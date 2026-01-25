#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIBUSLIVEOBJ.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusLiveObj
Classe responsável pela busca de dados no Live
    
/*/
//-------------------------------------------------------------------
Class RmiBusLiveObj From RmiBuscaObj
    
    Data cNewChv        As Character
    Data oLive          As Object

    Method New()                            //Metodo construtor da Classe

    Method PreExecucao()                    //Metodo com as regras para efetuar conexão com o sistema de destino

    Method Busca()                          //Metodo responsavel por buscar as informações no sistema de destino

    Method SetaProcesso(cProcesso)          //Metodo responsavel por carregar as informações referente ao processo que será recebido

    Method TrataRetorno()                   //Metodo que centraliza os retorno permitidos

    Method Venda()                          //Metodo para carregar a publicação de venda

    Method NotaEntrada()                    //Metodo para carregar a mensagem de origem da publicação de nota de entrada
    
    Method Cadastros()                      //Metodo para carregar a publicação de Cadastros
    
    Method Confirma()                       //Metodo que efetua a confirmação do recebimento

    Method AjustaJsonRepro()                //Metodo não é implementado para o LiveConector

    //reprocessamento
    Method Reprocessa(cProcesso, oJsParams) //Metodo responsavel por buscar os registros com erro e separá-los por ticket para reenvio.
    Method EnvReproc(cProcesso, oJsParams)  //Metodo responsavel por liberar os tickets novamente para efetuar o reprocessamento novamente na busca.

    Method ReproCli(lDefault)               //Method para aceitar o cliente em caso de erro no processamento.

    Method setChaveUnica()                  //Metodo que atualiza a propriedade cChaveUnica a partir da configuração do processo. oConfProce["ChaveUni"]

    //Metodos utilizados nos Layouts
    Method LayEstAuto(cCmpRet, cModelo, cSerie, cEstacao)   //Metodo que Retorna informações da SLG a partir do campo recebido no parâmetro cCmpRet ou cadastra a SLG
    Method LayDocOri()                                      //Metodo que retorna o numero do documento fiscal de origem

    //Metodos auxiliares para tratamento interno da classe
    Method AuxExistePub()                       //Metodo que ira verificar se uma publicação já existe
    method SetFilMHP()                 //Metodo que atualiza o assinante LIVE para a primeira filial da lista ser unica a ser utilizada.
    
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class RmiBusLiveObj

    _Super:New("LIVE")

    If self:lSucesso
        self:oLive := totvs.protheus.retail.rmi.classes.live.Live():New()
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
Method PreExecucao() Class RmiBusLiveObj
    
    Local cError    := ""
    Local cWarning  := ""
    Local cBody     := ""
    Local cAux      := ""

    //Token do Live eh valido por 1 dia
    If !Empty(self:cToken)
        Return Nil
    EndIf

    Self:oPreExecucao := RMIConWsdl(self:oConfAssin["url_token"], @cError)

    If Empty(cError) 

        //Seta a operação que será executada
        LjGrvLog("RMIBUSLIVEOBJ","PreExecucao - Operacao",self:oConfAssin["operacao"])
        If !self:oPreExecucao:SetOperation( self:oConfAssin["operacao"] )   //"ObterChaveAcessoLC_Integracao"
            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, {ProcName(), "SetOperation", self:oPreExecucao:cError} )     //"[#1] Problema ao efetuar o #2: #3"
            LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
        Else
            LjGrvLog("RMIBUSLIVEOBJ","PreExecucao - Operacao set com sucesso")
            cBody := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>"
            cBody += "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/'>"
            cBody +=   "<SOAP-ENV:Body>"
            cBody +=       "<ObterChaveAcessoLC_Integracao xmlns='http://LiveConnector/'>"
            cBody +=           "<CodigoSistemaSatelite>" + self:oLive:getSatelite(self) + "</CodigoSistemaSatelite>"
            cBody +=           "<Usuario>" + self:oConfAssin["usuario"] + "</Usuario>"
            cBody +=           "<Senha>" + self:oConfAssin["senha"] + "</Senha>"
            cBody +=           "<PersisteChave>true</PersisteChave>"
            cBody +=       "</ObterChaveAcessoLC_Integracao>"
            cBody +=   "</SOAP-ENV:Body>"
            cBody += "</SOAP-ENV:Envelope>"        

            //Envia a mensagem a ser processada
            LjGrvLog("RMIBUSLIVEOBJ","PreExecucao - Body",cBody)
            If self:oPreExecucao:SendSoapMsg(cBody)
                LjGrvLog("RMIBUSLIVEOBJ","PreExecucao - Body com sucesso")
                self:cRetorno := self:oPreExecucao:GetSoapResponse()
                

                //Pesquisa a tag com o retorno do token
                cAux := RmiXGetTag(self:cRetorno, "<ObterChaveAcessoLC_IntegracaoResult>", .T.)
                LjGrvLog("RMIBUSLIVEOBJ","Retorno de RmiXGetTag", cAux)

                If !Empty(cAux)

                    self:oRetorno := XmlParser(cAux, "_", @cError, @cWarning)

                    //Carrega token
                    If self:oRetorno <> Nil
                        
                        If self:oConfProce:hasProperty("subsistemasatelite") .And. Valtype(self:oConfProce["subsistemasatelite"]) != "U" .And. !Empty(self:oConfProce["subsistemasatelite"])
                            self:oConfProce["subtoken"] := self:oRetorno:_ObterChaveAcessoLC_IntegracaoResult:Text
                        Else
                            self:cToken                 := self:oRetorno:_ObterChaveAcessoLC_IntegracaoResult:Text
                        EndIf

                        //Atualiza o token no assinante                        
                        self:SalvaConfig()
                    EndIf
                EndIf

                If Empty(cAux) .Or. self:oRetorno == Nil
                    self:lSucesso := .F.
                    self:cRetorno := I18n(STR0001, { ProcName(), "XmlParser", cError + CRLF + cWarning + CRLF + self:cRetorno} )    //"[#1] Problema ao efetuar o #2: #3"
                    LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
                EndIf
            Else
                self:lSucesso := .F.
                self:cRetorno := I18n(STR0001, { ProcName(), "SendSoapMsg", self:oPreExecucao:cError} )     //"[#1] Problema ao efetuar o #2: #3"
                LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
            EndIf

        EndIf
    Else
        self:lSucesso := .F.
        self:cRetorno := I18n(STR0001, {ProcName(), "XmlParser", self:oPreExecucao:cError} )    //"[#1] Problema ao efetuar o #2: #3"
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informações no Live

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusLiveObj

    Local cAux      := ""
    Local cError    := ""
    Local cWarning  := ""
    Local cDocCad   := ""
    Local aFilBus   := {}
    

    Self:oBusca := RMIConWsdl(self:oConfProce["url"], @cError)
    // Permito apenas 1 filial de busca, pois o Live é compartilhado a buscar não precisando mais q uma filial.
    LjGrvLog("RMIBUSLIVEOBJ","Tamanho do array de filial",{Len(self:aArrayFil)})
    If Len(self:aArrayFil) > 1
        LjGrvLog("RMIBUSLIVEOBJ","ajuste para adicionar apenas uma filial para busca antes do method SetFilMHP")
        self:SetFilMHP() // Atualiza o assinante LIVE para a primeira filial da lista ser unica a ser utilizada.
        //Ajusto o array de filial para não entrar novamnete no method SetFilMHP
        Aadd(aFilBus,aClone(self:aArrayFil[self:nFil]))  //aArrayFil[1] contem filial de filtros de buscas
        aSize(self:aArrayFil, 0)
        self:aArrayFil := aClone(aFilBus)
    EndIf
    //Faz o parse de uma URL
    If !Empty(cError)
        self:lSucesso := .F.
        self:cTipoRet := "RMIBUSLIVEOBJ"
        self:cRetorno := I18n(STR0001, { ProcName(), "ParseUrl", self:oBusca:cError} )      //"[#1] Problema ao efetuar o #2: #3"
    Else

        //Seta a operação que será executada
        If !self:oBusca:SetOperation( self:oConfProce["operacao"] )     //RecuperarCupomFiscalLC_Integracao_Xml

            self:lSucesso := .F.
            self:cTipoRet := "RMIBUSLIVEOBJ"
            self:cRetorno := I18n(STR0001, { ProcName(), "SetOperation", self:oBusca:cError} )      //"[#1] Problema ao efetuar o #2: #3"
        Else
            
            //Envia a mensagem a ser processada
            If self:oBusca:SendSoapMsg(self:cBody)

                self:cRetorno := self:oBusca:GetSoapResponse()
                self:cRetorno := StrTran(self:cRetorno, "&lt;", "<")
                self:cRetorno := StrTran(self:cRetorno, "&gt;", ">")

                //Pesquisa a tag com o retorno das vendas
                cAux := RmiXGetTag(self:cRetorno, self:oConfProce["tagretorno"], .T.)
                LjGrvLog("RMIBUSLIVEOBJ","RmiXGetTag - retorno (cAux):",cAux)

                //O xml (cAux) do cliente é retonado sem LC_ClienteSaida gerando erro caso continue. 
                cDocCad:= RmiXGetTag(self:cRetorno,"<Documentos>", .T.)//caso nao retorne documentos não deve continuar
                LjGrvLog("RMIBUSLIVEOBJ","RmiXGetTag - retorno (cDocCad):",cDocCad)

                If Empty(cAux)
                    self:lSucesso := .F.
                    self:cTipoRet := "RMIBUSLIVEOBJ"
                    self:cRetorno := I18n(STR0002, { ProcName(), self:oConfProce["tagretorno"], self:cRetorno} )    //"[#1] Não foi localizada a TAG #2: #3"

                //caso não exista mais integração para recuperar                    
                ElseIf Empty(cDocCad) .And. !Empty(cAux)
                    self:lSucesso := .F.
                    self:cTipoRet := "RMIBUSLIVEOBJ"
                    self:cRetorno := "Não existe dados a serem importados."

                Else

                    self:cRetorno := cAux                    
                    self:oRetorno := XmlParser(self:cRetorno, "_", @cError, @cWarning)
                    self:cRetorno := ""

                    If self:oRetorno == Nil
                        self:lSucesso := .F.
                        self:cTipoRet := "RMIBUSLIVEOBJ"
                        self:cRetorno := I18n(STR0001, { ProcName(), "XmlParser", cError +"\"+ cWarning +"\"+ cAux} )      //"[#1] Problema ao efetuar o #2: #3"
                    Else
                        //Centraliza os retorno permitidos
                        self:TrataRetorno()
                    EndIf
                EndIf
            Else

                self:lSucesso := .F.
                self:cTipoRet := "RMIBUSLIVEOBJ"
                self:cRetorno := I18n(STR0001, { ProcName(), "SendSoapMsg", self:oBusca:cError} )   //"[#1] Problema ao efetuar o #2: #3"

                //Limpa token para pegar um novo                                 
                self:cToken := ""
                self:SalvaConfig()
            EndIf

        EndIf

    EndIf

 Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBusLiveObj

    //Todos os processos de busca do Live já estão entrando para a Fila. (Venda, Nota de Entrada e Cadastros)
    self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo que centraliza os retorno permitidos

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusLiveObj

    Local cProcesso := AllTrim(self:cProcesso)

    Do Case 

        Case cProcesso == "VENDA"
            self:Venda()

        Case cProcesso == "NOTA DE ENTRADA"
            self:NotaEntrada()

        OTherWise
            self:Cadastros()
            
    End Case

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Venda
Metodo para carregar a publicação de venda

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Venda() Class RmiBusLiveObj

    Local nVenda        := 0
    Local cSituacao     := ""
    Local aRetorno      := {}
    self:cNewChv       := ""
    
    //Chave utilizada para efetuar a confirmação do recebimento das vendas
    self:cConfirma := self:oRetorno:_LC_TicketCupomFiscal:_Numero:Text

    If self:cConfirma == Nil .Or. Empty(self:cConfirma)
        self:lContinuaBusca := .F.
        self:lSucesso       := .F.
        self:cTipoRet       := "RMIBUSLIVEOBJ"
        self:cRetorno 		:= I18n(STR0003, { ProcName(), self:cRetorno} )   //"[#1] Não há vendas a serem baixadas: #2"
    Else

        LjGrvLog("RMIBUSLIVEOBJ", "Efetua a busca de vendas")

        //Ativa para efetuar busca novamente
        self:lContinuaBusca := .T.
        
        If ValType(self:oRetorno:_LC_TicketCupomFiscal:_Documentos:_LC_CupomFiscal) == 'A'
            aRetorno := aClone( self:oRetorno:_LC_TicketCupomFiscal:_Documentos:_LC_CupomFiscal )
        Else
            Aadd(aRetorno, self:oRetorno:_LC_TicketCupomFiscal:_Documentos:_LC_CupomFiscal )
        EndIf

        //Processa as vendas
        For nVenda:=1 To Len(aRetorno)

            //Carrega informações da publicação que será gerada   
            
            self:cNewChv := IIf(MHQ->(FieldPos('MHQ_IDEXT')) > 0,"",self:cConfirma + "|")
     
            self:oRegistro   := aRetorno[nVenda]
            self:cChaveUnica := ""
            self:lSucesso    := .T.
            self:cEvento     := ""
            self:cRetorno    := ""
            cSituacao        := AllTrim( self:oRegistro:_Situacao:Text )
            
            //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
            self:setChaveUnica()

            //Evento da publicação 1=Upsert, 2=Delete, 3=Inutilizado (MHQ_EVENTO)
            Do Case

                //Nota normal: Situação = A
                Case cSituacao == "A"
                    self:cEvento := "1"

                Case cSituacao == "C"

                    //Inutilização: Situação = C + Tag Inutilizado preenchida
                    If ( Upper( AllTrim(self:oRegistro:_SituacaoNFCe:Text) ) == "INUTILIZADO" )                        .Or.;
                       ( Empty(self:oRegistro:_ChaveNFCe:Text) .And. Empty(self:oRegistro:_ChaveNFCeCancelada:Text) )
                        self:cEvento := "3"

                    //Cancelamento: Situação = C + Tag Inutilizado em vazia
                    Else
                        self:cEvento := "2"
                    EndIf

                OTherWise

                    self:lSucesso := .F.
                    self:cTipoRet := "RMIBUSLIVEOBJ"
                    self:cRetorno := I18n( STR0005, {self:oRegistro:_Numero:Text, "<Numero>", cSituacao, "<SituacaoNFCe>"} )    //"Venda [#1] (tag #2) não será processada, está com situação desconhecida [#3] (tag #4)."

            End Case

            //Carrega a mensagem original
            SAVE self:oRegistro XMLSTRING self:cMsgOrigem
            self:cMsgOrigem := StrTran(self:cMsgOrigem, ">>", ">")  //Ao salvar o XML como string estava deixando '>>' em alguns momentos
            
            If self:AuxExistePub()
                Loop
            EndIf
            If ALLTRIM(self:oRegistro:_SiglaModelo:Text) == '59' .AND. (!FwIsNumeric(self:oRegistro:_NumeroImpressora:Text);
             .OR. Len(self:oRegistro:_NumeroImpressora:Text) != 9) //9 tamanho padrão na documentação tag nserieSAT
                self:lSucesso := .F.
                self:cRetorno := "Tag: NumeroImpressora fora do padrão de dados para numero de serie do equipamento NFCE/SAT : ";
                +self:oRegistro:_NumeroImpressora:Text    
            EndIf
            //Grava a publicação            
            self:Grava()

            //Limpa objeto da publicação
            FwFreeObj(self:oRegistro)
            self:oRegistro := Nil
            
        Next nVenda

        LjGrvLog("RMIBUSLIVEOBJ", "Final da busca de vendas")
    EndIf

    ASize(aRetorno, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NotaEntrada
Metodo para carregar a mensagem de origem da publicação de nota de entrada

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method NotaEntrada() Class RmiBusLiveObj

    Local nRegistro := 0
    Local aRetorno  := {}
    Local cTipoRet  := ""
    //Chave utilizada para efetuar a confirmação do recebimento das vendas
    self:cConfirma := self:oRetorno:_LC_TicketNotaFiscal:_Numero:Text

    If self:cConfirma == Nil .Or. Empty(self:cConfirma)
        self:lContinuaBusca := .F.
        self:lSucesso       := .F.
        self:cTipoRet       := "RMIBUSLIVEOBJ"
        self:cRetorno 		:= I18n("[#1] Não há notas de entrada a serem baixadas: #2", { ProcName(), self:cRetorno} )   //"[#1] Não há notas de entrada a serem baixadas: #2"
    Else

        LjGrvLog("RMIBUSLIVEOBJ", "Carregando publicações de nota de entrada - Inicio")

        //Ativa para efetuar busca novamente
        self:lContinuaBusca := .T.
        
        If ValType(self:oRetorno:_LC_TicketNotaFiscal:_Documentos:_LC_NotaFiscal) == 'A'
            aRetorno := aClone( self:oRetorno:_LC_TicketNotaFiscal:_Documentos:_LC_NotaFiscal )
        Else
            Aadd(aRetorno, self:oRetorno:_LC_TicketNotaFiscal:_Documentos:_LC_NotaFiscal )
        EndIf

        //Processa as vendas
        For nRegistro:=1 To Len(aRetorno)

            //Carrega informações da publicação que será gerada            
            self:oRegistro   := aRetorno[nRegistro] 
            self:cChaveUnica := ""
            self:lSucesso    := .T.
            self:cEvento     := IIF( AllTrim( Upper(self:oRegistro:_Situacao:Text) ) == "CANCELADA", "2", "1" )     //Situação LIVE: Integrada, Pendente Integracao ou Cancelada
            self:cRetorno    := ""

            //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
            self:setChaveUnica()

            //Restrição para carregar só nota de entrada
            If AllTrim( Upper(self:oRegistro:_TipoNota:Text) ) <> "ENTRADA"
                Loop
            EndIf

            //Restrição para carregar só devolução
            If !( "DEVOLUCAO" $ AllTrim( Upper( NoAcento(self:oRegistro:_TipoDocumento:_LC_TipoDocumentoNotaFiscal:_Descricao:Text) ) ) ) .Or.;
               Empty(self:oRegistro:_IDDoctoOrigem:Text)
                Loop
            EndIf

            //Carrega a mensagem original
            SAVE self:oRegistro XMLSTRING self:cMsgOrigem
            self:cMsgOrigem := StrTran(self:cMsgOrigem, ">>", ">")  //Ao salvar o XML como string estava deixando '>>' em alguns momentos

            //Verifica se a venda já foi publicada
            If self:AuxExistePub()
                Loop
            EndIf
            
            If Alltrim(self:oRegistro:_NumeroControle:Text) == "0" //Pular caso numero de controle seja zero
                self:cRetorno := "Nota de entrada nao integrada " 
                self:cRetorno += "o Numero de controle esta com conteudo igual a zero : '0'  numero do ticket :"+Self:cConfirma
                self:cRetorno += " - Data Emissao: "+self:oRegistro:_DataEmissao:Text
                self:cRetorno += " - Data Movimento: "+self:oRegistro:_DataMovimento:Text
                self:cRetorno += " - Loja: "+self:oRegistro:_CodigoLoja:Text
                self:cRetorno += " - Serie:"+self:oRegistro:_Serie:Text
                self:cRetorno += " - Numero Nota Fiscal:"+self:oRegistro:_NumeroNotaFiscal:Text
                cTipoRet := "NOTA DE ENTRADA"
                LjGrvLog(cTipoRet,self:cRetorno)
                //Pular a nota pois não deverá ser integrada
                self:cRetorno := ""
                Loop
            EndIf    
            //Grava a publicação            
            self:Grava()

            //Limpa objeto da publicação
            FwFreeObj(self:oRegistro)
            self:oRegistro := Nil
            
        Next nRegistro

        LjGrvLog("RMIBUSLIVEOBJ", "Carregando publicações de nota de entrada - Fim")
    EndIf

    ASize(aRetorno, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirmação do recebimento

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma() Class RmiBusLiveObj

    Local cBody     := ""
    Local cAux      := ""
    Local cError    := ""
    Local cWarning  := ""

    //Para conferencia não exite confirmação de Ticket
    If Alltrim(self:cConfirma) == '0' .Or. Empty(Alltrim(self:cConfirma))
        self:lContinuaBusca := .F.
        Return   
    EndIf
    
    Self:oEnvia := RMIConWsdl(self:oConfProce["url"], @cError)

    //Faz o parse de uma URL
    If !Empty(cError)
        self:lSucesso := .F.
        self:cRetorno := I18n(STR0001, { ProcName(), "ParseUrl", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
        LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
    Else

        //Seta a operação que será executada
        If !self:oEnvia:SetOperation("ConfirmarTicketLC_Integracao")
            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, { ProcName(), "SetOperation", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
            LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
        Else

            cBody := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/' xmlns:ren='http://schemas.datacontract.org/2004/07/Rentech.Framework.Data' xmlns:ren1='http://schemas.datacontract.org/2004/07/Rentech.PracticoLive.Connector.Objects' xmlns:arr='http://schemas.microsoft.com/2003/10/Serialization/Arrays'>"
            cBody +=	"<soapenv:Header/>"
            cBody += 	"<soapenv:Body>"
            cBody += 		"<liv:ConfirmarTicketLC_Integracao>"
            cBody += 			"<liv:confirmacaoTicket>"
            cBody += 				"<ren1:Chave>" + self:oLive:getToken(self) + "</ren1:Chave>"
            cBody += 				"<ren1:CodigoSistemaSatelite>" + self:oLive:getSatelite(self) + "</ren1:CodigoSistemaSatelite>"
            cBody += 				"<ren1:NumeroTicket>" + self:cConfirma + "</ren1:NumeroTicket>"
            cBody += 				"<ren1:SituacaoTicketSaida>EnvioConfirmado</ren1:SituacaoTicketSaida>"
            cBody += 			"</liv:confirmacaoTicket>"
            cBody += 		"</liv:ConfirmarTicketLC_Integracao>"
            cBody += 	"</soapenv:Body>"
            cBody += "</soapenv:Envelope>"

            //Envia a mensagem a ser processada
            If self:oEnvia:SendSoapMsg(cBody)

                self:cRetorno := self:oEnvia:GetSoapResponse()
                cAux := RmiXGetTag(self:cRetorno, "<s:Body>", .T.)

                self:oRetorno := XmlParser(cAux, "_", @cError, @cWarning)

                If self:oRetorno <> Nil
                    self:oRetorno := XmlChildEx(self:oRetorno, "_S_BODY")
                EndIf                    

                If self:oRetorno == Nil .Or. XmlChildEx(self:oRetorno, "_CONFIRMARTICKETLC_INTEGRACAORESPONSE") == Nil
                    self:lSucesso := .F.
                    self:cRetorno := I18n(STR0004, { ProcName(), self:cConfirma, self:cRetorno} )   //"[#1] Problema ao efetuar a confirmação do ticket #2: #3"
                    LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
                EndIf
            Else
                self:lSucesso := .F.
                self:cRetorno := I18n(STR0001, { ProcName(), "SendSoapMsg", self:oEnvia:cError} )   //"[#1] Problema ao efetuar o #2: #3"
                LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
            EndIf
        EndIf
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Cadastros
Metodo para carregar a publicação de Cadastros

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method Cadastros() Class RmiBusLiveObj

    Local nCad      := 0
    Local aTags     := self:oLayoutPub:GetNames()   //Retorno o nome das tags do objeto publica
    Local aTagsSec  := {}
    Local aTagsTri  := {}
    Local aCmpsTri  := {}    
    Local aNoFilho  := {}                           //Array do No Filho com os itens que serão procesasdos
    Local xNoFilho  := Nil                          //Objeto do No Filho com os itens que serão procesasdos
    Local nAte      := 1
    Local cDocId    := ""
    Local cTagRet   := ""
    Local nX        := 0
    
    //Chave utilizada para efetuar a confirmação do recebimento de cadastro//LC_TicketClienteSaida
    cTagRet :="self:oRetorno:_"+self:oConfProce["tagretorno"]
    cTagRet :=StrTran(cTagRet, "<", "")
    cTagRet :=StrTran(cTagRet, ">", "")
    self:cConfirma := &(cTagRet+":_Numero:Text")

    If self:cConfirma == Nil .Or. Empty(self:cConfirma)
        self:lContinuaBusca := .F.
        self:lSucesso       := .F.
        self:cRetorno 		:= I18n(STR0003, { ProcName(), self:cRetorno} )   //"[#1] Não há vendas a serem baixadas: #2"
        LjGrvLog("RMIBUSLIVEOBJ",self:cRetorno)
    Else
        LjGrvLog("RMIBUSLIVEOBJ","Efetua a busca de Cadastros")

        //Ativa para efetuar busca novamente
        self:lContinuaBusca := .T.
        cDocId := cTagRet+":_Documentos:_"+self:oConfProce["documentoId"]
        If ValType(&(cDocId)) == 'A'
            nAte:= Len(&(cDocId))// cDocId = self:oRetorno:_LC_TicketClienteSaida:_Documentos:_LC_ClienteSaida
        endIf

        //Processa as vendas
        For nCad:=1 To nAte

            self:lSucesso    := .T.
            self:cRetorno    := ""
            self:cChaveUnica := ""

            //Carrega informações da publicação que será gerada 
            self:oRegistro      := IIF(nAte>1,&cDocId[nCad],&cDocId)    //Objeto que poderá ser utilizado para gerar o layout da publicação. (MHP_LAYPUB)
            self:cEvento        := "1"                                  //IIF(self:oRegistro:_Situacao:Text == "A", "1", "2")       //Evento da publicação 1=Upsert, 2=Delete (MHQ_EVENTO) - Live: A = Nota normal, C= Nota cancelada

            //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
            self:setChaveUnica()
            
            //Carrega a mensagem original
            SAVE self:oRegistro XMLSTRING self:cMsgOrigem
            self:cMsgOrigem := StrTran(self:cMsgOrigem, ">>", ">")  //Ao salvar o XML como string estava deixando '>>' em alguns momentos    
            
            If AllTrim(self:cProcesso) == "SANGRIA" 
                //No live são gerados dois registros no fechamento do caixa.
                //O primeiro registro vem com valor conferido igual a Zero então nesse ponto descartamos essa msg.
                If XmlChildEx( self:oRegistro:_PAGAMENTOSMOVIMENTOCAIXA,"_LC_PAGAMENTOMOVIMENTOCAIXA") <> NIL
                    If !Val(PagMovCx(self:oRegistro:_PAGAMENTOSMOVIMENTOCAIXA:_LC_PAGAMENTOMOVIMENTOCAIXA)) > 0
                        Loop
                    EndIf
                Else
                    Loop
                EndIf        
            EndIf
            //Não aceitar registros de funcionarios que não sejam <Cargo>OPERADOR</Cargo>
            If AllTrim(self:cProcesso) == "OPERADOR CAIXA"
                If UPPER(ALLTRIM(self:oRegistro:_CARGO:Text)) <> "OPERADOR"
                    Loop 
                EndIf        
            EndIf
            //Verifica se a venda já foi publicada
            If Self:ReproCli(self:AuxExistePub())//se for live e o cliente processou com erro deletar e aceitar novo registro.  
                /*No XML do Live, o registro de administradora vem separado em varios itens da tag LC_BandeiraCartao,
                por conta disso, foi necessario permitir inserir na tabela MHQ o mesmo código no campo MHQ_CHVUNI
                e realizar o tratamento antes de enviar para o execauto do LOJA070, caso o registro já exista apenas altera,
                caso contrário inclui uma nova adm financeira.*/
                If AllTrim(self:cProcesso) == 'ADMINISTRADORA'
                    Sleep(1000)
                Else
                    Loop
                EndIf
            EndIf           
            
            If Alltrim(Self:cProcesso) <> "CLIENTE" // Outros Processos a tag não existe
                self:Grava()
            ElseIf Valtype(self:oRegistro:_TIPOCLIENTE:Text) <> "U" .and. UPPER(self:oRegistro:_TIPOCLIENTE:Text) <> "INFORMAL"  //Processo Cliente
                LjGrvLog("RMIBUSLIVEOBJ","Gravando MHQ de CLIENTE Fisico ou Juridico")
                self:Grava()
            Else
                LjGrvLog("RMIBUSLIVEOBJ","Tipo de Cliente Informal <TIPOCLIENTE> não sera gravado na tabela MHQ ")
            EndIf    

            //Limpa objeto da publicação
            FwFreeObj(xNoFilho)
            FwFreeObj(self:oRegistro)
            FwFreeObj(self:oPublica)
            xNoFilho        := Nil
            self:oRegistro  := Nil
            self:oPublica   := Nil
            
            If ValType(aNoFilho) == "A"
                Asize(aNoFilho, 0)
            EndIf
            Asize(aTagsSec, 0)
            Asize(aTagsTri, 0)
            Asize(aCmpsTri, 0)

        Next nCad
    EndIf

    Asize(aTags, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaMetodoRepro
Metodo não é implementado para o LiveConector apenas para o Totvs Chef

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method AjustaJsonRepro() Class RmiBusLiveObj
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAuto
Metodo que Retorna informações da SLG a partir do campo recebido no parâmetro cCmpRet ou cadastra a SLG
Cadastra a estação AUTOMATICO caso seja necessário.
Utilizado no layout

@param cCmpRet      - Nome do campo que irá retornar LG_SERIE, LG_PDV

@return cRetorno    - Caracter com a serie ou pdv 
				
@author  Danilo Rodrigues
@since 	 29/10/2020
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Method LayEstAuto(cCmpRet, cModelo, cSerie, cEstacao, cCodLoja) Class RmiBusLiveObj

    Local cRetorno  := ""

    Default cModelo   := self:oRegistro:_SiglaModelo:Text
    Default cSerie    := self:oRegistro:_SerieNFCe:Text
    Default cEstacao  := self:oRegistro:_NumeroImpressora:Text
    Default cCodLoja  := self:oRegistro:_CodigoLoja:Text

    LjGrvLog("ESTAÇÃO", "Dados recebidos para retorno de serie automática: cModelo, cSerie, cEstacao, cCodLoja", {cModelo, cSerie, cEstacao, cCodLoja})

    self:cModelo    := cModelo
    self:cModelo    := IIF(self:cModelo == "59", "1", self:cModelo) //SAT
    self:cModelo    := IIF(self:cModelo $ "65;55", "2", self:cModelo) //NFC-E e NFE
    self:cModelo    := IIF(Empty(self:cModelo) , "4", self:cModelo)

    self:cCodLoja   := PadR( self:DePara("SM0", cCodLoja, 1, 0), TamSX3("LG_FILIAL")[1] )
    self:cEstacao   := cEstacao
    self:cSerie     := IIF( self:cModelo == "1", "", cSerie )       //Se for SAT deixa vazia a serie para não tentar gerar estação com serie 0

    cRetorno := _Super:LayEstAuto(cCmpRet)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Metodo responsavel por liberar os tickets novamente para efetuar o
reprocessamento novamente na busca.

@type   method
@param  cProcesso, Caractere, Processo que terá o tickets liberados novamente
@param  oJsParams, JsonObject, Tickets que serão liberados

@author  Rafael Tenorio da Costa
@since 	 27/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnvReproc(cProcesso, oJsParams) Class RmiBusLiveObj

    Local cAux       := ""
    Local lReenvia   := .T.
    Local nVez       := 0
    Local cBody      := ""
    Local nTickets   := 1
    Local cTipTicket := ""
    Local cOperacao  := "AtualizarStatusTicketLC_Integracao_Xml"
    Local cError     := ""
    Local aOperacao  := {}
    Local cOperRepro := Substr(self:oConfProce["operacao"],1,At("LC_Integracao_Xml",self:oConfProce["operacao"])-1)
    Local nOper      := 0
    Local nCont      := 0

    aAdd(aOperacao,{"3" ,"RecuperarCupomFiscal"})
    aAdd(aOperacao,{"4" ,"RecuperarReducaoZ"})
    aAdd(aOperacao,{"5" ,"RecuperarInventario"})
    aAdd(aOperacao,{"12" ,"RecuperarPedidoCompra"})
    aAdd(aOperacao,{"13" ,"RecuperarNotaFiscal"})
    aAdd(aOperacao,{"14" ,"RecuperarNotaEspelho"})
    aAdd(aOperacao,{"15" ,"RecuperarNotaEspelho"})
    aAdd(aOperacao,{"17" ,"RecuperarCupomFiscalCodigoPromocional"})
    aAdd(aOperacao,{"20" ,"RecuperarImpressoraFiscal"})
    aAdd(aOperacao,{"22" ,"RecuperarPreVenda"})
    aAdd(aOperacao,{"23" ,"RecuperarRegistroInventarioP7"})
    aAdd(aOperacao,{"24" ,"RecuperarRegistroMovimentacaoP3"})
    aAdd(aOperacao,{"25" ,"RecuperarArquivoMasterSAF"})
    aAdd(aOperacao,{"26" ,"RecuperarSaldoEstoque"})
    aAdd(aOperacao,{"32" ,"RecuperarPreVendaRPSSituacao"})
    aAdd(aOperacao,{"34" ,"RecuperarProduto"})
    aAdd(aOperacao,{"35" ,"RecuperarPrecoProduto"})
    aAdd(aOperacao,{"36" ,"RecuperarEstoqueProduto"})
    aAdd(aOperacao,{"37" ,"RecuperarFuncionario"})
    aAdd(aOperacao,{"38" ,"RecuperarDespesasContasPagar"})
    aAdd(aOperacao,{"39" ,"RecuperarIrregularidade"})
    aAdd(aOperacao,{"42" ,"RecuperarXmlNotaFiscal"})
    aAdd(aOperacao,{"43" ,"RecuperarXmlCupomFiscal"})
    aAdd(aOperacao,{"45" ,"RecuperarFormaPagamento"})
    aAdd(aOperacao,{"46" ,"RecuperarBandeiraCartao"})
    aAdd(aOperacao,{"47" ,"ClassificadorProduto"})
    aAdd(aOperacao,{"48" ,"ProdutoSaidaEcommerce"})
    aAdd(aOperacao,{"49" ,"SaldoEstoqueEcommerce"})
    aAdd(aOperacao,{"50" ,"PrecoProdutoEcommerce"})
    aAdd(aOperacao,{"51" ,"TotalizadorVenda"})
    aAdd(aOperacao,{"54" ,"RecuperarUnidadesDeNegocio"})
    aAdd(aOperacao,{"55" ,"RecuperarCartaConsentimento"})
    aAdd(aOperacao,{"56" ,"RecuperarListaTickets"})

    If (nOper := AScan(aOperacao,{|x| Alltrim(x[2]) == cOperRepro} )) > 0
        cTipTicket := aOperacao[nOper][1]
    Else
        self:lSucesso := .F.
        self:cRetorno := "TipoTicket inválido ou não encontrado"  
    EndIf

    If self:lSucesso

        Self:oEnvia := RMIConWsdl(self:oConfProce["url"], @cError)

        //Faz o parse de uma URL
        If !Empty(cError)

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, { ProcName(), "ParseUrl", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
        Else

            //Seta a operação que será executada
            If !self:oEnvia:SetOperation(cOperacao)

                self:lSucesso := .F.
                self:cRetorno := I18n(STR0001, { ProcName(), "SetOperation", self:oEnvia:cError} )      //"[#1] Problema ao efetuar o #2: #3"
            Else

                While self:lSucesso .and. ( lReenvia .Or. nTickets <= Len(oJsParams["tickets"]) )

                    //Controle de reenvio com geração de novo token
                    lReenvia := .F.
                    nVez++

                    cBody := "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:liv='http://LiveConnector/'>"
                    cBody += "<soapenv:Header/>"
                    cBody += 	"<soapenv:Body>"
                    cBody += 		"<liv:AtualizarStatusTicketLC_Integracao_Xml>"
                    cBody += 		"<liv:codigoSistemaSatelite>" + self:oLive:getSatelite(self) + "</liv:codigoSistemaSatelite>"
                    cBody += 		"<liv:identificacao>"
                    cBody += 			"<![CDATA[<?xml version='1.0'?>"
                    cBody += 				"<LC_AtualicaoTicket>"
                    cBody += 					"<Chave>" + self:oLive:getToken(self) + "</Chave>"
                    cBody += 					"<CodigoSistemaSatelite>" + self:oLive:getSatelite(self) + "</CodigoSistemaSatelite>"
                    cBody += 					"<TipoTicket>" + cTipTicket + "</TipoTicket>"
                    cBody += 					"<Status>1</Status>"
                    cBody += 					"<ListaTickets>"

                    //Limite do LIVE é de 100 tickets por envio
                    nCont := 0
                    While nTickets <= Len(oJsParams["tickets"]) .And. nCont < 100 
                        cBody += 				    "<LC_Ticket>"
                        cBody += 				    	"<Numero>" + allTrim(oJsParams["tickets"][nTickets]) + "</Numero>"
                        cBody += 				    "</LC_Ticket>"

                        nTickets++
                        nCont++
                    EndDo

                    cBody += 					"</ListaTickets>"
                    cBody += 				"</LC_AtualicaoTicket>"
                    cBody += 			"]]>"
                    cBody += 		"</liv:identificacao>"
                    cBody += 		"</liv:AtualizarStatusTicketLC_Integracao_Xml>"
                    cBody += 	"</soapenv:Body>"
                    cBody += "</soapenv:Envelope>"

                    //Envia a mensagem a ser processada
                    cBody := EnCodeUtf8(cBody)
                    LjGrvLog("RMIBUSLIVEOBJ", "Envio Reprocessamento - SendSoapMsg.", {cOperacao, cBody})
                    If self:oEnvia:SendSoapMsg(cBody)

                        //Zera o controle de reenvio por causa de chave inválida
                        nVez := 0

                        self:cRetorno := DeCodeUtf8( self:oEnvia:GetSoapResponse() )
                        self:cRetorno := StrTran(self:cRetorno, "&lt;", "<")
                        self:cRetorno := StrTran(self:cRetorno, "&gt;", ">")

                        LjGrvLog("RMIBUSLIVEOBJ", "Retorno Reprocessamento - OK.", self:cRetorno)

                        //Pesquisa a tag com o retorno das vendas
                        cAux := RmiXGetTag(self:cRetorno, "<AtualizarStatusTicketLC_Integracao_XmlResult>", .T.)

                        If !Empty(cAux)

                            self:lSucesso := .T.
                            self:cRetorno := cAux
                            self:oConfAssin["data_reprocessamento"] := DTOC(Date())                          
                        Else

                            self:lSucesso := .F.
                            self:cRetorno := I18n(STR0006, { ProcName(), cOperacao, self:cRetorno} )  //"[#1] Retorno desconhecido, na operação #2: #3"
                        EndIf
                        
                    Else

                        self:cRetorno := DeCodeUtf8(self:oEnvia:cError)

                        LjGrvLog("RMIBUSLIVEOBJ", "Retorno Reprocessamento - ERRO.", self:cRetorno)                        

                        If "CHAVE DE ACESSO INV" $ Upper(self:cRetorno)

                            If nVez > 1

                                self:lSucesso := .F.
                                self:cRetorno := I18n(STR0007, {ProcName(), self:cRetorno} )    //"[#1] Chave de Acesso já foi gerada, mas erro persiste: #2"
                            Else
                                
                                //Volta para primeiro ticket para efetuar o tentativa com a nota chave
                                nTickets := 1

                                //Gera novo token para tentar o reenvio
                                lReenvia    := .T.
                                self:cToken := ""
                                
                                self:PreExecucao() 

                                If !self:lSucesso
                                    Exit
                                EndIf
                            EndIf

                        Else                        

                            self:lSucesso := .F.
                            self:cRetorno := I18n(STR0001, { ProcName(), "SendSoapMsg", self:cRetorno} )   //"[#1] Problema ao efetuar o #2: #3"
                        EndIf
                    EndIf
                EndDo

                //Atualiza a configuração do assinante, com o novo token gerado
                If self:lSucesso
                    self:SalvaConfig()
                EndIf
            EndIf
        EndIf
    EndIf
    If !self:lSucesso
        //Gera log de erro    
        self:getRetorno()
    EndIf
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ReproCli 
Esse metodo tem a responsabilidade em verificar se o registro da MHQ
está processado com erro para aceitar nova busca no live e gravar
novos registros.
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method ReproCli(lDefault) Class RmiBusLiveObj

Local aArea     := GetArea()
Local aAreaMHQ  := MHQ->(GetArea())
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lRet      := .T. //Variavel de retorno
Local lExiste := .F. 
Local cChave  := xFilial("MHQ") + PadR(self:cOrigem, TamSx3("MHQ_ORIGEM")[1]) + PadR(self:cProcesso, TamSx3("MHQ_CPROCE")[1]) + PadR(self:cChaveUnica, TamSx3("MHQ_CHVUNI")[1])

If Alltrim(self:cProcesso) != 'CLIENTE' .OR. !lDefault // se o Default for falso cliente nao exite retornar default.
    LjGrvLog("ReproCli", "Processo não é de cliente retornando o resultado do Method self:AuxExistePub", lDefault)
    Return lDefault //Default é o resultado do Method self:AuxExistePub
EndIf


MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
lExiste := MHQ->( DbSeek(cChave + self:cEvento) )

If lExiste 

    cQuery := "SELECT MHQ.R_E_C_N_O_ MHQREC,MHR.R_E_C_N_O_ MHRREC,MHL.R_E_C_N_O_ MHLREC,MHQ_STATUS,MHR_STATUS "
    cQuery += " FROM " + RetSqlName("MHQ") + " MHQ "
    cQuery += " LEFT JOIN " + RetSqlName("MHR") + " MHR "
    cQuery += " ON MHR.MHR_UIDMHQ = MHQ.MHQ_UUID "
    cQuery += " AND MHR.D_E_L_E_T_ != '*'"
    cQuery += " LEFT JOIN " + RetSqlName("MHL") + " MHL "
    cQuery += " ON MHL.MHL_UIDORI = MHQ.MHQ_UUID "
    cQuery += " AND MHL.D_E_L_E_T_ != '*'"
    cQuery += " WHERE MHQ.MHQ_UUID = '" + MHQ->MHQ_UUID + "'"
    cQuery += " AND MHQ.MHQ_CPROCE = 'CLIENTE' "
    cQuery += " AND MHQ.MHQ_ORIGEM != 'PROTHEUS' "
    cQuery += " AND MHQ.D_E_L_E_T_ != '*'"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
    
    
    If (cAlias)->MHQ_STATUS == '3' .OR. (cAlias)->MHR_STATUS == '3'
        LjGrvLog("ReproCli", "Exclusão de Publicação cliente (MHQ)" ,(cAlias)->MHQREC)
        MHQ->(dbGoto((cAlias)->MHQREC))
        RecLock("MHQ",.F.)
            MHQ->( DbDelete() ) //Deleta o Registro na MHQ
        MHQ->( MsUnLock() )
        lExiste := .F.
    EndIf
    
    If (cAlias)->MHR_STATUS == '3'
        LjGrvLog("ReproCli", "Exclusão de Distribuilçao cliente (MHR)" ,(cAlias)->MHRREC)
        MHR->(dbGoto((cAlias)->MHRREC))
        RecLock("MHR",.F.)
            MHR->( DbDelete() ) //Deleta o Registro na MHQ
        MHR->( MsUnLock() )
        lExiste := .F.
    EndIf
    
    If ((cAlias)->MHR_STATUS == '3' .OR. (cAlias)->MHQ_STATUS == '3') .AND. (cAlias)->MHLREC > 0
        LjGrvLog("ReproCli", "Exclusão de LOG Publicação cliente (MHL)" ,(cAlias)->MHLREC)
        MHL->(dbGoto((cAlias)->MHLREC))
        RecLock("MHL",.F.)
            MHL->( DbDelete() ) //Deleta o Registro na MHQ
        MHL->( MsUnLock() )
        lExiste := .F.
    EndIf
    lRet := lExiste
    (cAlias)->( DbCloseArea() )
EndIf

RestArea(aArea)
RestArea(aAreaMHQ)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setChaveUnica 
Metodo que atualiza a propriedade cChaveUnica a partir da configuração do processo. oConfProce["ChaveUni"]

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method setChaveUnica() Class RmiBusLiveObj
Local nX := 0

If Valtype(self:oConfProce["ChaveUni"]) == "A"
    For nX := 1 To Len(self:oConfProce["ChaveUni"])
        If XmlChildEx( self:oRegistro,"_"+UPPER(self:oConfProce["ChaveUni"][nX])) <> NIL 
            self:cChaveUnica    += &("self:oRegistro:_"+self:oConfProce["ChaveUni"][nX]+":Text")+"|"    
        Else
            self:cChaveUnica    += &(self:oConfProce["ChaveUni"][nX])+"|"        
        EndIf
    next
Else
    self:cChaveUnica    := &("self:oRegistro:_"+self:oConfProce["ChaveUni"]+":Text")+"|" //Chave única do registro publicado. (MHQ_CHVUNI)
EndIf
If nX > 0
    self:cChaveUnica  := SubStr(self:cChaveUnica,1,Len(self:cChaveUnica)-1)
EndIf    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LayDocOri
Metodo que retorna o numero do documento fiscal de origem

@type    method

@param   nItem, Numérico, Numero do item no array _Lc_ItemNotaFiscal que esta sendo macro executado
@param   cCmpRet, Caractere, Utilizado para retorno de campo no layout
@author  Rafael Tenorio da Costa
@since   16/01/2023
@version 12.1.2310
/*/
//--------------------------------------------------------------------
Method LayDocOri(nItem, cCmpRet) Class RmiBusLiveObj

    Local aArea     := GetArea()
    Local cSql      := "" 
    Local cRetorno  := ""
    Local oItem     := IIF( ValType(self:oRegistro:_Itens:_Lc_ItemNotaFiscal) == "O", self:oRegistro:_Itens:_Lc_ItemNotaFiscal, self:oRegistro:_Itens:_Lc_ItemNotaFiscal[nItem] )
    Local cSerOri   := self:LayEstAuto('LG_SERIE', SubStr(oItem:_ChaveAcessoOrigem:Text, 21, 2), oItem:_SerieDoctoOrigem:Text, oItem:_SerieEquipamentoOrigem:Text, oItem:_CNPJLojaOrigem:Text)
    Local cFilOri   := self:DePara('SM0', oItem:_CNPJLojaOrigem:Text, 1, 0)
    Local aSql      := {}
    Local nCount    := 0         

    Default cCmpRet := ""

    cSql := " SELECT D2_DOC, D2_ITEM, (D2_QUANT - D2_QTDEDEV) AS SALDO"
    cSql += " FROM " + RetSqlName("SD2")
    cSql += " WHERE D_E_L_E_T_ = ' '"
    cSql +=     " AND D2_FILIAL = '" + cFilOri + "'"    
    cSql +=     " AND CAST(D2_DOC AS INT) = '" + cValtoChar(Val(oItem:_NumeroDoctoOrigem:Text)) + "'"     
    cSql +=     " AND D2_SERIE = '" + cSerOri + "'"
    cSql +=     " AND D2_COD = '" + oItem:_CodigoProduto:Text + "'"
    cSql +=     " ORDER BY D2_ITEM"

    aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    If Len(aSql) > 0
        For nCount := 1 to Len(aSql)
            If (aSql[nCount][3] >= Val(oItem:_Quantidade:Text) )
                If cCmpRet == "D1_NFORI"
                    cRetorno := aSql[nCount][1]
                    Exit
                elseIf cCmpRet == "D1_ITEMORI"
                    cRetorno := aSql[nCount][2]
                    Exit
                EndIf
            Else
                self:lSucesso := .F.
                self:cTipoRet := "DOCORI"
                self:cRetorno += "Quantidade solicitada " + oItem:_Quantidade:Text + " para troca não confere com a nota fiscal numero: " + aSql[nCount][1] + CRLF
            EndIF
        Next nCount
    Else
        self:lSucesso := .F.
        self:cTipoRet := "DOCORI"
        self:cRetorno += "Documento de origem não localizado, possivelmente pelo produto não fazer parte da nota. Consulta realizada:" + cSql + CRLF
    EndIf

    RestArea(aArea)


Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Metodo responsavel por buscar os registros com erro e separá-los por ticket para reenvio.

@type   method
@param  cProcesso, Caractere, Processo que terá o tickets liberados novamente
@param  oJsParams, JsonObject, Tickets que serão liberados

@author  Evandro Pattaro
@since 	 08/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method Reprocessa(cProcesso, oJsParams) Class RmiBusLiveObj

    Local cQryErros     := ""
    Local cWhere        := ""
    Local cTblErro      := ""

    Default cProcesso := ""
    Default oJsParams := Nil

    If !Empty(cProcesso) .AND. Valtype(oJsParams) == "J"
        LjGrvLog("RMIBUSLIVEOBJ", "Executando reprocessamento manual.", {cProcesso, oJsParams}) 
        //Atualiza informações do processo
        self:SetaProcesso(cProcesso)        
        self:EnvReproc(cProcesso, oJsParams)        
    Else
        If self:oConfAssin["data_reprocessamento"] == DTOC(Date())
            LjGrvLog("RMIBUSCAOBJ","Reprocessamento já executado.",self:oConfAssin["data_reprocessamento"])        
        Else
            //Carrega os processos de busca
            self:Consulta()

            cQryErros     := "SELECT MHQ.MHQ_IDEXT "    
            cQryErros     += "FROM "+RetSqlName("MHL")+" MHL "
            cQryErros     += "INNER JOIN "+RetSqlName("MHQ")+" MHQ ON MHL.MHL_UIDORI = MHQ.MHQ_UUID "
            cQryErros     += "WHERE "
            If Valtype(self:oConfAssin["diasreprocessabusca"]) == "N"
                cQryErros += "  MHQ_DATGER >= '"+DTOS(Date()-self:oConfAssin["diasreprocessabusca"])+"'"
            Else            
                cQryErros += "  MHQ_DATGER >= '"+DTOS(Date()-1)+"'"
                self:oConfAssin["diasreprocessabusca"] := 1     //Quando não existir atualiza com quantidade default
            EndIf
            cQryErros     += "  AND MHQ.MHQ_ORIGEM = 'LIVE'"
            cQryErros     += "  AND MHQ.D_E_L_E_T_ = ' '"
            cQryErros     += "  AND MHL.D_E_L_E_T_ = ' '"
            cQryErros     += "  AND MHL.MHL_STATUS IN ('IR','3')"              

            If (self:cAliasQuery)->( Eof() )
                LjGrvLog("RMIBUSCAOBJ","Query sem dados")
            Else    
                While !(self:cAliasQuery)->( Eof() )

                    self:lSucesso := .T.
                    self:SetaProcesso((self:cAliasQuery)->MHP_CPROCE)
                    cTblErro := GetNextAlias()
                    oJsParams := JsonObject():New()
                    oJsParams["tickets"] := {}                    
                                    
                    cWhere := "  AND MHL.MHL_CPROCE = '"+(self:cAliasQuery)->MHP_CPROCE+"' GROUP BY MHQ.MHQ_IDEXT"  
                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQryErros+cWhere), cTblErro, .T., .F.)                
                    If (cTblErro)->( Eof() )
                        LjGrvLog("RMIBUSCAOBJ","Sem dados para reprocessar")
                    Else                 
                        While !(cTblErro)->( Eof() )
                            Aadd(oJsParams["tickets"], (cTblErro)->MHQ_IDEXT)
                            (cTblErro)->( DbSkip() )
                        EndDo
                    
                        LjGrvLog("RMIBUSLIVEOBJ", "Executando Reprocessamento.", {(self:cAliasQuery)->MHP_CPROCE, oJsParams})                
                        self:EnvReproc(Alltrim((self:cAliasQuery)->MHP_CPROCE), oJsParams)  
                    EndIf
                    (cTblErro)->( DbCloseArea() )
                    FwFreeObj(oJsParams)
                    (self:cAliasQuery)->( DbSkip() )
                EndDo
            EndIf
        EndIf    

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxExistePub 
Metodo que ira verificar se uma publicação já existe

@type    method
@author  Rafael Tenorio da Costa
@return  Lógico, define se existe uma publicação válida
@since   28/03/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Method AuxExistePub() Class RmiBusLiveObj

    Local lExiste   := _Super:AuxExistePub()
    Local cProcesso := AllTrim(self:cProcesso)

    If lExiste .And. cProcesso == "NOTA DE ENTRADA"

        //Valida publicação com erro
        If MHQ->MHQ_STATUS == "3".Or. Posicione("MHR", 3, xFilial("MHR") + MHQ->MHQ_UUID, "MHR_STATUS") == "3"
            self:deletaPublicacao()
            lExiste := .F.
        Else
            LjxjMsgErr( I18n("Publicação de #1 sera desprezada, ja existe a chave [#2] em processamento ou concluída.", {cProcesso, self:cChaveUnica}) , /*cSolucao*/, "AuxExistePub - RmiBusLiveObj")
        EndIf
    EndIf

Return lExiste
//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilMHP         
Function SetFilMHP()

Metodo que atualiza a filial do MHP, utilizado para o LiveConector
*/
Method SetFilMHP() Class RmiBusLiveObj
Local aAreaMHP      := MHP->(GetArea()) //Guarda a area
Local lStRmixFil    := existFunc("rmixFilial")                      //Verifica se existe a função que vai retornar as filiais
Local cStCmpFil     := iif(lStRmixFil, "MHP_LAYFIL", "MHP_FILPRO")  //Campo com as filiais utilizadas para processamento

LjGrvLog("RMIBUSLIVEOBJ","Verificando o campo que irá atualizar lStRmixFil",cStCmpFil)
If MHP->(dbSeek(xFilial("MHP") + PadR(Self:cAssinante,TamSX3("MHP_CASSIN")[1]) + PadR(Self:cProcesso,TamSX3("MHP_CPROCE")[1]) ))
    If RecLock("MHP",.F.)
        MHP->(&cStCmpFil) := cFilAnt+";"
        MHP->(MsUnlock())
    EndIf
EndIf
RestArea(aAreaMHP)

Return Nil
