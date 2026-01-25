#INCLUDE "TOTVS.CH"
// #INCLUDE "FWMVCDEF.CH"
#INCLUDE "InsightDefs.CH"
#INCLUDE "PINSA040.CH"

//-------------------------- PINSA040 --------------------------------
// Funções para geração do pedido de venda pelo Central de IA
//-------------------------------------------------------------------

#DEFINE A410RESULT   1  // Posição do return do processamento da A410Inclui
#DEFINE SALES_ORDER  2  // Posição do return número do pedido de venda


//-------------------------------------------------------------------
/*/{Protheus.doc} PINSA040
Função de controle de geração do pedido de venda

@param cTmpTable, caracter, Nome da tabela temporária.
@param aControler, array, vetor com as mensagens selecionadas na Central de IA. 
@param cMessage, caracter, Observação do pedido.
@param lForce, boolean, Indica se deve "forçar" uma execução de sucesso quando vir do ADVPR

@return json, objeto com as informações de sucesso ou cancelamento da tela do pedido de venda.
@author Marcia Junko 
@since 25/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function PINSA040( cTmpTable, aControler, cMessage, lForce )
    Local aArea := GetArea()
    Local aAreaSC6 := SC6->( GetArea() )
    Local aCustomer := {}
    Local aItens := {}
    Local aReturn := {}
    Local cAlias := ''
    Local cStatus := ''
    Local cDescription := ''
    Local cProduct := ''
    Local nSizeProduct := 0
    Local nSizeSale := 0
    Local nSizeFilial  := 0
    Local jSalesOrder
    Local jResult

    Default aControler := {}
    Default cMessage := ''
    Default lForce := .F.

    I21->( DBSetOrder(1) )  //I21_FILIAL+I21_UIDINS
    SC6->( DBSetOrder(2) )  //C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM

    If !Empty( cTmpTable )
        cAlias := SearchTmpAlias( cTmpTable, aControler )

        //Abre a área com a tabela temporária
        dbUseArea( .T., "TOPCONN" ,cTmpTable, cTmpTable, .T., .F. )
    EndIf

    IF !Empty( cAlias )
        nSizeProduct := TamSX3( "C6_PRODUTO" )[ 1 ]
        nSizeSale := TamSX3( "C6_NUM" )[ 1 ]
        nSizeFilial  := FWSizeFilial()

        While ( cAlias )->( !Eof() )
            ( cTmpTable )->( DBGoto( ( cAlias )->ID ) )

            If Empty( aCustomer )
                Aadd( aCustomer, { ( cTmpTable )->BRANCH, ( cTmpTable )->CUSTOMER } )
            Else
                If Ascan( aCustomer, {|x| x[1] != ( cTmpTable )->BRANCH  } ) 
                    cStatus := 'Error'
                    cDescription := STR0001     //'Foram selecionados registros de filiais diferentes para processamento.'
                    Exit
                ElseIf Ascan( aCustomer, {|x| x[1] == ( cTmpTable )->BRANCH  .And. x[2] != ( cTmpTable )->CUSTOMER } ) 
                    cStatus := 'Error'
                    cDescription := STR0002     //'Foram selecionados registros de clientes diferentes para a geração do pedido de venda.'
                    Exit
                EndIf
            EndIf

            If Empty( cStatus )
                Aadd( aItens, { ( cTmpTable )->PRODUCT, ( cTmpTable )->QUANTITY ,( cTmpTable )->POT_VL} )
            EndIf

            ( cAlias )->( DBSkip() )
        EndDo
    
        If Empty( cStatus )
            aReturn := NewSalesOrder( aCustomer, aItens, cMessage, lForce )

            If aReturn[ A410RESULT ] == 1    // Pedido de venda salvo
                jSalesOrder := MakeJsonInfo( 'Success', '', aReturn[ SALES_ORDER ] )


                ( cAlias )->( DBGotop() )

                While ( cAlias )->( !Eof() )
                    ( cTmpTable )->( DBGoto( ( cAlias )->ID ) )

                    aAux := StrTokArr2( ( cTmpTable )->PRODUCT, '|', .T. )
                    cProduct := aAux[ 2 ]

                    If SC6->( MSSeek( xFilial( "SC6" ) + Padr( cProduct, nSizeProduct ) + Padr( aReturn[ SALES_ORDER ], nSizeSale )  ) )
                        UpdateTableData( cTmpTable, ( cAlias )->ID, GENERATED, jSalesOrder )
                    EndIf

                    ( cAlias )->( DBSkip() )
                EndDo
                jResult := MakeJsonInfo( 'Success', '', aReturn[ SALES_ORDER ] ) 
            Else    // Pedido de Venda não gravado ou Cancelado
                jResult := MakeJsonInfo( 'Canceled', STR0003, '' ) //'Rotina de inclusão do pedido de venda foi cancelada pelo usuário.'
            EndIf
        Else
            jResult := MakeJsonInfo( cStatus, cDescription, '' ) 
        EndIf
    EndIf
    If !Empty( cTmpTable )
        ( cAlias )->( dbCloseArea() )
        ( cTmpTable )->( dbCloseArea() )
    EndIf    

    RestArea( aArea )
    RestArea( aAreaSC6 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaSC6 )
    FWFreeArray( aItens )
    FWFreeArray( aCustomer )
    FWFreeArray( aReturn )
Return jResult

//-------------------------------------------------------------------
/*/{Protheus.doc} NewSalesOrder
Função para mostrar a tela de geração do pedido de venda

@param aHeaderInfo, array, Vetor com as informações do cliente para o pedido de venda
@param aColsInfo, array, vetor com as informações de produtos ( itens do pedido de venda )
@param cMessage, caracter, Observação do pedido.
@param lForce, boolean, Indica se deve "forçar" uma execução de sucesso quando vir do ADVPR

@author Marcia Junko 
@since 25/09/2024
/*/
//-------------------------------------------------------------------
Static Function NewSalesOrder( aHeaderInfo, aColsInfo, cMessage, lForce )
    Local aArea     := GetArea()
    Local aAreaSA1  := SA1->( GetArea() )
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSC5  := SC5->( GetArea() )
    Local aAreaSC6  := SC6->( GetArea() )
    Local aAreaSF4  := SF4->( GetArea() )
    Local bField    := {|nCPO| Field( nCPO ) }
    Local nX        := 0
    Local nY        := 0
    Local nMaxFor   := 0
    Local nUsado    := 0
    Local nRet		:= 0
    Local cTesPed	:= ""
    Local cCFOP		:= ""
    Local cItemPed  := "00" //Item do Pedido
    Local cFilBkp	:= cFilAnt
    Local aHeadC6	:= {}
    Local cNewPV := ""
    Local cPayCode := ""
    Local cCodCli := ""
    Local cCodLoj := ""
    Local nI := 0
    Local nSizeCode := 0
    Local nSizeStore := 0
    Local nSizeBranch := 0
    Local nSizeProduct := 0

    Local cBranch := ''
    Local cSalesOrder := ''
    Local cField := ''
    Local aAux := {}
    Local aAux1 := {}

    Local aSC6 := {}

    //Variaveis Utilizadas pela Funcao a410Inclui
    Private aHeader		:= {}
    Private aCols 		:= {}          
    Private aHeadGrade 	:= {}
    Private aColsGrade 	:= {}
    Private n          	:= 1
    Private ALTERA 		:= .T.
    Private INCLUI 		:= .T.
    Private cCadastro 	:= STR0007  //"Pedido de Venda"
    Private aRotina     := {{ STR0005 ,'AxPesqui'  ,0,1},; 	//'Pesquisar'
							{ STR0006,'A410Visual',0,2} } 	//'Visualizar'

    SA1->( dbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA 
    SB1->( dbSetOrder(1) ) //B1_FILIAL+B1_COD
    SF4->( dbSetOrder(1) ) //F4_FILIAL+F4_CODIGO
    SC5->( dbSetOrder(1) ) //C5_FILIAL+C5_NUM

    If !Empty( aHeaderInfo )
        cBranch := aHeaderInfo[ 1 ][ 1 ]
        aAux := StrTokArr2( aHeaderInfo[ 1 ][ 2 ], '|', .T. )

        nSizeBranch := FWSizeFilial()
        nSizeCode := TamSX3( "A1_COD" )[1]
        nSizeStore := TamSX3( "A1_LOJA" )[1]
        nSizeProduct := TamSX3( "C6_PRODUTO" )[ 1 ]

        cCodCli := Padr( aAux[ 2 ], nSizeCode )    
        cCodLoj := Padr( aAux[ 3 ], nSizeStore )    
    EndIf

    //Altera filial
    cFilAnt := Padr( cBranch, nSizeBranch )

    If !Empty( cCodCli ) .And. !Empty( cCodLoj ) 
        If SA1->( MSSeek( FWxFilial( "SA1" ) + cCodCli + cCodLoj ) )
            If Empty( cPayCode )
                cPayCode := IIf( !Empty( SA1->A1_COND ), SA1->A1_COND, Space( TamSx3("C5_CONDPAG")[1]) )
            EndIf

            aHeadC6 := BuildHeader( 'SC6' )
                                
            //Cria as variaveis do Pedido de Venda                                    		
            dbSelectArea( "SC5" )
            
            nMaxFor := FCount()
            
            For nX := 1 To nMaxFor
                M->&( EVAL( bField, nX ) ) := CriaVar( FieldName( nX ), .T. )
            Next nX				
            
            cNewPV := GetSxeNum( "SC5", "C5_NUM" )

            //Atualiza cabecalho do Pedido de Venda
            M->C5_NUM		:= cNewPV				
            M->C5_CLIENTE 	:= cCodCli
            M->C5_LOJACLI 	:= cCodLoj
            M->C5_CLIENT	:= cCodCli
            M->C5_LOJAENT	:= cCodLoj			                     					
            M->C5_CONDPAG 	:= cPayCode
            M->C5_MOEDA   	:= 1
            If SC5->( FieldPos( "C5_COMENT" ) ) > 0
                M->C5_COMENT := cMessage
            EndIf
            
            //Preenche o Acols do Pedido de Venda                                     		
            nUsado := Len( aHeadC6 )

            For nI := 1 to len( aColsInfo )

                aAux := StrTokArr2( aColsInfo[ nI ][ 1 ], '|', .T. )
                If SB1->( MSSeek( FWxFilial( "SB1", PadR( aAux[ 1 ], nSizeBranch ) ) + aAux[ 2 ] ) )
                    cTesPed := Iif( !Empty( SB1->B1_TS ), SB1->B1_TS, MaTESInt( 2, "01", cCodCli, cCodLoj, "C", SB1->B1_COD ) )
                                    								                    
                    If SF4->( MSSeek( xFilial("SF4") + cTesPed ) )
                        cCFOP := SF4->F4_CF
                    EndIf
                    
                    aAdd( aSC6, Array( nUsado + 1) )
                    nY := Len( aSC6 )		
                    aSC6[nY, nUsado + 1] := .F.

                    For nX := 1 To nUsado
                        cField := AllTrim( aHeadC6[nX, 2] )
                        Do Case
                            Case ( cField == "C6_ITEM" )								
                                cItemPed := Soma1(cItemPed)
                                aSC6[nY, nX] := cItemPed
                            Case ( cField == "C6_PRODUTO" )
                                aAux1 := StrTokArr2( aColsInfo[ nI ][ 1 ], '|', .T. )
                                cProduct := aAux1[ 2 ]
                                aSC6[nY, nX] := PadR( cProduct, nSizeProduct )
                            Case ( cField == "C6_UM" )
                                aSC6[nY, nX] := SB1->B1_UM
                            Case ( cField == "C6_QTDVEN" )
                                aSC6[nY, nX] := aColsInfo[ nI ][ 2 ]
                            Case ( cField == "C6_PRCVEN" )
                                aSC6[nY, nX] := aColsInfo[ nI ][ 3 ]      
                            Case ( cField == "C6_VALOR" )    
                                aSC6[nY,nX] := aColsInfo[ nI ][ 2 ] * aColsInfo[ nI ][ 3 ]
                            Case ( cField == "C6_TES" )
                                aSC6[nY, nX] := cTesPed	
                            Case ( cField == "C6_CF" )
                                aSC6[nY, nX] := cCfop																																					
                            Case ( cField == "C6_DESCRI" )
                                aSC6[nY, nX] := SB1->B1_DESC
                            Case ( cField == "C6_PRUNIT" )
                                aSC6[nY, nX] := SB1->B1_PRV1										
                            OtherWise
                                aSC6[nY, nX] := CriaVar( cField, .T. )
                        EndCase					
                    Next nX
                EndIf
            Next							
        
            //Se Pedido de Venda Manual, abre tela para Inclusao
            If Len( aSC6 ) > 0		
                BEGIN TRANSACTION
                    aCols   := aClone( aSC6 )
                    aHeader := aClone( aHeadC6 )															
                            
                    For nX := 1 To Len( aCols )
                        MatGrdMont( nX )
                    Next nX
                    
                    Pergunte( "MTA410", .F. )		 

                    If !Isblind()                                                                                            
                        nRet := SC5->( a410Inclui( "SC5", SC5->( RECNO() ), 3, .T. ) )
                    Else
                        // Se for automação volta o controle de numeração do pedido.
                        RollbackSx8()
                        DisarmTransaction()	
                    EndIf

                    If nRet == 1 .Or. lForce
                        iF nRet == 1
                            cCadastro 	:= STR0008
                            SC5->( a410Visual( "SC5", SC5->( Recno() ), 2 ) )
                        EndIf

                        nRet := 1
                        cSalesOrder := SC5->C5_NUM
                    EndIf
                 END TRANSACTION
            EndIf	
        EndIf
    EndIf

    //Restaura filial
    cFilAnt := cFilBkp
                                    
    //Restaura a entrada da rotina                                    
    RestArea( aAreaSA1 )
    RestArea( aAreaSB1 )
    RestArea( aAreaSC5 )
    RestArea( aAreaSC6 )
    RestArea( aAreaSF4 )
    RestArea( aArea )
    
    FWFreeArray( aAreaSA1 )
    FWFreeArray( aAreaSB1 )
    FWFreeArray( aAreaSC5 )
    FWFreeArray( aAreaSC6 )
    FWFreeArray( aAreaSF4 )
    FWFreeArray( aArea )
    FWFreeArray( aAux )
    FWFreeArray( aAux1 )
    FWFreeArray( aSC6 )
    FWFreeArray( aHeadC6 )
Return { nRet, cSalesOrder }

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildHeader
Função para buscar a estrutura de determinado alias.

@param cAlias, caracter, Nome do alias para montagem da estrutura.

@return array, lista de campos para montagem da estrutura.
@author Marcia Junko 
@since 25/09/2024
/*/
//-------------------------------------------------------------------
Static Function BuildHeader( cAlias )
    Local aArea := GetArea()
    Local aHeader := {}
    Local aFields := {}
    Local cField := ''
    Local cType := ''
    Local cX3_NIVEL := ''
    Local cX3_USADO := ''
    Local nI := 0

    // Busca campos no dicionario de dados	
    aFields := FWSX3Util():GetAllFields( cAlias , .T. )
    for nI := 1 to len( aFields )
        cField := aFields[ nI ]
        cType := GetSx3Cache( cField, "X3_TIPO" )
        cX3_NIVEL := GetSx3Cache( aFields[ nI ], "X3_NIVEL" )
        cX3_USADO := GetSx3Cache( aFields[ nI ], "X3_USADO" )
        if cNivel >= cX3_NIVEL .and. X3Uso( cX3_USADO ) 
            AADD( aHeader,{ TRIM( FWx3Titulo( cField ) ),;
                cField,;
                GetSx3Cache( cField, "X3_PICTURE" ),;
                GetSx3Cache( cField, "X3_TAMANHO" ),;
                GetSx3Cache( cField, "X3_DECIMAL" ),;
                GetSx3Cache( cField, "X3_VALID" ),;
                cX3_USADO,;
                cType,;
                GetSx3Cache( cField, "X3_F3" ),;
                GetSx3Cache( cField, "X3_CONTEXT" )})
        Endif
    next    

    RestArea( aArea )

    FWFreeArray( aArea )
    FWFreeArray( aFields )
Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} SearchTmpAlias
Função para mostrar a tela de geração do pedido de venda

@param cTmpTable, caracter, Nome da tabela temporária.
@param aControler, array, vetor com as mensagens selecionadas na Central de IA. 

@return caracter, Alias da consulta a tabela temporária.
@author Marcia Junko 
@since 25/09/2024
/*/
//-------------------------------------------------------------------
Static Function SearchTmpAlias( cTmpTable, aControler )
    Local cQuery := ''
    Local cAlias := ''
    Local oQuery

    cQuery := 'SELECT R_E_C_N_O_ ID FROM ? WHERE CTRL_NUMB IN ( ? ) '
    cQuery := ChangeQuery( cQuery )
    oQuery := FwExecStatement():New( cQuery )

    oQuery:setUnsafe( 1, cTmpTable )
    oQuery:setIn( 2, aControler )

    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

    FreeObj( oQuery )   
Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} MakeJsonInfo
Função para montar o json de envio de atualização do processamento para
o front.

@param cStatus, caracter, Indica o status de processamento.
@param cMessage, caracter, Indica a mensagem de processamento.
@param cSalesOrder, caracter, Indica o número do pedido de venda gerado.

@return json, Objeto com as informações para envio ao front.
@author Marcia Junko 
@since 25/09/2024
/*/
//-------------------------------------------------------------------
Static Function MakeJsonInfo( cStatus, cMessage, cSalesOrder )
	Local jResult

	jResult := JsonObject():new()

	jResult[ 'status' ]   := cStatus
	jResult[ 'message' ]  := cMessage
	jResult[ 'userCode' ] := __cUserID
	jResult[ 'userName' ] := FwGetUserName( __cUserID )

	If !Empty( cSalesOrder )
		jResult[ 'orderNumber' ] := cSalesOrder
		jResult[ 'createdDate' ] := dDataBase
	Else
		jResult[ 'discardDate' ] := dDataBase
	EndIf
Return jResult

//-------------------------------------------------------------------
/*/{Protheus.doc} PINS040UpdTable
Função de atualiza as informações do insight como discarte.

@param cTmpTable, caracter, Nome da tabela temporária.
@param aControler, array, vetor com as mensagens selecionadas na Central de IA. 
@param cMessage, caracter, Observação do pedido.
@param nOpc, numeric, Opção de DISCARD ou RESTORE / 0 = Restore / 1 = Discard

@return json, Objeto com as informações para envio ao front.
@author Marcia Junko 
@since 25/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function PINS040UpdTable( cTmpTable, aControler, cMessage, nOpc )
	Local aArea   := GetArea()
	Local cAlias  := ''
	Local cStatus := ''
	Local lOpen   := .F.
	Local jResult

	Default aControler := {}
	Default cMessage   := ''
	Default nOpc       := 0

	If nOpc == 1
		cStatus := DISCARD
	EndIf

	If !Empty( cTmpTable )
		cAlias := SearchTmpAlias( cTmpTable, aControler )

		//Abre a área com a tabela temporária
		If Select(cTmpTable) == 0
			dbUseArea( .T., "TOPCONN" ,cTmpTable, cTmpTable, .T., .F. )
			lOpen := .T.
		EndIf
	EndIf

	IF !Empty( cAlias )

        jResult := MakeJsonInfo( 'Success', cMessage )

		While ( cAlias )->( !Eof() )
			UpdateTableData( cTmpTable, ( cAlias )->ID, cStatus, jResult )

			( cAlias )->( DBSkip() )
		EndDo
	EndIf
	//Fecha área temporária com Recnos filtradas a partir da query
	( cAlias )->( dbCloseArea() )

	//Fecha área da tabela temporária caso tenha sido aberta no DBUSEAREA nessa função
	If lOpen
		( cTmpTable )->( dbCloseArea() )
	EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
Return jResult


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateTableData
Função de atualiza as informações do insight nas tabelas I21 e temporária

@param cTmpTable, caracter, Nome da tabela temporária.
@param nId, number, Recno para posicionar na tabela temporária.
@param cStatus, caracter, Status de atualização do registro
@param jResult, object, Objeto para salvar no campo result da tabela I21 e tabela temporária.

@author Marcia Junko 
@since 29/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UpdateTableData( cTmpTable, nID, cStatus, jResult )
	Local aArea := GetArea()

	I21->( DBSetOrder(1) )  //I21_FILIAL+I21_UIDINS

	( cTmpTable )->( DBGoto( nID ) )

	RecLock( cTmpTable, .F. )
	( cTmpTable )->MSG_STATUS := cStatus
	( cTmpTable )->MSG_RESULT := jResult:tojson()

	If cStatus == "GEN"
		( cTmpTable )->ORDER_NUMB := jResult[ 'orderNumber' ]
		( cTmpTable )->DT_CREATE := DToC( jResult[ 'createdDate' ] )
		( cTmpTable )->USER_GEN := jResult[ 'userName' ]
	ElseIF cStatus == "DSC"
		( cTmpTable )->DT_DISCARD := DToC( jResult[ 'discardDate' ] )
		( cTmpTable )->USER_DSC := jResult[ 'userName' ]
	EndIf     

	( cTmpTable )->( MSUnlock() )

	If I21->( MSSeek( xFilial( 'I21' ) + ( cTmpTable )->CTRL_NUMB ) )
		RecLock( 'I21', .F. )
		I21->I21_STATUS := cStatus
		I21->I21_RESULT := jResult:tojson()
		I21->( MSUnlock() )
	EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
Return
