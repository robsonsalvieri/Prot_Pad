#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL FreightInvoices DESCRIPTION ('Serviço para consulta e alteração de faturas de frete do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
    WSMETHOD GET v1;
	DESCRIPTION ("Permite a consulta de todos as faturas de frete cadastrados.");
	WSSYNTAX "/api/gfe/v1/FreightInvoices";
    PATH "/api/gfe/v1/FreightInvoices" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET v1_ID;
	DESCRIPTION ("Retorna apenas uma fatura de frete, requerido através da chave do registro (InternalId).");
    WSSYNTAX "/api/gfe/v1/FreightInvoices/{InternalId}";
	PATH "/api/gfe/v1/FreightInvoices/{InternalId}" ;
    PRODUCES APPLICATION_JSON RESPONSE EaiObj	
	
//	WSMETHOD POST v1;
//	DESCRIPTION ("Inclui uma nova fatura de frete.");
//	PATH "/api/agr/v1/Teste123" ;
//	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD PUT v1;
	DESCRIPTION ("Altera a situação de uma fatura de frete.");
    WSSYNTAX "/api/gfe/v1/FreightInvoices/{InternalId}";
	PATH "/api/gfe/v1/FreightInvoices/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
//  WSMETHOD DELETE v1;
//	DESCRIPTION ("Exclui uma fatura de frete.");
//	PATH "/api/agr/v1/Teste123/{InternalId}" ;
//	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
END WSRESTFUL


WSMETHOD GET v1 QUERYPARAM Page,PageSize,Order,Fields  WSREST FreightInvoices
	Local lRet    				as LOGICAL
	Local oFWFreightInvoice 	as OBJECT
	Local oJsonfilter   		as OBJECT
	Local aQryParam				as ARRAY
	Local nX					as NUMERIC

	aQryParam 	:= {}	
	lRet 		:= .T. 

	oFWFreightInvoice := FWFreightInvoicesAdapter():new()
	oFWFreightInvoice:oEaiObjRec  := FWEaiObj():new()

	oJsonfilter := &('JsonObject():New()')

	oFWFreightInvoice:oEaiObjRec:setRestMethod('GET')

	If !(Empty(self:Page))
        oFWFreightInvoice:oEaiObjRec:setPage(self:Page)
    Else
        oFWFreightInvoice:oEaiObjRec:setPage(1)
    EndIf

	If !(Empty(Self:PageSize))
        oFWFreightInvoice:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWFreightInvoice:oEaiObjRec:setPageSize(10)
    EndIf

    If !Empty(Self:Order)
        oFWFreightInvoice:oEaiObjRec:setOrder(Self:Order)
    EndIf

    If !Empty(Self:Fields)
        oFWFreightInvoice:cSelectedFields := Self:Fields
    EndIf

    oFWFreightInvoice:cTipRet := '1' //Tipo de retorno array

    For nX := 1 To Len(self:aQueryString)
        If !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR. UPPER(self:aQueryString[nX][1]) == 'PAGE' ;
                                                           .OR. UPPER(self:aQueryString[nX][1]) == 'ORDER' ;
                                                           .OR. UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    Next nX

    oFWFreightInvoice:oEaiObjRec:Activate()

    oFWFreightInvoice:oEaiObjRec:setFilter(oJsonfilter)

	oFWFreightInvoice:lApi := .T.
	oFWFreightInvoice:GetFreightInvoice()

	If oFWFreightInvoice:lOk
		If oFWFreightInvoice:cTipRet = '1'
			::SetResponse(EncodeUTF8(oFWFreightInvoice:oEaiObjSnd:GetJson(,.T.)))
		Else
			::SetResponse(EncodeUTF8(oFWFreightInvoice:oEaiObjSn2:GetJson(,.T.)))
		EndIf
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightInvoice:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD GET v1_ID QUERYPARAM Fields PATHPARAM InternalId WSREST FreightInvoices
	Local lRet 					as LOGICAL
	Local oFWFreightInvoice  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWFreightInvoice := FWFreightInvoicesAdapter():new()
    oFWFreightInvoice:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightInvoice:oEaiObjRec:setRestMethod('GET')  

    If !empty(Self:Fields)
        oFWFreightInvoice:cSelectedFields := Self:Fields
    endIf
    
    oFWFreightInvoice:oEaiObjRec:activate()    
    
    oFWFreightInvoice:oEaiObjRec:setPathParam('InternalId',Self:InternalId)
    
    oFWFreightInvoice:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightInvoice:lApi := .T.
    oFWFreightInvoice:GetFreightInvoice()
    
    if oFWFreightInvoice:lOk
    	lRet := oFWFreightInvoice:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightInvoice:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWFreightInvoice:oEaiObjSnd:GetJson(1,.F.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightInvoice:cError ))
        lRet := .F.
    EndIf

Return lRet


/*WSMETHOD POST V1 WSREST FreightInvoices
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	Local oRequest 	as OBJECT
	
	cBody := ::GetContent()
	
    oFWFreightInvoice := FWFreightInvoicesAdapter():new()
    oFWFreightInvoice:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightInvoice:oEaiObjRec:setRestMethod('POST')
    
    oFWFreightInvoice:oEaiObjRec:activate()

    oFWFreightInvoice:oEaiObjRec:loadJson(cBody)
    
    oFWFreightInvoice:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightInvoice:lApi := .T.
    cCodId := oFWFreightInvoice:IncludeFreightInvoices()

    If oFWFreightInvoice:lOk
        lRet := .T.
        
        //Realizando o GET da fatura de frete incluida para gerar a resposta
        oFWFreightInvoice:GetFreightInvoice(cCodId)
        ::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightInvoice:oEaiObjSn2, .F., .F., .T.)))
        //::SetResponse(EncodeUtf8(oFWFreightInvoice:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWFreightInvoice:cError))
    EndIf

Return lRet
*/


WSMETHOD PUT V1 PATHPARAM InternalId WSREST FreightInvoices
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWFreightInvoice := FWFreightInvoicesAdapter():new()
    oFWFreightInvoice:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightInvoice:oEaiObjRec:setRestMethod('PUT')    
    oFWFreightInvoice:oEaiObjRec:activate()
    
    oFWFreightInvoice:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWFreightInvoice:oEaiObjRec:loadJson(cBody)
    
    oFWFreightInvoice:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightInvoice:lApi := .T.
    cCodId := oFWFreightInvoice:UpdateFreightInvoices()

    If oFWFreightInvoice:lOk
        lRet := .T.
		//Realizando o GET do conjunto incluido para gerar a resposta
		oFWFreightInvoice:GetFreightInvoice(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightInvoice:oEaiObjSn2, .F., .F., .T.)))
		//::SetResponse(EncodeUtf8(oFWFreightInvoice:oEaiObjSnd:getJson(1,.F.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWFreightInvoice:cError))
    EndIf
Return lRet
