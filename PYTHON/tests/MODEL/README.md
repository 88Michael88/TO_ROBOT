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


| Test | Rodzaj Testu | Co sprawdza | Wynik  |
|-----------------------------------------------------|---|---------------------------------------------------------------------------------------------------------------------------------|--------|
| test_attach_request_accepts_valid_range             | 1 | Sprawdza, czy model `AttachUERequest` akceptuje poprawne wartości `ue_id` z zakresu 1–100.                                      | PASSED |
| test_attach_request_rejects_invalid_range           | 2 | Sprawdza, czy model `AttachUERequest` odrzuca niepoprawne wartości `ue_id`.                                                     | PASSED |
| test_add_bearer_accepts_valid_range                 | 1 | Sprawdza, czy model `AddBearerRequest` akceptuje poprawne wartości `bearer_id` z zakresu 1–9.                                   | PASSED |
| test_add_bearer_rejects_invalid_range               | 2 | Sprawdza, czy model `AddBearerRequest` odrzuca niepoprawne wartości `bearer_id`.                                                | PASSED |
| test_bearer_config_defaults                         | 1 | Sprawdza, czy model `BearerConfig` poprawnie ustawia wartości domyślne.                                                         | PASSED |
| test_bearer_config_accepts_valid_protocol           | 1 | Sprawdza, czy model `BearerConfig` akceptuje poprawne protokoły.                                                                | PASSED |
| test_bearer_config_rejects_invalid_protocol         | 2 | Sprawdza, czy model `BearerConfig` odrzuca niepoprawne protokoły.                                                               | PASSED |
| test_ue_state_initializes_empty_dicts               | 1 | Sprawdza, czy model `UEState` inicjalizuje pola `bearers` i `stats` jako puste słowniki.                                        | PASSED |
| test_ue_state_converts_none_to_empty_dicts          | 1 | Sprawdza, czy model `UEState` zamienia wartości `None` w polach `bearers` i `stats` na puste słowniki.                          | PASSED |
| test_start_traffic_target_bps                       | 1 | Sprawdza, czy metoda `target_bps()` poprawnie przelicza przepustowość z `Mbps`, `kbps` oraz `bps` na bity na sekundę.           | PASSED |
| test_start_traffic_requires_exactly_one_throughput  | 2 | Sprawdza, czy model `StartTrafficRequest` odrzuca przypadek podania więcej niż jednego parametru przepustowości jednocześnie.   | PASSED |
| test_start_traffic_requires_at_least_one_throughput | 2 | Sprawdza, czy model `StartTrafficRequest` wymaga podania przynajmniej jednego parametru przepustowości.                         | PASSED |
| test_start_traffic_rejects_invalid_protocol         | 2 | Sprawdza, czy model `StartTrafficRequest` odrzuca niepoprawne protokoły.                                                        | PASSED |


```bash 
$ docker build -t epc-simulator . && docker run --rm -e PYTHONPATH=. epc-simulator uv run pytest -v -q
[+] Building 24.1s (13/13) FINISHED                                                                                                                                          docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                   0.7s
 => => transferring dockerfile: 626B                                                                                                                                                   0.0s
 => [internal] load metadata for docker.io/library/python:3.12-slim                                                                                                                    2.7s
 => [internal] load .dockerignore                                                                                                                                                      0.6s
 => => transferring context: 2B                                                                                                                                                        0.0s
 => [1/8] FROM docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                              1.4s
 => => resolve docker.io/library/python:3.12-slim@sha256:090ba77e2958f6af52a5341f788b50b032dd4ca28377d2893dcf1ecbdfdfe203                                                              1.4s
 => [internal] load build context                                                                                                                                                      0.7s
 => => transferring context: 10.96kB                                                                                                                                                   0.0s
 => CACHED [2/8] WORKDIR /app                                                                                                                                                          0.0s
 => CACHED [3/8] RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*                                                                                          0.0s
 => CACHED [4/8] RUN curl -LsSfvvv https://astral.sh/uv/install.sh | sh                                                                                                                0.0s
 => CACHED [5/8] COPY pyproject.toml .                                                                                                                                                 0.0s
 => CACHED [6/8] RUN uv lock && uv sync --frozen --no-install-project                                                                                                                  0.0s
 => [7/8] COPY . .                                                                                                                                                                     3.2s
 => [8/8] RUN mkdir -p /data                                                                                                                                                           5.1s
 => exporting to image                                                                                                                                                                 4.0s
 => => exporting layers                                                                                                                                                                3.3s
 => => writing image sha256:e9324b9c475cb75220d4f7227f05b8d6b954ddd367640b281a5bfe2703cb6660                                                                                           0.0s
 => => naming to docker.io/library/epc-simulator                                                                                                                                       0.1s
   Building epc-simulator @ file:///app
      Built epc-simulator @ file:///app
Installed 1 package in 1ms
============================= test session starts ==============================
platform linux -- Python 3.12.13, pytest-7.4.4, pluggy-1.6.0
rootdir: /app
plugins: anyio-4.13.0
collected 27 items

tests/MODEL/test_model.py ...........................                    [100%]

============================== 27 passed in 0.27s ==============================
 ```
