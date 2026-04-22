*** Settings ***
Documentation    Weryfikacja punktu 5: Precyzyjne i całkowite zakończenie transferu
Library          RequestsLibrary
Library          Collections
Suite Setup      Setup UE With Multiple Bearers

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         ${10}

*** Test Cases ***
Verify Specific Bearer Removal
    [Documentation]    Test sprawdza, czy po usunięciu jednego bearera, pozostałe 2 wciąż istnieją
    DELETE On Session    my_session    /ues/${UE_ID}/bearers/2
    
    ${resp}=    GET On Session    my_session    /ues/${UE_ID}
    ${bearers}=    Set Variable    ${resp.json()}[bearers]
    ${count}=      Get Length    ${bearers}
    Should Be Equal As Integers    ${count}    2
    Log To Console    \nPozostałe bearery po usunięciu jednego: ${count}

Verify Total Detach Removes Everything
    [Documentation]    Test sprawdza, czy usunięcie całego UE czyści wszystko (lista UE pusta)
    DELETE On Session    my_session    /ues/${UE_ID}
    
    ${resp}=    GET On Session    my_session    /ues
    ${ues_list}=    Set Variable    ${resp.json()}[ues]
    ${count}=       Get Length      ${ues_list}
    Should Be Equal As Integers    ${count}    0
    Log To Console    \nLiczba UE w systemie po Detach: ${count}

*** Keywords ***
Setup UE With Multiple Bearers
    [Documentation]    Przygotowuje środowisko: resetuje symulator i dodaje UE z 3 bearerami
    Create Session    my_session    ${BASE_URL}
    POST On Session    my_session    /reset

    ${ue_data}=    Create Dictionary    ue_id=${10}
    POST On Session    my_session    /ues    json=${ue_data}
   
    ${b2}=    Create Dictionary    bearer_id=${2}
    POST On Session    my_session    /ues/10/bearers    json=${b2}
    ${b3}=    Create Dictionary    bearer_id=${3}
    POST On Session    my_session    /ues/10/bearers    json=${b3}
   
    Log To Console    \nSetup zakończony: UE ${UE_ID} posiada 3 bearery.
