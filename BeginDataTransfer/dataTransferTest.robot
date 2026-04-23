*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Resource        Resources/SetupTeardown.resource
Resource        Resources/TransferConfiguration.resource
Resource        Resources/TransferVerification.resource
Test Setup      Prepare Test Environment
Test Teardown   Clean Test Environment

Suite Setup     Clean Environment
Suite Teardown  Clean Environment


*** Test Cases ***
TC 01
    [Documentation]     Test One!
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer

TC 02
    [Documentation]     Test Two!
    Set Transter Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer

TC 03
    [Documentation]     Test Two!
    Set Transter Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer

TC 04
    [Documentation]     Test Two!
    Set Transter Speed To 50 Mbps
    Set TCP Protocol
    Verify Transfer

TC 05
    [Documentation]     Test Two!
    Set Transter Speed To 99 Mbps
    Set TCP Protocol
    Verify Transfer

TC 06
    [Documentation]     Test Two!
    Set Transter Speed To 100 Mbps
    Set TCP Protocol
    Verify Transfer

TC 07
    [Documentation]     Test Two!
    Set Transter Speed To 101 Mbps
    Set TCP Protocol
    Verify Transfer Expected 422 Error

TC 08
    [Documentation]     Test One!
    Set Transter Speed To 1 bps
    Set UDP Protocol
    Verify Transfer

TC 09
    [Documentation]     Test Two!
    Set Transter Speed To 1 kbps
    Set UDP Protocol
    Verify Transfer

TC 10
    [Documentation]     Test Two!
    Set Transter Speed To 1 Mbps
    Set UDP Protocol
    Verify Transfer

TC 11
    [Documentation]     Test Two!
    Set Transter Speed To 50 Mbps
    Set UDP Protocol
    Verify Transfer

TC 12
    [Documentation]     Test Two!
    Set Transter Speed To 99 Mbps
    Set UDP Protocol
    Verify Transfer

TC 13
    [Documentation]     Test Two!
    Set Transter Speed To 100 Mbps
    Set UDP Protocol
    Verify Transfer

TC 14
    [Documentation]     Test Two!
    Set Transter Speed To 101 Mbps
    Set UDP Protocol
    Verify Transfer Expected 422 Error

TC 15
    [Documentation]     Test Two!
    Set Transter Speed To 1 bps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

TC 16
    [Documentation]     Test Two!
    Set Transter Speed To 1 kbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

TC 17
    [Documentation]     Test Two!
    Set Transter Speed To 1 Mbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error


*** Keywords ***
Clean Environment
    [Documentation]     Reset everything, just in case of an error
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        POST On Session     connectSession  /reset

    # TC 08
    #     [Documentation]     Test Two!
    #     
    #     Set Transter Speed To 120 Mbps
    #     Set TCP Protocol
    #     Verify Transfer
    #     
    #
    # TC 09
    #     [Documentation]     Test Two!
    #     
    #     Set Transter Speed To 220 Mbps
    #     Set TCP Protocol
    #     Verify Transfer
    #     
