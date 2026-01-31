#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIDISTRIB.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static lStRmixFil   := existFunc("rmixFilial")                  //Verifica se existe a função que vai retornar as filiais
Static cStCmpQrFi   := iif( lStRmixFil, "", ", MHP_FILPRO" )    //Campo de filial utilizado nas querys

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
    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo

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
    Local aFilPro    := {}
    Local lContinua  := .T.
    Local cOrigem    := ""
    Local cAssinante := ""

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

    //Carrega Assinantes do Processo
    aAssinante := RmiXSql(  " SELECT MHP_CASSIN" + cStCmpQrFi   +;
                            " FROM " + RetSqlName("MHP")        +;
                            " WHERE MHP_FILIAL = '" + xFilial("MHP") + "' AND MHP_CPROCE = '" + cProcesso +  "' AND MHP_ATIVO = '1' AND MHP_TIPO = '1' AND D_E_L_E_T_ = ' '", "*", /*lCommit*/, /*aReplace*/)
    LjGrvLog(" RmiDistrib ", "Carrega Assinantes do Processo",{aAssinante})

    //Executa enquanto encontrar registros para distribuir
    while lContinua

        //Seleciona as publicações de um determinado processo, para serem distribuidas
        cTabela := GetNextAlias()
        cSelect := " SELECT R_E_C_N_O_ AS REGISTRO, MHQ_ORIGEM, MHQ_IDEXT"
        cSelect += " FROM " + RetSqlName("MHQ") 
        cSelect += " WHERE MHQ_FILIAL = '" + xFilial("MHQ") + "' AND MHQ_CPROCE = '" + cProcesso + "' AND MHQ_STATUS = '1' AND D_E_L_E_T_ = ' '"
        
        LjGrvLog(" RmiDistrib ", "Seleciona as publicações de um determinado processo, para serem distribuidas",{cSelect})
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

        lContinua := !(cTabela)->( Eof() )

        While !(cTabela)->( Eof() )

            Begin Transaction

                For nAssi := 1 To Len(aAssinante)

                    cFilPub     := allTrim( (cTabela)->MHQ_IDEXT  )
                    cOrigem     := allTrim( (cTabela)->MHQ_ORIGEM )
                    cAssinante  := allTrim( aAssinante[nAssi][1]  )

                    //Não distribui publicação onde o PROTHEUS não esteja envolvido
                    If (cOrigem <> "PROTHEUS" .and. cAssinante <> "PROTHEUS") .or. (cOrigem == cAssinante)

                        LjGrvLog(" RmiDistrib ", i18n("Publicação de origem #1 não será distribuida para o assinante #2: ", {cOrigem, cAssinante}), {cFilPub, cProcesso, (cTabela)->REGISTRO})
                        Loop
                    EndIf

                    //Avalia a filial do regisro publicado pelo PROTHEUS para distribuir
                    If cOrigem == "PROTHEUS" .And. !Empty(cFilPub)

                        aFilPro := iif( lStRmixFil, rmixFilial(cAssinante, cProcesso), StrTokArr( AllTrim(aAssinante[nAssi][2]), ";" ) )

                        If aScan(aFilPro, {|x| SubStr(x, 1, Len(cFilPub)) == cFilPub}) == 0
                            LjGrvLog(" RmiDistrib ", "Publicação do PROTHEUS não distribuida para o assinante, filial do registro não contemplada.", {cFilPub, cProcesso, (cTabela)->REGISTRO, aAssinante[nAssi]})
                            Loop
                        EndIf
                    EndIf

                    //Grava distribuição
                    RmiDistGrv(cAssinante, cProcesso, (cTabela)->REGISTRO)

                Next nAssi

            End Transaction

            (cTabela)->( DbSkip() )
        EndDo
        (cTabela)->( DbCloseArea() )

    endDo

    fwFreeArray(aAssinante)
    fwFreeArray(aFilPro)

    //Libera a execução do login
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)    

    if !empty(cFilDist)
        rpcClearEnv()
    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistGrv
Grava a distribuição na tabela MHR - Mensagens Distribuidas
Feito em Function para possibilitar a chamada de outros fontes.

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistGrv(cAssinante, cProcesso, nRecnoPub)

    Local aArea := GetArea()
    Local oError:= Nil
    Local cTipo := ""

    MHQ->( DbGoTo(nRecnoPub) )

    //Não distribui publicação onde a origem é igual ao destino
    TRY EXCEPTION
        If !MHQ->( Eof() ) .And. AllTrim(MHQ->MHQ_ORIGEM) <> AllTrim(cAssinante)
            //Gera distribuição
            RecLock("MHR", .T.)

                MHR->MHR_FILIAL := xFilial("MHR")
                MHR->MHR_CPROCE := cProcesso
                MHR->MHR_CASSIN := cAssinante
                MHR->MHR_RECPUB := nRecnoPub        //Antigo relacionamento entre Publicação x Distribuição, foi mantido para não dar erro na chave única.
                MHR->MHR_TENTAT := "0"
                MHR->MHR_STATUS := "1"              //1=A Processar;2=Processada;3=Erro
                MHR->MHR_UIDMHQ := MHQ->MHQ_UUID    //Id unico da MHQ para relacionamento com MHR.

            MHR->( MsUnLock() )
            
            //Atualiza publicação
            RecLock("MHQ", .F.)

                MHQ->MHQ_STATUS := "2"              //1=A Processar;2=Processada;3=Erro
                MHQ->MHQ_DATPRO := Date()
                MHQ->MHQ_HORPRO := Time()

            MHQ->( MsUnLock() )
        EndIf
    CATCH EXCEPTION USING oError
        
        If 'CHAVE DUPLICADA' $ UPPER(oError:Description) .OR. 'DUPLICATE KEY' $ UPPER(oError:Description)
            //Atualiza publicação
            cTipo := MHQ->MHQ_UUID
            LjGrvLog("RmiDistGrv", "RmiDistGrv -> Ocorreu erro ao atualizar MHR, Chave UUID ja existe.", oError:Description)
            
            RecLock("MHQ", .F.)
            MHQ->MHQ_STATUS := "1"              //1=A Processar;2=Processada;3=Erro
            MHQ->MHQ_DATPRO := Date()
            MHQ->MHQ_HORPRO := Time()
            MHQ->MHQ_UUID   := FwUUID("DISTRIB" + AllTrim(cProcesso))    //Gera nova chave unica
            MHQ->( MsUnLock() )
            //Log de Ratriamento
            LjGrvLog("RmiDistGrv", "atualizando Chave unica de: "+cTipo+" para -> "+MHQ->MHQ_UUID)
            
        Else
            //Atualiza publicação
            RecLock("MHQ", .F.)
            MHQ->MHQ_STATUS := "3"              //1=A Processar;2=Processada;3=Erro
            MHQ->MHQ_DATPRO := Date()
            MHQ->MHQ_HORPRO := Time()
            MHQ->( MsUnLock() )
            
            RMIGRVLOG(  "IR"          , "MHQ"           , MHQ->(Recno())    , "DISTRIB" ,;
                oError:Description ,                 ,                   ,               ,;
                .F.           , 1               , MHQ->MHQ_CHVUNI            , MHQ->MHQ_CPROCE,;
                MHQ->MHQ_ORIGEM, MHQ->MHQ_UUID )
        EndIf
        
    ENDTRY
    
    RestArea(aArea)
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
