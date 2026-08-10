#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB2Y

Manutencao de Operadoras

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCB2Y(cFiltro,lAutom)
	Local cDescript := "DMED - Despesas Analíticas"
	Local oPnl
	Local oBrowse
	Local cAlias	:= "B2Y"

	Private oDlgB2Y
	Private aRotina	:= {}

	Default cFiltro	:= 	""

	(cAlias)->(dbSetOrder(1))

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:SetMenuDef( 'CENMVCB2Y' )
	oBrowse:SetProfileID( 'CENMVCB2Y' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Despesas DMED Analiticas", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAutom
		oBrowse:Activate()
	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCB2Y'	, 0 , 2 , 0 , NIL } ) //Visualizar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B2Y

@return oModel	objeto model criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB2Y 	:= FWFormStruct( 1, 'B2Y', , )
	Local oModel		:= Nil

	oModel := MPFormModel():New( "DMED - Despesas Analíticas", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B2YMASTER', , oStruB2Y )
	oModel:GetModel( 'B2YMASTER' ):SetDescription( "DMED - Despesas Analíticas" )
	oModel:SetPrimaryKey({'B2Y_FILIAL','B2Y_CODOPE','B2Y_CPFTIT','B2Y_CPFDEP','B2Y_DTNASD','B2Y_NOMDEP','B2Y_CPFCGC','B2Y_CHVDES','B2Y_COMPET','B2Y_EXCLU'})
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B2Y

@return oView	objeto view criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCB2Y' )
	Local oStruB2Y := FWFormStruct( 2, 'B2Y' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B2Y' , oStruB2Y , 'B2YMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B2Y', 'DMED - Despesas Analíticas' )

Return oView


Function CENTPDES()
	Local cRet 	:= "1=Despesa;2=Reembolso"

Return cRet
