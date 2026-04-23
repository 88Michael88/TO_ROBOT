*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Library         RequestsLibrary
# Test Setup      Prepare Test Environment
# Test Teardown   Clean Test Environment


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        7
${BEARER_ID}    1
${SPEED}        NONE        # 1 / 50 / 99 / 100 / 101
${SPEED_bps}    NONE        # The speed in bps
${UNITS}        NONE        # bps / Kbps / Mbps
${PROTOCOL}     NONE        # TCP / UDP


*** Test Cases ***
TC 8
    [Documentation]     Prepare the environment with an invalid Bearer ID.
    Prepare Test Environment Without Bearer  # This can be a custom set up.
    Set Transter Speed To 50 Kbps

    Clean Test Environment Without Bearer  # This can be a custom tear down.

TC 9
    [Documentation]     Prepare the environment with an invalid Bearer ID.
    Prepare Test Environment Without Bearer  # This can be a custom set up.
    Set Transter Speed To 50 Mbps

    Clean Test Environment Without Bearer  # This can be a custom tear down.

TC 10
    [Documentation]     Prepare the environment with an invalid Bearer ID.
    Prepare Test Environment Without Bearer  # This can be a custom set up.
    Set Transter Speed To 100 Mbps

    Clean Test Environment Without Bearer  # This can be a custom tear down.

TC 11
    [Documentation]     Prepare the environment normally, but use an invalid Bearer ID.
    Prepare Test Environment
    Set Transter Speed To 50 Kbps

    Clean Test Environment  # This can be a custom tear down.

TC 12
    [Documentation]     Prepare the environment normally, but use an invalid Bearer ID.
    Prepare Test Environment   # This can be a custom set up.
    Set Transter Speed To 50 Mbps

    Clean Test Environment   # This can be a custom tear down.

TC 13
    [Documentation]     Prepare the environment normally, but use an invalid Bearer ID.
    Prepare Test Environment  # This can be a custom set up.
    Set Transter Speed To 100 Mbps

    Clean Test Environment   # This can be a custom tear down.


*** Keywords ***
# Here we have out set ups and tear downs.
Prepare Test Environment
    [Documentation]     Here we will Attach the UE and Attach the Bearer.
    Attach UE7 To Network
    Attach Bearer1 To UE7

Clean Test Environment
    [Documentation]     Here we will Detach the UE and Detach the Bearer.
    Detach Bearer1 From UE7
    Detach UE7 From Network

Prepare Test Environment Without Bearer
    [Documentation]     Here we will Attach the UE without Attaching the Bearer.
    Attach UE7 To Network

Clean Test Environment Without Bearer
    [Documentation]     Here we will Attach the UE without Detaching the Bearer.
    Detach UE7 From Network

# Here we have the Key Words that will be treated as functions.
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
    [Documentation]     Here we set the transfer speed for the connection.
    Set Test Variable   ${SPEED}     ${Speed}
    Set Test Variable   ${UNITS}     ${Units}

Set ${Protocol} Protocol
    [Documentation]     Here we set the protocol on the connection.
    Set Test Variable   ${PROTOCOL}  ${Protocol}

Verify Transfer  # HERE WE HAVE TO TEST THE PROTOCOL it could be TCP or UDP
    [Documentation]     Here we will execute the transfer speed test.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   "protocol"="tcp",${UNITS}=${SPEED}
    Log To Console      ${BODY}
    ${RESPONSE}=        POST On Session     connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic

    Sleep               ${DURATION}         Testing the connection for a duration of time.

