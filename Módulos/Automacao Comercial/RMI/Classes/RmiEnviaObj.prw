#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVIAOBJ.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static lStRmixFil   := existFunc("rmixFilial")      //Verifica se existe a função que vai retornar as filiais

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnviaObj
Classe responsável pelo envio das distribuições

/*/
//-------------------------------------------------------------------
Class RmiEnviaObj

    Data cAssinante     As Character    //Código do Assinante
    Data oConfAssin     As Objetc       //Objeto JsonObject de configuração do assinante
    Data cToken         As Character    //Código do token que poderá ser atualizado - campo MHO_TOKEN
    
    Data cProcesso      As Character    //Código do Processo
    Data oConfProce     As Objetc       //Objeto JsonObject de configuração do processo
    Data cTabela        As Character    //Principal tabela referente ao processo
    Data aSecundaria    As Character    //Tabelas secundarias relacionadas ao processo
    Data aArrayFil      As Array        //Contem as filias selecionada no Processo (MHP_FILPRO) 
    Data nFil           As Numeric      //Numero de controle para ArrayFil

    Data cTipo          As Character    //Tipo referente ao processo que será utilizado (MHP_TIPO)
    Data cLayoutEnv     As Character    //Layout referente ao processo que será utilizado para geração do body (MHP_LAYENV)
    Data oLayoutEnv     As Objetc       //Objeto JsonObject com layout do corpo da mensagem que será enviada

    Data cOrigem        As Character    //Nome do sistema origem que gerou a publicação (MHQ_ORIGEM)
    Data cPublica       As Character    //Publicação referente ao processo que será utilizado para geração do body (MHQ_MENSAG)
    Data oPublica       As Objetc       //Objeto JsonObject com a publicação
    Data cChaveUnica    As Character    //Código da chave única referente ao registro publicado
    Data cEvento        As Character    //Define o evento do registro 1=Upsert, 2=Delete
    Data cIdExt         As Character    //Conteúdo do campo MHQ_IDEXT
    
    Data nTimeOut       as Numeric      //Controla o tempo aguardado em um requisição do objeto fwRest

    Data oPreExecucao   As Objetc       //Objeto utilizado para efetuar as regras de antes da execução Ex: Obter token

    Data aHeader        as Array        //Cabeçalho com as configurações para efetuar as comunicações (Get, Post, Put)
    Data cBody          As Character    //Corpo da mensagem que será enviada para o sistema de destino
    Data oBody          As Objetc       //Objeto Json com o corpo da mensagem que será enviada para o sistema de destino
    Data oEnvia         As Objetc       //Objeto utilizado para efetuar o envio
    Data lContinuaEnvio As Logical      //Faz o controle do processamento continuo

    Data lSucesso       As Logical      //Define o sucesso da execução
    Data cRetorno       As Character    //Mensagem de retorno
    Data cTipoRet       As Character    //Tipo do retorno que pode ser Erro, Alerta ou categorizado
    Data oRetorno       As Objetc       //Objeto que conterá o retorno do envio
    Data cChaveExterna  As Objetc       //Código da chave única retornado pelo sistema destino

    Data cQuery         As Character    //Query com a consulta das distribuiçãoes a enviar
    Data cAliasQuery    As Character    //Nome do alias temporario com o resultado da query acima

    Data lLoteIdRet     as Logical      //Valida a existencia dos campos MHR_LOTE e MHR_IDRET
    Data cLote          As Character    //Guarda o Lote para ser utilizado no layout 
    Data cIdRetaguarda  As Character    //Guarda o idRetaguarda do PDVSync 
    Data nMhrRec        As Numeric      // Recno de busca utilizado na consulta.
    Data nMhqRec        As Numeric      // Recno de busca utilizado na consulta.
    
    Data cMD5               As Character    //MD5 do dado enviado (excluindo campos cadastrados na tag camposExcluidosDaComparacao na configuração do processo.)
    Data lEnvDuplic         As Logical      //Indica se é um envio duplicado com base no MD5
    Data lComparaRepetido   as Logical      //Indica se a comparação de repetidos esta ativa

    Data lDetDistrib    as Logical      //Define se esta ativo a gração da tabela MIP
    
    Method New(cAssinante)              //Metodo construtor da Classe

    Method PreExecucao()                //Metodo com as regras para efetuar conexão com o sistema de destino
    Method PosExecucao()                //Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informações referente ao processo que será enviado
    
    Method SetArrayFil()
    
    Method Processa()                   //Metodo que ira controlar o processamento dos envios

    Method Consulta()                   //Metodo que efetua consulta das distribuições a enviar

    Method CarregaBody()                //Metodo que carrega o corpo da mensagem que será enviada

    Method Envia()                      //Metodo responsavel por enviar a mensagens ao sistema de destino

    Method Grava(cStatus)               //Metodo que ira atualizar a situação da distribuição e gravar o de\para
    Method atualizaMHR()                //Metodo que atualiza dados na tabela MHR

    Method SalvaConfig()                //Metodo que ira atualizar a a configuraçaõ do assinante, com o novo token gerado

    Method Destroi()                    //Metodo que ira tirar os objetos criados da memoria

    Method DePara(cAlias , cValor , nRetIxdex , nIndice)                     //Metodo responsavel por buscar o de/para e validar dado na base.

    Method ProcessNode(oJson,nItem)     //Metodo responsavel em processar um nó do layout de publicação

    Method AlteraConfig()               //Metodo responsavel em ajustar o JSON de configuração da tabela MHO
    
    Method SetList(cXmlItens)           //Metodo responsavel em ajustar o XML quando existe Itens

    //Metodos para controle de execução
    Method getSucesso()                 //Retorna a situação da execução - lSucesso
    Method getRetorno()                 //Retorna a mensagem de execução - cRetorno

    Method ProcessArray(aArray,cTag)
    Method GetCadAux(cIdMIH,cTpCadAux,cCampoRet)   // Metodo para retornar conteudo de um campo no cadastrdo Auxiliar cID = MIH_ID

    Method RemoveTags()
    Method Remocao(xTag,jEnvio)
    Method SetMd5() 
    Method ValidaEnvioDuplicado()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante, cProcesso) Class RmiEnviaObj
    
    Default cProcesso   := ""
    
    self:cAssinante     := ""
    self:oConfAssin     := Nil
    self:cToken         := ""

    self:cProcesso      := cProcesso //Tratamento Thread do Live por processo
    self:oConfProce     := Nil
    self:cTabela        := ""
    self:aSecundaria    := {}
    self:aArrayFil      := {}
    self:nFil           := 0
    self:cTipo          := "1"  //1=Envio
    self:cLayoutEnv     := ""
    self:oLayoutEnv     := Nil

    self:cOrigem        := ""
    self:cPublica       := ""
    self:oPublica       := Nil
    self:cChaveUnica    := ""
    self:cEvento        := "1"  //1=Upsert
    self:cIdExt         := ""

    self:nTimeOut       := 300  //5 minutos

    self:oPreExecucao   := Nil

    self:aHeader        := {}
    self:cBody          := ""
    self:oBody          := Nil
    self:oEnvia         := Nil
    self:lContinuaEnvio := .T.

    self:lSucesso       := .T.
    self:cRetorno       := ""
    self:cTipoRet       := ""
    self:oRetorno       := Nil
    self:cChaveExterna  := ""

    self:cQuery         := ""
    self:cAliasQuery    := ""

    self:lLoteIdRet     := MHR->( fieldPos("MHR_LOTE") ) > 0 .and. MHR->( fieldPos("MHR_IDRET") ) > 0
    Self:cLote          := "" 
    Self:cIdRetaguarda  := "" 
    Self:nMhrRec        := 0
    Self:nMhqRec        := 0

    Self:lEnvDuplic         := .F.
    self:lComparaRepetido   := .F.

    self:lDetDistrib    := FwAliasInDic("MIP") .And. ExistFunc("RmiStDist")

    MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
    If MHO->( DbSeek( xFilial("MHO") + PadR(cAssinante, TamSx3("MHO_COD")[1]) ) )

        self:cAssinante := MHO->MHO_COD
        self:cToken     := AllTrim(MHO->MHO_TOKEN)
        self:oConfAssin := JsonObject():New()
        self:oConfAssin:FromJson( AllTrim(MHO->MHO_CONFIG) )

        if self:oConfAssin:hasProperty("timeOut") .and. self:oConfAssin["timeOut"] > 0
            self:nTimeOut := self:oConfAssin["timeOut"]
        endIf
    Else

        self:lSucesso := .F.
        self:cRetorno := I18n(STR0001, {cAssinante})    //"Assinante não encontrado #1"
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnviaObj
    
    Local cJson := "" //Recebe o Json da configuração do assinante MHO_CONFIG

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json    
    If self:oPreExecucao == Nil
        self:oPreExecucao := FWRest():New("")

        //Seta a url para pegar o token
        self:oPreExecucao:SetPath( self:oConfAssin["url_token"] )
    EndIf
    
    cJson := self:oConfAssin:ToJson()
    
    If Self:oConfProce["chave"] <> Nil .AND. !Empty(Self:oConfProce["chave"])
        cJson := StrTran(cJson,self:oConfAssin["chave"],Self:oConfProce["chave"])    
    EndIf

    //Seta o corpo do Post
    self:oPreExecucao:SetPostParams( cJson )

    //Busca o token
    If self:oPreExecucao:Post( {"Content-Type:application/json"} )
        
        self:cRetorno := self:oPreExecucao:GetResult()                
        
        If self:oRetorno == Nil
            self:oRetorno := JsonObject():New()
        EndIf
        self:oRetorno:FromJson(self:cRetorno)

        self:lSucesso   := self:oRetorno[ self:oConfAssin["tagretorno"] ]
        self:cToken     := self:oRetorno[ self:oConfAssin["tagtoken"] ]
    Else

        self:lSucesso := .F.
        self:cRetorno := self:oPreExecucao:GetLastError() + " - [" + self:oConfAssin["url_token"] + "]"
        LjGrvLog(" RmiEnviaObj ", "self:oPreExecucao:Post() = .F. => ",{self:cRetorno })        
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será enviado

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiEnviaObj

    Local cRetorno := ""
    
    //Limpa configurações anteriores
    self:cProcesso  := ""
    self:cLayoutEnv := ""
    self:cTabela    := ""
    aSize(self:aSecundaria, 0)
    
    MHP->( DbSetOrder(1) )  //MHP_FILIAL + MHP_CASSIN + MHP_CPROCE + MHP_TIPO
    If MHP->( DbSeek( xFilial("MHP") + self:cAssinante + Padr(cProcesso, TamSx3("MHP_CPROCE")[1] ) + self:cTipo ) ) .And. MHP->MHP_ATIVO == "1"

        self:cProcesso  := MHP->MHP_CPROCE
        self:cLayoutEnv := AllTrim(MHP->MHP_LAYENV)
        self:cTabela    := Posicione("MHN", 1, xFilial("MHN") + self:cProcesso, "MHN_TABELA")     //MHN_FILIAL + MHN_COD

        //Gera aArrayFil com as filiais do De/Para
        self:SetArrayFil()

        //Caso o method SetArrayFil gere exception o self:lSucesso é Falso e para gerar log.
        If self:lSucesso

            //Carrega layout que será enviado
            If SubStr(self:cLayoutEnv, 1, 1) == "{"
                If self:oLayoutEnv == Nil
                    self:oLayoutEnv := JsonObject():New()
                EndIf
                self:oLayoutEnv:FromJson(self:cLayoutEnv)
            EndIf

            If !Empty(MHP->MHP_CONFIG)
                If self:oConfProce == Nil
                    self:oConfProce := JsonObject():New()
                EndIf
                
                If ValType( cRetorno := self:oConfProce:FromJson( AllTrim(MHP->MHP_CONFIG) ) ) == "C"

                    self:lSucesso := .F.
                    self:cRetorno := "Campo MHP_CONFIG no cadastro de Assinante com conteúdo inválido, não foi possível transformá-lo em Json, verifique! " + cRetorno
                Else
                
                    self:lComparaRepetido := MHR->( ColumnPos("MHR_MD5") ) > 0 .And. self:oConfProce:HasProperty("configPSH") .And. self:oConfProce["configPSH"]:HasProperty("camposExcluidosDaComparacao")
                EndIf

            EndIf

            If ExistFunc("RmiGetRepc") .AND. RmiGetRepc() .AND. !IsInCallStack("GERAMSG")
                Self:AjustaJsonRepro()
            EndIf

            //Carrega tabelas secundarias
            MHS->( DbSetOrder(1) )  //MHS_FILIAL + MHS_CPROCE + MHS_TABELA
            If MHS->( DbSeek(xFilial("MHS") + self:cProcesso) )
                While !MHS->( Eof() ) .And. MHS->MHS_FILIAL == xFilial("MHS") .And. MHS->MHS_CPROCE == self:cProcesso
                    Aadd(self:aSecundaria, MHS->MHS_TABELA)
                    MHS->( DbSkip() )
                EndDo
            EndIf
        endIf
    Else

        self:lSucesso := .F.
        self:cRetorno := I18n(STR0002, {cProcesso, self:cAssinante})     //"Processo #1 não existe ou não esta ativo para o Assinante #2"
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento dos envios

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiEnviaObj

    LjGrvLog(" RmiEnviaObj ", "Antes da chamada do metodo consulta", FWTimeStamp(2))

    self:SetaProcesso( self:cProcesso )

    if self:lSucesso

        while self:lContinuaEnvio

            //Carrega a distribuições que devem ser enviadas
            self:Consulta()

            LjGrvLog(" RmiEnviaObj ", "Apos executar a query do metodo consulta", FWTimeStamp(2))
            
            if (self:cAliasQuery)->( eof() )
                
                self:lContinuaEnvio := .F.
                ljGrvLog("RmiEnviaObj", "Todos os registros da query foram processados.", self:lContinuaEnvio)
            else
                
                    While !(self:cAliasQuery)->( Eof() )
                        
                        self:lSucesso   := .T.
                        self:cRetorno   := ""
                        self:cBody      := ""
                        self:lEnvDuplic := .F.

                        //Posiciona na publicação
                        MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE
                        MHQ->( DbGoTo( (self:cAliasQuery)->RECNO_PUB ) )
                        
                        If !MHQ->( Eof() )

                            self:cOrigem     := MHQ->MHQ_ORIGEM
                            self:cEvento     := MHQ->MHQ_EVENTO //1=Upsert, 2=Delete, 3=Inutilização
                            self:cChaveUnica := MHQ->MHQ_CHVUNI
                            self:cIdExt      := allTrim(MHQ->MHQ_IDEXT)
                            self:nMhqRec     := MHQ->(Recno())
                            
                            //Metodo com as regras para efetuar conexão com o sistema de destino
                            If self:lSucesso
                                LjGrvLog(" RmiEnviaObj ", "Executa PreExecucao =>", {(self:cAliasQuery)->MHQ_CPROCE})
                                self:PreExecucao()
                            EndIf

                            //Carrega o layout com os dados da publicação
                            If self:lSucesso
                                
                                //Carrega a publicação que será distribuida
                                self:cPublica := AllTrim(MHQ->MHQ_MENSAG)
                                If self:oPublica == Nil
                                    self:oPublica := JsonObject():New()
                                EndIf

                                If !Empty(Alltrim(self:cPublica))
                                    self:oPublica:FromJson(self:cPublica)
                                    self:CarregaBody()
                                Else
                                    self:lSucesso := .F.
                                    self:cRetorno := "campo MHQ_MENSAG em branco MHQ_UUID -> "+ MHQ->MHQ_UUID    
                                    LjGrvLog(" RmiEnviaObj ", "Erro ao Carrega o layout com os dados da publicação =>", {AllTrim(MHQ->MHQ_MENSAG),MHQ->MHQ_UUID})
                                EndIf
                            EndIf

                            //Envia a distribuição ao assinante
                            If self:lSucesso
                                self:Envia()
                            EndIf
                        Else
                            self:lSucesso := .F.
                            self:cRetorno := I18n(STR0003, {"MHQ", cValToChar( (self:cAliasQuery)->RECNO_PUB)} )       //"Publicação(#1), recno #2 não encontrado"
                            LjGrvLog(" RmiEnviaObj ", "lSucesso := .F. -> ",{self:cRetorno} )
                        EndIf

                        //Posiciona na distribuição
                        MHR->( DbSetOrder(1) )  //MHR_FILIAL + MHR_CASSIN + MHR_CPROCE
                        MHR->( DbGoTo( (self:cAliasQuery)->RECNO_DIS ) )
                        If !MHR->( Eof() )
                            self:Grava()
                        EndIf

                        LjGrvLog("RmiEnviaObj", "Executa PosExecucao => MHR.R_E_C_N_O_:", (self:cAliasQuery)->RECNO_DIS)
                        self:PosExecucao()

                        (self:cAliasQuery)->( DbSkip() )
                        FwFreeObj(self:oRetorno)
                        self:oRetorno := Nil
                    EndDo

                    //Atualiza a configuração do assinante, com o novo token gerado
                    If self:lSucesso
                        self:SalvaConfig()
                    EndIf

            EndIf
        
            (self:cAliasQuery)->( DbCloseArea() )
        endDo

    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo que efetua consulta das distribuições a enviar

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiEnviaObj

    Local cDB       := AllTrim( TcGetDB() )
    Local cQuant    := "100000"
    Local cSelect   := IIF( cDB == "MSSQL"            , " TOP " + cQuant          , "" )
    Local cWhere    := IIF( cDB == "ORACLE"           , " AND ROWNUM <= " + cQuant, "" )
    Local cLimit    := IIF( !(cDB $ "MSSQL|ORACLE")   , " LIMIT " + cQuant        , "" )
    Local nX        := 0
    Local aDataHora := {}
    Local aTent     := {}

    LjGrvLog("RmiEnviaObj", "Conectado com banco de dados: " + cDB)

    self:cAliasQuery := GetNextAlias()

    self:cQuery      := "SELECT "
    self:cQuery      += cSelect
    self:cQuery      += " MHQ_CPROCE, MHQ.R_E_C_N_O_ AS RECNO_PUB, MHR.R_E_C_N_O_ AS RECNO_DIS "
    self:cQuery      += " FROM " + RetSqlName("MHQ") + " MHQ INNER JOIN " + RetSqlName("MHR") + " MHR "
    self:cQuery      += " ON MHQ_FILIAL = MHR_FILIAL AND MHQ_UUID = MHR_UIDMHQ "

    If !Empty(self:cProcesso)
        self:cQuery  += " AND MHQ_CPROCE = '" + self:cProcesso + "'"
    EndIf    

    self:cQuery      += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
    self:cQuery      += " AND MHR_CASSIN = '" + self:cAssinante + "'"
    self:cQuery      += " AND ( MHR_STATUS = '1'"                         //1=A processar, 2=Processado, 3=Erro

    If self:oConfProce <> Nil .and. self:oConfProce:hasProperty("qtdereenvio") 
        aTent  := self:oConfProce["qtdereenvio"]

        LjGrvLog("RmiEnviaObj", "Encontrada propriedade na configuração para reenvio: ", aTent)

        If Len(aTent) == 0 .or. Len(aTent) > 9
            LjGrvLog("RmiEnviaObj","A tag qtdereenvio foi configurada incorretamente. Favor verifique!")
            Return Nil
        EndIF        

        self:cQuery += " OR (MHR_STATUS = '3' AND MHR_TENTAT < 9 AND ("

        For nX := 1 to len(aTent)

            aDataHora := SHPRepData(aTent[nX]) 

            aDataHora[1] := DtoS(aDataHora[1])
            aDataHora[2] := aDataHora[2] + ":59" 

            LjGrvLog("RmiEnviaObj", "Numero da tentativa: " + cValtoChar(nX) + " ,Data: " + aDataHora[1] + " , Hora: " + aDataHora[2])                            

            self:cQuery += " (MHR_TENTAT = '" + cValtoChar(nX) + "' AND MHR_DATPRO = '" + aDataHora[1] + "' AND MHR_HORPRO <= '" + aDataHora[2] + "')"
            If nx < Len(aTent)
                self:cQuery += " OR "
            EndIF
        Next nX 

        self:cQuery += " ))"
    EndIF

    self:cQuery += " )"
    self:cQuery += " AND MHR.D_E_L_E_T_ = ' ' "
    self:cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "

    //Ajuste envia PdvSync para nao repetir itens na lista.
    If self:nMhrRec > 0
        self:cQuery      += " AND MHR.R_E_C_N_O_ > "+Alltrim(STR(self:nMhrRec))
    EndIf
    
    self:cQuery      += cWhere    

    self:cQuery      += " ORDER BY MHR.R_E_C_N_O_"

    self:cQuery      += cLimit

    LjGrvLog(" RmiEnvObj ", "Method Consulta() cQuery => "+self:cQuery )
    
    DbUseArea(.T., "TOPCONN", TcGenQry( , , self:cQuery), self:cAliasQuery, .T., .F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaBody
Metodo que carrega o corpo da mensagem que será enviada

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method CarregaBody() Class RmiEnviaObj

    Local aTags         := {}
    Local nTag          := 0
    Local xLayout       := Nil
    Local nPosIni       := 0
    Local nPosFim       := 0
    Local cAux          := ""
    Local cCampo        := ""
    Local xPublica      := Nil
    Local bErrorBlock   := Nil
    Local lErrorBlock   := .F.
    Local cErrorBlock   := ""
    Local aAux          := {}

    //Limpa para carregar o novo
    self:cBody          := ""

    //Salva tratamento de erro anterior e atualiza tratamento de erro
    bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, @lErrorBlock, @cErrorBlock)} )

    //Condição que pode dar erro
    Begin Sequence

        Do Case

            //Layout não preenchido
            Case Empty(self:cLayoutEnv)
                
                self:cBody := ""
                LjGrvLog(" RmiEnviaObj ", "Layout não preenchido cBody ")

            //Macro executa função para retornar body
            Case SubStr(self:cLayoutEnv, 1, 1) == "&"

                //Retira quebra de linha e tab para macro executar
                self:cBody := &(FwNoAccent(SubStr( StrTran( StrTran( StrTran(self:cLayoutEnv, Chr(9), ""), Chr(10), ""), Chr(13), ""), 2) ))                                  

            //Carrega body a partir do layout do processo
            OtherWise

                // -- Limpo o controle de registro duplicado
                Self:lEnvDuplic     := .F.

                //Cria o corpo da mensagem a partir do layout
                If self:oBody == Nil
                    self:oBody := JsonObject():New()
                EndIf            
                self:oBody:FromJson( self:oLayoutEnv:ToJson() )
                
                If self:oBody:hasProperty("configPSH")
                    self:oBody:DelName("configPSH")
                EndIf
                
                Self:cIdRetaguarda := "" 

                //Retorno o nome das propriedades do objeto layout
                aTags := self:oLayoutEnv:GetNames()                
                For nTag := 1 To Len(aTags)

                    //Carrega configuração de uma tag do layout
                    xLayout  := self:oLayoutEnv[ aTags[nTag] ]
                    xPublica := ""

                    Do Case

                        //Campo da publicação
                        Case ValType(xLayout) == "C" .And. ( nPosIni := At("%", xLayout) ) > 0                            
                            //Carrega campo
                            cAux 	:= SubStr(xLayout, nPosIni + 1)
                            nPosFim := At("%", cAux)
                            cCampo  := AllTrim( SubStr(cAux, 1, nPosFim - 1) )
                                                        
                            //Pega conteudo da publicação
                            If At(cCampo, self:cLayoutEnv) > 0
                                xPublica := self:oPublica[cCampo]                                
                            EndIf

                        //Retorna resultado de macro execução
                        Case ValType(xLayout) == "C" .And. SubStr(xLayout, 1, 1) == "&"
                            
                            cCampo  := AllTrim( SubStr(xLayout, 2) )                            
                            //Macro executa
                            If !Empty(cCampo)
                                xPublica := &(cCampo)                                
                            EndIf

                        Case ValType(xLayout) == "J"
                            
                            Self:ProcessNode(@xLayout)
                            xPublica := xLayout                            

                        Case ValType(xLayout) == "A"
                            
                            aAux     := aClone(xLayout)
                            
                            xPublica := self:ProcessArray(aAux,aTags[nTag])
                            
                        //Retorna o proprio contudo do layout
                        OTherWise
                            xPublica := xLayout
                            LjGrvLog(" RmiEnviaObj ", 'OTherWise|xPublica' ,{xPublica})
                            
                    End Case
                    
                    If ValType(xPublica) == "C" .AND. !Empty(xPublica)
                        LjGrvLog(" RmiEnviaObj ", "xPublica do tipo C ",{xPublica} )
                        If UPPER(Alltrim(xPublica)) == "NULL"
                            xPublica := NIL    
                        EndIf
                    elseIf (ValType(xPublica) $ "U")  
                        xPublica := I18n(STR0004, {xLayout})    //"Configuração da TAG #1 inválida"
                        LjGrvLog(" RmiEnviaObj ", xPublica )
                    EndIf

                    If Upper(aTags[nTag]) == "IDRETAGUARDA" 
                        Self:cIdRetaguarda := xPublica
                    EndIf

                    //Atualiza o corpo da mensagem com os dados da publicação
                    // -- Vefirico se o Nó atual ainda existe no JSON, caso a tabela de referencia desse Nó não esteja disponivel o nó é removido
                    If self:oBody:hasProperty( aTags[nTag])
                        self:oBody[ aTags[nTag] ] := xPublica                        
                    Else
                        LjGrvLog(" RmiEnviaObj ", "TAG [" + aTags[nTag] + "] não está mais disponivel no JSON, o nó será ignorodo.",self:oBody)    
                    EndIf 

                Next nTag

                //Exportar o objeto JSON para uma string em formato JSON
                self:cBody := self:oBody:ToJson()

                // -- Checa se é um envio duplicado com base no MD5
                Self:ValidaEnvioDuplicado()

        End Case

    //Se ocorreu erro
    Recover
        
        self:lSucesso := .F.
        self:cRetorno := I18n("Erro ao gerar layout de envio - Processo #1, Assinante #2: ", {AllTrim(self:cProcesso), AllTrim(self:cAssinante)}) + CRLF + cErrorBlock
        LjxjMsgErr(self:cRetorno)

    End Sequence

    //Restaura tratamento de erro anterior
    ErrorBlock(bErrorBlock)

    If ValType(self:cBody) <> "C" .Or. Empty(self:cBody) .Or. self:cBody =="{}"
        self:lSucesso := .F.
        self:cRetorno := IIF(Empty(self:cRetorno),STR0005,self:cRetorno)    //"Corpo não preenchido ou inválido"
        LjGrvLog(" RmiEnviaObj ", 'Corpo não preenchido ou inválido' )
    EndIf

    self:cBody := AllTrim(self:cBody)

    Asize(aTags, 0)
    FwFreeArray(aAux)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao sistema de destino

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnviaObj

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        //Inteligencia poderá ser feita na classe filha - default em Rest com Json    
        If self:oEnvia == Nil
            self:oEnvia := FWRest():New("")
        EndIf

        self:oEnvia:SetPath( self:oConfProce["url"] )

        self:oEnvia:SetPostParams(EncodeUTF8(self:cBody))
        
        If self:oEnvia:Post( {"Content-Type:application/json"} )
            
            self:cRetorno := self:oEnvia:GetResult()
            
            If self:oRetorno == Nil
                self:oRetorno := JsonObject():New()
            EndIf
            self:oRetorno:FromJson(self:cRetorno)

            self:lSucesso       := self:oRetorno[ self:oConfProce["tagretorno"] ]
            
            If self:oConfProce["tagprincipal"] <> Nil .AND. !Empty(self:oConfProce["tagprincipal"])

                //Quando ocorre algum erro no envio, a TAG principal é Nil, neste caso não deve pegar a chave externa
                If self:oRetorno[self:oConfProce["tagprincipal"]] <> Nil

                    self:cChaveExterna  := self:oRetorno[self:oConfProce["tagprincipal"]][self:oConfProce["tagcodigo"]]
                    If ValType(self:cChaveExterna) == "N"
                        self:cChaveExterna := cValToChar(self:cChaveExterna)                        
                    EndIf
                    LjGrvLog(" RmiEnviaObj ", "Retorna a chave externa " ,{self:cChaveExterna})    
                EndIf
            Else
                self:cChaveExterna  := self:oRetorno[ self:oConfProce["tagcodigo"] ]
                LjGrvLog(" RmiEnviaObj ", "tagprincipal igua a 'NIL' " ,{self:cChaveExterna}) 
            EndIf
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oEnvia:GetLastError() + " - [" + self:oConfProce["url"] + "]" + CRLF
            LjGrvLog(" RmiEnviaObj ", "Não teve sucesso retorno => " ,{self:cRetorno})             
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar o de\para

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava(cStatus) Class RmiEnviaObj

    Local cSisOrigem := IIF(AllTrim(self:cAssinante) == "PROTHEUS", self:cOrigem, self:cAssinante)  //Tratamento para publicações que o Protheus assina
    
    Default cStatus  := IIF( self:lSucesso, "2", IIF(Self:lEnvDuplic, "R", "3") )                   //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação R=Repitido

    Begin Transaction

        //Atualiza dados na tabela MHR
        self:atualizaMHR(cStatus)

        //Só grava de\para quando tiver chave externa, tratamento para sistemas assincronos
        If self:lSucesso .And. !Empty(self:cChaveExterna)
            
            RmiDePaGrv( cSisOrigem    , self:cTabela, ""/*cCampo*/, self:cChaveExterna, self:cChaveUnica,;
                        (self:cEvento == "1"),MHR->MHR_UIDMHQ)
        EndIf
        
        If cStatus == "3" .Or. cStatus == "R" 

            LjGrvLog(" RmiEnviaObj ", "Ocorreu erro na gravação" ,{MHR->MHR_UIDMHQ,self:cRetorno}) 
            RMIGRVLOG(  cStatus         , "MHR"             , MHR->(Recno())    , "ENVIA"           ,;
                        self:cRetorno   , /*lRegNew*/       , /*lTxt*/          , "MHR_STATUS"      ,;
                        .F.             , 3                 , self:cChaveUnica  , MHR->MHR_CPROCE   ,;
                        MHR->MHR_CASSIN , MHR->MHR_UIDMHQ   )
        EndIf
    End Transaction

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaConfig
Metodo que ira atualizar a configuração do assinante.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SalvaConfig() Class RmiEnviaObj

    DbSelectArea("MHO")    
    MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
    If MHO->( DbSeek( xFilial("MHO") + self:cAssinante ) ) 
        RecLock("MHO", .F.)
            
            If Alltrim(self:cToken) <> Alltrim(MHO->MHO_TOKEN)
                MHO->MHO_TOKEN := RTrim(self:cToken)
            EndIf 
            
            MHO->MHO_CONFIG :=  self:oConfAssin:ToJson()

        MHO->( MsUnLock() )
    EndIf
    MHO->(DbCloseArea())

    If Valtype(self:oConfProce) == "J" .And. Alltrim(Self:cProcesso) == Alltrim(MHP->MHP_CPROCE)
        RecLock("MHP", .F.) 
            MHP->MHP_CONFIG := self:oConfProce:ToJson()
        MHP->( MsUnLock() )
    EndIf 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroi
Metodo que ira tirar os objetos criados da memoria

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroi() Class RmiEnviaObj
    
    FwFreeObj(self:oConfAssin)
    FwFreeObj(self:oConfProce)
    FwFreeObj(self:oLayoutEnv)
    FwFreeObj(self:oPublica)
    FwFreeObj(self:oBody)
    FwFreeObj(self:oPreExecucao)
    FwFreeObj(self:oEnvia)
    FwFreeObj(self:oRetorno)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getSucesso
Retorna a situação da execução - lSucesso

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method getSucesso() Class RmiEnviaObj
Return self:lSucesso

//-------------------------------------------------------------------
/*/{Protheus.doc} getRetorno
Retorna a mensagem de execução - cRetorno

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method getRetorno() Class RmiEnviaObj
    LjxjMsgErr( "[" + AllTrim(self:cProcesso) + "] " + self:cRetorno, /*cSolucao*/, self:cTipoRet )
Return self:cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} SetArrayFil
Alimenta o Atributo aArrayFil para controle de filial no processo.
@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetArrayFil() Class RmiEnviaObj

    Local aArrayCamp := {}
    Local nX         := 0
    Local cRetFil    := ""
    Local cSisOrigem := IIF(AllTrim(self:cAssinante) == "PROTHEUS", self:cOrigem, self:cAssinante)  //Tratamento para publicações que o Protheus assina

    aSize(self:aArrayFil, 0)

    //Campo obrigatorio caso esteja em branco gerar exception
    If !empty(MHP->MHP_FILPRO) .or. !empty(MHP->MHP_LAYFIL)

        aArrayCamp := iif( lStRmixFil, rmixFilial(self:cAssinante, self:cProcesso, self:cTipo), strTokArr( alltrim(MHP->MHP_FILPRO), ";") )

        For nX:=1 To Len(aArrayCamp)

            //Parametros-> cSisOri(CHEF ou LIVE...) ,Alias,cPesDePara,lOrigem) lOrigem-> .T. Retorna o campo MHM_VLORIG .F. Retorna MHM_VLINT
            cRetFil := RmiDePaRet(cSisOrigem, "SM0", aArrayCamp[nX], .T.)
            
            If !Empty(cRetFil)

                Aadd(self:aArrayFil, {cRetFil, aArrayCamp[nX]})
            Else

                LjGrvLog(" RmiEnviaObj ", I18n(STR0006, {aArrayCamp[nX], self:cAssinante}))  //De Para de Filial #1 não encontrado, para o assinante #2.                
            EndIf
        Next nX

    Else

        self:lSucesso := .F.
        self:cRetorno := I18n(STR0007, {self:cProcesso, self:cAssinante})  //Campo Obrigatorio de Filiais não preenchido no cadastro de Assinantes
    EndIf

    LjGrvLog("RmiEnviaObj", "Carregando De\Para de Filiais.", {self:cRetorno, self:aArrayFil} )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
Metodo responsavel por buscar o de/para e validar seus dados na base.
Seta erro caso nao encontre de/para ou registro na base.

@param cAlias        Alias para Busca do De/Para | Obrigatório
@param cValor        Valor do De/Para para busca | Obrigatório
@param nRetIxdex     Indice a ser retornado quando De/para com mais de um retorno | Padrão 2
@param nIndice       Indice para busca da informação na base se passar 0 não valida | Padrão 1
@param lOrigem       indica se busca dado de origem | Padrão .F. 

@author  Rafael Pessoa
@version 1.0
/*/
//-------------------------------------------------------------------
Method DePara(  cAlias  , cValor    , nRetIxdex , nIndice ,;
                lOrigem , cOrigem   , cFilInt   ) Class RmiEnviaObj
    
    Local cRetDePara    := ""
    Local cRet          := ""
    Local aAux          := {}
    Local cChave        := ""
    Local aRetorno      := {}
    Local aArea         := GetArea()
    Local aAreaSa1      := SA1->(GetArea())

    Default cAlias	    := ""
    Default cValor	    := ""
    Default nRetIxdex   := 2
    Default nIndice	    := 1
    Default lOrigem	    := .F.
    Default cOrigem	    := ""
    Default cFilInt     := cFilAnt

    LjGrvLog("DePara","ID_INICIO")

    cAlias      := AllTrim(cAlias)

    If Empty(cOrigem)    
        cOrigem     := IIf(AllTrim(self:cAssinante) == "PROTHEUS" , self:cOrigem, self:cAssinante)
    EndIf    
    
    LjGrvLog("DePara", "Parâmetros recebidos:", {cAlias, cValor, nRetIxdex, nIndice, lOrigem, cOrigem, cFilInt})
    
    cRetDePara := RmiDePaRet(cOrigem, cAlias, cValor , lOrigem)

    If Empty(cRetDePara) .And. ExistFunc("RmiDePaAut")
        //Verifica se a tabela tem tratamento para inclusão automática
        LjGrvLog("DePara","Antes de buscar Automatico " + cRetDePara)
        cRetDePara := RmiDePaAut(cOrigem, cAlias, cValor , lOrigem)
        LjGrvLog("DePara","Depois de buscar Automatico " + cRetDePara)
    EndIf

    //Para cliente, quando não localiza o de\para tentar encontrar o cliente pelo cpf\cnpj
    if cAlias == "SA1" .and. empty(cRetDePara)

        SA1->( DbSetOrder(3) )      //A1_FILIAL, A1_CGC

        If SA1->( dbSeek( xFilial("SA1", padR(cFilInt, tamSx3("A1_FILIAL")[1])) + padR(cValor, tamSx3("A1_CGC")[1]) ) )
            cRetDePara := SA1->A1_FILIAL + "|" + SA1->A1_COD + "|" + SA1->A1_LOJA
        else
            self:cRetorno += i18n(STR0016, {cValor, cAlias}) + CRLF     //"Cliente com cpf\cnpj #1 não localizado na tabela de clientes(#2). Verifique se a integração de clientes esta ativa e se o cliente já foi integrado corretamente."
        endIf
    endIf

    If Empty(cRetDePara)
        self:lSucesso := .F.
        self:cTipoRet := "DEPARA"
        self:cRetorno += I18n(STR0008, {AllTrim(cOrigem), cAlias, cValor }) + CHR(13)+CHR(10) //"De/Para(MHM) não encontrado para a busca realizada. Origem: #1 | Alias: #2 | Valor: #3"    
    Else

        aAux := Separa(cRetDePara,"|") 

        If Len(aAux) >= nRetIxdex

            If lOrigem
                cChave  := Replace(cValor,"|","")
            Else
                cChave  := Replace(cRetDePara,"|","")
            EndIf

            cRet    := aAux[nRetIxdex] //Pega o Retorno na posição do parametro da função

            If nIndice > 0
                (cAlias)->( DbSetOrder(nIndice) )
                If !(cAlias)->( DbSeek(cChave) )
                    cRet := ""
                    self:lSucesso := .F.
                    self:cTipoRet := "DEPARA"
                    self:cRetorno   += I18n(STR0009, {cAlias, nIndice , cChave }) + CHR(13)+CHR(10) //"Registro não encontrado para a busca realizada no Alias: #1 | Indice: #2 | Chave: #3"   
                EndIf
            EndIf
        Else
            self:lSucesso := .F.
            self:cTipoRet := "DEPARA"
            self:cRetorno   += I18n(STR0010, { nRetIxdex , cRetDePara })  + CHR(13)+CHR(10) //"De/Para não localizado para posição: #1 . De/Para: #2 ."
        EndIf

    EndIf

    LjGrvLog("DePara","cRet: " + cRet)
    LjGrvLog("DePara","ID_FIM")

    fwFreeArray(aRetorno)

    RestArea(aAreaSA1)
    RestArea(aArea)
    
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AlteraConfig
Metodo responsavel em ajustar o JSON de configuração da tabela MHO

@param   oJson -> Recebe o objeto json na qual seria o nó a processar
@param   cTag  -> Nome da tag do nó
@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method AlteraConfig() Class RmiEnviaObj

Local cJson         := self:oConfAssin:ToJson() //Retorno do JSON
Local aTagsAssi     := self:oConfAssin:GetNames() //Retorna as tags do assinante
Local aTagsProce    := self:oConfProce:GetNames() //Retorna as tagas do processo
Local nI            := 0 //Variavel de loop
Local nPos          := 0 //Posição da tag

For nI := 1 To Len(aTagsAssi)
    nPos := aScan(aTagsProce,{|x| AllTrim(x) == AllTrim(aTagsAssi[nI])})
    If nPos > 0
        If self:oConfProce[aTagsAssi[nI]] <> Nil .AND. !Empty(self:oConfProce[aTagsAssi[nI]])
            cJson := StrTran(cJson,self:oConfAssin[aTagsAssi[nI]],Self:oConfProce[aTagsAssi[nI]])
        EndIf
    EndIf
Next nI

Return cJson


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessNode
Metodo responsavel por processar um nó no layout de envio do cadastro

@param   oJson -> Recebe o objeto json na qual seria o nó a processar
@param   nItem  -> Item atual
@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method ProcessNode(oJson,nItem) Class RmiEnviaObj

Local aTags     := oJson:GetNames() //Armazena todas as tags para processar
Local nI        := 0                //Variavel de loop
Local xLayout   := Nil              //Recebe o layout a processar
Local xPublica  := Nil              //Recebe o conteudo para colocar no objeto oBody
Local nPosIni   := 0                //Verifica na string se existe um determinado caractere
Local nPosFim   := 0                //Verifica na string se existe um determinado caractere
Local cAux      := ""               //Conteúdo auxilixar a ser macro-executado
Local cCampo    := ""               //Recebe o campo a ser macro-executado
Local aAux      := {}

             
Default nItem       := 0


For nI := 1 To Len(aTags)

    //Carrega configuração de uma tag do layout
    xLayout  := oJson[ aTags[nI] ]
    xPublica := ""

    Do Case

        //Campo da publicação
        Case ValType(xLayout) == "C" .And. ( nPosIni := At("%", xLayout) ) > 0

            //Carrega campo
            cAux 	:= SubStr(xLayout, nPosIni + 1)
            nPosFim := At("%", cAux)
            cCampo  := AllTrim( SubStr(cAux, 1, nPosFim - 1) )

            //Pega conteudo da publicação
            If At(cCampo, self:cLayoutEnv) > 0
                xPublica := self:oPublica[cCampo]
            EndIf

        //Retorna resultado de macro execução
        Case ValType(xLayout) == "C" .And. SubStr(xLayout, 1, 1) == "&"

            cCampo  := AllTrim( SubStr(xLayout, 2) )

            //Macro executa
            If !Empty(cCampo)
                xPublica := &(cCampo)
            EndIf
        Case ValType(xLayout) == "A"
            aAux     := aClone(xLayout)   
            xPublica := self:ProcessArray(aAux,aTags[nI])

        //Retorna o proprio contudo do layout
        OTherWise
            xPublica := xLayout
            
    End Case

    If ValType(xPublica) == "C" .AND. !Empty(xPublica)
        xPublica := EncodeUtf8(xPublica)
        If UPPER(Alltrim(xPublica)) == "NULL"
            xPublica := NIL    
        EndIf
    elseIf (ValType(xPublica) $ "U")  
        xPublica := I18n(STR0004, {xLayout})    //"Configuração da TAG #1 inválida"
    EndIf

    //Atualiza o corpo da mensagem com os dados da publicação
    
    oJson[ aTags[nI] ] := xPublica
Next nI


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SetList
Metodo responsavel por processar um nó no layout de envio xml

@param   cXmlItens -> Recebe xml na qual seria o nó a processar
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetList(cXmlItens) Class RmiEnviaObj
Local cItens    := ""
Local cXml      := ""
Local nPos      := 1
Local nTabSeq   := 1    

DEFAULT cXmlItens := ""

For nTabSeq := 1 To Len(self:aSecundaria)
    If ValType(self:oPublica[self:aSecundaria[nTabSeq]]) <> 'U'
        For nPos:= 1 To Len(self:oPublica[self:aSecundaria[nTabSeq]]) //Tamanho do Array de Itens da tabela secundaria.
            cXml := '&"'+RmiXGetTag(cXmlItens, self:oConfProce[self:aSecundaria[nTabSeq]], .T.)+'"' //Retorna a configuração exemplo:  "SD1" é igual "<LC_ItemNotaEspelho>"
            cXml := StrTran(cXml,"nPos",Alltrim(STR(nPos)))
            cXml := StrTran(cXml,"'+",'"+')
            cXml := StrTran(cXml,"+'",'+"')
            cItens += &(SubStr( StrTran( StrTran( StrTran(cXml, Chr(9), ""), Chr(10), ""), Chr(13), ""), 2) )
        next
    else
        LjGrvLog("(Method SetList) tabela Secundaria não encontrada no Json Gerado conferir campo MHQ_MENSAG -> ",self:aSecundaria[nTabSeq])
        
        self:lSucesso := .F.
        self:cRetorno := "(Method SetList) tabela Secundaria não encontrada no Json Gerado conferir campo MHQ_MENSAG -> "+self:aSecundaria[nTabSeq]              
    EndIf       
next

Return cItens 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessArray
Método para processar os no do Json e retornar o Array de nó

@type Method
@param aArray,cTag
@author  Lucas Novais
@Date    27/07/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method ProcessArray(aArray,cTag) Class RmiEnviaObj
    Local aRet       := {}
    Local nItem      := 1
    Local aTags      := {}
    Local cTagTabela := "TableNode"
    Local nLen       := 0
    Local cTagAux    := ""

    If ValType(aArray[1]) == "J"
        
        aTags := aArray[1]:GetNames()

        If aScan(aTags,cTagTabela) > 0
            LjGrvLog("ProcessArray", "Iniciar o array para macro executar!")

            cTagAux := aArray[1][cTagTabela]

            If Self:oPublica:hasProperty(cTagAux)
         
                If ValType(Self:oPublica[cTagAux]) == "A"
                    nLen := Len(Self:oPublica[cTagAux])

                ElseIf ValType(Self:oPublica[cTagAux]) == "C" .And. ";" $ Self:oPublica[cTagAux]
                    nLen := Len( StrTokArr(Self:oPublica[cTagAux], ";") )
                    
                EndIf 

                For nItem := 1 To nLen
                    Aadd(aRet,JsonObject():New())

                    // -- Carrego layout padrão
                    aRet[nItem]:FromJson(aArray[1]:ToJson())
                    
                    // -- Processo e Macro executo cada nó do objeto.
                    Self:ProcessNode(@aRet[nItem],nItem)
                    // -- Remove a TAG q indica a tabela chave antes de criar o layout
                    aRet[nItem]:DelName(cTagTabela)
                Next nItem
            Else
                // -- Tabela Chave [cTagTabela] não encontrada na publicação, por esse motivo removemos o Nó  
                LjGrvLog("ProcessArray","Tabela Chave [" + cTagTabela + "] não encontrada na publicação, por esse motivo removemos o Nó [" + cTag + "]")
                
                Self:oBody:DelName(cTag)
                aRet := aArray
            EndIf    
        Else

            //Macro executa o objeto json dentro da 1ª posição do array
            LjGrvLog("ProcessArray", "TAG " + cTagTabela + " não foi encontrada no Layout, será feita a macro execução para apenas 1 item do array.")
            self:ProcessNode(@aArray[1], 1)            
            aRet := aArray
        EndIf 
    Else   
        LjGrvLog("ProcessArray","Parametro aArray não é um Json -> ", aArray)
        aRet := aArray
    EndIf 

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCadAux
Metodo responsavel por buscar o conteudo na tabela Auxiliar.

@type    Method
@param   cIdMIH,cTpCadAux,cCampoRet
@author  Everson S P Junior
@Date    13/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetCadAux(cIdMIH, cTpCadAux, cCampoRet) Class RmiEnviaObj

    Local aAreaMIH      := MIH->(GetArea())
    Local oJsonCfg      := Nil
    Local cJsonCfg      := ""
    Local xRet          := ""
    Local nPos          := 0

    DEFAULT cIdMIH      := ""
    DEFAULT cTpCadAux   := ""
    DEFAULT cCampoRet   := "" 

    If !Empty(cIdMIH)

        DbSelectArea("MIH")
        MIH->( DbSetOrder(1) )    

        If MIH->( dbSeek( xFilial("MIH") + PadR(cTpCadAux, TamSx3("MIH_TIPCAD")[1]) + PadR(cIdMIH,TamSx3("MIH_ID")[1]) ) ) //Verifica se existe o cadastro Auxilixar.
            
            cJsonCfg := MIH->MIH_CONFIG
            //Carrega configurações do tipo do cadastro        
            oJsonCfg := JsonObject():New()
            oJsonCfg:FromJson(cJsonCfg)             

            If ( nPos := aScan( oJsonCfg["Components"], {|x| UPPER(x["IdComponent"]) == UPPER(cCampoRet)} ) ) > 0
                xRet := oJsonCfg["Components"][nPos]["ComponentContent"]
                Do Case
                
                    Case VALTYPE(xRet) == "C" .AND. Empty(xRet)
                        Self:lSucesso := .F.
                        self:cRetorno   += I18n(STR0009, {cTpCadAux, cCampoRet , cIdMIH }) + CHR(13)+CHR(10) //"Registro não encontrado para a busca realizada no Alias MIH : #1 | Indice: #2 | Chave: #3"   
                        LjGrvLog(" RmiEnviaObj ", 'OTherWise|xPublica' ,I18n(STR0009, {' MIH |'+cTpCadAux, cCampoRet , cIdMIH }))
                    
                    
                    Case VALTYPE(xRet) == "N"
                        //Não Implementado Regra para retorno numerico
                    
                    
                    Case VALTYPE(xRet) == "L"
                        //Não Implementado Regra para retorno Logico
                    
                    Case VALTYPE(xRet) == "U" //Retorno desconhecido com exemplo NIL ou NULL
                        Self:lSucesso := .F.
                        self:cRetorno += STR0011+ cTpCadAux + STR0012 + cCampoRet + STR0013 + cIdMIH //'Tipo de retorno desconhecido na busca MIH Cadastro Auxiliar -> '+cTpCadAux+ ' Campo de Retorno '+ cCampoRet+' Conteudo pesquisado '+cIdMIH
                        LjGrvLog(" RmiEnviaObj ", STR0011+ cTpCadAux + STR0012 + cCampoRet + STR0013 + cIdMIH)
                End Case
            Else
                Self:lSucesso := .F.
                self:cRetorno += STR0015 + cCampoRet+ STR0015 + cTpCadAux
                LjGrvLog(" RmiEnviaObj ", STR0014 + cCampoRet+ STR0015 + cTpCadAux) //'O Campo de Retorno ->'+cCampoRet+'<- solicitado, não exite no cadastro Auxiliar '+ cTpCadAux
            EndIf
            
        Else

            Self:lSucesso := .F.
            self:cRetorno   += I18n(STR0009, {' MIH |'+cTpCadAux, cCampoRet , cIdMIH }) + CHR(13)+CHR(10) //"Registro não encontrado para a busca realizada no Alias MIH : #1 | Indice: #2 | Chave: #3"   
        EndIf

    EndIf

    RestArea(aAreaMIH)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosExecucao
Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PosExecucao() Class RmiEnviaObj
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMD5
Metodo responsavel por Setar o MD5 no propriedade Self:Md5

@author  Lucas Novais (lnovais@)
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetMD5() Class RmiEnviaObj
    Local cEnvio := Self:cBody
    Local jEnvio := JsonObject():New()

    If jEnvio:FromJSON(cEnvio) == Nil
        Self:RemoveTags(@jEnvio)

        Self:cMD5 :=  MD5(jEnvio:ToJson(),2)
    EndIf 

    FwFreeObj(jEnvio)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RemoveTags
Metodo responsavel por Remover as tags presentes na configuração camposExcluidosDaComparacao

@author  Lucas Novais (lnovais@)
@version 1.0
/*/
//-------------------------------------------------------------------
Method RemoveTags(jEnvio) Class RmiEnviaObj
    Local nCampo := 1
    
    For nCampo := 1 To Len(Self:oConfProce["configPSH"]["camposExcluidosDaComparacao"]) 
        Self:Remocao(Self:oConfProce["configPSH"]["camposExcluidosDaComparacao"][nCampo],jEnvio) 
    Next nCampo
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Remocao
Metodo responsavel por percorrer o objeto e remover as tags antes de gerar o md5

@author  Lucas Novais (lnovais@)
@version 1.0
/*/
//-------------------------------------------------------------------
Method Remocao(xTag,jEnvio) Class RmiEnviaObj
    
    Local nCampo := 1
    Local nItem := 1

    If ValType(xTag) == "A"
        For nCampo := 1 To Len(xTag[2])// -- {String contendo o nome da TAG que será removida,Array com campos que serão removidos}
            If ValType(jEnvio[xTag[1]]) == "A"   //-- Nesse ponto o dado pode ser um objeto Json ou um Array, por esse motivo existe tratamento especifico 
                For nItem := 1 To Len(jEnvio[xTag[1]])
                    Self:Remocao(xTag[2][nCampo],jEnvio[xTag[1]][nItem])
                Next nItem
            Else
                Self:Remocao(xTag[2][nCampo],jEnvio[xTag[1]])
            EndIf 
        Next 
    Else
        If ValType(jEnvio) == "J" //Caso não tenha dados ignora (ex: array vazio)
            jEnvio:DelName(xTag)
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Remocao
Metodo responsavel por validar se existe algum envio duplicado

@author  Lucas Novais (lnovais@)
@version 1.0
/*/
//-------------------------------------------------------------------
Method ValidaEnvioDuplicado() Class RmiEnviaObj

	Local aArea	  := GetArea()
    Local cQuery  := ""
    Local cDB     := AllTrim( TcGetDB() )
    Local cQuant  := "1"
    Local cSelect := IIF( cDB == "MSSQL" , " TOP " + cQuant , "" )
    Local cWhere  := IIF( cDB == "ORACLE" , " AND ROWNUM <= " + cQuant, "" )
    Local cLimit  := IIF( !(cDB $ "MSSQL|ORACLE") , " LIMIT " + cQuant , "" )
    Local cTabela := ""

    If self:lComparaRepetido

        //Carrega o MD5 do registro que esta sendo enviado
        self:SetMD5()

        cQuery := " SELECT"
        cQuery += 	cSelect
        cQuery += 	" MHR_MD5, MHR_UIDMHQ, MHR_CASSIN, MHR_STATUS"
        cQuery += " FROM " + RetSqlName("MHR") + " MHR INNER JOIN " + RetSqlName("MHQ") + " MHQ"
        cQuery += 	" ON MHR.MHR_UIDMHQ = MHQ.MHQ_UUID"
        cQuery += " WHERE MHR_FILIAL = '"   + xFilial("MHR")        + "'"
        cQuery += 	" AND MHR_CPROCE = '"   + Self:cProcesso 		+ "'"
        cQuery += 	" AND MHR_CASSIN = '"   + Self:cAssinante 		+ "'"
        cQuery += 	" AND MHR_DATPRO >= '"  + dToS( date() - 30 ) 	+ "'"
		cQuery += 	" AND MHR.D_E_L_E_T_ = ' '"
        cQuery += 	" AND MHQ_CHVUNI = '"   + Self:cChaveUnica 		+ "'"
		cQuery += 	" AND MHQ.D_E_L_E_T_ = ' '"
        cQuery += 	cWhere
        cQuery += " ORDER BY MHR.R_E_C_N_O_ DESC"
        cQuery += cLimit
        
        cQuery := ChangeQuery(cQuery)

        cTabela := GetNextAlias()
        
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTabela, .T., .F. )
        
        If !(cTabela)->( Eof() ) .And. (cTabela)->MHR_MD5 == self:cMD5 .And. (cTabela)->MHR_STATUS $ "2|6|R"  //2=Processado corretamente, 6=Aguardando Confirmação, R=Repetido, iqual ao ultimo enviado coretamente
            Self:lEnvDuplic := .T.
            Self:lSucesso   := .F.
            Self:cRetorno   := "Registro com envio duplicado, ou seja, são os mesmos dados do ultimo envio realizado. UIID MHQ do ultimo envio: UIDMHQ [" + (cTabela)->MHR_UIDMHQ + "] e ASSINANTE: [" + (cTabela)->MHR_CASSIN + "]"
        EndIf 

        (cTabela)->( DbCloseArea() )
    Else

        LjGrvLog("Envio - ValidaEnvioDuplicado()", "Não foi possivel realizar a checagem de MD5, campo MHR_MD5 não esta presente ou comparação de repetidos esta desabilitada.")
    EndIf
    
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} atualizaMHR
Metodo que atualiza dados na tabela MHR

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method atualizaMHR(cStatus) Class RmiEnviaObj

    RecLock("MHR", .F.)
        MHR->MHR_STATUS := cStatus
        MHR->MHR_TENTAT := cValToChar( Val(MHR->MHR_TENTAT) + 1)
        MHR->MHR_DATPRO := Date()
        MHR->MHR_HORPRO := Time()
        MHR->MHR_RETORN := self:cRetorno 
        MHR->MHR_ENVIO  := self:cBody

        If self:lLoteIdRet 
            MHR->MHR_LOTE   := IIF(self:lEnvDuplic, "", self:cLote)
            MHR->MHR_IDRET  := self:cIdRetaguarda
        EndIf

        If self:lComparaRepetido
            MHR->MHR_MD5	:= self:cMD5
        EndIf
    MHR->( MsUnLock() )

Return Nil
