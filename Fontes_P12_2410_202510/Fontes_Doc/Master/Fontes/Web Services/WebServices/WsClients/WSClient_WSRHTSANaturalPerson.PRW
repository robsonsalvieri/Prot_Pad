#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/NaturalPersonIntegrationServiceBean?wsdl
Gerado em        09/25/18 13:41:21
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JQSWZWN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNaturalPersonIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSNaturalPersonIntegrationServiceBeanService

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
	WSDATA   oWSarg0	               AS NaturalPersonIntegrationServiceBeanService_statusDTO

	WSDATA   oWSstatusDTO              AS NaturalPersonIntegrationServiceBeanService_statusDTO
	WSDATA   oWSnaturalPersonDTO       AS NaturalPersonIntegrationServiceBeanService_naturalPersonDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNaturalPersonIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180727 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNaturalPersonIntegrationServiceBeanService
	::oWSarg0		      := {} // Array Of  NaturalPersonIntegrationServiceBeanService_STATUSDTO():New()
	::oWSstatusDTO       := {} // Array Of  NaturalPersonIntegrationServiceBeanService_STATUSDTO():New()
	::oWSnaturalPersonDTO := {} // Array Of  NaturalPersonIntegrationServiceBeanService_NATURALPERSONDTO():New()
Return

WSMETHOD RESET WSCLIENT WSNaturalPersonIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0       := NIL 
	::oWSstatusDTO       := NIL 
	::oWSnaturalPersonDTO := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNaturalPersonIntegrationServiceBeanService
Local oClone := WSNaturalPersonIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSnaturalPersonDTO :=  IIF(::oWSnaturalPersonDTO = NIL , NIL ,::oWSnaturalPersonDTO:Clone() )
Return oClone

// WSDL Method remove of Service WSNaturalPersonIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSNaturalPersonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://naturalperson.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://naturalperson.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/NaturalPersonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,NaturalPersonIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSNaturalPersonIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSnaturalPersonDTO WSCLIENT WSNaturalPersonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://naturalperson.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "naturalPersonDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://naturalperson.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/NaturalPersonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","naturalPersonDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSnaturalPersonDTO,NaturalPersonIntegrationServiceBeanService_naturalPersonDTO():New()) , ::oWSnaturalPersonDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure statusDTO

WSSTRUCT NaturalPersonIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NaturalPersonIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NaturalPersonIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT NaturalPersonIntegrationServiceBeanService_statusDTO
	Local oClone := NaturalPersonIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NaturalPersonIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure naturalPersonDTO

WSSTRUCT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   caddress                  AS string OPTIONAL
	WSDATA   cbirthDate                AS string OPTIONAL
	WSDATA   ccity                     AS string OPTIONAL
	WSDATA   ccountry                  AS string OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cfederalId                AS string OPTIONAL
	WSDATA   cidCard                   AS string OPTIONAL
	WSDATA   cidCardDate               AS dateTime OPTIONAL
	WSDATA   cidCardEmitter            AS string OPTIONAL
	WSDATA   cidCardState              AS string OPTIONAL
	WSDATA   cimage                    AS base64Binary OPTIONAL
	WSDATA   cname                     AS string OPTIONAL
	WSDATA   cneighborhood             AS string OPTIONAL
	WSDATA   cotherDocumentName        AS string OPTIONAL
	WSDATA   cotherDocumentValue       AS string OPTIONAL
	WSDATA   nphone1                   AS int OPTIONAL
	WSDATA   nphone2                   AS int OPTIONAL
	WSDATA   nphoneCode1               AS int OPTIONAL
	WSDATA   nphoneCode2               AS int OPTIONAL
	WSDATA   csex                      AS string OPTIONAL
	WSDATA   cstate                    AS string OPTIONAL
	WSDATA   czipCode                  AS string OPTIONAL
	WSDATA   cfilial				   AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
Return

WSMETHOD CLONE WSCLIENT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
	Local oClone := NaturalPersonIntegrationServiceBeanService_naturalPersonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	
	oClone:caddress             := ::caddress
	oClone:cbirthDate           := ::cbirthDate
	oClone:ccity                := ::ccity
	oClone:ccountry             := ::ccountry
	oClone:cemail               := ::cemail
	oClone:cexternalKey         := ::cexternalKey
	oClone:cfederalId           := ::cfederalId
	oClone:cidCard              := ::cidCard
	oClone:cidCardDate          := ::cidCardDate
	oClone:cidCardEmitter       := ::cidCardEmitter
	oClone:cidCardState         := ::cidCardState
	oClone:cimage               := ::cimage
	oClone:cname                := ::cname
	oClone:cneighborhood        := ::cneighborhood
	oClone:cotherDocumentName   := ::cotherDocumentName
	oClone:cotherDocumentValue  := ::cotherDocumentValue
	oClone:nphone1              := ::nphone1
	oClone:nphone2              := ::nphone2
	oClone:nphoneCode1          := ::nphoneCode1
	oClone:nphoneCode2          := ::nphoneCode2
	oClone:csex                 := ::csex
	oClone:cstate               := ::cstate
	oClone:czipCode             := ::czipCode
	oClone:cfilial				:= ::cfilial
Return oClone

WSMETHOD SOAPSEND WSCLIENT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
	Local cSoap := ""
	Local lTsa := SUPERGETMV("MV_TSAINT",,.F., ::cfilial)             

	cSoap += WSSoapValue("address", ::caddress, ::caddress , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("city", ::ccity, ::ccity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("country", ::ccountry, ::ccountry , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("federalId", ::cfederalId, ::cfederalId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("idCard", ::cidCard, ::cidCard , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("idCardDate", ::cidCardDate, ::cidCardDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("idCardEmitter", ::cidCardEmitter, ::cidCardEmitter , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("idCardState", ::cidCardState, ::cidCardState , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("image", ::cimage, ::cimage , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("name", ::cname, ::cname , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("neighborhood", ::cneighborhood, ::cneighborhood , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("otherDocumentName", ::cotherDocumentName, ::cotherDocumentName , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("otherDocumentValue", ::cotherDocumentValue, ::cotherDocumentValue , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phone1", ::nphone1, ::nphone1 , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phone2", ::nphone2, ::nphone2 , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phoneCode1", ::nphoneCode1, ::nphoneCode1 , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phoneCode2", ::nphoneCode2, ::nphoneCode2 , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("state", ::cstate, ::cstate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("zipCode", ::czipCode, ::czipCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	
	If !lTsa
		cSoap += WSSoapValue("sex", ::csex, ::csex , "string", .F. , .F., 0 , NIL, .F.,.F.)
		cSoap += WSSoapValue("birthDate", ::cbirthDate, ::cbirthDate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	EndIf
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NaturalPersonIntegrationServiceBeanService_naturalPersonDTO
	Local lTsa := SUPERGETMV("MV_TSAINT",,.F., ::cfilial)

	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	
	::caddress           :=  WSAdvValue( oResponse,"_ADDRESS","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccity              :=  WSAdvValue( oResponse,"_CITY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccountry           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cemail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cfederalId         :=  WSAdvValue( oResponse,"_FEDERALID","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidCard            :=  WSAdvValue( oResponse,"_IDCARD","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidCardDate        :=  WSAdvValue( oResponse,"_IDCARDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidCardEmitter     :=  WSAdvValue( oResponse,"_IDCARDEMITTER","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cidCardState       :=  WSAdvValue( oResponse,"_IDCARDSTATE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cimage             :=  WSAdvValue( oResponse,"_IMAGE","base64Binary",NIL,NIL,NIL,"SB",NIL,"tns") 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cneighborhood      :=  WSAdvValue( oResponse,"_NEIGHBORHOOD","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cotherDocumentName :=  WSAdvValue( oResponse,"_OTHERDOCUMENTNAME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cotherDocumentValue :=  WSAdvValue( oResponse,"_OTHERDOCUMENTVALUE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::nphone1            :=  WSAdvValue( oResponse,"_PHONE1","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::nphone2            :=  WSAdvValue( oResponse,"_PHONE2","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::nphoneCode1        :=  WSAdvValue( oResponse,"_PHONECODE1","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::nphoneCode2        :=  WSAdvValue( oResponse,"_PHONECODE2","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cstate             :=  WSAdvValue( oResponse,"_STATE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::czipCode           :=  WSAdvValue( oResponse,"_ZIPCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 

	If !lTsa
		::cbirthDate         :=  WSAdvValue( oResponse,"_BIRTHDATE","string",NIL,NIL,NIL,"S",NIL,"xs") 
		::csex               :=  WSAdvValue( oResponse,"_SEX","string",NIL,NIL,NIL,"S",NIL,"xs") 
	EndIf

Return


