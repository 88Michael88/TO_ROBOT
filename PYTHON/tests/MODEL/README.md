# Model.py unit tests

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
