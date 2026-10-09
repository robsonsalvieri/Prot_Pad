#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIDISTRIB.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static cStFonte     := "RMIDISTRIB"             //Constante para o nome do log
Static oStFilPro    := nil                      //Objeto tHashMap para armazenar as filiais dos processos e evitar consultas repetidas
Static cStProcesso  := ""                       //Constante com o processo que esta distribuindo
Static cStFilMhr    := ""                       //Constante com o processo que esta distribuindo

Static oStBulk      := nil                      //Objeto fwBulk
Static nStTamBulk   := 1000                     //Tamanho do commit no Bulk
Static nStTamQry    := 10000                    //Tamanho de retorno da query

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistrib
Serviços que gera as Distribuições

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistrib(cEmpAmb, cFilAmb, cTempoMax, cTipo, cFiltro)

	Local lManual       := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua     := .T.
    Local cSelect       := ""
    Local cTabela       := ""
    Local cHoraInicio   := time()
    Local cSemaforo     := ""
    Local lGrupo        := .F.
    Local aProcGrupo    := {}
    Local nPos          := 0
	
    Default cEmpAmb     := ""
	Default cFilAmb     := ""
    Default cTempoMax   := "00:05:00"
    Default cTipo       := "1"          //1=Processo, 2=Grupo
    Default cFiltro     := ""           //Código do processo ou grupo

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.
            
            //Alterado para RPCSetType(3) para não consumir licença
            RpcSetType(3)
			RpcSetEnv(cEmpAmb, cFilAmb, , , "LOJA", "RMIDISTRIB")
		Else
            LjGrvLog(" RmiDistrib ",I18N(STR0001, {"RmiDistrib"}) )//"Parâmetros incorretos no serviço #1."
		EndIf	
	EndIf

    //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)
    //Quando o filtro for passado não faz esta verificação porque deve haver mais de 1 job de ditribuição configurado, um para cada processo ou grupo.
    If empty(cFiltro) .and. existFunc("pshChkJob")
        lContinua := PSHChkJob()
    EndIf

	If lContinua

        LjGrvLog("RMIDISTRIB", "Ambiente iniciado:", {cEmpAmb, cFilAmb, cTempoMax, cModulo, cTipo, cFiltro})
	
		//Trava a execução para evitar que mais de uma sessão faça a execução.
        cSemaforo := "RMIDISTRIB" +"_"+ cEmpAmb +"_"+ cTipo +"_"+ cFiltro
        If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            ljxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
            rpcClearEnv()
            Return Nil
		EndIf

        lGrupo := cTipo == "2" .and. MHN->( columnPos("MHN_CODGRP") ) > 0

        //Thread é encerrada quando, estiver sendo executada a mais tempo que o tempo maximo
        while elapTime(cHoraInicio, time()) <= cTempoMax

            aProcGrupo := {}

            //Seleciona os processos assinados e já publicados
            cTabela := GetNextAlias()
            cSelect := " SELECT MHP_CPROCE"
            cSelect += IIF(lGrupo, ", MHN_CODGRP", "")

            cSelect += " FROM " + retSqlName("MHP") + " MHP"
            
            //Filtro processo por grupo
            if lGrupo
                cSelect +=  " INNER JOIN " + retSqlName("MHN") + " MHN"
                cSelect +=       " ON MHP_CPROCE = MHN_COD AND MHN.D_E_L_E_T_ = ' '"
                if !empty(cFiltro)
                    cSelect +=      " AND MHN_CODGRP IN " + formatIn(cFiltro, ",")
                endIf
            endIf
            
            cSelect +=      " INNER JOIN " + retSqlName("MHQ") + " MHQ"
            cSelect +=          " ON MHQ_FILIAL = '" + xFilial("MHQ") + "' AND MHP_CPROCE = MHQ_CPROCE AND MHQ_STATUS = '1' AND MHQ.D_E_L_E_T_ = ' '"
            cSelect += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "'"
            cSelect +=      " AND MHP_ATIVO = '1'"      //1=Sim
            cSelect +=      " AND MHP_TIPO = '1'"       //1=Envia
            cSelect +=      " AND MHP.D_E_L_E_T_ = ' '"

            //Filtro processo
            if cTipo == "1" .and. !empty(cFiltro)
                cSelect +=  " AND MHP_CPROCE IN " + formatIn(cFiltro, ",")
            endIf

            cSelect += " GROUP BY MHP_CPROCE"
            cSelect += IIF(lGrupo, ", MHN_CODGRP", "")
            
            LjGrvLog(" RmiDistrib ", "Query que seleciona os registros para a distribuição:", cSelect)    
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

            While !(cTabela)->( Eof() )

                //Carrega processos por grupo
                if lGrupo

                    if ( nPos := aScan(aProcGrupo, {|x| x[1] == (cTabela)->MHN_CODGRP}) ) == 0
                        aAdd(aProcGrupo, {(cTabela)->MHN_CODGRP, {}} )
                        nPos := len(aProcGrupo)
                    endIf

                    aAdd(aProcGrupo[nPos][2], (cTabela)->MHP_CPROCE)

                else

                    StartJob("RmiDistSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, (cTabela)->MHP_CPROCE)
                    Sleep(1000)
                endIf
                
                (cTabela)->( DbSkip() )
            EndDo
            (cTabela)->( DbCloseArea() )

            //Distribuição por grupo, abre uma thread por grupo
            if lGrupo
                for nPos:=1 to len(aProcGrupo)
                    startJob("pshDistGrp", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aProcGrupo[nPos])
                    sleep(1000)
                next nPos
            endIf

            fwFreeArray(aProcGrupo)
                        
            sleep(5000)
        endDo

        //Libera a execução do login
        UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
	EndIf

    rpcClearEnv()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistSel
Seleciona os registros que serão distribuidos

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistSel(cEmpDist, cFilDist, cProcesso)

    Local cSemaforo  := "RMIDISTSEL" +"_"+ cEmpDist +"_"+ AllTrim(cProcesso)
    Local cSelect    := ""
    Local cTabela    := "" 
    Local aAssinante := {}
    Local nAssi      := 0
    Local cFilPub    := ""
    Local lContinua  := .T.
    Local cOrigem    := ""
    Local cAssinante := ""
    Local nCont      := 0
    Local cUuids     := ""

    if !empty(cFilDist)
    
        RpcSetType(3)
        RpcSetEnv(cEmpDist, cFilDist, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "RmiDistSel")
    endIf

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        rpcClearEnv()
        Return Nil
    EndIf

    ljxjMsgErr("Distribui" + " - " + cSemaforo + " - " + time() + " - " + cValTochar( ThreadId() ), /*cSolucao*/, /*cRotina*/, {cEmpAnt, cFilAnt})

    //Carrega staticas
    oStFilPro   := tHashMap():New()
    cStProcesso := cProcesso
    cStFilMhr   := xFilial("MHR")

    //Inicia gravação do fwBulk
    iniciaBulk()

    //Carrega Assinantes do Processo
    aAssinante := RmiXSql(  " SELECT MHP_CASSIN"            +;
                            " FROM " + RetSqlName("MHP")    +;
                            " WHERE MHP_FILIAL = '" + xFilial("MHP") + "' AND MHP_CPROCE = '" + cStProcesso +  "' AND MHP_ATIVO = '1' AND MHP_TIPO = '1' AND D_E_L_E_T_ = ' '", "*", /*lCommit*/, /*aReplace*/)
    LjGrvLog(" RmiDistrib ", "Carrega Assinantes do Processo",{aAssinante})

    cSelect := " SELECT R_E_C_N_O_ AS REGISTRO, MHQ_ORIGEM, MHQ_IDEXT, MHQ_UUID"
    cSelect += " FROM " + RetSqlName("MHQ")
    cSelect += " WHERE MHQ_FILIAL = '" + xFilial("MHQ") + "' AND MHQ_CPROCE = '" + cStProcesso + "' AND MHQ_STATUS = '1' AND D_E_L_E_T_ = ' ' "
    cSelect += " ORDER BY R_E_C_N_O_"
    cSelect += " OFFSET 0 ROWS"
    cSelect += " FETCH NEXT " + cValToChar(nStTamQry) + " ROWS ONLY"

    //Executa enquanto encontrar registros para distribuir
    while lContinua

        //Seleciona as publicações de um determinado processo, para serem distribuidas
        cTabela := mpSysOpenQuery(cSelect, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)
        LjGrvLog("RmiDistrib", "Seleciona as publicações de um determinado processo, para serem distribuidas", {cSelect, cTabela})

        if ( lContinua := !(cTabela)->( Eof() ) )

            While !(cTabela)->( Eof() )

                For nAssi := 1 To Len(aAssinante)

                    cFilPub     := allTrim( (cTabela)->MHQ_IDEXT  )
                    cOrigem     := allTrim( (cTabela)->MHQ_ORIGEM )
                    cAssinante  := allTrim( aAssinante[nAssi][1]  )
                    nRecnoPub   := (cTabela)->REGISTRO
                    cUuidPub    := (cTabela)->MHQ_UUID
                    
                    //Valida se vai distribuir
                    if !distribui(cOrigem, cAssinante, cFilPub, nRecnoPub)
                        loop
                    endIf

                    //Carrega distribuições no fwBulk                     
                    carregaBulk(cAssinante, nRecnoPub, cUuidPub)                    
                    nCont++
                    
                Next nAssi

                //Concatena os UUIDs para depois deletar os registros da MHQ e evitar erro de chave duplicada no fwBulk
                cUuids      += "'" + cUuidPub + "',"   

                if nCont >= nStTamBulk                        
                    //Grava distribuições
                    gravaBulk(cUuids)

                    nCont   := 0
                    cUuids  := ""
                endIf

                (cTabela)->( dbSkip() )
            EndDo

            //Grava distribuições
            gravaBulk(cUuids)
        endIf

        (cTabela)->( dbCloseArea() )
    endDo

    //Finaliza gravação do fwBulk
    finalizaBulk()

    fwFreeObj(oStFilPro)

    fwFreeArray(aAssinante)

    //Libera a execução do login
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)    

    if !empty(cFilDist)
        rpcClearEnv()
    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} carregaBulk
Carrega fwBulk para grava distribuições

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
function carregaBulk(cAssinante, nRecnoPub, cUuidPub)
    
    //O array de extrutura (aStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
    IIf(!oStBulk:addData({cStFilMhr   ,;  //MHR_FILIAL
                        cStProcesso ,;  //MHR_CPROCE
                        cAssinante  ,;  //MHR_CASSIN
                        nRecnoPub   ,;  //MHR_RECPUB
                        "0"         ,;  //MHR_TENTAT
                        "1"         ,;  //MHR_STATUS
                        cUuidPub    }),;  //MHR_UIDMHQ
        ljxjMsgErr("carregaBulk - Erro ao adicionar registro no fwBulk. - "+cUuidPub +" Erro :" +oStBulk:GetError(), /*Solucao*/, procName(1)),;        
    .T.)

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função utilizada por rotina colocadas no Schedule

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local aParam  := {}

    aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
                "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
                /*Alias*/           ,;	
                /*Array de ordens*/ ,;
                /*Titulo*/          }

Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} pshDistGrp
Gera a distribuição dos processos de um determinado grupo

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshDistGrp(cEmpAmb, cFilAmb, aProcGrupo)

    Local cSemaforo := "pshDistGrp" +"_"+ cEmpAmb +"_"+ aProcGrupo[1]
    Local nCont     := 1
    
    rpcSetType(3)
    rpcSetEnv(cEmpAmb, cFilAmb, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "pshDistGrp")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        rpcClearEnv()
        Return Nil
    EndIf    

    for nCont:=1 to len(aProcGrupo[2])
        rmiDistSel(cEmpAnt, "", aProcGrupo[2][nCont])
    next nCont

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    fwFreeArray(aProcGrupo)
    rpcClearEnv()

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} distribui
Efetua as validações para distribuição de uma publicação.

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
static Function distribui(cOrigem, cAssinante, cFilPub, nRecnoPub)

    Local lRetorno  := .T.
    Local cChave    := ""
    Local aFilPro   := nil

    //Não distribui publicação onde o PROTHEUS não esteja envolvido
    if (cOrigem == cAssinante) .or. (cOrigem <> "PROTHEUS" .and. cAssinante <> "PROTHEUS")
        ljGrvLog(cStFonte, i18n("Publicação de origem #1 não será distribuida para o assinante #2: ", {cOrigem, cAssinante}), {cFilPub, cStProcesso, nRecnoPub})
        lRetorno := .F.
    EndIf    

    //Avalia a filial do regisro publicado pelo PROTHEUS para distribuir
    If lRetorno .and. cOrigem == "PROTHEUS" .And. !Empty(cFilPub)

        cChave := cAssinante + cStProcesso
        if !oStFilPro:get(cChave, @aFilPro)
            aFilPro := rmixFilial(cAssinante, cStProcesso)
            oStFilPro:set(cChave, aClone(aFilPro))
        endIf
                                    
        if aScan(aFilPro, {|x| SubStr(x, 1, Len(cFilPub)) == cFilPub}) == 0
            ljGrvLog(cStFonte, "Publicação não distribuida, filial do registro não foi configurada na integração.", {cFilPub, cStProcesso, nRecnoPub, cAssinante})
            lRetorno := .F.
        endIf

        aFilPro := nil
        fwFreeArray(aFilPro)
    endIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} iniciaBulk
Inicia a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function iniciaBulk()

    Local aStrBulk := {}

    //O array de extrutura (aStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
    aAdd( aStrBulk, {"MHR_FILIAL" })
    aAdd( aStrBulk, {"MHR_CPROCE" })
    aAdd( aStrBulk, {"MHR_CASSIN" })
    aAdd( aStrBulk, {"MHR_RECPUB" })
    aAdd( aStrBulk, {"MHR_TENTAT" })
    aAdd( aStrBulk, {"MHR_STATUS" })
    aAdd( aStrBulk, {"MHR_UIDMHQ" })

    oStBulk := fwBulk():New(retSqlName("MHR"), nStTamBulk + 50)
    oStBulk:setFields(aStrBulk)

    fwFreeArray(aStrBulk)

    ljGrvLog(cStFonte, "Iniciada inclusão de registros por fwBulk.")

return nil

//TENORIO
//-------------------------------------------------------------------
/*/{Protheus.doc} gravaBulk
Efetua a gravação das distribuições(MHR) utilizando fwBulk, e atualiza MHQ.

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function gravaBulk(cUuids)

    if oStBulk:count() > 0

        cUuids := subStr(cUuids, 1, len(cUuids)-1)  //Tira a última vírgula

        Begin Transaction

            //Deleta MHR com os UUIDs para não gerar erro no fwBulk de chave duplicada
            //Utiliza indice 4- MHR_FILIAL, MHR_UIDMHQ, MHR_CPROCE, MHR_CASSIN, R_E_C_N_O_, D_E_L_E_T_
            cSql := " DELETE FROM " + retSqlName("MHR") 
            cSql += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
            cSql += " AND MHR_UIDMHQ IN (" + cUuids + ")"
            cSql += " AND MHR_CPROCE = '" + cStProcesso + "'"

            ljGrvLog(cStFonte, "Executa delete na MHR com os UUIDs para não gerar erro no fwBulk de chave duplicada.", cSql)
            tcSqlExec(cSql)

            ljGrvLog(cStFonte, "Executa flush no fwBulk para gravar os registros de distribuição.")            
            iIf( !oStBulk:flush() , ljxjMsgErr("GravaBulk - Erro ao gravar distribuições por fwBulk."+oStBulk:GetError(), /*Solucao*/) ,.T.)
                    
            //Atualiza status da MHQ para processada
            //Utiliza indice 9- MHQ_FILIAL, MHQ_CPROCE, MHQ_UUID, MHQ_EVENTO, MHQ_CHVUNI, R_E_C_N_O_, D_E_L_E_T_
            cSql := " UPDATE " + retSqlName("MHQ") 
            cSql += " SET MHQ_STATUS = '2', MHQ_DATPRO = '" + dToS( date() ) + "', MHQ_HORPRO = '" + time() + "'"
            cSql += " WHERE MHQ_FILIAL = '" + xFilial("MHQ") + "'"
            cSql += " AND MHQ_CPROCE = '" + cStProcesso + "'"
            cSql += " AND MHQ_UUID IN (" + cUuids + ")"
            cSql += " AND D_E_L_E_T_ = ' '"

            ljGrvLog(cStFonte, "Executa update na MHQ para atualizar o status dos registros que geraram distribuição.", cSql)
            tcSqlExec(cSql)

        End Transaction
    endIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} finalizaBulk
Finaliza a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function finalizaBulk()

    oStBulk:close()
    oStBulk:destroy()

    fwFreeObj(oStBulk)
    
    ljGrvLog(cStFonte, "Finalizada inclusão de registros por fwBulk.")

return nil
