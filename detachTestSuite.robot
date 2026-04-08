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