#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCOE

Manutencao de Contratos Estipulados

@author timoteo.bega/Roger C
@since 26/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCOE(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   :=.F.
	PRIVATE lAtu22  := BUP->(fieldpos("BUP_CONREP")) > 0 .And. Val(B3D->B3D_ANO) >= 2022

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('BUP')
	oBrowse:SetDescription("DIOPS - Contratos Estipulados")
	oBrowse:AddLegend( "BUP_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "BUP_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "BUP_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "BUP_FILIAL=B3D->B3D_FILIAL .And. BUP_CODOPE=B3D->B3D_CODOPE .And. BUP_CODOBR=B3D->B3D_CDOBRI .And. BUP_ANOCMP=B3D->B3D_ANO .And. BUP_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCCOE' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS - Contratos Estipulados", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("BUP", BUP->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCCOE'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCCOE'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCCOE'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCCOE'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDCOE(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("7")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabCOE())'	, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BUP

@return oModel	objeto model criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBUP 	:= FWFormStruct( 1, 'BUP', , )
	Local oModel	:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'BUPMASTER', 'BUP_CODOPE', 'BUP_CODOBR', 'BUP_CDCOMP', 'BUP_ANOCMP', 'BUP_REFERE', 'BUP_STATUS') }

	oModel := MPFormModel():New( "DIOPS - Contratos Estipulados", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'BUPMASTER', , oStruBUP )
	oModel:GetModel( 'BUPMASTER' ):SetDescription( "DIOPS - Contratos Estipulados" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BUP

@return oView	objeto view criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCCOE' )
	Local oStruBUP := FWFormStruct( 2, 'BUP' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BUP' , oStruBUP , 'BUPMASTER' )
	oStruBUP:RemoveField('BUP_DTINVL')
	oStruBUP:RemoveField('BUP_HRINVL')
	oStruBUP:RemoveField('BUP_DTTEVL')
	oStruBUP:RemoveField('BUP_HRTEVL')
	oStruBUP:RemoveField('BUP_STATUS')
	If FunName() <> 'RPC' .And. lAtu22
		oStruBUP:RemoveField('BUP_VLRFAT')
	Else
		If 	FunName() <> 'RPC' .And. !lAtu22 .And. Val(B3D->B3D_ANO) > 2021
			MsgInfo("Para criar um Quadro em compromissos maior que 2021 você deve atualizar o Sistema. Favor entrar em contato com administrador do sistema.")
		EndIf
		oStruBUP:RemoveField('BUP_QTDVIA')
		oStruBUP:RemoveField('BUP_CONREP')
		oStruBUP:RemoveField('BUP_CONESP')
	EndIf
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BUP', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BUP', 'DIOPS - Contratos Estipulados' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCOE

Retorna tabela do quadro Contratos Estipulados

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCOE()
Return "BUP"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegCOE

Retorna array de regras para validar o quadro Contratos Estipulados

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegCOE()
	Local aRegrasAll    := {}
	Local aRegrasCOE    := {}
	Local aRegras       := {}

	//Verificar quais regras precisam ser desenvolvidas
	aAdd( aRegrasAll, {"CE01","    ","AlwaysTrue()", "","", "" } )
	aRegras := { GetTabCOE(), aRegrasAll, aRegrasCOE }

Return aRegras