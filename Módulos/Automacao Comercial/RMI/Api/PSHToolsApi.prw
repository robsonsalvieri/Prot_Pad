#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para consulta de Produtos do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL ApiMonitor DESCRIPTION "API para consulta de logs Smar-Hub-Protheus" FORMAT "application/json,text/html"    //

    WSDATA Fields       as Charecter    Optional
    WSDATA Page         as Integer 	    Optional
    WSDATA PageSize     as Integer		Optional
    WSDATA Order    	as Character   	Optional

    WSMETHOD GET Items;
        DESCRIPTION "Retorna uma lista com todos os logs";    
        PATH "/api/v1/apimonitor";
        WSSYNTAX "/api/v1/apimonitor/{Order, Page, PageSize, Fields}";
        PRODUCES APPLICATION_JSON
    
    WSMETHOD DELETE Items;
        DESCRIPTION "Delete uma lista com todos os logs";
        PATH '/api/v1/apimonitor';
        WSSYNTAX "/api/v1/apimonitor/{id}";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com todos os Produtos
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET Items QUERYPARAM Fields, Page, PageSize, Order WSREST ApiMonitor

    Local lRet         As Logical
    Local oAPIMonitor  As Object

    oAPIMonitor := SHPApiMonitorObj():New(self)
    oAPIMonitor:Get()
    
    If oAPIMonitor:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oAPIMonitor:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oAPIMonitor:GetError() ) )
    EndIf

    FwFreeObj(oAPIMonitor)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com todos os Produtos
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE Items PATHPARAM id WSREST ApiMonitor

    Local lRet         As Logical
    Local oAPIMonitor  As Object
    Local oResponse    As Object
    
    oAPIMonitor := SHPApiMonitorObj():New(self)
    oAPIMonitor:Delete(self:GetContent())
    
    If oAPIMonitor:Success()
        lRet := .T.
        oResponse = JsonObject():New()
        oResponse['response'] := 'OK'
        self:SetResponse( EncodeUtf8(FwJsonSerialize( oResponse, .T. )) )
    EndIf

    FwFreeObj(oAPIMonitor)

Return lRet
