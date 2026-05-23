# Model.py Testy Jednostkowe

Testy do modelu znajdują się w pliku `test_model.py` w katalogu `tests/MODEL/`.
Testy jednostkowe sprawdzały poprawne działanie następujący klas: 
 
- AttachUERequest
- AddBearerRequest
- BearerConfig
- UEState
- StartTrafficRequest

Testy zostały wykonane przy użyciu następującego polecenia:

``` bash 
docker build -t epc-simulator . 
docker run --rm -e PYTHONPATH=. epc-simulator uv run pytest -v -q
```

> [!Important]
> Bardzo ważne jest zbudowanie kontenera za każdym razem gdy modyfikujemy testy.

## Rodzaje Testów

Zostały wykonane dwa rodzaje unit testów: 
- pierwszy rodzaj sprawdza działanie danego modelu i zakład poprawne działanie - brak wyrzucenia błędu.
- drugi rodzaj sprawdza działanie danego modelu i oczekuje wyrzucenie błędu. Ten rodzaj testu sprawdza czy poprawnie działa weryfikacja danych.

## Wyniki Testów

| Test | Rodzaj Testu | Co Sprawdza | Wynik |
|-----------------------------------------------------|---|-|-|
| test_attach_request_accepts_valid_range             | 1 | | PASSED |
| test_attach_request_rejects_invalid_range           | 2 | | PASSED |
| test_add_bearer_accepts_valid_range                 | 1 | | PASSED |
| test_add_bearer_rejects_invalid_range               | 2 | | PASSED |
| test_bearer_config_defaults                         | 1 | | PASSED |
| test_bearer_config_accepts_valid_protocol           | 1 | | PASSED |
| test_bearer_config_rejects_invalid_protocol         | 2 | | PASSED |
| test_ue_state_initializes_empty_dicts               | 1 | | PASSED |
| test_ue_state_converts_none_to_empty_dicts          | 1 | | PASSED |
| test_start_traffic_target_bps                       | 1 | | PASSED |
| test_start_traffic_requires_exactly_one_throughput  | 2 | | PASSED |
| test_start_traffic_requires_at_least_one_throughput | 2 | | PASSED |
| test_start_traffic_rejects_invalid_protocol         | 2 | | PASSED |
