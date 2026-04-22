# ACK - Acceptance Criteria
*** Settings ***
Documentation    Test suite covering adding a new bearer for a UE
Library          RequestsLibrary
Resource         bearerTestsResources.resource

Test Setup  Attach UE3 To Network
Test Teardown  Detach UE3 From Network



*** Test Cases ***
TC 1 Add New Bearer to UE
    [Documentation]  Verifies adding a new bearer for a UE
    Attach Bearer1 To UE3
    Verify If Response Is OK
    Detach Bearer1 From UE3

TC 2 Add Bearer Outside Valid Range
    [Documentation]    Attempts to attach bearers with IDs outside valid range of 1-9
    # test high
    Attach Bearer10 To UE3
    Verify If Response Is Validation Error
    Verify If Response Message Is Input should be less than or equal to 9

    # test low
    Attach Bearer0 To UE3
    Verify If Response Is Validation Error
    Verify If Response Message Is Input should be greater than or equal to 1

TC 3 Add Already Attached Bearer
    [Documentation]    Attempts to attach same bearer twice
    Attach Bearer1 To UE3
    Attach Bearer1 To UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is Bearer already exists
    Detach Bearer1 From UE3

TC 4 Add Default Bearer
    [Documentation]   Attempts to add default bearer (ID = 9) which always exists
    Attach Bearer9 To UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is Bearer already exists



