#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA421.CH"
//-----------------------------------
/*/{Protheus.doc} WMSA421
Monitor Carga x WMS

@author Felipe Machado de Oliveira
@version P12
@Since	30/11/12
@obs Monitoramento da Carga x WMS
/*/
//-----------------------------------
Static cSituacao := '1'
Static oBrowse   := Nil

Function WMSA421()
Local nTime   := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela (Default = 10 segundos)

	If Pergunte("WMSA421",.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('DAK')
		oBrowse:SetOnlyFields({'DAK_COD','DAK_PESO','DAK_CAPVOL','DAK_VALOR','DAK_DATA'})
		oBrowse:SetMenuDef('WMSA421')
		oBrowse:SetDescription(STR0013) // Carga
		oBrowse:AddLegend({|| WMSA421MNT(1) == '1'},"RED",STR0001) // Não iniciado
		oBrowse:AddLegend({|| cSituacao == '2'},"YELLOW" ,STR0002) // Em andamento
		oBrowse:AddLegend({|| cSituacao == '3'},"ORANGE" ,STR0003) // Finalizado
		oBrowse:AddLegend({|| cSituacao == '4'},"BLUE"   ,STR0004) // Aguardando faturamento
		oBrowse:AddLegend({|| cSituacao == '5'},"GREEN"  ,STR0005) // Faturado
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:SetParam({|| SelFiltro() })
		oBrowse:SetTimer({|| RefreshBrw() }, Iif(nTime <= 0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR05 < 4)})
		oBrowse:DisableDetails()
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:Activate()

	EndIf
Return .T.
//-----------------------------------
/*/{Protheus.doc} MenuDef
MenuDef

@author Felipe Machado de Oliveira
@version P12
@Since	30/11/12
/*/
//-----------------------------------
Static Function MenuDef()
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0007 ACTION "WMSA421A()" OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} SelFiltro
Seleciona um Novo Filtro ao Browse

@author Felipe Machado de Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SelFiltro()
Local lRet := .T.
	If (lRet := Pergunte('WMSA421',.T.))
		oBrowse:oTimer:lActive := (MV_PAR05 < 4)
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:Refresh()
	EndIf
Return lRet
//-----------------------------------
/*/{Protheus.doc} RefreshBrw
Atualiza Browse

@author Felipe Machado de Oliveira
@version P12
@Since	03/12/12
@obs Atualiza Browse
/*/
//-----------------------------------
Static Function RefreshBrw()
Local nPos := oBrowse:At()
	If MV_PAR05 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR05 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	ElseIf MV_PAR05 == 3
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.
//-----------------------------------------------------
/*/{Protheus.doc} WMA421SCAR
Retorna a situação da carga com base nos movimentos WMS
@author Felipe Machado de Oliveira
@version P12
@Since	04/12/13
@param cCarga, Caracter, (Código da Carga)
@param cPedido, Caracter, (Código do Pedido)
@obs Situação da Carga
     1 Não iniciado
     2 Em Andamento
     3 Interrompida
     4 Aguardando Faturamento
     5 Finalizada
/*/
//-----------------------------------------------------
Function WMSA421MNT(nOpcao,nQtdLib,nQtdEmp)
Local aAreaAnt  := GetArea()
Local aTamSx3   := {}
Local cQuery    := ""
Local cAliasSC9 := ""
Local cCarga    := ""
Local cSeqCar   := ""
Local cPedido   := ""
Local cItem     := ""
Local cSequen   := ""
Default nOpcao  := 1
	
	nQtdLib   := 0
	nQtdEmp   := 0
	cCarga    := DAK->DAK_COD
	cSeqCar   := DAK->DAK_SEQCAR
	If nOpcao > 1
		cPedido := DAI->DAI_PEDIDO
	EndIf
	If nOpcao == 3
		cItem   := SC9->C9_ITEM
		cSequen := SC9->C9_SEQUEN
	EndIf
	
	cQuery := " SELECT SC9.C9_CARGA,"
	cQuery +=        " SUM(SC9.C9_QTDLIB) QTDLIB,"
	cQuery +=        " SUM(SDC.DC_QUANT)  QTDEMP,"
	cQuery +=        " COUNT(SC9.C9_FILIAL) NRO_PED,"
	cQuery +=        " SUM(CASE WHEN SC9.C9_NFISCAL <> '"+Space(TamSX3("C9_NFISCAL")[1])+"' THEN 1 ELSE 0 END) NRO_FAT,"
	cQuery +=        " SUM(CASE WHEN SC9.C9_BLWMS = '05' THEN 1 ELSE 0 END) NRO_LIB"
	cQuery +=   " FROM "+RetSqlName("SC9")+" SC9"
	cQuery +=   " LEFT JOIN "+RetSqlName("SDC")+" SDC"
	cQuery +=     " ON SDC.DC_FILIAL =  '"+xFilial("SDC")+"'"
	cQuery +=    " AND SDC.DC_PEDIDO = SC9.C9_PEDIDO"
	cQuery +=    " AND SDC.DC_ITEM = SC9.C9_ITEM"
	cQuery +=    " AND SDC.DC_SEQ = SC9.C9_SEQUEN"
	cQuery +=    " AND SDC.D_E_L_E_T_ = '  '"
	cQuery +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=    " AND SC9.C9_CARGA = '"+cCarga+"'"
	cQuery +=    " AND SC9.C9_SEQCAR = '"+cSeqCar+"'"
	If !Empty(cPedido)
		cQuery += " AND SC9.C9_PEDIDO = '"+cPedido+"'"
	EndIf
	If !Empty(cItem)
		cQuery += " AND SC9.C9_ITEM = '"+cItem+"'"
		cQuery += " AND SC9.C9_SEQUEN = '"+cSequen+"'"
	EndIf
	cQuery +=    " AND SC9.D_E_L_E_T_ =  '  '"
	cQuery +=  " GROUP BY SC9.C9_CARGA"
	cQuery := ChangeQuery(cQuery)
	cAliasSC9 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSC9,.F.,.T.)
	aTamSX3 := TamSx3("C9_QTDLIB"); TcSetField(cAliasSC9,'QTDLIB','N',aTamSX3[1],aTamSX3[2])
	aTamSX3 := TamSx3("DC_QUANT") ; TcSetField(cAliasSC9,'QTDEMP','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSC9,'NRO_PED','N',10,0)
	TcSetField(cAliasSC9,'NRO_FAT','N',10,0)
	TcSetField(cAliasSC9,'NRO_LIB','N',10,0)
	If (cAliasSC9)->(!Eof())
		nQtdLib := (cAliasSC9)->QTDLIB
		nQtdEmp := (cAliasSC9)->QTDEMP
		If (cAliasSC9)->NRO_PED == (cAliasSC9)->NRO_FAT
			cSituacao := '5'
		ElseIf (cAliasSC9)->NRO_PED == (cAliasSC9)->NRO_LIB
				cSituacao := '4'
		ElseIf QtdComp(nQtdLib) == QtdComp(nQtdEmp)
				cSituacao := '3'
		ElseIf QtdComp(nQtdEmp) == QtdComp(0)
				cSituacao := "1"
		Else
			cSituacao := "2"
		EndIf
	EndIf
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cSituacao

/*---------------------------------------------------------------------------
---MontaQuery
---Retorna expressao do filtro
---Alexsander
---------------------------------------------------------------------------*/
Static Function MontaQuery()
Local cQuery := ''
	cQuery :=    " DAK_COD >= '"+MV_PAR01+"'"
	cQuery +=    " AND DAK_COD <= '"+MV_PAR02+"'"
	cQuery +=    " AND DAK_DATA >= '"+DTOS(MV_PAR03)+"'"
	cQuery +=    " AND DAK_DATA <= '"+DTOS(MV_PAR04)+"'"
Return(cQuery)
