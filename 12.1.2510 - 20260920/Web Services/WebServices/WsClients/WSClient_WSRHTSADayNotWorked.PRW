#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean?wsdl
Gerado em        12/18/18 10:39:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LLFSGKN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSDayNotWorkedIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSDayNotWorkedIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD remove
	WSMETHOD insertLocationDayNotWorkedWildcard
	WSMETHOD removeLocationDayNotWorkedWildcard
	WSMETHOD insertOrUpdateIncrement
	WSMETHOD insertLocationDayNotWorked
	WSMETHOD insertOrUpdate
	WSMETHOD removeLocationDayNotWorked
	WSMETHOD insertOrUpdateWildcard
	WSMETHOD insertOrUpdateList

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0		           AS DayNotWorkedIntegrationServiceBeanService_statusDTO
	WSDATA   oWSstatusDTO              AS DayNotWorkedIntegrationServiceBeanService_statusDTO
	WSDATA   oWSdayNotWorked           AS DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	WSDATA   oWSlocationDayNotWorkedDTO AS DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	WSDATA   oWSdayNotWorkedDTO        AS DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
	::oWSarg0		     := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_STATUSDTO():New()
	::oWSstatusDTO       := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_STATUSDTO():New()
	::oWSdayNotWorked    := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_LOCATIONDAYNOTWORKEDDTO():New()
	::oWSlocationDayNotWorkedDTO := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_LOCATIONDAYNOTWORKEDDTO():New()
	::oWSdayNotWorkedDTO := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_DAYNOTWORKEDDTO():New()
Return

WSMETHOD RESET WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0		     := NIL 
	::oWSstatusDTO       := NIL 
	::oWSdayNotWorked    := NIL 
	::oWSlocationDayNotWorkedDTO := NIL 
	::oWSdayNotWorkedDTO := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local oClone := WSDayNotWorkedIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0		 :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSdayNotWorked :=  IIF(::oWSdayNotWorked = NIL , NIL ,::oWSdayNotWorked:Clone() )
	oClone:oWSlocationDayNotWorkedDTO :=  IIF(::oWSlocationDayNotWorkedDTO = NIL , NIL ,::oWSlocationDayNotWorkedDTO:Clone() )
	oClone:oWSdayNotWorkedDTO :=  IIF(::oWSdayNotWorkedDTO = NIL , NIL ,::oWSdayNotWorkedDTO:Clone() )
Return oClone

// WSDL Method remove of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,DayNotWorkedIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertLocationDayNotWorkedWildcard of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertLocationDayNotWorkedWildcard WSSEND oWSdayNotWorked WSRECEIVE oWSlocationDayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertLocationDayNotWorkedWildcard xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("dayNotWorked", ::oWSdayNotWorked, oWSdayNotWorked , "locationDayNotWorkedDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertLocationDayNotWorkedWildcard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTLOCATIONDAYNOTWORKEDWILDCARDRESPONSE:_RETURN","locationDayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSlocationDayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New()) , ::oWSlocationDayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeLocationDayNotWorkedWildcard of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD removeLocationDayNotWorkedWildcard WSSEND oWSdayNotWorked WSRECEIVE oWSlocationDayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeLocationDayNotWorkedWildcard xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("dayNotWorked", ::oWSdayNotWorked, oWSdayNotWorked , "locationDayNotWorkedDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</removeLocationDayNotWorkedWildcard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVELOCATIONDAYNOTWORKEDWILDCARDRESPONSE:_RETURN","locationDayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSlocationDayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New()) , ::oWSlocationDayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdateIncrement of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertOrUpdateIncrement WSSEND oWSarg0 WSRECEIVE oWSdayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdateIncrement xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "dayNotWorkedDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdateIncrement>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATEINCREMENTRESPONSE:_RETURN","dayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSdayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO():New()) , ::oWSdayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertLocationDayNotWorked of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertLocationDayNotWorked WSSEND oWSarg0 WSRECEIVE oWSlocationDayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertLocationDayNotWorked xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "locationDayNotWorkedDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertLocationDayNotWorked>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTLOCATIONDAYNOTWORKEDRESPONSE:_RETURN","locationDayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSlocationDayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New()) , ::oWSlocationDayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSdayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "dayNotWorkedDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","dayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSdayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO():New()) , ::oWSdayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeLocationDayNotWorked of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD removeLocationDayNotWorked WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeLocationDayNotWorked xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "locationDayNotWorkedDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</removeLocationDayNotWorked>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVELOCATIONDAYNOTWORKEDRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,DayNotWorkedIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdateWildcard of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertOrUpdateWildcard WSSEND oWSarg0 WSRECEIVE oWSdayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdateWildcard xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "dayNotWorkedWildcardDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertOrUpdateWildcard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATEWILDCARDRESPONSE:_RETURN","dayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSdayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO():New()) , ::oWSdayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdateList of Service WSDayNotWorkedIntegrationServiceBeanService

WSMETHOD insertOrUpdateList WSSEND oWSarg0 WSRECEIVE oWSdayNotWorkedDTO WSCLIENT WSDayNotWorkedIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdateList xmlns="http://daynotworked.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "dayNotWorkedSimpleDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertOrUpdateList>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://daynotworked.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/DayNotWorkedIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATELISTRESPONSE:_RETURN","dayNotWorkedDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSdayNotWorkedDTO,DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO():New()) , ::oWSdayNotWorkedDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure statusDTO

WSSTRUCT DayNotWorkedIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT DayNotWorkedIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT DayNotWorkedIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT DayNotWorkedIntegrationServiceBeanService_statusDTO
	Local oClone := DayNotWorkedIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT DayNotWorkedIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure locationDayNotWorkedDTO

WSSTRUCT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	WSDATA   cdayNotWorkedExternalKey  AS string OPTIONAL
	WSDATA   clocationExternalKey      AS string OPTIONAL
	WSDATA   cshiftWorkExternalKey     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
Return

WSMETHOD CLONE WSCLIENT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	Local oClone := DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():NEW()
	oClone:cdayNotWorkedExternalKey := ::cdayNotWorkedExternalKey
	oClone:clocationExternalKey := ::clocationExternalKey
	oClone:cshiftWorkExternalKey := ::cshiftWorkExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	Local cSoap := ""
	cSoap += WSSoapValue("dayNotWorkedExternalKey", ::cdayNotWorkedExternalKey, ::cdayNotWorkedExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("locationExternalKey", ::clocationExternalKey, ::clocationExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shiftWorkExternalKey", ::cshiftWorkExternalKey, ::cshiftWorkExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdayNotWorkedExternalKey :=  WSAdvValue( oResponse,"_DAYNOTWORKEDEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::clocationExternalKey :=  WSAdvValue( oResponse,"_LOCATIONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cshiftWorkExternalKey :=  WSAdvValue( oResponse,"_SHIFTWORKEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure dayNotWorkedDTO

WSSTRUCT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cdayNotWorked             AS dateTime OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   oWSlocationDayNotWorkedDTOCol AS DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO OPTIONAL
	WSDATA   lrecurrent                AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	::oWSlocationDayNotWorkedDTOCol := {} // Array Of  DayNotWorkedIntegrationServiceBeanService_LOCATIONDAYNOTWORKEDDTO():New()
Return

WSMETHOD CLONE WSCLIENT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	Local oClone := DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cdayNotWorked        := ::cdayNotWorked
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
	oClone:oWSlocationDayNotWorkedDTOCol := NIL
	If ::oWSlocationDayNotWorkedDTOCol <> NIL 
		oClone:oWSlocationDayNotWorkedDTOCol := {}
		aEval( ::oWSlocationDayNotWorkedDTOCol , { |x| aadd( oClone:oWSlocationDayNotWorkedDTOCol , x:Clone() ) } )
	Endif 
	oClone:lrecurrent           := ::lrecurrent
Return oClone

WSMETHOD SOAPSEND WSCLIENT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("dayNotWorked", ::cdayNotWorked, ::cdayNotWorked , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSlocationDayNotWorkedDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("locationDayNotWorkedDTOCol", x , x , "locationDayNotWorkedDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("recurrent", ::lrecurrent, ::lrecurrent , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT DayNotWorkedIntegrationServiceBeanService_dayNotWorkedDTO
	Local nRElem4, oNodes4, nTElem4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdayNotWorked      :=  WSAdvValue( oResponse,"_DAYNOTWORKED","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes4 :=  WSAdvValue( oResponse,"_LOCATIONDAYNOTWORKEDDTOCOL","locationDayNotWorkedDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4 
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oWSlocationDayNotWorkedDTOCol , DayNotWorkedIntegrationServiceBeanService_locationDayNotWorkedDTO():New() )
			::oWSlocationDayNotWorkedDTOCol[len(::oWSlocationDayNotWorkedDTOCol)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
	::lrecurrent         :=  WSAdvValue( oResponse,"_RECURRENT","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
Return


