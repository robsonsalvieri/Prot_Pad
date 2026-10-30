#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} GFEFIX36
Rotina de FIX para deleção de rateios de frete (GWM) e
movimentos contábeis (GWA) órfãos sem correspondência
na tabela de cálculos de frete (GWF).

@type   Function
@author Guilherme A. Metzger
@since  07/08/2026
/*/
//---------------------------------------------------------------------
Function GFEFIX36()
Local aSay    := {}
Local aButton := {}
Local nOpcao  := 0
Local lSimula := .T.

    AAdd(aSay, "Esta rotina irá identificar e deletar os registros órfãos da tabela GWM (Rateio do Frete) e")
    AAdd(aSay, "GWA (Movimentos Contábeis), cujo Tipo de Documento seja 1 (Cálculo de Frete) e")
    AAdd(aSay, "não possuam correspondência na tabela GWF (Cálculos de Frete).")
    AAdd(aSay, "")
    AAdd(aSay, "Para executar em MODO SIMULAÇÃO clique em OK")
    AAdd(aSay, "Para EFETIVAR A DELEÇÃO clique em Excluir")

    AAdd(aButton, { 1, .T., {|| nOpcao := 1, FechaBatch() } }) // Simulação
    AAdd(aButton, { 3, .T., {|| nOpcao := 2, FechaBatch() } }) // Efetivação
    AAdd(aButton, { 2, .T., {|| nOpcao := 0, FechaBatch() } }) // Cancelar

    FormBatch("FIX - Limpeza de Rateios de Frete e Movimentos Contábeis Órfãos", aSay, aButton)

    If nOpcao == 1
        lSimula := .T.
        Processa({|| ProcLimpeza(lSimula) }, "Processando Simulação...")
    ElseIf nOpcao == 2
        If MsgYesNo("ATENÇÃO: Os registros órfãos da GWM e da GWA serão DELETADOS." + CRLF + ;
                    "Confirma que foi realizado backup das tabelas GWM e GWA?", "Confirmação de Deleção")
            lSimula := .F.
            Processa({|| ProcLimpeza(lSimula) }, "Executando Deleção dos Registros...")
        EndIf
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcLimpeza
Realiza o processamento

@type   Function
@author Guilherme A. Metzger
@since  07/08/2026
/*/
//---------------------------------------------------------------------
Static Function ProcLimpeza(lSimula)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local oExec     := Nil
Local nIterator := 1
Local cAliasGWM := ""
Local cAliasGWA := ""
Local oVwProc   := GFEViewProc():New()
Local nCont     := 0

    // Query para busca de registros na GWM (Tipo 1) sem correspondência na GWF
    cQuery := "SELECT GWM.R_E_C_N_O_ AS RECNOGWM,"
    cQuery +=       " GWM.GWM_FILIAL,"
    cQuery +=       " GWM.GWM_NRDOC"
    cQuery +=  " FROM ? GWM"
    cQuery += " WHERE GWM.GWM_FILIAL = ?"
    cQuery +=   " AND GWM.GWM_TPDOC  = ?"
    cQuery +=   " AND GWM.D_E_L_E_T_ = ?"
    cQuery +=   " AND NOT EXISTS (SELECT 1 "
    cQuery +=                     " FROM ? GWF"
    cQuery +=                    " WHERE GWF.GWF_FILIAL = GWM.GWM_FILIAL"
    cQuery +=                      " AND GWF.GWF_NRCALC = GWM.GWM_NRDOC"
    cQuery +=                      " AND GWF.D_E_L_E_T_ = GWM.D_E_L_E_T_)"

    oExec := FWExecStatement():New()
    oExec:SetQuery(ChangeQuery(cQuery))

    oExec:setUnSafe(nIterator++,RetSqlName("GWM"))
    oExec:setString(nIterator++,xFilial("GWM"))
    oExec:setString(nIterator++,"1")
    oExec:setString(nIterator++," ")

    oExec:setUnSafe(nIterator++,RetSqlName("GWF"))

    cAliasGWM := oExec:OpenAlias()

    ProcRegua(0)

    oVwProc:Add("=== LOG DE EXECUÇÃO FIX GWM e GWA (" + Iif(lSimula, "SIMULAÇÃO", "EFETIVAÇÃO") + ") ===" + CRLF + CRLF)

    If (cAliasGWM)->(Eof())
        oVwProc:Add("Nenhum registro órfão encontrado na GWM.")
    EndIf

    Begin Transaction

        While !(cAliasGWM)->(Eof())

            nCont++

            IncProc("Analisando registro: " + cValToChar(nCont))

            oVwProc:Add("Filial: " + (cAliasGWM)->GWM_FILIAL + " | Cálculo: " + (cAliasGWM)->GWM_NRDOC + " | Recno: " + cValToChar((cAliasGWM)->RECNOGWM) + CRLF)

            If !lSimula
                GWM->(DbGoTo((cAliasGWM)->RECNOGWM))
                RecLock("GWM", .F.)
                GWM->(DbDelete())
                GWM->(MsUnlock())
                oVwProc:Add("Registro deletado com sucesso." + CRLF)
            EndIf

            (cAliasGWM)->(DbSkip())

        EndDo

    End Transaction

    (cAliasGWM)->(DbCloseArea())

    oVwProc:Add(CRLF + "Total de registros órfãos identificados na GWM: " + cValToChar(nCont) + CRLF + CRLF)

    oExec:Destroy()
    oExec := Nil
    nIterator := 1
    nCont := 0

    // Query para busca de registros na GWA (Tipo 1) sem correspondência na GWF
    cQuery := "SELECT GWA.R_E_C_N_O_ AS RECNOGWA,"
    cQuery +=       " GWA.GWA_FILIAL,"
    cQuery +=       " GWA.GWA_NRDOC"
    cQuery +=  " FROM ? GWA"
    cQuery += " WHERE GWA.GWA_FILIAL = ?"
    cQuery +=   " AND GWA.GWA_TPDOC  = ?"
    cQuery +=   " AND GWA.D_E_L_E_T_ = ?"
    cQuery +=   " AND NOT EXISTS (SELECT 1 "
    cQuery +=                     " FROM ? GWF"
    cQuery +=                    " WHERE GWF.GWF_FILIAL = GWA.GWA_FILIAL"
    cQuery +=                      " AND GWF.GWF_NRCALC = GWA.GWA_NRDOC"
    cQuery +=                      " AND GWF.D_E_L_E_T_ = GWA.D_E_L_E_T_)"

    oExec := FWExecStatement():New()
    oExec:SetQuery(ChangeQuery(cQuery))

    oExec:setUnSafe(nIterator++,RetSqlName("GWA"))
    oExec:setString(nIterator++,xFilial("GWA"))
    oExec:setString(nIterator++,"1")
    oExec:setString(nIterator++," ")

    oExec:setUnSafe(nIterator++,RetSqlName("GWF"))

    cAliasGWA := oExec:OpenAlias()

    If (cAliasGWA)->(Eof())
        oVwProc:Add("Nenhum registro órfão encontrado na GWA.")
    EndIf

    Begin Transaction

        While !(cAliasGWA)->(Eof())

            nCont++

            IncProc("Analisando registro: " + cValToChar(nCont))

            oVwProc:Add("Filial: " + (cAliasGWA)->GWA_FILIAL + " | Cálculo: " + (cAliasGWA)->GWA_NRDOC + " | Recno: " + cValToChar((cAliasGWA)->RECNOGWA) + CRLF)

            If !lSimula
                GWA->(DbGoTo((cAliasGWA)->RECNOGWA))
                RecLock("GWA", .F.)
                GWA->(DbDelete())
                GWA->(MsUnlock())
                oVwProc:Add("Registro deletado com sucesso." + CRLF)
            EndIf

            (cAliasGWA)->(DbSkip())

        EndDo

    End Transaction

    (cAliasGWA)->(DbCloseArea())

    oVwProc:Add(CRLF + "Total de registros órfãos identificados na GWA: " + cValToChar(nCont) + CRLF + CRLF)

    oExec:Destroy()
    oExec := Nil

    // Exibe resultado em tela / arquivo de log
    oVwProc:Show(,,,"")

RestArea(aAreaAnt)
Return
