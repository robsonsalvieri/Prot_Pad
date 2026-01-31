#include "Protheus.ch"
#include 'TOPCONN.ch'
#include 'OFIA538.ch'

/*/{Protheus.doc} OFIA538
    GLASS - SCANIA
    @type  Function
    @author Renan Migliaris
    @since 20/08/2025
    /*/
Function OFIA538()
    local aArea := FwGetArea()
    local lRet := .f.
    local lFunc := .t.
    private lPePro := ExistBlock("OF538PRO")
    private lPeFim := ExistBlock("OF538FIM")
    private lSched := FWGetRunSchedule()
    private cOrigem := ""
    private cPerg := "OFIA538"
    private lPEnt := ExistBlock("IA440DPG") //questão da chamada de ponto de entrada
    private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)
    private cBZB5 := GetNewPar("MV_CADPROD", '')
    private nValor := 0
    private aFilAtu := FWArrFilAtu()
    private aFilAux := FWAllFilial(aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f.) //traz todas as filiais aqui
    private oTmpTab := nil
    private cAliasTmp := ''
    default lEnd := .t.

    if lSched
        cOrigem := STR0001 //Scheduler
    else
        cOrigem := STR0002 //Menu
    endif

    if !lSched
        while pergunte(cPerg, !lSched)
            if OA538001J_VerificaPerguntePreenchido()
                FWMsgRun(,{|| OA538002J_ProcessaArquivo(@lFUnc)}, STR0004)
                if lFunc
                    FWAlertSuccess(STR0005, STR0006) //'OFIA538' //'Arquivo Processado Com Sucesso!'
                    lRet := .t.
                else
                    FMX_HELP(STR0005, STR0027) //OFIA538 //'Uma ou mais perguntas obrigatórias não foram preenchidas corretamente! Verifique as informações e tente novamente.'
                    OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(STR0009), .t.) //"Erro" //"Erro execução via menu"
                    lRet := .f.
                endif
                Exit
            end
        endDo
    else
        if OA538001J_VerificaPerguntePreenchido()
            OA538002J_ProcessaArquivo(@lFunc)
            lRet := lFunc
        else   
            OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(STR0029), .t.) //"Erro" //"Erro execução via scheduler"
            lRet := .f.
        endif
    endif

    if lPeFim .and. lRet
        ExecBlock("OF538FIM", .f., .f.)
    endif
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} OA538001J_VerificaPerguntePreenchido
    Verificação do eprgunte preenchido
    @author Renan Migliaris
    @since 21/08/2025
/*/
Static Function OA538001J_VerificaPerguntePreenchido()
    local lRet := .t.
    local cExt := alltrim(upper(ExtractExt(MV_PAR05)))
    local aErros := {}
    local cMsg := ''
    local oX1Hlp := FwSX1Util():new()
    local aPergs := {}
    local nX := 0
    local nPar06 := 0

    oX1Hlp:AddGroup(cPerg)
    oX1Hlp:SearchGroup()
    aPergs := oX1Hlp:GetGroup(cPerg)

    if Empty(MV_PAR05) .or. (cExt <> '.DAT')
        aadd(aErros, STR0028)
    endif

    if ValType(MV_PAR06) <> "N"
        nPar06 := 0
    else
        nPar06 := MV_PAR06
    endif

    if len(aErros) > 0 
        if !lSched
            for nx := 1 to len(aErros)
                cMsg += alltrim(aErros[nx])
            next
            FMX_HELP(STR0008, STR0022 + alltrim(cMsg)) //"Erro" //"Os seguintes parâmetros não foram preenchidos corretamente: "
        endif
        lRet := .f.
    endif

Return lRet

/*/{Protheus.doc} OA538002J_ProcessaArquivo()
    Realiza o processamento do arquivo .Dat enviado
    @type  Static Function
    @author Renan Migliaris
    @since 21/08/2025
/*/
Static Function OA538002J_ProcessaArquivo(lRet)
    local cFile := alltrim(MV_PAR05)
    local nAcaoArq := MV_PAR06
    local oFile := FwFileReader():new(cFile)
    local cDest := ''
    local cArqOrig := ''
    local lCopy := .f.
    default lRet := .t.
 
    OA538003J_LogaExecucao(cOrigem, STR0012, OA538004J_ParametrosString()) //"Início"
    if (oFile:Open())
        cArqOrig := alltrim(lower(MV_PAR05))
        OA538005J_PreparaVE9()

        OA538006J_ProcessaArquivoGlass(@oFile)

        lRet := .t.
        oFile:Close()
        OA538003J_LogaExecucao(cOrigem, STR0013, STR0014, .t.) //"Sucesso" //"Processado com sucesso"
        Do Case
            Case nAcaoArq == 2
                cDest := alltrim(lower(alltrim(MV_PAR07)+ "\" + SubStr(cFile, Rat("\", cFile) + 1)))
                lCopy := __CopyFile(cArqOrig, alltrim(lower(cDest)))
                if lCopy
                    oFile:erase()
                endIF
            Case nAcaoArq == 3
                oFile:erase()
        EndCase
    else
        lRet := .f.
        OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(STR0015), .t.) //Erro //"Não foi possível realizar a abertura do arquivo"
    endif
Return lRet

/*/{Protheus.doc} OA538003J_LogaExecucao()
    Realiza o log da operação. 
    @type  Static Function
    @author Renan Migliaris
    @since 21/08/2025
/*/
Static Function OA538003J_LogaExecucao(cOrigem, cTipo, cMensagem, lHorFin)
    local aData := {}
    local oLogger := DMS_Logger():new()
    default lHorFin := .f.

    
    aadd(adata, {"VQL_AGROUP", "OFIA538"})
    aadd(adata, {"VQL_FILORI", cFilAnt})
    aadd(adata, {"VQL_TIPO", cTipo})
    aadd(adata, {"VQL_MSGLOG", cMensagem})
    aadd(adata, {"VQL_DADOS", cOrigem})
    if lHorFin
        aadd(aData, {"VQL_HORAF", VAL(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ))})
        aadd(adata, {"VQL_DATAF", dDataBase})
    endif

    oLogger:LogToTable(aData)
Return

/*/{Protheus.doc} OA538004J_ParametrosString
    Função que vai guardar os parâmetros que foram recebidos pela função para finalidade de log
    Os parâmetros serão guardados no formato json
    @type  Static Function
    @author Renan Migliaris
    @since 22/08/2025
/*/
Static Function OA538004J_ParametrosString(cMsgErro)
    local cParams := ''
    local oParams := JsonObject():new()
    default cMsgErro := ''

    oParams["MV_PAR01"] := MV_PAR01
    oParams["MV_PAR02"] := MV_PAR02
    oParams["MV_PAR03"] := MV_PAR03
    oParams["MV_PAR04"] := MV_PAR04
    oParams["MV_PAR05"] := MV_PAR05
    oParams["MV_PAR06"] := MV_PAR06
    oParams["MV_PAR07"] := MV_PAR07
    if !Empty(cMsgErro)
        oParams["MSG_ERRO"] := cMsgErro
    endif

    cParams := oParams:toJson()

    freeObj(oParams)
Return cParams

/*/{Protheus.doc} OA538005J_PreparaVE9
    Função que irá realizar a preparação da VE9 para uma nova importação
    @type  Static Function
    @author Renan Migliaris
    @since 25/08/2025    
/*/
Static Function OA538005J_PreparaVE9()
    local oStatement := FWPreparedStatement():New()
    local cQuery := ''
    local cFinalQuery := ''
    local cVeFilial := ''
    DbSelectArea("VE9")
    cVeFilial := xFilial('VE9')
    
    Do Case
        Case Empty(cVeFilial)
            //truncate não vai passar linha a linha deletando o que vai gerar mais performance quando apagar a VE9 
            //tabela será trucanda em casos que a VE9 seja compartilhada
            cQuery := " TRUNCATE TABLE " + RetSQLName('VE9')
            oStatement:SetQuery(cQuery)
        Otherwise
            cQuery := " DELETE FROM " +RetSQLName("VE9")
            cQuery += " WHERE VE9_FILIAL = ? "
            oStatement:SetQuery(cQuery)
            oStatement:SetString(1, cVeFilial)
    EndCase
    
    cFinalQuery := oStatement:GetFixQuery()

    TCSqlExec(cFinalQuery)
Return .t.

/*/{Protheus.doc} OA538006J_ProcessaArquivoGlass
    Realiza o processamento do arquivo .dat (glass)
    @type  Static Function
    @author Renan Migliaris
    @since 25/08/2025
/*/
Static Function OA538006J_ProcessaArquivoGlass(oFile)
    local lRet := .t.

    begin transaction
        if OA538014J_CriaTabelaTemporaria(@oFile)
            OA538008J_GravaVE9(@oTmpTab)
            OA538007J_VerificaEGravaSb1(@oTmpTab)
            
            If "SB5" $ cBZB5
                OA538009J_VerificaEGravaSb5(@oTmpTab)
            EndIf

            If "SBZ" $ cBZB5
                OA538010J_VerificaEGravaSBZ(@oTmpTab)
            EndIf

            OA538012J_VerificaEGravaVEH(@oTmpTab)
            OA538013J_VerificaEGravaVE8(@oTmpTab)
            oTmpTab:Delete()
        endif
    end transaction
Return lRet

/*/{Protheus.doc} OA538007J_VerificaEGravaSb1
    Verifica via query quais os registros que não existem na SB1 
    Caso não existirem eu já faço a inclusão deles via bulk
    Mando a tmpTable aqui como parâmetro para acessar seus respectivos métodos do objeto como por exemplo o realname
    @type  Static Function
    @author Renan Migliaris
    @since 27/08/2025
/*/
Static Function OA538007J_VerificaEGravaSb1(oTmpTab)
    local cQuery := ''
    local cRealName := oTmpTab:GetTableNameForQuery()
    local cAlias := ''
    local nX := 0
    local lOk := .t.
    local aFields := {}
    local aFieAux := {}
    local aItem := {}
    local aItAux := {}
    local aFils := OA538015J_VerificaAcessoExclusivo("SB1")
    local oBulkB1 := FwBulk():new(RetSQLName('SB1'), 850)
    local cErro := ''

    aFields := { ;
        {"B1_FILIAL"}, {"B1_COD"}, {"B1_GRUPO"}, {"B1_CODITE"}, {"B1_FABRIC"}, {"B1_DESC"}, ;
        {"B1_UM"}, {"B1_SEGUM"}, {"B1_TIPO"}, {"B1_LOCPAD"}, {"B1_PICM"}, ;
        {"B1_IPI"}, {"B1_PRV1"}, {"B1_CONTA"}, {"B1_CC"}, {"B1_PESO"}, ;
        {"B1_TIPOCQ"}, {"B1_ORIGEM"}, {"B1_CLASFIS"} ;
    }

    if lPePro
        aFieAux := ExecBlock("OF538PRO", .f., .f., {"SB1", .t.})
    endif

    OA538020J_SetaFieldsBulk(@oBulkB1, @aFields, aFieAux)
    
    for nX := 1 to len(aFils)
        cQuery := " SELECT " 
        cQuery += "    T.CODIGO, "
        cQuery += "    T.GRUPO, "
        cQuery += "    T.CODITE, "
        cQuery += "    T.FABRIC, "
        cQuery += "    T.DESCRIC, "
        cQuery += "    T.UM, "
        cQuery += "    T.SEGUM, "
        cQuery += "    T.TIPO, "
        cQuery += "    T.LOCPAD, "
        cQuery += "    T.PICM, "
        cQuery += "    T.IPI, "
        cQuery += "    T.PRV1, "
        cQuery += "    T.CONTA, "
        cQuery += "    T.CENTRO, "
        cQuery += "    T.PESO, "
        cQuery += "    T.TIPOCQ, "
        cQuery += "    T.ORIGEM, "
        cQuery += "    T.CLASFIS "
        cQuery += " FROM " + cRealName + " T "
        cQuery += " WHERE "
        cQuery += "    T.SEGMENTO = '01' "
        cQuery += "    AND NOT EXISTS ( "
        cQuery += "    SELECT 1 FROM " + RetSQLName("SB1") + " SB1 "
        cQuery += "    WHERE SB1.B1_FILIAL = '" + aFils[nX] + "' "
        cQuery += "      AND SB1.B1_GRUPO  = T.GRUPO "
        cQuery += "      AND SB1.B1_CODITE = T.CODITE "
        cQuery += "      AND SB1.D_E_L_E_T_ = ' ' "
        cQuery += ")"

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)

        while !(cAlias)->(eof())
            aItem := {}
            aadd(aItem, {;
                aFils[nX],;
                (cAlias)->CODIGO,;
                (cAlias)->GRUPO,; 
                (cAlias)->CODITE,;
                (cAlias)->FABRIC,; 
                (cAlias)->DESCRIC,; 
                (cAlias)->UM,; 
                (cAlias)->SEGUM,;
                (cAlias)->TIPO,;
                (cAlias)->LOCPAD,;
                (cAlias)->PICM,;
                (cAlias)->IPI,;
                (cAlias)->PRV1,;
                (cAlias)->CONTA,;
                (cAlias)->CENTRO,;
                (cAlias)->PESO,;
                (cAlias)->TIPOCQ,;
                (cAlias)->ORIGEM,;
                (cAlias)->CLASFIS;
            })

            aItAux := aClone(aItem)

            if lPePro
                aItAux := ExecBlock("OF538PRO", .f., .f., {"SB1", .f. ,aItAux})
            endif

            OA538021J_SetaODadoDoItem(@oBulkB1, aItAux)

            fwFreeArray(aItem)
            fwFreeArray(aItAux)
            (cAlias)->(DbSkip())
        endDo

        (cAlias)->(dbCloseArea())
        oBulkB1:flush()
    next

    lOk := oBulkB1:Close()
    cErro := oBulkB1:GetError()
    iif(empty(cErro), OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString(STR0017)), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cErro + " SB1")))
    oBulkB1:Destroy()

    fwFreeArray(aFils)
    fwFreeArray(aFields)
    freeObj(oBulkB1)
Return lOk

/*/{Protheus.doc} OA538008J_GravaVE9
    Aqui já vou fazer o processamento da VE9 em outra thread. 
    Vou receber os parâmetros de filial + empresa 
    o terceiro elemento do array vai ser os dados a serem processados já filtrados pelo 01 
    Ou seja, vou montando o cLinha aqui para realizar o bulk da VE9
    @type Function
    @author Renan Migliaris
    @since 28/08/2025
/*/
Static Function OA538008J_GravaVE9(oTmpTab)
    local aVe9 := {}
    local cQuery := ''
    local lOk := .t.
    local cAlias := ''
    local cRealName := oTmpTab:GetTableNameForQuery()
    local oBulkVE9 := FwBulk():new(RetSQLName('VE9'), 850)
    local cMyFil := xFilial("VE9")
    local cErro := ''
    
    aVE9 := {;
        {"VE9_FILIAL"}, {"VE9_NROSEQ"}, {"VE9_NROSUB"}, {"VE9_GRUITE"},;
        {"VE9_ITEANT"}, {"VE9_ITENOV"}, {"VE9_SEGMEN"}, {"VE9_STAGLA"},;
        {"VE9_APLICA"}, {"VE9_STATUS"}, {"VE9_DATSUB"}, {"VE9_QTDADE"},; 
        {"VE9_QTDSUB"}, {"VE9_GRUNOV"};
    }

    oBulkVE9:setFields(aVe9)

    cQuery := "SELECT "
    cQuery += "    T.SEQVE9, "
    cQuery += "    T.NROSUBVE9, "
    cQuery += "    T.ITENOV, "
    cQuery += "    T.GRUPO, "
    cQuery += "    T.ITEANT, "
    cQuery += "    T.SEGMENTO, "
    cQuery += "    T.STAGLA, "
    cQuery += "    T.APLICA, "
    cQuery += "    T.STATUS, "
    cQuery += "    T.DATSUB, "
    cQuery += "    T.QTDADE, "
    cQuery += "    T.QTDSUB "
    cQuery += "FROM " + cRealName + " T"
    cQuery += " WHERE T.SEGMENTO IN ('01','02','04','06') "
    cAlias := GetNextAlias()
    
    dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)

    while !(cAlias)->(eof())
        oBulkVE9:addData({;
            cMyFil,;
            (cAlias)->SEQVE9,;
            (cAlias)->NROSUBVE9,;
            (cAlias)->GRUPO,;
            (cAlias)->ITEANT,;
            (cAlias)->ITENOV,;
            (cAlias)->SEGMENTO,;
            (cAlias)->STAGLA,;
            (cAlias)->APLICA,;
            (cAlias)->STATUS,;
            (cAlias)->DATSUB,;
            (cAlias)->QTDADE,;
            (cAlias)->QTDSUB,;
            (cAlias)->GRUPO;
        })
        (cAlias)->(DbSkip())
    end

    oBulkVE9:flush()
    lOk := oBulkVE9:Close()
    oBulkVE9:destroy()

    (cAlias)->(dbCloseArea())
    cErro := oBulkVE9:GetError()
    iif(empty(cErro), OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString(STR0018), .t.), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cErro + " VE9"), .t.))
    freeObj(oBulkVE9)
Return lOk

/*/{Protheus.doc} OA538009J_VerificaEGravaSb5
    Aqui vou ver quais itens que estão na SB5 e que precisarão ser atualizados. 
    Recebo o array aqui faço um batch no banco de dados e obtenho o retorno do que precisa ser atualizado.
    A busca será feita pelo código do item e deverá considerar todas as filiais
    Primeiro item do aParams vai ser meu array para processamento da braba
    @type  Static Function
    @author Renan Migliaris
    @since 28/08/2025
/*/
Static Function OA538009J_VerificaEGravaSb5(oTmpTab)
    local lOk := .t.
    local aB5Fields := {}
    local nI := 0
    local oBulkB5 := FwBulk():new(RetSQLName("SB5"), 850)
    local cQuery := ''
    local cRealName := oTmpTab:GetTableNameForQuery()
    local cAlias := ''
    local aFils := OA538015J_VerificaAcessoExclusivo("SB5")
    local aFieAux := {}
    local aItAux := {}
    local aItem := {}
    local cError := ''

    aB5Fields := {;
        {"B5_FILIAL"}, {"B5_COD"}, {"B5_CEME"}, {"B5_UMIND"};
    }

    if lPePro
        aFieAux := ExecBlock("OF538PRO", .f., .f., {"SB5", .t.})
    endif

    OA538020J_SetaFieldsBulk(@obulkB5, @aB5Fields, aFieAux)

    for nI := 1 to len(aFils)
        cQuery := "SELECT T.CODIGO, T.DESCRIC FROM " + cRealName + " T "
        cQuery += " WHERE "
        cQuery += "     T.SEGMENTO = '01' "
        cQuery += "     AND NOT EXISTS ( "
        cQuery += "     SELECT 1 FROM "+ RetSQLName("SB5") + " SB5 "
        cQuery += "     WHERE SB5.B5_FILIAL = '" +aFils[ni]+"'" 
        cQuery += "         AND SB5.B5_COD = T.CODIGO "
        cQuery += "         AND SB5.D_E_L_E_T_ = ' ' "
        cQuery += " )"
        
        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)

        while !(cAlias)->(eof())
            aItem := {}
            aadd(aItem,  {;
                aFils[ni],;
                (cAlias)->CODIGO,;
                (cAlias)->DESCRIC,;
                "1";
            })

            aItAux := aClone(aItem)

            if lPePro
                aItAux := ExecBlock("OF538PRO", .f., .f., {"SB5", .f., aItAux})
            endif
            
            OA538021J_SetaODadoDoItem(@oBulkB5, aItAux)

            fwFreeArray(aItem)
            fwFreeArray(aItAux)
            (cAlias)->(dbSkip())
        endDo
        (cAlias)->(dbCloseArea())
        oBulkB5:flush()
    next

    lOk := oBulkB5:Close()
    cError := oBulkB5:GetError()

    iif(Empty(cError), OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString(STR0019)), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cError + " SB5")))
    oBulkB5:destroy()

    fwFreeArray(aFils)
    fwFreeArray(aB5Fields)
    freeObj(obulkB5)
return lOk

/*/{Protheus.doc} OA538010J_VerificaEGravaSBZ
    Caso tiver o parâmetro da SBZ vai fazer a gravação dela nessa função aqui
    @type  Static Function
    @author Renan Migliaris
    @since 10/09/2025
/*/
Static Function OA538010J_VerificaEGravaSBZ(oTmpTab)
    local lOk := .t.
    local aBZFields := {}
    local nI := 0
    local oBulkBZ := FwBulk():new(RetSqlName("SBZ"), 850)
    local cQuery := ''
    local cRealName := oTmpTab:GetTableNameForQuery()
    local cAlias := ''
    local aFils := OA538015J_VerificaAcessoExclusivo("SBZ")
    local aFieAux := {}
    local aItem := {}
    local aItAux := {}
    local cErro := ''

    aBZFields := {;
        {"BZ_FILIAL"}, {"BZ_COD"}, {"BZ_LOCPAD"};
    }
    
    if lPePro
        aFieAux := ExecBlock("OF538PRO", .f., .f., {"SBZ", .t.})
    endif

    OA538020J_SetaFieldsBulk(@oBulkBZ, @aBZFields, aFieAux)

    for ni := 1 to len(aFils)
        
        cQuery := " SELECT T.CODIGO, T.LOCPAD FROM " + cRealName + " T "
        cQuery += " WHERE "
        cQuery += "     T.SEGMENTO = '01' "
        cQuery += "     AND NOT EXISTS ( "
        cQuery += "     SELECT 1 FROM "+RetSqlName("SBZ")+" SBZ "
        cQuery += "     WHERE SBZ.BZ_FILIAL = '"+aFils[ni]+"' "
        cQuery += "         AND SBZ.BZ_COD = T.CODIGO "
        cQuery += "         AND SBZ.D_E_L_E_T_ = ' ' "
        cQuery += " )"

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)

        while !(cAlias)->(eof())
            aItem := {}
            aadd(aItem, {;
                aFilAux[ni],;
                (cAlias)->CODIGO,;
                (cAlias)->LOCPAD;
            })

            aItAux := aClone(aItem)

            if lPePro
                aItAux := ExecBlock("OF538PRO", .f., .f., {"SBZ", .f., aItAux})
            endif

            OA538021J_SetaODadoDoItem(@oBulkBZ, aItAux)

            fwFreeArray(aItem)
            fwFreeArray(aItAux)
            (cAlias)->(dbSkip())
        endDo

        (cAlias)->(dbCloseArea())
        oBulkBZ:flush()
    next

    lOk := oBulkBZ:Close()

    cErro := oBulkBZ:GetError()
    iif(Empty(cErro), OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString(STR0020)), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cErro + " SBZ"))) //"SUCESSO" //SBZ Salva
    oBulkBZ:destroy()


    fwFreeArray(aFils)
    fwFreeArray(aBZFields)
    freeObj(oBulkBZ)
Return lOk

/*/{Protheus.doc} OA538011J_MontaItemDeAcordoComOSeguimento
    Vai montar o Itenov de acordo com a linha recebida para a inserção na tabela temporária
    @type  Static Function
    @author Renan Migliaris
    @since 15/09/2025
/*/
Static Function OA538011J_MontaItemDeAcordoComOSeguimento(cLinha)
    Local oRetorno
    Local cSegmento := Left(cLinha, 2)

    oRetorno := JsonObject():new()
    oRetorno["CODIGO"] := UPPER(Subs(cLinha, 3, 7))
    oRetorno["CODITE"] := UPPER(Subs(cLinha, 3, 7))
    oRetorno["DESCRICAO"] := UPPER(Subs(cLinha, 10, 15))
    oRetorno["APLICA"] := ""
    oRetorno["ITEANT"] := UPPER(Subs(cLinha, 3, 7))
    oRetorno["SEGMENTO"] := cSegmento
    oRetorno["ITENOV"] := ""
    oRetorno["CODITE"] := ""
    oRetorno["STAGLA"] := ""
    oRetorno["QTDADE"] := 0
    oRetorno["DATSUB"] := ""
    oRetorno["QTDSUB"] := 0
    oRetorno["STATUS"] := ""
    oRetorno["CODKIT"] := ""

    Do Case
        Case cSegmento == "01" //informação básica do item
            oRetorno["ITENOV"] := UPPER(Subs(cLinha, 3, 7))
            oRetorno["CODITE"] := UPPER(Subs(cLinha, 3, 7))
            oRetorno["STAGLA"] := UPPER(Subs(cLinha, 55, 30))
        
        Case cSegmento == "02"
            oRetorno["APLICA"] := UPPER(Subs(cLinha, 10,35))
            oRetorno["ITENOV"] := UPPER(Subs(cLinha, 3, 7))

        Case cSegmento == "04" //informacoes substituo do item
            oRetorno["ITENOV"] := UPPER(Subs(cLinha, 10, 10))
            oRetorno["QTDADE"] := Val(Subs(cLinha, 20, 7))
            oRetorno["DATSUB"] := dDataBase
            oRetorno["QTDSUB"] := Val(Subs(cLinha, 20, 7))
            oRetorno["STATUS"] := "99"
        
        Case cSegmento == "06" //kits
            oRetorno["CODITE"] := UPPER(Subs(cLinha, 10, 7))
            oRetorno["QTDADE"] := Val(Subs(cLinha, 20, 7))
            oRetorno["CODKIT"] := UPPER(Subs(cLinha, 3, 7))
    EndCase

Return oRetorno

/*/{Protheus.doc} OA538013J_VerificaEGravaVEH
    Vai criar ou atualizar a tabela VEH de acordo com as informações do segmento 06 do arquivo GLASS    
    Tabela cabeçalho de kits
    @type  Static Function
    @author Renan Migliaris
    @since 17/09/2025
/*/
Static Function OA538012J_VerificaEGravaVEH(oTmpTab)
    local lRet := .t.
    local lOk := .t.
    local cQuery := ''
    local aVEHFields := {}
    local oBulkVEH := FwBulk():new(RetSQLName("VEH"), 850)
    local cRealName := oTmpTab:GetTableNameForQuery()
    local cAlias := ''
    local aFils := OA538015J_VerificaAcessoExclusivo("VEH")
    local nX := 0
    local cErro := ''

    aVEHFields := {;
        {"VEH_FILIAL"},; 
        {"VEH_TIPO"},;
        {"VEH_GRUKIT"},; 
        {"VEH_CODKIT"},; 
        {"VEH_DESKIT"},; 
        {"VEH_VALKIT"};
    }

    oBulkVEH:setFields(aVEHFields)

    for nx := 1 to len(aFils)
        cQuery := " SELECT DISTINCT "
        cQuery += "     T.CODKIT, "
        cQuery += "     T.GRUPO, "
        cQuery += "     B1.B1_DESC AS DESKIT "
        cQuery += " FROM " + cRealName + " T "
        cQuery += " LEFT JOIN " + RetSQLName("SB1") + " B1 "
        cQuery += "     ON B1.B1_COD   = T.CODKIT "
        cQuery += "     AND B1.B1_GRUPO = T.GRUPO  "
        cQuery += "     AND B1.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE T.SEGMENTO = '06' "
        cQuery += "   AND T.CODKIT <> ' ' "
        cQuery += "   AND NOT EXISTS ( "
        cQuery += "       SELECT 1 "
        cQuery += "       FROM " + RetSQLName("VEH") + " VEH "
        cQuery += "       WHERE VEH.VEH_FILIAL = '" + aFils[nx] + "' "
        cQuery += "         AND VEH.VEH_CODKIT = T.CODKIT "
        cQuery += "         AND VEH.VEH_GRUKIT = T.GRUPO "
        cQuery += "         AND VEH.VEH_TIPO = '2' "
        cQuery += "         AND VEH.D_E_L_E_T_ = ' ' "
        cQuery += "   ) "

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)
        while !(cAlias)->(eof())
            oBulkVEH:addData({;
                aFils[nx],; //filial
                "2",; //tipo 2 seguindo a rotina OFIIA440 ele foi chumbado lá como tipo 2 
                (cAlias)->GRUPO,; //grukit
                (cAlias)->CODKIT,; //codkit
                (cAlias)->DESKIT,; //deskit
                0; //valkit valor que foi chumbado na rotina original OFIIA440
            })

            (cAlias)->(dbSkip())
        endDo
        (cAlias)->(dbCloseArea())
        oBulkVEH:flush()
    next

    lOk := oBulkVEH:Close()
    cErro := oBulkVEH:GetError() 
    iif(empty(cErro),OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString("VEH SALVA")), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cErro + " VEH")))
    oBulkVEH:destroy()
    freeObj(oBulkVEH)
    fwFreeArray(aVEHFields)
Return lRet 

/*/{Protheus.doc} OA538013J_VerificaEGravaVE8
    Função que irá verificar, gravar ou atualizar a tabela VE8
    Se o registro não existir vai pro bulk insert
    Se existir vou atualizar ele
    A VE8 é uma tabela filho da VEH
    @type  Static Function
    @author Renan Migliaris
    @since 18/09/2025
/*/
Static Function OA538013J_VerificaEGravaVE8(oTmpTab)
    local lRet := .t.
    local lOk := .t.
    local cQuery := ''
    local aVE8Fields := {}
    local oBulkVE8 := FwBulk():new(RetSQLName("VE8"), 850)
    local cRealName := oTmpTab:GetTableNameForQuery()
    local cAlias := ''
    local aFils := OA538015J_VerificaAcessoExclusivo("VE8")
    local nX := 0
    local cErro := ''

    aVE8Fields := {;
        {"VE8_FILIAL"},; 
        {"VE8_TIPO"},; 
        {"VE8_GRUKIT"},; 
        {"VE8_CODKIT"},; 
        {"VE8_GRUITE"},; 
        {"VE8_CODITE"},; 
        {"VE8_QTDADE"};
    }

    oBulkVE8:setFields(aVE8Fields)

    for nx := 1 to len(aFils)
        cQuery := " SELECT "
        cQuery += "  T.CODKIT, "
        cQuery += "  T.GRUPOKIT, "
        cQuery += "  T.CODITE, "
        cQuery += "  T.QTDADE, "
        cQuery += "  T.GRUPO "
        cQuery += " FROM " + cRealName + " T "
        cQuery += " WHERE "
        cQuery += "     T.SEGMENTO = '06' "
        cQuery += "     AND T.CODKIT <> ' ' "
        cQuery += "     AND T.GRUPOKIT <> ' ' "
        cQuery += "     AND NOT EXISTS ( "
        cQuery += "     SELECT 1 FROM "+RetSQLName("VE8")+" VE8 "
        cQuery += "     WHERE VE8.VE8_FILIAL =  '"+aFils[nx]+"' "
        cQuery += "        AND VE8.VE8_GRUKIT = T.GRUPOKIT "
        cQuery += "        AND VE8.VE8_CODKIT = T.CODKIT "
        cQuery += "        AND VE8.VE8_GRUITE = T.GRUPO "
        cQuery += "        AND VE8.VE8_CODITE = T.CODITE "
        cQuery += "        AND VE8.D_E_L_E_T_ = ' ' "
        cQuery += "        AND T.CODKIT <> ' ' "
        cQuery += "        AND T.GRUPOKIT <> ' ' "
        cQuery += "        AND T.CODITE <> ' ' "
        cQuery += "        AND T.GRUPO <> ' ' "
        cQuery += " )"

        cAlias := GetNextAlias()

        dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .f., .t.)
        while !(cAlias)->(eof())
            oBulkVE8:addData({;
                aFils[nx],; //filial
                "1",; //tipo 1 seguindo a rotina OFIIA440 ele foi chumbado lá como tipo 2 
                (cAlias)->GRUPOKIT,; //grukit
                (cAlias)->CODKIT,; //codkit
                (cAlias)->GRUPO,; //gruitem
                (cAlias)->CODITE,; //codite
                (cAlias)->QTDADE; //qtidade
            })

            (cAlias)->(dbSkip())
        endDo
        (cAlias)->(dbCloseArea())
        oBulkVE8:flush()
    next
    lOk := oBulkVE8:Close()
    cErro := oBulkVE8:GetError()
    iif(empty(cErro), OA538003J_LogaExecucao(cOrigem, STR0013, OA538004J_ParametrosString("VE8 SALVA")), OA538003J_LogaExecucao(cOrigem, STR0008, OA538004J_ParametrosString(cErro + " VE8")))
    oBulkVE8:destroy()
    freeObj(oBulkVE8)
    fwFreeArray(aVE8Fields)
Return lRet

/*/{Protheus.doc} OA538014J_CriaTabelaTemporaria
    Função que vai criar a tabela temporária que irá armazenar os dados do arquivo glass
    A tabela temporária será destruída no final do processamento
    A partir dela que as demais "alimentações" das tabelas serão feitas
    @type  Static Function
    @author user
    @since 17/09/2025
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function OA538014J_CriaTabelaTemporaria(oFile)
    local lRet := .t.
    local aBulkFie := {}
    local aFields := {}
    local cCenCus := ''
    local cDesmar := ''
    local cCtaCtb := ''
    local cGruIte := ''
    local cRealName := ''
    local nCont := 0
    local cLinha := ''
    local nLinha := 0
    local nX := 0
    local nTFabr := TamSX3("B1_FABRIC")[1]
    local oItem := nil
    local oBulk := nil
    local cNumSeq := Strzero(0,TamSX3("VE9_NROSEQ")[1])
    
    cGruIte := MV_PAR01

    DbSelectArea('VE4')
    DbSetOrder(1)
    DbSeek(xFilial('VE4'))

    if !Empty(MV_PAR02)
        cCenCus := alltrim(MV_PAR02)
    else 
        cCencus := VE4->VE4_CENCUS
    endif

    if !Empty(MV_PAR03)
        cCtaCtb := alltrim(MV_PAR03)
    else 
        cCtaCtb := VE4->VE4_CTACTB
    endif

    aadd(aFields, {"CODIGO", "C", TamSX3("B1_COD")[1], TamSX3("B1_COD")[2]})
    aadd(aFields, {"GRUPO", "C", TamSX3("B1_GRUPO")[1], TamSX3("B1_GRUPO")[2]})
    aadd(aFields, {"CODITE", "C", TamSX3("B1_CODITE")[1], TamSX3("B1_CODITE")[2]})
    aadd(aFields, {"FABRIC", "C", TamSX3("B1_FABRIC")[1], TamSX3("B1_FABRIC")[2]})
    aadd(aFields, {"DESCRIC", "C", TamSX3("B1_DESC")[1], TamSX3("B1_DESC")[2]})
    aadd(aFields, {"UM", "C", TamSX3("B1_UM")[1], TamSX3("B1_UM")[2]})
    aadd(aFields, {"SEGUM", "C", TamSX3("B1_SEGUM")[1], TamSX3("B1_SEGUM")[2]})
    aadd(aFields, {"TIPO", "C", TamSX3("B1_TIPO")[1], TamSX3("B1_TIPO")[2]})
    aadd(aFields, {"LOCPAD", "C", TamSX3("B1_LOCPAD")[1], TamSX3("B1_LOCPAD")[2]})
    aadd(aFields, {"PICM", "N", TamSX3("B1_PICM")[1], TamSX3("B1_PICM")[2]})
    aadd(aFields, {"IPI", "N", TamSX3("B1_IPI")[1], TamSX3("B1_IPI")[2]})
    aadd(aFields, {"PRV1", "N", TamSX3("B1_PRV1")[1], TamSX3("B1_PRV1")[2]})
    aadd(aFields, {"CONTA", "C", TamSX3("B1_CONTA")[1], TamSX3("B1_CONTA")[2]})
    aadd(aFields, {"CENTRO", "C", TamSX3("B1_CC")[1], TamSX3("B1_CC")[2]})
    aadd(aFields, {"PESO", "N", TamSX3("B1_PESO")[1], TamSX3("B1_PESO")[2]})
    aadd(aFields, {"TIPOCQ", "C", TamSX3("B1_TIPOCQ")[1], TamSX3("B1_TIPOCQ")[2]})
    aadd(aFields, {"ORIGEM", "C", TamSX3("B1_ORIGEM")[1], TamSX3("B1_ORIGEM")[2]})
    aadd(aFields, {"CLASFIS", "C", TamSX3("B1_CLASFIS")[1], TamSX3("B1_CLASFIS")[2]})
    aadd(aFields, {"SEQVE9", "C", TamSX3("VE9_NROSEQ")[1], TamSX3("VE9_NROSEQ")[2]})
    aadd(aFields, {"NROSUBVE9", "C", TamSX3("VE9_NROSUB")[1], TamSX3("VE9_NROSUB")[2]})
    aadd(aFields, {"ITENOV", "C", TamSX3("VE9_ITENOV")[1], TamSX3("VE9_ITENOV")[2]})
    aadd(aFields, {"ITEANT", "C", TamSX3("VE9_ITEANT")[1], TamSX3("VE9_ITEANT")[2]})
    aadd(aFields, {"STAGLA", "C", TamSX3("VE9_STAGLA")[1], TamSX3("VE9_STAGLA")[2]})
    aadd(aFields, {"APLICA", "C", TamSX3("VE9_APLICA")[1], TamSX3("VE9_APLICA")[2]})
    aadd(aFields, {"QTDADE", "N", TamSX3("VE9_QTDADE")[1], TamSX3("VE9_QTDADE")[2]})
    aadd(aFields, {"DATSUB", "D", TamSX3("VE9_DATSUB")[1], TamSX3("VE9_DATSUB")[2]})
    aadd(aFields, {"QTDSUB", "N", TamSX3("VE9_QTDSUB")[1], TamSX3("VE9_QTDSUB")[2]})
    aadd(aFields, {"STATUS", "C", TamSX3("VE9_STATUS")[1], TamSX3("VE9_STATUS")[2]})
    aadd(aFields, {"SEGMENTO", "C", TamSX3("VE9_SEGMEN")[1], TamSX3("VE9_SEGMEN")[2]})
    aadd(aFields, {"CODKIT", "C", TamSx3("VE8_CODKIT")[1], TamSX3("VE8_CODKIT")[2]})
    aadd(aFields, {"GRUPOKIT", "C", TamSx3("VE8_GRUKIT")[1], TamSX3("VE8_GRUKIT")[2]})

    cAliasTmp := GetNextAlias()
    oTmpTab := FWTemporaryTable():new(cAliasTmp) 
    oTmpTab:setFields(aFields)
    oTmpTab:addIndex("1", {"CODIGO"})

    for nX := 1 to len(aFields)
        aadd(aBulkFie, {aFields[nx][1]})
    next

    oTmpTab:Create() 

    DbSelectArea("VE1")
    DbSetOrder(1)
    DbSeek(xFilial("VE1") + VE4->VE4_PREFAB)

    cDesmar := Left(VE1->VE1_DESMAR, nTFabr)

    cRealName := oTmpTab:GetTableNameForTCFunctions() //função para pegar o nome para ser usada em outras funções do DBAccess
    
    
    oBulk := FwBulk():new(cRealName)
    oBulk:setFields(aBulkFie)

    while oFile:hasLine()
        nCont++
        cNumSeq := soma1(cNumSeq)
        cLinha := oFile:GetLine()
        oItem := OA538011J_MontaItemDeAcordoComOSeguimento(cLinha)
        if Left(cLinha,2) == "01" .or. Left(cLinha,2) == "04" .or. Left(cLinha,2) == "06" .or. Left(cLinha,2) == "02"
            oBulk:addData({;
                oItem["CODIGO"],;                              // CODIGO
                cGruIte,;                                      // GRUPO
                oItem["CODITE"],;                              // CODITE
                cDesmar,;                                      // FABRIC
                oItem["DESCRICAO"],;                           // DESCRIC
                "PC",;                                         // UM
                "PC",;                                         // SEGUM
                "ME",;                                         // TIPO
                alltrim(MV_PAR04),;                            // LOCPAD
                0,;                                            // PICM 
                0,;                                            // IPI 
                0,;                                            // PRV1 
                cCtaCtb,;                                      // CONTA
                cCenCus,;                                      // CENTRO
                1,;                                            // PESO 
                "M",;                                          // TIPOCQ 
                "0",;                                          // ORIGEM 
                "00",;                                         // CLASFIS 
                cNumSeq,;                                      // SEQVE9
                Strzero(nCont,TamSX3("VE9_NROSUB")[1]),;       // NROSUBVE9 //Soma1 com tamanho 6
                oItem["ITENOV"],;                              // ITENOV
                oItem["ITEANT"],;                              // ITEANT
                oItem["STAGLA"],;                              // STAGLA
                oItem["APLICA"],;                              // APLICA 
                oItem["QTDADE"],;                              // QTDADE
                oItem["DATSUB"],;                              // DATSUB
                oItem["QTDSUB"],;                              // QTDSUB
                oItem["STATUS"],;                              // STATUS
                oItem["SEGMENTO"],;                            // SEGMENTO
                oItem["CODKIT"],;                              // CODKIT
                cGruIte;                                       // GRUPOKIT
            })
        endif
        nLinha++
    endDo
    oBulk:flush()
    oBulk:Close()
    oBulk:destroy()
    
    fwFreeArray(aFields)
    fwFreeArray(aBulkFie)
    freeObj(oBulk)
Return lRet

/*/{Protheus.doc} OA538015J_VerificaAcessoExclusivo
    Vai verificar se o acesso é exclusivo.
    Se o acesso for compartilhado vai retornar um array de filiais com o xFilial do alias recebido
    Caso contrário a função que chamar aqui vai usar a private aFilAux
    @type  Static Function
    @author Renan Migliaris
    @since 18/09/2025
/*/
Static Function OA538015J_VerificaAcessoExclusivo(cAlias)
    local aRet := {}

    if FWModeAccess(cAlias, 3) == "E"
        aRet := aClone(aFilAux)
    else
        aRet := {xFilial(cAlias)} 
    endif

Return aRet


/*/{Protheus.doc} OA538016J
    Valida o grupo da peça informado no parâmetro MV_PAR01
    @type  Function
    @author Renan Migliaris
    @since 19/09/2025
    /*/
Function OA538016J()
    local lRet := .t.
    DbSelectArea("SBM")
    DbSetOrder(1)
    
    if !Empty(MV_PAR01) .and. (DbSeek(xFilial("SBM") + MV_PAR01))
        lRet := .t.
    else
        FMX_HELP(STR0005, STR0026) //OFIA538 //"Grupo Padrão da Peça Inválido"
        lRet := .f.
    endif
    dbCloseArea()
Return lRet

/*/{Protheus.doc} OA538016J
    Valida o MV_PAR02 Conta Padrão
    @type  Function
    @author Renan Migliaris
    @since 19/09/2025
    /*/
Function OA538017J()
    local lRet := .t.
    DbSelectArea("CT1")
    DbSetOrder(1)
    if !Empty(MV_PAR02)
        If !DbSeek(xFilial("CT1") + MV_PAR02)
            FMX_HELP(STR0005, STR0025) //"OFIA538" //"Conta Contábil Padrão da Peça Inválida"
            lRet := .f.
        EndIf
    endif
    dbCloseArea()
Return lRet

/*/{Protheus.doc} OA538017J
    Valida o MV_PAR03 CTT
    @type  Function
    @author Renan Migliaris
    @since 19/09/2025
    /*/
Function OA538018J()
    local lRet := .t. 
    DbSelectArea("CTT")
    DbSetOrder(1)

    if !Empty(MV_PAR03)
        If !DbSeek(xFilial("CTT") + MV_PAR03)
            FMX_HELP(STR0005, STR0024) //"OFIA538" //"Centro de Custo Padrão da Peça Inválido"
            lRet := .f.
        EndIf
    endif
    dbCloseArea()
Return lRet


/*/{Protheus.doc} OA538018J
    Valida o MV_PAR04 Localização Padrão
    @type  Function
    @author Renan Migliaris
    @since 19/09/2025
    /*/
Function OA538019J()
    local lRet := .t.
    DbSelectArea("NNR")
    DbSetOrder(1)
    
    if !Empty(MV_PAR04) .and. (DbSeek(xFilial("NNR") + MV_PAR04))
        lRet := .t.
    else
        FMX_HELP(STR0005, STR0023) //"OFIA538" //"Localização Padrão da Peça Inválida"
        lRet := .f.
    endif
    dbCloseArea()
Return lRet

/*/{Protheus.doc} OA538020J_SetaFieldsBulk
    Verifica os arrays de fields que podem vir ou não do ponto de entrada
    Seta o bulk da maneira correta com o array certo 
    Manipula o objeto pra fazer esse insert bulk 
    @type  Static Function
    @author Renan Migliaris
    @since 26/09/2025
/*/
Static Function OA538020J_SetaFieldsBulk(oBulk, aFields, aFielAux)
    local nX := 0

    if (valtype(aFielAux) == "A") .and. (len(aFielAux) > 0)
        for nx := 1 to len(aFielAux)
            aadd(aFields, aFielAux[nx])
        next
    endif

    oBulk:setFields(aFields)
Return

/*/{Protheus.doc} OA538021J_SetaODadoDoItem
    Mesma coisa da setaField só que com o dado do item
    @type  Static Function
    @author Renan Migliaris
    @since 26/09/2025
/*/
Static Function OA538021J_SetaODadoDoItem(oBulk, aNewDado)
    if (valtype(aNewDado) == "A") .and. len(aNewDado) > 0
        oBulk:addData(aNewDado[1])
    endif
Return


/*/{Protheus.doc} OA538022J_ValidaSelecaoDeArquivosPergunte
    Valida a seleção dos arquivos
	@type Function
	@author Renan Migliaris
	@since 17/10/2025
/*/
Function OA538022J_ValidPerg()

	Local lRet 		:= .T.

    if ReadVar() == 'MV_PAR07' .and. MV_PAR06 == 2
        MV_PAR07 := cGetFile(STR0030, STR0031, , "SERVIDOR", .T., GETF_RETDIRECTORY, .T., .T. ) //"Diretório" //"Glass-Scania"

        if !ExistDir(MV_PAR07) .or. Empty(MV_PAR07)
            lRet := .F.            
        endif
    endif

Return lRet

/*/{Protheus.doc} schedDef
    Função padrão scheduler
    @type  Static Function
    @author Renan Migliaris
    @since 22/08/2025
/*/
Static Function schedDef()
    local aParam := {;
        "P",;
        "OFIA538",;
        "",;
        "",;
        "";
    }
Return aParam