#include "protheus.ch"
#include "GRRI020.ch"

//-------------------------- GRRI020 ------------------------------
// Funções de sincronismo dos Itens ( Produtos ) com a plataforma GRR
//-------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI020
Função que prepara as informações necessárias para a sincronização dos itens ( produtos )
do Protheus com a plataforma GRR.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aBranches, array, vetor com as informações das filiais selecionadas.
@param cFilter, caracter, Condição de filtro para sincronizar registros específicos.
@param lStamp, boolean, considera as informações de Stamp do registro na condição de consulta.
@param lAutomato, boolean, Indica que vai rodar pelo ADVPR.

@return caracter, Retorna os dados de processamento em lote.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI020( oStatus, aBranches, cFilter, lStamp, lAutomato )
    Local aSvAlias := GetArea()
    Local aJsonItems := {}
    Local aParams := {}
    Local cEndpoint := ''
    Local cPath := '/items/many'         // Endereço para envio de produtos em lote
    Local cSource := ''
    Local cResult := ''
    Local cTmpAlias := GetNextAlias()
    Local nPageSize := 20
    Local nPage := 1
    Local nRecStart := 0
    Local nRecFinish := 0
    Local nTotal := 0
    Local lFirst := .T.
    Local jItem := NIL
    Local oQryItem := NIL

    Default oStatus := NIL
    Default aBranches := {}
    Default cFilter := ''
    Default lStamp := .F.
    Default lAutomato := .F.

    //--------------------------------------------------------------
    // Retorna o nome do fonte PRW que fez a chamada da função
    //--------------------------------------------------------------
    cSource := ProcSource( 0 ) 
    cSource := StrTran( cSource, '.PRW', '' )  
    
    If GRRSyncExec( 'items', cSource )
        cEndPoint := GRRURL()

        If Empty( aBranches )
            aBranches := GRRActBranches()
        EndIf
        
        nPageSize := Iif( lAutomato, 2, nPageSize )

        oQryItem := QryItems( @nTotal, aBranches, cFilter, lStamp, lAutomato ) 

        If nTotal > 0
            While lFirst .Or. ( nTotal > nRecFinish )
                aJsonItems := {}
                
                IF lFirst
                    lFirst := .F.
                else
                    nPage++
                EndIf

                nRecStart := ( ( nPage - 1 ) * nPageSize ) + 1
                nRecFinish := ( nRecStart + nPageSize ) - 1

                oQryItem:SetNumeric( 1, nRecStart )
                oQryItem:SetNumeric( 2, nRecFinish )

                MPSysOpenQuery( oQryItem:getFixQuery(), cTmpAlias )

                GRRDebugInfo( { { STR0001, oQryItem:getFixQuery() } } )	//"Query sincroniza itens"

                While ( cTmpAlias )->( !EOF() )
                    jItem := SetJson( cTmpAlias )

                    AAdd( aJsonItems, jItem )

                    ( cTmpAlias )->( DBSkip() )
                End 

                //--------------------------------------------------------------
                // Chama o sincronismo para cada paginação se estiver rodando em lote
                //--------------------------------------------------------------
                iF !Empty( aJsonItems ) 
                    cResult := GRRSyncData( oStatus, aJsonItems, cEndPoint, cPath )
                EndIf

                ( cTmpAlias )->( DBCloseArea() )
            End

            //--------------------------------------------------------------
            // Armazena a informação de execução ao controle de sincronismo
            //--------------------------------------------------------------
            GRRSyncTime( 'items', cSource )
        EndIf
    EndIf
    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aJsonItems )
    FWFreeArray( aParams )
    FreeObj( jItem )
    FreeObj( oQryItem )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma.

@param aData, array, vetor com informações da filial para sincronizar.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( cTmpAlias )
    Local jItem := NIL
    
    jItem := JsonObject():New()

    jItem[ "organizationIntegrationId" ] :=  cEmpAnt + '|' + ( cTmpAlias )->B1_FILIAL
    jItem[ "version" ] :=  1                            
    jItem[ "name" ] :=  EncodeUTF8( Alltrim( ( cTmpAlias )->B1_DESC ) ) 
    jItem[ "reference" ] :=  Alltrim( ( cTmpAlias )->B1_COD )    
    jItem[ "description" ] :=  EncodeUTF8( Alltrim( ( cTmpAlias )->B1_DESC ) )
    jItem[ "typeCalculation" ] :=  '2'                              // 2=PriceByQuantity
    jItem[ "unitMeasurement" ] := ( cTmpAlias )->B1_UM    
    jItem[ "currencyCode" ] :=  GRRISOCurrency( )
    jItem[ "value" ] := ( cTmpAlias )->B1_PRV1

    jItem[ "integrationId" ] := cEmpAnt + '|'+ ( cTmpAlias )->B1_FILIAL + '|' + Alltrim( ( cTmpAlias )->B1_COD )
    jItem[ "isActive" ] := "true"

Return jItem


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} QryItems
Função que prepara o JSON para a sincronização de produtos do Protheus com a plataforma.

@param @nTotal, number, retorna a quantidade total de registros que correspondem 
ao resultado da consulta.
@param aBranches, array, vetor com as informações das filiais selecionadas.
@param cFilter, caracter, Condição de filtro para sincronizar registros específicos.
@param lStamp, boolean, considera as informações de Stamp do registro na condição de consulta.
    Caso o parâmetro seja .T., avalia o conteúdo do STAMP para definir os registros 
    que serão sincronizados. Se for .F., ignora as informações de atualização do registro.
@param lAutomato, boolean, Indica que vai rodar pelo ADVPR.

@return array, lista de items para subir no formato JSON
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function QryItems( nTotal, aBranches, cFilter, lStamp, lAutomato )
    Local oPrepare := NIL
    Local cQuery := ''
    Local cBranchFilter := ''
    Local cLSyncItem := ''
    Local cStamp := ''
    Local cIdentifier := ''
    
    Default nTotal := 0
    Default aBranches := {}
    Default cFilter := ''
    Default lStamp := .F.
    Default lAutomato := .F.

    cBranchFilter := GRRBranchFilter( aBranches, 'SB1' )
    Iif( !Empty( cBranchFilter ), cBranchFilter += " AND ", "" )
    Iif( !Empty( cFilter ), cFilter += " AND ", "" )

    cIdentifier := GRRSysIdentifier( 'items' )

    //--------------------------------------------------------------
    // Considera apenas registros alterados depois da última sincronização
    //--------------------------------------------------------------
    If lAutomato .Or. ( lStamp .And. TCConfig( "GETUSEROWSTAMP" ) == "ON" )
        cLSyncItem := GRRSysValue( cIdentifier + '_' + cEmpAnt )
        iF lAutomato .Or. !Empty( cLSyncItem )
            cStamp := " ( " + GRRTreatStamp( "SB1" ) + " >= '" + cLSyncItem + "'  OR " + GRRTreatStamp( "HRG" ) + " >= '" + cLSyncItem + "' ) AND "

            cStamp := Iif( lAutomato, '', cStamp )
        EndIf
    EndIf

    cQuery := "SELECT <<PAGE_CONTROL>>, B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_PRV1 " + ;
        " FROM " + RetSqlName( "SB1" ) + " SB1 " + ;
        " INNER JOIN " + RetSqlName( "HRG" ) + " HRG " + ;
            " ON HRG_FILIAL = '" + xFilial( "HRG" ) + "' " + ;
                " AND HRG_SRCFIL = B1_FILIAL " + ;
                " AND HRG_ALIAS = 'SB1' " + ;
                " AND HRG_CODE = B1_COD " + ;
                " AND HRG_RECURR = 'T' " + ;
                " AND HRG.D_E_L_E_T_ = ' ' " + ;
        " WHERE " + cBranchFilter + ;       // filiais habilitadas para sincronismo
            cFilter + ;                     // filtros adicionais do usuário ( pode ser útil quando vier pelo REST, por exemplo )
            cStamp + ;                      // condição de sincronismo pelo S_T_A_M_P_
            " SB1.D_E_L_E_T_ = ' '"

    nTotal := GRRQryTRecords( cQuery )

    cQuery := GRRPgControl( cQuery )
    cQuery := ChangeQuery( cQuery )

    oPrepare := FWPreparedStatement():New( cQuery )
Return oPrepare

