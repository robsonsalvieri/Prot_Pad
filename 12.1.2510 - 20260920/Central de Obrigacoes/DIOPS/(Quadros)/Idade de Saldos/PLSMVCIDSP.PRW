#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCIDSP

Manutencao de Idade de Saldos Ativos - A Receber

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCIDSP(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8G')
	oBrowse:SetDescription("DIOPS - Idade de Saldos - A Receber")
	oBrowse:AddLegend( "B8G_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8G_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8G_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "B8G_FILIAL=B3D->B3D_FILIAL .And. B8G_CODOPE=B3D->B3D_CODOPE .And. B8G_CODOBR=B3D->B3D_CDOBRI .And. B8G_ANOCMP=B3D->B3D_ANO .And. B8G_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCIDSP' )
	PLSCRIIDSP(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO)

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Idade Saldos - A Receber", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8G", B8G->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCIDSP'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCIDSP'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCIDSP'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCIDSP'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDISP(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("16")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabIDSP())'	, 0 , 7 , 0 , NIL } ) //Imprimir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8G

@return oModel	objeto model criado

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8G 	:= FWFormStruct( 1, 'B8G', , )
	Local oModel		:= Nil
	Local oEvent  := CENEVTIDSP():New()

	oModel	:= MPFormModel():New( "DIOPS - Idade dos Saldos - A Receber")
	oModel:AddFields( 'B8GMASTER', , oStruB8G )
	oModel:GetModel( 'B8GMASTER' ):SetDescription( "DIOPS - Idade dos Saldos - A Receber" )
	oModel:SetPrimaryKey({'B8G_FILIAL','B8G_CODOPE','B8G_CODOBR','B8G_ANOCMP','B8G_CDCOMP','B8G_VENCTO'})
	oModel:InstallEvent("QDRIDSP", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8G

@return oView	objeto view criado

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCIDSP' )
	Local oStruB8G := FWFormStruct( 2, 'B8G' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8G' , oStruB8G , 'B8GMASTER' )

	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:SetOwnerView( 'VIEW_B8G', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8G', 'DIOPS - Idade dos Saldos - A Receber' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabIDSP

Retorna tabela do quadro Idade dos Saldos A Receber

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabIDSP()
Return "B8G"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Idade dos Saldos A Receber

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegIDSP()

	local aRegrasAll := {}
	local aRegrasBl := {}
	local aRegras := {}
	local cVencto := " AND B8G_VENCTO <> '400' "


	aAdd( aRegrasBl, {"IP01","    ","IdaSalPasA(.F.)", "(A) - Planos Ind./Fam. Mensalidades PF Preço Pré-Estabelecido.","Verifique os valores das contas 123111011,123121011 no balancete.", cVencto } )
	aAdd( aRegrasBl, {"IP02","    ","IdaSalPasB(.F.)", "(B) - Planos Ind./Fam. Mensalidades PF Preco Pos-Estabelecido",	"Verifique os valores das contas 123112011,123122011 no balancete",  cVencto } )
	aAdd( aRegrasBl, {"IP03","    ","IdaSalPasC(.F.)", "(C) - Planos Coletivos Faturas PJ Preco Pre-Estabelecido",      "Verifique os valores das contas 123111012,123111013,123121012,123121013 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP04","    ","IdaSalPasD(.F.)", "(D) - Planos Coletivos Faturas PJ Preco Pos-Estabelecido",      "Verifique os valores das contas 123112012,123112013,123112015,123122012,123122013,123122015  no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP05","    ","IdaSalPasE(.F.)", "(E) - Creditos de Operacao de Administracao de Beneficios",     "Veja os valores das contas 123219011,123219012,123219021,123219022,123229011,123229012,123229021,123229022 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP06","    ","IdaSalPasF(.F.)", "(F) - Participacao dos Beneficiarios em Eventos / Sinistros",   "Verifique os valores das contas 123311011,123312011,123321011,123322011 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP08","    ","IdaSalPasH(.F.)", "(H) - Outros Creditos de Operacoes com Planos",					"Valores das contas 1239-(123911019,123911029,123911089,123912089,123921019,123921029,123921089,123922089) no balancete.", cVencto } )
	aAdd( aRegrasBl, {"IP09","    ","IdaSalPasI(.F.)", "(I) - Outros Creditos Nao Relacionados com Planos Subgrupo 124","Contas 124119011,124119021,124119022,124119082,124119088,124129011,124129021,124129022,124129082,124129088 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP10","    ","IdaSalPasJ(.F.,.T.)", "(G) - Creditos de Operadoras - Pre-Pagamento",				"Verifique os valores das contas (123411 - 123411091) + (123421 - 123421091) no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP11","    ","IdaSalPasJ(.F.,.F.)", "(G) - Creditos de Operadoras - Pós Pagamento",				"Verifique os valores das contas (123412 - 123412091) + (123422 - 123422091) no balancete", cVencto } )

	cVencto := " AND B8G_VENCTO = '400' "

	aAdd( aRegrasBl, {"IP12","    ","IdaSalPasA(.T.)", "(A) - Planos Ind./Fam. Mensalidades PF Preco Pre-Estabelecido",	"Verifique os valores das contas 123111091,123121091 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP13","    ","IdaSalPasB(.T.)", "(B) - Planos Ind./Fam. Mensalidades PF Preco Pos-Estabelecido",	"Verifique os valores das contas 123112091,123122091 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP14","    ","IdaSalPasC(.T.)", "(C) - Planos Coletivos Faturas PJ Preco Pre-Estabelecido",		"Verifique os valores das contas 123111092,123111093,123121092,123121093 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP15","    ","IdaSalPasD(.T.)", "(D) - Planos Coletivos Faturas PJ Preco Pos-Estabelecido",		"Verifique os valores das contas 123112092,123112093,123112095,123122092,123122093,123122095 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP16","    ","IdaSalPasE(.T.)", "(E) - Creditos de Operacao de Administracao de Beneficios",		"Verifique os valores das contas 123219019,123219029,123229019,123229029 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP17","    ","IdaSalPasF(.T.)", "(F) - Participacao dos Beneficiarios em Eventos / Sinistros",	"Verifique os valores das contas 123311019,123312019,123321019,123322019 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP19","    ","IdaSalPasH(.T.)", "(H) - Outros Creditos de Operacoes com Planos",					"Veja os valores das contas 123911019,123911029,123911089,123912089,123921019,123921029,123921089,123922089 no balancete.", cVencto } )
	aAdd( aRegrasBl, {"IP20","    ","IdaSalPasI(.T.)", "(I) - Outros Creditos Nao Relacionados com Planos Subgrupo 124","Verifique os valores das contas 124119019,124119029,124119089,124129019,124129029,124129089 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP21","    ","IdaSalPasJ(.T.,.T.)", "(G) - Creditos de Operadoras - Pre-Pagamento",				"Verifique os valores das contas 123411091 + 123421091 no balancete", cVencto } )
	aAdd( aRegrasBl, {"IP22","    ","IdaSalPasJ(.T.,.F.)", "(G) - Creditos de Operadoras - Pós-Pagamento",				"Verifique os valores das contas 123412091 + 123422091 no balancete", cVencto } )

	aRegras := { GetTabIDSP(), aRegrasAll, aRegrasBl }

Return aRegras
