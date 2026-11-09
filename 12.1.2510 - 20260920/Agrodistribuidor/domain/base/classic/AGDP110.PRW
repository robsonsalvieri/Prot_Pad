#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP110.CH"

/*/{Protheus.doc} AGDP110
Cadastro de complemento da tabela de preço para o Agro (NE8)
@type function
@author  claudineia.reinert
@since   17/03/2026
@version P12
/*/
Function AGDP110()
    If !FWAliasInDic("NE8")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NE8")
	oFWMBrowse:SetDescription(FwX2Nome("NE8"))
	oFWMBrowse:DisableDetails()
	oFWMBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Opções do menu da rotina AGDP110
@type function
@version P12
@author claudineia.reinert
@since 17/03/2026
/*/
Static Function MenuDef()
    Local aRotina := {}
    Local cAction := "VIEWDEF.AGDP110"

    ADD OPTION aRotina TITLE STR0001    ACTION cAction OPERATION 2 ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0002    ACTION cAction OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0003    ACTION cAction OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0004    ACTION cAction OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@type function
@version P12
@author claudineia.reinert
@since 17/03/2026
/*/
Static Function ModelDef()
    Local oModel    := MPFormModel():New('AGDP110')
    Local oStruNE8  := FWFormStruct(1, 'NE8')
    Local oEvent    := AGDP110EVT():New()

    // Adição dos componentes ao modelo
    oModel:AddFields('AGDP110_NE8', /*cOwner*/, oStruNE8)
    oModel:SetPrimaryKey({"NE8_FILIAL", "NE8_CODTAB"})
    oModel:SetDescription(FwX2Nome("NE8"))
    
    oModel:InstallEvent("AGDP110EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
View da rotina
@type function
@version  P12
@author claudineia.reinert
@since 17/03/2026
/*/
Static Function ViewDef()
    Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDP110")
	Local oStructNE8 := FwFormStruct(2, "NE8")

	oView:SetModel(oModel)
	oStructNE8:RemoveField("NE8_FILIAL")
	oView:AddField("VIEW_NE8", oStructNE8, "AGDP110_NE8")
	oView:EnableTitleView("VIEW_NE8")
	oView:SetCloseOnOk({ || .T.})
    oView:ShowUpdateMsg(.F.)

Return oView

/*/{Protheus.doc} AGDP110WHN
Função para When de campo - dicionario de dados 
@type function
@version  P12
@author claudineia.reinert
@since 19/03/2026
@return logical, indica se o campo será habilitado ou não 
/*/
Function AGDP110WHN()
    Local lRet := .T.
	Local cReadVar := ReadVar()

    If "NE8_CODTAB" $ cReadVar .AND. (ALTERA .OR. (INCLUI .AND. IsInCallStack("AGDI110")))
		lRet := .F.
	EndIf

Return lRet



/*/{Protheus.doc} IntegDef
Integradef
@type function
@version 12
@author lindembergson.pacheco
@since 24/03/2026
@param xEnt, variant, Obejto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno
/*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

Return AGDIP110(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
