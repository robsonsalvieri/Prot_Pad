#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmOrc
Métodos Rest do FSM para Orçamentos
@author flavio.martins
@since 14/10/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMORC DESCRIPTION "WS de Integração Field Services Manager - Orçamentos" 

	WSMETHOD POST generateSalesOrder   DESCRIPTION 'Inclusão do pedido de venda' PATH "generateSalesOrder" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST generateSalesOrder WSREST FSMORC
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgRet	   := ''
Local cCodigo      := ''
Local cCodRet      := ''

oRequest:fromJson(cBody)

cCodigo := oRequest['codigoOrcamento']

lRet := FsmPedOrc(cCodigo, @cMsgRet, @cCodRet)

If lRet
	oResponse['message'] := EncodeUtf8(cMsgRet)
	oResponse['data'] := {}
			
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['codigo'] := cCodRet

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Else
	SetRestFault(400, EncodeUtf8(cMsgRet))
Endif

oResponse := Nil
oRequest :=  Nil

Return lRet
