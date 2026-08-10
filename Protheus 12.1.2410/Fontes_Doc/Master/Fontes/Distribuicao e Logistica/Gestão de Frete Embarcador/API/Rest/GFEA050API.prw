#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL MANIFEST DESCRIPTION "Serviço especifico inclusão de Romaneio do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR";
    FORMAT "application/json,text/html"

    WSDATA Status AS CHAR
    WSDATA Page AS INTEGER
    WSDATA PageSize AS INTEGER
    WSDATA Id AS CHAR

    WSMETHOD GET  GETLST;
    DESCRIPTION ("Permite a consulta de todos os romaneios cadastrados.");
    WSSYNTAX "/MANIFEST/api/gfe/v1/Manifest";
    PATH "/MANIFEST/api/gfe/v1/Manifest"

    WSMETHOD GET  GETONE;
    DESCRIPTION ("Retorna apenas um romaneio, requerido através da chave do registro (Id), composto pela Filial e Romaneio.");
    WSSYNTAX "/MANIFEST/api/gfe/v1/Manifest/{Id}";
    PATH "/MANIFEST/api/gfe/v1/Manifest/{Id}"

    WSMETHOD PUT PUTROM;
    DESCRIPTION ("Altera o romaneio informado através da chave (ManifestNumber).");
    WSSYNTAX "/MANIFEST/api/gfe/v1/Manifest";
    PATH "/MANIFEST/api/gfe/v1/Manifest"

    WSMETHOD POST POSTROM ;
    DESCRIPTION ("Inclui um novo romaneio. É possível incluir um documento de carga também.");
    WSSYNTAX "/MANIFEST/api/gfe/v1/Manifest";
    PATH "/MANIFEST/api/gfe/v1/Manifest"

END WSRESTFUL

WSMETHOD PUT PUTROM WSSERVICE MANIFEST
    Local aRet      := {}
    Local oContent  := jSonObject():New()
    Local lRet      := .T.
    
    ::SetContentType("application/json")

    oContent:FromJson(Self:GetContent())
    aNames := oContent:getNames()

    aRet := GFE050IGRV(.T., oContent, aNames)

    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        lRet := .F.
        SetRestFault(aRet[2], EncodeUTF8(aRet[3]))
    EndIf

Return lRet

WSMETHOD POST POSTROM WSSERVICE MANIFEST
    Local aRet      := {}
    Local oContent  := jSonObject():New()
    Local lRet      := .T.

    ::SetContentType("application/json")

    oContent:FromJson(Self:GetContent())
    aNames := oContent:getNames()

    aRet := GFE050IGRV(.F., oContent, aNames)

    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        lRet := .F.
        SetRestFault(aRet[2], EncodeUTF8(aRet[3]))
    EndIf

Return lRet

WSMETHOD GET GETONE PATHPARAM Id WSSERVICE MANIFEST //Retorna todos
    Local aRet  := {}

    Default cId := ''

    ::SetContentType("application/json")

    cId := ::Id

    aRet := GFE050QRY(cId, {})

    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        ::SetStatus(aRet[2])
        ::SetResponse(EncodeUTF8(aRet[3]))
    EndIf

Return .T.

WSMETHOD GET GETLST QUERYPARAM Status, Page, PageSize WSSERVICE MANIFEST //Retorna todos
    Local nPage as numeric
    Local nPageSize as numeric
    Local aRet := {}
    
    Default ::Status = ''
    Default ::Page = 1
    Default ::PageSize = 10
    ::SetContentType("application/json")

    nPage := (::Page - 1) * ::PageSize
    nPageSize := ::PageSize
    cStatus := ::Status

    aRet := GFE050QRY('',{cStatus, nPage, nPageSize})

    If aRet[1]
        ::SetResponse(EncodeUTF8(aRet[3]))
    Else
        ::SetStatus(aRet[2])
        ::SetResponse(EncodeUTF8(aRet[3]))
    EndIf

Return .T.
