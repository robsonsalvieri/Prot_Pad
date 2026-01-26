#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCPESL

Manutencao deComposição do Saldo da Provisão de Eventos/SInistros a Liquidar

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCPESL(lAuto)
	Local oBrowse	:= Nil
	Local lNew22    := Val(B3D->B3D_ANO) >= 2022
	Default lAuto   := .F.


	If FWAliasInDic("B8J", .F.)

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('B8J')
		oBrowse:SetDescription("Composição do Saldo da Provisão de Eventos/SInistros a Liquidar")
		oBrowse:AddLegend( "B8J_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
		oBrowse:AddLegend( "B8J_STATUS=='2'", "GREEN",	"Valido" )
		oBrowse:AddLegend( "B8J_STATUS=='3'", "RED",	"Invalido" )
		oBrowse:SetFilterDefault( "B8J_FILIAL=B3D->B3D_FILIAL .And. B8J_CODOPE=B3D->B3D_CODOPE .And. B8J_CODOBR=B3D->B3D_CDOBRI .And. B8J_ANOCMP=B3D->B3D_ANO .And. B8J_CDCOMP=B3D->B3D_CODIGO" )
		oBrowse:SetMenuDef( 'PLSMVCPESL' )

		If lNew22

			oBrowse:SetOnlyFields( { 'B8J_UMMSUS','B8J_UMCARP','B8J_UMCOAS','B8J_DOMSUS','B8J_DOCARP','B8J_DOCOAS','B8J_TRMSUS','B8J_TRCARP','B8J_TRCOAS','B8J_TIPOES'} )
		Else
			oBrowse:SetOnlyFields( { 'B8J_QTDE','B8J_EVULTI','B8J_EVMAIS','B8J_CAULTI','B8J_CAMAIS'} )

		EndIf


		if lHabMetric .and. lLibSupFw .and. lVrsAppSw
			FWMetrics():addMetrics("Prov Eve/Sinis a Liq", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
		endif

		If !lAuto
			oBrowse:Activate()
		EndIf
	Else
		MsgAlert("Tabela B8J não existe. Favor aplicar o pacote 006231")

	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8J", B8J->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCPESL'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCPESL'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCPESL'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCPESL'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDPESL(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("13")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabPES())'	, 0 , 7 , 0 , NIL } ) //

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8J

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8J 	:= FWFormStruct( 1, 'B8J', , )
	Local oModel	:= Nil
	Local oEvent    := CENEVTPESL():New()

	If Val(B3D->B3D_ANO) < 2022
		oStruB8J:setProperty( "B8J_TIPOES" , MODEL_FIELD_OBRIGAT, .F. )
	EndIf

	oModel	:= MPFormModel():New( "DIOPS - Composição do Saldo da Provisão de Eventos/SInistros a Liquidar")
	oModel:AddFields( 'B8JMASTER', , oStruB8J )
	oModel:GetModel( 'B8JMASTER' ):SetDescription( "DIOPS - Composição do Saldo da Provisão de Eventos/SInistros a Liquidar" )

	If Val(B3D->B3D_ANO) >= 2022
		oModel:SetPrimaryKey({'B8J_FILIAL','B8J_CODOPE', 'B8J_CODOBR', 'B8J_CDCOMP', 'B8J_ANOCMP', 'B8J_REFERE','B8J_TIPOES'})
	Else
		oModel:SetPrimaryKey({'B8J_FILIAL','B8J_CODOPE', 'B8J_CODOBR', 'B8J_CDCOMP', 'B8J_ANOCMP', 'B8J_REFERE'})
	EndIf

	oModel:InstallEvent("QDRPESL", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8J

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCPESL' )
	Local oStruB8J := FWFormStruct( 2, 'B8J' )
	Local oView    := FWFormView():New()
	Local lNew22    := Val(B3D->B3D_ANO) >= 2022

	If lNew22
		oStruB8J:RemoveField("B8J_QTDE")
		oStruB8J:RemoveField("B8J_EVULTI")
		oStruB8J:RemoveField("B8J_EVMAIS")
		oStruB8J:RemoveField("B8J_CAULTI")
		oStruB8J:RemoveField("B8J_CAMAIS")
	Else
		oStruB8J:RemoveField("B8J_UMMSUS")
		oStruB8J:RemoveField("B8J_UMCARP")
		oStruB8J:RemoveField("B8J_UMCOAS")
		oStruB8J:RemoveField("B8J_DOMSUS")
		oStruB8J:RemoveField("B8J_DOCARP")
		oStruB8J:RemoveField("B8J_DOCOAS")
		oStruB8J:RemoveField("B8J_TRMSUS")
		oStruB8J:RemoveField("B8J_TRCARP")
		oStruB8J:RemoveField("B8J_TRCOAS")
		oStruB8J:RemoveField("B8J_TIPOES")
	EndIf

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8J' , oStruB8J , 'B8JMASTER' )

	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8J', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8J', 'DIOPS - Composição do Saldo da Provisão de Eventos/SInistros a Liquidar' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegPES

Retorna array de regras para validar o quadroComposição do Saldo da Provisão de Eventos/SInistros a Liquidar

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegPES()

	local aRegras   := {}
	local aRegrasAll:= {}
	local aRegrasBl := {}
	local lNew22    := Val(B3D->B3D_ANO) >= 2022
	// Regras de Validacao de Blocos
	// Compara Somatório dos Itens por Produtos com o total da Conta Contábil respectiva
	/* a somatória do campo total do quadro PROV. Eventos Sinistros a Liquidar deve ser igual as conta
	 	21111102,21111103,23111102,23111103,21111202,21111203,23111202,23111203,21112102,21112103,23112102,23112103,21112202,21112203,23112202,23112203
	*/
	//mudaram todos os campos deste quadro.estamos confirmando se haverá novas criticas. Sendo assim por enquanro só será informativo.
	aAdd( aRegrasBl, {"PE01","   ",IIF(lNew22,"AlwaysTrue()","PLVLDPES01()"),  "Somatório dos itens não confere com o total da(s) conta(s) 2X111X02, 2X111X03, 2X112X02, 2X112X03.", "Verifique a somatória dos itens e o valor contabilizado na(s) conta(s) 2X111X02, 2X111X03, 2X112X02, 2X112X03."," " } )

	aRegras := { getTabPES(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabPES

Retorna tabela do quadroComposição do Saldo da Provisão de Eventos/SInistros a Liquidar

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabPES()
return "B8J"
