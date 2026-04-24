*** Settings ***
Documentation   

Library         Collections
Library         String
Library         RequestsLibrary

Suite Setup     Prepare Environment

*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        5     #ue [1-100]
${UE_ID2}       6     #ue [1-100]
${UE_ID3}       7     #ue [1-100]

${BEARER_ID}    1     #berer[1-8] with default 9 
${BEARER_ID2}   2     #berer[1-8] with default 9 
${BEARER_ID3}   3     #berer[1-8] with default 9 

*** Test Cases ***
TC_9 01_stats
    [Documentation]  reset with single ue
    Reset Simulator
    Attach UE To Network  ${UE_ID}

    ${ue_count}=  Check number of Attached UEs Using /ues
    Log To Console    \nLiczba urządzeń w ues przed resetem: ${ue_count}

    Reset Simulator
    
    ${ue_count}=  Check number of Attached UEs Using /ues
    Log To Console    \nLiczba urządzeń w ues po resecie: ${ue_count}

    Verify List Is Empty  ${ue_count}

    
TC_9 02
    [Documentation]  reset with single berer - verify bearer is deleted after reset
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}

    ${bearer_count_before}=  Check Number Of Bearers For UE  ${UE_ID}
    Log To Console    \nLiczba bererów przed resetem: ${bearer_count_before}
    Should Be Equal As Integers  ${bearer_count_before}  2  msg=Should have default bearer 9 and bearer ${BEARER_ID}

    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${bearer_count_after}=  Check Number Of Bearers For UE  ${UE_ID}
    Log To Console    \nLiczba bererów po resecie: ${bearer_count_after}

    Should Be Equal As Integers  ${bearer_count_after}  1  msg=After reset should only have default bearer 9

TC_9 03
    [Documentation]  reset with single active traffic - verify traffic is stopped after reset
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50

    ${stats_before}=  Get Traffic Stats  ${UE_ID}  ${BEARER_ID}
    Log To Console    \nTx bps przed resetem: ${stats_before}
    Should Not Be Equal  ${stats_before}  0  msg=Transfer powinien mieć wartość > 0

    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    ${stats_after}=  Get Traffic Stats  ${UE_ID}  ${BEARER_ID}
    Log To Console    \nTx bps po resecie: ${stats_after}
    Should Be Equal As Integers  ${stats_after}  0  msg=Traffic powinien być wyzerowany po resecie

TC_9 04
    [Documentation]  reset with multiple ue - verify all ue deleted after reset
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach UE To Network  ${UE_ID2}
    Attach UE To Network  ${UE_ID3}

    ${ue_count_before}=  Check Number Of Attached UEs Using /ues
    Log To Console    \nLiczba UE przed resetem: ${ue_count_before}
    Should Be Equal As Integers  ${ue_count_before}  3

    Reset Simulator
    
    ${ue_count_after}=  Check Number Of Attached UEs Using /ues
    Log To Console    \nLiczba UE po resecie: ${ue_count_after}
    Should Be Equal As Integers  ${ue_count_after}  0

TC_9 05
    [Documentation]  reset with multiple bearers - verify all bearers deleted after reset
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID2}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID3}

    ${bearer_count_before}=  Check Number Of Bearers For UE  ${UE_ID}
    Log To Console    \nLiczba bererów przed resetem: ${bearer_count_before}
    Should Be Equal As Integers  ${bearer_count_before}  4  msg=Default 9 + 3 added bearers

    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${bearer_count_after}=  Check Number Of Bearers For UE  ${UE_ID}
    Log To Console    \nLiczba bererów po resecie: ${bearer_count_after}
    Should Be Equal As Integers  ${bearer_count_after}  1  msg=Only default bearer 9 should remain

TC_9 06
    [Documentation]  reset with multiple active traffics - verify all traffics stopped
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID2}

    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID2}  30

    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID2}
    
    ${stats_bearer1}=  Get Traffic Stats  ${UE_ID}  ${BEARER_ID}
    ${stats_bearer2}=  Get Traffic Stats  ${UE_ID}  ${BEARER_ID2}
    Log To Console    \nTx bps bearer 1 po resecie: ${stats_bearer1}
    Log To Console    \nTx bps bearer 2 po resicie: ${stats_bearer2}
    
    Should Be Equal As Integers  ${stats_bearer1}  0  msg=Bearer 1 traffic powinien być zerowany
    Should Be Equal As Integers  ${stats_bearer2}  0  msg=Bearer 2 traffic powinien być zerowany

TC_9 07
    [Documentation]  attempt to interact with deleted ue after reset - should fail
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Reset Simulator
    
    ${response}=  Run Keyword And Expect Error  *  Get On Session  connectSession  /ues/${UE_ID}
    Log To Console    \nPróba dostępu do usuniętego UE zwróciła błąd (OK)

TC_9 08
    [Documentation]  attempt to interact with deleted bearer after reset - should fail
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${response}=  Run Keyword And Expect Error  *  GET On Session  connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}
    Log To Console    \nPróba dostępu do usuniętego bearera zwróciła błąd (OK)


TC_9 9
    [Documentation]  attempt to use deleted bearer with existing ue - should fail
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    # Bearer 1 nie istnieje dla tego UE, powinien zwrócić błąd
    ${response}=  Run Keyword And Expect Error  *  Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Log To Console    \nPróba uruchomienia trafficu na usuniętym bearerem zwróciła błąd (OK)

TC_9 10
    [Documentation]  attempt to use deleted ue and bearer after reset - should fail
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Reset Simulator
    
    # Stary UE i bearer nie istnieją
    ${response}=  Run Keyword And Expect Error  *  Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Log To Console    \nPróba dostępu do usuniętego UE i bearera zwróciła błąd (OK)

*** Keywords ***
Prepare Environment
    [Documentation]     Reset everything, just in case of an error
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        POST On Session     connectSession  /reset

Check number of Attached UEs Using /ues
    [Documentation]  Check and log number of Attached UE's to show number of UE's attached before and after   
    ${RESPONSE}=    GET On Session    connectSession    /ues
    ${ues_list}=    Set Variable    ${RESPONSE.json()}[ues]
    ${LIST_LENGTH}=    Get Length    ${ues_list}
    RETURN          ${LIST_LENGTH}

Check Number Of Bearers For UE
    [Documentation]   Check number of bearers for specific UE using /ues/{ue_id} endpoint
    [Arguments]    ${ue_id}
    Create Session      connectSession      ${BASE_URL}    disable_warnings=True

    ${response}=    GET On Session    connectSession    /ues/${ue_id}
    ${bearers_dict}=    Set Variable    ${response.json()}[bearers]
    ${bearer_count}=    Get Length    ${bearers_dict}
    
    RETURN          ${bearer_count}

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

Verify List Is Empty
    [Documentation]  Checks if list is empty meaning reset was succesfull
    [Arguments]      ${LIST_COUNT}
    Should Be Equal As Integers    ${LIST_COUNT}    0
