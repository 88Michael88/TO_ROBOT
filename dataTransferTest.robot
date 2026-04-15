*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000


*** Test Cases ***
TC 1
    [Documentation]     Test One!
    Prepare Test Environment
    # Attach UE, to Get the UE ID.
    # Attach Bearer, to Get the Bearer ID.
    # Pick a Transfer Speed.

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.

TC 2
    [Documentation]     Test Two!
    Clean Test Environment


*** Keywords ***
Prepare Test Environment
    [Documentation]     Here we will Attach the UE and Attach the DL.
    ${RESPONSE_UE}=     Attach UE7 To Network
    ${RESPONSE_BR}=     Attach Bearer1 To UE7
    Log To Console      ${RESPONSE_UE.text}
    Log To Console      ${RESPONSE_BR.text}

Clean Test Environment
    [Documentation]     Here we will Detach the UE and Detach the DL.
    Create Session      detachUE        ${BASE_URL}
    # Here we have to detach the UE and Bearers.

Attach UE${UeId} To Network
    [Documentation]     Attach UE with id ue_id to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY_UE}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE_UE}=        POST On Session     connectSession  /ues  json=${BODY_UE}

    RETURN              ${RESPONSE_UE}

Attach Bearer${BearerId} To UE${UeId}
    [Documentation]     Attach Bearer with bearer_id to UE with ue_id.
    Create Session      connectSession      ${BASE_URL}

    ${BODY_BR}=            Create Dictionary   bearer_id=${BearerId}
    ${RESPONSE_BR}=        POST On Session     connectSession   /ues/${UeId}/bearers  json=${BODY_BR}

    RETURN              ${RESPONSE_BR}
