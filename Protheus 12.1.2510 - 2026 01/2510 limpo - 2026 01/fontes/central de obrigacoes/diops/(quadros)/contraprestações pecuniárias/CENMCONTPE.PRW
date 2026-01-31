#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMCONTPE

Manutencao de Contraprestações Pecuniárias / Prêmios por Período de Cobertura

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CENMCONTPE()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	If FWAliasInDic("B37", .F.)

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B37')
		oBrowse:SetDescription("Contraprestações Pecuniárias")
		oBrowse:AddLegend( "B37_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
		oBrowse:AddLegend( "B37_STATUS=='2'", "GREEN",	"Valido" )
		oBrowse:AddLegend( "B37_STATUS=='3'", "RED",		"Invalido" )
		oBrowse:SetFilterDefault( "B37_FILIAL=B3D->B3D_FILIAL .And."+;
			" B37_CODOPE=B3D->B3D_CODOPE .And."+;
			" B37_CODOBR=B3D->B3D_CDOBRI .And."+;
			" B37_ANOCMP=B3D->B3D_ANO .And."+;
			" B37_CDCOMP=B3D->B3D_CODIGO" )
		oBrowse:SetMenuDef( 'CENMCONTPE' )

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Contraprestações Pecuniárias", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		If !lAuto
			oBrowse:Activate()
		EndIf
	else
		MsgAlert("Tabela B37 não existe. Favor aplicar o pacote 006231")

	EndIf
Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B37", B37->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMCONTPE'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMCONTPE'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMCONTPE'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.CENMCONTPE'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRCTPE(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("23")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabCtPe())'	, 0 , 7 , 0 , NIL } ) //Imprimir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B37

@return oModel	objeto model criado

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB37 	:= FWFormStruct( 1, 'B37', , )
	Local oModel		:= Nil
	Local oEvent  := CENEVTCOPE():New()

	oModel	:= MPFormModel():New( "DIOPS - Contraprestações Pecuniárias / Prêmios por Período de Cobertura")
	oModel:AddFields( 'B37MASTER', , oStruB37 )
	oModel:GetModel( 'B37MASTER' ):SetDescription( "Contraprestações Pecuniárias" )
	oModel:SetPrimaryKey({'B37_FILIAL','B37_CODOPE','B37_CODOBR','B37_ANOCMP','B37_CDCOMP','B37_PERCOB','B37_PLANO'})
	oModel:InstallEvent("QDRCONTPE", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B37

@return oView	objeto view criado

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMCONTPE' )
	Local oStruB37 := FWFormStruct( 2, 'B37' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B37' , oStruB37 , 'B37MASTER' )

	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:SetOwnerView( 'VIEW_B37', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B37', 'Contraprestações Pecuniárias' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCtPe

Retorna tabela do quadro Contraprestações Pecuniárias / Prêmios por Período de Cobertura

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCtPe()
Return "B37"


