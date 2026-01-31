#INCLUDE 'WMSV075.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#DEFINE CRLF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsV075 | Autor ³ Alex Egydio              ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conferencia de mercadorias                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static cServico   := ""
Static cOrdTar    := ""
Static cTarefa    := ""
Static cAtividade := ""
Static cArmazem   := ""
Static cEndereco  := ""
Static cOrdSep    := ""
Static lWmsDaEn   := .F.
Static lWV076LOT  := ExistBlock("WV076LOT")
Static lWV075REG  := ExistBlock("WV075REG")
Static lWV075DOC  := ExistBlock("WV075DOC")

Function WmsV075()
Local aAreaAnt    := GetArea()
Local aAreaDC5    := DC5->(GetArea())
Local lRet        := .T.
//-- Salva todas as teclas de atalho anteriores
Local aSavKey     := VTKeys()
Local aAreaSDB    := SDB->(GetArea())
Local lCarga      := .F.
Local cCarga      := Space(Len(SDB->DB_CARGA))
Local cPedido     := Space(Len(SDB->DB_DOC))
Local lTrocouDoc  := .F.
Local cWmsUMI     := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Local lAbandona   := .F.

cServico   := SDB->DB_SERVIC
cOrdTar    := SDB->DB_ORDTARE
cTarefa    := SDB->DB_TAREFA
cAtividade := SDB->DB_ATIVID
cArmazem   := SDB->DB_LOCAL
cEndereco  := Space(Len(SDB->DB_LOCALIZ))
cOrdSep    := "01"
lWmsDaEn   := SuperGetMV("MV_WMSDAEN",.F.,.F.)

If !(cWmsUMI$'0|1|2|3|4|5')
	DLVTAviso('SIGAWMS',STR0002) //'Parametro MV_WMSUMI incorreto...'
	lRet := .F.
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
	Return(lRet)
EndIf

DC5->(DbSetOrder(1))
If DC5->(MsSeek(xFilial("DC5")+cServico+cOrdTar))
	DC5->(DbSkip(-1))
	If DC5->DC5_SERVIC == cServico
		cOrdSep := DC5->DC5_ORDEM
	EndIf
EndIf

Do While lRet .And. !lAbandona
	//-- Indica ao operador o endereco de destino da conferencia
	DLVTCabec(STR0001,.F.,.F.,.T.) //Conferência
	DLVEndereco(0,0,SDB->DB_LOCALIZ,SDB->DB_LOCAL,,,STR0003) //'Va para o Endereco'
	If (VTLastKey()==27)
		WMSV075ESC(@lAbandona)
		Loop
	EndIf
	Exit
EndDo

Do While lRet .And. !lAbandona
	DLVTCabec(STR0001,.F.,.F.,.T.)
	If !lWmsDaEn
		@ 01, 00 VTSay Padr(STR0055+cArmazem,VTMaxCol()) //Armazem
	EndIf
	@ 02, 00 VTSay PadR(STR0004,VTMaxCol()) //'Endereco'
	@ 03, 00 VTSay PadR(SDB->DB_LOCALIZ,VTMaxCol())
	@ 05, 00 VTSay PadR(STR0005, VTMaxCol()) //'Confirme !'
	@ 06, 00 VTGet cEndereco Pict '@!' Valid ValidEnder(SDB->DB_LOCALIZ,@cEndereco)
	VTRead()
	If (VTLastKey()==27)
		WMSV075ESC(@lAbandona)
		Loop
	EndIf
	Exit
EndDo

Do While lRet .And. !lAbandona
	lCarga  := WmsCarga(SDB->DB_CARGA)
	cCarga  := Space(TamSX3("DB_CARGA")[1])
	cPedido := Space(TamSX3("DB_DOC")[1])
	// Permite apresentar uma tela ou executar alguma ação antes da confirmação da carga/pedido
	If lWV075DOC
		ExecBlock("WV075DOC", .F., .F.)
	EndIf
	// Solicita confirmação da carga/pedido
	If lCarga
		DLVTCabec(STR0001,.F.,.F.,.T.)
		@ 01, 00 VTSay PadR(STR0006,VTMaxCol()) //"Carga"
		@ 02, 00 VTSay PadR(SDB->DB_CARGA,VTMaxCol())
		@ 04, 00 VTSay PadR(STR0005, VTMaxCol()) //'Confirme !'
		@ 05, 00 VTGet cCarga Picture '@!' Valid ValidCarga(cCarga,SDB->DB_CARGA)
	Else
		DLVTCabec(STR0001,.F.,.F.,.T.)
		@ 01, 00 VTSay PadR(STR0007,VTMaxCol()) //"Pedido"
		@ 02, 00 VTSay PadR(SDB->DB_DOC,VTMaxCol())
		@ 04, 00 VTSay PadR(STR0005, VTMaxCol()) //'Confirme !'
		@ 05, 00 VTGet cPedido Picture '@!' Valid ValidPedido(cPedido,SDB->DB_DOC)
	EndIf
	VTRead()
	If (VTLastKey()==27)
		WMSV075ESC(@lAbandona)
		Loop
	EndIf
	If lCarga
		If Empty(cCarga)
			cCarga := SDB->DB_CARGA
		EndIf
	Else
		If Empty(cPedido)
			cPedido := SDB->DB_DOC
		EndIf
	EndIf
	//-- Se o operador informou outro documento tira a reserva feita pelo DLGV001
	If ( lCarga .And. !Empty(cCarga) .And. cCarga <> SDB->DB_CARGA) .Or. ;
		(!lCarga .And. !Empty(cPedido) .And. cPedido <> SDB->DB_DOC  )
		If !WmsQuestion(STR0021) //"Deseja alterar pedido/carga?"
			Loop
		Else
			lTrocouDoc := .T.
		EndIf
	EndIf
	//-- Efetua as validações para a carga/pedido informado
	If !ValidDocto(cCarga,cPedido,lTrocouDoc)
		Loop
	EndIf
	Exit
EndDo

If lRet .And. !lAbandona
	//Efetua a conferencia dos produtos deste embarque
	lRet := CofPrdLot(cCarga,cPedido,lCarga)
	DLVAltSts(.F.) //Não altera a situação da atividade no DLGV0001
EndIf

VTClear()
VTKeyBoard(chr(13))
VTInkey(0)
//-- Restaura as teclas de atalho anteriores
VTKeys(aSavKey)
RestArea(aAreaDC5)
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Permite ir executando a conferência dos produtos, informando os dados
//de lote, sub-lote e quantidade a ser conferida
//-----------------------------------------------------------------------------
Static Function CofPrdLot(cCarga,cPedido,lCarga)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
//-- Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote   := SuperGetMV('MV_WMSLOTE',.F.,.T.)
Local lWMSConf   := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local cWmsUMIAux := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Local cWmsUMI    := cWmsUMIAux
Local cProduto   := ""
Local cPrdAnt    := ""
Local cDescPro   := ""
Local cDescPr2   := ""
Local cDescPr3   := ""
Local cLoteCtl   := ""
Local cSubLote   := ""
Local nQtConf    := 0
Local cPictQt    := ""
Local cUM        := ""
Local cDscUM     := ""
Local aUNI       := {}
Local nItem      := 0
Local lEncerra   := .F.
Local lAbandona  := .F.
Local nAviso     := 0
Local nQtdNorma  := 0
Local nQtde1UM   := 0
Local nQtde2UM   := 0
Local nLin       := 0
Local xRetPE     := Nil
Local cLoteVazio := Space(TamSx3("DB_LOTECTL")[1])
Local cSublVazio := Space(TamSx3("DB_NUMLOTE")[1])

	// Permite indicar a rotina deve solicitar o lote no processo de conferência
	If lWV076LOT
		xRetPE   := ExecBlock("WV076LOT",.F.,.F.)
		lWmsLote := Iif(ValType(xRetPE)=="L",xRetPE,lWmsLote)
	EndIf

	//-- Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
	VTSetKey(17,{||ShowPrdCof(cCarga,cPedido,lCarga,lWmsLote)},STR0041) //'Ja Conferidos'

	While !lEncerra .And. !lAbandona
		cProduto := Space(128)
		cDescPro := Space(VTMaxCol())
		cDescPr2 := Space(VTMaxCol())
		cDescPr3 := Space(VTMaxCol())
       	cLoteCtl := cLoteVazio
		cSubLote := cSublVazio

		//--  01234567890123456789
		//--0 ____Conferência_____
		//--1 Pedido: 000000       // Carga: 000000
		//--2 Informe o Produto
		//--3 PA1
		//--4 Informe o Lote
		//--5 AUTO000636
		//--6 Qtde 999.00 UM
		//--7               240.00
		DLVTCabec(STR0001,.F.,.F.,.T.) //Conferência
		If lCarga
			@ 01,00  VtSay STR0006 + ': ' + cCarga //Carga
		Else
			@ 01,00  VtSay STR0007 + ': ' + cPedido //Pedido
		EndIf
		@ 02,00  VTSay STR0008 //Informe o Produto
		@ 03,00  VtGet cProduto Picture "@!" Valid ValidPrdLot(cCarga,cPedido,@cProduto,@cDescPro,@cDescPr2,@cDescPr3,@cLoteCtl,@cSubLote,@nQtConf)
		//-- Descricao do Produto com tamanho especifico.
		@ 04,00 VTGet cDescPro When .F.
		@ 05,00 VTGet cDescPr2 When .F.
		@ 06,00 VTGet cDescPr3 When .F.
		VtRead()

		If VTLastKey()==27
			nAviso := DLVTAviso(STR0001,STR0014,{STR0015,STR0016}) //"Deseja encerrar a conferencia?"###'Encerrar'###'Interromper'
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf

		nLin := 4
		If !lEncerra .And. !lAbandona .And. lWmsLote
			//Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
			If Rastro(cProduto)
				@ nLin,00  VtSay STR0053 //"Informe o Lote"
				@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cCarga,cPedido,cProduto,cLoteCtl)
			EndIf
			If Rastro(cProduto,"S")
				@ nLin,00 VTSay STR0054 //"Informe o Sub-Lote"
				@ nLin++,10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
			EndIf
			VtRead()

			If VTLastKey()==27
				Loop //Volta para o inicio do produto
			EndIf

			//- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			If !(Iif(Empty(cLoteCtl),.T.,ValLoteCtl(cCarga,cPedido,cProduto,cLoteCtl))) .Or. ;
				!(Iif(Empty(cSubLote),.T.,ValSubLote(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)))
				Loop //Volta para o inicio do produto
			EndIf
		EndIf

		If !lEncerra .And. !lAbandona
			//-- Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
			If cProduto <> cPrdAnt .Or. lWMSConf
				cWmsUMI   := cWmsUMIAux
				nItem     := 0
				nQtdNorma := 0
			EndIf
			cPrdAnt := cProduto
		EndIf

		If !lEncerra .And. !lAbandona
			//-- Indica a unidade de medida utilizada pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=UNITIZADOR / 4=U.M.I.
			//-- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
			If cWmsUMI == '4'
				SB5->(DbSetOrder(1))
				SB5->(MsSeek(xFilial('SB5')+cProduto))
				cWmsUMI := SB5->B5_UMIND
				If !(cWmsUMI$'1|2')
					cWmsUMI := '0'
				EndIf
			EndIf
			//-- Se db_qtsegum nao estiver preenchido
			If cWmsUMI $ '2|3|5'
				If Empty(SB1->B1_SEGUM)
					cWmsUMI := '1'
				EndIf
			EndIf
			//-- Se parametro MV_WMSUMI = 3, solicita unidade de medida a cada nova informação de quantidade
			//-- Se parametro MV_WMSUMI = 5, solicita unidade de medida somente quando informado novo produto
			If cWmsUMI $ '3|5'
				If nItem == 0 .Or. cWmsUMI == '3'
					nQtdNorma := DLQtdNorma(cProduto,SDB->DB_LOCAL,SDB->DB_ESTFIS,@cDscUM,.F.)
					nItem := Iif(nQtdNorma > 0,3,2)
					aUNI := {}
					If nQtdNorma > 0
						aAdd(aUNI,{cDscUM})
					EndIf
					aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')})
					aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,   'AH_UMRES')})
					//--  01234567890123456789
					//--0 UNIDADE
					//--1 -------------------
					//--2 PALETE PBRII
					//--3 CAIXA
					//--4 PECA
					//--5 ___________________
					//--6
					//--7  Unidade p/Confer?
					aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
					DLVTCabec()
					DLVTRodaPe(STR0011,.F.) //'Unidade p/Confer?'
					nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{STR0012},aUNI,{VTMaxCol()},,nItem) //'Unidade'
					VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
					If nItem <= 0
						nItem := Iif(nQtdNorma > 0,3,2)
					EndIf
					cDscUM := aUNI[nItem,1]
					If nQtdNorma > 0 .And. nItem == 1
						cPictQt:= '@R 9999999999'
						cUM    := ''
					ElseIf (nQtdNorma > 0 .And. nItem == 2) .Or. (nQtdNorma == 0 .And. nItem == 1)
						cPictQt:= PesqPict('SDB','DB_QTSEGUM')
						cUM    := SB1->B1_SEGUM
					ElseIf (nQtdNorma > 0 .And. nItem == 3) .Or. (nQtdNorma == 0 .And. nItem == 2)
						cPictQt:= PesqPict('SDB','DB_QUANT')
						cUM    := SB1->B1_UM
					EndIf
					If !Empty(cUM)
						SAH->(DbSetOrder(1))
						SAH->(MsSeek(xFilial('SAH')+cUM))
						cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
					EndIf
				EndIf
			Else
				If cWmsUMI $ '0|1'
					nItem  := 2
					cPictQt:= PesqPict('SDB','DB_QUANT')
					cUM    := SB1->B1_UM
				ElseIf cWmsUMI == '2'
					nItem  := 1
					cPictQt:= PesqPict('SDB','DB_QTSEGUM')
					cUM    := SB1->B1_SEGUM
				EndIf
				SAH->(DbSetOrder(1))
				SAH->(MsSeek(xFilial('SAH')+cUM))
				cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
			EndIf

			//Posiciona SB8 - para lancamento de ocorrencia no produto correto quando acionado
			WmsPosSB8(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)

			//- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			While .T.
				@ nLin++,00 VTSay PadR(STR0013+' '+cDscUM,VTMaxCol())
				@ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid !Empty(nQtConf)
				VTRead()
				If VTLastKey()==27
					Exit //Volta para o inicio do produto
				EndIf
				If !ValidQtd(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,nQtConf,nItem,nQtdNorma,@nQtde1UM,@nQtde2UM)
					nQtConf := 0
					nLin -= 2
					Loop
				EndIf
				Exit
			EndDo

			If VTLastKey()==27
				Loop
			EndIf
		EndIf

		//Somente grava a quantidade se o usuário não cancelar
		If !lEncerra .And. !lAbandona
			GravCofOpe(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,nQtde1UM)
			// Permite executar tratamentos adicionais a partir do registro de produtos conferidos
			If lWV075REG
				ExecBlock("WV075REG",.F.,.F.,{cCarga,cPedido,cProduto,cLoteCtl,cSubLote,cArmazem,cEndereco,cServico,cOrdTar,cTarefa,cAtividade})
			EndIf
		EndIf
		//Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
		If lEncerra
			lEncerra := FinCofExp(cCarga,cPedido)
		EndIf
		//Se o usuário optou por interromper, deve verificar se pode sair da conferência
		//Caso não haja mais nada para ser executado, não será possível efetuar
		//a liberação da expedição para o faturamento
		If lAbandona
			lAbandona := SaiCofExp(cCarga,cPedido)
		EndIf
	EndDo

//Restaura tela anterior
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return

//-----------------------------------------------------------------------------
// Exibe os produtos e quantidade conferida para cada um deles
//-----------------------------------------------------------------------------
Static Function ShowPrdCof(cCarga,cPedido,lCarga,lWmsLote)
Local aAreaAnt   := GetArea()
Local aProduto   := {}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aHeaders   := {}
Local aSizes     := {}

	cQuery := "SELECT DB_PRODUTO, "
	//Se não informa o lote no coletor, ele não mostra na Query
	If lWmsLote
		cQuery += " DB_LOTECTL, DB_NUMLOTE, DB_QUANT, DB_QTDLID"
	Else
		cQuery += "SUM(DB_QUANT) DB_QUANT, SUM(DB_QTDLID) DB_QTDLID"
	EndIf
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If lCarga
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"','"+cStatExec+"')"
	cQuery += " AND DB_RECHUM   = '"+__cUserID+"'"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	//Se não informa lote ele agrupa por produto apenas
	If !lWmsLote
		cQuery += " GROUP BY DB_PRODUTO ORDER BY DB_PRODUTO"
	Else
		cQuery += " ORDER BY DB_PRODUTO, DB_LOTECTL, DB_NUMLOTE"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TCSetField(cAliasQry,'DB_QUANT' ,'N',TamSx3('DB_QUANT')[1], TamSx3('DB_QUANT')[2])
	TCSetField(cAliasQry,'DB_QTDLID','N',TamSx3('DB_QTDLID')[1],TamSx3('DB_QTDLID')[2])
	While (cAliasQry)->(!Eof())
		If lWmsLote
			AAdd(aProduto,{Iif((cAliasQry)->DB_QUANT <> (cAliasQry)->DB_QTDLID,'*',' '),(cAliasQry)->DB_PRODUTO,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->DB_PRODUTO,'SB1->B1_DESC'),(cAliasQry)->DB_LOTECTL, (cAliasQry)->DB_NUMLOTE, (cAliasQry)->DB_QTDLID})
		Else
			AAdd(aProduto,{Iif((cAliasQry)->DB_QUANT <> (cAliasQry)->DB_QTDLID,'*',' '),(cAliasQry)->DB_PRODUTO,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->DB_PRODUTO,'SB1->B1_DESC'), (cAliasQry)->DB_QTDLID})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

	If lWmsLote
		aHeaders := {' ',RetTitle("DB_PRODUTO"),RetTitle("B1_DESC"),RetTitle("DB_LOTECTL"),RetTitle("DB_NUMLOTE"),STR0040} //Produto|Descrição|Lote|Sub-Lote|Qtde Conferida
		aSizes   := {1,TamSx3("DB_PRODUTO")[1],30,TamSx3("DB_LOTECTL")[1],TamSx3("DB_NUMLOTE")[1],11}
	Else
		aHeaders := {' ',RetTitle("DB_PRODUTO"),RetTitle("B1_DESC"),STR0040} //Produto|Descrição|Qtde Conferida
		aSizes   := {1,TamSx3("DB_PRODUTO")[1],30,11}
	EndIf
	VtClearBuffer()
	DLVTCabec(STR0001,.F.,.F.,.T.) //Produto
	VTaBrowse(1,,,,aHeaders,aProduto,aSizes)
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

//-----------------------------------------------------------------------------
// Valida a informação do campo Carga
//-----------------------------------------------------------------------------
Static Function ValidCarga(cCargaInf,cCargaSys)
Local aAreaAnt := GetArea()
Local lRet
	//Se não informou a carga retorna
	If Empty(cCargaInf)
		Return .F.
	EndIf
	//Se a carga informada é a mesma convocada
	If cCargaInf == cCargaSys
		Return .T.
	EndIf
	//Se a carga é diferente, deve validar se existe esta carga
	cCargaInf := PadR(cCargaInf,TamSX3("DAK_COD")[1])
	DAK->(DbSetOrder(1)) //DAK_FILIAL+DAK_COD
	If DAK->(!DbSeek(xFilial("DAK")+cCargaInf))
		DLVTAviso("SIGAWMS",STR0019) //Carga inválida!
		lRet := .F.
	EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida a informação do campo Pedido
//-----------------------------------------------------------------------------
Static Function ValidPedido(cPedidoInf,cPedidoSys)
Local aAreaAnt := GetArea()
Local lRet
	//Se não informou a Pedido retorna
	If Empty(cPedidoInf)
		Return .F.
	EndIf
	//Se a Pedido informada é a mesma convocada
	If cPedidoInf == cPedidoSys
		Return .T.
	EndIf
	//Se o pedido é diferente, deve validar se existe este pedido
	cPedidoInf := PadR(cPedidoInf,TamSX3("C5_NUM")[1])
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	If SC5->(!DbSeek(xFilial("SC5")+cPedidoInf))
		DLVTAviso("SIGAWMS",STR0020) //Pedido inválido!
		lRet := .F.
	EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida a informação da carga/pedido informado, trocando o operador se for o caso
//-----------------------------------------------------------------------------
Static Function ValidDocto(cCarga,cPedido,lTrocouDoc)
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local cServAnt   := cServico
Local cOrdTarAnt := cOrdTar
local cTarAnt    := cTarefa
Local cAtivAnt   := cAtividade
Local cArmAnt    := cArmazem
	//Se trocou a carga ou o pedido, deve validar a nova informação
	If lTrocouDoc
		If !HasTarDoc(cCarga,cPedido)
			If WmsCarga(cCarga)
				DLVTAviso("SIGAWMS",WmsFmtMsg(STR0022,{{"[VAR01]",cArmazem}})) // Não existem atividades de conferência para a carga informada para o armazém [VAR01].
			Else
				DLVTAviso("SIGAWMS",WmsFmtMsg(STR0023,{{"[VAR01]",cArmazem}})) // Não existem atividades de conferência para o pedido informado para o armazém [VAR01].
			EndIf
			Return .F.
		EndIf
	EndIf
	//-- Se algum item do mesmo documento foi convocado p/ outro operador.
	If TarExeOper(cCarga,cPedido)
		DLVTAviso("SIGAWMS",STR0024) //"Atividades da tarefa em andamento por outro operador."
		//Retorna variáveis
		cServico  := cServAnt
		cOrdTar   := cOrdTarAnt
		cTarefa   := cTarAnt
		cAtividade:= cAtivAnt
		cArmazem  := cArmAnt
		Return .F.
	EndIf

	If lTrocouDoc
		RecLock('SDB', .F.)  //-- Trava para gravacao
		SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
		SDB->DB_STATUS := cStatAExe // Atividade A Executar
		//-- Libera o registro do arquivo SDB
		MsUnlock()
		If lLiberaRH
			//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
			CancRHServ(SDB->DB_CARGA,SDB->DB_DOC,SDB->DB_SERVIC)
		EndIf
		If WmsCarga(cCarga)
			DLVTAviso(STR0001,PadC(STR0025,VTMaxCol())+STR0026) //"Atenção" - "Carga alterada. Executar a conferencia da carga informada."
		Else
			DLVTAviso(STR0001,PadC(STR0025,VTMaxCol())+STR0027) //"Atenção" - "Pedido alterado. Executar a conferencia do pedido informado."
		EndIf
	EndIf
	//-- Atribui o documento todo para o usuário
	AddRHServ(cCarga,cPedido)
Return (.T.)

//-----------------------------------------------------------------------------
// Verifica se tem atividades para o novo documento informado
//-----------------------------------------------------------------------------
Static Function HasTarDoc(cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.DB_SERVIC,"
	cQuery +=       " SDB.DB_ORDTARE,"
	cQuery +=       " SDB.DB_TAREFA,"
	cQuery +=       " SDB.DB_ATIVID,"
	cQuery +=       " SDB.DB_LOCAL"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND (DB_RECHUM  = '"+cRecHVazio+"'"
	cQuery += " OR   DB_RECHUM  = '"+__cUserID+"')"
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (lRet := (cAliasQry)->(!Eof()))
		//Atribui variáveis
		cServico   := (cAliasQry)->DB_SERVIC
		cOrdTar    := (cAliasQry)->DB_ORDTARE
		cTarefa    := (cAliasQry)->DB_TAREFA
		cAtividade := (cAliasQry)->DB_ATIVID
		cArmazem   := (cAliasQry)->DB_LOCAL
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Analisa se a tarefa está em andamento por outro operador.
//-----------------------------------------------------------------------------
Static Function TarExeOper(cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " INNER JOIN "+RetSqlName('DCD')+" DCD"
	cQuery +=  " ON DCD_FILIAL   = '"+xFilial('DCD')+"'"
	cQuery +=   " AND DCD_CODFUN = DB_RECHUM"
	cQuery +=   " AND DCD_STATUS IN ('1','2')" // Somente se o operador estiver livre ou ocupado
	cQuery +=   " AND DCD.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC    = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_RECHUM  <> '"+cRecHVazio+"'"
	cQuery += " AND DB_RECHUM  <> '"+__cUserID+"'"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND SDB.D_E_L_E_T_  = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Retira recurso humano atribuido as atividades de conferencia
// de outros itens do mesmo pedido / carga.
//-----------------------------------------------------------------------------
Static Function CancRHServ(cCarga,cPedido,cServic)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cAliasQry := GetNextAlias()
	cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
	cQuery += " FROM " + RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery += " AND DB_ESTORNO  = ' '"
	cQuery += " AND DB_ATUEST   = 'N'"
	cQuery += " AND DB_SERVIC   = '"+cServic+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_STATUS   = '"+cStatAExe+"'" // Atividade A Executar
	cQuery += " AND DB_RECHUM   = '"+__cUserID+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		SDB->(MsGoto((cAliasQry)->SDBRECNO))
		RecLock('SDB', .F.)  // Trava para gravacao
		SDB->DB_RECHUM := cRecHVazio
		MsUnlock()
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

Return

//-----------------------------------------------------------------------------
// Atribui o recurso humano para as atividades de conferencia
// de outros itens do mesmo pedido / carga.
//-----------------------------------------------------------------------------
Static Function AddRHServ(cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_STATUS   IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND DB_RECHUM   = '"+cRecHVazio+"'"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		SDB->(MsGoto((cAliasQry)->SDBRECNO))
		RecLock('SDB', .F.)  // Trava para gravacao
		SDB->DB_RECHUM := __cUserID
		MsUnlock()
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida o produto informado, verificando se o mesmo pertence ao pedido/carga
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValidPrdLot(cCarga,cPedido,cProduto,cDescPro,cDescPr2,cDescPr3,cLoteCtl,cSubLote,nQtde)
Local lRet     := .T.
Local nMax     := VTMaxCol()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lVerSimp := SuperGetMV('MV_WMSVSTC',.F.,.F.) //-- Versao simplificada telas de conferência no coletor RF

	lRet := DLVValProd(@cProduto,@cLoteCtl,@cSubLote,@nQtde)

	//Deve validar se o produto possui quantidade para ser conferida
	If lRet
		If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,.F.)) == 0
			DLVTAviso('SIGAWMS',STR0028) //"Produto não pertence a conferência."
			lRet := .F.
		EndIf
		//Verifica se possui alguma quantidade para conferir liberada
		If lRet .And. QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)) == 0
			//Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
			If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,.F.,.T.)) > 0
				DLVTAviso('SIGAWMS',STR0042) //"Conferência do produto bloqueada."
			Else
				DLVTAviso('SIGAWMS',STR0043) //"Conferência do produto finalizada."
			EndIf
			lRet := .F.
		EndIf
		If lRet .And. QtdComp(QtdPrdSep(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)) == 0
			DLVTAviso('SIGAWMS',STR0029) //"Produto não possui quantidade separada para conferência."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !lVerSimp
		//-- Divide Descr. do produto em 3 linhas
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial('SB1')+cProduto))
		cDescPro := SubStr(SB1->B1_DESC,       1,nMax)
		cDescPr2 := SubStr(SB1->B1_DESC,  nMax+1,nMax)
		cDescPr3 := SubStr(SB1->B1_DESC,2*nMax+1,nMax)
		VtGetRefresh("cProduto")
		VtGetRefresh("cDescPro")
		VtGetRefresh("cDescPr2")
		VtGetRefresh("cDescPr3")
		DLVTRodape()
		VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	EndIf

	If !lRet
		cProduto := Space(128)
		VTKeyBoard(Chr(20))
	EndIf

Return lRet

//-----------------------------------------------------------------------------
// Valida o produto/lote informado, verificando se o mesmo pertence ao pedido/carga
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValLoteCtl(cCarga,cPedido,cProduto,cLoteCtl)
Local lRet  := .T.

	If Empty(cLoteCtl)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,/*cSubLote*/,.F.)) == 0
		DLVTAviso('SIGAWMS',STR0030) //"Produto/Lote não pertence a conferência."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	//Verifica se possui alguma quantidade para conferir liberada
	If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl)) == 0
		//Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,,.F.,.T.)) > 0
			DLVTAviso('SIGAWMS',STR0044) //"Conferência do Produto/Lote bloqueada."
		Else
			DLVTAviso('SIGAWMS',STR0045) //"Conferência do Produto/Lote finalizada."
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(QtdPrdSep(cCarga,cPedido,cProduto,cLoteCtl)) == 0
		DLVTAviso('SIGAWMS',STR0031) //"Produto/Lote não possui quantidade separada para conferência."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet

//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo pertence ao pedido/carga
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValSubLote(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
Local lRet  := .T.

	If Empty(cSubLote)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,.F.)) == 0
		DLVTAviso('SIGAWMS',STR0032) //"Produto/Rastro não pertence a conferência."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	//Verifica se possui alguma quantidade para conferir liberada
	If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)) == 0
		//Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,.F.,.T.)) > 0
			DLVTAviso('SIGAWMS',STR0046) //"Conferência do Produto/Rastro bloqueada."
		Else
			DLVTAviso('SIGAWMS',STR0047) //"Conferência do Produto/Rastro finalizada."
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(QtdPrdSep(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)) == 0
		DLVTAviso('SIGAWMS',STR0033) //"Produto/Rastro não possui quantidade separada para conferência."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet

//-----------------------------------------------------------------------------
//Valida a quantidade informada efetuando a conversão das unidades de medida
//-----------------------------------------------------------------------------
Static Function ValidQtd(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,nQtConf,nItem,nQtdNorma,nQtde1UM,nQtde2UM)
Local lRet       := .T.
Local nQtdPrdCof := 0
Local nQtdPrdSep := 0
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM  := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))

	If Empty(nQtConf)
		Return .F.
	EndIf
	//-- O sistema trabalha sempre na 1a.UM
	If nQtdNorma > 0 .And. nItem == 1
		//-- Converter de U.M.I. p/ 1a.UM
		nQtde1UM := (nQtConf*nQtdNorma)
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	ElseIf (nQtdNorma > 0 .And. nItem == 2) .Or. (nQtdNorma == 0 .And. nItem == 1)
		//-- Converter de 2a.UM p/ 1a.UM
		nQtde2UM := nQtConf
		nQtde1UM := ConvUm(cProduto,0,nQtde2UM,1)
	ElseIf (nQtdNorma > 0 .And. nItem == 3) .Or. (nQtdNorma == 0 .And. nItem == 2)
		//-- Converter de 1a.UM p/ 2a.UM
		nQtde1UM := nQtConf
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	EndIf
	//Validando as quantidades informadas
	nQtdPrdCof := QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
	If QtdComp(nQtde1UM) > QtdComp(nQtdPrdCof) .And.;
		QtdComp(Abs(nQtdPrdCof-nQtde1UM)) > QtdComp(nToler1UM)
		DLVTAviso('SIGAWMS',STR0034) //"Quantidade informada maior que a quantidade liberada para conferência."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	//Valida se a quantidade separada é maior ou igual a quantidade conferida mais o está sendo conferido
	nQtdPrdSep := QtdPrdSep(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
	nQtdPrdCof := QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,,,.T.)
	If lRet .And. QtdComp(nQtdPrdCof+nQtde1UM) > QtdComp(nQtdPrdSep) .And.;
		QtdComp(Abs(nQtdPrdSep-(nQtdPrdCof+nQtde1UM))) > QtdComp(nToler1UM)
		DLVTAviso('SIGAWMS',STR0035) //"Quantidade conferida mais a informada maior que quantidade total separada."
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf

Return lRet

//-----------------------------------------------------------------------------
//Permite carregar a quantidade do produto que está pendente de conferência
//-----------------------------------------------------------------------------
Static Function QtdPrdCof(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,lSitLib,lSitBlq,lQtdLid)
Local aAreaAnt   := GetArea()
Local nQuant     := 0
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aTamSX3    := TamSx3('DB_QUANT')
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

Default lSitLib := .T.
Default lSitBlq := .F.
Default lQtdLid := .F.

	If lQtdLid
		cQuery := "SELECT SUM(DB_QTDLID) QTD_SALDO"
	ElseIf lSitLib
		cQuery := "SELECT SUM(DB_QUANT-DB_QTDLID) QTD_SALDO"
	Else
		cQuery := "SELECT SUM(DB_QUANT) QTD_SALDO"
	EndIf
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_PRODUTO  = '"+cProduto+"'"
	If !Empty(cLoteCtl)
		cQuery += " AND DB_LOTECTL  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cSubLote)
		cQuery += " AND DB_NUMLOTE  = '"+cSubLote+"'"
	EndIf
	If lQtdLid
		cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatExec+"')"
	ElseIf lSitLib
		cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	ElseIf lSitBlq
		cQuery += " AND DB_STATUS = '"+cStatProb+"'"
	EndIf
	cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery += "  OR DB_RECHUM   = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'QTD_SALDO','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQuant := (cAliasQry)->QTD_SALDO
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant

//-----------------------------------------------------------------------------
//Permite carregar a quantidade do produto que está empenhada (já separada)
//-----------------------------------------------------------------------------
Static Function QtdPrdSep(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
Local aAreaAnt   := GetArea()
Local nQuant     := 0
Local cWhere     := ""
Local cWhereDcf  := ""
Local cAliasQry  := Nil
Local aTamSX3    := TamSx3('DB_QUANT')

    cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND SDB.DB_LOTECTL = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cSubLote)
		cWhere += " AND SDB.DB_NUMLOTE = '"+cSubLote+"'"
	EndIf
	cWhere += " AND SDB.DB_STATUS IN ('"+cStatExec+"','"+cStatManu+"')"
	cWhere += "%"
	
	cWhereDcf :="%"
	If WmsCarga(cCarga)
		cWhereDcf += " AND DCF.DCF_CARGA  = '"+cCarga+"'"
	Else
		cWhereDcf += " AND DCF.DCF_DOCTO    = '"+cPedido+"'"
	EndIf
	cWhereDcf += "%"
	
	cAliasQry := GetNextAlias()											  
	BeginSql Alias cAliasQry											  
		SELECT SUM(DCR.DCR_QUANT) QTD_SEPARA
		FROM %Table:DCF% DCF
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL =  %xFilial:DCR%
		AND DCR.DCR_IDDCF = DCF.DCF_ID
		AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
		AND DCR.%NotDel%
		INNER JOIN %Table:SDB% SDB
		ON SDB.DB_FILIAL = %xFilial:SDB%
		AND SDB.DB_ESTORNO = ' ' 
        AND SDB.DB_ATUEST  = 'N' 
        AND SDB.DB_SERVIC  = DCF.DCF_SERVIC 
        AND SDB.DB_IDDCF = DCR.DCR_IDORI
        AND SDB.DB_IDMOVTO = DCR.DCR_IDMOV
        AND SDB.DB_IDOPERA = DCR.DCR_IDOPER
        AND SDB.DB_ORDTARE = %Exp:cOrdSep% 
        AND SDB.DB_PRODUTO = %Exp:cProduto%
        AND SDB.%NotDel%
        %Exp:cWhere%
        AND SDB.DB_ORDATIV = (SELECT MAX(DB_ORDATIV)
								FROM %Table:SDB% SDBM
								WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL
								AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO
								AND SDBM.DB_DOC     = SDB.DB_DOC
								AND SDBM.DB_SERIE   = SDB.DB_SERIE
								AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR
								AND SDBM.DB_LOJA    = SDB.DB_LOJA
								AND SDBM.DB_SERVIC  = SDB.DB_SERVIC
								AND SDBM.DB_TAREFA  = SDB.DB_TAREFA
								AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO
								AND SDBM.DB_ESTORNO = ' '
								AND SDBM.DB_ATUEST  = 'N'
								AND SDBM.%NotDel%)
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
	    AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.%NotDel%
		%Exp:cWhereDCF%
	EndSql	
	TcSetField(cAliasQry,'QTD_SEPARA','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQuant := (cAliasQry)->QTD_SEPARA
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant

//-----------------------------------------------------------------------------
//Grava a quantidade conferida, finalizando a atividade
//relativa ao produto conferido, se for o caso.
//-----------------------------------------------------------------------------
Static Function GravCofOpe(cCarga,cPedido,cProduto,cLoteCtl,cSubLote,nQtConf)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local nQtdLid    := 0
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM  := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))

	Begin Transaction

	cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_PRODUTO  = '"+cProduto+"'"
	If !Empty(cLoteCtl)
		cQuery += " AND DB_LOTECTL  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cSubLote)
		cQuery += " AND DB_NUMLOTE  = '"+cSubLote+"'"
	EndIf
	cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery +=  " OR DB_RECHUM   = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND ((DB_QUANT-DB_QTDLID) > 0)"
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While lRet .And. (cAliasQry)->(!Eof()) .And. QtdComp(nQtConf) > 0
		SDB->(DbGoTo((cAliasQry)->RECNOSDB))
		// Regra para distribuir a quantidade conferida entre mais de um
		// registro de conferência, quando um mesmo produto/lote pertencer
		// a pedidos diferentes de uma mesma carga, por exemplo.
		If QtdComp(SDB->DB_QUANT-SDB->DB_QTDLID) > QtdComp(nQtConf)
			nQtdLid := nQtConf
		Else
			If QtdComp(Abs(SDB->DB_QUANT-(SDB->DB_QTDLID+nQtConf))) <= QtdComp(nToler1UM)
				nQtdLid := nQtConf
			Else
				nQtdLid := SDB->DB_QUANT-SDB->DB_QTDLID
			EndIf
		EndIf
		If (lRet := RecLock("SDB",.F.))
			SDB->DB_RECHUM  := __cUserID
			SDB->DB_DATAFIM := dDataBase
			SDB->DB_HRFIM   := Time()
			SDB->DB_STATUS  := cStatInte // Atividade Em Execução
			SDB->DB_QTDLID  += nQtdLid
			SDB->(MsUnlock("SDB"))
			//Diminuindo a quantida utilizada da quantidade conferida
			nQtConf -= nQtdLid
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	If !lRet
		DisarmTransaction()
		DLVTAviso('SIGAWMS',STR0036) //"Não foi possível registrar a quantidade."
	EndIf
	End Transaction
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Grava a quantidade conferida, finalizando a atividade
//relativa ao produto conferido, se for o caso.
//-----------------------------------------------------------------------------
Static Function FinCofExp(cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local lDiverge   := .F.
Local lPendExec  := .F.
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local lCarga     := WmsCarga(cCarga)
Local lFinal     := .T.
Local cLibPed    := Iif(DC5->(FieldPos('DC5_LIBPED'))>0,Posicione('DC5',1,xFilial('DC5')+cServico+cOrdTar,'DC5_LIBPED'),'1')

	If AtivAntPen(cCarga,cPedido)
		DLVTAviso('SIGAWMS',STR0037) // "Existem atividades anteriores não finalizadas."
		Return .F.
	EndIf

	If DocAntPen(cCarga,cPedido)
		DLVTAviso('SIGAWMS',STR0048) // "Existem ordens de serviço pendentes de execução."
		lPendExec := .T.
	EndIf

	Begin Transaction
		If !lPendExec
			// Primeiro verifica se existem itens que não foram totalmente conferidos
			cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
			cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
			cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
			cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
			cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
			If lCarga
				cQuery += " AND DB_CARGA = '"+cCarga+"'"
			Else
				cQuery += " AND DB_DOC   = '"+cPedido+"'"
			EndIf
			cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
			cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
			cQuery +=   " OR DB_RECHUM  = '"+cRecHVazio+"')"
			If !lWmsDaEn
				cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
			EndIf
			cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
			cQuery += " AND ((DB_QUANT-DB_QTDLID) > 0)"
			cQuery += " AND D_E_L_E_T_  = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				If WmsQuestion(STR0038) //"Existem itens não conferidos. Confirma a finalização da conferência?"
					While lRet .And. (cAliasQry)->(!Eof())
						SDB->(DbGoTo((cAliasQry)->RECNOSDB))
						lDiverge := .T.
						If (lRet := RecLock("SDB",.F.))
							SDB->DB_DATAFIM := dDataBase
							SDB->DB_HRFIM   := Time()
							SDB->DB_STATUS  := cStatProb // Atividade Com Problemas
							SDB->DB_ANOMAL  := 'S'
							SDB->(MsUnlock("SDB"))
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
				Else
					lRet := .F.
					lFinal := .F.
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
			// Se a conferência foi finalizada normalmente e sem divergências
			If lRet .And. lFinal .And. !lDiverge
				// Altera o status dos movimentos para Atividade Executada
				cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
				cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
				cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
				cQuery +=   " AND DB_ESTORNO = ' '"
				cQuery +=   " AND DB_ATUEST  = 'N'"
				cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
				cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
				cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
				cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
				If lCarga
					cQuery += " AND DB_CARGA = '"+cCarga+"'"
				Else
					cQuery += " AND DB_DOC   = '"+cPedido+"'"
				EndIf
				cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatProb+"')"
				cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
				cQuery +=   " OR DB_RECHUM  = '"+cRecHVazio+"')"
				If !lWmsDaEn
					cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
				EndIf
				cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
				cQuery += " AND ((DB_QUANT-DB_QTDLID) <= 0)"
				cQuery += " AND D_E_L_E_T_  = ' '"
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				While lRet .And. (cAliasQry)->(!Eof())
					SDB->(DbGoTo((cAliasQry)->RECNOSDB))
					If (lRet := RecLock("SDB",.F.))
						SDB->DB_STATUS := cStatExec // Atividade Executada
						SDB->(MsUnlock())
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
				// Deve liberar os itens do pedido de venda, caso esteja parametrizado para tal
				If cLibPed == '2'
					cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9"
					cQuery +=  " FROM "+RetSqlName("SDB")+" SDB, "+RetSqlName("SC9")+" SC9"
					cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
					cQuery +=   " AND DB_ESTORNO = ' '"
					cQuery +=   " AND DB_ATUEST  = 'N'"
					cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
					cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
					cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
					cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
					If lCarga
						cQuery += " AND DB_CARGA  = '"+cCarga+"'"
					Else
						cQuery += " AND DB_DOC    = '"+cPedido+"'"
					EndIf
					cQuery += " AND DB_STATUS   = '"+cStatExec+"'"
					cQuery += " AND DB_RECHUM   = '"+__cUserID+"'"
					If !lWmsDaEn
						cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
					EndIf
					cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
					cQuery += " AND SDB.D_E_L_E_T_  = ' '"
					cQuery += " AND C9_FILIAL  = '"+xFilial("SC9")+"'"
					If lCarga
						cQuery += " AND C9_CARGA  = '"+cCarga+"'"
					Else
						cQuery += " AND C9_PEDIDO = '"+cPedido+"'"
						cQuery += " AND C9_ITEM   = DB_SERIE"
					EndIf
					cQuery += " AND C9_PRODUTO = DB_PRODUTO"
					cQuery += " AND C9_SERVIC  = DB_SERVIC"
					cQuery += " AND C9_LOTECTL = DB_LOTECTL"
					cQuery += " AND C9_IDDCF   = DB_IDDCF"
					cQuery += " AND C9_BLWMS   = '01'"
					cQuery += " AND C9_BLEST   = '  '"
					cQuery += " AND C9_BLCRED  = '  '"
					cQuery += " AND SC9.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
					While lRet .And. (cAliasQry)->(!Eof())
						SC9->(DbGoTo((cAliasQry)->RECNOSC9)) //-- Posiciona no registro do SC9 correspondente
						If (lRet := RecLock("SC9",.F.))
							SC9->C9_BLWMS := "05"
							SC9->(MsUnlock())
						EndIf
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())
				EndIf
			EndIf
			If !lRet
				DisarmTransaction()
				If lFinal
					DLVTAviso('SIGAWMS',STR0039) //"Não foi possível finalizar a conferência."
				EndIf
			EndIf
		Else
			// Altera o status dos movimentos para Atividade Com Problemas
			cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
			cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
			cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
			cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
			cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
			If lCarga
				cQuery += " AND DB_CARGA = '"+cCarga+"'"
			Else
				cQuery += " AND DB_DOC   = '"+cPedido+"'"
			EndIf
			cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
			cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
			cQuery +=   " OR DB_RECHUM  = '"+cRecHVazio+"')"
			If !lWmsDaEn
				cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
			EndIf
			cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
			cQuery += " AND ((DB_QUANT-DB_QTDLID) <= 0)"
			cQuery += " AND D_E_L_E_T_  = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			Do While lRet .And. (cAliasQry)->(!Eof())
				SDB->(DbGoTo((cAliasQry)->RECNOSDB))
				If (lRet := RecLock("SDB",.F.))
					SDB->DB_STATUS := cStatProb // Atividade Com Problemas
					SDB->(MsUnlock())
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	End Transaction
	If lRet .And. !lPendExec
		DLVTAviso('SIGAWMS',STR0050) // "Conferência encerrada com sucesso!"
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Efetua a validação para verificar se não exitem mais itens pendentes
//Caso não exista mais nenhuma pendencia, somente deverá ser finalizado a conferência
//-----------------------------------------------------------------------------
Static Function SaiCofExp(cCarga,cPedido)
Local aAreaAnt   := GetArea()
Local lRet       := .T.

	If !AtivAtuPen(cCarga,cPedido)
		If !DocAntPen(cCarga,cPedido)
			DLVTAviso('SIGAWMS',STR0052) // "Não existem mais itens para serem conferidos. Conferência deve ser finalizada."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
// Valida o endereço informado
//-----------------------------------------------------------------------------
Static Function ValidEnder(cEnderSYS,cEndereco)
Local aAreaAnt := GetArea()
Local aAreaSBE := SBE->(GetArea())
Local lRet     := .T.

	//Se não informou a carga retorna
	If Empty(cEndereco)
		Return .F.
	EndIf
   If cEndereco!=cEnderSYS
   	DLVTAviso('SIGAWMS',STR0017) //'Endereco incorreto!'
   	VTKeyBoard(chr(20))
   	lRet := .F.
   EndIf
   If lRet
   	SBE->(DbSetOrder(9))
   	If SBE->( ! MsSeek(xFilial('SBE')+cEndereco))
   		DLVTAviso('SIGAWMS',WmsFmtMsg(STR0018,{{"[VAR01]",cEndereco}})) //'O endereco [VAR01] não está cadastrado!'
   		VTKeyBoard(chr(20))
   		lRet := .F.
   	EndIf
   EndIf
   RestArea(aAreaSBE)
   RestArea(aAreaAnt)
Return(lRet)

//----------------------------------------------------------
//Verifica se existem atividades anteriores não finalizadas
//----------------------------------------------------------
Static Function AtivAntPen(cCarga,cPedido)
Local cAreaAnt    := GetArea()
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local lRet        := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA  = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC    = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_SERVIC  = '"+cServico+"'"
	cQuery += " AND DB_ORDTARE < '"+cOrdTar+"'"
	cQuery += " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND DB_ATUEST  = 'N'"
	cQuery += " AND DB_ESTORNO = ' '"
	cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
RestArea(cAreaAnt)
Return lRet

//----------------------------------------------------------
//Verifica se existem ordens de serviço não executadas para o mesmo documento
//----------------------------------------------------------
Static Function DocAntPen(cCarga,cPedido)
Local cAreaAnt    := GetArea()
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local lRet        := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF_FILIAL  = '"+xFilial('DCF')+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DCF_CARGA  = '"+cCarga+"'"
	Else
		cQuery += " AND DCF_DOCTO  = '"+cPedido+"'"
	EndIf
	cQuery += " AND DCF_SERVIC = '"+cServico+"'"
	cQuery += " AND DCF_STSERV IN ('1','2')"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
RestArea(cAreaAnt)
Return lRet

//----------------------------------------------------------
//Verifica se existem atividades do documento atual ainda pendentes
//----------------------------------------------------------
Static Function AtivAtuPen(cCarga,cPedido)
Local cAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local lRet       := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery +=   " OR DB_RECHUM  = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
RestArea(cAreaAnt)
Return lRet

//----------------------------------------------------------
//Questiona ao usuário se o mesmo deseja sair da conferência, abandonando a mesma
//----------------------------------------------------------
Static Function WMSV075ESC(lAbandona)
//-- Disponibiliza novamente o documento para convocação quando o operador
//-- altera o documento ou abandona conferência pelo Coletor RF.
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	If WmsQuestion(STR0051) //'Deseja sair da conferencia?'
		lAbandona := .T.
		//-- Variavel definida no programa dlgv001
		DLVAltSts(.F.)

		//Grava SDB
		RecLock('SDB', .F.)  // Trava para gravacao
		SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
		SDB->DB_STATUS := cStatAExe // Atividade A Executar
		//-- Libera o registro do arquivo SDB
		MsUnlock()
		If lLiberaRH
			//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
			CancRHServ(SDB->DB_CARGA,SDB->DB_DOC,SDB->DB_SERVIC)
		EndIf
	EndIf
Return (Nil)


/*/{Protheus.doc} WmsPosSB8
	(Posiciona na SB8 apos a digitacao do lote na conferencia convocada. 
	Quando acionada a ocorrencia (Ctrl + O), o lancamento ocorre para o produto posicionado)
	@type  Function
	@author Equipe WMS
	@since 22/12/2023
	/*/
Static Function WmsPosSB8(cCarga,cPedido,cProduto,cLoteCtl,cSubLote)
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	If WmsCarga(cCarga)
		cQuery += " AND DB_CARGA = '"+cCarga+"'"
	Else
		cQuery += " AND DB_DOC   = '"+cPedido+"'"
	EndIf
	cQuery += " AND DB_PRODUTO  = '"+cProduto+"'"
	If !Empty(cLoteCtl)
		cQuery += " AND DB_LOTECTL  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cSubLote)
		cQuery += " AND DB_NUMLOTE  = '"+cSubLote+"'"
	EndIf
	cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	cQuery += " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery +=  " OR DB_RECHUM   = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery += " AND DB_LOCAL = '"+cArmazem+"'"
	EndIf
	cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery += " AND ((DB_QUANT-DB_QTDLID) > 0)"
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	EndIf
	(cAliasQry)->(DbCloseArea())
	
Return
