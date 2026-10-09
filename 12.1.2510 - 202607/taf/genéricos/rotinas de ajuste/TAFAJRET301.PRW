#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAF_ALIAS 01
#DEFINE TAF_RECNO 02
#DEFINE TSS_ID    03
#DEFINE TSS_CHAVE 04 

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFAJRET301 

Recupera as chaves (ids) do servidor TSS quando há ocorrencia de erro no 
servidor e-Social (erro 301), essas chaves sao gravadas no campo XMLID dos
eventos no TAF possibilitando a recuperacao do recibo após a realizaçao de
uma nova transmissao.

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
 Function TAFAJRET301()

    Local oDlgMain      := Nil 
    Local oFont1        := Nil 
    Local oFont2        := Nil 
    Local oPanel        := Nil 
    Local oSayMsg       := Nil 
    Local oGetServer    := Nil 
    Local oGetDB        := Nil 
    Local oGetAlias     := Nil 
    Local oGetPort      := Nil 
    Local oSayConn      := Nil 
    Local oBConn        := Nil 
    Local oBExec        := Nil
    Local oBExit        := Nil 

    Local cServer   := Space(100)
    Local cDataBase := Space(30)
    Local cAliasDB  := Space(50)
    Local cAmbte    := ""
    Local cUrl      := ""
    Local lTransFil := .F.
    Local lOk       := .F. 
    Local cCheckURL := ""
    Local cMsgRet   := ""
    Local cIdEnt    := ""
    Local cMsgEstr  := ""

    Local nPort     := 0

    If verificaMatriz()

        nHndERP := AdvConnection()
        cAmbte  := SuperGetMv('MV_TAFAMBE',.F.,"2")

        Define MsDialog oDlgMain From 0,0 To 170,460 Pixel Title "Recuperação de Recibos - Erro no Servidor e-Social - Codigo 301" 

        FwMsgRun(,{||lOk := verificaEstrutura(@cMsgEstr)},"Verificando estruturas das tabelas. ")
        If !lOk
            MsgStop("É necessário executar a rotina de compatibilização de dicionário para a criação do campo _XMLID nas seguintes tabelas: " + cMsgEstr)
            Return Nil 
        EndIf

        FwMsgRun(,{||lOk := checkConnTSS(@cURL,@lTransFil,@cCheckURL,@cMsgRet,@cIdEnt)},"Conexão com TSS","Verificando conexão com TSS.")
        If !lOk
            MsgStop("Servidor TSS não conectado.")
            Return Nil 
        EndIf
        
        oFont1 := TFont():New("Tahoma",,-12,.T.)
        oFont1:Bold  

        oFont2 := TFont():New("Tahoma",,-11,.T.)
        
        oPanel := TPanel():New(000,000,'',oDlgMain,,.F.,.F.,,CLR_WHITE,000,000,.F.,.F.)
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        oSayMsg 	:= TSay():New(04,015,{||"Informe as configuracões do Servidor TSS."},oPanel,,oFont2,,,,.T.,,,200,030,,,,,,.T.)  

        oGetServer  := TGet():New(15,015,{|u|If( PCount()==0,cServer,cServer := u )}        ,oPanel,160,009,"@!"    ,,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Host (Server):",1,,CLR_BLUE)
        oGetDB      := TGet():New(35,015,{|u|If( PCount()==0,cDataBase,cDataBase := u )}    ,oPanel,085,009,"@!"    ,,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"DataBase (Identificador do Banco):",1,,CLR_BLUE)
        oGetAlias   := TGet():New(35,112,{|u|If( PCount()==0,cAliasDB,cAliasDB := u )}      ,oPanel,063,009,"@!"    ,,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Top Alias (ODBC/TNS):",1,,CLR_BLUE) 
        oGetPort    := TGet():New(35,186,{|u|If( PCount()==0,nPort,nPort := u )}            ,oPanel,030,009,"99999" ,,,,,,,.T.,,,,,,,.F.,.F.,,,,,,.T.,,,"Top Port: ",1,,CLR_BLUE)  

        oSayConn 	:= TSay():New(055,015,{||"Não Conectado."},oPanel,,oFont2,,,,.T.,CLR_RED,,100,030,,,,,,.T.)      

        oBConn      := TButton():New(070,015,"Conectar",oPanel,{||nHndTSS := validaConTSS(cServer,cDataBase,cAliasDB,nPort,oGetServer,oGetDB,oGetAlias,oGetPort,oSayConn)}, 50,13,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oBExec      := TButton():New(070,070,"Processar",oPanel,{||runApp(oDlgMain,nHndTSS,nHndERP,cIdEnt,cAmbte)}, 50,13,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oBExit      := TButton():New(070,165,"Sair",oPanel,{||oDlgMain:End()}, 50,13,,,.F.,.T.,.F.,,.F.,,,.F. ) 

        Activate MsDialog oDlgMain Centered
    Else
        MsgStop("É Necessário estar logado em uma filial Matriz para a execução da rotina.")
    EndIf 


Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} checkConnTSS 
Verifica se o Servidor TSS está no Ar e obtem o o codigo da Entidade
correspondente a empresa

@param cURL - Url do Servidor TSS
@param lTransFil - Indica se a consulta pode ser realizada pela Filial
@param cCheckURL - Url sem o Apw
@param cMsgRet - Mensagem de retorno
@param cIdEnt - Codigo da entidade

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function checkConnTSS(cURL,lTransFil,cCheckURL,cMsgRet,cIdEnt)

    Local lRet := .T.

    If FindFunction("TafGetUrlTSS")
        cURL := PadR(TafGetUrlTSS(),250)
    Else
        cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
    EndIf
    cURL := AllTrim(cURL)

	If FindFunction("TAFTransFil")
		lTransFil := TAFTransFil(.F.)
	EndIf

    If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
        cCheckURL := cUrl
        cUrl += "/TSSWSSOCIAL.apw"
    Else
        cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
    EndIf

    If TAFCTSpd(cCheckURL,,,@cMsgRet)
        cIdEnt := TAFRIdEnt(lTransFil)
    Else
        MsgStop("Não foi possivel conectar com o servidor TSS para busca da entidade." + cMsgRet)
        lRet := .F. 
    EndIf 

Return lRet 


//----------------------------------------------------------------------------
/*/{Protheus.doc} validaConTSS 
Realiza TcLink com TSS

@param cServer - Host TSS
@param cDataBase - Identificador do Banco de Dados
@param cAliasDB - Alias da conexao ODBC/TNS
@param nPort - Porta do DbAccess

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function validaConTSS(cServer,cDataBase,cAliasDB,nPort,oGetServer,oGetDB,oGetAlias,oGetPort,oSayConn)

    Local nHndTSS := 0

    Default cServer := ""
    Default cDataBase := ""
    Default cAliasDB := ""
    Default nPort := 0

    cServer := AllTrim(cServer)
    cDataBase := AllTrim(cDataBase)
    cAliasDB := AllTrim(cAliasDB)

    nHndTSS := TCLink(cDataBase+"/"+cAliasDB,cServer,nPort)

    If nHndTSS >= 0

        oGetServer:SetEnable(.F.)
        oGetDB:SetEnable(.F.)
        oGetAlias:SetEnable(.F.)
        oGetPort:SetEnable(.F.)
        oSayConn:cCaption := "Conectado com Sucesso."
        oSayConn:NCLRTEXT := CLR_BLUE  

        MsgInfo("Conexão Realizada com Sucesso.","Conexão TSS")
    Else
        MsgInfo("Falha na conexão. Reveja os parâmetros informados e certifique-se que o servidor de destino está no Ar.","Conexão TSS")
    EndIf 

Return nHndTSS 

//----------------------------------------------------------------------------
/*/{Protheus.doc} runApp 
Função de ponte, usada somente para validação dos parâmetros e chamada 
da função de correção atraves do FWMsgRun.

@param oDlg - Objeto Dialog
@param nHndTSS - Identificador da conexao do TSS 
@param nHndERP - Identificador da conexao do TAF
@param cIdEnt - Codigo da entidade
@param cAmbte - Codigo do ambiente

@author Evandro dos Santos O. Teixeira
@since 24/08/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function runApp(oDlg,nHndTSS,nHndERP,cIdEnt,cAmbte)

    Local lReturn := .T. 

    If nHndTSS <= 0
        lReturn := .F.
        MsgStop("Configure a Conexão com o TSS para a execução da rotina")
    Else 
        FwMsgRun(,{|obj|execProc400A(obj,oDlg,nHndERP,nHndTSS,cIdEnt,cAmbte)},"Recuperação de Status/Protocolo","Pesquisando Eventos ...")
    EndIf 

Return lReturn 

//---------------------------------------------------------------------
/*/{Protheus.doc} execProc400A

Verifica se existem eventos inconsintentes na base TAF, caso positivo
procura os eventos relativos no TSS.


@Param		obj - Objeto FWMsgRun
            oDlg - Objeto Dialog
            nHndERP - Handle da conexao do servidor do TAF
			nHndTSS	- Handle da conexao do servidor TSS
            cEntidade - Entidade correspondente a Filial
            cAmbiente - Tipo do ambiente eSocial 

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function execProc400A(obj,oDlg,nHndERP,nHndTSS,cEntidade,cAmbiente)

    Local aXmlsIds := {}
    Local nQtdRegs := 0
    Local cMsgLog  := ""

    If nHndTSS < 0
        MsgStop("Realize a Conexão para a execução da rotina")
    Else

        aXmlsIds := getArr400A(obj,nHndERP,nHndTSS,cEntidade,cAmbiente)
        If !Empty(aXmlsIds)

            nQtdRegs := atualizaXMLSIds(obj,aXmlsIds,@cMsgLog)
            mostraLog("Gravação da chave no campo _XMLID","Rotina Finalizada - " + cValToChar(nQtdRegs) + " regitros localizados.",cMsgLog)
        Else

            MsgInfo("Não foram encontrados registros com código 301 na base do TSS considerando os registros inconsistentes no TAF considerando a base de CNPJ da filial logada.")
        EndIf 

        oDlg:End()
    EndIf  

Return Nil 

//---------------------------------------------------------------------
/*/{Protheus.doc} getArr400A

Pesquisa os registros inconsistentes no TAF e verifica se existe um 
registro relativo na tabela SPED400A com o codigo de erro 301, caso
positivo a chave é armazena em um array para uma posterior atualizacao 
da mesma no campo _XMLID.

@Param		obj - Objeto FWMsgRun
            nHndERP - Handle da conexao do servidor do TAF
			nHndTSS	- Handle da conexao do servidor TSS
            cEntidade - Entidade correspondente a Filial
            cAmbiente - Tipo do ambiente eSocial 

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function getArr400A(obj,nHndERP,nHndTSS,cEntidade,cAmbiente)

    Local cSql := ""
    Local aEvtEsocial := {}
    Local cTipoEvt := ""
    Local cAliasEvt := ""
    Local cLayout  := ""
    Local cId := ""
    Local cTabela := ""
    Local aXmlsIds := {}
    Local nRecNo := 0
    Local nX := 0
    Local nTamId := 0
    Local nFil := 0
    Local aFils := {}

    tcSetConn(nHndERP)

    aEvtEsocial := TAFRotinas(,,.T.,2)
    aFils := filiaisPorCPNJ()

    If ValType(obj) == "O"

        For nX := 1 To Len(aEvtEsocial)

            cAliasEvt := AllTrim(aEvtEsocial[nX][3])
            cTipoEvt := AllTrim(aEvtEsocial[nX][12])
            cLayout := AllTrim(aEvtEsocial[nX][4])

            If cTipoEvt != 'T' .And. TAFAlsInDic(cAliasEvt)
                
                If nX > 1
                    cSql += " UNION ALL "    
                EndIf 

                cSql += " SELECT '" + cLayout + "' EVENTO " 
                cSql += " ,'"   + cAliasEvt + "' TABELA "
                cSql += " ,"    + cAliasEvt + "_ID ID "
                cSql += " ,"    + cAliasEvt + "_VERSAO VERSAO "
                cSql += " , R_E_C_N_O_  RECNO "
                cSql += " FROM  "   + RetSqlName(cAliasEvt)  
                cSql += " WHERE " 

                cSql += "("
                For nFil := 1 To Len(aFils)

                    If nFil > 1 
                        cSql += " OR "
                    EndIf 

                    If cAliasEvt == "C1E"
                        cSql += " C1E_FILTAF = '" + aFils[nFil] + "'" 
                        cSql += " AND C1E_MATRIZ = 'T' "
                    Else
                        cSql += cAliasEvt + "_FILIAL = '" + xFilial(cAliasEvt,aFils[nFil]) + "'"
                    EndIf 
                Next nFil 
                cSql += ")"

                cSql += " AND " + cAliasEvt + "_STATUS = '3' " 

                If cAliasEvt == "C9V"
                    cSql += " AND C9V_NOMEVE != 'TAUTO' "
                EndIf

                cSql += " AND " + cAliasEvt + "_ATIVO = '1' "
                cSql += " AND D_E_L_E_T_ = ' ' "

            EndIf 

        Next nX 

        TCQuery cSql New Alias 'rsIds'

        While rsIds->(!Eof())

            cTabela := AllTrim(rsIds->TABELA)
            nRecNo  := rsIds->RECNO
            
            nTamId := GetSx3Cache(cTabela + "_ID","X3_TAMANHO")
            cId := AllTrim(StrTran(rsIds->EVENTO,"-","")) + PADR(rsIds->ID,nTamId) + AllTrim(rsIds->VERSAO)

            obj:cCaption := "Verificando ID " + AllTrim(cId) + " tabela " + cTabela + " no servidor TSS."
            ProcessMessages()
            tcSetConn(nHndTSS)

            cSql := " SELECT CHAVE "
            cSql += " FROM SPED400A SP400A"
            cSql += " WHERE ENTIDADE = '"   + cEntidade + "'"
            cSql += " AND AMBIENTE = '"     + cAmbiente + "'"
            cSql += " AND ID = '"           + cId + "'"
            cSql += " AND CODRECEITA = '301' "
            cSql += " AND D_E_L_E_T_ = ' ' "

            TCQuery cSql New Alias 'rs400A'

            If rs400A->(!Eof())

                aAdd(aXmlsIds,{  cTabela;
                                ,nRecNo;
                                ,cId;
                                ,rs400A->CHAVE})

                
            EndIf 
            rs400A->(dbCloseArea())

            tcSetConn(nHndERP)
            rsIds->(dbSkip())   
        EndDo

    Else
        MsgStop("Encerre esta seção (Thread) para utilizar esta rotina novamente.")
    EndIf 

    
    rsIds->(dbCloseArea())

Return aXmlsIds

//---------------------------------------------------------------------
/*/{Protheus.doc} atualizaXMLSIds

Atualiza nas tabelas do TAF as chaves encontradas no TSS com o 
codigo de erro 301
	
@Param		obj - Objeto FWMsgRun
            aXmlsIds - Array com os eventos localizados com o codigo 301
			cMsgRet	 - Messagem de finalização

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function atualizaXMLSIds(obj,aXmlsIds,cMsgRet)

    Local nX := 0 
    Local nRecNo := 0
    Local nRegsAtu := 0
    Local cXmlId := ""
    Local cAliasTab := ""
    Local cIdTss := ""
    
    For nX := 1 To Len(aXmlsIds)

        cAliasTab   := aXmlsIds[nX][TAF_ALIAS]
        nRecNo      := aXmlsIds[nX][TAF_RECNO]
        cIdTss      := aXmlsIds[nX][TSS_ID]
        cXmlId      := aXmlsIds[nX][TSS_CHAVE]

        (cAliasTab)->(dbGoTo(nRecNo))
        If (cAliasTab)->(!Eof())
            RecLock(cAliasTab,.F.)
            (cAliasTab)->&(cAliasTab+"_XMLID") := cXmlId
            (cAliasTab)->&(cAliasTab+"_STATUS") := '0'
            (cAliasTab)->(msUnlock())
            nRegsAtu++
            cMsgRet += "Registro Atualizado. Alias: " + cAliasTab + " - RecNo: " + cValToChar(nRecNo) + " - XmlId: " + cXmlId + CRLF
            obj:cCaption := "Atualizando chave " + cXmlId + " na Tabela " + cAliasTab
            ProcessMessages()
        Else
            cMsgRet += "Registro não posicionado. Alias: " + cAliasTab + " - RecNo: " + cValToChar(nRecNo) + " - XmlId: " + cXmlId + CRLF
        EndIf 

    Next nX 

    cMsgRet += CRLF
    cMsgRet += "Os eventos acima foram localizados na base TSS com o codigo de erro 301 (servidor do governo indisponível), "
    cMsgRet += " as chaves (IDs) utilizadas nestes registros foram atualizados no TAF, desta forma ao realizar transmissão destes eventos "
    cMsgRet += " o RET irá retornar os recibos. "

Return nRegsAtu 

//---------------------------------------------------------------------
/*/{Protheus.doc} filiaisPorCPNJ

Retorna as filias com a mesma base de CNPJ da empresa logada.

@return aFils - Filiais

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function filiaisPorCPNJ()

    Local aAreaSM0 := {}
    Local aFils    := {}
    Local cBaseCGC := ""
    Local nTpInscr := 1 

    nTpInscr := SM0->M0_TPINSC
    
    If nTpInscr == 1
        cBaseCGC := SM0->M0_CGC
    Else
        cBaseCGC := Substr(SM0->M0_CGC,1,8)
    EndIf 

    aAreaSM0 := SM0->(getArea())
    SM0->(dbGoTop())

    While SM0->(!Eof())

        If nTpInscr == 1 
            If cBaseCGC == SM0->M0_CGC
                aAdd(aFils,SM0->M0_CODFIL)
            EndIf 
        Else
            If cBaseCGC == Substr(SM0->M0_CGC,1,8)
                aAdd(aFils,SM0->M0_CODFIL)
            EndIf
        EndIf  

        SM0->(dbSkip())
    EndDo 

    RestArea(aAreaSM0)

Return aFils 

//---------------------------------------------------------------------
/*/{Protheus.doc} mostraLog

Exibe o log com inconsistências encontradas durante o processamento.

@Param		cTitulo	-	Título da interface
			cHeader	-	Cabeçalho da inconsistência
			cBody	-	Mensagem de inconsistência

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function mostraLog(cTitulo,cHeader,cBody)

    Local oModal := Nil 

    oModal := FWDialogModal():New()
    oModal:SetTitle( cTitulo )
    oModal:SetFreeArea( 290, 250 )
    oModal:SetEscClose( .T. )
    oModal:SetBackground( .T. )
    oModal:CreateDialog()

    TMultiGet():New( 030, 020, { || cHeader + Chr( 13 ) + Chr( 10 ) + Chr( 13 ) + Chr( 10 ) + cBody }, oModal:GetPanelMain(), 250, 190,,,,,, .T.,,,,,, .T.,,,,, .T. )

    oModal:Activate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} verificaEstrutura

Verifica se as tabelas contem o campo _XMLID

@param cMsgErr - Tabelas que não contem o campo _XMLID
@return lRet - Retorna se todas as tabelas possuem o campo _XMLID

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function verificaEstrutura(cMsgErr)

    Local aEvtEsocial := {}
    Local cAliasEvt := ""
    Local cTipoEvt := ""
    Local nX := 0
    Local lRet := .T. 
    Local lVirgula := .F. 

    aEvtEsocial := TAFRotinas(,,.T.,2)

    For nX := 1 To Len(aEvtEsocial)

        cAliasEvt := AllTrim(aEvtEsocial[nX][3])
        cTipoEvt := AllTrim(aEvtEsocial[nX][12])

        If cTipoEvt != 'T' .And. TAFAlsInDic(cAliasEvt)

            If !TAFColumnPos(cAliasEvt+"_XMLID")

                If lVirgula
                    cMsgErr += ","
                Else
                    lVirgula := .T.
                EndIf 

                cMsgErr += cAliasEvt
                lRet := .F.
            EndIf 
        EndIf
    Next nX 

Return lRet 

//---------------------------------------------------------------------
/*/{Protheus.doc} verificaMatriz

Verifica se a filial logada é Matriz 

@return lehMatriz - Retorna se a filial é matriz ou não 

@Author		Evandro dos Santos Oliveira Teixeira
@Since		16/01/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function verificaMatriz()

    Local lehMatriz := .F.

	//Verifica se a filial logada é a filial matriz
	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( MSSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lehMatriz := .T.
		EndIf
	EndIf

Return lehMatriz 






