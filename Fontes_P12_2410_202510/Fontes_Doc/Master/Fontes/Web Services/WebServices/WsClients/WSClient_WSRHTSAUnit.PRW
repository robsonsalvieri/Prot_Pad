#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/UnitIntegrationServiceBean?wsdl
Gerado em        12/18/18 09:35:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _PDVSJRS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUnitIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSUnitIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD remove
	WSMETHOD removeUnitAbsenceReason
	WSMETHOD insertUnitAbsenceReason
	WSMETHOD insertOrUpdate

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0	               		AS UnitIntegrationServiceBeanService_statusDTO
	WSDATA   oWSstatusDTO              AS UnitIntegrationServiceBeanService_statusDTO
	WSDATA   oWSunitAbsenceReasonInsertDTO AS UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	WSDATA   oWSunitDTO                AS UnitIntegrationServiceBeanService_unitDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUnitIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUnitIntegrationServiceBeanService
	::oWSarg0       				:= {} // Array Of  UnitIntegrationServiceBeanService_STATUSDTO():New()
	::oWSstatusDTO       := {} // Array Of  UnitIntegrationServiceBeanService_STATUSDTO():New()
	::oWSunitAbsenceReasonInsertDTO := {} // Array Of  UnitIntegrationServiceBeanService_UNITABSENCEREASONINSERTDTO():New()
	::oWSunitDTO         := {} // Array Of  UnitIntegrationServiceBeanService_UNITDTO():New()
Return

WSMETHOD RESET WSCLIENT WSUnitIntegrationServiceBeanService
	::oWSarg0       := NIL 
	::carg0              := NIL 
	::oWSstatusDTO       := NIL 
	::oWSunitAbsenceReasonInsertDTO := NIL 
	::oWSunitDTO         := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUnitIntegrationServiceBeanService
Local oClone := WSUnitIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:oWSarg0  :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )

	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSunitAbsenceReasonInsertDTO :=  IIF(::oWSunitAbsenceReasonInsertDTO = NIL , NIL ,::oWSunitAbsenceReasonInsertDTO:Clone() )
	oClone:oWSunitDTO    :=  IIF(::oWSunitDTO = NIL , NIL ,::oWSunitDTO:Clone() )
Return oClone

// WSDL Method remove of Service WSUnitIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUnitIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://unit.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://unit.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UnitIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UnitIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUnitAbsenceReason of Service WSUnitIntegrationServiceBeanService

WSMETHOD removeUnitAbsenceReason WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUnitIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUnitAbsenceReason xmlns="http://unit.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "unitAbsenceReasonRemoveDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</removeUnitAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://unit.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UnitIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUNITABSENCEREASONRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UnitIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUnitAbsenceReason of Service WSUnitIntegrationServiceBeanService

WSMETHOD insertUnitAbsenceReason WSSEND oWSarg0 WSRECEIVE oWSunitAbsenceReasonInsertDTO WSCLIENT WSUnitIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUnitAbsenceReason xmlns="http://unit.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "unitAbsenceReasonInsertDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertUnitAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://unit.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UnitIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUNITABSENCEREASONRESPONSE:_RETURN","unitAbsenceReasonInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSunitAbsenceReasonInsertDTO,UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():New()) , ::oWSunitAbsenceReasonInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSUnitIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSunitDTO WSCLIENT WSUnitIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://unit.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "unitDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://unit.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UnitIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","unitDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSunitDTO,UnitIntegrationServiceBeanService_unitDTO():New()) , ::oWSunitDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure statusDTO

WSSTRUCT UnitIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UnitIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UnitIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT UnitIntegrationServiceBeanService_statusDTO
	Local oClone := UnitIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UnitIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure unitAbsenceReasonInsertDTO

WSSTRUCT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
		WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   lblockAccess              AS boolean OPTIONAL
	WSDATA   nrestrictedDaysQuantity   AS int OPTIONAL
	WSDATA   cunitExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
Return

WSMETHOD CLONE WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	Local oClone := UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:lblockAccess         := ::lblockAccess
	oClone:nrestrictedDaysQuantity := ::nrestrictedDaysQuantity
	oClone:cunitExternalKey     := ::cunitExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("blockAccess", ::lblockAccess, ::lblockAccess , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("restrictedDaysQuantity", ::nrestrictedDaysQuantity, ::nrestrictedDaysQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("unitExternalKey", ::cunitExternalKey, ::cunitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::lblockAccess       :=  WSAdvValue( oResponse,"_BLOCKACCESS","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::nrestrictedDaysQuantity :=  WSAdvValue( oResponse,"_RESTRICTEDDAYSQUANTITY","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cunitExternalKey   :=  WSAdvValue( oResponse,"_UNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure unitDTO

WSSTRUCT UnitIntegrationServiceBeanService_unitDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   clegalPersonExternalKey   AS string OPTIONAL
	WSDATA   oWSunitAbsenceReasonDTOCol AS UnitIntegrationServiceBeanService_unitAbsenceReasonDTO OPTIONAL
	WSDATA   nunitType                 AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UnitIntegrationServiceBeanService_unitDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UnitIntegrationServiceBeanService_unitDTO
	::oWSunitAbsenceReasonDTOCol := {} // Array Of  UnitIntegrationServiceBeanService_UNITABSENCEREASONDTO():New()
Return

WSMETHOD CLONE WSCLIENT UnitIntegrationServiceBeanService_unitDTO
	Local oClone := UnitIntegrationServiceBeanService_unitDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
	oClone:clegalPersonExternalKey := ::clegalPersonExternalKey
	oClone:oWSunitAbsenceReasonDTOCol := NIL
	If ::oWSunitAbsenceReasonDTOCol <> NIL 
		oClone:oWSunitAbsenceReasonDTOCol := {}
		aEval( ::oWSunitAbsenceReasonDTOCol , { |x| aadd( oClone:oWSunitAbsenceReasonDTOCol , x:Clone() ) } )
	Endif 
	oClone:nunitType            := ::nunitType
Return oClone

WSMETHOD SOAPSEND WSCLIENT UnitIntegrationServiceBeanService_unitDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("legalPersonExternalKey", ::clegalPersonExternalKey, ::clegalPersonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSunitAbsenceReasonDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("unitAbsenceReasonDTOCol", x , x , "unitAbsenceReasonDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("unitType", ::nunitType, ::nunitType , "int", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UnitIntegrationServiceBeanService_unitDTO
	Local nRElem4, oNodes4, nTElem4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::clegalPersonExternalKey :=  WSAdvValue( oResponse,"_LEGALPERSONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes4 :=  WSAdvValue( oResponse,"_UNITABSENCEREASONDTOCOL","unitAbsenceReasonDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4 
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oWSunitAbsenceReasonDTOCol , UnitIntegrationServiceBeanService_unitAbsenceReasonDTO():New() )
			::oWSunitAbsenceReasonDTOCol[len(::oWSunitAbsenceReasonDTOCol)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
	::nunitType          :=  WSAdvValue( oResponse,"_UNITTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
Return

// WSDL Data Structure unitAbsenceReasonDTO

WSSTRUCT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   lblockAccess              AS boolean OPTIONAL
	WSDATA   nrestrictedDaysQuantity   AS int OPTIONAL
	WSDATA   cunitExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
Return

WSMETHOD CLONE WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
	Local oClone := UnitIntegrationServiceBeanService_unitAbsenceReasonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:lblockAccess         := ::lblockAccess
	oClone:nrestrictedDaysQuantity := ::nrestrictedDaysQuantity
	oClone:cunitExternalKey     := ::cunitExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("blockAccess", ::lblockAccess, ::lblockAccess , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("restrictedDaysQuantity", ::nrestrictedDaysQuantity, ::nrestrictedDaysQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("unitExternalKey", ::cunitExternalKey, ::cunitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UnitIntegrationServiceBeanService_unitAbsenceReasonDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::lblockAccess       :=  WSAdvValue( oResponse,"_BLOCKACCESS","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::nrestrictedDaysQuantity :=  WSAdvValue( oResponse,"_RESTRICTEDDAYSQUANTITY","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cunitExternalKey   :=  WSAdvValue( oResponse,"_UNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


