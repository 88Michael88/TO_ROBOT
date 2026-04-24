# ACK - Acceptance Criteria
*** Settings ***
Documentation    Test suite covering checking available bearers for a given UE
Library          RequestsLibrary
Resource         bearerTestsResources.resource

Test Setup  Attach UE3 To Network
Test Teardown  Detach UE3 From Network

*** Test Cases ***
TC 1 Check bearers listing
    [Documentation]    Checks if listing bearers works properly
    Attach Bearer4 To UE3
    Get Info For UE3
    Verify If Response Is OK
    Verify If Response Is Exactly Bearers  4  9
    Detach Bearer4 From UE3
