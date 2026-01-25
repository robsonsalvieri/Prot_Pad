#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'WMSV095.CH'

#DEFINE WMSV09501 "WMSV09501"
#DEFINE WMSV09502 "WMSV09502"
#DEFINE WMSV09503 "WMSV09503"
#DEFINE WMSV09504 "WMSV09504"
#DEFINE WMSV09505 "WMSV09505"
#DEFINE WMSV09506 "WMSV09506"
#DEFINE WMSV09507 ""
#DEFINE WMSV09508 ""
#DEFINE WMSV09509 "WMSV09509"
#DEFINE WMSV09510 "WMSV09510"
#DEFINE WMSV09511 "WMSV09511"
#DEFINE WMSV09512 "WMSV09512"
#DEFINE WMSV09513 "WMSV09513"
#DEFINE WMSV09514 "WMSV09514"
#DEFINE WMSV09515 "WMSV09515"
#DEFINE WMSV09516 "WMSV09516"
#DEFINE WMSV09517 "WMSV09517"
#DEFINE WMSV09518 "WMSV09518"
#DEFINE WMSV09519 "WMSV09519"
#DEFINE WMSV09520 "WMSV09520"
#DEFINE WMSV09521 "WMSV09521"
#DEFINE WMSV09522 "WMSV09522"
#DEFINE WMSV09523 "WMSV09523"
#DEFINE WMSV09524 "WMSV09524"
#DEFINE WMSV09525 "WMSV09525"
#DEFINE WMSV09526 "WMSV09526"
#DEFINE WMSV09527 "WMSV09527"
#DEFINE WMSV09528 "WMSV09528"
#DEFINE WMSV09529 "WMSV09529"
#DEFINE WMSV09530 "WMSV09530"
#DEFINE WMSV09531 "WMSV09531"
#DEFINE WMSV09532 "WMSV09532"
#DEFINE WMSV09533 "WMSV09533"
#DEFINE WMSV09534 "WMSV09534"
#DEFINE WMSV09535 "WMSV09535"
#DEFINE WMSV09536 "WMSV09536"
#DEFINE WMSV09537 "WMSV09537"
#DEFINE WMSV09538 "WMSV09538"
#DEFINE WMSV09539 "WMSV09539"
#DEFINE WMSV09540 "WMSV09540"
#DEFINE WMSV09541 "WMSV09541"
#DEFINE WMSV09542 "WMSV09542"
#DEFINE WMSV09543 "WMSV09543"

Static oOrdServ := Nil
Static oTransf  := WMSBCCTransferencia():New()
Static lPermTrfBlq := SuperGetMv("MV_WMSTRBL",.F.,.F.)

//------------------------------------------------------------
/*/{Protheus.doc} WMSV095
Transferência de produtos entre endereços.
@author felipe.m
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
Function WMSV095()
Local aAreaAnt  := GetArea()
Local lRet      := .T.
// Salva todas as teclas de atalho anteriores
Local aSavKey   := VTKeys()
Local lExit     := .F.
Local cArmAnt   := PadR("",TamSx3("D14_LOCAL")[1])
Local cInternet := ''
Local lMovTot   := .F.

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	//Para evitar de o coletor cair quando ocorrer alguma abertura de tela indevida
	If Type("__cInternet") <> "U"
		cInternet := __cInternet
	EndIf
	__cInternet := "AUTOMATICO"

	// Cria as tabelas temporárias utilizadas no caso de transferência unitizada
	WMSCTPENDU()

	Do While .T.
		// Inicializa oOrdServ
		If !Empty(oOrdServ)
			cArmAnt := oOrdServ:oOrdEndOri:GetArmazem()
		EndIf
		oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oOrdServ)
		// atribui armazem
		oOrdServ:oOrdEndOri:SetArmazem(cArmAnt)
		// Atribui data e hora inicio
		oOrdServ:SetData(dDataBase)
		oOrdServ:SetHora(Time())
		// Solicita endereço origem
		lExit := GetEndOri()
		// Se o armazém origem for unitizado e o endereço origem for picking ou produção, solicita o unitizador
		If !lExit .And. oOrdServ:oOrdEndOri:IsArmzUnit() .And. !(oOrdServ:oOrdEndOri:GetTipoEst() == 2 .Or. oOrdServ:oOrdEndOri:GetTipoEst() == 7)
			lExit := GetUniOri(oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEnder(),@lMovTot)
		EndIf
		// Confirma dados do produto
		If !lExit .And. !lMovTot
			ConfirmPrd(@lExit)
		EndIf
		// Solicita o endereço destino da transferência
		If !lExit
			lExit := GetEndDes()
		EndIf
		// Saida
		If lExit
			Exit
		EndIf
		lMovTot := .F.
	EndDo
	VTClear()
	VTKeyBoard(chr(13))
	VTInkey(0)
	// Restaura as teclas de atalho anteriores
	VTKeys(aSavKey)
	RestArea(aAreaAnt)
	__cInternet := cInternet
Return lRet

/*--------------------------------------------------------------------------------
---GetEndOri
---Atribui armazem e endereço origem
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function GetEndOri()
Local lAbandona := .F.
Local cArmazem  := PadR(oOrdServ:oOrdEndOri:GetArmazem(),TamSx3("D14_LOCAL")[1])
Local cEnderOri := PadR("",TamSx3("D14_ENDER")[1])
	Do While !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		@ 01,00 VTSay PadR(STR0018,VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmazem Pict "@!" Valid VldArmOri(cArmazem) F3 'NNR'
		@ 03,00 VTSay PadR(STR0002,VTMaxCol()) // Endereco Origem
		@ 04,00 VTGet cEnderOri Pict "@!" Valid VldEndOri(cEnderOri)
		VTKeyBoard(Chr(13))
		VtRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		EndIf
		Exit
	EndDo
Return lAbandona

/*--------------------------------------------------------------------------------
---ConfirmPrd
---Solicita produto/lote/sub-lote e quantidade
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ConfirmPrd(lExit)
Local lRet       := .T.
Local lCtrlInter := .F.
Local lLoop      := .F.
Local aAreaAnt   := GetArea()
Local cAliasD14  := GetNextAlias()
Local cCodBar    := ""
Local cWhere     := ""
Local cProduto   := PadR("", TamSx3("D14_PRODUT")[1])
Local cLoteCtl   := PadR("", TamSx3("D14_LOTECT")[1])
Local cNumLote   := PadR("", TamSx3("D14_NUMLOT")[1])
Local nQtdNorma  := 0
Local nQuant     := 0
Local nItem      := 0
Local nLin       := 1

	cWhere := "%"
	If lPermTrfBlq
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP)) > 0"
	Else
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0"
	EndIf
	cWhere += "%"

	// Verifica se o endereço origem possui saldo a ser movimentado
	BeginSql Alias cAliasD14
		SELECT 1
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:oOrdServ:oOrdEndOri:GetArmazem()%
		AND D14.D14_ENDER  = %Exp:oOrdServ:oOrdEndOri:GetEnder()%
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD14)->(Eof())
		WMSVTAviso(WMSV09509,STR0025) // Este endereco esta vazio!
		lRet  := .F.
		lExit := .T.
	EndIf
	(cAliasD14)->(dbCloseArea())
	If lRet
		// Limpa as informações do produto
		oOrdServ:oProdLote:ClearData()
		Do While !lCtrlInter
			// Zera as variáveis que serão utilizadas
			lLoop     := .F.
			nLin      := 1
			cCodBar   := Space(128)
			cProduto  := Space(TamSx3("D14_PRODUT")[1])
			// Solicita o código do produto a ser movimentado
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
			@ nLin++,00 VTSay PadR(STR0003,VTMaxCol())
			@ nLin++,00 VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cNumLote,@nQuant,@cCodBar)
			VtRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					Loop
				Else
					lRet  := .F.
					lExit := .T.
					Exit
				EndIf
			EndIf
	    
			//Se for informado código de barra, a tela será limpa para os casos de código de barra grandes poluindo a tela
			If AllTrim(cCodBar) != AllTrim(cProduto)
				nLin := 1
				WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
				@ nLin++,00 VTSay PadR(STR0003,VTMaxCol())
				@ nLin++,00 VtSay cProduto
			EndIf

			lRet := TrfProdut(cProduto,cLoteCtl,cNumLote,@nQuant,@nItem,@lCtrlInter,@lExit,@lLoop,nLin)
			If lLoop
				Loop
			EndIf
			Exit
		EndDo
	EndIf
	// Realiza os tratamentos a respeito da unidade de medida do produto
	If lRet
		// O sistema trabalha sempre na 1a.UM
		If nItem == 1
			// Converter de U.M.I. p/ 1a.UM
			nQtdNorma:= DLQtdNorma(oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEstFis(),,.F.)
			oOrdServ:SetQuant(nQuant*nQtdNorma)
		ElseIf nItem == 2
			// Converter de 2a.UM p/ 1a.UM
			oOrdServ:SetQuant(ConvUm(oOrdServ:oProdLote:GetProduto(),0,nQuant,1))
		Else
			oOrdServ:SetQuant(nQuant)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---TrfProdut
---Transferência de produto normal ou unitizador parcial
---felipe.m - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function TrfProdut(cProduto,cLoteCtl,cNumLote,nQuant,nItem,lCtrlInter,lExit,lLoop,nLin)
Local lRet     := .T.
Local cPrdOri  := PadR("", TamSx3("D14_PRDORI")[1])
Local nQtdTot  := 0
Local lWmsLote := SuperGetMV('MV_WMSLOTE',.F.,.F.) // Solicita a confirmacao do lote nas operacoes com RF
Local cWmsUMI  := ""
Local oTarefa  := WMSDTCTarefaAtividade():New()
Local cUM      := ""
Local cPictQt  := ""
Local nQtdItem := 0
Local nTamLote := 14

	lLoop := .F.
	// Valida saldo e permite selecionar o produto/lote no endereço de origem
	If !PrdSldEnd(oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndOri:GetEnder(),@cPrdOri,cProduto,@cLoteCtl,@cNumLote,@nQtdTot)
		lLoop := .T.
		Return .F.
	EndIf
	oOrdServ:oProdLote:SetPrdOri(cPrdOri)
	oOrdServ:oProdLote:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
	oOrdServ:oProdLote:SetProduto(cProduto)
	oOrdServ:oProdLote:SetLoteCtl(cLoteCtl)
	oOrdServ:oProdLote:SetNumLote(cNumLote)
	oOrdServ:oProdLote:SetNumSer("")
	oOrdServ:oProdLote:LoadData()
	If lWmsLote
		If oOrdServ:oProdLote:HasRastro()
			@ nLin,00  VtSay STR0004 // Lote:
			@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValidLote(cLoteCtl)
		EndIf
		If oOrdServ:oProdLote:HasRastSub()
			@ nLin,00 VTSay STR0005 // Sub-Lote:
			@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid ValSubLote(cNumLote)
		EndIf
		VtRead()
		//Se o lote ultrapassa 14 caracteres, adicionamos o restante na proxima linha
		If oOrdServ:oProdLote:HasRastro() .And. Len(Alltrim(oOrdServ:oProdLote:GetLoteCtl())) > nTamLote
			@ nLin++,00 VTSay PadR(SubStr(oOrdServ:oProdLote:GetLoteCtl(),nTamLote+1,VTMaxCol()),VTMaxCol())
		EndIf
	EndIf
	If !Empty(oOrdServ:oProdLote:GetSerTran())
		// Serviço de transferência preenchido no cadastro SB5.
		oOrdServ:oServico:SetServico(oOrdServ:oProdLote:GetSerTran())
	Else
		// Retorna o primeiro serviço de transferência encontrado.
		oOrdServ:oServico:SetServico(oOrdServ:oServico:ChkServico('8')) // Operação de transferencia
	EndIf
	oOrdServ:oServico:LoadData()
	// Atribui tarefa
	oTarefa:SetTarefa(oOrdServ:oServico:GetTarefa())
	oTarefa:LoadData()
	// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
	WmsValUM(@nQtdTot,;                           // Quantidade movimento
			@cWmsUMI,;                             // Unidade parametrizada
			oOrdServ:oProdLote:GetProduto(),;      // Produto
			oOrdServ:oOrdEndOri:GetArmazem(),;     // Armazem
			oOrdServ:oOrdEndOri:GetEnder())        // Endereço
	Do While !lCtrlInter
		// Monta tela produto
		WmsMontPrd(cWmsUMI,;                        // Unidade parametrizada
					.F.,;                              // Indica se é uma conferência
					oTarefa:GetDesTar(),;              // Descrição da tarefa
					oOrdServ:oOrdEndOri:GetArmazem(),; // Armazem
					oOrdServ:oOrdEndOri:GetEnder(),;   // Endereço
					oOrdServ:oProdLote:GetPrdOri(),;   // Produto Origem
					oOrdServ:oProdLote:GetProduto(),;  // Produto
					oOrdServ:oProdLote:GetLoteCtl(),;  // Lote
					oOrdServ:oProdLote:GetNumLote())   // sub-lote
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lCtrlInter)
				Loop
			Else
				lRet  := .F.
				lExit := .T.
			EndIf
		EndIf
		Exit
	EndDo

	If lRet
		Do While !lCtrlInter
			// Seleciona unidade de medida
			WmsSelUM(cWmsUMI,;                        // Unidade parametrizada
					@cUM,;                             // Unidade medida reduzida
					Nil,;                              // Descrição unidade medida
					nQtdTot,;                          // Quantidade movimento
					@nItem,;                           // Item seleção unidade
					@cPictQt,;                         // Mascara unidade medida
					@nQtdItem,;                        // Quantidade no item seleção unidade
					.F.,;                              // Indica se é uma conferência
					oTarefa:GetDesTar(),;              // Descrição da tarefa
					oOrdServ:oOrdEndOri:GetArmazem(),; // Armazem
					oOrdServ:oOrdEndOri:GetEnder(),;   // Endereço
					oOrdServ:oProdLote:GetPrdOri(),;   // Produto Origem
					oOrdServ:oProdLote:GetProduto(),;  // Produto
					oOrdServ:oProdLote:GetLoteCtl(),;  // Lote
					oOrdServ:oProdLote:GetNumLote())   // sub-lote
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					Loop
				Else
					lRet  := .F.
					lExit := .T.
				EndIf
			EndIf
			Exit
		EndDo
	EndIf
	If lRet
		Do While !lCtrlInter
			@ nLin++,00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) // Qtd 240.00 UN
			@ nLin++,00 VTGet nQuant Pict PesqPict('D12','D12_QTDMOV') When VTLastKey()==05 .Or. Empty(nQuant) Valid !Empty(nQuant) .And. (QtdComp(nQuant) <= QtdComp(nQtdItem))
			VtRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lCtrlInter)
					nLin -= 2
					Loop
				Else
					lRet  := .F.
					lExit := .T.
				EndIf
			EndIf
			Exit
		EndDo
		If lRet .And. QtdComp(nQuant) > QtdComp(nQtdItem)
			WMSVTAviso(WMSV09527,WmsFmtMsg(STR0035,{{"[VAR01]",cValToChar(nQuant)},{"[VAR02]",cValToChar(nQtdItem)}}))   // Quantidade informada [VAR01] maior que os saldo [VAR02]!
			lLoop := .T.
		EndIf
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} TrfUnitiz
Transferência de unitizador completo
@author  Guilherme A. Metzger
@since   10/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function TrfUnitiz()
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSX3("D14_QTDEST")
Local cAliasD14 := Nil
	// Valida se o saldo está comprometido ou se é apenas uma previsão
	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT SUM(D14.D14_QTDEST) D14_QTDEST,
				SUM(D14.D14_QTDEPR) D14_QTDEPR,
				SUM(D14.D14_QTDSPR) D14_QTDSPR,
				SUM(D14.D14_QTDEMP) D14_QTDEMP,
				SUM(D14.D14_QTDBLQ) D14_QTDBLQ
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:oOrdServ:oOrdEndOri:GetArmazem()%
		AND D14.D14_ENDER = %Exp:oOrdServ:oOrdEndOri:GetEnder()%
		AND D14.D14_IDUNIT = %Exp:oOrdServ:GetIdUnit()%
		AND D14.%NotDel%
	EndSql
	TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDEMP','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDBLQ','N',aTamSX3[1],aTamSX3[2])
	If QtdComp((cAliasD14)->D14_QTDEST) > 0
		If QtdComp((cAliasD14)->D14_QTDEPR) > 0
			WMSVTAviso(WMSV09529,STR0065) // "Existem movimentações de entrada pendentes para este endereço/unitizador."
			lRet  := .F.
		Else
			If lPermTrfBlq
				If QtdComp((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP) > 0
					WMSVTAviso(WMSV09510,STR0047) // "O saldo deste unitizador está total ou parcialmente comprometido!"
					lRet  := .F.			 	
				EndIf
			Else
				If QtdComp((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ) > 0
					WMSVTAviso(WMSV09532,STR0047) // "O saldo deste unitizador está total ou parcialmente comprometido!"
					lRet  := .F.
				EndIf
			EndIf
		EndIf
	Else
		WMSVTAviso(WMSV09533,STR0048) // "A movimentação de estoque do unitizador para este endereço ainda não foi realizada!"
		lRet  := .F.
	EndIf
	(cAliasD14)->(DbCloseArea())
	// Sugere o serviço de transferência com base no primeiro produto encontrado no unitizador
	If lRet
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_PRODUT
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:oOrdServ:oOrdEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:oOrdServ:oOrdEndOri:GetEnder()%
			AND D14.D14_IDUNIT = %Exp:oOrdServ:GetIdUnit()%
			AND D14.%NotDel%
		EndSql
		If !(cAliasD14)->(Eof())
			oOrdServ:oProdLote:SetProduto((cAliasD14)->D14_PRODUT)
			oOrdServ:oProdLote:LoadData()
			If !Empty(oOrdServ:oProdLote:GetSerTran())
				// Serviço de transferência preenchido no cadastro SB5.
				oOrdServ:oServico:SetServico(oOrdServ:oProdLote:GetSerTran())
			Else
				// Retorna o primeiro serviço de transferência encontrado
				oOrdServ:oServico:SetServico(oOrdServ:oServico:ChkServico('8')) // Operação de transferencia
			EndIf
			oOrdServ:oServico:LoadData()
			// Limpa os dados do produto, pois é movimentação de unitizador completo
			oOrdServ:oProdLote:ClearData()
			// Para movimentação de unitizador completo
			// O unitizador destino é igual ao origem
			oOrdServ:SetUniDes(oOrdServ:GetIdUnit())
			oOrdServ:SetTipUni(oOrdServ:GetTipUni())
			// A quantidade é sempre igual a 1
			oOrdServ:SetQuant(1)
		EndIf
		(cAliasD14)->(DbCloseArea())
	EndIf
RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---GetEndDes
---Adquire o endereço destino da transferência.
---felipe.m - 01/04/2015
---cArmazem, character, (Armazém destino, que sempre será o mesmo do origem)
---cEnderDes, character, (Endereço destino da transferencia)
---cProduto, character, (Produto para validação do endereço destino)
---nQuant, numérico, (Quantidade para validação do endereço destino)
----------------------------------------------------------------------------------*/
Static Function GetEndDes()
Local lAbandona := .F.
Local lConfirm  := .F.
Local cArmDes   := PadR("",TamSx3("D14_LOCAL" )[1])
Local cEnderDes := PadR("",TamSx3("D14_ENDER" )[1])
Local cEnderAux := PadR("",TamSx3("D14_ENDER" )[1])
Local nLin      := 1
	// Inicializa armazem destino
	cArmDes := oOrdServ:oOrdEndOri:GetArmazem()
	Do While !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		@ 01,00 VTSay PadR(STR0018,VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmDes Pict "@!" Valid VldArmDes(cArmDes) F3 'NNR'
		@ 03,00 VTSay PadR(STR0009,VTMaxCol()) // Endereco Destino
		@ 04,00 VTGet cEnderDes Pict "@!" Valid VldEndDes(@cEnderDes,cArmDes,@lConfirm)
		VTRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lAbandona)
				nLin := 1
				Loop
			EndIf
		EndIf
		// Quando o WMS sugere o endereço, deve solicitar a confirmação ao operador
		If !lAbandona .And. lConfirm
			@ 05,00 VTSay PadR(STR0037, VTMaxCol())  // Confirme!
			@ 06,00 VTGet cEnderAux Pict "@!" Valid !Empty(cEnderAux) .And. VldConfirm(cEnderDes,cEnderAux,cArmDes)
			VTRead()
			// Valida se foi pressionado Esc
			If VTLastKey() == 27
				If !Escape(@lAbandona)
					nLin := 1
					Loop
				EndIf
			EndIf
		EndIf
		// Se o destino for um armazém unitizado e a movimentação não for de unitizador completo
		If !lAbandona .And. oOrdServ:oOrdEndDes:IsArmzUnit() .And. !oOrdServ:IsMovUnit()
			// Caso endereço destino seja um picking ou seja a DOCA no processo de separação, limpa o unidizador destino do movimento
			If (oOrdServ:oOrdEndDes:GetTipoEst() <> 2 .And. oOrdServ:oOrdEndDes:GetTipoEst() <> 7)
				// Solicita o código do unitizador
				If !GetUniDes(cArmDes,cEnderDes) .And. !Escape(@lAbandona)
					nLin := 1
					Loop
				EndIf
			EndIf
		EndIf
		If !lAbandona .And. !WMSDtVdDif(oTransf:oMovEndOri:GetArmazem(),oTransf:oMovEndDes:GetArmazem(),oTransf:oMovPrdLot:GetPrdOri(),oTransf:oMovPrdLot:GetLotectl(),oTransf:oMovPrdLot:GetNUmlote()) 
			WMSVTAviso(WMSV09541,WmsFmtMsg(STR0074,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()},{"[VAR02]",oTransf:oMovPrdLot:GetLotectl()},{"[VAR03]",oTransf:oMovPrdLot:GetNUmlote()},{"[VAR04]",oTransf:oMovEndDes:GetArmazem()}})) //"Produto [VAR01] / [VAR02]/[VAR03] com data validade diferente no armazém destino [VAR04] "
			lAbandona := .T.
		End If 

		If !lAbandona .And. !WMSDtFbDif(oTransf:oMovEndOri:GetArmazem(),oTransf:oMovEndDes:GetArmazem(),oTransf:oMovPrdLot:GetPrdOri(),oTransf:oMovPrdLot:GetLotectl(),oTransf:oMovPrdLot:GetNUmlote()) 
			WMSVTAviso(WMSV09542,WmsFmtMsg(STR0075,{{"[VAR01]",oTransf:oMovPrdLot:GetProduto()},{"[VAR02]",oTransf:oMovPrdLot:GetLotectl()},{"[VAR03]",oTransf:oMovPrdLot:GetNUmlote()},{"[VAR04]",oTransf:oMovEndDes:GetArmazem()}})) //"Produto [VAR01] / [VAR02]/[VAR03] com data fabricação diferente no armazém destino [VAR04] "
			lAbandona := .T.
		End If 

		// Realiza a transferência conforme os dados informados
		If !lAbandona
			lAbandona := !Transfere()
		EndIf
		Exit
	EndDo
Return lAbandona

//-----------------------------------------------
/*/{Protheus.doc} GetUniOri
Solicita as informações do unitizador origem da transferência
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function GetUniOri(cArmazem,cEndereco,lMovTot)
Local cIdUnit   := PadR("",TamSx3("D14_IDUNIT")[1])
Local lAbandona := .F.
	While !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
		@ 01,00 VTSay PadR(STR0049,VTMaxCol()) // Unitizador
		@ 02,00 VTGet cIdUnit Pict "@!" Valid VldUniOri(cArmazem,cEndereco,cIdUnit)
		VTRead()
		// Valida se foi pressionado Esc
		If VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		EndIf
		// Verifica se é movimentação total do unitizador
		If !lAbandona .And. WmsQuestion(STR0050) // "Deseja movimentar o unitizador por completo?"
			lAbandona := !TrfUnitiz()
			lMovTot   := .T.
		EndIf
		// Valida se foi pressionado Esc
		If !lAbandona .And. VTLastKey() == 27
			If !Escape(@lAbandona)
				Loop
			EndIf
		EndIf
		Exit
	EndDo
Return lAbandona

//-----------------------------------------------
/*/{Protheus.doc} VldUniOri
Valida o unitizador origem informado
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldUniOri(cArmazem,cEndereco,cIdUnit)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasD14 := GetNextAlias()
	If Empty(cIdUnit)
		Return ListUnitiz(cArmazem,cEndereco)
	EndIf
	// Valida se o unitizador possui caractere especial
	If !WmsVlStr(cIdUnit)
		Return .F.
	EndIf
	BeginSql Alias cAliasD14
		SELECT D0Y.D0Y_TIPUNI
		FROM %Table:D14% D14
		LEFT JOIN %Table:D0Y% D0Y
		ON D0Y.D0Y_FILIAL = %xFilial:D0Y%
		AND D0Y.D0Y_IDUNIT = D14.D14_IDUNIT
		AND D0Y.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:oOrdServ:oOrdEndOri:GetArmazem()%
		AND D14.D14_ENDER = %Exp:oOrdServ:oOrdEndOri:GetEnder()%
		AND D14.D14_IDUNIT = %Exp:cIdUnit%
		AND D14.%NotDel%
	EndSql
	If (cAliasD14)->(Eof())
		WMSVTAviso(WMSV09520,WmsFmtMsg(STR0052,{{"[VAR01]",cIdUnit},{"[VAR02]",oOrdServ:oOrdEndOri:GetArmazem()},{"[VAR03]",oOrdServ:oOrdEndOri:GetEnder()}})) // "O unitizador [VAR01] não pertence ao armazém/endereço [VAR02]/[VAR03]."
		cIdUnit := PadR("",TamSx3("D14_IDUNIT")[1])
		lRet    := .F.
		VTKeyBoard(Chr(20))
	Else
		oOrdServ:SetIdUnit(cIdUnit)
		oOrdServ:SetTipUni((cAliasD14)->D0Y_TIPUNI)
	EndIf
	(cAliasD14)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ListUnitiz
Lista os unitizadores disponíveis no endereço para seleção
@author  Guilherme A. Metzger
@since   31/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function ListUnitiz(cArmazem,cEndereco)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aTelaAnt  := VTSave(00,00,VTMaxRow(),VTMaxCol())
Local aCab      := {STR0049} // "Unitizador"
Local aSize     := {VTMaxCol()}
Local aUnitiz   := {}
Local cAliasD14 := GetNextAlias()
Local nItem     := 1
Local cWhere    := ""

	cWhere := "%"
	If lPermTrfBlq
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP)) > 0"
	Else
		cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0"
	EndIf
	cWhere += "%"

	// Busca todos os unitizadores contidos no endereço
	BeginSql Alias cAliasD14
		SELECT DISTINCT(D14.D14_IDUNIT)
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:cArmazem%
		AND D14.D14_ENDER  = %Exp:cEndereco%
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql
	If !(cAliasD14)->(Eof())
		(cAliasD14)->(DbEval({||Aadd(aUnitiz,{(cAliasD14)->D14_IDUNIT})}))
	EndIf
	(cAliasD14)->(DbCloseArea())
	// Se conseguir encontrar unitizadores disponíveis no endereço
	If Len(aUnitiz) > 0
		VTClear()
		WMSVTRodPe(, .F.)
		// Apresenta os dados para seleção
		nItem := VTaBrowse(00,00,Min(VTMaxRow()-1,Len(aUnitiz)+1),VTMaxCol(),aCab,aUnitiz,aSize)
		// Tratamento da tecla Esc
		If VTLastKey() == 27
			lRet := .F.
		EndIf
	Else
		WMSVTAviso(WMSV09516,STR0053) // "O saldo dos unitizadores contidos neste endereço já estão comprometidos por outras movimentações!"
		lRet := .F.
	EndIf
	If lRet
		oOrdServ:SetIdUnit(aUnitiz[nItem][1])
	EndIf
	VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} GetUniDes
Solicita as informações do unitizador destino da transferência
@author  Guilherme A. Metzger
@since   17/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function GetUniDes(cArmazem,cEndereco)
Local cTipUni  := PadR("",TamSx3("D14_CODUNI")[1])
Local cIdUnit  := PadR("",TamSx3("D14_IDUNIT")[1])
Local oTipUnit := WMSDTCUnitizadorArmazenagem():New()
	VTClearBuffer()
	oTipUnit:FindPadrao()
	cTipUni := oTipUnit:GetTipUni()
	WMSVTCabec(STR0001,.F.,.F.,.T.) // Transferência
	// Solicita informações do unitizador destino
	@ 01,00 VTSay PadR(STR0049,VTMaxCol()) // Unitizador
	@ 02,00 VTGet cIdUnit Pict "@!" Valid VldUniDes(cArmazem,cEndereco,@cTipUni,@cIdUnit)
	@ 03,00 VTSay PadR(STR0054,VTMaxCol()) // Tipo Unitiz.
	@ 04,00 VTGet cTipUni Pict "@!" Valid VldTipUni(@cTipUni) F3 "D0T"
	VTRead()
	// Valida se foi pressionado Esc
	If VTLastKey() == 27
		Return .F.
	EndIf
Return .T.

//-----------------------------------------------
/*/{Protheus.doc} VldTipUni
Valida o tipo do unitizador informado end. destino
@author  Guilherme A. Metzger
@since   15/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldTipUni(cTipUni)
Local lRet := .T.

	If Empty(cTipUni)
		Return .F.
	EndIf
	D0T->(DbSetOrder(1))
	If !(lRet := D0T->(DbSeek(xFilial("D0T")+cTipUni)))
		WMSVTAviso(WMSV09526,STR0069) // Tipo de unitizador inválido.
		VTKeyBoard(Chr(20))
	EndIf
	If lRet
		oOrdServ:SetTipUni(cTipUni)
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} VldUniDes
Valida o unitizador informado end. destino
@author  Guilherme A. Metzger
@since   12/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function VldUniDes(cArmazem,cEndereco,cTipUni,cIdUnit)
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Local oTipUnit    := WMSDTCUnitizadorArmazenagem():New()
Local cAliasQry   := Nil
Local cAliasD14   := Nil
Local cTipUniD14  := ""
	If Empty(cIdUnit)
		Return .F.
	EndIf
	// Valida se o unitizador possui caractere especial
	If !WmsVlStr(cIdUnit)
		Return .F.
	EndIf
	// Valida se existe etiqueta do unitizador
	oMntUniItem:SetIdUnit(cIdUnit)
	If !oMntUniItem:VldIdUnit(4)
		// Valida a existencia do código do unitizador
		WMSVTAviso(WMSV09501,oMntUniItem:GetErro())
		Return .F.
	EndIf	
	// Carrega informações do tipo do unitizador
	oTipUnit:SetTipUni(cTipUni)
	oTipUnit:LoadData()
	If!oTipUnit:CanUniMis() .And. oMntUniItem:oUnitiz:IsMultPrd(oOrdServ:oProdLote:GetProduto(),,.T.)
		WMSVTAviso(WMSV09538,WmsFmtMsg(STR0070,{{"[VAR01]",oTipUnit:GetTipUni()}})) //Tipo de unitizador [VAR01] não permite montagem de unitizador misto.
		Return .F.
	EndIf
	// Verifica se o unitizador já existe em algum endereço
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT CASE WHEN (D14.D14_LOCAL = %Exp:oOrdServ:oOrdEndOri:GetArmazem()% AND D14.D14_ENDER = %Exp:oOrdServ:oOrdEndOri:GetEnder()% ) THEN 1
					WHEN (D14.D14_LOCAL = %Exp:oOrdServ:oOrdEndDes:GetArmazem()% AND D14.D14_ENDER = %Exp:oOrdServ:oOrdEndDes:GetEnder()% ) THEN 2
					ELSE 3 END END_UNITIZ,
				D14_LOCAL,
				D14_ENDER,
				D14_CODUNI
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:cIdUnit%
		AND D14.%NotDel%
	EndSql
	// O unitizador não pode possuir estoque em dois endereços diferentes ao mesmo tempo
	If (cAliasQry)->(!Eof())
		// Guarda o tipo do unitizador, para que o usuário não precise informar posteriormente
		cTipUniD14 := (cAliasQry)->D14_CODUNI
		Do Case
			// Se estiver na origem, deve validar se existe mais algum produto no unitizador
			Case (cAliasQry)->END_UNITIZ == 1
				// Pode ser que o endereço comporte mais de um unitizador
				If oOrdServ:GetIdUnit() == cIdUnit
					cAliasD14 := GetNextAlias()
					BeginSql Alias cAliasD14
						SELECT CASE WHEN (D14.D14_PRODUT <> %Exp:oOrdServ:oProdLote:GetProduto()%
									OR  D14.D14_LOTECT <> %Exp:oOrdServ:oProdLote:GetLoteCtl()%
									OR  D14.D14_NUMLOT <> %Exp:oOrdServ:oProdLote:GetNumLote()% )
									THEN 1 ELSE 0 END PRD_OUTROS,
								(D14.D14_QTDEST + D14.D14_QTDEPR) D14_QTDEST
						FROM %Table:D14% D14
						WHERE D14.D14_FILIAL = %xFilial:D14%
						AND D14.D14_IDUNIT = %Exp:cIdUnit%
						AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0
						AND D14.%NotDel%
						ORDER BY PRD_OUTROS DESC
					EndSql
					If !(cAliasD14)->(Eof())
						If (cAliasD14)->PRD_OUTROS == 1
							WMSVTAviso(WMSV09535,STR0055) // "O unitizador possui outros produtos no endereço origem! Informe um novo ou movimente este unitizador por completo."
							lRet := .F.
						Else
							If QtdComp(oOrdServ:GetQuant()) < QtdComp((cAliasD14)->D14_QTDEST)
								WMSVTAviso(WMSV09536,STR0067) // "O unitizador possui saldo restante do produto no endereço origem! Informe um novo ou movimente o saldo total deste unitizador."
								lRet := .F.
							EndIf
						EndIf
					EndIf
					(cAliasD14)->(DbCloseArea())
				Else
					WMSVTAviso(WMSV09537,STR0068) // "Este unitizador está armazenado no endereço origem, porém é diferente do informado como origem da movimentação!"
					lRet := .F.
				EndIf
			// Se estiver no destino, deve validar se o unitizador pode receber o produto/lote/quantidade
			Case (cAliasQry)->END_UNITIZ == 2
				// Seta as informações da sequência de abastecimento
				oTransf:oMovSeqAbt:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
				oTransf:oMovSeqAbt:SetProduto(oOrdServ:oProdLote:GetProduto())
				oTransf:oMovSeqAbt:SetEstFis(oOrdServ:oOrdEndDes:GetEstFis())
				If oTransf:oMovSeqAbt:LoadData(2)
					// Seta o unitizador destino
					oTransf:SetUniDes(cIdUnit)
					oTransf:SetTipUni(cTipUniD14)
					// Verifica se o unitizador pode receber o produto
					If !oTransf:CanUnitPar(.F.)
						WMSVTAviso(WMSV09504,STR0064 + CRLF + oTransf:GetErro()) // O endereço não pode receber o saldo do movimento. Motivo:
						lRet := .F.
					EndIf
				Else
					WMSVTAviso(WMSV09540,oTransf:oMovSeqAbt:GetErro())
					lRet := .F.
				EndIf
			// Se o unitizador está contido em algum endereço diferente da origem e destino
			Case (cAliasQry)->END_UNITIZ == 3
				WMSVTAviso(WMSV09518,WmsFmtMsg(STR0061,{{"[VAR01]",AllTrim((cAliasQry)->D14_LOCAL)},{"[VAR02]",AllTrim((cAliasQry)->D14_ENDER)}})) // "Este unitizador já encontra-se endereçado no armazém/endereço [VAR01]/[VAR02]."
				lRet := .F.
		EndCase
	EndIf
	(cAliasQry)->(dbCloseArea())
	If lRet
		If !Empty(cTipUniD14)
			cTipUni := cTipUniD14
			VTKeyBoard(Chr(13))
		EndIf
		oOrdServ:SetTipUni(cTipUni)
		oOrdServ:SetUniDes(cIdUnit)
	Else
		cIdUnit := PadR("",TamSx3("D14_IDUNIT")[1])
		VTKeyBoard(Chr(20))
	EndIf
	FreeObj(oMntUniItem)
	RestArea(aAreaAnt)
Return lRet

/*--------------------------------------------------------------------------------
---Escape
---Pergunta ao usuário se deseja encerrar a transferência
---felipe.m - 01/04/2015
---lAbandona, ${boolean}, (Parâmetro por referência para encerrar a transferência)
---------------------------------------------------------------------------------*/
Static Function Escape(lAbandona)
Local nAviso := WMSVTAviso(STR0001,STR0015,{STR0016,STR0017}) // Tranferência","Deseja encerrar a transferencia?",{"Sim","Não"}
	If nAviso == 1
		lAbandona := .T.
	ElseIf nAviso == 2
		lAbandona := .F.
	EndIf
Return lAbandona

Static oMovimento := Nil
/*--------------------------------------------------------------------------------
---Transfere
---Realiza a transferência com base nos dados informados.
---felipe.m - 02/04/2015
---------------------------------------------------------------------------------*/
Static Function Transfere()
Local lRet       := .T.
Local lMovUnit   := .F.
Local oEtiqUnit  := Nil
Local cAliasQry  := Nil
Local cDocto     := ""

	cDocto := GetSX8Num("DCF", "DCF_DOCTO")
	ConfirmSx8()
	oMovimento := WMSBCCMovimentoServico():New()
	// Cria tabela temporária
	WMSCTPRGCV()
	VTMsg(STR0031) // Processando...
	Begin Transaction
		// Atribui usado para a etiqueta
		If !Empty(oOrdServ:GetUniDes())
			oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
			oEtiqUnit:SetIdUnit(oOrdServ:GetUniDes())
			If oEtiqUnit:LoadData()
				If !oEtiqUnit:GetIsUsed()
					oEtiqUnit:SetTipUni(oOrdServ:GetTipUni())
					oEtiqUnit:SetUsado("1")
					oEtiqUnit:UpdateD0Y()
				EndIf
			EndIf
			FreeObj(oEtiqUnit)
		EndIf
		// Atribui quantidade
		oOrdServ:SetOrigem("DCF")
		oOrdServ:SetDocto(cDocto)
		//Informa que a classe não deve gerar um novo Id DCF
		oOrdServ:GeraNovoId(.F.)
		If !(oOrdServ:oOrdEndOri:GetArmazem() == oOrdServ:oOrdEndDes:GetArmazem())
			oOrdServ:SetOrigem("DH1")
			// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
			If !oOrdServ:IsMovUnit()
				oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
				oOrdServ:oProdLote:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
				oOrdServ:oProdLote:LoadData()
				lRet := WmsGeraDH1("WMSV095")
			Else
				// Criação do serviço com origem DH1 quando o armazém é diferente para cada produto do unitizador
				lMovUnit := .T.
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_NUMSER,
							D14.D14_QTDEST,
							D14.D14_QTDES2
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:oOrdServ:GetIdUnit()%
					AND D14.%NotDel%
					ORDER BY D14.D14_FILIAL,
					D14.D14_LOCAL,
					D14.D14_PRODUT
				EndSql
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta as informações do produto do unitizador
					oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
					//Informa que a classe não deve gerar um novo Id DCF
					oOrdServ:GeraNovoId(.F.)
					oOrdServ:oProdLote:SetArmazem((cAliasQry)->D14_LOCAL)
					oOrdServ:oProdLote:SetProduto((cAliasQry)->D14_PRODUT)
					oOrdServ:oProdLote:SetPrdOri((cAliasQry)->D14_PRODUT)
					oOrdServ:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oOrdServ:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT)
					oOrdServ:oProdLote:SetDtValid((cAliasQry)->D14_DTVALD)
					oOrdServ:oProdLote:SetNumSer((cAliasQry)->D14_NUMSER)
					oOrdServ:oProdLote:LoadData()
					oOrdServ:SetQuant((cAliasQry)->D14_QTDEST)
					// Gera a DH1 com base nas informações do objeto e incrementa B2_RESERVA
					If (lRet := WmsGeraDH1("WMSV095"))
						// Atribui os valores e cria a ordem de serviço por produto
						lRet := GeraOrdSer()
					EndIf
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			EndIf
		Else
			oOrdServ:SetIdDCF(WMSProxSeq('MV_DOCSEQ','DCF_ID'))
		EndIf
		If lRet .And. lPermTrfBlq
			If !oOrdServ:IsMovUnit()
				WMSRemBloq(oOrdServ:oProdLote:GetPrdOri(),;
				oOrdServ:oProdLote:GetProduto(),;
				oOrdServ:oProdLote:GetLoteCtl(),;
				oOrdServ:oProdLote:GetNumLote(),;
				oOrdServ:oOrdEndOri:GetArmazem(),;
				oOrdServ:oOrdEndOri:GetEnder(),;
				oOrdServ:GetIdUnit(),;
				oOrdServ:GetQuant(),;
				oOrdServ:GetIdDCF(),;
				oOrdServ:GetDocto())
			Else
				lRet := WMSRemBlUn(oOrdServ:GetIdUnit(),oOrdServ:GetIdDCF(),oOrdServ:GetDocto(),oOrdServ:oOrdEndOri:GetArmazem())
			EndIf
			If !lRet
				WMSVTAviso(WMSV09506,STR0073) //Não foi possível liberar toda a quantidade para a transferência.
			EndIf
		EndIf
		// Atribui os valores e cria a ordem de serviço por produto
		If lRet .And. !lMovUnit
			lRet := GeraOrdSer()
		EndIf
		If !lRet
			Disarmtransaction()
		EndIf
	End Transaction
	WMSDTPRGCV()
	oMovimento:Destroy()
Return lRet
//-------------------------------------------------------------
Static Function GeraOrdSer()
//-------------------------------------------------------------
Local lRet       := .T.
Local cAliasD12  := Nil
	oOrdServ:ForceDtHr(.F.)
	If !oOrdServ:CreateDCF()
		WMSVTAviso(WMSV09539,oOrdServ:GetErro())
		lRet := .F.
	Else
		// Adiciona a ordem de serviço criada para ser executada automaticamente
		If oOrdServ:oServico:GetTpExec() != "2"
			AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
		EndIf
	EndIf
	// Efetua a execução automática quando serviço configurado 
	If lRet
		lRet := WmsExeServ(.F.,.T.,,.F.)
	EndIf
	If lRet
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = %Exp:oOrdServ:GetIdDCF()%
			AND D12.%NotDel%
		EndSql
		Do While lRet .And. (cAliasD12)->(!Eof())
			oMovimento:GoToD12((cAliasD12)->RECNOD12)
			// Finaliza movimento
			oMovimento:SetQtdLid(oMovimento:nQtdMovto)
			oMovimento:dDtGeracao := oOrdServ:GetData()
			oMovimento:cHrGeracao := oOrdServ:GetHora()
			oMovimento:dDtInicio  := oOrdServ:GetData()
			oMovimento:cHrInicio  := oOrdServ:GetHora()
			// Atualiza o D12 para finalizado
			oMovimento:SetStatus("1")
			oMovimento:SetDataFim(dDataBase)
			oMovimento:SetHoraFim(Time())
			oMovimento:SetRecHum(__cUserID)
			If oMovimento:GetAtuEst()== "1"
				lRet := oMovimento:RecEnter()
			EndIf
			If lRet
				oMovimento:UpdateD12()
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		If !lRet
			WMSVTAviso(WMSV09502,oMovimento:GetErro())
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---VldArmOri
---Validação do armazém origem informado.
---Alexsander.Correa - 01/04/2015
---cArmazem, character, (Armazém informado)
---------------------------------------------------------------------------------*/
Static Function VldArmOri(cArmazem)
Local lRet := .T.
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV09505,STR0010) // Armazem invalido!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	If lRet
		// Atribui armazem endereço origem
		oOrdServ:oOrdEndOri:SetArmazem(cArmazem)
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---VldEndOri
---Validação do endereço origem informado.
---Alexsander.Correa - 01/04/2015
---cEndereco, character, (Endereço informado)
---------------------------------------------------------------------------------*/
Static Function VldEndOri(cEndereco)
Local lRet   := .T.

	If Empty(cEndereco)
		Return .F.
	EndIf
	oOrdServ:oOrdEndOri:SetEnder(cEndereco)
	If !oOrdServ:oOrdEndOri:LoadData()
		WMSVTAviso(WMSV09503,STR0013) // Endereço invalido!
		VTKeyBoard(chr(20))
		lRet := .F.
	Else
		If oOrdServ:oOrdEndOri:GetStatus() == "3"
			WMSVTAviso(WMSV09523,WmsFmtMsg(STR0032,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta bloqueado! (BE_STATUS)
			VTKeyBoard(chr(20))
			lRet := .F.
		ElseIf oOrdServ:oOrdEndOri:GetStatus() == "5"
			WMSVTAviso(WMSV09524,WmsFmtMsg(STR0033,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta com bloqueio de saida! (BE_STATUS)
			VTKeyBoard(chr(20))
			lRet := .F.
		ElseIf oOrdServ:oOrdEndOri:GetStatus() == "6"
			WMSVTAviso(WMSV09525,WmsFmtMsg(STR0034,{{"[VAR01]",oOrdServ:oOrdEndOri:GetEnder()}})) // Endereco origem [VAR01] esta com bloqueio de inventario! (BE_STATUS)
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ValidPrdLot
Validações referentes ao código do produto
@author  Guilherme A. Metzger
@since   10/05/2017
@version 1.0
@obs     Caso seja informado o código do unitizador,
         subentende-se que é uma transferência de
         unitizador completo
/*/
//-----------------------------------------------
Static Function ValidPrdLot(cProduto,cLoteCtl,cNumLote,nQuant,cCodBar)
Local lRet := .T.
Local lRetPE := .T.

	If Empty(cCodBar)
		Return .F.
	EndIf
	// Realiza as validações genéricas referentes ao código do produto
	lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQuant,@cCodBar)

	If lRet
		If ExistBlock("WMS095EO")
			lRetPE := ExecBlock("WMS095EO",.F.,.F.,{oOrdServ:oOrdEndOri:GetArmazem(),;
													oOrdServ:oOrdEndOri:GetEnder(),;
													cProduto,;
													cLoteCtl,;
													cNumLote,;
													nQuant})
			lRet := If(ValType(lRetPE)=="L",lRetPE,.T.)
		EndIf
	EndIf

Return lRet

/*--------------------------------------------------------------------------------
---ValidLote
---Validação do lote do produto informado.
---Alexsander.Correa - 01/04/2015
---cLoteCtl, character, (Lote informado)
---------------------------------------------------------------------------------*/
Static Function ValidLote(cLoteCtl)
Local lRet := .T.
	If Empty(cLoteCtl)
		Return .F.
	EndIf
	If oOrdServ:oProdLote:GetLoteCtl() != cLoteCtl
		WMSVTAviso(WMSV09514,STR0026) // Lote inválido!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---ValSubLote
---Validação do sub-lote do lote do produto informado.
---Alexsander.Correa - 01/04/2015
---cNumLote, character, (Sub-lote informado)
---------------------------------------------------------------------------------*/
Static Function ValSubLote(cNumLote)
Local lRet := .T.
	If Empty(cNumLote)
		Return .F.
	EndIf
	If oOrdServ:oProdLote:GetNumLote() != cNumLote
		WMSVTAviso(WMSV09515,STR0027) // SubLote inválido
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
Return lRet

/*--------------------------------------------------------------------------------
---VldArmDes
---Validação do armazém destino informado.
---Alexsander.Correa - 01/04/2015
---cArmazem, character, (Armazém informado)
---------------------------------------------------------------------------------*/
Static Function VldArmDes(cArmazem)
Local lRet := .T.
Local cArmCq := SuperGetMV("MV_CQ",.F.,"98")
	
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV09517,STR0010) // Armazem invalido!
		lRet := .F.
	EndIf
	/*Verifica se o Armazem Origem possui controle de CQ, caso tenha devemos validar 
	Se o Armazem destino também tem controle de CQ.*/
	If oOrdServ:oOrdEndOri:GetArmazem() == cArmCq
		If oOrdServ:oOrdEndOri:GetArmazem() <> cArmazem
			WMSVTAviso(WMSV09543,STR0076)//""O Armazém destino informado não possui controle de CQ"
			lRet := .F.
		EndIf	
	EndIf
	If !lRet
		VTKeyBoard(chr(20))
		@ 04,00 VTSay PadR("",VTMaxCol())
	EndIf
	oOrdServ:oOrdEndDes:SetArmazem(cArmazem)
Return lRet

/*--------------------------------------------------------------------------------
---VldEndDes
---Validação do endereço destino informado.
---Alexsander.Correa - 01/04/2015
---cEndereco, character, (Endereço informado)
---------------------------------------------------------------------------------*/
Static Function VldEndDes(cEnderDes,cArmDes,lConfirm)
Local lRet     := .T.
Local lRetPE   := .T.
Local lUnitOri := .F.
Local lUnitDes := .F.
Local cAliasQry:= Nil
	// Se o usuário pressionou Enter, disponibiliza lista de endereços para seleção
	If VTLastKey() == 13 .And. Empty(cEnderDes)
		ListEnder(cArmDes,@cEnderDes)
		lConfirm := .T. //Quando o WMS sugere o endereço, é necessário que o usuário confirme o endereço escolhido
	Else
		lConfirm := .F. //Quando usuário informa manualmente o endereço é desnecessário perdir confirmação do endereço escolhido
	EndIf
	
	If	ExistBlock("WMS095VL")
		lRetPE := ExecBlock("WMS095VL",.F.,.F.,{oOrdServ:oOrdEndOri:GetArmazem(),;
												oOrdServ:oOrdEndOri:GetEnder(),;
												cArmDes,;
												cEnderDes,;
												oOrdServ:oProdLote:GetProduto(),;
												oOrdServ:oProdLote:GetLoteCtl(),;
												oOrdServ:oProdLote:GetNumLote(),;
												oOrdServ:GetQuant()})
		lRet := If(ValType(lRetPE)=="L",lRetPE,.T.)
	EndIf

	If lRet
		// Dados Endereço Destino
		oOrdServ:oOrdEndDes:SetArmazem(cArmDes)
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
		// Atribui endereço destino
		oTransf:oMovEndDes := oOrdServ:oOrdEndDes
		oTransf:oMovEndOri := oOrdServ:oOrdEndOri
		oTransf:SetIdUnit(oOrdServ:GetIdUnit())
		// Caso o armazém destino não é unitizado, limpa o unitizador destino do objeto
		If oOrdServ:oOrdEndDes:IsArmzUnit()
			oTransf:SetUniDes(oOrdServ:GetUniDes())
			oTransf:SetTipUni(oOrdServ:GetTipUni())
		Else
			oTransf:SetUniDes("")
			oTransf:SetTipUni("")
			oOrdServ:SetUniDes("")
			oOrdServ:SetTipUni("")
		EndIf

		lUnitOri := WmsArmUnit(oTransf:oMovEndOri:GetArmazem())
		lUnitDes := WmsArmUnit(oTransf:oMovEndDes:GetArmazem())

		If oOrdServ:oOrdEndOri:GetArmazem() == oOrdServ:oOrdEndDes:GetArmazem() .And. oOrdServ:oOrdEndOri:GetEnder() == oOrdServ:oOrdEndDes:GetEnder()
			WMSVTAviso(WMSV09522,WmsFmtMsg(STR0030,{{"[VAR01]",oOrdServ:oOrdEndDes:GetEnder()}})) // Endereço destino [VAR01] não pode ser igual ao endereço origem!
			lRet := .F.
		EndIf

		If lRet
			If oOrdServ:IsMovUnit() .And. !(oTransf:oMovEndOri:GetArmazem() == oTransf:oMovEndDes:GetArmazem()) .And. lUnitOri .And. !lUnitDes
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_DTVALD,
							D14.D14_NUMSER,
							D14.D14_QTDEST,
							D14.D14_QTDES2
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:oTransf:GetIdUnit()%
					AND D14.%NotDel%
				EndSql
				Do While lRet .And. (cAliasQry)->(!Eof())
					// Seta o Produto no movimento
					oTransf:oMovPrdLot:SetArmazem((cAliasQry)->D14_LOCAL)
					oTransf:oMovPrdLot:SetProduto((cAliasQry)->D14_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasQry)->D14_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasQry)->D14_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasQry)->D14_NUMLOT)
					oTransf:oMovPrdLot:SetDtValid((cAliasQry)->D14_DTVALD)
					oTransf:oMovPrdLot:SetNumSer((cAliasQry)->D14_NUMSER)
					oTransf:oMovPrdLot:LoadData()
					oTransf:SetQuant((cAliasQry)->D14_QTDEST)
					// Seta o Produto na ordem de serviço
					oOrdServ:oProdLote := oTransf:oMovPrdLot
					// Validação do produto
					lRet := VldEndPrd()

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				// Limpa o objeto da ordem de serviço
				oOrdServ:oProdLote := WMSDTCProdutoLote():New()
			Else
				If !oOrdServ:IsMovUnit()
					// Seta o Produto no movimento
					oTransf:oMovPrdLot := oOrdServ:oProdLote
				EndIf
				oTransf:SetQuant(oOrdServ:GetQuant())
				// Validação do produto
				lRet := VldEndPrd()
			EndIf
		EndIf
	EndIf
	// Limpa o campo se houve erro
	If !lRet
		cEnderDes := PadR("",TamSx3("D14_ENDER")[1])
	Else
		@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
	EndIf
	VTKeyBoard(chr(20))
Return lRet
/*--------------------------------------------------------------------------------
---VldEndPrd
---Validação do endereço destino por produto.
---felipe.m - 19/07/2017
---------------------------------------------------------------------------------*/
Static Function VldEndPrd()
Local lRet     := .T.
Local lConsCap := .T.
	If !oOrdServ:IsMovUnit() .And.;
		oOrdServ:oOrdEndOri:GetArmazem() != oOrdServ:oOrdEndDes:GetArmazem() .And.;
		oOrdServ:oProdLote:GetProduto()  != oOrdServ:oProdLote:GetPrdOri()
		WMSVTAviso(WMSV09530,WmsFmtMsg(STR0046,{{"[VAR01]",oOrdServ:oProdLote:GetProduto()},{"[VAR02]",oOrdServ:oProdLote:GetPrdOri()}})) //Transferência entre armazéns de produto [VAR01] e componente [VAR02] não permitida!
		lRet := .F.
	EndIf
	If lRet
		If (oOrdServ:IsMovUnit() .And. Empty(oOrdServ:GetUniDes())) .Or.;
			(oOrdServ:oOrdEndDes:IsArmzUnit() .And. oOrdServ:oOrdEndDes:GetTipoEst() != 2 .And. Empty(oOrdServ:GetUniDes()))
			lConsCap := .F.
		EndIf
		If !oTransf:ChkEndDes(.F.,lConsCap)
			WMSVTAviso(WMSV09513,oTransf:GetErro())
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} ListEnder
Responsável por sugerir o endereço destino da transferência

@author  amanda.vieira
@since   10/05/2016
@version 1.0
/*/
//-----------------------------------------------
Static Function ListEnder(cArmDes,cEnderDes)
Local aCab       := {STR0038,STR0039}
Local aSize      := {Len(aCab[1]), Len(aCab[2])}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aEnderecos := {}
Local aNorma     := {}
Local cAliasQry  := Nil
Local cEndereco  := ""
Local cWhere     := ""
Local nItem      := 1
Local nSaldoCap  := 0
Local nAviso     := 1

	Do While .T.
		cEnderDes := PadR("",TamSx3("D14_ENDER")[1])
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
		If !oOrdServ:oOrdEndDes:IsArmzUnit()
			nAviso := WMSVTAviso(STR0036,STR0040,{STR0071,STR0041,STR0042}) // Endereços // Selecione a opção desejada:  // Automatico // Vazios // Parcialmente Cheios
			If VTLastKey() == 27
				VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
				@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
				Return
			EndIf
		Else
			// Armazém unitizado só vai trabalhar com a opção "Automático"
			nAviso := 1
		EndIf
		VTMsg(STR0045) // Processando...

		If nAviso == 1
			If FindEndDes() .And. !Empty(oTransf:oMovEndDes:GetEnder())
				cEnderDes := oTransf:oMovEndDes:GetEnder()
				If oOrdServ:oOrdEndDes:IsArmzUnit()
					WmsMessage(WmsFmtMsg(STR0072,{{"[VAR01]",AllTrim(cEnderDes)}}),STR0036) // "Transferência planejada para o endereço [VAR01]."
				EndIf
			EndIf
			VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
			@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
			Return
		ElseIf nAviso == 2
			//Busca endereços vazios
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SBE.BE_LOCAL,
						SBE.BE_ESTFIS,
						SBE.BE_LOCALIZ
				FROM %Table:SBE% SBE
				INNER JOIN %Table:DC3% DC3
				ON DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = SBE.BE_LOCAL
				AND DC3.DC3_CODPRO = %Exp:oOrdServ:oProdLote:GetProduto()%
				AND DC3.DC3_EMBDES = '1'
				AND DC3.%NotDel%
				WHERE SBE.BE_FILIAL = %xFilial:SBE%
				AND SBE.BE_LOCAL = %Exp:cArmDes%
				AND SBE.BE_STATUS NOT IN ('3','4','6')
				AND SBE.BE_CODZON = %Exp:oOrdServ:oProdLote:GetCodZona()%
				AND SBE.%NotDel%
				AND NOT EXISTS (SELECT 1
								FROM %Table:D14% D14
								WHERE D14.D14_FILIAL = %xFilial:D14%
								AND D14.D14_LOCAL = BE_LOCAL
								AND D14.D14_ESTFIS = BE_ESTFIS
								AND D14.D14_ENDER = BE_LOCALIZ
								AND D14.%NotDel% )
				UNION ALL
				SELECT SBE.BE_LOCAL,
						SBE.BE_ESTFIS,
						SBE.BE_LOCALIZ
				FROM %Table:SBE% SBE
				INNER JOIN %Table:DC3% DC3
				ON DC3.DC3_FILIAL = %xFilial:DC3%
				AND DC3.DC3_LOCAL = SBE.BE_LOCAL
				AND DC3.DC3_CODPRO = %Exp:oOrdServ:oProdLote:GetProduto()%
				AND DC3.DC3_EMBDES = '1'
				AND DC3.%NotDel%
				INNER JOIN %Table:DCH% DCH
				ON DCH.DCH_FILIAL = %xFilial:DCH%
				AND DCH.DCH_CODPRO = %Exp:oOrdServ:oProdLote:GetProduto()%
				AND DCH.DCH_CODZON = SBE.BE_CODZON
				AND DCH.%NotDel%
				WHERE SBE.BE_FILIAL = %xFilial:SBE%
				AND SBE.BE_LOCAL = %Exp:cArmDes%
				AND SBE.BE_STATUS NOT IN ('3','4','6')
				AND SBE.BE_CODZON <> %Exp:oOrdServ:oProdLote:GetCodZona()%
				AND SBE.%NotDel%
				AND NOT EXISTS (SELECT 1
								FROM %Table:D14% D14
								WHERE D14.D14_FILIAL = %xFilial:D14%
								AND D14.D14_LOCAL = BE_LOCAL
								AND D14.D14_ESTFIS = BE_ESTFIS
								AND D14.D14_ENDER = BE_LOCALIZ
								AND D14.%NotDel% )
			EndSql
		ElseIf nAviso == 3
			cWhere := "%"
			If lPermTrfBlq
				cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDPEM)) > 0"
			Else
				cWhere += " AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ + D14.D14_QTDPEM)) > 0"
			EndIf
			cWhere += "%"
			//Busca endereços parcialmente cheios
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D14.D14_LOCAL  BE_LOCAL,
						D14.D14_ESTFIS BE_ESTFIS,
						D14.D14_ENDER  BE_LOCALIZ,
						D14.D14_QTDEST,
						D14.D14_QTDEPR
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL  = %Exp:cArmDes%
				AND D14.D14_PRODUT = %Exp:oOrdServ:oProdLote:GetProduto()%
				AND D14.%NotDel%
				%Exp:cWhere%
			EndSql
		EndIf
		Do While (cAliasQry)->(!EoF())
			// Endereco
			cEndereco := (cAliasQry)->BE_LOCALIZ
			// Verifica norma por estrutura
			If (nPos := AScan(aNorma,{|x| x[1] == (cAliasQry)->BE_ESTFIS  })) == 0
				Aadd(aNorma,{(cAliasQry)->BE_ESTFIS,DLQtdNorma(oOrdServ:oProdLote:GetProduto(),(cAliasQry)->BE_LOCAL,(cAliasQry)->BE_ESTFIS,,.F.,cEndereco)})
				nSaldoCap := aNorma[Len(aNorma),2]
			Else
				nSaldoCap := aNorma[nPos,2]
			EndIf
			// Quando parcialmente  cheios desconta comprimetido
			If nAviso == 3
				nSaldoCap := nSaldoCap - ((cAliasQry)->D14_QTDEST + (cAliasQry)->D14_QTDEPR)
			EndIf
			// Verifica se a norma é maior que a quantidade
			If nSaldoCap >= oOrdServ:GetQuant()
				aAdd(aEnderecos, {cEndereco, cValToChar(nSaldoCap)})
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

		If VTLastKey() != 27
			If Len(aEnderecos) > 0
				VTClear()
				WMSVTRodPe(, .F.)
				nItem := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aEnderecos)+1), VTMaxCol(), aCab, aEnderecos, aSize)
				If nItem > 0
					cEnderDes := aEnderecos[nItem][1]
				EndIf
			Else
				WMSVTAviso(WMSV09528,WmsFmtMsg(STR0043,{{"[VAR01]",cValToChar(oOrdServ:GetQuant())}}))
				Loop
			EndIf
		EndIf
		Exit
	EndDo
	VTRestore(00, 00, VTMaxRow()  , VTMaxCol(), aTelaAnt)
	@ 04,00 VTSay PadR(cEnderDes,VTMaxCol())
Return

//-----------------------------------------------
/*/{Protheus.doc} FindEndDes
Busca endereço destino de forma automática

@author  amanda.vieira
@since   10/05/2016
@version 1.0
/*/
//-----------------------------------------------
Static Function FindEndDes()
Local oFuncao    := Nil
Local cIdUnitGen := ""
Local aLogEnd    := {}
Local lRet       := .T.

	If oOrdServ:oOrdEndDes:IsArmzUnit()
		oFuncao := WMSBCCEnderecamentoUnitizado():New()
		oFuncao:SetOrdServ(oOrdServ)
		// Se for movimentação do unitizador completo
		If oOrdServ:IsMovUnit()
			oFuncao:SetLstUnit({{oOrdServ:GetIdUnit(),0}})
		Else
			// Gera um ID de unitizador genérico só para a busca funcionar
			cIdUnitGen := Replicate("Z",TamSX3("D0R_IDUNIT")[1])
			cTipUniGen := Posicione("D0Y",1,xFilial("D0Y"),"D0Y_TIPUNI")
			// Atribui dados genéricos ao objeto
			oFuncao:SetLstUnit({{cIdUnitGen,0}})
			oFuncao:SetTipUni(cTipUniGen)
			oFuncao:lTrfUnit := .T.
		EndIf
	Else
		// Transferir
		oFuncao := WMSBCCEnderecamento():New()
		oFuncao:oMovServic:SetServico(oOrdServ:oServico:GetServico())
		oFuncao:oMovServic:SetOrdem(oOrdServ:oServico:GetOrdem())
		oFuncao:oMovServic:LoadData()

		oFuncao:oMovPrdLot:SetArmazem(oOrdServ:oProdLote:GetArmazem())
		oFuncao:oMovPrdLot:SetPrdOri(oOrdServ:oProdLote:GetPrdOri())
		oFuncao:oMovPrdLot:SetProduto(oOrdServ:oProdLote:GetProduto())
		oFuncao:oMovPrdLot:SetLoteCtl(oOrdServ:oProdLote:GetLoteCtl())
		oFuncao:oMovPrdLot:SetNumLote(oOrdServ:oProdLote:GetNumLote())
		oFuncao:oMovPrdLot:SetNumSer(oOrdServ:oProdLote:GetNumSer())
		oFuncao:oMovPrdLot:LoadData()

		oFuncao:oMovEndOri:SetArmazem(oOrdServ:oOrdEndOri:GetArmazem())
		oFuncao:oMovEndOri:SetEnder(oOrdServ:oOrdEndOri:GetEnder())
		oFuncao:oMovEndOri:LoadData()
		oFuncao:oMovEndOri:ExceptEnd()

		oFuncao:oMovEndDes:SetArmazem(oOrdServ:oOrdEndDes:GetArmazem())
		oFuncao:oMovEndDes:SetEnder(oOrdServ:oOrdEndDes:GetEnder())
		oFuncao:oMovEndDes:LoadData()
	EndIf

	oFuncao:SetQuant(oOrdServ:GetQuant())
	oFuncao:SetLogEnd(aLogEnd)
	oFuncao:SetTrfCol(.T.)

	If !oFuncao:ExecFuncao()
		oTransf:oMovEndDes:SetEnder("")
		WMSVTAviso(WMSV09512,oFuncao:GetErro())
		lRet := .F.
	Else
		oTransf:oMovEndDes:SetEnder(oFuncao:oMovEndDes:GetEnder())
	EndIf

Return lRet

Static Function VldConfirm(cEnderDes,cEnderAux,cArmDes)
	//Verifica se houve troca de endereço
	If cEnderDes != cEnderAux
		nAviso := WMSVTAviso(STR0001,STR0044,{STR0016,STR0017}) // Tranferencia","Deseja trocar o endereço destino?",{"Sim","Não"}.
		If nAviso == 1 .And. VldEndDes(cEnderAux,cArmDes)
			@ 04,00 VTSay PadR(cEnderAux,VTMaxCol())
			Return .T.
		Else
			Return .F.
		EndIf
	Else
		// Seta novamente armazém e endereço destino, pois pode
		// ter passado pela função VldEndDes() com um endereço
		// inexistente, gerando problemas na geração da OS
		oOrdServ:oOrdEndDes:SetArmazem(cArmDes)
		oOrdServ:oOrdEndDes:SetEnder(cEnderDes)
	EndIf
Return .T.

//-----------------------------------------------
/*/{Protheus.doc} PrdSldEnd
Verifica o saldo do produto no endereço origem.
Caso exista mais do mesmo produto no endereço,
apresenta tela para seleção do unitizador/lote
que deve ser movimentado.
@author  Inovação WMS
@since   12/05/2017
@version 1.0
/*/
//-----------------------------------------------
Static Function PrdSldEnd(cArmazem,cEndereco,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtdTot)
Local lRet      := .T.
Local lSldComp  := .F. // Indica que o saldo está comprometido
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aItens    := {}
Local aItensAux := {}
Local aCab      := {}
Local aSize     := {}
Local cAliasD14 := GetNextAlias()
Local cWhere    := ""
Local nPos      := 1
Local nQtdDisp  := 0
Local nI        := 1
	// Busca os saldos do produto/lote no endereço
	cWhere := "%"
	If !Empty(oOrdServ:GetIdUnit())
		cWhere += " AND D14_IDUNIT = '"+oOrdServ:GetIdUnit()+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D14_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D14_NUMLOT = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasD14
		SELECT D14.D14_PRDORI,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				D14.D14_NUMLOT,
				D14.D14_QTDEST,
				D14.D14_QTDSPR,
				D14.D14_QTDEMP,
				D14.D14_QTDBLQ,
				D14.D14_IDUNIT
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:cArmazem%
		AND D14.D14_ENDER  = %Exp:cEndereco%
		AND D14.D14_PRODUT = %Exp:cProduto%
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql
	Do While !(cAliasD14)->(Eof())
		If lPermTrfBlq
			nQtdDisp := (cAliasD14)->D14_QTDEST-((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP)
		Else
			nQtdDisp := (cAliasD14)->D14_QTDEST-((cAliasD14)->D14_QTDSPR+(cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)
		EndIf
		If QtdComp(nQtdDisp) > 0
			Aadd(aItens,{nQtdDisp,;
						(cAliasD14)->D14_IDUNIT,;
						(cAliasD14)->D14_PRDORI,;
						(cAliasD14)->D14_PRODUT,;
						(cAliasD14)->D14_LOTECT,;
						(cAliasD14)->D14_NUMLOT})
		Else
			lSldComp := .T.
		EndIf
		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(dbCloseArea())
	// Caso tenha encontrado mais do mesmo produto, apresente tela para seleção
	If Len(aItens) > 0
		// Guarda uma cópia do array para o caso da coluna do unitizador ser removida
		aItensAux := aClone(aItens)
		If Len(aItens) > 1
			// Monta o cabeçalho da tela para seleção do produto
			aCab := {RetTitle("D14_QTDEST"),;
						RetTitle("D14_IDUNIT"),;
						RetTitle("D14_PRDORI"),;
						RetTitle("D14_PRODUT"),;
						RetTitle("D14_LOTECT"),;
						RetTitle("D14_NUMLOT")}
			// Tamanho das colunas na tela para seleção do produto
			aSize := {9,;
						 TamSx3("D14_IDUNIT")[1],;
						 TamSx3("D14_PRDORI")[1],;
						 TamSx3("D14_PRDORI")[1],;
						 TamSx3("D14_LOTECT")[1],;
						 TamSx3("D14_NUMLOT")[1]}
			// Se não é armazém unitizado, remove a coluna do unitizador
			If !oOrdServ:oOrdEndOri:IsArmzUnit()
				aDel(aCab ,2)
				aDel(aSize,2)
				aSize(aCab,  Len(aCab)-1)
				aSize(aSize, Len(aSize)-1)
				For nI := 1 To Len(aItens)
					aDel(aItens[nI],2)
					aSize(aItens[nI],Len(aItens[nI])-1)
				Next
			EndIf
			// Apresenta tela para seleção do produto
			WMSVTCabec("Produto Origem",.F.,.F.,.T.) // Produto Origem
			nPos := VTaBrowse(00, 00, Min(VTMaxRow()-1,Len(aItens)+1), VTMaxCol(), aCab, aItens, aSize)
		EndIf
		If VTLastKey() != 27
			// Atribui dados
			nQtdTot  := aItensAux[nPos][1]
			cIdUnit  := aItensAux[nPos][2]
			cPrdOri  := aItensAux[nPos][3]
			cLoteCtl := aItensAux[nPos][5]
			cNumLote := aItensAux[nPos][6]
			VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
		Else
			lRet := .F.
		EndIf
	Else
		If lSldComp
			WMSVTAviso(WMSV09531,WmsFmtMsg(STR0062,{{"[VAR01]",cProduto},{"[VAR02]",cEndereco}})) // "O produto [VAR01] está com todo o saldo comprometido no endereço [VAR02]."
		Else
			WMSVTAviso(WMSV09521,WmsFmtMsg(STR0063,{{"[VAR01]",cProduto},{"[VAR02]",cEndereco}})) // "Produto [VAR01] não encontrado no endereço [VAR02]."
		EndIf
		lRet := .F.
	EndIf
Return lRet
