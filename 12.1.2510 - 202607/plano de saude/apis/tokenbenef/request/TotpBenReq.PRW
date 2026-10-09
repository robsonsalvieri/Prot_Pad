#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TotpBenReq
    classe para validacao de Tokens de Atendimento

@author  sakai
@version P12
@since   04/06/19
/*/
//------------------------------------------------------------------- 
class TotpBenReq from CenRequest 

    Data oRest as Object
 
    method New()
    method validTotp()

endClass

method New(oRest) class TotpBenReq as Object

    self:oRest := oRest
  
return self

method validTotp() class TotpBenReq

    Local oTotpService := nil
   
    oTotpService := TotpBenSvc():New()

    if oTotpService:retToken(self:oRest:subscriberId)
        self:lSuccess  := .T.
        self:cResponse := oTotpService:getResult()
        self:nStatus   := oTotpService:getStatusCode()
    else
        oErrorAux         := oTotpService:getError()
        self:lSuccess     := .F.
        self:nFault       := oErrorAux['status']
        self:nStatus      := oErrorAux['status']
        self:cFaultDesc   := oErrorAux['message']
        self:cFaultDetail := oErrorAux['detailedMessage']
    endIf

return .T.