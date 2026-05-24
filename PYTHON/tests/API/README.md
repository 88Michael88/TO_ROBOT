## Unit test results for api.py

| Test | Result |
| --- | --- |
| TestListUEs::test_empty_list| PASSED |
| TestListUEs::test_returns_attached_ue_ids| PASSED |
| TestAttachUE::test_attach_success| PASSED |
| TestAttachUE::test_attach_duplicate_raises_400| PASSED |
| TestAttachUE::test_attach_invalid_ue_invalid_id[0]| PASSED |
| TestAttachUE::test_attach_invalid_ue_invalid_id[101]| PASSED |
| TestGetUE::test_get_existing_ue| PASSED |
| TestGetUE::test_get_nonexistent_ue_returns_400| PASSED |
| TestDetachUE::test_detach_success| PASSED |
| TestDetachUE::test_detach_nonexistent_returns_400| PASSED |
| TestAddBearer::test_add_bearer_success| PASSED |
| TestAddBearer::test_add_bearer_invalid_id[0]| PASSED |
| TestAddBearer::test_add_bearer_invalid_id[10]| PASSED |
| TestAddBearer::test_add_bearer_exists_returns_400| PASSED |
| TestDeleteBearer::test_delete_bearer_success| PASSED |
| TestDeleteBearer::test_delete_missing_bearer_returns_400| PASSED |
| TestStartTraffic::test_start_traffic[Mbps-2.0-2000000]| PASSED |
| TestStartTraffic::test_start_traffic[kbps-500.0-500000]| PASSED |
| TestStartTraffic::test_start_traffic[bps-12345-12345]| PASSED |
| TestStartTraffic::test_start_traffic_validation_errors[payload0]| PASSED |
| TestStartTraffic::test_start_traffic_validation_errors[payload1]| PASSED |
| TestStartTraffic::test_start_traffic_validation_errors[payload2]| PASSED |
| TestStartTraffic::test_start_traffic_tm_error_returns_400| PASSED |
| TestStopTraffic::test_stop_traffic_success| PASSED |
| TestGetTrafficStats::test_stats_completed_traffic| PASSED |
| TestGetUEStats::test_global_stats_with_traffic| PASSED |
| TestGetUEStats::test_stats_for_specific_ue| PASSED |
| TestResetAll::test_reset_returns_ok| PASSED |
| TestResetAll::test_reset_calls_stop_all_and_repo_reset| PASSED |
