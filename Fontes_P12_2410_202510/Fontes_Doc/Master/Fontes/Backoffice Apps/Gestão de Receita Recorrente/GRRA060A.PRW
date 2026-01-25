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

@author  Rodrigo G. Soares
@since   30/05/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRA060A( aParam )
    Local aSvAlias := GetArea()
    Local aPaymentOrder := ARRAY( 12 )
    local aChargeSalesOrder := {}
    Local aInfo := {}
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
    // local lBordero := SuperGetMV( "MV_GRRBORD" , .F. , .F.)

    For nX := 1 to len( aParam )
        lSalesOrder := .F.
        lContinue := .F.
        aInfo := StrTokArr2( aParam[ nX ][ GRR_CHARGE_BILLIID ] , '|' , .T. )
        
        //--------------------------------------------------------------
        // Troca para a empresa\filial do dado
        //--------------------------------------------------------------
        GRRChgConn( aInfo[ 1 ], aInfo[ 2 ] )        

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

                If HRH->( DbSeek( xFilial( "HRH" ) + Padr( aInfo[ 2 ], nTamFil ) + cAlias + Padr( cSeek, nTamReq ) + cSource ) )  .and. lSalesOrder
                    cReference := IIF( HRH->HRH_ALIAS == 'SC5', xFilial( "HRH" ) + "|" + HRH->HRH_SRCFIL + "|" + HRH->HRH_REQCD, xFilial( "HRH" ) + "|" + cReference )
                    cPayCond := Posicione( 'SC5', 1, Padr( aInfo[ 2 ], nTamFil ) + cSalesOrder, "C5_CONDPAG" )
                    cInvGenerator := GRRInvGenerate( cPayCond ) 
                    
                    //--------------------------------------------------------------
                    // Libera o pedido de venda do bloqueio GRR e Cria NF.
                    //--------------------------------------------------------------
                    lContinue := GRRLibSalesOrder( cReference, cInvGenerator )
                
                    If lContinue
                        // ----------------------------------------------------------------------------
                        // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                        // ----------------------------------------------------------------------------
                        GRRSetBillId( { xFilial( cAlias, aInfo[ 2 ] ), cAlias, cSeek }, aParam[ nX ][ GRR_CHARGE_BILLID ] )

                        aChargeSalesOrder = RetAccountxSalesOrder( cReference )
                        aPaymentOrder[ GRR_PAYMENT_ORDER_ALIAS ]  = 'SE1'
                        aPaymentOrder[ GRR_PAYMENT_ORDER_SOURCE ] = "MATA460"
                    EndIf
                EndIf
            else
                    //Busca o Cliente na Base Protheus

                    //Irá criar um registro a Receber no Protheus            
            EndIF

            if ( len( aChargeSalesOrder ) > 0 )
                If ( aChargeSalesOrder[ 1 ][ 6 ] == aParam[ nX ][ GRR_CHARGE_AMOUNT ] .or. aChargeSalesOrder[ 1 ][ 7 ] == aParam[ nX ][ GRR_CHARGE_VENC ] )
                    
                    // Este tratamento foi mudado pois o parâmetro MV_GRRBORD não foi disponibilizado  no ATUSX e ainda não é utilizado pelos clientes.
                    If SendBordero( aChargeSalesOrder[ 1 ] )     //!lBordero .or. SendBordero( aChargeSalesOrder[ 1 ] )
                        aPaymentOrder[ GRR_PAYMENT_ORDER_SRCFIL ] := aChargeSalesOrder[ 1 ][ 1 ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_REQCD ] := aChargeSalesOrder[ 1 ][ 2 ] + aChargeSalesOrder[ 1 ][ 3 ] + aChargeSalesOrder[ 1 ][ 4 ] + aChargeSalesOrder[ 1 ][ 5 ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_CHARID ] := aParam[ nX ][ GRR_CHARGE_CHARGEID ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_BILLID ] := aParam[ nX ][ GRR_CHARGE_BILLID ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_CUSIID ] := aParam[ nX ][ GRR_CHARGE_SOURCE ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_STATUS ] := GRR_PROVIDER_CREATED // 1=Ordem de Pagamento Criada.
                        aPaymentOrder[ GRR_PAYMENT_ORDER_VALUE ] := aParam[ nX ][ GRR_CHARGE_AMOUNT ] 
                        aPaymentOrder[ GRR_PAYMENT_ORDER_DUEDATE ] := aParam[ nX ][ GRR_CHARGE_VENC ]
                        aPaymentOrder[ GRR_PAYMENT_ORDER_PAYMET ] := aParam[ nX ][ GRR_CHARGE_PAYMENTMETHOD ]

                        IF GRRA060( aPaymentOrder )
                            MsgAlert( STR0001 )  //"Incluído com sucesso"
                            lRet := .T.
                        EndIf
                    EndIf
                Else
                    MsgAlert( "Error - " + STR0002 )  //"Vencimento ou valor diferente do Protheus com o GRR"
                EndIf
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
    FWFreeArray( aPaymentOrder )
    FWFreeArray( aChargeSalesOrder )
    FWFreeArray( aInfo )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetAccountxSalesOrder
Função que vai buscar os titulos referente ao processo iniciado pelo GRR.

@param cReference, string, Chave do pedido para pesquisa dos títulos.

@return array, Array com os títulos a pagar relacionados ao pedido.
    [1] Filial
    [2] Prefixo do título
    [3] Número do título
    [4] Parcela do título
    [5] Tipo
    [6] Valor do título
    [7] Vencimento do título
@author  Rodrigo G Soares
@since   06/02/2023
/*/
//-------------------------------------------------------------------------------------
Static Function RetAccountxSalesOrder( cReference )
    Local aSvAlias := GetArea()
    Local aSE1 := {}
    Local cQuery := ""
    Local cTmp := GetNextAlias()
    Local aInfo := StrTokArr2( cReference, '|', .T. )
    Local oStatement

    cQuery := "SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_VENCTO " + ;
        " FROM " + RetSQLName( "SE1" ) + " SE1 " + ;
        " INNER JOIN " + RetSQLName( "SC5" ) + " SC5 " + ;
            " ON C5_FILIAL = E1_FILORIG " + ;
            " AND C5_NUM = E1_PEDIDO " + ;
            " AND C5_LIBEROK = 'S' " + ;
            " AND SC5.D_E_L_E_T_= ' ' " + ;
        " INNER JOIN " + RetSQLName( "SF2" ) + " SF2 " + ;
            " ON F2_DOC = C5_NOTA  " + ;
            " AND F2_SERIE = C5_SERIE " + ;
            " AND SF2.D_E_L_E_T_= ' ' " + ;
        " WHERE E1_FILIAL = ? " + ;
            " AND E1_PEDIDO = ? " + ;
            " AND SE1.D_E_L_E_T_= ' ' "

    cQuery := ChangeQuery( cQuery )
    oStatement := FWExecStatement():New( cQuery )

    oStatement:SetString( 1, aInfo[ 2 ] )
    oStatement:SetString( 2, aInfo[ 3 ] )

    MPSysOpenQuery( oStatement:getFixQuery(), cTmp )

    While !( cTmp )->( Eof() )
        aAdd( aSE1, { ( cTmp )->E1_FILIAL, ( cTmp )->E1_PREFIXO, ( cTmp )->E1_NUM, + ;
            ( cTmp )->E1_PARCELA, ( cTmp )->E1_TIPO, ( cTmp )->E1_VALOR, ( cTmp )->E1_VENCTO } )
        
        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aInfo )
    FreeObj( oStatement )
Return aSE1


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendBordero
Função que irá criar um bordero para os titulos que serão negociados com o banco.

@param aAccount, array, Vetor com as informações do título financeiro a receber

@return lRet, lógivco,  Informa se deu certo a o envio para o Bordero.
@author  Rodrigo G Soares
@since   06/02/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SendBordero( aAccount )
    Local aRecInfo := {}
    Local aReceivable := {}
    Local aBordero := {}
    local aBank := StrTokArr2( SuperGetMV( "MV_GRRBPAY", .F. , "||" ), '|', .T. )
    Local cSituation := "1" //Deverá ser criado no Wizard
    Local cBankCode := "001" // itens deverão ser informado no Wizard
    Local dDataMov := DATE()
    Local lRet := .T.
 
    //-- Variáveis utilizadas para o controle de erro da rotina automática
    Local aErroAuto := {}
    Local cErroRet := ""
    
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
 
    //--------------------------------------------------------------
    // Chave do título
    //--------------------------------------------------------------
    AAdd( aRecInfo, { "E1_FILIAL", PadR( aAccount[ 1 ], TamSX3( "E1_FILIAL" )[ 1 ] ), Nil } )
    AAdd( aRecInfo, { "E1_PREFIXO", PadR( aAccount[ 2 ], TamSX3( "E1_PREFIXO" )[ 1 ] ), Nil } )
    AAdd( aRecInfo, { "E1_NUM", PadR( aAccount[ 3 ], TamSX3( "E1_NUM" )[ 1 ] ), Nil } )
    AAdd( aRecInfo, { "E1_PARCELA", PadR( aAccount[ 4 ], TamSX3( "E1_PARCELA" )[ 1 ] ), Nil } )
    AAdd( aRecInfo, { "E1_TIPO", PadR( aAccount[ 5 ], TamSX3( "E1_TIPO" )[ 1 ] ), Nil } )
 
    AAdd( aReceivable, aRecInfo )
    
    //--------------------------------------------------------------
    // Informações bancárias
    //--------------------------------------------------------------
    AAdd( aBordero, { "AUTDATAMOV", dDataMov, Nil } )
    AAdd( aBordero, { "AUTBANCO", PadR( aBank[ 1 ], TamSX3( "A6_COD" )[ 1 ] ), Nil } )
    AAdd( aBordero, { "AUTAGENCIA", PadR( aBank[ 2 ], TamSX3( "A6_AGENCIA" )[ 1 ] ), Nil } )
    AAdd( aBordero, { "AUTCONTA", PadR( aBank[ 3 ], TamSX3( "A6_NUMCON" )[ 1 ] ), Nil } )
    AAdd( aBordero, { "AUTSITUACA", PadR( cSituation, TamSX3( "E1_SITUACA" )[ 1 ] ), Nil } )
    AAdd( aBordero, { "AUTNUMBCO", PadR( cBankCode, TamSX3( "E1_NUMBCO" )[ 1 ] ), Nil } )
    AAdd( aBordero, { "AUTGRVFI2", .T., Nil } )
 
    //--------------------------------------------------------------
    // Carteira descontada deve ser encaminhado o valor de crédito, desconto e IOF já calculados
    // Validar como será realizado a questão de IOF e outros descontos.
    //--------------------------------------------------------------
    // If cSituaca $ "2|7"
    //     AAdd(aTit, {"AUTDESCONT",   090,    Nil})
    //     AAdd(aTit, {"AUTCREDIT",    750,    Nil})
    //     AAdd(aTit, {"AUTIOF",       010,    Nil})
    // EndIf

    MSExecAuto( {|a, b| FINA060( a, b ) }, 3, { aBordero, aReceivable } )
 
    lRet := GRRAutoError( @cErroRet, "SendBordero" )		

    FWFreeArray( aBordero )
    FWFreeArray( aReceivable )
    FWFreeArray( aRecInfo )
    FWFreeArray( aBank )
    FWFreeArray( aErroAuto )
Return lRet
