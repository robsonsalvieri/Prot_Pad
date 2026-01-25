#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCIDSA

Manutencao de Idade de Saldos Passivo - A Pagar

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCIDSA(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := lAuto

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8F')
	oBrowse:SetDescription("DIOPS - Idade de Saldos - A Pagar") //Beneficiarios
	oBrowse:AddLegend( "B8F_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B8F_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B8F_STATUS=='3'", "RED",		"Invalido" )
	oBrowse:SetFilterDefault( "B8F_FILIAL=B3D->B3D_FILIAL .And. B8F_CODOPE=B3D->B3D_CODOPE .And. B8F_CODOBR=B3D->B3D_CDOBRI .And. B8F_ANOCMP=B3D->B3D_ANO .And. B8F_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'PLSMVCIDSA' )
	PLSCRIIDSA(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_CODIGO,B3D->B3D_ANO)

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Idade Saldos - A Pagar", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B8F", B8F->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'								, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCIDSA'					, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCIDSA'					, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCIDSA'					, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCIDSA'					, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { "Imprimir Quadro"		, 'PLSRDISA(.F.)'						, 0 , 7 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("5")'						, 0 , 7 , 0 , NIL } ) //
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabIDSA())'			, 0 , 7 , 0 , NIL } ) //Imprimir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8F

@return oModel	objeto model criado

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8F 	:= FWFormStruct( 1, 'B8F', , )
	Local oModel		:= Nil
	Local oEvent  := CENEVTIDSA():New()

	oModel := MPFormModel():New( "DIOPS - Idade dos Saldos - A Pagar")
	oModel:AddFields( 'B8FMASTER', , oStruB8F )
	oModel:GetModel( 'B8FMASTER' ):SetDescription( "DIOPS - Idade dos Saldos - A Pagar" )
	oModel:SetPrimaryKey({'B8F_FILIAL','B8F_CODOPE','B8F_CODOBR','B8F_ANOCMP','B8F_CDCOMP','B8F_VENCTO'})
	oModel:InstallEvent("QDRIDSA", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8F

@return oView	objeto view criado

@author timoteo.bega
@since 05/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCIDSA' )
	Local oStruB8F := FWFormStruct( 2, 'B8F' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8F' , oStruB8F , 'B8FMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B8F', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B8F', 'DIOPS - Idade dos Saldos - A Pagar' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabIDSA

Retorna tabela do quadro Idade dos Saldos A Pagar

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabIDSA()
Return "B8F"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Idade dos Saldos A Pagar

@author timoteo.bega
@since 22/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegIDSA()

	local aRegrasAll := {}
	local aRegrasIDSA := {}//Passar a clausula where pronta
	local aRegras := {}

	aAdd( aRegrasAll, {"IA01","    ","IdaSalAtvA()", "(A) - Eventos/Sinistros a Liquidar SUS Conta = 21111102 + 21111202 + 21112102 + 21112202",						"Verifique o valor da(s) conta(s) '21111102','21111202','21112102','21112202' no balancete", " AND B8F_EVESUS > 0 " } )
	aAdd( aRegrasAll, {"IA02","    ","IdaSalAtvB()", "(B) - Eventos/Sinistros a Liquidar Conta = 21111103 + 21111203 + 21112103 + 21112203'",													"Verifique o valor da(s) conta(s) '21111103','21111203','21112103','21112203' no balancete", " AND B8F_EVENTO > 0 " } )
	aAdd( aRegrasAll, {"IA03","    ","IdaSalAtvC()", "(C) - Comercializacao sobre Operacoes Conta = 2134",																	"Verifique o valor da(s) conta(s) '2134' no balancete", " AND B8F_COMERC > 0 " } )
	aAdd( aRegrasAll, {"IA04","    ","IdaSalAtvD()", "(D) - Debitos com Operadoras Conta = 2135",																				"Verifique o valor da(s) conta(s) '2135' no balancete", " AND B8F_DEBOPE > 0 " } )
	aAdd( aRegrasAll, {"IA05","    ","IdaSalAtvE()", "(E) - Outros Debitos Operacionais com Planos Conta = 2131+ 2138",												"Verifique o valor da(s) conta(s) '2131','2138' no balancete", " AND B8F_OUDBOP > 0 " } )
	aAdd( aRegrasAll, {"IA06","    ","IdaSalAtvF()", "(F) - Tributos e Encargos a Recolher Conta = 216",																	"Verifique o valor da(s) conta(s) '216' no balancete", " AND B8F_TITSEN > 0 " } )
	aAdd( aRegrasAll, {"IA07","    ","IdaSalAtvG()", "(G) - Depositos de Beneficiarios - Contraprest/Seguros Recebidos - Plano de contas conta = 2185",		"Verifique o valor da(s) conta(s) '2185' no balancete", " AND B8F_DEPBEN > 0 " } )
	aAdd( aRegrasAll, {"IA08","    ","IdaSalAtvH()", "(H) - Prestadores de Serv. de Assistencia a Saude Subgrupo = 214",												"Verifique o valor da(s) conta(s) '214' no balancete", " AND B8F_SERASS > 0 " } )
	aAdd( aRegrasAll, {"IA09","    ","IdaSalAtvI()", "(I) - Debitos com Aquisicao de Carteira - Plano de contas = 2186",												"Verifique o valor da(s) conta(s) '2186' no balancete", " AND B8F_AQUCAR > 0 " } )
	aAdd( aRegrasAll, {"IA10","    ","IdaSalAtvJ()", "(J) - Outros Debitos a Pagar Conta = 2188",																				"Verifique o valor da(s) conta(s) '2188' no balancete", " AND B8F_OUDBPG > 0 " } )

	aRegras := { GetTabIDSA(), aRegrasAll, aRegrasIDSA }

Return aRegras