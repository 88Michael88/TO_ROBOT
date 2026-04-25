*** Settings ***
Documentation   This resource has all the needed keywords to verify the transfer.
Library         Collections
Library         String
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        7
${BEARER_ID}    1
${SPEED}        NONE        # 1 / 50 / 99 / 100 / 101
${SPEED_bps}    NONE        # The speed in bps
${UNITS}        NONE        # bps / kbps / Mbps
${PROTOCOL}     NONE        # TCP / UDP
${DURATION}     100


*** Keywords ***
Verify Transfer
    [Documentation]     Here we will execute the transfer speed test.
    Start Transfer
    Sleep               ${DURATION}         Testing the connection for a duration of time.
    Get Transfer
    End Transfer

Verify Transfer Expected ${ErrorCode} Error
    [Documentation]     Here we will execute the transfer speed test.
    ${StatusCode}=      Start Transfer
    Should Be Equal As Integers     ${StatusCode}   ${ErrorCode}

Start Transfer
    [Documentation]     Start the transfer of data
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   protocol=${PROTOCOL}    ${UNITS}=${SPEED}
    Log To Console      \n${BODY}
    ${RESPONSE}=        POST On Session     connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic  json=${BODY}  expected_status=any

    RETURN              ${RESPONSE.status_code}

Get Transfer
    [Documentation]     Check if the transfer is valid
    # Remember to check the units
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        Get On Session   connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic
    Validate Transfer ${RESPONSE} Received

Validate Transfer ${Response} Received
    [Documentation]     Validating if the transfer matches assumptions
    Log To Console      ${Response.json()}
    Parse And Validate ${Response.json()} Dictionary

End Transfer
    [Documentation]     End the transfer of data
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}/traffic

Parse And Validate ${Dictionary} Dictionary
    [Documentation]     Comparing values as Integers
    Dictionary Should Contain Key   ${Dictionary}               ue_id
    Dictionary Should Contain Key   ${Dictionary}               bearer_id
    Dictionary Should Contain Key   ${Dictionary}               protocol
    Dictionary Should Contain Key   ${Dictionary}               target_bps
    Dictionary Should Contain Key   ${Dictionary}               duration

    Should Be Equal As Integers     ${Dictionary}[ue_id]        ${UE_ID}
    Should Be Equal As Integers     ${Dictionary}[bearer_id]    ${BEARER_ID}
    Should Be Equal As Strings      ${Dictionary}[protocol]     ${PROTOCOL}
    Should Be Equal As Integers     ${Dictionary}[target_bps]   ${SPEED_bps}
