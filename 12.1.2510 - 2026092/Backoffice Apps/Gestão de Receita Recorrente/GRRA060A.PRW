#include "protheus.ch"
#include "GRRXDefs.CH"
#include "GRRA060A.CH"

/*-----------------------------------------------------
                Charge GRR
-----------------------------------------------------*/
#DEFINE GRR_CHARGE_BILLIID           1     // BillIntegrationID
#DEFINE GRR_CHARGE_BILLID            2     // BillID
#DEFINE GRR_CHARGE_CHARGEID          3     // ChargeId
#DEFINE GRR_CHARGE_SOURCE            4     // Source
#DEFINE GRR_CHARGE_CURRENCY          5     // Currency
#DEFINE GRR_CHARGE_PAYMENTMETHOD     6     // PaymentMethod
#DEFINE GRR_CHARGE_CUSTIID           7     // CustomerIntegrationId
#DEFINE GRR_CHARGE_AMOUNT            8     // Amount
#DEFINE GRR_CHARGE_VENC              9     // Vencimento
#DEFINE GRR_CHARGE_ORGID             10    // OrganizationIntegrationId


//-------------------------------- GRRA060A ----------------------------------------------------
// Funções que realizam o processo de Envio e Recebimento de Mensagens pelo Provider Protheus.
//----------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRA060A
Função que prepara as informações necessárias para a liberação dos pedidos no Protheus, 
após receber a mensagem via SmartLink, sinalizando que a a fatura relacionada a um determinado 
pedido já foi paga e prossegue com o fluxo de emissão da NF pelo Protheus, caso seja necessário.

@param aInfo, array, Vetor com as informações do contrato a sincronizar, sendo:
    [1] = BillIntegrationID
    [2] = BillID
    [3] = ChargeId
    [4] = Source
    [5] = Currency
    [6] = PaymentMethod
    [7] = CustomerIntegrationId
    [8] = Amount
    [9] = Vencimento
    [10] = OrganizationIntegrationId

@author  Rodrigo G. Soares
@since   30/05/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRA060A( aParam )
    Local aSvAlias := GetArea()
    Local aChaveSC5 := {}
    local aChargeSalesOrder := {}
    Local aInfo := {}
    Local aOrgInfo := {}
    Local lSalesOrder := .F.
    Local nX := 1
    Local cReference := ""
    Local cAlias := ""
    Local cSeek := ""
    Local cSource := ""
    Local cEmpBck := cEmpAnt
    Local cFilBck := cFilAnt
    Local cInvGenerator := ''
    Local cPayCond := ''
    Local cSalesOrder := ''
    Local nTamFil := TamSx3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSx3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSx3( "HRH_REQCD" )[1]
	Local nTamContr := TamSx3( "CNA_CONTRA" )[1]
	Local nTamRev := TamSx3( "CNA_REVISA" )[1]
	Local nTamPla := TamSx3( "CNA_NUMERO" )[1]
    Local lRet := .F.
    Local lContinue := .F.
    Local aReference := {}
    Local oInstallme := jsonObject():new()
    Local oInsertHrk := jsonObject():new()
    Local oObjHrk := Nil

    For nX := 1 to len( aParam )
        lSalesOrder := .F.
        lContinue := .F.
        aInfo := StrTokArr2( aParam[ nX ][ GRR_CHARGE_BILLIID ] , '|' , .T. )
        aOrgInfo := StrTokArr2( aParam[ nX ][ GRR_CHARGE_ORGID ] , '|' , .T. ) //organizationIntegrationId da mensagem PaymentOrderProtheus
        oInstallme:fromJson("{}")
        oInsertHrk:fromJson("{}")
        
        //--------------------------------------------------------------
        // Troca para a empresa\filial do dado
        //--------------------------------------------------------------
        GRRChgConn( aOrgInfo[ 1 ], aOrgInfo[ 2 ] )        

        // Deveria estar dentro de uma transação, mas foi retirado por causa de erro de DBRUnlock na FINA060 
        // BEGIN TRANSACTION
            // Valida se houve integração Protheus anteriormente
            IF ( !Empty( aParam[ nX ][ GRR_CHARGE_BILLIID ] ) )
                //--------------------------------------------------------------
                // Caso o pedido de venda tenha sido gerado pelo GCT encontrar 
                // o pedido de venda para seguir com o fluxo.
                //--------------------------------------------------------------
                IF ( aParam[ nX ][ GRR_CHARGE_SOURCE ] == 'CNTA300' )
                    aChaveSC5 := GRRGetSalesOrder( aInfo[ 3 ] )
                    If len( aChaveSC5 ) > 0
                        cReference := aChaveSC5[ 1 ][ 1 ] + "|" + aChaveSC5[ 1 ][ 2 ]
                        cAlias := Padr( 'CNA', nTamAlias )
                        cSeek := Padr( aInfo[ 3 ], nTamContr ) + Padr( aInfo[ 4 ], nTamRev ) + Padr( aInfo[ 5 ], nTamPla )
                        cSource := 'CNTA300'
                        cSalesOrder := aChaveSC5[ 1 ][ 2 ]
                        lSalesOrder := .T.     
                    EndIF

                // Necessário incluir um ElseIf pois existirá fluxo de integração que não irá gerar 
                // pedido de venda, apenas financeiro.
                ElseiF ( aParam[ nX ][ GRR_CHARGE_SOURCE ]  == 'MATA410' )
                    cAlias := Padr( 'SC5', nTamAlias )
                    cSeek := aInfo[ 3 ]
                    cSalesOrder := cSeek
                    cSource := 'MATA410'
                    lSalesOrder := .T.    
                EndIF

                HRH->( DbSetOrder( 1 ) )         // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

                If HRH->( DbSeek( xFilial( "HRH" ) + Padr( aOrgInfo[ 2 ], nTamFil ) + cAlias + Padr( cSeek, nTamReq ) + cSource ) )  .and. lSalesOrder
                    cReference := IIF( HRH->HRH_ALIAS == 'SC5', xFilial( "HRH" ) + "|" + HRH->HRH_SRCFIL + "|" + HRH->HRH_REQCD, xFilial( "HRH" ) + "|" + cReference )
                    cPayCond := Posicione( 'SC5', 1, Padr( aOrgInfo[ 2 ], nTamFil ) + cSalesOrder, "C5_CONDPAG" )
                    cInvGenerator := GRRInvGenerate( cPayCond ) 
                    
                    //--------------------------------------------------------------
                    // Libera o pedido de venda do bloqueio GRR e Cria NF.
                    //--------------------------------------------------------------
                    lContinue := GRRLibSalesOrder( cReference, cInvGenerator )
                
                    If lContinue
                        // ----------------------------------------------------------------------------
                        // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                        // ----------------------------------------------------------------------------
                        GRRSetBillId( { xFilial( cAlias, aOrgInfo[ 2 ] ), cAlias, cSeek }, aParam[ nX ][ GRR_CHARGE_BILLID ] )

                        aReference := StrTokArr2( cReference, '|', .T. )
                        oInstallme := totvs.protheus.backoffice.apps.grr.integration.invoice.InvoiceIntegration():getInvoiceInstallmentsBySalesOrder(aReference[2], aReference[3])
                    EndIf
                EndIf
            else
                    //Busca o Cliente na Base Protheus

                    //Irá criar um registro a Receber no Protheus            
            EndIF

            If oInstallme:hasProperty('amount') .and. oInstallme:hasProperty('dueDate') .and. oInstallme:hasProperty('idDoc') .and. ( oInstallme['amount'] == aParam[ nX ][ GRR_CHARGE_AMOUNT ] .or. oInstallme['dueDate'] == aParam[ nX ][ GRR_CHARGE_VENC ] )
                oObjHrk := totvs.protheus.backoffice.apps.grr.integration.paymentorder.PaymentOrderIntegration():new(aParam[ nX ][ GRR_CHARGE_CHARGEID ])
                oInsertHrk := oObjHrk:createPaymentOrderIntegration(aParam[ nX ][ GRR_CHARGE_CHARGEID ], oInstallme['idDoc'])
                If oInsertHrk['status'] == "true"
                    lRet := .T.
                Else
                    totvs.protheus.backoffice.apps.grr.general.FlowControl():logMessage({{"PaymentOrderIntegration", oInsertHrk['message']}})
                EndIf
            Else
                totvs.protheus.backoffice.apps.grr.general.FlowControl():logMessage({{"PaymentOrderIntegration", "Error - " + STR0002}}) //"Vencimento ou valor diferente do Protheus com o GR"
            EndIf

        // Deveria estar dentro de uma transação, mas foi retirado por causa de erro de DBRUnlock na FINA060 
        //     If !lRet
        //         DisarmTransaction()
        //     EndIf
        // END TRANSACTION
            
        //--------------------------------------------------------------
        // Volta para a empresa\filial original
        //--------------------------------------------------------------
        GRRChgConn( cEmpBck, cFilBck )        
    Next

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aChaveSC5 )
    FWFreeArray( aChargeSalesOrder )
    FWFreeArray( aReference )

    aSize(aInfo, 0)
    aInfo := Nil

    aSize(aOrgInfo, 0)
    aOrgInfo := Nil

    oInstallme:fromJson("{}")
    freeObj(oInstallme)
    oInsertHrk:fromJson("{}")
    freeObj(oInsertHrk)
    
    fwFreeObj(oObjHrk)
Return lRet
