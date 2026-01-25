#include "PROTHEUS.ch"
#include "WMSXREAB.ch"

#DEFINE WMSXREAB01 "WMSXREAB01"
#DEFINE WMSXREAB02 "WMSXREAB02"
#DEFINE WMSXREAB03 "WMSXREAB03"
#DEFINE WMSXREAB04 "WMSXREAB04"
#DEFINE WMSXREAB05 "WMSXREAB05"

/*----------------------------------------------------------------------------+
| Esta rotina destina-se exclusivamente a funções relacionadas com as regras  |
| dos serviços de reabastecimento, sendo referente a geração e/ou a execução  |
| dos mesmos pelo coletor.                                                    |
+----------------------------------------------------------------------------*/
Static lDLGNSERI := ExistBlock("DLGNSERI")
Static lDLGQTDAB := ExistBlock("DLGQTDAB")

Static __cProduto := ""
Static __cLocOrig := ""
Static __cLocDest := ""
Static __cEstDest := ""
Static __cEndDest := ""
Static __cCarga   := ""
Static __cDocto   := ""
Static __cSerie   := ""
Static __nRegra   := 3
Static __xRegra   := CtoD('')
Static __cServico := ""
Static __cTarefa  := ""
Static __cOrdTar  := "01"
Static __lRastro  := .F.
Static __cTipRep  := "1" //Baixa a norma (Palete) completo

Function WmsAbastece(lRadioF, cStatRF, cTipReab, nQuantOS, cMotNReab, lReabDem)
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local lRet       := .T.
Local nQtdNorPkg := 0
Local cNSEBlock  := ""
Local lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')

Default lRadioF  := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF  := "1"
Default cTipReab := "M"
Default nQuantOS := 0
Default cMotNReab := ""
Default lReabDem  := .F.

	__cProduto := aParam150[01] //-- Produto
	__cLocOrig := aParam150[02] //-- Armazem Origem
	__cLocDest := aParam150[25] //-- Armazem
	__cEstDest := aParam150[27] //-- Estrutura
	__cEndDest := aParam150[26] //-- Endereco
	__cDocto   := aParam150[03]
	__cSerie   := aParam150[04]
	__nRegra   := aParam150[22] //-- Regra para o Apanhe - 1=Lote/2=Numero de Serie/3=Data
	__cServico := aParam150[09]
	__cTarefa  := aParam150[10]
	__cOrdTar  := aParam150[28]
	__lRastro  := Rastro(__cProduto)
	nQuant     := aParam150[06]
	__cCarga   := aParam150[23]

	If (lRadioF .And. cStatRF == '2')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
		Private lWmsMovPkg := .T.
		lRet := WmsMovEst(aParam150)
		//-- Reabastecimento Aumomático COMEÇO
		If lRet
			LiberaSep()
		EndIf
	Else
		If __nRegra == 1
			__xRegra := aParam150[18] //-- Lote
		ElseIf __nRegra == 2
			__xRegra := Space(TamSx3("DB_NUMSERI")[1]) //-- Numero de Serie
			If lDLGNSERI
				cNSEBlock := ExecBlock('DLGNSERI', .F., .F., {"DCF", __cProduto, __cLocOrig, nQuant})
				If ValType(cNSEBlock) == 'C'
					__xRegra := cNSEBlock
				EndIf
			EndIf
		ElseIf __nRegra == 3 .Or. __nRegra == 4
			__xRegra := Iif(__lRastro .And. !lConsVenc,aParam150[07],CtoD('')) //-- Data
			__nRegra := 4
		Else
			__xRegra := CtoD('') //-- Data em branco (soh quando o "__nRegra" for "0", para manter a compatibilidade)
			__nRegra := 4        //-- Quando o "__nRegra" for "0", eh redefinido como "3", para manter a compatibilidade.
		EndIf
		//-- Reabastecimento Automático FIM
		If (lRet := VldGeracao(@nQtdNorPkg))
			nQuantOS := 0
			lRet := ProcEstAbt(nQuant,lRadioF,nQtdNorPkg,cTipReab,@nQuantOS,@cMotNReab,lReabDem)
		EndIf
		If lRet .And. ( __lSX8 ) .And. QtdComp(nQuantOS) > 0
			ConfirmSX8()
		EndIf
	EndIf

RestArea(aAreaDCF)
RestArea(aAreaAnt)
Return lRet

/*/----------------------------------------------------------------------------
----------------------------------------------------------------------------/*/
//-- Cria uma ordem de serviço para reabastecimento
Static Function VldGeracao(nQtdNorPkg)
Local aAreaAnt   := GetArea()
Local aAreaDC3   := DC3->(GetArea())
Local aAreaDC5   := DC5->(GetArea())
Local lRet       := .T.

	DC3->(DbSetOrder(2)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
	If DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocDest+__cEstDest))
		__cTipRep := IIf(Empty(DC3->DC3_TIPREP),'1',DC3->DC3_TIPREP)
		If Empty(__cServico)
			__cServico := DC3->DC3_REABAS
		EndIf
	Else
		WmsMessage(WmsFmtMsg(STR0002,{{"[VAR01]",__cProduto},{"[VAR02]",__cLocDest},{"[VAR03]",__cEstDest}}),WMSXREAB01,1) // "Produto/Armazém [VAR01]/[VAR02] não possui sequencia de abastecimento para a estrutura [VAR03] (PICKING)."
		lRet := .F.
	EndIf

	If lRet
		nQtdNorPkg := DLQtdNorma(__cProduto, __cLocDest, __cEstDest, Nil, .T., __cEndDest)
		//Se não encontrou uma sequencia de abastecimento de PICKING para o item
		If nQtdNorPkg == 0
			WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",__cProduto}}),WMSXREAB02,1) // "O produto [VAR01] não possui norma cadastrada para estrutura do tipo PICKING."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. Empty(__cServico)
		//-- Carrega o serviço padrão de reabastecimento
		DC5->(DbSetOrder(3)) //DC5_FILIAL+DC5_FUNEXE
		If DC5->(lRet:=MsSeek(xFilial('DC5')+'000003'))
			__cServico := DC5->DC5_SERVIC
			__cTarefa  := DC5->DC5_TAREFA
			__cOrdTar  := DC5->DC5_ORDEM
		Else
			//Não existe um serviço de reabastecimento cadastrado.
			WmsMessage(STR0005,WMSXREAB03,1) // "Não foi possível realizar o reabastecimento, pois não existe serviço de reabastecimento cadastrado."
			lRet := .F.
		EndIf
	EndIf
	//-- Caso ainda não tenha definido deve buscar a tarefa de reabastecimento
	If lRet .And. Empty(__cTarefa)
		DC5->(DbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
		If DC5->(MsSeek(xFilial('DC5')+__cServico))
			While DC5->(!Eof())
				If DC5->DC5_FUNEXE == '000003'
					__cTarefa := DC5->DC5_TAREFA
					__cOrdTar := DC5->DC5_ORDEM
					Exit
				EndIf
				DC5->(DbSkip())
			EndDo
		EndIf
	EndIf
	If lRet .And. Empty(__cTarefa)
		WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",__cProduto}}),WMSXREAB05,1) // "Não foi possível determinar o serviço e/ou tarefa de reabastecimento para o produto [VAR01]."
		lRet := .F.
	EndIf

RestArea(aAreaDC5)
RestArea(aAreaDC3)
RestArea(aAreaAnt)
Return lRet

/*/----------------------------------------------------------------------------
 Cria uma ordem de serviço para reabastecimento
----------------------------------------------------------------------------/*/
Static Function CriaDCFAbt(nPosDCF,nQuant,cTipReab)
Local lRet    := .T.

Default cTipReab := "M"

	//Criando a base para a OS
	AFill(aParam150,Nil)
	aParam150[01] := __cProduto                 //-- Produto
	aParam150[02] := __cLocOrig                 //-- Armazem Origem
	aParam150[03] := Iif(cTipReab=="M",__cDocto,GetSX8Num('DCF', 'DCF_DOCTO')) //-- Documento
	aParam150[04] := Iif(cTipReab=="M",__cSerie,CriaVar('DCF_SERIE', .F.))  //-- Serie
	aParam150[05] := ProxNum()
	aParam150[06] := nQuant
	aParam150[07] := dDataBase                  //-- Data da Movimentacao
	aParam150[09] := __cServico                 //-- Serviço
	aParam150[12] := CriaVar("DCF_CLIFOR", .F.) //-- Cliente/Fornecedor
	aParam150[13] := CriaVar("DCF_LOJA", .F.)   //-- Loja
	aParam150[17] := "DCF"      //-- Origem de Movimentacao
	aParam150[22] := __nRegra   //-- Regra de Apanhe (1=Lote/2=N.Serie/3=Data)
	aParam150[23] := __cCarga   //-- Carga
	aParam150[25] := __cLocDest //-- Armazem Destino
	aParam150[26] := __cEndDest //-- Endereco Destino
	aParam150[27] := __cEstDest //-- Estrutura Fisica Destino
	aParam150[28] := __cOrdTar  //-- Ordem da Tarefa
	aParam150[29] := "ZZ"       //-- Ordem da Atividade
	lRet := WmsCriaDCF("DCF", 1, Nil, aParam150, @nPosDCF)
	If lRet
		DCF->(MsGoTo(nPosDCF)) //Posiciona para buscar o ID do DCF
		aParam150[32] := DCF->DCF_ID
		If cTipReab == "D"
			RecLock('DCF', .F.)
			If WmsCarga(__cCarga)
				DCF->DCF_DOCORI  := __cCarga
			Else
				DCF->DCF_DOCORI := __cDocto
				DCF->DCF_SERORI := __cSerie
			EndIf
			DCF->(MsUnLock())
		EndIf
	EndIf

Return lRet

/*/----------------------------------------------------------------------------
Processa estoque para reabastecimento
----------------------------------------------------------------------------/*/
Static Function ProcEstAbt(nQuant,lRadioF,nQtdNorPkg,cTipReab,nQuantOS,cMotNReab,lReabDem)
Local aAreaAnt   := GetArea()
Local aAreaDC3   := DC3->(GetArea())
Local lRet       := .T.
Local aSeqAbast  := {}
Local nSeqAbast  := 1
Local nQtdNorPul := 0
Local nPosDCF    := Iif(cTipReab $ "D|M",0,DCF->(Recno()))
Local nQuantOS2  := 0

Default cMotNReab := ""
Default lReabDem  := .F.

	//-- Carrega sequencias de abastecimento
	aSeqAbast := WmsSeqAbast(__cLocOrig,__cProduto,4) //Processo
	If Len(aSeqAbast) <= 0
		WmsMessage(WmsFmtMsg(STR0001,{{"[VAR01]",__cProduto},{"[VAR02]",__cLocDest}}),WMSXREAB04,1) //"O produto [VAR01] não possui sequencia de abastecimento para o armazém [VAR02]."
		lRet := .F.
	EndIf

	If lRet
		DC3->(DbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
		If __nRegra == 4
			//-- Como busca por data de validade, pode misturar as sequencias de abastecimento
			//-- Neste caso, utiliza como base o primeiro pulmão da sequência de abastecimento do produto
			DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+aSeqAbast[1]))
			nQtdNorPul := DLQtdNorma(__cProduto,__cLocOrig,DC3->DC3_TPESTR,/*cDesUni*/,.F.)
			//-- Busca sem considerar a ordem da sequencia de abastecimento
			lRet := ProcEndAbt(Nil,@nQuant,lRadioF,nQtdNorPul,cTipReab,@nQuantOS,@nPosDCF,nQtdNorPkg,@cMotNReab,lReabDem)
		Else
			//-- Realiza o apanhe dos produtos até que a quantidade seja zero
			Do While lRet .And. nSeqAbast <= Len(aSeqAbast) .And. QtdComp(nQuant) > QtdComp(0)
				//Busca dados Sequencia abastecimento
				DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+aSeqAbast[nSeqAbast]))
				//Determinando a quantidade da norma do pulmão
				nQtdNorPul := DLQtdNorma(__cProduto,__cLocOrig,DC3->DC3_TPESTR,/*cDesUni*/,.F.)
				// Estrutura física do endereço origem não cadastrada na sequência de abastecimento do produto
				// Neste caso utiliza como base a própria norma do picking para busca de saldo
				If QtdComp(nQtdNorPul) <= QtdComp(0)
					nQtdNorPul := nQtdNorPkg
				EndIf
				lRet := ProcEndAbt(DC3->DC3_TPESTR,@nQuant,lRadioF,nQtdNorPul,cTipReab,@nQuantOS,@nPosDCF,nQtdNorPkg,@cMotNReab,lReabDem)
				nSeqAbast++
			EndDo
		EndIf
	EndIf

	//Deve atualizar a quantidade na ordem de serviço gerada
	If lRet .And. nPosDCF > 0 .And. QtdComp(nQuantOS) > QtdComp(0)
		nQuantOS2 := ConvUm(__cProduto,nQuantOS,2)
		DCF->(MsGoTo(nPosDCF)) //Posiciona para buscar o ID do DCF
		RecLock('DCF', .F.)
		DCF->DCF_STSERV := '3'
		DCF->DCF_QUANT  := nQuantOS
		DCF->DCF_QTSEUM := nQuantOS2
		MsUnLock()
	EndIf

RestArea(aAreaDC3)
RestArea(aAreaAnt)
Return lRet

/*/----------------------------------------------------------------------------
Processa endereços para reabastecimento
----------------------------------------------------------------------------/*/
Static Function ProcEndAbt(cEstOrig,nQuant,lRadioF,nQtdNorPul,cTipReab,nQuantOS,nPosDCF,nQtdNorPkg,cMotNReab, lReabDem)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cAliasSld  := ""
Local nQtdAbast  := 0
Local nQtdAbasPE := 0
Local lNormaInt  := .F.
Local lRegraOK   := .T.
Local cTipoServ  := WmsTipServ(__cServico)  //-- Servico
Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO
Local lTarUsaRF  := .T.
Local nQtdMovto  := 0
Local aParam     := {}
Local lMultReab  := (SuperGetMV("MV_WMSMABP", .F., "N")=="S") //-- Gera múltiplos movimentos de reabastecimento
Local cLotepk    := {}
Local cMotivo    := ""
Local cMotRegra  := ""
Local lMistLote  := .F.
Default cEstOrig := Space(TamSX3("BF_ESTFIS")[1])
Default cTipReab := "M"
Default cMotNReab := ""
Default lReabDem  := .F.
Private lWmsMovPkg := .T. //-- Indica que a movimentação de estoque é para o endereço de picking

	//Se a quantidade a reabastecer no PICKING é menor que a norma do PULMAO vai tentar buscar no
	//armazem endereços que estejam com a quantidade menor que a norma do endereço, palete incompleto
	lNormaInt := Iif((QtdComp(nQuant) >= QtdComp(nQtdNorPul)),.T.,.F.)
	//-- Carregas as exceções das atividades, somente do destino
	DLExcecoes(cTipoServ,__cLocOrig,cEstOrig,Nil,__cLocDest,__cEstDest,__cEndDest,Nil,aExcecoesD)
 	
	lMistLote := WMSMistLot(__cProduto, __cLocDest, __cEndDest) //Retorna se mistura lote

	cAliasSld := QryEstEnd(cEstOrig,lNormaInt,lRadioF)
	While (cAliasSld)->(!Eof())
		lFoundD14 := .T.
		
		If !lMistLote .And. Empty(cLotepk) .And. Rastro(__cProduto)
			cLotepk := ProcLotEnd(cTipReab, lReabDem)
		EndIf

		If !lMistLote .And. !Empty(cLotepk) .AND. ((cAliasSld)->BF_LOTECTL <> cLotepk)
			cMotivo := STR0006 + AllTrim(cLotePk) + STR0007 + AllTrim((cAliasSld)->BF_LOTECTL) + ")." //"Lotes diferentes end. (XX) / reabast. (YY).
			(cAliasSld)->(DbSkip())
			Loop
		EndIf    

		//-- Se for por data de validade, não carregou previamente a estrutura fisica
		If __nRegra == 4 .And. (cAliasSld)->BF_ESTFIS != cEstOrig
			cEstOrig := (cAliasSld)->BF_ESTFIS
			//Determinando a quantidade da norma do pulmão
			nQtdNorPul := DLQtdNorma(__cProduto,__cLocOrig,(cAliasSld)->BF_ESTFIS,/*cDesUni*/,.F.)
			// Estrutura física do endereço origem não cadastrada na sequência de abastecimento do produto
			// Neste caso utiliza como base a própria norma do picking para busca de saldo
			If QtdComp(nQtdNorPul) <= QtdComp(0)
				nQtdNorPul := nQtdNorPkg
			EndIf
		EndIf

		//-- Desconsidera SBE não encontrado - falha de integridade
		SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
		If !SBE->(DbSeek(xFilial('SBE')+__cLocOrig+(cAliasSld)->BF_LOCALIZ+(cAliasSld)->BF_ESTFIS))			
			cMotivo := STR0008 + __cLocOrig+ "/" + AllTrim((cAliasSld)->BF_LOCALIZ) + ")." //Endereço não cadastradado. (SBE) (XX/YY).
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Desconsidera Enderecos Bloqueados
		If SBE->BE_STATUS == '3'
			cMotivo := STR0009 + __cLocOrig+ "/" + (cAliasSld)->BF_LOCALIZ + ")." //Endereço bloqueado. (SBE) (XX/YY).
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Descontar do saldo os movimentos de RF pendentes
		If QtdComp((cAliasSld)->BF_QTDLIB-(cAliasSld)->BF_QTDSPR) <= QtdComp(0)
			cMotivo := STR0010 //Saldo utilizado para outros movimentos.
			(cAliasSld)->(DbSkip())
			Loop
		EndIf

		lRegraOK := .F.
		If Empty(__nRegra)
			lRegraOK := .T.
		ElseIf __nRegra == 1
			lRegraOK := Iif(!Empty(__xRegra),(cAliasSld)->BF_LOTECTL==__xRegra,.T.)
			cMotRegra := STR0011 + AllTrim((cAliasSld)->BF_LOTECTL) + STR0014 + AllTrim(__xRegra) + ")." //Lotes diferentes (XX) e (YY).
		ElseIf __nRegra == 2
			lRegraOK := Iif(!Empty(__xRegra),(cAliasSld)->BF_NUMSERI==__xRegra,.T.)
			cMotRegra := STR0012 + AllTrim((cAliasSld)->BF_NUMSERI) + STR0014 + AllTrim(__xRegra) + ")." //Num. série diferentes (XX) e (YY).
		ElseIf __nRegra == 3 .Or. __nRegra == 4
			lRegraOK := Iif(!Empty(__xRegra),(cAliasSld)->B8_DTVALID>=__xRegra,.T.)
			cMotRegra := STR0013 + cValToChar((cAliasSld)->B8_DTVALID) + STR0014 + cValToChar(__xRegra) + ")." ////Validade diferentes (XX) e (YY).
		EndIf
		If !lRegraOK
			cMotivo := STR0015 + cMotRegra //Regra WMS violada : XXX"
			(cAliasSld)->(DbSkip())
			Loop
		EndIf

		//-- Determina a quantidade a ser apanhada no endereço
		If __cTipRep == '1' //-- Baixa a norma (Palete) completo
			//-- Se o solicitado for menor que uma norma, força a baixa uma norma completa ou o saldo do endereço
			If QtdComp(nQuant) < QtdComp(nQtdNorPul)
				nQtdAbast := Min((cAliasSld)->BF_SALDO,nQtdNorPul)
			Else
				nQtdAbast := Min((cAliasSld)->BF_SALDO,nQuant)
			EndIf
		Else
			nQtdAbast := Min((cAliasSld)->BF_SALDO,nQuant)
		EndIf
		//-- PE possibilita a redefinicao da quantidade a ser utilizada nos reabastecimentos.
		If lDLGQTDAB
			nQtdAbasPE := ExecBlock("DLGQTDAB",.F.,.F.,{__cProduto, __cLocDest, __cEstDest, __cEndDest, nQtdAbast, {(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,__cLocOrig,(cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_NUMSERI,nQtdAbast}})
			nQtdAbast  := If(ValType(nQtdAbasPE)=="N",nQtdAbasPE,nQtdAbast)
		EndIf
		If QtdComp(nQtdAbast) <= QtdComp(0)
			(cAliasSld)->(DbSkip())
			cMotivo := STR0016 //"Endereço descartado pelo PE DLENDAP."
			Loop
		EndIf

		//-- Se a ordem de serviço não estava criada até agora, cria a mesma
		If nPosDCF == 0
			If !(lRet := CriaDCFAbt(@nPosDCF, nQtdAbast, cTipReab))
				Exit
			EndIf
		EndIf

		//-- Carregas as exceções das atividades, somente da origem
		DLExcecoes(cTipoServ,__cLocOrig,(cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,__cLocDest,__cEstDest,__cEndDest,aExcecoesO,Nil)
		//-- Verifica se a tarefa utiliza RF
		lTarUsaRF := DLTarUsaRF(cTipoServ,__cTarefa,aExcecoesO,aExcecoesD)
		//Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
		While lRet .And. QtdComp(nQtdAbast) > QtdComp(0)
			nQtdMovto := Min(nQtdAbast,nQtdNorPul)
			//-- Monta o Array aParam para ser utilizado na Execucao das Atividades
			aParam     := aClone(aParam150)
			aParam[02] := __cLocOrig //-- Armazem Origem
			aParam[06] := nQtdMovto  //-- Quantidade Movimentada
			aParam[08] := Time()     //-- Hora da Movimentacao
			aParam[09] := __cServico //-- Servico
			aParam[10] := __cTarefa  //-- Tarefa
			aParam[15] := "01"       //-- Item da Nota Fiscal
			aParam[16] := "501"      //-- Tipo de Movimentacao
			aParam[18] := (cAliasSld)->BF_LOTECTL   //-- Lote
			aParam[19] := (cAliasSld)->BF_NUMLOTE   //-- Sub-Lote
			aParam[20] := (cAliasSld)->BF_LOCALIZ   //-- Endereco Origem
			aParam[21] := (cAliasSld)->BF_ESTFIS    //-- Estrutura Fisica Origem
			aParam[25] := __cLocDest //-- Armazem Destino
			aParam[26] := __cEndDest //-- Endereco Destino
			aParam[27] := __cEstDest //-- Estrutura Fisica Destino
			aParam[28] := __cOrdTar
			//-- Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
			If (lRet := DLXExecAti(__cTarefa, aParam))
				If !lTarUsaRF
					While Len(aParam150) < 34
						AAdd(aParam150,"")
					EndDo
					aParam150[34] := aParam[34]
					//-- Efetua a movimentação de estoque
					lRet := WmsMovEst(aParam)
				EndIf
			EndIf
			//-- Diminuindo a quantidade a ser separada
			If lRet
				nQtdAbast -= nQtdMovto
				nQuant    -= nQtdMovto
				nQuantOS  += nQtdMovto //-- Somando na OS
			EndIf
			//Se não gera multiplos reabastecimentos, sai ao gerar o primeiro
			If !lMultReab
				Exit
			EndIf
		EndDo
		//Se houve algum erro sai do processo
		If !lRet
			Exit
		EndIf
		//Se não gera multiplos reabastecimentos, sai ao gerar o primeiro
		If !lMultReab
			Exit
		EndIf
		//-- Conseguiu atender toda a quantidade solicitada
		If QtdComp(nQuant) <= QtdComp(0)
			Exit
		EndIf
		(cAliasSld)->(DbSkip())
	EndDo
	(cAliasSld)->(DbCloseArea())

	cMotNReab := cMotivo

RestArea(aAreaAnt)
Return lRet

/*/----------------------------------------------------------------------------
Efetua a consulta de saldo de estoque
----------------------------------------------------------------------------/*/
Static Function QryEstEnd(cEstOrig,lNormaInt,lRadioF)
Local cQuery       := ""
Local aTamSx3      := {}
Default lNormaInt  := .T.
Default lRadioF    := (SuperGetMV('MV_RADIOF')=="S")

	cQuery := " SBF.BF_ESTFIS,SBF.BF_LOCALIZ,SBF.BF_LOTECTL,"
	cQuery +=       " SBF.BF_NUMLOTE,SBF.BF_NUMSERI,SBF.R_E_C_N_O_ RECNOSBF,"
	If __lRastro
		cQuery +=    " SB8.B8_DTVALID,SB8.R_E_C_N_O_ RECNOSB8,"
	Else
		cQuery +=    " '        ' B8_DTVALID,0 RECNOSB8,"
	EndIf
	cQuery +=       " (SBF.BF_QUANT - SBF.BF_EMPENHO) BF_QTDLIB,"
	If lRadioF
		cQuery +=    " (CASE WHEN SDB.DB_QUANT IS NOT NULL THEN SDB.DB_QUANT ELSE 0 END) BF_QTDSPR,"
	Else
		cQuery +=    " 0 BF_QTDSPR,"
	EndIf
	cQuery +=       " ((SBF.BF_QUANT - SBF.BF_EMPENHO)"
	If lRadioF
		cQuery +=    "-(CASE WHEN SDB.DB_QUANT IS NOT NULL THEN SDB.DB_QUANT ELSE 0 END)"
	EndIf
	cQuery +=       ") BF_SALDO"
	cQuery +=  " FROM "+RetSqlName("SBF")+" SBF"+;
				 " INNER JOIN "+RetSqlName("SBE")+" SBE"+;
					 " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"+;
					" AND SBE.BE_LOCAL = SBF.BF_LOCAL"+;
					" AND SBE.BE_LOCALIZ = SBF.BF_LOCALIZ"+;
					" AND SBE.D_E_L_E_T_ = ' '"
	If __lRastro
		cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8"+;
						 " ON SB8.B8_FILIAL = '"+xFilial("SB8")+"'"+;
						" AND SB8.B8_PRODUTO = SBF.BF_PRODUTO"+;
						" AND SB8.B8_LOCAL = SBF.BF_LOCAL"+;
						" AND SB8.B8_LOTECTL = SBF.BF_LOTECTL"+;
						" AND SB8.B8_NUMLOTE = SBF.BF_NUMLOTE"+;
						" AND SB8.B8_SALDO > 0"+;
						" AND SB8.D_E_L_E_T_ = ' '"
	EndIf

	cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"+;
					 " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"+;
					" AND DC8.DC8_CODEST = SBE.BE_ESTFIS"+;
					" AND DC8.D_E_L_E_T_ = ' '"
	If lRadioF
		cQuery +=" LEFT JOIN ("+;
				  "SELECT DB_LOCAL,DB_LOCALIZ,DB_LOTECTL,DB_NUMLOTE,SUM(DB_QUANT) DB_QUANT"+;
				  " FROM "+RetSqlName("SDB")+" SDB"+;
				 " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"+;
					" AND SDB.DB_PRODUTO = '"+__cProduto+"'"+;
					" AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"+;
					" AND SDB.DB_ESTORNO = ' '"+;
					" AND SDB.DB_ATUEST  = 'N'"+;
					" AND SDB.DB_STATUS IN ('4','3','2','-')"+;
					" AND SDB.D_E_L_E_T_ = ' '"+;
					" AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
													" FROM "+RetSqlName("SDB")+" SDBM"+;
												  " WHERE SDBM.DB_FILIAL  = SDB.DB_FILIAL"+;
													 " AND SDBM.DB_PRODUTO = SDB.DB_PRODUTO"+;
													 " AND SDBM.DB_DOC     = SDB.DB_DOC"+;
													 " AND SDBM.DB_SERIE   = SDB.DB_SERIE"+;
													 " AND SDBM.DB_CLIFOR  = SDB.DB_CLIFOR"+;
													 " AND SDBM.DB_LOJA    = SDB.DB_LOJA"+;
													 " AND SDBM.DB_SERVIC  = SDB.DB_SERVIC"+;
													 " AND SDBM.DB_TAREFA  = SDB.DB_TAREFA"+;
													 " AND SDBM.DB_IDMOVTO = SDB.DB_IDMOVTO"+;
													 " AND SDBM.DB_ESTORNO = ' '"+;
													 " AND SDBM.DB_ATUEST  = 'N'"+;
													 " AND SDBM.DB_STATUS IN ('4','3','2','-')"+;
													 " AND SDBM.D_E_L_E_T_ = ' ' )"+;
				 " GROUP BY DB_LOCAL,DB_LOCALIZ,DB_LOTECTL,DB_NUMLOTE) SDB"+;
					 " ON SDB.DB_LOCAL   = SBF.BF_LOCAL"+;
					" AND SDB.DB_LOCALIZ = SBF.BF_LOCALIZ"+;
					" AND SDB.DB_LOTECTL = SBF.BF_LOTECTL"+;
					" AND SDB.DB_NUMLOTE = SBF.BF_NUMLOTE"
	EndIf

	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+"'"+;
					" AND SBF.BF_LOCAL   = '"+__cLocOrig+"'"+;
					" AND SBF.BF_PRODUTO = '"+__cProduto+"'"+;
					" AND SBF.BF_QUANT > 0"+;
					" AND DC8.DC8_TPESTR = '1'"+; //-- Somente estrutura pulmao
					" AND SBE.BE_STATUS <> '3'"+;  //-- Não pode estar bloqueado
					" AND SBF.D_E_L_E_T_ = ' '"
	//Quando separa por data de validade não segue a sequencia de abastecimento
	If __nRegra != 4
		cQuery += " AND BF_ESTFIS = '"+cEstOrig+"'"
	EndIf
	cQuery += " AND (SBF.BF_QUANT - SBF.BF_EMPENHO) > 0"

	If __nRegra == 4
		cQuery += " ORDER BY B8_DTVALID, BF_PRIOR, BF_SALDO "+Iif(lNormaInt,"DESC","ASC")+", BF_LOCALIZ"
	Else
		If __nRegra == 1 //-- Lote
			cQuery += " ORDER BY BF_PRIOR, BF_LOTECTL, BF_NUMLOTE, BF_SALDO "+Iif(lNormaInt,"DESC","ASC")+", BF_LOCALIZ"
		ElseIf __nRegra == 2 //-- Numero de Serie
			cQuery += " ORDER BY BF_PRIOR, BF_NUMSERI, BF_SALDO "+Iif(lNormaInt,"DESC","ASC")+", BF_LOCALIZ"
		Else  //-- Data (Default)
			cQuery += " ORDER BY BF_PRIOR, B8_DTVALID, BF_SALDO "+Iif(lNormaInt,"DESC","ASC")+", BF_LOCALIZ"
		EndIf
	EndIf

	cAliasSld := GetNextAlias()
	cQuery := "%" + cQuery + "%"
	BeginSql Alias cAliasSld
		SELECT %Exp:cQuery%
	EndSql

	aTamSX3 := TamSx3('BF_QUANT');
	//-- Ajustando o tamanho dos campos da query
	TcSetField(cAliasSld,'BF_SALDO','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasSld,'B8_DTVALID','D',8,0)
	TcSetField(cAliasSld,'RECNOSBF', 'N',10,0)
	TcSetField(cAliasSld,'RECNOSB8', 'N',10,0)
Return cAliasSld

/*/----------------------------------------------------------------------------
Reinicio automatico das tarefas de separação com problema
----------------------------------------------------------------------------/*/
Static Function LiberaSep()
Local aAreaAnt  := GetArea()
Local aAreaSDB  := SDB->(GetArea())
Local cQuery    := ""
Local cAliasTmp := GetNextAlias()

	//Busca tarefas de separação com problema para fazer reinício automático
	cQuery := "SELECT SDB.R_E_C_N_O_ AS RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB, "+RetSqlName('DC5')+" DC5"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
	cQuery +=   " AND DB_PRODUTO = '"+__cProduto+"'"
	cQuery +=   " AND DB_LOCAL   = '"+__cLocDest+"'"
	cQuery +=   " AND DB_LOCALIZ = '"+__cEndDest+"'"
	cQuery +=   " AND DB_STATUS  = '"+cStatProb+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_OCORRE  = '9999'" // Indica que a atividade depende de reabastecimento
	cQuery +=   " AND DC5_FILIAL = '"+xFilial('DC5')+"'"
	cQuery +=   " AND DC5_SERVIC = DB_SERVIC"
	cQuery +=   " AND DC5_ORDEM  = DB_ORDTARE"
	cQuery +=   " AND DC5_TAREFA = DB_TAREFA "
	cQuery +=   " AND DC5_FUNEXE IN ('000002','000008')"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DC5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)

	While !(cAliasTmp)->(Eof())
		SDB->(DbGoTo((cAliasTmp)->RECNOSDB))

		RecLock('SDB',.F.)
		SDB->DB_STATUS := cStatAExe
		SDB->DB_OCORRE := ""
		SDB->DB_HRINI  := Time()
		SDB->DB_DATA   := Date()
		SDB->DB_HRFIM  := Space(Len(SDB->DB_HRFIM))
		SDB->(MsUnlock())

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return .T.

//Esta função deverá buscar o Tipo de endereçamento da sequencia de abastecimento se nao permite
//misturar lotes, será carregado o lote previsto ou em estoque.
Static Function ProcLotEnd(cTipReab, lReabDem)
	Local cRetLote := ""
	Local cAliasSBF := NIL
	Local cStatExec := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indincando Atividade a Executar
	Local lWMSLREB  := SuperGetMV('MV_WMSLREB', .F., .F.) //Permite gerar reabastecimentos mesmo que a sequencia de ab nao permite misturar lote no picking

	If !lWMSLREB .Or. !lReabDem //Modo sem parametro(processo normal) ou percentual de reposicao
		cAliasSBF:= GetNextAlias()
		BeginSql Alias cAliasSBF     
			SELECT DISTINCT BF_LOTECTL,BF_QUANT
			FROM %Table:SBF% SBF
			WHERE SBF.BF_FILIAL  = %xFilial:SBF%
			AND SBF.BF_LOCAL   = %Exp:__cLocDest%
			AND SBF.BF_LOCALIZ = %Exp:__cEndDest%
			AND SBF.BF_PRODUTO = %Exp:__cProduto%
			AND SBF.BF_QUANT > 0
			AND SBF.%NotDel% 
		EndSql
		IF (cAliasSBF)->(!Eof())
			cRetLote := (cAliasSBF)->BF_LOTECTL
		EndIf
		If Empty(cRetLote)
			cRetLote := WMSSaiPrev(__cProduto, __cLocDest, __cEndDest, cStatExec) //Peenche lote da saida prevista ou deixa vazio
		EndIf
		(cAliasSBF)->(DbCloseArea())

	ElseIf lWMSLREB .And. cTipReab = "D" .And. lReabDem //Permite misturar lote no picking, mesmo que seq de abastecimento nao permite no picking (reabastecimento por demanda)
		cRetLote := ' '
	EndIf

Return cRetLote


/*/{Protheus.doc} WMSMistLot
	Informa se na sequencia de abastecimento permite misturar lote
	@since 28/04/2023
/*/
Function WMSMistLot(cProduto, cLocDest, cEndDest)
	Local lRet := .T.
	Local cAliasDC3 := Nil

	cAliasDC3:= GetNextAlias()
	BeginSql Alias cAliasDC3
		SELECT DISTINCT 1 
		  FROM  %Table:SBE% SBE
 		 INNER JOIN  %Table:DC3% DC3
 		    ON DC3.DC3_FILIAL = %xFilial:DC3%
 		   AND DC3.DC3_LOCAL = SBE.BE_LOCAL
 		   AND DC3.DC3_CODPRO = %Exp:cProduto%
 		   AND DC3.DC3_TPESTR = SBE.BE_ESTFIS
		   AND DC3.DC3_TIPEND = '3'
		   AND DC3.%NotDel%
		 WHERE SBE.BE_FILIAL = %xFilial:SBE%
		   AND SBE.BE_LOCAL = %Exp:cLocDest%
		   AND SBE.BE_LOCALIZ = %Exp:cEndDest%
		   AND SBE.%NotDel%
    EndSql
	If (cAliasDC3)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasDC3)->(DbCloseArea()) 
Return lRet


/*/{Protheus.doc} WMSSaiPrev
	Obtem o lote da saida prevista
	@since 28/04/2023
/*/
Function WMSSaiPrev(cProduto, cLocDest, cEndDest, cStatExec)
	Local cLoteTemp := ' '
	Local cAliasSDB := Nil

	cAliasSDB:= GetNextAlias()
	BeginSql Alias cAliasSDB  
		SELECT DISTINCT SDB.DB_LOTECTL 
		FROM %Table:SDB% SDB
		WHERE SDB.DB_FILIAL = %xFilial:SDB%
		AND SDB.DB_LOCAL = %Exp:cLocDest%
		AND SDB.DB_ENDDES = %Exp:cEndDest%
		AND SDB.DB_PRODUTO = %Exp:cProduto%
		AND SDB.DB_DATAFIM = ' ' 
		AND SDB.DB_ESTORNO = ' '
		AND (SDB.DB_STATUS = %Exp:cStatExec% OR SDB.DB_STATUS = '-')
		AND SDB.%NotDel%
	EndSql
	If (cAliasSDB)->(!Eof())
		cLoteTemp := (cAliasSDB)->DB_LOTECTL
	EndIf
	(cAliasSDB)->(DbCloseArea())
Return cLoteTemp
