#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCINA

Inadimplência

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCINA(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	If !lAuto .And. Val(B3D->B3D_ANO) <=2021
		MsgInfo("O Quadro de Inadimplência somente deve ser utilizado para gerar movimentações para compromissos acima de 2021")
		Return .F.
	EndIf

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B7W')
	oBrowse:SetDescription("DIOPS - Inadimplência Administradora de Benefícios") //Inadimplência
	oBrowse:AddLegend( "B7W_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B7W_STATUS=='2'", "GREEN" ,	"Valido" )
	oBrowse:AddLegend( "B7W_STATUS=='3'", "RED"   , "Invalido" )
	oBrowse:SetFilterDefault( "B7W_FILIAL=B3D->B3D_FILIAL .And. B7W_CODOPE=B3D->B3D_CODOPE .And. B7W_CODOBR=B3D->B3D_CDOBRI .And. B7W_ANOCMP=B3D->B3D_ANO .And. B7W_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef('CENMVCINA')

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS - Inadimplência Administradora de Benefícios", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definicao das opcoes do menu

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B7W", B7W->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCINA'	, 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMVCINA'	, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.CENMVCINA'	, 0 , 5 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'CENRINADI(.F.)'		, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("26")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabINA())'	, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMVCINA'   	, 0 , 4 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B7W

@return oModel	objeto model criado

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB7W 	:= FWFormStruct( 1, 'B7W', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B7WMASTER', 'B7W_CODOPE', 'B7W_CODOBR', 'B7W_CDCOMP', 'B7W_ANOCMP', 'B7W_REFERE', 'B7W_STATUS') }
	Local aAuxB7W       := {}

	aAuxB7W:= FwStruTrigger(;
		'B7W_PMPAUT'     ,;
		'B7W_PERCAP'     ,;
		''               ,;
		.F.              ,;
		'B7W'            ,;
		1                ,;
		'M->B7W_PMPAUT == "2"',;
		'')

	oStruB7W:AddTrigger( aAuxB7W[1], aAuxB7W[2], aAuxB7W[3], aAuxB7W[4])

	oModel	:= MPFormModel():New( "DIOPS - Inadimplência Administradora de Benefícios", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B7WMASTER', , oStruB7W )
	oModel:GetModel( 'B7WMASTER' ):SetDescription( "DIOPS - Inadimplência Administradora de Benefícios" )
	oModel:SetPrimaryKey({'B7W_FILIAL','B7W_CODOPE', 'B7W_CODOBR', 'B7W_CDCOMP', 'B7W_ANOCMP', 'B7W_REFERE'})


Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B7W

@return oView	objeto view criado

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCINA' )
	Local oStruB7W := FWFormStruct( 2, 'B7W' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B7W' , oStruB7W , 'B7WMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B7W', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B7W', 'DIOPS - Inadimplência Administradora de Benefícios' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabIDSA

Retorna tabela do quadro Inadimplência

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabINA()
Return "B7W"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Inadimplência

@author jose.paulo
@since 14/03/2022
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegIna()

	local aRegrasAll := {}
	local aRegras := {}
	local aRegrasIna := {}//Passar a clausula where pronta

	aAdd( aRegrasAll, {"INA01","    ","AllwaysTrue()", "","", "" } )
	aAdd( aRegrasIna, {"INA02","    ","AllwaysTrue()", "","", "" } )

	aRegras := { GetTabINA(), aRegrasAll,aRegrasIna}

Return aRegras
