*** Settings ***
Documentation   This resource contains all configuration variables for the Detach test suite.


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        42


*** Keywords ***
Set UE ID To ${UeId}
    [Documentation]     Set the UE ID to be used in the test.
    Set Test Variable   ${UE_ID}    ${UeId}
