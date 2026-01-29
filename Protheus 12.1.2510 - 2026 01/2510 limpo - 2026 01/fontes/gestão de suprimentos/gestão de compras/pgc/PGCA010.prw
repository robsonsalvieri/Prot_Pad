#include "totvs.ch"  
#include "PGCA010.CH"
#INCLUDE 'FWLIBVERSION.CH'
#Include 'FWMVCDef.ch'

Static _oJsonSup := JsonObject():New()
Static _cRoutine := 'PGCA010'
//------------------------------------------------------------------
/*/{Protheus.doc} PGCA010

Executa app Angular Portal de Compras.

@author  juan.felipe
@since   19/10/2021
/*/
//-------------------------------------------------------------------
Function PGCA010(cRoutine)
    Default cRoutine := 'PGCA010'
    _cRoutine := cRoutine
    CallApp()
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CallApp
    Executa app Angular Portal de Compras
@author  juan.felipe
@since   19/10/2023
/*/
//-------------------------------------------------------------------
Static Function CallApp()
	Local aDownload := {"pdf", "xls", "xlsx", "rtf", "docx", "doc", "mht", "html", "txt", "csv", "png", "jpg","jpeg", "gif", "xml", "zip","tiff","bmp","rar"}
    Local cIdMetric := 'compras-protheus_total-de-acessos-ao-pgc_total'
    Local cMessage  := ''
    Local cHelp := ''

    addMetric(_cRoutine, _cRoutine+'-FwCallApp', cIdMetric, 1)

    If PGCVldTables(@cMessage, _cRoutine, @cHelp) //-- Valida campos necessários
        FwTWebEngineDownloadList():SetTemporaryAllowed(aDownload)
        FwCallApp("pgca010")
        FwTWebEngineDownloadList():ClearTemporaryAllowed()
    Else
        Help(" ",1, cHelp,, cMessage, 1, 0)
    EndIf
Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl

Bloco de codigo que recebera as chamadas JavaScript

@author  juan.felipe
@since   19/10/2021
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel,cType,cContent)
Local cJsonCompany  := ""
Local cJsonBranch   := ""
Local cIdMetric     := ""
Local cSubRoutine   := ""
Local cTargetDir    := ""
Local cCode         := ""
Local cMessage      := ""
Local nValue        := 1
Local oJsonRemote   := Nil
Local oJsonMetric   := Nil
Local oJsonMessage  := Nil
Local oJsonData     := Nil
Local oJsonAction   := Nil
Local oJsonSup      := Nil
Local cMascara      := "||Imagens|*.jpg|PDFs|*.pdf" //"Todos os arquivos|."
Local cTitulo       := STR0001
Local cDirini       := "\"
Local cDirDocs	    := MsDocPath()
Local lSalvar       := .T.
Local lArvore       := .F.
Local lCopy         := .F.
Local nMascpad      := 0
Local nOpcoes       := nOR( GETF_LOCALHARD, GETF_RETDIRECTORY)
Local cViewText     := ""
Local cDocumenttype := ""
Local cJustification := ""
Local oSubsRepo     := Nil
Local oJsonResult   := Nil
Local oJsonRequest  := Nil
Local cQuotCode     := ""
Local cSupplier     := ""
Local cStore        := ""
Local cSupName      := ""
Local cProposal     := ""
Local cEmailList    := ""
Local lNewProp      := ""
Local lCleanProp    := ""
Local lNewPart      := ""
Local lNewEmail     := .f.
Local cNameBox      := ""
Local cEmailUsr     := ""
Local cRpoRelease   := ""
Local lNFCFilFor    := .F. // P.E para filtrar os fornecedores na geração da cotação.
local aButtons      := { {.F., Nil},;            //- Copiar
                        {.F., Nil},;            //- Recortar
                        {.F., Nil},;            //- Colar
                        {.t., Nil},;            //- Calculadora
                        {.t., Nil},;            //- Spool
                        {.t., Nil},;            //- Imprimir
                        {.t., STR0047},;        //- "Confirmar"
                        {.t., STR0048},;        //- "Cancelar"
                        {.t., Nil},;            //- WalkThrough
                        {.F., Nil},;            //- Ambiente
                        {.t., Nil},;            //- Mashup
                        {.t., Nil},;            //- Help
                        {.F., Nil},;            //- Formulário HTML
                        {.F., Nil},;            // - ECM
                        {.f., nil}}             // - Desabilitar o botão Salvar e Criar Novo

Private nOpcNFC := 0
Private INCLUI  := .F.
Private ALTERA  := .F.

If cType == "preLoad"
    oJsonRemote := JsonObject():New()

    cJsonCompany := '{"Code":"'+cEmpAnt+'","InternalId":"'+cEmpAnt+'","CorporateName":"'+FWGrpName(cEmpAnt)+'"}'
    cJsonBranch := '{"CompanyCode":"'+cEmpAnt+'","EnterpriseGroup":"'+cEmpAnt+'","ParentCode":"'+cFilAnt+'","Code":"'+cFilAnt+'","Description":"'+FWFilialName()+'"}'
    oJsonRemote["isSmartClient"] := .T.
	cEmailUsr := Alltrim(UsrRetMail(__cUserID))
	cRpoRelease := GetRpoRelease()
    lNFCFilFor := Existblock("NFCFILFOR")
    
    oWebChannel:AdvPLToJS('cleanStorageData', Nil)
    oWebChannel:AdvPLToJS('setCompany', cJsonCompany)
    oWebChannel:AdvPLToJS('setBranch', cJsonBranch)
    oWebChannel:AdvPLToJS('remoteType', FwJsonSerialize(oJsonRemote))
    oWebChannel:AdvPLToJS('user', UsrRetName(__cUserID))
    oWebChannel:AdvPLToJS('userAdmin', iif(FWIsAdmin(__cUserID), "true", "false"))
    oWebChannel:AdvPLToJS('userEmail',cEmailUsr)
    oWebChannel:AdvPLToJS('paramWfBuyer', iif(WFGetMV( "MV_PGCWF", .F. ), "true", "false"))
    oWebChannel:AdvPLToJS('paramNewInterface', iif(FindFunction("NFCA020"), "true", "false"))
	oWebChannel:AdvPLToJS('paramNewUpdateContact', iif(FindFunction("NFCSetContactList") .and. FindFunction("COMA070A") .and. FwAliasInDic("DKI"), "true", "false"))
	oWebChannel:AdvPLToJS('paramNewInsertSupplier', iif(FindFunction("A020SetNFC") .and. FindFunction("NFCRegSup"), "true", "false"))
    oWebChannel:AdvPLToJS('userId', __cUserID)
	oWebChannel:AdvPLToJS('rpoRelease', cRpoRelease)
    oWebChannel:AdvPLToJS('paramNFCFilFor', if(lNFCFilFor,"true","false"))
	oWebChannel:AdvPLToJS('paramAltpDoc', Iif(SuperGetMV("MV_ALTPDOC", .F., .F.), 'true', 'false'))
	oWebChannel:AdvPLToJS('paramDtReceb', Iif(SuperGetMV("MV_NFCDTRE", .F., .F.), 'true', 'false'))
	oWebChannel:AdvPLToJS('nfcWfCustom', Iif(Existblock("NFCWFCUSTOM"), 'true', 'false'))
    
    if ( WFGetMV( "MV_PGCWF", .F. ) .and. !empty(cEmailUsr) )
        lNewEmail := NFCexistsWF7email(cEmailUsr, @cNameBox)
    endif
    
    oWebChannel:AdvPLToJS('postalBoxName', cNameBox)    
    oWebChannel:AdvPLToJS('proPaisLoc', cPaisLoc)
	oWebChannel:AdvPLToJS('routine', _cRoutine)
ElseIf cType == "metric"
    oJsonMetric := JsonObject():New()

    If oJsonMetric:fromJson(cContent) == Nil
        cIdMetric := oJsonMetric['idMetric']
        cSubRoutine := oJsonMetric['subRoutine']
        nValue := oJsonMetric['value']

        addMetric('PGCA010', cSubRoutine, cIdMetric, nValue)
    EndIf
ElseIf cType == "download"
    oJsonData := JsonObject():New()
    oJsonMessage := JsonObject():New()

    If oJsonData:FromJson(cContent) == Nil
        cTargetDir := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
        
        If !Empty(cTargetDir)
            lCopy := CpyS2T(cDirDocs+'\'+oJsonData['name'], cTargetDir)

            If lCopy
                oJsonMessage['status'] := .T.
                oJsonMessage['message'] := STR0045 //-- Anexo salvo com sucesso.
            Else
                oJsonMessage['status'] := .F.
                oJsonMessage['message'] := STR0046 + ' Error(' + AllTrim(Str(FError())) + ')'//-- Não foi possível realizar o download do arquivo pois ele pode estar corrompido.
            EndIf
        Else
            oJsonMessage['status'] := .F.
            oJsonMessage['message'] := ''
        EndIf
        
        oJsonMessage['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('attachmentSaved', oJsonMessage:toJson())
    FreeObj(oJsonData)
    FreeObj(oJsonMessage)
ElseIf cType == "editQuote"
    
    DbSelectArea("DHU")
    DHU->(DbSetOrder(1))

    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()

    oJsonAction['isRefresh'    ] := .F.
    oJsonAction['wasSaved'     ] := .F.
    oJsonAction['supplierCode' ] := ''
    oJsonAction['supplierStore'] := ''
    oJsonAction['supplierName' ] := ''

    _oJsonSup['wasSaved'     ] := .F.
    _oJsonSup['supplierCode' ] := ''
    _oJsonSup['supplierStore'] := ''
    _oJsonSup['supplierName' ] := ''
    
    oWebChannel:AdvPLToJS('editQuoteClosed', Nil)
    
    If oJsonData:FromJson(cContent) == Nil
        cQuotCode  := oJsonData['quoteNumber']
        cSupplier := oJsonData['supplierCode']
        cStore := oJsonData['supplierStore']
        cSupName := oJsonData['supplierName']
        cProposal := oJsonData['proposal']
        lNewProp  := oJsonData['newProposal']
        lCleanProp  := oJsonData['cleanProposal']
        lNewPart  := oJsonData['newParticipant']
		lEditPartial  := oJsonData['editPartial']

        If DHU->(DbSeek(fwxFilial("DHU") + cQuotCode))

            If oJsonData['readOnly'] //-- Operação de visualização
                nOpcNFC := MODEL_OPERATION_VIEW
                oJsonAction['isRefresh'] := .F. //-- Não atualiza a tela do PO-UI ao fechar a tela MVC
            Else //-- Operação de update
                nOpcNFC := MODEL_OPERATION_UPDATE
                oJsonAction['isRefresh'] := .T. //-- Atualiza a tela do PO-UI ao fechar a tela MVC
            EndIf

            
            NF020SetSup(cQuotCode, cSupplier, cStore, cSupName, cProposal, lNewProp, lNewPart, lCleanProp, lEditPartial) //-- Define informações do fornecedor
            cViewText := ' ' + cQuotCode + " - "
            
            If lNewPart
                cViewText += STR0049 //-- Novo participante
            Else
                cViewText += cSupName
            EndIf

            FWMsgRun(, {|| FWExecView (cViewText, "NFCA020", nOpcNFC, , , , , aButtons) }, STR0050, STR0051) //-- Aguarde... | Carregando...

            oJsonAction['wasSaved'     ] := _oJsonSup['wasSaved']
            oJsonAction['supplierCode' ] := _oJsonSup['supplierCode']
            oJsonAction['supplierStore'] := _oJsonSup['supplierStore']
            oJsonAction['supplierName' ] := _oJsonSup['supplierName']
        EndIf

		oJsonAction['executionHash'] := oJsonData['executionHash']
    Endif

    oWebChannel:AdvPLToJS('editQuoteClosed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "updateContact"


    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()
	oJsonSup := JsonObject():New()
    oJsonAction['wasSaved'] := .F.
    _oJsonSup['wasSaved']   := .F.

    oWebChannel:AdvPLToJS('updateContactClosed', Nil)
    
    oJsonData:FromJson(cContent)
    cSupplier := oJsonData['supplierCode']
    cStore := oJsonData['supplierStore']

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbSeek(fwxFilial("SA2")+cSupplier+cStore))

    FWMsgRun(, {|| FWExecView (STR0052, "COMA070", MODEL_OPERATION_UPDATE, , , , , aButtons) }, STR0050, STR0051) // Manutenção -- Aguarde... | Carregando...

    oJsonSup['items'] := {JsonObject():New()}
    oJsonSup['items'][1]['suppliercode'] := SA2->A2_COD
    oJsonSup['items'][1]['store'] := SA2->A2_LOJA
    cEmailList := NFCSetContactList(oJsonSup, 1)

    oJsonAction['wasSaved' ] := _oJsonSup['wasSaved']
    oJsonAction['email'    ] := SA2->A2_EMAIL
    oJsonAction['emaillist'] := IIf(!Empty(cEmailList), cEmailList, SA2->A2_EMAIL)
    oJsonAction['areacode' ] := SA2->A2_DDD
    oJsonAction['telephone'] := SA2->A2_TEL
    oJsonAction['executionHash'] := oJsonData['executionHash']
    
    oWebChannel:AdvPLToJS('updateContactClosed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
    FreeObj(oJsonSup)

ElseIf cType == "contractByProposal" //Inclusão do Contrato

    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()
    
    oJsonAction['isRefresh'    ] := .F.
    oJsonAction['wasSaved'     ] := .F.
    oJsonAction['supplierCode' ] := ''
    oJsonAction['supplierStore'] := ''
    oJsonAction['supplierName' ] := ''
    oJsonAction['code' ]         := ''
    oJsonAction['message' ]      := ''

    _oJsonSup['wasSaved'     ]  := .F.
    _oJsonSup['supplierCode' ]  := ''
    _oJsonSup['supplierStore']  := ''
    _oJsonSup['supplierName' ]  := ''
    _oJsonSup['code' ]          := ''
    _oJsonSup['message' ]       := ''

    oJsonRequest := JsonObject():New()

    If oJsonData:FromJson(cContent) == Nil
        cQuotCode  := oJsonData['quotationcode']
        cSupplier   := oJsonData['supplier']
        cStore := oJsonData['store']
        cSupName := oJsonData['supplierName']
        cDocumenttype := oJsonData['documenttype']
        cJustification := oJsonData['justification']

        oJsonRequest['contractgenerationtype'] := cDocumenttype

        oWebChannel:AdvPLToJS('contractByProposalClosed', Nil)
    
        oSubsRepo := pgc.analyzeQuotationRepository.pgcAnalyzeQuotationRepository():New()
        oJsonResult := oSubsRepo:analyzeQuoteByProposal(;
								oJsonData,;
                                oJsonRequest,;
                                cJustification;
							)
 
        cCode := oJsonResult['code']
        cMessage := oJsonResult['message']
    
        oJsonAction['wasSaved'     ] := _oJsonSup['wasSaved']
        oJsonAction['supplierCode' ] := _oJsonSup['supplierCode']
        oJsonAction['supplierStore'] := _oJsonSup['supplierStore']
        oJsonAction['supplierName' ] := _oJsonSup['supplierName']
        oJsonAction['code']          := cCode
        oJsonAction['message']       := DecodeUTF8(cMessage)

        oJsonAction['executionHash'] := oJsonData['executionHash']

    EndIf

    oWebChannel:AdvPLToJS('contractByProposalClosed', oJsonAction:ToJson())
    FreeObj(oJsonData)
    FreeObj(oJsonAction)
    FreeObj(oSubsRepo)
    FreeObj(oJsonResult)
    FreeObj(oJsonRequest)
    
ElseIf cType == "contractByItem" //Inclusão do Contrato por Item

    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()
    
    oJsonAction['isRefresh'    ] := .F.
    oJsonAction['wasSaved'     ] := .F.
    oJsonAction['supplierCode' ] := ''
    oJsonAction['supplierStore'] := ''
    oJsonAction['supplierName' ] := ''
    oJsonAction['code' ]         := ''
    oJsonAction['message' ]      := ''

    _oJsonSup['wasSaved'     ]  := .F.
    _oJsonSup['supplierCode' ]  := ''
    _oJsonSup['supplierStore']  := ''
    _oJsonSup['supplierName' ]  := ''
    _oJsonSup['code' ]          := ''
    _oJsonSup['message' ]       := ''

    oJsonRequest := JsonObject():New()
    
    oWebChannel:AdvPLToJS('contractByItemClosed', Nil)

    If oJsonData:FromJson(cContent) == Nil

        oSubsRepo := pgc.analyzeQuotationRepository.pgcAnalyzeQuotationRepository():New()

        oJsonResult := oSubsRepo:analyzeQuoteByItem(;
                            oJsonData['contractFormalizationItem'];
                        )

        cCode := oJsonResult['code']
        cMessage := oJsonResult['message']

        oJsonAction['wasSaved'     ] := _oJsonSup['wasSaved']
        oJsonAction['supplierCode' ] := _oJsonSup['supplierCode']
        oJsonAction['supplierStore'] := _oJsonSup['supplierStore']
        oJsonAction['supplierName' ] := _oJsonSup['supplierName']
        oJsonAction['code']          := cCode
        oJsonAction['message']       := DecodeUTF8(cMessage)

        oJsonAction['executionHash'] := oJsonData['executionHash']

    EndIf

    oWebChannel:AdvPLToJS('contractByItemClosed', oJsonAction:ToJson())
    FreeObj(oJsonData)
    FreeObj(oJsonAction)
    FreeObj(oSubsRepo)
    FreeObj(oJsonResult)
    FreeObj(oJsonRequest)

ElseIf cType == "supplierRegister" //Inclusão do Contrato por Item
    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()
    
    oJsonAction['items'] := {}
    oJsonAction['wasSaved'] := .F.

    oWebChannel:AdvPLToJS('supplierClosed', Nil)

    If oJsonData:FromJson(cContent) == Nil .And. oJsonData:HasProperty('items')
        lOk := NFCRegSup(oWebChannel, oJsonData)

        oJsonAction['items'        ] := oJsonData['items']
        oJsonAction['executionHash'] := oJsonData['executionHash']
        oJsonAction['wasSaved'     ] := lOk
    EndIf

    oWebChannel:AdvPLToJS('supplierClosed', oJsonAction:ToJson())
    FreeObj(oJsonData)
    FreeObj(oJsonAction)
    FreeObj(oJsonResult)
ElseIf cType == "COMA250Edit" // -- Editar Grupo de aprovação
    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()

    oJsonAction['isRefresh'] := .F.
    oJsonAction['wasSaved']  := .F.
    _oJsonSup['wasSaved']  := .F.
    _oJsonSup['isRefresh'] := .T.

    oWebChannel:AdvPLToJS('COMA250Closed', Nil)

    If oJsonData:FromJson(cContent) == Nil
        DbSelectArea("SAL")
        SAL->(DbSetOrder(1))
        SAL->(DbSeek(fwxFilial("SAL")+oJsonData['al_cod']))

        FWMsgRun(, {|| FWExecView (STR0052, "MATA114", MODEL_OPERATION_UPDATE, , , , , aButtons) }, STR0050, STR0051) // Manutenção -- Aguarde... | Carregando...

        oJsonAction['wasSaved'] := _oJsonSup['wasSaved']
        oJsonAction['isRefresh'] := _oJsonSup['isRefresh']
        
        oJsonAction['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('COMA250Closed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "COMA250View"// -- Visualizar Grupo de aprovação

    oJsonData := JsonObject():New()
    oJsonData:FromJson(cContent)

    DbSelectArea("SAL")
    SAL->(DbSetOrder(1))
    SAL->(DbSeek(fwxFilial("SAL")+oJsonData['al_cod']))

    FWMsgRun(, {|| FWExecView (STR0052, "MATA114", MODEL_OPERATION_VIEW, , , , , aButtons) }, STR0050, STR0051) // Manutenção -- Aguarde... | Carregando...

ElseIf cType == "COMA250Delete"// -- Visualizar Grupo de aprovação

    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()

    oJsonAction['isRefresh'] := .F.
    oJsonAction['wasSaved']  := .F.
    _oJsonSup['wasSaved']  := .F.
    _oJsonSup['isRefresh'] := .T.

    oWebChannel:AdvPLToJS('COMA250Closed', Nil)

    If oJsonData:FromJson(cContent) == Nil
        DbSelectArea("SAL")
        SAL->(DbSetOrder(1))
        SAL->(DbSeek(fwxFilial("SAL")+oJsonData['al_cod']))

        FWMsgRun(, {|| FWExecView (STR0052, "MATA114", MODEL_OPERATION_DELETE, , , , , aButtons) }, STR0050, STR0051) // Manutenção -- Aguarde... | Carregando...

        oJsonAction['wasSaved'] := _oJsonSup['wasSaved']
        oJsonAction['isRefresh'] := _oJsonSup['isRefresh']

        oJsonAction['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('COMA250Closed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "MATA095Insert"// -- Inclusão Aprovadores
    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()

    oJsonAction['isRefresh'] := .F.
    oJsonAction['wasSaved']  := .F.
    _oJsonSup['wasSaved']  := .F.
    _oJsonSup['isRefresh'] := .T.

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', Nil)

    If oJsonData:FromJson(cContent) == Nil

        cViewText := STR0054 //-- "Incluir"
        INCLUI := .T.

        FWMsgRun(, {|| FWExecView (cViewText, "MATA095", MODEL_OPERATION_INSERT, , , , , aButtons) }, STR0050, STR0051) //-- Aguarde... | Carregando...

        oJsonAction['wasSaved'] := _oJsonSup['wasSaved']
        oJsonAction['isRefresh'] := _oJsonSup['isRefresh']

        oJsonAction['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "MATA095Update"// -- Editar Aprovadores
    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()
    
    oJsonAction['isRefresh'] := .F.
    oJsonAction['wasSaved']  := .F.
    oJsonAction['ak_cod']    := ''
    oJsonAction['ak_nome']   := ''
    oJsonAction['ak_login']  := ''
    oJsonAction['ak_user']   := ''

    _oJsonSup['wasSaved']    := .F.
    _oJsonSup['isRefresh']   := .T.

    _oJsonSup['ak_cod']      := ''
    _oJsonSup['ak_nome']     := ''
    _oJsonSup['ak_login']    := ''
    _oJsonSup['ak_user']     := ''

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', Nil)

    If oJsonData:FromJson(cContent) == Nil
        cApproverCode := oJsonData['ak_cod']

        DbSelectArea("SAK")
        SAK->(DbSetOrder(1))
        SAK->(DbSeek(fwxFilial("SAK")+cApproverCode))

        cViewText := STR0055 //-- "Alterar"
        ALTERA := .T.

        FWMsgRun(, {|| FWExecView (cViewText, "MATA095", MODEL_OPERATION_UPDATE, , , , , aButtons) }, STR0050, STR0051) //-- Aguarde... | Carregando...

        oJsonAction['wasSaved']  := _oJsonSup['wasSaved']
        oJsonAction['isRefresh'] := _oJsonSup['isRefresh']
        oJsonAction['ak_cod']    := SAK->AK_COD
        oJsonAction['ak_nome']   := SAK->AK_NOME
        oJsonAction['ak_login']  := SAK->AK_LOGIN
        oJsonAction['ak_user']   := SAK->AK_USER
        
        oJsonAction['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "MATA095Delete"// -- Excluir Aprovadores
    oJsonData := JsonObject():New()
    oJsonAction := JsonObject():New()

    oJsonAction['isRefresh'] := .F.
    oJsonAction['wasSaved']  := .F.
    _oJsonSup['wasSaved']  := .F.
    _oJsonSup['isRefresh'] := .T.

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', Nil)
    
    If oJsonData:FromJson(cContent) == Nil

        oJsonData:FromJson(cContent)
        cApproverCode := oJsonData['ak_cod']

        DbSelectArea("SAK")
        SAK->(DbSetOrder(1))
        SAK->(DbSeek(fwxFilial("SAK")+cApproverCode))

        cViewText := STR0056 //-- "Excluir"    
        FWMsgRun(, {|| FWExecView (cViewText, "MATA095", MODEL_OPERATION_DELETE, , , , , aButtons) }, STR0050, STR0051) //-- Aguarde... | Carregando...

        oJsonAction['wasSaved'] := _oJsonSup['wasSaved']
        oJsonAction['isRefresh'] := _oJsonSup['isRefresh']
        
        oJsonAction['executionHash'] := oJsonData['executionHash']
    EndIf

    oWebChannel:AdvPLToJS('MATA095ApproverClosed', oJsonAction:ToJson())

    FreeObj(oJsonData)
    FreeObj(oJsonAction)
ElseIf cType == "MATA095View"// -- Visualizar Aprovadores
    oJsonData := JsonObject():New()
    oJsonData:FromJson(cContent)

    DbSelectArea("SAK")
    SAK->(DbSetOrder(1))
    SAK->(DbSeek(fwxFilial("SAK")+oJsonData['ak_cod']))

    FWMsgRun(, {|| FWExecView (cViewText, "MATA095", MODEL_OPERATION_VIEW, , , , , aButtons) }, STR0050, STR0051) //-- Aguarde... | Carregando...
EndIf

Return Nil


/*/{Protheus.doc} addMetric
	Adiciona métrica <cIdMetric> via <FWCustomMetrics>
@author juan.felipe
@since 07/09/2022
@param cRoutine, character, rotina.
@param cSubRoutine, character, sub rotina.
@param cIdMetrice, character, id da métrica.
@param nValue, numeric, valor a ser atribuído a métrica.
@return Nil, nulo.
/*/
Static Function addMetric(cRoutine, cSubRoutine, cIdMetric, nValue)
	Local lOk	    	:= FWLibVersion() >= "20210517" .And. FindClass('FWCustomMetrics')
    Default cRoutine	:= ""
	Default cSubRoutine	:= ""
	Default cIdMetric	:= ""
	Default nValue		:= 1
	
    If lOk
        Do Case
            Case (cIdMetric == "compras-protheus_total-de-acessos-ao-pgc_total")
                FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nValue, /*dDateSend*/, /*nLapTime*/, cRoutine)
            Case (cIdMetric == "compras-protheus_total-de-acessos-as-rotinas-do-pgc")
                FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nValue, /*dDateSend*/, /*nLapTime*/, cRoutine)
        End Case
    EndIf
Return Nil

/*/{Protheus.doc} PG010Saved
	Seta dados do fornecedor gravado na variável estática _oJsonSup
@author juan.felipe
@since 02/2024
@param lWasSaved, loigcal, indica se foi uma ação de gravação.
@param cSupplier, character, código do fornecedor.
@param cStore, character, loja do fornecedor.
@param cSupName, character, nome do fornecedor.
@return Nil, nulo.
/*/
Function PG010Saved(lWasSaved, cSupplier, cStore, cSupName)
    Default lWasSaved := .F.
    Default cSupplier := ''
    Default cStore := ''
    Default cSupName := ''

    _oJsonSup['wasSaved'     ] := lWasSaved
    _oJsonSup['supplierCode' ] := cSupplier
    _oJsonSup['supplierStore'] := cStore
    _oJsonSup['supplierName' ] := cSupName
Return Nil


/*/{Protheus.doc} existsWF7email
Verifica se já existe o e-mail do comprador cadastrado no sistema
@author Renan Martins
@since 05/2024
@param cEmail, string, e-mail do usuário
@param cFileArq, string, nome da caixa de e-mail, por referência
@return lReturn, lógico, se já existe item.
/*/
Function NFCexistsWF7email(cEmail, cFileArq)
    local cAliasQry     := GetNextAlias()
    local lReturn       := .t.
    default cEmail      := ""
    default cFileArq    := ""

    cEmail      := upper(alltrim(cEmail))

    BeginSQL Alias cAliasQry
        SELECT
            WF7_PASTA
        FROM
            %Table:WF7% WF7
        WHERE
            WF7.WF7_FILIAL          = %xFilial:WF7% AND
            upper(WF7.WF7_ENDERE)   = %exp:cEmail% AND
            WF7.WF7_ATIVO           = %exp:'T'% AND
            WF7.%NotDel%
    EndSQL

    if !(cAliasQry)->(Eof())
        lReturn := .f.
        cFileArq := (cAliasQry)->WF7_PASTA
    endif
	(cAliasQry)->(DbCloseArea())

Return lReturn
