#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'PCPA160.CH'

Static __cIDThr    := ""
Static __cErrorUID := ""

/*/{Protheus.doc} a160VldReq()
Valida se a utilização da requisição pendente está ativa
Considerando todos os pré-requisitos

@author michele.girardi
@since 23/01/2026
@param: lMemory - Indica se utiliza variavel de memória ou não 
@return: T - Está ativa ou F - Não está ativa
/*/
Function a160VldReq(lMemory)
    Local aArea       := GetArea()
    Local aBaixaSGF   := {}
    Local cDevAut	  := ""
    Local cHoraIni    := ""
    Local cHoraFim    := ""
    Local cObserva    := ""
    Local cOp         := ""
    Local cOperac     := ""
    Local cProduto    := ""
    Local cReqAut	  := ""
    Local cTmPad      := ""
    Local lAponTemp   := .F.
    Local lEmp        := .F.
    Local lEncerra    := .F.
    Local lExFilds    := .F.
    Local lMes        := .F.
    Local lRet        := .T.
    Local lUltOper    := .F.
    Local nQtdProd    := 0
    Local nQtdPerd    := 0

    Default lMemory   := .F.

    Static lA160GERZ0 := Nil

    lA160GERZ0 := Iif (lA160GERZ0==Nil,ExistBlock('A160GERZ0'),lA160GERZ0)

    lEncerra := IsInCallStack("A680Encer")

    If !IsInCallStack("MATI681")
        lRet := .F.
    EndIf

    If lRet
        lExFilds  := a160Filds()
        //Verifica se existem os campos e tabelas da Requisição Pendente
        If !lExFilds
            lRet := .F.
        EndIf
    EndIf
    
    If lRet
        cHoraIni := If(lMemory,M->H6_HORAINI,SH6->H6_HORAINI)
        cHoraFim := If(lMemory,M->H6_HORAFIN,SH6->H6_HORAFIN)
        cObserva := If(lMemory,M->H6_OBSERVA,SH6->H6_OBSERVA)
        cOp      := If(lMemory,M->H6_OP,SH6->H6_OP)
        cOperac  := If(lMemory,M->H6_OPERAC,SH6->H6_OPERAC)
        cProduto := If(lMemory,M->H6_PRODUTO,SH6->H6_PRODUTO)
        nQtdProd := If(lMemory,M->H6_QTDPROD,SH6->H6_QTDPROD)
        nQtdPerd := If(lMemory,M->H6_QTDPERD,SH6->H6_QTDPERD)
    EndIf

    If lRet .And. !lEncerra
        //Apontamento realizado pelo TOTVSMES
        lMes := AllTrim(cObserva) == "TOTVSMES"
        If !lMes
            lRet := .F.
        EndIf
    EndIf

    //Verifica se existe algum empenho com lote/endereço empenhado
    If lRet
        lEmp := a160ExtEmp(cOp)
        If lEmp
            lRet := .F.
        EndIf
    EndIf

    If lRet
        lAponTemp := Iif(MV_PAR04 == 1 .AND. !Empty(cHoraIni) .AND. !Empty(cHoraFim) .AND. nQtdProd == 0 .AND. nQtdPerd == 0,.T.,.F.)
        lUltOper  := A680UltOper(lMemory)
    EndIf

    If !lA160GERZ0
        If lRet .And. !lEncerra
            //Apontamento somente de quantidade boas
            If lAponTemp .Or. nQtdPerd <> 0
                lRet := .F.
            EndIf
        EndIf

        If lRet .And. !lEncerra
            //Apontamento da última operação ou componente na operação intermediária
            aBaixaSGF := A637BxComp(cProduto, A680RotPad(), cOperac, cOp)

            If !lUltOper .And. aBaixaSGF == Nil
                lRet := .F.
            EndIf
        EndIf
    EndIf

    If lRet
        //OP deve estar parametrizada para trabalhar com Requisição Pendente - C2_REQPEND = 1
        dbSelectArea("SC2")
        SC2->(dbSetOrder(1))
        If SC2->(dbSeek(xFilial("SC2")+cOp))
            If Empty(SC2->C2_REQPEND) .Or. SC2->C2_REQPEND <> '1'
                lRet := .F.
            EndIf
        EndIf
    EndIf

    If lRet
        //TOTVSMES deve estar parametrizado para realizar o consumo dos componentes por BackFlush
        dbSelectArea("SOE")
        SOE->(dbSetOrder(1))
        SOE->(dbSeek(xFilial("SOE")+"SC2"))
        If AllTrim(SOE->OE_VAR1) == "2" .Or. AllTrim(SOE->OE_VAR1) == "3"
            lRet := .F.
        EndIf
    EndIf

    If lRet
        //Verifica se o tipo de movimento atualiza estoque
        cTmPad := GetMV("MV_TMPAD")
        dbSelectArea("SF5")
	    SF5->(dbSetOrder(1))
	    SF5->(dbSeek(xFilial("SF5")+cTmPad))
        If SF5->F5_ATUEMP <> 'S'
            lRet := .F.
        EndIf
    EndIf

    If lRet
        cReqAut	:= A250ReqAut(GetMv("MV_REQAUT"))
	    cDevAut	:= A250DevAut(SuperGetMV("MV_DEVAUT",.F.,cReqAut))
        //Verifica se o MV_REQAUT e MV_DEVAUT = A
        If cReqAut == "D" .Or. cDevAut == "D"
            lRet := .F.
        EndIf
    EndIf

    RestArea(aArea)
    
Return lRet

/*/{Protheus.doc} a160ExtEmp()
Verifica se existe algum empenho na SD4 com lote/sublote informado
Verifica se existe algum empenho na SDC com endereço informado

@author michele.girardi
@param: cOp - Ordem de produção
@return: T - Existe lote/sublote/endereço empenhado ou F - Não existe lote/sublote/endereço empenhado
/*/
Function a160ExtEmp(cOp)
    Local cAlias   := ""
    Local cAlias1  := ""
    Local cQry     := ""
    Local cQry1    := ""
    Local lRet     := .F.

    Local oExec    := Nil
    Local oExec1   := Nil

    cQry := " SELECT COUNT(*) COUND4 "
	cQry +=   " FROM " + RetSqlName('SD4') + " SD4 "
	cQry += "  WHERE SD4.D4_FILIAL   = ? "
    cQry += "    AND SD4.D4_OP       = ? "
    cQry += "    AND (SD4.D4_LOTECTL  <> ' ' OR SD4.D4_NUMLOTE <> ' ')
	cQry += "    AND SD4.D_E_L_E_T_  = ' ' "
	
    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("SD4"))
    oExec:setString(2, cOp)

	cAlias := oExec:OpenAlias()

	If (cAlias)->COUND4 > 0
        lRet := .T.
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

    If !lRet
        cQry1 := " SELECT COUNT(*) COUNDC "
        cQry1 +=   " FROM " + RetSqlName('SDC') + " SDC "
        cQry1 += "  WHERE SDC.DC_FILIAL   = ? "
        cQry1 += "    AND SDC.DC_OP       = ? "
        cQry1 += "    AND SDC.DC_QUANT    > 0 "
        cQry1 += "    AND SDC.D_E_L_E_T_  = ' ' "
        
        oExec1 := FwExecStatement():New(cQry1)
        oExec1:setString(1, xFilial("SDC"))
        oExec1:setString(2, cOp)

        cAlias1 := oExec1:OpenAlias()

        If (cAlias1)->COUNDC > 0
            lRet := .T.
        EndIf

        (cAlias1)->(DbCloseArea())        
        oExec1:Destroy()
        FreeObj(oExec1)
    EndIf

Return lRet

/*/{Protheus.doc} a160Filds()
Valida a existência dos campos VK_REQPEND - C2_REQPEND - HWA_REQPEN
Valida a existência das tabelas HZ0 - HZ1 - HZ2 - HZ3 - HZ4

@author michele.girardi
@since 20/01/2026
@return: T - Existem os campos/tabelas ou F - Não existem os campos/tabelas
/*/
Function a160Filds()
    Local lRet	:= .F.

    dbSelectArea("SVK")
    lRet := FieldPos("VK_REQPEND") > 0 

    If lRet
        dbSelectArea("SC2")
        lRet := FieldPos("C2_REQPEND") > 0
    EndIf

    If lRet
        dbSelectArea("HWA")
        lRet := FieldPos("HWA_REQPEN") > 0
    EndIf

    If lRet
        lRet := TableInDic("HZ0")
    EndIf

    If lRet
        lRet := TableInDic("HZ1")
    EndIf

    If lRet
        lRet := TableInDic("HZ2")
    EndIf

    If lRet
        lRet := TableInDic("HZ3")
    EndIf

    If lRet
        lRet := TableInDic("HZ4")
    EndIf

Return lRet

/*/{Protheus.doc} a160GTabZ0()
Grava a tabela de controle das requisições pendentes - HZ0
Esta tabela é grava com base no apontamento realizado

@author michele.girardi
@since 23/01/2026
@param 01: cIdent   - Referente ao campo H6_IDENT do apontamento corrente
@param 02: cOp      - Referente ao campo H6_OP do apontamento corrente
@param 03: dDtApont - Referente ao campo D3_EMISSAO do apontamento corrente
@param 04: lEncOP   - Indica se o apontamento deve encerrar a OP
@param 05: cSeqPvt  - Retorna a variável private para gravar as tabelas filhas
@param 06: cIdtPvt  - Retorna a variável private para gravar as tabelas filhas
@param 07: lSoEnc   - Indica se o apontamento é referente somente ao encerramento da OP 
                      Sem produção e sem requisição - Pelo TOTVS MES é possível realizar somente o encerramento da OP
@return: Nil
/*/
Function a160GTabZ0(cIdent, cOp, dDtApont, lEncOP,cSeqPvt,cIdtPvt,lSoEnc)
    Local cEncOP      := ""
    Local cReqTot     := ""
    Local cSeq        := ""
    Local lA160ATUHZ0 := ExistBlock('A160ATUHZ0')
    Local lUsaIdInt   := Iif(Type('cMesIDIntg')=="C",.T.,.F.)

    Default lSoEnc := .F.

    If lSoEnc
        cReqTot := 'E'
    Else
        cReqTot := 'N'
    EndIf

    cSeq := GETSXENUM("HZ0","HZ0_SEQ")
    cEncOP  := Iif (lEncOP,'S','N')

    dbselectarea("HZ0")
    RecLock("HZ0",.T.)
        REPLACE HZ0->HZ0_FILIAL 	WITH xFilial("HZ0")
        REPLACE HZ0->HZ0_SEQ 		WITH cSeq
        REPLACE HZ0->HZ0_IDENT		WITH cIdent
        REPLACE HZ0->HZ0_OP		    WITH cOp
        REPLACE HZ0->HZ0_ENCOP		WITH cEncOP
        REPLACE HZ0->HZ0_REQTOT		WITH cReqTot
        REPLACE HZ0->HZ0_ESTORN 	WITH "N"
        REPLACE HZ0->HZ0_DTINCL 	WITH Date()
        REPLACE HZ0->HZ0_HRINCL 	WITH Time()  
        REPLACE HZ0->HZ0_DTAPON 	WITH dDtApont
        REPLACE HZ0->HZ0_ANALIS 	WITH "N"
        REPLACE HZ0->HZ0_PRCENC 	WITH "N"
        REPLACE HZ0->HZ0_IDMES   	WITH Iif(lUsaIdInt,cMesIDIntg,"")
    HZ0->(MSUNLOCK())

    ConfirmSX8()

    If lA160ATUHZ0
        ExecBlock('A160ATUHZ0', .F.,.F.)
    EndIf

    cSeqPvt := cSeq
    cIdtPvt := cIdent
Return Nil

/*/{Protheus.doc} a160GTabZ1()
Grava a tabela das requisições pendentes - HZ1

@author michele.girardi
@since 23/01/2026
@param 01: cOp        - Referente ao campo D4_OP 
@param 02: cComp      - Referente ao campo D4_COD
@param 03: cTrt       - Referente ao campo D4_TRT
@param 04: cLocal     - Referente ao campo D4_LOCAL
@param 05: nQtd       - Quantidade a ser requisitada do componente
@param 06: cLote      - Referente ao campo D4_LOTECTL
@param 07: cSubLote   - Referente ao campo D4_NUMLOTE
@param 08: dDataValid - Referente ao campo D4_DTVALID
@param 09: cOpOrig    - Referente ao campo D4_OPORIG
@return: Nil
/*/
Function a160GTabZ1(cOp,cComp,cTrt,cLocal,nQtd,cLote,cSubLote,dDataValid,cOpOrig)

    dbselectarea("HZ1")
    RecLock("HZ1",.T.)
        REPLACE HZ1->HZ1_FILIAL 	WITH xFilial("HZ1")
        REPLACE HZ1->HZ1_SEQ 		WITH cSeqPvt
        REPLACE HZ1->HZ1_IDENT		WITH cIdtPvt
        REPLACE HZ1->HZ1_OP		    WITH cOp
        REPLACE HZ1->HZ1_COMP	    WITH cComp 
        REPLACE HZ1->HZ1_TRT	    WITH cTrt
        REPLACE HZ1->HZ1_LOCAL	    WITH cLocal
        REPLACE HZ1->HZ1_QTD	    WITH nQtd
        REPLACE HZ1->HZ1_LOTE	    WITH cLote
        REPLACE HZ1->HZ1_SUBLOT	    WITH cSubLote
        REPLACE HZ1->HZ1_DTVALD	    WITH dDataValid
        REPLACE HZ1->HZ1_OPORIG	    WITH cOpOrig
        REPLACE HZ1->HZ1_ESTORN	    WITH "N"
        REPLACE HZ1->HZ1_PROCES	    WITH "N"        
        REPLACE HZ1->HZ1_ANALIS	    WITH "N"    
        REPLACE HZ1->HZ1_QTDPRC	    WITH 0   
    HZ1->(MSUNLOCK())

Return Nil

/*/{Protheus.doc} a160ProcRP()
Processa Requisições Pendentes - Geral
Função principal que inicia o processamento do JOB e Monitor

@author michele.girardi
@since 23/01/2026
@param 01: nRecnoZ0   - Recno da HZ0 a ser processado. Quando executada uma RP específica - Pelo Monitor.
@param 02: nRecnoZ1   - Recno da HZ1 a ser processado. Quando executada uma RP específica - Pelo Monitor.
@param 03: cMsg       - Mensagem do processamento da RP específica - Pelo Monitor.
@param 04: nQtdThread - Quantidade de threads que será utilizada no processamento.
@return: Nil
/*/
Function a160ProcRP(nRecnoZ0, nRecnoZ1, cMsg, nQtdThread)
    Local cAlias     := ""
    Local cAlias1    := ""
    Local cAlias2    := ""
    Local cAliasT    := ""
    Local cAnalise   := ""
    Local cFilZ0     := xFilial("HZ0")
    Local cFilZ1     := xFilial("HZ1")
    Local cMsgLog    := ""
	Local cQry       := ""
    Local cQry1      := ""
    Local cQry2      := ""
    Local cQry3      := ""
    Local cRecover   := ""
    Local lAbriu     := .T.
    Local lAudit     := .F.
    Local lErro      := .F.
    Local lMThread   := .F.
    Local nId        := ThreadID()
    Local nQtdTent   := 0
    Local nRecZ4     := 0
    Local nRecPrc    := 0
    Local nTotReq    := 0
	
    Local oExec      := Nil
    Local oExec1     := Nil
    Local oExec2     := Nil
    Local oExec3     := Nil

    Default nQtdThread := 0
    Default nRecnoZ0   := 0
    Default nRecnoZ1   := 0
    Default cMsg       := ""

    Private aAponPrc := {}
    Private lReqAP   := .T.
    Private lDevAP   := .T.

    If nRecnoZ0 == 0 .And. nRecnoZ1 == 0
        lAudit := .T.
    EndIf

    If lAudit
        //Gravar tabela de auditoria
        cMsgLog := "INICIO PROCESSAMENTO..."
        a160GrvHZ3(cMsgLog)

        cAliasT := a160CrTemp()
        a160InTemp(cAliasT)
    EndIf

    If nQtdThread == 0 .Or. (nRecnoZ0 != 0 .And. nRecnoZ1 != 0)
        lMThread := .F.
    Else
        If nQtdThread > 0
            lMThread := .T.
        EndIf
    EndIf 

    If lMThread
        __cIDThr  := "P160_" + cValToChar(nId)
	    __cErrorUID := "P160_E" + cValToChar(nId)

        cRecover   := 'P160ErroRP("'+ __cIDThr +'", '+ cValToChar(nQtdThread) +')'

	    //Inicializa as Threads
	    PCPIPCStart(__cIDThr, nQtdThread, 0, cEmpAnt, cFilAnt, __cErrorUID, cRecover)

        // Tempo de espera para aguardar a abertura das threads.
        // Cada unidade representa um sleep de 100ms
        lAbriu := PCPIPCWIni(__cIDThr, 600)

        If !lAbriu
		    Help(Nil,Nil,"Help",Nil,STR0014,1,0) //"Não foi possivel abrir as threads de processamento."
            Return .F.
	    EndIf
    EndIf

    dbSelectArea("HZ4")
    IF !(HZ4->(dbSeek(xFilial("HZ4"))))
        Help(Nil,Nil,"Help",Nil,STR0001,1,0) //"Parâmetros Iniciais não cadastrado no PCPA161."
        Return .F.
    EndIf

    dbSelectArea("SF5")
	dbSetorder(1)
	If dbSeek(xFilial("SF5")+HZ4->HZ4_TMREQ)
	    If SF5->F5_APROPR != "S"
            lReqAP := .F.
        EndIf
        If SF5->F5_ATUEMP != "S"
            Help(Nil,Nil,"Help",Nil,STR0010,1,0) //"Tipo de movimento de requisição deve Atualizar Empenho."
            Return .F.
        EndIf
    EndIf

    If dbSeek(xFilial("SF5")+HZ4->HZ4_TMDEV)
	    If SF5->F5_APROPR != "S"
            lDevAP := .F.
        EndIf
        If SF5->F5_ATUEMP != "S"
            Help(Nil,Nil,"Help",Nil,STR0011,1,0) //"Tipo de movimento de devolução deve Atualizar Empenho."
            Return .F.
        EndIf
    EndIf

    cAnalise := HZ4->HZ4_ANALIS
    nQtdTent := HZ4->HZ4_QTDTEN
    nRecZ4   := HZ4->(Recno())

    If lAudit
        //Verifica a quantidade de requisições pendentes para processamento
        cQry := " SELECT COUNT(*) COUNTRP"
        cQry +=   " FROM " + RetSqlName('HZ0') + " HZ0, " + RetSqlName('HZ1') + " HZ1 "
        cQry += "  WHERE HZ0.HZ0_FILIAL  = ? "
        cQry += "    AND HZ1.HZ1_FILIAL  = ? "
        cQry += "    AND HZ0.HZ0_ESTORN  = 'N' "
        cQry += "    AND HZ0.HZ0_ANALIS  = 'N' "
        cQry += "    AND HZ0.HZ0_REQTOT  = 'N' "
        cQry += "    AND HZ0.HZ0_OP      = HZ1.HZ1_OP "
        cQry += "    AND HZ0.HZ0_IDENT   = HZ1.HZ1_IDENT "
        cQry += "    AND HZ0.HZ0_SEQ     = HZ1.HZ1_SEQ "
        cQry += "    AND HZ1.HZ1_ESTORN  = 'N' "
        cQry += "    AND HZ1.HZ1_PROCES  = 'N' "
        cQry += "    AND HZ1.HZ1_ANALIS  = 'N' "
        cQry += "    AND HZ0.D_E_L_E_T_  = ' ' "
        cQry += "    AND HZ1.D_E_L_E_T_  = ' ' "

        oExec := FwExecStatement():New(cQry)
        oExec:setString(1, xFilial("HZ0"))
        oExec:setString(2, xFilial("HZ1"))

        cAlias := oExec:OpenAlias()

        If (cAlias)->(!Eof())
            nTotReq := (cAlias)->COUNTRP
        EndIf

        (cAlias)->(DbCloseArea())        
        oExec:Destroy()
        FreeObj(oExec)
    EndIf

    nRecPrc := 0

    //Varrer a tabela de controle para procurar todos apontamentos que possuem requisição em aberto
    cQry1 := " SELECT HZ0.HZ0_SEQ, "
    cQry1 += "        HZ0.HZ0_IDENT, "
    cQry1 += "        HZ0.HZ0_OP, "
    cQry1 += "        HZ0.HZ0_ENCOP, "
    cQry1 += "        HZ0.R_E_C_N_O_  RECNO "    
    cQry1 += "   FROM " + RetSqlName('HZ0') + " HZ0 "
    cQry1 += "  WHERE HZ0.HZ0_FILIAL   = ? "
    cQry1 += "    AND HZ0.HZ0_REQTOT   = 'N' "
    cQry1 += "    AND HZ0.HZ0_ESTORN   = 'N' "
    cQry1 += "    AND HZ0.HZ0_ANALIS   = 'N' "
    cQry1 += "    AND HZ0.D_E_L_E_T_   = ' ' "

    If nRecnoZ0 != 0
        cQry1 += "  AND HZ0.R_E_C_N_O_ = ? "
    EndIf

    cQry1 += "  ORDER BY HZ0.HZ0_DTINCL, HZ0.HZ0_HRINCL "

    oExec1 := FwExecStatement():New(cQry1)
        
    If nRecnoZ0 != 0
        oExec1:setString(1, cFilZ0)
        oExec1:SetNumeric(2, nRecnoZ0)
    Else
        oExec1:setString(1, cFilZ0)
    EndIf

    cAlias1 := oExec1:OpenAlias()

    While (cAlias1)->(!Eof())
            
        dbSelectArea("HZ0")
        dbGoTo((cAlias1)->RECNO)

        //Buscar os componentes pendentes dos apontaentos
        cQry2 := " SELECT HZ1.R_E_C_N_O_  RECNO "    
        cQry2 += "   FROM " + RetSqlName('HZ1') + " HZ1 "
        cQry2 += "  WHERE HZ1.HZ1_FILIAL   = ? "
        cQry2 += "    AND HZ1.HZ1_SEQ      = ? "
        cQry2 += "    AND HZ1.HZ1_IDENT    = ? "
        cQry2 += "    AND HZ1.HZ1_OP       = ? "
        cQry2 += "    AND HZ1.HZ1_PROCES   = 'N' "
        cQry2 += "    AND HZ1.HZ1_ESTORN   = 'N' "
        cQry2 += "    AND HZ1.HZ1_ANALIS   = 'N' "
        cQry2 += "    AND HZ1.D_E_L_E_T_   = ' ' "

        If nRecnoZ1 != 0
            cQry2 += "  AND HZ1.R_E_C_N_O_ = ? "
        EndIf

        oExec2 := FwExecStatement():New(cQry2)

        If nRecnoZ1 != 0
            oExec2:setString(1, cFilZ1)
            oExec2:setString(2, (cAlias1)->HZ0_SEQ)
            oExec2:setString(3, (cAlias1)->HZ0_IDENT)
            oExec2:setString(4, (cAlias1)->HZ0_OP)
            oExec2:SetNumeric(5, nRecnoZ1)
        Else
            oExec2:setString(1, cFilZ1)
            oExec2:setString(2, (cAlias1)->HZ0_SEQ)
            oExec2:setString(3, (cAlias1)->HZ0_IDENT)
            oExec2:setString(4, (cAlias1)->HZ0_OP)
        EndIf

        cAlias2 := oExec2:OpenAlias()

        While (cAlias2)->(!Eof())

            nRecPrc := nRecPrc + 1
            
            cMsg := ""
            If !lMThread
                a160ReqPrc((cAlias1)->RECNO, (cAlias2)->RECNO, nRecZ4, lAudit, @cMsg,cAliasT)
            Else
                lErro := !PCPIPCGO(__cIDThr, .F., "a160ReqPrc", (cAlias1)->RECNO, (cAlias2)->RECNO, nRecZ4, lAudit,,cAliasT)
                If lErro
                    Help(Nil,Nil,"Help",Nil,STR0015,1,0) //"Ocorreu errorlog no processamento das requisições pendentes. Execute o processamento pelo menu do Protheus para obter o errorlog."
                    Exit
                EndIf
            EndIf

            (cAlias2)->(dbSkip())
        End
        (cAlias2)->(DbCloseArea())

        oExec2:Destroy()
        FreeObj(oExec2)

        If lErro
            Exit
        EndIf

        If lMThread
            PCPIPCWait(__cIDThr)
	    EndIf

        //Após processar todas requisições daquele apontamento, verificar se todas foram efetivadas 
        //e atualizar o campo HZ0_REQTOT para indicar que foram processadas todas requisições
        a160AtuTOT((cAlias1)->HZ0_SEQ, (cAlias1)->HZ0_IDENT, (cAlias1)->HZ0_OP, (cAlias1)->RECNO)        

        (cAlias1)->(dbSkip())
    End
    (cAlias1)->(DbCloseArea())
        
    oExec1:Destroy()
    FreeObj(oExec1)

    If lErro
        Return nil
    EndIf

    If lAudit
        dbSelectArea(cAliasT)
        (cAliasT)->(dbGoTop())

        RecLock(cAliasT,.F.)
            Replace RP_TOTAL With nTotReq
            Replace RP_PROC  With nRecPrc
        (cAliasT)->(MsUnLock())
    EndIf

    If lMThread
		PCPIPCFinish(__cIDThr, 10, nQtdThread)
	EndIf

    If lAudit        
        dbSelectArea(cAliasT)
        (cAliasT)->(dbGoTop())

        cMsg :=         cValToChar((cAliasT)->RP_DATINI) +; 
                " "   + cValToChar((cAliasT)->RP_HORINI) +; 
                " T:" + cValToChar((cAliasT)->RP_TOTAL) +; 
                " S:" + cValToChar((cAliasT)->RP_PROCSUC) +; 
                " E:" + cValToChar((cAliasT)->RP_PROCERR) +; 
                " L:" + cValToChar((cAliasT)->RP_ERRLOCK) +; 
                " S:" + cValToChar((cAliasT)->RP_ERRSLD) +; 
                " D:" + cValToChar((cAliasT)->RP_ERRDIV) +; 
                " Thr:" + cValToChar(nQtdThread) +;
                " Tab:" + cValToChar(cAliasT)
                        
        //Gravar tabela de auditoria
        a160GrvHZ3(cMsg)

        TCDelFile(cAliasT)
        fDelSMP(cAliasT)
    EndIf

    If nRecnoZ0 == 0 .And. nRecnoZ1 == 0
        //Varrer a tabela de controle para procurar todos apontamentos que possuem somente Encerramento 
        //Enviado XML somente de encerramento pelo MES
        cQry3 := " SELECT HZ0.HZ0_SEQ, "
        cQry3 += "        HZ0.HZ0_IDENT, "
        cQry3 += "        HZ0.HZ0_OP, "
        cQry3 += "        HZ0.HZ0_ENCOP, "    
        cQry3 += "        HZ0.R_E_C_N_O_  RECNO "    
        cQry3 += "   FROM " + RetSqlName('HZ0') + " HZ0 "
        cQry3 += "  WHERE HZ0.HZ0_FILIAL   = ? "
        cQry3 += "    AND HZ0.HZ0_REQTOT   = 'E' " //RECTOT = E - Indica que não existe requisição - Foi gerado somente o encerramento
        cQry3 += "    AND HZ0.HZ0_ENCOP    = 'S' " 
        cQry3 += "    AND HZ0.HZ0_PRCENC   = 'N' " //Ainda não foi encerrado
        cQry3 += "    AND HZ0.HZ0_ESTORN   = 'N' "
        //cQry3 += "    AND HZ0.HZ0_ANALIS   = 'N' " //Não está em análise -- encerramento não olha em analise
        cQry3 += "    AND HZ0.D_E_L_E_T_   = ' ' "
        cQry3 += "  ORDER BY HZ0.HZ0_DTINCL, HZ0.HZ0_HRINCL

        oExec3 := FwExecStatement():New(cQry3)
        oExec3:setString(1, cFilZ0)

        cAlias3 := oExec3:OpenAlias()

        While (cAlias3)->(!Eof())
                
            dbSelectArea("HZ0")
            dbGoTo((cAlias3)->RECNO)

            a160EncOP(HZ0->HZ0_OP, HZ0->HZ0_SEQ, HZ0->HZ0_IDENT, (cAlias3)->RECNO)
                
            (cAlias3)->(dbSkip())
        End
        (cAlias3)->(DbCloseArea())
        oExec3:Destroy()
        FreeObj(oExec3)
    EndIf

    If nRecnoZ0 == 0 .And. nRecnoZ1 == 0
        //Encerrar GERAL - Verifica se tem algum encerramento pendente onde todas requisições foram feitas
        a160EncGer()
    EndIf

    lMsErroAuto := .F.

    If lAudit
        //Gravar tabela de auditoria
        cMsgLog := "FIM PROCESSAMENTO..."
        a160GrvHZ3(cMsgLog)
    EndIf

Return Nil

/*/{Protheus.doc} a160ReqPrc()
Processa a Requisição Pendente - Individual

@author michele.girardi
@since 10/03/2026
@param 01: nRecZ0 - Recno da HZ0 a ser processado. 
@param 02: nRecZ1 - Recno da HZ1 a ser processado. 
@param 03: nRecZ4 - Mensagem do processamento da RP específica - Pelo Monitor.
@param 04: lAudit - Indica se vai gravar auditoria na HZ3 - resumo do processamento
@param 05: cMsg   - Retorno da mensagem do processamento
@return: nil
/*/
Function a160ReqPrc(nRecZ0, nRecZ1, nRecZ4, lAudit, cMsg, cAliasT)
    Local cAnalise  := ""
    Local cSeqLog   := ""
    Local lAtuAn    := .F.
    Local lLock     := .F.
    Local lLockD4   := .F.
	Local lRet      := .T.
    Local nQtdProc  := 0
    Local nQtdTent  := 0
    Local nRecB2    := 0
    Local nRecD4    := 0

    Local lPROCSUC  := .F.
    Local lPROCERR  := .F.
    Local lERRLOCK  := .F.
    Local lERRSLD   := .F.
    Local lERRDIV   := .F.

    Default cMsg := ""
    Default lAudit := .F.

    dbSelectArea("HZ0")
    dbGoTo(nRecZ0)

    dbSelectArea("HZ1")
    dbGoTo(nRecZ1)

    dbSelectArea("HZ4")
    dbGoTo(nRecZ4)

    cAnalise := HZ4->HZ4_ANALIS
    nQtdTent := HZ4->HZ4_QTDTEN
            
    Begin Transaction
        //Lock SB2
        lLock := .F.
        If AllTrim(HZ1->HZ1_OPORIG) != 'GGF'
            dbSelectArea("SB2")
            SB2->(dbSetOrder(1))
            If SB2->(MsSeek(xFilial("SB2")+HZ1->HZ1_COMP+HZ1->HZ1_LOCAL))
                If !SB2->(DBRLock()) 
                    cMsg := STR0002 + STR0003 + HZ1->HZ1_COMP //"Tabela SB2 - Saldos Físico e Financeiro, em lock em outro processamento." //"Componente: "
                    lLock := .T.
                    lRet  := .F.
                Else
                    If SoftLock("SB2")
                        nRecB2 := SB2->(Recno())
                    EndIf
                EndIf
            EndIf

            If !lLock
                lLockD4 := .F.
                nRecD4 := a160RecD4()

                If nRecD4 > 0
                    dbSelectArea("SD4")
                    dbGoTo(nRecD4)

                    If !SD4->(DBRLock()) 
                        cMsg := STR0016 + STR0003 + HZ1->HZ1_COMP //"Tabela SD4 - Requisições Empenhadas, em lock em outro processamento." //"Componente: "
                        lLockD4 := .T.
                        lRet  := .F.
                    Else
                        If SoftLock("SD4")
                            nRecD4 := SD4->(Recno())
                        EndIf
                    EndIf
                EndIf
            EndIf
        Else
            lLock   := .F.
            lLockD4 := .F.
        EndIf    
        
        If !lLock .And. !lLockD4
            nQtdProc := HZ1->HZ1_QTDPRC + 1

            //Processa Execauto do MATA241                    
            lRet := a160Prc241(@cMsg)
            If !lRet
                DisarmTransaction()
            EndIf

            If AllTrim(HZ1->HZ1_OPORIG) != 'GGF'
                dbSelectArea("SB2")
                SB2->(dbGoto(nRecB2))
                SB2->(MsUnLock())

                If nRecD4 > 0
                    dbSelectArea("SD4")
                    SD4->(dbGoto(nRecD4))
                    SD4->(MsUnLock())
                EndIf
            EndIf
        EndIf
    End Transaction

    If !lRet
        //Gravar tabela de erro
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")

        dbselectarea("HZ3")
        RecLock("HZ3",.T.)
            REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
            REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
            REPLACE HZ3->HZ3_SEQ 		WITH HZ1->HZ1_SEQ
            REPLACE HZ3->HZ3_IDENT		WITH HZ1->HZ1_IDENT
            REPLACE HZ3->HZ3_OP		    WITH HZ1->HZ1_OP
            REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
            REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
            REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
            REPLACE HZ3->HZ3_LOTE	    WITH HZ1->HZ1_LOTE
            REPLACE HZ3->HZ3_SUBLOT	    WITH HZ1->HZ1_SUBLOT
            REPLACE HZ3->HZ3_DTVALD	    WITH HZ1->HZ1_DTVALD
            REPLACE HZ3->HZ3_ENDERE	    WITH HZ1->HZ1_ENDERE
            REPLACE HZ3->HZ3_SERIE	    WITH HZ1->HZ1_SERIE 
            REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
            REPLACE HZ3->HZ3_MSG	    WITH cMsg
            REPLACE HZ3->HZ3_DTLOG	    WITH Date()
            REPLACE HZ3->HZ3_HRLOG	    WITH Time()
        HZ3->(MSUNLOCK())
        ConfirmSX8()

        If !lLock
            lAtuAn := .F.
            If cAnalise == "S"
                If nQtdProc >= nQtdTent 
                    nQtdProc := 0
                    lAtuAn := .T.
                EndIf
            EndIf

            dbselectarea("HZ1")
            RecLock("HZ1",.F.)
                REPLACE HZ1->HZ1_QTDPRC WITH nQtdProc

                If lAtuAn
                    REPLACE HZ1->HZ1_ANALIS WITH "S"
                EndIf
            HZ1->(MSUNLOCK())
        EndIf
    Else
        dbselectarea("HZ1")
        RecLock("HZ1",.F.)
            REPLACE HZ1->HZ1_QTDPRC WITH nQtdProc
        HZ1->(MSUNLOCK())
    EndIf

    If lAudit
        If Select(cAliasT) <= 0
            dbUseArea( .T.,"TOPCONN", cAliasT, cAliasT, .T., .F. )
        EndIf        

        dbSelectArea(cAliasT)
        (cAliasT)->(dbGoTop())

        If lRet
            lPROCSUC := .T.
        Else
            lPROCERR := .T.

            If lLock .Or. lLockD4
                lERRLOCK := .T.
            Else
                If (AT("MA240NEGAT", cMsg) > 0) .Or. (AT("[SALDO]", cMsg) > 0)
                    lERRSLD := .T.
                Else
                    lERRDIV := .T.
                EndIf
            EndIf
        EndIf

        RecLock(cAliasT,.F.)
            If lPROCSUC
                Replace RP_PROCSUC With RP_PROCSUC + 1
            EndIf

            If lPROCERR
                Replace RP_PROCERR With RP_PROCERR + 1
            EndIf

            If lERRLOCK
                Replace RP_ERRLOCK With RP_ERRLOCK + 1
            EndIf

            If lERRSLD
                Replace RP_ERRSLD  With RP_ERRSLD + 1
            EndIf

            If lERRDIV
                Replace RP_ERRDIV  With RP_ERRDIV + 1
            EndIf
        (cAliasT)->(MsUnLock())
    EndIf

Return

/*/{Protheus.doc} a160Prc241()
Processa a Requisição Pendente pelo MATA241

@author michele.girardi
@since 23/01/2026
@param: cMsg - Retorna a mensagem de erro caso ocorra algum problema na requisição
@return: lRet - T ou F
/*/
Function a160Prc241(cMsg)
    Local aCab       := {}
    Local aItens     := {}
    Local aLotes     := {}
    Local aRet       := {}
    Local cA160ENDE  := ""
    Local cCC        := ""
    Local cCod       := ""    
    Local cConta     := ""
    Local cEndereco  := ""
    Local cFilZ2     := xFilial("HZ2")
    Local cIdent     := ""
    Local cItemCTA   := ""
    Local cLocal     := ""
    Local cLote      := ""
    Local cCLVL      := ""
    Local cObserva   := ""
    Local cOP        := ""  
    Local cSeqLog    := ""
    Local cSerie     := ""  
    Local cSubLote   := ""
    Local cTM        := ""
    Local cTrt       := ""
    Local dDtApont   := HZ0->HZ0_DTAPON    
    Local dDtValid  
    Local lBscLt     := .F.
    Local lDevol     := .F.
    Local lMvtUnico  := .T.
    Local lNotSldSD4 := .F.
    Local lSldD4Parc := .F.
    Local lRastro    := Rastro(HZ1->HZ1_COMP)
    Local lRet       := .T.
    Local lLocaliz   := Localiza(HZ1->HZ1_COMP)
    Local lSetFilds  := .F.
    Local nLen       := 1
    Local nI         := 0
    Local nQuant     := 0
    Local nQuantClc  := 0
    Local nQtdSD4    := 0
    Local nMultiplic := 0
    Local nSaldo     := 0

    Static lA160ENDE  := Nil    
    Static lA160TMGGF := Nil

    Private lMsErroAuto    := .F.  //Indica se houve erro na execução
    Private lAutoErrNoFile := .T.  //Define se o erro será salvo em um arquivo log físico

    If AllTrim(HZ1->HZ1_OPORIG) == 'GGF'
        
        lA160TMGGF := Iif (lA160TMGGF==Nil,ExistBlock('A160TMGGF'),lA160TMGGF)

        If lA160TMGGF
            cTM := ExecBlock('A160TMGGF',.F.,.F.)
        Else
            cTM := HZ4->HZ4_TMREQ
        EndIf
        
        aCab    := {}
        aItens  := {}

        //Busca SD3 do MOD que foi requisitado no apontamento
        nRecD3  := a160RecD3()

        If nRecD3 == 0
            cMsg := STR0024 //"GGF - Não foi localizado o movimento da SD3 referente ao MOD."
            Return .F.
        EndIf

        dbSelectArea("SD3")
    	dbGoTo(nRecD3)

        cDoc      := SD3->D3_DOC
        cCC       := SD3->D3_CC
        
        cOP       := HZ1->HZ1_OP
        cCod      := HZ1->HZ1_COMP
        cLocal    := HZ1->HZ1_LOCAL    
        nQuant    := HZ1->HZ1_QTD     
        cIdent    := HZ1->HZ1_IDENT
        cObserva  := "TOTVSMES"
        
        dbSelectArea("SB1")
	    SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1") + PAD(cCod,TAMSX3("B1_COD")[1])))

        cConta   := SB1->B1_CONTA
        cItemCTA := SB1->B1_ITEMCC
        cCLVL    := SB1->B1_CLVL

        aCab := {{"D3_TM"     , cTM,      Nil},;
                 {"D3_DOC"    , cDoc,     Nil},;
                 {"D3_CC"      ,cCC,      NIL},;
			     {"D3_EMISSAO", dDtApont, Nil}}
        
        aAdd(aItens, {{"D3_COD"       , cCod,       Nil},;
		              {"D3_QUANT"     , nQuant,     Nil},;
                      {"D3_LOCAL"     , cLocal,     Nil},;
                      {"D3_TRT"       , cTrt,       Nil},;
                      {"D3_OP"        , cOP,        Nil},;
                      {"D3_IDENT"     , cIdent,     Nil},;
                      {"D3_OBSERVA"   , cObserva,   Nil},;
                      {"D3_CC"        , cCC,        NIL},;
                      {"D3_CONTA"     , cConta,     NIL},;
					  {"D3_ITEMCTA"   , cItemCTA,   NIL},;
					  {"D3_CLVL"      , cCLVL,      NIL}})

        lMsErroAuto := .F.
        lAutoErrNoFile := .T.
        //Chamar o execauto do MATA241
        MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)
        If lMsErroAuto            
            aRet := GetAutoGRLog()
            cMsg := FormErro(aRet)         
            lRet := .F.
        Else
            RecLock("HZ1", .F.)
	            REPLACE HZ1->HZ1_NUMSEQ WITH SD3->D3_NUMSEQ
                REPLACE HZ1->HZ1_LOTE   WITH SD3->D3_LOTECTL
                REPLACE HZ1->HZ1_SUBLOT WITH SD3->D3_NUMLOTE
                REPLACE HZ1->HZ1_DTVALD WITH SD3->D3_DTVALID
                REPLACE HZ1->HZ1_ENDERE WITH SD3->D3_LOCALIZ
                REPLACE HZ1->HZ1_SERIE  WITH SD3->D3_NUMSERI
                REPLACE HZ1->HZ1_PROCES WITH "S"
                REPLACE HZ1->HZ1_DTCONL WITH Date()
                REPLACE HZ1->HZ1_HRCONL WITH Time()
		    HZ1->(MsUnlock())

            lRet := .T.           
        EndIf
    
        Return lRet
    EndIf 

    dbSelectArea("HZ2")
    aCab    := {}
    aItens  := {}

    lA160ENDE  := Iif (lA160ENDE==Nil,ExistBlock('A160ENDE'),lA160ENDE)
    lDevol     := Iif (HZ1->HZ1_QTD < 0, .T.,.F.)
    nMultiplic := Iif (HZ1->HZ1_QTD < 0, -1,1)
    
    If lDevol
        cTM  := HZ4->HZ4_TMDEV
    Else
        cTM  := HZ4->HZ4_TMREQ
    EndIf

    aCab := {{"D3_TM"     , cTM,      Nil},;
			 {"D3_EMISSAO", dDtApont, Nil}}

    cCod      := HZ1->HZ1_COMP
    cLocal    := HZ1->HZ1_LOCAL    
    cTrt      := HZ1->HZ1_TRT
    cOP       := HZ1->HZ1_OP        
    nQuant    := (HZ1->HZ1_QTD * nMultiplic)
    cObserva  := "TOTVSMES"     
    cIdent    := HZ1->HZ1_IDENT

    cSubLote  := ""
    cLote     := ""
    cEndereco := ""
    cSerie    := ""
    
    lSetFilds := .F.

    If nQuant == 0
        //Quantidade a requisitar está zerada
        cMsg := STR0017 //"Quantidade a requisitar igual a zero. A requisição pendente foi processada, mas não foi requisitada."
        lMsErroAuto := .F.
        lAutoErrNoFile := .T.

        RecLock("HZ1", .F.)	    
            REPLACE HZ1->HZ1_PROCES WITH "S"
            REPLACE HZ1->HZ1_DTCONL WITH Date()
            REPLACE HZ1->HZ1_HRCONL WITH Time()
		HZ1->(MsUnlock())

        //Gravar tabela de erro
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")

        dbselectarea("HZ3")
        RecLock("HZ3",.T.)
            REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
            REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
            REPLACE HZ3->HZ3_SEQ 		WITH HZ1->HZ1_SEQ
            REPLACE HZ3->HZ3_IDENT		WITH HZ1->HZ1_IDENT
            REPLACE HZ3->HZ3_OP		    WITH HZ1->HZ1_OP
            REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
            REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
            REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
            REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
            REPLACE HZ3->HZ3_MSG	    WITH cMsg
            REPLACE HZ3->HZ3_DTLOG	    WITH Date()
            REPLACE HZ3->HZ3_HRLOG	    WITH Time()
        HZ3->(MSUNLOCK())
        ConfirmSX8()

        Return .T.
    EndIf

    //Verifica saldo disponível na SD4
    lNotSldSD4 := .F.
    lSldD4Parc := .F.

    nQtdSD4 := a160SldSD4(cOp,cCod,cTrt,cLocal)
    nQtdSD4 := (nQtdSD4 * nMultiplic)
    //Se a qtd da SD4 é maior ou igual a qtd da requisição - seguir processo normal
    //Se não possuir mais quantidade disponível na SD4 - atualiza para processado e não chama o MATA241
    If nQtdSD4 == 0
        lNotSldSD4 := .T.
    Else
        //Quantidade da SD4 é menor que a qtd a ser requisitada - movimenta somente a qtd disponível na SD4
        If nQtdSD4 < nQuant
            nQuant := nQtdSD4
            lSldD4Parc := .T.
        EndIf
    EndIf    

    If lNotSldSD4 //Não existe a SD4
        cMsg := STR0012 //"Saldo do empenho já requisitado. A requisição pendente foi processada, mas não foi requisitada."
        lMsErroAuto := .F.
        lAutoErrNoFile := .T.

        RecLock("HZ1", .F.)	    
            REPLACE HZ1->HZ1_PROCES WITH "S"
            REPLACE HZ1->HZ1_DTCONL WITH Date()
            REPLACE HZ1->HZ1_HRCONL WITH Time()
		HZ1->(MsUnlock())

        //Gravar tabela de erro
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")

        dbselectarea("HZ3")
        RecLock("HZ3",.T.)
            REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
            REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
            REPLACE HZ3->HZ3_SEQ 		WITH HZ1->HZ1_SEQ
            REPLACE HZ3->HZ3_IDENT		WITH HZ1->HZ1_IDENT
            REPLACE HZ3->HZ3_OP		    WITH HZ1->HZ1_OP
            REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
            REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
            REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
            REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
            REPLACE HZ3->HZ3_MSG	    WITH cMsg
            REPLACE HZ3->HZ3_DTLOG	    WITH Date()
            REPLACE HZ3->HZ3_HRLOG	    WITH Time()
        HZ3->(MSUNLOCK())
        ConfirmSX8()

        Return .T.
    EndIF

    SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cCod))
        If SB1->B1_APROPRI == 'I'
            If lDevol
                If !lDevAP
                    cMsg := STR0004 + cCod + STR0005 + cTM + STR0006 //"Componente " //" com apropriação indireta. Para devolver esse produto a TM " //" deve estar parametrizada como F5_APROPR = S."
                    Return .F.
                EndIf
            Else
                If !lReqAP                    
                    cMsg := STR0004 + cCod + STR0007 + cTM + STR0006 //"Componente " //" com apropriação indireta. Para requisitar esse produto a TM " //" deve estar parametrizada como F5_APROPR = S."
                    Return .F.                    
                EndIf
            EndIf
        EndIf
    EndIf

    //Não possui nem rastro e em localização
    //Não precisa buscar nenhuma informação adicional
    If ((!lRastro .And. !lLocaliz) .Or. lDevol)
        lMvtUnico := .T.
        lSetFilds := .T.
        lBscLt    := .F.
    EndIf 

    If !lSetFilds
        //Possui rastro ou localização
        //Não foi empenhado o lote nem o endereço
        //Busca o saldo do lote/endereço disponível
        If lRastro .Or. lLocaliz
            
            If lLocaliz
                cA160ENDE := Nil
                If lA160ENDE
                    cA160ENDE := ExecBlock('A160ENDE', .F., .F.)
                    If !(ValType(cA160ENDE)=='C')
                        cA160ENDE := Nil
                    EndIf	
                    cA160ENDE := Padr(cA160ENDE,TamSX3("BF_LOCALIZ")[1])								
                    //Verifica se o endereço retornado no PE é válido
                    If !Empty(cA160ENDE)
                        SBE->(dbSetOrder(1))
                        If !SBE->( MsSeek(xFilial("SBE")+cLocal+cA160ENDE) )
                            cA160ENDE := Nil
                        EndIf
                    EndIf
                EndIf
            EndIf

            aLotes := SldPorLote(cCod,cLocal,nQuant,,,,cA160ENDE,,,,,,,,dDtApont,,,,,,)
            nLen   := len(aLotes)
            lBscLt := .T.

            If nLen == 1
                lMvtUnico := .T.
            Else
                lMvtUnico := .F.
            EndIf
        EndIf
    EndIf

    If lBscLt 
        If nLen == 0
            //Apresentar mensagem sem saldo
            cMsg := "[SALDO]" + STR0009 + " " + STR0003 + cCod //"Não existe quantidade suficiente em estoque para atender esta requisição." //"Componente: "
            Return .F.
        EndIf

        //Verifica se existe saldo
        For nI := 1 to nLen
            nSaldo := nSaldo + aLotes[nI,5]
        Next nI

        If nQuant > nSaldo
            //Apresentar mensagem sem saldo
            cMsg := "[SALDO]" + STR0009 + " " + STR0003 + cCod //"Não existe quantidade suficiente em estoque para atender esta requisição." //"Componente: "
            Return .F.
        EndIf
    EndIf

    If lDevol .And. lRastro
        // Descobre o sub-lote
        cSubLote := NextLote(cCod,"S")
        // Descobre o lote
        cLote := NextLote(cCod,"L",cSubLote)
        cLote := If(Empty(cLote),"AUTO"+cSubLote,cLote)
    EndIf

    nQuantClc := nQuant
    
    For nI := 1 to nLen
        If nQuant <= 0
            Exit
        EndIf
        
        aItens := {}
        If lRastro .Or. lLocaliz
            If lBscLt
                cSubLote  := aLotes[nI,2]
                cLote     := aLotes[nI,1]
                cEndereco := aLotes[nI,3]
                cSerie    := aLotes[nI,4]
                dDtValid  := aLotes[nI,7]

                If nQuant > aLotes[nI,5]
                    nQuantClc := aLotes[nI,5]
                    nQuant    := nQuant - nQuantClc
                Else
                    nQuantClc := nQuant
                    nQuant    := 0 
                EndIf
            EndIf
        EndIf

        aAdd(aItens, {{"D3_COD"       , cCod,       Nil},;
		              {"D3_QUANT"     , nQuantClc,  Nil},;
                      {"D3_LOCAL"     , cLocal,     Nil},;
                      {"D3_TRT"       , cTrt,       Nil},;
                      {"D3_OP"        , cOP,        Nil},;
                      {"D3_IDENT"     , cIdent,     Nil},;
                      {"D3_OBSERVA"   , cObserva,   Nil}})

        If lRastro
            aAdd(aItens[Len(aItens)],{"D3_LOTECTL" , cLote,    Nil})
            aAdd(aItens[Len(aItens)],{"D3_DTVALID" , dDtValid, Nil})

            If !Empty(cSubLote)
                aAdd(aItens[Len(aItens)],{"D3_NUMLOTE" , cSubLote, Nil})
            EndIf
        EndIf

        If lLocaliz                    
            aAdd(aItens[Len(aItens)],{"D3_LOCALIZ" , cEndereco, Nil})

            If !Empty(cSerie)
                aAdd(aItens[Len(aItens)],{"D3_NUMSERI" , cSerie, Nil})
            EndIf
        EndIf
        
        lMsErroAuto := .F.
        lAutoErrNoFile := .T.
        //Chamar o execauto do MATA241
        MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)
        If lMsErroAuto            
            aRet := GetAutoGRLog()
            cMsg := FormErro(aRet)         
            lRet := .F.
            Exit
        Else
            If lSldD4Parc
                cMsg := STR0013 //"Saldo disponível do empenho é menor que a quantidade a ser requisitada. A requisição pendente foi processada considerando a quantidade disponível do empenho."
                //Gravar tabela de erro
                cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")                

                dbselectarea("HZ3")
                RecLock("HZ3",.T.)
                    REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
                    REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
                    REPLACE HZ3->HZ3_SEQ 		WITH HZ1->HZ1_SEQ
                    REPLACE HZ3->HZ3_IDENT		WITH HZ1->HZ1_IDENT
                    REPLACE HZ3->HZ3_OP		    WITH HZ1->HZ1_OP
                    REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
                    REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
                    REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
                    REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
                    REPLACE HZ3->HZ3_MSG	    WITH cMsg
                    REPLACE HZ3->HZ3_DTLOG	    WITH Date()
                    REPLACE HZ3->HZ3_HRLOG	    WITH Time()
                HZ3->(MSUNLOCK())
                ConfirmSX8()
            EndIf

            If lMvtUnico
                RecLock("HZ1", .F.)
	                REPLACE HZ1->HZ1_NUMSEQ WITH SD3->D3_NUMSEQ
                    REPLACE HZ1->HZ1_LOTE   WITH SD3->D3_LOTECTL
                    REPLACE HZ1->HZ1_SUBLOT WITH SD3->D3_NUMLOTE
                    REPLACE HZ1->HZ1_DTVALD WITH SD3->D3_DTVALID
                    REPLACE HZ1->HZ1_ENDERE WITH SD3->D3_LOCALIZ
                    REPLACE HZ1->HZ1_SERIE  WITH SD3->D3_NUMSERI
                    REPLACE HZ1->HZ1_PROCES WITH "S"
                    REPLACE HZ1->HZ1_DTCONL WITH Date()
                    REPLACE HZ1->HZ1_HRCONL WITH Time()
		        HZ1->(MsUnlock())
            Else
                //Gravar tabela dos componentes movimentados - a tabela HZ1 pode ter lote/endereço em branco 
                //e ter movimentado mais de um lote/endereço para atender aquela requisição
                RecLock("HZ2", .T.)
                    REPLACE HZ2->HZ2_FILIAL WITH cFilZ2
                    REPLACE HZ2->HZ2_SEQ    WITH HZ1->HZ1_SEQ
                    REPLACE HZ2->HZ2_IDENT  WITH cIdent
                    REPLACE HZ2->HZ2_OP     WITH cOP
                    REPLACE HZ2->HZ2_COMP   WITH cCod
                    REPLACE HZ2->HZ2_LOCAL  WITH cLocal
                    REPLACE HZ2->HZ2_TRT    WITH HZ1->HZ1_TRT
                    REPLACE HZ2->HZ2_LOTE   WITH SD3->D3_LOTECTL
                    REPLACE HZ2->HZ2_SUBLOT WITH SD3->D3_NUMLOTE
                    REPLACE HZ2->HZ2_DTVALD WITH SD3->D3_DTVALID
                    REPLACE HZ2->HZ2_ENDERE WITH SD3->D3_LOCALIZ
                    REPLACE HZ2->HZ2_SERIE  WITH SD3->D3_NUMSERI
                    REPLACE HZ2->HZ2_OPORIG WITH HZ1->HZ1_OPORIG
                    REPLACE HZ2->HZ2_QTD    WITH nQuantClc
                    REPLACE HZ2->HZ2_NUMSEQ WITH SD3->D3_NUMSEQ
                HZ2->(MsUnlock())
            EndIf           
        EndIf
    Next nI

    If lRet
        If !lMvtUnico
            RecLock("HZ1", .F.)
                REPLACE HZ1->HZ1_PROCES WITH "S"
                REPLACE HZ1->HZ1_DTCONL WITH Date()
                REPLACE HZ1->HZ1_HRCONL WITH Time()
		    HZ1->(MsUnlock())
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} a160RecD4()
Retorna o recno da SD4 para verificar se está em lock

@author michele.girardi
@since 12/03/2026
@return: nRecD4 - Recno da SD4
/*/
Function a160RecD4()    
    Local cAlias  := ""
    Local cQry    := ""
    Local nRecD4  := 0
    Local oExec   := Nil

    cQry := " SELECT SD4.R_E_C_N_O_  RECNO"
	cQry +=   " FROM " + RetSqlName('SD4') + " SD4 "
	cQry += "  WHERE SD4.D4_FILIAL  = ? "
    cQry += "    AND SD4.D4_OP      = ? "
    cQry += "    AND SD4.D4_COD     = ? "        
    cQry += "    AND SD4.D4_LOCAL   = ? "        
    cQry += "    AND SD4.D4_TRT     = ? "        
    cQry += "    AND SD4.D4_OPORIG  = ? "        
	cQry += "    AND SD4.D_E_L_E_T_ = ' ' "

	oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("SD4"))
    oExec:setString(2, HZ1->HZ1_OP)
    oExec:setString(3, HZ1->HZ1_COMP)
    oExec:setString(4, HZ1->HZ1_LOCAL)
    oExec:setString(5, HZ1->HZ1_TRT)
    oExec:setString(6, HZ1->HZ1_OPORIG)

	cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        nRecD4 := (cAlias)->RECNO
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return nRecD4

/*/{Protheus.doc} a160RecD3()
Retorna o recno da SD3 referente ao MOD para movimentar o GGF

@author michele.girardi
@since 24/04/2026
@return: nRecD3 - Recno da SD3
/*/
Function a160RecD3()    
    Local cAlias  := ""
    Local cQry    := ""
    Local nRecD3  := 0
    Local oExec   := Nil

    cQry := " SELECT SD3.R_E_C_N_O_  RECNO"
	cQry +=   " FROM " + RetSqlName('SD3') + " SD3 "
	cQry += "  WHERE SD3.D3_FILIAL  = ? "
    cQry += "    AND SD3.D3_OP      = ? "
    cQry += "    AND SD3.D3_IDENT   = ? "
    cQry += "    AND SD3.D3_NUMSEQ  = ? " 
    cQry += "    AND SD3.D3_ESTORNO = ' ' "       
	cQry += "    AND SD3.D_E_L_E_T_ = ' ' "

	oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("SD3"))
    oExec:setString(2, HZ1->HZ1_OP)
    oExec:setString(3, HZ1->HZ1_IDENT)
    oExec:setString(4, HZ1->HZ1_NUMSEQ)

	cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        nRecD3 := (cAlias)->RECNO
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return nRecD3

/*/{Protheus.doc} a160SldSD4()
Retorna o saldo disponível da SD4 que está sendo processada

@author michele.girardi
@since 23/01/2026
@param 01: cOp    - Ordem de Produção
@param 02: cComp  - Componente
@param 03: cTrt   - Sequencia da estrutura
@param 04: cLocal - Local
@return: nQtd - Saldo disponível da SD4
/*/
Static Function a160SldSD4(cOp,cComp,cTrt,cLocal)
    Local cAlias   := ""
    Local cAlias1  := ""
    Local cMsg     := ""
    Local cQry     := ""
    Local cQry1    := ""
    Local cVar     := 'OP: ' + cValToChar(cOp) + ' COMP: ' + cValToChar(cComp) + ' LOCAL: ' + cValToChar(cLocal) + ' TRT: ' + cValToChar(cTrt) 
    Local lAchou   := .F.
    Local nQtd     := 0

    Local oExec    := Nil
    Local oExec1   := Nil

    cOP    := PadR(cOp,    FWTamSX3('D4_OP')[1])
    cComp  := PadR(cComp,  FWTamSX3('D4_COD')[1])
    cLocal := PadR(cLocal, FWTamSX3('D4_LOCAL')[1])
    cTrt   := PadR(cTrt,   FWTamSX3('D4_TRT')[1])
    
    lAchou := .F.
    nQtd   := 0
    dbSelectArea('SD4')
    SD4->(dbGoTop())
	SD4->(dbSetOrder(2)) //D4_FILIAL+D4_OP+D4_COD+D4_LOCAL                                                                                                                                 
	If SD4->(dbSeek(xFilial('SD4')+cOP+cComp+cLocal))
	    While SD4->(!EOF()) .And. SD4->D4_FILIAL == xFilial('SD4') .And. SD4->D4_OP == cOP .And. SD4->D4_LOCAL == cLocal .And. SD4->D4_COD == cComp
            If SD4->(!EOF()) .And. SD4->D4_FILIAL == xFilial('SD4') .And. SD4->D4_OP == cOP .And. SD4->D4_LOCAL == cLocal .And. SD4->D4_COD == cComp .And. SD4->D4_TRT == cTrt
                lAchou := .T.
                nQtd += SD4->D4_QUANT
            EndIf
            
            SD4->(dbSkip())
        End
    EndIf

    If !lAchou
        cMsg := STR0025 //"[Auditoria Interna] Não achou a SD4 -0"
        a160grvLog(cMsg)
        a160grvLog(cVar)
    EndIf
    
Return nQtd
    
/*/{Protheus.doc} a160grvLog()
Grava mensagem de LOG - auditoria

@author michele.girardi
@since 23/01/2026
@param: cMsg   - Mensagem
@return: nil
/*/
Function a160grvLog(cMsg)

    Local cSeqLog  := ""

    //Gravar tabela de erro
    cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")

    dbselectarea("HZ3")
    RecLock("HZ3",.T.)
        REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
        REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
        REPLACE HZ3->HZ3_SEQ 		WITH HZ1->HZ1_SEQ
        REPLACE HZ3->HZ3_IDENT		WITH HZ1->HZ1_IDENT
        REPLACE HZ3->HZ3_OP		    WITH HZ1->HZ1_OP
        REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
        REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
        REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
        REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
        REPLACE HZ3->HZ3_MSG	    WITH cMsg
        REPLACE HZ3->HZ3_DTLOG	    WITH Date()
        REPLACE HZ3->HZ3_HRLOG	    WITH Time()
    HZ3->(MSUNLOCK())
    ConfirmSX8()

Return 

/*/{Protheus.doc} a160AtuTOT()
Atualiza campo HZ0_REQTOT caso todas requisições foram processadas com sucesso

@author michele.girardi
@since 23/01/2026
@param 01: cSeq     - Sequencia do apontamento - HZ0_SEQ
@param 02: cIdent   - ID do apontamento - HZ0_IDENT
@param 03: cOP      - Ordem de produção - HZ0_OP
@param 04: cRecnoZ0 - Recno da tabela HZ0
@return: Nil
/*/
Function a160AtuTOT(cSeq, cIdent, cOP, cRecnoZ0)
    Local cAlias   := ""
    Local cAlias3  := ""
    Local cMsg     := ""
    Local cQry     := ""
    Local cQry3    := ""
    Local cSeqLog  := ""

    Local oExec    := Nil
    Local oExec3   := Nil

    dbSelectArea("HZ0")
    dbGoTo(cRecnoZ0)

    //Após processar todas requisições daquele apontamento, verificar se todas foram efetivadas 
    //e atualizar o campo HZ0_REQTOT para indicar que foram processadas todas requisições
    cQry := " SELECT COUNT(*) COUNTZ1 "
	cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
	cQry += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry += "    AND HZ1.HZ1_SEQ      = ? "
    cQry += "    AND HZ1.HZ1_IDENT    = ? "
    cQry += "    AND HZ1.HZ1_OP       = ? "
    cQry += "    AND HZ1.HZ1_PROCES   = 'N' "        
	cQry += "    AND HZ1.D_E_L_E_T_   = ' ' "

	oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ1"))
    oExec:setString(2, HZ0->HZ0_SEQ)
    oExec:setString(3, HZ0->HZ0_IDENT)
    oExec:setString(4, HZ0->HZ0_OP)

	cAlias := oExec:OpenAlias()

	If (cAlias)->COUNTZ1 == 0
        RecLock("HZ0", .F.)
	        REPLACE HZ0->HZ0_REQTOT WITH "S"

            If HZ0->HZ0_ENCOP == "N"
                REPLACE HZ0->HZ0_DTCONL WITH Date()
                REPLACE HZ0->HZ0_HRCONL WITH Time()
            EndIf
	    HZ0->(MsUnlock())

        //Grava LOG para indicar quando a HZ0 foi alterada para REQTOT = S
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")
        cMsg    := STR0026 //"Apontamento processou todas requisições pendentes - REQTOT = S"

        dbselectarea("HZ3")
        RecLock("HZ3",.T.)
            REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
            REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
            REPLACE HZ3->HZ3_SEQ 		WITH HZ0->HZ0_SEQ
            REPLACE HZ3->HZ3_IDENT		WITH HZ0->HZ0_IDENT
            REPLACE HZ3->HZ3_OP		    WITH HZ0->HZ0_OP
            REPLACE HZ3->HZ3_MSG	    WITH cMsg
            REPLACE HZ3->HZ3_DTLOG	    WITH Date()
            REPLACE HZ3->HZ3_HRLOG	    WITH Time()
        HZ3->(MSUNLOCK())
        ConfirmSX8()

        //Verificar se o apontamento Encerra a OP
        If HZ0->HZ0_ENCOP == "S"
            a160EncOP(HZ0->HZ0_SEQ, HZ0->HZ0_IDENT, HZ0->HZ0_OP, cRecnoZ0)
        Else
            //Verifica se existe um registro pendente na HZ0 para encerrar a OP
            cQry3 := " SELECT HZ0.R_E_C_N_O_  RECNO "    
            cQry3 += "   FROM " + RetSqlName('HZ0') + " HZ0 "
            cQry3 += "  WHERE HZ0.HZ0_FILIAL   = ? "
            cQry3 += "    AND HZ0.HZ0_REQTOT   = 'E' " //RECTOT = E - Indica que não existe requisição - Foi gerado somente o encerramento
            cQry3 += "    AND HZ0.HZ0_ENCOP    = 'S' " 
            cQry3 += "    AND HZ0.HZ0_PRCENC   = 'N' " //Ainda não foi encerrado
            cQry3 += "    AND HZ0.HZ0_ESTORN   = 'N' "
            //cQry3 += "    AND HZ0.HZ0_ANALIS   = 'N' " //Não está em análise -- encerramento não olha em analise
            cQry3 += "    AND HZ0.HZ0_OP       = ? " 
            cQry3 += "    AND HZ0.D_E_L_E_T_   = ' ' "
            cQry3 += "  ORDER BY HZ0.HZ0_DTINCL, HZ0.HZ0_HRINCL

            oExec3 := FwExecStatement():New(cQry3)
            oExec3:setString(1, xFilial("HZ0"))
            oExec3:setString(2, HZ0->HZ0_OP)

            cAlias3 := oExec3:OpenAlias()

            While (cAlias3)->(!Eof())
                
                dbSelectArea("HZ0")
                dbGoTo((cAlias3)->RECNO)

                a160EncOP(HZ0->HZ0_OP, HZ0->HZ0_SEQ, HZ0->HZ0_IDENT, (cAlias3)->RECNO, .F.)
                
                (cAlias3)->(dbSkip())
            End
            (cAlias3)->(DbCloseArea())
            oExec3:Destroy()
            FreeObj(oExec3)
        EndIf
	EndIf

	(cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)
Return Nil

/*/{Protheus.doc} a160EncGer()
Verifica se existe algum encerramento pendente e encerra

@author michele.girardi
@since 26/01/2026
@return: Nil
/*/
Static Function a160EncGer()
    Local cAlias   := ""
    Local cQry     := ""

    Local oExec    := Nil

    //Verifica HZ0 se existe algum apontamento com todas requisições OK
    //Com o indicador para encerrar a OP e a OP ainda não encerrada

    cQry := " SELECT HZ0.HZ0_OP OPZ0,  HZ0.HZ0_SEQ SEQZ0, HZ0.HZ0_IDENT IDENTZ0, HZ0.R_E_C_N_O_ RECNOZ0 "
	cQry +=   " FROM " + RetSqlName('HZ0') + " HZ0 "
	cQry += "  WHERE HZ0.HZ0_FILIAL   = ? "
    cQry += "    AND HZ0.HZ0_REQTOT   = 'S' " 
    cQry += "    AND HZ0.HZ0_ENCOP    = 'S' " 
    cQry += "    AND HZ0.HZ0_PRCENC   = 'N' " 
    cQry += "    AND HZ0.HZ0_ESTORN   = 'N' " 
    cQry += "    AND HZ0.HZ0_ANALIS   = 'N' "

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ0"))

	cAlias := oExec:OpenAlias()

    While (cAlias)->(!Eof())

        //Criar um array para armazenar os apontamentos que já passaram pela função de encerramento mas ocorreu erro.
        //lAchou := aScan(aAponPrc, {|x| x[1] == (cAlias)->OPZ0})

        //If lAchou == 0                
            a160EncOP((cAlias)->OPZ0, (cAlias)->SEQZ0, (cAlias)->IDENTZ0, (cAlias)->RECNOZ0)
        //EndIf
        (cAlias)->(dbSkip())
    End

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return Nil

/*/{Protheus.doc} a160EncOP()
Encerra a OP

@author michele.girardi
@since 26/01/2026
@param 01: cOP      - Ordem de produção - HZ0_OP
@param 02: cSeq     - Sequencia do apontamento - HZ0_SEQ
@param 03: cIdent   - ID do apontamento - HZ0_IDENT
@param 04: cRecnoZ0 - Recno da tabela HZ0
@param 05: lVldPend - Indica se deve incluir o array da validação da pendência.
                      Como foi alterada a regra, sempre que concluir um apontamento será verificado
                      se existe registro de encerramento da OP. Mas pode existir outros apontamentos
                      em aberto e a OP não será encerrada. 
                      No final do processamento de todas requisições, deve ser validado novamente
                      se a OP pode ser excluida. Se existir registro nesse array essa OP é ignorada nesse
                      processamento final.
@return: Nil
/*/
Function a160EncOP(cOP, cSeq, cIdent, cRecnoZ0, lVldPend)
    Local aErroAuto := {}
    Local aVetor    := {}
    Local cAlias    := ""
    Local cCf       := ""
    Local cCod      := ""
    Local cLocal    := ""
    Local cLogTxt   := ""
    Local cMsg      := ""
    Local cNumSeq   := ""
    Local cQry      := ""
    Local cSeqLog   := ""
    Local lErro     := .T.
    Local lExtPend  := .F.
    Local lExtOper  := .F.
    Local nAux      := 0
    Local nOpc      := 7 // Opção de execução da rotina - Encerra OP

    Local oExec     := Nil

    Default lVldPend := .T.

    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .T.  //Define se o erro será salvo em um arquivo log físico

    dbSelectArea("HZ0")
    dbGoTo(cRecnoZ0)

    cOP    := HZ0->HZ0_OP
    cIdent := HZ0->HZ0_IDENT

    //Verifica se existe alguma requisição pendente para a OP
    //Só deve encerrar a OP quando não existir nenhuma pendência
    lExtPend := a160ExtPen(cOP)

    //Se existir pendência não deve encerrar a OP
    If lExtPend
        //If lVldPend
        //    Aadd(aAponPrc, {cOP})
        //EndIf

        Return
    Else
        //Grava LOG para indicar que não existe requisição pendente para a OP
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")
        cMsg    := STR0027 //"Não existe requisição pendente para OP. OP será encerrada."

        dbselectarea("HZ3")
        RecLock("HZ3",.T.)
            REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
            REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
            REPLACE HZ3->HZ3_SEQ 		WITH HZ0->HZ0_SEQ
            REPLACE HZ3->HZ3_IDENT		WITH HZ0->HZ0_IDENT
            REPLACE HZ3->HZ3_OP		    WITH cOP
            REPLACE HZ3->HZ3_MSG	    WITH cMsg
            REPLACE HZ3->HZ3_DTLOG	    WITH Date()
            REPLACE HZ3->HZ3_HRLOG	    WITH Time()
        HZ3->(MSUNLOCK())
        ConfirmSX8()
    EndIf

    //Verifica se existe alguma operação sem apontamento finalizado
    lExtOper := a160ExtApo(cOP)
    If lExtOper
        Return
    EndIf

    dbSelectArea("SC2")
    SC2->(dbSetOrder(1))
    If SC2->(dbSeek(xFilial("SC2")+cOp))
        If !Empty(SC2->C2_DATRF) //OP ENCERRADA NÃO PROCESSAR NOVAMENTE
            //Atualiza campo HZ0_PRCENC - HZ0_DTCONL - HZ0_HRCONL
            dbSelectArea("HZ0")
            HZ0->(dbGoTo(cRecnoZ0))

            RecLock("HZ0", .F.)
                REPLACE HZ0->HZ0_PRCENC WITH "S"
                REPLACE HZ0->HZ0_DTCONL WITH Date()
                REPLACE HZ0->HZ0_HRCONL WITH Time()
            HZ0->(MsUnlock())            

            //Grava LOG para indicar que a OP já foi encerrada
            cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")
            cMsg    := STR0028 //"Ordem de Produção já encerrada - Atualizado HZ0_PRCENC = S"

            dbselectarea("HZ3")
            RecLock("HZ3",.T.)
                REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
                REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
                REPLACE HZ3->HZ3_SEQ 		WITH HZ0->HZ0_SEQ
                REPLACE HZ3->HZ3_IDENT		WITH HZ0->HZ0_IDENT
                REPLACE HZ3->HZ3_OP		    WITH HZ0->HZ0_OP
                REPLACE HZ3->HZ3_MSG	    WITH cMsg
                REPLACE HZ3->HZ3_DTLOG	    WITH Date()
                REPLACE HZ3->HZ3_HRLOG	    WITH Time()
            HZ3->(MSUNLOCK())
            ConfirmSX8()

            Return
        EndIf
    EndIf
    
    Begin Transaction
        //Busca NUMSEQ da SD3 do apontamento que deve encerrar a OP
        cQry := " SELECT SD3.R_E_C_N_O_ RECNO"
	    cQry +=   " FROM " + RetSqlName('SD3') + " SD3 "
	    cQry += "  WHERE SD3.D3_FILIAL  = ? "
        cQry += "    AND SD3.D3_OP      = ? "     
        cQry += "    AND SD3.D3_IDENT   = ? "      
        cQry += "    AND SD3.D3_ESTORNO = ' ' "      
        cQry += "    AND SD3.D3_CF      = 'PR0' "      
	    cQry += "    AND SD3.D_E_L_E_T_  = ' ' "

        oExec := FwExecStatement():New(cQry)
	    oExec:setString(1, xFilial("SD3"))
        oExec:setString(2, cOP)
        oExec:setString(3, cIdent)

	    cAlias := oExec:OpenAlias()

	    If (cAlias)->(!Eof())

            DbSelectArea("SD3")
		    SD3->(dbGoTo((cAlias)->RECNO))

            cCod    := SD3->D3_COD
            cLocal  := SD3->D3_LOCAL
            cNumSeq := SD3->D3_NUMSEQ
            cCf     := SD3->D3_CF
    
		    aVetor := {;
                		{"D3_FILIAL" ,xFilial("SD3")  ,NIL},;
          		    	{"D3_COD"    ,cCod            ,NIL},;
              			{"D3_LOCAL"  ,cLocal          ,NIL},;
              	    	{"D3_NUMSEQ" ,cNumSeq         ,NIL},;
              			{"D3_CF"     ,cCf             ,NIL},;
          	    		{"INDEX"     ,3               ,NIL}}

            lMsErroAuto    := .F.
            lAutoErrNoFile := .T.
            lErro          := .F.

            MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )

		    If lMsErroAuto
                //Pode ocorrer de ser apresentando um HELP durante o encerramento mas esse HELP não impede o processamento.
                //Porém, quando é chamada a função HELP, o execauto entende que é erro e grava a váriável lMsErroAuto como T
                //Será validada se a OP foi encerrada ou não para apresentar a msg de erro ou atualizar as tabelas das pendências
                dbSelectArea("SC2")
                SC2->(dbSetOrder(1))
                If SC2->(dbSeek(xFilial("SC2")+cOp))
                    If !Empty(SC2->C2_DATRF) //OP ENCERRADA
                        lErro := .F.
                    Else                        
                        lErro := .T.
                    EndIf
                EndIf                
            Else
                lErro := .F.
            EndIf

            If lErro 
		        aErroAuto := GetAutoGRLog()
			    cLogTxt := " "
			    For nAux := 1 To Len(aErroAuto)
				    cLogTxt += aErroAuto[nAux]
			    Next nAux

                //Grava HZ3 - log de erro
                cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")

                dbselectarea("HZ3")
                RecLock("HZ3",.T.)
                    REPLACE HZ3->HZ3_FILIAL  WITH xFilial("HZ3")
                    REPLACE HZ3->HZ3_SEQLOG  WITH cSeqLog
                    REPLACE HZ3->HZ3_SEQ 	 WITH cSeq
                    REPLACE HZ3->HZ3_IDENT	 WITH cIdent
                    REPLACE HZ3->HZ3_OP		 WITH cOP
                    REPLACE HZ3->HZ3_MSG	 WITH cLogTxt
                    REPLACE HZ3->HZ3_DTLOG	 WITH Date()
                    REPLACE HZ3->HZ3_HRLOG	 WITH Time()
                HZ3->(MSUNLOCK())

                ConfirmSX8()

                //Aadd(aAponPrc, {cOP})
            Else
                //Grava LOG para indicar que a OP já foi encerrada
                cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")
                cMsg    := STR0029 //"Ordem de Produção encerrada com sucesso pela requisição pendente"

                dbselectarea("HZ3")
                RecLock("HZ3",.T.)
                    REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
                    REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
                    REPLACE HZ3->HZ3_SEQ 		WITH HZ0->HZ0_SEQ
                    REPLACE HZ3->HZ3_IDENT		WITH HZ0->HZ0_IDENT
                    REPLACE HZ3->HZ3_OP		    WITH HZ0->HZ0_OP
                    REPLACE HZ3->HZ3_MSG	    WITH cMsg
                    REPLACE HZ3->HZ3_DTLOG	    WITH Date()
                    REPLACE HZ3->HZ3_HRLOG	    WITH Time()
                HZ3->(MSUNLOCK())
                ConfirmSX8()       

                //Atualiza campo HZ0_PRCENC - HZ0_DTCONL - HZ0_HRCONL
                dbSelectArea("HZ0")
                HZ0->(dbGoTo(cRecnoZ0))

                RecLock("HZ0", .F.)
                    REPLACE HZ0->HZ0_PRCENC WITH "S"
                    REPLACE HZ0->HZ0_DTCONL WITH Date()
                    REPLACE HZ0->HZ0_HRCONL WITH Time()
                HZ0->(MsUnlock())     
            EndIf
        EndIf
        (cAlias)->(DbCloseArea())        
        oExec:Destroy()
        FreeObj(oExec)
    End Transaction
Return

/*/{Protheus.doc} a160ExtPen()
Verifica se existe requisição pendente para a OP para qualquer apontamento

@author michele.girardi
@since 26/01/2026
@param: cOP - Ordem de Produção
@return: lRet - T ou F
/*/
Function a160ExtPen(cOP)
    Local cAlias   := ""
    Local cQry     := ""
    Local lRet     := .T.

    Local oExec    := Nil

    cQry := " SELECT COUNT(*) COUNTZ1 "
	cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
	cQry += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry += "    AND HZ1.HZ1_OP       = ? " 
    cQry += "    AND HZ1.HZ1_PROCES   = 'N' "     
    cQry += "    AND HZ1.HZ1_ESTORN   = 'N' "      
	cQry += "    AND HZ1.D_E_L_E_T_   = ' ' "

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ1"))
    oExec:setString(2, cOP)

	cAlias := oExec:OpenAlias()

	If (cAlias)->COUNTZ1 == 0
        lRet := .F.
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return lRet

/*/{Protheus.doc} a160ExtApo()
Verifica se existe alguma operação sem apontamento

@author michele.girardi
@since 15/04/2026
@param: cOP - Ordem de Produção
@return: lRet - T ou F
/*/
Function a160ExtApo(cOP)
    Local aAreaSH6 := SH6->(GetArea())
    Local cAlias   := ""
    Local cQry     := ""
    Local lApon    := .F.
    Local lRet     := .F.
    Local lUltOper := .F.

    Local oExec    := Nil

    //Busca os registros ainda não finalzados na SHY para a OP
    cQry := " SELECT SHY.HY_OP YOP,  SHY.HY_ROTEIRO YROT, SHY.HY_OPERAC YOPER, SHY.HY_QUANT YQUANT "
	cQry +=   " FROM " + RetSqlName('SHY') + " SHY "
	cQry += "  WHERE SHY.HY_FILIAL   = ? "
    cQry += "    AND SHY.HY_OP       = ? " 
    cQry += "    AND SHY.HY_SITUAC   <> '3' " 
	cQry += "    AND SHY.D_E_L_E_T_  = ' ' "
    cQry += "  ORDER BY SHY.HY_OPERAC "

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("SHY"))
    oExec:setString(2, cOP)

	cAlias := oExec:OpenAlias()

    While (cAlias)->(!Eof())
        
        lUltOper := a160UltOpe((cAlias)->YOP, (cAlias)->YROT, (cAlias)->YOPER)

        If !lUltOper
            //Se não for a última operação, obrigatoriamente a operação precisa estar finalizada
            lRet := .T.
            Exit
        EndIf

        If !lRet
            //Se for a última operação verificar se já foi apontada a operação
            lApon := a160Apon((cAlias)->YOP, (cAlias)->YOPER, (cAlias)->YQUANT)

            If !lApon 
                //Se for a última operação deve ter apontada a quantidade total para encerrar a OP
                lRet := .T.
                Exit
            EndIf
        EndIf

    	(cAlias)->(dbSkip())    
	End

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

    RestArea(aAreaSH6)
Return lRet 

/*/{Protheus.doc} a160UltOpe()
Verifica se é a última operação

@author michele.girardi
@since 15/04/2026
@param: cOP - Ordem de Produção
@return: lRet - T ou F
/*/
Function a160UltOpe(cOP, cRoteiro, cOperac)
    Local lRet  := .T.

    dbSelectArea("SHY")
	SHY->(dbSetOrder(1))
	If SHY->(dbSeek(xFilial("SHY")+cOp+cRoteiro+cOperac))
	    SHY->(dbSkip())
		If Alltrim(cOp) == Alltrim(SHY->HY_OP) .AND. cRoteiro == SHY->HY_ROTEIRO
		    lRet:=.F.
		EndIf
	EndIf

Return lRet 


/*/{Protheus.doc} a160Apon()
Verifica se a última operação foi apontada total para permitir encerrar

@author michele.girardi
@since 15/04/2026
@param: cOP - Ordem de Produção
@return: lRet - T ou F
/*/
Function a160Apon(cOP, cOperac, nQuant)
    Local lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)
    Local lRet     := .F.
    Local nPerdPrd := 0
    Local nQtApon  := 0

    dbSelectArea("SH6")
	SH6->(dbSetOrder(1))
	SH6->(dbGotop())
	SH6->(dbSeek(xFilial("SH6")+cOP))
	While !Eof() .And. SH6->H6_FILIAL + SH6->H6_OP == xFilial("SH6") + cOP
	    If SH6->H6_FILIAL + SH6->H6_OP == xFilial("SH6") + cOP .And. SH6->H6_OPERAC = cOperac 
		    If SH6->H6_QTDPROD > 0 .OR. SH6->H6_QTDPERD > 0
			    nPerdPrd := IIF(lPerdInf,0,SH6->H6_QTDPERD)
				nQtApon += SH6->H6_QTDPROD + nPerdPrd - H6_QTMAIOR - H6_QTGANHO
			EndIf
		EndIf
		SH6->(dbSkip())
	End

    If nQuant == nQtApon
        lRet := .T.
    EndIf

Return lRet

/*/{Protheus.doc} FormErro()
Formata mensagem de erro do execauto

@author michele.girardi
@since 26/01/2026
@param: aRet - Retorno do execauto com o erro
@return: cLogErro - Mensagem de erro formatada
/*/
Static Function FormErro(aRet)
	Local nCount    := 0
	Local cLogErro  := ""

	For nCount := 1 To Len(aRet)
		If AT(':=',aRet[nCount]) > 0 .And. AT('< --',aRet[nCount]) < 1
			Loop
		EndIf
		If AT("------", aRet[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		If !Empty(cLogErro)
			cLogErro += " "
		EndIf
		cLogErro += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aRet[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount

Return cLogErro

/*/{Protheus.doc} a160CrTemp()
Cria tabela para guardar as informações do processamento

@author michele.girardi
@since 12/03/2026
@return: nil
/*/
Function a160CrTemp()
    Local aFields := {}
    Local cAliasT := ""
    Local cCampo  := ""
    Local cMsgLog := ""
    Local cNCampo := ""

    Local cId      := ""
    Local nId      := ThreadID()
    Local cUser    := RetCodUsr()

    Dbselectarea("SMP")
    //DROPA todas tabelas criadas 2 dias atrás
    fDelTabAnt()

    cId      := "RP" + cValToChar(nId)
    cAliasT  := cId

    If Select(cAliasT) > 0
        (cAliasT)->(DbCloseArea())    
    EndIf

    cNCampo := 'RP_DATINI'
    cCampo  := 'HZ3_DTLOG'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'RP_HORINI'
    cCampo  := 'HZ3_HRLOG'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'RP_TOTAL'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_PROC'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_PROCSUC'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_PROCERR'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_ERRLOCK'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_ERRSLD'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'RP_ERRDIV'
    aAdd(aFields, {cNCampo,'N',12,0})

    //Gravar tabela de auditoria
    cMsgLog := "Criada tabela.. "  + cValToChar(cAliasT)
    a160GrvHZ3(cMsgLog)

    //Deleta Tabela no Banco, caso exista
    If TCCanOpen(cAliasT)
        lOk := TCDelFile(cAliasT)
    EndIf

    dbCreate(cAliasT, aFields, "TOPCONN")
    dbUseArea( .T.,"TOPCONN", cAliasT, cAliasT, .T., .F. )

    fDelSMP(cAliasT)

    SMP->(dbSetOrder(1))
    dbselectarea("SMP")
    RecLock("SMP",.T.)
	    Replace SMP->MP_FILIAL   With xFilial( "SMP" ),;
		        SMP->MP_TABELA   With cAliasT,;
                SMP->MP_USUARIO  With cUser,;
			    SMP->MP_DTCONS   With dDataBase
	SMP->(MsUnLock())

Return cAliasT

/*/{Protheus.doc} fDelTabAnt()
Função para tratar criação/deleção da temporária

@author michele.girardi
@since 27/03/2026
@return: Nil
/*/
Static Function fDelTabAnt()
    Local cAliasDel := GetNextAlias()
    Local cQuery    := "" 
    Local dData     := DATE()

    dData := dData - 1    

    cQuery := "  SELECT MP_TABELA, MP_DTCONS "
    cQuery += "    FROM " + RetSqlName("SMP") + " SMP "
    cQuery += "   WHERE SMP.MP_FILIAL   = '" + xFilial( "SMP" ) + "'"
    cQuery += "     AND SMP.MP_DTCONS   < '"+ DTOS(dData) +"' "
    cQuery += "     AND SMP.D_E_L_E_T_  = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDel,.T.,.T.)
    While (cAliasDel)->(!Eof())

        TCDelFile((cAliasDel)->MP_TABELA)
        fDelSMP((cAliasDel)->MP_TABELA)

    	(cAliasDel)->(dbSkip())    
	End
	(cAliasDel)->(DBCloseArea())
Return 

/*/{Protheus.doc} fDelSMP()
Função para deletar tabela temporária

@author michele.girardi
@since 27/03/2026
@return: Nil
/*/
Static Function fDelSMP(cTabela)
    Local cDelete := ''
    Local lOk     := .T.

    cDelete := " DELETE FROM " + RetSqlName("SMP") 
    cDelete += "  WHERE MP_FILIAL   = '" + xFilial( "SMP" ) + "' " 
    cDelete += "    AND MP_TABELA   = '"+ cTabela +"' "
    cDelete += "    AND D_E_L_E_T_  = ' ' "

    lOk := TcSqlExec(cDelete)
Return

/*/{Protheus.doc} a160InTemp()
Inclui tabela para guardar as informações do processamento

@author michele.girardi
@since 12/03/2026
@return: nil
/*/
Function a160InTemp(cAliasT)
    Local ctime    := Time()
    Local dDate    := Date()

    dbSelectArea(cAliasT)

    RecLock(cAliasT,.T.)
        Replace RP_DATINI  With dDate
        Replace RP_HORINI  With ctime
        Replace RP_TOTAL   With 0
        Replace RP_PROC    With 0
        Replace RP_PROCSUC With 0
        Replace RP_PROCERR With 0
        Replace RP_ERRLOCK With 0
        Replace RP_ERRSLD  With 0
        Replace RP_ERRDIV  With 0
    (cAliasT)->(MsUnLock())
    
Return 

/*/{Protheus.doc} P160ErroRP()
Tratamento errorlog multi thread

@author michele.girardi
@since 11/03/2026
@return: Nil
/*/
Function P160ErroRP(__cIDThr, nQtdThread)

    PCPIPCFinish(__cIDThr, 1, nQtdThread)

Return

/*/{Protheus.doc} a160GrvHZ3()
Grava mensagem de log na HZ3

@author michele.girardi
@since 07/04/2026
@param: cMsg - Mensagem
@return: Nil
/*/
Static Function a160GrvHZ3(cMsg)
    Local cSeqLog   := ""
    Local lContinua := .T.

    dbselectarea("HZ3")

    //Verifica se o sequencial ja foi utilizado
    lContinua := .T.
	While lContinua
        cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")
        ConfirmSX8()
        
        If !(HZ3->(dbSeek(xFilial("HZ3")+cSeqLog)))
            Exit
        EndIf
    End

    RecLock("HZ3",.T.)
        REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
        REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
        REPLACE HZ3->HZ3_SEQ 		WITH "000"
        REPLACE HZ3->HZ3_IDENT		WITH "000"            
        REPLACE HZ3->HZ3_MSG	    WITH cMsg
        REPLACE HZ3->HZ3_DTLOG	    WITH Date()
        REPLACE HZ3->HZ3_HRLOG	    WITH Time()
    HZ3->(MSUNLOCK())
    
Return Nil

