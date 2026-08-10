#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB2W

Despesas sintéticas

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCB2W(cFiltro,lAutom)
	Local cDescript := "Movimentos DMED"
	Local oPnl
	Local oBrowse
	Local cAlias	:= "B2W"
	//Métricas - FwMetrics
	Local lLibSupFw		:= FWLibVersion() >= "20200727"
	Local lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
	Local lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
	Private oDlgB2W
	Private aRotina	:= {}

	Default cFiltro	:= 	" B2W_FILIAL = xFilial( 'B2W' ) .AND. " +;
		" B2W_CODOPE = B3D->B3D_CODOPE .AND. " +;
		" B2W_CODOBR = B3D->B3D_CDOBRI .AND. " +;
		" B2W_ANOCMP = B3D->B3D_ANO .AND. " +;
		" B2W_CDCOMP = B3D->B3D_CODIGO "

	(cAlias)->(dbSetOrder(1))

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:AddLegend( "B2W_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "B2W_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "B2W_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "B2W_STATUS=='4'", "GREEN"	, "Enviado Receita Federal" )

	oBrowse:SetMenuDef( 'CENMVCB2W' )
	oBrowse:SetProfileID( 'CENMVCB2W' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Movimentos DMED", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAutom
		oBrowse:Activate()
	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCB2W'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Validar Itens"		, 'CenVldDmed(.F.)'		, 0 , 2 , 0 , NIl } ) //Validação de item
	aAdd( aRotina, { "Críticas"				, 'CenCritB2W(.F.,"1")'	, 0 , 7 , 0 , NIL } ) //Críticas

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B2W

@return oModel	objeto model criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB2W 	:= FWFormStruct( 1, 'B2W', , )
	Local oModel		:= Nil

	oModel := MPFormModel():New( "DMED - Movimentos", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B2WMASTER', , oStruB2W )
	oModel:GetModel( 'B2WMASTER' ):SetDescription( "DMED - Movimentos" )
	oModel:SetPrimaryKey({'B2W_FILIAL','B2W_CODOPE','B2W_CODOBR','B2W_ANOCMP','B2W_CDCOMP','B2W_CPFTIT','B2W_CPFBEN','B2W_DTNASD','B2W_NOMBEN','B2W_CPFPRE','B2W_IDEREG'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B2W

@return oView	objeto view criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCB2W' )
	Local oStruB2W := FWFormStruct( 2, 'B2W' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B2W' , oStruB2W , 'B2WMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B2W', 'DMED - Movimentos' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenCritB2W

Filtro para a tela de críticas exibir somente críticas de DMED e tipo 1 = Críticas Validação.

@author vinicius.nicolau
@since 16/11/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenCritB2W(lAuto,cTipo)
	Local cFiltro := 	" B3F_FILIAL    = '" + xFilial( 'B3F' ) + "' .AND. " +;
		" B3F_TIPO		= '" + cTipo 			+ "' .AND. " +;
		" SubStr(B3F_CODCRI,1,2) == 'DM' .AND. " +;
		" B3F_IDEORI = '" + B2W->(B2W_CODOPE+B2W_CODOBR+B2W_ANOCMP+B2W_CDCOMP+B2W_CPFTIT+B2W_CPFBEN+DTOS(B2W_DTNASD)+B2W_NOMBEN+B2W_CPFPRE+B2W_IDEREG)  + "' "

	Default cTipo := "1"
	Default lAuto := .F.

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldDmed
Descricao:  Rotina de validação de itens DMED.

@author Vinícius Nicolau
@since 17/11/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function CenVldDmed(lAutom)
	Default lAutom		:= .F.

	If lAutom .Or. MsgYesNo("Este processo irá validar todos os itens pendentes em segundo plano. Deseja continuar?")
		Msginfo("Processo iniciado. Para acompanhar o andamento da validação, atualize a tela.")
		StartJob("B2WVldJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.T.,B2W->B2W_CODOPE)
		DelClassIntf()
	else
		Msginfo("O Job sera processado posteriormente de acordo com a parametrização.")
	EndIf

Return

Function B2WVldJob(cEmp, cFil, lJob, cCodOpe)
	Local aSvcVldr      := {}
	Local aSvcVlInd     := {}
	Default lJob := .T.

	If lJob
		rpcSetType(3)
		rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
	EndIf

	aSvcVldr  := {SvCalDmedG():New()}
	aSvcVlInd := {SvCalDmedI():New()}
	ExecVldDmed(cCodOpe,aSvcVldr,aSvcVlInd,cEmp,cFil)

Return