*** Settings ***
Documentation    Weryfikacja resetu z poprawnym formatem danych.
Library          RequestsLibrary
Library          Collections

*** Variables ***
${BASE_URL}      http://localhost:8000
${TEST_UE_ID}    ${50}    

*** Test Cases ***
Verify Simulator Reset And Inspect Content
    [Documentation]  this is simple reset request
    # Create Session: create a HTTP session to a server
    Create Session    my_session    ${BASE_URL}

    #try to create temporary UE to check if it will be removed 
    ${payload}=    Create Dictionary    ue_id=${TEST_UE_ID}
    #ignore error if ID is already taken because assumption is completed anyway
    Run Keyword And Ignore Error    POST On Session    my_session    /ues    json=${payload}


    # Check and log number of Attached UE's BEFORE reset
    ${count_ue}=  Check number of Attached UE's
    Log To Console    \nLiczba urządzeń w ues przed resetem: ${count_ue}

    # reset
    POST On Session    my_session    /reset

    # Check and log number of Attached UE's after reset
    ${count_ue}=  Check number of Attached UE's
    Log To Console    \nLiczba urządzeń w ues po resecie: ${count_ue}
    Verify List Is Empty  ${count_ue}


*** Keywords ***
Check number of Attached UE's
    [Documentation]  Check and log number of Attached UE's to show number of UE's attached before and after   
    ${RESPONSE}=    GET On Session    my_session    /ues
    ${ues_list}=    Set Variable    ${RESPONSE.json()}[ues]
    ${LIST_LENGTH}=    Get Length    ${ues_list}
    RETURN          ${LIST_LENGTH}

Verify List Is Empty
    [Documentation]  Checks if list is empty meaning reset was succesfull
    [Arguments]      ${LIST_COUNT}
    Should Be Equal As Integers    ${LIST_COUNT}    0
