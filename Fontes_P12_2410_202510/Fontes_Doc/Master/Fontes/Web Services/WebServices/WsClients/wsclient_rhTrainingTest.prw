#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:81/ws/rhtrainingtest.APW?WSDL
Gerado em        11/08/16 17:14:03
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FICLMOQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHTRAININGTEST
------------------------------------------------------------------------------- */

WSCLIENT WSRHTRAININGTEST

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BRWAGENDA
	WSMETHOD GETAVALIACAO
	WSMETHOD PUTAVALIACAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cFILIALFUNC               AS string
	WSDATA   cMATRICULA                AS string
	WSDATA   cTIPO                     AS string
	WSDATA   oWSBRWAGENDARESULT        AS RHTRAININGTEST_ARRAYOFTAGENDA
	WSDATA   cCODAVAL                  AS string
	WSDATA   nRAJ_RECNO                AS integer
	WSDATA   oWSGETAVALIACAORESULT     AS RHTRAININGTEST_TESTTYPES
	WSDATA   oWSAVALIACAO              AS RHTRAININGTEST_TAVALIACAO
	WSDATA   oWSPUTAVALIACAORESULT     AS RHTRAININGTEST_ARRAYOFTAGENDA

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTAVALIACAO             AS RHTRAININGTEST_TAVALIACAO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHTRAININGTEST
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20161103 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHTRAININGTEST
	::oWSBRWAGENDARESULT := RHTRAININGTEST_ARRAYOFTAGENDA():New()
	::oWSGETAVALIACAORESULT := RHTRAININGTEST_TESTTYPES():New()
	::oWSAVALIACAO       := RHTRAININGTEST_TAVALIACAO():New()
	::oWSPUTAVALIACAORESULT := RHTRAININGTEST_ARRAYOFTAGENDA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTAVALIACAO      := ::oWSAVALIACAO
Return

WSMETHOD RESET WSCLIENT WSRHTRAININGTEST
	::cFILIALFUNC        := NIL 
	::cMATRICULA         := NIL 
	::cTIPO              := NIL 
	::oWSBRWAGENDARESULT := NIL 
	::cCODAVAL           := NIL 
	::nRAJ_RECNO         := NIL 
	::oWSGETAVALIACAORESULT := NIL 
	::oWSAVALIACAO       := NIL 
	::oWSPUTAVALIACAORESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTAVALIACAO      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHTRAININGTEST
Local oClone := WSRHTRAININGTEST():New()
	oClone:_URL          := ::_URL 
	oClone:cFILIALFUNC   := ::cFILIALFUNC
	oClone:cMATRICULA    := ::cMATRICULA
	oClone:cTIPO         := ::cTIPO
	oClone:oWSBRWAGENDARESULT :=  IIF(::oWSBRWAGENDARESULT = NIL , NIL ,::oWSBRWAGENDARESULT:Clone() )
	oClone:cCODAVAL      := ::cCODAVAL
	oClone:nRAJ_RECNO    := ::nRAJ_RECNO
	oClone:oWSGETAVALIACAORESULT :=  IIF(::oWSGETAVALIACAORESULT = NIL , NIL ,::oWSGETAVALIACAORESULT:Clone() )
	oClone:oWSAVALIACAO  :=  IIF(::oWSAVALIACAO = NIL , NIL ,::oWSAVALIACAO:Clone() )
	oClone:oWSPUTAVALIACAORESULT :=  IIF(::oWSPUTAVALIACAORESULT = NIL , NIL ,::oWSPUTAVALIACAORESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTAVALIACAO := oClone:oWSAVALIACAO
Return oClone

// WSDL Method BRWAGENDA of Service WSRHTRAININGTEST

WSMETHOD BRWAGENDA WSSEND cFILIALFUNC,cMATRICULA,cTIPO WSRECEIVE oWSBRWAGENDARESULT WSCLIENT WSRHTRAININGTEST
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BRWAGENDA xmlns="http://localhost:81/">'
cSoap += WSSoapValue("FILIALFUNC", ::cFILIALFUNC, cFILIALFUNC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MATRICULA", ::cMATRICULA, cMATRICULA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</BRWAGENDA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/BRWAGENDA",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/RHTRAININGTEST.apw")

::Init()
::oWSBRWAGENDARESULT:SoapRecv( WSAdvValue( oXmlRet,"_BRWAGENDARESPONSE:_BRWAGENDARESULT","ARRAYOFTAGENDA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETAVALIACAO of Service WSRHTRAININGTEST

WSMETHOD GETAVALIACAO WSSEND cCODAVAL,cTIPO,nRAJ_RECNO WSRECEIVE oWSGETAVALIACAORESULT WSCLIENT WSRHTRAININGTEST
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETAVALIACAO xmlns="http://localhost:81/">'
cSoap += WSSoapValue("CODAVAL", ::cCODAVAL, cCODAVAL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TIPO", ::cTIPO, cTIPO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("RAJ_RECNO", ::nRAJ_RECNO, nRAJ_RECNO , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETAVALIACAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/GETAVALIACAO",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/RHTRAININGTEST.apw")

::Init()
::oWSGETAVALIACAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETAVALIACAORESPONSE:_GETAVALIACAORESULT","TESTTYPES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTAVALIACAO of Service WSRHTRAININGTEST

WSMETHOD PUTAVALIACAO WSSEND oWSAVALIACAO WSRECEIVE oWSPUTAVALIACAORESULT WSCLIENT WSRHTRAININGTEST
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTAVALIACAO xmlns="http://localhost:81/">'
cSoap += WSSoapValue("AVALIACAO", ::oWSAVALIACAO, oWSAVALIACAO , "TAVALIACAO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTAVALIACAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/PUTAVALIACAO",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/RHTRAININGTEST.apw")

::Init()
::oWSPUTAVALIACAORESULT:SoapRecv( WSAdvValue( oXmlRet,"_PUTAVALIACAORESPONSE:_PUTAVALIACAORESULT","ARRAYOFTAGENDA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFTAGENDA

WSSTRUCT RHTRAININGTEST_ARRAYOFTAGENDA
	WSDATA   oWSTAGENDA                AS RHTRAININGTEST_TAGENDA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_ARRAYOFTAGENDA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_ARRAYOFTAGENDA
	::oWSTAGENDA           := {} // Array Of  RHTRAININGTEST_TAGENDA():New()
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_ARRAYOFTAGENDA
	Local oClone := RHTRAININGTEST_ARRAYOFTAGENDA():NEW()
	oClone:oWSTAGENDA := NIL
	If ::oWSTAGENDA <> NIL 
		oClone:oWSTAGENDA := {}
		aEval( ::oWSTAGENDA , { |x| aadd( oClone:oWSTAGENDA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_ARRAYOFTAGENDA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TAGENDA","TAGENDA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTAGENDA , RHTRAININGTEST_TAGENDA():New() )
			::oWSTAGENDA[len(::oWSTAGENDA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TESTTYPES

WSSTRUCT RHTRAININGTEST_TESTTYPES
	WSDATA   cAREACODE                 AS string OPTIONAL
	WSDATA   cCONTSERV                 AS string OPTIONAL
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSDATA   cDURATION                 AS string OPTIONAL
	WSDATA   cEVALTYPE                 AS string OPTIONAL
	WSDATA   cEVALUATION               AS string OPTIONAL
	WSDATA   cITEM                     AS string OPTIONAL
	WSDATA   oWSLISTOFQUESTIONS        AS RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES OPTIONAL
	WSDATA   cQUESTION                 AS string OPTIONAL
	WSDATA   cSUBJECT                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_TESTTYPES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_TESTTYPES
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_TESTTYPES
	Local oClone := RHTRAININGTEST_TESTTYPES():NEW()
	oClone:cAREACODE            := ::cAREACODE
	oClone:cCONTSERV            := ::cCONTSERV
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cDURATION            := ::cDURATION
	oClone:cEVALTYPE            := ::cEVALTYPE
	oClone:cEVALUATION          := ::cEVALUATION
	oClone:cITEM                := ::cITEM
	oClone:oWSLISTOFQUESTIONS   := IIF(::oWSLISTOFQUESTIONS = NIL , NIL , ::oWSLISTOFQUESTIONS:Clone() )
	oClone:cQUESTION            := ::cQUESTION
	oClone:cSUBJECT             := ::cSUBJECT
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_TESTTYPES
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAREACODE          :=  WSAdvValue( oResponse,"_AREACODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCONTSERV          :=  WSAdvValue( oResponse,"_CONTSERV","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDURATION          :=  WSAdvValue( oResponse,"_DURATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEVALTYPE          :=  WSAdvValue( oResponse,"_EVALTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEVALUATION        :=  WSAdvValue( oResponse,"_EVALUATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cITEM              :=  WSAdvValue( oResponse,"_ITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_LISTOFQUESTIONS","ARRAYOFQUESTIONSTESTTYPES",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSLISTOFQUESTIONS := RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES():New()
		::oWSLISTOFQUESTIONS:SoapRecv(oNode8)
	EndIf
	::cQUESTION          :=  WSAdvValue( oResponse,"_QUESTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TAVALIACAO

WSSTRUCT RHTRAININGTEST_TAVALIACAO
	WSDATA   oWSANSWERS                AS RHTRAININGTEST_ARRAYOFTRESPOSTAS
	WSDATA   cDURATION                 AS string
	WSDATA   nRAJ_RECNO                AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_TAVALIACAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_TAVALIACAO
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_TAVALIACAO
	Local oClone := RHTRAININGTEST_TAVALIACAO():NEW()
	oClone:oWSANSWERS           := IIF(::oWSANSWERS = NIL , NIL , ::oWSANSWERS:Clone() )
	oClone:cDURATION            := ::cDURATION
	oClone:nRAJ_RECNO           := ::nRAJ_RECNO
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHTRAININGTEST_TAVALIACAO
	Local cSoap := ""
	cSoap += WSSoapValue("ANSWERS", ::oWSANSWERS, ::oWSANSWERS , "ARRAYOFTRESPOSTAS", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DURATION", ::cDURATION, ::cDURATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RAJ_RECNO", ::nRAJ_RECNO, ::nRAJ_RECNO , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TAGENDA

WSSTRUCT RHTRAININGTEST_TAGENDA
	WSDATA   cCALENDARIO               AS string OPTIONAL
	WSDATA   cCODAVAL                  AS string OPTIONAL
	WSDATA   cCURSO                    AS string OPTIONAL
	WSDATA   dDATAAVALIACAO            AS date OPTIONAL
	WSDATA   dDATAAVALIACAO1           AS date OPTIONAL
	WSDATA   cDESCRICAOAVAL            AS string OPTIONAL
	WSDATA   cDESCRICAOCURSO           AS string OPTIONAL
	WSDATA   cDESCRTIPOPROVA           AS string OPTIONAL
	WSDATA   lEDITAVEL                 AS boolean OPTIONAL
	WSDATA   cFILIAL                   AS string OPTIONAL
	WSDATA   cHORAAVALIACAO            AS string OPTIONAL
	WSDATA   cLEGENDA                  AS string OPTIONAL
	WSDATA   cMATRICULA                AS string OPTIONAL
	WSDATA   cMATRICULAAVAL            AS string OPTIONAL
	WSDATA   cNOME                     AS string OPTIONAL
	WSDATA   nRAJ_RECNO                AS integer OPTIONAL
	WSDATA   lREALIZADO                AS boolean OPTIONAL
	WSDATA   cTIPOAVAL                 AS string OPTIONAL
	WSDATA   cTIPOPROVA                AS string OPTIONAL
	WSDATA   cTITULOLEGENDA            AS string OPTIONAL
	WSDATA   cTURMA                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_TAGENDA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_TAGENDA
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_TAGENDA
	Local oClone := RHTRAININGTEST_TAGENDA():NEW()
	oClone:cCALENDARIO          := ::cCALENDARIO
	oClone:cCODAVAL             := ::cCODAVAL
	oClone:cCURSO               := ::cCURSO
	oClone:dDATAAVALIACAO       := ::dDATAAVALIACAO
	oClone:dDATAAVALIACAO1      := ::dDATAAVALIACAO1
	oClone:cDESCRICAOAVAL       := ::cDESCRICAOAVAL
	oClone:cDESCRICAOCURSO      := ::cDESCRICAOCURSO
	oClone:cDESCRTIPOPROVA      := ::cDESCRTIPOPROVA
	oClone:lEDITAVEL            := ::lEDITAVEL
	oClone:cFILIAL              := ::cFILIAL
	oClone:cHORAAVALIACAO       := ::cHORAAVALIACAO
	oClone:cLEGENDA             := ::cLEGENDA
	oClone:cMATRICULA           := ::cMATRICULA
	oClone:cMATRICULAAVAL       := ::cMATRICULAAVAL
	oClone:cNOME                := ::cNOME
	oClone:nRAJ_RECNO           := ::nRAJ_RECNO
	oClone:lREALIZADO           := ::lREALIZADO
	oClone:cTIPOAVAL            := ::cTIPOAVAL
	oClone:cTIPOPROVA           := ::cTIPOPROVA
	oClone:cTITULOLEGENDA       := ::cTITULOLEGENDA
	oClone:cTURMA               := ::cTURMA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_TAGENDA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCALENDARIO        :=  WSAdvValue( oResponse,"_CALENDARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODAVAL           :=  WSAdvValue( oResponse,"_CODAVAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCURSO             :=  WSAdvValue( oResponse,"_CURSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dDATAAVALIACAO     :=  WSAdvValue( oResponse,"_DATAAVALIACAO","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::dDATAAVALIACAO1    :=  WSAdvValue( oResponse,"_DATAAVALIACAO1","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cDESCRICAOAVAL     :=  WSAdvValue( oResponse,"_DESCRICAOAVAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRICAOCURSO    :=  WSAdvValue( oResponse,"_DESCRICAOCURSO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRTIPOPROVA    :=  WSAdvValue( oResponse,"_DESCRTIPOPROVA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lEDITAVEL          :=  WSAdvValue( oResponse,"_EDITAVEL","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cFILIAL            :=  WSAdvValue( oResponse,"_FILIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHORAAVALIACAO     :=  WSAdvValue( oResponse,"_HORAAVALIACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLEGENDA           :=  WSAdvValue( oResponse,"_LEGENDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMATRICULA         :=  WSAdvValue( oResponse,"_MATRICULA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMATRICULAAVAL     :=  WSAdvValue( oResponse,"_MATRICULAAVAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nRAJ_RECNO         :=  WSAdvValue( oResponse,"_RAJ_RECNO","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::lREALIZADO         :=  WSAdvValue( oResponse,"_REALIZADO","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cTIPOAVAL          :=  WSAdvValue( oResponse,"_TIPOAVAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPOPROVA         :=  WSAdvValue( oResponse,"_TIPOPROVA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTITULOLEGENDA     :=  WSAdvValue( oResponse,"_TITULOLEGENDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTURMA             :=  WSAdvValue( oResponse,"_TURMA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFQUESTIONSTESTTYPES

WSSTRUCT RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES
	WSDATA   oWSQUESTIONSTESTTYPES     AS RHTRAININGTEST_QUESTIONSTESTTYPES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES
	::oWSQUESTIONSTESTTYPES := {} // Array Of  RHTRAININGTEST_QUESTIONSTESTTYPES():New()
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES
	Local oClone := RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES():NEW()
	oClone:oWSQUESTIONSTESTTYPES := NIL
	If ::oWSQUESTIONSTESTTYPES <> NIL 
		oClone:oWSQUESTIONSTESTTYPES := {}
		aEval( ::oWSQUESTIONSTESTTYPES , { |x| aadd( oClone:oWSQUESTIONSTESTTYPES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_ARRAYOFQUESTIONSTESTTYPES
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_QUESTIONSTESTTYPES","QUESTIONSTESTTYPES",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSQUESTIONSTESTTYPES , RHTRAININGTEST_QUESTIONSTESTTYPES():New() )
			::oWSQUESTIONSTESTTYPES[len(::oWSQUESTIONSTESTTYPES)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTRESPOSTAS

WSSTRUCT RHTRAININGTEST_ARRAYOFTRESPOSTAS
	WSDATA   oWSTRESPOSTAS             AS RHTRAININGTEST_TRESPOSTAS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_ARRAYOFTRESPOSTAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_ARRAYOFTRESPOSTAS
	::oWSTRESPOSTAS        := {} // Array Of  RHTRAININGTEST_TRESPOSTAS():New()
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_ARRAYOFTRESPOSTAS
	Local oClone := RHTRAININGTEST_ARRAYOFTRESPOSTAS():NEW()
	oClone:oWSTRESPOSTAS := NIL
	If ::oWSTRESPOSTAS <> NIL 
		oClone:oWSTRESPOSTAS := {}
		aEval( ::oWSTRESPOSTAS , { |x| aadd( oClone:oWSTRESPOSTAS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHTRAININGTEST_ARRAYOFTRESPOSTAS
	Local cSoap := ""
	aEval( ::oWSTRESPOSTAS , {|x| cSoap := cSoap  +  WSSoapValue("TRESPOSTAS", x , x , "TRESPOSTAS", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure QUESTIONSTESTTYPES

WSSTRUCT RHTRAININGTEST_QUESTIONSTESTTYPES
	WSDATA   cACTIVE                   AS string OPTIONAL
	WSDATA   cALTERNATIVE              AS string OPTIONAL
	WSDATA   cANSWERTYPE               AS string OPTIONAL
	WSDATA   cAREACODE                 AS string OPTIONAL
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSDATA   cDETDESCCD                AS string OPTIONAL
	WSDATA   cLEVEL                    AS string OPTIONAL
	WSDATA   oWSLISTOFALTERNATIVE      AS RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS OPTIONAL
	WSDATA   cPOINTS                   AS string OPTIONAL
	WSDATA   cQUESTION                 AS string OPTIONAL
	WSDATA   cQUESTIONDT               AS string OPTIONAL
	WSDATA   cSUBJECT                  AS string OPTIONAL
	WSDATA   cTYPE                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_QUESTIONSTESTTYPES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_QUESTIONSTESTTYPES
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_QUESTIONSTESTTYPES
	Local oClone := RHTRAININGTEST_QUESTIONSTESTTYPES():NEW()
	oClone:cACTIVE              := ::cACTIVE
	oClone:cALTERNATIVE         := ::cALTERNATIVE
	oClone:cANSWERTYPE          := ::cANSWERTYPE
	oClone:cAREACODE            := ::cAREACODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cDETDESCCD           := ::cDETDESCCD
	oClone:cLEVEL               := ::cLEVEL
	oClone:oWSLISTOFALTERNATIVE := IIF(::oWSLISTOFALTERNATIVE = NIL , NIL , ::oWSLISTOFALTERNATIVE:Clone() )
	oClone:cPOINTS              := ::cPOINTS
	oClone:cQUESTION            := ::cQUESTION
	oClone:cQUESTIONDT          := ::cQUESTIONDT
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cTYPE                := ::cTYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_QUESTIONSTESTTYPES
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cACTIVE            :=  WSAdvValue( oResponse,"_ACTIVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cALTERNATIVE       :=  WSAdvValue( oResponse,"_ALTERNATIVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cANSWERTYPE        :=  WSAdvValue( oResponse,"_ANSWERTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAREACODE          :=  WSAdvValue( oResponse,"_AREACODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDETDESCCD         :=  WSAdvValue( oResponse,"_DETDESCCD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLEVEL             :=  WSAdvValue( oResponse,"_LEVEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_LISTOFALTERNATIVE","ARRAYOFALTERNATIVEQUESTIONS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSLISTOFALTERNATIVE := RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS():New()
		::oWSLISTOFALTERNATIVE:SoapRecv(oNode8)
	EndIf
	::cPOINTS            :=  WSAdvValue( oResponse,"_POINTS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQUESTION          :=  WSAdvValue( oResponse,"_QUESTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQUESTIONDT        :=  WSAdvValue( oResponse,"_QUESTIONDT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TRESPOSTAS

WSSTRUCT RHTRAININGTEST_TRESPOSTAS
	WSDATA   cANSWER                   AS string
	WSDATA   cQUESTIONCODE             AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_TRESPOSTAS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_TRESPOSTAS
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_TRESPOSTAS
	Local oClone := RHTRAININGTEST_TRESPOSTAS():NEW()
	oClone:cANSWER              := ::cANSWER
	oClone:cQUESTIONCODE        := ::cQUESTIONCODE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHTRAININGTEST_TRESPOSTAS
	Local cSoap := ""
	cSoap += WSSoapValue("ANSWER", ::cANSWER, ::cANSWER , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QUESTIONCODE", ::cQUESTIONCODE, ::cQUESTIONCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFALTERNATIVEQUESTIONS

WSSTRUCT RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS
	WSDATA   oWSALTERNATIVEQUESTIONS   AS RHTRAININGTEST_ALTERNATIVEQUESTIONS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS
	::oWSALTERNATIVEQUESTIONS := {} // Array Of  RHTRAININGTEST_ALTERNATIVEQUESTIONS():New()
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS
	Local oClone := RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS():NEW()
	oClone:oWSALTERNATIVEQUESTIONS := NIL
	If ::oWSALTERNATIVEQUESTIONS <> NIL 
		oClone:oWSALTERNATIVEQUESTIONS := {}
		aEval( ::oWSALTERNATIVEQUESTIONS , { |x| aadd( oClone:oWSALTERNATIVEQUESTIONS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_ARRAYOFALTERNATIVEQUESTIONS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALTERNATIVEQUESTIONS","ALTERNATIVEQUESTIONS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALTERNATIVEQUESTIONS , RHTRAININGTEST_ALTERNATIVEQUESTIONS():New() )
			::oWSALTERNATIVEQUESTIONS[len(::oWSALTERNATIVEQUESTIONS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALTERNATIVEQUESTIONS

WSSTRUCT RHTRAININGTEST_ALTERNATIVEQUESTIONS
	WSDATA   cALTERNATIVE              AS string OPTIONAL
	WSDATA   cAREACODE                 AS string OPTIONAL
	WSDATA   cCODE                     AS string OPTIONAL
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSDATA   cQUESTION                 AS string OPTIONAL
	WSDATA   cRESPOSTA                 AS string OPTIONAL
	WSDATA   cSUBJECT                  AS string OPTIONAL
	WSDATA   cVALUE                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHTRAININGTEST_ALTERNATIVEQUESTIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHTRAININGTEST_ALTERNATIVEQUESTIONS
Return

WSMETHOD CLONE WSCLIENT RHTRAININGTEST_ALTERNATIVEQUESTIONS
	Local oClone := RHTRAININGTEST_ALTERNATIVEQUESTIONS():NEW()
	oClone:cALTERNATIVE         := ::cALTERNATIVE
	oClone:cAREACODE            := ::cAREACODE
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cQUESTION            := ::cQUESTION
	oClone:cRESPOSTA            := ::cRESPOSTA
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cVALUE               := ::cVALUE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHTRAININGTEST_ALTERNATIVEQUESTIONS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cALTERNATIVE       :=  WSAdvValue( oResponse,"_ALTERNATIVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAREACODE          :=  WSAdvValue( oResponse,"_AREACODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODE              :=  WSAdvValue( oResponse,"_CODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cQUESTION          :=  WSAdvValue( oResponse,"_QUESTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRESPOSTA          :=  WSAdvValue( oResponse,"_RESPOSTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVALUE             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


