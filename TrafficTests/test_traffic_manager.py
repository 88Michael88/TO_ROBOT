import asyncio
import time

import pytest

import epc.traffic as traffic_module
from epc.models import BearerConfig, ThroughputStats, UEState
from epc.traffic import TrafficGeneratorManager


class FakeFuture:
    def __init__(self):
        self.cancelled = False

    def cancel(self):
        self.cancelled = True


class FakeScheduler:
    def __init__(self):
        self.futures: list[FakeFuture] = []

    def __call__(self, coroutine, loop):
        coroutine.close()
        future = FakeFuture()
        self.futures.append(future)
        return future


class FakeRepo:
    def __init__(self, state: UEState):
        self.state = state
        self.saved_stats: list[ThroughputStats] = []

    def get_ue(self, ue_id: int) -> UEState:
        assert ue_id == self.state.ue_id
        return self.state

    def update_stats(self, ue_id: int, stats: ThroughputStats) -> None:
        assert ue_id == self.state.ue_id
        self.state.stats[stats.bearer_id] = stats
        self.saved_stats.append(stats.model_copy())


@pytest.fixture
def repo():
    return FakeRepo(UEState(ue_id=1))


@pytest.fixture
def scheduler(monkeypatch):
    scheduler = FakeScheduler()
    monkeypatch.setattr(traffic_module.asyncio, "run_coroutine_threadsafe", scheduler)
    return scheduler


@pytest.fixture
def manager(repo, scheduler):
    manager = TrafficGeneratorManager(repo)
    yield manager
    manager.stop_all()


def configured_bearer(bearer_id: int = 5) -> BearerConfig:
    return BearerConfig(
        bearer_id=bearer_id,
        protocol="tcp",
        target_bps=8_000,
        active=True,
    )


def test_start_adds_task_and_marks_bearer_as_running(manager):
    bearer = configured_bearer()

    manager.start(ue_id=1, bearer=bearer)

    assert (1, bearer.bearer_id) in manager.tasks
    assert manager.is_running(1, bearer.bearer_id) is True


def test_is_running_is_false_before_start_and_after_stop(manager):
    bearer = configured_bearer()

    assert manager.is_running(1, bearer.bearer_id) is False

    manager.start(ue_id=1, bearer=bearer)
    future = manager.tasks[(1, bearer.bearer_id)]
    manager.stop(ue_id=1, bearer_id=bearer.bearer_id)

    assert future.cancelled is True
    assert manager.is_running(1, bearer.bearer_id) is False
    assert (1, bearer.bearer_id) not in manager.tasks


def test_start_rejects_bearer_that_is_already_running(manager):
    bearer = configured_bearer()
    manager.start(ue_id=1, bearer=bearer)

    with pytest.raises(ValueError, match="Traffic already running"):
        manager.start(ue_id=1, bearer=bearer)


@pytest.mark.parametrize(
    "bearer",
    [
        BearerConfig(bearer_id=1, protocol=None, target_bps=8_000),
        BearerConfig(bearer_id=2, protocol="udp", target_bps=None),
        BearerConfig(bearer_id=3, protocol="tcp", target_bps=0),
    ],
)
def test_start_rejects_bearer_without_protocol_or_speed(manager, bearer):
    with pytest.raises(ValueError, match="Bearer not configured for traffic"):
        manager.start(ue_id=1, bearer=bearer)

    assert manager.tasks == {}


def test_stop_all_cancels_every_running_bearer(manager):
    first = configured_bearer(bearer_id=1)
    second = configured_bearer(bearer_id=2)

    manager.start(ue_id=1, bearer=first)
    manager.start(ue_id=1, bearer=second)
    futures = list(manager.tasks.values())
    manager.stop_all()

    assert all(future.cancelled for future in futures)
    assert manager.tasks == {}
    assert manager.is_running(1, first.bearer_id) is False
    assert manager.is_running(1, second.bearer_id) is False


def test_simulated_bearer_updates_stats_and_last_update_timestamp(repo):
    manager = TrafficGeneratorManager(repo)
    started_at = time.time()

    async def run_one_update():
        task = asyncio.create_task(
            manager._run_simulated_bearer(
                ue_id=1,
                bearer_id=7,
                target_bps=8_000,
                protocol="udp",
            )
        )
        await asyncio.sleep(0.05)
        task.cancel()
        await asyncio.gather(task, return_exceptions=True)

    asyncio.run(run_one_update())

    stats = repo.state.stats[7]
    assert stats.bytes_tx == 1_000
    assert stats.bytes_rx == 1_000
    assert stats.protocol == "udp"
    assert stats.target_bps == 8_000
    assert stats.start_ts is not None
    assert stats.last_update_ts is not None
    assert stats.last_update_ts >= started_at
    assert repo.saved_stats[-1].last_update_ts == stats.last_update_ts
