#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVVENDADIGITALOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvVendaDigitalObj
Classe responsável pelo envio de dados ao Venda Digital (PluginBot)

/*/
//-------------------------------------------------------------------
Class RmiEnvVendaDigitalObj From RmiEnviaObj
    Data oTokenItem     As Objetc       //Objeto JsonObject de configuração do cBody da integração

    Method New()            //Metodo construtor da Classe
    Method PreExecucao()    //Metodo com as regras para efetuar conexão com o sistema de destino
    Method Envia()          //Metodo responsavel por enviar a mensagens ao Venda Digital
    Method SalvaConfig()    //Metodo que ira atualizar a a configuraçaõ do assinante, com o novo token gerado

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso,cAssinante) Class RmiEnvVendaDigitalObj
    //cProcesso para tratamento de Thread de processos.
    _Super:New(cAssinante, cProcesso) 
    Self:cToken := IIF(Self:oConfAssin == Nil .OR. Self:oConfAssin["token"] == Nil, "", Self:oConfAssin["token"])
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvVendaDigitalObj
    
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
        Self:cRetorno := STR0001 //"Tags de usuario e/ou senha não foram informados no cadastro de configuração do assinante, não foi possivel gerar o token."
        LjGrvLog(" RmiEnviaObj ", "Geração do token assinante Venda Digital",{Self:cRetorno })
    EndIf

    FwFreeObj(oRequest)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao sistema de destino

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvVendaDigitalObj

    Local lReenvia      := .T. //Controla o fluxo de envio
    Local nTentativa    := 1 //Numero para tentativa de reenvio da informação

    If Self:oEnvia == Nil
        Self:oEnvia := FWRest():New("")
    EndIf

    Self:oEnvia:SetPath( self:oConfProce["url"] )

    While lReenvia

        //Atualiza o body enviado para o caso do token estar inválido
        self:oEnvia:SetPostParams(EncodeUTF8(Self:cBody))
        LjGrvLog(" RmiEnviaObj ", "Method Envia() no oEnvia:SetPostParams(cBody) " ,{Self:cBody})

        If Self:oEnvia:Post( {"Content-Type:application/json"} ) 
            
            Self:cRetorno := DeCodeUTF8(Self:oEnvia:GetResult())
            LjGrvLog(" RmiEnviaObj ", "Retorno do Post " ,{Self:cRetorno})
            If Self:oRetorno == Nil
                Self:oRetorno := JsonObject():New()
            EndIf
            Self:oRetorno:FromJson(Self:cRetorno)

            If SubStr(Self:oConfProce["tagretorno"], 1, 1) == "&"
                Self:lSucesso :=  &( SubStr(Self:oConfProce["tagretorno"], 2))  
            Else
                Self:lSucesso := Self:oRetorno[ Self:oConfProce["tagretorno"] ]
            EndIf

            LjGrvLog(" RmiEnviaObj ", "Verifica se teve sucesso => " ,{Self:lSucesso})
            
            Self:cChaveExterna := ""
            lReenvia := .F.
        Else
            If Self:oEnvia:oResponseH:cStatusCode == "403" .AND. nTentativa == 1
                nTentativa  += 1
                Self:cToken := ""
                Self:PreExecucao() 
                LjGrvLog(" RmiEnviaObj ", "Foi retornado o erro 403 (Token Invalido), vamos refazer o token e enviar novamente a informação.")
            Else
                lReenvia        := .F.
                Self:lSucesso   := .F.
                Self:cRetorno   := iif(Self:oEnvia:oResponseH:cStatusCode == "400", Self:oEnvia:cResult ,Self:oEnvia:GetLastError() + " - [" + Self:oConfProce["url"] + "]" + CRLF)                
                LjGrvLog(" RmiEnviaObj ", "Não obteve sucesso no retorno => " ,{self:cRetorno}) 
            EndIf
        EndIf
    EndDo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaConfig
Metodo que ira atualizar a configuração do assinante.
Por enquanto atualiza o token

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method SalvaConfig() Class RmiEnvVendaDigitalObj

    Self:oConfAssin["token"] := Self:cToken
    
    MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
    If MHO->( DbSeek( xFilial("MHO") + PadR(Self:cAssinante, TamSx3("MHO_COD")[1]) ) )
        RecLock("MHO", .F.)
            MHO->MHO_CONFIG := Self:oConfAssin:ToJson()
            MHO->MHO_TOKEN  := ""
        MHO->( MsUnLock() )
    EndIf
    If !Empty(Self:cBody) // Atualizar o Token no Layout do Processo a ser transmitido.
        Self:oTokenItem := JsonObject():New()
        Self:oTokenItem:FromJson(AllTrim(Self:cBody))
        Self:oTokenItem["token"]  = Self:cToken 
        Self:cBody := Self:oTokenItem:ToJson()
    EndIf
Return Nil
