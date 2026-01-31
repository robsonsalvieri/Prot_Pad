#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCRES

Manutencao de Responsaveis

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCRES()
	Local oBrowse		:= Nil
	Local lAuto         := Isblind()
	Private CENUF		:= ""
	Private CENPAIS	:= ""
	Private CENCAR	:= ""

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8Y')
	oBrowse:SetDescription("DIOPS - Responsaveis") //Responsaveis
	oBrowse:SetMenuDef( 'PLSMVCRES' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS - Responsaveis", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCRES'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCRES'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCRES'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCRES'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8Y

@return oModel	objeto model criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8Y 	:= FWFormStruct( 1, 'B8Y', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "DIOPS - Responsaveis", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8YMASTER', , oStruB8Y )
	oModel:GetModel( 'B8YMASTER' ):SetDescription( "DIOPS - Responsaveis" )

	//Seta Chaves primarias
	oModel:SetPrimaryKey({'B8Y_FILIAL','B8Y_CODOPE','B8Y_TPRESP','B8Y_TPPESS','B8Y_CPFCNP'})

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8Y

@return oView	objeto view criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCRES' )
	Local oStruB8Y := FWFormStruct( 2, 'B8Y' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8Y' , oStruB8Y , 'B8YMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B8Y', 'DIOPS - Responsaveis' )


Return oView