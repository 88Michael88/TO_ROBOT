*** Settings ***
Documentation   This resource has all the needed keywords for configuring the transfer


*** Variables ***
${SPEED}        NONE        # 1 / 50 / 99 / 100 / 101
${UNITS}        NONE        # bps / kbps / Mbps
${PROTOCOL}     NONE        # TCP / UDP


*** Keywords ***
Set Transter Speed To ${Speed} ${Units}
    [Documentation]     Here we set the transfer speed for the connection.
    Set Test Variable   ${SPEED}     ${Speed}
    Set Test Variable   ${UNITS}     ${Units}

Set ${Protocol} Protocol
    [Documentation]     Here we set the protocol on the connection.
    Set Test Variable   ${PROTOCOL}  ${Protocol}
