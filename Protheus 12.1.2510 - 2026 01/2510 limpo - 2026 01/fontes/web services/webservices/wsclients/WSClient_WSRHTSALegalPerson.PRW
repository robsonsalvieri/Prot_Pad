#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb-11.5.0/LegalPersonIntegrationServiceBean?wsdl
Gerado em        06/13/11 18:57:28
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XKLPKOL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLegalPersonIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSLegalPersonIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertOrUpdate
	WSMETHOD remove

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0                   AS LegalPersonIntegrationServiceBeanService_legalPersonDTO
	WSDATA   oWSlegalPersonDTO         AS LegalPersonIntegrationServiceBeanService_legalPersonDTO
	WSDATA   oWSstatusDTO              AS LegalPersonIntegrationServiceBeanService_statusDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLegalPersonIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self


WSMETHOD INIT WSCLIENT WSLegalPersonIntegrationServiceBeanService
	::oWSarg0            := {} // Array Of  LegalPersonIntegrationServiceBeanService_LEGALPERSONDTO():New()
	::oWSlegalPersonDTO  := {} // Array Of  LegalPersonIntegrationServiceBeanService_LEGALPERSONDTO():New()
	::oWSstatusDTO       := {} // Array Of  LegalPersonIntegrationServiceBeanService_STATUSDTO():New()
Return

WSMETHOD RESET WSCLIENT WSLegalPersonIntegrationServiceBeanService
	::carg0              := NIL 
	::oWSarg0            := NIL 
	::oWSlegalPersonDTO  := NIL 
	::oWSstatusDTO       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLegalPersonIntegrationServiceBeanService
Local oClone := WSLegalPersonIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSlegalPersonDTO :=  IIF(::oWSlegalPersonDTO = NIL , NIL ,::oWSlegalPersonDTO:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
Return oClone

// WSDL Method insertOrUpdate of Service WSLegalPersonIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSlegalPersonDTO WSCLIENT WSLegalPersonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://legalperson.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "legalPersonDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://legalperson.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/LegalPersonIntegrationServiceBean")

oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","legalPersonDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSlegalPersonDTO,LegalPersonIntegrationServiceBeanService_legalPersonDTO():New()) , ::oWSlegalPersonDTO[y]:SoapRecv(x) ) })
Endif


END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSLegalPersonIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSLegalPersonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<remove xmlns="http://legalperson.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://legalperson.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/LegalPersonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,LegalPersonIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif
END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure legalPersonDTO

WSSTRUCT LegalPersonIntegrationServiceBeanService_legalPersonDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   caddress                  AS string OPTIONAL
	WSDATA   ccei                      AS string OPTIONAL
	WSDATA   ccity                     AS string OPTIONAL
	WSDATA   ccompanyName              AS string OPTIONAL
	WSDATA   ccountry                  AS string OPTIONAL
	WSDATA   cemail                    AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cfederalId                AS string OPTIONAL
	WSDATA   cneighborhood             AS string OPTIONAL
	WSDATA   nphone                    AS int OPTIONAL
	WSDATA   nphoneCode                AS int OPTIONAL
	WSDATA   cstate                    AS string OPTIONAL
	WSDATA   czipCode                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LegalPersonIntegrationServiceBeanService_legalPersonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LegalPersonIntegrationServiceBeanService_legalPersonDTO
Return

WSMETHOD CLONE WSCLIENT LegalPersonIntegrationServiceBeanService_legalPersonDTO
	Local oClone := LegalPersonIntegrationServiceBeanService_legalPersonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:caddress             := ::caddress
	oClone:ccei                 := ::ccei
	oClone:ccity                := ::ccity
	oClone:ccompanyName         := ::ccompanyName
	oClone:ccountry             := ::ccountry
	oClone:cemail               := ::cemail
	oClone:cexternalKey         := ::cexternalKey
	oClone:cfederalId           := ::cfederalId
	oClone:cneighborhood        := ::cneighborhood
	oClone:nphone               := ::nphone
	oClone:nphoneCode           := ::nphoneCode
	oClone:cstate               := ::cstate
	oClone:czipCode             := ::czipCode
Return oClone

WSMETHOD SOAPSEND WSCLIENT LegalPersonIntegrationServiceBeanService_legalPersonDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("address", ::caddress, ::caddress , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("cei", ::ccei, ::ccei , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("city", ::ccity, ::ccity , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("companyName", ::ccompanyName, ::ccompanyName , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("country", ::ccountry, ::ccountry , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("email", ::cemail, ::cemail , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("federalId", ::cfederalId, ::cfederalId , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("neighborhood", ::cneighborhood, ::cneighborhood , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("phone", ::nphone, ::nphone , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("phoneCode", ::nphoneCode, ::nphoneCode , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("state", ::cstate, ::cstate , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("zipCode", ::czipCode, ::czipCode , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LegalPersonIntegrationServiceBeanService_legalPersonDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::caddress           :=  WSAdvValue( oResponse,"_ADDRESS","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccei               :=  WSAdvValue( oResponse,"_CEI","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccity              :=  WSAdvValue( oResponse,"_CITY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccompanyName       :=  WSAdvValue( oResponse,"_COMPANYNAME","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ccountry           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cemail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cfederalId         :=  WSAdvValue( oResponse,"_FEDERALID","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cneighborhood      :=  WSAdvValue( oResponse,"_NEIGHBORHOOD","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::nphone             :=  WSAdvValue( oResponse,"_PHONE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::nphoneCode         :=  WSAdvValue( oResponse,"_PHONECODE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cstate             :=  WSAdvValue( oResponse,"_STATE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::czipCode           :=  WSAdvValue( oResponse,"_ZIPCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure statusDTO

WSSTRUCT LegalPersonIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LegalPersonIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LegalPersonIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT LegalPersonIntegrationServiceBeanService_statusDTO
	Local oClone := LegalPersonIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LegalPersonIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return
