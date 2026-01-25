#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSMODELEVENTWMSA324.CH"

#DEFINE WMSME32401 "WMSME32401"
#DEFINE WMSME32402 "WMSME32402"
#DEFINE WMSME32403 "WMSME32403"
#DEFINE WMSME32404 "WMSME32404"
#DEFINE WMSME32405 "WMSME32405"
#DEFINE WMSME32406 "WMSME32406"
#DEFINE WMSME32407 "WMSME32407"

//-------------------------------------------------------------------
CLASS WMSModelEventWMSA324 FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD BeforeTTS(oModel, cModelId)
	METHOD After(oModel, cModelId, cAlias, lNewRecord)
	METHOD InTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)

	METHOD ModelPreVld(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New() CLASS WMSModelEventWMSA324
Return
 
METHOD Destroy()  Class WMSModelEventWMSA324
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
//-------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) CLASS WMSModelEventWMSA324
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// depois da gravação de cada submodelo (field ou cada linha de uma grid)
//-------------------------------------------------------------------
METHOD After(oModel, cModelId, cAlias, lNewRecord) CLASS WMSModelEventWMSA324
Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// Após as gravações porém antes do final da transação
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS WMSModelEventWMSA324
Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS WMSModelEventWMSA324
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model
//-------------------------------------------------------------------
METHOD ModelPreVld(oModel, cModelId) CLASS WMSModelEventWMSA324
Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
//-------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS WMSModelEventWMSA324
Local oModel     := FWModelActive()
Local cProduto   := ""
Local cPedCom    := ""
Local cItPedCom  := ""
Local cFilPedCom := ""

	If cModelID == "A324D0M"

		cProduto   := oSubModel:GetValue("D0M_PRODUT")
		cPedCom    := oSubModel:GetValue("D0M_PEDCOM")
		cItPedCom  := oSubModel:GetValue("D0M_ITPC")
		cFilPedCom := oSubModel:GetValue("D0M_FILPED")

		If !IntWMS(cProduto)
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32401,STR0001,STR0002) // "O produto informado não possui controle WMS." // "Informe um produto com controle WMS."
			Return .F.
		EndIf

		If !Empty(cPedCom)

			If Empty(cItPedCom)
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32402,STR0003,STR0004) // "O campo Pedido de Compra foi preenchido, porém não foi informado o Item relacionado ao mesmo." // "Informe também o Item do Pedido de Compra."
				Return .F.
			EndIf

			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(cFilPedCom+cPedCom+cItPedCom))
				If !(SC7->C7_PRODUTO == cProduto)
					oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32403,WmsFmtMsg(STR0005,{{"[VAR01]",AllTrim(cProduto)},{"[VAR02]",AllTrim(SC7->C7_PRODUTO)}}),STR0006) // "O produto informado no Plano de Distribuição ([VAR01]) é diferente do produto informado no Pedido de Compra ([VAR02])." // "Verifique os dados informados."
					Return .F.
				EndIf
			Else
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32404,STR0007,STR0008) // "O Pedido ou o Item do Pedido de Compra informado não existe." // "Verifique os dados informados ou utilize a consulta padrâo (F3) para busca e preenchimento automático dos campos."
				Return .F.
			EndIf

		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS WMSModelEventWMSA324
Local oModelFlds := oModel:GetModel("A324D0L")
Local oModelGrid := oModel:GetModel("A324D0M")
Local nI         := 1
Local cCodPln    := ""
Local cItem      := ""
Local cProduto   := ""
Local cFilPedCom := ""
Local cPedCom    := ""
Local cItPedCom  := ""
Local nQtdDem    := 0
Local nQtdDis    := 0
Local lQtdDist   := .F.
Local lQtdParc   := .F.
Local aPrdPedCom := {}
Local nQtdDemAux := 0

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		For nI := 1 To oModelGrid:Length()

			oModelGrid:GoLine(nI)

			If !oModelGrid:IsDeleted()

				cCodPln    := oModelFlds:GetValue("D0L_CODPLN")
				cItem      := oModelGrid:GetValue("D0M_ITEM")
				cProduto   := oModelGrid:GetValue("D0M_PRODUT")
				cFilPedCom := oModelGrid:GetValue("D0M_FILPED")
				cPedCom    := oModelGrid:GetValue("D0M_PEDCOM")
				cItPedCom  := oModelGrid:GetValue("D0M_ITPC")
				nQtdDem    := oModelGrid:GetValue("D0M_QTDDEM")
				nQtdDis    := oModelGrid:GetValue("D0M_QTDDIS")

				If QtdComp(nQtdDis) > 0
					lQtdDist := .T.
					If QtdComp(nQtdDem) > QtdComp(nQtdDis)
						lQtdParc := .T.
					EndIf
				EndIf

				If QtdComp(nQtdDem) < QtdComp(nQtdDis)
					oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32405,WmsFmtMsg(STR0009,{{"[VAR01]",cItem}}),STR0010) // "A quantidade demandada para o Item [VAR01] é menor do que a quantidade distribuída." // "Informe para o Item uma Quantidade de Demanda maior ou igual à Quantidade Distribuída."
					Return .F.
				EndIf

				If !Empty(cPedCom)
					nQtdDemAux := CalcQtdDem(aPrdPedCom,cProduto,cFilPedCom,cPedCom,cItPedCom,nQtdDem)
					If !AvalQtdDem(cCodPln,cFilPedCom,cPedCom,cItPedCom,nQtdDemAux)
						oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32406,WmsFmtMsg(STR0011,{{"[VAR01]",AllTrim(cProduto)}}),STR0012) // "A quantidade demandada para o Produto [VAR01] ultrapassa o saldo solicitado no Pedido de Compra." // "Verifique a quantidade demandada para o Produto, bem como se outros Pedidos de Venda ou Planos de Distribuição já estão consumindo o saldo do Pedido de Compra."
						Return .F.
					EndIf
				EndIf

				oModelGrid:LoadValue("D0M_QTDDE2",ConvUm(cProduto,nQtdDem,0,2))

			EndIf

		Next nI

		// Atualiza o status de acordo com o que já foi distribuído e previne error.log MVC
		If lQtdDist
			If lQtdParc
				oModelFlds:LoadValue("D0L_STATUS","2")
			Else
				oModelFlds:LoadValue("D0L_STATUS","3")
			EndIf
		Else
			oModelFlds:LoadValue("D0L_STATUS","1")
		EndIf

	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_DELETE

		For nI := 1 To oModelGrid:Length()

			oModelGrid:GoLine(nI)

			If QtdComp(oModelGrid:GetValue("D0M_QTDDIS")) > 0
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSME32407,STR0013,WmsFmtMsg(STR0014,{{"[VAR01]",cItem}})) // "Não é permitido excluir um Plano de Distribuição que contenha itens com quantidade distribuída." // "Estorne o processo de Distribuição do Item [VAR01]."
				Return .F.
			EndIf

		Next nI

	EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} CalcQtdDem
Calcula a quantidade demandada dos produtos com Pedido de Compra informado

@author  Guilherme A. Metzger
@since   19/03/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function CalcQtdDem(aPrdPedCom,cProduto,cFilPedCom,cPedCom,cItPedCom,nQtdDem)
Local nPosPrd := 1

	// Exemplo de aplicação:
	// Foram criados dois lançamentos de 500 UN, com lotes diferentes,
	// para consumir um saldo de 1.000 UN do Pedido de Compra

	If Len(aPrdPedCom) > 0
		nPosPrd := AScan(aPrdPedCom,{|x| x[1]+x[2]+x[3]+x[4] == cProduto+cFilPedCom+cPedCom+cItPedCom})
		If nPosPrd > 0
			aPrdPedCom[nPosPrd,5] += nQtdDem
			Return aPrdPedCom[nPosPrd,5]
		Else
			aAdd(aPrdPedCom,{cProduto,cFilPedCom,cPedCom,cItPedCom,nQtdDem})
		EndIf
	Else
		aAdd(aPrdPedCom,{cProduto,cFilPedCom,cPedCom,cItPedCom,nQtdDem})
	EndIf

Return nQtdDem

//--------------------------------------------------------------------
/*/{Protheus.doc} AvalQtdDem
Avalia se a quantidade demandada para o item, mais o que já existe em
Pedidos de Venda e outros Planos de Distribuição, não ultrapassa a
quantidade solicitada no Pedido de Compra.

@author  Guilherme A. Metzger
@since   16/03/2018
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AvalQtdDem(cCodPln,cFilPedCom,cPedCom,cItPedCom,nQtdDem)
Local cAliasQry := ""
Local cQuery    := ""
Local aTamSX3   := {}
Local lRet      := .T.

	cQuery := "SELECT SUM(SC7.C7_QUANT)   C7_QUANT,"
	cQuery +=       " SUM(PED.C6_QTDVEN)  C6_QTDVEN,"
	cQuery +=       " SUM(PLN.D0M_QTDDEM) D0M_QTDDEM"
	cQuery +=  " FROM "+RetSqlName("SC7")+" SC7"
	cQuery +=  " LEFT JOIN (SELECT C6_FILPED,"
	cQuery +=                    " C6_PEDCOM,"
	cQuery +=                    " C6_ITPC,"
	cQuery +=                    " SUM(SC6.C6_QTDVEN) C6_QTDVEN"
	cQuery +=               " FROM "+RetSqlName("SC6")+" SC6"
	cQuery +=              " WHERE SC6.C6_FILIAL  = '"+xFilial("SC6")+"'"
	cQuery +=                " AND SC6.C6_FILPED  = '"+cFilPedCom+"'"
	cQuery +=                " AND SC6.C6_PEDCOM  = '"+cPedCom+"'"
	cQuery +=                " AND SC6.C6_ITPC    = '"+cItPedCom+"'"
	cQuery +=                " AND SC6.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY C6_FILPED,"
	cQuery +=                       " C6_PEDCOM,"
	cQuery +=                       " C6_ITPC) PED"
	cQuery +=    " ON PED.C6_FILPED = SC7.C7_FILIAL"
	cQuery +=   " AND PED.C6_PEDCOM = SC7.C7_NUM"
	cQuery +=   " AND PED.C6_ITPC   = SC7.C7_ITEM"
	cQuery +=  " LEFT JOIN (SELECT D0M_FILPED,"
	cQuery +=                    " D0M_PEDCOM,"
	cQuery +=                    " D0M_ITPC,"
	cQuery +=                    " SUM(D0M.D0M_QTDDEM) D0M_QTDDEM"
	cQuery +=               " FROM "+RetSqlName("D0M")+" D0M"
	cQuery +=              " WHERE D0M.D0M_FILIAL  = '"+xFilial("D0M")+"'"
	cQuery +=                " AND D0M.D0M_FILPED  = '"+cFilPedCom+"'"
	cQuery +=                " AND D0M.D0M_PEDCOM  = '"+cPedCom+"'"
	cQuery +=                " AND D0M.D0M_ITPC    = '"+cItPedCom+"'"
	cQuery +=                " AND D0M.D0M_CODPLN <> '"+cCodPln+"'"
	cQuery +=                " AND D0M.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY D0M_FILPED,"
	cQuery +=                       " D0M_PEDCOM,"
	cQuery +=                       " D0M_ITPC) PLN"
	cQuery +=    " ON PLN.D0M_FILPED = SC7.C7_FILIAL"
	cQuery +=   " AND PLN.D0M_PEDCOM = SC7.C7_NUM"
	cQuery +=   " AND PLN.D0M_ITPC   = SC7.C7_ITEM"
	cQuery += " WHERE SC7.C7_FILIAL  = '"+cFilPedCom+"'"
	cQuery +=   " AND SC7.C7_NUM     = '"+cPedCom+"'"
	cQuery +=   " AND SC7.C7_ITEM    = '"+cItPedCom+"'"
	cQuery +=   " AND SC7.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	aTamSX3 := TamSX3("C7_QUANT"  ); TCSetField(cAliasQry,"C7_QUANT"  ,"N",aTamSX3[1],aTamSX3[2])
	aTamSX3 := TamSX3("C6_QTDVEN" ); TCSetField(cAliasQry,"C6_QTDVEN" ,"N",aTamSX3[1],aTamSX3[2])
	aTamSX3 := TamSX3("D0M_QTDDEM"); TCSetField(cAliasQry,"D0M_QTDDEM","N",aTamSX3[1],aTamSX3[2])
	If !(cAliasQry)->(Eof())
		If QtdComp((cAliasQry)->C7_QUANT) < QtdComp((cAliasQry)->C6_QTDVEN+(cAliasQry)->D0M_QTDDEM+nQtdDem)
			lRet := .F.
		EndIf
	EndIf
	(cAliasQry)->(DbCloseArea())

Return lRet
