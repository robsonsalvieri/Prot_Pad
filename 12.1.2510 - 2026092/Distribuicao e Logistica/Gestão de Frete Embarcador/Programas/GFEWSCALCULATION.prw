#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 
WSRESTFUL FREIGHTCALCULATION DESCRIPTION "Serviço especifico para execução do calculo de frete do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"
 
WSMETHOD GET  DESCRIPTION "Exemplo de arquivo JSON para utilizar com base no cálculo de frete no módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"                         WSSYNTAX "supply/gfe/v1/freightcalculations || /GET/{id}"
WSMETHOD POST DESCRIPTION "Executa o cálculo de frete e recebe as mensagens de retorno de cada romaneio solicitado no módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR"    WSSYNTAX "supply/gfe/v1/freightcalculations || /POST/{id}"

END WSRESTFUL

WSMETHOD GET WSSERVICE FREIGHTCALCULATION
	Local oResponse   := JsonObject():New()

	/* DEFINIÇÃO DOS TAMANHOS DOS CAMPOS*/
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1]
	
	/* A FILIAL DEVE SER ENVIADA VIA PROTOCOLO REST NO HEADER tenantId CONFORME DOCUMENTAÇÃO DO PROTOCOLO REST NA TDN*/  

	// define o tipo de retorno do método
	::SetContentType("application/json")
	 
	//oResponse["description"] := EncodeUTF8("API PARA CALCULO DE FRETE NO MÓDULO SIGAGFE - GESTÃO DE FRETE EMBARCADOR (WEB SERVICE - REST)")
	
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())

	oResponse["content"][1]["Items"][1]["Manifest"] := {}

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"] := {}
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "ManifestNumber"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := nGWN_NRROM
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Número do Romaneio para cálculo"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := PADR("1",nGWN_NRROM,'0')

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "ReleaseCargoDocument"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := "1"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Liberar Documento de Carga (1=Não,2=Sim)"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "1"

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"] := {}
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["id"] := "ManifestNumber"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["length"] := nGWN_NRROM
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["Description"] := "Número do Romaneio para cálculo"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["value"] := PADR("2",nGWN_NRROM,'0')

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "ReleaseCargoDocument"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := "1"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "Liberar Documento de Carga (1=Não,2=Sim)"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := "1"

	::SetResponse(EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.)))
	
Return .T.

WSMETHOD POST WSSERVICE FREIGHTCALCULATION
	Local oContent		:= Nil
	Local aRetCalc
	Local aRetRom		:= {}
	Local cContent		:= ""
	Local aRet			:= {}
	Local cReturn		:= ""
	Local nCont 		:= 0
	Local cMsg			:= ""
	Local cArqLogCalc	:= ""
	Local cAliGW1		:= ""
	
	// define o tipo de retorno do método
	::SetContentType("application/json")
	
	cContent :=  ::GetContent()
	
	aRet := ValidContent(cContent)
	If !aRet[1]
		::SetResponse(EncodeUTF8(FWJsonSerialize(aRet[2], .F., .F., .T.)))
		Return .T.
	EndIf
	
	FWJsonDeserialize(cContent,@oContent)
	
	aRet := ReadContent(oContent)
	
	For nCont:= 1 To Len(aRet)
		cArqLogCalc := ""
		cMsg		:= ""

		If aRet[nCont][1]
			GWN->(dbSetOrder(1))
			GWN->(dbSeek(xFilial("GWN") + aRet[nCont][2][1]))

			If aRet[nCont][2][2] == "2"
				cAliGW1 := GetNextAlias()

				BeginSQL Alias cAliGW1
					SELECT GW1.R_E_C_N_O_ RECNOGW1
					FROM %Table:GW1% GW1
					WHERE GW1.GW1_FILROM = %Exp:GWN->GWN_FILIAL%
					AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
					AND GW1.GW1_SIT = '2'
					AND GW1.%NotDel%
				EndSQL

				If (cAliGW1)->(!EoF())
					GW1->(dbGoTo((cAliGW1)->RECNOGW1))

					GFEX101REG()

					(cAliGW1)->(dbSkip())
				EndIf

				(cAliGW1)->(dbCloseArea())
			EndIf

			aRetCalc := GFE050CALC(Nil,.F.,@cMsg,,,@cArqLogCalc) 

			If aRetCalc .AND. Empty(cMsg)
				aAdd(aRetRom,{aRet[nCont][2][1],"Cálculo realizado com sucesso","ok",cArqLogCalc})
			Else
				aAdd(aRetRom,{aRet[nCont][2][1],cMsg,'error',cArqLogCalc})
			EndIf
		Else
			aAdd(aRetRom,{aRet[nCont][2][1],aRet[nCont][3],'error',cArqLogCalc})
		EndIf
	Next
	
	cReturn := FWJsonSerialize(WriteCalculation(aRetRom), .F., .F., .T.)
	
	::SetResponse(EncodeUTF8(cReturn))
Return .T.

/*/{Protheus.doc} WriteCalculation
//TODO Monta o Json da cálculo de frete realizado.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return oResponse, ${Objeto Json da cálculo de frete}
@param aRetFrete, array, Array com a cálculo de frete calculado
@type function
/*/
Static Function WriteCalculation(aRetFrete)
	Local oResponse	:= JsonObject():New()
	Local nCont		:= 0
	
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())
	
	oResponse["content"][1]["Items"][1]["Status"]	:= "ok" 
	oResponse["content"][1]["Items"][1]["Message"]	:= "freightcalculations: Cálculo(s) de Frete realizado(s). Verifique o Status de cada Romaneio calculado."

	oResponse["content"][1]["Items"][1]["FreightCalculation"] := {}

	for nCont:= 1 to Len(aRetFrete)

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"] := {}
		
		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] 			:= "ManifestNumber"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"] 		:= aRetFrete[nCont][1]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "Número do Romaneio para cálculo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Message"] 	:= aRetFrete[nCont][2]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Status"] 		:= aRetFrete[nCont][3]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["FileMessage"] := aRetFrete[nCont][4]

	next

Return oResponse

/*/{Protheus.doc} ReadContent
//TODO Realiza a leitura do conteudo enviado no método POST.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oContent, object, descrição
@type function
/*/
Static Function ReadContent(oContent)
	Local aManifest
	Local nContent		:= 0
	Local aAgrFrt		:= {} // Agrupadores de frete
	Local aAux			:= {}
	Local lRet			:= .T.
	Local cMsgErro		:= ""
	Local cAuxMN

	/* DEFINIÇÃO DE TAMANHO DE CAMPOS*/
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1] 
	
	For nContent:= 1 to Len(oContent["content"][1]["Items"][1]["Manifest"])
		aManifest := oContent["content"][1]["Items"][1]["Manifest"][nContent]["Items"]
		
		aAux	:= {}
		lRet	:= .T.
		cLibDC	:= "1"
		
		cAuxMN := GFEGETVALUE(aManifest,"ManifestNumber",nGWN_NRROM)
		cLibDC := GFEGETVALUE(aManifest,"ReleaseCargoDocument",1)
		If lRet .AND. Empty(cAuxMN)
			lRet := .F.
			cMsgErro := 'Campo ManifestNumber. Número do Romaneio não informado. Informe um número de romaneio. '
			aAux := {lRet, {cAuxMN, cLibDC}, cMsgErro}
		EndIf

		If lRet
			GWN->(dbSetOrder(1))
			If !GWN->(dbSeek(xFilial("GWN") + cAuxMN))
				lRet := .F.
				cMsgErro := 'Campo ManifestNumber. Número do Romaneio informado não é válido, romaneio não encontrado na base de dados. ('+xFilial("GWN") + cAuxMN+')'
				aAux := {lRet, {cAuxMN, cLibDC}, cMsgErro}
			EndIf
		EndIf

		If lRet
			lRet := .T.
			cMsgErro := ''
			aAux := {lRet, {cAuxMN, cLibDC}, cMsgErro}
		EndIf

		AADD(aAgrFrt, aAux)
	next

Return aAgrFrt


/*/{Protheus.doc} GFEGETVALUE
//TODO Descrição Retorna o valor do campo de um objeto Json.
@author andre.wisnheski
@since 21/02/2018
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
	
	For nCampos:= 1 to Len(jValues)
		If Upper(jValues[nCampos]["id"]) == Upper(cCampo)
			cRet	:= jValues[nCampos]["value"]
			Loop
		EndIf
	Next

	If Empty(cRet) .AND. !Empty(cValToChar(cDefault))
		cRet := cDefault
	EndIf

	If nTamSX3 > 0
		cRet := PadR(cRet,nTamSX3)
	EndIf
Return cRet


/*/{Protheus.doc} ValidContent
//TODO Realiza as validaçoes dos arquivo.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cContent, characters, descrição
@type function
/*/
Static Function ValidContent(cContent)
	Local oResponse   := JsonObject():New()
	
	if Empty(cContent)
		oResponse["content"] := {}
		Aadd(oResponse["content"], JsonObject():New())
	
		oResponse["content"][1]["Items"] := {}
		Aadd(oResponse["content"][1]["Items"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["Status"]	:= "error" 
		oResponse["content"][1]["Items"][1]["Message"]	:= "freightcalculations: Não foi possível executar o cálculo de frete."
		oResponse["content"][1]["Items"][1]["Error"]	:= "freightcalculations: Dados do cálculo não encontrado no corpo da requisição. No método POST deve ser enviado no corpo da mensagem os dados para realizar o cálculo de frete. Execute o método GET para pegar JSON de exemplo."
		
		Return {.F., oResponse}
	EndIf
Return {.T.,nil}














