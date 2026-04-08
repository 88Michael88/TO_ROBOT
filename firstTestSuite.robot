# ACK - Acceptance Criteria
# Warstwy
# Opisowa
# Implementacyjna
# Embedded keywords
*** Settings ***
Documentation    This is a simple file where we try to understand robot.
Library          RequestsLibrary


*** Variables ***
${BASE_URL}      http://localhost:8000


*** Test Cases ***
Quick And Simpe Get Request Test
    [Documentation]  This is a simple get request
    # Create Session: create a HTTP session to a server
    Create Session   mysession  ${BASE_URL}

    ${RESPONSE}=  GET On Session  mysession  /ues

    Log   ${RESPONSE.status_code}

    Log To Console   ${RESPONSE.text}

Attach User Equipement
    [Documentation]  Attach UE to the network
    ${RESPONSE}=  Connect UE7 To Network

    Verify If ${RESPONSE} Is Valid


*** Keywords ***
Connect UE${ue_id} To Network
    [Documentation]   Connect UE with id ue_id to the network.
    Create Session  connectSession  ${BASE_URL}

    ${BODY}=  Create Dictionary   ue_id=${ue_id}

    ${RESPONSE}=  POST On Session   connectSession  /ues  json=${BODY}

    Log To Console  ${RESPONSE.status_code}

    Log To Console  ${RESPONSE.text}

    RETURN  ${RESPONSE}

Verify If ${result} Is Valid
    [Documentation]  Here we check if the UE has been successfully added to the network.
    Should Be Equal As Integers  ${result.status_code}  200
