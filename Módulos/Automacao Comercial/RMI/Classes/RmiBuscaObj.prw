#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIBUSCAOBJ.CH"

Static lLX_UUID := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBuscaObj
Classe responsável pela busca de dados nos Assinantes
    
/*/
//-------------------------------------------------------------------
Class RmiBuscaObj From RmiEnviaObj

    Data cLayoutPub     As Character    //Layout referente a publicação que será gerada quando for um processo de busca(MHP_LAYPUB)
    Data oLayoutPub     As Object       //Objeto JsonObject com layout de publicação utilizado no processo de busca para gerar a publicada
    Data nVerLayPub     As Numeric      //Versão do layout de publicação    

    Data oBusca         As Object       //Objeto utilizado para efetuar a busca no Assinante ele conterá o retorno do Assinante

    Data oRegistro      As Object       //Objeto que conterá o retorno de 1 registro. (Exemplo: 1 venda)

    Data cConfirma      As Character    //Código de confirmação utilizado para efetuar a confirmação de busca

    Data oConfirma      As Object       //Objeto com os artefatos necessarios para efetuar a confirmação de busca

    Data lContinuaBusca As Logical      //Faz o controle do processamento continuo

    Data cMsgOrigem     As Character    //Mensagem sem nenhum tratamento retornada pelo Assinante onde foi feita a busca

    Data cStatus        As Character    //Status de processamento da publicação - MHQ_STATUS 0=Fila;1=A Processar;2=Processada;3=Erro

    Data cModelo        As Character    //Modelo para processamento de estação SLG
    
    Data cCodLoja       As Character    //Codigo loja usado para processamento de estacao SLG
    
    Data cEstacao       As Character    //Estação/codigo equipamento usado para processamento de estacao SLG 
    
    Data cSerie         As Character    //Serie usado para processamento de estacao SLG

    Data cNumDoc        As Character  

    Method New(cAssinante)              //Metodo construtor da Classe

    Method Processa()                   //Metodo que ira controlar o processamento das buscas

    Method Busca()                      //Metodo responsavel por buscar as informações no Assinante

    Method Consulta()                   //Metodo com a consulta que será executada para saber quais os processos serão recebidos

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informações referente ao processo que será recebido
    
    Method TrataRetorno()               //Metodo que centraliza os retorno permitidos

    Method Venda()                      //Metodo para carregar a publicação de venda

    Method Grava()                      //Metodo que efetua a gravação da publicação

    Method Confirma()                   //Metodo que efetua a confirmação do recebimento

    Method Destroi()                    //Metodo que ira tirar os objetos criados da memoria    

    Method IgnoraPub()                  //Metodo que define se ignora uma publicação

    Method setChaveUnica()              //Metodo que atualiza a propriedade cChaveUnica a partir da configuração do processo. oConfProce["ChaveUni"]

    Method versaoLayout()               //Método responsável por carrega a versão dos layouts

    //Metodos auxiliares para tratamento interno da classe
    Method AuxTrataTag(cTag, xConteudo, nItem)  //Metodo para efetuar o tratamento das Tags que serão gravadas na publicação
    Method AuxExistePub()                       //Metodo que ira verificar se uma publicação já existe

    //Metodos responsaveis pelo reprocessamento da publicação
    Method DelVenda(cUuid)
    Method DelDePara(cUuid)
    Method DelLog(cUuid)
    Method DelDistrib(cUuid)
    Method DelPubCanc(cChvUni,cUuid)
    Method DelSLX(cUuid)
    Method DelRastroVend()              //Method para deletar as tabelas em caso de itens reenviados.
    Method VldVendErro()                //Valida a arvore de processo de erro 
    Method LayEstAuto(cCmpRet)          //Metodo generico de retorno ou inclusão de PDV e Serie
    Method getNumNota(cSerie) 
    Method Reprocessa()
    Method deletaPublicacao()           //Metodo que exclui os dados de uma publicação

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBuscaObj
    
    _Super:New(cAssinante)

    self:cOrigem        := self:cAssinante
    self:cTipo          := "2"   //2=Busca        
    self:cLayoutPub     := ""
    self:oLayoutPub     := Nil
    self:nVerLayPub     := 0    
    self:oBusca         := Nil
    self:oRegistro      := Nil
    self:cConfirma      := ""
    self:oConfirma      := Nil
    self:lContinuaBusca := .T.
    self:cMsgOrigem     := ""
    self:cStatus        := "1"  //0=Fila;1=A Processar;2=Processada;3=Erro
    self:cModelo        := ""
    self:cCodLoja       := ""
    self:cSerie         := ""
    self:cEstacao       := ""
    self:cNumDoc        := ""

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento das buscas

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiBuscaObj

    Local nFil := 0
    
    //Carrega os processo que devem efetuar a busca
    self:Consulta()

    If (self:cAliasQuery)->( Eof() )
        LjGrvLog("RMIBUSCAOBJ","Query sem dados")
    Else
        While !(self:cAliasQuery)->( Eof() )
            
            self:lSucesso := .T.
            self:cRetorno := ""

            //Atualiza informações do processo que será buscado
            self:SetaProcesso( (self:cAliasQuery)->MHP_CPROCE )

            //Gera log de erro
            If !self:lSucesso
                self:getRetorno()
            Else
                //Carrega o body de envio, solicitado pelo assinante para poder gerar o retorno
                For nFil:=1 To Len(self:aArrayFil)

                    //Tratamento para processamento por filial
                    self:nFil           := nFil 
                    self:lContinuaBusca := .T.

                    self:lSucesso := .T.
                    self:cTipoRet := ""
                    self:cRetorno := ""

                    If self:lSucesso
                        self:PreExecucao() 
                    EndIf

                    If self:lSucesso
                        self:CarregaBody()
                    EndIf

                    If self:lSucesso  
                        //Controla a execução das buscas, alguns sistemas retornam paginado - Ex: Live 35 vendas por retorno
                        While self:lContinuaBusca

                            self:lContinuaBusca := .F.
                            self:cConfirma      := ""

                            //Efetua a busca no assinante
                            If self:lSucesso
                                self:Busca()

                                //Efetua a confirmação do recebimento
                                //Sempre chama, porque pode ter que confirmar o recebimento de itens com erro
                                self:Confirma()
                            EndIf

                            //Gera log de erro
                            If !self:lSucesso
                                self:getRetorno()
                            EndIf
                            
                            FwFreeObj(self:oRetorno)
                            FwFreeObj(self:oConfirma)
                            self:oRetorno := Nil
                            self:oConfirma:= Nil
                        EndDo
                    EndIf
                Next nFil

            EndIf

            (self:cAliasQuery)->( DbSkip() )
        EndDo

        //Atualiza a configuração do assinante, com o novo token gerado
        If self:lSucesso
            self:SalvaConfig()
        EndIf
    EndIf

    (self:cAliasQuery)->( DbCloseArea() )
    self:Reprocessa() //realiza os reprocessamentos de registros com erro de integração   
    self:Destroi()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo com a consulta que será executada para saber quais os processos serão buscados

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiBuscaObj

    self:cAliasQuery := GetNextAlias()
    self:cQuery      := " SELECT MHP_CPROCE"
    self:cQuery      += " FROM " + RetSqlName("MHP")
    self:cQuery      += " WHERE D_E_L_E_T_ = ' '"
    self:cQuery      +=     " AND MHP_CASSIN = '" + self:cAssinante + "'"
    self:cQuery      +=     " AND MHP_ATIVO = '1'"  //1=Sim
    self:cQuery      +=     " AND MHP_TIPO = '2'"   //2=Busca
    self:cQuery      += " ORDER BY MHP_CPROCE"
    
    DbUseArea(.T., "TOPCONN", TcGenQry( , , self:cQuery), self:cAliasQuery, .T., .F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBuscaObj

    Local cErro := "" //Variavel para receber o retorno do metodo FromJson

    //Limpa configurações anteriores
    self:cLayoutPub := ""

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

    If self:lSucesso

        self:cLayoutPub := AllTrim(MHP->MHP_LAYPUB)
        
        //Carrega layout que será enviado
        If !Empty(self:cLayoutPub) .And. SubStr(self:cLayoutPub, 1, 1) == "{"

            If self:oLayoutPub == Nil
                self:oLayoutPub := JsonObject():New()
            EndIf

            cErro := self:oLayoutPub:FromJson(self:cLayoutPub)

            If ValType(cErro) <> "U" .And. !Empty(cErro)

                cErro := I18n( STR0003 + " (#4)", { GetSX3Cache("MHP_LAYPUB", "X3_TITULO"), AllTrim(self:cAssinante), AllTrim(cProcesso), AllTrim(cErro) } )   //"#1 inválido, verifique o cadastro do Assinante #2, Processo de #3"
            else
            
                //Carrega a versão dos layouts
                self:versaoLayout()                
            EndIf

        Else
            
            cErro := I18n( STR0003, { GetSX3Cache("MHP_LAYPUB", "X3_TITULO"), AllTrim(self:cAssinante), AllTrim(cProcesso) } )   //"#1 inválido, verifique o cadastro do Assinante #2, Processo de #3"
        EndIf

        If !Empty(cErro)

            //0=Fila não gera erro, só log
            If self:cStatus == "0"
                LjxjMsgErr(cErro, /*cSolucao*/)

            Else
                self:lSucesso := .F.
                self:cTipoRet := "LAYOUT"
                self:cRetorno := cErro
            EndIf
        EndIf

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informações no Assinante

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBuscaObj

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json (com Post)
    If self:lSucesso

        If self:oBusca == Nil
            self:oBusca := FWRest():New("")
        EndIf

        self:oBusca:SetPath( self:oConfProce["url"] )

        self:oBusca:SetPostParams(self:cBody)

        If self:oBusca:Post( {"Content-Type:application/json"} )

            self:cRetorno := self:oBusca:GetResult()

            If self:oRetorno == Nil
                self:oRetorno := JsonObject():New()
            EndIf
            self:oRetorno:FromJson(self:cRetorno)
            self:cRetorno := ""

            //Centraliza os retorno permitidos
            self:TrataRetorno()
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oBusca:GetLastError() + " - [" + self:oConfProce["url"] + "]" + CRLF
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo que centraliza os retorno permitidos

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBuscaObj

    Local cProcesso := AllTrim(self:cProcesso)

    Do Case 

        Case cProcesso == "VENDA"
            self:Venda()            

        OTherWise

            self:lSucesso := .F.
            self:cRetorno := I18n(STR0001, {cProcesso})    //"Processo #1 sem tratamento para busca implementado"
            LjGrvLog("RMIBUSCAOBJ",self:cRetorno)

    End Case

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Venda
Metodo para carregar a publicação de venda com implementações genericas
para todos os assinantes.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Venda() Class RmiBuscaObj

    Local nItem      := 0
    Local aTags      := self:oLayoutPub:GetNames()   //Retorno o nome das tags do objeto publica
    Local nTag       := 0
    Local aTagsSec   := {}
    Local nTagSec    := 0
    Local aNoFilho   := {}                           //Array do No Filho com os itens que serão procesasdos
    Local xNoFilho   := Nil                          //Objeto do No Filho com os itens que serão procesasdos
    Local cLayoutPub := ""                           //Propriedade que será macro executada para pegar o contedo retornado pelo assinante

    //Cria objeto que conterá a publicação
    If self:oPublica == Nil
        self:oPublica := JsonObject():New()
    EndIf            

    //Percorre tags do layout de publicação
    For nTag := 1 To Len(aTags)

        //Processa tags de um NÓ filho
        If aTags[nTag] $ "SL2|SL4"
            
            self:oPublica[ aTags[nTag] ] := {}

            //Pega o nome das tags filhas
            aTagsSec := self:oLayoutPub[ aTags[nTag] ][1]:GetNames()

            //Pega o caminho para o No Filho
            aNoFilho := {}
            ASize(aNoFilho, 0)
            xNoFilho := &( self:oConfProce[ aTags[nTag] ] )

            //Tratamento no layout para quando tiver apenas 1 item
            If ValType(xNoFilho) == "O"
                Aadd(aNoFilho, xNoFilho)
            Else
                aNoFilho := xNoFilho
            EndIf

            If ValType(aNoFilho) == "A"

                For nItem:=1 To Len( aNoFilho )

                    Aadd(self:oPublica[ aTags[nTag] ], JsonObject():New())

                    //Carrega tags do No Filho
                    For nTagSec:=1 To Len(aTagsSec)

                        cLayoutPub := self:oLayoutPub[ aTags[nTag] ][1][ aTagsSec[nTagSec] ]
                        
                        //Tratamento no layout para quando tiver apenas 1 item
                        If ValType(xNoFilho) == "O"
                            cLayoutPub := StrTran( cLayoutPub, "[nItem]", "")
                        EndIf

                        self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ] := self:AuxTrataTag( aTagsSec[nTagSec], cLayoutPub, nItem)

                    Next nTagSec
                Next nItem

            EndIf

        //Processa tags principais
        Else
            self:oPublica[ aTags[nTag] ] := self:AuxTrataTag( aTags[nTag], self:oLayoutPub[ aTags[nTag] ] )
        Endif

    Next nTag

    //Grava a publicação
    self:Grava()

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
    Asize(aTags   , 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Grava a publicação recebida

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiBuscaObj

    Local cChave  := xFilial("MHQ") + PadR(self:cOrigem, TamSx3("MHQ_ORIGEM")[1]) + PadR(self:cProcesso, TamSx3("MHQ_CPROCE")[1]) + PadR(self:cChaveUnica, TamSx3("MHQ_CHVUNI")[1])
    Local cHora     := IIF( TamSx3("MHQ_HORGER")[1] >= 12, TimeFull(), Time() )
    //Carrega json com o publicação que será gerada se existir
    If self:oPublica <> Nil
        self:cPublica := self:oPublica:ToJson()
    EndIf

    //Em caso de erro muda status
    If !self:lSucesso
        self:cStatus := "3"  //3=Erro
    EndIf

    Begin Transaction

        //Se for exclusão mas ainda não existi uma publicação de inclusão, gera a inclusão para depois gerar a exclusão
        MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
        If self:cEvento == "2" .And. !MHQ->( DbSeek(cChave) ) //Retirada a ExtVendCan pois não utiliza mais o ticket na chave.
            
            RecLock("MHQ", .T.)

                MHQ->MHQ_FILIAL := xFilial("MHQ")
                MHQ->MHQ_ORIGEM := self:cOrigem
                MHQ->MHQ_CPROCE := self:cProcesso
                MHQ->MHQ_EVENTO := "1"              //1=Atualização;2=Exclusão;3=Inutilização
                MHQ->MHQ_CHVUNI := self:cChaveUnica
                MHQ->MHQ_MENSAG := self:cPublica
                MHQ->MHQ_DATGER := Date()
                MHQ->MHQ_HORGER := cHora
                MHQ->MHQ_STATUS := self:cStatus     //0=Fila;1=A Processar;2=Processada;3=Erro
                MHQ->MHQ_UUID   := FwUUID("BUSCA" + AllTrim(self:cProcesso) + "1")    //Gera chave unica
                MHQ->MHQ_MSGORI := self:cMsgOrigem

                If MHQ->(FieldPos('MHQ_IDEXT')) > 0
                    MHQ->MHQ_IDEXT := self:cConfirma
                EndIf

            MHQ->( MsUnLock() )
            
        EndIf

        RecLock("MHQ", .T.)

            MHQ->MHQ_FILIAL := xFilial("MHQ")
            MHQ->MHQ_ORIGEM := self:cOrigem
            MHQ->MHQ_CPROCE := self:cProcesso
            MHQ->MHQ_EVENTO := self:cEvento     //1=Atualização;2=Exclusão;3=Inutilização
            MHQ->MHQ_CHVUNI := self:cChaveUnica
            MHQ->MHQ_MENSAG := self:cPublica
            MHQ->MHQ_DATGER := Date()
            MHQ->MHQ_HORGER := cHora
            MHQ->MHQ_STATUS := self:cStatus     //0=Fila;1=A Processar;2=Processada;3=Erro

            If self:cStatus == "3"
                MHQ->MHQ_DATPRO := Date()
                MHQ->MHQ_HORPRO := Time()
            EndIf

            MHQ->MHQ_UUID   := FwUUID("BUSCA" + AllTrim(self:cProcesso) + "2")      //Gera chave unica
            MHQ->MHQ_MSGORI := self:cMsgOrigem      

            If MHQ->(FieldPos('MHQ_IDEXT')) > 0
                MHQ->MHQ_IDEXT := cValToChar(self:cConfirma)
            EndIf

        MHQ->( MsUnLock() )

        //Em caso de erro grava Log
        If !self:lSucesso
            RMIGRVLOG(  "IR"            , "MHQ"         , MHQ->(Recno())    , self:cTipoRet     ,;
                        self:cRetorno   ,               ,                   ,                   ,;
                        .F.             , 1             , cChave            , MHQ->MHQ_CPROCE   ,;
                        MHQ->MHQ_ORIGEM , MHQ->MHQ_UUID )
        EndIf

    End Transaction

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirmação do recebimento

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma() Class RmiBuscaObj
    //Implementação esta na classe filha
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroi
Metodo que ira tirar os objetos criados da memoria

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroi() Class RmiBuscaObj
    
    FwFreeObj(self:oLayoutPub)
    FwFreeObj(self:oBusca)
    FwFreeObj(self:oRegistro)

    _Super:Destroi()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxTrataTag
Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method AuxTrataTag(cTag, xConteudo, nItem) Class RmiBuscaObj

    Local xTag      := xConteudo
    Local cTipo     := GetSX3Cache(cTag, "X3_TIPO")
    Local oError    := Nil

    Default nItem   := 0    //Variavel que pode ser utilizadada dentro do xConteudo

    //Retorna resultado de macro execução
    If ValType(xConteudo) == "C" .And. SubStr(xConteudo, 1, 1) == "&"

		//Macro executa
		TRY EXCEPTION
			//Condição que pode dar erro
			xTag := &( AllTrim( SubStr(xConteudo, 2) ) )

        //Se ocorreu erro
		CATCH EXCEPTION USING oError
            Self:lSucesso := .F.
            Self:cRetorno := STR0007 + cTag + STR0008 + Chr(13) +;  //"Não foi possivel macro executar a tag " # " do layout de publicação (MHP->MHP_LAYPUB)."
                            STR0009 + xConteudo + "." + Chr(13) +;  //" O conteúdo da tag que macro executou é: "
                            STR0010 + AllTrim(oError:ErrorStack)    //" O erro apresentado ao tentar macro executar é: "
            
            If At("cannot find function", oError:Description) .AND. Upper(SubStr(AllTrim(oError:Operation), 1, 2)) == "U_"
                Self:cRetorno += Chr(13) + STR0011 + oError:Operation + STR0012 //" A função que esta faltando no RPO trata-se de uma função customizada (" # "), por favor, verifique se o nome da função esta correta ou compile a função no RPO."
            EndIf
		ENDTRY
    EndIf

    //Formata com tipo esperado pelo Protheus
    Do Case

        Case cTipo == "C"

            If ValType(xTag) == "N"
                xTag := cValToChar(xTag)

            ElseIf ValType(xTag) == "C"
                xTag := NoAcento(xTag)
                xTag := DeCodeUtf8(xTag)

            Else

                self:lSucesso := .F.
                self:cRetorno := I18n(STR0014, {cTag, ValType(xTag)} )  //"Tipo da tag #1 inválido. Tipo esperado caracter, tipo retornado: #2"
            EndIf

        Case cTipo == "D"
            xTag := StrTran(xTag, "-", "")
            xTag := SubStr(xTag, 1, 8)

        Case cTipo == "N" .And. ValType(xTag) == "C"
            xTag := StrTran(xTag, ",", ".")     //Por algum motivo desconhecido estavamos recebendo valor com "," ai quando ia converter perdia os decimais
            xTag := Val(xTag)

    EndCase

Return xTag

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistePub 
Metodo que ira verificar se uma publicação já existe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method AuxExistePub() Class RmiBuscaObj

    Local lExiste := .F. 
    Local cChave  := xFilial("MHQ") + PadR(self:cOrigem, TamSx3("MHQ_ORIGEM")[1]) + PadR(self:cProcesso, TamSx3("MHQ_CPROCE")[1]) + PadR(self:cChaveUnica, TamSx3("MHQ_CHVUNI")[1])

    MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
    lExiste := MHQ->( DbSeek(cChave + self:cEvento) )

    /*Pesquisa se a venda, distribuição ou publicação esta com erro.
    Caso esteja com erro, marca com 4 para reprocessar.*/
    If lExiste .AND. ExistFunc("RmiGetRepc") .AND. ExistFunc("RmiMarkSale") .AND. RmiGetRepc()
        RmiMarkSale(MHQ->MHQ_UUID)
    EndIf
  
    If lExiste .AND. Alltrim(self:cProcesso) == 'VENDA'
        
        //Processo para deletar as tabelas em caso de itens reenviados.    
        Begin Transaction
            lExiste := Self:DelRastroVend()
        End Transaction
    EndIf

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} DelVenda 
Esse metodo tem o objetivo de localizar a venda que sera reprocessada
para antes, realizar a exclusão da SL1, SL2 e SL4.

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelVenda(cUuid) Class RmiBuscaObj

Local lRet      := .T. //Variavel de retorno
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias

cQuery := "SELECT R_E_C_N_O_ REC "
cQuery += "  FROM " + RetSqlName("SL1")
cQuery += " WHERE L1_UMOV = '" + cUuid + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("RMIBUSCAOBJ","[DelVenda] Query executada ->",cQuery)

If !(cAlias)->( Eof() )
    SL1->(dbGoto((cAlias)->REC))
    If SL1->L1_SITUA $ "IR|ER|RP"

        LjGrvLog(" RmiBuscaObj ", "Reprocessamento da publicação (MHQ_UUID) " +;
                                 AllTrim(cUuid) + ". Excluindo a venda L1_FILIAL = " + AllTrim(SL1->L1_FILIAL) +;
                                 " L1_NUM = " + AllTrim(SL1->L1_NUM)) 

        /*Trava a SL1 para não acontecer do usuario alterar o L1_SITUA
        pelo APSDU*/
        RecLock("SL1",.F.)

        //Inicia a exclusao da SL2
        dbSelectArea("SL2")
        SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
        If SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
            While SL2->(!Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM
                RecLock("SL2",.F.)
                SL2->( DbDelete() )
                SL2->( MsUnLock() )
                SL2->( DbSkip() )
            EndDo
        Else
            LjGrvLog("RMIBUSCAOBJ","Nenhum Item (SL2) encontrada para esse Orçamento")
        EndIf

        //Inicia a exclusao da SL4
        dbSelectArea("SL4")
        SL4->(dbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
        If SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
            While SL4->(!Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == SL1->L1_FILIAL + SL1->L1_NUM
                RecLock("SL4",.F.)
                SL4->( DbDelete() )
                SL4->( MsUnLock() )
                SL4->( DbSkip() )
            EndDo
        Else
            LjGrvLog("RMIBUSCAOBJ","Nenhum Pagamento (SL4) encontrada para esse Orçamento")
        EndIf

        //Após excluir a SL2 e SL4, terminar de excluir a SL1
        SL1->( DbDelete() )
        SL1->( MsUnLock() )       
        
    Else
        //"Não é possivel reprocessar a publicação (MHQ_UUID) " # " pois a venda esta com L1_SITUA igual a " # ". O reprocessamento só é aceito para vendas com L1_SITUA igual a IR ou ER."
        LjGrvLog(" RmiBuscaObj ", STR0004 + AllTrim(cUuid) + STR0005 + AllTrim(SL1->L1_SITUA) + STR0006) 
        lRet := .F.        
    EndIf
Else
    LjGrvLog("RMIBUSCAOBJ","Não foi encontrada venda para esse UUID ",{cUuid})
    lRet := .F.     
EndIf

(cAlias)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelDePara 
Metodo responsavel em realizar a exclusão dos registros de de/para
antes de efetivar o reprocessamento da venda

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelDePara(cUuid) Class RmiBuscaObj

Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lUidOri   := MHM->(ColumnPos("MHM_UIDORI" )) > 0

Default cUuid := ""

If lUidOri .AND. !Empty(cUuid)
    cQuery := "SELECT R_E_C_N_O_ REC"
    cQuery += "  FROM " + RetSqlName("MHM")
    cQuery += " WHERE MHM_UIDORI = '" + cUuid + "'"
    cQuery += "   AND D_E_L_E_T_ <> '*'"
    cQuery += "   AND MHM_UIDORI <> ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    LjGrvLog("RMIBUSCAOBJ","[DelDePara] Query executada ->",cQuery)
    LjGrvLog("RmiBuscaObj", "[DelDePara] Reprocessamento da publicação (MHM_UIDORI) " + AllTrim(cUuid) + ". Realizando a exclusão dos de/para tabela (MHM)")

    While !(cAlias)->( Eof() )
        MHM->(dbGoto((cAlias)->REC))
        
        RecLock("MHM",.F.)
        MHM->( DbDelete() )
        MHM->( MsUnLock() )
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )
Else
    LjGrvLog("RmiBuscaObj", "[DelDePara] O Campo MHM_UIDORI não existe no dicionario de dados, não foi possivel excluir os dados De/Para no reprocessamento - Publicação (MHQ_UUID) -> " + AllTrim(cUuid) + ".")    
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DelLog 
Metodo responsavel em realizar a exclusão dos registros de log da venda
que sera reprocessada

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelLog(cUuid) Class RmiBuscaObj

Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lUIDORI   := MHL->(ColumnPos("MHL_UIDORI" )) > 0 

If lUIDORI
    cQuery := "SELECT R_E_C_N_O_ REC"
    cQuery += "  FROM " + RetSqlName("MHL")
    cQuery += " WHERE MHL_UIDORI = '" + cUuid + "'"
    cQuery += "   AND D_E_L_E_T_ <> '*'"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
    
    LjGrvLog("RMIBUSCAOBJ","[DelLog] Query executada ->",cQuery)
    LjGrvLog("RmiBuscaObj", "[DelLog] Reprocessamento da publicação (MHQ_UUID) " + AllTrim(cUuid) + ". Realizando a exclusão dos logs tabela (MHL)")

    While !(cAlias)->( Eof() )
        MHL->(dbGoto((cAlias)->REC))
        RecLock("MHL",.F.)
        MHL->( DbDelete() )
        MHL->( MsUnLock() )    
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )
Else
    LjGrvLog("RmiBuscaObj", "[DelLog] O Campo MHL_UIDORI não existe no dicionario de Dados - Reprocessamento Não Efetuado - Publicação (MHQ_UUID) -> " + AllTrim(cUuid) + ".")    
ENDIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DelDistrib 
Metodo responsavel em realizar a exclusão dos registros de distribuição
da venda antes de reprocessa-la 

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelDistrib(cUuid) Class RmiBuscaObj

Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lRet      := .T.

cQuery := "SELECT R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName("MHR")
cQuery += " WHERE MHR_UIDMHQ = '" + cUuid + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("RMIBUSCAOBJ","[DelDistrib] Query executada ->",cQuery)


If !(cAlias)->( Eof() )
    While !(cAlias)->( Eof() )
        MHR->(dbGoto((cAlias)->REC))
        RecLock("MHR",.F.)
        MHR->( DbDelete() )
        MHR->( MsUnLock() )    
        (cAlias)->( DbSkip() )
    EndDo
else
    LjGrvLog("RmiBuscaObj", "[DelDistrib] Reprocessamento Não foi encontrado registro de distribuição tabela (MHR) UUID -> "+ AllTrim(cUuid))
    lRet := .F.    
EndIf    

(cAlias)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelPubCanc 
Metodo responsavel em realizar a exclusão dos registros de publicação
com o evento igual a 2 (cancelamento)

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelPubCanc(cChvUni,cUuid) Class RmiBuscaObj

Local aArea     := GetArea() 
Local aAreaMHQ  := MHQ->(GetArea())
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local lRet      := .T.

Default cChvUni := ""
Default cUuid := ""


cQuery := "SELECT R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName("MHQ")
cQuery += " WHERE MHQ_CHVUNI = '" + cChvUni + "'"
cQuery += "   AND MHQ_EVENTO IN ('2')"
cQuery += "   AND D_E_L_E_T_ <> '*'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("RMIBUSCAOBJ","[DelPubCanc] Query executada ->",cQuery)
LjGrvLog("RmiBuscaObj", "[DelPubCanc] Reprocessamento da publicação (MHQ_UUID) " + AllTrim(cUuid) + ". Realizando a exclusão do registro de cancelamento da MHQ (MHQ_EVENTO = 1 )")

If !(cAlias)->( Eof() )
    While !(cAlias)->( Eof() )
        MHQ->(dbGoto((cAlias)->REC))

        //Realiza a exclusão da distribuição 
        //do registro de cancelamento
        Self:DelLog(MHQ->MHQ_UUID) //Deleta log na MHL
        Self:DelDistrib(MHQ->MHQ_UUID)
        Self:DelSLX(MHQ->MHQ_UUID)

        RecLock("MHQ",.F.)
        MHQ->( DbDelete() )
        MHQ->( MsUnLock() )    
        (cAlias)->( DbSkip() )
    EndDo
else
    LjGrvLog("RmiBuscaObj","[DelPubCanc] Registro não encontrado na MHQ ",cQuery)    
    lRet := .F.
EndIf
(cAlias)->( DbCloseArea() )


RestArea(aAreaMHQ)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelSLX 
Metodo responsavel em realizar a exclusão dos registros da SLX (cancelamento)
@author  Julio Nery
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelSLX(cUuid, lSoErros) Class RmiBuscaObj

Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := "" //Pega o proximo alias
Local lRet      := .T.

Default cUuid   := ""
Default lSoErros:= .F.

If lLX_UUID == NIL
    lLX_UUID := SLX->(ColumnPos("LX_UUID")) > 0
    If !lLX_UUID
        LjGrvLog("RMIBUSCAOBJ","Campo LX_UUID não existe na base, se houver alguma SLX associada ela não sera deletada. ")
    EndIf
EndIf


If lLX_UUID .AND. !Empty(cUuid)
    cAlias    := GetNextAlias()
    cQuery := "SELECT R_E_C_N_O_ REC"
    cQuery += " FROM " + RetSqlName("SLX")
    cQuery += " WHERE LX_UUID = '" + cUuid + "'"
    
    cQuery += " AND LX_SITUA IN " + IIF( lSoErros, "('IR','ER')", "('IR','ER','IP')" )
    cQuery += " AND D_E_L_E_T_ = '' "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
    LjGrvLog("DelSLX","[DelSLX] Query executada ->",cQuery)
    
    If !(cAlias)->( Eof() )
        LjGrvLog("DelSLX", "Registro da SLX (LX_UUID): " + AllTrim(cUuid) + ". Realizando a exclusão do registro ")
        While !(cAlias)->( Eof() )
            SLX->(dbGoto((cAlias)->REC))
            
            RecLock("SLX",.F.)
                SLX->( DbDelete() )
            SLX->( MsUnLock() )    
            
            (cAlias)->( DbSkip() )
        EndDo
    else
        LjGrvLog("RMIBUSCAOBJ","[DelSLX] Não foi encontrado registro na tabela SLX ") 
        lRet := .F.    
    EndIf
    (cAlias)->( DbCloseArea() )
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DelRastroVend 
Esse metodo tem a responsabilidade em verificar se o registro da MHQ
está processado com erro para efetuar nova busca no live e gravar
novos registros.
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method DelRastroVend() Class RmiBuscaObj

Local aArea     := GetArea()
Local aAreaMHQ  := MHQ->(GetArea())
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local cUuid     := "" //Guardo o UUID da publicação
Local lRet      := .F. //Variavel de retorno
Local nRec      := 0 //Guarda o RECNO da publicação principal


cQuery := "SELECT R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName("MHQ")
cQuery += " WHERE MHQ_CHVUNI = '" + MHQ->MHQ_CHVUNI + "'"
cQuery += "   AND MHQ_EVENTO IN ('1','2','3') "
cQuery += "   AND MHQ_CPROCE = 'VENDA' "
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += "   ORDER BY MHQ_EVENTO "

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("DelRastroVend","[DelRastroVend] Query executada ->",cQuery)

While !(cAlias)->( Eof() )

    MHQ->(dbGoto((cAlias)->REC))
    nRec := (cAlias)->REC
    cUuid := MHQ->MHQ_UUID
    
    Do Case  
        
        Case Self:VldVendErro()
            
            Self:DelLog(cUuid)      //Deleta log na MHL
            Self:DelDePara(cUuid)   //Deleta De/Para na MHM
            Self:DelSLX(cUuid)      //Deleta cancelamento e inutilização
            
            If MHQ->MHQ_EVENTO == "1" // -- Somente entra nesse trecho caso esteja com erro na venda, com isso o cancelamento tambem é excluido.
                Self:DelPubCanc(MHQ->MHQ_CHVUNI,cUuid)
            EndIf 
           
            Self:DelDistrib(cUuid) //Deleta a distribuição

            LjGrvLog("DelRastroVend", "Exclusão de Publicação (MHQ) - Recno ->",nRec)
            MHQ->(dbGoto(nRec))
            RecLock("MHQ",.F.)
                MHQ->( DbDelete() ) //Deleta o Registro na MHQ
            MHQ->( MsUnLock() )
        
        OTherWise
            LjGrvLog("DelRastroVend", "(MHQ) não pode ser Excluida pois não possui erro no seu Status ",{MHQ->MHQ_STATUS,cUuid})    
            lRet := .T. //Retorna .T. indica que não deverá aceitar o novo registro pois não existe erro no processo.
    End Case

    (cAlias)->( DbSkip() )
EndDo

(cAlias)->( DbCloseArea() )


RestArea(aArea)
RestArea(aAreaMHQ)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldVendErro 
Esse metodo valida erro para efetuar deletar e receber os
novos registros.
@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method VldVendErro() Class RmiBuscaObj
Local aArea         := GetArea()
Local aAreaMHR      := MHR->(GetArea())
Local lRet          := .F.

If Self:DelVenda(MHQ->MHQ_UUID)
    LjGrvLog("VldVendErro", "Erro encontrada na Venda")
    lRet := .T. 
ElseIf MHQ->MHQ_STATUS == '3' .or. MHQ->MHQ_STATUS == '4'
    LjGrvLog("VldVendErro", "Erro encontrada na tabela MHQ")
    lRet := .T.    
elseIf Posicione("MHR", 3, xFilial("MHR") + MHQ->MHQ_UUID,"MHR_STATUS") == '3'
    LjGrvLog("VldVendErro", "Erro encontrada na tabela MHR")
    lRet := .T.    
else
    lRet := Self:DelSLX(MHQ->MHQ_UUID, .T.)
    LjGrvLog("VldVendErro", "Executando a busca no Method DelSLX ", {MHQ->MHQ_UUID,lRet})
EndIf

RestArea(aAreaMHR)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAuto
Metodo que Retorna informações da SLG a partir do campo recebido no parâmetro cCmpRet ou cadastra a SLG
Cadastra a estação AUTOMATICO caso seja necessário.
Utilizado no layout

@param cCmpRet      - Nome do campo que irá retornar LG_SERIE, LG_PDV

@return cRetorno    - Caracter com a serie ou pdv 
				
@author  Danilo Rodrigues
@since 	 03/12/2021
@version 1.0				
/*/	
//-------------------------------------------------------------------------------------------------
Method LayEstAuto(cCmpRet, cNumPdv) Class RmiBuscaObj

    Local aArea     := GetArea()
    Local cRetorno  := ""
	Local aEstacao	:= {}
	Local aErro		:= {}
	Local cErro		:= ""
	Local nCont		:= 0
	Local cQuery    := ""
    Local cTab      := ""
    Local nOpc      := 3    
    Local cPdv      := ""
    Local lContinua := .T.
    Local cFilialSlg:= ""
    Local nTamCod   := tamSx3("LG_CODIGO")[1]

    Default cNumPdv := ""

    LjGrvLog("LayEstAuto", "Dados recebidos para query na SLG: [cModelo\cCodLoja\cEstacao\cSerie\cCmpRet\cNumPdv]", {self:cModelo, self:cCodLoja, self:cEstacao, self:cSerie, cCmpRet, cNumPdv})

	Private lMsErroAuto	   := .F.	//Cria a variavel do retorno da rotina automatica

    If !Empty(self:cCodLoja)

        self:cCodLoja   := padR(self:cCodLoja, TamSx3("LG_FILIAL")[1])
        cFilialSlg      := xFilial("SLG", self:cCodLoja)

        LjGrvLog("LayEstAuto","Filial do De/Para de Loja: " + self:cCodLoja)

        cQuery := " SELECT LG_CODIGO, LG_NOME, LG_SERIE, LG_PDV, LG_SERPDV, LG_NFCE "
        cQuery += " FROM " + RetSqlName("SLG")
        cQuery += " WHERE LG_FILIAL = '" + cFilialSlg + "'"

        Do Case
            Case self:cModelo == "1" .and. !Empty(self:cEstacao)
                cQuery +=   " AND LG_SERSAT = '" + self:cEstacao + "'"

            Case self:cModelo == "2" .and. !Empty(self:cSerie)
                cQuery +=   " AND LG_SERIE = '" + self:cSerie + "'"
                
            Case self:cModelo == "4" .and. Empty(self:cEstacao)
                cQuery +=   " AND LG_SERPDV = '" + self:cEstacao + "'"

            OTherWise
                lContinua     := .F.
                self:lSucesso := .F.
                self:cTipoRet := "ESTACAO"
                self:cRetorno += I18n("Dados recebidos não conferem com as regras estabelecidas: Modelo=[#1] Serie=[#2] Estação=[#3]", {self:cModelo, self:cSerie,self:cEstacao}) + CRLF

        End Case

        cQuery +=   " AND D_E_L_E_T_ = ' ' "

        LjGrvLog("LayEstAuto", "Query executada: " + cQuery)

        If lContinua

            cTab := GetNextAlias()
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTab, .T., .F.)

            //Não encontrou nenhuma estação
            If (cTab)->( Eof() )                        
                If Empty(self:cSerie)
                    If self:cModelo == "1"
                        self:cSerie := "99A"
                    Else
                        self:cSerie := "001"
                    EndIf
                    
                    //Se encontrou a estação ou já tem a série nos livros atualiza a série
                    SLG->( dbSetOrder(1) )  //LG_FILIAL, LG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
                    SF3->( dbSetOrder(5) )  //F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT, F3_ENTRADA, F3_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
                    While SLG->( dbSeek(cFilialSlg + self:cSerie) ) .or. SF3->( dbSeek(xFilial("SF3", self:cCodLoja) + self:cSerie) )
                        self:cSerie := Soma1(self:cSerie, nTamCod)
                    End
                EndIF

                LjGrvLog("Código de série utilizada na estação: " + self:cSerie)                                        

                cPdv := Substr( GetSxeNum("SLG", "LG_PDV"), 8, 3 )
                Aadd( aEstacao, {"LG_FILIAL", cFilialSlg            , Nil} )
                Aadd( aEstacao, {"LG_NOME"	, STR0015 + self:cSerie , Nil} )     //"ESTAÇÃO "
                Aadd( aEstacao, {"LG_SERIE"	, self:cSerie	        , Nil} )
                Aadd( aEstacao, {"LG_PDV"	, cPdv                  , Nil} )
                  

                If self:cModelo == '1' .or. self:cModelo == '4'
                    
                    Aadd( aEstacao, {"LG_NFCE"  , .F.               , Nil} )
                    If self:cModelo == '1'
                        Aadd( aEstacao, {"LG_SERSAT", self:cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .T.           , Nil} )
                    ElseIf self:cModelo == '4'
                        Aadd( aEstacao, {"LG_SERPDV", self:cEstacao      , Nil} )
                        Aadd( aEstacao, {"LG_USESAT", .F.           , Nil} )
                    EndIf
                    
                Else            
                    Aadd( aEstacao, {"LG_NFCE"	, .T.               , Nil} )
                EndIF
                
                //A estação já é cadastrada via api de dispositivo 
                //então é preciso apenas atualizar os dados.
                SLG->( DbSetOrder(1) )  //LG_FILIAL, LG_CODIGO, R_E_C_N_O_, D_E_L_E_T_
                If !Empty(cNumPdv) .AND. SLG->( dbSeek(cFilialSlg + padR(cNumPdv, nTamCod) ) ) 
                    nOpc := 4
                    LjGrvLog("LayEstAuto", "Atualizando via venda o novo dispositivo na tabela SLG, LG_CODIGO:" + SLG->LG_CODIGO)
                    Aadd( aEstacao, {"LG_CODIGO", SLG->LG_CODIGO        , Nil} )
                else 
                    LjGrvLog("LayEstAuto","Estação e se serie será incluida... ")
                    Aadd( aEstacao, {"LG_CODIGO", self:cSerie           , Nil} )       
                EndIf

                SF3->( dbSetOrder(5) )  //F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT, F3_ENTRADA, F3_ESPECIE, R_E_C_N_O_, D_E_L_E_T_
                if SF3->( dbSeek( xFilial("SF3", self:cCodLoja) + padR(self:cSerie, tamSx3("F3_SERIE")[1]) ) )

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += i18n(STR0016, {self:cSerie})   //"Série (#1) utilizada na venda, já existe nos livros fiscais. Verifique no PDV a configuração da série e reprocesse a venda."
                else

                    //Cadastra a estação AUTOMATICA
                    MSExecAuto({|a,b,c,d| LOJA121(a,b,c,d)}, /*cFolder*/, /*lCallCenter*/, aEstacao, nOpc)
                    
                    If lMsErroAuto

                        aErro := GetAutoGRLog()

                        For nCont := 1 To Len(aErro)
                            cErro += aErro[nCont] + CRLF
                        Next nCont

                        self:lSucesso := .F.
                        self:cTipoRet := "ESTACAO"
                        self:cRetorno += cErro
                    Else
                        ConfirmSx8()
                        cRetorno := &("SLG->" + cCmpRet)                    
                    EndIf

                endIf
            Else

                If self:cModelo == "2" .And. (cTab)->LG_NFCE == "F"

                    self:lSucesso := .F.
                    self:cTipoRet := "ESTACAO"
                    self:cRetorno += I18n("A estação #1 do Protheus não se refere ao tipo NFCE.", {(cTab)->LG_CODIGO} ) + CRLF
                Else

                    cRetorno := &(cTab + "->" + cCmpRet)
                EndIf
            EndIf

            (cTab)->( DbCloseArea() )
        EndIf
    Else

        self:lSucesso := .F.
        self:cTipoRet := "ESTACAO"
        self:cRetorno += I18n("Não foi realizado o De/Para da Filial: CodigoLoja=[#1]", self:cCodLoja ) + CRLF
    EndIf

	Asize(aEstacao, 0)
	ASize(aErro   , 0)

    RestArea(aArea)

    LjGrvLog("LayEstAuto", "Retorno da geração automática de estação SLG:", {cRetorno, self:lSucesso, self:cRetorno})

Return cRetorno

//--------------------------------------------------------
/*/{Protheus.doc} getNumNota
Cria numero de nota de entrada para integracao LIVE

@param 		cSerie      -> NUmero de Serie da Nota 
@param 		lControle   -> Variavel de Controle
@author  	Varejo
@version 	1.0
@since      15/12/2021
@return	    cDoc       -> Retorna do Doc - Nota de Entrada
/*/
//--------------------------------------------------------
Method getNumNota(cSerie) Class RmiBuscaObj
Local aNotas          := {}
Local cChaveInt       := ""
Default cSerie        := ""

self:cNumDoc := IIF(Empty(self:cNumDoc),self:DePara('SF1',Alltrim(MHQ->MHQ_CHVUNI), 2, 0),self:cNumDoc)
        
If Empty(self:cNumDoc)
    If !Empty(cSerie)        
        If ljxDNota(cSerie,,,,aNotas)
            aNotas          := FWGetSX5( "01" , cSerie)
            self:cNumDoc    := aNotas[1][4]
            LjGrvLog("getNumNota","Gerado uma nova nota para processamento da Nota de Entrada - Num: " + aNotas[1][4],cSerie)
            cChaveInt := self:DePara('SM0', self:oRegistro:_Destinatario:Text, 1, 0)+"|"+self:cNumDoc+"|"+cSerie
            RmiDePaGrv(MHQ->MHQ_ORIGEM  , "SF1","F1_DOC",MHQ->MHQ_CHVUNI, cChaveInt,.T.,MHQ->MHQ_UUID)
            LjGrvLog("getNumNota","Gerado De-Para NOTA DE ENTRADA UUID:  "+MHQ->MHQ_UUID +" CHAVE : " + cChaveInt)
            self:lSucesso := .T. // quando não existe de-para lSucesso é alterado para Falso retornando erro para MHQ
            self:CRETORNO := ""// Restaura a o lSucesso e cRetorno.
        Else
            self:lSucesso := .F. 
            self:CRETORNO := "Serie : "+cSerie+" inexistente na Tabela 01 do SX5. Informe esta ocorrencia ao Administrador do Sistema."
            LjGrvLog("F1_DOC",self:CRETORNO)
        EndIf
    EndIf
EndIf

return self:cNumDoc 

//-------------------------------------------------------------------
/*/{Protheus.doc} IgnoraPub
Metodo que define se ignora uma publicação

@type    method
@return  Lógico, Define se o registro deve ser ignorado na publicação
@author  Rafael Tenorio da Costa
@since   12/05/2022
@version 12.1.33
/*/
//--------------------------------------------------------------------
Method IgnoraPub() Class RmiBuscaObj
    //Implementação esta na classe filha
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} setChaveUnica
//Metodo que atualiza a propriedade cChaveUnica a partir da configuração do processo. oConfProce["ChaveUni"]

@type    method
@param   jRegistro, JsonObject, Com os dados do registro que será publicado
@author  Rafael Tenorio da Costa
@since   17/05/2022
@version 12.1.33
/*/
//--------------------------------------------------------------------
Method setChaveUnica(jRegistro) Class RmiBuscaObj
    
    Local nCont  := 0
    Local aChave := {}    
    Local nChave := 0
    Local xAux   := Nil

    self:cChaveUnica := ""

    For nCont := 1 To Len( self:oConfProce["ChaveUni"] )

        aChave := StrToKarr( self:oConfProce["ChaveUni"][nCont], ":")
        nChave := 1
        xAux   := jRegistro[ aChave[nChave] ]

        //Verifica se é um objeto
        While ValType(xAux) == "J"
            nChave++
            xAux := xAux[ aChave[nChave] ]            
        EndDo

        self:cChaveUnica += cValToChar(xAux) + "|"

    Next nCont

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IgnoraPub
Método responsável por realizar o reprocessamento de dados recebidos

@type    method
@author  Evandro Pattaro
@since   07/03/2023
@version 12.1.2210
/*/
//--------------------------------------------------------------------
Method Reprocessa() Class RmiBuscaObj
    //Implementação esta na classe filha
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} deletaPublicacao 
Exclui os dados de uma publicação

@type    method
@author  Rafael Tenorio da Costa
@since   28/03/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Method deletaPublicacao() Class RmiBuscaObj

    Local aArea := GetArea()

    Begin Transaction

        //Deleta log MHL
        self:DelLog(MHQ->MHQ_UUID)

        //Deleta De/Para MHM
        self:DelDePara(MHQ->MHQ_UUID)
        
        //Deleta distribuição MHR
        self:DelDistrib(MHQ->MHQ_UUID)

        //Deleta o publicação MHQ
        RecLock("MHQ", .F.)
            MHQ->( DbDelete() )
        MHQ->( MsUnLock() )

    End Transaction

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} versaoLayout
Método responsável por carrega a versão dos layouts

@type    Method
@author  Rafael Tenorio da Costa
@since   20/01/2025
@version 12.1.2510
/*/
//--------------------------------------------------------------------
Method versaoLayout() Class RmiBuscaObj

    if self:oLayoutPub:hasProperty("configPSH") .and. self:oLayoutPub["configPSH"]:hasProperty("Version")
        self:nVerLayPub := iif( valType(self:oLayoutPub["configPSH"]["Version"]) == "C", val(self:oLayoutPub["configPSH"]["Version"]), self:oLayoutPub["configPSH"]["Version"] )
    endif

Return Nil
