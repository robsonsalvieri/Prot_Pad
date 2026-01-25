#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 

/* ===============================================================================
WSDL Location    http://localhost:8080/NFSE001.apw?WSDL
Gerado em        01/09/13 10:32:08
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QHNROXL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNFSE001
------------------------------------------------------------------------------- */

WSCLIENT WSNFSE001

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CANCELANFSE001
	WSMETHOD CFGAMBNFSE001
	WSMETHOD CFGNFSECERTPFX
	WSMETHOD CFGREADYX
	WSMETHOD CONSLOTENFSE001
	WSMETHOD CONSNOTANFSE001
	WSMETHOD CONSSEQNFSE001
	WSMETHOD GERAARQIMP
	WSMETHOD GERAARQIMPARR
	WSMETHOD GETMUNSIAF
	WSMETHOD MONITORX
	WSMETHOD PROCIMPNFSETXT
	WSMETHOD REMESSANFSE001
	WSMETHOD RETMUNCANC
	WSMETHOD RETMUNSERV
	WSMETHOD RETORNANFSE
	WSMETHOD SCHEMAX
	WSMETHOD STATUSNFSE
	WSMETHOD TSSCONSRPSNFSE
	WSMETHOD VERSAONFSE001
	WSMETHOD CONSCHVNFSE001 

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cID_ENT                   AS string
	WSDATA   oWSNFSE                   AS NFSE001_NFSE
	WSDATA   cCODMUN                   AS string
	WSDATA   oWSCANCELANFSE001RESULT   AS NFSE001_NFSESID
	WSDATA   nAMBIENTENFSE             AS integer
	WSDATA   nMODNFSE                  AS integer
	WSDATA   cVERSAONFSE               AS string
	WSDATA   cCODSIAFI                 AS string
	WSDATA   cUSO                      AS string
	WSDATA   cMAXLOTE                  AS string
	WSDATA   cCNPJAUT                  AS string
	WSDATA   cENVSINC                  AS string
	WSDATA   cLOGIN                    AS string
	WSDATA   cPASS                     AS base64Binary
	WSDATA   cAUTORIZACAO              AS base64Binary
	WSDATA   cChaveAutenticacao        AS string
	WSDATA   cCFGAMBNFSE001RESULT      AS string
	WSDATA   cCERTIFICATE              AS base64Binary
	WSDATA   cPASSWORD                 AS base64Binary
	WSDATA   cCFGNFSECERTPFXRESULT     AS string
	WSDATA   nCFGREADYXRESULT          AS integer
	WSDATA   cLOTE                     AS string
	WSDATA   cCONSLOTENFSE001RESULT    AS string
	WSDATA   dDATADE                   AS date
	WSDATA   dDATAATE                  AS date
	WSDATA   oWSCONSNOTANFSE001RESULT  AS NFSE001_NFSE2
	WSDATA   cCONSSEQNFSE001RESULT     AS string
	WSDATA   cIDINICIAL                AS string
	WSDATA   cIDFINAL                  AS string
	WSDATA   cDEST                     AS string
	WSDATA   dDATEDECL                 AS date
	WSDATA   lREPROC                   AS boolean
	WSDATA   dDATAINI                  AS date
	WSDATA   dDATAFIM                  AS date
	WSDATA   cGERAARQIMPRESULT         AS string
	WSDATA   oWSNFSEARR                AS NFSE001_NFSID
	WSDATA   cGERAARQIMPARRRESULT      AS string
	WSDATA   oWSGETMUNSIAFRESULT       AS NFSE001_SIAFLISTRETURN
	WSDATA   nTIPOMONITOR              AS integer
	WSDATA   cHORADE                   AS string
	WSDATA   cHORAATE                  AS string
	WSDATA   nTEMPO                    AS integer
	WSDATA   nDIASPARAEXCLUSAO         AS integer
	WSDATA   cIDNOTAS                  AS string
	WSDATA   cCALLNAME                 AS string
	WSDATA   oWSMONITORXRESULT         AS NFSE001_ARRAYOFMONITORNFSE
	WSDATA   cARQTXT                   AS string
	WSDATA   cPROCIMPNFSETXTRESULT     AS string
	WSDATA   oWSREMESSANFSE001RESULT   AS NFSE001_NFSESID
	WSDATA   cRETMUNCANCRESULT         AS string
	WSDATA   cCSERVICO                 AS string
	WSDATA   cRETMUNSERVRESULT         AS string
	WSDATA   oWSNFSEID                 AS NFSE001_NFSID
	WSDATA   oWSRETORNANFSERESULT      AS NFSE001_NFS5
	WSDATA   oWSNF                     AS NFSE001_NF
	WSDATA   oWSSCHEMAXRESULT          AS NFSE001_ARRAYOFNFSES4
	WSDATA   cIDTHREAD                 AS string
	WSDATA   cSTATUSNFSERESULT         AS string
	WSDATA   cTSSID                    AS string
	WSDATA   cNUMERORPS                AS string
	WSDATA   cSERIERPS                 AS string
	WSDATA   cTIPORPS                  AS string
	WSDATA   oWSTSSCONSRPSNFSERESULT   AS NFSE001_TSSCONSRPSNFSERETURN
	WSDATA   cVERSAONFSE001RESULT      AS string
	WSDATA   cTOKENID                  AS string
	WSDATA   cCLIENTID                 AS string
	WSDATA   cCLIENTSECRET             AS string
	WSDATA   CDATAHORA		           AS string
	WSDATA   cFtpT					   AS string
	WSDATA   cARQIMPRET				   AS string
	WSDATA   cNFSENAC				   AS string 
	WSDATA   cNFSEDISTRDANFSE		   AS string 
	WSDATA   DANFSE		           	   AS string
	WSDATA   XMLTSS		           	   AS string
	WSDATA   oWSCONSCHVNFSE001RESULT   AS NFSE001_CONSCHVNFSE001RETURN 
	WSDATA   CHVNFSE			   	   AS string
	WSDATA   cIMNAC 				   AS string 


	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSNFSID                  AS NFSE001_NFSID

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNFSE001
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNFSE001
	::oWSNFSE            := NFSE001_NFSE():New()
	::oWSCANCELANFSE001RESULT := NFSE001_NFSESID():New()
	::oWSCONSNOTANFSE001RESULT := NFSE001_NFSE2():New()
	::oWSNFSEARR         := NFSE001_NFSID():New()
	::oWSGETMUNSIAFRESULT := NFSE001_SIAFLISTRETURN():New()
	::oWSMONITORXRESULT  := NFSE001_ARRAYOFMONITORNFSE():New()
	::oWSREMESSANFSE001RESULT := NFSE001_NFSESID():New()
	::oWSNFSEID          := NFSE001_NFSID():New()
	::oWSRETORNANFSERESULT := NFSE001_NFS5():New()
	::oWSNF              := NFSE001_NF():New()
	::oWSSCHEMAXRESULT   := NFSE001_ARRAYOFNFSES4():New()
	::oWSTSSCONSRPSNFSERESULT := NFSE001_TSSCONSRPSNFSERETURN():New()
	::oWSCONSCHVNFSE001RESULT := NFSE001_CONSCHVNFSE001RETURN():New() 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSNFSE            := ::oWSNFSE
	::oWSNFSID           := ::oWSNFSEARR
	::oWSNF              := ::oWSNF
Return

WSMETHOD RESET WSCLIENT WSNFSE001
	::cUSERTOKEN         := NIL 
	::cID_ENT            := NIL 
	::oWSNFSE            := NIL 
	::cCODMUN            := NIL 
	::oWSCANCELANFSE001RESULT := NIL 
	::nAMBIENTENFSE      := NIL 
	::nMODNFSE           := NIL 
	::cVERSAONFSE        := NIL 
	::cCODSIAFI          := NIL 
	::cUSO               := NIL 
	::cMAXLOTE           := NIL 
	::cCNPJAUT           := NIL
	::cENVSINC           := NIL 
	::cLOGIN             := NIL 
	::cPASS              := NIL 
	::cAUTORIZACAO       := NIL 
	::cChaveAutenticacao := NIL 
	::cCFGAMBNFSE001RESULT := NIL 
	::cCERTIFICATE       := NIL 
	::cPASSWORD          := NIL 
	::cCFGNFSECERTPFXRESULT := NIL 
	::nCFGREADYXRESULT   := NIL 
	::cLOTE              := NIL 
	::cCONSLOTENFSE001RESULT := NIL 
	::dDATADE            := NIL 
	::dDATAATE           := NIL 
	::oWSCONSNOTANFSE001RESULT := NIL 
	::cCONSSEQNFSE001RESULT := NIL 
	::cIDINICIAL         := NIL 
	::cIDFINAL           := NIL 
	::cDEST              := NIL 
	::dDATEDECL          := NIL 
	::lREPROC            := NIL 
	::dDATAINI           := NIL 
	::dDATAFIM           := NIL 
	::cGERAARQIMPRESULT  := NIL 
	::oWSNFSEARR         := NIL 
	::cGERAARQIMPARRRESULT := NIL 
	::oWSGETMUNSIAFRESULT := NIL 
	::nTIPOMONITOR       := NIL 
	::cHORADE            := NIL 
	::cHORAATE           := NIL 
	::nTEMPO             := NIL 
	::nDIASPARAEXCLUSAO  := NIL 
	::cIDNOTAS           := NIL 
	::cCALLNAME          := NIL 
	::oWSMONITORXRESULT  := NIL 
	::cARQTXT            := NIL 
	::cPROCIMPNFSETXTRESULT := NIL 
	::oWSREMESSANFSE001RESULT := NIL 
	::cRETMUNCANCRESULT  := NIL 
	::cCSERVICO          := NIL 
	::cRETMUNSERVRESULT  := NIL 
	::oWSNFSEID          := NIL 
	::oWSRETORNANFSERESULT := NIL 
	::oWSNF              := NIL 
	::oWSSCHEMAXRESULT   := NIL 
	::cIDTHREAD          := NIL 
	::cSTATUSNFSERESULT  := NIL 
	::cTSSID             := NIL 
	::cNUMERORPS         := NIL 
	::cSERIERPS          := NIL 
	::cTIPORPS           := NIL 
	::oWSTSSCONSRPSNFSERESULT := NIL 
	::cVERSAONFSE001RESULT := NIL 
	::cTOKENID           := NIL 
	::cCLIENTID          := NIL 
	::cCLIENTSECRET      := NIL 
	::CDATAHORA			 := NIL
	::cFtpT				 := NIL
	::cARQIMPRET		 := NIL
	::cNFSENAC			 := NIL 
	::cNFSEDISTRDANFSE	 := NIL 
	::DANFSE			:= NIL 
	::XMLTSS			:= NIL 
	::oWSCONSCHVNFSE001RESULT := NIL 
	::CHVNFSE		 	 := NIL


	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSNFSE            := NIL
	::oWSNFSID           := NIL
	::oWSNF              := NIL
	::cNEWNFSE           := Nil  
	::cNFSENAC           := Nil
	::cIMNAC             := Nil

	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNFSE001
Local oClone := WSNFSE001():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERTOKEN    := ::cUSERTOKEN
	oClone:cID_ENT       := ::cID_ENT
	oClone:oWSNFSE       :=  IIF(::oWSNFSE = NIL , NIL ,::oWSNFSE:Clone() )
	oClone:cCODMUN       := ::cCODMUN
	oClone:oWSCANCELANFSE001RESULT :=  IIF(::oWSCANCELANFSE001RESULT = NIL , NIL ,::oWSCANCELANFSE001RESULT:Clone() )
	oClone:nAMBIENTENFSE := ::nAMBIENTENFSE
	oClone:nMODNFSE      := ::nMODNFSE
	oClone:cVERSAONFSE   := ::cVERSAONFSE
	oClone:cCODSIAFI     := ::cCODSIAFI
	oClone:cUSO          := ::cUSO
	oClone:cMAXLOTE      := ::cMAXLOTE
	oClone:cCNPJAUT      := ::cCNPJAUT
	oClone:cENVSINC      := ::cENVSINC
	oClone:cLOGIN        := ::cLOGIN
	oClone:cPASS         := ::cPASS
	oClone:cAUTORIZACAO  := ::cAUTORIZACAO
	oClone:cChaveAutenticacao:= ::cChaveAutenticacao
	oClone:cCFGAMBNFSE001RESULT := ::cCFGAMBNFSE001RESULT
	oClone:cCERTIFICATE  := ::cCERTIFICATE
	oClone:cPASSWORD     := ::cPASSWORD
	oClone:cCFGNFSECERTPFXRESULT := ::cCFGNFSECERTPFXRESULT
	oClone:nCFGREADYXRESULT := ::nCFGREADYXRESULT
	oClone:cLOTE         := ::cLOTE
	oClone:cCONSLOTENFSE001RESULT := ::cCONSLOTENFSE001RESULT
	oClone:dDATADE       := ::dDATADE
	oClone:dDATAATE      := ::dDATAATE
	oClone:oWSCONSNOTANFSE001RESULT :=  IIF(::oWSCONSNOTANFSE001RESULT = NIL , NIL ,::oWSCONSNOTANFSE001RESULT:Clone() )
	oClone:cCONSSEQNFSE001RESULT := ::cCONSSEQNFSE001RESULT
	oClone:cIDINICIAL    := ::cIDINICIAL
	oClone:cIDFINAL      := ::cIDFINAL
	oClone:cDEST         := ::cDEST
	oClone:dDATEDECL     := ::dDATEDECL
	oClone:lREPROC       := ::lREPROC
	oClone:dDATAINI      := ::dDATAINI
	oClone:dDATAFIM      := ::dDATAFIM
	oClone:cGERAARQIMPRESULT := ::cGERAARQIMPRESULT
	oClone:oWSNFSEARR    :=  IIF(::oWSNFSEARR = NIL , NIL ,::oWSNFSEARR:Clone() )
	oClone:cGERAARQIMPARRRESULT := ::cGERAARQIMPARRRESULT
	oClone:oWSGETMUNSIAFRESULT :=  IIF(::oWSGETMUNSIAFRESULT = NIL , NIL ,::oWSGETMUNSIAFRESULT:Clone() )
	oClone:nTIPOMONITOR  := ::nTIPOMONITOR
	oClone:cHORADE       := ::cHORADE
	oClone:cHORAATE      := ::cHORAATE
	oClone:nTEMPO        := ::nTEMPO
	oClone:nDIASPARAEXCLUSAO := ::nDIASPARAEXCLUSAO
	oClone:cIDNOTAS      := ::cIDNOTAS
	oClone:cCALLNAME     := ::cCALLNAME
	oClone:oWSMONITORXRESULT :=  IIF(::oWSMONITORXRESULT = NIL , NIL ,::oWSMONITORXRESULT:Clone() )
	oClone:cARQTXT       := ::cARQTXT
	oClone:cPROCIMPNFSETXTRESULT := ::cPROCIMPNFSETXTRESULT
	oClone:oWSREMESSANFSE001RESULT :=  IIF(::oWSREMESSANFSE001RESULT = NIL , NIL ,::oWSREMESSANFSE001RESULT:Clone() )
	oClone:cRETMUNCANCRESULT := ::cRETMUNCANCRESULT
	oClone:cCSERVICO     := ::cCSERVICO
	oClone:cRETMUNSERVRESULT := ::cRETMUNSERVRESULT
	oClone:oWSNFSEID     :=  IIF(::oWSNFSEID = NIL , NIL ,::oWSNFSEID:Clone() )
	oClone:oWSRETORNANFSERESULT :=  IIF(::oWSRETORNANFSERESULT = NIL , NIL ,::oWSRETORNANFSERESULT:Clone() )
	oClone:oWSNF         :=  IIF(::oWSNF = NIL , NIL ,::oWSNF:Clone() )
	oClone:oWSSCHEMAXRESULT :=  IIF(::oWSSCHEMAXRESULT = NIL , NIL ,::oWSSCHEMAXRESULT:Clone() )
	oClone:cIDTHREAD     := ::cIDTHREAD
	oClone:cSTATUSNFSERESULT := ::cSTATUSNFSERESULT
	oClone:cTSSID        := ::cTSSID
	oClone:cNUMERORPS    := ::cNUMERORPS
	oClone:cSERIERPS     := ::cSERIERPS
	oClone:cTIPORPS      := ::cTIPORPS
	oClone:oWSTSSCONSRPSNFSERESULT :=  IIF(::oWSTSSCONSRPSNFSERESULT = NIL , NIL ,::oWSTSSCONSRPSNFSERESULT:Clone() )
	oClone:cVERSAONFSE001RESULT := ::cVERSAONFSE001RESULT
	oClone:cTOKENID      	 := ::cTOKENID
	oClone:cCLIENTID     	 := ::cCLIENTID
	oClone:cCLIENTSECRET	 := ::cCLIENTSECRET
	oClone:CDATAHORA		 := ::CDATAHORA
	oClone:cFtpT			 := ::cFtpT
	oClone:cARQIMPRET	 	 := ::cARQIMPRET
	oClone:cNFSENAC		 	 := ::cNFSENAC 
	oClone:cNFSEDISTRDANFSE	 := ::cNFSEDISTRDANFSE
	Clone:DANFSE		 := ::DANFSE 
	Clone:XMLTSS		 := ::XMLTSS 
	oClone:oWSCONSCHVNFSE001RESULT :=  IIF(::oWSCONSCHVNFSE001RESULT = NIL , NIL ,::oWSCONSCHVNFSE001RESULT:Clone() )
	oClone:CHVNFSE 		 := ::CHVNFSE
	oClone:cNFSENAC      := ::cNFSENAC 
	oClone:cIMNAC        := ::cIMNAC 

	
	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSNFSE       := oClone:oWSNFSE
	oClone:oWSNFSID      := oClone:oWSNFSEARR
	oClone:oWSNF         := oClone:oWSNF
Return oClone

// WSDL Method CANCELANFSE001 of Service WSNFSE001

WSMETHOD CANCELANFSE001 WSSEND cUSERTOKEN,cID_ENT,oWSNFSE,cCODMUN WSRECEIVE oWSCANCELANFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CANCELANFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NFSE", ::oWSNFSE, oWSNFSE , "NFSE", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CANCELANFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CANCELANFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSCANCELANFSE001RESULT:SoapRecv( WSAdvValue( oXmlRet,"_CANCELANFSE001RESPONSE:_CANCELANFSE001RESULT","NFSESID",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CFGAMBNFSE001 of Service WSNFSE001

WSMETHOD CFGAMBNFSE001 WSSEND cUSERTOKEN,cID_ENT,nAMBIENTENFSE,nMODNFSE,cVERSAONFSE,cCODMUN,cCODSIAFI,cUSO,cMAXLOTE,cCNPJAUT,cENVSINC,cLOGIN,cPASS,cAUTORIZACAO,cChaveAutenticacao,cTOKENID,cCLIENTID,cCLIENTSECRET, cNFSENAC, cNFSEDISTRDANFSE, cIMNAC WSRECEIVE cCFGAMBNFSE001RESULT WSCLIENT WSNFSE001 
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CFGAMBNFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AMBIENTENFSE", ::nAMBIENTENFSE, nAMBIENTENFSE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("MODNFSE", ::nMODNFSE, nMODNFSE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("VERSAONFSE", ::cVERSAONFSE, cVERSAONFSE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODSIAFI", ::cCODSIAFI, cCODSIAFI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("USO", ::cUSO, cUSO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("MAXLOTE", ::cMAXLOTE, cMAXLOTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNPJAUT", ::cCNPJAUT, cCNPJAUT , "string", .F. , .F., 0 , NIL, .F.)
cSoap += WSSoapValue("ENVSINC", ::cENVSINC, cENVSINC , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LOGIN", ::cLOGIN, cLOGIN , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PASS", ::cPASS, cPASS , "base64Binary", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AUTORIZACAO", ::cAUTORIZACAO, cAUTORIZACAO , "base64Binary", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CHAVEAUTENTICACAO", ::cChaveAutenticacao , cChaveAutenticacao, "string", .F. , .F., 0 , NIL, .F.)
cSoap += WSSoapValue("TOKENID", ::cTOKENID, cTOKENID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLIENTID", ::cCLIENTID, cCLIENTID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLIENTSECRET", ::cCLIENTSECRET, cCLIENTSECRET , "string", .F. , .F., 0 , NIL, .F.,.F.)  
cSoap += WSSoapValue("NFSENAC", ::cNFSENAC , cNFSENAC, "string", .F. , .F., 0 , NIL, .F.,.F.)   
cSoap += WSSoapValue("NFSEDISTRDANFSE", ::cNFSEDISTRDANFSE , cNFSEDISTRDANFSE, "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IMNAC", ::cIMNAC , cIMNAC, "string", .F. , .F., 0 , NIL, .F.,.F.)   
cSoap += "</CFGAMBNFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CFGAMBNFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cCFGAMBNFSE001RESULT :=  WSAdvValue( oXmlRet,"_CFGAMBNFSE001RESPONSE:_CFGAMBNFSE001RESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CFGNFSECERTPFX of Service WSNFSE001

WSMETHOD CFGNFSECERTPFX WSSEND cUSERTOKEN,cID_ENT,cCERTIFICATE,cPASSWORD,cUSO WSRECEIVE cCFGNFSECERTPFXRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CFGNFSECERTPFX xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CERTIFICATE", ::cCERTIFICATE, cCERTIFICATE , "base64Binary", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, cPASSWORD , "base64Binary", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("USO", ::cUSO, cUSO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</CFGNFSECERTPFX>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CFGNFSECERTPFX",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cCFGNFSECERTPFXRESULT :=  WSAdvValue( oXmlRet,"_CFGNFSECERTPFXRESPONSE:_CFGNFSECERTPFXRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CFGREADYX of Service WSNFSE001

WSMETHOD CFGREADYX WSSEND cUSERTOKEN,cID_ENT,cCODMUN WSRECEIVE nCFGREADYXRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CFGREADYX xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CFGREADYX>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CFGREADYX",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::nCFGREADYXRESULT   :=  WSAdvValue( oXmlRet,"_CFGREADYXRESPONSE:_CFGREADYXRESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSLOTENFSE001 of Service WSNFSE001

WSMETHOD CONSLOTENFSE001 WSSEND cUSERTOKEN,cID_ENT,cCODMUN,cLOTE WSRECEIVE cCONSLOTENFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSLOTENFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LOTE", ::cLOTE, cLOTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSLOTENFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CONSLOTENFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cCONSLOTENFSE001RESULT :=  WSAdvValue( oXmlRet,"_CONSLOTENFSE001RESPONSE:_CONSLOTENFSE001RESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSNOTANFSE001 of Service WSNFSE001

WSMETHOD CONSNOTANFSE001 WSSEND cUSERTOKEN,cID_ENT,cCODMUN,dDATADE,dDATAATE WSRECEIVE oWSCONSNOTANFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSNOTANFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATADE", ::dDATADE, dDATADE , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAATE", ::dDATAATE, dDATAATE , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSNOTANFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CONSNOTANFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSCONSNOTANFSE001RESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSNOTANFSE001RESPONSE:_CONSNOTANFSE001RESULT","NFSE2",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CONSSEQNFSE001 of Service WSNFSE001

WSMETHOD CONSSEQNFSE001 WSSEND cUSERTOKEN,cID_ENT,cCODMUN WSRECEIVE cCONSSEQNFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSSEQNFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSSEQNFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CONSSEQNFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cCONSSEQNFSE001RESULT :=  WSAdvValue( oXmlRet,"_CONSSEQNFSE001RESPONSE:_CONSSEQNFSE001RESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GERAARQIMP of Service WSNFSE001

WSMETHOD GERAARQIMP WSSEND cUSERTOKEN,cID_ENT,cIDINICIAL,cIDFINAL,cDEST,dDATEDECL,lREPROC,dDATAINI,dDATAFIM,cFtpT WSRECEIVE cGERAARQIMPRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GERAARQIMP xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDINICIAL", ::cIDINICIAL, cIDINICIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDFINAL", ::cIDFINAL, cIDFINAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DEST", ::cDEST, cDEST , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATEDECL", ::dDATEDECL, dDATEDECL , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REPROC", ::lREPROC, lREPROC , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAINI", ::dDATAINI, dDATAINI , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAFIM", ::dDATAFIM, dDATAFIM , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TIPOFTP", ::cFtpT, cFtpT , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GERAARQIMP>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/GERAARQIMP",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cGERAARQIMPRESULT  :=  WSAdvValue( oXmlRet,"_GERAARQIMPRESPONSE:_GERAARQIMPRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GERAARQIMPARR of Service WSNFSE001

WSMETHOD GERAARQIMPARR WSSEND cUSERTOKEN,cID_ENT,oWSNFSEARR,cDEST,dDATEDECL,lREPROC,dDATAINI,dDATAFIM,cFTPT WSRECEIVE cGERAARQIMPARRRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GERAARQIMPARR xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NFSEARR", ::oWSNFSEARR, oWSNFSEARR , "NFSID", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DEST", ::cDEST, cDEST , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATEDECL", ::dDATEDECL, dDATEDECL , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REPROC", ::lREPROC, lREPROC , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAINI", ::dDATAINI, dDATAINI , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAFIM", ::dDATAFIM, dDATAFIM , "date", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TIPOFTP", ::cFtpT, cFtpT , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GERAARQIMPARR>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/GERAARQIMPARR",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cGERAARQIMPARRRESULT :=  WSAdvValue( oXmlRet,"_GERAARQIMPARRRESPONSE:_GERAARQIMPARRRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETMUNSIAF of Service WSNFSE001

WSMETHOD GETMUNSIAF WSSEND cUSERTOKEN,cCODMUN WSRECEIVE oWSGETMUNSIAFRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMUNSIAF xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETMUNSIAF>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/GETMUNSIAF",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSGETMUNSIAFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETMUNSIAFRESPONSE:_GETMUNSIAFRESULT","SIAFLISTRETURN",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method MONITORX of Service WSNFSE001

WSMETHOD MONITORX WSSEND cUSERTOKEN,cID_ENT,nTIPOMONITOR,cIDINICIAL,cIDFINAL,dDATADE,dDATAATE,cHORADE,cHORAATE,nTEMPO,nDIASPARAEXCLUSAO,cIDNOTAS,cCALLNAME WSRECEIVE oWSMONITORXRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<MONITORX xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TIPOMONITOR", ::nTIPOMONITOR, nTIPOMONITOR , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDINICIAL", ::cIDINICIAL, cIDINICIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDFINAL", ::cIDFINAL, cIDFINAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATADE", ::dDATADE, dDATADE , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATAATE", ::dDATAATE, dDATAATE , "date", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("HORADE", ::cHORADE, cHORADE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("HORAATE", ::cHORAATE, cHORAATE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TEMPO", ::nTEMPO, nTEMPO , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DIASPARAEXCLUSAO", ::nDIASPARAEXCLUSAO, nDIASPARAEXCLUSAO , "integer", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDNOTAS", ::cIDNOTAS, cIDNOTAS , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CALLNAME", ::cCALLNAME, cCALLNAME , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</MONITORX>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/MONITORX",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSMONITORXRESULT:SoapRecv( WSAdvValue( oXmlRet,"_MONITORXRESPONSE:_MONITORXRESULT","ARRAYOFMONITORNFSE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PROCIMPNFSETXT of Service WSNFSE001

WSMETHOD PROCIMPNFSETXT WSSEND cUSERTOKEN,cID_ENT,cCODMUN,cARQTXT,cDEST,cFtpT,cARQIMPRET WSRECEIVE cPROCIMPNFSETXTRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PROCIMPNFSETXT xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ARQTXT", ::cARQTXT, cARQTXT , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DEST", ::cDEST, cDEST , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TIPOFTP", ::cFtpT, cFtpT , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ARQIMPRET", ::cARQIMPRET, cARQIMPRET , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</PROCIMPNFSETXT>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/PROCIMPNFSETXT",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cPROCIMPNFSETXTRESULT :=  WSAdvValue( oXmlRet,"_PROCIMPNFSETXTRESPONSE:_PROCIMPNFSETXTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method REMESSANFSE001 of Service WSNFSE001

WSMETHOD REMESSANFSE001 WSSEND cUSERTOKEN,cID_ENT,oWSNFSE,cCODMUN,lREPROC WSRECEIVE oWSREMESSANFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<REMESSANFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NFSE", ::oWSNFSE, oWSNFSE , "NFSE", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REPROC", ::lREPROC, lREPROC , "boolean", .F. , .F., 0 , NIL, .F.) 
cSoap += "</REMESSANFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/REMESSANFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSREMESSANFSE001RESULT:SoapRecv( WSAdvValue( oXmlRet,"_REMESSANFSE001RESPONSE:_REMESSANFSE001RESULT","NFSESID",NIL,NIL,NIL,NIL,NIL,NIL) )
END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETMUNCANC of Service WSNFSE001

WSMETHOD RETMUNCANC WSSEND cUSERTOKEN WSRECEIVE cRETMUNCANCRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETMUNCANC xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</RETMUNCANC>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/RETMUNCANC",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cRETMUNCANCRESULT  :=  WSAdvValue( oXmlRet,"_RETMUNCANCRESPONSE:_RETMUNCANCRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETMUNSERV of Service WSNFSE001

WSMETHOD RETMUNSERV WSSEND cUSERTOKEN,cCSERVICO WSRECEIVE cRETMUNSERVRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETMUNSERV xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERVICO", ::cCSERVICO, cCSERVICO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</RETMUNSERV>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/RETMUNSERV",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cRETMUNSERVRESULT  :=  WSAdvValue( oXmlRet,"_RETMUNSERVRESPONSE:_RETMUNSERVRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RETORNANFSE of Service WSNFSE001

WSMETHOD RETORNANFSE WSSEND cUSERTOKEN,cID_ENT,oWSNFSEID,nDIASPARAEXCLUSAO WSRECEIVE oWSRETORNANFSERESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETORNANFSE xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NFSEID", ::oWSNFSEID, oWSNFSEID , "NFSID", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DIASPARAEXCLUSAO", ::nDIASPARAEXCLUSAO, nDIASPARAEXCLUSAO , "integer", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RETORNANFSE>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/RETORNANFSE",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSRETORNANFSERESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETORNANFSERESPONSE:_RETORNANFSERESULT","NFS5",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SCHEMAX of Service WSNFSE001

WSMETHOD SCHEMAX WSSEND cUSERTOKEN,cID_ENT,cCODMUN,oWSNF WSRECEIVE oWSSCHEMAXRESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SCHEMAX xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NF", ::oWSNF, oWSNF , "NF", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SCHEMAX>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/SCHEMAX",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSSCHEMAXRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SCHEMAXRESPONSE:_SCHEMAXRESULT","ARRAYOFNFSES4",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method STATUSNFSE of Service WSNFSE001

WSMETHOD STATUSNFSE WSSEND cUSERTOKEN,cIDTHREAD WSRECEIVE cSTATUSNFSERESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<STATUSNFSE xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("IDTHREAD", ::cIDTHREAD, cIDTHREAD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</STATUSNFSE>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/STATUSNFSE",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cSTATUSNFSERESULT  :=  WSAdvValue( oXmlRet,"_STATUSNFSERESPONSE:_STATUSNFSERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TSSCONSRPSNFSE of Service WSNFSE001

WSMETHOD TSSCONSRPSNFSE WSSEND cUSERTOKEN,cID_ENT,cCODMUN,cTSSID,cNUMERORPS,cSERIERPS,cTIPORPS WSRECEIVE oWSTSSCONSRPSNFSERESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TSSCONSRPSNFSE xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TSSID", ::cTSSID, cTSSID , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NUMERORPS", ::cNUMERORPS, cNUMERORPS , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("SERIERPS", ::cSERIERPS, cSERIERPS , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TIPORPS", ::cTIPORPS, cTIPORPS , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</TSSCONSRPSNFSE>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/TSSCONSRPSNFSE",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSTSSCONSRPSNFSERESULT:SoapRecv( WSAdvValue( oXmlRet,"_TSSCONSRPSNFSERESPONSE:_TSSCONSRPSNFSERESULT","TSSCONSRPSNFSERETURN",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VERSAONFSE001 of Service WSNFSE001

WSMETHOD VERSAONFSE001 WSSEND cUSERTOKEN,cCODMUN WSRECEIVE cVERSAONFSE001RESULT WSCLIENT WSNFSE001
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VERSAONFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODMUN", ::cCODMUN, cCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</VERSAONFSE001>"

oXmlRet := SvcSoapCall(	ObjSelf(Self),cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/VERSAONFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::cVERSAONFSE001RESULT :=  WSAdvValue( oXmlRet,"_VERSAONFSE001RESPONSE:_VERSAONFSE001RESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


WSMETHOD CONSCHVNFSE001 WSSEND cUSERTOKEN,cID_ENT,CHVNFSE WSRECEIVE oWSCONSCHVNFSE001RESULT WSCLIENT WSNFSE001 
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSCHVNFSE001 xmlns="http://webservices.totvs.com.br/nfse001.apw">'
cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ID_ENT", ::cID_ENT, cID_ENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CHVNFSE", ::CHVNFSE, CHVNFSE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSCHVNFSE001>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/nfse001.apw/CONSCHVNFSE001",; 
	"DOCUMENT","http://webservices.totvs.com.br/nfse001.apw",,"1.031217",; 
	"http://localhost:8080/NFSE001.apw")

::Init()
::oWSCONSCHVNFSE001RESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSCHVNFSE001RESPONSE:_CONSCHVNFSE001RESULT","CONSCHVNFSE001RETURN",NIL,NIL,NIL,NIL,NIL,NIL) )


END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure NFSE

WSSTRUCT NFSE001_NFSE
	WSDATA   oWSNOTAS                  AS NFSE001_ARRAYOFNFSES1
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSE
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSE
	Local oClone := NFSE001_NFSE():NEW()
	oClone:oWSNOTAS             := IIF(::oWSNOTAS = NIL , NIL , ::oWSNOTAS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NFSE
	Local cSoap := ""
	cSoap += WSSoapValue("NOTAS", ::oWSNOTAS, ::oWSNOTAS , "ARRAYOFNFSES1", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure NFSESID

WSSTRUCT NFSE001_NFSESID
	WSDATA   oWSID                     AS NFSE001_ARRAYOFSTRING OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSESID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSESID
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSESID
	Local oClone := NFSE001_NFSESID():NEW()
	oClone:oWSID                := IIF(::oWSID = NIL , NIL , ::oWSID:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSESID
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ID","ARRAYOFSTRING",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSID := NFSE001_ARRAYOFSTRING():New()
		::oWSID:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure NFSE2

WSSTRUCT NFSE001_NFSE2
	WSDATA   oWSNOTAS                  AS NFSE001_ARRAYOFNFSES2
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSE2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSE2
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSE2
	Local oClone := NFSE001_NFSE2():NEW()
	oClone:oWSNOTAS             := IIF(::oWSNOTAS = NIL , NIL , ::oWSNOTAS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSE2
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NOTAS","ARRAYOFNFSES2",NIL,"Property oWSNOTAS as s0:ARRAYOFNFSES2 on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNOTAS := NFSE001_ARRAYOFNFSES2():New()
		::oWSNOTAS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure NFSID

WSSTRUCT NFSE001_NFSID
	WSDATA   oWSNOTAS                  AS NFSE001_ARRAYOFNFSESID1
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSID
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSID
	Local oClone := NFSE001_NFSID():NEW()
	oClone:oWSNOTAS             := IIF(::oWSNOTAS = NIL , NIL , ::oWSNOTAS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NFSID
	Local cSoap := ""
	cSoap += WSSoapValue("NOTAS", ::oWSNOTAS, ::oWSNOTAS , "ARRAYOFNFSESID1", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure SIAFLISTRETURN

WSSTRUCT NFSE001_SIAFLISTRETURN
	WSDATA   cCODSERV                  AS string
	WSDATA   cCODSIAF                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_SIAFLISTRETURN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_SIAFLISTRETURN
Return

WSMETHOD CLONE WSCLIENT NFSE001_SIAFLISTRETURN
	Local oClone := NFSE001_SIAFLISTRETURN():NEW()
	oClone:cCODSERV             := ::cCODSERV
	oClone:cCODSIAF             := ::cCODSIAF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_SIAFLISTRETURN
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODSERV           :=  WSAdvValue( oResponse,"_CODSERV","string",NIL,"Property cCODSERV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODSIAF           :=  WSAdvValue( oResponse,"_CODSIAF","string",NIL,"Property cCODSIAF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return
// WSDL Data Structure ARRAYOFMONITORNFSE

WSSTRUCT NFSE001_ARRAYOFMONITORNFSE
	WSDATA   oWSMONITORNFSE            AS NFSE001_MONITORNFSE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFMONITORNFSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFMONITORNFSE
	::oWSMONITORNFSE       := {} // Array Of  NFSE001_MONITORNFSE():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFMONITORNFSE
	Local oClone := NFSE001_ARRAYOFMONITORNFSE():NEW()
	oClone:oWSMONITORNFSE := NIL
	If ::oWSMONITORNFSE <> NIL 
		oClone:oWSMONITORNFSE := {}
		aEval( ::oWSMONITORNFSE , { |x| aadd( oClone:oWSMONITORNFSE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFMONITORNFSE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_MONITORNFSE","MONITORNFSE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSMONITORNFSE , NFSE001_MONITORNFSE():New() )
			::oWSMONITORNFSE[len(::oWSMONITORNFSE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure NFS5

WSSTRUCT NFSE001_NFS5
	WSDATA   oWSNOTAS                  AS NFSE001_ARRAYOFNFSES5 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFS5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFS5
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFS5
	Local oClone := NFSE001_NFS5():NEW()
	oClone:oWSNOTAS             := IIF(::oWSNOTAS = NIL , NIL , ::oWSNOTAS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFS5
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_NOTAS","ARRAYOFNFSES5",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSNOTAS := NFSE001_ARRAYOFNFSES5():New()
		::oWSNOTAS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure NF

WSSTRUCT NFSE001_NF
	WSDATA   oWSNOTAS                  AS NFSE001_ARRAYOFNF001
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NF
Return

WSMETHOD CLONE WSCLIENT NFSE001_NF
	Local oClone := NFSE001_NF():NEW()
	oClone:oWSNOTAS             := IIF(::oWSNOTAS = NIL , NIL , ::oWSNOTAS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NF
	Local cSoap := ""
	cSoap += WSSoapValue("NOTAS", ::oWSNOTAS, ::oWSNOTAS , "ARRAYOFNF001", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFNFSES4

WSSTRUCT NFSE001_ARRAYOFNFSES4
	WSDATA   oWSNFSES4                 AS NFSE001_NFSES4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNFSES4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNFSES4
	::oWSNFSES4            := {} // Array Of  NFSE001_NFSES4():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNFSES4
	Local oClone := NFSE001_ARRAYOFNFSES4():NEW()
	oClone:oWSNFSES4 := NIL
	If ::oWSNFSES4 <> NIL 
		oClone:oWSNFSES4 := {}
		aEval( ::oWSNFSES4 , { |x| aadd( oClone:oWSNFSES4 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFNFSES4
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NFSES4","NFSES4",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNFSES4 , NFSE001_NFSES4():New() )
			::oWSNFSES4[len(::oWSNFSES4)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TSSCONSRPSNFSERETURN

WSSTRUCT NFSE001_TSSCONSRPSNFSERETURN
	WSDATA   nAMBIENTE                 AS integer
	WSDATA   cCODIGOAUTH               AS string
	WSDATA   cID                       AS string
	WSDATA   cNOTA                     AS string
	WSDATA   cRPS                      AS string
	WSDATA   cSERIERPS                 AS string
	WSDATA   cSTATUSNFSE               AS string
	WSDATA   cXMLRETPREF               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_TSSCONSRPSNFSERETURN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_TSSCONSRPSNFSERETURN
Return

WSMETHOD CLONE WSCLIENT NFSE001_TSSCONSRPSNFSERETURN
	Local oClone := NFSE001_TSSCONSRPSNFSERETURN():NEW()
	oClone:nAMBIENTE            := ::nAMBIENTE
	oClone:cCODIGOAUTH          := ::cCODIGOAUTH
	oClone:cID                  := ::cID
	oClone:cNOTA                := ::cNOTA
	oClone:cRPS                 := ::cRPS
	oClone:cSERIERPS            := ::cSERIERPS
	oClone:cSTATUSNFSE          := ::cSTATUSNFSE
	oClone:cXMLRETPREF          := ::cXMLRETPREF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_TSSCONSRPSNFSERETURN
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","integer",NIL,"Property nAMBIENTE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCODIGOAUTH        :=  WSAdvValue( oResponse,"_CODIGOAUTH","string",NIL,"Property cCODIGOAUTH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOTA              :=  WSAdvValue( oResponse,"_NOTA","string",NIL,"Property cNOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRPS               :=  WSAdvValue( oResponse,"_RPS","string",NIL,"Property cRPS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERIERPS          :=  WSAdvValue( oResponse,"_SERIERPS","string",NIL,"Property cSERIERPS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUSNFSE        :=  WSAdvValue( oResponse,"_STATUSNFSE","string",NIL,"Property cSTATUSNFSE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLRETPREF        :=  WSAdvValue( oResponse,"_XMLRETPREF","string",NIL,"Property cXMLRETPREF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFNFSES1

WSSTRUCT NFSE001_ARRAYOFNFSES1
	WSDATA   oWSNFSES1                 AS NFSE001_NFSES1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNFSES1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNFSES1
	::oWSNFSES1            := {} // Array Of  NFSE001_NFSES1():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNFSES1
	Local oClone := NFSE001_ARRAYOFNFSES1():NEW()
	oClone:oWSNFSES1 := NIL
	If ::oWSNFSES1 <> NIL 
		oClone:oWSNFSES1 := {}
		aEval( ::oWSNFSES1 , { |x| aadd( oClone:oWSNFSES1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_ARRAYOFNFSES1
	Local cSoap := ""
	aEval( ::oWSNFSES1 , {|x| cSoap := cSoap  +  WSSoapValue("NFSES1", x , x , "NFSES1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFSTRING

WSSTRUCT NFSE001_ARRAYOFSTRING
	WSDATA   cSTRING                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFSTRING
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFSTRING
	::cSTRING              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFSTRING
	Local oClone := NFSE001_ARRAYOFSTRING():NEW()
	oClone:cSTRING              := IIf(::cSTRING <> NIL , aClone(::cSTRING) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFSTRING
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cSTRING ,  x:TEXT  ) } )
Return

// WSDL Data Structure ARRAYOFNFSES2

WSSTRUCT NFSE001_ARRAYOFNFSES2
	WSDATA   oWSNFSES2                 AS NFSE001_NFSES2 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNFSES2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNFSES2
	::oWSNFSES2            := {} // Array Of  NFSE001_NFSES2():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNFSES2
	Local oClone := NFSE001_ARRAYOFNFSES2():NEW()
	oClone:oWSNFSES2 := NIL
	If ::oWSNFSES2 <> NIL 
		oClone:oWSNFSES2 := {}
		aEval( ::oWSNFSES2 , { |x| aadd( oClone:oWSNFSES2 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFNFSES2
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NFSES2","NFSES2",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNFSES2 , NFSE001_NFSES2():New() )
			::oWSNFSES2[len(::oWSNFSES2)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFNFSESID1

WSSTRUCT NFSE001_ARRAYOFNFSESID1
	WSDATA   oWSNFSESID1               AS NFSE001_NFSESID1 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNFSESID1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNFSESID1
	::oWSNFSESID1          := {} // Array Of  NFSE001_NFSESID1():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNFSESID1
	Local oClone := NFSE001_ARRAYOFNFSESID1():NEW()
	oClone:oWSNFSESID1 := NIL
	If ::oWSNFSESID1 <> NIL 
		oClone:oWSNFSESID1 := {}
		aEval( ::oWSNFSESID1 , { |x| aadd( oClone:oWSNFSESID1 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_ARRAYOFNFSESID1
	Local cSoap := ""
	aEval( ::oWSNFSESID1 , {|x| cSoap := cSoap  +  WSSoapValue("NFSESID1", x , x , "NFSESID1", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure MONITORNFSE

WSSTRUCT NFSE001_MONITORNFSE
	WSDATA   nAMBIENTE                 AS integer
	WSDATA   oWSERRO                   AS NFSE001_ARRAYOFERROSLOTE OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   nMODALIDADE               AS integer
	WSDATA   oWSNFE                    AS NFSE001_NFSEXML OPTIONAL
	WSDATA   oWSNFECANCELADA           AS NFSE001_NFSEXML OPTIONAL
	WSDATA   cNOTA                     AS string
	WSDATA   cPROTOCOLO                AS string OPTIONAL
	WSDATA   cRECOMENDACAO             AS string
	WSDATA   cRPS                      AS string
	WSDATA   nSTATUS                   AS integer
	WSDATA   nSTATUSCANC               AS integer
	WSDATA   cURLNFSE                  AS base64Binary OPTIONAL
	WSDATA   cXMLRETTSS                AS string OPTIONAL
	WSDATA	 CDATAHORA                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_MONITORNFSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_MONITORNFSE
Return

WSMETHOD CLONE WSCLIENT NFSE001_MONITORNFSE
	Local oClone := NFSE001_MONITORNFSE():NEW()
	oClone:nAMBIENTE            := ::nAMBIENTE
	oClone:oWSERRO              := IIF(::oWSERRO = NIL , NIL , ::oWSERRO:Clone() )
	oClone:cID                  := ::cID
	oClone:nMODALIDADE          := ::nMODALIDADE
	oClone:oWSNFE               := IIF(::oWSNFE = NIL , NIL , ::oWSNFE:Clone() )
	oClone:oWSNFECANCELADA      := IIF(::oWSNFECANCELADA = NIL , NIL , ::oWSNFECANCELADA:Clone() )
	oClone:cNOTA                := ::cNOTA
	oClone:cPROTOCOLO           := ::cPROTOCOLO
	oClone:cRECOMENDACAO        := ::cRECOMENDACAO
	oClone:cRPS                 := ::cRPS
	oClone:nSTATUS              := ::nSTATUS
	oClone:nSTATUSCANC          := ::nSTATUSCANC
	oClone:cURLNFSE             := ::cURLNFSE
	oClone:cXMLRETTSS           := ::cXMLRETTSS
	oClone:CDATAHORA          	:= ::CDATAHORA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_MONITORNFSE
	Local oNode2
	Local oNode5
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","integer",NIL,"Property nAMBIENTE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ERRO","ARRAYOFERROSLOTE",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSERRO := NFSE001_ARRAYOFERROSLOTE():New()
		::oWSERRO:SoapRecv(oNode2)
	EndIf
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nMODALIDADE        :=  WSAdvValue( oResponse,"_MODALIDADE","integer",NIL,"Property nMODALIDADE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_NFE","NFSEXML",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSNFE := NFSE001_NFSEXML():New()
		::oWSNFE:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_NFECANCELADA","NFSEXML",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSNFECANCELADA := NFSE001_NFSEXML():New()
		::oWSNFECANCELADA:SoapRecv(oNode6)
	EndIf
	::cNOTA              :=  WSAdvValue( oResponse,"_NOTA","string",NIL,"Property cNOTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPROTOCOLO         :=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRECOMENDACAO      :=  WSAdvValue( oResponse,"_RECOMENDACAO","string",NIL,"Property cRECOMENDACAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRPS               :=  WSAdvValue( oResponse,"_RPS","string",NIL,"Property cRPS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSTATUS            :=  WSAdvValue( oResponse,"_STATUS","integer",NIL,"Property nSTATUS as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSTATUSCANC        :=  WSAdvValue( oResponse,"_STATUSCANC","integer",NIL,"Property nSTATUSCANC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cURLNFSE           :=  WSAdvValue( oResponse,"_URLNFSE","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cXMLRETTSS         :=  WSAdvValue( oResponse,"_XMLRETTSS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::CDATAHORA        	 :=  WSAdvValue( oResponse,"_CDATAHORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFNFSES5

WSSTRUCT NFSE001_ARRAYOFNFSES5
	WSDATA   oWSNFSES5                 AS NFSE001_NFSES5 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNFSES5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNFSES5
	::oWSNFSES5            := {} // Array Of  NFSE001_NFSES5():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNFSES5
	Local oClone := NFSE001_ARRAYOFNFSES5():NEW()
	oClone:oWSNFSES5 := NIL
	If ::oWSNFSES5 <> NIL 
		oClone:oWSNFSES5 := {}
		aEval( ::oWSNFSES5 , { |x| aadd( oClone:oWSNFSES5 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFNFSES5
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NFSES5","NFSES5",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNFSES5 , NFSE001_NFSES5():New() )
			::oWSNFSES5[len(::oWSNFSES5)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFNF001

WSSTRUCT NFSE001_ARRAYOFNF001
	WSDATA   oWSNF001                  AS NFSE001_NF001 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFNF001
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFNF001
	::oWSNF001             := {} // Array Of  NFSE001_NF001():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFNF001
	Local oClone := NFSE001_ARRAYOFNF001():NEW()
	oClone:oWSNF001 := NIL
	If ::oWSNF001 <> NIL 
		oClone:oWSNF001 := {}
		aEval( ::oWSNF001 , { |x| aadd( oClone:oWSNF001 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_ARRAYOFNF001
	Local cSoap := ""
	aEval( ::oWSNF001 , {|x| cSoap := cSoap  +  WSSoapValue("NF001", x , x , "NF001", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure NFSES4

WSSTRUCT NFSE001_NFSES4
	WSDATA   cID                       AS string
	WSDATA   cMENSAGEM                 AS string OPTIONAL
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSES4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSES4
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSES4
	Local oClone := NFSE001_NFSES4():NEW()
	oClone:cID                  := ::cID
	oClone:cMENSAGEM            := ::cMENSAGEM
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSES4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,"Property cXML as s:base64Binary on SOAP Response not found.",NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure NFSES1

WSSTRUCT NFSE001_NFSES1
	WSDATA   cCODCANC                  AS string OPTIONAL
	WSDATA   cCODMUN                   AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   cMOTCANC                  AS string OPTIONAL
	WSDATA   cNFSECANCELADA            AS string OPTIONAL
	WSDATA   lREPROC                   AS boolean OPTIONAL
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSES1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSES1
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSES1
	Local oClone := NFSE001_NFSES1():NEW()
	oClone:cCODCANC             := ::cCODCANC
	oClone:cCODMUN              := ::cCODMUN
	oClone:cID                  := ::cID
	oClone:cMOTCANC             := ::cMOTCANC
	oClone:cNFSECANCELADA       := ::cNFSECANCELADA
	oClone:lREPROC              := ::lREPROC
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NFSES1
	Local cSoap := ""
	cSoap += WSSoapValue("CODCANC", ::cCODCANC, ::cCODCANC , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODMUN", ::cCODMUN, ::cCODMUN , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("MOTCANC", ::cMOTCANC, ::cMOTCANC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NFSECANCELADA", ::cNFSECANCELADA, ::cNFSECANCELADA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REPROC", ::lREPROC, ::lREPROC , "boolean", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure NFSES2

WSSTRUCT NFSE001_NFSES2
	WSDATA   cCODMUN                   AS string OPTIONAL
	WSDATA   cNUMNOTA                  AS string OPTIONAL
	WSDATA   cSITUACAO                 AS string OPTIONAL
	WSDATA   cSTATUS1                  AS string OPTIONAL
	WSDATA   cSTATUS2                  AS string OPTIONAL
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSES2
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSES2
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSES2
	Local oClone := NFSE001_NFSES2():NEW()
	oClone:cCODMUN              := ::cCODMUN
	oClone:cNUMNOTA             := ::cNUMNOTA
	oClone:cSITUACAO            := ::cSITUACAO
	oClone:cSTATUS1             := ::cSTATUS1
	oClone:cSTATUS2             := ::cSTATUS2
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSES2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODMUN            :=  WSAdvValue( oResponse,"_CODMUN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNUMNOTA           :=  WSAdvValue( oResponse,"_NUMNOTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSITUACAO          :=  WSAdvValue( oResponse,"_SITUACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS1           :=  WSAdvValue( oResponse,"_STATUS1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSTATUS2           :=  WSAdvValue( oResponse,"_STATUS2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure NFSESID1

WSSTRUCT NFSE001_NFSESID1
	WSDATA   cID                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSESID1
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSESID1
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSESID1
	Local oClone := NFSE001_NFSESID1():NEW()
	oClone:cID                  := ::cID
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NFSESID1
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFERROSLOTE

WSSTRUCT NFSE001_ARRAYOFERROSLOTE
	WSDATA   oWSERROSLOTE              AS NFSE001_ERROSLOTE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ARRAYOFERROSLOTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ARRAYOFERROSLOTE
	::oWSERROSLOTE         := {} // Array Of  NFSE001_ERROSLOTE():New()
Return

WSMETHOD CLONE WSCLIENT NFSE001_ARRAYOFERROSLOTE
	Local oClone := NFSE001_ARRAYOFERROSLOTE():NEW()
	oClone:oWSERROSLOTE := NIL
	If ::oWSERROSLOTE <> NIL 
		oClone:oWSERROSLOTE := {}
		aEval( ::oWSERROSLOTE , { |x| aadd( oClone:oWSERROSLOTE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ARRAYOFERROSLOTE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERROSLOTE","ERROSLOTE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSERROSLOTE , NFSE001_ERROSLOTE():New() )
			::oWSERROSLOTE[len(::oWSERROSLOTE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure NFSEXML

WSSTRUCT NFSE001_NFSEXML
	WSDATA   cXML                      AS string OPTIONAL
	WSDATA   cXMLCOMPL                 AS string OPTIONAL
	WSDATA   cXMLERP                   AS string OPTIONAL
	WSDATA   cXMLPROT                  AS string OPTIONAL
	WSDATA   CDATAHORA                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSEXML
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSEXML
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSEXML
	Local oClone := NFSE001_NFSEXML():NEW()
	oClone:cXML                 := ::cXML
	oClone:cXMLCOMPL            := ::cXMLCOMPL
	oClone:cXMLERP              := ::cXMLERP
	oClone:cXMLPROT             := ::cXMLPROT
	oClone:CDATAHORA			:= ::CDATAHORA
	oClone:DANFSE				:= ::DANFSE
	oClone:XMLTSS				:= ::XMLTSS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSEXML
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cXML               :=  WSAdvValue( oResponse,"_XML","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLCOMPL          :=  WSAdvValue( oResponse,"_XMLCOMPL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLERP            :=  WSAdvValue( oResponse,"_XMLERP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLPROT           :=  WSAdvValue( oResponse,"_XMLPROT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::CDATAHORA          :=  WSAdvValue( oResponse,"_CDATAHORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure NFSES5

WSSTRUCT NFSE001_NFSES5
	WSDATA   cID                       AS string
	WSDATA   oWSNFE                    AS NFSE001_NFSEPROTOCOLO
	WSDATA   oWSNFECANCELADA           AS NFSE001_NFSEPROTOCOLO OPTIONAL
	WSDATA   cNUMNSE                   AS string OPTIONAL
	WSDATA   cXMLRETTSS                AS string OPTIONAL
	WSDATA   CDATAHORA 	               AS string OPTIONAL
	WSDATA   DANFSE		           	   AS string OPTIONAL
	WSDATA   XMLTSS		           	   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSES5
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSES5
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSES5
	Local oClone := NFSE001_NFSES5():NEW()
	oClone:cID                  := ::cID
	oClone:oWSNFE               := IIF(::oWSNFE = NIL , NIL , ::oWSNFE:Clone() )
	oClone:oWSNFECANCELADA      := IIF(::oWSNFECANCELADA = NIL , NIL , ::oWSNFECANCELADA:Clone() )
	oClone:cNUMNSE              := ::cNUMNSE
	oClone:cXMLRETTSS           := ::cXMLRETTSS
	oClone:CDATAHORA            := ::CDATAHORA
	oClone:DANFSE		        := ::DANFSE
	oClone:XMLTSS		        := ::XMLTSS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSES5
	Local oNode2
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_NFE","NFSEPROTOCOLO",NIL,"Property oWSNFE as s0:NFSEPROTOCOLO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSNFE := NFSE001_NFSEPROTOCOLO():New()
		::oWSNFE:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_NFECANCELADA","NFSEPROTOCOLO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode3 != NIL
		::oWSNFECANCELADA := NFSE001_NFSEPROTOCOLO():New()
		::oWSNFECANCELADA:SoapRecv(oNode3)
	EndIf
	::cNUMNSE            :=  WSAdvValue( oResponse,"_NUMNSE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLRETTSS         :=  WSAdvValue( oResponse,"_XMLRETTSS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::CDATAHORA	         :=  WSAdvValue( oResponse,"_CDATAHORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::DANFSE	         :=  WSAdvValue( oResponse,"_DANFSE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::XMLTSS	         :=  WSAdvValue( oResponse,"_XMLTSS","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure NF001

WSSTRUCT NFSE001_NF001
	WSDATA   cID                       AS string
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NF001
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NF001
Return

WSMETHOD CLONE WSCLIENT NFSE001_NF001
	Local oClone := NFSE001_NF001():NEW()
	oClone:cID                  := ::cID
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT NFSE001_NF001
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ERROSLOTE

WSSTRUCT NFSE001_ERROSLOTE
	WSDATA   cCODIGO                   AS string
	WSDATA   cMENSAGEM                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_ERROSLOTE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_ERROSLOTE
Return

WSMETHOD CLONE WSCLIENT NFSE001_ERROSLOTE
	Local oClone := NFSE001_ERROSLOTE():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cMENSAGEM            := ::cMENSAGEM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_ERROSLOTE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMENSAGEM          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure NFSEPROTOCOLO

WSSTRUCT NFSE001_NFSEPROTOCOLO
	WSDATA   cPROTOCOLO                AS string OPTIONAL
	WSDATA   cXML                      AS string
	WSDATA   cXMLCOMPL                 AS string OPTIONAL
	WSDATA   cXMLERP                   AS string OPTIONAL
	WSDATA   cXMLPROT                  AS string OPTIONAL
	WSDATA   CDATAHORA                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_NFSEPROTOCOLO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_NFSEPROTOCOLO
Return

WSMETHOD CLONE WSCLIENT NFSE001_NFSEPROTOCOLO
	Local oClone := NFSE001_NFSEPROTOCOLO():NEW()
	oClone:cPROTOCOLO           := ::cPROTOCOLO
	oClone:cXML                 := ::cXML
	oClone:cXMLCOMPL            := ::cXMLCOMPL
	oClone:cXMLERP              := ::cXMLERP
	oClone:cXMLPROT             := ::cXMLPROT
	oClone:CDATAHORA            := ::CDATAHORA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_NFSEPROTOCOLO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPROTOCOLO         :=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXML               :=  WSAdvValue( oResponse,"_XML","string",NIL,"Property cXML as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLCOMPL          :=  WSAdvValue( oResponse,"_XMLCOMPL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLERP            :=  WSAdvValue( oResponse,"_XMLERP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLPROT           :=  WSAdvValue( oResponse,"_XMLPROT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::CDATAHORA          :=  WSAdvValue( oResponse,"_CDATAHORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure CONSCHVNFSE001RETURN 

WSSTRUCT NFSE001_CONSCHVNFSE001RETURN  
	WSDATA ID            AS STRING
	WSDATA AMBIENTE      AS INTEGER
	WSDATA VERSAO        AS STRING
	WSDATA RECBTO        AS STRING OPTIONAL
	WSDATA PROTOCOLO     AS STRING OPTIONAL
	WSDATA CODRETNFE     AS STRING OPTIONAL
	WSDATA MSGRETNFE     AS STRING OPTIONAL
	WSDATA DIGVAL        AS STRING OPTIONAL
	WSDATA XML_RET       AS STRING OPTIONAL
	WSDATA PDF_RET       AS STRING OPTIONAL
	WSDATA RECBTOTM      AS STRING OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NFSE001_CONSCHVNFSE001RETURN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NFSE001_CONSCHVNFSE001RETURN
Return

WSMETHOD CLONE WSCLIENT NFSE001_CONSCHVNFSE001RETURN
	Local oClone := NFSE001_CONSCHVNFSE001RETURN():NEW()
	oClone:ID            	:= ::cID
	oClone:AMBIENTE         := ::cAMBIENTE
	oClone:VERSAO          	:= ::cVERSAO
	oClone:RECBTO			:= ::cRECBTO
	oClone:PROTOCOLO		:= ::cPROTOCOLO
	oClone:CODRETNFE		:= ::cCODRETNFE
	oClone:MSGRETNFE		:= ::cMSGRETNFE
	oClone:DIGVAL			:= ::cDIGVAL
	oClone:PDF_RET			:= ::cPDF_RET
	oClone:XML_RET			:= ::cXML_RET
	oClone:RECBTOTM			:= ::cRECBTOTM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NFSE001_CONSCHVNFSE001RETURN 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ID          	:=  WSAdvValue( oResponse,"_ID","string",NIL,"Property ID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::XML_RET       :=  WSAdvValue( oResponse,"_XML_RET","string",NIL,"Property XML_RET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::PDF_RET       :=  WSAdvValue( oResponse,"_PDF_RET","string",NIL,"Property cPDF_RET as s:string on SOAP Response not found.",NIL,"S",NIL,NIL)
	::AMBIENTE		:=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::VERSAO		:=  WSAdvValue( oResponse,"_VERSAO","string",NIL,"Property cVERSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::RECBTO		:=  WSAdvValue( oResponse,"_RECBTO","string",NIL,"Property cRECBTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::PROTOCOLO		:=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,"Property cPROTOCOLO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::CODRETNFE		:=  WSAdvValue( oResponse,"_CODRETNFE","string",NIL,"Property cCODRETNFE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::MSGRETNFE		:=  WSAdvValue( oResponse,"_MSGRETNFE","string",NIL,"Property cMSGRETNFE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::DIGVAL		:=  WSAdvValue( oResponse,"_DIGVAL","string",NIL,"Property cDIGVAL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::RECBTOTM		:=  WSAdvValue( oResponse,"_RECBTOTM","string",NIL,"Property cRECBTOTM as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

