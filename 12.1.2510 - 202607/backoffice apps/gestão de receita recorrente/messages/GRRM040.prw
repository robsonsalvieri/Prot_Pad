#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BillAwaitingPaymentCreatedMessageReader
	Classe responsável pela leitura das mensagens do tipo BillAwaitingPaymentCreated
    Link: https://tdn.totvs.com/display/public/framework/FwTotvsLinkClient
@author philipe.pompeu
@since 23/07/2024
/*/
//-------------------------------------------------------------------------------------
Class BillAwaitingPaymentCreatedMessageReader from LongNameClass

    Data aOrigCompany As Array
    Data aPropObg As Array
    Data aCheckEnv As Array
    Data bSetEnv as CodeBlock
    Data cMessageType as charactere
	Method New()
	Method Read(oLinkMessage)
    Method IsMsgValid(oMessage)
    Method IsEnvPrepared()
    Method PrepareEnv(cOrgIntgId)
    Method ProcessMessage(oMessage)
    Method GetDueDate(cDueDate)
    Private Method newProcessMessage(oLinkMessage as object) as logical
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
	Método construtor da classe
@author philipe.pompeu
@since 23/07/2024
/*/
//-------------------------------------------------------------------------------------
Method New() Class BillAwaitingPaymentCreatedMessageReader

    ::aOrigCompany  := { cEmpAnt, cFilAnt }
    ::bSetEnv       := {|cCompany, cBranch| RpcClearEnv(), GRRConnCompany( cCompany, cBranch ) }
    ::cMessageType  := "BillAwaitingPaymentCreated"

    ::aPropObg  := {'organizationIntegrationId' ,;
                    'billIntegrationId'         ,;
                    'source'                    ,;
                    'cycle'                     ,;                        
                    'dueDate'                   ,;                        
                    'billId'                    }
    ::aCheckEnv := {'GRRGetSalesOrder','GRRConnCompany','GRRVldMessage'}
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Read
	Realiza a leitura da mensagem oriunda do SmartLink
@author philipe.pompeu
@since 23/07/2024
@param oLinkMessage, instância de FwTotvsLinkMessage, mensagem recebida
@return lResult, lógico
/*/
//-------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class BillAwaitingPaymentCreatedMessageReader
	Local lResult   := .F.
    Local oContent  := JsonObject():New()
    
    If GRRInDebug()
        GRRDebugInfo( { {'Type'     , ::cMessageType },;
                        {'Message'  , oLinkMessage:RawMessage()   } } )
    EndIf

	oContent:FromJSON(oLinkMessage:RawMessage())

    If oContent:HasProperty('data')
        oContent := oContent['data']
    EndIf    

    If lResult := ( ::IsMsgValid(oContent) .And. ::IsEnvPrepared() )
        if !(lResult := ::newProcessMessage(oLinkMessage))
            lResult := ::ProcessMessage(oContent)
        endIf
    EndIf
    
    FreeObj(oContent)
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} newProcessMessage
	Verifica e chama nova classe para processar a mensagem.
    @author guilherme.sordi
    @since 04/04/2025
    @version 12.1.2410
/*/
//-------------------------------------------------------------------------------------
method newProcessMessage(oLinkMessage as object) as logical class BillAwaitingPaymentCreatedMessageReader
    local lSuccess as logical
    local oNewHandler as object
    
    lSuccess := .F.

    if findClass("totvs.protheus.backoffice.apps.grr.messages.BillAwaitingPaymentCreatedMessageHandler")        
        oNewHandler := totvs.protheus.backoffice.apps.grr.messages.BillAwaitingPaymentCreatedMessageHandler():new()
        if oNewHandler:canRead(::cMessageType)
            lSuccess := oNewHandler:read(oLinkMessage)
        endIf
        fwFreeObj(oNewHandler)
    endIf
return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsMsgValid
	Valida se a mensagem está no padrão esperado
@author philipe.pompeu
@since 23/07/2024
@param oMessage, instância de JsonObject, json da mensagem BillAwaitingPaymentCreated
@return lMsgValid, lógico, se a mensagem está no formato esperado
/*/
//-------------------------------------------------------------------------------------
Method IsMsgValid(oMessage) Class BillAwaitingPaymentCreatedMessageReader
    Local lMsgValid := .F.

    lMsgValid := GRRVldMessage(oMessage, ::aPropObg)    
Return lMsgValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsEnvPrepared
	Valida se o ambiente está preparado para recepcionar a mensagem
@author philipe.pompeu
@since 23/07/2024
@return lMsgValid, lógico, pode realizar o processamento da mensagem
/*/
//-------------------------------------------------------------------------------------
Method IsEnvPrepared() Class BillAwaitingPaymentCreatedMessageReader
    Local lResult   := .T.
    Local nX        := 0

    for nX := 1 to Len(::aCheckEnv)

        lResult := FindFunction(::aCheckEnv[nX])
        If !lResult
            Exit
        EndIf
    next nX

Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessMessage
	Realiza o processamento da mensagem BillAwaitingPaymentCreated
@author philipe.pompeu
@since 23/07/2024
@param oMessage, JsonObject, instância da mensagem tipo BillAwaitingPaymentCreated
@return lMsgProcessed, boolean, se o processamento foi concluído corretamente
/*/
//-------------------------------------------------------------------------------------
Method ProcessMessage(oMessage) Class BillAwaitingPaymentCreatedMessageReader
    Local aAreas         := {SC5->(GetArea()), SF2->(GetArea()), SE1->(GetArea()), GetArea() }
    Local aSalesOrder    := {}
    Local aContractSheet := {}  
    Local aOrders        := {}
    Local aSeek          := {}    
    Local lMsgProcessed := .F.    
    Local l1stBillCtr   := .F.
    Local lIsType9      := .F.
    Local cSource       := ""
    Local cContractKey  := ""
    Local cBranchCtr    := ""
    Local cOrderNumber  := ""
    Local cKeySF2       := ""
    Local cQryAlias     := ""
    Local cQuery        := ""
    Local nSizeOrder    := GetSx3Cache('C5_NUM', 'X3_TAMANHO')
    Local dDueDate      := Date()
    Local dRealDueDate  := Date()
    Local oQuery        := Nil

    ::PrepareEnv(StrTokArr2( oMessage['organizationIntegrationId'], '|' ))

    cSource := AllTrim(oMessage['source'])    

    l1stBillCtr := ( cSource == 'CNTA300' .And. oMessage['cycle'] == 1 ) //Se for a primeira fatura de um contrato

    If( l1stBillCtr )
        aContractSheet := StrTokArr2( oMessage['billIntegrationId'] , '|', .T.)
        
        cBranchCtr  := PadR(aContractSheet[2], FWSizeFilial() )
        cContractKey:= PadR(aContractSheet[3], GetSx3Cache('CNA_CONTRA', 'X3_TAMANHO'))
        cContractKey+= PadR(aContractSheet[4], GetSx3Cache('CNA_REVISA', 'X3_TAMANHO'))
        cContractKey+= PadR(aContractSheet[5], GetSx3Cache('CNA_NUMERO', 'X3_TAMANHO'))

        aOrders := GRRGetSalesOrder(cContractKey)
        If Len(aOrders) > 0            
            cOrderNumber := PadR(aOrders[1,2], nSizeOrder)
        EndIf
    ElseIf ( cSource $ 'MATA410|CNTA300' )
        aSalesOrder := StrTokArr2( oMessage['billIntegrationId'] , '|' )
        cOrderNumber := PadR(aSalesOrder[3], nSizeOrder)      
    EndIf

    If !Empty(cOrderNumber)

        SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
        If SC5->( MsSeek( xFilial('SC5') + cOrderNumber ) )
            lOpenOrder  := SC5->( (Empty(C5_LIBEROK) .Or. C5_LIBEROK=='S') .And. Empty(C5_NOTA) .And. Empty(C5_BLQ) )
            lClosedOrder:= SC5->( C5_LIBEROK=='E' .Or. !Empty(C5_NOTA) .And. Empty(C5_BLQ) )
            
            dDueDate := ::GetDueDate(oMessage['dueDate'])            
            
            If lOpenOrder                
                lIsType9 := (Posicione('SE4', 1, xFilial('SE4') + SC5->C5_CONDPAG, 'E4_TIPO') == '9')
                
                If lIsType9
                    RecLock('SC5', .F.)
                    SC5->C5_DATA1 := dDueDate
                    SC5->(MsUnlock())
                    lMsgProcessed := .T.
                EndIf
            ElseIf lClosedOrder
                SF2->( DBSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
                cKeySF2 := xFilial('SF2') + SC5->( C5_NOTA + C5_SERIE + C5_CLIENTE + C5_LOJACLI )
                If SF2->( MSSeek( cKeySF2 ) )
                    dRealDueDate := DataValida(dDueDate)

                    cQuery := " SELECT	SE1.R_E_C_N_O_ AS RECID"
                    cQuery += " FROM "+RetSqlName("SE1")+" SE1"
                    cQuery += " WHERE	SE1.D_E_L_E_T_=' '"
                    cQuery += " AND SE1.E1_FILORIG = ?"
                    cQuery += " AND SE1.E1_PREFIXO = ?"
                    cQuery += " AND SE1.E1_NUM = ?"
                    cQuery += " AND SE1.E1_TIPO = ?"
                    cQuery += " ORDER BY E1_PARCELA"
                    cQuery := ChangeQuery(cQuery)
                    
                    oQuery := FWPreparedStatement():New(cQuery)                    
                    oQuery:SetString(1, SF2->F2_FILIAL)
                    oQuery:SetString(2, SF2->F2_PREFIXO)
                    oQuery:SetString(3, SF2->F2_DOC)
                    oQuery:SetString(4, MVNOTAFIS)

                    cQryAlias := MPSysOpenQuery( oQuery:getFixQuery() )
                    
                    BEGIN TRANSACTION
                        While (cQryAlias)->(!Eof())                            
                            SE1->( DbGoTo( (cQryAlias)->RECID ) )

                            RecLock('SE1', .F.)
                            SE1->E1_VENCTO := dDueDate
                            SE1->E1_VENCREA:= dRealDueDate                            
                            SE1->(MsUnlock())

                            (cQryAlias)->(DbSkip())
                        EndDo
                    END TRANSACTION
                    
                    lMsgProcessed := .T.

                    (cQryAlias)->(DbCloseArea())
                    oQuery:Destroy()
            		oQuery := Nil
                EndIf


            EndIf           
        EndIf
    EndIf

    ::PrepareEnv(::aOrigCompany) //Restaura ambiente prévio
    
    aEval(aAreas , {|x| RestArea(x) })
    FwFreeArray(aAreas)
    FwFreeArray(aSalesOrder)
    FwFreeArray(aContractSheet)
    FwFreeArray(aOrders)
    FwFreeArray(aSeek)
Return lMsgProcessed

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrepareEnv
	Prepara o ambiente com base na empresa/filial associada ao OrganizationIntegrationId
@author philipe.pompeu
@since 23/07/2024
@param cOrgIntgId, caractere, identificador da empresa/filial na plataforma
/*/
//-------------------------------------------------------------------------------------
Method PrepareEnv(aCompany) Class BillAwaitingPaymentCreatedMessageReader

    If (aCompany[1] != cEmpAnt)
        Eval(::bSetEnv, aCompany[1], aCompany[2] )        
    EndIf
    cFilAnt := aCompany[2]

    FwFreeArray(aCompany)
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDueDate
	Converte a data de vencimento da plataforma para uma data válida no sistema
@author philipe.pompeu
@since 23/07/2024
@param cDueDate, caractere, data no formato YYYY-MM-DDTHH:mm:ss
@return dDueDate, date, data de vencimento 
/*/
//-------------------------------------------------------------------------------------
Method GetDueDate(cDueDate) Class BillAwaitingPaymentCreatedMessageReader
    Local nSizeDate := Len("YYYY-MM-DD")
    Local aDate     := StrTokArr2( Left(cDueDate,nSizeDate), '-' ) //Exemplo : YYYY-MM-DDT00:00:00    
    Local dDueDate  := Date()
    
    If Len(aDate) == 3        
        dDueDate := CtoD(I18N('#3/#2/#1', aDate))
    EndIf

    FwFreeArray(aDate)
Return dDueDate
