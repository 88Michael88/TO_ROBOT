*** Settings ***
Documentation   This test suite will test data transfer sent from UE to DL.
Resource        Resources/SetupTeardown.resource
Resource        Resources/TransferConfiguration.resource
Resource        Resources/TransferVerification.resource
# Test Setup      Prepare Test Environment
# Test Teardown   Clean Test Environment


*** Test Cases ***
TC 1
    [Documentation]     Test One!
    Prepare Test Environment
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer
    Clean Test Environment
