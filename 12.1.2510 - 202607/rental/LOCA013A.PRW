#Include "TOTVS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} LOCA013A
Gera BEM (ST9) automaticamente para a linha de contrato (FPA) quando o produto
estiver mapeado no Cadastro de Bens Temporarios (FH3).
@type function
@version 25.10
@author Dennis Calabrez
@since 27/03/2026
@return logical, .T. se BEM gerado com sucesso
/*/
Function LOCA013A()
Local aArea         := FWGetArea()
Local aAreaSB1      := SB1->(GetArea())
Local aAreaFQ5      := FQ5->(GetArea())
Local cAliasFH3     := GetNextAlias()
Local cAliasStAti   := GetNextAlias()  // status inicial  (STAREN/STTCTR = "00")
Local cAliasStCtrat := GetNextAlias()  // status contrato (STAREN/STTCTR = "10")
Local cQuery        := ""
Local aBindParam    := {}
Local cCodBem       := ""
Local cNomeBem      := ""
Local cFamil        := ""
Local cModel        := ""
Local cFabric       := ""
Local cTurno        := ""
Local cCC           := ""
Local cStAtivo      := ""   // codigo do status ativo (STAREN/STTCTR = "00")
Local cStCtrat      := ""   // codigo do status em contrato (STAREN/STTCTR = "10")
Local lCriou        := .F.
Local oST9          := Nil  // objeto da classe MntBem para gravacao direta na ST9

    // Condicao de entrada: apenas Locacao sem BEM alocado
    If FPA->FPA_TIPOSE <> "L" .Or. !Empty(AllTrim(FPA->FPA_GRUA))
        SB1->(RestArea(aAreaSB1))
        FQ5->(RestArea(aAreaFQ5))
        FWRestArea(aArea)
        Return .F.
    EndIf

    // ----------------------------------------------------------------------------------
    // 1. Verifica se o produto existe no Cadastro de Bens Temporarios (ZBT)
    // ----------------------------------------------------------------------------------
    cQuery       := " SELECT FH3_FAMILI, FH3_MODELO, FH3_FABRIC, FH3_TURNO, FH3_CC "
    cQuery       += " FROM " + RetSqlName("FH3")
    cQuery       += " WHERE FH3_FILIAL = ? "
    cQuery       += " AND FH3_PROD = ? "
    cQuery       += " AND D_E_L_E_T_ = ' ' "
    aBindParam   := { xFilial("FH3"), (FPA->FPA_PRODUT) }
    cQuery       := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAliasFH3,,, aBindParam)

    If !(cAliasFH3)->(Eof())

        // Captura dados de mapeamento da FH3
        cFamil  := AllTrim((cAliasFH3)->FH3_FAMILI)
        cModel  := AllTrim((cAliasFH3)->FH3_MODELO)
        cFabric := AllTrim((cAliasFH3)->FH3_FABRIC)
        cTurno  := AllTrim((cAliasFH3)->FH3_TURNO)
        cCC     := AllTrim((cAliasFH3)->FH3_CC)

        // ----------------------------------------------------------------------------------
        // 2. Busca descricao do produto (SB1) para compor o Nome do BEM
        // ----------------------------------------------------------------------------------
        SB1->(DbSetOrder(1))
        SB1->(DbSeek(xFilial("SB1") + FPA->FPA_PRODUT))

        // ----------------------------------------------------------------------------------
        // 3. Monta Codigo do BEM: Contrato + Obra + Sequencial da linha FPA
        //    ATENCAO: verifique se TamSx3("T9_CODBEM")[1] comporta os 3 segmentos
        // ----------------------------------------------------------------------------------
        cCodBem := Left(  AllTrim(FPA->FPA_PROJET) + AllTrim(FPA->FPA_OBRA) + AllTrim(FPA->FPA_SEQGRU) ,;
                          TamSx3("T9_CODBEM")[1] )

        // ----------------------------------------------------------------------------------
        // 4. Monta Nome do BEM: Codigo do Cliente + Descricao do Item + Sequencial
        // ----------------------------------------------------------------------------------
        cNomeBem := Left(  AllTrim(FP0->FP0_CLI) + " " + AllTrim(SB1->B1_DESC) + " " + AllTrim(FPA->FPA_SEQGRU) ,;
                           TamSx3("T9_NOME")[1] )

        // ----------------------------------------------------------------------------------
        // 5. Busca codigo do status inicial (STAREN/STTCTR = "00" - ativo/disponivel)
        // ----------------------------------------------------------------------------------
        aBindParam := {}
        if "ORACLE" $ Upper(TCGetDB()) .or. file("\SYSTEM\LOCA013A.TXT")
            cQuery := " SELECT FQD_STATQY STCOD FROM " + RetSqlName("FQD")
            cQuery += " WHERE FQD_FILIAL = ? AND FQD_STAREN = '00' AND D_E_L_E_T_ = ' '"
            cQuery += " AND ROWNUM = 1"
        Else
            cQuery := " SELECT TOP 1 FQD_STATQY STCOD FROM " + RetSqlName("FQD")
            cQuery += " WHERE FQD_FILIAL = ? AND FQD_STAREN = '00' AND D_E_L_E_T_ = ' '"
        EndIf 
        AAdd(aBindParam, xFilial("FQD"))

        cQuery := ChangeQuery(cQuery)
        MPSysOpenQuery(cQuery, cAliasStAti,,, aBindParam)
        If !(cAliasStAti)->(Eof())
            cStAtivo := AllTrim((cAliasStAti)->STCOD)
        EndIf
        (cAliasStAti)->(DbCloseArea())

        // ----------------------------------------------------------------------------------
        // 6. Busca codigo do status em contrato (STAREN/STTCTR = "10")
        // ----------------------------------------------------------------------------------
        aBindParam := {}
        if "ORACLE" $ Upper(TCGetDB()) .or. file("\SYSTEM\LOCA013A.TXT")
            cQuery := " SELECT FQD_STATQY STCOD FROM " + RetSqlName("FQD")
            cQuery += " WHERE FQD_FILIAL = ? AND FQD_STAREN = '10' AND D_E_L_E_T_ = ' '"
            cQuery += " AND ROWNUM = 1"
        Else
            cQuery := " SELECT TOP 1 FQD_STATQY STCOD FROM " + RetSqlName("FQD")
            cQuery += " WHERE FQD_FILIAL = ? AND FQD_STAREN = '10' AND D_E_L_E_T_ = ' '"
        EndIf
        AAdd(aBindParam, xFilial("FQD"))

        cQuery := ChangeQuery(cQuery)
        MPSysOpenQuery(cQuery, cAliasStCtrat,,, aBindParam)
        If !(cAliasStCtrat)->(Eof())
            cStCtrat := AllTrim((cAliasStCtrat)->STCOD)
        EndIf
        (cAliasStCtrat)->(DbCloseArea())

        oST9 := MntBem():New

        // Operacao 3 = inclusao (equivalente a MODEL_OPERATION_INSERT)
        oST9:SetOperation(3)

        // Campos obrigatorios
        oST9:SetValue( "T9_CODBEM", cCodBem  )
        oST9:SetValue( "T9_NOME"  , cNomeBem )
        oST9:SetValue( "T9_CATBEM", "1"      )  // "1" = Bem padrao (roteamento MNTA080)

        // Status e situacao inicial
        If !Empty(cStAtivo)
            oST9:SetValue( "T9_STATUS", cStAtivo )
        EndIf
        oST9:SetValue( "T9_DTINCO", dDatabase )
        oST9:SetValue( "T9_SITBEM", "A"       )
        oST9:SetValue( "T9_SITMAN", "A"       )
        oST9:SetValue( "T9_DTINSTA", dDatabase )

        // Dados vindos do mapeamento FH3
        If !Empty(cFamil)
            oST9:SetValue( "T9_CODFA" , Left(cFamil , TamSx3("T9_CODFA")[1])  )
        EndIf
        If !Empty(cModel)
            oST9:SetValue( "T9_TIPMOD", Left(cModel , TamSx3("T9_TIPMOD")[1]) )
        EndIf
        If !Empty(cFabric)
            oST9:SetValue( "T9_FABRICA", Left(cFabric, TamSx3("T9_FABRICA")[1]) )
        EndIf
        If !Empty(cTurno)
            oST9:SetValue( "T9_CALENDA" , Left(cTurno , TamSx3("T9_CALENDA")[1])  )
        EndIf
        If !Empty(cCC)
            oST9:SetValue( "T9_CCUSTO"    , Left(cCC    , TamSx3("T9_CCUSTO")[1])     )
        EndIf
        If !Empty(cFamil)
            oST9:SetValue( "T9_CODFAMI"    , Left(cFamil    , TamSx3("T9_CODFAMI")[1])     )
        EndIf        

        // Executa validacoes internas da classe (mesmo fluxo que CommitInfo usa)
        oST9:Valid()
        oST9:ShowHelp()

        If oST9:IsValid()
            // Grava na ST9: Upsert faz INSERT em operacao de inclusao
            oST9:Upsert()
            // IsInsert() = .T. confirma que foi inclusao -> confirma reserva de numeracao
            If oST9:IsInsert()
                ConfirmSX8()
            EndIf
            lCriou := .T.
        EndIf

        oST9:Free()

        // ----------------------------------------------------------------------------------
        // 8. Vincula o BEM a linha de contrato (FPA)
        // ----------------------------------------------------------------------------------
        If lCriou

            RecLock("FPA", .F.)
            FPA->FPA_GRUA   := cCodBem
            FPA->FPA_DESGRU := Left(AllTrim(SB1->B1_DESC), TamSx3("FPA_DESGRU")[1])
            FPA->(MsUnlock())

            // ----------------------------------------------------------------------------------
            // 9. Vincula o BEM a AS gerada (FQ5_GUINDA) via indice 9 (FQ5_FILIAL + FQ5_AS)
            // ----------------------------------------------------------------------------------
            FQ5->(DbSetOrder(9))
            If FQ5->(DbSeek(xFilial("FQ5") + AllTrim(FPA->FPA_AS)))
                RecLock("FQ5", .F.)
                FQ5->FQ5_GUINDA := cCodBem
                FQ5->(MsUnlock())
            EndIf

            // ----------------------------------------------------------------------------------
            // 10. Altera status do BEM para "em contrato" (STAREN/STTCTR = "10") via LOCXITU21
            //     Padrao identico ao utilizado em LOCA013 e LOCA259X para transicao de status
            // ----------------------------------------------------------------------------------
            If !Empty(cStAtivo) .And. !Empty(cStCtrat)

                ST9->(DbSetOrder(1))
                If ST9->(DbSeek(xFilial("ST9") + cCodBem))
                    // LOCXITU21 registra a transicao de status (historico, log, movimentos)
                    // FPA deve estar posicionado na linha correta - ja esta neste ponto
                    LOCXITU21(cStAtivo, cStCtrat, FPA->FPA_PROJET, "", "", .F.)

                    // Atualiza T9_STATUS apos a chamada do LOCXITU21 (igual ao padrao LOCA259X)
                    RecLock("ST9", .F.)
                    ST9->T9_STATUS := cStCtrat
                    ST9->(MsUnlock())
                EndIf

            EndIf

        EndIf

    EndIf

    // Fecha alias temporarios que ainda estiverem abertos
    If SELECT(cAliasFH3) > 0
        (cAliasFH3)->(DbCloseArea())
    EndIf

    SB1->(RestArea(aAreaSB1))
    FQ5->(RestArea(aAreaFQ5))
    FWRestArea(aArea)

Return lCriou
