# Traffic.py unit tests

Testy znajduja sie w pliku `test_traffic_manager.py` i sprawdzaja klase
`TrafficGeneratorManager` z modulu `PYTHON/epc/traffic.py`.

Repozytorium EPC jest zamockowane przez `FakeRepo`, dzieki czemu testy nie
korzystaja z prawdziwej bazy SQLite. Planowanie zadan w tle jest zamockowane
przez `FakeScheduler`, a osobny test uruchamia coroutine bezposrednio przez
`asyncio.run`, zeby sprawdzic zapis statystyk.

## Wyniki testow

| Test | Co sprawdza | Wynik |
|---|---|---|
| `test_start_adds_task_and_marks_bearer_as_running` | Czy `start()` dodaje zadanie do `self.tasks` i czy `is_running()` zwraca `True`. | Passed |
| `test_is_running_is_false_before_start_and_after_stop` | Czy `is_running()` zwraca `False` przed startem i po `stop()`, oraz czy zadanie jest anulowane. | Passed |
| `test_start_rejects_bearer_that_is_already_running` | Czy ponowne uruchomienie ruchu dla tego samego bearera konczy sie bledem `ValueError`. | Passed |
| `test_start_rejects_bearer_without_protocol_or_speed` | Czy bearer bez protokolu, bez predkosci albo z predkoscia `0` jest odrzucany. | Passed |
| `test_stop_all_cancels_every_running_bearer` | Czy `stop_all()` anuluje wszystkie uruchomione zadania i czysci `self.tasks`. | Passed |
| `test_simulated_bearer_updates_stats_and_last_update_timestamp` | Czy symulowany bearer zapisuje bajty, protokol, `target_bps` i `last_update_ts` w statystykach. | Passed |

Ostatnie uruchomienie:

```powershell
cd "C:\Users\jkbpo\Desktop\Testowanie oprogramowania\TO_ROBOT\PYTHON"
uv run pytest ..\TrafficTests -q
```

Wynik:

```text
8 passed in 0.18s
```
