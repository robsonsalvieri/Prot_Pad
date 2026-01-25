#include "protheus.ch"
#include "GRRXDefs.ch"
#Include 'FWMVCDef.ch'
#include 'GRRI050A.ch'

#DEFINE SIZE_AINFO      6
    #DEFINE POS_BRANCH      1
    #DEFINE POS_CONTRACT    2
    #DEFINE POS_REVISION    3
    #DEFINE POS_SPREADSHEET 4
    #DEFINE POS_MEASUREMENT 5
    #DEFINE POS_DOCUMENT    6

#DEFINE SIZE_SHEETINFO 10
    #DEFINE POS_SHEETINFO_BRANCH            1
    #DEFINE POS_SHEETINFO_CONTRACT          2
    #DEFINE POS_SHEETINFO_SPREADSHEET       3
    #DEFINE POS_SHEETINFO_REVISION          4
    #DEFINE POS_SHEETINFO_BRANCHCODE        5
    #DEFINE POS_SHEETINFO_CLIENT            6
    #DEFINE POS_SHEETINFO_STORE             7
    #DEFINE POS_SHEETINFO_PLAN              8
    #DEFINE POS_SHEETINFO_PAYMENT           9
    #DEFINE POS_SHEETINFO_SPREADSHEET_ID    10

//---------------------------------- GRRI050A ----------------------------------------
// Funções de sincronização dos contratos do GCT com a plataforma GRR ( subscrição ).
//-----------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRI050A
Função que prepara as informações necessárias para a sincronização dos contratos do GCT
com a plataforma GRR.

@param aInfo, array, Vetor com as informações do contrato a sincronizar, sendo:
    [1] = filial
    [2] = número do contrato
    [3] = número da revisão
    [4] = número da planilha
    [5] = número da medição
    [6] = identificador do documento(SC5 ou SE1)

@param lMsg, boolean, Indica se a mensagem da requisição será mostrada ao usuário.
@param cAction, caracter, indica qual a ação será feita na plataforma.

@return lRet, lógico, Indica se o processo terminou corretamente.

@author  Rodrigo G Soares
@since   01/02/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRI050A( aInfo, lMsg, cAction )
    Local aSvAlias          := GetArea()
    Local aCNAArea          := CNA->( GetArea() )
    Local aCNBArea          := CNB->( GetArea() )
    Local aHRDArea          := HRD->( GetArea() )
    Local aHREArea          := HRE->( GetArea() )
    Local nTamRevi          := GetSx3Cache("CNA_REVISA" , "X3_TAMANHO")
    Local nTamContra        := GetSx3Cache("CNA_CONTRA" , "X3_TAMANHO")
    Local nTamPlan          := GetSx3Cache("CNA_NUMERO" , "X3_TAMANHO")
    Local nTamFil           := GetSx3Cache("HRH_SRCFIL" , "X3_TAMANHO")
	Local nTamAlias         := GetSx3Cache("HRH_ALIAS"  , "X3_TAMANHO")
    Local cBillId           := ''
    Local cIntegrationId    := ''
    Local cTmpAlias         := "CNA"
    Local nCicle            := 0
    Local nRecNoE1          := 0
    Local lRet              := .F.
    Local aReference        := {}
    Local aItens            := {}
    Local aPedido           := {}
    Local jSalesOrder


    Default aInfo := { }
    Default lMsg := .T.
    Default cAction := 'SC5'

    CNA->( DbSetOrder( 1 ) )    // CN9_FILIAL+CN9_NUMERO+CN9_REVISA                                                                                                                                
    CNB->( DbSetOrder( 1 ) )    // CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM                                                                                                            

    HRD->( DbSetOrder( 1 ) )    // HRD_FILIAL+HRD_CODE
    HRE->( DbSetOrder( 2 ) )    // HRE_FILIAL+HRE_PLAN+HRE_PRDCOD+HRE_FILPRD     
    HRH->( DBSetOrder( 1 ) )    // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

    IF !Empty( aInfo ) .And. len( aInfo ) == SIZE_AINFO

        //Garante o tamanho correto dos campos
        aInfo[ POS_CONTRACT ]   := PadR(aInfo[ POS_CONTRACT ]   , nTamContra)
        aInfo[ POS_REVISION ]   := PadR(aInfo[ POS_REVISION ]   , nTamRevi)
        aInfo[ POS_SPREADSHEET ]:= PadR(aInfo[ POS_SPREADSHEET ], nTamPlan)
        
        IF EMPTY( aInfo[POS_MEASUREMENT] ) //Sem número da medição, gera subscrições
            
            aItens := LoadSheetInfo( aInfo[POS_CONTRACT], aInfo[POS_REVISION] )//Carrega os dados do contrato e gera os registros na HRH

            Processa( {|| ProcessSubscription( aItens, lMsg, @lRet ) }, STR0001 )   //"Enviando a subscrição para plataforma"        
        Else
            cReference          := aInfo[ POS_CONTRACT ] + aInfo[ POS_REVISION ] + aInfo[ POS_SPREADSHEET ]
            cIntegrationId      := GenIntegId({cEmpAnt , xFilial('CNA') , aInfo[ POS_CONTRACT ] , aInfo[ POS_REVISION ] , aInfo[ POS_SPREADSHEET ]})

            cSeek := Padr( aInfo[1], nTamFil )
		    cSeek += Padr( cTmpAlias, nTamAlias )
		    cSeek += GenIntegId({aInfo[ POS_CONTRACT ] , aInfo[ POS_REVISION ] , aInfo[ POS_SPREADSHEET ]})            
            
            If HRH->( MsSeek( xFilial( "HRH" ) + cSeek ))

                If cAction == 'SC5'
                    aPedido := GRRGetSalesOrder( cReference )                    
                    
                    // ----------------------------------------------------------------------------
                    // Cria o Registro na HRH 
                    // ----------------------------------------------------------------------------
                    GRRA050( { xFilial( "SC5" ), "SC5", "MATA410",  SC5->C5_NUM, xFilial( "HRD" ), HRH->HRH_PLANCD, '' , HRH->HRH_SUBSID } )
                    
                    // ----------------------------------------------------------------------------
                    // Busca a próxima bill na plataforma
                    // ----------------------------------------------------------------------------

                    for nCicle := 1 to Len( aPedido )
                        if aScan( aPedido[ nCicle ], aInfo[ POS_DOCUMENT ] ) > 0
                            EXIT
                        EndIf
                    next
            
                    cBillId := GRRGetNextBill( cIntegrationId, nCicle, GRR_BILL_STATUS_CREATED )    // 1=Criada

                    IF !EMPTY( cBillId )
                        // ----------------------------------------------------------------------------
                        // Busca a próxima bill na plataforma
                        // ----------------------------------------------------------------------------  
                        cIntegrationId  := cEmpAnt + '|'+ aInfo[ 1 ] + '|' + Alltrim( aInfo[ 6 ] )

                        aAdd( aReference, { 'integrationId', cIntegrationId } )
                        aAdd( aReference, { 'reference', aInfo[ POS_DOCUMENT ] } )

                        // ----------------------------------------------------------------------------
                        // Atribui os dados de integração do Protheus nas faturas ( bills ) 
                        // ----------------------------------------------------------------------------
                        IF GRRBillReferences( cBillId, aReference )

                            // ----------------------------------------------------------------------------
                            // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                            // ----------------------------------------------------------------------------
                            GRRSetBillId( { xFilial( "SC5" ), "SC5", aInfo[ POS_DOCUMENT ] }, cBillId )

                            // ----------------------------------------------------------------------------
                            // Atualiza o vencimento, os itens( caso tenham sofrido alteração ) e muda a 
                            // situação da fatura para 'Medição completa'
                            // ----------------------------------------------------------------------------
                            lRet := GRRUpdateBill( cIntegrationId, aPedido[ nCicle ], GRR_BILL_STATUS_AWAITINGPAYMENT ) 
                        EndIF
                    EndIf
                ElseIf cAction == 'SE1'

                    nRecNoE1 := aInfo[ POS_DOCUMENT ]

                    If ValType(nRecNoE1) == 'N' .And. nRecNoE1 > 0
                        SE1->(DbGoTo(nRecNoE1))

                        // ----------------------------------------------------------------------------
                        // Cria o Registro na HRH 
                        // ----------------------------------------------------------------------------
                        GRRA050( { SE1->E1_FILIAL, "SE1", "FINA040",  SE1->(GenIntegId({E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO})), xFilial( "HRD" ), HRH->HRH_PLANCD, '' , HRH->HRH_SUBSID } )
                        
                        cBillId := GRRGetNextBill( cIntegrationId, 0, GRR_BILL_STATUS_CREATED, {|x| x:status == GRR_BILL_STATUS_CREATED .And. Left(x:dueDate, 7) == dateFormat( SE1->E1_VENCTO, "yyyy-mm" ) } )

                        IF !EMPTY( cBillId )
                            // ----------------------------------------------------------------------------
                            // Busca a próxima bill na plataforma
                            // ----------------------------------------------------------------------------                            
                            cIntegrationId  := SE1->(GenIntegId({cEmpAnt,E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO}))

                            aAdd( aReference, { 'integrationId', cIntegrationId } )                            
                            aAdd( aReference, { 'reference', SE1->(GenIntegId({E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO})) } )                     

                            // ----------------------------------------------------------------------------
                            // Atribui os dados de integração do Protheus nas faturas ( bills ) 
                            // ----------------------------------------------------------------------------
                            IF GRRBillReferences( cBillId, aReference )
                                // ----------------------------------------------------------------------------
                                // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                                // ----------------------------------------------------------------------------                                
                                GRRSetBillId( SE1->({ E1_FILIAL, "SE1", GenIntegId({E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO}) }), cBillId )                                

                                If lRet := GRRSetDueDate( cIntegrationId , SE1->({ E1_FILIAL, RecNo() }), {|x|  dateFormat( SE1->E1_VENCREA, "yyyy-mm-dd" ) } )
                                    
                                    If SuperGetMV( "MV_GRRICST", .F. , .F. ) 
                                        //---------------------------------------------------------
                                        // Atualiza os itens caso tenha tido alguma mudança nas quantidades/valor unitário            
                                        //---------------------------------------------------------
                                        lRet := GRRUpdateItems( cIntegrationId, SE1->({ E1_FILIAL, E1_NUM }), {|x,y| GRRUpdItCNE(x, y) }) 
                                    EndIf

                                    If lRet                                        
                                        lRet := GRRBillStatus( cIntegrationId , GRR_BILL_STATUS_AWAITINGPAYMENT)// Muda a situação da fatura para Aguardando Pagamento
                                    EndIf
                                EndIf
                                    
                            EndIF
                        EndIf
                    EndIf
                EndIf                                

                IF !lRet
                    Aviso( "GRRI050A", STR0002, { "Ok" } )  //"Não foi possivel encontrar o registro correspondente na plataforma GRR"
                    DisarmTransaction()
                EndIf
            EndIf
        EndIf

    EndIf

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    CNA->( RestArea( aCNAArea ) )
    CNB->( RestArea( aCNBArea ) )
    HRD->( RestArea( aHRDArea ) )
    HRE->( RestArea( aHREArea ) )

    FWFreeArray( aSvAlias )
    FWFreeArray( aReference )
    FWFreeArray( aItens )
    FWFreeArray( aPedido )
    FreeObj( jSalesOrder )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para a sincronização das empresas\filiais
do Protheus com a plataforma.

@param aItem, array, vetor com informações do Contrato para geração do JSON.

@return json, componente com as propriedades no formato JSON para envio à plataforma.
@author  Rodrigo G Soares
@since   05/05/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( aItem )
    Local aAreas:= {CNA->(GetArea()), CN9->(GetArea()), GetArea()}
    Local jData := NIL
    Local cCreationDate := ""
    Local cBillingStart := ""
    Local cName := "" 
    Local dCreation := dDataBase

    HRH->( DbSetOrder( 1 )) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE
    
    CNA->(DbGoTo( aItem[POS_SHEETINFO_SPREADSHEET_ID] ))

    CN9->(DbSetOrder(1))//CN9_FILIAL+CN9_NUMERO+CN9_REVISA
    If CN9->(DbSeek(CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA)))
        dCreation := CN9->CN9_DTREV
        If Empty(dCreation)
            dCreation := CNA->CNA_DTINI
        EndIf

        jData := JsonObject():New()
        
        jData[ "organizationIntegrationId" ] :=  GenIntegId({cEmpAnt, aItem[POS_SHEETINFO_BRANCHCODE] })

        // TODO - Não foi definido uma forma de trabalhar com o currency no Protheus, por isso, 
        // por enquanto vou utilizar o currencyId. Caso seja criado mais de um currency ( um para 
        // produção e outro para Sandbox ) para o mesmo tenant, este fluxo deve ser reavaliado.
        jData[ "currencyId" ] := "bbff1352-0256-4ac9-8aaa-df0f619f3d37"
        
        cCreationDate := dateFormat( dCreation, "yyyy-mm-dd" )
        cBillingStart := BillingDtCNA()

        jData[ "creationDate" ]         := cCreationDate    
        jData[ "subscriptionAccession" ]:= cCreationDate 
        jData[ "billingCycleStartAt" ]  := cBillingStart        
        jData[ "subscriptionStart" ]    := cBillingStart

        //Periodicidade
        jData[ "chargeEach"]:= 1 //Cobrar a cada 1
        jData[ "period"]:= 2 //2=Mês
        jData[ "numberOfTimes"]:= 0 //Quantidade de cobranças

        jData[ "chargeType"]:= 2
        jData[ "specificDay"]:= 0
        jData[ "quantityDay"]:= 0
        jData[ "referenceDay"]:= 2
        jData[ "referencePeriod"]:= 1
        jData[ "subscriptionPause" ] := {}

        cName := I18N(IIF(Empty(AllTrim(CNA->CNA_REVISA)), STR0006, STR0007),  CNA->({CNA_CONTRA, CNA_NUMERO, CNA_REVISA}) )//'Contrato #1 / Planilha #2 / Revisão #3'
        jData[ "name" ]     := EncodeUTF8(cName)
        jData[ "origin" ]   := "Protheus"
        jData[ "source" ]   := "CNTA300"
        jData[ "reference" ] := CNA->(GenIntegId({ CNA_CONTRA, CNA_REVISA, CNA_NUMERO }))    
        jData[ "integrationId" ] := CNA->(GenIntegId({ cEmpAnt,  CNA_FILIAL, CNA_CONTRA, CNA_REVISA, CNA_NUMERO }))
        jData[ "customer" ] := GRRI040( { xFilial( "SA1", aItem[POS_SHEETINFO_BRANCHCODE] ), aItem[POS_SHEETINFO_CLIENT] , aItem[POS_SHEETINFO_STORE]  } )
        jData[ "items" ]    := CNA->(MakeItems( CNA_CONTRA, CNA_REVISA, CNA_NUMERO, jData))
        jData[ "metadata" ] := GRRSetMetadata({'CNA_CONTRA','CNA_REVISA','CNA_NUMERO','CNA_CRONOG','CN9_FILCTR'})    
    EndIf

    aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadSheetInfo
Função que pega as planilhas do contrato do GCT e faz o vinculo com a tabela HRH.

@param cContract, string, numero do contrato do GCT para dados das planilhas.

@return aItems, array, Informações das Planilhas do Contrato em questão.

O Array é camposto pelo seguintes itens:
 1 - Filial
 2 - Numero do contrato
 3 - Numero da planilha
 4 - Numero da revisão
 5 - Data da Assinatura
 6 - Codigo do cliente
 7 - Loja do cliente
 8 - Cógio do plano GRR
 9 - Códiog da condição de pagamento.

@author  Rodrigo G Soares
@since   01/02/2023
/*/
//-------------------------------------------------------------------------------------
static Function LoadSheetInfo( cContract, cRevision )
    Local aListOfItems	:= {}
    Local aItem         := Array(SIZE_SHEETINFO)
    Local cQuery        := ""
    Local cTmp          := ""
    Local oQueryCNA     := Nil

    cQuery :=   " SELECT CNA.CNA_FILIAL, CNA.CNA_CONTRA, CNA.CNA_NUMERO, CNA.CNA_REVISA, CN9.CN9_PLAGRR," + ; 
                " CN9.CN9_DTASSI, CNA.CNA_CLIENT, CNA.CNA_LOJACL, CN9.CN9_PLAGRR, CN9.CN9_CONDPG, CN9_FILCTR,CNA.R_E_C_N_O_ RECNOCNA  " + ; 
                " FROM " + RetSqlName( "CNA" ) + " CNA " + ;
                " INNER JOIN " + RetSqlName( "CN9" ) + " CN9 ON ( CN9.CN9_NUMERO = CNA.CNA_CONTRA AND CN9.CN9_FILIAL = CNA.CNA_FILIAL AND CN9.D_E_L_E_T_ = ' ') " + ;
                " WHERE   CNA.CNA_FILIAL = ? " + ;     
                    " AND CNA.CNA_CONTRA = ? " + ;
                    " AND CNA.CNA_REVISA = ? " + ;
                    " AND CNA.CNA_SALDO > ? " + ;
                    " AND CNA.D_E_L_E_T_ = ? " + ;    
                " ORDER BY " + SqlOrder( CNA->( IndexKey() ) )

    cQuery := ChangeQuery( cQuery )
    oQueryCNA := FWPreparedStatement():New(cQuery) 
	oQueryCNA:SetString(1, xFilial('CNA'))
	oQueryCNA:SetString(2, cContract )
	oQueryCNA:SetString(3, cRevision )
	oQueryCNA:SetNumeric(4, 0 )
	oQueryCNA:SetString(5, Space(1) )

    cTmp := MPSysOpenQuery( oQueryCNA:getFixQuery() )

    While !( cTmp )->( Eof() )        
        aItem[POS_SHEETINFO_BRANCH]         := ( cTmp )->CNA_FILIAL
        aItem[POS_SHEETINFO_CONTRACT]       := ( cTmp )->CNA_CONTRA
        aItem[POS_SHEETINFO_SPREADSHEET]    := ( cTmp )->CNA_NUMERO
        aItem[POS_SHEETINFO_REVISION]       := ( cTmp )->CNA_REVISA
        aItem[POS_SHEETINFO_BRANCHCODE]     := ( cTmp )->CN9_FILCTR
        aItem[POS_SHEETINFO_CLIENT]         := ( cTmp )->CNA_CLIENT
        aItem[POS_SHEETINFO_STORE]          := ( cTmp )->CNA_LOJACL
        aItem[POS_SHEETINFO_PLAN]           := ( cTmp )->CN9_PLAGRR
        aItem[POS_SHEETINFO_PAYMENT]        := ( cTmp )->CN9_CONDPG
        aItem[POS_SHEETINFO_SPREADSHEET_ID] := ( cTmp )->RECNOCNA        
        
        aAdd( aListOfItems, aClone(aItem))

        GRRA050( { xFilial( "CNA" ), "CNA", "CNTA300",  (cTmp)->(GenIntegId({CNA_CONTRA, CNA_REVISA, CNA_NUMERO})), xFilial( "HRD" ), ( cTmp )->CN9_PLAGRR, '' } )
        
        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    FreeObj(oQueryCNA)
return aListOfItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeItems
Função que pega as planilhas do contrato do GCT e faz o vinculo com a tabela HRH.

@param cContract, string, numero do contrato do GCT para dados das planilhas.
@param cReview, string, numero da revisão do GCT para dados das planilhas.
@param cNumber, string, numero do planilha do contrato do GCT para dados das planilhas.

@return aItems, array, vetor as informações dos itens da subscrição.

@author  Rodrigo G Soares
@since   01/02/2023
/*/
//-------------------------------------------------------------------------------------
static Function MakeItems( cContract, cReview, cNumber, jSubscription)
    Local aAreas	 := {CN9->(GetArea()), CNA->(GetArea()), CNB->(GetArea()),GetArea()}
    Local aItems := {}
    Local cSeek := ''
    Local nTamFil   := GetSx3Cache("HRH_SRCFIL" , "X3_TAMANHO")  
	Local nTamAlias := GetSx3Cache("HRH_ALIAS"  , "X3_TAMANHO")  
	Local nTamReq   := GetSx3Cache("HRH_REQCD"  , "X3_TAMANHO")  
    Local nDecVlTot := GetSx3Cache("CNB_VLTOT"  , "X3_DECIMAL")    
    Local jItems 
    Local nQuantity := 0
    Local nBaseValue:= 0
    Local nTotalAmount:= 0
    Local lRecurring:= .F.
    Local lHasCrong := .F.
    Local nNumberOfTimes := 0
    Local nParcelQuantity:= 0

    HRH->( DbSetOrder( 1 )) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE
    cSeek := Padr( xFilial( 'CNA' ), nTamFil )
    cSeek += Padr( 'CNA', nTamAlias )        
    cSeek += Padr( GenIntegId({cContract , cReview , cNumber}), nTamReq )
    If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ))
        CN9->(DbSetOrder(1))
        CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO        
        cSeek := xFilial( "CNB" ) + (cContract + cReview + cNumber)
        If  CNB->( DBSeek( cSeek ) ) .And.;
            CN9->(DbSeek(CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA))) .And.;
            CNA->(DbSeek(CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO)))
            
            lRecurring	:= Cn300RetSt("RECORRENTE"	,0,CNA->CNA_NUMERO,,,.F.)

            If !Empty(CNA->CNA_CRONOG)
                CNF->(DbSetOrder(2))//CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_COMPET                
                If (lHasCrong := CNF->(DbSeek( CNA->(CNA_FILIAL + CNA_CONTRA + CNA_REVISA + CNA_CRONOG) )))
                    If (nParcelQuantity := QtdParcCNF()) > 1
                        While CNF->(!Eof() .And. CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO == CNA->(CNA_FILIAL + CNA_CONTRA + CNA_REVISA + CNA_CRONOG) )
                            If CNF->CNF_VLREAL == 0 //Posiciona na primeira parcela que não tenha sido medida para usar como 'base' pra função Cn121QtdIt
                                Exit
                            EndIf
                            CNF->(DbSkip())
                        EndDo
                    EndIf

                EndIf
            EndIf

            if (lRecurring .Or. lHasCrong)                
                While CNB->( !Eof() .And. CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO == cSeek )

                    If lRecurring .Or. (lHasCrong .And. CNB->CNB_SLDMED > 0)
                        
                        jItems := JsonObject():New()                

                        jItems[ "integrationId" ]   := GenIntegId({cEmpAnt, xFilial("SB1", CN9->CN9_FILCTR), CNB->CNB_PRODUT})
                        
                        jItems[ "reference" ]       := CNB->(AllTrim(CNB_PRODUT))
                        jItems[ "description" ]     := I18N("#1 - #2", CNB->({AllTrim(CNB_PRODUT), EncodeUTF8(AllTrim(CNB_DESCRI)) }))
                        jItems[ "itemName" ]        := jItems[ "description" ]
                        jItems[ "unitMeasurement" ] := CNB->CNB_UM
                        jItems[ "currencyCode" ]    := "BRL"
                        jItems[ "paymentType" ]     := "1"
                        
                        jItems[ "subscriptionItemPriceRange" ] := {}
                        jItems[ "metadata" ] := GRRSetMetadata({'CNB_CONTRA','CNB_REVISA', 'CNB_NUMERO', 'CNB_ITEM'})
                        
                        If lRecurring
                            nQuantity := CNB->CNB_QUANT
                            nBaseValue:= CNB->CNB_VLTOT
                            nTotalAmount:=nBaseValue
                            jItems[ "quantityCicles" ] := CNA->CNA_QTDREC
                        Else                    
                            jItems[ "typeCalculation" ] := "2" //2=preço x quantidade
                            nQuantity := Cn121QtdIt(CNB->CNB_SLDMED,CNA->CNA_SALDO,CNF->CNF_SALDO,.F.,lHasCrong)
                            nBaseValue  := CNB->CNB_VLUNIT
                            nTotalAmount:= Round((nBaseValue * nQuantity), nDecVlTot)
                            jItems[ "quantityCicles" ] := nParcelQuantity
                        Endif

                        jItems[ "quantity" ]    := Max(1,Int(nQuantity))//O GRR só aceita valores inteiros.
                        jItems[ "baseValue" ]   := nBaseValue
                        jItems[ "totalAmount" ] := nTotalAmount
                        jItems[ "value" ]       := jItems[ "totalAmount" ]                    

                        aAdd( aItems, jItems )
                        
                        nNumberOfTimes := Max(jItems[ "quantityCicles" ],nNumberOfTimes)
                    EndIf

                    CNB->( DBSkip() )
                End
            endif
        EndIf
        
    EndIf

    if nNumberOfTimes > 0 .And. ValType(jSubscription) == "J"
        jSubscription["numberOfTimes"] := nNumberOfTimes
    endif

    aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessSubscription
Função que monta o metadata dos itens do pedido de venda.

@param aItems, array, Informações das Planilhas do Contrato em questão.
@param lMsg, boolean, Indica se a mensagem da requisição será mostrada ao usuário.

@return lRet, lógico, Indica se o processo terminou corretamente.

@author  Rodrigo G Soares
@since   06/02/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ProcessSubscription(aItens, lMsg, lRet)
    Local nTotal          := len( aItens )
    Local nI              := 0
    Local cMsg            := ''     
    Local cResult         := ''
    Local cIDSubscription := ''
    Local cSeek           := ''
    Local cPath           := '/subscriptions'     
    Local nType           := 1
    Local nTamFil         := GetSx3Cache( "HRH_SRCFIL"  , "X3_TAMANHO")
	Local nTamAlias       := GetSx3Cache( "HRH_ALIAS"   , "X3_TAMANHO")
	Local nTamReq         := GetSx3Cache( "HRH_REQCD"   , "X3_TAMANHO")
    Local nTamContra      := GetSx3Cache( "CNA_CONTRA"  , "X3_TAMANHO")
    Local nTamRevi        := GetSx3Cache( "CNA_REVISA"  , "X3_TAMANHO")
    Local nTamPlan        := GetSx3Cache( "CNA_NUMERO"  , "X3_TAMANHO")

    Local cEndpoint       := ''
    Local cContra         := ""
    Local cRevision       := ""
    Local cSpreadSheet    := ""
    Local oResult
    Local lCustomer := .F.
    Local lItems    := .F.

    Default lMsg := .T.

    cEndPoint := GRRURL()
    
    ProcRegua(nTotal)

    For nI := 1 to nTotal

        IncProc( I18N( STR0005, { cValToChar( nI ), cValToChar( nTotal ) } ) )    //"Enviando subscrição #1 de #2..."

        cContra     := PadR(aItens[nI][POS_SHEETINFO_CONTRACT]    , nTamContra)
        cRevision   := PadR(aItens[nI][POS_SHEETINFO_REVISION]    , nTamRevi)
        cSpreadSheet:= PadR(aItens[nI][POS_SHEETINFO_SPREADSHEET] , nTamPlan)                

        cSeek := Padr( xFilial( "CNA" ), nTamFil )
        cSeek += Padr( "CNA", nTamAlias )
        cSeek += Padr( GenIntegId({cContra, cRevision, cSpreadSheet}), nTamReq )

        If HRH->( DBSeek( xFilial( "HRH" ) + cSeek ) ) .And. Empty( HRH->HRH_SUBSID )
            jSalesOrder := SetJson( aItens[nI] )

            // ----------------------------------------------------------------------------
            // Avalia se os dados de cadastro do cliente estão preenchidos, antes de 
            // enviar a subscrição para a plataforma.
            // ----------------------------------------------------------------------------
            lCustomer :=    ( jSalesOrder[ "customer"] <> NIL ) .And.;
                            ( !Empty( jSalesOrder[ "customer"]["emails"] ) .And. !Empty( jSalesOrder[ "customer"]["phones"] ) .And. !Empty( jSalesOrder[ "customer"]["addresses"] ) )
            
            lItems  :=  ( jSalesOrder[ "items"] <> NIL .And. Len(jSalesOrder[ "items"]) > 0)//Valida a existência de produtos

            IF  lCustomer .And. lItems         

                cMsg := I18N( STR0003, { alltrim( cContra + cRevision + cSpreadSheet ) } )   //"Contrato #1 enviado com sucesso para a plataforma."
                
                cResult := GRRSyncData( NIL, jSalesOrder, cEndPoint, cPath, nType, NIL, @cMsg )

                If !Empty( cResult )
                    oResult := JSONObject():New() 
                    oResult:FromJSON( cResult )

                    // ----------------------------------------------------------------------------
                    // Salva o guid da subscrição na tabela intermediária de assinatura ( HRH )
                    // ----------------------------------------------------------------------------
                    cIDSubscription := oResult[ "id" ]
                    If !Empty( cIDSubscription )
                        GRRSetSubscriptionId( { xFilial( "CNA" ), "CNA", GenIntegId({cContra, cRevision, cSpreadSheet}) }, cIDSubscription )
                        lRet := .T.
                    Endif
                EndIf
            Else 
                cMsg := I18N( STR0004, { Alltrim( aItens[nI][6] ), Alltrim( aItens[nI][7] ) } )     //"Existem informações no cadastro do cliente desta assinatura que não foram informadas. Por favor, revise as informações de email, endereço e telefone do cliente: #1 - loja: #2 para prosseguir com o envio deste contrato para a plataforma."
            EndIf

            If lMsg 
                ApMsgAlert( cMsg )
            EndIf
        EndIf
    Next
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetNextBill
Função que vai buscar o ID da ultima bill gerada com status aguardando medição..

@param cSubsIntegrationID, string, Id da subscrição que irá procurar.
@param nCicle   , numérico, ciclo da recorrência a ser considerada na filtragem do resultado
@param nStatus  , numérico, situação da fatura a ser considerada na filtragem do resultado
@param bFilter  , code-block, permite filtrar a lista de faturas(bills) com a estratégia desejada
@return string, Id da fatura que foi procurada.
@author  Rodrigo G Soares
@since   06/02/2023
/*/
//-------------------------------------------------------------------------------------
function GRRGetNextBill(cSubsIntegrationID, nCicle, nStatus , bFilter)
    Local cEndpoint := GRRURL()
    Local cPath := '/subscriptions/' +  FwUrlEncode( cSubsIntegrationID )
    Local cBillId := ''
    Local nI := 0
    Local oRest
    Local oResult
    Local oJson

	Default nStatus := GRR_BILL_STATUS_AWAITINGMEASUREMENT      // 2=Aguardando Medição
    Default bFilter := Nil

    cResult := GRRRestExec( 'GET', cEndpoint, cPath, @oRest )

    If !Empty( cResult )
        oResult := JSONObject():New() 
        oResult:FromJSON( cResult )

        If FWJsonDeserialize( cResult, @oJson)
            If AttIsMemberOf( oJson, "bills" )
                For nI := 1 to len( oJson:bills )
                    IF  (bFilter == Nil .And. oJson:bills[ nI ]:status == nStatus .And. Empty( oJson:bills[ nI ]:integrationId ) .And. oJson:bills[ nI ]:cicle == nCicle) .Or.;
                        ( ValType(bFilter) == 'B' .And. Eval(bFilter, oJson:bills[ nI ] ) )
                        cBillId := oJson:bills[ nI ]:id
                    EndIF
                NEXT
            ENDIF
        ENDIF
    ENDIF

    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return cBillId

/*/{Protheus.doc} QtdParcCNF
    Quantidade de parcelas restantes.
@return nQuantity, numérico, parcelas em aberto(saldo > 0)
@author philipe.pompeu
@since 27/11/2024
/*/
Static Function QtdParcCNF()
    Local nQuantity  	:= 0
    Local cQuery        := ""
    Local cTmp          := ""
    Local oQueryCNF     := Nil

    cQuery :=   " SELECT COUNT(CNF_PARCEL) QTDPARCEL " + ;
                " FROM " + RetSqlName( "CNF" ) + " CNF " + ;                
                " WHERE   CNF.CNF_FILIAL = ? " + ;     
                    " AND CNF.CNF_CONTRA = ? " + ;
                    " AND CNF.CNF_REVISA = ? " + ;
                    " AND CNF.CNF_NUMPLA = ? " + ;
                    " AND CNF.CNF_SALDO > ? " + ;    
                    " AND CNF.D_E_L_E_T_ = ? "
    cQuery := ChangeQuery( cQuery )
    oQueryCNF := FWPreparedStatement():New(cQuery) 

    //Busca dados da parcela posicionada
	oQueryCNF:SetString(1, CNF->CNF_FILIAL)
	oQueryCNF:SetString(2, CNF->CNF_CONTRA)
	oQueryCNF:SetString(3, CNF->CNF_REVISA)
	oQueryCNF:SetString(4, CNF->CNF_NUMPLA)
	oQueryCNF:setNumeric(5, 0)	
	oQueryCNF:SetString(6, Space(1) )

    cTmp := MPSysOpenQuery( oQueryCNF:getFixQuery() )

    If ( cTmp )->( !Eof() )
        nQuantity := ( cTmp )->QTDPARCEL
    EndIf
    
    ( cTmp )->( DbCloseArea() )

    FreeObj(oQueryCNF)

Return nQuantity

/*/{Protheus.doc} GRRSndE1MD
    Envia os títulos à receber gerados pela medição pra plataforma
@author philipe.pompeu
@since 28/11/2024
/*/
Function GRRSndE1MD()
    Local lResult   := .F.
    Local cQuery    := ""
    Local cTmp      := ""
    Local oQuery    := Nil
    Local aInfo     := Array(6, "")

    If IsGRRPayment(CND->CND_CONDPG)

        cQuery :=   " SELECT DISTINCT CXJ_NUMPLA, CXJ_NUMTIT, E1_PARCELA, E1_PREFIXO, E1_TIPO, SE1.R_E_C_N_O_ RECE1 FROM " + RetSqlName( "CXJ" ) + " CXJ " + ;
                    " INNER JOIN "+ RetSqlName( "SE1" ) +" SE1 ON(E1_MDCONTR = CXJ_CONTRA AND E1_MEDNUME = CXJ_NUMMED AND E1_MDPLANI = CXJ_NUMPLA AND E1_NUM = CXJ_NUMTIT AND SE1.D_E_L_E_T_ = CXJ.D_E_L_E_T_) " + ;
                    " WHERE  " + ;            
                    "     CXJ.CXJ_FILIAL = ? " + ;
                    " AND CXJ.CXJ_CONTRA = ? " + ;
                    " AND CXJ.CXJ_NUMMED = ? " + ;
                    " AND CXJ.D_E_L_E_T_ = ? " + ;
                    " ORDER BY CXJ_NUMPLA, CXJ_NUMTIT, E1_PARCELA "    
        cQuery := ChangeQuery( cQuery )
        oQuery := FWPreparedStatement():New(cQuery) 

        //Busca dados da medição posicionada
        oQuery:SetString(1, CND->CND_FILIAL)
        oQuery:SetString(2, CND->CND_CONTRA)
        oQuery:SetString(3, CND->CND_NUMMED)        
        oQuery:SetString(4, Space(1) )

        cTmp := MPSysOpenQuery( oQuery:getFixQuery() )

        While (cTmp)->( !Eof() )              

            aInfo[POS_BRANCH]       := xFilial("CN9", CND->CND_FILCTR)
            aInfo[POS_CONTRACT]     := CND->CND_CONTRA
            aInfo[POS_REVISION]     := CND->CND_REVISA
            aInfo[POS_SPREADSHEET]  := (cTmp)->CXJ_NUMPLA
            aInfo[POS_MEASUREMENT]  := CND->CND_NUMMED
            aInfo[POS_DOCUMENT]     := (cTmp)->RECE1            
            
            If !(lResult :=  GRRI050A( aInfo , .T., 'SE1')) //Processa os títulos e os envia pra plataforma
                Exit
            EndIf

            (cTmp)->( DbSkip() )
        EndDo

        ( cTmp )->( DbCloseArea() )
    Endif    

    FwFreeArray(aInfo)
    FreeObj(oQuery)
Return

/*/{Protheus.doc} GenIntegId
    Gera um integrationId com base em <aFields>, concatenando todas as posições separados por pipe(|)
@param aFields, vetor, lista de valores a serem concatenados
@return cResult, caractere, resultado da concatenação de <aFields>
@author philipe.pompeu
@since 03/12/2024
/*/
Static Function GenIntegId(aFields)
    Local cResult   := ""
    Local nSize     := Len(aFields)
    Local nPos      := 0   
    
    For nPos := 1 To nSize
        cResult += aFields[nPos]
        If nPos < nSize
            cResult += "|"
        EndIf
    Next
    FwFreeArray(aFields)
Return cResult

/*/{Protheus.doc} GRRUpdItCNE
    Atualiza os itens da fatura com base nos produtos da medição(CNE)
@param aDocument    , vetor, dados do título(filial e numero)
@param aOrigItems   , vetor, itens originais da fatura(conforme retornado pela plataforma)
@return aItems, vetor, itens atualizados(quantidade e valor unitário)
@author philipe.pompeu
@since 03/12/2024
/*/
Function GRRUpdItCNE( aDocument, aOrigItems )
    Local aAreas    := { CNE->( GetArea() ), SE1->( GetArea() ), GetArea() }    
    Local aItems    := aOrigItems    
    Local nX        := 0
    Local nY        := 0    
    Local jItem    
    Local jProperty := Nil
    Local cSeek     := ""  
    Local nQuantity := 0
    Local nBaseValue:= 0
    Local nDecimal	:= GetSx3Cache("CNE_VLUNIT","X3_DECIMAL")

    CNE->(DbSetOrder(1))//CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM 
    for nX := 1 to Len( aItems )
        jItem := aItems[ nX ]

        If jItem:HasProperty('metadata')
            for nY := 1 to Len(jItem['metadata'])
                jProperty := jItem['metadata'][nY]
                If  (jProperty["alias"] == "CNB" .And. jProperty["key"] == "CNB_ITEM")

                    cSeek := xFilial("CNE") + SE1->(E1_MDCONTR + E1_MDREVIS + E1_MDPLANI + E1_MEDNUME ) + jProperty["value"]
                    If CNE->(DbSeek(cSeek))
                        nQuantity := CNE->( Max(1,Int(CNE_QUANT)) ) //Pega apenas a parte inteira, pois o GRR só aceita inteiros
                        nBaseValue:= CNE->( Round(CNE_VLTOT / nQuantity, nDecimal) )//Por conta da divergência na quantidade entre GCTxGRR, é necessário recalcular o valor unitário ao invés de usar o CNE_VLUNIT
                        jItem["quantity"]    := nQuantity
                        jItem["baseValue"]   := nBaseValue
                        jItem["value"]       := nBaseValue
                        jItem["totalAmount"] := CNE->CNE_VLTOT                      
                    EndIf
                    
                    Exit
                EndIf
            next nY            
        EndIf
    next nX    

    aEval( aAreas , {|x| RestArea(x) } )
    FwFreeArray( aAreas )    
Return aItems

/*/{Protheus.doc} GRRDelHRH
    Remove os registros da HRH referentes ao contrato informado, caso existam subscrições associadas elas são canceladas.
@param cContract, caractere, número do contrato
@param cRevision, caractere, revisão do contrato
@author philipe.pompeu
@since 27/11/2024
/*/
Function GRRDelHRH(cContract, cRevision)
    Local aAreas := {CNA->(GetArea()), GetArea()}
    Local cKeyHRH := ""
    Local cKeyCNA := ""

    CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
    cKeyCNA := xFilial("CNA") + cContract + cRevision
    If CNA->(DbSeek(cKeyCNA)) 
        HRH->( DBSetOrder( 1 ) )    // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE
        cKeyHRH := xFilial("HRH") + CNA->CNA_FILIAL + "CNA"

        While CNA->(!Eof() .And. CNA_FILIAL+CNA_CONTRA+CNA_REVISA == cKeyCNA)
            If HRH->(DbSeek(cKeyHRH + CNA->(GenIntegId( { CNA_CONTRA, CNA_REVISA, CNA_NUMERO } )) ))
                If  HRH->(!Empty(HRH_SUBSID))
                    GRRCancelSubscription(HRH->HRH_SUBSID)
                EndIf
                RecLock('HRH', .F.)
                HRH->(DbDelete())

                HRH->(MsUnLock())
            EndIf
            CNA->(DbSkip())
        EndDo
    EndIf
    
    aEval(aAreas, {|x|RestArea(x)})
    FwFreeArray(aAreas)
Return

/*/{Protheus.doc} GRRCancelSubscription
    Realiza o cancelamento de determinada subscrição
@param cSubscriptionID, caractere, identificador da subscrição 
@return lResult, lógico, se o cancelamento ocorreu com sucesso.
@author philipe.pompeu
@since 27/11/2024
/*/
Function GRRCancelSubscription(cSubscriptionID)
    Local cEndpoint := GRRURL()
    Local cPath := '/subscriptions/cancelation'
    Local oRest
    Local oResult
    Local oJson	
    Local lResult := .F.

    oJson := JSONObject():New() 

    oJson["id"] := cSubscriptionID
    oJson["cancellationDate"] := dateFormat( dDataBase, "yyyy-mm-dd" )

    cResult := GRRRestExec( 'PUT', cEndpoint, cPath, @oRest, oJson)
    lResult := !Empty( cResult )
    
    If GRRInDebug()
        GRRDebugInfo( { {'GRRCancelSubscription',;
                        I18N('subscription #1 #2', {cSubscriptionID, IIF(lResult, 'CANCELLED','FAILED')})};
                      } )
    EndIf

    FreeObj( oRest )
    FreeObj( oResult )
    FreeObj( oJson )
Return lResult

/*/{Protheus.doc} BillingDtCNA
    Retorna a data da primeira cobrança da planilha(CNA) do contrato.
@return cBillingStart, caractere, data da primeira cobrança no formato yyyy-mm-dd
@author philipe.pompeu
@since 26/12/2024
/*/
Static Function BillingDtCNA()
    Local cBillingStart := ''
    Local dStart        := Date()    
    Local cQuery        := ""
    Local cTmp          := ""
    Local oQueryCNF     := Nil

    If CNA->CNA_QTDREC > 0 //Recorrente
        dStart := CNA->CNA_PROMED
    ElseIf !Empty(CNA->CNA_CRONOG)//Fixo com Cronograma Financeiro
        cQuery :=   " SELECT MIN(CNF_DTVENC) MINVENC " + ;
                    " FROM " + RetSqlName( "CNF" ) + " CNF " + ;                
                    " WHERE   CNF.CNF_FILIAL = ? " + ;     
                        " AND CNF.CNF_CONTRA = ? " + ;
                        " AND CNF.CNF_REVISA = ? " + ;
                        " AND CNF.CNF_NUMPLA = ? " + ;
                        " AND CNF.CNF_SALDO > ? " + ;    
                        " AND CNF.D_E_L_E_T_ = ? "
        cQuery := ChangeQuery( cQuery )
        oQueryCNF := FWPreparedStatement():New(cQuery) 

        //Busca dados da parcela posicionada
        oQueryCNF:SetString(1, CNA->CNA_FILIAL)
        oQueryCNF:SetString(2, CNA->CNA_CONTRA)
        oQueryCNF:SetString(3, CNA->CNA_REVISA)
        oQueryCNF:SetString(4, CNA->CNA_NUMERO)        
        oQueryCNF:setNumeric(5, 0)	
        oQueryCNF:SetString(6, Space(1) )

        cTmp := MPSysOpenQuery( oQueryCNF:getFixQuery() )

        If ( cTmp )->( !Eof() )            
            dStart :=  SToD( (cTmp)->MINVENC )
        EndIf        
        ( cTmp )->( DbCloseArea() )

        FreeObj(oQueryCNF)
    EndIf
    
    cBillingStart := dateFormat( dStart, "yyyy-mm-dd" )
Return cBillingStart
