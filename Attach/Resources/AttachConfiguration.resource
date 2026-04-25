*** Settings ***
Documentation   This resource contains all configuration variables for the Attach test suite.


*** Variables ***
${BASE_URL}           http://localhost:8000
${UE_ID}              42
${UE_ID_MIN}          0
${UE_ID_MAX}          100
${UE_ID_TOO_HIGH}     101
${UE_ID_NEGATIVE}     -1
${DEFAULT_BEARER_ID}  9


*** Keywords ***
Set UE ID To ${UeId}
    [Documentation]     Set the UE ID to be used in the test.
    Set Test Variable   ${UE_ID}    ${UeId}
