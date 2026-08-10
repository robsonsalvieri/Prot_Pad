#Include "AGDA010N.ch"
#Include "fwmvcdef.ch"
#Include "protheus.ch"
#Define Rateio_Negociacao agd.rateioNegociacaoRepository.agdRateioNegociacaoRepository
#Define NEGOCIO_SERVICE  agd.negocioService.agdNegocioService

/*/{Protheus.doc} AGDA010N
Cadastro de Rateio de Entregas da Negociação
Tela de manutenção de rateios da negociação barter, por item de insumo (NEB).
Permite cadastrar e distribuir a quantidade de um insumo negociado entre datas diferentes.
@type function
@version P12
@since 10/04/2025
@author rodrigo.nsoledade
@return nil
/*/
Function AGDA010N()
	Local aAreaNEA    := NEA->(GetArea())
	Local oExecView   := FWViewExec():New()
	Local oNegocioSrv := NEGOCIO_SERVICE():New()
	Local cCodVersao  := ""

	cCodVersao := oNegocioSrv:buscarVersaoAtualValida(NEA->NEA_CODIGO)

	DbSelectArea("NEM")
	DbSelectArea("NEB")
	DbSetOrder(1)//NEB_FILIAL+NEB_CODBRT+NEB_VERSAO+NEB_ITEM
	If DbSeek(xFilial("NEB")+NEA->NEA_CODIGO+cCodVersao)

		//FWExecView(STR0001, "VIEWDEF.AGDA010N", MODEL_OPERATION_UPDATE, ,{ || .T. } , , 60)
		oExecView:setTitle(STR0002) //"Rateio de Entregas"
		oExecView:setSource("AGDA010N")
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:setSize(600, 400) // Define largura e altura em pixels
		oExecView:openView()

	Else
		AGDHELP(STR0003, STR0004) //"Atenção"#"Esta negociação não possui insumos cadastrados."
	EndIf

	RestArea(aAreaNEA)

Return

/*/{Protheus.doc} ModelDef
Função responsavel pela camada de modelagem dos dados
@type function
@return oModel
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStrField  := Nil
	Local oStrGrid   := Nil

	oStrField := FWFormModelStruct():New()
	oStrField:AddTable("", {"X_CODNEG","X_ITEM","X_CODPRO","X_DESPRO","X_QTDPRO"}, STR0001, {|| ""})
	oStrField:AddField("X_CODNEG", RetTitle("NEM_CODBRT"), "X_CODNEG", "C", TamSX3("NEA_CODIGO")[1]) //"Negociação"
	oStrField:AddField("X_ITEM"  , RetTitle("NEM_ITEM")  , "X_ITEM"  , "C", TamSX3("NEM_ITEM")[1]) //"Item Insumo"
	oStrField:AddField("X_CODPRO", RetTitle("NEM_CODPRO"), "X_CODPRO", "C", TamSX3("B1_COD")[1]) //"Cod. Produto"
	oStrField:AddField("X_DESPRO", RetTitle("B1_DESC")   , "X_DESPRO", "C", TamSX3("B1_DESC")[1]) //"Descrição"
	oStrField:AddField("X_QTDPRO", RetTitle("NEB_QTDVEN"), "X_QTDPRO", "N", TamSX3("NEB_QTDVEN")[1],2) //"Quantidade"

	oStrField:SetProperty('X_CODNEG', MODEL_FIELD_INIT, {|| NEA->NEA_CODIGO })
	oStrField:SetProperty('X_CODNEG', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStrField:SetProperty('X_CODPRO', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStrField:SetProperty('X_DESPRO', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStrField:SetProperty('X_QTDPRO', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStrField:SetProperty('X_ITEM'  , MODEL_FIELD_VALID, {|| fValidItem() .And. fBuscaRateio() })

	oStrGrid := FWFormStruct(1, "NEM")
	oStrGrid:AddField("NEM_REGNV", STR0006, "NEM_REGNV", "C", 1) //"Registro Novo"
	oStrGrid:SetProperty('NEM_FILIAL', MODEL_FIELD_INIT, {|| FWxFilial("NEM")})
	oStrGrid:SetProperty('NEM_CODBRT', MODEL_FIELD_INIT, {|| NEA->NEA_CODIGO })
	oStrGrid:SetProperty('NEM_ITEM',   MODEL_FIELD_INIT, {|| oModel:GetModel("CABPROD"):GetValue("X_ITEM") })
	oStrGrid:SetProperty('NEM_CODPRO', MODEL_FIELD_INIT, {|| oModel:GetModel("CABPROD"):GetValue("X_CODPRO") })
	oStrGrid:SetProperty('NEM_REGNV',  MODEL_FIELD_INIT, {|| "1" })//1=Sim

	// Define se a data pode ser editada ou não
	oStrGrid:SetProperty("NEM_DTENTR", MODEL_FIELD_WHEN, {|| fWhenDtEntr() })

	oModel := MPFormModel():New("AGDA010N", { |oModel| fPreValid(oModel) }, {|oModel| fPosValidNEM(oModel)}, {|oModel| fCommitGrid(oModel)})

	oModel:AddFields("CABPROD", , oStrField, , , { || {} })
	oModel:AddGrid("GRIDID", "CABPROD", oStrGrid,,,,)
	oModel:SetPrimaryKey({"NEM_FILIAL", "NEM_CODBRT", "NEM_ITEM", "NEM_DTENTR" })
	oModel:SetRelation("GRIDID", {{"NEM_FILIAL", "xFilial('NEM')"}, {"NEM_CODBRT", "X_CODNEG"}, {"NEM_ITEM", "X_ITEM"}}, NEM->(IndexKey(1)))
	oModel:GetModel("GRIDID"):SetUniqueLine({"NEM_DTENTR"})
	oModel:GetModel("GRIDID"):SetOptional(.T.)

	// Cria os campos de totalizadores
	oModel:AddCalc( 'AGDA010N_TOTAL', 'CABPROD', 'GRIDID', 'NEM_QUANT', 'TOTRATEADO' ,'SUM',{||.t.}/*{||fxxxx() }*/,,STR0007,/*{||fxxx() }*/ ) //"Total Rateado"
	oModel:AddCalc( 'AGDA010N_TOTAL', 'CABPROD', 'GRIDID', 'NEM_QUANT', 'TOTVALDIF' ,'FORMULA',,,STR0008,{|| AGDA10NDIF(oModel)} ) //"Qtd. Faltante"

Return oModel

/*/{Protheus.doc} ViewDef
Função responsavel pela camada de interacao com o usuario 
@type function
@return oView
/*/
Static Function ViewDef()
	Local oView     := Nil
	Local oModel    := Nil
	Local oStrCab   := Nil
	Local oStrGrid  := Nil

	oStrCab := FWFormViewStruct():New()
	oStrCab:AddField("X_CODNEG", "01", RetTitle("NEM_CODBRT"),RetTitle("NEM_CODBRT"), , "C")
	oStrCab:AddField("X_ITEM",   "03", RetTitle("NEM_ITEM")  ,RetTitle("NEM_ITEM")  , , "C")
	oStrCab:AddField("X_CODPRO", "04", RetTitle("NEM_CODPRO"),RetTitle("NEM_CODPRO"), , "C")
	oStrCab:AddField("X_DESPRO", "05", RetTitle("B1_DESC")   ,RetTitle("B1_DESC")   , , "C")
	oStrCab:AddField("X_QTDPRO", "06", RetTitle("NEB_QTDVEN"),RetTitle("NEB_QTDVEN"), , "N", PesqPict( "NEB", "NEB_QTDVEN" ))
	oStrCab:SetProperty("X_ITEM", MVC_VIEW_LOOKUP, "NEBNEM")

	oStrGrid := FWFormStruct(2, "NEM")
	oStrGrid:RemoveField("NEM_CODBRT")
	oStrGrid:RemoveField("NEM_ITEM")
	oStrGrid:RemoveField("NEM_CODPRO")

	oModel := FWLoadModel("AGDA010N")
	oCalc := FWCalcStruct( oModel:GetModel( 'AGDA010N_TOTAL') )
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStrCab, "CABPROD")
	oView:AddGrid("VIEW_GRID", oStrGrid, "GRIDID")
	oView:AddField("VIEW_CALC", oCalc , "AGDA010N_TOTAL")

	oView:CreateHorizontalBox("TOHID", 30)
	oView:CreateHorizontalBox("TOSHOW", 55)
	oView:CreateHorizontalBox("RODAPE", 15)

	oView:SetOwnerView("VIEW_CAB", "TOHID")
	oView:SetOwnerView("VIEW_GRID", "TOSHOW")
	oView:enableTitleView("VIEW_GRID", STR0005) //"Divisão de Entrega"
	oView:SetOwnerView( 'VIEW_CALC','RODAPE' )
	oView:SetCloseOnOk({ || .T.})
Return oView

/*/{Protheus.doc} fValidItem
Valida se o item informado existe na tabela de insumos da negociação (NEB).
@type function
@version 1.0
@author rodrigo.nsoledade
@since 14/04/2025
@return logical, .T. se existir, .F. caso contrário
/*/
Static Function fValidItem()
	Local oModel    := FWModelActive()
	Local oCabec    := oModel:GetModel("CABPROD")
	Local cItem     := oCabec:GetValue("X_ITEM")
	Local oStmt     := FWPreparedStatement():New()
	Local cQuery    := ""
	Local nQtd      := 0
	Local oNegocSrv := NEGOCIO_SERVICE():New()
	Local cCodVersao:= ""

	// Validação do item
	If Empty(cItem)
		Return .F.
	EndIf

	cCodVersao := oNegocSrv:buscarVersaoAtualValida(NEA->NEA_CODIGO)

	cQuery := " SELECT COUNT(*) AS QTD"
	cQuery += " FROM " + RetSqlName("NEB")
	cQuery += " WHERE D_E_L_E_T_ = ''"
	cQuery += "   AND NEB_FILIAL = ?"
	cQuery += "   AND NEB_CODBRT = ?"
	cQuery += "   AND NEB_VERSAO = ?"
	cQuery += "   AND NEB_ITEM   = ?"
	cQuery := ChangeQuery(cQuery)

	oStmt:SetQuery(cQuery)
	oStmt:SetString(1, xFilial("NEB"))
	oStmt:SetString(2, NEA->NEA_CODIGO)
	oStmt:SetString(3, cCodVersao)
	oStmt:SetString(4, cItem)

	nQtd := MPSysExecScalar(oStmt:GetFixQuery(), "QTD")

	If nQtd <= 0
		//AGDHELP(STR0003, STR0010)//"Atenção"#"Esse item não foi encontrado nos insumos da negociação."
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} fBuscaRateio
Busca os dados de rateio para o item informado e popula a grid com os registros da tabela NEM.
@type function
@version P12
@since 11/04/2025
@author rodrigo.nsoledade
@return logical, .T. ou .F.
/*/
Static Function fBuscaRateio()
	Local aArea     := FWGetArea()
	Local oModel    := FwModelActive()
	Local oCabec    := oModel:GetModel("CABPROD")
	Local oGrid     := oModel:GetModel("GRIDID")
	Local oView     := FWViewActive()
	Local jrateio   := JsonObject():New()
	Local jArray    := JsonObject():New()
	Local jItem     := JsonObject():New()
	Local cCodNegoc := oCabec:GetValue("X_CODNEG")
	Local cItem     := oCabec:GetValue("X_ITEM")
	Local nIndex    := 0
	Local oRateio   as object
	Local oNegocSrv := NEGOCIO_SERVICE():New()
	Local cCodVersao:= ""

	cCodVersao := oNegocSrv:buscarVersaoAtualValida(cCodNegoc)

	// Limpa a grid
	If oGrid:Length() > 0
		If oGrid:Length() == 1 .And. Empty(oGrid:GetValue("NEM_ITEM"))
			oGrid:SetValue("NEM_QUANT", 0)
		Else
			oGrid:DelAllLine()
			oGrid:ClearData()
		EndIf
	EndIf

	// Busca os dados do item da NEB
	dbSelectArea("NEB")
	NEB->(dbSetOrder(1)) // NEB_FILIAL+NEB_CODBRT+NEB_VERSAO+NEB_ITEM
	If NEB->(dbSeek(xFilial("NEB") + cCodNegoc + cCodVersao + cItem))

		oCabec:LoadValue("X_CODPRO", NEB->NEB_CODPRO)
		oCabec:LoadValue("X_DESPRO", Posicione("SB1", 1, xFilial("SB1")+NEB->NEB_CODPRO, "B1_DESC"))
		oCabec:LoadValue("X_QTDPRO", NEB->NEB_QTDVEN)

		oRateio := Rateio_Negociacao():New()
		jrateio := oRateio:getListaRateio(cCodNegoc, NEB->NEB_ITEM) //Metodo que retorna os registros de rateio no formato JSON

		If jrateio:HasProperty("rateio") .And. Len(jrateio["rateio"]) > 0
			jArray := jrateio["rateio"]

			For nIndex := 1 To Len(jrateio["rateio"])
				jItem := jArray[nIndex]

				IIf( nIndex > oGrid:Length(), oGrid:AddLine(),)
				oGrid:SetValue("NEM_FILIAL", jItem["NEM_FILIAL"])
				oGrid:SetValue("NEM_CODBRT", jItem["NEM_CODBRT"])
				oGrid:SetValue("NEM_ITEM",   jItem["NEM_ITEM"])
				oGrid:SetValue("NEM_CODPRO", jItem["NEM_CODPRO"])
				oGrid:SetValue("NEM_DTENTR", STOD(jItem["NEM_DTENTR"]))
				oGrid:SetValue("NEM_QUANT",  jItem["NEM_QUANT"])
				oGrid:SetValue("NEM_REGNV",  "2")
			Next
		Else
			// Se não encontrou registros, adiciona linha padrão
			oGrid:LoadValue("NEM_FILIAL", xFilial("NEB"))
			oGrid:LoadValue("NEM_CODBRT", cCodNegoc)
			oGrid:LoadValue("NEM_ITEM",   NEB->NEB_ITEM)
			oGrid:LoadValue("NEM_CODPRO", NEB->NEB_CODPRO)
		EndIf

		oGrid:GoLine(1)
		If oView != Nil;
				.AND. ValType(oView) == "O";
				.AND. oView:oModel:getId() == "AGDA010N"
			oView:Refresh("GRIDID")
		EndIf
	EndIf

	FWRestArea(aArea)
Return .T.

/*/{Protheus.doc} fPreValid
Funcao de pré validação.
@type function
@version P12
@since 11/04/2025
@author rodrigo.nsoledade
@param oModel, objeto do modelo da tela
@return logical
/*/
Static Function fPreValid(oModel)
	Local oCabec := oModel:GetModel("CABPROD")

	oCabec:LoadValue("X_CODNEG", NEA->NEA_CODIGO)

Return .T.

/*/{Protheus.doc} fPosValidNEM
Valida se o rateio totaliza 100% da quantidade do insumo.
@type function
@version P12
@since 11/04/2025
@author rodrigo.nsoledade
@param oModel, objeto do modelo da tela
@return logical
/*/
Static Function fPosValidNEM(oModel)
	Local oGrid      := oModel:GetModel("GRIDID")
	Local nTotal     := 0
	Local nLinha     := 0
	Local nDeleted   := 0
	Local lVlDTENTR  := .F.
	Local nQtdLinhas := oGrid:Length()
	Local nQtdProd   := oModel:GetModel("CABPROD"):GetValue("X_QTDPRO")

	For nLinha := 1 To nQtdLinhas
		oGrid:GoLine(nLinha)
		If !oGrid:IsDeleted()
			nTotal += oGrid:GetValue("NEM_QUANT")

			If Empty(oGrid:GetValue("NEM_DTENTR")) .Or. oGrid:GetValue("NEM_DTENTR") < dDataBase
				lVlDTENTR := .T.
			EndIf
		Else
			nDeleted++
		EndIf
	Next

	If lVlDTENTR
		Help(NIL, NIL, STR0003, NIL, STR0013, 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) //"A data de entrega deve ser maior que a data atual."
		Return .F.
	EndIf

	If nTotal <> nQtdProd .And. nQtdLinhas <> nDeleted //se todas as linhas estiverem deletadas, deixa passar
		Help(NIL, NIL, STR0003, NIL, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) //"Atenção"#"O rateio do item deve ser feito em sua totalidade. Favor verificar."
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} fCommitGrid
Confirma as alterações na grid de rateio (NEM), inclui, altera ou exclui registros.
@type function
@version P12
@since 11/04/2025
@author rodrigo.nsoledade
@param oModel, objeto do modelo da tela
@return logical, .T. para sucesso
/*/
Static Function fCommitGrid(oModel)
	Local oGrid      := oModel:GetModel("GRIDID")
	Local oCabec     := oModel:GetModel("CABPROD")
	Local cNegoc     := oCabec:GetValue("X_CODNEG")
	Local cItem      := oCabec:GetValue("X_ITEM")
	Local aCampos    := FWSX3Util():GetAllFields("NEM", .F.)
	Local nQdtLinhas := oGrid:Length()
	Local nLinha     := 0
	Local i          := 0
	Local cChaveNEM  := ""
	Local lInclui    := .F.

	DbSelectArea("NEM")
	DbSetOrder(1) // NEM_FILIAL+NEM_CODBRT+NEM_ITEM+NEM_DTENTR

	Begin Transaction

		For nLinha := 1 To nQdtLinhas
			oGrid:GoLine(nLinha)

			cChaveNEM := xFilial("NEM") + cNegoc + cItem + DToS(oGrid:GetValue("NEM_DTENTR"))

			If oGrid:IsDeleted()
				If DbSeek(cChaveNEM)
					Reclock("NEM", .F.)
					DbDelete()
					MsUnlock()
				EndIf
			Else
				lInclui := IIF(DbSeek(cChaveNEM),.F., .T.)

				Reclock("NEM", lInclui)

				For i := 1 To Len(aCampos)
					FieldPut(FieldPos(aCampos[i]), oGrid:GetValue(aCampos[i]))
				Next

				MsUnlock()
			EndIf
		Next

	End Transaction

Return .T.

/*/{Protheus.doc} fWhenDtEntr
Valida se o campo NEM_DTENTR pode ser editado com base na existência do registro.
@type function
@version P12
@since 14/04/2025
@author rodrigo.nsoledade
@param oGrid, objeto da grid
@return logical, .T. se pode editar, .F. se deve ser protegido
/*/
Static Function fWhenDtEntr()
	Local oModel := FWModelActive()
	Local oGrid  := oModel:GetModel("GRIDID")
	Local lEdit  := .T.

	If oGrid:GetValue("NEM_REGNV") == "2"
		lEdit  := .F.
	EndIf

Return lEdit

/*/{Protheus.doc} AGDA10NDIF
Retorna a diferenca entre Total rateado e Quantidade de insumo
@type function
@version 12
@author rodrigo.nsoledade
@since 15/04/2025
@return character, alias da consulta
/*/
Static Function AGDA10NDIF(oModel)
	Local nQtdProd := oModel:GetModel("CABPROD"):GetValue("X_QTDPRO")
	Local nRet := 0

	nRet = nQtdProd - oModel:GetModel('AGDA010N_TOTAL'):GetValue('TOTRATEADO')

Return nRet
