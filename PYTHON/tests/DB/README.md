## Unit test results for db.py

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
| TestEdgeCases::test_attach_valid_ue_ids[50] | PASSED |
| TestEdgeCases::test_attach_valid_ue_ids[100] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[1] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[5] | PASSED |
| TestEdgeCases::test_add_valid_bearer_ids[8] | PASSED |

**Summary: 26 passed in 0.43s** 
