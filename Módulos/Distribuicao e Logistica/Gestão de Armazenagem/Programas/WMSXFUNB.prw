#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNB.CH"
#define CLRF  Chr(13)+Chr(10)
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNB                                                           |
+---------+--------------------------------------------------------------------+
|Autor    | Jackson Patrick Werka                                              |
+---------+--------------------------------------------------------------------+
|Data     | 21/03/2014                                                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Esta função tem por objetivo reunir todas as informações relativas |
|         | a ordens de serviço no WMS, como criação, avaliação, exclusão,     |
|         | estorno, entre outras funcionalidades que estejam relacionadas com |
|         | as ordens de serviço WMS.                                          |
+---------+--------------------------------------------------------------------+

*/

Static lMntVol := SuperGetMV('MV_WMSVEMB',.F.,.F.)

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsTipServ(cServico)
Local aAreaAnt := GetArea()
Local aAreaDC5 := DC5->(GetArea())
Local cTipServ := ""

	DbSelectArea("DC5")
	DC5->(DbSetOrder(1))
	If DC5->(MsSeek(xFilial("DC5")+cServico))
		cTipServ := DC5->DC5_TIPO
	EndIf

RestArea(aAreaDC5)
RestArea(aAreaAnt)
Return cTipServ

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsPosDCF(cIdDCF)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDCF := ""
Local lRet      := .F.

DbSelectArea("DCF")
//-- Se o identificador da OS for diferente do posicionado
If !Empty(cIdDCF)
	If DCF->DCF_ID == cIdDCF
		lRet := .T.
	Else
		cAliasDCF := GetNextAlias()
		cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
		cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_ID     = '"+cIdDCF+"'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			DCF->(DbGoTo((cAliasDCF)->RECNODCF))
			lRet := .T.
		EndIf
		(cAliasDCF)->(DbCloseArea())
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsAvalDCF(cAcao,cIdDCF,lExibeMsg)
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local nWmsVlEP  := SuperGetMV("MV_WMSVLEP",.F.,1)   // Tratamento da OS WMS no estorno da liberação do pedido
Local cStatInte := SuperGetMV('MV_RFSTINT',.F.,'3') // DB_STATUS indincando Atividade Interrompida (Em execução)
Local lEstPed   := .F.

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

//-- Caso a DCF não esteja posicionada corretamente
If !Empty(cIdDCF)
	If !WmsPosDCF(cIdDCF)
		WmsMessage("SIGAWMS - "+STR0001+AllTrim(cIdDCF)+".","WmsAvalDCF",1,lExibeMsg) //"Não foi possível encontrar a OS pelo identificador "
		RestArea(aAreaAnt)
		Return lRet
	EndIf
EndIf

If cAcao == '1' //-- Alterar
	//-- Falta definir ainda
ElseIf cAcao == '2' //-- Excluir
	If !(lRet:=DCF->DCF_STSERV $ "1|2")
		If Type("lEstPedDAK")=='L'
			lEstPed := lEstPedDAK
		EndIf
		// Assume valor padrão caso o parâmetro tenha sido preenchido de forma inconsistente
		If nWmsVlEP < 1 .Or. nWmsVlEP > 3
			nWmsVlEP := 1
		EndIf
		// Se não estiver sendo chamado da rotina de geração das notas fiscais de saída
		If (IsInCallStack("Mata460a") .Or. (IsInCallStack("WmsAvalDAK") .And. lEstPed)) .And. nWmsVlEP <> 1
			//Verifica se alguma das atividades está em andamento pelo WMS
			If WmsChkSDB("1",,,"('"+cStatInte+"')")
				cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
				cMensagem += STR0020+CRLF // "Existem atividades em andamento para esta ordem de serviço."
				cMensagem += STR0021      // "Finalize as atividades ou estorne o processo WMS manualmente."
				WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
			Else
				// STR0019
				// Confirma o estorno da liberação do pedido sem estornar o processo WMS manualmente?
				// Em caso positivo, a ordem de serviço WMS será cancelada e o saldo dos produtos será
				// mantido na doca sem empenho, aguardando a sua utilização por outro pedido.
				If nWmsVlEP == 2 .Or. (nWmsVlEP == 3 .And. (!lWmsPergEP .Or. WmsMessage(STR0019,"WmsAvalDCF",3)))
					lRet       := .T.
					lWmsPergEP := .F. // Pegunta apenas uma vez
				EndIf
			EndIf
		Else
			//Verifica se a ordem de serviço possui serviço com execução automática
			If WmsVldSrv('4',DCF->DCF_SERVIC)
				//Verifica se alguma das atividades está em andamento ou finalizada pelo WMS
				lRet := !WmsChkSDB("1")
				If !lRet
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0002+CLRF //"Existem atividades em andamento ou finalizadas para esta"
					cMensagem += STR0003+CLRF //"ordem de serviço pelo processo WMS."
					cMensagem += STR0005 //"Deverá ser estornado o processo WMS manualmente."
					WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
				EndIf
			Else
				cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
				cMensagem += STR0004+CLRF //"A ordem de serviço já foi executada pelo processo WMS."
				cMensagem += STR0005 //"Deverá ser estornado o processo WMS manualmente."
				WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
			EndIf
		EndIf
	EndIf
ElseIf cAcao == '3' //-- Estornar
	If !(lRet:=DCF->DCF_STSERV $ '2|3')
		cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
		cMensagem += STR0006 //"A situação da OS não permite estorno."
		WmsMessage(cMensagem,"WmsAvalDCF",1,lExibeMsg)
	EndIf
EndIf

RestArea(aAreaAnt)
Return lRet

/*
+----------+----------+-------+------------------------------+------+----------+
|Função    |WmsCriaDCF| Autor |Jackson Patrick Werka         | Data |21.03.2014|
+----------+----------+-------+------------------------------+------+----------+
|Descrição |Gravar dados no Arquivo DCF                                        |
+----------+-------------------------------------------------------------------+
|Sintaxe   |WmsCriaDCF(ExpC1,ExpN1,ExpC2,ExpL1)                                |
+----------+-------------------------------------------------------------------+
|Parametros|ExpC1 = Alias Origem do Lancamento a ser gravado no DCF.           |
|          |        (DCF, SC9 ou SDA)                                     |
|          |        E necessario que o ponteiro deste alias esteja posicionado |
|          |        no registro correto.                                       |
|          |ExpN1 = Tipo de apanhe (1=Produto/2=Cliente).                      |
|          |ExpC2 = Codigo do servico a ser gerado.                            |
|          |        Se NAO for passado a funcao ira utilizar o servico         |
|          |        constante no respectivo campo de servico.                  |
|          |        Se passado, o sistema ira gerar um DCF utilizando o        |
|          |        servico passado. Se o servico passado estiver em           |
|          |        branco (diferente de NIL) o DCF sera gerado SEM            |
|          |        servico, devendo ser "definido" posteriormente pela        |
|          |        rotina de O.S. manual.                                     |
|          |ExpA1 = Vetor contendo dados para geração e execução da            |
|          |        O.S.WMS sem atualizar o estoque.                           |
|          |ExpN2 = Nr.do novo registro(DCF) gerado pela funcao, na            |
|          |        geracao e execucao da O.S.WMS sem atualizar estoque.       |
+----------+-------------------------------------------------------------------+
|Uso       | EST/PCP/FAT/COM/OMS/WMS                                           |
+----------+-------------------------------------------------------------------+*/
Function WmsCriaDCF(cAliasOrig, nTpApanhe, cServPad, aParam, nPosDCF )

Local aAreaAnt  := GetArea()
Local aAreaAux  := {}
Local aAreaDCF  := {}
Local cServico  := ''
Local cDoc      := ''
Local cSerie    := ''
Local cProduto  := ''
Local cCliFor   := ''
Local cLoja     := ''
Local cStServ   := ''
Local cOrigem   := ''
Local cNumSeq   := ''
Local cSequen   := ''
Local cArmazem  := ''
Local cEstrFis  := ''
Local cRegra    := ''
Local cEndere   := ''
Local cLoteCtl  := ''
Local cNumLote  := ''
Local cPriori   := ''
Local cCodFun   := ''
Local cCarga    := ''
Local cUnitiz   := ''
Local cNorma    := ''
Local cSeekSD1  := ''
Local cSeekSD3  := ''
Local dData     := CtoD('  /  /  ')
Local lRet      := IntWMS()
Local lRetPE    := .F.
Local nQuant    := 0
Local nQuant2UM := 0
Local cIdDCF    := 0
Local lInclusao := .T.
Local lA240Arm  := .F.
Local lA240End  := .F.
Local cLocDes   := ""

Default cAliasOrig := ''
Default nTpApanhe  := 2
Default cServPad   := Nil
Default aParam     := {}
Default nPosDCF    := 0

If lRet
	If cAliasOrig == 'SC9'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Pedido de Vendas Liberado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SC9')
		cServico := SC9->C9_SERVIC
		cDoc     := SC9->C9_PEDIDO
		cSerie   := SC9->C9_ITEM
		dData    := SC9->C9_DATALIB
		cProduto := SC9->C9_PRODUTO
		cStServ  := SC9->C9_STSERV
		nQuant   := SC9->C9_QTDLIB
		cOrigem  := 'SC9'
		cArmazem   := SC9->C9_LOCAL
		cRegra   := SC9->C9_REGWMS
		// Verifica informacoes de lote/sub-lote
		If Empty(cRegra) .And. !Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE)
			cRegra := "1"
		EndIf
		cLoteCtl := SC9->C9_LOTECTL
		cNumLote := SC9->C9_NUMLOTE
		cCarga   := SC9->C9_CARGA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posicionar o Cabecalho do Pedido (SC5)                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO, .F.))
			cCliFor := SC5->C5_CLIENTE
			cLoja   := SC5->C5_LOJACLI
		EndIf
		cEndere  := SC9->C9_ENDPAD
		If !Empty(aParam)
			cServico := aParam[1]
			nQuant   := aParam[2]
		EndIf
	ElseIf cAliasOrig == 'SDA'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Arquivo de Produtos a Distribuir (SDA)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SDA')
		cServico := '' //-- Utiliza dados do Arquivo Origem (DA_ORIGEM)
		cDoc     := SDA->DA_DOC
		cSerie   := SDA->DA_SERIE
		dData    := SDA->DA_DATA
		cProduto := SDA->DA_PRODUTO
		cCliFor  := SDA->DA_CLIFOR
		cLoja    := SDA->DA_LOJA
		cStServ  := '' //-- Utiliza dados do Arquivo Origem (DA_ORIGEM)
		nQuant   := (SDA->DA_SALDO-SDA->DA_EMPENHO)
		cOrigem  := SDA->DA_ORIGEM
		cNumSeq  := SDA->DA_NUMSEQ
		cArmazem := SDA->DA_LOCAL
		cRegra   := SDA->DA_REGWMS
		cLoteCtl := SDA->DA_LOTECTL
		cNumLote := SDA->DA_NUMLOTE

		If !Empty(aParam) .And. QtdComp(aParam[2]) > QtdComp(0)
			cServico := aParam[1]
			nQuant   := aParam[2]
			cEndere  := aParam[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define o codigo de Servico e o Status                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf cOrigem == 'SD1'
			DbSelectArea('SD1')
			aAreaAux := GetArea()
			SD1->(DbSetOrder(1)) //-- D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If SD1->(DbSeek(cSeekSD1:=xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cProduto, .F.))
				Do While SD1->(!Eof()) .And. cSeekSD1 == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD
					If cNumSeq == SD1->D1_NUMSEQ
						cServico := SD1->D1_SERVIC
						cStServ  := SD1->D1_STSERV
						cEndere  := SD1->D1_ENDER
						cNorma := SD1->D1_CODNOR
						Exit
					EndIf
					SD1->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SD2'
			If !(cServPad==Nil)
				cServico := cServPad
				cStServ  := '1'
			Else
				//-- Pesquisa Servico Padrao p/ Entradas ref. excl. Nota Fiscal de Saida
				SB5->(DbSetOrder(1))
				If SB5->(DbSeek(xFilial('SB5')+cProduto, .F.) .And. !Empty(B5_SERVENT))
					cServico   := SB5->B5_SERVENT
				Else
					cServPad := CriaVar('DCF_SERVIC')
				EndIf
				cStServ  := '1'
			EndIf
			// Se o processo de saída não é feito pelo WMS, o saldo de um mesmo produto é consumido de endereços diferentes e
			// na exclusao da NF de saída for selecionada a opção de redistribuir produtos, o sistema tentará gerar duas DCFs
			// com a mesma chave. Neste caso, deverá avaliar se já existe uma OS com a chave informada e apenas incrementá-la.
			If WmsChkDCF(cOrigem,,,cServico,'1',,cDoc,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,,@nPosDCF,'1')
				DCF->(DbGoTo(nPosDCF))
				lInclusao := .F.
			EndIf
		ElseIf cOrigem == 'SD3'
			lA240Arm := !(Type('cA240Arm') == 'U') .And. !Empty(cA240Arm)
			lA240End := !(Type('cA240End') == 'U') .And. !Empty(cA240End)
			DbSelectArea('SD3')
			aAreaAux := GetArea()
			SD3->(DbSetOrder(3))
			If DbSeek(cSeekSD3:=xFilial('SD3')+cProduto+cArmazem+cNumSeq, .F.)
				Do While SD3->(!Eof()) .And. cSeekSD3 == SD3->D3_FILIAL+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ
					If !Empty(SD3->D3_SERVIC)
						cServico := SD3->D3_SERVIC
						cStServ  := SD3->D3_STSERV
						cArmazem := SD3->D3_LOCAL
						cEndere  := SD3->D3_LOCALIZ
						//-- Recebe as variaveis de Endereco e Estrutura Fisica dos MATA240 e MATA241
						If lA240Arm
							cArmazem := cA240Arm
						EndIf
						If lA240End
							cEndere := cA240End
						EndIf
						Exit
					EndIf
					SD3->(DbSkip())
				EndDo
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SCM'
			DbSelectArea('SCM')
			aAreaAux := GetArea()
			SCM->(DbSetOrder(9))
			If SCM->(DbSeek(xFilial('SCM')+cDoc+cNumSeq, .F.))
				cServico := SCM->CM_SERVIC
				cStServ  := SCM->CM_STSERV
				cEndere  := SCM->CM_ENDER
			EndIf
			RestArea(aAreaAux)
		ElseIf cOrigem == 'SCN'
			DbSelectArea('SCN')
			aAreaAux := GetArea()
			SCN->(DbSetOrder(6))
			If SCN->(DbSeek(xFilial('SCN')+DtoS(dData)+cNumSeq, .F.))
				cServico := SCN->CN_SERVIC
				cStServ  := SCN->CN_STSERV
				cEndere  := SCN->CN_ENDER
			EndIf
			RestArea(aAreaAux)
		EndIf
	ElseIf cAliasOrig == 'SD1'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Arquivo de Nota Fiscal de Entrada (SD1)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SD1')
		cServico := SD1->D1_SERVIC
		cDoc     := SD1->D1_DOC
		cSerie   := SD1->D1_SERIE
		dData    := SD1->D1_DTDIGIT
		cProduto := SD1->D1_COD
		cCliFor  := SD1->D1_FORNECE
		cLoja    := SD1->D1_LOJA
		cStServ  := SD1->D1_STSERV
		nQuant   := SD1->D1_QUANT
		cOrigem  := 'SD1'
		cNumSeq  := SD1->D1_NUMSEQ
		cArmazem := SD1->D1_LOCAL
		cRegra   := SD1->D1_REGWMS
		cEndere  := SD1->D1_ENDER
		cLoteCtl := SD1->D1_LOTECTL
		cNumLote := SD1->D1_NUMLOTE
		cNorma := SD1->D1_CODNOR
	ElseIf cAliasOrig == 'SD3'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Arquivo de Movimentacoes Internas (SD3)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SD3')
		cServico := SD3->D3_SERVIC
		cDoc     := SD3->D3_DOC
		dData    := SD3->D3_EMISSAO
		cProduto := SD3->D3_COD
		cStServ  := SD3->D3_STSERV
		nQuant   := SD3->D3_QUANT
		cOrigem  := 'SD3'
		cNumSeq  := SD3->D3_NUMSEQ
		cArmazem := SD3->D3_LOCAL
		cRegra   := SD3->D3_REGWMS
		cEndere  := SD3->D3_LOCALIZ
		cLoteCtl := SD3->D3_LOTECTL
		cNumLote := SD3->D3_NUMLOTE
		//-- Recebe as variaveis de Endereco e Estrutura Fisica dos MATA240 e MATA241
		If !(Type('cA240Arm')=='U') .And. !Empty(cA240Arm)
			cArmazem := cA240Arm
		EndIf
		If !(Type('cA240End')=='U') .And. !Empty(cA240End)
			cEndere := cA240End
		EndIf
	ElseIf cAliasOrig == 'SDB'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Arquivo de Movimentacoes de Enderecamento (SDB)   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SDB')
		cServico := SDB->DB_SERVIC
		cDoc     := SDB->DB_DOC
		cSerie   := SDB->DB_SERIE
		dData    := SDB->DB_DATA
		cProduto := SDB->DB_PRODUTO
		cCliFor  := SDB->DB_CLIFOR
		cLoja    := SDB->DB_LOJA
		cStServ  := '1'
		nQuant   := SDB->DB_QUANT
		cOrigem  := 'SDB'
		cNumSeq  := SDB->DB_NUMSEQ
		cArmazem := SDB->DB_LOCAL
		cRegra   := SDB->DB_REGWMS
		cEndere  := SDB->DB_ENDDES
		cLoteCtl := SDB->DB_LOTECTL
		cNumLote := SDB->DB_NUMLOTE
		cCarga   := SDB->DB_CARGA
		cUnitiz  := SDB->DB_UNITIZ
	ElseIf cAliasOrig == 'SD2'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza os Dados do Arquivo de ITENS DA NOTA FISCAL DE SAIDA(SD2)     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea('SD2')
		cServico := SD2->D2_SERVIC
		cDoc     := SD2->D2_DOC
		cSerie   := SD2->D2_SERIE
		dData    := SD2->D2_EMISSAO
		cProduto := SD2->D2_COD
		cCliFor  := SD2->D2_CLIENTE
		cLoja    := SD2->D2_LOJA
		cStServ  := SD2->D2_STSERV
		nQuant   := SD2->D2_QUANT
		cOrigem  := 'SD2'
		cNumSeq  := SD2->D2_NUMSEQ
		cArmazem := SD2->D2_LOCAL
		cRegra   := SD2->D2_REGWMS
		cLoteCtl := SD2->D2_LOTECTL
		cNumLote := SD2->D2_NUMLOTE
		If cPaisLoc == "ARG"
			cLocDes := SD2->D2_LOCDEST
		EndIf
	ElseIf cAliasOrig == 'DCF' .Or. cAliasOrig == 'SD4'
		cProduto := aParam[01]
		cArmazem := aParam[02]
		cDoc     := aParam[03]
		cSerie   := aParam[04]
		cNumSeq  := aParam[05]
		nQuant   := aParam[06]
		dData    := aParam[07]
		cServico := aParam[09]
		cCliFor  := aParam[12]
		cLoja    := aParam[13]
		cOrigem  := aParam[17]
		cRegra   := aParam[22]
		cCarga   := aParam[23]
		cEndere  := aParam[26]
	EndIf
EndIf
If !Empty(cEndere)
	cEstrFis := Posicione('SBE',1,xFilial('SBE')+cArmazem+cEndere,'BE_ESTFIS')
Else
	cEstrFis := CriaVar('DCF_ESTFIS')
EndIf

lRet := (lRet.And.If(!(cServPad==Nil),.T.,!Empty(cServico))) //-- O Servico (ou Servico Padrao) deve estar preenchido
lRet := (lRet.And.QtdComp(nQuant)>QtdComp(0)) //-- Deve haver Quantidade maior que ZERO

If ExistBlock('DLANTDCF')
	lRet := If(ValType(lRetPE:=ExecBlock('DLANTDCF',.F.,.F.,{cAliasOrig, cOrigem, cServico, cDoc, cSerie, cCliFor, cLoja, cProduto, cArmazem, cNumSeq}))=='L',lRetPE,lRet)
	//-- Parametros do Ponto de Entrada DLANTDCF
	//-- aParam[01] = C, 03, ##, Alias do Arquivo que disparou a Execucao do Servico
	//-- aParam[02] = C, 03, ##, Alias do Arquivo onde o Servico esta gravado
	//-- aParam[03] = C, 06, ##, Servico
	//-- aParam[04] = C, 06, ##, Documento
	//-- aParam[05] = C, 03, ##, Serie
	//-- aParam[06] = C, 06, ##, Cliente/Fornecedor
	//-- aParam[07] = C, 02, ##, Loja
	//-- aParam[08] = C, 15, ##, Produto
	//-- aParam[09] = C, 02, ##, Armazem
	//-- aParam[10] = C, 06, ##, Numero Sequencial
EndIf

If lRet
	cServico := If(!(cServPad==Nil),cServPad,cServico)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Gravacao do Servico no DCF                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DbSelectArea('DCF')
	aAreaDCF := GetArea()
	//-- Adequacao ao tamanho das variaveis com o tamanho dos campos do DCF
	cServico := PadR(cServico, Len(DCF->DCF_SERVIC))
	cDoc     := PadR(cDoc    , Len(DCF->DCF_DOCTO))
	cSerie   := PadR(cSerie  , Len(DCF->DCF_SERIE))
	cCliFor  := PadR(cCliFor , Len(DCF->DCF_CLIFOR))
	cLoja    := PadR(cLoja   , Len(DCF->DCF_LOJA))
	cProduto := PadR(cProduto, Len(DCF->DCF_CODPRO))
	cOrigem  := PadR(cOrigem , Len(DCF->DCF_ORIGEM))
	cNumSeq  := PadR(cNumSeq , Len(DCF->DCF_NUMSEQ))
	cArmazem := PadR(cArmazem, Len(DCF->DCF_LOCAL))
	cEstrFis := PadR(cEstrFis, Len(DCF->DCF_ESTFIS))
	cRegra   := PadR(cRegra  , Len(DCF->DCF_REGRA))
	cEndere  := PadR(cEndere , Len(DCF->DCF_ENDER))
	cLoteCtl := PadR(cLoteCtl, Len(DCF->DCF_LOTECT))
	cNumLote := PadR(cNumLote, Len(DCF->DCF_NUMLOT))
	cPriori  := PadR(cPriori , Len(DCF->DCF_PRIORI))
	cCodFun  := PadR(cCodFun , Len(DCF->DCF_CODFUN))
	cCarga   := PadR(cCarga  , Len(DCF->DCF_CARGA))
	cUnitiz  := PadR(cUnitiz , Len(DCF->DCF_UNITIZ))
	cNorma   := PadR(cNorma  , Len(DCF->DCF_CODNOR))

	If cPaisLoc == "ARG"
		If !Empty(cLocDes)
			cLocDes := PadR(cLocDes, Len(DCF->DCF_LOCDES))
		EndIf
	EndIf
	Begin Transaction
		nQuant2UM := ConvUm(cProduto,nQuant,0,2)
		cIdDCF    := WMSProxSeq("MV_DOCSEQ","DCF_ID")
		If Empty(cNumSeq)
			cNumSeq := WMSProxSeq("MV_DOCSEQ","DCF_NUMSEQ")
		EndIf
		RecLock('DCF', lInclusao)
		If lInclusao
			DCF->DCF_FILIAL := xFilial('DCF')
			DCF->DCF_SERVIC := cServico
			DCF->DCF_DOCTO  := cDoc
			DCF->DCF_SERIE  := cSerie
			DCF->DCF_CLIFOR := cCliFor
			DCF->DCF_LOJA   := cLoja
			DCF->DCF_CODPRO := cProduto
			DCF->DCF_DATA   := dData
			DCF->DCF_STSERV := '1'
			DCF->DCF_QUANT  := nQuant
			DCF->DCF_QTSEUM := nQuant2UM
			DCF->DCF_ORIGEM := cOrigem
			DCF->DCF_NUMSEQ := cNumSeq
			DCF->DCF_LOCAL  := cArmazem
			DCF->DCF_ESTFIS := cEstrFis
			DCF->DCF_REGRA  := cRegra
			DCF->DCF_ENDER  := cEndere
			DCF->DCF_LOTECT := cLoteCtl
			DCF->DCF_NUMLOT := cNumLote
			DCF->DCF_PRIORI := cPriori
			DCF->DCF_CODFUN := cCodFun
			DCF->DCF_CARGA  := cCarga
			DCF->DCF_UNITIZ := cUnitiz
			DCF->DCF_CODNOR := cNorma
			DCF->DCF_STRADI := Iif(cOrigem == 'DCF',Replicate('0',Len(DCF->DCF_SERVIC)),Space(Len(DCF->DCF_SERVIC)))
			DCF->DCF_ID     := cIdDCF

			If cPaisLoc == "ARG"
				If !Empty(cLocDes)
					DCF->DCF_LOCDES := cLocDes
				Else
					DCF->DCF_LOCDES := cArmazem
				EndIf
				DCF->DCF_PRDORI := cProduto
			EndIf
		Else
			// Deve atribuir e não incrementar porque no caso de SDA com origem em SD2
			// a WMSCriaDCF é chamada diversas vezes, mas sempre com o valor atualizado.
			DCF->DCF_QUANT  := nQuant
			DCF->DCF_QTSEUM := nQuant2UM
		EndIf
		DCF->(MsUnLock())

		//Grava IDDCF na SDA
		If cAliasOrig == 'SDA'
			RecLock('SDA', .F.)
			SDA->DA_IDDCF := DCF->DCF_ID
			MsUnLock()
		EndIf
		//Grava IDDCF na SC9
		If cAliasOrig == 'SC9'
			RecLock('SC9', .F.)
			SC9->C9_STSERV := DCF->DCF_STSERV
			SC9->C9_IDDCF  := DCF->DCF_ID
			MsUnLock()
		EndIf
	End Transaction
	//-- Garante que o DCF ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
	nPosDCF := DCF->(Recno())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada DLATUDCF apos as gravacoes                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('DLATUDCF')
		ExecBlock('DLATUDCF',.F.,.F.,{cAliasOrig, cOrigem, cServico, cDoc, cSerie, cCliFor, cLoja, cProduto, cArmazem, cNumSeq, nQuant})
		//-- Parametros do Ponto de Entrada DLATUDCF
		//-- aParam[01] = C, 03, ##, Alias do Arquivo que disparou a Execucao do Servico
		//-- aParam[02] = C, 03, ##, Alias do Arquivo onde o Servico esta gravado
		//-- aParam[03] = C, 06, ##, Servico
		//-- aParam[04] = C, 06, ##, Documento
		//-- aParam[05] = C, 03, ##, Serie
		//-- aParam[06] = C, 06, ##, Cliente/Fornecedor
		//-- aParam[07] = C, 02, ##, Loja
		//-- aParam[08] = C, 15, ##, Produto
		//-- aParam[09] = C, 02, ##, Armazem
		//-- aParam[10] = C, 06, ##, Numero Sequencial
		//-- aParam[11] = N,   , ##, Quantidade
	EndIf
	RestArea(aAreaDCF)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna a Integridade do Sistema                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
Estorna todas as DCFs , inclusive as DCFs origem
------------------------------------------------------------------------------*/
Function WmsEstAll(cAcao,lEstSrvAut,aDocOri,lExibeMsg)
Static lDLGA150D := ExistBlock('DLGA150D')
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local lRet       := .T.
Local lRetPE     := .F.
Local lDocOri    := .F.
Local lDelDoc    := .F.
Local nCntFor    := 0
Default cAcao     := '1'
Default lExibeMsg := WmsMsgExibe()

If cAcao == '1'

	If !(lRet := WmsAvalDCF('3',/*cIdDCF*/,lExibeMsg))
		RestArea(aAreaAnt)
		Return lRet
	EndIf

	lDocOri  := WmsDocOri('1') //-- Verifica se habilita estorno dos itens do dcf com referencia ao documento original
	If lDocOri .And. Empty(DCF->DCF_DOCORI)
		lDelDoc := .T.
	EndIf
	//-- Ponto de Entrada DLGA150D (Antes do Estorno do Servico)
	//-- Parametros Passados:
	//-- PARAMIXB[1] = Produto
	//-- PARAMIXB[2] = Local
	//-- PARAMIXB[3] = Documento
	//-- PARAMIXB[4] = Serie
	//-- PARAMIXB[5] = Recno no DCF
	If lDLGA150D
		lRetPE := ExecBlock('DLGA150D', .F., .F., {DCF->DCF_CODPRO, DCF->DCF_LOCAL, DCF->DCF_DOCTO, DCF->DCF_SERIE, DCF->(Recno())})
		If ValType(lRetPE)=='L'
			lRet := lRetPE
		EndIf
	EndIf

	If lRet
		lRet := WmsEstDCF(/*cIdDCF*/,lExibeMsg)
		DCF->(RestArea(aAreaDCF)) // Restaura a área anterior DCF
		If lRet .And. lEstSrvAut
			If lDelDoc
				If WmsCarga(DCF->DCF_CARGA)
					If aScan(aDocOri,{|x|x[3]==DCF->DCF_CARGA})==0
						AAdd(aDocOri,{'','',DCF->DCF_CARGA})
					EndIf
				Else
					If aScan(aDocOri,{|x|x[1]+x[2]==DCF->DCF_DOCTO+DCF->DCF_SERIE})==0
						AAdd(aDocOri,{DCF->DCF_DOCTO,DCF->DCF_SERIE,''})
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf cAcao == '2'
	For nCntFor := 1 To Len(aDocOri)
		//-- Estorna todos os documentos com referencia a carga ou documento original
		lRet := WmsEstOri(aDocOri[nCntFor,3],aDocOri[nCntFor,1],aDocOri[nCntFor,2])
		If !lRet
			Exit
		EndIf
	Next
EndIf

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsEstDCF(cIdDCF,lExibeMsg)
Static lDLA220E := ExistBlock("DLA220E")
Local aAreaAnt   := GetArea()
Local aAreaDCF   := {}
Local aAreaSDB   := {}
Local cQuery     := ""
Local cAliasSDB  := ""
Local cAliasSD3  := ""
Local cAliasQry  := ""
Local cAliasSDD  := ""
Local dDataFec   := DToS(WmsData())
Local cTipServ   := ""
Local aCusto     := {}
Local aCM        := {}
Local dDtValid   := CtoD('  /  /  ')
Local cSeekSB8   := ""
Local cSeekSD1   := ""
Local cSeekSD3   := ""
Local cNumSD1    := ""
Local cNumero    := ""
Local lCQ        := .F.
Local lAchouD1   := .F.
Local nEmpenho   := 0
Local nEmpenho2  := 0
Local nBaixa     := 0
Local nBaixa2    := 0
Local nQtde      := 0
Local nRegOrigD3 := 0
Local nRegDestD3 := 0
Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local nTipoRegra := 3
Local xRegra     := CtoD('  /  /  ')
Local cFunExe    := ""
Local lRet       := .T.
Local cLocalCQ   := SuperGetMV('MV_CQ', .F., '98')

Private aParam150  := Array(34)
Private lWmsMovPkg := .F.

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

	cTipServ := WmsTipServ(DCF->DCF_SERVIC)

	Begin Transaction

	If DCF->DCF_ORIGEM == "SC9"
		// Estorna Mont. de Volumes e Conf. Expedição
		WMSEstVlCf()
		// Estorna liberação de pedidos
		nTipoRegra := Iif(Empty(DCF->DCF_REGRA),nTipoRegra,Val(DCF->DCF_REGRA))
		xRegra     := Iif(nTipoRegra==1,IIF(FwIsInCallStack("WMSA332"),SDB->DB_LOTECTL,DCF->DCF_LOTECT),xRegra)//MV_WMSALOTE, permite alterar lote, mas nao atualiza DCF. Via WMSA332, SDB possui o novo lote.
		lRet := WmsEstSC9(DCF->DCF_CARGA,DCF->DCF_DOCTO,DCF->DCF_SERIE,DCF->DCF_CODPRO,DCF->DCF_SERVIC,DCF->DCF_QUANT,DCF->DCF_QTSEUM,DCF->DCF_LOCAL,DCF->DCF_ENDER,DCF->DCF_ID,nTipoRegra,xRegra)
	EndIf

	If lRet
		//-- Estornando as movimentações de estoque
		cAliasSDB := GetNextAlias()
		cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB, SDB.DB_ESTORNO, SDB.DB_DATA, SDB.DB_ATUEST ATUEST"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
		cQuery +=   " AND SDB.DB_IDDCF   = '"+DCF->DCF_ID+"'"
		cQuery +=   " AND SDB.DB_TM     <= '500'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery += " UNION ALL "
		cQuery += "SELECT SDB.R_E_C_N_O_ RECNOSDB, SDB.DB_ESTORNO, SDB.DB_DATA, SDB.DB_ATUEST ATUEST"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND EXISTS (SELECT 1 "
		cQuery +=                 " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=                " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=                  " AND DCR.DCR_IDDCF  = '"+DCF->DCF_ID+"'"
		cQuery +=                  " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
		cQuery +=                  " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
		cQuery +=                  " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
		cQuery +=                  " AND DCR.D_E_L_E_T_ = ' ')"
		cQuery +=   " ORDER BY ATUEST DESC "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)

		While (cAliasSDB)->(!Eof())
			SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
			If SDB->DB_ATUEST == 'N'
				//-- Estorna somente movimentações de RF
				DbSelectArea('DCR')
				If DCR->(DbSeek(xFilial("DCR")+SDB->DB_IDDCF+DCF->DCF_ID+SDB->DB_IDMOVTO+SDB->DB_IDOPERA,.F.))
					RecLock('SDB',.F.)
					If QtdComp(SDB->DB_QUANT - DCR->DCR_QUANT) == QtdComp(0)
						SDB->DB_ESTORNO := 'S'
					Else
						SDB->DB_QUANT   := SDB->DB_QUANT   - DCR->DCR_QUANT
						SDB->DB_QTSEGUM := SDB->DB_QTSEGUM - DCR->DCR_QTSEUM
					EndIf
					SDB->(MsUnlock())
					//-- Elimina registro da DCR
					RecLock("DCR",.F.)
					DCR->(DbDelete())
					DCR->(MsUnlock())
				Else
					lRet := .F.
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0007+CLRF //"Não foi possível encontrar a movimentação relacionada (DCR)."
					cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
					cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO
					WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
					Exit
				EndIf
			Else
				If DtoS(SDB->DB_DATA) > dDataFec
					If GetVersao(.F.) >= '12' .AND. DCF->DCF_ORIGEM == 'SD4'
						WmsAtuSD4(SDB->DB_LOCAL,SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,,SDB->DB_LOCALIZ,SDB->DB_QUANT,SDB->DB_IDDCF,.T.)
					EndIf
					//Verifica a função executada pelo serviço/tarefa
					WmsFunExe('1',SDB->DB_SERVIC,SDB->DB_TAREFA,@cFunExe)
					//-- Estorna movimentações de estoque
					If cTipServ $ "2ú3" .And. !('DLTRANSFER' $ Upper(cFunExe))
						//-- Preenche array aParam150 a ser utilizado pela WmsMovEst
						aParam150[01] := SDB->DB_PRODUTO    //-- Produto
						aParam150[03] := SDB->DB_DOC        //-- Documento
						aParam150[04] := SDB->DB_SERIE      //-- Série
						aParam150[05] := SDB->DB_NUMSEQ     //-- Sequencial
						aParam150[08] := Time()             //-- Hora Inicio da Execucao de Servicos
						aParam150[09] := SDB->DB_SERVIC     //-- Servico
						aParam150[10] := SDB->DB_TAREFA     //-- Tarefa
						aParam150[11] := SDB->DB_ATIVID     //-- Atividade
						aParam150[17] := SDB->DB_ORIGEM     //-- Origem do Lancamento
						aParam150[23] := SDB->DB_CARGA      //-- Carga
						aParam150[24] := SDB->DB_UNITIZ     //-- Unitizador
						aParam150[28] := SDB->DB_ORDTARE    //-- Ordem da Tarefa
						aParam150[29] := SDB->DB_ORDATIV    //-- Ordem da Atividade
						aParam150[32] := SDB->DB_IDDCF   //-- Identificador do DCF
						aParam150[34] := SDB->DB_IDMOVTO //-- Identificador do SDB DB_IDMOVTO
						//-- Processa o destino para a origem
						aParam150[25] := SDB->DB_LOCAL
						aParam150[27] := SDB->DB_ESTFIS
						aParam150[26] := SDB->DB_LOCALIZ
						//-- Procura registro correspondente no SD3
						aAreaSDB := GetArea() //-- Salva a área anterior
						cAliasSD3 := GetNextAlias()
						cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
						cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
						cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"'"
						cQuery +=   " AND SD3.D3_NUMSEQ  = '"+SDB->DB_NUMSEQ+"'"
						cQuery +=   " AND SD3.D3_CHAVE   = 'E0'"
						cQuery +=   " AND SD3.D3_COD     = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SD3.D3_LOTECTL = '"+SDB->DB_LOTECTL+"'"
						cQuery +=   " AND SD3.D3_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
						cQuery +=   " AND SD3.D3_NUMSERI = '"+SDB->DB_NUMSERI+"'"
						cQuery +=   " AND SD3.D3_QUANT   = "+Str(SDB->DB_QUANT)
						cQuery +=   " AND SD3.D3_ESTORNO = ' '"
						cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
						If (cAliasSD3)->(!Eof())
							nRegOrigD3 := (cAliasSD3)->RECNOSD3
							SD3->(DbGoTo(nRegOrigD3))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0008+CLRF //"Não foi possível encontrar a movimentação origem (SD3)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasSD3)->(DbCloseArea())
						If !lRet
							Exit
						EndIf
						//-- Processa a origem para o destino
						cAliasQry := GetNextAlias()
						cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
						cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
						cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial('SDB')+"'"
						cQuery +=   " AND SDB.DB_PRODUTO = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SDB.DB_DOC     = '"+SDB->DB_DOC    +"'"
						cQuery +=   " AND SDB.DB_SERIE   = '"+SDB->DB_SERIE  +"'"
						cQuery +=   " AND SDB.DB_CLIFOR  = '"+SDB->DB_CLIFOR +"'"
						cQuery +=   " AND SDB.DB_LOJA    = '"+SDB->DB_LOJA   +"'"
						cQuery +=   " AND SDB.DB_SERVIC  = '"+SDB->DB_SERVIC +"'"
						cQuery +=   " AND SDB.DB_NUMSEQ  = '"+SDB->DB_NUMSEQ +"'"
						cQuery +=   " AND SDB.DB_IDDCF   = '"+SDB->DB_IDDCF  +"'"
						cQuery +=   " AND SDB.DB_IDMOVTO = '"+SDB->DB_IDMOVTO+"'"
						cQuery +=   " AND SDB.DB_TM      > '500'"
						cQuery +=   " AND SDB.DB_ESTORNO = ' '"
						cQuery +=   " AND SDB.DB_DATA    > '"+dDataFec+"'"
						cQuery +=   " AND SDB.DB_ATUEST  = 'S'"
						cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
						If (cAliasQry)->(!Eof())
							SDB->(DbGoTo((cAliasQry)->RECNOSDB))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0009+CLRF //"Não foi possível encontrar a movimentação origem (SDB)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasQry)->(DbCloseArea())
						If !lRet
							Exit
						EndIf

						aParam150[06] := SDB->DB_QUANT
						aParam150[18] := SDB->DB_LOTECTL
						aParam150[19] := SDB->DB_NUMLOTE
						aParam150[02] := SDB->DB_LOCAL
						aParam150[21] := SDB->DB_ESTFIS
						aParam150[20] := SDB->DB_LOCALIZ

						//-- Procura registro correspondente no SD3
						cAliasSD3 := GetNextAlias()
						cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
						cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
						cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"'"
						cQuery +=   " AND SD3.D3_NUMSEQ  = '"+SDB->DB_NUMSEQ+"'"
						cQuery +=   " AND SD3.D3_CHAVE   = 'E9'"
						cQuery +=   " AND SD3.D3_COD     = '"+SDB->DB_PRODUTO+"'"
						cQuery +=   " AND SD3.D3_LOTECTL = '"+SDB->DB_LOTECTL+"'"
						cQuery +=   " AND SD3.D3_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
						cQuery +=   " AND SD3.D3_NUMSERI = '"+SDB->DB_NUMSERI+"'"
						cQuery +=   " AND SD3.D3_QUANT   = "+Str(SDB->DB_QUANT)
						cQuery +=   " AND SD3.D3_ESTORNO = ' '"
						cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
						If (cAliasSD3)->(!Eof())
							nRegDestD3 := (cAliasSD3)->RECNOSD3
							SD3->(DbGoTo(nRegDestD3))
						Else
							lRet := .F.
							cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
							cMensagem += STR0010+CLRF //"Não foi possível encontrar a movimentação destino (SD3)."
							cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
							cMensagem += RetTitle("DB_NUMSEQ")+": "+SDB->DB_NUMSEQ
							WmsMessage(cMensagem,"WmsEstDCF",1,lExibeMsg)
						EndIf
						(cAliasSD3)->(DbCloseArea())
						If !lRet
							Exit
						EndIf
						//Se for movimentação saída e a origem foi um endereço de picking, marca para não validar capacidade
						If cTipServ == '2' .And. DLTipoEnd(SDB->DB_ESTFIS) == 2 //2=Picking
							lWmsMovPkg := .T.
						Else
							lWmsMovPkg := .F.
						EndIf

						RestArea(aAreaSDB) //-- Restaura a área anterior
						aAreaDCF := DCF->(GetArea()) //-- A função mata260 desposiciona a DCF, deve salvar a área anterior
						lRet := WmsMovEst(aParam150, .T. /*Estorno*/, nRegOrigD3, nRegDestD3, Val(cTipServ))
						If !lRet
							Exit
						EndIf
						DCF->(RestArea(aAreaDCF)) // Restaura a área anterior DCF
					ElseIf cTipServ == "1" .Or. (cTipServ == "3" .And. 'DLTRANSFER' $ Upper(cFunExe))
						If !VldEstEnt(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_LOCAL,SDB->DB_LOCALIZ,SDB->DB_PRODUTO,SDB->DB_NUMSERI,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_QUANT)
							lRet := .F.
							Exit
						EndIf
						//-- Atualiza SDB
						RecLock('SDB',.F.)
						Replace DB_ESTORNO WITH 'S'
						SDB->(MsUnlock())
						//-- Cria SDB de estorno
						CriaSDB(DB_PRODUTO,;             //Produto
								DB_LOCAL,;                 //Local
								DB_QUANT,;                 //Quantidade
								DB_LOCALIZ,;               //Localiza
								DB_NUMSERI,;               //Numero Serie
								DB_DOC,;                   //Documento
								DB_SERIE,;                 //Serie
								DB_CLIFOR,;                //Cliente-fornecedor
								DB_LOJA,;                  //Loja
								DB_TIPONF,;                //Tipo Nota-fiscal
								DB_ORIGEM,;                //Origem
								dDataBase,;                //Data
								DB_LOTECTL,;               //Lote
								DB_NUMLOTE,;               //Sub-lote
								DB_NUMSEQ,;                //Numero sequencial
								'501',;                    //TM
								'D',;                      //Tipo
								DB_ITEM,;                  //Item
								.T.,;                      //Flag Estorno
								If(DB_EMPENHO>0,DB_QUANT,0),; //Quantidade Empenho
								DB_QTSEGUM,;               //Quantidade 2 UM
								If(DB_EMPENHO>0,DB_QTSEGUM,0),;  //Quantidade Empenho 2 UM
								DB_ESTFIS,;                //Estrutura Fisica
								DB_SERVIC,;                //Servico
								DB_TAREFA,;                //Tarefa
								DB_ATIVID,;                //Atividade
								DB_ANOMAL,;                //Anomalia
								DB_ESTDES,;                //Estrutura Destino
								DB_ENDDES,;                //Endereco Destino
								Time(),;                   //Hora Inicio
								DB_ATUEST,;                //Flag Atualiza Estoque
								DB_CARGA,;                 //Carga
								DB_UNITIZ,;                //Unitiza
								DB_ORDTARE,;               //Ordem Tarefa
								DB_ORDATIV,;               //Ordem Atividade
								DB_RHFUNC,;                //Recurso Humano
								DB_RECFIS,;                //Recurso Fisico
								DB_SEQCAR,;                //Sequencia Carga
								DB_IDDCF,;                 //Identificador DCF
								Nil,;                      //
								DB_IDMOVTO)                //Identificador Movimento
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Soma saldo classificar no arquivo de saldos em estoque (SB2) ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea('SB2')
						dbSetOrder(1)
						If MsSeek(xFilial('SB2')+SDB->DB_PRODUTO+SDB->DB_LOCAL, .F.)
							RecLock('SB2', .F.)
							Replace B2_QACLASS With (B2_QACLASS+SDB->DB_QUANT)
							SB2->(MsUnlock())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Baixa saldo empenhado no arquivo de saldos por sub-lote (SB8)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Rastro(SDB->DB_PRODUTO)
							If Rastro(SDB->DB_PRODUTO, 'S')
								dbSelectArea('SB8')
								dbSetOrder(3)
								If MsSeek(xFilial('SB8')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE, .F.)
									RecLock('SB8', .F.)
									Replace B8_QACLASS With (B8_QACLASS+SDB->DB_QUANT)
									Replace B8_QACLAS2 With (B8_QACLAS2+SDB->DB_QTSEGUM)
									SB8->(MsUnlock())
								EndIf
							Else
								nEmpenho  := SDB->DB_QUANT
								nEmpenho2 := SDB->DB_QTSEGUM
								dbSelectArea('SB8')
								dbSetOrder(3)
								dbSelectArea('SD5')
								dbSetOrder(3)
								If MsSeek(cSeekSD5:=xFilial('SD5')+SDB->DB_NUMSEQ+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL, .F.)
									While SD5->(!Eof() .And. nEmpenho>0 .And. SD5->D5_FILIAL+SD5->D5_NUMSEQ+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL == cSeekSD5)
										dbSelectArea('SB8')
										If MsSeek(xFilial('SB8')+SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL+SD5->D5_NUMLOTE, .F.)
											nBaixa  := Min(SB8Saldo(,,,,,lEmpPrev), nEmpenho)
											nBaixa2 := Min(SB8Saldo(,,,.T.,,lEmpPrev), nEmpenho2)
											Reclock('SB8', .F.)
											Replace B8_QACLASS With (B8_QACLASS+nBaixa)
											Replace B8_QACLAS2 With (B8_QACLAS2+nBaixa2)
											SB8->(MsUnlock())
											nEmpenho  -= nBaixa
											nEmpenho2 -= nBaixa2
										EndIf
										dbSelectArea('SD5')
										DbSkip()
									EndDo
								EndIf
								dbSelectArea('SB8')
								dbSetOrder(3)
								If MsSeek(cSeekSB8:=xFilial('SB8')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL, .F.)
									While SB8->(!Eof() .And. nEmpenho>0 .And. SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL == cSeekSB8)
										nBaixa  := Min(SB8Saldo(,,,,,lEmpPrev), nEmpenho)
										nBaixa2 := Min(SB8Saldo(,,,.T.,,lEmpPrev), nEmpenho2)
										Reclock('SB8', .F.)
										Replace B8_QACLASS With (B8_QACLASS+nBaixa)
										Replace B8_QACLAS2 With (B8_QACLAS2+nBaixa2)
										SB8->(MsUnlock())
										nEmpenho  -= nBaixa
										nEmpenho2 -= nBaixa2
										SB8->(DbSkip())
									EndDo
								EndIf
							EndIf
							//-- Libera quantidade estornada da quarentena
							cAliasSDD  := GetNextAlias()
							cQuery := "SELECT SDD.R_E_C_N_O_ RECNOSDD"
							cQuery +=  " FROM "+RetSqlName('SDD')+" SDD "
							cQuery += " WHERE SDD.DD_FILIAL  = '"+xFilial('SDD')+"'"
							cQuery +=   " AND SDD.DD_DOC     = '"+SDB->DB_DOC+"'"
							cQuery +=   " AND SDD.DD_PRODUTO = '"+SDB->DB_PRODUTO+"'"
							cQuery +=   " AND SDD.DD_LOCAL   = '"+SDB->DB_LOCAL  +"'"
							cQuery +=   " AND SDD.DD_LOTECTL = '"+SDB->DB_LOTECTL+"'"
							cQuery +=   " AND SDD.DD_NUMLOTE = '"+SDB->DB_NUMLOTE+"'"
							cQuery +=   " AND SDD.DD_LOCALIZ = '"+SDB->DB_LOCALIZ+"'"
							cQuery +=   " AND SDD.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSDD,.F.,.T.)
							If (cAliasSDD)->(!Eof())
								SDD->(dbGoto((cAliasSDD)->RECNOSDD))
								If SDD->DD_SALDO > 0
									RecLock('SDD', .F. ) // Trava para gravacao
									SDD->DD_QUANT := SDB->DB_QUANT
									SDD->(MsUnlock())
									ProcSDD(.T.)
								EndIf
								//Realiza acerto na quantidade origem
								RecLock('SDD', .F. ) // Trava para gravacao
								SDD->DD_QTDORIG -= SDB->DB_QUANT
								SDD->(MsUnlock())

								If SDD->DD_SALDO <= 0 .AND. SDD->DD_SALDO2 <= 0 .AND. SDD->DD_QTDORIG <= 0
									RecLock('SDD', .F. ) // Trava para gravacao
									SDD->(DbDelete())
									SDD->(MsUnlock())
								EndIf
							EndIf
							(cAliasSDD)->(DbCloseArea())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se o Produto possui CQ                              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea('SD7')
						dbSetOrder(3)
						cNumero := Left(SDB->DB_DOC,Len(SD7->D7_NUMERO))
						If MsSeek(xFilial('SD7')+SDB->DB_PRODUTO+SDB->DB_NUMSEQ+cNumero, .F.)
							lCQ      := .T.
							cSeekSD1 := xFilial('SD1')+SD7->D7_PRODUTO+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA
						Else
							cSeekSD1 := xFilial('SD1')+SDB->DB_PRODUTO+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
						EndIf
						cNumSD1 := If(lCQ,'SD7->D7_NUMERO==SD1->D1_NUMCQ', 'SDB->DB_NUMSEQ==SD1->D1_NUMSEQ')
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Caso item da NF seja p/OP, grava o numero da OP na requisicao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea('SD1')
						dbSetOrder(2)
						MsSeek(cSeekSD1, .F.)
						If &cNumSD1 .And. !Empty(SD1->D1_OP) .And. !(SDB->DB_LOCAL == cLocalCQ)
							lAchouD1 := .T.
						EndIf
						If lAchouD1
							dbSelectArea('SB1')
							dbSetOrder(1)
							MsSeek(xFilial('SB1')+SDB->DB_PRODUTO, .F.)
							dbSelectArea('SD3')
							dbSetOrder(2)
							If MsSeek(cSeekSD3:=xFilial('SD3')+SDB->DB_DOC+SDB->DB_PRODUTO, .F.)
								Do While !Eof() .And. D3_FILIAL+D3_DOC+D3_PRODUTO == cSeekSD3
									If D3_CF=='RE5' .And. !Empty(D3_OP) .And. SDB->DB_NUMSEQ+SDB->DB_LOTECTL == D3_NUMSEQ+D3_LOTECTL .And. !(D3_ESTORNO=='S') .And. QtdComp(SDB->DB_QUANT)==QtdComp(D3_QUANT)
										RecLock('SD3', .F.) //-- Estorno do RE5
										Replace D3_ESTORNO With 'S'
										SD3->(MsUnlock())
										dDtValid := D3_DTVALID
										Exit
									EndIf
									DbSkip()
								EndDo
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Caso item da NF seja p/OP, grava o numero da OP na requisicao³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								RecLock('SD3', .T.)  //-- Cria DE5
								Replace D3_FILIAL  With xFilial('SD3')
								Replace D3_COD     With SDB->DB_PRODUTO
								Replace D3_QUANT   With SDB->DB_QUANT
								Replace D3_CF      With 'DE5'
								Replace D3_CHAVE   With 'E9'
								Replace D3_LOCAL   With SDB->DB_LOCAL
								Replace D3_DOC     With If(lCQ,SD7->D7_NUMERO,SDB->DB_DOC)
								Replace D3_EMISSAO With dDataBase
								Replace D3_UM      With SB1->B1_UM
								Replace D3_GRUPO   With SB1->B1_GRUPO
								Replace D3_NUMSEQ  With If(lCQ,SD7->D7_NUMSEQ,SDB->DB_NUMSEQ)
								Replace D3_QTSEGUM With If(lCQ,SD7->D7_QTSEGUM,SDB->DB_QTSEGUM)
								Replace D3_SEGUM   With SB1->B1_SEGUM
								Replace D3_TM      With '499'
								Replace D3_TIPO    With SB1->B1_TIPO
								Replace D3_CONTA   With SB1->B1_CONTA
								Replace D3_USUARIO With CUSERNAME
								Replace D3_OP      With SD1->D1_OP
								Replace D3_NUMLOTE With SDB->DB_NUMLOTE
								Replace D3_LOTECTL With SDB->DB_LOTECTL
								Replace D3_LOCALIZ With SDB->DB_LOCALIZ
								Replace D3_IDENT   With SDB->DB_NUMSEQ
								Replace D3_DTVALID With dDtValid
								Replace D3_ESTORNO With 'S'
								SD3->(MsUnlock())
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Array com os custos medios do produto                        ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aCM := If(If(lCQ,SD7->D7_ORIGLAN=='CP',SDB->DB_ORIGEM=='SD1'),PegaCMD1(),PegaCMD3())
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava o custo da movimentacao                                ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aCusto := GravaCusD3(aCM)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Estorna o Empenho do SD4                                     ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea('SD4')
								dbSetOrder(1)
								If MsSeek(xFilial('SD4')+SD1->D1_COD+SD1->D1_OP, .F.)
									nQtde := Min(D4_QUANT, SD1->D1_QUANT)
									RecLock('SD4',.F.)
									Replace D4_QUANT   With (D4_QUANT+nQtde)
									Replace D4_QTSEGUM With (D4_QTSEGUM+ConvUM(D4_COD, nQtde, 0, 2))
									SD4->(MsUnlock())
									dbSelectArea('SB2')
									dbSetOrder(1)
									If MsSeek(xFilial('SB2')+SD4->D4_COD+SD4->D4_LOCAL, .F.)
										nQtde := If(nQtde==NIL,SD1->D1_QUANT,nQtde)
										RecLock('SB2', .F.)
										Replace B2_QEMP  With (B2_QEMP+nQtde)
										Replace B2_QEMP2 With (B2_QEMP2+ConvUM(B2_COD, nQtde, 0, 2))
										SB2->(MsUnlock())
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza o saldo atual (VATU) com os dados do SD3            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								B2AtuComD3(aCusto)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Acerta custo da OP relacionada na NF de Entrada              ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								C2AtuComD3(aCusto)
								EndIf
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Soma saldo no arquivo de Saldos a classificar   (SDA)        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea('SDA')
						dbSetOrder(1)
						If MsSeek(xFilial('SDA')+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ, .F.)
							RecLock('SDA',.F.)
							Replace DA_SALDO   With (DA_SALDO+SDB->DB_QUANT)
							Replace DA_QTSEGUM With (DA_QTSEGUM+SDB->DB_QTSEGUM)
							Replace DA_EMPENHO With (DA_EMPENHO+SDB->DB_EMPENHO)
							Replace DA_EMP2    With (DA_EMP2+SDB->DB_EMP2)
							SDA->(MsUnlock())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Baixa Saldo no SBF baseado no movimento                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						GravaSBF('SDB')
					EndIf
				Else
					lRet := .F.
					cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
					cMensagem += STR0011 //"Existem movimentos com data anterior à data de fechamento de estoque."
					WmsMessage(cMensagem,"WmsEstDCF",0,lExibeMsg)
					Exit
				EndIf
			EndIf
			(cAliasSDB)->(DbSkip())
		EndDo
		(cAliasSDB)->(DbCloseArea())
	EndIf

	If lRet
		//-- Altera o Status para NAO EXECUTADO no DCF
		DLA150Stat('1')
		If lDLA220E
			ExecBlock("DLA220E",.F.,.F.)
		EndIf
	EndIf

	If !lRet
		DisarmTransaction()
	EndIf
	End Transaction

RestArea(aAreaAnt)
Return lRet

/*------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
Function WmsEstOri(cCarga,cDocto,cSerie,lExibeMsg)
Static lDLGA150D := ExistBlock("DLGA150D")
Local aAreaAnt := GetArea()
Local aAreaDCF := {}
Local cSeekDCF := ''
Local cCompDCF := ''
Local lRet     := .T.
Local lRetPE   := .F.

Default lExibeMsg := WmsMsgExibe()

	//-- Verifica se o processo eh por carga ou documento/serie
	If WmsCarga(cCarga)
		cCarga   := PadR(cCarga, Len(DCF->DCF_DOCORI))
		cSeekDCF := xFilial('DCF') + cCarga
		cCompDCF := "DCF_FILIAL+DCF_DOCORI"
	Else
		cDocto   := PadR(cDocto, Len(DCF->DCF_DOCORI))
		cSerie   := PadR(cSerie, Len(DCF->DCF_SERORI))
		cSeekDCF := xFilial('DCF') + cDocto + cSerie
		cCompDCF := "DCF_FILIAL+DCF_DOCORI+DCF_SERORI"
	EndIf

	//-- Estorna todos os documentos com referencia a carga ou documento original
	DCF->(DbSetOrder(7)) //DCF_FILIAL+DCF_DOCORI+DCF_SERORI
	DCF->(DbSeek(cSeekDCF))
	While lRet .And. DCF->(!Eof() .And. &cCompDCF==cSeekDCF)
		//-- Verifica status do servico
		If !WmsAvalDCF('3',,.F.)
			DCF->(DbSkip())
			Loop
		EndIf
		//-- Verifica se alguma atividade do serviço já foi executada
		If WmsChkSDB('4')
			DCF->(DbSkip())
			Loop
		EndIf
		//-- Ponto de Entrada DLGA150D (Antes do Estorno do Servico)
		//-- Parametros Passados:
		//-- PARAMIXB[1] = Produto
		//-- PARAMIXB[2] = Local
		//-- PARAMIXB[3] = Documento
		//-- PARAMIXB[4] = Serie
		//-- PARAMIXB[5] = Recno no DCF
		If lDLGA150D
			lRetPE := ExecBlock('DLGA150D', .F., .F., {DCF->DCF_CODPRO, DCF->DCF_LOCAL, DCF->DCF_DOCTO, DCF->DCF_SERIE, DCF->(Recno())})
			If ValType(lRetPE)=='L'
				lRet := lRetPE
			EndIf
		EndIf

		If lRet
			aAreaDCF := DCF->(GetArea()) // Guarda a área anterior da DCF
			lRet := WmsEstDCF(,lExibeMsg)
			DCF->(RestArea(aAreaDCF)) // Restaura a área anterior DCF
		EndIf

		If lRet
			//-- Estorna fisicamente a ordem de servico
			RecLock('DCF',.F.,.T.)
			DCF->(DbDelete())
			MsUnlock()
		EndIf
	EndDo

RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Atualiza campos endereço e estrutura física da tabela DCF quando informados
na Montagem de Carga ou Execução de Serviços
-----------------------------------------------------------------------------/*/
Function WmsEndDCF(cEndereco,lEndVazio)
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aArea      := GetArea()
Local oOrdServ   := Iif(lWmsNew,WMSDTCOrdemServico():New(),Nil)
Local cAliasQry  := GetNextAlias()

Default lEndVazio := .T. //-- Atualiza somente OS sem informação de endereço ou atualiza tudo

	If lEndVazio
		BeginSql Alias cAliasQry
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO = %Exp:SC9->C9_PEDIDO%
			AND DCF.DCF_SERIE = %Exp:SC9->C9_ITEM%
			AND DCF.DCF_CLIFOR = %Exp:SC9->C9_CLIENTE%
			AND DCF.DCF_LOJA = %Exp:SC9->C9_LOJA%
			AND DCF.DCF_CODPRO = %Exp:SC9->C9_PRODUTO%
			AND DCF.DCF_ORIGEM = 'SC9'
			AND DCF.DCF_STSERV IN ('1','2')
			AND DCF.DCF_ENDER  = ' '
			AND DCF.DCF_ESTFIS = ' '
			AND DCF.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO = %Exp:SC9->C9_PEDIDO%
			AND DCF.DCF_SERIE = %Exp:SC9->C9_ITEM%
			AND DCF.DCF_CLIFOR = %Exp:SC9->C9_CLIENTE%
			AND DCF.DCF_LOJA = %Exp:SC9->C9_LOJA%
			AND DCF.DCF_CODPRO = %Exp:SC9->C9_PRODUTO%
			AND DCF.DCF_ORIGEM = 'SC9'
			AND DCF.DCF_STSERV IN ('1','2')
			AND DCF.%NotDel%
		EndSql	
	EndIf
	Do While (cAliasQry)->(!Eof())
		If !lWmsNew
			DCF->(DbGoTo((cAliasQry)->RECNODCF))
			RecLock('DCF')
			DCF->DCF_ENDER  := cEndereco
			DCF->DCF_ESTFIS := Posicione('SBE',1,xFilial('SBE')+DCF->DCF_LOCAL+cEndereco,'BE_ESTFIS')
			MsUnlock()
		Else
			oOrdServ:GoToDCF((cAliasQry)->RECNODCF)
			oOrdServ:oOrdEndDes:SetEnder(cEndereco)
			oOrdServ:oOrdEndDes:LoadData()
			oOrdServ:UpdateDCF()
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsChkDCF ³ Autor ³ Alex Egydio            ³Data³29.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura uma ordem de servico no WMS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Alias do arquivo que gerou a O.S.WMS              ³±±
±±³          ³ ExpC02 - Carga                                             ³±±
±±³          ³ ExpC03 - Unitizador                                        ³±±
±±³          ³ ExpC04 - Servico                                           ³±±
±±³          ³ ExpC05 - Status da O.S.WMS a ser pesquisada                ³±±
±±³          ³ ExpN06 - Tipo de apanhe 1=Por Cliente / 2=Por Produto      ³±±
±±³          ³ ExpC07 - Documento                                         ³±±
±±³          ³ ExpC08 - Serie                                             ³±±
±±³          ³ ExpC09 - Cliente                                           ³±±
±±³          ³ ExpC10 - Loja                                              ³±±
±±³          ³ ExpC11 - Armazem                                           ³±±
±±³          ³ ExpC12 - Produto                                           ³±±
±±³          ³ ExpC13 - Lote                                              ³±±
±±³          ³ ExpC14 - Sub-Lote                                          ³±±
±±³          ³ ExpC15 - Sequencia                                         ³±±
±±³          ³ ExpC16 - Item                                              ³±±
±±³          ³ ExpN17 - Nr.do registro(DCF) encontrado pela funcao   (@)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ .T./.F. = O.S.WMS Encontrada/nao Encontrada                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function WmsChkDCF(cOrigem,cCarga,cUnitiz,cServico,cStServ,nTpApanhe,cDocto,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,cIdDCF,nPosDCF,cAcao,nQuant)
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cStatus   := "" //Utilizado para guardar o status no formato SQL
Local cAliasQry := "DCF"
Local cWhere    := ""
Local nX        := 0

Default cCarga   := ""
Default cUnitiz  := ""
Default cStServ  := ""
Default nTpApanhe:= 1
Default cSerie   := ""
Default cCliFor  := ""
Default cLoja    := ""
Default cLoteCtl := ""
Default cNumLote := ""
Default cNumSeq  := ""
Default nPosDCF  := 0
Default cAcao    := "1"
Default nQuant   := 0
Default cIdDCF   := ""
	
	//Transforma o Status no formato SQL
	If !Empty(cStServ)
		If At(cStServ,"'") > 0 //Se possui aspas simples deve estar no formato SQL
			cStatus = cStServ
		ElseIf Len(cStServ) == 1 //Se possui só um digito, coloca aspas no mesmo
			cStatus := "'"+cStServ+"'"
		Else
			//Vai quebrando as situações e colocando aspas
			For nX = 0 To Len(cStServ)
				If IsDigit(SubStr(cStServ,nX+1,1))
					If Len(cStatus) > 0
						cStatus += ",'"+SubStr(cStServ,nX+1,1)+"'"
					Else
						cStatus += "'"+SubStr(cStServ,nX+1,1)+"'"
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	
	If cAcao == "1"
		If !IntWMS(cProduto) .Or. (Empty(cServico) .And. cOrigem != "SD2")
			Return(.F.)
		EndIf
		// Parâmetro Where
		cWhere := "%"
		If !Empty(cNumSeq)
			cWhere += " AND DCF_NUMSEQ = '"+cNumSeq+"'"
		Else
			If !Empty(cIdDCF)
				cWhere += " AND DCF_ID = '"+cIdDCF+"'"
			EndIf
		EndIf
		If !Empty(cStatus)
			 cWhere += " AND DCF_STSERV IN ("+cStatus+")"
		EndIf
		cWhere += "%"
		cAliasQry := GetNextAlias()
		If WmsCarga(cCarga)
			BeginSql Alias cAliasQry
				SELECT DCF.R_E_C_N_O_ RECNODCF
				FROM %Table:DCF% DCF
				WHERE DCF_FILIAL = %xFilial:DCF%
				AND DCF_SERVIC = %Exp:cServico%
				AND DCF_LOCAL = %Exp:cArmazem%
				AND DCF_CODPRO = %Exp:cProduto%
				AND DCF_CARGA = %Exp:cCarga%
				AND DCF.%NotDel%
				%Exp:cWhere%
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT DCF.R_E_C_N_O_ RECNODCF
				FROM %Table:DCF% DCF
				WHERE DCF_FILIAL = %xFilial:DCF%
				AND DCF_SERVIC = %Exp:cServico%
				AND DCF_LOCAL = %Exp:cArmazem%
				AND DCF_CODPRO = %Exp:cProduto%
				AND DCF_DOCTO = %Exp:cDocto%
				AND DCF_SERIE = %Exp:cSerie%
				AND DCF_CLIFOR = %Exp:cCliFor%
				AND DCF_LOJA = %Exp:cLoja%
				AND DCF.%NotDel%
				%Exp:cWhere%
			EndSql
		EndIf
		If (cAliasQry)->(!Eof())
			Do While (cAliasQry)->(!Eof())
				DCF->(DbGoTo((cAliasQry)->RECNODCF))
				If Iif(!Empty(cLoteCtl) .And. !Empty(DCF->DCF_LOTECT),DCF->DCF_LOTECT == cLoteCtl,.T.) .And.;
					Iif(!Empty(cNumLote) .And. !Empty(DCF->DCF_NUMLOT),DCF->DCF_NUMLOT == cNumLote,.T.)
					//-- Garante que o dcf ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
					nPosDCF := DCF->(Recno())
					lRet := .T.
					Exit
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
		Else
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	ElseIf cAcao == "2"
		If !IntWMS(cProduto)
			Return(.F.)
		EndIf
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCF.R_E_C_N_O_ RECDCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_CODPRO = %Exp:cProduto%
			AND DCF.DCF_DOCTO = %Exp:cDocto%
			AND DCF.DCF_SERIE = %Exp:cSerie%
			AND DCF.DCF_CLIFOR = %Exp:cCliFor%
			AND DCF.DCF_LOJA = %Exp:cLoja%
			AND DCF.DCF_NUMSEQ = %Exp:cNumSeq%
			AND DCF.%NotDel%
			ORDER BY DCF_FILIAL,
						DCF_CODPRO,
						DCF_DOCTO,
						DCF_SERIE,
						DCF_CLIFOR,
						DCF_LOJA,
						DCF_NUMSEQ
		EndSql
		If (cAliasQry)->(!Eof())
			lRet := .T.
			DCF->(MsGoTo((cAliasQry)->RECDCF))
		EndIf
		If lRet
			//-- Garante que o dcf ficara posicionado no registro gerado, algumas rotinas recebem nposdcf como referencia
			nPosDCF := DCF->(Recno())
		EndIf
		(cAliasQry)->(DbCloseArea())
	ElseIf cAcao == "3"
		//-- Soma Saldos de Lotes/Sub-Lotes selecionados na liberacao do Pedido
		If IntWMS(cProduto) .And. !Empty(cLoteCtl+cNumLote)
			lRet := .T.
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DCF.DCF_QUANT
				FROM %Table:DCF% DCF
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_LOCAL = %Exp:cArmazem%
				AND DCF.DCF_CODPRO = %Exp:cProduto%
				AND DCF.DCF_LOTECT = %Exp:cLoteCtl%
				AND DCF.DCF_NUMLOT = %Exp:cNumLote%
				AND DCF.DCF_ORIGEM = %Exp:cOrigem%
				AND DCF.DCF_STSERV IN ('1','2')
				AND DCF.%NotDel%
			EndSql
			Do While (cAliasQry)->(!Eof())
				nQuant += (cAliasQry)->DCF_QUANT
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	ElseIf cAcao == "4"
		//-- Verifica se existem ordens de serviço executadas para o pedido
		cStatus := "%"+cStatus+"%"
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_DOCTO  = %Exp:cDocto%
			AND DCF.DCF_ORIGEM = %Exp:cOrigem%
			AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
			AND DCF.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			lRet := .T.
			//-- A mensagem só serve para quando a função é chamada para verificar se existe OS executada
			If cStServ == '3'
				WmsMessage(STR0012,"WmsChkDCF") //"Existem uma ou mais ordens de serviço executadas. Ao informar destino do Serviço WMS estas ordens de serviço não sofrerão alteração"
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf	
	RestArea(aAreaAnt)
Return(lRet)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WmsDelDCF| Autor ³ Alex Egydio                ³Data³23.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorno de movtos do wms, baseado nos campos _IDDCF          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - 1 = Acao tomada no faturamento                       ³±±
±±³          ³             Executado por MaAvalSC9 com evento 2 e 8         ³±±
±±³          ³         2 = Acao tomada no estorno do wms                    ³±±
±±³          ³             Executado por DLA220Esto                         ³±±
±±³          ³ ExpC2 - Select utilizada na funcao dla220esto                ³±±
±±³          ³ ExpA1 - Vetor contendo os registros do SC9                   ³±±
±±³          ³ ExpL1 - Flag que determina se ha empenhos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function WmsDelDCF(cAcao,cOrigem,cIdDCF,lExibeMsg)
Static lWMSXDCF  := ExistBlock("WMSXDCF")
Local aAreaAnt   := GetArea()
Local cServico   := ""
Local cCarga     := ""
Local cDocto     := ""
Local cSerie     := ""
Local cCliFor    := ""
Local cLoja      := ""
Local cArmazem   := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cNumSeq    := ""
Local cAliasSDB  := ""
Local cQuery     := ""
Local nQuant     := 0
Local nQtdDel    := 0
Local nQtdDel2UM := 0
Local nQtdDelDCF := 0
Local cSeekDCF   := ""
Local cIdMovto   := ""
Local lRet       := .F.
Local n1Cnt      := 0
Local nRecDCF    := 0
Local cMensagem  := ""
Local nWmsVlEP   := SuperGetMV("MV_WMSVLEP",.F.,1)   // Tratamento da OS WMS no estorno da liberação do pedido
Local lWmsVlEP   := nWmsVlEP > 1

Default cIdDCF    := ""
Default lExibeMsg := WmsMsgExibe()

	If cAcao == "1"
		//-- Se foi passado o ID DCF deve pesquisar por ele para encontrar o OS
		If !Empty(cIdDCF)
			If !WmsPosDCF(cIdDCF)
				WmsMessage("SIGAWMS - "+STR0001+AllTrim(cIdDCF)+".","WmsDelDCF",1,lExibeMsg) //"Não foi possível encontrar a OS pelo identificador "
				RestArea(aAreaAnt)
				Return .F.
			EndIf
			nQuant := DCF->DCF_QUANT
		Else
			If cOrigem == "SC9"
				cServico := SC9->C9_SERVIC
				cCarga   := SC9->C9_CARGA
				cDocto   := SC9->C9_PEDIDO
				cSerie   := SC9->C9_ITEM
				cCliFor  := SC9->C9_CLIENTE
				cLoja    := SC9->C9_LOJA
				cArmazem := SC9->C9_LOCAL
				cProduto := SC9->C9_PRODUTO
				cLoteCtl := SC9->C9_LOTECTL
				cNumLote := SC9->C9_NUMLOTE
				cIdDCF   := SC9->C9_IDDCF
				nQuant   := SC9->C9_QTDLIB
				//-- Verifica se o pedido gera OS na carga, caso contrário não considera a carga
				If !Empty(cCarga)
					SC5->(DbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO)) .And. SC5->C5_GERAWMS == "1"
						cCarga := "" //Limpa a carga, pois a OS foi gerada no pedido
					EndIf
				EndIf
			ElseIf cOrigem == "SD1"
				cServico := SD1->D1_SERVIC
				cDocto   := SD1->D1_DOC
				cSerie   := SD1->D1_SERIE
				cCliFor  := SD1->D1_FORNECE
				cLoja    := SD1->D1_LOJA
				cArmazem := SD1->D1_LOCAL
				cProduto := SD1->D1_COD
				cLoteCtl := SD1->D1_LOTECTL
				cNumLote := SD1->D1_NUMLOTE
				cNumSeq  := SD1->D1_NUMSEQ
				nQuant   := SD1->D1_QUANT
			ElseIf cOrigem == "SD2"
				cServico := SD2->D2_SERVIC
				cDocto   := SD2->D2_DOC
				cSerie   := SD2->D2_SERIE
				cCliFor  := SD2->D2_CLIENTE
				cLoja    := SD2->D2_LOJA
				cArmazem := SD2->D2_LOCAL
				cProduto := SD2->D2_COD
				cLoteCtl := SD2->D2_LOTECTL
				cNumLote := SD2->D2_NUMLOTE
				cNumSeq  := SD2->D2_NUMSEQ
				nQuant   := SD2->D2_QUANT
			ElseIf cOrigem == "SD3"
				cServico := SD3->D3_SERVIC
				cDocto   := SD3->D3_DOC
				cArmazem := SD3->D3_LOCAL
				cProduto := SD3->D3_COD
				cLoteCtl := SD3->D3_LOTECTL
				cNumLote := SD3->D3_NUMLOTE
				cNumSeq  := SD3->D3_NUMSEQ
				nQuant   := SD3->D3_QUANT
			EndIf
			//Verifica se encontra a ordem de serviço
			If !WmsChkDCF(cOrigem,cCarga,,cServico,/*Status*/,,cDocto,cSerie,cCliFor,cLoja,cArmazem,cProduto,cLoteCtl,cNumLote,cNumSeq,cIdDCF)
				RestArea(aAreaAnt)
				Return .T. //Não existe ordem de serviço
			EndIf
		EndIf
		nQtdDelDCF := nQuant
		//Verifica se o serviço já foi executado
		If DCF->DCF_STSERV == "3"
			// A regra abaixo deve ser executada por tarefa para que no estorno da liberação do pedido
			// ou alteração de suas quantidades, todas as tarefas do serviço sejam estornadas corretamente
			DC5->(DbSetOrder(1))
			DC5->(DbSeek(xFilial('DC5')+DCF->DCF_SERVIC))
			While !DC5->(Eof()) .And. xFilial('DC5')+DCF->DCF_SERVIC == DC5->DC5_FILIAL+DC5->DC5_SERVIC
				//Só considera para estorno automático movimentos que não atualizam estoque
				//Pois se for movimentado algo, deve ser estornado manual a OS antes
				cQuery := "SELECT SDB.DB_IDMOVTO, SDB.DB_ORDATIV, SDB.R_E_C_N_O_ RECNOSDB"
				cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
				cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
				cQuery +=   " AND SDB.DB_SERVIC  = '"+DCF->DCF_SERVIC+"'"
				cQuery +=   " AND SDB.DB_TAREFA  = '"+DC5->DC5_TAREFA+"'"
				cQuery +=   " AND SDB.DB_PRODUTO = '"+DCF->DCF_CODPRO+"'"
				cQuery +=   " AND SDB.DB_LOCAL   = '"+DCF->DCF_LOCAL+"'"
				cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
				cQuery +=   " AND SDB.DB_ESTORNO = ' '"
				cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
				cQuery +=   " AND EXISTS (SELECT 1 "
				cQuery +=                 " FROM "+RetSqlName("DCR")+" DCR"
				cQuery +=                " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=                  " AND DCR.DCR_IDDCF  = '"+DCF->DCF_ID+"'"
				cQuery +=                  " AND DCR.DCR_IDORI  = SDB.DB_IDDCF"
				cQuery +=                  " AND DCR.DCR_IDMOV  = SDB.DB_IDMOVTO"
				cQuery +=                  " AND DCR.DCR_IDOPER = SDB.DB_IDOPERA"
				cQuery +=                  " AND DCR.D_E_L_E_T_ = ' ')"
				If lWmsVlEP
					cQuery +=   " AND NOT EXISTS("
					cQuery +=   " SELECT 1 FROM  "+RetSqlName("SC9")+" SC9 
					cQuery +=   	" WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
					cQuery +=   		" AND SC9.C9_PEDIDO = SDB.DB_DOC"
					cQuery +=   		" AND SC9.C9_ITEM   = SDB.DB_SERIE"
					cQuery +=   		" AND SC9.C9_PRODUTO = SDB.DB_PRODUTO"
					cQuery +=   		" AND SC9.C9_SERVIC  = SDB.DB_SERVIC"
					cQuery +=   		" AND SC9.C9_LOTECTL = SDB.DB_LOTECTL"
					cQuery +=   		" AND SC9.C9_IDDCF   = SDB.DB_IDDCF"
					cQuery +=   		" AND SC9.C9_NFISCAL <> ' '"
					cQuery +=   		" AND SC9.D_E_L_E_T_ = ' ')"
				EndIf
				cQuery += " ORDER BY SDB.DB_IDMOVTO, SDB.DB_ORDATIV"
				cQuery := ChangeQuery(cQuery)
				cAliasSDB := GetNextAlias()
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDB,.F.,.T.)
				While (cAliasSDB)->(!Eof())
					SDB->(DbGoTo((cAliasSDB)->RECNOSDB))
					//Se o lote for preenchido e for diferente, não exclui
					If Iif(!Empty(cLoteCtl) .And. !Empty(SDB->DB_LOTECTL),SDB->DB_LOTECTL != cLoteCtl,.F.) .Or.;
						Iif(!Empty(cNumLote) .And. !Empty(SDB->DB_NUMLOTE),SDB->DB_NUMLOTE != cNumLote,.F.)
						(cAliasSDB)->(DbSkip())
						Loop
					EndIf
					//Só pode deletar a quantidade do movimento quando encontrar o próximo
					If Iif(!Empty(cIdMovto),cIdMovto != SDB->DB_IDMOVTO,.F.)
						//Diminuindo a quantidade deletada
						nQuant -= nQtdDel
						If QtdComp(nQuant) <= QtdComp(0)
							Exit
						EndIf
					EndIf
					//-- Estorna somente movimentações de RF
					DbSelectArea("DCR")
					If DCR->(DbSeek(xFilial("DCR")+SDB->DB_IDDCF+DCF->DCF_ID+SDB->DB_IDMOVTO+SDB->DB_IDOPERA,.F.))
						If cIdMovto != SDB->DB_IDMOVTO
							If QtdComp(DCR->DCR_QUANT) <= QtdComp(nQuant)
								nQtdDel    := DCR->DCR_QUANT
								nQtdDel2UM := DCR->DCR_QTSEUM
							Else
								nQtdDel    := nQuant
								nQtdDel2UM := ConvUm(SDB->DB_PRODUTO,nQuant,0,2)
							EndIf
							cIdMovto := SDB->DB_IDMOVTO
						EndIf
						RecLock("SDB",.F.)
						If QtdComp(SDB->DB_QUANT - nQtdDel) == QtdComp(0)
							SDB->DB_ESTORNO := 'S'
						Else
							SDB->DB_QUANT   -= nQtdDel
							SDB->DB_QTSEGUM -= nQtdDel2UM
						EndIf
						SDB->(MsUnlock())
						//-- Elimina registro da DCR
						RecLock("DCR",.F.)
						If QtdComp(DCR->DCR_QUANT - nQtdDel) == QtdComp(0)
							DCR->(DbDelete())
						Else
							DCR->DCR_QUANT  -= nQtdDel
							DCR->DCR_QTSEUM -= nQtdDel2UM
						EndIf
						DCR->(MsUnlock())
					Else
						lRet := .F.
						cMensagem := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(DCF->DCF_SERIE),"")+STR0013+AllTrim(DCF->DCF_CODPRO)+CLRF
						cMensagem += STR0007+CLRF //"Não foi possível encontrar a movimentação relacionada (DCR)."
						cMensagem += RetTitle("DCF_ID")+": "+DCF->DCF_ID+CLRF
						cMensagem += RetTitle("DB_IDMOVTO")+": "+SDB->DB_IDMOVTO
						WmsMessage(cMensagem,"WmsDelDCF",1,lExibeMsg)
						Exit
					EndIf
					(cAliasSDB)->(DbSkip())
				EndDo
				(cAliasSDB)->(DbCloseArea())
				// Restaura as variáveis para estornar a próxima tarefa
				nQuant   := nQtdDelDCF
				cIdMovto := ""
				DC5->(DbSkip())
			EndDo
		EndIf
		RecLock("DCF",.F.)
		//Diminuindo a quantidade ou excluindo a ordem de serviço
		If QtdComp(DCF->DCF_QUANT) > QtdComp(nQtdDelDCF)
			DCF->DCF_QUANT  := DCF->DCF_QUANT - nQtdDelDCF
			DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
		Else
			If lWMSXDCF
				ExecBlock("WMSXDCF", .F., .F.)
			EndIf
			DCF->(DbDelete())
		EndIf
		DCF->(MsUnlock())
		If cOrigem == "SC9"
			// Estorna Mont. de Volumes e Conf. Expedição
			WMSEstVlCf(SC9->C9_SEQUEN)
			//Se exclui a ordem de serviço, deve excluir o IDDCF da origem
			RecLock("SC9",.F.)
			SC9->C9_IDDCF  := ""
			SC9->C9_STSERV := ""
			SC9->(MsUnlock())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return(lRet)

//----------------------------------------------------------
// Função que verifica se existe (e exclui) serviço WMS de conferência relacionado
// a uma nota de entrada (SD1).
// Esta verificação é necessária, pois quando a nota é originada de uma pré-nota, onde foi
// informado serviço WMS de conferência, ao realizar a classificação da mesma informado um
// serviço de recebimento, os dados referentes ao serviço de conferência se perdem.
// Sendo assim, na exclusão ou alteração da pré-nota, a OS original de conferência não é
// excluída, permitindo ao usuário efetuar operações indevidas com este registro.
//
// Esta função foi criada devido a uma exceção e é chamada somente
// pela pela rotina Documento de Entrada (MATA103) - Chamado TQRQCF
//----------------------------------------------------------
Function WMSDelConf()
Local aArea     := GetArea()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

	cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_LOCAL  = '"+SD1->D1_LOCAL +"'"
	cQuery +=   " AND DCF.DCF_DOCTO  = '"+SD1->D1_DOC +"'"
	cQuery +=   " AND DCF.DCF_SERIE  = '"+SD1->D1_SERIE +"'"
	cQuery +=   " AND DCF.DCF_CLIFOR = '"+SD1->D1_FORNECE+"'"
	cQuery +=   " AND DCF.DCF_LOJA   = '"+SD1->D1_LOJA+"'"
	cQuery +=   " AND DCF.DCF_CODPRO = '"+SD1->D1_COD+"'"
	cQuery +=   " AND EXISTS (SELECT 1"
	cQuery +=                " FROM "+RetSqlName('DC5')+" DC5"
	cQuery +=               " WHERE DC5.DC5_FILIAL  = '"+xFilial('DC5')+"'"
	cQuery +=                  " AND DC5.DC5_SERVIC = DCF.DCF_SERVIC"
	cQuery +=                  " AND DC5.DC5_TIPO   = '1'"
	cQuery +=                  " AND DC5.DC5_FUNEXE = '000005'"
	cQuery +=                  " AND DC5.D_E_L_E_T_ = ' ')"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
			DCF->(DbGoTo((cAliasQry)->RECNODCF))
			If Iif(!Empty(SD1->D1_LOTECTL) .And. !Empty(DCF->DCF_LOTECT),DCF->DCF_LOTECT == SD1->D1_LOTECTL,.T.) .And.;
				Iif(!Empty(SD1->D1_NUMLOTE) .And. !Empty(DCF->DCF_NUMLOT),DCF->DCF_NUMLOT == SD1->D1_NUMLOTE,.T.)
				//Se achar a OS correspondente chama a função de exclusão da DCF
				WmsDelDCF('1',,DCF->DCF_ID)
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())
	
	RestArea(aArea)
Return
//-----------------------------------
/*{Protheus.doc}
Valida o saldo dos endereços no estorno de um serviço de entrada

@param   cDocto      Código do documento
@param   cSerie      Serie do documento
@param   cLocal      Código do armazém
@param   cEndereco   Código do endereço
@param   cProduto    Código do produto
@param   cNumSerie   Número de série
@param   cLote       Código do lote
@param   cSubLote    Código do sublote
@param   nQuant      Quantidade da movimentação

@author  Guilherme Alexandre Metzger
@version P11
@since   28/10/14
*/
//-----------------------------------
Static Function VldEstEnt(cDocto,cSerie,cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,nQuant)
Local lRet      := .T.
Local nSaldoSBF := 0
Local nSaldoRF  := 0
Local cMensagem := ''

	//Consulta os saldos de endereço e pendente RF
	nSaldoSBF := WmsSaldoSBF(cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,.F.,.F.,.F.,.F.,'1',.F.)
	nSaldoRF  := WmsSaldoSBF(cLocal,cEndereco,cProduto,cNumSerie,cLote,cSubLote,.F.,.T.,.F.,.T.,'3')
	
	If QtdComp(nQuant) > QtdComp(nSaldoSBF + nSaldoRF)
		//SIGAWMS - OS '#####'/'#####' - Produto: '#####'
		//O estorno não pode ser efetuado, pois o saldo do endereço '#####' está comprometido.
		//Quantidade para estorno de '###,##'
		//Endereço possui saldo de '###,##'
		//Movimentações WMS pendentes de saída de '###,##'
		cMensagem := "SIGAWMS - OS "+AllTrim(cDocto)+Iif(!Empty(cSerie),"/"+AllTrim(SubStr(cSerie,1,3)),"")+STR0013+AllTrim(cProduto)+CLRF
		cMensagem += STR0014+AllTrim(cEndereco)+STR0015
		cMensagem += CLRF+STR0016+AllTrim(Transf(nQuant,PesqPictQt('DB_QUANT',14)))
		If nSaldoSBF > 0
			cMensagem += CLRF+STR0017+AllTrim(Transf(nSaldoSBF,PesqPictQt('DB_QUANT',14)))
		EndIf
		If nSaldoRF < 0 //Saldo de saída sempre será retornado negativo
			cMensagem += CLRF+STR0018+AllTrim(Transf(nSaldoRF*(-1),PesqPictQt('DB_QUANT',14)))
		EndIf
		WmsMessage(cMensagem,,1)
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------------------------
/*{Protheus.doc} VldEstDCF
Validações no estorno de ordem de serviço

@param cMsg    Mensagem de alerta recebida por referência
               caso o estorno não possa ser executado

@author  Guilherme A. Metzger
@version P11
@since   07/03/2016
*/
//----------------------------------------------------------
Function VldEstDCF(cMsg)
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local oCofExpItem := Nil
Local oMntVolItem := Nil
Local cAliasSC9   := Nil
Local cAliasD0H   := Nil
Local cAliasD0I   := Nil
Local cCodCofExp  := ""
Local cCodMntVol  := ""

	// Verifica se alguma atividade da O.S. está em execução
	If !DLA150ChDb(DCF->DCF_DOCTO,DCF->DCF_SERIE,DCF->DCF_CLIFOR,DCF->DCF_LOJA,DCF->DCF_SERVIC,DCF->DCF_ID)
		cMsg := WmsFmtMsg(STR0022,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existem atividades em execução para o documento: [VAR01] série: [VAR02]"
		RestArea(aAreaAnt)
		Return .F.
	EndIf
	If WmsTipServ(DCF->DCF_SERVIC) == '2' // Saída
		// Verifica se existe item faturado para o documento
		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_PEDIDO,
					SC9.C9_ITEM
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_IDDCF = %Exp:DCF->DCF_ID%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
		EndSql
		If (cAliasSC9)->(!Eof())
			cMsg := STR0023 + AllTrim((cAliasSC9)->C9_PEDIDO) + '/' + AllTrim((cAliasSC9)->C9_ITEM)
			lRet := .F.
		EndIf
		(cAliasSC9)->(DbCloseArea())
		// Verifica se existe endereçamento para o documento
		If lRet
			D00->(DbSetOrder(1)) // D00_FILIAL+D00_CARGA+D00_PEDIDO+D00_CODEND
			If D00->(DbSeek(xFilial("D00")+DCF->DCF_CARGA+AllTrim(DCF->DCF_DOCTO)))
				cMsg := WmsFmtMsg(STR0024,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existe endereçamento para o documento: [VAR01] série: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
		// Verifica se existe conferência de expedição para o item do documento
		If lRet .And. Posicione('DC5',1,xFilial('DC5')+DCF->DCF_SERVIC,'DC5_COFEXP') == '1'
			cAliasD0H := GetNextAlias()
			BeginSql Alias cAliasD0H
				SELECT D0H.D0H_CODEXP
				FROM %Table:D0H% D0H
				WHERE D0H.D0H_FILIAL = %xFilial:D0H%
				AND D0H.D0H_IDDCF = %Exp:DCF->DCF_ID%
				AND D0H.%NotDel%
			EndSql
			If (cAliasD0H)->(!Eof())
				cCodCofExp := (cAliasD0H)->D0H_CODEXP
			EndIf
			(cAliasD0H)->(dbCloseArea())
			// Valida montagem de volume
			oCofExpItem := WMSDTCConferenciaExpedicaoItens():New()
			oCofExpItem:SetCarga(DCF->DCF_CARGA)
			oCofExpItem:SetPedido(DCF->DCF_DOCTO)
			oCofExpItem:SetPrdOri(DCF->DCF_CODPRO)
			oCofExpItem:SetProduto(DCF->DCF_CODPRO)
			If !Empty(cCodCofExp)
				oCofExpItem:SetCodExp(cCodCofExp)
			Else
				// Busca o codigo da montagem de volume
				oCofExpItem:SetCodExp(oCofExpItem:oConfExp:FindCodExp())
			EndIf
			If oCofExpItem:LoadData() .And. oCofExpItem:GetStatus() != "1"
				cMsg := WmsFmtMsg(STR0037,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existe conferência de expedição para o documento: [VAR01] série: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
		// Verifica se existe montagem de volumes para o item do documento
		If lRet
			cAliasD0I := GetNextAlias()
			BeginSql Alias cAliasD0I
				SELECT D0I.D0I_CODMNT
				FROM %Table:D0I% D0I
				WHERE D0I.D0I_FILIAL = %xFilial:D0I%
				AND D0I.D0I_IDDCF = %Exp:DCF->DCF_ID%
				AND D0I.%NotDel%
			EndSql
			If (cAliasD0I)->(!Eof())
				cCodMntVol := (cAliasD0I)->D0I_CODMNT
			EndIf
			(cAliasD0I)->(dbCloseArea())
			// Valida montagem de volume
			oMntVolItem := WMSDTCMontagemVolumeItens():New()
			oMntVolItem:SetCarga(DCF->DCF_CARGA)
			oMntVolItem:SetPedido(DCF->DCF_DOCTO)
			oMntVolItem:SetPrdOri(DCF->DCF_CODPRO)
			oMntVolItem:SetProduto(DCF->DCF_CODPRO)
			If !Empty(cCodMntVol)
				oMntVolItem:SetCodMnt(cCodMntVol)
			Else
				// Busca o codigo da montagem de volume
				oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
			EndIf
			If oMntVolItem:LoadData() .And. oMntVolItem:GetStatus() != "1"
				cMsg := WmsFmtMsg(STR0026,{{"[VAR01]",DCF->DCF_DOCTO},{"[VAR02]",DCF->DCF_SERIE}}) // "Existem volumes montados para o documento: [VAR01] série: [VAR02]"
				lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*{Protheus.doc} WMSEstVlCf
Estorno de montagem de volumes e conferência de expedição

@author  Guilherme A. Metzger
@version P11
@since   07/04/2016
*/
//----------------------------------------------------------
Static Function WMSEstVlCf(cSequen)
Local aAreaSC9  := SC9->(GetArea())
Local oConfExp  := Nil
Local oMntVol   := Nil

Default cSequen := ""

	// Estorna os dados da montagem de volumes
	If lMntVol
		oMntVol := WMSDTCMontagemVolume():New()
		oMntVol:SetCarga(DCF->DCF_CARGA)
		oMntVol:SetPedido(DCF->DCF_DOCTO)
		oMntVol:SetCodMnt(oMntVol:FindCodMnt())
		If oMntVol:LoadData()
			If !Empty(cSequen)
				WmsEstVol(oMntVol:GetCodMnt(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
			Else
				// Faz a busca para encontrar lote, sublote e quantidade
				// corretos de cada sequência de liberação do pedido
				SC9->(DbSetOrder(9)) // C9_FILIAL+C9_IDDCF
				SC9->(DbSeek(xFilial('SC9')+DCF->DCF_ID))
				Do While !SC9->(Eof()) .And. (xFilial('SC9')+DCF->DCF_ID == SC9->C9_FILIAL+SC9->C9_IDDCF)
					WmsEstVol(oMntVol:GetCodMnt(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
					SC9->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	// Estorna os dados da conferência de expedição
	If Posicione('DC5',1,xFilial('DC5')+DCF->DCF_SERVIC,'DC5_COFEXP') == '1'
		oConfExp := WMSDTCConferenciaExpedicao():New()
		oConfExp:SetCarga(DCF->DCF_CARGA)
		oConfExp:SetPedido(DCF->DCF_DOCTO)
		oConfExp:SetCodExp(oConfExp:FindCodExp())
		If oConfExp:LoadData()
			If !Empty(cSequen)
				// Se a sequência vier preenchida já estará posicionado na SC9 correta
				WmsConfEst(oConfExp:GetCodExp(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
			Else
				// Faz a busca para encontrar lote, sublote e quantidade
				// corretos de cada sequência de liberação do pedido
				SC9->(DbSetOrder(9)) // C9_FILIAL+C9_IDDCF
				SC9->(DbSeek(xFilial('SC9')+DCF->DCF_ID))
				Do While !SC9->(Eof()) .And. (xFilial('SC9')+DCF->DCF_ID == SC9->C9_FILIAL+SC9->C9_IDDCF)
					WmsConfEst(oConfExp:GetCodExp(),SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_PRODUTO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_QTDLIB,SC9->C9_IDDCF)
					SC9->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC9)
Return
//----------------------------------------------------------
/*{Protheus.doc} WmsAvalDAK
Avalia se pode excluir ou estornar pedidos de uma carga verificando se
os serviços WMS já foram executados para aqueles pedidos.
Somente poderá estornar direto caso o parametro MV_OMSESTP esteja como .T.
Pois neste caso quando excluído um item ou parte dele da carga a liberação
do pedido de venda é estornada, voltando o processo ao início

@author  Jackson Patrick Werka
@version P11
@since   07/04/2016
*/
//----------------------------------------------------------
Function WmsAvalDAK(cCarga,cSeqCar,cSeqEnt,cPedido,cItem,cSeqLib,nIndex,lEstPed,nQtdEst)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaSC9   := SC9->(GetArea())
Local aAreaSC5   := SC5->(GetArea())
Local oOrdSerDel := IIf(lWmsNew,WMSDTCOrdemServicoDelete():New(),Nil)
Local cAliasQry  := GetNextAlias()
Local cWhere     := ""

Default nIndex  := 5
Default lEstPed := .F.
Default nQtdEst := SC9->C9_QTDLIB
Default cCarga  := ""
Default cSeqCar := ""
Default cSeqEnt := ""
Default cPedido := ""
Default cItem   := ""
Default cSeqLib := ""



Private lWmsPergEP := .T.
Private lEstPedDAK := lEstPed

	// Se enviou a chave unica pesquisa pela chave unica
	If !Empty(cPedido) .And. !Empty(cItem) .And. !Empty(cSeqLib)
		nIndex := 1
	EndIf
	
	If nIndex == 5
		// Parâmetro Where
		cWhere := "%"
		If !Empty(cSeqEnt)
			cWhere += " AND SC9.C9_SEQENT = '"+cSeqEnt+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9,
					SC5.C5_GERAWMS
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = SC9.C9_PEDIDO
			AND SC5.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:cCarga%
			AND SC9.C9_SEQCAR = %Exp:cSeqCar%
			AND SC9.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		// Parâmetro Where
		cWhere := "%"
		If !Empty(cSeqLib)
			cWhere += " AND SC9.C9_SEQUEN = '"+cSeqLib+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9,
					SC5.C5_GERAWMS
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = SC9.C9_PEDIDO
			AND SC5.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_ITEM = %Exp:cItem%
			AND SC9.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	If (cAliasQry)->(!Eof())
		Do While (cAliasQry)->(!Eof())
			SC9->(dbGoTo( (cAliasQry)->RECNOSC9))
			If IntWMS(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
				If lEstPed .Or. (cAliasQry)->C5_GERAWMS <> '1'
					//-- Procura ordem de servico do wms ja executada
					If !lWmsNew
						If !(lRet := WmsAvalSC9())
							Exit
						EndIf
					Else
						oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
						If oOrdSerDel:LoadData()
							oOrdSerDel:SetHasEst(lEstPed)
							If !oOrdSerDel:CanCancel(nQtdEst)
								WmsMessage(oOrdSerDel:GetErro(),"WmsAvalDAK",1)
								lRet := .F.
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
Return lRet
//------------------------------------------------------------------------------
Function WmsAvalSC5(cAcao)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local nCntFor   := 1
Local nMaxArray := 1
Local nPosProd  := 1
Local nPosServ  := 1
Local nPosDest  := 1
Local lHasWMSIt := .F.

	// Por hora só existe a ação 1, por isso não trata
	If M->C5_TPCARGA == "2" .And. !(M->C5_GERAWMS == "1")
		// Descobre a posição dos campos no aHeader
		nPosProd  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
		nPosServ  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_SERVIC" })
		nPosDest  := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ENDPAD" })
		nMaxArray := Len(aCols)
		// Verifica ao menos um dos itens do pedido possui controle WMS
		For nCntFor := 1 To nMaxArray
			If !aCols[nCntFor][Len(aCols[nCntFor])] .And. IntWMS(aCols[nCntFor][nPosProd]) .And.;
				!Empty(aCols[nCntFor][nPosServ]) .And. !Empty(aCols[nCntFor][nPosDest])
				lHasWMSIt := .T.
				Exit
			EndIf
		Next nCntFor
		// Se possui produto WMS, apresenta a mensagem e retorna falso
		If lHasWMSIt
			WmsMessage(STR0027,"WmsAvalSC5",1) //"Não será gerado ordem de serviço WMS. Pedido não utiliza carga."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*{Protheus.doc} WmsAvalSC6
Validação de estorno da liberação do pedido de venda
@author  felipe.m
@version P11
@since   09/08/2016
*/
//----------------------------------------------------------
Function WmsAvalSC6(cAcao,cAliasSC6,aCols,nLin,aHeader,lAltera,nQtdEst)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oSaldoWMS  := Nil // Só instância em caso de uso
Local oOrdSerDel := Nil // Só instância em caso de uso
Local nCol       := 0
Local cItemSC6   := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cServico   := ""
Local cArmazem   := ""
Local cEndOrig   := ""
Local cEndDest   := ""
Local cRegrwms   := ""
Local nSaldo     := 0
Local nQtdLib    := 0
Local aBoxDC8    := {}
Local cQtdVen    := 0 

Default cAliasSC6 := "SC6"
Default nQtdEst := SC9->C9_QTDLIB
// Variável de controle do MATA410(Pedido de venda)
Default lAltera := .T.

	Do Case
		Case cAcao == "1" // Chamado via mata410 - Inclusão/Alteração de linha (LinhaOK)
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))   >0,aCols[nLin,nCol],CriaVar('C6_ITEM',   .F.))
			cServico := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_SERVIC'})) >0,aCols[nLin,nCol],CriaVar('C6_SERVIC', .F.))
			cArmazem := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCAL'}))  >0,aCols[nLin,nCol],CriaVar('C6_LOCAL',  .F.))
			cEndOrig := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCALIZ'}))>0,aCols[nLin,nCol],CriaVar('C6_LOCALIZ',.F.))
			cEndDest := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ENDPAD'})) >0,aCols[nLin,nCol],CriaVar('C6_ENDPAD', .F.))
			cRegrwms := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_REGWMS'})) >0,aCols[nLin,nCol],CriaVar('C6_REGWMS', .F.))
			cLotectl := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOTECTL'})) >0,aCols[nLin,nCol],CriaVar('C6_LOTECTL', .F.))
			cQtdVen  := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_QTDVEN'}))   >0,aCols[nLin,nCol],CriaVar('C6_QTDVEN',   .F.))
				
			// Valida a informação ou não do código do serviço WMS
			If !lWmsNew
				// No WMS atual não pode informar serviço e endereço origem ao mesmo tempo
				If !Empty(cEndOrig) .And. !Empty(cServico)
					WmsMessage(STR0032,"WmsAvalSC6",1) //"Não informar serviço WMS para itens com endereço informado."
					lRet := .F.
				EndIf
			Else
				// No WMS novo é obrigatório informar o código do serviço.
				If Empty(cServico) .AND.  SF4->F4_ESTOQUE == "S" .AND. cQtdVen > 0
					WmsMessage(STR0025,"WmsAvalSC6",1) //"É necessário informar o código do serviço para produtos que controlam WMS."
					lRet := .F.
				EndIf
				//validação para quando incluir lote se usar regra usar por lote 
				If lRet .AND. !Empty(cLotectl) .AND. !Empty(cRegrwms) .AND. cRegrwms <> '1'
					WmsMessage(STR0038,"WmsAvalSC6",1) //"Quando informado o Lote não é possível informar Regra WMS diferente de lote ou em branco."
					lRet:=.F.
				EndIF 
			EndIf
			// Valida o serviço informado se é do tipo expedição
			If lRet .And. !Empty(cServico)
				DC5->(DbSetOrder(1))
				DC5->(MsSeek(xFilial("DC5")+cServico))
				If DC5->DC5_TIPO != "2"
					WmsMessage(STR0028,"WmsAvalSC6",1) // Na inclusão de um pedido de venda somente serviços WMS do tipo saída podem ser utilizados.
					lRet := .F.
				EndIf
				If lRet
					lRet := VldSerTMS(cServico)
				EndIf
			EndIf
			// Se informou o endereço destino deve validar se o mesmo é do tipo box/doca.
			If lRet .And. !Empty(cEndDest)
				SBE->(dbSetOrder(1))
				If SBE->(!DbSeek(xFilial('SBE')+cArmazem+cEndDest, .F.))
					WmsMessage(STR0033,"WmsAvalSC6",1) //"Endereço não cadastrado (SBE)."
					lRet := .F.
				Else
					If DLTipoEnd(SBE->BE_ESTFIS) != 5
						WmsMessage(STR0034,"WmsAvalSC6",1) //"Para serviços de saída somente endereços de estrutura do tipo box/doca podem ser utilizados."
						lRet := .F.
					EndIf
				EndIf
			EndIf
			// Se está alterando o pedido de venda valida se tem serviço WMS já executado
			If lRet .And. lAltera
				lRet := WmsChkSC9(M->C5_NUM,cItemSC6,nQtdEst)
			EndIf
			// Para o novo WMS quando informado o endereço deve validar o saldo
			If lRet .And. lWmsNew .And. !Empty(cEndOrig)
				If !FwIsInCallStack("WMSV083PED") .And. WmsArmUnit(cArmazem)
					oEndereco := WMSDTCEndereco():New()
					oEndereco:SetArmazem(cArmazem)
					oEndereco:SetEnder(cEndOrig)
					If oEndereco:LoadData()
						If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
							aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
							WmsMessage(WmsFmtMsg(STR0035,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),"WmsAvalSC6",1,,,WmsFmtMsg(STR0036,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // "Não é permitido informar o endereço origem com estrutura física [VAR01], quando o armazém controla unitizador (C6_LOCALIZ)."##"Informe um endereço do tipo [picking] ou [doca]."
							lRet := .F.
						EndIf
					EndIf
				EndIf

				If lRet
					cProduto := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_PRODUTO'}))>0,aCols[nLin,nCol],CriaVar('C6_PRODUTO',.F.))
					cNumLote := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_NUMLOTE'}))>0,aCols[nLin,nCol],CriaVar('C6_NUMLOTE',.F.))
					nQtdLib  := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_QTDLIB'})) >0,aCols[nLin,nCol],CriaVar('C6_QTDLIB', .F.))

					If (Rastro(cProduto,"S") .And. (Empty(cNumLote) .Or. Empty(cLoteCtl))) .Or. (Rastro(cProduto,"L") .And. Empty(cLoteCtl))
						WmsMessage(STR0029,,,,,STR0030) //Só é possível informar o endereço de um produto com controle de rastro se o lote estiver preenchido.//Informe o lote/sub-lote do produto ou não informe o endereço (C6_LOCALIZ).
						lRet := .F.
					EndIf
				EndIf

				If lRet .And. QtdComp(nQtdLib) > 0
					oSaldoWMS := WMSDTCEstoqueEndereco():New()
					nSaldo := oSaldoWMS:GetSldWMS(cProduto,cArmazem,cEndOrig,cLoteCtl,cNumLote,/*cNumSerie*/ Nil)
					If QtdComp(nSaldo) < QtdComp(nQtdLib)
						Help(" ",1,"SALDOLOCLZ")
						lRet := .F.
					EndIf
				EndIf
			EndIf

		Case cAcao == "2" // Chamado via mata410 - Exclusão de linha
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))>0,aCols[nLin,nCol],CriaVar('C6_ITEM',.F.))

			If lAltera
				lRet := WmsChkSC9(M->C5_NUM,cItemSC6,nQtdEst)
			EndIf

		Case cAcao == "3" // Chamado via mata410 - Confirmação inclusão (TudoOK)
			cItemSC6 := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_ITEM'}))>0,aCols[nLin,nCol],CriaVar('C6_ITEM',.F.))

			If lAltera
				lRet := WmsChkSC9(M->C5_NUM,cItemSC6,nQtdEst)
			EndIf

			If lRet .And. lWmsNew
				cArmazem := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCAL'}))  >0,aCols[nLin,nCol],CriaVar('C6_LOCAL',  .F.))
				cEndOrig := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOCALIZ'}))>0,aCols[nLin,nCol],CriaVar('C6_LOCALIZ',.F.))

				If !Empty(cEndOrig)
					nQtdLib  := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_QTDLIB'})) >0,aCols[nLin,nCol],CriaVar('C6_QTDLIB', .F.))

					If QtdComp(nQtdLib) > 0
						cProduto := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_PRODUTO'}))>0,aCols[nLin,nCol],CriaVar('C6_PRODUTO',.F.))
						cLoteCtl := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_LOTECTL'}))>0,aCols[nLin,nCol],CriaVar('C6_LOTECTL',.F.))
						cNumLote := Iif((nCol := aScan(aHeader,{|x|Alltrim(x[2])=='C6_NUMLOTE'}))>0,aCols[nLin,nCol],CriaVar('C6_NUMLOTE',.F.))
						oSaldoWMS := Iif(oSaldoWMS==Nil,WMSDTCEstoqueEndereco():New(),oSaldoWMS)
						nSaldo := oSaldoWMS:GetSldWMS(cProduto,cArmazem,cEndOrig,cLoteCtl,cNumLote,/*cNumSerie*/ Nil)
						If QtdComp(nSaldo) < QtdComp(nQtdLib)
							Help(" ",1,"SALDOLOCLZ")
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		Case cAcao == "4" //Chamado via mata461(Faturamento) e mata455(Liberação do Estoque)
			// Já vem posicionado no SC9 correto
			If !lWmsNew
				lRet := WmsAvalSC9()
			Else
			   oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
				If oOrdSerDel:LoadData()
					oOrdSerDel:SetHasEst(.T.)
					If !(lRet := oOrdSerDel:CanCancel(nQtdEst)) .And. !Empty(oOrdSerDel:GetErro())
						WmsMessage(oOrdSerDel:GetErro(),"WmsAvalSC6",1)
					EndIf
				EndIf
			EndIf
		Case cAcao == "5" //Chamado via mata416(Aprovação orçamento) para carregar os campos: C6_SERVIC, C6_ENDPAD, C6_TPESTR
			nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
			nPosSer    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERVIC"})
			nPosEnd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENDPAD"})
			nPosTpEst    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TPESTR"})
			If  nPosCod > 0 .AND. (nPosSer > 0 .AND. Empty(aCols[nLin][nPosSer])) .OR.  (nPosEnd > 0 .AND. Empty(aCols[nLin][nPosEnd])) .OR. (nPosTpEst > 0 .AND. Empty(aCols[nLin][nPosTpEst])) 
				If IntWMS(aCols[nLin][nPosCod])
					SB5->(dbSetOrder(1))
					If SB5->(MsSeek(xFilial("SB5")+aCols[nLin][nPosCod]))
						If SB5->(FieldPos("B5_SERVSAI")) > 0 .And. nPosSer > 0 .AND. Empty(aCols[nLin][nPosSer])
							aCols[nLin][nPosSer] := SB5->B5_SERVSAI
						EndIf
						If SB5->(FieldPos("B5_ENDSAI")) > 0 .AND. nPosEnd > 0 .AND. Empty(aCols[nLin][nPosEnd])
							aCols[nLin][nPosEnd] := SB5->B5_ENDSAI
							SBE->(DbSetOrder(9))
							If SBE->(DbSeek(xFilial('SBE')+SB5->B5_ENDSAI)) .AND. nPosTpEst > 0
								aCols[nLin][nPosTpEst] := SBE->BE_ESTFIS
							EndIF
						EndIF
					EndIf
				EndIf
			ENDIF
	EndCase
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Static Function WmsChkSC9(cPedido,cItem,nQtdEst)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaSC9   := SC9->(GetArea())
Local oOrdSerDel := Iif(lWmsNew,WMSDTCOrdemServicoDelete():New(),Nil)
Local cAliasSC9  := GetNextAlias()

	// Posiciona em todas as sequencias SC9 referentes ao SC6
	BeginSql Alias cAliasSC9
		SELECT SC9.R_E_C_N_O_ RECNOSC9
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.%NotDel%
	EndSql
	If (cAliasSC9)->(!Eof())
		Do While lRet .And. (cAliasSC9)->(!Eof())
			SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
			If Empty(SC9->C9_NFISCAL) .And. !Empty(SC9->C9_SERVIC)
				If !lWmsNew
					If !(lRet := WmsAvalSC9())
						Exit
					EndIf
				Else
					oOrdSerDel:SetIdDCF(SC9->C9_IDDCF)
					If oOrdSerDel:LoadData()
						oOrdSerDel:SetHasEst(.T.)
						If !(lRet := oOrdSerDel:CanCancel(nQtdEst)) .And. !Empty(oOrdSerDel:GetErro())
							WmsMessage(oOrdSerDel:GetErro(),"WmsChkSC9",1)
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasSC9)->(dbSkip())
		EndDo
	EndIf
	(cAliasSC9)->(dbcloseArea())
	RestArea(aAreaSC9)
Return lRet
//------------------------------------------------------------------------------
Static Function VldSerTMS(cServico)
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local cAliasQry:= GetNextAlias()
	
	BeginSql Alias cAliasQry
		SELECT DISTINCT DC5.DC5_SERVIC
		FROM %Table:DC5% DC5
		WHERE DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = %Exp:cServico%
		AND DC5.DC5_TIPTRA <> %Exp:Criavar("DC5_TIPTRA",.F.)%
		AND DC5.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		Help(' ',1, 'A410SERTMS')
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*{Protheus.doc} WmsChkSC6
Valida a inclusão e alteração de pedidos.
@author  amanda.vieira
@version P11
@since   30/11/2016
*/
//----------------------------------------------------------
Function WmsChkSC6(cAcao,cLocaliza,cProduto,cLoteCtl,cNumLote)
Local lRet    := .T.
Default cAcao := "1"

	Do Case
		Case cAcao == "1" //Chamado do programa mata 410, ao incluir ou alterar um pedido.
			//Se o produto controla rastro e encontra-se informado o endereço, então é necessário informar o lote/sub-lote que será ser utilizado
			If !Empty(cLocaliza)
				If (Rastro(cProduto,"S") .And. (Empty(cNumLote) .Or. Empty(cLoteCtl))) .Or. (Rastro(cProduto,"L") .And. Empty(cLoteCtl))
					WmsMessage(STR0029,,,,,STR0030) //Só é possível informar o endereço de um produto com controle de rastro se o lote estiver preenchido.//Informe o lote/sub-lote do produto ou não informe o endereço (C6_LOCALIZ).
					lRet := .F.
				EndIf
			EndIf
	EndCase
Return lRet
