#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNJ.CH"
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNJ - Funções WMS Integração com Requisição Produção          |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas em            |
|         | integrações que estejam relacionadas com o proceso de requisição   |
|         | de estoque para atender os processos de produção.                  |
|         | Validações, Geração, Baixa, Estorno...                             |
+---------+--------------------------------------------------------------------+
*/
#define WMSXFUNJ01 "WMSXFUNJ01"
#define WMSXFUNJ02 "WMSXFUNJ02"
#define WMSXFUNJ03 "WMSXFUNJ03"
#define WMSXFUNJ04 "WMSXFUNJ04"
#define WMSXFUNJ05 "WMSXFUNJ05"
#define WMSXFUNJ06 "WMSXFUNJ06"
#define WMSXFUNJ07 "WMSXFUNJ07"
#define WMSXFUNJ08 "WMSXFUNJ08"
#define WMSXFUNJ09 "WMSXFUNJ09"
#define WMSXFUNJ10 "WMSXFUNJ10"

//------------------------------------------------------------------------------
// Valida se o endereço utilizado é do tipo produção
//------------------------------------------------------------------------------
Function Wms650End(cArmazem,cEndereco)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT SBE.BE_LOCALIZ
		FROM %Table:SBE% SBE
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = SBE.BE_ESTFIS
		AND DC8.DC8_TPESTR = '7'
		AND DC8.%NotDel%
		WHERE SBE.BE_FILIAL  = %xFilial:SBE%
		AND SBE.BE_LOCAL = %Exp:cArmazem%
		AND SBE.BE_LOCALIZ = %Exp:cEndereco%
		AND SBE.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	If !lRet
		WmsMessage(STR0001,WMSXFUNJ01,,,,STR0002) //"Quando integrado ao WMS não é possível utilizar endereços diferentes do tipo produção."##"Outro tipo de endereço poderá ser escolhido no WMS quando efetuado o atendimento das requisições."
	EndIf
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
// Realiza a baixa das requisições do WMS no apontamento da produção
//------------------------------------------------------------------------------
Static oEstEnder := Nil
Static oProdComp := Nil
Function WmsBaixaReq(nRecSD3,lCriaSDC)
Local lRet     := .T.
Local lEmpenho := .F.
Local lRastro  := .F.
Local lSubLot  := .F.
Local lReqLot  := .F.
Local aProduto := {}
Local cWhere   := ""
Local cAliasSDC:= Nil
Local cAliasD14:= Nil
Local cNumSeq  := ""
Local cProduto := ""
Local cArmazem := ""
Local cLoteCtl := ""
Local cNumLote := ""
Local cOp      := ""
Local cTrt     := ""
Local cDoc     := ""
Local cPrdCmp  := ""
Local nQtMult  := 0
Local nQtdReq  := 0
Local nQtdBaixa:= 0
Local nI       := 0
Local nQuant   := 0
Local nQuant2  := 0
Local nQtdSld  := 0
Local cJoinSD5 := "%%"
Local lEmpOp   := .T.
Local lWmsBxOp  := SuperGetMV("MV_WMSBXOP",.F.,.F.)

DEFAULT lCriaSDC := .F.

	If Empty(oEstEnder)
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oProdComp := oEstEnder:oProdLote:oProduto:oProdComp
	EndIf

	SD3->(MsGoTo(nRecSD3))
	cNumSeq  := SD3->D3_NUMSEQ
	cProduto := SD3->D3_COD
	cArmazem := SD3->D3_LOCAL
	cLoteCtl := SD3->D3_LOTECTL
	cNumLote := SD3->D3_NUMLOTE
	cOp      := SD3->D3_OP
	cTrt     := SD3->D3_TRT
	cDoc     := SD3->D3_DOC
	nQuant   := SD3->D3_QUANT
	nQuant2  := SD3->D3_QTSEGUM
	lRastro  := Rastro(cProduto)
	lSubLot  := Rastro(cProduto,"S")
	lReqLot  := (lRastro .And. Empty(cLoteCtl)) .Or.  (lSubLot .And. Empty(cNumLote))
	lEmpOp   := SD3->D3_EMPOP = "S"

	// Parâmetro Where
	cWhere := "%"
	If lRastro .And. !Empty(cLoteCtl)
		cWhere += " AND SDC.DC_LOTECTL = '"+cLoteCtl+"'"
	EndIf
	If lSubLot .And. !Empty(cNumLote)
		cWhere += " AND SDC.DC_NUMLOTE = '"+cNumLote+"'"
	EndIf
	cWhere += "%"

	If SD5->( FieldPos("D5_TRT") ) > 0
		cJoinSD5 := "% AND SD5.D5_TRT = SDC.DC_TRT %"
	EndIf

	cAliasSDC := GetNextAlias()
	If lReqLot
		BeginSql Alias cAliasSDC
			SELECT 	SDC.R_E_C_N_O_ RECNOSDC,
					SDC.DC_ORIGEM,
					SDC.DC_IDDCF,
					SDC.DC_LOCALIZ,
					SD5.D5_LOTECTL LOTECTL,
					SD5.D5_NUMLOTE NUMLOTE,
					SD5.D5_QUANT QUANT
			FROM %Table:SDC% SDC
			INNER JOIN %Table:SD5% SD5
			ON SD5.D5_FILIAL = %xFilial:SD5%
			AND SD5.D5_OP = SDC.DC_OP
			AND SD5.D5_NUMSEQ = %Exp:cNumSeq%
			AND SD5.D5_PRODUTO = SDC.DC_PRODUTO
			AND SD5.D5_LOCAL = SDC.DC_LOCAL
			AND SD5.%NotDel%
			%Exp:cJoinSD5%
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto%
			AND SDC.DC_LOCAL = %Exp:cArmazem%
			AND SDC.DC_OP = %Exp:cOp%
			AND SDC.DC_TRT = %Exp:cTrt%
			AND SDC.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		BeginSql Alias cAliasSDC
			SELECT SDC.R_E_C_N_O_ RECNOSDC,
					SDC.DC_ORIGEM,
					SDC.DC_IDDCF,
					SDC.DC_LOCALIZ,
					SDC.DC_LOTECTL LOTECTL,
					SDC.DC_NUMLOTE NUMLOTE,
					SDC.DC_QUANT QUANT
			FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto%
			AND SDC.DC_LOCAL = %Exp:cArmazem%
			AND SDC.DC_OP = %Exp:cOp%
			AND SDC.DC_TRT = %Exp:cTrt%
			AND SDC.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	Do While lRet .And. (cAliasSDC)->(!Eof())
		// Indica se irá retirar o empenho do endereço reservado para a requisição
		lEmpenho := (cAliasSDC)->DC_ORIGEM <> "SD3" .And. !Empty((cAliasSDC)->DC_LOCALIZ)

		// Quantidade da requisição para consimir do(s) endereço(s)
		If (lRastro .And. Empty(cLoteCtl)) .Or.  (lSubLot .And. Empty(cNumLote))
			nQtdReq := (cAliasSDC)->QUANT
		Else
			nQtdReq := Min((cAliasSDC)->QUANT,nQuant)
		EndIf

		// Baixa a quantidade do empenho SDC que antes era realizado pela função MovLote()
		// A baixa é realizada neste ponto devido a geração da SDC por endereço do WMS, no qual divide
		// a quantidade empenha por endereço escolhido pelo WMS
		If (!FwIsInCallStack("MATA241")) .Or. (lWmsBxOp .And. (lEmpOp .OR. lCriaSDC))
            SDC->(MsGoto((cAliasSDC)->RECNOSDC))
			RecLock("SDC",.F.)
			SDC->DC_QUANT   -= Min(SDC->DC_QUANT  ,nQuant)
			SDC->DC_QTSEGUM -= Min(SDC->DC_QTSEGUM,nQuant2)
			SDC->(MsUnlock())
		ENDIF

		// Busca a estrutura do produto no WMS
		oProdComp:SetProduto(cProduto)
		oProdComp:SetPrdOri(cProduto)
		oProdComp:EstProduto()
		aProduto := oProdComp:GetArrProd()

		For nI := 1 To Len(aProduto)
			cPrdCmp := aProduto[nI][1]
			nQtMult := aProduto[nI][2]
			nQtdReq := (nQtdReq * nQtMult)
			// Parâmetro Where
			cWhere := "%"
			If !Empty((cAliasSDC)->LOTECTL)
				cWhere += " AND D14.D14_LOTECT = '"+(cAliasSDC)->LOTECTL+"'"
			EndIf
			If !Empty((cAliasSDC)->NUMLOTE)
				cWhere += " AND D14.D14_NUMLOT = '"+(cAliasSDC)->NUMLOTE+"'"
			EndIf
			cWhere += "%"
			cAliasD14 := GetNextAlias()
			If !Empty((cAliasSDC)->DC_LOCALIZ)
				BeginSql Alias cAliasD14
					SELECT D14.D14_LOCAL,
							D14.D14_ENDER,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_NUMSER,
							D14.D14_DTVALD,
							SUM(D14.D14_QTDEST) D14_QTDEST,
							SUM(D14.D14_QTDEST - (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)) D14_QTDSLD
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:cArmazem%
					AND D14.D14_PRODUT = %Exp:cPrdCmp%
					AND D14.D14_PRDORI = %Exp:cProduto%
					AND D14.D14_ENDER = %Exp:(cAliasSDC)->DC_LOCALIZ%
					AND D14.%NotDel%
					%Exp:cWhere%
					GROUP BY D14.D14_LOCAL,
								D14.D14_ENDER,
								D14.D14_PRODUT,
								D14.D14_PRDORI,
								D14.D14_LOTECT,
								D14.D14_NUMLOT,
								D14.D14_NUMSER,
								D14.D14_DTVALD
					ORDER BY D14.D14_ENDER,
								D14.D14_LOTECT,
								D14.D14_NUMLOT,
								D14.D14_NUMSER,
								D14.D14_DTVALD
				EndSql
			Else
				BeginSql Alias cAliasD14
					SELECT D14.D14_LOCAL,
							D14.D14_ENDER,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_NUMSER,
							D14.D14_DTVALD,
							SUM(D14.D14_QTDEST) D14_QTDEST,
							SUM(D14.D14_QTDEST - (D14.D14_QTDSPR  + D14.D14_QTDBLQ + D14.D14_QTDEMP)) D14_QTDSLD
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:cArmazem%
					AND D14.D14_PRODUT = %Exp:cPrdCmp%
					AND D14.D14_PRDORI = %Exp:cProduto%
					AND EXISTS (SELECT 1
								FROM %Table:DC8% DC8
								WHERE DC8.DC8_FILIAL = %xFilial:DC8%
								AND DC8.DC8_CODEST = D14.D14_ESTFIS
								AND DC8.DC8_TPESTR = '7' // Somente endereços de produção
								AND DC8.%NotDel% )
					AND D14.%NotDel%
					%Exp:cWhere%
					GROUP BY D14.D14_LOCAL,
								D14.D14_ENDER,
								D14.D14_PRODUT,
								D14.D14_PRDORI,
								D14.D14_LOTECT,
								D14.D14_NUMLOT,
								D14.D14_NUMSER,
								D14.D14_DTVALD
					ORDER BY D14.D14_ENDER,
								D14.D14_LOTECT,
								D14.D14_NUMLOT,
								D14.D14_NUMSER,
								D14.D14_DTVALD
				EndSql
			EndIf
			If (cAliasD14)->(Eof())
				If !Empty((cAliasSDC)->LOTECTL)
					WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",(cAliasSDC)->LOTECTL}}),WMSXFUNJ08,5,.T.,,STR0011) //"Não encontrado saldo WMS em endereço de produção para o lote: [VAR01] . " " Efetue os empenhos WMS através do programa WMSA505 para considerar primeiro o saldo em endereço de produção para empenho."
					lRet := .F.
				ELSE
					WmsMessage(STR0012,WMSXFUNJ09,5,.T.,,STR0013) //"Não encontrado saldo WMS em endereço de produção. "  " Efetue os empenhos WMS através do programa WMSA505"
					lRet := .F.
				EndIf
			EndIf
			Do While lRet .And. (cAliasD14)->(!Eof()) .And. nQtdReq > 0
				If lWmsBxOp .And. FwIsInCallStack("MATA241")
					lEmpenho := lEmpOp
				EndIf

				nQtdSld := IIf(!lEmpenho,(cAliasD14)->D14_QTDSLD,(cAliasD14)->D14_QTDEST)
				If nQtdSld > 0

					// Rateio da quantidade entre os endereços disponíveis
					If nQtdReq < nQtdSld
						nQtdBaixa := nQtdReq
					Else
						nQtdBaixa := nQtdSld
					EndIf
					nQtdReq -= nQtdBaixa

					// Inicialia objeto
					oEstEnder:ClearData()
					// Informações do endereço
					oEstEnder:oEndereco:SetArmazem((cAliasD14)->D14_LOCAL)
					oEstEnder:oEndereco:SetEnder((cAliasD14)->D14_ENDER)
					// Informações do produto
					oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)
					oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT)
					oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT)
					oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT)
					oEstEnder:oProdLote:SetDtValid((cAliasD14)->D14_DTVALD)
					oEstEnder:oProdLote:SetNumSer((cAliasD14)->D14_NUMSER)
					// Seta o bloco de código para informações do documento para o Kardex
					oEstEnder:SetBlkDoc({|oMovEstEnd|;
						oMovEstEnd:SetOrigem("SC2"),;
						oMovEstEnd:SetDocto(cDoc),;
						oMovEstEnd:SetSerie(""),;
						oMovEstEnd:SetCliFor(""),;
						oMovEstEnd:SetLoja(""),;
						oMovEstEnd:SetNumSeq(cNumSeq),;
						oMovEstEnd:SetIdDCF((cAliasSDC)->DC_IDDCF);
					})
					// Seta o bloco de código para informações do movimento para o Kardex
					oEstEnder:SetBlkMov({|oMovEstEnd|;
						oMovEstEnd:SetIdMovto(""),;
						oMovEstEnd:SetIdOpera(""),;
						oMovEstEnd:SetIdUnit("");
					})
					oEstEnder:SetQuant(nQtdBaixa)

					lRet := oEstEnder:UpdSaldo('999',.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,lEmpenho,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
				EndIf
				(cAliasD14)->(dbSkip())
			EndDo
			(cAliasD14)->(dbCloseArea())
		Next nI
		//Quando sobrou saldo no WMS e porque nao tinha estoque suficiente no endereço de produção para baixa da OP e pode dar problema de saldo.
		If lRet .AND. nQtdReq > 0
			WmsMessage(WmsFmtMsg(STR0014,{{"[VAR01]",cProduto},{"[VAR02]",(cAliasSDC)->LOTECTL}}) + STR0015,WMSXFUNJ10,5,.T.) //"Não encontrado saldo disponível no endereço de produção para o produto/lote: [VAR01]/[VAR02], conforme FIFO do Estoque"//"Efetue os empenhos WMS através do programa WMSA505 para realocação dos lotes."
			lRet := .F.
		EndIf

		(cAliasSDC)->(dbSkip())
	EndDo
	(cAliasSDC)->(dbCloseArea())
Return lRet

//------------------------------------------------------------------------------
// Gera ou estorna um empenho no WMS a partir de uma requisição de estoque
//Parâmetros:
// lMovQtdSDC: indica se haverá movimentação da tabela SDC. Essa situação ocorrerá somente no encerramento de uma O.P. com saldo.
//             Assim, em caso de estorno, o registro na SDC continuará existindo, e será usado para o estorno.
//             Não foi usado o parâmetro lCriaSDC pelo fato de que outras funções também o chamam para estorno, o que poderia desestabilizar outras rotinas.
//------------------------------------------------------------------------------
Function WmsEmpReq(cOrigem,cProduto,cArmazem,nQuant,cEndereco,cLoteCtl,cNumLote,cNumSerie,cOp,cTrt,cIdDCF,cIdUnitiz,lEstorno,lCriaSDC,lEmpD14,lMovQtdSDC,lOpEncer)
Local lRet      := .T.
Local oEstEnder := Nil

Default cNumSerie := ""
Default cOp       := ""
Default cTrt      := ""
Default cIdDCF    := ""
Default cIdUnitiz := ""
Default lEstorno  := .F.
Default lCriaSDC  := .F.
Default lMovQtdSDC := .T.
Default lOpEncer   := .F. //

	// Se for um estorno e for vazio o endereço, deve buscar os endereços no WMS
	If lEstorno .And. Empty(cEndereco)
		lRet := EstEmpReq(cOrigem,cProduto,cArmazem,nQuant,cLoteCtl,cNumLote,cOp,cTrt,lMovQtdSDC,lOpEncer)
	Else
		If lEmpD14 == Nil
			lEmpD14 := !Empty(cEndereco)

			If lEmpD14 .And. Rastro(cProduto)
				lEmpD14 := !Empty(cLoteCtl)
			EndIf

			If lEmpD14 .And. Rastro(cProduto,"S")
				lEmpD14 := !Empty(cNumLote)
			EndIf
		EndIf

		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:oEndereco:SetArmazem(cArmazem)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cArmazem) // Armazem
		oEstEnder:oProdLote:SetPrdOri(cProduto)  // Produto Origem - Componente
		oEstEnder:oProdLote:SetProduto(cProduto) // Produto Principal
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl) // Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote(cNumLote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumSer(cNumSerie)
		oEstEnder:SetIdUnit(cIdUnitiz)
		oEstEnder:SetQuant(nQuant)

		If !(lRet := oEstEnder:GeraEmpReq(cOrigem,cOp,cTrt,cIdDCF,lEstorno,lCriaSDC,lEmpD14,lOpEncer))
			WmsMessage(oEstEnder:GetErro(),WMSXFUNJ02,1)
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Função que busca os empenhos por endereço quando for WMS
//------------------------------------------------------------------------------
Static Function EstEmpReq(cOrigem,cProduto,cArmazem,nQuant,cLoteCtl,cNumLote,cOp,cTrt,lMovQtdSDC,lOpEncer)
Local lRet      := .T.
Local cAliasSDC := GetNextAlias()
Local nSaldo    := nQuant
Default lOpEncer := .F.

	BeginSql Alias cAliasSDC
		SELECT SDC.DC_QUANT,
				SDC.DC_LOCALIZ,
				SDC.DC_NUMSERI,
				SDC.DC_IDDCF
		FROM %Table:SDC% SDC
		WHERE SDC.DC_FILIAL = %xFilial:SDC%
		AND SDC.DC_PRODUTO = %Exp:cProduto%
		AND SDC.DC_LOCAL = %Exp:cArmazem%
		AND SDC.DC_OP = %Exp:cOp%
		AND SDC.DC_TRT = %Exp:cTrt%
		AND SDC.DC_LOTECTL = %Exp:cLoteCtl%
		AND SDC.DC_NUMLOTE = %Exp:cNumLote%
		AND SDC.%NotDel%
	EndSql
	If (cAliasSDC)->(!Eof())
		Do While lRet .And. (cAliasSDC)->(!Eof())
			nQuant := Min((cAliasSDC)->DC_QUANT,nSaldo)
			nSaldo -= nQuant
			lRet := WmsEmpReq(cOrigem,cProduto,cArmazem,nQuant,(cAliasSDC)->DC_LOCALIZ,cLoteCtl,cNumLote,(cAliasSDC)->DC_NUMSERI,cOp,cTrt,(cAliasSDC)->DC_IDDCF,/*cIdUnitiz*/,.T.,lMovQtdSDC,,,lOpEncer)

			(cAliasSDC)->(dbSkip())
		EndDo
	EndIf
	(cAliasSDC)->(dbCloseArea())
Return lRet
//------------------------------------------------------------------------------
// Efetua a divisão da SD4 e gera empenho para a nova sequencia gerada
//------------------------------------------------------------------------------
Function WmsDivSD4(cProduto,cArmazem,cOp,cTrt,cLoteCtl,cNumLote,cNumSerie,nQuant,nQuant2UM,cEndereco,cIdDCF,lGeraEmp,nRecnoSD4,cTrtSD4,nNewRecno,lEmpNew,cArmOri,lOrigPerda,nRecnoSBC,lQuebraD4)
Local lRet       := .T.
Local aCopySD4   := {}
Local aAreaAnt   := GetArea()
Local cWhere     := ""
Local cAliasSD4  := GetNextAlias()
Local cAliasSB8  := GetNextAlias()
Local nCnt       := 0
Local nQtdEmp    := 0
Local nQtdEmp2UM := 0
Local dDtValid   := CtoD('  /  /  ')
Local aAreaSBC   := SBC->(GetArea())
Local lRastro    := .F.

Default cProduto   := Space(TamSx3("D4_COD")[1])
Default cArmazem   := Space(TamSx3("D4_LOCAL")[1])
Default cOp        := Space(TamSx3("D4_OP")[1])
Default cTrt       := Space(TamSx3("D4_TRT")[1])
Default cLoteCtl   := Space(TamSx3("D4_LOTECTL")[1])
Default cNumLote   := Space(TamSx3("D4_NUMLOTE")[1])
Default cNumSerie  := Space(TamSx3("DC_NUMSERI")[1])
Default cIdDCF     := ''
Default nQuant2UM  := ConvUM(cProduto, nQuant, 0, 2)
Default lGeraEmp   := .T.
Default nRecnoSD4  := 0
Default cTrtSD4    := ''
Default nNewRecno  := SD4->(Recno())
Default lEmpNew    := .T.
Default cArmOri    := cArmazem
Default lOrigPerda := .F.
Default nRecnoSBC  := 0
Default lQuebraD4  := .F.

	cAliasSB8 := GetNextAlias()
	BeginSql Alias cAliasSB8
		SELECT SB8.B8_DTVALID
		FROM %Table:SB8% SB8
		WHERE SB8.B8_FILIAL = %xFilial:SB8%
		AND SB8.B8_PRODUTO = %Exp:cProduto%
		AND SB8.B8_LOCAL = %Exp:cArmOri%
		AND SB8.B8_LOTECTL = %Exp:cLoteCtl%
		AND SB8.B8_NUMLOTE = %Exp:cNumLote%
		AND SB8.%NotDel%
	EndSql
	TcSetField( cAliasSB8,'B8_DTVALID','D')
	If (cAliasSB8)->(!Eof())
		dDtValid := (cAliasSB8)->B8_DTVALID
	EndIf
	(cAliasSB8)->(dbCloseArea())

	If nRecnoSD4 == 0
		cWhere := "%"
		If !Empty(cLoteCtl)
			cWhere += " AND (SD4.D4_LOTECTL = '"+Space(TamSx3("D4_LOTECTL")[1])+"' OR SD4.D4_LOTECTL = '"+cLoteCtl+"')"
		EndIf
		If !Empty(cNumLote)
			cWhere += " AND (SD4.D4_NUMLOTE = '"+Space(TamSx3("D4_NUMLOTE")[1])+"' OR SD4.D4_NUMLOTE = '"+cNumLote+"')"
		EndIf
		If !Empty(cIdDCF)
			cWhere += " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasSD4
			SELECT SD4.D4_TRT,
					SD4.R_E_C_N_O_ RECNOSD4
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.D4_COD = %Exp:cProduto%
			AND SD4.D4_OP = %Exp:cOp%
			AND SD4.D4_TRT = %Exp:cTrt%
			AND SD4.D4_LOCAL = %Exp:cArmazem%
			AND SD4.%NotDel%
			%Exp:cWhere%
			ORDER BY SD4.D4_TRT
		EndSql
	Else
		BeginSql Alias cAliasSD4
			SELECT SD4.R_E_C_N_O_ RECNOSD4
			FROM %Table:SD4% SD4
			WHERE SD4.D4_FILIAL = %xFilial:SD4%
			AND SD4.R_E_C_N_O_ = %Exp:nRecnoSD4%
			AND SD4.%NotDel%
		EndSql
	EndIf
	Do While lRet .And. (cAliasSD4)->(!Eof()) .And. QtdComp(nQuant) > 0
		SD4->(DbGoTo((cAliasSD4)->RECNOSD4))
		RecLock("SD4", .F.)
		lRastro := Rastro(SD4->D4_COD)
		//-- Verifica se a quantidade liberada nesta sequencia é menor ou igual ao solicitado
		nQtdEmp    := SD4->D4_QUANT
		nQtdEmp2UM := SD4->D4_QTSEGUM
		If QtdComp(nQtdEmp) <= QtdComp(nQuant)
			cTrtSD4   := SD4->D4_TRT
			nNewRecno := SD4->(Recno())
			//-- Só liberar esta sequencia da SD4, não há o que dividir
			SD4->D4_IDDCF  := cIdDCF
			If SD4->D4_LOTECTL <> cLoteCtl
				cTrtSD4 := UpdSD4WMS(cLoteCtl, cNumLote, cTrtSD4)
				SD4->D4_TRT := cTrtSD4
				SD4->D4_LOTECTL := cLoteCtl
				SD4->D4_NUMLOTE := cNumLote
				SD4->D4_DTVALID := dDtValid
				cTrt := cTrtSD4 //A chave foi atualizada caso lGeraEmp for verdadeiro
			EndIf
			SD4->(MsUnlock())
			// Se deve gerar empenho, neste caso sempre gera o empenho para a sequencia atual
			If lGeraEmp
				lRet := WmsAtuSDC("SC2",cOp,cTrt,/*cPedido*/,/*cItem*/,/*cSeqSC9*/,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdEmp,nQtdEmp2UM,cArmazem,cEndereco,cIdDCF,2,.F.)
			EndIf
		Else
			nQtdEmp    := Min(nQtdEmp,nQuant)
			nQtdEmp2UM := ConvUM(cProduto, nQtdEmp, 0, 2)
			// Efetua cópia da SD4
			For nCnt := 1 To SD4->(FCount())
				AAdd(aCopySD4, SD4->(FieldGet(nCnt)))
			Next nCnt
			// Se não empenha o novo, deve atualizar o registro atual
			If !lEmpNew
				SD4->D4_QUANT   := nQtdEmp
				SD4->D4_QTSEGUM := nQtdEmp2UM
				SD4->D4_QTDEORI := nQtdEmp
				SD4->D4_IDDCF   := cIdDCF
				If SD4->D4_LOTECTL <> cLoteCtl
					SD4->D4_LOTECTL := cLoteCtl
					SD4->D4_NUMLOTE := cNumLote
					SD4->D4_DTVALID := dDtValid
				EndIf
			// Só diminui do registro atual a quantidade a ser empenhada
			Else
				SD4->D4_QTDEORI -= nQtdEmp
				SD4->D4_QUANT   -= nQtdEmp
				SD4->D4_QTSEGUM -= nQtdEmp2UM
			EndIf
			SD4->(MsUnlock())
			// Se deve gerar empenho e não é para a nova sequencia, empenha a atual
			If lGeraEmp .And. !lEmpNew
				lRet := WmsAtuSDC("SC2",cOp,cTrt,/*cPedido*/,/*cItem*/,/*cSeqSC9*/,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdEmp,nQtdEmp2UM,cArmazem,cEndereco,cIdDCF,2)
			EndIf
			If lRet
				//-- Pega a sequencia máxima da SD4
				cTrtSD4 := WMaxTrtSD4(cOp,cProduto)
				cTrtSD4 := Soma1(cTrtSD4)

				RecLock("SD4", .T.)
				For nCnt := 1 To Len(aCopySD4)
					FieldPut(nCnt, aCopySD4[nCnt])
				Next nCnt
				SD4->D4_TRT := cTrtSD4
				// Se empenha o novo, deve atualizar o registro novo
				If lEmpNew
					SD4->D4_QTDEORI := nQtdEmp
					SD4->D4_QUANT   := nQtdEmp
					SD4->D4_QTSEGUM := nQtdEmp2UM
					SD4->D4_IDDCF   := cIdDCF
					If lOrigPerda
					   If lRastro
							//-- Se registro gerado pela perda, significa que não há saldo do lote no endereço
							//-- Assim, remove lote para não "prender" saldo da OP (cenário de apontamento parcial)
							SB8->(dbSetOrder(3))
							SB8->(dbSeek(xFilial("SB8")+SD4->(D4_COD+D4_LOCAL+D4_LOTECTL+D4_NUMLOTE)))
							GravaB8Emp("-",nQtdEmp,"F",NIL,nQtdEmp2UM)
							SD4->D4_LOTECTL := CriaVar("D4_LOTECTL",.F.)
							SD4->D4_NUMLOTE := CriaVar("D4_NUMLOTE",.F.)
							SD4->D4_DTVALID := CriaVar("D4_DTVALID",.F.)
						EndIf
						SD4->D4_IDDCF   := CriaVar("D4_IDDCF",.F.)

						If nRecnoSBC > 0 .And. nRecnoSD4 > 0
							lQuebraD4 := .T. //--Seta variavel para que ocorra a baixa da DC_QTDORIG na funcao WmsAtuSDC
							SBC->(dbGoTo(nRecnoSBC))
						EndIf

					ElseIf SD4->D4_LOTECTL <> cLoteCtl
						SD4->D4_LOTECTL := cLoteCtl
						SD4->D4_NUMLOTE := cNumLote
						SD4->D4_DTVALID := dDtValid
					EndIf
				Else
					SD4->D4_QTDEORI -= nQtdEmp
					SD4->D4_QUANT   -= nQtdEmp
					SD4->D4_QTSEGUM -= nQtdEmp2UM
				EndIf
				nNewRecno := SD4->(Recno())
				SD4->(MsUnlock())
				//-- Deve gerar o empenho para a quantidade dividida
				If lGeraEmp .And. lEmpNew
					lRet := WmsAtuSDC("SC2",cOp,cTrtSD4,/*cPedido*/,/*cItem*/,/*cSeqSC9*/,cProduto,cLoteCtl,cNumLote,cNumSerie,nQtdEmp,nQtdEmp2UM,cArmazem,cEndereco,cIdDCF,2)
				EndIf
			EndIf
		EndIf
		nQuant -= nQtdEmp
		(cAliasSD4)->(dbSkip())
	EndDo
	(cAliasSD4)->(dbCloseArea())

	RestArea(aAreaSBC)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
// Retorna o saldo das requisições no WMS no estorno do apontamento da OP
//------------------------------------------------------------------------------
Function WmsEstReq(nRecSD3)
Local lRet      := .T.
Local lRastro   := .F.
Local lSubLot   := .F.
Local lEmpenho  := .F.
Local aAreaAnt  := GetArea()
Local aAreaSD3  := SD3->(GetArea())
Local aProduto  := {}
Local aTamSX3   := {}
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local oProdComp := oEstEnder:oProdLote:oProduto:oProdComp
Local cWhere    := ""
Local cAliasD13 := Nil
Local cAliasSDC := Nil
Local cAliasSB2 := Nil
Local cAliasSB8 := Nil
Local cNumSeq   := ""
Local cDoc      := ""
Local cOp       := ""
Local cTrt      := ""
Local cProduto  := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cTipoLote := ""
Local lSemSDC   := .F.
Local nQtdMaior := 0
Local nQtdEst := 0
Local nQtdEst2 := 0
Local lRetEmp  := .T.
Local nQtdBx 	:= 0
Local lWmsBxOp  := SuperGetMV("MV_WMSBXOP",.F.,.F.)
Local lEmpOp     := .T.
Local lEmpD14    := .T.

	SD3->(MsGoTo(nRecSD3))
	cNumSeq := SD3->D3_NUMSEQ
	cDoc    := SD3->D3_DOC
	cOp     := SD3->D3_OP
	cTrt    := SD3->D3_TRT
	cProduto:= SD3->D3_COD
	cLoteCtl:= SD3->D3_LOTECTL
	cNumLote:= SD3->D3_NUMLOTE
	lRastro := Rastro(SD3->D3_COD); Iif(lRastro,cTipoLote := "L",)
	lSubLot := Rastro(SD3->D3_COD,"S"); Iif(lSubLot,cTipoLote := "S",)
	nQtdMaior := SD3->D3_QTMAIOR
	lEmpOp  := SD3->D3_EMPOP = "S"

	// Busca as movimentações do kardex quando realizado a baixa
	cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND D13.D13_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D13.D13_NUMLOT = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	cAliasD13 := GetNextAlias()
	BeginSql Alias cAliasD13
		SELECT D13.D13_TM,
				D13.D13_LOCAL,
				D13.D13_ENDER,
				D13.D13_PRODUT,
				D13.D13_PRDORI,
				D13.D13_LOTECT,
				D13.D13_NUMLOT,
				D13.D13_NUMSER,
				D13.D13_QTDEST,
				D13.D13_QTDES2,
				D13.D13_ORIGEM,
				D13.D13_DOC,
				D13.D13_SERIE,
				D13.D13_CLIFOR,
				D13.D13_LOJA,
				D13.D13_NUMSEQ,
				D13.D13_IDDCF,
				D13.D13_IDMOV,
				D13.D13_IDOPER,
				D13.D13_IDUNIT
		FROM %Table:D13% D13
		WHERE D13.D13_FILIAL = %xFilial:D13%
		AND D13.D13_NUMSEQ = %Exp:cNumSeq%
		AND D13.D13_DOC = %Exp:cDoc%
		AND D13.D13_PRODUT = %Exp:cProduto%
		AND D13.D13_TM >= '500'
		AND D13.D13_USACAL = '1'
		AND D13.%NotDel%
		%Exp:cWhere%
	EndSql
	aTamSX3 := TamSx3("D14_QTDEST"); TcSetField( cAliasD13,'D13_QTDEST','N',aTamSx3[1],aTamSx3[2])
	aTamSX3 := TamSx3("D13_QTDES2"); TcSetField( cAliasD13,'D13_QTDES2','N',aTamSx3[1],aTamSx3[2])
	Do While lRet .And. (cAliasD13)->(!Eof())

		If (cAliasD13)->D13_QTDEST <= SD3->D3_QUANT
			If nQtdBx == SD3->D3_QUANT
				Exit
			EndIf
		Else
			(cAliasD13)->(dbSkip())
			Loop
		EndIf

		nQtdEst := (cAliasD13)->D13_QTDEST
		nQtdEst2 := ConvUm(cProduto,nQtdEst,0,2)
		If nQtdMaior > 0  .AND.  nQtdMaior <= (cAliasD13)->D13_QTDEST
			nQtdEst := (cAliasD13)->D13_QTDEST - nQtdMaior
			nQtdMaior := 0
			nQtdEst2 := ConvUm(cProduto,nQtdEst,0,2)
		elseIf nQtdMaior > 0 .AND. nQtdMaior > (cAliasD13)->D13_QTDEST
 			nQtdEst := (cAliasD13)->D13_QTDEST
			nQtdMaior -=  (cAliasD13)->D13_QTDEST
			nQtdEst2 := ConvUm(cProduto,nQtdEst,0,2)
		EndIf

		//Fazer busca geral na SDC sem o ID_DCF validando se nao tem empenhos devido apontamento sem empenho criado na SDC
		cWhere := "%"
		If !Empty((cAliasD13)->D13_LOTECT)
			cWhere += " AND SDC.DC_LOTECTL = '"+(cAliasD13)->D13_LOTECT+"'"
		EndIf
		If !Empty((cAliasD13)->D13_NUMLOT)
			cWhere += " AND SDC.DC_NUMLOTE = '"+(cAliasD13)->D13_NUMLOT+"'"
		EndIf
		cWhere += "%"

		lSemSDC := .F.
		cAliasSDC := GetNextAlias()
		BeginSql Alias cAliasSDC
			SELECT DISTINCT 1
			FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL = %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:(cAliasD13)->D13_PRODUT%
			AND SDC.DC_LOCAL = %Exp:(cAliasD13)->D13_LOCAL%
			AND SDC.DC_OP = %Exp:cOp%
			AND SDC.DC_TRT = %Exp:cTrt%
			AND SDC.DC_LOCALIZ = %Exp:(cAliasD13)->D13_ENDER%
			AND SDC.DC_NUMSERI = %Exp:(cAliasD13)->D13_NUMSER%
			AND SDC.%NotDel%
			%Exp:cWhere%
		EndSql
		lSemSDC := (cAliasSDC)->(Eof())
		(cAliasSDC)->(dbCloseArea())

		If !lSemSDC
			// Retorna o registro de empenho SDC caso houve
			cWhere := ""
			cWhere := "%"
			If !Empty((cAliasD13)->D13_LOTECT)
				cWhere += " AND SDC.DC_LOTECTL = '"+(cAliasD13)->D13_LOTECT+"'"
			EndIf
			If !Empty((cAliasD13)->D13_NUMLOT)
				cWhere += " AND SDC.DC_NUMLOTE = '"+(cAliasD13)->D13_NUMLOT+"'"
			EndIf
			cWhere += " AND SDC.DC_IDDCF = '"+PadR((cAliasD13)->D13_IDDCF,TamSx3("DC_IDDCF")[1])+"'"
			cWhere += "%"

			cAliasSDC := GetNextAlias()
			BeginSql Alias cAliasSDC
				SELECT SDC.R_E_C_N_O_ RECNOSDC
				FROM %Table:SDC% SDC
				WHERE SDC.DC_FILIAL = %xFilial:SDC%
				AND SDC.DC_PRODUTO = %Exp:(cAliasD13)->D13_PRODUT%
				AND SDC.DC_LOCAL = %Exp:(cAliasD13)->D13_LOCAL%
				AND SDC.DC_OP = %Exp:cOp%
				AND SDC.DC_TRT = %Exp:cTrt%
				AND SDC.DC_LOCALIZ = %Exp:(cAliasD13)->D13_ENDER%
				AND SDC.DC_NUMSERI = %Exp:(cAliasD13)->D13_NUMSER%
				AND SDC.%NotDel%
				%Exp:cWhere%
			EndSql
			If (lEmpenho := (cAliasSDC)->(!Eof()))
				If (!FwIsInCallStack("MATA241")) .Or. (lWmsBxOp .And. lEmpOp)
					SDC->(MsGoto((cAliasSDC)->RECNOSDC))
					RecLock("SDC",.F.)
					SDC->DC_QUANT   += nQtdEst
					SDC->DC_QTSEGUM += nQtdEst2
					SDC->(MsUnlock())
				EndIf
			EndIf
			(cAliasSDC)->(dbCloseArea())
		EndIf
		If lRastro
			// Estorna a movimentação do Lote/Sub-Lote
			EstornaSD5(cTipoLote,;
				(cAliasD13)->D13_PRODUT,;
				(cAliasD13)->D13_LOCAL,;
				(cAliasD13)->D13_LOTECT,;
				(cAliasD13)->D13_NUMLOT,;
				(cAliasD13)->D13_NUMSEQ,;
				.F.,;
				Nil/*lBxQtdClass*/,;
				(cAliasD13)->D13_TM,;
				Nil/*nQuantPMax*/,;
				(cAliasD13)->D13_QTDEST,;
				Nil/*cAliasOri*/,Nil/*cCliFor*/,Nil/*cLoja*/,(cAliasD13)->D13_DOC,Nil/*cSerie*/)

			If lEmpenho .OR. lSemSDC
				// Retorna o empenho SB2 caso houver SDC
				cAliasSB2 := GetNextAlias()
				BeginSql Alias cAliasSB2
					SELECT SB2.R_E_C_N_O_ RECNOSB2
					FROM %Table:SB2% SB2
					WHERE SB2.B2_FILIAL = %xFilial:SB2%
					AND SB2.B2_COD = %Exp:(cAliasD13)->D13_PRODUT%
					AND SB2.B2_LOCAL = %Exp:(cAliasD13)->D13_LOCAL%
					AND SB2.%NotDel%
				EndSql
				If (cAliasSB2)->(!Eof())
					SB2->(dbGoTo((cAliasSB2)->RECNOSB2))
					If (!FwIsInCallStack("MATA241")) .Or. (lWmsBxOp .And. lEmpOp)
						GravaB2Emp("+",nQtdEst,,.F./*lPedido*/,nQtdEst2)
					EndIf
				EndIf
				(cAliasSB2)->(dbCloseArea())
				// Retorna o empenho SB8
				If Rastro((cAliasD13)->D13_PRODUT) .And. !Empty((cAliasD13)->D13_LOTECT+(cAliasD13)->D13_NUMLOT) .AND. lEmpenho
					cAliasSB8 := GetNextAlias()
					BeginSql Alias cAliasSB8
						SELECT SB8.R_E_C_N_O_ RECNOSB8
						FROM %Table:SB8% SB8
						WHERE SB8.B8_FILIAL = %xFilial:SB8%
						AND SB8.B8_PRODUTO = %Exp:(cAliasD13)->D13_PRODUT%
						AND SB8.B8_LOCAL = %Exp:(cAliasD13)->D13_LOCAL%
						AND SB8.B8_LOTECTL = %Exp:(cAliasD13)->D13_LOTECT%
						AND SB8.B8_NUMLOTE = %Exp:(cAliasD13)->D13_NUMLOT%
						AND SB8.%NotDel%
					EndSql
					If (cAliasSB8)->(!Eof())
						SB8->(dbGoTo((cAliasSB8)->RECNOSB8))
						If (!FwIsInCallStack("MATA241")) .Or. (lWmsBxOp .And. lEmpOp)
							GravaB8Emp("+",nQtdESt,"",.T.)
						EndIf
					EndIf
					(cAliasSB8)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
		If lEmpenho .OR. lSemSDC
			// Retorna o saldo das requisições no endereço de produção
			// Inicialia objeto
			oEstEnder:ClearData()
			// Informações do endereço
			oEstEnder:oEndereco:SetArmazem((cAliasD13)->D13_LOCAL)
			oEstEnder:oEndereco:SetEnder((cAliasD13)->D13_ENDER)
			oEstEnder:oEndereco:LoadData()
			// Informações do produto
			oEstEnder:oProdLote:SetArmazem((cAliasD13)->D13_LOCAL)
			oEstEnder:oProdLote:SetPrdOri((cAliasD13)->D13_PRDORI)
			oEstEnder:oProdLote:SetProduto((cAliasD13)->D13_PRODUT)
			oEstEnder:oProdLote:SetLoteCtl((cAliasD13)->D13_LOTECT)
			oEstEnder:oProdLote:SetNumLote((cAliasD13)->D13_NUMLOT)
			oEstEnder:oProdLote:SetNumSer((cAliasD13)->D13_NUMSER)
			oEstEnder:oProdLote:LoadData()
			// Seta o bloco de código para informações do documento para o Kardex
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem((cAliasD13)->D13_ORIGEM),;
				oMovEstEnd:SetDocto((cAliasD13)->D13_DOC),;
				oMovEstEnd:SetSerie((cAliasD13)->D13_SERIE),;
				oMovEstEnd:SetCliFor((cAliasD13)->D13_CLIFOR),;
				oMovEstEnd:SetLoja((cAliasD13)->D13_LOJA),;
				oMovEstEnd:SetNumSeq((cAliasD13)->D13_NUMSEQ),;
				oMovEstEnd:SetIdDCF((cAliasD13)->D13_IDDCF);
			})
			// Seta o bloco de código para informações do movimento para o Kardex
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto((cAliasD13)->D13_IDMOV),;
				oMovEstEnd:SetIdOpera((cAliasD13)->D13_IDOPER),;
				oMovEstEnd:SetIdUnit((cAliasD13)->D13_IDUNIT);
			})
			oEstEnder:SetQuant((cAliasD13)->D13_QTDEST)
			lRet := oEstEnder:UpdSaldo('499',.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)

			//Atulização somente do empenho na D14
			oEstEnder:ClearData()
			// Informações do endereço
			oEstEnder:oEndereco:SetArmazem((cAliasD13)->D13_LOCAL)
			oEstEnder:oEndereco:SetEnder((cAliasD13)->D13_ENDER)
			oEstEnder:oEndereco:LoadData()
			// Informações do produto
			oEstEnder:oProdLote:SetPrdOri((cAliasD13)->D13_PRDORI)
			oEstEnder:oProdLote:SetProduto((cAliasD13)->D13_PRODUT)
			oEstEnder:oProdLote:SetLoteCtl((cAliasD13)->D13_LOTECT)
			oEstEnder:oProdLote:SetNumLote((cAliasD13)->D13_NUMLOT)
			oEstEnder:oProdLote:SetNumSer((cAliasD13)->D13_NUMSER)
			oEstEnder:oProdLote:LoadData()
			// Seta o bloco de código para informações do documento para o Kardex

			lEmpD14 := lEmpenho
			If FwIsInCallStack("MATA241")
				If lWmsBxOp .And. lSemSDC
					lEmpD14 := .F.
				Else
					lEmpD14 := lEmpOp
				EndIf
			EndIf
			oEstEnder:SetQuant(nQtdEst)
			lRetEmp := oEstEnder:UpdSaldo('499',.F./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,lEmpD14 /*lEmpenho*/,.F./*lBloqueio*/,.F./*lEmpPrev*/,.F./*lMovEstEnd*/)
			If !lRetEmp .And. lEmpenho
			    lRet := .F.
			EndIf

			If lRet
				nQtdBx += (cAliasD13)->D13_QTDEST
			EndIf

		EndIF
		(cAliasD13)->(dbSkip())
	EndDo
	(cAliasD13)->(dbCloseArea())

	oEstEnder:Destroy()
	RestArea(aAreaSD3)
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Pega qual é máxima sequencia de uma requisição de um produto na SD4
//-----------------------------------------------------------------------------
Function WMaxTrtSD4(cOp,cProduto)
Local aAreaAnt  := GetArea()
Local cAliasSeq := GetNextAlias()
Local cTrtSD4   := "01"

	BeginSql Alias cAliasSeq
		SELECT MAX(SD4.D4_TRT) MAXSD4TRT
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL  = %xFilial:SD4%
		AND SD4.D4_OP  = %Exp:cOp%
		AND SD4.D4_COD = %Exp:cProduto%
		AND SD4.%NotDel%
	EndSql
	If (cAliasSeq)->(!Eof())
		cTrtSD4 := (cAliasSeq)->MAXSD4TRT
	EndIf
	(cAliasSeq)->(DbCloseArea())

	RestArea(aAreaAnt)
Return cTrtSD4

Function WMVlOPLtEn(cArmazem,cEndereco,cProduto,cNumSerie,cLoteCtl,cNumLote,nAcumulado)
//validar se o produto controla lote
//se controla lote validar se o campo cLoteCtl está preenchido
Local oProduto := WMSDTCProdutoDadosGenericos():New()
Local lRet := .T.
Local nSaldoEnd := 0

    IF !Empty(cEndereco)
		oProduto:SetProduto(cProduto)
		If oProduto:LoadData()
			IF (oProduto:HasRastSub() .AND. Empty(cNumLote)) .AND. (oProduto:HasRastro() .AND. Empty(cLoteCtl))
				WmsMessage(STR0003,WMSXFUNJ03,,,,STR0004) //"Endereço de produção informado."  "Para informar um endereço o Lote/Sublote deverá ser informado."
				lRet:= .F.
			Else
				If (oProduto:HasRastSub() .AND. Empty(cNumLote))
					WmsMessage(STR0003,WMSXFUNJ04,,,,STR0005) //"Endereço de produção informado."   "Para informar um endereço o Sublote deverá ser informado."
					lRet:= .F.
				Else
					IF oProduto:HasRastro() .AND. Empty(cLoteCtl)
    	   	        	WmsMessage(STR0003,WMSXFUNJ05,,,,STR0006) // "Endereço de produção informado."  "Para informar um endereço o Lote deverá ser informado."
						lRet:= .F.
					EndIf
				Endif
			EndIf
		EndIf
	EndIf
    If lRet
		nSaldoEnd := WmsSldD14(cArmazem,cEndereco,cProduto,cNumSerie,cLoteCtl,cNumLote)
		If nAcumulado > nSaldoEnd
			WmsMessage(WmsFmtMsg(STR0007,{{"[VAR01]",cEndereco},{"[VAR02]",AllTrim(Str(nSaldoEnd))}}),WMSXFUNJ06,5,.T.,,STR0008) //"O produto não tem saldo suficiente ou o endereço selecionado não possui saldo suficiente. Endereço: [VAR01]. Quantidade: [VAR02]."  "Diminua a quantidade do movimento ou selecione outra localização."
			lRet:= .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} UpdSD4WMS
//Verifica se já existe empenho para o lote, se sim, gera nova sequencia TRT
@author Equipe WMS
@since 25/08/2021
/*/
Static Function UpdSD4WMS(cLote, cNumLt, cTrtOld)
Local aAreaAnt  := GetArea()
Local lUpdTRT 	:= .F.
Local cAliasTrt := GetNextAlias()

	BeginSql Alias cAliasTrt
		SELECT SD4.R_E_C_N_O_ RECNOSD4
		FROM %Table:SD4% SD4
		WHERE SD4.D4_FILIAL  = %xFilial:SD4%
		AND SD4.D4_COD = %Exp:SD4->D4_COD%
		AND SD4.D4_OP  = %Exp:SD4->D4_OP%
		AND SD4.D4_TRT = %Exp:cTrtOld%
		AND SD4.D4_LOTECTL = %Exp:cLote%
		AND SD4.D4_NUMLOTE = %Exp:cNumLt%
		AND SD4.%NotDel%
	EndSql
	If (cAliasTrt)->(!Eof())
		lUpdTRT := .T.
	EndIf
	(cAliasTrt)->(DbCloseArea())
	If lUpdTRT
		cTrtOld := WMaxTrtSD4(SD4->D4_OP,SD4->D4_COD)
		cTrtOld := Soma1(cTrtOld)
	EndIf
	RestArea(aAreaAnt)
Return cTrtOld

/*/{Protheus.doc} WMSVlLtSd4
//Validação quando foi informado o lote na Sd4, e não foi informado o endereço
//e é efeutado o apontamento sem antes gerar os empenhos na SD4.
@author Roselaine Adriano
@since 25/10/2021
/*/
Function WMSVlLtSd4(lWmsNew,lProdWms,lCriaSDC,lCtrLote,cLote,cProduto,nPercPrM,cD4Op,cD4TRT,cLocal)
Local lRet:= .T.
Local cAliasQry := NIL
Local lValida := .T.
Default nPercPrM := 0

 	If nPercPrM > 0
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
		   SELECT SUM(DC_QUANT) as QTDSDC
		   	FROM %Table:SDC% SDC
			WHERE SDC.DC_FILIAL =  %xFilial:SDC%
			AND SDC.DC_PRODUTO = %Exp:cProduto%
			AND SDC.DC_LOCAL = %Exp:cLocal%
			AND SDC.DC_OP = %Exp:cD4OP%
			AND SDC.DC_TRT = %Exp:cD4TRT%
			AND SDC.DC_LOTECTL = %Exp:cLote%
			AND SDC.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			IF (cAliasQry)->QTDSDC > 0
				lValida := .F.
			ENDIF
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If lWmsNew .AND. lProdWms .AND. lCriaSDC .AND. lCtrLote .AND. !Empty(cLote) .AND. lValida
		WmsMessage(WmsFmtMsg(STR0009,{{"[VAR01]",cProduto}}),WMSXFUNJ07,5,.T.) //"Componente : [VAR01], com controle de lote e endereço, porém somente o saldo por lote foi empenhado. Para efetuar o apontamento é necessário efetivar o processo de empenho de requisição no SIGAWMS."
		lRet := .F.
	EndIf
Return lRet


