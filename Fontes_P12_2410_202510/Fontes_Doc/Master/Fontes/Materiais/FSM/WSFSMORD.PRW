#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmOrd
Métodos Rest do FSM para Ordem de Serviço
@author flavio.martins
@since 01/08/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMORD DESCRIPTION "WS de Integração Field Services Manager - Ordem de Serviço" 

	WSDATA dataAgenda            	AS STRING
	WSDATA codigo                	AS STRING
	WSDATA filtraAgendados		 	AS BOOLEAN
	WSDATA rawimage              	AS STRING    
	WSDATA userLogged            	AS STRING   
	WSDATA codObjeto             	AS STRING    
	WSDATA nomeObj               	AS STRING	
	WSDATA page                  	AS INTEGER
	WSDATA pageSize              	AS INTEGER
	WSDATA filter                	AS STRING
	WSDATA codProduto            	AS STRING 
	WSDATA codigoBase       	 	AS STRING 
	WSDATA idUnico		      	 	AS STRING 
	WSDATA cep	         		 	AS STRING
	WSDATA idUser 					AS STRING
	WSDATA codigoCliente			AS STRING
	WSDATA lojaCliente				AS STRING

	WSMETHOD POST generateSalesOrder   DESCRIPTION 'Inclusão do pedido de venda' PATH "generateSalesOrder" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST generateSalesOrder WSREST FSMORD
Local lRet         := .T.
Local oRequest     := JSonObject():New()
Local oResponse	   := JsonObject():New()
Local cBody        := Self:GetContent()
Local cMsgRet	   := ''
Local cCodigo      := ''
Local cCodRet      := ''

oRequest:fromJson(cBody)

cCodigo := oRequest['ordemServico']

lRet := FsmGerPed(cCodigo, @cMsgRet, @cCodRet)

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
