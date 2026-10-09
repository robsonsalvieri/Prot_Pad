#Include "PROTHEUS.CH"
#Include "PRTOPDEF.CH"
#Include "TOPCONN.CH"
#Include "FINXGES.CH"

//////////////////////////////////////////
//  DEFINES para a gestão de procedures //
//////////////////////////////////////////
#DEFINE DEF_SPS_FROM_TPH                "0" // o pacote ZSPS será obtido a partir da Central de Atualizações
#DEFINE DEF_SPS_FROM_RPO                "1" // o pacote ZSPS será obtido a partir do RPO
#DEFINE DEF_SPS_FROM_DB                 "2" // obtém os dados do processo já instalado no ambiente

#DEFINE DEF_SPS_INSTALL                 "1" // ação de INSTALAÇÃO de pacotes
#DEFINE DEF_SPS_UNINSTALL               "2" // ação de DESINSTALAÇÃO de pacotes

#DEFINE DEF_SPS_UPDATED                 "0" // status é ATUALIZADO
#DEFINE DEF_SPS_OUTDATED                "1" // status é DESATUALIZADO
#DEFINE DEF_SPS_NOT_INSTALLED           "2" // status é NÃO INSTALADO
#DEFINE DEF_SPS_NOT_RATED               "3" // status é NÃO AVALIADO
#DEFINE DEF_SPS_USER_TEST               "4" // status é TESTE
#DEFINE DEF_SPS_NOT_COMPATIBLE          "5" // status é NÃO COMPATÍVEL
#DEFINE DEF_SPS_PRIME                   "6" // status é [EMERGENCIAL]
#DEFINE DEF_SPS_INNOVATION              "7" // status é [PILOTO]

Static __cLockNm As Character
Static __cFIN006 As Character
Static __cFIN007 As Character
Static __cFIN008 As Character
Static __cFIN009 As Character
Static __cFIN010 As Character
Static __lTemLog As Logical
Static __oQrySE1 As Object
Static __oQrySE2 As Object
Static __oF7JAls As Object

/*/{Protheus.doc} FINXGES

    Rotina de JOB no schedule para chamada das procedures

    @type  Function
    @author victor.azevedo@totvs.com.br
    @since 28/02/2025
    @version 1.0    

    @param cGrpEmp, Character, Grupo de empresa a ser processada
    @param lFullLoad, Logical, Indica se realiza carga full (utilizado para automação)
    @param lReproc, Logical, Indica se realiza o reprocessamento de determinada procedure
    @param cProcExec, Character, Procedure a ser executada (utilizado para automação)
    @param lAutomato, Logical, Indica se a execução está sendo realizada por automação
    @param cDataIni, Character, Data inicial para filtro de processamento (utilizado para automação)
    @param cDataFim, Character, Data final para filtro de processamento (utilizado para automação)
    @param cIdTenant, Character, Identificador do tenant para execução via automação    
    
    @return Nil

/*/
Function FINXGES(cGrpEmp As Character, lFullLoad As Logical, lReproc As Logical, cProcExec As Character, lAutomato As Logical, cDataIni As Character, cDataFim As Character, cIdTenant as Character)

    Local aProcedure As Array
    Local cEmpProc   As Character
    Local cStartTime As Character
    Local cProcGesp  As Character
    Local cIdOrigem  As Character
    Local cLtProcess As Character
    Local cLockName  As Character
    Local dIniCFull  As Date
    Local dAteFull   As Date
    Local dFimCFull  As Date
    Local dCorte     As Date
    Local lExistProc As Logical
    Local lRet       As Logical
    Local lCargaFull As Logical
    Local lLockFull  As Logical
    Local lProcFull  As Logical
    Local nY         As Numeric  
    Local lCheck     As Logical
    Local nQtdMonth  As Numeric
    Local nTamLote   As Numeric
    Local nPeriodo   As Numeric
    Local cTenantId  As Character
    Local cIdProc    As Character

    Default cGrpEmp    := ""
    Default lFullLoad  := .F.
    Default lReproc    := .F.
    Default lAutomato  := .F.
    Default cProcExec  := ""
    Default cDataIni   := ""
    Default cDataFim   := ""
    Default cIdTenant  := ""
    
    RpcSetType(3)
    RpcSetEnv(cGrpEmp,,,,,,)
    
    IniStatic()
    ChkFileGes()

    If !VldProced()
        FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0012 ) //"Falha na validacao/instalacao automatica dos processos 33, 39 e 40.")
        Return
    EndIf

    aProcedure  := {} 
    cEmpProc    := ""
    cStartTime  := ""
    cLockName   := ""
    cProcGesp   := GetMv("MV_GESPROC")  
    cIdOrigem   := FWUUIDV4()
    lExistProc  := .F.
    lRet        := .T.
    lCargaFull  := .F.
    lProcFull   := .F.
    lLockFull   := .F.
    nY          := 1
    nTamLote    := TamSX3("F7P_LOTE")[1]
    cLtProcess  := Soma1(Replicate("0", nTamLote))
    nQtdMonth   := SuperGetMv("MV_GESMESF", .F., 24)
    cTenantId   := ""
    cIdProc     := ""
    dCorte      := FirstDay(MonthSub(Date(), nQtdMonth))
    dIniCFull   := dCorte

    // Obtém configuração do tipo de processo e monta a lista de procedures a executar.
    If !lAutomato
        If Empty(cProcGesp)
            cProcGesp := "CP;CR;MB"
        EndIf

        If "CR" $ cProcGesp
            AAdd(aProcedure, __cFIN006)
            AAdd(aProcedure, __cFIN008)
        EndIf

        If "CP" $ cProcGesp
            AAdd(aProcedure, __cFIN007)
            AAdd(aProcedure, __cFIN009)
        EndIf

        If "MB" $ cProcGesp
            AAdd(aProcedure, __cFIN010)
        EndIf
    Else
        AAdd(aProcedure, cProcExec)
    EndIf

    // Valida a existência apenas das procedures selecionadas
    For nY := 1 To Len(aProcedure)
        cIdProc := GetProcSignature(aProcedure[nY])
        lExistProc := !Empty(cIdProc) .And. ExistProc(aProcedure[nY], cIdProc)

        If !lExistProc
            Exit
        EndIf
    Next nY

    If Empty(cIdTenant)
    	GesplanCon(@cTenantId)
    Else
        cTenantId := cIdTenant
    EndIf

    If cTenantId == Nil .Or. Empty(AllTrim(cTenantId))
        FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "TENANT", STR0005 + ' ' + cEmpAnt) // TenantId Carol não informado (tenantIdCarol). Processo de execução das procedures interrompido.
        Return
    EndIf

    If (AliasIndic("F7I") .And. AliasIndic("F7N") .And. AliasIndic("F7O") .And. AliasIndic("F7J"))
        If !lExistProc
            FwLogMsg("ERROR",, "FINXGES", "FINXGES", "", "Procedures", STR0004 + ' ' + cEmpAnt ) //Procedures nao instaladas, favor verificar.)
            Return
        EndIf

        // Valida se alguma procedure selecionada exige carga full para definir a chave do lock.
        lLockFull := .F.
        For nY := 1 To Len(aProcedure)
            Do Case
                Case aProcedure[nY] == __cFIN006 .And. "CR" $ cProcGesp
                    lLockFull := !HasF7JAlias("CRP")
                Case aProcedure[nY] == __cFIN007 .And. "CP" $ cProcGesp
                    lLockFull := !HasF7JAlias("CPP")
                Case aProcedure[nY] == __cFIN008 .And. "CR" $ cProcGesp
                    lLockFull := !HasF7JAlias("CRR")
                Case aProcedure[nY] == __cFIN009 .And. "CP" $ cProcGesp
                    lLockFull := !HasF7JAlias("CPR")
                Case aProcedure[nY] == __cFIN010 .And. "MB" $ cProcGesp
                    lLockFull := !HasF7JAlias("MVB")
            EndCase

            If lLockFull
                Exit
            EndIf
        Next nY

        If lLockFull
            cLockName := __cLockNm
        Else
            cLockName := __cLockNm + "_" + cEmpAnt
        EndIf

        If LockByName(cLockName, .F./*lEmpresa*/, .F./*lFilial*/ )
            If __lTemLog
                cStartTime := Time()
                FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "START", __cLockNm + " started at : "+ FWTimeStamp(2, DATE(), TIME()) + ' ' + cEmpAnt)
            EndIf

            If !lAutomato .And. Empty(cGrpEmp)
                cEmpProc := BscGrpEmpr()

                If Empty(cEmpProc)
                    FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", cEmpAnt + " Procedures", STR0001) //Nao existe grupo de empresas configurado para processamento.
                    lRet    := .F.
                EndIf
            Else
                cEmpProc := AllTrim(cGrpEmp)
            EndIf
            
            If lRet .And. lExistProc .And. !Empty(cEmpProc)
                If !lAutomato
                    For nY := 1 to Len(aProcedure)
                        lProcFull  := .F.
                        lCargaFull := .F.
                        nPeriodo   := 0

                        GetProcExecCfg(aProcedure[nY], cProcGesp, @lProcFull, @lCargaFull, @nPeriodo, @dIniCFull, dCorte)

                        If (lProcFull .Or. lCargaFull) .And. cLtProcess > Soma1(Replicate("0", nTamLote))
                            cLtProcess  := Soma1(Replicate("0", nTamLote))
                        EndIf
                    
                        If lCargaFull
                            dFimCFull  := Date()
                            dAteFull   := dIniCFull + nPeriodo
                            lCheck     := .T.

                            Do While dFimCFull >= dAteFull .And. lCheck
                                lCheck := !(dAteFull == dFimCFull)
                                
                                ExecProced(aProcedure[nY], cEmpProc, .T., lReproc, DToS(dIniCFull), DToS(dAteFull), cIdOrigem, cLtProcess, cTenantId, DToS(dCorte))
                                
                                cLtProcess := Soma1(cLtProcess)
                                
                                If aProcedure[nY] == __cFIN006
									dIniCFull := MinOpenSE1(dAteFull)
								ElseIf aProcedure[nY] == __cFIN007
									dIniCFull := MinOpenSE2(dAteFull)
								Else
									dIniCFull  := dAteFull + 1
								EndIf
								
                                dAteFull   := dIniCFull + nPeriodo
                                
                                If dAteFull > dFimCFull
                                    dAteFull := dFimCFull
                                EndIf
                            Enddo                                
                        Else
                            ExecProced(aProcedure[nY], cEmpProc, lProcFull, lReproc, cDataIni, cDataFim, cIdOrigem, cLtProcess, cTenantId, DToS(dCorte))
                        Endif
                    Next nY
                Else
                    ExecProced(cProcExec, cEmpProc, lFullLoad, lReproc, cDataIni, cDataFim, cIdOrigem, cLtProcess, cTenantId, DToS(dCorte))
                EndIf
            EndIf

            If __lTemLog
                FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "FINISH", __cLockNm + " ended at : "+ FWTimeStamp(2, DATE(), TIME()) + ' ' + cEmpAnt )
                FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "ELAPSED", __cLockNm + " elapsed time : "+ ElapTime(cStartTime, Time()) + ' ' + cEmpAnt )
            EndIf

            UnLockByName(cLockName, .F./*lEmpresa*/, .F./*lFilial*/ )
        Else
            FwLogMsg('INFO',, "FINXGES", "FINXGES", "", 'cLockName', "["+ cLockName + "] Running on another thread " + cEmpAnt )
        EndIf
    Else
        FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0002 + ' - ' + cEmpAnt) //Dicionário de dados incompatível, realize atualização do sistema.
    EndIf

    If __oQrySE1 <> Nil
        __oQrySE1:Destroy()
        __oQrySE1 := Nil
    EndIf

    If __oQrySE2 <> Nil
        __oQrySE2:Destroy()
        __oQrySE2 := Nil
    EndIf

    If __oF7JAls <> Nil
        __oF7JAls:Destroy()
        __oF7JAls := Nil
    EndIf

    FwFreeArray(aProcedure)
Return

/*/{Protheus.doc} ExecProced

    Realiza execução das procedures.

    @type Function
    @author victor.azevedo@totvs.com.br
    @since 05/03/2025    

    @param cProcedure, Character, Procedure a ser executada
    @param cEmpProc, Character, Empresa a ser processada
    @param lProcFull, Logical, Indica se realiza o processamento full das procedures
    @param lReprocess, Logical, Indica se realiza o reprocessamento de determinada procedure
    @param cDataIni, Character, Data inicial para filtro de processamento (utilizado para automação)
    @param cDataFim, Character, Data final para filtro de processamento (utilizado para automação)
    @param cIdOrig, Character, Identificador da execução (origem) para rastreabilidade
    @param cLoteProc, Character, Lote de processamento
    @param cTenantId, Character, Identificador do tenant
    @param cCorte, Character, Data de corte para processamento

    @return Nil

/*/
Function ExecProced(cProcedure as Character, cEmpProc as Character, lProcFull as Logical, lReprocess as Logical, cDataIni as Character, cDataFim as Character, cIdOrig as Character, cLoteProc as Character, cTenantId as Character, cCorte as Character)
    
    Local aResult    As Array
    Local aTables    As Array
    Local aSizes     As Array
    Local aParams    As Array
    Local cProcFull  As Character
    Local cCartD     As Character
    Local cSpace     As Character
    Local cStartTime As Character
    Local cMsgInfo   As Character
    Local cMvGesLot  As Character
    Local cInTransct As Character
    Local lCartDesc  As Logical
    Local nDecCNVBS  As Numeric
    
    Default cProcedure  := " "
    Default cEmpProc    := " "
    Default lProcFull   := .F.
    Default lReprocess  := .F.
    Default cDataIni    := " "
    Default cDataFim    := " "
    Default cIdOrig     := " "
    Default cLoteProc   := Soma1(Replicate("0", TamSX3("F7P_LOTE")[1]))
    Default cTenantId   := " "
    Default cCorte      := DToS(Date())

    aResult     := {}
    aTables     := {}
    aParams     := {}
    cProcFull   := "N"
    cCartD      := "N"
    cSpace      := Space(1)
    cMsgInfo    := ""
    cInTransct  := "1"
    lCartDesc   := SuperGetMv('MV_GZ0DSC ', .F., .F. ) 
    cMvGesLot   := SuperGetMv('MV_GESLOTR', .F., "2" )
    nDecCNVBS   := TamSx3("F7I_CONVBS")[2]

    If lProcFull
        cProcFull := "S"
    EndIf

    If lCartDesc
        cCartD := "S"
    EndIf
    
    //Executa para cada filial do grupo de empresa enviado
    If !Empty(cProcedure)

        If __lTemLog
            cStartTime := Time()
            cMsgInfo := __cLockNm + " - " + cProcedure + "_" + cEmpProc
            FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "START", cMsgInfo + " started at : "+ FWTimeStamp(2, DATE(), TIME()))
        EndIf

        If !Intransact()
            cInTransct := "0"
        EndIf
        
        /*
            Estrutura do array aSizes:
            aSizes[1,1] = Nome da tabela;
            aSizes[1,2] = Tamanho total do modo de acesso da tabela (empresa, unidade de negócio e filial);
            aSizes[1,3] = Tamanho do modo de acesso da tabela (empresa);
            aSizes[1,4] = Tamanho do modo de acesso da tabela (unidade de negócio);
            aSizes[1,5] = Tamanho do modo de acesso da tabela (filial);
        */
        
        // Monta os parâmetros conforme o procedimento
        Do Case
            Case cProcedure $ "FIN006_33"
                aTables := {"SE1", "SED", "CT1", "SX5", "SA1", "FRV"}
                aSizes  := TablesSize(aTables)
                
                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], ;
                    aSizes[5,2], aSizes[6,2], aSizes[1,2], cEmpProc, cSpace, cSpace, cSpace , ;
                    cTenantId, cDataIni, cDataFim, cProcFull, cCartD, cInTransct, nDecCNVBS, cIdOrig, cLoteProc, cCorte}

                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], ;
                    aParams[10], aParams[11], aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], ;
                    aParams[17], aParams[18], aParams[19], aParams[20], aParams[21], aParams[22], aParams[23], aParams[24])

            Case cProcedure $ "FIN007_39"
                aTables := ({"SE2", "SED", "CT1", "SX5", "SA2"})
                aSizes  := TablesSize(aTables)
                
                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], ;
                    aSizes[5,2], cEmpProc, cSpace, cSpace, cSpace, cTenantId, cDataIni, ;
                    cDataFim, cProcFull, cInTransct, nDecCNVBS, cIdOrig, cLoteProc, cCorte}
                
                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], ;
                    aParams[10], aParams[11], aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], ;
                    aParams[17], aParams[18], aParams[19], aParams[20], aParams[21])

            Case cProcedure $ "FIN008_33"
                aTables     := ({"SE1", "SED", "SX5", "SA1", "SEV"})
                aSizes      := TablesSize(aTables)

                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], aSizes[5,2], ;
                    cEmpProc, cTenantId, cDataIni, cDataFim, cProcFull,  ;
                    cInTransct, nDecCNVBS, cMvGesLot, cIdOrig, cLoteProc}
                
                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], ;
                    aParams[10], aParams[11], aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], ;
                    aParams[17], aParams[18]) 

            Case cProcedure $ "FIN009_39"
                aTables     := ({"SE2", "SED", "SX5", "SA2", "SEV"})
                aSizes      := TablesSize(aTables)

                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], ;
                    aSizes[5,2], cEmpProc, cSpace, cSpace, cSpace, cTenantId, cDataIni, cDataFim, ; 
                    cProcFull, cInTransct, nDecCNVBS, cIdOrig, cLoteProc}

                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], ;
                    aParams[10], aParams[11], aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], ;
                    aParams[17], aParams[18], aParams[19], aParams[20])

            Case cProcedure $ "FIN010_40"
                aTables     := ({"FK5", "SA6"})
                aSizes      := TablesSize(aTables)

                aParams := { cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], ;
                    cEmpProc, cDataIni, cDataFim, cSpace, cSpace, cSpace, cProcFull, ;
                    cMvGesLot, cInTransct, cIdOrig, cLoteProc}

                If __lTemLog
                    LogProcs(aParams)
                EndIf
                
                aResult :=  TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], ;
                    aParams[10], aParams[11], aParams[12], aParams[13], aParams[14], aParams[15], aParams[16] ) 
        EndCase

        // Tratamento de erro
        If Empty(aResult) .Or. aResult[1] = "0"
            FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "SPERROR", STR0003 + " " + cProcedure + "_" + cEmpProc + " " + TCSQLError()) //P33 - Erro na chamada do processo -
        EndIf

        If __lTemLog
            FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "FINISH", cMsgInfo + " ended at : "+ FWTimeStamp(2, DATE(), TIME()))
            FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "ELAPSED", cMsgInfo + " elapsed time : "+ ElapTime(cStartTime, Time()) )
        EndIf

    EndIf
Return

/*/{Protheus.doc}  VerIDProc
	Identifica a assinaturas das stored procedure. 
	Procedures FIN006,FIN007,FIN008,FIN009 e FIN010
	Processos 33, 39, 40 - Integração Protheus x Gesplan
	@type  StaticFunction
	@author victor.azevedo@totvs.com.br
	@since 14/02/2025
    @return character, Retorna a assinatura da rotina
/*/      
Static Function VerIDProc(cProcess as Character, cProcedure as Character) As Character

    Local cIdProc As Character

    Default cProcess   := ""
    Default cProcedure := ""

    cIdProc := ""

    If cProcedure $ "FIN006_33|FIN008_33" .Or. cProcess $ "33"
        cIdProc := "005"
    ElseIf cProcedure $ "FIN007_39|FIN009_39" .Or. cProcess $ "39"
        cIdProc := "002"
    ElseIf cProcedure $ "FIN010_40" .Or. cProcess $ "40"
        cIdProc := "002"
    EndIf

Return cIdProc

/*/{Protheus.doc} GetProcSignature
    Retorna a assinatura do processo conforme a procedure informada.

    @type  StaticFunction
    @author victor.azevedo@totvs.com.br
    @since 07/05/2026
    @param cProcedure, Character, Procedure a ser validada
    @return Character, Assinatura do processo
/*/
Static Function GetProcSignature(cProcedure As Character) As Character

    Local cIdProc As Character

    Default cProcedure := ""

    cIdProc := VerIDProc(Nil,cProcedure)

Return cIdProc

/*/{Protheus.doc} GetProcExecCfg
    Retorna a configuração de execução da procedure informada.

    @type  StaticFunction
    @author victor.azevedo@totvs.com.br
    @since 07/05/2026
    @param cProcedure, Character, Procedure a ser processada
    @param cProcGesp, Character, Tipos de processo habilitados
    @param lProcFull, Logical, Indica se a execução deve ser full por procedure
    @param lCargaFull, Logical, Indica se a execução deve ser em carga full por período
    @param nPeriodo, Numeric, Quantidade de dias por lote de carga full
    @return Nil
/*/
Static Function GetProcExecCfg(cProcedure As Character, cProcGesp As Character, lProcFull As Logical, lCargaFull As Logical, nPeriodo As Numeric, dIniCFull As Date, dCorte As Date)

    Default cProcedure := ""
    Default cProcGesp := ""
    Default lProcFull := .F.
    Default lCargaFull := .F.
    Default nPeriodo := 0
    Default dIniCFull := Date()
    Default dCorte := Date()

    Do Case
        Case cProcedure == __cFIN006 .And. "CR" $ cProcGesp
            lCargaFull  := !HasF7JAlias("CRP")
            dIniCFull   := MinOpenSE1(SToD('01/01/1999'))
            nPeriodo    := 30
        Case cProcedure == __cFIN007 .And. "CP" $ cProcGesp
            lCargaFull  := !HasF7JAlias("CPP")
            dIniCFull   := MinOpenSE2(SToD('01/01/1999'))
            nPeriodo    := 30
        Case cProcedure == __cFIN008 .And. "CR" $ cProcGesp
            lCargaFull  := !HasF7JAlias("CRR")
            dIniCFull   := dCorte
            nPeriodo    := 5
        Case cProcedure == __cFIN009 .And. "CP" $ cProcGesp
            lCargaFull  := !HasF7JAlias("CPR")
            dIniCFull   := dCorte
            nPeriodo    := 5
        Case cProcedure == __cFIN010 .And. "MB" $ cProcGesp
            lProcFull   := !HasF7JAlias("MVB")
    EndCase

Return

/*/{Protheus.doc} HasF7JAlias
    Verifica se existe registro ativo (nao deletado logicamente) na F7J para o alias informado.

    @type  StaticFunction
    @author victor.azevedo@totvs.com.br
    @since 03/06/2026
    @param cAlias, Character, Alias da F7J a ser validado
    @return Logical, .T. se houver registro ativo para o alias
/*/
Static Function HasF7JAlias(cAlias As Character) As Logical
    Local lFound    As Logical
    Local cQry      As Character
    Local cSpace    As Character

    Default cAlias := ""

    lFound  := .F.
    cQry    := ""
    cSpace  := Space(1)

    If __oF7JAls == Nil
        cQry += " SELECT F7J_RECNO "
        cQry += " FROM " + RetSqlName("F7J")
        cQry += " WHERE F7J_ALIAS = ? "
        cQry += " AND D_E_L_E_T_ = ? "

        cQry := ChangeQuery(cQry)
        __oF7JAls := FwExecStatement():New(cQry)
    EndIf

    __oF7JAls:SetString(1, cAlias)
    __oF7JAls:SetString(2, cSpace)

    lFound  := __oF7JAls:ExecScalar("F7J_RECNO") > 0

Return lFound

/*/{Protheus.doc}  BscGrpEmpr
	Busca os grupos de empresas que foram executados no wizard para configuração das procedures
	@type  StaticFunction
	@author TOTVS
	@since 14/02/2025
    @return character, Retorna os Grupos de Empresas que foram configurados
/*/ 
Static Function BscGrpEmpr() as Character

    Local cRet      As Character
    Local cQry      As Character
    Local cCompany  As Character
    Local cSpace    As Character
    Local cTblTmp   As Character
    Local oQuery    As Object

    cRet      := ""
    cQry      := ""
    cTblTmp   := ""
    cCompany  := "FWCarolCompany" + cEmpAnt
    cSpace    := Space(1)

    cQry := "SELECT "    
    cQry += "APP_PARAM as COMPANY "
    cQry += "FROM SYS_APP_PARAM "
    cQry += "WHERE "
    cQry += "APP_PARAM = ? "
    cQry += "AND D_E_L_E_T_ = ?"

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)
    
    oQuery:SetString(1, cCompany)
    oQuery:SetString(2, cSpace)
    
    cTblTmp := oQuery:OpenAlias()

    If !(cTblTmp)->(Eof())
        cRet :=  RIGHT(Trim(((cTblTmp)->COMPANY)),2)
    EndIf
    
    (cTblTmp)->(DbCloseArea())
    cTblTmp := ""

    If oQuery <> Nil
        oQuery:Destroy()
        oQuery := Nil
    EndIf

Return cRet

/*/{Protheus.doc} GesplanCon
    Obtém o TenantId da Gesplan/Carol para parametrizar a execução das procedures.
    
    @type  StaticFunction
    @author victor.azevedo@totvs.com.br
	@since 05/03/2025   
    @param cTenantId, Character, TenantId para conexão (retornado por referência)
    @return Nil
/*/
Static Function GesplanCon(cTenant As Character)
    
    Local oConfig  As JSon
    
    //Parâmetros de entrada da função
    Default cTenant   := ""
    
    If (FindFunction('FwTechFinVersion') .and. FwTechFinVersion() >= '2.6.1')
        // retorna o Tenant Interno, ou seja, o conteúdo do APP_PARAM "tenantIdCarol"
        cTenant := TFConfiguration():getTenantIdCarol()
    Else
        //Inicializa variáveis
        oConfig  := FwTFConfig()
        
        If !(oConfig == Nil)
            If cTenant != Nil
                cTenant := AllTrim(oConfig["gesplan-mdmTenantId"])
            EndIf

            FreeObj(oConfig)
        EndIf
    EndIf    
Return 

/*/{Protheus.doc} IniStatic
    Inicializa variáveis static

    @type StaticFunction
    @author victor.azevedo@totvs.com.br
    @since 05/03/2025
    @version P12
/*/
Static Function IniStatic()
	
    __cLockNm := "FINXGES"
    __cFIN006 := GetSPName("FIN006","33")
    __cFIN008 := GetSPName("FIN008","33")
    __cFIN007 := GetSPName("FIN007","39")
    __cFIN009 := GetSPName("FIN009","39")
    __cFIN010 := GetSPName("FIN010","40")
    __lTemLog := SuperGetMv( 'MV_GESLOG ', .F., .F. )

Return

/*/{Protheus.doc} SchedDef
    Função que permite ao frame fazer a preparação do
    ambiente de execuçãodo schedule.

    @type StaticFunction
    @author victor.azevedo@totvs.com.br
    @since 28/02/2025
    @return aParam, vetor de 8 posições.
/*/
Static Function SchedDef()
    Local aParam As Array

    aParam := {"P", "", Nil, Nil, Nil, Nil, .T., .F.}

Return aParam

/*/{Protheus.doc} EngSPS33Signature
    Ponto de Entrada que retorna a assinatura do processo 33

    @type  Function
    @return character, Assinatura
    @author  TOTVS
    @version 12
/*/
Function EngSPS33Signature(cProcess as character) As Character

    Local cAssinatura as character

    cAssinatura := VerIDProc(cProcess)

Return cAssinatura

/*/{Protheus.doc} EngPre33Compile
    Ponto de entrada que será executado antes da compilação das procedures no RPO
    .
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPre33Compile(cProcesso as character, cEmpresa as character, cError as character) As Logical

Return ValidatePreCompile(cEmpresa, @cError)

/*/{Protheus.doc} EngOn33Compile
    Ponto de Entrada responsável por fazer a adaptação do código original do processo 33, 
    substituindo as tags '###' dentro dos arquivos .SQL pela correta regra de negócio.

    Executado durante a compilação das procedures, para cada procedure é feita a substituição das tags de acordo com a regra de negócio definida para cada uma delas
    .
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngOn33Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character) As Logical
    
    ApplyCommonOnCompile(cEmpresa, @cBuffer)
	
    If AliasIndic("F7O")
        Do Case
            Case cProcName $ 'FIN006|FIN006A|FIN006B'
                FlexField(@cBuffer,'2',"F7I")
            Case cProcName $ "FIN008|FIN008A|FIN008B|FIN008C|FIN008D|FIN008E"
                FlexField(@cBuffer,'4',"F7I")
        End Case
    EndIf

Return .T.

/*/{Protheus.doc} EngPos33Compile
    
    Ponto de Entrada responsável por fazer ajustes no código já adaptado ao tipo de banco de dados em uso. 
    Ajustes só podem ser realizados após a função MsParse traduzir o script original para a linguagem do banco que está sendo utilizado.
    Permite fazer ajustes específicos para cada banco de dados, caso necessário

    Executado após compilação das procedures de um determinado processo pela MsParse. Será executado para cada procedure do processo.    
    .
    @type  Function
    @return logical, Realizado a compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPos33Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character) As Logical
    
    Local cVariaIn        As Character
    Local cHashMSSQL      As Character
    Local cHashOracl      As Character
    Local cHashPostg      As Character
    Local cCteAbatSE1     As Character
    Local cTableSE1       As Character

    Default cProcesso := ""
    Default cEmpresa  := ""
    Default cProcName := ""
    Default cLocalDB  := ""
    Default cBuffer   := ""
    Default cError    := ""

    cTableSE1 := RetSqlName("SE1")
    cProcName := AllTrim(cProcName)
    cLocalDB  := AllTrim(cLocalDB)
    cBuffer   := StrTran( cBuffer, "121", '127' )
    cVariaIn  := "@"
    
    If  cLocalDB $ "ORACLE|POSTGRES"
        cVariaIn := "v"
    EndIf

    If cProcName $ 'FIN006A|FIN006B'
        //CTE SE1 Abatimentos
        cHashMSSQL := "LOWER(CONVERT(VARCHAR(32), HASHBYTES( 'MD5', CONCAT( TRIM(" + cVariaIn + "IN_mdmTenantId), RTRIM(" + cVariaIn + "IN_GROUPEMPRESA) + '|' + RTRIM(se1.E1_FILIAL) + '|' + RTRIM(se1.E1_PREFIXO) + '|' + RTRIM(se1.E1_NUM) + '|' + RTRIM(se1.E1_PARCELA) + '|' + RTRIM(se1.E1_TIPO), se1.E1_FILORIG)), 2))"
        cHashOracl := "LOWER(STANDARD_HASH( TRIM(IN_mdmTenantId) || RTRIM(IN_GROUPEMPRESA) || '|' || RTRIM(se1.E1_FILIAL) || '|' || RTRIM(se1.E1_PREFIXO) || '|' || RTRIM(se1.E1_NUM) || '|' || RTRIM(se1.E1_PARCELA) || '|' || RTRIM(se1.E1_TIPO) || se1.E1_FILORIG, 'MD5'))"
        cHashPostg := "LOWER(md5(TRIM(IN_mdmTenantId) || RTRIM(IN_GROUPEMPRESA) || '|' || RTRIM(se1.E1_FILIAL) || '|' || RTRIM(se1.E1_PREFIXO) || '|' || RTRIM(se1.E1_NUM) || '|' || RTRIM(se1.E1_PARCELA) || '|' || RTRIM(se1.E1_TIPO) || se1.E1_FILORIG))"

        cCteAbatSE1 := " WITH se1_abatimentos as ( " + CHR(13)+CHR(10)
        cCteAbatSE1 += "   SELECT E1_FILIAL, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, SUM(E1_VALOR) AS ABAT " + CHR(13)+CHR(10)
        cCteAbatSE1 += "   FROM " + cTableSE1 + " se1_abatimentos " + CHR(13)+CHR(10)
        cCteAbatSE1 += "   WHERE se1_abatimentos.E1_TIPO like '%-' " + CHR(13)+CHR(10)
        cCteAbatSE1 += "   AND se1_abatimentos.E1_EMISSAO >= " + cVariaIn + "param_DTINI " + CHR(13)+CHR(10) 
        cCteAbatSE1 += "   AND se1_abatimentos.D_E_L_E_T_ = " +cVariaIn+"IS_SPACE" + CHR(13)+CHR(10)
        cCteAbatSE1 += "   GROUP BY E1_FILIAL, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA " + CHR(13)+CHR(10)
        cCteAbatSE1 += " ) " + CHR(13)+CHR(10)
        cCteAbatSE1 += " SELECT "

        cBuffer := StrTran( cBuffer, "SELECT '##CTE_SE1_ABATIMENTOS##' ,", cCteAbatSE1 )

    EndIf

    If cProcName $ "FIN008|FIN008A|FIN008B|FIN008C|FIN008D|FIN008E"
        cBuffer := StrTran(cBuffer, "CONVERT( datetime ,@F7I_EMIS1 ,127 )", "CONVERT( datetime ,@F7I_EMIS1 ,121 )")    

        //CTE FK1
        cBuffer := StrTran(cBuffer, "SELECT '##CTE_FK1'", " WITH fk1_one AS (" +CHR(13)+CHR(10)+ "XXFK1RN" )
        cBuffer := StrTran(cBuffer, "XXFK1RN", " SELECT fk1.FK1_FILIAL, fk1.FK1_LOTE, fk1.FK1_IDDOC, fk1.FK1_IDFK1, fk1.FK1_TPDOC, fk1.FK1_VALOR, fk1.FK1_VLMOE2, " +CHR(13)+CHR(10)+"XXFK1RN" )
        cBuffer := StrTran(cBuffer, "XXFK1RN", "       ROW_NUMBER() OVER ( PARTITION BY fk1.FK1_IDFK1 ORDER BY fk1.R_E_C_N_O_ DESC ) AS fk1rn" +CHR(13)+CHR(10)+ "XXFK1RN" )
        cBuffer := StrTran(cBuffer, "XXFK1RN", " FROM "+  RetSqlName("FK1") + " fk1 " +CHR(13)+CHR(10)+ "XXFK1RN" )
        cBuffer := StrTran(cBuffer, "XXFK1RN", " WHERE fk1.FK1_LOTE <> ' ' " +CHR(13)+CHR(10)+ "XXFK1RN" )        
        cBuffer := StrTran(cBuffer, "XXFK1RN", "      and fk1.FK1_MOTBX not in ('LIQ', 'CEC', 'CMP') " +CHR(13)+CHR(10)+ "XXFK1RN" )
        cBuffer := StrTran(cBuffer, "XXFK1RN", "      and fk1.D_E_L_E_T_ = ' ' " +CHR(13)+CHR(10)+ "XXFK1RN" )        
        cBuffer := StrTran(cBuffer, "XXFK1RN", ") " +CHR(13)+CHR(10)+ " SELECT 'SemFka' " )  

        cBuffer := StrTran(cBuffer, "'CASE_SEV_FK5_TPDOC'", " CASE WHEN fk1.FK1_TPDOC = "+cVariaIn+"IS_DOCBA AND fk5.FK5_TPDOC IN ( "+cVariaIn+"IS_DOCBL, "+cVariaIn+"IS_DOCVL ) THEN 'X'" +CHR(13)+CHR(10)+ "XXFK5TPDOC")
        cBuffer := StrTran(cBuffer, "XXFK5TPDOC", "ELSE CASE WHEN fk1.FK1_TPDOC = "+cVariaIn+"IS_DOCES AND fk5.FK5_TPDOC = "+cVariaIn+"IS_DOCES THEN 'X' ELSE 'Y' END END") 

    EndIf
    
    If  cLocalDB == "MSSQL"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '" , " WITH (READCOMMITTED) ")
        If cProcName $ 'FIN006|FIN006A|FIN006B'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,se1.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = se1.S_T_A_M_P_")
            cBuffer := StrTran(cBuffer, "'##HASH_MD5_PK##'", cHashMSSQL )
        ElseIf cProcName $ "FIN008|FIN008A|FIN008B|FIN008C|FIN008D|FIN008E"
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT(Char(26), fk5.S_T_A_M_P_, 121 )", "AND trim(f7j.F7J_STAMP) = CONVERT( datetime , fk5.S_T_A_M_P_ , 127 )")
        EndIf
    ElseIf cLocalDB == "ORACLE"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")

        If cProcName $ 'FIN006|FIN006A|FIN006B'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRP' );" , "WHERE F7J.F7J_ALIAS  = 'CRP' ;")
            cBuffer := StrTran( cBuffer, "'##HASH_MD5_PK##'", cHashOracl )
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE1_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vE1_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE1_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vE1_BAIXA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7I_EMIS1 , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR',", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "-2 , SYSDATE ),'YYYYMMDD')", " ")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR ) :=" , "RTRIM (DSCMDA.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE" , "IN_maxStagingCounter  in  TIMESTAMP") 
            cBuffer := StrTran(cBuffer, "= TO_CHAR(se1.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')" , "= RPAD(TO_CHAR(se1.S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'), 26, ' ')")
        ElseIf cProcName $ "FIN008|FIN008A|FIN008B|FIN008C|FIN008D|FIN008E"
            cBuffer := StrTran(cBuffer, "vfk5_S_T_A_M_P_ DATE" , "vfk5_S_T_A_M_P_ TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE" , "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vdelTransactTime, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "= RPAD(TO_CHAR(fk5.S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'), 26, ' ')")                
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRR' );" , "WHERE F7J.F7J_ALIAS  = 'CRR' ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR ) :=" , "RTRIM (DSCMDA.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")   
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDB.X6_CONTEUD" , " DSCMDB.X6_CONTEUD INTO vF7I_DSCMDB ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDB.X6_VAR ) :=" , "RTRIM (DSCMDB.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDB.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDB.D_E_L_E_T_  = vIS_SPACE ;")   
            cBuffer := StrTran(cBuffer, "vF7I_DSCMOV  := (" , " ")
            cBuffer := StrTran(cBuffer, "SELECT FRV_DESCRI" , "SELECT FRV_DESCRI INTO vF7I_DSCMOV ")
            cBuffer := StrTran(cBuffer, "FRV_CODIGO  := vFRVCOD" , "FRV_CODIGO  = vFRVCOD")
            cBuffer := StrTran(cBuffer, "FRV.D_E_L_E_T_  := vIS_SPACE );" , "FRV.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vcFk5_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3'), 'yyyy-MM-ddTHH:mm:ss.fff' );" , "vcFk5_STAMP;" )
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vcStamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
            cBuffer := StrTran(cBuffer, "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_CHAR(vfk5_S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vF7I_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vF7I_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD');", "TO_CHAR(ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD');")
            cBuffer := StrTran(cBuffer, "FROM SX6### SX6C" , "INTO vF7I_DSCMDB FROM SX6### SX6C ")
            cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6C.X6_VAR ) := CONCAT ('MV_MOEDA" , "WHERE TRIM (SX6C.X6_VAR ) = CONCAT ('MV_MOEDA")
            cBuffer := StrTran(cBuffer, ") )) AND SX6C.D_E_L_E_T_  := ' ' )" , ") )) AND SX6C.D_E_L_E_T_  = ' ' ")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE" , "IN_maxStagingCounter  in  TIMESTAMP") 
        EndIf
    ElseIf cLocalDB == "POSTGRES" 
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
        
        If  cProcName $ 'FIN006|FIN006A|FIN006B'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran( cBuffer, "'##HASH_MD5_PK##'", cHashPostg )
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRP' );" , "WHERE F7J.F7J_ALIAS  = 'CRP' ;")
            cBuffer := StrTran(cBuffer, "E1_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , " ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE1_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vE1_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")     
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "TO_CHAR(CURRENT_DATE - interval '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE1_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vE1_BAIXA, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vF7I_EMIS1, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR',", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD')") //ver
            cBuffer := StrTran(cBuffer, "-2 , SYSDATE ),'YYYYMMDD')", " ")//ver
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE", "IN_maxStagingCounter  in  TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_DATE(se1.E1_EMIS1", "TO_TIMESTAMP(se1.E1_EMIS1 ,'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDA.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
        ElseIf cProcName $ "FIN008|FIN008A|FIN008B|FIN008C|FIN008D|FIN008E"
            cBuffer := StrTran(cBuffer, "vfk5_S_T_A_M_P_ DATE" , "vfk5_S_T_A_M_P_ TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE", "IN_maxStagingCounter  in  TIMESTAMP")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vdelTransactTime, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRR' );" , "WHERE F7J.F7J_ALIAS  = 'CRR' ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "SX6.X6_CONTEUD" , " SX6.X6_CONTEUD INTO vF7I_DSCMDB ")
            cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6.X6_VAR )::bpchar  := CONCAT( 'MV_MOEDA'" , "WHERE TRIM (SX6.X6_VAR )::bpchar  = CONCAT( 'MV_MOEDA'") 
            cBuffer := StrTran(cBuffer, ") )::bpchar )::bpchar  AND SX6.D_E_L_E_T_  := ' ' )" , ") )::bpchar )::bpchar  AND SX6.D_E_L_E_T_  = ' ' ")   
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vcFk5_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3'), 'yyyy-MM-ddTHH:mm:ss.fff' );" , "vcFk5_STAMP;" )
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" ,  "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")                
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vF7I_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vF7I_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")            
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDA.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDB.X6_CONTEUD" , " DSCMDB.X6_CONTEUD INTO vF7I_DSCMDB ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDB.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDB.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDB.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDB.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMOV  := (" , " ")
            cBuffer := StrTran(cBuffer, "SELECT FRV_DESCRI" , "SELECT FRV_DESCRI INTO vF7I_DSCMOV ")
            cBuffer := StrTran(cBuffer, "FRV_CODIGO  := vFRVCOD" , "FRV_CODIGO  = vFRVCOD")
            cBuffer := StrTran(cBuffer, "FRV.D_E_L_E_T_  := vIS_SPACE );" , "FRV.D_E_L_E_T_  = vIS_SPACE ;")
        EndIf
    EndIf
    
    cBuffer := StrTran( cBuffer, "SX6###", RetSqlName("SX6") ) 

Return  .T.

/*/{Protheus.doc} EngSPS39Signature
    Ponto de Entrada que retorna a assinatura do processo 39

    @type  Function
    @return character, Assinatura
    @author  TOTVS
    @version 12
/*/
Function EngSPS39Signature(cProcess as character) As Character

    Local cAssinatura as character

    cAssinatura := VerIDProc(cProcess)

Return cAssinatura

/*/{Protheus.doc} EngPre39Compile
    Ponto de entrada que será executado antes da compilação das procedures no RPO
    
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPre39Compile(cProcesso as character, cEmpresa as character, cError as character) As Logical

Return ValidatePreCompile(cEmpresa, @cError)

/*/{Protheus.doc} EngOn39Compile
    Ponto de Entrada responsável por fazer a adaptação do código original do processo 39, 
    substituindo as tags '###' dentro dos arquivos .SQL pela correta regra de negócio.

    Executado durante a compilação das procedures, para cada procedure é feita a substituição das tags de acordo com a regra de negócio definida para cada uma delas
    .
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngOn39Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character) As Logical
    
    ApplyCommonOnCompile(cEmpresa, @cBuffer)
	
    If AliasIndic("F7O")
        Do Case
            Case cProcName $ 'FIN007|FIN007A|FIN007B'
                FlexField(@cBuffer,'1',"F7I")
            Case cProcName $ 'FIN009|FIN009A|FIN009B|FIN009C'
                FlexField(@cBuffer,'3',"F7I")
        End Case
    EndIf

Return .T.

/*/{Protheus.doc} EngPos39Compile
    
    Ponto de Entrada responsável por fazer ajustes no código já adaptado ao tipo de banco de dados em uso. 
    Ajustes só podem ser realizados após a função MsParse traduzir o script original para a linguagem do banco que está sendo utilizado.
    Permite fazer ajustes específicos para cada banco de dados, caso necessário

    Executado após compilação das procedures de um determinado processo pela MsParse. Será executado para cada procedure do processo.    
    .
    @type  Function
    @return logical, Realizado a compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPos39Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character) As Logical
    
    Local cVariaIn        As Character

    Default cProcesso := ""
    Default cEmpresa  := ""
    Default cProcName := ""
    Default cLocalDB  := ""
    Default cBuffer   := ""
    Default cError    := ""

    cProcName := AllTrim(cProcName)
    cLocalDB  := AllTrim(cLocalDB)
    cBuffer   := StrTran( cBuffer, "121", '127' )
    cVariaIn  := "@"
    
    If  cLocalDB $ "ORACLE|POSTGRES"
        cVariaIn := "v"
    EndIf

    If cProcName $ "FIN007|FIN007A|FIN007B"
        //CASE PAMOV
        cBuffer := StrTran(cBuffer, "'##PAMOV##'", " CASE WHEN FK5.FK5_TPDOC = "+cVariaIn+"IS_TPDOCPA THEN 'X' " + CHR(13)+CHR(10)+ "XXPAMOV") 
        cBuffer := StrTran(cBuffer, "XXPAMOV", " WHEN FK5.FK5_TPDOC = "+cVariaIn+"IS_TPDOCES THEN 'X' ELSE 'Y' END" )
    EndIf
    
    If cProcName $ 'FIN009|FIN009A|FIN009B|FIN009C'
        cBuffer := StrTran(cBuffer, "SELECT '##CTE_FK2'", " WITH fk2_one AS (" +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", " SELECT fk2.FK2_FILIAL, fk2.FK2_LOTE, fk2.FK2_IDDOC, fk2.FK2_IDFK2, fk2.FK2_TPDOC, fk2.FK2_VALOR, fk2.FK2_VLMOE2, " +CHR(13)+CHR(10)+"XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", "       ROW_NUMBER() OVER ( PARTITION BY fk2.FK2_IDFK2 ORDER BY fk2.R_E_C_N_O_ DESC ) AS fk2rn" +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", " FROM "+  RetSqlName("FK2") + " fk2 " +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", " WHERE fk2.FK2_LOTE <> ' ' " +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", "      and fk2.FK2_MOTBX not in ('LIQ', 'CEC', 'CMP') " +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", "      and fk2.D_E_L_E_T_ = ' ' " +CHR(13)+CHR(10)+ "XXFK2RN" )
        cBuffer := StrTran(cBuffer, "XXFK2RN", ") " +CHR(13)+CHR(10)+ " SELECT 'SemFka' " )  

        cBuffer := StrTran(cBuffer, "'CASE_FK2_FK5_TPDOC'", " CASE WHEN fk2.FK2_TPDOC = "+cVariaIn+"IS_DOCBA AND FK5.FK5_TPDOC IN ( "+cVariaIn+"IS_DOCBL, "+cVariaIn+"IS_DOCVL ) THEN 'X'" +CHR(13)+CHR(10)+ "XXFK5FK2TPDOC")
        cBuffer := StrTran(cBuffer, "XXFK5FK2TPDOC", "ELSE CASE WHEN fk2.FK2_TPDOC = "+cVariaIn+"IS_DOCES AND FK5.FK5_TPDOC = "+cVariaIn+"IS_DOCES AND FK5.FK5_IDFK7 = fk2.FK2_IDDOC THEN 'X' ELSE 'Y' END END") 
	EndIf
    
    If  cLocalDB == "MSSQL"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '" , " WITH (READCOMMITTED) ")
        If cProcName $ 'FIN007|FIN007A|FIN007B'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,se2_principal.stamp_se2 ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = se2_principal.stamp_se2")
            cBuffer := StrTran(cBuffer, "SELECT FK5_IDMOV" , " SELECT COALESCE(MAX(FK5_IDMOV), ' ') ")
        ElseIf cProcName $ "FIN009|FIN009A|FIN009B|FIN009C"
            cBuffer := StrTran(cBuffer, "AND TRIM ( f7j.F7J_STAMP ) = CONVERT(CHAR(26), FK5.S_T_A_M_P_, 121)", "AND trim(f7j.F7J_STAMP) = CONVERT( datetime , FK5.S_T_A_M_P_ , 127 )")
        EndIf
    ElseIf cLocalDB == "ORACLE"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")

        If cProcName $ 'FIN007|FIN007A|FIN007B'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPP' )" , "WHERE F7J.F7J_ALIAS  = 'CPP' ")
            cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (IN_mdmTenantId , protheus_pk , E2_FILORIG )),'YY.MM.DD'))" , "LOWER(STANDARD_HASH( TRIM (IN_mdmTenantId ) || protheus_pk  || E2_FILORIG, 'MD5') )")
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := vIS_SPACE )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vED_CCD AND D_E_L_E_T_  = vIS_SPACE ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE2_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vE2_CCUSTO AND D_E_L_E_T_ = vIS_SPACE")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_39_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "MSDATEADD_39_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")                
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE2_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vE2_BAIXA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7I_EMIS1 , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
            cBuffer := StrTran(cBuffer, "TO_DATE(se2_principal.E2_EMIS1", "TO_TIMESTAMP(se2_principal.E2_EMIS1 ,'YYYY-MM-DD' ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR ) :=" , "RTRIM (DSCMDA.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")   
            cBuffer := StrTran(cBuffer, "vExistRatio  := (" , " ")
            cBuffer := StrTran(cBuffer, " SELECT COUNT (* )" , " SELECT COUNT (*) INTO vExistRatio")
            cBuffer := StrTran(cBuffer, "SE2.E2_MULTNAT  := vIS_COMRAT );" , "SE2.E2_MULTNAT = vIS_COMRAT ;")
            cBuffer := StrTran(cBuffer, "vF7I_IDMOV  := (" , " ")
            cBuffer := StrTran(cBuffer, "SELECT FK5_IDMOV" , " SELECT COALESCE(MAX(FK5_IDMOV), ' ') INTO vF7I_IDMOV ")
            cBuffer := StrTran(cBuffer, "FK5.FK5_IDDOC  := vFK7_IDDOC  AND 'X'  :=" , "FK5.FK5_IDDOC = vFK7_IDDOC AND 'X' = ")
            cBuffer := StrTran(cBuffer, "FK5.D_E_L_E_T_  := vIS_SPACE )" , "FK5.D_E_L_E_T_ = vIS_SPACE ")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE" , "IN_maxStagingCounter  in  TIMESTAMP") 
            cBuffer := StrTran(cBuffer, "= TO_CHAR(se2_principal.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')" , "= RPAD(TO_CHAR(se2_principal.S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'), 26, ' ')")
        ElseIf cProcName $ 'FIN009|FIN009A|FIN009B|FIN009C'
            cBuffer := StrTran(cBuffer, "= TO_CHAR(FK5.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "= RPAD(TO_CHAR(fk5.S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'), 26, ' ')")                
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPR' )" , "WHERE F7J.F7J_ALIAS  = 'CPR' ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vF7I_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vF7I_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")  

            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR ) :=" , "RTRIM (DSCMDA.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")   
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDB.X6_CONTEUD" , " DSCMDB.X6_CONTEUD INTO vF7I_DSCMDB ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDB.X6_VAR ) :=" , "RTRIM (DSCMDB.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDB.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDB.D_E_L_E_T_  = vIS_SPACE ;")   
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_39_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "MSDATEADD_39_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
            cBuffer := StrTran(cBuffer,'vfk5_S_T_A_M_P_ DATE','vfk5_S_T_A_M_P_ TIMESTAMP')
            cBuffer := StrTran(cBuffer, "TO_DATE(stg_se2.E2_EMIS1", "TO_TIMESTAMP(stg_se2.E2_EMIS1 ,'YYYY-MM-DD' ")

            cBuffer := StrTran(cBuffer, "FROM SX6### SX6C" , "INTO vF7I_DSCMDB FROM SX6### SX6C ")
            cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6C.X6_VAR ) := CONCAT ('MV_MOEDA" , "WHERE TRIM (SX6C.X6_VAR ) = CONCAT ('MV_MOEDA")
            cBuffer := StrTran(cBuffer, ") )) AND SX6C.D_E_L_E_T_  := ' ' )" , ") )) AND SX6C.D_E_L_E_T_  = ' ' ")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE" , "IN_maxStagingCounter  in  TIMESTAMP")   
        EndIf 
    ElseIf cLocalDB == "POSTGRES" 
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
        
        If cProcName $ 'FIN007|FIN007A|FIN007B'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPP' )" , "WHERE F7J.F7J_ALIAS  = 'CPP' ")
            cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (IN_mdmTenantId , protheus_pk , E2_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , "lower(md5(trim(in_mdmTenantId) || protheus_pk || E2_FILORIG)) as F7I_EXTCDH")
            cBuffer := StrTran(cBuffer, "E2_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , " ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := vIS_SPACE )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vED_CCD AND D_E_L_E_T_  = vIS_SPACE ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE2_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vE2_CCUSTO AND D_E_L_E_T_ = vIS_SPACE")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "TO_CHAR(CURRENT_DATE - interval '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE2_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vE2_BAIXA, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vF7I_EMIS1, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE", "IN_maxStagingCounter  in  TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
            cBuffer := StrTran(cBuffer, "TO_DATE(se2_principal.E2_EMIS1", "TO_TIMESTAMP(se2_principal.E2_EMIS1 ,'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "vF7I_IDMOV  := (" , " ")
            cBuffer := StrTran(cBuffer, "SELECT FK5_IDMOV" , " SELECT COALESCE(MAX(FK5_IDMOV), ' ') INTO vF7I_IDMOV ")
            cBuffer := StrTran(cBuffer, "FK5.FK5_IDDOC  := vFK7_IDDOC  AND 'X'  :=" , "FK5.FK5_IDDOC = vFK7_IDDOC AND 'X' = ")
            cBuffer := StrTran(cBuffer, "FK5.D_E_L_E_T_  := vIS_SPACE )" , "FK5.D_E_L_E_T_ = vIS_SPACE ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDA.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "vExistRatio  := (" , " ")
            cBuffer := StrTran(cBuffer, " SELECT COUNT (* )" , " SELECT COUNT (*) INTO vExistRatio")
            cBuffer := StrTran(cBuffer, "SE2.E2_MULTNAT  := vIS_COMRAT );" , "SE2.E2_MULTNAT = vIS_COMRAT ;")
        ElseIf cProcName $ 'FIN009|FIN009A|FIN009B|FIN009C'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPR' )" , "WHERE F7J.F7J_ALIAS  = 'CPR' ")
            cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vF7I_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vF7I_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM SX6### SX6C" , "INTO vF7I_DSCMDB FROM SX6### SX6C ")
            cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6C.X6_VAR )::bpchar  := CONCAT ('MV_MOEDA' , TRIM (", "WHERE TRIM (SX6C.X6_VAR )::bpchar  = CONCAT ('MV_MOEDA' , TRIM (") 
            cBuffer := StrTran(cBuffer, ") )::bpchar )::bpchar  AND SX6C.D_E_L_E_T_  := ' ' )" , ") )::bpchar )::bpchar  AND SX6C.D_E_L_E_T_  = ' ' ")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE", "IN_maxStagingCounter  in  TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
            cBuffer := StrTran(cBuffer,'vfk5_S_T_A_M_P_ DATE','vfk5_S_T_A_M_P_ TIMESTAMP')
            cBuffer := StrTran(cBuffer, "TO_DATE(stg_se2.E2_EMIS1", "TO_TIMESTAMP(stg_se2.E2_EMIS1 ,'YYYYMMDD'")

            cBuffer := StrTran(cBuffer, "vF7I_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7I_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDA.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDB.X6_CONTEUD" , " DSCMDB.X6_CONTEUD INTO vF7I_DSCMDB ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDB.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDB.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDB.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDB.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vF7I_CCUSTO  AND D_E_L_E_T_  := vIS_SPACE );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vF7I_CCUSTO  AND D_E_L_E_T_  = vIS_SPACE ;")
        EndIf
    EndIf
    
    cBuffer := StrTran( cBuffer, "SX6###", RetSqlName("SX6") ) 

Return  .T.

/*/{Protheus.doc} EngSPS40Signature
    Ponto de Entrada que retorna a assinatura do processo 40

    @type  Function
    @return character, Assinatura
    @author  TOTVS
    @version 12
/*/
Function EngSPS40Signature(cProcess as character) As Character

    Local cAssinatura as character

    cAssinatura := VerIDProc(cProcess)

Return cAssinatura

/*/{Protheus.doc} EngPre40Compile
    Ponto de entrada que será executado antes da compilação das procedures no RPO
    .
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPre40Compile(cProcesso as character, cEmpresa as character, cError as character) As Logical

Return ValidatePreCompile(cEmpresa, @cError)

/*/{Protheus.doc} EngOn40Compile
    Ponto de Entrada responsável por fazer a adaptação do código original do processo 40, 
    substituindo as tags '###' dentro dos arquivos .SQL pela correta regra de negócio.

    Executado durante a compilação das procedures, para cada procedure é feita a substituição das tags de acordo com a regra de negócio definida para cada uma delas
    .
    @type  Function
    @return logical, Permite compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngOn40Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character) As Logical
    
    ApplyCommonOnCompile(cEmpresa, @cBuffer)
	
    If AliasIndic("F7O")
        Do Case
            Case cProcName == 'FIN010'
                cBuffer := StrTran( cBuffer, "'F7N_DSCMDA'", cValTochar(LEN(X6Conteud())))
                FlexField(@cBuffer,'5',"F7N")
        End Case
    EndIf

Return .T.

/*/{Protheus.doc} EngPos40Compile
    
    Ponto de Entrada responsável por fazer ajustes no código já adaptado ao tipo de banco de dados em uso. 
    Ajustes só podem ser realizados após a função MsParse traduzir o script original para a linguagem do banco que está sendo utilizado.
    Permite fazer ajustes específicos para cada banco de dados, caso necessário

    Executado após compilação das procedures de um determinado processo pela MsParse. Será executado para cada procedure do processo.    
    .
    @type  Function
    @return logical, Realizado a compilação ou não das procedures, caso retorne .F. a procedure não será compilada
    @author  TOTVS
    @version 12
/*/
Function EngPos40Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character) As Logical
    
    Local cVariaIn        As Character
    Local cGESFK5         As Character
    Local cOrigemFK5      As Character

    Default cProcesso := ""
    Default cEmpresa  := ""
    Default cProcName := ""
    Default cLocalDB  := ""
    Default cBuffer   := ""
    Default cError    := ""

    cProcName := AllTrim(cProcName)
    cLocalDB  := AllTrim(cLocalDB)
    cBuffer   := StrTran( cBuffer, "121", '127' )
    cGESFK5   := SuperGetMv("MV_GESFK5", .F., "")
    cVariaIn  := "@"
    
    If  cLocalDB $ "ORACLE|POSTGRES"
        cVariaIn := "v"
    EndIf

    If cProcName == 'FIN010'
        cBuffer := StrTran(cBuffer, "CONVERT( datetime ,stg.FK5_DATA ,127 )", "CONVERT( datetime ,stg.FK5_DATA ,121 )")

        If !Empty(cGESFK5)
            cOrigemFK5 := MontaStr(Upper(cGESFK5))
            cBuffer    := StrTran(cBuffer, "'##ORIGEMFK5'", cOrigemFK5)
        Else
            cOrigemFK5 := "'FINA085A' "
            cBuffer    := StrTran(cBuffer, "'FINA085A' ,", cOrigemFK5)
            cBuffer    := StrTran(cBuffer, "'##ORIGEMFK5'", "")
        EndIf
        
        If ChkFixGes()
            AtuMvFix("1")
        EndIf 
    EndIf
    
    If  cLocalDB == "MSSQL"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '" , " WITH (READCOMMITTED) ")
        If cProcName == 'FIN010'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,stg.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = stg.S_T_A_M_P_")
        EndIf
    ElseIf cLocalDB == "ORACLE"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")

        If cProcName == 'FIN010'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'MVB' )" , "WHERE F7J.F7J_ALIAS  = 'MVB' ")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_40_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "MSDATEADD_40_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7N_DATA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7N_DATA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(stg.FK5_DATA ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(stg.FK5_DATA ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "vS_T_A_M_P_FK5 DATE", "vS_T_A_M_P_FK5 TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "TO_DATE(''", "TO_TIMESTAMP('1900-01-01'")
            cBuffer := StrTran(cBuffer, "vID_PROCESSO  := TO_CHAR(HASHBYTES ('MD5' , vDtInicio ),'YY.MM.DD')", "XXHASHORACL")
            cBuffer := StrTran(cBuffer, "XXHASHORACL", "SELECT STANDARD_HASH(vDtInicio, 'MD5') INTO vID_PROCESSO FROM DUAL")
            cBuffer := StrTran(cBuffer, "IN_maxStagingCounter  in  DATE" , "IN_maxStagingCounter  in  TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vF7N_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7N_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR ) :=" , "RTRIM (DSCMDA.X6_VAR ) = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE );" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
        EndIf 
    ElseIf cLocalDB == "POSTGRES" 
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
        cBuffer := StrTran(cBuffer, "TO_CHAR(SYSDATETIME ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
        
        If cProcName == 'FIN010'
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
            cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'MVB' )" , "WHERE F7J.F7J_ALIAS  = 'MVB' ")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_40_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_DATE('' ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TIMESTAMP '1900-01-01 00:00:00' ")  //INIFILTER
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_40_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - interval '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7N_DATA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vF7N_DATA, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_DATE(stg.FK5_DATA ,'YYYY-MM-DD HH24:MI:SS.FF3')", "stg.fk5_data::timestamp")
            cBuffer := StrTran(cBuffer, "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "vS_T_A_M_P_FK5 DATE", "vS_T_A_M_P_FK5 TIMESTAMP")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "TO_CHAR(HASHBYTES ('MD5' , CONCAT (IN_mdmTenantId , vDtInicio )::bpchar ),'YY.MM.DD')", "md5(trim(in_mdmTenantId) || now() || "+cProcName+" )")
            cBuffer := StrTran(cBuffer, "vF7N_DSCMDA  := (" , " ")
            cBuffer := StrTran(cBuffer, "DSCMDA.X6_CONTEUD" , " DSCMDA.X6_CONTEUD INTO vF7N_DSCMDA ")
            cBuffer := StrTran(cBuffer, "RTRIM (DSCMDA.X6_VAR )::bpchar  :=" , "RTRIM (DSCMDA.X6_VAR )::bpchar = ")
            cBuffer := StrTran(cBuffer, "AND DSCMDA.D_E_L_E_T_  := vIS_SPACE" , "AND DSCMDA.D_E_L_E_T_  = vIS_SPACE ;")
            cBuffer := StrTran(cBuffer, "                  );", "")
        EndIf
    EndIf
    
    cBuffer := StrTran( cBuffer, "SX6###", RetSqlName("SX6") ) 

Return  .T.

/*/{Protheus.doc} ValidatePreCompile
    Função dinâmica para validar a pré-compilação das tabelas.
    @type Function
    @author  victor.azevedo@totvs.com.br
    @param cEmpresa, Character, Código da empresa.
    @param cError, Character, Mensagem de erro.
    @return Logical, Retorna .T. se a validação for bem-sucedida, .F. caso contrário.
*/
Static Function ValidatePreCompile(cEmpresa As Character, cError As Character) As Logical
    Local aTblCheck := {"F7I","F7N","F7O","F7J","F7P"} As Array
    Local cTblFalta := "" As Character
    Local lRet      := .T. As Logical
    Local nX        := 0   As Numeric

    If !SuperGetMv("MV_FINTGES", .F., .F.) .Or. !ExistStamp(@cError)
        Return .F.
    EndIf

    For nX := 1 To Len(aTblCheck)
        If !AliasIndic(aTblCheck[nX])
            cTblFalta += IIf(Empty(cTblFalta), "", ", ") + aTblCheck[nX]
        EndIf
    Next

    If !Empty(cTblFalta)
        cError := STR0002 + cTblFalta + " - " + cEmpresa
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} ApplyCommonOnCompile
    Função dinâmica para aplicar configurações comuns durante a compilação.
    
    @type Function
    @author  victor.azevedo@totvs.com.br
    @param cEmpresa, Character, Código da empresa.
    @param cBuffer, Character, Buffer de compilação.
    @return Nil
*/
Static Function ApplyCommonOnCompile(cEmpresa As Character, cBuffer As Character)

    Local aSM0     As Array
    Local nX       As Numeric
    Local nTamSM0  As Numeric
    Local nGrupEmp As Numeric
    Local nCompani As Numeric
    Local nCodUnid As Numeric
    Local nCodFil  As Numeric

    aSM0     := FWLoadSM0()
    nTamSM0  := Len(aSM0)
    nGrupEmp := 20
    nCompani := 20
    nCodUnid := 20
    nCodFil  := 20

    For nX := 1 To nTamSM0
        If Trim(aSM0[nX,1]) == Trim(cEmpresa)
            nGrupEmp := Len(aSM0[nX,1])
            nCompani := Len(aSM0[nX,3])
            nCodUnid := Len(aSM0[nX,4])
            nCodFil  := Len(aSM0[nX,5])
            Exit
        EndIf
    Next

    If nCompani < 1
        nCompani := 1
    EndIf

    If nCodUnid < 1
        nCodUnid := 1
    EndIf

    cBuffer := StrTran(cBuffer, "'##GROUPEMPRESA'", cValToChar(nGrupEmp))
    cBuffer := StrTran(cBuffer, "'##COMPANIA'",     cValToChar(nCompani))
    cBuffer := StrTran(cBuffer, "'##COD_UNID'",     cValToChar(nCodUnid))
    cBuffer := StrTran(cBuffer, "'##COD_FIL'",      cValToChar(nCodFil))
    cBuffer := StrTran(cBuffer, "'F7I_DSCMDA'",     cValToChar(Len(X6Conteud())))
    cBuffer := StrTran(cBuffer, "'F7I_DSCMDB'",     cValToChar(Len(X6Conteud())))

    FwFreeArray(aSM0)

Return

/*/{Protheus.doc} TablesSize
    Função dinâmica para calcular o tamanho de cada unidade de negócio para N tabelas.
    @type Function
    @author  victor.azevedo@totvs.com.br
    @param aTables, Array, Array com os nomes das tabelas a serem processadas.
    @return Array, Array contendo os tamanhos das unidades de negócio para cada tabela.
/*/
Function TablesSize(aTables As Array) As Array
    Local aResult    As Array 
    Local nTamEmp    As Numeric
    Local nTamUnit   As Numeric
    Local nTamFil    As Numeric
    Local nTamTotal  As Numeric
    Local cTable     As Character
    Local nI         As Numeric

    Default aTables := {}

    //inicializa variaveis
    aResult   := {}
    nTamEmp   := 0
    nTamUnit  := 0
    nTamFil   := 0
    nTamTotal := 0
    cTable    := ""
    nI        := 0

    // Itera sobre cada tabela no array
    If !Empty(aTables)
        For nI := 1 To Len(aTables)
            cTable := aTables[nI]

            // Calcula os tamanhos das unidades de negócio para a tabela atual
            nTamEmp  := Len(FWCompany(cTable))
            nTamUnit := Len(FWUnitBusiness(cTable))
            nTamFil  := Len(FWFilial(cTable))

            nTamTotal := 0

            // Verifica os modos de acesso e soma os tamanhos
            If FWModeAccess(cTable, 1) == "E"
                nTamTotal += nTamEmp
            EndIf

            If FWModeAccess(cTable, 2) == "E"
                nTamTotal += nTamUnit
            EndIf

            If FWModeAccess(cTable, 3) == "E"
                nTamTotal += nTamFil
            EndIf

            // Adiciona o resultado ao array
            AAdd(aResult, {cTable, nTamTotal, nTamEmp, nTamUnit, nTamFil})
        Next
    EndIf

Return aResult

/*/{Protheus.doc} FlexField
    Função para processar os campos flexíveis nas procedures de integração, substituindo os placeholders no código SQL.
    
    @type Function
    @author  victor.azevedo@totvs.com.br
    
    @param cBuffer, Character, Buffer contendo o código SQL com placeholders a serem substituídos.
    @param cOrigem, Character, Carteira origem do campo flexível.
    @param cTable, Character, Nome da tabela a ser processada.
    
    @return Character, Buffer com os placeholders substituídos.
/*/
Static Function FlexField(cBuffer as character, cOrigem  as character, cTable  as character) As Character

    Local aFlexFld   As Array
    Local cDeclare   As Character
    Local cSelCursor As Character
    Local cCampo     As Character
    Local cCursor    As Character
    Local cVariaveis As Character
    Local cInsert    As Character
    Local cSelCurRat As Character
    Local cCampoRat  As Character
    Local cCursorRat As Character
    Local cVarRat    As Character
    Local cInsertRat As Character
    Local nI         As Numeric

    Default cBuffer   := ""
    Default cOrigem   := ""
    Default cTable    := ""

    aFlexFld   := FindFlex(cOrigem) //F7O_COLUNA, F7O_FLEX, F7O_TABELA
    cDeclare   := " "
    cSelCursor := " "
    cCampo     := " "
    cCursor    := " "
    cVariaveis := " "
    cInsert    := " "
    cSelCurRat := " "
    cCampoRat  := " "
    cCursorRat := " "
    cVarRat    := " "
    cInsertRat := " "
    nI         := 1

    If !Empty(aFlexFld)
        For nI := 1 To Len(aFlexFld)
            If AT( '.'+ RTrim(aFlexFld[nI][1]) , cBuffer ) == 0 
                cDeclare   += ' declare @F' + aFlexFld[nI][1] + ' char(' + IIF(Val(aFlexFld[nI][2]) > 10, '100', '30') + ')' + CRLF
                If aFlexFld[nI][3] $ "SEV|SEZ"
                    cSelCurRat += ' , '+ aFlexFld[nI][1] + ' as F7I_FLXF'+ aFlexFld[nI][2] + CRLF
                    cCampoRat  += ' , ' +  lower(aFlexFld[nI][3]) + '.' + aFlexFld[nI][1] + CRLF
                    cCursorRat += ' , ' +'@F' + aFlexFld[nI][1] + CRLF
                    cVarRat    += " , IsNull(" +'@F' + aFlexFld[nI][1] +", ' ') " + CRLF
                    cInsertRat += ' ,  '+cTable+'_FLXF' + aFlexFld[nI][2] + CRLF
                Else 
                    cSelCursor += ' , '+ aFlexFld[nI][1] + ' as F7I_FLXF'+ aFlexFld[nI][2] + CRLF
                    cCampo     += ' , ' +  aFlexFld[nI][1] + CRLF
                    cCursor    += ' , ' +'@F' + aFlexFld[nI][1] + CRLF
                    cVariaveis += " , IsNull(" +'@F' + aFlexFld[nI][1] +", ' ') " + CRLF
                    cInsert    += ' ,  '+cTable+'_FLXF' + aFlexFld[nI][2] + CRLF
                EndIf
            EndIf 
        Next nI
    EndIf

    cBuffer := StrTran( cBuffer, "--#cursorflex",  cCursor )
    cBuffer := StrTran( cBuffer, "--#cursorrateio",  cCursorRat )

    cBuffer := StrTran( cBuffer, "--#insertflex",  cInsert )
    cBuffer := StrTran( cBuffer, "--#insertrateio",  cInsertRat )

    cBuffer := StrTran( cBuffer, "--#variaveisflex",  cVariaveis )
    cBuffer := StrTran( cBuffer, "--#variaveisrateio",  cVarRat )

    cBuffer := StrTran( cBuffer, ",'#selectcursorflex' as cursorflex",  cSelCursor )
    cBuffer := StrTran( cBuffer, ",'#selectcursorrateio' as cursorflexrateio",  cSelCurRat )

    cBuffer := StrTran( cBuffer, ",'#campoflex' as campoflex", cCampo )
    cBuffer := StrTran( cBuffer, ",'#camposflexrateio' as camposflexrateio", cCampoRat )
    cBuffer := StrTran( cBuffer, "declare flex char(1)",  cDeclare )

Return cBuffer

/*/{Protheus.doc} ChkFileGes
    Função para gerar as tabelas de integração Gesplan
    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @since 27/05/2025
/*/
Static Function ChkFileGes()
    Local aTab as Array
    Local nX   as Numeric
    
    aTab := {'F7I','F7J','F7O','F7N', 'F7P'}
    
    For nX := 1 to Len(aTab)
        ChkFile(aTab[nX])
    Next    

    FwFreeArray(aTab)
Return

/*/{Protheus.doc} ChkFixGes
    Função para validar os registros com Stamp null para os registros da tabela FK5 com data futura.
    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @since 10/09/2025
    @return lRet,  Logical, Confirmação do ajuste da base.    
/*/
Static Function ChkFixGes() As Logical
    Local lRet       As Logical
    Local cQry       As Character
    Local cDtFk5     As Character
    Local cTblTmp    As Character
    Local nParam     As Numeric
    Local oQuery     As Object 
    Local aFk5Rec    As Array
    
    lRet      := .T.
    cQry      := ""
    cTblTmp   := ""    
    cDtFk5    := dToS(Date())
    nParam    := 1
    aFk5Rec   := {}
    
    cQry := " SELECT "        
    cQry += "   FK5.R_E_C_N_O_ "
    cQry += " FROM "
    cQry += "   " + RetSqlName("FK5") + " FK5 "    
    cQry += " WHERE "
    cQry += "   FK5.S_T_A_M_P_ is null "
    cQry += "   AND  FK5.FK5_DATA > ? "
    cQry += "   AND FK5.D_E_L_E_T_ = ? "

    cQry := ChangeQuery(cQry)
    oQuery := FwExecStatement():New(cQry)
    
    oQuery:SetString(nParam++, cDtFk5)
    oQuery:SetString(nParam++, Space(1))    
    
    cTblTmp := oQuery:OpenAlias()

	While !(cTblTmp)->(Eof())
        AAdd(aFk5Rec, (cTblTmp)->R_E_C_N_O_ )
		(cTblTmp)->(dbSkip())
	EndDo    
    
    (cTblTmp)->(DbCloseArea()) 

    If Len(aFk5Rec) > 0
        lRet := GesUpStamp("FK5", aFk5Rec)
    EndIf

    If oQuery <> Nil
        oQuery:Destroy()
        oQuery := Nil
    EndIf

    FwFreeArray(aFk5Rec)

Return lRet

/*/{Protheus.doc} AtuMvFix
    Ajusta o MV_GESFIX
    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @param cCodFix, Character, código do fix executado
    @since 10/09/2025
/*/

Static Function AtuMvFix(cCodFix As Character)

    Local cMvFinFix As Character
    
    Default cCodFix := "0"
    
    cMvFinFix := SuperGetMv("MV_GESFIX", .F., "0" )
    
    If cMvFinFix < cCodFix
        PutMv("MV_GESFIX", cCodFix)
    EndIf

Return

/*/{Protheus.doc} GesUpStamp
    Função gravar os campos de Stamp com conteudo null via gatilho de base.

    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @since 12/09/2025    
    @param cAlias, character, Alias da tabela
    @param aRec,   Array, Conteudos de Recno para atualizar
    @return lRet,  Logical, Confirmação do ajuste da base.    
/*/
Static Function GesUpStamp(cAlias as character, aRec as Array) As Logical
    
    Local cQry       As Character
    Local lRet       As Logical
    Local nParam     As Numeric
    Local oStatement As Object
    
    Default cAlias  := ""
    Default aRec    := {}

    cQry   := ""
    lRet   := .T.
    nParam := 1
    

    If !Empty(cAlias) .And. Len(aRec) > 0
        cQry    := " UPDATE " + RetSqlName("FK5")
        cQry 	+= " SET S_T_A_M_P_ =  Null " 
        cQry 	+= " WHERE R_E_C_N_O_ IN (?) " 

        oStatement := FwExecStatement():New(cQry) 
        oStatement:setIn(nParam++, aRec)                
        
        If TcSqlExec(oStatement:getFixQuery()) != 0
            FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "GesUpStamp", TCSQLError()) //Ocorreu um erro inesperado na atualização do campo S_T_A_M_P_
            lRet      := .F.
        EndIf

        If oStatement <> Nil
            oStatement:Destroy()
            oStatement := Nil
        EndIf
    EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistStamp
    Função para validar se os campos de Stamp estão criados nas tabelas de integração Gesplan.

    @type			function
    @description	Valida se todos os STAMPS estão criados.
    @author			victor.azevedo@totvs.com.br
    @since			23/09/2025
    @param			cError, Character, Mensagem de erro detalhada com as tabelas que estão sem o campo de Stamp.
    @return			Logical, Retorna .T. se todos os campos de Stamp existirem,
/*/
//-------------------------------------------------------------------------------------\-----------
Static function ExistStamp(cError) as Logical
    Local aTables 		as Array
    Local lRet 			as Logical
    Local nLenTbl   	as Numeric
    Local nCountTbls	as Numeric
    Local nI			as Numeric

    Default cError := ""

    aTables    := {'SE1', 'SE2', 'FK5'}
    lRet       := .T.
    nCountTbls := 0
    nI         := 0
    nLenTbl    := Len(aTables)

    For nI := 1 To nLenTbl
        If Ascan( TCStruct(RetSqlName(aTables[nI])), {|x| x[1] == 'S_T_A_M_P_' }) == 0
            nCountTbls++ 

            If nCountTbls == 1
                lRet := .F.
                cError += "Não foi encontrado o campo S_T_A_M_P_ para as tabelas: "
                cError += aTables[nI] 
            ElseIf nCountTbls > 1 .and. nI < nLenTbl
                cError += ', ' + aTables[nI] 
            ElseIf nI == nLenTbl
                cError += " e " + aTables[nI] + CRLF + "Realize a execução do wizard de configuração da integração Gesplan."
            EndIf  
        EndIf
    Next nI

return lRet 

/*/{Protheus.doc} LogProcs
    Função responsável exibir parâmetros de chamada das procedures no console.log
    @type  Static Function
    @author victor.azevedo@totvs.com.br
    @since 19/09/2025    
    @param aParams, Array, Parâmetros de entrada da procedure
    @return Nil 
/*/
Static Function LogProcs(aParams as Array)
    Local cMsg as Character
    Local nI   as Numeric

    Default aParams := {}

    //inicializa variaveis
    cMsg := ""
    nI   := 1

    If !Empty(aParams)
        For nI := 1 To Len(aParams)
            If nI > 2
                cMsg += "; "
            EndIf

            cMsg += cValToChar(aParams[nI])

            If nI == 1
                cMsg += "( " 
            EndIf

            If nI == Len(aParams)
                cMsg += " )"
            EndIf
        Next nI

        FwLogMsg("INFO",, "FINXGES", __cLockNm, "", , cMsg)
    EndIf

Return

/*/{Protheus.doc}  FindFlex
	Busca campos flex fileds na base
	@type  function
	@author victor.azevedo@totvs.com.br
	@since 18/10/2025
    @return Array, FlexFields cadastrados
/*/ 
Static Function FindFlex(cOrigem as Character) as Array

    Local aFlex     As Array
    Local cQry      As Character
    Local cSpace    As Character
    Local cTblTmp   As Character
    Local oQuery    As Object

    Default cOrigem := ""

    aFlex     := {}
    cQry      := ""
    cTblTmp   := ""
    cSpace    := Space(1)

    If !Empty(cOrigem)
        cQry := " SELECT F7O_COLUNA, F7O_FLEX, F7O_TABELA "    
        cQry += " FROM " + RetSqlName("F7O")
        cQry += " WHERE "
        cQry += " F7O_ORIGEM = ? "
        cQry += " AND D_E_L_E_T_ = ? "
        cQry += " ORDER BY F7O_FLEX "

        cQry := ChangeQuery(cQry)
        oQuery := FwExecStatement():New(cQry)
        
        oQuery:SetString(1, cOrigem)
        oQuery:SetString(2, cSpace)
        
        cTblTmp := oQuery:OpenAlias()
        While (cTblTmp)->(!Eof())
            AAdd(aFlex, {(cTblTmp)->F7O_COLUNA, (cTblTmp)->F7O_FLEX, AllTrim((cTblTmp)->F7O_TABELA)})

            (cTblTmp)->(dbSkip())
        EndDo

        (cTblTmp)->(DbCloseArea())

        If oQuery <> Nil
            oQuery:Destroy()
            oQuery := Nil
        EndIf
    EndIf

Return aFlex

/*/{Protheus.doc} MontaStr
    Transforma string recebida em formato aceito pela cláusula IN do SQL
    @type  Static Function
    @author victor.azevedo@totvs.com.br
    @since 08/01/2026    
    @param cString, Character, String a ser formatada
    @return Character, String formatada para uso no IN do SQL
/*/
Static Function MontaStr(cString as Character) As Character

    Local aOrigem    As Array
    Local cResultado As Character
    Local nI         As Numeric

    Default cString := ""

    aOrigem    := {}
    cResultado := ""
    nI         := 0

    If !Empty(cString)
        // Divide a string pelo delimitador ";"
        aOrigem := StrTokArr(cString, ";")

        // Constrói a nova string com aspas simples e vírgulas
        For nI := 1 To Len(aOrigem)
            If nI > 1
                cResultado += ", "
            EndIf

            cResultado += "'" + AllTrim(aOrigem[nI]) + "'"
        Next
    EndIf

Return cResultado

/*/{Protheus.doc} VldProced
	Função responsável por identificar quando a assinatura vigente do processo 33 no fonte é "004" e a assinatura instalada está abaixo dessa versão, a função busca os processos 33, 39 e 40 no RPO e executa a instalação automática de cada um deles.
	
	@type  Static Function
	@author victor.azevedo@totvs.com.br
	@since 20/05/2026
	@version P12
	@description Na versão "004" da assinatura da antiga procedure 33, o processo foi desmembrado em três processos independentes para separar as integrações por domínio de negócio: 33 - Contas a Receber Previsto e Realizado; 39 - Contas a Pagar Previsto e Realizado; 40 - Movimentos Bancários.
	@return logical, .T. quando o ambiente suporta a instalação automática e os processos necessários estão instalados ou foram instalados com sucesso; .F. quando houver divergência, indisponibilidade do modelo migrado ou falha na instalação.
/*/
Static Function VldProced()

    Local aProcessos  as Array
    Local oInstall    as Object
    Local oProcesso   as Object
    Local oProcesRPO  as Object
    Local nI          as Numeric

    aProcessos := {"33", "39", "40"}
    nI         := 0

	//Verifica se é possivel utilizar as funções de instalação automatica de procedures.
    If !(FindFunction("SPSMigrated") .and. SPSMigrated())
        FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0006) //Obrigatório utilizar novo modelo de procedure para efetuar a instalação automática dos processos de integração Gesplan.
		Return .F.
	EndIf

    oProcesso  := EngSPSStatus("33")

    If (Val(oProcesso["signature"]) > 0 .And. Val(oProcesso["signature"]) < 5)
        For nI := 1 To Len(aProcessos)
            oProcesRPO := EngSPSGetProcess(DEF_SPS_FROM_RPO, aProcessos[nI], cEmpAnt)

            // Realiza a instalação do processo com base no RPO
            If oProcesRPO["status"] <> "FALSE"
                oInstall := EngSPSInstall(aProcessos[nI], cEmpAnt, DEF_SPS_FROM_RPO)
                If !Empty(oInstall["error"])
                    FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0007 + CHR(10) + STR0008 + oInstall["idlog"] + STR0009 + oInstall["error"]) // "Falha na instalação da procedure." "IDLog da operação [ " " ] - Erro: "
                    Return .F.
                EndIf
            Else
                FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0010 + oProcesso["process"] + STR0011 + oProcesRPO["error"]) // "Não foi possivel obter o objeto do processo. " Motivo: " 
                Return .F.
            EndIf
        Next nI
    EndIf

Return .T.

/*/{Protheus.doc} MinOpenSE1
    Retorna a menor data de emissão de um título com saldo em aberto.
    Consulta a tabela SE1 (Títulos a Receber) filtrando apenas registros que
    possuem saldo (E1_SALDO > 0) e retorna a menor data do campo E1_EMIS1.
    
    @type  Static Function
    @author sidney.silva
    @since 14/04/2026
    @version 1.0
    
    @param dIniCFull, Date, Data inicial para comparação
    @return Date, Data de emissão do título mais antigo com saldo, ou a data inicial fornecida se nenhum encontrado

/*/
Static Function MinOpenSE1(dIniCFull as Date) As Date

    Local cQry          As Character
    Local cSpace        As Character
    Local cMenorData    As Character
    Local dMenorData    As Date

    Default dIniCFull := Date()

    cQry        := ""
    cSpace      := Space(1)
    cMenorData  := ""
    dMenorData  := dIniCFull

	If __oQrySE1 == Nil
	    cQry := " SELECT MIN(E1_EMIS1) AS MENOR_DATA "    
	    cQry += " FROM " + RetSqlName("SE1")
	    cQry += " WHERE E1_SALDO > ? "
	    cQry += " AND E1_EMIS1 > ? "
	    cQry += " AND D_E_L_E_T_ = ? "

    	cQry := ChangeQuery(cQry)
    	__oQrySE1 := FwExecStatement():New(cQry)
	EndIf
	    
    __oQrySE1:SetNumeric(1, 0)
	__oQrySE1:SetDate(2, dIniCFull)
	__oQrySE1:SetString(3, cSpace)

    cMenorData := __oQrySE1:ExecScalar("MENOR_DATA")

	If !Empty(cMenorData)
		dMenorData := SToD(cMenorData)
	EndIf

Return dMenorData

/*/{Protheus.doc} MinOpenSE2
    Retorna a menor data de emissão de um título com saldo em aberto.
    Consulta a tabela SE2 (Títulos a Pagar) filtrando apenas registros que
    possuem saldo (E2_SALDO > 0) e retorna a menor data do campo E2_EMIS1.
    
    @type  Static Function
    @author sidney.silva
    @since 14/04/2026
    @version 1.0
    
    @param dIniCFull, Date, Data inicial para comparação
    @return Date, Data de emissão do título mais antigo com saldo, ou a data inicial fornecida se nenhum encontrado

/*/
Static Function MinOpenSE2(dIniCFull as Date) As Date

    Local cQry          As Character
    Local cSpace        As Character
    Local cMenorData    As Character
    Local dMenorData    As Date

    Default dIniCFull := Date()

    cQry        := ""
    cSpace      := Space(1)
    cMenorData  := ""
    dMenorData  := dIniCFull

	If __oQrySE2 == Nil
	    cQry := " SELECT MIN(E2_EMIS1) AS MENOR_DATA "    
	    cQry += " FROM " + RetSqlName("SE2")
	    cQry += " WHERE E2_SALDO > ? "
	    cQry += " AND E2_EMIS1 > ? "
	    cQry += " AND D_E_L_E_T_ = ? "

    	cQry := ChangeQuery(cQry)
    	__oQrySE2 := FwExecStatement():New(cQry)
	EndIf
	    
    __oQrySE2:SetNumeric(1, 0)
	__oQrySE2:SetDate(2, dIniCFull)
	__oQrySE2:SetString(3, cSpace)

    cMenorData := __oQrySE2:ExecScalar("MENOR_DATA")

	If !Empty(cMenorData)
		dMenorData := SToD(cMenorData)
	EndIf

Return dMenorData
