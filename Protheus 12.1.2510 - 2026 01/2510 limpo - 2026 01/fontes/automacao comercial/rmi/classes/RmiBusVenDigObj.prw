#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIBUSVENDIGOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusVenDigObj
Classe responsÃ¡vel pela busca de dados no Venda Digital
    
/*/
//-------------------------------------------------------------------
Class RmiBusVenDigObj From RmiBuscaObj

    Method New(cAssinante)
    Method Busca()                      //Metodo responsavel por buscar as informações no Assinante
    Method Confirma(cUrl)               //Metodo para confirmar a publicação do pedido
    Method TrataRetorno()               //Metodo para buscar/Get as publicações no Venda Digital como Exemplo: Pedido
    Method PreExecucao()                //Metodo com as regras para efetuar conexão com o sistema de destino
    Method SalvaConfig()    //Metodo que ira atualizar a a configuraçaõ do assinante, com o novo token gerado
    Method SetaProcesso(cProcesso)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
MÃ©todo construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBusVenDigObj
    
    _Super:New(cAssinante)
    Self:cToken := IIF(Self:oConfAssin["token"] == Nil, "", Self:oConfAssin["token"])

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informações no Assinante

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusVenDigObj

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        self:oBusca := FWRest():New("")        
        self:oBusca:SetPath(self:oConfProce["url"])
        self:oBusca:SetPostParams(EncodeUTF8(Self:cBody))

        If self:oBusca:Post( {"Content-Type:application/json"} )

            self:cRetorno := DeCodeUTF8(self:oBusca:GetResult())
            LjGrvLog(" RMIBusVenDigObj ", "Retorno do Post " ,{Self:cRetorno})
            If self:oRetorno == Nil
                self:oRetorno := JsonObject():New()
            EndIf
            self:oRetorno:FromJson(self:cRetorno)
            self:cRetorno := ""
            //Centraliza os retorno permitidos
            self:TrataRetorno()
        ElseIf Self:oBusca:oResponseH:cStatusCode == "403"
            Self:cToken := ""
            Self:PreExecucao() 
            LjGrvLog(" RMIBusVenDigObj ", "Foi retornado o erro 403 (Token Invalido), vamos refazer o token e enviar novamente a informação.")
        Else    
            self:lSucesso := .F.
            self:cRetorno := self:oBusca:GetLastError() + " - [" + self:oConfProce["url"] + "]" + CRLF
            LjGrvLog(" RMIBusVenDigObj ", "Retorno do Post Falhou " ,{Self:cRetorno})
        EndIf
        
    EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo para carregar a publicação de cadastro

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusVenDigObj

    Local nPos    := 0
    Local aConfirma := {}
    Local nConfirma := 0
    Local oConteudo := JsonObject():New()
    Local oJsonConf := Nil
  
    If Len(self:oRetorno["data"]) == 0
        self:lSucesso := .F.
        self:cRetorno := I18n("Não há dados a serem baixados:", { ProcName(), self:cRetorno} )   
        LjGrvLog("RmiBusVenDigObj", self:cRetorno)
    Else

        For nPos:=1 To Len(self:oRetorno["data"])

            self:cEvento    := "1"
            self:oRegistro  := self:oRetorno["data"][nPos]:toJson()
            self:cMsgOrigem := self:oRegistro
            
            oConteudo:FromJson(self:cMsgOrigem)
            
            //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
            self:setChaveUnica(oConteudo)

            If self:AuxExistePub()
                Loop
            EndIf

            self:Grava()
            nConfirma++
            aAdd( aConfirma, JsonObject():New() )
            If self:lSucesso                   
                aConfirma[nConfirma]["order_id"] := self:oRetorno["data"][nPos]["IdOrigem"]
                aConfirma[nConfirma]["status"]   := IIF(self:lSucesso,self:oRetorno["data"][nPos]["StatusPedido"],"error")
                aConfirma[nConfirma]["read"]     := IIF(self:lSucesso,"read","noread")
                aConfirma[nConfirma]["content"]  := ""
            EndIf

            FwFreeObj(self:oRegistro)
            self:oRegistro  := Nil

        Next nPos
        
        LjGrvLog("RmiBusVenDigObj", "Final da busca de vendas")
    EndIf        

    
    If Len(aConfirma) > 0

        If self:oConfirma == Nil
            self:oConfirma := JsonObject():New()
            oJsonConf      := JsonObject():New()
        EndIf
        oJsonConf["token"]:= Self:cToken
        oJsonConf["status"]:= aConfirma
        self:oConfirma:Set(oJsonConf)
    EndIf

    FwFreeArray(aConfirma)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiBusVenDigObj
    
    Local oRequest  := Nil //Json para geracao da chave de acesso

    If !Empty(Self:cToken)
        Return Nil
    EndIf

    oRequest  := JsonObject():New()

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json    
    If Self:oPreExecucao == Nil
        Self:oPreExecucao := FWRest():New("")

        //Seta a url para pegar o token
        Self:oPreExecucao:SetPath( Self:oConfAssin["url_token"] )
    EndIf
    
    If !Empty(Self:oConfAssin["usuario"]) .AND. !Empty(Self:oConfAssin["senha"])

        oRequest["email"]       := Self:oConfAssin["usuario"]
        oRequest["password"]    := Self:oConfAssin["senha"]
        
        //Seta o corpo do Post
        Self:oPreExecucao:SetPostParams( oRequest:ToJson() )

        //Busca o token
        If Self:oPreExecucao:Post( {"Content-Type:application/json"} )
            
            Self:cRetorno := Self:oPreExecucao:GetResult()
            
            LjGrvLog(" RmiEnviaObj ", "Self:oPreExecucao:Post() = .T. => ",{Self:cRetorno })
            
            If Self:oRetorno == Nil
                Self:oRetorno := JsonObject():New()
            EndIf
            Self:oRetorno:FromJson(self:cRetorno)

            Self:lSucesso   := .T.
            Self:cToken     := Self:oRetorno["token"]
            Self:SalvaConfig()
        Else

            Self:lSucesso := .F.
            Self:cRetorno := Self:oPreExecucao:GetLastError() + " - [" + Self:oConfAssin["url_token"] + "]"
            LjGrvLog(" RmiEnviaObj ", "Self:oPreExecucao:Post() = .F. => ",{Self:cRetorno})
        EndIf
    Else
        Self:lSucesso := .F.
        Self:cRetorno := STR0010 //"Tags de usuario e/ou senha não foram informados no cadastro de configuração do assinante, não foi possivel gerar o token."
        LjGrvLog(" RmiEnviaObj ", "Geração do token assinante Venda Digital",{Self:cRetorno })
    EndIf

    FwFreeObj(oRequest)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirmação do recebimento

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma(cUrl) Class RmiBusVenDigObj
    Local cJson     := ""
    Default cUrl    := Self:oConfAssin["url_Confirma"]

    If ValType(self:oConfirma) != "U" .AND. cUrl <> NIL
        
        If self:oEnvia == Nil
            self:oEnvia := FWRest():New("")
        EndIf

        Self:oEnvia:SetPath( cUrl)
        cJson := self:oConfirma:toJson()
        Self:oEnvia:SetPostParams(EncodeUTF8(cJson))
        
        LjGrvLog(GetClassName(self), "Envio de confirmação da busca." , {self:cProcesso, cJson} )
        
        If self:oEnvia:Post( {"Content-Type:application/json"})
            self:cRetorno := self:oEnvia:GetResult()
        Else
            self:lSucesso := .F.
            self:cRetorno := self:oEnvia:GetLastError() + " - " + self:oEnvia:CRESULT + "." 
        EndIf
        LjGrvLog( GetClassName(self), "Retorno de confirmação da busca." , {self:cProcesso, cJson, self:lSucesso, self:cRetorno} )
    EndIf
        
Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaConfig
Metodo que ira atualizar a configuração do assinante.
Por enquanto atualiza o token

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method SalvaConfig() Class RmiBusVenDigObj

    If !Self:oConfAssin["token"] == Self:cToken
        
        Self:oConfAssin["token"] := Self:cToken
        MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
        If MHO->( DbSeek( xFilial("MHO") + Self:cAssinante ) )
            RecLock("MHO", .F.)
                MHO->MHO_CONFIG := Self:oConfAssin:ToJson()
                MHO->MHO_TOKEN  := ""
            MHO->( MsUnLock() )
        EndIf
   endif
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@author  Everson S P Junior.
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBusVenDigObj
    
    self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

Return Nil
