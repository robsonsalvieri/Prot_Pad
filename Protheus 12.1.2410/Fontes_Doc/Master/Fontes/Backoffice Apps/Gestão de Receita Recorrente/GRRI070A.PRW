#include "protheus.ch"
#include "GRRXDefs.ch"
#include "GRRI070A.ch"

// posições do array de evento
#DEFINE POS_TYPE        1   
#DEFINE POS_DATA        2   

//-------------------------------- GRRI070A --------------------------------------------
// Funções para controle das informações de conciliação da Adyen\Maxipago
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI070A
Função que prepara as informações necessárias para o controle das informações de 
conciliação.

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRI070A( ) 
    Local aSvAlias      := GetArea()
    Local aSteps        := {} 
    Local cIdentifier   := 'conciliation'
    Local nSyncControl  := 0
    Local nSyncValue    := 0

    nSyncControl    := SuperGetMV( "MV_GRRBCOC", .F., 1 )  // BCOC - BANK CONCILIATION CONTROL         
    nSyncValue      := SuperGetMV( "MV_GRRBCOV", .F., 1 )    // BCOV - BANK CONCILIATION  VALUE         

    aAdd( aSteps, 'SyncFlow( )' )

    GRRSyncFlow( cIdentifier, aSteps, nSyncControl, nSyncValue )     

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
    FWFreeArray( aSteps )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla o fluxo de conciliação.

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow(  )
    Local aSvAlias          := GetArea()
    Local aSteps            := {}
    Local aData             := {}
    Local cURLConciliation  := ''
    Local cPath             := '/settlement-events?received=false'
    Local cBKPFil           := ""
    Local oQryHRH           := Nil

    //---------------------------------------------------------
    // Armazena a informação da filial logada
    //---------------------------------------------------------
    cBKPFil := cFilAnt

    cURLConciliation := GRRURLService()

    aAdd( aSteps, 'LoadConciliation( oData, @aData )' )

    //---------------------------------------------------------
    // Busca os dados no serviço do GRR
    //---------------------------------------------------------
    aData := GRRAllResponse( cURLConciliation, cPath, aSteps )

    //---------------------------------------------------------
    // Processa as informações
    //---------------------------------------------------------
    Flow( aData )

    //---------------------------------------------------------
    // Volta a informação da filial logada
    //---------------------------------------------------------
    cFilAnt := cBKPFil

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( oQryHRH )
Return   

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadConciliation
Função que obtém as informações para o fluxo de conciliação.

@param oData, object, response do endpoint
@param @aData, array, vetor com o conteúdo para processamento

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function LoadConciliation( oData, aData )
    aAdd( aData, { oData:settlement:type, oData } )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Flow
Função que controla o processamento das informações.

@param aData, array, informações a serem processadas

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function Flow( aData )
    Local aDataperType  := {}
    Local nI            := 0

    aDataperType := PartperType( aData )

    For nI := 1 to len( aDataperType )
        ExecperType( aDataperType[ nI ] )
    Next
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PartperType
Função que separa as informações do response por tipo de evento

@param aData, array, informações a serem processadas

@return array, vetor com as informações por tipo.
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function PartperType( aData )
    Local aDataperType  := {}
    Local nI            := 0
    Local nPos          := 0

    aSort( aData, , , {| x, y | x[ POS_TYPE ] < y[ POS_TYPE ] } )

    aDataperType := { { GRR_PAY_PREDICTION, {} }, { GRR_PAY_SETTLEMENT, {} } }
    For nI := 1 to len( aData )
        If cBIStr( aData[ nI ][ POS_TYPE ] ) $ cBIStr( GRR_PAY_PREDICTION ) + " | " + cBIStr( GRR_PAY_SETTLEMENT ) 
            nPos := aData[ nI ][ POS_TYPE ] + 1

            aAdd( aDataperType[ nPos ][ POS_DATA ], aData[ nI ][ POS_DATA ] )
        EndIf       
    Next
Return aDataperType

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecperType
Função que executa as operações de acordo com o tipo de evento

@param aData, array, informações a serem processadas

@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ExecperType( aData )
    Local aSvArea           := GetArea()    
    Local aBatchId          := {}
    Local aInvoices         := {}
    Local cDtConciliation   := ''
    Local cBatchId          := ''
    Local cBillId           := ''
    Local cId               := ''
    Local cDetail           := ''
    Local cBank             := ''
    Local cBankUnit         := ''
    Local cBankAcc          := ''
    Local nI                := 0
    Local nType             := 0    
    Local lOk               := .F.
    Local oEvent            := Nil
    Local oBills            := Nil
    Local oBillData         := Nil
    Local cKeySE1           := ''
    Local cKeyBill          := ''

    nType := aData[ POS_TYPE ]  

    For nI := 1 to Len( aData[ POS_DATA ] )
        lOk         := .F.
        cDetail     := ''
        aInvoices   := {}
        cKeySE1     := '' 
        cKeyBill    := '' 

        If nI == 1 
            If nType == 0
                MsgAlert( STR0001 ) //"Processa as provisões"
            else
                MsgAlert( STR0002 )    //"Processa as liquidações"
            EndIf
        EndIf

        BEGIN TRANSACTION 
            If !Empty( aData[ POS_DATA ][ nI ]:settlement )
                cId := aData[ POS_DATA ][ nI ]:id
                If AttIsMemberOf( aData[ POS_DATA ][ nI ], "conciliationDate" )
                    cDtConciliation := GRRTreatData( aData[ POS_DATA ][ nI ]:conciliationDate )
                EndIf

                oEvent      := aData[ POS_DATA ][ nI ]:settlement
                cBatchId    := oEvent:settlementBatchId
                cBillId     := oEvent:billId

                nHRHId := FindHRHInfo( cBillId )  

                If nHRHId > 0

                    HRH->( DBGoto( nHRHId ) )
           
                    If Alltrim( HRH->HRH_SOURCE ) == "MATA410"
                        //---------------------------------------------------------
                        // Localiza as informações de nota pela fatura
                        //---------------------------------------------------------
                        aInvoices := FindInvoiceInfo(HRH->HRH_SRCFIL, HRH->HRH_REQCD)
                    ElseIf Alltrim( HRH->HRH_SOURCE ) $ "GRRI110"
                        If oBills == Nil
                            oBills := totvs.protheus.backoffice.apps.grr.integration.financial.Bills():new()
                        EndIf
                        oBills:setIdDoc( HRH->HRH_REQCD )

                        oBillData := oBills:getBillData()
                        cKeyBill := oBillData['billBranch'] + oBillData['prefix'] + oBillData['number'] + oBillData['installment'] + oBillData['type']
                    ElseIf Substr(Upper(HRH->HRH_SOURCE),1,3) $ "PLS|FIN" 
                        cKeySE1 := HRH->HRH_SRCFIL + HRH->HRH_REQCD 
                    EndIf

                    If !Empty( aInvoices ) .Or. !Empty( cKeySE1 ) .Or. !Empty( cKeyBill )  
 
                        // 0 = Previsão de pagamento
                        If nType == GRR_PAY_PREDICTION
                            MsgAlert( I18N( STR0003, { cBillId } ) )  //"Atualiza os títulos financeiro da fatura #1."
                            //---------------------------------------------------------
                            // Avalia os movimentos de previsão
                            //---------------------------------------------------------
                            lOK := Prediction( aInvoices, cKeySE1,  oEvent, cKeyBill )
                        Else                                
                            If !( FindBankAcc(oEvent) )
                                lOK := .F.
                                cDetail := I18N( STR0004, { Alltrim( cBank ), Alltrim( cBankUnit ), Alltrim( cBankAcc ) } ) //"Informações deste banco: #1, agência: #2 e conta: #3 não localizado no Protheus."
                            Else
                                MsgAlert( I18N( STR0005, { cBillId } ) )    //"Faz a baixa dos títulos a receber da fatura #1, pois foram liquidados."
                                
                                If !Empty(aInvoices)
                                    //---------------------------------------------------------
                                    // Realiza a baixa do título financeiro.
                                    //---------------------------------------------------------
                                    lOK := GRRSettleBill( aInvoices[ 1 ],, oEvent )
                                Else
                                    lOK := GRRSettleBill(,cKeySE1, oEvent, cKeyBill )
                                EndIf
                            EndIf
                            
                        EndIf
                         
                        //---------------------------------------------------------
                        // Chama a função para verificar as taxas do lote
                        //---------------------------------------------------------
                        If lOk
                            If Ascan( aBatchId, {|x| x == cBatchId } ) == 0
                                lOK := BatchProcess( cBatchId, aInvoices, cKeySE1 )

                                aAdd( aBatchId, cBatchId )
                            EndIf
                        EndIf 

                        If !lOk
                            RollbackSx8()
                            DisarmTransaction()
                            If !Empty( cDetail )
                                MsgAlert( cDetail )
                            EndIf
                            If !Empty( aInvoices)    
                                MsgAlert( I18N( STR0006, { aInvoices[1] } ) )  //"Não foi possível realizar as movimentações financeiras da nota #1 !"
                            EndIf
                        EndIf
                         
                        //---------------------------------------------------------
                        // Atualiza o evento de conciliação na plataforma
                        //---------------------------------------------------------
                        ConfirmReceipt( cId, lOk, cDetail )
                    Else
                        //---------------------------------------------------------
                        // Marca a rotina como processada
                        //---------------------------------------------------------
                        ConfirmReceipt( cId, .F., I18N( STR0007, { cID } ) )  //"Nota associada ao evento #1 não encontrada no Protheus."
                    EndIf

                EndIf

            EndIF
        END TRANSACTION
    Next

    RestArea( aSvArea )    
    
    FWFreeArray( aSvArea )
    FWFreeArray( aBatchId )
    FWFreeArray( aInvoices )
    FreeObj( oEvent )
    FreeObj(oBillData)
    FwFreeObj(oBills)
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BatchProcess
Função que realiza a criação do título a pagar relacionada a taxa do lote.

@param cId, caracter, id do lote.
@param aInvoices, array, informações de nota
@param cKeySE1, string, chave do titulo a receber

@return boolean, indica se processou a taxa do lote.
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function BatchProcess( cId, aInvoices, cKeySE1 )
    Local cEndpoint := ''
    Local cPath     := ''
    Local cData     := ''
    Local oRest     := Nil
    Local oResult   := Nil
    Local lOK       := .T.
   
    If !Empty( cId )
        cEndpoint := GRRURLService()
        cPath     := '/settlement-batchs/' + cId
        cResult   := GRRRestExec( 'GET', cEndpoint, cPath, @oRest )

        If !Empty( cResult )
            If !Empty( cResult )
                oResult := JSONObject():New() 
                oResult:FromJSON( cResult )

                If oResult[ 'batchFee' ] > 0
                    cData := GRRTreatData( oResult[ 'conciliationDate' ] )
                    MsgAlert( I18N( STR0008, { cData } ) )    //"Gera um título já baixado do contas a pagar para o provedor com a taxa do lote do dia #1"

                    lOK := MakeAPBatchFee( oResult, aInvoices, cKeySE1 )
                EndIf
            EndIf
        EndIf
    ENDIF

    FreeObj( oRest )
    FreeObj( oResult )
Return lOK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConfirmReceipt
Função que confirma o recebimento do evento na plataforma.

@param cId, caracter, Id do evento
@param lOk, boolean, indica se o registro foi concialiado ou não
@param cDetail, caracter, detalhe do evento

@return boolean, indica se confirmou o recebimento do evento
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ConfirmReceipt( cId, lOk, cDetail )
    Local aPatch    := {}
    Local cEndpoint := ''
    Local cPath     := ''
    Local cMsg      := ''
    Local lRet      := .F.

    Default cDetail := ''

    cEndpoint   := GRRURLService()
    cPath       := '/settlement-events/' + cId 

    cMsg := I18N( STR0011, { cID, cDetail } ) //"Evento #1 processado. #2"

    MsgAlert( cMsg )

    aAdd( aPatch, { 'status', Iif( lOk, 1, 0 ) } )      // 0=Não conciliada; 1=Conciliada
    aAdd( aPatch, { 'received', "true" } )
    aAdd( aPatch, { 'detail', EncodeUTF8( cDetail ) } )
    
    lRet := GRRPatchExec( { cEndpoint, cPath }, aPatch, 'status', cMsg )

    FWFreeArray( aPatch )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FindHRHInfo
Função que procura as informações da assinatura a partir da fatura.

@param cBillId, caracter, Guid da fatura

@return number, R_E_C_N_O_ do registro na HRH
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function FindHRHInfo( cBillId )
    Local aSvAlias  := GetArea()
    Local cQuery    := ''
    Local cTempHRH  := ''
    Local nID       := 0
    Local oQryHRH   := Nil

    If !Empty( cBillId )
        oQryHRH := GRRGetQuery( 'QGRR070_Signature' )
        oQryHRH:SetString( 1, cBillId )

        cQuery := oQryHRH:GetFixQuery()
        cTempHRH := MPSysOpenQuery( cQuery )

        If ( cTempHRH )->( !Eof() )   
            nId := ( cTempHRH )->ID
        EndIf
        ( cTempHRH )->( DBCloseArea() )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( oQryHRH )
Return nId

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FindInvoiceInfo
Função que procura as informações de nota a partir do Recno do HRH.

@param nHRHId, integer, Recno do HRH

@return array, vetor com as informações de nota
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function FindInvoiceInfo(cReqBranch, cRequest)
    Local aSvAlias  := GetArea()
    Local aResult   := {}
    Local cQryAlias := ''
    Local oQuery    := Nil

    Default cReqBranch  := ''
    Default cRequest    := ''

    oQuery := GRRGetQuery( 'QGRR070_InvoicesxSC5' )
    oQuery:SetString( 1, xFilial( "SC5" ) )
    oQuery:SetString( 2, Alltrim( cRequest ) )
    oQuery:SetString( 3, xFilial( "SD2" ) )
    oQuery:SetString( 4, cFilAnt )

    cQryAlias := MPSysOpenQuery( oQuery:GetFixQuery() )

    If ( cQryAlias )->( !Eof() )
        While ( cQryAlias )->(!Eof() )
            aAdd( aResult, ( cQryAlias )->F2_FILIAL + ( cQryAlias )->F2_DOC + ( cQryAlias )->F2_SERIE + ( cQryAlias )->F2_CLIENTE + ( cQryAlias )->F2_LOJA )   

            ( cQryAlias )->( DBSkip() )
        End
    EndIf
    ( cQryAlias )->( DBCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FreeObj( oQuery )
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeQueryModel
Função responsável por criar a query base para localizar as informações do pedido de 
venda a partir do guid da fatura.

@param cOper, caracter, Identifica qual a query será retornada

@return caracter, String contendo a query base a ser executada.
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeQueryModel( cOper )
    Local cQuery := ''

    If cOper == 'QGRR070_Signature'
        cQuery := "SELECT HRH_SRCFIL, HRH_ALIAS, HRH_REQCD, HRH_SOURCE, R_E_C_N_O_ ID " + ;
            " FROM " + RetSqlName( "HRH" ) + ;
            " WHERE HRH_BILLID = ? AND D_E_L_E_T_ = ' '"

    Elseif cOper == "QGRR070_InvoicesxSC5"
        cQuery := "SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA " + ;
                " FROM " + RetSqlName( "SF2" ) + " SF2 " + ; 
                " INNER JOIN " + RetSqlName( "SC5" ) + " SC5 " + ; 
                " ON C5_FILIAL = ? " + ; 
                    " AND C5_NUM = ? " + ; 
                    " AND SC5.D_E_L_E_T_ = ' ' " + ; 
                " INNER JOIN " + RetSqlName( "SD2" ) + " SD2 " + ; 
                " ON D2_FILIAL = ? " + ; 
                    " AND D2_DOC = F2_DOC " + ;  
                    " AND D2_SERIE = F2_SERIE " + ; 
                    " AND D2_CLIENTE = F2_CLIENTE " + ; 
                    " AND D2_LOJA = F2_LOJA " + ; 
                    " and D2_PEDIDO = C5_NUM " + ; 
                    " AND SD2.D_E_L_E_T_ = ' ' " + ;  
                " INNER JOIN " + RetSqlName( "SE1" ) + " SE1 " + ;
                " ON E1_FILORIG = ? " + ; 
                    " AND E1_NUM = F2_DOC " + ; 
                    " AND E1_PREFIXO = 'GRR' " + ; 
                    " AND E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' " + ; 
                " WHERE SF2.D_E_L_E_T_ = ' ' " + ; 
                " GROUP BY F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA"    
    EndIf
Return cQuery

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Prediction( cTmpAlias, oEvent )
Função responsável por administrar a previsão de pagamento dos títulos financeiros 
para cada fatura.

@param aInvoices, array, informações de nota
@param cKeySE1, caracter, chave do título
@param oEvent, objetct, dados do evento que está sendo processado
@param cKeyBill, caracter, chave do título quando a origem é GRRI110

@return boolean, indica se processou a previsão de pagamento.
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function Prediction( aInvoices, cKeySE1, oEvent, cKeyBill )
    Local lRet := .T.

    If !Empty( aInvoices )
        lRet := GRRFinPrediction( aInvoices[ 1 ], cKeySE1, oEvent, cKeyBill )
    Else
        lRet := GRRFinPrediction(, cKeySE1, oEvent, cKeyBill ) 
    EndIf
Return lRet

/*/{Protheus.doc} FindBankAcc
    Busca o banco(SA6) de acordo com os dados de <oEvent>. Considera o cenário do digito verificador estar concactenado com a conta corrente.
@param oEvent, object, evento da conciliação
@return lFound, lógico, se algum banco foi encontrado no cadastro
@author philipe.pompeu
@since 03/02/2025
/*/
Static Function FindBankAcc(oEvent) as Logical
    Local aAreas as Array
    Local cBank as Char
    Local cBankUnit as Char
    Local cBankAcc as Char
    Local nX as Numeric
    Local nBank as Numeric
    Local nBankUnit as Numeric
    Local nBankSize	as Numeric
    Local lFound as Logical

    aAreas      := { SA6->(GetArea()), GetArea() }
    lFound      := .F.
    nBank       := GetSx3Cache( "A6_COD"        , "X3_TAMANHO")
    nBankUnit   := GetSx3Cache( "A6_AGENCIA"    , "X3_TAMANHO")

    cBank 		:= PadR( oEvent:bankCode, nBank )  
    cBankUnit	:= PadR( oEvent:bankBranchCode, nBankUnit ) 
    cBankAcc	:= StrTran(AllTrim(oEvent:bankAccountNumber), '-','')
    nBankSize   := Len(cBankAcc)

    If !Empty( cBank ) .And. !Empty( cBankUnit ) .And. !Empty( cBankAcc )

        SA6->( DBSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON        
        for nX := 0 to 1
            If (lFound := SA6->( MSSeek( xFilial( 'SA6' ) + cBank + cBankUnit + Left(cBankAcc, (nBankSize - nX) ) ) ))
                Exit
            EndIf
        next nX
    EndIf

    If lFound
        /*Atualiza o objeto <oEvent> para que no processamento posterior realizado no GRRA030(ExecSettle) os dados dos bancos estejam corretos*/
        oEvent:bankCode         := SA6->A6_COD
        oEvent:bankBranchCode   := SA6->A6_AGENCIA
        oEvent:bankAccountNumber:= SA6->A6_NUMCON
    EndIf

    aEval(aAreas, {|x|RestArea(x)})
	FwFreeArray(aAreas)    
Return lFound
