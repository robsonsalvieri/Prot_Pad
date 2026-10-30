#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/LJWINTEGRACAO.apw?WSDL
Gerado em        09/13/21 18:46:14
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KHSIYQK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJWINTEGRACAO
------------------------------------------------------------------------------- */

WSCLIENT WSLJWINTEGRACAO

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONNECT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   lLEXPORTA                 AS boolean
	WSDATA   cCAMBIENTE                AS string
	WSDATA   oWSAOUTDATA               AS LJWINTEGRACAO_OUTDATA
	WSDATA   cCFIL                     AS string
	WSDATA   cCEMP                     AS string
	WSDATA   oWSCONNECTRESULT          AS LJWINTEGRACAO_INDATA

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSOUTDATA                AS LJWINTEGRACAO_OUTDATA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJWINTEGRACAO
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJWINTEGRACAO
	::oWSAOUTDATA        := LJWINTEGRACAO_OUTDATA():New()
	::oWSCONNECTRESULT   := LJWINTEGRACAO_INDATA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSOUTDATA         := ::oWSAOUTDATA
Return

WSMETHOD RESET WSCLIENT WSLJWINTEGRACAO
	::lLEXPORTA          := NIL 
	::cCAMBIENTE         := NIL 
	::oWSAOUTDATA        := NIL 
	::cCFIL              := NIL 
	::cCEMP              := NIL 
	::oWSCONNECTRESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSOUTDATA         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJWINTEGRACAO
Local oClone := WSLJWINTEGRACAO():New()
	oClone:_URL          := ::_URL 
	oClone:lLEXPORTA     := ::lLEXPORTA
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:oWSAOUTDATA   :=  IIF(::oWSAOUTDATA = NIL , NIL ,::oWSAOUTDATA:Clone() )
	oClone:cCFIL         := ::cCFIL
	oClone:cCEMP         := ::cCEMP
	oClone:oWSCONNECTRESULT :=  IIF(::oWSCONNECTRESULT = NIL , NIL ,::oWSCONNECTRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSOUTDATA    := oClone:oWSAOUTDATA
Return oClone

// WSDL Method CONNECT of Service WSLJWINTEGRACAO

WSMETHOD CONNECT WSSEND lLEXPORTA,cCAMBIENTE,oWSAOUTDATA,cCFIL,cCEMP WSRECEIVE oWSCONNECTRESULT WSCLIENT WSLJWINTEGRACAO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONNECT xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("LEXPORTA", ::lLEXPORTA, lLEXPORTA , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("AOUTDATA", ::oWSAOUTDATA, oWSAOUTDATA , "OUTDATA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEMP", ::cCEMP, cCEMP , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONNECT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CONNECT",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/LJWINTEGRACAO.apw")

::Init()
::oWSCONNECTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONNECTRESPONSE:_CONNECTRESULT","INDATA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure OUTDATA

WSSTRUCT LJWINTEGRACAO_OUTDATA
	WSDATA   oWSNEWOUTTRANS            AS LJWINTEGRACAO_ARRAYOFOUTTRANS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_OUTDATA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_OUTDATA
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_OUTDATA
	Local oClone := LJWINTEGRACAO_OUTDATA():NEW()
	oClone:oWSNEWOUTTRANS       := IIF(::oWSNEWOUTTRANS = NIL , NIL , ::oWSNEWOUTTRANS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWINTEGRACAO_OUTDATA
	Local cSoap := ""
	cSoap += WSSoapValue("NEWOUTTRANS", ::oWSNEWOUTTRANS, ::oWSNEWOUTTRANS , "ARRAYOFOUTTRANS", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure INDATA

WSSTRUCT LJWINTEGRACAO_INDATA
	WSDATA   oWSNEWINTRANS             AS LJWINTEGRACAO_ARRAYOFINTRANS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_INDATA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_INDATA
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_INDATA
	Local oClone := LJWINTEGRACAO_INDATA():NEW()
	oClone:oWSNEWINTRANS        := IIF(::oWSNEWINTRANS = NIL , NIL , ::oWSNEWINTRANS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWINTEGRACAO_INDATA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NEWINTRANS","ARRAYOFINTRANS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNEWINTRANS := LJWINTEGRACAO_ARRAYOFINTRANS():New()
		::oWSNEWINTRANS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFOUTTRANS

WSSTRUCT LJWINTEGRACAO_ARRAYOFOUTTRANS
	WSDATA   oWSOUTTRANS               AS LJWINTEGRACAO_OUTTRANS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_ARRAYOFOUTTRANS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_ARRAYOFOUTTRANS
	::oWSOUTTRANS          := {} // Array Of  LJWINTEGRACAO_OUTTRANS():New()
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_ARRAYOFOUTTRANS
	Local oClone := LJWINTEGRACAO_ARRAYOFOUTTRANS():NEW()
	oClone:oWSOUTTRANS := NIL
	If ::oWSOUTTRANS <> NIL 
		oClone:oWSOUTTRANS := {}
		aEval( ::oWSOUTTRANS , { |x| aadd( oClone:oWSOUTTRANS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWINTEGRACAO_ARRAYOFOUTTRANS
	Local cSoap := ""
	aEval( ::oWSOUTTRANS , {|x| cSoap := cSoap  +  WSSoapValue("OUTTRANS", x , x , "OUTTRANS", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFINTRANS

WSSTRUCT LJWINTEGRACAO_ARRAYOFINTRANS
	WSDATA   oWSINTRANS                AS LJWINTEGRACAO_INTRANS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_ARRAYOFINTRANS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_ARRAYOFINTRANS
	::oWSINTRANS           := {} // Array Of  LJWINTEGRACAO_INTRANS():New()
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_ARRAYOFINTRANS
	Local oClone := LJWINTEGRACAO_ARRAYOFINTRANS():NEW()
	oClone:oWSINTRANS := NIL
	If ::oWSINTRANS <> NIL 
		oClone:oWSINTRANS := {}
		aEval( ::oWSINTRANS , { |x| aadd( oClone:oWSINTRANS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWINTEGRACAO_ARRAYOFINTRANS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INTRANS","INTRANS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINTRANS , LJWINTEGRACAO_INTRANS():New() )
			::oWSINTRANS[len(::oWSINTRANS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure OUTTRANS

WSSTRUCT LJWINTEGRACAO_OUTTRANS
	WSDATA   oWSNEWOUTREG              AS LJWINTEGRACAO_ARRAYOFOUTREG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_OUTTRANS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_OUTTRANS
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_OUTTRANS
	Local oClone := LJWINTEGRACAO_OUTTRANS():NEW()
	oClone:oWSNEWOUTREG         := IIF(::oWSNEWOUTREG = NIL , NIL , ::oWSNEWOUTREG:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWINTEGRACAO_OUTTRANS
	Local cSoap := ""
	cSoap += WSSoapValue("NEWOUTREG", ::oWSNEWOUTREG, ::oWSNEWOUTREG , "ARRAYOFOUTREG", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure INTRANS

WSSTRUCT LJWINTEGRACAO_INTRANS
	WSDATA   oWSNEWINREG               AS LJWINTEGRACAO_ARRAYOFINREG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_INTRANS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_INTRANS
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_INTRANS
	Local oClone := LJWINTEGRACAO_INTRANS():NEW()
	oClone:oWSNEWINREG          := IIF(::oWSNEWINREG = NIL , NIL , ::oWSNEWINREG:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWINTEGRACAO_INTRANS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NEWINREG","ARRAYOFINREG",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNEWINREG := LJWINTEGRACAO_ARRAYOFINREG():New()
		::oWSNEWINREG:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFOUTREG

WSSTRUCT LJWINTEGRACAO_ARRAYOFOUTREG
	WSDATA   oWSOUTREG                 AS LJWINTEGRACAO_OUTREG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_ARRAYOFOUTREG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_ARRAYOFOUTREG
	::oWSOUTREG            := {} // Array Of  LJWINTEGRACAO_OUTREG():New()
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_ARRAYOFOUTREG
	Local oClone := LJWINTEGRACAO_ARRAYOFOUTREG():NEW()
	oClone:oWSOUTREG := NIL
	If ::oWSOUTREG <> NIL 
		oClone:oWSOUTREG := {}
		aEval( ::oWSOUTREG , { |x| aadd( oClone:oWSOUTREG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWINTEGRACAO_ARRAYOFOUTREG
	Local cSoap := ""
	aEval( ::oWSOUTREG , {|x| cSoap := cSoap  +  WSSoapValue("OUTREG", x , x , "OUTREG", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFINREG

WSSTRUCT LJWINTEGRACAO_ARRAYOFINREG
	WSDATA   oWSINREG                  AS LJWINTEGRACAO_INREG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_ARRAYOFINREG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_ARRAYOFINREG
	::oWSINREG             := {} // Array Of  LJWINTEGRACAO_INREG():New()
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_ARRAYOFINREG
	Local oClone := LJWINTEGRACAO_ARRAYOFINREG():NEW()
	oClone:oWSINREG := NIL
	If ::oWSINREG <> NIL 
		oClone:oWSINREG := {}
		aEval( ::oWSINREG , { |x| aadd( oClone:oWSINREG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWINTEGRACAO_ARRAYOFINREG
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INREG","INREG",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSINREG , LJWINTEGRACAO_INREG():New() )
			::oWSINREG[len(::oWSINREG)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure OUTREG

WSSTRUCT LJWINTEGRACAO_OUTREG
	WSDATA   dDATAOUT                  AS date OPTIONAL
	WSDATA   cMODULO                   AS string OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   cPACOTE                   AS string OPTIONAL
	WSDATA   cPROCESSO                 AS string OPTIONAL
	WSDATA   cREGISTRO                 AS string OPTIONAL
	WSDATA   cSEQUENCIA                AS string OPTIONAL
	WSDATA   cSERVWEB                  AS string OPTIONAL
	WSDATA   cSITPRO                   AS string OPTIONAL
	WSDATA   cSTATUST                  AS string OPTIONAL
	WSDATA   cTIPO                     AS string OPTIONAL
	WSDATA   cTIPOCAMPO                AS string OPTIONAL
	WSDATA   cTOTREG                   AS string OPTIONAL
	WSDATA   cTRANSACAO                AS string OPTIONAL
	WSDATA   cVALOR                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_OUTREG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_OUTREG
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_OUTREG
	Local oClone := LJWINTEGRACAO_OUTREG():NEW()
	oClone:dDATAOUT             := ::dDATAOUT
	oClone:cMODULO              := ::cMODULO
	oClone:cNOME                := ::cNOME
	oClone:cORIGEM              := ::cORIGEM
	oClone:cPACOTE              := ::cPACOTE
	oClone:cPROCESSO            := ::cPROCESSO
	oClone:cREGISTRO            := ::cREGISTRO
	oClone:cSEQUENCIA           := ::cSEQUENCIA
	oClone:cSERVWEB             := ::cSERVWEB
	oClone:cSITPRO              := ::cSITPRO
	oClone:cSTATUST             := ::cSTATUST
	oClone:cTIPO                := ::cTIPO
	oClone:cTIPOCAMPO           := ::cTIPOCAMPO
	oClone:cTOTREG              := ::cTOTREG
	oClone:cTRANSACAO           := ::cTRANSACAO
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWINTEGRACAO_OUTREG
	Local cSoap := ""
	cSoap += WSSoapValue("DATAOUT", ::dDATAOUT, ::dDATAOUT , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MODULO", ::cMODULO, ::cMODULO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NOME", ::cNOME, ::cNOME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ORIGEM", ::cORIGEM, ::cORIGEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PACOTE", ::cPACOTE, ::cPACOTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PROCESSO", ::cPROCESSO, ::cPROCESSO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REGISTRO", ::cREGISTRO, ::cREGISTRO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCIA", ::cSEQUENCIA, ::cSEQUENCIA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SERVWEB", ::cSERVWEB, ::cSERVWEB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SITPRO", ::cSITPRO, ::cSITPRO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUST", ::cSTATUST, ::cSTATUST , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPO", ::cTIPO, ::cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TIPOCAMPO", ::cTIPOCAMPO, ::cTIPOCAMPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TOTREG", ::cTOTREG, ::cTOTREG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TRANSACAO", ::cTRANSACAO, ::cTRANSACAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VALOR", ::cVALOR, ::cVALOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure INREG

WSSTRUCT LJWINTEGRACAO_INREG
	WSDATA   dDATAIN                   AS date OPTIONAL
	WSDATA   cMODULO                   AS string OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   cPACOTE                   AS string OPTIONAL
	WSDATA   cPROCESSO                 AS string OPTIONAL
	WSDATA   cREGISTRO                 AS string OPTIONAL
	WSDATA   cSEQUENCIA                AS string OPTIONAL
	WSDATA   cSERVWEB                  AS string OPTIONAL
	WSDATA   cSITPRO                   AS string OPTIONAL
	WSDATA   cSTATUST                  AS string OPTIONAL
	WSDATA   cTIPO                     AS string OPTIONAL
	WSDATA   cTIPOCAMPO                AS string OPTIONAL
	WSDATA   cTOTREG                   AS string OPTIONAL
	WSDATA   cTRANSACAO                AS string OPTIONAL
	WSDATA   cVALOR                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWINTEGRACAO_INREG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWINTEGRACAO_INREG
Return

WSMETHOD CLONE WSCLIENT LJWINTEGRACAO_INREG
	Local oClone := LJWINTEGRACAO_INREG():NEW()
	oClone:dDATAIN              := ::dDATAIN
	oClone:cMODULO              := ::cMODULO
	oClone:cNOME                := ::cNOME
	oClone:cORIGEM              := ::cORIGEM
	oClone:cPACOTE              := ::cPACOTE
	oClone:cPROCESSO            := ::cPROCESSO
	oClone:cREGISTRO            := ::cREGISTRO
	oClone:cSEQUENCIA           := ::cSEQUENCIA
	oClone:cSERVWEB             := ::cSERVWEB
	oClone:cSITPRO              := ::cSITPRO
	oClone:cSTATUST             := ::cSTATUST
	oClone:cTIPO                := ::cTIPO
	oClone:cTIPOCAMPO           := ::cTIPOCAMPO
	oClone:cTOTREG              := ::cTOTREG
	oClone:cTRANSACAO           := ::cTRANSACAO
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWINTEGRACAO_INREG
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::dDATAIN            :=  WSAdvValue( oResponse,"_DATAIN","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cMODULO            :=  WSAdvValue( oResponse,"_MODULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cORIGEM            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPACOTE            :=  WSAdvValue( oResponse,"_PACOTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPROCESSO          :=  WSAdvValue( oResponse,"_PROCESSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cREGISTRO          :=  WSAdvValue( oResponse,"_REGISTRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSEQUENCIA         :=  WSAdvValue( oResponse,"_SEQUENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSERVWEB           :=  WSAdvValue( oResponse,"_SERVWEB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSITPRO            :=  WSAdvValue( oResponse,"_SITPRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUST           :=  WSAdvValue( oResponse,"_STATUST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPOCAMPO         :=  WSAdvValue( oResponse,"_TIPOCAMPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTOTREG            :=  WSAdvValue( oResponse,"_TOTREG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTRANSACAO         :=  WSAdvValue( oResponse,"_TRANSACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVALOR             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


