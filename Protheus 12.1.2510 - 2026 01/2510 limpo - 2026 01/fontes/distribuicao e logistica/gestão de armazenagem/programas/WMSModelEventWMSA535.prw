#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
CLASS WMSModelEventWMSA535 FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	METHOD BeforeTTS(oModel, cModelId)
	METHOD After(oModel, cModelId, cAlias, lNewRecord)
	METHOD InTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)

	METHOD ModelPreVld(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New() CLASS WMSModelEventWMSA535
Return
 
METHOD Destroy()  Class WMSModelEventWMSA535
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
//-------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) CLASS WMSModelEventWMSA535
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// depois da gravação de cada submodelo (field ou cada linha de uma grid)
//-------------------------------------------------------------------
METHOD After(oModel, cModelId, cAlias, lNewRecord) CLASS WMSModelEventWMSA535
Local lRet       := .T.
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do commit
// Após as gravações porém antes do final da transação
//-------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) CLASS WMSModelEventWMSA535
Local aAreaSB8  := SB8->(GetArea())
Local lRet      := .T.
Local cQuery    := ""
Local cAliasD14 := ""
Local cAliasSB8 := GetNextAlias()
Local cSeekSDD  := ""
Local cSeekSB8  := ""
Local cSeekSB2  := ""
Local cWhere    := ""
Local cAliasDH1 := GetNextAlias()
Local bBlockSB2 := Nil
Local bBlockSDD := Nil
Local nBlqTotal := 0
Local nBaixaRes := 0
Local nBaixaEmp := 0
Local dDtValid  := SB8->B8_DTVALID
Local dDFabric  := SB8->B8_DFABRIC

	Pergunte("WMSA535",.F.)

	// Atualiza a data de validade do lote na tabela de Saldo por Endereço
	cQuery := "SELECT R_E_C_N_O_ RECNOD14"
	cQuery +=  " FROM " + RetSqlName("D14")
	cQuery += " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	If MV_PAR01 == 1
		cQuery += " AND D14_LOCAL  = '"+SB8->B8_LOCAL+"'"
	EndIf
	cQuery +=   " AND D14_PRDORI = '"+SB8->B8_PRODUTO+"'"
	cQuery +=   " AND D14_LOTECT = '"+SB8->B8_LOTECTL+"'"
	cQuery +=   " AND D14_NUMLOT = '"+SB8->B8_NUMLOTE+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD14 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	While !(cAliasD14)->(Eof())
		D14->(DbGoTo((cAliasD14)->RECNOD14))
		RecLock("D14",.F.)
		D14->D14_DTVALD := dDtValid
		D14->D14_DTFABR := dDFabric
		D14->(MsUnlock())
		(cAliasD14)->(DbSkip())
	EndDo
	(cAliasD14)->(DbCloseArea())


	cWhere := "%"
	If MV_PAR01 == 1
		cWhere += " AND DH1.DH1_LOCAL = '"+SB8->B8_LOCAL+"'"
	EndIf
	cWhere += "%"
	// Atualiza registro de DH1 pendentes
	BeginSql Alias cAliasDH1
		SELECT DH1.R_E_C_N_O_ RECNODH1  
		  FROM %Table:DH1% DH1
		 WHERE DH1.DH1_FILIAL = %xFilial:DH1%
		   AND DH1.DH1_PRODUT = %Exp:SB8->B8_PRODUTO%
		   AND DH1.DH1_LOTECT = %Exp:SB8->B8_LOTECTL%
		   AND DH1.DH1_NUMLOT = %Exp:SB8->B8_NUMLOTE%
		   AND DH1.DH1_STATUS = '1'
		   AND DH1.%NotDel%
		   %Exp:cWhere%
	EndSql
	While (cAliasDH1)->(!EoF())
		DH1->(DbGoTo((cAliasDH1)->RECNODH1))
		RecLock("DH1",.F.)
		DH1->DH1_DTVALI := dDtValid
		DH1->(MsUnlock())
		(cAliasDH1)->(DbSkip())
	EndDo
	(cAliasDH1)->(DbCloseArea())

	// Atualiza a data de validade dos demais armazéns, quando parametrizado para tal
	If MV_PAR01 == 2
		BeginSql Alias cAliasSB8
			SELECT SB8.R_E_C_N_O_ RECNOSB8  
		  		FROM %Table:SB8% SB8
			WHERE SB8.B8_FILIAL = %xFilial:SB8%
		   		AND SB8.B8_PRODUTO = %Exp:SB8->B8_PRODUTO%
		   		AND SB8.B8_LOTECTL = %Exp:SB8->B8_LOTECTL%
		   		AND SB8.B8_NUMLOTE = %Exp:SB8->B8_NUMLOTE%
		   		AND SB8.%NotDel%
		EndSql

		While (cAliasSB8)->(!EoF())
			SB8->(DbGoTo((cAliasSB8)->RECNOSB8))
			RecLock("SB8",.F.)
			SB8->B8_DTVALID := dDtValid
			SB8->B8_DFABRIC := dDFabric
			SB8->(MsUnlock())
			(cAliasSB8)->(DbSkip())
		EndDo
		(cAliasSB8)->(DbCloseArea())
	EndIf

	// Verifica se deve atualizar o armazém do lote ou todos os armazéns
	If MV_PAR01 == 1
		SDD->(DbSetOrder(2))
		cSeekSDD  := xFilial("SDD")+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL+SB8->B8_NUMLOTE
		bBlockSDD := {|| SDD->DD_FILIAL+SDD->DD_PRODUTO+SDD->DD_LOCAL+SDD->DD_LOTECTL+SDD->DD_NUMLOTE == cSeekSDD}
	Else
		SDD->(DbSetOrder(3))
		cSeekSDD  := xFilial("SDD")+SB8->B8_PRODUTO+SB8->B8_LOTECTL+SB8->B8_NUMLOTE
		bBlockSDD := {|| SDD->DD_FILIAL+SDD->DD_PRODUTO+SDD->DD_LOTECTL+SDD->DD_NUMLOTE == cSeekSDD}
	EndIf

	If !SDD->(DbSeek(cSeekSDD))
		Return .T.
	EndIf

	While !SDD->(Eof()) .And. Eval(bBlockSDD)
		// Se for bloqueio por data de validade, elimina os registros. Caso contrário, apenas atualiza com a nova informação.
		If SDD->DD_MOTIVO == "VV"
			nBlqTotal += SDD->DD_SALDO
			// Elimina o empenho relacionado ao bloqueio de saldo
			SDC->(DbSetOrder(1))
			If SDC->(DbSeek(xFilial("SDC")+SDD->DD_PRODUTO+SDD->DD_LOCAL+"SDD"+CriaVar("DC_PEDIDO")+CriaVar("DC_ITEM")+CriaVar("DC_SEQ")+SDD->DD_LOTECTL+SDD->DD_NUMLOTE))
				RecLock("SDC",.F.)
				If QtdComp(SDD->DD_SALDO) < QtdComp(SDC->DC_QUANT)
					SDC->DC_QUANT   -= SDD->DD_SALDO
					SDC->DC_QTSEGUM := ConvUm(SDC->DC_PRODUTO,SDC->DC_QUANT,0,2)
				Else
					SDC->(DbDelete())
				EndIf
				SDC->(MsUnlock())
			EndIf
			// Elimina os registros de bloqueio de saldo WMS com base no bloqueio de saldo ERP
			D0U->(DbSetOrder(1))
			If D0U->(DbSeek(xFilial("D0U")+SDD->DD_DOC))
				D0V->(DbSetOrder(1))
				D0V->(DbSeek(cSeekD0V := xFilial("D0V")+D0U->D0U_IDBLOQ+SDD->DD_PRODUTO))
				While !D0V->(Eof()) .And. D0V->D0V_FILIAL+D0V->D0V_IDBLOQ+D0V->D0V_PRDORI == cSeekD0V
					// Só considera itens de mesmo lote/sublote
					If D0V->D0V_LOTECT+D0V->D0V_NUMLOT == SDD->DD_LOTECTL+SDD->DD_NUMLOTE
						// Atualiza o empenho dos registros de saldo por endereço
						D14->(DbSetOrder(3))
						D14->(DbSeek(cSeekD14 := xFilial("D14")+D0V->D0V_LOCAL+D0V->D0V_PRODUT+D0V->D0V_ENDER+D0V->D0V_LOTECT+D0V->D0V_NUMLOT))
						While !D14->(Eof()) .And. D14->D14_FILIAL+D14->D14_LOCAL+D14->D14_PRODUT+D14->D14_ENDER+D14->D14_LOTECT+D14->D14_NUMLOT == cSeekD14
							If D14->D14_IDUNIT == D0V->D0V_IDUNIT
								RecLock("D14",.F.)
								D14->D14_QTDBLQ -= D0V->D0V_QTDBLQ
								D14->D14_QTDBL2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDBLQ,0,2)
								D14->(MsUnlock())
							EndIf
							D14->(DbSkip())
						EndDo
						// Elimina o item de bloqueio de saldo
						RecLock("D0V",.F.)
						D0V->(DbDelete())
						D0V->(MsUnlock())
					EndIf
					D0V->(DbSkip())
				EndDo
				// Se não encontrar mais nenhum item deste ID, elimina também o documento de bloqueio
				If !D0V->(DbSeek(xFilial("D0V")+D0U->D0U_IDBLOQ))
					RecLock("D0U",.F.)
					D0U->(DbDelete())
					D0U->(MsUnlock())
				EndIf
			EndIf
			// Elimina o registro de bloqueio de saldo ERP
			RecLock("SDD",.F.)
			SDD->(DbDelete())
			SDD->(MsUnlock())
		Else
			// Atualiza tabelas de bloqueio de saldo com a nova data de validade
			D0U->(DbSetOrder(1))
			If D0U->(DbSeek(xFilial("D0U")+SDD->DD_DOC))
				D0V->(DbSetOrder(1))
				D0V->(DbSeek(cSeekD0V := xFilial("D0V")+D0U->D0U_IDBLOQ+SDD->DD_PRODUTO))
				While !D0V->(Eof()) .And. D0V->D0V_FILIAL+D0V->D0V_IDBLOQ+D0V->D0V_PRDORI == cSeekD0V
					// Só considera itens de mesmo lote/sublote
					If D0V->D0V_LOTECT+D0V->D0V_NUMLOT == SDD->DD_LOTECTL+SDD->DD_NUMLOTE
						RecLock("D0V",.F.)
						D0V->D0V_DTVALD := dDtValid
						D0V->(MsUnlock())
					EndIf
					D0V->(DbSkip())
				EndDo
			EndIf
			// Elimina o registro de bloqueio de saldo ERP
			RecLock("SDD",.F.)
			SDD->DD_DTVALID := dDtValid
			SDD->(MsUnlock())
		EndIf
		SDD->(DbSkip())
	EndDo

	If nBlqTotal > 0
		// Verifica se deve atualizar o armazém do lote ou todos os armazéns
		If MV_PAR01 == 1
			cSeekSB2  := xFilial("SB2")+SB8->B8_PRODUTO+SB8->B8_LOCAL
			bBlockSB2 := {|| SB2->B2_FILIAL+SB2->B2_COD+SB2->B2_LOCAL == cSeekSB2}
		Else
			cSeekSB2  := xFilial("SB2")+SB8->B8_PRODUTO
			bBlockSB2 := {|| SB2->B2_FILIAL+SB2->B2_COD == cSeekSB2}
		EndIf

		// Atualiza o registro de saldo por lote
		If MV_PAR01 == 2
			nBaixaRes := nBlqTotal
			SB8->(DbSetOrder(5))
			SB8->(DbSeek(cSeekSB8 := xFilial("SB8")+SB8->B8_PRODUTO+SB8->B8_LOTECTL))
			While !SB8->(Eof()) .And. nBaixaRes > 0 .And. SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOTECTL == cSeekSB8
				// Verifica qual é menor, a quantidade de baixa ou o empenho do endereço
				nBaixaEmp := Min(nBaixaRes,SB8->B8_EMPENHO)
				RecLock("SB8",.F.)
				SB8->B8_EMPENHO -= nBaixaEmp
				SB8->B8_EMPENH2 := ConvUm(SB8->B8_PRODUTO,SB8->B8_EMPENHO,0,2)
				SB8->(MsUnlock())
				// Atualiza a quantidade restante
				nBaixaRes -= nBaixaEmp
				SB8->(DbSkip())
			EndDo
		Else
			RecLock("SB8",.F.)
			SB8->B8_EMPENHO -= nBlqTotal
			SB8->B8_EMPENH2 := ConvUm(SB8->B8_PRODUTO,SB8->B8_EMPENHO,0,2)
			SB8->(MsUnlock())
		EndIf

		nBaixaRes := nBlqTotal
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(cSeekSB2))
		While !SB2->(Eof()) .And. nBaixaRes > 0 .And. Eval(bBlockSB2)
			// Verifica qual é menor, a quantidade de baixa ou o empenho do endereço
			nBaixaEmp := Min(nBaixaRes,SB2->B2_QEMP)
			RecLock("SB2",.F.)
			SB2->B2_QEMP -= nBaixaEmp
			SB2->B2_QEMP2 := ConvUm(SB2->B2_COD,SB2->B2_QEMP,0,2)
			SB2->(MsUnlock())
			// Atualiza a quantidade restante
			nBaixaRes -= nBaixaEmp
			SB2->(DbSkip())
		EndDo
	EndIf

RestArea(aAreaSB8)
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
//-------------------------------------------------------------------
METHOD AfterTTS(oModel, cModelId) CLASS WMSModelEventWMSA535
Return

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pre validação do Model
//-------------------------------------------------------------------
METHOD ModelPreVld(oModel, cModelId) CLASS WMSModelEventWMSA535
Local lRet := .T.
Return lRet

//-------------------------------------------------------------------
// Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS WMSModelEventWMSA535
Local lRet := .T.
Return lRet
