#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean?wsdl
Gerado em        12/18/18 10:06:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _PMZMNKO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAbsenceReasonIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSAbsenceReasonIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD removeUnitAbsenceReason
	WSMETHOD remove
	WSMETHOD insertOrUpdate
	WSMETHOD insertUserAbsenceReason
	WSMETHOD removeUserAbsenceReason
	WSMETHOD insertUnitAbsenceReason

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     		AS string
	WSDATA   oWSarg0                   AS AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
	WSDATA   oWSarg1                		AS AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
	WSDATA   oWSstatusDTO              AS AbsenceReasonIntegrationServiceBeanService_statusDTO
	WSDATA   oWSabsenceReasonDTO       AS AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	WSDATA   oWSuserAbsenceReasonInsertDTO AS AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	WSDATA   oWSunitAbsenceReasonInsertDTO AS AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	WSDATA   oWSuserAbsenceReasonRemoveDTO 	AS AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
	::oWSarg0            := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_UNITABSENCEREASONREMOVEDTO():New()
	::oWSarg1            			:= {} // Array Of  AbsenceReasonIntegrationServiceBeanService_USERABSENCEREASONREMOVEDTO():New()
	::oWSstatusDTO       := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_STATUSDTO():New()
	::oWSabsenceReasonDTO := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_ABSENCEREASONDTO():New()
	::oWSuserAbsenceReasonInsertDTO := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_USERABSENCEREASONINSERTDTO():New()
	::oWSunitAbsenceReasonInsertDTO := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_UNITABSENCEREASONINSERTDTO():New()
	::oWSuserAbsenceReasonRemoveDTO := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_USERABSENCEREASONREMOVEDTO():New()
Return

WSMETHOD RESET WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
	::carg0              			:= NIL 
	::oWSarg0           			:= NIL 
	::oWSarg1            			:= NIL 
	::oWSstatusDTO       := NIL 
	::oWSabsenceReasonDTO := NIL 
	::oWSuserAbsenceReasonInsertDTO := NIL 
	::oWSunitAbsenceReasonInsertDTO := NIL 
	::oWSuserAbsenceReasonRemoveDTO := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local oClone := WSAbsenceReasonIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         				 := ::carg0
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSarg1       :=  IIF(::oWSarg1 = NIL , NIL ,::oWSarg1:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSabsenceReasonDTO :=  IIF(::oWSabsenceReasonDTO = NIL , NIL ,::oWSabsenceReasonDTO:Clone() )
	oClone:oWSuserAbsenceReasonInsertDTO :=  IIF(::oWSuserAbsenceReasonInsertDTO = NIL , NIL ,::oWSuserAbsenceReasonInsertDTO:Clone() )
	oClone:oWSunitAbsenceReasonInsertDTO :=  IIF(::oWSunitAbsenceReasonInsertDTO = NIL , NIL ,::oWSunitAbsenceReasonInsertDTO:Clone() )
	oClone:oWSuserAbsenceReasonRemoveDTO :=  IIF(::oWSuserAbsenceReasonRemoveDTO = NIL , NIL ,::oWSuserAbsenceReasonRemoveDTO:Clone() )
	
Return oClone

// WSDL Method removeUnitAbsenceReason of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD removeUnitAbsenceReason WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUnitAbsenceReason xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "unitAbsenceReasonRemoveDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</removeUnitAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUNITABSENCEREASONRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,AbsenceReasonIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,AbsenceReasonIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSabsenceReasonDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "absenceReasonDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","absenceReasonDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSabsenceReasonDTO,AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO():New()) , ::oWSabsenceReasonDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserAbsenceReason of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD insertUserAbsenceReason WSSEND oWSarg0 WSRECEIVE oWSuserAbsenceReasonInsertDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserAbsenceReason xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userAbsenceReasonInsertDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertUserAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERABSENCEREASONRESPONSE:_RETURN","userAbsenceReasonInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserAbsenceReasonInsertDTO,AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO():New()) , ::oWSuserAbsenceReasonInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserAbsenceReason of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD removeUserAbsenceReason WSSEND oWSarg1 WSRECEIVE oWSstatusDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserAbsenceReason xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg1, oWSarg1 , "userAbsenceReasonRemoveDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</removeUserAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERABSENCEREASONRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,AbsenceReasonIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUnitAbsenceReason of Service WSAbsenceReasonIntegrationServiceBeanService

WSMETHOD insertUnitAbsenceReason WSSEND oWSarg0 WSRECEIVE oWSunitAbsenceReasonInsertDTO WSCLIENT WSAbsenceReasonIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUnitAbsenceReason xmlns="http://absencereason.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "unitAbsenceReasonInsertDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertUnitAbsenceReason>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://absencereason.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/AbsenceReasonIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUNITABSENCEREASONRESPONSE:_RETURN","unitAbsenceReasonInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSunitAbsenceReasonInsertDTO,AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():New()) , ::oWSunitAbsenceReasonInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure unitAbsenceReasonRemoveDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
	WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   cunitExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO():NEW()
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:cunitExternalKey     := ::cunitExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonRemoveDTO
	Local cSoap := ""
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("unitExternalKey", ::cunitExternalKey, ::cunitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure 	userAbsenceReasonRemoveDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO():NEW()
	oClone:cstatuscode          		:= ::cstatuscode
	oClone:cstatusdescription   		:= ::cstatusdescription
	oClone:cabsenceReasonExternalKey 	:= ::cabsenceReasonExternalKey
	oClone:cinitialDate     			:= ::cinitialDate
	oClone:cuserExternalKey     		:= ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonRemoveDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure statusDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_statusDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure absenceReasonDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   nsituationType            AS int OPTIONAL
	WSDATA   oWSunitAbsenceReasonDTOCol AS AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO OPTIONAL
	WSDATA   oWSuserAbsenceReasonDTOCol AS AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	::oWSunitAbsenceReasonDTOCol := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_UNITABSENCEREASONDTO():New()
	::oWSuserAbsenceReasonDTOCol := {} // Array Of  AbsenceReasonIntegrationServiceBeanService_USERABSENCEREASONDTO():New()
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
	oClone:nsituationType       := ::nsituationType
	oClone:oWSunitAbsenceReasonDTOCol := NIL
	If ::oWSunitAbsenceReasonDTOCol <> NIL 
		oClone:oWSunitAbsenceReasonDTOCol := {}
		aEval( ::oWSunitAbsenceReasonDTOCol , { |x| aadd( oClone:oWSunitAbsenceReasonDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserAbsenceReasonDTOCol := NIL
	If ::oWSuserAbsenceReasonDTOCol <> NIL 
		oClone:oWSuserAbsenceReasonDTOCol := {}
		aEval( ::oWSuserAbsenceReasonDTOCol , { |x| aadd( oClone:oWSuserAbsenceReasonDTOCol , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("situationType", ::nsituationType, ::nsituationType , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSunitAbsenceReasonDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("unitAbsenceReasonDTOCol", x , x , "unitAbsenceReasonDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserAbsenceReasonDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userAbsenceReasonDTOCol", x , x , "userAbsenceReasonDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_absenceReasonDTO
	Local nRElem4, oNodes4, nTElem4
	Local nRElem5, oNodes5, nTElem5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::nsituationType     :=  WSAdvValue( oResponse,"_SITUATIONTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	oNodes4 :=  WSAdvValue( oResponse,"_UNITABSENCEREASONDTOCOL","unitAbsenceReasonDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4 
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oWSunitAbsenceReasonDTOCol , AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO():New() )
			::oWSunitAbsenceReasonDTOCol[len(::oWSunitAbsenceReasonDTOCol)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
	oNodes5 :=  WSAdvValue( oResponse,"_USERABSENCEREASONDTOCOL","userAbsenceReasonDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem5 := len(oNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( oNodes5[nRElem5] )
			aadd(::oWSuserAbsenceReasonDTOCol , AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO():New() )
			::oWSuserAbsenceReasonDTOCol[len(::oWSuserAbsenceReasonDTOCol)]:SoapRecv(oNodes5[nRElem5])
		Endif
	Next
Return

// WSDL Data Structure userAbsenceReasonInsertDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure unitAbsenceReasonInsertDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
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

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:lblockAccess         := ::lblockAccess
	oClone:nrestrictedDaysQuantity := ::nrestrictedDaysQuantity
	oClone:cunitExternalKey     := ::cunitExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("blockAccess", ::lblockAccess, ::lblockAccess , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("restrictedDaysQuantity", ::nrestrictedDaysQuantity, ::nrestrictedDaysQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("unitExternalKey", ::cunitExternalKey, ::cunitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::lblockAccess       :=  WSAdvValue( oResponse,"_BLOCKACCESS","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::nrestrictedDaysQuantity :=  WSAdvValue( oResponse,"_RESTRICTEDDAYSQUANTITY","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cunitExternalKey   :=  WSAdvValue( oResponse,"_UNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure unitAbsenceReasonDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
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

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:lblockAccess         := ::lblockAccess
	oClone:nrestrictedDaysQuantity := ::nrestrictedDaysQuantity
	oClone:cunitExternalKey     := ::cunitExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("blockAccess", ::lblockAccess, ::lblockAccess , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("restrictedDaysQuantity", ::nrestrictedDaysQuantity, ::nrestrictedDaysQuantity , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("unitExternalKey", ::cunitExternalKey, ::cunitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_unitAbsenceReasonDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	:::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::lblockAccess       :=  WSAdvValue( oResponse,"_BLOCKACCESS","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::nrestrictedDaysQuantity :=  WSAdvValue( oResponse,"_RESTRICTEDDAYSQUANTITY","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cunitExternalKey   :=  WSAdvValue( oResponse,"_UNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userAbsenceReasonDTO

WSSTRUCT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cabsenceReasonExternalKey AS string OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
Return

WSMETHOD CLONE WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
	Local oClone := AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cabsenceReasonExternalKey := ::cabsenceReasonExternalKey
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("absenceReasonExternalKey", ::cabsenceReasonExternalKey, ::cabsenceReasonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AbsenceReasonIntegrationServiceBeanService_userAbsenceReasonDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cabsenceReasonExternalKey :=  WSAdvValue( oResponse,"_ABSENCEREASONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


