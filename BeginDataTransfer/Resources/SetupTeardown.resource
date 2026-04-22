*** Settings ***
Documentation   This resource has all the needed keywords concerning set ups and tear downs.
Library         RequestsLibrary


*** Variables ***
${BASE_URL}     http://localhost:8000
${UE_ID}        7
${BEARER_ID}    3


*** Keywords ***
# Here we have out set ups and tear downs.
Prepare Test Environment
    [Documentation]     Here we will Attach the UE and Attach the Bearer.
    Attach UE7 To Network
    Attach Bearer3 To UE7

Clean Test Environment
    [Documentation]     Here we will Detach the UE and Detach the Bearer.
    Detach Bearer3 From UE7
    Detach UE7 From Network

Prepare Test Environment Without Bearer
    [Documentation]     Here we will Attach the UE without Attaching the Bearer.
    Attach UE7 To Network

Clean Test Environment Without Bearer
    [Documentation]     Here we will Attach the UE without Detaching the Bearer.
    Detach UE7 From Network

# Here we have the Key Words that will be treated as functions.
Attach UE${UeId} To Network
    [Documentation]     Attach UE with id UeId to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${RESPONSE}=        POST On Session     connectSession  /ues  json=${BODY}

    Set Test Variable   ${UE_ID}            ${UeId}

    RETURN              ${RESPONSE}

Detach UE${UeId} From Network
    [Documentation]     Detach UE with id UeId from the network.
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession  /ues/${UeId}

    RETURN              ${RESPONSE}

Attach Bearer${BearerId} To UE${UeId}
    [Documentation]     Attach Bearer with BearerId to UE with UeId.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   bearer_id=${BearerId}
    ${RESPONSE}=        POST On Session     connectSession   /ues/${UeId}/bearers  json=${BODY}

    Set Test Variable   ${BEARER_ID}        ${BearerId}

    RETURN              ${RESPONSE}

Detach Bearer${BearerId} From UE${UeId}
    [Documentation]     Detach Bearer with BearerId from UE with UeId
    Create Session      connectSession      ${BASE_URL}

    ${RESPONSE}=        DELETE On Session   connectSession   /ues/${UeId}/bearers/${BearerId}

    RETURN              ${RESPONSE}
