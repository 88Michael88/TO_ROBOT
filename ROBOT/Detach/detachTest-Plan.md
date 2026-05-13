# Test Plan – Odłączenie UE od sieci (Detach)

| ID    | Nazwa                                      | Typ       | Warunek wstępny                     | Kroki                                 | Oczekiwany rezultat                            |
|-------|--------------------------------------------|-----------|-------------------------------------|---------------------------------------|------------------------------------------------|
| TC_01 | Pomyślne odłączenie podłączonego UE        | Pozytywny | UE jest podłączone                  | POST /ues → DELETE /ues/{id}          | HTTP 200, `status: detached`, poprawne `ue_id` |
| TC_02 | Odłączone UE znika z listy                 | Pozytywny | UE jest podłączone                  | DELETE /ues/{id} → GET /ues           | UE ID nie występuje w tablicy `ues`            |
| TC_03 | Błąd przy odłączeniu niepodłączonego UE    | Negatywny | UE nie jest podłączone              | DELETE /ues/{id}                      | HTTP != 200                                    |
| TC_04 | GET na odłączone UE zwraca błąd            | Negatywny | UE było podłączone, potem odłączone | DELETE /ues/{id} → GET /ues/{id}      | HTTP != 200                                    |
| TC_05 | Ponowne podłączenie UE po odłączeniu       | Pozytywny | UE było podłączone                  | DELETE /ues/{id} → POST /ues          | HTTP 200, `status: attached`                   |
