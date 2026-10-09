#include "protheus.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "GRRXDefs.ch"

/*-----------------------------------------------------
        Informações do OrganizationIntegrationID
-----------------------------------------------------*/
#DEFINE ORG_COMPANY         1
#DEFINE ORG_BRANCH          2

//-------------------------- GRRI100 ------------------------------------------------
// Funções de atualização de cobrança para a plataforma.
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI100
Função que sincroniza os titulos pagos no Protheus com a plataforma quando for
Provider Protheus.

@author  Rodrigo Soares
@since   16/11/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRI100( )
    Local aSvAlias := GetArea()
    Local cSource := ''

    //--------------------------------------------------------------
    // Retorna o nome do fonte PRW que fez a chamada da função
    //--------------------------------------------------------------
    cSource := ProcSource( 0 ) 
    cSource := StrTran( cSource, '.PRW', '' )  

    IF GRRSyncExec( 'paymentOrder', cSource )        
        BEGIN TRANSACTION
            //-----------------------------------------------------------------------
            // Envia os pagamentos dos titulos para a plataforma.
            //-----------------------------------------------------------------------
            SyncFlow()

            //--------------------------------------------------------------
            // Armazena a informação de execução ao controle de sincronismo
            //--------------------------------------------------------------
            GRRSyncTime( 'paymentOrder', cSource )
        END TRANSACTION
    EndIf

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla a criação dos pedidos de venda de acordo com as faturas geradas 
pela plataforma

@author  Rodrigo Soares
@since   16/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow(  )
    Local aPaymentOrders := {}
    Local nI := 1

    aPaymentOrders    := GetPaymentOrder()
    For nI := 1 to len( aPaymentOrders )
        UpdatePaymentOrder( aPaymentOrders[ nI ] )
    Next

    FWFreeArray( aPaymentOrders )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPaymentOrder
Função busca quais titulos precisam atualizar na plataforma

@return array, Array com os itens a enviar para plataforma.
    [1]-CharId
    [2]-Vencimento do boleto
    [3]-Data da baixa
    [4]-Recno na HRK
    [5]-Boleto pago?
    [6]-Sandbox?
@author  Rodrigo Soares 
@since   17/11/2022
/*/
//-------------------------------------------------------------------------------------
Static Function GetPaymentOrder()
    Local aArea       := Getarea()
    local aPaymentOrders := {}
    Local cQuery         := ""
    Local lIsSndbox      :=  GRRIsSndbox( ) 
    Local oQuery
    Local nParamOrder := 1
    Local cTmp := ""
    
    cQuery := "SELECT HRK.HRK_CHARID, E1_VENCTO, E1_BAIXA, HRK.R_E_C_N_O_ HRKRECNO "
    cQuery += "FROM " + RetSQLName( "HRK" ) + " HRK "

    cQuery += "INNER JOIN " + RetSQLName( "FK7" ) + " FK7 "
    cQuery += "ON FK7.FK7_FILIAL = ? "
    cQuery += "AND FK7.FK7_IDDOC = HRK.HRK_IDDOC "
    cQuery += "AND FK7.D_E_L_E_T_ = ? "
    
    cQuery += "INNER JOIN " + RetSQLName( "SE1" ) + " SE1 "
    cQuery += "ON SE1.E1_FILIAL = FK7.FK7_FILTIT "
    cQuery += "AND SE1.E1_PREFIXO = FK7.FK7_PREFIX "
    cQuery += "AND SE1.E1_NUM = FK7.FK7_NUM "
    cQuery += "AND SE1.E1_PARCELA = FK7.FK7_PARCEL "
    cQuery += "AND SE1.E1_TIPO = FK7.FK7_TIPO "
    cQuery += "AND SE1.E1_SALDO = ? "
    cQuery += "AND SE1.E1_BAIXA <> ? "
    cQuery += "AND SE1.D_E_L_E_T_ = ? "

    cQuery += "WHERE HRK_STATUS = ? "
    cQuery += "AND HRK.D_E_L_E_T_ = ? "

    oQuery := FWExecStatement():new(changeQuery(cQuery))

    oQuery:setString(nParamOrder++, xFilial("FK7"))
    oQuery:setString(nParamOrder++, " ")
    oQuery:setNumeric(nParamOrder++, 0)
    oQuery:setString(nParamOrder++, " ")
    oQuery:setString(nParamOrder++, " ")
    oQuery:SetString(nParamOrder++, GRR_PROVIDER_GENERATED_BANKSLIP) // 2=Notificado para Plataforma
    oQuery:setString(nParamOrder++, " ")

    cTmp := oQuery:openAlias()

    While ( cTmp )->( !Eof() )
        AADD( aPaymentOrders, { ( cTmp )->HRK_CHARID, STOD( ( cTmp )->E1_VENCTO ), STOD( ( cTmp )->E1_BAIXA ), ( cTmp )->HRKRECNO, .T., lIsSndbox } )
        
        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    RestArea( aArea )

    aSize( aArea, 0 )
    aArea := Nil
    
    FreeObj( oQuery )
return aPaymentOrders

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdatePaymentOrder
Função que irá atualizar as PaymentOrders na plataforma

@param aItem, array, vetor com informações da PaymentOrder para geração do JSON. Onde:
    [1]-CharId
    [2]-Vencimento do boleto
    [3]-Data da baixa
    [4]-Recno na HRI
    [5]-Boleto pago?
    [6]-Sandbox?

@return lSuccess, lógico, se a mensagem foi enviada com sucesso 
@author  Rodrigo Soares 
@since   17/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function UpdatePaymentOrder( aItem )
    Local aSvAlias := GetArea()
    Local lSuccess := .F.
    Local jPaymentOrderUpdate

    jPaymentOrderUpdate := SetJson( aItem )

    lSuccess := GRRSLSendMsg( EncodeUTF8( FwJsonSerialize( jPaymentOrderUpdate ) ), "PaymentOrderProtheusUpdated" )

    if lSuccess
        HRK->( DBGoTo( aItem[ 4 ] ) )
        RecLock( 'HRK', .F. )
            HRK->HRK_STATUS := GRR_PROVIDER_COMPLETED // 3=Ordem de pagamento finalizada
        MsUnlock()
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( jPaymentOrderUpdate )
Return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a confirmação do pagamento do 
boleto para a plataforma GRR.

@param aItem, array, vetor com informações da PaymentOrder para geração do JSON.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Rodrigo G Soares
@since   17/11/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( aItem )
    Local jData := NIL

    jData := JsonObject():New()
 
    jData[ "ChargeId" ] :=  aItem[ 1 ]  
    jData[ "DueDate" ] := FWTimeStamp( 5, aItem[ 2 ],   TIME() )
    jData[ "PayoutDate" ] := FWTimeStamp( 5, aItem[ 3 ], TIME() )
    jData[ "Paid" ] := aItem[ 5 ]
    JData[ "IsSandbox"] :=  aItem[ 6 ]
Return jData
