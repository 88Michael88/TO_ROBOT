*** Settings ***
Documentation   This test suite verifies the UE attach procedure (Functionality 1).
Resource        Resources/AttachConfiguration.resource
Resource        Resources/SetupTeardown.resource
Resource        Resources/AttachVerification.resource

Suite Setup     Clean Environment
Suite Teardown  Clean Environment
Test Setup      Clean Environment


*** Test Cases ***
FN 1 TC 01 - Successful Attach With Valid UE ID
    [Documentation]     Verify that a UE with a valid ID attaches successfully and response contains status and ue_id.
    Verify Attach UE42 To Network

FN 1 TC 02 - Default Bearer ID 9 Assigned After Attach
    [Documentation]     Verify that bearer ID 9 is automatically created after attach.
    Attach UE42 To Network
    Verify Default Bearer Assigned To UE42

FN 1 TC 03 - Attach UE With Minimum Valid ID = 0
    [Documentation]     Verify that UE ID = 0 is accepted as a valid value (boundary).
    Verify Attach UE0 To Network

FN 1 TC 04 - Attach UE With Maximum Valid ID = 100
    [Documentation]     Verify that UE ID = 100 is accepted as a valid value (boundary).
    Verify Attach UE100 To Network

FN 1 TC 05 - Two Different UEs Can Be Attached Simultaneously
    [Documentation]     Verify that UE ID 10 and UE ID 20 can both be attached and appear in GET /ues.
    Attach UE10 To Network
    Attach UE20 To Network
    Verify UE10 Present In List
    Verify UE20 Present In List

FN 1 TC 06 - Attach Fails For UE ID Above Range
    [Documentation]     Verify that UE ID = 101 is rejected (boundary above max).
    [Setup]             Prepare Empty Test Environment
    [Teardown]          Clean Empty Test Environment
    Verify Attach UE101 To Network Expected 422 Error

FN 1 TC 07 - Attach Fails For Negative UE ID
    [Documentation]     Verify that a negative UE ID is rejected.
    [Setup]             Prepare Empty Test Environment
    [Teardown]          Clean Empty Test Environment
    Verify Attach UE-1 To Network Expected 422 Error

FN 1 TC 08 - Attach Fails When UE Already Attached
    [Documentation]     Verify that attaching an already attached UE returns an error.
    Attach UE42 To Network
    Verify Attach UE42 To Network Expected 400 Error
