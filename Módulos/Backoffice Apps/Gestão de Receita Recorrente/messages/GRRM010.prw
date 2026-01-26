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

    If lResult := ( ::IsMsgValid( oContent ) .And. FindFunction( 'GRRA060A' ) )
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
                        'dueDate' }
    
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
    Local aParam    := Array( 9 )
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

    FwFreeArray( aLocalDate )
Return aParam
