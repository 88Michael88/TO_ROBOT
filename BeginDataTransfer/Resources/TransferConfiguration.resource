*** Settings ***
Documentation   This resource has all the needed keywords for configuring the transfer
Library         String


*** Variables ***
${SPEED}        NONE        # 1 / 50 / 99 / 100 / 101
${SPEED_bps}    NONE        # The speed in bps
${UNITS}        NONE        # bps / kbps / Mbps
${PROTOCOL}     NONE        # tcp / udp


*** Keywords ***
Set Transter Speed To ${Speed} ${Units}
    [Documentation]     Here we set the transfer speed for the connection.
    ${SPEED}            Convert To Integer  ${Speed}
    Parse ${Units} And ${SPEED}
    Set Test Variable   ${SPEED}     ${SPEED}
    Set Test Variable   ${UNITS}     ${Units}

Set ${Protocol} Protocol
    [Documentation]     Here we set the protocol on the connection.
    ${PROTOCOL}=        Convert To Lower Case   ${Protocol}

    Set Test Variable   ${PROTOCOL}  ${PROTOCOL}

Parse ${Units} And ${Speed}
    [Documentation]     Hello
    IF    '${Units}' == 'bps'
        ${SPEED_bps}=    Set Variable   ${Speed}
    ELSE IF    '${Units}' == 'kbps'
        ${SPEED_bps}=    Evaluate       ${Speed} * 1000
    ELSE IF    '${Units}' == 'Mbps'
        ${SPEED_bps}=    Evaluate       ${Speed} * 1000000
    ELSE
        Fail   Unsupported unit: ${Units}
    END
    Set Test Variable  ${SPEED_bps}     ${SPEED_bps}
