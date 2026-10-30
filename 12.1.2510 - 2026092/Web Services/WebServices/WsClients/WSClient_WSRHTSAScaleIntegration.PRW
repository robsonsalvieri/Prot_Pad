#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/tsa-ejb-11.5.0/ScaleIntegrationServiceBean?wsdl
Gerado em        06/13/11 19:09:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110315
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SKSMSEQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSScaleIntegrationServiceBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSScaleIntegrationServiceBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD updateScale
	WSMETHOD insertScale
	WSMETHOD insertOrUpdate
	WSMETHOD remove

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   carg0                     AS string
	WSDATA   oWSarg0                   AS ScaleIntegrationServiceBeanService_scaleDTO
	WSDATA   oWSscaleDTO               AS ScaleIntegrationServiceBeanService_scaleDTO
	WSDATA   oWSstatusDTO              AS ScaleIntegrationServiceBeanService_statusDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSScaleIntegrationServiceBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSScaleIntegrationServiceBeanService
	::oWSarg0            := ScaleIntegrationServiceBeanService_SCALEDTO():New()
	::oWSscaleDTO        := ScaleIntegrationServiceBeanService_SCALEDTO():New()
	::oWSstatusDTO       := {} // Array Of  ScaleIntegrationServiceBeanService_STATUSDTO():New()
Return

WSMETHOD RESET WSCLIENT WSScaleIntegrationServiceBeanService
	::oWSarg0            := NIL 
	::oWSscaleDTO        := NIL 
	::oWSstatusDTO       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSScaleIntegrationServiceBeanService
Local oClone := WSScaleIntegrationServiceBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSscaleDTO   :=  IIF(::oWSscaleDTO = NIL , NIL ,::oWSscaleDTO:Clone() )
	oClone:oWSstatusDTO  :=  IIF(::oWSstatusDTO = NIL , NIL ,::oWSstatusDTO:Clone() )
Return oClone

// WSDL Method updateScale of Service WSScaleIntegrationServiceBeanService

WSMETHOD updateScale WSSEND oWSarg0 WSRECEIVE oWSscaleDTO WSCLIENT WSScaleIntegrationServiceBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<updateScale xmlns="http://scale.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "scaleDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</updateScale>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://shiftwork.tsa.totvs.com/",; 
	"DOCUMENT","http://scale.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ScaleIntegrationServiceBean")

::oWSscaleDTO:SoapRecv( WSAdvValue( oXmlRet,"_UPDATESCALERESPONSE:_RETURN","scaleDTO",NIL,NIL,NIL,NIL,NIL,"tns") )


END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertScale of Service WSScaleIntegrationServiceBeanService

WSMETHOD insertScale WSSEND oWSarg0 WSRECEIVE oWSscaleDTO WSCLIENT WSScaleIntegrationServiceBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertScale xmlns="http://scale.tsa.totvs.com/">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "scaleDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertScale>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://scale.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ScaleIntegrationServiceBean")

::oWSscaleDTO:SoapRecv( WSAdvValue( oXmlRet,"_INSERTSCALERESPONSE:_RETURN","scaleDTO",NIL,NIL,NIL,NIL,NIL,"tns") )


END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertOrUpdate of Service WSScaleIntegrationServiceBeanService

WSMETHOD insertOrUpdate WSSEND oWSarg0 WSRECEIVE oWSscaleDTO WSCLIENT WSScaleIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<insertOrUpdate>'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "scaleDTO", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertOrUpdate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://scale.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ScaleIntegrationServiceBean")

oATmp01 :=           WSAdvValue( oXmlRet,"_INSERTORUPDATERESPONSE:_RETURN","scaleDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSscaleDTO,ScaleIntegrationServiceBeanService_scaleDTO():New()) , ::oWSscaleDTO[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method remove of Service WSScaleIntegrationServiceBeanService

WSMETHOD remove WSSEND carg0 WSRECEIVE oWSstatusDTO WSCLIENT WSScaleIntegrationServiceBeanService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<remove>'
cSoap += WSSoapValue("arg0", ::carg0, carg0 , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</remove>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://scale.tsa.totvs.com/",,,; 
	"http://localhost:8080/tsa-ejb-11.5.0/ScaleIntegrationServiceBean")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_REMOVERESPONSE:_RETURN","statusDTO",NIL,NIL,NIL,NIL,NIL,"tns") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSstatusDTO,ScaleIntegrationServiceBeanService_statusDTO():New()) , ::oWSstatusDTO[y]:SoapRecv(x) ) })
Endif
END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure scaleDTO

WSSTRUCT ScaleIntegrationServiceBeanService_scaleDTO
	WSDATA   cstatuscode               AS string OPTIONAL
	WSDATA   cstatusdescription        AS string OPTIONAL
	WSDATA   ndayType                  AS int OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   nendSequence              AS int OPTIONAL
	WSDATA   cexternalKey              AS string OPTIONAL
	WSDATA   ninitialSequence          AS int OPTIONAL
	WSDATA   oWSscalePairDTOCol        AS ScaleIntegrationServiceBeanService_scalePairDTO OPTIONAL
	WSDATA   cshiftWorkExternalKey     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ScaleIntegrationServiceBeanService_scaleDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ScaleIntegrationServiceBeanService_scaleDTO
	::oWSscalePairDTOCol   := {} // Array Of  ScaleIntegrationServiceBeanService_SCALEPAIRDTO():New()
Return

WSMETHOD CLONE WSCLIENT ScaleIntegrationServiceBeanService_scaleDTO
	Local oClone := ScaleIntegrationServiceBeanService_scaleDTO():NEW()
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

WSMETHOD SOAPSEND WSCLIENT ScaleIntegrationServiceBeanService_scaleDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("dayType", ::ndayType, ::ndayType , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("endSequence", ::nendSequence, ::nendSequence , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("externalKey", ::cexternalKey, ::cexternalKey , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("initialSequence", ::ninitialSequence, ::ninitialSequence , "int", .F. , .F., 0 , NIL, .T.) 
	aEval( ::oWSscalePairDTOCol , {|x| cSoap := cSoap  +  WSSoapValue("scalePairDTOCol", x , x , "scalePairDTO", .F. , .F., 0 , NIL, .T.)  } ) 
	cSoap += WSSoapValue("shiftWorkExternalKey", ::cshiftWorkExternalKey, ::cshiftWorkExternalKey , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ScaleIntegrationServiceBeanService_scaleDTO
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
			aadd(::oWSscalePairDTOCol , ScaleIntegrationServiceBeanService_scalePairDTO():New() )
			::oWSscalePairDTOCol[len(::oWSscalePairDTOCol)]:SoapRecv(oNodes6[nRElem6])
		Endif
	Next
	::cshiftWorkExternalKey :=  WSAdvValue( oResponse,"_SHIFTWORKEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure statusDTO

WSSTRUCT ScaleIntegrationServiceBeanService_statusDTO
	WSDATA   cexternalKey              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ScaleIntegrationServiceBeanService_statusDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ScaleIntegrationServiceBeanService_statusDTO
Return

WSMETHOD CLONE WSCLIENT ScaleIntegrationServiceBeanService_statusDTO
	Local oClone := ScaleIntegrationServiceBeanService_statusDTO():NEW()
	oClone:cexternalKey         := ::cexternalKey
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ScaleIntegrationServiceBeanService_statusDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cexternalKey       :=  WSAdvValue( oResponse,"_EXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return

// WSDL Data Structure scalePairDTO

WSSTRUCT ScaleIntegrationServiceBeanService_scalePairDTO
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

WSMETHOD NEW WSCLIENT ScaleIntegrationServiceBeanService_scalePairDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ScaleIntegrationServiceBeanService_scalePairDTO
Return

WSMETHOD CLONE WSCLIENT ScaleIntegrationServiceBeanService_scalePairDTO
	Local oClone := ScaleIntegrationServiceBeanService_scalePairDTO():NEW()
	oClone:cstatuscode          := ::cstatuscode
	oClone:cstatusdescription   := ::cstatusdescription
	oClone:cendTime             := ::cendTime
	oClone:cinitialTime         := ::cinitialTime
	oClone:npairType            := ::npairType
	oClone:cscaleExternalKey    := ::cscaleExternalKey
Return oClone

WSMETHOD SOAPSEND WSCLIENT ScaleIntegrationServiceBeanService_scalePairDTO
	Local cSoap := ""
	cSoap += WSSoapValue("statuscode", ::cstatuscode, ::cstatuscode , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("statusdescription", ::cstatusdescription, ::cstatusdescription , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("endTime", ::cendTime, ::cendTime , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("initialTime", ::cinitialTime, ::cinitialTime , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("pairType", ::npairType, ::npairType , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("scaleExternalKey", ::cscaleExternalKey, ::cscaleExternalKey , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ScaleIntegrationServiceBeanService_scalePairDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatuscode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cstatusdescription :=  WSAdvValue( oResponse,"_STATUSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cendTime           :=  WSAdvValue( oResponse,"_ENDTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::cinitialTime       :=  WSAdvValue( oResponse,"_INITIALTIME","dateTime",NIL,NIL,NIL,"S",NIL,"tns") 
	::npairType          :=  WSAdvValue( oResponse,"_PAIRTYPE","int",NIL,NIL,NIL,"N",NIL,"tns") 
	::cscaleExternalKey  :=  WSAdvValue( oResponse,"_SCALEEXTERNALKEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


