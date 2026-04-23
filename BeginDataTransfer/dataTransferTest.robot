*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Resource        Resources/SetupTeardown.resource
Resource        Resources/TransferConfiguration.resource
Resource        Resources/TransferVerification.resource
# Test Setup      Prepare Test Environment
# Test Teardown   Clean Test Environment
Suite Setup     Clean Environment
Suite Teardown  Clean Environment


*** Test Cases ***
TC 1
    [Documentation]     Test One!
    Prepare Test Environment
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 2
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 3
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 4
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 50 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 5
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 99 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 6
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 100 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 7
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 101 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 8
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 120 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment

TC 9
    [Documentation]     Test Two!
    Prepare Test Environment
    Set Transter Speed To 220 Mbps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment


*** Keywords ***
Clean Environment
    [Documentation]     Reset everything, just in case of an error
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        POST On Session     connectSession  /reset
