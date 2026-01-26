#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"
#INCLUDE "TOTVS.ch"

/* ===============================================================================
WSDL Location    http://localhost:8480/TSSWSCONSIGNADO.apw?WSDL
=============================================================================== */

User Function WSTAFCONSIGNADO; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service TSSWSCONSIGNADO
------------------------------------------------------------------------------- */

WSCLIENT TSSWSCONSIGNADO

    WSMETHOD NEW
    WSMETHOD INIT
    WSMETHOD RESET
    WSMETHOD CLONE

    WSMETHOD CONSULTARCONSIGNACOES

    WSDATA   _URL                AS String
    WSDATA   _HEADOUT            AS Array of String
    WSDATA   _COOKIES            AS Array of String

    WSDATA   oWSCONSULTADOC      AS TSSWSCONSIGNADO_CONSULTADOC
    WSDATA   oWSRETORNODOC       AS TSSWSCONSIGNADO_RETORNODOC

    WSDATA   cBearerToken        AS String

ENDWSCLIENT

WSMETHOD NEW WSSEND cBearerToken WSCLIENT TSSWSCONSIGNADO
    Default cBearerToken := ""
    ::Init()
    ::cBearerToken := cBearerToken
Return Self

WSMETHOD INIT WSCLIENT TSSWSCONSIGNADO
    ::oWSCONSULTADOC  := TSSWSCONSIGNADO_CONSULTADOC():New()
    ::oWSRETORNODOC   := TSSWSCONSIGNADO_RETORNODOC():New()
Return

WSMETHOD RESET WSCLIENT TSSWSCONSIGNADO
    ::oWSCONSULTADOC := Nil
    ::oWSRETORNODOC  := Nil
    ::Init()
Return

WSMETHOD CLONE WSCLIENT TSSWSCONSIGNADO
    Local oClone := TSSWSCONSIGNADO():New()
    oClone:_URL              := ::_URL
    oClone:oWSCONSULTADOC    := IIF(::oWSCONSULTADOC = Nil, Nil, ::oWSCONSULTADOC:Clone())
    oClone:oWSRETORNODOC     := IIF(::oWSRETORNODOC = Nil, Nil, ::oWSRETORNODOC:Clone())
Return oClone

// WSDL Method CONSULTARCONSIGNACOES
WSMETHOD CONSULTARCONSIGNACOES WSSEND oWSCONSULTADOC WSRECEIVE oWSRETORNODOC WSCLIENT TSSWSCONSIGNADO
    Local cSoap := "" , oXmlRet

    BEGIN WSMETHOD

    cSoap += '<CONSULTARCONSIGNACOES xmlns="http://webservices.totvs.com.br/TSSWSCONSIGNADO.apw">'
    cSoap += WSSoapValue("CONSULTADOC", ::oWSCONSULTADOC, oWSCONSULTADOC , "CONSULTADOC", .T., .F., 0 , NIL, .F., .F.)
    cSoap += "</CONSULTARCONSIGNACOES>"

    oXmlRet := SvcSoapCall(TafSetTssHeader(Self,::cBearerToken), cSoap,;
        "http://webservices.totvs.com.br/TSSWSCONSIGNADO.apw/CONSULTARCONSIGNACOES",;
        "DOCUMENT","http://webservices.totvs.com.br/TSSWSCONSIGNADO.apw",,"1.110216",;
        "http://localhost:8480/TSSWSCONSIGNADO.apw")

    ::Init()
    ::oWSRETORNODOC:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARCONSIGNACOESRESPONSE:_CONSULTARCONSIGNACOESRESULT","RETORNODOC",NIL,NIL,NIL,NIL,NIL,NIL) )

    END WSMETHOD

    oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Data Structure CONSULTADOC
------------------------------------------------------------------------------- */

WSSTRUCT TSSWSCONSIGNADO_CONSULTADOC
    WSDATA   cAMBIENTE       AS string
    WSDATA   cCOMPETENCIA    AS string
    WSDATA   cENTIDADE       AS string
    WSDATA   lFORCEREQUEST   AS boolean
    WSDATA   cUSERTOKEN      AS string
    WSMETHOD NEW
    WSMETHOD INIT
    WSMETHOD CLONE
    WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSCONSIGNADO_CONSULTADOC
    ::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSCONSIGNADO_CONSULTADOC
Return

WSMETHOD CLONE WSCLIENT TSSWSCONSIGNADO_CONSULTADOC
    Local oClone := TSSWSCONSIGNADO_CONSULTADOC():NEW()
    oClone:cAMBIENTE     := ::cAMBIENTE
    oClone:cCOMPETENCIA  := ::cCOMPETENCIA
    oClone:cENTIDADE     := ::cENTIDADE
    oClone:lFORCEREQUEST := ::lFORCEREQUEST
    oClone:cUSERTOKEN    := ::cUSERTOKEN
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSCONSIGNADO_CONSULTADOC
    Local cSoap := ""
    cSoap += WSSoapValue("AMBIENTE",    ::cAMBIENTE,    ::cAMBIENTE,    "string",  .T., .F., 0, NIL, .F., .F.)
    cSoap += WSSoapValue("COMPETENCIA", ::cCOMPETENCIA, ::cCOMPETENCIA, "string",  .T., .F., 0, NIL, .F., .F.)
    cSoap += WSSoapValue("ENTIDADE",    ::cENTIDADE,    ::cENTIDADE,    "string",  .T., .F., 0, NIL, .F., .F.)
    cSoap += WSSoapValue("FORCEREQUEST",::lFORCEREQUEST,::lFORCEREQUEST,"boolean", .T., .F., 0, NIL, .F., .F.)
    cSoap += WSSoapValue("USERTOKEN",   ::cUSERTOKEN,   ::cUSERTOKEN,   "string",  .T., .F., 0, NIL, .F., .F.)
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure RETORNODOC
------------------------------------------------------------------------------- */

WSSTRUCT TSSWSCONSIGNADO_RETORNODOC
    WSDATA   cAMBIENTE        AS string
    WSDATA   cARQUIVO         AS base64Binary
    WSDATA   cCODREQUISICAO   AS string
    WSDATA   cCOMPETENCIA     AS string
    WSDATA   cDESCRERRO       AS string
    WSDATA   dDTSOLICITACAO   AS date
    WSDATA   cENTIDADE        AS string
    WSDATA   cHRSOLICITACAO   AS string
    WSDATA   cID              AS string
    WSDATA   cSTATUS          AS string
    WSMETHOD NEW
    WSMETHOD INIT
    WSMETHOD CLONE
    WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSCONSIGNADO_RETORNODOC
    ::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSCONSIGNADO_RETORNODOC
Return

WSMETHOD CLONE WSCLIENT TSSWSCONSIGNADO_RETORNODOC
    Local oClone := TSSWSCONSIGNADO_RETORNODOC():NEW()
    oClone:cAMBIENTE       := ::cAMBIENTE
    oClone:cARQUIVO        := ::cARQUIVO
    oClone:cCODREQUISICAO  := ::cCODREQUISICAO
    oClone:cCOMPETENCIA    := ::cCOMPETENCIA
    oClone:cDESCRERRO      := ::cDESCRERRO
    oClone:dDTSOLICITACAO  := ::dDTSOLICITACAO
    oClone:cENTIDADE       := ::cENTIDADE
    oClone:cHRSOLICITACAO  := ::cHRSOLICITACAO
    oClone:cID             := ::cID
    oClone:cSTATUS         := ::cSTATUS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSCONSIGNADO_RETORNODOC
    Local cBase64 := ""
    ::Init()
    If oResponse = NIL ; Return ; Endif

    ::cAMBIENTE       := WSAdvValue(oResponse,"_AMBIENTE","string",NIL,NIL,NIL,"S",NIL,NIL)
     If Type("oResponse:_ARQUIVO:text") == "U" .AND. !Empty(oResponse:_ARQUIVO:text)
        GzStrDecomp(Decode64(oResponse:_ARQUIVO:text), Len(Decode64(oResponse:_ARQUIVO:text)), @cBase64)
        ::cARQUIVO := cBase64
    EndIf
    ::cCODREQUISICAO  := WSAdvValue(oResponse,"_CODREQUISICAO","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::cCOMPETENCIA    := WSAdvValue(oResponse,"_COMPETENCIA","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::cDESCRERRO      := WSAdvValue(oResponse,"_DESCRERRO","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::dDTSOLICITACAO  := WSAdvValue(oResponse,"_DTSOLICITACAO","date",NIL,NIL,NIL,"D",NIL,NIL)
    ::cENTIDADE       := WSAdvValue(oResponse,"_ENTIDADE","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::cHRSOLICITACAO  := WSAdvValue(oResponse,"_HRSOLICITACAO","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::cID             := WSAdvValue(oResponse,"_ID","string",NIL,NIL,NIL,"S",NIL,NIL)
    ::cSTATUS         := WSAdvValue(oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL)
Return
