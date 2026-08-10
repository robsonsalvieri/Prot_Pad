#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 
WSRESTFUL FREIGHTSIMULATION DESCRIPTION "Serviço especifico para execução da simulação de frete do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"
 
WSDATA tipoServico AS INTEGER
 
WSMETHOD GET  DESCRIPTION "Exemplo de arquivo JSON para utilizar com base na simulação de frete no módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"                                       WSSYNTAX "supply/gfe/v2/FreightSimulations || /GET/{id}"
WSMETHOD POST DESCRIPTION "Recebe os dados para realizar a simulação de frete e retorna todas as transportadoras e seus trechos quando encontrados e não possuir erros de cálculo"    WSSYNTAX "supply/gfe/v2/FreightSimulations || /POST/{id}"

END WSRESTFUL

WSMETHOD GET WSSERVICE FREIGHTSIMULATION
	Local oContent		:= Nil
	Local aRet

	private nAPIVersion := 1
	
	aRet := ValidContent('',.F.,::GETPATH())
	If !aRet[1]
		::SetResponse(FWJsonSerialize(aRet[2], .F., .F., .T.))
		Return .T.
	EndIf

	oContent := GetSimulation()

	::SetResponse(FWJsonSerialize(oContent, .F., .F., .T.))

Return .T.

WSMETHOD POST WSSERVICE FREIGHTSIMULATION
	Local oContent		:= Nil
	Local aRetCalc
	Local cContent		:= ""
	Local aRet			:= {}
	Local cReturn		:= ""
	Local dBaseDate		:= Date()
	Local lGFEXWS20 	:= ExistBlock("GFEXWS20")
	Local aCpPE := {}
	Local aDadosGW1 := {}

	private nAPIVersion := 1

	// define o tipo de retorno do método
	
	cContent :=  ::GetContent()
	
	aRet := ValidContent(cContent,.T.,::GETPATH())
	If !aRet[1]
		::SetResponse(FWJsonSerialize(aRet[2], .F., .F., .T.))
		Return .T.
	EndIf
	
	FWJsonDeserialize(cContent,@oContent)
	
	aRet := ReadContent(oContent)

	aDadosGW1 := aRet[4]

	// Ponto de entrada da Usina Colombo que permite a manipulação da variável publica deValPedagio
	If  lGFEXWS20
		aCpPE := ExecBlock("GFEXWS20",.F.,.F.,{aDadosGW1})
		If ValType(aCpPE) == "A" .And. !Empty(aCpPE)
			aDadosGW1 := aCpPE
		EndIf
	EndIf	
	
	if aRet[1]
		If !Empty(aRet[3][1][10])
			dBaseDate := SToD(SubStr(aRet[3][1][10],1,4)+SubStr(aRet[3][1][10],6,2)+SubStr(aRet[3][1][10],9,2))
		EndIf

		aRetCalc := GFECLCFRT(aRet[3],aRet[4],aRet[5],aRet[6],,.F., 0,,.F.,/*iTpSimul*/,/*lCalcLote*/, /*lHideProgress*/, IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.), /*lServ*/, , .T., , , dBaseDate)
		if aRetCalc[1]
			cReturn := FWJsonSerialize(WriteResumid(aRetCalc), .F., .F., .T.)
		else
			cReturn	:= '{"content": [{"Items": [{"Status" : "error","Message":' + FWJsonSerialize(aRetCalc[2], .F., .F., .T.) + ',"Error":"O cálculo de frete não pode ser realizado, demais informações podem ser visualizadas no arquivo de LOG de cálculo quando parametrizado para gerar"}]}]}'
		EndIf
	Else
		cReturn	:= '{"content": [{"Items": [{"Status" : "error","Message":"' + aRet[2] + '","Error":"O cálculo de frete não pode ser realizado, demais informações podem ser visualizadas no arquivo de LOG de cálculo quando parametrizado para gerar"}]}]}'
	EndIf
	
	//::SetResponse(EncodeUTF8(cReturn))
	::SetResponse(cReturn)
Return .T.

Static Function GetSimulation()
	Local oManifest
	Local nItems := 0
	Local nValues := 0
	Local oResponse   := JsonObject():New()

	/* DEFINIÇÃO DOS TAMANHOS DOS CAMPOS*/
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1] 
	Local nGWN_CDTRP  := TamSX3("GWN_CDTRP")[1] 
	Local nGWN_CDTPVC := TamSX3("GWN_CDTPVC")[1]
	Local nGWN_CDCLFR := TamSX3("GWN_CDCLFR")[1]
	Local nGWN_CDTPOP := TamSX3("GWN_CDTPOP")[1]
	
	Local nGW1_NRROM  := nGWN_NRROM
	Local nGW1_EMISDC := TamSX3("GW1_EMISDC")[1]
	Local nGW1_SERDC  := TamSX3("GW1_SERDC")[1]
	Local nGW1_NRDC   := TamSX3("GW1_NRDC")[1]
	Local nGW1_CDTPDC := TamSX3("GW1_CDTPDC")[1]
	Local nGW1_CDREM  := nGW1_EMISDC
	Local nGW1_CDDEST := nGW1_EMISDC
	Local nGW1_ENTEND := TamSX3("GW1_ENTEND")[1]
	Local nGW1_ENTBAI := TamSX3("GW1_ENTBAI")[1]
	Local nGW1_ENTNRC := TamSX3("GW1_ENTNRC")[1]
	Local nGW1_ENTCEP := TamSX3("GW1_ENTCEP")[1]
	Local nGW1_QTUNI  := 13.5
	Local nGU3_CDERP  := TamSX3("GU3_CDERP")[1]
	Local nGU3_CDCERP := TamSX3("GU3_CDCERP")[1]
	Local nSpecValue  := 9.3
	
	Local nGWU_EMISDC := nGW1_EMISDC
	Local nGWU_SERDC  := nGW1_SERDC
	Local nGWU_NRDC   := nGW1_NRDC
	Local nGWU_CDTPDC := nGW1_CDTPDC
	Local nGWU_SEQ    := TamSX3("GWU_SEQ")[1]
	Local nGWU_CDTRP  := nGWN_CDTRP
	Local nGWU_NRCIDD := TamSX3("GWU_NRCIDD")[1]
	Local nGWU_CDTPVC := nGWN_CDTPVC
	Local nGWU_NRCIDO := nGWU_NRCIDD
	Local nGWU_CEPO   := TamSX3("GWU_CEPO")[1]
	Local nGWU_CEPD   := nGWU_CEPO
	Local nGWU_CDCLFR := nGWN_CDCLFR
	Local nGWU_CDTPOP := nGWN_CDTPOP
	
	Local nGW8_EMISDC := nGW1_EMISDC
	Local nGW8_SERDC  := nGW1_SERDC
	Local nGW8_NRDC   := nGW1_NRDC
	Local nGW8_CDTPDC := nGW1_CDTPDC
	Local nGW8_ITEM   := TamSX3("GW8_ITEM")[1]
	Local nGW8_CDCLFR := nGWN_CDCLFR
	Local nGW8_TPITEM := TamSX3("GW8_TPITEM")[1]
	Local nGW8_QTDE   := Val(cValToChar(TamSX3("GW8_QTDE")[1])   + "." + cValToChar(TamSX3("GW8_QTDE")[2]))
	Local nGW8_PESOR  := Val(cValToChar(TamSX3("GW8_PESOR")[1])  + "." + cValToChar(TamSX3("GW8_PESOR")[2]))
	Local nGW8_PESOC  := Val(cValToChar(TamSX3("GW8_PESOC")[1])  + "." + cValToChar(TamSX3("GW8_PESOC")[2]))
	Local nGW8_QTDALT := Val(cValToChar(TamSX3("GW8_QTDALT")[1]) + "." + cValToChar(TamSX3("GW8_QTDALT")[2]))
	Local nGW8_VALOR  := Val(cValToChar(TamSX3("GW8_VALOR")[1])  + "." + cValToChar(TamSX3("GW8_VALOR")[2]))
	Local nGW8_VOLUME := Val(cValToChar(TamSX3("GW8_VOLUME")[1]) + "." + cValToChar(TamSX3("GW8_VOLUME")[2]))

	Local aManifest := { 		{{"id","ManifestNumber"},        {"value","01      "},        {"Type","string"},    {"Length",nGWN_NRROM }, {"Description","Código agrupador/Romaneio"}},;
								{{"id","CarrierCode"},           {"value","              "},  {"Type","string"},    {"Length",nGWN_CDTRP }, {"Description","Transportador a ser considerado no cálculo quando não informado no trecho/rota."}},;
								{{"id","TypeOfVehicle"},         {"value","          "},      {"Type","string"},    {"Length",nGWN_CDTPVC}, {"Description","Tipo de Veículo"}},;
								{{"id","FreightClassification"}, {"value","    "},            {"Type","string"},    {"Length",nGWN_CDCLFR}, {"Description","Classificação de frete"}},;
								{{"id","OperationType"},         {"value","          "},      {"Type","string"},    {"Length",nGWN_CDTPOP}, {"Description","Tipo de Operação"}},;
								{{"id","BaseDate"},              {"value",GFEDToJson(Date())}, {"Type","string"},    {"Length",20}, 		{"Description","Data Base para o cálculo"}}}

	Local aDocCarg := {			{{"id","ManifestNumber"},        {"value","01      "},        {"Type","string"},    {"Length",nGW1_NRROM }, {"Description","Código agrupador/Romaneio"}},;
								{{"id","IssuerCode"},            {"value","              "},  {"Type","string"},    {"Length",nGW1_EMISDC}, {"Description","Emitente do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceSerie"},          {"value","   "},             {"Type","string"},    {"Length",nGW1_SERDC }, {"Description","Série do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceNumber"},         {"value","00001           "},{"Type","string"},    {"Length",nGW1_NRDC  }, {"Description","Número do Documento de Carga/Nota Fiscal"}},;
								{{"id","TypeOfDocument"},        {"value",""},                {"Type","string"},    {"Length",nGW1_CDTPDC}, {"Description","Tipo do Documento de Carga/Nota Fiscal"}},;
								{{"id","SenderCode"},            {"value","000000001     "},  {"Type","string"},    {"Length",nGW1_CDREM }, {"Description","Remetente do Documento de Carga/Nota Fiscal"}},;
								{{"id","SenderERPCode"},         {"value","12345601"},  		  {"Type","string"},    {"Length",nGU3_CDERP+nGU3_CDCERP }, {"Description","Código do ERP do Remetente do Documento de Carga/Nota Fiscal"}},;
								{{"id","CostumerCode"},          {"value","000000003     "},  {"Type","string"},    {"Length",nGW1_CDDEST}, {"Description","Destinatário do Documento de Carga/Nota Fiscal"}},;
								{{"id","CostumerERPCode"},       {"value","12345702"},  		  {"Type","string"},    {"Length",nGU3_CDERP+nGU3_CDCERP} , {"Description","Código do ERP do Destinatário do Documento de Carga/Nota Fiscal"}},;
								{{"id","DeliveryAddress"},       {"value",""},                {"Type","string"},    {"Length",nGW1_ENTEND}, {"Description","Endereço de Entrega do Documento de Carga/Nota Fiscal"}},;
								{{"id","DeliveryDistrict"},      {"value",""},                {"Type","string"},    {"Length",nGW1_ENTBAI}, {"Description","Bairro de Entrega do Documento de Carga/Nota Fiscal"}},;
								{{"id","CityCodeDelivery"},      {"value","       "},         {"Type","string"},    {"Length",nGW1_ENTNRC}, {"Description","Cidade de Entrega do Documento de Carga/Nota Fiscal"}},;
								{{"id","ZipCodeDelivery"},       {"value","        "},        {"Type","string"},    {"Length",nGW1_ENTCEP}, {"Description","CEP de Entrega do Documento de Carga/Nota Fiscal"}},;
								{{"id","Unitizador"},            {"value",1},                 {"Type","double"},    {"Length",nGW1_QTUNI }, {"Description","Quantidade de Unitizadores"}},;
								{{"id","SpecificValue"},         {"value",100},               {"Type","double"},    {"Length",nSpecValue }, {"Description","Valor específico"}}}

	Local aRoute := {			{{"id","IssuerCode"},            {"value","              "},  {"Type","string"},    {"Length",nGWU_EMISDC}, {"Description","Emitente do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceSerie"},          {"value","   "},             {"Type","string"},    {"Length",nGWU_SERDC }, {"Description","Série do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceNumber"},         {"value","00001           "},{"Type","string"},    {"Length",nGWU_NRDC  }, {"Description","Número do Documento de Carga/Nota Fiscal"}},;
								{{"id","TypeOfDocument"},        {"value","     "},           {"Type","string"},    {"Length",nGWU_CDTPDC}, {"Description","Tipo de Documento de Carga/Nota Fiscal"}},;
								{{"id","Sequence"},              {"value","01"},              {"Type","string"},    {"Length",nGWU_SEQ   }, {"Description","Sequência do Trecho. Serial unico"}},;
								{{"id","CarrierCode"},           {"value","              "},  {"Type","string"},    {"Length",nGWU_CDTRP }, {"Description","Transportador do trecho/rota. Ao utilizar o transportador em branco, será realizada simulação para todos os trechos encontrados. Se informar o transportador, somente este será considerado."}},;
								{{"id","CityCodeDelivery"},      {"value","       "},         {"Type","string"},    {"Length",nGWU_NRCIDD}, {"Description","Cidade de Destino"}},;
								{{"id","TypeOfVehicle"},         {"value","          "},      {"Type","string"},    {"Length",nGWU_CDTPVC}, {"Description","Tipo de veículo do trecho"}},;
								{{"id","CityCodeOrigin"},        {"value","       "},         {"Type","string"},    {"Length",nGWU_NRCIDO}, {"Description","Número Cidade Origem"}},;
								{{"id","ZipCodeOrigin"},         {"value","        "},        {"Type","string"},    {"Length",nGWU_CEPO  }, {"Description","CEP de Origem"}},;
								{{"id","ZipCodeDelivery"},       {"value","        "},        {"Type","string"},    {"Length",nGWU_CEPD  }, {"Description","CEP de Destino"}},;
								{{"id","FreightClassification"}, {"value","    "},            {"Type","string"},    {"Length",nGWU_CDCLFR}, {"Description","Classifição de Frete"}},;
								{{"id","OperationType"},         {"value","          "},      {"Type","string"},    {"Length",nGWU_CDTPOP}, {"Description","Tipo de Operação"}}}
								
	Local aItDCv1 := {	{{"id","IssuerCode"},            {"value","              "},  {"Type","string"},    {"Length",nGW8_EMISDC}, {"Description","Emitente do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceSerie"},          {"value","   "},             {"Type","string"},    {"Length",nGW8_SERDC }, {"Description","Série do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceNumber"},         {"value","00001           "},{"Type","string"},    {"Length",nGW8_NRDC  }, {"Description","Número do Documento de Carga/Nota Fiscal"}},;
								{{"id","TypeOfDocument"},        {"value","     "},           {"Type","string"},    {"Length",nGW8_CDTPDC}, {"Description","Tipo do Documento de Carga/Nota Fiscal"}},;
								{{"id","ItemCode"},              {"value","ItemA          "}, {"Type","string"},    {"Length",nGW8_ITEM  }, {"Description","Código do Item do Documento de Carga/Nota Fiscal"}},;
								{{"id","FreightClassification"}, {"value","    "},            {"Type","string"},    {"Length",nGW8_CDCLFR}, {"Description","Classificação de Frete do Item Documento de Carga/Nota Fiscal"}},;
								{{"id","ItemType"},              {"value","    "},            {"Type","string"},    {"Length",nGW8_TPITEM}, {"Description","Tipo do Item do Documento de Carga/Nota Fiscal"}},;
								{{"id","Quantity"},              {"value",0},                 {"Type","double"},    {"Length",nGW8_QTDE  }, {"Description","Quantidade do Item"}},;
								{{"id","Weight"},                {"value",100},               {"Type","double"},    {"Length",nGW8_PESOR }, {"Description","Peso do Item"}},;
								{{"id","NetWeight"},             {"value",0},                 {"Type","double"},    {"Length",nGW8_PESOC }, {"Description","Peso Cubado"}},;
								{{"id","AlternativeQuantity"},   {"value",0},                 {"Type","double"},    {"Length",nGW8_QTDALT}, {"Description","Quantidade/Peso Alternativa"}},;
								{{"id","NetPrice"},              {"value",100},               {"Type","double"},    {"Length",nGW8_VALOR }, {"Description","Valor do Item"}},;
								{{"id","CubicVolume"},           {"value",0},                 {"Type","double"},    {"Length",nGW8_VOLUME}, {"Description","Volume Ocupado (m3)"}}}

	Local aItDCv2 := {	{{"id","IssuerCode"},            {"value","              "},  {"Type","string"},    {"Length",nGW8_EMISDC}, {"Description","Emitente do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceSerie"},          {"value","   "},             {"Type","string"},    {"Length",nGW8_SERDC }, {"Description","Série do Documento de Carga/Nota Fiscal"}},;
								{{"id","InvoiceNumber"},         {"value","00001           "},{"Type","string"},    {"Length",nGW8_NRDC  }, {"Description","Número do Documento de Carga/Nota Fiscal"}},;
								{{"id","TypeOfDocument"},        {"value","     "},           {"Type","string"},    {"Length",nGW8_CDTPDC}, {"Description","Tipo do Documento de Carga/Nota Fiscal"}},;
								{{"id","ItemCode"},              {"value","ItemA          "}, {"Type","string"},    {"Length",nGW8_ITEM  }, {"Description","Código do Item do Documento de Carga/Nota Fiscal"}},;
								{{"id","FreightClassification"}, {"value","    "},            {"Type","string"},    {"Length",nGW8_CDCLFR}, {"Description","Classificação de Frete do Item Documento de Carga/Nota Fiscal"}},;
								{{"id","ItemType"},              {"value","    "},            {"Type","string"},    {"Length",nGW8_TPITEM}, {"Description","Tipo do Item do Documento de Carga/Nota Fiscal"}},;
								{{"id","Quantity"},              {"value",0},                 {"Type","double"},    {"Length",nGW8_QTDE  }, {"Description","Quantidade do Item"}},;
								{{"id","Weight"},                {"value",100},               {"Type","double"},    {"Length",nGW8_PESOR }, {"Description","Peso do Item"}},;
								{{"id","NetWeight"},             {"value",0},                 {"Type","double"},    {"Length",nGW8_PESOC }, {"Description","Peso Cubado"}},;
								{{"id","AlternativeQuantity"},   {"value",0},                 {"Type","double"},    {"Length",nGW8_QTDALT}, {"Description","Quantidade/Peso Alternativa"}},;
								{{"id","NetPrice"},              {"value",100},               {"Type","double"},    {"Length",nGW8_VALOR }, {"Description","Valor do Liquido do Item"}},;
								{{"id","GrossPrice"},            {"value",100},               {"Type","double"},    {"Length",nGW8_VALOR }, {"Description","Valor do Bruto do Item"}},;
								{{"id","CubicVolume"},           {"value",0},                 {"Type","double"},    {"Length",nGW8_VOLUME}, {"Description","Volume Ocupado (m3)"}}}

	Local aItDC

	if nAPIVersion == 1
		aItDC := aItDCv1
	Else
		aItDC := aItDCv2
	EndIf

	//////////// --- AGRUPADOR ROMANEIO --- ////////////

	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["id"] := "1" 
	
	oResponse["content"][1]["Items"][1]["Manifest"] := {}
	for nItems:= 1 to Len(aManifest)
		
		Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
		
		for nValues:= 1 to Len(aManifest[nItems])
			aTail(oResponse["content"][1]["Items"][1]["Manifest"])[aManifest[nItems][nValues][1]] := aManifest[nItems][nValues][2]
		next
	next

	oManifest	:= oResponse["content"][1]["Items"][1]["Manifest"]
	
	//////////// --- DOCUMENTOS DE CARGA --- ////////////

	oResponse["content"][1]["Items"][1]["DocumentBurden"] := {}
	Aadd(oResponse["content"][1]["Items"][1]["DocumentBurden"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["id"] := "1" 
	oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"] := {}
	for nItems:= 1 to Len(aDocCarg)
		
		Aadd(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"], JsonObject():New())
		
		for nValues:= 1 to Len(aDocCarg[nItems])
			aTail(oResponse["content"][1]["Items"][1]["DocumentBurden"][1]["Items"])[aDocCarg[nItems][nValues][1]] := aDocCarg[nItems][nValues][2]
		next
	next
	
	//////////// --- ROTAS DOCUMENTO DE CARGA--- ////////////

	oResponse["content"][1]["Items"][1]["Route"] := {}
	Aadd(oResponse["content"][1]["Items"][1]["Route"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Route"][1]["id"] := "1" 

	oResponse["content"][1]["Items"][1]["Route"][1]["Items"] := {}

	for nItems:= 1 to Len(aRoute)
		
		Aadd(oResponse["content"][1]["Items"][1]["Route"][1]["Items"], JsonObject():New())
		
		for nValues:= 1 to Len(aRoute[nItems])
			aTail(oResponse["content"][1]["Items"][1]["Route"][1]["Items"])[aRoute[nItems][nValues][1]] := aRoute[nItems][nValues][2]
		next
	next
	
	//////////// --- ITENS DOCUMENTO DE CARGA --- ////////////

	oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"] := {}
	Aadd(oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"][1]["id"] := "1" 
	oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"][1]["Items"] := {}

	for nItems:= 1 to Len(aItDC)
		
		Aadd(oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"][1]["Items"], JsonObject():New())
		
		for nValues:= 1 to Len(aItDC[nItems])
			aTail(oResponse["content"][1]["Items"][1]["ItemsDocumentBurden"][1]["Items"])[aItDC[nItems][nValues][1]] := aItDC[nItems][nValues][2]
		next
	next
	
Return oResponse


/*/{Protheus.doc} WriteResumid
//TODO Monta o Json da simulação resumida.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return oResponse, ${Objeto Json da simulação simplificada}
@param aRetFrete, array, Array com a simulação de frete calculada
@type function
/*/
Static Function WriteResumid(aRetFrete)
	Local aTRBTCF		:= aRetFrete[6]
	Local aTRBCCF		:= aRetFrete[10]
	Local aTRBUNC		:= aRetFrete[8]
	Local aTRBTRE		:= aRetFrete[9]
	Local nCont			:= 0
	Local oResponse		:= JsonObject():New()
	Local cCarCnpj		:= ""
	Local cCarName		:= ""
	Local cCarERPCode 	:= ""
	Local cTpLot		:= ""

	Local nContComp := 0
	Local nTamComp	:= 0
	Local nContUnc	:= 0
	Local nTamUnc	:= 0
	Local nAux		:= 0
	Local cCatComp	:= ""
	
	/* DEFINIÇÃO DOS TAMANHOS DOS CAMPOS*/
	Local nCDTRP		:= TamSX3("GWN_CDTRP")[1]
	Local nCNPJTRP		:= TamSX3("GU3_IDFED")[1]
	Local nNMTRP		:= TamSX3("GU3_NMEMIT")[1]
	Local nNRTAB		:= TamSX3("GV1_NRTAB")[1]
	Local nNRROTA		:= TamSX3("GV1_NRROTA")[1]
	Local nDSROTA		:= 150
	Local nTPLOT		:= 16
	Local nVLFRETE		:= Val(cValToChar(TamSX3("GW8_VALOR")[1])  + "." + cValToChar(TamSX3("GW8_VALOR")[2]))
	Local nVLIMP		:= Val(cValToChar(TamSX3("GW8_VALOR")[1])  + "." + cValToChar(TamSX3("GW8_VALOR")[2]))
	Local nTPVEIC		:= TamSX3("GV7_CDTPVC")[1]
	Local nCDCLFR		:= TamSX3("GV9_CDCLFR")[1]
	Local nCDTPOP		:= TamSX3("GV9_CDTPOP")[1]
	Local nNRNEG		:= TamSX3("GV9_NRNEG")[1]
	Local nCDFAIXA		:= TamSX3("GV7_CDFXTV")[1]
	
	Local nCDCOMP		:= TamSX3("GWI_CDCOMP")[1]
	Local nVLCOMP		:= Val(cValToChar(TamSX3("GWI_VLFRET")[1])  + "." + cValToChar(TamSX3("GWI_VLFRET")[2]))
	Local nCATCOMP		:= 20

	Local aCalc			:= {}
	Local aComp			:= {}

	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())
	
	oResponse["content"][1]["Items"][1]["Status"]	:= "ok" 
	oResponse["content"][1]["Items"][1]["Message"]	:= "FreightSimulations: Simulação realizada com sucesso."

	oResponse["content"][1]["Items"][1]["FreightCalculation"] := {}

	For nCont := 1 To Len(aTRBTCF)
		nPos := aScan(aCalc,{|x|x[1] == aTRBTCF[nCont][1]})

		If nPos == 0
			Aadd(aCalc, aTRBTCF[nCont])
		EndIf		
	Next nCont

	For nCont := 1 To Len(aTRBCCF)
		nPos := aScan(aComp,{|x|x[1] == aTRBCCF[nCont][1] .And.;
		 					    x[2] == aTRBCCF[nCont][2] .And.;
								x[3] == aTRBCCF[nCont][3] .And.;
								x[5] == aTRBCCF[nCont][5]})

		If nPos == 0
			Aadd(aComp, aTRBCCF[nCont])
		EndIf
	Next nCont

	For nCont:= 1 To Len(aCalc)
		cCarCnpj	:= ""
		cCarName	:= ""
		cCarERPCode	:= ""
		cTpLot		:= ""

		GU3->(dbSetOrder(1))
		If GU3->(dbSeek(xFilial("GU3") + aCalc[nCont][7]))
			cCarCnpj	:= GU3->GU3_IDFED
			cCarName	:= GU3->GU3_NMEMIT
			cCarERPCode := GU3->GU3_CDTERP + GU3->GU3_CDCERP
		Endif
		
		GV9->(dbSetOrder(1))
		If GV9->(dbSeek(xFilial("GV9") + aCalc[nCont][7] + aCalc[nCont][8] + aCalc[nCont][9]))
			cTpLot	:=  GetStrCbox(GetSx3Inf("GV9_TPLOTA")[2],GV9->GV9_TPLOTA)
		Endif

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"] := {}
		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["SimulationNumber"] := aCalc[nCont][1]
		
		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "CarrierCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCDTRP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código do Transportador da rota calculada"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"] := noAcento(aCalc[nCont][7])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "CarrierCnpj"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCNPJTRP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "CNPJ do Transportador da rota calculada"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"] := noAcento(cCarCnpj)
				
		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "CarrierName"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nNMTRP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Nome do Transportador da rota calculada"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(cCarName)

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "CarrierERPCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCDTRP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código do ERP da Transportadora da rota calculada"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(cCarERPCode)

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "RouteCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nNRROTA
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código da rota utilizada para o cálculo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][12])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "RouteName"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nDSROTA
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Descrição da rota utilizada para o cálculo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(GFEAINFROT(aCalc[nCont][7],aCalc[nCont][8],aCalc[nCont][9],aCalc[nCont][12]))

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "TypeCapacity"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nTPLOT
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Tipo Lotação da Tabela de Frete. (1=Carga Fracionada 2=Carga Fechada 3=Veículo Dedicado)"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]:= noAcento(cTpLot)

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "CostFreight"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nVLFRETE
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "double"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Valor total do Frete"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= GetCostFreight(aTRBCCF,aCalc[nCont][1]) 

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "Tax"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nVLIMP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "double"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Valor Imposto (ICMS ou ISS)"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]			:= GetTax(aTRBUNC,aCalc[nCont][1])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "DeliveryTime"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := "19"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Prazo de Entrega no formato YYYY-MM-DDThh:mm:ss"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]:= noAcento(GetPrazo(aTRBUNC,aCalc[nCont][1]))

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "TableCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nNRTAB
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código da tabela utilizada para o cálculo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][8])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "VehicleType"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nTPVEIC
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Tipo de Veículo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][11])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "OperationType"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCDTPOP
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Tipo de Operação"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][3])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "FreightClassification"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCDCLFR
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Classificação de Frete"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][2])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "TradingCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nNRNEG
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código da Negociação"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][9])

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] := "TrackCode"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["length"] := nCDFAIXA
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["type"] := "string"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Código da Faixa"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"]	:= noAcento(aCalc[nCont][10])

		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"] := {}

		nTamComp := Len(aTRBCCF)

		nAux := 0

		For nContComp := 1 To nTamComp
			If aTRBCCF[nContComp][1] == aCalc[nCont][1]
				nAux++

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"], JsonObject():New())
				oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"] := {}
				
				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["id"] := "ComponentCode"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["length"] := nCDCOMP
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["Description"] := "Código do componente"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["value"] := noAcento(aTRBCCF[nContComp][5])

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["id"] := "ComponentValue"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["length"] := nVLCOMP
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["type"] := "double"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["Description"] := "Valor do componente"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["value"] := aTRBCCF[nContComp][8]

				cCatComp := GetStrCbox(GetSx3Inf("GV2_CATVAL")[2],aTRBCCF[nContComp][6])

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["id"] := "ComponentCategory"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["length"] := nCATCOMP
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["Description"] := "Categoria do componente"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightComponents"][nAux]["Items"])["value"] := noAcento(cCatComp)
			EndIf
		Next nContComp

		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"] := {}

		nTamUnc 	:= Len(aTRBUNC)
		nAux 		:= 0
		
		For nContUnc := 1 To nTamUnc
			If aTRBUNC[nContUnc][1] == aCalc[nCont][1]
				nContStr := 0
				
				nAux++

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"], JsonObject():New())
				oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"] := {}

				nContStr += TamSX3("GWU_FILIAL")[1] + 1

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["id"] := "TypeofDocument"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["length"] := 5
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["Description"] := "Tipo do Documento"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["value"] := SubStr(aTRBUNC[nContUnc][24],nContStr,TamSX3("GWU_CDTPDC")[1])

				nContStr += TamSX3("GWU_CDTPDC")[1]

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["id"] := "DocumentEmiss"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["length"] := 10
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["Description"] := "Emissor do Documento"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["value"] := SubStr(aTRBUNC[nContUnc][24],nContStr,TamSX3("GWU_EMISDC")[1])

				nContStr += TamSX3("GWU_EMISDC")[1]

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["id"] := "DocumentGrade"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["length"] := 5
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["Description"] := "Serie do Documento"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["value"] := SubStr(aTRBUNC[nContUnc][24],nContStr,TamSX3("GWU_SERDC")[1])

				nContStr += TamSX3("GWU_SERDC")[1]

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["id"] := "DocumentInvoice"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["length"] := 12
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["Description"] := "Numero do Documento"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["value"] := SubStr(aTRBUNC[nContUnc][24],nContStr,TamSX3("GWU_NRDC")[1])

				Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"], JsonObject():New())
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["id"] := "DocumentSequence"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["length"] := 2
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["type"] := "string"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["Description"] := "Sequencia do Documento"
				aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["FreightDocuments"][nAux]["Items"])["value"] := aTRBUNC[nContUnc][21]
			EndIf
		Next nContTre
	Next
Return oResponse

/*/{Protheus.doc} ReadContent
//TODO Realiza a leitura do conteudo enviado no método POST.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return ${return}, ${return_description}
@param oContent, object, descrição
@type function
/*/
Static Function ReadContent(oContent)
	Local aManifest
	Local aDocumentBurden
	Local aRoute
	Local aItemsDocumentBurden
	
	Local nContent			:= 0
	Local nContItens		:= 0

	Local aAgrFrt		:= {} // Agrupadores de frete
	Local aDocCarg		:= {} // Documento de carga
	Local aItDoc		:= {} // Itens do Documento
	Local aTrchDoc		:= {} // Trechos
	
	Local aAux			:= {}
	Local lRet			:= .T.
	Local cMsgErro		:= ""
	Local cAuxMN
	Local cAuxMNDoc
	Local cIssuerCode		:= ""
	Local cSenderCode		:= ""
	Local cCostumerCode		:= ""
	Local cInvoiceNumber	:= ""
	Local cTypeOfDocument	:= ""
	Local cCityCodeDelivery	:= ""
	Local c1CarrierCode		:= ""
	Local c2CarrierCode		:= ""
	Local cTypeOfVehicle    := ""
	Local cFreightClassific := ""
	Local cOperationType    := ""
	Local cSenderERPCode	:= ""
	Local cCostumerERPCode	:= ""
	/* DEFINIÇÃO DE TAMANHO DE CAMPOS*/
	
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1] 
	Local nGWN_CDTRP  := TamSX3("GWN_CDTRP")[1] 
	Local nGWN_CDTPVC := TamSX3("GWN_CDTPVC")[1]
	Local nGWN_CDCLFR := TamSX3("GWN_CDCLFR")[1]
	Local nGWN_CDTPOP := TamSX3("GWN_CDTPOP")[1]
	
	Local nGW1_NRROM  := nGWN_NRROM
	Local nGW1_EMISDC := TamSX3("GW1_EMISDC")[1]
	Local nGW1_SERDC  := TamSX3("GW1_SERDC")[1]
	Local nGW1_NRDC   := TamSX3("GW1_NRDC")[1]
	Local nGW1_CDTPDC := TamSX3("GW1_CDTPDC")[1]
	Local nGW1_ENTEND := TamSX3("GW1_ENTEND")[1]
	Local nGW1_ENTBAI := TamSX3("GW1_ENTBAI")[1]
	Local nGW1_ENTNRC := TamSX3("GW1_ENTNRC")[1]
	Local nGW1_ENTCEP := TamSX3("GW1_ENTCEP")[1]
	Local nGU3_CDERP  := TamSX3("GU3_CDERP")[1]
	Local nGU3_CDCERP := TamSX3("GU3_CDCERP")[1]
	
	Local nGWU_EMISDC := nGW1_EMISDC
	Local nGWU_SERDC  := nGW1_SERDC
	Local nGWU_NRDC   := nGW1_NRDC
	Local nGWU_SEQ    := TamSX3("GWU_SEQ")[1]
	Local nGWU_CDTRP  := nGWN_CDTRP
	Local nGWU_NRCIDD := TamSX3("GWU_NRCIDD")[1]
	Local nGWU_CDTPVC := nGWN_CDTPVC
	Local nGWU_NRCIDO := nGWU_NRCIDD
	Local nGWU_CEPO   := TamSX3("GWU_CEPO")[1]
	Local nGWU_CEPD   := nGWU_CEPO
	Local nGWU_CDCLFR := nGWN_CDCLFR
	Local nGWU_CDTPOP := nGWN_CDTPOP
	
	Local nGW8_EMISDC := nGW1_EMISDC
	Local nGW8_SERDC  := nGW1_SERDC
	Local nGW8_NRDC   := nGW1_NRDC
	Local nGW8_ITEM   := TamSX3("GW8_ITEM")[1]
	Local nGW8_CDCLFR := nGWN_CDCLFR
	Local nGW8_TPITEM := TamSX3("GW8_TPITEM")[1]
	Local nGWN_NRCIDD := TamSX3("GWN_NRCIDD")[1] //Cidade Destino
	Local nGWN_CEPD   := TamSX3("GWN_CEPD")[1]   //CEP Destino

	Local cAliasGUK	  := ""
	Local cCdClFrItem := ""
	Local cMV_CDCLFR  := SuperGetMV("MV_CDCLFR",.F.,"")
	Local lExiItemExc := .F.
	Local cGU3_CDERP  := ""
	Local cGU3_CDCERP := ""	
	
	For nContent:= 1 to Len(oContent["content"][1]["Items"])
		aManifest 			:= oContent["content"][1]["Items"][nContent]["Manifest"]
		aDocumentBurden 	:= oContent["content"][1]["Items"][nContent]["DocumentBurden"]
		aRoute 				:= oContent["content"][1]["Items"][nContent]["Route"]
		aItemsDocumentBurden:= oContent["content"][1]["Items"][nContent]["ItemsDocumentBurden"]
		
		aAux := {}
		
		cAuxMN := GFEGETVALUE(aManifest,"ManifestNumber",nGWN_NRROM)
		If Empty(cAuxMN)
			cAuxMN := PadR("01", nGWN_NRROM)
		EndIf

		c1CarrierCode := GFEGETVALUE(aManifest,"CarrierCode",nGWN_CDTRP)
		If !Empty(c1CarrierCode)
			GU3->(dbSetOrder(1))
			If !GU3->(dbSeek(xFilial("GU3") + c1CarrierCode))
				lRet := .F.
				cMsgErro := 'Campo CarrierCode. Código do Transportador ('+c1CarrierCode+') não encontrado na base de dados, verifique no cadastro de Emitentes se este código existe. '
				Loop
			Endif
		EndIf
		
		cTypeOfVehicle := GFEGETVALUE(aManifest,"TypeOfVehicle", nGWN_CDTPVC)
		If !Empty(cTypeOfVehicle)
			GV3->(dbSetOrder(1))
			If !GV3->(dbSeek(xFilial("GV3") + cTypeOfVehicle))
				lRet := .F.
				cMsgErro := 'Campo TypeOfVehicle. Tipo de Veículo ('+cTypeOfVehicle+') não encontrado na base de dados, verifique se este código existe no cadastro de Tipo de Veículo. '
				Loop
			Endif
		EndIf
		
		cFreightClassific := GFEGETVALUE(aManifest,"FreightClassification", nGWN_CDCLFR)
		If !Empty(cFreightClassific)
			GUB->(dbSetOrder(1))
			If !GUB->(dbSeek(xFilial("GUB") + cFreightClassific))
				lRet := .F.
				cMsgErro := 'Campo FreightClassification. Classificação de Frete ('+cFreightClassific+') não encontrado na base de dados, verifique se este código existe no cadastro de Classificação de Frete. '
				Loop
			Endif
		EndIf

		If Empty(cFreightClassific)
			cFreightClassific := cMV_CDCLFR
		EndIf
		
		cOperationType := GFEGETVALUE(aManifest,"OperationType",nGWN_CDTPOP) 
		If !Empty(cOperationType)
			GV4->(dbSetOrder(1))
			If !GV4->(dbSeek(xFilial("GV4") + cOperationType))
				lRet := .F.
				cMsgErro := 'Campo OperationType. Tipo de Operação ('+cOperationType+') não encontrado na base de dados, verifique se este código existe no cadastro de Tipo de Operação. '
				Loop
			Endif
		EndIf

		AADD(aAux, cAuxMN                                                    )       // GWN_NRROM  - Número do Agrupador
		AADD(aAux, c1CarrierCode                                             )       // GWN_CDTRP  - Transportador (GU3)
		AADD(aAux, cTypeOfVehicle                                            )       // GWN_CDTPVC  - Tipo de Veículo (GV3)
		AADD(aAux, cFreightClassific                                         )       // GWN_CDCLFR  - Classificação de Frete (GUB)
		AADD(aAux, cOperationType                                            )       // GWN_CDTPOP  - Tipo de Operação (GV4)
		AADD(aAux, 0                                                         )       // Distancia Percorrida
		AADD(aAux, PadR("",nGWN_NRCIDD)                                      )       // Cidade Destino
		AADD(aAux, PadR("",nGWN_CEPD)                                        )       // CEP Destino
		AADD(aAux, "0"                                                       )       // Erro
		AADD(aAux, GFEGETVALUE(aManifest,"BaseDate",20)						 )       // Data Base
		
		AADD(aAgrFrt, aAux)
		
		For nContItens:= 1 to Len(aDocumentBurden)
			aAux   := {}
	
			cAuxMNDoc := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"ManifestNumber",nGW1_NRROM  )
			If Empty(cAuxMNDoc)
				cAuxMNDoc := cAuxMN
			EndIf
			
			cSenderCode := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"SenderCode", nGW1_EMISDC)
			
			If Empty(cSenderCode)
				cSenderERPCode := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"SenderERPCode", nGU3_CDERP + nGU3_CDCERP)
				cGU3_CDERP	   := SubStr(cSenderERPCode, 1, nGU3_CDERP)
				cGU3_CDCERP	   := SubStr(cSenderERPCode, nGU3_CDERP + 1, nGU3_CDCERP)
				
				If !Empty(cSenderERPCode)
					GU3->(dbSetOrder(12))
					If GU3->(dbSeek(xFilial("GU3") + cGU3_CDERP + cGU3_CDCERP))
						cSenderCode := GU3->GU3_CDEMIT
					EndIf
				EndIf
			EndIf
			
			If Empty(cSenderCode)
				lRet := .F.
				cMsgErro := 'Campo SenderCode obrigatório. Informe o Remetente a ser considerado no cálculo! '
				Loop
			Else
				GU3->(dbSetOrder(1))
				If !GU3->(dbSeek(xFilial("GU3") + cSenderCode))
					lRet := .F.
					cMsgErro := 'Campo SenderCode. Código do Remetente ('+cSenderCode+') não encontrado na base de dados, verifique o cadastro de Emitentes se este código existe. '
					Loop
				EndIf
			EndIf

			cIssuerCode := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"IssuerCode", nGW1_EMISDC)
			If Empty(cIssuerCode) // Caso não seja informado o emissor, será considerado o rementente.
				cIssuerCode := cSenderCode
			EndIf
			
			cCityCodeDelivery 	:= GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"CityCodeDelivery", nGW1_ENTNRC)
			cCostumerCode 		:= GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"CostumerCode", nGW1_EMISDC)
			
			If Empty(cCostumerCode)
				cCostumerERPCode := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"CostumerERPCode", nGU3_CDERP + nGU3_CDCERP)
				cGU3_CDERP	     := SubStr(cCostumerERPCode, 1, nGU3_CDERP)
				cGU3_CDCERP	     := SubStr(cCostumerERPCode, nGU3_CDERP + 1, nGU3_CDCERP)

				If !Empty(cCostumerERPCode)
					GU3->(dbSetOrder(12))
					If GU3->(dbSeek(xFilial("GU3") + cGU3_CDERP + cGU3_CDCERP))
						cCostumerCode := GU3->GU3_CDEMIT
					EndIf
				EndIf
			EndIf

			If Empty(cCostumerCode) .And. Empty(cCityCodeDelivery)
				lRet := .F.
				cMsgErro := 'Campo CostumerCode ou CityCodeDelivery devem ser preenchidos. Informe o Destinatario ou a Cidade de Destino a ser considerado no cálculo! '
				Loop
			Else
				If !Empty(cCostumerCode)
					GU3->(dbSetOrder(1))
					If !GU3->(dbSeek(xFilial("GU3") + cCostumerCode))
						lRet := .F.
						cMsgErro := 'Campo CostumerCode. Código do Destinatário ('+cCostumerCode+') não encontrado na base de dados, verifique o cadastro de Emitentes se este código existe. '
						Loop
					EndIf
				EndIf
			EndIf
			
			cInvoiceNumber := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"InvoiceNumber", nGW1_NRDC,"01")
			If Empty(cInvoiceNumber)
				cInvoiceNumber := PadR('01' + AllTrim(cValToChar(nContItens)),nGW1_NRDC)
				// Se tiver mais de um documento de carga por romaneio, é obrigatório separar cada documento com seu número
				if nContItens > 1
					lRet := .F.
					cMsgErro := 'Campo InvoiceNumber grupo DocumentBurden. Quando informado mais de um documento de carga por romaneio é obrigatório informar o campo InvoiceNumber para separar cada documento. '
					Loop
				EndIf				
			EndIf

			cTypeOfDocument := GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"TypeOfDocument", nGW1_CDTPDC)
			If Empty(cTypeOfDocument)
				GV5->(dbSetOrder(3))
				GV5->(dbSeek(xFilial("GV5")+"1"))   
				cTypeOfDocument := GV5->GV5_CDTPDC
			EndIf 

			AADD(aAux, cIssuerCode                                                                      ) // GW1_EMISDC - Emitente do Documento
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"InvoiceSerie",nGW1_SERDC      )) // GW1_SERDC - Serie do Documento
			AADD(aAux, cInvoiceNumber                                                                   ) // GW1_NRDC - Número do Documento
			AADD(aAux, cTypeOfDocument                                                                  ) // GW1_CDTPDC - Tipo do Documento
			AADD(aAux, cSenderCode                                                                      ) // GW1_CDREM - Remetente do Documento
			AADD(aAux, cCostumerCode                                                                    ) // GW1_CDDEST - Destinatario do Documento
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"DeliveryAddress", nGW1_ENTEND )) // GW1_ENTEND - endereço de Entrega
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"DeliveryDistrict", nGW1_ENTBAI)) // GW1_ENTBAI - Bairro de entrega
			AADD(aAux, cCityCodeDelivery) // GW1_ENTNRC - Cidade de Entrega
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"ZipCodeDelivery", nGW1_ENTCEP )) // GW1_ENTCEP - CEP de Entrega
			AADD(aAux, ''                                                                               ) //Região de destino
			AADD(aAux, '1'                                                                              ) // GW1_TPFRET - Tipo de Frete
			AADD(aAux, '2'                                                                              ) //ICMS?
			AADD(aAux, '1'                                                                              ) //Finalidade da mercadoria
			AADD(aAux, ''                                                                               ) //Número do carregamento
			AADD(aAux, cAuxMNDoc                                                                        ) // GW1_NRROM - Número do Agrupador
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"Unitizador",                  )) // GW1_QTUNI - Quantidade de Unitizadores
			AADD(aAux, GFEGETVALUE(aDocumentBurden[nContItens]["Items"],"SpecificValue",,0             )) // Valor Específico para ser utilizado durante o cálculo

			AADD(aDocCarg, aAux)
		Next
		if lRet == .F.
			Loop
		EndIf
		for nContItens:= 1 to Len(aRoute)
			aAux := {}
			
			cIssuerCode := GFEGETVALUE(aRoute[nContItens]["Items"],"IssuerCode", nGWU_EMISDC )
			if Empty(cIssuerCode) // Caso não seja informado o emissor, será considerado o rementente.
				cIssuerCode := cSenderCode
			EndIf
			cInvoiceNumber := GFEGETVALUE(aRoute[nContItens]["Items"],"InvoiceNumber", nGWU_NRDC,"01" )
			If Empty(cInvoiceNumber)
				cInvoiceNumber := PadR('01' + AllTrim(cValToChar(nContItens)),nGW1_NRDC)
				// Se tiver mais de um documento de carga por romaneio, é obrigatório separar cada documento com seu número
				if nContItens > 1
					lRet := .F.
					cMsgErro := 'Campo InvoiceNumber grupo Route. Quando informado mais de um documento de carga por romaneio é obrigatório informar o campo InvoiceNumber para separar cada documento. '
					Loop
				EndIf
			EndIF
			cCityCodeDelivery := GFEGETVALUE(aRoute[nContItens]["Items"],"CityCodeDelivery", nGWU_NRCIDD)
			if Empty(cCityCodeDelivery)
				cCityCodeDelivery := POSICIONE("GU3",1,xFilial("GU3")+cCostumerCode,"GU3_NRCID")
			EndIf

			c2CarrierCode := GFEGETVALUE(aRoute[nContItens]["Items"],"CarrierCode", nGWU_CDTRP)
			if !Empty(c2CarrierCode)
				GU3->(dbSetOrder(1))
				If !GU3->(dbSeek(xFilial("GU3") + c2CarrierCode))
					lRet := .F.
					cMsgErro := 'Campo CarrierCode. Código do Transportador ('+c2CarrierCode+') não encontrado na base de dados, verifique o cadastro de Emitentes se este código existe. '
					Loop
				Endif
			Else
				//Quando estiver em branco, assumir o transportador do manifesto, se informado
				c2CarrierCode := c1CarrierCode
			EndIf

			AADD(aAux, cIssuerCode                                                                  )       // GWU_EMISDC - Emitente do Documento
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"InvoiceSerie", nGWU_SERDC          ))       // GWU_SERDC - Serie do Documento
			AADD(aAux, cInvoiceNumber                                                               )       // GWU_NRDC - Número do Documento
			AADD(aAux, cTypeOfDocument                                                              )       // GWU_CDTPDC - Tipo do Documento
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"Sequence", nGWU_SEQ                ))       // GWU_SEQ - Sequencia do Trecho
			AADD(aAux, c2CarrierCode                                                                )       // GWU_CDTRP - Transportador do Trecho
			AADD(aAux, cCityCodeDelivery                                                            )       // GWU_NRCIDD - Cidade Destino
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"TypeOfVehicle", nGWU_CDTPVC        ))       // GWU_CDTPVC - Tipo de Veículo do Trecho
			AADD(aAux, '1'                                                                          )       //Paga o trecho ou não (sempre pagar '1')
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"CityCodeOrigin", nGWU_NRCIDO       ))       // GWU_NRCIDO - Cidade de Origem do Trecho
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"ZipCodeOrigin", nGWU_CEPO          ))       // GWU_CEPO - CEP de Origem do Trecho
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"ZipCodeDelivery", nGWU_CEPD        ))       // GWU_CEPD - CEP de Destino do Trecho
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"FreightClassification", nGWU_CDCLFR))       // GWU_CDCLFR - Código da Classificação de Frete do Trecho
			AADD(aAux, GFEGETVALUE(aRoute[nContItens]["Items"],"OperationType", nGWU_CDTPOP        ))       // GWU_CDTPOP - Código do Tipo de Operação do Trecho
			
			AADD(aTrchDoc, aAux)

		Next
		
		if lRet == .F.
			Loop
		EndIf

		cAliasGUK := GetNextAlias()

		BeginSQL Alias cAliasGUK
			SELECT GUK.GUK_CDCLFR
			FROM %Table:GUK% GUK
			WHERE GUK.GUK_FILIAL = %xFilial:GUK%
			AND GUK.%NotDel%
		EndSQL

		If (cAliasGUK)->(!EoF())
			lExiItemExc := .T.
		EndIf

		(cALiasGUK)->(dbCloseArea())

		for nContItens:= 1 to Len(aItemsDocumentBurden)
			aAux := {}
	
			cIssuerCode := GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"IssuerCode", nGW8_EMISDC)
			if Empty(cIssuerCode) // Caso não seja informado o emissor, será considerado o rementente.
				cIssuerCode := cSenderCode
			EndIf
			cInvoiceNumber := GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"InvoiceNumber", nGW8_NRDC,"01" )
			If Empty(cInvoiceNumber)
				cInvoiceNumber := PadR('01' + AllTrim(cValToChar(nContItens)),nGW1_NRDC)
				// Se tiver mais de um documento de carga por romaneio, é obrigatório separar cada documento com seu número
				if nContItens > 1
					lRet := .F.
					cMsgErro := 'Campo InvoiceNumber grupo ItemsDocumentBurden. Quando informado mais de um documento de carga por romaneio é obrigatório informar o campo InvoiceNumber para separar cada documento. '
					Loop
				EndIf
			EndIF

			If !Empty(GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"ItemCode", nGW8_ITEM))
				cAliasGUK := GetNextAlias()

				BeginSQL Alias cAliasGUK
					SELECT GUK.GUK_CDCLFR
					FROM %Table:GUK% GUK
					WHERE GUK.GUK_FILIAL = %xFilial:GUK%
					AND GUK.GUK_ITEM = %Exp:GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"ItemCode", nGW8_ITEM)%
					AND GUK.%NotDel%
				EndSQL

				If (cAliasGUK)->(!EoF())
					cCdClFrItem := (cAliasGUK)->GUK_CDCLFR
				Else
					cCdClFrItem := GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"FreightClassification",nGW8_CDCLFR )

					If Empty(cCdClFrItem) .And. lExiItemExc
						cCdClFrItem := cMV_CDCLFR
					EndIf
				EndIf

				(cALiasGUK)->(dbCloseArea())
			Else
				cCdClFrItem := GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"FreightClassification",nGW8_CDCLFR )

				If Empty(cCdClFrItem) .And. lExiItemExc
					cCdClFrItem := cMV_CDCLFR
				EndIf
			EndIf

			If Empty(cCdClFrItem)
				cCdClFrItem := cMV_CDCLFR	
			EndIf

			AADD(aAux, cIssuerCode                                                                                ) // GW8_EMISDC - Emitente do Documento
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"InvoiceSerie", nGW8_SERDC          )) // GW8_SERDC - Serie do Documento
			AADD(aAux, cInvoiceNumber                                                                             ) // GW8_NRDC - Número do Documento
			AADD(aAux, cTypeOfDocument                                                                            ) // GW8_CDTPDC - Tipo do Documento
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"ItemCode", nGW8_ITEM               )) // GW8_ITEM - Item
			AADD(aAux, cCdClFrItem 																				  ) // GW8_CDCLFR - Classificação de Frete
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"ItemType", nGW8_TPITEM             )) // GW8_TPITEM - Tipo de Item
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"Quantity",,0                       )) // GW8_QTDE - Quantidade do Item
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"Weight",,0                         )) // GW8_PESOR - Peso do Item
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"NetWeight",,0                      )) // GW8_PESOC - Peso Cubado
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"AlternativeQuantity",,0            )) // GW8_QTDALT- Quantidade Peso Alternativo
			if nAPIVersion == 1
				AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"NetPrice",,0                   )) // GW8_VALOR - Valor do bruto
			Else
				AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"GrossPrice",,0                 )) // GW8_VALOR - Valor do bruto
			EndIf
			AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"CubicVolume",,0                    )) // GW8_VOLUME - Volume ocupado (m3)
			AADD(aAux, "1"                                                                                        ) // Trib PIS
			if nAPIVersion >= 2
				AADD(aAux, GFEGETVALUE(aItemsDocumentBurden[nContItens]["Items"],"NetPrice",,0                       )) // GW8_VALLIQ - Valor do LIQUIDO
			EndIf
	
			AADD(aItDoc, aAux)
		Next
	next

Return {lRet, cMsgErro, aAgrFrt, aDocCarg, aTrchDoc, aItDoc}


/*/{Protheus.doc} GFEGETVALUE
//TODO Descrição Retorna o valor do campo de um objeto Json.
@author andre.wisnheski
@since 28/08/2017
@version 1.0
@return Conteudo do objeto 
@param jValues, TJson , Ojeto Json
@param cCampo, characters, Nome do conteudo a ser encontrado
@type function
/*/
Static Function GFEGETVALUE(jValues,cCampo,nTamSX3,cDefault)
	Local nCampos := 0
	Local cRet := ""
	Default nTamSX3 := 0
	for nCampos:= 1 to Len(jValues)
		if Upper(jValues[nCampos]["id"]) == Upper(cCampo)
			cRet	:= jValues[nCampos]["value"]
			Loop
		EndIf
	next
	if Empty(cRet) .AND. !Empty(cValToChar(cDefault))
		cRet := cDefault
	EndIf
	if nTamSX3 > 0
		cRet := PadR(cRet,nTamSX3)
	EndIf
Return cRet


/*/{Protheus.doc} ValidContent
//TODO Realiza as validaçoes dos arquivo.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return ${return}, ${return_description}
@param cContent, characters, conteudo do cabeçalho
@param lHeader, boolean, indica se deve validar o cabeçalhado. Quando executado um GET não tem o cabeçaho
@type function
/*/
Static Function ValidContent(cContent,lHeader, cPatch)
	Local oResponse
	Local aVersion
	
	if Empty(cContent) .AND. lHeader
		oResponse   := JsonObject():New()
		oResponse["content"] := {}
		Aadd(oResponse["content"], JsonObject():New())
	
		oResponse["content"][1]["Items"] := {}
		Aadd(oResponse["content"][1]["Items"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["Status"]	:= "error" 
		oResponse["content"][1]["Items"][1]["Message"]	:= "FreightSimulations: Não foi possível executar a simulação de frete."
		oResponse["content"][1]["Items"][1]["Error"]	:= "FreightSimulations: Dados da simulação não encontrado no corpo da requisição. No método POST deve ser enviado no corpo da mensagem os dados para realizar a simulação. Execute o método GET para pegar JSON de exemplo."
		
		Return {.F., oResponse}
	Else
		aVersion := GFEGetVersion(cPatch)
		if aVersion[1] == .F.
			oResponse   := JsonObject():New()
			oResponse["content"] := {}
			Aadd(oResponse["content"], JsonObject():New())
		
			oResponse["content"][1]["Items"] := {}
			Aadd(oResponse["content"][1]["Items"], JsonObject():New())
			oResponse["content"][1]["Items"][1]["Status"]	:= "error" 
			oResponse["content"][1]["Items"][1]["Message"]	:= "FreightSimulations: Não foi possível executar a simulação de frete."
			oResponse["content"][1]["Items"][1]["Error"]	:= "FreightSimulations: " + aVersion[2]
			
			Return {.F., oResponse}
		EndIf
	EndIf
Return {.T.,nil}

/*/{Protheus.doc} GFEGetVersion
//TODO Verificar se foi informado o patch correto no caminho da solicitação do serviço
@author andre.wisnheski
@since 28/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function GFEGetVersion(cPatchPar)
	Local lStatus := .T.
	Local cMessage := ''
	Local cPatch

	cPatch := Lower(cPatchPar)
	If     AT('supply/gfe/v2/freightsimulations/freightsimulation',cPatch) > 0
		nAPIVersion := 2
	ElseIf AT('supply/gfe/v1/freightsimulations/freightsimulation',cPatch) > 0
		nAPIVersion := 1
	Else
		lStatus := .F.
		cMessage := 'Patch ou versão incorreto. Informado: ' + cPatch + ' - Correto: supply/gfe/version/freightsimulations/freightsimulation - Verificar quais as versões estão disponíveis'
	End
Return {lStatus, cMessage}


/*/{Protheus.doc} GetCostFreight
//TODO Soma o valor do frete dos componentes da simulação de frete por unidade de cálculo.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return ${ntotFrete}, ${O valor do frete do Número de cálculo}
@param aAuxCCF, array, Array com os componentes de frete da unidade de cálculo
@param cNrCalc, characters, Número da unidade de cálculo
@type function
/*/
Static Function GetCostFreight(aAuxCCF,cNrCalc)
	Local nCont		:= 0
	Local nTotFrete	:= 0
	for nCont:= 1 to Len(aAuxCCF)
		if aAuxCCF[nCont][1] == cNrCalc
			IF !Empty(aAuxCCF[nCont][2] + aAuxCCF[nCont][3]) .AND. aAuxCCF[nCont][9] == "1"
				nTotFrete := nTotFrete + aAuxCCF[nCont][8]
			ElseIf Empty(aAuxCCF[nCont][2] + aAuxCCF[nCont][3]) .AND. aAuxCCF[nCont][9] == "1"
				nTotFrete := nTotFrete + aAuxCCF[nCont][8]
			EndIf
		EndIf
	next
Return nTotFrete

/*/{Protheus.doc} GetTax
//TODO Soma o valor da impostos ICMS/ISS.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return ${nVlTax}, ${Valor do ICMS/ISS da unidade de cálculo}
@param aAuxUNC, array, Array com a unidade de cálculo
@param cNrCalc, characters, Número da unidade de cálculo
@type function
/*/
Static Function GetTax(aAuxUNC,cNrCalc)
	Local nCont		:= 0
	Local nVlTax	:= 0
	for nCont:= 1 to Len(aAuxUNC)
		if aAuxUNC[nCont][1] == cNrCalc
			nVlTax := nVlTax + (aAuxUNC[nCont][09] + aAuxUNC[nCont][13])
		EndIf
	next
Return nVlTax

/*/{Protheus.doc} GetPrazo
//TODO Retorna  data e hora de previsão de entrega.
@author andre.wisnheski
@since 09/10/2017
@version 1.0
@return ${return}, ${Data e previsão de entrega}
@param aAuxUNC, array, Unidade de cálculo
@param cNrCalc, characters, Número da unidade de cálculo
@type function
/*/
Static Function GetPrazo(aAuxUNC,cNrCalc)
	Local nCont		:= 0
	Local cPrazo	:= ""
	
	for nCont:= 1 to Len(aAuxUNC)
		if aAuxUNC[nCont][1] == cNrCalc
			cPrazo := GFEDToJson(aAuxUNC[nCont][04],aAuxUNC[nCont][05])
		EndIf
	next
Return cPrazo

/*/{Protheus.doc} GetStrCbox
//TODO Retorna a valor do combobox gravado no banco de dados.
@author andre.wisnheski
@since 30/08/2017
@version 1.0
@return ${cRet}, ${Descrição do valor gravado}
@param cBox, characters, Conteudo do campo cBox
@param cVal, characters, Valor a ser localizado
@type function
/*/
Static Function GetStrCbox(cBox,cVal)
    Local aArr := STRTOKARR(cBox,";")
    Local aArr2 := {}
    Local nCont,nPos,cRet:=""
    For nCont :=1 to Len(aArr)
        aAdd(aArr2,STRTOKARR(aArr[ncont],"="))
    Next nCont
    If Len(aArr2) > 0 
        nPos := aScan(aArr2,{|x|x[1]==cVal})
        If nPos > 0
            cRet := aArr2[nPos][2]
        EndIf
    EndIf
Return cRet

Static Function GetSx3Inf(cCampo,aRetorno)
Local nCont := 1
Local aArea := GetArea("SX3")
Default aRetorno := {"","","",""}
    For nCont := 1 to 4-Len(aRetorno)
        aAdd(aRetorno,"")
    Next
    dbSelectArea("SX3")
    dbSetOrder(2)
    If dbSeek( cCampo )   
        aRetorno[1] := X3Titulo()
        aRetorno[2] := X3Cbox()
        aRetorno[3] := X3Picture()
        aRetorno[4] := X3DESCRIC()
    EndIf
    RestArea(aArea)
Return aRetorno
