#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMISTATUSLIVE.CH"

Static oJson     := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMISTATUS
Serviço que busca informações nos Assinantes

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISTATUS(cEmpAmb, cFilAmb)

	Local lManual   := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua := .T.
    
    Default cEmpAmb := ""
	Default cFilAmb := ""

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.

			RpcSetType(3) // Para nao consumir licenças na Threads
            RpcSetEnv(cEmpAmb, cFilAmb, , ,'LOJ', "RMISTATUS")
            LjGrvLog(" RMISTATUSLIVE ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})  
		Else
            LjGrvLog(" RMISTATUS ",I18N(STR0001, {"RMISTATUS"}) ) //"Parâmetros incorretos no serviço."
		EndIf	
	EndIf
	
	If lContinua
	
		//Trava a execução para evitar que mais de uma sessão faça a execução.
		If !LockByName("RMISTATUS", .T., .T.)
            LjGrvLog(" RMISTATUSLIVE ", I18n(STR0002, {"RMISTATUS"}))    //"Serviço #1 já esta sendo utilizado por outra instância."
			Return Nil
		EndIf

        LjGrvLog(" RMISTATUSLIVE ", "Antes da Chamada da Função RMISTAEXE")

        StartJob("RMISTAEXE", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt)

        Sleep(5000)
            
        //Libera a execução do login
        UnLockByName("RMISTATUS", .T., .T.)
	EndIf
    
    //Chama a funcao para o reprocessamento
    If lContinua .AND. ExistFunc("RmiReprocessa")
        RmiReprocessa("CHEF")
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMISTAEXE
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISTAEXE(cEmpEnv, cFilEnv, cProcesso)

Local aTicket   := ""
Local cSelect   := ""
Local cTabela   := ""
Local cSemaforo := ""

Default cEmpEnv := ""
Default cFilEnv := ""
Default cProcesso := ""

//Inicia processamento do conciliador
startJob("totvs.protheus.retail.rmi.servicos.SHPConciliador.SHPConciliador", GetEnvServer(), .F./*lEspera*/, cEmpEnv, cFilEnv)

cSemaforo := "RMISTAEXE" +"_"+ cEmpEnv +"_"+ "LIVE_STATUS" +"_"+ cProcesso

// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
RpcSetType(3) // Para nao consumir licenças na Threads
RpcSetEnv(cEmpEnv, cFilEnv, , , "LOJA", "RmiStaExe")

nModulo := 12 //RpcSetEnv incia o modulo 5 por padrão, para validar AmIIn(12) foi preciso mudar nModulo 
If !AmIIn(12)
    LjGrvLog(" RMISTATUSLIVE ", "Não foi encontrado Licença para o Varejo-SIGALOJA: ")    
    ConOut("RMISTATUSLIVE - Não foi encontrado Licença para o Varejo-SIGALOJA:" )
    Return(.F.)
EndIf  

If !LockByName(cSemaforo, .T., .T.)
    LjGrvLog(" RMISTATUSLIVE ", I18n(STR0002, {"RMISTAEXE"}))   //"Serviço #1 já esta sendo utilizado por outra instância."
    Return Nil
EndIf

ljxjMsgErr("Status Live" + " - " + cSemaforo + " - " + time() + " - " + cValTochar( ThreadId() ), /*cSolucao*/, /*cRotina*/, {cEmpAnt, cFilAnt})

DbSelectArea("MHR")
MHR->(DbSetOrder(1))

cTabela := GetNextAlias()
cSelect := " SELECT TOP(500) * "
cSelect += " FROM " + RetSqlName("MHR") + " MHR Where MHR_STATUS = '6' "
cSelect += Iif(!Empty(cProcesso), "AND MHR_CPROCE = '" + cProcesso + "'", "")
cSelect += " AND MHR.D_E_L_E_T_ = ' ' AND MHR_CASSIN = 'LIVE' "
cSelect += " ORDER BY MHR_DATPRO,MHR_HORPRO "
DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

LjGrvLog(" RMISTATUSLIVE ", "Apos a Execução da Query, Query em execução:", cSelect) 

While !(cTabela)->( Eof() )
    //Posiciona no Registro MHR para pegar campo Memo MHR_ENVIO
    MHR->(DbGoTo((cTabela)->R_E_C_N_O_))
    //Retorna o Array com 3 posiçoes Ticket/Sistema/Token
    aTicket := GetNumTicket(MHR->MHR_ENVIO)
    

    LjGrvLog(" RMISTATUSLIVE ", "Antes da chamada da Funcao SetStatus") 

    //Busca o Status no Live e Atualiza o a tabela MHR e caso encontre erro MHL.
    SetStatus(aTicket)
    
    (cTabela)->( DbSkip() )
EndDo

(cTabela)->( DbCloseArea() )

MHR->(DbCloseArea())

UnLockByName(cSemaforo, .T., .T.)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatus
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNumTicket(cXmlEnvio)
Local aRet          := {}
Local cToken        := ""
Local cSisSat       := "" 
Local cURL          := ""  
Local oEnviaObj     := Nil
Default cXmlEnvio   := ""

DbSelectArea("MHP")
MHP->(DbSetOrder(1))

DbSelectArea("MHO")
MHO->(DbSetOrder(1))

//MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
cToken := Alltrim(Posicione("MHO", 1, xFilial("MHO") + PADR("LIVE",TAMSX3("MHO_COD")[1]),"MHO_TOKEN"))
oJson := JsonObject():New()
oJson:FromJson(MHO->MHO_CONFIG) 
cURL  := oJson["url_token"]  
//Quando é Utilizado subsistemasatelite no Assinante. Utiliza o SubSatelite para confirmar o token
If MHP->(DbSeek(xFilial("MHP")+PadR("LIVE", TamSx3("MHP_CASSIN")[1])+ PadR(MHR->MHR_CPROCE, TamSx3("MHP_CPROCE")[1]) + '1'))

    oJson:FromJson(MHP->MHP_CONFIG)

    //caso o token esteja em branco é gerado outro para execução 
    If Empty(cToken) .or. (!Empty(oJson["subsistemasatelite"]) .and. Empty(Alltrim(oJson["subtoken"])))
        LjGrvLog("RMISTATUSLIVE", "O token esta em branco, será gerado outro")
        oEnviaObj := RmiEnvLiveObj():New(MHP->MHP_CPROCE)
        If oEnviaObj:oConfProce == Nil
            oEnviaObj:oConfProce := JsonObject():New()
        EndIf
        oEnviaObj:oConfProce:FromJson( AllTrim(MHP->MHP_CONFIG) )
        oEnviaObj:PreExecucao()
        cToken := oEnviaObj:cToken
        LjGrvLog("RMISTATUSLIVE", "O token gerado na rotina GetNumTicket. Token: ", cToken)
    EndIf

    If Empty(oJson["subsistemasatelite"])//Se nao existir subsistemasatelite utilizar o Satelite principal.
        oJson:FromJson(MHO->MHO_CONFIG)
        cSisSat := oJson["sistemasatelite"]
        cToken  := Alltrim(MHO->MHO_TOKEN)
    Else
        oJson:FromJson(MHP->MHP_CONFIG)
        cSisSat := oJson["subsistemasatelite"]
        cToken  := Iif(Empty(Alltrim(oJson["subtoken"])), oJson["subtoken"] := cToken, Alltrim(oJson["subtoken"]))
    EndIf
EndIf

Aadd(aRet,{RmiXGetTag(cXmlEnvio, "<Numero>", .F.), cSisSat,cToken,cURL})

MHP->(DbCloseArea())
MHO->(DbCloseArea())

LjGrvLog("RMISTATUSLIVE", "Retorna o Numero do Ticket e o Sistema Satelite" ,aRet)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatus
Executa a busca

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetStatus(aTicket)
Local cError    := ""
Local cBody     := ""
Local cSitua    := ""
Local cDetalhe  := ""
Local cRetorno  := ""
Local oSoapGet  := Nil

    oSoapGet := RMIConWsdl(aTicket[1][4], @cError)

    If !Empty(cError)
        lSucesso := .F.
        cRetorno := STR0003 + " [" + cError + "] "    //"Problema ao efetuar o ParseUrl verificar as configurações no cadastro de Assinantes, retorno: "
        
        LjGrvLog("RMISTATUSLIVE",cRetorno)
        
    Else
        
        LjGrvLog("RMISTATUSLIVE","PreExecucao - Parse Executado com sucesso ")
    
        If !oSoapGet:SetOperation("ConsultarStatusTicketLC_Integracao")   //"ObterChaveAcessoLC_Integracao"
            cError := I18n("Problema o Consultar end-point Live", {ProcName(), "SetOperation", "ConsultarStatusTicketLC_Integracao"} )     //"[#1] Problema ao efetuar o #2: #3"
            
            LjGrvLog("RMISTATUSLIVE",cError)
            Conout(" RMISTATUSLIVE - Erro ao setar a operacao " + cError) 
        Else
            cBody := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>"
            cBody += "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/' xmlns:ren='http://schemas.datacontract.org/2004/07/Rentech.Framework.Data' xmlns:ren1='http://schemas.datacontract.org/2004/07/Rentech.PracticoLive.Connector.Objects'>"
            cBody +=   "<soapenv:Header/>"
            cBody +=   "<soapenv:Body>"
            cBody +=       "<liv:ConsultarStatusTicketLC_Integracao>"
            cBody +=         "<liv:parametro>"
            cBody +=            "<ren1:Chave>" + aTicket[1][3] + "</ren1:Chave>"
            cBody +=            "<ren1:CodigoSistemaSatelite>" + aTicket[1][2] + "</ren1:CodigoSistemaSatelite>"
            cBody +=            "<ren1:NumeroTicket>" + aTicket[1][1]+ "</ren1:NumeroTicket>"
            cBody +=         "</liv:parametro>"
            cBody +=       "</liv:ConsultarStatusTicketLC_Integracao>"
            cBody +=   "</soapenv:Body>"
            cBody += "</soapenv:Envelope>"        
            //Envia a mensagem a ser processada
            
            LjGrvLog("RMISTATUSLIVE","SetStatus - Body -> ",cBody)
            
            If oSoapGet:SendSoapMsg(cBody)
                
                LjGrvLog("RMISTATUSLIVE","SetStatus - Body com sucesso")
                cRetorno := DeCodeUtf8( oSoapGet:GetSoapResponse() )
            
                //Pesquisa a tag com o retorno do token
                cDetalhe := RmiXGetTag(cRetorno, "<a:DetalheSituacao>", .F.)
                cSitua   := RmiXGetTag(cRetorno, "<a:SituacaoProcessamento>", .F.)
                cSitua   := AllTrim( Upper(cSitua) )
                
                LjGrvLog("RMISTATUSLIVE","Retorno de RmiXGetTag", cSitua +" -> "+cDetalhe)

                If "PROCESSADO" $ cSitua
                    Grava(.T.,cDetalhe,"2")
                ElseIf "AGUARDANDO" $ cSitua .Or. "EMPROCESSAMENTO" $ cSitua
                    Grava(.T.,cSitua,"6")
                Else
                    Grava(.F.,cDetalhe,"3")
                EndIf
            Else
                lSucesso := .F.
                cRetorno := STR0005+oSoapGet:cError  //"" Problema ao efetuar SendSoapMsg "
                LjGrvLog("RMISTATUSLIVE",cRetorno)
                //caso a chave de acesso invalida limpa o campo pra gerar novamente.
                If UPPER("Chave de Acesso Inv") $ UPPER(cRetorno)

                    DbSelectArea("MHO")
                    MHO->(DbSetOrder(1))
                    If MHO->( DbSeek( xFilial("MHO") + PADR("LIVE",TAMSX3("MHO_COD")[1]) ) )  .and. Empty(oJson["subsistemasatelite"])
                        RecLock("MHO", .F.)
                            MHO->MHO_TOKEN := ""
                        MHO->( MsUnLock() )
                        MHO->(DbCommit())
                    EndIf
                    MHO->(DbCloseArea())

                    //Como a chave de acesso do subtoken já esta vencida limpo a tag no Json
                    If !Empty(oJson["subsistemasatelite"])
                        oJson["subtoken"] := ""
                    EndIF

                    LjGrvLog("RMISTATUSLIVE","Limpando campo MHO_TOKEN e a tag SubToken no Json no retorno Chave de Acesso Invalida ")
                EndIf
                //Chamei a gravação para atualizar a tentativa
                Grava(.T.,cRetorno,"6")
            EndIf

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição 

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Grava(lSucesso,cDetalhe,cStatus)

    Default cStatus  := IIF(lSucesso,"2","3") //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação
    Default cDetalhe := "Processado com Sucesso"
    
    LjGrvLog("RMISTATUSLIVE"," Function Grava iniciando a gravação ", cDetalhe)

    Begin Transaction

        RecLock("MHR", .F.)
            MHR->MHR_STATUS := cStatus
            MHR->MHR_RETORN := cDetalhe
            MHR->MHR_DATPRO := Date()
            MHR->MHR_HORPRO := Time()
        MHR->( MsUnLock() )

        If !Empty(oJson["subsistemasatelite"])
            RecLock("MHP", .F.)
                MHP->MHP_CONFIG := oJson:ToJson()
            MHP->( MsUnLock() )
        EndIF
        
        If cStatus == "3"
            LjGrvLog(" RMISTATUSLIVE ", "Ocorreu erro na gravação" ,{MHR->MHR_UIDMHQ,cDetalhe}) 
            RMIGRVLOG("IR", "MHR" , MHR->(Recno()), "ENVIA",;
                      cDetalhe  ,      ,      , 'MHR_STATUS',;
                        .F.          , 3      ,MHR->MHR_FILIAL+"|"+MHR->MHR_UIDMHQ+"|"+MHR->MHR_CASSIN+"|"+MHR->MHR_CPROCE,MHR->MHR_CPROCE,MHR->MHR_CASSIN,MHR->MHR_UIDMHQ)
        ElseIF cStatus == '2'
            Iif(Alltrim(MHR->MHR_CPROCE) == 'PRODUTO', geraImpostos(MHR->MHR_UIDMHQ), "")
            GravaDePara(MHR->MHR_CPROCE)
        EndIf
    LjGrvLog("RMISTATUSLIVE"," Function Grava Fim da gravação ", cDetalhe)
    End Transaction
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição 

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function geraImpostos(cUUID)

    Local aArea         := getArea()
    Local cAssinante    := padR("LIVE", tamSx3("MHP_CASSIN")[1]) 
    Local aFilProc      := rmixFilial(cAssinante, "PRODUTO", "1")
    Local cStatus       := "1"
    Local cJsonImp      := ""
    Local nX            := 0
    Local aDadosMHQ     := getAdvFVal("MHQ", {"MHQ_EVENTO", "MHQ_CHVUNI"}, xFilial("MHQ") + cUUID, 7, /*uDef*/)     //MHQ_FILIAL, MHQ_UUID, R_E_C_N_O_, D_E_L_E_T_
    Local aChave        := {}

    ljGrvLog("RmiStatusLive", "Pesquisa publicação pelo UUID:", {cUUID, aDadosMHQ})

    if len(aDadosMHQ) > 0 .and. !empty(aDadosMHQ[1])

        aChave := strTokArr( aDadosMHQ[2], "|" )

        ljGrvLog("RmiStatusLive", "Localizando produto para gerar impostos:", {aChave})

        SB1->( dbSetOrder(1) )      //B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
        if SB1->( dbSeek( aChave[1] + aChave[2] ) )

            ljGrvLog("RmiStatusLive", "Gera publicação de IMPOSTO PROD e IMPOSTO VENDA, para o assinante, produto e filials:", {cAssinante, aDadosMHQ[2], aFilProc})

            for nX := 1 to len(aFilProc)

                //Função para geras o json de impostos  
                cJsonImp := ""
                JsonImp(@cJsonImp, /*cCliente*/, /*cLojaCli*/, aFilProc[nX])

                gravaMHQ(   "IMPOSTO PROD"  ,;
                            aDadosMHQ[1]    ,; 
                            aDadosMHQ[2]    ,; 
                            cJsonImp        ,; 
                            cStatus         ,;
                            aFilProc[nX]    )

                gravaMHQ(   "IMPOSTO VENDA" ,;
                            aDadosMHQ[1]    ,; 
                            aDadosMHQ[2]    ,; 
                            cJsonImp        ,; 
                            cStatus         ,;
                            aFilProc[nX]    )
            next nX
        endIf
    endIf

    fwFreeArray(aDadosMHQ)
    fwFreeArray(aFilProc)

    restArea(aArea)

Return Nil

/*/{Protheus.doc} GravaDePara
    Função para gravar de/para de cadastro, usado para confirmação da integração
    @type  Static Function
    @author Danilo Rodrigues
    @since 15/12/2022
    @version 1.0
    @param param_name, param_type, param_descr
    @return lRet
/*/
Static Function GravaDePara(cProcesso)

    Local aArea     := GetArea()
    Local aAreaMHQ  := MHQ->( GetArea() )
    Local cVlCad    := ""
    Local cChave    := MHR->MHR_FILIAL + MHR->MHR_UIDMHQ

    DbSelectArea("MHQ")
    DbSelectArea("MHN")
    MHN->( DbSetOrder(1) )    //MHN_FILIAL+MHN_COD
    If MHN->( DbSeek(xFilial("MHN") + cProcesso) )

        cVlCad := GetAdvFVal("MHQ", "MHQ_CHVUNI", cChave, 7, "")
    
        RmiDePaGrv("CONFIRMA", MHN->MHN_TABELA, /*cCampo*/, cVlCad, cVlCad, .T., MHR->MHR_UIDMHQ)
    EndIf
    
    RestArea(aAreaMHQ)
    RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} gravaMHQ
Centraliza a gravação da tabela MHQ

@type    Function
@param 	 cProcesso  , Caractere, Processo da publicação
@param 	 cEvento    , Caractere, Evento da publicação
@param 	 cChave     , Caractere, Chave unica da publicação
@param 	 cJson      , Caractere, Json da publicação
@param 	 cStatus    , Caractere, Status da publicação
@param 	 cFilReg    , Caractere, Filial do registro publicado
@version 12.1.2510
/*/
//-----------------------------------------------------------------------
Static Function gravaMHQ(cProcesso, cEvento, cChave, cJson, cStatus, cFilReg)

    RecLock("MHQ", .T.)
        MHQ->MHQ_FILIAL := xFilial("MHQ")
        MHQ->MHQ_ORIGEM := "PROTHEUS"
        MHQ->MHQ_CPROCE := cProcesso
        MHQ->MHQ_EVENTO := cEvento
        MHQ->MHQ_CHVUNI := cChave
        MHQ->MHQ_MENSAG := cJson
        MHQ->MHQ_DATGER := date()
        MHQ->MHQ_HORGER := timeFull()
        MHQ->MHQ_STATUS := cStatus      //0=Em publicação; 1=Liberado para distribuição; 9=Aguardando confirmação do produto
        MHQ->MHQ_UUID   := fwUuid("PUBLICA" + allTrim(cProcesso))
        MHQ->MHQ_IDEXT  := cFilReg
    MHQ->( MsUnLock() )

Return nil
