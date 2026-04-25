*** Settings ***
Documentation    
Resource         Resources/SetupTeardownWithArguments.resource
Library          Collections
Library          RequestsLibrary

Suite Setup      Prepare Environment

*** Variables ***
${BASE_URL}      http://localhost:8000
${UE_ID}         10
${UE_ID2}        11
${BEARER_ID}     1
${BEARER_ID2}    2
${BEARER_ID3}    3

*** Test Cases ***
TC_5 01_Stop Transfer On Active Bearer
    [Documentation]    Test if possible to stop active berer
    [Tags]             Positive_Test    Stop_Transfer
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    
    ${tx_before}=    Get Traffic Stats   ${UE_ID}    ${BEARER_ID}
    Log To Console    \nTx bps przed stopem: ${tx_before}
    Should Not Be Equal As Integers    ${tx_before}    0    msg=Przed stopem powinno być > 0
    
    Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}
    
    check if transfer is stopped    ${UE_ID}  ${BEARER_ID}

TC_5 02_Stop Transfer On Inactive Bearer
    [Documentation]    Test if possible to stop innactive berer
    [Tags]             Negative_Test    Stop_Transfer    
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    
    Run Keyword And Expect Error  *  Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}
      
TC_5 03_Stop Transfer On Non Existent Bearer
    [Documentation]    Test if possible to stop transfer on non existing bearer
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator
    
    Attach UE To Network  ${UE_ID}
    
    Run Keyword And Expect Error  *  Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}

TC_5 04_Stop Transfer On Non Existent UE
    [Documentation]    Test if possible to stop berer on non existing ue
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator
    
    Run Keyword And Expect Error  *  Stop Traffic On Bearer   ${999}  ${9}    

TC_5 05_Stop Transfer Twice
    [Documentation]    Test if possible to stop berer that has been stopped before
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50

    Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}
    
    Run Keyword And Expect Error  *  Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}

TC_5 06_Stop One Bearer Keep Other Active
    [Documentation]    checking if stoping one transfer does not stop others on the same berer
    [Tags]             Positive_Test    Stop_Transfer    
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID2}
    
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID2}  50
    
    Stop Traffic On Bearer   ${UE_ID}  ${BEARER_ID}
    
    Check if transfer is stopped    ${UE_ID}  ${BEARER_ID}
    Run Keyword And Expect Error  *  Check if transfer is stopped    ${UE_ID}  ${BEARER_ID2} 
    Reset Simulator

TC_5 07_Stop All Traffic For UE Optional Bearer ID
    [Documentation]    test if berer id is optional and allows to stop multiple bereres at once with the same ue_id
    [Tags]             Positive_Test    Stop_Transfer
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID}
    Attach Bearer To Network  ${UE_ID}  ${BEARER_ID2}
    
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID}  50
    Start Traffic On Bearer  ${UE_ID}  ${BEARER_ID2}  50

    ${response}=    DELETE On Session    my_session    /ues/${UE_ID}/traffic    
    

TC_5 08_Stop Transfer With Invalid Bearer ID Out Of Range
    [Documentation]    Test to check if berer out of range [1-9] will rerturn error
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    
    Run Keyword And Expect Error  *    Stop Traffic On Bearer   ${UE_ID}  10

TC_5 09_Stop Transfer With Negative Bearer ID
    [Documentation]    Test to check if possible to stop transfer on negative Berer ID
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    
    Run Keyword And Expect Error  *    Stop Traffic On Bearer   ${UE_ID}  -1

TC_5 10_Stop Transfer On Default Bearer 9
    [Documentation]    Veryfing if possible to stop transfer on default berer
    [Tags]             Positive_Test    Stop_Transfer    
    Reset Simulator

    Attach UE To Network  ${UE_ID}
    Start Traffic On Bearer  ${UE_ID}  ${9}  50
    
    Stop Traffic On Bearer   ${UE_ID}  ${9}
    
    Check if transfer is stopped    ${UE_ID}  ${9}

TC_5 11_Stop Transfer With Invalid UE ID Out Of Range
    [Documentation]    Test to check if UE_ID out of range  [1-100] will return error
    [Tags]             Negative_Test    Stop_Transfer
    Reset Simulator

    Run Keyword And Expect Error  *    Stop Traffic On Bearer   ${101}  ${9}

*** Keywords ***
Prepare Environment
    [Documentation]    Reset everything before suite
    Create Session    my_session    ${BASE_URL}
    POST On Session    my_session    /reset

Check if transfer is stopped
    [Documentation]    Keyword to check if transfer is stopped by verifying that tx_bps is not increasing after stop command
    [Arguments]    ${ue_id}  ${bearer_id}
    
    ${tx_before}=    Get Traffic Stats   ${ue_id}    ${bearer_id}
    Sleep  1s
    ${tx_after}=    Get Traffic Stats   ${ue_id}    ${bearer_id}
    Log To Console    \nTx bps: ${tx_after}

    Should Be Equal As Integers    ${tx_after}    ${tx_before}   msg=Po stopie powinny być równe
