#INCLUDE "WMSV090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV09001 "WMSV09001"
#DEFINE WMSV09002 "WMSV09002"
#DEFINE WMSV09003 "WMSV09003"
#DEFINE WMSV09004 "WMSV09004"
#DEFINE WMSV09005 "WMSV09005"
#DEFINE WMSV09006 "WMSV09006"
#DEFINE WMSV09007 "WMSV09007"
#DEFINE WMSV09008 "WMSV09008"
#DEFINE WMSV09009 "WMSV09009"
#DEFINE WMSV09010 "WMSV09010"
#DEFINE WMSV09011 "WMSV09011"
#DEFINE WMSV09012 "WMSV09012"
#DEFINE WMSV09013 "WMSV09013"
#DEFINE WMSV09014 "WMSV09014"
#DEFINE WMSV09015 "WMSV09015"
#DEFINE WMSV09016 "WMSV09016"
#DEFINE WMSV09017 "WMSV09017"
#DEFINE WMSV09018 "WMSV09018"
#DEFINE WMSV09019 "WMSV09019"
#DEFINE WMSV09020 "WMSV09020"
#DEFINE WMSV09021 "WMSV09021"
#DEFINE WMSV09022 "WMSV09022"
#DEFINE WMSV09023 "WMSV09023"
#DEFINE WMSV09024 "WMSV09024"
#DEFINE WMSV09025 "WMSV09025"
#DEFINE WMSV09026 "WMSV09026"
#DEFINE WMSV09027 "WMSV09027"
#DEFINE WMSV09028 "WMSV09028"
#DEFINE WMSV09029 "WMSV09029"
#DEFINE WMSV09030 "WMSV09030"
#DEFINE WMSV09031 "WMSV09031"
#DEFINE WMSV09032 "WMSV09032"
#DEFINE WMSV09033 "WMSV09033"

Static __WV090VLP  := ExistBlock("WV090VLP")
Static __WV090VLQ  := ExistBlock("WV090VLQ")
Static __WV090UNI  := ExistBlock("WV090UNI")
Static __cWmsLcEx  := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnEx  := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso
Static __lUnitiza  := .F.
Static __lSolEnd   := .T.
Static oMntUniItem := Nil
Static __QtExcUni  := 0
Static __aItsUni   := {}
Static __lWmsDtCF  := SuperGetMV('MV_WMSDTCF',.F.,.F.) // Solicita data de validade do lote se este não existe?
Static lDtValid    := DCY->(ColumnPos("DCY_DTVAL")) > 0
Static lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)
//------------------------------------------------------------
/*/{Protheus.doc} WMSV090
Conferencia de recebimento de documentos de entrada.
@author alexsander.correa
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
Function WMSV090()
Local cKey09    := VtDescKey(09)
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local bkey09    := VTSetKey(09)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local lRet      := .T.
Local aEmbarque := {}
Local cEmbarque := Space(Len(DCZ->DCZ_EMBARQ))
Local lWmsCRD := SuperGetMV("MV_WMSCRD",.F.,.F.)

	If !IntWMS() .And. !lWmsCRD
		WMSVTAviso(WMSV09015,STR0034) // Permitida utilização somente com Integração com o WMS (MV_INTWMS) ou integração com a conferência de recebimento WMS (MV_WMSCRD)!
		Return
	EndIf
	// Avalia se os parâmetros estão preenchidos e informa o usuário
	WMSA320Par()
	Do While .T.
		// Bloqueia Tecla Estorno
		VTSetKey(24)
		cEmbarque := Space(Len(DCZ->DCZ_EMBARQ))
		VtClear()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		@ 01,00  VTSay STR0036 //Recebimento:
		@ 02, 00 VTGet cEmbarque Valid VldEmb(@cEmbarque)
		VTRead()
		If VTLastKey() == 27
			Exit
		EndIf
		If Empty(cEmbarque)
			LoadCofRec(@aEmbarque)
			If Empty(aEmbarque)
				WMSVTAviso(WMSV09001,STR0002) // Não existem conferências de recebimento pendentes para execução.
				VtKeyboard(Chr(20))
				lRet := .F.
				Exit
			Else
				VtClearBuffer()
				WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
				nPos:=VTaBrowse(1,,,,{STR0003},aEmbarque,{20}) // Recebimento

				If VTLastKey() == 27
					Exit
				EndIf
				cEmbarque:= aEmbarque[nPos,1]
			EndIf
		EndIf
		// Efetua a conferencia dos produtos deste embarque
		If lRet
			VTSetKey(24,{|| CofPrdLot(cEmbarque,.T.)}, STR0004) // Estorno
			CofPrdLot(cEmbarque)
		EndIf
	EndDo
	// Restaura as teclas de talhao
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
Return
/*--------------------------------------------------------------------------------
---LoadCofRec
---Monta embarques disponíveis para conferencia
---Alexsander Correa - 01/04/2015
---aEmbarque, Array (aEmbarque - codigo embarque, Caracter
                               - data geraçã0, Data)
----------------------------------------------------------------------------------*/
Static Function LoadCofRec(aEmbarque)
Local cAliasDCW := GetNextAlias()
	aEmbarque := {}
	BeginSql Alias cAliasDCW
		SELECT DCW.DCW_EMBARQ,
				DCW.DCW_DATGER
		FROM %Table:DCW% DCW
		WHERE DCW.DCW_FILIAL = %xFilial:DCW%
		AND DCW.DCW_SITEMB IN ('1','3','4','5')
		AND DCW.%NotDel%
	EndSql
	TCSetField(cAliasDCW,'DCW_DATGER','D',)
	Do While !(cAliasDCW)->( Eof() )
		Aadd(aEmbarque,{(cAliasDCW)->DCW_EMBARQ,DTOC((cAliasDCW)->DCW_DATGER)})
		(cAliasDCW)->(dbSkip())
	EndDo
	(cAliasDCW)->(dbCloseArea())
Return .T.
/*--------------------------------------------------------------------------------
---CofPrdLot
---Permite efetuar a conferência dos produtos de um processo
---até que o usuário escolha a opção de finalizar a conferência.
---Jackson Patrick Werka - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
---lEstorno, Logico, (Indica se é estorno)
----------------------------------------------------------------------------------*/
Static Function CofPrdLot(cEmbarque,lEstorno)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
// Ativa teclas de atalho
Local bkey09    := VTSetKey(9, {|| ShowPrdCof(cEmbarque)}, STR0016) // Produto
Local bkey15    := VTSetKey(15,{|| ShowOpeCof(cEmbarque)}, STR0014) // Operador
Local bkey21    := VTSetKey(21)
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local lEncerra  := .F.
Local lAbandona := .F.
Local lQtdBar   := .f.
Local lNewUnit  := .T.
Local lRastro   := .F.
Local cWmsUMI   := ""
Local cCodBar   := ""
Local cProduto  := ""
Local cPrdOri   := ""
Local cPrdAnt   := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cArmazem  := ""
Local cEndereco := ""
Local cTipUni  := ""
Local cIdUnit   := ""
Local cPictQt   := ""
Local cUM       := ""
Local cDscUM    := ""
Local cKey09    := VtDescKey(09)
Local cKey15    := VtDescKey(15)
Local cKey21    := VtDescKey(21)
Local nQtConf   := 0.00
Local nItem     := 0
Local nAviso    := 0
Local nLin      := 0
Local nCont     := 0
Local lArmdif   := LeArmDif(cEmbarque)
Local lVoltaTl  := .F.
Local dDtVal    := cToD("")
Default lEstorno := .F.

	IF ExistBlock("WV090TCI")
		ExecBlock("WV090TCI",.F.,.F.,{cEmbarque,lEstorno})
	EndIF

	Do While !lEncerra .And. !lAbandona
		lVoltaTl  := .F.
		cArmazem  := Space(Len(DCZ->DCZ_LOCAL))
		cEndereco := Space(TamSX3("BE_LOCALIZ")[1])
		If WmsX212118("D0R")
			cTipUni   := Space(TamSX3("D0R_CODUNI")[1])
			cIdUnit   := Space(TamSX3("D0R_IDUNIT")[1])
		EndIf
		nQtConf   := 0.00

		//   01234567890123456789
		// 0 ____Conferência_____
		// 1 Recebimento: 000000
		// 2 Informe o Armazém
		// 3 01
		// 4 Informe o Endereço
		// 5 DOCA
		WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
		@ 01,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
		@ 02,00  VTSay STR0039 // Informe o Armazém
		@ 03,00  VtGet cArmazem Picture "@!" Valid ValidArm(cEmbarque,cArmazem,@cEndereco)
		VtRead
		If VTLastKey() != 27 .And. __lUnitiza
			@ 04,00  VTSay STR0040 // Informe o Endereço
			@ 05,00  VtGet cEndereco Picture "@!" Valid ValidEnd(cEmbarque,cArmazem,cEndereco) When __lSolEnd
			VtRead
		EndIf
		If VTLastKey()==27
			If !lEstorno
			nAviso := WMSVTAviso(WMSV09002,STR0010,{STR0012,STR0013}) // Deseja encerrar a conferencia? // Encerrar // Interromper
			Else
				Exit
			EndIf
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf
		Do While !lVoltaTl .And. !lEncerra .And. !lAbandona
			//   01234567890123456789
			// 0 ____Conferência_____
			// 1 Recebimento: 000000
			// 2 Informe o Untiz
			// 3 000001
			// 4 Tipo Unitz
			// 5 123456
			If __lUnitiza
				// Seta o armazém e endereço
				If oMntUniItem == Nil
					oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
				EndIf
				oMntUniItem:oUnitiz:SetArmazem(cArmazem)
				oMntUniItem:oUnitiz:SetEnder(cEndereco)
				lNewUnit := .T.
				// Solicita o unitizador a ser conferido
				If !GetUniti(cEmbarque,cArmazem,cEndereco,@cIdUnit,@cTipUni,lEstorno,@lNewUnit)
					If !lEstorno .And. !lArmdif
						nAviso := WMSVTAviso(WMSV09002,STR0010,{STR0012,STR0013}) // Deseja encerrar a conferencia? // Encerrar // Interromper
						If nAviso == 1
							lEncerra := .T.
							Exit
						ElseIf nAviso == 2
							lAbandona  := .T.
							Exit
						Else
							Loop
						EndIf
					Else
						lVoltaTl := .T. 
						Exit
					EndIf
				Else
					// Tratamentos para quando 
					If __WV090UNI .And. Len(__aItsUni) > 0
						__aItsUni := {} // Libera memória
						Loop
					EndIf
					VTSetKey(21,{|| GetUniti(cEmbarque,cArmazem,cEndereco,@cIdUnit,@cTipUni,lEstorno,@lNewUnit,.T.)}, STR0043) // Ctrl+U // Unitizador
					VTSetKey(09,{|| ShowItens(cIdUnit,cEmbarque)}, STR0044) // Ctrl+I // Itens Unitiz.
				EndIf
				If lEstorno .AND. !VlCmpUnit(cIdUnit)
					WMSVTAviso(WMSV09032,STR0066) //"Unitizador contém produto componente. Utilize o monitor de conferência para estorno." 
					lVoltaTl := .T. 
					Exit
				EndIf
			EndIf
			Do While !lVoltaTl .And. !lEncerra .And. !lAbandona 
				//   01234567890123456789
				// 0 ____Conferência_____
				// 1 Recebimento: 000000
				// 2 Unitizador: UN0001
				// 3 Informe o Produto
				// 4 PA1
				// 5 Lote: AUTO000636
				// 6 Sub-Lote: 000000
				// 7 Informe a Qtde
				// 8               240.00
				VtClear()
				VtClearBuffer()
				lNewUnit  := .F.
				cCodBar   := Space(128)
				cProduto  := Space(Len(DCZ->DCZ_PROD))
				cPrdOri   := Space(Len(DCZ->DCZ_PRDORI))
				cLoteCtl  := Space(Len(DCZ->DCZ_LOTE))
				cNumLote  := Space(Len(DCZ->DCZ_SUBLOT))
				nCont     := 0
				nLin      := 1
				dDtVal    := cToD("")
				WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
				@ nLin++,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
				If __lUnitiza
					If Len(cIdUnit) == 6
						@ nLin++,00  VtSay STR0045 + cIdUnit // Unitizador:
					ElseIf Len(cIdUnit) <= 16
						@ nLin++,00  VtSay "ID: " + cIdUnit // Unitizador:
					Else
						@ nLin++,00  VtSay cIdUnit // Unitizador:
					EndIf
				EndIf
				@ nLin++,00  VTSay STR0005 // Informe o Produto
				@ nLin++,00  VtGet cCodBar Picture "@!" Valid ValidPrdLot(cEmbarque,cArmazem,cEndereco,@cProduto,@cLoteCtl,@cNumLote,@nQtConf,@cCodBar,@dDtVal)
				// Descricao do Produto com tamanho especifico.
				VtRead()
				If VTLastKey()==27
					If __lUnitiza
						If lNewUnit
							Loop
						Else
							Exit
						EndIf
					Else
						If !lEstorno .And. !lArmdif
							nAviso := WMSVTAviso(WMSV09002,STR0010,{STR0012,STR0013}) // Deseja encerrar a conferencia? // Encerrar // Interromper
							If nAviso == 1
								lEncerra := .T.
								Exit
							ElseIf nAviso == 2
								lAbandona  := .T.
								Exit
							Else
								Loop
							EndIf
						Else
						    lVoltaTl := .T. 
							Exit
						EndIf
					EndIf
				EndIf
				If !lEncerra .And. !lAbandona

					dbSelectArea('DCW')
					DCW->(dbSetOrder(1))//DCW_FILIAL+DCW_EMBARQ
					DCW->( dbSeek(xFilial('DCW')+cEmbarque) )

					// Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
					If (lRastro := Rastro(cProduto))
						@ nLin,00  VtSay STR0037 // Lote
						@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid !Empty(cLoteCtl)
						//Solicita lote apenas quando a conferência for de Pré-Nota
						If DCW->DCW_TPCONF == "2" .And. Rastro(cProduto,"S")
							@ nLin,00 VTSay STR0038 // Sub-Lote
							@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid !Empty(cNumLote)
						EndIf
						VtRead()
					EndIf
					
					cPrdOri := AvaliaProd(cEmbarque,cProduto,cLoteCtl,cNumLote,lEstorno)

					If lDtValid .And. lRastro .And. Empty(dDtVal)
						dDtVal := GetDtVal(cEmbarque, cArmazem, cPrdOri, cLoteCtl, cNumLote)
					EndIf
					//Solicita data de validade do lote, caso não exista na DCY ou SB8
					If lRastro .And. lDtValid .And. __lWmsDtCF
						If Empty(dDtVal)
							If (nLin + 2) > VTMaxRow()
								@ nLin,00 VTSay STR0064 //Dt. Val.: 
								@ nLin,Len(STR0064) VTGet dDtVal Picture "@D" When Empty(dDtVal) Valid !Empty(dDtVal)
								nLin++
							Else
								@ nLin++,00 VTSay PadR(STR0065,VTMaxCol()) //Data de Validade: 
								@ nLin++,00 VTGet dDtVal Picture "@D" When Empty(dDtVal) Valid !Empty(dDtVal)
							EndIf
							VtRead()
						EndIf
					EndIf

					If VTLastKey()==27
						Loop // Volta para o inicio do produto
					EndIf
				EndIf
				// Verifica se quantidade já preenchida via etiqueta
				lQtdBar := (nQtConf >0)
				If lQtdBar
					cPrdAnt := Space(TamSx3("D12_PRODUT")[1])
				EndIf
				If !lEncerra .And. !lAbandona
					If ((cProduto <> cPrdAnt) .Or. lWMSConf)
						//  Carrega unidade de medida, simbolo da unidade e quantidade na unidade
						WmsValUM(@Nil,;     // Quantidade movimento
								@cWmsUMI,;  // Unidade parametrizada
								cProduto,;  // Produto
								Nil,;       // Armazem
								Nil,;       // Endereço
								Nil,;       // Item unidade medida
								.T.,;       // Indica se é uma conferência
								lQtdBar)    // Indica se quantidade já preenchida
						// Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
						If (QtdComp(nQtConf) <= QtdComp(0))
							//  Seleciona unidade de medida
							WmsSelUM(cWmsUMI,; // Unidade parametrizada
									@cUM,;      // Unidade medida reduzida
									@cDscUM,;   // Descrição unidade medida
									Nil,;       // Quantidade movimento
									@nItem,;    // Item seleção unidade
									@cPictQt,;  // Mascara unidade medida
									Nil,;       // Quantidade no item seleção unidade
									.T.,;       // Indica se é uma conferência
									STR0001,;   // Descrição da tarefa
									Nil,;       // Armazem
									Nil,;       // Endereço
									cProduto,;  // Produto Origem
									cProduto,;  // Produto
									cLoteCtl,;  // Lote
									cNumLote,;  // sub-lote
									lQtdBar)    // Indica se quantidade já preenchida
							If (VTLastKey()==27)
								Loop
							EndIf
						EndIf
						cPrdAnt := cProduto
					EndIf
				EndIf
				If !lEncerra .And. !lAbandona
					If VTLastKey()==27
						Loop
					EndIf
					// Validações do produto quando o armazém controla unitizador
					If  __lUnitiza
						oMntUniItem:SetPrdOri(cPrdOri)
						oMntUniItem:SetProduto(cProduto)
						oMntUniItem:SetLoteCtl(cLoteCtl)
						oMntUniItem:SetNumLote(cNumLote)
						oMntUniItem:SetUsaD0Q(.F.)
						If !oMntUniItem:VldPrdUni(lEstorno)
							WMSVTAviso(WMSV09029,oMntUniItem:GetErro())
							Loop
						EndIf
					EndIf
					If VTLastKey()==27
						Loop
					EndIf
					If (nLin + 1) > VTMaxRow()
						@ nLin,00 VTSay STR0011+': '
						@ nLin,Len(STR0011+': ') VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid nQtConf > 0
					Else
						@ nLin++,00 VTSay PadR(STR0011+' '+cDscUM,VTMaxCol())
						@ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid nQtConf > 0
					EndIf
					VTRead()
					If VTLastKey()==27 .Or. QtdComp(nQtConf) <= 0
						Loop
					EndIf
					If !ValidQtd(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,@nQtConf,lEstorno,nItem,cArmazem,cIdUnit,cTipUni,dDtVal)
						Loop
					EndIf
				EndIf
				// Somente grava a quantidade se o usuário não cancelar
				If !lEncerra .And. !lAbandona
					VTMsg(STR0033) // Processando...
					GravCofOpe(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,cArmazem,cEndereco,cIdUnit,cTipUni,dDtVal)
				EndIf
				// Se for estorno, sai ao executar a primeira vez
				If lEstorno
					Exit
				EndIf
			EndDo
			// Se for estorno, sai ao executar a primeira vez
			If lEstorno
				Exit
			EndIf
		EndDo
		// Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
		If lEncerra
			lEncerra := FinCofRec(cEmbarque)
		EndIf
	EndDo
	// Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(21,bkey21,cKey21)
	If ExistBlock("WV090TCF")
		ExecBlock("WV090TCF",.F.,.F.,{cEmbarque,lEstorno})
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdCof
---Apresenta produtos da conferencia
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ShowPrdCof(cEmbarque)
Local lRet     := .T.
Local aProduto := {}
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	DCY->( dbSetOrder(1) )
	DCY->( dbSeek(xFilial('DCY')+cEmbarque) )
	While !DCY->( Eof() ) .And. DCY->DCY_FILIAL == xFilial('DCY') .And. DCY->DCY_EMBARQ == cEmbarque
		If QtdComp(DCY->DCY_QTCONF) > 0
			Aadd(aProduto,{IIf(DCY->DCY_QTORIG <> DCY->DCY_QTCONF,'*',' '),DCY->DCY_LOCAL,DCY->DCY_PROD,Posicione('SB1',1,xFilial('SB1')+DCY->DCY_PROD,'SB1->B1_DESC'),DCY->DCY_LOTE,DCY->DCY_SUBLOT,DCY->DCY_QTCONF})
		EndIf
		DCY->( dbSkip() )
	EndDo
	VtClearBuffer()
	WMSVTCabec(STR0001,.F.,.F.,.T.) // Produto
	nPos:=VTaBrowse(1,,,,{' ',STR0056,STR0016,STR0017,STR0018,STR0019,STR0020},aProduto,{1,TamSx3("DCY_LOCAL")[1],TamSx3("DCY_PROD")[1],30,TamSx3("DCY_LOTE")[1],TamSx3("DCY_SUBLOT")[1],11})// Armazém|Produto|Descrição|Lote|Sub-Lote|Qtde Conferida
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ShowOpeCof
---Apresenta os operados dos produtos conferidos
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (cEmbarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ShowOpeCof(cEmbarque)
Local lRet      := .T.
Local cAliasDCZ := GetNextAlias()
Local aOperador := {}
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	// Movimento do SF1
	BeginSql Alias cAliasDCZ
		SELECT DISTINCT DCZ.DCZ_OPER,
				DCD.DCD_NOMFUN
		FROM %Table:DCZ% DCZ
		INNER JOIN %Table:DCD% DCD
		ON DCD.DCD_FILIAL = %xFilial:DCD%
		AND DCD.DCD_CODFUN = DCZ.DCZ_OPER
		AND DCD.%NotDel%
		WHERE DCZ_FILIAL = %xFilial:DCZ%
		AND DCZ.DCZ_EMBARQ = %Exp:cEmbarque%
		AND DCZ.%NotDel%
		ORDER BY DCZ.DCZ_OPER
	EndSql
	Do While (cAliasDCZ)->(!Eof())
		AAdd(aOperador,{(cAliasDCZ)->DCZ_OPER,(cAliasDCZ)->DCD_NOMFUN})
		(cAliasDCZ)->( DBSkip() )
	EndDo
	(cAliasDCZ)->( DBCloseArea() )
	If Empty(aOperador)
		WMSVTAviso(WMSV09003,STR0030) // Nao foi realizada nenhuma conferencia por nenhum operador.
		VtKeyboard(Chr(20))
		lRet := .F.
	Else
		VtClearBuffer()
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		nPos:=VTaBrowse(1,,,,{STR0014,STR0015},aOperador,{TamSx3("DCZ_OPER")[1],30}) // Operador // Nome
		VTKeyBoard(chr(20))
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence a alguma
---distribuição de separação que está pendente ou em andamento
---Jackson Patrick Werka - 01/04/2015
---cEmbarque, character, (Embarque da conferência de recebimento)
---cArmazem, character, (Armazem no qual o produto se encontra)
---cEndereco, character, (Endereco no qual o produto se encontra)
---cProduto, character, (Produto informado)
---cLoteCtl, character, (Lote etiqueta)
---cNumLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---cCodBar, character, (Codigo de barras)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cEmbarque,cArmazem,cEndereco,cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,dDtVal)
Local lRet     := .T.
Local lRetPE   := .T.
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())

	lRet := !Empty(cCodBar)
	If lRet
		lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtde,@cCodBar,,,,@dDtVal)
	EndIf
	// Ponto de entrada para validações complementares do produto
	If lRet .And. __WV090VLP
		lRetPE := ExecBlock("WV090VLP",.F.,.F.,{cEmbarque,cProduto,cLoteCtl,cNumLote,nQtde})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	If lRet
		// Monta tela produto
		WmsMontPrd( Nil,;       // Unidade parametrizada
					.T.,;       // Indica se é uma conferência
					STR0001,;   // Descrição da tarefa
					cArmazem,;  // Armazem
					cEndereco,; // Endereço
					cProduto,;  // Produto Origem
					cProduto,;  // Produto
					cLoteCtl,;  // Lote
					cNumLote,;  // sub-lote
					Nil,;       // Id Unitizador
					nQtde)      // Quantidade preenchida
	EndIf
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida a digitação da quantidade
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
---cCodOpe, character, (Operador da  conferencia de recebimento)
---cPrdOri, character, (Produto origem da  conferencia de recebimento)
---cProduto, character, (Produto da conferencia de recebimento)
---cLoteCtl, character, (Lote do produto da conferencia de recebimento)
---cNumLote, character, (Sub-lote do lote do produto da conferencia de recebimento)
---nQtConf, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
---dDtVal, Data, (Data de validade do lote)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,nItem,cArmazem,cIdUnit,cTipUni,dDtVal)
Local lRet      := .T.
Local lRetPE    := .T.
Local cAliasDCY := Nil
Local nQuant    := 0
Local nQtdAnt   := nQtConf
Local lWmsNpCp  := SuperGetMV("MV_WMSNPCP",.F.,.F.)

	// Converter de 2a.UM p/ 1a.UM
	If nItem == 2
		nQtConf := ConvUm(cProduto,0,nQtConf,1)
	EndIf
	//Validações do quantidade que será inserida no unitizador
	If __lUnitiza
		If !(lRet := oMntUniItem:VldQtdSld(nQtConf,lEstorno))
			WMSVTAviso(WMSV09021,oMntUniItem:GetErro()) // Erro do objeto
		EndIf
	EndIf
	// Ponto de entrada para validações complementares de quantidade
	If lRet .And. !lEstorno .And. __WV090VLQ
		lRetPE := ExecBlock("WV090VLQ",.F.,.F.,{cEmbarque,cProduto,cLoteCtl,cNumLote,nQtConf,dDtVal,cArmazem})
		If ValType(lRetPE) == "L"
			lRet := lRetPE
		EndIf
	EndIf
	// Verificar produto com excesso que não estão na nota e o parâmetro MV_WMSNPCP restrige a conferência
	If lRet .And. !lWmsNew .And. !lEstorno .AND. lWmsNpCp
		cAliasDCY := GetNextAlias()
		BeginSql Alias caliasDCY
			SELECT Distinct 1
			FROM %Table:DCY% DCY
			WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			AND DCY.DCY_PRDORI = %Exp:cPrdOri% 
			AND DCY.DCY_PROD = %Exp:cProduto%
			AND DCY.%NotDel%
		EndSql
		If (cAliasDCY)->(Eof())
			WmsMessage(STR0063,WMSV09031,2) //"Produto não pertence a prenota ou documento de entrada relacionado à conferência."
			lRet := .F.
		EndIf
		(cAliasDCY)->(dbCloseArea())
	EndIf			
	If lRet .And. lWmsNew .And. !lEstorno
		lRet := GeraExcesso(cEmbarque,cLoteCtl,cNumLote,cArmazem,@nQtConf,cProduto,cPrdOri,cCodOpe,cIdUnit,cTipUni,dDtVal)
	EndIf
	If lRet .And. lEstorno
		DCZ->( dbSetOrder(1) )
		cAliasDCY := GetNextAlias()
		If lWmsNew
			BeginSql Alias cAliasDCY
				SELECT DCY.DCY_PRDORI,
						DCY.DCY_PROD,
						D11.D11_QTMULT
				FROM %Table:DCY% DCY
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = DCY_PRDORI
				AND D11.D11_PRDCMP = DCY_PROD
				AND D11.%NotDel%
				WHERE DCY.DCY_FILIAL = %xFilial:DCY%
				AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				AND DCY.DCY_PRDORI = %Exp:cProduto%
				AND DCY.DCY_PRDORI <> DCY_PROD
				AND DCY.DCY_LOTE = %Exp:cLoteCtl%
				AND DCY.DCY_SUBLOT = %Exp:cNumLote%
				AND DCY.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasDCY
				SELECT DCY.DCY_PRDORI,
						DCY.DCY_PROD
				FROM %Table:DCY% DCY
				WHERE DCY.DCY_FILIAL = %xFilial:DCY%
				AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				AND DCY.DCY_PRDORI = %Exp:cProduto%
				AND DCY.DCY_PRDORI <> DCY_PROD
				AND DCY.DCY_LOTE = %Exp:cLoteCtl%
				AND DCY.DCY_SUBLOT = %Exp:cNumLote%
				AND DCY.%NotDel%
			EndSql
		EndIf
		If (cAliasDCY)->(!Eof() )
			Do While (cAliasDCY)->(!Eof())
				nQuant := IIf(lWmsNew, nQtConf * (cAliasDCY)->D11_QTMULT, nQtConf)
				If !DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+(cAliasDCY)->DCY_PRDORI+(cAliasDCY)->DCY_PROD+cLoteCtl+cNumLote) )
					WMSVTAviso(WMSV09006,STR0022) // Não existe qtd conferida para este operador/produto.
					VtKeyboard(Chr(20))
					lRet := .F.
					Exit
				Else
					If QtdComp(nQuant) > QtdComp(DCZ->DCZ_QTCONF)
						WMSVTAviso(WMSV09007,STR0023) // Quantidade à estornar maior que a qtd conferida.
						VtKeyboard(Chr(20))
						lRet := .F.
						Exit
					EndIf
				EndIf
				(cAliasDCY)->(dbSkip())
			EndDo
		Else
			If !DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+cPrdOri+cProduto+cLoteCtl+cNumLote) )
				WMSVTAviso(WMSV09006,STR0022) // Não existe qtd conferida para este operador/produto.
				VtKeyboard(Chr(20))
				lRet := .F.
			Else
				If QtdComp(nQtConf) > QtdComp(DCZ->DCZ_QTCONF)
					WMSVTAviso(WMSV09007,STR0023) // Quantidade à estornar maior que a qtd conferida.
					VtKeyboard(Chr(20))
					lRet := .F.
				EndIf
			EndIf
		EndIf
		(cAliasDCY)->(dbCloseArea())
	EndIf
	//Se retornou falso retorna para a unidade que o usuário informou para mostrar em tela
	If !lRet
		nQtConf := nQtdAnt
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---GravCofOpe
---Grava conferencia
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
---cCodOpe, character, (Operador da  conferencia de recebimento)
---cPrdOri, character, (Produto origem da  conferencia de recebimento)
---cProduto, character, (Produto da conferencia de recebimento)
---cLoteCtl, character, (Lote do produto da conferencia de recebimento)
---cNumLote, character, (Sub-lote do lote do produto da conferencia de recebimento)
---nQtConf, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function GravCofOpe(cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,cArmazem,cEndereco,cIdUnit,cTipUni,dDtVal)
Local aProdComp  := {}
Local nQtConfPai := 0
Local nI         := 0
Local oProdComp  := Nil
Local lRet       := .T.
Local cProdConf  := ""

	// Verifica situação do embarque
	DCW->( dbSetOrder(1) )
	If DCW->( dbSeek(xFilial('DCW')+cEmbarque) )
		If DCW->DCW_SITEMB $ '6|7|8'
			WMSVTAviso(WMSV09008,STR0024) // Conferência já finalizada por outro processo!
			VtKeyboard(Chr(20))
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09009,STR0025) // Número recebimento informado não cadastrado.
		lRet := .F.
	EndIf
	If lRet
		Begin Transaction
			If lWmsNew
				// Grava array apenas de produtos conferidos
				oProdComp := WMSDTCProdutoComponente():New()
				oProdComp:SetProduto(cPrdOri)
				oProdComp:SetPrdOri(cPrdOri)
				oProdComp:EstProduto()
				aProdComp := oProdComp:GetArrProd()
				//Tratamentos para gravar ou estornar unitizador.
				If __lUnitiza
					If !lEstorno
						For nI := 1 To Len(aProdComp)
							If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
								oMntUniItem:oUnitiz:SetIdUnit(cIdUnit)
								oMntUniItem:oUnitiz:SetTipUni(cTipUni)
								oMntUniItem:SetProduto(aProdComp[nI][1])
								oMntUniItem:SetPrdOri(aProdComp[nI][3])
								oMntUniItem:SetLoteCtl(cLoteCtl)
								oMntUniItem:SetNumLote(cNumLote)
								oMntUniItem:SetQuant(IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf))
								oMntUniItem:oUnitiz:SetStatus('5')
								If !oMntUniItem:IsDad()
									If !oMntUniItem:AssignD0S()
										WMSVTAviso(WMSV09033,oMntUniItem:GetErro())
										lRet := .F. 
									EndIF
								EndIf
							EndIf
						Next nI
						__QtExcUni := 0
					Else
						For nI := 1 To Len(aProdComp)
							WMSA320EST(cEmbarque,aProdComp[nI][3],aProdComp[nI][1],cLoteCtl,cNumLote,cIdUnit,cCodOpe,.F.,IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf))
						Next nI
					EndIf
				EndIf
				//Calcula a quantidade do produto pai, quando o produto informado for um filho
				nQtConfPai := CalcQtdConf(nQtConf,cPrdOri,cProduto,cLoteCtl,cNumLote,cArmazem,cEmbarque)
			Else
				nQtConfPai := CalcQtdConf(nQtConf,cPrdOri,cProduto,cLoteCtl,cNumLote,cArmazem,cEmbarque)
				aAdd(aProdComp,{cProduto,1,cProduto})
				cProdConf := cProduto
			EndIf
			If lRet
				//Realiza rateio da quantidade origem das linhas da DCY e grava registros
				RateioConf(lEstorno,cEmbarque,aProdComp,cProduto,cPrdOri,cLoteCtl,cNumLote,cArmazem,cIdUnit,cCodOpe,nQtConfPai,nQtConf,dDtVal)
				// Atualiza informações embarque
			   lRet := A320COFDCY(cEmbarque,.F.,lEstorno,cProdConf)
			EndIf 
			If !lRet
				DisarmTransaction()
				Break
				WMSVTAviso(WMSV09010,STR0026) // Não foi possível registrar a quantidade.
			EndIf
		End Transaction
		MsUnLockALL()
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---RateioConf
---Realiza rateio da quantidade origem e grava DCY/DCZ
---Amanda Rosa Vieira
----------------------------------------------------------------------------------*/
Static Function RateioConf(lEstorno,cEmbarque,aProdComp,cProduto,cPrdOri,cLoteCtl,cNumLote,cArmazem,cIdUnit,cCodOpe,nQtConfPai,nQtConf,dDtVal)
Local nI         := 1
Local nDiferenca := 0
Local nQtdOri    := 0
Local lContinua  := .T.
Local lRet       := .T.
Local lWMA320DT  := ExistBlock("WMA320DT")

	//Ajusta DCY e DCZ
	For nI := 1 To Len(aProdComp)
		If !lEstorno
			nDiferenca := 0
			//Ajusta DCY
			If !DCY->( dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+cLoteCtl+cNumLote+cArmazem) )
				//Zera quantidade origem
				nQtdOri := 0
				//Caso não seja uma conferência de excesso e não tenha encontrado uma linha da DCY correspondente ao lote,
				//procura sem o lote e então desconta a quantidade origem para criar uma nova linha na DCY
				If DCY->( dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+Space(TamSX3("DCY_LOTE")[1])+Space(TamSX3("DCY_SUBLOT")[1])+cArmazem) )
					RecLock('DCY',.F.)
					DCY->DCY_QTORIG -= (nQtConfPai*aProdComp[nI][2])
					DCY->(MsUnLock())
					nQtdOri := nQtConfPai*aProdComp[nI][2]
				EndIf
				RecLock('DCY',.T.)
				DCY->DCY_FILIAL := xFilial('DCY')
				DCY->DCY_EMBARQ := cEmbarque
				DCY->DCY_PRDORI := aProdComp[nI][3]
				DCY->DCY_PROD   := aProdComp[nI][1]
				DCY->DCY_LOTE   := cLoteCtl
				DCY->DCY_SUBLOT := cNumLote
				DCY->DCY_LOCAL  := cArmazem
				DCY->DCY_QTORIG := nQtdOri
				If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
					DCY->DCY_QTCONF := IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				Else
					DCY->DCY_QTCONF := 0
				EndIf
				If lDtValid .And. !Empty(dDtVal)
					DCY->DCY_DTVAL  := dDtVal
				EndIf
				DCY->(MsUnLock())

				If lWMA320DT
					ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
				EndIf
			Else
				nQtdOri :=  nQtConfPai*aProdComp[nI][2]
				nQtdOri := IIF(QtdComp(nQtdOri) > QtdComp(DCY->DCY_QTORIG),nQtdOri,DCY->DCY_QTORIG)
				nDiferenca := IIF(nQtdOri  > DCY->DCY_QTORIG,nQtdOri - DCY->DCY_QTORIG,0)
				RecLock('DCY',.F.)
				If (cProduto == aProdComp[nI][1]) .Or. (cProduto == aProdComp[nI][3])
					DCY->DCY_QTCONF += IIf(cProduto== aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				EndIf
				DCY->DCY_QTORIG := nQtdOri
				DCY->(MsUnLock())

				If lWMA320DT
					ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
				EndIf
		
				//Verifica se a quantidade origem aumentou
				If QtdComp(nDiferenca) > 0
					//Ajusta quantidade origem da linha da DCY que não possui lote informado
					If DCY->(dbSeek(xFilial('DCY')+cEmbarque+aProdComp[nI][3]+aProdComp[nI][1]+Space(TamSX3("DCY_LOTE")[1])+Space(TamSX3("DCY_SUBLOT")[1])+cArmazem) )
						RecLock('DCY',.F.)
						DCY->DCY_QTORIG -= nDiferenca
						DCY->(MsUnLock())
					EndIf
				EndIf
			EndiF
			lContinua := .F.
			If cProduto <> cPrdOri
				If cProduto == aProdComp[nI][1]
					lContinua := .T.
				EndIf
			Else
				lContinua := .T.
			EndIf
		EndIf
		//Ajusta DCZ
		If lContinua
			If DCZ->( dbSeek(xFilial('DCZ')+cEmbarque+cCodOpe+aProdComp[nI][3]+aProdComp[nI][1]+cLoteCtl+cNumLote+cArmazem+cIdUnit) )
				RecLock('DCZ', .F.)
				If lEstorno
					DCZ->DCZ_QTCONF -= IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				Else
					DCZ->DCZ_QTCONF += IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				EndIf
				DCZ->(MsUnLock())
			Else
				RecLock('DCZ',.T.)
				DCZ->DCZ_FILIAL := xFilial('DCZ')
				DCZ->DCZ_EMBARQ := cEmbarque
				DCZ->DCZ_OPER   := cCodOpe
				DCZ->DCZ_PRDORI := aProdComp[nI][3]
				DCZ->DCZ_PROD   := aProdComp[nI][1]
				DCZ->DCZ_LOTE   := cLoteCtl
				DCZ->DCZ_SUBLOT := cNumLote
				DCZ->DCZ_QTCONF := IIf(cProduto == aProdComp[nI][3],(nQtConf * aProdComp[nI][2]),nQtConf)
				DCZ->DCZ_LOCAL  := cArmazem
				If __lUnitiza
					DCZ->DCZ_IDUNIT := cIdUnit
				EndIf
				If lDtValid .And. !Empty(dDtVal)
					DCZ->DCZ_DTVAL  := dDtVal
				EndIf
				DCZ->(MsUnLock())
			EndIf
		EndIf
	Next nI
Return lRet
/*--------------------------------------------------------------------------------
---FinCofRec
---Verifica/Finaliza conferencia de embarque
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function FinCofRec(cEmbarque)
Local aAreaDCW := DCW->( GetArea() )
Local lRet     := .T.
Local aBoxDCW  := RetSx3Box(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),,,1)
	DCW->( dbSetOrder(1) )
	If DCW->( dbSeek(xFilial('DCW')+cEmbarque) )
		WMSVTCabec(STR0001,.F.,.F.,.T.)
		@ Int(VTMaxRow()/2), 00 VtSay STR0033 // Processando...
		If Wms320FiCo()
			//   01234567890123456789
			// 0 ____Conferência_____
			// 1 Recebimento: 000000
			// 2 --------------------
			// 3 Conferido
			// 4 --------------------
			VtClear()
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
			//Mostra Dados
			@ 01,00  VTSay STR0003 + ': ' + cEmbarque // Embarque
			@ 02,00  VTSay Replicate('-',VTMaxCol())
			@ 03,00  VtSay aBoxDCW[Val(DCW->DCW_SITEMB) , 3 ]
			@ 04,00  VTSay Replicate('-',VTMaxCol())
			WMSVTRodPe()
		Else
			WMSVTAviso(WMSV09013,STR0029) // Não foi possível finalizar a conferência.
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09014,STR0025) // Número recebimento informado não cadastrado.
		lRet := .F.
	EndIf
	RestArea(aAreaDCW)
Return lRet
//-------------------------------------------------
// Valida número do embarque
//-------------------------------------------------
Static Function VldEmb(cEmbarque)
Local lRet      := .T.
Local cAliasDCW := GetNextAlias()
	//Se o número do embarque está vazio retorna true para que mostre a lista de embarques pendentes
	If Empty(cEmbarque)
		Return .T.
	EndIf
	BeginSql Alias cAliasDCW
		SELECT 1
		FROM %Table:DCW% DCW
		WHERE DCW.DCW_FILIAL = %xFilial:DCW%
		AND DCW.DCW_EMBARQ = %Exp:cEmbarque%
		AND DCW.DCW_SITEMB IN ('1','3','4','5')
		AND DCW.%NotDel%
	EndSql
	If (cAliasDCW)->(Eof())
		WMSVTAviso(WMSV09016,STR0035) //Não existe conferência de recebimento pendentes com o código informado.
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
	(cAliasDCW)->( DBCloseArea() )
Return lRet
//-------------------------------------------------
// Valida o armazém informado
//-------------------------------------------------
Static Function ValidArm(cEmbarque,cArmazem,cEndereco)
Local lRet      := .T.
Local cAliasDCY := Nil
Local cAliasQry := Nil
	__lUnitiza := .F.
	__lSolEnd  := .T.
	NNR->(dbSetOrder(1))
	If NNR->(dbSeek(xFilial("NNR")+cArmazem))
		__lUnitiza :=  WmsArmUnit(cArmazem)
	Else
		WmsMessage(STR0046,WMSV09024) // Armazem inválido!
		lRet := .F.
	EndIf
	// Verifica se o armazém informado faz parte do processo de conferência
	If lRet
		cAliasDCY := GetNextAlias()
		BeginSql Alias cAliasDCY
			SELECT 1
			FROM %Table:DCY% DCY
			WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			AND DCY.DCY_LOCAL  = %Exp:cArmazem%
			AND DCY.%NotDel%
		EndSql
		If (cAliasDCY)->(Eof())
			WMSVTAviso(WMSV09017,WmsFmtMsg(STR0047,{{"[VAR01]",cArmazem}})) // Não há conferência prevista para o armazém [VAR01].
			lRet := .F.
		EndIf
		(cAliasDCY)->(DbCloseArea())
	EndIf
	// Se o armazém informado for o de excesso e ele for unitizado
	If lRet .And. (cArmazem == __cWmsLcEx) .And. __lUnitiza
		// Valida se o armazém é diferente do informado nos documentos
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:DCX% DCX
			INNER JOIN %table:SD1% SD1
			ON SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_DOC = DCX.DCX_DOC
			AND SD1.D1_SERIE = DCX.DCX_SERIE
			AND SD1.D1_FORNECE = DCX.DCX_FORNEC
			AND SD1.D1_LOJA = DCX.DCX_LOJA
			AND SD1.D1_LOCAL <> %Exp:cArmazem%
			AND SD1.%NotDel%
			WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
			AND DCX.%NotDel%
		EndSql
		If !(cAliasQry)->(Eof())
			cEndereco := __cWmsEnEx
			__lSolEnd := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet
//-------------------------------------------------
// Valida o endereço informado
//-------------------------------------------------
Static Function ValidEnd(cEmbarque,cArmazem,cEndereco)
Local lRet     := .T.
Local cAliasSD1:= Nil
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If !SBE->(DbSeek(xFilial('SBE')+cArmazem+cEndereco))
		WmsMessage(STR0048,WMSV09018) // Endereço inválido!
		lRet := .F.
	Else
		If DLTipoEnd(SBE->BE_ESTFIS) != 5
			WmsMessage(STR0049,WMSV09022) // Somente endereços de estrutura do tipo box/doca podem ser informados!
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cAliasSD1 := GetNextAlias()
		BeginSql Alias cAliasSD1
			SELECT SD1.D1_ENDER
			FROM %Table:DCX% DCX
			INNER JOIN %Table:SD1% SD1
			ON SD1.D1_FILIAL  = %xFilial:SD1%
			AND SD1.D1_DOC = DCX.DCX_DOC
			AND SD1.D1_SERIE = DCX.DCX_SERIE
			AND SD1.D1_FORNECE = DCX.DCX_FORNEC
			AND SD1.D1_LOJA = DCX.DCX_LOJA
			AND SD1.D1_LOCAL =  %Exp:cArmazem%
			AND (SD1.D1_ENDER = %Exp:cEndereco%
				OR SD1.D1_ENDER  = '   ')
			AND SD1.%NotDel%
			WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
			AND DCX.%NotDel%
		EndSql
		If (cAliasSD1)->(EoF())
			WmsMessage(WmsFmtMsg(STR0050,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco}}),WMSV09023) // Não existe conferência de recebimento prevista para o armazém [VAR01] e endereço [VAR02]!
			lRet := .F.
		EndIf
		(cAliasSD1)->(DbCloseArea())
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
Return lRet
//-------------------------------------------------
// Valida o id do unitizador informado
//-------------------------------------------------
Static Function ValidUnitz(cEmbarque,cArmazem,cIdUnit,cTipUni,lEstorno)
Local lRet := .T.
Default lEstorno := .F.
	If Empty(cIdUnit)
		lRet := .F.
	EndIf
	If lRet
		// Se possui o PE WV090UNI e a etiqueta não existe, gera automaticamente
		If __WV090UNI
			D0Y->(DbSetOrder(1))
			If !D0Y->(DbSeek(xFilial("D0Y")+cIdUnit))
				WmsGerUnit(.F.,.F.,.F.,cIdUnit,cTipUni)
			EndIf
		EndIf
		oMntUniItem:SetIdUnit(cIdUnit)
		oMntUniItem:SetUsaD0Q(.F.)
		If !oMntUniItem:VldIdUnit(2,@cTipUni,lEstorno)
			If !Empty(oMntUniItem:GetErro())
				WMSVTAviso(WMSV09019,oMntUniItem:GetErro())
				VtKeyboard(Chr(20))
			EndIf
			lRet := .F.
		EndIf
		If lRet .And. !lEstorno .And. !WMSA320VUN(cEmbarque,cIdUnit)
			WMSVTAviso(WMSV09027,WmsFmtMsg(STR0061,{{"[VAR01]",cIdUnit}})) // O unitizador [VAR01] está sendo utilizado por outro processo.
			VtKeyboard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------
// Valida o tipo do unitizador informado
//-------------------------------------------------
Static Function ValidTpUni(cTipUni)
Local lRet        := .T.
	oMntUniItem:oUnitiz:SetTipUni(cTipUni)
	oMntUniItem:SetUsaD0Q(.F.)
	If !oMntUniItem:VldTipUni()
		If !Empty(oMntUniItem:GetErro())
			WmsMessage(oMntUniItem:GetErro(),WMSV09025)
			VtKeyboard(Chr(20))
		EndIf
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} GeraExcesso
Valida se está sendo conferida quantidade excedente.
@author  Amanda Rosa Vieira
@version P12
@since   24/04/2017
/*/
//----------------------------------------------------------
Static Function GeraExcesso(cEmbarque,cLoteCtl,cNumLote,cLocal,nQtdInf,cPrdConf,cPrdOri,cCodOpe,cIdUnit,cTipUni,dDtVal)
Local lRet       := .T.
Local lArmExcUni := WmsArmUnit(__cWmsLcEx) //Identifica se armazém de excesso possui controle de unitizador.
Local lArmExcDif := !(__cWmsLcEx == cLocal) //Indica se o armazém de excesso é diferente do armazém 'normal'
Local aExcesso   := {}
Local aTela      := VtSave()
Local aCab       := {}
Local aSize      := {}
Local aProdComp  := {}
Local oProdComp  := WMSDTCProdutoComponente():New()
Local cAliasDCY  := GetNextAlias()
Local cAliasDCZ  := GetNextAlias()
Local cDCZIdUnit := "%%"
Local cProduto   := ""
Local nI         := 1
Local nQtdExc    := 0
Local nQtdConf   := 0
Local nSaldoPai  := nQtdInf
Local nSaldoFil  := 0
Local nQtdExcPrd := 0
Local nPos       := 0
Local lWmsNpCp  := SuperGetMV("MV_WMSNPCP",.F.,.F.)
Local lWMA320DT := ExistBlock("WMA320DT")

Default cIdUnit := ""

	oProdComp:SetPrdOri(cPrdOri)
	If oProdComp:LoadData(3)
		oProdComp:EstProduto()
		aProdComp:= oProdComp:GetArrProd()
	Else
		aAdd(aProdComp,{cPrdConf,1,cPrdConf})
	EndIf
	For nI := 1 To Len(aProdComp)
		If cPrdConf == aProdComp[nI][3] .Or. cPrdConf == aProdComp[nI][1]
			//Calcula quantidade saldo disponível para conferência
			cAliasDCY := GetNextAlias()
			BeginSql Alias cAliasDCY
				SELECT SUM(DCY_QTORIG - DCY_QTCONF) DCY_SALDO
				FROM %Table:DCY% DCY
				WHERE DCY.DCY_FILIAL = %xFilial:DCY%
				AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				AND DCY.DCY_PRDORI = %Exp:aProdComp[nI][3]%
				AND DCY.DCY_PROD = %Exp:aProdComp[nI][1]%
				AND (DCY.DCY_LOTE = %Exp:cLoteCtl% 
					OR DCY.DCY_LOTE = '  ')
				AND (DCY.DCY_SUBLOT = %Exp:cNumLote%
					OR DCY.DCY_SUBLOT = '  ')
				AND DCY.DCY_LOCAL  = %Exp:cLocal%
				AND DCY.%NotDel%
			EndSql
			If (cAliasDCY)->(!Eof())
				//Quantidade conferida
				nQtdConf := nQtdInf
				If cPrdConf == aProdComp[nI][3]
					nQtdConf  := nQtdInf * aProdComp[nI][2]
					// Guarda o saldo disponível do pai para, ao final, calcular corretamente o que foi gerado de excesso,
					// pois pode ser que um filho possua quantidade disponível proporcionalmente inferior à do pai
					nSaldoFil := (cAliasDCY)->DCY_SALDO / aProdComp[nI][2]
					If QtdComp(nSaldoPai) > QtdComp(nSaldoFil)
						nSaldoPai := nSaldoFil
					EndIf
				EndIf
				//Calcula quantidade do excesso
				If QtdComp((cAliasDCY)->DCY_SALDO) > 0
					If QtdComp((cAliasDCY)->DCY_SALDO) < QtdComp(nQtdConf)
						nQtdExc := nQtdConf - (cAliasDCY)->DCY_SALDO
					EndIf
				Else
					//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
					nQtdExc := nQtdConf
				EndIf
				//Verifica se há quantidade excedente, para criar as DCY de excesso.
				If QtdComp(nQtdExc) > 0
					Aadd(aExcesso,{aProdComp[nI][1],nQtdExc,cPrdConf,cLoteCtl,cNumLote,__cWmsLcEx}) //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
				EndIf
			EndIf
			(cAliasDCY)->(DbCloseArea())
		EndIf
	Next nI
	If Len(aExcesso) > 0
		// Verificar produto com excesso que não estão na nota e o parâmetro MV_WMSNPCP restrige a conferência
		If lWmsNpCp
			For nI := 1 To Len(aExcesso)
				cAliasDCY := GetNextAlias()
				BeginSql Alias caliasDCY
					SELECT Distinct 1
					FROM %Table:DCY% DCY
					WHERE DCY.DCY_FILIAL = %xFilial:DCY%
					AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
					AND DCY.DCY_PRDORI = %Exp:aExcesso[nI][3]% 
					AND DCY.DCY_PROD = %Exp:aExcesso[nI][1]%
					AND DCY.%NotDel%
				EndSql
				If (cAliasDCY)->(Eof())
					WmsMessage(STR0063,WMSV09031,2) //"Produto não pertence a prenota ou documento de entrada relacionado à conferência."
					lRet := .F.
				EndIf
				(cAliasDCY)->(dbCloseArea())
				If !lRet
					Exit
				EndIf 
			Next nI
		EndIf 
		If lRet
			If lArmExcUni .And. lArmExcDif
				//Faz tela de pergunta
				aCab  := {STR0051,STR0052,STR0053,STR0054,STR0055,STR0056} //Produto|Quantidade|Prd. Origem|Lote|Sub-Lote|Armazém
				aSize := {TamSx3("DCY_PROD")[1],TamSx3("DCY_QTCONF")[1],TamSx3("DCY_PRDORI")[1],TamSx3("DCY_LOTE")[1],TamSx3("DCY_SUBLOT")[1],TamSx3("DCY_LOCAL")[1]}
				VTClear()
				WMSVTAviso(WMSV09028,STR0062) //Conferência de produto em excesso.A quantidade excedente ficará pendente de conferência.
				WMSVTCabec(STR0057,.F.,.F.,.T.) //Conferir Excesso
				VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aExcesso,aSize)
				VTKeyBoard(Chr(20))
			EndIF
			If VTLastKey() == 27
				VtRestore(,,,,aTela)
				Return .F.
			EndIf
	
			// Cria itens na DCY
			DCY->(dbSetOrder(1))
			For nI := 1 To Len(aProdComp)
				cProduto := aProdComp[nI][1]
				// Na conf. de produto pai gera DCY de excesso para todos os componentes
				// Na conf. de produto filho "solto" gera o excesso apenas para este
				If (nPos := AScan(aExcesso,{|x| x[1]+x[3] == cProduto+cPrdConf})) <= 0
					Loop
				EndIf
				//Quando o armazém de excesso não for unitizado grava a quantidade conferida,
				//caso contrário o produto ficará pendente de conferência no armazém de excesso para montagem do unitizador.
				If lArmExcUni .And. lArmExcDif
					nQtdExcPrd := 0
				Else
					nQtdExcPrd := aExcesso[nPos][2]
				EndIf
				//Grava unitizador do excesso
				If lArmExcUni .And. QtdComp(nQtdExcPrd) > 0
					oMntUniItem:oUnitiz:SetIdUnit(cIdUnit)
					oMntUniItem:oUnitiz:SetTipUni(cTipUni)
					oMntUniItem:SetProduto(cProduto)
					oMntUniItem:SetPrdOri(cPrdConf)
					oMntUniItem:SetLoteCtl(cLoteCtl)
					oMntUniItem:SetNumLote(cNumLote)
					oMntUniItem:SetQuant(nQtdExcPrd)
					oMntUniItem:oUnitiz:SetStatus('5')
					If !oMntUniItem:IsDad()
						oMntUniItem:AssignD0S()
					EndIf
				EndIf
				//Grava excesso das partes
				If !DCY->(dbSeek(xFilial('DCY')+cEmbarque+cPrdConf+cProduto+cLoteCtl+cNumLote+__cWmsLcEx))
					RecLock('DCY',.T.)
					DCY->DCY_FILIAL := xFilial('DCY')
					DCY->DCY_EMBARQ := cEmbarque
					DCY->DCY_PROD   := cProduto
					DCY->DCY_PRDORI := cPrdConf
					DCY->DCY_LOTE   := cLoteCtl
					DCY->DCY_SUBLOT := cNumLote
					DCY->DCY_QTORIG := 0
					DCY->DCY_QTCONF := nQtdExcPrd
					DCY->DCY_LOCAL  := __cWmsLcEx
					If lDtValid .And. !Empty(dDtVal)
						DCY->DCY_DTVAL := dDtVal
					EndIf
					DCY->(MsUnlock())

					If lWMA320DT
						ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
					EndIf
				ElseIf (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtdExcPrd) > 0
					RecLock('DCY',.F.)
					DCY->DCY_QTCONF += nQtdExcPrd
					DCY->(MsUnlock())

					If lWMA320DT
						ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
					EndIf
				EndIf
				
				//Grava DCZ para a quantidade conferida no armazém de excesso.
				If (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(nQtdExcPrd) > 0
					If lArmExcUni .And. !lArmExcDif
						cDCZIdUnit := "%AND DCZ.DCZ_IDUNIT = '" + cIdUnit + "'%"
					EndIf
					cAliasDCZ := GetNextAlias()
					BeginSql Alias cAliasDCZ
						SELECT DCZ.R_E_C_N_O_ 
						FROM %Table:DCZ% DCZ
						WHERE DCZ.DCZ_FILIAL = %xFilial:DCZ%
						AND DCZ.DCZ_EMBARQ = %Exp:cEmbarque%
						AND DCZ.DCZ_OPER = %Exp:cCodOpe%
						AND DCZ.DCZ_PRDORI = %Exp:cPrdConf%
						AND DCZ.DCZ_PROD = %Exp:cProduto%
						AND DCZ.DCZ_LOTE = %Exp:cLoteCtl%
						AND DCZ.DCZ_SUBLOT = %Exp:cNumLote%
						AND DCZ.DCZ_LOCAL = %Exp:__cWmsLcEx%
						AND DCZ.%NotDel%
						%Exp:cDCZIdUnit%
					EndSql
					If (cAliasDCZ)->(!Eof())
						DCZ->(dbGoTo((cAliasDCZ)->R_E_C_N_O_))
						RecLock('DCZ', .F.)
						DCZ->DCZ_QTCONF += IIf(cProduto == aProdComp[1][3],(nQtdExcPrd * aProdComp[nI][2]),nQtdExcPrd)
						DCZ->(MsUnLock())
					Else
						RecLock('DCZ',.T.)
						DCZ->DCZ_FILIAL := xFilial('DCZ')
						DCZ->DCZ_EMBARQ := cEmbarque
						DCZ->DCZ_OPER   := cCodOpe
						DCZ->DCZ_PRDORI := cPrdConf
						DCZ->DCZ_PROD   := cProduto
						DCZ->DCZ_LOTE   := cLoteCtl
						DCZ->DCZ_SUBLOT := cNumLote
						DCZ->DCZ_QTCONF := IIf(cProduto == aProdComp[1][3],(nQtdExcPrd * aProdComp[nI][2]),nQtdExcPrd)
						DCZ->DCZ_LOCAL  := __cWmsLcEx
						// Caso o armazém de excesso seja igual ao normal, atribui o mesmo unitizador conferido
						If lArmExcUni .And. !lArmExcDif
							DCZ->DCZ_IDUNIT := oMntUniItem:GetIdUnit()
						EndIf
						If lDtValid .And. !Empty(dDtVal)
							DCZ->DCZ_DTVAL := dDtVal
						EndIf
						DCZ->(MsUnLock())
					EndIf
					(cAliasDCZ)->(DbCloseArea())	
				EndIf
			Next nI
			//Calcula quantidade conferida do produto pai
			//Gera DCY para produto pai
			cAliasDCY := GetNextAlias()
			BeginSql Alias cAliasDCY
				SELECT CASE WHEN(MIN(DCY.DCY_QTCONF / D11.D11_QTMULT)) IS NULL THEN 0 ELSE (MIN(DCY.DCY_QTCONF / D11.D11_QTMULT)) END DCY_QTCONF
				FROM %Table:DCY% DCY
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRODUT = DCY.DCY_PRDORI"
				AND D11.D11_PRDORI = DCY.DCY_PRDORI"
				AND D11.D11_PRDCMP = DCY.DCY_PROD"
				AND D11.%NotDel%
				WHERE DCY.DCY_FILIAL = %xFilial:DCY%
				AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				AND DCY.DCY_PRDORI = %Exp:cPrdConf%
				AND DCY.DCY_LOTE   = %Exp:cLoteCtl%
				AND DCY.DCY_SUBLOT = %Exp:cNumLote%
				AND DCY.DCY_LOCAL  = %Exp:__cWmsLcEx%
				AND DCY.%NotDel%
			EndSql
			If (cAliasDCY)->(!Eof())
				If !DCY->(dbSeek(xFilial('DCY')+cEmbarque+cPrdConf+cPrdConf+cLoteCtl+cNumLote+__cWmsLcEx))
					RecLock('DCY',.T.)
					DCY->DCY_FILIAL := xFilial('DCY')
					DCY->DCY_EMBARQ := cEmbarque
					DCY->DCY_PRDORI := cPrdConf
					DCY->DCY_PROD   := cPrdConf
					DCY->DCY_LOTE   := cLoteCtl
					DCY->DCY_SUBLOT := cNumLote
					DCY->DCY_QTORIG := 0
					DCY->DCY_QTCONF := Int((cAliasDCY)->DCY_QTCONF)
					DCY->DCY_LOCAL  := __cWmsLcEx
					If lDtValid .And. !Empty(dDtVal)
						DCY->DCY_DTVAL := dDtVal
					EndIf
					DCY->(MsUnlock())
					
					If ExistBlock("WMA320DT")
						ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
					EndIf
				ElseIf (!lArmExcUni .Or. !lArmExcDif) .And. QtdComp(Int((cAliasDCY)->DCY_QTCONF)) > 0
					RecLock('DCY',.F.)
					DCY->DCY_QTCONF := Int((cAliasDCY)->DCY_QTCONF)
					DCY->(MsUnlock())

					If ExistBlock("WMA320DT")
						ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
					EndIf
				EndIf
		
			EndIF
			(cAliasDCY)->(DbCloseArea())
			// Verifica saldo disponível do produto pai, quanto este estiver sendo conferido
			If cPrdConf  == aProdComp[1][3]
				If QtdComp(nSaldoPai) > 0
					If QtdComp(nSaldoPai) < QtdComp(nQtdInf)
						nQtdExc := nQtdInf - nSaldoPai
					EndIf
				Else
					//Se não encontrou quantidade na DCY, toda a quantidade será jogada em excesso
					nQtdExc := nQtdInf
				EndIf
			EndIf
			//Ajusta status do embarque
			DCW->(DbSetOrder(1))//DCW_FILIAL+DCW_EMBARQ
			If DCW->(DbSeek(xFilial('DCW')+ cEmbarque)) .And. DCW->DCW_SITEMB == '1'
				RecLock('DCW',.F.)
				DCW->DCW_SITEMB := '5' //Em andamento
				DCW->(MsUnlock())
			EndIf
			//Ajusta quantidade que está sendo conferida, removendo o excesso
			nQtdInf -= nQtdExc
			// Quanto o excesso for no mesmo armazém que o normal, precisa adicionar a quantidade também no unitizador
			If lArmExcUni .And. !lArmExcDif
				__QtExcUni := nQtdExc
			Else
				__QtExcUni := 0
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} GetUnitz
Troca unitizador que está sendo conferido.
@author  Amanda Rosa Vieira
@version P12
@since   24/04/2017
/*/
//----------------------------------------------------------
Static Function GetUniti(cEmbarque,cArmazem,cEndereco,cIdUnit,cTipUni,lEstorno,lNewUnit,lAtalho)
Local lRet      := .T.
Local aTela     := VtSave()
Local cIdUniAux := Space(TamSX3("D0R_IDUNIT")[1])
Local cTpUniAux := cTipUni
Local nX        := 1

Default lEstorno := .F.
Default lAtalho  := .F.

	If Empty(cTpUniAux)
		oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
		cTpUniAux := oMntUniItem:oUnitiz:oTipUnit:GetTipUni()
	EndIf
	VtClear()
	If !Empty(cTpUniAux)
		VTKeyBoard(Chr(13))
	EndIf

	WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferência
	@ 01,00  VtSay STR0003 + ': ' + cEmbarque // Recebimento
	@ 02,00  VTSay STR0042 // Tipo Unitz.
	@ 03,00  VtGet cTpUniAux Picture "@!" Valid ValidTpUni(cTpUniAux) When !(oMntUniItem:oUnitiz:UniHasItem()) F3 "D0T"
	@ 04,00  VTSay STR0041 // Informe o Untiz.
	@ 05,00  VtGet cIdUniAux Picture "@!" Valid ValidUnitz(cEmbarque,cArmazem,cIdUniAux,@cTpUniAux,lEstorno)
	VtRead()
	If lAtalho
		VtRestore(,,,,aTela)
	EndIf
	If VtLastkey() == 27
		oMntUniItem:SetIdUnit(cIdUnit)
		oMntUniItem:oUnitiz:SetTipUni(cTipUni)
		lRet := .F.
	EndIf
	If lRet
		If !oMntUniItem:oUnitiz:LoadData()
			oMntUniItem:oUnitiz:SetDatIni(dDataBase)
			oMntUniItem:oUnitiz:SetHorIni(Time())
		EndIf
		// Anula data e hora final para forçar gravar atualizado
		oMntUniItem:oUnitiz:SetDatFim(StoD(""))
		oMntUniItem:oUnitiz:SetHorFim("")

		cIdUnit  := cIdUniAux
		cTipUni  := cTpUniAux
		If !lNewUnit
			VTKeyBoard(Chr(27)) // Força um ESC para voltar o inicio do produto
			lNewUnit := .T.
		EndIf
	EndIf
	If lRet .And. __WV090UNI .And. !lEstorno
		// Permite automatizar a conferência dos unitizadores
		__aItsUni := ExecBlock("WV090UNI",.F.,.F.,{cEmbarque,cTipUni,cIdUnit,cArmazem,cEndereco})
		If ValType(__aItsUni) == "A" .And. Len(__aItsUni) > 0
			For nX := 1 To Len(__aItsUni)
				// GravCofOpe(cEmbarque,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtConf,lEstorno,cArmazem,cEndereco,cIdUnit,cTipUni)
				GravCofOpe(cEmbarque,__cUserID,__aItsUni[nX,1],__aItsUni[nX,2],__aItsUni[nX,3],__aItsUni[nX,4],__aItsUni[nX,5],.F.,cArmazem,cEndereco,cIdUnit,cTipUni)
			Next nX
		Else
			__aItsUni := {}
		EndIf
	EndIf

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ShowItens
Mostra itens do unitizador
@author  Inovação WMS
@version P12
@since   02/04/2017
/*/
//----------------------------------------------------------
Static Function ShowItens(cUnitiz,cEmbarque)
Local cKey09   := VtDescKey(09)
Local cKey15   := VtDescKey(15)
Local cKey21   := VtDescKey(21)
Local bKey09   := VTSetKey(09)
Local bKey15   := VTSetKey(15)
Local bKey21   := VTSetKey(21)

	// Deve validar se o unitizador possui itens
	If !oMntUniItem:oUnitiz:UniHasItem()
		WMSVTAviso(WMSV09026, STR0058) // O unitizador não possui itens.
		lRet := .F.
	Else
		GetItens(cUnitiz,cEmbarque)
	EndIf
	// Restaura Tecla
	VTSetKey(09,bKey09, cKey09)
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(21,bKey21, cKey21)
Return Nil
//----------------------------------------------------------------------------------
Static Function GetItens(cUnitiz,cEmbarque)
Local aAreaAnt := GetArea()
Local aTela    := VTSave()
Local aCab     := {}
Local aSize    := {}
Local aPrdUni  := {}
Local aTamSX3  := TamSx3('D0S_QUANT')
Local cAliasQry:= Nil
Local cCampo   := ""

	cCampo := "%"
	If lDtValid
		cCampo += " ,DCZ.DCZ_DTVAL"
	EndIf
	cCampo += "%"

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0S.D0S_CODPRO,
			   D0S.D0S_LOTECT,
			   D0S.D0S_NUMLOT,
			   D0S.D0S_PRDORI,
			   D0S.D0S_QUANT
			   %Exp:cCampo%
		 FROM %Table:D0S% D0S
		 LEFT JOIN %Table:DCZ% DCZ
		   ON DCZ.DCZ_FILIAL = %xFilial:DCZ%
		  AND DCZ.DCZ_EMBARQ = %Exp:cEmbarque%
		  AND DCZ.DCZ_PRDORI = D0S.D0S_PRDORI
		  AND DCZ.DCZ_PROD = D0S.D0S_CODPRO
		  AND DCZ.DCZ_LOTE = D0S.D0S_LOTECT
		  AND DCZ.DCZ_SUBLOT = D0S.D0S_NUMLOT
		  AND DCZ.DCZ_IDUNIT = D0S.D0S_IDUNIT
		  AND DCZ.%NotDel%
		WHERE D0S.D0S_FILIAL = %xFilial:D0S%
		  AND D0S.D0S_IDUNIT = %Exp:cUnitiz%
		  AND D0S.%NotDel%
		GROUP BY D0S.D0S_CODPRO,
			     D0S.D0S_LOTECT,
			     D0S.D0S_NUMLOT,
			     D0S.D0S_PRDORI,
			     D0S.D0S_QUANT
				 %Exp:cCampo%
		ORDER BY D0S.D0S_PRDORI,
				 D0S.D0S_CODPRO,
				 D0S.D0S_LOTECT,
				 D0S.D0S_NUMLOT
	EndSql
	TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		aAdd(aPrdUni,{(cAliasQry)->D0S_CODPRO,(cAliasQry)->D0S_LOTECT,(cAliasQry)->D0S_NUMLOT,(cAliasQry)->D0S_QUANT,(cAliasQry)->D0S_PRDORI})
		If lDtValid
			aAdd(aPrdUni[Len(aPrdUni)], sToD((cAliasQry)->DCZ_DTVAL))
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	VTClear()
	aCab  := {RetTitle("D0S_CODPRO"),RetTitle("D0S_LOTECT"),RetTitle("D0S_NUMLOT"),RetTitle("D0S_QUANT"),RetTitle("D0S_PRDORI")}
	aSize := {TamSx3("D0S_CODPRO")[1],TamSx3("D0S_LOTECT")[1],TamSx3("D0S_NUMLOT")[1],TamSx3("D0S_QUANT")[1],TamSx3("D0S_PRDORI")[1]}

	If lDtValid
		aAdd(aCab,RetTitle("DCZ_DTVAL"))
		aAdd(aSize,TamSx3("DCZ_DTVAL")[1])
	EndIf

	WMSVTCabec(STR0059,.F.,.F.,.T.) // Itens Unitizador
	VTaBrowse(1,0,(VTMaxRow()-1),VTMaxCol(),aCab,aPrdUni,aSize)

	VtRestore(,,,,aTela)
	RestArea(aAreaAnt)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} CalcQtdConf
Calcula quantidade já conferida para o produto
@author  Amanda Rosa Vieira
@version P12
@since   05/07/2017
/*/
//----------------------------------------------------------
Static Function CalcQtdConf(nQtConf,cPrdOri,cProduto,cLote,cNumLote,cLocal,cEmbarque)
Local aDCY_QTCONF := TamSx3("DCY_QTCONF")
Local aD11_QTMULT := TamSx3("D11_QTMULT")
Local cAliasQry   := Nil
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCY.DCY_QTCONF
		FROM %Table:DCY% DCY
		WHERE DCY.DCY_FILIAL = %xFilial:DCY%
		AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
		AND DCY.DCY_PRDORI = %Exp:cPrdOri%
		AND DCY.DCY_PROD = %Exp:cProduto%
		AND DCY.DCY_LOTE = %Exp:cLote%
		AND DCY.DCY_LOCAL = %Exp:cLocal%
		AND DCY.DCY_SUBLOT = %Exp:cNumLote%
		AND DCY.%NotDel%
	EndSql
	TCSetField(cAliasQry,'DCY_QTCONF','N',aDCY_QTCONF[1],aDCY_QTCONF[2])
	If (cAliasQry)->(!Eof())
		nQtConf += (cAliasQry)->DCY_QTCONF
	EndIf
	(cAliasQry)->(dbCloseArea())
	//Desconta quantidade em excesso que já foi gravada em outro ponto
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT SUM(DCY.DCY_QTORIG) DCY_QTORIG
		FROM %Table:DCY% DCY
		WHERE DCY.DCY_FILIAL = %xFilial:DCY%
		AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
		AND DCY.DCY_PRDORI = %Exp:cPrdOri%
		AND DCY.DCY_PROD   = %Exp:cProduto%
		AND (DCY.DCY_LOTE  = %Exp:cLote% 
			OR DCY.DCY_LOTE = ' ')
		AND (DCY.DCY_SUBLOT= %Exp:cNumLote% 
			OR DCY.DCY_SUBLOT = ' ')
		AND DCY.DCY_LOCAL = %Exp:cLocal%
		AND DCY.%NotDel%
	EndSql
	TCSetField(cAliasQry,'DCY_QTCONF','N',aDCY_QTCONF[1],aDCY_QTCONF[2])
	If (cAliasQry)->(!Eof())
		If nQtConf > (cAliasQry)->DCY_QTORIG
			//Remove quantidade excedente
			nQtConf -= (nQtConf - (cAliasQry)->DCY_QTORIG)
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D11.D11_QTMULT
		FROM %Table:D11% D11
		WHERE D11.D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRODUT = %Exp:cPrdOri%
		AND D11.D11_PRDORI = %Exp:cPrdOri%
		AND D11.D11_PRDCMP = %Exp:cProduto%
		AND D11.%NotDel%
	EndSql
	TCSetField(cAliasQry,'D11_QTMULT','N',aD11_QTMULT[1],aD11_QTMULT[2])
	If (cAliasQry)->(!Eof())
		nQtConf := nQtConf/(cAliasQry)->D11_QTMULT
	EndIf
	(cAliasQry)->(dbCloseArea())
	//Caso o cálculo do produto pai gere um valor com decimais arredonda para cima dessa forma gera a linha do produto pai de forma coerente com a quantidade conferida para o filho
	If !(cPrdOri == cProduto) .And. nQtConf > Int(nQtConf)
		nQtConf := Int(nQtConf)+1
	EndIf
Return nQtConf

//----------------------------------------------------------
/*/{Protheus.doc} LeArmDif
Busca a quantidade de armazéns da conferência
@author  Roselaine Adriano
@version P12
@since   01/06/2020
/*/
//----------------------------------------------------------
Static Function LeArmDif(cEmbarque)
Local cAliasQry := Nil
Local nQtdArm   := 0
Local lRet      := .F.
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT count(DISTINCT dcy_local) as QdtArm
		FROM  %Table:DCY% DCY
		WHERE DCY.DCY_FILIAL = %xFilial:DCY%
        AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
		AND %NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nQtdArm := (cAliasQry)->QdtArm
	EndIf
	(cAliasQry)->(dbCloseArea())

	If nQtdArm > 1 
		lRet := .T.
	EndIf 
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} AvaliaProd
Função que verifica se o produto digitado é um componente ou produto solto
@author  amanda.vieira
@Since   21/09/2020
/*/
//----------------------------------------------------------
Static Function AvaliaProd(cEmbarque,cProduto,cLoteCtl,cNumLote,lEstorno)
Local cPrdOri   := ""
Local cAliasQry := ""
Local lPergunta := .F.

	cPrdOri := cProduto

	// Verificar se produto existe na DCY como produto e componente ao mesmo tempo
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 1
		  FROM %Table:DCY% DCY
		 WHERE DCY.DCY_FILIAL = %xFilial:DCY%
		   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
		   AND DCY.DCY_PROD = %Exp:cProduto%
		   AND DCY.DCY_LOTE = %Exp:cLoteCtl%
		   AND DCY.DCY_SUBLOT = %Exp:cNumLote%
		   AND EXISTS (SELECT DCYB.DCY_PRDORI
					     FROM %Table:DCY% DCYB
					    WHERE DCYB.DCY_FILIAL = %xFilial:DCY%
					      AND DCYB.DCY_EMBARQ = DCY.DCY_EMBARQ
					      AND DCYB.DCY_PROD = DCY.DCY_PROD
					      AND DCYB.DCY_PRDORI <> DCY.DCY_PRDORI
					      AND DCYB.DCY_LOTE = DCY.DCY_LOTE
					      AND DCYB.DCY_SUBLOT = DCY.DCY_SUBLOT
					      AND DCYB.DCY_LOCAL = DCY.DCY_LOCAL
					      AND DCYB.%NotDel% )
		  AND DCY.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		lPergunta := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

	//Verifica se já possui na DCY como produto parte
	If lWmsNew .And. !lEstorno .And. !lPergunta
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCY.DCY_PRDORI,
				   DCY.DCY_PROD
			  FROM %Table:DCY% DCY
			 WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			   AND DCY.DCY_PROD = %Exp:cProduto%
			   AND DCY.DCY_LOTE = %Exp:cLoteCtl%
			   AND DCY.DCY_SUBLOT = %Exp:cNumLote%
			   AND DCY.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			If (cAliasQry)->DCY_PRDORI <> (cAliasQry)->DCY_PROD
				cPrdOri := (cAliasQry)->DCY_PRDORI
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lWmsNew .And. !lEstorno .And. cPrdOri == cProduto
		If(!Empty(cPrdOri := WmsPrdOri(cProduto)))
			lPergunta := .T.
		EndIf
	EndIf
	If lPergunta .And. !(Alltrim(cPrdOri) == Alltrim(cProduto))
		If WMSVTAviso(WMSV09005,STR0032, {STR0016 ,STR0031}) == 1
			cPrdOri := cProduto
		EndIf
	EndIf
Return cPrdOri
//----------------------------------------------------------
/*/{Protheus.doc} GetDtVal
Função disparada para efetuar o preenchimento da data de validade do lote.
@author  amanda.vieira
@Since   21/09/2020
/*/
//----------------------------------------------------------
Static Function GetDtVal(cEmbarque, cLocal, cProduto, cLoteCtl, cNumLote)
Local dRet      := cToD("")
Local cAliasSB8 := ""
Local cAliasDCY := ""
Local cWhere    := ""
	If !Empty(cLoteCtl)
		cWhere := "%"
		If !Empty(cNumLote)
			cWhere += " AND SB8.B8_NUMLOTE = '"+cNumLote+"'"
		EndIf
		cWhere += "%"
		cAliasSB8 := GetNextAlias()
		BeginSql Alias cAliasSB8
			SELECT SB8.B8_DTVALID 
			  FROM %Table:SB8% SB8
			 WHERE SB8.B8_FILIAL = %xFilial:SB8%
			   AND SB8.B8_PRODUTO = %Exp:cProduto%
			   AND SB8.B8_LOCAL = %Exp:cLocal%
			   AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
			   AND SB8.%NotDel%
			   %Exp:cWhere%
		EndSql
		If (cAliasSB8)->(!EoF())
			dRet := SToD((cAliasSB8)->B8_DTVALID)
		EndIf
		(cAliasSB8)->(dbCloseArea())

		cWhere := "%"
		If !Empty(cNumLote)
			cWhere += "AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
		EndIf
		cWhere := "%"
		cAliasDCY := GetNextAlias()
		BeginSql Alias cAliasDCY
			SELECT DCY.DCY_DTVAL
			  FROM %Table:DCY% DCY
			 WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			   AND DCY.DCY_PRDORI = %Exp:cProduto%
			   AND DCY.DCY_LOTE = %Exp:cLoteCtl%
			   AND DCY.DCY_LOCAL = %Exp:cLocal%
			   AND DCY.%NotDel%
			   %Exp:cWhere%
		EndSql
		If (cAliasDCY)->(!EoF())
			dRet := SToD((cAliasDCY)->DCY_DTVAL)
		EndIf
		(cAliasDCY)->(dbCloseArea())
	EndIf

Return dRet

//----------------------------------------------------------
/*/{Protheus.doc} VlCmpUnit
Valida se no unitizador que está sendo estornado possui item componente,
Caso possuir mostrar mensagem informando que o processo de estorno deverá ser efetuado através do monitor de Conferência de recebimento
@author  Roselaine Adriano
@version P12
@since   14/01/2021
/*/
//----------------------------------------------------------
Static Function VlCmpUnit(cIdUnit)
Local cAliasQry := Nil
Local lRet := .T.

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DISTINCT 1 
  		FROM  %Table:D0S% D0S 
  		INNER JOIN %Table:D11% D11 
		ON D11.D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDORI = D0S.D0S_PRDORI
		AND D11.D11_PRDCMP = D0S.D0S_CODPRO
		AND D11.%NotDel%
		INNER JOIN %Table:DCZ% DCZ
		ON DCZ.DCZ_FILIAL = %xFilial:DCZ%
		AND DCZ.DCZ_IDUNIT = D0S.D0S_IDUNIT
		AND DCZ.DCZ_PROD = D0S.D0S_CODPRO
		AND DCZ.DCZ_PRDORI = D0S.D0S_PRDORI
		AND DCZ.%NotDel%
 		WHERE D0S.D0S_FILIAL = %xFilial:D0S%
 		AND D0S.D0S_IDUNIT =  %Exp:cIdUnit%
 		AND D0S.D0S_PRDORI <> D0S.D0S_CODPRO 
		AND D0S.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		lRet:=.F.
	EndIf
	(cAliasQry)->(dbCloseArea())

Return lRet
