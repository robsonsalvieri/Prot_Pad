#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPGRADE.CH"

/*/{Protheus.doc} PCPGRADEEVDEF
Eventos padroes da tela de Grade do PCP
@author brunno.costa
@since 17/01/2019
@version P12
/*/
CLASS PCPGRADEEVDEF FROM FWModelEvent

	DATA lViewGrade   AS LOGICAL
	DATA lExecGrdLine AS LOGICAL
	DATA nTotal       AS NUMERIC

	//Metodos padroes MVC
	METHOD new() CONSTRUCTOR
	METHOD gridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
	METHOD ModelPosVld(oModel, cModelId)

	//Metodos auxiliares
	METHOD getSoma()     //Retorna soma das quantidades digitadas
	METHOD setSoma()     //seta soma das quantidades digitadas
	METHOD refreshView() //Realiza refresh dos componentes da view - com protecao

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe
@author brunno.costa
@since 17/01/2019
@version P12
/*/
METHOD New() CLASS PCPGRADEEVDEF
	::lViewGrade   := .F.
	::lExecGrdLine := .F.
Return

/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Numérico, Linha do grid
@param 04 cAction      , Caracter, Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param 05 cId          , Caracter, nome do campo
@param 06 xValue       , Variável, Novo valor do campo
@param 07 xCurrentValue, Variável, Valor atual do campo
@return lRet, logico, indicador de validacao da linha
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPGRADEEVDEF
	Local lRet     := .T.
	Local nTotal   := 0
	Local cProduto
	Local cGrade
	Local cMascara
	Local nTamRef
	Local nTamLin
	Local nTamCol

	If ::lExecGrdLine .AND. cModelID == "SBV_DETAIL" .AND. cAction == "CANSETVALUE"

		//Prepara variaveis locais
		cGrade    := oSubModel:GetModel():GetModel("SB4_MASTER"):GetValue("B4_COD")
		cMascara  := SuperGetMv("MV_MASCGRD")
		nTamRef   := Val(Substr(cMascara,1,2))
		nTamLin   := Val(Substr(cMascara,4,2))
		nTamCol   := Val(Substr(cMascara,7,2))

		cProduto := Left(cGrade, nTamRef);
					+ Left(oSubModel:GetValue("BV_CHAVE", nLine),nTamLin);
					+ Substring(cId + "  ", 8, nTamCol)
		cProduto := PadR(cProduto, GetSx3Cache("B1_COD", "X3_TAMANHO"))

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(xFilial("SB1")+cProduto))
		    HelpInDark( .F. )	//Habilita a apresentação do Help
			Help(,,'Help',,"Produto não cadastrado: " + cProduto,1,0,,,,,,;
			{"Cadastre o produto no sistema."})
			lRet := .F.
			HelpInDark( .T. )	//Desabilita a apresentação do Help

		EndIf

	ElseIf ::lExecGrdLine .AND. cModelID == "SBV_DETAIL" .AND. cAction == "SETVALUE"

		nTotal := ::getSoma()
		If xCurrentValue < xValue
			nTotal += xValue - xCurrentValue
		ElseIf xCurrentValue > xValue
			nTotal -= xCurrentValue - xValue
		EndIf
		::setSoma(nTotal)

	EndIf
Return lRet

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
Esse evento ocorre uma vez no contexto do modelo principal.
@author brunno.costa
@since 11/06/2019
@version P12
@param oModel  , object    , modelo principal
@param cModelId, characters, ID do submodelo de dados
@return lRet, logico, indicador de validacao do modelo
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPGRADEEVDEF
	Local lRet   := .T.
	Local nSoma
	Local nTotal
	If ::lExecGrdLine
		nSoma  := ::getSoma()
		nTotal := ::nTotal
		If nSoma != nTotal .AND. nTotal != 0
			Help(,,'Help',,STR0003 + cValToChar(nTotal) + STR0004 + cValToChar(nSoma) + "'.",1,0,,,,,,; //"Quantidade digitada (" + ") alterada para '"
					{STR0005}) //"A quantidade 'Total' deve equivaler a soma das quantidades dos itens."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} refreshView
Realiza refresh na view - Protegida
@author brunno.costa
@since 11/06/2019
@version P12
/*/
METHOD refreshView() CLASS PCPGRADEEVDEF
	Local oView
	If ::lViewGrade
		oView := FwViewActive()
		If oView != Nil .AND. oView:IsActive()
			oView:Refresh("V_SB4_MASTER")
			oView:Refresh("V_SBV_DETAIL")
		EndIf
	EndIf
Return

/*/{Protheus.doc} getSoma
Retorna nSUM - Campo da SB4_MASTER
@author brunno.costa
@since 11/06/2019
@version P12
@return nTotal, numero   , retorna o total da tela de grade
/*/
METHOD getSoma() CLASS PCPGRADEEVDEF
	Local nTotal
	Local oModel  := FWModelActive()
	nTotal := oModel:GetModel("SB4_MASTER"):GetValue("nSUM")
Return nTotal

/*/{Protheus.doc} setSoma
Seta nSUM - Campo da SB4_MASTER
@author brunno.costa
@since 11/06/2019
@version P12
@param 01 - nTotal, numero, valor para atualizacao do total da tela de grade
/*/
METHOD setSoma(nTotal) CLASS PCPGRADEEVDEF
	Local oModel  := FWModelActive()
	oModel:GetModel("SB4_MASTER"):LoadValue("nSUM", nTotal)
Return