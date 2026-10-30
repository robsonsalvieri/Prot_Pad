#include "PROTHEUS.ch"
#INCLUDE "WMSXFUNF.ch"
#define CLRF  Chr(13)+Chr(10)

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNF                                                           |
+---------+--------------------------------------------------------------------+
|Autor    | Jackson Patrick Werka                                              |
+---------+--------------------------------------------------------------------+
|Data     | 19/05/2015                                                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Esta função tem por objetivo reunir todas as informações relativas |
|         | ao processo de transferência do WMS, como validações de capacidade |
|         | e geração dos movimentos de transferência.                         |
+---------+--------------------------------------------------------------------+
*/

Static __cMsgOsPr := ""
Function WmsTransfer(lRadioF,cStatRF)
Local aAreaAnt  := GetArea()
Local aAreaDC8  := DC8->(GetArea())
Local aAreaSD3  := SD3->(GetArea())
Local cProduto  := CriaVar('B1_COD'    , .F.)
Local cDocto    := ''
Local cSerie    := ''
Local cNumSeq   := ''
Local cLocOrig  := CriaVar('BE_LOCAL'  , .F.)
Local cEndOrig  := ''
Local cEstOrig  := ''
Local cLocDest  := ''
Local cEndDest  := ''
Local cEstDest  := ''
Local cCodZona  := ''
Local nOrdem    := 0
Local cSeek     := ''
Local cEstNorma := ''
Local cLocNorma := ''
Local nQuant    := 0
Local nQtdNorma := 0
Local cMensagem := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cTipoNF   := ""
Local cTm       := ""
Local cItem     := ""
Local cOrigLan  := ""
Local lRet      := .T.

	__cMsgOsPr := "SIGAWMS - OS "+AllTrim(DCF->DCF_DOCTO)+Iif(!Empty(DCF->DCF_SERIE),"/"+AllTrim(SerieNfId("DCF",2,"DCF_SERIE")),"")+STR0001+AllTrim(cProduto)+CLRF
	//-- Considera os Parametros passados pela aParam150
	If Type('aParam150') == 'A'
		cProduto := aParam150[01]
		cDocto   := aParam150[03]
		cSerie   := aParam150[04]
		cNumSeq  := aParam150[05]
		nQuant   := aParam150[06]
		cItem    := aParam150[15]
		cLocDest := aParam150[25]
		cEndDest := aParam150[26]
		cEstDest := aParam150[27]
	EndIf

	If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
		//-- Posiciona o SB5
		If lRet
			DbSelectArea('SB5')
			DbSetOrder(1)
			If !(lRet:=MsSeek(xFilial('SB5') + cProduto, .F.))
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0002,{{"[VAR01]",cProduto}}) //"Produto [VAR01] não cadastrado nos Dados Adicionais do Produto. (SB5)"
				WmsMessage(cMensagem,"WmsTransfer",1)
			Else
				cCodZona := B5_CODZON
			EndIf
		EndIf

		If lRet
			//-- Pesquisa Endereco Origem da Transferencia
			lRet := .F.
			DbSelectArea('SD3')
			SD3->(DbSetOrder(8)) //D3_FILIAL+D3_DOC+D3_NUMSEQ
			If SD3->(DbSeek(cSeek:=xFilial('SD3')+cDocto+cNumSeq, .F.))
				Do While SD3->(!Eof() .And. cSeek == D3_FILIAL+D3_DOC+D3_NUMSEQ)
					If Empty(SD3->D3_SERVIC)
						cLocOrig := SD3->D3_LOCAL
						cEndOrig := SD3->D3_LOCALIZ
						lRet := .T.
						Exit
					EndIf
					SD3->(DbSkip())
				EndDo
			EndIf
			If !lRet
				cMensagem := __cMsgOsPr
				cMensagem += STR0008 // Não foi possível encontrar um registro de movimentação para o documento desta ordem de serviço. (SD3)
				WmsMessage(cMensagem,"WmsTransfer",1)
			EndIf
			RestArea(aAreaSD3)
		EndIf

		If lRet
			//-- Preenche a estrutura fisica de Origem da Transferencia
			If !Empty(cEndOrig)
				SBE->(DbSetOrder(1))
				If SBE->(MsSeek(xFilial('SBE')+cLocOrig+cEndOrig))
					cEstOrig := SBE->BE_ESTFIS
				EndIf
			EndIf
			aParam150[02] := cLocOrig
			aParam150[20] := cEndOrig
			aParam150[21] := cEstOrig
		EndIf

		// Caso não tenha sido informado o endereço destino da transferência, chama a função de endereçamento
		// para utilizar a inteligência WMS na busca dos endereços, conforme o processo padrão de armazenagem.
		// Chama só nesse ponto porque primeiro precisa buscar as informações da origem.
		If lRet .And. Empty(cEndDest)
			Return WmsEndereca(lRadioF,cStatRF)
		EndIf

		If lRet
			DC8->(DbSetOrder(1))
			If DC8->(DbSeek(xFilial('DC8')+cEstDest)) // Se a estrutura de destino é do tipo doca, busca a norma de acordo com as informações do endereço de origem
				If DC8->DC8_TPESTR == '5'
					nQtdNorma := DLQtdNorma(cProduto, cLocOrig, cEstOrig, /*cDesUni*/, .F., cEndOrig) //Não pode considerar a qtd pelo nr de unitizadores
					cEstNorma := cEstOrig
					cLocNorma := cLocOrig
				Else
					nQtdNorma := DLQtdNorma(cProduto, cLocDest, cEstDest, /*cDesUni*/, .F., cEndDest) //Não pode considerar a qtd pelo nr de unitizadores
					cEstNorma := cEstDest
					cLocNorma := cLocDest
				EndIf
			EndIf
			RestArea(aAreaDC8)

			If nQtdNorma == 0
				cMensagem := __cMsgOsPr
				cMensagem += STR0003+CLRF //Não foi possível determinar a norma para a movimentação.
				cMensagem += WmsFmtMsg(STR0004,{{"[VAR01]",cEstNorma},{"[VAR02]",cProduto},{"[VAR03]",cLocNorma}}) //A estrutura fisica [VAR01] não está cadastrada na sequencia de abastecimento do Produto/Armazém [VAR02]/[VAR03].
				WmsMessage(cMensagem,"WmsTransfer",1)
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona e Consiste SDA                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		DbSelectArea('SDA')
		DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
		If !(lRet:=MsSeek(xFilial('SDA')+cProduto+cLocDest+cNumSeq+cDocto+cSerie, .F.))
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0005,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)}}) //"O registro de movimentação do Produto/Armazém/Doc/Série '####' não foi encontrado no Arquivo de Saldos a Enderecar (SDA)."
			WmsMessage(cMensagem,"WmsTransfer",1)
		ElseIf !(lRet:=lRet.And.(QtdComp(SDA->DA_SALDO)>QtdComp(0)))
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0006,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)}}) //"O Produto/Armazém/Doc/Série '###' não possui Saldo a Enderecar (SDA)."
			WmsMessage(cMensagem,"WmsTransfer",1)
		Else
			cOrigLan := SDA->DA_ORIGEM
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona e Consiste SD1, SD2, SD3 ou SD5                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. cOrigLan$'SD1úSD2úSD3úSD5'
		DbSelectArea(cOrigLan)
		If cOrigLan == 'SD1'
			nOrdem := 5
			cSeek  := xFilial('SD1')+cProduto+cLocDest+cNumSeq
		ElseIf cOrigLan == 'SD2'
			nOrdem := 1
			cSeek  := xFilial('SD2')+cProduto+cLocDest+cNumSeq
		ElseIf cOrigLan == 'SD3'
			nOrdem := 3
			cSeek  := xFilial('SD3')+cProduto+cLocDest+cNumSeq
		Else
			nOrdem := 3
			cSeek  := xFilial('SD5')+cNumSeq+cProduto+cLocDest+SDA->DA_LOTECTL
		EndIf
		DbSetOrder(nOrdem)
		If !(MsSeek(cSeek, .F.))
			If (lRet:=!(cOrigLan=='SD3'))
				cCliFor := SDA->DA_CLIFOR
				cLoja   := SDA->DA_LOJA
				cTipoNF := SDA->DA_TIPONF
			Else
				cMensagem := __cMsgOsPr
				cMensagem += WmsFmtMsg(STR0007,{{"[VAR01]",cProduto},{"[VAR02]",cLocDest},{"[VAR03]",cDocto},{"[VAR04]",SubStr(cSerie,1,3)},{"[VAR05]",cOrigLan}}) //"O registro de movimentação do Produto/Armazém/Doc/Série [VAR01]/[VAR02]/[VAR03]/[VAR04] não foi encontrado no Arquivo de Origem ([VAR05])."
				WmsMessage(cMensagem,"WmsTransfer",1)
			EndIf
		ElseIf cOrigLan == 'SD1'
			cCliFor := SD1->D1_FORNECE
			cLoja   := SD1->D1_LOJA
			cTipoNF := SD1->D1_TIPO
			cTm     := SD1->D1_TES
			cItem   := SD1->D1_ITEM
		ElseIf cOrigLan == 'SD2'
			cCliFor := SD2->D2_CLIENTE
			cLoja   := SD2->D2_LOJA
			cTipoNF := SD2->D2_TIPO
			cTm     := SD2->D2_TES
			cItem   := SD2->D2_ITEM
		ElseIf cOrigLan == 'SD3'
			Do While SD3->(!Eof() .And. cSeek == D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ)
				If !Empty(SD3->D3_SERVIC)
					cTm := SD3->D3_TM
				EndIf
				SD3->(DbSkip())
			EndDo
		Else
			cCliFor := SD5->D5_CLIFOR
			cLoja   := SD5->D5_LOJA
		EndIf
	EndIf
	aParam150[12] := cCliFor         //-- Cliente/Fornecedor
	aParam150[13] := cLoja           //-- Loja
	aParam150[14] := cTipoNF         //-- Tipo da Nota Fiscal
	aParam150[15] := cItem           //-- Item da Nota Fiscal
	aParam150[16] := cTM             //-- Tipo de Movimentacao
	aParam150[17] := cOrigLan        //-- Origem do Lancamento

	If lRet .And. (!lRadioF .Or. (lRadioF .And. cStatRF == '1'))
		lRet := WmsVldDest(cProduto, cLocDest, cEndDest, SDA->DA_LOTECTL, SDA->DA_NUMLOTE, /*cNumSerie*/, nQuant)
	EndIf

	If lRet
		If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
			Begin Transaction
			lRet := WmsTrfEnd(cProduto,cLocOrig,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,nQuant,nQtdNorma,lRadioF,cStatRF)
			//-- Se houve algum erro aborta toda a transação
			If !lRet
				DisarmTransaction()
			EndIf
			End Transaction
		ElseIf lRadioF .And. cStatRF == '2'
			lRet := WmsEndereca(lRadioF,cStatRF)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Calcula a quantidade que pode ser transferida gerando as movimentações de estoque.
//-----------------------------------------------------------------------------
Static Function WmsTrfEnd(cProduto,cLocOrig,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,nQuant,nQtdNorma,lRadioF,cStatRF)
Local lRet       := .T.
Local cTipoServ  := WmsTipServ(aParam150[09])  //-- Servico
Local cTarefa    := aParam150[10]  //-- Tarefa
Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO
Local nQtdMov    := 0

	//-- Verifica se a Atividade utiliza Radio Frequencia
	//-- Carregas as exceções das atividades no destino
	DLExcecoes(cTipoServ,cLocDest,cEstOrig,cEndOrig,cLocDest,cEstDest,cEndDest,aExcecoesO,aExcecoesD)
	//-- Verifica se a tarefa utiliza RF
	lRadioF := DLTarUsaRF(cTipoServ,cTarefa,aExcecoesO,aExcecoesD)
	//Equanto for maior que uma norma, vai endereçando a quantidade de uma norma
	While lRet .And. QtdComp(nQuant) > 0
		nQtdMov := Min(nQuant,nQtdNorma)
		lRet := WmsGrvEnd(cProduto,cLocDest,cEstDest,cEndDest,nQtdMov,lRadioF)
		If lRet
			nQuant -= nQtdMov
		EndIf
	EndDo
Return lRet

//-----------------------------------------------------------------------------
// Gera a movimentação para o endereço de destino considerando a norma.
// Caso a tarefa não utilize RF já é executada a movimentação do saldo.
//-----------------------------------------------------------------------------
Static Function WmsGrvEnd(cProduto,cLocDest,cEstDest,cEndDest,nQtdEnd,lRadioF)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cTarefa  := aParam150[10]  //-- Tarefa
Local aParam   := {}

Default lRadioF := (SuperGetMV("MV_RADIOF")=="S")

	//-- Monta o Array aParam para ser utilizado na Execucao das Atividades
	aParam     := aClone(aParam150)
	aParam[06] := nQtdEnd         //-- Quantidade Movimentada
	aParam[07] := dDataBase       //-- Data da Movimentacao
	aParam[08] := Time()          //-- Hora da Movimentacao
	aParam[18] := SDA->DA_LOTECTL //-- Lote
	aParam[19] := SDA->DA_NUMLOTE //-- Sub-Lote
	aParam[25] := cLocDest        //-- Armazem Destino
	aParam[26] := cEndDest        //-- Endereco Destino
	aParam[27] := cEstDest        //-- Estrutura Fisica Destino
	//-- Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
	DLXExecAti(cTarefa, aParam)
	If !lRadioF
		While Len(aParam150) < 34
			AAdd(aParam150,"")
		EndDo
		aParam150[34] := aParam[34]
		//Deve efetuar a movimentação de estoque
		lRet := WmsEndereca(.T.,'2')
	EndIf

RestArea(aAreaAnt)
Return lRet

