# ACK - Acceptance Criteria
*** Settings ***
Documentation    This is a simple file where we try to understand robot.
Library          RequestsLibrary
Resource         bearerTestsResources.resource

*** Test Cases ***
TC 1 Remove bearer
    [Documentation]    Tests removing a valid bearer
    [Setup]    Run Keywords  Attach UE3 To Network
    ...    Attach Bearer7 To UE3

    Detach Bearer7 From UE3
    Verify If Response Is OK
    Verify If Response Status Is "bearer_deleted"   # weird formatted message

    [Teardown]    Detach UE3 From Network

TC 2 Remove bearer outside range
    [Documentation]    Tests removing a bearer with ID outside of valid range
    [Setup]    Attach UE3 To Network
    Detach Bearer10 From UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is "Bearer not found"    # wrong error message?
    [Teardown]    Detach UE3 From Network

TC 3 Remove nonexistent bearer
    [Documentation]    Tests removing a bearer that does not exist
    [Setup]    Attach UE3 To Network
    Detach Bearer7 From UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is "Bearer not found"
    [Teardown]    Detach UE3 From Network

TC 4 Remove for nonexistent UE
    [Documentation]    Tests removing a bearer on UE which does not exist
    Detach Bearer7 From UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is "UE not found"

TC 5 Remove default bearer
    [Documentation]    Tests attempting to remove the default bearer
    [Setup]    Attach UE3 To Network

    Detach Bearer9 From UE3
    Verify If Response Is Bad Request
    Verify If Response Details Is "Cannot remove default bearer"

    [Teardown]    Detach UE3 From Network
