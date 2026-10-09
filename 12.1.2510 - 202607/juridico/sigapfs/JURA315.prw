#INCLUDE "JURA315.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA315
URLs integração LD

@author Abner Fogaça de Oliveira
@since  08/11/2023
/*/
//-------------------------------------------------------------------
Function JURA315()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0006) // URLs integração LD
	oBrowse:SetAlias("OI9")
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "OI9")
	JurSetBSize(oBrowse)
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

@author Abner Fogaça de Oliveira
@since  08/11/2023
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA315", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA315", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA315", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA315", 0, 5, 0, NIL } ) //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados URLs integração LD

@author Abner Fogaça de Oliveira
@since  08/11/2023
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA315" )
Local oStruct := FWFormStruct( 2, "OI9" )

	JurSetAgrp( 'OI9',, oStruct )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA315_VIEW", oStruct, "OI9MASTER")
	oView:CreateHorizontalBox( "FORMFIELD", 100)
	oView:SetOwnerView( "JURA315_VIEW", "FORMFIELD")
	oView:SetDescription(STR0006) // URLs integração LD
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados URLs integração LD

@author Abner Fogaça de Oliveira
@since  08/11/2023
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOI9 := FWFormStruct(1, "OI9")

	//-----------------------------------------
	// Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA315", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("OI9MASTER", NIL, oStructOI9, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0007) //"Modelo de Dados URLs integração LD"
	oModel:GetModel("OI9MASTER"):SetDescription(STR0006) // URLs integração LD

	JurSetRules( oModel, "OI9MASTER",, "OI9")

Return oModel
