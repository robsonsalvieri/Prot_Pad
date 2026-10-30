#include "protheus.ch"
#include "GRRXDefs.ch"

//-------------------------------- GRRI060 --------------------------------------------
// Funções que tratam as faturas da plataforma GRR para realizar liberação dos 
// pedidos no Protheus
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI060
Função que prepara as informações necessárias para a liberação dos pedidos no Protheus, 
após analisar se a fatura relacionada a um determinado pedido já foi paga e prosseguir
com o fluxo de emissão da NF pelo Protheus.

@author  Marcia Junko
@since   03/08/2022
/*/
//-------------------------------------------------------------------------------------

Function GRRI060( )
    Local aSvAlias := GetArea()
    Local aSteps := {}
    Local cIdentifier := 'bills'
    Local cPath := '/' + cIdentifier + '?status=4'      // 4=Pagamento Feito
    Local nSyncControl := 0
    Local nSyncValue := 0

    nSyncControl := SuperGetMV( "MV_GRRSSOC", .F., 3 )  // SSOC - SYNC SALES ORDERS CONTROL         
    nSyncValue := SuperGetMV( "MV_GRRSSOV", .F., 2 )    // SSOV - SYNC SALES ORDERS VALUE

    aAdd( aSteps, 'SyncFlow( ' + cPath  + ')' )

    GRRSyncFlow( cIdentifier, aSteps, nSyncControl, nSyncValue )     

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FWFreeArray( aSteps )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncFlow
Função que controla o sincronismo dos dados vindos da plataforma

@param cPath, caracter, Endpoint a executar

@author  Marcia Junko
@since   03/08/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SyncFlow( cPath )

    // TODO - A integração vai usar o DesvioFlow até que as condições necessárias 
    // sejam implementadas pela plataforma. Após a disponibilização destas features, 
    // deve-se apagar a função DesvioFlow e o conteúdo da RealFlow deve ser movido 
    // para esta função.
    
    DesvioFlow( cPath )
    // RealFlow()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RealFlow
Fluxo paleativo para a liberação de pedidos

@author  Marcia Junko
@since   03/08/2022
/*/
//-------------------------------------------------------------------------------------
/*
Static Function RealFlow(  )
    Local aSvAlias := GetArea()
    Local cEndpoint := GRRURL()
    Local cQuery := ''
    Local cQryAlias := ''
    Local cPath := ''
    Local cResult := ''
    Local nI := 0
    Local oRest
    Local oResult
    Local oJson
    
    cQuery := "SELECT C9_FILIAL, C9_PEDIDO FROM " + RetSqlName( "SC9" ) + ;
            " WHERE C9_BLCRED = '70' AND D_E_L_E_T_ = ' ' " + ;
            " GROUP BY C9_FILIAL, C9_PEDIDO"
    cQuery := ChangeQuery( cQuery )
    cQryAlias := MPSysOpenQuery( cQuery )

    While ( cQryAlias )->( !Eof() )
        oRest := NIL
        oResult := NIL
        oJson := NIL

        // TODO - Este serviço não está funcionando pois ainda não foi disponibilizada a busca por integrationId
        cPath := '/subscriptions/' + cEmpAnt + '|' + ( cQryAlias )->C9_FILIAL + '|' + ( cQryAlias )->C9_PEDIDO
        cResult := GRRRestExec( 'GET', cEndpoint, cPath, @oRest )

        If !Empty( cResult )
            oResult := JSONObject():New() 
            oResult:FromJSON( cResult )

            // TODO - Rever deste ponto em diante
            aResult := oResult[ 'responseData' ]

            If !Empty( aResult )
                If FWJsonDeserialize( cResult, @oJson)
                    If AttIsMemberOf( oJson, "bills" )
                        For nI := 1 to len( oJson:bills )
                            If oJson:bills[ nI ]:status == 4 
                                // TODO - Chamada da função de liberação de pedidos ( SC9 ) do Rodrigo
                                GRRLibSalesOrder( oJson:integrationId )
                            EndIf
                        Next     
                    EndIf 
                EndIf
            EndIF
        EndIf

        ( cQryAlias )->( DBSkip() )
    End
    ( cQryAlias )->( DBCloseArea() )
    
    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} DesvioFlow
Fluxo paleativo para a liberação de pedidos

@param cPath, caracter, Endpoint a executar

@author  Marcia Junko
@since   03/08/2022
/*/
//-------------------------------------------------------------------------------------
Static Function DesvioFlow( cPath )
    Local aSvAlias := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local aResult := {}
    Local aOrganizations := {}
    Local aIntegration := {}
    Local cEndpoint := GRRURL()
    Local aChaveSC5 := {}
    Local cPage := ''
    Local cResult := ''
    Local cTODOResult := ''
    Local cTODOPath := ''
    Local cTODOOrganization := ''
    Local cBKPFil := ''
    Local cReference := ''
    Local cInvGenerator := '1'

    Local lFirst := .T.
    Local lHasNext := .F.
    Local nI := 0
    Local nPage := 1
    Local oRest
    Local oResult
    Local oJson
    Local oTODORest
    Local oTODOResult

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
                            If !Empty( oJson:responseData[ nI ]:reference )

                                // TODO - Este fluxo está sendo feito até que se possa realizar os filtros na subscription por integrationID.
                                // Quando o filtro estiver disponível, o fluxo vai mudar para query na SC9 com filtro de bloqueio = 70.
                                IF ( nPos := ( Ascan( aOrganizations, {|x, y| x[1] == oJson:responseData[ nI ]:organizationId } ) ) ) == 0
                                    cTODOPath := '/organizations/' + FwUrlEncode( oJson:responseData[ nI ]:organizationIntegrationId )

                                    cTODOResult := GRRRestExec( 'GET', cEndpoint, cTODOPath, @oTODORest )
                                    If !Empty( cTODOResult )
                                        oTODOResult := JSONObject():New() 
                                        oTODOResult:FromJSON( cTODOResult )

                                        cTODOOrganization := oTODOResult[ 'reference' ]
                                        aAdd( aOrganizations, { oTODOResult[ 'id' ], oTODOResult[ 'reference' ] } )
                                    EndIf
                                else
                                    cTODOOrganization := aOrganizations[ nPos ][ 2 ]    
                                EndIf

                                aIntegration := StrTokArr2( cTODOOrganization, '|' )

                                If aIntegration[ INT_COMPANY ] == cEmpAnt
                                    //---------------------------------------------------------
                                    // Atribui a variável do sistema a filial do registro que 
                                    // está sendo processada.
                                    //---------------------------------------------------------
                                    cFilAnt := aIntegration[ INT_BRANCH ]

                                    
                                    //--------------------------------------------------------------
                                    // Caso o pedido de venda tenha sido gerado pelo GCT encontrar 
                                    // primeiro o pedido de venda para seguir com o fluxo.
                                    //--------------------------------------------------------------

                                    IF ( oJson:responseData[ nI ]:source == 'CNTA300' .And. oJson:responseData[ nI ]:cicle == 1 )
                                        aChaveSC5 := GRRGetSalesOrder( oJson:responseData[ nI ]:reference )
                                        If len( aChaveSC5 ) > 0
                                            cReference := aChaveSC5[ 1 ][ 2 ]     
                                        EndIF
                                    else
                                        cReference := oJson:responseData[ nI ]:reference
                                    EndIF

                                    SC5->( dbSetOrder( 1 ) ) //C5_FILIAL+C5_NUM
                                    IF SC5->( MSSEEK( xFIlial( 'SC5' ) + StrTran( cReference, "|", "" ) ) )
                                        cInvGenerator := GRRInvGenerate( SC5->C5_CONDPAG ) 

                                        //--------------------------------------------------------------
                                        // Libera o pedido de venda do bloqueio GRR
                                        //--------------------------------------------------------------
                                        GRRLibSalesOrder( cTODOOrganization + '|' + cReference,  cInvGenerator )

                                        // ----------------------------------------------------------------------------
                                        // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                                        // ----------------------------------------------------------------------------
                                        GRRSetBillId( { xFilial( "SC5" ), "SC5", cReference }, oJson:responseData[ nI ]:id )
                                    EndIf
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

    RestArea( aSvAlias )
    RestArea( aAreaSC5 )
    
    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSC5 )
    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetSalesOrder
Função que vai buscar os pedidos de venda referente ao processo iniciado pelo GCT.

@param cReference, string, Chave para encontrar o registro na tabela CNA.

@return array, Array com a chave dos pedidos de venda encontradoas
    [1] Filial
    [2] Numero do pedido.
@author  Rodrigo G Soares
@since   06/02/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRGetSalesOrder( cReference )
    Local aSvAlias := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local aAreaCNA := CNA->( GetArea() )
    Local aAreaCND := CND->( GetArea() )
    Local aChaveSC5 := {}
    Local cQuery        := ""
    Local cTmp          := GetNextAlias()

    CNA->( DbSetOrder(1) )    //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
    IF CNA->( MSSeek( xFilial( "CNA" ) + cReference ) )
        cQuery := " SELECT SC5.C5_FILIAL, SC5.C5_NUM " + ; 
            " FROM " + RetSqlName( "SC5" ) + " SC5 " + ;
            " INNER JOIN " + RetSqlName( "CNA" ) + " CNA " + ;
                " ON SC5.C5_MDCONTR = CNA.CNA_CONTRA " + ;
                " AND SC5.C5_MDPLANI = CNA.CNA_NUMERO " + ; 
                " AND SC5.C5_FILIAL = CNA.CNA_FILIAL " + ;  
                " AND CNA.D_E_L_E_T_ = ' ' " + ;
            " INNER JOIN " + RetSqlName( "CND" ) + " CND " + ;
                " ON CND.CND_CONTRA = CNA.CNA_CONTRA " + ;
                " AND CND.CND_NUMMED = SC5.C5_MDNUMED " + ;  
                " AND CND.CND_FILIAL = SC5.C5_FILIAL " + ;  
                " AND CND.D_E_L_E_T_ = ' ' " + ;
            " WHERE SC5.C5_FILIAL = '" + xFilial( "SC5" ) + "' " + ;     
                " AND SC5.C5_MDCONTR = '"+ CNA->CNA_CONTRA + "' " + ;
                " AND SC5.C5_MDPLANI = '"+ CNA->CNA_NUMERO + "' " + ;
                " AND SC5.D_E_L_E_T_ = ' ' " + ;    
            " ORDER BY " + SqlOrder( SC5->( IndexKey() ) )

        cQuery := ChangeQuery( cQuery )
        MPSysOpenQuery( cQuery, cTmp )

        While ( cTmp )->( !Eof() )
            AADD( aChaveSC5,{ ( cTmp )->C5_FILIAL, ( cTmp )->C5_NUM } )
            ( cTmp )->( dbSkip() )  
        EndDo
        ( cTmp )->( DbCloseArea() )
    ENDIF

    RestArea( aSvAlias )
    RestArea( aAreaSC5 )
    RestArea( aAreaCNA )
    RestArea( aAreaCND )

    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSC5 )
    FWFreeArray( aAreaCNA )
    FWFreeArray( aAreaCND )
Return aChaveSC5
