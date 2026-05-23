from fastapi.testclient import TestClient

from main import app
from epc.api import get_repo

import pytest

@pytest.fixture
def client():
    repo = get_repo()
    repo.reset_all()

    with TestClient(app) as c:
        yield c

    repo.reset_all()
