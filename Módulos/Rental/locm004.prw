#Include "totvs.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "locm004.ch"

/*/{Protheus.doc} LOCM004.PRW
ITUP Business - TOTVS RENTAL
P.E. antes de qualquer atualizacao na exclusao da N.Fiscal de saída
Validar se exclusao será efetuada ou não.
Ponto de entrada versão antiga MS520VLD
@type function
@version 1
@Author Frank Zwarg Fuga
@since 2/23/2024
20/09/2023 - Novas regras para exclusão da remessa mesmo com notas mais atuais
/*/

Function LOCM004
	Local _aAreaSD2     := SD2->(GetArea())
	Local _aAreaSC6     := SC6->(GetArea())
	Local _aAreaSF2     := SF2->(GetArea())
	Local _aAreaFPZ     := FPZ->(GetArea())
	Local _aAreaFPY     := FPY->(GetArea())
	Local _lRet         := .T.
	Local cQry
	Local lContinua     := .T.
	Local aBindParam    := {}
	Local cPedido       := SC5->C5_NUM
	Local dEmissao      := SC5->C5_EMISSAO
	Local cProjeto

// Essa função é chamada na validção se uma nota pode ser deletada ou se um pedido pode ser deletado

	if IsInCallStack("A410DELETA") // Veio da deleção do pedido

		FPY->(dbSetOrder(1))
		IF FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))

			IF FPY->FPY_TIPFAT = "P" // É pedido de Faturamento Automatico ou de Medição
				// Nao permitir a exclusao do pedido de venda, se houver um faturamento mais atual do mesmo contrato
				// Passo 1 - Verificar no pedido que esta sendo excluido, qual é o contrato
				cProjeto := FPY->FPY_PROJET
				// Passo 2 - Verificar se há pedido de Faturamento Automatico ou de Medição posterior ao pedido que será deletado

				aBindParam := {}
				cQry := " SELECT FPY.R_E_C_N_O_ REG "
				cQry += "   FROM "+RetSqlName("FPY")+" FPY"
				cQry += " WHERE FPY.D_E_L_E_T_ = '' "
				cQry += "   AND FPY_FILIAL     = '"+xFilial("FPY")+"'"
				cQry += "   AND FPY.FPY_PROJET = ?"
				cQry += "   AND FPY.FPY_PEDVEN > ? "
				cQry += "   AND FPY.FPY_TIPFAT = 'P' " // Automatico ou Medição
				cQry += "   AND FPY.FPY_STATUS = '1' " // Pedido ativo

				Aadd(aBindParam, cProjeto)
				Aadd(aBindParam, cPedido )
				cQry := ChangeQuery(cQry)

				MPSysOpenQuery(cQry,"QRY",,,aBindParam)

				_lRet := QRY->(Eof()) // Se não achou pode deletar

				If !_lRet
					MsgAlert(STR0007,STR0004) //"Existe um pedido emitido para o orçamento com data superior ao que você está tentando excluir." //"Exclusão bloqueada." 
				EndIf
				*/
			endif
		endif

	else // Veio da deleção da Nota
		// Nao permitir a exclusao do documento de saida, se for de remessa e alguns dos itens já tiver sido
		// faturado quer seja por Faturamento automatico quer seja por medição
		// Passo 1 - Verificar na nota que esta sendo excluida se o pedido é de remessa
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE))
		While !SD2->(Eof()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) ==  xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE
			FPY->(dbSetOrder(1))
			If FPY->(dbSeek(xFilial("FPY")+SD2->D2_PEDIDO)) // Buscar Pedido
				if FPY->FPY_TIPFAT <> "R" // Não é remessa
					lContinua := .F. // Não COntinua a validação
				else
					lContinua := .T. // Continua a validação
				endif

				EXIT // Sai do Loop
			endif

			SD2->(dbSkip())

		enddo

		if lContinua // Continuar a validação
			// Passo 2 - Verificar se alguma AS do pedido de remessa já gerou cobrança
			cQry := ""
			aBindParam := {}
			cQry += " select  COUNT( FPZ_AS) NOTAS
			cQry += " from "+REtSqlName("SD2") +" SD2"
			cQry += " inner join "+RetSqlName("FPZ") +" FPZ"
			cQry += " on D2_FILIAL = FPZ_FILIAL"
			cQry += " and  FPZ_PEDVEN = D2_PEDIDO"
			cQry += " and  FPZ_ITEM   = D2_ITEMPV"
			cQry += " and  FPZ.D_E_L_E_T_ = ' '"
			cQry += " where D2_FILIAL = '"+xFilial("SD2")+"'"
			cQry += " and D2_DOC = ? "
			Aadd(aBindParam, SF2->F2_DOC)
			cQry += " and D2_SERIE = ? "
			Aadd(aBindParam, SF2->F2_SERIE)
			cQry += " and SD2.D_E_L_E_T_ = ' '"
			cQry += " and EXISTS ("
			cQry += "SELECT FPZ_AS"
			cQry += "   from "+RetSqlName("FPZ") +" FPZ2"
			cQry += "   inner join "+RetSqlName("FPY") +" FPY"
			cQry += "       on FPY_FILIAL = FPZ2.FPZ_FILIAL"
			cQry += "       and FPY_PEDVEN = FPZ2.FPZ_PEDVEN"
			cQry += "       and FPY_TIPFAT IN ('P', 'M')" // Se tiverem Faturamento ou medição
			cQry += "       and FPY.D_E_L_E_T_ = ' '"
			cQry += "   where FPZ2.FPZ_FILIAL  = FPZ.FPZ_FILIAL"
			cQry += "       and FPZ2.FPZ_AS = FPZ.FPZ_AS"
			cQry += "       and FPZ2.D_E_L_E_T_ = ' '  )"

			MPSysOpenQuery(cQry,"QRY",,,aBindParam)

			if QRY->NOTAS > 0 // Tem pelo menos uma AS com faturamento ou medicao
				_lRet := .F.
			endif

		endif

		If !_lRet
			MsgAlert(STR0006,STR0004) //"Exclusão bloqueada." //"Existe um Faturamento ou Medição para algum dos itens dessa nota de remessa que você está tentando excluir."
		EndIf

	endif

	RestArea(_aAreaSD2)
	RestArea(_aAreaSC6)
	RestArea(_aAreaSF2)
	RestArea(_aAreaFPZ)
	RestArea(_aAreaFPY)
Return _lRet

