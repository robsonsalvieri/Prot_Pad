#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

STATIC _REPORTSERVICE
STATIC _REPORTDD
STATIC _REPORTKEY
STATIC _DELETELAST
STATIC _lDebug := .F.
STATIC _lRecall := .F.
//-------------------------------------------------------------------
/*{Protheus.doc} RU99X12_DATAGRID2(cReport,cDD,cKey)
Function to be called from report to render Angular report on RUSDATAGRID03 component
@param cReport, character, Name of the function where definition will be read
@param cDD , character, Drilldown function
@param cKey , character, name of file where parameters are stored
@param lDelete , logical , use for debugging purposes, when .F., temporary files will not be deleted from database 

@author Rafael Silva
@since 07/07/2020
@version 1.0
*/
Function RU99X1203_DATAGRID3(cReport,cDD,cKey,lDelete)
	_REPORTSERVICE	:=	cReport
	_REPORTKEY		:=	cKey
	_REPORTDD		:=	cDD
	_DELETELAST		:=	iif(lDelete,'1','0')


	 _lRecall := .F.
	FWCALLAPP('rusdatagrid03')
Return _lRecall

//-------------------------------------------------------------------
/*{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Fun??o que pode ser chamada do PO-UI quando dentro do Protheus

@param oWebChannel, object, TWebEngine utilizado para renderizar o PO-UI
@param cType , character, Par?metro de tipo
@param cContent , character, Conteudo passado pelo PO-UI

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Local oJSonResp
	Local cBody 
	Local cColumn 
	Local cGridID 
	Local cDrillDownID
	Local cKey 

	Do Case
	Case cType == "preLoad"
		oJSonResp := JsonObject():New()
		cJsonCompany	:=	'{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
		oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )

		cCode := '[{"key": "reportService", "value":"'+_REPORTSERVICE+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "reportDD", "value":"'+_REPORTDD+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "reportParams", "value":"'+_REPORTKEY+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )
		
		cCode := '[{"key": "deleteAfterLast", "value":"'+_DELETELAST+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "ERPLanguage", "value":"'+Alltrim(FwRetIdiom())+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )
	Case cType == "OpenDoc"
		oJSonResp := JsonObject():New()
		oJSonResp:FromJson(cContent)
		cBody   :=oJSonResp['body']:toJSon()
		cColumn :=oJSonResp['column']
		cGridID :=oJSonResp['gridID']
		cDrillDownID :=oJSonResp['drillDownID']
		cKey :=oJSonResp['key']
		&(_REPORTDD+"('"+cColumn+"','"+cGridID+"','"+cDrillDownID+"','"+cKey+"','"+cBody+"')")
		FreeObj(oJSonResp)
	Case cType == "recallApp"
		 _lRecall := .T.
	EndCase
Return
                   
//Merge Russia R14 

