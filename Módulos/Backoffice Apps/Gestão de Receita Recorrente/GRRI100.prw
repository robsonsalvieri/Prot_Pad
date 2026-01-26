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
    [4]-Recno na HRI
    [5]-Boleto pago?
    [6]-Sandbox?
@author  Rodrigo Soares 
@since   17/11/2022
/*/
//-------------------------------------------------------------------------------------
Static Function GetPaymentOrder()
    Local aSvAlias       := Getarea()
    local aPaymentOrders := {}
    Local cQuery         := ""
    Local lIsSndbox      :=  GRRIsSndbox( ) 
    Local oQuery

    cQuery := "SELECT HRI_CHARID, E1_VENCTO, E1_BAIXA, HRI.R_E_C_N_O_ RECNO " + ;
        " FROM " + RetSQLName( "HRI" ) + " HRI " + ;
        " INNER JOIN " + RetSQLName( "SE1" ) + " SE1 " + ;
            " ON E1_FILIAL = HRI_SRCFIL " + ;
            " AND ( E1_PREFIXO || E1_NUM || E1_PARCELA || E1_TIPO ) = HRI_REQCD " + ;
            " AND E1_SALDO = 0 " + ;
            " AND E1_BAIXA != '' " + ;
            " AND SE1.D_E_L_E_T_ = ' ' " + ;
        " WHERE HRI_STATUS = ? " + ;     
            " AND HRI.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    
    oQuery := FWPreparedStatement():New( cQuery )
    oQuery:SetString( 1, GRR_PROVIDER_GENERATED_BANKSLIP )      // 2=Notificado para Plataforma

    cTmp := MPSysOpenQuery( oQuery:GetFixQuery() )

    While ( cTmp )->( !Eof() )
        AADD( aPaymentOrders, { ( cTmp )->HRI_CHARID, STOD( ( cTmp )->E1_VENCTO ), STOD( ( cTmp )->E1_BAIXA ), ( cTmp )->RECNO, .T., lIsSndbox } )
        
        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
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
        HRI->( DBGoTo( aItem[ 4 ] ) )
        RecLock( 'HRI', .F. )
            HRI->HRI_STATUS := GRR_PROVIDER_COMPLETED // 3=Ordem de pagamento finalizada
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
