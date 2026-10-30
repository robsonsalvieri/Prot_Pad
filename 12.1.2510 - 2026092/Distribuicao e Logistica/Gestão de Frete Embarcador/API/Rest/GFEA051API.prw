#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL CARGODELIVERY DESCRIPTION "Serviço para realizar o registro das entregas de trecho pagos e não pagos do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR";
FORMAT "application/json,text/html"
//FORMAT APPLICATION_JSON
 
    WSDATA DeliveryDate AS CHAR
    WSDATA Page AS INTEGER 
    WSDATA PageSize AS INTEGER
    WSDATA Id AS CHAR
 
 
    WSMETHOD GET  GETLST;
    DESCRIPTION ("Permite a consulta de todos os trechos das notas fiscais.");
    WSSYNTAX "/CARGODELIVERY/api/gfe/v1/CargoDelivery";
    PATH "/CARGODELIVERY/api/gfe/v1/CargoDelivery"
    //PRODUCES APPLICATION_JSON RESPONSE EaiObj

    WSMETHOD GET  GETONE;
    DESCRIPTION ("Retorna apenas um trecho, requerido através da chave do registro (Id), composto pela chave DANFE e o trecho.");
    WSSYNTAX "/CARGODELIVERY/api/gfe/v1/CargoDelivery/{Id}";
    PATH "/CARGODELIVERY/api/gfe/v1/CargoDelivery/{Id}"
    //PRODUCES APPLICATION_JSON RESPONSE EaiObj

    WSMETHOD PUT PUTENT;
    DESCRIPTION ("Permite a inclusão e cancelamento das entregas. ");
    WSSYNTAX "/CARGODELIVERY/api/gfe/v1/CargoDelivery/";
    PATH "/CARGODELIVERY/api/gfe/v1/CargoDelivery/"
    //PRODUCES APPLICATION_JSON RESPONSE EaiObj

END WSRESTFUL

WSMETHOD PUT PUTENT WSSERVICE CARGODELIVERY
    Local cId as character
    Local aRet := {}
    Local oContent := jSonObject():New()
    Default cId := ''
    ::SetContentType("application/json")

    oContent:FromJson(Self:GetContent())
    aNames := oContent:getNames()

    aRet := GFE51REST(.t., oContent, aNames)
    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        lRet := .F.
        ::SetResponse(EncodeUTF8(aRet[3]))
    EndIf          

Return .T.


WSMETHOD GET GETONE PATHPARAM Id WSSERVICE CARGODELIVERY //Retorna todos
    Local cId as character
    Local aRet := {}
    Default cId = ''
    ::SetContentType("application/json")

    cId := ::Id

    aRet := GFE51Query(cId, {})
    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))        
    Else
        ::SetStatus(aRet[2])
        ::SetResponse(EncodeUTF8(aRet[3]))
    EndIf

Return .T.

WSMETHOD GET GETLST QUERYPARAM DeliveryDate, Page, PageSize WSSERVICE CARGODELIVERY //Retorna todos
    Local nPage as numeric
    Local nPageSize as numeric
    Local cDeliveryDate as character
    Local aRet := {}
    //Default ::DeliveryDate = 0
    Default ::DeliveryDate = ''
    Default ::Page = 1
    Default ::PageSize = 10
    ::SetContentType("application/json")

    nPage := (::Page - 1) * ::PageSize
    nPageSize := ::PageSize
    cDeliveryDate := ::DeliveryDate

    aRet := GFE51Query('',{cDeliveryDate, nPage, nPageSize})
    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        ::SetStatus(aRet[2])
        ::SetResponse(EncodeUTF8(aRet[3]))
    EndIf

Return .T.
