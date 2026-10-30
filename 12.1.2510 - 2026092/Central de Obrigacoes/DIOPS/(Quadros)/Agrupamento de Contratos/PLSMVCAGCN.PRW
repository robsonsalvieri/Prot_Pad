#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCAGCN

Manutencao de AGRUPAMENTO DE CONTRATOS

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCAGCN()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8K')
	oBrowse:SetDescription("DIOPS - AGRUPAMENTO DE CONTRATOS")
	oBrowse:AddLegend( "B8K_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8K_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8K_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B8K_FILIAL=B3D->B3D_FILIAL .And. B8K_CODOPE=B3D->B3D_CODOPE .And. B8K_CODOBR=B3D->B3D_CDOBRI .And. B8K_ANOCMP=B3D->B3D_ANO .And. B8K_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCAGCN' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Agrupamento Contratos", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8K", B8K->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCAGCN'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCAGCN'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCAGCN'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprime Quadro"		, 'PLSRDAGCN(.F.)'		, 0 , 7 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("12")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabAGCo())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCAGCN'   	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8K

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8K 	:= FWFormStruct( 1, 'B8K', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8KMASTER', 'B8K_CODOPE', 'B8K_CODOBR', 'B8K_CDCOMP', 'B8K_ANOCMP', 'B8K_REFERE', 'B8K_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - AGRUPAMENTO DE CONTRATOS", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8KMASTER', , oStruB8K )
	oModel:GetModel( 'B8KMASTER' ):SetDescription( "DIOPS - AGRUPAMENTO DE CONTRATOS" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8K

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCAGCN' )
	Local oStruB8K := FWFormStruct( 2, 'B8K' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8K' , oStruB8K , 'B8KMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8K', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8K', 'DIOPS - AGRUPAMENTO DE CONTRATOS' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegAGC

Retorna array de regras para validar o quadro AGRUPAMENTO DE CONTRATOS

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegAGC()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Compara Somatório dos Itens por Produtos com o total da Conta Contábil respectiva
	aAdd( aRegrasBl, {"AC01","   ","PLVLDAGC01()", "Total infomado para Pl.Col. Adesão ref. a contraprestações emitida não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 31111104."," " })
	aAdd( aRegrasBl, {"AC02","   ","PLVLDAGC02()", "Total infomado para Pl.Col. Adesão ref. a Eventos/Sinistros não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 411X1104."," " })
	aAdd( aRegrasBl, {"AC03","   ","PLVLDAGC03()", "Total infomado para Pl.Col. Empresarial ref. a contraprestações emitidas não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 31111106."," " })
	aAdd( aRegrasBl, {"AC04","   ","PLVLDAGC04()", "Total infomado para Pl.Col. Empresarial ref. a Eventos/Sinistros não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 411X1106."," " })
	aAdd( aRegrasBl, {"AC05","   ","PLVLDAGC05()", "Total infomado para Pl.Col. Adesão ref. a Corresponsabilidade Cedida não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 31171104."," " })
	aAdd( aRegrasBl, {"AC06","   ","PLVLDAGC06()", "Total infomado para Pl.Col. Empresarial ref. a Corresponsabilidade Cedida não confere com o Balancete.", "Verifique a somatória dos itens  e o valor contabilizado na conta 31171106."," " })

	aRegras := { getTabAGCo(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabAGCo

Retorna tabela do quadro AGRUPAMENTO DE CONTRATOS

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabAGCo()
return "B8K"