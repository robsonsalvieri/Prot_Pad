#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCREP

Manutencao de Operadoras

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCREP()
	Local oBrowse		:= Nil
	Local lAuto         := Isblind()
	Private CENUF		:= ""
	Private CENPAIS	    := ""
	Private CENCAR	    := ""

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8N')
	oBrowse:SetDescription("DIOPS - Representantes") //Operadoras
	oBrowse:SetMenuDef( 'PLSMVCREP' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS Representantes", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCREP'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCREP'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCREP'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCREP'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8N

@return oModel	objeto model criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8N 	:= FWFormStruct( 1, 'B8N', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "DIOPS - Representantes", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8NMASTER', , oStruB8N )
	oModel:GetModel( 'B8NMASTER' ):SetDescription( "DIOPS - Representantes" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8N

@return oView	objeto view criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCREP' )
	Local oStruB8N := FWFormStruct( 2, 'B8N' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8N' , oStruB8N , 'B8NMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B8N', 'DIOPS - Representantes' )

Return oView