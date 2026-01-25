#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSV084.CH"
#INCLUDE "APVT100.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSV084 - Montagem de Unitizadores Coletor                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a montagem de unitizadores de forma manual através |
|         | do coletor de dados.                                               |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSV08401 "WMSV08401"
#DEFINE WMSV08402 "WMSV08402"
#DEFINE WMSV08403 "WMSV08403"
#DEFINE WMSV08404 "WMSV08404"
#DEFINE WMSV08405 "WMSV08405"
#DEFINE WMSV08406 "WMSV08406"
#DEFINE WMSV08407 "WMSV08407"
#DEFINE WMSV08408 "WMSV08408"
#DEFINE WMSV08409 "WMSV08409"
#DEFINE WMSV08410 "WMSV08410"
#DEFINE WMSV08411 "WMSV08411"
#DEFINE WMSV08412 "WMSV08412"
#DEFINE WMSV08413 "WMSV08413"
#DEFINE WMSV08414 "WMSV08414"
#DEFINE WMSV08415 "WMSV08415"
#DEFINE WMSV08416 "WMSV08416"
#DEFINE WMSV08417 "WMSV08417"
#DEFINE WMSV08418 "WMSV08418"
#DEFINE WMSV08419 "WMSV08419"
#DEFINE WMSV08420 "WMSV08420"
#DEFINE WMSV08421 "WMSV08421"

Static __lCBRETEAN := ExistBlock("CBRETEAN")
Static __WV084AUT  := ExistBlock("WV084AUT")
Static __WV084VPR  := ExistBlock("WV084VPR") // Validacao do produto na montagem
Static oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Static lEndereca   := .F.
Static __aItsUni   := {}

//----------------------------------------------------------------------------------
Function WMSV084(cOrigem)
Local aTela     := VtSave()
Local cKey24    := VtDescKey(24)
Local bkey24    := VTSetKey(24)
Local nOpc      := 0
Local cArmazem  := Space(TamSx3("D14_LOCAL")[1])
Local cEndereco := Space(TamSx3("D14_ENDER")[1])

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	VTClear()
	If Empty(cOrigem) .Or. !(cOrigem $ "SD1|SD3|SC2|SD7")
		@ 0,0 VTSay STR0001+":" // "Selecione"
		nOpc := VTaChoice(2,0,VTMaxRow()-1,VTMaxCol(),{STR0002,STR0003,STR0004,STR0042}) // Doc. Entrada // Mov. Interna // Apont. Producao // Qualidade
		Do Case
			Case nOpc == 1
				cOrigem := "SD1"
			Case nOpc == 2
				cOrigem := "SD3"
			Case nOpc == 3
				cOrigem := "SC2"
			Case nOpc == 4
				cOrigem := "SD7"
		EndCase
	EndIf

	If VtLastKey() == 27
		VtRestore(,,,,aTela)
	Else
		oMntUniItem:ClearData()
		oMntUniItem:oUnitiz:SetOrigem(cOrigem)

		If GetEndOrig(@cArmazem,@cEndereco)
			oMntUniItem:oUnitiz:SetArmazem(cArmazem)
			oMntUniItem:oUnitiz:SetEnder(cEndereco)
			// Atribui tecla de atalho para estorno
			VTSetKey(24,{|| EstUnitiz()}, STR0005) // Ctrl-X // Estorno
			MntUnitiz()
		EndIf
	EndIf
	VTSetKey(24,bkey24,cKey24)
Return Nil
//----------------------------------------------------------------------------------
Function WMSV084A()
// Opção do menu para realizar a montagem de unitizador com base nas demandas de origem Documento de Entrada
Return WMSV084("SD1")
//----------------------------------------------------------------------------------
Function WMSV084B()
// Opção do menu para realizar a montagem de unitizador com base nas demandas de origem Movimentação Interna de Devolução
Return WMSV084("SD3")
//----------------------------------------------------------------------------------
Function WMSV084C()
// Opção do menu para realizar a montagem de unitizador com base nas demandas de origem Apontamento de Produção
Return WMSV084("SC2")
//----------------------------------------------------------------------------------
Function WMSV084D()
// Opção do menu para realizar a montagem de unitizador com base nas demandas de origem Liberação de Qualidade
Return WMSV084("SD7")
//----------------------------------------------------------------------------------
Static Function GetEndOrig(cArmazem,cEndereco)
Local lEncerra := .F.

	Do While !lEncerra
		WMSVTCabec(STR0006,.F.,.F.,.T.) // Montagem Unitizador
		@ 01,00 VTSay PadR(STR0007+":",VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmazem Pict "@!" Valid VldArmazem(cArmazem)
		@ 03,00 VTSay PadR(STR0008+":",VTMaxCol()) // Endereco
		@ 04,00 VTGet cEndereco Pict "@!" Valid VldEndOrig(cArmazem,cEndereco)
		VtRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			lEncerra := WmsQuestion(STR0009,STR0006) // Confirma a saída?
			Loop
		EndIf
		Exit
	EndDo
Return !lEncerra
//----------------------------------------------------------------------------------
Static Function MntUnitiz()
Local cKey06   := VtDescKey(06)
Local cKey09   := VtDescKey(09)
Local cKey21   := VtDescKey(21)
Local bkey06   := VTSetKey(06) // Ctrl+F
Local bkey09   := VTSetKey(09) //Ctrl+I
Local bkey21   := VTSetKey(21) // Ctrl+U
Local aTela    := VTSave()
Local aTelaAux := {}
Local lRet     := .T.
Local lSair    := .F.
Local cUnitiz  := ""
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0
Local nProxLin := 1
Local lQtdDig  := .T.
Local lNewUnit := .F.
Local lRetPE   := .T.

	While !lSair

		lEndereca := .F.
		// Inicializa variaveis
		cUnitiz  := Space(TamSx3("D0R_IDUNIT")[1])
		lNewUnit := .T.
		// Solicita o código do unitizador
		If !GetIdUnit(@cUnitiz,@lNewUnit)
			lSair := WmsQuestion(STR0009,STR0006) // Confirma a saída?
			Loop
		EndIf

		// Tratamentos para o PE que permite automatizar a montagem de unitizadores
		If __WV084AUT .And. Len(__aItsUni) > 0
			VTClearBuffer()
			__aItsUni := {} // Libera memória
			Loop
		EndIf

		VTSetKey(06,{|| GerarOS(@cUnitiz)}, STR0039) // Ctrl+F // Gerar OS End.
		VTSetKey(09,{|| ShowItens(cUnitiz)}, STR0010) // Ctrl+I // Itens Unitiz.
		VTSetKey(21,{|| GetIdUnit(@cUnitiz,@lNewUnit)}, STR0011) // Ctrl+U // Unitizador
		VTSetKey(15,{|| MostraUnit(cUnitiz)}, STR0043) // Ctrl+O // "Cons.Unitizador"
		While !lSair .And. !lEndereca
			VtClear()
			VTClearBuffer()
			lNewUnit := .F.
			nProxLin := 1
			cCodBar  := Space(128)
			cProduto := Space(TamSx3("D0S_CODPRO")[1])
			cLoteCtl := Space(TamSx3("D0S_LOTECT")[1])
			cSubLote := Space(TamSx3("D0S_NUMLOT")[1])

			//   01234567890123456789
			// 0 Montagem Unitizador
			// 1 ID: UN00000001
			// 2 Informe o Produto
			// 3 PRDWMS0001
			// 4 Lote: AUTO000000
			// 5 Sub-Lote: 000000
			// 6 Qtde
			// 7             9.999,99

			WMSVTCabec(STR0006, .F., .F., .T.) // Montagem Unitizador
			If Len(cUnitiz) == 6
				@ nProxLin++,00 VTSay PadR(STR0011 + ": " + cUnitiz,VTMaxCol()) // Unitizador
			ElseIf Len(cUnitiz) <= 16
				@ nProxLin++,00 VTSay PadR("ID: " + cUnitiz,VTMaxCol()) // Unitizador
			Else
				@ nProxLin++,00 VTSay PadR(cUnitiz,VTMaxCol()) // Unitizador
			EndIf
			@ nProxLin++,00 VTSay STR0012 // Informe o Produto
			@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid VldPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
			VtRead()

			If VTLastKey() != 27
				If Rastro(cProduto)
					@ nProxLin,   00 VTSay PadR(STR0013+":", VTMaxCol()) // Lote
					@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid VldLoteCtl(cLoteCtl)
					If Rastro(cProduto,"S")
						@ nProxLin,   00 VTSay PadR(STR0014+":", VTMaxCol()) // Sub-Lote
						@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid VldSubLote(cSubLote)
					EndIf
				EndIf

				While .T.
					lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
					@ nProxLin++,00 VTSay STR0015 // Qtde
					@ nProxLin++,00 VTGet nQtde Picture PesqPict("D0S","D0S_QUANT")  When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
					VTRead()
					If VTLastKey() == 27
						Exit // Volta para o inicio do produto
					EndIf

					If !VldQtdSld(nQtde)
						nQtde    := 0
						nProxLin -= 2
						// Caso a quantidade não tenha sido digitada pelo usuário, volta para o produto
						If !lQtdDig
							Exit
						Else
							Loop
						EndIf
					EndIf
					
					If __WV084VPR
						lRetPE := Execblock("WV084VPR",.F.,.F.,{cProduto, cLoteCtl, nQtde, oMntUniItem:oUnitiz:GetArmazem(), oMntUniItem:oUnitiz:GetEnder(), oMntUniItem:oUnitiz:GetOrigem(), oMntUniItem:oUnitiz:oTipUnit:GetTipUni()})
						If !IIf(ValType(lRetPE)=="L",lRetPE,.T.)
							Exit
						Endif
					Endif

					If VTLastKey() != 27
						aTelaAux := VTSave()
						VTMsg(STR0036+"...") // Processando
						oMntUniItem:SetQuant(nQtde)
						If !oMntUniItem:MntPrdUni()
							WMSVTAviso(WMSV08401,oMntUniItem:GetErro()) // Erro do objeto
							// Deve restaurar a tela para limpar a mensagem de processamento
							VtRestore(,,,,aTelaAux)
							nQtde    := 0
							nProxLin -= 2
							Loop
						EndIf
						oMntUniItem:SetIdUnitA(oMntUniItem:GetIdUnit())
					EndIf
					Exit
				EndDo
			Else
				If !lNewUnit .And. !lEndereca .And. WmsQuestion(STR0009,STR0006) // Confirma a saída?
					lSair := .T.
				EndIf
			EndIf
		EndDo
		// Restaura teclas
		VTSetKey(06,bkey06,cKey06)
		VTSetKey(09,bkey09,cKey09)
		VTSetKey(21,bkey21,cKey21)
	EndDo

	// Caso operador tenha saído da montagem e não tenha gerado Ordem de Serviço, altera o status para '2=Aguard. Ender'
	If lSair .And. oMntUniItem:oUnitiz:GetStatus() == "1" .And. oMntUniItem:oUnitiz:UniHasItem()
		oMntUniItem:oUnitiz:SetStatus("2") // Aguardando Endereçamento
		If !oMntUniItem:oUnitiz:UpdStatus()
			WMSVTAviso(WMSV08418, oMntUniItem:oUnitiz:GetErro()) // Erro do objeto
		EndIf
	EndIf

	VtRestore(,,,,aTela)
Return lRet
//----------------------------------------------------------------------------------
Static Function GetIdUnit(cUnitiz,lNewUnit)
Local cKey06    := VtDescKey(06)
Local bKey06    := VTSetKey(06)
Local cKey09    := VtDescKey(09)
Local bKey09    := VTSetKey(09)
Local cKey21    := VTDescKey(21)
Local bKey21    := VTSetKey(21)
Local aTela     := VtSave()
Local lRet      := .T.
Local cUnitAux  := Space(TamSx3("D0R_IDUNIT")[1])
Local cTipUni   := Space(TamSx3("D0R_CODUNI")[1])
Local cIdUniAnt := oMntUniItem:GetIdUnit()

	oMntUniItem:SetIdUnit("")
	// Limpa o serviço para permitir montar unitizadores diferentes com serviços diferentes
	oMntUniItem:oUnitiz:SetServico("")
	If Empty(oMntUniItem:oUnitiz:oTipUnit:GetTipUni())
		oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
	EndIf
	cTipUni := oMntUniItem:oUnitiz:oTipUnit:GetTipUni()
	VtClear()
	If !Empty(cTipUni)
		VTKeyBoard(Chr(13))
	EndIf
	WMSVTCabec(STR0006, .F., .F., .T.) // Montagem Unitizador
	@ 01,00 VTSay STR0007+"/"+STR0008 // Armazém/Endereço
	@ 02,00 VTSay oMntUniItem:oUnitiz:GetArmazem()+"/"+oMntUniItem:oUnitiz:GetEnder()
	@ 03,00 VtSay STR0017 // Tipo Unitiz.
	@ 04,00 VtGet cTipUni Picture '@!' Valid VldTipUni(cTipUni) When !(oMntUniItem:oUnitiz:UniHasItem()) F3 "D0T"
	@ 05,00 VtSay STR0016 // Informe o Unitiz.
	@ 06,00 VtGet cUnitAux Picture '@!' Valid VldIdUnit(cUnitAux,@cTipUni)
	VtRead()

	VtRestore(,,,,aTela)

	If VtLastkey() == 27
		// Caso haja cancelamento da troca do unitizador, volta o código antigo
		oMntUniItem:SetIdUnit(cIdUniAnt)
		lRet := .F.
	EndIf

	If lRet
		// Caso seja alterado o unitizador
		If !(cUnitAux == cIdUniAnt) .And. !Empty(cIdUniAnt)
			oMntUniItem:SetIdUnit(cIdUniAnt)
			// Atualiza o unitizador anterior para status '2=Aguard. Ender' caso o mesmo tenha algum item
			If oMntUniItem:oUnitiz:GetStatus() <> '3' .And. oMntUniItem:oUnitiz:UniHasItem()
				oMntUniItem:oUnitiz:SetStatus("2") // Aguardando Endereçamento
				If !oMntUniItem:oUnitiz:UpdStatus()
					WMSVTAviso(WMSV08418, oMntUniItem:oUnitiz:GetErro()) // Erro do objeto
				EndIf
			EndIf
			oMntUniItem:SetIdUnit(cUnitAux)
		EndIf

		// Salva no auxiliar para não sobrepor a variável
		cUnitiz := cUnitAux

		oMntUniItem:oUnitiz:SetStatus("1") // Em Montagem
		If !oMntUniItem:oUnitiz:UniHasItem()
			oMntUniItem:oUnitiz:SetTipUni(cTipUni)
			oMntUniItem:oUnitiz:SetDatIni(dDataBase)
			oMntUniItem:oUnitiz:SetHorIni(Time())
		Else
			// Caso seja alterado para um unitizador que estava com status '2=Aguard. Ender', retorna para status '1=Em Montagem'
			If !oMntUniItem:oUnitiz:UpdStatus()
				WMSVTAviso(WMSV08418, oMntUniItem:oUnitiz:GetErro()) // Erro do objeto
			EndIf
		EndIf
		oMntUniItem:oUnitiz:SetDatFim(StoD(""))
		oMntUniItem:oUnitiz:SetHorFim("")
		If !lNewUnit
			VTKeyBoard(Chr(27)) // Força um ESC para voltar o inicio do produto
			lNewUnit := .T.
		EndIf
	EndIf
	// PE que permite automatizar a montagem dos unitizadores
	If lRet .And. __WV084AUT
		lRet := GerUniAuto(cTipUni,cUnitiz)
	EndIf
	// Restaura Tecla
	VTSetKey(06,bKey06, cKey06)
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(21,bKey21, cKey21)
Return lRet
//----------------------------------------------------------------------------------
Static Function ShowItens(cUnitiz)
Local cKey06   := VtDescKey(06)
Local cKey09   := VtDescKey(09)
Local cKey21   := VtDescKey(21)
Local bkey06   := VTSetKey(06) //Ctrl+F
Local bkey09   := VTSetKey(09) //Ctrl+I
Local bkey21   := VTSetKey(21) // Ctrl+U

	// Deve validar se o unitizador possui itens
	If !oMntUniItem:oUnitiz:UniHasItem()
		WMSVTAviso(WMSV08402, STR0018) // O unitizador não possui itens.
		lRet := .F.
	Else
	   WMSV084ITU(cUnitiz)
	EndIf
	// Restaura Tecla
	VTSetKey(06,bkey06, cKey06)
	VTSetKey(09,bkey09, cKey09)
	VTSetKey(21,bKey21, cKey21)
Return Nil
//----------------------------------------------------------------------------------
Function WMSV084ITU(cUnitiz)
Local aAreaAnt := GetArea()
Local aTela    := VTSave()
Local aTamSX3  := TamSx3('D0S_QUANT')
Local aCab     := {}
Local aSize    := {}
Local aPrdUni  := {}
Local cAliasQry:= Nil
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0S.D0S_CODPRO,
				D0S.D0S_LOTECT,
				D0S.D0S_NUMLOT,
				D0S.D0S_PRDORI,
				D0S.D0S_QUANT"
		FROM %Table:D0S% D0S
		WHERE D0S.D0S_FILIAL = %xFilial:D0S%
		AND D0S.D0S_IDUNIT = %Exp:cUnitiz%
		AND D0s.%NotDel%
		ORDER BY D0S.D0S_PRDORI,
					D0S.D0S_CODPRO,
					D0S.D0S_LOTECT,
					D0S.D0S_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		aAdd(aPrdUni,{(cAliasQry)->D0S_CODPRO,(cAliasQry)->D0S_LOTECT,(cAliasQry)->D0S_NUMLOT,(cAliasQry)->D0S_QUANT,(cAliasQry)->D0S_PRDORI})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	VTClear()
	aCab  := {RetTitle("D0S_CODPRO"),RetTitle("D0S_LOTECT"),RetTitle("D0S_NUMLOT"),RetTitle("D0S_QUANT"),RetTitle("D0S_PRDORI")}
	aSize := {TamSx3("D0S_CODPRO")[1],TamSx3("D0S_LOTECT")[1],TamSx3("D0S_NUMLOT")[1],TamSx3("D0S_QUANT")[1],TamSx3("D0S_PRDORI")[1]}
	WMSVTCabec(STR0035,.F.,.F.,.T.) // Itens Unitizador
	VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aPrdUni,aSize)

	VtRestore(,,,,aTela)
	RestArea(aAreaAnt)
Return Nil
//----------------------------------------------------------------------------------
Static Function EstUnitiz()
Local cKey06     := VTDescKey(06)
Local cKey09     := VTDescKey(09)
Local cKey21     := VTDescKey(21)
Local cKey24     := VTDescKey(24)
Local bKey06     := VTSetKey(06)
Local bKey09     := VTSetKey(09)
Local bKey21     := VTSetKey(21)
Local bKey24     := VTSetKey(24)
Local aTela      := VTSave()
Local cUnitiz    := ""
Local cCodBar    := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cSubLote   := ""
Local nQtde      := 0
Local nProxLin   := 1
Local lQtdDig    := .T.
Local aProdutos  := {}
Local lRet       := .T.
Local lEsc       := .F.
Local nOpcao     := 0
Local cIdUnitAnt := oMntUniItem:GetIdUnit()
Local cPrdOriAnt := oMntUniItem:GetPrdOri()
Local cProdutAnt := oMntUniItem:GetProduto()
Local cLoteCtAnt := oMntUniItem:GetLoteCtl()
Local cNumLotAnt := oMntUniItem:GetNumLote()
Local nQuantAnt  := oMntUniItem:GetQuant()
	// 01234567890123456789
	// 0 Estorno Mnt. Unitiz
	// 1 Unitizador: XXXXXX ou ID: XXXXXXXXXXXXXXXX
	// 2 Informe o Produto
	// 3 PRDWMS0001
	// 4 Lote: AUTO000000
	// 5 Sub-Lote: 000000
	// 6 Qtde
	// 7             9.999,99
	Do While lRet .And. !lEsc
		VTCLear()
		VTClearBuffer()

		cCodBar  := Space(128)
		cProduto := Space(TamSx3("D0S_CODPRO")[1])
		cLoteCtl := Space(TamSx3("D0S_LOTECT")[1])
		cSubLote := Space(TamSx3("D0S_NUMLOT")[1])
		cUnitiz  := Space(TamSx3("D0S_IDUNIT")[1])
		// Desativa a tecla de atalho de itens do unitizador
		VTSetKey(09)
		WMSVTCabec(STR0019, .F., .F., .T.) // Estorno Mnt. Unitiz
		@ 01,00 VTSay STR0007+"/"+STR0008 // Armazém/Endereço
		@ 02,00 VTSay oMntUniItem:oUnitiz:GetArmazem()+"/"+oMntUniItem:oUnitiz:GetEnder()
		@ 03,00 VtSay STR0016 // Informe o Unitiz.
		@ 04,00 VtGet cUnitiz Picture '@!' Valid VldIdUnit(cUnitiz,,.T.)
		VtRead()
		If VtLastKey() == 27
			lEsc := .T.
			Exit
		EndIf
		// Ativa a tecla de atalho de itens do unitizador
		VTSetKey(09,{|| ShowItens(cUnitiz)}, STR0010) // Ctrl+I // Itens Unitiz.
		// Deve questionar se deseja estornar o unitizador completo ou informar o item
		If (nOpcao := WMSVTAviso(STR0020,STR0021+":",{STR0022,STR0023})) == 1 //Atencao! Escolha o tipo de estorno: //Unitiz. Completo //Produto Unitiz.
			// Deve carregar as informações dos produtos a serem estornados
			// Carrega todos os produtos do unitizador
			aProdutos := {}
			VTMsg(STR0036+"...") // Processando
			If LoadPrdEst(aProdutos,nQtde,.T.)
				oMntUniItem:EstPrdUni(aProdutos,.T.)
			EndIf
			Loop
		EndIf
		// Se teclou ESC na pergunta
		If nOpcao == 0
			Loop
		EndIf

		VTCLear()
		nProxLin := 1
		WMSVTCabec(STR0019, .F., .F., .T.) // Estorno Mnt. Unitiz
		If Len(cUnitiz) == 6
			@ nProxLin++,00 VTSay PadR(STR0011 + ": " + cUnitiz,VTMaxCol()) // Unitizador
		ElseIf Len(cUnitiz) <= 16
			@ nProxLin++,00 VTSay PadR("ID: " + cUnitiz,VTMaxCol()) // Unitizador
		Else
			@ nProxLin++,00 VTSay PadR(cUnitiz,VTMaxCol()) // Unitizador
		EndIf
		@ nProxLin++,00 VTSay STR0012 // Informe o Produto
		@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid VldPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar,.T.)
		VtRead()

		If VTLastKey() != 27
			If Rastro(cProduto)
				@ nProxLin,   00 VTSay PadR(STR0013+":", VTMaxCol()) // Lote
				@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid VldLoteCtl(cLoteCtl,.T.)
				If Rastro(cProduto,"S")
					@ nProxLin,   00 VTSay PadR(STR0014+":", VTMaxCol()) // Sub-Lote
					@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid VldSubLote(cSubLote,.T.)
				EndIf
			EndIf

			Do While .T.
				lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
				@ nProxLin++,00 VTSay STR0015 // Qtde
				@ nProxLin++,00 VTGet nQtde Picture PesqPict("D0S","D0S_QUANT") When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
				VTRead()
				If VTLastKey() == 27
					lEsc := .T.
					Exit // Sai da rotina de estorno
				EndIf
				If !VldQtdSld(nQtde,.T.)
					nQtde    := 0
					nProxLin -= 2
					// Caso a quantidade não tenha sido digitada pelo usuário, volta para o produto
					If lQtdDig
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			If lEsc
				Exit
			EndIf
			aProdutos := {}
			VTMsg(STR0036+"...") // Processando
			If LoadPrdEst(aProdutos,nQtde,.F.)
				oMntUniItem:EstPrdUni(aProdutos,.F.)
			EndIf
		EndIf
	EndDo

	VTClearBuffer()
	oMntUniItem:SetIdUnit(cIdUnitAnt)
	// Caso o unitizador anterior não exista mais
	// Pode ocorrer caso o unitizador que esteja sendo montado foi o mesmo estornado
	If !oMntUniItem:oUnitiz:LoadData(3)
		lEndereca := .T. // Força para voltar ao código do unitizador
		oMntUniItem:SetIdUnit("")
		VTKeyBoard(Chr(27)) //-- Tecla ESC para sair do unitizador
	EndIf
	oMntUniItem:SetPrdOri(cPrdOriAnt)
	oMntUniItem:SetProduto(cProdutAnt)
	oMntUniItem:SetLoteCtl(cLoteCtAnt)
	oMntUniItem:SetNumLote(cNumLotAnt)
	oMntUniItem:SetQuant(nQuantAnt)
	VtRestore(,,,,aTela)
	VTSetKey(06,bKey06, cKey06)
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(21,bKey21, cKey21)
	VTSetKey(24,bKey24, cKey24)
Return
//----------------------------------------------------------------------------------
Static Function LoadPrdEst(aProdutos,nQtde,lTotal)
Local lRet      := .T.
Local lIsDad    := oMntUniItem:IsDad()
Local aAreaAnt  := GetArea()
Local aTamD0S   := TamSx3("D0S_QUANT")
Local cWhere    := ""
Local cCampos   := ""
Local cAliasQry := Nil
Local cCodAnt   := ""
Local nQtdPrd   := 0

Local nQtdAux   := nQtde
Local nPrdComp  := Len(oMntUniItem:GetArrProd())
Local nCount    := 0

Default nQtde  := 0
Default lTotal := .F.
	// Parâmetro Campos
	cCampos := "%"
	If WmsX312118("D13","D13_USACAL") .And. WmsX312118("D0S","D0S_IDMVUN")
		cCampos += "D0S.D0S_IDMVUN,"
	EndIf
	cCampos += "%"
	// Parâmetro Where
	cWhere := "%"
	If !Empty(oMntUniItem:GetLoteCtl())
		cWhere += " AND D0S.D0S_LOTECT = '"+oMntUniItem:GetLoteCtl()+"'"
	EndIf
	If !Empty(oMntUniItem:GetNumLote())
		cWhere += " AND D0S.D0S_NUMLOT = '"+oMntUniItem:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cAliasQry := GetNextAlias()
	If lIsDad
		If lTotal
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						%Exp:cCampos%
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT,
						D0S.D0S_IDD0Q,
						D11.D11_QTMULT
				FROM %Table:D0S% D0S
				// Adiciona a estrutura na query, pois foi informado o produto pai para estornar,
				// portanto é necessário multiplicar a quantidade informado pelo multiplo do filho
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D0S.D0S_FILIAL = %xFilial:D0S%
				AND D11.D11_PRODUT = D0S.D0S_PRDORI
				AND D11.D11_PRDORI = D0S.D0S_PRDORI
				AND D11.D11_PRDCMP = D0S.D0S_CODPRO
				AND D11.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:oMntUniItem:GetIdUnit()%
				AND D0S.%NotDel%
				ORDER BY D0S.D0S_CODPRO
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT,
						D0S.D0S_IDD0Q,
						D11.D11_QTMULT
				FROM %Table:D0S% D0S
				// Adiciona a estrutura na query, pois foi informado o produto pai para estornar,
				// portanto é necessário multiplicar a quantidade informado pelo multiplo do filho
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D0S.D0S_FILIAL = %xFilial:D0S%
				AND D11.D11_PRODUT = D0S.D0S_PRDORI
				AND D11.D11_PRDORI = D0S.D0S_PRDORI
				AND D11.D11_PRDCMP = D0S.D0S_CODPRO
				AND D11.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:oMntUniItem:GetIdUnit()%
				AND D0S.D0S_PRDORI = %Exp:oMntUniItem:GetPrdOri()%
				AND D0S.%NotDel%
				%Exp:cWhere%
				ORDER BY D0S.D0S_CODPRO
			
			EndSql
		EndIf
	Else
		If lTotal
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						%Exp:cCampos%
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT,
						D0S.D0S_IDD0Q
				FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:oMntUniItem:GetIdUnit()%
				AND D0S.%Notdel%
				ORDER BY D0S.D0S_CODPRO
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						%Exp:cCampos%
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT,
						D0S.D0S_IDD0Q
				FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:oMntUniItem:GetIdUnit()%
				AND D0S.D0S_PRDORI = %Exp:oMntUniItem:GetPrdOri()%
				AND D0S.D0S_CODPRO = %Exp:oMntUniItem:GetProduto()%
				AND D0S.%NotDel%
				%Exp:cWhere%
				ORDER BY D0S.D0S_CODPRO
			EndSql
		EndIf
	EndIf
	TcSetField(cAliasQry,"D0S_QUANT","N",aTamD0S[1],aTamD0S[2])
	Do While (cAliasQry)->(!Eof())
		If !(cCodAnt == (cAliasQry)->D0S_CODPRO)
			cCodAnt := (cAliasQry)->D0S_CODPRO
			nQtde := Iif(!lIsDad,nQtdAux,(nQtdAux * (cAliasQry)->D11_QTMULT))
			nCount++
		EndIf
		If (!lTotal .And. QtdComp(nQtde) == 0)
			(cAliasQry)->(dbSkip())
			Loop
		EndIf
		If lTotal
			nQtdPrd := (cAliasQry)->D0S_QUANT
		Else
			// Calcula a quantidade que pode ser "rateada" para este produto
			If QtdComp(nQtde) > QtdComp((cAliasQry)->D0S_QUANT)
				nQtdPrd := (cAliasQry)->D0S_QUANT
				nQtde   -= (cAliasQry)->D0S_QUANT
			Else
				nQtdPrd := nQtde
				nQtde   := 0
			EndIf
		EndIf
		// Adiciona o produto no array de produtos a serem colocados no unitizador
		If QtdComp(nQtdPrd) > 0
			aAdd(aProdutos, {;
						(cAliasQry)->D0S_CODPRO,;
						(cAliasQry)->D0S_LOTECT,;
						(cAliasQry)->D0S_NUMLOT,;
						nQtdPrd,;
						(cAliasQry)->D0S_PRDORI,;
						(cAliasQry)->D0S_IDD0Q,;
						IIf(WmsX312118("D13","D13_USACAL") .And. WmsX312118("D0S","D0S_IDMVUN"),(cAliasQry)->D0S_IDMVUN,"");
						})
		EndIf
		// Se não é produto componente e zerou a quantidade, deve sair
		If (!lTotal .And. QtdComp(nQtde) == 0) .And. (QtdComp(nCount) == QtdComp(nPrdComp))
			Exit
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function GerarOS(cUnitiz)
Local lRet := .T.
	If Empty(cUnitiz)
		Return .F.
	EndIf
	If !WmsQuestion(WmsFmtMsg(STR0037,{{"[VAR01]",oMntUniItem:GetIdUnit()}}),STR0006) // Confirma endereçamento do unitizador [VAR01]? // Montagem Unitizador
		lRet := .F.
	EndIf
	If lRet .And. oMntUniItem:oUnitiz:GetStatus() == "3"
		WMSVTAviso(WMSV08419, STR0040) // "A OS deste unitizador já foi gerada."
		lRet := .F.
	EndIf
	// Deve validar se o unitizador possui itens
	If lRet .And. !oMntUniItem:oUnitiz:UniHasItem()
		WMSVTAviso(WMSV08420, STR0038) // O unitizador não possui itens para o endereçamento.
		lRet := .F.
	EndIf
	If lRet
		lRet := WMSV086END({cUnitiz})
	EndIf
	// Se deu certo a geração da ordem de serviço limpa o unitizador
	If lRet
		lEndereca := .T.
		oMntUniItem:SetIdUnit("")
		oMntUniItem:oUnitiz:SetStatus("3")
		VTKeyBoard(Chr(27)) //-- Tecla ESC para sair do unitizador
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function VldArmazem(cArmazem)
Local lRet      := .T.
Local cAliasQry := Nil

	If Empty(cArmazem)
		Return .F.
	EndIf
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT NNR.NNR_AMZUNI
		FROM %Table:NNR% NNR
		WHERE NNR.NNR_FILIAL = %xFilial:NNR%
		AND NNR.NNR_CODIGO = %Exp:cArmazem%
		AND NNR.%NotDel%
	EndSql
	If (cAliasQry)->(Eof())
		WMSVTAviso(WMSV08403,STR0024) // Armazem inválido!
		lRet := .F.
	Else
		If (cAliasQry)->NNR_AMZUNI == "2"
			WMSVTAviso(WMSV08404,STR0025) // Armazem nao controla unitizacao!
			lRet := .F.
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function VldEndOrig(cArmazem,cEndereco)
Local lRet      := .T.
Local aAreaAnt  := {}
Local cEstFis   := ""
Local cAliasQry := Nil

	If Empty(cEndereco)
		Return .F.
	EndIf
	aAreaAnt := GetArea()
	If Empty(cEstFis := Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndereco,"BE_ESTFIS")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		WMSVTAviso(WMSV08405,STR0026) // Endereço inválido!
		lRet := .F.
	EndIf
	If lRet
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:D0Q% D0Q
			WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_LOCAL = %Exp:cArmazem%
			AND D0Q.D0Q_ENDER = %Exp:cEndereco%
			AND D0Q.D0Q_ORIGEM = %Exp:oMntUniItem:oUnitiz:GetOrigem()%
			// Deve existir demanda com status 'Pendente' ou 'Em Andamento'
			AND ( D0Q.D0Q_STATUS IN ('1','2')
				// Ou então existir demanda 'Finalizada' que possua Unitizador sem Ordem se Serviço gerada (status '2=Aguard. Ender'),
				// para deixar entrar na montagem e realizar algum estorno ou gerar a Ordem se Serviço.
				OR ( D0Q.D0Q_STATUS = '3' 
					AND EXISTS (SELECT 1 
								FROM %Table:D0S% D0S
								WHERE D0S.D0S_FILIAL = %xFilial:D0S%
								AND D0S.D0S_IDD0Q = D0Q.D0Q_ID
								AND EXISTS (SELECT 1 
											FROM %Table:D0R% D0R
											WHERE D0R.D0R_FILIAL = %xFilial:D0R%
											AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
											AND D0R.D0R_STATUS = '2'
											AND D0R.%NotDel% )
								AND D0S.%NotDel% )))
			AND D0Q.%NotDel%
		EndSql
		If (cAliasQry)->(Eof())
			WMSVTAviso(WMSV08406,WmsFmtMsg(STR0027,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco}})) // Não existe Demanda de Unitização 'Pendente' ou 'Em Andamento' para armazám [VAR01] e endereço [VAR02]!
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function VldIdUnit(cUnitiz,cTipUni,lEstorno)
Local lRet := .T.
	// Se possui o PE WV084AUT e a etiqueta não existe, gera automaticamente
	If __WV084AUT
		D0Y->(DbSetOrder(1))
		If !D0Y->(DbSeek(xFilial("D0Y")+cUnitiz))
			WmsGerUnit(.F.,.F.,.F.,cUnitiz,cTipUni)
		EndIf
	EndIf
	oMntUniItem:SetIdUnit(cUnitiz)
	If !(lRet := oMntUniItem:VldIdUnit(1,@cTipUni,lEstorno))
		oMntUniItem:SetIdUnit("")
		If !Empty(oMntUniItem:GetErro())
			WMSVTAviso(WMSV08407,oMntUniItem:GetErro()) // Erro do objeto
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function VldTipUni(cTipUni)
Local lRet := .T.
	oMntUniItem:oUnitiz:SetTipUni(cTipUni)
	If !(lRet := oMntUniItem:VldTipUni())
		If !Empty(oMntUniItem:GetErro())
			WMSVTAviso(WMSV08408,oMntUniItem:GetErro()) // Erro do objeto
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function VldQtdSld(nQtde,lEstorno)
Local lRet := .T.
	If !(lRet := oMntUniItem:VldQtdSld(nQtde,lEstorno))
		If !Empty(oMntUniItem:GetErro())
			WMSVTAviso(WMSV08409,oMntUniItem:GetErro()) // Erro do objeto
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function VldPrdLot(cProduto,cLoteCtl,cSubLote,nQtde,cCodBar,lEstorno)
Local lRet := .T.
Local aProduto := {}
Local nI := 0
Local cProdAnt := ""
Local cOrigAnt := ""
Default lEstorno := .F.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("D0S_CODPRO")[1])
	cLoteCtl := Space(TamSx3("D0S_LOTECT")[1])
	cSubLote := Space(TamSx3("D0S_NUMLOT")[1])
	nQtde    := 0
	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		If __lCBRETEAN
			nQtde := aProduto[2]
		EndIf
		cLoteCtl := Padr(aProduto[3],TamSx3("D0S_LOTECT")[1])
	Else
		aProduto := CBRetEti(cCodBar, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := aProduto[2]
			cLoteCtl := Padr(aProduto[16],TamSx3("D0S_LOTECT")[1])
			cSubLote := Padr(aProduto[17],TamSx3("D0S_NUMLOT")[1])
		EndIf
		If Empty(aProduto)
			WMSVTAviso(WMSV08410,STR0028) //Etiqueta invalida!
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Deve validar se o produto informado é um produto componente
		oMntUniItem:SetProduto(cProduto)
		oMntUniItem:SetLoteCtl(cLoteCtl)
		oMntUniItem:SetNumLote(cSubLote)
		// Seta o produto origem e faz a pergunta ao operador
		// caso necessário escolher entre produto ou partes
		oMntUniItem:VldPrdCmp(lEstorno)

		// Valida se o produto é apto a ser adicionado ao unitizador ou
		// se está contido no unitizador para realizar o estorno
		If !oMntUniItem:VldPrdUni(lEstorno)
			WMSVTAviso(WMSV08411,oMntUniItem:GetErro()) // Erro do objeto
			lRet := .F.
		EndIf
	EndIf

	If lRet
		cProdAnt := oMntUniItem:GetProduto()
		cOrigAnt := oMntUniItem:GetPrdOri()
		// Realiza a validação para todos os filhos do produto pai, caso informado
		aProduto := oMntUniItem:GetArrProd()
		For nI := 1 To Len(aProduto)
			oMntUniItem:SetProduto(aProduto[nI][1])
			oMntUniItem:SetPrdOri(aProduto[nI][3])

			oMntUniItem:QtdPrdUni(lEstorno)
			If !lEstorno
				//Deve validar se o produto possui quantidade em estoque no endereço
				If QtdComp(oMntUniItem:GetQuant()) == 0
					WMSVTAviso(WMSV08412,WmsFmtMsg(STR0029,{{"[VAR01]",oMntUniItem:GetProduto()}})) // Produto [VAR01] não possui saldo disponível para montagem de unitizador.
					lRet := .F.
					Exit
				EndIf
			Else
				//Deve validar se o produto possui quantidade para embalada para ser estornada
				If QtdComp(oMntUniItem:GetQuant()) == 0
					WMSVTAviso(WMSV08413,WmsFmtMsg(STR0030,{{"[VAR01]",oMntUniItem:GetProduto()}})) // Produto [VAR01] não possui quantidade no unitizador para estorno.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

		oMntUniItem:SetProduto(cProdAnt)
		oMntUniItem:SetPrdOri(cOrigAnt)
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
		cCodBar := Space(128)
	EndIf
Return lRet
//-----------------------------------------------------------------------------
// Valida o produto/lote informado, verificando se o mesmo possui saldo no endereço
// Valida se o mesmo já foi montado o unitizador e pode ser estornado unitizador
//-----------------------------------------------------------------------------
Static Function VldLoteCtl(cLoteCtl,lEstorno)
Local aProduto := {}
Local nI       := 0
Local lRet     := .T.
Local cProdAnt := ""
Local cOrigAnt := ""

Default lEstorno := .F.

	If Empty(cLoteCtl)
		Return .F.
	EndIf

	cProdAnt := oMntUniItem:GetProduto()
	cOrigAnt := oMntUniItem:GetPrdOri()

	oMntUniItem:SetLoteCtl(cLoteCtl)
	// Realiza a validação para todos os filhos do produto pai, caso informado
	aProduto := oMntUniItem:GetArrProd()
	For nI := 1 To Len(aProduto)
		oMntUniItem:SetProduto(aProduto[nI][1])
		oMntUniItem:SetPrdOri(aProduto[nI][3])
		// Carregar as quantidades para o produto
		oMntUniItem:QtdPrdUni(lEstorno)
		If !lEstorno
			//Deve validar se o produto/lote possui quantidade em estoque no endereço
			If QtdComp(oMntUniItem:GetQuant()) == 0
				WMSVTAviso(WMSV08414,WmsFmtMsg(STR0031,{{"[VAR01]",oMntUniItem:GetProduto()},{"[VAR02]",cLoteCtl}})) // Produto/Lote [VAR01]/[VAR02] não possui saldo disponível para montagem de unitizador.
				lRet := .F.
			EndIf
		Else
			//Deve validar se o produto possui quantidade para embalada para ser estornada
			If QtdComp(oMntUniItem:GetQuant()) == 0
				WMSVTAviso(WMSV08415,WmsFmtMsg(STR0032,{{"[VAR01]",oMntUniItem:GetProduto()},{"[VAR02]",cLoteCtl}})) // Produto/Lote [VAR01]/[VAR02] não possui quantidade no unitizador para estorno.
				lRet := .F.
			EndIf
		EndIf
	Next nI

	oMntUniItem:SetProduto(cProdAnt)
	oMntUniItem:SetPrdOri(cOrigAnt)

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo possui saldo no endereço
// Valida se o mesmo já foi montado unitizador e pode ser estornado unitizador
//-----------------------------------------------------------------------------
Static Function VldSubLote(cSubLote,lEstorno)
Local aProduto := {}
Local nI       := 0
Local lRet     := .T.
Local cProdAnt := ""
Local cOrigAnt := ""

Default lEstorno:= .F.

	If Empty(cSubLote)
		Return .F.
	EndIf

	cProdAnt := oMntUniItem:GetProduto()
	cOrigAnt := oMntUniItem:GetPrdOri()

	oMntUniItem:SetNumLote(cSubLote)
	// Realiza a validação para todos os filhos do produto pai, caso informado
	aProduto := oMntUniItem:GetArrProd()
	For nI := 1 To Len(aProduto)
		oMntUniItem:SetProduto(aProduto[nI][1])
		oMntUniItem:SetPrdOri(aProduto[nI][3])
		// Carregar as quantidades para o produto
		oMntUniItem:QtdPrdUni(lEstorno)
		If !lEstorno
			//Deve validar se o produto/lote possui quantidade em estoque no endereço
			If QtdComp(oMntUniItem:GetQuant()) == 0
				WMSVTAviso(WMSV08416,WmsFmtMsg(STR0033,{{"[VAR01]",oMntUniItem:GetProduto()},{"[VAR02]",cSubLote}})) // Produto/Rastro [VAR01]/[VAR02] não possui saldo disponível para montagem de unitizador.
				lRet := .F.
			EndIf
		Else
			//Deve validar se o produto possui quantidade para embalada para ser estornada
			If QtdComp(oMntUniItem:GetQuant()) == 0
				WMSVTAviso(WMSV08417,WmsFmtMsg(STR0034,{{"[VAR01]",oMntUniItem:GetProduto()},{"[VAR02]",cSubLote}})) // Produto/Rastro [VAR01]/[VAR02] não possui quantidade no unitizador para estorno.
				lRet := .F.
			EndIf
		EndIf
	Next nI

	oMntUniItem:SetProduto(cProdAnt)
	oMntUniItem:SetPrdOri(cOrigAnt)

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} GerUniAuto
Tratativas do PE que permite automatizar a montagem de unitizadores
@author  Guilherme A. Metzger
@version P12
@since   19/12/2018
/*/
//----------------------------------------------------------
Static Function GerUniAuto(cTipUni,cUnitiz)
Local cOrigem   := ""
Local cArmazem  := ""
Local cEndereco := ""
Local aTelaAux  := {}
Local nX        := 1
Local lRet      := .T.

	// Carrega as variáveis para facilitar a leitura
	cOrigem   := oMntUniItem:oUnitiz:GetOrigem()
	cArmazem  := oMntUniItem:oUnitiz:GetArmazem()
	cEndereco := oMntUniItem:oUnitiz:GetEnder()

	// Permite automatizar a montagem dos unitizadores
	__aItsUni := ExecBlock("WV084AUT",.F.,.F.,{cOrigem,cArmazem,cEndereco,cTipUni,cUnitiz})

	If ValType(__aItsUni) == "A" .And. Len(__aItsUni) > 0
		aTelaAux := VTSave()
		VTMsg(STR0036+"...") // Processando
		For nX := 1 To Len(__aItsUni)
			// Atribui as informações retornadas no objeto e efetiva no unitizador
			oMntUniItem:SetPrdOri(__aItsUni[nX,1])
			oMntUniItem:SetProduto(__aItsUni[nX,2])
			oMntUniItem:SetLoteCtl(__aItsUni[nX,3])
			oMntUniItem:SetNumLote(__aItsUni[nX,4])
			oMntUniItem:SetQuant(__aItsUni[nX,5])
			If !oMntUniItem:MntPrdUni()
				WMSVTAviso(WMSV08421,oMntUniItem:GetErro()) // Erro do objeto
				lRet := .F.
				Exit
			EndIf
		Next nX
		// Se tudo deu certo, gera a OS do unitizador
		If lRet
			lRet := GerarOS(cUnitiz)
		EndIf
		// Deve restaurar a tela para limpar a mensagem de processamento
		VtRestore(,,,,aTelaAux)
	Else
		__aItsUni := {}
	EndIf

Return lRet

/*/{Protheus.doc} MostraUnit
	(long_description)
	@type  Static Function
	@author roselaine.adriano
	@since 17/08/2023
	@version version
	@param cIdUnti - Codigo do unitizador */
	
Static Function MostraUnit(cIdUnit)
Local aAreaAnt := GetArea()
Local aTela    := VTSave()
Local lEsc     := .F.

	Do While !lEsc
		VTClear()
		WMSVTCabec(STR0006, .F., .F., .T.)   // Montagem unitizador
		@ 02,00 VTSay PadR(cIdUnit, VTMaxCol())
		If Len(cIdUnit) > 19
			@ 03,00 VTSay PadR(SubStr(cIdUnit,19+1,VTMaxCol()),VTMaxCol())
		ENDIF
		If Len(cIdUnit) > 38
			@ 04,00 VTSay PadR(SubStr(cIdUnit,38+1,VTMaxCol()),VTMaxCol())
		EndIF 
		WMSVTRodPe()
		If (VTLastKey()==27) .OR. (VTLastKey()==13)
			lEsc     := .T.
			EXIT
		EndIf
	EndDo
	VtRestore(,,,,aTela)	
	RestArea(aAreaAnt)
Return Nil
