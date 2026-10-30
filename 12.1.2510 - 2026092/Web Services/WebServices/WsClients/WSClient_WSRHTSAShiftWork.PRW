#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb/ShiftWorkIntegrationServiceBean?wsdl
Gerado em        12/19/18 10:57:58
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NEZOOKF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSShiftWorkIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSShiftWorkIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateDescriptionShiftWork
	WSMETHOD remove
	WSMETHOD insertOrUpdate
	WSMETHOD removeAll

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   carg1                     AS string
	WSDATA   cMsg0                     AS string
	WSDATA   cMsg1                     AS string
	WSDATA   oWSarg0		           AS ShiftWorkIntegrationServiceBeanService_statusDTO
	WSDATA   oWSstatusDTO              AS ShiftWorkIntegrationServiceBeanService_statusDTO
	WSDATA   oWSshiftWorkDTO           AS ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	WSDATA   oWSshiftWorkRMV           AS ShiftWorkIntegrationServiceBeanService_shiftWorkRMV

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSShiftWorkIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSShiftWorkIntegrationServiceBeanService
	::oWSstatusDTO       := ShiftWorkIntegrationServiceBeanService_STATUSDTO():New()
	::oWSarg0		     := {} // Array Of  ShiftWorkIntegrationServiceBeanService_STATUSDTO():New()
	::oWSshiftWorkDTO    := {} // Array Of  ShiftWorkIntegrationServiceBeanService_SHIFTWORKDTO():New()
	::oWSshiftWorkRMV    := {} // Array Of  ShiftWorkIntegrationServiceBeanService_SHIFTWORKRMV():New()
Return

WSMETHOD RESET WSCLIENT WSShiftWorkIntegrationServiceBeanService
	::carg0              := NIL 
	::carg1              := NIL 
	::oWSarg0		     := NIL 
	::oWSstatusDTO       := NIL 
	::oWSshiftWorkDTO    := NIL 
	::oWSshiftWorkRMV    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSShiftWorkIntegrationServiceBeanService
Local oClone := WSShiftWorkIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:carg0         := ::carg0
	oClone:carg1         := ::carg1
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
	oClone:oWSshiftWorkDTO :=  IIF(::oWSshiftWorkDTO = NIL , NIL ,::oWSshiftWorkDTO:Clone() )
	oClone:oWSshiftWorkRMV :=  IIF(::oWSshiftWorkRMV = NIL , NIL ,::oWSshiftWorkRMV:Clone() )
Return oClone

// WSDL Method updateDescriptionShiftWork of Service WSShiftWorkIntegrationServiceBeanService

WSMETHOD updateDescriptionShiftWork WSSEND carg0,carg1 WSRECEIVE oWSstatusDTO WSCLIENT WSShiftWorkIntegrationServiceBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<updateDescriptionShiftWork xmlns="http://shiftwork.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += WSSoapValue("arg1", ::carg1, carg1 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</updateDescriptionShiftWork>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://shiftwork.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/ShiftWorkIntegrationServiceBean")

::Init()
::oWSstatusDTO:SoapRecv( WSAdvValue( oXmlRet,"_UPDATEDESCRIPTIONSHIFTWORKRESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSShiftWorkIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSShiftWorkIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<remove xmlns="http://shiftwork.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://shiftwork.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/ShiftWorkIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,ShiftWorkIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSShiftWorkIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSshiftWorkDTO WSCLIENT WSShiftWorkIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<insertOrUpdate xmlns="http://shiftwork.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "shiftWorkDTO", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://shiftwork.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/ShiftWorkIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","shiftWorkDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSshiftWorkDTO,ShiftWorkIntegrationServiceBeanService_shiftWorkDTO():New()) , ::oWSshiftWorkDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeAll of Service WSShiftWorkIntegrationServiceBeanService

WSMETHOD removeAll WSSEND oWSarg0 WSRECEIVE oWSshiftWorkRMV WSCLIENT WSShiftWorkIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01

BEGIN WSMETHOD

cSoap += '<removeAll xmlns="http://shiftwork.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "shiftWorkRMV", .F. , .F., 0 , NIL, .T.,.F.) 
cSoap += "</removeAll>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://shiftwork.tsa.totvs.com/",,,; 
	"http://SPON010114022:8080/tsa-ejb/ShiftWorkIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVEALLRESPONSE:_RETURN","shiftWorkRMV",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSshiftWorkRMV,ShiftWorkIntegrationServiceBeanService_shiftWorkRMV():New()) , ::oWSshiftWorkRMV[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Data Structure statusDTO

WSSTRUCT ShiftWorkIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA cstatuscode AS string OPTIONAL
	WSDATA cstatusdescription AS string OPTIONAL  
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ShiftWorkIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ShiftWorkIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT ShiftWorkIntegrationServiceBeanService_statusDTO
	Local oClone := ShiftWorkIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ShiftWorkIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure shiftWorkDTO

WSSTRUCT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   cinitialDate              AS dateTime OPTIONAL
	WSDATA   oWSscaleDTOCol            AS ShiftWorkIntegrationServiceBeanService_scaleDTO OPTIONAL
	WSDATA   nsequence                 AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	::oWSscaleDTOCol       := {} // Array Of  ShiftWorkIntegrationServiceBeanService_SCALEDTO():New()
Return

WSMETHOD CLONE WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	Local oClone := ShiftWorkIntegrationServiceBeanService_shiftWorkDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cdescription         := ::cdescription
	oClone:cexternalKey         := ::cexternalKey
	oClone:cinitialDate         := ::cinitialDate
	oClone:oWSscaleDTOCol := NIL
	If ::oWSscaleDTOCol <> NIL 
		oClone:oWSscaleDTOCol := {}
		aEval( ::oWSscaleDTOCol , { |x| aadd( oClone:oWSscaleDTOCol , x:Clone() ) } )
	Endif 
	oClone:nsequence            := ::nsequence
Return oClone

WSMETHOD SOAPSEND WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialDate", ::cinitialDate, ::cinitialDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSscaleDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("scaleDTOCol", x , x , "scaleDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("sequence", ::nsequence, ::nsequence , "int", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkDTO
	Local nRElem4, oNodes4, nTElem4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialDate       :=  WSAdvValue( oResponse,"_INITIALDATE","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	oNodes4 :=  WSAdvValue( oResponse,"_SCALEDTOCOL","scaleDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem4 := len(oNodes4)
	For nRElem4 := 1 to nTElem4 
		If !WSIsNilNode( oNodes4[nRElem4] )
			aadd(::oWSscaleDTOCol , ShiftWorkIntegrationServiceBeanService_scaleDTO():New() )
			::oWSscaleDTOCol[len(::oWSscaleDTOCol)]:SoapRecv(oNodes4[nRElem4])
		Endif
	Next
	::nsequence          :=  WSAdvValue( oResponse,"_SEQUENCE","int",NIL,NIL,NIL,"N",NIL,"tns") 
Return

// WSDL Data Structure scaleDTO

WSSTRUCT ShiftWorkIntegrationServiceBeanService_scaleDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   ndayType                  AS int OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   nendSequence              AS int OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   ninitialSequence          AS int OPTIONAL
	WSDATA   oWSscalePairDTOCol        AS ShiftWorkIntegrationServiceBeanService_scalePairDTO OPTIONAL
	WSDATA   cshiftWorkExternalKey     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ShiftWorkIntegrationServiceBeanService_scaleDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ShiftWorkIntegrationServiceBeanService_scaleDTO
	::oWSscalePairDTOCol   := {} // Array Of  ShiftWorkIntegrationServiceBeanService_SCALEPAIRDTO():New()
Return

WSMETHOD CLONE WSCLIENT ShiftWorkIntegrationServiceBeanService_scaleDTO
	Local oClone := ShiftWorkIntegrationServiceBeanService_scaleDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:ndayType             := ::ndayType
	oClone:cdescription         := ::cdescription
	oClone:nendSequence         := ::nendSequence
	oClone:cexternalKey         := ::cexternalKey
	oClone:ninitialSequence     := ::ninitialSequence
	oClone:oWSscalePairDTOCol := NIL
	If ::oWSscalePairDTOCol <> NIL 
		oClone:oWSscalePairDTOCol := {}
		aEval( ::oWSscalePairDTOCol , { |x| aadd( oClone:oWSscalePairDTOCol , x:Clone() ) } )
	Endif 
	oClone:cshiftWorkExternalKey := ::cshiftWorkExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT ShiftWorkIntegrationServiceBeanService_scaleDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("dayType", ::ndayType, ::ndayType , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("endSequence", ::nendSequence, ::nendSequence , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialSequence", ::ninitialSequence, ::ninitialSequence , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSscalePairDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("scalePairDTOCol", x , x , "scalePairDTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("shiftWorkExternalKey", ::cshiftWorkExternalKey, ::cshiftWorkExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ShiftWorkIntegrationServiceBeanService_scaleDTO
	Local nRElem6, oNodes6, nTElem6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ndayType           :=  WSAdvValue( oResponse,"_DAYTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::nendSequence       :=  WSAdvValue( oResponse,"_ENDSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::ninitialSequence   :=  WSAdvValue( oResponse,"_INITIALSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	oNodes6 :=  WSAdvValue( oResponse,"_SCALEPAIRDTOCOL","scalePairDTO",{},NIL,.T.,"O",NIL,"tns") 
	nTElem6 := len(oNodes6)
	For nRElem6 := 1 to nTElem6 
		If !WSIsNilNode( oNodes6[nRElem6] )
			aadd(::oWSscalePairDTOCol , ShiftWorkIntegrationServiceBeanService_scalePairDTO():New() )
			::oWSscalePairDTOCol[len(::oWSscalePairDTOCol)]:SoapRecv(oNodes6[nRElem6])
		Endif
	Next
	::cshiftWorkExternalKey :=  WSAdvValue( oResponse,"_SHIFTWORKEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure scalePairDTO

WSSTRUCT ShiftWorkIntegrationServiceBeanService_scalePairDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   cendTime                  AS dateTime OPTIONAL
	WSDATA   cinitialTime              AS dateTime OPTIONAL
	WSDATA   npairType                 AS int OPTIONAL
	WSDATA   cscaleExternalKey         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ShiftWorkIntegrationServiceBeanService_scalePairDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ShiftWorkIntegrationServiceBeanService_scalePairDTO
Return

WSMETHOD CLONE WSCLIENT ShiftWorkIntegrationServiceBeanService_scalePairDTO
	Local oClone := ShiftWorkIntegrationServiceBeanService_scalePairDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cendTime             := ::cendTime
	oClone:cinitialTime         := ::cinitialTime
	oClone:npairType            := ::npairType
	oClone:cscaleExternalKey    := ::cscaleExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT ShiftWorkIntegrationServiceBeanService_scalePairDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("endTime", ::cendTime, ::cendTime , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("initialTime", ::cinitialTime, ::cinitialTime , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("pairType", ::npairType, ::npairType , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("scaleExternalKey", ::cscaleExternalKey, ::cscaleExternalKey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ShiftWorkIntegrationServiceBeanService_scalePairDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendTime           :=  WSAdvValue( oResponse,"_ENDTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialTime       :=  WSAdvValue( oResponse,"_INITIALTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::npairType          :=  WSAdvValue( oResponse,"_PAIRTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cscaleExternalKey  :=  WSAdvValue( oResponse,"_SCALEEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure shiftWorkRMV

WSSTRUCT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	WSDATA   lRemoveAll                AS boolean OPTIONAL
	WSDATA   cIntDate                  AS string  OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	::lRemoveAll       := .F.
	::cIntDate         := ""
Return

WSMETHOD CLONE WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	Local oClone := ShiftWorkIntegrationServiceBeanService_shiftWorkRMV():NEW()
	oClone:lRemoveAll          := ::lRemoveAll
	oClone:cIntDate            := ::cIntDate
Return oClone

WSMETHOD SOAPSEND WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	Local cSoap := ""
	cSoap += WSSoapValue("removeall", ::lRemoveAll, ::lRemoveAll , "boolean", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("intDate", ::cIntDate, ::cIntDate , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ShiftWorkIntegrationServiceBeanService_shiftWorkRMV
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lRemoveAll         :=  WSAdvValue( oResponse,"_REMOVEALL","boolean",NIL,NIL,NIL,"S",NIL,"tns") 
	::cIntDate           :=  WSAdvValue( oResponse,"_INTDATE","string",NIL,NIL,NIL,"S",NIL,"tns")
Return
