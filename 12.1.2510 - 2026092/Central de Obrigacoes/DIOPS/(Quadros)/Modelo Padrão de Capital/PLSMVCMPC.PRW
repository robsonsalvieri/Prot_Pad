#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCMPC

Manutencao de MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCMPC()

	Local oBrowse := Nil
	Local lAuto   := Isblind()

	If FWAliasInDic("B82", .F.)

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B82')
		oBrowse:SetDescription("DIOPS - MODELO PADRÃO DE CAPITAL")
		oBrowse:AddLegend( "B82_STATUS=='1'", "YELLOW", "Validacao Pendente" )
		oBrowse:AddLegend( "B82_STATUS=='2'", "GREEN", "Valido" )
		oBrowse:AddLegend( "B82_STATUS=='3'", "RED", "Invalido" )
		oBrowse:SetFilterDefault( "B82_FILIAL=B3D->B3D_FILIAL .And. B82_CODOPE=B3D->B3D_CODOPE .And. B82_CODOBR=B3D->B3D_CDOBRI .And. B82_ANOCMP=B3D->B3D_ANO .And. B82_CDCOMP=B3D->B3D_CODIGO" )
		oBrowse:SetMenuDef( 'PLSMVCMPC' )

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("DIOPS - Modelo Padrão de Capital", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		If !lAuto
			oBrowse:Activate()
		EndIf
	else
		MsgAlert("Tabela B82 não existe. Favor aplicar o pacote 006231")

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

	aAdd( aRotina, { "Críticas"		  		, 'PlCenFilCri("B82", B82->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"	  		, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"	  		, 'VIEWDEF.PLSMVCMPC'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"		  		, 'VIEWDEF.PLSMVCMPC'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Incluir Quadro Zerado", 'CENDIOZERO(getTabMPC(),getCmpMPC())'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"		  		, 'VIEWDEF.PLSMVCMPC'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDMPC(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro" 		, 'CenVldQdMn("21")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro" 		, 'CenLimpBlc(getTabMPC())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"		  		, 'VIEWDEF.PLSMVCMPC'	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B82

@return oModel	objeto model criado

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruB82 	:= FWFormStruct( 1, 'B82', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B82MASTER', 'B82_CODOPE', 'B82_CODOBR', 'B82_CDCOMP', 'B82_ANOCMP', 'B82_REFERE', 'B82_STATUS') }

	oModel	:= MPFormModel():New( " DIOPS - MODELO PADRÃO DE CAPITAL ", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B82MASTER', , oStruB82 )
	oModel:GetModel( 'B82MASTER' ):SetDescription( "DIOPS - MODELO PADRÃO DE CAPITAL" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B82
@return oView objeto view criado
@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel( 'PLSMVCMPC' )
	Local oStruB82 := FWFormStruct( 2, 'B82' )
	Local oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B82' , oStruB82 , 'B82MASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B82', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B82', 'DIOPS - MODELO PADRÃO DE CAPITAL' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegMPC

Retorna array de regras para validar o quadro MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getRegMPC()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao Registro a Registro
	aAdd( aRegrasBl,{"MP01","   ","PLVLDMP01()", "Campos Num. Remid V e/ou Num. Remid T com conteúdo inválido.", "O conteúdo dos campos Num.Remid V e Num.Remid T devem ser maior que zero e menor ou igual a 2147483647.", ""} )
	aRegras := { getTabMPC(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabMPC

Retorna tabela do quadro MODELO PADRÃO DE CAPITAL

@author lima.everton
@since 21/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getTabMPC()
return "B82"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabMPC

Retorna Campos do quadro MODELO PADRÃO DE CAPITAL

@author david.juan
@since 06/05/2021
/*/
//--------------------------------------------------------------------------------------------------
function getCmpMPC()
return {"B82_SMRMTP", "B82_SMRMVI", "B82_NMRMTP", "B82_NMRMVI", "B82_SMDETP", "B82_SMDEVI"}
