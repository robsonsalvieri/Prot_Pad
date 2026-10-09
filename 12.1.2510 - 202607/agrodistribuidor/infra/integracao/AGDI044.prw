#INCLUDE "TOTVS.CH"
#DEFINE BLOQUEIO_RECEITA totvs.protheus.agrobusiness.agd.SalesLockService
#DEFINE ITEM_SOLICITACAO_RECEITA totvs.protheus.agrobusiness.agd.RequestRecipeItemRepository


/*/{Protheus.doc} AGDI044
Recebe a chave de uma SC9 após liberação de estoque, busca NEU correspondente de origem e atualiza a NEUs
@type method
@version P12
@author carlos.augusto
@since 17/03/2026
/*/
Function AGDI044(cFilialSC9, cPedidoSC9, cItemSC9, cSeqLibSC9, cProdSC9)
	Local lSIGAAGD    := SuperGetMV("MV_SIGAAGD", .F., .F.)
	Local aAreaSC9    := SC9->(GetArea())
	Local cNumSolic   := ""
	Local cMapa       := ""
	Local cCodRec     := ""
	Local cSeqRec     := ""
	Local cMapaRec    := ""
	Local oSrvBlqRec  := Nil
	Local oRepItemSol := Nil

	If !lSIGAAGD .Or. !TableInDic('NEU') .Or. !TableInDic('NET') .Or. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_MAPA"))) <= 0
		Return
	EndIf

	/* Produto deve emitir receita */
	DbSelectArea('NCR')
	NCR->(dbSetOrder(1)) // NCR_FILIAL+NCR_PROD
	If NCR->(dbSeek(FwxFilial("NCR") + cProdSC9))
		If NCR->NCR_EMREC != '1'
			Return
		EndIf
	Else
		Return
	EndIf

	/* Retorna item NEU / espelho da SC9 ativo no momento */
	oRepItemSol := ITEM_SOLICITACAO_RECEITA():new()
	nRecnoNEU   := oRepItemSol:getItemSolicitacaoAtivaByChave(cFilialSC9, cPedidoSC9, cItemSC9, cSeqLibSC9, cProdSC9)

	If nRecnoNEU > 0
		NEU->(DbGoTo(nRecnoNEU))
		cNumSolic := NEU->NEU_CODIGO
		cCodRec   := NEU->NEU_CODREC
		cSeqRec   := NEU->NEU_SEQREC
		cMapaRec  := NEU->NEU_MAPA

		/* O Seek e While são realizados no item da SC9, pois a liberação de estoque pode gerar mais de uma SC9 para a mesma SC9 que foi liberada estoque. 
		Além da possibilidade de esta SC9 em que está sendo realizada a liberação de estoque ser deletada e gerada uma nova com C9_SEQUEN disponível */
		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(xFilial("SC9") + cPedidoSC9 + cItemSC9))
			While SC9->(!EoF()) .And. FwxFilial('SC9') == SC9->C9_FILIAL .And. SC9->C9_PEDIDO == cPedidoSC9 .And. SC9->C9_ITEM == cItemSC9

				//Descartar SC9 ja faturada. 
				If !Empty(SC9->C9_NFISCAL)
					SC9->(DbSkip())
					Loop
				EndIf
				
				oRepItemSol := Nil
				oRepItemSol := ITEM_SOLICITACAO_RECEITA():new()
				nRecnoNEU   := oRepItemSol:getItemSolicitacaoAtivaByChave(cFilialSC9, cPedidoSC9, cItemSC9, SC9->C9_SEQUEN, SC9->C9_PRODUTO)
				If nRecnoNEU > 0
					NEU->(DbGoTo(nRecnoNEU))
					/* Esta sendo utilizada em outra solicitação, não criar/atualizar esta NEU */
					If NEU->NEU_CODIGO != cNumSolic
						SC9->(DbSkip())
						Loop
					Else
						//Se esta SC9 já existe na NEU, atualizar NEU_QTDVEN da NEU para esta chave da SC9. O código da solicitação é extremamente importante para realizar no registro correto.
						//Se encontrou é porque a SC9 em que foi realizada a liberação não foi deletada. Pode ter diluída a quantidade em outras SC9, por isso a alteração da quantidade na NEU.
						RecLock("NEU",.F.)
							NEU->NEU_QTDVEN := SC9->C9_QTDLIB
						NEU->(MsUnLock())
					EndIf
				Else
					/* Caso não encontre, pode ser uma SC9 nova gerada pelo motivo de quebra quantidades (LOTES-ENDEREÇOS) 
					ou por ter deletado a SC9 original e gerou uma com C9_SEQUEN superior. */
					NCR->(dbSetOrder(1)) 
					If NCR->(dbSeek(xFilial('NCR') + SC9->C9_PRODUTO))
						cMapa := NCR->NCR_MAPA
					EndIf

					RecLock("NEU",.T.)
						NEU->NEU_FILIAL := FWxFilial("NEU")
						NEU->NEU_CODIGO := cNumSolic
						NEU->NEU_ITEM   := AGDI44Item(cNumSolic, SC9->C9_PEDIDO)
						NEU->NEU_NUMPED := SC9->C9_PEDIDO
						NEU->NEU_PRODUT := SC9->C9_PRODUTO
						NEU->NEU_MAPA   := cMapa
						NEU->NEU_ITEMPE := SC9->C9_ITEM
						NEU->NEU_SEQLIB := SC9->C9_SEQUEN
						NEU->NEU_UM		:= Posicione("SB1", 1, xFilial("SB1") + SC9->C9_PRODUTO, "B1_UM")
						NEU->NEU_QTDVEN := SC9->C9_QTDLIB
						NEU->NEU_CODREC := cCodRec
						NEU->NEU_SEQREC := cSeqRec
					NEU->(MsUnLock())
				EndIf

				oSrvBlqRec := BLOQUEIO_RECEITA():new()
				oSrvBlqRec:gerarBloqueioReceita(SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRODUTO)
				FreeObj(oSrvBlqRec)

				SC9->(DbSkip())
			EndDo
		EndIf

		//Se não existe mais essa SC9 de sequencia de liberação C9_SEQUEN, apagamos o registro espelho na NEU 
		SC9->(DbSetOrder(1))
		If !SC9->(DbSeek(cFilialSC9 + cPedidoSC9 + cItemSC9 + cSeqLibSC9))
			NEU->(DbSetOrder(4))
			If NEU->(DbSeek(xFilial("NEU") + cNumSolic + cPedidoSC9 + cItemSC9 + cSeqLibSC9))
				RecLock("NEU",.F.)
					NEU->(dbDelete())
				NEU->(MsUnLock())
			EndIf
		EndIf
	EndIf
	FreeObj(oRepItemSol)
	RestArea(aAreaSC9)
Return 


/*/{Protheus.doc} AGDI44Item
Gera nova sequencia (NEU_ITEM) para a NEU
@type method
@version P12
@author carlos.augusto
@since 17/03/2026
/*/
Static Function AGDI44Item(cCodNET,cNumPed)
	Local cNewSeq    := STRZERO(1,TAMSX3("NEU_ITEM")[1])
    Local oFwPrepNEU As Object
	Local cAliasNEU  := GetNextAlias()
	Local cQuery     := ""

    cQuery := " SELECT MAX(NEU.NEU_ITEM) MAXSEQINT "
    cQuery += 	" FROM " + RetSqlName("NEU") + " NEU "
	cQuery += 	  " WHERE NEU.NEU_FILIAL = ? "
	cQuery += 		" AND NEU.NEU_CODIGO = ? "
	cQuery += 		" AND NEU.NEU_NUMPED = ? "
	cQuery += 		" AND NEU.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    oFwPrepNEU := FWPreparedStatement():New()
    oFwPrepNEU:SetQuery(cQuery)
    oFwPrepNEU:SetString(1, xFilial("NEU"))
	oFwPrepNEU:SetString(2, cCodNET)
	oFwPrepNEU:SetString(3, cNumPed)
    
    cQuery := oFwPrepNEU:GetFixQuery()
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNEU, .F., .T.)

	cNewSeq := Iif(!Empty((cAliasNEU)->MAXSEQINT), Soma1((cAliasNEU)->MAXSEQINT ), cNewSeq)

	(cAliasNEU)->(DbCloseArea())
	FwFreeObj(oFwPrepNEU)   

Return cNewSeq
