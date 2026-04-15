# ACK - Acceptance Criteria
# Resources:
# https://docs.robotframework.org/docs/different_libraries/requests
# https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html
# Warstwy
# Opisowa
# Implementacyjna
# Embedded keywords

*** Settings ***
Documentation    This is a simple file where we try to understand robot.
Library          RequestsLibrary


*** Variables ***
${BASE_URL}      http://localhost:8000
${RESPONSE}      NONE


*** Test Cases ***
TC 1 Quick And Simpe Get Request Test
    [Documentation]  This is a simple get request
    # Create Session: create a HTTP session to a server
    Create Session   mysession  ${BASE_URL}

    ${RESPONSE}=  GET On Session  mysession  /ues

    Log   ${RESPONSE.status_code}

    Log To Console   ${RESPONSE.text}

TC 2 Attach User Equipement
    [Documentation]  Attach UE to the network
    Attach UE7 To Network
    Verify If Response Is Valid


*** Keywords ***
Attach UE${ue_id} To Network
    [Documentation]     Attach UE with id ue_id to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${ue_id}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}

    Log To Console      ${RESPONSE.status_code}
    Log To Console      ${RESPONSE.text}

    Set Test Variable   ${RESPONSE}

Verify If Response Is Valid
    [Documentation]  Here we check if the UE has been successfully added to the network.
    Should Be Equal As Integers  ${RESPONSE.status_code}  200
