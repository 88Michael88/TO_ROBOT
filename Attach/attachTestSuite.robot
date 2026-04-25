*** Settings ***
Library    RequestsLibrary
Library    Collections

Suite Setup       Create Session    epc    http://localhost:8000
Suite Teardown    Delete All Sessions

*** Variables ***
${VALID_UE_ID}        42
${VALID_UE_ID_MIN}    0
${VALID_UE_ID_MAX}    100
${UE_ID_TOO_HIGH}     101
${UE_ID_NEGATIVE}     -1
${DEFAULT_BEARER}     9

*** Keywords ***
Reset Simulator
    POST On Session    epc    /reset    expected_status=200

Attach UE
    [Arguments]    ${ue_id}
    ${body}=      Create Dictionary    ue_id=${ue_id}
    ${response}=  POST On Session    epc    /ues    json=${body}    expected_status=any
    RETURN        ${response}

*** Test Cases ***

# ------------------------------------------------------------------------------
# Testy pozytywne
# ------------------------------------------------------------------------------

TC_ATTACH_01 Pomyślne podłączenie UE z poprawnym ID
    [Documentation]    Odpowiedź zawiera status "attached" oraz poprawne ue_id.
    [Tags]    attach    positive
    Reset Simulator
    ${response}=    Attach UE    ${VALID_UE_ID}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings     ${json}[status]    attached
    Should Be Equal As Integers    ${json}[ue_id]     ${VALID_UE_ID}

TC_ATTACH_02 Podłączone UE automatycznie otrzymuje domyślny bearer o ID 9
    [Documentation]    Weryfikacja przez GET /ues/{ue_id}.
    [Tags]    attach    positive
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    ${response}=    GET On Session    epc    /ues/${VALID_UE_ID}    expected_status=200
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}[bearers]    ${DEFAULT_BEARER}

TC_ATTACH_03 Pomyślne podłączenie UE z minimalnym ID = 0
    [Documentation]    Wartość graniczna — UE ID = 0.
    [Tags]    attach    positive    boundary
    Reset Simulator
    ${response}=    Attach UE    ${VALID_UE_ID_MIN}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json}[status]    attached

TC_ATTACH_04 Pomyślne podłączenie UE z maksymalnym ID = 100
    [Documentation]    Wartość graniczna — UE ID = 100.
    [Tags]    attach    positive    boundary
    Reset Simulator
    ${response}=    Attach UE    ${VALID_UE_ID_MAX}
    Should Be Equal As Integers    ${response.status_code}    200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${json}[status]    attached

TC_ATTACH_05 Możliwe podłączenie dwóch różnych UE jednocześnie
    [Documentation]    Oba UE widoczne na liście GET /ues.
    [Tags]    attach    positive
    Reset Simulator
    ${r1}=    Attach UE    10
    ${r2}=    Attach UE    20
    Should Be Equal As Integers    ${r1.status_code}    200
    Should Be Equal As Integers    ${r2.status_code}    200
    ${response}=    GET On Session    epc    /ues    expected_status=200
    ${json}=    Set Variable    ${response.json()}
    List Should Contain Value    ${json}[ues]    ${10}
    List Should Contain Value    ${json}[ues]    ${20}

TC_ATTACH_06 Po podłączeniu UE stats zwracają bearer_count = 1
    [Documentation]    GET /ues/stats powinno uwzględniać domyślny bearer o ID 9.
    [Tags]    attach    positive    bug
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    ${params}=      Create Dictionary    ue_id=${VALID_UE_ID}
    ${response}=    GET On Session    epc    /ues/stats    params=${params}    expected_status=200
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Integers    ${json}[bearer_count]    1

# ------------------------------------------------------------------------------
# Testy negatywne – walidacja zakresu UE ID
# ------------------------------------------------------------------------------

TC_ATTACH_07 Błąd przy UE ID = 101 (powyżej zakresu)
    [Documentation]    Wartość graniczna — UE ID = 101.
    [Tags]    attach    negative    boundary
    Reset Simulator
    ${response}=    Attach UE    ${UE_ID_TOO_HIGH}
    Should Not Be Equal As Integers    ${response.status_code}    200

TC_ATTACH_08 Błąd przy ujemnym UE ID
    [Documentation]    Wartość graniczna — UE ID = -1.
    [Tags]    attach    negative    boundary
    Reset Simulator
    ${response}=    Attach UE    ${UE_ID_NEGATIVE}
    Should Not Be Equal As Integers    ${response.status_code}    200

# ------------------------------------------------------------------------------
# Testy negatywne – duplikat attach
# ------------------------------------------------------------------------------

TC_ATTACH_09 Błąd przy ponownym podłączeniu już podłączonego UE
    [Documentation]    Drugi attach tego samego UE ID.
    [Tags]    attach    negative
    Reset Simulator
    Attach UE    ${VALID_UE_ID}
    ${response}=    Attach UE    ${VALID_UE_ID}
    Should Not Be Equal As Integers    ${response.status_code}    200
