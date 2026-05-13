*** Settings ***
Documentation   This test suite verifies the UE detach procedure (Functionality 2).
Resource        Resources/DetachConfiguration.resource
Resource        Resources/SetupTeardown.resource
Resource        Resources/DetachVerification.resource

Suite Setup     Clean Environment
Suite Teardown  Clean Environment
Test Setup      Prepare Test Environment
Test Teardown   Clean Empty Test Environment


*** Test Cases ***
FN 2 TC 01 - Successful Detach Of Attached UE
    [Documentation]     Verify that an attached UE detaches successfully and response contains status and ue_id.
    Verify Detach UE42 From Network

FN 2 TC 02 - Detached UE Disappears From List
    [Documentation]     Verify that UE ID is no longer present in GET /ues after detach.
    Detach UE42 From Network
    Verify UE42 Absent From List

FN 2 TC 03 - GET On Detached UE Returns Error
    [Documentation]     Verify that GET /ues/{ue_id} fails after detach.
    Detach UE42 From Network
    Verify GET UE42 Returns Error

FN 2 TC 04 - Detach Fails When UE Is Not Attached
    [Documentation]     Verify that detaching a UE that is not in the network returns an error.
    [Setup]             Prepare Empty Test Environment
    Verify Detach UE42 From Network Expected 400 Error

FN 2 TC 05 - UE Can Be Re-Attached After Detach
    [Documentation]     Verify that a detached UE can be attached again successfully.
    Detach UE42 From Network
    Verify Attach UE42 Successfully Re-Attached


*** Keywords ***
Verify Attach UE42 Successfully Re-Attached
    [Documentation]     Attach UE42 again and verify success.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=42
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}  expected_status=any

    Should Be Equal As Integers     ${RESPONSE.status_code}     200
    Should Be Equal As Strings      ${RESPONSE.json()}[status]  attached
