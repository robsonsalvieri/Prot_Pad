#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIGRVMSGPUBPDVSYNCOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubPdvSyncObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubPdvSyncObj From RmiGrvMsgPubObj

    Method New()            	//Metodo construtor da Classe
    Method Especificos(cPonto)	//Efetua tratamento especificos para a publicação da MHQ_MENSAG.
    Method CarregaXml()         //Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).

    Method Venda()              //Efetua tratamentos especificos na publicação da venda 
    Method Inutilizacao()       //Efetua os tratamentos especificos na publicação de venda quando é uma inutilização

    Method Gravar()         	//Grava o conteudo no campo MHQ_MENSAGE

    Method AuxIniciaSL4(nSL4, oAux, nPagamento)     //Carrega dados iniciais do pagamento da venda na SL4
    Method Administradora()                         //Carrega dados iniciais do pagamento da venda na SL4
    Method VerificaCredito(cChvCred)                //Método que valida o crédito utilizado na venda (pagamentos do tipo CR)
    
    Method publicaCliente()                         //Método responsável por publicar o cliente caso não exista

    Method versaoLayPub()                           //Retorna a versão do layout de publicação

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiGrvMsgPubPdvSyncObj 
    Default cAssinante := "PDVSYNC"

    _Super:New(cAssinante)
    self:oBuscaObj  := RmiBusPdvSyncObj():New(cAssinante)

    self:oBuscaObj:oXmlSefaz  := Nil

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Especificos
Efetua tratamento especificos para a publicação da MHQ_MENSAG.

@type    Method
@param   cPonto, Caractere, Define o ponto onde esta sendo chamado o metodo.
@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Especificos(cPonto) Class RmiGrvMsgPubPdvSyncObj

    Local cProcesso := AllTrim(self:oBuscaObj:cProcesso)

    If cPonto == "INICIO"
    
        If cProcesso == "VENDA"

            //Atualiza a filial para a que será processada, para a correta execução do layout de publicação
            cFilAnt := self:oBuscaObj:oRegistro["Loja"]["IdRetaguarda"]

            //Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).
            self:CarregaXml()

            //Publica o cliente caso não exista
            self:publicaCliente()

            // -- Se for Inutilização simplifico o layout para os campos que serão necessarios.
            If self:oBuscaObj:cEvento == "3"
                Self:Inutilizacao()
            EndIf
        EndIf

    ElseIf cPonto == "FIM"

        //Carrega a filial de origem para ser utilizada para gerar os registros no Protheus (cFilAnt)
        if self:oBuscaObj:oRegistro:hasProperty("Loja") .and. self:oBuscaObj:oRegistro["Loja"]:hasProperty("IdRetaguarda")
            self:oPublica["FILIAL"] := self:oBuscaObj:oRegistro["Loja"]["IdRetaguarda"]
        endIf

        If cProcesso == "VENDA"
            self:Venda()
        EndIf

    EndIf

    _Super:Especificos(cPonto)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} CarregaXml
Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method CarregaXml() Class RmiGrvMsgPubPdvSyncObj

    Local cXml := ""
    Local nI   := 1
    //Valida TAG VendaCustodiaXml
    If self:oBuscaObj:oRegistro:HasProperty("VendaCustodiaXml")     .And.;
       ValType(self:oBuscaObj:oRegistro["VendaCustodiaXml"]) == "A" .And.;
       Len(self:oBuscaObj:oRegistro["VendaCustodiaXml"]) > 0

        If self:oBuscaObj:cEvento == '3'
            nI := Ascan(self:oBuscaObj:oRegistro['VendaCustodiaXml'], {|x| x['TipoXml'] == 3})
        EndIf

        If nI > 0
            //Valida TAG Xml - SEFAZ
            If self:oBuscaObj:oRegistro["VendaCustodiaXml"][nI]:HasProperty("Xml")           .And.;  
            !Empty( self:oBuscaObj:oRegistro["VendaCustodiaXml"][nI]:HasProperty("Xml") )         

                cXml := DeCode64( self:oBuscaObj:oRegistro["VendaCustodiaXml"][nI]["Xml"] )

                LjGrvLog( GetClassName(self), "Conteúdo da TAG VendaCustodiaXml após o DeCode64.", cXml )
                
                self:oBuscaObj:nCustodia := nI
                self:oBuscaObj:oXmlSefaz := RmiXmlSefaz():New(self:oBuscaObj:oRegistro["ModeloFiscal"], cXml)

                If !self:oBuscaObj:oXmlSefaz:getStatus()
                    self:lSucesso := self:oBuscaObj:oXmlSefaz:getStatus()
                    self:cErro    := self:oBuscaObj:oXmlSefaz:getErro()
                EndIf
            Else
            
                self:lSucesso := .F.
                self:cErro    := I18n(STR0001, {"[Xml] - SEFAZ", "MHQ_MSGORI"})     //"TAG #1 inválida, verifique se a TAG exite e tem conteúdo: campo #2."
            EndIf 
        Else 
            self:lSucesso := .F.
            self:cErro    := I18n(STR0001, {"[Xml] - SEFAZ (INUTILIZACAO)", "MHQ_MSGORI"})     //"TAG #1 inválida, verifique se a TAG exite e tem conteúdo: campo #2."                
        EndIf
    Else

        self:lSucesso := .F.
        self:cErro    := I18n(STR0002, {"VendaCustodiaXml", "MHQ_MSGORI"})      //"TAG #1 inválida, verifique se a TAG tem conteúdo e o mesmo é um array: campo #2."
    EndIf

    LjGrvLog( GetClassName(self), "Processando TAG VendaCustodiaXml.", {self:lSucesso, self:cErro} )

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Venda
Efetua tratamentos especificos na publicação da venda 

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Venda() Class RmiGrvMsgPubPdvSyncObj

    Local nPagamento := 0
    Local nPagItems  := 0
    Local nSL4       := 0
    Local oAux       := Nil
    Local nAux       := 0
    Local cAdminis   := ""
    Local aDadosComp := {}
    Local cForma     := ""
    Local cChvCred   := ""
    Local bErrorBlock := Nil
    Local cErrorBlock   := ""

    self:oPublica["SL4"] := {}
    self:oPublica["L1_CREDITO"] := 0
    //Nao executar quando for Inutlização
    If self:oBuscaObj:cEvento != '3'

        //Salva tratamento de erro anterior e atualiza tratamento de erro
        bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, /*@lErrorBlock*/, @cErrorBlock)} )

        //Condição que pode dar erro
        Begin Sequence
            //Valida processamento de venda gerada a partir de orçamento
            if self:versaoLayPub() < 2.3 .and. self:oBuscaObj:oRegistro["PreVenda"] <> Nil .and. self:oBuscaObj:oRegistro["PreVenda"]["IdRetaguarda"] <> nil
                self:lSucesso := .F.
                self:cErro    := STR0005 + "https://tdn.totvs.com/pages/releaseview.action?pageId=653841728"    //"Ops! Layout de publicação da venda desatualizado, acesse a documentação a seguir para efetuar a atualização: "
            endIf

            if self:lSucesso
                For nPagamento:=1 To Len(self:oBuscaObj:oRegistro["VendaPagamentos"])

                    cAdminis    := ""
                    cChvCred    := ""            
                    aDadosComp  := {}
                    cForma      := LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]['PagamentoForma']['IdRetaguarda'], 'forma')

                    //Tratamento para o Vale Troca
                    If Alltrim(cForma) == "CR" .OR. (self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]:HasProperty("VendaPagamentoTrocas") .And. Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoTrocas"]) > 0)

                        self:oPublica["L1_CREDITO"] +=  self:oBuscaObj:AuxTrataTag("L1_CREDITO", self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["ValorPago"])

                        If self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]:HasProperty("idCreditoRetaguarda")
                            cChvCred := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["idCreditoRetaguarda"]                    
                            self:VerificaCredito(cChvCred)
                            If !self:lSucesso
                                Exit
                            EndIf
                        EndIf
                    //Processamento de Venda\Cancelamento
                    Else
                    
                        If Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"]) == 0

                            //Carrega dados iniciais do pagamento da venda na SL4
                            self:AuxIniciaSL4(@nSL4, @oAux, nPagamento)

                            self:oPublica["SL4"][nSL4]["L4_VALOR"] := self:oBuscaObj:AuxTrataTag("L4_VALOR", oAux["ValorPago"])
                        Else

                            //Carrega Administradora
                            cAdminis := self:Administradora(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento])

                            //Carrega Dados Complementars
                            oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoDadoComplementars"]
                            For nAux:=1 To Len(oAux)
                                
                                If oAux[nAux]:HasProperty("PagamentoDadoComplementar")

                                    Aadd( aDadosComp, { AllTrim( LjAuxPosic("COMPLEM PAGAMENTO", "MIH_ID", oAux[nAux]["PagamentoDadoComplementar"]["IdRetaguarda"], "campoProtheus") ), oAux[nAux]["Conteudo"] } )
                                Else

                                    self:lSucesso := .F.
                                    self:cErro    := "Ops! Venda recebida com formato incorreto, atualize os serviços de integração do PDV. (TAG PagamentoDadoComplementar não encontrada)"
                                    Exit
                                EndIf
                            Next nAux

                            For nPagItems:=1 To Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"])

                                //Carrega dados iniciais do pagamento da venda na SL4
                                self:AuxIniciaSL4(@nSL4, @oAux, nPagamento)

                                //VendaPagamentos
                                self:oPublica["SL4"][nSL4]["L4_ADMINIS"] := cAdminis

                                //VendaPagamentoDadoComplementars
                                For nAux:=1 To Len(aDadosComp)
                                    If !Empty(aDadosComp[nAux][1])
                                        self:oPublica["SL4"][nSL4][aDadosComp[nAux][1]] := aDadosComp[nAux][2]
                                    EndIf
                                Next nAux

                                //VendaPagamentoItems
                                oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"][nPagItems]

                                self:oPublica["SL4"][nSL4]["L4_DATA"]  := self:oBuscaObj:AuxTrataTag("L4_DATA" , oAux["DataVencimento"] )
                                self:oPublica["SL4"][nSL4]["L4_VALOR"] := self:oBuscaObj:AuxTrataTag("L4_VALOR", oAux["ValorParcela"]   )

                                //VendaPagamentoTefs - Será um array com 1 posição
                                If self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]:HasProperty("VendaPagamentoTefs")

                                    oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoTefs"]

                                    If ValType(oAux) == "A" .And. Len(oAux) > 0
                                        self:oPublica["SL4"][nSL4]["L4_AUTORIZ"]   := self:oBuscaObj:AuxTrataTag("L4_AUTORIZ" , oAux[1]["NumeroAutorizacao"]                                )
                                        self:oPublica["SL4"][nSL4]["L4_NSUTEF"]    := self:oBuscaObj:AuxTrataTag("L4_NSUTEF"  , oAux[1]["NsuSitef"]                                         ) 
                                        self:oPublica["SL4"][nSL4]["L4_BANDEIR"]   := self:oBuscaObj:AuxTrataTag("L4_BANDEIR" , oAux[1]["Bandeira"]                                         )
                                        self:oPublica["SL4"][nSL4]["L4_PARCTEF"]   := self:oBuscaObj:AuxTrataTag("L4_PARCTEF" , oAux[1]["NumeroParcelas"]                                   )
                                        self:oPublica["SL4"][nSL4]["L4_REDEAUT"]   := self:oBuscaObj:AuxTrataTag("L4_REDEAUT" , oAux[1]["CodigoRede"]                                       )
                                        self:oPublica["SL4"][nSL4]["L4_DATATEF"]   := self:oBuscaObj:AuxTrataTag("L4_DATATEF" , StrTran( Substr(oAux[1]["DataCadastro"], 1, 10), "-", "")   )
                                        self:oPublica["SL4"][nSL4]["L4_HORATEF"]   := self:oBuscaObj:AuxTrataTag("L4_HORATEF" , StrTran( Substr(oAux[1]["DataCadastro"], 12, 8), ":", "")   )
                                        self:oPublica["SL4"][nSL4]["L4_DOCTEF"]    := self:oBuscaObj:AuxTrataTag("L4_NSUTEF"  , oAux[1]["NsuHost"]                                          )
                                    EndIf
                                EndIf

                            Next nPagItems
                        EndIf
                    EndIf
                Next nPagamento
            endIf
        //Tratamento para o erro
        Recover
            self:lSucesso := .F.
            self:cErro    := STR0006 + CRLF + cErrorBlock    //"Ops! Ocorreu um erro ao gerar a publicação de VENDA, verifique o log para mais detalhes."
            LjxjMsgErr(self:cErro)

        End Sequence
    EndIf

    oAux := Nil
    FwFreeObj(oAux)
    FwFreeArray(aDadosComp)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} AuxIniciaSL4
Carrega dados iniciais do pagamento da venda na SL4

@type    Method
@param   nSL4, Numerico, Quantidade de itens já incluidos na SL4
@param   oAux, JsonObject, Com o conteudo da TAG["VendaPagamentos"]
@param   nPagamento, Numerico, Numero do pagamento

@author  Rafael Tenorio da Costa
@version 1.0
@since   22/12/21   
/*/
//--------------------------------------------------------
Method AuxIniciaSL4(nSL4, oAux, nPagamento) Class RmiGrvMsgPubPdvSyncObj

    Aadd(self:oPublica["SL4"], JsonObject():New())
    nSL4 := Len(self:oPublica["SL4"])

    self:oPublica["SL4"][nSL4]["L4_FILIAL"] := self:oPublica["L1_FILIAL"]

    //VendaPagamentos
    oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]
    
    self:oPublica["SL4"][nSL4]["L4_FORMA"] := self:oBuscaObj:AuxTrataTag("L4_FORMA" , LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', oAux['PagamentoForma']['IdRetaguarda'], 'forma'))
    self:oPublica["SL4"][nSL4]["L4_TROCO"] := self:oBuscaObj:AuxTrataTag("L4_TROCO" , oAux["ValorTroco"])

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Gravar
Grava o conteudo no campo MHQ_MENSAGE

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Gravar() Class RmiGrvMsgPubPdvSyncObj

    _Super:Gravar()

    FwFreeObj(self:oBuscaObj:oXmlSefaz)
    self:oBuscaObj:oXmlSefaz := Nil

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Inutilizacao
Metodo responsavel por fornecer a origem dos dados que serão necessarios para uma inutilização

@author  Lucas Novais (lnovais@)
@version 1.0
@since   19/07/22 
/*/
//--------------------------------------------------------

Method Inutilizacao() Class RmiGrvMsgPubPdvSyncObj
    //Prepara os dados e envia para a classe PAI

      nPos :=  Ascan(self:oBuscaObj:oRegistro['VendaCustodiaXml'], {|x| x['TipoXml'] == 3})

        If nPos > 0

            _Super:Inutilizacao("&self:oRegistro['Loja']['IdRetaguarda']",;
                                "&self:oRegistro['Ccf']",;
                                "&self:LayEstAuto('LG_SERIE')",;
                                "&LjAuxPosic('OPERADOR DE LOJA', 'MIH_ID', self:oRegistro['Operador']['IdRetaguarda'], 'banco')",;
                                "IC",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['DataAutorizacao']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['NumeroAutorizacao']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['ChaveAcesso']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['DescricaoRetorno']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['CodigoRetorno']",;
                                "&self:LayEstAuto('LG_PDV')")
        EndIf 

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Administradora
Retorna a administradora da venda

@type    Method
@param   oVendaPagamentos, JsonObjeto, Json da venda a aprtir do nó VendaPagamentos
@return  Caractere, Código da Administradora
@author  Rafael Tenorio da Costa
@version 1.0
@since   22/12/21   
/*/
//--------------------------------------------------------
Method Administradora(oVendaPagamentos) Class RmiGrvMsgPubPdvSyncObj

    Local cRetorno  := ""
    Local cSql      := ""
    Local aSql      := {}
    Local nCont     := 0

        //Só pega a administradora pelo TEF quando o CodigoRede vier preenchido
        If oVendaPagamentos:HasProperty("VendaPagamentoTefs") .And. Len(oVendaPagamentos["VendaPagamentoTefs"]) > 0 .And.;
            !Empty(oVendaPagamentos["VendaPagamentoTefs"][1]["CodigoRede"]) .And. !( AllTrim(oVendaPagamentos["VendaPagamentoTefs"][1]["CodigoRede"]) == "0" )

            cSql    := " SELECT AE_COD ,AE_DESC"
            cSql    += " FROM " + RetSqlName("SAE") + " AE INNER JOIN " + RetSqlName("MDE") + " MDE_1 ON"
            cSql    += " MDE_1.MDE_FILIAL = AE_FILIAL"
            cSql    += " AND MDE_1.MDE_CODIGO = AE_ADMCART"
            cSql    += " AND MDE_1.MDE_TIPO = '"+self:oBuscaObj:AuxTrataTag("L4_FORMA" , LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', oVendaPagamentos['PagamentoForma']['IdRetaguarda'], 'forma'))+"' "
            cSql    += " AND MDE_1.MDE_CODSIT = '" + oVendaPagamentos["VendaPagamentoTefs"][1]["Bandeira"] + "'"
            cSql    += " AND MDE_1.D_E_L_E_T_ = ' '"
            cSql    += " INNER JOIN " + RetSqlName("MDE") + " MDE_2 ON"
            cSql    += " MDE_2.MDE_FILIAL = AE_FILIAL"
            cSql    += " AND MDE_2.MDE_CODIGO = AE_REDEAUT"
            cSql    += " AND MDE_2.MDE_TIPO = 'RD'"
            cSql    += " AND MDE_2.MDE_CODSIT = '" + oVendaPagamentos["VendaPagamentoTefs"][1]["CodigoRede"] + "'"
            cSql    += " AND MDE_2.D_E_L_E_T_ = ' '"
            cSql    += " WHERE AE_FILIAL = '"+ xFilial("SAE") +"' " 
            cSql    += " AND AE.D_E_L_E_T_ = ' '"

            aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

            If Len(aSql) > 0 
                cRetorno := AllTrim(aSql[1][1])
            EndIf
        EndIf

        If Empty(cRetorno)

            If oVendaPagamentos:HasProperty("PagamentoOperadora") .And. oVendaPagamentos["PagamentoOperadora"] <> Nil
                cRetorno := Right(oVendaPagamentos["PagamentoOperadora"]["IdRetaguarda"],tamSx3("AE_COD")[1])

            ElseIf oVendaPagamentos:HasProperty("PagamentoCondicao") .And. oVendaPagamentos["PagamentoCondicao"] <> Nil
                cRetorno := Right(oVendaPagamentos["PagamentoCondicao"]["IdRetaguarda"],tamSx3("AE_COD")[1])
            
            Else
                cRetorno := LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', oVendaPagamentos['PagamentoForma']['IdRetaguarda'], 'operadora')    
                
            EndIf
        EndIf

        If Empty(cRetorno)
            self:lSucesso := .F.
            self:cErro    :=  STR0003 + "(" + cSql + ")"  //"Administradora Financeira não localizada! Por favor, verifique as tabelas SAE e MDE do Protheus e certifique-se que na mensagem da venda, ao menos uma das seguintes tags estão preenchidas : 'VendaPagamentoTefs','PagamentoOperadora' ou 'PagamentoCondicao'. "
        EndIf

        If Len(aSql) > 1 
            
            cRetorno := ""
            For nCont:=1 To Len(aSql)
                cRetorno += AllTrim(aSql[nCont][1]) + " - " + AllTrim(aSql[nCont][2]) + ", "
            Next nCont
            cRetorno := SubStr(cRetorno, 1, Len(cRetorno) - 2)

            self:lSucesso := .F.
            self:cErro    := I18n(STR0004, {cRetorno, "AE_REDEAUT", "AE_ADMCART"})      //"Foram localizadas as Administradoras Financeiras (#1), utilizando as mesmas configurações de Rede Autorizadora(#2) e Bandeira(#3), na integração isto não é permitido. Por favor, altere estas Administradoras de modo que deixei apenas uma com esta configuração de Rede Autorizadora e Bandeira."
            cRetorno      := ""            
        EndIf

Return cRetorno

//--------------------------------------------------------
/*/{Protheus.doc} VerificaCredito
Método que valida o crédito utilizado na venda (pagamentos do tipo CR)

@type    Method
@param   cChvCred, Caractere, Chave do título CR que foi gerado pela compensação da NCC e retornado na mensagem da venda
@param   nValor, Numérico, Valor do pagamento realizado referente ao CR
@return  Nulo
@author  Evandro Pattaro
@version 1.0
@since   15/08/23   
/*/
//--------------------------------------------------------
Method VerificaCredito(cChvCred) Class RmiGrvMsgPubPdvSyncObj


    Local cChvVend  := ""
    Local aEstorno  := {}   
    Local aSE1		:= {}
    Local aTit      := {}
    Local nX        := 0 
    Local nValor    := 0
    Local aAreaSE1  := SE1->(GetArea())
    Local aAreaSE5	:= SE5->(GetArea())

    Private lMsErroAuto := .F.

    Default cChvCred    := ""

    nValor   := self:oPublica["L1_CREDITO"]

    SE1->(dbSetOrder(1))
    SE5->(dbSetOrder(7)) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
    If !Empty(cChvCred)
        cChvVend := RmiDePaRet(self:oBuscaObj:cAssinante, "SE1",cChvCred,.T.)
        If !Empty(cChvVend) 
        
            If self:oBuscaObj:cEvento == "2" //Cancelamento ou reprocessamento
                RmiDePaGrv(self:oBuscaObj:cAssinante, "SE1","",self:oBuscaObj:cChaveUnica, ,.F.) //Deleta o De/Para gerado anteriormente
            Else
                self:lSucesso := .F.
                self:cErro    := "Ops! O crédito utilizado nesta venda já foi utilizado na venda : "+cChvVend+". Verifique!"                  
            EndIf                  
        EndIf               

        If self:lSucesso

            If SE1->( dbSeek(cChvCred) ) //E1_FILIAL+ E1_PREFIXO+ E1_NUM+ E1_PARCELA+ E1_TIPO
                If self:oBuscaObj:cEvento == "1" //Venda
                    If nValor <> SE1->E1_VALOR 
                        self:lSucesso := .F.
                        self:cErro    := "Atenção! O valor de pagamento informado na venda ("+cValToChar(nValor)+") é diferente do valor baixado no sistema ("+cValToChar(SE1->E1_VALOR)+"). Verifique!"                     
                    ElseIf SE1->E1_SALDO <> 0 
                        self:lSucesso := .F.
                        self:cErro    := "Atenção! Título CR ("+cChvCred+") não teve seu saldo baixado completamente (saldo está maior que 0). Verifique se a compensação foi realizada corretamente." 
                    Else
                        RmiDePaGrv(self:oBuscaObj:cAssinante, "SE1","",self:oBuscaObj:cChaveUnica, cChvCred,.T.,MHQ->MHQ_UUID)
                    EndIf
                ElseIf self:oBuscaObj:cEvento == "2" //Cancelamento  
                    aSE1    := {SE1->(Recno())}                     
                    If SE5->(dbSeek(xFilial("SE5",SE1->E1_FILORIG)+ Substr(cChvCred,FwSizeFilial()+1) + SE1->E1_CLIENTE + SE1->E1_LOJA )) // E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
                        Begin Transaction
                            While SE5->E5_PREFIXO 	== SE1->E1_PREFIXO .AND.;
                                SE5->E5_NUMERO		== SE1->E1_NUM .AND.;
                                SE5->E5_PARCELA 	== SE1->E1_PARCELA .AND.;
                                SE5->E5_TIPO 		== Padr("CR",TamSX3("E5_TIPO")[1]) .AND.;
                                SE5->E5_CLIFOR 		== SE1->E1_CLIENTE .AND.;
                                SE5->E5_LOJA 		== SE1->E1_LOJA

                                If !Empty(SE5->E5_DOCUMEN)		
                                    aAdd(aEstorno, {{SE5->E5_DOCUMEN},SE5->E5_SEQ})
                                EndIf

                                SE5->(dbSkip())
                            EndDo 

                            For nX := 1 To Len(aEstorno)			
                                // Chama o cancelamento da baixa
                                MaIntBxCR(3 ,aSE1, , , , , ,aEstorno[nX], , , , , , , , , , , ) 									

                            Next nX
                            /*Deleta o título CR criado na compensação do crédito*/
                            If self:lSucesso
                                SE1->(DBGoTo(aSE1[1]))
                                AAdd(aTit , {"E1_FILIAL"  , xFilial("SE1")  , Nil})
                                AAdd(aTit , {"E1_PREFIXO" , SE1->E1_PREFIXO , Nil})
                                AAdd(aTit , {"E1_NUM"     , SE1->E1_NUM     , Nil})
                                AAdd(aTit , {"E1_PARCELA" , SE1->E1_PARCELA , Nil})
                                AAdd(aTit , {"E1_TIPO"    , SE1->E1_TIPO    , Nil})
                                AAdd(aTit , {"E1_CLIENTE" , SE1->E1_CLIENTE , Nil})
                                AAdd(aTit , {"E1_LOJA"    , SE1->E1_LOJA    , Nil})

                                MSExecAuto({|x, y| FINA040(x, y)}, aTit, 5)
                                If lMsErroAuto
                                    DisarmTransaction() 
                                    self:lSucesso   := .F.
                                    self:cErro      := MostraErro("\")
                                EndIf
                            EndIf
                        End Transaction    
                    EndIf
                EndIf               
            Else    
                self:lSucesso := .F.
                self:cErro    := "Atenção! Título CR ("+cChvCred+") não foi encontrado na base (SE1). Verifique se a compensação foi realizada corretamente."                    
            EndIf

        EndIF
    Else 
        self:lSucesso := .F.
        self:cErro    := "Atenção! o Pagamento de consumo de créditos de cliente (CR) não recebeu o id da movimentação. Verifique a mensagem da venda realizada no PDV OMNISHOP"
    EndIf
    RestArea(aAreaSE1)
    RestArea(aAreaSE5)
    
Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} publicaCliente
Método responsável por publicar o cliente caso não exista

@type    Method
@author  Rafael Tenorio da Costa
@since   24/11/2023
@version 12.1.2410
/*/
//--------------------------------------------------------
Method publicaCliente() Class RmiGrvMsgPubPdvSyncObj

    Local aArea     := GetArea()
    Local aAreaMHQ  := MHQ->( GetArea() )
    Local cHora     := IIF( TamSx3("MHQ_HORGER")[1] >= 12, TimeFull(), Time() )
    Local cAssinante:= PadR(self:cAssinante, TamSx3("MHQ_ORIGEM")[1])
    Local cProcesso := PadR("CLIENTE"      , TamSx3("MHQ_CPROCE")[1])
    Local oBuscaCli := Nil

    oBuscaCli := RmiBusPdvSyncObj():New()

    oBuscaCli:SetaProcesso("CLIENTE")

    If oBuscaCli:lSucesso .And. self:oBuscaObj:oRegistro:hasProperty("Cliente") .And. valType(self:oBuscaObj:oRegistro["Cliente"]) == "J" .And. self:oBuscaObj:oRegistro["Cliente"]:hasProperty("CpfCnpj")
     
        oBuscaCli:setChaveUnica(self:oBuscaObj:oRegistro["Cliente"])
        
    EndIf

    If !Empty(oBuscaCli:cChaveUnica)
        
        SA1->( dbSetOrder(3) )  //A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
        If !SA1->( dbSeek( xFilial("SA1", self:oBuscaObj:oRegistro["Loja"]["IdRetaguarda"]) + self:oBuscaObj:oRegistro["Cliente"]["CpfCnpj"]) )
            
            MHQ->( dbSetOrder(1) )  //MHQ_FILIAL, MHQ_ORIGEM, MHQ_CPROCE, MHQ_CHVUNI, MHQ_EVENTO, MHQ_DATGER, MHQ_HORGER, R_E_C_N_O_, D_E_L_E_T_
            If !MHQ->( dbSeek(xFilial("MHQ") + cAssinante + cProcesso + oBuscaCli:cChaveUnica) )
            
                RecLock("MHQ", .T.)
                    MHQ->MHQ_FILIAL := xFilial("MHQ")
                    MHQ->MHQ_ORIGEM := self:cAssinante
                    MHQ->MHQ_CPROCE := "CLIENTE"
                    MHQ->MHQ_EVENTO := "1"
                    MHQ->MHQ_CHVUNI := oBuscaCli:cChaveUnica
                    MHQ->MHQ_DATGER := Date()
                    MHQ->MHQ_HORGER := cHora
                    MHQ->MHQ_STATUS := "0"
                    MHQ->MHQ_UUID   := FwUUID("PUBLICACLIENTE")
                    MHQ->MHQ_MSGORI := self:oBuscaObj:oRegistro["Cliente"]:toJson()
                MHQ->( MsUnLock() )
            EndIf
        EndIf
    EndIf
    
    FwFreeObj(oBuscaCli)
    RestArea(aAreaMHQ)
    RestArea(aArea)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} versaoLayPub
Retorna a versão do layout de publicação

@type    Method
@author  Rafael Tenorio da Costa
@since   21/01/2025
@version 12.1.2510
/*/
//--------------------------------------------------------
Method versaoLayPub() Class RmiGrvMsgPubPdvSyncObj
return self:oBuscaObj:nVerLayPub
