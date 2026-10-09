#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/UserIntegrationServiceBean?wsdl
Gerado em        09/25/18 10:38:23
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QSUJOMU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUserIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSUserIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertUserPositionLevel
	WSMETHOD insertUserShiftWork
	WSMETHOD removeUserShiftWork
	WSMETHOD removeUserAllocationUnit
	WSMETHOD updateExternalKey
	WSMETHOD insertUserLocation
	WSMETHOD updateUserRoleBadge
	WSMETHOD removeUserRoleBadge
	WSMETHOD removeUserPositionLevel
	WSMETHOD remove
	WSMETHOD insertUserRoleBadge
	WSMETHOD insertUserCostCenter
	WSMETHOD insertUserAllocationUnit
	WSMETHOD insertOrUpdate
	WSMETHOD removeUserCostCenter
	WSMETHOD removeUserLocation

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSarg0                   AS UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	WSDATA   oWSuserPositionLevelInsertDTO AS UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	WSDATA   oWSuserShiftWorkInsertDTO AS UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	WSDATA   oWSstatusDTO              AS UserIntegrationServiceBeanService_statusDTO
	WSDATA   oWSexternalKeyUpdateDTO   AS UserIntegrationServiceBeanService_externalKeyUpdateDTO
	WSDATA   oWSuserLocationInsertDTO  AS UserIntegrationServiceBeanService_userLocationInsertDTO
	WSDATA   oWSuserRoleBadgeInsertDTO AS UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	WSDATA   oWSuserCostCenterInsertDTO AS UserIntegrationServiceBeanService_userCostCenterInsertDTO
	WSDATA   oWSuserAllocationUnitInsertDTO AS UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	WSDATA   oWSuserDTO                AS UserIntegrationServiceBeanService_userDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUserIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180727 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUserIntegrationServiceBeanService
	::oWSarg0            := {} // Array Of  UserIntegrationServiceBeanService_USERPOSITIONLEVELINSERTDTO():New()
	::oWSuserPositionLevelInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERPOSITIONLEVELINSERTDTO():New()
	::oWSuserShiftWorkInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERSHIFTWORKINSERTDTO():New()
	::oWSstatusDTO       := {} // Array Of  UserIntegrationServiceBeanService_STATUSDTO():New()
	::oWSexternalKeyUpdateDTO := UserIntegrationServiceBeanService_EXTERNALKEYUPDATEDTO():New()
	::oWSuserLocationInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERLOCATIONINSERTDTO():New()
	::oWSuserRoleBadgeInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERROLEBADGEINSERTDTO():New()
	::oWSuserCostCenterInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERCOSTCENTERINSERTDTO():New()
	::oWSuserAllocationUnitInsertDTO := {} // Array Of  UserIntegrationServiceBeanService_USERALLOCATIONUNITINSERTDTO():New()
	::oWSuserDTO         := {} // Array Of  UserIntegrationServiceBeanService_USERDTO():New()
Return

WSMETHOD RESET WSCLIENT WSUserIntegrationServiceBeanService
	::oWSarg0            := NIL 
	::oWSuserPositionLevelInsertDTO := NIL 
	::oWSuserShiftWorkInsertDTO := NIL 
	::oWSstatusDTO       := NIL 
	::oWSexternalKeyUpdateDTO := NIL 
	::oWSuserLocationInsertDTO := NIL 
	::oWSuserRoleBadgeInsertDTO := NIL 
	::oWSuserCostCenterInsertDTO := NIL 
	::oWSuserAllocationUnitInsertDTO := NIL 
	::oWSuserDTO         := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUserIntegrationServiceBeanService
Local oClone := WSUserIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSuserPositionLevelInsertDTO :=  IIF(::oWSuserPositionLevelInsertDTO = NIL , NIL ,::oWSuserPositionLevelInsertDTO:Clone() )
	oClone:oWSuserShiftWorkInsertDTO :=  IIF(::oWSuserShiftWorkInsertDTO = NIL , NIL ,::oWSuserShiftWorkInsertDTO:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSexternalKeyUpdateDTO :=  IIF(::oWSexternalKeyUpdateDTO = NIL , NIL ,::oWSexternalKeyUpdateDTO:Clone() )
	oClone:oWSuserLocationInsertDTO :=  IIF(::oWSuserLocationInsertDTO = NIL , NIL ,::oWSuserLocationInsertDTO:Clone() )
	oClone:oWSuserRoleBadgeInsertDTO :=  IIF(::oWSuserRoleBadgeInsertDTO = NIL , NIL ,::oWSuserRoleBadgeInsertDTO:Clone() )
	oClone:oWSuserCostCenterInsertDTO :=  IIF(::oWSuserCostCenterInsertDTO = NIL , NIL ,::oWSuserCostCenterInsertDTO:Clone() )
	oClone:oWSuserAllocationUnitInsertDTO :=  IIF(::oWSuserAllocationUnitInsertDTO = NIL , NIL ,::oWSuserAllocationUnitInsertDTO:Clone() )
	oClone:oWSuserDTO    :=  IIF(::oWSuserDTO = NIL , NIL ,::oWSuserDTO:Clone() )
Return oClone

// WSDL Method insertUserPositionLevel of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserPositionLevel WSSEND oWSarg0 WSRECEIVE oWSuserPositionLevelInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserPositionLevel xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userPositionLevelInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertUserPositionLevel>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERPOSITIONLEVELRESPONSE:_RETURN","userPositionLevelInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserPositionLevelInsertDTO,UserIntegrationServiceBeanService_userPositionLevelInsertDTO():New()) , ::oWSuserPositionLevelInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserShiftWork of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserShiftWork WSSEND oWSarg0 WSRECEIVE oWSuserShiftWorkInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserShiftWork xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userShiftWorkInsertDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertUserShiftWork>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERSHIFTWORKRESPONSE:_RETURN","userShiftWorkInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserShiftWorkInsertDTO,UserIntegrationServiceBeanService_userShiftWorkInsertDTO():New()) , ::oWSuserShiftWorkInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserShiftWork of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserShiftWork WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserShiftWork xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userShiftWorkRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserShiftWork>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERSHIFTWORKRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserAllocationUnit of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserAllocationUnit WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserAllocationUnit xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userAllocationUnitRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserAllocationUnit>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERALLOCATIONUNITRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateExternalKey of Service WSUserIntegrationServiceBeanService

WSMETHOD updateExternalKey WSSEND oWSarg0 WSRECEIVE oWSexternalKeyUpdateDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<updateExternalKey xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "externalKeyUpdateDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</updateExternalKey>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
::oWSexternalKeyUpdateDTO:SoapRecv( WSAdvValue( oXmlRet,"_UPDATEEXTERNALKEYRESPONSE:_RETURN","externalKeyUpdateDTO",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserLocation of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserLocation WSSEND oWSarg0 WSRECEIVE oWSuserLocationInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserLocation xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userLocationInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertUserLocation>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERLOCATIONRESPONSE:_RETURN","userLocationInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserLocationInsertDTO,UserIntegrationServiceBeanService_userLocationInsertDTO():New()) , ::oWSuserLocationInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateUserRoleBadge of Service WSUserIntegrationServiceBeanService

WSMETHOD updateUserRoleBadge WSSEND oWSarg0 WSRECEIVE oWSuserRoleBadgeInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<updateUserRoleBadge xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userRoleBadgeInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</updateUserRoleBadge>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_UPDATEUSERROLEBADGERESPONSE:_RETURN","userRoleBadgeInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserRoleBadgeInsertDTO,UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():New()) , ::oWSuserRoleBadgeInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserRoleBadge of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserRoleBadge WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserRoleBadge xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userRoleBadgeRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserRoleBadge>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERROLEBADGERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserPositionLevel of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserPositionLevel WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserPositionLevel xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userPositionLevelRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserPositionLevel>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERPOSITIONLEVELRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSUserIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserRoleBadge of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserRoleBadge WSSEND oWSarg0 WSRECEIVE oWSuserRoleBadgeInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserRoleBadge xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userRoleBadgeInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertUserRoleBadge>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERROLEBADGERESPONSE:_RETURN","userRoleBadgeInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserRoleBadgeInsertDTO,UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():New()) , ::oWSuserRoleBadgeInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserCostCenter of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserCostCenter WSSEND oWSarg0 WSRECEIVE oWSuserCostCenterInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserCostCenter xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userCostCenterInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertUserCostCenter>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERCOSTCENTERRESPONSE:_RETURN","userCostCenterInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserCostCenterInsertDTO,UserIntegrationServiceBeanService_userCostCenterInsertDTO():New()) , ::oWSuserCostCenterInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUserAllocationUnit of Service WSUserIntegrationServiceBeanService

WSMETHOD insertUserAllocationUnit WSSEND oWSarg0 WSRECEIVE oWSuserAllocationUnitInsertDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertUserAllocationUnit xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userAllocationUnitInsertDTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</insertUserAllocationUnit>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTUSERALLOCATIONUNITRESPONSE:_RETURN","userAllocationUnitInsertDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserAllocationUnitInsertDTO,UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():New()) , ::oWSuserAllocationUnitInsertDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSUserIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSuserDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","userDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSuserDTO,UserIntegrationServiceBeanService_userDTO():New()) , ::oWSuserDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserCostCenter of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserCostCenter WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserCostCenter xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userCostCenterRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserCostCenter>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERCOSTCENTERRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeUserLocation of Service WSUserIntegrationServiceBeanService

WSMETHOD removeUserLocation WSSEND oWSarg0 WSRECEIVE oWSstatusDTO WSCLIENT WSUserIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeUserLocation xmlns="http://user.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "userLocationRemoveDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</removeUserLocation>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://user.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/UserIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEUSERLOCATIONRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,UserIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure userPositionLevelInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cpositionLevelExternalKey AS string OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userPositionLevelInsertDTO():NEW()
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cpositionLevelExternalKey := ::cpositionLevelExternalKey
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("positionLevelExternalKey", ::cpositionLevelExternalKey, ::cpositionLevelExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userPositionLevelInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cpositionLevelExternalKey :=  WSAdvValue( oResponse,"_POSITIONLEVELEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userShiftWorkInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	WSDATA   cendDate					AS dateTime OPTIONAL
	WSDATA   cinitialDate				AS dateTime OPTIONAL
	WSDATA   cshiftWorkExternalKey		AS string OPTIONAL
	WSDATA   cuserExternalKey			AS string OPTIONAL
	WSDATA   cInitialScaleBaseDate		AS string OPTIONAL
	WSDATA   cProcessDate				AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userShiftWorkInsertDTO():NEW()
	oClone:cendDate					:= ::cendDate
	oClone:cinitialDate				:= ::cinitialDate
	oClone:cshiftWorkExternalKey	:= ::cshiftWorkExternalKey
	oClone:cuserExternalKey			:= ::cuserExternalKey
	oClone:cInitialScaleBaseDate	:= ::cInitialScaleBaseDate
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shiftWorkExternalKey", ::cshiftWorkExternalKey, ::cshiftWorkExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialScaleBaseDate", ::cInitialScaleBaseDate, ::cInitialScaleBaseDate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("processDate", ::cProcessDate, ::cProcessDate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userShiftWorkInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cendDate					:=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate				:=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cshiftWorkExternalKey		:=  WSAdvValue( oResponse,"_SHIFTWORKEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey			:=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cInitialScaleBaseDate		:=  WSAdvValue( oResponse,"_INITIALSCALEBASEDATE","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure statusDTO

WSSTRUCT UserIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_statusDTO
	Local oClone := UserIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure externalKeyUpdateDTO

WSSTRUCT UserIntegrationServiceBeanService_externalKeyUpdateDTO
	WSDATA   cexternalKeyNew           AS string OPTIONAL
	WSDATA   cexternalKeyOld           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_externalKeyUpdateDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_externalKeyUpdateDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_externalKeyUpdateDTO
	Local oClone := UserIntegrationServiceBeanService_externalKeyUpdateDTO():NEW()
	oClone:cexternalKeyNew      := ::cexternalKeyNew
	oClone:cexternalKeyOld      := ::cexternalKeyOld
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_externalKeyUpdateDTO
	Local cSoap := ""
	cSoap += WSSoapValue("externalKeyNew", ::cexternalKeyNew, ::cexternalKeyNew , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKeyOld", ::cexternalKeyOld, ::cexternalKeyOld , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_externalKeyUpdateDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKeyNew    :=  WSAdvValue( oResponse,"_EXTERNALKEYNEW","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKeyOld    :=  WSAdvValue( oResponse,"_EXTERNALKEYOLD","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userLocationInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userLocationInsertDTO
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   clocationExternalKey      AS string OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userLocationInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userLocationInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userLocationInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userLocationInsertDTO():NEW()
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:clocationExternalKey := ::clocationExternalKey
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userLocationInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("locationExternalKey", ::clocationExternalKey, ::clocationExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userLocationInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::clocationExternalKey :=  WSAdvValue( oResponse,"_LOCATIONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userRoleBadgeInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	WSDATA   cbadgeNumber              AS string OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cinitialDateOld           AS dateTime OPTIONAL
	WSDATA   cproviderUnitExternalKey  AS string OPTIONAL
	WSDATA   cregistry                 AS string OPTIONAL
	WSDATA   croleType                 AS string OPTIONAL
	WSDATA   ctakerUnitExternalKey     AS string OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSDATA   cfilial		           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():NEW()
	oClone:cbadgeNumber         := ::cbadgeNumber
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cinitialDateOld      := ::cinitialDateOld
	oClone:cproviderUnitExternalKey := ::cproviderUnitExternalKey
	oClone:cregistry            := ::cregistry
	oClone:croleType            := ::croleType
	oClone:ctakerUnitExternalKey := ::ctakerUnitExternalKey
	oClone:cuserExternalKey     := ::cuserExternalKey
	oClone:cfilial				:= ::cfilial
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	Local cSoap := ""
	Local lTsa 	:= SUPERGETMV("MV_TSAINT",,.F., ::cfilial)

	cSoap += WSSoapValue("badgeNumber", ::cbadgeNumber, ::cbadgeNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDateOld", ::cinitialDateOld, ::cinitialDateOld , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("providerUnitExternalKey", ::cproviderUnitExternalKey, ::cproviderUnitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("registry", ::cregistry, ::cregistry , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	If !lTsa
		cSoap += WSSoapValue("roleType", ::croleType, ::croleType , "string", .F. , .F., 0 , NIL, .F.,.F.)
	Else
		cSoap += WSSoapValue("roleType", ::croleType, ::croleType , "int", .F. , .F., 0 , NIL, .F.,.F.)
	EndIf
	cSoap += WSSoapValue("takerUnitExternalKey", ::ctakerUnitExternalKey, ::ctakerUnitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userRoleBadgeInsertDTO
	Local lTsa  := SUPERGETMV("MV_TSAINT",,.F., ::cfilial)

	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cbadgeNumber       :=  WSAdvValue( oResponse,"_BADGENUMBER","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDateOld    :=  WSAdvValue( oResponse,"_INITIALDATEOLD","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cproviderUnitExternalKey :=  WSAdvValue( oResponse,"_PROVIDERUNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cregistry          :=  WSAdvValue( oResponse,"_REGISTRY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	If !lTsa
		::croleType      :=  WSAdvValue( oResponse,"_ROLETYPE","string",NIL,NIL,NIL,"N",NIL,"tns")
	Else
		::croleType      :=  WSAdvValue( oResponse,"_ROLETYPE","int",NIL,NIL,NIL,"N",NIL,"tns")
	EndIf
	::ctakerUnitExternalKey :=  WSAdvValue( oResponse,"_TAKERUNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userCostCenterInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userCostCenterInsertDTO
	WSDATA   ccostCenterExternalKey    AS string OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userCostCenterInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userCostCenterInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userCostCenterInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userCostCenterInsertDTO():NEW()
	oClone:ccostCenterExternalKey := ::ccostCenterExternalKey
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userCostCenterInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("costCenterExternalKey", ::ccostCenterExternalKey, ::ccostCenterExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userCostCenterInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccostCenterExternalKey :=  WSAdvValue( oResponse,"_COSTCENTEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userAllocationUnitInsertDTO

WSSTRUCT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	WSDATA   callocationUnitExternalKey AS string OPTIONAL
	WSDATA   cendDate                  AS dateTime OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   cuserExternalKey          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	Local oClone := UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():NEW()
	oClone:callocationUnitExternalKey := ::callocationUnitExternalKey
	oClone:cendDate             := ::cendDate
	oClone:cinitialDate         := ::cinitialDate
	oClone:cuserExternalKey     := ::cuserExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	Local cSoap := ""
	cSoap += WSSoapValue("allocationUnitExternalKey", ::callocationUnitExternalKey, ::callocationUnitExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endDate", ::cendDate, ::cendDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userExternalKey", ::cuserExternalKey, ::cuserExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userAllocationUnitInsertDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::callocationUnitExternalKey :=  WSAdvValue( oResponse,"_ALLOCATIONUNITEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendDate           :=  WSAdvValue( oResponse,"_ENDDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cuserExternalKey   :=  WSAdvValue( oResponse,"_USEREXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure userDTO

WSSTRUCT UserIntegrationServiceBeanService_userDTO
	WSDATA   cbadgeNumber              AS string OPTIONAL
	WSDATA   lcontrolDoubleMarking     AS boolean OPTIONAL
	WSDATA   lexceptionREP             AS boolean OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cfireDate                 AS dateTime OPTIONAL
	WSDATA   chiringDate               AS dateTime OPTIONAL
	WSDATA   lflexibleInterval         AS boolean OPTIONAL
	WSDATA   lfreeAccess               AS boolean OPTIONAL
	WSDATA   clastMarkDate             AS dateTime OPTIONAL
	WSDATA   cnaturalPersonExternalKey AS string OPTIONAL
	WSDATA   cpis                      AS string OPTIONAL
	WSDATA   cfilial		           AS string OPTIONAL
	WSDATA   oWSuserAllocationUnitDTOCol AS UserIntegrationServiceBeanService_userAllocationUnitInsertDTO OPTIONAL
	WSDATA   oWSuserCostCenterDTOCol   AS UserIntegrationServiceBeanService_userCostCenterInsertDTO OPTIONAL
	WSDATA   oWSuserLocationDTOCol     AS UserIntegrationServiceBeanService_userLocationInsertDTO OPTIONAL
	WSDATA   oWSuserPositionLevelDTOCol AS UserIntegrationServiceBeanService_userPositionLevelInsertDTO OPTIONAL
	WSDATA   oWSuserRoleBadgeDTOCol    AS UserIntegrationServiceBeanService_userRoleBadgeInsertDTO OPTIONAL
	WSDATA   oWSuserShiftWorkDTOCol    AS UserIntegrationServiceBeanService_userShiftWorkInsertDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UserIntegrationServiceBeanService_userDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UserIntegrationServiceBeanService_userDTO
	::oWSuserAllocationUnitDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERALLOCATIONUNITINSERTDTO():New()
	::oWSuserCostCenterDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERCOSTCENTERINSERTDTO():New()
	::oWSuserLocationDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERLOCATIONINSERTDTO():New()
	::oWSuserPositionLevelDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERPOSITIONLEVELINSERTDTO():New()
	::oWSuserRoleBadgeDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERROLEBADGEINSERTDTO():New()
	::oWSuserShiftWorkDTOCol := {} // Array Of  UserIntegrationServiceBeanService_USERSHIFTWORKINSERTDTO():New()
Return

WSMETHOD CLONE WSCLIENT UserIntegrationServiceBeanService_userDTO
	Local oClone := UserIntegrationServiceBeanService_userDTO():NEW()
	oClone:cbadgeNumber         := ::cbadgeNumber
	oClone:lcontrolDoubleMarking := ::lcontrolDoubleMarking
	oClone:lexceptionREP        := ::lexceptionREP
	oClone:cexternalKey         := ::cexternalKey
	oClone:cfireDate            := ::cfireDate
	oClone:chiringDate          := ::chiringDate
	oClone:lflexibleInterval    := ::lflexibleInterval
	oClone:lfreeAccess          := ::lfreeAccess
	oClone:clastMarkDate        := ::clastMarkDate
	oClone:cnaturalPersonExternalKey := ::cnaturalPersonExternalKey
	oClone:cpis                 := ::cpis
	oClone:cfilial				:= ::cfilial
	oClone:oWSuserAllocationUnitDTOCol := NIL
	If ::oWSuserAllocationUnitDTOCol <> NIL 
		oClone:oWSuserAllocationUnitDTOCol := {}
		aEval( ::oWSuserAllocationUnitDTOCol , { |x| aadd( oClone:oWSuserAllocationUnitDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserCostCenterDTOCol := NIL
	If ::oWSuserCostCenterDTOCol <> NIL 
		oClone:oWSuserCostCenterDTOCol := {}
		aEval( ::oWSuserCostCenterDTOCol , { |x| aadd( oClone:oWSuserCostCenterDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserLocationDTOCol := NIL
	If ::oWSuserLocationDTOCol <> NIL 
		oClone:oWSuserLocationDTOCol := {}
		aEval( ::oWSuserLocationDTOCol , { |x| aadd( oClone:oWSuserLocationDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserPositionLevelDTOCol := NIL
	If ::oWSuserPositionLevelDTOCol <> NIL 
		oClone:oWSuserPositionLevelDTOCol := {}
		aEval( ::oWSuserPositionLevelDTOCol , { |x| aadd( oClone:oWSuserPositionLevelDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserRoleBadgeDTOCol := NIL
	If ::oWSuserRoleBadgeDTOCol <> NIL 
		oClone:oWSuserRoleBadgeDTOCol := {}
		aEval( ::oWSuserRoleBadgeDTOCol , { |x| aadd( oClone:oWSuserRoleBadgeDTOCol , x:Clone() ) } )
	Endif 
	oClone:oWSuserShiftWorkDTOCol := NIL
	If ::oWSuserShiftWorkDTOCol <> NIL 
		oClone:oWSuserShiftWorkDTOCol := {}
		aEval( ::oWSuserShiftWorkDTOCol , { |x| aadd( oClone:oWSuserShiftWorkDTOCol , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UserIntegrationServiceBeanService_userDTO
	Local cSoap := ""
	Local lTsa 	:= SUPERGETMV("MV_TSAINT",,.F., ::cfilial)

	cSoap += WSSoapValue("badgeNumber", ::cbadgeNumber, ::cbadgeNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("controlDoubleMarking", ::lcontrolDoubleMarking, ::lcontrolDoubleMarking , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("exceptionREP", ::lexceptionREP, ::lexceptionREP , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fireDate", ::cfireDate, ::cfireDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	If !lTsa
		cSoap += WSSoapValue("hiringDate", ::chiringDate, ::chiringDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	EndIf
	cSoap += WSSoapValue("flexibleInterval", ::lflexibleInterval, ::lflexibleInterval , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("freeAccess", ::lfreeAccess, ::lfreeAccess , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lastMarkDate", ::clastMarkDate, ::clastMarkDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("naturalPersonExternalKey", ::cnaturalPersonExternalKey, ::cnaturalPersonExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("pis", ::cpis, ::cpis , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSuserAllocationUnitDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userAllocationUnitDTOCol", x , x , "userAllocationUnitInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserCostCenterDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userCostCenterDTOCol", x , x , "userCostCenterInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserLocationDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userLocationDTOCol", x , x , "userLocationInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserPositionLevelDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userPositionLevelDTOCol", x , x , "userPositionLevelInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserRoleBadgeDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userRoleBadgeDTOCol", x , x , "userRoleBadgeInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSuserShiftWorkDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("userShiftWorkDTOCol", x , x , "userShiftWorkInsertDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UserIntegrationServiceBeanService_userDTO
	Local nRElem11, oNodes11, nTElem11
	Local nRElem12, oNodes12, nTElem12
	Local nRElem13, oNodes13, nTElem13
	Local nRElem14, oNodes14, nTElem14
	Local nRElem15, oNodes15, nTElem15
	Local nRElem16, oNodes16, nTElem16
	Local lTsa  := SUPERGETMV("MV_TSAINT",,.F., ::cfilial)

	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cbadgeNumber       :=  WSAdvValue( oResponse,"_BADGENUMBER","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::lcontrolDoubleMarking :=  WSAdvValue( oResponse,"_CONTROLDOUBLEMARKING","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::lexceptionREP      :=  WSAdvValue( oResponse,"_EXCEPTIONREP","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cfireDate          :=  WSAdvValue( oResponse,"_FIREDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	If !lTsa
		::chiringDate        :=  WSAdvValue( oResponse,"_HIRINGDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	EndIf
	::lflexibleInterval  :=  WSAdvValue( oResponse,"_FLEXIBLEINTERVAL","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::lfreeAccess        :=  WSAdvValue( oResponse,"_FREEACCESS","boolean",NIL,NIL,NIL,"L",NIL,"tns") 
	::clastMarkDate      :=  WSAdvValue( oResponse,"_LASTMARKDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cnaturalPersonExternalKey :=  WSAdvValue( oResponse,"_NATURALPERSONEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cpis               :=  WSAdvValue( oResponse,"_PIS","string",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes11 :=  WSAdvValue( oResponse,"_USERALLOCATIONUNITDTOCOL","userAllocationUnitInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem11 := len(oNodes11)
	For nRElem11 := 1 to nTElem11 
		If !WSIsNilNode( oNodes11[nRElem11] )
			aadd(::oWSuserAllocationUnitDTOCol , UserIntegrationServiceBeanService_userAllocationUnitInsertDTO():New() )
			::oWSuserAllocationUnitDTOCol[len(::oWSuserAllocationUnitDTOCol)]:SoapRecv(oNodes11[nRElem11])
		Endif
	Next
	oNodes12 :=  WSAdvValue( oResponse,"_USERCOSTCENTERDTOCOL","userCostCenterInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem12 := len(oNodes12)
	For nRElem12 := 1 to nTElem12 
		If !WSIsNilNode( oNodes12[nRElem12] )
			aadd(::oWSuserCostCenterDTOCol , UserIntegrationServiceBeanService_userCostCenterInsertDTO():New() )
			::oWSuserCostCenterDTOCol[len(::oWSuserCostCenterDTOCol)]:SoapRecv(oNodes12[nRElem12])
		Endif
	Next
	oNodes13 :=  WSAdvValue( oResponse,"_USERLOCATIONDTOCOL","userLocationInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem13 := len(oNodes13)
	For nRElem13 := 1 to nTElem13 
		If !WSIsNilNode( oNodes13[nRElem13] )
			aadd(::oWSuserLocationDTOCol , UserIntegrationServiceBeanService_userLocationInsertDTO():New() )
			::oWSuserLocationDTOCol[len(::oWSuserLocationDTOCol)]:SoapRecv(oNodes13[nRElem13])
		Endif
	Next
	oNodes14 :=  WSAdvValue( oResponse,"_USERPOSITIONLEVELDTOCOL","userPositionLevelInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem14 := len(oNodes14)
	For nRElem14 := 1 to nTElem14 
		If !WSIsNilNode( oNodes14[nRElem14] )
			aadd(::oWSuserPositionLevelDTOCol , UserIntegrationServiceBeanService_userPositionLevelInsertDTO():New() )
			::oWSuserPositionLevelDTOCol[len(::oWSuserPositionLevelDTOCol)]:SoapRecv(oNodes14[nRElem14])
		Endif
	Next
	oNodes15 :=  WSAdvValue( oResponse,"_USERROLEBADGEDTOCOL","userRoleBadgeInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem15 := len(oNodes15)
	For nRElem15 := 1 to nTElem15 
		If !WSIsNilNode( oNodes15[nRElem15] )
			aadd(::oWSuserRoleBadgeDTOCol , UserIntegrationServiceBeanService_userRoleBadgeInsertDTO():New() )
			::oWSuserRoleBadgeDTOCol[len(::oWSuserRoleBadgeDTOCol)]:SoapRecv(oNodes15[nRElem15])
		Endif
	Next
	oNodes16 :=  WSAdvValue( oResponse,"_USERSHIFTWORKDTOCOL","userShiftWorkInsertDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem16 := len(oNodes16)
	For nRElem16 := 1 to nTElem16 
		If !WSIsNilNode( oNodes16[nRElem16] )
			aadd(::oWSuserShiftWorkDTOCol , UserIntegrationServiceBeanService_userShiftWorkInsertDTO():New() )
			::oWSuserShiftWorkDTOCol[len(::oWSuserShiftWorkDTOCol)]:SoapRecv(oNodes16[nRElem16])
		Endif
	Next
Return


