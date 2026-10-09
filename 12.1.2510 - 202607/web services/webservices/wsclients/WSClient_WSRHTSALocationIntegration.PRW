#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb-11.5.0/LocationIntegrationServiceBean?wsdl
Gerado em        06/13/11 19:10:12
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CNOOXKM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLocationIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSLocationIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertOrUpdate
	WSMETHOD remove

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0                   AS LocationIntegrationServiceBeanService_locationDTO
	WSDATA   oWSlocationDTO            AS LocationIntegrationServiceBeanService_locationDTO
	WSDATA   oWSstatusDTO              AS LocationIntegrationServiceBeanService_statusDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLocationIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLocationIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0            := {} // Array Of  LocationIntegrationServiceBeanService_LOCATIONDTO():New()
	::oWSlocationDTO     := {} // Array Of  LocationIntegrationServiceBeanService_LOCATIONDTO():New()
	::oWSstatusDTO       := {} // Array Of  LocationIntegrationServiceBeanService_STATUSDTO():New()
Return

WSMETHOD RESET WSCLIENT WSLocationIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0            := NIL 
	::oWSlocationDTO     := NIL 
	::oWSstatusDTO       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLocationIntegrationServiceBeanService
Local oClone := WSLocationIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSlocationDTO :=  IIF(::oWSlocationDTO = NIL , NIL ,::oWSlocationDTO:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
Return oClone

// WSDL Method insertOrUpdate of Service WSLocationIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSlocationDTO WSCLIENT WSLocationIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://location.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "locationDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://location.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/LocationIntegrationServiceBean")

oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","locationDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSlocationDTO,LocationIntegrationServiceBeanService_locationDTO():New()) , ::oWSlocationDTO[y]:SoapRecv(x) ) })
Endif


END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSLocationIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSLocationIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<remove xmlns="http://location.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://location.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/LocationIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,LocationIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure locationDTO

WSSTRUCT LocationIntegrationServiceBeanService_locationDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   ccity                     AS string OPTIONAL
	WSDATA   ccityCode                 AS string OPTIONAL
	WSDATA   ccountry                  AS string OPTIONAL
	WSDATA   ccountryCode              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cstate                    AS string OPTIONAL
	WSDATA   cstateCode                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LocationIntegrationServiceBeanService_locationDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LocationIntegrationServiceBeanService_locationDTO
Return

WSMETHOD CLONE WSCLIENT LocationIntegrationServiceBeanService_locationDTO
	Local oClone := LocationIntegrationServiceBeanService_locationDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:ccity                := ::ccity
	oClone:ccityCode            := ::ccityCode
	oClone:ccountry             := ::ccountry
	oClone:ccountryCode         := ::ccountryCode
	oClone:cexternalKey         := ::cexternalKey
	oClone:cstate               := ::cstate
	oClone:cstateCode           := ::cstateCode
Return oClone

WSMETHOD SOAPSEND WSCLIENT LocationIntegrationServiceBeanService_locationDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("city", ::ccity, ::ccity , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("cityCode", ::ccityCode, ::ccityCode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("country", ::ccountry, ::ccountry , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("countryCode", ::ccountryCode, ::ccountryCode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("state", ::cstate, ::cstate , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("stateCode", ::cstateCode, ::cstateCode , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LocationIntegrationServiceBeanService_locationDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccity              :=  WSAdvValue( oResponse,"_CITY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccityCode          :=  WSAdvValue( oResponse,"_CITYCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccountry           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccountryCode       :=  WSAdvValue( oResponse,"_COUNTRYCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstate             :=  WSAdvValue( oResponse,"_STATE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstateCode         :=  WSAdvValue( oResponse,"_STATECODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure statusDTO

WSSTRUCT LocationIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LocationIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LocationIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT LocationIntegrationServiceBeanService_statusDTO
	Local oClone := LocationIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LocationIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


