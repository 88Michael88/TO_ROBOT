*** Settings ***
Documentation   This resource has all the needed keywords to verify the detach procedure.
Library         Collections
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        42


*** Keywords ***
Verify Detach UE${UeId} From Network
    [Documentation]     Detach UE and verify the response contains status and ue_id.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UeId}  expected_status=any

    Should Be Equal As Integers     ${RESPONSE.status_code}             200
    Should Be Equal As Strings      ${RESPONSE.json()}[status]          detached
    Should Be Equal As Integers     ${RESPONSE.json()}[ue_id]           ${UeId}

Verify Detach UE${UeId} From Network Expected ${ErrorCode} Error
    [Documentation]     Detach UE and verify the response returns expected error code.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UeId}  expected_status=any

    Should Be Equal As Integers     ${RESPONSE.status_code}             ${ErrorCode}

Verify UE${UeId} Absent From List
    [Documentation]     Verify that UE ID does not appear in GET /ues response after detach.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        GET On Session      connectSession  /ues

    List Should Not Contain Value   ${RESPONSE.json()}[ues]             ${${UeId}}

Verify GET UE${UeId} Returns Error
    [Documentation]     Verify that GET /ues/{ue_id} returns an error after detach.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        GET On Session      connectSession  /ues/${UeId}  expected_status=any

    Should Not Be Equal As Integers     ${RESPONSE.status_code}         200
