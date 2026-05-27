import pytest
from pydantic import ValidationError

from epc.models import (
    AttachUERequest,
    AddBearerRequest,
    StartTrafficRequest,
    BearerConfig,
    UEState,
)


# =========================================================
# AttachUERequest
# =========================================================

@pytest.mark.parametrize("ue_id", [1, 25, 100])
def test_attach_request_accepts_valid_range(ue_id):
    model = AttachUERequest(ue_id=ue_id)

    assert model.ue_id == ue_id


@pytest.mark.parametrize("ue_id", [0, -1, 101])
def test_attach_request_rejects_invalid_range(ue_id):
    with pytest.raises(ValidationError):
        AttachUERequest(ue_id=ue_id)


# =========================================================
# AddBearerRequest
# =========================================================

@pytest.mark.parametrize("bearer_id", [1, 5, 9])
def test_add_bearer_accepts_valid_range(bearer_id):
    model = AddBearerRequest(bearer_id=bearer_id)

    assert model.bearer_id == bearer_id


@pytest.mark.parametrize("bearer_id", [0, 10, -5])
def test_add_bearer_rejects_invalid_range(bearer_id):
    with pytest.raises(ValidationError):
        AddBearerRequest(bearer_id=bearer_id)


# =========================================================
# BearerConfig
# =========================================================

def test_bearer_config_defaults():
    model = BearerConfig(bearer_id=1)

    assert model.protocol is None
    assert model.target_bps is None
    assert model.active is False


@pytest.mark.parametrize("protocol", ["tcp", "udp"])
def test_bearer_config_accepts_valid_protocol(protocol):
    model = BearerConfig(
        bearer_id=1,
        protocol=protocol,
    )

    assert model.protocol == protocol


@pytest.mark.parametrize("protocol", ["quic", "http", ""])
def test_bearer_config_rejects_invalid_protocol(protocol):
    with pytest.raises(ValidationError):
        BearerConfig(
            bearer_id=1,
            protocol=protocol,
        )


# =========================================================
# UEState
# =========================================================

def test_ue_state_initializes_empty_dicts():
    model = UEState(ue_id=1)

    assert model.bearers == {}
    assert model.stats == {}


def test_ue_state_converts_none_to_empty_dicts():
    model = UEState(
        ue_id=1,
        bearers=None,
        stats=None,
    )

    assert model.bearers == {}
    assert model.stats == {}


# =========================================================
# StartTrafficRequest
# =========================================================

@pytest.mark.parametrize(
    "payload,expected_bps",
    [
        ({"protocol": "tcp", "Mbps": 10}, 10_000_000),
        ({"protocol": "udp", "kbps": 500}, 500_000),
        ({"protocol": "tcp", "bps": 1234}, 1234),
    ],
)
def test_start_traffic_target_bps(payload, expected_bps):
    model = StartTrafficRequest(**payload)

    assert model.target_bps() == expected_bps


def test_start_traffic_requires_exactly_one_throughput():
    with pytest.raises(ValidationError):
        StartTrafficRequest(
            protocol="tcp",
            Mbps=10,
            kbps=500,
        )


def test_start_traffic_requires_at_least_one_throughput():
    with pytest.raises(ValidationError):
        StartTrafficRequest(protocol="udp")


@pytest.mark.parametrize("protocol", ["quic", "http"])
def test_start_traffic_rejects_invalid_protocol(protocol):
    with pytest.raises(ValidationError):
        StartTrafficRequest(
            protocol=protocol,
            Mbps=1,
        )
