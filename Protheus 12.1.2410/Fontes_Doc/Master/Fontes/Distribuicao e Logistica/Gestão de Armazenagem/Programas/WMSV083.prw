#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSV083.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "FWBROWSE.CH"
#Define CLRF  CHR(13)+CHR(10)
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSV083 - Geração de Pedido Cross-Docking Coletor                  |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a seleção de uma listagem de volumes cross-docking |
|         | para efetuar a geração de um pedido de vendas integrado com o WMS  |
|         | de forma direta a partir dos itens do volume via coletor de dados. |
+---------+--------------------------------------------------------------------+
*/
#DEFINE WMSV08301 "WMSV08301"
#DEFINE WMSV08302 "WMSV08302"
#DEFINE WMSV08303 "WMSV08303"
#DEFINE WMSV08304 "WMSV08304"
#DEFINE WMSV08305 "WMSV08305"
#DEFINE WMSV08306 "WMSV08306"
#DEFINE WMSV08307 "WMSV08307"
#DEFINE WMSV08308 "WMSV08308"
#DEFINE WMSV08309 "WMSV08309"
#DEFINE WMSV08310 "WMSV08310"
#DEFINE WMSV08311 "WMSV08311"
#DEFINE WMSV08312 "WMSV08312"
#DEFINE WMSV08313 "WMSV08313"
#DEFINE WMSV08314 "WMSV08314"
#DEFINE WMSV08315 "WMSV08315"
#DEFINE WMSV08316 "WMSV08316"
#DEFINE WMSV08317 "WMSV08317"
#DEFINE WMSV08318 "WMSV08318"
#DEFINE WMSV08319 "WMSV08319"
#DEFINE WMSV08320 "WMSV08320"
#DEFINE WMSV08321 "WMSV08321"
#DEFINE WMSV08322 "WMSV08322"
#DEFINE WMSV08323 "WMSV08323"
#DEFINE WMSV08324 "WMSV08324"
#DEFINE WMSV08325 "WMSV08325"
#DEFINE WMSV08326 "WMSV08326"
#DEFINE WMSV08327 "WMSV08327"
#DEFINE WMSV08328 "WMSV08328"
#DEFINE WMSV08329 "WMSV08329"
#DEFINE WMSV08330 "WMSV08330"
#DEFINE WMSV08331 "WMSV08331"
#DEFINE WMSV08332 "WMSV08332"
#DEFINE WMSV08333 "WMSV08333"
//----------------------------------------------------------------------------------1
Function WMSV083()
Local cArmazem  := Space(TamSx3("D14_LOCAL")[1])
Local cEndereco := Space(TamSx3("D14_ENDER")[1])
Local cCliente  := Space(TamSx3("C5_CLIENTE")[1])
Local cLoja     := Space(TamSx3("C5_LOJACLI")[1])
	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If GetEndOrig(@cArmazem,@cEndereco)
		If GetCliLoja(cArmazem,cEndereco,@cCliente,@cLoja)
			GetVolumes(cArmazem,cEndereco,cCliente,cLoja)
		EndIf
	EndIf
Return Nil

//----------------------------------------------------------------------------------
Static Function GetEndOrig(cArmazem,cEndereco)
Local lEncerra := .F.
	Do While !lEncerra
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Gera Pedido Cross
		@ 01,00 VTSay PadR(STR0002+":",VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmazem Pict "@!" Valid VldArmazem(cArmazem)
		@ 03,00 VTSay PadR(STR0003+":",VTMaxCol()) // Endereço
		@ 04,00 VTGet cEndereco Pict "@!" Valid VldEndOrig(cArmazem,cEndereco)
		VtRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			lEncerra := WmsQuestion(STR0004,STR0001) // Confirma a saída?
			Loop
		EndIf
		Exit
	EndDo
Return !lEncerra

//----------------------------------------------------------------------------------
Static Function VldArmazem(cArmazem)
Local lRet := .T.
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV08301,STR0005) // Armazem inválido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------------------------------------------------
Static Function VldEndOrig(cArmazem,cEndereco)
Local lRet := .T.
Local cEstFis := ""
Local cTipEst := ""
	If Empty(cEndereco)
		Return .F.
	EndIf
	If Empty(cEstFis := Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndereco,"BE_ESTFIS")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		WMSVTAviso(WMSV08302,STR0006) // Endereço inválido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Deve validar se o endereço é do tipo cross-docking
	If (lRet .And. ( cTipEst := Posicione("DC8",1,xFilial("DC8")+cEstFis,"DC8_TPESTR") ) != '3') //DC8_FILIAL+DC8_CODEST
		WMSVTAviso(WMSV08303,STR0007) // Endereço não é o do tipo crossdocking.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Deve existir pelo menos um volume apto a faturar no endereço
	If lRet
		D0N->(DbSetOrder(2)) // D0N_FILIAL+D0N_LOCAL+D0N_ENDER+D0N_CODVOL
		If D0N->(!DbSeek(xFilial("D0N")+cArmazem+cEndereco))
			WMSVTAviso(WMSV08309,STR0009) // No endereço informado não existe nenhum volume montado para gerar pedido.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------------------------------
Static Function GetVolumes(cArmazem,cEndereco,cCliente,cLoja)
Local cKey06   := VtDescKey(06)
Local cKey22   := VtDescKey(22)
Local cKey24   := VtDescKey(24)
Local bkey06   := VTSetKey(06) // Ctrl+F
Local bkey22   := VTSetKey(22) // Ctrl+V
Local bkey24   := VTSetKey(24) // Ctrl+X
Local aTela    := VTSave()
Local lRet     := .T.
Local lSair    := .F.
Local cVolume  := ""
Local aVolumes := {}

	VTSetKey(06,{|| GerPedVol(cArmazem,cEndereco,cCliente,cLoja,@aVolumes)}, STR0046) // Ctrl+F // Gerar Pedido
	VTSetKey(22,{|| ShowLstVol(aVolumes)}, STR0014) // Ctrl+F // Lista Volumes
	VTSetKey(24,{|| EstVolume(cArmazem,cEndereco,aVolumes)}, STR0018) // Ctrl-X // Estorno Vol. Lista
	While !lSair
		// Inicializa variaveis
		cVolume := Space(TamSx3("D0O_CODVOL")[1])
		VtClear()
		WMSVTCabec(STR0001, .F., .F., .T.) // Gera Pedido Cross
		@ 01,00 VTSay STR0002+'/'+STR0003 // Armazém/Endereço
		@ 02,00 VTSay cArmazem+'/'+cEndereco
		@ 03,00 VtSay STR0008 // Informe o Volume
		@ 04,00 VtGet cVolume Picture '@!' Valid VldCodVol(cArmazem,cEndereco,cVolume,aVolumes)
		VtRead()
		If VtLastkey() == 27
			lSair := WmsQuestion(STR0004,STR0001) //"Confirma a saída?"
			Loop
		EndIf
		AAdd(aVolumes,cVolume)
	EndDo
	// Restaura teclas
	VTSetKey(06,bkey06,cKey06)
	VTSetKey(22,bkey22,cKey22)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil

//----------------------------------------------------------------------------------
Static Function VldCodVol(cArmazem,cEndereco,cVolume,aVolumes)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Local nPos      := 0
	If Empty(cVolume)
		Return .F.
	EndIf
	If (nPos := AScan(aVolumes,{|x| x == cVolume})) > 0
		WMSVTAviso(WMSV08307, STR0016)  // O volume informado já se encontra na listagem.
		VTKeyBoard(Chr(20))
		Return .F.
	EndIf
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:DCU% DCU
		WHERE DCU.DCU_FILIAL = %xFilial:DCU%
		AND DCU.DCU_CODVOL = %Exp:cVolume%
		AND DCU.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		WMSVTAviso(WMSV08304, STR0011) // O volume informado pertence a uma montagem de volume de expedição.
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	If lRet
		cArmazem  := PadR(cArmazem, TamSx3("D14_LOCAL")[1])
		cEndereco := PadR(cEndereco,TamSx3("D14_ENDER")[1])
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0N.D0N_LOCAL,
					D0N.D0N_ENDER,
					D0N.R_E_C_N_O_ RECNOD0N
			FROM %Table:D0N% D0N
			WHERE D0N.D0N_FILIAL = %xFilial:D0N%
			AND D0N.D0N_CODVOL = %Exp:cVolume%
			AND D0N.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			If (cAliasQry)->(D0N_LOCAL+D0N_ENDER) != cArmazem+cEndereco
				WMSVTAviso(WMSV08305, STR0012) // O volume informado está sendo usado em outro armazém/endereço.
				lRet := .F.
			EndIf
		Else
			WMSVTAviso(WMSV08306, STR0013) // Volume informado inválido.
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function ShowLstVol(aVolumes)
Local cKey06   := VtDescKey(06)
Local bKey06   := VTSetKey(06)
Local cKey22   := VTDescKey(22)
Local bKey22   := VTSetKey(22)
Local cKey24   := VTDescKey(24)
Local bKey24   := VTSetKey(24)
Local aTela    := VTSave()
Local nLin     := 1
	// Se a lista está vazia não mostra a mesma
	If Empty(aVolumes)
		WMSVTAviso(WMSV08308, STR0017) // Não existem volume informados na listagem.
	Else
		VTClear()
		While nLin > 0
			WMSVTCabec(STR0014,.F.,.F.,.T.) // "Lista Volumes"
			nLin := VtAchoice(1,0,VtMaxRow(),VtMaxCol(),aVolumes,,,nLin)
			If nLin > 0
				WMSV083ITV(aVolumes[nLin])
			EndIf
		EndDo
	EndIf
	// Restaura teclas
	VTSetKey(06,bKey06,cKey06)
	VTSetKey(22,bKey22,cKey22)
	VTSetKey(24,bKey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
//-----------------------------------------------------------------------------
Function WMSV083ITV(cVolume)
Local aAreaAnt := GetArea()
Local aTela    := VTSave()
Local aTamSX3  := TamSx3('D0O_QUANT')
Local aCab     := {}
Local aSize    := {}
Local aPrdVol  := {}
Local cAliasQry:= Nil

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0O.D0O_CODPRO,
				D0O.D0O_LOTECT,
				D0O.D0O_NUMLOT,
				D0O.D0O_PRDORI,
				D0O.D0O_QUANT
		FROM %Table:D0O% D0O
		WHERE D0O.D0O_FILIAL = %xFilial:D0O%
		AND D0O.D0O_CODVOL = %Exp:cVolume%
		AND D0O.%NotDel%
		ORDER BY D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0O_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		AAdd(aPrdVol,{(cAliasQry)->D0O_CODPRO,(cAliasQry)->D0O_LOTECT,(cAliasQry)->D0O_NUMLOT,(cAliasQry)->D0O_QUANT,(cAliasQry)->D0O_PRDORI})
		(cAliasQry)->(!DbSkip())
	EndDo
	(cAliasQry)->(!DbCloseArea())

	VTClear()
	aCab  := {RetTitle("D0O_CODPRO"),RetTitle("D0O_LOTECT"),RetTitle("D0O_NUMLOT"),RetTitle("D0O_QUANT"),RetTitle("D0O_PRDORI")}
	aSize := {TamSx3("D0O_CODPRO")[1],TamSx3("D0O_LOTECT")[1],TamSx3("D0O_NUMLOT")[1],TamSx3("D0O_QUANT")[1],TamSx3("D0O_PRDORI")[1]}
	WMSVTCabec(STR0010,.F.,.F.,.T.) // "Itens Volume"
	VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aPrdVol,aSize)
	VtRestore(,,,,aTela)
	RestArea(aAreaAnt)
Return Nil
//----------------------------------------------------------------------------------
Static Function EstVolume(cArmazem,cEndereco,aVolumes)
Local cKey06   := VTDescKey(06)
Local cKey22   := VTDescKey(22)
Local cKey24   := VTDescKey(24)
Local bKey06   := VTSetKey(06)
Local bKey22   := VTSetKey(22)
Local bKey24   := VTSetKey(24)
Local aTela    := VTSave()
Local cVolume  := ""
Local nPos     := 0
Local lRet     := .T.

	If Empty(aVolumes)
		WMSVTAviso(WMSV08311, STR0017) // Não existem volume informados na listagem.
	Else
		Do While .T.
			VTCLear()
			cVolume  := Space(TamSx3("D0O_CODVOL")[1])
			WMSVTCabec(STR0018, .F., .F., .T.) // Estorno Vol. Lista
			@ 01,00 VTSay STR0002+'/'+STR0003 // Armazém/Endereço
			@ 02,00 VTSay cArmazem+'/'+cEndereco
			@ 03,00 VtSay STR0008 // Informe o Volume
			@ 04,00 VtGet cVolume Picture '@!' Valid VldEstVol(cVolume,aVolumes,@nPos)
			VtRead()
			If VtLastKey() == 27
				Exit
			EndIf
			If nPos > 0
				ADel(aVolumes,nPos)
				ASize(aVolumes,Len(aVolumes)-1)
			EndIf
			// Se estornou todos os volumes sai
			If Len(aVolumes) == 0
				WMSVTAviso(WMSV08311, STR0017) // Não existem volume informados na listagem.
				Exit
			EndIf
		EndDo
		VTClearBuffer()
	EndIf
	VtRestore(,,,,aTela)
	VTSetKey(06, bKey06, cKey06)
	VTSetKey(22, bKey22, cKey22)
	VTSetKey(24, bKey24, cKey24)
Return
//----------------------------------------------------------------------------------
Static Function VldEstVol(cVolume,aVolumes,nPos)

	If Empty(cVolume)
		Return .F.
	EndIf
	If (nPos := AScan(aVolumes,{|x| x == cVolume})) <= 0
		WMSVTAviso(WMSV08310, STR0019)  // O volume informado não se encontra na listagem.
		VTKeyBoard(Chr(20))
		Return .F.
	EndIf
Return .T.
//-----------------------------------------------------------------------------
Static Function GerPedVol(cArmazem,cEndereco,cCliente,cLoja,aVolumes)
Local lRet  := .T.
	If Empty(aVolumes)
		Return .F.
	EndIf
	If !WmsQuestion(STR0045,STR0001) // Confirma geração do pedido de venda a partir da seleção de volumes?
		lRet := .F.
	EndIf
	If lRet
		lRet := WMSV083PED(cArmazem,cEndereco,aVolumes,cCliente,cLoja)
	EndIf
	// Se deu certo a geração do pedido de venda limpa os volumes
	If lRet
		aVolumes := {}
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Function WMSV083PED(cArmazem,cEndereco,aVolumes,cCliente,cLoja,cServico,cEndDest)
Local lRet  := .T.
Local aTela := Nil
Local aProdutos := {}
Local aIdDCF    := {}
Local cPedido   := ""
Local cMensagem := ""
Local cTipOpPed := SuperGetMV('MV_WMSTPOP',.F.,"")
Local cTesCross := SuperGetMV('MV_WMSTMCR',.F.,"")

Default cServico  := CriaVar('DCF_SERVIC',.F.)
Default cEndDest  := CriaVar('BE_LOCALIZ',.F.)
Default cCliente  := CriaVar('C5_CLIENTE',.F.)
Default cLoja     := CriaVar('C5_LOJACLI',.F.)

	If IsTelNet()
		aTela := VTSave()
		VTMsg(STR0020) // Processando...
	Else
		ProcRegua(3)
		IncProc(STR0020)
	EndIf
	WmsMessage("",WMSV08314,0,.F.) // Limpa qualquer mensagem anterior
	If Empty(cTipOpPed) .And. Empty(cTesCross)
		WmsMessage(STR0041,WMSV08315,1) // O valor dos parâmetros MV_WMSTPOP (Tipo Operação Pedido Cross-Docking) ou MV_WMSTMCR (TES Pedido Cross-Docking) devem ser preenchidos.
		lRet := .F.
	EndIf
	// Deve carregar todos os itens de todos os volumes
	// No caso de produto partes vai carregar o máximo que pode ser montado
	// Porém, não será possível liberar um ou mais volumes para um pedido
	// Caso a combinação de todos os filhos não atinja o máximo de itens pai
	If lRet
		lRet := VldPrdCmp(aVolumes,aProdutos)
	EndIf
	If lRet
		lRet := LoadPrdNor(aVolumes,aProdutos)
	EndIf
	If lRet
		lRet := VldPrdCusM(aProdutos,cArmazem)
	EndIf
	If lRet .And. (Empty(cCliente) .Or. Empty(cLoja))
		lRet := GetCliLoja(cArmazem,cEndereco,@cCliente,@cLoja)
	EndIf
	If lRet .And. (Empty(cServico) .Or. Empty(cEndDest))
		lRet := GetSerDest(aProdutos[1][1],cArmazem,@cServico,@cEndDest)
	EndIf
	If lRet
		If IsTelNet()
			VTMsg(STR0021) // Gerando Pedido...
		Else
			IncProc(STR0021)
		EndIf

		// Cria tabela temporária
		WMSCTPRGCV()
		Begin Transaction
			If lRet
				lRet := RetBlqSld(cArmazem,cEndereco,aVolumes)
			EndIf
			If lRet
				lRet := GeraPedido(@cPedido,cCliente,cLoja,cTipOpPed,cTesCross,cArmazem,cEndereco,cServico,cEndDest,aProdutos)
			EndIf
			If lRet
				lRet := LiberaPed(cPedido,cCliente,cLoja)
			EndIf
			If IsTelNet()
				VTMsg(STR0022) // Executando WMS...
			Else
				IncProc(STR0022)
			EndIf
			If lRet
				lRet := ExeSrvWMS(cPedido,cCliente,cLoja,aIdDCF)
			EndIf
			If lRet
				lRet := ExeMovWMS(cPedido,cCliente,cLoja,cServico,aIdDCF)
			EndIf
			If lRet
				lRet := TransfVol(cPedido,cArmazem,cEndereco,aVolumes)
			EndIf
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction
	EndIf
	If lRet
		cMensagem := STR0023 // Gerado o pedido de venda:
		If IsTelNet()
			cMensagem += CRLF + "-------------------"
		EndIf
		cMensagem += CRLF + AllTrim(RetTitle('C9_PEDIDO')) + ":" + cPedido
		cMensagem += CRLF + AllTrim(RetTitle('C9_CLIENTE'))+ ":" + Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NREDUZ")
		If IsTelNet()
			cMensagem += CRLF + "-------------------"
		EndIf
		WmsMessage(cMensagem)
	Else
		If IsTelNet() 
			WmsMessage(STR0039,WMSV08316,1) // "Ocorrem problemas na tentativa de gerar o pedido de venda."
		Else
			cMensagem := STR0039
			If !Empty(WmsLastMsg())
				cMensagem += CRLF + WmsLastMsg()
			EndIf
			WmsMessage(cMensagem,WMSV08317,1)
		EndIf
	EndIf
	If IsTelNet()
		VtRestore(,,,,aTela)
	EndIf
	WMSDTPRGCV()
Return lRet

//-----------------------------------------------------------------------------
#define POS_CMP 5
Static Function VldPrdCmp(aVolumes,aProdutos)
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aComponentes := {}
Local aCab     := {}
Local aSize    := {}
Local aTamSX3  := TamSx3('D0O_QUANT')
Local aCmpPend := {}
Local oDlg, oBrw, oCol, oBtn
Local cPrdOri  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local cVolumes := ""
Local cAliasQry:= Nil
Local cPicture := ""
Local nQtdPrd  := 0
Local nQtdVol  := 0
Local nPos1    := 0
Local nPos2    := 0

	AEval(aVolumes, {|x| cVolumes += "'"+x+"',"})
	cVolumes := SubStr(cVolumes,1,Len(cVolumes)-1)
	cVolumes := "%"+cVolumes+"%"
	// Pega todos os produtos pai colocando os filhos abaixo deles
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0O.D0O_CODPRO,
				D0O.D0O_LOTECT,
				D0O.D0O_NUMLOT,
				D0O.D0O_PRDORI,
				SUM(D0O.D0O_QUANT) D0O_QUANT
		FROM %Table:D0O% D0O
		WHERE D0O.D0O_FILIAL = %xFilial:D0O%
		AND D0O.D0O_CODPRO <> D0O.D0O_PRDORI
		AND D0O.%NotDel%
		AND D0O.D0O_CODVOL IN ( %Exp:cVolumes% )
		GROUP BY D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
		ORDER BY D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0O_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		If (nPos1 := aScan(aComponentes,{|x| x[1]+x[2]+x[3] == (cAliasQry)->(D0O_PRDORI+D0O_LOTECT+D0O_NUMLOT)})) == 0
			AAdd(aComponentes,{(cAliasQry)->D0O_PRDORI,;    // Produto Origem
								(cAliasQry)->D0O_LOTECT,;   // Lote
								(cAliasQry)->D0O_NUMLOT,;   // Sub-Lote
								0,;                         // Quantidade (Será calculada)
								{{(cAliasQry)->D0O_CODPRO,; // Produto Componente
								(cAliasQry)->D0O_QUANT}}})  // Quantidade volume
		Else
			If (nPos2 := aScan(aComponentes[nPos1][POS_CMP],{|x| x[1] == (cAliasQry)->D0O_CODPRO})) == 0
				AAdd(aComponentes[nPos1][POS_CMP],{(cAliasQry)->D0O_CODPRO,; // Produto Componente
													(cAliasQry)->D0O_QUANT}) // Quantidade volume

			Else
				aComponentes[nPos1][POS_CMP][nPos2][2] += (cAliasQry)->D0O_QUANT
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())

	If Len(aComponentes) > 0  //-- calcula a quantidade de itens completos quando possui componentes
		D11->(dbSetOrder(3))
		For nPos1 := 1 to Len(aComponentes)
			cPrdOri  := aComponentes[nPos1][1]
			cLoteCtl := aComponentes[nPos1][2]
			cSubLote := aComponentes[nPos1][3]
			nQtdPrd := 0
			// Varre todos os componentes pegando a maior quantidade para o produto pai
			For nPos2 := 1 To Len(aComponentes[nPos1][POS_CMP])
				cProduto := aComponentes[nPos1][POS_CMP][nPos2][1]
				nQtdVol  := aComponentes[nPos1][POS_CMP][nPos2][2]
				If D11->(dbSeek(xFilial("D11")+cPrdOri+cProduto))
					If QtdComp(nQtdPrd) < QtdComp(nQtdVol/D11->D11_QTMULT)
						nQtdPrd := nQtdVol/D11->D11_QTMULT
					EndIf
				EndIf
			Next nPos2
			aComponentes[nPos1][4] := nQtdPrd
			D11->(dbSeek(xFilial("D11")+cPrdOri))
			While D11->(!Eof()) .And. D11->(D11_FILIAL+D11_PRODUT) == xFilial("D11")+cPrdOri
				If (nPos2:= aScan(aComponentes[nPos1][POS_CMP],{|x| x[1] == D11->D11_PRDCMP})) == 0
					AAdd(aCmpPend,{D11->D11_PRDCMP,cLoteCtl,cSubLote,(nQtdPrd * D11->D11_QTMULT),cPrdOri})
				Else
					cProduto := aComponentes[nPos1][POS_CMP][nPos2][1]
					nQtdVol  := aComponentes[nPos1][POS_CMP][nPos2][2]
					If QtdComp(nQtdPrd) > QtdComp(nQtdVol/D11->D11_QTMULT)
						AAdd(aCmpPend,{cProduto,cLoteCtl,cSubLote,((nQtdPrd-(nQtdVol/D11->D11_QTMULT)) * D11->D11_QTMULT),cPrdOri})
					EndIf
				EndIf
				D11->(dbSkip())
			EndDo
		Next nPos1
	EndIf

	If Len(aCmpPend) > 0
		aCab  := {RetTitle("D0O_CODPRO"),RetTitle("D0O_LOTECT"),RetTitle("D0O_NUMLOT"),RetTitle("D0O_QUANT"),RetTitle("D0O_PRDORI")}
		ASize := {TamSx3("D0O_CODPRO")[1],TamSx3("D0O_LOTECT")[1],TamSx3("D0O_NUMLOT")[1],TamSx3("D0O_QUANT")[1],TamSx3("D0O_PRDORI")[1]}
		If IsTelNet()
			WMSVTAviso(STR0024,(STR0025+" "+STR0015)) // Existem componentes faltantes para completar um produto na seleção de volumes. Adicione estes produtos a volumes na seleção.
			lRet := .F.
			WMSVTCabec(STR0024,.F.,.F.,.T.) // Produtos Pendentes
			VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aCmpPend,aSize)
			VTKeyBoard(Chr(20))
		Else
			WmsMessage(STR0025,WMSV08318,5,.T.,,STR0015) // Existem componentes faltantes para completar um produto na seleção de volumes.##Adicione estes produtos a volumes na seleção.")
			lRet := .F.
			cPicture := "@E "+Replicate("9",aTamSX3[1]); cPicture += "."+Replicate("9",aTamSX3[2])
			DEFINE MSDIALOG oDlg TITLE STR0024 FROM 00,00 TO 350,650 PIXEL
			DEFINE FWFORMBROWSE oBrw DATA ARRAY ALIAS "ARRAY" ARRAY aCmpPend NO SEEK NO CONFIG NO REPORT OF oDlg
			ADD COLUMN oCol DATA {|| aCmpPend[oBrw:nAT,1]} TITLE aCab[1] TYPE "C" SIZE ASize[1] OF oBrw
			ADD COLUMN oCol DATA {|| aCmpPend[oBrw:nAT,2]} TITLE aCab[2] TYPE "C" SIZE ASize[2] OF oBrw
			ADD COLUMN oCol DATA {|| aCmpPend[oBrw:nAT,3]} TITLE aCab[3] TYPE "C" SIZE ASize[3] OF oBrw
			ADD COLUMN oCol DATA {|| aCmpPend[oBrw:nAT,4]} TITLE aCab[4] TYPE "C" SIZE aTamSX3[1] DECIMAL aTamSX3[2] PICTURE cPicture ALIGN COLUMN_ALIGN_RIGHT OF oBrw
			ADD COLUMN oCol DATA {|| aCmpPend[oBrw:nAT,5]} TITLE aCab[5] TYPE "C" SIZE ASize[5] OF oBrw
			ACTIVATE FWFORMBROWSE oBrw
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,,,,,,.F.,.F.)
		EndIf
	Else
		For nPos1 := 1 To Len(aComponentes)
			AAdd(aProdutos,{aComponentes[nPos1][1],aComponentes[nPos1][2],aComponentes[nPos1][3],aComponentes[nPos1][4]})
		Next
	EndIf

	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
Static Function LoadPrdNor(aVolumes,aProdutos)
Local lRet     := .T.
Local aTamSX3  := TamSx3('D0O_QUANT')
Local aAreaAnt := GetArea()
Local cVolumes := ""
Local cAliasQry:= Nil

	AEval(aVolumes, {|x| cVolumes += "'"+x+"',"})
	cVolumes := SubStr(cVolumes,1,Len(cVolumes)-1)
	cVolumes := "%"+cVolumes+"%"
	// Pega todos os produtos pai colocando os filhos abaixo deles
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0O.D0O_CODPRO,
				D0O.D0O_LOTECT,
				D0O.D0O_NUMLOT,
				SUM(D0O.D0O_QUANT) D0O_QUANT
		FROM %Table:D0O% D0O
		WHERE D0O.D0O_FILIAL = %xFilial:D0O%
		AND D0O.D0O_CODPRO = D0O.D0O_PRDORI
		AND D0O.D0O_CODVOL IN ( %Exp:cVolumes% )
		AND D0O.%NotDel%
		GROUP BY D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
		ORDER BY D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0O_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		AAdd(aProdutos,{(cAliasQry)->D0O_CODPRO,(cAliasQry)->D0O_LOTECT,(cAliasQry)->D0O_NUMLOT,(cAliasQry)->D0O_QUANT})
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
Static Function VldPrdCusM(aProdutos,cArmazem)
Local lRet := .T.
Local nX   := 0

	SB2->(DbSetOrder(1))
	For nX := 1 To Len(aProdutos)
		If SB2->(DbSeek(xFilial("SB2")+aProdutos[nX,1]+cArmazem))
			If QtdComp(SB2->B2_CM1) > 0
				AAdd(aProdutos[nX],SB2->B2_CM1)
			Else
				WmsMessage(WmsFmtMsg(STR0044,{{"[VAR02]",aProdutos[nX,1]}}),WMSV08319,1) // O valor do custo médio unitário para o produto [VAR02] está zerado. (SB2)
				lRet := .F.
			EndIf
		Else
			WmsMessage(WmsFmtMsg(STR0043,{{"[VAR01]",aProdutos[nX,1]}}),WMSV08320,1) // Produto [VAR01] não possui registro de saldo no armazém. (SB2)
			lRet := .F.
		EndIf
		If !lRet
			Exit
		EndIf
	Next
Return lRet
//-----------------------------------------------------------------------------
Static Function GetCliLoja(cArmazem,cEndereco,cCliWMS,cLojaWMS)
Local lRet     := .T.
Local lCancel  := .F.
Local cCliente := cCliWMS
Local cLoja    := cLojaWMS
Local cTitCli  := AllTrim(RetTitle('C5_CLIENTE'))
Local cTitLoja := AllTrim(RetTitle('C5_LOJACLI'))
Local oDlg, oBtn, aTela
	// Pega os dados do cadastro de cliente x endereço
	D10->(DbSetOrder(2)) // D10_FILIAL+D10_LOCAL+D10_ENDER
	D10->(DbSeek(xFilial("D10")+cArmazem+cEndereco))
	cCliente := D10->D10_CLIENT // Código do Cliente do Endereço
	cLoja    := D10->D10_LOJA   // Loja do Cliente do Endereço
	If IsTelNet()
		aTela := VtSave()
		While .T.
			VTClear()
			WMSVTCabec('SIGAWMS', .F., .F., .T.)
			@ 01,00 VTSay AllTrim(RetTitle('BE_LOCAL'))+'/'+ AllTrim(RetTitle('BE_LOCALIZ'))
			@ 02,00 VTSay cArmazem+'/'+cEndereco
			@ 03,00 VTSay STR0026 // Informe Cliente/Loja
			@ 04,00 VTSay cTitCli+':'
			@ 04,Len(cTitCli)+2 VtGet cCliente Pict "@!" Valid VldCliWMS(cCliente,@cLoja)
			@ 05,00 VTSay cTitLoja+':'
			@ 05,Len(cTitLoja)+2 VtGet cLoja Pict "@!" Valid VldCliWMS(cCliente,@cLoja)
			VtRead()
			If VTLastKey() == 27
				If WmsQuestion(STR0027) // Confirma o cancelamento do processo?
					lCancel := .T.
					Exit
				Else
					Loop
				EndIf
			Else
				If !VldCliWMS(cCliente,cLoja)
					Loop
				Else
					Exit
				EndIf
			EndIf
		EndDo
		VtRestore(,,,,aTela)
	Else
		lCancel := .F.
		DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 183, 295 TITLE 'SIGAWMS' PIXEL
		@ 10, 10 SAY   AllTrim(RetTitle('BE_LOCAL'))+':' OF oDlg PIXEL
		@ 10, 50 MSGET cArmazem WHEN .F. OF oDlg PICTURE '@!' PIXEL
		@ 28, 10 SAY   AllTrim(RetTitle('BE_LOCALIZ'))+':' OF oDlg PIXEL
		@ 28, 50 MSGET cEndereco WHEN .F. OF oDlg PICTURE '@!' PIXEL
		@ 46, 10 SAY   cTitCli+':' OF oDlg PIXEL
		@ 46, 50 MSGET cCliente VALID VldCliWMS(cCliente,@cLoja) F3 'SA1' OF oDlg PICTURE '@!' PIXEL
		@ 64, 10 SAY   cTitLoja+':' OF oDlg PIXEL
		@ 64, 50 MSGET cLoja VALID VldCliWMS(cCliente,cLoja) OF oDlg PICTURE '@!' PIXEL

		@ 080,100 BUTTON oBtn PROMPT STR0028 SIZE 040,012 OF oDlg PIXEL; // Cancelar
		ACTION (oDlg:End(),lCancel:=.T.)
		@ 080,058 BUTTON oBtn PROMPT STR0029 SIZE 040,012 OF oDlg PIXEL; // Confirmar
		ACTION (Iif(VldCliWMS(cCliente,cLoja),(oDlg:End()),/*Não faz nada*/))

		oDlg:lEscClose := .F.
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	If lCancel
		lRet := .F.
	Else
		cCliWMS  := cCliente
		cLojaWMS := cLoja
	EndIf
Return lRet
//-----------------------------------------------------------------------------
Static Function VldCliWMS(cCliente,cLoja)
Local lRet     := .T.

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCliente+Iif(Empty(cLoja),"",cLoja)))
		If Empty(cLoja)
			cLoja := SA1->A1_LOJA
		Else
			If SA1->A1_MSBLQL == "1"
				WmsMessage(STR0040,WMSV08321,1) // Cliente/Loja não está ativo (SA1).
				lRet := .F.
			EndIf
			If lRet .And. Empty(SA1->A1_COND)
				WmsMessage(STR0031,WMSV08322,1) // Condição de pagamento não informada para o Cliente/Loja (SA1).
				lRet := .F.
			EndIf
		EndIf
	Else
		WmsMessage(STR0030,WMSV08323,1) // Cliente/Loja não cadastrado (SA1).
		lRet := .F.
	EndIf

	If !lRet .And. IsTelNet()
		VTKeyBoard(Chr(20))
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function GetSerDest(cProduto,cArmazem,cServico,cEndereco)
Local lRet     := .T.
Local oServico := WMSDTCServicoTarefa():New()
	// Pega os dados do primeiro produto
	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+cProduto))
	cServico  := SB5->B5_SERSCD // Serviço de Cross-Docking de Saída
	cEndereco := SB5->B5_ENDSCD // Endereço de Cross-Docking de Saída
	Do While .T.
		If (lRet := DLPergWMS(@cServico,@cEndereco, .T. /*lSuggest*/, .F. /*lForce*/, "2",cArmazem))
			oServico:SetServico(cServico)
			oServico:ServTarefa()
			If !Empty(oServico:GetArrTar())
				oServico:SetOrdem(oServico:GetArrTar()[1][1])
			EndIf
			If oServico:LoadData()
				// Valida se o serviço possui tarefa de separação na primeira sequência - obrigatório ter
				If !oServico:ChkSpCross()
					WmsMessage(STR0032,WMSV08324,1) // O serviço informado deve possuir a função de separação cross-docking na primeira tarefa.
					lRet := .F.
				EndIf
				// Valida se o serviço possui conferência de saída via convocação - não pode ter
				If lRet .And. oServico:HasOperac({'7'})
					WmsMessage(STR0033,WMSV08325,1) // O serviço informado não pode possuir tarefa de conferência de saída.
					lRet := .F.
				EndIf
				// Valida se o serviço possui distribuição de separação - não pode ter
				If lRet .And. oServico:ChkDisSep()
					WmsMessage(STR0034,WMSV08326,1) // O serviço informado não pode possuir distribuição de separação.
					lRet := .F.
				EndIf
				// Valida se o serviço possui montagem de volumes - obrigatório ter
				If lRet .And. !oServico:ChkMntVol()
					WmsMessage(STR0035,WMSV08327,1) // O serviço informado deve possuir montagem de volumes.
					lRet := .F.
				EndIf
				// O serviço não pode ser execução automática, pois será executado pela rotina atual
				If lRet .And. oServico:GetTpExec() == "2"
					WmsMessage(STR0036,WMSV08328,1) // O serviço informado não deve ser execução automática na integração. O mesmo será executado pela rotina atual.
					lRet := .F.
				EndIf
			Else
				WmsMessage(oServico:GetErro(),WMSV08329,1)
				lRet := .F.
			EndIf

			If !lRet
				Loop
			EndIf
		EndIf
		Exit
	EndDo

Return lRet

//-----------------------------------------------------------------------------
Static Function RetBlqSld(cArmazem,cEndereco,aVolumes)
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aTamSX3  := TamSx3('D0O_QUANT')
Local oEstEnder:= WMSDTCEstoqueEndereco():New()
Local cVolumes := ""
Local cAliasQry:= Nil

	AEval(aVolumes, {|x| cVolumes += "'"+x+"',"})
	cVolumes := SubStr(cVolumes,1,Len(cVolumes)-1)
	cVolumes := "%"+cVolumes+"%"
	// Pega todos os produtos, pois no estoque WMS os filhos são gravados separados
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0O.D0O_PRDORI,
				D0O.D0O_CODPRO,
				D0O.D0O_LOTECT,
				D0O.D0O_NUMLOT,
				SUM(D0O.D0O_QUANT) D0O_QUANT
		FROM %Table:D0O% D0O
		WHERE D0O.D0O_FILIAL = %xFilial:D0O%
		AND D0O.D0O_CODVOL IN ( %Exp:cVolumes% )
		AND D0O.%NotDel%
		GROUP BY D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
		ORDER BY D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0O_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		// Carrega dados para LoadData EstEnder
		oEstEnder:ClearData()
		oEstEnder:oEndereco:SetArmazem(cArmazem)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cArmazem) // Armazem
		oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0O_PRDORI)   // Produto Origem - Componente
		oEstEnder:oProdLote:SetProduto((cAliasQry)->D0O_CODPRO) // Produto Principal
		oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0O_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0O_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:SetQuant((cAliasQry)->D0O_QUANT)
		If !(lRet := oEstEnder:UpdSaldo('999',.F.,.F.,.F.,.F.,.T.)) // cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev
			WmsMessage(oEstEnder:GetErro(),WMSV08330,1)
		EndIf
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
Static Function GeraPedido(cPedido,cCliente,cLoja,cTipOpPed,cTesCross,cArmazem,cEndOrig,cServico,cEndDest,aProdutos)
Local aAreaAnt := GetArea()
Local aRetPe   := {}
Local lRet     := .T.
Local nPos     := 0

Local aCabec   := {}
Local aItens   := {}
Local aLinha   := {}
Local nX       := 0
Local cItem    := StrZero(nX,TamSx3("C6_ITEM")[1])
Local nQtdVen  := 0
Local nPrcVen  := 0
Local cTesInt  := ""

Private lMsErroAuto := .F.

	cPedido := " "
	aCabec := {}
	aItens := {}
	SA1->(dbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
	aAdd(aCabec,{"C5_TIPO"   ,"N" ,Nil})
	aAdd(aCabec,{"C5_CLIENTE",SA1->A1_COD ,Nil})
	aAdd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
	aAdd(aCabec,{"C5_TIPOCLI",SA1->A1_TIPO,Nil})
	aAdd(aCabec,{"C5_CLIENT" ,SA1->A1_COD ,Nil})
	aAdd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
	aAdd(aCabec,{"C5_CONDPAG",SA1->A1_COND,Nil})
	aAdd(aCabec,{"C5_TPCARGA","2",Nil})
	AAdd(aCabec,{"C5_GERAWMS","1",Nil})

	For nX := 1 To Len(aProdutos)
		aLinha := {}
		If !Empty(cTipOpPed)
			cTesInt := MaTesInt(2,cTipOpPed,cCliente,cLoja,"C",aProdutos[nX][1])
		EndIf
		nQtdVen := A410Arred(aProdutos[nX][4],"C6_QTDVEN")
		nPrcVen := A410Arred(aProdutos[nX][5],"C6_PRCVEN")
		cItem := Soma1(cItem)
		aAdd(aLinha,{"C6_ITEM"   ,cItem,Nil})
		aAdd(aLinha,{"C6_PRODUTO",aProdutos[nX][1],Nil})
		If Rastro(aProdutos[nX][1])
			aAdd(aLinha,{"C6_LOTECTL",aProdutos[nX][2],Nil})
			aAdd(aLinha,{"C6_NUMLOTE",aProdutos[nX][3],Nil})
		EndIf
		aAdd(aLinha,{"C6_QTDVEN" ,nQtdVen,Nil})
		aAdd(aLinha,{"C6_PRCVEN" ,nPrcVen,Nil})
		AAdd(aLinha,{"C6_VALOR"  ,A410Arred((nQtdVen*nPrcVen),"C6_VALOR"),Nil})
		aAdd(aLinha,{"C6_TES"    ,Iif(!Empty(cTesInt),cTesInt,cTesCross),Nil})
		aAdd(aLinha,{"C6_SERVIC" ,cServico,Nil})
		aAdd(aLinha,{"C6_ENDPAD" ,cEndDest,Nil})
		aAdd(aLinha,{"C6_LOCAL"  ,cArmazem,Nil})
		aAdd(aLinha,{"C6_LOCALIZ",cEndOrig,Nil})

		aAdd(aItens,aLinha)
	Next nX
	If lRet
		If ExistBlock("WMV83PED")
			aRetPe := ExecBlock("WMV83PED",.F.,.F.,{aCabec,aItens})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
				If ValType(aRetPe[1]) == "A"
					aCabec := aClone(aRetPe[1])
				EndIf
				If ValType(aRetPe[2]) == "A"
					aItens := aClone(aRetPe[2])
				EndIf
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Teste de Inclusao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabec,aItens,3) //Inclusão
	If lMsErroAuto
		// Erro na criação do pedido pelo MsExecAuto
		If !IsTelNet()
			MostraErro()
		Else
			VTDispFile(NomeAutoLog(),.T.)
		EndIf
		lRet := .F.
	EndIf
	If lRet
		cPedido := SC6->C6_NUM
	EndIf

	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
Static Function LiberaPed(cPedido,cCliente,cLoja)
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local cAliasQry:= Nil
Local nQtdLibP := 0 // Pendente
Local nQtdLibE := 0 // Efetuada

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SC6.R_E_C_N_O_ RECNOSC6
		FROM %Table:SC6% SC6
		WHERE SC6.C6_FILIAL = %xFilial:SC6%
		AND SC6.C6_NUM = %Exp:cPedido%
		AND SC6.C6_CLI = %Exp:cCliente%
		AND SC6.C6_LOJA = %Exp:cLoja%
		AND (SC6.C6_QTDVEN - SC6.C6_QTDEMP - SC6.C6_QTDENT) > 0
		AND SC6.%NotDel%
	EndSql
	Do While lRet .And. (cAliasQry)->(!Eof())
		SC6->(DbGoTo((cAliasQry)->RECNOSC6))
		nQtdLibP := (SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT)
		nQtdLibE := MaLibDoFat(SC6->(Recno()),nQtdLibP,/*lCredito*/.T.,/*lEstoque*/.T.,/*lAvCred*/.F.,/*lAvEst*/.F.)
		If QtdComp(nQtdLibP) <> QtdComp(nQtdLibE)
			WmsMessage(WmsFmtMsg(STR0042,{{"[VAR01]",SC6->C6_ITEM},{"[VAR02]",AllTrim(Str(nQtdLibP))},{"[VAR03]",AllTrim(Str(nQtdLibE))}}),WMSV08312,1) // "Não foi possível efetuar toda a liberação do item [VAR01] do pedido. Solicitado [VAR02] -> Liberado [VAR03]."
			lRet := .F.
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	// Verifica os itens do pedido se estão com algum bloqueio
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SC9.R_E_C_N_O_ RECNOSC9,
				SC6.R_E_C_N_O_ RECNOSC6
		FROM %Table:SC9% SC9
		INNER JOIN %Table:SC6% SC6
		ON SC6.C6_FILIAL = %xFilial:SC6%
		AND SC6.C6_NUM = SC9.C9_PEDIDO
		AND SC6.C6_ITEM = SC9.C9_ITEM
		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
		AND SC6.%NotDel%
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.C9_CLIENTE = %Exp:cCliente%
		AND SC9.C9_LOJA = %Exp:cLoja%
		AND (SC9.C9_BLCRED <> '  '
			OR SC9.C9_BLEST <> '  ' )
		AND SC9.C9_NFISCAL = ' '
		AND SC9.%NotDel%
	EndSql
	Do While ((cAliasQry)->(!Eof()))
		SC9->(dbGoTo((cAliasQry)->RECNOSC9))
		SC6->(DbGoTo((cAliasQry)->RECNOSC6))
		nQtdLibP := SC9->C9_QTDLIB
		If a460Estorna()
			nQtdLibE := MaLibDoFat(SC6->(Recno()),nQtdLibP,/*lCredito*/.T.,/*lEstoque*/.T.,/*lAvCred*/.F.,/*lAvEst*/.F.)
			If QtdComp(nQtdLibP) <> QtdComp(nQtdLibE)
				WmsMessage(WmsFmtMsg(STR0042,{{"[VAR01]",SC6->C6_ITEM},{"[VAR02]",AllTrim(Str(nQtdLibP))},{"[VAR03]",AllTrim(Str(nQtdLibE))}}),WMSV08313,1) // "Não foi possível efetuar toda a liberação do item [VAR01] do pedido. Solicitado [VAR02] -> Liberado [VAR03]."
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
Static Function ExeSrvWMS(cPedido,cCliente,cLoja,aIdDCF)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local oOrdServ   := Nil
Local cAliasQry  := Nil

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SC9.C9_ITEM,
				SC9.C9_IDDCF,
				DCF.DCF_STSERV,
				SC9.C9_BLCRED,
				SC9.C9_BLEST,
				SC9.C9_PRODUTO
		FROM %Table:SC9% SC9
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = SC9.C9_IDDCF
		AND DCF.%NotDel%
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = %Exp:cPedido%
		AND SC9.C9_CLIENTE = %Exp:cCliente%
		AND SC9.C9_LOJA = %Exp:cLoja%
		AND SC9.C9_BLCRED = '  '
		AND SC9.C9_BLEST = '  '
		AND SC9.C9_NFISCAL = '  '"
		AND SC9.%NotDel%
	EndSql
	If (cAliasQry)->(Eof())
		WmsMessage(WmsFmtMsg(STR0049,{{"[VAR01]",AllTrim(cPedido)},{"[VAR02]",AllTrim(cCliente)},{"[VAR03]",AllTrim(cLoja)}}),WMSV08331,1) // Pedido: [VAR01] Cliente/Loja: [VAR02]/[VAR03] não integrado com o WMS
		lRet := .F.
	Else
		// Instancia classe ordem de serviço execute
		oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oOrdServ)	
		Do While (cAliasQry)->(!Eof())
			If (cAliasQry)->DCF_STSERV $ "1|2"
				AAdd(aIdDCF,{(cAliasQry)->C9_ITEM,(cAliasQry)->C9_IDDCF})
				AAdd(oOrdServ:aLibDCF,(cAliasQry)->C9_IDDCF)
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		oOrdServ:Destroy()
	EndIf
	// Efetua a execução automática quando serviço configurado 
	If lRet
		lRet := WmsExeServ(.F.,.T.)
	EndIf
	RestArea(aAreaAnt)
	
Return lRet

//-----------------------------------------------------------------------------
Static Function ExeMovWMS(cPedido,cCliente,cLoja,cServico,aIdDCF)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local oMovimento := WMSBCCMovimentoServico():New()
Local cAliasQry  := Nil
Local nX         := 0
	For nX := 1 To Len(aIdDCF)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:cPedido%
			AND D12.D12_SERIE = %Exp:aIdDCF[nX][1]%
			AND D12.D12_CLIFOR = %Exp:cCliente%
			AND D12.D12_LOJA = %Exp:cLoja%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_IDDCF = %Exp:aIdDCF[nX][2]%
			AND D12.%NotDel%
			ORDER BY D12_ORDTAR,
						D12_IDMOV,
						D12_ORDATI
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			oMovimento:GoToD12((cAliasQry)->RECNOD12)
			oMovimento:SetLog("2")
			oMovimento:SetStatus("1")
			oMovimento:SetPrAuto("2")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(dDataBase)
			oMovimento:SetHoraFim(Time())
			oMovimento:SetRecHum(__cUserID)
			oMovimento:SetQtdLid(oMovimento:GetQtdMov())
			oMovimento:SetRadioF("2")
			oMovimento:UpdateD12()
			// Finalizar ou Apontar a movimentação
			If lRet .And. oMovimento:IsUltAtiv()
				If oMovimento:IsUpdEst()
					lRet := oMovimento:RecExit()
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Next nX
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
Static Function TransfVol(cPedido,cArmazem,cEndereco,aVolumes)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aProdutos  := {}
Local aTamSX3    := TamSx3('D0O_QUANT')
Local oMntVolItE := WMSDTCMontagemVolumeItens():New() // Expedição
Local oMntVolItC := WMSDTCVolumeCrossDockingItens():New() // Cross-Docking
Local cAliasQry  := Nil
Local cCodMnt    := ""
Local nX         := 0

	oMntVolItE:oMntVol:SetPedido(cPedido)
	cCodMnt := oMntVolItE:oMntVol:FindCodMnt()
	If Empty(cCodMnt)
		WmsMessage(STR0038,WMSV08332,1) // Não foi possível encontrar a montagem de volumes do pedido.
		lRet := .F.
	EndIf
	If lRet
		oMntVolItE:oMntVol:SetCodMnt(cCodMnt)
		oMntVolItC:oVolume:SetArmazem(cArmazem)
		oMntVolItC:oVolume:SetEnder(cEndereco)

		For nX := 1 To Len(aVolumes)
			aProdutos := {} // Deve zerar os produtos do volume anterior, caso existam
			oMntVolItC:oVolume:SetCodVol(aVolumes[nX])
			oMntVolItE:oVolume:SetCodVol(aVolumes[nX])
			oMntVolItC:oVolume:LoadData()
			oMntVolItE:oVolume:SetDtIni(oMntVolItC:oVolume:GetDtIni())
			oMntVolItE:oVolume:SetHrIni(oMntVolItC:oVolume:GetHrIni())
			oMntVolItE:oVolume:SetDtFim(oMntVolItC:oVolume:GetDtFim())
			oMntVolItE:oVolume:SetHrFim(oMntVolItC:oVolume:GetHrFim())
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0O.D0O_PRDORI,
						D0O.D0O_CODPRO,
						D0O.D0O_LOTECT,
						D0O.D0O_NUMLOT,
						D0O.D0O_QUANT,
						D0O.D0O_CODOPE
				FROM %Table:D0O% D0O
				WHERE D0O.D0O_FILIAL = %xFilial:D0O%
				AND D0O.D0O_CODVOL = %Exp:aVolumes[nX]%
				AND D0O.%NotDel%
				ORDER BY D0O.D0O_PRDORI,
							D0O.D0O_CODPRO,
							D0O.D0O_LOTECT,
							D0O.D0O_NUMLOT
			EndSql
			TcSetField(cAliasQry,'D0O_QUANT','N',aTamSX3[1],aTamSX3[2])
			Do While (cAliasQry)->(!Eof())
				If Empty(aProdutos) // Adiciona o operador ao volume para o primeiro produto
					oMntVolItE:oVolume:SetCodOpe((cAliasQry)->D0O_CODOPE)
				EndIf
				AAdd(aProdutos,{(cAliasQry)->D0O_CODPRO,(cAliasQry)->D0O_LOTECT,(cAliasQry)->D0O_NUMLOT,(cAliasQry)->D0O_QUANT,(cAliasQry)->D0O_PRDORI})
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
			lRet := oMntVolItE:MntPrdVol(aProdutos)
			If lRet
				lRet := oMntVolItC:EstPrdVol(aProdutos,.T.,.F.)
			EndIf
		Next
	EndIf
	RestArea(aAreaAnt)
Return lRet
