#include "protheus.ch"
#include "GRRXDefs.ch"
#include "GRRI080.ch"

//-------------------------------- GRRI080 --------------------------------------------
// Funções que realizam o processo de recorrência para faturas geradas automaticamente 
// pela plataforma.
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI080
Função que prepara as informações necessárias para a criação de pedidos de faturas gera-
das pela plataforma.

@author  Marcia Junko
@since   22/08/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI080( )
    Local aSvAlias := GetArea()
    Local aSteps := {}
    Local cIdentifier := 'new_order'
    Local nSyncControl := 0
    Local nSyncValue := 0

    nSyncControl := SuperGetMV( "MV_GRRGNOC", .F., 1 )  // GNOC - GENERATE NEW ORDER CONTROL         
    nSyncValue := SuperGetMV( "MV_GRRGNOV", .F., 1 )    // GNOV - GENERATE NEW ORDER VALUE         

    aAdd( aSteps, 'SyncFlow( )' )

    GRRSyncFlow( cIdentifier, aSteps, nSyncControl, nSyncValue )     

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FWFreeArray( aSteps )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla a criação dos pedidos de venda de acordo com as faturas geradas 
pela plataforma

@author  Marcia Junko
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow(  )
    Local aSvAlias := GetArea()
    Local aResult := {}
    Local aIntegration := {}
    Local cEndpoint := GRRURL()
    Local cPath := '/bills?status=2'
    Local cPage := ''
    Local cResult := ''
    Local cAux := ""
    Local cBKPFil := ""
    Local lFirst := .T.
    Local lHasNext := .F.
    Local lApprovedQuant := .F.
    Local nI := 0
    Local nPage := 1
    Local oRest
    Local oResult
    Local oJson

    // Pergunte( "MTA410", .F. )
	// IF MV_PAR01 == 1
	// 	lApprovedQuant := .T.
	// EndIf
    
    //---------------------------------------------------------
    // Armazena a informação da filial logada
    //---------------------------------------------------------
    cBKPFil := cFilAnt

    While lFirst .Or. lHasNext
        oRest := NIL
        lHasNext := .F.

        IF lFirst
            lFirst := .F.
        else
            nPage++
            cPage := "&page=" + Alltrim( Str( nPage ) )
        EndIf

        cResult := GRRRestExec( 'GET', cEndpoint, cPath + cPage, @oRest )

        If !Empty( cResult )
            oResult := JSONObject():New() 
            oResult:FromJSON( cResult )

            lHasNext := oResult[ 'hasNext' ]
            aResult := oResult[ 'responseData' ]

            If !Empty( aResult )
                If FWJsonDeserialize( cResult, @oJson)
                    If AttIsMemberOf( oJson, "responseData" )
                        For nI := 1 to len( oJson:responseData )
                            cAux := oJson:responseData[ nI ]:organizationIntegrationId
                            
                            If cAux <> NIL
                                aIntegration := StrTokArr2( cAux, '|' )
                                
                                If aIntegration[ INT_COMPANY ] == cEmpAnt
                                    //---------------------------------------------------------
                                    // Atribui a variável do sistema a filial do registro que 
                                    // está sendo processada.
                                    //---------------------------------------------------------
                                    cFilAnt := aIntegration[ INT_BRANCH ] 
                                    SetData( oJson:responseData[ nI ], lApprovedQuant )
                                EndIf
                            EndIf
                        Next    
                    EndIf 
                EndIf
            EndIF
        EndIf
    End
    
    //---------------------------------------------------------
    // Volta a informação da filial logada
    //---------------------------------------------------------
    cFilAnt := cBKPFil

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetData
Função que atribui as informações do fatura para uma estrutura de metadata do pedido de venda.

@param oData, json, dados da fatura
@param lApprovedQuant, boolean, indica se deve liberar as quantidades dos itens do pedido
    durante a criação do pedido de venda.

@return lResult, boolean, se a operação ocorreu com sucesso
@author  Marcia Junko
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetData( oData, lApprovedQuant )
    Local aSvAlias := GetArea()
    Local aSC5 := {}
    Local aSC5Fields := {}
    Local aSC6 := {}
    Local aSC6Fields := {}
    Local aMetaSC5 := {}
    Local aMetaSC6 := {}
    Local aCustomerIntegration := {}
    Local aItemSC6 := {}
    Local nI := 0
    Local lResult := .F.
    Local oItem

    If oData:reference == NIL 
        If oData:source  == 'MATA410'
            aSC5Fields := GRRMetaFields( GRR_SALESORDER, .F. ) 
            aSC6Fields := GRRMetaFields( GRR_SALESORDER_ITEMS, .F. ) 

            //----------------------------------------------------------------
            // Armazena a informação da Bill e subscription para manipular o 
            // status posteriormente
            //----------------------------------------------------------------
            Aadd( aSC5Fields, "BILL_ID" )
            Aadd( aSC5Fields, "SUBS_ID" )

            //-----------------------------------------------------
            // Monta o metadata da SC5
            //-----------------------------------------------------
            aMetaSC5 := oData:metadata

            //------------------------------------------------------------------
            // Tratamento para que o fluxo de criação do pedido não prossiga 
            // caso haja algum problema com o metadata do item
            //------------------------------------------------------------------
            If !Empty( aMetaSC5 )
                aSC5 := GRRSetMetadata( aClone( aSC5Fields ), GRR_LOAD_METADATA )

                aCustomerIntegration := StrTokArr2( oData:customerIntegrationId, '|' )
            
                SetInMetadata( @aSC5, "C5_CLIENTE", aCustomerIntegration[ 3 ] )
                SetInMetadata( @aSC5, "C5_LOJACLI", aCustomerIntegration[ 4 ] )

                SetInMetadata( @aSC5, "BILL_ID", oData:id )
                SetInMetadata( @aSC5, "SUBS_ID", oData:subscriptionId )

                aEval( aSC5, {|x| aAdd( aMetaSC5, x ) } )
            EndIf

            //-----------------------------------------------------
            // Monta o metadata por item da SC6
            //-----------------------------------------------------
            For nI := 1 to len( oData:items )
                aSC6 := {}

                aSC6 := GRRSetMetadata( aclone( aSC6Fields ), GRR_LOAD_METADATA )
                oItem := oData:items[ nI ]

                aItemSC6 := oItem:metadata

                //------------------------------------------------------------------
                // Tratamento para que o fluxo de criação do pedido não prossiga 
                // caso haja algum problema com o metadata do item
                //------------------------------------------------------------------
                If !Empty( aItemSC6 )
                    SetInMetadata( @aSC6, "C6_PRODUTO", oItem:billItemReference )
                    SetInMetadata( @aSC6, "C6_UM", oItem:unitMeasurement )
                    SetInMetadata( @aSC6, "C6_QTDVEN", oItem:quantity )
                    SetInMetadata( @aSC6, "C6_PRUNIT", oItem:baseValue )
                    SetInMetadata( @aSC6, "C6_PRCVEN", oItem:baseValue )
                    SetInMetadata( @aSC6, "C6_VALOR", oItem:totalAmount )

                    aEval( aItemSC6, {|x| aAdd( aSC6, x ) } )

                    Aadd( aMetaSC6, aClone( aSC6 ) )
                EndIf
            Next

            //-----------------------------------------------------
            // Chama a execauto para criar o pedido de venda pela 
            // estrutura do metadata
            //-----------------------------------------------------
            If !Empty( aMetaSC5 ) .And. ( !Empty( aMetaSC6 ) .And. ( Len( oData:items ) == len( aMetaSC6 ) ) )
                lResult := GRRI080SalesOrder( aMetaSC5, aMetaSC6, lApprovedQuant )
            Else
                MsgAlert( I18N( STR0003, { oData:subscriptionIntegrationId } ) )    //"Não foi possível gerar o pedido de venda baseado no pedido #1 pois há falhas na estrutura do metadata."
            EndIf
        EndIf
    EndIF

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aSC5 )
    FWFreeArray( aSC5Fields )
    FWFreeArray( aSC6 )
    FWFreeArray( aSC6Fields )
    FWFreeArray( aMetaSC5 )
    FWFreeArray( aMetaSC6 )
    FWFreeArray( aCustomerIntegration )
    FWFreeArray( aItemSC6 )
    FreeObj( oItem )
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI080SalesOrder
Função que cria um pedido de venda baseado nos dados do metadata

@param aMetaHeader, array, vetor de json com as propriedades da SC5
@param aMetaItens, array, vetor de json com as propriedades da SC6
@param lApprovedQuant, boolean, indica se deve liberar as quantidades dos itens do pedido
    durante a criação do pedido de venda.

@return  lRet, boolean, se a geração do pedido ocorreu com sucesso.
@author  Marcia Junko
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI080SalesOrder( aMetaHeader, aMetaItens, lApprovedQuant )
    Local aSvAlias := GetArea()
    Local aHeader := {}
    Local aHeaderHRH := {}
    Local aHRHInfo := {}
    Local aItens := {}
    Local aLine := {}
    Local aNewReference := {}
    Local nI := 0
    Local nJ := 0
    Local nPos := 0
    Local cRequest := ""
    Local cField := ""
    Local cBillId := ""
    Local cSubsId := ""
    Local cIntegrationId := ""
    Local cError := ""
    Local lRet := .T.

    Default lApprovedQuant := .F.
    
    PRIVATE lMsErroAuto := .F.

    // If Valtype( lApprovedQuant ) == NIL
    //     Pergunte( "MTA410", .F. )
    //     IF MV_PAR01 == 1
    //         lApprovedQuant := .T.
    //     else
    //         lApprovedQuant := .F.
    //     EndIf
    // EndIf

    aadd( aHeaderHRH, { "HRH_SRCFIL", xFilial("SC5"), Nil } )
    aadd( aHeaderHRH, { "HRH_ALIAS", "SC5", Nil } )
    aadd( aHeaderHRH, { "HRH_SOURCE", "MATA410", Nil } )
    aadd( aHeaderHRH, { "HRH_REQCD", "#XXX#", Nil } )
    
    For nI := 1 to len( aMetaHeader )
        cField := Upper( Alltrim( aMetaHeader[ nI ][ "key" ] ) )
        If aMetaHeader[ nI ][ "alias" ] == "SC5"
            If cField != "C5_NUM"
                If cField != "BILL_ID"
                    If cField != "SUBS_ID"
                        aAdd( aHeader, { cField, aMetaHeader[ nI ][ "value" ], NIL } )
                    else
                        cSubsId := aMetaHeader[ nI ][ "value" ]
                    EndIf
                else
                    cBillId := aMetaHeader[ nI ][ "value" ]
                EndIf
            EndIf
        elseif aMetaHeader[ nI ][ "alias" ] == "HRH"
            If cField == "HRH_PLANCD"
                aAdd( aHeaderHRH, { "HRH_PLNFIL",  xFilial( "HRD" ), NIL } )
            EndIf
            aAdd( aHeaderHRH, { cField, aMetaHeader[ nI ][ "value" ], NIL } )
        EndIf
    Next

    For nI := 1 to len( aMetaItens )
        aLine := {}
        For nJ := 1 to len( aMetaItens[ nI ] )
            cField := aMetaItens[ nI ][ nJ ][ "key" ]
            If cField == "C6_ITEM"
                aadd( aLine, { "C6_ITEM", StrZero( nI, 2 ),  Nil } )
            else
                aAdd( aLine, { cField, aMetaItens[ nI ][ nJ ][ "value" ], NIL } )
            EndIf        
        Next

        // -------------------------------------------------------------------------
        // Força a criação de itens no pedido de venda sem liberação automática
        // -------------------------------------------------------------------------
        If ( nPos := Ascan( aLine, {|x| x[1] == "C6_QTDLIB" } ) ) == 0
            aAdd( aLine, { "C6_QTDLIB", 0, NIL } )
        else
            If !lApprovedQuant
                aLine[ nPos ][ 2 ] := 0
            EndIf
        EndIf

        aadd( aItens, aLine )
    Next

    // -------------------------------------------------------------
    // Monta o vetor com as informações da tabela intermediária HRH
    // -------------------------------------------------------------
    aHRHInfo := GRRHRHFieldsInOrder( aHeaderHRH )

    If Len( aItens ) > 0
        BEGIN TRANSACTION
            MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aHeader, aItens, 3, .F. )

            If !lMsErroAuto
                cRequest := SC5->C5_NUM

                // -------------------------------------------------------------
                // Substitui o valor temporário do HRH_REQCD
                // -------------------------------------------------------------
                nPos := Ascan( aHRHInfo, {|x| x == "#XXX#" } )
                aHRHInfo[ nPos ] := cRequest

                // -------------------------------------------------------------
                // Cria a relação entre o pedido e o plano GRR
                // -------------------------------------------------------------
                GRRA050( aHRHInfo )

                // ----------------------------------------------------------------------------
                // Salva o guid da subscrição na tabela intermediária de assinatura ( HRH )
                // ----------------------------------------------------------------------------
                If !Empty( cSubsId )
                    GRRSetSubscriptionId( { xFilial( "SC5" ), "SC5", cRequest }, cSubsId )
                Endif

                IF !Empty( cBillId )
                    cIntegrationId := cEmpAnt + '|'+ aHRHInfo[1] + '|' + Alltrim( cRequest )
                    aAdd( aNewReference, { 'integrationId', cIntegrationId } )
                    aAdd( aNewReference, { 'reference', cRequest } )

                    // ----------------------------------------------------------------------------
                    // Atribui os dados de integração do Protheus nas faturas ( bills ) 
                    // ----------------------------------------------------------------------------
                    lRet := GRRBillReferences( cBillId, aNewReference )

                    // Por enquanto a variável lApprovedQuant é sempre .F., por isso não entraria na GRRBillStatus
                    // IF lRet .And. lApprovedQuant
                    //     GRRBillStatus( cIntegrationId )
                    // EndIf

                    // ----------------------------------------------------------------------------
                    // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                    // ----------------------------------------------------------------------------
                    GRRSetBillId( { xFilial( "SC5" ), "SC5", cRequest }, cBillId )
                Else
                    lRet := .T.
                EndIf
            Else
                lRet := GRRAutoError( @cError, "GRRI080SalesOrder" )
                RollbackSx8()
                DisarmTransaction()
                MsgAlert( STR0005 ) //"Não foi possível gerar o pedido de venda." 
            EndIf
        END TRANSACTION
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aHeader )
    FWFreeArray( aHeaderHRH )
    FWFreeArray( aHRHInfo )
    FWFreeArray( aItens )
    FWFreeArray( aLine )
    FWFreeArray( aNewReference )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetInMetadata
Função que atribui uma informação específica em um campo do metadata.

@param @aArray, vetor, array com a estrutura json do metadata.
@param cField, caracter, nome do campo para busca
@param xValue, any, conteúdo que será atribuído.

@author  Marcia Junko
@since   06/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetInMetadata( aArray, cField, xValue )
    GRRSetJsonValue( aArray, cField, xValue )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRBillReferences
Função que atribui os dados de integração gerados no Protheus nas faturas ( bills ) 
da plataforma.

@param cBillId, caracter, guid da fatura na plataforma
@param aValues, array, vetor com as propriedades a serem atualizadas na fatura, onde:  
    [1] - nome da propriedade
    [2] - conteúdo

@author  Marcia Junko
@since   08/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRBillReferences( cBillId, aValues )
    Local lRet := .F.
    Local cEndpoint := GRRURL()
    Local cPath := '/bills'
    Local cResult := ''
    Local cMsg := ''
    Local nI := 0
    Local oResult
    Local jBillReferences 

    If !Empty( cBillId )
        cPath += '/' + cBillId + '/integration'

        IF !Empty( aValues )
            If ( nI := Ascan( aValues, {|x| x[ 1 ] == 'reference' } ) ) > 0
                cMsg := I18n( STR0001, { alltrim( aValues[ nI ][ 2 ] ) } )  //"Dados de integração da fatura com o pedido #1 enviado com sucesso para a plataforma."
            EndIf

            jBillReferences := GRRArrtoJson( aValues )
        
            cResult := GRRSyncData( NIL, jBillReferences, cEndPoint, cPath, GRR_PATCH, NIL, @cMsg )

            If !Empty( cResult )
                oResult := JSONObject():New() 
                oResult:FromJSON( cResult )

                If !Empty( oResult[ "integrationId" ] ) 
                    lRet := .T.
                Endif
            EndIf
        End
    EndIf

    FreeObj( oResult )
    FreeObj( jBillReferences ) 
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRBillStatus
Função que atualiza o status de uma determinada fatura na plataforma de acordo com o 
integrationID informado.

@param cIntegrationId, caracter, Integration ID da fatura na plataforma
@param cStatus, caracter, novo status da fatura.

@author  Marcia Junko
@since   08/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRBillStatus( cIntegrationId, cStatus )
    Local aSalesOrder := {}
    Local cEndpoint := GRRURL()
    Local cPath := '/bills/integration'
    Local cResult := ''
    Local cRequest := ''
    Local cMsg := ''
    Local jBillStatus 
    Local lRet := .F.
    Local cOperation := ""

    Default cStatus := GRR_BILL_STATUS_MEASUREMENTCOMPLETED     // 7=Medição Realizada

    If ( cStatus == GRR_BILL_STATUS_MEASUREMENTCOMPLETED )  // 7=Medição Realizada
        cOperation := 'measurement-completed'
    ElseIf ( cStatus == GRR_BILL_STATUS_AWAITINGPAYMENT )   // 3=Aguardando Pagamento
        cOperation := 'awaiting-payment'
    EndIf

    If !Empty( cIntegrationId )
        cPath += '/' + FwUrlEncode(cIntegrationId) + '/'+ cOperation

        aSalesOrder := StrtokArr( cIntegrationId, '|' )
        cRequest := aSalesOrder[ INT_REFERENCE ]

        cMsg := I18N( STR0002, { cRequest } )   //"Medição efetuada para o pedido #1"

        jBillStatus := JsonObject():New()
        jBillStatus[ 'status' ] := cStatus

        cResult := GRRSyncData( NIL, jBillStatus, cEndPoint, cPath, GRR_PUT, NIL, @cMsg )

        If !Empty( cResult )
            lRet := .T.
        EndIf
    EndIf

    FreeObj( jBillStatus )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSetDueDate
	Atualiza a fatura com a data de vencimento calculada por <bGetDueDate)
@author philipe.pompeu
@since 19/04/2024
@param cIntegrationId , caracter  , Integration ID da fatura na plataforma
@param aDocument      , array     , vetor com a filial e identificador do documento(número do pedido ou título)
@param bGetDueDate    , code-block, bloco de código responsável por retornar uma data de vencimento nova
@return lRet, lógico, se a operação foi realizada com sucesso
/*/
//-------------------------------------------------------------------------------------
Function GRRSetDueDate( cIntegrationId, aDocument, bGetDueDate )    
    Local cEndpoint := GRRURL()
    Local cPath     := ''
    Local cResult   := ''
    Local cMsg      := ''    
    Local cNewDueDate   := ''
    Local lRet := .F.
    Local jBillPatch 
    Local jUpdateProp 
    Default bGetDueDate := {|x| GetDueDate(x) } //Por padrão, obtem usando o GetDueDate, que espera que aDocument seja um pedido de venda

    If !Empty( cIntegrationId ) .And. ( ValType( aDocument ) == 'A' .And. Len( aDocument ) >= 2 )
        cPath := '/bills/' + FwUrlEncode( cIntegrationId )
        
        cNewDueDate := Eval(bGetDueDate, aDocument)        

        cMsg := I18N( STR0006, { cIntegrationId } )   //"Data de vencimento da subscrição #1 atualizada"

        jUpdateProp := JsonObject():New()
        jUpdateProp[ 'op' ]    := 'replace'
        jUpdateProp[ 'path' ]  := '/DueDate'
        jUpdateProp[ 'value' ] := cNewDueDate
        
        jBillPatch := JsonObject():New()
        
        jBillPatch:Set( { jUpdateProp } ) //Inclui na raiz do objeto um vetor com as propriedades a serem atualizadas

        cResult := GRRSyncData( NIL, jBillPatch, cEndPoint, cPath, GRR_PATCH, NIL, @cMsg )

        If !Empty( cResult )
            lRet := .T.
        EndIf
    EndIf

    FreeObj( jUpdateProp )
    FreeObj( jBillPatch )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDueDate
Calcula a data de vencimento do pedido e retorna a data no formato esperado pela plataforma

@param aSalesOrder , array, vetor com a filial e número do pedido

@return cDueDate, caractere, data de vencimento no formato yyyy-mm-dd
@author philipe.pompeu
@since 19/04/2024
/*/
//-------------------------------------------------------------------------------------
Static Function GetDueDate( aSalesOrder )
    Local aAreas := { SC5->( GetArea() ), SE4->( GetArea() ), SC9->( GetArea() ), GetArea() }
    Local aParcel   := {}
    Local cSeek     := ""
    Local cDueDate  := ""
    Local dDueDate  := Date()
    Local dStart

    cSeek := aSalesOrder[ 1 ] + aSalesOrder[ 2 ]
    SC5->( DbSetOrder( 1 ) )    //C5_FILIAL+C5_NUM
    If SC5->( MSSeek( cSeek ) )
        If ( Posicione( 'SE4', 1, xFilial( "SE4" ) + SC5->C5_CONDPAG, "E4_TIPO" ) == "9" )
            //---------------------------------------------------------
            // Se for condição tipo 9, usa a data informada diretamente no campo
            //---------------------------------------------------------
            dDueDate := SC5->C5_DATA1 
        Else
            dStart := SC5->C5_EMISSAO

            SC9->( DbSetOrder( 1 ) )    //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED        
            If SC9->( MSSeek( xFilial( "SC9" ) + SC5->C5_NUM ) )
                dStart := SC9->C9_DATALIB
            EndIf
            
            aParcel := Condicao( 1, SC5->C5_CONDPAG, , dStart )
            If !Empty( aParcel )
                dDueDate := aParcel[ 1, 1 ]
            EndIf
        EndIf
    EndIf

    cDueDate := dateFormat( dDueDate, "yyyy-mm-dd" )

    aEval( aAreas, {| x | RestArea( x ) } )
    FwFreeArray( aAreas )
    FwFreeArray( aParcel )
Return cDueDate


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRUpdateBill
Atualiza os dados da fatural(bill) conforme informações do pedido de venda e muda sua situação para medição completa

@param cIntegrationId   , caracter  , Integration ID da fatura na plataforma
@param aSalesOrder      , array     , vetor com a filial e número do pedido a ser atualizado

@return lRet, lógico, se a operação foi realizada com sucesso
@author philipe.pompeu
@since 03/05/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRUpdateBill( cIntegrationId, aSalesOrder, cStatus )
    Local lResult := .F.
    Default cStatus := GRR_BILL_STATUS_MEASUREMENTCOMPLETED     // 7=Medição Realizada
    
    //---------------------------------------------------------
    // Atualiza a data de vencimento da fatura conforme o pedido de venda
    //---------------------------------------------------------
    If ( lResult := GRRSetDueDate( cIntegrationId, aSalesOrder ) ) 
        //---------------------------------------------------------
        // Verifica se pode customizar os valores e quantidades dos itens das subscrições GRR
        //---------------------------------------------------------
        If SuperGetMV( "MV_GRRICST", .F. , .F. ) 
            //---------------------------------------------------------
            // Atualiza os itens caso tenha tido alguma mudança nas quantidades/valor unitário            
            //---------------------------------------------------------
            lResult := GRRUpdateItems( cIntegrationId, aSalesOrder ) 
        EndIf
    EndIf

    If lResult
        //---------------------------------------------------------
        // Atualiza a situação da fatura para <cStatus>
        //---------------------------------------------------------
        lResult := GRRBillStatus( cIntegrationId , cStatus) 
    endif
Return lResult


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRUpdateItems
Atualiza os itens da fatural(bill) conforme os produtos do pedido de venda

@param cIntegrationId , caracter    , Integration ID da fatura na plataforma
@param aDocument      , array       , vetor com a filial e número do pedido vinculado a fatura
@param bUpdateItems   , code-block  , define operação a ser realizada ao atualizar os itens da fatura
@return lRet, lógico, se a operação foi realizada com sucesso
@author philipe.pompeu
@since 03/05/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRUpdateItems( cIntegrationId, aDocument, bUpdateItems)    
    Local cEndpoint := GRRURL()
    Local cPath     := ''
    Local cResult   := ''
    Local cMsg      := ''
    Local aItems    := {}
    Local lRet      := .F.
    Local nTotal    := 0
    Local nX        := 0
    Local nDecTotal := GetSx3Cache('C6_VALOR','X3_DECIMAL')    
    Local jBillPatch 
    Local jUpdItems 
    Local jUpdTotal

    Local oRest := Nil
    Local jBill 

    Default bUpdateItems := {|x, y| UpdateBillItems(x, y) } // Atualiza os itens da fatura com base no pedido de vendas

    If !Empty( cIntegrationId ) .And. ( ValType( aDocument ) == 'A' .And. Len( aDocument ) >= 2 )
        cPath := '/bills/' + FwUrlEncode( cIntegrationId )

        cResult := GRRRestExec( 'GET', cEndpoint, cPath, @oRest )

        If ( lRet := !Empty( cResult ) )
            jBill := JsonObject():New()

            jBill:FromJSON( cResult )

            If jBill:HasProperty( 'items' )                
                aItems := jBill[ 'items' ] //Obtem itens da fatura
            EndIf
        EndIf        

        If Len( aItems ) > 0            
            cMsg := I18N( STR0007, { aDocument[ 2 ] } )   //"Itens do pedido #1 atualizado."
            
            aItems := Eval(bUpdateItems, aDocument, aItems)//Processa atualização dos itens
            
            for nX := 1 to Len(aItems)
                nTotal += aItems[nX]['totalAmount']//Soma do total dos itens
            next nX
            nTotal := Round(nTotal, nDecTotal)

            jUpdItems := JsonObject():New()
            jUpdItems[ 'op' ]    := 'replace'
            jUpdItems[ 'path' ]  := '/Items'
            jUpdItems[ 'value' ] := aItems 

            jUpdTotal := JsonObject():New()
            jUpdTotal[ 'op' ]    := 'replace'
            jUpdTotal[ 'path' ]  := '/TotalAmount'
            jUpdTotal[ 'value' ] := nTotal
            
            jBillPatch := JsonObject():New()
            
            //---------------------------------------------------------
            // Inclui na raiz do objeto um vetor com as propriedades a serem atualizadas
            //---------------------------------------------------------
            jBillPatch:Set( { jUpdItems, jUpdTotal } ) 

            cResult := GRRSyncData( NIL, jBillPatch, cEndPoint, cPath, GRR_PATCH, NIL, @cMsg )            
        EndIf
        
        lRet := !Empty( cResult )
    EndIf

    FwFreeArray( aItems )
    FreeObj( jBill )
    FreeObj( jUpdTotal )
    FreeObj( jUpdItems )
    FreeObj( jBillPatch )
    FreeObj( oRest )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateBillItems
Atualiza os itens da fatural(bill) conforme os produtos do pedido de venda(SC6)

@param aSalesOrder  , array , vetor com a filial e número do pedido vinculado a fatura
@param aOrigItems   , array , vetor de objetos json com os itens da fatura no formato esperado pela plataforma

@return aItems      , array , produtos atualizados
@author philipe.pompeu
@since 03/05/2024
/*/
//-------------------------------------------------------------------------------------
Static Function UpdateBillItems( aSalesOrder, aOrigItems )
    Local aAreas    := { SC5->( GetArea() ), SC6->( GetArea() ), GetArea() }    
    Local aItems    := aOrigItems
    Local aIntegId  := {}
    Local cSeek     := ""
    Local cProduct  := ""
    Local cIntegId  := ""
    Local nX        := 0
    Local nSizeProd := GetSx3Cache( 'C6_PRODUTO', 'X3_TAMANHO' )
    Local jItem    

    cSeek := aSalesOrder[ 1 ] + aSalesOrder[ 2 ]
    SC5->( DbSetOrder( 1 ) )    //C5_FILIAL+C5_NUM
    If SC5->( MSSeek( cSeek ) )
        cSeek := SC5->( C5_FILIAL + C5_NUM )

        SC6->( DbSetOrder( 12 ) )   //C6_FILIAL+C6_NUM+C6_PRODUTO+C6_SOLCOM
        for nX := 1 to Len( aItems )
            jItem := aItems[ nX ]
                        
            cIntegId := jItem['itemIntegrationId']
            cIntegId := IIF(Empty(cIntegId), jItem['integrationId'],cIntegId)
                   
            aIntegId := StrTokArr2( cIntegId, '|' )
            cProduct := PadR( AllTrim( aIntegId[ 3 ] ), nSizeProd )

            If SC6->( MSSeek( cSeek + cProduct ) )
                jItem["quantity"]    := SC6->C6_QTDVEN
                jItem["baseValue"]   := SC6->C6_PRCVEN
                jItem["value"]       := SC6->C6_PRCVEN
                jItem["totalAmount"] := SC6->C6_VALOR
            EndIf            
        next nX        
    EndIf    

    aEval( aAreas , {|x| RestArea(x) } )
    FwFreeArray( aAreas )
    FwFreeArray( aIntegId )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGenSaleOrder
Expõe a função SetData(Função que atribui as informações da fatura para uma estrutura de metadata do pedido de venda) para utilização de outros fontes

@param oData         , objeto   , instância da fatura no formato esperado pela função SetData
@param lApprovedQuant, boolean  , indica se deve liberar as quantidades dos itens do pedido durante a criação do pedido de venda.

@return lógico, resultado da chamada de <SetData>
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Function GRRGenSaleOrder( oData, lApprovedQuant )
    Default lApprovedQuant := .F.
    
Return SetData( oData, lApprovedQuant )
