#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCMUN

Manutencao de Municipios IBGE

@author timoteo.bega
@since 13/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCMUN(lAuto)
	Local oBrowse	:= Nil
	Private CENUF	:= ""

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8W')
	oBrowse:SetDescription("DIOPS - Municipios IBGE")
	oBrowse:SetMenuDef( 'PLSMVCMUN' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Manutenção de Municípios IBGE", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 13/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCMUN(.F.)'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCMUN(.F.)'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCMUN(.F.)'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCMUN(.F.)'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8W

@return oModel	objeto model criado

@author timoteo.bega
@since 13/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8W 	:= FWFormStruct( 1, 'B8W', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "DIOPS - Municipios IBGE", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8WMASTER', , oStruB8W )
	oModel:GetModel( 'B8WMASTER' ):SetDescription( "DIOPS - Municipios IBGE" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8W

@return oView	objeto view criado

@author timoteo.bega
@since 13/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCMUN' )
	Local oStruB8W := FWFormStruct( 2, 'B8W' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8W' , oStruB8W , 'B8WMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B8W', 'DIOPS - Municipios IBGE' )

Return oView