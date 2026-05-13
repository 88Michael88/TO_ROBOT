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
FN 3-4 TC 01 - TCP Transfer at Minimum Speed
    [Documentation]     Verify that data transfer succeeds over TCP with the minimum valid connection speed (1 bps) for a registered UE (ID=7) and Bearer (ID=3).
    Set Transfer Speed To 1 bps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 02 - TCP Transfer at Low Speed
    [Documentation]     Verify that data transfer succeeds over TCP with low connection speed (1 kbps).
    Set Transfer Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 03 - TCP Transfer at Medium Speed
    [Documentation]     Verify that data transfer succeeds over TCP with medium connection speed (1 Mbps).
    Set Transfer Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 04 - TCP Transfer at High Speed
    [Documentation]     Verify that data transfer succeeds over TCP with high connection speed (50 Mbps).
    Set Transfer Speed To 50 Mbps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 05 - TCP Transfer at Near-Max Speed
    [Documentation]     Verify that data transfer succeeds over TCP near the upper boundary (99 Mbps).
    Set Transfer Speed To 99 Mbps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 06 - TCP Transfer at Max Speed
    [Documentation]     Verify that data transfer succeeds over TCP at the maximum allowed speed (100 Mbps).
    Set Transfer Speed To 100 Mbps
    Set TCP Protocol
    Verify Transfer

FN 3-4 TC 07 - TCP Transfer Above Max Speed
    [Documentation]     Verify that data transfer fails when connection speed exceeds allowed limit (101 Mbps). Expect HTTP 422 error.
    Set Transfer Speed To 101 Mbps
    Set TCP Protocol
    Verify Transfer Expected 422 Error

FN 3-4 TC 08 - UDP Transfer at Minimum Speed
    [Documentation]     Verify that data transfer succeeds over UDP with the minimum valid speed.
    Set Transfer Speed To 1 bps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 09 - UDP Transfer at Low Speed
    [Documentation]     Verify that data transfer succeeds over UDP with low speed.
    Set Transfer Speed To 1 kbps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 10 - UDP Transfer at Medium Speed
    [Documentation]     Verify that data transfer succeeds over UDP with medium speed.
    Set Transfer Speed To 1 Mbps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 11 - UDP Transfer at High Speed
    [Documentation]     Verify that data transfer succeeds over UDP with high speed.
    Set Transfer Speed To 50 Mbps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 12 - UDP Transfer at Near-Max Speed
    [Documentation]     Verify that data transfer succeeds over UDP near upper boundary.
    Set Transfer Speed To 99 Mbps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 13 - UDP Transfer at Max Speed
    [Documentation]     Verify that data transfer succeeds over UDP at maximum allowed speed.
    Set Transfer Speed To 100 Mbps
    Set UDP Protocol
    Verify Transfer

FN 3-4 TC 14 - UDP Transfer Above Max Speed
    [Documentation]     Verify that data transfer fails for UDP when speed exceeds 100 Mbps. Expect HTTP 422 error.
    Set Transfer Speed To 101 Mbps
    Set UDP Protocol
    Verify Transfer Expected 422 Error

FN 3-4 TC 15 - Invalid Protocol QUIC at Minimum Speed
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transfer Speed To 1 bps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

FN 3-4 TC 16 - Invalid Protocol QUIC at Low Speed
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transfer Speed To 1 kbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

FN 3-4 TC 17 - Invalid Protocol QUIC at High Speed
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transfer Speed To 1 Mbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

FN 3-4 TC 18 - Missing Bearer at Low Minimum Speed
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transfer Speed To 1 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

FN 3-4 TC 19 - Missing Bearer at Low Speed
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transfer Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

FN 3-4 TC 20 - Missing Bearer at High Speed
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transfer Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

FN 3-4 TC 21 - Missing UE
    [Documentation]     Verify that data transfer fails when UE ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without UE
    Set Transfer Speed To 1 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without UE

FN 3-4 TC 22 - Transfer below Minimum Speed 
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 bps). Expect HTTP 400 error.
    Set Transfer Speed To 0 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error

FN 3-4 TC 23 - Transfer below Minimum Speed
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 kbps). Expect HTTP 400 error.
    Set Transfer Speed To 0 kbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error

FN 3-4 TC 24 - Transfer below Minimum Speed
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 Mbps). Expect HTTP 400 error.
    Set Transfer Speed To 0 Mbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error


*** Keywords ***
Clean Environment
    [Documentation]     Reset everything, just in case of an error
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        POST On Session     connectSession  /reset
