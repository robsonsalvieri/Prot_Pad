#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCCC

Manutencao de Conta corrente cooperado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCCC(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   :=.F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('BUW')
	oBrowse:SetDescription("DIOPS - Conta Corrente Cooperado")
	oBrowse:AddLegend( "BUW_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "BUW_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "BUW_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "BUW_FILIAL=B3D->B3D_FILIAL .And. BUW_CODOPE=B3D->B3D_CODOPE .And. BUW_CODOBR=B3D->B3D_CDOBRI .And. BUW_ANOCMP=B3D->B3D_ANO .And. BUW_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCCCC' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Conta Corrente Cooperado", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("BUW", BUW->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCCCC'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCCCC'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCCCC'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCCCC'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRBCCC(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("14")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabCCC())'	, 0 , 7 , 0 , NIL } ) //

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BUW

@return oModel	objeto model criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBUW 	:= FWFormStruct( 1, 'BUW', , )
	Local oModel	:= Nil
	Local oEvent  := CENEVTCCC():New()

	oModel := MPFormModel():New( "DIOPS - Conta Corrente Cooperado")
	oModel:AddFields( 'BUWMASTER', , oStruBUW )
	oModel:GetModel( 'BUWMASTER' ):SetDescription( "DIOPS - Conta Corrente Cooperado" )
	oModel:SetPrimaryKey({'BUW_FILIAL','BUW_CODOPE','BUW_CODOBR','BUW_ANOCMP','BUW_CDCOMP','BUW_TIPO','BUW_DENOMI','BUW_DTCOMP'})
	oModel:InstallEvent("QDRCCC", /*cOwner*/, oEvent)


Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BUW

@return oView	objeto view criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCCCC' )
	Local oStruBUW := FWFormStruct( 2, 'BUW' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BUW' , oStruBUW , 'BUWMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BUW', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BUW', 'DIOPS - Conta Corrente Cooperado' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCCC

Retorna tabela do quadro Conta Corrente Cooperado

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCCC()
Return "BUW"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Conta Corrente Contratado

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegCCC()
	Local aRegrasAll	:= {}
	Local aRegrasCCC	:= {}
	Local aRegras		:= {}

	aAdd( aRegrasAll, {"CC01","    ","CtaCCoop01()", "Somatório dos registros das contas correntes do cooperado não bate com a conta 1319 do Balancete","Verifique os registros das contas correntes", "" } )
	aRegras := { GetTabCCC(), aRegrasAll, aRegrasCCC }

Return aRegras