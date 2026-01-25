#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCDFI

Manutencao de CBR - Risco de Crédito - Parcela 2

@author jose.paulo
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCDFI(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B6Z')
	oBrowse:SetDescription("DIOPS - CBR - Risco de Crédito - Parcela 2")
	oBrowse:AddLegend( "B6Z_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B6Z_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B6Z_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B6Z_FILIAL=B3D->B3D_FILIAL .And. B6Z_CODOPE=B3D->B3D_CODOPE .And. B6Z_CODOBR=B3D->B3D_CDOBRI .And. B6Z_ANOCMP=B3D->B3D_ANO .And. B6Z_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'CENMVCDFI' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("CBR - Risco de Crédito - Parcela 2", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B6Z", B6Z->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				                 , 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCDFI'	                 , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMVCDFI'	                 , 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMVCDFI'   	             , 0 , 4 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'CENRDEFUI(.F.)'		                 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("25")'	                 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabDFuI())'	         , 0 , 7 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B6Z

@return oModel	objeto model criado

@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6Z 	:= FWFormStruct( 1, 'B6Z', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B6ZMASTER', 'B6Z_CODOPE', 'B6Z_CODOBR', 'B6Z_CDCOMP', 'B6Z_ANOCMP', 'B6Z_REFERE', 'B6Z_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - CBR - Risco de Crédito - Parcela 2", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B6ZMASTER', , oStruB6Z )
	oModel:GetModel( 'B6ZMASTER' ):SetDescription( "DIOPS - CBR - Risco de Crédito - Parcela 2" )
	oModel:SetPrimaryKey({'B6Z_FILIAL','B6Z_CODOPE','B6Z_CODOBR','B6Z_ANOCMP','B6Z_CDCOMP','B6Z_REFERE'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B6Z

@return oView	objeto view criado

@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCDFI' )
	Local oStruB6Z := FWFormStruct( 2, 'B6Z' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B6Z' , oStruB6Z , 'B6ZMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B6Z', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B6Z', 'DIOPS - CBR - Risco de Crédito - Parcela 2' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabDFuI

@author jose.paulo
@since 14/04/2021
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabDFuI()
Return "B6Z"

Function GetRegDFI()
	Local aRegrasAll    := {}
	Local aRegrasBl	    := {}

	aAdd( aRegrasBl, {"DFI1","    ","CENVLDFI1()", "Valor diferente do total dos valores informado na última data do trimestre pelos Fundos de Investimento dedicados ao setor suplementar (FDSS).","Verifique se o campo 1 (Oper.Cre/Deb) informe uma Operadora válida junto a ANS(SIstema CADOP)", "" } )
	aAdd( aRegrasBl, {"DFI2","    ","CENVLDFI2()", "Vlr do campo diferente da soma dos campos Tot.Aplica.Q e Tot.não FDSS.","O valor desse campo deve ser igual a soma dos campos Tot.Aplica.Q e Tot.não FDSS e também a soma das contas 12211902,12212902,12213901, 12221902,12222902,12223901, 13111902,13112902,13113901, 13121902,13122902 e 13123901 do balancete.",	"" } )

	aRegras := { GetTabDFuI(), aRegrasAll, aRegrasBl }

Return aRegras