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
TC 01 - TCP Transfer at Minimum Speed (1 bps)
    [Documentation]     Verify that data transfer succeeds over TCP with the minimum valid connection speed (1 bps) for a registered UE (ID=7) and Bearer (ID=3).
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer

TC 02 - TCP Transfer at Low Speed (1 kbps)
    [Documentation]     Verify that data transfer succeeds over TCP with low connection speed (1 kbps).
    Set Transter Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer

TC 03 - TCP Transfer at Medium Speed (1 Mbps)
    [Documentation]     Verify that data transfer succeeds over TCP with medium connection speed (1 Mbps).
    Set Transter Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer

TC 04 - TCP Transfer at High Speed (50 Mbps)
    [Documentation]     Verify that data transfer succeeds over TCP with high connection speed (50 Mbps).
    Set Transter Speed To 50 Mbps
    Set TCP Protocol
    Verify Transfer

TC 05 - TCP Transfer at Near-Max Speed (99 Mbps)
    [Documentation]     Verify that data transfer succeeds over TCP near the upper boundary (99 Mbps).
    Set Transter Speed To 99 Mbps
    Set TCP Protocol
    Verify Transfer

TC 06 - TCP Transfer at Max Allowed Speed (100 Mbps)
    [Documentation]     Verify that data transfer succeeds over TCP at the maximum allowed speed (100 Mbps).
    Set Transter Speed To 100 Mbps
    Set TCP Protocol
    Verify Transfer

TC 07 - TCP Transfer Above Max Speed (Invalid)
    [Documentation]     Verify that data transfer fails when connection speed exceeds allowed limit (101 Mbps). Expect HTTP 422 error.
    Set Transter Speed To 101 Mbps
    Set TCP Protocol
    Verify Transfer Expected 422 Error

TC 08 - UDP Transfer at Minimum Speed (1 bps)
    [Documentation]     Verify that data transfer succeeds over UDP with the minimum valid speed.
    Set Transter Speed To 1 bps
    Set UDP Protocol
    Verify Transfer

TC 09 - UDP Transfer at Low Speed (1 kbps)
    [Documentation]     Verify that data transfer succeeds over UDP with low speed.
    Set Transter Speed To 1 kbps
    Set UDP Protocol
    Verify Transfer

TC 10 - UDP Transfer at Medium Speed (1 Mbps)
    [Documentation]     Verify that data transfer succeeds over UDP with medium speed.
    Set Transter Speed To 1 Mbps
    Set UDP Protocol
    Verify Transfer

TC 11 - UDP Transfer at High Speed (50 Mbps)
    [Documentation]     Verify that data transfer succeeds over UDP with high speed.
    Set Transter Speed To 50 Mbps
    Set UDP Protocol
    Verify Transfer

TC 12 - UDP Transfer at Near-Max Speed (99 Mbps)
    [Documentation]     Verify that data transfer succeeds over UDP near upper boundary.
    Set Transter Speed To 99 Mbps
    Set UDP Protocol
    Verify Transfer

TC 13 - UDP Transfer at Max Allowed Speed (100 Mbps)
    [Documentation]     Verify that data transfer succeeds over UDP at maximum allowed speed.
    Set Transter Speed To 100 Mbps
    Set UDP Protocol
    Verify Transfer

TC 14 - UDP Transfer Above Max Speed (Invalid)
    [Documentation]     Verify that data transfer fails for UDP when speed exceeds 100 Mbps. Expect HTTP 422 error.
    Set Transter Speed To 101 Mbps
    Set UDP Protocol
    Verify Transfer Expected 422 Error

TC 15 - Invalid Protocol QUIC at 1 bps
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transter Speed To 1 bps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

TC 16 - Invalid Protocol QUIC at 1 kbps
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transter Speed To 1 kbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

TC 17 - Invalid Protocol QUIC at 1 Mbps
    [Documentation]     Verify that data transfer fails when using unsupported protocol (QUIC). Expect HTTP 422 error.
    Set Transter Speed To 1 Mbps
    Set QUIC Protocol
    Verify Transfer Expected 422 Error

TC 18 - Missing Bearer (1 bps)
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

TC 19 - Missing Bearer (1 kbps)
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transter Speed To 1 kbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

TC 20 - Missing Bearer (1 Mbps)
    [Documentation]     Verify that data transfer fails when Bearer ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without Bearer
    Set Transter Speed To 1 Mbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without Bearer

TC 21 - Missing UE
    [Documentation]     Verify that data transfer fails when UE ID is not registered. Expect HTTP 400 error.
    [Setup]             Prepare Test Environment Without UE
    Set Transter Speed To 1 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error
    [Teardown]          Clean Test Environment Without UE

TC 22 - Transfer bellow Minimum Speed (0 bps)
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 bps). Expect HTTP 400 error.
    Set Transter Speed To 0 bps
    Set TCP Protocol
    Verify Transfer Expected 400 Error

TC 23 - Transfer bellow Minimum Speed (0 kbps)
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 bps). Expect HTTP 400 error.
    Set Transter Speed To 0 kbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error

TC 24 - Transfer bellow Minimum Speed (0 Mbps)
    [Documentation]     Verify that data transfer fails when connection speed is below the minimum allowed value (0 bps). Expect HTTP 400 error.
    Set Transter Speed To 0 Mbps
    Set TCP Protocol
    Verify Transfer Expected 400 Error


*** Keywords ***
Clean Environment
    [Documentation]     Reset everything, just in case of an error
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        POST On Session     connectSession  /reset
