#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCCDO

Manutencao de CBR - Risco de Crédito - Parcela 1

@author jose.paulo
@since 12/04/2021
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCCDO(lAuto)
	Local oBrowse	:= Nil
	Default lAuto   := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B6X')
	oBrowse:SetDescription("DIOPS - CBR - Risco de Crédito - Parcela 1")
	oBrowse:AddLegend( "B6X_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B6X_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B6X_STATUS=='3'", "RED",	"Invalido" )
	oBrowse:SetFilterDefault( "B6X_FILIAL=B3D->B3D_FILIAL .And. B6X_CODOPE=B3D->B3D_CODOPE .And. B6X_CODOBR=B3D->B3D_CDOBRI .And. B6X_ANOCMP=B3D->B3D_ANO .And. B6X_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef( 'CENMVCCDO' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("CBR - Risco de Crédito - Parcela 1", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
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

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("B6X", B6X->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				                 , 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCCDO'	                 , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMVCCDO'	                 , 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMVCCDO'   	             , 0 , 4 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'CENRCRDEOP(.F.)'		                 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("24")'	                 , 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.CENMVCCDO'	                 , 0 , 5 , 0 , NIL } )
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabCrDO())'	         , 0 , 7 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B6X

@return oModel	objeto model criado

@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB6X 	:= FWFormStruct( 1, 'B6X', , )
	Local oModel		:= Nil
	Local oEvent  := CENEVTCDO():New()

	oModel	:= MPFormModel():New( "DIOPS - CBR - Risco de Crédito - Parcela 1")
	oModel:AddFields( 'B6XMASTER', , oStruB6X )
	oModel:GetModel( 'B6XMASTER' ):SetDescription( "DIOPS - CBR - Risco de Crédito - Parcela 1" )
	oModel:SetPrimaryKey({'B6X_FILIAL','B6X_CODOPE','B6X_CODOBR','B6X_ANOCMP','B6X_CDCOMP','B6X_REFERE','B6X_OPECRD'})
	oModel:InstallEvent("QDRCDO", /*cOwner*/, oEvent)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B6X

@return oView	objeto view criado

@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENMVCCDO' )
	Local oStruB6X := FWFormStruct( 2, 'B6X' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B6X' , oStruB6X , 'B6XMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_B6X', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_B6X', 'DIOPS - CBR - Risco de Crédito - Parcela 1' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerTamCp
@author jose.paulo
@since 30/03/2021
/*/
//--------------------------------------------------------------------------------------------------
function VerTamCp(cVal,cTipo,lAuto)
	Local lOK          := .T.
	Local nI           := 0
	Default cVal       := 0
	Default lAuto      := .F.
	Default cTipo      := ''

	If cTipo == "1"
		If	Len(Alltrim(cVal)) <> 6
			lOK:=.F.
		EndIf

		If lOK
			For nI:=1 to Len(Alltrim(cVal))
				If !SubStr(cVal,nI,1) $ '0123456789'
					lOK:=.F.
				EndIf
			next
		EndIf

	Else
		If cVal > 100 .Or. cVal < 0
			lOK:=.F.
		EndIf
	EndIf

Return lOK

Function QtdRgCDO(lAuto)
	Local nCount   := 0
	Local aRetCdOp := {}
	Local cSql 	   := ""
	Local lRet 	   := .T.
	Default lAuto  := .F.

	cSql := " SELECT COUNT(*) AS TOTREG "
	cSql += " FROM " + RetSqlName("B6X")
	cSql += " WHERE B6X_FILIAL = '" + xFilial("B6X") + "' "
	cSql += " AND B6X_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B6X_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B6X_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B6X_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCDO",.F.,.T.)

	If !TRBCDO->(Eof())
		Do While !TRBCDO->(Eof())
			iF TRBCDO->TOTREG >= 200 .Or. lAuto
				lRet:=.F.
				IIF(lAuto,conout("O limite máximo de Operadoras cadastradas é 200"),Help(,,'HELP',,"O limite máximo de Operadoras cadastradas é 200.",1,0))
			EndIf
			TRBCDO->(DbSkip())

		EndDo
	EndIf
	TRBCDO->(DbCloseArea())
	If lAuto
		lRet:=.T.
	Endif

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTabCrDO

@author jose.paulo
@since 14/04/2021
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabCrDO()
Return "B6X"

Function GetRegCDO()
	Local aRegrasAll    := {}
	Local aRegrasBl	:= {}

	aAdd( aRegrasAll,{"CD01","    ","CENVLCDO01()", "Código do registro da Operadora junto a ANS inválido."                                                                                                   ,"O número do registro informado no campo Oper.Cre/Deb deve ter 6 dígitos", "" } )
	aAdd( aRegrasBl, {"CD02","    ","CENVLCDO02()", "A soma do campo Créd.Opera.  deste quadro deve ser igual ao Saldo Final da conta 1234 no balancete."                                                     ,"Verifique se o valor no campo Créd.Opera. é igual ao da conta 1234 do balancete.",	"" } )
	aAdd( aRegrasBl, {"CD03","    ","CENVLCDO03()", "A soma do campo Interc.Receb deste quadro deve ser igual ao das contas 1241X902."                                                                        ,"Verifique se o valor do campo Interc.Receb é igual a somatória das contas 1241X902",	"" } )
	aAdd( aRegrasBl, {"CD04","    ","CENVLCDO04()", "A soma do campo Outros Cr.Op deste quadro deve ser menor ou igual ao Saldo Final das contas 1239XX082."                                                  ,"Verifique se o valor do campo Outros Cr.Op é menor ou igual a somatória das contas 1239XX082",	"" } )
	aAdd( aRegrasBl, {"CD05","    ","CENVLCDO05()", "A soma do campo Prov.Perdas  deste quadro deve ser menor ou igual ao Saldo Final das contas 1239XX089 e menor ou igual ao valor do campo 4 deste quadro.","Verifique se o valor do campo Prov.Perdas é menor ou igual a somatória das contas 1239XX089 e menor ou igual ao valor do campo 4 deste quadro.",	"" } )
	aAdd( aRegrasBl, {"CD06","    ","CENVLCDO06()", "A soma do campo Outr.Créd.Op deste quadro deve ser menor ou igual ao Saldo Final das contas 1241X9082."                                                  ,"Verifique se o valor do campo Outr.Créd.Op é menor ou igual a somatória das contas 1241X9082",	"" } )
	aAdd( aRegrasBl, {"CD07","    ","CENVLCDO07()", "A soma do campo Prov.Perdas  deste quadro deve ser menor ou igual ao Saldo Final das contas 1241X9089 e menor ou igual ao campo 6 deste quadro."         ,"Verifique se o valor do campo Prov.Perdas é menor ou igual a somatória das contas 1241X9089 e menor ou igual ao campo 6 deste quadro.",	"" } )
	aAdd( aRegrasBl, {"CD08","    ","CENVLCDO08()", "A soma do campo Déb.Op.Ass   deste quadro deve ser igual ao Saldo Final da conta 2135."                                                                  ,"Verifique se o valor do campo Déb.Op.Ass é igual a somatória das contas 2135",	"" } )
	aAdd( aRegrasBl, {"CD09","    ","CENVLCDO09()", "A soma do campo Prov.Even.Si deste quadro deve ser igual ao Saldo Final das contas 2111XX033 e 2311XX033."                                               ,"Verifique se o valor do campo Prov.Even.Si é igual a somatória das contas 2111XX033 e 2311XX033.",	"" } )
	aAdd( aRegrasBl, {"CD10","    ","CENVLCDO10()", "A soma do campo Outr.Debitos deste quadro deve ser igual ao Saldo Final das contas 214889082."                                                           ,"Verifique se o valor do campo Outr.Debitos é igual a somatória das contas 214889082",	"" } )

	aRegras := { GetTabCrDO(), aRegrasAll, aRegrasBl }

Return aRegras