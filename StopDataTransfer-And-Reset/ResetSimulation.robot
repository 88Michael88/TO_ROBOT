*** Settings ***
Documentation   
Resource        Resources/SetupTeardownWithArguments.resource
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
    [Tags]             Positive_Test    ResetTest
    Reset Simulator
    Attach UE To Network  ${UE_ID}

    ${ue_count}=  Check number of Attached UEs Using /ues
    Log To Console    \nLiczba urządzeń w ues przed resetem: ${ue_count}

    Reset Simulator
    
    ${ue_count}=  Check number of Attached UEs Using /ues
    Log To Console    \nLiczba urządzeń w ues po resecie: ${ue_count}

    Verify List Is Empty  ${ue_count}

    
TC_9 02
    [Documentation]  Verify bearer is deleted after reset
    [Tags]             Positive_Test    ResetTest
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
    [Documentation]    Verify single active traffic is stopped after reset
    [Tags]             Positive_Test    ResetTest
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
    [Documentation]  Verify all ue deleted after reset
    [Tags]           Positive_Test    ResetTest
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
    [Documentation]  Verify all bearers deleted after reset
    [Tags]           Positive_Test    ResetTest
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
    [Documentation]   verify all traffics are stopped in case of multiple
    [Tags]           Positive_Test    ResetTest
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
    [Documentation]  attempt to interact with deleted ue after reset 
    [Tags]           Negative_Test    ResetTest
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Reset Simulator
    
    ${response}=  Run Keyword And Expect Error  *  Get On Session  connectSession  /ues/${UE_ID}
    Log To Console    \nPróba dostępu do usuniętego UE zwróciła błąd (OK)

TC_9 08
    [Documentation]  attempt to interact with deleted bearer after reset
    [Tags]           Negative_Test    ResetTest
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${response}=  Run Keyword And Expect Error  *  GET On Session  connectSession  /ues/${UE_ID}/bearers/${BEARER_ID}
    Log To Console    \nPróba dostępu do usuniętego bearera zwróciła błąd (OK)


TC_9 9
    [Documentation]  attempt to use deleted bearer with existing ue
    [Tags]           Negative_Test    ResetTest
    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${response}=  Run Keyword And Expect Error  *  Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Log To Console    \nPróba uruchomienia trafficu na usuniętym bearerem zwróciła błąd (OK)

TC_9 10
    [Documentation]  checks if default bearer 9 transfer value is reseted
    [Tags]             Positive_Test    ResetTest

    Reset Simulator
    Attach UE To Network  ${UE_ID}
    Start Traffic On Bearer  ${UE_ID}  ${9}  50
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    ${response}=    Get Traffic Stats  ${UE_ID}  ${9}
    Should Be Equal As Integers    ${response}  0   

    Log To Console    \n Default bearer traffic is reseted and equal 0

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


Verify List Is Empty
    [Documentation]  Checks if list is empty meaning reset was succesfull
    [Arguments]      ${LIST_COUNT}
    Should Be Equal As Integers    ${LIST_COUNT}    0