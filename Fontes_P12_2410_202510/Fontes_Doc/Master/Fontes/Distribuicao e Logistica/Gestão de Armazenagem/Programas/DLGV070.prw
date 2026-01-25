#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'DLGV070.CH'
#INCLUDE 'APVT100.CH'
#DEFINE _CRLF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA        ³Programa   DLGV070.PRW  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³Flavio Luiz Vicco         ³ 31/01/2006   ³00000096015       ³±±
±±³      02  ³Flavio Luiz Vicco         ³ 15/02/2006   |00000091627       ³±±
±±³      03  ³Flavio Luiz Vicco         ³ 29/06/2006   |00000099487       ³±±
±±³      04  ³Flavio Luiz Vicco         ³ 31/01/2006   ³00000096015       ³±±
±±³      05  ³Flavio Luiz Vicco         ³ 13/07/2006   ³00000102433       ³±±
±±³      06  ³Flavio Luiz Vicco         ³ 13/07/2006   ³00000102433       ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³Flavio Luiz Vicco         ³ 29/06/2006   |00000099487       ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Flavio Luiz Vicco         ³ 15/02/2006   |00000091627       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DLGV070 ³ Autor ³ Fernando Joly Siquini  ³ Data ³25.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Conferencia de recebimento de mercadorias c/Sep. p/NF      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLGV070()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLGV070(nNumConta, nTipConf)
Local aAreaAnt   := GetArea()
Local aRetPE     := {}
Local aAreaSDB   := SDB->(GetArea())
Local aAreaSDB1  := {}
Local aProdutos  := {}
Local aTotPrdUSU := {}
Local aTotPrdSYS := {}
Local aOcorr     := {}
Local aLoteCtl   := {}
//-- Salva todas as teclas de atalho anteriores.
Local aSavKey    := VTKeys()
Local cEndereco  := ""
Local cAliasNew  := "SDB"
Local cDoc       := SDB->DB_DOC
Local cSerie     := SDB->DB_SERIE
Local cCliFor    := SDB->DB_CLIFOR
Local cLoja      := SDB->DB_LOJA
Local cCarga     := SDB->DB_CARGA
Local cServic    := SDB->DB_SERVIC
Local cTarefa    := SDB->DB_TAREFA
Local cAtivid    := SDB->DB_ATIVID
Local cIdOpera   := SDB->DB_IDOPERA
Local cProduto   := ""
Local cLoteCtl   := ""
Local cConfirma  := ""
Local cSeekSDB   := ""
//-- Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote   := SuperGetMv('MV_WMSLOTE',.F.,.F.)
Local lDigita    := (SuperGetMV('MV_DLCOLET', .F., 'N')=='N')	// Se sim leitura atraves codigo de barras, se nao digitacao
Local cWmsUMI    := AllTrim(SuperGetMv('MV_WMSUMI',.F.,'1'))
Local aUNI       := {}
Local cUM        := ""
Local cDscUM     := ""
Local cDesUni    := ""
Local cEstFis    := ""
Local cPict1UM   := ""
Local cEndPad    := ""
Local nQtdInf    := 0
Local nQtdNorma  := 0
Local nOpc       := 0
Local nX         := 0
Local nRet       := 0
Local lOcorr     := .T.
Local lRet       := .T.
Local nMaxConta  := Val(GetMV('MV_MAXCONT', .F., '3'))
Local nOrder     := 0
Local nAviso     := 0
Local nProxLin   := 0
Local nItem      := 0
Local aTelaAnt   := {}
Local cDescPro   := ""
Local cCompara   := ""

Default nNumConta  := 0
Default nTipConf   := 1

Private aConferUsu := {}
Private cCadastro  := STR0001	//'Conferencia'
Private cArmazemPd := SDB->DB_LOCAL

//-- Na conferencia: "5" similar ao "3"
cWmsUMI := If(cWmsUMI=='5','3',cWmsUMI)

//-- Incrementa 1 ao numero de Contagens
nNumConta ++

//-- Informa o Endereco de Destino
If nNumConta == 1
	DLVTCabec()
	DLVEndereco(00, 00, SDB->DB_LOCALIZ, SDB->DB_LOCAL,,,STR0002)	//'Va para o Endereco'
	If	(VTLastKey()==27) .And. (DLVTAviso('DLGV07001',STR0003, {STR0004,STR0005})==1)	//'Deseja encerrar a Conferencia?'###'Sim'###'Nao'
		lRet      := .F.
		lAbandona := .T.
	EndIf
EndIf

//-- Solicita confirmacao do Endereco de Destino
If (nNumConta==1) .And. lRet
	cEndereco := SDB->DB_LOCALIZ
	DLVTCabec(,.F.,.F.,.T.)
	@ 02, 00 VTSay PadR(STR0006, VTMaxCol())	//'Endereco'
	@ 03, 00 VTSay PadR(SDB->DB_LOCALIZ, VTMaxCol())
	@ 05, 00 VTSay PadR(STR0007, VTMaxCol())	//'Confirme !'
	@ 06, 00 VTGet (cConfirma:=Space(Len(cEndereco))) Pict '@!' Valid (cConfirma==cEndereco)
	VTRead
	If	(VTLastKey()==27) .And. (DLVTAviso('DLGV07002',STR0003, {STR0004,STR0005})==1)	//'Deseja encerrar a Conferencia?'###'Sim'###'Nao'
		lRet := .F.
		lAbandona := .T.
	ElseIf nTipConf == 2
		cEndPad := cEndereco
	EndIf
EndIf

//-- Efetua a Contagem dos Produtos/Quantidades constantes na NF
If lRet
	//-- Conferencia com Informacao de Enderecos
	If nTipConf == 1
		//-- Atribui a Funcao de ENDERECO a Combinacao de Teclas <CTRL> + <E>
		VTSetKey(5,{||DLG070FimC(aProdutos, nTipConf, cEndPad)},STR0006)	//'Endereco'
	EndIf
	//-- Atribui a Funcao de INFORMACAO DO PRODUTO a Combinacao de Teclas <CTRL> + <I>
	VTSetKey(9,{||DLG070IPrd(cProduto)},STR0008)	//'Inf.Produto'
	//-- Atribui a Funcao de JA CONFERIDOS a Combinacao de Teclas <CTRL> + <Q>
	VTSetKey(17,{|| DlV070Conf(aProdutos)},STR0009)	//'Ja Conferidos'

	VtAlert(STR0010,STR0011, .T., 1000, 3)	//'Aguarde... Contando Produtos.'###'Processamento'
	cSeekSDB := xFilial('SDB')+cDoc+cSerie+cCliFor+cLoja
	cCompara := 'DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA'
	nOrder   := 6
	aLoteCtl := {}
	If	ExistBlock('DLV070CO')
		aRetPE := ExecBlock('DLV070CO', .F., .F., {cSeekSDB, cCompara, nOrder})
		cSeekSDB := aRetPE[1]
		cCompara := aRetPE[2]
		nOrder   := aRetPE[3]
	EndIf
	DbSelectArea('SDB')

	aAreaSDB1 := GetArea()
	SDB->(DbSetOrder(nOrder))
	If SDB->(DbSeek(cSeekSDB, .F.))
		While SDB->(!Eof() .And. cSeekSDB == &(cCompara))
			If	SDB->DB_ESTORNO == ' '
				If cServic+cTarefa+cAtivid+cIdOpera==SDB->DB_SERVIC+SDB->DB_TAREFA+SDB->DB_ATIVID+SDB->DB_IDOPERA
					If (nPos:=aScan(aTotPrdSYS, {|x| x[1]==SDB->DB_PRODUTO})) == 0
						aAdd(aTotPrdSYS, {SDB->DB_PRODUTO, SDB->DB_QUANT, SDB->DB_LOCALIZ, SDB->DB_ESTFIS,SDB->(Recno()) })
					Else
						aTotPrdSYS[nPos, 2] += SDB->DB_QUANT
					EndIf
				EndIf
				//-- Obtem os numeros de lote do documento
				If	aScan(aLoteCtl,SDB->DB_LOTECTL)==0
					aAdd(aLoteCtl,SDB->DB_LOTECTL)
				EndIf
			EndIf
			SDB->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaSDB1)
	If	!(cWmsUMI$'1234')
		cWmsUMI :='1'
	EndIf
EndIf

If	ExistBlock('DLV070PR')
	lRet := ExecBlock('DLV070PR', .F., .F., {cProduto})
EndIf

//-- Looping para Contagem dos Produtos
While lRet
	//--            1
	//--  01234567890123456789
	//--0 ____Conferencia____
	//--1 Produto
	//--2 PA1
	//--3 NOME DO PRODUTO
	//--4 Lote
	//--5 AUTO000636
	//--6 Quantidade
	//--7     240.00

	//-- Escolha do Produto a ser Conferido
	DLVTCabec()
	If lRet
		If	lDigita
			cProduto := Space(TamSX3('D1_COD')[1])
		Else
			cProduto := Space(Len(SB1->B1_CODBAR))
		EndIf
		cDescPro := ""
		@ 01, 00 VTSay PadR(STR0012, VTMaxCol())	//'Produto'
		@ 02, 00 VTGet cProduto Pict '@!' Valid DLV70VlPro(@cProduto, aTotPrdSYS, lDigita, @cDescPro) F3 'SB1'
		VTRead
		@ 03, 00 VTSay PadR(cDescPro, VTMaxCol())
		If (nRet:=DLV70VlDig(aProdutos, @lOcorr, nTipConf, cEndPad))==1
			Loop
		ElseIf nRet == 2
			Exit
		ElseIf nRet == 3
			lRet      := .F.
			lAbandona := .T.
			Exit
		EndIf
		//-- Lote
		nProxLin := 4
		If	lWmsLote .And. Rastro(cProduto)
			cLoteCtl := Space(Len(SDB->DB_LOTECTL))
			@ nProxLin  ,00 VTSay PadR(STR0013,VTMaxCol())	//'Lote'
			@ nProxLin+1,00 VTGet cLoteCtl Picture PesqPict('SDB','DB_LOTECTL') Valid DlV70VlLot(cLoteCtl,aLoteCtl)
			VTRead
			If (nRet:=DLV70VlDig(aProdutos, @lOcorr, nTipConf, cEndPad))==1
				Loop
			ElseIf nRet == 2
				Exit
			ElseIf nRet == 3
				lRet      := .F.
				lAbandona := .T.
				Exit
			EndIf
			nProxLin := 6
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 1a. / 2a. Unidade de Medida ou Unitizador        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// --- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If	cWmsUMI == '4'
			SB5->(dbSetOrder(1))
			SB5->(MsSeek(xFilial('SB5')+cProduto))
			cWmsUMI := SB5->B5_UMIND
		EndIf
		//-- Indica a unidade de medida utilizada pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=UNITIZADOR / 4=U.M.I.
		aUNI := {}
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial('SB1')+cProduto))
		If	cWmsUMI $ '12'
			If	cWmsUMI == '1'
				cUM    := SB1->B1_UM
				cDscUM := Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,'AH_UMRES')
				nItem  := 3
			Else
				cUM    := SB1->B1_SEGUM
				cDscUM := Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')
				nItem  := 2
			EndIf
		ElseIf cWmsUMI == '3'
			If (nX:=aScan(aTotPrdSys, {|x|x[1]==cProduto})) > 0
				cEstFis := aTotPrdSys[nX, 4]
			EndIf
			nQtdNorma := DLQtdNorma(cProduto,cArmazemPD,cEstFis,@cDesUni,.F.)
			cUM       := "*"
			nItem     := 1
			aAdd(aUNI, {cDesUni})
			aAdd(aUNI, {Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')})
			aAdd(aUNI, {Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,   'AH_UMRES')})
			//--            1
			//--  01234567890123456789
			//--0 UNIDADE
			//--1 -------------------
			//--2 PALETE PBRII
			//--3 CAIXA
			//--4 PECA
			//--5 ___________________
			//--6
			//--7  Unidade p/Endere
			aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
			DLVTRodaPe(STR0045,.F.) //"Unidade p/Confer?"
			nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{STR0046},aUNI,{VTMaxCol()},,nItem) //"Unidade"
			If	(VTLastKey()==27) .And. (DLVTAviso('DLGV07001',STR0003, {STR0004,STR0005})==1)	//'Deseja encerrar a Conferencia?'###'Sim'###'Nao'
				lRet      := .F.
				lAbandona := .T.
			EndIf
			cDscUM := aUNI[nItem,1]
			If nItem == 2
				cUM := SB1->B1_SEGUM
			ElseIf nItem == 3
				cUM := SB1->B1_UM
			EndIf
			VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
		EndIf

		If lRet
			If	nItem == 1
				cPict1UM := '@R 9999999999'
			Else
				cPict1UM := PesqPict('SDB','DB_QUANT')
			EndIf
			//-- Atribui uma Quantidade ao Produto Escolhido
			@ nProxLin,   00 VTSay PadR((STR0047+cDscUM), VTMaxCol()) //"Qtde "
			@ nProxLin+1, 00 VTGet (nQtdInf:=0) Picture cPict1UM Valid DLV070QTD(@nQtdInf,cProduto)
			VTRead
			If (nRet:=DLV70VlDig(aProdutos, @lOcorr, nTipConf, cEndPad))==1
				Loop
			ElseIf nRet == 2
				Exit
			ElseIf nRet == 3
				lRet      := .F.
				lAbandona := .T.
				Exit
			EndIf
		EndIf

		//-- Converter de U.M.I. p/ 1a.UM
		If	lRet
			If	nItem == 1
				nQtdInf	:= (nQtdInf*nQtdNorma)
			//-- Converter de 2a.UM p/ 1a.UM
			ElseIf nItem == 2
				nQtdInf := ConvUm(cProduto,0,nQtdInf,1)
			EndIf
				//-- Adiciona o Produto escolhido e a Quantidade Atribuida ao Array de Contagem de Produtos
			If (nPos:=aScan(aProdutos, {|x|x[1]==cProduto})) == 0
				aAdd(aProdutos, {cProduto, nQtdInf})
			Else
				aProdutos[nPos, 2] += nQtdInf
			EndIf
			//-- Adiciona o Produto escolhido e a Quantidade Atribuida ao Array Totalizador de Contagem de Produtos
			If (nPos:=aScan(aTotPrdUSU, {|x|x[1]==cProduto})) == 0
				aAdd(aTotPrdUSU, {cProduto, nQtdInf})
			Else
				aTotPrdUSU[nPos, 2] += nQtdInf
			EndIf
		EndIf
	EndIf
EndDo

If lRet
	VTClear()

	If Len(aConferUsu) > 0
		//-- Procura produtos digitados a menos ou errados com base no Documento
		For nX := 1 to Len(aTotPrdSYS)
			If (nPos:=aScan(aTotPrdUSU, {|x| x[1]==aTotPrdSYS[nX,1]})) > 0
				If !(QtdComp(aTotPrdUSU[nPos, 2])==QtdComp(aTotPrdSYS[nX, 2]))
					aAdd(aOcorr, {aTotPrdSYS[nX, 1], aTotPrdSYS[nX, 2], aTotPrdUSU[nPos, 1], aTotPrdUSU[nPos, 2]})
				EndIf
			Else
				aAdd(aOcorr, {aTotPrdSYS[nX, 1], aTotPrdSYS[nX, 2], '', 0})
			EndIf
		Next nX
		//-- Procura produtos digitados a mais que nao constam no documento
		For nX := 1 to Len(aTotPrdUSU)
			If aScan(aTotPrdSYS, {|x| x[1]==aTotPrdUSU[nX,1]}) == 0
				aAdd(aOcorr, {'', 0, aTotPrdUSU[nX, 1], aTotPrdUSU[nX, 2]})
			EndIf
		Next nX
		If Len(aOcorr) > 0
			Do While .T.
				If nNumConta >= nMaxConta
					DLVTAviso('DLGV07003',STR0015+AllTrim(Str(nNumConta))+STR0016)	//'As Divergencias encontradas na '###' Conferencia serao Regigstradas.'
					DLV70Proc(aConferUSU, aTotPrdSYS, cDoc, cSerie, .T., aOcorr, cCarga, nNumConta)
					lRet := .F.
				Else
					nAviso := 0
					Do While nAviso == 0
						nAviso := DLVTAviso('DLGV07004',STR0017+AllTrim(Str(nNumConta))+STR0018, {STR0019,STR0020})	//'Foram encontradas Divergencias na '###' Conferencia.'###'Confere Novamente'###'Registra Ocorrencias'
						If	(VTLastKey()==27)
							Loop
						EndIf
					EndDo
					If nAviso == 1
						RestArea(aAreaSDB)
						RestArea(aAreaAnt)
						lRet := DLGV070(@nNumConta, nTipConf)
					Else
						DLV70Proc(aConferUSU, aTotPrdSYS, cDoc, cSerie, .T., aOcorr, cCarga, nNumConta)
						lRet := .F.
					EndIf
				EndIf
				// ---- Zera Array dos itens conferidos
				aProdutos := {}
				Exit
			EndDo
		Else
			DLV70Proc(aConferUSU, aTotPrdSYS, cDoc, cSerie, .F., Nil, cCarga, nNumConta)
		EndIf
	EndIf
EndIf
VTClear()
//-- Restaura as teclas de atalho anteriores
VTKeys(aSavKey)
RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLG070FimC³ Autor ³ Fernando Joly Siquini ³ Data ³25.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Finaliza a Contagem dos Itens e Define sua Localizacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLG070FimC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1  = Array com os Produtos contados ate o momento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLG070FimC(aProdutos, nTipConf, cEndPad)

Local cEndereco  := Space(TamSX3('BE_LOCALIZ')[1])
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local nPos       := 0
Local nX         := 0

Default aProdutos  := {}

If Len(aProdutos)>0

	If nTipConf == 1
		//-- Solicita o Endereco no qual os Produtos contados ate o momento
		DLVTCabec()
		@ 02, 00 VTSay PadR(STR0021, VTMaxCol())	//'Escolha o Endereco'
		@ 03, 00 VTGet cEndereco Pict '@!' Valid DLV70VlEnd(cArmazemPD, cEndereco) F3 'SBE'
		VTRead
	Else
		cEndereco := cEndPad
	EndIf
	If	!(VTLastKey() == 27)
		//-- Adiciona os Produtos Contados ao Array com de Enderecos
		If (nPos:=aScan(aConferUsu, {|x| x[1]==cEndereco})) == 0
			aAdd(aConferUsu, {cEndereco, aClone(aProdutos)})
		Else
			For nX := 1 to Len(aProdutos)
				aAdd(aConferUsu[nPos, 2], aClone(aProdutos[nX]))
			Next nX
		EndIf
	EndIf
Else
	DLVTAviso('DLGV07005',STR0022)	//'Nenhum Produto na memoria do Coletor...'
EndIf

VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
VTInkey()
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLV70VlEnd  ³ Autor ³Fernando Joly Siquini³Data  ³25.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do endereco                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV070VldEnd( ExpC1, ExpC2, ExpC3, ExpC4, ExpL1 )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Armazem                                            ³±±
±±³          ³ ExpC2 = Encedero a Validar                                 ³±±
±±³          ³ ExpL1 = .T. Digitacao / .F. Leitura via coletor de dados   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DLGV070l                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLV70VlEnd(cArmazem, cEndereco)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Default cArmazem   := cArmazemPD
Default cEndereco  := ''

lRet := ExistCpo('SBE', cArmazem+cEndereco)
If	lRet .And. ExistBlock('DLVENDER')
	lRet := ExecBlock('DLVENDER',.F.,.F.,{cArmazem, cEndereco})
EndIf
RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLV70VlPro  ³ Autor ³Fernando Joly Siquini³ Data ³02.05.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV070VldPro( ExpC1, ExpL1 )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto digitado                         ³±±
±±³          ³ ExpL1 = .T. Digitacao / .F. Leitura via coletor de dados   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLV70VlPro(cProduto, aProdutos, lDigita, cDescPro)
Local aAreaAnt   := GetArea()
Local aProduto   := {}
Local aRetPE     := {}
Local lRet       := .T.

Default cProduto   := ''
Default aProdutos  := {}
Default lDigita    := .F.
Default cDescPro   := ''

If	ExistBlock('DLV070VL')
	aRetPE   := ExecBlock('DLV070VL', .F., .F., {cProduto, aProdutos, lDigita})
	lRet     := aRetPE[1]
	cProduto := aRetPE[2]
	cDescPro := aRetPE[3]
Else
	If !lDigita
		cTipId := CBRetTipo(cProduto)
		If	cTipId $ "EAN8OU13-EAN14-EAN128"
			aProduto := CBRetEtiEAN(cProduto)
		Else
			aProduto := CBRetEti(cProduto, '01')
		EndIf
		If	Empty(aProduto)
			DLVTAviso('DLGV07007',STR0023)	//'Etiqueta invalida !'
			VTKeyBoard(chr(20))
			lRet := .F.
		Else
			cProduto := aProduto[1]
		EndIf
	EndIf

	If lRet
		dbSelectArea('SB1')
		dbSetOrder(1)
		If !dbSeek(xFilial('SB1')+cProduto, .F.)
			DLVTAviso('DLGV07008',STR0024+AllTrim(cProduto)+STR0025)	//'O Produto '###' nao esta cadastrado.'
			VTKeyBoard(chr(20))
			lRet := .F.
		Else
			cDescPro := SB1->B1_DESC
		EndIf
	EndIf

	If lRet .And. Len(aProdutos) > 0
		If aScan(aProdutos, {|x| x[1]==cProduto}) == 0
			DLVTAviso('DLGV07009',STR0024+AllTrim(cProduto)+STR0026)	//'O Produto '###' nao consta no Documento Atual.'
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaAnt)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLV70VlDig  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao Apos a Leitura dos Gets                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV70VlDig(ExpA1, ExpL1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Produtos                                           ³±±
±±³          ³ ExpL1 = Ocorrencias                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorno para contole do VTAchoice                          ³±±
±±³          ³ 0 - Continua Processo                                      ³±±
±±³          ³ 1 - Loop                                                   ³±±
±±³          ³ 2 - Exit                                                   ³±±
±±³          ³ 3 - Exit + Abandona                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV???                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLV70VlDig(aProdutos, lOcorr, nTipConf, cEndPad)

Local nRet       := 0
Local nOpc       := 0

Default aProdutos  := {}
Default lOcorr     := .T.

If	VTLastKey() == 27
	If (DLVTAviso('DLGV07010',STR0027, {STR0004,STR0005})==1)	//'Deseja encerrar a Conferencia?'###'Sim'###'Nao'
		If !Empty(aProdutos)
			If !(nTipConf==1) .Or. (nOpc:=DLVTAviso('DLGV07011',STR0028, {STR0029,STR0030,STR0031})) == 1	//'O Endereco da Ultima Contagem Nao foi Informado.'###'Informa Endereco'###'Continua Contagem'###'Abandona Contagem'
				DLG070FimC(aProdutos, nTipConf, cEndPad)
				nRet := 2 //-- Exit
			ElseIf nOpc == 3
				nRet := 3 //-- Exit + Abandona
			Else
				nRet := 1 //-- Loop
			EndIf
		Else
			nRet := 3 //-- Exit + Abandona
		EndIf
	Else
		nRet := 1 //-- Loop
	EndIf
EndIf
VTInkey()

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLV70Proc   ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa a Separacao dos Itens Conferidos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV70Proc(ExpA1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os Itens a serem Processados             ³±±
±±³          ³ ExpA2 = Array com os Produtos registrados pelo Sistema     ³±±
±±³          ³ ExpC1 = Documento                                          ³±±
±±³          ³ ExpC2 = Serie                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLV70Proc(aConferUSU, aTotPrdSYS, cDoc, cSerie, lOcorr, aOcorr, cCarga, nNumConta)

Local aRecnos    := {}
Local cProduto   := ''
Local cEndDest   := ''
Local nQuant     := 0
Local nX         := 0
Local nY         := 0
Local cLogFile   := ''
Local cString    := ''
Local cPictQuant := '@E 999999999.99'
Local cWmsDoc    := SuperGetMV('MV_WMSDOC',.F.,'')
Local aLog       := {}
Local nHandle    := 0
Local lRet       := .F.
Default cDoc     := ''
Default cSerie   := ''
Default lOcorr   := .F.
Default aOcorr   := {}
Default cCarga   := ''
Private lAutoErrNoFile := .T.
DLVTAviso('DLGV07012',STR0032, {STR0033}, .F.)	//'Finalizando a Conferencia.'###'Aguarde...'
Begin Transaction
	If lOcorr
		For nX := 1 to Len(aConferUSU)
			cEndDest := aConferUSU[nX, 1]
			For nY := 1 to Len(aConferUSU[nX, 2])
				cProduto := aConferUSU[nX, 2, nY, 1]
				nQuant   := aConferUSU[nX, 2, nY, 2]
				If (nPos:=aScan(aTotPrdSYS, {|x| x[1]==cProduto})) > 0
					//-- Realiza a Gravacao da Conferencia Enderecada no BOX
					dbSelectArea('SDB')
					dbSetOrder(1)
					dbGoto(aTotPrdSys[nPos, 5])
					If RecLock('SDB', .F.)
						Replace DB_STATUS  With '1'
						Replace DB_RECHUM  With __cUserID
						Replace DB_DATAFIM With dDataBase
						Replace DB_HRFIM   With Time()
						Replace DB_ANOMAL With 'S'
					EndIf
				EndIf
			Next nY
		Next nX

		// ---- LOG de Ocorrencias na Conferencia
		// ---- Arquivo TEXTO com o nome RFnnnnnn.LOG - nnnnnn = nro da carga
		cString := ""
		If	Len(aOcorr) > 0
			VtAlert(STR0034,STR0011, .T., 3000, 3)	//'Aguarde... Gerando o LOG.'###'Processamento'
			If !Empty(cCarga)
				cLogFile := "RF" + PadR(cCarga,6) + ".LOG"
			Else
				cLogFile := "RF" + PadR(cDoc,TAMSX3("F2_DOC")[1]) + ".LOG"
			EndIf
			// ---- MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
			// ---- Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
			// ---- Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
			// ---- C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
			If	!Empty(cWmsDoc)
				cWmsDoc := AllTrim(cWmsDoc)
				If	Right(cWmsDoc,1)$"/\"
					cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
				EndIf
				cLogFile := cWmsDoc+"\"+cLogFile
			EndIf
			// ---- Gera array Log
			AutoGrLog(OemToAnsi("Microsiga Protheus WMS - LOG de Ocorrencias na Conferencia (") + cLogFile + ")")
			AutoGrLog(OemToAnsi("Log gerado em ") + DtoC(dDataBase) + OemToAnsi(", as ") + Time())
			AutoGrLog(OemToAnsi("Usuario: ") + AllTrim(CUSERNAME))
			If !Empty(cCarga)
				AutoGrLog(OemToAnsi("Carga: ") + AllTrim(cCarga))
			Else
				AutoGrLog(OemToAnsi("Documento: ") + AllTrim(cDoc) + " / Serie: " + AllTrim(SubStr(cSerie,1,3)))
			EndIf
			AutoGrLog(OemToAnsi("Contagem no.: ") + AllTrim(Str(nNumConta)))
			AutoGrLog(If(Len(aOcorr)>1, OemToAnsi("Ocorrencias (") + AllTrim(Str(Len(aOcorr))) + ") : ", OemToAnsi("Ocorrencia :")))
			AutoGrLog("--------------------------------------++--------------------------------")
			AutoGrLog(PadC("Contagem do Sistema",38)+"||"+PadC("Contagem do Usuario",32))
			AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
			AutoGrLog(PadR("Item",5)+"|"+PadR("Produto",17)+"|"+PadR("Quantidade",14)+"||"+PadR("Produto",17)+"|"+PadR("Quantidade",14))
			AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
			For nX := 1 to Len(aOcorr)
				AutoGrLog(StrZero(nX, 3) + "  |" +  PadR(aOcorr[nX, 1], 16) + " | " + Transform(aOcorr[nX, 2], cPictQuant) + " ||" + PadR(aOcorr[nX, 3], 16) + " | " + Transform(aOcorr[nX, 4], cPictQuant))
			Next nX
			AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
			// ---- Grava Arquivo Log
			aLog := GetAutoGRLog()
			If	!File(cLogFile)
				If	(nHandle := MSFCreate(cLogFile,0)) <> -1
					lRet := .T.
				EndIf
			Else
				If	(nHandle := FOpen(cLogFile,2)) <> -1
					FSeek(nHandle,0,2)
					lRet := .T.
				EndIf
			EndIf
			If	lRet
				For nX := 1 To Len(aLog)
					FWrite(nHandle,aLog[nX]+_CRLF)
				Next nX
				FClose(nHandle)
			EndIf
			DLVTAviso('DLGV07013',STR0035 + cLogFile + STR0036)	//'O LOG '###' foi gerado. Entre em contato com seu Supervisor.'
		EndIf
	Else
		For nX := 1 to Len(aConferUSU)
			cEndDest := aConferUSU[nX, 1]
			For nY := 1 to Len(aConferUSU[nX, 2])
				cProduto := aConferUSU[nX, 2, nY, 1]
				nQuant   := aConferUSU[nX, 2, nY, 2]
				If (nPos:=aScan(aTotPrdSYS, {|x| x[1]==cProduto})) > 0
					//-- Realiza a Gravacao da Conferencia Enderecada no BOX
					dbSelectArea('SDB')
					dbSetOrder(1)
					dbGoto(aTotPrdSys[nPos, 5])
					If aScan(aRecnos, aTotPrdSys[nPos, 5]) == 0
						aAdd(aRecnos, aTotPrdSys[nPos, 5])
					EndIf
					CriaSDB(cProduto,DB_LOCAL,nQuant,cEndDest,DB_NUMSERI,DB_DOC,DB_SERIE,DB_CLIFOR,DB_LOJA,'','SDB',dDataBase,DB_LOTECTL,DB_NUMLOTE,DB_NUMSEQ,DB_TM,'E',DB_ITEM,.F.,Nil,Nil,Nil,DB_ESTFIS,DB_SERVIC,DB_TAREFA,DB_ATIVID,'N',DB_ESTDES,DB_ENDDES,Time(),'N',DB_CARGA,DB_UNITIZ,DB_ORDTARE,DB_ORDATIV,If(FieldPos('DB_RHFUNC')>0,DB_RHFUNC,DB_RECHUM),DB_RECFIS)
					If RecLock('SDB', .F.)
						Replace DB_STATUS  With '1'
						Replace DB_RECHUM  With __cUserID
						Replace DB_DATAFIM With dDataBase
						Replace DB_HRFIM   With Time()
					EndIf
				EndIf
			Next nY
		Next nX
		dbSelectArea('SDB')
		For nX := 1 to Len(aRecnos)
			dbGoto(aRecnos[nX])
			If RecLock('SDB', .F.)
				dbDelete()
				MsUnlock()
			EndIf
		Next nX
	EndIf
End Transaction	


VTClear()

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLG070IPrd  ³ Autor ³Fernando Joly Siquini³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Informacoes ref. ao Produto                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV70IPrd(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Produto a ser Pesquisado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGV070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLG070IPrd(cProduto)

Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt   := GetArea()
Local nLastro    := 0
Local nCamada    := 0
Local nUMInd     := 0
Local cUM        := ''
Local lRet       := .T.

Default cProduto   := SDB->DB_PRODUTO

If !Empty(cProduto)

	dbSelectArea('SB5')
	dbSetOrder(1)
	If !dbSeek(xFilial('SB5')+cProduto, .F.)
		DLVTAviso('DLGV07014',STR0024+AllTrim(cProduto)+STR0037)	//'O Produto '###' nao esta cadastrado no SB5'
		lRet := .F.
	Else
		nUMInd := Val(B5_UMIND)
		dbSelectArea('SB1')
		dbSetOrder(1)
		If !dbSeek(xFilial('SB1')+cProduto, .F.)
			DLVTAviso('DLGV07015',STR0024+AllTrim(cProduto)+STR0038)	//'O Produto '###' nao esta cadastrado no SB1'
			lRet := .F.
		Else
			cUM     := If(nUMInd==1,B1_UM,B1_SEGUM)
			cDescri := B1_DESC
			dbSelectArea('DC3')
			dbSetorder(1)
			If dbSeek(xFilial('DC3')+cProduto, .F.)
				dbSelectArea('DC2')
				dbSetorder(1)
				If dbSeek(xFilial('DC2')+DC3->DC3_CODNOR, .F.)
					nLastro := DC2_LASTRO
					nCamada := DC2_CAMADA
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		dbSelectArea('SAH')
		dbSetOrder(1)
		If dbSeek(xFilial('SAH')+cUM, .F.)
			cUm := AH_UMRES
		EndIf
		DLVTCabec(AllTrim(cProduto), .F., .F., .T.)
		@ 01, 00 VTSay PadR(cDescri, VTMaxCol())
		@ 02, 00 VTSay PadR(STR0039+AllTrim(cUM), VTMaxCol())	//'Unidade..: '
		@ 03, 00 VTSay PadR(STR0040+AllTrim(Str(nLastro)), VTMaxCol())	//'Lastro...: '
		@ 04, 00 VTSay PadR(STR0041+AllTrim(Str(nCamada)), VTMaxCol())	//'Camada...: '
		@ 05, 00 VTSay PadR(STR0042+AllTrim(Str(nLastro*nCamada)), VTMaxCol())	//'Cap.Max..: '
		DLVTRodaPe()
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)

EndIf
RestArea(aAreaAnt)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLV070QTD ºAutor  ³Microsiga           º Data ³  02/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da Quantidade Digitada                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLV070QTD(nQtdInf,cProduto)

Local lRet       := !Empty(nQtdInf)
Local aRetPE     := {}

If ExistBlock('DV070QTD')
	aRetPE  := ExecBlock('DV070QTD', .F., .F., {lRet, nQtdInf, cProduto})
	lRet    := aRetPE[01]
	nQtdInf := aRetPE[02]
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Informa   ºAutor  ³Microsiga           º Data ³  07/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra produtos que ja foram lidos                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DlV070Conf(aProdutos)
Local aCab       := {STR0012,STR0014}	//'Produto'###'Quantidade'
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
If Len(aProdutos) > 0
	VTClear()
	VTaBrowse(00, 00, VTMaxRow(), VTMaxCol(), aCab, aProdutos, aSize)
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Else
	DLVTAviso('DLGV07016',STR0043)	//'Nenhum Produto Conferido...'
EndIf
Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV70VlLot³ Autor ³ Alex Egydio           ³ Data ³27.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o lote digitado na conferencia pertence ao lote³±±
±±³          ³ do documento                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nr. do Lote digitado na conferencia                ³±±
±±³          ³ ExpA1 - Vetor contendo os nrs de lote do documento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DlV70VlLot(cLoteCtl,aLoteCtl)
Local lRet := .T.
If	Empty(cLoteCtl)
	lRet := .F.
Else
	If	Len(aLoteCtl)>0 .And. ASCan(aLoteCtl,cLoteCtl) == 0
		DLVTAviso('DLGV07017',STR0044+AllTrim(cLoteCtl)+STR0026)	//'O Lote '###' nao consta no documento atual.'
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
EndIf
Return(lRet)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV70VlSLt³ Autor ³ Flavio Luiz Vicco     ³ Data ³08.05.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Sub-Lote digitado na conferencia pertence ao ³±±
±±³          ³ Sub-lote do documento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nr. do Sub-Lote digitado                           ³±±
±±³          ³ ExpA1 - Vetor contendo os nrs de Sub-Lote do documento     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DlV70VlSLt(cSubLote,aSubLote)
Local lRet := .T.
If	Empty(cSubLote)
	lRet := .F.
Else
	If	Len(aSubLote)>0 .And. ASCan(aSubLote,cSubLote) == 0
		DLVTAviso('DLGV07018',STR0048+AllTrim(cSubLote)+STR0026) //'O Sub-Lote '###' nao consta no documento atual.'
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
EndIf
Return(lRet)
