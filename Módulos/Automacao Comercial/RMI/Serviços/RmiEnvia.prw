#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVIA.CH"
#INCLUDE 'FWLIBVERSION.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiEnvia
Serviços que ira enviar as distribuições para os destinos

@author  Rafael Tenorio da Costa
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiEnvia(cEmpAmb, cFilAmb, cTempoMax, cTipo, cFiltro)

    Local lManual       := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua     := .T.
    Local cSelect       := ""
    Local cTabela       := ""
    Local cHoraInicio   := time()
    Local cSemaforo     := ""
    Local lGrupo        := .F.
    Local aProcGrupo    := {}
    Local nPos          := 0
    Local lDetDistrib   := .F.
	
    Default cEmpAmb     := ""
	Default cFilAmb     := ""
    Default cTempoMax   := "00:05:00"    
    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.

			//Normalmente utiliza-se RPCSetType(3) para informar ao Server que a RPC não consumirá licenças
            RpcSetType(3) // Para não consumir licenças nas Threads
			RpcSetEnv(cEmpAmb, cFilAmb, , ,"LOJA", "RMIENVIA")
		Else
            LjGrvLog(" RMIENVIA ",I18N(STR0001, {"RMIENVIA"}) )//"Parâmetros incorretos no serviço #1."
		EndIf
	EndIf

    //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)
    //Quando o filtro for passado não faz esta verificação porque deve haver mais de 1 job de envio configurado, um para cada processo ou grupo.
    If empty(cFiltro) .and. existFunc("pshChkJob")
        lContinua := PSHChkJob()
    EndIf

	If lContinua

        LjGrvLog("RMIENVIA", "Ambiente iniciado:", {cEmpAmb, cFilAmb, cTempoMax, cModulo, cTipo, cFiltro})
        
        lDetDistrib := FwAliasInDic("MIP") .And. ExistFunc("RmiStDist")
		
        //Trava a execução para evitar que mais de uma sessão faça a execução.
        cSemaforo := "RMIENVIA" +"_"+ cTipo +"_"+ cFiltro
        If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            ljxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
            rpcClearEnv()
            Return Nil
		EndIf

        lGrupo := cTipo == "2" .and. MHN->( columnPos("MHN_CODGRP") ) > 0

        //Thread é encerrada quando, estiver sendo executada a mais tempo que o tempo maximo
        while elapTime(cHoraInicio, time()) <= cTempoMax

            aProcGrupo := {}

            //Seleciona os processos ativos com envios pendentes
            cTabela := GetNextAlias()
            cSelect := " SELECT MHP_CASSIN, MHP_CPROCE"
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

            cSelect +=      " INNER JOIN " + retSqlName("MHR") + " MHR"
            cSelect +=           " ON MHR_FILIAL = '" + xFilial("MHR") + "' AND MHP_CPROCE = MHR_CPROCE AND MHP_CASSIN = MHR_CASSIN AND MHR.D_E_L_E_T_ = ' '"   //1=Pendente envio
            cSelect +=      " INNER JOIN " + retSqlName("MHQ") + " MHQ"
            cSelect +=           " ON MHR_UIDMHQ = MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"
            cSelect += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "'"
            cSelect +=      " AND MHP.D_E_L_E_T_ = ' '"
            cSelect +=      " AND MHP_ATIVO = '1'"  //1=Ativo
            cSelect +=      " AND MHP_TIPO = '1'"   //1=Envia
            cSelect +=      " AND ( MHR_STATUS IN ('1','6')"
            cSelect +=          " OR ( MHR_STATUS = '3' AND MHR_DATPRO >= '" + DTOS(DATE()-7) + "' )"
            
            If lDetDistrib
                cSelect +=      " OR EXISTS( SELECT '' FROM " + retSqlName("MIP") + " MIP WHERE MIP.D_E_L_E_T_ = ' ' AND MHR_UIDMHQ = MIP_UIDORI AND ((MIP_STATUS = '3' AND MIP_DATPRO >= '" + DTOS(DATE()-7) + "') OR MIP_STATUS = '6') )"
            EndIf
            
            cSelect +=      " ) "
            //Filtro processo
            if cTipo == "1" .and. !empty(cFiltro)
                cSelect +=  " AND MHP_CPROCE IN " + formatIn(cFiltro, ",")
            endIf

            cSelect += " GROUP BY MHP_CASSIN, MHP_CPROCE"
            cSelect += IIF(lGrupo, ", MHN_CODGRP", "")
            
            LjGrvLog(" RMIENVIA ", "Query que seleciona os processos ativos com envios pendentes:", cSelect)
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
            
            While !(cTabela)->( Eof() )

                //Carrega processos por grupo
                if lGrupo

                    if ( nPos := aScan(aProcGrupo, {|x| x[1] == (cTabela)->MHN_CODGRP}) ) == 0
                        aAdd(aProcGrupo, {(cTabela)->MHN_CODGRP, {}} )
                        nPos := len(aProcGrupo)
                    endIf

                    aAdd(aProcGrupo[nPos][2], { allTrim((cTabela)->MHP_CASSIN), allTrim((cTabela)->MHP_CPROCE) } )

                else

                    StartJob("RmiEnvExec", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHP_CASSIN), AllTrim((cTabela)->MHP_CPROCE))
                    Sleep(1000)
                endIf

                (cTabela)->( DbSkip() )
            EndDo
            (cTabela)->( DbCloseArea() )

            //Envio por grupo, abre uma thread por grupo
            if lGrupo
                for nPos:=1 to len(aProcGrupo)
                    startJob("pshEnvGrp", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aProcGrupo[nPos])
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
/*/{Protheus.doc} RmiEnvExec
Executa o envio

@author  Rafael Tenorio da Costa
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiEnvExec(cEmpEnv, cFilEnv, cAssinante, cProcesso)

    Local cSemaforo := "RMIENVEXEC" +"_"+ cEmpEnv +"_"+ cAssinante +"_"+ cProcesso
    Local oEnvio    := Nil
    Local lContinua := .T.

    if !empty(cFilEnv)

        If cAssinante <> "TERCEIROS"
            RpcSetType(3)        
        EndIF
    
        RpcSetEnv(cEmpEnv, cFilEnv, , ,"LOJA", "RmiEnvExec")
    endIf

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        rpcClearEnv()
        Return Nil
    EndIf

    ljxjMsgErr("Envia" + " - " + cSemaforo + " - " + time() + " - " + cValTochar( ThreadId() ), /*cSolucao*/, /*cRotina*/, {cEmpAnt, cFilAnt})

    cAssinante := AllTrim(cAssinante)

    Do Case

        Case cAssinante == "CHEF"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a CHEF cria objeto-> oEnvio : ")
            oEnvio := RmiEnvChefObj():New(cProcesso)

        Case cAssinante == "LIVE"

            If FindFunction("RMISTAEXE")
                LjGrvLog(" RMIENVIA ", "Vai executar (RMISTAEXE) para todos os processos.")
                StartJob("RMISTAEXE", GetEnvServer(), .F./*Não lEspera*/, cEmpAnt, cFilAnt, /*cProcesso*/)
                Sleep(1000)
            EndIf

            LjGrvLog(" RmiEnvExec ", "Assinante igual a LIVE cria objeto-> oEnvio : ")
            oEnvio := RmiEnvLiveObj():New(cProcesso)//Passado para Metod New RmiEnvLiveObj iniciar o processo para Live

        Case cAssinante == "PROTHEUS"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a PROTHEUS cria objeto-> oEnvio : ")
            oEnvio := RmiEnvProtheusObj():New(cProcesso)
        
        Case cAssinante == "PDVSYNC"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a PDVSYNC cria objeto-> oEnvio : ")
            oEnvio := RmiEnvPdvSyncObj():New(cProcesso)

        Case "VENDA DIGITAL" $ cAssinante
            LjGrvLog(" RmiEnvExec ", "Assinante igual a VENDA DIGITAL cria objeto-> oEnvio : ")
            oEnvio := RmiEnvVendaDigitalObj():New(cProcesso,cAssinante)

        Case cAssinante == "MOTOR PROMOCOES"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a MOTOR PROMOCOES cria objeto-> oEnvio : ")
            oEnvio := RmiEnvMotorObj():New(cProcesso)
            
        Case cAssinante == "TOTVS PDV"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a TOTVS PDV cria objeto-> oEnvio : ")
            oEnvio := RmiEnvTotvsPdv():New(cProcesso,cAssinante)

        Case "NAPP" $ cAssinante
            LjGrvLog(" RmiEnvExec ", "Assinante igual a NAPP cria objeto-> oEnvio : ")
            oEnvio := RmiEnvNappObj():New(cProcesso, cAssinante)

        OTherWise
            LjGrvLog(" RmiEnvExec ", I18n(STR0003, {cAssinante}))//"Assinante #1 sem envio implementado."
            lContinua := .F.

    End Case

    //Envia as distribuições ao assinante
    If lContinua 
    
        If oEnvio:GetSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .T. e vai executar a rotina oEnvio:Processa() ")
            oEnvio:Processa()
        EndIf

        //Gera log de erro
        If !oEnvio:getSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .F. e Vai recuperar o erro ")
            oEnvio:getRetorno()
            LjGrvLog(" RmiEnvExec ",oEnvio:getRetorno())
        EndIf
    EndIf


    fwFreeObj(oEnvio)

    //Libera a execução do login
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    if !empty(cFilEnv)
        rpcClearEnv()
    endIf

Return Nil

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
/*/{Protheus.doc} pshEnvGrp
Efetua o envio dos processos de um determinado grupo

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshEnvGrp(cEmpAmb, cFilAmb, aProcGrupo)

    Local cSemaforo := "pshEnvGrp" +"_"+ cEmpAmb +"_"+ aProcGrupo[1]
    Local nCont     := 1
    
    rpcSetType(3)
    rpcSetEnv(cEmpAmb, cFilAmb, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "pshEnvGrp")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        rpcClearEnv()
        Return Nil
    EndIf

    for nCont:=1 to len(aProcGrupo[2])
        rmiEnvExec(cEmpAnt, "", aProcGrupo[2][nCont][1], aProcGrupo[2][nCont][2])
    next nCont

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    fwFreeArray(aProcGrupo)
    rpcClearEnv()

return nil
