#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/CostCenterIntegrationServiceBean?wsdl
Gerado em        12/18/18 10:33:28
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TKHWPJO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCostCenterIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSCostCenterIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertOrUpdate
	WSMETHOD remove

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0                   AS CostCenterIntegrationServiceBeanService_costCenterDTO
	WSDATA   oWScostCenterDTO          AS CostCenterIntegrationServiceBeanService_costCenterDTO
	WSDATA   oWSstatusDTO              AS CostCenterIntegrationServiceBeanService_statusDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCostCenterIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCostCenterIntegrationServiceBeanService
	::oWSarg0            := {} // Array Of  CostCenterIntegrationServiceBeanService_COSTCENTERDTO():New()
	::oWScostCenterDTO   := {} // Array Of  CostCenterIntegrationServiceBeanService_COSTCENTERDTO():New()
	::oWSstatusDTO       := {} // Array Of  CostCenterIntegrationServiceBeanService_STATUSDTO():New()
Return

WSMETHOD RESET WSCLIENT WSCostCenterIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0            := NIL 
	::oWScostCenterDTO   := NIL 
	::oWSstatusDTO       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCostCenterIntegrationServiceBeanService
Local oClone := WSCostCenterIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWScostCenterDTO :=  IIF(::oWScostCenterDTO = NIL , NIL ,::oWScostCenterDTO:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
Return oClone

// WSDL Method insertOrUpdate of Service WSCostCenterIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWScostCenterDTO WSCLIENT WSCostCenterIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://costcenter.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "costCenterDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://costcenter.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/CostCenterIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","costCenterDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWScostCenterDTO,CostCenterIntegrationServiceBeanService_costCenterDTO():New()) , ::oWScostCenterDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSCostCenterIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSCostCenterIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://costcenter.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://costcenter.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/CostCenterIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,CostCenterIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure costCenterDTO

WSSTRUCT CostCenterIntegrationServiceBeanService_costCenterDTO
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

WSMETHOD NEW WSCLIENT CostCenterIntegrationServiceBeanService_costCenterDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CostCenterIntegrationServiceBeanService_costCenterDTO
Return

WSMETHOD CLONE WSCLIENT CostCenterIntegrationServiceBeanService_costCenterDTO
	Local oClone := CostCenterIntegrationServiceBeanService_costCenterDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT CostCenterIntegrationServiceBeanService_costCenterDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CostCenterIntegrationServiceBeanService_costCenterDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure statusDTO

WSSTRUCT CostCenterIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CostCenterIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CostCenterIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT CostCenterIntegrationServiceBeanService_statusDTO
	Local oClone := CostCenterIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT CostCenterIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


