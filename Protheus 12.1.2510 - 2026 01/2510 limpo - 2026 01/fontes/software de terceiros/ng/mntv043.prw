#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV043
Cálculo da variável CTMN - Custo total de manutenção em um período.

@param De_Data      , Date     , Data início para filtro na Query.
@param Ate_Data     , Date     , Ate data para filtro na Query.
@param [De_Bem]     , Caractere, Bem início para filtro na Query.
@param [Ate_Bem]    , Caractere, Bem fim para filtro na Query.
@param [De_Ccusto]  , Caractere, Centro de custo início para filtro na Query.
@param [Ate_Ccusto] , Caractere, Centro de custo fim para filtro na Query.
@param [De_Centra]  , Caractere, Centro de Trabalho início para filtro na Query.
@param [Ate_Centra] , Caractere, Centro de Trabalho final para filtro na Query.
@param [Tip_Ordem]  , Caractere, Tipo de ordem de servico (1=Corretiva; 2=Preventiva; 3=Ambas)

@author Wexlei Silveira
@since 23/07/2018
@version P12
@return nResult, Numérico, Soma do custo total
/*/
//------------------------------------------------------------------------------
Function MNTV043(De_Data, Ate_Data, De_Bem, Ate_Bem, De_Ccusto, Ate_Ccusto, De_Centra, Ate_Centra, Tip_Ordem)

	Local aArea     := GetArea()
	Local cAlias    := GetNextAlias()
	Local cQry      := ""
	Local cCodIndic := 'MNTV043'
	Local nCusto    := 0
	Local nResult   := 0

	Default De_Bem    := ""
	Default De_Ccusto := ""
	Default De_Centra := ""
	Default De_Data   := CToD("")
	Default Tip_Ordem := "3"

	cQry := "SELECT SUM(STJ.TJ_CUSTMDO) + SUM(STJ.TJ_CUSTMAT) + SUM(STJ.TJ_CUSTMAA) +"
	cQry += "       SUM(STJ.TJ_CUSTMAS) + SUM(STJ.TJ_CUSTTER) + SUM(STJ.TJ_CUSTFER) AS CUSTO_TOTAL"
	cQry += "  FROM " + RetSqlName("STJ") + " STJ"
	cQry += " WHERE STJ.TJ_FILIAL = " + ValToSQL(xFilial("STJ"))
	cQry += "   AND STJ.TJ_TERMINO = 'S'"
	cQry += "   AND STJ.TJ_SITUACA = 'L'"
	If Tip_Ordem == "1" .Or. Tip_Ordem == "2"
		cQry += "   AND STJ.TJ_PLANO " + IIf(Tip_Ordem == "1", "=", "<>") + " '000000'"
	EndIf
	cQry += "   AND STJ.TJ_CODBEM BETWEEN '" + De_Bem + "' AND '" + Ate_Bem + "'"
	cQry += "   AND STJ.TJ_CCUSTO BETWEEN '" + De_Ccusto + "' AND '" + Ate_Ccusto + "'"
	cQry += "   AND STJ.TJ_CENTRAB BETWEEN '" + De_Centra + "' AND '" + Ate_Centra + "'"
	cQry += "   AND STJ.TJ_DTMRINI >= " +  ValToSQL(De_Data)
	cQry += "   AND STJ.TJ_DTMRFIM <= " + ValToSQL(Ate_Data)
	If ExistBlock('MNTVFilter')

		cQry += (ExecBlock('MNTVFilter', .F., .F., {cCodIndic}))[1]

	EndIf
	cQry += "   AND STJ.D_E_L_E_T_ = ' '"
	cQry += " UNION ALL "
	// Soma o total de Custos das OS's de histórico
	cQry += "SELECT COALESCE(SUM(STS.TS_CUSTMDO) + SUM(STS.TS_CUSTMAT) + SUM(STS.TS_CUSTMAA) +"
	cQry += "       SUM(STS.TS_CUSTMAS) + SUM(STS.TS_CUSTTER) + SUM(STS.TS_CUSTFER), 0) AS CUSTO_TOTAL"
	cQry += "  FROM " + RetSqlName("STS") + " STS"
	cQry += " WHERE STS.TS_FILIAL = " + ValToSQL(xFilial("STS"))
	cQry += "   AND STS.TS_TERMINO = 'S'"
	cQry += "   AND STS.TS_SITUACA = 'L'"
	If Tip_Ordem == "1" .Or. Tip_Ordem == "2"
		cQry += "   AND STS.TS_PLANO " + IIf(Tip_Ordem == "1", "=", "<>") + " '000000'"
	EndIf
	cQry += "   AND STS.TS_CODBEM BETWEEN '" + De_Bem + "' AND '" + Ate_Bem + "'"
	cQry += "   AND STS.TS_CCUSTO BETWEEN '" + De_Ccusto + "' AND '" + Ate_Ccusto + "'"
	cQry += "   AND STS.TS_CENTRAB BETWEEN '" + De_Centra + "' AND '" + Ate_Centra + "'"
	cQry += "   AND STS.TS_DTMRINI >= " + ValToSQL(De_Data)
	cQry += "   AND STS.TS_DTMRFIM <= " + ValToSQL(Ate_Data)

	If ExistBlock('MNTVFilter')

		cQry += (ExecBlock('MNTVFilter', .F., .F., {cCodIndic}))[2]

	EndIf

	cQry += "   AND D_E_L_E_T_ = ' '"

	cQry := ChangeQuery(cQry)
	MPSysOpenQuery(cQry, cAlias)

	dbSelectArea(cAlias)
	dbGoTop()

	nCusto := (cAlias)->CUSTO_TOTAL
	(cAlias)->(DbSkip())
	nResult := (cAlias)->CUSTO_TOTAL + nCusto

	(cAlias)->(dbCloseArea())

	RestArea(aArea)

Return nResult
