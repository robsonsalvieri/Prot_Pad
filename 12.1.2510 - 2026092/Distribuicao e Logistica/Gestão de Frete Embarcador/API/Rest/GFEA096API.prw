#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"

WSRESTFUL FreightAccountingBatches DESCRIPTION ('Serviço para consulta e alteração de lotes de provisão do módulo SIGAGFE - GESTÃO DE FRETE EMBARCADOR');
FORMAT "application/json,text/html" 
	
	WSDATA InternalId As CHARACTER
	
	WSDATA Page 	AS INTEGER 		OPTIONAL
    WSDATA PageSize AS INTEGER		OPTIONAL
    WSDATA Order    AS CHARACTER   	OPTIONAL
    WSDATA Fields   AS CHARACTER   	OPTIONAL
	
	WSMETHOD GET v1;
	DESCRIPTION ("Permite a consulta de todos os lotes de provisão cadastrados.");
	WSSYNTAX "/api/gfe/v1/FreightAccountingBatches" ;
    PATH "/api/gfe/v1/FreightAccountingBatches" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj
	
	WSMETHOD GET v1_ID;
	DESCRIPTION ("Retorna apenas um lote de provisão, requerido através da chave do registro (InternalId).");
	WSSYNTAX "/api/gfe/v1/FreightAccountingBatches/{InternalId}";
	PATH "/api/gfe/v1/FreightAccountingBatches/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj	
	
	WSMETHOD PUT v1;
	DESCRIPTION ("Altera a situação do lote de provisão informado através da chave (InternalId).");
	WSSYNTAX "/api/gfe/v1/FreightAccountingBatches/{InternalId}";
	PATH "/api/gfe/v1/FreightAccountingBatches/{InternalId}" ;
	PRODUCES APPLICATION_JSON RESPONSE EaiObj 
	
END WSRESTFUL


WSMETHOD GET v1 QUERYPARAM Page,PageSize,Order,Fields  WSREST FreightAccountingBatches
	Local lRet    				as LOGICAL
	Local oFWFreightAccountingBatch as OBJECT
	Local oJsonfilter   		as OBJECT
	Local aQryParam				as ARRAY
	Local nX					as NUMERIC

	aQryParam 	:= {}	
	lRet 		:= .T. 
	
	oFWFreightAccountingBatch := FWFreightAccountingBatchesAdapter():new()
	oFWFreightAccountingBatch:oEaiObjRec  := FWEaiObj():new()
	
	oJsonfilter := &('JsonObject():New()')
	
	oFWFreightAccountingBatch:oEaiObjRec:setRestMethod('GET')
	
	If !(Empty(self:Page))
        oFWFreightAccountingBatch:oEaiObjRec:setPage(self:Page)
    Else
        oFWFreightAccountingBatch:oEaiObjRec:setPage(1)
    EndIf
	
	If !(Empty(Self:PageSize))
        oFWFreightAccountingBatch:oEaiObjRec:setPageSize(Self:PageSize)
    Else
        oFWFreightAccountingBatch:oEaiObjRec:setPageSize(10)
    EndIf
    
    If !Empty(Self:Order)
        oFWFreightAccountingBatch:oEaiObjRec:setOrder(Self:Order)
    EndIf
    
    If !Empty(Self:Fields)
        oFWFreightAccountingBatch:cSelectedFields := Self:Fields
    EndIf
    
    oFWFreightAccountingBatch:cTipRet := '1' //Tipo de retorno array
    
    For nX := 1 To len(self:aQueryString)
        If !(UPPER(self:aQueryString[nX][1]) == 'PAGESIZE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'PAGE' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'ORDER' .OR.;
         UPPER(self:aQueryString[nX][1]) == 'FIELDS')
            oJsonfilter[self:aQueryString[nX][1]] := self:aQueryString[nX][2]
        EndIf
    Next nX
    
    oFWFreightAccountingBatch:oEaiObjRec:Activate()
    
    oFWFreightAccountingBatch:oEaiObjRec:setFilter(oJsonfilter)
	
	oFWFreightAccountingBatch:lApi := .T.
	oFWFreightAccountingBatch:GetFreightAccountingBatch()
	
	If oFWFreightAccountingBatch:lOk
		If oFWFreightAccountingBatch:cTipRet = '1' // Tipo de retorno array
			::SetResponse(EncodeUTF8(oFWFreightAccountingBatch:oEaiObjSnd:GetJson(,.T.)))
		Else
			::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightAccountingBatch:oEaiObjSn2, .F., .F., .T.)))
		EndIf
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightAccountingBatch:cError ))
        lRet := .F.
    EndIf
	
Return lRet

WSMETHOD GET v1_ID QUERYPARAM Fields PATHPARAM InternalId WSREST FreightAccountingBatches
	Local lRet 					as LOGICAL
	Local oFWFreightAccountingBatch  	as OBJECT
	Local oJsonfilter   		as OBJECT
	
	oJsonfilter := &('JsonObject():New()')

	oFWFreightAccountingBatch := FWFreightAccountingBatchesAdapter():new()
    oFWFreightAccountingBatch:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightAccountingBatch:oEaiObjRec:setRestMethod('GET')  

    If !Empty(Self:Fields)
        oFWFreightAccountingBatch:cSelectedFields := Self:Fields
    EndIf
    
    oFWFreightAccountingBatch:oEaiObjRec:activate()    
    
    oFWFreightAccountingBatch:oEaiObjRec:setPathParam('InternalId',Self:InternalId)
    
    oFWFreightAccountingBatch:cTipRet := '2' //Tipo de retorno Não array

    oFWFreightAccountingBatch:lApi := .T.
    oFWFreightAccountingBatch:GetFreightAccountingBatch()
    
    If oFWFreightAccountingBatch:lOk
    	lRet := oFWFreightAccountingBatch:lOk
    
    	::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightAccountingBatch:oEaiObjSn2, .F., .F., .T.)))
    Else
        SetRestFault(400,EncodeUtf8( oFWFreightAccountingBatch:cError ))
        lRet := .F.
    EndIf

Return lRet

WSMETHOD PUT V1 PATHPARAM InternalId WSREST FreightAccountingBatches
	Local lRet      as LOGICAL
	Local cBody     as CHARACTER
	Local cCodId    as CHARACTER
	
	cBody 	:= ::GetContent()
	lRet 	:= .T.
	
    oFWFreightAccountingBatch := FWFreightAccountingBatchesAdapter():new()
    oFWFreightAccountingBatch:oEaiObjRec := FWEaiObj():new()
    
    oFWFreightAccountingBatch:oEaiObjRec:setRestMethod('PUT')    
    oFWFreightAccountingBatch:oEaiObjRec:activate()
    
    oFWFreightAccountingBatch:oEaiObjRec:SetPathParam('InternalId',Self:InternalId)
    oFWFreightAccountingBatch:oEaiObjRec:loadJson(cBody)
    
    oFWFreightAccountingBatch:cTipRet := '2' //Tipo de retorno Não array 

    oFWFreightAccountingBatch:lApi := .T.
    cCodId := oFWFreightAccountingBatch:UpdateFreightAccountingBatch()

    If oFWFreightAccountingBatch:lOk
        lRet := .T.
		//Realizando o GET do conjunto incluido para gerar a resposta
		oFWFreightAccountingBatch:GetFreightAccountingBatch(cCodId)
		::SetResponse(EncodeUTF8(FWJsonSerialize(oFWFreightAccountingBatch:oEaiObjSn2, .F., .F., .T.)))
    Else
        lRet := .F.
        SetRestFault(400,EncodeUtf8(oFWFreightAccountingBatch:cError))
    EndIf
Return lRet
