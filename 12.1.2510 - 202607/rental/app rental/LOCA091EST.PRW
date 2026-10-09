#Include "loca091.ch"
#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} LOCA091EST
Estorno de Checklist
- Tipo 2: Reverte status do bem, exclui FQ4, limpa FPA_DTSCRT e cancela FQC
- Tipo diferente de 2: Apenas cancela FQC
@type function
@author Claude
@since 17/02/2026
/*/
Function LOCA091EST() 
Local aAreaFQC := FQC->(GetArea())
Local aAreaST9 := ST9->(GetArea())
Local aAreaFQ4 := FQ4->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local cCodBem  := FQC->FQC_CODBEM
Local cCodChe  := FQC->FQC_CODCHE
Local cCodFor  := Alltrim(FQC->FQC_CODFOR)
Local cStatus  := Alltrim(FQC->FQC_STATUS)
Local cProjeto := FQC->FQC_PROJET
Local cObra    := FQC->FQC_OBRA
//Local cQuery   := ""
//Local aBindParam := {}
//Local lFQ4Check := .F.
//Local cStsAnt  := ""
Local lOk      := .T.
Local cErro    := ""

    // Valida se o checklist pode ser estornado
    If Upper(cStatus) == "CANCELADO"
        MsgAlert(STR0010, STR0009) //"Atencao" //"Este checklist ja esta cancelado."
        RestArea(aAreaFPA)
        RestArea(aAreaFQ4)
        RestArea(aAreaST9)
        RestArea(aAreaFQC)
        Return
    EndIf

    If !MsgYesNo(STR0012 + Alltrim(cCodChe) + "?", STR0011) //"Estorno de Checklist" //"Deseja estornar o checklist "
        RestArea(aAreaFPA)
        RestArea(aAreaFQ4)
        RestArea(aAreaST9)
        RestArea(aAreaFQC)
        Return
    EndIf

    If cCodFor == "2"
        // Checklist Tipo 2 - Estorno completo
        lOk := LOCA091ET2(cCodBem, cCodChe, cProjeto, cObra, @cErro)
    Else
        // Checklist Tipo diferente de 2 - Apenas cancela
        lOk := LOCA091ETO(cCodChe, @cErro)
    EndIf

    If lOk
        MsgInfo(STR0013, STR0011) //"Estorno de Checklist" //"Checklist estornado com sucesso."
    EndIf

    RestArea(aAreaFPA)
    RestArea(aAreaFQ4)
    RestArea(aAreaST9)
    RestArea(aAreaFQC)

Return

/*/{Protheus.doc} LOCA091ET2
Estorno de checklist tipo 2
Reverte status do bem, exclui FQ4, limpa FPA_DTSCRT e cancela FQC
@Author: Alessandro Gois
@type function
@since 17/02/2026
/*/
Static Function LOCA091ET2(cCodBem, cCodChe, cProjeto, cObra, cErro)
Local cQuery    := ""
Local aBindParam := {}
Local lFQ4Check := .F.
Local cStsAnt   := ""
Local cDocChe   := SubStr(cCodChe, 2, 9)
Local lOk       := .T.

    // Passo 1: Localizar o ultimo registro do bem na FQ4
    LOCACLOSE("TRBFQ4E")
    cQuery := "SELECT FQ4.R_E_C_N_O_ REG, FQ4.FQ4_DOCUME, FQ4.FQ4_STSOLD, FQ4.FQ4_SEQ "
    cQuery += "FROM " + RetSqlName("FQ4") + " FQ4 "
    cQuery += "WHERE FQ4.D_E_L_E_T_ = ' ' "
    cQuery += "AND FQ4.FQ4_FILIAL = ? "
    cQuery += "AND FQ4.FQ4_CODBEM = ? "
    cQuery += "AND FQ4.FQ4_SEQ = (SELECT MAX(FQ4A.FQ4_SEQ) FROM " + RetSqlName("FQ4") + " FQ4A "
    cQuery += "WHERE FQ4A.D_E_L_E_T_ = ' ' "
    cQuery += "AND FQ4A.FQ4_FILIAL = FQ4.FQ4_FILIAL "
    cQuery += "AND FQ4A.FQ4_CODBEM = FQ4.FQ4_CODBEM) "
    cQuery := CHANGEQUERY(cQuery)
    aAdd(aBindParam, xFilial("FQ4"))
    aAdd(aBindParam, cCodBem)
    MPSysOpenQuery(cQuery, "TRBFQ4E",,, aBindParam)

    If TRBFQ4E->(Eof())
        LOCACLOSE("TRBFQ4E")
        // Sem registro na FQ4, apenas cancela o checklist (passo 5)
        lOk := LOCA091ETO(cCodChe, @cErro)
        Return lOk
    EndIf

    // Verifica se o ultimo registro FQ4 e oriundo deste checklist
    lFQ4Check := (Alltrim(TRBFQ4E->FQ4_DOCUME) == Alltrim(cDocChe))
    cStsAnt   := TRBFQ4E->FQ4_STSOLD

    If !lFQ4Check // ADVPR
        // Ultimo registro FQ4 nao e deste checklist - apenas cancela (passo 5)
        LOCACLOSE("TRBFQ4E")
        lOk := LOCA091ETO(cCodChe, @cErro)
        Return lOk
    EndIf

    // Estorno completo com transacao
    Begin Transaction

        // Passo 2: Reverter status do bem para o anterior
        ST9->(dbSetOrder(1))
        If ST9->(dbSeek(xFilial("ST9") + cCodBem))
            If ST9->(RecLock("ST9", .F.))
                ST9->T9_STATUS := cStsAnt
                ST9->(MsUnLock())
            EndIf
        Else
            cErro := STR0016 //"Bem nao localizado na ST9."
            lOk := .F.
            DisarmTransaction()
        EndIf

        // Passo 3: Excluir o registro da FQ4
        If lOk
            FQ4->(dbGoto(TRBFQ4E->REG))
            If FQ4->(RecLock("FQ4", .F.))
                FQ4->(dbDelete())
                FQ4->(MsUnLock())
            EndIf
        EndIf

        // Passo 4: Limpar FPA_DTSCRT da AS vinculada
        If lOk
            FPA->(dbSetOrder(1))
            If FPA->(dbSeek(xFilial("FPA") + cProjeto + cObra))
                If FPA->(RecLock("FPA", .F.))
                    FPA->FPA_DTSCRT := CtoD("")
                    FPA->(MsUnLock())
                EndIf
            EndIf
        EndIf

        // Passo 5: Atualizar FQC_STATUS para Cancelado
        If lOk
            FQC->(dbSetOrder(1))
            If FQC->(dbSeek(xFilial("FQC") + cCodChe))
                If FQC->(RecLock("FQC", .F.))
                    FQC->FQC_STATUS := "Cancelado"
                    FQC->(MsUnLock())
                EndIf
            Else
                cErro := STR0020 //"Checklist nao localizado na FQC."
                lOk := .F.
                DisarmTransaction()
            EndIf
        EndIf

    End Transaction

    LOCACLOSE("TRBFQ4E")

Return lOk

/*/{Protheus.doc} LOCA091ETO
Estorno de checklist tipo diferente de 2
Apenas atualiza FQC_STATUS para Cancelado
@author: Alessandro Gois
@type function
@since 17/02/2026
/*/
Static Function LOCA091ETO(cCodChe, cErro)
Local lOk := .T.

    FQC->(dbSetOrder(1))
    If FQC->(dbSeek(xFilial("FQC") + cCodChe))
        If FQC->(RecLock("FQC", .F.))
            FQC->FQC_STATUS := "Cancelado"
            FQC->(MsUnLock())
        EndIf
    EndIf

Return lOk
