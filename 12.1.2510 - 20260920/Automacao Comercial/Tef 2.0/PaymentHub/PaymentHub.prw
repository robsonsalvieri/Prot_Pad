#include "PROTHEUS.CH"
#include "msobject.ch"
#include "PAYMENTHUB.CH"

User function xxteste()  
     //Metodos para testes.
    RPCSETENV("99", "01",,,"FRT")                         
    oPayment := PaymentHub():New("00000001","BRL","P400Plus-275421821","PDV003","protheus","admin","LEA@65582367","paymenthub_bdb7540a88064044980bc1a2e2dd1d07_ro","totvsraas@12345")
    
    /*
    oPayment:PaymentTransaction(Nil,"123456789",10.00,Nil,Nil,Nil,1,10)
    oResult := oPayment:ResultPaymentTransaction()
    oPayment:RefundTransaction(oResult["id"],oResult["processorTransactionId"],Nil,oResult["externalTransactionId"],10.59,Nil,Nil,Nil)
    oResult := oPayment:ResultRefundTransaction()
    oPayment:ReceiptTransaction(oResult["id"])
    oResult := oPayment:ResultReceiptTransaction()
    oPayment:InputTextTransaction(Nil,Nil,Nil,"Informar seu CPF")
    oResult := oPayment:ResultInputTextTransaction()
    oPayment:ListTerminalsTransaction()
    oResult := oPayment:ResultListTerminalsTransaction()
    oPayment:MethodsAvaliables()
    oResult := oPayment:ResultMethodsAvaliables()
    */

    oPayment:LinkPaymentTransaction(Nil,"123456789",100.09,Nil,Nil,Nil,Nil,"ame")
    oResult := oPayment:ResultLinkPaymentTransaction()

    oPayment:StatusLinkPaymentTransaction(oResult["processorTransactionId"])
    oResult := oPayment:ResultStatusLinkPaymentTransaction()
    
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PaymentHub
Classe responsavel pela comunicação com o PaymentHub

@type       Class
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return
/*/
//-------------------------------------------------------------------------------------

Class PaymentHub

    Method New()          CONSTRUCTOR

    // -- Tratamentos de erros e integridade
    Method CheckIntegrity()             // -- Checa a integridade dos dados para consumir as API's
    Method SetMessageError()
    Method CleanErrors()                // -- Limpa mensagens de erro
    Method GetStatus()

    // -- Limpeza dos dados da transação anterior
    Method CleanOldTransaction()

    // -- Transação de pagamento CC/CD
    Method PaymentTransaction()         // -- Realiza uma transação
    Method ResultPaymentTransaction()

    // -- Geração/Manutenão do Token
    Method GetToken()                   // -- Busca o Token
    Method ExpirationDate()
    Method OutOfDate()

    // -- Estorno de transação.
    Method RefundTransaction()
    Method ResultRefundTransaction()

    // -- Reimpressão
    Method ReceiptTransaction()
    Method ResultReceiptTransaction()

    // -- Enviar / Receber informações dos PinPads
    Method InputTextTransaction()
    Method ResultInputTextTransaction()

    // -- Listar terminais
    Method ListTerminalsTransaction()
    Method ResultListTerminalsTransaction()

    // -- Listar Metodos de pagamento disponiveis 
    Method MethodsAvaliables()
    Method ResultMethodsAvaliables()

    Method LinkPaymentTransaction()
    Method ResultLinkPaymentTransaction()

    Method StatusLinkPaymentTransaction()
    Method ResultStatusLinkPaymentTransaction()
    Method SetStatusLinkPaymentTransaction()

    Data cTenant                         
    Data cUserName                       
    Data cPassword                       
    Data cClientId                       
    Data cClientSecret   
    Data cEnvironment                

    Data cURL 
    Data cURLRAC                           

    Data cToken                          
    Data cTimeExpiration                 
    Data dDateExpiration                 

    Data lStatus                       
    Data aMessageError                   

    Data cCodeComp                       
    Data cCurrency                       
    Data cIdPinPed                       
    Data cIdPos                          

    // -- Devem ser limpas por transação
    Data oResultPaymentTransaction        
    Data oResultRefundTransaction        
    Data oResultReceiptTransaction       
    Data oResultInputTextTransaction     
    Data oResultListTerminalsTransaction 
    Data oResultMethodsAvaliables
    Data oResultLinkPaymentTransaction
    Data oResultStatusLinkPaymentTransaction

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa
@param cCurrency, Caracter, Moeda atual
@param cIdPinPed, Caracter, Terminal
@param cIdPos, Caracter, Caixa (Ponto de venda)
@param cTenant, Caracter, Empresa cadastrada no RAC
@param cUserName, Caracter, Usuario RAC
@param cPassword, Caracter, Senha RAC
@param cClientId, Caracter, Identificador do produto no RAC
@param cClientSecret, Caracter, Senha do identificador
@param cToken
@param dDateExpiration
@param cTimeExpiration
@param cEnvironment

@return PaymentHub, Objeto, Objeto construido.
/*/
//-------------------------------------------------------------------------------------

Method New(cCodeComp,cCurrency,cIdPinPed,cIdPos,cTenant,cUserName,cPassword,cClientId,cClientSecret,cToken,dDateExpiration,cTimeExpiration,cEnvironment) Class PaymentHub
    
    Default cIdPinPed    := ""
    Default cToken       := ""
    Default cEnvironment := "2" //1=Homologação;2=Produção

    Self:cTenant         := cTenant
    Self:cUserName       := cUserName
    Self:cPassword       := cPassword
    Self:cClientId       := cClientId
    Self:cClientSecret   := cClientSecret
    Self:cEnvironment    := cEnvironment
    
    If cEnvironment == "1"      // -- Homologação  
        Self:cURL            := "https://api-techfinpagamentos.staging.totvs.app"
        Self:cURLRAC         := "https://" + Self:cTenant + ".rac.staging.totvs.app"
    ElseIf cEnvironment == "2" // --  Produção
        Self:cURL            := "https://api-techfinpagamentos.totvs.app"
        Self:cURLRAC         := "https://" + Self:cTenant + ".rac.totvs.app"
    EndIf
                            
    Self:cToken          := cToken

    Self:cTimeExpiration := cTimeExpiration
    Self:dDateExpiration := dDateExpiration

    Self:lStatus         := .T.
    Self:aMessageError   := {}

    Self:cCodeComp       := cCodeComp
    Self:cCurrency       := cCurrency
    Self:cIdPinPed       := cIdPinPed
    Self:cIdPos          := cIdPos

    Self:CheckIntegrity()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetMessageError
Metodo responsavel pelo indicativo de erro na classe

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cMessage, Caracter, mensagem de erro
@param cComplement

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method SetMessageError(cMessage,cComplement) Class PaymentHub
    Default cComplement := ""
    AADD(Self:aMessageError,cMessage + cComplement) 
    LjGrvLog("[PaymentHub - Called ->" + ProcName(1) + " Erro]",cMessage + cComplement, cComplement,,.T.)
    Self:lStatus := .F. 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Metodo responsavel por devolver o estatus atual da classe e as mensagems de erro caso existam.

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method GetStatus() Class PaymentHub
Return {Self:lStatus,Self:aMessageError}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckIntegrity
Metodo responsavel verificar a integridade geral da classe
@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method CheckIntegrity() Class PaymentHub

    If Empty(Self:cCodeComp)
        Self:SetMessageError("Empresa Não fornecido.") // "Empresa Não fornecido."
    EndIf

    If Empty(Self:cCurrency)
        Self:SetMessageError("Moeda Não fornecido.") // "Moeda Não fornecido."
    EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CleanErrors
Metodo responsavel limpar as mensagem de erro da classe.
@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method CleanErrors() Class PaymentHub
    Self:lStatus       := .T.
    Self:aMessageError := {}
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CleanOldTransaction
Metodo responsavel limpar os dados da transação anterior, no inicio de uma nova transação 
os objetos de retornos são limpos. 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method CleanOldTransaction() Class PaymentHub
    FreeObj(Self:oResultPaymentTransaction)             // -- Dados de trasações
    FreeObj(Self:oResultRefundTransaction)              // -- Dados de estorno
    FreeObj(Self:oResultReceiptTransaction)             // -- Dados de Reimpressão
    FreeObj(Self:oResultInputTextTransaction)           // -- Dados de Envio de texto
    FreeObj(Self:oResultListTerminalsTransaction)       // -- Dados de busca de terminais
    FreeObj(Self:oResultMethodsAvaliables)              // -- Metodos disponiveis
    FreeObj(Self:oResultLinkPaymentTransaction)         // -- Dados de Link de pagamento
    FreeObj(Self:oResultStatusLinkPaymentTransaction)   // -- Dados de status de link de pagamento / qr-code

    // -- Limpa os erros das transações anteriores 
    Self:CleanErrors()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PaymentTransaction
Metodo responsavel por realizar um transação sendo ela, debito, credito a vista ou credito parcelado. 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa
@param cIdInternal, Caracter, codigo unico de transação
@param nAmount, Numerico, valor da transação
@param cCurrency, Caracter, Moeda atual
@param cIdPinPed, Caracter, Terminal
@param cIdPos, Caracter, Caixa (Ponto de venda)
@param nCardType, Numerico, tipo da transação, se credito ou debido 
@param nParcel, Numerico, Parcelas da transação

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method PaymentTransaction(cCodeComp,cIdInternal,nAmount,cCurrency,cIdPinPed,cIdPos,nCardType,nParcel) Class PaymentHub
    Local cParams      := ""
    Local aHeadStr     := {}                 
    Local cResult      := ""
    Local oRestClient  := FWRest():New(Self:cURL)               
    Local oJson        := JsonObject():new()
    Local cToken       := ""
    Local cCardType    := ""

    Default cCodeComp :=  Self:cCodeComp
    Default cCurrency :=  Self:cCurrency
    Default cIdPinPed :=  Self:cIdPinPed
    Default cIdPos    :=  Self:cIdPos

    If Empty(Self:cIdPinPed) .And. !Empty(cIdPinPed)
        Self:cIdPinPed := cIdPinPed
    EndIf

    If Empty(Self:cIdPos) .And. !Empty(cIdPos)
        Self:cIdPos := cIdPos
    EndIf

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        
        cToken := Self:GetToken()

        If nCardType == 1
            cCardType := "CreditCard"
        Else
            cCardType := "DebitCard"
            If nParcel > 1
                Self:SetMessageError("Não é permitido pagamentos com debito parcelado.")   
            EndIf 
        EndIf  
       
        If Empty(cCodeComp) .Or. Empty(cIdInternal) .Or. Empty(nAmount) .Or. Empty(cCurrency) .Or.;
            Empty(cIdPinPed) .Or. Empty(cIdPos) .Or. Empty(nCardType) .Or. Empty(nParcel)
            Self:SetMessageError("Um ou mais campo obrigatorio não foi preenchido.")
        EndIf 
       
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            cParams := '{'
            cParams += '"externalBusinessUnitId"    : "' + cCodeComp                + '",' 
            cParams += '"externalTransactionId"     : "' + cIdInternal              + '",'
            cParams += '"amount"                    :  ' + cValtochar(nAmount)      + ' ,'
            cParams += '"currency"                  : "' + cCurrency                + '",'
            cParams += '"posPadId"                  : "' + cIdPinPed                + '",'
            cParams += '"externalPosId"             : "' + cIdPos                   + '",' // -- alterar para externalPosId
            cParams += '"card"                      : {'
            cParams +=                                  '"type": "'                 + cCardType + '"'
            cParams +=                              '},'
            cParams += '"installments"              : {'
            cParams +=                                  '"numberOfInstallments": ' + cValtoChar(nParcel)
            cParams +=                              '}'
            cParams += '}'

            oRestClient:setPath("/payments-transacting/api/v1/transactions/authorize")
            oRestClient:SetPostParams(cParams)

            If oRestClient:Post(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultPaymentTransaction := oJson
                Else
                    Self:SetMessageError("Não foi possivel realizar o Parse do retorno da API, ERRO: " + cResult)
                EndIf           
            Else
                Self:SetMessageError("Retorno da API: ",oRestClient:cResult)
                Self:SetMessageError("ERROR: ",oRestClient:GetLastError())
            EndIf   
        EndIf 
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RefundTransaction
Metodo responsavel por realizar um transação sendo ela, debito, credito a vista ou credito parcelado. 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cIdtransaction, Caracter, Transação
@param cProcessorTransactionId, Caracter, Id do processador
@param cCodeComp, Caracter, Codigo da empresa
@param cExternalTransactionId, Caracter, codigo unico de transação
@param nAmount, Numerico, valor da transação
@param cCurrency, Caracter, Moeda atual
@param cIdPinPed, Caracter, Terminal
@param cIdPos, Caracter, Caixa (Ponto de venda)

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method RefundTransaction(cIdtransaction,cProcessorTransactionId,cCodeComp,cExternalTransactionId,nAmount,cCurrency,cIdPinPed,cIdPos) Class PaymentHub
    Local cParams      := ""
    Local aHeadStr     := {}                 
    Local cResult      := ""
    Local oRestClient  := FWRest():New(Self:cURL)               
    Local oJson        := JsonObject():new()
    Local cToken       := ""

    Default cCodeComp                := Self:cCodeComp
    Default cCurrency               :=  Self:cCurrency
    Default cIdPinPed               :=  ""
    Default cIdPos                  :=  Self:cIdPos

    LjGrvLog("Totvs Pagamentos Digitais","Metodo RefundTransaction - Inicio",,.T.,.T.)

    If Empty(Self:cIdPinPed) .And. !Empty(cIdPinPed)
        Self:cIdPinPed := cIdPinPed
    EndIf

    If Empty(Self:cIdPos) .And. !Empty(cIdPos)
        Self:cIdPos := cIdPos
    EndIf

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        cToken := Self:GetToken()
        
        If Empty(cIdtransaction) .Or. Empty(cProcessorTransactionId) .Or. Empty(cCodeComp) .Or. Empty(cExternalTransactionId) .Or.;
            Empty(nAmount) .Or. Empty(cCurrency) .Or. Empty(cIdPos)
            Self:SetMessageError("Um ou mais campo obrigatorio não foi preenchido.")
        EndIf 
       
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            cParams := '{'
            cParams += '"transactionId"          : "' + cIdtransaction           + '",' 
            cParams += '"processorTransactionId" : "' + cProcessorTransactionId  + '",'
            cParams += '"externalBusinessUnitId" : "' + cCodeComp                + '",'
            cParams += '"externalTransactionId"  : "' + cExternalTransactionId   + '",'
            cParams += '"amount"                 : '  + cValTochar(nAmount)      + ' ,'
            cParams += '"currency"               : "' + cCurrency                + '",'
            cParams += '"posPadId"               : "' + cIdPinPed                + '",'
            cParams += '"externalPosId"          : "' + cIdPos                   + '"'
            cParams += '}'

            LjGrvLog("Totvs Pagamentos Digitais","Metodo RefundTransaction - Envio de comando para estorno da transacao.",cParams,,.T.)

            oRestClient:setPath("/payments-transacting/api/v2/payment/refund/")
            oRestClient:SetPostParams(cParams)

            If oRestClient:Post(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultRefundTransaction := oJson
                Else
                    Self:SetMessageError("Não foi possivel realizar o Parse do retorno da API, ERRO: " + cResult)
                EndIf           
            Else
                Self:SetMessageError("Retorno da API: ",oRestClient:cResult)
                Self:SetMessageError("ERROR: ",oRestClient:GetLastError())
            EndIf  
        EndIf  
    EndIf 

    LjGrvLog("Totvs Pagamentos Digitais","Metodo RefundTransaction - Retorno da API.",oRestClient:cResult,,.T.)
    LjGrvLog("Totvs Pagamentos Digitais","Metodo RefundTransaction - Fim",Self:GetStatus(),,.T.)

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReceiptTransaction
Metodo responsavel reimpressão

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cIdtransaction, Caracter, Transação

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method ReceiptTransaction(cIdtransaction) Class PaymentHub
    Local aHeadStr     := {}                 
    Local cResult      := ""
    Local oRestClient  := FWRest():New(Self:cURL)               
    Local oJson        := JsonObject():new()
    Local cToken       := ""

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        
        cToken := Self:GetToken()

        If Empty(cIdtransaction) 
            Self:SetMessageError("Um ou mais campo obrigatorio não foi preenchido.")
        EndIf 
        
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            oRestClient:setPath("/payments-transacting/api/v2/payment/receipt/" + cIdtransaction)

            If oRestClient:Get(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultReceiptTransaction := oJson
                Else
                    Self:SetMessageError("Não foi possivel realizar o Parse do retorno da API, ERRO: " + cResult)
                EndIf           
            Else
                Self:SetMessageError("Retorno da API: ",oRestClient:cResult)
                Self:SetMessageError("ERROR: ",oRestClient:GetLastError())
            EndIf 
        EndIf   
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultPaymentTransaction
Metodo responsavel devolver o retorno da transação

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultPaymentTransaction() Class PaymentHub
Return Self:oResultPaymentTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultRefundTransaction
Metodo responsavel devolver o retorno da estorno

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultRefundTransaction() Class PaymentHub
Return Self:oResultRefundTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultReceiptTransaction
Metodo responsavel devolver o retorno da reimpressão 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultReceiptTransaction() Class PaymentHub
Return Self:oResultReceiptTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetToken
Metodo responsavel devolver token de acesso ao RAC

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method GetToken() Class PaymentHub

    Local cParams      := ""
    Local aHeadStr     := {}                        
    Local cResult      := ""
    Local nTokenExpire := 0

    Local oRestClient  := FWRest():New(Self:cURLRAC)
    Local oJson        := JsonObject():new()

    If Self:OutOfDate() // -- Fora da validade?

        AAdd( aHeadStr, "Content-Type: application/x-www-form-urlencoded" )
        AAdd( aHeadStr, "charset: UTF-8" )
        AAdd( aHeadStr, "User-Agent: Protheus " + GetBuild() )
        
        cParams := "grant_type=password"
        cParams += "&username=" + Self:cUserName
        cParams += "&password=" + Self:cPassword
        cParams += "&scope=authorization_api"
        cParams += "&client_id=" + Self:cClientId
        cParams += "&client_secret="+ Self:cClientSecret
        
        oRestClient:setPath("/totvs.rac/connect/token")
        oRestClient:SetPostParams(cParams)

        If oRestClient:Post(aHeadStr)
            cResult := oJson:FromJson(oRestClient:GetResult())
            If ValType(cResult) == "U"                        // -- Nil indica que conseguiu popular o objeto com o Json
                Self:cToken     := oJson["access_token"]      // -- Chave de acesso
                nTokenExpire    := oJson["expires_in"] / 60   // -- Expiração do token em minutos

                Self:ExpirationDate(nTokenExpire)
            Else
                Self:SetMessageError("Não foi possivel realizar o Parse do retorno da API, ERRO: " + cResult)
            EndIf
        Else
            Self:SetMessageError("Retorno da API: ",oRestClient:cResult)
            Self:SetMessageError("ERROR: ",oRestClient:GetLastError())
        EndIf

    EndIf 

    FreeObj(oRestClient)
    FreeObj(oJson)

Return Self:cToken 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExpirationDate
Metodo responsavel converter dias em horas

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param nTime, Numerico, tempo para conversão
@param cTipo, Caracter, tipo da conversão

@return Nil, nulo
/*/
//-------------------------------------------------------------------------------------

Method ExpirationDate(nTime,cTipo) Class PaymentHub
    Local cTime       := ""
    Local nHora       := 0
    Local nDias       := 0

    Default cTipo     := "M" 

    If  Upper(cTipo) = "H"
        nTime := nTime * 60
    ElseIf Upper(cTipo) = "S"
        nTime := nTime / 60
    EndIf 

    cTime := IncTime(time(),,nTime)
    nHora := Val(SubStr(cTime,1,2))

    While  nHora > 24
        nHora := nHora - 24
        nDias ++
    End

    Self:cTimeExpiration := STRZero(nHora,2) + SubStr(cTime,3,Len(cTime))
    Self:dDateExpiration := Date() + nDias

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OutOfDate
Metodo responsavel indicar se o token esta vencido
@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Logico, Indica se o token esta vencido.
/*/
//-------------------------------------------------------------------------------------

Method OutOfDate() Class PaymentHub
    Local lRet := .F.
    If !Empty(Self:dDateExpiration) .AND. !Empty(Self:cTimeExpiration)
        If Self:dDateExpiration == Date()
            If Time() >= Self:cTimeExpiration .Or. ElapTime(Time(),Self:cTimeExpiration) <= "00:10:00"
                lRet := .T.
            EndIf
        Else
            If Self:dDateExpiration < Date()
                lRet := .T.
            EndIf
        EndIf
    Else
        lRet := .T.
    EndIf
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} InputTextTransaction
Metodo responsavel por realizar um transação sendo ela, debito, credito a vista ou credito parcelado. 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa
@param cIdPinPed, Caracter, Terminal
@param cIdPos, Caracter, Caixa (Ponto de venda)
@param cText, Caracter, texto que será apresentado no terminal.

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method InputTextTransaction(cCodeComp,cIdPinPed,cIdPos,cText) Class PaymentHub
    Local cParams     := ""
    Local aHeadStr    := {}                 
    Local cResult     := ""
    Local oRestClient := FWRest():New(Self:cURL)
    Local oJson       := JsonObject():new()
    Local cToken      := ""

    Default cCodeComp := Self:cCodeComp
    Default cIdPinPed := Self:cIdPinPed
    Default cIdPos    := Self:cIdPos

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        
        cToken := Self:GetToken()

        If Empty(cCodeComp) .Or. Empty(cIdPinPed) .Or. Empty(cIdPos) .Or. Empty(cText) 
            Self:SetMessageError(STR0001) // "Um ou mais campo obrigatorio não foi preenchido."
        EndIf 

        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            cParams := '{'
            cParams += '"externalBusinessUnitId"    : "' + cCodeComp  + '",' 
            cParams += '"posPedId"                  : "' + cIdPinPed  + '",'
            cParams += '"externalPosId"             : "' + cIdPos     + '",'
            cParams += '"outputPhrase"              : "' + cText      + '"'
            cParams += '}'

            oRestClient:setPath("/payments-transacting/api/v1/pos-ped/input/text")
            oRestClient:SetPostParams(cParams)

            If oRestClient:Post(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultInputTextTransaction := oJson
                Else
                    Self:SetMessageError(STR0002 + cResult) // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                EndIf           
            Else
                Self:SetMessageError(STR0003,oRestClient:cResult) // "Retorno da API: "
                Self:SetMessageError(STR0004,oRestClient:GetLastError()) // "ERROR: "
            EndIf
        EndIf 
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultInputTextTransaction
Metodo responsavel devolver o retorno do terminal 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultInputTextTransaction() Class PaymentHub
Return Self:oResultInputTextTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ListTerminalsTransaction
Metodo responsavel por listar os terminais disponiveis

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method ListTerminalsTransaction(cCodeComp) Class PaymentHub
    Local aHeadStr    := {}                 
    Local cResult     := ""
    Local oRestClient := FWRest():New(Self:cURL)
    Local oJson       := JsonObject():new()
    Local cToken      := ""

    Default cCodeComp := Self:cCodeComp

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]

        cToken := Self:GetToken()

        If Empty(cCodeComp) 
            Self:SetMessageError(STR0001) // "Um ou mais campo obrigatorio não foi preenchido."
        EndIf 
        
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            oRestClient:setPath("/payments-transacting/api/v1/pos-ped/" + cCodeComp)
         
            If oRestClient:Get(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultListTerminalsTransaction := oJson
                Else
                    Self:SetMessageError(STR0002 + cResult) // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                EndIf           
            Else
                Self:SetMessageError(STR0003,oRestClient:cResult) // "Retorno da API: "
                Self:SetMessageError(STR0004,oRestClient:GetLastError()) // "ERROR: "
            EndIf 
        EndIf   
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultListTerminalsTransaction
Metodo responsavel devolver o retorno do terminal 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultListTerminalsTransaction() Class PaymentHub
Return Self:oResultListTerminalsTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MethodsAvaliables
Retorna os metodos de pagamentos disponiveis para a empresa

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cIdPos, Caracter, Codigo do PDV
@param cCodeComp, Caracter, Codigo da empresa

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method MethodsAvaliables(cIdPos,cCodeComp) Class PaymentHub
    Local aHeadStr     := {}                 
    Local cResult      := ""
    Local oRestClient  := FWRest():New(Self:cURL)               
    Local oJson        := JsonObject():new()
    Local cToken       := ""

    Default cIdPos       := Self:cIdPos
    Default cCodeComp    := Self:cCodeComp

    LjGrvLog("TPD"," MethodsAvaliables - Inicio",,,.T. )

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        
        cToken := Self:GetToken()

        If Empty(cIdPos) 
            Self:SetMessageError(STR0001) // "Um ou mais campo obrigatorio não foi preenchido."
            LjGrvLog("TPD"," MethodsAvaliables - cIdPos -> Um ou mais campo obrigatorio não foram preenchidos.",,,.T. )
        EndIf 
        
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            oRestClient:setPath("/payments-transacting/api/v3/payment/link/methods/availables/" + cCodeComp)
            
            If oRestClient:Get(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultMethodsAvaliables := oJson
                    LjGrvLog("TPD"," MethodsAvaliables - Retorno dos metodos de pagamento", Self:oResultMethodsAvaliables,,.T.)
                Else
                    Self:SetMessageError(STR0002 + cResult) // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                    LjGrvLog("TPD"," MethodsAvaliables - Não foi possivel realizar o Parse do retorno da API, ERRO:", cResult,,.T. )
                EndIf           
            Else
                Self:SetMessageError(STR0003,oRestClient:cResult) // "Retorno da API: "
                Self:SetMessageError(STR0004,oRestClient:GetLastError()) // "ERROR: "
                LjGrvLog("TPD"," MethodsAvaliables - Retorno da API - ERRO:", oRestClient:GetLastError(),,.T. )
            EndIf 
        EndIf  
    Else
        LjGrvLog("TPD"," MethodsAvaliables -  Status atual da classe PaymentHub ", Self:GetStatus()[1],,.T.)
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultMethodsAvaliables
Metodo responsavel devolver o retorno do MethodsAvaliables 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultMethodsAvaliables() Class PaymentHub
Return Self:oResultMethodsAvaliables

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LinkPaymentTransaction
Metodo responsavel realizar o estorno da transação

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa
@param cIdInternal, Caracter, Id interno da venda (external para o paymenthub)
@param nAmount, Numerico, Valor da transação
@param cCurrency, Caracter, Moeda
@param cIdPos, Caracter, Codigo do PDV
@param cIdCustomer, Caracter, Codigo do cliente
@param cEmail, Caracter, Email do cliente
@param cMethod, Caracter, Carteira selecionada 

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method LinkPaymentTransaction(cCodeComp,cIdInternal,nAmount,cCurrency,cIdPos,cIdCustomer,cEmail,cMethod,aDadosCli) Class PaymentHub
    Local cParams       := ""
    Local aHeadStr      := {}
    Local cResult       := ""
    Local oRestClient   := FWRest()    :New(Self:cURL)
    Local oJson         := JsonObject():New()
    Local cToken        := ""

    Default cCodeComp   := Self:cCodeComp
    Default cCurrency   := Self:cCurrency
    Default cIdPos      := Self:cIdPos

    Default cIdCustomer := ""
    Default cEmail      := ""

    Default aDadosCli  := {"","","","","","","",""} // {"cod","email","cpf/cnpj","nome","rua","cidade","cep","estado"}

    If Empty(Self:cIdPos) .And. !Empty(cIdPos)
        Self:cIdPos := cIdPos
    EndIf

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1] 

        cToken := Self:GetToken()
       
        If Empty(cCodeComp) .Or. Empty(cIdInternal) .Or. Empty(nAmount) .Or. Empty(cCurrency) .Or.;
            Empty(cIdPos) .Or. Empty(cMethod) 
            Self:SetMessageError(STR0001) // "Um ou mais campo obrigatorio não foi preenchido."
        EndIf 
       
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            cParams := '{'
            cParams += '"externalPosId"             : "' + cIdPos                               + '",'
            cParams += '"externalBusinessUnitId"    : "' + cCodeComp                            + '",' 
            cParams += '"externalTransactionId"     : "' + cIdInternal                          + '",'
            cParams += '"amount"                    : "' + cValToChar(nAmount)                  + '",'
            cParams += '"currency"                  : "' + cCurrency                            + '",'            
            cParams += '"customer"                  : { ' 
            cParams +=                                  '"id":"'    + aDadosCli[1]              + '",'
            cParams +=                                  '"email":"' + aDadosCli[2]              + '",'
            cParams +=                                  '"ssn":"'   + aDadosCli[3]              + '",'
            cParams +=                                  '"name":"'  + aDadosCli[4]              + '",'
            cParams +=                                  '"street":"' + aDadosCli[5]             + '",'
            cParams +=                                  '"city":"'   + aDadosCli[6]             + '",'
            cParams +=                                  '"postalCode":"' + aDadosCli[7]         + '",'
            cParams +=                                  '"state":"'   + aDadosCli[8]            + '",'
            cParams +=                                  '"locale":"Brasil",'
            cParams +=                              ' },'
            cParams += '"wallet"                    : "' + cMethod                             + '"'
            cParams += '}'

            cParams := EncodeUTF8(cParams)

            LjGrvLog("Totvs Pagamentos Digitais","Metodo LinkPaymentTransaction - Envio de comando da transacao.",cParams)

            oRestClient:setPath("/payments-transacting/api/v2/payment/link")
            oRestClient:SetPostParams(cParams)

            If oRestClient:Post(aHeadStr)
                cResult := oJson:FromJson(oRestClient:GetResult()) 
                
                If ValType(cResult) == "U"  
                    Self:oResultLinkPaymentTransaction := oJson
                    If Upper(oJson["processorMessage"]) == "ERROR"
                        Self:SetMessageError(STR0005 + cMethod) // "Erro ao utilizar carteira: "
                        Self:SetMessageError("Error:" + oJson["errorReason"])
                    EndIf 
                Else
                    Self:SetMessageError(STR0002 + cResult) // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                EndIf           
            Else
                Self:SetMessageError(STR0003,oRestClient:cResult) // "Retorno da API: "
                Self:SetMessageError(STR0004,oRestClient:GetLastError()) // "ERROR: "
            EndIf   
        EndIf 
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultLinkPaymentTransaction
Metodo responsavel devolver o retorno do LinkPaymentTransaction 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultLinkPaymentTransaction() Class PaymentHub
Return Self:oResultLinkPaymentTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} StatusLinkPaymentTransaction
Metodo responsavel realizar o estorno da transação

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/12/2020
@version    12.1.27

@param cCodeComp, Caracter, Codigo da empresa
@param cIdPos, Caracter, Codigo do  PDV 
@param cIdProcessor, Caracter, Id do processador
@param lSerialized, Logico, Indica se o retorno será em caracter ou em objeto

@return Logico, resultado da classe
/*/
//-------------------------------------------------------------------------------------

Method StatusLinkPaymentTransaction(cCodeComp,cIdPos,cIdProcessor,lSerialized) Class PaymentHub
    Local aHeadStr     := {}                 
    Local cResult      := ""
    Local oRestClient  := FWRest():New(Self:cURL)               
    Local oJson        := JsonObject():new()
    Local cToken       := ""

    Default cIdPos      := Self:cIdPos
    Default cCodeComp   := Self:cCodeComp
    Default lSerialized := .T.

    // -- Limpar dados da transação anterior 
    Self:CleanOldTransaction()

    If Self:GetStatus()[1]
        
        cToken := Self:GetToken()

        If Empty(cIdProcessor) 
            Self:SetMessageError(STR0001) // "Um ou mais campo obrigatorio não foi preenchido."
        EndIf 
        
        If Self:GetStatus()[1] 
            AAdd( aHeadStr, "Content-Type: application/json")
            AAdd( aHeadStr, "Authorization: Bearer " + cToken)

            oRestClient:setPath("/payments-transacting/api/v2/payment/link/" + cCodeComp  + "/pos/" + cIdPos + "/transaction/" + cIdProcessor )

            If oRestClient:Get(aHeadStr)
                
                If lSerialized                    
                    cResult  := oJson:FromJson(oRestClient:GetResult()) 
                EndIf 

                If ValType(cResult) == "U" .Or. !lSerialized   
                    If lSerialized
                        Self:oResultStatusLinkPaymentTransaction := oJson
                    Else
                        Self:oResultStatusLinkPaymentTransaction := oRestClient:GetResult()
                    EndIf 
                Else
                    Self:SetMessageError(STR0002 + cResult) // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                EndIf           
            Else
                Self:SetMessageError(STR0003,oRestClient:cResult) // "Retorno da API: "
                Self:SetMessageError(STR0004,oRestClient:GetLastError()) // "ERROR: "
            EndIf 
        EndIf   
    EndIf 

Return Self:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultStatusLinkPaymentTransaction
Metodo responsavel devolver o retorno do StatusLinkPaymentTransaction 

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@return Objeto, Resultado do metodo.
/*/
//-------------------------------------------------------------------------------------

Method ResultStatusLinkPaymentTransaction() Class PaymentHub
Return Self:oResultStatusLinkPaymentTransaction

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetStatusLinkPaymentTransaction
Metodo responsavel setar a propriedade oResultStatusLinkPaymentTransaction

@type       Method
@author     Lucas Novais (lnovais@)
@since      10/08/2020
@version    12.1.27

@param oResultStatusLinkPaymentTransaction, Objeto, dados do retorno para serem setados

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method SetStatusLinkPaymentTransaction(oResultStatusLinkPaymentTransaction) Class PaymentHub
    Self:oResultStatusLinkPaymentTransaction := oResultStatusLinkPaymentTransaction
Return 

