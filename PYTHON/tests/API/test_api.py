from unittest.mock import MagicMock, patch

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from epc.models import (
    BearerConfig,
    ThroughputStats,
    UEState,
)

from epc.api import router, get_repo


NOW = 1_700_000_000.0

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture()
def mock_repo():
    repo = MagicMock()
    repo.list_ues.return_value = []
    repo.ue_exists.return_value = True
    return repo


@pytest.fixture()
def mock_tm():
    tm = MagicMock()
    tm.is_running.return_value = False
    return tm


@pytest.fixture()
def client(mock_repo, mock_tm):
    app = FastAPI()
    app.include_router(router)
    app.dependency_overrides[get_repo] = lambda: mock_repo

    with patch("epc.api.get_traffic_manager", return_value=mock_tm):
        with TestClient(app) as client:
            yield client


# ---------------------------------------------------------------------------
# GET /ues
# ---------------------------------------------------------------------------

class TestListUEs:
    def test_empty_list(self, client, mock_repo):
        mock_repo.list_ues.return_value = []
        r = client.get("/ues")
        assert r.status_code == 200
        assert r.json() == {"ues": []}

    def test_returns_attached_ue_ids(self, client, mock_repo):
        mock_repo.list_ues.return_value = [1, 2, 5]
        r = client.get("/ues")
        assert r.status_code == 200
        assert r.json() == {"ues": [1, 2, 5]}


# ---------------------------------------------------------------------------
# POST /ues
# ---------------------------------------------------------------------------

class TestAttachUE:
    def test_attach_success(self, client, mock_repo):
        r = client.post("/ues", json={"ue_id": 3})
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "attached"
        assert body["ue_id"] == 3

    def test_attach_duplicate_raises_400(self, client, mock_repo):
        mock_repo.attach_ue.side_effect = ValueError("UE already attached")
        r = client.post("/ues", json={"ue_id": 3})
        assert r.status_code == 400
        assert "already" in r.json()["detail"].lower()

    @pytest.mark.parametrize("ue_id", [0, 101])
    def test_attach_invalid_ue_invalid_id(self, client, ue_id):
        r = client.post("/ues", json={"ue_id": ue_id})
        assert r.status_code == 422


# ---------------------------------------------------------------------------
# GET /ues/{ue_id}
# ---------------------------------------------------------------------------

class TestGetUE:
    def test_get_existing_ue(self, client, mock_repo):
        mock_repo.get_ue.return_value = UEState(ue_id=7)
        r = client.get("/ues/7")
        assert r.status_code == 200
        assert r.json()["ue_id"] == 7

    def test_get_nonexistent_ue_returns_400(self, client, mock_repo):
        mock_repo.get_ue.side_effect = ValueError("UE not found")
        r = client.get("/ues/99")
        assert r.status_code == 400
        assert "not found" in r.json()["detail"].lower()

# ---------------------------------------------------------------------------
# DELETE /ues/{ue_id}
# ---------------------------------------------------------------------------

class TestDetachUE:
    def test_detach_success(self, client, mock_repo):
        r = client.delete("/ues/1")
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "detached"
        assert body["ue_id"] == 1

    def test_detach_nonexistent_returns_400(self, client, mock_repo):
        mock_repo.detach_ue.side_effect = ValueError("UE not found")
        r = client.delete("/ues/42")
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# POST /ues/{ue_id}/bearers
# ---------------------------------------------------------------------------

class TestAddBearer:
    def test_add_bearer_success(self, client, mock_repo):
        mock_repo.get_ue.return_value = UEState(ue_id=1)
        r = client.post("/ues/1/bearers", json={"bearer_id": 3})
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "bearer_added"
        assert body["bearer_id"] == 3
        assert body["ue_id"] == 1

    @pytest.mark.parametrize("bearer_id", [0, 10])
    def test_add_bearer_invalid_id(self, client, bearer_id):
        r = client.post("/ues/1/bearers", json={"bearer_id": bearer_id})
        assert r.status_code == 422

    def test_add_bearer_exists_returns_400(self, client, mock_repo):
        mock_repo.add_bearer.side_effect = ValueError("Bearer already exists")
        r = client.post("/ues/1/bearers", json={"bearer_id": 1})
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# DELETE /ues/{ue_id}/bearers/{bearer_id}
# ---------------------------------------------------------------------------

class TestDeleteBearer:
    def test_delete_bearer_success(self, client, mock_repo, mock_tm):
        bearer = BearerConfig(bearer_id=2)
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={2: bearer})
        r = client.delete("/ues/1/bearers/2")
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "bearer_deleted"
        assert body["bearer_id"] == 2

    def test_delete_missing_bearer_returns_400(self, client, mock_repo):
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={})
        r = client.delete("/ues/1/bearers/5")
        assert r.status_code == 400
        assert "not found" in r.json()["detail"].lower()


# ---------------------------------------------------------------------------
# POST /ues/{ue_id}/bearers/{bearer_id}/traffic
# ---------------------------------------------------------------------------

class TestStartTraffic:
    def _start(self, client, ue_id=1, bearer_id=1, payload=None):
        payload = payload or {"protocol": "udp", "Mbps": 1.0}
        return client.post(f"/ues/{ue_id}/bearers/{bearer_id}/traffic", json=payload)

    @pytest.mark.parametrize("unit,speed,expected", [("Mbps", 2.0, 2_000_000), ("kbps", 500.0, 500_000), ("bps", 12345, 12345)])
    def test_start_traffic(self, client, mock_repo, mock_tm, unit, speed, expected):
        bearer = BearerConfig(bearer_id=1)
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={1: bearer})
        r = self._start(client, payload={"protocol": "tcp", unit: speed})
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "traffic_started"
        assert body["target_bps"] == expected

    # invalid protocol, multiple transfer speeds, missing transfer speed
    @pytest.mark.parametrize("payload", [{"protocol": "bleh", "Mbps": 1.0}, {"protocol": "udp", "Mbps": 1.0, "kbps": 500.0}, {"protocol": "udp"}])
    def test_start_traffic_validation_errors(self, client, payload):
        r = self._start(client, payload=payload)
        assert r.status_code == 422

    def test_start_traffic_tm_error_returns_400(self, client, mock_repo, mock_tm):
        bearer = BearerConfig(bearer_id=1)
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={1: bearer})
        mock_tm.start.side_effect = ValueError("Traffic already running")
        r = self._start(client)
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# DELETE /ues/{ue_id}/bearers/{bearer_id}/traffic
# ---------------------------------------------------------------------------

class TestStopTraffic:
    def test_stop_traffic_success(self, client, mock_repo, mock_tm):
        bearer = BearerConfig(bearer_id=1, active=True)
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={1: bearer})
        r = client.delete("/ues/1/bearers/1/traffic")
        assert r.status_code == 200
        body = r.json()
        assert body["status"] == "traffic_stopped"
        assert body["ue_id"] == 1
        assert body["bearer_id"] == 1
        mock_tm.stop.assert_called_once_with(1, 1)

# ---------------------------------------------------------------------------
# GET /ues/{ue_id}/bearers/{bearer_id}/traffic
# ---------------------------------------------------------------------------

class TestGetTrafficStats:
    def test_stats_completed_traffic(self, client, mock_repo, mock_tm):
        stats = ThroughputStats(ue_id=1, bearer_id=9, bytes_tx=800, bytes_rx=400, start_ts=NOW, last_update_ts=NOW + 1)
        bearer = BearerConfig(bearer_id=1, protocol="udp")
        mock_repo.get_ue.return_value = UEState(ue_id=1, bearers={1: bearer}, stats={1: stats})
        mock_tm.is_running.return_value = False
        r = client.get("/ues/1/bearers/1/traffic")
        assert r.status_code == 200
        body = r.json()
        assert body["tx_bps"] == 6400
        assert body["rx_bps"] == 3200
        assert body["duration"] == pytest.approx(1.0)

# ---------------------------------------------------------------------------
# GET /ues/stats
# ---------------------------------------------------------------------------

class TestGetUEStats:
    def test_global_stats_with_traffic(self, client, mock_repo, mock_tm):
        stats = ThroughputStats(ue_id=1, bearer_id=9, bytes_tx=800, bytes_rx=400, start_ts=NOW, last_update_ts=NOW + 1)
        bearer = BearerConfig(bearer_id=1, active=True)
        state = UEState(ue_id=1, bearers={1: bearer}, stats={1: stats})
        mock_repo.list_ues.return_value = [1]
        mock_repo.get_ue.return_value = state
        mock_tm.is_running.return_value = False
        r = client.get("/ues/stats")
        assert r.status_code == 200
        body = r.json()
        assert body["bearer_count"] == 1
        assert body["total_tx_bps"] == 6400
        assert body["total_rx_bps"] == 3200

    def test_stats_for_specific_ue(self, client, mock_repo, mock_tm):
        mock_repo.ue_exists.return_value = True
        stats = ThroughputStats(ue_id=2, bearer_id=9, bytes_tx=1000, bytes_rx=500, start_ts=NOW, last_update_ts=NOW + 1)
        state = UEState(ue_id=2, bearers={1: BearerConfig(bearer_id=9)}, stats={1: stats})
        mock_repo.get_ue.return_value = state
        mock_tm.is_running.return_value = False
        r = client.get("/ues/stats?ue_id=2")
        assert r.status_code == 200
        body = r.json()
        assert body["scope"] == "ue:2"
        assert body["ue_count"] == 1

# ---------------------------------------------------------------------------
# POST /reset
# ---------------------------------------------------------------------------

class TestResetAll:
    def test_reset_returns_ok(self, client, mock_repo, mock_tm):
        r = client.post("/reset")
        assert r.status_code == 200
        assert r.json() == {"status": "reset"}

    def test_reset_calls_stop_all_and_repo_reset(self, client, mock_repo, mock_tm):
        client.post("/reset")
        mock_tm.stop_all.assert_called_once()
        mock_repo.reset_all.assert_called_once()