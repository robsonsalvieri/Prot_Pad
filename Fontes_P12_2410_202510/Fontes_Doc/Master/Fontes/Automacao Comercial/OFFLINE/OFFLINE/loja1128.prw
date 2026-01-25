#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://127.0.0.1:2780/LJWESTOQUE.apw?WSDL
Gerado em        09/13/21 18:47:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TDLTNTL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLJWESTOQUE
------------------------------------------------------------------------------- */

WSCLIENT WSLJWESTOQUE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CANCRES
	WSMETHOD CONSEST
	WSMETHOD CONSRES
	WSMETHOD RESPROD

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSACANCRES               AS LJWESTOQUE_CANCRES
	WSDATA   cKEYCLI                   AS string
	WSDATA   oWSCANCRESRESULT          AS LJWESTOQUE_RETCANC
	WSDATA   oWSACONSPROD              AS LJWESTOQUE_CONSPROD
	WSDATA   oWSCONSESTRESULT          AS LJWESTOQUE_RETSALDOS
	WSDATA   oWSACONSRES               AS LJWESTOQUE_CONSRES
	WSDATA   oWSCONSRESRESULT          AS LJWESTOQUE_RETCRES
	WSDATA   oWSARESPROD               AS LJWESTOQUE_RESPROD
	WSDATA   oWSRESPRODRESULT          AS LJWESTOQUE_RETRES

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSCANCRES                AS LJWESTOQUE_CANCRES
	WSDATA   oWSCONSPROD               AS LJWESTOQUE_CONSPROD
	WSDATA   oWSCONSRES                AS LJWESTOQUE_CONSRES
	WSDATA   oWSRESPROD                AS LJWESTOQUE_RESPROD

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLJWESTOQUE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLJWESTOQUE
	::oWSACANCRES        := LJWESTOQUE_CANCRES():New()
	::oWSCANCRESRESULT   := LJWESTOQUE_RETCANC():New()
	::oWSACONSPROD       := LJWESTOQUE_CONSPROD():New()
	::oWSCONSESTRESULT   := LJWESTOQUE_RETSALDOS():New()
	::oWSACONSRES        := LJWESTOQUE_CONSRES():New()
	::oWSCONSRESRESULT   := LJWESTOQUE_RETCRES():New()
	::oWSARESPROD        := LJWESTOQUE_RESPROD():New()
	::oWSRESPRODRESULT   := LJWESTOQUE_RETRES():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCANCRES         := ::oWSACANCRES
	::oWSCONSPROD        := ::oWSACONSPROD
	::oWSCONSRES         := ::oWSACONSRES
	::oWSRESPROD         := ::oWSARESPROD
Return

WSMETHOD RESET WSCLIENT WSLJWESTOQUE
	::oWSACANCRES        := NIL 
	::cKEYCLI            := NIL 
	::oWSCANCRESRESULT   := NIL 
	::oWSACONSPROD       := NIL 
	::oWSCONSESTRESULT   := NIL 
	::oWSACONSRES        := NIL 
	::oWSCONSRESRESULT   := NIL 
	::oWSARESPROD        := NIL 
	::oWSRESPRODRESULT   := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSCANCRES         := NIL
	::oWSCONSPROD        := NIL
	::oWSCONSRES         := NIL
	::oWSRESPROD         := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLJWESTOQUE
Local oClone := WSLJWESTOQUE():New()
	oClone:_URL          := ::_URL 
	oClone:oWSACANCRES   :=  IIF(::oWSACANCRES = NIL , NIL ,::oWSACANCRES:Clone() )
	oClone:cKEYCLI       := ::cKEYCLI
	oClone:oWSCANCRESRESULT :=  IIF(::oWSCANCRESRESULT = NIL , NIL ,::oWSCANCRESRESULT:Clone() )
	oClone:oWSACONSPROD  :=  IIF(::oWSACONSPROD = NIL , NIL ,::oWSACONSPROD:Clone() )
	oClone:oWSCONSESTRESULT :=  IIF(::oWSCONSESTRESULT = NIL , NIL ,::oWSCONSESTRESULT:Clone() )
	oClone:oWSACONSRES   :=  IIF(::oWSACONSRES = NIL , NIL ,::oWSACONSRES:Clone() )
	oClone:oWSCONSRESRESULT :=  IIF(::oWSCONSRESRESULT = NIL , NIL ,::oWSCONSRESRESULT:Clone() )
	oClone:oWSARESPROD   :=  IIF(::oWSARESPROD = NIL , NIL ,::oWSARESPROD:Clone() )
	oClone:oWSRESPRODRESULT :=  IIF(::oWSRESPRODRESULT = NIL , NIL ,::oWSRESPRODRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSCANCRES    := oClone:oWSACANCRES
	oClone:oWSCONSPROD   := oClone:oWSACONSPROD
	oClone:oWSCONSRES    := oClone:oWSACONSRES
	oClone:oWSRESPROD    := oClone:oWSARESPROD
Return oClone

// WSDL Method CANCRES of Service WSLJWESTOQUE

WSMETHOD CANCRES WSSEND oWSACANCRES,cKEYCLI WSRECEIVE oWSCANCRESRESULT WSCLIENT WSLJWESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CANCRES xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ACANCRES", ::oWSACANCRES, oWSACANCRES , "CANCRES", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("KEYCLI", ::cKEYCLI, cKEYCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CANCRES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CANCRES",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/LJWESTOQUE.apw")

::Init()
::oWSCANCRESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CANCRESRESPONSE:_CANCRESRESULT","RETCANC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSEST of Service WSLJWESTOQUE

WSMETHOD CONSEST WSSEND oWSACONSPROD WSRECEIVE oWSCONSESTRESULT WSCLIENT WSLJWESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSEST xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ACONSPROD", ::oWSACONSPROD, oWSACONSPROD , "CONSPROD", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CONSEST",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/LJWESTOQUE.apw")

::Init()
::oWSCONSESTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSESTRESPONSE:_CONSESTRESULT","RETSALDOS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSRES of Service WSLJWESTOQUE

WSMETHOD CONSRES WSSEND oWSACONSRES,cKEYCLI WSRECEIVE oWSCONSRESRESULT WSCLIENT WSLJWESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSRES xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ACONSRES", ::oWSACONSRES, oWSACONSRES , "CONSRES", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("KEYCLI", ::cKEYCLI, cKEYCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSRES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/CONSRES",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/LJWESTOQUE.apw")

::Init()
::oWSCONSRESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSRESRESPONSE:_CONSRESRESULT","RETCRES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RESPROD of Service WSLJWESTOQUE

WSMETHOD RESPROD WSSEND oWSARESPROD WSRECEIVE oWSRESPRODRESULT WSCLIENT WSLJWESTOQUE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RESPROD xmlns="http://127.0.0.1:2780/">'
cSoap += WSSoapValue("ARESPROD", ::oWSARESPROD, oWSARESPROD , "RESPROD", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RESPROD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://127.0.0.1:2780/RESPROD",; 
	"DOCUMENT","http://127.0.0.1:2780/",,"1.031217",; 
	"http://127.0.0.1:2780/LJWESTOQUE.apw")

::Init()
::oWSRESPRODRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RESPRODRESPONSE:_RESPRODRESULT","RETRES",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CANCRES

WSSTRUCT LJWESTOQUE_CANCRES
	WSDATA   oWSNCANCRES               AS LJWESTOQUE_ARRAYOFITCANCRES
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_CANCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_CANCRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_CANCRES
	Local oClone := LJWESTOQUE_CANCRES():NEW()
	oClone:oWSNCANCRES          := IIF(::oWSNCANCRES = NIL , NIL , ::oWSNCANCRES:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_CANCRES
	Local cSoap := ""
	cSoap += WSSoapValue("NCANCRES", ::oWSNCANCRES, ::oWSNCANCRES , "ARRAYOFITCANCRES", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RETCANC

WSSTRUCT LJWESTOQUE_RETCANC
	WSDATA   oWSNRETCANC               AS LJWESTOQUE_ARRAYOFITRETCANC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_RETCANC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_RETCANC
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_RETCANC
	Local oClone := LJWESTOQUE_RETCANC():NEW()
	oClone:oWSNRETCANC          := IIF(::oWSNRETCANC = NIL , NIL , ::oWSNRETCANC:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_RETCANC
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NRETCANC","ARRAYOFITRETCANC",NIL,"Property oWSNRETCANC as s0:ARRAYOFITRETCANC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNRETCANC := LJWESTOQUE_ARRAYOFITRETCANC():New()
		::oWSNRETCANC:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure CONSPROD

WSSTRUCT LJWESTOQUE_CONSPROD
	WSDATA   oWSNCONSPROD              AS LJWESTOQUE_ARRAYOFPRODUTO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_CONSPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_CONSPROD
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_CONSPROD
	Local oClone := LJWESTOQUE_CONSPROD():NEW()
	oClone:oWSNCONSPROD         := IIF(::oWSNCONSPROD = NIL , NIL , ::oWSNCONSPROD:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_CONSPROD
	Local cSoap := ""
	cSoap += WSSoapValue("NCONSPROD", ::oWSNCONSPROD, ::oWSNCONSPROD , "ARRAYOFPRODUTO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RETSALDOS

WSSTRUCT LJWESTOQUE_RETSALDOS
	WSDATA   oWSNRETSALDOS             AS LJWESTOQUE_ARRAYOFSALDO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_RETSALDOS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_RETSALDOS
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_RETSALDOS
	Local oClone := LJWESTOQUE_RETSALDOS():NEW()
	oClone:oWSNRETSALDOS        := IIF(::oWSNRETSALDOS = NIL , NIL , ::oWSNRETSALDOS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_RETSALDOS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NRETSALDOS","ARRAYOFSALDO",NIL,"Property oWSNRETSALDOS as s0:ARRAYOFSALDO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNRETSALDOS := LJWESTOQUE_ARRAYOFSALDO():New()
		::oWSNRETSALDOS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure CONSRES

WSSTRUCT LJWESTOQUE_CONSRES
	WSDATA   oWSNCONSRES               AS LJWESTOQUE_ARRAYOFITCONSRES
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_CONSRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_CONSRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_CONSRES
	Local oClone := LJWESTOQUE_CONSRES():NEW()
	oClone:oWSNCONSRES          := IIF(::oWSNCONSRES = NIL , NIL , ::oWSNCONSRES:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_CONSRES
	Local cSoap := ""
	cSoap += WSSoapValue("NCONSRES", ::oWSNCONSRES, ::oWSNCONSRES , "ARRAYOFITCONSRES", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RETCRES

WSSTRUCT LJWESTOQUE_RETCRES
	WSDATA   oWSNRETCRES               AS LJWESTOQUE_ARRAYOFITRETCRES
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_RETCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_RETCRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_RETCRES
	Local oClone := LJWESTOQUE_RETCRES():NEW()
	oClone:oWSNRETCRES          := IIF(::oWSNRETCRES = NIL , NIL , ::oWSNRETCRES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_RETCRES
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NRETCRES","ARRAYOFITRETCRES",NIL,"Property oWSNRETCRES as s0:ARRAYOFITRETCRES on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNRETCRES := LJWESTOQUE_ARRAYOFITRETCRES():New()
		::oWSNRETCRES:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure RESPROD

WSSTRUCT LJWESTOQUE_RESPROD
	WSDATA   oWSNRESPROD               AS LJWESTOQUE_ARRAYOFITRESPROD
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_RESPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_RESPROD
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_RESPROD
	Local oClone := LJWESTOQUE_RESPROD():NEW()
	oClone:oWSNRESPROD          := IIF(::oWSNRESPROD = NIL , NIL , ::oWSNRESPROD:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_RESPROD
	Local cSoap := ""
	cSoap += WSSoapValue("NRESPROD", ::oWSNRESPROD, ::oWSNRESPROD , "ARRAYOFITRESPROD", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RETRES

WSSTRUCT LJWESTOQUE_RETRES
	WSDATA   oWSNRETRES                AS LJWESTOQUE_ARRAYOFITRETRES
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_RETRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_RETRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_RETRES
	Local oClone := LJWESTOQUE_RETRES():NEW()
	oClone:oWSNRETRES           := IIF(::oWSNRETRES = NIL , NIL , ::oWSNRETRES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_RETRES
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NRETRES","ARRAYOFITRETRES",NIL,"Property oWSNRETRES as s0:ARRAYOFITRETRES on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNRETRES := LJWESTOQUE_ARRAYOFITRETRES():New()
		::oWSNRETRES:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFITCANCRES

WSSTRUCT LJWESTOQUE_ARRAYOFITCANCRES
	WSDATA   oWSITCANCRES              AS LJWESTOQUE_ITCANCRES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITCANCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITCANCRES
	::oWSITCANCRES         := {} // Array Of  LJWESTOQUE_ITCANCRES():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITCANCRES
	Local oClone := LJWESTOQUE_ARRAYOFITCANCRES():NEW()
	oClone:oWSITCANCRES := NIL
	If ::oWSITCANCRES <> NIL 
		oClone:oWSITCANCRES := {}
		aEval( ::oWSITCANCRES , { |x| aadd( oClone:oWSITCANCRES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ARRAYOFITCANCRES
	Local cSoap := ""
	aEval( ::oWSITCANCRES , {|x| cSoap := cSoap  +  WSSoapValue("ITCANCRES", x , x , "ITCANCRES", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFITRETCANC

WSSTRUCT LJWESTOQUE_ARRAYOFITRETCANC
	WSDATA   oWSITRETCANC              AS LJWESTOQUE_ITRETCANC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITRETCANC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITRETCANC
	::oWSITRETCANC         := {} // Array Of  LJWESTOQUE_ITRETCANC():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITRETCANC
	Local oClone := LJWESTOQUE_ARRAYOFITRETCANC():NEW()
	oClone:oWSITRETCANC := NIL
	If ::oWSITRETCANC <> NIL 
		oClone:oWSITRETCANC := {}
		aEval( ::oWSITRETCANC , { |x| aadd( oClone:oWSITRETCANC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ARRAYOFITRETCANC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITRETCANC","ITRETCANC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITRETCANC , LJWESTOQUE_ITRETCANC():New() )
			::oWSITRETCANC[len(::oWSITRETCANC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFPRODUTO

WSSTRUCT LJWESTOQUE_ARRAYOFPRODUTO
	WSDATA   oWSPRODUTO                AS LJWESTOQUE_PRODUTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFPRODUTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFPRODUTO
	::oWSPRODUTO           := {} // Array Of  LJWESTOQUE_PRODUTO():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFPRODUTO
	Local oClone := LJWESTOQUE_ARRAYOFPRODUTO():NEW()
	oClone:oWSPRODUTO := NIL
	If ::oWSPRODUTO <> NIL 
		oClone:oWSPRODUTO := {}
		aEval( ::oWSPRODUTO , { |x| aadd( oClone:oWSPRODUTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ARRAYOFPRODUTO
	Local cSoap := ""
	aEval( ::oWSPRODUTO , {|x| cSoap := cSoap  +  WSSoapValue("PRODUTO", x , x , "PRODUTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSALDO

WSSTRUCT LJWESTOQUE_ARRAYOFSALDO
	WSDATA   oWSSALDO                  AS LJWESTOQUE_SALDO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFSALDO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFSALDO
	::oWSSALDO             := {} // Array Of  LJWESTOQUE_SALDO():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFSALDO
	Local oClone := LJWESTOQUE_ARRAYOFSALDO():NEW()
	oClone:oWSSALDO := NIL
	If ::oWSSALDO <> NIL 
		oClone:oWSSALDO := {}
		aEval( ::oWSSALDO , { |x| aadd( oClone:oWSSALDO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ARRAYOFSALDO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SALDO","SALDO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSALDO , LJWESTOQUE_SALDO():New() )
			::oWSSALDO[len(::oWSSALDO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITCONSRES

WSSTRUCT LJWESTOQUE_ARRAYOFITCONSRES
	WSDATA   oWSITCONSRES              AS LJWESTOQUE_ITCONSRES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITCONSRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITCONSRES
	::oWSITCONSRES         := {} // Array Of  LJWESTOQUE_ITCONSRES():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITCONSRES
	Local oClone := LJWESTOQUE_ARRAYOFITCONSRES():NEW()
	oClone:oWSITCONSRES := NIL
	If ::oWSITCONSRES <> NIL 
		oClone:oWSITCONSRES := {}
		aEval( ::oWSITCONSRES , { |x| aadd( oClone:oWSITCONSRES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ARRAYOFITCONSRES
	Local cSoap := ""
	aEval( ::oWSITCONSRES , {|x| cSoap := cSoap  +  WSSoapValue("ITCONSRES", x , x , "ITCONSRES", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFITRETCRES

WSSTRUCT LJWESTOQUE_ARRAYOFITRETCRES
	WSDATA   oWSITRETCRES              AS LJWESTOQUE_ITRETCRES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITRETCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITRETCRES
	::oWSITRETCRES         := {} // Array Of  LJWESTOQUE_ITRETCRES():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITRETCRES
	Local oClone := LJWESTOQUE_ARRAYOFITRETCRES():NEW()
	oClone:oWSITRETCRES := NIL
	If ::oWSITRETCRES <> NIL 
		oClone:oWSITRETCRES := {}
		aEval( ::oWSITRETCRES , { |x| aadd( oClone:oWSITRETCRES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ARRAYOFITRETCRES
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITRETCRES","ITRETCRES",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITRETCRES , LJWESTOQUE_ITRETCRES():New() )
			::oWSITRETCRES[len(::oWSITRETCRES)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFITRESPROD

WSSTRUCT LJWESTOQUE_ARRAYOFITRESPROD
	WSDATA   oWSITRESPROD              AS LJWESTOQUE_ITRESPROD OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITRESPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITRESPROD
	::oWSITRESPROD         := {} // Array Of  LJWESTOQUE_ITRESPROD():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITRESPROD
	Local oClone := LJWESTOQUE_ARRAYOFITRESPROD():NEW()
	oClone:oWSITRESPROD := NIL
	If ::oWSITRESPROD <> NIL 
		oClone:oWSITRESPROD := {}
		aEval( ::oWSITRESPROD , { |x| aadd( oClone:oWSITRESPROD , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ARRAYOFITRESPROD
	Local cSoap := ""
	aEval( ::oWSITRESPROD , {|x| cSoap := cSoap  +  WSSoapValue("ITRESPROD", x , x , "ITRESPROD", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFITRETRES

WSSTRUCT LJWESTOQUE_ARRAYOFITRETRES
	WSDATA   oWSITRETRES               AS LJWESTOQUE_ITRETRES OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ARRAYOFITRETRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ARRAYOFITRETRES
	::oWSITRETRES          := {} // Array Of  LJWESTOQUE_ITRETRES():New()
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ARRAYOFITRETRES
	Local oClone := LJWESTOQUE_ARRAYOFITRETRES():NEW()
	oClone:oWSITRETRES := NIL
	If ::oWSITRETRES <> NIL 
		oClone:oWSITRETRES := {}
		aEval( ::oWSITRETRES , { |x| aadd( oClone:oWSITRETRES , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ARRAYOFITRETRES
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITRETRES","ITRETRES",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSITRETRES , LJWESTOQUE_ITRETRES():New() )
			::oWSITRETRES[len(::oWSITRETRES)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ITCANCRES

WSSTRUCT LJWESTOQUE_ITCANCRES
	WSDATA   cARMAZEM                  AS string
	WSDATA   cENDERECO                 AS string
	WSDATA   cFILCANC                  AS string
	WSDATA   cLOJARES                  AS string
	WSDATA   cNUMLOTE                  AS string
	WSDATA   cNUMSERIE                 AS string
	WSDATA   cPRODUTO                  AS string
	WSDATA   cRESERVA                  AS string
	WSDATA   cSUBLOTE                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITCANCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITCANCRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITCANCRES
	Local oClone := LJWESTOQUE_ITCANCRES():NEW()
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:cENDERECO            := ::cENDERECO
	oClone:cFILCANC             := ::cFILCANC
	oClone:cLOJARES             := ::cLOJARES
	oClone:cNUMLOTE             := ::cNUMLOTE
	oClone:cNUMSERIE            := ::cNUMSERIE
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:cRESERVA             := ::cRESERVA
	oClone:cSUBLOTE             := ::cSUBLOTE
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ITCANCRES
	Local cSoap := ""
	cSoap += WSSoapValue("ARMAZEM", ::cARMAZEM, ::cARMAZEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDERECO", ::cENDERECO, ::cENDERECO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILCANC", ::cFILCANC, ::cFILCANC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJARES", ::cLOJARES, ::cLOJARES , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMLOTE", ::cNUMLOTE, ::cNUMLOTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMSERIE", ::cNUMSERIE, ::cNUMSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RESERVA", ::cRESERVA, ::cRESERVA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBLOTE", ::cSUBLOTE, ::cSUBLOTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ITRETCANC

WSSTRUCT LJWESTOQUE_ITRETCANC
	WSDATA   lCANCELA                  AS boolean
	WSDATA   cRESERVA                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITRETCANC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITRETCANC
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITRETCANC
	Local oClone := LJWESTOQUE_ITRETCANC():NEW()
	oClone:lCANCELA             := ::lCANCELA
	oClone:cRESERVA             := ::cRESERVA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ITRETCANC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lCANCELA           :=  WSAdvValue( oResponse,"_CANCELA","boolean",NIL,"Property lCANCELA as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cRESERVA           :=  WSAdvValue( oResponse,"_RESERVA","string",NIL,"Property cRESERVA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PRODUTO

WSSTRUCT LJWESTOQUE_PRODUTO
	WSDATA   cARMAZEM                  AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRI                   AS string
	WSDATA   cEMPCONS                  AS string
	WSDATA   cFILCONS                  AS string
	WSDATA   nITEM                     AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_PRODUTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_PRODUTO
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_PRODUTO
	Local oClone := LJWESTOQUE_PRODUTO():NEW()
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRI              := ::cDESCRI
	oClone:cEMPCONS             := ::cEMPCONS
	oClone:cFILCONS             := ::cFILCONS
	oClone:nITEM                := ::nITEM
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_PRODUTO
	Local cSoap := ""
	cSoap += WSSoapValue("ARMAZEM", ::cARMAZEM, ::cARMAZEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRI", ::cDESCRI, ::cDESCRI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPCONS", ::cEMPCONS, ::cEMPCONS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILCONS", ::cFILCONS, ::cFILCONS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEM", ::nITEM, ::nITEM , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SALDO

WSSTRUCT LJWESTOQUE_SALDO
	WSDATA   cARMAZEM                  AS string
	WSDATA   nATUAL                    AS float
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRI                   AS string
	WSDATA   cEMPCONS                  AS string
	WSDATA   cFILCONS                  AS string
	WSDATA   cGRUPO                    AS string
	WSDATA   nINICIAL                  AS float
	WSDATA   nITEM                     AS float
	WSDATA   nPRECO1                   AS float
	WSDATA   nPRECO2                   AS float
	WSDATA   nPRECO3                   AS float
	WSDATA   nPRECO4                   AS float
	WSDATA   nPRECO5                   AS float
	WSDATA   nPRECO6                   AS float
	WSDATA   nPRECO7                   AS float
	WSDATA   nPRECO8                   AS float
	WSDATA   nPRECO9                   AS float
	WSDATA   cUNIDADE                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_SALDO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_SALDO
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_SALDO
	Local oClone := LJWESTOQUE_SALDO():NEW()
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:nATUAL               := ::nATUAL
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRI              := ::cDESCRI
	oClone:cEMPCONS             := ::cEMPCONS
	oClone:cFILCONS             := ::cFILCONS
	oClone:cGRUPO               := ::cGRUPO
	oClone:nINICIAL             := ::nINICIAL
	oClone:nITEM                := ::nITEM
	oClone:nPRECO1              := ::nPRECO1
	oClone:nPRECO2              := ::nPRECO2
	oClone:nPRECO3              := ::nPRECO3
	oClone:nPRECO4              := ::nPRECO4
	oClone:nPRECO5              := ::nPRECO5
	oClone:nPRECO6              := ::nPRECO6
	oClone:nPRECO7              := ::nPRECO7
	oClone:nPRECO8              := ::nPRECO8
	oClone:nPRECO9              := ::nPRECO9
	oClone:cUNIDADE             := ::cUNIDADE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_SALDO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cARMAZEM           :=  WSAdvValue( oResponse,"_ARMAZEM","string",NIL,"Property cARMAZEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nATUAL             :=  WSAdvValue( oResponse,"_ATUAL","float",NIL,"Property nATUAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRI            :=  WSAdvValue( oResponse,"_DESCRI","string",NIL,"Property cDESCRI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEMPCONS           :=  WSAdvValue( oResponse,"_EMPCONS","string",NIL,"Property cEMPCONS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILCONS           :=  WSAdvValue( oResponse,"_FILCONS","string",NIL,"Property cFILCONS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cGRUPO             :=  WSAdvValue( oResponse,"_GRUPO","string",NIL,"Property cGRUPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nINICIAL           :=  WSAdvValue( oResponse,"_INICIAL","float",NIL,"Property nINICIAL as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nITEM              :=  WSAdvValue( oResponse,"_ITEM","float",NIL,"Property nITEM as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO1            :=  WSAdvValue( oResponse,"_PRECO1","float",NIL,"Property nPRECO1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO2            :=  WSAdvValue( oResponse,"_PRECO2","float",NIL,"Property nPRECO2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO3            :=  WSAdvValue( oResponse,"_PRECO3","float",NIL,"Property nPRECO3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO4            :=  WSAdvValue( oResponse,"_PRECO4","float",NIL,"Property nPRECO4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO5            :=  WSAdvValue( oResponse,"_PRECO5","float",NIL,"Property nPRECO5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO6            :=  WSAdvValue( oResponse,"_PRECO6","float",NIL,"Property nPRECO6 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO7            :=  WSAdvValue( oResponse,"_PRECO7","float",NIL,"Property nPRECO7 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO8            :=  WSAdvValue( oResponse,"_PRECO8","float",NIL,"Property nPRECO8 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPRECO9            :=  WSAdvValue( oResponse,"_PRECO9","float",NIL,"Property nPRECO9 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUNIDADE           :=  WSAdvValue( oResponse,"_UNIDADE","string",NIL,"Property cUNIDADE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ITCONSRES

WSSTRUCT LJWESTOQUE_ITCONSRES
	WSDATA   cFILCONS                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITCONSRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITCONSRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITCONSRES
	Local oClone := LJWESTOQUE_ITCONSRES():NEW()
	oClone:cFILCONS             := ::cFILCONS
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ITCONSRES
	Local cSoap := ""
	cSoap += WSSoapValue("FILCONS", ::cFILCONS, ::cFILCONS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ITRETCRES

WSSTRUCT LJWESTOQUE_ITRETCRES
	WSDATA   cARMAZEM                  AS string
	WSDATA   cCODRES                   AS string
	WSDATA   cDATARES                  AS string
	WSDATA   cDATAVAL                  AS string
	WSDATA   cFILCONS                  AS string
	WSDATA   cOBSERV                   AS string
	WSDATA   cPRODUTO                  AS string
	WSDATA   nQUANTRES                 AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITRETCRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITRETCRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITRETCRES
	Local oClone := LJWESTOQUE_ITRETCRES():NEW()
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:cCODRES              := ::cCODRES
	oClone:cDATARES             := ::cDATARES
	oClone:cDATAVAL             := ::cDATAVAL
	oClone:cFILCONS             := ::cFILCONS
	oClone:cOBSERV              := ::cOBSERV
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:nQUANTRES            := ::nQUANTRES
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ITRETCRES
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cARMAZEM           :=  WSAdvValue( oResponse,"_ARMAZEM","string",NIL,"Property cARMAZEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODRES            :=  WSAdvValue( oResponse,"_CODRES","string",NIL,"Property cCODRES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATARES           :=  WSAdvValue( oResponse,"_DATARES","string",NIL,"Property cDATARES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATAVAL           :=  WSAdvValue( oResponse,"_DATAVAL","string",NIL,"Property cDATAVAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFILCONS           :=  WSAdvValue( oResponse,"_FILCONS","string",NIL,"Property cFILCONS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERV            :=  WSAdvValue( oResponse,"_OBSERV","string",NIL,"Property cOBSERV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPRODUTO           :=  WSAdvValue( oResponse,"_PRODUTO","string",NIL,"Property cPRODUTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQUANTRES          :=  WSAdvValue( oResponse,"_QUANTRES","float",NIL,"Property nQUANTRES as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ITRESPROD

WSSTRUCT LJWESTOQUE_ITRESPROD
	WSDATA   cARMAZEM                  AS string
	WSDATA   cCODCLI                   AS string
	WSDATA   cCODPROD                  AS string
	WSDATA   cDTVALID                  AS string
	WSDATA   cEMPRES                   AS string
	WSDATA   cENDERECO                 AS string
	WSDATA   cFILRES                   AS string
	WSDATA   cITVENDA                  AS string
	WSDATA   cKEYCLI                   AS string
	WSDATA   cLOJCLI                   AS string
	WSDATA   cLOTE                     AS string
	WSDATA   cNUMSERIE                 AS string
	WSDATA   nQTDERES                  AS float
	WSDATA   cQUEBRA                   AS string
	WSDATA   cSUBLOTE                  AS string
	WSDATA   cTPVENDA                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITRESPROD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITRESPROD
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITRESPROD
	Local oClone := LJWESTOQUE_ITRESPROD():NEW()
	oClone:cARMAZEM             := ::cARMAZEM
	oClone:cCODCLI              := ::cCODCLI
	oClone:cCODPROD             := ::cCODPROD
	oClone:cDTVALID             := ::cDTVALID
	oClone:cEMPRES              := ::cEMPRES
	oClone:cENDERECO            := ::cENDERECO
	oClone:cFILRES              := ::cFILRES
	oClone:cITVENDA             := ::cITVENDA
	oClone:cKEYCLI              := ::cKEYCLI
	oClone:cLOJCLI              := ::cLOJCLI
	oClone:cLOTE                := ::cLOTE
	oClone:cNUMSERIE            := ::cNUMSERIE
	oClone:nQTDERES             := ::nQTDERES
	oClone:cQUEBRA              := ::cQUEBRA
	oClone:cSUBLOTE             := ::cSUBLOTE
	oClone:cTPVENDA             := ::cTPVENDA
Return oClone

WSMETHOD SOAPSEND WSCLIENT LJWESTOQUE_ITRESPROD
	Local cSoap := ""
	cSoap += WSSoapValue("ARMAZEM", ::cARMAZEM, ::cARMAZEM , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODCLI", ::cCODCLI, ::cCODCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODPROD", ::cCODPROD, ::cCODPROD , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DTVALID", ::cDTVALID, ::cDTVALID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRES", ::cEMPRES, ::cEMPRES , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENDERECO", ::cENDERECO, ::cENDERECO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILRES", ::cFILRES, ::cFILRES , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITVENDA", ::cITVENDA, ::cITVENDA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("KEYCLI", ::cKEYCLI, ::cKEYCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOJCLI", ::cLOJCLI, ::cLOJCLI , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LOTE", ::cLOTE, ::cLOTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NUMSERIE", ::cNUMSERIE, ::cNUMSERIE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QTDERES", ::nQTDERES, ::nQTDERES , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QUEBRA", ::cQUEBRA, ::cQUEBRA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBLOTE", ::cSUBLOTE, ::cSUBLOTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TPVENDA", ::cTPVENDA, ::cTPVENDA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ITRETRES

WSSTRUCT LJWESTOQUE_ITRETRES
	WSDATA   cFILRES                   AS string
	WSDATA   cITEM                     AS string
	WSDATA   cORCAM                    AS string
	WSDATA   cPEDIDO                   AS string OPTIONAL
	WSDATA   cRESERVA                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LJWESTOQUE_ITRETRES
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LJWESTOQUE_ITRETRES
Return

WSMETHOD CLONE WSCLIENT LJWESTOQUE_ITRETRES
	Local oClone := LJWESTOQUE_ITRETRES():NEW()
	oClone:cFILRES              := ::cFILRES
	oClone:cITEM                := ::cITEM
	oClone:cORCAM               := ::cORCAM
	oClone:cPEDIDO              := ::cPEDIDO
	oClone:cRESERVA             := ::cRESERVA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LJWESTOQUE_ITRETRES
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFILRES            :=  WSAdvValue( oResponse,"_FILRES","string",NIL,"Property cFILRES as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cITEM              :=  WSAdvValue( oResponse,"_ITEM","string",NIL,"Property cITEM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cORCAM             :=  WSAdvValue( oResponse,"_ORCAM","string",NIL,"Property cORCAM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPEDIDO            :=  WSAdvValue( oResponse,"_PEDIDO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRESERVA           :=  WSAdvValue( oResponse,"_RESERVA","string",NIL,"Property cRESERVA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


