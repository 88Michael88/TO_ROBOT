
*** Variables ***
${BASE_URL}      http://localhost:8000
&{STATUS_NAMES}  OK=200     Bad Request=400     Validation Error=422
&{RESPONSE_NAMES_MAP}  Details=detail  Message=msg  Status=status

*** Keywords ***
Attach UE${UeId} To Network
    [Documentation]     Attach UE with id UeId to the network.
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   ue_id=${UeId}
    ${Response}=        POST On Session     connectSession  /ues  json=${BODY}

    Set Test Variable   ${UE_ID}            ${UeId}

    RETURN              ${Response}

Detach UE${UeId} From Network
    [Documentation]     Detach UE with id UeId from the network.
    Create Session      connectSession      ${BASE_URL}

    ${Response}=        DELETE On Session   connectSession  /ues/${UeId}

    RETURN              ${Response}

Attach Bearer${BearerId} To UE${UeId}
    [Documentation]     Attach Bearer with BearerId to UE with UeId.
    # [Arguments]         ${ExpectedStatus}= 200
    Create Session      connectSession      ${BASE_URL}

    ${BODY}=            Create Dictionary   bearer_id=${BearerId}
    ${Response}=        POST On Session     connectSession   /ues/${UeId}/bearers  json=${BODY}     expected_status=Anything

    Set Test Variable   ${BEARER_ID}        ${BearerId}
    Set Test Variable   ${RESPONSE}         ${Response}

    RETURN              ${Response}

Detach Bearer${BearerId} From UE${UeId}
    [Documentation]     Detach Bearer with BearerId from UE with UeId
    Create Session      connectSession      ${BASE_URL}

    ${Response}=        DELETE On Session   connectSession   /ues/${UeId}/bearers/${BearerId}  expected_status=Anything

    Set Test Variable   ${RESPONSE}         ${Response}

    RETURN              ${Response}

# Start ${Protocol} Traffic For UE${UeId} On Bearer${BearerId}
#     Create Session      connectSession      ${BASE_URL}
#
#     ${BODY}=            Create Dictionary   protocol=${Protocol}
#     ${Response}=        POST On Session     connectSession   /ues/${UeId}/bearers  json=${BODY}     expected_status=Anything
#
#     Set Test Variable   ${BEARER_ID}        ${BearerId}
#     Set Test Variable   ${RESPONSE}         ${Response}
#
#     RETURN              ${Response}

Verify If Response Is ${StatusName}
    Status Should Be    ${STATUS_NAMES}[${StatusName}]

Verify If Response ${ArgName} Is "${ArgValue}"
    VAR  ${ArgName}  ${RESPONSE_NAMES_MAP}[${ArgName}]
    VAR  ${Response}  ${RESPONSE.json()}
    IF  "${ArgName}" == "msg"
        Log To Console      ${Response}[detail][0][${ArgName}]
        Should Be Equal     ${Response}[detail][0][${ArgName}]   ${ArgValue}    ignore_case=True
    ELSE
        Log To Console      ${Response}
        Should Be Equal     ${Response}[${ArgName}]  ${ArgValue}    ignore_case=True
    END


Get Info For UE${UeId}
    Create Session      connectSession      ${BASE_URL}
    ${Response}=        GET On Session     connectSession   /ues/${UeId}     expected_status=Anything
    Set Test Variable   ${RESPONSE}         ${Response}

    RETURN              ${Response}

Verify If Response Is Exactly Bearers
    [Arguments]  @{BearersIdList}
    VAR  ${Response}  ${RESPONSE.json()}
    Log To Console  ${Response}
    Log To Console  ${BearersIdList}

    ${BearersIdListLength}=  Get Length  ${BearersIdList}
    Length Should Be  ${Response}[bearers]  ${BearersIdListLength}

    FOR  ${Bearer}  IN  &{Response}[bearers]
        Should Contain  ${BearersIdList}  ${Bearer}[0]
    END

