#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCFUCO

Manutencao de Fundos Comuns

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCFUCO(lAuto)
	Local oBrowse	:= Nil
	Private B8MN	:= ""
	Private B8MM	:= ""
	Private B8MS	:= ""
	Default lAuto	:=.F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B6R')
	oBrowse:SetDescription("DIOPS - Fundos Comuns")
	oBrowse:AddLegend( "B6R_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B6R_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B6R_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B6R_FILIAL=B3D->B3D_FILIAL .And. B6R_CODOPE=B3D->B3D_CODOPE .And. B6R_CODOBR=B3D->B3D_CDOBRI .And. B6R_ANOCMP=B3D->B3D_ANO .And. B6R_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCFUCO' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Fundos Comuns", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf


Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"			, 'PlCenFilCri("B6R", B6R->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"		, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //FUCquisar
	aAdd( aRotina, { "Visualizar"		, 'VIEWDEF.PLSMVCFUCO'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"			, 'VIEWDEF.PLSMVCFUCO'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"			, 'VIEWDEF.PLSMVCFUCO'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"			, 'VIEWDEF.PLSMVCFUCO'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"	, 'PLSRDFUCO(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"	, 'CenVldQdMn("19")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"	, 'CenLimpBlc(getTabFUC())'	, 0 , 7 , 0 , NIL } ) //

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B6R

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6R 	:= FWFormStruct( 1, 'B6R', , )
	Local oModel		:= Nil
	Local oEvent  := PLSEVTFUCO():New()

	oModel	:= MPFormModel():New( "DIOPS - Fundos Comuns" )
	oModel:AddFields( 'B6RMASTER', , oStruB6R )
	oModel:GetModel( 'B6RMASTER' ):SetDescription( "DIOPS - Fundos Comuns" )
	oModel:InstallEvent("QDRFUCOM", /*cOwner*/, oEvent)

Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B6R

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCFUCO' )
	Local oStruB6R := FWFormStruct( 2, 'B6R' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B6R' , oStruB6R , 'B6RMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B6R', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B6R', 'DIOPS - FUNDOS COMUNS' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegFUC

Retorna array de regras para validar o quadro Fundo Comum

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegFUC()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao de Blocos
	// Compara Somatório dos Itens por Produtos com o total da Conta Contábil respectiva
	aAdd( aRegrasBl, {"FC01","   ","PLVLDFUC01()", "Tipo de fundo FCP diverge do total das contas contábeis (Credor/Devedor).", "Verifique a somatória dos saldos FCP e o valor contabilizado nas contas 12391X082 e 2138X9082."," AND B6R_TIPO = 'FCP' " })
	aAdd( aRegrasBl, {"FC02","   ","PLVLDFUC02()", "Tipo de fundo FCA diverge do total das contas contábeis (Credor/Devedor).", "Verifique a somatória dos saldos FCA e o valor contabilizado nas contas 1241X9082 e 214889082."," AND B6R_TIPO = 'FCA' " })

	// No momento nao foi encontrada uma forma de validar as regras, portanto ficamos aguardando posicionamento da Marcia - 12/12/2017.
	aRegras := { getTabFUC(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabFUC

Retorna tabela do quadro FUNDOS COMUNS

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function getTabFUC()
Return "B6R"
