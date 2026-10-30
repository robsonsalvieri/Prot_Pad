#INCLUDE "PROTHEUS.CH"

User Function UPDINSFER()

    Local aButtons  := {}
    Local aSays     := {}
    Local nOpcA     := 0
    Local nAltura   := 250 //Default 250
    Local nLargura  := 1090 //Default 520

    Private aLog        := {}
    Private aTitle      := {}
    Private cProcesso   := "     "
    Private cPeriodo    := "      "
    Private cMatricula  := "      "
    Private cFiltFil    := cFilAnt

    
    aAdd(aSays, OemToAnsi( "Objetivo: Ajustar INSS de Férias na Folha (acumulado SRD) de Jan/2026 em diante (MV_DINSSFM=N)." ))
    aAdd(aSays, OemToAnsi( "Cenário 1 (Folha)- ID 0065: Férias mês inteiro pagas no mês anterior." ))
    aAdd(aSays, OemToAnsi( "  -> Se ID 0065 Incid.IR=43, DIRF=B e verba subst. sem IR: Força Origem C e Dt.Pgto e Dt.Refer. da Folha." ))
    aAdd(aSays, OemToAnsi( "Cenário 2 (Folha)- ID 0168 Férias Partidas com pagamento no mês anterior." ))
    aAdd(aSays, OemToAnsi( "  -> Se ID 0168 Incid.IR=9, DIRF=B e verba subst. IR=43: Grava a verba subst. no campo RD_FERSUB." ))
    aAdd(aSays, OemToAnsi( "Cenário 3 (Rescisão)- ID 0065 Férias mês inteiro pagas no mês anter. e rescisão no mesmo mês. -> Se ID 0065 Incid.IR=43, DIRF=B e verba subst. sem IR: Grava na SRR a Dt.Pgto igual à Dt. de Homolog. " ))
    aAdd(aSays, OemToAnsi( "ATENÇÃO: Efetue o BACKUP da base de dados antes de iniciar o processamento!" ))

    aAdd(aButtons, { 14,.T.,{|| ShellExecute( "open", "https://tdn.totvs.com/pages/viewpage.action?pageId=1085099729", "", "", 1 ) } } )
    aAdd(aButtons, { 5, .T.,{|| fLoadParams() }} )
    AAdd(aButtons, { 1, .T.,{|| nOpcA := 1, Iif(gpconfOK(), FechaBatch(), nOpcA := 0 ) } } )
    aAdd(aButtons, { 2, .T.,{|| FechaBatch() }} )

    //Abre a tela de processamento
    FormBatch('Ajuste no cálculo de INSS de Férias na Folha', aSays, aButtons, , nAltura, nLargura)

    //Efetua o processamento de geração
    If Empty(cPeriodo) .And. nOpcA == 1
        MsgInfo("O preenchimento do período é obrigatório")
    ElseIf nOpcA == 1 .And. MsgNoYes("Foi efetuado o backup da base de dados?", "Atenção!") .And. MsgYesNo("Tem certeza que deseja continuar?", "Atenção!")
        Aadd( aTitle, OemToAnsi( "Funcionários processados: " ) )
        Aadd( aLog, {} )
        ProcGpe( {|lEnd| fProcessa()},"Aguarde","Processando...",.T. )
        If Empty(aLog[1])
            MsgInfo("Nenhum registro processado")
        EndIf
        fMakeLog(aLog,aTitle,,,"UPDINSFER",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
Return

/*/{Protheus.doc} fLoadParams
Função para preenchimento dos parametros de processamento (Filial/Processo/Periodo/Matricula)
/*/
Static Function fLoadParams()

    Local oDlg
    Local oFont
    Local oSize
    Local lRet  := .F.
    Local cDinssfm := Getmv("MV_DINSSFM")

    DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

    oSize := FwDefSize():New()
    oSize:AddObject( "CABECALHO",  160, 50, .F., .F. ) // NÃƒO dimensionavel

    oSize:lProp 	:= .F.            // Proporcional
    oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
    oSize:Process() 	              // Dispara os calculos

    Define MSDialog oDlg Title OemToAnsi("Parâmetros para processamento") FROM 0,0 TO 250,380 OF oMainWnd PIXEL
    	@ oSize:GetDimension("CABECALHO","LININI") +5 , oSize:GetDimension("CABECALHO","COLINI")+10;
    		TO oSize:GetDimension("CABECALHO","LINEND") +30, oSize:GetDimension("CABECALHO","COLEND")+10 LABEL OemToAnsi("Filtro") OF oDlg PIXEL

        @ oSize:GetDimension("CABECALHO","LININI") +18, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Filial: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +17, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oFilial VAR cFiltFil SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SM0' VALID Vazio() .Or. ExistCpo("SM0",cEmpAnt + cFiltFil)

        @ oSize:GetDimension("CABECALHO","LININI") +33, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Matrícula: ")    SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +32, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cMatricula SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SRA' VALID Vazio() .Or. ExistCpo("SRA")

        @ oSize:GetDimension("CABECALHO","LININI") +48, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Processo: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +47, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cProcesso SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'RCJ' VALID Vazio() .Or. ExistCpo("RCJ")

        @ oSize:GetDimension("CABECALHO","LININI") +63, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Período: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +62, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oPeriodo VAR cPeriodo SIZE 050,10 OF oDlg PIXEL PICTURE "@E 999999" F3 "RCH" VALID NaoVazio()

    	bSet15 := {|| lRet := .T., oDlg:End() }
    	bSet24 := {|| lRet := .F., oDlg:End() }

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

    If lRet
        //Validação do parametro MV_DINSSFM = 'N'
        If !(cDinssfm == "N")
            MsgInfo("Para atualizar os registros, o parâmetro MV_DINSSFM deve estar igual 'N'.")
            lRet := .F.
        EndIf
        //Valida de existe o campo RD_FERSUB na tabela SRD
        DbSelectArea("SRD")
        If !(SRD->(FieldPos("RD_FERSUB")) > 0) 
            MsgInfo("O campo RD_FERSUB não existe na tabela SRD. Favor atualizar o sistema para a versão mais recente.")
            lRet := .F.    
        EndIf

        If Empty(cPeriodo)
            MsgInfo("O preenchimento do período é obrigatório.")
            lRet := .F.
        EndIf

        If !Empty(cPeriodo) .And. cPeriodo < '202601'
            MsgInfo("O campo deve ser preenchido com o período a partir de 202601.")
            lRet := .F.
        EndIf

        If lRet .and. Empty(cFiltFil)
           lRet := MsgYesNo( "Filial não foi preenchida. Confirma o processamento para todas as filiais? " )
        EndIf 

        If lRet .and. Empty(cProcesso)
            lRet := MsgYesNo( "Processo não foi preenchido. Confirma o processamento para todos os processos? " )
        EndIf   

        If lRet .and. Empty(cMatricula)
            lRet := MsgYesNo( "Matrícula não foi preenchida. Confirma o processamento para todas as matrículas? " )
        EndIf   

    EndIf

Return lRet

/*/{Protheus.doc} fProcessa
Função que efetua os ajustes na base SRD e SRR
/*/
Static Function fProcessa()

    Local cAliasQry := GetNextAlias()
    Local cAliasSRR := GetNextAlias()
    Local cAliasRD2 := GetNextAlias()
    Local cAliasVal := GetNextAlias()
    Local cDtRef    := ""
    Local cDtPagto  := ""
    Local cQuery    := ""
    Local cWhereRD  := ""
    Local cWhereRR  := ""
    Local cWhereRD2 := ""
    Local cJoinRDRV := "%" + FWJoinFilial("SRD", "SRV") + "%"
    Local cJoinRDRG := "%" + FWJoinFilial("SRD", "SRG") + "%"
    Local cJoinRRRV := "%" + FWJoinFilial("SRR", "SRV") + "%"
    Local cJoinRRRG := "%" + FWJoinFilial("SRR", "SRG") + "%"
    Local cJoinRDRH := "%" + FWJoinFilial("SRD", "SRH") + "%"
    Local cSubst    := ""
    Local lVbSemIR  := .F.
    Local lFerMesInt:= .F.
    Local lVbSubIR43:= .F.
    Local lFerPart  := .F.
    Local nQtd      := 0
    Local nQtdRR    := 0
    Local nQtdRd2   := 0
    Local nAtual    := 0
    Local nDiasSal  := 0
    Local lTeto     := .F.
    Local cPerAnt   := ""
    Local aTinssFer := {}    
    Local nTetoInss := 0
    Local nTotInss  := 0

    If !Empty(cFiltFil)
        cWhereRD += "SRD.RD_FILIAL = '" + cFiltFil + "' AND "
        cWhereRR += "SRR.RR_FILIAL = '" + cFiltFil + "' AND "
        cWhereRD2 += "SRD.RD_FILIAL = '" + cFiltFil + "' AND "
    EndIf

    If !Empty(cProcesso)
       cWhereRD += "SRD.RD_PROCES = '" + cProcesso + "' AND "
       cWhereRR += "SRR.RR_PROCES = '" + cProcesso + "' AND "
       cWhereRD2 += "SRD.RD_PROCES = '" + cProcesso + "' AND "
    EndIf

    If !Empty(cMatricula)
        cWhereRD += "SRD.RD_MAT = '" + cMatricula + "' AND "
        cWhereRR += "SRR.RR_MAT = '" + cMatricula + "' AND "
        cWhereRD2 += "SRD.RD_MAT = '" + cMatricula + "' AND "
    EndIf

    If !Empty(cPeriodo)
        cPerAnt  := AnoMes(MonthSub(STOD(cPeriodo + "01"), 1))
        cWhereRD += "SRD.RD_PERIODO = '" + cPeriodo + "' AND "
        cWhereRR += "SRR.RR_PERIODO = '" + cPeriodo + "' AND "
        cWhereRD2 += "SRD.RD_PERIODO = '" + cPeriodo + "' AND "
    EndIf

    cWhereRD += "((SRV.RV_CODFOL='0065' AND SRD.RD_TIPO2='K' AND RD_FERSUB <> '') OR "
    cWhereRD += "(SRV.RV_CODFOL='0065' AND SRD.RD_TIPO2='G' AND RD_FERSUB <> '' AND SRD.RD_DATPGT <> SRG.RG_DATAHOM) OR " //Rescisao na folha
    cWhereRD += "(SRV.RV_CODFOL='0168' AND SRD.RD_TIPO2='C' AND RD_FERSUB = ''))"
    cWhereRD := "%" + cWhereRD + "%"

    // Query para trazer os registros da SRD que possuem amarração correta com as regras da SRV
    BeginSql Alias cAliasQry
        SELECT SRD.RD_FILIAL, 
               SRD.RD_MAT, 
               SRD.RD_PD, 
               SRD.RD_TIPO2,
               SRD.RD_DTREF, 
               SRD.RD_DATPGT,
               SRD.RD_FERSUB, 
               SRD.RD_PROCES, 
               SRV.RV_COD,
               SRV.RV_CODFOL,
               SRV.RV_INCIRF,  
               SRV.RV_DIRF,  
               SRV.RV_FERXML,
               SRG.RG_DATAHOM
        FROM %table:SRD% SRD
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRD.RD_PD 
            AND %exp:cJoinRDRV%
            AND SRV.%NotDel%
        LEFT JOIN %table:SRG% SRG
            ON SRG.RG_FILIAL = SRD.RD_FILIAL
            AND SRG.RG_MAT = SRD.RD_MAT
            AND %exp:cJoinRDRG%
            AND SRG.RG_PERIODO = SRD.RD_PERIODO
            AND SRG.%NotDel%
        WHERE %exp:cWhereRD% 
            AND SRD.%NotDel%
        ORDER BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD
    EndSql

    COUNT TO nQtd
    DbSelectArea(cAliasQry)
    DbGoTop()

    If nQtd > 0
        GpProcRegua(nQtd)
        While !(cAliasQry)->( EoF() )   
            nAtual++
            GpIncProc("Atualizando registro SRD " + cValToChar(nAtual) + " de " + cValToChar(nQtd) + "...")
            cSubst     := (cAliasQry)->RV_FERXML   
            lVbSemIR   := .F.
            lFerMesInt := .F.
            lVbSubIR43 := .F.
            lFerPart   := .F.      

            //ID 0065 (INSS FÉRIAS)
            If (cAliasQry)->RV_CODFOL == "0065"
                // Valida incidências do ID 0065: IR eSocial '43' e DIRF 'B'
                If Alltrim((cAliasQry)->RV_INCIRF) == "43" .And. Alltrim((cAliasQry)->RV_DIRF) == "B"
                    cDtRef     := cPeriodo + StrZero(f_UltDia( STOD(cPeriodo + "01") ), 2) 
                    //cDtPagto   := fGetDtPag((cAliasQry)->RD_PROCES, 'FOL', cPeriodo)

                    //Valida se verba substitutiva (RV_FERXML) está sem incidência de IR                
                    If !Empty(cSubst)
                        SRV->(DbSetOrder(1)) //RV_FILIAL + RV_COD
                        If SRV->(DbSeek(xFilial("SRV") + cSubst))
                            If Empty(Alltrim(SRV->RV_INCIRF)) .Or. Alltrim(SRV->RV_INCIRF) == "9"
                                lVbSemIR := .T.
                            EndIf
                        EndIf
                    EndIf

                    // Valida se teve férias o mês inteiro 
                    nDiasSal := fGetDiasSal((cAliasQry)->RD_FILIAL, (cAliasQry)->RD_MAT, cPeriodo)
                    If nDiasSal == 0 .Or. Empty(nDiasSal)
                        lFerMesInt := .T.
                    EndIf

                    If lVbSemIR .And. lFerMesInt
                        If (cAliasQry)->RD_TIPO2=='K'  
                            cDtPagto := fGetDtPag((cAliasQry)->RD_PROCES, 'FOL', cPeriodo)

                            cQuery := "UPDATE " + RetSqlName("SRD") + " "
                            cQuery += "SET RD_TIPO2 = 'C', " 
                            cQuery += "RD_DTREF = '"+cDtRef+"', " 
                            cQuery += "RD_DATPGT = '"+cDtPagto+"' " 
                            cQuery += "WHERE RD_FILIAL  = '" + (cAliasQry)->RD_FILIAL + "' "
                            cQuery += "AND RD_MAT     = '" + (cAliasQry)->RD_MAT + "' "
                            cQuery += "AND RD_PD      = '" + (cAliasQry)->RD_PD + "' "
                            cQuery += "AND RD_PERIODO = '" + cPeriodo + "' "
                            cQuery += "AND D_E_L_E_T_ = ' '"
                            TcSqlExec(cQuery)

                            Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ajustado origem = C, data de refer. = " + DtoC(SToD(cDtRef)) + " e data de pagto. = " + DtoC(SToD(cDtPagto)))

                        ElseIf (cAliasQry)->RD_TIPO2=='G' .And. !Empty((cAliasQry)->RG_DATAHOM)                            

                            cQuery := "UPDATE " + RetSqlName("SRD") + " "
                            cQuery += "SET RD_DATPGT = '"+(cAliasQry)->RG_DATAHOM +"',  " 
                            cQuery += "RD_DTREF = '"+(cAliasQry)->RG_DATAHOM+"' " 
                            cQuery += "WHERE RD_FILIAL  = '" + (cAliasQry)->RD_FILIAL + "' "
                            cQuery += "AND RD_MAT     = '" + (cAliasQry)->RD_MAT + "' "
                            cQuery += "AND RD_PD      = '" + (cAliasQry)->RD_PD + "' "
                            cQuery += "AND RD_PERIODO = '" + cPeriodo + "' "
                            cQuery += "AND D_E_L_E_T_ = ' '"
                            TcSqlExec(cQuery)

                            Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ajustado para data de pagto. da Rescisão (G) = " + DtoC(SToD((cAliasQry)->RG_DATAHOM)))
                        EndIf                        
                    Else
                        Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ignorado: Não atendeu o critério de férias mês inte. ou verba subs. "+cSubst+" sem IR.")
                    EndIf
                Else
                    Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ignorado: Não atendeu os critérios de IR eSocial '43' e DIRF 'B'.")
                EndIf

            //ID 0168 (DED. INSS IR FÉRIAS)
            ElseIf (cAliasQry)->RV_CODFOL == "0168" .And. (cAliasQry)->RD_TIPO2 == "C"
                // Validar incidências do ID 0168: IR eSocial '9' e DIRF 'B'
                If Alltrim((cAliasQry)->RV_INCIRF) == "9" .And. Alltrim((cAliasQry)->RV_DIRF) == "B" .And. !Empty((cAliasQry)->RV_FERXML)

                    // Validar verba substitutiva (RV_FERXML) possui incidência de IR '43'
                    SRV->(DbSetOrder(1)) // RV_FILIAL + RV_COD
                    If SRV->(DbSeek(xFilial("SRV") + cSubst))
                        If Alltrim(SRV->RV_INCIRF) == "43"
                            lVbSubIR43 := .T.
                        EndIf
                    EndIf

                    // Validar férias partidas - se existe verba de salário no período
                    nDiasSal := fGetDiasSal((cAliasQry)->RD_FILIAL, (cAliasQry)->RD_MAT, cPeriodo)
                    If nDiasSal > 0
                        lFerPart := .T.
                    EndIf            

                    If lVbSubIR43 .And. lFerPart                    
                        cQuery := "UPDATE " + RetSqlName("SRD") + " "
                        cQuery += "SET RD_FERSUB = '" + (cAliasQry)->RV_FERXML + "' "
                        cQuery += "WHERE RD_FILIAL  = '" + (cAliasQry)->RD_FILIAL + "' "
                        cQuery += "AND RD_MAT     = '" + (cAliasQry)->RD_MAT + "' "
                        cQuery += "AND RD_PD      = '" + (cAliasQry)->RD_PD + "' "
                        cQuery += "AND RD_PERIODO = '" + cPeriodo + "' "
                        cQuery += "AND RD_TIPO2   = 'C' "
                        cQuery += "AND D_E_L_E_T_ = ' '"
                        TcSqlExec(cQuery)

                        Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Gravado RD_FERSUB = " + (cAliasQry)->RV_FERXML) 
                    Else
                        Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ignorado - Férias não são part. ou verba subs. "+cSubst+" não possui IR eSocial '43'.")
                    EndIf  
                Else 
                    Aadd(aLog[1], "(SRD) Filial:" + (cAliasQry)->RD_FILIAL + " | Matrícula:" + (cAliasQry)->RD_MAT + " | Verba " + (cAliasQry)->RV_COD + ": Ignorado - não atendeu os critérios de IR eSocial '9' e DIRF 'B' ou verba subs. está vazia.")         
                EndIf
            EndIf

            (cAliasQry)->( dbSkip() )
        EndDo
    EndIf
    (cAliasQry)->( dbCloseArea() )

    // --- PROCESSAMENTO DA TABELA SRR (RESCISÃO - APENAS ID 0065) ---
    cWhereRR += "SRV.RV_CODFOL='0065' AND SRR.RR_TIPO2='K' AND SRR.RR_FERSUB<>'' AND SRR.RR_TIPO3='R'"
    cWhereRR := "%" + cWhereRR + "%"

    BeginSql Alias cAliasSRR
        SELECT SRR.RR_FILIAL, 
               SRR.RR_MAT, 
               SRR.RR_PD, 
               SRR.RR_TIPO2,
               SRR.RR_DTREF, 
               SRR.RR_DATAPAG,
               SRR.RR_PROCES, 
               SRG.RG_DATAHOM,
               SRV.RV_COD,
               SRV.RV_CODFOL,
               SRV.RV_INCIRF,  
               SRV.RV_DIRF,  
               SRV.RV_FERXML
        FROM %table:SRR% SRR
        INNER JOIN %table:SRG% SRG
            ON %exp:cJoinRRRG%
            AND SRG.RG_MAT = SRR.RR_MAT
            AND SRG.%NotDel%
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRR.RR_PD 
            AND %exp:cJoinRRRV%
            AND SRV.%NotDel%
        WHERE %exp:cWhereRR% 
            AND SRR.%NotDel%
        ORDER BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD
    EndSql

    COUNT TO nQtdRR
    DbSelectArea(cAliasSRR)
    DbGoTop()

    If nQtdRR > 0
        nAtual := 0
        GpProcRegua(nQtdRR)
        
        While !(cAliasSRR)->( EoF() )
            nAtual++
            GpIncProc("Atualizando registro SRR " + cValToChar(nAtual) + " de " + cValToChar(nQtdRR) + "...")
            cSubst     := (cAliasSRR)->RV_FERXML
            lVbSemIR   := .F.
            lFerMesInt := .F.

            If Alltrim((cAliasSRR)->RV_INCIRF) == "43" .And. Alltrim((cAliasSRR)->RV_DIRF) == "B"
                
                If !Empty(cSubst)
                    SRV->(DbSetOrder(1))
                    If SRV->(DbSeek(xFilial("SRV") + cSubst))
                        If Empty(Alltrim(SRV->RV_INCIRF)) .Or. Alltrim(SRV->RV_INCIRF) == "9"
                            lVbSemIR := .T.
                        EndIf
                    EndIf
                EndIf
                // Valida a existência do ID 0064 na SRR
                nDiasSal := fGetIdSRR((cAliasSRR)->RR_FILIAL, (cAliasSRR)->RR_MAT, cPeriodo)
                If nDiasSal == 0 .Or. Empty(nDiasSal)
                    lFerMesInt := .T.
                EndIf

                If lVbSemIR .And. lFerMesInt
                    cQuery := "UPDATE " + RetSqlName("SRR") + " "
                    cQuery += "SET RR_TIPO2 = 'R', " 
                    cQuery += "RR_DATAPAG = '"+(cAliasSRR)->RG_DATAHOM+"' " 
                    cQuery += "WHERE RR_FILIAL  = '" + (cAliasSRR)->RR_FILIAL + "' "
                    cQuery += "AND RR_MAT = '" + (cAliasSRR)->RR_MAT + "' "
                    cQuery += "AND RR_PD = '" + (cAliasSRR)->RR_PD + "' "
                    cQuery += "AND RR_PERIODO = '" + cPeriodo + "' "
                    cQuery += "AND RR_TIPO3 = 'R' "
                    cQuery += "AND D_E_L_E_T_ = ' '"
                    TcSqlExec(cQuery)
                    
                    Aadd(aLog[1], "(SRR) Filial:" + (cAliasSRR)->RR_FILIAL + " | Matrícula:" + (cAliasSRR)->RR_MAT + " | Verba " + (cAliasSRR)->RV_COD + ": Ajustado origem = R, e data de pagto. = " + DtoC(SToD((cAliasSRR)->RG_DATAHOM)))
                Else
                    Aadd(aLog[1], "(SRR) Filial:" + (cAliasSRR)->RR_FILIAL + " | Matrícula:" + (cAliasSRR)->RR_MAT + " | Verba " + (cAliasSRR)->RV_COD + ": Ignorado - Não atendeu o critério de férias mês inte. ou verba subs. "+cSubst+" sem IR.")
                EndIf
            Else
                Aadd(aLog[1], "(SRR) Filial:" + (cAliasSRR)->RR_FILIAL + " | Matrícula:" + (cAliasSRR)->RR_MAT + " | Verba " + (cAliasSRR)->RV_COD + ": Ignorado - Não atendeu os critérios de IR eSocial '43' e DIRF 'B'.")
            EndIf

            (cAliasSRR)->( dbSkip() )
        EndDo
    EndIf
    (cAliasSRR)->(dbCloseArea())
    //--------------------------------------------------------------------------------------------
    // --- PROCESSAMENTO DA TABELA SRD PAGAMENTO DO TETO NO MÊS ANTERIOR (ACUMULADO - ID 0168) ---
    //--------------------------------------------------------------------------------------------
    cWhereRD2 := "SRV.RV_CODFOL = '0168' AND SRD.RD_TIPO2 = 'C' "
    cWhereRD2 := "%" + cWhereRD2 + "%"

    BeginSql Alias cAliasRD2
        SELECT DISTINCT 
               SRD.R_E_C_N_O_ AS RECNO_SRD, 
               SRH.RH_DTRECIB, 
               SRD.RD_FILIAL, 
               SRD.RD_MAT, 
               SRD.RD_PD, 
               SRD.RD_DATPGT, 
               SRD.RD_DTREF, 
               SRV.RV_COD 
        FROM %table:SRD% SRD 
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRD.RD_PD 
            AND %exp:cJoinRDRV%
            AND SRV.%NotDel% 
        INNER JOIN %table:SRH% SRH 
            ON SRH.RH_MAT = SRD.RD_MAT 
            AND %exp:cJoinRDRH%
            AND SUBSTRING(SRH.RH_DATAINI, 1, 6) = %exp:cPerAnt%
            AND SUBSTRING(SRH.RH_DATAFIM, 1, 6) >= %exp:cPeriodo%
            AND SRH.%NotDel% 
        WHERE %exp:cWhereRD2% 
            AND SRD.%NotDel% 
        ORDER BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD
    EndSql

    COUNT TO nQtdRd2
    DbSelectArea(cAliasRD2)
    DbGoTop()

    If nQtdRd2 > 0
        nAtual := 0
        GpProcRegua(nQtdRd2)
        DbSelectArea("SRD")

        While !(cAliasRD2)->(Eof())
            nAtual++
            GpIncProc("Atualizando registro com teto de INSS na SRD " + cValToChar(nAtual) + " de " + cValToChar(nQtdRd2) + "...")
            lTeto := .F.
            cFil  := (cAliasRD2)->RD_FILIAL
            cMat  := (cAliasRD2)->RD_MAT
            // Busca o valor do teto do INSS vigente na data do pagamento das férias
            If !Empty((cAliasRD2)->RH_DTRECIB)
                Car_inss(@aTinssFer, MesAno(STOD((cAliasRD2)->RH_DTRECIB)))
                nTetoInss := fRetTetIns(aTinssFer)
                nTotInss  := 0
                // Soma o total do ID 0168 de origem K no mês anterior
                BeginSql Alias cAliasVal
                    SELECT SUM(SRD.RD_VALOR) AS TOTAL_INSS
                    FROM %table:SRD% SRD
                    INNER JOIN %table:SRV% SRV
                        ON SRV.RV_COD = SRD.RD_PD
                        AND %exp:cJoinRDRV%
                        AND SRV.%NotDel%
                    WHERE SRD.RD_FILIAL = %exp:cFil%
                        AND SRD.RD_MAT = %exp:cMat%
                        AND SRD.RD_PERIODO = %exp:cPerAnt%
                        AND SRD.RD_TIPO2 = 'K'
                        AND SRV.RV_CODFOL = '0168'
                        AND SRD.%NotDel%
                EndSql

                If !(cAliasVal)->(Eof()) //.And. ValType((cAliasVal)->TOTAL_INSS) == "N"
                    nTotInss := (cAliasVal)->TOTAL_INSS
                EndIf
                (cAliasVal)->(DbCloseArea())

            EndIf

            // Se a dedução do INSS Férias no mês anterior atingiu o teto
            If nTotInss > 0 .And. nTotInss >= nTetoInss
                lTeto := .T.
            EndIf
            If lTeto
                SRD->(DbGoTo((cAliasRD2)->RECNO_SRD))                
                If !(SRD->(Eof()))
                    RecLock("SRD", .F.)
                        SRD->(DbDelete())
                    SRD->(MsUnlock())

                    Aadd(aLog[1], "(SRD) Filial:" + (cAliasRD2)->RD_FILIAL +" | Matrícula:" + (cAliasRD2)->RD_MAT + " | Verba " + (cAliasRD2)->RV_COD + ": Excluída pois atingiu o teto de dedução de INSS IR Férias no mês anterior.")            
                EndIf
            Else 
                Aadd(aLog[1], "(SRD) Filial:" + (cAliasRD2)->RD_FILIAL +" | Matrícula:" + (cAliasRD2)->RD_MAT + " | Verba " + (cAliasRD2)->RV_COD + ": Ignorado - não atingiu o teto de dedução de INSS IR Férias no mês anterior.")
            EndIf

            (cAliasRD2)->(DbSkip())
        EndDo
    EndIf

    (cAliasRD2)->(DbCloseArea())

    If nQtd == 0 .And. nQtdRR == 0 .And. nQtdRd2 == 0
        Aadd(aLog[1], "Nenhum registro correspondente aos critérios foi encontrado para os parâmetros informados.")
    EndIf
Return

/*/{Protheus.doc} fGetDtPag
Função para buscar a data de pagamento do período na tabela RCH
/*/
Static Function fGetDtPag(cProcesso, cRoteiro, cPeriodo)
    Local cDtPag    := ""

    If Empty(cRoteiro)
        cRoteiro := "FOL"
    EndIf

    RCH->(DbSetOrder(4)) 
    If RCH->(DbSeek(xFilial("RCH") + cProcesso + cRoteiro + cPeriodo))
        cDtPag := DTOS(RCH->RCH_DTPAGO) 
    EndIf
Return cDtPag

/*/{Protheus.doc} fGetDiasSal
Função para buscar a soma dos dias de salário de um funcionário no período.
/*/
Static Function fGetDiasSal(cFili, cMat, cPeriodo)

    Local nDiasSal   := 0
    Local cAliasSRD  := GetNextAlias()
    Local cJoinRDRV  := "%" + FWJoinFilial("SRD", "SRV") + "%"

    BeginSql Alias cAliasSRD
        SELECT SUM(SRD.RD_HORAS) AS DIAS_SALARIO
        FROM %table:SRD% SRD
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRD.RD_PD
            AND %exp:cJoinRDRV%
            AND SRV.%NotDel%
        WHERE SRD.RD_FILIAL = %exp:cFili%
            AND SRD.RD_MAT = %exp:cMat%
            AND SRD.RD_PERIODO = %exp:cPeriodo%
            AND SRV.RV_CODFOL IN ('0031', '0032') //Salário mensalista/horista
            AND SRD.%NotDel%
    EndSql

    If (cAliasSRD)->( !EoF() )
        nDiasSal := (cAliasSRD)->DIAS_SALARIO
    EndIf
    
    (cAliasSRD)->(DbCloseArea())

Return nDiasSal

/*/{Protheus.doc} fGetIdSRR
Função para buscar a existência do ID na tabela SRR.
/*/
Static Function fGetIdSRR(cFili, cMat, cPeriodo)
    Local nRetVal     := 0
    Local cAliasSRR   := GetNextAlias()
    Local cJoinRRRV   := "%" + FWJoinFilial("SRR", "SRV") + "%"

    BeginSql Alias cAliasSRR
        SELECT COUNT(*) AS QTD_REG
        FROM %table:SRR% SRR
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRR.RR_PD
            AND %exp:cJoinRRRV%
            AND SRV.%NotDel%
        WHERE SRR.RR_FILIAL = %exp:cFili%
            AND SRR.RR_MAT = %exp:cMat%
            AND SRR.RR_PERIODO = %exp:cPeriodo%
            AND SRV.RV_CODFOL = '0064' //INSS 
            AND SRR.%NotDel%
    EndSql

    If (cAliasSRR)->( !EoF() )
        nRetVal := (cAliasSRR)->QTD_REG
    EndIf
    
    (cAliasSRR)->(DbCloseArea())

Return nRetVal

