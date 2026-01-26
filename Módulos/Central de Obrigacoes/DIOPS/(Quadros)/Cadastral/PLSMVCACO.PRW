#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCACO

Manutencao de Acionistas

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCACO()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()
	Private B8SN	:= ""
	Private B8SM	:= ""
	Private B8SS	:= ""
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8S')
	oBrowse:SetDescription("DIOPS - Acionistas") //Operadoras
	oBrowse:SetMenuDef( 'PLSMVCACO' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Manutenção de Acionistas", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCACO'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCACO'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCACO'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCACO'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8S

@return oModel	objeto model criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8S 	:= FWFormStruct( 1, 'B8S', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "DIOPS - Acionistas", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8SMASTER', , oStruB8S )
	oModel:GetModel( 'B8SMASTER' ):SetDescription( "DIOPS - Acionistas" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8S

@return oView	objeto view criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCACO' )
	Local oStruB8S := FWFormStruct( 2, 'B8S' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8S' , oStruB8S , 'B8SMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B8S', 'DIOPS - Acionistas' )

Return oView