*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Library         RequestsLibrary
# Test Setup      Prepare Test Environment
# Test Teardown   Clean Test Environment


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        7
${BEARER_ID}    1
${SPEED}        NONE
${UNITS}        NONE


*** Test Cases ***
TC 1
    [Documentation]     Test One!
    Prepare Test Environment
    Set Transter Speed To 1 bps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 2
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 1 Kbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 3
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 1 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 4
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 50 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 5
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 99 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 6
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 100 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 7
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 101 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment

TC 8
    [Documentation]     Prepare the environment with an invalid Bearer ID.
    Prepare Test Environment Without Bearer  # This can be a custom set up.
    Set Transter Speed To 50 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment Without Bearer  # This can be a custom tear down.

TC 9
    [Documentation]     Prepare the environment with an invalid UE ID.
    Prepare Test Environment Without UE  # This can be a custom set up.
    Set Transter Speed To 50 Mbps

    # Use different speeds. One larger, equal to, one smaller than the max Mbps.
    # Use a invalid UE ID.
    # Use a invalid Bearer ID.
    Clean Test Environment Without UE  # This can be a custom tear down.


*** Keywords ***
Prepare Test Environment
    [Documentation]     Here we will Attach the UE and Attach the Bearer.
    Attach UE7 To Network
    Attach Bearer1 To UE7

Clean Test Environment
    [Documentation]     Here we will Detach the UE and Detach the Bearer.
    Detach Bearer1 From UE7
    Detach UE7 From Network

Attach UE${UeId} To Network
    [Documentation]     Attach UE with id UeId to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}

    Set Test Variable   ${UE_ID}            ${UeId}

    RETURN              ${RESPONSE}

Detach UE${UeId} From Network
    [Documentation]     Detach UE with id UeId from the network.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UeId}

    RETURN              ${RESPONSE}

Attach Bearer${BearerId} To UE${UeId}
    [Documentation]     Attach Bearer with BearerId to UE with UeId.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   bearer_id=${BearerId}
    ${RESPONSE}=        POST On Session     connectSession   /ues/${UeId}/bearers  json=${BODY}

    Set Test Variable   ${BEARER_ID}        ${BearerId}

    RETURN              ${RESPONSE}

Detach Bearer${BearerId} From UE${UeId}
    [Documentation]     Detach Bearer with BearerId from UE with UeId
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession   /ues/${UeId}/bearers/${BearerId}

    RETURN              ${RESPONSE}

Set Transter Speed To ${Speed} ${Units}
    [Documentation]     Here we will set the transfer speed for the connection.

    Set Test Variable   ${SPEED}    ${Speed}
    Set Test Variable   ${UNITS}    ${Units}
