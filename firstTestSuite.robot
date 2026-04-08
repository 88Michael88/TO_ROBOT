# ACK - Acceptance Criteria
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
