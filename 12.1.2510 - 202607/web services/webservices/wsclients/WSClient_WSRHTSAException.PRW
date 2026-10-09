#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb-11.5.0/ExceptionIntegrationServiceBean?wsdl
Gerado em        06/13/11 19:14:45
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KONEMWJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSExceptionIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSExceptionIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD remove
	WSMETHOD insertOrUpdate

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0                   AS ExceptionIntegrationServiceBeanService_statusDTO
	WSDATA   oWSstatusDTO              AS ExceptionIntegrationServiceBeanService_statusDTO
	WSDATA   oWSexceptionDTO           AS ExceptionIntegrationServiceBeanService_exceptionDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSExceptionIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSExceptionIntegrationServiceBeanService
	::oWSarg0            := {} // Array Of  ExceptionIntegrationServiceBeanService_STATUSDTO():New()
	::oWSstatusDTO       := {} // Array Of  ExceptionIntegrationServiceBeanService_STATUSDTO():New()
	::oWSexceptionDTO    := {} // Array Of  ExceptionIntegrationServiceBeanService_EXCEPTIONDTO():New()
Return

WSMETHOD RESET WSCLIENT WSExceptionIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0            := NIL 
	::oWSstatusDTO       := NIL 
	::oWSexceptionDTO    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSExceptionIntegrationServiceBeanService
Local oClone := WSExceptionIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSexceptionDTO :=  IIF(::oWSexceptionDTO = NIL , NIL ,::oWSexceptionDTO:Clone() )
Return oClone

// WSDL Method remove of Service WSExceptionIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSExceptionIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<remove xmlns="http://exception.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://exception.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ExceptionIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,ExceptionIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSExceptionIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSexceptionDTO WSCLIENT WSExceptionIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://exception.tsa.totvs.com/">'

If valtype(oWSarg0)="A"
	aEval( oWSarg0 ,{|x| ( cSoap += WSSoapValue("arg0", x , x , "exceptionDTO", .F. , .F., 0 , NIL, .T.)  ) })
Else
	cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "exceptionDTO", .F. , .F., 0 , NIL, .T.) 
Endif
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://exception.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ExceptionIntegrationServiceBean")

oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","exceptionDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSexceptionDTO,ExceptionIntegrationServiceBeanService_exceptionDTO():New()) , ::oWSexceptionDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure statusDTO

WSSTRUCT ExceptionIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ExceptionIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ExceptionIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT ExceptionIntegrationServiceBeanService_statusDTO
	Local oClone := ExceptionIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ExceptionIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure exceptionDTO

WSSTRUCT ExceptionIntegrationServiceBeanService_exceptionDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   ndirection                AS int OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   oWSexceptionPairDTOCol    AS ExceptionIntegrationServiceBeanService_exceptionPairDTO OPTIONAL
	WSDATA   nexceptionType            AS int OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   norigin                   AS int OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSDATA   cobservation         	   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ExceptionIntegrationServiceBeanService_exceptionDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ExceptionIntegrationServiceBeanService_exceptionDTO
	::oWSexceptionPairDTOCol := {} // Array Of  ExceptionIntegrationServiceBeanService_EXCEPTIONPAIRDTO():New()
Return

WSMETHOD CLONE WSCLIENT ExceptionIntegrationServiceBeanService_exceptionDTO
	Local oClone := ExceptionIntegrationServiceBeanService_exceptionDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:ndirection           := ::ndirection
	oClone:cendDate             := ::cendDate
	oClone:oWSexceptionPairDTOCol := NIL
	If ::oWSexceptionPairDTOCol <> NIL 
		oClone:oWSexceptionPairDTOCol := {}
		aEval( ::oWSexceptionPairDTOCol , { |x| aadd( oClone:oWSexceptionPairDTOCol , x:Clone() ) } )
	Endif 
	oClone:nexceptionType       := ::nexceptionType
	oClone:cexternalKey         := ::cexternalKey
	oClone:cinitialDate         := ::cinitialDate
	oClone:norigin              := ::norigin
	oClone:cuserExternalKey     := ::cuserExternalKey
	oClone:cobservation     := ::cobservation
Return oClone

WSMETHOD SOAPSEND WSCLIENT ExceptionIntegrationServiceBeanService_exceptionDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("direction", ::ndirection, ::ndirection , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .T.) 
	aEval( ::oWSexceptionPairDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("exceptionPairDTOCol", x , x , "exceptionPairDTO", .F. , .F., 0 , NIL, .T.)  } ) 
	cSoap += WSSoapValue("exceptionType", ::nexceptionType, ::nexceptionType , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("origin", ::norigin, ::norigin , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("observation", ::cobservation, ::cobservation , "string", .F. , .F., 0 , NIL, .T.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ExceptionIntegrationServiceBeanService_exceptionDTO
	Local nRElem3, oNodes3, nTElem3
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ndirection         :=  WSAdvValue( oResponse,"_DIRECTION","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes3 :=  WSAdvValue( oResponse,"_EXCEPTIONPAIRDTOCOL","exceptionPairDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem3 := len(oNodes3)
	For nRElem3 := 1 to nTElem3 
		If !WSIsNilNode( oNodes3[nRElem3] )
			aadd(::oWSexceptionPairDTOCol , ExceptionIntegrationServiceBeanService_exceptionPairDTO():New() )
			::oWSexceptionPairDTOCol[len(::oWSexceptionPairDTOCol)]:SoapRecv(oNodes3[nRElem3])
		Endif
	Next
	::nexceptionType     :=  WSAdvValue( oResponse,"_EXCEPTIONTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::norigin            :=  WSAdvValue( oResponse,"_ORIGIN","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cobservation	     :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,NIL,NIL,"S",NIL,"tns")
Return

// WSDL Data Structure exceptionPairDTO

WSSTRUCT ExceptionIntegrationServiceBeanService_exceptionPairDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cendTime                  AS dateTime OPTIONAL
	WSDATA   cinitialTime              AS dateTime OPTIONAL
	WSDATA   npairType                 AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ExceptionIntegrationServiceBeanService_exceptionPairDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ExceptionIntegrationServiceBeanService_exceptionPairDTO
Return

WSMETHOD CLONE WSCLIENT ExceptionIntegrationServiceBeanService_exceptionPairDTO
	Local oClone := ExceptionIntegrationServiceBeanService_exceptionPairDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cendTime             := ::cendTime
	oClone:cinitialTime         := ::cinitialTime
	oClone:npairType            := ::npairType
Return oClone

WSMETHOD SOAPSEND WSCLIENT ExceptionIntegrationServiceBeanService_exceptionPairDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("endTime", ::cendTime, ::cendTime , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("initialTime", ::cinitialTime, ::cinitialTime , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("pairType", ::npairType, ::npairType , "int", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ExceptionIntegrationServiceBeanService_exceptionPairDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendTime           :=  WSAdvValue( oResponse,"_ENDTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialTime       :=  WSAdvValue( oResponse,"_INITIALTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::npairType          :=  WSAdvValue( oResponse,"_PAIRTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
Return


