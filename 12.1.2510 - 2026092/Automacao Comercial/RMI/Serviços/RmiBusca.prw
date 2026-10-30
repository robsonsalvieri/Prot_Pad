#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIBUSCA.CH"
#INCLUDE 'FWLIBVERSION.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiBusca
Serviço que busca informações nos Assinantes

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiBusca(cEmpAmb, cFilAmb)

	Local lManual       := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua     := .T.
	Local cSelect       := ""
    Local cTabela       := ""
    Local lReprocessa   := .F.
    Local cTime         := ""
	
    Default cEmpAmb := ""
	Default cFilAmb := ""

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.

			//Alterado para RPCSetType(3) para não consumir licença, até identificar qual assinante deve consumir licença.
            RpcSetType(3)
			RpcSetEnv(cEmpAmb, cFilAmb, , ,'LOJA', "RMIBUSCA")
            LjGrvLog(" RmiBusca ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})    
		Else
            LjGrvLog(" RmiBusca ", I18n(STR0001, {"RMIBUSCA"}))
		EndIf
	EndIf

    //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)
    If existFunc("pshChkJob")
        lContinua := PSHChkJob()
    EndIf

	If lContinua
	        
        //Trava a execução para evitar que mais de uma sessão faça a execução.
        If !LockByName("RMIBUSCA", .T./*lEmpresa*/, .F./*lFilial*/)
            LjGrvLog(" RmiBusca ", I18n(STR0002, {"RMIBUSCA"}))
            Return Nil
        EndIf 

        //Seleciona os assinantes com a busca ativa
        cTabela := GetNextAlias()
        cSelect := " SELECT MHO_COD"
        cSelect += " FROM " + RetSqlName("MHO") + " MHO INNER JOIN " + RetSqlName("MHP") + " MHP"
        cSelect +=      " ON MHO_FILIAL = MHP_FILIAL AND MHO_COD = MHP_CASSIN AND MHP_ATIVO = '1' AND MHP_TIPO = '2' AND MHO.D_E_L_E_T_ = MHP.D_E_L_E_T_"   //1=Ativo, 2=Busca
        cSelect += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "' AND MHO.D_E_L_E_T_ = ' '"
        cSelect += " GROUP BY MHO_COD"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

        While !(cTabela)->( Eof() )
            If ALLTRIM(MHO_COD) == "CHEF"
                lReprocessa := .T.
            EndIf
	        StartJob("RmiBusExec", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHO_COD), /*cReprocessa*/, /*cProcesso*/)
            Sleep(2000)            
            StartJob("PshProcBus", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHO_COD), /*cReprocessa*/, /*cProcesso*/)
            (cTabela)->( DbSkip() )
        EndDo
        (cTabela)->( DbCloseArea() )

        //Processamento do expurgo
        cTime := time()
        if cTime > "00:00:00" .and. cTime < "06:00:00"
	        startJob("totvs.protheus.retail.rmi.monitoramento.expurgo.controle.processa", getEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt)
        endIf

        //Libera a execução do login
        UnLockByName("RMIBUSCA", .T./*lEmpresa*/, .F./*lFilial*/)
	EndIf
    
    //Chama a funcao para o reprocessamento
    If lContinua .AND. ExistFunc("RmiReprocessa") .AND. lReprocessa
        RmiReprocessa("CHEF")
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiBusExec
Executa a busca

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiBusExec(cEmpEnv, cFilEnv, cAssinante, cReprocessa, cProcesso)

    Local cSemaforo := ""
    Local oBusca    := Nil
    Local lContinua := .T.
    
    Default cReprocessa := ""
    DEFAULT cProcesso   := ""

    cSemaforo := "RMIBUSEXEC" +"_"+ cEmpEnv +"_"+ cAssinante +"_"+ cProcesso + IIF(Empty(cReprocessa), "", "_" + cReprocessa)

    If cAssinante <> "TERCEIROS"
        RpcSetType(3)        
    EndIF
  
    RpcSetEnv(cEmpEnv, cFilEnv, , , "LOJA", "RmiBusca")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T., .T.)
        LjGrvLog(" RmiBusca ", I18n(STR0002, {cSemaforo}))//"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    cAssinante := AllTrim(cAssinante)

    Do Case

        Case cAssinante == "CHEF"
            oBusca := RmiBusChefObj():New()

        Case cAssinante == "LIVE"
            oBusca := RmiBusLiveObj():New()

        Case cAssinante == "PDVSYNC"
            oBusca := RmiBusPdvSyncObj():New()

        Case cAssinante == "TERCEIROS"
            oBusca := RmiBusTerceirosObj():New()
        
        Case "VENDA DIGITAL" $ cAssinante 
            oBusca := RmiBusVenDigObj():New(cAssinante)        
            
        Case "SIGAGPC" $ cAssinante 
            oBusca := RmiBusSigaGpcObj():New()

        OTherWise
            LjGrvLog("RmiBusca", I18n(STR0003, {cAssinante}))   //"Assinante #1 sem busca implementada."
            lContinua := .F.
    End Case

    //Busca os processos integrados
    If lContinua 
        oBusca:Processa()
    EndIf

    FwFreeObj(oBusca)
    //Libera a execução do login
	UnLockByName(cSemaforo, .T., .T.)

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
/*/{Protheus.doc} PshProcBus
Executa o processamento dos itens da busca

@author  Everson P.
@version 1.0
/*/
//-------------------------------------------------------------------
Function PshProcBus(cEmpEnv, cFilEnv, cAssinante, cReprocessa, cProcesso)

    Local cSemaforo := ""
    Local oGrvMsg   := Nil //Instância da classe RmiGrvMsgPubChefObj

    Default cReprocessa := ""
    Default cProcesso   := ""

    cSemaforo := "PshProcBus" +"_"+ cEmpEnv +"_"+ cAssinante +"_"+ cProcesso + IIF(Empty(cReprocessa), "", "_" + cReprocessa)

    If cAssinante <> "TERCEIROS"
        RpcSetType(3)        
    EndIF
  
    RpcSetEnv(cEmpEnv, cFilEnv, , , "LOJA", "RmiBusca")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T., .T.)
        LjGrvLog(" RmiBusca ", I18n(STR0002, {cSemaforo}))//"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    cAssinante := AllTrim(cAssinante)

    //Efetua geração da mensagem de publicação MHQ_MENSAG
    Do Case

        Case cAssinante == "CHEF"        
            oGrvMsg := RmiGrvMsgPubChefObj():New()
            oGrvMsg:GeraMsg(cAssinante)

        Case cAssinante == "LIVE"
            oGrvMsg := RmiGrvMsgPubLiveObj():New()
            oGrvMsg:GeraMsg(cAssinante)

        Case cAssinante == "PDVSYNC"
            oGrvMsg := RmiGrvMsgPubPdvSyncObj():New()
            oGrvMsg:GeraMsg()
			
        Case "VENDA DIGITAL" $ cAssinante
            oGrvMsg := RmiGrvMsgPubVenDig():New(cAssinante)
            oGrvMsg:GeraMsg()

        Case cAssinante == "TERCEIROS"
            oGrvMsg := RmiGrvMsgPubTerceirosObj():New()
            oGrvMsg:GeraMsg()
            
        OTherWise
            LjxjMsgErr( I18n("Assinante #1 sem gravação de mensagem implementada.", {cAssinante}), /*cSolucao*/, /*cRotina*/ )
    End Case
    
    //Limpa o objeto
    FwFreeObj(oGrvMsg)

    //Libera a execução do login
	UnLockByName(cSemaforo, .T., .T.)

Return Nil
