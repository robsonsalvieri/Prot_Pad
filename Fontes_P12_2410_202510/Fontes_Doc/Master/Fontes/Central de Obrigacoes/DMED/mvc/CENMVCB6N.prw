#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB6N

Manutencao de Operadoras

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCB6N(cFiltro,lAutom)
	Local cDescript := "DMED - Responsáveis"
	Local oPnl
	Local oBrowse
	Local cAlias	:= "B6N"

	Private oDlgB6N
	Private aRotina	:= {}

	Default cFiltro	:= ""

	(cAlias)->(dbSetOrder(1))

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:SetMenuDef( 'CENMVCB6N' )
	oBrowse:SetProfileID( 'CENMVCB6N' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:AddLegend( "B6N_ATIVO=='1'", "GREEN"   , "Ativo" )
	oBrowse:AddLegend( "B6N_ATIVO=='0'", "RED"     , "Inativo" )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Responsáveis DMED", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCB6N'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMVCB6N'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMVCB6N'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.CENMVCB6N'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B6N

@return oModel	objeto model criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6N 	:= FWFormStruct( 1, 'B6N', , )
	Local oModel		:= Nil

	oModel := MPFormModel():New( "DMED - Responsáveis", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B6NMASTER', , oStruB6N )
	oModel:GetModel( 'B6NMASTER' ):SetDescription( "DMED - Responsáveis" )
	oModel:SetPrimaryKey({'B6N_FILIAL','B6N_CODOPE','B6N_CPFRES'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B6N

@return oView	objeto view criado

@author jose.paulo
@since 29/07/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCB6N' )
	Local oStruB6N := FWFormStruct( 2, 'B6N' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B6N' , oStruB6N , 'B6NMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B6N', 'DMED - Responsáveis' )

Return oView


Function ValCpoDm(cCampo,cCont)
	Local cMsg     := ""
	Local lOk      := .T.
	Local cQuery   := ""

	Default cCont  := ""
	Default cCampo := ""

	cCont:= alltrim(upper(cCont))

	If cCampo == "B6N_DDDRES"
		If Len(cCont) < 2
			lOk:= .F.
		EndIf
	ElseIf cCampo == "B6N_TELRES"
		If Len(cCont) < 9
			lOk:= .F.
		EndIf
	ElseIf cCampo =="B6N_FAXRES"
		If Len(cCont) < 9
			lOk:= .F.
		EndIf
	ElseIf cCampo =="B6N_CPFRES" .And. CGC(M->B6N_CPFRES)

		cQuery += " SELECT B6N_CPFRES FROM " + RetSQLName("B6N") + " "
		cQuery += "	WHERE B6N_CODOPE = '" + M->B6N_CODOPE + "' "
		cQuery += "	WHERE B6N_CPFRES = '" + M->B6N_CPFRES + "' "
		cQuery += "	AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBB6N",.T.,.T.)

		If !TRBB6N->(Eof())
			cMsg := "Já existe este CPF cadastrado para esta mesma Operadora. "
			TRBB6N->(DbCloseArea())
		Else
			lOk:=.T.
		EndIf

	ElseIf cCampo =="B6N_ATIVO" .And. M->B6N_ATIVO = '1'

		cQuery += " SELECT B6N_ATIVO FROM " + RetSQLName("B6N") + " "
		cQuery += "	WHERE B6N_CODOPE = '" + M->B6N_CODOPE + "' "
		cQuery += "	AND B6N_ATIVO = '1' AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBB6N",.T.,.T.)

		If !TRBB6N->(Eof())
			cMsg := "Já existe outro responsável ativo para esta Operadora."
			TRBB6N->(DbCloseArea())
		Else
			lOk:=.T.
		EndIf

	EndIf

	If !Empty(cMsg)
		MsgInfo(cMsg)
		lOk:=.f.
	EndIf

Return lOk

