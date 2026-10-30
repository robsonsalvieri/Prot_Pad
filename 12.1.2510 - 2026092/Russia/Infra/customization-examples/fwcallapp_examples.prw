#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

STATIC _REPORTKEY

//-------------------------------------------------------------------
/*{Protheus.doc} U_FWAPP01
Function to be called from report to render Angular report on RUSDATAGRID01 component
@author Rafael Silva
@since 07/07/2020
@version 1.0
*/
Function U_FWAPP01()
	_REPORTKEY		:=	'list1'

   nOpc := Aviso('Select report example','Select one the options below to use report',{'List','Client grouped',"List with summary"},3)
   if nOpc == 1
      _REPORTKEY := 'list'
   Elseif nOpc == 2
      _REPORTKEY := 'grouped'
   Elseif nOpc == 1
      _REPORTKEY := 'list1'
   Endif
   //Name of APP muste be exactky the same as the source qhere is called.
	FWCALLAPP('fwcallapp_examples')
Return

//-------------------------------------------------------------------
/*{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
This function is the link between angular APP amd MA-3. Below is implemented the opcion OnLoad, that it is called when angular APP is opened

Information is sent to app, so it knows were to get information from to render report

@param oWebChannel, object, TWebEngine utilizado para renderizar o PO-UI
@param cType , character, Par?metro de tipo
@param cContent , character, Conteudo passado pelo PO-UI

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Local cJsonCompany
   Do Case
	Case cType == "preLoad"
		oJSonResp := JsonObject():New()
		cJsonCompany	:=	'{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
		oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )

		cCode := '[{"key": "reportParams", "value":"'+_REPORTKEY+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "ERPLanguage", "value":"'+Alltrim(FwRetIdiom())+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )
	EndCase
Return


/*/{Protheus.doc} U_FWCALLAPPEXAMPLE
REST WEB SERVICE responsible for communicating with angular APP
@type function
@author Bruno Sobieski
@since 7/7/2021
@return variant, return_description
/*/
WSRESTFUL U_FWCALLAPPEXAMPLE DESCRIPTION 'Service playgrond for interacting with FWCALLP-examples'
	WSDATA pageSize					As Number
	WSDATA page							As Number
	WSDATA locale						As character
	WSMETHOD GET GETREPDEF ;
		DESCRIPTION 'Get report parameters' ;
		WSSYNTAX "GETREPDEF/{key}" ;
		PATH "GETREPDEF/{key}"

	WSMETHOD GET GETDATA ;
		DESCRIPTION 'Get data for report';
		WSSYNTAX "GETDATA/{key}" ;
		PATH "GETDATA/{key}"
END WSRESTFUL

WSMETHOD GET GETREPDEF  WSSERVICE U_FWCALLAPPEXAMPLE
	Local lRet	:=	.T.
	Local cResponse:=""

	If ::locale <> nil
		fwSetidiom(::locale)
	Endif
	::SetContentType("application/json; charset=UTF-8")
	If Len(::aURLParms) <> 2
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+"Incorrect parameter count"+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n("#1 parameters expected, received #2",{'2',Alltrim(str(Len(::aURLParms)))})+'"'+; //
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
		cResponse:=	GETDefs(::aURLParms[2])
      
      cResponse :=  '{"data": { "dxDataGridOptions": '+cResponse+", "+;
                                    ' "key": "'+::aURLParms[2]+'",'+;
                   ' "mainTitle": "'+IIf(::aURLParms[2]=="list","Simple list",IIf(::aURLParms[2]=="list1","Simple list with summaries in grouping and totals","Simple list with client grouped from beginning"))+'" },'+;
         ' "status": "ok",'+;
         ' "ok": "ok",'+;
         ' "statusText": "ok"}'
  		::SetResponse(EncodeUTF8(cResponse))
   Endif
Return .T.

WSMETHOD GET GETDATA  WSSERVICE U_FWCALLAPPEXAMPLE
	Local lRet	:=	.T.
	Local cResponse:=""
   DEFAULT ::page       := '1'
   DEFAULT ::pageSize   := '500'
	If ::locale <> nil
		fwSetidiom(::locale)
	Endif
	::SetContentType("application/json; charset=UTF-8")
	If Len(::aURLParms) <> 2
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+"Incorrect parameter count"+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n("#1 parameters expected, received #2",{'2',Alltrim(str(Len(::aURLParms)))})+'"'+; //
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
		cResponse:=	GETDATA(::aURLParms[2],val(::page),val(::pageSize))
			If Len(cResponse) >2
      		cResponse := '{"data":'+cResponse+","+;
				'"status": "ok",'+;
				'"ok": "ok",'+;
				'"statusText":"ok"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
		Else
			cResponse := '{'+;
				'"type": "warning",'+;
				'"code": "591",'+;
				'"message":"'+"Query returned no data"+'",'+; //
				'"detailedMessage": "'+"Query returned no data"+'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
		Endif
	Endif
Return lRet

/*/{Protheus.doc} GetDefs
Function the returns definitons for report
@type function
@author Bruno Sobieski
@since 7/7/2021
@param cKey, character, Key that defines which definition was requested
@return variant, return_description
/*/
Static Function GetDefs(cKey)
Local oJson := GetDxModel('main')
Local oSummary := GetDxModel('summary')

Do Case
case cKey == "list1" .or. cKey == "grouped"  .or. cKey == "list" 

   oCol := GetDxModel('columns')
   oCol['dataField'] := 'ID'
   oCol['caption']   := 'ID'
   oCol['dataType']  := 'number'
   oCol['visible']   := .F.
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)


   oCol := GetDxModel('columns')
   oCol['dataField'] := 'client'
   oCol['caption']   := 'Client'
   oCol['dataType']  := 'string'
   If cKey == "grouped" 
      oCol['groupIndex']  := 1
   Endif
   oCol['visible']   := .T.
   oCol['allowGrouping']   := .T.
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)

   oCol := GetDxModel('columns')
   oCol['dataField'] := 'orderNumber'
   oCol['caption']   := 'Order Number'
   oCol['dataType']  := 'string'
   oCol['visible']   := .T.
   oCol['allowGrouping']   := .T.
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)

   oCol := GetDxModel('columns')
   oCol['dataField'] := 'orderDate'
   oCol['caption']   := 'Order Date'
   oCol['dataType']  := 'date'
   oCol['format']  := 'longDate'
   oCol['visible']   := .T.
   oCol['allowGrouping']   := .T.
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)

   oCol := GetDxModel('columns')
   oCol['dataField'] := 'totalValue'
   oCol['caption']   := 'Total Value'
   oCol['dataType']  := 'number'
   oCol['visible']   := .T.
   oCol['format']  := 'currency'
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)
   oCol := GetDxModel('columns')
   oCol['dataField'] := 'status'
   oCol['caption']   := 'status'
   oCol['dataType']  := 'string'
   oCol['encodeHtml']   := .F. //(data on this column will be sent in icons //<i class="dx-icon-email"></i>)
   oCol['visible']   := .T.
   oCol['width'] := '30px'
   oCol['allowGrouping']   := .T.
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)
   If cKey == "list1"
      aadd(oSummary['groupItems'],GetDxModel('groupItems'))
      oSummary['groupItems'][Len(oSummary['groupItems'])]['column'] := 'totalValue'
      oSummary['groupItems'][Len(oSummary['groupItems'])]['alignByColumn']   := .T.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['showInGroupFooter'] := .F.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['summaryType'] := 'sum'
      oSummary['groupItems'][Len(oSummary['groupItems'])]['valueFormat']  := 'currency'

      aadd(oSummary['groupItems'],GetDxModel('groupItems'))
      oSummary['groupItems'][Len(oSummary['groupItems'])]['column'] := 'orderNumber'
      oSummary['groupItems'][Len(oSummary['groupItems'])]['alignByColumn']   := .T.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['showInGroupFooter'] := .F.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['summaryType'] := 'count'

      aadd(oSummary['groupItems'],GetDxModel('groupItems'))
      oSummary['groupItems'][Len(oSummary['groupItems'])]['column'] := 'status'
      oSummary['groupItems'][Len(oSummary['groupItems'])]['alignByColumn']   := .T.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['showInGroupFooter'] := .F.
      oSummary['groupItems'][Len(oSummary['groupItems'])]['summaryType'] := 'count'

      aadd(oSummary['totalItems'],GetDxModel('totalItems'))
      oSummary['totalItems'][Len(oSummary['totalItems'])]['column'] := 'totalValue'
      oSummary['totalItems'][Len(oSummary['totalItems'])]['summaryType'] := 'sum'
      oSummary['totalItems'][Len(oSummary['totalItems'])]['valueFormat']  := 'currency'

      aadd(oSummary['totalItems'],GetDxModel('totalItems'))
      oSummary['totalItems'][Len(oSummary['totalItems'])]['column'] := 'orderNumber'
      oSummary['totalItems'][Len(oSummary['totalItems'])]['summaryType'] := 'count'

      oJson['summary']  := oSummary
      FreeObj(oSummary)
   Endif
   oJson['stateStoring']['enabled']  := .F.

   oJson['pager']['allowedPageSizes'] :=  {'100','250','500'}

   oJson['paging']['pageSize'] := 100

  /*
	oSummary['alignByColumn'] 			:= .F.
	oSummary['column'] 					:= Nil
	oSummary['displayFormat'] 			:= Nil
	oSummary['showInColumn'] 			:= Nil
	oSummary['showInGroupFooter'] 		:= .F.
	oSummary['skipEmptyValues'] 			:= Nil
	oSummary['summaryType'] 			:= Nil
	oSummary['valueFormat'] 			:= Nil
   */
EndCase

Return oJson:toJson()
/*/{Protheus.doc} GetData
Function that returns data requested according to key
@type function
@author Bruno Sobieski
@since 7/7/2021
@param cKey, character, Key that defines which data will be returned
@param nPage, numeric, Page number
@param nPageSize, numeric, Size of the page
@return variant, return_description
/*/
static Function GetData(cKey,nPage,nPageSize)
Local cRet  := ""
Local oJsonItem  := JsonObject():New()
Local nX
Local aStatus := {"dx-icon-isblank","dx-icon-isnotblank"}
Local nStart := 1
Local nTotItems := 2511
Default nPage := 1
Default nPageSize := 200
DEFAULT cKey   := "list1"

nStart:= ((nPage-1) * nPageSize) + 1

Do Case
case cKey == "list1" .Or. cKey =="grouped" .or. cKey == "list"
   For nX:= nStart to Min(nTotItems,(nStart+nPageSize-1))
      oJsonItem  := JsonObject():New()
      oJsonItem['ID'] := nX
      oJsonItem['status'] := '<i class="'+aStatus[Randomize(1,3)]+'"></i>'
      oJsonItem['client'] := StrZero(Randomize(1000,1030),6)
      oJsonItem['orderNumber'] := StrZero(nX+200,6)
      oJsonItem['orderDate'] := MsDate() - Randomize(1,50)
      oJsonItem['totalValue'] := Randomize(50000,8000000) /100
//      aadd(oJson,oJsonItem)
      cRet += ","+oJsonItem:toJson()
      FreeObj(oJsonItem)
   Next
EndCase

cRet:=	'{   "hasNext": '+iif((nPage * nPageSize) < nTotItems,'true','false')+','+;
   			 '"count": '+STR(nX-nStart)+','+;
   			 '"total": '+STR(nTotItems)+','+;
				 '"items": ['+Substr(cRet,2)+"]"+;
				 '}'

Return cRet

