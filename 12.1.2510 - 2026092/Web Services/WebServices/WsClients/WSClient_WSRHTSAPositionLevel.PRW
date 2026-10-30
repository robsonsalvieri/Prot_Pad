#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/PositionLevelIntegrationServiceBean?wsdl
Gerado em        12/18/18 09:04:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _HJPPGLY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPositionLevelIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSPositionLevelIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD remove
	WSMETHOD insertOrUpdate

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSstatusDTO              AS PositionLevelIntegrationServiceBeanService_statusDTO
	WSDATA   oWSarg0                   AS PositionLevelIntegrationServiceBeanService_statusDTO
	WSDATA   oWSpositionLevelDTO       AS PositionLevelIntegrationServiceBeanService_positionLevelDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPositionLevelIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPositionLevelIntegrationServiceBeanService
	::oWSstatusDTO       := {} // Array Of  PositionLevelIntegrationServiceBeanService_STATUSDTO():New()
	::oWSpositionLevelDTO := {} // Array Of  PositionLevelIntegrationServiceBeanService_POSITIONLEVELDTO():New()
	::oWSarg0            := {} // Array Of  PositionLevelIntegrationServiceBeanService_STATUSDTO():New()
	
Return

WSMETHOD RESET WSCLIENT WSPositionLevelIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSstatusDTO       := NIL 
	::oWSpositionLevelDTO := NIL 
	::oWSarg0            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPositionLevelIntegrationServiceBeanService
Local oClone := WSPositionLevelIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSpositionLevelDTO :=  IIF(::oWSpositionLevelDTO = NIL , NIL ,::oWSpositionLevelDTO:Clone() )
Return oClone

// WSDL Method remove of Service WSPositionLevelIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSPositionLevelIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://positionlevel.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://positionlevel.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/PositionLevelIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,PositionLevelIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSPositionLevelIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSpositionLevelDTO WSCLIENT WSPositionLevelIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://positionlevel.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "positionLevelDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://positionlevel.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/PositionLevelIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","positionLevelDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSpositionLevelDTO,PositionLevelIntegrationServiceBeanService_positionLevelDTO():New()) , ::oWSpositionLevelDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure statusDTO

WSSTRUCT PositionLevelIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PositionLevelIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PositionLevelIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT PositionLevelIntegrationServiceBeanService_statusDTO
	Local oClone := PositionLevelIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PositionLevelIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure positionLevelDTO

WSSTRUCT PositionLevelIntegrationServiceBeanService_positionLevelDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PositionLevelIntegrationServiceBeanService_positionLevelDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PositionLevelIntegrationServiceBeanService_positionLevelDTO
Return

WSMETHOD CLONE WSCLIENT PositionLevelIntegrationServiceBeanService_positionLevelDTO
	Local oClone := PositionLevelIntegrationServiceBeanService_positionLevelDTO():NEW()
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription

Return oClone

WSMETHOD SOAPSEND WSCLIENT PositionLevelIntegrationServiceBeanService_positionLevelDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 

	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PositionLevelIntegrationServiceBeanService_positionLevelDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


