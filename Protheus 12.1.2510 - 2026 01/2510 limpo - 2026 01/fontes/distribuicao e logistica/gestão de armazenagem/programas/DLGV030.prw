#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'DLGV030.CH'
#INCLUDE 'APVT100.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLGV030 ³ Autor ³ Alex Egydio            ³ Data ³18.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apanhe / Abastecimento de mercadorias                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLGV030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
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
Static lDV030EN1  := ExistBlock("DV030EN1") //-- Utilizado para confirmar o endereço de origem
Static lDV030CO1  := ExistBlock("DV030CO1") //-- Executado após informado o endereço origem, válido ou não
Static lDV030CON  := ExistBlock("DV030CON") //-- Executado após a confirmação do endereço origem válido
Static lDV030CO3  := ExistBlock("DV030CO3") //-- Executado antes do inicio da atividade, permite validação
Static lDV030DOC  := ExistBlock("DV030DOC") //-- Executado antes da solicitação do endereço da atividade
Static lDV030ENO  := ExistBlock("DV030ENO") //-- Executado para definir o endereço origem
Static lDV030END  := ExistBlock("DV030END") //-- Executado para definir o endereço destino
Static lDV030DES  := ExistBlock("DV030DES") //-- Executado para substituir a tela padrão de endereço destino
Static lDV030SDB  := ExistBlock("DV030SDB") //-- Executado após a alteração da situação na tabela SDB
Static lDV030CO6  := ExistBlock("DV030CO6") //-- Executado após a informação da quantidade, antes da validação
Static lDV030PRD  := ExistBlock("DV030PRD") //-- Executado na validação do produto para retornar as informações
Static lDLV030VL  := ExistBlock("DLV030VL") //-- Executado para efetuar a validação do produto digitado
Static lDV030SCR  := ExistBlock("DV030SCR") //-- Executado após a montagem da tela que exibe o produto para o usuário
Static lDV030CO4  := ExistBlock("DV030CO4")
Static lDV030SEP  := ExistBlock("DV030SEP")
Static lDV030LOT  := ExistBlock("DV030LOT") //-- Utilizado para tratar o número do lote na validação do mesmo
Static lDV030EST  := ExistBlock("DV030EST") //-- Executado para indicar se deve ou não movimentar estoque
Static lDVATUEST  := ExistBlock("DLGV030EST") //-- Executado para indicar se deve ou não movimentar estoque - Não utilizar mais
Static lDLGV040   := ExistBlock("DLGV040")
Static lCBRETEAN  := ExistBlock("CBRETEAN")
Static lDLVENDER  := ExistBlock("DLVENDER")
Static lDLVESTC9  := ExistBlock("DLVESTC9")
Static lDLV001VS  := ExistBlock("DLV001VS")
Static lDLV001ST  := ExistBlock("DLV001ST")
Static lWMSXDMOV  := ExistBlock("WMSXDMOV")
Static lWMSALOT   := ExistBlock("WMSALOT")

Static __cDispMov := ""
Static __cEstDMov := ""

Function DlgV030()
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local aSavKey   := VTKeys() //-- Salva todas as teclas de atalho anteriores
Local lRet      := .T.
Local cArmazem  := ""
Local cEndereco := ""
Local cConfirma := ""
//-- Versao simplificada telas de separacao no coletor de radiofrequencia
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.)
//-- Indica a unidade de medida utilizadas pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=U.M.I.
//-- 0=Permanece como antes ate a proxima versao
Local cWmsUMI   := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Local lRFEndDe  := SuperGetMV('MV_RFENDDE',.F.,.F.)
Local lRetPE    := .T.
Local aRetPE    := {.F.}
Local cRetPE    := ""
Local nQuant    := 0
Local nQtdTot   := 0
Local lNorma    := .T.
Local cDscAtv   := ""
Local lPrimAtiv := DLPrimAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
Local lUltiAtiv := DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
Local lMultAtiv := .F. //-- Parametro MV_WMSMTEA - Multiplas tarefas (atividades)
Local lMultApan := .F. //-- Parametro MV_RFENDDE - Mais de um apanhe, desde que menor que a norma
Local lAtPerMul := .T. //-- Indica se a atividade permite multiplos movimentos
Local nSaldoOri := 0
Local cUM       := ""
//-- Variaveis para solicitar dispositivo de movimentacao
Local lDispMov := .F.

Private cCadastro := STR0001 //'Apanhe'
Private lCtrlFOk  := .F.

	DLVAltSts(.F.)
	If DLVEndDes()
		//Deve descarregar as atividades pendentes
		lRet := DesMulAtiv(@cArmazem,@cEndereco)
		//-- Restaura as teclas de atalho anteriores
		VTKeys(aSavKey)
		RestArea(aAreaSDB)
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	If lRet
	nSaldoOri := WmsSaldoSBF(SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,.T.,.T.,.F.,.T.,'1',.F.)
	If QtdComp(nSaldoOri) < QtdComp(SDB->DB_QUANT)
		DLVTAviso('DLGV03001', STR0056+' '+SDB->DB_LOCALIZ+' '+STR0057)  //"Saldo no endereço"###"insuficiente para a retirada!"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//-- Define regras para solicitar o dispositivo de movimentacao
		If Empty(__cDispMov) .Or. Empty(__cEstDMov)
			lDispMov := .F.
			If lWMSXDMOV
				lDispMov := ExecBlock('WMSXDMOV',.F.,.F.)
				If ValType(lDispMov)!='L'
					lDispMov := .F.
				EndIf
			EndIf
			If lDispMov
				//-- Solicita o dispositivo de movimentacao
				WmsAtzSDB('2',,@__cDispMov,@__cEstDMov)
			EndIf
		EndIf

		If !Empty(__cDispMov) .And. !Empty(__cEstDMov)
			VTSetKey(4,{|| WmsAtzSDB('2',,@__cDispMov,@__cEstDMov)},STR0046) //Ctrl+D //"Dispositivo Movto."
		EndIf
		//-- Atribui a Funcao de INFORMACAO DA CARGA a Combinacao de Teclas <CTRL> + <G>
		VTSetKey(7,{|| DLV030Info()},STR0029) //Ctrl+G //"Info.Carga"

		//-- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If cWmsUMI == '4'
			SB5->(DbSetOrder(1))
			SB5->(MsSeek(xFilial('SB5')+SDB->DB_PRODUTO))
			cWmsUMI := SB5->B5_UMIND
		EndIf

		DC5->(DbSetOrder(1))
		DC5->(MsSeek(xFilial('DC5')+SDB->(DB_SERVIC+DB_ORDTARE) ))

		SX5->(DbSetOrder(1))
		SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
		cFunExe := AllTrim(Upper(SX5->(X5Descri())))
		If SX5->(MsSeek(xFilial('SX5')+'L3'+SDB->DB_ATIVID))
			cDscAtv := Upper(AllTrim(SX5->(X5Descri())))
		EndIf
		//-- Verifica se a atividade nesta ordem permite multiplos movimentos
		If DC6->(FieldPos("DC6_PERMUL")) > 0
			DC6->(DbSetOrder(1)) //-- DC6_FILIAL+DC6_TAREFA+DC6_ORDEM
			DC6->(MsSeek(xFilial('DC6')+SDB->DB_TAREFA+SDB->DB_ORDATIV))
			lAtPerMul := (DC6->DC6_PERMUL != '2')
		EndIf
		//-- Visualizar a unitizacao da carga
		If lDlgV040
			ExecBlock('DLGV040',.F.,.F.,{SDB->DB_CARGA})
		EndIf

		If lDV030CO3
			lRetPE:= ExecBlock('DV030CO3', .F., .F., {SDB->DB_PRODUTO})
			lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
		EndIf
	EndIf

	If lRet 
		If lDV030DOC
			ExecBlock('DV030DOC', .F., .F., {cFunExe})
		EndIf
		cArmazem := SDB->DB_LOCAL
		//-- Indica a unidade de medida utilizada pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=UNITIZADOR / 4=U.M.I.
		If cWmsUMI $ '2ú3' .And. SDB->DB_QTSEGUM==0
			cWmsUMI := '1'
		EndIf
		If cWmsUMI == '2'
			nQtdTot := SDB->DB_QTSEGUM - ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2)
		Else
			nQtdTot := SDB->DB_QUANT - SDB->DB_QTDLID
		EndIf

		If 'DLAPANHE' $ cFunExe
			cCadastro := STR0001   //'Apanhe'
			//-- Parametro: MV_RFENDDE - O sistema solicita a confirmacao do endereco de destino:
			//-- .F. = A cada apanhe, pois o apanhe eh de um unitizador completo
			//-- .T. = Somente no final do apanhe, pois o apanhe eh menor que a norma
			//-- Parametro: MV_RFENDBL - Default = .T. Habilita a verificacao da norma para estrutura = 6 (Blocado Fracionado)
			If lRFEndDe .And. (DLTipoEnd(SDB->DB_ESTFIS) <> 6 .Or. SuperGetMv('MV_RFENDBL',.F.,.T.))
				lNorma := (SDB->DB_QUANT >= DLQtdNorma(SDB->DB_PRODUTO,cArmazem,SDB->DB_ESTFIS,,.F.,cEndereco))
			EndIf
		ElseIf 'DLGXABAST' $ cFunExe
			cCadastro := STR0002   //'Reabastecimento'
		EndIf

		If nQtdTot > 0
			//-- Direciona RH para o Endereco Origem
			cEndereco := SDB->DB_LOCALIZ
			If !lPrimAtiv .And. cDscAtv == 'MOVIMENTO VERTICAL'
				//-- Usa endereco DESTINO se nao eh primeira atividade.
				cEndereco := SDB->DB_ENDDES
			EndIf
			If lDV030ENO
				cRetPE    := ExecBlock("DV030ENO", .F., .F.)
				cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
			EndIf

			//-- Solicita endereco origem e/ou exibe produto/lote/qtdade conforme regra definida pelo PE.
			If lWmsApan
				Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
					DLVEndereco(00, 00, cEndereco, cArmazem,,,STR0003) //'Va para o Endereco'
					If (VTLastKey()==27)
						DLV030ESC()
						Loop
					EndIf
					Exit
				EndDo
			EndIf

			//-- Confirma Endereco
			Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
				//--  01234567890123456789
				//--0 __Va p/o Endereco___
				//--1
				//--2 Endereco
				//--3 R01BL0102
				//--4
				//--5 Confirme !
				//--6 R01BL0102
				//--7
				cConfirma := Space(Len(cEndereco))
				//-- Direciona RH para o Endereco Origem
				If lDV030EN1
					cRetPE    := ExecBlock("DV030EN1", .F., .F.,{cEndereco})
					cConfirma := Iif(ValType(cRetPE)=="C",cRetPE,cConfirma)
				EndIf
				DLVTCabec(STR0003,.F.,.F.,.T.)   //'Va para o Endereco'
				@ 02, 00 VTSay PadR(STR0007, VTMaxCol()) //'Endereco'
				@ 03, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0008, VTMaxCol()) //'Confirme !'
				@ 06, 00 VTGet cConfirma Pict '@!' Valid DLV030VldEnd(@cConfirma, cEndereco)
				VTRead()
				If (VTLastKey()==27)
					DLV030ESC()
					Loop
				EndIf

				//-- Execblock no WHILE da confirmacao do endereco
				If lDV030CO1
					lRetPE:= ExecBlock('DV030CO1', .F., .F., {SDB->DB_PRODUTO, cEndereco, lRet})
					lRet  := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
				EndIf
				Exit
			EndDo
			 //-- Se não pulou ou bloqueou a atividade, nem escolheu descarregar, processa a atividade
			If lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
				//-- Execblock apos a confirmacao do endereco
				If lRet .And. lDV030CON
					aRetPE := ExecBlock('DV030CON')
					If ValType(aRetPE) != 'A'
						aRetPE := {.F.}
					EndIf
				EndIf
				//-- Força a releitura da quantidade
				If cWmsUMI == '2'
					nQtdTot := SDB->DB_QTSEGUM - ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2)
				Else
					nQtdTot := SDB->DB_QUANT - SDB->DB_QTDLID
				EndIf
				If lRet
					lRet := DLV030UM(SDB->DB_PRODUTO,cArmazem,SDB->DB_ESTFIS,cWmsUMI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,nQtdTot,lPrimAtiv,.T.)
				EndIf
			EndIf
		Else
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial('SB1')+SDB->DB_PRODUTO))
			If cWmsUMI == '2'
				cUM    := SB1->B1_SEGUM
				nQuant := SDB->DB_QTSEGUM
			Else
				cUM    := SB1->B1_UM
				nQuant := SDB->DB_QUANT
			EndIf

			DLVTAviso('DLGV03003',STR0017+AllTrim(SDB->DB_PRODUTO)+' '+Iif(!Empty(SDB->DB_LOTECTL),STR0012+AllTrim(SDB->DB_LOTECTL)+' ','')+STR0019+AllTrim(Str(nQuant))+' '+cUm+STR0047) //"Produto '#####' Lote '#####' Qtd '#####' já coletado. Faltando apenas finalizar a atividade."
		EndIf

		If lRet
			//-- Se quer bloquear a atividade atual ou todas as outras
			If DLVOpcESC() == 1 .Or. DLVOpcESC() == 2
				RecLock('SDB', .F.)
				SDB->DB_STATUS  := cStatProb
				SDB->DB_DATAFIM := dDataBase
				SDB->DB_HRFIM   := Time()
				MsUnlock()
				//-- Ponto de entrada para manipular o status da SDB
				If lDV030SDB
					ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
				EndIf
			//-- Se quer pular apenas esta atividade ou descarregar as outras
			ElseIf DLVOpcESC() == 3 .Or. DLVEndDes()
				RecLock('SDB', .F.)
				If DLVOpcESC() == 3
					DLGVAltPri() //-- Altera a prioridade da atividade atual
				EndIf
				SDB->DB_STATUS := cStatAExe
				MsUnlock()
				//-- Ponto de entrada para manipular o status da SDB
				If lDV030SDB
					ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
				EndIf
			EndIf
			//-- Se não pulou ou bloqueou a atividade, nem escolheu descarregar, coloca a mesma na pilha
			//-- Caso tenha pressionado CTRL-F e cancelado a quantidade toda não leva para o destino
			If DLVOpcESC() == 0 .And. !DLVEndDes() .And. QtdComp(SDB->DB_QUANT) > 0
				//-- Endereco de destino
				cEndereco := SDB->DB_ENDDES
				If lPrimAtiv .And. !lUltiAtiv .And. cDscAtv == 'MOVIMENTO VERTICAL'
					//-- Usa endereco ORIGEM se eh primeira atividade.
					//-- Solicita mesmo endereco, pois trata-se do 1o movto.
					cEndereco := SDB->DB_LOCALIZ
				EndIf
				If lDV030END
					cRetPE    := ExecBlock('DV030END', .F., .F.)
					cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
				EndIf

				//-- Grava array com os dados para enderecamento no final
			   AAdd(aColetor,{SDB->(Recno()),DtoS(dDataBase)+Time(),SDB->DB_LOCAL,SDB->DB_LOCALIZ,cEndereco,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_QUANT,SDB->DB_CARGA,SDB->DB_DOC,SDB->DB_CLIFOR,SDB->DB_LOJA,lPrimAtiv,lUltiAtiv})
			EndIf
		EndIf
	EndIf
	//-- Se deu erro, bloqueia a atividade atual
	If !lRet
		RecLock('SDB', .F.)
		SDB->DB_STATUS  := cStatProb
		SDB->DB_DATAFIM := dDataBase
		SDB->DB_HRFIM   := Time()
		MsUnlock()
		//-- Ponto de entrada para manipular o status da SDB
		If lDV030SDB
			ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
		EndIf
	EndIf
	lRet := .T.

	//-- Se não escolheu levar para o destino, deve verificar se existem outras atividades
	If (DLVOpcESC() == 0 .Or. DLVOpcESC() == 2 .Or. DLVOpcESC() == 3) .And. !DLVEndDes()
		//-- Verifica se tem mais registro com o mesmo tarefa
		If (nWmsMTea == 1 .Or. nWmsMTea == 3) .And. lAtPerMul // paramentro MV_WMSMTEA
			If DLVMultAtv(SDB->(Recno()))
				lMultAtiv := .T.
			EndIf
			RestArea(aAreaSDB) //-- Volta o registro do SDB que foi alterado
		Else
			// Se o que está separando não é uma norma deve verificar se existe um outro registro
			// no SDB que atenda a quantidade e possa ser separado colocando o mesmo na lista
			If !lNorma .And. lRFEndDe .And. lAtPerMul
				If DLVMultApn(SDB->(Recno()))
					lMultApan := .T.
				EndIf
				//-- Independente se é multiplo apanhe ou não, deve colocar o endereço no Array
				If AScan(aConfEnd,{|x|x[1]+x[2]==cArmazem+cEndereco}) == 0 .And. DLVOpcESC() == 0
					AAdd(aConfEnd,{cArmazem,cEndereco})
				EndIf
				RestArea(aAreaSDB) //-- Volta o registro do SDB que foi alterado
			EndIf
		EndIf
	EndIf
	//-- Limpa as opções do ESC quando tratar apenas da atividade atual
	If DLVOpcESC() == 2 .Or. DLVOpcESC() == 3
		DLVOpcESC(0)
	EndIf
	//-- Se está ativado o multi-tarefa e não vai selecionar uma próxima tarefa OU
	//-- Se está ativado o RFENDDE e não tem mais atividades do documento
	If DLVOpcESC() == 0 .And. !lMultAtiv .And. !lMultApan .And. Len(aColetor) > 0
		//-- Passa por referencia o armazém e endereço por causa da tecla de atalho <CTRL> + <E>
		If Len(aColetor) > 1 .Or. DLVEndDes()
			lRet := DesMulAtiv(@cArmazem,@cEndereco)
		Else
			lRet := DesUmaAtiv(@cArmazem,@cEndereco,lPrimAtiv,lUltiAtiv)
		EndIf
	EndIf

	//-- Se deu erro, bloqueia a atividade atual
	If !lRet .And. DLVOpcESC() == 0 
		RecLock('SDB', .F.)
		SDB->DB_STATUS  := cStatProb
		SDB->DB_DATAFIM := dDataBase
		SDB->DB_HRFIM   := Time()
		MsUnlock()
		//-- Ponto de entrada para manipular o status da SDB
		If lDV030SDB
			ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
		EndIf
	EndIf

VTClear()
VTKeyBoard(Chr(13)) //-- Tecla ENTER
VTInkey(0)
VTClearBuffer()
//-- Restaura as teclas de atalho anteriores
VTKeys(aSavKey)
RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV30VlPro³ Autor ³ Flavio Vicco          ³ Data ³01.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o codigo do produto eh valido                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Produto                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function DLV30VlPro(cProduto,cLoteCtl,nQtde,cSubLote,nQtdTot)
Local lRet     := .T.
Local lRetPE   := .T.
Local aRetPE   := {}
	If Empty(cProduto)
		Return .F.
	EndIf
	If lDV030PRD
		aRetPE := ExecBlock('DV030PRD',.F.,.F.,{cProduto})
		If ValType(aRetPE)=="A" .And. Len(aRetPE)==4
			cProduto := Padr(aRetPE[1],Len(SDB->DB_PRODUTO))
			cLoteCtl := Padr(aRetPE[2],Len(SDB->DB_LOTECTL))
			cSubLote := Padr(aRetPE[4],Len(SDB->DB_NUMLOTE))
			nQtde    := aRetPE[3]
			nQtdTot  := aRetPE[3]
			Return .T.
		EndIf
	EndIf
	lRet := DLVValProd(@cProduto,@cLoteCtl,@cSubLote,@nQtde)
	If lRet
		lRet := (cProduto==SDB->DB_PRODUTO)
		If lDLV030VL
			lRetPE:= ExecBlock('DLV030VL',.F.,.F.,{cProduto})
			lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
		EndIf
		If !lRet
			DLVTAviso('DLGV03019',STR0017+AllTrim(cProduto)+STR0020) //'Produto '###' nao consta no documento atual.'
			cProduto := Space(128)
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLV030UM  | Autor ³ Alex Egydio              ³Data³17.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita a qtde de apanhe                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Produto                                              ³±±
±±³          ³ ExpC2 - Armazem                                              ³±±
±±³          ³ ExpC3 - Estrutura fisica de origem                           ³±±
±±³          ³ ExpC4 - Conteudo do parametro MV_WMSUMI                      ³±±
±±³          ³ ExpC5 - Numero do Lote                                       ³±±
±±³          ³ ExpC6 - Numero do SubLote                                    ³±±
±±³          ³ ExpN1 - Quantidade para apanhe                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. = Indicando que o apanhe ou reabastecimento esta ok      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DLV030UM(cCodPro,cArmazem,cEstFis,cWmsUMI,cLoteOri,cSubLoteOri,nQtdTot,lPrimAtiv,lAtzQtdLid)
Local aCab      := {PadL(STR0019,15)+' UM'}   //'Qtde'
Local aSize     := {VTMaxCol()}
Local aQtde     := {}
Local aUni      := {}
Local aQtdUni   := {}
Local nItem     := 0
Local cUM       := ""
Local cPictQt   := ""
Local cLoteCTL  := ""
Local cSubLote  := ""
Local cProduto  := ""
Local lRet      := .T.
Local lEncerra  := .F.
Local lQtdValid := .T.
Local nProxLin  := 0
Local cCodEtq   := ""
Local nQtde     := 0
Local nQtdNorma := 0
Local nQtdItem  := 0
Local lFirst    := .T.
Local nInfLote  := 0 //-- Esta variável controla a troca de lote, só pode na 1ª vez
Local nToler    := SuperGetMV('MV_WMSQSEP',.F., 0 ) //-- Permite Qtde a maior Separac. / Reabast. RF
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) //-- Solicita a confirmacao do lote nas operacoes com RF
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.) //-- Versao simplificada telas de separacao no coletor RF
Local lWmsFSep  := SuperGetMV('MV_WMSFSEP',.F.,.F.) //-- Finaliza Separac. / Reabast. RF
Local aRetPE    := Nil
Local lWMSQMSEF := ExistBlock("WMSQMSEF")
Local nPerTolPE := 0

// Permite configurar um percentual de tolerância para separação a maior
If lRet .And. lWMSQMSEF
	nPerTolPE := ExecBlock("WMSQMSEF",.F.,.F.)
	If ValType(nPerTolPE) == "N"
		nToler := nPerTolPE / 100
	EndIf
EndIf

While DLVOpcESC() == 0 .And. !DLVEndDes() 
	//--  01234567890123456789
	//--0 ______Apanhe_______
	//--1 Pegue o Produto
	//--2 PA1
	//--3 Lote
	//--4 AUTO000636
	//--5
	//--6 ___________________
	//--7  Pressione <ENTER>
	DLVTCabec(cCadastro,.F.,.F.,.T.)
	@ 01,00 VTSay PadR(STR0009, VTMaxCol()) //'Pegue o Produto'
	@ 02,00 VTSay DLGVCOD(cCodPro)
	If lWmsLote .And. Rastro(cCodPro)
		@ 03,00 VTSay PadR(STR0012,VTMaxCol()) //'Lote '
		@ 04,00 VTSay cLoteOri
		//--5 Sub-Lote
		//--6 000636
		If Rastro(cCodPro,"S")
			@ 05,00 VTSay PadR(STR0034,VTMaxCol()) //"Sub-Lote "
			@ 06,00 VTSay PadR(cSubLoteOri,VTMaxCol())
			@ 07,00 VTSay "" //LINHA EM BRANCO
		EndIf
	EndIf
	If lDV030SCR
		ExecBlock("DV030SCR",.F.,.F.)
	EndIf
	DLVTRodaPe()

	If (VTLastKey()==27)
		DLV030ESC(!lAtzQtdLid)
		Loop
	EndIf
	Exit
EndDo

If lWmsFSep .And. lPrimAtiv .And. lAtzQtdLid
	//-- Atribui funcao para encerrar separacao/reabast. com qtde a menor a combinacao de teclas <CTRL> + <F>
	VTSetKey( 6,{||lEncerra:=AlteraQtd(.F.,cWmsUMI)},STR0035) //Ctrl+F###"Finalizar"
EndIf

If cWmsUMI == '2'
   nQtdTot := Round(nQtdTot,TamSX3('DB_QTSEGUM')[2])
EndIf

While DLVOpcESC() == 0 .And. !DLVEndDes()
	If nQtdTot <= 0
		VtBeep(3)
		Exit
	EndIf

	If cWmsUMI $ '1ú2'
		nItem := Iif(cWmsUMI == '1',3,2)
		nQtdItem := nQtdTot
		If Empty(cPictQt)
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial('SB1')+cCodPro))
			If cWmsUMI == '1'
				cPictQt:= PesqPict('SDB','DB_QUANT')
				cUM    := SB1->B1_UM
			ElseIf cWmsUMI == '2'
				cPictQt:= PesqPict('SDB','DB_QTSEGUM')
				cUM    := SB1->B1_SEGUM
			EndIf
		EndIf

		If lWmsApan
			aQtde := {}
			aAdd(aQtde,{PadL(Transform(nQtdTot,cPictQt),15)+' '+cUM})
			//--            1
			//--  01234567890123456789
			//--0 _______Apanhe_______
			//--1 Pegue o Produto
			//--2 PA1
			//--3             Qtde UM
			//--4 -------------------
			//--5           240.00 UN
			//--6 ___________________
			//--7  Pressione <ENTER>
			DLVTCabec(cCadastro,.F.,.F.,.T.)
			@ 01, 00 VTSay PadR(STR0009, VTMaxCol())  //'Pegue o Produto'
			@ 02, 00 VTSay DLGVCOD(cCodPro)
			DLVTRodaPe(,.F.)
			VTaBrowse(3,0,5,VTMaxCol(),aCab,aQtde,aSize)
		EndIf
	ElseIf cWmsUMI $ '3ú5'
		aQtdUni := WmsQtdUni(cCodPro,cArmazem,cEstFis,nQtdTot)
		If cWmsUMI == "3"
			 aQtde := {}
			 AAdd(aQtde,{PadL(Transform(aQtdUni[1,1],'@R 9999999999'),15)+' *'})
			 AAdd(aQtde,{PadL(Transform(aQtdUni[2,1],PesqPict('SDB','DB_QTSEGUM')),15)+' '+AllTrim(aQtdUni[2,2])})
			 AAdd(aQtde,{PadL(Transform(aQtdUni[3,1],PesqPict('SDB','DB_QUANT')),15)+' '+AllTrim(aQtdUni[3,2])})
			//--            1
			//--  01234567890123456789
			//--0            Qtde UM
			//--1 -------------------
			//--2            1,00 *
			//--3            0,00 CX
			//--4            0,00 UN
			//--5 (*) PALETE PBRII
			//--6 ___________________
			//--7  Unidade p/Apanhe?
			nItem := 1
			DLVTCabec(cCadastro,.F.,.F.,.T.)
			@ VTMaxRow()-2,0 VTSay PadR('(*) '+aQtdUni[1,2],VTMaxCol())
			DLVTRodaPe(STR0015+cCadastro+'?',.F.)   //'Unidade p/'
			nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),aCab,aQtde,aSize,,nItem)
			If nItem > 0
				nQtdItem := aQtdUni[nItem,1]
				cUM      := aQtdUni[nItem,2]
				cPictQt  := Iif(nItem==1,'@R 9999999999',Iif(nItem==2,PesqPict('SDB','DB_QTSEGUM'),PesqPict('SDB','DB_QUANT')))
			EndIf
		ElseIf cWmsUMI == "5"
			//--            1
			//--  01234567890123456789
			//--0 UNIDADE
			//--1 -------------------
			//--2 PALETE PBRII
			//--3 CAIXA
			//--4 PECA
			//--5 ___________________
			//--6
			//--7  Unidade p/Apanhe?
			If lFirst
				aUni := {}
				AAdd(aUni, {aQtdUni[1,2]})
				AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[2,2],'AH_UMRES')})
				AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[3,2],'AH_UMRES')})
				nItem := 1
				DLVTCabec(cCadastro,.F.,.F.,.T.)
				DLVTRodaPe(STR0015+cCadastro+'?',.F.)   //'Unidade p/'
				nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{RetTitle("B1_UM")},aUni,aSize,,nItem)
			EndIf
			If nItem > 0 .And. !lEncerra
				lFirst := .F.
				//-- Converter de U.M.I. p/ 1a.UM
				If nItem == 1
					nQtdNorma:= DLQtdNorma(cCodPro,cArmazem,cEstFis,,.F.)
					nQtdItem := (nQtdTot/nQtdNorma)
					cPictQt  := '@R 9999999999'
				//-- Converter de 2a.UM p/ 1a.UM
				ElseIf nItem == 2
					nQtdItem := ConvUm(cCodPro,nQtdTot,0,2)
					cPictQt  := PesqPict('SDB','DB_QTSEGUM')
				//-- 1a.UM
				ElseIf nItem == 3
					nQtdItem := nQtdTot
					cPictQt  := PesqPict('SDB','DB_QUANT')
				EndIf
				cUM    := aQtdUni[nItem,2]
				If lWmsApan
					aQtde := {}
					aAdd(aQtde,{PadL(Transform(nQtdItem,cPictQt),15)+' '+Iif(nItem==1,'*',AllTrim(aQtdUni[nItem,2]))})
					//--            1
					//--  01234567890123456789
					//--0 _______Apanhe_______
					//--1 Pegue o Produto
					//--2 PA1
					//--3             Qtde UM
					//--4 -------------------
					//--5           240.00 UN
					//--6 ___________________
					//--7  Pressione <ENTER>
					DLVTCabec(cCadastro,.F.,.F.,.T.)
					@ 00, 00 VTSay PadR(STR0009, VTMaxCol())  //'Pegue o Produto'
					@ 01, 00 VTSay DLGVCOD(cCodPro)
					@ VTMaxRow()-2,0 VTSay Iif(nItem==1,PadR('(*) '+aQtdUni[1,2],VTMaxCol()),'')
					DLVTRodaPe(,.F.)
					VTaBrowse(2,0,4,VTMaxCol(),aCab,aQtde,aSize)
				EndIf
			EndIf
		EndIf
	Else
		nItem := 3 //-- 1a UM
		nQtdItem := nQtdTot
		If Empty(cPictQt)
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial('SB1')+cCodPro))
			cPictQt:= PesqPict('SDB','DB_QUANT')
			cUM := SB1->B1_UM
		EndIf
	EndIf

	If lEncerra
		lCtrlFOk := .T.
		Exit
	EndIf
	If (VTLastKey()==27)
		DLV030ESC(!lAtzQtdLid .Or. (nInfLote>0))
		Loop
	EndIf

	If nItem <= 0
		Loop
	EndIf

	If nItem == 1 .And. nQtdItem < 1
		DLVTAviso("DLGV03007",STR0053+" "+Lower(cCadastro)+" "+STR0054)
		lFirst := .T.
		Loop
	EndIf

	//-- Leitura da etiqueta avulsa qd o produto for a granel
	If 'DLAPANHE' $ cFunExe
		WmsAtzSDB('4',,,,@cCodEtq)
	EndIf

	//--            1
	//--  01234567890123456789
	//--0 _______Apanhe_______
	//--1 Pegue o Produto
	//--2 PA1
	//--3 PA1
	//--4 Lote
	//--5 AUTO000636
	//--6 Qtd 240.00 UN
	//--7     240.00
	cProduto := Space(128)
	cLoteCtl := Space(Len(SDB->DB_LOTECTL))
	cSubLote := Space(Len(SDB->DB_NUMLOTE))
	nQtde    := 0
	DLVTCabec(cCadastro,.F.,.F.,.T.)
	nProxLin := 1
	@ nProxLin++, 00 VTSay PadR(STR0009, VTMaxCol()) //'Pegue o Produto'
	@ nProxLin++, 00 VTSay DLGVCOD(cCodPro)
	@ nProxLin++, 00 VTGet cProduto Picture PesqPict("SDB","DB_PRODUTO") Valid DlV30VlPro(@cProduto,@cLoteCtl,@nQtde,@cSubLote,@nQtdTot)
	If lWmsLote .And. Rastro(cCodPro)
		@ nProxLin++,00 VTSay PadR(STR0012,VTMaxCol()) //'Lote '
		@ nProxLin++,00 VTGet cLoteCtl Picture PesqPict("SDB","DB_LOTECTL") When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid DlV30VlLot(@cLoteCtl,@cLoteOri,@nQtdTot,(!lAtzQtdLid .Or. (nInfLote>0)),nItem,cUM,nProxLin)
	EndIf
	//Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
	If VTMaxRow() >= 10
		If lWmsLote .And. Rastro(cCodPro,"S")
			@ nProxLin++,00 VTSay PadR(STR0033,VTMaxCol()) //"Informe o Sub-Lote"
			@ nProxLin++,00 VTGet cSubLote Picture PesqPict('SDB','DB_NUMLOTE') When VTLastKey()==05 .Or. Empty(cSubLote) Valid DlV30VlSLt(cSubLote,cSubLoteOri)
		EndIf
	EndIf
	@ nProxLin++, 00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) //Qtd 240.00 UN
	@ nProxLin++, 00 VTGet nQtde Picture cPictQt When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
	VTRead()
	If lEncerra
		lCtrlFOk := .T.
		Exit
	EndIf
	If (VTLastKey()==27)
		DLV030ESC(!lAtzQtdLid .Or. (nInfLote>0))
		Loop
	EndIf
	//Se não tiver espaço na tela suficiente ele mostra o sub-lote em outra tela
	If VTMaxRow() < 10
		//--            1
		//--  01234567890123456789
		//--0 _______Apanhe_______
		//--1 Informe o Sub-Lote
		//--2 000636
		If lWmsLote .And. Rastro(cCodPro,"S")
			DLVTCabec(cCadastro,.F.,.F.,.T.)
			@ 01,00 VTSay PadR(STR0033,VTMaxCol()) //"Informe o Sub-Lote"
			@ 02,00 VTGet cSubLote Picture PesqPict('SDB','DB_NUMLOTE') When VTLastKey()==05 .Or. Empty(cSubLote) Valid DlV30VlSLt(cSubLote,cSubLoteOri)
			VTRead()
			If lEncerra
				lCtrlFOk := .T.
				Exit
			EndIf
			If (VTLastKey()==27)
				DLV030ESC(!lAtzQtdLid .Or. (nInfLote>0))
				Loop
			EndIf
		EndIf
	EndIf
	//- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
	If !(Iif(Empty(cLoteCtl),.T.,DlV30VlLot(cLoteCtl,cLoteOri,,(!lAtzQtdLid .Or. (nInfLote>0))))) .Or. ;
		!(Iif(Empty(cSubLote),.T.,DlV30VlSLt(cSubLote,cSubLoteOri)))
		lRet := .F.
		Loop
	EndIf
	//-- Já informou o lote
	//-- Deve fazer assim, pois não pode permitir alterar na segunda vez que o usuário
	//-- informar uma outra quantidade, pois o apanhe pode ser feito parcial
	nInfLote++

	If cWmsUMI != '2' //-- Se não está na 2a UM deve converter para a 1a UM
		//-- Converter de U.M.I. p/ 1a.UM
		If nItem == 1
			nQtdNorma:= DLQtdNorma(cCodPro,cArmazem,cEstFis,,.F.)
			nQtde    := (nQtde*nQtdNorma)
		//-- Converter de 2a.UM p/ 1a.UM
		ElseIf nItem == 2
			nQtde := ConvUm(cCodPro,0,nQtde,1)
			nQtde := Round(nQtde,TamSX3('DB_QUANT')[2])
		EndIf
	EndIf

	nQtdTot -= nQtde
	If lDV030CO6
		aRetPE := ExecBlock('DV030CO6',.F.,.F.,{nQtdTot, nQtde})
		If ValType(aRetPE) == 'A'
			nQtdTot := aRetPE[1]
		EndIf
	EndIf
	lQtdValid := .T.
	If nQtdTot < 0
		If nToler <= 0
         DLVTAviso("DLGV03015",STR0065) //"Não possui percentual de tolerancia de separação a maior cadastrado."
         lQtdValid := .F.
	   ElseIf !lPrimAtiv
         DLVTAviso("DLGV03016",STR0066) //"Somente na primeira atividade poderá ser separado uma quantidade maior que a solicitada."
	      lQtdValid := .F.
		ElseIf !AlteraQtd(.T.,cWmsUMI,Iif(cWmsUMI=='2',ConvUm(cCodPro,0,nQtdTot*(-1),1),nQtdTot*(-1)))
		   lQtdValid := .F.
		EndIf
		If !lQtdValid
			//-- Retorna ao valor anterior
			nQtdTot += nQtde
			nInfLote--
		EndIf
	EndIf
	If lQtdValid .And. lAtzQtdLid //-- Quando está sendo chamado da descarga multi-tarefa não pode atualizar
		//-- Grava etiqueta avulsa
		If lPrimAtiv
			WmsAtzSDB('5',nQtde,,,cCodEtq)
		EndIf
		//Grava a quantidade lida para o movimento
		RecLock('SDB', .F.) // Trava para gravacao
		SDB->DB_QTDLID += Iif(cWmsUMI == '2',ConvUm(cCodPro,0,nQtde,1),nQtde)
		MsUnlock() // Destrava apos gravacao
	EndIf
EndDo
VTSetKey(6) //Ctrl+F
Return (lRet)

/*-----------------------------------------------------------------------------
Função para efetuar a descarga de apenas um movimento
Jackson Patrick Werka
-----------------------------------------------------------------------------*/
Static Function DesUmaAtiv(cArmazem,cEndereco,lPrimAtiv,lUltiAtiv)
Local aAreaAnt  := GetArea()
Local lRet      := .T.

	lRet := DLV030End(cArmazem,cEndereco)
	If lRet
		//-- Força a releitura da situação do SDB
		SDB->(DbGoTo(Recno()))
		lRet := FinalAtiv(lUltiAtiv,Len(aColetor))
	EndIf
	If DLVEndDes()
		aConfEnd := {}
	EndIf

RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Função para efetuar a descarga dos movimentos quando for multi-tarefa
Jackson Patrick Werka
-----------------------------------------------------------------------------*/
Static Function DesMulAtiv(cArmazem,cEndereco)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nQtdTot   := 0
Local nCntEnd   := 0
Local nCntMov   := 0
Local cWmsUMI   := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0')) //-- Indica a unidade de medida utilizadas pelas rotinas de RF
Local cWmsUMIP  := cWmsUMI
Local aEndDest  := {}
Local cProduto  := ''
Local cLoteCtl  := ''
Local cSubLote  := ''
Local lPrimAtiv := .F.
Local lUltiAtiv := .F.
Local lEfetDesc := .F.
Local cEndAnt   := ''
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) //-- Descarga apenas considerando o endereço sem o armazém

	If nWmsMTea == 1 .Or. nWmsMTea == 3
		If Len(aColetor) > 1
			aEndDest := DLGV001ORD(aColetor)
		Else
			aEndDest := AClone(aColetor)
		EndIf
	Else
		aEndDest := AClone(aConfEnd)
		If lWmsDaEn
			ASort(aEndDest,,,{|x,y| x[1]+x[2]<y[1]+y[2]})
		EndIf
	EndIf

	For nCntEnd := 1 To Len(aEndDest)
		If nWmsMTea == 1 .Or. nWmsMTea == 3
			cArmazem  := aEndDest[nCntEnd,3]
			cEndereco := aEndDest[nCntEnd,5]
			cProduto  := aEndDest[nCntEnd,6]
			cLoteCtl  := aEndDest[nCntEnd,7]
			cSubLote  := aEndDest[nCntEnd,8]
		Else
			cArmazem  := aEndDest[nCntEnd,1]
			cEndereco := aEndDest[nCntEnd,2]
		EndIf

		If lWmsDaEn
			If cEndereco <> cEndAnt
				lRet := DLV030End(cArmazem,cEndereco)
				cEndAnt := cEndereco
			EndIf
		Else
			lRet := DLV030End(cArmazem,cEndereco)
		EndIf

		//-- Deve pesquisar se tem mais algum registro indicando outro produto
		If lRet .And. (nWmsMTea == 1 .Or. nWmsMTea == 3)
			//If AScan(aEndDest,{|x|x[3]+x[5]==cArmazem+cEndereco},nCntEnd+1) > 0
			If Len(aEndDest) > 1
				SDB->(DbGoTo(aEndDest[nCntEnd,1])) //Posiciona no SBD para validar o produto
				//-- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
				cWmsUMIP := cWmsUMI
				If cWmsUMI == '4'
					SB5->(DbSetOrder(1))
					SB5->(MsSeek(xFilial('SB5')+SDB->DB_PRODUTO))
					cWmsUMIP := SB5->B5_UMIND
				EndIf
				If cWmsUMIP $ '2ú3' .And. SDB->DB_QTSEGUM==0
					cWmsUMIP := '1'
				EndIf
				nQtdTot := Iif(cWmsUMIP=='2',ConvUm(SDB->DB_PRODUTO,aEndDest[nCntEnd,9],0,2),aEndDest[nCntEnd,9])
				lPrimAtiv := aEndDest[nCntEnd,14]
				lRet := DLV030UM(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTFIS,cWmsUMIP,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,nQtdTot,lPrimAtiv,.F.)
			EndIf
		EndIf

		If lRet
			For nCntMov := Len(aColetor) To 1 Step -1
				lUltiAtiv := aColetor[nCntMov,15]
				lEfetDesc := .F.
				//-- Se a movimentação é para o mesmo endereço destino
				If nWmsMTea == 1 .Or. nWmsMTea == 3
					If aColetor[nCntMov,3]+aColetor[nCntMov,5]+aColetor[nCntMov,6]+aColetor[nCntMov,7]+aColetor[nCntMov,8] == cArmazem+cEndereco+cProduto+cLoteCtl+cSubLote
						lEfetDesc := .T.
					EndIf
				Else
					If aColetor[nCntMov,3]+aColetor[nCntMov,5] == cArmazem+cEndereco
						lEfetDesc := .T.
					EndIf
				EndIf

				If lEfetDesc
					//-- Posiciona o registro de movimentação
					SDB->(DbGoTo(aColetor[nCntMov,1]))
					lRet := FinalAtiv(lUltiAtiv,nCntMov)
				EndIf
			Next nCntMov
		EndIf

		If DLVOpcESC() > 0
			//-- Neste caso, sempre vai forçar bloquear todas as atividades que ficaram pendentes
			If DLVOpcESC() == 2
				DLVOpcESC(1)
			EndIf
			Exit
		EndIf

	Next nCntEnd
	aConfEnd := {}

RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Função para efetuar a finalização das atividades movimentando o estoque
Jackson Patrick Werka
-----------------------------------------------------------------------------*/
Static Function FinalAtiv(lUltiAtiv,lPosCol)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lRetPE     := .T.
Local lAtuEst    := .T.

Default lUltiAtiv := .T.

	If lDVATUEST //-- Não utilizar mais
		lRetPE := ExecBlock("DLGV030EST",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf
	If lDV030EST
		lRetPE := ExecBlock("DV030EST",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf

	If SDB->(SimpleLock()) .And. SDB->DB_STATUS==cStatInte // Verifica se conseguiu travar registro
		Begin Transaction
		If lAtuEst .And. lUltiAtiv
			//-- Gera SDB de movimentacao para o dispositivo de movimentacao.
			If !Empty(__cDispMov) .And. !Empty(__cEstDMov)
				WmsAtzSDB('3',SDB->DB_QUANT,__cDispMov,__cEstDMov)
			EndIf
			//-- Confirma o movimento de distribuicao atualizando o estoque.
			lRet := DLVGrSaida(cFunExe)
		EndIf
		If lRet
			//-- Atualiza o SDB para finalizado
			RecLock('SDB', .F.)  // Trava para gravacao
			SDB->DB_STATUS  := cStatExec
			SDB->DB_DATAFIM := dDataBase
			SDB->DB_HRFIM   := Time()
			MsUnlock() // Destrava apos gravacao
			//P.E. para manipular o status da SDB
			If lDV030SDB
				ExecBlock("DV030SDB",.F.,.F.,{lCtrlFOk})
			EndIf
		EndIf
		 //-- Retira do Array a movimentação, mesmo que não tenha movimentado
		If !Empty(aColetor)
			ADel(aColetor,lPosCol) //-- Apaga do array o registro que ja foi movimentado
			ASize(aColetor,Len(aColetor)-1)   //-- Exclui fisicamente o registro do array
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
		End Transaction
	Else
		SDB->(MsUnLock())
		lRet := .F.
	EndIf

RestArea(aAreaAnt)
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLV030END | Autor ³ Alex Egydio              ³Data³12.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita o endereco de destino                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Vetor contendo o endereco de destino                 ³±±
±±³          ³ ExpC2 - Armazem                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DLV030End(cArmazem,cEndereco)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWmsApan  := SuperGetMV('MV_WMSAPAN',.F.,.T.) //-- Versao simplificada telas de separacao no coletor RF
Local lRet      := .T.
Local lRetPE    := .F.
Local cRetPE    := ""
Local cConfirma := ""

	//-- Ponto de entrada para elaborar a selecao do endereco de destino do apanhe.
	If lDV030DES
		lRetPE := ExecBlock('DV030DES',.F.,.F.)
		lRet   := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	Else
		If lWmsApan
			DLVEndereco(00, 00, cEndereco, cArmazem,,,STR0013) //'Leve para o Endereco'
			If (VTLastKey()==27) .And. (DLVTAviso('DLGV03005',STR0004+cCadastro+'?', {STR0005,STR0006})==1)  //'Deseja encerrar o '###'Sim'###'Nao'
				DLVOpcESC(1) // Bloquear Todas Atividades
				lRet := .F.
			EndIf
		EndIf
		//-- Confirma Endereco
		If lRet
			Do While .T.
				If lDV030CO4
					cRetPE   := ExecBlock('DV030CO4', .F., .F., {cEndereco})
					cConfirma:= Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
				Else
					cConfirma := Space(Len(cEndereco))
				EndIf
				DLVTCabec(STR0013,.F.,.F.,.T.)   //'Leve para o Endereco'
				@ 02, 00 VTSay PadR(STR0007, VTMaxCol()) //'Endereco'
				@ 03, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0008, VTMaxCol()) //'Confirme !'
				@ 06, 00 VTGet cConfirma Pict '@!'  Valid DLV030VldEnd(@cConfirma, cEndereco)
				VTRead()
				If (VTLastKey()==27)
					If DLVTAviso('DLGV03006',STR0004+cCadastro+'?', {STR0005,STR0006})==1 //'Deseja encerrar o '###'Sim'###'Nao'
						DLVOpcESC(1) // Bloquear Todas Atividades
						lRet := .F.
					Else
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			DLVEndDes(.T.)
		EndIf
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLV030VldEnd³ Autor ³ Alex Egydio         ³ Data ³20.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do endereco                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV030VldEnd( ExpC1, ExpC2, ExpC3, ExpC4, ExpL1 )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Endereco digitado                                  ³±±
±±³          ³ ExpC2 = Armazem                                            ³±±
±±³          ³ ExpC3 = Estrutura                                          ³±±
±±³          ³ ExpC4 = Endereco sugerido pelo sistema                     ³±±
±±³          ³ ExpL1 = .T. Digitacao / .F. Leitura via coletor de dados   ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DLV030VldEnd(cConfirma, cEndereco)
Local lRet := .T.
If Empty(cConfirma)
	lRet := .F.
Else
	lRet := (AllTrim(cConfirma)==Alltrim(cEndereco))
	If lDLVENDER
		lRet := ExecBlock('DLVENDER',.F.,.F.,{cConfirma, cEndereco})
	EndIf
	If !lRet
		DLVTAviso('DLGV03009',STR0018)    //"Endereco Incorreto"
		VTKeyBoard(chr(20))
	EndIf
EndIf
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLV030Info | Autor ³ Flavio Luiz Vicco        ³Data³04.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informacoes ref. ao docto. <Ctrl+G>                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DLV030Info()
Local aAreaAnt  := GetArea()
Local lWmsCarga := WmsCarga(SDB->DB_CARGA)
Do Case
	Case SDB->DB_ORIGEM == "SC9"
		dbSelectArea("SA1")
		dbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
		msSeek(xFilial("SA1")+SDB->DB_CLIFOR+SDB->DB_LOJA)
		DLVTAviso(cCadastro,;
		If(Empty(SDB->DB_CARGA),"",Padr(STR0031+SDB->DB_CARGA,VTMaxCol()))+; //"Carga..: "
		If(lWmsCarga,"",Padr(STR0042+SDB->DB_DOC  ,VTMaxCol()))+; //"Pedido.: "
		If(Empty(SDB->DB_UNITIZ),"",Padr(STR0032+SDB->DB_UNITIZ,VTMaxCol()))+; //"Unitizador:"
		STR0043+SA1->A1_NOME) //"Cliente: "
	OtherWise
		DLVTAviso(cCadastro,STR0030+SDB->DB_DOC) //"Docto:"
EndCase
RestArea(aAreaAnt)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLVGrSaida³ Autor ³ Alex Egydio           ³ Data ³20.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV010VldPro( ExpC1, ExpL1 )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome da funcao                                     ³±±
±±³          ³ ExpL1 = .T. = Processo por carga                           ³±±
±±³          ³         .F. = Processo por documento                       ³±±
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
Function DLVGrSaida(cFunExe,lCarga,lHelp)
Local lRet        := .T.
Local lWmsAtzSC9  := .T.
Local lBlqLibFat  := .F.
Local lConfExp    := .F.
Local lMntVol     := .F.
Local cAliasQry   := ""
Local cQuery      := ""
Local cLibPed     := '1'
Local cNumSerie   := Space(TamSx3("DB_NUMSERI")[1]) //-- Numero de Serie

Private aParam150 := Array(34)
Private lExec150  := .F.
Default lCarga    := .F.
Default lHelp     := .T.

//-- Ao confirmar a ultima atividade da tarefa registrar o movimento de estoque.
If DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
	aParam150[01]  := SDB->DB_PRODUTO //-- Produto
	aParam150[02]  := SDB->DB_LOCAL   //-- Almoxarifado
	aParam150[03]  := SDB->DB_DOC     //-- Documento
	aParam150[04]  := SDB->DB_SERIE   //-- Serie
	aParam150[06]  := SDB->DB_QUANT   //-- Saldo do produto em estoque
	aParam150[07]  := SDB->DB_DATA    //-- Data da Movimentacao
	aParam150[08]  := Time()          //-- Hora da Movimentacao
	aParam150[09]  := SDB->DB_SERVIC  //-- Servico
	aParam150[10]  := SDB->DB_TAREFA  //-- Tarefa
	aParam150[11]  := SDB->DB_ATIVID  //-- Atividade
	aParam150[12]  := SDB->DB_CLIFOR  //-- Cliente/Fornecedor
	aParam150[13]  := SDB->DB_LOJA    //-- Loja
	aParam150[14]  := ''              //-- Tipo da Nota Fiscal
	aParam150[15]  := '01'            //-- Item da Nota Fiscal
	aParam150[16]  := ''              //-- Tipo de Movimentacao
	aParam150[17]  := SDB->DB_ORIGEM  //-- Origem de Movimentacao
	aParam150[18]  := SDB->DB_LOTECTL //-- Lote
	aParam150[19]  := SDB->DB_NUMLOTE //-- Sub-Lote
	aParam150[20]  := SDB->DB_LOCALIZ //-- Endereco
	aParam150[21]  := SDB->DB_ESTFIS  //-- Estrutura Fisica
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DCF.R_E_C_N_O_ DCFRECNO "
	cQuery += "  FROM "+RetSqlName('DCF')+" DCF "
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery += "   AND DCF.DCF_NUMSEQ = '"+SDB->DB_NUMSEQ+"'"
	cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		DCF->(DbGoTo((cAliasQry)->DCFRECNO))//Posicionar no DCF selecionado
	EndIf
	(cAliasQry)->(DbCloseArea())
	//Força a definição de uma área ativa
	DbSelectArea('SDB')
	If DCF->(Eof()) .Or. Empty(DCF->DCF_REGRA)
		aParam150[22]:= 0                   //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA.SEQ.ABAST/4=DATA)
	Else
		aParam150[22]:= Val(DCF->DCF_REGRA) //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA.SEQ.ABAST/4=DATA)
	EndIf
	aParam150[05]  := DCF->DCF_NUMSEQ
	aParam150[23]  := SDB->DB_CARGA   //-- Carga
	aParam150[24]  := SDB->DB_UNITIZ  //-- Nr. do Pallet
	aParam150[25]  := SDB->DB_LOCAL   //-- Centro de Distribuicao Destino
	aParam150[26]  := SDB->DB_ENDDES  //-- Endereco Destino
	aParam150[27]  := SDB->DB_ESTDES  //-- Estrutura Fisica Destino
	aParam150[28]  := SDB->DB_ORDTARE //-- Ordem da Tarefa
	aParam150[29]  := SDB->DB_ORDATIV //-- Ordem da Atividade
	aParam150[30]  := SDB->DB_RHFUNC  //-- Funcao do Recurso Humano
	aParam150[31]  := SDB->DB_RECFIS  //-- Recurso Fisico
	aParam150[32]  := SDB->DB_IDDCF   //-- Identificador do DCF DCF_ID
	aParam150[34]  := SDB->DB_IDMOVTO //-- Identificador exclusivo do Movimento no SDB

	If lHelp
		DLVTCabec(cCadastro,.F.,.F.,.T.)
		@ Int(VTMaxRow()/2), 00 VtSay STR0028 //'Processando...'
	EndIf

	If 'DLGXABAST' $ cFunExe
		lRet := DlgxAbast(.T.,'2')
	Else

		DC5->(DbSetOrder(1))
		If DC5->(FieldPos('DC5_COFEXP')) > 0  .And. DC5->(DbSeek(xFilial('DC5')+SDB->DB_SERVIC+SDB->DB_ORDTARE))
			lConfExp := (DC5->DC5_COFEXP == '1')
			cLibPed  := DC5->DC5_LIBPED
		EndIf

		lMntVol := SuperGetMV("MV_WMSVEMB",.F.,.F.) .And. (('DLAPANHEVL' $ cFunExe) .Or. ('DLAPANHEC2' $ cFunExe))

		cQuery := "SELECT DCF.DCF_CARGA, DCF.DCF_DOCTO, DCF.DCF_SERIE, DCF.DCF_CLIFOR, DCF.DCF_LOJA, DCF.DCF_NUMSEQ, DCR.DCR_QUANT, DCR.DCR_IDDCF"
		cQuery +=  " FROM "+RetSqlName("DCR")+" DCR, "+RetSqlName("DCF")+" DCF"
		cQuery += " WHERE DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
		cQuery +=   " AND DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=   " AND DCR.DCR_IDORI  = '"+SDB->DB_IDDCF+"'"
		cQuery +=   " AND DCR.DCR_IDMOV  = '"+SDB->DB_IDMOVTO+"'"
		cQuery +=   " AND DCR.DCR_IDOPER = '"+SDB->DB_IDOPERA+"'"
		cQuery +=   " AND DCF.DCF_ID     = DCR.DCR_IDDCF"
		cQuery +=   " AND DCR.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		While (cAliasQry)->(!Eof()) .And. lRet
				
			//Substitui inforações para tratar movimentos aglutinados.
			aParam150[03] := (cAliasQry)->DCF_DOCTO  //Documento
			aParam150[04] := (cAliasQry)->DCF_SERIE  //Serie
			aParam150[06] := (cAliasQry)->DCR_QUANT  //Quantidade
			aParam150[12] := (cAliasQry)->DCF_CLIFOR //Cliente
			aParam150[13] := (cAliasQry)->DCF_LOJA   //Loja						
			aParam150[05] := (cAliasQry)->DCF_NUMSEQ //Sequencial
			aParam150[32] := (cAliasQry)->DCR_IDDCF  //Identificador do DCF  
			
			//-- Efetua a movimentação de estoque
			If lRet
				lRet := WmsMovEst(aParam150,,,,2)
			EndIf

			lWmsAtzSC9 := (DLTipoEnd(SDB->DB_ESTDES) != 7)
			lBlqLibFat := lMntVol .Or. (lConfExp .And. cLibPed $ '34') .Or. (cLibPed == '2' .And. HasConfSai())

			//-- Efetua a liberação do pedido de venda
			If lRet .And. SDB->DB_ORIGEM == 'SC9'
				lRet := WmsAtuSC9((cAliasQry)->DCF_CARGA,(cAliasQry)->DCF_DOCTO,(cAliasQry)->DCF_SERIE,SDB->DB_PRODUTO,SDB->DB_SERVIC,/*cLoteCtl*/SDB->DB_LOTECTL,/*cNumLote*/SDB->DB_NUMLOTE,cNumSerie,(cAliasQry)->DCR_QUANT,/*nQuant2UM*/,SDB->DB_LOCAL,SDB->DB_ENDDES,/*cIdDCF*/(cAliasQry)->DCR_IDDCF,aParam150[22],CtoD(''),!lBlqLibFat)
			EndIf

			// Atualiza as informacoes de requisicao de empenho de ordens de producao
			If lRet .And. GetVersao(.F.) >= "12" .And. SDB->DB_ORIGEM == 'SD4'
				lRet := WmsAtuSD4(SDB->DB_LOCAL,SDB->DB_PRODUTO,/*cLoteCtl*/SDB->DB_LOTECTL,/*cNumLote*/SDB->DB_NUMLOTE,cNumSerie,SDB->DB_ENDDES,(cAliasQry)->DCR_QUANT,/*cIdDCF*/(cAliasQry)->DCR_IDDCF,.F.)
			EndIf

			If lRet
				If lMntVol
					lRet := WmsVolEmb((cAliasQry)->DCF_CARGA,(cAliasQry)->DCF_DOCTO,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_TAREFA,(cAliasQry)->DCR_QUANT,cLibPed,(cAliasQry)->DCR_IDDCF)
				EndIf
				If lConfExp
					lRet := WmsConfMult((cAliasQry)->DCF_CARGA,(cAliasQry)->DCF_DOCTO,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_TAREFA,(cAliasQry)->DCR_QUANT,cLibPed,(cAliasQry)->DCR_IDDCF)
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

	EndIf
	//-- Grava status de execucao automatica
	If lRet
		DLVStAuto(aParam150[09],aParam150[28],aParam150[10])
	EndIf

	If !lRet .And. lHelp
		DLVTAviso('DLGV03010',STR0014+cCadastro+'!')  //'Problemas no '
	EndIf
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV30VlLot³ Autor ³ VICCO                 ³ Data ³01.12.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o lote digitado na conferencia pertence ao lote³±±
±±³          ³ do documento                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nr. do Lote digitado na conferencia                ³±±
±±³          ³ ExpA1 - Nr. de lote do documento                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlV30VlLot(cLoteCtl,cLoteOri,nQtdTot,lForceLote,nItem,cUM,nProxLin)
Local aAreaSDB   := SDB->(GetArea())
Local aTela      := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet       := .T.
Local nSaldoSBF  := 0
Local lConSldRF  := .T.
Local cWMSALOT   := SuperGetMV('MV_WMSALOT',.F.,'1') //-- Permite Alterar nro lote separacao -RF-. 1=Nao / 2=Sim / 3=Confirmacao
Local cRetPE     := ""
Local aCab       := {STR0012,STR0048} //Lote //Quant
Local aLotes     := {{SDB->DB_LOTECTL,SDB->DB_QUANT}}
Local aSize      := {TamSx3("DB_LOTECTL")[1],TamSx3("DB_QUANT")[1]}
Local cAliasSDB  := ""
Local cAliasSLT  := ""
Local cAliasCF   := ""
Local cAliasDCR  := ""
Local aDadosAlt  := {}
Local nNovoRecno := 0
Local nQtdMov    := 0 
Local nQuant2UM  := 0
Local cIdMovto   := '' 
Local cNumIDOper := ''

Default lForceLote := .F.

//-- PE para tratar o numero do lote.
If lDV030LOT
	cRetPE := ExecBlock("DV030LOT",.F.,.F.,{SDB->DB_PRODUTO,cLoteCtl})
	If ValType(cRetPE) == "C"
		cLoteCtl := cRetPE
	EndIf
EndIf

If cWMSALOT == "1" .Or. lForceLote
	If Empty(cLoteCtl)
	   VTClear()
		DLVTCabec(STR0049,.F.,.F.,.T.) //Lotes a separar
		VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aLotes,aSize)
		VtRestore(,,,,aTela)
		lRet := .F.
	ElseIf cLoteCtl <> cLoteOri
		DLVTAviso("DLGV03024",STR0012+AllTrim(cLoteCtl)+STR0020) //"Lote "###" nao consta no documento atual."
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
Else
	//-- Selecionar lotes a separar do mesmo endereço.
	If Empty(cLoteCtl)
		lRet := .F.
		If DlV30Lote(@cLoteCtl,@cLoteOri,@nQtdTot,nItem,cUM,nProxLin)
			aAreaSDB := SDB->(GetArea())
		EndIf
	ElseIf cLoteCtl <> cLoteOri
		//-- Nova funcionalidade para permitir o apanhe de um numero de lote diferente do solicitado
		//-- Observacao: Necessario possuir saldo disponivel do novo lote informado no mesmo endereco.
		DCF->(DbSetOrder(2))
		If DCF->(MsSeek(xFilial("DCF")+SDB->DB_SERVIC+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_PRODUTO) .And. DCF_ORIGEM$"DCF/SC9")
			If cWMSALOT == "2" .Or. (cWMSALOT == "3" .And. DLVTAviso(cCadastro,STR0039,{STR0005,STR0006})==1) //"Deseja alterar o lote?"###"Sim"###"Nao"
				If lWMSALOT
					lConSldRF := ExecBlock("WMSALOT",.F.,.F.)
					lConSldRF := Iif(ValType(lConSldRF)<>"L",.T.,lConSldRF)
				EndIf
				//-- Validar se existe saldo do lote/sublote no endereco.
				nSaldoSBF := WmsSaldoSBF(SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,cLoteCtl,SDB->DB_NUMLOTE,.F.,.T.,.F.,.T.,"1",lConSldRF)
				//-- Verifica se o saldo do lote é maior que o solicitado pelo movimento
				If QtdComp(nSaldoSBF) >= QtdComp(SDB->DB_QUANT)
					nQtdMov := SDB->DB_QUANT
					//quando efetuar uma alteração de lote deve alterar 
					cAliasSDB := GetNextAlias()	
				    BeginSql Alias cAliasSDB
						SELECT SDB.R_E_C_N_O_ as RECNOSDB 
						FROM %Table:SDB% SDB
						WHERE SDB.DB_FILIAL  =  %xFilial:SDB% 
						AND SDB.DB_SERVIC = %Exp:SDB->DB_SERVIC%
						AND SDB.DB_DOC = %Exp:SDB->DB_DOC%
  						AND SDB.DB_SERIE = %Exp:SDB->DB_SERIE%
  						AND SDB.DB_CLIFOR = %Exp:SDB->DB_CLIFOR%
  						AND SDB.DB_LOJA = %Exp:SDB->DB_LOJA%
  						AND SDB.DB_PRODUTO = %Exp:SDB->DB_PRODUTO%
    					AND SDB.DB_ESTORNO = ' '
    					AND SDB.DB_IDDCF = %Exp:SDB->DB_IDDCF% 
   						AND SDB.DB_IDMOVTO =  %Exp:SDB->DB_IDMOVTO% 
       					AND SDB.%NotDEl%
					ENDSQL
					Do While (cAliasSDB)->(!Eof())
						SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
						RecLock("SDB",.F.)
						SDB->DB_LOTECTL := cLoteCtl
						SDB->(MsUnlock())
						(cAliasSDB)->(DbSkip())
					ENDDO
					(cAliasSDB)->(dbCloseArea())
					cAliasCF := GetNextAlias()	
				    BeginSql Alias cAliasCF
						SELECT  SDB.R_E_C_N_O_ as RECNOSDB,
	   				 	   		SDB.DB_QUANT,
								SDB.DB_IDDCF,
								SDB.DB_PRODUTO,
								SDB.DB_IDOPERA,
								SDB.DB_IDMOVTO	   
  						FROM %Table:SDB% SDB
  						INNER JOIN %Table:DC5% DC5
   						ON DC5.DC5_FILIAL = %xFilial:DC5% 
   						AND DC5.DC5_SERVIC = SDB.DB_SERVIC
   						AND DC5.DC5_TAREFA =  SDB.DB_TAREFA 
   						AND DC5.%NotDel%
 						INNER JOIN %Table:SX5% SX5
   						ON SX5.X5_filial = %xFilial:SX5%
   						AND SX5.X5_TABELA  = 'L6' 
   						AND SX5.X5_DESCRI = 'DLConfSai()'
   						AND SX5.X5_CHAVE = DC5.DC5_FUNEXE
						AND SX5.%NotDel%
						WHERE SDB.DB_FILIAL  =  %xFilial:SDB% 
						AND SDB.DB_SERVIC = %Exp:SDB->DB_SERVIC%
						AND SDB.DB_PRODUTO = %Exp:SDB->DB_PRODUTO%
						AND SDB.DB_LOTECTL  = %Exp:cLoteOri%
    					AND SDB.DB_ESTORNO = ' '
						AND SDB.DB_ATUEST  = 'N'
					    AND SDB.DB_IDDCF  IN  (SELECT DISTINCT DCR_IDDCF
                       							FROM %Table:DCR% DCR
                       							WHERE DCR.DCR_FILIAL = %xFilial:DCR%
												AND DCR.DCR_IDORI = %Exp:SDB->DB_IDDCF%
                       							AND DCR.DCR_IDMOV = %Exp:SDB->DB_IDMOVTO%
					                            AND DCR.DCR_IDOPER = %Exp:SDB->DB_IDOPERA%
                       							AND DCR.%NotDel%) 
						AND SDB.%NotDEl%
					ENDSQL
					Do While (cAliasCF)->(!Eof())
						SDB->(DbGoTo((cAliasCF)->RECNOSDB))				
						If (QtdComp((cAliasCF)->DB_QUANT) <= QtdComp(nQtdMov)) .And. QtdComp(nQtdMov) > 0
							//Faz uma busca pelo lote destino 
							cAliasSLT := GetNextAlias()	
				    		BeginSql Alias cAliasSLT
								SELECT  SDB.R_E_C_N_O_ as RECNOSDB,
								        SDB.DB_IDDCF,
										SDB.DB_PRODUTO,
										SDB.DB_IDOPERA,
										SDB.DB_IDMOVTO	
  								FROM %Table:SDB% SDB
  								INNER JOIN %Table:DC5% DC5
   								ON DC5.DC5_FILIAL = %xFilial:DC5% 
   								AND DC5.DC5_SERVIC = SDB.DB_SERVIC
   								AND DC5.DC5_TAREFA =  SDB.DB_TAREFA 
   								AND DC5.%NotDel%
 								INNER JOIN %Table:SX5% SX5
   								ON SX5.X5_filial = %xFilial:SX5%
   								AND SX5.X5_TABELA  = 'L6' 
   								AND SX5.X5_DESCRI = 'DLConfSai()'
   								AND SX5.X5_CHAVE = DC5.DC5_FUNEXE
								AND SX5.%NotDel%
								WHERE SDB.DB_FILIAL  =  %xFilial:SDB% 
								AND SDB.DB_SERVIC = %Exp:SDB->DB_SERVIC%
								AND SDB.DB_DOC = %Exp:SDB->DB_DOC%
  								AND SDB.DB_SERIE = %Exp:SDB->DB_SERIE%
  								AND SDB.DB_CLIFOR = %Exp:SDB->DB_CLIFOR%
  								AND SDB.DB_LOJA = %Exp:SDB->DB_LOJA%
  								AND SDB.DB_PRODUTO = %Exp:SDB->DB_PRODUTO%
								AND SDB.DB_LOTECTL  = %Exp:cLoteCtl%
    							AND SDB.DB_ESTORNO = ' '
								AND SDB.DB_ATUEST  = 'N'
    							AND SDB.DB_IDDCF = %Exp:SDB->DB_IDDCF% 
								AND SDB.%NOtDEl%
    						ENDSQL
							If (cAliasSLT)->(!Eof())
								//se existe o lote desitno
								SDB->(DbGoTo((CAliasSLT)->RECNOSDB))
								RecLock("SDB",.F.)
								SDB->DB_QUANT += nQtdMov
								SDB->(MsUnlock())

								//atualizar a quantidade  na DCR 
								cAliasDCR := GetNextAlias()	
				    			BeginSql Alias cAliasDCR
									SELECT  DCR.R_E_C_N_O_ as RECNODCR,
									 		DCR.DCR_QUANT
  									FROM %Table:DCR% DCR
  									WHERE DCR.DCR_FILIAL = %xFilial:DCR% 
   									AND DCR.DCR_IDDCF = %Exp:(cAliasSLT)->DB_IDDCF%
									AND DCR.DCR_IDORI = %Exp:(cAliasSLT)->DB_IDDCF%
   									AND DCR.DCR_IDMOV = %Exp:(cAliasSLT)->DB_IDMOVTO%
									AND DCR.DCR_IDOPER = %Exp:(cAliasSLT)->DB_IDOPERA%
									AND DCR.%NOtDEl%
								ENDSQL
								If (cAliasDCR)->(!Eof())
									nQuant2UM := ConvUm((cAliasSLT)->DB_Produto,((cAliasDCR)->DCR_QUANT + nQtdMov),0,2)
									DCR->(DbGoTo((cAliasDCR)->RECNODCR))
									RecLock("DCR",.F.)
									DCR->DCR_QUANT += nQtdMov
									DCR->DCR_QTSEUM := nQuant2UM
									DCR->(MsUnlock())
								ENDIF
								(cAliasDCR)->(dbCloseArea()) 

								//Para o registro que irá excluir terá que excluir o relacionado na DCR também
								cAliasDCR := GetNextAlias()	
				    			BeginSql Alias cAliasDCR
									SELECT  DCR.R_E_C_N_O_ as RECNODCR
  									FROM %Table:DCR% DCR
  									WHERE DCR.DCR_FILIAL = %xFilial:DCR% 
   									AND DCR.DCR_IDDCF = %Exp:(cAliasCF)->DB_IDDCF%
									AND DCR.DCR_IDORI = %Exp:(cAliasCF)->DB_IDDCF%
   									AND DCR.DCR_IDMOV = %Exp:(cAliasCF)->DB_IDMOVTO%
									AND DCR.DCR_IDOPER = %Exp:(cAliasCF)->DB_IDOPERA%
									AND DCR.%NOtDEl%
								ENDSQL
								If (cAliasDCR)->(!Eof())
									DCR->(DbGoTo((cAliasCF)->RECNODCR))
									RecLock("DCR",.F.)
									DCR->(DbDelete())
									DCR->(MsUnlock())
								ENDIF
								(cAliasDCR)->(dbCloseArea()) 

								SDB->(DbGoTo((cAliasCF)->RECNOSDB))
								RecLock("SDB",.F.)
								SDB->(DbDelete())
								SDB->(MsUnlock())
							Else
								SDB->(DbGoTo((cAliasCF)->RECNOSDB))
								RecLock("SDB",.F.)
								SDB->DB_LOTECTL := cLoteCtl
								SDB->(MsUnlock())
							Endif 
							nQtdMov := nQtdMov - (cAliasCF)->DB_QUANT
							(CAliasSLT)->(dbCloseArea()) 
						ELSE
						    //se nao e igual e maior
							SDB->(DbGoTo((cAliasCF)->RECNOSDB))
							RecLock("SDB",.F.)
							SDB->DB_QUANT -= nQtdMov
							SDB->(MsUnlock())

							//atualizar a quantidade  na DCR 
							cAliasDCR := GetNextAlias()	
				    		BeginSql Alias cAliasDCR
								SELECT  DCR.R_E_C_N_O_ as RECNODCR,
								 		DCR.DCR_QUANT
  								FROM %Table:DCR% DCR
  								WHERE DCR.DCR_FILIAL = %xFilial:DCR% 
   								AND DCR.DCR_IDDCF = %Exp:(cAliasCF)->DB_IDDCF%
								AND DCR.DCR_IDORI = %Exp:(cAliasCF)->DB_IDDCF%
   								AND DCR.DCR_IDMOV = %Exp:(cAliasCF)->DB_IDMOVTO%
								AND DCR.DCR_IDOPER = %Exp:(cAliasCF)->DB_IDOPERA%
								AND DCR.%NOtDEl%
							ENDSQL
							If (cAliasDCR)->(!Eof())
								nQuant2UM := ConvUm((cAliasCF)->DB_Produto,((cAliasDCR)->DCR_QUANT - nQtdMov),0,2)
								DCR->(DbGoTo((cAliasDCR)->RECNODCR))
								RecLock("DCR",.F.)
								DCR->DCR_QUANT -= nQtdMov
								DCR->DCR_QTSEUM := nQuant2UM
								DCR->(MsUnlock())
							ENDIF
							(cAliasDCR)->(dbCloseArea()) 

							//Faz uma busca pelo lote destino 
							cAliasSLT := GetNextAlias()	
				    		BeginSql Alias cAliasSLT
								SELECT  SDB.R_E_C_N_O_ as RECNOSDB,
										SDB.DB_IDDCF,
										SDB.DB_PRODUTO,
										SDB.DB_IDOPERA,
										SDB.DB_IDMOVTO	
  								FROM %Table:SDB% SDB
  								INNER JOIN %Table:DC5% DC5
   								ON DC5.DC5_FILIAL = %xFilial:DC5% 
   								AND DC5.DC5_SERVIC = SDB.DB_SERVIC
   								AND DC5.DC5_TAREFA =  SDB.DB_TAREFA 
   								AND DC5.%NotDel%
 								INNER JOIN %Table:SX5% SX5
   								ON SX5.X5_filial = %xFilial:SX5%
   								AND SX5.X5_TABELA  = 'L6' 
   								AND SX5.X5_DESCRI = 'DLConfSai()'
   								AND SX5.X5_CHAVE = DC5.DC5_FUNEXE
								AND SX5.%NotDel%
								WHERE SDB.DB_FILIAL  =  %xFilial:SDB% 
								AND SDB.DB_SERVIC = %Exp:SDB->DB_SERVIC%
								AND SDB.DB_DOC = %Exp:SDB->DB_DOC%
  								AND SDB.DB_SERIE = %Exp:SDB->DB_SERIE%
  								AND SDB.DB_CLIFOR = %Exp:SDB->DB_CLIFOR%
  								AND SDB.DB_LOJA = %Exp:SDB->DB_LOJA%
  								AND SDB.DB_PRODUTO = %Exp:SDB->DB_PRODUTO%
								AND SDB.DB_LOTECTL  = %Exp:cLoteCtl%
    							AND SDB.DB_ESTORNO = ' '
								AND SDB.DB_ATUEST  = 'N'
    							AND SDB.DB_IDDCF = %Exp:SDB->DB_IDDCF% 
								AND SDB.%NOtDEl%
    						ENDSQL
							If (cAliasSLT)->(!Eof())
								//se existe o lote desitno
								SDB->(DbGoTo((CAliasSLT)->RECNOSDB))
								RecLock("SDB",.F.)
								SDB->DB_QUANT += nQtdMov
								SDB->(MsUnlock())

								//atualizar a quantidade  na DCR 
								cAliasDCR := GetNextAlias()	
				    			BeginSql Alias cAliasDCR
									SELECT  DCR.R_E_C_N_O_ as RECNODCR,
									 		DCR.DCR_QUANT
  									FROM %Table:DCR% DCR
  									WHERE DCR.DCR_FILIAL = %xFilial:DCR% 
   									AND DCR.DCR_IDDCF = %Exp:(cAliasSLT)->DB_IDDCF%
									AND DCR.DCR_IDORI = %Exp:(cAliasSLT)->DB_IDDCF%
   									AND DCR.DCR_IDMOV = %Exp:(cAliasSLT)->DB_IDMOVTO%
									AND DCR.DCR_IDOPER = %Exp:(cAliasSLT)->DB_IDOPERA%
									AND DCR.%NOtDEl%
								ENDSQL
								If (cAliasDCR)->(!Eof())
									nQuant2UM := ConvUm((cAliasSLT)->DB_Produto,((cAliasDCR)->DCR_QUANT + nQtdMov),0,2)
									DCR->(DbGoTo((cAliasDCR)->RECNODCR))
									RecLock("DCR",.F.)
									DCR->DCR_QUANT += nQtdMov
									DCR->DCR_QTSEUM := nQuant2UM
									DCR->(MsUnlock())
								ENDIF
								(cAliasDCR)->(dbCloseArea()) 
							Else
								//SE não existe criar um novo registro.
								cIdMovto := WMSProxSeq("MV_WMSSEQ","DB_IDMOVTO")
								cNumIDOper := GetSx8Num('SDB','DB_IDOPERA'); ConfirmSX8()
								aDadosAlt := {}
								aAdd(aDadosAlt,{"DB_QUANT",nQtdMov})
								aAdd(aDadosAlt,{"DB_LOTECTL",cLoteCtl})
								aAdd(aDadosAlt,{"DB_IDMOVTO",cIdMovto})
								aAdd(aDadosAlt,{"DB_IDOPERA",cNumIDOper})
								nNovoRecno := WmsCopy("SDB", aDadosAlt)

								nQuant2UM := ConvUm((cAliasCF)->DB_Produto,nQtdMov,0,2)

								Reclock('DCR', .T.)
                            	DCR->DCR_FILIAL := xFilial('DCR')
                            	DCR->DCR_IDORI  := (cAliasCF)->DB_IDDCF
                            	DCR->DCR_IDDCF  := (cAliasCF)->DB_IDDCF
                            	DCR->DCR_IDMOV  := cIdMovto
                            	DCR->DCR_IDOPER := cNumIDOper
                            	DCR->DCR_QUANT  := nQtdMov
                            	DCR->DCR_QTSEUM := nQuant2UM
								DCR->( MsUnlock())
							EndIf
							(CAliasSLT)->(dbCloseArea())
						EndIf
						(cAliasCf)->(DbSkip())
					EndDO
					(CAliasCF)->(dbCloseArea())
					cLoteOri := cLoteCtl 
				Else
					DLVTAviso("DLGV03028",STR0012+AllTrim(cLoteCtl)+STR0040) //"Lote "###" sem saldo disponível."
					VTKeyBoard(chr(20))
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSDB)
Return(lRet)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV30VlSLt³ Autor ³ VICCO                 ³ Data ³01.12.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Sub-Lote digitado na conferencia pertence ao ³±±
±±³          ³ Sub-lote do documento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nr. do Sub-Lote digitado                           ³±±
±±³          ³ ExpA1 - Nr. de Sub-Lote do documento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlV30VlSLt(cSubLote,cSubLoteOri)
Local lRet := .T.
If Empty(cSubLote)
	lRet := .F.
Else
	If cSubLote <> cSubLoteOri
		DLVTAviso("DLGV03025",STR0034+AllTrim(cSubLote)+STR0020) //'Sub-Lote '###' nao consta no documento atual.'
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
EndIf
Return(lRet)

//------------------------------------------------------------------------------
// Efetua a validação e permite efetuar a alteração da quantidade movimentada
// tanto para maior como para menor. Atualiza liberação do pedido, ordem de serviço
// movimentação de estoque atual e da tarefa de conferência caso exista
//------------------------------------------------------------------------------
Static Function AlteraQtd(lQtdMaior,cWmsUMI,nQuant)
Local lWMSQMSEF := ExistBlock("WMSQMSEF")
Local lWMSQMSEG := ExistBlock("WMSQMSEG")
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local aAreaDCF  := DCF->(GetArea())
Local lRet      := .T.
Local nPerToler := SuperGetMV('MV_WMSQSEP',.F., 0 ) / 100 //-- Permite Qtde a maior Separac. / Reabast. RF
Local nQtdToler := 0
Local nQtdMaior := 0
Local nPerTolPE := 0
Local nSaldoSBF := 0
Local nQtdOrig  := 0
Local nQtdMvto  := 0
Local lRetPE    := Nil

Default nQuant  := 0

	If DLAtivAglt(SDB->DB_IDDCF,SDB->DB_IDMOVTO,SDB->DB_IDOPERA)
		DLVTAviso("DLGV03011",STR0055) //"Atividade está aglutinada, não permite separar quantidade diferente da solicitada."
		lRet := .F.
	EndIf

	If lRet .And. !WmsChkDCF(SDB->DB_ORIGEM,SDB->DB_CARGA,,SDB->DB_SERVIC,'3',,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_LOCAL,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,SDB->DB_IDDCF)
		DLVTAviso("DLGV03012",STR0062) //"Não foi possível encontrar a ordem de serviço da movimentação."
		lRet := .F.
	EndIf

	If lRet .And. lWMSQMSEG //Ponto de entrada criado para testar tolerãncia para separação a menor
		lRetPE := ExecBlock("WMSQMSEG",.F.,.F.,{nQuant, lQtdMaior})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf

	// Permite configurar um percentual de tolerância para separação a maior
	If lRet .And. lWMSQMSEF
		nPerTolPE := ExecBlock("WMSQMSEF",.F.,.F.)
		If ValType(nPerTolPE) == "N"
			nPerToler := nPerTolPE / 100
		EndIf
	EndIf

	If lRet .And. lQtdMaior
		If DCF->(FieldPos("DCF_QTDORI")) > 0 .And. DCF->DCF_QTDORI > 0
			nQtdToler := DCF->DCF_QTDORI * nPerToler
			nQtdMaior := DCF->DCF_QUANT - DCF->DCF_QTDORI
		Else
			nQtdToler := DCF->DCF_QUANT*nPerToler
		EndIf

		If QtdComp(nQtdMaior+nQuant) > QtdComp(nQtdToler)
			DLVTAviso("DLGV03013",STR0063) //"Total ultrapassa a quantidade de tolerância a maior para a ordem de serviço."
			lRet := .F.
		EndIf

		If lRet
			nSaldoSBF := WmsSaldoSBF(SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,.F.,.T.,.F.,.T.,"1")
			If QtdComp(nQuant) > QtdComp(nSaldoSBF)
				DLVTAviso("DLGV03014",WmsFmtMsg(STR0064,{{"[VAR01]",Str(nSaldoSBF)}})) //"Endereço não possui saldo de estoque suficiente. Saldo disponível: [VAR01]"
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		nQtdOrig := SDB->DB_QUANT
		nQtdMvto := Iif(lQtdMaior,SDB->DB_QUANT+nQuant,SDB->DB_QTDLID)
		DLVTCabec(cCadastro, .F., .F., .T.)
		@ 01, 00 VTSay PadR(STR0010, VTMaxCol()) //"Quantidade"
		@ 02, 00 VTSay PadR(STR0036, VTMaxCol()) //"Total"
		If cWmsUMI == "2"
			@ 03, 00 VTSay PadR(Transform(ConvUm(SDB->DB_PRODUTO,nQtdOrig,0,2),PesqPict("SDB","DB_QTSEGUM")), VTMaxCol())
			@ 04, 00 VTSay PadR(STR0037, VTMaxCol()) //"Separada"
			@ 05, 00 VTSay PadR(Transform(ConvUm(SDB->DB_PRODUTO,nQtdMvto,0,2),PesqPict("SDB","DB_QTSEGUM")), VTMaxCol())
		Else
			@ 03, 00 VTSay PadR(Transform(nQtdOrig,PesqPict("SDB","DB_QUANT")), VTMaxCol())
			@ 04, 00 VTSay PadR(STR0037, VTMaxCol()) //"Separada"
			@ 05, 00 VTSay PadR(Transform(nQtdMvto,PesqPict("SDB","DB_QUANT")), VTMaxCol())
		EndIf
		DLVTRodaPe()

		If DLVTAviso(cCadastro,Iif(lQtdMaior,STR0041,STR0038),{STR0005,STR0006})==1 //"Separar quantidade superior?"###"Finalizar atividade com quantidade inferior?"###"Sim"###"Nao"
			Begin Transaction
			//-- Atualiza a liberação do pedido de venda
			If DCF->DCF_ORIGEM == "SC9"
				lRet := DLGV030ALP(nQtdOrig,nQtdMvto)
			EndIf
			//-- Atualiza quantidade na ordem de serviço
			If lRet
				RecLock("DCF",.F.)
				If DCF->(FieldPos("DCF_QTDORI")) > 0 .And. DCF->DCF_QTDORI == 0
					DCF->DCF_QTDORI := DCF->DCF_QUANT
				EndIf
				DCF->DCF_QUANT  := DCF->DCF_QUANT + (nQtdMvto-nQtdOrig)
				DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
				//-- Se zerar estorna o registro do DCF
				If QtdComp(DCF->DCF_QUANT) <= QtdComp(0)
					DCF->(DbDelete())
				EndIf
				DCF->(MsUnlock())
			EndIf
			//-- Atualiza movimentação de estoque da tarefa atual
			If lRet
				lRet := DLGV030ASC(.T.,nQtdOrig,nQtdMvto)
			EndIf
			//-- Atualizando, caso exista a atividade de conferência
			If lRet
				lRet := DLGV030ASC(.F.,nQtdOrig,nQtdMvto)
			EndIf
			If !lRet
				DisarmTransaction()
			EndIf
			End Transaction
			If lDV030SEP
				lRetPE := ExecBlock("DV030SEP",.F.,.F.,{nQtdOrig,nQtdMvto})
				If ValType(lRetPE) == "L"
					lRet := lRetPE
				EndIf
			EndIf
			If lRet .And. !lQtdMaior
			   VTKeyBoard(Chr(27)) //-- Tecla ESC
			EndIf
		Else
		   lRet := .F.
		EndIf
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaDCF)
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------------------------
//-- Atualiza liberação do pedido de venda de acordo com a quantidade
//--------------------------------------------------------------------
Function DLGV030ALP(nQtdOrig,nQtdMvto)
Local aAreaAnt  := GetArea()
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local lRet      := .T.
Local nQtAbat   := 0
Local cQuery    := ""
Local cAliasSC9 := ""
Local cAliasSUM := ""
Local aLocaliz  := {}
Local aDlEstC9  := {}
Local lDlEstC9  := .T.
Local lQtdMaior := QtdComp(nQtdOrig) < QtdComp(nQtdMvto)
Local nQuant    := Iif(lQtdMaior,nQtdMvto-nQtdOrig,nQtdOrig-nQtdMvto)
Local lDelSC9   := .F.
	//-- P.E. para manipular o estorno da liberação do pedido
	//O retorno deve ser .T. para que o processo não tome o padrão
	If lDLVESTC9
		aDlEstC9 := ExecBlock("DLVESTC9",.F.,.F.,{lDlEstC9,{SDB->(Recno())},nQtdOrig,nQtdMvto,.F.})
		If ValType(aDlEstC9) == "A" .And. Len(aDlEstC9) >= 2
			lDlEstC9 := aDlEstC9[1]
			lRet     := aDlEstC9[2]
		EndIf
	EndIf
	If lDlEstC9
		//-- Localiza Liberações do Pedido e subtrai a diferença
		cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9 "
		cQuery +=  " FROM "+RetSqlName("SC9")+" SC9 "
		cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=   " AND C9_IDDCF = '"+SDB->DB_IDDCF+"' "
		cQuery +=   " AND C9_BLWMS = '01'"
		cQuery +=   " AND C9_BLEST = '  '"
		cQuery +=   " AND C9_BLCRED = '  '"
		cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSC9  := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
		While (cAliasSC9)->(!Eof()) .And. QtdComp(nQuant) > 0
			SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
			nQtAbat := 0
			If lQtdMaior .OR. QtdComp(SC9->C9_QTDLIB) >= QtdComp(nQuant)
				nQtAbat := nQuant
				nQuant  := 0
			Else
				nQtAbat := SC9->C9_QTDLIB
				nQuant  -= nQtAbat
			EndIf
			//-- Itens Pedidos de Vendas
			SC6->(DbSetOrder(1))
			SC6->(MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))

			//-- 2.Estorno do SC9 / Estorno da Liberacao de 6.Estoque/4.Credito do SC9 / WMS
			aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
			MaAvalSC9("SC9",2,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
			//-- Atualiza quantidade liberada
			RecLock("SC9",.F.)
			SC9->C9_BLEST   := " "
			SC9->C9_BLCRED  := " "
			SC9->C9_QTDLIB  := Iif(lQtdMaior,(SC9->C9_QTDLIB + nQtAbat),(SC9->C9_QTDLIB - nQtAbat))
			SC9->C9_QTDLIB2 := ConvUm(SC9->C9_PRODUTO,SC9->C9_QTDLIB,0,2)
			If QtdComp(SC9->C9_QTDLIB) <= 0
				lDelSC9 := .T.
				SC9->(DbDelete())
			EndIf
			SC9->(MsUnlock())
			SC9->(DbCommit()) //-- Força enviar para o banco a atualização da SC9
			RecLock("SC6",.F.)
			//-- Atualiza item do pedido de venda
			SC6->C6_QTDLIB  := SC9->C9_QTDLIB
			SC6->C6_QTDLIB2 := SC9->C9_QTDLIB2
			If lQtdMaior
				//-- Deve calcular tudo o que já possui liberado do pedido de venda
				cQuery := "SELECT SUM(C9_QTDLIB) SUM_QTDLIB "
				cQuery +=  " FROM "+RetSqlName("SC9")+" SC9 "
				cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
				cQuery +=   " AND C9_PEDIDO = '"+SC9->C9_PEDIDO+"' "
				cQuery +=   " AND C9_ITEM   = '"+SC9->C9_ITEM+"'"
				cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasSUM  := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSUM,.F.,.T.)
				If QtdComp((cAliasSUM)->SUM_QTDLIB) > QtdComp(SC6->C6_QTDVEN)
					SC6->C6_QTDVEN := (cAliasSUM)->SUM_QTDLIB
					SC6->C6_UNSVEN := ConvUM(SC6->C6_PRODUTO,SC6->C6_QTDVEN,0,2)
					SC6->C6_VALOR  := A410Arred(SC6->C6_QTDVEN * SC6->C6_PRCVEN,"C6_VALOR")
				EndIf
				(cAliasSUM)->(DbCloseArea())
			EndIf
			SC6->(MsUnlock())
			//-- Atualiza Credito
			If !lDelSC9
				aLocaliz := {{ "","","","",SC9->C9_QTDLIB,,Ctod(""),"","","",SC9->C9_LOCAL,0}}
				MaAvalSC9("SC9",1,aLocaliz,Nil,Nil,Nil,Nil,Nil,Nil,,.F.,,.F.)
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
		(cAliasSC9)->(DbCloseArea())
	EndIf
	RestArea(aAreaSB2)
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------------------------
//-- Atualiza os movimentos de estoque de acordo com a quantidade
//--------------------------------------------------------------------
Function DLGV030ASC(lTarAtual,nQtdOrig,nQtdMvto)
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSDB := GetNextAlias()

	cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery += " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_DOC     = '"+SDB->DB_DOC+"'"
	cQuery +=   " AND DB_SERIE   = '"+SDB->DB_SERIE+"'"
	cQuery +=   " AND DB_CLIFOR  = '"+SDB->DB_CLIFOR+"'"
	cQuery +=   " AND DB_LOJA    = '"+SDB->DB_LOJA+"'"
	cQuery +=   " AND DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
	cQuery +=   " AND DB_LOTECTL = '"+SDB->DB_LOTECTL+"'"
	cQuery +=   " AND DB_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
	cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
	If lTarAtual
		cQuery += " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
		cQuery += " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
		cQuery += " AND DB_IDMOVTO = '"+SDB->DB_IDMOVTO+"'"
	Else
		cQuery += " AND DB_ORDTARE > '"+SDB->DB_ORDTARE+"'"
	EndIf
	cQuery +=   " AND DB_IDDCF   = '"+SDB->DB_IDDCF+"'"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	cAliasSDB := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
	//-- Subtrai quantidade cortada do SDB
	While (cAliasSDB)->(!Eof())
		SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
		RecLock("SDB",.F.)
		If SDB->(FieldPos("DB_QTDORI")) > 0 .And. SDB->DB_QTDORI == 0
			SDB->DB_QTDORI := SDB->DB_QUANT
		EndIf
		SDB->DB_QUANT   := SDB->DB_QUANT + (nQtdMvto-nQtdOrig)
		SDB->DB_QTSEGUM := ConvUm(SDB->DB_PRODUTO,SDB->DB_QUANT,0,2)
		//-- Se zerar estorna o registro do SDB
		If QtdComp(SDB->DB_QUANT) <= QtdComp(0)
			SDB->DB_ESTORNO := "S"
			SDB->DB_STATUS  := cStatExec
		EndIf
		SDB->(MsUnlock())
		WmsAtzDCR(SDB->DB_IDDCF,SDB->DB_IDMOVTO,SDB->DB_IDOPERA,SDB->DB_QUANT,SDB->DB_QTSEGUM)
		(cAliasSDB)->(DbSkip())
	EndDo
	(cAliasSDB)->(DbCloseArea())
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV30Lote  | Autor ³ Flavio Luiz Vicco        ³Data³16.12.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Permite selecionar lotes a separar do mesmo endereco.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlV30Lote(cLoteCtl,cLoteOri,nQtdTot,nItem,cUM,nProxLin)
Local aAreaSDB  := SDB->(GetArea())
Local nTipoConv := SuperGetMV('MV_TPCONVO',.F., 1 ) //-- 1=Por Atividade/2=Por Tarefa
Local nRecSDB   := SDB->(RecNo())
Local cUM1      := Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO,"B1_UM")
Local aLotes    := {{SDB->DB_LOTECTL,SDB->DB_QUANT,cUM1,nRecSDB}}
Local aCab      := {STR0012,STR0048,STR0067} //"Lote"###"Quant."
Local aSize     := {TamSx3("DB_LOTECTL")[1],TamSx3("DB_QUANT")[1],TamSx3("B1_UM")[1]}
Local aTela     := VtSave()
Local dDataFec  := DToS(WmsData())
Local lRet      := .T.
Local nPos      := 0
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lTrocouLt := .F.
Local lTrocouQt := .F.
Local nQtdNorma := DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTFIS,,.F.)

	cQuery := " SELECT SDB.DB_LOTECTL, SDB.R_E_C_N_O_ SDBRECNO"
	cQuery +=   " FROM " + RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_SERVIC   = '"+SDB->DB_SERVIC+"'"
	cQuery +=   " AND DB_DOC      = '"+SDB->DB_DOC+"'"
	cQuery +=   " AND DB_SERIE    = '"+SDB->DB_SERIE+"'"
	cQuery +=   " AND DB_PRODUTO  = '"+SDB->DB_PRODUTO+"'"
	cQuery +=   " AND DB_LOCALIZ  = '"+SDB->DB_LOCALIZ+"'"
	cQuery +=   " AND DB_TAREFA   = '"+SDB->DB_TAREFA +"'"
	cQuery +=   " AND DB_ATIVID   = '"+SDB->DB_ATIVID +"'"
	cQuery +=   " AND DB_ORDATIV  = '"+SDB->DB_ORDATIV+"'"
	cQuery +=   " AND DB_RHFUNC   = '"+SDB->DB_RHFUNC +"'"
	cQuery +=   " AND DB_RECFIS   = '"+SDB->DB_RECFIS +"'"
	cQuery +=   " AND (DB_RECHUM = ' ' OR DB_RECHUM = '"+__cUserID+"')"
	cQuery +=   " AND DB_TIPO     = 'E'"
	cQuery +=   " AND DB_ATUEST   = 'N'"
	cQuery +=   " AND DB_ESTORNO  = ' '"
	cQuery +=   " AND DB_STATUS   = '"+cStatAExe+"'"
	cQuery +=   " AND SDB.R_E_C_N_O_ <> "+AllTrim(Str(nRecSDB))
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SDB.DB_LOTECTL"
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		//-- Posicionar no registro do SDB
		SDB->(DbGoTo((cAliasQry)->SDBRECNO))
		//-- Somente se nao for a ultima atividade
		If DLVExecAnt(nTipoConv,dDataFec,__cUserID)
			AAdd(aLotes,{SDB->DB_LOTECTL,SDB->DB_QUANT,cUM1,SDB->(RecNo())})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	VTClear()
	DLVTCabec(STR0049,.F.,.F.,.T.) //"Lotes a separar"
	nPos := VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aLotes,aSize)
	VtRestore(,,,,aTela)
	//-- Trocar lote selecionado.
	If nPos > 0
		//-- Trocar atividade
		If nRecSDB<>aLotes[nPos,4]
			Begin Transaction
				//-- Posicionar no registro do SDB
				SDB->(DbGoTo(nRecSDB))
				RecLock("SDB",.F.)
				SDB->DB_STATUS := cStatAExe
				//SDB->DB_RECHUM := " "
				SDB->DB_HRINI  := " "
				//-- Liberar o registro do arquivo SDB
				SDB->(MsUnlock())
				lTrocouLt := (aLotes[nPos,1] != SDB->DB_LOTECTL)
				lTrocouQt := (aLotes[nPos,2] != SDB->DB_QUANT)
				//P.E. para manipular o status da SDB
				If lDV030SDB
					Execblock("DV030SDB",.F.,.F.,{lCtrlFOk})
				EndIf
				//-- Posicionar no registro do SDB
				SDB->(DbGoTo(aLotes[nPos,4]))
				If SDB->(SimpleLock())
					RecLock("SDB",.F.)
					SDB->DB_STATUS := cStatInte
					SDB->DB_RECHUM := __cUserID
					SDB->DB_DATA   := dDataBase
					SDB->DB_HRINI  := Time()
					SDB->(MsUnlock())
					//P.E. para manipular o status da SDB
					If lDV030SDB
						Execblock("DV030SDB",.F.,.F.,{lCtrlFOk})
					EndIf
					cLoteOri := aLotes[nPos,1]
					nQtdTot  := aLotes[nPos,2]
					aAreaSDB := SDB->(GetArea())
					If lTrocouLt
						DLVTAviso("DLGV03026",STR0044) //Numero do lote alterado.
					ElseIf lTrocouQt
						DLVTAviso("DLGV03026",STR0058) //Quantidade para separação alterada.
					EndIf
					// Deve atualizar o campo quantidade em tela, para que o usuário separe a quantidade correta
					//Converter para U.M.I.
					If nItem == 1
						nQtdNorma:= DLQtdNorma(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTFIS,,.F.)
						nQtdTot := (nQtdTot/nQtdNorma)
					//Converter para 2a.UM
					ElseIf nItem == 2
						nQtdTot := ConvUm(SDB->DB_PRODUTO,nQtdTot,0,2)
					//1a.UM
					EndIf
					@ nProxLin-2, 00 VTSay PadR(STR0019+' '+AllTrim(Str(nQtdTot))+' '+cUM, VTMaxCol()) //Qtd 240.00 UN
				Else
					DisarmTransaction()
					DLVTAviso("DLGV03027",STR0045) //"Nao foi possivel efetuar a alteracao."
					lRet := .F.
				EndIf
			End Transaction
		EndIf
	Else
		lRet := .F.
	EndIf

RestArea(aAreaSDB)
Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} DLV030ESC
Valida saida com ESC

@author  Alexsander Burigo Corrêa
@version P11
@since   30/08/13
@obs     Valida saida com ESC
/*/
//----------------------------------------------------------
Static Function DLV030ESC(lForcaEnc)
Local lRFEndDe  := SuperGetMV('MV_RFENDDE',.F.,.F.)
Local lSaida    := .F.
Local aOpcoes   := {}
Local nOpcao    := 0
Local lPulaAtiv := DLVPulaAti()
Default lForcaEnc := .F.

	DLVOpcESC(0)
	// Se permite selecionar mais de uma atividade
	If (lRFEndDe .Or. nWmsMTea == 1 .Or. nWmsMTea == 3) .And. !lForcaEnc
		// Se possui mais de uma atividade no aColetor, ou se a primeira é diferente do SDB atual
		If Len(aConfEnd) > 0 .Or. Len(aColetor) > 1 .Or. (Len(aColetor) == 1 .And. aColetor[1,1] != SDB->(Recno()))
			If lPulaAtiv
				aOpcoes := {STR0052,STR0027,STR0051} //"Endereco Destino"#"Pular Atividade"#"Bloquear Atividade"
			Else
				aOpcoes := {STR0052,STR0051} //"Endereco Destino"#"Bloquear Atividade"
			EndIf
			nOpcao := DLVTAviso(cCadastro,STR0050,aOpcoes) //Opcoes -- 'Atencao!'
			// Tratativa para quando o "Pular atividade" não estiver parametrizado,
			// assim o sistema executará sempre a ação correta
			nOpcao := Iif(!lPulaAtiv .And. nOpcao == 2, 3, nOpcao)
			If nOpcao == 1
				DLVEndDes(.T.) // Libera Atividade Atual e Envia Anteriores para Doca
			ElseIf nOpcao == 2
				DLVOpcESC(3) // Pular Atividade Atual
			ElseIf nOpcao == 3
				aOpcoes := {STR0060,STR0061} //"Atividade Atual"#"Todas Atividades"
				nOpcao := DLVTAviso(cCadastro,STR0059,aOpcoes) //Opcoes -- "Atencao! Escolha o tipo de bloqueio:"
				If nOpcao == 1
					DLVOpcESC(2) // Bloqueia Atividade Atual
				ElseIf nOpcao == 2
					DLVOpcESC(1) // Bloqueia Todas Atividades
				EndIf
			EndIf
		Else
			lSaida := .T.
		EndIf
	Else
		lSaida := .T.
	EndIf

	If lSaida
		If lPulaAtiv .And. !lForcaEnc
			aOpcoes := {STR0027,STR0051} //"Pular Atividade"#"Bloquear Atividade"
			nOpcao := DLVTAviso(cCadastro,STR0050,aOpcoes) //Opcoes -- 'Atencao!'
			If nOpcao == 1
				DLVOpcESC(3) // Pular Atividade Atual
			ElseIf nOpcao == 2
				DLVOpcESC(2) // Bloquear Atividade Atual
			EndIf
		Else
			If DLVTAviso(cCadastro,STR0004+cCadastro+'?', {STR0005,STR0006}) == 1 //'Deseja encerrar o '###'Sim'###'Nao'
				DLVOpcESC(2) // Bloquear Atividade Atual
			EndIf
		EndIf
	EndIf
Return (Nil)

//-----------------------------------------------------------------------------
// Verifica se existe a atividade de conferência para o processo de saída
//-----------------------------------------------------------------------------
Static Function HasConfSai()
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

   cQuery := "SELECT DISTINCT 1"
   cQuery +=  " FROM "+RetSqlName("SDB")
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery +=   " AND DB_ESTORNO = ' '"
   cQuery +=   " AND DB_ATUEST  = 'N'"
   cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
   cQuery +=   " AND DB_ORDTARE > '"+SDB->DB_ORDTARE+"'"
   cQuery +=   " AND DB_TAREFA IN (SELECT DC5.DC5_TAREFA"
   cQuery +=                       " FROM "+RetSqlName("SX5")+" SX5, "+RetSqlName("DC5")+" DC5"
   cQuery +=                      " WHERE X5_FILIAL  = '"+xFilial("SX5")+"' "
   cQuery +=                        " AND X5_TABELA  = 'L6' AND X5_DESCRI = 'DLConfSai()'"
   cQuery +=                        " AND DC5_FILIAL = '"+xFilial("DC5")+"'"
   cQuery +=                        " AND DC5_SERVIC = '"+SDB->DB_SERVIC+"'"
   cQuery +=                        " AND DC5_ORDEM  > '"+SDB->DB_ORDTARE+"'"
   cQuery +=                        " AND X5_CHAVE   = DC5_FUNEXE"
   cQuery +=                        " AND DC5.D_E_L_E_T_ = ' '"
   cQuery +=                        " AND SX5.D_E_L_E_T_ = ' ')"
   If WmsCarga(SDB->DB_CARGA)
      cQuery += " AND DB_CARGA = '"+SDB->DB_CARGA+"'"
   Else
      cQuery += " AND DB_DOC   = '"+SDB->DB_DOC+"'"
   EndIf
   cQuery += " AND DB_STATUS IN ('"+cStatInte+"','"+cStatProb+"','"+cStatAExe+"')"
   cQuery += " AND D_E_L_E_T_  = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
   lRet := (cAliasQry)->(!Eof())
   (cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet
