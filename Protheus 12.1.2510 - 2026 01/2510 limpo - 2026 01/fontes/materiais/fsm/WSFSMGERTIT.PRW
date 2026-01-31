#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGeraTitDesp
    WebService REST para Geração de Títulos de Pagamento de Despesas
    Descrição: WS para geração automática de títulos financeiros a partir de despesas
    @since 18/01/2024   
    @version 1.0
    @author Silas Gomes
/*/
//-------------------------------------------------------------------

WSRESTFUL FSMGERATIT DESCRIPTION "WebService para Geração de Títulos de Pagamento de Despesas" 
    WSMETHOD POST generateTitle DESCRIPTION 'Gera título financeiro para pagamento de despesa' PATH "generateTitle" PRODUCES APPLICATION_JSON
END WSRESTFUL

//-------------------------------------------------------------------
WSMETHOD POST generateTitle WSREST FSMGERATIT

    Local aCodDesp    as array
    Local cBody       as character
    Local cCodigoDesp as character
    Local cCodRet     as character
    Local cDtVenc     as character
    Local cDtBase     as character
    Local cMsgRet     as character
    Local lAgrupar    as logical
    Local lRet        as logical
    Local oRequest    as object
    Local oResponse   as object

    aCodDesp    := {}
    cBody       := Self:GetContent()
    cCodigoDesp := ''
    cCodRet     := ''
    cDtVenc     := ''
    cDtBase     := ''
    cMsgRet     := ''
    lAgrupar    := .T.
    lRet        := .T.
    oRequest    := JsonObject():New()
    oResponse   := JsonObject():New()
    
    Private lMsErroAuto := .F.
    
    If Empty(cBody)
        SetRestFault(400, EncodeUtf8('Corpo da requisição não informado'))
        Return .F.
    EndIf
    
    BEGIN SEQUENCE
        oRequest:fromJson(cBody)
    RECOVER
        SetRestFault(400, EncodeUtf8('Erro na leitura do JSON. Verifique o formato.'))
        Return .F.
    END SEQUENCE
   
    cCodigoDesp := AllTrim(oRequest['codigoDespesa'])
    
    If !Empty(cCodigoDesp)
        aAdd(aCodDesp, cCodigoDesp)
    Else
        If !Empty(oRequest['codigoDespesas'])
            aCodDesp := oRequest['codigoDespesas']
        Else
            SetRestFault(400, EncodeUtf8('Código da despesa não informado'))
            Return .F.
        EndIf
    EndIf
    
    cDtVenc := AllTrim(oRequest['dataVencimento'])
    cDtBase := AllTrim(oRequest['dataBase'])
    
    lAgrupar := oRequest['agrupar']
    
    lRet := GeraTit(aCodDesp, @cMsgRet, @cCodRet, cDtVenc, cDtBase, lAgrupar)
    
    oResponse['message'] := EncodeUtf8(cMsgRet)
    
    Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
    
    If lRet
        Self:SetStatus(201)  // Created
    Else
        Self:SetStatus(400)  // Bad Request
    EndIf
    
    // Limpeza
    oResponse := Nil
    oRequest  := Nil
    
Return lRet
