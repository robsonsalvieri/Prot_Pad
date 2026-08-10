#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'DLGV080.CH'
#INCLUDE 'APVT100.CH'

// Versão simplificada das telas de endereçamento no coletor RF
Static __lVerSimp  := SuperGetMv('MV_WMSVSTE',.F.,.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DLGV080 ³ Autor ³ Fernando Joly Siquini  ³ Data ³25.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recebimento de mercadorias c/Separacao p/NF                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLGV080()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static lDV080INI := ExistBlock("DV080INI") //-- Executado antes do inicio da atividade, permite validação
Static lDV080ENO := ExistBlock("DV080ENO") //-- Executado para definir o endereço origem
Static lDV080ORI := ExistBlock("DV080ORI") //-- Executado após informado o endereço origem, válido ou não
Static lDV080END := ExistBlock("DV080END") //-- Executado para definir o endereço destino
Static lDLV080VL := ExistBlock("DLV080VL") //-- Executado para efetuar as validações dos campos endereço/unitizador
Static lDV080SCR := ExistBlock("DV080SCR") //-- Executado após a montagem da tela que exibe o produto para o usuário
Static lDV080SED := ExistBlock("DV080SED") //-- Executado para suprimir o envio para o destino e todo o processo de finalização
Static lDV080DST := ExistBlock("DV080DST") //-- Executado para substituir a tela padrão de endereço destino
Static lDV080OPC := ExistBlock("DV080OPC") //-- Executado para substituir a tela de troca de endereço
Static lDV080DES := ExistBlock("DV080DES") //-- Executado após a movimentação de estoque e finalização da atividade
Static lDV080EST := ExistBlock("DV080EST") //-- Executado para indicar se deve ou não movimentar estoque
Static lDV080QTD := ExistBlock("DV080QTD") //-- Executado para validar a quantidade informada para endereçamento
Static lDVATUEST := ExistBlock("DLGV080END") //-- Executado para indicar se deve ou não movimentar estoque - Não utilizar mais

Function DLGV080()

Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local aSavKey   := VTKeys() //-- Salva todas as teclas de atalho anteriores
Local cArmazem  := ''
Local cEndereco := ''
Local cConfirma := ''
Local cUnitiza  := ''
Local cDscAtv   := ''
Local lRet      := .T.
Local lRetPE    := .T.
Local cRetPE    := ''
//-- 0=Permanece como antes ate a proxima versao
Local cWmsUMI   := AllTrim(SuperGetMv('MV_WMSUMI',.F.,'0'))
Local nQtdTot   := 0
Local lTelaDes  := .T.
Local lMultAtiv := .F. //-- Parametro MV_WMSMTEA - Multiplas tarefas (atividades)
Local lAtPerMul := .T. //-- Indica se a atividade permite multiplos movimentos

Private cCadastro  := STR0001 //'Enderecamento'
Private lPrimAtiv := DLPrimAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
Private lUltiAtiv := DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)

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
		//-- Atribui a Funcao de ENDERECO a Combinacao de Teclas <CTRL> + <E>
		VTSetKey(5, {|| DLVEndereco(00, 00, cEndereco, cArmazem)},STR0002)   //'Endereco'
		//-- Atribui a Funcao de INFORMACAO DO PRODUTO a Combinacao de Teclas <CTRL> + <I>
		VTSetKey(9, {|| DLG070IPrd()} ,STR0003)   //'Inf.Produto'

		// --- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If cWmsUMI == '4'
			SB5->(DbSetOrder(1))
			SB5->(MsSeek(xFilial('SB5')+SDB->DB_PRODUTO))
			cWmsUMI := SB5->B5_UMIND
		EndIf

		SX5->(DbSetOrder(1))
		If SX5->(MsSeek(xFilial('SX5')+'L2'+SDB->DB_TAREFA))
			cCadastro := AllTrim(SX5->(X5Descri()))
		EndIf
		If SX5->(MsSeek(xFilial('SX5')+'L3'+SDB->DB_ATIVID))
			cDscAtv := Upper(AllTrim(SX5->(X5Descri())))
		EndIf
		//-- Verifica se a atividade nesta ordem permite multiplos movimentos
		If DC6->(FieldPos("DC6_PERMUL")) > 0
			DC6->(DbSetOrder(1)) //-- DC6_FILIAL+DC6_TAREFA+DC6_ORDEM
			DC6->(MsSeek(xFilial('DC6')+SDB->DB_TAREFA+SDB->DB_ORDATIV))
			lAtPerMul := (DC6->DC6_PERMUL != '2')
		EndIf
		//-- Execblock apos a confirmacao do endereco
		If lDV080INI
			lRetPE := ExecBlock('DV080INI', .F., .F., {cConfirma, cEndereco})
			If ValType(lRetPE) == 'L'
				lRet := lRetPE
			EndIf
		EndIf
	EndIf

	//-- Informa o Endereco de Origem
	If lRet
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

		If nQtdTot > 0
			//-- Direciona RH para o Endereco Origem
			cEndereco := SDB->DB_LOCALIZ
			If !lPrimAtiv .And. cDscAtv == 'MOVIMENTO VERTICAL'
				//-- Usa endereco DESTINO se nao eh primeira atividade.
				cEndereco := SDB->DB_ENDDES
			EndIf
			If lDV080ENO
				cRetPE := ExecBlock('DV080ENO', .F., .F.)
				cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
			EndIf

			If !__lVerSimp
				Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
					DLVEndereco(00, 00, cEndereco, cArmazem,,,STR0004) //'Va p/o Endereco'
					If (VTLastKey()==27)
						DLV080ESC()
						Loop
					EndIf
					Exit
				EndDo
			EndIf

			//-- Solicita confirmacao do Endereco de Origem
			Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
				//--  01234567890123456789
				//--0 __Va p/o Endereco___
				//--1
				//--2 Endereco
				//--3 DOCA
				//--4
				//--5 Confirme !
				//--6 DOCA
				//--7
				cConfirma := Space(Len(cEndereco))
				DLVTCabec(STR0004,.F.,.F.,.T.) //'Va p/o Endereco'
				@ 02, 00 VTSay PadR(STR0002, VTMaxCol())  //'Endereco'
				@ 03, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0008, VTMaxCol())  //'Confirme!'
				@ 06, 00 VTGet cConfirma Pict '@!' Valid DLV080Vld(@cConfirma, cEndereco, 1)
				VTRead()
				If (VTLastKey()==27)
					DLV080ESC()
					Loop
				EndIf
				//-- Execblock apos a confirmacao do endereco
				If lDV080ORI
					lRetPE := ExecBlock('DV080ORI', .F., .F., {cConfirma, cEndereco, lRet})
					If ValType(lRetPE) == 'L'
						lRet := lRetPE
					EndIf
				EndIf
				Exit
			EndDo

			 //-- Se não pulou ou bloqueou a atividade, nem escolheu descarregar, processa a atividade
			If lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
				If !Empty(SDB->DB_UNITIZ)
					//-- Informa o unitizador a ser pego
					If !__lVerSimp
						Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
							DLVTCabec(STR0009, .F., .F., .T.)   //'Pegue o Unitizador'
							@ 02, 00 VTSay PadR(cUnitiza:=SDB->DB_UNITIZ, VTMaxCol())
							If (VTLastKey()==27)
								DLV080ESC()
								Loop
							EndIf
							Exit
						EndDo
					EndIf
					//-- Solicita confirmacao do Unitizador
					Do While lRet .And. DLVOpcESC() == 0 .And. !DLVEndDes()
						cConfirma := Space(Len(cUnitiza))
						DLVTCabec(cCadastro,.F.,.F.,.T.)
						@ 02, 00 VTSay PadR(STR0010, VTMaxCol())  //'Unitizador'
						@ 03, 00 VTSay PadR(cUnitiza, VTMaxCol())
						@ 05, 00 VTSay PadR(STR0008, VTMaxCol())  //'Confirme!'
						@ 06, 00 VTGet cConfirma Pict '@!' Valid DLV080Vld(@cConfirma, cUnitiza, 3)
						VTRead
						If (VTLastKey()==27)
							DLV080ESC()
							Loop
						EndIf
						Exit
					EndDo
				Else
					//-- Recalcula a quantidade, pois pode ser que tenha mudado - Não retirar
					If cWmsUMI == '2'
						nQtdTot := SDB->DB_QTSEGUM - ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2)
					Else
						nQtdTot := SDB->DB_QUANT - SDB->DB_QTDLID
					EndIf
					//-- Passa a estrutura fisica destino para calcular a norma com base no destino para endereçamento
					lRet := DlV080UM(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTDES,cWmsUMI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,nQtdTot,.T.,cEndereco)
				EndIf
			EndIf
		Else
			DLVTAviso("DLGV08003",STR0033) //"Quantidade endereçamento já realizada!"
		EndIf

		If lRet
			//-- Se quer bloquear a atividade atual ou todas as outras
			If DLVOpcESC() == 1 .Or. DLVOpcESC() == 2
				RecLock('SDB', .F.)
				SDB->DB_STATUS  := cStatProb
				SDB->DB_DATAFIM := dDataBase
				SDB->DB_HRFIM   := Time()
				MsUnlock()
			//-- Se quer pular apenas esta atividade ou descarregar as outras
			ElseIf DLVOpcESC() == 3 .Or. DLVEndDes()
				RecLock('SDB', .F.)
				If DLVOpcESC() == 3
					DLGVAltPri() //-- Altera a prioridade da atividade atual
				EndIf
				SDB->DB_STATUS := cStatAExe
				MsUnlock()
			EndIf
			//-- Se não pulou ou bloqueou a atividade, nem escolheu descarregar, coloca a mesma na pilha
			If DLVOpcESC() == 0 .And. !DLVEndDes()
				//-- Solicita endereco destino
				cEndereco := SDB->DB_ENDDES
				If lPrimAtiv .And. !lUltiAtiv .And. cDscAtv == 'MOVIMENTO VERTICAL'
					//-- Usa endereco ORIGEM se eh primeira atividade.
					//-- Solicita mesmo endereco, pois trata-se do 1o movto.
					cEndereco := SDB->DB_LOCALIZ
				EndIf
				//-- PE para selecionar endereco destino
				If lDV080END
					cRetPE := ExecBlock("DV080END", .F., .F.)
					cEndereco := Iif(ValType(cRetPE)=="C",cRetPE,cEndereco)
				EndIf

				//-- Grava array com os dados para enderecamento no final
				AAdd(aColetor,{SDB->(Recno()),DtoS(dDataBase)+Time(),SDB->DB_LOCAL,SDB->DB_LOCALIZ,cEndereco,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_QUANT,SDB->DB_CARGA,SDB->DB_DOC,SDB->DB_CLIFOR,SDB->DB_LOJA,lPrimAtiv,lUltiAtiv})
			EndIf
			//-- Limpa as opções do ESC quando tratar apenas da atividade atual
			If DLVOpcESC() == 2 .Or. DLVOpcESC() == 3
				DLVOpcESC(0)
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
	EndIf
	lRet := .T.

	//-- Se não escolheu levar para o destino, deve verificar se existem outras atividades
	If DLVOpcESC() == 0 .And. !DLVEndDes()
		//-- Verifica se tem mais registro com o mesmo tarefa
		If (nWmsMTea == 2 .Or. nWmsMTea == 3) .And. lAtPerMul // paramentro MV_WMSMTEA
			If DLVMultAtv(SDB->(Recno()))
				lMultAtiv := .T.
			EndIf
			RestArea(aAreaSDB) //-- Volta o registro do SDB que foi alterado
		EndIf
	EndIf
	//-- Senão deve descarregar os registros pendentes
	If DLVOpcESC() == 0 .And. !lMultAtiv .And. Len(aColetor) > 0
		If Len(aColetor) > 1 .Or. DLVEndDes()
			//-- Passa por referencia o armazém e endereço por causa da tecla de atalho <CTRL> + <E>
			lRet := DesMulAtiv(@cArmazem,@cEndereco)
		Else
			lRet := DesUmaAtiv(@cArmazem,@cEndereco)
		EndIf
	EndIf

	//-- Se deu erro, bloqueia a atividade atual
	If !lRet .And. DLVOpcESC() == 0 
		RecLock('SDB', .F.)
		SDB->DB_STATUS  := cStatProb
		SDB->DB_DATAFIM := dDataBase
		SDB->DB_HRFIM   := Time()
		MsUnlock()
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DLV080Vld ºAutor  ³Fernando Joly Siquini  º Data ³24/12/2003º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o Endereco/Unitizador Digitado                      º±±
±±º          ³ Obs.: Se o ponto de entrada existir, TODA a validacao      º±±
±±º          ³       devera ser feita por ele.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC01 = Endereco/Unitizador a ser validado                º±±
±±º          ³ ExpC02 = Endereco/Unitizador designado pelo sistema        º±±
±±º          ³ ExpN03 = Tipo de Validacao, onde:                          º±±
±±º          ³          1-Endereco Origem                                 º±±
±±º          ³          2-Endereco Destino                                º±±
±±º          ³          3-Unitizador                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SOMENTE no fonte DLGV080                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DLV080Vld(cConfirma, cSistema, nTipo)
Local lRet := (cConfirma==cSistema)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao do Endereco/Unitizador   ³
//³ Parametros passados no Ponto de Entrada:                 ³
//³ PARAMIXB[01] = Endereco/Unitizador Digitado              ³
//³ PARAMIXB[02] = Endereco/Unitizador designado pelo sistema³
//³ PARAMIXB[03] = Tipo de Validacao, onde:                  ³
//³                1-Endereco origem                         ³
//³                2-Endereco Destino                        ³
//³                3-Unitizador                              ³
//³ Retorno: O retorno DEVE OBRIGATORIAMENTE ser logigo,     ³
//³          onde TRUE confirma a validacao e FALSE pede     ³
//³          nova digitacao.                                 ³
//³ Obs.: Esta posicionado no registro referente ao servico  ³
//³       no arquivo SDB.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lDLV080VL
	lRet := ExecBlock('DLV080VL', .F., .F., {cConfirma, cSistema, nTipo})
	If !lRet
		cConfirma := Space(Len(cSistema))
	EndIf
Else
	If !lRet
		If nTipo == 1
			DLVTAviso("DLGV08017",STR0021+AllTrim(cConfirma)+STR0022)      //'Endereco Origem '###' incorreto.'
		ElseIf nTipo == 2
			DLVTAviso("DLGV08017",STR0023+AllTrim(cConfirma)+STR0022)      //'Endereco Destino '###' incorreto.'
		ElseIf nTipo == 3
			DLVTAviso("DLGV08017",STR0010+' '+AllTrim(cConfirma)+STR0022)  //'Unitizador '###' incorreto.'
		EndIf
		VTKeyBoard(chr(20))
	EndIf
EndIf
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLV080UM | Autor ³ Alex Egydio               ³Data³17.02.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita a quantidade quando MV_WMSUMI igual a 3             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Produto                                              ³±±
±±³          ³ ExpC2 - Armazem                                              ³±±
±±³          ³ ExpC3 - Estrutura fisica de origem                           ³±±
±±³          ³ ExpC4 - Descricao do servico, Enderecamento                  ³±±
±±³          ³ ExpC5 - Numero do Lote                                       ³±±
±±³          ³ ExpL1 - Conteudo do parametro MV_WMSLOTE                     ³±±
±±³          ³ ExpN1 - Quantidade na 1a Unidade de Medida                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. = Incicando que o enderecamento esta ok                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlV080UM(cCodPro,cArmazem,cEstFis,cWmsUMI,cLoteOri,cSubLoteOri,nQtdTot,lAtzQtdLid,cEndereco)
Local aCab      := {PadL(STR0019,15)+' UM'}   //'Qtde'
Local aSize     := {VTMaxCol()}
Local aQtde     := {}
Local aUni      := {}
Local aQtdUni   := {}
Local nItem     := 0
Local cUM       := ""
Local cPictQt   := ""
Local cLoteCtl  := ""
Local cSubLote  := ""
Local cProduto  := ""
Local lRet      := .T.
Local lRetPE    := .T.
Local lEncerra  := .F.
Local nProxLin  := 0
Local cCodEtq   := ""
Local nQtde     := 0
Local nQtdNorma := 0
Local nQtdItem  := 0
Local lFirst    := .T.
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.F.) //-- Solicita a confirmacao do lote nas operacoes com RF
Local lRfNNorm  := SuperGetMV('MV_RFNNORM',.F.,.F.) //-- Permite mover quantidades abaixo da norma nas operacoes com radio frequencia

While DLVOpcESC() == 0 .And. !DLVEndDes()
	//--  01234567890123456789
	//--0 ___Enderecamento____
	//--1 Pegue o Produto
	//--2 PA1
	//--3 Lote
	//--4 AUTO000636
	//--5
	//--6 ___________________
	//--7  Pressione <ENTER>
	DLVTCabec(cCadastro,.F.,.F.,.T.)
	@ 01,00 VTSay PadR(STR0015, VTMaxCol()) //'Pegue o Produto'
	@ 02,00 VTSay DLGVCOD(cCodPro)
	If lWmsLote .And. Rastro(cCodPro)
		@ 03,00 VTSay PadR(STR0016,VTMaxCol()) //'Lote'
		@ 04,00 VTSay cLoteOri
		//--5 Sub-Lote
		//--6 000636
		If Rastro(cCodPro,"S")
			@ 05,00 VTSay PadR(STR0028,VTMaxCol()) //"Sub-Lote"
			@ 06,00 VTSay PadR(cSubLoteOri,VTMaxCol())
			@ 07,00 VTSay "" //LINHA EM BRANCO
		EndIf
	EndIf
	If lDV080SCR
		ExecBlock('DV080SCR',.F.,.F.)
	EndIf
	DLVTRodaPe()

	If (VTLastKey()==27)
		DLV080ESC(!lAtzQtdLid)
		Loop
	EndIf
	Exit
EndDo

If lRfNNorm .And. lAtzQtdLid
	//-- Atribui funcao para executar endereçamento com qtde a menor a combinacao de teclas <CTRL> + <F>
	VTSetKey(6,{||(lEncerra:=EndParcial(cWmsUMI))},STR0038) //Ctrl+F###"Ender Parcial"
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

			If !__lVerSimp
				aQtde := {}
				aAdd(aQtde,{PadL(Transform(nQtdTot,cPictQt),15)+' '+cUM})
				//--            1
				//--  01234567890123456789
				//--0 ___Enderecamento____
				//--1 Pegue o Produto
				//--2 PA1
				//--3             Qtde UM
				//--4 -------------------
				//--5           240.00 UN
				//--6 ___________________
				//--7  Pressione <ENTER>
				DLVTCabec(cCadastro,.F.,.F.,.T.)
				@ 01, 00 VTSay PadR(STR0015, VTMaxCol())  //'Pegue o Produto'
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
			//--7 Unidade p/Endereçar
			nItem := 1
			DLVTCabec(cCadastro,.F.,.F.,.T.)
			@ VTMaxRow()-2,0 VTSay PadR('(*) '+aQtdUni[1,2],VTMaxCol())
			DLVTRodaPe(STR0020,.F.)   //'Unidade p/Endereçar'
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
			//--7 Unidade p/Endereçar
			If lFirst
				aUni := {}
				AAdd(aUni, {aQtdUni[1,2]})
				AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[2,2],'AH_UMRES')})
				AAdd(aUni, {Posicione('SAH',1,xFilial('SAH')+aQtdUni[3,2],'AH_UMRES')})
				nItem := 1
				DLVTCabec(cCadastro,.F.,.F.,.T.)
				DLVTRodaPe(STR0020,.F.)   //'Unidade p/Endereçar'
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
				cUM   := aQtdUni[nItem,2]
					If !__lVerSimp
						aQtde := {}
						aAdd(aQtde,{PadL(Transform(nQtdItem,cPictQt),15)+' '+Iif(nItem==1,'*',AllTrim(aQtdUni[nItem,2]))})
						//--            1
						//--  01234567890123456789
						//--0 ___Enderecamento____
						//--1 Pegue o Produto
						//--2 PA1
						//--3             Qtde UM
						//--4 -------------------
						//--5           240.00 UN
						//--6 ___________________
						//--7  Pressione <ENTER>
						DLVTCabec(cCadastro,.F.,.F.,.T.)
						@ 00, 00 VTSay PadR(STR0015, VTMaxCol())  //'Pegue o Produto'
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
		Exit
	EndIf
	If (VTLastKey()==27)
		DLV080ESC(!lAtzQtdLid)
		Loop
	EndIf

	If nItem <= 0
		Loop
	EndIf

	If nItem == 1 .And. nQtdItem < 1
		DLVTAviso("DLGV08004",STR0035) //"Para endereçamento com unitizador a quantidade não pode ser menor que um."
		lFirst := .T.
		Loop
	EndIf
	//--            1
	//--  01234567890123456789
	//--0 ___Enderecamento____
	//--1 Pegue o Produto
	//--2 PA1
	//--3 PA1
	//--4 Lote
	//--5 AUTO000636
	//--6 Qtde 240 UN
	//--7     240.00
	cProduto := Space(128)
	cLoteCtl := Space(Len(SDB->DB_LOTECTL))
	cSubLote := Space(Len(SDB->DB_NUMLOTE))
	nQtde    := 0
	DLVTCabec(cCadastro,.F.,.F.,.T.)
	nProxLin := 1
	@ nProxLin++, 00 VTSay PadR(STR0015, VTMaxCol())  //'Pegue o Produto'
	@ nProxLin++, 00 VTSay DLGVCOD(cCodPro)
	@ nProxLin++, 00 VTGet cProduto Picture PesqPict('SDB','DB_PRODUTO') Valid DlV30VlPro(@cProduto,@cLoteCtl,@nQtde,@cSubLote,@nQtdTot)
	If lWmsLote .And. Rastro(cCodPro)
		@ nProxLin++,00 VTSay PadR(STR0016,VTMaxCol()) //'Lote'
		@ nProxLin++,00 VTGet cLoteCtl Picture PesqPict('SDB','DB_LOTECTL') When VTLASTKEY()==05 .Or. Empty(cLoteCtl) Valid DlV70VlLot(cLoteCtl,{cLoteOri})
	EndIf
	//Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
	If VTMaxRow() >= 10
		If lWmsLote .And. Rastro(cCodPro,"S")
			@ nProxLin++,00 VTSay PadR(STR0027,VTMaxCol()) //"Informe o Sub-Lote"
			@ nProxLin++,00 VTGet cSubLote Picture PesqPict('SDB','DB_NUMLOTE') When VTLASTKEY()==05 .Or. Empty(cSubLote) Valid DlV70VlSLt(cSubLote,{cSubLoteOri})
		EndIf
	EndIf
	@ nProxLin++, 00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) //Qtd 240.00 UN
	@ nProxLin++, 00 VTGet nQtde Picture cPictQt When VTLASTKEY()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
	VTRead
	If lEncerra
		Exit
	EndIf
	If VTLastKey()==27
		DLV080ESC(!lAtzQtdLid)
		Loop
	EndIf
	//Se não tiver espaço na tela suficiente ele mostra o sub-lote em outra tela
	If VTMaxRow() < 10
		//--            1
		//--  01234567890123456789
		//--0 ___Enderecamento____
		//--1 Informe o Sub-Lote
		//--2 000636
		If lWmsLote .And. Rastro(cCodPro,"S")
			DLVTCabec(cCadastro,.F.,.F.,.T.)
			@ 01,00 VTSay PadR(STR0027,VTMaxCol()) //"Informe o Sub-Lote"
			@ 02,00 VTGet cSubLote Picture PesqPict('SDB','DB_NUMLOTE') When VTLASTKEY()==05 .Or. Empty(cSubLote) Valid DlV70VlSLt(cSubLote,{cSubLoteOri})
			VTRead
			If lEncerra
				Exit
			EndIf
			If VTLastKey()==27
				DLV080ESC(!lAtzQtdLid)
				Loop
			EndIf
		EndIf
	EndIf
	//- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
	If !(Iif(Empty(cLoteCtl),.T.,DlV70VlLot(cLoteCtl,{cLoteOri}))) .Or. ;
		!(Iif(Empty(cSubLote),.T.,DlV70VlSLt(cSubLote,{cSubLoteOri})))
		lRet := .F.
		Loop
	EndIf

	If cWmsUMI != '2' //-- Se não está na 2a UM deve converter para a 1a UM
		//-- Converter de U.M.I. p/ 1a.UM
		If nItem == 1
			nQtdNorma:= DLQtdNorma(cCodPro,cArmazem,cEstFis,,.F.)
			nQtde    := (nQtde*nQtdNorma)
		//-- Converter de 2a.UM p/ 1a.UM
		ElseIf nItem == 2
			nQtde := ConvUm(cCodPro,0,nQtde,1)
		EndIf
	EndIf

	nQtdTot -= nQtde
	If nQtdTot < 0
		DLVTAviso("DLGV08006",STR0018)   //'Ultrapassou o total!'
		//-- Retorna ao valor anterior
		nQtdTot += nQtde
	Else
		If lDV080QTD
			nQtdNorma := DLQtdNorma(cCodPro,cArmazem,cEstFis,,.F.)
			lRetPE := ExecBlock('DV080QTD', .F., .F., {cArmazem,cEstFis,cEndereco,cCodPro,cLoteCtl,cSubLote,nQtdNorma,nQtdItem,nQtde})
			lRet   := Iif(ValType(lRetPE)=="L",lRetPE,.T.)
			If !lRet
				//-- Retorna ao valor anterior
				nQtdTot += nQtde
			EndIf
		EndIf
		If lAtzQtdLid .And. lRet //-- Quando está sendo chamado da descarga multi-tarefa não pode atualizar
			//Grava a quantidade lida para o movimento
			RecLock('SDB', .F.) // Trava para gravacao
			SDB->DB_QTDLID += Iif(cWmsUMI == '2',ConvUm(cCodPro,0,nQtde,1),nQtde)
			MsUnlock() // Destrava apos gravacao
		EndIf
	EndIf

EndDo
VTSetKey(6) //Ctrl+F
Return(lRet)

/*-----------------------------------------------------------------------------
Função para efetuar a descarga de apenas um movimento
Jackson Patrick Werka
-----------------------------------------------------------------------------*/
Static Function DesUmaAtiv(cArmazem,cEndereco)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local lRetPE    := .F.

	If lDV080SED
		lRetPE := ExecBlock('DV080SED', .F., .F., {lRet})
		lRet := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
	If lRet
		lRet := DLV080End(cArmazem,cEndereco)
		If lRet
			lRet := FinalAtiv(Len(aColetor))
		EndIf
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
Local nCntEnd   := 0
Local nCntMov   := 0
Local cWmsUMI   := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0')) //-- Indica a unidade de medida utilizadas pelas rotinas de RF
Local cWmsUMIP  := cWmsUMI //-- Unidade medida informada produto
Local aConfEnd  := {}
Local cProduto  := ''
Local cLoteCtl  := ''
Local cSubLote  := ''

	If Len(aColetor) > 1
		aConfEnd := DLGV001ORD(aColetor)
	Else
		aConfEnd := AClone(aColetor)
	EndIf

	For nCntEnd := 1 To Len(aConfEnd)
		cArmazem  := aConfEnd[nCntEnd,3]
		cEndereco := aConfEnd[nCntEnd,5]
		cProduto  := aConfEnd[nCntEnd,6]
		cLoteCtl  := aConfEnd[nCntEnd,7]
		cSubLote  := aConfEnd[nCntEnd,8]
		lPrimAtiv := aConfEnd[nCntEnd,14]
		lUltiAtiv := aConfEnd[nCntEnd,15]
		
		//Posiciona na SDB
		SDB->(DbGoTo(aConfEnd[nCntEnd,1]))
		 
		lRet := DLV080End(cArmazem,cEndereco)

		//-- Deve pesquisar se tem mais algum registro indicando outro produto
		If lRet .And. (nWmsMTea == 2 .Or. nWmsMTea == 3)
			If Len(aConfEnd) > 1
				SDB->(DbGoTo(aConfEnd[nCntEnd,1])) //Posiciona no SBD para validar o produto
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
				nQtdTot := Iif(cWmsUMIP=='2',ConvUm(SDB->DB_PRODUTO,aConfEnd[nCntEnd,9],0,2),aConfEnd[nCntEnd,9])
				//-- Passa a estrutura fisica destino para calcular a norma com base no destino para endereçamento
				lRet := DLV080UM(SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_ESTDES,cWmsUMIP,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,nQtdTot,.F.,cEndereco)
			EndIf
		EndIf

		If lRet
			Begin Transaction
			For nCntMov := Len(aColetor) To 1 Step -1
				//-- Se a movimentação é para o mesmo endereço destino
				If aColetor[nCntMov,3]+aColetor[nCntMov,5]+aColetor[nCntMov,6]+aColetor[nCntMov,7]+aColetor[nCntMov,8] == cArmazem+cEndereco+cProduto+cLoteCtl+cSubLote
					//-- Posiciona o registro de movimentação
					SDB->(DbGoTo(aColetor[nCntMov,1]))
					lRet := FinalAtiv(nCntMov)
				EndIf
			Next nCntMov
			End Transaction
		EndIf

		If DLVOpcESC() > 0
			//-- Neste caso, sempre vai forçar bloquear todas as atividades que ficaram pendentes
			If DLVOpcESC() == 2
				DLVOpcESC(1)
			EndIf
			Exit
		EndIf

	Next nCntEnd

RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Função para efetuar a finalização das atividades movimentando o estoque
Jackson Patrick Werka
-----------------------------------------------------------------------------*/
Static Function FinalAtiv(lPosCol)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lRetPE     := .T.
Local lAtuEst    := .T.

Default lPosCol   := 1

	If lDVATUEST //-- Não utilizar mais
		lRetPE := ExecBlock("DLGV080END",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf
	If lDV080EST
		lRetPE := ExecBlock("DV080EST",.F.,.F.)
		lAtuEst:= Iif(ValType(lRetPE)=="L",lRetPE,lAtuEst)
	EndIf

	If SDB->(SimpleLock()) .And. SDB->DB_STATUS==cStatInte // Verifica se conseguiu travar registro
		Begin Transaction
		If lAtuEst .And. lUltiAtiv
			//-- Confirma o movimento de distribuicao atualizando o estoque.
			lRet := DLV080GrIn()
		EndIf
		If lRet
			//-- Atualiza o SDB para finalizado
			RecLock('SDB', .F.)  // Trava para gravacao
			SDB->DB_STATUS  := cStatExec
			SDB->DB_DATAFIM := dDataBase
			SDB->DB_HRFIM   := Time()
			MsUnlock() // Destrava apos gravacao
		EndIf
		If lRet
			If !Empty(aColetor)
				ADel(aColetor,lPosCol) //-- Apaga do array o registro que ja foi movimentado
				ASize(aColetor,Len(aColetor)-1)   //-- Exclui fisicamente o registro do array
			EndIf
		Else
			DisarmTransaction()
		EndIf
		End Transaction
	   If lDV080DES
		   lRet := ExecBlock('DV080DES', .F., .F.,{lRet})
	   EndIf
	Else
		SDB->(MsUnLock())
		lRet := .F.
	EndIf

RestArea(aAreaAnt)
Return lRet

/*-----------------------------------------------------------------------------
Monta a tela e solicita o endereco de destino
-----------------------------------------------------------------------------*/
Static Function DLV080End(cArmazem,cEndereco)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .T.
Local lRetPE    := .F.
Local cConfirma := ""
Local bKey10    := Nil

	//-- Ponto de entrada para elaborar a selecao do endereco de destino do endereçamento.
	If lDV080DST
		lRetPE := ExecBlock('DV080DST', .F., .F.)
		lRet := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	Else
		//-- Atribui a funcao para informar novo endereco destino a combinacao de teclas <CTRL> + <J>
		If lPrimAtiv
			bKey10 := VTSetKey(10,{||DlV080Opc(@cEndereco)},STR0034) //Altera Endereço
		EndIf

		If !__lVerSimp
			DLVEndereco(00, 00, cEndereco, cArmazem,,,STR0011)  //"Leve p/o Endereco"
			If (VTLastKey()==27) .And. (DLVTAviso("DLGV08007",STR0005, {STR0006,STR0007})==1) //"Deseja encerrar o enderecamento?"###"Sim"###"Nao"
				DLVOpcESC(1) // Bloquear Todas Atividades
				lRet := .F.
			EndIf
		EndIf

		If lRet
			//-- Confirma Endereco
			While .T.
				cConfirma := Space(Len(SDB->DB_ENDDES))
				//--  01234567890123456789
				//--0 Leve para o Endereco
				//--1
				//--2 Endereco
				//--3 R01P01N01
				//--4
				//--5 Confirme !
				//--6 R01P01N01
				//--7
				DLVTCabec(STR0011,.F.,.F.,.T.) //'Leve para o Endereco'
				@ 02, 00 VTSay PadR(STR0002, VTMaxCol())  //"Endereco"
				@ 03, 00 VTSay PadR(cEndereco, VTMaxCol())
				@ 05, 00 VTSay PadR(STR0008, VTMaxCol())  //"Confirme !"
				@ 06, 00 VTGet cConfirma Pict '@!' Valid DLV080Vld(@cConfirma, cEndereco, 2)
				VTRead()
				If (VTLastKey()==27)
					If DLVTAviso("DLGV08008",STR0005, {STR0006,STR0007})==1   //"Deseja encerrar o Enderecamento?"###"Sim"###"Nao"
						DLVOpcESC(1) // Bloquear Todas Atividades
						lRet := .F.
					Else
						Loop
					EndIf
				EndIf
				Exit
			EndDo
		EndIf

		If lPrimAtiv
			VTSetKey(10,bKey10)
		EndIf
	EndIf

	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLV080GrIn³ Autor ³ Alex Egydio           ³ Data ³18.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma o movimento de distribuicao atualizando o estoque ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLV080GrIn()                                               ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DLV080GrIn(lHelp)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nTipEst   := 0
Local cQuery    := ''
Local cAliasQry := ''
Local cAliasSDD := GetNextAlias()

Private aParam150 := Array(34)
Default lHelp     := .T.

//-- Ao confirmar a ultima atividade da tarefa registrar o movimento de estoque.
If DLUltiAtiv(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_IDMOVTO,SDB->DB_ORDATIV)
	aParam150[01] := SDB->DB_PRODUTO //-- Produto
	aParam150[02] := SDB->DB_LOCAL   //-- Almoxarifado
	aParam150[03] := SDB->DB_DOC     //-- Documento
	aParam150[04] := SDB->DB_SERIE   //-- Serie
	aParam150[05] := SDB->DB_NUMSEQ  //-- Sequencial
	aParam150[06] := SDB->DB_QUANT   //-- Saldo do produto em estoque
	aParam150[07] := SDB->DB_DATA    //-- Data da Movimentacao
	aParam150[08] := Time()          //-- Hora da Movimentacao
	aParam150[09] := SDB->DB_SERVIC  //-- Servico
	aParam150[10] := SDB->DB_TAREFA  //-- Tarefa
	aParam150[11] := SDB->DB_ATIVID  //-- Atividade
	aParam150[12] := SDB->DB_CLIFOR  //-- Cliente/Fornecedor
	aParam150[13] := SDB->DB_LOJA    //-- Loja
	aParam150[14] := ''              //-- Tipo da Nota Fiscal
	aParam150[15] := '01'            //-- Item da Nota Fiscal
	aParam150[16] := ''              //-- Tipo de Movimentacao
	aParam150[17] := SDB->DB_ORIGEM  //-- Origem de Movimentacao
	aParam150[18] := SDB->DB_LOTECTL //-- Lote
	aParam150[19] := SDB->DB_NUMLOTE //-- Sub-Lote
	aParam150[20] := SDB->DB_LOCALIZ //-- Endereco
	aParam150[21] := SDB->DB_ESTFIS  //-- Estrutura Fisica
	aParam150[22] := '1'             //-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
	aParam150[23] := SDB->DB_CARGA   //-- Carga
	aParam150[24] := SDB->DB_UNITIZ  //-- Nr. do Pallet
	aParam150[25] := SDB->DB_LOCAL   //-- Centro de Distribuicao Destino
	aParam150[26] := SDB->DB_ENDDES  //-- Endereco Destino
	aParam150[27] := SDB->DB_ESTDES  //-- Estrutura Fisica Destino
	aParam150[28] := SDB->DB_ORDTARE //-- Ordem da Tarefa
	aParam150[29] := SDB->DB_ORDATIV //-- Ordem da Atividade
	aParam150[30] := SDB->DB_RHFUNC  //-- Funcao do Recurso Humano
	aParam150[31] := SDB->DB_RECFIS  //-- Recurso Fisico
	aParam150[32] := SDB->DB_IDDCF   //-- Identificador do DCF
	aParam150[34] := SDB->DB_IDMOVTO //-- Identificador exclusivo do Movimento no SDB
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclui trava para uso exclusivo desta carga / documento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lHelp
		DLVTCabec(cCadastro,.F.,.F.,.T.)
		@ Int(VTMaxRow()/2), 00 VtSay STR0039 //'Processando...'
	EndIf
	//-- Efetua a Gravacao do Produto no Endereco Desejado
	lRet := WmsEndereca(.T.,'2')
	//-- Grava status de execucao automatica
	DLVStAuto(aParam150[09],aParam150[28],aParam150[10])

	If lRet
		DbSelectArea('DC5')
		DC5->( DbSetOrder(1) )

		//Se existe o campo Bloqueia Lote a funcao prossegue
		If DC5->(FieldPos('DC5_BLQLOT')) > 0
			If Rastro(SDB->DB_PRODUTO, "")
				If DC5->(DbSeek(xFilial('DC5')+SDB->DB_SERVIC) )
					SX5->(DbSetOrder(1))
					SX5->(DbSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
					cFunExe := AllTrim(Upper(SX5->(X5Descri())))
					// Valida se funcao permite Bloqueio de Lote automaticamente
					If ('DLENDERECA' $ cFunExe .Or. 'DLCROSSDOC' $ cFunExe) .AND. DC5->DC5_BLQLOT = '1'
						cQuery := "SELECT SDD.R_E_C_N_O_ RECNOSDD "
						cQuery += "FROM "+RetSqlName('SDD')+" SDD "
						cQuery += "WHERE SDD.DD_FILIAL = "+xFilial('SDD')
						cQuery += "AND SDD.DD_DOC = '"+SDB->DB_DOC+"' "
						cQuery += "AND SDD.DD_PRODUTO = '"+SDB->DB_PRODUTO+"' "
						cQuery += "AND SDD.DD_LOCAL   = '"+SDB->DB_LOCAL+"' "
						cQuery += "AND SDD.DD_LOTECTL = '"+SDB->DB_LOTECTL+"' "
						cQuery += "AND SDD.DD_NUMLOTE = '"+SDB->DB_NUMLOTE+"' "
						cQuery += "AND SDD.DD_LOCALIZ = '"+SDB->DB_ENDDES+"' "
						cQuery += "AND SDD.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSDD,.F.,.T.)
						//Grava SDD
						RecLock('SDD', (cAliasSDD)->( Eof() )) // Trava para gravacao
						If (cAliasSDD)->( Eof() )
							DbSelectArea('SB8')
							If (Rastro(SDB->DB_PRODUTO, 'S') .And. !Empty(SDB->DB_NUMLOTE))
								SB8->( DbSetOrder(2) )
								SB8->( DbSeek(xFilial('SB8')+SDB->DB_NUMLOTE+SDB->DB_LOTECTL+SDB->DB_PRODUTO+SDB->DB_LOCAL, .F.) )
							Else
								SB8->( DbSetOrder(3))
								SB8->( DbSeek(xFilial('SB8')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL,.F.) )
							EndIf
							SDD->DD_FILIAL  := xFilial('SDD')
							SDD->DD_DOC     := SDB->DB_DOC
							SDD->DD_PRODUTO := SDB->DB_PRODUTO
							SDD->DD_LOCAL   := SDB->DB_LOCAL
							SDD->DD_LOTECTL := SDB->DB_LOTECTL
							SDD->DD_NUMLOTE := SDB->DB_NUMLOTE
							SDD->DD_DTVALID := SB8->B8_DTVALID
							SDD->DD_LOCALIZ := SDB->DB_ENDDES
							SDD->DD_MOTIVO  := 'IN'
							SDD->DD_OBSERVA := 'Gerado automaticamente pelo WMS'
						Else
							SDD->(DbGoto((cAliasSDD)->RECNOSDD))
						EndIf
						SDD->DD_QUANT   += SDB->DB_QUANT
						SDD->DD_QTSEGUM += SDB->DB_QTSEGUM
						SDD->DD_QTDORIG += SDB->DB_QUANT
						SDD->DD_SALDO   += SDB->DB_QUANT
						SDD->DD_SALDO2  += SDB->DB_QTSEGUM

						MsUnlock() // Destrava apos gravacao
						(cAliasSDD)->( DbCloseArea())

						//-- Atualiza os arquivos de Saldos por Lote, Localizacao e Saldos em Estoque
						GravaEmp(SDD->DD_PRODUTO,;
									SDD->DD_LOCAL,;
									SDD->DD_QUANT,;
									SDD->DD_QTSEGUM,;
									SDD->DD_LOTECTL,;
									SDD->DD_NUMLOTE,;
									SDD->DD_LOCALIZ,;
									SDD->DD_NUMSERI,;
									Nil,;
									Nil,;
									SDD->DD_DOC,;
									Nil,;
									"SDD",;
									Nil,;
									Nil,;
									Nil,;
									.F.,;
									.F.,;
									.F.,;
									.F.,;
									.T.,;
									.T.,;
									.T.,;
									.F.,;
									SDB->DB_IDDCF,;
									Nil,;
									Nil,;
									Nil,;
									Nil,;
									Nil)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Libera o pedido de venda bloqueado por falta de estoque
	If lRet
		nTipEst := DLTipoEnd(SDB->DB_ESTDES)
		If nTipEst = 3
			cAliasQry := GetNextAlias()
			cQuery := "SELECT C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_SERVIC"
			cQuery += " FROM "+RetSqlName('SC9')+" SC9"
			cQuery += " WHERE C9_FILIAL = '"+xFilial('SC9')+"'"
			cQuery += " AND C9_BLEST    = '02'"
			cQuery += " AND C9_BLCRED   = '"+Space(Len(SC9->C9_BLCRED))+"'"
			cQuery += " AND C9_PRODUTO  = '"+SDB->DB_PRODUTO+"'"
			cQuery += " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			While (cAliasQry)->(!Eof())
				If WmsVldSrv("9", (cAliasQry)->C9_SERVIC,,,)
					DbSelectArea('SC9')
					SC9->(DbSetOrder(1))
					SC9->(DbSeek(xFilial("SC9")+(cAliasQry)->C9_PEDIDO+(cAliasQry)->C9_ITEM+(cAliasQry)->C9_SEQUEN))
					a450Grava(1,.T.,.T.,.F.)
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

	If !lRet .And. lHelp
		DLVTAviso("DLGV03011",STR0012)  //"Problemas no endereçamento!"
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

Function DLVGrEntra(lHelp)
Return DLV080GrIn(lHelp)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLGVCOD  | Autor ³ Sandro                     ³Data³23.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostrar o codigo do produto ou o codigo de barras conforme   ³±±
±±³          ³ parametro MV_WMSCODP                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DLGVCOD(cCodigo)
Local aAreaSB1:= SB1->(GetArea())
If GetMv("MV_WMSCODP",.F.,.T.)
	Return cCodigo
EndIf
If SB1->B1_COD <> cCodigo
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodigo))
EndIf
cCodigo := SB1->B1_CODBAR
RestArea(aAreaSB1)
Return cCodigo

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DlV080Opc| Autor ³ Alex Egydio                ³Data³23.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Substitui o endereco de destino                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Endereco de destino original                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DlV080Opc(cEndDest)
Local aAreaSDB := SDB->(GetArea())
Local aAreaSBE := SBE->(GetArea())
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cAliasOpc   := 'SDB'
Local cQuery   := ''
Local cCliFor  := SDB->DB_CLIFOR
Local cLoja    := SDB->DB_LOJA
Local cDocto   := SDB->DB_DOC
Local cSerie   := SDB->DB_SERIE
Local cLocal   := SDB->DB_LOCAL
Local cProduto := SDB->DB_PRODUTO
Local cLocaliz := SDB->DB_LOCALIZ
Local cNumSeri := SDB->DB_NUMSERI
Local cNewEnd  := Space(Len(cEndDest))
Local cNewEFis := ''
Local nQuant   := SDB->DB_QUANT
Local lRet     := .F.
//-- Variavel definida no ponto de entrada DLV080VL quando eh feita a leitura de ID de endereco.
Private cV080End:= ''

If VTLastKey() <> 10 //CTRL+J, quando entra pelo CTRL+A
	DLVTAviso(cCadastro,STR0029) //"Para alterar o endereço pressione CTRL+J no campo endereço destino!"
	Return Nil
EndIf

If lDV080OPC
	cNewEnd := ExecBlock('DV080OPC', .F., .F., {cEndDest})
Else
	DLVTCabec(cCadastro,.F.,.F.,.T.)
	@ 02, 00 VTSay PadR(STR0025, VTMaxCol())  //'Novo Endereco'
	@ 03, 00 VTGet cNewEnd Pict '@!' Valid DLV080Vld(@cNewEnd,cNewEnd,2) .And. cNewEnd<>cEndDest
	VTRead
EndIf

lRet := !(VTLastKey()==27) .Or. !Empty(cNewEnd)

If lRet .And. !Empty(cV080End)
	cNewEnd := cV080End
EndIf

If lRet .And. !Empty(cNewEnd) .And. SuperGetMV('MV_WMSVLDT',.F.,.T.)
	//-- Na convocacao com Radio Frequencia passamos o 7o parametro com ZERO, pois a quantidade ja sera considerada
	//-- pela funcao WmsSaldoSBF
	lRet := WMSVldDest(cProduto,cLocal,cNewEnd,Nil,Nil,cNumSeri,0)
EndIf

If lRet
	SBE->(DbSetOrder(1))
	If SBE->(MsSeek(xFilial('SBE')+cLocal+cNewEnd))
		cNewEFis := SBE->BE_ESTFIS
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. DLVTAviso("DLGV08009",STR0026, {STR0006,STR0007})==1   //'Substitui o Endereco?'###'Sim'###'Nao'
	DbSelectArea('SDB')
	DbSetOrder(1)
	cAliasOpc:= GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_CLIFOR  = '"+cCliFor+"'"
	cQuery +=   " AND DB_LOJA    = '"+cLoja+"'"
	cQuery +=   " AND DB_PRODUTO = '"+cProduto+"'"
	cQuery +=   " AND DB_LOCAL   = '"+cLocal+"'"
	cQuery +=   " AND DB_LOCALIZ = '"+cLocaliz+"'"
	cQuery +=   " AND DB_ENDDES  = '"+cEndDest+"'"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_STATUS IN ('2','3','4')"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasOpc,.F.,.T.)
	While (cAliasOpc)->(!Eof())
		SDB->(DbGoTo((cAliasOpc)->RECSDB))
		RecLock('SDB',.F.)
		SDB->DB_ENDDES := cNewEnd
		SDB->DB_ESTDES := cNewEFis
		MsUnLock()
		(cAliasOpc)->(DbSkip())
	EndDo
	(cAliasOpc)->(DbCloseArea())
	//-- O endereco cNewEnd tera seu status atualizado pela funcao GRAVASBF apos a confirmacao do endereco destino e movimentacao do estoque.
	cEndDest := cNewEnd
EndIf
RestArea(aAreaSBE)
//-- Favor nao alterar!!!
//-- Eh obrigatorio q a funcao saia com este restarea ativo!!!
RestArea(aAreaSDB)
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
//-- Apresenta o novo endereco na tela
@ 03, 00 VTSay PadR(cEndDest, VTMaxCol())
Return

/*****************************************************************************/
/*****************************************************************************/
Static Function EndParcial(cWmsUMI)
Local aAreaAnt  := GetArea()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet      := .F.
Local nQtdTotal := 0
Local nQtdLida  := 0
Local cPictQt   := ""

	nQtdTotal := Iif(cWmsUMI=='2',SDB->DB_QTSEGUM,SDB->DB_QUANT)
	nQtdLida  := Iif(cWmsUMI=='2',ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2),SDB->DB_QTDLID)
	cPictQt   := Iif(cWmsUMI=='2',PesqPict("SDB","DB_QTSEGUM"),PesqPict("SDB","DB_QUANT"))

	If (nQtdTotal-nQtdLida) <= 0 //Se endereçou tudo não há o que quebrar no movimento
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	DLVTCabec(cCadastro,.F.,.F.,.T.)
	@ 01, 00 VTSay PadR(STR0017, VTMaxCol()) //"Quantidade"
	@ 02, 00 VTSay PadR(STR0036, VTMaxCol()) //"Total"
	@ 03, 00 VTSay PadR(Transform(nQtdTotal,cPictQt), VTMaxCol())
	@ 04, 00 VTSay PadR(STR0037, VTMaxCol()) //"Endereçada"
	@ 05, 00 VTSay PadR(Transform(nQtdLida,cPictQt), VTMaxCol())
	DLVTRodaPe()

	If DLVTAviso("DLGV08010",STR0024,{STR0006,STR0007})==1 //"Endereçar atividade com quantidade parcial?"###"Sim"###"Nao"
		If !DLAtivAglt(SDB->DB_IDDCF,SDB->DB_IDMOVTO,SDB->DB_IDOPERA)
			WmsAtzSDB('1',SDB->DB_QTDLID)
			lRet := .T.
			VTKeyBoard(Chr(27)) //-- Tecla ESC
		Else
			DLVTAviso("DLGV08005",STR0040) //"Atividade está aglutinada, não permite movimentar parcial."
			lRet := .F.
		EndIf
	EndIf

VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
RestArea(aAreaAnt)
Return lRet

/*****************************************************************************/
/*****************************************************************************/
Static Function DLV080ESC(lForcaEnc)
Local lSaida    := .F.
Local aOpcoes   := {}
Local nOpcao    := 0
Local lPulaAtiv := DLVPulaAti()
Default lForcaEnc := .F.

	DLVOpcESC(0)
	//-- Se permite selecionar mais de uma atividade
	If (nWmsMTea == 2 .Or. nWmsMTea == 3) .And. !lForcaEnc
		//-- Se possui mais de uma atividade no aColetor, ou se a primeira é diferente do SDB atual
		If Len(aColetor) > 1 .Or. (Len(aColetor) == 1 .And. aColetor[1,1] != SDB->(Recno()))
			aOpcoes := {STR0031,STR0032} //"Bloquear Atividade"###"Endereco Destino"
			If lPulaAtiv
				AAdd(aOpcoes,STR0042) //"Pular Atividade"
			EndIf
			nOpcao := DLVTAviso(cCadastro,STR0030,aOpcoes) //Opcoes -- "Atencao! Escolha uma ação a ser executada:"
			If nOpcao == 1
				aOpcoes := {STR0043,STR0044} //"Atividade Atual"###"Todas Atividades"
				nOpcao := DLVTAviso(cCadastro,STR0041,aOpcoes) //Opcoes -- "Atencao! Escolha o tipo de bloqueio:"
				If nOpcao == 1
					DLVOpcESC(2) //-- Bloqueia Atividade Atual
				ElseIf nOpcao == 2
					DLVOpcESC(1) //-- Bloqueia Todas Atividades
				EndIf
			ElseIf nOpcao == 2
				DLVEndDes(.T.) //-- Libera Atividade Atual e Envia Anteriores para Doca
			ElseIf nOpcao == 3
				DLVOpcESC(3) // Pular Atividade Atual
			EndIf
		Else
			lSaida := .T.
		EndIf
	Else
		lSaida := .T.
	EndIf

	If lSaida
		If lPulaAtiv .And. !lForcaEnc
			aOpcoes := {STR0031,STR0042} //"Bloquear Atividade"###"Pular Atividade"
			nOpcao := DLVTAviso(cCadastro,STR0030,aOpcoes) //Opcoes -- "Atencao! Escolha uma ação a ser executada:"
			If nOpcao == 1
				DLVOpcESC(2) // Bloquear Atividade Atual
			ElseIf nOpcao == 2
				DLVOpcESC(3) // Pular Atividade Atual
			EndIf
		Else
			If DLVTAviso(cCadastro,STR0005, {STR0006,STR0007}) == 1 //'Deseja encerrar o endereçamento?'###'Sim'###'Nao'
				DLVOpcESC(2) // Bloquear Atividade Atual
			EndIf
		EndIf
	EndIf
Return (Nil)

