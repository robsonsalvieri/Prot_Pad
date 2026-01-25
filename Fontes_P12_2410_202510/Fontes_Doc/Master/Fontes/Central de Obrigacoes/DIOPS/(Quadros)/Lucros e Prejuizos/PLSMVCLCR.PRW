#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCLCR

Manutencao de Lucros e Prejuízos

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCLCR(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8E')
	oBrowse:SetDescription("DIOPS - Lucros e Prejuízos") //Lucros e Prejuizos
	oBrowse:AddLegend( "B8E_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8E_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8E_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "B8E_FILIAL=B3D->B3D_FILIAL .And. B8E_CODOPE=B3D->B3D_CODOPE .And. B8E_CODOBR=B3D->B3D_CDOBRI .And. B8E_ANOCMP=B3D->B3D_ANO .And. B8E_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCLCR' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS - Lucros e Prejuízos", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definicao das opcoes do menu

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8E", B8E->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCLCR'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCLCR'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCLCR'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDLCRP(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("6")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabLCR())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCLCR'   	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8E

@return oModel	objeto model criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8E 	:= FWFormStruct( 1, 'B8E', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B8EMASTER', 'B8E_CODOPE', 'B8E_CODOBR', 'B8E_CDCOMP', 'B8E_ANOCMP', 'B8E_REFERE', 'B8E_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - Lucros e Prejuizos", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B8EMASTER', , oStruB8E )
	oModel:GetModel( 'B8EMASTER' ):SetDescription( "DIOPS - Lucros e Prejuizos" )
	oModel:SetPrimaryKey({'B8E_FILIAL','B8E_CODOPE','B8E_CODOBR','B8E_ANOCMP','B8E_CDCOMP','B8E_DESCRI'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8E

@return oView	objeto view criado

@author everton.mateus
@since 29/03/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCLCR' )
	Local oStruB8E := FWFormStruct( 2, 'B8E' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8E' , oStruB8E , 'B8EMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8E', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8E', 'DIOPS - Lucros e Prejuizos' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabIDSA

Retorna tabela do quadro Idade dos Saldos Ativo

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabLCR()
Return "B8E"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Lucros e Prejuizos

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegLCR()

	local aRegrasAll := {}
	local aRegrasLCR := {}//Passar a clausula where pronta
	local aRegras := {}

	aAdd( aRegrasAll, {"LCR1","    ","LucrPrej01()", "O total do quadro Lucros e Prejuízos não corresponde ao valor da conta contábil.",	"Verifique o valor da conta contábil 256 - LUCROS/PREJUÍZOS-SUPERÁVITS/DÉFICITS ACUMULADOS ou RESULTADO", "" } )
	aAdd( aRegrasAll,{"LCR2","    ","LucrPrej02()", "Movimentação de Lucros e Prejuízos é Redutora, o valor deverá ser menor ou igual a zero.", "Verificar se a movimentação do Lucros e Prejuízos é Redutora, esses codigos tem o sinal (-) e precede o valor.", ""} )

	aRegras := { GetTabLCR(), aRegrasAll, aRegrasLCR }

Return aRegras