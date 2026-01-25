#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

//*************************************************************************************************
// ATENCAO
// No metodo WSMETHOD SOAPSEND WSCLIENT SOAManager_SOAData foi inibido o envio da propriedade
// "Columns", pois, nao eh preciso para o WS e o nosso WS nao esta tratando ainda o envio de uma
// propriedade com recursividade
// QUALQUER ALTERACAO NESSE PROGRAMA DEVERA SER VERIFICADO COM EDUARDO SOUZA - FRAMEWORK
//*************************************************************************************************


/* ===============================================================================
WSDL Location    http://mashups.totvs.com.br/SOAManager.wsdl
Gerado em        06/06/08 17:06:03
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.080519
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FURKQOI ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSOAManager
------------------------------------------------------------------------------- */

WSCLIENT WSSOAManager

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Execute
	WSMETHOD GetService
	WSMETHOD GetServiceNames
	WSMETHOD GetServiceTypes
	WSMETHOD GetServicesInfo

	WSDATA   _URL                      AS String
	WSDATA   oWSConnectionData         AS SOAManager_SOAConnectionData
	WSDATA   oWSServiceData            AS SOAManager_SOAServiceData
	WSDATA   oWSResultType             AS SOAManager_SOAResultType
	WSDATA   cResultMessage            AS string
	WSDATA   nResultMessageCode        AS int
	WSDATA   cServiceType              AS string
	WSDATA   cServiceName              AS string
	WSDATA   nServiceVersion           AS int
	WSDATA   oWSServiceNames           AS SOAManager_ArrayOfstring
	WSDATA   oWSServiceTypes           AS SOAManager_ArrayOfstring
	WSDATA   oWSSearchType             AS SOAManager_SOASearchType
	WSDATA   cSearchValue              AS string
	WSDATA   oWSServicesInfo           AS SOAManager_ArrayOfSOAServiceInfo

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSOAManager
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.080307A-20080327] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSOAManager
	::oWSConnectionData  := SOAManager_SOACONNECTIONDATA():New()
	::oWSServiceData     := SOAManager_SOASERVICEDATA():New()
	::oWSResultType      := SOAManager_SOARESULTTYPE():New()
	::oWSServiceNames    := SOAManager_ARRAYOFSTRING():New()
	::oWSServiceTypes    := SOAManager_ARRAYOFSTRING():New()
	::oWSSearchType      := SOAManager_SOASEARCHTYPE():New()
	::oWSServicesInfo    := SOAManager_ARRAYOFSOASERVICEINFO():New()
Return

WSMETHOD RESET WSCLIENT WSSOAManager
	::oWSConnectionData  := NIL 
	::oWSServiceData     := NIL 
	::oWSResultType      := NIL 
	::cResultMessage     := NIL 
	::nResultMessageCode := NIL 
	::cServiceType       := NIL 
	::cServiceName       := NIL 
	::nServiceVersion    := NIL 
	::oWSServiceNames    := NIL 
	::oWSServiceTypes    := NIL 
	::oWSSearchType      := NIL 
	::cSearchValue       := NIL 
	::oWSServicesInfo    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSOAManager
Local oClone := WSSOAManager():New()
	oClone:_URL          := ::_URL 
	oClone:oWSConnectionData :=  IIF(::oWSConnectionData = NIL , NIL ,::oWSConnectionData:Clone() )
	oClone:oWSServiceData :=  IIF(::oWSServiceData = NIL , NIL ,::oWSServiceData:Clone() )
	oClone:oWSResultType :=  IIF(::oWSResultType = NIL , NIL ,::oWSResultType:Clone() )
	oClone:cResultMessage := ::cResultMessage
	oClone:nResultMessageCode := ::nResultMessageCode
	oClone:cServiceType  := ::cServiceType
	oClone:cServiceName  := ::cServiceName
	oClone:nServiceVersion := ::nServiceVersion
	oClone:oWSServiceNames :=  IIF(::oWSServiceNames = NIL , NIL ,::oWSServiceNames:Clone() )
	oClone:oWSServiceTypes :=  IIF(::oWSServiceTypes = NIL , NIL ,::oWSServiceTypes:Clone() )
	oClone:oWSSearchType :=  IIF(::oWSSearchType = NIL , NIL ,::oWSSearchType:Clone() )
	oClone:cSearchValue  := ::cSearchValue
	oClone:oWSServicesInfo :=  IIF(::oWSServicesInfo = NIL , NIL ,::oWSServicesInfo:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method Execute of Service WSSOAManager
------------------------------------------------------------------------------- */

WSMETHOD Execute WSSEND oWSConnectionData,BYREF oWSServiceData WSRECEIVE oWSResultType, cResultMessage, nResultMessageCode WSCLIENT WSSOAManager
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOAManagerExecuteRequest xmlns="http://TotvsSOA.ServiceContracts/v1">'
cSoap += WSSoapValue("ConnectionData", ::oWSConnectionData, oWSConnectionData , "SOAConnectionData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += WSSoapValue("ServiceData", ::oWSServiceData, oWSServiceData , "SOAServiceData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += "</SOAManagerExecuteRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"Execute",; 
	"DOCUMENT","http://TotvsSOA.ServiceContracts/v1",,,; 
	"http://mashups.totvs.com.br/TotvsSOA.Host/SOAManager.svc")

::Init()
::oWSResultType:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGEREXECUTERESULT:_RESULTTYPE","SOAResultType",NIL,NIL,NIL,NIL,NIL,NIL) )
::cResultMessage     :=  WSAdvValue( oXmlRet,"_SOAMANAGEREXECUTERESULT:_RESULTMESSAGE:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 
::nResultMessageCode :=  WSAdvValue( oXmlRet,"_SOAMANAGEREXECUTERESULT:_RESULTMESSAGECODE:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::oWSServiceData:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGEREXECUTERESULT:_SERVICEDATA","SOAServiceData",NIL,NIL,NIL,NIL,@oWSServiceData,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GetService of Service WSSOAManager
------------------------------------------------------------------------------- */

WSMETHOD GetService WSSEND oWSConnectionData,cServiceType,cServiceName,nServiceVersion WSRECEIVE oWSServiceData WSCLIENT WSSOAManager
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOAManagerGetServiceRequest xmlns="http://TotvsSOA.ServiceContracts/v1">'
cSoap += WSSoapValue("ConnectionData", ::oWSConnectionData, oWSConnectionData , "SOAConnectionData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += WSSoapValue("ServiceType", ::cServiceType, cServiceType , "string", .F. , .F., 0 , NIL) 
cSoap += WSSoapValue("ServiceName", ::cServiceName, cServiceName , "string", .F. , .F., 0 , NIL) 
cSoap += WSSoapValue("ServiceVersion", ::nServiceVersion, nServiceVersion , "int", .F. , .F., 0 , NIL) 
cSoap += "</SOAManagerGetServiceRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"GetService",; 
	"DOCUMENT","http://TotvsSOA.ServiceContracts/v1",,,; 
	"http://mashups.totvs.com.br/TotvsSOA.Host/SOAManager.svc")

::Init()
::oWSServiceData:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGERGETSERVICERESULT:_SERVICEDATA","SOAServiceData",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GetServiceNames of Service WSSOAManager
------------------------------------------------------------------------------- */

WSMETHOD GetServiceNames WSSEND oWSConnectionData,cServiceType WSRECEIVE oWSServiceNames WSCLIENT WSSOAManager
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOAManagerGetServiceNamesRequest xmlns="http://TotvsSOA.ServiceContracts/v1">'
cSoap += WSSoapValue("ConnectionData", ::oWSConnectionData, oWSConnectionData , "SOAConnectionData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += WSSoapValue("ServiceType", ::cServiceType, cServiceType , "string", .F. , .F., 0 , NIL) 
cSoap += "</SOAManagerGetServiceNamesRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"GetServiceNames",; 
	"DOCUMENT","http://TotvsSOA.ServiceContracts/v1",,,; 
	"http://mashups.totvs.com.br/TotvsSOA.Host/SOAManager.svc")

::Init()
::oWSServiceNames:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGERGETSERVICENAMESRESULT:_SERVICENAMES","ArrayOfstring",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GetServiceTypes of Service WSSOAManager
------------------------------------------------------------------------------- */

WSMETHOD GetServiceTypes WSSEND oWSConnectionData WSRECEIVE oWSServiceTypes WSCLIENT WSSOAManager
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOAManagerGetServiceTypesRequest xmlns="http://TotvsSOA.ServiceContracts/v1">'
cSoap += WSSoapValue("ConnectionData", ::oWSConnectionData, oWSConnectionData , "SOAConnectionData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += "</SOAManagerGetServiceTypesRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"GetServiceTypes",; 
	"DOCUMENT","http://TotvsSOA.ServiceContracts/v1",,,; 
	"http://mashups.totvs.com.br/TotvsSOA.Host/SOAManager.svc")

::Init()
::oWSServiceTypes:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGERGETSERVICETYPESRESULT:_SERVICETYPES","ArrayOfstring",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GetServicesInfo of Service WSSOAManager
------------------------------------------------------------------------------- */

WSMETHOD GetServicesInfo WSSEND oWSConnectionData,oWSSearchType,cSearchValue WSRECEIVE oWSServicesInfo WSCLIENT WSSOAManager
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SOAManagerGetServicesInfoRequest xmlns="http://TotvsSOA.ServiceContracts/v1">'
cSoap += WSSoapValue("ConnectionData", ::oWSConnectionData, oWSConnectionData , "SOAConnectionData", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += WSSoapValue("SearchType", ::oWSSearchType, oWSSearchType , "SOASearchType", .F. , .F., 0 , "http://TotvsSOA.ServiceContracts/v1") 
cSoap += WSSoapValue("SearchValue", ::cSearchValue, cSearchValue , "string", .F. , .F., 0 , NIL) 
cSoap += "</SOAManagerGetServicesInfoRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"GetServiceInfos",; 
	"DOCUMENT","http://TotvsSOA.ServiceContracts/v1",,,; 
	"http://mashups.totvs.com.br/TotvsSOA.Host/SOAManager.svc")

::Init()
::oWSServicesInfo:SoapRecv( WSAdvValue( oXmlRet,"_SOAMANAGERGETSERVICESINFORESULT:_SERVICESINFO","ArrayOfSOAServiceInfo",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure SOAConnectionData
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOAConnectionData
	WSDATA   cClientId                 AS string OPTIONAL
	WSDATA   cUsername                 AS string OPTIONAL
	WSDATA   cPassword                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOAConnectionData
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_SOAConnectionData
Return

WSMETHOD CLONE WSCLIENT SOAManager_SOAConnectionData
	Local oClone := SOAManager_SOAConnectionData():NEW()
	oClone:cClientId            := ::cClientId
	oClone:cUsername            := ::cUsername
	oClone:cPassword            := ::cPassword
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOAConnectionData
	Local cSoap := ""
	cSoap += WSSoapValue("ClientId", ::cClientId, ::cClientId , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Username", ::cUsername, ::cUsername , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Password", ::cPassword, ::cPassword , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure SOAServiceData
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOAServiceData
	WSDATA   cServiceExecutionId       AS string OPTIONAL
	WSDATA   cServiceType              AS string OPTIONAL
	WSDATA   cServiceName              AS string OPTIONAL
	WSDATA   nServiceVersion           AS int OPTIONAL
	WSDATA   cServiceTitle             AS string OPTIONAL
	WSDATA   cCurrentState             AS string OPTIONAL
	WSDATA   cCurrentStateDescription  AS string OPTIONAL
	WSDATA   oWSData                   AS SOAManager_ArrayOfSOAData OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOAServiceData
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_SOAServiceData
Return

WSMETHOD CLONE WSCLIENT SOAManager_SOAServiceData
	Local oClone := SOAManager_SOAServiceData():NEW()
	oClone:cServiceExecutionId  := ::cServiceExecutionId
	oClone:cServiceType         := ::cServiceType
	oClone:cServiceName         := ::cServiceName
	oClone:nServiceVersion      := ::nServiceVersion
	oClone:cServiceTitle        := ::cServiceTitle
	oClone:cCurrentState        := ::cCurrentState
	oClone:cCurrentStateDescription := ::cCurrentStateDescription
	oClone:oWSData              := IIF(::oWSData = NIL , NIL , ::oWSData:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOAServiceData
	Local cSoap := ""
	cSoap += WSSoapValue("ServiceExecutionId", ::cServiceExecutionId, ::cServiceExecutionId , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("ServiceType", ::cServiceType, ::cServiceType , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("ServiceName", ::cServiceName, ::cServiceName , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("ServiceVersion", ::nServiceVersion, ::nServiceVersion , "int", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("ServiceTitle", ::cServiceTitle, ::cServiceTitle , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("CurrentState", ::cCurrentState, ::cCurrentState , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("CurrentStateDescription", ::cCurrentStateDescription, ::cCurrentStateDescription , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Data", ::oWSData, ::oWSData , "ArrayOfSOAData", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOAServiceData
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cServiceExecutionId :=  WSAdvValue( oResponse,"_SERVICEEXECUTIONID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceType       :=  WSAdvValue( oResponse,"_SERVICETYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceName       :=  WSAdvValue( oResponse,"_SERVICENAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nServiceVersion    :=  WSAdvValue( oResponse,"_SERVICEVERSION","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cServiceTitle      :=  WSAdvValue( oResponse,"_SERVICETITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCurrentState      :=  WSAdvValue( oResponse,"_CURRENTSTATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCurrentStateDescription :=  WSAdvValue( oResponse,"_CURRENTSTATEDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_DATA","ArrayOfSOAData",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSData := SOAManager_ArrayOfSOAData():New()
		::oWSData:SoapRecv(oNode8)
	EndIf
Return

/* -------------------------------------------------------------------------------
WSDL Data Enumeration SOAResultType
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOAResultType
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOAResultType
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Continue" )
	aadd(::aValueList , "Finished" )
	aadd(::aValueList , "Error" )
	aadd(::aValueList , "Warning" )
	aadd(::aValueList , "InvalidParam" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOAResultType
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOAResultType
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SOAManager_SOAResultType
Local oClone := SOAManager_SOAResultType():New()
	oClone:Value := ::Value
Return oClone

/* -------------------------------------------------------------------------------
WSDL Data Structure ArrayOfstring
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_ArrayOfstring
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_ArrayOfstring
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_ArrayOfstring
	::cstring              := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT SOAManager_ArrayOfstring
	Local oClone := SOAManager_ArrayOfstring():NEW()
	oClone:cstring              := IIf(::cstring <> NIL , aClone(::cstring) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_ArrayOfstring
	Local oNodes1 :=  WSAdvValue( oResponse,"_STRING","string",{},NIL,.T.,"S",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::cstring ,  x:TEXT  ) } )
Return

/* -------------------------------------------------------------------------------
WSDL Data Enumeration SOASearchType
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOASearchType
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOASearchType
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "All" )
	aadd(::aValueList , "ServiceType" )
	aadd(::aValueList , "ServiceName" )
	aadd(::aValueList , "ServiceTitle" )
	aadd(::aValueList , "Description" )
	aadd(::aValueList , "Provider" )
	aadd(::aValueList , "Tag" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOASearchType
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOASearchType
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SOAManager_SOASearchType
Local oClone := SOAManager_SOASearchType():New()
	oClone:Value := ::Value
Return oClone

/* -------------------------------------------------------------------------------
WSDL Data Structure ArrayOfSOAServiceInfo
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_ArrayOfSOAServiceInfo
	WSDATA   oWSSOAServiceInfo         AS SOAManager_SOAServiceInfo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_ArrayOfSOAServiceInfo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_ArrayOfSOAServiceInfo
	::oWSSOAServiceInfo    := {} // Array Of  SOAManager_SOASERVICEINFO():New()
Return

WSMETHOD CLONE WSCLIENT SOAManager_ArrayOfSOAServiceInfo
	Local oClone := SOAManager_ArrayOfSOAServiceInfo():NEW()
	oClone:oWSSOAServiceInfo := NIL
	If ::oWSSOAServiceInfo <> NIL 
		oClone:oWSSOAServiceInfo := {}
		aEval( ::oWSSOAServiceInfo , { |x| aadd( oClone:oWSSOAServiceInfo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_ArrayOfSOAServiceInfo
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SOASERVICEINFO","SOAServiceInfo",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSOAServiceInfo , SOAManager_SOAServiceInfo():New() )
			::oWSSOAServiceInfo[len(::oWSSOAServiceInfo)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ArrayOfSOAData
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_ArrayOfSOAData
	WSDATA   oWSSOAData                AS SOAManager_SOAData OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_ArrayOfSOAData
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_ArrayOfSOAData
	::oWSSOAData           := {} // Array Of  SOAManager_SOADATA():New()
Return

WSMETHOD CLONE WSCLIENT SOAManager_ArrayOfSOAData
	Local oClone := SOAManager_ArrayOfSOAData():NEW()
	oClone:oWSSOAData := NIL
	If ::oWSSOAData <> NIL 
		oClone:oWSSOAData := {}
		aEval( ::oWSSOAData , { |x| aadd( oClone:oWSSOAData , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_ArrayOfSOAData
	Local cSoap := ""
	aEval( ::oWSSOAData , {|x| cSoap := cSoap  +  WSSoapValue("SOAData", x , x , "SOAData", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" )  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_ArrayOfSOAData
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SOADATA","SOAData",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSOAData , SOAManager_SOAData():New() )
			::oWSSOAData[len(::oWSSOAData)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure SOAServiceInfo
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOAServiceInfo
	WSDATA   cServiceType              AS string OPTIONAL
	WSDATA   cServiceName              AS string OPTIONAL
	WSDATA   nServiceVersion           AS int OPTIONAL
	WSDATA   cServiceTitle             AS string OPTIONAL
	WSDATA   cServiceProvider          AS string OPTIONAL
	WSDATA   cServiceDescription       AS string OPTIONAL
	WSDATA   cServiceTags              AS string OPTIONAL
	WSDATA   cServiceDate              AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOAServiceInfo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_SOAServiceInfo
Return

WSMETHOD CLONE WSCLIENT SOAManager_SOAServiceInfo
	Local oClone := SOAManager_SOAServiceInfo():NEW()
	oClone:cServiceType         := ::cServiceType
	oClone:cServiceName         := ::cServiceName
	oClone:nServiceVersion      := ::nServiceVersion
	oClone:cServiceTitle        := ::cServiceTitle
	oClone:cServiceProvider     := ::cServiceProvider
	oClone:cServiceDescription  := ::cServiceDescription
	oClone:cServiceTags         := ::cServiceTags
	oClone:cServiceDate         := ::cServiceDate
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOAServiceInfo
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cServiceType       :=  WSAdvValue( oResponse,"_SERVICETYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceName       :=  WSAdvValue( oResponse,"_SERVICENAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nServiceVersion    :=  WSAdvValue( oResponse,"_SERVICEVERSION","int",NIL,NIL,NIL,"N",NIL,NIL) 
	::cServiceTitle      :=  WSAdvValue( oResponse,"_SERVICETITLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceProvider   :=  WSAdvValue( oResponse,"_SERVICEPROVIDER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceDescription :=  WSAdvValue( oResponse,"_SERVICEDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceTags       :=  WSAdvValue( oResponse,"_SERVICETAGS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cServiceDate       :=  WSAdvValue( oResponse,"_SERVICEDATE","dateTime",NIL,NIL,NIL,"S",NIL,NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure SOAData
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOAData
	WSDATA   oWSDataKind               AS SOAManager_SOADataKind OPTIONAL
	WSDATA   oWSDataType               AS SOAManager_SOADataType OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   cName                     AS string OPTIONAL
	WSDATA   cStateName                AS string OPTIONAL
	WSDATA   cValue                    AS string OPTIONAL
	WSDATA   oWSListItems              AS SOAManager_ArrayOfSOADataListItem OPTIONAL
	WSDATA   oWSColumns                AS SOAManager_ArrayOfSOAData OPTIONAL
	WSDATA   lRequired                 AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOAData
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_SOAData
Return

WSMETHOD CLONE WSCLIENT SOAManager_SOAData
	Local oClone := SOAManager_SOAData():NEW()
	oClone:oWSDataKind          := IIF(::oWSDataKind = NIL , NIL , ::oWSDataKind:Clone() )
	oClone:oWSDataType          := IIF(::oWSDataType = NIL , NIL , ::oWSDataType:Clone() )
	oClone:cDescription         := ::cDescription
	oClone:cName                := ::cName
	oClone:cStateName           := ::cStateName
	oClone:cValue               := ::cValue
	oClone:oWSListItems         := IIF(::oWSListItems = NIL , NIL , ::oWSListItems:Clone() )
	oClone:oWSColumns           := IIF(::oWSColumns = NIL , NIL , ::oWSColumns:Clone() )
	oClone:lRequired            := ::lRequired
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOAData
	Local cSoap := ""
	cSoap += WSSoapValue("DataKind", ::oWSDataKind, ::oWSDataKind , "SOADataKind", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("DataType", ::oWSDataType, ::oWSDataType , "SOADataType", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Name", ::cName, ::cName , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("StateName", ::cStateName, ::cStateName , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Value", ::cValue, ::cValue , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("ListItems", ::oWSListItems, ::oWSListItems , "ArrayOfSOADataListItem", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
//	cSoap += WSSoapValue("Columns", ::oWSColumns, ::oWSColumns , "ArrayOfSOAData", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Required", ::lRequired, ::lRequired , "boolean", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOAData
	Local oNode1
	Local oNode2
	Local oNode7
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_DATAKIND","SOADataKind",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSDataKind := SOAManager_SOADataKind():New()
		::oWSDataKind:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_DATATYPE","SOADataType",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSDataType := SOAManager_SOADataType():New()
		::oWSDataType:SoapRecv(oNode2)
	EndIf
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cName              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cStateName         :=  WSAdvValue( oResponse,"_STATENAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_LISTITEMS","ArrayOfSOADataListItem",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSListItems := SOAManager_ArrayOfSOADataListItem():New()
		::oWSListItems:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_COLUMNS","ArrayOfSOAData",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSColumns := SOAManager_ArrayOfSOAData():New()
		::oWSColumns:SoapRecv(oNode8)
	EndIf
	::lRequired          :=  WSAdvValue( oResponse,"_REQUIRED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Enumeration SOADataKind
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOADataKind
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOADataKind
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Param" )
	aadd(::aValueList , "Info" )
	aadd(::aValueList , "Result" )
	aadd(::aValueList , "Internal" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOADataKind
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOADataKind
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SOAManager_SOADataKind
Local oClone := SOAManager_SOADataKind():New()
	oClone:Value := ::Value
Return oClone

/* -------------------------------------------------------------------------------
WSDL Data Enumeration SOADataType
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOADataType
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOADataType
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "Boolean" )
	aadd(::aValueList , "Integer" )
	aadd(::aValueList , "Number" )
	aadd(::aValueList , "DateTime" )
	aadd(::aValueList , "String" )
	aadd(::aValueList , "List" )
	aadd(::aValueList , "Image" )
	aadd(::aValueList , "Table" )
Return Self

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOADataType
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOADataType
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT SOAManager_SOADataType
Local oClone := SOAManager_SOADataType():New()
	oClone:Value := ::Value
Return oClone

/* -------------------------------------------------------------------------------
WSDL Data Structure ArrayOfSOADataListItem
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_ArrayOfSOADataListItem
	WSDATA   oWSSOADataListItem        AS SOAManager_SOADataListItem OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_ArrayOfSOADataListItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_ArrayOfSOADataListItem
	::oWSSOADataListItem   := {} // Array Of  SOAManager_SOADATALISTITEM():New()
Return

WSMETHOD CLONE WSCLIENT SOAManager_ArrayOfSOADataListItem
	Local oClone := SOAManager_ArrayOfSOADataListItem():NEW()
	oClone:oWSSOADataListItem := NIL
	If ::oWSSOADataListItem <> NIL 
		oClone:oWSSOADataListItem := {}
		aEval( ::oWSSOADataListItem , { |x| aadd( oClone:oWSSOADataListItem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_ArrayOfSOADataListItem
	Local cSoap := ""
	aEval( ::oWSSOADataListItem , {|x| cSoap := cSoap  +  WSSoapValue("SOADataListItem", x , x , "SOADataListItem", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" )  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_ArrayOfSOADataListItem
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_SOADATALISTITEM","SOADataListItem",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSSOADataListItem , SOAManager_SOADataListItem():New() )
			::oWSSOADataListItem[len(::oWSSOADataListItem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure SOADataListItem
------------------------------------------------------------------------------- */

WSSTRUCT SOAManager_SOADataListItem
	WSDATA   cCode                     AS string OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SOAManager_SOADataListItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SOAManager_SOADataListItem
Return

WSMETHOD CLONE WSCLIENT SOAManager_SOADataListItem
	Local oClone := SOAManager_SOADataListItem():NEW()
	oClone:cCode                := ::cCode
	oClone:cDescription         := ::cDescription
Return oClone

WSMETHOD SOAPSEND WSCLIENT SOAManager_SOADataListItem
	Local cSoap := ""
	cSoap += WSSoapValue("Code", ::cCode, ::cCode , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , "http://TotvsSOA.DataContracts/v1" ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SOAManager_SOADataListItem
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCode              :=  WSAdvValue( oResponse,"_CODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


