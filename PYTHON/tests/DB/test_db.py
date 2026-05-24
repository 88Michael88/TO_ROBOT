import sqlite3
import sys
from pathlib import Path

import pytest

# Add parent directory to path to import epc module
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from epc.db import EPCRepository
from epc.models import BearerConfig, UEState


# ---------------------------------------------------------------------------
# Fix for in-memory database connection handling
# ---------------------------------------------------------------------------

def fixed_conn(self):
    """Fix for in-memory database connection handling."""
    if not hasattr(self, '_shared_conn'):
        self._shared_conn = sqlite3.connect(self._path, check_same_thread=False)
        self._shared_conn.row_factory = sqlite3.Row
    return self._shared_conn


EPCRepository._conn = fixed_conn


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def repo():
    """Fixture that provides a fresh in-memory database for each test."""
    repository = EPCRepository(db_path=":memory:")
    yield repository
    # Cleanup is automatic for in-memory databases


# ---------------------------------------------------------------------------
# Attach UE Tests
# ---------------------------------------------------------------------------

class TestAttachUE:
    def test_attach_ue_saves_correctly(self, repo):
        """Test if UE is correctly saved to database."""
        ue_id = 10
        repo.attach_ue(ue_id)
        
        assert repo.ue_exists(ue_id)
        state = repo.get_ue(ue_id)
        assert state.ue_id == ue_id

    def test_default_bearer_9_created(self, repo):
        """Test if default bearer 9 is created automatically."""
        ue_id = 5
        repo.attach_ue(ue_id)
        
        state = repo.get_ue(ue_id)
        assert 9 in state.bearers, "Bearer 9 should be added automatically!"
        assert state.bearers[9].bearer_id == 9

    def test_attach_duplicate_ue_raises_error(self, repo):
        """Test if attaching duplicate UE raises an error."""
        ue_id = 10
        repo.attach_ue(ue_id)
        
        with pytest.raises(ValueError, match="already attached"):
            repo.attach_ue(ue_id)


# ---------------------------------------------------------------------------
# Detach UE Tests
# ---------------------------------------------------------------------------

class TestDetachUE:
    def test_detach_removes_ue(self, repo):
        """Test if detach actually removes the UE from database."""
        repo.attach_ue(10)
        assert repo.ue_exists(10)
        
        repo.detach_ue(10)
        
        assert not repo.ue_exists(10)

    def test_detach_nonexistent_ue_raises_error(self, repo):
        """Test if detaching non-existent UE raises an error."""
        with pytest.raises(ValueError, match="not found"):
            repo.detach_ue(999)


# ---------------------------------------------------------------------------
# Bearer Tests
# ---------------------------------------------------------------------------

class TestBearer:
    def test_add_bearer_to_ue(self, repo):
        """Test if bearer can be added to existing UE."""
        repo.attach_ue(1)
        repo.add_bearer(1, 5)
        
        state = repo.get_ue(1)
        assert 5 in state.bearers

    def test_add_duplicate_bearer_raises_error(self, repo):
        """Test if adding existing bearer raises an error."""
        repo.attach_ue(10)
        # Bearer 9 is added automatically
        
        with pytest.raises(ValueError, match="already exists"):
            repo.add_bearer(10, 9)

    def test_delete_nonexistent_bearer_raises_error(self, repo):
        """Test if deleting non-existent bearer raises an error."""
        repo.attach_ue(10)
        
        with pytest.raises(ValueError, match="not found"):
            repo.delete_bearer(10, 5)

    def test_delete_default_bearer_raises_error(self, repo):
        """Test if deleting default bearer 9 is blocked."""
        repo.attach_ue(10)
        
        with pytest.raises(ValueError, match="default bearer"):
            repo.delete_bearer(10, 9)

    def test_delete_bearer_removes_it(self, repo):
        """Test if deleting bearer removes it from database."""
        repo.attach_ue(1)
        repo.add_bearer(1, 5)
        
        state = repo.get_ue(1)
        assert 5 in state.bearers
        
        repo.delete_bearer(1, 5)
        
        state = repo.get_ue(1)
        assert 5 not in state.bearers


# ---------------------------------------------------------------------------
# Get UE Tests
# ---------------------------------------------------------------------------

class TestGetUE:
    def test_get_existing_ue(self, repo):
        """Test if get_ue returns correct UE."""
        repo.attach_ue(7)
        
        state = repo.get_ue(7)
        
        assert state.ue_id == 7
        assert isinstance(state, UEState)

    def test_get_nonexistent_ue_raises_error(self, repo):
        """Test if getting non-existent UE raises an error."""
        with pytest.raises(ValueError, match="not found"):
            repo.get_ue(999)


# ---------------------------------------------------------------------------
# List UEs Tests
# ---------------------------------------------------------------------------

class TestListUEs:
    def test_list_ues_shows_all(self, repo):
        """Test if list_ues shows all correct IDs."""
        repo.attach_ue(1)
        repo.attach_ue(2)
        repo.attach_ue(3)
        
        ues = list(repo.list_ues())
        
        assert len(ues) == 3
        assert 1 in ues
        assert 2 in ues
        assert 3 in ues

    def test_list_ues_empty(self, repo):
        """Test if list_ues returns empty list when no UEs."""
        ues = list(repo.list_ues())
        
        assert len(ues) == 0

    def test_list_ues_ordered(self, repo):
        """Test if list_ues returns ordered IDs."""
        repo.attach_ue(5)
        repo.attach_ue(1)
        repo.attach_ue(3)
        
        ues = list(repo.list_ues())
        
        assert ues == [1, 3, 5]


# ---------------------------------------------------------------------------
# Reset Tests
# ---------------------------------------------------------------------------

class TestReset:
    def test_reset_removes_all_ues(self, repo):
        """Test if reset removes all UEs."""
        repo.attach_ue(1)
        repo.attach_ue(2)
        
        repo.reset_all()
        
        assert not repo.ue_exists(1)
        assert not repo.ue_exists(2)
        assert list(repo.list_ues()) == []

    def test_reset_on_empty_db(self, repo):
        """Test if reset works on empty database."""
        repo.reset_all()
        
        assert list(repo.list_ues()) == []


# ---------------------------------------------------------------------------
# Edge Cases
# ---------------------------------------------------------------------------

class TestEdgeCases:
    def test_operation_on_nonexistent_ue_raises_error(self, repo):
        """Test if operations on non-existent UE raise an error."""
        with pytest.raises(ValueError, match="not found"):
            repo.get_ue(999)
        
        with pytest.raises(ValueError, match="not found"):
            repo.detach_ue(999)

    def test_add_bearer_to_nonexistent_ue_raises_error(self, repo):
        """Test if adding bearer to non-existent UE raises error."""
        with pytest.raises(ValueError, match="not found"):
            repo.add_bearer(999, 5)

    def test_delete_bearer_from_nonexistent_ue_raises_error(self, repo):
        """Test if deleting bearer from non-existent UE raises error."""
        with pytest.raises(ValueError, match="not found"):
            repo.delete_bearer(999, 5)

    @pytest.mark.parametrize("ue_id", [1, 50, 100])
    def test_attach_valid_ue_ids(self, repo, ue_id):
        """Test if various valid UE IDs can be attached."""
        repo.attach_ue(ue_id)
        
        assert repo.ue_exists(ue_id)

    @pytest.mark.parametrize("bearer_id", [1, 5, 8])
    def test_add_valid_bearer_ids(self, repo, bearer_id):
        """Test if various valid bearer IDs can be added."""
        repo.attach_ue(1)
        repo.add_bearer(1, bearer_id)
        
        state = repo.get_ue(1)
        assert bearer_id in state.bearers
