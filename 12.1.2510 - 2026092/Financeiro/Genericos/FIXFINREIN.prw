#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include 'TOPConn.ch'
#Include "FILEIO.CH"
#INCLUDE "PARMTYPE.CH" 

Static __lFK7Cpos As Logical
Static __oTitPaga As Object
Static __oTitRece As Object
Static __oBaixaCP As Object
Static __oSemImp  As Object
Static __oImpNR   As Object
Static __nTamFil  As Numeric
Static __nTamPre  As Numeric
Static __nTamNum  As Numeric
Static __nTamParc As Numeric
Static __nTamTipo As Numeric
Static __nTamCliF As Numeric
Static __nTamLoja As Numeric
Static __nFkwImp  As Numeric
Static __lFIXQRYR As Logical
Static __lCQUERYP  As Logical

/*/{Protheus.doc} FIXFINREINF    
    Inicio das funções de FIX do módulo SIGAFIN que abrange a gravação da FKW para os 
    títulos a pagar/recebe sem vinculo com notas (doc. entrada/saída)
    
    @param aFiliais, array unidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento da atualização
    da natureza de rendimento dos títulos contas a pagar e/ou receber e/ou baixas a pagar
/*/
Function FIXFINREIN(aFiliais As Array, cDtIni As Character)
    Local lRetorno   As Logical  
    Local cMAEmpSED  As Char
    Local cMAUniSED  As Char    
    Local cMAFilSED  As Char            
    Local cMAEmpSA1  As Char
    Local cMAUniSA1  As Char
    Local cMAFilSA1  As Char    
    Local cMAEmpSA2  As Char
    Local cMAUniSA2  As Char
    Local cMAFilSA2  As Char
    Local cMAEmpSE1  As Char
    Local cMAUniSE1  As Char
    Local cMAFilSE1  As Char
    Local cMAEmpSE2  As Char
    Local cMAUniSE2  As Char
    Local cMAFilSE2  As Char
    Local nTamFilSED As Numeric
    Local nTamFilSA1 As Numeric
    Local nTamFilSA2 As Numeric    
    Local nTamFilSE1 As Numeric
    Local nTamFilSE2 As Numeric
    Local nTamEmp    As Numeric
	Local nTamUni    As Numeric
    Local nTamFil    As Numeric    
    Local nFiliais   As Numeric
    Local nLinha     As Numeric
    Local aFilAux    As Arry
    Local aLstTipo   As Array
    
    //Parâmetros de entrada.
    Default aFiliais := {cFilAnt}
    Default cDtIni   := DTOS(Date())
    
    If __nFkwImp == Nil
		__nFkwImp := TAMSX3("FKW_TPIMP")[1]
    EndIf
    
    If __lFIXQRYR == Nil
        __lFIXQRYR := ExistBlock("FIXQRYR")
    EndIf
    
    __lCQUERYP := REINFLOG->(ColumnPos("CQUERYP")) > 0
    
    //Inicializa variáveis
    lRetorno := .F.
    cMAEmpSED  := AllTrim(FWModeAccess("SED",1))
    cMAUniSED  := AllTrim(FWModeAccess("SED",2))
    cMAFilSED  := AllTrim(FWModeAccess("SED",3))
    cMAEmpSA1  := AllTrim(FWModeAccess("SA1",1))
    cMAUniSA1  := AllTrim(FWModeAccess("SA1",2))
    cMAFilSA1  := AllTrim(FWModeAccess("SA1",3))
    cMAEmpSA2  := AllTrim(FWModeAccess("SA2",1))
    cMAUniSA2  := AllTrim(FWModeAccess("SA2",2))
    cMAFilSA2  := AllTrim(FWModeAccess("SA2",3))
    cMAEmpSE1  := AllTrim(FWModeAccess("SE1",1))
    cMAUniSE1  := AllTrim(FWModeAccess("SE1",2))
    cMAFilSE1  := AllTrim(FWModeAccess("SE1",3))
    cMAEmpSE2  := AllTrim(FWModeAccess("SE2",1))
    cMAUniSE2  := AllTrim(FWModeAccess("SE2",2))
    cMAFilSE2  := AllTrim(FWModeAccess("SE2",3))
    nTamFilSED := 0
    nTamFilSA1 := 0
    nTamFilSA2 := 0
    nTamFilSE1 := 0
    nTamFilSE2 := 0
    nTamEmp    := Len(FwSM0Layout(,1))
    nTamUni    := Len(FwSM0Layout(,2))
    nTamFil    := Len(FwSM0Layout(,3))        
    nFiliais   := Len(aFiliais)
    nLinha     := 0
    aFilAux    := {{}, {}, {}}
    aLstTipo   := {}
    
    If (nTamEmp+nTamUni) == 0
        cMAEmpSED := cMAUniSED := cMAFilSED
        cMAEmpSA1 := cMAUniSA1 := cMAFilSA1
        cMAEmpSA2 := cMAUniSA2 := cMAFilSA2
        cMAEmpSE1 := cMAUniSE1 := cMAFilSE1
        cMAEmpSE2 := cMAUniSE2 := cMAFilSE2
    Else
        If nTamEmp == 0
            cMAEmpSED := cMAUniSED
            cMAEmpSA1 := cMAUniSA1
            cMAEmpSA2 := cMAUniSA2
            cMAEmpSE1 := cMAUniSE1
            cMAEmpSE2 := cMAUniSE2
        ElseIf nTamUni == 0 
            cMAUniSED := cMAFilSED
            cMAUniSA1 := cMAFilSA1
            cMAUniSA2 := cMAFilSA2
            cMAUniSE1 := cMAFilSE1
            cMAUniSE2 := cMAFilSE2        
        EndIf 
    EndIf
    
    nTamFilSED := (IIf(cMAEmpSED == "C", 0, nTamEmp) + IIf(cMAUniSED == "C", 0, nTamUni) + IIf(cMAFilSED == "C", 0, nTamFil))
    nTamFilSA1 := (IIf(cMAEmpSA1 == "C", 0, nTamEmp) + IIf(cMAUniSA1 == "C", 0, nTamUni) + IIf(cMAFilSA1 == "C", 0, nTamFil))
    nTamFilSA2 := (IIf(cMAEmpSA2 == "C", 0, nTamEmp) + IIf(cMAUniSA2 == "C", 0, nTamUni) + IIf(cMAFilSA2 == "C", 0, nTamFil))
    nTamFilSE1 := (IIf(cMAEmpSE1 == "C", 0, nTamEmp) + IIf(cMAUniSE1 == "C", 0, nTamUni) + IIf(cMAFilSE1 == "C", 0, nTamFil))
    nTamFilSE2 := (IIf(cMAEmpSE2 == "C", 0, nTamEmp) + IIf(cMAUniSE2 == "C", 0, nTamUni) + IIf(cMAFilSE2 == "C", 0, nTamFil))
    aLstTipo   := Strtokarr((MVABATIM+"|"+MV_CRNEG+"|"+MVTXA+"|"+MVTAXA+"|"+MV_CPNEG+"|"+MVPROVIS+"|"+MVINSS+"|"+MVISS+"|"+MVCSABT+"|"+MVCFABT+"|"+MVPIABT+"|SES|CID|INA|PIS|CSL|COF"), "|")
    
    For nLinha := 1 To nFiliais
        If !Empty(aFiliais[nLinha])        
            lRetorno := .T.
            AAdd(aFilAux[1], xFilial("SE2", aFiliais[nLinha]))
            AAdd(aFilAux[2], xFilial("SE1", aFiliais[nLinha]))
            AAdd(aFilAux[3], xFilial("FK2", aFiliais[nLinha]))
        EndIf
    Next nX        
    
    aFiliais := AClone(aFilAux)        
    
    If lRetorno
        //Atualiza a natureza de rendimentos do contas a pagar        
        FinCPag(aFiliais[1], nTamFilSED, nTamFilSA2, nTamFilSE2, aLstTipo, cDtIni)
        
        //Atualiza a natureza de rendimentos do contas a receber
        FinCRec(aFiliais[2], nTamFilSED, nTamFilSA1, nTamFilSE1, aLstTipo, cDtIni)        
        
        //Gravação da tabelas de Impostos x Nat. Rend. x Baixas (FKY)
        FinFKYWCP(aFiliais[3])
    EndIf
    
    FWFreeArray(aFilAux)
    FwFreeArray(aLstTipo)
Return lRetorno

/*/{Protheus.doc} FinCPag    
    @type User Function   
    @param aFiliais, array unidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento de atualização
    da natureza de rendimento do títulos a pagar
/*/
Static Function FinCPag(aFiliais As Array, nTamFilSED As Numeric, nTamFilSA2 As Numeric, nTamFilSE2 As Numeric, aLstTipo As Array, cDtIni As Char) As Logical    
    Local lRetorno   As Logical
    Local lAchouFKF  As Logical
    Local cTblPagar  As Char
    Local cQuery     As Char
    Local cIdDocFK7  As Char
    Local cTpImpos   As Char
    Local cFilAtual  As Char
    Local cQryNew    As Char
    Local cTipoQryP  As Char
    Local nMenorFil  As Numeric        
    Local nTpImpos   As Numeric
    Local nVlrImpos  As Numeric
    Local nBaseImpos As Numeric 
    Local nTotal     As Numeric
    Local nMVALIQIRF As Numeric
    Local aDados     As Array
    
    //Parâmetros de entrada.
    Default aFiliais   := {cFilAnt}
    Default nTamFilSED := 0
    Default nTamFilSA2 := 0
    Default nTamFilSE2 := 0
    Default aLstTipo   := {""}
    Default cDtIni     := StoD(Date())
    
    //Inicializa variáveis.
    lRetorno   := .F.
    lAchouFKF  := .T.
    cTblPagar  := ""
    cQuery     := ""
    cIdDocFK7  := ""
    cTpImpos   := "SEMIMP"
    cFilAtual  := cFilAnt
    cQryNew    := ""
    cTipoQryP  := "P"
    nMenorFil  := 0
    nTpImpos   := 0
    nVlrImpos  := 0
    nBaseImpos := 0
    nTotal     := 0
    nMVALIQIRF := SuperGetMV("MV_ALIQIRF", .T., 0)
    aDados     := {}
    
    If __oTitPaga == Nil
        cQuery := "SELECT SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_FILORIG, "
        cQuery += "SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_IRRF, SE2.E2_VALOR, SE2.E2_SALDO, SE2.E2_BASEIRF, SE2.E2_BASEPIS, SE2.E2_BASECOF, "
        cQuery += "SE2.E2_BASECSL, SE2.R_E_C_N_O_, SED.ED_NATREN, SED.ED_CALCIRF, SED.ED_CALCPIS, SED.ED_CALCCOF, SED.ED_CALCCSL, SED.ED_PERCIRF, "
        cQuery += "SED.ED_PERCPIS, SED.ED_PERCCOF, SED.ED_PERCCSL, SA2.A2_RECPIS, SA2.A2_RECCOFI, SA2.A2_RECCSLL, SA2.A2_CALCIRF "
        cQuery += "FROM ? SE2 "
        
        //Relacionamento: SE2 vs SED
        nMenorFil := IIf(nTamFilSED > nTamFilSE2, nTamFilSE2, nTamFilSED)
        
        cQuery += "INNER JOIN ? SED ON ( "
        
        If nMenorFil > 0
            cQuery += "SUBSTRING(SE2.E2_FILIAL, 1, " + cValToChar(nMenorFil) + ") = SUBSTRING(SED.ED_FILIAL, 1, " + cValToChar(nMenorFil) + ") AND "
        EndIf
        
        cQuery += "SE2.E2_NATUREZ = SED.ED_CODIGO "
        cQuery += "AND SE2.D_E_L_E_T_ = SED.D_E_L_E_T_) "

        //Relacionamento: SE2 vs SA2
        nMenorFil := IIf(nTamFilSA2 > nTamFilSE2, nTamFilSE2, nTamFilSA2)
        
        cQuery += "INNER JOIN ? SA2 ON ( "
        
        If nMenorFil > 0
            cQuery += "SUBSTRING(SE2.E2_FILIAL, 1, " + cValToChar(nMenorFil) + ") = SUBSTRING(SA2.A2_FILIAL, 1, " + cValToChar(nMenorFil) + ") AND "
        EndIF
        
        cQuery += "SE2.E2_FORNECE = SA2.A2_COD "
        cQuery += "AND SE2.E2_LOJA = SA2.A2_LOJA "
        cQuery += "AND SE2.D_E_L_E_T_ = SA2.D_E_L_E_T_) "
        
        cQuery += "WHERE "
        cQuery += "SE2.E2_FILIAL IN (?) "
        cQuery += "AND SE2.E2_TIPO NOT IN (?) "
        cQuery += "AND SE2.E2_ORIGEM NOT IN ('MATA100', 'MATA103') "            
        cQuery += "AND SE2.D_E_L_E_T_ = ' ' "
        cQuery += "AND SED.ED_NATREN IS NOT NULL AND SED.ED_NATREN <> ' ' "            
        cQuery += "AND SE2.E2_EMISSAO >= ? "       
        
        cQuery := ChangeQuery(cQuery)
        __oTitPaga := FwPreparedStatement():New(cQuery)
    EndIf
    
    __oTitPaga:SetNumeric(1, RetSqlName("SE2"))
    __oTitPaga:SetNumeric(2, RetSqlName("SED"))
    __oTitPaga:SetNumeric(3, RetSqlName("SA2"))
    __oTitPaga:SetIn(4, aFiliais)
    __oTitPaga:SetIn(5, aLstTipo)
    __oTitPaga:SetString(6, cDtIni)

    cQuery := __oTitPaga:GetFixQuery()
    
    If __lFIXQRYR
        cQryNew := cQuery
        cQryNew := ExecBlock("FIXQRYR", .F., .F., {"06", "P", cQryNew})        
        
        If ValType(cQryNew) == "C" .And. !Empty(cQryNew) .And. AllTrim(cQryNew) != AllTrim(cQuery)
            cQuery    := cQryNew 
            cTipoQryP := "C"            
        EndIf
    EndIf
    
    cTblPagar := MpSysOpenQuery(cQuery)
    nTotal    := Contar(cTblPagar,"!Eof()")
    
    (cTblPagar)->(DbGoTop())
    DbSelectArea("FKF")
    
    While (cTblPagar)->(!Eof())
        aDados    := {}
        cIdDocFK7 := FINBuscaFK7((cTblPagar)->(E2_FILIAL+"|"+E2_PREFIXO+"|"+E2_NUM+"|"+E2_PARCELA+"|"+E2_TIPO+"|"+E2_FORNECE+"|"+E2_LOJA), "SE2", (cTblPagar)->E2_FILORIG)
        
        If !Empty(cIdDocFK7) .And. !FTemFKW(cIdDocFK7)            
            //Atualiza FKF        
            FKF->(DbSetOrder(1))
            lAchouFKF := FKF->(MsSeek(xFilial("FKF", (cTblPagar)->E2_FILORIG)+cIdDocFK7))
            
            IF lAchouFKF
                RecLock("FKF", .F.)
                FKF->FKF_NATREN := (cTblPagar)->ED_NATREN
                FKF->(MsUnLock())
            EndIF
            
            For nTpImpos := 1 To 5                
                Do Case
                    Case nTpImpos == 1 //IRRF                        
                        If (AllTrim((cTblPagar)->ED_CALCIRF) != "S" .Or. (((cTblPagar)->ED_PERCIRF+nMVALIQIRF) <= 0) .Or. (cTblPagar)->E2_BASEIRF == 0 .Or. !AllTrim((cTblPagar)->A2_CALCIRF) $ "1|2" )
                            Loop
                        EndIf
                        
                        cTpImpos   := "IRF"
                        nVlrImpos  := (cTblPagar)->E2_IRRF
                        nBaseImpos := (cTblPagar)->E2_BASEIRF                    
                    Case nTpImpos == 2 //PIS
                        If (AllTrim((cTblPagar)->ED_CALCPIS) != "S" .Or. (cTblPagar)->ED_PERCPIS <= 0 .Or. AllTrim((cTblPagar)->A2_RECPIS) != "2")
                            Loop
                        EndIf
                        
                        cTpImpos   := "PIS"
                        nVlrImpos  := (cTblPagar)->E2_PIS 
                        nBaseImpos := (cTblPagar)->E2_BASEPIS                    
                    Case nTpImpos == 3 //COFINS                        
                        If (AllTrim((cTblPagar)->ED_CALCCOF) != "S" .Or. (cTblPagar)->ED_PERCCOF <= 0 .Or. AllTrim((cTblPagar)->A2_RECCOFI) != "2")
                            Loop
                        EndIf                    
                        
                        cTpImpos   := "COF"
                        nVlrImpos  := (cTblPagar)->E2_COFINS 
                        nBaseImpos := (cTblPagar)->E2_BASECOF                     
                    Case nTpImpos == 4 //CSLL                        
                        If (AllTrim((cTblPagar)->ED_CALCCSL) != "S" .Or. (cTblPagar)->ED_PERCCSL <= 0 .Or. AllTrim((cTblPagar)->A2_RECCSLL) != "2")
                            Loop
                        EndIf
                        
                        cTpImpos   := "CSL"
                        nVlrImpos  := (cTblPagar)->E2_CSLL 
                        nBaseImpos := (cTblPagar)->E2_BASECSL
                    OtherWise // Títulos sem impostos
                        If Len(aDados) == 0
                            cTpImpos   := "SEMIMP"
                            nVlrImpos  := 0
                            nBaseImpos := (cTblPagar)->E2_VALOR                              
                        EndIf
                EndCase
                
                If nBaseImpos > 0
                    AAdd(aDados, {(cTblPagar)->E2_FILORIG, cIdDocFK7, cTpImpos, (cTblPagar)->ED_NATREN, 100, nBaseImpos, nVlrImpos, 0, 0, "", "", "", 0})
                EndIf
                
                nBaseImpos := 0
            Next nTpImpos
            
            //Gravação do FKW
            If Len(aDados) > 0
                cFilAnt  := (cTblPagar)->E2_FILORIG
                lRetorno := F070Grv(aDados, 4, "1")
                cFilAnt  := cFilAtual
            EndIf
            
            If lRetorno
                DbSelectArea("REINFLOG")
                REINFLOG->(DbSetIndex("IND1"))
                lRegNew := REINFLOG->(MsSeek("CP" + cIdDocFK7 ))
                
                If RecLock("REINFLOG",!lRegNew)
                    REINFLOG->GRUPO    := cEmpAnt
                    REINFLOG->EMPFIL   := (cTblPagar)->E2_FILIAL
                    REINFLOG->DATAPROC := FWTimeStamp(2, DATE(), TIME())
                    REINFLOG->TIPO     := "CP"
                    REINFLOG->CHAVE    := cIdDocFK7
                    REINFLOG->FINFKF   := "U" //U=Update
                    REINFLOG->FINFKW   := "I" //I=Insert
                    
                    If __lCQUERYP 
                        REINFLOG->CQUERYP := cTipoQryP
                    EndIf
                    
                    REINFLOG->(MsUnlock())
                Endif
            EndIf
        EndIf
        (cTblPagar)->(DbSkip())
    EndDo    
    
    (cTblPagar)->(DbCloseArea())
    FwFreeArray(aDados)
Return lRetorno

/*/{Protheus.doc} FinCRec    
    @type User Function    
    @param aFiliais, array unidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento de atualização
    da natureza de rendimento do títulos a receber
/*/
Static Function FinCRec(aFiliais As Array, nTamFilSED As Numeric, nTamFilSA1 As Numeric, nTamFilSE1 As Numeric, aLstTipo As Array, cDtIni As Char) As Logical
    Local lRetorno   As Logical
    Local lAchouFKW  As Logical
    Local lAchouFKF  As Logical
    Local cTblTmp    As Char
    Local cQuery     As Char
    Local cIdDocFK7  As Char
    Local cQryNew    As Char
    Local cTipoQryP  As Char
    Local nMenorFil  As Numeric
    Local nTotal     As Numeric
    Local aDados     As Array
    
    //Parâmetros de entrada.
    Default aFiliais   := {cFilAnt}
    Default nTamFilSED := 0
    Default nTamFilSA1 := 0
    Default nTamFilSE1 := 0
    Default aLstTipo   := {""}
    Default cDtIni     := StoD(Date())
    
    //Inicializa variáveis.
    lRetorno   := .F.
    lAchouFKW  := .T.
    lAchouFKF  := .T.
    cTblTmp    := ""
    cQuery     := ""
    cIdDocFK7  := ""
    cQryNew    := ""
    cTipoQryP  := "P"
    nMenorFil  := 0
    nTotal     := 0
    aDados     := {}
    
    If __oTitRece == Nil
        cQuery := "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_FILORIG, SE1.E1_PIS, "
        cQuery += "SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_IRRF, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_BASEIRF, SE1.E1_BASEPIS, SE1.E1_BASECOF, SE1.E1_BASECSL, "
        cQuery += "SE1.R_E_C_N_O_, SED.ED_NATREN, SED.ED_CALCIRF, SED.ED_CALCPIS, SED.ED_CALCCOF, SED.ED_CALCCSL, SED.ED_PERCIRF, SED.ED_PERCPIS, "
        cQuery += "SED.ED_PERCCOF,SED.ED_PERCCSL FROM ? SE1 "        
        
        //Relacionamento: SE1 vs SED
        nMenorFil := IIf(nTamFilSED > nTamFilSE1, nTamFilSE1, nTamFilSED)

        cQuery += "INNER JOIN ? SED ON ( "
        
        If nMenorFil > 0
            cQuery += "SUBSTRING(SE1.E1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") = SUBSTRING(SED.ED_FILIAL , 1 , " + cValToChar(nMenorFil) + ") AND "
        EndIF        
        
        cQuery += "SE1.E1_NATUREZ = SED.ED_CODIGO "
        cQuery += "AND SE1.D_E_L_E_T_ = SED.D_E_L_E_T_) "
        
        //Relacionamento: SE1 vs SA1
        nMenorFil := IIf(nTamFilSA1 > nTamFilSE1, nTamFilSE1, nTamFilSA1)
        
        cQuery += "INNER JOIN ? SA1 ON ( "
        
        If nMenorFil > 0
            cQuery += "SUBSTRING(SE1.E1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") = SUBSTRING(SA1.A1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") AND "
        EndIF
        
        cQuery += "SE1.E1_CLIENTE = SA1.A1_COD "
        cQuery += "AND SE1.E1_LOJA = SA1.A1_LOJA "
        cQuery += "AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_) "
        
        //Filtro de linhas
        cQuery += "WHERE "
        cQuery += "SE1.E1_FILIAL IN (?) AND SE1.E1_SALDO > 0 "
        cQuery += "AND SE1.E1_TIPO NOT IN (?) "
        cQuery += "AND SE1.E1_ORIGEM NOT IN ('MATA460', 'MATA461') "
        cQuery += "AND SED.ED_NATREN IS NOT NULL AND SED.ED_NATREN <> ' ' AND SED.ED_CALCIRF = 'S' "
        cQuery += "AND SA1.A1_RECIRRF = '2' AND SE1.D_E_L_E_T_ = ' ' "
        cQuery += "AND SE1.E1_EMISSAO >= ? "
        
        cQuery := ChangeQuery(cQuery)
        __oTitRece := FwPreparedStatement():New(cQuery)
    EndIf    
    
    __oTitRece:SetNumeric(1, RetSqlName("SE1"))
    __oTitRece:SetNumeric(2, RetSqlName("SED"))
    __oTitRece:SetNumeric(3, RetSqlName("SA1"))
    __oTitRece:SetIn(4, aFiliais)
    __oTitRece:SetIn(5, aLstTipo)
    __oTitRece:SetString(6, cDtIni)
    
    cQuery := __oTitRece:GetFixQuery()
    
    If __lFIXQRYR
        cQryNew := cQuery
        cQryNew := ExecBlock("FIXQRYR", .F., .F., {"06", "R", cQryNew})        
        
        If ValType(cQryNew) == "C" .And. !Empty(cQryNew) .And. AllTrim(cQryNew) != AllTrim(cQuery)
            cQuery    := cQryNew 
            cTipoQryP := "C"
        EndIf
    EndIf    
    
    cTblTmp := MpSysOpenQuery(cQuery)

    //Contando os registros e voltando ao topo da query
    nTotal := Contar(cTblTmp,"!Eof()")
    (cTblTmp)->(DbGoTop())    
    DbSelectArea("FKF")
    
    While (cTblTmp)->(!Eof())        
        cIdDocFK7 := FINBuscaFK7((cTblTmp)->(E1_FILIAL+"|"+E1_PREFIXO+"|"+E1_NUM+"|"+E1_PARCELA+"|"+E1_TIPO+"|"+E1_CLIENTE+"|"+E1_LOJA), "SE1", (cTblTmp)->E1_FILORIG)
        
        If Empty(cIdDocFK7)
            (cTblTmp)->(DbSkip())
            Loop
        EndIf
        
        lAchouFKW := FTemFKW(cIdDocFK7)
        
        //Validar a geração da FKW
        If lAchouFKW
            (cTblTmp)->(DbSkip())
            Loop
        EndIf
        
        //Atualiza FKF
        FKF->(DbSetOrder(1))
        lAchouFKF := FKF->(MsSeek(xFilial("FKF", (cTblTmp)->E1_FILORIG)+cIdDocFK7))
        
        IF lAchouFKF
            RecLock("FKF", .F.)
            FKF->FKF_NATREN := (cTblTmp)->ED_NATREN
            FKF->(MsUnLock())
        EndIf
        
        AAdd(aDados, {(cTblTmp)->E1_FILORIG, cIdDocFK7, "IRF", (cTblTmp)->ED_NATREN, 100, (cTblTmp)->E1_BASEIRF, (cTblTmp)->E1_IRRF, 0, 0, "", "", "", 0})
        
        //Gravação do FKW
        If Len(aDados) > 0
            lRetorno := F070Grv(aDados, 4, "2")
        EndIf
        
        If lRetorno
            DbSelectArea("REINFLOG")
            REINFLOG->(DbSetIndex("IND1"))
            lRegNew := REINFLOG->(MsSeek("CR" + cIdDocFK7))
            
            If RecLock("REINFLOG", !lRegNew)
                REINFLOG->GRUPO    := cEmpAnt
                REINFLOG->EMPFIL   := (cTblTmp)->E1_FILIAL
                REINFLOG->DATAPROC := FWTimeStamp(2, DATE(), TIME())
                REINFLOG->TIPO     := "CR"
                REINFLOG->CHAVE    := cIdDocFK7
                REINFLOG->FINFKF   := "U" //U=Update
                REINFLOG->FINFKW   := "I" //I=Insert
                
                If __lCQUERYP 
                    REINFLOG->CQUERYP := cTipoQryP
                EndIf                
                
                REINFLOG->(MsUnlock())
            Endif
        EndIf
        
        (cTblTmp)->(DbSkip())
        aDados := {}    
    EndDo
    
     (cTblTmp)->(DbCloseArea())
Return lRetorno

/*/{Protheus.doc} FinFKYWCP
    Gravação da tabela FKY dos títulos do contas a pagar que sofreram
    baixas após a data de 31/08/2023 sem a confuguração da natureza de rendimento
    
    @param aFiliais, array bidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento de atualização
    da natureza de rendimento do títulos a pagar
/*/
Static Function FinFKYWCP(aFiliais As Array) As Logical    
    Local lRetorno   As Logical
    Local cTblTmp    As Char
    Local cTblFK2    As Char
    Local cTblFKW    As Char
    Local cTblFK7    As Char
    Local cQuery     As Char
    Local cCamposFK7 As Char
    Local cChaveSE2  As Char
    Local cChaveFK4  As Char
    Local cDtIniBx   As Char
    Local cQryNew    As Char
    Local cTipoQryP  As Char    
    Local nTotal     As Numeric    
    Local nCamposFK7 As Numeric
    Local nCampo     As Numeric
    Local nLoop      As Numeric
    Local nBase      As Numeric
    Local nVlImp     As Numeric
    Local nPerc      As Numeric
    Local aDados     As Array
    Local aCamposFK7 As Array

    //Parâmetros de entrada.
    Default aFiliais   := {cFilAnt}
    
    //Inicializa variáveis.
    lRetorno   := .F.
    cTblTmp    := ""
    cTblFK2    := RetSqlName("FK2")
    cTblFKW    := RetSqlName("FKW")
    cTblFK7    := RetSqlName("FK7")
    cQuery     := ""
    cCamposFK7 := "FK7.FK7_CHAVE"
    cChaveSE2  := ""
    cChaveFK4  := ""
    cDtIniBx   := "20230831"
    cQryNew    := ""
    cTipoQryP  := "P"    
    nTotal     := 0
    nCamposFK7 := 0
    nCampo     := 0
    nLoop      := 0
    nBase      := 0
    nVlImp     := 0
    aDados     := {}    
    aCamposFK7 := {}
    aPerc      := {}
    
    If __lFK7Cpos == Nil
        If(__lFK7Cpos := (FK7->(ColumnPos("FK7_CLIFOR")) > 0 .And. FindFunction("FinFK7Cpos") .And. FExecFixN("2")))
            cCamposFK7 := "FK7.FK7_FILTIT, FK7.FK7_PREFIX, FK7.FK7_NUM, FK7.FK7_PARCEL, FK7.FK7_TIPO, FK7.FK7_CLIFOR, FK7.FK7_LOJA"
        EndIf
    EndIf    
    
    __nTamFil  := IIf(__nTamFil == Nil,  TamSX3("E2_FILIAL")[1], __nTamFil)
    __nTamPre  := IIf(__nTamPre == Nil,  TamSX3("E2_PREFIXO")[1], __nTamPre)
    __nTamNum  := IIf(__nTamNum == Nil,  TamSX3("E2_NUM")[1], __nTamNum)
    __nTamParc := IIf(__nTamParc == Nil, TamSX3("E2_PARCELA")[1], __nTamParc)
    __nTamTipo := IIf(__nTamTipo == Nil, TamSX3("E2_TIPO")[1], __nTamTipo)
    __nTamCliF := IIf(__nTamCliF == Nil, TamSX3("E2_FORNECE")[1], __nTamCliF)
    __nTamLoja := IIf(__nTamLoja == Nil, TamSX3("E2_LOJA")[1], __nTamLoja)
    
    If __oBaixaCP == Nil               
        cQuery := "SELECT DISTINCT FK2.FK2_FILIAL, FK2.FK2_IDFK2, FK2.FK2_IDDOC, FK2_NATURE, "
        cQuery += "FK2_FILORI, FK2.FK2_ORIGEM, FK2.FK2_VALOR, FKW.FKW_FILIAL, FKW.FKW_IDDOC, "
        cQuery += "FKW.FKW_NATREN, " + cCamposFK7 + " FROM ? FK2 "
        
        //Relacionamento: (Baixas contas a pagar (FK2) vs Impostos x Natureza Rendimento (FKW))
        cQuery += "INNER JOIN ? FKW ON ("
        cQuery += "FK2.FK2_IDDOC = FKW.FKW_IDDOC "
        cQuery += "AND FK2.D_E_L_E_T_ = FKW.D_E_L_E_T_) "
        
        //Relacionamento: (Impostos x Natureza Rendimento (FKW) vs Tabela Auxiliar (FK7))
        cQuery += "INNER JOIN ? FK7 ON ("
        cQuery += "FKW.FKW_IDDOC = FK7.FK7_IDDOC "
        cQuery += "AND FKW.D_E_L_E_T_ = FK7.D_E_L_E_T_) "
        
        //Filtro de linhas dos registros de baixas
        cQuery += "WHERE "
        cQuery += "FK2.FK2_FILIAL IN (?) "
        cQuery += "AND FK2.FK2_DATA > ? "
        cQuery += "AND FK2.FK2_RECPAG = 'P' "
        cQuery += "AND FK2.D_E_L_E_T_ = ' ' "
        cQuery += "AND FKW.FKW_NATREN IS NOT NULL "
        cQuery += "AND FKW.FKW_NATREN <> ' ' "
        cQuery += "AND FK2.FK2_SEQ NOT IN ("
        cQuery += "SELECT FK2EST.FK2_SEQ FROM ? FK2EST "
        cQuery += "INNER JOIN ? FKWEST ON ("
        cQuery += "FK2EST.FK2_IDDOC = FKWEST.FKW_IDDOC "
        cQuery += "AND FK2EST.D_E_L_E_T_ = FKWEST.D_E_L_E_T_) "                
        cQuery += "INNER JOIN ? FK7EST ON ("
        cQuery += "FKWEST.FKW_IDDOC = FK7EST.FK7_IDDOC "
        cQuery += "AND FKWEST.D_E_L_E_T_ = FK7EST.D_E_L_E_T_) "
        cQuery += "WHERE "
        cQuery += "FK2EST.FK2_FILIAL IN (?) " 
        cQuery += "AND FK2EST.FK2_DATA > ? " 
        cQuery += "AND FK2EST.FK2_RECPAG = 'R' " 
        cQuery += "AND FK2EST.FK2_TPDOC <> 'ES' " 
        cQuery += "AND FK2EST.D_E_L_E_T_ = ' ' "
        cQuery += "AND FKWEST.FKW_NATREN IS NOT NULL "
        cQuery += "AND FKWEST.FKW_NATREN <> ' ') "
        cQuery += "AND FK2.FK2_IDFK2 NOT IN (SELECT FKY.FKY_IDFK2 FROM ? FKY WHERE FKY.D_E_L_E_T_ = ' ') "
        cQuery := ChangeQuery(cQuery)
        __oBaixaCP := FwPreparedStatement():New(cQuery)
    EndIf
    
    __oBaixaCP:SetNumeric(1, cTblFK2)
    __oBaixaCP:SetNumeric(2, cTblFKW)
    __oBaixaCP:SetNumeric(3, cTblFK7)
    __oBaixaCP:SetIn(4, aFiliais)    
    __oBaixaCP:SetString(5, cDtIniBx)
    __oBaixaCP:SetNumeric(6, cTblFK2)
    __oBaixaCP:SetNumeric(7, cTblFKW)
    __oBaixaCP:SetNumeric(8, cTblFK7)
    __oBaixaCP:SetIn(9, aFiliais)
    __oBaixaCP:SetString(10, cDtIniBx)
    __oBaixaCP:SetNumeric(11, RetSqlName("FKY"))    
    
    cQuery  := __oBaixaCP:GetFixQuery()
    
    If __lFIXQRYR
        cQryNew := cQuery
        cQryNew := ExecBlock("FIXQRYR", .F., .F., {"06", "BXP", cQryNew})        
        
        If ValType(cQryNew) == "C" .And. !Empty(cQryNew) .And. AllTrim(cQryNew) != AllTrim(cQuery)
            cQuery    := cQryNew 
            cTipoQryP := "C"
        EndIf
    EndIf    
    
    cTblTmp := MpSysOpenQuery(cQuery)
    
    //Contando os registros e voltando ao topo da query
    nTotal := Contar(cTblTmp,"!Eof()")
    
    DbSelectArea("FK4")
    DbSelectArea("SED")
    DbSelectArea("SE2")
    DbSelectArea("SA2")
    
    SED->(DbSetOrder(1))
    SE2->(DbSetOrder(1))
    SA2->(DbSetOrder(1))
    FK4->(DbSetOrder(2))
    (cTblTmp)->(DbGotop())
    
    While (cTblTmp)->(!Eof())
        aDados    := {}
        cChaveSE2 := ""
        cChaveFK4 := (xFilial("FKY", (cTblTmp)->FK2_FILORI) + (cTblTmp)->FK2_IDFK2)
        
        If __lFK7Cpos 
            cChaveSE2 := (cTblTmp)->(FK7_FILTIT+FK7_PREFIX+FK7_NUM+FK7_PARCEL+FK7_TIPO+FK7_CLIFOR+FK7_LOJA)
        Else
            aCamposFK7 := StrToKarr((cTblTmp)->FK7_CHAVE, "|")
            
            If (nCamposFK7 := Len(aCamposFK7)) > 0
                For nCampo := 1 To nCamposFK7
                    Do Case
                        Case nCampo == 1
                            cChaveSE2 := PadR(aCamposFK7[1], __nTamFil, " ")
                        Case nCampo == 2
                            cChaveSE2 += PadR(aCamposFK7[2], __nTamPre, " ")
                        Case nCampo == 3
                            cChaveSE2 += PadR(aCamposFK7[3], __nTamNum, " ")
                        Case nCampo == 4
                            cChaveSE2 += PadR(aCamposFK7[4], __nTamParc, " ")
                        Case nCampo == 5
                            cChaveSE2 += PadR(aCamposFK7[5], __nTamTipo, " ")
                        Case nCampo == 6
                            cChaveSE2 += PadR(aCamposFK7[6], __nTamCliF, " ")
                        OtherWise
                            cChaveSE2 += PadR(aCamposFK7[1], __nTamLoja, " ")
                    EndCase
                Next nCampo 
            EndIf            
        EndIf
        
        If SE2->(MsSeek(cChaveSE2))        
            If SED->(MsSeek(xFilial("SED", SE2->E2_FILORIG) + SE2->E2_NATUREZ))            
                If SA2->(MsSeek(xFilial("SA2", SE2->E2_FILORIG)+SE2->(E2_FORNECE+E2_LOJA)))                
                    If FK4->(MsSeek(cChaveFK4))
                        While FK4->(FK4_FILIAL+FK4_IDORIG) == cChaveFK4
                            If AllTrim(FK4->FK4_IMPOS) == "IRF" .And. !SA2->A2_CALCIRF $ "2|3|4"
                                FK4->(DbSkip())
                                Loop
                            EndIf
                            
                            nPerc := PercImpNR((cTblTmp)->FKW_IDDOC, (cTblTmp)->FKW_NATREN, FK4->FK4_IMPOS)
                            
                            If nPerc > 0
                                nBase  := (FK4->FK4_BASIMP * nPerc) / 100
                                nVlImp := (FK4->FK4_VALOR * nPerc) / 100                                
                                AAdd(aDados, {(cTblTmp)->FK2_FILIAL, (cTblTmp)->FKW_IDDOC, (cTblTmp)->FK2_IDFK2, "FK4", FK4->FK4_IDFK4, FK4->FK4_IMPOS, (cTblTmp)->FKW_NATREN, nBase, nVlImp, 0, 0, "", "", ""})
                            EndIf
                            
                            FK4->(DbSkip())
                        EndDo
                    ElseIf FSemImp((cTblTmp)->FKW_IDDOC)
                        AAdd(aDados, {(cTblTmp)->FK2_FILIAL, (cTblTmp)->FKW_IDDOC, (cTblTmp)->FK2_IDFK2, "FKW", "", "SEMIMP", (cTblTmp)->FKW_NATREN, (cTblTmp)->FK2_VALOR, 0, 0, 0, "", "", ""})   
                    EndIf
                    
                    //Gravação tabelas FKY
                    If !Empty(aDados)
                        lRetorno := GravaFKY(aDados)
                    EndIf
                    
                    If lRetorno
                        DbSelectArea("REINFLOG")
                        REINFLOG->(DbSetIndex("IND1"))
                        lRegNew := REINFLOG->(MsSeek("BX" + (cTblTmp)->FKW_IDDOC))
                        
                        If RecLock("REINFLOG", !lRegNew)
                            REINFLOG->GRUPO    := cEmpAnt
                            REINFLOG->EMPFIL   := (cTblTmp)->FK2_FILORI
                            REINFLOG->DATAPROC := FWTimeStamp(2, DATE(), TIME())
                            REINFLOG->TIPO     := "BX"
                            REINFLOG->CHAVE    := (cTblTmp)->FK2_IDFK2
                            REINFLOG->FINFKF   := "" //U=Update
                            REINFLOG->FINFKW   := "" //I=Insert
                            
                            If __lCQUERYP 
                                REINFLOG->CQUERYP := cTipoQryP
                            EndIf                            
                            
                            REINFLOG->(MsUnlock())
                        Endif
                    EndIf
                EndIf
            EndIf
        EndIf
        
        (cTblTmp)->(DbSkip())
    EndDo
    
    (cTblTmp)->(DbCloseArea())
    FwFreeArray(aDados)
Return lRetorno

/*/{Protheus.doc} GravaFKY
    Gravação da tabela de Impostos x Nat. Rend. x Baixas (FKY)
    baixas realizadas a partir da data de 01/09/2023
    
    @author Sivaldo Oliveira
    @since 30/08/2023     
    
    @param aDadosFKY, array multidimensional , com os dados que serão utilizados 
    para gerar nova linha na tabela FKY
    
    @return lRetorno, Logical, Retorno lógico que indica se há houve gravação na tabela FKY
/*/
Static Function GravaFKY(aDadosFKY As Array)
	Local lRetorno  As Logical
    Local nLoopFKY  As Numeric
    Local nTotalReg As Numeric
	
    Default aDadosFKY := {}
	
    //Inicializador padrão
    nLoopFKY  := 0
    nTotalReg := Len(aDadosFKY)
    
    If (lRetorno := (nTotalReg > 0))
        For nLoopFKY := 1 To nTotalReg        
            RecLock("FKY", .T.)
            FKY->FKY_FILIAL := aDadosFKY[nLoopFKY, 01]
            FKY->FKY_IDFKY  := FWUUIDV4()
            FKY->FKY_IDDOC  := aDadosFKY[nLoopFKY, 02]
            FKY->FKY_IDFK2  := aDadosFKY[nLoopFKY, 03]
            FKY->FKY_TABORI := aDadosFKY[nLoopFKY, 04]
            FKY->FKY_IDORIG := aDadosFKY[nLoopFKY, 05]
            FKY->FKY_TPIMP  := aDadosFKY[nLoopFKY, 06]
            FKY->FKY_NATREN := aDadosFKY[nLoopFKY, 07]
            FKY->FKY_BASETR := aDadosFKY[nLoopFKY, 08]
            FKY->FKY_VLIMP  := aDadosFKY[nLoopFKY, 09]
            FKY->FKY_BASENR := aDadosFKY[nLoopFKY, 10]
            FKY->FKY_VLIMPN := aDadosFKY[nLoopFKY, 11]
            FKY->FKY_NUMPRO := aDadosFKY[nLoopFKY, 12]
            FKY->FKY_TPPROC := aDadosFKY[nLoopFKY, 13]
            FKY->FKY_CODSUS := aDadosFKY[nLoopFKY, 14]
            FKY->(MsUnLock())
        Next nLoopFKY
    EndIf
Return lRetorno

/*/{Protheus.doc} FSemImp
    Verifica se o titulo possui registro(s) na tabela FKW sem calculo
    de impostos (FKW_TPIMP=SEMIMP)
    
    @param cIdTit, Character, Chave do titulo (FK7_IDDOC)
    @return lRet, logical, retorna .T. se encontrar registros do titulo na FKW
/*/
Static Function FSemImp(cIdTit As Character) As Logical
    Local lRet   As Logical
    Local cQuery As Character
    Local cTpFkw As Character
    
    //Parâmetros de entrada
    Default cIdTit := ""
    
    //Inicializa variáveis
    lRet    := .F.
    cQuery  := ""
	cSemImp := PadR("SEMIMP", __nFkwImp)
    
    If __oSemImp == Nil
        cQuery := "SELECT FKW_TPIMP TPIMP FROM ? "
        cQuery += "WHERE FKW_IDDOC = ? "
        cQuery += "AND FKW_TPIMP = ? "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        __oSemImp := FWPreparedStatement():New(cQuery)
    Endif
    
    __oSemImp:SetNumeric(1, RetSqlName("FKW"))
    __oSemImp:SetString(2, cIdTit)
    __oSemImp:SetString(3, cSemImp)
    
    cQuery := __oSemImp:GetFixQuery()
    cTpFkw := MpSysExecScalar(cQuery,"TPIMP")
    
    lRet := !Empty(cTpFkw)
Return lRet

/*/{Protheus.doc} PercImpNR
    Verifica o percentual de rateio do Imposto x Natureza de Rendimento
    para o título.
    
    @param cIdTit, Char, Identificador de inclusão do título (FK7_IDDOC)
    @param cNatRen, Char, Código da natureza de rendimento
    @param cImpos, Char, Tipo de imposto (PIS, COF, CSL, IRF)
    @return nRet, Numeric, Somatório com o valor total de imposto

    @author Fabio Casagrande
    @since 30/08/2023    
/*/
Static Function PercImpNR(cIdTit As Char, cNatRen As Char, cImpos As Char) As Numeric
    Local nRet   As Numeric
    Local cQuery As Character
    
    Default cIdTit  := ""
    Default cNatRen := ""
    Default cImpos  := ""
    
    //Inicializa variáveis
    nRet    := 0
    cQuery  := ""    
    
    If __oImpNR == Nil
        cQuery := "SELECT FKW_PERC FROM ? "
        cQuery += "WHERE FKW_IDDOC = ? "
        cQuery += "AND FKW_TPIMP = ? "
        cQuery += "AND FKW_NATREN = ? "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        __oImpNR := FWPreparedStatement():New(cQuery)
    Endif
    
    __oImpNR:SetNumeric(1, RetSqlName("FKW"))
    __oImpNR:SetString(2, cIdTit)
    __oImpNR:SetString(3, cImpos)
    __oImpNR:SetString(4, cNatRen)
    cQuery := __oImpNR:GetFixQuery()
    
    nRet := MpSysExecScalar(cQuery,"FKW_PERC")
Return nRet
