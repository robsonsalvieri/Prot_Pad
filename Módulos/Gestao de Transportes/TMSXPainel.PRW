#INCLUDE "Protheus.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSPnlT170(cTipo)
Função que retorna quantidade de registros para exibição nos paineis
Uso: TMSA170.PRW
@param: cTipo (Controle de execução da query)
@author Felipe Barbiere
@since 17/08/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Function TMSPnlT170( cTipo, cFilialOri, nDias )
Local cQuery	:= ""
Local cAliasQry	:= ""
Local dPeriodo  := 	FirstDate(dDataBase)
Local cRet      := "0"

Default cTipo       := "0"
Default cFilialOri  := ""
Default nDias       := 0

If nDias > 0
    dPeriodo := dPeriodo - nDias
EndIf

If cTipo == "1" //Lotes Pendentes de cálculo
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DTP_LOTNFC)  QTDELOT "
    cQuery += "FROM " + RetSqlName("DTP")
    cQuery += "WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
    cQuery += " AND DTP_DATLOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DTP_STATUS = '2' "
    If !Empty(cFilialOri)
        cQuery += " AND DTP_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDELOT, "@E 99999")) 
    EndIf    
    (cAliasQry)->(DbCloseArea())

ElseIf cTipo == "2" //Lotes bloqueados
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DTP_LOTNFC)  QTDELOT "
    cQuery += "FROM " + RetSqlName("DTP")
    cQuery += "WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
    cQuery += " AND DTP_DATLOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DTP_STATUS = '4' "
    If !Empty(cFilialOri)
        cQuery += " AND DTP_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDELOT, "@E 99999")) 
    EndIf    
    (cAliasQry)->(DbCloseArea())

ElseIf cTipo == "3" //Lotes pendentes de transmissão
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DT6_DOC) QTDEDOC "
    cQuery += "FROM " + RetSqlName("DTP") + " DTP "
    cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
    cQuery += "ON DTP.DTP_LOTNFC = DT6.DT6_LOTNFC AND " 
    cQuery += " DTP.DTP_FILORI = DT6.DT6_FILORI " 
    cQuery += "WHERE DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
    cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
    cQuery += " AND DTP.DTP_DATLOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DT6.DT6_SITCTE IN ('0', '1') "
    If !Empty(cFilialOri)
        cQuery += " AND DT6.DT6_FILORI = '" + cFilialOri + "'"
        cQuery += " AND DTP.DTP_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND DTP.D_E_L_E_T_ = '' "
    cQuery += " AND DT6.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDEDOC, "@E 99999"))  
    EndIf    
    (cAliasQry)->(DbCloseArea())

ElseIf cTipo == "4" //Documentos rejeitados
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DT6_DOC) QTDEDOC "
    cQuery += "FROM " + RetSqlName("DTP") + " DTP "
    cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
    cQuery += "ON DTP.DTP_LOTNFC = DT6.DT6_LOTNFC AND "
    cQuery += " DTP.DTP_FILORI = DT6.DT6_FILORI "
    cQuery += "WHERE DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
    cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
    cQuery += " AND DTP.DTP_DATLOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DT6_SITCTE IN ('5', '3') "
    If !Empty(cFilialOri)
        cQuery += " AND DT6.DT6_FILORI = '" + cFilialOri + "'"
        cQuery += " AND DTP.DTP_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND DTP.D_E_L_E_T_ = '' "
    cQuery += " AND DT6.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDEDOC, "@E 99999"))  
    EndIf    
    (cAliasQry)->(DbCloseArea())

ElseIf cTipo == "5" //Coletas em aberto
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DT5_NUMSOL) QTDEDOC "
    cQuery += "FROM " + RetSqlName("DT5") + " DT5 "
    cQuery += "WHERE DT5_FILIAL = '" + xFilial("DT5") + "'"
    cQuery += " AND DT5_DATSOL >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DT5_STATUS IN ('1', '2', '3', '5', '7') "
    If !Empty(cFilialOri)
        cQuery += " AND DT5_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDEDOC, "@E 99999"))  
    EndIf    
    (cAliasQry)->(DbCloseArea())

ElseIf cTipo == "6" //Cotações em aberto
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DT4_NUMCOT) QTDEDOC "
    cQuery += "FROM " + RetSqlName("DT4") + " DT4 "
    cQuery += "WHERE DT4_FILIAL = '" + xFilial("DT4") + "'"
    cQuery += " AND DT4_DATCOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DT4_STATUS IN ('1', '2', '3') "
    If !Empty(cFilialOri)
        cQuery += " AND DT4_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDEDOC, "@E 99999"))  
    EndIf    
    (cAliasQry)->(DbCloseArea())
ElseIf cTipo == "7" //Bloqueio crédito
    cAliasQry := GetNextAlias()
    cQuery := "SELECT COUNT(DT6_DOC) QTDEDOC "
    cQuery += "FROM " + RetSqlName("DTP") + " DTP "
    cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 "
    cQuery += "ON DTP.DTP_LOTNFC = DT6.DT6_LOTNFC AND " 
    cQuery += " DTP.DTP_FILORI = DT6.DT6_FILORI " 
    cQuery += "WHERE DTP.DTP_FILIAL = '" + xFilial("DTP") + "'"
    cQuery += " AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
    cQuery += " AND DTP.DTP_DATLOT >= '" + DToS(dPeriodo) + "'"
    cQuery += " AND DT6.DT6_SITCTE IN ('0', '1') "
    cQuery += " AND DT6.DT6_BLQDOC = '1' "
    If !Empty(cFilialOri)
        cQuery += " AND DT6.DT6_FILORI = '" + cFilialOri + "'"
        cQuery += " AND DTP.DTP_FILORI = '" + cFilialOri + "'"
    EndIf
    cQuery += " AND DTP.D_E_L_E_T_ = '' "
    cQuery += " AND DT6.D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

    If (cAliasQry)->(!Eof())
        cRet := AllTrim(TransForm((cAliasQry)->QTDEDOC, "@E 99999"))  
    EndIf    
    (cAliasQry)->(DbCloseArea())
EndIf

Return cRet

/*{Protheus.doc} TMSPnlT510
    Indicadores do Cockpit dos Clientes
    @type Function
    @author Valdemar Roberto Mognon
    @since 17/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA510()
    (examples)
    @see (links_or_references)
*/
Function TMSPnlT510(nFreteMes,nTotPeso,nTotVols,nTotPend,nPercServ)
Local aArea     := GetArea()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local dDatIni   := CToD("01/" + SubStr(DToC(dDataBase),4,7))
Local dDatFim   := dDataBase
Local nTotOco   := 0
Local nTotEnt   := 0

Default nFreteMes := 0
Default nTotPeso  := 0
Default nTotVols  := 0
Default nTotPend  := 0
Default nPercServ := 0

//-- Total de Peso e de Volumes
cQuery := "SELECT SUM(DT6_VALTOT) TOTFRETE, SUM(DT6_PESO) TOTPESO, SUM(DT6_VOLORI) TOTVOLS "

cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "

cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6_CLIDEV = '" + SA1->A1_COD + "' "
cQuery += "   AND DT6_LOJDEV = '" + SA1->A1_LOJA + "' "
cquery += "   AND DT6_DATEMI BETWEEN '" + DToS(dDatIni) + "' AND '" + DTos(dDatFim) + "' "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->(!Eof())
    nFreteMes := (cAliasQry)->TOTFRETE
	nTotPeso  := (cAliasQry)->TOTPESO
	nTotVols  := (cAliasQry)->TOTVOLS
EndIf
(cAliasQry)->(DbCloseArea())

//-- Total de Pendências
cQuery := "SELECT COUNT(DUU_DOC) TOTPEND "

cQuery += "  FROM " + RetSqlName("DUU") + " DUU "

cQuery += " WHERE DUU_FILIAL = '" + xFilial("DUU") + "' "
cQuery += "   AND DUU_CODCLI = '" + SA1->A1_COD + "' "
cQuery += "   AND DUU_LOJCLI = '" + SA1->A1_LOJA + "' "
cquery += "   AND DUU_DATPND BETWEEN '" + DToS(dDatIni) + "' AND '" + DTos(dDatFim) + "' "
cQuery += "   AND DUU.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

If (cAliasQry)->(!Eof())
	nTotPend := (cAliasQry)->TOTPEND
EndIf
(cAliasQry)->(DbCloseArea())

//-- % Nível de Serviço
cQuery := "SELECT 0 TOTOCO,COUNT(DUA_DOC) TOTENT "

cQuery += "  FROM " + RetSqlName("DUA") + " DUA "

cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6_FILDOC = DUA_FILDOC "
cQuery += "   AND DT6_DOC    = DUA_DOC "
cQuery += "   AND DT6_SERIE  = DUA_SERIE "
cQuery += "   AND DT6_CLIDEV = '" + SA1->A1_COD + "' "
cQuery += "   AND DT6_LOJDEV = '" + SA1->A1_LOJA + "' "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

cQuery += "  JOIN " + RetSqlName("DT2") + " DT2 "
cQuery += "    ON DT2_FILIAL = '" + xFilial("DT2") + "' "
cQuery += "   AND DT2_CODOCO = DUA_CODOCO "
cQuery += "   AND DT2_TIPOCO = '" + StrZero(1,Len(DT2->DT2_TIPOCO)) + "' "
cQuery += "   AND DT2.D_E_L_E_T_ = ' '"

cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
cquery += "   AND DUA_DATOCO BETWEEN '" + DToS(dDatIni) + "' AND '" + DTos(dDatFim) + "' "
cQuery += "   AND DUA.D_E_L_E_T_ = ' '"

cQuery += " UNION ALL "

cQuery += "SELECT COUNT(DUA_DOC) TOTOCO,0 TOTENT "

cQuery += "  FROM " + RetSqlName("DUA") + " DUA "

cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6_FILDOC = DUA_FILDOC "
cQuery += "   AND DT6_DOC    = DUA_DOC "
cQuery += "   AND DT6_SERIE  = DUA_SERIE "
cQuery += "   AND DT6_CLIDEV = '" + SA1->A1_COD + "' "
cQuery += "   AND DT6_LOJDEV = '" + SA1->A1_LOJA + "' "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

cQuery += " WHERE DUA_FILIAL = '" + xFilial("DUA") + "' "
cquery += "   AND DUA_DATOCO BETWEEN '" + DToS(dDatIni) + "' AND '" + DTos(dDatFim) + "' "
cQuery += "   AND DUA.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

While (cAliasQry)->(!Eof())
	nTotOco += (cAliasQry)->TOTOCO
	nTotEnt += (cAliasQry)->TOTENT
	(cAliasQry)->(DbSkip())
EndDo
nPercServ := (nTotEnt * 100) / nTotOco
(cAliasQry)->(DbCloseArea())

RestArea(aArea)
FwFreeArray(aArea)

Return
