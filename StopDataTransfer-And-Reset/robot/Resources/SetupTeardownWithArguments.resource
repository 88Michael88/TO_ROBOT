*** Settings ***
Documentation   This resource has all the needed keywords concerning set ups and tear downs.
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000

*** Keywords ***
Attach Bearer To Network
    [Documentation]    Add dedicated bearer to UE
    [Arguments]    ${ue_id}  ${bearer_id}
    Create Session    connectSession    ${BASE_URL}    disable_warnings=True
    
    ${BODY}=    Create Dictionary    bearer_id=${bearer_id}
    ${RESPONSE}=    POST On Session    connectSession    /ues/${ue_id}/bearers    json=${BODY}
    
    RETURN    ${RESPONSE}

Start Traffic On Bearer
    [Documentation]    Start traffic on specific bearer for UE
    [Arguments]    ${ue_id}  ${bearer_id}  ${mbps}
    Create Session    connectSession    ${BASE_URL}    disable_warnings=True
    
    ${BODY}=    Create Dictionary    protocol=tcp    Mbps=${mbps}
    ${RESPONSE}=    POST On Session    connectSession    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${BODY}
    
    RETURN    ${RESPONSE}

Stop Traffic On Bearer
    [Documentation]    Stop traffic on specific bearer for UE
    [Arguments]    ${ue_id}  ${bearer_id}
    Create Session    connectSession    ${BASE_URL}    disable_warnings=True
    
    ${RESPONSE}=    DELETE On Session    connectSession    /ues/${ue_id}/bearers/${bearer_id}/traffic
    
    RETURN    ${RESPONSE}

Get Traffic Stats
    [Documentation]    Get traffic statistics for specific bearer
    [Arguments]    ${ue_id}  ${bearer_id}
    Create Session    connectSession    ${BASE_URL}    disable_warnings=True
    
    ${RESPONSE}=    GET On Session    connectSession    /ues/${ue_id}/bearers/${bearer_id}/traffic
    ${tx_bps}=    Set Variable    ${RESPONSE.json()}[tx_bps]
    
    RETURN    ${tx_bps}


Attach UE To Network
    [Documentation]     Attach UE with id UeId to the network.
    [Arguments]    ${ue_id}
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${ue_id}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}

    Set Test Variable   ${ue_id}            ${ue_id}

    RETURN              ${RESPONSE}

Reset Simulator
    ${resp}=       POST    ${BASE_URL}/reset
    Status Should Be    200    ${resp}
