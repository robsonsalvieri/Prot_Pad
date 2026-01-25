#INCLUDE "WMSV104.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV10401 "WMSV10401"
#DEFINE WMSV10402 "WMSV10402"
#DEFINE WMSV10403 "WMSV10403"
#DEFINE WMSV10404 "WMSV10404"
#DEFINE WMSV10405 "WMSV10405"
#DEFINE WMSV10406 "WMSV10406"
#DEFINE WMSV10407 "WMSV10407"
#DEFINE WMSV10408 "WMSV10408"
#DEFINE WMSV10409 "WMSV10409"
#DEFINE WMSV10410 "WMSV10410"
#DEFINE WMSV10411 "WMSV10411"
#DEFINE WMSV10412 "WMSV10412"
#DEFINE WMSV10413 "WMSV10413"
#DEFINE WMSV10414 "WMSV10414"
#DEFINE WMSV10415 "WMSV10415"
#DEFINE WMSV10416 "WMSV10416"
#DEFINE WMSV10417 "WMSV10417"
#DEFINE WMSV10418 "WMSV10418"
#DEFINE WMSV10419 "WMSV10419"
#DEFINE WMSV10420 "WMSV10420"
#DEFINE WMSV10421 "WMSV10421"
#DEFINE WMSV10422 "WMSV10422"
#DEFINE WMSV10423 "WMSV10423"
#DEFINE WMSV10424 "WMSV10424"
#DEFINE WMSV10425 "WMSV10425"
#DEFINE WMSV10426 "WMSV10426"
#DEFINE WMSV10427 "WMSV10427"
#DEFINE WMSV10428 "WMSV10428"
#DEFINE WMSV10429 "WMSV10429"
#DEFINE WMSV10430 "WMSV10430"
#DEFINE WMSV10431 "WMSV10431"
#DEFINE WMSV10432 "WMSV10432"
#DEFINE WMSV10433 "WMSV10433"
#DEFINE WMSV10434 "WMSV10434"
#DEFINE WMSV10435 "WMSV10435"
#DEFINE WMSV10436 "WMSV10436"
#DEFINE WMSV10437 "WMSV10437"
#DEFINE WMSV10438 "WMSV10438"
#DEFINE WMSV10439 "WMSV10439"
#DEFINE WMSV10440 "WMSV10440"
Static oEmbExpOp := Nil
Static lD0ZLocal := D0Z->(ColumnPos("D0Z_LOCAL")) > 0
Static lD0XTransp := D0X->(ColumnPos("D0X_TRANSP")) > 0
//------------------------------------------------------------
/*/{Protheus.doc} WMSV104
Embarque/conferência de embarque de expedição.
@author alexsander.correa
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
Function WMSV104()
	
	If WMSChkPrg(FunName(),"1") .And. WmsX212123("D0X")
		
		oEmbExpOp := WMSDTCEmbarqueExpedicaoEmbarqueOperador():New()
		
		GetEmbarq()

		oEmbExpOp:Destroy()
	EndIf
	
Return Nil
/*--------------------------------------------------------------------------------
---GetArEndIt
---Solicita armazém e endereço de origem do embarque.
---Squad WMS/OMS Protheus
----------------------------------------------------------------------------------*/
Static Function GetArEndIt(lEstorno, cArmazem, cEndereco)
Local lRet      := .T.


	//   01234567890123456789
	// 0 ____Embarque_____
	// 1 Armazem:
	// 2 01
	// 3 Endereco:
	// 4 DOCEXP01
	VtClear()
	VtClearBuffer()
	cArmazem  := Space(TamSx3("D0Z_LOCAL")[1])
	cEndereco := Space(TamSx3("D0Z_ENDER")[1])
	WMSVTCabec(IIf(lEstorno,STR0006,STR0001),.F.,.F.,.T.)  // Estorno Embarq. // Embarque Exp.
	@ 01,00 VTSay PadR(STR0003+":",VTMaxCol()) // Armazem
	@ 02,00 VTGet cArmazem Pict "@!" Valid ValidArm(cArmazem)
	@ 03,00 VTSay PadR(STR0004+":",VTMaxCol()) // Endereço
	@ 04,00 VTGet cEndereco Pict "@!" Valid ValEnder(cArmazem,cEndereco,lEstorno)
	VtRead()
 Return lRet
/*--------------------------------------------------------------------------------
---GetEmbarq
---Permite ir executando o embarque de expedição do produtos, informando os dados
---de lote, sub-lote e quantidade a ser embarcada
---Squad WMS/OMS Protheus
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function GetEmbarq(lEstorno)
Local lRet       := .T.
Local lGerEmbExp := SuperGetMV("MV_WMSGEEX",.F.,.F.) // Permite gerar o embarque de expedição via coletor?
Local aEmbarque  := {}
Local bkey05     := VTSetKey(05) // Ctrl+E
Local cEmbarque  := Space(TamSx3("D0X_EMBARQ")[1])
Local cKey05     := VtDescKey(05)

Default lEstorno := .F.

	If !lEstorno .And. lGerEmbExp
		VTSetKey(05,{|| GerEmbExp()}, STR0005) // Ctrl+E // Gera Embarque
	EndIf

	//   01234567890123456789
	// 0 ____Embarque_____
	// 1 Embarque:
	// 2 0000000010
	// Atribui tecla de atalho para estorno
	Do While lRet
		// Inicializa os campos
		cEmbarque  := Space(TamSx3("D0X_EMBARQ")[1])
		oEmbExpOp:oEmbExpIt:ClearData()
		VtClear()
		WMSVTCabec(IIf(lEstorno,STR0006,STR0001),.F.,.F.,.T.)  // Estorno Embarq. // Embarque Exp.
		@ 01,00 VTSay STR0007+":" //Embarque
		@ 02,00 VTGet cEmbarque
		VTRead()

		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			lRet := !WmsQuestion(STR0002,STR0001) // Confirma a saída? // Embarque Exp.
			Loop
		EndIf
	
		If lRet .And. Empty(cEmbarque)
			aEmbarque := oEmbExpOp:oEmbExpIt:oEmbExp:LoadEmbExp()
			If Empty(aEmbarque)
				WMSVTAviso(WMSV10408,STR0008) // Não existem embarques de expedição pendentes para execução.
				VtKeyboard(Chr(20))
				Loop
			Else
				VtClearBuffer()
				WMSVTCabec(IIf(lEstorno,STR0006,STR0001),.F.,.F.,.T.) // Estorno Embarq. // Embarque Exp.
				nPos:=VTaBrowse(1,,,,{STR0001},aEmbarque,{20}) // Embarque Exp.
				If VTLastKey() == 27
					lRet := .F.
				EndIf
				If lRet
					cEmbarque:= aEmbarque[nPos,1]
				EndIf
			EndIf
		EndIf
		If lRet
			oEmbExpOp:oEmbExpIt:SetEmbarq(cEmbarque)
			If !oEmbExpOp:oEmbExpIt:oEmbExp:FindEmbExp()
				WmsMessage(oEmbExpOp:oEmbExpIt:oEmbExp:GetErro(),WMSV10401)
				VtKeyboard(Chr(20))
				Loop
			EndIf
		EndIf
		// Efetua a conferência dos produtos deste embarque
		If lRet
			CofPrdLot(cEmbarque)
		EndIf
	EndDo
	// Desabilita tecla
	VTSetKey(05,bkey05,cKey05)
	
Return lRet
/*--------------------------------------------------------------------------------
---CofPrdLot
---Permite efetuar o embarque de expedição dos produtos de um processo
---até que o usuário escolha a opção de finalizar o embarque de expedição.
---Squad WMS/OMS Protheus - 19/12/2018
---cEmbarque, Caracter, Código do embarque
---lEstorno, Logico, (Indica se é estorno)
----------------------------------------------------------------------------------*/
Static Function CofPrdLot(cEmbarque,lEstorno)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aVolume   := {}
// Ativa teclas de atalho
Local bkey09    := VTSetKey(9, {|| ShowPrdEmb()}, STR0009) // Produto
Local bkey15    := VTSetKey(15,{|| ShowOpeEmb()}, STR0010) // Operador
Local bkey18    := "" 
Local bkey21    := VTSetKey(21)
Local bkey24    := VTSetKey(24,{|| CofPrdLot(cEmbarque,.T.)}, STR0006) // Estorno Embarq. // Ctrl+X

Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local lWMSSolEnd:= SuperGetMV('MV_WMSEEAE', .F., .T.) //Embarque de Expedição Solicita Armazém e Endereço? 
Local lVolume   := .F.
Local lQtdBar   := .F.
Local lRet      := .T.
Local lPergunta := .F.
Local lForceESC := .F.
Local cKey09    := VtDescKey(09)
Local cKey15    := VtDescKey(15)
Local cKey18    := "" 
Local cKey21    := VtDescKey(21)
Local cKey24    := VtDescKey(24)
Local cWmsUMI   := ""
Local cCodBar   := ""
Local cProduto  := ""
Local cPrdOri   := ""
Local cPrdAnt   := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cPictQt   := ""
Local cUM       := ""
Local cDscUM    := ""
Local cArmazem  := ""
Local cEnder    := ""
Local cAliasSC9 := ""
Local nQtdEmb   := 0.00
Local nItem     := 0.00
Local nLin      := 0
Local nCont     := 0
Local nI        := 0
Local cEndereco := ""
Local nQtdPrdE  := 0 
Local cLocalD00 := ""
Local cEndD00   := ""
Local lRetD00   := .F. 

Default lEstorno := .F.

    If lD0XTransp
		bkey18 := VTSetKey(18,{|| GetTransp(1)},"Transportador") // Ctrl+R
		cKey18    := VtDescKey(18)
	End IF 

	oEmbExpOp:SetDatIni(dDataBase)
	oEmbExpOp:SetHorIni(Time())
	Do While lRet
		lForceESC := .F.
		Do While lRet
			nQtdEmb := 0.00
			//   01234567890123456789
			// 0 ____Embarque_____
			// 1 Embarque: 000000

			//Limpa variáveis
			oEmbExpOp:oEmbExpIt:oProdLote:ClearData()
			oEmbExpOp:oEmbExpIt:SetQuant(0)
			oEmbExpOp:oEmbExpIt:SetArrVol({})
			//   01234567890123456789
			// 0 ____Embarque_____
			// 1 Embarque: 000000
			// 2 Informe o Armazém
			// 3 01
			// 4 Informe o Endereço
			// 5 DOCA
			If lD0ZLocal 
				If lWMSSolEnd //Embarque de Expedição Solicita Armazém e Endereço? 
					lRet := GetArEndIt(lEstorno,@cArmazem,@cEndereco)
				Else
					cArmazem := D0Z->D0Z_LOCAL
					cEndereco := D0Z->D0Z_ENDER
				EndIf	
			EndIf
			If VTLastKey() == 27
				exit
			EndIf
			//   01234567890123456789
			// 0 ____Embarque_____	
			// 1 Embarque: 000000
			// 2 Informe o Produto
			// 3 PA1
			// 4 Lote: AUTO000636
			// 5 Sub-Lote: 000000
			// 6 Informe a Qtde
			// 7               240.00
			VtClear()
			VtClearBuffer()
			lPergunta := .F.
			aVolume   := {}
			cCodBar   := Space(128)
			cProduto  := Space(Len(D0Z->D0Z_PRODUT))
			cPrdOri   := Space(Len(D0Z->D0Z_PRDORI))
			cLoteCtl  := Space(Len(D0Z->D0Z_LOTECT))
			cNumLote  := Space(Len(D0Z->D0Z_NUMLOT))
			nCont     := 0
			nLin      := 1
			WMSVTCabec(Iif(lEstorno,STR0006,STR0001),.F.,.F.,.T.) // Estorno Embarq. // Embarque Exp.
			@ nLin++,00  VtSay STR0007 + ': ' + cEmbarque // Embarque
			@ nLin++,00  VTSay STR0011 // Informe o Produto
			@ nLin++,00  VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cNumLote,@nQtdEmb,@cCodBar,@aVolume)
			// Descricao do Produto com tamanho especifico.
			VtRead()
			If VTLastKey() == 27
				exit
			EndIf
			If lRet
				lVolume := !Empty(aVolume)
				lQtdBar := (nQtdEmb > 0)
				If lQtdBar
					cPrdAnt := Space(TamSx3("D0Z_PRODUT")[1])
				EndIf
				If !lVolume
					// Se tiver espaço suficiente na tela será mostrado o sub-lote na mesma tela
					If Rastro(cProduto)
						@ nLin,00  VtSay STR0015 // Lote
						@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid !Empty(cLoteCtl)
						If Rastro(cProduto,"S")
							@ nLin,00 VTSay STR0016 // Sub-Lote
							@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid !Empty(cNumLote)
						EndIf
						VtRead()
					EndIf
					//validar se produto lote numlote está no embarque 
					If !VldPrLote(cEmbarque,cProduto,cLoteCtl,cNumLote)
						WmsMessage(STR0056,WMSV10440) // "Produto e/ou Lote informado nao pertence ao embarque"
						Loop // Volta para o inicio do produto
					EndIf
					If VTLastKey() == 27
						Loop // Volta para o inicio do produto
					EndIf
					If lRet
						// Força selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
						If ((cProduto <> cPrdAnt) .Or. lWMSConf)
							//Fazer uma busca na tabela de itens do embarque para buscar a quantidade total do item e ja validar se o item/Lote está no embarque 
							nQtdPrdE := VldCalcIt(cEmbarque,cProduto,cLoteCtl,cNumLote)
						
							//  Carrega unidade de medida, simbolo da unidade e quantidade na unidade
							WmsValUM(@nQtdPrdE,;    // Quantidade movimento
									@cWmsUMI,;  // Unidade parametrizada
									cProduto,;   // Produto
									cArmazem,;       // Armazem
									cEndereco,;       // Endereço
									@nItem,;       // Item unidade medida
									.F.,;       // Indica se é uma conferência
									lQtdBar)    // Indica se quantidade já preenchida
							// Força selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
							If (QtdComp(nQtdEmb) <= QtdComp(0))
								//  Seleciona unidade de medida
								WmsSelUM(cWmsUMI,; // Unidade parametrizada
										@cUM,;      // Unidade medida reduzida
										@cDscUM,;   // Descrição unidade medida
										Nil,;       // Quantidade movimento
										@nItem,;    // Item seleção unidade
										@cPictQt,;  // Mascara unidade medida
										Nil,;       // Quantidade no item seleção unidade
										.T.,;       // Indica se é uma conferência
										STR0007,;   // Descrição da tarefa
										Nil,;       // Armazem
										Nil,;       // Endereço
										cProduto,;  // Produto Origem
										cProduto,;  // Produto
										cLoteCtl,;  // Lote
										cNumLote,;  // sub-lote
										lQtdBar)    // Indica se quantidade já preenchida
								If (VTLastKey()==27)
									lRet := .F.
									Loop
								EndIf
							EndIf
						EndIf
						If lRet
							cPrdAnt := cProduto
							If (nLin + 1) > VTMaxRow()
								@ nLin,00 VTSay STR0017+': ' //Qtde
								@ nLin,Len(STR0017+': ') VTGet nQtdEmb Picture cPictQt When Empty(nQtdEmb) Valid nQtdEmb > 0
							Else
								@ nLin++,00 VTSay PadR(STR0017+' '+cDscUM,VTMaxCol())
								@ nLin++,00 VTGet nQtdEmb Picture cPictQt When Empty(nQtdEmb) Valid nQtdEmb > 0
							EndIf
							VTRead()
							If VTLastKey()==27 .Or. QtdComp(nQtdEmb) == 0
								Loop
							EndIf
							// Quando usar a segunda unidade de medida converter para a primeira e quantidade informada para que o embarque seja finalizado 
							If (cWmsUMI == '2' .OR. cWmsUMI == '3') .AND. nItem == 2
								nQtdEmb := ConvUm(cProduto,0,nQtdEmb,1)
							EndIf
						EndIf
					EndIf
				EndIF
			EndIf
			If lRet
				// Atribui os dados do embarque
				oEmbExpOp:SetReverse(lEstorno)
				oEmbExpOp:oEmbExpIt:SetReverse(lEstorno)
				oEmbExpOp:oEmbExpIt:SetArrVol(aVolume)
				If Empty(aVolume)
					oEmbExpOp:oEmbExpIt:oProdLote:SetProduto(cProduto) // Produto do embarque de expedição 
					oEmbExpOp:oEmbExpIt:oProdLote:SetLoteCtl(cLoteCtl) // Lote do produto
					oEmbExpOp:oEmbExpIt:oProdLote:SetNumLote(cNumLote) // Sublote do lote do produto
					oEmbExpOp:oEmbExpIt:oProdLote:SetNumSer("")        // Número de Série
					oEmbExpOp:oEmbExpIt:SetQuant(nQtdEmb)
					If !lWMSSolEnd .And. lD0ZLocal
						cLocalD00 := ""
						cEndD00   := ""
						lRetD00 := WmsBoxDoca(.T.,3,,,,cProduto, /*cNota*/, /*cCarga*/, /*cEstVol*/, @cLocalD00, @cEndD00, cLoteCtl, cEmbarque,nQtdEmb)
						If lRetD00 
							oEmbExpOp:oEmbExpIt:SetArmazem(cLocalD00) // Armazem
							oEmbExpOp:oEmbExpIt:SetEnder(cEndD00)  // Endereco
						EndIf
					EndIf
				EndIf
				// Efetua as validações e retorna os documentos do embarque
				If !oEmbExpOp:oEmbExpIt:FindDocEmb()
					WMSVTAviso(WMSV10419,oEmbExpOp:oEmbExpIt:GetErro())
					Loop
				EndIf
				nI := 1
				If Empty(aVolume)
					If SelDocEmb(@nI)
						cCarga  := oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][1] // Carga
						cPedido := oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][2] // Pedido 
						cItem   := oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][3] // Item do Pedido Liberado
						cSequen := oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][4] // Sequencia do Item
						cPrdOri := oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][8] // Produto Origem
					Else
						Loop
					EndIf
				EndIf
			EndIf
			// Somente grava a quantidade se o usuário não cancelar
			If lRet
				VTMsg(STR0018) // Processando...
				//Atribui o código do operador
				oEmbExpOp:SetCodOpe(__cUserID) // Operador
				// Verifica se o produto está em mais de uma carga, pedido, romaneio de embarque e nota-fiscal
				If Empty(aVolume)
					oEmbExpOp:oEmbExpIt:oProdLote:SetPrdOri(cPrdOri) // Produto do embarque de expedição
					oEmbExpOp:oEmbExpIt:SetCarga(cCarga)             // Carga
					oEmbExpOp:oEmbExpIt:SetPedido(cPedido)           // Pedido 
					oEmbExpOp:oEmbExpIt:SetItem(cItem)               // Item do Pedido Liberado
					oEmbExpOp:oEmbExpIt:SetSequen(cSequen)           // Sequencia do Item
					If lWMSSolEnd .And. lD0ZLocal
						oEmbExpOp:oEmbExpIt:SetArmazem(cArmazem)     // Armazem
						oEmbExpOp:oEmbExpIt:SetEnder(cEnder)         // Endereco
					EndIf
					oEmbExpOp:SetCodVol("")                          // Código do Volume
					oEmbExpOp:SetQtdEmb(nQtdEmb)                     // Quantidade embarcada
					If !oEmbExpOp:AssignD16()
						WMSVTAviso(WMSV10425,oEmbExpOp:GetErro())
						lRet := .F.
					EndIf
				Else
					For nI := 1 To Len(aVolume)
						oEmbExpOp:oEmbExpIt:oProdLote:SetPrdOri(aVolume[nI][10]) // Produto do embarque de expedição 
						oEmbExpOp:oEmbExpIt:oProdLote:SetProduto(aVolume[nI][1]) // Produto do embarque de expedição 
						oEmbExpOp:oEmbExpIt:oProdLote:SetLoteCtl(aVolume[nI][6]) // Lote do produto
						oEmbExpOp:oEmbExpIt:oProdLote:SetNumLote(aVolume[nI][7]) // Sublote do lote do produto
						oEmbExpOp:oEmbExpIt:oProdLote:SetNumSer("")              // Número de Série
						oEmbExpOp:SetCodVol(aVolume[nI][11])                     // Código do Volume
						oEmbExpOp:SetQtdEmb(aVolume[nI][3])                      // Quantidade embarcada						
						oEmbExpOp:oEmbExpIt:SetCarga(aVolume[nI][4])             // Carga
						oEmbExpOp:oEmbExpIt:SetPedido(aVolume[nI][5])            // Pedido
						oEmbExpOp:oEmbExpIt:SetItem(aVolume[nI][8])              // Item do Pedido Liberado
						oEmbExpOp:oEmbExpIt:SetSequen(aVolume[nI][9])    		 // Sequencia do Item
						//Validação para inclusão do armazem e endereço caso os respectivos campos existam na tabela DOZ
						IF lD0ZLocal
							oEmbExpOp:oEmbExpIt:SetArmazem(oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][9])    // Armazem
							oEmbExpOp:oEmbExpIt:SetEnder(oEmbExpOp:oEmbExpIt:GetArrDoc()[nI][10])      // Endereco        
						Endif
						cAliasSC9 := GetNextAlias()
						If !lWMSSolEnd .And. lD0ZLocal
							cLocalD00 := ""
							cEndD00   := ""
							lRetD00 := WmsBoxDoca(.T.,3,aVolume[nI][5], aVolume[nI][8], aVolume[nI][9], aVolume[nI][10], /*cNota*/, /*cCarga*/, /*cEstVol*/, @cLocalD00, @cEndD00)
							If lRetD00
								oEmbExpOp:oEmbExpIt:SetArmazem(cLocalD00) // Armazem
								oEmbExpOp:oEmbExpIt:SetEnder(cEndD00)  // Endereco
							ElseIf !lRet
								BeginSql Alias cAliasSC9
								SELECT SC9.C9_LOCAL,
									SC9.C9_ENDPAD 
								FROM %Table:SC9% SC9
								WHERE SC9.C9_FILIAL = %xFilial:SC9%
								AND SC9.C9_PEDIDO = %Exp:aVolume[nI][5]%
								AND SC9.C9_ITEM = %Exp:aVolume[nI][8]%
								AND SC9.C9_SEQUEN = %Exp:aVolume[nI][9]%
								AND SC9.C9_PRODUTO = %Exp:aVolume[nI][10]%
								AND SC9.C9_BLWMS = '05'
								AND SC9.%NotDel%
								EndSql
								If (cAliasSC9)->(!EoF())
									oEmbExpOp:oEmbExpIt:SetArmazem((cAliasSC9)->C9_LOCAL) // Armazem
									oEmbExpOp:oEmbExpIt:SetEnder((cAliasSC9)->C9_ENDPAD)  // Endereco
								EndIf
								(cAliasSC9)->(DbCloseArea())
							EndIf
						EndIf

						If !oEmbExpOp:AssignD16()
							WMSVTAviso(WMSV10426,oEmbExpOp:GetErro())
							lRet := .F.
						EndIf
					Next nI
				EndIf
			EndIf
			// Se for estorno, sai ao executar a primeira vez
			If lEstorno
				Exit
			EndIf
			//-- Se o status ficou como embarcado, sai para digitar novamente outro embarque
			If lRet .And. oEmbExpOp:oEmbExpIt:oEmbExp:GetStatus() =="3"
				lForceESC := .T.
				Exit
			EndIf
		EndDo

		If VTLastKey() == 27 .Or. lForceESC
			If !lEstorno
				If lForceESC .Or. (WMSVTAviso(WMSV10415,STR0012,{STR0013,STR0014}) == 1) // Deseja interromper o embarque de expedicao? // Sim // Não
					lRet := .F.
				Else
					Loop
				EndIf
			Else
				lEstorno := .F.
				Loop
			EndIf
		EndIf
	
		If (!lRet .And.!lEstorno) .And. oEmbExpOp:oEmbExpIt:oEmbExp:GetStatus() =="3"
			WmsUpdD00(2,cEmbarque)
		EndIf

		//Apresenta status do embarque
		If !lRet .And.!lEstorno
			FinEmbExp()
		EndIf

	EndDo
	// Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(15,bkey15,cKey15)
	If lD0XTransp 
		VTSetKey(18,bkey18,cKey18)
	EndIF 
	VTSetKey(21,bkey21,cKey21)
	VTSetKey(24,bkey24,cKey24)
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdEmb
---Apresenta produtos do embarque de expedição
---Squad WMS/OMS Protheus
----------------------------------------------------------------------------------*/
Static Function ShowPrdEmb()
Local aTamSx3   := {}
Local aProduto  := {}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cAliasD0Z := Nil
	cQuery := "SELECT D0Z.D0Z_CARGA,"
	cQuery +=       " D0Z.D0Z_PEDIDO,"
	cQuery +=       " SC9.C9_ROMEMB,"
	cQuery +=       " SC9.C9_NFISCAL,"
	cQuery +=       " SC9.C9_SERIENF,"
	cQuery +=       " D0Z.D0Z_PRODUT,"
	cQuery +=       " SB1.B1_DESC,"
	cQuery +=       " D0Z.D0Z_LOTECT,"
	cQuery +=       " D0Z.D0Z_NUMLOT,"
	cQuery +=       " D0Z.D0Z_QTDEMB,"
	cQuery +=       " CASE WHEN D0Z.D0Z_QTDORI <> D0Z.D0Z_QTDEMB THEN '*' ELSE ' ' END PRD_EMB"
	cQuery +=  " FROM "+RetSqlName("D0Z")+ " D0Z"
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=    " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=   " AND SB1.B1_COD = D0Z.D0Z_PRODUT"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=    " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=   " AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO"
	cQuery +=   " AND SC9.C9_ITEM = D0Z.D0Z_ITEM"
	cQuery +=   " AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D0Z.D0Z_FILIAL = '"+xFilial("D0Z")+"'"
	cQuery +=   " AND D0Z.D0Z_EMBARQ = '"+oEmbExpOp:oEmbExpIt:GetEmbarq()+"'"
	cQuery +=   " AND D0Z.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0Z := GetNextAlias()
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0Z,.F.,.T.)
	aTamSx3 := TamSx3("D0Z_EMBARQ");TcSetField(cAliasD0Z,'D0Z_EMBARQ','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasD0Z)->(!Eof())
		Aadd(aProduto,{(cAliasD0Z)->PRD_EMB,(cAliasD0Z)->D0Z_CARGA,(cAliasD0Z)->D0Z_PEDIDO,(cAliasD0Z)->C9_ROMEMB,(cAliasD0Z)->C9_NFISCAL,(cAliasD0Z)->C9_SERIENF,(cAliasD0Z)->D0Z_PRODUT,(cAliasD0Z)->B1_DESC,(cAliasD0Z)->D0Z_LOTECT,(cAliasD0Z)->D0Z_NUMLOT,(cAliasD0Z)->D0Z_QTDEMB})
		(cAliasD0Z)->(dbSkip())
	EndDo
	(cAliasD0Z)->(dbCloseArea())
	If Empty(aProduto)
		WMSVTAviso(WMSV10416,WmsFmtMsg(STR0019,{{"[VAR01]",Alltrim(oEmbExpOp:oEmbExpIt:GetEmbarq())}})) // Embarque de expedição [VAR01] não iniciado.
	Else
		VtClearBuffer()
		WMSVTCabec(STR0009,.F.,.F.,.T.) // Produto
		nPos:=VTaBrowse(1,,,,{' ',STR0020,STR0021,STR0022,STR0037,STR0009,STR0023,STR0024,STR0015,STR0016,STR0025},aProduto,{1,TamSx3("D0Z_CARGA")[1],TamSx3("D0Z_PEDIDO")[1],TamSx3("C9_ROMEMB")[1],TamSx3("C9_NFISCAL")[1],TamSx3("C9_SERIENF")[1],TamSx3("D0Z_PRODUT")[1],30,TamSx3("D0Z_LOTECT")[1],TamSx3("D0Z_NUMLOT")[1],11})// Carga|Pedido|RomEmb|Nota-Fiscal|Serie NF|Produto|Descrição|Lote|Sub-Lote|Qtde Embarq
	EndIf
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowOpeEmb
---Apresenta os operados dos produtos embarcados/conferidos
---Squad WMS/OMS Protheus - 20/01/2019
----------------------------------------------------------------------------------*/
Static Function ShowOpeEmb()
Local cQuery    := ""
Local cAliasD16 := GetNextAlias()
Local aOperador := {}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	// Movimento do SF1
	cQuery := " SELECT DISTINCT D16.D16_CODOPE,"
	cQuery +=        " DCD.DCD_NOMFUN"
	cQuery +=   " FROM "+RetSqlName("D16")+ " D16,"+RetSqlName("DCD")+" DCD"
	cQuery +=  " WHERE D16.D16_FILIAL ='"+xFilial("D16")+"'"
	cQuery +=    " AND D16.D16_EMBARQ = '" + oEmbExpOp:oEmbExpIt:GetEmbarq() +"'"
	cQuery +=    " AND D16.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCD.DCD_FILIAL = '"+xFilial("DCD")+"'"
	cQuery +=    " AND DCD.DCD_CODFUN = D16.D16_CODOPE"
	cQuery +=    " AND DCD.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY D16.D16_CODOPE"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD16,.F.,.T.)
	While !(cAliasD16)->( Eof() )
		AAdd(aOperador,{(cAliasD16)->D16_CODOPE,(cAliasD16)->DCD_NOMFUN})
		(cAliasD16)->( DBSkip() )
	EndDo
	(cAliasD16)->( DBCloseArea() )
	If Empty(aOperador)
		WMSVTAviso(WMSV10403,WmsFmtMsg(STR0026,{{"[VAR01]",Alltrim(oEmbExpOp:oEmbExpIt:GetEmbarq())}})) // Embarque de expedição [VAR01] não iniciado.
	Else
		VtClearBuffer()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Embarque Exp.
		nPos:=VTaBrowse(1,,,,{STR0010,STR0027},aOperador,{TamSx3("D16_CODOPE")[1],30}) // Operador // Nome
	EndIf
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence a alguma
---distribuição de separação que está pendente ou em andamento
---Squad WMS/OMS Protheus - 20/01/2019
---cProduto, character, (Produto informado)
---cLoteCtl, character, (Lote etiqueta)
---cNumLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---cCodBar, character, (Codigo de barras)
---aVolume, Array, Contém os itens do volume quando informado um volume no cCodBar
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,aVolume)
Local lRet     := .T.
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())

	lRet := !Empty(cCodBar)
	If lRet
		lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtde,@cCodBar,.T.,@aVolume)
	EndIf
	
	If lRet .And. Empty(aVolume)
		// Monta tela produto
		WmsMontPrd( Nil,;                               // Unidade parametrizada
					.T.,;                               // Indica se é uma conferência
					STR0001,;                           // Descrição da tarefa
					oEmbExpOp:oEmbExpIt:GetArmazem(),;  // Armazem
					oEmbExpOp:oEmbExpIt:GetEnder(),;    // Endereço
					cProduto,;                          // Produto Origem
					cProduto,;                          // Produto
					cLoteCtl,;                          // Lote
					cNumLote,;                          // sub-lote
					Nil,;                               // Id Unitizador
					nQtde)                              // Quantidade preenchida
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---FinEmbExpc
---Encerramento Embarque/Conferênica do embarque de expedição
---Squad WMS/OMS Protheus 20/01/2019
----------------------------------------------------------------------------------*/
Static Function FinEmbExp()
Local aAreaD0X := D0X->( GetArea() )
Local lRet     := .T.
Local aBoxD0X  := RetSx3Box(Posicione('SX3',2,'D0X_STATUS','X3CBox()'),,,1)

	If oEmbExpOp:oEmbExpIt:oEmbExp:LoadData()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Embarque Exp.
		@ Int(VTMaxRow()/2), 00 VtSay STR0018 // Processando...
		//   01234567890123456789
		// 0 Embarque Exp._____
		// 1 Recebimento: 000000
		// 2 --------------------
		// 3 Embarcado
		// 4 --------------------
		VtClear()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Embarque Exp.
		//Mostra Dados
		@ 01,00  VTSay STR0007 + ': ' + oEmbExpOp:oEmbExpIt:GetEmbarq() // Embarque
		@ 02,00  VTSay Replicate('-',VTMaxCol())
		@ 03,00  VtSay aBoxD0X[Val(oEmbExpOp:oEmbExpIt:oEmbExp:GetStatus()),3]
		@ 04,00  VTSay Replicate('-',VTMaxCol())
		WMSVTRodPe()
	Else
		WMSVTAviso(WMSV10417,STR0028) // Embarque de expedição informado não cadastrado.
		lRet := .F.
	EndIf
	oEmbExpOp:oEmbExpIt:SetEmbarq("")
	RestArea(aAreaD0X)
Return lRet
//-------------------------------------------------
// Valida o armazém informado
//-------------------------------------------------
Static Function ValidArm(cArmazem)
Local lRet      := .T.
	NNR->(dbSetOrder(1))
	If !NNR->(dbSeek(xFilial("NNR")+cArmazem))
		WmsMessage(STR0029,WMSV10401) // Armazem inválido!
		lRet := .F.
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet
//-------------------------------------------------
// Valida o endereço informado
//-------------------------------------------------
Static Function ValEnder(cArmazem,cEndereco,lEstorno)
Local lRet     := .T.
Local oEnderAux := WMSDTCEndereco():New()

	oEnderAux:SetArmazem(cArmazem)
	oEnderAux:SetEnder(cEndereco)
	If !oEnderAux:LoadData()
		WmsMessage(STR0030,WMSV10402) // Endereço inválido!
		lRet := .F.
	Else
		If oEnderAux:GetTipoEst() != 5
			WmsMessage(STR0031,WMSV10414) // Somente endereços de estrutura do tipo box/doca podem ser informados!
			lRet := .F.
		EndIf
	EndIf
	If lRet
		oEmbExpOp:oEmbExpIt:SetArmazem(cArmazem)
		oEmbExpOp:oEmbExpIt:SetEnder(cEndereco)
		oEmbExpOp:oEmbExpIt:SetReverse(lEstorno)
		If !(lRet := oEmbExpOp:oEmbExpIt:FindDocEmb(.F.))
			WmsMessage(oEmbExpOp:oEmbExpIt:GetErro(),WMSV10427)
		EndIf
	EndIf

	If !lRet
		VtKeyboard(Chr(20))
	EndIf
	FreeObJ(oEnderAux)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} GerEmbExp
Monta opção para geração do embarque de expedição
@author Squad WMS/OMS Protheus
@version P12
@since 03/01/2019
/*/
//----------------------------------------------------------
Static Function GerEmbExp()
Local lRet      := .T.
Local aOpcoes   := {}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local nOpcao    := 0
Local cTransp   := oEmbExpOp:oEmbExpIt:GetTransp()
		
	If Empty(cTransp) .AND. lD0XTransp 
		GetTransp(0)
	EndIf

	cEmbarque := Space(Len(D0X->D0X_EMBARQ))
	// Carrega opções
	AAdd(aOpcoes,{STR0020})             // Carga
	AAdd(aOpcoes,{STR0021})            // Pedido
	AAdd(aOpcoes,{STR0032}) // Romaneio Embarque
	AAdd(aOpcoes,{STR0033}) // Nota-Fiscal/Danfe

	Do While lRet
		VtClearBuffer()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Embarque Exp.
		nOpcao := VTaBrowse(1,,,,{STR0034},aOpcoes,{19}) // Tipo Embarque
		If VTLastKey() == 27
			lRet := .F.
		EndIf
		If lRet
			BuscaDados(nOpcao)
		EndIf
	EndDo
	If oEmbExpOp:oEmbExpIt:oEmbExp:LoadData()
		CofPrdLot(oEmbExpOp:GetEmbarq())
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---SelDocEmb
---Apresenta os documentos para selecionar na geração do embarque de expedição
---Squad WMS/OMS Protheus 03/01/2019
---nOpcao, numeric, Opção de documentos (1-Carga;2-Pedido;3-Romaneio de Embarque;4-Nota-fiscal
----------------------------------------------------------------------------------*/
Static Function SelDocEmb(nOpcao)
Local lRet := .T.
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	If Len(oEmbExpOp:oEmbExpIt:GetArrDoc()) > 1
		VtClearBuffer()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Embarque Exp.
		If lD0ZLocal
			nOpcao:=VTaBrowse(1,,,,{STR0020,STR0021,STR0035,STR0036,STR0037,STR0023,STR0009,STR0038,"Armazem","Endereco"},oEmbExpOp:oEmbExpIt:GetArrDoc(),{TamSx3("D0Z_CARGA")[1],TamSx3("D0Z_PEDIDO")[1],TamSx3("D0Z_ITEM")[1],TamSx3("D0Z_SEQUEN")[1],TamSx3("C9_NFISCAL")[1],TamSx3("C9_SERIENF")[1],TamSx3("D0Z_PRODUTO")[1],TamSx3("D0Z_PRDORI")[1],TamSx3("D0Z_LOCAL")[1],TamSx3("D0Z_ENDER")[1]})// Carga|Pedido|Item|Seq|Nota-Fiscal|Serie NF|Produto|Produto Origem|Local|Endereço
		Else
			nOpcao:=VTaBrowse(1,,,,{STR0020,STR0021,STR0035,STR0036,STR0037,STR0023,STR0009,STR0038},oEmbExpOp:oEmbExpIt:GetArrDoc(),{TamSx3("D0Z_CARGA")[1],TamSx3("D0Z_PEDIDO")[1],TamSx3("D0Z_ITEM")[1],TamSx3("D0Z_SEQUEN")[1],TamSx3("C9_NFISCAL")[1],TamSx3("C9_SERIENF")[1],TamSx3("D0Z_PRODUTO")[1],TamSx3("D0Z_PRDORI")[1]})// Carga|Pedido|Item|Seq|Nota-Fiscal|Serie NF|Produto|Produto Origem|
		EndIf
		If VTLastKey() == 27
			lRet := .F.
		EndIf
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---BuscaDados
---Valida as informações e gera o embarque de expedição
---Squad WMS/OMS Protheus 03/01/2019
---nOpcao, numeric, Opção de documentos (1-Carga;2-Pedido;3-Romaneio de Embarque;4-Nota-fiscal
---lEstono, Logico, indica que será efetuado o estorno
----------------------------------------------------------------------------------*/
Static Function BuscaDados(nOpcao,lEstorno)
Local lContinua := .T.
Local cCarga    := ""
Local cPedido   := ""
Local cRomEmb   := ""
Local cNFDanfe  := ""
Local cNFiscal  := ""
Local cNFSerie  := ""
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())

Default nOpcao   := 1
Default lEstorno := .F.

	Do While lContinua
		// Inicializa variáveis
		cCarga   := Space(TamSx3("D0Z_CARGA")[1])
		cPedido  := Space(TamSx3("D0Z_PEDIDO")[1])
		cRomEmb  := Space(TamSx3("C9_ROMEMB")[1])
		cNFDanfe := Space(TamSx3("F2_CHVNFE")[1])
		cNFiscal := Space(TamSx3("C9_NFISCAL")[1])
		cNFSerie := Space(TamSx3("C9_SERIENF")[1])

		WMSVTCabec(STR0001,.F.,.F.,.T.)   // Embarque Exp.
		If nOpcao == 1
			@ 01,00 VTSay PadR(STR0020+":",VTMaxCol()) // Carga
			@ 02,00 VTGet cCarga Pict "@!" Valid ValCarga(cCarga)
		ElseIf nOpcao == 2
			@ 01,00 VTSay PadR(STR0021+":",VTMaxCol()) // Pedido
			@ 02,00 VTGet cPedido Pict "@!" Valid ValPedido(cPedido)
		ElseIf nOpcao == 3
			@ 01,00 VTSay PadR(STR0032+":",VTMaxCol()) // Romaneio Embarque
			@ 02,00 VTGet cRomEmb Pict "@!" Valid ValRomEmb(cRomEmb)
		Else
			@ 01,00 VTSay PadR(STR0033+":",VTMaxCol()) // Nota-Fiscal/Danfe
			@ 02,00 VTGet cNFDanfe Pict "@!" Valid ValNFDanfe(cNFDanfe,@cNFiscal,@cNFSerie)
		EndIf
		VTRead()
		// Valida se foi precionado Esc
		If VTLastKey() == 27
			lContinua := .F.
			Loop
		EndIf
		// Inicializa Objeto
		oEmbExpOp:oEmbExpIt:SetCarga(cCarga)
		oEmbExpOp:oEmbExpIt:SetPedido(cPedido)
		oEmbExpOp:oEmbExpIt:SetRomEmb(cRomEmb)
		oEmbExpOp:oEmbExpIt:SetNFiscal(cNFiscal)
		oEmbExpOp:oEmbExpIt:SetNFSerie(cNFSerie)
		If !oEmbExpOp:oEmbExpIt:ChangeData(nOpcao)
			WmsMessage(oEmbExpOp:oEmbExpIt:GetErro(),WMSV10418)
		EndIf
	EndDo
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ValCarga
---Valida as informações da carga
---Squad WMS/OMS Protheus 03/01/2019
---cCarga, caracter, Código da carga
----------------------------------------------------------------------------------*/
Static Function ValCarga(cCarga)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt  := GetArea()
Local cTransp   := oEmbExpOp:oEmbExpIt:GetTransp()
Local cTrpCarg   := ""
Local lUpdte     := .T.
Local lWMSTrem  := SuperGetMV('MV_WMSTREM',.F.,.F.) //Questiona se deve ou não assumir a transportadora do embarque?
Local cAliasDAI := Nil
Local cAliasDAK := NIl
Local cAliasVFT := Nil 
Local cRecnoDAK := ""

	If !Empty(cCarga)
		cAliasDAK := GetNextAlias()
		BeginSql Alias cAliasDAK
			SELECT R_E_C_N_O_ RECNODAK,
					DAK.DAK_TRANSP
			FROM %Table:DAK% DAK 
			WHERE DAK.DAK_FILIAL = %xFilial:DAK%
			AND DAK.DAK_COD = %Exp:cCarga%
			AND DAK.%NotDel%
		EndSql
		If (cAliasDAK)->(!Eof())
			cRecnoDAK:= (cAliasDAK)->RECNODAK
			cTrpCarg := (cAliasDAK)->DAK_TRANSP
		Else
			WmsMessage(WmsFmtMsg(STR0039,{{"[VAR01]",AllTrim(cCarga)}}),WMSV10420) // Carga [VAR01] inválida!
			lRet := .F.
		EndIf
		(cAliasDAK)->(dbCloseArea()) 
	Else
		lRet := .F.
	EndIf
	
	If lRet .AND. lD0XTransp .AND. !Empty(cTransp)
	    //Valida se ja existe faturamento para a carga e caso ja exista a transportadora nao pode ser diferente
		cAliasVFT := GetNextAlias()
		BeginSql Alias cAliasVFT
			SELECT DISTINCT 1 
  			FROM %Table:DAK% DAK
  			INNER JOIN %TABLE:DAI% DAI
  			ON DAI.DAI_FILIAL =  %xFilial:DAI%
  			AND DAI.DAI_COD = DAK.DAK_COD
			AND DAI.%NotDel%
   			INNER JOIN %Table:SC9%  SC9
  			ON SC9.C9_FILIAL = %xFilial:SC9%
  			AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO
   			AND SC9.C9_CARGA = DAI.DAI_COD
			AND SC9.C9_SEQCAR = DAI.DAI_SEQCAR
			AND SC9.%NotDel%
   			INNER JOIN %Table:SD2% SD2
  			ON SD2.D2_FILIAL = %xFilial:SD2%
  			AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
    		AND SD2.D2_ITEMPV = SC9.C9_ITEM
    		AND SD2.D2_DOC    = SC9.C9_NFISCAL
			AND SD2.%NotDel%
  			INNER JOIN %Table:SF2% SF2
  			ON SF2.F2_FILIAL = %xFilial:SF2%
  			AND SF2.F2_DOC = SD2.D2_DOC
			AND SF2.%NotDel%
   			WHERE DAK.DAK_FILIAL =  %xFilial:DAK%
   			AND DAK.DAK_COD  =  %Exp:cCarga%
  			AND (SF2.F2_TRANSP IS NOT NULL AND SF2.F2_TRANSP <> ' '
  			AND SF2.F2_TRANSP <>  %Exp:cTransp%)
			AND DAK.%NotDel%
		EndSql
		If (cAliasVFT)->(!Eof())
			lRet := .F.
			WMSVTAviso(WMSV10433,STR0049) //"Existem pedidos desta carga já faturados com transportadora diferente."
		EndIf
		(cAliasVFT)->(dbCloseArea())
	EndIf 
	
	If lRet .AND. lD0XTransp .AND. !Empty(cTransp)
		If cTrpCarg != cTransp
			If lWMSTrem 
				lUpdte := WmsQuestion(STR0046,WMSV10430) //"Transportadora difere da transportadora da Carga. Assume transportadora?"
			EndIf
			If lUpdte
				DAK->(dbGoTo(cRecnoDAK))
				RecLock("DAK",.F.)
				DAK->DAK_TRANSP := cTransp
				DAK->(MsUnlock())
			
				cAliasDAI := GetNextAlias()
				BeginSql Alias cAliasDAI
					SELECT DAI.DAI_PEDIDO
					FROM %Table:DAI% DAI
					WHERE DAI.DAI_FILIAL = %xFilial:DAI%
					AND DAI.DAI_COD = %Exp:cCarga%
					AND DAI.%NotDel%
				EndSql
				Do While (cAliasDAI)->(!Eof()) 
					SC5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+ (cAliasDAI)->DAI_PEDIDO))
						RecLock("SC5",.F.)
						SC5->C5_TRANSP := cTransp
						SC5->(MsUnlock())
					Endif
					(cAliasDAI)->(DbSkip())	
				EndDo
				(cAliasDAI)->(dbCloseArea())	
			EndIf
		EndIf
	EndIf
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValPedido
---Valida as informações do pedido de venda
---Squad WMS/OMS Protheus 03/01/2019
---cPedido, caracter, Número do pedido de venda
----------------------------------------------------------------------------------*/
Static Function ValPedido(cPedido)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSC6 := Nil 
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt  := GetArea()

	If !Empty(cPedido)
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName("SC6")+" SC6"
		cQuery += " WHERE SC6.C6_FILIAL = '"+xFilial("SC6")+"'"
		cQuery +=   " AND SC6.C6_NUM = '"+cPedido+"'"
		cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSC6 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC6,.F.,.T.)
		If (cAliasSC6)->(Eof())
			WmsMessage(WmsFmtMsg(STR0040,{{"[VAR01]",AllTrim(cPedido)}}),WMSV10421) // Pedido [VAR01] não cadatrado!
			lRet := .F.
		EndIf
		(cAliasSC6)->(dbCloseArea())
	Else
		lRet := .F.
	EndIf
	
	If lRet .AND. lD0XTransp .And. !Empty(oEmbExpOp:oEmbExpIt:GetTransp())
		lRet := VldTrpPed(cPedido)
	EndIf
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValRomEmb
---Valida as informações do romaneio de embarque
---Squad WMS/OMS Protheus 03/01/2019
---cRomEmb, caracter, Número do romaneio de embarque
----------------------------------------------------------------------------------*/
Static Function ValRomEmb(cRomEmb)
Local lRet      := .T.
Local cQuery    := ""
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aAreaAnt  := GetArea()
Local cTransp   := oEmbExpOp:oEmbExpIt:GetTransp()
Local lWMSTrem  := SuperGetMV('MV_WMSTREM',.F.,.F.) //Questiona se deve ou não assumir a transportadora do embarque?
Local lUpdte 	:= .T.
Local cAliasDCU := Nil
Local cAliasQry := Nil 
Local lPrimeiro := .T.

If !Empty(cRomEmb)
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName("DCU")+" DCU"
		cQuery += " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery +=   " AND DCU.DCU_ROMEMB = '"+cRomEmb+"'"
		cQuery +=   " AND DCU.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasDCU := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
		If (cAliasDCU)->(Eof())
			WmsMessage(WmsFmtMsg(STR0041,{{"[VAR01]",AllTrim(cRomEmb)}}),WMSV10422) // Romaneio de embarque [VAR01] não cadatrado!
			lRet := .F.
		EndIf
		(cAliasDCU)->(dbCloseArea())
	Else
		lRet := .F.
	EndIf

	//Valida se o pedido na SC9 ja foi faturado e possui outra transportadora 
	If lRet .AND. lD0XTransp .AND. !Empty(cTransp)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DISTINCT 1 
  			FROM %TABLE:DCU% DCU
  		 	INNER JOIN %TABLE:SC9% SC9
  			ON SC9.C9_FILIAL = %xFilial:SC9%
  			AND SC9.C9_PEDIDO = DCU.DCU_PEDIDO
   			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
			AND NOT EXISTS (SELECT DISTINCT 1
	                 		FROM  %TABLE:D0Z% D0Z
	                 		WHERE D0Z.D0Z_FILIAL =  %xFilial:D0Z%
	                 		AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
	                 		AND D0Z.D0Z_ITEM  = SC9.C9_ITEM
	                 		AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
							AND D0Z.%NotDel% ) 
			INNER JOIN %TABLE:SD2% SD2
  			ON SD2.D2_FILIAL = %xFilial:SD2%
  			AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
    		AND SD2.D2_ITEMPV = SC9.C9_ITEM
    		AND SD2.D2_DOC    = SC9.C9_NFISCAL
			AND SD2.%NotDel% 
  			INNER JOIN %TABLE:SF2% SF2
  			ON SF2.F2_FILIAL = %xFilial:SF2%
  			AND SF2.F2_DOC = SD2.D2_DOC
  			AND SF2.%NotDel% 
  	   		WHERE DCU.DCU_FILIAL =  %xFilial:SD2%
   			AND DCU.DCU_ROMEMB  = %Exp:cRomEmb%
            AND (SF2.F2_TRANSP IS NOT NULL AND SF2.F2_TRANSP <> ' '
  			AND SF2.F2_TRANSP <>  %Exp:cTransp%)
			AND SF2.%NotDel% 
		EndSql
		If (cAliasQry)->(!Eof())
			lRet := .F.
			WMSVTAviso(WMSV10434,STR0050) //"Existem pedidos deste romaneio já faturados com transportadora diferente."
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf 
    // caso nao existe pedidos ja faturados 
	//verificar o parametro e realizar a troca da transportadora nos pedidos de venda relacionados ao romaneio
	//Verificar se tem pedido que possui transportadora diferente da informada no embarque 
	If lRet .AND. lD0XTransp .AND. !Empty(cTransp)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC5.R_E_C_N_O_ RECNOSC5 
  			FROM %Table:DCU% DCU
  	   		INNER JOIN %Table:SC5% SC5
  			ON SC5.C5_FILIAL =  %xFilial:SC5%
  			AND SC5.C5_NUM = DCU.DCU_PEDIDO
    		AND SC5.%NotDel% 
 			AND SC5.C5_TRANSP <> %Exp:cTransp%
     		WHERE DCU.DCU_FILIAL = %xFilial:DCU%
   			AND DCU.DCU_ROMEMB  = %Exp:cRomEmb%
 		EndSql
		Do While (cAliasQry)->(!Eof())
			If lWMSTrem .And. lPrimeiro
				lUpdte := WmsQuestion(STR0047,WMSV10431) //"Transportadora difere de um ou mais pedidos do embarque. Assume transportadora?"
				lPrimeiro := .F. 
			EndIf
			If lUpdte
				SC5->(dbGoTo((cAliasQRY)->RECNOSC5))
				RecLock("SC5",.F.)
				SC5->C5_TRANSP := cTransp
				SC5->(MsUnlock())
			EndIf 
			(cAliasQry)->(DbSkip())	
		EndDo
		(cAliasQry)->(dbCloseArea())	
	EndIf

	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)

Return lRet

/*--------------------------------------------------------------------------------
---ValNFDanfe
---Valida as informações da nota-fiscal
---Squad WMS/OMS Protheus 03/01/2019
---cNFDanfe, caracter, Número do nota-fiscal/danfe
---cNFiscal, caracter, Retorna o número da nota-fiscal
---cNFSerie, caracter, Retorna a série da nota-fiscal
----------------------------------------------------------------------------------*/
Static Function ValNFDanfe(cNFDanfe,cNFiscal,cNFSerie)
Local lRet      := .T.
Local lNFiscal  := .F.
Local cNFisAux  := ""
Local cQuery    := ""
Local cAliasSF2 := ""
Local cTransp   := oEmbExpOp:oEmbExpIt:GetTransp()
Local nPos      := 0
Local nNFiscal  := TamSx3("F2_DOC")[1]
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aNFSerie  := {}
Local aAreaAnt  := GetArea()
Local cAliasSC9 := NIl
Local cAliasVol := Nil 

	cNFiscal := ""
	cNFSerie := ""
	If !Empty(cNFDanfe)
		lNFiscal := Len(AllTRim(cNFDanfe)) <= nNFiscal
		If lNFiscal 
			cNFisAux := PadR(cNFDanfe,nNFiscal)
		EndIf
		// Verifica se nota fiscal cadastrada
		cQuery := "SELECT SF2.F2_DOC,"
		cQuery +=       " SF2.F2_SERIE"
		cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
		cQuery += " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
		If lNFiscal
			cQuery += " AND SF2.F2_DOC = '"+cNFisAux+"'"
		Else
			cQuery += " AND SF2.F2_CHVNFE = '"+cNFDanfe+"'"
		EndIf
		cQuery += " AND SF2.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSF2 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSF2,.F.,.T.)
		If (cAliasSF2)->(!Eof())
			Do While (cAliasSF2)->(!Eof())
				AAdd(aNFSerie,{(cAliasSF2)->F2_DOC,(cAliasSF2)->F2_SERIE})
				(cAliasSF2)->(dbskip())
			EndDo
			//
			nPos := 1
			If Len(aNFSerie) > 1
				VtClearBuffer()
				WMSVTCabec(STR0001,.F.,.F.,.T.) // Estorno Embarq. // Embarque Exp.
				nPos:=VTaBrowse(1,,,,{STR0037,STR0023},aNFSerie,{TamSx3("C9_NFISCAL")[1],TamSx3("C9_SERIENF")[1]}) // Nota-Fiscal|Serie NF
				If VTLastKey() == 27
					lRet := .F.
				EndIf
			EndIf
			If lRet
				cNfiscal := aNFSerie[nPos][1]
				cNFSerie := aNFSerie[nPos][2]
			EndIf
		Else
			If lNFiscal
				WmsMessage(WmsFmtMsg(STR0042,{{"[VAR01]",AllTrim(cNFisAux)}}),WMSV10423) // Nota-Fiscal [VAR01] não gerada!
			Else
				WmsMessage(WmsFmtMsg(STR0043,{{"[VAR01]",AllTrim(cNFDanfe)}}),WMSV10424) // Danfe [VAR01] não gerada!
			EndIf
			lRet := .F.
		EndIf
		(cAliasSF2)->(dbCloseArea())
	Else
		lRet := .F.
	EndIf

	If lRet .AND. lD0XTransp .AND. !Empty(cTransp)
		//Valida se a nota fiscal esta relacionada a algum pedido que foi montado volume, se estiver informa para 
		cAliasVol := GetNextAlias()
		BeginSql Alias cAliasVol
			SELECT DISTINCT VOL.DCV_CODVOL
			FROM ( SELECT DCV.DCV_CODVOL
					FROM %Table:SC9% SC9
					INNER JOIN %Table:DCV% DCV
					ON DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
					AND DCV.DCV_ITEM = SC9.C9_ITEM
					AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
					AND DCV.%NotDel%
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_NFISCAL = %Exp:cNfiscal%
					AND SC9.C9_SERIENF = %Exp:cNFSerie%
					AND SC9.C9_BLWMS = '05'
					AND NOT EXISTS (SELECT 1 
									FROM %Table:D0Z% D0Z
									WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
									AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
									AND D0Z.D0Z_ITEM = SC9.C9_ITEM
									AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
									AND D0Z.%NotDel% )
					AND SC9.%NotDel%
					GROUP BY DCV.DCV_CODVOL) VOL
			INNER JOIN %Table:DCV% DCV
			ON DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
			AND DCV.%NotDel%
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
			AND SC9.C9_ITEM = DCV.DCV_ITEM
			AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
			AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
			AND SC9.%NotDel%
			INNER JOIN %Table:SF2% SF2 
			ON SF2.F2_FILIAL = %xFilial:SD2% 
			AND SF2.F2_DOC = SC9.C9_NFISCAL
			AND (SF2.F2_TRANSP IS NOT NULL 	AND SF2.F2_TRANSP <> ' ' AND SF2.F2_TRANSP <>  %Exp:cTransp%)
			AND SF2.%NotDel%
		EndSql
		If (cAliasVol)->(!Eof())
			lRet := .F.
			WMSVTAviso(WMSV10435,WmsFmtMsg(STR0051,{{"[VAR01]",Alltrim((cAliasVol)->DCV_CODVOL)}})) //"NF relacionada ao Volume: [VAR01] com itens já faturados e Transportadora diferente."
		EndIf
		(cAliasVol)->(dbCloseArea())

		If lRet
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_NFISCAL, SC9.C9_FILIAL, SC9.C9_SERIENF
				FROM %Table:SC9% SC9
				INNER JOIN %Table:SF2% SF2 ON SF2.F2_FILIAL = %xFilial:SF2% 
				AND SF2.F2_DOC = SC9.C9_NFISCAL 
				AND SF2.F2_SERIE = SC9.C9_SERIENF
				AND (SF2.F2_TRANSP IS NOT NULL AND SF2.F2_TRANSP <> ' '
  				AND SF2.f2_TRANSP <>  %Exp:cTransp%)
				AND SF2.%NotDel% 
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_NFISCAL = %Exp:cNfiscal%
				AND SC9.C9_SERIENF = %Exp:cNFSerie%
				AND SC9.%NotDel%
			EndSql
			While (cAliasSC9)->(!Eof())  .And. (cAliasSC9)->C9_FILIAL == FwXFilial("SC9") .And. (cAliasSC9)->C9_NFISCAL == cNfiscal .And. (cAliasSC9)->C9_SERIENF == cNFSerie
				lRet := .F.
				WMSVTAviso(WMSV10429,STR0045) //"Existem notas faturadas para os itens do pedido com transportadora diferente. Inclusão não permitida."
				EXIT
			EndDo
			(cAliasSC9)->(dbCloseArea())
		EndIf
	EndIf
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---GetTransp
---Solicita transportadora.
---Squad WMS/OMS Protheus
----------------------------------------------------------------------------------*/
Static Function GetTransp(nOpcao)
Local lRet      := .T.
Local cTransp	:= " "

    If nOpcao == 1
		oEmbExpOp:oEmbExpIt:oEmbExp:LoadData()
		cTransp := oEmbExpOp:oEmbExpIt:GetTransp()
	Else
		cTransp := Space(TamSx3("D0X_TRANSP")[1])
	EndIf

	VtClear()
	VtClearBuffer()

	WMSVTCabec(STR0055,.F.,.F.,.T.)  // Transportadora
	@ 01,00 VTSay PadR(STR0055+":",VTMaxCol()) // Transportadora
	@ 02,00 VTGet cTransp Pict "@!" Valid ValidTransp(@cTransp,nOpcao) F3 'SA4'
	oEmbExpOp:oEmbExpIt:SetTransp(cTransp)
	VtRead()
	If nOpcao == 1
		If lRet
			oEmbExpOp:oEmbExpIt:oEmbExp:UpdateD0X()
		EndIf
		CofPrdLot(oEmbExpOp:oEmbExpIt:GetEmbarq())
	EndIf	
Return lRet

//-------------------------------------------------
// Valida a transportadora informada
//-------------------------------------------------
Static Function ValidTransp(cTransp, nOpcao)
	Local lRet 	:= .T.
	If !Empty(cTransp)
		SA4->(dbSetOrder(1))
		If !SA4->(dbSeek(xFilial("SA4") + cTransp))
	 		WmsMessage(STR0044, WMSV10428) // Transportadora inválida!
			lRet := .F.
		EndIf
		If !lRet	
			VtKeyboard(Chr(20))
		Else
			If nOpcao = 0
				oEmbExpOp:oEmbExpIt:SetTransp(cTransp)
			Else
				lRet := VldTrpEmb(@cTransp)
			EndIf
		EndIf
	EndIf 
	 
Return lRet

//-------------------------------------------------
// Valida pedido
//-------------------------------------------------
Static Function VldTrpPed(cPedido)
	Local lRet 		:= .T.
	Local lUpdte 	:= .T.
	Local cTransp   := oEmbExpOp:oEmbExpIt:GetTransp()
	Local lWMSTrem  := SuperGetMV('MV_WMSTREM',.F.,.F.) //Questiona se deve ou não assumir a transportadora do embarque?
	Local cAliasQry := Nil
	Local cAliasPed := Nil 

	//Valida de o pedido está relacionado a um volume ainda nao embarcado. 
	//Caso estiver validar se ja existe faturamento com transportadora diferente da informada para algum dos pedidos do volume.   
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DISTINCT VOL.DCV_CODVOL 
			FROM (SELECT DCV.DCV_CODVOL
		    		FROM %Table:SC9% SC9
	   	   			INNER JOIN %Table:DCV% DCV 
					ON DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
					AND DCV.DCV_ITEM = SC9.C9_ITEM
					AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
					AND DCV.%NotDel%
	 				WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO =  %Exp:cPedido%
					AND SC9.C9_BLWMS = '05'
					AND NOT EXISTS (SELECT 1
									FROM %Table:D0Z% D0Z
									WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
									AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
									AND D0Z.D0Z_ITEM = SC9.C9_ITEM
									AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
									AND D0Z.%NotDel%)
					AND SC9.D_E_L_E_T_ = ' '
					GROUP BY DCV.DCV_CODVOL	) VOL
			INNER JOIN %Table:DCV% DCV 
			ON DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_CODVOL = VOL.DCV_CODVOL
			AND DCV.%NotDel%
			INNER JOIN %Table:SC9% SC9 
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO
			AND SC9.C9_ITEM = DCV.DCV_ITEM
			AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN
			AND SC9.C9_PRODUTO = DCV.DCV_PRDORI
			AND SC9.%NotDel%
			INNER JOIN %Table:SD2% SD2 
			ON SD2.D2_FILIAL = %xFilial:SD2%
			AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
			AND SD2.D2_ITEMPV = SC9.C9_ITEM
			AND SD2.D2_DOC = SC9.C9_NFISCAL
			AND SD2.%NotDel%
			INNER JOIN %Table:SF2% SF2 
			ON SF2.F2_FILIAL = %xFilial:SD2% 
			AND SF2.F2_DOC = SD2.D2_DOC
			AND (SF2.F2_TRANSP IS NOT NULL 	AND SF2.F2_TRANSP <> ' ' AND SF2.F2_TRANSP <>  %Exp:cTransp%)
			AND SF2.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			lRet := .F.
			WMSVTAviso(WMSV10436,WmsFmtMsg(STR0052,{{"[VAR01]",Alltrim((cAliasQry)->DCV_CODVOL)}})) //"Pedido relacionado a Volume: [VAR01] com itens já faturados e Transportadora diferente."
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Validar se o pedido de venda foi separado parcial e disponivel para embarque sem ter faturado ainda
	//Caso encontrar indica que pode estar criando o embarque para parte do pedido nao faturado. 
	//Mais a frente quando informar o item e quantidade deverá ser validado para que o item seja o mesmo da transportadora informada.
	If lRet 		
		cAliasPed := GetNextAlias()
		BeginSql Alias cAliasPed
			SELECT DISTINCT 1
			FROM  %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_NFISCAL = ' '
			AND NOT EXISTS (SELECT DISTINCT 1
	       			           	FROM  %Table:D0Z% D0Z
	       		 	          	WHERE D0Z.D0Z_FILIAL =  %xFilial:D0Z%
	       	   		  	      	AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
	       	    	     	  	AND D0Z.D0Z_ITEM  = SC9.C9_ITEM
	                	  		AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
					  			AND D0Z.%NotDel%)
			AND SC9.%NotDel%
		EndSql
		If (cAliasPed)->(Eof())
			//Validar se o pedido/ itens relacionado ao embarque está faturado:
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DISTINCT 1 
  	 			FROM %Table:SC9% SC9
  				INNER JOIN %Table:SD2% SD2
  				ON SD2.D2_FILIAL = %xFilial:SD2%
  				AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
   				AND SD2.D2_ITEMPV = SC9.C9_ITEM
   				AND SD2.D2_DOC    = SC9.C9_NFISCAL
  				AND SD2.%NotDel% 
  				INNER JOIN %Table:SF2% SF2
  				ON SF2.F2_FILIAL =  %xFilial:SF2%
  				AND SF2.F2_DOC = SD2.D2_DOC
  				AND (SF2.F2_TRANSP IS NOT NULL AND SF2.F2_TRANSP <> ' '
  				AND SF2.F2_TRANSP <>  %Exp:cTransp%)
  				AND SF2.%NotDel%
  				WHERE  SC9.C9_FILIAL = %xFilial:SC9%
  				AND SC9.C9_PEDIDO =  %Exp:cPedido%
   				AND SC9.C9_NFISCAL <> ' '
   				AND NOT EXISTS (SELECT DISTINCT 1
	   	    		           	FROM  %Table:D0Z% D0Z
	   		     	          	WHERE D0Z.D0Z_FILIAL =  %xFilial:D0Z%
	   	   		      	      	AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
	           		     	  	AND D0Z.D0Z_ITEM  = SC9.C9_ITEM
	                	  		AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
					  			AND D0Z.%NotDel%)
				AND SC9.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				lRet := .F.
				WMSVTAviso(WMSV10437,STR0053) //"Existem notas faturadas para o pedido com transportadora diferente. Inclusão não permitida."
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		(cAliasPed)->(dbCloseArea()) 
	EndIf 
	If lRet 
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC5.R_E_C_N_O_ RECNOSC5,
					SC5.C5_TRANSP
			FROM %Table:SC5% SC5
			WHERE SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = %Exp:cPedido%
			AND SC5.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->C5_TRANSP) .And. (cAliasQry)->C5_TRANSP <> cTRansp .AND. lWMSTrem
				lUpdte := WmsQuestion(STR0048,WMSV10432) //"Transportadora difere da informada no Pedido. Assume transportadora?"
			EndIf 
			If lUpdte
				SC5->(dbGoTo((cAliasQRY)->RECNOSC5))
				RecLock("SC5",.F.)
				SC5->C5_TRANSP := cTransp
				SC5->(MsUnlock())
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	
Return lRet

//-------------------------------------------------
// Valida se pode alterar transportadora
//-------------------------------------------------
Static Function VldTrpEmb(cTransp)
	Local lRet      := .T.
	Local cEmbarque := ""
	Local cAliasQry := Nil 
	Local lWMSTrem  := SuperGetMV('MV_WMSTREM',.F.,.F.) //Questiona se deve ou não assumir a transportadora do embarque?
	Local lUpdte    := .T. 
	Local lPrimeiro := .T. 
	cEmbarque := oEmbExpOp:oEmbExpIt:GetEmbarq()

	cAliasQry := GetNextAlias()
	BeginSQl Alias cAliasQry
		SELECT DISTINCT 1
		FROM %Table:D0Z% D0Z
		INNER JOIN %Table:SC9% SC9
		ON SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_PEDIDO = D0Z.D0Z_PEDIDO
		AND SC9.C9_ITEM = D0Z.D0Z_ITEM
		AND SC9.C9_SEQUEN = D0Z.D0Z_SEQUEN
   		AND SC9.C9_NFISCAL <> ' '
		AND NOT EXISTS (SELECT DISTINCT 1
   	                  	FROM  %Table:D0Z% D0Z2
  	                  	WHERE D0Z2.D0Z_FILIAL = %xFilial:D0Z%
  	                  	AND D0Z2.D0Z_PEDIDO =  SC9.C9_PEDIDO
	                  	AND D0Z2.D0Z_ITEM  = SC9.C9_ITEM
	                  	AND D0Z2.D0Z_SEQUEN =  SC9.C9_SEQUEN
					   	AND D0Z2.D0Z_EMBARQ <> %Exp:cEmbarque%
						AND D0Z2.%NotDel%)
		AND SC9.%NotDel%
  		INNER JOIN %Table:SD2% SD2
  		ON SD2.D2_FILIAL = %xFilial:SD2%
  		AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
   		AND SD2.D2_ITEMPV = SC9.C9_ITEM
   		AND SD2.D2_DOC    = SC9.C9_NFISCAL
  		AND SD2.%NotDel% 
  		INNER JOIN %Table:SF2% SF2
  		ON SF2.F2_FILIAL = %xFilial:SF2%
  		AND SF2.F2_DOC = SD2.D2_DOC
  		AND (SF2.F2_TRANSP IS NOT NULL AND SF2.F2_TRANSP <> ' '
  		AND SF2.F2_TRANSP <> %Exp:cTransp%)
  		AND SF2.%NotDel% 
  		WHERE  D0Z.D0Z_FILIAL = %xFilial:D0Z%
  		AND D0Z.D0Z_EMBARQ = %Exp:cEmbarque%
		AND D0Z.%NotDel%
	EndSql 
	IF (cAliasQry)->(!Eof())
		WMSVTAviso(WMSV10438,STR0054) //"Pedidos já faturados no embarque com Transportadora diferente.Alteração não permitida."
		cTransp := ""
		lRet := .F.
	EndIf
	(cAliasQry)->(DBCloseArea())

	If lRet 

		cAliasQry := GetNextAlias()
		BeginSQl Alias cAliasQry
			SELECT D0Z.D0Z_CARGA, 
					SC5.C5_TRANSP,
					SC5.R_E_C_N_O_ RECNOSC5,
					DAK.R_E_C_N_O_ RECNODAK
			FROM %Table:D0Z% D0Z
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_TRANSP <> %Exp:cTransp%
			AND SC5.C5_NUM = D0Z.D0Z_Pedido
			AND SC5.%NotDel%
			LEFT JOIN %Table:DAK% DAK
			ON DAK.DAK_FILIAL =  %xFilial:DAK%
			AND DAK.DAK_COD = D0Z_CARGA
			WHERE  D0Z.D0Z_FILIAL =  %xFilial:D0Z%
  			AND D0Z.D0Z_Embarq = %Exp:cEmbarque%
   			AND D0Z.%NotDel%
   		EndSql
		Do While (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->C5_TRANSP ) .And. lWMSTrem .And. lPrimeiro
				lUpdte := WmsQuestion(STR0047,WMSV10439) //"Transportadora difere de um ou mais pedidos do embarque. Assume transportadora?"
				lPrimeiro := .F. 
			EndIf 
			If lUpdte 
				If !Empty((cAliasQry)->D0Z_CARGA)
					DAK->(dbGoTo((cAliasQry)->RecnoDAK))
					RecLock("DAK",.F.)
					DAK->DAK_TRANSP := cTransp
					DAK->(MsUnlock())
				EndIf

				SC5->(dbGoTo((cAliasQry)->RECNOSC5))
				RecLock("SC5",.F.)
				SC5->C5_TRANSP := cTransp
				SC5->(MsUnlock())
			EndIf
			(cAliasQry)->(DbSkip())
		EndDO
		(cAliasQry)->(dbCloseArea())
	EndIf 	

	If lRet
		oEmbExpOp:oEmbExpIt:SetTransp(cTransp)
	EndIf	
	
Return lRet

//-----------------------------------------
/*/{Protheus.doc} VldCalcIt
Busca quantidade do embarque para o item 
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
Static Function VldCalcIt(cEmbarque,cProduto,cLoteCtl,cNumLote)
Local cAliasD0Z := GetNextAlias()
Local nSldItem := 0
Local cWhere := ""

	cWhere := '%'
	If !Empty(cLoteCtl)
		cWhere += " AND D0Z.D0Z_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D0Z.D0Z_NUMLOT = '"+cNumLote+"'"
	EndIf
	cWhere += '%'

	BeginSql Alias cAliasD0Z
		SELECT SUM(D0Z.D0Z_QTDORI / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D0Z_QTDORI,
				SUM(D0Z.D0Z_QTDEMB / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D0Z_QTDEMB
		FROM %Table:D0Z% D0Z
		LEFT JOIN %Table:D11% D11
		ON D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDORI = D0Z.D0Z_PRDORI
		AND D11.D11_PRDCMP = D0Z.D0Z_PRODUT
		AND D11.%NotDel%
		WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
		AND D0Z.D0Z_EMBARQ = %Exp:cEmbarque%
		AND D0Z.D0Z_PRODUT = %Exp:cProduto%
		AND D0Z.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD0Z)->(!Eof())
		nSldItem := ((cAliasD0Z)->D0Z_QTDORI - (cAliasD0Z)->D0Z_QTDEMB)
	EndIf
	(cAliasD0Z)->(dbCloseArea())
Return nSldItem

//-----------------------------------------
/*/{Protheus.doc} 
Valida se o item existe no embarque
@author Squad WMS/OMS Protheus
@since 11/07/2022
@version 1.0
/*/
//-----------------------------------------
Static Function VldPrLote(cEmbarque,cProduto,cLoteCtl,cNumLote)
Local cAliasD0Z := GetNextAlias()
Local lRet := .T.
Local cWhere := ""

	cWhere := '%'
	If !Empty(cLoteCtl)
		cWhere += " AND D0Z.D0Z_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D0Z.D0Z_NUMLOT = '"+cNumLote+"'"
	EndIf
	cWhere += '%'
	BeginSql Alias cAliasD0Z
		SELECT DISTINCT 1 
		FROM %Table:D0Z% D0Z
		LEFT JOIN %Table:D11% D11
		ON D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDORI = D0Z.D0Z_PRDORI
		AND D11.D11_PRDCMP = D0Z.D0Z_PRODUT
		AND D11.%NotDel%
		WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
		AND D0Z.D0Z_EMBARQ = %Exp:cEmbarque%
		AND D0Z.D0Z_PRODUT = %Exp:cProduto%
		AND D0Z.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD0Z)->(Eof())
		lRet:= .F.
	EndIf
	(cAliasD0Z)->(dbCloseArea())
Return lRet



