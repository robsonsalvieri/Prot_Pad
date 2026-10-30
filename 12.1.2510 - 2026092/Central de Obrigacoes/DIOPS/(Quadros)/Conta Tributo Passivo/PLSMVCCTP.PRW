#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCTP

Manutencao de Conta Tributo Passivo

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCTP()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('BUY')
	oBrowse:SetDescription("DIOPS - Conta Tributo Passivo")
	oBrowse:AddLegend( "BUY_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "BUY_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "BUY_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "BUY_FILIAL=B3D->B3D_FILIAL .And. BUY_CODOPE=B3D->B3D_CODOPE .And. BUY_CODOBR=B3D->B3D_CDOBRI .And. BUY_ANOCMP=B3D->B3D_ANO .And. BUY_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCCTP' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Conta Tributo Passivo", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("BUY", BUY->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCCTP'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCCTP'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCCTP'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCCTP'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRBCTP(.F.)'			, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("15")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabCTP())'	, 0 , 7 , 0 , NIL } ) //

Return aRotina


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BUY

@return oModel	objeto model criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBUY 	:= FWFormStruct( 1, 'BUY', , )
	Local oModel	:= Nil
	Local oEvent    := CENEVTCTP():New()
	Local lCpos   := BUY->(FieldPos("BUY_SEQUEN")) > 0

	oModel := MPFormModel():New( "DIOPS - Conta Tributo Passivo")
	oModel:AddFields( 'BUYMASTER', , oStruBUY )
	oModel:GetModel( 'BUYMASTER' ):SetDescription( "DIOPS - Conta Tributo Passivo" )

	If lCpos
		oModel:SetPrimaryKey({"BUY_FILIAL","BUY_CODOPE","BUY_CODOBR","BUY_ANOCMP","BUY_CDCOMP","BUY_CONTA","BUY_DTCOMP","BUY_SEQUEN"})
	Else
		oModel:SetPrimaryKey({"BUY_FILIAL","BUY_CODOPE","BUY_CODOBR","BUY_ANOCMP","BUY_CDCOMP","BUY_CONTA","BUY_DTCOMP"})
	EndIf

	oModel:InstallEvent("QDRCONTP", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BUY

@return oView	objeto view criado

@author timoteo.bega
@since 15/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCCTP' )
	Local oStruBUY := FWFormStruct( 2, 'BUY' )
	Local oView    := FWFormView():New()
	Local lCpos   := BUY->(FieldPos("BUY_SEQUEN")) > 0

	If lCpos
		oStruBUY:RemoveField('BUY_SEQUEN')    //retirando este campo da tela
	EndIf

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BUY' , oStruBUY , 'BUYMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BUY', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BUY', 'DIOPS - Conta Tributo Passivo' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCTP

Retorna tabela do quadro Conta Tributo Passivo

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCTP()
Return "BUY"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegCTP

Retorna array de regras para validar o quadro Conta Tributo Passivo

@author timoteo.bega
@since 15/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegCTP()
	Local aRegrasAll    := {}
	Local aRegrasBl	:= {}

	aAdd( aRegrasBl, {"CT03","    ","CtaTrPas03()", "Somatório dos registros das contas tributo passivo não bate com a conta 1319 do Balancete", "Verifique o valor informado para este registro", "" } )
	aAdd( aRegrasAll, {"CT01","    ","CtaTrPas01()", "Esta conta não faz parte do grupo 1319. ","Informe um código de conta que faça parte do grupo 1319",	"" } )
	aAdd( aRegrasAll, {"CT02","    ","CtaTrPas02()", "O valor do saldo final deste registro não bate com o respectivo saldo final da conta.","Verificar se o Saldo Inicial - Valor Pago + Atualização Monetária é igual ao Saldo Final do Trimestre ", "" } )

	aRegras := { GetTabCTP(), aRegrasAll, aRegrasBl }

Return aRegras




