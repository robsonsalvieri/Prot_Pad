#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC aSavedModels := {}

/*/{Protheus.doc} GTPRestModel from FwRestModel
	Publicação dos modelos que devem ficar disponíveis no REST.
	@author Serviços
	@since 03/09/2020
	@version version
	/*/
Class GTPRestModel from FwRestModel
	Method setFilter(cFilter)
	Method SaveData(cPK, cData, cError)
	Method GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID)
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} GetData
Método responsável por retornar o registro do modelo no formato XML
ou JSON.
@param  lFieldDetail    Indica se retorna o registro com informações detalhadas
@param  lFieldVirtual   Indica se retorna o registro com campos virtuais
@param  lFieldEmpty     Indica se retorna o registro com campos nao obrigatorios vazios
@param  lFirstLevel     Indica se deve retornar todos os modelos filhos ou nao
@param  lInternalID     Indica se deve retornar o ID como informação complementar das linhas do GRID
@return cRet        Retorna o registro nos formatos XML ou JSON
@author Felipe Bonvicini Conti
@since 25/06/2015
@version P11, P12
/*/
//-------------------------------------------------------------------
Method GetData(lFieldDetail, lFieldVirtual, lFieldEmpty, lFirstLevel, lInternalID) Class GTPRestModel
    Local oJson   := JsonObject():New()
	Local cPath   := strtokarr(Upper(self:GetHttpHeader("_PATH_")),'/')[3]
	Local cVerbo  := self:GetHttpHeader("_METHOD_")
    Local nModel
    Local hModel
	Local cRet		:= ""

	If cVerbo != 'GET' .And. cPath == 'GTPU011' .And. Len(aSavedModels) > 0
		// Cria estrutura base
		oJson["id"] := "GTPU011"
		oJson["operation"] := MODEL_OPERATION_VIEW
		oJson["models"] := {}

		// Verifica se há modelos salvos
		For nModel := 1 To Len(aSavedModels)
			hModel := aSavedModels[nModel]
			AAdd(oJson["models"], hModel)
		Next
		cRet := oJson:ToJson()

	Else
		self:oModel:SetOperation(MODEL_OPERATION_VIEW)
		Self:oModel:Activate()
		cRet := Self:oModel:GetJsonData(lFieldDetail,,lFieldVirtual,,lFieldEmpty,.T./*lPK*/,.T./*lPKEncoded*/,self:aFields,lFirstLevel,lInternalID)
		Self:oModel:DeActivate()

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Método responsável por salvar o registro recebido pelo metodo PUT ou POST.
Se o parametro cPK não for informado, significa que é um POST.
@param  cPK         PK do registro.
@param  cData       Conteúdo a ser salvo
@param  @cError Retorna o alguma mensagem de erro
@return lRet        Indica se o registro foi salvo
@author Felipe Bonvicini Conti
@since 25/06/2015
@version P11, P12
/*/
//-------------------------------------------------------------------
Method SaveData(cPK, cData, cError) Class GTPRestModel
	Local lRet     := .T.
	Local oJson    := JsonObject():New()
	Local cPath   := strtokarr(Upper(self:GetHttpHeader("_PATH_")),'/')[3]
	Local aModels  := {}
	Local oModels  := {}
	Local oGrid	   := {}
	Local cModelID := ""
	Local cModelData := ""
	Local nModel     := 0
	Local nIndex	 := 0
	Local nOperation := 0
	Local nAtivas := 0
	Local nI := 0

	Default cData := ""

	If cPath == 'GTPU011'
		aSavedModels := {}

		oJson:FromJson(cData)

		aModels := oJson["models"]
		nOperation := AllTrim(Str(oJson["operation"]))

		// Itera sobre os modelos recebidos
		For nModel := 1 To Len(aModels)

			oModels := aModels[nModel]
			cModelID := oModels["id"]

			cModelData := '{"id": "' + oJson["id"] + '","operation": ' + nOperation + ',"models": ['+ FWJsonSerialize( oModels ) + ']}'

			nIndex := ASCAN(aModels[nModel]["fields"], {|x| x["id"] == "H7E_CODIGO" })
			If nIndex > 0
				self:oModel:SetOperation(MODEL_OPERATION_UPDATE)
				self:Seek(xFilial("H7E")+aModels[nModel]["fields"][nIndex]['value'])

			Else
				self:oModel:SetOperation(MODEL_OPERATION_INSERT)

			EndIf
			Self:oModel:Activate()

			If Self:oModel:LoadJsonData(cModelData)

				If Self:oModel:lModify
					If (Self:oModel:VldData() .And. Self:oModel:CommitData())
						Sleep(1000) // espera 1 segundo a cada 10 commits
						lRet := .T.
						AAdd(aSavedModels, oModels) // Guarda o modelo original

					Else

						AAdd(aSavedModels, ErrorMessage(self:oModel:GetErrorMessage(), aModels[nModel]["fields"])) // Guarda o modelo original

					EndIf

				Else
					lRet := .F.
					Self:SetStatusResponse(304, "Not Modified")
				EndIf

			Else
				//lRet := .F.
				//cError := ErrorMessage(self:oModel:GetErrorMessage())
			EndIf

			// Verifica se todos os itens da H7F foram deletados
			If lRet .And. ASCAN(aModels[nModel]["models"][1]["items"], {|x| x["deleted"] == 1 }) > 0
				nAtivas := 0
				oGrid := Self:oModel:GetModel("H7FDETAIL")

				For nI := 1 To oGrid:Length()
					oGrid:GoLine(nI)
					If !oGrid:IsDeleted()
						nAtivas++
					EndIf
				Next

				If nAtivas == 0
					Self:oModel:DeActivate()
					self:oModel:SetOperation(MODEL_OPERATION_DELETE)
					self:Seek(xFilial("H7E")+aModels[nModel]["fields"][nIndex]['value'])
					Self:oModel:Activate()
					If !(Self:oModel:VldData() .And. Self:oModel:CommitData())
						AAdd(aSavedModels, ErrorMessage(self:oModel:GetErrorMessage()))
					EndIf
				EndIf

			EndIf

			Self:oModel:DeActivate()

		Next

	Else

		If Empty(cPk)
			self:oModel:SetOperation(MODEL_OPERATION_INSERT)
		Else
			self:oModel:SetOperation(MODEL_OPERATION_UPDATE)
			lRet := self:Seek(cPK)
		EndIf
		If lRet
			self:oModel:Activate()
			If self:lXml
				//lRet := self:oModel:LoadXMLData(cData)
			Else
				lRet := self:oModel:LoadJsonData(cData)
			EndIf
			If lRet
				If self:oModel:lModify // Verifico se o modelo sofreu alguma alteração
					If !(self:oModel:VldData() .And. self:oModel:CommitData())
						lRet := .F.
						cError := ErrorMessage(self:oModel:GetErrorMessage())
					EndIf
				Else
					lRet := .F.
					self:SetStatusResponse(304, "Not Modified")
				EndIf
			Else
				//cError := ErrorMessage(self:oModel:GetErrorMessage())
			EndIf
			Self:oModel:DeActivate()
		Else
			//cError := i18n("Invalid record '#1' on table #2", {cPK, self:cAlias})
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ErrorMessage
Funcao responsavel por retonar o erro do modelo.
@param aErroMsg Array de erro do modelo de dados
@return cRet Formato texto do array de erro do modelo de dados
@author Felipe Bonvicini Conti
@since 05/04/2016
@version P11, P12
/*/
//-------------------------------------------------------------------
Static Function ErrorMessage(aErroMsg, oModels)
	Local cRet 	 := CRLF + " --- Erro no Modelo ---" + CRLF

    cRet += "Id submodelo origem: [" + aErroMsg[1] + "]" + CRLF
    cRet += "Id campo origem: [" + aErroMsg[2] + "]" + CRLF
    cRet += "Id submodelo erro: [" + aErroMsg[3] + "]" + CRLF
    cRet += "Id campo erro: [" + aErroMsg[4] + "]" + CRLF
    cRet += "Id erro: [" + aErroMsg[5] + "]" + CRLF
    cRet += "Mensagem de erro: [" + aErroMsg[6] + "]" + CRLF
    cRet += "Mensagem da solução: [" + aErroMsg[7] + "]" + CRLF
    cRet += "Valor atribuído: [" + cValToChar( aErroMsg[8] ) + "]" + CRLF
    cRet += "Valor anterior: [" + cValToChar( aErroMsg[9] ) + "]" + CRLF
    aErroMsg := aSize(aErroMsg, 0)

Return EncodeUTF8(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter()
Filtro recebido da requisição.

@author Breno Gomes
@since 10/07/2024
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class GTPRestModel
Local cVerbo     := self:GetHttpHeader("_METHOD_")
Local cPath      := strtokarr(Upper(self:GetHttpHeader("_PATH_")),'/')[3]
Local cFiltFil   := ""

	Do case
		Case cVerbo == 'GET'
			public INCLUI   := .F.
			public ALTERA   := .F.
		Case cVerbo == 'POST'
			public INCLUI   := .T.
			public ALTERA   := .F.
			nOpc := 3
		Case cVerbo == 'PUT'
			public INCLUI   := .F.
			public ALTERA   := .T.
			nOpc := 4
		Case cVerbo == 'DELETE'
			public INCLUI   := .F.
			public ALTERA   := .F.
			nOpc := 5
	End Case

	Do Case
		Case cPath == "GTPA008"
			cFiltFil := "GYG_FILIAL = '" + FWxFilial("GYG") + "'"
		Case cPath == "GTPU001"
			cFiltFil := "H6R_FILIAL = '" + FWxFilial("H6R") + "'"
		Case cPath == "GTPU002"
			cFiltFil := "H6S_FILIAL = '" + FWxFilial("H6S") + "'"
		Case cPath == "GTPU003"
			cFiltFil := "H6V_FILIAL = '" + FWxFilial("H6V") + "'"
		Case cPath == "GTPU004"
			cFiltFil := "H6W_FILIAL = '" + FWxFilial("H6W") + "'"
		Case cPath == "GTPU005"
			cFiltFil := "H6Y_FILIAL = '" + FWxFilial("H6Y") + "'"
		Case cPath == "GTPU006"
			cFiltFil := "H6Z_FILIAL = '" + FWxFilial("H6Z") + "'"
		Case cPath == "GTPU007"
			cFiltFil := "T9_FILIAL = '" + FWxFilial("ST9") + "'"
		Case cPath == "GTPU008"
			cFiltFil := "H72_FILIAL = '" + FWxFilial("H72") + "'"
		Case cPath == "GTPU009"
			cFiltFil := "H71_FILIAL = '" + FWxFilial("H71") + "'"
		Case cPath == "GTPU010"
			cFiltFil := "H76_FILIAL = '" + FWxFilial("H76") + "'"
		Case cPath == "GTPU011"
			cFiltFil := "H7E_FILIAL = '" + FWxFilial("H7E") + "'"
		Case  cPath =="GTPU011A"
			cFiltFil := "H7R_FILIAL = '" + FWxFilial("H7R") + "'"
		Case cPath == "GTPU012"
			cFiltFil := "H7H_FILIAL = '" + FWxFilial("H7H") + "'"
		Case cPath == "GTPU014"
			cFiltFil := "H7O_FILIAL = '" + FWxFilial("H7O") + "'"
		Case cPath == "GTPU016"
			cFiltFil := "H7M_FILIAL = '" + FWxFilial("H7M") + "'"
		Case cPath == "GTPU018"
			cFiltFil := "H82_FILIAL = '" + FWxFilial("H82") + "'"
		Case cPath == "GTPU019"
			cFiltFil := "H84_FILIAL = '" + FWxFilial("H84") + "'"
		Case cPath == "GTPUNATFIN"
			cFiltFil := "ED_FILIAL = '" + FWxFilial("SED") + "'"
		Case cPath == "GTPUCLIENTE"
			cFiltFil := "A1_FILIAL = '" + FWxFilial("SA1") + "'"
		Case cPath == "GTPUFORNEC"
			cFiltFil := "A2_FILIAL = '" + FWxFilial("SA2") + "'"
		Case cPath == "GTPBANCO"
			cFiltFil := "A6_FILIAL = '" + FWxFilial("SA6") + "'"
		Otherwise
			cFiltFil := ""
	End Case

	If !Empty(cFiltFil)
		If !Empty(cFilter)
			cFilter += " AND "
		EndIf
		cFilter += cFiltFil
	EndIf


Return _Super:SetFilter(cFilter)

	PUBLISH MODEL REST NAME GTPA000     SOURCE GTPA000    RESOURCE OBJECT GTPRestModel  /*Orgão Concedente*/
	PUBLISH MODEL REST NAME GTPA001     SOURCE GTPA001    RESOURCE OBJECT GTPRestModel  /*Localidades*/
	PUBLISH MODEL REST NAME GTPA006     SOURCE GTPA006    RESOURCE OBJECT GTPRestModel  /*Agências*/
	PUBLISH MODEL REST NAME GTPA007     SOURCE GTPA007    RESOURCE OBJECT GTPRestModel  /*Tipo de Docs*/
	PUBLISH MODEL REST NAME GTPA008     SOURCE GTPA008    RESOURCE OBJECT GTPRestModel  /*Colaboradores*/
	PUBLISH MODEL REST NAME GTPA010     SOURCE GTPA010    RESOURCE OBJECT GTPRestModel  /*Tipo de Recurso*/
	PUBLISH MODEL REST NAME GTPA011     SOURCE GTPA011    RESOURCE OBJECT GTPRestModel  /*Categorias*/
	PUBLISH MODEL REST NAME GTPA022     SOURCE GTPA022    RESOURCE OBJECT GTPRestModel  /*Tipo de linha*/
	PUBLISH MODEL REST NAME GTPA045     SOURCE GTPA045    RESOURCE OBJECT GTPRestModel  /*Cadastro de Cheques*/
	PUBLISH MODEL REST NAME GTPA102     SOURCE GTPA102    RESOURCE OBJECT GTPRestModel  /*Num. e Movimento de Bilhetes*/
	PUBLISH MODEL REST NAME GTPA102B    SOURCE GTPA102B   RESOURCE OBJECT GTPRestModel  /*Num. e Movimento de Bilhetes*/
	PUBLISH MODEL REST NAME GTPA117     SOURCE GTPA117    RESOURCE OBJECT GTPRestModel  /*Taxas*/
	PUBLISH MODEL REST NAME GTPA026     SOURCE GTPA026    RESOURCE OBJECT GTPRestModel  /*Vandas POS*/
	PUBLISH MODEL REST NAME GTPA115     SOURCE GTPA115    RESOURCE OBJECT GTPRestModel  /*Bilhetes*/
	PUBLISH MODEL REST NAME GTPBANCO    SOURCE MATA070    RESOURCE OBJECT GTPRestModel  //Bancos - MATA070
	PUBLISH MODEL REST NAME GTPADMFIN   SOURCE LOJA070    RESOURCE OBJECT GTPRestModel  //Adm.Financeira - LOJA070
	PUBLISH MODEL REST NAME GTPA004     SOURCE GTPA004    RESOURCE OBJECT GTPRestModel  /*Horarios*/
	PUBLISH MODEL REST NAME GTPA002     SOURCE GTPA002    RESOURCE OBJECT GTPRestModel  /*Linhas*/
	PUBLISH MODEL REST NAME GTPA300     SOURCE GTPA300    RESOURCE OBJECT GTPRestModel  /*Viagens*/
	PUBLISH MODEL REST NAME GTPA422     SOURCE GTPA422    RESOURCE OBJECT GTPRestModel  /*Demonstrativo de Passagem*/
	PUBLISH MODEL REST NAME GTPA107     SOURCE GTPA107    RESOURCE OBJECT GTPRestModel  /*Remessa de documento*/
	PUBLISH MODEL REST NAME GTPA421     SOURCE GTPA421    RESOURCE OBJECT GTPRestModel  /*Ficha de remessa*/
	PUBLISH MODEL REST NAME GTPA421PO   SOURCE GTPA421PO  RESOURCE OBJECT GTPRestModel  /*Ficha de remessa - Exclusivo PO-UI*/
	PUBLISH MODEL REST NAME GTPA420     SOURCE GTPA420    RESOURCE OBJECT GTPRestModel  /*Tipos receita despesa*/
	PUBLISH MODEL REST NAME GTPA287     SOURCE GTPA287    RESOURCE OBJECT GTPRestModel  /*Parametros de cliente requisição*/
	PUBLISH MODEL REST NAME GTPA283     SOURCE GTPA283    RESOURCE OBJECT GTPRestModel  /*Requisições*/
	PUBLISH MODEL REST NAME GTPA284     SOURCE GTPA284    RESOURCE OBJECT GTPRestModel  /*Lote Requisições*/
	PUBLISH MODEL REST NAME GTPU001     SOURCE GTPU001    RESOURCE OBJECT GTPRestModel  /*Forma de pagamentos - urbano*/
	PUBLISH MODEL REST NAME GTPU002     SOURCE GTPU002    RESOURCE OBJECT GTPRestModel  /*Tarifas - urbano*/
	PUBLISH MODEL REST NAME GTPU003     SOURCE GTPU003    RESOURCE OBJECT GTPRestModel  /*Linhas - urbano*/
	PUBLISH MODEL REST NAME GTPU004     SOURCE GTPU004    RESOURCE OBJECT GTPRestModel  /*Seções - urbano*/
	PUBLISH MODEL REST NAME GTPU005     SOURCE GTPU005    RESOURCE OBJECT GTPRestModel  /*Validador - urbano*/
	PUBLISH MODEL REST NAME GTPU006     SOURCE GTPU006    RESOURCE OBJECT GTPRestModel  /*Roleta - urbano*/
	PUBLISH MODEL REST NAME GTPU007     SOURCE GTPU007    RESOURCE OBJECT GTPRestModel  /*Complemento de Frota - urbano*/
	PUBLISH MODEL REST NAME GTPU008     SOURCE GTPU008    RESOURCE OBJECT GTPRestModel  /*Pedágio - urbano*/
	PUBLISH MODEL REST NAME GTPU009     SOURCE GTPU009    RESOURCE OBJECT GTPRestModel  /*Programação de linhas - urbano*/
	PUBLISH MODEL REST NAME GTPU010     SOURCE GTPU010    RESOURCE OBJECT GTPRestModel  /*Criação de Escalas- urbano*/
	PUBLISH MODEL REST NAME GTPU011     SOURCE GTPU011    RESOURCE OBJECT GTPRestModel  /*Alocação de recursos - urbano*/
	PUBLISH MODEL REST NAME GTPU011A    SOURCE GTPU011A   RESOURCE OBJECT GTPRestModel  /*Lançamento de exceções - urbano*/
	PUBLISH MODEL REST NAME GTPU012     SOURCE GTPU012    RESOURCE OBJECT GTPRestModel  /*Cartões Provisórios - Urbano*/
	PUBLISH MODEL REST NAME GTPU014     SOURCE GTPU014    RESOURCE OBJECT GTPRestModel  /*Tipo de receita e despesa - Urbano*/
	PUBLISH MODEL REST NAME GTPU016     SOURCE GTPU016    RESOURCE OBJECT GTPRestModel  /*Locais de Arrecadação - Urbano*/
	PUBLISH MODEL REST NAME GTPU018     SOURCE GTPU018    RESOURCE OBJECT GTPRestModel  /*Grupo de colaboradores - Urbano*/
	PUBLISH MODEL REST NAME GTPU019     SOURCE GTPU019    RESOURCE OBJECT GTPRestModel  /*Tipos de exceções - Urbano*/
	PUBLISH MODEL REST NAME GPEA030     SOURCE GPEA030    RESOURCE OBJECT GTPRestModel  /*Funcão - urbano*/
	PUBLISH MODEL REST NAME GTPUNATFIN  SOURCE FINA010    RESOURCE OBJECT GTPRestModel  /* Natureza - FINA010*/
	PUBLISH MODEL REST NAME GTPUCLIENTE SOURCE MATA030    RESOURCE OBJECT GTPRestModel  /* Cliente - MATA030*/
	PUBLISH MODEL REST NAME GTPUFORNEC  SOURCE MATA020    RESOURCE OBJECT GTPRestModel  /* Fornecedor - MATA020*/
