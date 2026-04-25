*** Settings ***
Documentation   This resource has all the needed keywords to verify the attach procedure.
Library         Collections
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        42


*** Keywords ***
Verify Attach UE${UeId} To Network
    [Documentation]     Attach UE and verify the response contains status and ue_id.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}  expected_status=any

    Should Be Equal As Integers     ${RESPONSE.status_code}             200
    Should Be Equal As Strings      ${RESPONSE.json()}[status]          attached
    Should Be Equal As Integers     ${RESPONSE.json()}[ue_id]           ${UeId}

Verify Attach UE${UeId} To Network Expected ${ErrorCode} Error
    [Documentation]     Attach UE and verify the response returns expected error code.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}  expected_status=any

    Should Be Equal As Integers     ${RESPONSE.status_code}             ${ErrorCode}

Verify Default Bearer Assigned To UE${UeId}
    [Documentation]     Verify that bearer ID 9 is present after attach via GET /ues/{ue_id}.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        GET On Session      connectSession  /ues/${UeId}

    Dictionary Should Contain Key   ${RESPONSE.json()}[bearers]         9

Verify UE${UeId} Present In List
    [Documentation]     Verify that UE ID appears in GET /ues response.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        GET On Session      connectSession  /ues

    List Should Contain Value       ${RESPONSE.json()}[ues]             ${${UeId}}

