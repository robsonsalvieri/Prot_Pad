#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
 
#DEFINE VARIAVEIS_TAM  16
#DEFINE VAR_CODCOMP    1
#DEFINE VAR_CODCPL     2
#DEFINE VAR_VALORMIN   3 
#DEFINE VAR_VALORFIX   4
#DEFINE VAR_FRETEVALOR 5
#DEFINE VAR_SUBTOTFRET 6
#DEFINE VAR_FRETEPESOB 7
#DEFINE VAR_FRETEPESOL 8
#DEFINE VAR_FRACAO     9
#DEFINE VAR_UNIMED     11
#DEFINE VAR_QTDEITENS  12
#DEFINE VAR_QTDEVOLUM  13
#DEFINE VAR_QTDEENTRG  14
#DEFINE VAR_VOLUME     15
#DEFINE VAR_DISTANCIA  16

#DEFINE PERCIMPOS_TAM  7
#DEFINE PER_TIPORIGEM  1
#DEFINE PER_CONTORIG   2
#DEFINE PER_TIPODESTI  3
#DEFINE PER_CONTDEST   4
#DEFINE PER_ADDISS     5
#DEFINE PER_ADDICMS    6
#DEFINE PER_TRANSPOR   7

#DEFINE DS_LOCALPADRAO "|Padrão"

User Function _QFRRMJK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFreightRuleAcquisitionService
------------------------------------------------------------------------------- */

WSCLIENT WSFreightRuleAcquisitionService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Envia
	WSMETHOD AddGrupo
	WSMETHOD NovoGrupoFrete
	WSMETHOD NovoItem
	WSMETHOD VerificaLimite
	WSMETHOD ConverteData

	WSDATA   _URL                      	AS String
	WSDATA   _HEADOUT                  	AS Array of String
	WSDATA   _COOKIES                  	AS Array of String
	WSDATA   oWSfreightRuleGroups      	AS FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	WSDATA   oWSresult                 	AS FreightRuleAcquisitionService_resultList
	WSDATA	 oXMLRESULT				 	AS OBJECT
	WSDATA	 cEnderecoWs				AS String
	WSDATA	 cXmlEnviado				AS String
	WSDATA   lLimiteVerificado			AS BOOLEAN
	WSDATA	 lLiberado					AS BOOLEAN
	WSDATA   nQtdItens					AS INTEGER
	WSDATA   cMsgRet					AS STRING 
	
ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFreightRuleAcquisitionService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150107] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFreightRuleAcquisitionService
	::oWSfreightRuleGroups := FreightRuleAcquisitionService_ARRAYOFFREIGHTRULEGROUP():New()
	::oWSresult          := FreightRuleAcquisitionService_RESULTLIST():New()
	::cXmlEnviado := ""
	::lLimiteVerificado := .F.
	::lLiberado := .T.
	::nQtdItens := 0
Return

WSMETHOD RESET WSCLIENT WSFreightRuleAcquisitionService
	::oWSfreightRuleGroups := NIL 
	::oWSresult          := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFreightRuleAcquisitionService
Local oClone := WSFreightRuleAcquisitionService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSfreightRuleGroups :=  IIF(::oWSfreightRuleGroups = NIL , NIL ,::oWSfreightRuleGroups:Clone() )
	oClone:oWSresult     :=  IIF(::oWSresult = NIL , NIL ,::oWSresult:Clone() )
Return oClone

WSMETHOD AddGrupo WSSEND oGrupo WSCLIENT WSFreightRuleAcquisitionService
	aAdd(::oWSfreightRuleGroups:oWSfreightRuleGroup,oGrupo)
Return

WSMETHOD NovoGrupoFrete WSCLIENT WSFreightRuleAcquisitionService
	
	Local oObj := FreightRuleAcquisitionService_freightRuleGroup():New()
	oObj:cregionSourceId := SuperGetMv("MV_CPLREG",.T.,"")
	
Return oObj

WSMETHOD NovoItem WSSEND cAliasTab WSCLIENT WSFreightRuleAcquisitionService
	//Padrões novo item
	Local oObj := FreightRuleAcquisitionService_freightRule():NEW()
	oObj:cshipperSourceId := SuperGetMv("MV_CPLEMB",.T.,"")
	oObj:cAliasTab := cAliasTab
	::nQtdItens++
Return oObj

WSMETHOD VerificaLimite WSCLIENT WSFreightRuleAcquisitionService

	::lLiberado := .T.
	::lLimiteVerificado := .T.

Return (::lLimiteVerificado == .T. .And. ::lLiberado == .T.)

WSMETHOD ConverteData WSSEND xData,cTempo WSCLIENT WSFreightRuleAcquisitionService
	Local cData := ""
	
	If !Empty(xData)
		
		If Empty(cTempo)
			cTempo := "00:00:00"
		EndIf
	
		If VALTYPE(xData) == "D"
			xData := DTOS(xData)
		EndIf
	
		cData := SubStr(xData,1,4) + '-' + SubStr(xData,5,2) + '-' + SubStr(xData,7,2) + "T" + cTempo
		
	EndIf
Return cData


// WSDL Method Envia of Service WSFreightRuleAcquisitionService

WSMETHOD Envia WSSEND oWSfreightRuleGroups WSRECEIVE oWSresult WSCLIENT WSFreightRuleAcquisitionService
Local cSoap := "" 
Local oXmlRet
Local cSoapPE
Local cServico := "FreightRuleAcquisitionService"
Local cTabela  := "GV9"
Local aErros
//Local nX
Local nY
Local aItems
Local cToken
Local cSoapSend
Local XMLHeadRet
Local aHeadOut
Local XMLPostRet := ""
Private XMLREC
	

BEGIN WSMETHOD

If ::VerificaLimite()

	cSoap += '<fre:replaceFreightRules xmlns:fre="http://www.neolog.com.br/cpl/acquisition/freightRule/">'
	cSoap += WSSoapValue("fre:freightRuleGroups", ::oWSfreightRuleGroups, oWSfreightRuleGroups , "ArrayOfFreightRuleGroup", .T. , .F., 0 , NIL, .F.) 
	cSoap += "</fre:replaceFreightRules>"
	
	::cMsgRet := ""
	::_URL := ::cEnderecoWs
	
	If ExistBlock("GFEXWSCPL1")
		cSoapPE := ExecBlock('GFEXWSCPL1',.F.,.F.,{cSoap})
	EndIf
	
	If !Empty(cSoapPE)
		cSoap := cSoapPE
	EndIf

	cToken := GFGETTOKEN()
	If Empty(cToken) //Quando não há token
		cSoapSend := cSoap
		GFEXGRVXML(cServico,cSoap,cTabela,(cTabela)->(&((cTabela)->(IndexKey()))))
		oXmlRet := SvcSoapCall(	Self,cSoap,"",	"DOCUMENT","http://www.neolog.com.br/cpl/acquisition/freightRule/",,,::_URL)
		XMLPostRet := XMLSaveStr(oXmlRet)
		GFEXGRVXML(cServico,XMLPostRet,cTabela,(cTabela)->(&((cTabela)->(IndexKey())))+"_resp")
	Else
		cSoapSend := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
		cSoapSend += '<soapenv:Header/>'
		cSoapSend += '<soapenv:Body>'
		cSoapSend += cSoap
		cSoapSend += '</soapenv:Body>'
		cSoapSend += '</soapenv:Envelope>'
		XMLHeadRet:= ""
		aHeadOut  := {'user.token: ' + cToken ,'Content-Type: text/xml;charset=utf-8','SOAPAction: ""','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
		GFEXGRVXML(cServico,cSoapSend,cTabela,(cTabela)->(&((cTabela)->(IndexKey()))))
		If Empty(XMLPostRet := HTTPSPost(::_URL, "", "", "", "", cSoapSend, 999999, aHeadOut, @XMLHeadRet))
			::cMsgRet +=  GfeFmtMsg("CPLERR01 - Não foi possível se comunicar com o endereço de webservice [VAR01].",{{"[VAR01]",::_URL}})
		Else
			GFEXGRVXML(cServico,XMLPostRet,cTabela,(cTabela)->(&((cTabela)->(IndexKey())))+"_resp")
			If Empty(oXmlRet := XmlParser ( XMLPostRet, "NS1", "", "") )
				::cMsgRet +=  GfeFmtMsg("CPLERR01 - Não foi possível se comunicar com o endereço de webservice [VAR01].",{{"[VAR01]",::_URL}})
			Else
				XMLREC := classdataarr(oXmlRet)[1][2]
				oXmlRet := TMSXGetItens("Body","O")
			EndIf
		EndIf
	EndIf
	If !Empty(XMLPostRet) .And. !Empty(oXmlRet)
		XMLREC := classdataarr(oXmlRet)[1][2]
		aItems := TMSXGetAll("RESULT:RESULTS:RESULT")
		For nY := 1 To Len(aItems)
			If aItems[nY]:_SUCESS:TEXT == "false"
				//::cMsgRet +=  CRLF + " Identificador :" +  aItems[nY]:_IDENTIFIER:TEXT + CRLF + " Código(s) de erro(s):" + CRLF  
				XMLREC := aItems[nY]
				aErros := TMSXGetAll("ERRORCODES:ERRORCODE:VALUE")
				/*For nX := 1 To Len(aErros)
					::cMsgRet += aErros[nX]:TEXT + CRLF
				Next nX*/
			EndIf
		Next nY
	EndIf
	
	::Init()
	::oXMLRESULT  := oXmlRet
	::cXmlEnviado := cSoapSend
	::oWSresult:SoapRecv( WSAdvValue( oXmlRet,"_REPLACEFREIGHTRULESRESPONSE:_RESULT","resultList",NIL,NIL,NIL,NIL,NIL,"xsd") )
	
EndIf

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfFreightRuleGroup

WSSTRUCT FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	WSDATA   oWSfreightRuleGroup       AS FreightRuleAcquisitionService_freightRuleGroup OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	::oWSfreightRuleGroup  := {} // Array Of  FreightRuleAcquisitionService_FREIGHTRULEGROUP():New()
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	Local oClone := FreightRuleAcquisitionService_ArrayOfFreightRuleGroup():NEW()
	oClone:oWSfreightRuleGroup := NIL
	If ::oWSfreightRuleGroup <> NIL 
		oClone:oWSfreightRuleGroup := {}
		aEval( ::oWSfreightRuleGroup , { |x| aadd( oClone:oWSfreightRuleGroup , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRuleGroup
	Local cSoap := ""
	Private nX := 1
	aEval( ::oWSfreightRuleGroup , {|x| cSoap := cSoap  +  WSSoapValue("fre:freightRuleGroup", x , x , "freightRuleGroup", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure resultList

WSSTRUCT FreightRuleAcquisitionService_resultList
	WSDATA   oWSresults                AS FreightRuleAcquisitionService_ArrayOfResult OPTIONAL
	WSDATA   lsuccess                  AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_resultList
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_resultList
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_resultList
	Local oClone := FreightRuleAcquisitionService_resultList():NEW()
	oClone:oWSresults           := IIF(::oWSresults = NIL , NIL , ::oWSresults:Clone() )
	oClone:lsuccess             := ::lsuccess
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FreightRuleAcquisitionService_resultList
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_RESULTS","ArrayOfResult",NIL,NIL,NIL,"O",NIL,"xsd") 
	If oNode1 != NIL
		::oWSresults := FreightRuleAcquisitionService_ArrayOfResult():New()
		::oWSresults:SoapRecv(oNode1)
	EndIf
	::lsuccess           :=  WSAdvValue( oResponse,"_SUCCESS","boolean",NIL,NIL,NIL,"L",NIL,"xsd") 
Return

// WSDL Data Structure freightRuleGroup

WSSTRUCT FreightRuleAcquisitionService_freightRuleGroup
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   oWSfreightRules           AS FreightRuleAcquisitionService_ArrayOfFreightRule OPTIONAL
	WSDATA   cname                     AS string OPTIONAL
	WSDATA   cregionSourceId           AS string OPTIONAL
	WSDATA   cfreightRuleGroupName     AS string OPTIONAL
	WSDATA   cvalidityFinalDate        AS dateTime OPTIONAL
	WSDATA   cvigencyInitialDate       AS dateTime OPTIONAL
	WSDATA   cNrNegociacao			   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD ADDITEM
	WSMETHOD CodigoGrupo
	WSMETHOD Transportador
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	::oWSfreightRules := FreightRuleAcquisitionService_ArrayOfFreightRule():NEW()
	::cNrNegociacao := ""
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	Local oClone := FreightRuleAcquisitionService_freightRuleGroup():NEW()
	oClone:cdescription         := ::cdescription
	oClone:oWSfreightRules      := IIF(::oWSfreightRules = NIL , NIL , ::oWSfreightRules:Clone() )
	oClone:cname                := ::cname
	oClone:cregionSourceId      := ::cregionSourceId
	oClone:cfreightRuleGroupName := ::cfreightRuleGroupName
	oClone:cvalidityFinalDate   := ::cvalidityFinalDate
	oClone:cvigencyInitialDate  := ::cvigencyInitialDate
Return oClone

WSMETHOD SOAPSEND WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	Local cSoap := ""
	nX := 1
	cSoap += WSSoapValue("fre:description", ::cdescription, ::cdescription , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fre:freightRules", ::oWSfreightRules, ::oWSfreightRules , "ArrayOfFreightRule", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fre:regionSourceId", ::cregionSourceId, ::cregionSourceId , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("fre:freightRuleGroupName", ::cfreightRuleGroupName, ::cfreightRuleGroupName , "string", .F. , .F., 0 , NIL, .F.)
	If !Empty(::cvalidityFinalDate) 
		cSoap += WSSoapValue("fre:validityFinalDate", ::cvalidityFinalDate, ::cvalidityFinalDate , "dateTime", .F. , .F., 0 , NIL, .F.)
	EndIf 
	cSoap += WSSoapValue("fre:vigencyInitialDate", ::cvigencyInitialDate, ::cvigencyInitialDate , "dateTime", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD ADDITEM WSSEND oItem,cTipoLotacao WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	Local cCodFil  := ""
	Local cVeiculo := AllTrim(SuperGetMv("MV_CPLTVF",.F.,""))
	If cTipoLotacao == "1" 
	    If !Empty(cVeiculo)
			cCodFil := IIf(SuperGetMv("MV_ERPGFE",.F.,"1") == "2",GFEXGETFIL("DUT"),"")
		Else 
		    cCodFil := ""
		ENDIF
		oItem:cvehicleSourceId := cVeiculo + AllTrim(cCodFil)			
	EndIf
	aAdd(::oWSfreightRules:oWSfreightRule,oItem)		
Return .T.

WSMETHOD CodigoGrupo WSSEND cEmitente,cNumero,cNrNegoc WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	Local cCodigo := ""
	cCodigo := AllTrim(cEmitente) + "|" + AllTrim(cNumero) + "|" + AllTrim(cNrNegoc)
Return cCodigo

WSMETHOD Transportador WSSEND cCdEmit WSCLIENT FreightRuleAcquisitionService_freightRuleGroup
	Local cCodFil := GFEXGETFIL("SA4")
	Local cTrp    := RTrim(Posicione("GU3",1,xFilial("GU3") + cCdEmit,"GU3_CDTERP")) 

	IF SuperGetMv("MV_ERPGFE",.F.,"1") == "2" //Protheus
	
		If Empty(cTrp)
			cIDFed  := RTrim(Posicione("GU3",1,xFilial("GU3") + cCdEmit,"GU3_IDFED"))
					
			dbSelectarea("SA4")
			SA4->(DbSetOrder(3)) // Filial + cgc
			SA4->(dbSeek(xFilial("SA4") + cIDFed))
			If !SA4->(Eof())
				cTrp := SA4->A4_COD
			EndIf
		EndIF
		
		If !Empty(cTrp)
			cTrp += RTrim(cCodFil)
		EndIf
	EndIf
	
	If Empty(cTrp)
		cTrp := cCdEmit
	EndIF

Return cTrp

// WSDL Data Structure ArrayOfResult

WSSTRUCT FreightRuleAcquisitionService_ArrayOfResult
	WSDATA   oWSresult                 AS FreightRuleAcquisitionService_result OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_ArrayOfResult
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_ArrayOfResult
	::oWSresult            := {} // Array Of  FreightRuleAcquisitionService_RESULT():New()
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_ArrayOfResult
	Local oClone := FreightRuleAcquisitionService_ArrayOfResult():NEW()
	oClone:oWSresult := NIL
	If ::oWSresult <> NIL 
		oClone:oWSresult := {}
		aEval( ::oWSresult , { |x| aadd( oClone:oWSresult , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FreightRuleAcquisitionService_ArrayOfResult
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RESULT","result",{},NIL,.T.,"O",NIL,"xsd") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSresult , FreightRuleAcquisitionService_result():New() )
			::oWSresult[len(::oWSresult)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfFreightRule

WSSTRUCT FreightRuleAcquisitionService_ArrayOfFreightRule
	WSDATA   oWSfreightRule            AS FreightRuleAcquisitionService_freightRule
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRule
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRule
	::oWSfreightRule       := {} // Array Of  FreightRuleAcquisitionService_FREIGHTRULE():New()
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRule
	Local oClone := FreightRuleAcquisitionService_ArrayOfFreightRule():NEW()
	oClone:oWSfreightRule := NIL
	If ::oWSfreightRule <> NIL 
		oClone:oWSfreightRule := {}
		aEval( ::oWSfreightRule , { |x| aadd( oClone:oWSfreightRule , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FreightRuleAcquisitionService_ArrayOfFreightRule
	Local cSoap := ""
	nX :=1 
	aEval( ::oWSfreightRule , {|x| cSoap := cSoap  +  WSSoapValue("fre:freightRule", x , x , "freightRule", .T. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure result

WSSTRUCT FreightRuleAcquisitionService_result
	WSDATA   oWSerrorCodes             AS FreightRuleAcquisitionService_ArrayOfErrorCode OPTIONAL
	WSDATA   cerrorMessage             AS string OPTIONAL
	WSDATA   oWSidentifier             AS SCHEMA OPTIONAL
	WSDATA   lsucess                   AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_result
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_result
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_result
	Local oClone := FreightRuleAcquisitionService_result():NEW()
	oClone:oWSerrorCodes        := IIF(::oWSerrorCodes = NIL , NIL , ::oWSerrorCodes:Clone() )
	oClone:cerrorMessage        := ::cerrorMessage
	oClone:oWSidentifier        := IIF(::oWSidentifier = NIL , NIL , ::oWSidentifier:Clone() )
	oClone:lsucess              := ::lsucess
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FreightRuleAcquisitionService_result
	Local oNode1
	
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ERRORCODES","ArrayOfErrorCode",NIL,NIL,NIL,"O",NIL,"xsd") 
	If oNode1 != NIL
		::oWSerrorCodes := FreightRuleAcquisitionService_ArrayOfErrorCode():New()
		::oWSerrorCodes:SoapRecv(oNode1)
	EndIf
	::cerrorMessage      :=  WSAdvValue( oResponse,"_ERRORMESSAGE","string",NIL,NIL,NIL,"S",NIL,"xsd") 
	
	// Neste trecho existia tratamento em relação a erro de schema de arquivo,
	// esse tratamento foi removido devido ao débito técnico de chamada de função

	::lsucess            :=  WSAdvValue( oResponse,"_SUCESS","boolean",NIL,NIL,NIL,"L",NIL,"xsd") 
Return

// WSDL Data Structure freightRule

WSSTRUCT FreightRuleAcquisitionService_freightRule
	WSDATA   ccarrierSourceId          AS string OPTIONAL
	WSDATA   cdestinationCarrierZoneSourceId AS string OPTIONAL
	WSDATA   cdestinationSourceId      AS string OPTIONAL
	WSDATA   coriginCarrierZoneSourceId AS string OPTIONAL
	WSDATA   coriginSourceId           AS string OPTIONAL
	WSDATA   cpriority                 AS string OPTIONAL
	WSDATA   cserviceType              AS string OPTIONAL
	WSDATA   cshipperSourceId          AS string OPTIONAL
	WSDATA   cvariable1                AS string OPTIONAL
	WSDATA   cvariable10               AS string OPTIONAL
	WSDATA   cvariable11               AS string OPTIONAL
	WSDATA   cvariable12               AS string OPTIONAL
	WSDATA   cvariable13               AS string OPTIONAL
	WSDATA   cvariable14               AS string OPTIONAL
	WSDATA   cvariable15               AS string OPTIONAL
	WSDATA   cvariable16               AS string OPTIONAL
	WSDATA   cvariable17               AS string OPTIONAL
	WSDATA   cvariable18               AS string OPTIONAL
	WSDATA   cvariable19               AS string OPTIONAL
	WSDATA   cvariable2                AS string OPTIONAL
	WSDATA   cvariable20               AS string OPTIONAL
	WSDATA   cvariable21               AS string OPTIONAL
	WSDATA   cvariable22               AS string OPTIONAL
	WSDATA   cvariable23               AS string OPTIONAL
	WSDATA   cvariable24               AS string OPTIONAL
	WSDATA   cvariable25               AS string OPTIONAL
	WSDATA   cvariable26               AS string OPTIONAL
	WSDATA   cvariable27               AS string OPTIONAL
	WSDATA   cvariable28               AS string OPTIONAL
	WSDATA   cvariable29               AS string OPTIONAL
	WSDATA   cvariable3                AS string OPTIONAL
	WSDATA   cvariable30               AS string OPTIONAL
	WSDATA   cvariable31               AS string OPTIONAL
	WSDATA   cvariable32               AS string OPTIONAL
	WSDATA   cvariable33               AS string OPTIONAL
	WSDATA   cvariable34               AS string OPTIONAL
	WSDATA   cvariable35               AS string OPTIONAL
	WSDATA   cvariable36               AS string OPTIONAL
	WSDATA   cvariable4                AS string OPTIONAL
	WSDATA   cvariable5                AS string OPTIONAL
	WSDATA   cvariable6                AS string OPTIONAL
	WSDATA   cvariable7                AS string OPTIONAL
	WSDATA   cvariable8                AS string OPTIONAL
	WSDATA   cvariable9                AS string OPTIONAL
	WSDATA   cvehicleSourceId          AS string OPTIONAL
	WSDATA   cAliasTab					AS string OPTIONAL
	WSDATA   lSameOrgDest				AS BOOLEAN OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD TipoServico
	WSMETHOD ZonaOrigem
	WSMETHOD ZonaDestino
	WSMETHOD LocalidadeOrigem
	WSMETHOD LocalidadeDestino
	WSMETHOD Cabecalho
	WSMETHOD DefineLocaiseZona
	WSMETHOD AdicionaComponentes
	WSMETHOD TrataComponente
	WSMETHOD CompAdicEnt
	WSMETHOD AdicionaExcedente
	WSMETHOD AdicionaImposto // Desativado
	WSMETHOD PercImposto
	WSMETHOD AdicionaFatorCubagem
	WSMETHOD AdicionaFaixa
	WSMETHOD ClassifFrete	
ENDWSSTRUCT

WSMETHOD NEW  WSCLIENT FreightRuleAcquisitionService_freightRule
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_freightRule
	::lSameOrgDest := .F.
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_freightRule
	Local oClone := FreightRuleAcquisitionService_freightRule():NEW()
	oClone:ccarrierSourceId     := ::ccarrierSourceId
	oClone:cdestinationCarrierZoneSourceId := ::cdestinationCarrierZoneSourceId
	oClone:cdestinationSourceId := ::cdestinationSourceId
	oClone:coriginCarrierZoneSourceId := ::coriginCarrierZoneSourceId
	oClone:coriginSourceId      := ::coriginSourceId
	oClone:cpriority            := ::cpriority
	oClone:cserviceType         := ::cserviceType
	oClone:cshipperSourceId     := ::cshipperSourceId
	oClone:cvariable1           := ::cvariable1
	oClone:cvariable10          := ::cvariable10
	oClone:cvariable11          := ::cvariable11
	oClone:cvariable12          := ::cvariable12
	oClone:cvariable13          := ::cvariable13
	oClone:cvariable14          := ::cvariable14
	oClone:cvariable15          := ::cvariable15
	oClone:cvariable16          := ::cvariable16
	oClone:cvariable17          := ::cvariable17
	oClone:cvariable18          := ::cvariable18
	oClone:cvariable19          := ::cvariable19
	oClone:cvariable2           := ::cvariable2
	oClone:cvariable20          := ::cvariable20
	oClone:cvariable21          := ::cvariable21 
	oClone:cvariable22          := ::cvariable22
	oClone:cvariable23          := ::cvariable23
	oClone:cvariable24          := ::cvariable24
	oClone:cvariable25          := ::cvariable25
	oClone:cvariable26          := ::cvariable26
	oClone:cvariable27          := ::cvariable27
	oClone:cvariable28          := ::cvariable28
	oClone:cvariable29          := ::cvariable29
	oClone:cvariable3           := ::cvariable3
	oClone:cvariable30          := ::cvariable30
	oClone:cvariable31          := ::cvariable31
	oClone:cvariable32          := ::cvariable32
	oClone:cvariable33          := ::cvariable33
	oClone:cvariable34          := ::cvariable34
	oClone:cvariable35          := ::cvariable35
	oClone:cvariable4           := ::cvariable4
	oClone:cvariable5           := ::cvariable5
	oClone:cvariable6           := ::cvariable6
	oClone:cvariable7           := ::cvariable7
	oClone:cvariable8           := ::cvariable8
	oClone:cvariable9           := ::cvariable9
	oClone:cvehicleSourceId     := ::cvehicleSourceId
	oClone:cAliasTab				:= ::cAliasTab
Return oClone

WSMETHOD SOAPSEND WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cSoap := ""
	
	cSoap += IIF(Empty(::ccarrierSourceId),"",WSSoapValue("fre:carrierSourceId", ::ccarrierSourceId, ::ccarrierSourceId , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cdestinationCarrierZoneSourceId),"",WSSoapValue("fre:destinationCarrierZoneSourceId", ::cdestinationCarrierZoneSourceId, ::cdestinationCarrierZoneSourceId , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::cdestinationSourceId),"",WSSoapValue("fre:destinationSourceId", ::cdestinationSourceId, ::cdestinationSourceId , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::coriginCarrierZoneSourceId),"",WSSoapValue("fre:originCarrierZoneSourceId", ::coriginCarrierZoneSourceId, ::coriginCarrierZoneSourceId , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::coriginSourceId),"",WSSoapValue("fre:originSourceId", ::coriginSourceId, ::coriginSourceId , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::cpriority),"",WSSoapValue("fre:priority", ::cpriority, ::cpriority , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::cserviceType),"",WSSoapValue("fre:serviceType", ::cserviceType, ::cserviceType , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cshipperSourceId),"",WSSoapValue("fre:shipperSourceId", ::cshipperSourceId, ::cshipperSourceId , "string", .F. , .F., 0 , NIL, .F.)) 
	cSoap += IIF(Empty(::cvariable1 ),"",WSSoapValue("fre:variable1",  ::cvariable1, ::cvariable1 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable10),"",WSSoapValue("fre:variable10", ::cvariable10, ::cvariable10 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable11),"",WSSoapValue("fre:variable11", ::cvariable11, ::cvariable11 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable12),"",WSSoapValue("fre:variable12", ::cvariable12, ::cvariable12 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable13),"",WSSoapValue("fre:variable13", ::cvariable13, ::cvariable13 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable14),"",WSSoapValue("fre:variable14", ::cvariable14, ::cvariable14 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable15),"",WSSoapValue("fre:variable15", ::cvariable15, ::cvariable15 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable16),"",WSSoapValue("fre:variable16", ::cvariable16, ::cvariable16 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable17),"",WSSoapValue("fre:variable17", ::cvariable17, ::cvariable17 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable18),"",WSSoapValue("fre:variable18", ::cvariable18, ::cvariable18 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable19),"",WSSoapValue("fre:variable19", ::cvariable19, ::cvariable19 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable2),"",WSSoapValue("fre:variable2",  ::cvariable2,  ::cvariable2  , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable20),"",WSSoapValue("fre:variable20", ::cvariable20, ::cvariable20 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable21),"",WSSoapValue("fre:variable21", ::cvariable21, ::cvariable21 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable22),"",WSSoapValue("fre:variable22", ::cvariable22, ::cvariable22 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable23),"",WSSoapValue("fre:variable23", ::cvariable23, ::cvariable23 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable24),"",WSSoapValue("fre:variable24", ::cvariable24, ::cvariable24 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable25),"",WSSoapValue("fre:variable25", ::cvariable25, ::cvariable25 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable26),"",WSSoapValue("fre:variable26", ::cvariable26, ::cvariable26 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable27),"",WSSoapValue("fre:variable27", ::cvariable27, ::cvariable27 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable28),"",WSSoapValue("fre:variable28", ::cvariable28, ::cvariable28 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable29),"",WSSoapValue("fre:variable29", ::cvariable29, ::cvariable29 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable3 ),"",WSSoapValue("fre:variable3",  ::cvariable3,  ::cvariable3 ,  "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable30),"",WSSoapValue("fre:variable30", ::cvariable30, ::cvariable30 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable31),"",WSSoapValue("fre:variable31", ::cvariable31, ::cvariable31 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable32),"",WSSoapValue("fre:variable32", ::cvariable32, ::cvariable32 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable33),"",WSSoapValue("fre:variable33", ::cvariable33, ::cvariable33 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable34),"",WSSoapValue("fre:variable34", ::cvariable34, ::cvariable34 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable35),"",WSSoapValue("fre:variable35", ::cvariable35, ::cvariable35 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable36),"",WSSoapValue("fre:variable36", ::cvariable36, ::cvariable36 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable4 ),"",WSSoapValue("fre:variable4", ::cvariable4, ::cvariable4 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable5 ),"",WSSoapValue("fre:variable5", ::cvariable5, ::cvariable5 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable6 ),"",WSSoapValue("fre:variable6", ::cvariable6, ::cvariable6 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable7 ),"",WSSoapValue("fre:variable7", ::cvariable7, ::cvariable7 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable8 ),"",WSSoapValue("fre:variable8", ::cvariable8, ::cvariable8 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvariable9 ),"",WSSoapValue("fre:variable9", ::cvariable9, ::cvariable9 , "string", .F. , .F., 0 , NIL, .F.))
	cSoap += IIF(Empty(::cvehicleSourceId),"",WSSoapValue("fre:vehicleSourceId", ::cvehicleSourceId, ::cvehicleSourceId , "string", .F. , .F., 0 , NIL, .F.))
	 
Return cSoap

WSMETHOD TipoServico WSSEND cTpServ,cCdTpOp WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cTipoServico := ""
	
	If Empty(cTpServ)
		cTipoServico := cCdTpOp
	Else
		cTipoServico := cTpServ
	EndIf
	
Return AllTrim(cTipoServico)

WSMETHOD ZonaOrigem WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cZonaOrigem := Nil
	If (::cAliasTab)->GV8_TPORIG == "0"
		cZonaOrigem := "||" + SuperGetMv("MV_CPLZTO",.F.,"")
	ElseIf (::cAliasTab)->GV8_TPORIG != "5"
		If (::cAliasTab)->GV8_TPORIG == "2"
			MsgAlert("Distância não implementado")
		Else
			cZonaOrigem := CPLZona((::cAliasTab)->GV8_TPORIG,(::cAliasTab)->GV8_NRCIOR,(::cAliasTab)->GV8_NRREOR,::ccarrierSourceId,(::cAliasTab)->GV8_CDUFOR,(::cAliasTab)->GV8_CDEMIT)
		EndIf
	EndIf
Return cZonaOrigem

WSMETHOD ZonaDestino WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cZonaDestino := Nil
	If (::cAliasTab)->GV8_TPDEST == "0"
		cZonaDestino := "||" + SuperGetMv("MV_CPLZTD",.F.,"")
	ElseIf (::cAliasTab)->GV8_TPDEST != "5"
		If (::cAliasTab)->GV8_TPDEST	 == "2"
			MsgAlert("Distância não implementado")
		Else
			cZonaDestino := CPLZona((::cAliasTab)->GV8_TPDEST,(::cAliasTab)->GV8_NRCIDS,(::cAliasTab)->GV8_NRREDS,::ccarrierSourceId,(::cAliasTab)->GV8_CDUFDS,(::cAliasTab)->GV8_CDEMIT)
		EndIf
	EndIf
Return cZonaDestino

WSMETHOD LocalidadeOrigem WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cLcOrigem := Nil
	If (::cAliasTab)->GV8_TPORIG == "5"
		cLcOrigem := LocalRemDest((::cAliasTab)->GV8_CDREM)
	EndIf
Return cLcOrigem

WSMETHOD LocalidadeDestino WSSEND cLocalDestino WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cLcDestino := Nil
	
	If Empty(cLocalDestino)
		cLocalDestino := (::cAliasTab)->GV8_CDDEST
	Else
		cLcDestino := LocalRemDest(cLocalDestino)
	EndIf
	
	If Empty(cLcDestino) .And. (::cAliasTab)->GV8_TPDEST == "5"
		cLcDestino := LocalRemDest(cLocalDestino)
	EndIf
Return cLcDestino

WSMETHOD Cabecalho WSSEND oGrupo WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cCodFil := IIf(SuperGetMv("MV_ERPGFE",.F.,"1") == "2",GFEXGETFIL("DUT"),"")

	::cserviceType         := ::TipoServico((::cAliasTab)->GV9_CPLTS,(::cAliasTab)->GV9_CDTPOP)
	::ccarrierSourceId     := oGrupo:Transportador((::cAliasTab)->GV9_CDEMIT)
	::cvehicleSourceId     := AllTrim((::cAliasTab)->GV7_CDTPVC)+AllTrim(cCodFil)
	
Return

WSMETHOD DefineLocaiseZona WSSEND lInverte, cLocalDest, lAdicEnt WSCLIENT FreightRuleAcquisitionService_freightRule

	If lAdicEnt //Se adicional de entrega, vale para todas as faixas
		::coriginCarrierZoneSourceId      :=  SuperGetMv("MV_CPLZTO",.F.,"")
	Else
	
		If !lInverte
			
			//ZonaTransporte
			::coriginCarrierZoneSourceId := ::ZonaOrigem()
			::cdestinationCarrierZoneSourceId := ::ZonaDestino()
			//Localidade
			::coriginSourceId      := ::LocalidadeOrigem()
			::cdestinationSourceId := ::LocalidadeDestino(cLocalDest)
			
		Else
			
			//ZonaTransporte
			::coriginCarrierZoneSourceId := ::ZonaDestino()
			::cdestinationCarrierZoneSourceId := ::ZonaOrigem()
			//Localidade
			::coriginSourceId      := ::LocalidadeDestino(cLocalDest)
			::cdestinationSourceId := ::LocalidadeOrigem()
			
		EndIf
	EndIf
		
	If !Empty(::coriginCarrierZoneSourceId) .And. !Empty(::cdestinationCarrierZoneSourceId)
	
		If At("|",::coriginCarrierZoneSourceId) > 0 .Or. At("|",::cdestinationCarrierZoneSourceId) > 0
			If !Empty(cLocalDest)
				::cpriority := "2"
			Else
				::cpriority := "1"
			EndIf
		Else
			If !Empty(cLocalDest)
				::cpriority := "4"
			Else
				::cpriority := "3"
			EndIf
		EndIf
	
	ElseIf !Empty(::coriginCarrierZoneSourceId) .And. !Empty(::cdestinationSourceId)

		If At("|",::coriginCarrierZoneSourceId) > 0
			If !Empty(cLocalDest)
				::cpriority := "6"
			Else
				::cpriority := "5"
			EndIf
		Else
			If !Empty(cLocalDest)
				::cpriority := "8"
			Else
				::cpriority := "7"
			EndIf
		EndIf

	ElseIf !Empty(::coriginSourceId) .And. !Empty(::cdestinationCarrierZoneSourceId)
		
		If At("|",::cdestinationCarrierZoneSourceId) > 0
			If !Empty(cLocalDest)
				::cpriority := "10"
			Else
				::cpriority := "9"
			EndIf
		Else
			If !Empty(cLocalDest)
				::cpriority := "12"
			Else
				::cpriority := "11"
			EndIf
		EndIf

	ElseIf !Empty(::coriginSourceId) .And. !Empty(::cdestinationSourceId)

		If !Empty(cLocalDest)
			::cpriority := "14"
		Else
			::cpriority := "13"
		EndIf
	Else
		::cpriority := "0"
	EndIf
	
	If !Empty(::coriginCarrierZoneSourceId) .And. At("|",::coriginCarrierZoneSourceId) > 0
		::coriginCarrierZoneSourceId := subStr(::coriginCarrierZoneSourceId,3)
	EndIf 
		
	If !Empty(::cdestinationCarrierZoneSourceId) .And. At("|",::cdestinationCarrierZoneSourceId) > 0
		::cdestinationCarrierZoneSourceId := subStr(::cdestinationCarrierZoneSourceId,3)
	EndIf
	
	//Quando a localidade e a zona estão definidas ao mesmo tempo, prevalece a localidade
	
	If  ::coriginCarrierZoneSourceId != Nil .And. ::coriginSourceId != Nil
		::coriginCarrierZoneSourceId := Nil
	EndIf
	
	If  ::cdestinationCarrierZoneSourceId != Nil .And. ::cdestinationSourceId != Nil
		::cdestinationCarrierZoneSourceId := Nil
	EndIf
	
	If !Empty(::coriginSourceId) .And. !Empty(::cdestinationSourceId) .And. ::coriginSourceId == ::cdestinationSourceId
		::lSameOrgDest := .T.
	ElseIf !Empty(::coriginSourceId) .And. !Empty(::cdestinationCarrierZoneSourceId) .And. ::coriginSourceId == ::cdestinationCarrierZoneSourceId
		::lSameOrgDest := .T.
	ElseIf !Empty(::coriginCarrierZoneSourceId) .And. !Empty(::cdestinationSourceId) .And. ::coriginCarrierZoneSourceId == ::cdestinationSourceId
		::lSameOrgDest := .T.
	ElseIf !Empty(::coriginCarrierZoneSourceId) .And. !Empty(::cdestinationCarrierZoneSourceId) .And. ::coriginCarrierZoneSourceId == ::cdestinationCarrierZoneSourceId
		::lSameOrgDest := .T.
	EndIf
	
	If SuperGetMv("MV_ERPGFE",.F.,"1") == "1"
		If !Empty(::coriginSourceId)
			 ::coriginSourceId += DS_LOCALPADRAO
		EndIf
		
		If !Empty(::cdestinationSourceId)
			::cdestinationSourceId += DS_LOCALPADRAO
		EndIf
	EndIf
Return

//Desativado
WSMETHOD AdicionaImposto WSSEND cCdDest WSCLIENT FreightRuleAcquisitionService_freightRule 
	Local aParImp := Array(PERCIMPOS_TAM)
	
	aParImp[PER_TIPORIGEM] := (::cAliasTab)->GV8_TPORIG
	
	If aParImp[PER_TIPORIGEM] == '1'
		aParImp[PER_CONTORIG] := (::cAliasTab)->GV8_NRCIOR
	ElseIf aParImp[PER_TIPORIGEM] == '3'
		aParImp[PER_CONTORIG] := (::cAliasTab)->GV8_NRREOR
	ElseIf aParImp[PER_TIPORIGEM] == '4'
		aParImp[PER_CONTORIG] := (::cAliasTab)->GV8_CDUFOR
	ElseIf aParImp[PER_TIPORIGEM] == '5'
		aParImp[PER_CONTORIG] := (::cAliasTab)->GV8_CDREM
	EndIf
	
	aParImp[PER_TIPODESTI] := (::cAliasTab)->GV8_TPDEST
	
	If aParImp[PER_TIPODESTI] == '1'
		aParImp[PER_CONTDEST] := (::cAliasTab)->GV8_NRCIDS
	ElseIf aParImp[PER_TIPODESTI] == '3'
		aParImp[PER_CONTDEST] := (::cAliasTab)->GV8_NRREDS
	ElseIf aParImp[PER_TIPODESTI] == '4'
		aParImp[PER_CONTDEST] := (::cAliasTab)->GV8_CDUFDS
	ElseIf aParImp[PER_TIPODESTI] == '5'
		If Empty(cCdDest)
			aParImp[PER_CONTDEST] := (::cAliasTab)->GV8_CDDEST
		Else
			aParImp[PER_CONTDEST] := cCdDest
		EndIf
	EndIf
	
	aParImp[PER_ADDISS   ] := (::cAliasTab)->GV9_ADISS
	aParImp[PER_ADDICMS  ] := (::cAliasTab)->GV9_ADICMS
	aParImp[PER_TRANSPOR ] := GVA->GVA_CDEMIT
	
	If aParImp[PER_TIPORIGEM] == '2' .Or. aParImp[PER_TIPODESTI] == '2' // Distância não é determinado.
		::cvariable7 := TrataNumerico(0)
	Else
		::cvariable7 := TrataNumerico(::PercImposto(aParImp))
	EndIf
	
	aSize(aParImp,0)
Return

//Retorna o percentual de imposto simplificado para tabela de frete. Retorna nulo quando não se aplica.
WSMETHOD PercImposto WSSEND aParam WSCLIENT FreightRuleAcquisitionService_freightRule
	
	Local nPercImp := 0
	Local lPodeIss := .F.
	Local cPesqOrig := ""
	Local cPesqDest := ""
	
	If '[' + aParam[PER_TIPORIGEM] + ']' $ '[1][5]' .And. '[' + aParam[PER_TIPODESTI] + ']' $ '[1][5]' .And. aParam[PER_ADDISS   ] == '1'
		
		//Verificar se são da mesma cidade
		If aParam[PER_TIPORIGEM] == '1'
			cPesqOrig := aParam[PER_CONTORIG]
		Else
			cPesqOrig := Posicione("GU3",1,xFilial("GU3") + aParam[PER_CONTORIG], "GU3_NRCID")
		EndIf
		
		If aParam[PER_TIPODESTI] == '1'
			cPesqDest := aParam[PER_CONTDEST]
		Else
			cPesqDest := Posicione("GU3",1,xFilial("GU3") + aParam[PER_CONTDEST], "GU3_NRCID")
		EndIf
		
		If AllTrim(cPesqDest) == cPesqOrig // Cidades iguais
			lPodeIss := .T.
		EndIf
		
	EndIf
	
	If lPodeIss
		
		dbSelectArea("GU3")
		GU3->(dbSetOrder(1))
		GU3->(MsSeek(xFilial("GU3") + aParam[PER_TRANSPOR ]))
		
		If GU3->GU3_TPTRIB == "2" .AND. GU3->GU3_CONISS == "1"
		
			If GU3->GU3_PCISS == 0
				nPercImp := Posicione("GU7",1,xFilial("GU7") + cPesqDest,"GU7_PCISS")
			Else
				nPercImp := GU3->GU3_PCISS
			EndIf
			
		EndIf
		
	Else // Verificar se icms
		
		If aParam[PER_ADDICMS  ] == '1'
			
			//descobrir as uf a seguir
			If !Empty(cPesqDest + cPesqOrig) // Direto pelas cidades já pesquisada
			
				cPesqOrig := Posicione("GU7",1,xFilial("GU7") + cPesqOrig,"GU7_CDUF")
				cPesqDest := Posicione("GU7",1,xFilial("GU7") + cPesqDest,"GU7_CDUF")
				
			Else// Outros tipos combinados ou não com cidade/remetente/destinatario
				
				If aParam[PER_TIPORIGEM] == '1'
					cPesqOrig := Posicione("GU7",1,xFilial("GU7") + aParam[PER_CONTORIG],"GU7_CDUF")
				ElseIf aParam[PER_TIPORIGEM] == '4'
					cPesqOrig := aParam[PER_CONTORIG]
				ElseIf aParam[PER_TIPORIGEM] == '5'
					cPesqOrig := Posicione("GU3",1,xFilial("GU3") + aParam[PER_CONTORIG], "GU3_NRCID")
					cPesqOrig := Posicione("GU7",1,xFilial("GU7") + cPesqOrig,"GU7_CDUF")
				EndIf
				
				If aParam[PER_TIPODESTI] == '1'
					cPesqDest := Posicione("GU7",1,xFilial("GU7") + aParam[PER_CONTDEST],"GU7_CDUF")
				ElseIf aParam[PER_TIPODESTI] == '4'
					cPesqDest := aParam[PER_CONTDEST]
				ElseIf aParam[PER_TIPODESTI] == '5'
					cPesqDest := Posicione("GU3",1,xFilial("GU3") + aParam[PER_CONTDEST], "GU3_NRCID")
					cPesqDest := Posicione("GU7",1,xFilial("GU7") + cPesqDest,"GU7_CDUF")
				EndIf
				
			EndIf
			
			If !Empty(cPesqDest) .And. !Empty(cPesqOrig) 
			
				If cPesqOrig == cPesqDest //Mesmo estado
					nPercImp := Posicione("GUT",1,xFilial("GUT") + cPesqOrig, "GUT_PCEC")
				Else
					nPercImp := Posicione("GUT",1,xFilial("GUT") + cPesqOrig, "GUT_PCIC")
				EndIf
			
			EndIf
			
		EndIf
		
	EndIf
	
	If Empty(nPercImp)
		nPercImp := 0
	EndIf
	
Return nPercImp

WSMETHOD AdicionaFatorCubagem WSCLIENT FreightRuleAcquisitionService_freightRule

	::cvariable10 			:= TrataNumerico((::cAliasTab)->GV9_QTKGM3)
	
Return

WSMETHOD AdicionaFaixa WSSEND cFxEntIni, cFxEntFim, nFaixaExc, cCalcExc, cAtrExc, cTpExce WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cFaixa
	Local cFaixaIni
	Local cFaixaFim
	Local nTamGV7_CDFXTV := TamSx3("GV7_CDFXTV")[1]
	Local cAtribFx := ""
	Local nX := 0
	Local lExcedente := .F.
	
	//Adicional por Entrega - Faixa definida pela GUZ 
	If !Empty(cFxEntIni) .Or. !Empty(cFxEntFim)
		
		/*Qtde Entregas*/	    
		::cvariable30 := cFxEntIni //"QTDE ENTREGAS INICIAL"	             
		::cvariable31 := cFxEntFim //"QTDE ENTREGAS FINAL"
	
	Else
		
		If (::cAliasTab)->GV9_TPLOTA == '1' // Fracionado
			
			cAtribFx := AllTrim((::cAliasTab)->GV9_ATRFAI)
			
			dbselectArea("GV7")
			GV7->(dbSetOrder(1))
			
			//Posiciona na faixa anterior
			cFaixa := Strzero(Val((::cAliasTab)->GV7_CDFXTV) - 1,nTamGV7_CDFXTV)
			
			If cFaixa == Strzero(0,nTamGV7_CDFXTV)
				
				cFaixaIni := "0" 
				cFaixaFim := If((::cAliasTab)->GV7_QTFXFI == 0,"0",TrataNumerico((::cAliasTab)->GV7_QTFXFI)) 
			
			Else
			
				GV7->(MsSeek((::cAliasTab)->(GV7_FILIAL+GV7_CDEMIT+GV7_NRTAB+GV7_NRNEG+GV7_CDFXTV)))
				GV7->(DbSkip(-1)) //Utilizado dbskip pois as faixas podem não estar sequenciais
				
				cFaixaIni := If(GV7->GV7_QTFXFI == 0,"0",TrataNumerico(GV7->GV7_QTFXFI+0.00001))
				cFaixaFim := If((::cAliasTab)->GV7_QTFXFI == 0,"0",TrataNumerico((::cAliasTab)->GV7_QTFXFI))
				
			EndIf
		EndIf
		
		If !Empty(nFaixaExc) //Tem Excedente

			::cvariable34 := TrataNumerico(nFaixaExc)
			::cvariable35 := IIF(cCalcExc == '1','Diferenca','Total')
			
			if Empty(cAtribFx) .Or. cAtrExc <> cAtribFx //Unid do componente é diferente da faixa 
				lExcedente := .T.
				cFaixaExcIni := IIf(cTpExce == '1', "0" ,TrataNumerico(nFaixaExc+0.00001)  )
				cFaixaExcFim := IIf(cTpExce == '1', TrataNumerico(nFaixaExc),"999999999.99999")
			Else
				cAtribFx := AllTrim(cAtrExc)
	 			
	 			If cTpExce == '1' //Normal - "1ª Linha"
					If Empty(cFaixaIni)
						cFaixaIni := "0"
					EndIf 
					
					cFaixaFim := TrataNumerico(nFaixaExc)
					
				Else //Excedente - "2ª Linha"
					cFaixaIni := TrataNumerico(nFaixaExc+0.00001)    
					
					If Empty(cFaixaFim)
						cFaixaFim := "999999999.99999"
					EndIf
				EndIf
			EndIF
		EndIF
			
		::cvariable21 := AllTrim((::cAliasTab)->GV9_UNIFAI) //"UNIDADE DE MEDIDA FAIXA PESO"
		
		For nX := 1 To 2
			
			If nX == 1 .Or. (nX == 2 .And. lExcedente)
			
				If nX == 2
					cAtribFx  := AllTrim(cAtrExc)
					cFaixaIni := cFaixaExcIni 
					cFaixaFim := cFaixaExcFim 
				EndIF
				
				Do Case
					Case cAtribFx == '1' /*Peso*/
						
						IF !Empty(::cvariable8) /*Peso Liq*/
							::cvariable19 := cFaixaIni //"PESO LÍQUIDO INICIAL"	             
							::cvariable20 := cFaixaFim //"PESO LÍQUIDO FINAL"
						Else /*Peso Bruto*/ 
							::cvariable17 := cFaixaIni //"PESO BRUTO INICIAL"	              
							::cvariable18 := cFaixaFim //"PESO BRUTO FINAL"
						EndIF
						
					Case cAtribFx $ '2|8|9' /*Valor*/	             
						::cvariable22 := cFaixaIni //"VALOR CARGA INICIAL"	             
						::cvariable23 := cFaixaFim //"VALOR CARGA FINAL"
					
					Case cAtribFx == '3' /*Qtde Itens*/                       
						::cvariable26 := cFaixaIni //"QTDE ITENS INICIAL"	             
						::cvariable27 := cFaixaFim //"QTDE ITENS FINAL"
					
					Case cAtribFx == '4' /*Volumes*/	           
						::cvariable32 := cFaixaIni //"VOLUME M3 INICIAL"	          
						::cvariable33 := cFaixaFim //"VOLUME M3 FINAL"
					
					Case cAtribFx == '5' /*Qtde Volumes*/	                 
						::cvariable28 := cFaixaIni //"QTDE VOLUMES INICIAL"	                 
						::cvariable29 := cFaixaFim //"QTDE VOLUMES FINAL"
								
					Case cAtribFx == '6'/*Distância*/	             
						::cvariable24 := cFaixaIni //"KM INICIAL"	                     
						::cvariable25 := cFaixaFim //"KM FINAL"	  
							
					Case cAtribFx == '7' /*Qtde Entregas*/	             
						::cvariable30 := cFaixaIni //"QTDE ENTREGAS INICIAL"	             
						::cvariable31 := cFaixaFim //"QTDE ENTREGAS FINAL"
						
					Case cAtribFx == '10' /*Peso Liq*/             
						::cvariable19 := cFaixaIni //"PESO LÍQUIDO INICIAL"	             
						::cvariable20 := cFaixaFim //"PESO LÍQUIDO FINAL"
						
					Otherwise
						::cvariable17 := cFaixaIni //"PESO BRUTO INICIAL"	              
						::cvariable18 := cFaixaFim //"PESO BRUTO FINAL"
					                
				EndCase
			EndIf   
		Next nX
		
	EndIF                                                
Return

WSMETHOD ClassifFrete WSCLIENT FreightRuleAcquisitionService_freightRule

	::cvariable36 			:= (::cAliasTab)->GV9_CDCLFR
	
Return

WSMETHOD AdicionaComponentes WSSEND cAliasComp, aComp WSCLIENT FreightRuleAcquisitionService_freightRule
	
	//Local nPesoFrete
	
	If Empty(aComp)
		aComp := CompNormal(::cAliasTab, cAliasComp)
	EndIf
	
	aComp := ::TrataComponente(aComp)
			
	If aComp[VAR_VALORMIN ] == Nil
		aComp[VAR_VALORMIN ] := '0'
	EndIF
	
	If aComp[VAR_FRETEVALOR ] == Nil
		aComp[VAR_FRETEVALOR ] := '0'
	EndIF
	
	::cvariable1  := aComp[VAR_CODCOMP  ]
	::cvariable2  := aComp[VAR_CODCPL   ]
	::cvariable3  := aComp[VAR_VALORMIN ]
	::cvariable4  := aComp[VAR_VALORFIX ]
	::cvariable5  := aComp[VAR_FRETEVALOR]
	::cvariable6  := aComp[VAR_SUBTOTFRET]
	::cvariable7  := aComp[VAR_FRETEPESOB]
	::cvariable8  := aComp[VAR_FRETEPESOL]
	::cvariable9  := aComp[VAR_FRACAO   ]
	::cvariable11 := aComp[VAR_UNIMED   ]
	::cvariable12 := aComp[VAR_QTDEITENS]
	::cvariable13 := aComp[VAR_QTDEVOLUM]
	::cvariable14 := aComp[VAR_QTDEENTRG]
	::cvariable15 := aComp[VAR_VOLUME   ]
	::cvariable16 := aComp[VAR_DISTANCIA]
	
		
Return

WSMETHOD TrataComponente WSSEND aComp WSCLIENT FreightRuleAcquisitionService_freightRule
	Local nX
	For nX := 1 To VARIAVEIS_TAM
		aComp[nX] := TrataNumerico(aComp[nX])
	Next nX
Return aComp

Static Function TrataNumerico(nValor)
	If ValType(nValor) != "C" //tratado
		If nValor == 0
			nValor := Nil
		ElseIf nValor != Nil
			nValor := cValToChar(nValor)
		EndIf
	EndIf
Return nValor



WSMETHOD CompAdicEnt WSSEND cAliasTab WSCLIENT FreightRuleAcquisitionService_freightRule
	Local cQuery :=""
	Local cAliasQry 
	Local aCompsAdds := {}
	Local aComp
	Local nTam := TamSx3("GUZ_SEQFAI")[1]
	cFaixaIni := "0"
	cFaixaFim := "0"


	cAliasQry := GetNextAlias()
	cQuery+="select	GUZ_FILIAL, GUZ_CDEMIT, GUZ_NRTAB, GUZ_NRNEG, GUZ_SEQFAI, GUZ_VLFXFI, GUZ_VLENTR VALORFIXO , GUZ_PCENTR SUBTOTFRET		 "
	cQuery+="	from " + RetSqlName("GUZ") + "                 "
	cQuery+="where " + RetSqlName("GUZ") + ".d_e_l_e_t_ = '' "
	cQuery+="and guz_filial = '" + GVA->GVA_FILIAL + "'                          "
	cQuery+="and guz_cdemit = '" + GVA->GVA_CDEMIT + "'                          "
	cQuery+="and guz_nrtab  = '" + GVA->GVA_NRTAB  + "'                          "
	cQuery+="and guz_nrneg  = '" + (cAliasTab)->GV9_NRNEG  + "'                          "
	cQuery+="ORDER BY GUZ_SEQFAI "
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasQry, .F., .T.)
	
	While !(cAliasQry)->(Eof())
		
		dbselectArea("GUZ")
		GUZ->(dbSetOrder(1))
		
		//Posiciona na faixa anterior
		cFaixa := Strzero(Val((cAliasQry)->GUZ_SEQFAI) - 1,nTam)
		
		If cFaixa == Strzero(0,nTam)
			
			cFaixaIni := "0" 
			cFaixaFim := If((cAliasQry)->GUZ_VLFXFI == 0,"0",TrataNumerico((cAliasQry)->GUZ_VLFXFI)) 
		
		Else
		
			GUZ->(MsSeek((cAliasQry)->(GUZ_FILIAL+GUZ_CDEMIT+GUZ_NRTAB+GUZ_NRNEG+GUZ_SEQFAI)))
			GUZ->(DbSkip(-1)) //Utilizado dbskip pois as faixas podem não estar sequenciais
			
			cFaixaIni := If(GUZ->GUZ_VLFXFI == 0,"0",TrataNumerico(GUZ->GUZ_VLFXFI+0.00001))
			cFaixaFim := If((cAliasQry)->GUZ_VLFXFI == 0,"0",TrataNumerico((cAliasQry)->GUZ_VLFXFI))
			
		EndIf
	
		aComp := NovoComps()
		
		aComp[VAR_CODCOMP  ]  := (cAliasTab)->GV9_COMFXE //"CÓDIGO DO COMPONENTE"
		aComp[VAR_VALORFIX ]  := (cAliasQry)->VALORFIXO  
		aComp[VAR_SUBTOTFRET] := (cAliasQry)->SUBTOTFRET
		
		If aComp[VAR_SUBTOTFRET] > 0
			aComp[VAR_SUBTOTFRET] := aComp[VAR_SUBTOTFRET]/100
		EndIf
					
		aAdd(aCompsAdds,{cFaixaIni,cFaixaFim,aComp})
		
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aCompsAdds

WSMETHOD AdicionaExcedente WSSEND cAliasTab WSCLIENT FreightRuleAcquisitionService_freightRule
	
	aComp := NovoComps()
	
	aComp[VAR_UNIMED   ]  := (::cAliasTab)->GV7_UNICAL	
	aComp[VAR_CODCOMP  ]  := (cAliasTab)->CDCOMP //"CÓDIGO DO COMPONENTE"
	aComp[VAR_VALORFIX ]  := (cAliasTab)->GV1_VLFIXE
	
	If GFXCP12123("GUY_CPLPFR")
		cIdCPL = Posicione("GUY",1,xFilial("GUY")+(::cAliasTab)->(GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG)+(cAliasTab)->CDCOMP,"GUY_CPLPFR")
		If !Empty(cIdCPL)
			aComp[VAR_CODCPL]  := AllTrim(cIdCPL) //"CODIGO COCKPIT LOGISTICO"
		EndIF
	EndIf
	
	Do Case
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '2'
			aComp[VAR_FRETEVALOR] := (cAliasTab)->GV1_PCEXTR
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '9'
			aComp[VAR_SUBTOTFRET] := (cAliasTab)->GV1_PCEXTR
		
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '1'  
			aComp[VAR_FRETEPESOB] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '10'           
			aComp[VAR_FRETEPESOL] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '3'  
			aComp[VAR_QTDEITENS ] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '5'  
			aComp[VAR_QTDEVOLUM ] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '7'  
			aComp[VAR_QTDEENTRG ] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '4'  
			aComp[VAR_VOLUME    ] := (cAliasTab)->GV1_VLUNIE
		Case AllTrim((cAliasTab)->GV2_ATRCAL) == '6'  
			aComp[VAR_DISTANCIA ] := (cAliasTab)->GV1_VLUNIE
	EndCase
	
	aComp[VAR_VALORMIN  ] := (cAliasTab)->VALORMIN
	
	If (::cAliasTab)->GV6_FRMIN <> 0 .And. (::cAliasTab)->GV6_FRMIN > aComp[VAR_VALORMIN ]
		aComp[VAR_VALORMIN  ] := (::cAliasTab)->GV6_FRMIN
	EndIF
	
	If !Empty(aComp[VAR_FRETEVALOR]) 
		aComp[VAR_FRETEVALOR] := aComp[VAR_FRETEVALOR]/100
	EndIf
	
	If !Empty(aComp[VAR_SUBTOTFRET]) 
		aComp[VAR_SUBTOTFRET] := aComp[VAR_SUBTOTFRET]/100
	EndIf

Return aComp

Static Function NovoComps()
Return Array(VARIAVEIS_TAM)

Static Function CompNormal(cAlGV9, cAliasQry)
	Local cIdCPL   := ""
	Local aValComp := NovoComps()
	
	aValComp[VAR_CODCOMP  ]  := (cAliasQry)->CDCOMP //"CÓDIGO DO COMPONENTE"
	aValComp[VAR_UNIMED   ]  := (cAlGV9)->GV7_UNICAL
	aValComp[VAR_VALORMIN ]  := ValorVinc((cAliasQry)->VALORMIN   ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_VALORFIX ]  := ValorVinc((cAliasQry)->VALORFIXO  ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_FRETEVALOR] := ValorVinc((cAliasQry)->FRETEVALOR ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_SUBTOTFRET] := ValorVinc((cAliasQry)->SUBTOTFRET ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_FRETEPESOB] := ValorVinc((cAliasQry)->FRETEPESOB ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_FRETEPESOL] := ValorVinc((cAliasQry)->FRETEPESOL ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_FRACAO   ]  := (cAliasQry)->FRACAO
	aValComp[VAR_QTDEITENS]  := ValorVinc((cAliasQry)->QTDEITENS  ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_QTDEVOLUM]  := ValorVinc((cAliasQry)->QTDEVOLUM  ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_QTDEENTRG]  := ValorVinc((cAliasQry)->QTDEENTRG  ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_VOLUME   ]  := ValorVinc((cAliasQry)->VOLUME     ,(cAliasQry)->GVB_CDCOMP)
	aValComp[VAR_DISTANCIA]  := ValorVinc((cAliasQry)->DISTANCIA  ,(cAliasQry)->GVB_CDCOMP)
	
	If (cAlGV9)->GV6_FRMIN <> 0 .And. (cAlGV9)->GV6_FRMIN > aValComp[VAR_VALORMIN ]
		aValComp[VAR_VALORMIN  ] := (cAlGV9)->GV6_FRMIN
	EndIF
	
	If aValComp[VAR_FRETEVALOR] > 0
		aValComp[VAR_FRETEVALOR] := aValComp[VAR_FRETEVALOR]/100
	EndIf
	
	If aValComp[VAR_SUBTOTFRET] > 0
		aValComp[VAR_SUBTOTFRET] := aValComp[VAR_SUBTOTFRET]/100
	EndIf
	
	If GFXCP12123("GUY_CPLPFR")
		cIdCPL = Posicione("GUY",1,xFilial("GUY")+(cAlGV9)->(GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG)+(cAliasQry)->CDCOMP,"GUY_CPLPFR")
		If !Empty(cIdCPL)
			aValComp[VAR_CODCPL]  := AllTrim(cIdCPL) //"CODIGO COCKPIT LOGISTICO"
		EndIF
	EndIf
Return aValComp

Static Function ValorVinc(nValor,cCdComp)
	If GVA->GVA_TPTAB == '2' .And. Empty(cCdComp)
		nValor := (nValor * GVA->GVA_VLMULT) + GVA->GVA_VLADIC
	EndIf
Return nValor

Static Function CPLZona(cOrigem,cCidade,cRegiao,cTrp,cUf,cCdEmit)

	If cOrigem == "1"
		cRet := ZonaCidade(cCidade)
	ElseIf cOrigem == "3"
		
		If Empty(cTrp)
			cTrp := Posicione("GU3", 1, xFilial("GU3") + cCdEmit, "GU3_CDTERP")
		EndIf
		cRet := ZonaRegiao(cRegiao,cTrp)
		
	ElseIf cOrigem == "4"
		cRet := ZonaUf(cUf)
	Else
		MsgInfo("cOrigem " + cOrigem + " Não implementado ")  
	EndIf

Return cRet

Static Function ZonaCidade(cCidade)
	Local cZonaCidade := ""
	dbSelectArea("GU7")
	GU7->(dbSetOrder(1))
	GU7->(MsSeek(xFilial("GU7") + cCidade))
	cZonaCidade := AllTrim(GU7->GU7_NMCID) + "-" + GU7->GU7_CDUF
Return cZonaCidade

Static Function ZonaRegiao(cRegiao,cTrp)
	Local cZonaRegiao := ""
	dbSelectArea("GU9")
	GU9->(dbSetOrder(1))
	GU9->(MsSeek(xFilial("GU9") + cRegiao))
	If !Empty(GU9->GU9_CPLZT)
		cZonaRegiao := GU9->GU9_CPLZT
	Else
		cZonaRegiao := AllTrim(cTrp) + '-' + AllTrim(GU9->GU9_NMREG)
	EndIf
Return cZonaRegiao

Static Function ZonaUf(cUf)
Return cUf

Static Function LocalRemDest(cCdEmit)
	Local cCodFil := ""
	Local cCodERP := "" 
	Local cLojERP := ""
	
	/*Tratamento código do cliente*/
	If SuperGetMv("MV_ERPGFE",.F.,"1") == "2" //Protheus
		
		cCodFil := GFEXGETFIL("SA1")
		cCodERP := RTrim(Posicione("GU3",1,xFilial("GU3") + cCdEmit,"GU3_CDERP")) 
		cLojERP := RTrim(Posicione("GU3",1,xFilial("GU3") + cCdEmit,"GU3_CDCERP"))
		cIDFed  := RTrim(Posicione("GU3",1,xFilial("GU3") + cCdEmit,"GU3_IDFED"))
		
		If Empty(cCodERP) .Or. Empty(cLojERP)
			dbSelectarea("SA1")
			SA1->(DbSetOrder(3)) // Filial + cgc
			SA1->(dbSeek(xFilial("SA1") + cIDFed))
			If !SA1->(Eof())
				cCodERP := SA1->A1_COD
				cLojERP := SA1->A1_LOJA
			EndIf
		EndIF
		
		If !Empty(cCodERP) .And. !Empty(cLojERP)
			cCdEmit := "CLI-" + RTrim(cCodERP) + "-" + RTrim(cLojERP) + RTrim(cCodFil)
		EndIf
	EndIf

Return AllTrim(cCdEmit)

// WSDL Data Structure ArrayOfErrorCode

WSSTRUCT FreightRuleAcquisitionService_ArrayOfErrorCode
	WSDATA   oWSerrorCode              AS FreightRuleAcquisitionService_errorCode OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_ArrayOfErrorCode
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_ArrayOfErrorCode
	::oWSerrorCode         := {} // Array Of  FreightRuleAcquisitionService_ERRORCODE():New()
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_ArrayOfErrorCode
	Local oClone := FreightRuleAcquisitionService_ArrayOfErrorCode():NEW()
	oClone:oWSerrorCode := NIL
	If ::oWSerrorCode <> NIL 
		oClone:oWSerrorCode := {}
		aEval( ::oWSerrorCode , { |x| aadd( oClone:oWSerrorCode , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FreightRuleAcquisitionService_ArrayOfErrorCode
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERRORCODE","errorCode",{},NIL,.T.,"O",NIL,"xsd") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSerrorCode , FreightRuleAcquisitionService_errorCode():New() )
			::oWSerrorCode[len(::oWSerrorCode)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure errorCode

WSSTRUCT FreightRuleAcquisitionService_errorCode
	WSDATA   cvalue                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FreightRuleAcquisitionService_errorCode
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FreightRuleAcquisitionService_errorCode
Return

WSMETHOD CLONE WSCLIENT FreightRuleAcquisitionService_errorCode
	Local oClone := FreightRuleAcquisitionService_errorCode():NEW()
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FreightRuleAcquisitionService_errorCode
	::Init()
	If oResponse == NIL 
		Return
	Endif 
	::cvalue := WSAdvValue(oResponse,"_VALUE","string",,,,"S",,"xsd")
Return

Function NovoEnvioGrupoFrete()
	Local oWs := WSFreightRuleAcquisitionService():New()
	oWs:cEnderecoWs := SuperGetMv("MV_CPLURL",.T.,"")
	
	If Rat("/",oWs:cEnderecoWs) == Len(oWs:cEnderecoWs)
		oWs:cEnderecoWs := SubStr(oWs:cEnderecoWs,1,Len(oWs:cEnderecoWs)-1)
	EndIf
	
	oWs:cEnderecoWs += "/FreightRuleAcquisitionService"
	
Return oWs

/*
Static Function ConverteUM(nPesoFrete,cUniFaixa,cUniParam)

	dbSelectArea("GUV")
	GUV->(dbSetOrder(01))
	If GUV->(msSeek(xFilial("GUV") + cUniFaixa +  AllTrim(cUniParam) ))
		nPesoFrete := (nPesoFrete/GUV->GUV_QTDDE) * GUV->GUV_QTDPAR
	Else
		If GUV->(msSeek(xFilial("GUV") + AllTrim(cUniParam) + cUniFaixa ))
			nPesoFrete := (nPesoFrete/GUV->GUV_QTDPAR) * GUV->GUV_QTDDE
		EndIf
	EndIf
	
Return nPesoFrete
*/

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFGETTOKEN
Função para enviar buscar o token para integração WS
Baseado na função  OMGETTOKEN()   
@author Tamyris Ganzenmueller	
@since 10/04/2019
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFGETTOKEN()
	Local cUsr
	Local cPsw
	Local cUrlAuth := SuperGetMv("MV_CPLUAUT",.F.,"")
	Local cToken   := AllTrim(SuperGetMv("MV_TOKCPL",.F.,""))
	Local cDataHr  := SuperGetMv("MV_DTTOK",,"")
	Local dData
	Local cHora
	Local nTempoPar := SuperGetMv("MV_EXPTOK",, 1)
	Local nTempo
	Local nHoras
	Local nMinutos
	Local nSegundos
	Local aDataHora := StrTokArr(cDataHr,"-")

	If Empty(cUrlAuth)
		Return ""
	EndIf

	If !Empty(aDataHora) .And. Len(aDataHora) == 2

		If nTempoPar >= 24
			nTempo := (Mod(nTempoPar,24))
			dData := Date() - nTempo
		EndIf

		If dData == CTOD(aDataHora[1])

			cHora := TIME()
			nHoras    := Val(SubStr(cHora,1,2))
			nMinutos  := Val(SubStr(cHora,4,2))
			nSegundos := Val(SubStr(cHora,7,2))

			nTempo := nHoras*3600 + nMinutos*60 + nSegundos

			cHora := aDataHora[2]
			nHoras    := Val(SubStr(cHora,1,2))
			nMinutos  := Val(SubStr(cHora,4,2))
			nSegundos := Val(SubStr(cHora,7,2))

			If ABS( (nTempo - (nHoras*3600 + nMinutos*60 + nSegundos)) / 3600 ) >= nTempoPar
				cToken := "" //Expirou o token
			EndIf

		Else
			cToken := "" //Expirou o token
		EndIf
	Else
		aDataHora := {}
	EndIf

	If Empty(cToken) .Or. Empty(aDataHora)
		cUsr := StrTran(SuperGetMv("MV_USRCPL",.F.,"")," ","")
		cPsw := AllTrim(SuperGetMv("MV_PSWCPL",.F.,""))
	EndIf

	If !Empty(cUsr) .And. !Empty(cPsw)
		cToken := GFECPLGetToken(cUrlAuth,cUsr,cPsw)
		PutMv("MV_TOKCPL",cToken)
		PutMv("MV_DTTOK",DTOC(DATE()) + '-' + TIME())
	EndIf

Return cToken

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFECPLGetToken
Função para enviar buscar o token para integração WS
Baseado na função  OMCPLBuscaToken()   
@author Tamyris Ganzenmueller	
@since 10/04/2019
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFECPLGetToken(cUrlAuth,cUsr,cPsw)
	Local cToken
	Local cXMLPostRet
	Local cSoapSend
	Local XMLHeadRet
	Local aHeadOut
	aHeadOut  := {'Content-Type: text/xml;charset=utf-8','SOAPAction: ""','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
	XMLHeadRet:= ""

	cSoapSend := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:aut="http://www.neolog.com.br/cpl/gateway/authentication/">'
	cSoapSend += '<soapenv:Header/>'
	cSoapSend += '<soapenv:Body>'
	cSoapSend += '<aut:credentials>'
	cSoapSend += '<username>' + cUsr + '</username>'
	cSoapSend += '<password>' + cPsw + '</password>'
	cSoapSend += '</aut:credentials>'
	cSoapSend += '</soapenv:Body>'
	cSoapSend += '</soapenv:Envelope>'

	cXMLPostRet := HTTPSPost(AllTrim(cUrlAuth), "", "", "", "", cSoapSend, 30, aHeadOut, @XMLHeadRet)

	If Empty(cXMLPostRet)
		MsgAlert("Autenticação TOKEN inválida.")
		Return ""
	EndIf

	oXmlSoap := XmlParser ( cXMLPostRet, "", "", "")
	If Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS3_AUTHENTICATIONTOKEN") == "O"
		oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS3_AUTHENTICATIONTOKEN
	ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_AUTHENTICATIONTOKEN") == "O"
		oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS2_AUTHENTICATIONTOKEN
	ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_AUTHENTICATIONTOKEN") == "O"
		oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_AUTHENTICATIONTOKEN
	ElseIf Type("oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_AUTHENTICATIONTOKEN") == "O"
		oToken := oXmlSoap:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_AUTHENTICATIONTOKEN
	Else
		MsgAlert("Autenticação TOKEN inválida.")
		Return ""
	EndIf

	If Type("oToken:_SUCCESSFUL") == "O"
		If UPPER(oToken:_SUCCESSFUL:TEXT) == "TRUE"
			cToken := oToken:_TOKEN:TEXT
		Else
			MsgAlert("Usuário ou senha do token inválidos.")
			Return ""
		EndIf
	Else
		MsgAlert("Autenticação TOKEN inválida.")
		Return ""
	EndIf
Return cToken

/*/{Protheus.doc} GFEXGRVXML
	Realiza a gravação de um arquivo XML na pasta de LOG parametrizada na integração com a NEOLOG.
	O nome do arquivo sempre será precedido pela Data/Hora no formato AAAAMMDDHHMMSS
	A pasta principal é a configurada no INI na seção [NEOLOG] em DebugPath
	Baseada na função OMSXGRVXML
@author Tamyris Ganzenmueller
@since  10/04/2019
@param cTipo, characters, Sub pasta, que indica o processo do xml
@param cConteudo, characters, Conteúdo do xml a ser gravado
@param cNome, characters, Nome do arquivo. Geralmente referencia a tabela do processo no Protheus
@param cNome2, characters, Complemento do nome do arquivo. Geralmente referencia a PK da tabela do processo no Protheus
/*/
Function GFEXGRVXML(cTipo,cConteudo,cNome,cNome2)
	Local cPastaFinal := ""
	Local cArquivo    := ""
	Local cMessage    := ""
	Local cBarra      := Iif(IsSrvUnix(),"/","\")
	
	/*Retorna se a configuração do INI para Debug com a NEOLOG está ativa.
	Estando ativa os arquivos xml trocados com a neolog serão salvos na configuração indicada em: DebugPath
	Caso não exista a configuração no INI retornará true por padrão.*/
	If !(AllTrim(GetPvProfString("NEOLOG" , "Debug" , "1" , GetSrvIniName())) == "1")
		Return .T.
	EndIf

	cPastaFinal := OsCplDbgDir() + cBarra + cTipo
	If GFEXCRIFOL(cPastaFinal,cBarra)
		cArquivo := cPastaFinal + cBarra + DtoS(Date()) + StrTran(Time(),":") + "_" + StrTran(cNome," ") + Iif(!Empty(cNome2),"_"+StrTran(cNome2," "),"") + ".xml"
		If Empty(cArquivo) 
			cMessage := "Não foi possível gravar o arquivo pasta para gravação inválida." + CRLF   
			FWLogMsg("WARN", "", "BusinessObject", "GFEXWSCPL", "", "", cMessage, 0, 0)
		ElseIf Empty(cConteudo)
			cMessage := "Não foi possível gravar o arquivo o conteúdo retornado pelo CPL é invalido." + CRLF   
			FWLogMsg("WARN", "", "BusinessObject", "GFEXWSCPL", "", "", cMessage, 0, 0)
		Else
			MemoWrite(cArquivo, @cConteudo)
			If Ferror() != 0
				cMessage := "Não foi possível gravar o arquivo" + cArquivo + "." + CRLF + "Erro" + cValToChar(FError())   
				FWLogMsg("WARN", "", "BusinessObject", "GFEXWSCPL", "", "", cMessage, 0, 0)
			EndIf
		EndIf
	Else
		cMessage := "Não foi possível criar a pasta" + cPastaFinal + "." + CRLF + "Erro" + cValToChar(FError())  
		FWLogMsg("WARN", "", "BusinessObject", "GFEXWSCPL", "", "", cMessage, 0, 0)
	EndIf
Return

/*/{Protheus.doc} GFEXCRIFOL
	Realiza a criação de uma pasta. Necessita do caminho completo.
	Cria toda a hierarquia de pastas necessárias
@author siegklenes.beulke
@since 06/09/2016
@param cPasta, characters, Caminho completo da pasta a ser criada
@param cBarra, characters, Barra utilizada pelo sistema operacional
/*/
Function GFEXCRIFOL(cPasta,cBarra)
Local lAbsolute
Local cPastaT := ""
Local aPasta
Local nY
Local nRet := 0
Local lSrvUnix := IsSrvUnix()

Default cBarra := Iif(lSrvUnix,"/","\")

	lAbsolute := IIf(Substr(LTrim(cPasta),1,1) == cBarra, .F., .T.)

	If !ExistDir(cPasta)
		aPasta := StrTokArr2(cPasta,cBarra)

		For nY := 1 To Len(aPasta)
			If !Empty(aPasta[nY])
				If lSrvUnix .Or. !lAbsolute
					cPastaT += cBarra + aPasta[nY]
				Else
					cPastaT += aPasta[nY] + cBarra
				EndIf
				If !ExistDir(cPastaT)
					nRet := MakeDir(cPastaT)
					If nRet != 0
						Exit
					EndIf
				EndIF
			EndIf
		Next nY
	EndIf

Return nRet == 0

Function GfeFmtMsg(cMessage,aStrRepl)
Local nI      := 0
Local cRetMsg := cMessage

	For nI := 1 To Len(aStrRepl)
		If ValType(aStrRepl[nI]) == "A" .And. Len(aStrRepl[nI]) == 2
			cRetMsg := StrTran(cRetMsg,aStrRepl[nI][1],AllTrim(aStrRepl[nI][2]))
		EndIf
	Next

Return cRetMsg

/*/{Protheus.doc} GFEXGETFIL
	Retorna filial para uso em códigos de relacionamento.
@author siegklenes.beulke
@since 06/09/2016
@version undefined
@param cTabela, characters, Alias da tabela
@example
(examples)
@see (links_or_references)
/*/
Function GFEXGETFIL(cTabela,lHifen)
Local cRet := ""
Local cCplEmpDef := AllTrim(GetPvProfString("NEOLOG" , "DefaultCompany" , "" , GetSrvIniName()))
Local lHasEmpFil := ('E' $ FWSM0Layout()) // Se contem a empresa no layout
 
Default lHifen := .T.

	If cTabela == "SM0"
		If Empty(cCplEmpDef)
			cRet := FWGrpCompany() + '-' + cFilAnt
		Else
			cRet := cFilAnt
		EndIf
	Else
		If Empty(cCplEmpDef) .And. !lHasEmpFil
			cRet := FWGrpCompany() + xFilial(cTabela)
		Else
			cRet := xFilial(cTabela)
		EndIf
	EndIf
	If !Empty(cRet) .And. lHifen
		cRet := '-' + cRet
	EndIf
Return cRet
