#INCLUDE "TOTVS.CH"
#INCLUDE "AGDX020.CH"

/*/{Protheus.doc} AGDX020
Faz a validação do lote do produto.
@type function
@version 12
@author jc.maldonado
@since 04/04/2025
@param cCodPro, character, codigo do produto
@param cLocal, character, local
@param cLoteCtl, character, lote
@param cSubLote, character, subLote
@param lHelp, logical, ativa/desativa a mensagem de ajuda
@param lBaixaEmp, logical, considera empenho
@param lConsClas, logical, considera saldo a classificar
@param lSaldo, logical, considera somente valor B8_SALDO 
@return logical, resultado da validacao
/*/
Function AGDX020(cCodPro, cLocal, cLoteCtl, cSubLote, lHelp, lBaixaEmp, lConsClas, lSaldo)
	Local aArea    := FWgetArea()
	Local lLOTVENC := SuperGetMV("MV_LOTVENC") == "S" // Parametro que define a permissão para utilizar lotes vencidos
	Local cFilSB8  := FWxFilial("SB8")
	Local nSaldo

	Default cSubLote  := ""
	Default lHelp     := .F.
	Default lBaixaEmp := .F.
	Default lConsClas := .F.
	Default lSaldo    := .T.

	If Empty(cLocal)
		If lHelp
			AGDHELP(STR0001, STR0002, STR0003) // "AJUDA", "Armazem inválido.", "Informe o Armazem do produto."
		EndIf
		FWrestArea(aArea)
		Return .F.
	EndIf

	DBSelectArea("SB8")
	SB8->(DBsetOrder(retOrdem("SB8", "B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)")))
	SB8->(DbGoTop())
	If ! SB8->(dbSeek(cFilSB8 + cCodPro + cLocal + cLoteCtl + cSubLote))
		if lHelp
			AGDHELP(STR0001, STR0006 + CRLF + cLoteCtl , STR0007) //"AJUDA", "Lote inválido!", "Informe um lote válido!"
		EndIf
		FWrestArea(aArea)
		Return .F.
	EndIf

	If ! lLOTVENC .And. ! isLotDTVld(cCodPro, cLocal, cLoteCtl)
		if lHelp
			AGDHELP(STR0001, STR0004 + CRLF + cLoteCtl, STR0005) // "AJUDA, "Lote encontra-se vencido.", "Informe um lote que esteja com a data de validade vigente."
		EndIf
		FWrestArea(aArea)
		Return .F.
	EndIf

	DbSelectArea("SB8")
	nSaldo := SaldoLote(cCodPro, cLocal, cLoteCtl, cSubLote, lBaixaEmp, lLOTVENC, lConsClas, DDATABASE, "", lSaldo)
	If nSaldo <= 0
		if lHelp
			AGDHELP(STR0001, STR0008 + CRLF + cLoteCtl, STR0009) // "AJUDA, "Lote não possui saldo disponível.", "Informe um lote que tenha saldo disponível."
		EndIf
		FWrestArea(aArea)
		Return .F.
	EndIf

	FWrestArea(aArea)
Return .T.

/*/{Protheus.doc} isLotDTVld
Verifica se o LoteCTl não está vencido
@type function
@version 12
@author jc.maldonado
@since 07/04/2025
@param cCodPro, character, codigo do produto
@param cLocal, character, armazem do produto
@param cLoteCtl, character, lote do produto
@return logical, resultado da verificacao
/*/
Static Function isLotDTVld(cCodPro, cLocal, cLoteCtl)
	Local cQuery
	Local aParQry := {}
	Local cAlias
	Local lValido

	cQuery := " SELECT"
	cQuery += "     1"
	cQuery += " FROM"
	cQuery += "     " + retSQLName("SB8")
	cQuery += " WHERE
	cQuery += "     B8_FILIAL = ?"      ; aAdd(aParQry, FWxFilial("SB8"))
	cQuery += "     AND B8_PRODUTO = ?" ; aAdd(aParQry, cCodPro)
	cQuery += "     AND B8_LOCAL = ?"   ; aAdd(aParQry, cLocal)
	cQuery += "     AND B8_LOTECTL = ?" ; aAdd(aParQry, cLoteCtl)
	cQuery += "     AND B8_DTVALID > ?" ; aAdd(aParQry, DtoS(DDATABASE))
	cQuery += "     AND D_E_L_E_T_ = ''"
	cQuery := changeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cQuery, aParQry), cAlias, .F., .T.)

	lValido := (cAlias)->(! EOF())

	(cAlias)->(DbCloseArea())
Return lValido
