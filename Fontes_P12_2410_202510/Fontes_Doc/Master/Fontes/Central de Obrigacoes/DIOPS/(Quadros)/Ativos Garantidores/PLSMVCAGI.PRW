#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCAGI

Manutencao de Ativos Garantidores Imobiliários

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCAGI(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8C')
	oBrowse:SetDescription("DIOPS - Ativos Garantidores Imobiliários") //Beneficiarios
	oBrowse:AddLegend( "B8C_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8C_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8C_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B8C_FILIAL=B3D->B3D_FILIAL .And. B8C_CODOPE=B3D->B3D_CODOPE .And. B8C_CODOBR=B3D->B3D_CDOBRI .And. B8C_ANOCMP=B3D->B3D_ANO .And. B8C_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCAGI' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Atv. Gar. - Imobiliario", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	Endif

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8C", B8C->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'								, 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCAGI'					, 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCAGI'					, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCAGI'					, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir registro"		, 'VIEWDEF.PLSMVCAGI'					, 0 , 5 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDAGIM(.F.)'						, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("3")'						, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabAGI())'				, 0 , 7 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8C

@return oModel	objeto model criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8C 	:= FWFormStruct( 1, 'B8C', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8CMASTER', 'B8C_CODOPE', 'B8C_CODOBR', 'B8C_CDCOMP', 'B8C_ANOCMP', 'B8C_REFERE', 'B8C_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - Ativos Garantidores Imobiliario", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8CMASTER', , oStruB8C )
	oModel:GetModel( 'B8CMASTER' ):SetDescription( "DIOPS - Ativos Garantidores Imobiliario" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8C

@return oView	objeto view criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCAGI' )
	Local oStruB8C := FWFormStruct( 2, 'B8C' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8C' , oStruB8C , 'B8CMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8C', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8C', 'DIOPS - Ativos Garantidores Imobiliario' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabAGI

Retorna tabela do quadro Ativos Garantidores Imobiliario

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabAGI()
Return "B8C"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Ativos Garantidores Imobiliario

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegAGI()

	local aRegrasAll := {}
	local aRegrasAGI := {}
	local aRegras := {}

	//Nao existem regras de validacao para o quadro ativos garantidores imobiliario
	aAdd( aRegrasAll, {"AG01","    ","AllwaysTrue()", "","", "" } )
	aRegras := { GetTabAGI(), aRegrasAll, aRegrasAGI }

Return aRegras

Function B3DRefere()
	Local cRefere := ""

	cRefere := Subs(B3D->B3D_REFERE,1,1)
	cRefere := AllTrim(cRefere)
	cRefere := StrZero(Val(cRefere),2)

Return cRefere