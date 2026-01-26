#include "PROTHEUS.ch"
#include "WMSXFUNC.ch"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNC                                                           |
+---------+--------------------------------------------------------------------+
|Autor    | Jackson Patrick Werka                                              |
+---------+--------------------------------------------------------------------+
|Data     | 05/05/2014                                                         |
+---------+--------------------------------------------------------------------+
|Objetivo | Esta função tem por objetivo reunir todas as informações relativas |
|         | ao processo de expedição WMS, como busca de saldo, geração dos     |
|         | movimentos de separação e avaliação da necessidade de              |
|         | reabastecimento de picking.                                        |
+---------+--------------------------------------------------------------------+

*/

/*/-----------------------------------------------------------------------------
Indica se deve ou não imprimir o relatório de busca de saldo
-----------------------------------------------------------------------------/*/
Static __lSwLogSld := .F.
Function WmsLogSld(lSwLogSld)
Local lOldSwLog := __lSwLogSld
	If ValType(lSwLogSld) == 'L'
		__lSwLogSld := lSwLogSld
	EndIf
Return lOldSwLog

Static lDLGNSERI  := ExistBlock("DLGNSERI")
Static lWMSXCONV  := ExistBlock("WMSXCONV")
Static lDLENDAP   := ExistBlock('DLENDAP')
Static lDLABAEND  := ExistBlock('DLABAEND')
Static lWMSFIFO   := ExistBlock("WMSFIFO")
Static lWMSFIFO2  := ExistBlock("WMSFIFO2")
Static lWMSMULP   := ExistBlock("WMSMULP")
Static lWMSQYSEP  := ExistBlock("WMSQYSEP")

Static __cMsgOsPr := ""
Static __cOrigem  := ""
Static __cCarga   := ""
Static __cDocto   := ""
Static __cSerie   := ""
Static __cProduto := ""
Static __cLocOrig := ""
Static __cLocDest := ""
Static __cEstDest := ""
Static __cEndDest := ""
Static __cIDDCF   := ""
Static __nRegra   := 3
Static __xRegra   := CtoD('')
Static __cServico := ""
Static __cTarefa  := ""
Static __lRastro  := .F.
Static __lLibSC9  := .T.
Static __lPrdPul  := .T.
Static __lPrdPkg  := .F.
Static __aEndPkg  := {}
Static __aReabGer := {}
Static __lSpUsaRF := .T.


/*/{Protheus.doc} WmsApanhe
Gera e/ou executa o apanhe de expedição.
@author Jackson Patrick Werka
@since 05/05/2014

@param [lRadioF], Lógico, Indicador se utiliza radio frequência
@param [cStatRF], Caracter, Status do RF, onde: 1 - Geração, 2 - Execução

@return Lógico Separação realizada com sucesso
/*/
Function WmsApanhe(lRadioF, cStatRF, lWmsAtzSC9, lWmsLibSC9)
Local aAreaAnt   := GetArea()
Local cPedido    := ""
Local cItem      := ""
Local cSequencia := ""
Local lRet       := .T.
Local nQuant     := 0
Local cNumSerie  := Space(TamSx3("DB_NUMSERI")[1]) //-- Numero de Serie
Local cNSEBlock  := ''
Local lCarga     := .F.
Local lCargaAnt  := .F.
Local lCargaPE   := .F.
Local lCrossDoc  := .F.
Local cMensagem  := ""
Local lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')

Local aRetPE     := {}
Local nFatConv   := 0
Local nQtdUn     := 0
Local nQtdCx     := 0
Local lAtvPad    := .T.
Local lAtvEmb    := .T.
Local nAliasSld  := 0

Default lRadioF    := (SuperGetMV('MV_RADIOF')=='S')
Default cStatRF    := '1'
Default lWmsAtzSC9 := .T.
Default lWmsLibSC9 := .T.

Private cTipoSDB  := 'E' //-- Variável que será utilizada para preencher o campo DB_TIPO (E = para movimentos padrão, B = para mapa de separação de embalagem)
Private aAliasSld := {}

	Begin Transaction
	__cProduto := aParam150[01]
	__cLocOrig := aParam150[02]
	__cDocto   := aParam150[03]
	__cSerie   := aParam150[04]
	__cOrigem  := aParam150[17]
	__cLocDest := aParam150[25]
	__cEndDest := aParam150[26]
	__cEstDest := aParam150[27]
	__nRegra   := aParam150[22] //-- Regra para o Apanhe - 1=Lote/2=Numero de Serie/3=Data
	__cServico := aParam150[09]
	__cTarefa  := aParam150[10]
	__lRastro  := Rastro(__cProduto)
	nQuant     := aParam150[06]
	__lLibSC9  := lWmsLibSC9
	__cCarga   := aParam150[23]
	cSequencia := aParam150[05]
    __cIDDCF   := aParam150[32]

	__cMsgOsPr := "SIGAWMS - OS "+AllTrim(__cDocto)+Iif(!Empty(__cSerie),"/"+AllTrim(SubStr(__cSerie,1,3)),"")+STR0043+AllTrim(__cProduto)+CRLF

	If !lRadioF .Or. (lRadioF .And. cStatRF == '1')
		__aEndPkg  := {}
		__aReabGer := {}
		__lSpUsaRF := .T.
		aParam150[15] := "01"  //-- Item da Nota Fiscal
		aParam150[16] := "501" //-- Tipo de Movimentacao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera e Consiste os Parametros passados pela aParam150            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lCarga     := WmsCarga(__cCarga)
		lCrossDoc  := WmsVldSrv('9',__cServico,__cOrigem,__cCarga,__cProduto,aParam150[24],,)

		If !(lRet:=QtdComp(nQuant)>QtdComp(0))
			cMensagem := __cMsgOsPr
			cMensagem += STR0001+AllTrim(__cLocOrig)+'/'+AllTrim(__cProduto)+'.' //'Quantidade de apanhe inválida para o Armazém/Produto '
			WmsMessage(cMensagem,"WmsApanhe",1)
		EndIf

		If lRet
			If __cOrigem == 'SD3'
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona o SD3                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SD3->(DbSetOrder(3))
				If !(lRet:=SD3->(MsSeek(xFilial('SD3')+__cProduto+__cLocOrig+cSequencia, .F.)))
					cMensagem := __cMsgOsPr
					cMensagem += STR0003+AllTrim(__cProduto)+STR0006 //'Produto '###' não encontrado no arquivo de Movimentações Internas (SD3).'
					WmsMessage(cMensagem,"WmsApanhe",1)
				Else
					aParam150[16] := SD3->D3_TM
					aParam150[18] := SD3->D3_LOTECTL
					aParam150[19] := SD3->D3_NUMLOTE
				EndIf
			ElseIf __cOrigem == 'SC9'
				cPedido := PadR(__cDocto,TamSx3("C6_NUM")[1])
				cItem   := PadR(__cSerie,TamSx3("C6_ITEM")[1])
				//-- Valida o item do pedido
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If lRet .And. SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM+SC6->C6_PRODUTO != xFilial('SC6')+cPedido+cItem+__cProduto
					If !(lRet:=SC6->(MsSeek(xFilial('SC6')+cPedido+cItem+__cProduto, .F.)))
						cMensagem := __cMsgOsPr
						cMensagem += STR0003+AllTrim(__cProduto)+STR0010 //'Produto '###' não encontrado no arquivo de montagem de pedidos (SC6).'
						WmsMessage(cMensagem,"WmsApanhe",1)
					EndIf
				EndIf
				If lRet
					aParam150[16] := SC6->C6_TES
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definicao do Tipo de Regra de Apanhe ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//-- Se for cross-docking não faz a busca por validade
		If lRet
			If lCrossDoc .And. __nRegra == 4
				__nRegra := 3
			EndIf
			If __nRegra == 1
				__xRegra := aParam150[18] //-- Lote
			ElseIf __nRegra == 2
				__xRegra := cNumSerie //-- Numero de Serie
				If lDLGNSERI
					cNSEBlock := ExecBlock('DLGNSERI', .F., .F., {__cOrigem, __cProduto, __cLocOrig, nQuant})
					If ValType(cNSEBlock) == 'C'
						__xRegra := cNSEBlock
					EndIf
				EndIf
			ElseIf __nRegra == 3 .Or. __nRegra == 4
				__xRegra := Iif(__lRastro .And. !lConsVenc,aParam150[07],CtoD('')) //-- Data
			Else
				__xRegra := CtoD('') //-- Data em branco (soh quando o "__nRegra" for "0", para manter a compatibilidade)
				__nRegra := 3        //-- Quando o "__nRegra" for "0", eh redefinido como "3", para manter a compatibilidade.
			EndIf
		EndIf

		//-- Força a utilização de um endereco destino
		If lRet .And. (Empty(__cEndDest) .Or. Empty(__cEstDest))
			If lRadioF .And. ISTelNet()
				cMensagem := __cMsgOsPr+STR0017 //"O endereço destino não foi informado."
				WmsMessage(cMensagem,"WmsApanhe",1)
				lRet := .F.
			Else
				If Empty(__cEndDest)
					__cEndDest := Space(Len(SBF->BF_LOCALIZ))
				EndIf
				If Empty(__cEstDest)
					__cEstDest := Space(Len(SBF->BF_ESTFIS))
				EndIf

				DLPergEnd(@__cEndDest,.T.,.T.,'2',DCF->DCF_LOCAL) //"Identifique o destino do Serviço WMS:"
			EndIf
		EndIf

		//-- Preenche DCF com os endereco e estrutura escolhidos
		//-- Neste caso está executando a OS, portanto a DCF está posicionada
		If lRet .And. (Empty(DCF->DCF_ENDER) .Or. Empty(DCF->DCF_ESTFIS))
			__cEstDest := Posicione('SBE',1,xFilial('SBE')+DCF->DCF_LOCAL+__cEndDest,'BE_ESTFIS')
			RecLock('DCF')
			DCF->DCF_ENDER  := __cEndDest
			DCF->DCF_ESTFIS := __cEstDest
			MsUnlock()
			lCargaAnt := lCarga
			If ExistBlock("DLENDOSE") //Enderçamento Ordem Serviço Expedição
				lCargaPE := ExecBlock('DLENDOSE',.F.,.F.,{lCarga})
				If ValType(lCargaPE) =='L'
					lCarga := lCargaPE
				EndIf
			EndIf
			//-- Atualiza as outras ordens de serviço, caso existam
			cQuery := "UPDATE "+RetSqlName('DCF')
			cQuery += " SET DCF_ENDER = '"+__cEndDest+"', DCF_ESTFIS = '"+__cEstDest+"'"
			cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
			cQuery += " AND DCF_SERVIC   = '"+DCF->DCF_SERVIC+"'"
			If lCarga
				cQuery += " AND DCF_CARGA  = '"+DCF->DCF_CARGA+"'"
			Else
				cQuery += " AND DCF_DOCTO  = '"+DCF->DCF_DOCTO+"'"
				cQuery += " AND DCF_CLIFOR = '"+DCF->DCF_CLIFOR+"'"
				cQuery += " AND DCF_LOJA   = '"+DCF->DCF_LOJA+"'"
			EndIf
			cQuery += " AND DCF_ENDER  = '"+Space(Len(DCF->DCF_ENDER))+"'"
			cQuery += " AND DCF_ESTFIS = '"+Space(Len(DCF->DCF_ESTFIS))+"'"
			cQuery += " AND D_E_L_E_T_ = ' '"
			lRet := (TcSQLExec(cQuery) >= 0)
			If !lRet
				cMensagem := 'O.S. '+AllTrim(DCF->DCF_DOCTO)+' / '+TcSQLError()
				WmsMessage(cMensagem,"WmsApanhe",1)
			Else
				//-- Atualiza as liberações do pedido
				cQuery := "UPDATE "+RetSqlName('SC9')
				cQuery += " SET C9_ENDPAD   = '"+__cEndDest+"'"
				cQuery += " WHERE C9_FILIAL = '"+xFilial('SC9')+"'"
				cQuery += " AND C9_SERVIC   = '"+DCF->DCF_SERVIC+"'"
				If lCarga
					cQuery += " AND C9_CARGA   = '"+DCF->DCF_CARGA+"'"
				Else
					cQuery += " AND C9_PEDIDO  = '"+DCF->DCF_DOCTO+"'"
					cQuery += " AND C9_CLIENTE = '"+DCF->DCF_CLIFOR+"'"
					cQuery += " AND C9_LOJA    = '"+DCF->DCF_LOJA+"'"
				EndIf
				cQuery += " AND C9_ENDPAD  = '"+Space(Len(SC9->C9_ENDPAD))+"'"
				cQuery += " AND D_E_L_E_T_ = ' '"
				lRet := (TcSQLExec(cQuery) >= 0)
				If !lRet
					cMensagem := 'Pedido '+AllTrim(DCF->DCF_DOCTO)+' / '+TcSQLError()
					WmsMessage(cMensagem,"WmsApanhe",1)
				EndIf
			EndIf
			lCarga := lCargaAnt
		EndIf

		If lRet
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial('SB1')+__cProduto))
			//Tratamento para quando o produto gera quantidades unitizadas para embalagem
			If WmsPrdEmb(__cProduto)
				//-- Fator de conversao do produto
				nFatConv := SB1->B1_CONV
				If lWMSXCONV
					aRetPE := ExecBlock("WMSXCONV",.F.,.F.,{__cLocOrig,__cProduto})
					nFatConv := aRetPE[1]
				EndIf
				//-- Regras para a geracao das atividades
				//-- Se a quantidade da total for menor que o fator de conversão do produto, gera somente atividade de embalagem
				If QtdComp(nQuant) < QtdComp(nFatConv)
					lAtvPad := .F.
					lAtvEmb := .T.
					nQtdUn:= nQuant
				//-- Se a quantidade do unitizador for igual ao fator de conversão do produto, gera somente atividade padrão
				ElseIf QtdComp(nQuant) == QtdComp(nFatConv)
					lAtvPad := .T.
					lAtvEmb := .F.
					nQtdCx  := nQuant
				//-- Se a quantidade do unitizador for maior que o fator de conversão do produto efetua o cálculo
				Else
					nQtdCx := Int( nQuant / nFatConv ) * nFatConv
					//-- Se o resultado do cálculo for igual a quantidade do unitizador, gera somente atividade padrão
					If QtdComp(nQuant) == QtdComp(nQtdCx)
						lAtvPad := .T.
						lAtvEmb := .F.
					//-- Gera atividade padrao e atividade de embalagem
					Else
						lAtvPad := .T.
						lAtvEmb := .T.
						nQtdUn := nQuant - nQtdCx
					EndIf
				EndIf
			Else
				lAtvPad := .T.
				lAtvEmb := .F.
				nQtdCx := nQuant
			EndIf
			//-- Carregas as informações se o produto tem pulmão e picking
			__lPrdPul  := PrdTemPulm(__cLocOrig,__cProduto)
			__lPrdPkg  := PrdTemPkg(__cLocOrig,__cProduto)
			//Busca estoque de saída para atividade padrão
			If lAtvPad
				lRet := WmsEstSai(nQtdCx,lCrossDoc,lRadioF)
			EndIf

			//Busca estoque de saída para atividade de embalagem
			If lRet .And. lAtvEmb
				cTipoSDB := 'B'
				lRet     := WmsEstSai(nQtdUn,lCrossDoc,lRadioF)
			EndIf
		EndIf
	EndIf
	If !lRet
		DisarmTransaction()
	EndIf
	End Transaction

	//Apaga as temporárias caso use os pontos de entrada WmsFIFO ou WmsFIFO2 ou tenha pesquisa por picking futuro
	For nAliasSld := 1 To Len(aAliasSld)
		DelTabTmp(aAliasSld[nAliasSld])
	Next nAliasSld

	// Gera novamente os reabastecimentos que foram eliminados no desarme da transação
	// quando a tarefa de separação não utilizar RF e o reabastecimento utilizar.
	If !lRet .And. Len(__aReabGer) > 0 .And. !__lSpUsaRF
		Begin Transaction
			ReGerReab()
		End Transaction
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Efetua a busca dos saldos para serem feitos o apanhe de acordo com a Regra WMS
- Pode fazer a busca de saldo seguindo a sequencia de abastecimento na ordem
inversa, considerando apenas sequencias de endereçamento.
- Pode fazer a busca de saldo pela data de validade independente da sequencia
de abastecimento.
Com base nisto monta o mapa de separação da OS que está sendo executada.
-----------------------------------------------------------------------------/*/
Static Function WmsEstSai(nQuant,lCrossDoc,lRadioF)
Local aAreaAnt   := GetArea()
Local aAreaDC3   := DC3->(GetArea())
Local lRet       := .T.
Local aSeqAbast  := {}
Local aSeqAbPkg  := {}
Local nSeqAbast  := 0
Local cMensagem  := ""
Local lGeraAbast := .F.
Local nGerouReab := 0
Local lWmsQtAp   := SuperGetMV("MV_WMSQTAP",.F.,"N") == "S" //Reinicia a busca de saldo de forma unitária se a quantidade a separar for maior que a capacidade de expedição do picking
Local nQtdApMax  := 0
Local lReiSeqAb  := .F.
Local cTipoEstr  := ""
Local aBoxDC8    := RetSX3Box(Posicione('SX3',2,'DC8_TPESTR','X3CBox()'),,,1)
Local nSeek      := 0
Local lLogSld    := Type("aLogSld") == "A"

Default nQuant    := 0
Default lCrossDoc := .F.

	//-- Posiciona na maior sequencia de abastecimento do produto
	aSeqAbast := WmsSeqAbast(__cLocOrig,__cProduto,Iif(lCrossDoc,3,2)/*Processo*/)
	If Len(aSeqAbast) <= 0
		cMensagem := __cMsgOsPr
		cMensagem += STR0019+AllTrim(__cProduto)+'/'+AllTrim(__cLocOrig)+STR0020 //"Produto/Armazém '###' não possui sequência de abastecimento cadastrada (DC3)."
		WmsMessage(cMensagem,"WmsEstSai",1)
		lRet := .F.
	EndIf
	nSeqAbast := 1

	If lRet .And. lLogSld
		If Len(aLogSld) == 0 //Adiciona apenas na primeira vez
			AddParRel()
		EndIf
		
		AAdd(aLogSld,{DCF->DCF_CARGA,DCF->DCF_DOCTO,__cProduto,SB1->B1_DESC,nQuant,__nRegra,{},{},__cLocDest})
		AddinfProd()
	EndIf
	If lRet
		If __nRegra == 4
			If lLogSld
				AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0022,{{"[VAR01]",__cLocOrig}}),{}}) //"Armazém [VAR01] - Busca de saldo por data de validade"
			EndIf
			//-- Busca sem considerar a ordem da sequencia de abastecimento
			lRet := ProcEndExp(Nil,@nQuant,0,0,"3",lRadioF)
			If lRet .And. __lPrdPul .And. __lPrdPkg //-- Se tem Pulmão e Picking
				//-- Se sobrou saldo, deve verificar se tem reabastecimento pendente, para poder utilizar
				If lRet .And. QtdComp(nQuant) > QtdComp(0)
					If lLogSld
						AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0022+STR0049,{{"[VAR01]",__cLocOrig}}),{}}) // "Armazém [VAR01] - Busca de saldo por data de validade - Reabastecimentos anteriores."
					EndIf
					lRet := ProcEndExp(Nil,@nQuant,0,0,"3",lRadioF,.T.)
				EndIf
				//-- Se sobrou saldo, deve verificar se pode gerar reabastecimento para completar a separação
				If lRet .And. QtdComp(nQuant) > QtdComp(0)
					If lLogSld
						AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0059,{{"[VAR01]",__cLocOrig}}),{}}) // "Armazém [VAR01] - Geração de reabastecimento por demanda."
					EndIf
					// Busca somente pickigns
					aSeqAbPkg := WmsSeqAbast(__cLocOrig,__cProduto,6/*Processo*/)
					// Procede com a geração de reabastecimento por demanda
					lRet := GeraAbtDem(@lGeraAbast,nQuant,lRadioF,aSeqAbPkg)
					If lRet .And. lGeraAbast
						If lLogSld
							AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0022+STR0050,{{"[VAR01]",__cLocOrig}}),{}}) //"Armazém [VAR01] - Busca de saldo por data de validade"
						EndIf
						//-- Deve utilizar estes reabastecimentos pendente para a separação
						lRet := ProcEndExp(Nil,@nQuant,0,0,"3",lRadioF,.T.)
					EndIf
				EndIf
			EndIf
		Else
			DC3->(DbSetOrder(1)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_ORDEM
			DC8->(DbSetOrder(1))
			//-- Realiza o apanhe dos produtos até que a quantidade seja zero
			Do While lRet .And. nSeqAbast <= Len(aSeqAbast) .And. QtdComp(nQuant) > QtdComp(0)
				DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+aSeqAbast[nSeqAbast]))
				DC8->(DbSeek(xFilial('DC8')+DC3->DC3_TPESTR))
				If lLogSld
					If __nRegra == 3 .And. __lRastro
						// Neste caso só deve apresentar o cabeçalho novamente quando mudar o tipo de estrutura
						If cTipoEstr != DC8->DC8_TPESTR
							AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0052,{{"[VAR01]",__cLocOrig},{"[VAR02]",DC8->DC8_TPESTR},{"[VAR03]",Iif((nSeek := Ascan(aBoxDC8, { |x| x[ 2 ] == DC8->DC8_TPESTR})) > 0,AllTrim(aBoxDC8[nSeek,3]),"")}}),{}}) //"Armazém [VAR01] - Busca de saldo no tipo de estrutura [VAR02] - [VAR03]"
						EndIf
					Else
						AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0023,{{"[VAR01]",__cLocOrig},{"[VAR02]",DC3->DC3_TPESTR},{"[VAR03]",DC8->DC8_DESEST}}),{}}) //"Armazém [VAR01] - Busca de saldo na estrutura [VAR02] - [VAR03]"
					EndIf
				EndIf
				If DC8->DC8_TPESTR == '2' //Picking
					//Se permite alterar o tipo de apanhe do pulmão
					If lWmsQtAp .And. !lReiSeqAb
						//Busca a quantidade máxima para o apanhe
						nQtdApMax := ApMaxPic(DC3->DC3_TPESTR,DC3->DC3_NUNITI,DC3->DC3_PERAPM,DC3->DC3_QTDUNI)
						//Se a quantidade solicitada é maior que o apanhe máximo do picking
						If QtdComp(nQuant) > QtdComp(nQtdApMax)
							nSeqAbast := 1
							lReiSeqAb := .T.
							AddMsgLog(DC3->DC3_TPESTR,,,,,,nQuant,,WmsFmtMsg(STR0045,{{"[VAR01]",Str(nQtdApMax)}})) //"Reiniciando busca. Solicitado maior que apanhe máximo picking ([VAR01])." 
							Loop
						EndIf
					EndIf
					AAdd(aSeqAbPkg,aSeqAbast[nSeqAbast])
				EndIf
				If __nRegra == 3 .And. __lRastro .And. cTipoEstr == DC8->DC8_TPESTR
					nSeqAbast++
					Loop
				EndIf
				cTipoEstr := DC8->DC8_TPESTR
				If __nRegra == 3 .And. __lRastro
					lRet := ProcEndExp(DC3->DC3_TPESTR,@nQuant,0,0,"3",lRadioF,lReiSeqAb)
				Else
					lRet := ProcEstFis(DC3->DC3_TPESTR,@nQuant,lRadioF,,lReiSeqAb)
				EndIf
				nSeqAbast++
			EndDo
			If lRet .And. __lPrdPul .And. __lPrdPkg //-- Se tem Pulmão e Picking
				//-- Se sobrou saldo, deve verificar se tem reabastecimento pendente, para poder utilizar
				nSeqAbast := 1
				Do While lRet .And. nSeqAbast <= Len(aSeqAbPkg) .And. QtdComp(nQuant) > QtdComp(0)
					DC3->(MsSeek(xFilial('DC3')+__cProduto+__cLocOrig+aSeqAbPkg[nSeqAbast]))
					DC8->(DbSeek(xFilial('DC8')+DC3->DC3_TPESTR))
					If lLogSld
						AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0023+STR0049,{{"[VAR01]",__cLocOrig},{"[VAR02]",DC3->DC3_TPESTR},{"[VAR03]",DC8->DC8_DESEST}}),{}}) //"Armazém [VAR01] - Busca de saldo na estrutura [VAR02] - [VAR03] - Reabastecimentos anteriores."
					EndIf
					lRet := ProcEstFis(DC3->DC3_TPESTR,@nQuant,lRadioF,.T.)
					nSeqAbast++
				EndDo
				//-- Se sobrou saldo, deve verificar se pode gerar reabastecimento para completar a separação
				If lRet .And. QtdComp(nQuant) > QtdComp(0)
					If lLogSld
						AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0059,{{"[VAR01]",__cLocOrig}}),{}}) // "Armazém [VAR01] - Geração de reabastecimento por demanda."
					EndIf
					lRet := GeraAbtDem(@lGeraAbast,nQuant,lRadioF,aSeqAbPkg,.T.)
					If lRet .And. lGeraAbast
						nSeqAbast := 1
						Do While lRet .And. nSeqAbast <= Len(aSeqAbPkg) .And. QtdComp(nQuant) > QtdComp(0)
							DC3->(MsSeek(xFilial('DC3')+__cProduto+__cLocOrig+aSeqAbPkg[nSeqAbast]))
							DC8->(DbSeek(xFilial('DC8')+DC3->DC3_TPESTR))
							If lLogSld
								AAdd(aLogSld[Len(aLogSld),7],{WmsFmtMsg(STR0023+STR0050,{{"[VAR01]",__cLocOrig},{"[VAR02]",DC3->DC3_TPESTR},{"[VAR03]",DC8->DC8_DESEST}}),{}}) //"Armazém [VAR01] - Busca de saldo na estrutura [VAR02] - [VAR03] - Reabastecimentos gerados."
							EndIf
							lRet := ProcEstFis(DC3->DC3_TPESTR,@nQuant,lRadioF,.T.)
							nSeqAbast++
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
		// Verifica se há endereços de picking para reabastecimento
		// por percentual de reposição
		If lRet .And. !Empty(aValReab)
			FindReabPK(@nGerouReab,lRadioF)
			If nGerouReab == 2
				If Type('aWmsReab') == "A"
					//Deve adicionar no log apenas uma vez
					If AScan(aWmsReab, { |x| AllTrim(__cProduto) $ x[1] }) == 0
						AAdd(aWmsReab,{STR0039+AllTrim(__cProduto)}) // Reabastecimentos pendentes que precisam ser executados para o produto
					EndIf
				EndIf
			ElseIf nGerouReab == 1
				AddMsgLog(,,,,,,,,STR0072) //"Sequência de abastecimento não possui taxa de reposição de reabastecimento configurada."
			ElseIf nGerouReab == 0
				AddMsgLog(,,,,,,,nQuant,STR0056) // Não foi possível gerar reabastecimento na estrutura física.
			EndIf
		EndIf
		If lRet .And. QtdComp(nQuant) > QtdComp(0)
			cMensagem := __cMsgOsPr
			cMensagem += WmsFmtMsg(STR0044+CRLF+STR0048+CRLF,{{"[VAR01]",Str(nQuant)}}) // "Não foi possível separar toda a quantidade. Saldo pendente ([VAR01]). As movimentações desta OS foram estornadas."
			WmsMessage(cMensagem,"WmsEstSai",1)
			lRet := .F.
		EndIf
		If !lRet .And. !__lSwLogSld
			__lSwLogSld := .T.
		EndIf
	EndIf
	RestArea(aAreaDC3)
	RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Determina a quantidade que deve ser solicitada para cada sequencia de
abastecimento e solicita de forma recursiva a quantidade para cada uma das
estruturas até zerar o saldo ou acabar as estruturas.
-----------------------------------------------------------------------------/*/
Static Function ProcEstFis(cEstOrig,nQtdApanhe,lRadioF,lCnsPkgFut,lReiSeqAb)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local nQtdNorma  := 0
Local nQtdApUni  := 0
Local cTipoSep   := '3' //-- Tipo de Separação
Local nApMinimo  := 0

Default cEstOrig   := ""
Default nQtdApanhe := 0
Default lCnsPkgFut := .F.
Default lReiSeqAb  := .F.

	nApMinimo := 1 / (10 ** TamSX3('DC3_QTDUNI')[2])  //Cálculo da quantidade mínima possível para um apanhe, conforme número de casas decimais do campo DC3_QTDUNI
	nQtdApUni := Max(DC3->DC3_QTDUNI,nApMinimo)
	cTipoSep  := Iif(Empty(DC3->DC3_TIPSEP),'3',DC3->DC3_TIPSEP)

	//-- Posiciona o Arquivo de Normas de Paletizacao
	nQtdNorma := DLQtdNorma(__cProduto,__cLocOrig,cEstOrig,/*cDesUni*/,.F.)

	If !lReiSeqAb .And. cTipoSep == '1' //Somente a norma completa
		nQtdApUni := nQtdNorma
	Else
		nQtdApUni := Min(nQtdApUni,nQtdNorma)
	EndIf

	If QtdComp(nQtdApanhe) >= QtdComp(nQtdApUni)
		lRet := ProcEndExp(cEstOrig,@nQtdApanhe,nQtdApUni,nQtdNorma,cTipoSep,lRadioF,lCnsPkgFut,lReiSeqAb)
	Else
		If cTipoSep == '1'
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,WmsFmtMsg(STR0041,{{"[VAR01]",Str(nQtdNorma)}})) //"Tipo de separação: Somente norma. Quantidade menor que uma norma completa ([VAR01])."
		Else
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,WmsFmtMsg(STR0042,{{"[VAR01]",Str(nQtdApUni)}})) //"Tipo de separação: Quantidade mínima. Qtd menor que a separação mínima. ([VAR01])."  
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Busca o próximo endereço com saldo disponível para a separação.
Quando estrutura é do tipo picking verifica se deve gerar reabastecimento.
-----------------------------------------------------------------------------/*/
Static Function ProcEndExp(cEstOrig,nQtdApanhe,nQtdApUni,nQtdNorma,cTipoSep,lRadioF,lCnsPkgFut,lReiSeqAb)

Local aAreaAnt   := GetArea()
Local aAreaSBE   := SBE->(GetArea())
Local aAreaDC3   := DC3->(GetArea())
Local nQtdApEnd  := 0
Local nQtdApMov  := 0
Local nQtdApanPE := 0
Local nSaldoSBF  := 0
Local nTipEnd    := 0
Local lFoundSBF  := .F.
Local xRetPE     := Nil
Local lRet       := .T.
Local cTipoServ  := WmsTipServ(__cServico)  //-- Servico
Local aExcecoesO := {} //-- Excecoes referentes ao Endereco ORIGEM
Local aExcecoesD := {} //-- Excecoes referentes ao Endereco DESTINO
Local nApMinimo  := 1 / (10 ** TamSX3('DC3_QTDUNI')[2]) //Cálculo da quantidade mínima possível para um apanhe, conforme número de casas decimais do campo DC3_QTDUNI
Local lOK        := .T.
Local lTarUsaRF  := .T.
Local cAliasSld  := ""
Local nCntLib    := 0
Local lFldSldRF  := .F.
Local lGerouReab := .F.
Local cQuery     := ""
Local aParamBkp  := {}
Local lConfExp   := .F.
Local cLibPed    := ""
Local lMntVol    := SuperGetMV("MV_WMSVEMB",.F.,.F.) .And. (IsInCallStack('DLAPANHEVL') .Or. IsInCallStack('DLAPANHEC2'))
Local lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')
Local nQtdApMax  := 0
Local cMensag  := ""

Default cEstOrig   := Space(TamSX3("BF_ESTFIS")[1])
Default lCnsPkgFut := .F.
Default lReiSeqAb  := .F.

	nCntLib := Iif(lCnsPkgFut,Len(aLibSDB),0)
	nTipEnd := Iif(!Empty(cEstOrig),DLTipoEnd(cEstOrig),0) //-- 1=Pulmao/2=Picking
	//-- Carregas as exceções das atividades, somente do destino
	DLExcecoes(cTipoServ,__cLocOrig,cEstOrig,Nil,__cLocDest,__cEstDest,__cEndDest,Nil,aExcecoesD)
	//-- Carregando o saldo na estrtura origem
	If lWMSQYSEP
		cAliasSld := ExecBlock("WMSQYSEP",.F.,.F.,{__cProduto,__cLocOrig,cEstOrig,__nRegra})
		cAliasSld := Iif(ValType(cAliasSld)=="C",cAliasSld,"")
	EndIf
	If Empty(cAliasSld)
		cAliasSld := QryEstEnd(cEstOrig,nQtdApanhe,nQtdApUni,lRadioF,lCnsPkgFut)
	Else
		AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,"Saldo a ser utilizado retornado pelo PE: WMSQYSEP") //"Saldo a ser utilizado retornado pelo PE: WMSQYSEP"
	EndIf
	// Limpa a estrutura física para forçar carregar norma e apanhe unitário
	If __nRegra == 3 .And. __lRastro
		cEstOrig := ""
	EndIf
	lFldSldRF := (cAliasSld)->(FieldPos("BF_QTDSPR")) > 0 // Se existe o campo no SELECT
	While (cAliasSld)->(!Eof())
		nSaldoSBF  := (cAliasSld)->BF_SALDO
		lFoundSBF  := .T.

		If (__nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro)) .And. cEstOrig != (cAliasSld)->BF_ESTFIS
			cEstOrig := (cAliasSld)->BF_ESTFIS
			DC3->(DbSetOrder(2))
			If DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+cEstOrig))
				nQtdApUni := Max(DC3->DC3_QTDUNI,nApMinimo) //DC3->DC3_QTDUNI
				nQtdNorma := DLQtdNorma(__cProduto,__cLocOrig,cEstOrig,/*cDesUni*/,.F.)
				nTipEnd   := DLTipoEnd(cEstOrig)
				cTipoSep  := Iif(Empty(DC3->DC3_TIPSEP),'3',DC3->DC3_TIPSEP)
			EndIf
			If __nRegra == 3 .And. __lRastro
				If !lReiSeqAb .And. cTipoSep == '1' //Somente a norma completa
					nQtdApUni := nQtdNorma
				Else
					nQtdApUni := Min(nQtdApUni,nQtdNorma)
				EndIf
			EndIf
		EndIf
		nQtdApMax := ApMaxPic(DC3->DC3_TPESTR,DC3->DC3_NUNITI,DC3->DC3_PERAPM,DC3->DC3_QTDUNI)
	
		//-- Desconsidera quando lote encontrar-se vencido
		If !lConsVenc .And. __lRastro .And. !((cAliasSld)->B8_DTVALID >= dDataBase)
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,,nQtdApanhe,,STR0065) //"Lote com a data de validade vencida!"
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Desconsidera quando for endereco destino
		If (__cLocOrig+(cAliasSld)->BF_ESTFIS+(cAliasSld)->BF_LOCALIZ==__cLocDest+__cEstDest+__cEndDest)
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,,nQtdApanhe,,STR0025) //"Endereço origem igual destino."
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Se é saldo futuro, deve descontar o saldo de RF de saída
		If lFldSldRF .And.  !(__nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro))
			nSaldoRF := (cAliasSld)->BF_QTDSPR
		Else
			nSaldoRF := ConSldRF(__cLocOrig, (cAliasSld)->BF_LOCALIZ, __cProduto, (cAliasSld)->BF_LOTECTL, (cAliasSld)->BF_NUMLOTE, , lRadioF, '1', /*Cache*/.F., /*Convocacao*/.T., /*Entrada*/.F., /*Saída*/.T.)
			nSaldoRF := nSaldoRF * (-1) //Multiplica por -1, pois saldo de saída é negativo
		EndIf
		If QtdComp(nSaldoSBF-nSaldoRF) <= 0
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0028) //"Saldo utilizado para outros movimentos."
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Desconsidera SBE não encontrado - falha de integridade
		SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ+BE_ESTFIS
		If !SBE->(DbSeek(xFilial('SBE')+__cLocOrig+(cAliasSld)->BF_LOCALIZ+(cAliasSld)->BF_ESTFIS))
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0026) //"Endereço não cadastradado. (SBE)"
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Desconsidera Enderecos Bloqueados
		If SBE->BE_STATUS == '3'
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0027) //"Endereço bloqueado. (SBE)"
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Se o saldo for menor que o apanhe unitário minimo, não utiliza o saldo
		If QtdComp(nSaldoSBF-nSaldoRF) < QtdComp(nQtdApUni)
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,WmsFmtMsg(STR0029,{{"[VAR01]",Str(nQtdApUni)}})) //"Saldo menor que o apanhe mínimo da estrutura ([VAR01])."
			(cAliasSld)->(DbSkip())
			Loop
		EndIf
		//-- Se separar somente o saldo restante e for maior que o solicitado, não utiliza o saldo
		If !lReiSeqAb .And. cTipoSep == '2' .And. QtdComp(nSaldoSBF-nSaldoRF) > QtdComp(nQtdApanhe)
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0040) //"Tipo de separação: Saldo  restante. Saldo maior que o solicitado."
			(cAliasSld)->(DbSkip())
			Loop
		EndIf

		lOk := .T.
		cMensag  := ""
		If __nRegra==1
			lOk := Iif(!Empty(__xRegra),(cAliasSld)->BF_LOTECTL==__xRegra,.T.)
			cMensag := STR0066 + (cAliasSld)->BF_LOTECTL + STR0067 + __xRegra  // "Lote item WMS:"+ (cAliasD14)->D14_LOTECT + " Lote Regra :" + Self:xRegra
		ElseIf __nRegra==2
			lOk := Iif(!Empty(__xRegra),(cAliasSld)->BF_NUMSERI==__xRegra,.T.)
			cMensag := STR0068 + (cAliasSld)->BF_NUMSERI + STR0069  + __xRegra  //"Num. Série item WMS: " + (cAliasSld)->BF_NUMSERI + " Num. Série Regra:"  + __xRegra 
		ElseIf __nRegra==3
			lOk := Iif(!Empty(__xRegra),(cAliasSld)->B8_DTVALID>=__xRegra,.T.)
			cMensag := STR0070 + cValToChar((cAliasSld)->B8_DTVALID) + STR0071  + cValToChar(__xRegra) // "Validade item WMS: " + (cAliasSld)->B8_DTVALID + " menor que data Regra: "  + __xRegra
		EndIf
		If !lOK
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0030+cMensag) //"Regra WMS impede utilização saldo."
		EndIf
		If lOK
			xRetPE := {}
			If lDLENDAP
				lOk := .F.
				//-- Ponto de Entrada: DLENDAP
				//-- Para confirmar a escolha de um endereço de apanhe
				//-- Parametros:
				//-- PARAMIXB[1] = Armazem Origem
				//-- PARAMIXB[2] = Endereco Origem
				//-- PARAMIXB[3] = Estrutura Fisica Origem
				//-- PARAMIXB[4] = Codigo do Produto
				//-- PARAMIXB[5] = Lote
				//-- PARAMIXB[6] = Sub-Lote
				//-- Retorno (Logico):
				//-- .F. - Para Descartar o endereco de Apanhe
				//-- .T. - Para Confirmar o endereco de Apanhe
				xRetPE := ExecBlock("DLENDAP",.F.,.F.,{__cLocOrig,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_ESTFIS,__cProduto,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,nQtdApanhe})
				If ValType(xRetPE)=="L"
					lOk := xRetPE
				ElseIf ValType(xRetPE)=="A"
					If Len(xRetPE)>=1 .And. ValType(xRetPE[1])=="L"
						lOk := xRetPE[1]
					EndIf
					If Len(xRetPE)>=2 .And. ValType(xRetPE[2])=="N"
						nQtdApanPE := xRetPE[2]
					EndIf
				EndIf
				If !lOK
					AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0031) //"Endereço descartado pelo PE DLENDAP."
				EndIf
			EndIf
		EndIf

		If !lOK
			(cAliasSld)->(DbSkip())
			Loop
		EndIf

		If QtdComp(nQtdApanPE) > QtdComp(0)
			nQtdApEnd := nQtdApanPE
		Else
			//-- Determina a quantidade a ser apanhada no endereço
			nQtdApEnd := Min((nSaldoSBF-nSaldoRF),nQtdApanhe)
			If !lReiSeqAb
				//-- Valida se a quantidade é multipla do apanhe unitário minimo
				nQtdApEnd := NoRound(nQtdApEnd/nQtdApUni,0) * nQtdApUni
				If QtdComp(nQtdApEnd) <= QtdComp(0)
					AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,WmsFmtMsg(STR0036,{{"[VAR01]",Str(nQtdApUni)}})) //"Multiplo menor que um apanhe unitário ([VAR01])."
					(cAliasSld)->(DbSkip())
					Loop
				EndIf
			Else
				//-- Valida se a quantidade é multipla da 2aUM do produto
				nQtdApEnd := RetQtdMul(nQtdApEnd,nApMinimo)
				If QtdComp(nQtdApEnd) <= QtdComp(0)
					AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,,STR0046) //"Múltiplo da quantidade solicitada menor que 2a UM do produto ou menor que a separação mínima."
					(cAliasSld)->(DbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		IF nQtdApMax > 0 .AND. (DC3->DC3_PERAPM < QtdComp(100) .AND. DC3->DC3_PERAPM > QtdComp(0)) .AND. (VldPkUnM(DC3->DC3_LOCAL,DC3->DC3_CODPRO))>=2 
			//Quando utiliza picking Master e picking unitário na sequencia de abastecimento 
			//para que o reabastecimento ocorra da forma correta e necessário a validação do apanhe maximo na estrutra
			//Se a quantidade solicitada é maior que o apanhe máximo do picking
			If QtdComp(nQtdApEnd) > QtdComp(nQtdApMax)
				AddMsgLog(DC3->DC3_TPESTR,,,,,,nQtdApEnd,,WmsFmtMsg(STR0064,{{"[VAR01]",Str(nQtdApMax)}})) //"Solicitado maior que apanhe máximo picking ([VAR01])."
				(cAliasSld)->(DbSkip())
				Loop
			EndIf
		EndIf
		If QtdComp(nQtdApEnd) > 0
			AddMsgLog((cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,(cAliasSld)->BF_LOTECTL,(cAliasSld)->B8_DTVALID,nSaldoSBF,nSaldoRF,nQtdApanhe,nQtdApEnd,STR0032) //"Endereço utilizado"
		EndIf
		//Quando o parametro MV_RADIOF = N e esta processando uma estrutura de picking e a mesma e zerada e não esta consultando lancamentos de picking futuro, alimenta o endereço para que o mesmo seja considerado no reabastecimento por demanda. 
		If !lRadioF .And. !lCnsPkgFut .And. __lPrdPul .AND. nTipEnd == 2  .And. nQtdApanhe > nQtdApEnd 
			AAdd(__aEndPkg, (cAliasSld)->BF_LOCALIZ)
		EndIf
		If QtdComp(nQtdApEnd) > 0
			//-- Carregas as exceções das atividades, somente da origem
			DLExcecoes(cTipoServ,__cLocOrig,(cAliasSld)->BF_ESTFIS,(cAliasSld)->BF_LOCALIZ,__cLocDest,__cEstDest,__cEndDest,aExcecoesO,Nil)
			//-- Verifica se a tarefa utiliza RF
			lTarUsaRF := DLTarUsaRF(cTipoServ,__cTarefa,aExcecoesO,aExcecoesD)
			//Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
			aParamBkp  := AClone(aParam150)
			While lRet .And. QtdComp(nQtdApEnd) > QtdComp(0)
				nQtdApMov := Min(nQtdApEnd,nQtdNorma)
				//-- Monta o Array aParam para ser utilizado na Execucao das Atividades
				aParam150[02] := __cLocOrig //-- Armazem Origem
				aParam150[06] := nQtdApMov  //-- Quantidade Movimentada
				aParam150[18] := (cAliasSld)->BF_LOTECTL   //-- Lote
				aParam150[19] := (cAliasSld)->BF_NUMLOTE   //-- Sub-Lote
				aParam150[20] := (cAliasSld)->BF_LOCALIZ   //-- Endereco Origem
				aParam150[21] := (cAliasSld)->BF_ESTFIS    //-- Estrutura Fisica Origem
				aParam150[25] := __cLocDest //-- Armazem Destino
				aParam150[26] := __cEndDest //-- Endereco Destino
				aParam150[27] := __cEstDest //-- Estrutura Fisica Destino
				//-- Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
				If (lRet := DLXExecAti(__cTarefa, aParam150))
				    If !lTarUsaRF

						__lSpUsaRF := .F.

						// Se o reabastecimento utiliza RF, a separação não utiliza e é consulta de picking futuro,
						// é provável que não exista saldo suficiente para a movimentação de estoque nesse momento
						If lCnsPkgFut
							nSaldoSBF := WmsSaldoSBF(__cLocOrig,(cAliasSld)->BF_LOCALIZ,__cProduto,(cAliasSld)->BF_NUMSERI,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,/*lCache*/.F.,lRadioF,/*lUsaEntra*/.F.,/*lUsaSaida*/.F.,'1',/*lConSldRF*/.F.)
							If nSaldoSBF < nQtdApMov
								lRet := .F.
								cMensagem := __cMsgOsPr
								cMensagem += STR0053+CRLF+STR0048+CRLF // Não há saldo suficiente para movimentação de estoque do produto. As movimentações desta OS foram estornadas.
								WmsMessage(cMensagem,"WmsApanhe",1)
							EndIf
						EndIf

						DC5->(DbSetOrder(1))
						If DC5->(DbSeek(xFilial('DC5')+__cServico))
							lConfExp := DC5->DC5_COFEXP == '1'
							cLibPed  := DC5->DC5_LIBPED
						EndIf

						While Len(aParamBkp) < 34
							AAdd(aParamBkp,"")
						EndDo
						aParamBkp[34] := aParam150[34]

						//Utiliza as informações da DCR, para quando houver documentos aglutinados
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

						While (cAliasQry)->(!Eof()) .And.  lRet
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

							If !lRet
								cMensagem := __cMsgOsPr
								cMensagem += STR0051+CRLF+STR0048+CRLF // "Ocorreram problemas na movimentação de estoque do produto. As movimentações desta OS foram estornadas."
								WmsMessage(cMensagem,"WmsApanhe",1)
							Else
								If __cOrigem == 'SC9'
									lRet := WmsAtuSC9(__cCarga,__cDocto,__cSerie,__cProduto,__cServico,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,(cAliasSld)->BF_NUMSERI,aParam150[06] /*nQtdApMov*/,/*nQuant2UM*/,__cLocDest,__cEndDest,/*cIdDCF*/aParam150[32],__nRegra,__xRegra,__lLibSC9)
									If !lRet
										WmsMessage(__cMsgOsPr + WmsLastMsg(),"WmsApanhe",1)
									EndIf
								EndIf
							EndIf
							// Atualiza as informacoes de requisicao de empenho de ordens de producao
							If lRet .And. GetVersao(.F.) >= "12" .And. __cOrigem == 'SD4'
								lRet := WmsAtuSD4(__cLocDest,__cProduto,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,(cAliasSld)->BF_NUMSERI,__cEndDest,aParam150[06],/*cIdDCF*/aParam150[32],.F.)
							EndIf

							If lRet
								If lMntVol
									WmsVolEmb((cAliasQry)->DCF_CARGA,(cAliasQry)->DCF_DOCTO,__cProduto,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,__cTarefa,(cAliasQry)->DCR_QUANT,cLibPed,(cAliasQry)->DCR_IDDCF)
								EndIf
								If lConfExp
									lRet := WmsConfMult((cAliasQry)->DCF_CARGA,(cAliasQry)->DCF_DOCTO,__cProduto,(cAliasSld)->BF_LOTECTL,(cAliasSld)->BF_NUMLOTE,__cTarefa,(cAliasQry)->DCR_QUANT,cLibPed,(cAliasQry)->DCR_IDDCF)
								EndIf
							EndIf

							(cAliasQry)->(dbSkip())
						EndDo
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
				//-- Diminuindo a quantidade a ser separada
				If lRet
					nQtdApEnd  -= nQtdApMov
					nQtdApanhe -= nQtdApMov
				EndIf
			EndDo
			aParam150 := aParamBkp
		EndIf
		If !lRet
			Exit
		EndIf
		//-- Se o restante para apanhe for menor que o apanhe unitário, sai fora
		If !(__nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro)) .And. QtdComp(nQtdApanhe) > 0 .And. QtdComp(nQtdApanhe) < QtdComp(nQtdApUni)
			AddMsgLog((cAliasSld)->BF_ESTFIS,,,,,,nQtdApanhe,,WmsFmtMsg(STR0024,{{"[VAR01]",Str(nQtdApUni)}})) //"Solicitado menor que o apanhe unitário ([VAR01])."
			Exit
		EndIf
		//-- Conseguiu atender toda a quantidade solicitada
		If QtdComp(nQtdApanhe) <= QtdComp(0)
			Exit
		EndIf
		(cAliasSld)->(DbSkip())
	EndDo
	//-- Fecha a Query se não for ponto de entrada.
	//If !(!lCnsPkgFut .And. (lWMSFIFO .Or. (lWMSFIFO2 .And. !Empty(cEstOrig))))
	If !(lCnsPkgFut .Or. lWMSFIFO .Or. (lWMSFIFO2 .And. !Empty(cEstOrig)))
		(cAliasSld)->(DbCloseArea())
	EndIf

	//-- Esta regra é para gerar as movimentações de separação bloqueadas
	If lRet .And. lCnsPkgFut
		While nCntLib < Len(aLibSDB)
			nCntLib++
			If aLibSDB[nCntLib,1] == '4'
				aLibSDB[nCntLib,1] := '2'
			EndIf
		EndDo
	EndIf

	If lRet .And. !lCnsPkgFut .And. !lFoundSBF
		If __nRegra == 4
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0054) // Não possui saldo no armazém.
		ElseIf __nRegra == 3 .And. __lRastro
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0055) // Não possui saldo no tipo de estrutura fisica.
		Else
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0033) //"Não possui saldo na estrutura fisica."
		EndIf
	EndIf
	//-- Se encontrar um saldo futuro, indica que tem reabastecimento pendente
	If lRet
		If (lGerouReab .Or. Len(__aReabGer) > 0)
			If Type('aWmsReab')=='A'
				//Deve adicionar no log apenas uma vez
				If AScan(aWmsReab, { |x| AllTrim(__cProduto) $ x[1] }) == 0
					AAdd(aWmsReab,{STR0039+AllTrim(__cProduto)})//"Reabastecimentos pendentes que precisam ser executados para o produto "
				EndIf
			EndIf
		ElseIf !lGerouReab .And. lCnsPkgFut .And. !lFoundSBF
			AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0056) // Não foi possível gerar reabastecimento na estrutura física.
		EndIf
	EndIf
	RestArea(aAreaDC3)
	RestArea(aAreaSBE)
	RestArea(aAreaAnt)
Return(lRet)

/*-----------------------------------------------------------------------------
Estrutura do array para o PE WMSFIFO
aSaldoTmp -> ARRAY (    1) [...]
	  aSaldoTmp[1] -> ARRAY (   13) [...]
			 aSaldoTmp[1][1] -> C (   10) [AUTO000782]           Lote
			 aSaldoTmp[1][2] -> C (    6) [      ]               Sub-Lote
			 aSaldoTmp[1][3] -> C (   15) [01010001       ]      Endereco
			 aSaldoTmp[1][4] -> C (   20) [                    ] Numero de Serie
			 aSaldoTmp[1][5] -> N (   15) [       240.0000]      Quantidade (Saldo - Empenho)
			 aSaldoTmp[1][6] -> N (   15) [        15.0000]      Quantidade 2 um
			 aSaldoTmp[1][7] -> D (    8) [09/08/05]             Data de Validade
			 aSaldoTmp[1][8] -> N (   15) [         1]           Recno no SB2
			 aSaldoTmp[1][9] -> N (   15) [         1]           Recno no SBF
			 aSaldoTmp[1][10] -> ARRAY (1) [...]
					aSaldoTmp[1][10][1] -> ARRAY (3) [...]
						  aSaldoTmp[1][10][1][1] -> N (   15) [         1]       Recno SB8
						  aSaldoTmp[1][10][1][2] -> N (   15) [       240.0000]  Quantidade
						  aSaldoTmp[1][10][1][3] -> N (   15) [        15.0000]  Quantidade 2 um
			 aSaldoTmp[1][11] -> C (    2) [01]                  Armazem
			 aSaldoTmp[1][12] -> N (   15) [         0.0000]     Potencia
			 aSaldoTmp[1][13] -> C (    3) [ZZZ]                 Prioridade
			 aSaldoTmp[1][14] -> C (    6) [000001]              Estrutura Fisica
			 aSaldoTmp[1][15] -> N (   15) [       240.0000]     Quantidade Saldo,indica que já foi feito o apanhe
			 aSaldoTmp[1][16] -> C (    2) [01]                  Ordem Estrutura Fisica Sequencia Abastecimento
			 aSaldoTmp[1][17] -> C (    2) [01]                  Saldo RF Saída Pendente
-----------------------------------------------------------------------------*/
/*/-----------------------------------------------------------------------------
//Efetua a consulta de saldo
-----------------------------------------------------------------------------/*/
Static Function QryEstEnd(cEstOrig,nQtdApanhe,nQtdApUni,lRadioF,lCnsPkgFut)
Local cQuery    := ""
Local cAliasSld := GetNextAlias()
Local aTamSx3   := {}
Local cOrdemDC3 := Replicate("0", TamSx3("DC3_ORDEM")[1])
Local lBlOrdDec := SuperGetMV("MV_WMSBLAP",.F.,2) == 2 //-- Define Ordem apanhe para estrutura blocado (1-Crescente/2-Descrescente)
Local lFEFO     := __lRastro .And. SuperGetMV("MV_FEFOBLF",.F.,.F.) == .T.
Local aSldLote  := {}
Local aRetPE    := {}
Local nSldSBF2  := 0
Local aSldSB8   := {}
Local cSeek     := ""
Local nTipEnd   := Iif(!Empty(cEstOrig),DLTipoEnd(cEstOrig),0)

	cQuery := Iif((__nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro .And. !lCnsPkgFut)),"DC3.DC3_ORDEM,DC3.DC3_QTDUNI",("'"+cOrdemDC3+"' DC3_ORDEM"))+","
	cQuery +=      " SBF.BF_PRIOR,SBF.BF_ESTFIS,SBF.BF_LOCALIZ,SBF.BF_LOTECTL,SBF.BF_NUMLOTE,SBF.BF_NUMSERI,SBF.R_E_C_N_O_ RECNOSBF,"
	If __lRastro
		cQuery +=   " SB8.B8_POTENCI,SB8.B8_DTVALID,SB8.R_E_C_N_O_ RECNOSB8,"
	Else
		cQuery +=   " 0 B8_POTENCI,'        ' B8_DTVALID,0 RECNOSB8,"
	EndIf
	cQuery +=      " (SBF.BF_QUANT - SBF.BF_EMPENHO) BF_SALDO, 'S' BF_IDSALDO"
	If lRadioF .And. !lCnsPkgFut
		cQuery +=   ", (CASE WHEN SDB.DB_QUANT IS NOT NULL THEN SDB.DB_QUANT ELSE 0 END) BF_QTDSPR"
	EndIf
	cQuery += " FROM "+RetSqlName("SBF")+" SBF"
	If __lRastro
		cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8"+;
						 " ON SB8.B8_FILIAL  = '"+xFilial("SB8")+"'"+;
						" AND SB8.B8_PRODUTO = SBF.BF_PRODUTO"+;
						" AND SB8.B8_LOCAL   = SBF.BF_LOCAL"+;
						" AND SB8.B8_LOTECTL = SBF.BF_LOTECTL"+;
						" AND SB8.B8_NUMLOTE = SBF.BF_NUMLOTE"+;
						" AND SB8.B8_SALDO > 0"+;
						" AND SB8.D_E_L_E_T_ = ' '"
	EndIf

	//Se prioriza a busca por sequência de abastecimento
	If __nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro .And. !lCnsPkgFut)
		cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"+;
						 " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"+;
						" AND DC3.DC3_LOCAL  = SBF.BF_LOCAL"+;
						" AND DC3.DC3_CODPRO = SBF.BF_PRODUTO"+;
						" AND DC3.DC3_TPESTR = SBF.BF_ESTFIS"+;
						" AND DC3.D_E_L_E_T_ = ' '"
	EndIf
	If lCnsPkgFut .Or. (__nRegra == 3 .And. __lRastro)
		cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
		cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
		cQuery +=   " AND DC8.DC8_CODEST = SBF.BF_ESTFIS"
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	EndIf
	//Se consulta saldo futuro
	If lCnsPkgFut
		cQuery += " INNER JOIN "+RetSqlName("SBE")+" SBE"
		cQuery +=    " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
		cQuery +=   " AND SBE.BE_LOCAL   = SBF.BF_LOCAL"
		cQuery +=   " AND SBE.BE_LOCALIZ = SBF.BF_LOCALIZ"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	EndIf
	If lRadioF .And. !lCnsPkgFut
		cQuery +=" LEFT JOIN ("
		cQuery += "SELECT DB_LOCAL,DB_LOCALIZ,DB_LOTECTL,DB_NUMLOTE,SUM(DB_QUANT) DB_QUANT"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+__cProduto+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"
		If !(__nRegra == 4 .Or. (__nRegra == 3 .And. __lRastro))
			cQuery += " AND SDB.DB_ESTFIS = '"+cEstOrig+"'"
		EndIf
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_STATUS IN ('4','3','2','-')"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
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
														 " AND SDBM.D_E_L_E_T_ = ' ' )"
		cQuery += " GROUP BY DB_LOCAL,DB_LOCALIZ,DB_LOTECTL,DB_NUMLOTE) SDB"
		cQuery +=    " ON SDB.DB_LOCAL   = SBF.BF_LOCAL"
		cQuery +=   " AND SDB.DB_LOCALIZ = SBF.BF_LOCALIZ"
		cQuery +=   " AND SDB.DB_LOTECTL = SBF.BF_LOTECTL"
		cQuery +=   " AND SDB.DB_NUMLOTE = SBF.BF_NUMLOTE"
	EndIf

	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+"'"
	cQuery +=   " AND SBF.BF_LOCAL   = '"+__cLocOrig+"'"
	cQuery +=   " AND SBF.BF_PRODUTO = '"+__cProduto+"'"
	cQuery +=   " AND SBF.BF_QUANT > 0"
	cQuery +=   " AND (SBF.BF_QUANT - SBF.BF_EMPENHO) > 0"
	If __nRegra != 4
		If __nRegra == 3 .And. __lRastro .And. !lCnsPkgFut
			cQuery += " AND DC8.DC8_TPESTR = '"+AllTrim(Str(nTipEnd))+"'"
		Else
			cQuery += " AND SBF.BF_ESTFIS  = '"+cEstOrig+"'"
		EndIf
	EndIf
	If lCnsPkgFut //Endereço bloqueado já desconsiderou na primeira vez
		cQuery += " AND SBE.BE_STATUS <> '3'"  //-- Não pode estar bloqueado
	EndIf
	cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	If __lRastro .And. __nRegra == 1 .And. !Empty(__xRegra) //-- Lote
		cQuery += " AND SBF.BF_LOTECTL = '"+__xRegra+"'"
	EndIf

	//Se consulta saldo futuro
	If lCnsPkgFut
		cQuery +=   " AND DC8.DC8_TPESTR = '2'" //Somente picking
		cQuery += " UNION ALL "
		cQuery += "SELECT "+Iif(__nRegra == 4,"DC3.DC3_ORDEM,DC3.DC3_QTDUNI",("'"+cOrdemDC3+"' DC3_ORDEM"))+","
		cQuery +=       " BE_PRIOR BF_PRIOR,DB_ESTDES BF_ESTFIS,DB_ENDDES BF_LOCALIZ,"
		cQuery +=       " DB_LOTECTL BF_LOTECTL,DB_NUMLOTE BF_NUMLOTE,DB_NUMSERI BF_NUMSERI, 0 RECNOSBF,"
		If __lRastro
			cQuery +=    " SB8.B8_POTENCI,SB8.B8_DTVALID,0 RECNOSB8,"
		Else
			cQuery +=    " 0 B8_POTENCI,'        ' B8_DTVALID,0 RECNOSB8,"
		EndIf
		cQuery +=       " SUM(DB_QUANT) BF_SALDO, 'F' BF_IDSALDO"
		cQuery +=  " FROM "+RetSqlName("SDB")+" SDB"
		If __lRastro
			cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8"+;
							 " ON SB8.B8_FILIAL  = '"+xFilial("SB8")+"'"+;
							" AND SB8.B8_PRODUTO = SDB.DB_PRODUTO"+;
							" AND SB8.B8_LOCAL   = SDB.DB_LOCAL"+;
							" AND SB8.B8_LOTECTL = SDB.DB_LOTECTL"+;
							" AND SB8.B8_NUMLOTE = SDB.DB_NUMLOTE"+;
							" AND SB8.B8_SALDO > 0"+;
							" AND SB8.D_E_L_E_T_ = ' '"
		EndIf
		//Se prioriza a busca por sequência de abastecimento
		If __nRegra == 4
			cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"+;
							 " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"+;
							" AND DC3.DC3_LOCAL  = SDB.DB_LOCAL"+;
							" AND DC3.DC3_CODPRO = SDB.DB_PRODUTO"+;
							" AND DC3.DC3_TPESTR = SDB.DB_ESTDES"+;
							" AND DC3.D_E_L_E_T_ = ' '"
		EndIf
		cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
		cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
		cQuery +=   " AND DC8.DC8_CODEST = SDB.DB_ESTDES"
		cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN "+RetSqlName("SBE")+" SBE"
		cQuery +=    " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
		cQuery +=   " AND SBE.BE_LOCAL   = SDB.DB_LOCAL"
		cQuery +=   " AND SBE.BE_LOCALIZ = SDB.DB_ENDDES"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
		cQuery +=   " AND SDB.DB_PRODUTO = '"+__cProduto+"'"
		cQuery +=   " AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"
		If __nRegra != 4
			cQuery += " AND SDB.DB_ESTDES = '"+cEstOrig+"'"
		EndIf
		If __lRastro .And. __nRegra == 1 .And. !Empty(__xRegra) //-- Lote
			cQuery += " AND SDB.DB_LOTECTL = '"+__xRegra+"'"
		EndIf
		cQuery +=   " AND SDB.DB_ESTORNO = ' '"
		cQuery +=   " AND SDB.DB_ATUEST  = 'N'"
		cQuery +=   " AND SDB.DB_STATUS IN ('4','3','2','-')"
		cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
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
														 " AND SDBM.D_E_L_E_T_ = ' ' )"
		cQuery +=   " AND DC8.DC8_TPESTR = '2'" //Somente picking
		If __lRastro
			cQuery += " GROUP BY B8_POTENCI,B8_DTVALID,BE_PRIOR,DB_ESTDES,DB_ENDDES,DB_LOTECTL,DB_NUMLOTE,DB_NUMSERI"
		Else
			cQuery += " GROUP BY BE_PRIOR,DB_ESTDES,DB_ENDDES,DB_LOTECTL,DB_NUMLOTE,DB_NUMSERI"
		EndIf
		If __nRegra == 4
			cQuery += ",DC3_ORDEM,DC3_QTDUNI"
		EndIf
	EndIf

	If nTipEnd == 4 .Or. (nTipEnd == 6 .And. !lFEFO)
		cQuery += " ORDER BY BF_PRIOR, BF_LOCALIZ "+Iif(lBlOrdDec,"DESC","ASC")
	ElseIf __nRegra == 1 //-- Lote
		//-- Ordenar -> Prioridade + Lote + Sub-Lote + Endereco
		cQuery += " ORDER BY BF_PRIOR, BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ"
	ElseIf __nRegra == 4
		//-- Ordenar -> Dt.Validade Lote + Ordem Estrutura Fisica + Prioridade + Endereco
		cQuery += " ORDER BY B8_DTVALID, DC3_ORDEM, BF_PRIOR, BF_LOCALIZ"
	Else //-- Data (Default)
		//-- Ordenar -> Prioridade + Dt.Validade Lote + Lote + Sub-Lote + Endereco
		cQuery += " ORDER BY "+Iif(__nRegra == 3 .And. __lRastro .And. !lCnsPkgFut,"DC3_QTDUNI DESC,","")+" BF_PRIOR, B8_DTVALID, BF_LOTECTL, BF_NUMLOTE, BF_LOCALIZ"
	EndIf

	cQuery := "%" + cQuery + "%"
	BeginSql Alias cAliasSld
		SELECT %Exp:cQuery%
	EndSql

	aTamSx3 := TamSx3("BF_QUANT")
	TcSetField(cAliasSld,'BF_SALDO', 'N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasSld,'B8_DTVALID','D',8,0)
	TcSetField(cAliasSld,'RECNOSBF', 'N',10,0)
	TcSetField(cAliasSld,'RECNOSB8', 'N',10,0)

	//Se possuir os pontos de entrada, deve gerar um arquivo com os saldos
 	If lCnsPkgFut .Or. lWMSFIFO .Or. (lWMSFIFO2 .And. !Empty(cEstOrig))
		While (cAliasSld)->(!Eof())
			//-- Se for saldo futuro, deve agrupar caso exista saldo no endereço e saldo a reabastecer
			If lCnsPkgFut
				cSeek := __cLocOrig+(cAliasSld)->BF_LOCALIZ+(cAliasSld)->BF_LOTECTL+(cAliasSld)->BF_NUMLOTE
				If (nPos := AScan(aSldLote,{|x| x[11]+x[3]+x[1]+x[2] == cSeek})) == 0
					AAdd(aSldLote,{(cAliasSld)->BF_LOTECTL,;
										(cAliasSld)->BF_NUMLOTE,;
										(cAliasSld)->BF_LOCALIZ,;
										(cAliasSld)->BF_NUMSERI,;
										(cAliasSld)->BF_SALDO /*nQtdSaldo*/,;
										0,; //- Saldo 2UM - Não usa
										(cAliasSld)->B8_DTVALID,;
										0,; //SB2->(Recno()) - Não usa
										0,; //SBF->(Recno()) - Força zerado para descontar RF
										0,; //SB8->(Recno()) - Não usa
										__cLocOrig,;
										(cAliasSld)->B8_POTENCI,;
										(cAliasSld)->BF_PRIOR,;
										(cAliasSld)->BF_ESTFIS,;
										0,; //Qtd Apanhe
										(cAliasSld)->DC3_ORDEM,;
										0}) //Saída Previsa
				Else
					aSldLote[nPos,5] += (cAliasSld)->BF_SALDO /*nQtdSaldo*/
				EndIf
			Else
				nSldSBF2 := ConvUm(__cProduto,(cAliasSld)->BF_SALDO,2)
				If (cAliasSld)->RECNOSB8 == 0
					aSldSB8 := {}
				Else
					aSldSB8 := {(cAliasSld)->RECNOSB8,(cAliasSld)->BF_SALDO,nSldSBF2}
				EndIf
				AAdd(aSldLote,{(cAliasSld)->BF_LOTECTL,;
									(cAliasSld)->BF_NUMLOTE,;
									(cAliasSld)->BF_LOCALIZ,;
									(cAliasSld)->BF_NUMSERI,;
									(cAliasSld)->BF_SALDO,;
									nSldSBF2,;
									(cAliasSld)->B8_DTVALID,;
									0,; //SB2->(Recno())
									(cAliasSld)->RECNOSBF,;
									{aSldSB8},;
									__cLocOrig,;
									(cAliasSld)->B8_POTENCI,;
									(cAliasSld)->BF_PRIOR,;
									(cAliasSld)->BF_ESTFIS,;
									0,; //Qtd Apanhe
									(cAliasSld)->DC3_ORDEM,;
									Iif(lRadioF,(cAliasSld)->BF_QTDSPR,0)})
			EndIf
			(cAliasSld)->(DbSkip())
		EndDo
		(cAliasSld)->(DbCloseArea())
		If !lCnsPkgFut
			//Ponto de entrada para ajustar o saldo
			If lWMSFIFO
				aRetPE := ExecBlock("WMSFIFO",.F.,.F.,{AClone(aSldLote)} )
				If ValType(aRetPE)=='A' .And. Len(aRetPE) > 0
					aSldLote := aRetPE
					AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0057) // Saldo a ser utilizado retornado pelo PE: WMSFIFO
				EndIf
			EndIf
			If lWMSFIFO2 .And. !Empty(cEstOrig)
				aRetPE := ExecBlock("WMSFIFO2",.F.,.F.,{AClone(aSldLote),__cProduto,__cLocOrig,cEstOrig,nQtdApanhe,__nRegra,__xRegra,lRadioF,'1',nQtdApUni} )
				If ValType(aRetPE)=='A' .And. Len(aRetPE) > 0
					aSldLote := aRetPE
					AddMsgLog(cEstOrig,,,,,,nQtdApanhe,,STR0058) // Saldo a ser utilizado retornado pelo PE: WMSFIFO2
				EndIf
			EndIf
		EndIf

		cAliasSld := CriaTmpSld(lCnsPkgFut)
		cAliasSld := GravaTmpSld(aSldLote,cAliasSld,lCnsPkgFut)
	EndIf

Return cAliasSld

/*/-----------------------------------------------------------------------------
Analisa a capacidade do endereço de picking e verificar se o mesmo necessita de
reabastecimento após um processo de separação no mesmo.
Para isto analisa se o endereço possui um percentual de reposição e ao retirar
a quantidade para separação atingiu este percentual de reposição ou ficou zerado
e o sistema está parametrizado para reabastecer endereço de picking vazios.
-----------------------------------------------------------------------------/*/
Static Function PerRepPkg(cEstFis,cEndereco,nQtdAbast,nQtdApanhe,lRadioF)
Local aAreaAnt   := GetArea()
Local aAreaDC3   := DC3->(GetArea())
Local nCapEndPkg := 0
Local nReposicao := 0
Local nSaldoEnd  := 0
Local nQtdAbtPE  := 0
Local nTipoPerc  := 0
Local nRet       := 0

	nQtdAbast := 0
	DC3->(DbSetOrder(2)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
	If DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+cEstFis)) .And. (DC3->DC3_PERREP > 0)
		nCapEndPkg := DLQtdNorma(__cProduto,__cLocOrig,cEstFis,/*cDesUni*/,.T.,cEndereco)
		nReposicao := nCapEndPkg - ((DC3->DC3_PERREP/100) * nCapEndPkg)
		
		If WmsChkDCP(__cLocOrig,cEndereco,cEstFis,DC3->DC3_CODNOR,__cProduto,@nTipoPerc) .And. nTipoPerc == 1
			nSaldoEnd := WmsSaldoSBF(__cLocOrig,cEndereco,__cProduto,,,,.F.,.T.,.T.,.T.,'1')
		Else
			nSaldoEnd := WmsSaldoSBF(__cLocOrig,cEndereco,/*cProduto*/,,,,.F.,.T.,.T.,.T.,'1')
		EndIf
		nSaldoEnd  -= nQtdApanhe //Quantidade que será atendida pelo picking na geração automática
		If QtdComp(nReposicao) >= QtdComp(nSaldoEnd) // Se o saldo é menor que o mínimo para reposição
			If ExistBlock("DLQTDABT")
				nQtdAbtPE := ExecBlock('DLQTDABT',.F.,.F.,{__cLocOrig,cEndereco,__cProduto,nQtdApanhe})
				If ValType(nQtdAbtPE) == 'N'
					nQtdAbast := nQtdAbtPE
				EndIf
			EndIf
			If nQtdAbast <= 0
				nQtdAbast := nCapEndPkg-nSaldoEnd
			EndIf
			nRet := 2
		EndIf
	Else 
		nRet :=1	
	EndIf
	RestArea(aAreaDC3)
	RestArea(aAreaAnt)
Return(nRet)

/*/-----------------------------------------------------------------------------
Efetua a geração do reabastecimento do endereço solicitado.
-----------------------------------------------------------------------------/*/
Static Function GeraAbtPkg(cEstFis,cEndereco,nQtdAbast,lRadioF,cMotNReab,lReabDem)
Local lRet     := .T.
Local cTipoAux := "E"
Local nQuantOS := 0 //-- Quantidade gerada na OS de Reabastecimento

Default cMotNReab := ""
Default lReabDem  := .F.

	//O tratamento a seguir é para quando está gerando um reabastecimento a partir de
	//um movimento referente a um mapa de separação fracionado.
	//Se o tipo do movimento continuar como 'B', o reabastecimento também será
	//gerado com tipo 'B', e consequentemente não será convocado via coletor de dados
	cTipoAux  := cTipoSDB //Salva o valor da variável private
	cTipoSDB  := 'E' //Seta o valor para 'E'
	aParamBkp := AClone(aParam150) //-- Salvando os dados dos parametros da separação
	aParam150[25] := __cLocOrig //-- Armazem
	aParam150[27] := cEstFis    //-- Estrutura
	aParam150[26] := cEndereco  //-- Endereco
	aParam150[06] := nQtdAbast  //-- Endereco
	aParam150[09] := "" //-- Limpa o serviço, força busca
	aParam150[10] := "" //-- Limpa a tarefa, força busca
	aParam150[28] := "" //-- Limpa a ordem da tarefa, força busca

	lRet := WmsAbastece(lRadioF, "1", "D" /*Demanda*/, @nQuantOS, @cMotNReab, lReabDem)

	ACopy(aParamBkp,aParam150) //Restaura os valores dos parâmetros
	cTipoSDB := cTipoAux
	nQtdAbast := nQuantOS //Retornando a quantidade do reabastecimento

Return(lRet)

/*/-----------------------------------------------------------------------------
Busca dentre os endereços de picking possíveis, qual poderá ser utilizado para
gerar reabastecimento automático. Leva em conta o número máximo de pickings que
podem ser ocupados por um mesmo produto.
Caso seja mais de um endereço, tenta fazer um rateio dos reabastecimentos.
-----------------------------------------------------------------------------/*/
Static Function GeraAbtDem(lGeraAbast,nQtdApanhe,lRadioF,aSeqAbPkg, lReabDem)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasSBE  := GetNextAlias()
Local cZonaPkg   := ""
Local cWmsMulP   := SuperGetMV("MV_WMSMULP", .F., "N")
Local nLimSBE    := SuperGetMV("MV_WMSNRPO", .F.,  10) //-- Limite de enderecos picking ocupados
Local aEnderecos := {}
Local aTamSX3    := TamSx3('BF_QUANT')
Local nQtdAbast  := 0
Local nQtdAbPkg  := 0
Local nCapEndPkg := 0
Local nX         := 0
Local nI         := 0
Local lFirstRat  := .T.
Local cInEnd     := ''
Local lPercOcup  := .F.
Local nSaldoSBF  := 0
Local lEndPri    := .F. 
Local cMotNReab  := ''
Local nQtdApAnt	 := 0
Local lAvaliaDCP := .F.
Local cAliasDCP  := ""
Default lReabDem := .F.

	If lWMSMULP
		cWmsMulP := Iif(ExecBlock("WMSMULP", .F., .F., {__cProduto}), "S", "N")
	EndIf

	//-- Procura por qualquer endereço de picking vazio
	DbSelectArea('SB5')
	SB5->(DbSetOrder(1))
	If SB5->(MsSeek(xFilial('SB5')+__cProduto))
		cZonaPkg := SB5->B5_CODZON
	EndIf
	lGeraAbast := .F.

	If Len(__aEndPkg) > 0 .And. !lRadioF
		For nI := 1 To Len(__aEndPkg)
			cInEnd += "'" + __aEndPkg[nI] + "',"
		Next
		cInEnd := SubStr(cInEnd,1,Len(cInEnd)-1)
	EndIf

	// Para os casos em que a seq. de abastecimento do produto possuir mais de uma estrutura do tipo
	// picking, deve realizar a busca por estrutura, para que reabasteça corretamente todas elas.
	For nI := 1 To Len(aSeqAbPkg)

		// Posiciona na sequencia de abastecimento
		DC3->(DbSetOrder(1)) // DC3_FILIAL, DC3_CODPRO, DC3_LOCAL, DC3_ORDEM
		DC3->(DbSeek(xFilial("DC3")+__cProduto+__cLocOrig+aSeqAbPkg[nI]))
		// Somente estruturas que estejam parametrizadas para reabastecimento automático
		If DC3->DC3_PERREP <= 0
			AddMsgLog(DC3->DC3_TPESTR,,,,,,nQtdApanhe,,STR0061) // Estrutura picking não permite reabastecimento automático.
			Loop
		EndIf
		// Somente reabastece, caso a quantidade minima de separação da estrtura seja menor que o solicitado
		If QtdComp(DC3->DC3_QTDUNI) > QtdComp(nQtdApanhe)
			AddMsgLog(DC3->DC3_TPESTR,,,,,,nQtdApanhe,,WmsFmtMsg(STR0042,{{"[VAR01]",Str(DC3->DC3_QTDUNI)}})) // Tipo de separação: Quantidade mínima. Qtd menor que a separação mínima. ([VAR01]).  
			Loop
		EndIf

		lAvaliaDCP := .F.
		cAliasDCP := GetNextAlias()
		BeginSql Alias cAliasDCP
			SELECT DCP.R_E_C_N_O_
			FROM %Table:DCP% DCP
			WHERE DCP.DCP_FILIAL = %xFilial:DC8%
			AND DCP.DCP_LOCAL = %Exp:__cLocOrig%
			AND DCP.DCP_ESTFIS = %Exp:DC3->DC3_TPESTR%
			AND DCP.DCP_NORMA = %Exp:DC3->DC3_CODNOR%
			AND DCP_CODPRO = %Exp:__cProduto%
			AND DCP.%NotDel%
		EndSql
		If (cAliasDCP)->(!Eof())
			lAvaliaDCP := .T.
		EndIf
		(cAliasDCP)->(DbCloseArea())

		If lAvaliaDCP //--Se possuir percentual de ocupação cadastrado busca por todos os endereços da estrutura para avaliação

			//-- Se não encontrou endereços, ou ainda não atingiu o total de picking ocupados
			cQuery := "SELECT ZON.ZON_ORDEM,"
			//Se foi informado o produto no endereço ele tem prioridade
			cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 3 ELSE 1 END PRD_ORDEM,"
			cQuery += " SBE.BE_ESTFIS, SBE.BE_LOCALIZ,"
			If Len(__aEndPkg) > 0 .And. !lRadioF
				cQuery += "CASE WHEN SBE2.BE_LOCALIZ IS NULL THEN 2 ELSE 1 END PKG_ORDEM,"
			Else
				cQuery += " 2 PKG_ORDEM,"
			EndIf
			//-- Carregando endereços que possuam saldo
			cQuery += "(SELECT CASE WHEN sum(BF_QUANT) IS NULL THEN 0 ELSE sum(BF_QUANT) END BF_QUANT"
			cQuery += "  FROM "+RetSqlName("SBF")+" SBF"
			cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
			cQuery += "   AND BF_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND BF_PRODUTO = '"+__cProduto+"'"
			cQuery += "   AND BF_LOCALIZ = SBE.BE_LOCALIZ"
			cQuery += "   AND BF_ESTFIS  = SBE.BE_ESTFIS"
			cQuery += "   AND BF_QUANT > 0"
			cQuery += "   AND D_E_L_E_T_ = ' ') BF_SALDO,"
			//-- Carregando o saldo previsto de entrada
			cQuery += "(SELECT CASE WHEN sum(DB_QUANT) IS NULL THEN 0 ELSE sum(DB_QUANT) END DB_QUANT"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND SDB.DB_PRODUTO = '"+__cProduto+"'"
			cQuery += "   AND SDB.DB_ENDDES  = SBE.BE_LOCALIZ"
			cQuery += "   AND SDB.DB_ESTDES  = SBE.BE_ESTFIS"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
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
															" AND SDBM.D_E_L_E_T_ = ' ' )) DB_SALDO"
			cQuery += " FROM "+RetSqlName("SBE")+" SBE"
			//Somente considera as zonas de armazenagem na query
			cQuery += " INNER JOIN ("
			//Não utiliza do cadastro por que existe um PE que pode alterar, usa a variável
			cQuery += "SELECT '00' ZON_ORDEM, '"+cZonaPkg+"' ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("SB5")
			cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "   AND B5_COD    = '"+__cProduto+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery += " UNION ALL "
			cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("DCH")
			cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
			cQuery += "   AND DCH_CODPRO = '"+__cProduto+"'"
			cQuery += "   AND DCH_CODZON <> '"+cZonaPkg+"'"
			cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
			cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
			If Len(__aEndPkg) > 0 .And. !lRadioF
				cQuery += " LEFT JOIN "+RetSqlName('SBE')+" SBE2"
				cQuery +=   " ON SBE2.BE_FILIAL  = '"+xFilial('SBE')+"'"
				cQuery +=  " AND SBE2.BE_LOCAL   = SBE.BE_LOCAL"
				cQuery +=  " AND SBE2.BE_LOCALIZ = SBE.BE_LOCALIZ"
				cQuery +=  " AND SBE2.BE_LOCALIZ IN ("+cInEnd+")"
				cQuery +=  " AND SBE2.D_E_L_E_T_ = ' '"
			EndIf
			cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
			cQuery +=   " AND SBE.BE_LOCAL   = '"+__cLocOrig+"'"
			cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+__cProduto+"')"
			cQuery +=   " AND SBE.BE_STATUS <> '3'"
			cQuery +=   " AND SBE.BE_ESTFIS  = '"+DC3->DC3_TPESTR+"'"
			cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY BF_SALDO DESC, DB_SALDO DESC, PRD_ORDEM, ZON_ORDEM,PKG_ORDEM, SBE.BE_LOCALIZ"
			cQuery := ChangeQuery(cQuery)

		Else
			/*Se não possuir percentual de ocupação cadastrado busca somente por endereços que não possuam saldos
			ou entradas previstas de outros produtos, somente os produtos que atendem a este criterio podem gerar reabastecimento*/

			cQuery := " SELECT * FROM (

			//-- Se não encontrou endereços, ou ainda não atingiu o total de picking ocupados
			cQuery += "SELECT ZON.ZON_ORDEM,"
			//Se foi informado o produto no endereço ele tem prioridade
			cQuery += " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 3 ELSE 1 END PRD_ORDEM,"
			cQuery += " SBE.BE_ESTFIS, SBE.BE_LOCALIZ,"
			If Len(__aEndPkg) > 0 .And. !lRadioF
				cQuery += "CASE WHEN SBE2.BE_LOCALIZ IS NULL THEN 2 ELSE 1 END PKG_ORDEM,"
			Else
				cQuery += " 2 PKG_ORDEM,"
			EndIf
			//-- Carregando endereços que possuam saldo
			cQuery += "	( SELECT CASE WHEN sum(BF_QUANT) IS NULL THEN 0 ELSE sum(BF_QUANT) END BF_QUANT"
			cQuery += "  FROM "+RetSqlName("SBF")+" SBF"
			cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
			cQuery += "   AND BF_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND BF_PRODUTO = '"+__cProduto+"'"
			cQuery += "   AND BF_LOCALIZ = SBE.BE_LOCALIZ"
			cQuery += "   AND BF_ESTFIS  = SBE.BE_ESTFIS"
			cQuery += "   AND BF_QUANT > 0"
			cQuery += "   AND D_E_L_E_T_ = ' ' 	) BF_SALDO, "

			//-- Carregando endereços que possuam saldo de outros produtos
			cQuery += "	( SELECT CASE WHEN sum(BF_QUANT) IS NULL THEN 0 ELSE sum(BF_QUANT) END BF_QUANT"
			cQuery += "  FROM "+RetSqlName("SBF")+" SBF"
			cQuery += " WHERE BF_FILIAL  = '"+xFilial("SBF")+"'"
			cQuery += "   AND BF_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND BF_PRODUTO <> '"+__cProduto+"'"
			cQuery += "   AND BF_LOCALIZ = SBE.BE_LOCALIZ"
			cQuery += "   AND BF_ESTFIS  = SBE.BE_ESTFIS"
			cQuery += "   AND BF_QUANT > 0"
			cQuery += "   AND D_E_L_E_T_ = ' ' )BF_OUTPROD, "

			//-- Carregando o saldo previsto de entrada
			cQuery += "(SELECT CASE WHEN sum(DB_QUANT) IS NULL THEN 0 ELSE sum(DB_QUANT) END DB_QUANT"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND SDB.DB_PRODUTO = '"+__cProduto+"'"
			cQuery += "   AND SDB.DB_ENDDES  = SBE.BE_LOCALIZ"
			cQuery += "   AND SDB.DB_ESTDES  = SBE.BE_ESTFIS"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
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
															" AND SDBM.D_E_L_E_T_ = ' ' )) DB_SALDO,"

			//-- Carregando o saldo previsto de entrada de outros produtos
			cQuery += "(SELECT CASE WHEN sum(DB_QUANT) IS NULL THEN 0 ELSE sum(DB_QUANT) END DB_QUANT"
			cQuery += "  FROM "+RetSqlName("SDB")+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery += "   AND SDB.DB_LOCAL   = '"+__cLocOrig+"'"
			cQuery += "   AND SDB.DB_PRODUTO <> '"+__cProduto+"'"
			cQuery += "   AND SDB.DB_ENDDES  = SBE.BE_LOCALIZ"
			cQuery += "   AND SDB.DB_ESTDES  = SBE.BE_ESTFIS"
			cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery += "   AND SDB.DB_ESTORNO = ' '"
			cQuery += "   AND SDB.DB_ATUEST  = 'N'"
			cQuery += "   AND SDB.D_E_L_E_T_ = ' '"
			cQuery += "   AND SDB.DB_ORDATIV = (SELECT MIN(DB_ORDATIV)"+;
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
															" AND SDBM.D_E_L_E_T_ = ' ' )) DB_OUTPROD"

			cQuery += " FROM "+RetSqlName("SBE")+" SBE"
			//Somente considera as zonas de armazenagem na query
			cQuery += " INNER JOIN ("
			//Não utiliza do cadastro por que existe um PE que pode alterar, usa a variável
			cQuery += "SELECT '00' ZON_ORDEM, '"+cZonaPkg+"' ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("SB5")
			cQuery += " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "   AND B5_COD    = '"+__cProduto+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery += " UNION ALL "
			cQuery += "SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
			cQuery += "  FROM "+RetSqlName("DCH")
			cQuery += " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
			cQuery += "   AND DCH_CODPRO = '"+__cProduto+"'"
			cQuery += "   AND DCH_CODZON <> '"+cZonaPkg+"'"
			cQuery += "   AND D_E_L_E_T_ = ' ') ZON"
			cQuery += " ON ZON.ZON_CODZON = SBE.BE_CODZON"
			If Len(__aEndPkg) > 0 .And. !lRadioF
				cQuery += " LEFT JOIN "+RetSqlName('SBE')+" SBE2"
				cQuery +=   " ON SBE2.BE_FILIAL  = '"+xFilial('SBE')+"'"
				cQuery +=  " AND SBE2.BE_LOCAL   = SBE.BE_LOCAL"
				cQuery +=  " AND SBE2.BE_LOCALIZ = SBE.BE_LOCALIZ"
				cQuery +=  " AND SBE2.BE_LOCALIZ IN ("+cInEnd+")"
				cQuery +=  " AND SBE2.D_E_L_E_T_ = ' '"
			EndIf
			cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
			cQuery += " AND SBE.BE_LOCAL   = '"+__cLocOrig+"'"
			cQuery += " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+__cProduto+"')"
			cQuery += " AND SBE.BE_STATUS <> '3'"
			cQuery += " AND SBE.BE_ESTFIS  = '"+DC3->DC3_TPESTR+"'"
			cQuery += " AND SBE.D_E_L_E_T_ = ' '"
			cQuery += " ) QRY_RESULT "
			cQuery += " WHERE BF_OUTPROD <= 0 " //-- Filtra endereços sem saldos de outros produtos
			cQuery += " 	AND DB_OUTPROD <= 0 " //-- Filtra endereços sem entrada prevista de outros produtos
			cQuery += " ORDER BY BF_SALDO DESC, DB_SALDO DESC, PRD_ORDEM, ZON_ORDEM,PKG_ORDEM, BE_LOCALIZ"
			cQuery := ChangeQuery(cQuery)

		EndIf

		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSBE,.F.,.T.)
		TcSetField(cAliasSBE,'PRD_ORDEM', 'N',5,0)
		TcSetField(cAliasSBE,'PKG_ORDEM', 'N',5,0)
		TcSetField(cAliasSBE,'BF_SALDO' , 'N',aTamSX3[1],aTamSX3[2])
		TcSetField(cAliasSBE,'DB_SALDO' , 'N',aTamSX3[1],aTamSX3[2])

		While (cAliasSBE)->(!Eof())
			nSaldoSBF := 0
			If lAvaliaDCP
				//Verifica se o endereço utiliza percentual de ocupação
				lPercOcup := WmsChkDCP(__cLocOrig,(cAliasSBE)->BE_LOCALIZ,DC3->DC3_TPESTR,DC3->DC3_CODNOR,__cProduto)
			
				// Se não possuir percentual de ocupação, deve avaliar se existe
				// saldo de outro produto no endereço. Neste caso não reabastece.
				If !lPercOcup
					nSaldoSBF := WmsSaldoSBF(__cLocOrig,(cAliasSBE)->BE_LOCALIZ,/*cProduto*/,/*cNumSerie*/,/*cLoteCtl*/,/*cNumLote*/,.F.,.T.,.T.,.F.,'1')
					nSaldoSBF -= ((cAliasSBE)->BF_SALDO+(cAliasSBE)->DB_SALDO)
				Else
					nSaldoSBF := 0
				EndIf
			EndIf

			If QtdComp(nSaldoSBF) <= 0
				nCapEndPkg := DLQtdNorma(__cProduto,__cLocOrig,DC3->DC3_TPESTR,/*cDesUni*/,.T.,(cAliasSBE)->BE_LOCALIZ)
				AAdd(aEnderecos,{(cAliasSBE)->ZON_ORDEM,;
										DC3->DC3_ORDEM,;
										Iif(QtdComp((cAliasSBE)->BF_SALDO)>0,'01','99'),;
										Iif(QtdComp((cAliasSBE)->DB_SALDO)>0,'01','99'),;
										Iif((cAliasSBE)->PRD_ORDEM==3 .And. QtdComp((cAliasSBE)->BF_SALDO+(cAliasSBE)->DB_SALDO)>0,'02',StrZero((cAliasSBE)->PRD_ORDEM,2)),;
										DC3->DC3_TPESTR,;
										(cAliasSBE)->BE_LOCALIZ,;
										(cAliasSBE)->BF_SALDO,;
										(cAliasSBE)->DB_SALDO,;
										nCapEndPkg})
				If (cAliasSBE)->PRD_ORDEM==1 
					lEndPri := .T.
				EndIf				
				If (nLimSBE > 0 .And. nLimSBE <= Len(aEnderecos)) .Or. cWmsMulP == "N"
					Exit
				EndIf
			Else
				// Se o produto possui saldo do produto, porém possui saldo de outros produtos - picking misto
				If ((cAliasSBE)->BF_SALDO+(cAliasSBE)->DB_SALDO) > 0
					AddMsgLog(DC3->DC3_TPESTR,(cAliasSBE)->BE_LOCALIZ,,,(cAliasSBE)->BF_SALDO,(cAliasSBE)->DB_SALDO,nQtdApanhe,,STR0060) // Endereço possui saldo de outros produtos.
				EndIf
			EndIf
			(cAliasSBE)->(DbSkip())
		EndDo
		(cAliasSBE)->(DbCloseArea())
	Next
	RestArea(aAreaAnt)

	aSeqAbPkg := {}
	__aEndPkg := {}

	If Len(aEnderecos) > 0
		//-- Pego todos os endereços, vai ordenar os mesmos do menor saldo para o maior saldo
		//-- Esta lógica é para fazer um "rateio" do reabastecimento, forçando todos os endereços ficarem abastecidos
		IF lEndPri 
			ASort(aEnderecos,,,{|x,y| x[3]+x[4]+x[5]+x[1]+x[2]+StrZero((x[8]+x[9]),aTamSX3[1],aTamSX3[2])+x[7] < y[3]+y[4]+y[5]+y[1]+y[2]+StrZero((y[8]+y[9]),aTamSX3[1],aTamSX3[2])+y[7]})
		ELSE
			ASort(aEnderecos,,,{|x,y| x[3]+x[4]+x[1]+x[2]+x[5]+StrZero((x[8]+x[9]),aTamSX3[1],aTamSX3[2])+x[7] > y[3]+y[4]+y[1]+y[2]+y[5]+StrZero((y[8]+y[9]),aTamSX3[1],aTamSX3[2])+y[7]})
		ENDIF

		nX := 1
		//Enquanto houver saldo a ser reabastecido
		While lRet .And. QtdComp(nQtdApanhe) > 0
			//-- Se é a primeira vez que está passando e o endereço está cheio, tenta outro
			If !lFirstRat .Or. QtdComp(aEnderecos[nX,8]+aEnderecos[nX,9]) < QtdComp(aEnderecos[nX,10])
				//-- Se a capacidade do endereço é maior que o saldo do mesmo, tente reabastecer a diferença
				If QtdComp(aEnderecos[nX,10]) > QtdComp(aEnderecos[nX,8]+aEnderecos[nX,9])
					//-- Se possuir só um endereço, deverá tentar reabastecer tudo para este
					If Len(aEnderecos) == 1
						nQtdAbast := Max(aEnderecos[nX,10] - (aEnderecos[nX,8]+aEnderecos[nX,9]),nQtdApanhe)
					Else //-- Senão reabastece até completar o saldo apenas
						nQtdAbast := aEnderecos[nX,10] - (aEnderecos[nX,8]+aEnderecos[nX,9])
					EndIf
				Else //-- Senão tenta jogar mais mais saldo
					nQtdAbast := Min(aEnderecos[nX,10], nQtdApanhe)
				EndIf	
				nQtdAbPkg := nQtdAbast
				lRet := GeraAbtPkg(aEnderecos[nX,6],aEnderecos[nX,7],@nQtdAbast,lRadioF, @cMotNReab, lReabDem)
				If lRet
					//-- Se não conseguiu reabastecer nada, vai sair, pois não tem saldo para reabastecimento
					If QtdComp(nQtdAbast) <= 0 
						If ValType(cMotNReab) == 'C' .And. !Empty(cMotNReab) // Se há motivo para não haver o reabastecimento, exibe no relatório e tenta o próximo endereço
							AddMsgLog(aEnderecos[nX,6],aEnderecos[nX,7],,,aEnderecos[nX,8],aEnderecos[nX,9],nQtdAbPkg,nQtdAbast,cMotNReab,.T.) 
						Else
							Exit
						EndIf
					Else
						AddMsgLog(aEnderecos[nX,6],aEnderecos[nX,7],,,aEnderecos[nX,8],aEnderecos[nX,9],nQtdAbPkg,nQtdAbast,STR0035,.T.) //"Reabastecimento gerado para o endereço."
						aEnderecos[nX,9] += nQtdAbast //-- Soma o saldo no endereço abastecido, para calculos de rateio
						nQtdApanhe -= nQtdAbast //-- Diminui a quantidade abastecida da solicitada para separar
						lGeraAbast := .T.
						//-- Adiciona a sequencia de abastecimento para processar
						If AScan(aSeqAbPkg,aEnderecos[nX,2]) == 0
							AAdd(aSeqAbPkg,aEnderecos[nX,2])
						EndIf
						AAdd(__aReabGer,{aEnderecos[nX,6],aEnderecos[nX,7],nQtdAbast})
					EndIf
				EndIf
			EndIf
			//-- Se chegou no ultimo endereço volta para o primeiro
			If (nX+1) > Len(aEnderecos)
				 If nQtdApanhe == nQtdApAnt
			 		Exit
				Endif
				lFirstRat := .F.
				nQtdApAnt := nQtdApanhe
			Else
				nX++
			EndIf
		EndDo
	EndIf

	//-- Só marcar que gerou reabastecimento, se conseguiu atender todo o solicitado para separação
	If lGeraAbast
		lGeraAbast := (QtdComp(nQtdApanhe) <= 0)
	EndIf

RestArea(aAreaAnt)
Return(lRet)

/*/-----------------------------------------------------------------------------
Adiciona mensagens ao registro de LOG de busca de saldo.
Formato ALogSld
	ALogSld[nX,1] = Carga
	ALogSld[nX,2] = Documento
	ALogSld[nX,3] = Produto
	ALogSld[nX,4] = Descrição Produto
	ALogSld[nX,5] = Quantidade Apanhe
	ALogSld[nX,6] = Regra WMS
	ALogSld[nX,7] = Array(2)
		ALogSld[nX,7,nY,1] = "Busca de saldo ..."
		ALogSld[nX,7,nY,2] = Array(6)
			ALogSld[nX,7,nY,2,nZ,1] = Estrutura Fisica
			ALogSld[nX,7,nY,2,nZ,2] = Endereço
			ALogSld[nX,7,nY,2,nZ,3] = Lote
			ALogSld[nX,7,nY,2,nZ,4] = Data Validade
			ALogSld[nX,7,nY,2,nZ,5] = Saldo Disponível
			ALogSld[nX,7,nY,2,nZ,6] = Saldo RF Saída
			ALogSld[nX,7,nY,2,nZ,7] = Quantidade Solicitada
			ALogSld[nX,7,nY,2,nZ,8] = Quantidade Utilizada
			ALogSld[nX,7,nY,2,nZ,9] = Mensagem
			ALogSld[nX,7,nY,2,nZ,10] = Indica uma mensagem do reabastecimento
-----------------------------------------------------------------------------/*/
Static Function AddMsgLog(cEstrtura,cEndereco,cLoteCtl,dDtValid,nSaldoSBF,nSaldoRF,nTotSep,nQtdSep,cMensagem,lReabast)
Local aLogMsg := Nil
Default cEstrtura := ""
Default cEndereco := ""
Default cLoteCtl  := ""
Default dDtValid  := CtoD('')
Default nSaldoSBF := 0
Default nSaldoRF  := 0
Default nTotSep   := 0
Default nQtdSep   := 0
Default lReabast := .F.

	If Type("aLogSld") != "A"
		Return Nil
	EndIf

	aLogMsg := aLogSld[Len(aLogSld),7]
	AAdd(aLogMsg[Len(aLogMsg),2],{cEstrtura,cEndereco,cLoteCtl,dDtValid,nSaldoSBF,nSaldoRF,nTotSep,nQtdSep,cMensagem,lReabast})

Return (Nil)

/*/-----------------------------------------------------------------------------
Retorna se o Local/Produto possui uma estrutura do tipo pulmão cadastrada.
-----------------------------------------------------------------------------/*/
Static Function PrdTemPulm(cLocal,cProduto)
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasQry := ''
Local lRet := .F.

	cQuery := "SELECT DC3_TPESTR"
	cQuery +=  " FROM "+RetSqlName('DC3')+" DC3, "+RetSqlName('DC8')+" DC8"
	cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
	cQuery +=   " AND DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
	cQuery +=   " AND DC3.DC3_LOCAL  = '"+cLocal+"'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND DC3.DC3_TPESTR = DC8.DC8_CODEST"
	cQuery +=   " AND DC8.DC8_TPESTR = '1'"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Retorna se o Local/Produto possui uma estrutura do tipo picking cadastrada.
-----------------------------------------------------------------------------/*/
Static Function PrdTemPkg(cLocal,cProduto)
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasQry := ''
Local lRet := .F.

	cQuery := "SELECT DC3_TPESTR"
	cQuery +=  " FROM "+RetSqlName('DC3')+" DC3, "+RetSqlName('DC8')+" DC8"
	cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
	cQuery +=   " AND DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
	cQuery +=   " AND DC3.DC3_LOCAL  = '"+cLocal+"'"
	cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
	cQuery +=   " AND DC3.DC3_TPESTR = DC8.DC8_CODEST"
	cQuery +=   " AND DC8.DC8_TPESTR = '2'"
	cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------------------
/*/{Protheus.doc} WmsPrdEmb
Verifica se o produto gera quantidades unitizadas para embalagem

@author  Guilherme Alexandre Metzger
@version P11
@Since   10/09/2014
/*/
//--------------------------------------------------------------
Static Function WmsPrdEmb(cProduto)
Local aAreaAnt := GetArea()
Local lRet     := .F.

	SB5->(DbSetOrder(1))
	If SB5->(MsSeek(xFilial('SB5')+cProduto)) .And. SB5->B5_WMSEMB == '1'
		lRet := .T.
	EndIf

RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
Retorna a quantidade máxima de apanhe para o picking com base no percentual
máximo de apanhe
-----------------------------------------------------------------------------/*/
Static Function ApMaxPic(cEstFis,nQtdUniti,nPerApMax,nQtdSepMin)
Local nQtdApMax := 0
Local nApMinimo := 1 / (10 ** TamSX3('DC3_QTDUNI')[2]) // Cálculo da quantidade mínima possível para um apanhe
Local nQtdApUni := Max(nQtdSepMin,nApMinimo)
Local nQtdNorma := DLQtdNorma(__cProduto,__cLocOrig,cEstFis,/*cDesUni*/,.F.)

	// Assume valores padrão caso estejam zerados
	nPerApMax := Iif(QtdComp(nPerApMax) > 0,nPerApMax,100)
	nQtdUniti := Iif(QtdComp(nQtdUniti) > 0,nQtdUniti,1)

	// Calcula a quantidade máxima para apanhe
	nQtdApMax := (nQtdNorma * nQtdUniti * nPerApMax) / 100

	//Garante que a quantidade retornada seja múltipla do apanhe unitário mínimo
	nQtdApMax := NoRound(nQtdApMax/nQtdApUni,0) * nQtdApUni

Return nQtdApMax

/*/-----------------------------------------------------------------------------
Retorna a quantidade múltipla com base na segunda unidade de medida do produto
-----------------------------------------------------------------------------/*/
Static Function RetQtdMul(nQtdApEnd,nApMinimo)
Local nQtdMul := nQtdApEnd

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial('SB1')+__cProduto))
	If !Empty(SB1->B1_CONV)
		//Precisa calcular apenas para o caso de 1aUM ser unitária e 2aUM agrupadora
		//(Ex.: 1aUM = UN e 2aUM = CX), pois do contrário sempre será quantidade múltipla
		If SB1->B1_TIPCONV == 'D'
			nQtdMul := NoRound(nQtdApEnd / SB1->B1_CONV, 0) * SB1->B1_CONV
		EndIf
	Else
		//Se o produto não possui 2aUM faz com base no apanhe unitário mínimo
		nQtdMul := NoRound(nQtdApEnd / nApMinimo, 0) * nApMinimo
	EndIf

Return nQtdMul


/*/-----------------------------------------------------------------------------
Cria uma tabela temporária que deverá ser utilizada para percorrer os saldos
quando possuir os pontos de entrada WMSFIFO ou WMSFIFO2 - Compatibilização
-----------------------------------------------------------------------------/*/
Static Function CriaTmpSld(lCnsPkgFut)
Local aTamSX3 := {}
Local aColSld := {}
Local cAliasSld := GetNextAlias()

	/*Criando um campo Indice*/      AAdd(aColSld,{"ORD_TEMP"   ,"C",6,0})
	aTamSX3 := TamSX3("BF_LOCALIZ"); AAdd(aColSld,{"BF_LOCALIZ" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("BF_LOTECTL"); AAdd(aColSld,{"BF_LOTECTL" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("B8_DTVALID"); AAdd(aColSld,{"B8_DTVALID" ,"D",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("BF_NUMLOTE"); AAdd(aColSld,{"BF_NUMLOTE" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("BF_NUMSERI"); AAdd(aColSld,{"BF_NUMSERI" ,"C",aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("BF_QUANT");   AAdd(aColSld,{"BF_SALDO"   ,"N",aTamSX3[1],aTamSX3[2]})
	If !lCnsPkgFut
	/*Adicionando o Saldo RF*/       AAdd(aColSld,{"BF_QTDSPR"  ,"N",aTamSX3[1],aTamSX3[2]})
	EndIf
	aTamSX3 := TamSX3("BF_ESTFIS");  AAdd(aColSld,{"BF_ESTFIS"  ,"C",aTamSX3[1],aTamSX3[2]})
	/*Adicionando o Recno da SBF*/   AAdd(aColSld,{"RECNOSBF"   ,"N",10,0})
	// Cria tabelas temporárias
	CriaTabTmp(aColSld,{"ORD_TEMP"},cAliasSld)
	Aadd(aAliasSld, cAliasSld)
Return cAliasSld

/*/-----------------------------------------------------------------------------
Grava os dados da consulta de estoque na tabela temporária
quando possuir os pontos de entrada WMSFIFO ou WMSFIFO2 - Compatibilização
-----------------------------------------------------------------------------/*/
Static Function GravaTmpSld(aSldLote,cAliasSld,lCnsPkgFut)
Local nCont   := 0
Local cOrdTmp := "000000"

	(cAliasSld)->( DbSetOrder(1) )
	
	For nCont := 1 To Len(aSldLote)
		cOrdTmp := Soma1(cOrdTmp)
		RecLock(cAliasSld,.T.)
		(cAliasSld)->ORD_TEMP   := cOrdTmp
		(cAliasSld)->BF_LOCALIZ := aSldLote[nCont,03]
		(cAliasSld)->BF_LOTECTL := aSldLote[nCont,01]
		(cAliasSld)->B8_DTVALID := aSldLote[nCont,07]
		(cAliasSld)->BF_NUMLOTE := aSldLote[nCont,02]
		(cAliasSld)->BF_NUMSERI := aSldLote[nCont,04]
		(cAliasSld)->BF_SALDO   := aSldLote[nCont,05]
		If !lCnsPkgFut
			(cAliasSld)->BF_QTDSPR := aSldLote[nCont,17]
		EndIf
		(cAliasSld)->BF_ESTFIS  := aSldLote[nCont,14]
		(cAliasSld)->RECNOSBF   := aSldLote[nCont,09]
		(cAliasSld)->(MsUnLock())
	Next
	(cAliasSld)->(DbGoTop())

Return cAliasSld

//--------------------------------------------------------------
/*/{Protheus.doc} ReGerReab
Gera novamente os reabastecimentos que foram eliminados no
desarme da transação quando a tarefa de separação
não utilizar RF e o reabastecimento utilizar.

@author  Guilherme A. Metzger
@version P11
@since   18/02/2016
/*/
//--------------------------------------------------------------
Static Function ReGerReab()
Local aAreaAnt   := GetArea()
Local aAreaDC3   := DC3->(GetArea())
Local nI         := 1
Local nCapEndPkg := 0
Local nSaldoEnd  := 0
Local nTipoPerc  := 0
Local cEndereco  := ''
Local cEstFis    := ''
Local nQtdAbast  := 0

	DC3->(DbSetOrder(2)) //DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
	For nI := 1 To Len(__aReabGer)
		cEstFis   := __aReabGer[nI,1]
		cEndereco := __aReabGer[nI,2]
		nQtdAbast := __aReabGer[nI,3]
		If DC3->(DbSeek(xFilial('DC3')+__cProduto+__cLocOrig+cEstFis))
			nCapEndPkg := DLQtdNorma(__cProduto,__cLocOrig,cEstFis,/*cDesUni*/,.T.,cEndereco)
			If WmsChkDCP(__cLocOrig,cEndereco,cEstFis,DC3->DC3_CODNOR,__cProduto,@nTipoPerc) .And. nTipoPerc == 1
				nSaldoEnd := WmsSaldoSBF(__cLocOrig,cEndereco,__cProduto,,,,.F.,.T.,.T.,.T.,'1')
			Else
				nSaldoEnd := WmsSaldoSBF(__cLocOrig,cEndereco,/*cProduto*/,,,,.F.,.T.,.T.,.T.,'1')
			EndIf
		EndIf
		// Verifica se já não está com saldo atual + previsto de entrada acima de sua capacidade,
		// pois o usuário pode ficar re-executando a  OS interrompida e isso acabar gerando
		// diversos reabastecimentos desnecessários.
		If nCapEndPkg > nSaldoEnd
			GeraAbtPkg(cEstFis,cEndereco,nQtdAbast,.T.)
		EndIf
	Next

RestArea(aAreaDC3)
RestArea(aAreaAnt)
Return .T.

//--------------------------------------------------
/*/{Protheus.doc} FindReabPK
Verifica se há endereços de picking para reabastecimento
por percentual de reposição

@author alexsader.correa
@since 03/07/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function FindReabPK(nGerouReab,lRadioF)
Local lRet       := .T.
Local cAliasSDB  := Nil
Local clistRecno := ""
Local nQtdAbast  := 0
Local nI         := 0
Local nQtdApPkg  := 0
Local nRetPkg    := 0
	// Busca os endereços de picking utilizado e avalia reabastecimento por percentual de reposição
	For nI := 1 To Len(aValReab)
		cListRecno += cValToChar(aValReab[nI][1])+","
	Next nI
	cListRecno := "%("+Substr(cListRecno,1,Len(cListRecno)-1)+")%"
	cAliasSDB := GetNextAlias()
	BeginSql Alias cAliasSDB
		SELECT SDB.DB_ESTFIS,
			   SDB.DB_LOCALIZ
		  FROM %Table:SDB% SDB
		 INNER JOIN %Table:DC8% DC8
		    ON DC8.DC8_FILIAL = %xFilial:DC8%
		   AND DC8.DC8_CODEST = SDB.DB_ESTFIS
		   AND DC8.DC8_TPESTR = '2'
		   AND DC8.%NotDel%
		 WHERE SDB.DB_FILIAL = %xFilial:SDB%
		   AND SDB.R_E_C_N_O_ IN %Exp:cListRecno%
		   AND SDB.DB_ESTORNO <> 'S'
		   AND SDB.DB_ATUEST = 'N'
		   AND SDB.DB_IDDCF = %Exp:__CIdDCF%
		   AND SDB.%NotDel%
		 GROUP BY SDB.DB_ESTFIS,
		   		  SDB.DB_LOCALIZ
	EndSql
	Do While (cAliasSDB)->(!Eof())
		nRetPkg := PerRepPkg((cAliasSDB)->DB_ESTFIS,(cAliasSDB)->DB_LOCALIZ,@nQtdAbast,0,lRadioF)
		If nRetPkg == 2
			nQtdApPkg := nQtdAbast
			lRet := GeraAbtPkg((cAliasSDB)->DB_ESTFIS,(cAliasSDB)->DB_LOCALIZ,@nQtdAbast,lRadioF)
			If lRet .And. QtdComp(nQtdAbast) > QtdComp(0)
				nGerouReab := 2
				AAdd(__aEndPkg, (cAliasSDB)->DB_LOCALIZ)
				AddMsgLog((cAliasSDB)->DB_ESTFIS,(cAliasSDB)->DB_LOCALIZ,,,,,,nQtdAbast,STR0035,.T.) //"Reabastecimento gerado para o endereço."
				AAdd(__aReabGer,{(cAliasSDB)->DB_ESTFIS,(cAliasSDB)->DB_LOCALIZ,nQtdAbast})
			EndIf
		Else
			 nGerouReab := nRetPkg
		EndIf
		(cAliasSDB)->(dbSkip())
	EndDo
	(cAliasSDB)->(dbCloseArea())


	//Limpa para não validar novamente na próxima execução
	aValReab := {}
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} D0ZxSF2
Retorna Nota fiscal e série a partir do registro da tabela D0Z, utilizando a tabela de pedido (SC9).
O registro da tabela D0Z precisa estar posicionado. Isso foi feito em vez de passar a chave por parâmetro pelo fato de que
 o campo SX3_INIBRW suporta só 80 caracteres.
 nCampo é usado para efetuar a leitura somente a primeira vez (para o campo número da NF). Para a série, não há
 necessidade de ler novamente visto que a informações já foi carregada na variável __aD0ZSF2.
@author wander.horongoso
@since 14/11/2019
@version 1.0
/*/
//--------------------------------------------------
Static __aD0ZSF2 := {"", ""}
Function D0ZxSF2(nCampo)
Local cAliasSF2 := GetNextAlias()

	If nCampo == 1 //nota fiscal
		BeginSql Alias cAliasSF2
			SELECT SF2.F2_DOC, SF2.F2_SERIE
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SF2% SF2
			ON SF2.F2_FILIAL = %xFilial:SF2%
			AND SF2.F2_DOC = SC9.C9_NFISCAL
			AND SF2.F2_SERIE = SC9.C9_SERIENF
			AND SF2.F2_CLIENTE = SC9.C9_CLIENTE
			AND SF2.F2_LOJA = SC9.C9_LOJA
			AND SF2.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:D0Z->D0Z_PEDIDO%
			AND SC9.C9_ITEM = %Exp:D0Z->D0Z_ITEM%
			AND SC9.C9_SEQUEN = %Exp:D0Z->D0Z_SEQUEN%
			AND SC9.C9_PRODUTO = %Exp:D0Z->D0Z_PRDORI%
			AND SC9.%NotDel%
		EndSql

		If (cAliasSF2)->(!Eof())
			__aD0ZSF2 := {(cAliasSF2)->F2_DOC, (cAliasSF2)->F2_SERIE}
		Else
			__aD0ZSF2 := {"",""}
		EndIf

		(cAliasSF2)->(dbCloseArea())
	EndIf

Return __aD0ZSF2[nCampo]

//----------------------------------------------------------
/*/{Protheus.doc} VldPkUnM
Validar se tem mais de uma estrutura de picking na sequencia de abastecimento.
@author  Roselaine Adriano.
@version P12
@Since   03/02/2020
@version 1.0
/*/
//----------------------------------------------------------
Static Function VldPkUnM(cLocal,cProduto)
Local nQtdPk := 0
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT COUNT(*) AS QtdPk
		FROM %Table:DC3% DC3
		INNER JOIN  %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = DC3.DC3_TPESTR
		AND DC8.DC8_TPESTR = '2'
		AND DC8.%NotDel%
		WHERE DC3.DC3_FILIAL = %xFilial:DC3% 
		AND DC3.DC3_LOCAL = %Exp:cLocal%
		AND DC3.DC3_CODPRO = %Exp:cProduto%
		AND DC3.%NotDel%
	EndSql
	nQtdPk := (cAliasQry)->QtdPk
	(cAliasQry)->(DbCloseArea())
	
Return nQtdPk
//----------------------------------------------------------
/*/{Protheus.doc} AddParRel
Buscar dados dos parâmetros gerais para impressão do relatorio.
@author  Roselaine Adriano.
@version P12
@Since   03/02/2020
@version 1.0
/*/
//----------------------------------------------------------
Static Function AddParRel()
Local lUnicoReab := SuperGetMV("MV_WMSMABP", .F., "N")=="S"
Local lMultPick := SuperGetMV("MV_WMSMULP", .F., "N")=="S"
Local lNovoWMS := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lReinBusca := SuperGetMV("MV_WMSQTAP",.F.,"N") == "S"
Local lLotesVenc := SuperGetMV('MV_LOTVENC', .F., 'N')=='S'
Local nNroPick := SuperGetMV("MV_WMSNRPO", .F., 10)

	Aadd(aLogSld,{lUnicoReab, lMultPick, lNovoWMS, nNroPick, lReinBusca, lLotesVenc})

Return

//----------------------------------------------------------
/*/{Protheus.doc} AddInfProd
Buscar dados do produto para impressão do relatorio.
@author  Roselaine Adriano.
@version P12
@Since   03/02/2020
@version 1.0
/*/
//----------------------------------------------------------
Static Function AddInfProd()
Local cAliasQry := GetNextAlias()
Local cZona:= ""
Local cWmsEmb := ""
Local cUmInd  := ""
Local cCtrlWMS := ""

	BeginSql Alias cAliasQry
		SELECT SB5.B5_CODZON,
				SB5.B5_WMSEMB,
				SB5.B5_UMIND,
				SB5.B5_CTRWMS
		FROM %Table:SB5% SB5
		WHERE SB5.B5_FILIAL = %xFilial:SB5% 
		AND SB5.B5_COD = %Exp:__cProduto%
		AND SB5.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		cZona   := (cAliasQry)->B5_CODZON
		cWmsEmb := (cAliasQry)->B5_WMSEMB
		cUmInd  := (cAliasQry)->B5_UMIND
		cCtrlWMS := (cAliasQry)->B5_CTRWMS
	EndIf
	(cAliasQry)->(!DbCloseArea())
	Aadd(aLogSld[Len(aLogSld),8],{SB1->B1_UM, SB1->B1_SEGUM, SB1->B1_CONV, SB1->B1_TIPCONV, cZona, cWmsEmb,cUmInd,cCtrlWMS,__cLocDest})
Return

