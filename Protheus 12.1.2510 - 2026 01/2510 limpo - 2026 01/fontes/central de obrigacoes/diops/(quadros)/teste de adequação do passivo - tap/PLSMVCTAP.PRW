#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCTAP

Manutencao de MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCTAP()

	Local oBrowse := Nil
	Local lAuto   := Isblind()

	If FWAliasInDic("B89", .F.)
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B89')
		oBrowse:SetDescription("DIOPS - TESTE DE ADEQUAÇÃO DO PASSIVO - TAP")
		oBrowse:AddLegend( "B89_STATUS=='1'", "YELLOW", "Validacao Pendente" )
		oBrowse:AddLegend( "B89_STATUS=='2'", "GREEN", "Valido" )
		oBrowse:AddLegend( "B89_STATUS=='3'", "RED", "Invalido" )
		oBrowse:SetFilterDefault( "B89_FILIAL=B3D->B3D_FILIAL .And. B89_CODOPE=B3D->B3D_CODOPE .And. B89_CODOBR=B3D->B3D_CDOBRI .And. B89_ANOCMP=B3D->B3D_ANO .And. B89_CDCOMP=B3D->B3D_CODIGO" )
		oBrowse:SetMenuDef( 'PLSMVCTAP' )

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Teste Adequação do Passivo", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		If !lAuto
			oBrowse:Activate()
		EndIf
	else
		MsgAlert("Tabela B89 não existe. Favor aplicar o pacote 006231")

	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"		  , 'PlCenFilCri("B89", B89->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"	  , 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"	  , 'VIEWDEF.PLSMVCTAP'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"		  , 'VIEWDEF.PLSMVCTAP'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"		  , 'VIEWDEF.PLSMVCTAP'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro", 'PLSRDTAP(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro" , 'CenVldQdMn("22")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro" , 'CenLimpBlc(getTabTAP())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"		  , 'VIEWDEF.PLSMVCTAP'	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B89

@return oModel	objeto model criado

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB89 	:= FWFormStruct( 1, 'B89', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B89MASTER', 'B89_CODOPE', 'B89_CODOBR', 'B89_CDCOMP', 'B89_ANOCMP', 'B89_REFERE', 'B89_STATUS') }

	oModel	:= MPFormModel():New( " DIOPS - TESTE DE ADEQUAÇÃO DO PASSIVO - TAP", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B89MASTER', , oStruB89 )
	oModel:GetModel( 'B89MASTER' ):SetDescription( "DIOPS - TESTE DE ADEQUAÇÃO DO PASSIVO - TAP" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B89
@return oView objeto view criado
@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'PLSMVCTAP' )
	Local oStruB89 := FWFormStruct( 2, 'B89' )
	Local oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B89' , oStruB89 , 'B89MASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B89', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B89', 'DIOPS - TESTE DE ADEQUAÇÃO DO PASSIVO - TAP' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegTAP

Retorna array de regras para validar o quadro MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getRegTAP()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao Registro a Registro
	aAdd( aRegrasBl,{"TA01","   ","PLVLDTA01()", "Quadro sem validação.", "Quadro sem validação.", ""} )
	aRegras := { getTabTAP(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabTAP

Retorna tabela do quadro MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getTabTAP()
return "B89"
