*** Settings ***
Documentation   This resource has all the needed keywords to verify the transfer.
Library         RequestsLibrary
Library         String


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        7
${BEARER_ID}    1
${SPEED}        NONE        # 1 / 50 / 99 / 100 / 101
${UNITS}        NONE        # bps / kbps / Mbps
${PROTOCOL}     NONE        # TCP / UDP


*** Keywords ***
Verify Transfer
    [Documentation]     Here we will execute the transfer speed test.
    Start Transfer
    Sleep               1
    Get Transfer
    End Transfer

Start Transfer
    [Documentation]     Start the transfer of data
    Create Session      connectSession      ${BASE_URL}

    ${SPEED}            Convert To Integer  ${SPEED}
    ${PROTOCOL}=        Convert To Lower Case   ${PROTOCOL}
    ${BODY}=            Create Dictionary   protocol=${PROTOCOL}    ${UNITS}=${SPEED}
    Log To Console      ${BODY}
    ${RESPONSE}=        POST On Session     connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic  json=${BODY}

Get Transfer
    [Documentation]     Check if the transfer is valid
    # Remember to check the units
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        Get On Session   connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic
    Validate Transfer ${RESPONSE} Received

Validate Transfer ${Response} Received
    [Documentation]     Validating if the transfer matches assumptions
    Log To Console      ${Response}

End Transfer
    [Documentation]     End the transfer of data
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic
