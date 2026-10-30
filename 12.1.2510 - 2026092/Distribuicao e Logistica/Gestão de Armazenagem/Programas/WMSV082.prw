#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSV082.CH"
#INCLUDE "APVT100.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSV082 - Montagem de Volumes Cross-Docking Coletor                |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a montagem de volumes em endereços cross-docking   |
|         | de forma manual através do coletor de dados.                       |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSV08201 "WMSV08201"
#DEFINE WMSV08202 "WMSV08202"
#DEFINE WMSV08203 "WMSV08203"
#DEFINE WMSV08204 "WMSV08204"
#DEFINE WMSV08205 "WMSV08205"
#DEFINE WMSV08206 "WMSV08206"
#DEFINE WMSV08207 "WMSV08207"
#DEFINE WMSV08208 "WMSV08208"
#DEFINE WMSV08209 "WMSV08209"
#DEFINE WMSV08210 "WMSV08210"
#DEFINE WMSV08211 "WMSV08211"
#DEFINE WMSV08212 "WMSV08212"
#DEFINE WMSV08213 "WMSV08213"
#DEFINE WMSV08214 "WMSV08214"
#DEFINE WMSV08215 "WMSV08215"
#DEFINE WMSV08216 "WMSV08216"
#DEFINE WMSV08217 "WMSV08217"
#DEFINE WMSV08218 "WMSV08218"
#DEFINE WMSV08219 "WMSV08219"
#DEFINE WMSV08220 "WMSV08220"
#DEFINE WMSV08221 "WMSV08221"

Static __lHasLot   := SuperGetMV("MV_WMSLOTE",.F.,.T.)
Static __lVolAuto  := SuperGetMV("MV_WMSCVAC",.F.,.F.) // Geração de código de volume automática no coletor de dados
Static __lCodBar   := SuperGetMV("MV_WMSQCBV",.F.,.F.)
Static __lCBRETEAN := ExistBlock("CBRETEAN")

Static oMntVolItem := WMSDTCVolumeCrossDockingItens():New()
//----------------------------------------------------------------------------------
Function WMSV082()
Local cKey24    := VtDescKey(24)
Local bkey24    := VTSetKey(24)
Local cArmazem  := Space(TamSx3("D14_LOCAL")[1])
Local cEndereco := Space(TamSx3("D14_ENDER")[1])

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	If GetEndOrig(@cArmazem,@cEndereco)
		oMntVolItem:SetArmazem(cArmazem)
		oMntVolItem:SetEnder(cEndereco)
		// Atribui tecla de atalho para estorno
		VTSetKey(24,{|| EstVolume()}, STR0008) // Ctrl-X // Estorno
		MntVolume()
	EndIf
	VTSetKey(24,bkey24,cKey24)
Return Nil
//----------------------------------------------------------------------------------
Static Function GetEndOrig(cArmazem,cEndereco)
Local lEncerra := .F.

	Do While !lEncerra
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Montagem Volume
		@ 01,00 VTSay PadR(STR0002+":",VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmazem Pict "@!" Valid VldArmazem(cArmazem)
		@ 03,00 VTSay PadR(STR0003+":",VTMaxCol()) // Endereco
		@ 04,00 VTGet cEndereco Pict "@!" Valid VldEndOrig(cArmazem,cEndereco)
		VtRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			lEncerra := WmsQuestion(STR0038,STR0001) // Confirma a saída?
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
		WMSVTAviso(WMSV08201,STR0005) // Armazem inválido!
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
		WMSVTAviso(WMSV08202,STR0006) // Endereço inválido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Deve validar se o endereço é do tipo cross-docking
	If (lRet .And. ( cTipEst := Posicione("DC8",1,xFilial("DC8")+cEstFis,"DC8_TPESTR") ) != '3') //DC8_FILIAL+DC8_CODEST
		WMSVTAviso(WMSV08203,STR0007) // Endereço não é o do tipo crossdocking.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------------------------------------------------
Static Function MntVolume()
Local cKey06   := VtDescKey(06)
Local cKey09   := VtDescKey(09)
Local cKey22   := VtDescKey(22)
Local bkey06   := VTSetKey(06) // Ctrl+F
Local bkey09   := VTSetKey(09) //Ctrl+I
Local bkey22   := VTSetKey(22) // Ctrl+V
Local aTela    := VTSave()
Local lRet     := .T.
Local lSair    := .F.
Local cVolume  := ""
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0
Local nProxLin := 1
Local lSaiPed  := .F.
Local lQtdDig  := .T.

Local aProdutos:= {}

	Do While !lSair
		// Inicializa variaveis
		lSaiPed := .F.
		cVolume := Space(TamSx3("D0O_CODVOL")[1])
		If !GetCodVol(@cVolume)
			lSair := WmsQuestion(STR0038,STR0001) //"Confirma a saída?"
			Loop
		EndIf
		VTSetKey(06,{|| GerPedVol(@cVolume)}, STR0030) // Ctrl+F // Gerar Pedido
		VTSetKey(09,{|| ShowItens(cVolume)}, STR0024) // Ctrl+I // Itens Volume
		VTSetKey(22,{|| GetCodVol(@cVolume)}, STR0009) // Ctrl+V // Volume
		Do While !lSair .And. !lSaiPed
			VtClear()
			VTClearBuffer()
			nProxLin := 1
			cCodBar  := Space(128)
			cProduto := Space(TamSx3("D0O_CODPRO")[1])
			cLoteCtl := Space(TamSx3("D0O_LOTECT")[1])
			cSubLote := Space(TamSx3("D0O_NUMLOT")[1])
			//   01234567890123456789
			// 0 Montagem Volume
			// 1 Volume: XXXXXXXXXX
			// 2 Produto
			// 3 PRDWMS0001
			// 4 Lote: AUTO000000
			// 5 Sub-Lote: 000000
			// 6 Qtde
			// 7             9.999,99
			WMSVTCabec(STR0001, .F., .F., .T.) // Montagem Volume
			@ nProxLin++,00 VTSay PadR(STR0009 + ': ' + cVolume,VTMaxCol()) // Volume
			@ nProxLin++,00 VTSay STR0014 // Informe o Produto
			@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid VldPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
			VtRead()
			// Se teclou CTRL+F limpa o volume, então deve pedir um novo
			If Empty(cVolume)
				VTKeyBoard(Chr(20))
				lSaiPed := .T.
				Loop
			EndIf
			If VTLastKey() != 27
				If __lHasLot .And. Rastro(cProduto)
					@ nProxLin,   00 VTSay PadR(STR0015, VTMaxCol()) // Lote:
					@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid VldLoteCtl(cLoteCtl)
					If Rastro(cProduto,"S")
						@ nProxLin,   00 VTSay PadR(STR0016, VTMaxCol()) // Sub-Lote:
						@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid VldSubLote(cSubLote)
					EndIf
				Else
					oMntVolItem:QtdPrdVol() // Deve carregar as quantidades neste ponto
				EndIf
				Do While .T.
					lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
					@ nProxLin++,00 VTSay STR0017 //Qtde
					@ nProxLin++,00 VTGet nQtde Pict "@E 99,999,999.99" When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
					VTRead()
					// Se teclou CTRL+F limpa o volume, então deve pedir um novo
					If Empty(cVolume)
						VTKeyBoard(Chr(20))
						lSaiPed := .T.
						Exit
					EndIf
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
					// Deve carregar as informações dos produtos a serem gravados
					// Não pode gravar diretamente o produto do objeto, pois quando
					// o produto possui lote, porém não solicita o lote no coletor
					// pode ser que tenha mais de um produto/lote apto a ser montado
					// volume de acordo com a quantidade informada
					// Também quando o produto do objeto é um pai deve carregar os filhos
					aProdutos := {}
					If !oMntVolItem:LoadPrdVol(aProdutos,nQtde)
						nQtde    := 0
						nProxLin -= 2
						Loop
					EndIf
					Exit
				EndDo

				If VTLastKey() != 27
					If !oMntVolItem:MntPrdVol(aProdutos)
						Loop
					EndIf
				EndIf
			Else
				If WmsQuestion(STR0038,STR0001) //"Confirma a saída?"
					lSair := .T.
				EndIf
			EndIf
		EndDo
		// Restaura teclas
		VTSetKey(06,bkey06,cKey06)
		VTSetKey(09,bkey09,cKey09)
		VTSetKey(22,bkey22,cKey22)
	EndDo
	VtRestore(,,,,aTela)
Return lRet
//----------------------------------------------------------------------------------
Static Function GetCodVol(cVolume)
Local cKey06   := VtDescKey(06)
Local bkey06   := VTSetKey(06)
Local cKey09   := VtDescKey(09)
Local bkey09   := VTSetKey(09)
Local ckey22   := VTDescKey(22)
Local bkey22   := VTSetKey(22)
Local aTela    := VtSave()
Local lRet     := .T.
Local cVolAux  := Space(TamSx3("D0N_CODVOL")[1])
Local lVolAuto := .F.
Local lReabre  := .F.

	// Geração automática do código dos volumes (não solicita)
	If __lVolAuto
		cVolAux := PadL(CBProxCod('MV_WMSNVOL'),TamSX3('D0N_CODVOL')[1],'0')
		WMSVTAviso(STR0001, STR0010+ cVolAux) // Novo volume gerado:
		lVolAuto := .T.
	EndIf
	If !lVolAuto
		VtClear()
		WMSVTCabec(STR0001, .F., .F., .T.) // Montagem Volume
		@ 01,00 VTSay STR0002+'/'+STR0003 // Armazém/Endereço
		@ 02,00 VTSay oMntVolItem:GetArmazem()+'/'+oMntVolItem:GetEnder()
		@ 03,00 VtSay STR0018 // Informe o Volume
		@ 04,00 VtGet cVolAux Picture '@!' Valid VldCodVol(cVolAux,@lReabre)
		VtRead()
		VtRestore(,,,,aTela)
		If VtLastkey() == 27
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cVolume := cVolAux
		@ 01,00 VTSay PadR(STR0009 + ': ' + cVolume,VTMaxCol()) // Volume
		If !lReabre
			oMntVolItem:oVolume:SetCodVol(cVolume)
			oMntVolItem:oVolume:SetDtIni(dDataBase)
			oMntVolItem:oVolume:SetHrIni(Time())
		EndIf
		// Anula data e hora final para forçar gravar atualizado
		oMntVolItem:oVolume:SetDtFim(StoD(""))
		oMntVolItem:oVolume:SetHrFim("")
	EndIf
	// Restaura Tecla
	VTSetKey(06,bkey06, cKey06)
	VTSetKey(09,bkey09, cKey09)
	VTSetKey(22,bKey22, cKey22)
Return lRet

//----------------------------------------------------------------------------------
Static Function VldCodVol(cVolume,lReabre,lEstorno)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil

Default lEstorno := .F.

	If Empty(cVolume)
		Return .F.
	EndIf
	If Len(AllTrim(cVolume)) != TamSx3("D0N_CODVOL")[1]
		WMSVTAviso(WMSV08219,STR0023) // "Tamanho do codigo do volume invalido!"
		lRet := .F.
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
		WMSVTAviso(WMSV08204, STR0011) // O volume informado pertence a uma montagem de volume de expedição.
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	If lRet
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
			If (cAliasQry)->(D0N_LOCAL+D0N_ENDER) != oMntVolItem:GetArmazem()+oMntVolItem:GetEnder()
				WMSVTAviso(WMSV08205, STR0012) // O volume informado está sendo usado em outro armazém/endereço.
				lRet := .F.
			Else
				If !lEstorno
					oMntVolItem:oVolume:GoToD0N((cAliasQry)->RECNOD0N)
					WMSVTAviso(WMSV08206, STR0013) // O volume já existe neste armazém/endereço e está sendo reaberto.
					lReabre := .T.
				Else
					oMntVolItem:SetCodVol(cVolume)
				EndIf
			EndIf
		Else
			If lEstorno
				WMSVTAviso(WMSV08217, STR0034) // Volume informado inválido.
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function ShowItens(cVolume)
Local cKey06   := VtDescKey(06)
Local cKey09   := VtDescKey(09)
Local cKey22   := VtDescKey(22)
Local bkey06   := VTSetKey(06) // Ctrl+F
Local bkey09   := VTSetKey(09) //Ctrl+I
Local bkey22   := VTSetKey(22) // Ctrl+V

	// Deve validar se o volume possui itens
	If !oMntVolItem:oVolume:VolHasItem()
		WMSVTAviso(WMSV08218, STR0032) // O volume não possui itens.
		lRet := .F.
	Else
		WMSV083ITV(cVolume)
	EndIf
	// Restaura Tecla
	VTSetKey(06,bkey06, cKey06)
	VTSetKey(09,bkey09, cKey09)
	VTSetKey(22,bKey22, cKey22)
Return Nil

//----------------------------------------------------------------------------------
Static Function VldPrdLot(cProduto,cLoteCtl,cSubLote,nQtde,cCodBar,lEstorno)
Local lRet      := .T.
Local aProduto  := {}
Local lAchou    := .F.
Default lEstorno:= .F.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("D0O_CODPRO")[1])
	cLoteCtl := Space(TamSx3("D0O_LOTECT")[1])
	cSubLote := Space(TamSx3("D0O_NUMLOT")[1])
	nQtde    := 0
	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		If __lCodBar .Or. __lCBRETEAN
			nQtde := aProduto[2]
		EndIf
		cLoteCtl := Padr(aProduto[3],TamSx3("D0O_LOTECT")[1])
	Else
		aProduto := CBRetEti(cCodBar, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := aProduto[2]
			cLoteCtl := Padr(aProduto[16],TamSx3("D0O_LOTECT")[1])
			cSubLote := Padr(aProduto[17],TamSx3("D0O_NUMLOT")[1])
		EndIf
		If Empty(aProduto)
			WMSVTAviso(WMSV08207,STR0019) //Etiqueta invalida!
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
	// Deve validar se o produto informado é um produto partes ou componente
	If lRet
		oMntVolItem:SetProduto(cProduto)
		oMntVolItem:SetLoteCtl(cLoteCtl)
		oMntVolItem:SetNumLote(cSubLote)
		
		lAchou := oMntVolItem:VldPrdCmp(lEstorno)
		If !lAchou
			If !lEstorno
				WMSVTAviso(WMSV08208,STR0020) //Produto não possui saldo disponível no endereço para montagem de volumes.
			Else
				WMSVTAviso(WMSV08209,STR0021) //Produto não possui saldo bloqueado no endereço por montagem de volumes.
			EndIf
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
	If lRet
		// Se for estorno deve validar se o produto está no volume
		If lEstorno
			oMntVolItem:QtdPrdVol(lEstorno)
			If QtdComp(oMntVolItem:GetQuant()) == 0
				WMSVTAviso(WMSV08210,STR0022) // "Produto não possui quantidade embalada no volume para estorno."
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		cCodBar := Space(128)
	EndIf
Return lRet
//-----------------------------------------------------------------------------
// Valida o produto/lote informado, verificando se o mesmo possui saldo no endereço
// Valida se o mesmo já foi montado volume e pode ser estornado volume
//-----------------------------------------------------------------------------
Static Function VldLoteCtl(cLoteCtl,lEstorno)
Default lEstorno:= .F.

	If Empty(cLoteCtl)
		Return .F.
	EndIf
	oMntVolItem:SetLoteCtl(cLoteCtl)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol(lEstorno)
	If !lEstorno
		//Deve validar se o produto/lote possui quantidade em estoque no endereço
		If QtdComp(oMntVolItem:GetQuant()) == 0
			WMSVTAviso(WMSV08211,STR0025) // "Produto/Lote não possui saldo disponível no endereço para montagem de volumes."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	Else
		//Deve validar se o produto possui quantidade para embalada para ser estornada
		If QtdComp(oMntVolItem:GetQuant()) == 0
			WMSVTAviso(WMSV08212,STR0026) // "Produto/Lote não possui quantidade embalada no volume para estorno."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	EndIf
Return .T.
//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo possui saldo no endereço
// Valida se o mesmo já foi montado volume e pode ser estornado volume
//-----------------------------------------------------------------------------
Static Function VldSubLote(cSubLote,lEstorno)
Default lEstorno:= .F.

	If Empty(cSubLote)
		Return .F.
	EndIf
	oMntVolItem:SetNumLote(cSubLote)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol(lEstorno)
	If !lEstorno
		//Deve validar se o produto/lote possui quantidade em estoque no endereço
		If QtdComp(oMntVolItem:GetQuant()) == 0
			WMSVTAviso(WMSV08213,STR0027) // "Produto/Rastro não possui saldo disponível no endereço para montagem de volumes."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	Else
		//Deve validar se o produto possui quantidade para embalada para ser estornada
		If QtdComp(oMntVolItem:GetQuant()) == 0
			WMSVTAviso(WMSV08214,STR0028) // "Produto/Rastro não possui quantidade embalada no volume para estorno."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	EndIf
Return .T.
//----------------------------------------------------------------------------------
Static Function VldQtdSld(nQtde,lEstorno)
Local lRet := .T.
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := SuperGetMV("MV_NTOL1UM",.F.,0)
Default lEstorno:= .F.
	If Empty(nQtde)
		Return .F.
	EndIf
	If QtdComp(nQtde) > QtdComp(oMntVolItem:GetQuant()) .And.;
		QtdComp(Abs(oMntVolItem:GetQuant()-nQtde)) > QtdComp(nToler1UM)
		If !lEstorno
			WMSVTAviso(WMSV08215,WmsFmtMsg(STR0029,{{"[VAR01]",AllTrim(Str(oMntVolItem:GetQuant()))}})) //"Quantidade de saldo disponível ([VAR01]) menor que a quantidade solicitada."
		Else
			WMSVTAviso(WMSV08216,WmsFmtMsg(STR0033,{{"[VAR01]",AllTrim(Str(oMntVolItem:GetQuant()))}})) //"Quantidade montada volume ([VAR01]) menor que a quantidade solicitada para estorno."
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet

//----------------------------------------------------------------------------------
Static Function EstVolume()
Local ckey06   := VTDescKey(06)
Local ckey09   := VTDescKey(09)
Local ckey22   := VTDescKey(22)
Local ckey24   := VTDescKey(24)
Local bkey06   := VTSetKey(06)
Local bkey09   := VTSetKey(09)
Local bkey22   := VTSetKey(22)
Local bkey24   := VTSetKey(24)
Local aTela    := VTSave()
Local cVolume  := ""
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0
Local nProxLin := 1
Local lQtdDig  := .T.
Local aProdutos:= {}
Local lRet     := .T.
Local lEsc     := .F.
Local nOpcao   := 0

Local cVolumeAnt := oMntVolItem:GetCodVol()
Local cPrdOriAnt := oMntVolItem:GetPrdOri()
Local cProdutAnt := oMntVolItem:GetProduto()
Local cLoteCtAnt := oMntVolItem:GetLoteCtl()
Local cNumLotAnt := oMntVolItem:GetNumLote()
Local nQuantAnt  := oMntVolItem:GetQuant()

	// 01234567890123456789
	// 0 Estorno Mont. Volume
	// 1 Volume: XXXXXXXXXX
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
		cProduto := Space(TamSx3("D0O_CODPRO")[1])
		cLoteCtl := Space(TamSx3("D0O_LOTECT")[1])
		cSubLote := Space(TamSx3("D0O_NUMLOT")[1])
		cVolume  := Space(TamSx3("D0O_CODVOL")[1])
		// Desativa a tecla de atalho de itens do volume
		VTSetKey(09)

		WMSVTCabec(STR0031, .F., .F., .T.) // Estorno Mont. Volume
		@ 01,00 VTSay STR0002+'/'+STR0003 // Armazém/Endereço
		@ 02,00 VTSay oMntVolItem:GetArmazem()+'/'+oMntVolItem:GetEnder()
		@ 03,00 VtSay STR0018 // Informe o Volume
		@ 04,00 VtGet cVolume Picture '@!' Valid VldCodVol(cVolume,,.T.)
		VtRead()
		If VtLastKey() == 27
			lEsc := .T.
			Exit
		EndIf
		// Ativa a tecla de atalho de itens do volume
		VTSetKey(09,{|| ShowItens(cVolume)}, STR0024) // Ctrl+I // Itens Volume
		// Deve questionar se deseja estornar o volume completo ou informar o item
		If (nOpcao := WMSVTAviso(STR0031,STR0035,{STR0036,STR0037})) == 1 //Atencao! Escolha o tipo de estorno: //Volume Completo //Produto Volume
			// Deve carregar as informações dos produtos a serem estornados
			// Carrega todos os produtos do volume
			aProdutos := {}
			If LoadPrdEst(aProdutos,nQtde,.T.)
				oMntVolItem:EstPrdVol(aProdutos,.T.)
			EndIf
			Loop
		EndIf
		// Se teclou ESC na pergunta
		If nOpcao == 0
			Loop
		EndIf

		VTCLear()
		nProxLin := 1
		WMSVTCabec(STR0031, .F., .F., .T.) // Estorno Mont. Volume
		@ nProxLin++,00 VTSay PadR(STR0008 + ': ' + cVolume,VTMaxCol()) // Volume
		@ nProxLin++,00 VTSay STR0014 // Informe o Produto
		@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid VldPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar,.T.)
		VtRead()
		If VTLastKey() != 27
			If __lHasLot .And. Rastro(cProduto)
				@ nProxLin,   00 VTSay PadR(STR0015, VTMaxCol()) // Lote:
				@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid VldLoteCtl(cLoteCtl,.T.)
				If Rastro(cProduto,"S")
					@ nProxLin,   00 VTSay PadR(STR0016, VTMaxCol()) // Sub-Lote:
					@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid VldSubLote(cSubLote,.T.)
				EndIf
			EndIf
			Do While .T.
				lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
				@ nProxLin++,00 VTSay STR0017 //Qtde
				@ nProxLin++,00 VTGet nQtde Pict "@E 99,999,999.99" When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
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
			// Deve carregar as informações dos produtos a serem estornados
			// Não pode gravar diretamente o produto do objeto, pois quando
			// o produto possui lote, porém não solicita o lote no coletor
			// pode ser que tenha mais de um produto/lote apto a ser estornado
			// do volume de acordo com a quantidade informada
			aProdutos := {}
			If LoadPrdEst(aProdutos,nQtde,.F.)
				oMntVolItem:EstPrdVol(aProdutos,.F.)
			EndIf
		EndIf
	EndDo

	VTClearBuffer()
	oMntVolItem:SetCodVol(cVolumeAnt)
	oMntVolItem:oVolume:LoadData(1)
	oMntVolItem:SetPrdOri(cPrdOriAnt)
	oMntVolItem:SetProduto(cProdutAnt)
	oMntVolItem:SetLoteCtl(cLoteCtAnt)
	oMntVolItem:SetNumLote(cNumLotAnt)
	oMntVolItem:SetQuant(nQuantAnt)
	VtRestore(,,,,aTela)
	VTSetKey(06,bKey06, cKey06)
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(24,bKey24, cKey24)
Return

//-----------------------------------------------------------------------------
// Carrega as quantidades a serem estornadas do volume de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor,
// ou pode ser que esteja estornando todos os itens do volume
//-----------------------------------------------------------------------------
Static Function LoadPrdEst(aProdutos,nQtde,lTotal)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aTamD0O   := TamSx3('D0O_QUANT')
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nQtdPrd   := 0

Default nQtde  := 0
Default lTotal := .F.

	If lTotal
		BeginSql Alias cAliasQry
			SELECT D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT,
					D0O.D0O_QUANT
			FROM %Table:D0O% D0O
			WHERE D0O.D0O_FILIAL = %xFilial:D0O%
			AND D0O.D0O_CODVOL = %Exp:oMntVolItem:GetCodVol()%
			AND D0O.%NotDel%
		EndSql
	Else
		cWhere := "%"
		If !Empty(oMntVolItem:GetLoteCtl())
			cWhere += " AND D0O.D0O_LOTECT = '"+oMntVolItem:GetLoteCtl()+"'"
		EndIf
		If !Empty(oMntVolItem:GetNumLote())
			cWhere += " AND D0O.D0O_NUMLOT = '"+oMntVolItem:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT D0O.D0O_PRDORI,
					D0O.D0O_CODPRO,
					D0O.D0O_LOTECT,
					D0O.D0O_NUMLOT,
					D0O.D0O_QUANT
			FROM %Table:D0O% D0O
			WHERE D0O.D0O_FILIAL = %xFilial:D0O%
			AND D0O.D0O_CODVOL = %Exp:oMntVolItem:GetCodVol()%
			AND D0O.D0O_PRDORI = %Exp:oMntVolItem:GetPrdOri()%
			AND D0O.D0O_CODPRO = %Exp:oMntVolItem:GetProduto()%
			AND D0O.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	TcSetField(cAliasQry,'D0O_QUANT','N',aTamD0O[1],aTamD0O[2])
	Do While (cAliasQry)->(!Eof())
		If lTotal
			nQtdPrd := (cAliasQry)->D0O_QUANT
		Else
			// Calcula a quantidade que pode ser "rateada" para este produto
			If QtdComp(nQtde) > QtdComp((cAliasQry)->D0O_QUANT)
				nQtdPrd := (cAliasQry)->D0O_QUANT
				nQtde   -= (cAliasQry)->D0O_QUANT
			Else
				nQtdPrd := nQtde
				nQtde   := 0
			EndIf
		EndIf
		// Adiciona o produto no array de produtos a serem colocados no volume
		If QtdComp(nQtdPrd) > 0
			AAdd(aProdutos, {(cAliasQry)->D0O_CODPRO, (cAliasQry)->D0O_LOTECT, (cAliasQry)->D0O_NUMLOT, nQtdPrd, (cAliasQry)->D0O_PRDORI})
		EndIf
		// Se não é produto componente e zerou a quantidade, deve sair
		If !lTotal .And. QtdComp(nQtde) == 0
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
Static Function GerPedVol(cVolume)
Local lRet      := .T.
Local nOpcao    := 0
Local aTela     := {}
Local aVolumes  := {}
Local cSeekD0N  := ""
	If Empty(cVolume)
		Return .F.
	EndIf
	// __Montagem Volume___
	// Gera pedido de venda
	// a partir de:
	// 
	// Volume Atual
	// Volumes Endereço
	
	nOpcao := WMSVTAviso(STR0001, STR0039, {STR0041,STR0042})
	If nOpcao  == 0
		lRet := .F.
	EndIf

	If lRet
		If nOpcao == 1 
			// Deve validar se o volume possui itens
			If !oMntVolItem:oVolume:VolHasItem()
				WMSVTAviso(WMSV08220, STR0040) // O volume não possui itens para geração de pedido.
				lRet := .F.
			Else 
				aVolumes := {cVolume}
			EndIf
		Else
			D0N->(DbSetOrder(2)) //D0N_FILIAL+D0N_LOCAL+D0N_ENDER+D0N_CODVOL
			D0N->(DbSeek(cSeekD0N := xFilial("D0N")+oMntVolItem:GetArmazem()+oMntVolItem:GetEnder()))
			While D0N->(!Eof() .And. D0N_FILIAL+D0N_LOCAL+D0N_ENDER == cSeekD0N) 
				AAdd(aVolumes,D0N->D0N_CODVOL)
				D0N->(DbSkip())
			EndDo
			If Len(aVolumes) > 0
				aTela := VTSave()
				WMSVTCabec(STR0043,.F.,.F.,.T.) // "Lista Volumes"
				nOpcao := 1
				nOpcao := VtAchoice(1,0,VtMaxRow(),VtMaxCol(),aVolumes,,,nOpcao)
				If nOpcao <= 0 // Se teclar ESC cancela
					lRet := .F.
				EndIf
				VtRestore(,,,,aTela)
			Else
				WMSVTAviso(WMSV08221, STR0044) // Não existem volume no endereço aptos a gerar pedido.
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := WMSV083PED(oMntVolItem:GetArmazem(),oMntVolItem:GetEnder(),aVolumes)
	EndIf
	// Se deu certo a geração do pedido de venda limpa o volume
	If lRet
		cVolume := Space(TamSx3("D0O_CODVOL")[1])
		VTKeyBoard(Chr(27)) //-- Tecla ESC
	EndIf
Return lRet