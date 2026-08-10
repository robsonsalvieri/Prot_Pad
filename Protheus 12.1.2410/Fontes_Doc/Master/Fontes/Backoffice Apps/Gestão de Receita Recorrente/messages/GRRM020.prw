#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BillPaidCreatedMessageReader
	Classe responsável pela leitura das mensagens do tipo BillPaidCreated
    Link: https://tdn.totvs.com/display/public/framework/FwTotvsLinkClient
@author philipe.pompeu
@since 08/05/2024
/*/
//-------------------------------------------------------------------------------------
Class BillPaidCreatedMessageReader from LongNameClass

    Data aOrigCompany As Array
	Method New()
	Method Read(oLinkMessage)
    Method IsMsgValid(oMessage)
    Method IsEnvPrepared()
    Method PrepareEnv(cOrgIntgId)
    Method Finalize()
    Method ProcessMessage(oMessage)
    Method newProcessMessage(oLinkMessage as object) as logical
    Method isFinIntegration(oMessage) as logical
EndClass
 
Method New() Class BillPaidCreatedMessageReader

    ::aOrigCompany := { cEmpAnt, cFilAnt }
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Read
	Realiza a leitura da mensagem oriunda do SmartLink
@author philipe.pompeu
@since 08/05/2024
@param oLinkMessage, instância de FwTotvsLinkMessage, mensagem recebida
@return lResult, lógico
/*/
//-------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class BillPaidCreatedMessageReader
	Local lResult   := .F.
    Local oContent  := JsonObject():New()
    
    If GRRInDebug()
        GRRDebugInfo( { {'Type'     ,'BillPaidCreated'            },;
                        {'Message'  , oLinkMessage:RawMessage()   } } )
    EndIf

	oContent:FromJSON(oLinkMessage:RawMessage())

    If oContent:HasProperty('data')
        oContent := oContent['data']
    EndIf

    lResult := self:newProcessMessage(oLinkMessage)

    If !lResult .and. ::IsMsgValid(oContent) .And. ::IsEnvPrepared() .and. (!::isFinIntegration(oContent))
        lResult := ::ProcessMessage(oContent)
        ::Finalize()
    EndIf
    
    FreeObj(oContent)    

Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} isFinIntegration
	@description Retorna se a mensagem é de integração com o SIGAFIN
    @author guilherme.sordi@totvs.com.br
    @since 08/05/2024
    @param oMessage, instância de JsonObject, json da mensagem BillPaidCreated
    @return lMsgValid, lógico, se a mensagem está no formato esperado
/*/
//-------------------------------------------------------------------------------------
method isFinIntegration(oMessage) as logical class BillPaidCreatedMessageReader
    Local lRet as logical

    lRet := oMessage:hasProperty('source') .and. upper(allTrim(oMessage['source'])) == "GRRI110"
return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsMsgValid
	Valida se a mensagem está no padrão esperado
@author philipe.pompeu
@since 08/05/2024
@param oMessage, instância de JsonObject, json da mensagem BillPaidCreated
@return lMsgValid, lógico, se a mensagem está no formato esperado
/*/
//-------------------------------------------------------------------------------------
Method IsMsgValid(oMessage) Class BillPaidCreatedMessageReader
    Local lMsgValid := .F.
    Local aPropObg  := {'organizationIntegrationId' ,;
                        'billIntegrationId'         ,;
                        'source'                    ,;
                        'cycle'                     ,;
                        'paymentResponseType'       ,;
                        'billId'                    }
    
    lMsgValid := GRRVldMessage(oMessage, aPropObg)

    FWFreeArray(aPropObg)
Return lMsgValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IsEnvPrepared
	Valida se o ambiente está preparado para recepcionar a mensagem
@author philipe.pompeu
@since 08/05/2024
@return lMsgValid, lógico, pode realizar o processamento da mensagem
/*/
//-------------------------------------------------------------------------------------
Method IsEnvPrepared() Class BillPaidCreatedMessageReader
Return FindFunction("GRRGetSalesOrder") .And.;
       FindFunction("GRRInvGenerate")   .And.;
       FindFunction("GRRLibSalesOrder") .And.;
       FindFunction("GRRSetBillId")
       
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessMessage
	Realiza o processamento da mensagem BillPaidCreated
@author philipe.pompeu
@since 13/06/2024
@param oMessage, JsonObject, instância da mensagem tipo BillPaidCreated
@return lMsgProcessed, boolean, se o processamento foi concluído corretamente
/*/
//-------------------------------------------------------------------------------------
Method ProcessMessage(oMessage) Class BillPaidCreatedMessageReader
    Local aAreas         := {SC5->(GetArea()), GetArea() }
    Local aSalesOrder    := {}
    Local abillIntegrationId := {}
    Local aContractSheet := {}   
    Local aOrders        := {}
    Local aSeek          := {}    
    Local lMsgProcessed := .F.    
    Local l1stBillCtr   := .F.
    Local cInvGenerator := ''
    Local cSource       := ""
    Local cContractKey  := ""
    Local cSE1Key       := ""
    Local cBranch       := ""
    Local cOrderNumber  := ""
    Local cPaymentMethod:= ""
    Local nSizeOrder    := GetSx3Cache('C5_NUM', 'X3_TAMANHO')

    ::PrepareEnv(oMessage['organizationIntegrationId'])

    cSource := AllTrim(oMessage['source'])

    abillIntegrationId := StrTokArr2( oMessage['billIntegrationId'] , '|', .T.)

    cBranch  := PadR(abillIntegrationId[2], FWSizeFilial() )

    l1stBillCtr := ( cSource == 'CNTA300' .And. oMessage['cycle'] == 1 ) //Se for a primeira fatura de um contrato

    If( l1stBillCtr )
        
        cContractKey:= PadR(abillIntegrationId[3], GetSx3Cache('CNA_CONTRA', 'X3_TAMANHO'))
        cContractKey+= PadR(abillIntegrationId[4], GetSx3Cache('CNA_REVISA', 'X3_TAMANHO'))
        cContractKey+= PadR(abillIntegrationId[5], GetSx3Cache('CNA_NUMERO', 'X3_TAMANHO'))

        aOrders := GRRGetSalesOrder(cContractKey)
        If Len(aOrders) > 0            
            cOrderNumber := PadR(aOrders[1,2], nSizeOrder)
        EndIf
    ElseIf Substr(Upper(cSource),1,3) $ "PLS|FIN"

        cSE1Key := PadR(abillIntegrationId[3], GetSx3Cache('E1_PREFIXO', 'X3_TAMANHO'))
        cSE1Key += PadR(abillIntegrationId[4], GetSx3Cache('E1_NUM', 'X3_TAMANHO'))
        cSE1Key += PadR(abillIntegrationId[5], GetSx3Cache('E1_PARCELA', 'X3_TAMANHO'))
        cSE1Key += PadR(abillIntegrationId[5], GetSx3Cache('E1_TIPO', 'X3_TAMANHO'))

        aSeek := { cBranch, "SE1", cSE1Key }

        BEGIN TRANSACTION

            //--------------------------------------------------------------
            //Faz a baixa do titulo 
            //--------------------------------------------------------------            
            lMsgProcessed := GRRProcTit(abillIntegrationId)

            If lMsgProcessed
                cPaymentMethod := Left(oMessage['paymentResponseType'], 1)
                
                // ----------------------------------------------------------------------------
                // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                // ----------------------------------------------------------------------------
                GRRSetBillId( aSeek, oMessage['billId'] )
                // ----------------------------------------------------------------------------
                // Salva a forma de pagamento da fatura na tabela intermediária de assinatura(campo HRH_PAYMET)
                // ----------------------------------------------------------------------------
                GRRSetPaymentMethod( aSeek, cPaymentMethod )
            EndIf
        END TRANSACTION
    ElseIf ( cSource $ 'MATA410|CNTA300' )
        aSalesOrder := StrTokArr2( oMessage['billIntegrationId'] , '|' )
        cOrderNumber := PadR(aSalesOrder[3], nSizeOrder)
    EndIf

    If !Empty(cOrderNumber) 

        SC5->(dbSetOrder(1)) //C5_FILIAL+C5_NUM
        If SC5->( MsSeek( xFilial('SC5') + cOrderNumber ) )

            If l1stBillCtr //Primeira fatura de um contrato, busca HRH pela planilha
                aSeek := { cBranch, "CNA", cContractKey }
            Else
                aSeek := { SC5->C5_FILIAL, "SC5", SC5->C5_NUM }
            EndIf            

            cInvGenerator := GRRInvGenerate( SC5->C5_CONDPAG )

            BEGIN TRANSACTION
                //--------------------------------------------------------------
                // Libera o pedido de venda do bloqueio GRR
                //--------------------------------------------------------------            
                lMsgProcessed := GRRLibSalesOrder( (cEmpAnt +'|'+ SC5->C5_FILIAL +'|'+ SC5->C5_NUM),  cInvGenerator)

                If lMsgProcessed
                    cPaymentMethod := Left(oMessage['paymentResponseType'], 1)
                    
                    // ----------------------------------------------------------------------------
                    // Salva o guid da bill na tabela intermediária de assinatura ( HRH )
                    // ----------------------------------------------------------------------------
                    GRRSetBillId( aSeek, oMessage['billId'] )
                    // ----------------------------------------------------------------------------
                    // Salva a forma de pagamento da fatura na tabela intermediária de assinatura(campo HRH_PAYMET)
                    // ----------------------------------------------------------------------------
                    GRRSetPaymentMethod( aSeek, cPaymentMethod )
                EndIf
            END TRANSACTION
        EndIf
    EndIf
    
    aEval(aAreas , {|x| RestArea(x) })
    FwFreeArray(aAreas)
    FwFreeArray(aSalesOrder)
    FwFreeArray(aContractSheet)
    FwFreeArray(aOrders)
    FwFreeArray(aSeek)
Return lMsgProcessed

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} newProcessMessage
	Verifica e chama nova classe para processar a mensagem.
    @author claudio.yoshio
    @since 02/06/2025
    @param oLinkMessage, JsonObject, objeto da mensagem recebida do SmartLink
    @return lSuccess, lógico, indica se o processamento foi concluído corretamente
    @version 12.1.2410
/*/
//-------------------------------------------------------------------------------------
method newProcessMessage(oLinkMessage as object) as logical class BillPaidCreatedMessageReader
    local lSuccess as logical
    local oNewHandler as object
    local cMessageType := 'BillPaidCreated' as character
    
    lSuccess := .F.

    if findClass("totvs.protheus.backoffice.apps.grr.messages.BillPaidCreatedMessageHandler")
        oNewHandler := totvs.protheus.backoffice.apps.grr.messages.BillPaidCreatedMessageHandler():new()
        if oNewHandler:canRead(cMessageType)
            lSuccess := oNewHandler:read(oLinkMessage)
        endIf
        fwFreeObj(oNewHandler)
    endIf
return lSuccess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Finalize
	Restaura o ambiente para configuração inicial e limpa propriedades da classe
@author philipe.pompeu
@since 15/05/2024
/*/
//-------------------------------------------------------------------------------------
Method Finalize() Class BillPaidCreatedMessageReader

    If (::aOrigCompany[1] != cEmpAnt)
        RpcClearEnv()        
        GRRConnCompany( ::aOrigCompany[1], ::aOrigCompany[2] )
    EndIf    
    cFilAnt := ::aOrigCompany[2]

    FwFreeArray(::aOrigCompany) 
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrepareEnv
	Prepara o ambiente com base na empresa/filial associada ao OrganizationIntegrationId
@author philipe.pompeu
@since 15/05/2024
@param cOrgIntgId, caractere, identificador da empresa/filial na plataforma
/*/
//-------------------------------------------------------------------------------------
Method PrepareEnv(cOrgIntgId) Class BillPaidCreatedMessageReader
    Local aCompany          := {}

    aCompany := StrTokArr2( cOrgIntgId, '|' )

    If (aCompany[1] != cEmpAnt)
        RpcClearEnv()
        GRRConnCompany( aCompany[1], aCompany[2] )  
    EndIf
    cFilAnt := aCompany[2] 

    FwFreeArray(aCompany)
Return Nil
