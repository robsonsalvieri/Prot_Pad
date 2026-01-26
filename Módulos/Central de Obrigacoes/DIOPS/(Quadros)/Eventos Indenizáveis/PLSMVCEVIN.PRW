#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCEVIN

Manutencao de EVENTOS INDENIZAVEIS

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCEVIN()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8L')
	oBrowse:SetDescription("DIOPS - EVENTOS INDENIZAVEIS")
	oBrowse:AddLegend( "B8L_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8L_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8L_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B8L_FILIAL=B3D->B3D_FILIAL .And. B8L_CODOPE=B3D->B3D_CODOPE .And. B8L_CODOBR=B3D->B3D_CDOBRI .And. B8L_ANOCMP=B3D->B3D_ANO .And. B8L_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCEVIN' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Eventos Indenizáveis", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8L", B8L->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCEVIN'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCEVIN'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCEVIN'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDEVIN(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("11")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabEvIn())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCEVIN'   	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8L

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8L 	:= FWFormStruct( 1, 'B8L', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8LMASTER', 'B8L_CODOPE', 'B8L_CODOBR', 'B8L_CDCOMP', 'B8L_ANOCMP', 'B8L_REFERE', 'B8L_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - EVENTOS INDENIZAVEIS", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8LMASTER', , oStruB8L )
	oModel:GetModel( 'B8LMASTER' ):SetDescription( "DIOPS - EVENTOS INDENIZAVEIS" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8L

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCEVIN' )
	Local oStruB8L := FWFormStruct( 2, 'B8L' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8L' , oStruB8L , 'B8LMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8L', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8L', 'DIOPS - EVENTOS INDENIZAVEIS' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegEVI

Retorna array de regras para validar o quadro EVENTOS INDENIZAVEIS

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegEvIn()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao Registro a Registro
	aAdd( aRegrasAll,{"EI01","   ","PLVLDEVI01()", "O codigo do tipo de evento utilizado é inválido.", "Verifique o código do tipo de evento deste item.", ""} )
	aAdd( aRegrasBl, {"EI02","   ","PLVLDEVI02()", "Somatório dos novos avisos de Eventos do trimestre não confere com o total das contas contábeis.", "Verifique a somatória dos novos avisos de Eventos do trimestre e o valor contabilizado nas respectivas contas."," AND B8L_CODIGO BETWEEN '33' AND '46' " } )
	aAdd( aRegrasBl, {"EI03","   ","PLVLDEVI03()", "Somatório de Baixa por Glosa reconhecidas do trimestre não confere com o total das contas contábeis.", "Verifique a somatória das Baixas por Glosa do trimestre e o valor contabilizado nas respectivas contas."," AND B8L_CODIGO BETWEEN '47' AND '60' " } )
	aAdd( aRegrasBl, {"EI04","   ","PLVLDEVI04()", "Somatório de Outras Recuperações reconhecidas do trimestre não confere com o total das contas contábeis.", "Verifique a somatória de Outras Recuperações Conhecidas do trimestre e o valor contabilizado nas respectivas contas."," AND B8L_CODIGO BETWEEN '65' AND '78' " } )
	aAdd( aRegrasBl, {"EI05","   ","PLVLDEVI05()", "Somatório da PEONA do trimestre não confere com o total das contas contábeis.", "Verifique a somatória da PEONA do trimestre e o valor contabilizado nas respectivas contas."," AND B8L_CODIGO = '79' " } )
	aRegras := { getTabEvIn(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabEVI

Retorna tabela do quadro EVENTOS INDENIZAVEIS

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabEvIn()
return "B8L"
