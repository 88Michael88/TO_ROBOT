## Unit test results for db.py

### Wstęp

Testy zawarte w tym pliku sprawdzają funkcjonalność modułu `epc/db.py`, który implementuje repozytorium SQLite do zarządzania stanami User Equipment (UE) i bearerami. Testy skupiają się na weryfikacji:

- **Poprawności zapisu danych do bazy danych** — czy operacje takie jak `attach_ue()` i `add_bearer()` prawidłowo zapisują dane
- **Poprawności odczytu danych z bazy** — czy `get_ue()` i `list_ues()` zwracają prawidłowe dane
- **Obsługi błędów** — czy baza wyrzuca wyjątki dla operacji na nieistniejących elementach lub duplikatach
- **Integrości danych** — czy operacje `delete_bearer()`, `detach_ue()` i `reset_all()` prawidłowo usuwają dane

---

### Uruchomienie testów

```bash
python -m pytest tests/DB/test_db.py -v
```

Lub dla bardziej szczegółowego outputu:
```bash
python -m pytest tests/DB/test_db.py -vv --tb=short
```

---

### Setup — In-Memory Database i Fixtures

#### Tworzenie bazy danych
Testy używają **in-memory SQLite bazy** (`:memory:`), która je zainicjalizowana dla każdego testu. To znaczy, że:
- Każdy test dostaje świeżą, pustą bazę danych
- Po testu baza jest automatycznie wyczyszczana
- Testy są izolowane i nie wpływają na siebie

#### Fixture `repo()`
```python
@pytest.fixture
def repo():
    """Fixture that provides a fresh in-memory database for each test"""
    repository = EPCRepository(db_path=":memory:")
    yield repository
```

Fixture automatycznie:
- Tworzy nową instancję `EPCRepository` z `:memory:` bazą
- Dostarcza ją do testu poprzez parametr `repo`
- Czyszczi po sobie (automatycznie dla in-memory baz)

---

### Problem: In-Memory Database Connection Handling

#### Dlaczego `fixed_conn()` jest potrzebny?

Oryginalny kod `db.py` tworzy nowe połączenie do bazy za każdym razem gdy jest wywoływana metoda `_conn()`:

```python
def _conn(self):
    conn = sqlite3.connect(self._path)  
    return conn
```

Bez mechanizmu fixed_conn test wyglądałby tak:

* _init_schema tworzy tabelę w "Bazie A" (połączenie nr 1)

* repo.attach_ue(1) otwiera "Bazę B" (połączenie nr 2), w której tabela nie istnieje

* Aplikacja zgłasza błąd: sqlite3.OperationalError: no such table: ue_state



#### Rozwiązanie — `fixed_conn()`:
```python
def fixed_conn(self):
    """Fix for in-memory database connection handling"""
    if not hasattr(self, '_shared_conn'):
        self._shared_conn = sqlite3.connect(self._path, check_same_thread=False)
        self._shared_conn.row_factory = sqlite3.Row
    return self._shared_conn

EPCRepository._conn = fixed_conn  
```

To reużywa to samo połączenie dla tej samej instancji bazy, więc:
- Dane zapisane w `test 1` są dostępne w `test 2` (dla tej samej fixture)
- In-memory baza pozostaje spójna

---

### Grupy testów

#### **TestAttachUE** — Attachment UE do bazy
Testy sprawdzające proces mechanizm attachowania nowego User Equipment do bazy.
Sprawdzają również początkowy zapis i automatyczne tworzenie domyślnego bearera.

- `test_attach_ue_saves_correctly` — Czy UE jest prawidłowo zapisywane do bazy
- `test_default_bearer_9_created` — Czy przy dodaniu UE automatycznie tworzy się bearer 9 
- `test_attach_duplicate_ue_raises_error` — Czy próba dodania istniejącego UE wyrzuca błąd

 

---

#### **TestDetachUE** — Usuwanie UE z bazy
Testy sprawdzające mechanizm detachowania User Equipment z bazy.
Sprawdzają czy usuwanie danych i obsługę błędów dla operacji na nieistniejących elementach.

- `test_detach_removes_ue` — Czy usunięcie UE rzeczywiście go usuwa z bazy
- `test_detach_nonexistent_ue_raises_error` — Czy próba usunięcia nieistniejącego UE wyrzuca błąd



---

#### **TestBearer** — Zarządzanie bearerami
Testy sprawdzające wszystkie operacje na bearerach (dodawanie, usuwanie, walidacja)

- `test_add_bearer_to_ue` — Czy można dodać nowy bearer do istniejącego UE
- `test_add_duplicate_bearer_raises_error` — Czy próba dodania duplikatowego bearera wyrzuca błąd
- `test_delete_nonexistent_bearer_raises_error` — Czy próba usunięcia nieistniejącego bearera wyrzuca błąd
- `test_delete_default_bearer_raises_error` — Czy próba usunięcia default bearera  jest zablokowana
- `test_delete_bearer_removes_it` — Czy usunięcie bearera rzeczywiście go usuwa z bazy



---

#### **TestGetUE** — Odczyt danych UE
Testy sprawdzające pobieranie danych UE z bazy, poprawność odczytu danych i obsługę błędów

- `test_get_existing_ue` — Czy pobranie istniejącego UE zwraca prawidłowe dane
- `test_get_nonexistent_ue_raises_error` — Czy pobranie nieistniejącego UE wyrzuca błąd


---

#### **TestListUEs** — Listing UE
Testy sprawdzające listing wszystkich UE w bazie

- `test_list_ues_shows_all` — Czy listing pokazuje wszystkie dodane UE
- `test_list_ues_empty` — Czy listing pustej bazy zwraca pustą listę
- `test_list_ues_ordered` — Czy listing zwraca UE w porządku rosnącym


---

#### **TestReset** — Resetowanie bazy
Testy sprawdzające reset całej bazy

- `test_reset_removes_all_ues` — Czy reset usuwa wszystkie UE
- `test_reset_on_empty_db` — Czy reset działaluje też na pustej bazie


---

#### **TestEdgeCases** — Przypadki graniczne i walidacja
Testy sprawdzające edge casy i walidację danych

- `test_operation_on_nonexistent_ue_raises_error` — Czy operacje na nieistniejącym UE wyrzucają błędy
- `test_add_bearer_to_nonexistent_ue_raises_error` — Czy dodanie bearera do nieistniejącego UE wyrzuca błąd
- `test_delete_bearer_from_nonexistent_ue_raises_error` — Czy usunięcie bearera z nieistniejącego UE wyrzuca błąd
- `test_attach_valid_ue_ids[1]`, `[100]` — Czy walidne UE IDs (1, 100) mogą być dodane
- `test_attach_unvalid_ue_ids[0]`, `[101]` — Czy niewalidne UE IDs (0, 101) są odrzucane
- `test_add_valid_bearer_ids[1]`, `[5]`, `[8]` — Czy walidne bearer IDs mogą być dodane


---

## Wyniki testów

| Test | Result |
| --- | --- |
| TestAttachUE::test_attach_ue_saves_correctly | PASSED |
| TestAttachUE::test_default_bearer_9_created | PASSED |
| TestAttachUE::test_attach_duplicate_ue_raises_error | PASSED |
| TestDetachUE::test_detach_removes_ue | PASSED |
| TestDetachUE::test_detach_nonexistent_ue_raises_error | PASSED |
| TestBearer::test_add_bearer_to_ue | PASSED |
| TestBearer::test_add_duplicate_bearer_raises_error | PASSED |
| TestBearer::test_delete_nonexistent_bearer_raises_error | PASSED |
| TestBearer::test_delete_default_bearer_raises_error | PASSED |
| TestBearer::test_delete_bearer_removes_it | PASSED |
| TestGetUE::test_get_existing_ue | PASSED |
| TestGetUE::test_get_nonexistent_ue_raises_error | PASSED |
| TestListUEs::test_list_ues_shows_all | PASSED |
| TestListUEs::test_list_ues_empty | PASSED |
| TestListUEs::test_list_ues_ordered | PASSED |
| TestReset::test_reset_removes_all_ues | PASSED |
| TestReset::test_reset_on_empty_db | PASSED |
| TestEdgeCases::test_operation_on_nonexistent_ue_raises_error | PASSED |
| TestEdgeCases::test_add_bearer_to_nonexistent_ue_raises_error | PASSED |
| TestEdgeCases::test_delete_bearer_from_nonexistent_ue_raises_error | PASSED |
| TestEdgeCases::test_attach_valid_ue_ids[1] | PASSED |
| TestEdgeCases::test_attach_valid_ue_ids[100] | PASSED |
| TestEdgeCases::test_attach_unvalid_ue_ids[0] | PASSED |
| TestEdgeCases::test_attach_unvalid_ue_ids[101] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[1] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[5] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[8] | PASSED |

**Summary: 27 passed in 0.49s** 
