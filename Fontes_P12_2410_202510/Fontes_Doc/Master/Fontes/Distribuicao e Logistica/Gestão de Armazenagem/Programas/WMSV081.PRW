#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSV081.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV08101 "WMSV08101"
#DEFINE WMSV08102 "WMSV08102"
#DEFINE WMSV08103 "WMSV08103"
#DEFINE WMSV08104 "WMSV08104"
#DEFINE WMSV08105 "WMSV08105"
#DEFINE WMSV08107 "WMSV08107"
#DEFINE WMSV08108 "WMSV08108"
#DEFINE WMSV08109 "WMSV08109"
#DEFINE WMSV08110 "WMSV08110"
#DEFINE WMSV08111 "WMSV08111"
#DEFINE WMSV08112 "WMSV08112"
#DEFINE WMSV08113 "WMSV08113"
#DEFINE WMSV08114 "WMSV08114"
#DEFINE WMSV08115 "WMSV08115"
#DEFINE WMSV08116 "WMSV08116"
#DEFINE WMSV08117 "WMSV08117"
#DEFINE WMSV08118 "WMSV08118"
#DEFINE WMSV08119 "WMSV08119"
#DEFINE WMSV08120 "WMSV08120"
#DEFINE WMSV08121 "WMSV08121"
#DEFINE WMSV08122 "WMSV08122"
#DEFINE WMSV08123 "WMSV08123"
#DEFINE WMSV08124 "WMSV08124"
#DEFINE WMSV08125 "WMSV08125"
#DEFINE WMSV08126 "WMSV08126"
#DEFINE WMSV08127 "WMSV08127"
#DEFINE WMSV08128 "WMSV08128"
#DEFINE WMSV08129 "WMSV08129"
#DEFINE WMSV08130 "WMSV08130"
#DEFINE WMSV08131 "WMSV08131"
#DEFINE WMSV08132 "WMSV08132"
#DEFINE WMSV08133 "WMSV08133"
#DEFINE WMSV08134 "WMSV08134"
#DEFINE WMSV08135 "WMSV08135"
#DEFINE WMSV08136 "WMSV08136"
#DEFINE WMSV08137 "WMSV08137"
#DEFINE WMSV08138 "WMSV08138"
#DEFINE WMSV08139 "WMSV08139"
#DEFINE WMSV08140 "WMSV08140"
#DEFINE WMSV08141 "WMSV08141"
#DEFINE WMSV08142 "WMSV08142"
#DEFINE WMSV08143 "WMSV08143"
#DEFINE WMSV08144 "WMSV08144"
#DEFINE WMSV08145 "WMSV08145"
#DEFINE WMSV08146 "WMSV08146"
#DEFINE WMSV08147 "WMSV08147"
#DEFINE WMSV08148 "WMSV08148"
#DEFINE WMSV08149 "WMSV08149"
#DEFINE WMSV08150 "WMSV08150"
#DEFINE WMSV08151 "WMSV08151"
#DEFINE WMSV08152 "WMSV08152"
// Considera a quantidade retornada pelo código de barras do produto
Static __lHasLot  := SuperGetMV("MV_WMSLOTE",.F.,.T.)
Static __lCodBar  := SuperGetMV("MV_WMSQCBV",.F.,.F.)
Static __lVolAuto := SuperGetMV("MV_WMSCVAC",.F.,.F.) // Geração de código de volume automática no coletor de dados
Static _lCBRETEAN := ExistBlock("CBRETEAN")
Static _lWV080CDV := ExistBlock("WV080CDV")
Static _lWV080GVA := ExistBlock("WV080GVA")
Static _lWV081VMT := ExistBlock("WV081VMT")
Static oMntVolItem := WMSDTCMontagemVolumeItens():New()

//----------------------------------------------------------
/*/{Protheus.doc} WMSV081
Montagem de Volume via Coletor de Dados RF

@version P11
@since   09/10/06 - revisão 19/05/14
/*/
//----------------------------------------------------------
Function WMSV081()
Local aTela := {}
Local nOpc  := 0

	aTela := VtSave()
	VTClear()
	If !Empty(__cUserID)
	  // Dependendo da função que o usuário tem cadastrada no coletor ele poderá escolher entre
	  // Montagem de Volume por Carga ou Pedido, ou então ser direcionado automaticamente para
	  // uma das duas funções sem opção de escolha
		If IsInCallStack('WMSV081A')
			nOpc := 1
		ElseIf IsInCallStack('WMSV081B')
			nOpc := 2
		Else
			@ 00,00 VTSay STR0001 // Selecione"
			nOpc := VTaChoice(2,0,4,VTMaxCol(),{STR0002,STR0003}) // Montar Volume Carga // Montar Volume Pedido
		EndIf

		If VtLastKey() != 27
			MntVolume(nOpc)
		EndIf
	Else
		WMSVTAviso(WMSV08101,STR0004) // Operador não cadastrado
		VtKeyboard(Chr(20))
	EndIf
	VtRestore(,,,,aTela)
Return
//----------------------------------------------------------
/*/{Protheus.doc} WMSV081A
Remete automaticamente à montagem de volume por carga

@version	P11
@since   09/10/06 - revisão 19/05/14
/*/
//----------------------------------------------------------
Function WMSV081A()
	WMSV081()
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} WMSV081B
Remete automaticamente à montagem de volume por pedido

@version	P11
@since   09/10/06 - revisão 19/05/14
/*/
//----------------------------------------------------------
Function WMSV081B()
	WMSV081()
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} MntVolume
Tela de montagem de volumes

@param   nOpc  Opção de montagem de volume:
					1 - Por carga/pedido
					2 - Por pedido

@version	P11
@since   09/10/06 - revisão 19/05/14
/*/
//----------------------------------------------------------
Static Function MntVolume(nOpc)
Local cKey05   := VtDescKey(05)
Local cKey09   := VtDescKey(09)
Local cKey22   := VtDescKey(22)
Local cKey24   := VtDescKey(24)
Local bkey05   := VTSetKey(05) // Ctrl+E
Local bkey09   := VTSetKey(09) // Ctrl+I
Local bkey22   := VTSetKey(22) // Ctrl+V
Local bkey24   := VTSetKey(24) // Ctrl+X
Local aTela    := VTSave()
Local lRet     := .T.
Local lSair    := .F.
Local cVolume  := ""
Local cCarga   := ""
Local cPedido  := ""
Local cCodBar  := ""
Local cProduto := ""
Local cLoteCtl := ""
Local cSubLote := ""
Local nQtde    := 0
Local nPos     := 0
Local nProxLin := 1
Local lQtdDig  := .T.
Local cRetPE   := ""
Local aProdutos:= {}

	Do While !lSair
		VTCLear()
		VTClearBuffer()
		nProxLin := 2
		// Inicializa variaveis
		cVolume  := Space(TamSx3("DCU_CODVOL")[1])
		cCarga   := Space(TamSx3("DCS_CARGA")[1])
		cPedido  := Space(TamSx3("DCS_PEDIDO")[1])
		oMntVolItem:oMntVol:SetCarga(cCarga)
		oMntVolItem:oMntVol:SetPedido(cPedido)

		VTSetKey(24,{|| EstVolume(nOpc,cCarga,cPedido) }, STR0010) // Ctrl+X // Estorna

		WMSVTCabec(STR0005, .F., .F., .T.) // Montagem Volume
		If nOpc == 1
			@ nProxLin++, 00 VTSay PadR(STR0006, VTMaxCol()) // Carga
			@ nProxLin++, 00 VTGet cCarga Valid !Empty(cCarga) .And. ValCarPed(1,cCarga)
		EndIf
		@ nProxLin++, 00 VTSay PadR(STR0007, VTMaxCol()) // Pedido
		@ nProxLin++, 00 VTGet cPedido Valid !Empty(cPedido) .And. ValCarPed(2,cCarga,cPedido)
		VTRead()
		If VtLastKey() == 27
			Exit
		EndIf
		If !WMSV081Vol(nOpc,@cVolume)
			Exit
		EndIf
		// Ativa teclas de atalho
		VTSetKey(09,{|| WMSV081Inf(nOpc)         }, STR0009) // Ctrl+I // Informações
		VTSetKey(22,{|| WMSV081Vol(nOpc,@cVolume)}, STR0008) // Ctrl+V // Volume
		VTSetKey(05,{|| WMSV081Eti(.F.)}          , STR0075) // Ctrl+E // Etiqueta Volume
		Do While !lSair
			VtClear()
			nProxLin := 1
			cCodBar  := Space(128)
			cProduto := Space(TamSx3("DCV_CODPRO")[1])
			cLoteCtl := Space(TamSx3("DCT_LOTE")[1])
			cSubLote := Space(TamSx3("DCT_SUBLOT")[1])

			WMSVTCabec(STR0005, .F., .F., .T.) // Montagem Volume
			@ nProxLin++,00 VTSay PadR(STR0008 + ': ' + cVolume,VTMaxCol()) // Volume
			@ nProxLin++,00 VTSay STR0012 // Produto
			@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid ValPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
			VtRead()
			If VTLastKey() != 27
				// PE para possibilitar a geração automática de um
				// novo volume após a digitação do código do produto
				If _lWV080GVA
					cRetPE := ExecBlock("WV080GVA",.F.,.F.,{cCarga,cPedido,cProduto,cVolume,nQtde})
					If ValType(cRetPE) == "C" .And. !Empty(cRetPE)
						cVolume := cRetPE
						@01,00 VTSay STR0006 + ' ' + cVolume //Volume
						oMntVolItem:oVolume:SetCodVol(cVolume)
						oMntVolItem:oVolume:SetDtIni(dDataBase)
						oMntVolItem:oVolume:SetHrIni(Time())
						// Anula data e hora final para forçar gravar atualizado
						oMntVolItem:oVolume:SetDtFim(StoD(""))
						oMntVolItem:oVolume:SetHrFim("")
					Else
						Loop
					EndIf
				EndIf
				If __lHasLot .And. Rastro(cProduto)
					@ nProxLin,   00 VTSay PadR(STR0013, VTMaxCol()) // Lote:
					@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cLoteCtl)
					If Rastro(cProduto,"S")
						@ nProxLin,   00 VTSay PadR(STR0014, VTMaxCol()) // Sub-Lote:
						@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cSubLote)
					EndIf
				EndIf
				Do While .T.
					lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
					@ nProxLin++,00 VTSay STR0011 //Qtde
					@ nProxLin++,00 VTGet nQtde Pict "@E 99,999,999.99" When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
					VTRead()
					If VTLastKey() == 27
						Exit // Volta para o inicio do produto
					EndIf
					If !ValQtdEmb(nQtde)
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
					If QtdComp(nQtde) > QtdComp(0) .And. !oMntVolItem:LoadPrdVol(aProdutos,nQtde)
						WMSVTAviso(WMSV08142,oMntVolItem:GetErro())
						nQtde    := 0
						nProxLin -= 2
						Loop
					EndIf
					Exit
				EndDo
				// Retorna para leitura do produto quando quantidade zerada
				If QtdComp(nQtde) <= 0
					Loop
				EndIf
				If VTLastKey() != 27
					If !oMntVolItem:MntPrdVol(aProdutos)
						WMSVTAviso(WMSV08102,oMntVolItem:GetErro())
						Loop
					EndIf

					WMV081Fina(nOpc,oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),oMntVolItem:GetCodMnt())
					If oMntVolItem:oMntVol:GetStatus() == "3"
						lSair := .T.
					EndIf
				EndIf
			Else
				If WmsQuestion(STR0015,STR0005)
					VTClear()
					WMSVTCabec(STR0005, .F., .F., .T.) // Montagem Volume
					@ 01,00 VTSay PadR(STR0036, VTMaxCol()) // Em Andamento
					@ 02,00 VTSay Replicate("-",VTMaxCol())
					If nOpc == 1
						@ 04,00 VTSay STR0006+'..: '+cCarga // Carga..:
						@ 05,00 VTSay STR0007+': '+cPedido // Pedido:
						@ 06,00 VTSay Replicate("-",VTMaxCol())
					Else
						@ 04,00 VTSay STR0007+': '+cPedido // Pedido:
						@ 05,00 VTSay Replicate("-",VTMaxCol())
					EndIf
					WMSVTRodPe()
					lSair := .T.
				EndIf
			EndIf
		EndDo
		// Restaura teclas
		VTSetKey(05,bkey05,cKey05)
		VTSetKey(09,bkey09,cKey09)
		VTSetKey(22,bkey22,cKey22)
		VTSetKey(24,bkey24,cKey24)
	EndDo
	VtRestore(,,,,aTela)
Return lRet
//----------------------------------------------------------
// ValCarPed
// Validação de carga e pedido
// nCampo   Campo que está sendo validado:
// 			1 - Carga
// 			2 - Pedido
// cCarga   Número da carga
// cPedido  Número do pedido
//----------------------------------------------------------
Static Function ValCarPed(nCampo,cCarga,cPedido,lEstorno)
Local lRet   := .T.
Local xRetPE := Nil

Default cCarga  := Space(TamSx3("DCS_CARGA")[1])
Default cPedido := Space(TamSx3("DCS_PEDIDO")[1])
Default lEstorno:= .F.

	oMntVolItem:oMntVol:SetCarga(cCarga)
	If nCampo == 1
		If !oMntVolItem:oMntVol:ChkCarga()
			WMSVTAviso(WMSV08103,oMntVolItem:oMntVol:GetErro()) // Aviso
			lRet := .F.
		EndIf
	ElseIf nCampo == 2
		oMntVolItem:oMntVol:SetPedido(cPedido)
		// Busca o codigo da montagem de volume
		oMntVolItem:oMntVol:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		If !oMntVolItem:oMntVol:LoadData()
			WMSVTAviso(WMSV08104,STR0016) // Pedido inválido!
			lRet := .F.
		Else
			If !lEstorno .And. oMntVolItem:oMntVol:GetStatus() == "3"
				WMSVTAviso(WMSV08105,STR0017) // Montagem já finalizada!
				lRet := .F.
			ElseIf lEstorno .And. oMntVolItem:oMntVol:GetStatus()== "1"
				WMSVTAviso(WMSV08146,STR0069) // Montagem não iniciada!
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Permite executar regras adicionais na validação de Carga/Pedido
	If lRet .And. _lWV081VMT
		xRetPE := ExecBlock("WV081VMT",.F.,.F.,{nCampo,oMntVolItem:oMntVol:GetCodMnt(),cCarga,cPedido,lEstorno})
		If ValType(xRetPE) == "L"
			lRet := xRetPE
		EndIf
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet

//---------------------
// Validação do produto
//---------------------
Static Function ValPrdLot(cProduto,cLoteCtl,cSubLote,nQtde,cCodBar,lEstorno)
Local lRet      := .T.
Local lAchou    := .F.
Local aProduto  := {}
Local cWhere    := ""
Local cAliasDCT := Nil

Default lEstorno:= .F.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cProduto := Space(TamSx3("B8_PRODUTO")[1])
	cLoteCtl := Space(TamSx3("B8_LOTECTL")[1])
	cSubLote := Space(TamSx3("DCT_SUBLOT")[1])
	nQtde    := 0
	aProduto := CBRetEtiEAN(cCodBar)
	If Len(aProduto) > 0
		cProduto := aProduto[1]
		If __lCodBar .Or. _lCBRETEAN
			nQtde := aProduto[2]
		EndIf
		cLoteCtl := Padr(aProduto[3],TamSx3("B8_LOTECTL")[1])
	Else
		aProduto := CBRetEti(cCodBar, '01')
		If Len(aProduto) > 0
			cProduto := aProduto[1]
			nQtde    := aProduto[2]
			cLoteCtl := Padr(aProduto[16],TamSx3("B8_LOTECTL")[1])
			cSubLote := Padr(aProduto[17],TamSx3("DCT_SUBLOT")[1])
		EndIf
		If Empty(aProduto)
			WMSVTAviso(WMSV08125,STR0047) //Etiqueta invalida!
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
			WMSVTAviso(WMSV08126,STR0048) //Produto nao pertence a montagem de volumes do documento!
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. lEstorno
		// Parâmetro Where
		cWhere := "%"
		If !Empty(oMntVolItem:GetLoteCtl())
			cWhere += " AND DCT.DCT_LOTE   = '"+oMntVolItem:GetLoteCtl()+"'"
		EndIf
		If !Empty(oMntVolItem:GetNumLote())
			cWhere += " AND DCT.DCT_SUBLOT = '"+oMntVolItem:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		cAliasDCT := GetNextAlias()
		BeginSql Alias cAliasDCT
			SELECT COUNT(DCT.DCT_CODPRO) COUNTDCT
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CODMNT = %Exp:oMntVolItem:GetCodMnt()%
			AND DCT.DCT_CARGA = %Exp:oMntVolItem:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:oMntVolItem:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:oMntVolItem:GetProduto()%
			AND DCT.DCT_CODPRO <> DCT.DCT_PRDORI
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasDCT)->COUNTDCT > 1
			WMSVTAviso(WMSV08148,STR0071) // Para estorno informe o produto componente!
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		(cAliasDCT)->(dbCloseArea())
	EndIf
	If lRet
		// Carregar as quantidades para o produto
		oMntVolItem:QtdPrdVol(lEstorno)
		If !lEstorno
			//Deve validar se o produto possui quantidade para separada para ser embalada
			If QtdComp(oMntVolItem:GetQtdSep()) == 0
				WMSVTAviso(WMSV08127,STR0049) // "Produto não possui quantidade separada para montagem de volumes."
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
			//Deve validar se o produto possui quantidade para separada pendente para ser embalada
			If lRet .And. QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
				WMSVTAviso(WMSV08128,STR0050) // "Montagem de volumes do Produto finalizada."
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
			//Deve validar se o produto possui quantidade para separada pendente para ser embalada
			If lRet .And. QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
				WMSVTAviso(WMSV08128,STR0051) // "Produto não possui quantidade separada pendente para montagem de volumes."
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		Else
			//Deve validar se o produto possui quantidade para embalada para ser estornada
			If QtdComp(oMntVolItem:GetQtdEmb()) == 0
				WMSVTAviso(WMSV08138,STR0052) // "Produto não possui quantidade separada para montagem de volumes."
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
// Valida o produto/lote informado, verificando se o mesmo pertence ao pedido/carga
// Valida se o mesmo já foi separado e pode ser montado volume
//-----------------------------------------------------------------------------
Static Function ValLoteCtl(cLoteCtl,lEstorno)
Default lEstorno:= .F.

	If Empty(cLoteCtl)
		Return .F.
	EndIf
	oMntVolItem:SetLoteCtl(cLoteCtl)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol(lEstorno)
	If !lEstorno
		//Deve validar se o produto/lote possui quantidade para separada para ser embalada
		If QtdComp(oMntVolItem:GetQtdOri()) == 0
			WMSVTAviso(WMSV08129,STR0053) // "Produto/Lote não pertence a montagem de volumes do documento."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote possui quantidade para separada para ser embalada
		If QtdComp(oMntVolItem:GetQtdSep()) == 0
			WMSVTAviso(WMSV08130,STR0054) // "Produto/Lote não possui quantidade separada para montagem de volumes."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote já foi todo montado volume
		If QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08131,STR0055) // "Montagem de volumes do Produto/Lote finalizada."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote possui quantidade pendente para ser separada
		If QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08132,STR0056) //"Montagem de volumes do Produto/Lote da quantidade separada finalizada."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	Else
		//Deve validar se o produto possui quantidade para embalada para ser estornada
		If QtdComp(oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08139,STR0057) // "Produto/Lote não possui quantidade embalada no volume para estorno."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	EndIf
Return .T.

//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo pertence ao pedido/carga
// Valida se o mesmo já foi separado e pode ser montado volume
//-----------------------------------------------------------------------------
Static Function ValSubLote(cSubLote,lEstorno)
Default lEstorno:= .F.

	If Empty(cSubLote)
		Return .F.
	EndIf
	oMntVolItem:SetNumLote(cSubLote)
	// Carregar as quantidades para o produto
	oMntVolItem:QtdPrdVol(lEstorno)
	If !lEstorno
		//Deve validar se o produto/lote possui quantidade para separada para ser embalada
		If QtdComp(oMntVolItem:GetQtdOri()) == 0
			WMSVTAviso(WMSV08133,STR0058) // "Produto/Rastro não pertence a montagem de volumes do documento."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote possui quantidade para separada para ser embalada
		If QtdComp(oMntVolItem:GetQtdSep()) == 0
			WMSVTAviso(WMSV08134,STR0059) // "Produto/Rastro não possui quantidade separada para montagem de volumes."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote já foi todo montado volume
		If QtdComp(oMntVolItem:GetQtdOri()-oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08135,STR0060) // "Montagem de volumes do Produto/Rastro finalizada."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
		//Deve validar se o produto/lote possui quantidade pendente para ser separada
		If QtdComp(oMntVolItem:GetQtdSep()-oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08136,STR0061) //"Montagem de volumes do Produto/Rastro da quantidade separada finalizada."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	Else
		//Deve validar se o produto possui quantidade para embalada para ser estornada
		If QtdComp(oMntVolItem:GetQtdEmb()) == 0
			WMSVTAviso(WMSV08140,STR0062) // "Produto/Rastro não possui quantidade embalada no volume para estorno."
			VTKeyBoard(Chr(20))
			Return .F.
		EndIf
	EndIf
Return .T.
//-----------------------------------------------------------------------------
// Função para atribuir valor ao objeto estático
//-----------------------------------------------------------------------------
Static Function SetObj(oObj)
	oMntVolItem := oObj
Return

//-----------------------------------------------------------------------------
// Valida a quantidade informada efetuando a conversão das unidades de medida
//-----------------------------------------------------------------------------
Static Function ValQtdEmb(nQtde)
Local lRet := .T.
Local nQtdResVol := 0
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local lValDisSep := .T.
	If Empty(nQtde)
		Return .F.
	EndIf
	If lRet
		nQtdResVol := oMntVolItem:GetQtdSep() - oMntVolItem:GetQtdEmb()
		If QtdComp(nQtde) > QtdComp(nQtdResVol) .And.;
			QtdComp(Abs(nQtdResVol-nQtde)) > QtdComp(nToler1UM)
			WmsMessage(WmsFmtMsg(STR0063,{{"[VAR01]",oMntVolItem:GetProduto()}}),WMSV08137) //"Quantidade em volumes mais informada ultrapassa a quantidade separada do produto [VAR01]."
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
	If lWmsNew
		// Verifica se produto controla lote e não obriga a informação no processo WMS
		// Caso não obrigue não irá realizar as validações referente a quantidade distribuida de separação se houver
		If lRet .And. Rastro(oMntVolItem:GetProduto()) .And. !__lHasLot
			lValDisSep := .F.
		EndIf
		If lRet .And. lValDisSep .And. !WMA391AQTD(oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),oMntVolItem:GetPrdOri(),oMntVolItem:GetProduto(),oMntVolItem:GetLoteCtl(),oMntVolItem:GetNumLote(),nQtde)
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
// WMSV081Vol
// Tela para informar novo volume
//
// nOpc     Opção de montagem de volume:
// 			1 - Por carga/pedido
// 			2 - Por pedido
// cCarga   Número da carga
// cPedido  Número do pedido
// cVolume  Variável contendo o código do volume antigo,
//          receberá o novo código de volume por referência
//          se o mesmo for válido
//----------------------------------------------------------
Static Function WMSV081Vol(nOpc,cVolume)
Local ckey05   := VTDescKey(05)
Local ckey22   := VTDescKey(22)
Local ckey24   := VTDescKey(24)
Local bkey05   := VTSetKey(05)
Local bkey22   := VTSetKey(22)
Local bkey24   := VTSetKey(24)
Local aTela    := VtSave()
Local lRet     := .T.
Local cRetPE   := ""
Local cVolAux  := Space(TamSx3("DCU_CODVOL")[1])
	// PE para controle de geração do código dos volumes
	If _lWV080CDV
		cRetPE := ExecBlock('WV080CDV',.F.,.F.,{oMntVolItem:GetCarga(),oMntVolItem:GetPedido()})
		If ValType(cRetPE) == 'C'
			cVolAux  := cRetPE
		EndIf
	EndIf
	// Geração automática do código dos volumes (não solicita)
	If __lVolAuto
		cVolAux := Padl(CBProxCod('MV_WMSNVOL'),10,'0')
	EndIf

	If Empty(cVolAux)
		VtClear()
		WMSVTCabec(STR0005, .F., .F., .T.) // Montagem Volume
		@ 01,00 VTSay Iif(nOpc == 1,STR0006+'/'+STR0007,STR0007) // Carga/Pedido // Pedido
		@ 02,00 VTSay Iif(nOpc == 1,oMntVolItem:GetCarga()+'/'+oMntVolItem:GetPedido(),oMntVolItem:GetPedido())
		@ 03,00 VtSay STR0018 // Informe o Volume
		@ 04,00 VtGet cVolAux Picture '@!' Valid Iif(!Empty(cVolAux),WMSV081VlV(cVolAux,oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),""),.F.)
		VtRead()

		VtRestore(,,,,aTela)

		If VtLastkey() == 27
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If __lVolAuto
			WMSVTAviso(STR0005, "Novo volume gerado:"+ cVolAux) // Novo volume gerado:
		EndIf
		cVolume := cVolAux
		@ 01,00 VTSay PadR(STR0008 + ': ' + cVolume,VTMaxCol()) // Volume
		oMntVolItem:oVolume:SetCodVol(cVolume)
		If !oMntVolItem:oVolume:LoadData()
			oMntVolItem:oVolume:SetDtIni(dDataBase)
			oMntVolItem:oVolume:SetHrIni(Time())
		EndIf
		// Anula data e hora final para forçar gravar atualizado
		oMntVolItem:oVolume:SetDtFim(StoD(""))
		oMntVolItem:oVolume:SetHrFim("")
	EndIf
	// Restaura Tecla
	VTSetKey(05,bKey05, cKey05)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(24,bKey24, cKey24)

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSV081VlV
Validação do volume

@param   cVolume     Código do volume
@param   cCarga      Número da carga
@param   cPedido     Número do pedido

@version	P11
@since   09/10/06 - revisão 19/05/14
/*/
//----------------------------------------------------------
Function WMSV081VlV(cVolume,cCarga,cPedido,cArmazem,cEndereco,cServico)
Local lRet      := .T.
Local lRetPE    := .F.
Local lWmsDaEn  := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Descarga apenas considerando o endereço sem o armazém
Local aAreaAnt  := GetArea()
Local oMntVol   := WMSDTCMontagemVolume():New()
Local cAliasQry := Nil
Local cAliasDC5 := Nil
Local cAliasDCU := Nil
Local cAliasD02 := Nil
Local cMntExcAnt:= ""
Local cMntExcAtu:= ""

Default cArmazem  := ""
Default cEndereco := ""
DeFault cServico  := "" //Quando vazio, posterior a separacao

	cPedido := PadR(cPedido,TamSx3("C9_PEDIDO")[1])
	If Len(AllTrim(cVolume)) != TamSx3("DCU_CODVOL")[1]
		WMSVTAviso(WMSV08122,STR0043) // "Tamanho do codigo do volume invalido!"
		lRet := .F.
	EndIf
	// Verifica se existem caracteres especiais
	If lRet .And. !WmsVlStr(cVolume)
		lRet := .F.
	EndIf

	//Regra de apenas um volume por pedido por causa da conferencia DLOGWMSMSP-17359
	If lRet .And. !Empty(cServico)
		cAliasDC5 := GetNextAlias()
		BeginSql Alias cAliasDC5
			SELECT DC5.DC5_SERVIC FROM %Table:DC5% DC5
				WHERE DC5.DC5_FILIAL = %xFilial:DC5%
				AND DC5.DC5_SERVIC = %Exp:cServico%
				AND DC5.DC5_TIPO   = '2' //Saida
				AND DC5.DC5_COFEXP = '1' //Conferencia Expedicao Sim
				AND DC5.DC5_MNTVOL = '1' //Montagem de volume durante a separacao
				AND DC5.DC5_OPERAC = '3' //Separacao
				AND DC5.%NotDel%
		EndSql
		If (cAliasDC5)->(!Eof())
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DCV_PEDIDO
				FROM %Table:DCV% DCV
				WHERE DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = %Exp:cVolume%
				AND DCV.DCV_PEDIDO <> %Exp:cPedido%
				AND DCV.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				WMSVTAviso(WMSV08152, STR0076 + (cAliasQry)->DCV_PEDIDO+".") // "Volume já informado no pedido "
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
		(cAliasDC5)->(DbCloseArea())
	EndIf

	If lRet .And. AliasInDic("D0N")
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:D0N% D0N
			WHERE D0N.D0N_FILIAL = %xFilial:D0N%
			AND D0N.D0N_CODVOL = %Exp:cVolume%
			AND D0N.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			WMSVTAviso(WMSV08149, STR0072) // O volume informado pertence a uma montagem de volume cross-docking.
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If lRet
		//Verifica se o volume já está vinculado a um romaneio de embarque
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCU.DCU_ROMEMB
			FROM %Table:DCU% DCU
			WHERE DCU.DCU_FILIAL = %xFilial:DCU% 
			AND DCU.DCU_CODVOL  = %Exp:cVolume%
			AND DCU.DCU_ROMEMB <> ' '
			AND DCU.%NotDel%
		EndSql
		If (cAliasQry)->(!EoF())
			WMSVTAviso(WMSV08150, WmsFmtMsg(STR0073,{{"[VAR01]",(cAliasQry)->DCU_ROMEMB}})) // O volume encontra-se vinculado ao romaneio de embarque [VAR01]. Não permitida a inclusão de novos produtos.
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If lRet
		//Verifica se existe conferência de expedição para aquele pedido
		cAliasD02 := GetNextAlias()
		BeginSql Alias cAliasD02
			SELECT 1
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CARGA  = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_STATUS <> '3'
			AND D02.%NotDel%
		EndSql
		//Se o pedido possui conferência de expedição pendente verifica se o volume já encontra-se conferido e não permite incluir o pedido no volume
		If (cAliasD02)->(!Eof())
			cAliasDCU := GetNextAlias()
			BeginSql Alias cAliasDCU
				SELECT 1
				FROM %Table:DCU% DCU
				WHERE DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CODVOL = %Exp:cVolume%
				AND DCU.DCU_STCONF = '2' //Conferido
				AND DCU.%NotDel%
			EndSql
			If (cAliasDCU)->(!Eof())
				lRet := .F.
				WMSVTAviso(WMSV08143,STR0065) //Volume esta conferido.
			EndIf
		EndIf
	EndIf
	If lRet
		// Verifica se a montagem de volume é exclusiva com base na primeira DCV encontrada
		// Caso ainda não exista, utiliza as informações da DCS do volume informado.
		oMntVol:SetCarga(cCarga)
		oMntVol:SetPedido(cPedido)
		oMntVol:SetCodMnt(oMntVol:FindCodMnt())
		oMntVol:LoadData()
		cMntExcAtu := IIf(!Empty(oMntVol:GetMntExc()),oMntVol:GetMntExc(),'3')
		//Verifica se a montagem de volume é exclusiva
		DCU->(dbSetOrder(1))
		If DCU->(dbSeek(xFilial('DCU')+cVolume))
			oMntVol:SetCarga(DCU->DCU_CARGA)
			oMntVol:SetPedido(DCU->DCU_PEDIDO)
			oMntVol:SetCodMnt(oMntVol:FindCodMnt())
			oMntVol:LoadData()
			cMntExcAnt := IIf(!Empty(oMntVol:GetMntExc()),oMntVol:GetMntExc(),'3')
			If cMntExcAnt != cMntExcAtu
				WMSVTAviso(WMSV08145,STR0068) // Regra de excessão do volume utilizado diferente do pedido informado! Utilize outro volume.
				VTClearBuffer()
				lRet := .F.
			ElseIf cMntExcAtu == '1' .And. (!(cCarga == DCU->DCU_CARGA) .Or. (Empty(cCarga) .And. !(cPedido == DCU->DCU_PEDIDO)))
				WMSVTAviso(WMSV08118,STR0019+" "+Iif(!Empty(DCU->DCU_CARGA), STR0006+"/"+STR0007+" "+DCU->DCU_CARGA+'/'+DCU->DCU_PEDIDO,STR0007+" "+DCU->DCU_PEDIDO)) // Este volume está sendo utilizado por: Carga/Pedido "#"
				VTClearBuffer()
				lRet := .F.
			ElseIf cMntExcAtu == '2' .And. !(cPedido == DCU->DCU_PEDIDO)
				WMSVTAviso(WMSV08119,STR0019+" "+STR0007+" "+DCU->DCU_PEDIDO) // Este volume está sendo utilizado por: Pedido
				VTClearBuffer()
				lRet := .F.
			ElseIf cMntExcAtu == '3'
				If !(DCU->(DCU_CARGA+DCU_PEDIDO) == (cCarga+cPedido))
					If !WMSV081CLI(cPedido,DCU->DCU_PEDIDO) // só é permitido em um mesmo volume pedidos diferentes desde que seja para o mesmo cliente/loja
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DCV% DCV
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
			AND SC9.C9_ITEM = DCV.DCV_ITEM
			AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
			AND SC9.C9_NFISCAL <> '  '
			AND SC9.%NotDel%
			WHERE DCV.DCV_FILIAL = %xFilial:SC9%
			AND DCV.DCV_CODVOL = %Exp:cVolume%
			AND DCV.%NotDel%
		EndSql
		If (cAliasQry)->(!EoF())
			WMSVTAviso(WMSV08144,STR0067) // O volume possui itens já faturados.
			VTClearBuffer()
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())

		// Se foi informado o endereço deve validar se existem itens no volume que já estão em outro endereço
		If lRet .And. !Empty(cArmazem+cEndereco)
			cAliasQry := GetNextAlias()
			If !lWmsDaEn
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:DCV% DCV
					INNER JOIN %Table:SC9% SC9
					ON SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
					AND SC9.C9_ITEM = DCV.DCV_ITEM
					AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
					AND ((SC9.C9_LOCAL <> %Exp:cArmazem% )
						OR (SC9.C9_LOCAL = %Exp:cArmazem%
						AND SC9.C9_ENDPAD <> %Exp:cEndereco% ))
					AND SC9.%NotDel%
					WHERE DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_CODVOL = %Exp:cVolume%
					AND DCV.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:DCV% DCV
					INNER JOIN %Table:SC9% SC9
					ON SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
					AND SC9.C9_ITEM = DCV.DCV_ITEM
					AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
					AND SC9.C9_ENDPAD <> %Exp:cEndereco%
					AND SC9.%NotDel%
					WHERE DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_CODVOL = %Exp:cVolume%
					AND DCV.%NotDel%
				EndSql
			EndIf
			If (cAliasQry)->(!Eof())
				WMSVTAviso(WMSV08124,STR0046) // "Volume possui itens com endereço destino diferente."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		// Ponto de entrada para validação do volume
		If lRet .And. ExistBlock("WMSV081V")
			lRetPE := ExecBlock("WMSV081V",.F.,.F.,{cVolume,cCarga,cPedido,cArmazem,cEndereco})
			If ValType(lRetPE) == 'L'
				lRet := lRetPE
			EndIf
		EndIf
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
// EstVolume
// Tela para estorno de um produto do volume
//
// cCarga   Número da carga
// cPedido  Número do pedido
// cVolume  Código do volume
//----------------------------------------------------------
Static Function EstVolume(nOpc,cCarga,cPedido)
Local ckey05     := VTDescKey(05)
Local ckey09     := VTDescKey(09)
Local ckey22     := VTDescKey(22)
Local ckey24     := VTDescKey(24)
Local bkey05     := VTSetKey(05)
Local bkey09     := VTSetKey(09)
Local bkey22     := VTSetKey(22)
Local bkey24     := VTSetKey(24)
Local aTela      := VTSave()
Local cCodBar    := Space(128)
Local cProduto   := Space(TamSx3("DCV_CODPRO")[1])
Local cLoteCtl   := Space(TamSx3("DCT_LOTE")[1])
Local cSubLote   := Space(TamSx3("DCT_SUBLOT")[1])
Local cVolume    := Space(TamSx3("DCU_CODVOL")[1])
Local nQtde      := 0
Local nProxLin   := 2
Local lQtdDig  := .T.
Local nI         := 0
Local aProdutos  := {}
Local lRet       := .T.
Local lEsc       := .F.
Local cCodVolAnt := oMntVolItem:oVolume:GetCodVol()
Local cPrdOriAnt := oMntVolItem:GetPrdOri()
Local cProdutAnt := oMntVolItem:GetProduto()
Local cLoteCtAnt := oMntVolItem:GetLoteCtl()
Local cNumLotAnt := oMntVolItem:GetNumLote()
Local nQtdOriAnt := oMntVolItem:GetQtdOri()
Local nQtdSepAnt := oMntVolItem:GetQtdSep()
Local nQtdEmbAnt := oMntVolItem:GetQtdEmb()

	VtClear()
	VTClearBuffer()

	If Empty(cCarga+cPedido)
		WMSVTCabec(STR0010, .F., .F., .T.) // Estorno Mont. Volume
		If nOpc == 1
			@ nProxLin++, 00 VTSay PadR(STR0006, VTMaxCol()) // Carga
			@ nProxLin++, 00 VTGet cCarga Valid !Empty(cCarga) .And. ValCarPed(1,cCarga,,.T.)
		EndIf
		@ nProxLin++, 00 VTSay PadR(STR0007, VTMaxCol()) // Pedido
		@ nProxLin++, 00 VTGet cPedido Valid !Empty(cPedido) .And. ValCarPed(2,cCarga,cPedido,.T.)
		VTRead()
		If VtLastKey() == 27
			lEsc := .T.
		EndIf
	EndIf
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
		nProxLin := 1

		cCodBar  := Space(128)
		cProduto := Space(TamSx3("DCV_CODPRO")[1])
		cLoteCtl := Space(TamSx3("DCT_LOTE")[1])
		cSubLote := Space(TamSx3("DCT_SUBLOT")[1])
		cVolume  := Space(TamSx3("DCU_CODVOL")[1])

		WMSVTCabec(STR0010, .F., .F., .T.) // Estorno Mont. Volume
		@ nProxLin++,00 VTSay Iif(nOpc == 1,STR0006+'/'+STR0007,STR0007) // Carga/Pedido // Pedido
		@ nProxLin++,00 VTSay Iif(nOpc == 1,oMntVolItem:GetCarga()+'/'+oMntVolItem:GetPedido(),oMntVolItem:GetPedido())
		@ nProxLin++,00 VtSay STR0018 // Informe o Volume
		@ nProxLin++,00 VtGet cVolume Picture '@!' Valid !Empty(cVolume) .And. VldVolConf(cVolume)
		VtRead()
		If VtLastKey() == 27
			lEsc := .T.
			Exit
		EndIf
		VTCLear()
		nProxLin := 1
		WMSVTCabec(STR0010, .F., .F., .T.) // Estorno Mont. Volume
		@ nProxLin++,00 VTSay PadR(STR0008 + ': ' + cVolume,VTMaxCol()) // Volume
		@ nProxLin++,00 VTSay STR0012 // Produto
		@ nProxLin++,00 VtGet cCodBar Pict "@!" Valid ValPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar,.T.)
		VtRead()
		If VTLastKey() != 27
			If __lHasLot .And. Rastro(cProduto)
				@ nProxLin,   00 VTSay PadR(STR0013, VTMaxCol()) // Lote:
				@ nProxLin++, 06 VTGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cLoteCtl,.T.)
				If Rastro(cProduto,"S")
					@ nProxLin,   00 VTSay PadR(STR0014, VTMaxCol()) // Sub-Lote:
					@ nProxLin++, 10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cSubLote,.T.)
				EndIf
			EndIf
			Do While .T.
				lQtdDig := Empty(nQtde) // Indicador de que a quantidade foi digitada pelo usuário
				@ nProxLin++,00 VTSay STR0011 //Qtde
				@ nProxLin++,00 VTGet nQtde Pict "@E 99,999,999.99" When VTLastKey()==05 .Or. Empty(nQtde) Valid !Empty(nQtde)
				VTRead()
				If VTLastKey() == 27
					lEsc := .T.
					Exit // Sai da rotina de estorno
				EndIf
				If !ValQtdEst(cVolume,nQtde)
					nQtde    := 0
					nProxLin -= 2
					// Caso a quantidade não tenha sido digitada pelo usuário, volta para o produto
					If lQtdDig
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			// Deve carregar as informações dos produtos a serem estornados
			// Não pode gravar diretamente o produto do objeto, pois quando
			// o produto possui lote, porém não solicita o lote no coletor
			// pode ser que tenha mais de um produto/lote apto a ser estornado
			// do volume de acordo com a quantidade informada
			aProdutos := {}
			If nQtde > 0 .And. LoadPrdEst(aProdutos,cVolume,nQtde)
				Begin Transaction
					For nI := 1 To Len(aProdutos)
						WmA391GrvE(3,oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),cVolume,aProdutos[nI][5],aProdutos[nI][1],aProdutos[nI][2],aProdutos[nI][3],oMntVolItem:GetCodMnt(),aProdutos[nI][4],,oMntVolItem:oMntVol:GetLibPed())
					Next nI
				End Transaction
			EndIf
		EndIf
		//Limpa variáveis
		cCarga  := Space(TamSx3("DCS_CARGA")[1])
		cPedido := Space(TamSx3("DCS_PEDIDO")[1])
		cVolume := Space(TamSx3("DCU_CODVOL")[1])
	EndDo
	VTClearBuffer()
	
	oMntVolItem:oVolume:SetCodVol(cCodVolAnt)
	oMntVolItem:SetPrdOri(cPrdOriAnt)
	oMntVolItem:SetProduto(cProdutAnt)
	oMntVolItem:SetLoteCtl(cLoteCtAnt)
	oMntVolItem:SetNumLote(cNumLotAnt)
	oMntVolItem:SetQtdOri(nQtdOriAnt)
	oMntVolItem:SetQtdSep(nQtdSepAnt)
	oMntVolItem:SetQtdEmb(nQtdEmbAnt)
	
	VtRestore(,,,,aTela)
	VTSetKey(05,bKey05, cKey05)
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(24,bKey24, cKey24)
Return
//-----------------------------------------------------------------------------
// Valida a quantidade informada verificando se a mesma pode ser estornada
//-----------------------------------------------------------------------------
Static Function ValQtdEst(cVolume,nQtde)
Local lRet      := .T.
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
	If Empty(nQtde)
		lRet := .F.
	EndIf
	If lRet .And. !VldVolFat(cVolume)
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet
		If QtdComp(nQtde) > QtdComp(oMntVolItem:GetQtdEmb()) .And.;
			QtdComp(Abs(oMntVolItem:GetQtdEmb()-nQtde)) > QtdComp(nToler1UM)
			WMSVTAviso(WMSV08120,WmsFmtMsg(STR0041,{{"[VAR01]",oMntVolItem:GetProduto()},{"[VAR02]",Str(oMntVolItem:GetQtdEmb())}})) // Quantidade de estorno do produto [VAR01] ultrapassa a contagem de [VAR02].
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------------------------------
// Valida se o volume não se encontra faturado, neste caso não pode estornar
//-----------------------------------------------------------------------------
Static Function VldVolFat(cVolume)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Local cWhere    := ""

	cWhere := "%"
	If !Empty(oMntVolItem:GetLoteCtl())
		cWhere += " AND DCV.DCV_LOTE   = '"+oMntVolItem:GetLoteCtl()+"'"
	EndIf
	If !Empty(oMntVolItem:GetNumLote())
		cWhere += " AND DCV.DCV_SUBLOT = '"+oMntVolItem:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:DCV% DCV
		INNER JOIN %Table:SC9% SC9
		ON SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
		AND SC9.C9_ITEM = DCV.DCV_ITEM
		AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
		AND SC9.C9_NFISCAL <> ' '
		AND SC9.%NotDel%
		WHERE DCV.DCV_FILIAL = %xFilial:D0E%
		AND DCV.DCV_CODVOL = %Exp:cVolume%
		AND DCV.DCV_CODMNT = %Exp:oMntVolItem:GetCodMnt()%
		AND DCV.DCV_CARGA = %Exp:oMntVolItem:GetCarga()%
		AND DCV.DCV_PEDIDO = %Exp:oMntVolItem:GetPedido()%
		AND DCV.DCV_PRDORI = %Exp:oMntVolItem:GetPrdOri()%
		AND DCV.DCV_CODPRO = %Exp:oMntVolItem:GetProduto()%
		AND DCV.D_E_L_E_T_ = ' '"
		%Exp:cWhere%
	EndSql
	If (cAliasQry)->(!Eof())
		// Força recarregar os dados da capa da montagem
		oMntVolItem:oMntVol:LoadData()
		If oMntVolItem:oMntVol:GetLibEst() == "2"
			WMSVTAviso(WMSV08112,STR0026) // O Item do volume não foi estornado, pois já está faturado!
			lRet := .F.
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
// Valida se o volume não se encontra faturado, neste caso não pode estornar
//-----------------------------------------------------------------------------
Static Function VldVolConf(cVolume)
Local lRet      := .T.

	oMntVolItem:oVolume:SetCodVol(cVolume)
	If oMntVolItem:oVolume:LoadData()
		If !WMSA391VIC(oMntVolItem:GetCodMnt(),oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),cVolume)
			WMSVTAviso(WMSV08123,STR0066) // Volume possui conferência de expedição, primeiro estorne a conferência.
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV08147,STR0070) //Volume inválido!
		lRet := .F.
	EndIf
Return lRet
//-----------------------------------------------------------------------------
// Carrega as quantidades a serem montadas volumes de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor
//-----------------------------------------------------------------------------
Static Function LoadPrdEst(aProdutos,cVolume,nQtde)
Local aAreaAnt  := GetArea()
Local aTamDCV   := TamSx3('DCV_QUANT')
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nQtdPrd   := 0

Default nQtde := 0
	// Esta query deve ordenar primeiro os produtos filhos quando possuir
	// pois neste caso o produto pai não poderá ser considerado e deverá ser descartado ficando por ultimo
	cWhere := "%"
	If !Empty(oMntVolItem:GetLoteCtl())
		cWhere += " AND DCV.DCV_LOTE   = '"+oMntVolItem:GetLoteCtl()+"'"
	EndIf
	If !Empty(oMntVolItem:GetNumLote())
		cWhere += " AND DCV.DCV_SUBLOT = '"+oMntVolItem:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT DCV.DCV_LOTE,
				DCV.DCV_SUBLOT,
				SUM(DCV_QUANT) DCV_QUANT
		FROM %Table:DCV% DCV
		WHERE DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_CODVOL = %Exp:cVolume%
		AND DCV.DCV_CODMNT = %Exp:oMntVolItem:GetCodMnt()%
		AND DCV.DCV_CARGA = %Exp:oMntVolItem:GetCarga()%
		AND DCV.DCV_PEDIDO = %Exp:oMntVolItem:GetPedido()%
		AND DCV.DCV_PRDORI = %Exp:oMntVolItem:GetPrdOri()%
		AND DCV.DCV_CODPRO = %Exp:oMntVolItem:GetProduto()%
		AND DCV.%NotDel%
		%Exp:cWhere%
		GROUP BY DCV.DCV_LOTE,
					DCV.DCV_SUBLOT
		ORDER BY DCV.DCV_LOTE,
					DCV.DCV_SUBLOT
	EndSql
	TcSetField(cAliasQry,'DCV_QUANT','N',aTamDCV[1],aTamDCV[2])
	Do While (cAliasQry)->(!Eof())
		// Calcula a quantidade que pode ser "rateada" para este produto
		If QtdComp(nQtde) > QtdComp((cAliasQry)->DCV_QUANT)
			nQtdPrd := (cAliasQry)->DCV_QUANT
			nQtde   -= (cAliasQry)->DCV_QUANT
		Else
			nQtdPrd := nQtde
			nQtde   := 0
		EndIf
		// Adiciona o produto no array de produtos a serem estornados do volume
		AAdd(aProdutos, {oMntVolItem:GetProduto(), (cAliasQry)->DCV_LOTE, (cAliasQry)->DCV_SUBLOT, nQtdPrd, oMntVolItem:GetPrdOri()})
		// Se zerou a quantidade, deve sair
		If QtdComp(nQtde) == 0
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return .T.
//----------------------------------------------------------
// WMSV081Inf
// Tela de informações da montagem de volume
//----------------------------------------------------------
Static Function WMSV081Inf(nOpc)
Local ckey05   := VTDescKey(05)
Local ckey09   := VTDescKey(09)
Local ckey22   := VTDescKey(22)
Local ckey24   := VTDescKey(24)
Local bkey05   := VTSetKey(05) // Ctrl+E
Local bkey09   := VTSetKey(09)
Local bkey22   := VTSetKey(22)
Local bkey24   := VTSetKey(24)
Local aSave    := VTSave()
Local aTemp    := {}
Local aTemp2   := {}
Local nPos     := 1
Local nPos2    := 1

	aTemp := WMSV081Lb1()
	Do While .T.
		VtClear()
		WMSVTCabec(Iif(nOpc == 1, /*STR0045+'/'+STR0046+' '+*/ oMntVolItem:GetCarga()+'/'+oMntVolItem:GetPedido(), /*STR0046+' '+*/oMntVolItem:GetPedido()), .F., .F., .T.)
		nPos := VTaBrowse(1,,,,{STR0008,STR0031},aTemp,{10,15},,nPos)  // Volume // Operador
		If VTLastkey() == 27
			Exit
		EndIf

		aTemp2:= WMSV081Lb2(aTemp[nPos,1])
		WMSVTCabec(STR0032 + aTemp[nPos,1], .F., .F., .T.) // Vol. "
		nPos2 := VTaBrowse(1,,,,{STR0012,STR0033,STR0034,STR0034},aTemp2,{15,15,20,20},,nPos2) // Produto // Qtde. // Descrição // Descrição
	EndDo
	VtRestore(,,,,aSave)
	// Restaura Tecla
	VTSetKey(05,bKey05, cKey05)
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(24,bKey24, cKey24)
Return Nil
//----------------------------------------------------------
// WMSV081Lb1
// Carrega em um array os volumes e operadores da carga/pedido, ou
// somente do pedido, dependendo da forma como está sendo montado o volume
//----------------------------------------------------------
Static Function WMSV081Lb1()
Local aLbx1     := {}
Local cAliasDCV := Nil
	cAliasDCV := GetNextAlias()
	BeginSql Alias cAliasDCV
		SELECT DCV.DCV_CODVOL,
				DCD.DCD_NOMFUN
		FROM %Table:DCV% DCV
		INNER JOIN %Table:DCD% DCD
		ON DCD.DCD_FILIAL = %xFilial:DCD%
		AND DCD.DCD_CODFUN = DCV.DCV_CODOPE
		AND DCD.%NotDel%
		WHERE DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_CODMNT = %Exp:oMntVolItem:GetCodMnt()%
		AND DCV.DCV_CARGA = %Exp:oMntVolItem:GetCarga()%
		AND DCV.DCV_PEDIDO = %Exp:oMntVolItem:GetPedido()%
		AND DCV.%NotDel%
	EndSql
	Do While (cAliasDCV)->(!Eof())
		If aScan(aLbx1, {|x| x[1]+x[2] == (cAliasDCV)->DCV_CODVOL+(cAliasDCV)->DCD_NOMFUN}) == 0
			AAdd(aLbx1,{(cAliasDCV)->DCV_CODVOL,(cAliasDCV)->DCD_NOMFUN})
		EndIf
		(cAliasDCV)->(dbSkip())
	EndDo
	(cAliasDCV)->(dbCloseArea())
	If Empty(aLbx1)
		aLbx1:= {{Space(15),Space(20)}}
	EndIf
Return aLbx1
//----------------------------------------------------------
// WMSV081Lb2
// Carrega em um array os produtos, quantidades e a descrição
// dos produtos contidos em um volume
//----------------------------------------------------------
Static Function WMSV081Lb2(cVolume)
Local aLbx2     := {}
Local cAliasDCV := Nil
	cAliasDCV := GetNextAlias()
	BeginSql Alias cAliasDCV
		SELECT DCV.DCV_CODPRO,
				DCV.DCV_CARGA,
				DCV.DCV_PEDIDO,
				DCV.DCV_QUANT
		FROM %Table:DCV% DCV
		WHERE DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_CODVOL = %Exp:cVolume%
		AND DCV.%NotDel%
	EndSql
	Do While (cAliasDCV)->(!Eof())
		SB1->(dbSeek(xFilial('SB1')+(cAliasDCV)->DCV_CODPRO))

		aAdd(aLbx2,{(cAliasDCV)->DCV_CODPRO,;
						Str((cAliasDCV)->DCV_QUANT,15,2),;
						Subs(SB1->B1_DESC,01,20),;
						Subs(SB1->B1_DESC,21,20)})
		(cAliasDCV)->(dbSkip())
	EndDo
	If Empty(aLbx2)
		aLbx2:= {{Space(15),0,"",""}}
	EndIf
Return aLbx2
//----------------------------------------------------------
// WMV081Fina
// Apresenta o status referente à montagem de volumes de uma
// carga/pedido quando chega ao final do processo ou quando o
// usuário pressiona a tecla ESC
//
// nOpc     Opção de montagem de volume:
// 			1 - Por carga/pedido
// 			2 - Por pedido
// cCarga   Número da carga
// cPedido  Número do pedido
//----------------------------------------------------------
Function WMV081Fina(nOpc,cCarga,cPedido,cCodMnt,lMostra,lSolImp)
Default cCarga  := Space(TamSx3("DCS_CARGA")[1])
Default lMostra := .T.
Default lSolImp := .T.

	// Força atualizar os dados neste objeto, pois é chamado
	// pela montagem de volume via coletor durante a separação
	oMntVolItem:oMntVol:SetCarga(cCarga)
	oMntVolItem:oMntVol:SetPedido(cPedido)
	oMntVolItem:oMntVol:SetCodMnt(cCodMnt)
	If oMntVolItem:oMntVol:LoadData()
		If oMntVolItem:oMntVol:GetStatus() == "3"
			VTClear()
			If lMostra
				WMSVTCabec(STR0005, .F., .F., .T.) // Montagem Volume
				@ 01,00 VTSay PadR(STR0035, VTMaxCol()) // Finalizado // Em Andamento
				@ 02,00 VTSay Replicate("-",VTMaxCol())
				If nOpc == 1
					@ 04,00 VTSay STR0006+'..: '+cCarga // Carga..:
					@ 05,00 VTSay STR0007+': '+cPedido // Pedido:
					@ 06,00 VTSay Replicate("-",VTMaxCol())
				Else
					@ 04,00 VTSay STR0007+': '+cPedido // Pedido:
					@ 05,00 VTSay Replicate("-",VTMaxCol())
				EndIf
				WMSVTRodPe()
			EndIf
			// Pergunta se será feita a impressão da Etiqueta
			If lSolImp .And. WMSVTAviso(WMSV08115,IIf(lMostra,STR0037,WmsFmtMsg(STR0045,{{"[VAR01]",cPedido}})),{STR0028,STR0029},/*lWait*/,/*nItemIni*/) == 1 // Deseja imprimir as etiquetas de Volume? // Deseja imprimir as etiquetas de volume do pedido [VAR01]? // Sim // Não
				WMSV081Eti()
			EndIf
		EndIf
	EndIf
Return
//-----------------------------------------------
// Valida se os pedidos são do mesmo cliente/loja
//-----------------------------------------------
Function WMSV081CLI(cPedido1,cPedido2,lShowMsg,cCliente,cLoja)
Local lRet      := .T.
Local aAreaSC5  := SC5->(GetArea())
Local cAliasSC5 := Nil
Local cCliLoja1 := ""
Local cCliLoja2 := ""

Default lShowMsg := .T.

	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
		SELECT SC5.C5_CLIENTE,
				SC5.C5_LOJACLI
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %xFilial:SC5%
		AND SC5.C5_NUM = %Exp:cPedido1%
		AND SC5.%NotDel%
	EndSql
	If (cAliasSC5)->(!Eof())
		cCliente := (cAliasSC5)->C5_CLIENTE
		cLoja := (cAliasSC5)->C5_LOJACLI
		cCliLoja1 := cCliente+cLoja
	EndIf
	(cAliasSC5)->(dbCloseArea())
	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
		SELECT SC5.C5_CLIENTE,
				SC5.C5_LOJACLI
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %xFilial:SC5%
		AND SC5.C5_NUM = %Exp:cPedido2%
		AND SC5.%NotDel%
	EndSql
	If (cAliasSC5)->(!Eof())
		cCliente := (cAliasSC5)->C5_CLIENTE
		cLoja := (cAliasSC5)->C5_LOJACLI
		cCliLoja2 := cCliente+cLoja
	EndIf
	(cAliasSC5)->(dbCloseArea())
	If !Empty(cCliLoja1) .And. !Empty(cCliLoja2)
		If !(lRet := (cCliLoja1 == cCliLoja2))
			If lShowMsg
				WMSVTAviso(WMSV08107,WmsFmtMsg(STR0020,{{"[VAR01]",cCliente},{"[VAR02]",cLoja},{"[VAR03]", Iif(!Empty(DCU->DCU_CARGA),DCU->DCU_CARGA+'/'+DCU->DCU_PEDIDO,DCU->DCU_PEDIDO) }})) // "Este volume está sendo utilizado pelo Cliente:[VAR01] Loja:[VAR02] Carga/Pedido:[VAR03]"
				VTClearBuffer()
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC5)
Return lRet
//----------------------------------------------------------
// WMSV081Eti
// Imprime etiqueta volume
//----------------------------------------------------------
Static Function WMSV081Eti(lPedido)
Local lRet      := .T.
Local bkey22    := VTSetKey(22)
Local bkey24    := VTSetKey(24)
Local aTela     := VtSave()
Local aItens    := {}
Local cAliasDCV := Nil
Local cLocImp   := Space(TamSX3("CB5_CODIGO")[01])
Local ckey22    := VTDescKey(22)
Local ckey24    := VTDescKey(24)
Local cMntVol   := oMntVolItem:GetCodMnt()
Local cCarga    := oMntVolItem:GetCarga()
Local cPedido   := oMntVolItem:GetPedido()
Local cVolume   := oMntVolItem:oVolume:GetCodVol()

Default lPedido := .T.

	// Caminho da impressão
	If Empty(SuperGetMV("MV_WMSLOCI",.F.,""))
		VtClear()
		@ 00,00 VtSay STR0038 // Informe o local
		@ 01,00 VtSay STR0039 // de Impressao:"
		@ 02,00 VtGet cLocImp Picture "@!"
		VtRead()

		If VtLastkey() == 27
			lRet := .F.
		EndIf
		If lRet
			If !CB5SetImp(cLocImp,IsTelNet())
				WMSVTAviso(WMSV08116,STR0040) // Local de impressao invalido!"
				lRet := .F.
			EndIf
		EndIf
	ElseIf !CB5SetImp(CBRLocImp("MV_WMSLOCI"),IsTelNet())
		WMSVTAviso(WMSV08117,STR0040) // Local de impressao invalido!"
		lRet := .F.
	EndIf
	If lRet
		cAliasDCV := GetNextAlias()
		If lPedido
			BeginSql Alias cAliasDCV
				SELECT DCV.DCV_CODPRO,
						DCV.DCV_LOTE,
						DCV.DCV_SUBLOT,
						DCV.DCV_QUANT,
						DCV.DCV_CARGA,
						DCV.DCV_PEDIDO,
						DCV.DCV_CODVOL,
						SC9.C9_CLIENTE,
						SC9.C9_LOJA
				FROM %Table:DCV% DCV
				INNER JOIN %Table:DCU% DCU
				ON DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CARGA = DCV.DCV_CARGA
				AND DCU.DCU_PEDIDO = DCV.DCV_PEDIDO
				AND DCU.DCU_CODMNT = DCV.DCV_CODMNT
				AND DCU.DCU_CODVOL = DCV.DCV_CODVOL
				AND DCU.DCU_IMPETI <> '1'
				AND DCU.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				WHERE DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CARGA  = %Exp:cCarga%
				AND DCV.DCV_PEDIDO = %Exp:cPedido%
				AND DCV.DCV_CODMNT = %Exp:cMntVol%
				AND DCV.%NotDel%
				ORDER BY DCV.DCV_CODVOL
			EndSql
		Else
			BeginSql Alias cAliasDCV
				SELECT DCV.DCV_CODPRO,
						DCV.DCV_LOTE,
						DCV.DCV_SUBLOT,
						DCV.DCV_QUANT,
						DCV.DCV_CARGA,
						DCV.DCV_PEDIDO,
						DCV.DCV_CODVOL,
						SC9.C9_CLIENTE,
						SC9.C9_LOJA
				FROM %Table:DCV% DCV
				INNER JOIN %Table:DCU% DCU
				ON DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CARGA = DCV.DCV_CARGA
				AND DCU.DCU_PEDIDO = DCV.DCV_PEDIDO
				AND DCU.DCU_CODVOL = DCV.DCV_CODVOL
				AND DCU.DCU_CODMNT = DCV.DCV_CODMNT
				AND DCU.DCU_IMPETI <> '1'
				AND DCU.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
				AND SC9.C9_ITEM = DCV.DCV_ITEM
				AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
				AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
				AND SC9.%NotDel%
				WHERE DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CARGA  = %Exp:cCarga%
				AND DCV.DCV_PEDIDO = %Exp:cPedido%
				AND DCV.DCV_CODMNT = %Exp:cMntVol%
				AND DCV.DCV_CODVOL = %Exp:cVolume%
				AND DCV.%NotDel%
				ORDER BY DCV.DCV_CODVOL
			EndSql
		EndIf
		If (cAliasDCV)->(!Eof())
			Do While (cAliasDCV)->(!Eof())
				(cAliasDCV)->(aAdd(aItens,{DCV_CODPRO,DCV_QUANT,DCV_CODVOL,DCV_LOTE,DCV_SUBLOT,DCV_CARGA,DCV_PEDIDO,C9_CLIENTE,C9_LOJA}))
				(cAliasDCV)->(dbSkip())
			EndDo
			WMSR410ETI(aItens,.T.,cLocImp)
			MSCBCLOSEPRINTER()
		Else
			WMSVTAviso(WMSV08151,STR0074) // Não há etiquetas de volume pendentes de impressão! Para re-impressão utilize o monitor de volumes de expedição
		EndIf
		(cAliasDCV)->(dbCloseArea())
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
	// Restaura Tecla
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(24,bKey24, cKey24)
Return
