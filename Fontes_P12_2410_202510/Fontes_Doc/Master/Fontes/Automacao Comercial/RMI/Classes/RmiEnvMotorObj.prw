#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvMotorObj
Classe responsável pelo envio de dados ao RmiEnvMotorObj

/*/
//-------------------------------------------------------------------
Class RmiEnvMotorObj From RmiEnviaObj
    Data oTokenItem     As Objetc       //Objeto JsonObject de configuração do cBody da integração

    Method New()            //Metodo construtor da Classe
    Method PreExecucao()    //Metodo com as regras para efetuar conexão com o sistema de destino
    Method Envia()          //Metodo responsavel por enviar a mensagens ao RmiEnvMotorObj

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvMotorObj
    //cProcesso para tratamento de Thread de processos.
    _Super:New("MOTOR PROMOCOES", cProcesso)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvMotorObj
    Self:lSucesso   := .T.    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao sistema de destino

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvMotorObj

    
    If Self:oEnvia == Nil
        Self:oEnvia := FWRest():New("")
    EndIf

    Self:oEnvia:SetPath( self:oConfProce["url"] )
    self:oEnvia:SetPostParams(EncodeUTF8(Self:cBody))
    LjGrvLog(" RmiEnvMotorObj ", "Method Envia() no oEnvia:SetPostParams(cBody) " ,{Self:cBody})

    If Self:oEnvia:Post( {"Content-Type:application/json"} ) 
        
        Self:cRetorno := DeCodeUTF8(Self:oEnvia:GetResult())
        LjGrvLog(" RmiEnvMotorObj ", "Retorno do Post " ,{Self:cRetorno})
        
        Self:lSucesso := IIF("SUCESSO" $ UPPER(Alltrim(Self:cRetorno)),.T.,.F.)
        
        LjGrvLog(" RmiEnvMotorObj ", "Verifica se teve sucesso => " ,{Self:lSucesso})
    Else
        Self:lSucesso   := .F.
        Self:cRetorno   := iif(Self:oEnvia:oResponseH:cStatusCode == "400", Self:oEnvia:cResult ,Self:oEnvia:GetLastError() + " - [" + Self:oConfProce["url"] + "]" + CRLF)                
        LjGrvLog(" RmiEnvMotorObj ", "Não obteve sucesso no retorno => " ,{self:cRetorno}) 
    EndIf

Return Nil

