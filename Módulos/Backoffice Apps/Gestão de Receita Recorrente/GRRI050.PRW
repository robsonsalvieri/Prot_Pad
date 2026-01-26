#include "protheus.ch"
#include "GRRXDefs.ch"
#Include 'FWMVCDef.ch'
#include 'GRRI050.ch'

//---------------------------------- GRRI050 ----------------------------------------
// Funções de sincronização dos pedidos de venda do Protheus com a plataforma GRR ( subscrição ).
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI050
Função que prepara as informações necessárias para a sincronização dos pedidos do
Protheus com a plataforma GRR.

@param aInfo, array, Vetor com as informações do pedido a sincronizar, sendo:
    [1] = filial
    [2] = número do pedido
@param lMsg, boolean, Indica se a mensagem da requisição será mostrada ao usuário.
@param cAction, caracter, indica qual a ação será feita na plataforma.

@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI050( aInfo, lMsg, cAction )
    Local aSvAlias := GetArea()
    Local aSC5Area := SC5->( GetArea() )
    Local aSE4Area := SE4->( GetArea() )
    Local aHRDArea := HRD->( GetArea() )
    Local aHREArea := HRE->( GetArea() )
    Local cEndpoint := ''
    Local cMsg := ''     
    Local cResult := ''
    Local cIDSubscription := ''
    Local cIntegrationId := ''
    Local cSeek := ''
    Local cPath := '/subscriptions'     
    Local nType := 1
    Local nTamFil := TamSX3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSX3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSX3( "HRH_REQCD" )[1]
    Local jSalesOrder
    Local oResult

    Default aInfo := { }
    Default lMsg := .T.
    Default cAction := 'POST'

    SC5->( DbSetOrder( 1 ) )    // C5_FILIAL+C5_NUM
    SC6->( DbSetOrder( 1 ) )    // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

    SE4->( DbSetOrder( 1 ) )     // E4_FILIAL+E4_CODIGO

    HRD->( DbSetOrder( 1 ) )    // HRD_FILIAL+HRD_CODE
    HRE->( DbSetOrder( 2 ) )    // HRE_FILIAL+HRE_PLAN+HRE_PRDCOD+HRE_FILPRD     
    HRH->( DBSetOrder( 1 ) )    // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

    IF !Empty( aInfo ) .And. len( aInfo ) == 2                                                                                                               
        If SC5->( DBSeek( xFilial("SC5", aInfo[1] ) + aInfo[2] ) )
            If ValidReleaseStock( aInfo ) 
                If SE4->( DBSeek( xFilial("SE4", aInfo[1] ) + SC5->C5_CONDPAG ) ) .And. SE4->E4_PAGGRR
                    cEndPoint := GRRURL()
            
                    cSeek := Padr( xFilial( "SC5" ), nTamFil )
                    cSeek += Padr( "SC5", nTamAlias )
                    cSeek += Padr( SC5->C5_NUM, nTamReq )

                    If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ) ) .And. Empty( HRH->HRH_SUBSID )
                        jSalesOrder := SetJson(  )

                        // ----------------------------------------------------------------------------
                        // Avalia se os dados de cadastro do cliente estão preenchidos, antes de 
                        // enviar a subscrição para a plataforma.
                        // ----------------------------------------------------------------------------
                        IF ( jSalesOrder[ "customer"] <> NIL ) .And. ( !Empty( jSalesOrder[ "customer"]["emails"] ) .And. !Empty( jSalesOrder[ "customer"]["phones"] ) ;
                            .And. !Empty( jSalesOrder[ "customer"]["addresses"] ) )

                            cMsg := I18N( STR0001, { alltrim( aInfo[2] ) } ) //"Pedido #1 enviado com sucesso para a plataforma."
                            
                            cResult := GRRSyncData( NIL, jSalesOrder, cEndPoint, cPath, nType, NIL, @cMsg )

                            If !Empty( cResult )
                                oResult := JSONObject():New() 
                                oResult:FromJSON( cResult )

                                // ----------------------------------------------------------------------------
                                // Salva o guid da subscrição na tabela intermediária de assinatura ( HRH )
                                // ----------------------------------------------------------------------------
                                cIDSubscription := oResult[ "id" ]
                                If !Empty( cIDSubscription )
                                    GRRSetSubscriptionId( { xFilial( "SC5" ), "SC5", SC5->C5_NUM }, cIDSubscription )
                                Else
                                    cMsg := STR0002 //"Não foi possivel validar o processo de envio. Por gentileza tente mais tarde."
                                Endif
                            EndIf
                        Else 
                            cMsg := I18N( STR0003, { Alltrim( SC5->C5_CLIENTE ), Alltrim( SC5->C5_LOJACLI ) } ) //"Existem informações no cadastro do cliente desta assinatura que não foram informadas. Por favor, revise as informações de email, endereço e telefone do cliente: #1 - loja: #2  para prosseguir com o envio deste pedido para a plataforma."
                        EndIf

                        If lMsg 
                            ApMsgAlert( cMsg )
                        EndIf
                    else
                        // -------------------------------------------------------------------
                        // Atualiza o vencimento, os itens( caso tenham sofrido alteração ) 
                        // e muda a situação da fatura para 'Medição completa'
                        // OBS: A atualização da fatura como Medição efetuada só deve ser feita
                        // para pedidos com estoque liberado. Se esta premissa for alterada, 
                        // esta chamada deve ser reavaliada.
                        // -------------------------------------------------------------------		
                        cIntegrationId := cEmpAnt + '|'+ SC5->C5_FILIAL + '|' + Alltrim( SC5->C5_NUM )
                        GRRUpdateBill( cIntegrationId, { SC5->C5_FILIAL, SC5->C5_NUM } )
                    EndIf
                Else
                    ApMsgAlert( STR0004 )   //'O registro selecionado não possui as características necessárias para ser tratado pela plataforma de Gestão de Receita Recorrente.'
                EndIf
            EndIf
        EndIf
    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    SC5->( RestArea( aSC5Area ) )
    SE4->( RestArea( aSE4Area ) )
    HRD->( RestArea( aHRDArea ) )
    HRE->( RestArea( aHREArea ) )

    FWFreeArray( aSvAlias )
    FreeObj( jSalesOrder )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma.

@param aData, array, vetor com informações da filial para sincronizar.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( cTmpAlias )
    Local jData := NIL
    Local cDate := ""
    Local cCreationDate := ""
    Local cSeek := ''
    Local nTamFil := TamSX3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSX3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSX3( "HRH_REQCD" )[1]

    Default cTmpAlias := "SC5"

    HRH->( DbSetOrder( 1 )) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE


    jData := JsonObject():New()

/* TODO
        Precisa das propriedades abaixo pra conseguir integrar os dados
            jItem[ "organizationIntegrationId" ] :=  cEmpAnt + '|' + ( cTmpAlias )->C5_FILIAL
            jItem[ "reference" ] :=  ( cTmpAlias )->C5_NUM
            jItem[ "integrationId" ] := cEmpAnt + '|'+ ( cTmpAlias )->C5_FILIAL + '|' + Alltrim( ( cTmpAlias )->C5_NUM )
*/
    cDate := DTOS( ( cTmpAlias )->C5_EMISSAO )
    cCreationDate := Subs( cDate, 1, 4 ) + '-' + Subs( cDate, 5, 2 ) + '-' + Subs( cDate, 7 )
 
    jData[ "organizationIntegrationId" ] :=  cEmpAnt + '|' + ( cTmpAlias )->C5_FILIAL
    
    // TODO - Não foi definido uma forma de trabalhar com o currency no Protheus, por isso, 
    // por enquanto vou utilizar o currencyId. Caso seja criado mais de um currency ( um para 
    // produção e outro para Sandbox ) para o mesmo tenant, este fluxo deve ser reavaliado.
    jData[ "currencyId" ] := "bbff1352-0256-4ac9-8aaa-df0f619f3d37"
    jData[ "creationDate" ] := cCreationDate    
    jData[ "subscriptionAccession" ] := cCreationDate 
    jData[ "billingCycleStartAt" ] := cCreationDate        
    jData[ "subscriptionStart" ] := cCreationDate
    jData[ "skipFirstMeasurement"] := .t.            

    cSeek := Padr( xFilial( cTmpAlias ), nTamFil )
    cSeek += Padr( cTmpAlias, nTamAlias )
    cSeek += Padr( ( cTmpAlias )->C5_NUM, nTamReq )
    If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ))
        If HRD->( DBSeek( xFilial( "HRD" ) + HRH->HRH_PLANCD ) )
            jData[ "planId" ] := HRD->HRD_PLANID

            // TODO - Pela definição do PO o name deve ser o nome do plano, subentendo que se o Protheus 
            // passar o guide do plano, a plataforma deveria preencher este campo, mas hj não está assim.    
            jData[ "name" ] :=  Alltrim( HRD->HRD_NAME )
            // jData[ "name" ] :=  Alltrim( (cTmpAlias )->C5_NUM )
        EndIf            
    EndIf

    jData[ "reference" ] := ( cTmpAlias )->C5_NUM
    jData[ "origin" ] := "Protheus"
    jData[ "source" ] := "MATA410"
    jData[ "integrationId" ] := cEmpAnt + '|'+ ( cTmpAlias )->C5_FILIAL + '|' + Alltrim( ( cTmpAlias )->C5_NUM )
    jData[ "customer" ] := GRRI040( { xFilial( "SA1", ( cTmpAlias )->C5_FILIAL ), ( cTmpAlias )->C5_CLIENTE, ( cTmpAlias )->C5_LOJACLI } ) 
    jData[ "items" ] := MakeSalesItems( cTmpAlias, ( cTmpAlias )->C5_NUM )
    jData[ "subscriptionPause" ] := {}
    jData[ "metadata" ] := SetOrderMetadata( )

Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeSalesItems
Função que prepara as informações necessárias para a montagem dos itens da subscrição

@param cTmpAlias, caracter, alias do pedido que está sendo verificado.
@param cRequest, cRequest, código da solicitação

@return array, vetor com os itens da subscrição
@author  Marcia Junko
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakeSalesItems( cTmpAlias, cRequest )
    Local aItems := {}
    Local cSeek := ''
    Local nTamFil := TamSX3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSX3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSX3( "HRH_REQCD" )[1]
    Local lItemCust  := SuperGetMV( "MV_GRRICST", .F. , .F. ) 
    Local jItems 
    Local oTaxes as Object
    Local lIsB2B as Logical
    Local nTaxItem as Numeric
    Local nX as Numeric

    lIsB2B  := .F.
    nTaxItem:= 0
    nX      := 0

    HRH->( DbSetOrder( 1 )) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

    // ----------------------------------------------------------------
    // Se informar o plano, os itens devem ser exatamente iguais ao 
    // cadastro de planos x itens
    // ----------------------------------------------------------------
    cSeek := Padr( xFilial( cTmpAlias ), nTamFil )
    cSeek += Padr( cTmpAlias, nTamAlias )
    cSeek += Padr( ( cTmpAlias )->C5_NUM, nTamReq )
    If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ))
        If !Empty( HRH->HRH_PLANCD )

            lIsB2B := (GRRInvGenerate( ( cTmpAlias )->C5_CONDPAG ) == '2')//2=Emite NF no vencimento (B2B)
            If lIsB2B
                oTaxes := GrrTaxes():GetTaxes()
                lIsB2B := ValType(oTaxes) == 'J' .And.;
                          oTaxes:HasProperty('total_impostos') .And.;
                          oTaxes:HasProperty('total_impostos_embutidos')
            EndIf

            If SC6->( DBSeek( xFilial( "SC6" ) + ( cTmpAlias )->C5_NUM ) )
                While SC6->( !Eof() ) .And. SC6->C6_NUM == ( cTmpAlias )->C5_NUM
                    If HRE->( DBSeek( xFilial( "HRE" ) + HRH->HRH_PLANCD + SC6->C6_PRODUTO  ) ) .And. ;
                        (lItemCust .or. (HRE->HRE_QUANT  == SC6->C6_QTDVEN .And. HRE->HRE_BASEVL == SC6->C6_PRCVEN .And. HRE->HRE_TOTAL == SC6->C6_VALOR))  

                            jItems := JsonObject():New()

                            jItems[ "planItemId" ] := HRE->HRE_ITPLID 
                            jItems[ "itemId" ] := HRE->HRE_ITEMID 
                            jItems[ "subscriptionItemPriceRange" ] := {}
                            jItems[ "metadata" ] := SetItemMetadata()   

                            if lItemCust
                                jItems[ "quantity" ] := SC6->C6_QTDVEN 
                                jItems[ "baseValue" ] := SC6->C6_PRCVEN
                            EndIF

                            aAdd( aItems, jItems )
                    EndIf
                
                    SC6->( DBSkip() )
                End

                If lIsB2B .And. Len(aItems) > 0 .And. lItemCust                  
                    nTaxItem := (( oTaxes['total_impostos'] - oTaxes['total_impostos_embutidos'] ) / Len(aItems))

                    for nX := 1 to Len(aItems)                        
                        jItems := aItems[nX]
                        jItems[ "baseValue" ] += (nTaxItem / jItems[ "quantity" ]) //Soma o imposto por item
                    next
                EndIf
            EndIf
        EndIf
    else
        /* TODO - Se não informar o plano, não sei o que faz */
    EndIf

    FreeObj(oTaxes)
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRLibSalesOrder
Função que faz a liberação dos pedidos de venda do bloqueio do GRR.

@param cInfo, caracter, chave do pedido que está sendo verificado.
@param cInvGenerator, caracter, Informa qual o processo será responsavel pela geração
da Nota fiscal no Protheus. De preferência deve considerar a condição de pagamento do registro.

@return boolean, indica se conseguiu gerar a NF.
@author  Rodrigo Soares
@since   04/08/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRLibSalesOrder( cInfo, cInvGenerator )
    Local aSvAlias  := GetArea()
    Local aSC5Area  := SC5->( GetArea() )
    Local aSC9Area  := SC9->( GetArea() )
    Local cTmp      := GetNextAlias()
    Local cSalesOrder := ''
    Local cCustomer := ''
    Local cUnit     := ''
    Local aInfo     := StrTokArr2(cInfo, '|', .T.)
    Local lRet      := .T.
    Local cblock    := ''

    Default cInvGenerator := '1'
    
    cblock := IIF( cInvGenerator == '2', '', '70' )
    
    IF ( cInvGenerator == '2' .AND. !EMPTY( SC5->C5_NOTA ) .AND. !EMPTY( SC5->C5_SERIE ) .AND. ( FindFunction("GRRVldHRI") .AND. !GRRVldHRI() ) )
        
        GRRProcNFS( xFilial( 'SF2' ) + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI  ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA

    Else
        cQuery := "SELECT SC9.R_E_C_N_O_ RECNO FROM " + RetSQLName("SC5") + " C5 " + ;
        "INNER JOIN " + RetSQLName("SC9") + " SC9 " + ;
            "ON C9_FILIAL = C5_FILIAL " + ;
            "AND C9_PEDIDO = C5_NUM " + ;
            "AND C9_NFISCAL = ' ' " + ;
            "AND C9_SERIENF = ' ' " + ;
            "AND C9_BLEST = ' ' " + ;
            "AND C9_BLCRED = '"+ cBlock+ "' " + ;
            "AND SC9.D_E_L_E_T_= ' ' " + ;
        "WHERE C5_FILIAL = '" + aInfo[2]  + "' " + ;
            "AND C5_NUM = '" + aInfo[3]  + "' " + ;
            "AND C5_LIBEROK = 'S' " + ;
            "AND C5.D_E_L_E_T_= ' ' "

        cQuery := ChangeQuery( cQuery )
        MPSysOpenQuery( cQuery, cTmp )

        BEGIN TRANSACTION
            If ( cTmp )->( !Eof() )
                While ( cTmp )->( !Eof() )

                    SC9->( DBGoTo( ( cTmp )->RECNO ) )

                    cSalesOrder := SC9->C9_PEDIDO
                    cCustomer := SC9->C9_CLIENTE
                    cUnit := SC9->C9_LOJA

                    RecLock( 'SC9', .F. )
                        SC9->C9_BLCRED := ""
                    MsUnlock()

                    ( cTmp )->( DBSkip() )
                End

                If Empty( GrrNFSAut( cCustomer, cUnit, cSalesOrder, aInfo[2] ) )
                    LogMsg( "GRRLibSalesOrder", 23, 6, 1, "", "", "GRRLibSalesOrder -> " + I18N( STR0005, { aInfo[2], aInfo[3] } ) ) //"Não foi possível gerar o documento de saída na filial: #1, pedido: #2"
                    lRet := .F.
                EndIf 
            EndIf

            ( cTmp )->( DBCloseArea() )

        END TRANSACTION

    Endif

    SC5->( RestArea( aSC5Area ) )
    SC9->( RestArea( aSC9Area ) )

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSC5Area )
    FWFreeArray( aSC9Area )
    FWFreeArray( aSvAlias )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidReleaseStock
Função que faz a liberação dos pedidos de venda do bloqueio do GRR.

@param aInfo, array, Vetor com as informações do pedido a sincronizar, sendo:
    [1] = filial
    [2] = número do pedido

@return boolean - Validar se existe bloqueio de estoque na SC9.
@author  Rodrigo Soares
@since   04/08/2022
/*/
//-------------------------------------------------------------------------------------
static Function ValidReleaseStock( aInfo )
    Local aSvAlias  := GetArea()
    Local aSC5Area  := SC5->( GetArea() )
    Local aSC9Area  := SC9->( GetArea() )
    Local cTmp      := GetNextAlias()
    Local lRet      := .F.
    Local cInvGenerator := GRRInvGenerate( SC5->C5_CONDPAG )
    Local cblock := IIF( cInvGenerator == '2', '', '70' ) 

    cQuery := "SELECT C9_BLEST FROM " + RetSQLName( "SC5" ) + " C5 " + ;
        "INNER JOIN " + RetSQLName( "SC9" ) + " SC9 " + ;
            "ON C9_FILIAL = C5_FILIAL " + ;
            "AND C9_PEDIDO = C5_NUM " + ;
            "AND C9_BLCRED = '"+ cBlock+ "' " + ;
            "AND C9_NFISCAL = ' ' " + ;
            "AND C9_SERIENF = ' ' " + ;
            "AND SC9.D_E_L_E_T_= ' ' " + ;
        "WHERE C5_FILIAL = '" + aInfo[1]  + "' " + ;
            "AND C5_NUM = '" + aInfo[2]  + "' " + ;
            "AND C5_LIBEROK = 'S' " + ;
            "AND C5.D_E_L_E_T_= ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

    While ( cTmp )->( !Eof() )
        If !Empty( Alltrim( ( cTmp )->C9_BLEST ) )
            lRet := .F.
            Exit
        Else
            lRet := .T.
        EndIf
        
        ( cTmp )->( DBSkip() )
    End

    ( cTmp )->( DBCloseArea() )

    SC5->( RestArea( aSC5Area ) )
    SC9->( RestArea( aSC9Area ) )

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI050ReSend
Função que reenvia um pedido de venda para a plataforma. Esta função é util para tentar
criar os registros de subscrição na plataforma após algum ajuste no cadastro do cliente
ou indisponibilidade dos serviços.

@param aInfo, array, Vetor com as informações do pedido a sincronizar, sendo:
    [1] = alias
    [2] = filial
    [3] = código da requisição

@author  Marcia Junko
@since   15/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRI050ReSend( aInfo )
    Local aSvAlias := GetArea()
    Local nTamFil := TamSX3( "HRH_SRCFIL" )[1]
	Local nTamAlias := TamSX3( "HRH_ALIAS" )[1]
	Local nTamReq := TamSX3( "HRH_REQCD" )[1]
    Local cSeek := ''

    If GRRIsActive()
        If !Empty( aInfo )
            HRH->( DBSetOrder( 1 ) )    // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

            If len( aInfo ) == 3
                cSeek := Padr( aInfo[ 2 ], nTamFil )
                cSeek += Padr( aInfo[ 1 ], nTamAlias )
                cSeek += Padr( aInfo[ 3 ], nTamReq )
            
                If !Empty( cSeek )
                    If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ) ) .And. Empty( HRH->HRH_SUBSID )
                        GRRI050( { aInfo[ 2 ], aInfo[ 3 ] } )
                    EndIf
                EndIf
            EndIf
        EndIf
    Else
        Help(" ",1,"GRRNOACTIVE",,STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007})//Funcionalidade não disponível #Ative a integração com o Gestão de Receita Recorrente para utilizar essa opção.
    EndIf
    
    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSetMetadata
Função que monta o objeto metadata de acordo com a lista de campos passada.

@param aProperties, array, vetor com a lista de campos que fazem parte do metadata.

OBS: Para o correto funcionamento da função é necessário que as tabelas apontadas pelos
campos que vão formar os dados do metadata já estejam posicionados previamente.

@return array, vetor as informações do metadata
@author  Marcia Junko
@since   05/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRSetMetadata( aProperties, nType )
    Local aMetadata := {}
    Local cAuxAlias := ''
    Local cAlias := ''
    Local cField := ''
    Local nI := 0
    Local xValue 
    Local jItem

    Default nType := GRR_SAVE_METADATA

    For nI := 1 to len( aProperties )
        cField := aProperties[ nI ]
        cAuxAlias := GRRAliasXField( cField )
        If AliasinDic( cAuxAlias )
            cAlias := cAuxAlias
            If nType == GRR_SAVE_METADATA
                xValue := EncodeUTF8( cBIStr( ( cAlias )->&( cField ) ) )
            Else
                // Precisa passar manualmente o conteúdo 
                xValue := NIL   
            EndIf
        EndIf

        If xValue == NIL .Or. !Empty( xValue )
            jItem := JsonObject():New()
            jItem[ "alias" ] := cAlias
            jItem[ "name" ] := EncodeUTF8( Alltrim( FWX3Titulo( cField ) ) )
            jItem[ "key" ] :=  Alltrim( cField )
            jItem[ "value" ] :=  xValue

            aAdd( aMetadata, jItem )
        EndIf
    Next

    FWFreeArray( aProperties )
Return aMetadata


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetOrderMetadata
Função que monta o metadata dos itens do pedido de venda.

@return array, vetor as informações do metadata para o pedido de venda.
@author  Marcia Junko
@since   05/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetOrderMetadata( )
    Local aMetadata := {}
    Local aProperties := {}

    aProperties := GetMetaProperties( GRR_SALESORDER, 'SC5' )
    aMetadata := GRRSetMetadata( aProperties )

    FWFreeArray( aProperties )
Return aMetadata

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetItemMetadata
Função que monta o metadata dos itens do pedido de venda.

@return array, vetor as informações do metadata para o item do pedido de venda.
@author  Marcia Junko
@since   05/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetItemMetadata( )
    Local aMetadata := {}
    Local aProperties := {}

    aProperties := GetMetaProperties( GRR_SALESORDER_ITEMS, 'SC6' )
    aMetadata := GRRSetMetadata( aProperties )

    FWFreeArray( aProperties )
Return aMetadata


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMetaProperties
Função que prepara as informações necessárias para a montagem do telefone do cliente.

@param nType, number, Indica de qual metadata se trata, onde: 
    1 = Pedido de Venda
    2 = Itens do pedido

@return array, vetor com o telefone do cliente
@author  Marcia Junko
@since   05/09/2022
/*/
//-------------------------------------------------------------------------------------
Static Function GetMetaProperties( nType, cAlias )
    Local aProperties := {}
    Local aFields := {}
    Local aNoFields := {}
    Local cField := ''
    Local nI := 0

    Default nType := GRR_SALESORDER
    Default cAlias := 'SC5'

    aProperties := GRRMetaFields( nType, .T. )
    aNoFields := GRRMetaFields( nType, .F. )

    aFields := FWSX3Util():GetAllFields( cAlias, .F. )
    For nI := 1 to len( aFields )
        cField := aFields[ nI ] 
        If Ascan( aNoFields, {|x| x == cField }) == 0 .And. Ascan( aProperties, {|x| x == cField }) == 0
            If X3Obrigat( cField )
                Aadd( aProperties, cField )
            EndIf
        EndIf
    Next

    FWFreeArray( aFields )
Return aProperties

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRMetaFields
Função que prepara as informações necessárias para a montagem do telefone do cliente.

@param nType, number, Indica de qual metadata se trata, onde: 
    1 = Pedido de Venda
    2 = Itens do pedido
@param lON, boolean, Se .T., apresenta os campos que farão parte do metadata. 
        Se .F., retorna os campos que devem ser desconsiderados pelo modelo de 
        metadata default.

@return array, vetor com o telefone do cliente
@author  Marcia Junko
@since   05/09/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRMetaFields( nType, lON )
    Local aFields := {}

    Default nType := GRR_SALESORDER
    Default lON := .T.

    Do Case 
        Case nType == GRR_SALESORDER 
            If lON
                aFields := { 'C5_CONDPAG', 'C5_MODANP', 'HRH_PLANCD', 'HRH_PAYMET' }
            Else
                aFields := { 'C5_NUM', 'C5_CLIENTE', 'C5_LOJACLI' }
            EndIf
        Case nType == GRR_SALESORDER_ITEMS
            If lON
                aFields := { 'C6_TES', 'C6_LOCAL', 'C6_QTDLIB' }
            Else
                aFields := { 'C6_PRODUTO', 'C6_ITEM', 'C6_UM', 'C6_QTDVEN', 'C6_PRUNIT', 'C6_PRCVEN', 'C6_VALOR' }
            EndIf
    End

Return aFields

/*/{Protheus.doc} GrrTaxes
    Classe responsável por obter os impostos do pedido(SC5)
@author philipe.pompeu
@since 30/01/2025
/*/
Class GrrTaxes
    Data cAdapter as Char
    Data _oTaxes as Object
    Method New() Constructor
    Method SetJson(lSet, oTaxes)
    Static Method GetTaxes() As Object
EndClass

/*/{Protheus.doc} GetTaxes
    Método construtor
@author philipe.pompeu
@since 30/01/2025
/*/
Method New() Class GrrTaxes
    Self:cAdapter := "MATSIMP"
Return Nil

/*/{Protheus.doc} SetJson
    Método que é chamado pela função <Ma410Impos> e recebe um vetor de posição única contendo um JsonObject com os impostos do pedido(SC5)
@param lSet, lógico, sem uso( apenas para compatibilidade com a função <Ma410Impos> )
@param aTaxes, array, vetor com os impostos do pedido
@author philipe.pompeu
@since 30/01/2025
/*/
Method SetJson(lSet, aTaxes) Class GrrTaxes
    If ValType(aTaxes) == 'A' .And. Len(aTaxes) > 0
        Self:_oTaxes := aTail(aTaxes)
    EndIf
Return Nil

/*/{Protheus.doc} GetTaxes
    Método estático que retorna um json com os impostos do pedido(SC5) corrente.
@return jResult, JsonObject, instância de JsonObject com os impostos
@author philipe.pompeu
@since 30/01/2025
/*/
Method GetTaxes() Class GrrTaxes As Object  
    Local jResult as Object
    Local lLoad as Logical

    lLoad := !(Type("aHeader") == "A" .And. Type("aCols") == "A")
    If lLoad
        Private aHeader := {}
        Private aCols   := {}
        ALTERA   := .F.
		INCLUI   := .F.

        RegToMemory( "SC5" )        
        FillGetDados(2,"SC6",1, SC5->( C5_FILIAL+ C5_NUM )  ,;//chave de busca na SC6(cSeek)
                                {|| C6_FILIAL+C6_NUM }      ,;//condição para seleção dos itens(bWhile)
                                /*uSeekFor*/,;
                                 {"C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2","C6_INFAD"},;//campos que não devem ser inclusos na aCols(aNoFields)
                                /*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.F.)
    EndIf
    
    Pergunte( "MTA410", .F. )

    Private oApiManager := GrrTaxes():New()

    Ma410Impos(3, .T.,{})//A função espera que exista um objeto com o nome <oApiManager> e que ele tenha um método <SetJson>

    If ValType(oApiManager:_oTaxes) == 'J'
        jResult := JsonObject():New()
        jResult:FromJSON(oApiManager:_oTaxes:ToJSON())
    EndIf

    FreeObj(oApiManager)
Return jResult
