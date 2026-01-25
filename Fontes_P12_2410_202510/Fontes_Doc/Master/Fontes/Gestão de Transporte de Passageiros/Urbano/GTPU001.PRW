#INCLUDE 'TOTVS.ch'
#INCLUDE 'GTPU001.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU001
	Forma de pagamento - Urbano
	
	@author Breno Gomes
	@since 01/12/2024
	@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU001()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Forma de pagamento"
	oBrowse:SetAlias("H6R")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Breno Gomes
@since 01/12/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU001", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU001", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU001", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU001", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU001", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 10/09/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := nil
	Local oStrH6R   := FWFormStruct(1,'H6R')
	Local bPosValid  := {|oModel| PosValid(oModel)}

	oModel := MPFormModel():New('GTPU001', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('H6RMASTER',/*cOwner*/,oStrH6R,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001)// "Forma de pagamento"
	oModel:GetModel('H6RMASTER'):SetDescription(STR0001) //"Forma de pagamento"

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 13/09/2021
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView   := FWFormView():New()
	Local oModel  := FwLoadModel('GTPU001')
	Local oStrH6R := FWFormStruct(2, 'H6R')

	oView:SetModel(oModel)
	oView:AddField('VIEW_H6R' ,oStrH6R,'H6RMASTER')
	oView:SetDescription(STR0001) //"Forma de pagamento"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid
Função de validação

@type Static Function
@author karyna.martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)  
 
	Local oMdl 		:= oModel:GetModel()
	Local cMsgErro	:= ""
	Local cMsgSol	:= ""
	Local lRet 		:= .T.
	
	If !Empty(oMdl:GetValue('H6RMASTER', 'H6R_CODH7O'))

		H7O->( DbSetOrder(1) )
		If H7O->( DbSeek(xFilial("H7O") + oMdl:GetValue('H6RMASTER', 'H6R_CODH7O')) ) .And. H7O->H7O_TIPO == '3' .And. Empty(oMdl:GetValue('H6RMASTER', 'H6R_TIPO'))
			
			lRet     := .F.
			cMsgErro := STR0010 //"O tipo de receita e despesa não foi preenchido"
			cMsgSol	 := STR0011 //"É necessário informar o tipo para esse código de receita e despesa"				

		ElseIf H7O->( DbSeek(xFilial("H7O") + oMdl:GetValue('H6RMASTER', 'H6R_CODH7O')) ) .And. H7O->H7O_TIPO == '3' .And. H7O->H7O_AGLUTI

			If H7O->( DbSeek(xFilial("H7O") + H7O->H7O_CODRD ) ) .And. H7O->H7O_TIPO == oMdl:GetValue('H6RMASTER', 'H6R_TIPO')  

				lRet     := .F.
				cMsgErro := STR0012 //"O tipo de receita e despesa é o mesmo do código que aglutina valores no fechamento de caixa"
				cMsgSol	 := STR0013 //"É necessário escolher outra opção de tipo de receita e despesa"

			EndIf

		EndIf

	EndIf

	If !lRet
		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU001PosVld", cMsgErro, cMsgSol)
	EndIf

Return lRet

