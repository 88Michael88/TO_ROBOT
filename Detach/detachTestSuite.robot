*** Settings ***
Library        RequestsLibrary
Library        Collections

Suite Setup       Create Session    epc    http://localhost:8000
Suite Teardown    Delete All Sessions

*** Variables ***
${BASE_URL}               http://localhost:8000
${VALID_UE_ID}            42

*** Keywords ***
Reset Simulator
    POST On Session    epc    /reset    expected_status=200

Attach UE
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${response}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    RETURN    ${response}

Detach UE
    [Arguments]    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id}    expected_status=any
    RETURN    ${response}

*** Test Cases ***

TC_DETACH_01 Pomyślne odłączenie podłączonego UE
    [Documentation]    Podłączone UE może zostać odłączone od sieci.
    [Tags]    detach    positive
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    ${response}=    Detach UE    ${VALID_UE_ID}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json}[status]    detached
    Should Be Equal As Integers    ${json}[ue_id]    ${VALID_UE_ID}

TC_DETACH_02 Odłączone UE znika z listy podłączonych UE
    [Documentation]    Po odłączeniu GET /ues nie powinno zawierać UE ID.
    [Tags]    detach    positive
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    Detach UE    ${VALID_UE_ID}
    ${response}=    GET On Session    epc    /ues    expected_status=200
    ${json}=    Set Variable    ${response.json()}
    List Should Not Contain Value    ${json}[ues]    ${VALID_UE_ID}

TC_DETACH_03 Błąd przy próbie odłączenia niepodłączonego UE
    [Documentation]    Odłączenie UE które nie jest w sieci powinno zwrócić błąd.
    [Tags]    detach    negative
    Reset Simulator
    ${response}=    Detach UE    ${VALID_UE_ID}
    Should Not Be Equal As Integers    ${response.status_code}    200

TC_DETACH_04 Brak danych UE po odłączeniu - GET zwraca błąd
    [Documentation]    Po odłączeniu GET /ues/{ue_id} powinien zwrócić błąd - zasób nie istnieje.
    [Tags]    detach    positive
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    Detach UE    ${VALID_UE_ID}
    ${response}=    GET On Session    epc    /ues/${VALID_UE_ID}    expected_status=any
    Should Not Be Equal As Integers    ${response.status_code}    200

TC_DETACH_05 Możliwe ponowne podłączenie UE po odłączeniu
    [Documentation]    Po odłączeniu UE powinno dać się podłączyć ponownie.
    [Tags]    detach    positive
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    Detach UE    ${VALID_UE_ID}
    ${response}=    Attach UE    ${VALID_UE_ID}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json}[status]    attached