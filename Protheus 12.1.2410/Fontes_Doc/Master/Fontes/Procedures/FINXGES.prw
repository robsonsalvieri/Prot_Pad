#Include "PROTHEUS.CH"
#Include "PRTOPDEF.CH"
#Include "TOPCONN.CH"
#Include "FINXGES.CH"

Static __cLockNm As Character
Static __cFIN006 As Character
Static __cFIN007 As Character
Static __cFIN008 As Character
Static __cFIN009 As Character
Static __cFIN010 As Character
Static __lTemLog As Logical

/*/{Protheus.doc} FINXGES

    Rotina de JOB no schedule para chamada das procedures

    @type  Function
    @author victor.azevedo@totvs.com.br
    @since 28/02/2025
    @version 1.0    

    @param cGrpEmp, Character, Grupo de empresa a ser processada
    @param lAutomato, Logical, Indica se a execução está sendo realizada por automação
    @param cDataIni, Character, Data inicial para filtro de processamento (utilizado para automação)
    @param cDataFim, Character, Data final para filtro de processamento (utilizado para automação)
    @param lDelF7, Logical, Indica se realiza deleção dos registros nas tabelas F7N E F7I
    @param lReproc, Logical, Indica se realiza o reprocessamento de determinada procedure
    @param cProcExec, Character, Procedure a ser executada (utilizado para automação)
    
    @return Nil

/*/
Function FINXGES(cGrpEmp As Character, lDelF7 As Logical, lReproc As Logical, cProcExec As Character, lAutomato As Logical, cDataIni As Character, cDataFim As Character)

    Local aSM0       As Array
    Local cEmpProc   As Character
    Local cStartTime As Character
    Local lExistProc As Logical
    Local lRet       As Logical
    Local lCargaFull As Logical
    Local dIniCFull  As Date
    Local dAteFull   As Date
    Local dFimCFull  As Date
    Local nTamSM0    As Numeric
    Local nX         As Numeric
    Local nY         As Numeric 
    Local cProcGesp  As Character 
    Local lCheck     As Logical

    Default cGrpEmp    := ""
    Default lDelF7     := .F.
    Default lReproc    := .F.
    Default lAutomato  := .F.
    Default cProcExec  := ""
    Default cDataIni   := ""
    Default cDataFim   := ""
    
    RpcSetType(3)
    RpcSetEnv( cGrpEmp,,,,,,)
    
    IniStatic()
    ChkFileGes()

    lExistProc  := ExistProc(__cFIN006, VerIDProc()) .AND. ExistProc(__cFIN007, VerIDProc()) .AND. ExistProc(__cFIN008, VerIDProc()) .AND. ;
                  ExistProc(__cFIN009, VerIDProc()) .AND. ExistProc(__cFIN010, VerIDProc())


    aProcedure  := {__cFIN006, __cFIN007, __cFIN008, __cFIN009, __cFIN010} 
    aSM0	    := FWLoadSM0()    
    cEmpProc    := ""
    cProcGesp   := SuperGetMv("MV_GESPROC", .F., "CP;CR;MB" )     
    lRet        := .T.
    lCargaFull  := .F.
    nTamSM0	    := Len(aSM0)
    nX          := 0 
    nY          := 1 
    cStartTime  := ''
    
    If (AliasIndic("F7I") .And. AliasIndic("F7N") .And. AliasIndic("F7O") .And. AliasIndic("F7J"))
        If !lExistProc        
            FwLogMsg("ERROR",, "FINXGES", "FINXGES", "", "Procedures", STR0004 + ' ' + cEmpAnt ) //Procedures nao instaladas, favor verificar.)
            Return
        EndIf

        If LockByName(__cLockNm + "_" + cEmpAnt, .T./*lEmpresa*/, .F./*lFilial*/ )        
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
                If ! lAutomato
                    For nY := 1 to Len(aProcedure)
                        lCargaFull := .F.
                        If "FIN008" $ aProcedure[nY]
                            F7J->(DbSetOrder(1))
                            lCargaFull := !F7J->(DbSeek("CRR"))
                        EndIf

                        If lCargaFull 
                            dIniCFull := FirstDay(YearSum(Date(), -1))
                            dFimCFull := Date()
                            dAteFull  := dIniCFull + 5
                            lCheck    := .T.
                            Do While dFimCFull >= dAteFull .And. lCheck
                                lCheck := !(dAteFull == dFimCFull)
                                ExecProced(aProcedure[nY], cEmpProc, .T., lReproc, cProcGesp, dtos(dIniCFull), dtos(dAteFull))
                                dIniCFull := dAteFull + 1
                                dAteFull  := dIniCFull + 5                                
                                If dAteFull > dFimCFull
                                    dAteFull := dFimCFull
                                End 
                            Enddo                                
                        Else
                            ExecProced(aProcedure[nY], cEmpProc, lDelF7, lReproc, cProcGesp)
                        Endif
                    Next nY
                Else
                    ExecProced(cProcExec, cEmpProc, lDelF7, lReproc, cProcGesp, cDataIni, cDataFim)
                EndIf
            EndIf

            If __lTemLog
                FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "FINISH", __cLockNm + " ended at : "+ FWTimeStamp(2, DATE(), TIME()) + ' ' + cEmpAnt )
                FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "ELAPSED", __cLockNm + " elapsed time : "+ ElapTime(cStartTime, Time()) + ' ' + cEmpAnt )
            EndIf

            UnLockByName(__cLockNm + "_" + cEmpAnt, .T./*lEmpresa*/, .F./*lFilial*/ )

            FwFreeArray(aSM0)
        Else
            FwLogMsg('INFO',, "FINXGES", "FINXGES", "", 'cLockName', "["+ __cLockNm + "] Running on another thread " + cEmpAnt )
        EndIf
    Else
        FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "Procedures", STR0002) //Dicionário de dados incompatível, realize atualização do sistema.
    EndIf
Return

/*/{Protheus.doc} ExecProced
   
    Realiza execução das procedures.
   
    @type Function
    @author victor.azevedo@totvs.com.br
    @since 05/03/2025    
   
    @param cProcedure, Character, Procedure a ser executada
    @param cEmpProc, Character, Empresa a ser processada
    @param lDelTab, Logical, Indica se realiza deleção dos registros nas tabelas F7N E F7I
    @param lReprocess, Logical, Indica se realiza o reprocessamento de determinada procedure
    @param cProcGesp, Character, Tipo de processo configurado para integração
    @param cDataIni, Character, Data inicial para filtro de processamento (utilizado para automação)
    @param cDataFim, Character, Data final para filtro de processamento (utilizado para automação)
   
    @return Nil

/*/
Function ExecProced(cProcedure as Character, cEmpProc as Character, lDelTab as Logical, lReprocess as Logical, cProcGesp as Character, cDataIni as Character, cDataFim as Character)
    
    Local aResult    As Array
    Local aTables    As Array
    Local aParams    As Array
    Local cTenantId  As Character
    Local cDelTable  As Character
    Local cCartD     As Character
    Local cSpace     As Character
    Local cEmpBkp    As Character
    Local cFilBkp    As Character
    Local cStartTime As Character
    Local cMsgInfo   As Character
    Local cMvGesLot  As Character
    Local lCartDesc  As Logical
    Local nX         As Numeric
    Local nDecCNVBS  As Numeric
    
    Default cProcedure  := ""
    Default cEmpProc    := ""
    Default cProcGesp   := ""
    Default lDelTab     := .F.
    Default lReprocess  := .F.
    Default cDataIni    := ""
    Default cDataFim    := ""

    aResult     := {}
    aTables     := {}
    aParams     := {}
    nX          := 0
    cDelTable   := "N"
    cCartD      := "N"
    cSpace      := Space(1)
    cEmpBkp     := ""
    cFilBkp     := ""
    cMsgInfo    := ""
    lCartDesc   := SuperGetMv('MV_GZ0DSC ', .F., .F. ) 
    cMvGesLot   := SuperGetMv('MV_GESLOTR', .F., "2" )
    nDecCNVBS   := TamSx3("F7I_CONVBS")[2]

    If lDelTab
        cDelTable   := "S"
    EndIf

    If lCartDesc
        cCartD  := "S"
    EndIf
    
    GesplanCon(@cTenantId)

    //Executa para cada filial do grupo de empresa enviado
    If !Empty(cProcedure)
        If __lTemLog
            cStartTime := Time()
            cMsgInfo := __cLockNm + " - " + cProcedure + "_" + cEmpProc
            FwLogMsg("INFO",, "FINXGES", __cLockNm, "", "START", cMsgInfo + " started at : "+ FWTimeStamp(2, DATE(), TIME()))
        EndIf
        
        /*
            Estrutura do array aSizes:
            aSizes[1,1] = Nome da tabela;
            aSizes[1,2] = Tamanho total do modo de acesso da tabela (empresa, unidade de negócio e filial);
            aSizes[1,3] = Tamanho do modo de acesso da tabela (empresa);
            aSizes[1,4] = Tamanho do modo de acesso da tabela (unidade de negócio);
            aSizes[1,5] = Tamanho do modo de acesso da tabela (filial);
        */
        
        // Monta a string com os parâmetros conforme o procedimento
        cParametros := ""
        Do Case
            Case cProcedure $ "FIN006_33" .AND. "CR" $ cProcGesp
                aTables := {"SE1", "SED", "CT1", "CTT", "SX5", "SA1", "FRV", "SEV"}
                aSizes  := TablesSize(aTables)
                
                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], ;
                    aSizes[5,2], aSizes[6,2], aSizes[7,2], aSizes[8,2], cEmpProc, cSpace, cSpace, ;
                    cSpace , cTenantId, cDataIni, cDataFim, cDelTable, cCartD, IIF(Intransact(),'1','0'), nDecCNVBS}

                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], aParams[10], aParams[11], ;
                    aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], aParams[17], aParams[18], aParams[19], aParams[20], aParams[21], aParams[22] )

            Case cProcedure $ "FIN007_33" .AND. "CP" $ cProcGesp
                aTables := ({"SE2", "SED", "CT1", "CTT", "SX5", "SA2", "FRV", "SEV"})
                aSizes  := TablesSize(aTables)
                
                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], aSizes[5,2], ;
                    aSizes[6,2], aSizes[7,2], aSizes[8,2], cEmpProc, cSpace, cSpace, cSpace, cTenantId,  cDataIni, ;
                    cDataFim, cDelTable, IIF(Intransact(),'1','0'), nDecCNVBS}
                
                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], aParams[10], aParams[11], ;
                    aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], aParams[17], aParams[18], aParams[19], aParams[20], aParams[21] )

            Case cProcedure $ "FIN008_33" .AND. "CR" $ cProcGesp 
                aTables     := ({"SE1", "SA6", "SED", "CT1", "CTT", "SX5", "SA1", "FRV", "SEV"})
                aSizes      := TablesSize(aTables)

                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], aSizes[5,2], aSizes[6,2], ;
                    aSizes[7,2], aSizes[8,2], aSizes[9,2], cEmpProc, cSpace, cSpace, cSpace, cTenantId,  cDataIni, cDataFim, ; 
                    cDelTable, cCartD, IIF(Intransact(),'1','0'), nDecCNVBS, cMvGesLot}
                
                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], aParams[10], aParams[11], aParams[12], ;
                    aParams[13], aParams[14], aParams[15], aParams[16], aParams[17], aParams[18], aParams[19], aParams[20], aParams[21], aParams[22], aParams[23], aParams[24] ) 

            Case cProcedure $ "FIN009_33" .AND. "CP" $ cProcGesp
                aTables     := ({"SE2", "SA6", "SED", "CT1", "CTT", "SX5", "SA2", "FRV", "SEV"})
                aSizes      := TablesSize(aTables)

                aParams := {cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], aSizes[3,2], aSizes[4,2], aSizes[5,2], aSizes[6,2], ;
                    aSizes[7,2], aSizes[8,2], aSizes[9,2], cEmpProc, cSpace, cSpace, cSpace, cTenantId,  cDataIni, cDataFim, ; 
                    cDelTable, IIF(Intransact(),'1','0'), nDecCNVBS}

                If __lTemLog
                    LogProcs(aParams)
                EndIf

                aResult := TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], aParams[10], aParams[11], ;
                    aParams[12], aParams[13], aParams[14], aParams[15], aParams[16], aParams[17], aParams[18], aParams[19], aParams[20], aParams[21], aParams[22] )

            Case cProcedure $ "FIN010_33" .AND. "MB" $ cProcGesp
                aTables     := ({"FK5", "SA6"})
                aSizes      := TablesSize(aTables)

                aParams := { cProcedure, ;
                    aSizes[1,3], aSizes[1,4], aSizes[1,5], aSizes[2,2], ;
                    cEmpProc,  cDataIni, cDataFim, cSpace, cSpace, cSpace, cDelTable, cMvGesLot, IIF(Intransact(),'1','0')}

                If __lTemLog
                    LogProcs(aParams)
                EndIf
                
                aResult :=  TCSPExec( xProcedures(aParams[1]), ;
                    aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7], aParams[8], aParams[9], aParams[10], aParams[11], ;
                    aParams[12], aParams[13], aParams[14] ) 
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
	Identifica a sequencia de controle do fonte ADVPL com a	stored procedure, qualquer
	alteracao que envolva diretamente a stored procedure a variavel sera incrementada.
	Procedure FIN006,FIN007,FIN008,FIN009 e FIN010
	Processo ?? - Integração Protheus x Gesplan
	@type  StaticFunction
	@author TOTVS
	@since 14/02/2025
    @return character, Retorna a assinatura da rotina
/*/      
Static Function VerIDProc()
Return '001'

/*/{Protheus.doc}  BscGrpEmpr
	Busca os grupos de empresas que foram executados no wizard para configuração das procedures
	@type  StaticFunction
	@author TOTVS
	@since 14/02/2025
    @return array, Retorna os Grupos de Empresas que foram configurados
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

Return cRet

/*/{Protheus.doc} GesplanCon
    Valida se as credenciais de 
    conexão com a Gesplan estão configuradas.
    
    @author victor.azevedo@totvs.com.br
	@since 05/03/2025   
    @param cTenantId, Character, TenantId para conexão
    @return lRetorno, Logical, Indica as credenciais
    de conexão do TPI estão configurdas.
/*/
Static Function GesplanCon(cTenant As Character) as Logical
    
    Local oConfig  As JSon
    
    //Parâmetros de entrada da função
    Default cTenant   := ""
    
    If (FindFunction('FwTechFinVersion') .and. FwTechFinVersion() >= '2.6.1')
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

//-------------------------------
/*/{Protheus.doc} IniStatic
Inicializa variáveis static

@author victor.azevedo@totvs.com.br
@since 05/03/2025
@version P12
/*/
//-------------------------------
Static Function IniStatic()
	
    __cLockNm := "FINXGES"
    __cFIN006 := IIF(FindFunction("GetSPName"), GetSPName("FIN006","33"), "FIN006")
    __cFIN007 := IIF(FindFunction("GetSPName"), GetSPName("FIN007","33"), "FIN007")
    __cFIN008 := IIF(FindFunction("GetSPName"), GetSPName("FIN008","33"), "FIN008")
    __cFIN009 := IIF(FindFunction("GetSPName"), GetSPName("FIN009","33"), "FIN009")
    __cFIN010 := IIF(FindFunction("GetSPName"), GetSPName("FIN010","33"), "FIN010")
    __lTemLog := SuperGetMv( 'MV_GESLOG ', .F., .F. )

Return

/*/{Protheus.doc} SchedDef
	Função que permite ao frame fazer a preparação do
    ambiente de execuçãodo schedule.
	  
    @author victor.azevedo@totvs.com.br
    @since 28/02/2025
    @return aParam, vetor de 5 posições.
/*/
Static Function SchedDef()
	
    Local aParam As Array

	aParam := {"P", "", Nil, Nil, Nil}

Return aParam

/*/{Protheus.doc} EngSPS33Signature
    Processo 33 - Integracaoo Protheus x Gesplan
    Funcoes executadas durante a exibicapo de informacoes detalhadas 
    do processo na interface de gestao de procedures.
    Faz a execucao de funcoes STATIC proprietarias das rotinas donas 
    dos processos.
    @type  Function
    @return character, Assinatura
    @author  TOTVS
    @since   14/02/2025
    @version 12
/*/
Function EngSPS33Signature(cProcess as character)

    Local cAssinatura as character

    cAssinatura := VerIDProc()

Return cAssinatura

Function EngPre33Compile(cProcesso as character, cEmpresa as character, cError as character)
    Local lRet    as Logical
    Local lIntGes as Logical

    lRet    := .T.
    lIntGes := SuperGetMv("MV_FINTGES", .F., .F.)

    If !lIntGes .Or. (lIntGes .And. !ExistStamp(@cError))
        lRet   := .F.
    EndIf

Return lRet

Function EngOn33Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
    Local aSM0 as Array 
    Local nX as Numeric
    Local nTamSM0  as Numeric
    Local nGrupEmp as Numeric
    Local nCompani as Numeric
    Local nCodUnid as Numeric
    Local nCodFil as Numeric

    aSM0 := {}
    nTamSM0  := 0
    aSM0 := FWLoadSM0()  
    nTamSM0 := Len(aSM0)
    
    nGrupEmp := 20
    nCompani := 20
    nCodUnid := 20
    nCodFil  := 20
    
    For nX:= 1 to nTamSM0            
        If Trim(aSM0[nX,1]) == Trim(cEmpresa)
            nGrupEmp  := Len(aSM0[nX,1])  //Grupo de empresa ex "T1"
            nCompani  := Len(aSM0[nX,3])  //Compania ex  "D "
            nCodUnid  := Len(aSM0[nX,4])  //Cod. Empresa ex "MG"
            nCodFil   := Len(aSM0[nX,5])  //Cod. Filial  ex "01"
            exit
        EndIf
    Next nX
    IF ( nCompani < 1 ) 
        nCompani := 1
    EndIf
    IF ( nCodUnid < 1 ) 
        nCodUnid := 1
    EndIf
    cBuffer := StrTran( cBuffer, "'##GROUPEMPRESA'",  cValTochar(nGrupEmp) )
    cBuffer := StrTran( cBuffer, "'##COMPANIA'",      cValTochar(nCompani) )
    cBuffer := StrTran( cBuffer, "'##COD_UNID'",      cValTochar(nCodUnid) )
    cBuffer := StrTran( cBuffer, "'##COD_FIL'",       cValTochar(nCodFil) )
    cBuffer := StrTran( cBuffer, "'F7I_DSCMDA'",      cValTochar(LEN(X6Conteud())))
    cBuffer := StrTran( cBuffer, "'F7I_DSCMDB'",      cValTochar(LEN(X6Conteud())))
	If AliasIndic("F7O")
        Do Case
            Case cProcName == 'FIN007'
                FlexField(@cBuffer,'1',"F7I")
            Case cProcName == 'FIN006'
                FlexField(@cBuffer,'2',"F7I")
            Case cProcName == 'FIN009'
                FlexField(@cBuffer,'3',"F7I")
            Case cProcName == 'FIN008'
                FlexField(@cBuffer,'4',"F7I")
            Case cProcName == 'FIN010'
                cBuffer := StrTran( cBuffer, "'F7N_DSCMDA'", cValTochar(LEN(X6Conteud())))
                FlexField(@cBuffer,'5',"F7N")
        End Case
    EndIf
Return .T.

Function EngPos33Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)
    
    Local cSubstri as Character
    Local cReplica as Character
    Local cSoma    as Character
    Local cVariabl as Character
    Local cVariaIn as Character
    Local cType    as Character

    cType    := "VARCHAR"
    cSubstri := "Substring"
    cReplica := "Replicate"
    cSoma    := '+'
    cVariabl := "@"
    cVariaIn := "@"
        
    If  cLocalDB $ "ORACLE|POSTGRES"
        If cLocalDB == "ORACLE"
            cType := "VARCHAR2(10)"
        EndIf
        cSubstri := "Substr"
        cReplica := "RPAD"
        cSoma    := ' || '
        cVariabl := "v"
        cVariaIn := ""
    EndIf

    cBuffer := StrTran( cBuffer, "121", '127' )

	If cProcName == 'FIN008'
        cBuffer := StrTran(cBuffer, "'##ROW_NUMBER'", "ROW_NUMBER() OVER (PARTITION BY fk5.FK5_IDMOV, sev.EV_MSUID, sez.EZ_MSUID ORDER BY fk5.R_E_C_N_O_ DESC)")
        cBuffer := StrTran(cBuffer, "'##ROW_NUMBER_FKA'", "ROW_NUMBER() OVER (PARTITION BY fk5.FK5_IDMOV, sev.EV_MSUID, sez.EZ_MSUID, fk1.FK1_IDFK1 ORDER BY fk5.R_E_C_N_O_ DESC)")
        cBuffer := StrTran(cBuffer, "'##ROW_NUMBER_FWI'", "ROW_NUMBER() OVER (PARTITION BY stg_se1.E1_FILIAL,stg_se1.E1_PREFIXO,stg_se1.E1_NUM,stg_se1.E1_PARCELA,stg_se1.E1_TIPO, sev.EV_MSUID, sez.EZ_MSUID ORDER BY fwi.R_E_C_N_O_ DESC)")
        cBuffer := StrTran(cBuffer, "CONVERT( datetime ,@F7I_EMIS1 ,127 )", "CONVERT( datetime ,@F7I_EMIS1 ,121 )")    
        //Ajuste CTE
        cBuffer := StrTran(cBuffer, "SELECT '##CTE_FILIAL ", " WITH MAP_FILIAL AS ("+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", " SELECT map_sm0.M0_CODFIL AS MAP_FILORIG, "+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMSA6)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMSA6) AS " +cType+ ") AS SA6_FILIAL,"+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMSED)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMSED) AS " +cType+ ") AS SED_FILIAL,"+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMSX5)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMSX5) AS " +cType+ ") AS SX5_FILIAL,"+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMSA1)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMSA1) AS " +cType+ ") AS SA1_FILIAL,"+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMFRV)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMFRV) AS " +cType+ ") AS FRV_FILIAL,"+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "    CAST("+cSubstri+"(map_sm0.M0_CODFIL,1,"+cVariaIn+"IN_TAMSEV)"+cSoma+cReplica+"(' ', "+cVariabl+"N_TAMTOTAL - "+cVariaIn+"IN_TAMSEV) AS " +cType+ ") AS SEV_FILIAL "+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "  FROM SYS_COMPANY map_sm0 "+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "  WHERE map_sm0.M0_CODIGO = "+cVariaIn+"IN_GROUPEMPRESA "+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "        AND map_sm0.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)+"XXMAPFILIAL" )
        cBuffer := StrTran(cBuffer, "XXMAPFILIAL", "), " +CHR(13)+CHR(10))  

        cBuffer := StrTran(cBuffer, "##MAP_MOEDA'", " MAP_MOEDA AS ("+CHR(13)+CHR(10)+"XXMAP_MOEDA" )
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", " SELECT Cast("+cSubstri+"(SX6.X6_VAR,9,2) as Float) SX6_MOEDA, "+CHR(13)+CHR(10)+"XXMAP_MOEDA" )
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", "        X6_CONTEUD AS DESC_MOEDA "+CHR(13)+CHR(10)+"XXMAP_MOEDA" )
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", " FROM "+  RetSqlName("SX6") + " SX6 "+CHR(13)+CHR(10)+"XXMAP_MOEDA" )
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", " WHERE SX6.X6_VAR like 'MV_MOEDA%' "+CHR(13)+CHR(10)+"XXMAP_MOEDA" )        
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", "      AND "+cSubstri+"(SX6.X6_VAR,9,1) <= '99'"+CHR(13)+CHR(10)+"XXMAP_MOEDA" )
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", "      AND SX6.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)+"XXMAP_MOEDA" )        
        cBuffer := StrTran(cBuffer, "XXMAP_MOEDA", ") " +CHR(13)+CHR(10)+ " SELECT Origem " )   
	EndIf

    If cProcName == 'FIN009'
        cBuffer := StrTran(cBuffer, "'##ROW_NUMBER'", "ROW_NUMBER() OVER (PARTITION BY fk5.FK5_IDMOV, sev.EV_MSUID, sez.EZ_MSUID ORDER BY fk5.R_E_C_N_O_ DESC)")
        cBuffer := StrTran(cBuffer, "CONVERT( datetime ,@F7I_EMIS1 ,127 )", "CONVERT( datetime ,@F7I_EMIS1 ,121 )")
	EndIf

    If cProcName == 'FIN010'
        cBuffer := StrTran(cBuffer, "CONVERT( datetime ,stg.FK5_DATA ,127 )", "CONVERT( datetime ,stg.FK5_DATA ,121 )")
    Endif
    If  cLocalDB == "MSSQL"
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '" , " WITH (READCOMMITTED) ")
        If cProcName == 'FIN006'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,se1_principal.stamp_se1 ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = se1_principal.stamp_se1")
        EndIf
        If cProcName == 'FIN007'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,se2_principal.stamp_se2 ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = se2_principal.stamp_se2")
        EndIf
        If cProcName == 'FIN008'

            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 25 ) ,fk5.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = fk5.S_T_A_M_P_")
        EndIf
        If cProcName == 'FIN009'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,fk5.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = fk5.S_T_A_M_P_")
            cBuffer := StrTran(cBuffer, "fk5.FK5_IDDOC  = fk7.FK7_IDDOC" , "fk7.FK7_IDDOC = case when fk5.FK5_IDDOC = ' ' then fk5.FK5_IDFK7 else fk5.FK5_IDDOC end")
        EndIf
        If cProcName == 'FIN010'
            cBuffer := StrTran(cBuffer, "and TRIM ( f7j.F7J_STAMP ) = CONVERT( Char( 26 ) ,stg.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,f7j.F7J_STAMP ,127 ) = stg.S_T_A_M_P_")
        EndIf
    Else
        If cLocalDB == "ORACLE"
            If cProcName == 'FIN006'

                cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRP' );" , "WHERE F7J.F7J_ALIAS  = 'CRP' ;")

                cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (TRIM (IN_mdmTenantId ), protheus_pk , E1_FILORIG )),'YY.MM.DD'))" , "LOWER(STANDARD_HASH( TRIM (IN_mdmTenantId ) || protheus_pk  || E1_FILORIG, 'MD5') )")

                cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = ' ' ;")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE1_CCUSTO  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vE1_CCUSTO  AND D_E_L_E_T_  = ' ' ;")
            
                //tempo 
                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
                cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE1_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vE1_BAIXA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7I_EMIS1 , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR',", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD')")
                cBuffer := StrTran(cBuffer, "-2 , SYSDATE ),'YYYYMMDD')", " ")
                cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
                cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
                cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
                
            EndIf
            If cProcName == 'FIN007'

                cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPP' )" , "WHERE F7J.F7J_ALIAS  = 'CPP' ")

                cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (IN_mdmTenantId , protheus_pk , E2_FILORIG )),'YY.MM.DD'))" , "LOWER(STANDARD_HASH( TRIM (IN_mdmTenantId ) || protheus_pk  || E2_FILORIG, 'MD5') )")

                cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := ' ' )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vED_CCD AND D_E_L_E_T_  = ' ' ")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE2_CCUSTO  AND D_E_L_E_T_  := ' ' )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vE2_CCUSTO AND D_E_L_E_T_ = ' '")
            
                //tempo 
                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
                cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")                
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vE2_BAIXA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vE2_BAIXA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7I_EMIS1 , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                // cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR',", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD')")
                cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vF7I_STAMP ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "vF7I_STAMP DATE", "vF7I_STAMP TIMESTAMP")
                cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
                cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
                cBuffer := StrTran(cBuffer, "TO_DATE(se2_principal.E2_EMIS1", "TO_TIMESTAMP(se2_principal.E2_EMIS1 ,'YYYY-MM-DD' ")
                
            EndIf
            If cProcName == 'FIN008'                
                //Tratamento para carteira descontada
                cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' ," , "LOWER(STANDARD_HASH( ")
                cBuffer := StrTran(cBuffer, "CONCAT (TRIM (IN_mdmTenantId ), protheus_pk , FWI_SEQ )),'YY.MM.DD'))" , "TRIM (IN_mdmTenantId ) || protheus_pk  || FWI_SEQ, 'MD5') )")
                
                cBuffer := StrTran(cBuffer, "vfk5_S_T_A_M_P_ DATE" , "vfk5_S_T_A_M_P_ TIMESTAMP")
                cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE" , "vmaxStagingCounter TIMESTAMP")
                cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vdelTransactTime, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
                //Ajuste para o campo vcStamp
                cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRR' );" , "WHERE F7J.F7J_ALIAS  = 'CRR' ;")
                //Ajuste para o campo vF7I_DSCMDB
                cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
                cBuffer := StrTran(cBuffer, "SX6.X6_CONTEUD" , " SX6.X6_CONTEUD INTO vF7I_DSCMDB ")
                cBuffer := StrTran(cBuffer, "TRIM (SX6.X6_VAR ) :=" , "TRIM (SX6.X6_VAR ) = ")
                cBuffer := StrTran(cBuffer, "AND SX6.D_E_L_E_T_  := ' ' )" , "AND SX6.D_E_L_E_T_  = ' '")     
                //Ajuste para o campo @cF7I_STAMP
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vcFk5_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3'), 'yyyy-MM-ddTHH:mm:ss.fff' );" , "vcFk5_STAMP;" )
                //Ajuste para o campo @vmaxStagingCounter
                cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vcStamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
                //Ajuste para o campo vcFk5_STAMP
                cBuffer := StrTran(cBuffer, "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_CHAR(vfk5_S_T_A_M_P_, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
                //Ajuste para o campo vF7I_DSCCCT
                cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                //Ajuste para o campo vfilialCTT
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = ' ' ;")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE1_CCUSTO  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vE1_CCUSTO  AND D_E_L_E_T_  = ' ' ;")            
                //tempo 
                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD');", "TO_CHAR(ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD');")
            EndIf
            If cProcName == 'FIN009'

                cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPR' )" , "WHERE F7J.F7J_ALIAS  = 'CPR' ")


                cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCD  AND D_E_L_E_T_  = ' ' ;")
                cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM SX6### SX6C" , "INTO vF7I_DSCMDB FROM SX6### SX6C ")
                cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6C.X6_VAR ) := CONCAT ('MV_MOEDA" , "WHERE TRIM (SX6C.X6_VAR ) = CONCAT ('MV_MOEDA")
                cBuffer := StrTran(cBuffer, ") )) AND SX6C.D_E_L_E_T_  := ' ' )" , ") )) AND SX6C.D_E_L_E_T_  = ' ' ")
                
                //tempo 
                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
                cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
                cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
                cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
                cBuffer := StrTran(cBuffer,'vse2_S_T_A_M_P_ DATE','vse2_S_T_A_M_P_ TIMESTAMP')
                cBuffer := StrTran(cBuffer,'vfk7_S_T_A_M_P_ DATE','vfk7_S_T_A_M_P_ TIMESTAMP')
                cBuffer := StrTran(cBuffer,'vfk2_S_T_A_M_P_ DATE','vfk2_S_T_A_M_P_ TIMESTAMP')
                cBuffer := StrTran(cBuffer,'vfka_S_T_A_M_P_ DATE','vfka_S_T_A_M_P_ TIMESTAMP')
                cBuffer := StrTran(cBuffer,'vfk5_S_T_A_M_P_ DATE','vfk5_S_T_A_M_P_ TIMESTAMP')

                cBuffer := StrTran(cBuffer, "TO_DATE(stg_se2.E2_EMIS1", "TO_TIMESTAMP(stg_se2.E2_EMIS1 ,'YYYY-MM-DD' ")
                cBuffer := StrTran(cBuffer, "fk5.FK5_IDDOC  = fk7.FK7_IDDOC" , "fk7.FK7_IDDOC = case when fk5.FK5_IDDOC = ' ' then fk5.FK5_IDFK7 else fk5.FK5_IDDOC end")
            EndIf
            If cProcName == 'FIN010'

                cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'MVB' )" , "WHERE F7J.F7J_ALIAS  = 'MVB' ")

                cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
                cBuffer := StrTran(cBuffer, "MSDATEADD_33_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
               
                cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7N_DATA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_TIMESTAMP(vF7N_DATA , 'YYYYMMDD'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                
                cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_DATE(stg.FK5_DATA ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(stg.FK5_DATA ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                
                cBuffer := StrTran(cBuffer, "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                cBuffer := StrTran(cBuffer, "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                
                
                cBuffer := StrTran(cBuffer, "vS_T_A_M_P_FK5 DATE", "vS_T_A_M_P_FK5 TIMESTAMP")
                cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")

                cBuffer := StrTran(cBuffer, "TO_DATE(''", "TO_TIMESTAMP('1900-01-01'")
            EndIf 
        Else 
	        // POSTGRES
            Do Case
                Case  cProcName == 'FIN006'

                    cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                    cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRP' );" , "WHERE F7J.F7J_ALIAS  = 'CRP' ;")

                    cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (TRIM (IN_mdmTenantId )::bpchar , protheus_pk ," , "lower(md5(trim(in_mdmTenantId) || protheus_pk || E1_FILORIG)) as F7I_EXTCDH")
                    cBuffer := StrTran(cBuffer, "E1_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , " ")

                    cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = ' ' ;")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE1_CCUSTO  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vE1_CCUSTO  AND D_E_L_E_T_  = ' ' ;")
                
                    //tempo 
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
                    cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    cBuffer := StrTran(cBuffer, "TO_DATE(se1_principal.E1_EMIS1", "TO_TIMESTAMP(se1_principal.E1_EMIS1 ,'YYYYMMDD'")
                
                Case cProcName == 'FIN007'

                    cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                    cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPP' )" , "WHERE F7J.F7J_ALIAS  = 'CPP' ")

                    cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' , CONCAT (IN_mdmTenantId , protheus_pk , E2_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , "lower(md5(trim(in_mdmTenantId) || protheus_pk || E2_FILORIG)) as F7I_EXTCDH")
                    cBuffer := StrTran(cBuffer, "E2_FILORIG )::bpchar ),'YY.MM.DD'))::bpchar  as F7I_EXTCDH" , " ")

                    cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := ' ' )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vED_CCD AND D_E_L_E_T_  = ' ' ")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vE2_CCUSTO  AND D_E_L_E_T_  := ' ' )" , "WHERE CTT_FILIAL = vfilialCTT AND CTT_CUSTO = vE2_CCUSTO AND D_E_L_E_T_ = ' '")
                
                    //tempo 
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
                    cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
                    cBuffer := StrTran(cBuffer, "TO_DATE(se2_principal.E2_EMIS1", "TO_TIMESTAMP(se2_principal.E2_EMIS1 ,'YYYYMMDD'")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                
                Case cProcName == 'FIN008'

                    cBuffer := StrTran(cBuffer, "LOWER (TO_CHAR(HASHBYTES ('MD5' ," , "lower(md5(trim(in_mdmTenantId) || protheus_pk || FWI_SEQ)) as FK1_IDFK1")
                    cBuffer := StrTran(cBuffer, "CONCAT (TRIM (IN_mdmTenantId )::bpchar , protheus_pk , FWI_SEQ )::bpchar ),'YY.MM.DD'))::bpchar  as FK1_IDFK1" , " ")
                
                    cBuffer := StrTran(cBuffer, "vfk5_S_T_A_M_P_ DATE" , "vfk5_S_T_A_M_P_ TIMESTAMP")
                    cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE" , "vmaxStagingCounter TIMESTAMP")
                    cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TO_TIMESTAMP(vdelTransactTime, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
                    cBuffer := StrTran(cBuffer, "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "= TO_CHAR(fk5.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")                
                    //Ajuste para o campo vcStamp
                    cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                    cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CRR' );" , "WHERE F7J.F7J_ALIAS  = 'CRR' ;")
                    //Ajuste para o campo vF7I_DSCMDB
                    cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
                    cBuffer := StrTran(cBuffer, "SX6.X6_CONTEUD" , " SX6.X6_CONTEUD INTO vF7I_DSCMDB ")

                    cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6.X6_VAR )::bpchar  := CONCAT( 'MV_MOEDA'" , "WHERE TRIM (SX6.X6_VAR )::bpchar  = CONCAT( 'MV_MOEDA'") 
                    cBuffer := StrTran(cBuffer, ") )::bpchar )::bpchar  AND SX6.D_E_L_E_T_  := ' ' )" , ") )::bpchar )::bpchar  AND SX6.D_E_L_E_T_  = ' ' ")   

                    cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vcFk5_STAMP ,'YYYY-MM-DD HH24:MI:SS.FF3'), 'yyyy-MM-ddTHH:mm:ss.fff' );" , "vcFk5_STAMP;" )
                    cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')" ,  "TO_CHAR(vfk5_S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")                
                    cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCC  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCC  AND D_E_L_E_T_  = ' ' ;")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
           
                Case cProcName == 'FIN009'

                    cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                    cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'CPR' )" , "WHERE F7J.F7J_ALIAS  = 'CPR' ")


                    cBuffer := StrTran(cBuffer, "vF7I_DSCCCT  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM CTT###" , "INTO vF7I_DSCCCT  FROM CTT### ")
                    cBuffer := StrTran(cBuffer, "WHERE CTT_FILIAL  := vfilialCTT  AND CTT_CUSTO  := vED_CCD  AND D_E_L_E_T_  := ' ' );" , "WHERE CTT_FILIAL  = vfilialCTT  AND CTT_CUSTO  = vED_CCD  AND D_E_L_E_T_  = ' ' ;")
                    cBuffer := StrTran(cBuffer, "vF7I_DSCMDB  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM SX6### SX6C" , "INTO vF7I_DSCMDB FROM SX6### SX6C ")
                    
                    cBuffer := StrTran(cBuffer, "WHERE TRIM (SX6C.X6_VAR )::bpchar  := CONCAT ('MV_MOEDA' , TRIM (" , "WHERE TRIM (SX6C.X6_VAR )::bpchar  = CONCAT ('MV_MOEDA' , TRIM (") 
                    cBuffer := StrTran(cBuffer, ") )::bpchar )::bpchar  AND SX6C.D_E_L_E_T_  := ' ' )" , ") )::bpchar )::bpchar  AND SX6C.D_E_L_E_T_  = ' ' ")
                    
                    //tempo 
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
                    cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
                    cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
                    cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
                    cBuffer := StrTran(cBuffer,'vse2_S_T_A_M_P_ DATE','vse2_S_T_A_M_P_ TIMESTAMP')
                    cBuffer := StrTran(cBuffer,'vfk7_S_T_A_M_P_ DATE','vfk7_S_T_A_M_P_ TIMESTAMP')
                    cBuffer := StrTran(cBuffer,'vfk2_S_T_A_M_P_ DATE','vfk2_S_T_A_M_P_ TIMESTAMP')
                    cBuffer := StrTran(cBuffer,'vfka_S_T_A_M_P_ DATE','vfka_S_T_A_M_P_ TIMESTAMP')
                    cBuffer := StrTran(cBuffer,'vfk5_S_T_A_M_P_ DATE','vfk5_S_T_A_M_P_ TIMESTAMP')
                    
                    cBuffer := StrTran(cBuffer, "TO_DATE(stg_se2.E2_EMIS1", "TO_TIMESTAMP(stg_se2.E2_EMIS1 ,'YYYYMMDD'")
                    cBuffer := StrTran(cBuffer, "fk5.FK5_IDDOC  = fk7.FK7_IDDOC" , "fk7.FK7_IDDOC = case when fk5.FK5_IDDOC = ' ' then fk5.FK5_IDFK7 else fk5.FK5_IDDOC end")
                
                Case cProcName == 'FIN010'

                    cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
                    cBuffer := StrTran(cBuffer, "FROM F7J### F7J" , " INTO vcStamp FROM F7J### F7J ")
                    cBuffer := StrTran(cBuffer, "WHERE F7J.F7J_ALIAS  := 'MVB' )" , "WHERE F7J.F7J_ALIAS  = 'MVB' ")

                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    cBuffer := StrTran(cBuffer, "TO_DATE('' ,'YYYY-MM-DD HH24:MI:SS.FF3')" , "TIMESTAMP '1900-01-01 00:00:00' ")  //INIFILTER
                    cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_33_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - interval '2 years', 'YYYYMMDD')")
                
                    cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
                    cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")

                    cBuffer := StrTran(cBuffer, "FORMAT (TO_DATE(vF7N_DATA ), 'yyyy-MM-ddTHH:mm:ss.fff' )", "TO_CHAR(TO_DATE(vF7N_DATA, 'YYYYMMDD')::timestamp, 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    
                    
                    cBuffer := StrTran(cBuffer, "TO_DATE(stg.FK5_DATA ,'YYYY-MM-DD HH24:MI:SS.FF3')", "stg.fk5_data::timestamp")
                    
                    cBuffer := StrTran(cBuffer, "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(vS_T_A_M_P_FK5 ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    cBuffer := StrTran(cBuffer, "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_CHAR(stg.S_T_A_M_P_ ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
                    
                    
                    cBuffer := StrTran(cBuffer, "vS_T_A_M_P_FK5 DATE", "vS_T_A_M_P_FK5 TIMESTAMP")
                    cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            EndCase

        EndIf
        cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
    EndIf
    
    cBuffer := StrTran( cBuffer, "SX6###", RetSqlName("SX6") ) 

    If cProcName == 'FIN010'
        If ChkFixGes()
            AtuMvFix("1")
        EndIf 
    EndIf

Return  .T.

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

Static Function FlexField(cBuffer as character,cOrigem  as character,cTable  as character)

    Local aArea	AS ARRAY
    Local cDeclare   := "" as character
    Local cSelCursor := "" as character
    Local cCampo     := "" as character
    Local cCursor    := "" as character
    Local cVariaveis := "" as character
    Local cInsert    := "" as character
    Local cPrincipal := "" as character

    aArea:= GetArea()
     
    dbSelectArea("F7O")

    F7O->(dbSetOrder(1)) 
    //F7O_FILIAL, F7O_ORIGEM, F7O_TABELA, F7O_COLUNA, R_E_C_N_O_, D_E_L_E_T_
    
    If F7O->(dbSeek(xFilial("F7O")+cOrigem))
        Do While F7O->(!Eof()) .And. F7O->F7O_ORIGEM == cOrigem
            cDeclare += ' declare @F' + F7O->F7O_COLUNA + ' char(' +  IIF(val(F7O->F7O_FLEX)>10,'100)','30)') + CRLF
            cSelCursor += ' , '+ F7O->F7O_COLUNA + ' as F7I_FLXF'+ F7O->F7O_FLEX
            If AT( '.'+ RTrim(F7O->F7O_COLUNA) , cBuffer ) == 0 
                If 'E2_'$ F7O->F7O_COLUNA .or. 'E1_' $ F7O->F7O_COLUNA
                    cPrincipal +=  ' , ' +  F7O->F7O_COLUNA //Lower(F7O->F7O_TABELA) +'.'+
                Else
                    cCampo +=  ' , ' +  F7O->F7O_COLUNA //Lower(F7O->F7O_TABELA) +'.'+
                EndIf
            EndIf 
            cCursor +=  ' , ' +'@F' + F7O->F7O_COLUNA
            cVariaveis +=  " , IsNull(" +'@F' + F7O->F7O_COLUNA +", ' ') "
            cInsert +=  ' ,  '+cTable+'_FLXF' + F7O->F7O_FLEX
            // usar o cCursor cVariaveis +=
            F7O->(dbSkip())
        EndDo
        cBuffer := StrTran( cBuffer, "--#cursorflex",  cCursor )
        cBuffer := StrTran( cBuffer, "--#insertflex",  cInsert )
        cBuffer := StrTran( cBuffer, "--#variaveisflex",  cVariaveis )
    EndIf
    cBuffer := StrTran( cBuffer, ",'#selectcursorflex' as cursorflex",  cSelCursor )
    cBuffer := StrTran( cBuffer, ",'#campoflex' as campoflex", cPrincipal + cCampo )
    cBuffer := StrTran( cBuffer, ",'#campoflexprincipal' as campoflexprincipal", cPrincipal  )
    cBuffer := StrTran( cBuffer, "declare flex char(1)",  cDeclare )

    RestArea(aArea)
    FwFreeArray(aArea)

Return

/*/{Protheus.doc} ChkFileGes
    Função para gerar as tabelas de integração Gesplan
    @type  Static Function
    @author Luiz Gustavo R. Jesus
    @since 27/05/2025
/*/
Static Function ChkFileGes()
    Local aTab as Array
    Local nX   as Numeric
    
    aTab := {'F7I','F7J','F7O','F7N'}
    
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
    
    cQry := "SELECT "        
    cQry += "   FK5.R_E_C_N_O_"
    cQry += "FROM "
    cQry += "   "+ RetSqlName("FK5") +" FK5 "    
    cQry += "WHERE "
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

    FwFreeObj(oQuery)
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
        cQry    := ""
        cQry	+= " UPDATE " +RetSqlName("FK5")
        cQry 	+= " SET S_T_A_M_P_ =  Null " 
        cQry 	+= " WHERE R_E_C_N_O_ IN (?)" 

        oStatement := FwExecStatement():New(cQry) 
        oStatement:setIn(nParam++, aRec)                
        
        If TcSqlExec(oStatement:getFixQuery()) != 0
            FwLogMsg("ERROR",, "FINXGES", __cLockNm, "", "GesUpStamp", TCSQLError()) //Ocorreu um erro inesperado na atualização do campo S_T_A_M_P_
            lRet      := .F.
        EndIf    

        FwFreeObj(oStatement)
    EndIf

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistStamp
@type           function
@description    Valida se todos os STAMPS estão criados.
@author         victor.azevedo@totvs.com.br
@since          23/09/2025
/*/
//-------------------------------------------------------------------------------------\-----------
Static function ExistStamp(cError) as Logical
    Local aTables       as Array
    Local lRet          as Logical
    Local nLenTbl       as Numeric
    Local nCountTbls    as Numeric
    Local nI            as Numeric

    Default cError := ""

    aTables    := {'SE1', 'SE2','FK5'}
    cMsg       := ""
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
