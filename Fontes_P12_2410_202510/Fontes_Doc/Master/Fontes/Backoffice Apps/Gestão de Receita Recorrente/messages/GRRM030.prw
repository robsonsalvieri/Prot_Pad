#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BillAwaitingMeasurementCreatedMessageReader
Classe responsável pela leitura das mensagens do tipo BillAwaitingMeasurementCreated
Link: https://tdn.totvs.com/display/public/framework/FwTotvsLinkClient

@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Class BillAwaitingMeasurementCreatedMessageReader from LongNameClass
    Data aOrigCompany As Array
	
    Method New()
	Method Read( oLinkMessage )
    Method IsMsgValid( oMessage )
    Method PrepareEnv( cOrgIntgId )
    Method Finalize()
    Method ProcessMessage( oMessage )
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe

@return self, nova instância
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method New() Class BillAwaitingMeasurementCreatedMessageReader

    ::aOrigCompany := { cEmpAnt, cFilAnt }
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Read
Realiza a leitura da mensagem oriunda do SmartLink

@param oLinkMessage, instância de FwTotvsLinkMessage, mensagem recebida

@return lResult, lógico, se a mensagem foi lida com sucesso
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class BillAwaitingMeasurementCreatedMessageReader
	Local lResult   := .F.
    Local oContent  := JsonObject():New()

    GRRDebugInfo( { { "Type", 'BillAwaitingMeasurementCreated' } ,;
                    { "Message", oLinkMessage:RawMessage() } } )
    
	oContent:FromJSON( oLinkMessage:RawMessage() )

    If oContent:HasProperty( 'data' )
        oContent := oContent[ 'data' ]
    EndIf    

    If lResult := ( ::IsMsgValid( oContent ) .And. FindFunction( 'GRRGenSaleOrder' ) )
        lResult := ::ProcessMessage( oContent )        
    EndIf
    
    FreeObj( oContent )    

    ::Finalize()
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsMsgValid
Valida se a mensagem está no padrão esperado

@param oMessage, instância de JsonObject, json da mensagem BillAwaitingMeasurementCreated

@return lMsgValid, boolean, se a mensagem está no formato esperado
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method IsMsgValid( oMessage ) Class BillAwaitingMeasurementCreatedMessageReader
    Local lMsgValid := .F.
    Local aPropObg  := { 'organizationIntegrationId' ,;                        
                         'subscriptionId'            ,;
                         'source'                    ,;
                         'billMetadata'              ,;
                         'customerIntegrationId'     ,;
                         'billItems'                 ,;
                         'billId'                    }
    
    lMsgValid := GRRVldMessage( oMessage, aPropObg )

    FWFreeArray( aPropObg )
Return lMsgValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessMessage
Realiza o processamento da mensagem BillAwaitingMeasurementCreated

@param oMessage, JsonObject, instância da mensagem tipo BillAwaitingMeasurementCreated

@return lMsgProcessed, boolean, se o processamento foi concluído corretamente
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method ProcessMessage( oMessage ) Class BillAwaitingMeasurementCreatedMessageReader
    Local aAreas        := { SC5->( GetArea() ), GetArea() }
    Local lMsgProcessed := .F.
    Local nX            := 0
    Local nSizeProd     := GetSx3Cache( 'C6_PRODUTO', 'X3_TAMANHO' )
    Local aProduct      := {}    
    Local jItem         := Nil
    Local oData         := Nil    
    Local aMetaData     := {}

    ::PrepareEnv( oMessage[ 'organizationIntegrationId' ] )

    /*Cria propriedades ausentes na mensagem mas necessárias para o processamento de <GRRGenSaleOrder>*/
    oMessage[ 'reference']   := Nil 
    oMessage[ 'id']          := oMessage[ 'billId' ]
    oMessage[ 'items']       := oMessage[ 'billItems' ]
    oMessage[ 'metadata']    := {}

    for nX := 1 to Len( oMessage[ 'items' ] )
        jItem := oMessage[ 'items' ][ nX ]        

        aProduct := StrTokArr2( jItem[ 'itemIntegrationId' ], '|' )

        jItem[ 'billItemReference' ] := PadR( aProduct[ 3 ], nSizeProd )

        oMessage[ 'items' ][ nX ] := jItem
    next nX

    // Necessário converter do tipo 'J'(JsonObject) para 'O'(Object) para que a função <GRRGenSaleOrder> consiga realizar o processamento
    FWJsonDeserialize( oMessage:toJson(), @oData) 

    If ValType( oData ) == 'O'

        If AttIsMemberOf( oData, "metadata" )
            // A propriedade metadata vem como string do SmartLink, por isso é necessária a conversão em um vetor de objetos
            FWJsonDeserialize( oMessage[ 'billMetadata' ], @aMetaData )
            oData:metadata := aMetaData 
        EndIf

        If AttIsMemberOf( oData, "items" )
            for nX := 1 to Len( oData:items )
                jItem := oData:items[ nX ]                

                // A propriedade metadata vem como string do SmartLink, por isso é necessária a conversão em um vetor de objetos                
                FWJsonDeserialize( jItem:metadata, @oData:items[ nX ]:metadata )
            next nX
        EndIf

        lMsgProcessed := GRRGenSaleOrder( oData )
    EndIf    
    
    aEval( aAreas , {|x| RestArea( x ) } )
    FwFreeArray( aAreas )
    FwFreeArray( aProduct )
    FwFreeArray( aMetaData )

    FreeObj( jItem )
    FreeObj( oData )
Return lMsgProcessed

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrepareEnv
Prepara o ambiente com base na empresa/filial associada ao OrganizationIntegrationId

@param cOrgIntgId, caractere, identificador da empresa/filial na plataforma

@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method PrepareEnv( cOrgIntgId ) Class BillAwaitingMeasurementCreatedMessageReader
    Local aCompany          := {}

    aCompany := StrTokArr2( cOrgIntgId, '|' )

    GRRChgConn( aCompany[ 1 ], aCompany[ 2 ] )

    // If (aCompany[1] != cEmpAnt)
    //     RpcClearEnv()
    //     GRRConnCompany( aCompany[1], aCompany[2] )
    // EndIf
    // cFilAnt := aCompany[2]

    FwFreeArray( aCompany )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Finalize
Restaura o ambiente para configuração inicial e limpa propriedades da classe

@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method Finalize() Class BillAwaitingMeasurementCreatedMessageReader

    GRRChgConn( ::aOrigCompany[ 1 ], ::aOrigCompany[ 2 ] )

    // If (::aOrigCompany[1] != cEmpAnt)
    //     RpcClearEnv()        
    //     GRRConnCompany( ::aOrigCompany[1], ::aOrigCompany[2] )
    // EndIf    
    // cFilAnt := ::aOrigCompany[2]

    FwFreeArray( ::aOrigCompany )
Return


