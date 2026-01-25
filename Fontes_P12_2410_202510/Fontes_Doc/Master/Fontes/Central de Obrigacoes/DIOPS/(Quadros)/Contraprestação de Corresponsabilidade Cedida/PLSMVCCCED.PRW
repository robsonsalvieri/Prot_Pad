#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCCED

Movimentações de Contraprestação de Corresponsabilidade Cedida (Eventos Indenizáveis)

@author José Paulo
@since 29/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCCED()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	If FWAliasInDic("B36", .F.)

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B36')
		oBrowse:SetDescription("DIOPS - CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA")
		oBrowse:AddLegend( "B36_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
		oBrowse:AddLegend( "B36_STATUS=='2'", "GREEN",	"Valido" )
		oBrowse:AddLegend( "B36_STATUS=='3'", "RED",	"Invalido" )
		oBrowse:SetFilterDefault( " B36_FILIAL=B3D->B3D_FILIAL .And. B36_CODOPE=B3D->B3D_CODOPE .And. B36_CODOBR=B3D->B3D_CDOBRI .And. B36_ANOCMP=B3D->B3D_ANO .And. B36_CDCOMP=B3D->B3D_CODIGO " )
		oBrowse:SetMenuDef( 'PLSMVCCCED' )

		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Contrapr.Corresp.Cedida", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		If !lAuto
			oBrowse:Activate()
		EndIf
	else
		MsgAlert("Tabela B36 não existe. Favor aplicar o pacote 006231")

	EndIf
Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author José Paulo
@since 29/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"			, 'PlCenFilCri("B36", B36->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"		, 'PesqBrw'				    , 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"		, 'VIEWDEF.PLSMVCCCED'	    , 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"			, 'VIEWDEF.PLSMVCCCED'	    , 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"			, 'VIEWDEF.PLSMVCCCED'	    , 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"	, 'PLSRDEVCC(.F.)'		    , 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"	, 'CenVldQdMn("20")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"	, 'CenLimpBlc(getTabCED())'	, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Alterar"			, 'VIEWDEF.PLSMVCCCED'		, 0 , 4 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B36

@return oModel	objeto model criado

@author José Paulo
@since 24/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB36 	:= FWFormStruct( 1, 'B36', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'B36MASTER', 'B36_CODOPE', 'B36_CODOBR', 'B36_CDCOMP', 'B36_ANOCMP', 'B36_REFERE', 'B36_STATUS') }

	oModel	:= MPFormModel():New( "DIOPS - CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'B36MASTER', , oStruB36 )
	oModel:GetModel( 'B36MASTER' ):SetDescription( "DIOPS - CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B36

@return oView	objeto view criado

@author José Paulo
@since 29/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'PLSMVCCCED' )
	Local oStruB36 := FWFormStruct( 2, 'B36' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B36' , oStruB36 , 'B36MASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B36', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B36', 'DIOPS - CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegCED

Retorna array de regras para validar o quadro CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA

@author José Paulo
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegCED()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	// Regras de Validacao Registro a Registro
	aAdd( aRegrasAll,{"CC01","   ","PLVLDECC01()", "O codigo do tipo de evento utilizado é inválido.", "Verifique o código do tipo de evento deste item.", ""} )
	aAdd( aRegrasBl, {"CC02","   ","PLVLDECC02()", "Somatório dos novos avisos de Eventos do trimestre não confere com o total das contas contábeis.", "Verifique a somatória dos novos avisos de Eventos do trimestre e o valor contabilizado nas respectivas contas."," AND B36_CODIGO BETWEEN '33' AND '46' " } )
	/*aAdd( aRegrasBl, {"CC03","   ","PLVLDECC03()", "Somatório de Baixa por Glosa reconhecidas do trimestre não confere com o total das contas contábeis.", "Verifique a somatória das Baixas por Glosa do trimestre e o valor contabilizado nas respectivas contas."," AND B36_CODIGO BETWEEN '47' AND '60' " } )
	aAdd( aRegrasBl, {"CC04","   ","PLVLDECC04()", "Somatório de Outras Recuperações reconhecidas do trimestre não confere com o total das contas contábeis.", "Verifique a somatória de Outras Recuperações Conhecidas do trimestre e o valor contabilizado nas respectivas contas."," AND B36_CODIGO BETWEEN '65' AND '78' " } )
	*/aRegras := { getTabCED(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabCED

Retorna tabela do quadro  CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA

@author José Paulo
@since 29/04/2019
/*/
//--------------------------------------------------------------------------------------------------
function getTabCED()
return "B36"
