#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BillCanceledCreatedMessageReader
	Classe responsável pela leitura das mensagens do tipo BillCanceledCreated
    Link: https://tdn.totvs.com/display/public/framework/FwTotvsLinkClient
@author philipe.pompeu
@since 02/08/2024
/*/
//-------------------------------------------------------------------------------------
Class BillCanceledCreatedMessageReader from LongNameClass

    Data aOrigCompany As Array
    Data aPropObg As Array
    Data aCheckEnv As Array
    Data bSetEnv
	Method New()
	Method Read(oLinkMessage)
    Method IsMsgValid(oMessage)
    Method IsEnvPrepared()
    Method PrepareEnv(cOrgIntgId)
    Method ProcessMessage(oMessage)
    Method CancelOrder(cSource)
    Method RemoveHRH(aSubscription)
    Method UndoLiberation()
    Private Method newProcessMessage(oLinkMessage as object) as logical
EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
	Método construtor da classe
@author philipe.pompeu
@since 02/08/2024
/*/
//-------------------------------------------------------------------------------------
Method New() Class BillCanceledCreatedMessageReader

    ::aOrigCompany  := { cEmpAnt, cFilAnt }
    ::bSetEnv       := {|cCompany, cBranch| RpcClearEnv(), GRRConnCompany( cCompany, cBranch ) }

    ::aPropObg  := {'organizationIntegrationId' ,;
                    'billIntegrationId'         ,;                    
                    'source'                    }
    ::aCheckEnv := {'GRRA050','GRRConnCompany'}
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Read
	Realiza a leitura da mensagem oriunda do SmartLink
@author philipe.pompeu
@since 02/08/2024
@param oLinkMessage, instância de FwTotvsLinkMessage, mensagem recebida
@return lResult, lógico
/*/
//-------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class BillCanceledCreatedMessageReader
	Local lResult   := .F.
    Local oContent  := JsonObject():New()    
    
    If GRRInDebug()
        GRRDebugInfo( { {'Type'     ,'BillCanceledCreated' },;
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
    @author claudio.yoshio
    @since 26/05/2025
    @version 12.1.2410
/*/
//-------------------------------------------------------------------------------------
method newProcessMessage(oLinkMessage as object) as logical class BillCanceledCreatedMessageReader
    local lSuccess as logical
    local oNewHandler as object
    local cMessageType := 'BillCanceledCreated' as character
    
    lSuccess := .F.

    if findClass("totvs.protheus.backoffice.apps.grr.messages.BillCanceledCreatedMessageHandler")
        oNewHandler := totvs.protheus.backoffice.apps.grr.messages.BillCanceledCreatedMessageHandler():new()
        if oNewHandler:canRead(cMessageType)
            lSuccess := oNewHandler:read(oLinkMessage)
        endIf
        fwFreeObj(oNewHandler)
    endIf
return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsMsgValid
	Valida se a mensagem está no padrão esperado
@author philipe.pompeu
@since 02/08/2024
@param oMessage, instância de JsonObject, json da mensagem BillCanceledCreated
@return lMsgValid, lógico, se a mensagem está no formato esperado
/*/
//-------------------------------------------------------------------------------------
Method IsMsgValid(oMessage) Class BillCanceledCreatedMessageReader
    Local lMsgValid := .F.

    lMsgValid := GRRVldMessage(oMessage, ::aPropObg)    
Return lMsgValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsEnvPrepared
	Valida se o ambiente está preparado para recepcionar a mensagem
@author philipe.pompeu
@since 02/08/2024
@return lMsgValid, lógico, pode realizar o processamento da mensagem
/*/
//-------------------------------------------------------------------------------------
Method IsEnvPrepared() Class BillCanceledCreatedMessageReader
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
	Realiza o processamento da mensagem BillCanceledCreated
@author philipe.pompeu
@since 02/08/2024
@param oMessage, JsonObject, instância da mensagem tipo BillCanceledCreated
@return lMsgProcessed, boolean, se o processamento foi concluído corretamente
/*/
//-------------------------------------------------------------------------------------
Method ProcessMessage(oMessage) Class BillCanceledCreatedMessageReader
    Local aAreas         := {SC5->(GetArea()), SF2->(GetArea()), SE1->(GetArea()), GetArea() }
    Local aSalesOrder    := {}
    Local aContractSheet := {}  
    Local aOrders        := {}
    Local aSeek          := {}    
    Local lMsgProcessed := .F.
    Local cSource       := ""
    Local cOrderNumber  := ""
    Local nSizeOrder    := GetSx3Cache('C5_NUM', 'X3_TAMANHO')
    
    ::PrepareEnv(StrTokArr2( oMessage['organizationIntegrationId'], '|' ))

    cSource := AllTrim(oMessage['source'])

    If ( cSource $ 'MATA410' )
        aSalesOrder := StrTokArr2( oMessage['billIntegrationId'] , '|' )
        cOrderNumber := PadR(aSalesOrder[3], nSizeOrder)      
    EndIf

    If !Empty(cOrderNumber)

        SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
        If SC5->( MsSeek( xFilial('SC5') + cOrderNumber ) )
            lOpenOrder  := SC5->( (Empty(C5_LIBEROK) .Or. C5_LIBEROK=='S') .And. Empty(C5_NOTA) .And. Empty(C5_BLQ) )
            If lOpenOrder
                lMsgProcessed := ::CancelOrder(cSource)
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
@since 02/08/2024
@param cOrgIntgId, caractere, identificador da empresa/filial na plataforma
/*/
//-------------------------------------------------------------------------------------
Method PrepareEnv(aCompany) Class BillCanceledCreatedMessageReader

    If (aCompany[1] != cEmpAnt)
        Eval(::bSetEnv, aCompany[1], aCompany[2] )        
    EndIf
    cFilAnt := aCompany[2]

    FwFreeArray(aCompany)
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CancelOrder
	Cancela um Pedido de Venda
@author philipe.pompeu
@since 02/08/2024
@param cSource, caractere, origem da fatura
@return lResult, logical, se a operação foi executada com sucesso
/*/
//-------------------------------------------------------------------------------------
Method CancelOrder(cSource) Class BillCanceledCreatedMessageReader    
    Local lResult   := .T.
    Local cOrder    := ""
    Local cBranch   := ""
    Private lAutoErrNoFile := .T.
    Private lMsHelpAuto    := .T.
    Private lMsErroAuto    := .F.    

    cOrder := SC5->C5_NUM
    cBranch:= SC5->C5_FILIAL

    BEGIN TRANSACTION

    If SC5->C5_LIBEROK=='S'
        lResult := ::UndoLiberation()
    EndIf

    If lResult        
        lAutoErrNoFile := .T.
        lMsHelpAuto    := .T.
        lMsErroAuto    := .F. 
        
        MSExecAuto({|x,y,z| Mata410(x,y,z)},{ {"C5_NUM", cOrder, NIL} },{},5) //-- Exclui pedido de venda        
        
        If (lResult := !(lMsErroAuto))
            lResult := ::RemoveHRH({cBranch, "SC5", cOrder, cSource})
        EndIf
    EndIf

    If !lResult
        DisarmTransaction()
    EndIf

    END TRANSACTION  
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} UndoLiberation
	Estorna a liberação do pedido de venda
@author philipe.pompeu
@since 02/08/2024
@return lResult, logical, se a operação foi executada com sucesso
/*/
//-------------------------------------------------------------------------------------
Method UndoLiberation()  Class BillCanceledCreatedMessageReader
    Local aAreas := {SC5->(GetArea()),SC6->(GetArea()), GetArea()}
    Local aItems := {}
    Local aTemp := {}
    Local cKeySC6 := ""
    Private lAutoErrNoFile := .T.
    Private lMsHelpAuto    := .T.
    Private lMsErroAuto    := .F.

    cKeySC6 := SC5->(C5_FILIAL+C5_NUM)
    SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

    If SC6->(DbSeek(cKeySC6))
        While SC6->(!Eof() .And. C6_FILIAL+C6_NUM == cKeySC6)
            
            aAdd(aTemp,{"C6_ITEM"		,SC6->C6_ITEM		,Nil})
            aAdd(aTemp,{"C6_PRODUTO"	,SC6->C6_PRODUTO    ,Nil})
            aAdd(aTemp,{"C6_QTDVEN"	    ,SC6->C6_QTDVEN		,Nil})
            aAdd(aTemp,{"C6_PRCVEN"	    ,SC6->C6_PRCVEN	    ,Nil})
            aAdd(aTemp,{"C6_VALOR"	    ,SC6->C6_VALOR	    ,Nil})
            aAdd(aTemp,{"C6_TES"		,SC6->C6_TES	 	,Nil})
            aAdd(aTemp,{"C6_QTDLIB"	    ,0			        ,Nil})//Estorna a quantidade liberada

            aAdd(aItems, aClone(aTemp))
            aSize(aTemp,0)
            SC6->(DbSkip())
        EndDo
    EndIf

    MSExecAuto({|x,y,z| Mata410(x,y,z)},{ {"C5_NUM", SC5->C5_NUM, NIL} }, aItems, 4) //Estorna as quantidades liberadas

    aEval(aAreas,{|x| RestArea(x) })
    FwFreeArray(aAreas)
    FwFreeArray(aItems)
Return !(lMsErroAuto)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveHRH
	Exclui a amarração pedido x subscrição 
@author philipe.pompeu
@since 02/08/2024
@param aSubscription, array, dados da subscrição para exclusão
@return lResult, logical, se a operação foi executada com sucesso
/*/
//-------------------------------------------------------------------------------------
Method RemoveHRH(aSubscription) Class BillCanceledCreatedMessageReader
    Local lResult := .F.
    Local cSeek := ""
    Local oModel:= Nil

    cSeek:= PadR(aSubscription[1], GetSx3Cache('HRH_SRCFIL' , 'X3_TAMANHO')) +;
            PadR(aSubscription[2], GetSx3Cache('HRH_ALIAS'  , 'X3_TAMANHO')) +;
            PadR(aSubscription[3], GetSx3Cache('HRH_REQCD'  , 'X3_TAMANHO')) +;
            PadR(aSubscription[4], GetSx3Cache('HRH_SOURCE' , 'X3_TAMANHO'))

    HRH->( DBSetOrder(1) ) // HRH_FILIAL+HRH_SRCFIL+HRH_ALIAS+HRH_REQCD+HRH_SOURCE

    If (lResult := HRH->(DbSeek(xFilial('HRH') + cSeek)))
        oModel  := FWLoadModel( "GRRA050" )
        oModel:SetOperation( MODEL_OPERATION_DELETE )
        If (lResult := oModel:Activate())
            lResult := (oModel:VldData() .And. oModel:CommitData())
            oModel:DeActivate()			
        EndIf        
        FreeObj(oModel)
    EndIf
    
Return lResult
