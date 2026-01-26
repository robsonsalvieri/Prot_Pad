#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCCOAS

Manutencao de COBERTURA ASSISTENCIAL

@author Roger C
@since 09/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCCOAS()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8I')
	oBrowse:SetDescription("DIOPS - COBERTURA ASSISTENCIAL")
	oBrowse:AddLegend( "B8I_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8I_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8I_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B8I_FILIAL=B3D->B3D_FILIAL .And. B8I_CODOPE=B3D->B3D_CODOPE .And. B8I_CODOBR=B3D->B3D_CDOBRI .And. B8I_ANOCMP=B3D->B3D_ANO .And. B8I_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCCOAS' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Cobertura Assistencial", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()

	EndIF

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8I", B8I->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCCOAS'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCCOAS'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCCOAS'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDCOAS(.F.)'		, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("9")'		, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(getTabCoA())'	, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCCOAS'   	, 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8I

@return oModel	objeto model criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8I 	:= FWFormStruct( 1, 'B8I', , )
	Local oModel		:= Nil
	Local oEvent  := CENEVTCOAS():New()

	oModel	:= MPFormModel():New( "DIOPS - COBERTURA ASSISTENCIAL" )
	oModel:AddFields( 'B8IMASTER', , oStruB8I )
	oModel:GetModel( 'B8IMASTER' ):SetDescription( "DIOPS - COBERTURA ASSISTENCIAL" )

	oModel:InstallEvent("QDRCOAS", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8I

@return oView	objeto view criado

@author Roger C
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCCOAS' )
	Local oStruB8I := FWFormStruct( 2, 'B8I' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8I' , oStruB8I , 'B8IMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8I', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8I', 'DIOPS - COBERTURA ASSISTENCIAL' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRegCoA

Retorna array de regras para validar o quadro Cobertura Assistencial

@author timoteo.bega
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getRegCoA()

	local aRegras := {}
	local aRegrasAll := {}
	local aRegrasBl := {}

	aAdd( aRegrasBl, {"CA01","   ","PLVLDCOA01()", "Somatório dos itens referente a Planos IFAL não confere com o total das contas 411X1101.", "Verifique a somatória dos itens referente a Planos IFAL e o valor contabilizado nas contas 411X1101."," AND B8I_PLANO = 'IFAL' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA02","   ","PLVLDCOA02()", "Somatório dos itens referente a Planos IFPL não confere com o total das contas 411X1102.", "Verifique a somatória dos itens referente a Planos IFPL e o valor contabilizado nas contas 411X1102."," AND B8I_PLANO = 'IFPL' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA03","   ","PLVLDCOA03()", "Somatório dos itens referente a Planos PLAL não confere com o total das contas 411X1103.", "Verifique a somatória dos itens referente a Planos PLAL e o valor contabilizado nas contas 411X1103."," AND B8I_PLANO = 'PLAL' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA04","   ","PLVLDCOA04()", "Somatório dos itens referente a Planos PLAP não confere com o total das contas 411X1104.", "Verifique a somatória dos itens referente a Planos PLAP e o valor contabilizado nas contas 411X1104."," AND B8I_PLANO = 'PLAP' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA05","   ","PLVLDCOA05()", "Somatório dos itens referente a Planos PCEA não confere com o total das contas 411X1105.", "Verifique a somatória dos itens referente a Planos PCEA e o valor contabilizado nas contas 411X1105."," AND B8I_PLANO = 'PCEA' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA06","   ","PLVLDCOA06()", "Somatório dos itens referente a Planos PCEL não confere com o total das contas 411X1106.", "Verifique a somatória dos itens referente a Planos PCEL e o valor contabilizado nas contas 411X1106."," AND B8I_PLANO = 'PCEL' AND B8I_ORIGEM<>'6' " } )
	aAdd( aRegrasBl, {"CA07","   ","PLVLDCOA07()", "Somatório dos itens referente a Planos CRAS não confere com o total das contas 411X1108.", "Verifique a somatória dos itens referente a Planos CRAS e o valor contabilizado nas contas 411X1108."," AND B8I_PLANO = 'CRAS' AND B8I_ORIGEM<>'6' " } )

	aAdd( aRegrasBl, {"CA08","   ","PLVLDCOA08()", "Somatório dos itens referente a IFAL - Corresponsabilidade Cedida não confere com o total da conta 31171101.", "Verifique a somatória dos itens referente a IFAL - Corresponsabilidade Cedida e o valor contabilizado na conta 31171101."," AND B8I_PLANO = 'IFAL' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasBl, {"CA09","   ","PLVLDCOA09()", "Somatório dos itens referente a IFPL - Corresponsabilidade Cedida não confere com o total da conta 31171102.", "Verifique a somatória dos itens referente a IFPL - Corresponsabilidade Cedida e o valor contabilizado na conta 31171102."," AND B8I_PLANO = 'IFPL' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasBl, {"CA10","   ","PLVLDCOA10()", "Somatório dos itens referente a PLAL - Corresponsabilidade Cedida não confere com o total da conta 31171103.", "Verifique a somatória dos itens referente a PLAL - Corresponsabilidade Cedida e o valor contabilizado na conta 31171103."," AND B8I_PLANO = 'PLAL' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasBl, {"CA11","   ","PLVLDCOA11()", "Somatório dos itens referente a PLAP - Corresponsabilidade Cedida não confere com o total da conta 31171104.", "Verifique a somatória dos itens referente a PLAP - Corresponsabilidade Cedida e o valor contabilizado na conta 31171104."," AND B8I_PLANO = 'PLAP' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasBl, {"CA12","   ","PLVLDCOA12()", "Somatório dos itens referente a PCEA - Corresponsabilidade Cedida não confere com o total da conta 31171105.", "Verifique a somatória dos itens referente a PCEA - Corresponsabilidade Cedida e o valor contabilizado na conta 31171105."," AND B8I_PLANO = 'PCEA' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasBl, {"CA13","   ","PLVLDCOA13()", "Somatório dos itens referente a PCEL - Corresponsabilidade Cedida não confere com o total da conta 31171106.", "Verifique a somatória dos itens referente a PCEL - Corresponsabilidade Cedida e o valor contabilizado na conta 31171106."," AND B8I_PLANO = 'PCEL' AND B8I_ORIGEM='6' " } )
	aAdd( aRegrasAll,{"CA14","   ","PLVLDCOA14()", "Plano com corresp.cecida não pode ter origem pagto igual a reembolso ou corresp.cedida", "Verifique se o plano é de Corresp.Cedida e a Origem do Pgto."," AND B8I_PLANO = 'CRAS' AND B8I_ORIGEM IN ('2','6') " } )

	aRegras := { getTabCoA(), aRegrasAll, aRegrasBl }

Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabCoA

Retorna tabela do quadro Cobertura Assistencial

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
function getTabCoA()
return "B8I"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8IConta

Funcao criada para apresentar o numero da conta contabil

@author timoteo.bega
@since 28/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function B8IConta()
	Local cConta := ""
	Local aConta := {}
	Local nConta := 0

	aAdd(aConta,{"IFAL","411X1101"})
	aAdd(aConta,{"IFPL","411X1102"})
	aAdd(aConta,{"PLAL","411X1103"})
	aAdd(aConta,{"PLAP","411X1104"})
	aAdd(aConta,{"PCEA","411X1105"})
	aAdd(aConta,{"PCEL","411X1106"})
	aAdd(aConta,{"CRAS","411X1108"})

	If !IsInCallStack('PLSMIGCOA') .and. INCLUI
		cConta := M->B8I_PLANO
	Else
		cConta := B8I->B8I_PLANO
	EndIf

	nConta := aScan(aConta,{ |x| x[1] == cConta })

	If nConta > 0
		cConta := aConta[nConta,2]
	EndIf

Return cConta
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8IDesCon

Retorna a descrição da conta

@author timoteo.bega
@since 04/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8IDesCon(cConta)
	Local cDesCon	:= ""
	Default cConta	:= ""

	If Empty(cConta)
		cConta := B8IConta()
	EndIf
	cConta := Strtran(cConta,"X","1")
	If !Empty(cConta)
		cDesCon := POSICIONE('B8B',3,XFILIAL('B8B')+cConta,'B8B_DESCRI')
	EndIf

Return cDesCon

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CnCbB8IPla

Função para retornar o cbox do campo B8I_PLANO

@author Everton.mateus
@since 20/05/2019
/*/
//--------------------------------------------------------------------------------------------------

Function CnCbB8IPla()
	Local cBox := "IFAL=Cart Ind/Fam a.Lei;"+;
		"IFPL=Cart Ind/Fam p.Lei;"+;
		"PLAL=Col Ades. a.Lei;"+;
		"PLAP=Col Ades. p.Lei;"+;
		"PCEA=Col Empr a.Lei;"+;
		"PCEL=Col Empr p.Lei;"+;
		"CRAS=Corresp Assumida;"
Return cBox