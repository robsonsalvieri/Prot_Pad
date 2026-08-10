#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RMIPUBLICACAOAPI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}
    API para acesso a Publicações do Varejo
/*/
//-------------------------------------------------------------------
WSRESTFUL RmiPublicacao DESCRIPTION STR0001 FORMAT "application/json,text/html"     //"API para acesso a Publicações do Varejo"

    WSDATA AssinanteProcesso    As Character
    WSDATA Assinante            As Character
    WSDATA Fields               As Character    Optional
    WSDATA Page                 As Integer 	    Optional
    WSDATA PageSize             As Integer		Optional        
    WSDATA Order    	        As Character   	Optional

    WSMETHOD GET ;
        DESCRIPTION STR0002;   //"Retorna uma lista com as Publicações disponibilizadas para um Assinante|Processo (MHR_CASSIN|MHR_CPROCE)"
        PATH "/api/retail/v1/RmiPublicacao/{AssinanteProcesso}";
        WSSYNTAX "/api/retail/v1/RmiPublicacao/{AssinanteProcesso, Fields, Page, PageSize, Order}";
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT ;
        DESCRIPTION STR0003; //"Atualiza as Distribuições a partir do Assinante (MHR_CASSIN) e uma lista Distribuições"
        PATH "/api/retail/v1/RmiPublicacao/{Assinante}";
        WSSYNTAX "/api/retail/v1/RmiPublicacao/{Assinante}";
        PRODUCES APPLICATION_JSON 

    WSMETHOD POST ;
        DESCRIPTION STR0004;    //"Inclui uma Publicação"
        PATH     "/api/retail/v1/RmiPublicacao";        
        WSSYNTAX "/api/retail/v1/RmiPublicacao";
        PRODUCES APPLICATION_JSON     

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}
Retorna uma lista com as publicações a partir do AssinanteProcesso (MHR_CASSIN|MHR_CPROCE)

@param AssinanteProcesso - Código do Assinante|Processo (MHR_CASSIN|MHR_CPROCE)

@author  Everson S P Junior
@since   05/12/2019
@version 2.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET PATHPARAM AssinanteProcesso QUERYPARAM Fields, Page, PageSize, Order WSREST RmiPublicacao

    Local lRet              As Logical
    Local oRmiPublicacao    As Object

    oRmiPublicacao := RmiPublicacaoObj():New(self)
    oRmiPublicacao:Get()
    
    If oRmiPublicacao:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRmiPublicacao:GetReturn() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRmiPublicacao:GetError() ) )
    EndIf

    FwFreeObj(oRmiPublicacao)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Atualiza as publicações a partir do Assinante (MHR_CASSIN) e uma lista Publicações

@param Assinante - Identificador Assinante|Processos

@author  Danilo Santos
@since   11/12/2019
@version 2.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT PATHPARAM Assinante WSREST RmiPublicacao

    Local lRet              As Logical
    Local oRmiPublicacao    As Object
    Local cBody             As Character 
    Local cInternal         As Character
    Local oEaiObj           As Object
    
    cInternal   := self:Assinante
    cBody       := self:GetContent()
    cBody       := UPPER(cBody)
    oEaiObj     := JsonObject():New()
    oEaiObj:FromJson(cBody)
    
    oRmiPublicacao := RmiPublicacaoObj():New(self) 
    oRmiPublicacao:Alter(cInternal,oEaiObj)
    
    If oRmiPublicacao:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oEaiObj:ToJson() ) )
    Else
        lRet := .F.
        SetRestFault(404, EncodeUtf8( oRmiPublicacao:GetError() ) )
    EndIf

    FwFreeObj(oRmiPublicacao)
    FwFreeObj(oEaiObj)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}
Inclui uma Publicação

@return lRet - Informa se o processo foi executado com sucesso
@author
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSREST RmiPublicacao

    Local lRet             As Logical
    Local oRmiPublicacao   As Object
         
    oRmiPublicacao := RmiPublicacaoObj():New(self)
    oRmiPublicacao:Post()   

    If oRmiPublicacao:Success()
        lRet := .T.
        self:SetResponse( EncodeUtf8( oRmiPublicacao:cBody ) )
    Else
        lRet := .F.        
        SetRestFault( oRmiPublicacao:GetStatus(), EncodeUtf8( oRmiPublicacao:GetError() ) )
    EndIf

    FwFreeObj(oRmiPublicacao)

Return lRet