*** Settings ***
Documentation   This resource has all the needed keywords concerning set ups and tear downs.
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        42


*** Keywords ***
Prepare Test Environment
    [Documentation]     Attach UE to the network before the test.
    Attach UE${UE_ID} To Network

Clean Test Environment
    [Documentation]     Detach UE from the network after the test.
    Detach UE${UE_ID} From Network

Prepare Empty Test Environment
    [Documentation]     No setup needed - UE should not be attached.
    No Operation

Clean Empty Test Environment
    [Documentation]     No cleanup needed - attach was expected to fail.
    No Operation

Clean Environment
    [Documentation]     Reset the simulator to a clean state.
    Create Session      connectSession      ${BASE_URL}
    POST On Session     connectSession      /reset


Attach UE${UeId} To Network
    [Documentation]     Attach UE with id UeId to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}  expected_status=any

    Set Test Variable   ${UE_ID}            ${UeId}

    RETURN              ${RESPONSE}

Detach UE${UeId} From Network
    [Documentation]     Detach UE with id UeId from the network.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UeId}  expected_status=any

    RETURN              ${RESPONSE}
