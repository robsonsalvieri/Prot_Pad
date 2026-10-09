#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PaymentOrderProtheusMessageReader
Classe responsável pela leitura das mensagens do tipo PaymentOrderProtheus
Link: https://tdn.totvs.com/display/public/framework/FwTotvsLinkClient

@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Class PaymentOrderProtheusMessageReader from LongNameClass
	Method New()
	Method Read()
    Method IsMsgValid( oMessage )
    Method MsgToArray( oMessage )
    method newProcessMessage(oLinkMessage as object) as logical
EndClass

Method New() Class PaymentOrderProtheusMessageReader

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Read
Realiza a leitura da mensagem oriunda do SmartLink

@param oLinkMessage, instância de FwTotvsLinkMessage, mensagem recebida

@return lResult, lógico
@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class PaymentOrderProtheusMessageReader
	Local lResult   := .F.
    Local oContent  := JsonObject():New()
	Local aParam    := {}
  
	oContent:FromJSON( oLinkMessage:RawMessage() )

    If oContent:HasProperty( 'data' )
        oContent := oContent[ 'data' ]
    EndIf

    if oContent['source'] == "GRRI110"
        lResult := self:newProcessMessage(oLinkMessage)
    ElseIf ::IsMsgValid(oContent) .And. FindFunction( 'GRRA060A' )
        aParam := ::MsgToArray( oContent )        
        lResult := GRRA060A( { aParam } )
    EndIf

    FwFreeArray( aParam )
    FreeObj( oContent )    
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsMsgValid
Valida se a mensagem está no padrão esperado

@param oMessage, instância de JsonObject, json da mensagem PaymentOrderProtheus

@return lMsgValid, lógico, se a mensagem está no formato esperado
@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Method IsMsgValid( oMessage ) Class PaymentOrderProtheusMessageReader
    Local lMsgValid := .F.   
    Local aPropObg  := { 'billIntegrationId'     ,;
                        'billId'                ,;
                        'chargeId'              ,;
                        'source'                ,;
                        'currency'              ,;
                        'paymentMethod'         ,;
                        'customerIntegrationId' ,;
                        'totalAmount'           ,;
                        'dueDate'               ,;
                        'organizationIntegrationId' }
    
    lMsgValid := GRRVldMessage( oMessage, aPropObg )

    FWFreeArray( aPropObg )
Return lMsgValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MsgToArray
Converte <oMessage> para o vetor esperado pela função GRRA060A

@param oMessage, instância de JsonObject, json da mensagem PaymentOrderProtheus

@return aParam, vetor, dados para processamento
@author philipe.pompeu
@since 30/06/2023
/*/
//-------------------------------------------------------------------------------------
Method MsgToArray( oMessage )  Class PaymentOrderProtheusMessageReader
    Local aParam    := Array( 10 )
    Local dDueDate  := Date()
    Local aLocalDate:= {}

    aLocalDate  := FwDateTimeToLocal( oMessage[ 'dueDate' ] )
    If Len( aLocalDate ) > 0
        dDueDate := aLocalDate[ 1 ]
    EndIf

    //Converte <oMessage> p/ padrão esperado pela função GRRA060A
    aParam[1] := oMessage[ 'billIntegrationId' ]
    aParam[2] := oMessage[ 'billId' ]
    aParam[3] := oMessage[ 'chargeId' ]
    aParam[4] := oMessage[ 'source' ]
    aParam[5] := oMessage[ 'currency' ]
    aParam[6] := oMessage[ 'paymentMethod' ]
    aParam[7] := oMessage[ 'customerIntegrationId' ]
    aParam[8] := oMessage[ 'totalAmount' ]
    aParam[9] := dDueDate
    aParam[10] := oMessage[ 'organizationIntegrationId' ]

    FwFreeArray( aLocalDate )
Return aParam

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} newProcessMessage
	Verifica e chama nova classe para processar a mensagem.
    @author claudio.yoshio
    @since 12/05/2026
    @param oLinkMessage, JsonObject, objeto da mensagem recebida do SmartLink
    @return lSuccess, lógico, indica se o processamento foi concluído corretamente
    @version 12.1.2510
/*/
//-------------------------------------------------------------------------------------
method newProcessMessage(oLinkMessage as object) as logical class PaymentOrderProtheusMessageReader
    local lSuccess := .F. as logical
    local oNewHandler as object
    local cMessageType := 'PaymentOrderProtheus' as character
    
    if findClass("totvs.protheus.backoffice.apps.grr.messages.PaymentOrderProtheusMessageHandler")
        oNewHandler := totvs.protheus.backoffice.apps.grr.messages.PaymentOrderProtheusMessageHandler():new()
        if oNewHandler:canRead(cMessageType)
            lSuccess := oNewHandler:read(oLinkMessage)
        endIf
        fwFreeObj(oNewHandler)
    endIf
return lSuccess
