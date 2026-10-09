#include "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TotpBenSvc
    classe para validacao de tokens TOTP

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
class TotpBenSvc

    data cSeed as String
    data oError as Object
    data oResult as Object
    data cSuccess as String
    data cStatus as Integer
    
    method new()
    method retToken()
    method retSeed(cIdBenef)
    method setError(cStatus, cCode, cMessage, cDetailedMessage)
    method grvLogToken(cIdBenef,cToken)
    method setResult(cMessage)
    method getError()
    method getResult()
    method getStatusCode()
    
endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo Construtor

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
method New() class TotpBenSvc as Object

    self:oError      := JsonObject():new()
    self:oResult     := JsonObject():new()
    self:cStatus     := 200
    self:cSuccess    := .T.
    self:cSeed       := ''
    
return self


//-------------------------------------------------------------------
/*/{Protheus.doc} retToken
    Busca o beneficiario, seu seed e compara os tokens

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
method retToken(cIdBenef) class TotpBenSvc

    Local cSeed      := ''
    Local cToken     := ''
    Local nTimeStep   := GetNewPar("MV_PLSTKTS", 1800) //Token Time Step
    Local nDigits     := GetNewPar("MV_PLSTKDG", 6) //Token Number of Digits
    Local nEncodeType := GetNewPar("MV_PLSTKST", 1) //Token Seed Type 1=Text; 2=Base64; 3=Hex
    Local nHashType   := GetNewPar("MV_PLSTKSH", 5) //Token SHA Function 3=SHA-1; 5=SHA-256; 7=SHA-512    
    Default cIdBenef := ''

    cSeed := self:retSeed(cIdBenef)   
    if self:cSuccess
        cToken := PLSTOTPGEN(cSeed, nTimeStep, nHashType, nEncodeType, 3, nDigits, nil)
        self:grvLogToken(cIdBenef,cToken)
        self:setResult(cIdBenef, cToken, nTimeStep)
    endIf

return self:cSuccess

method retSeed(cIdBenef) class TotpBenSvc

    Local cSeed := ''
    Local aRet  := {}
    Local lAtualiza := .F.

    //Verifica se ja existe seed cadastrado, se nao houver, gera
    if self:cSuccess
        BA1->(DbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
        if len(cIdBenef) == 17 .And. BA1->(DbSeek(xFilial("BA1")+cIdBenef))
            lAtualiza := iif(empty(BA1->BA1_TKSEED),.T.,.F.)
            aRet := PLSTKSEEDG(cIdBenef,lAtualiza)
            if aRet[1]
                cSeed := aRet[2]
            else
                self:cSuccess := .F.
                self:setError(400,"0003","Ocorreu um erro ao validar o seed do beneficiario","Entre em contato com o Suporte")
            endIf              
        else
            self:cSuccess := .F.
            self:setError(400,"0003","Beneficiario informado nao encontrado","Entre em contato com o Suporte")
        endIf
    endIf

return Alltrim(cSeed)

method setError(cStatus, cCode, cMessage, cDetailedMessage) class TotpBenSvc

    Default cStatus  := 400
    Default cCode    := '0002'
    Default cMessage := 'Bad Request'
    Default cDetailedMessage := 'O servidor nao foi capaz de entender a solicitacao'

    self:oError['status'] := cStatus
    self:oError['code'] := cCode
    self:oError['message'] := cMessage
    self:oError['detailedMessage'] := cDetailedMessage
    self:cStatus  := cStatus
    self:cSuccess := .F.

return

method grvLogToken(cIdBenef,cToken) class TotpBenSvc

    if PLSALIASEXI("B74")
        B74->(RecLock("B74",.T.))
        B74->B74_FILIAL := xFilial('B74')
        B74->B74_CODINT := Substr(cIdBenef,1,4)
        B74->B74_CODEMP := Substr(cIdBenef,5,4)
        B74->B74_MATRIC := Substr(cIdBenef,9,6)
        B74->B74_TIPREG := Substr(cIdBenef,15,2)
        B74->B74_DIGITO := Substr(cIdBenef,17,1)
        B74->B74_DATSOL := dDatabase
        B74->B74_HORSOL := Time()
        B74->B74_TOKEN  := cToken
        B74->(MsUnLock())
    endIf

return

method setResult(subscriberId, cToken, nTimeStep) class TotpBenSvc
    self:oResult['subscriberId'] := subscriberId
    self:oResult['token'] := cToken
    self:oResult['timeStep'] := nTimeStep
return

method getError() class TotpBenSvc
return self:oError

method getResult() class TotpBenSvc
return self:oResult:toJson()

method getStatusCode() class TotpBenSvc
return self:cStatus