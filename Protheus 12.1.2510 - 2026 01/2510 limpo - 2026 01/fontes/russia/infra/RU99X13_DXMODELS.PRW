#INCLUDE "TOTVS.CH"
#INCLUDE "RU99X13_DXMODELS.CH"

Function GetDxModel(cModel)

	Local oRet := JsonObject():New()

	Do Case
	case cModel == 'main'
		oRet['modelId'] 					:= ""
		oRet['columns'] 					:= {} //JsonObject():New()
		oRet['hoverStateEnabled'] 		:= .T.
		oRet['allowColumnResizing'] 	:= .T.
		oRet['allowColumnReordering']	:= .T.
		oRet['columnAutoWidth'] 		:= .T.
		oRet['columnChooser']			:=  GetDxModel('columnChooser')
        oRet['columnFixing']				:=  GetDxModel('columnFixing')
		oRet['columnHidingEnabled'] 	:= .T.
		oRet['columnResizingMode'] 	:= Nil
		oRet['hint'] 						:= Nil
		oRet['export'] 					:= GetDxModel('export')
		oRet['filterPanel'] 				:= GetDxModel('filterPanel')
		oRet['filterRow'] 				:= GetDxModel('filterRow')
		oRet['focusStateEnabled'] 		:= .T.
		oRet['grouping'] 					:= GetDxModel('grouping')
		oRet['groupPanel'] 				:= GetDxModel('groupPanel')
		oRet['headerFilter'] 			:= GetDxModel('headerFilter')
		oRet['height'] 					:= '90vh'
		oRet['pager']					  	:= GetDxModel('pager')
        oRet['paging']					  	:= GetDxModel('paging')
		oRet['rowAlternationEnabled']	:= .T.
		oRet['scrolling'] 				:= GetDxModel('scrolling')
		oRet['searchPanel'] 				:= GetDxModel('searchPanel')
		oRet['showBorders']				:= .T.
		oRet['showRowLines'] 			:= .T.
		oRet['showColumnLines'] 		:= .T.
		oRet['showColumnHeaders'] 		:= .T.
		oRet['sorting'] 					:= GetDxModel('sorting')
		oRet['sortByGroupSummaryInfo'] := {}
		oRet['stateStoring'] 			:= GetDxModel('stateStoring')
		oRet['width'] 						:=	'99vw'
		oRet['wordWrapEnabled'] 		:= .F.

		oRet['masterDetail'] 			:= Nil
		oRet['summary'] 					:= nil
		oRet['drillDownLinks'] 			:= {} //JsonObject():New()
/*
      [summary]="dxSetup.summary"
*/
	case cModel == 'drillDownLink'
		oRet['callerGridId'] 		:= ""
		oRet['callerGridColumn']	:= "*"
		oRet['drillDownGridId'] 	:= ""
	case cModel == 'summary'
		oRet['groupItems'] 				:= {}
		oRet['totalItems'] 				:= {}
		oRet['skipEmptyValues'] 		:= .T.
		oRet['visible'] 					:= .F.
		oRet['wordWrapEnabled'] 		:= .T.
		oRet['width'] 						:= Nil
		oRet['texts'] 						:=  GetDxModel('summaryTexts') 
	case cModel == 'summaryTexts'
		oRet['sum'] 				:= STR0001
		oRet['count'] 				:= STR0002
		oRet['avg'] 				:= STR0003
		oRet['max'] 				:= STR0004
		oRet['min'] 				:= STR0005
		oRet['sumOtherColumn'] := STR0006
		oRet['countOtherColumn']:=STR0007
		oRet['avgOtherColumn']  :=STR0008
		oRet['maxOtherColumn']  :=STR0009
		oRet['minOtherColumn']  :=STR0010
	case cModel == 'groupItems'
		oRet['alignByColumn'] 			:= .F.
		oRet['column'] 					:= Nil
		oRet['displayFormat'] 			:= Nil
		oRet['showInColumn'] 			:= Nil
		oRet['showInGroupFooter'] 		:= .F.
		oRet['skipEmptyValues'] 			:= Nil
		oRet['summaryType'] 			:= Nil
		oRet['valueFormat'] 			:= Nil
	case cModel == 'totalItems'
		oRet['alignment'] 				:= Nil
		oRet['column'] 					:= Nil
		oRet['displayFormat'] 			:= Nil
		oRet['showInColumn'] 			:= Nil
		oRet['skipEmptyValues'] 		:= Nil
		oRet['summaryType'] 				:= Nil
		oRet['valueFormat'] 				:= Nil
	case cModel == 'masterDetail'
		oRet['enabled'] 		:= .F.
		oRet['template'] 		:= Nil
		oRet['autoExpandAll'] := .F.
	case cModel == 'columnChooser'
  		oRet['allowSearch'] 	:=	.T.
		oRet['enabled'] 		:= .T.
		oRet['height'] 		:= Nil
		oRet['mode'] 			:= 'select'
		oRet['searchTimeout'] := Nil
		oRet['width'] := Nil
	case cModel == 'columnFixing'
		oRet['enabled'] 		:= .T.
	case cModel == 'export'
  		oRet['allowExportSelectedData'] 	:=	.F.
		oRet['enabled'] 		:= .T.
	case cModel == 'filterPanel'
  		oRet['filterEnabled'] 	:=	.T.
		oRet['visible'] 		:= .T.
	case cModel == 'filterRow'
		oRet['visible'] 		:= .T.

	case cModel == 'grouping'
		oRet['allowCollapsing'] 	:= .T.
		oRet['autoExpandAll'] 		:= .T.
		oRet['contextMenuEnabled'] := .T.
	case cModel == 'groupPanel'
		oRet['visible'] 		:= .T.
		oRet['allowColumnDragging'] 		:= .T.
	
	case cModel == 'headerFilter'
		oRet['visible'] 		:= .T.
		oRet['height'] 		:= Nil
		oRet['width'] 			:= Nil
		oRet['allowSearch'] 		:= .T.

	case cModel == 'scrolling'
		oRet['mode'] 					:= Nil
		oRet['columnRenderingMode']:= Nil
		oRet['preloadEnabled'] 		:= Nil
		oRet['rowRenderingMode'] 	:= Nil
		oRet['showScrollbar'] 		:= Nil
		oRet['useNative'] 			:= Nil
	case cModel == 'sorting'
		oRet['mode'] 					:= 'single'
	case cModel == 'stateStoring'
		oRet['enabled'] 				:= .T.
		oRet['storageKey'] 			:= Nil

	case cModel == 'searchPanel'
		oRet['highlightCaseSensitive'] 	:= .T.
		oRet['highlightSearchText'] 		:= .T.
		oRet['searchVisibleColumnsOnly'] := .F.
		oRet['visible'] 	:= .T.
	case cModel == 'sortByGroupSummaryInfo'
		oRet['groupColumn'] 	:= Nil
		oRet['sortOrder'] 	:= Nil
		oRet['summaryItem'] := Nil
	case cModel == 'columns'
		oRet['visible']	:=	.T.
		oRet['caption']	:=	Nil
		oRet['dataField']	:=	Nil

		oRet['alignment']	:=	nil
		oRet['allowExporting']	:=	.T.
		oRet['allowFiltering']	:=	.T.
		oRet['allowFixing']		:=	.T.
		oRet['allowGrouping']	:=	.F.
		oRet['allowHeaderFiltering']	:=	.T.
		oRet['allowHiding']		:=	.T.
		oRet['allowReordering']	:=	.T.
		oRet['allowResizing']	:=	.T.
		oRet['allowSearch']		:=	.T.
		oRet['allowSorting']		:=	.T.
		oRet['autoExpandGroup']	:=	.T.

		oRet['columns']	:=	Nil
		oRet['dataType']	:=	Nil
		oRet['encodeHtml']	:=	.F.
		oRet['fixed']			:=	.F.
		oRet['fixedPosition']	:=	Nil
		oRet['format']	:=	Nil //Accepted Values: 'billions' | 'currency' | 'day' | 'decimal' | 'exponential' | 'fixedPoint' | 'largeNumber' | 'longDate' | 'longTime' | 'millions' | 'millisecond' | 'month' | 'monthAndDay' | 'monthAndYear' | 'percent' | 'quarter' | 'quarterAndYear' | 'shortDate' | 'shortTime' | 'thousands' | 'trillions' | 'year' | 'dayOfWeek' | 'hour' | 'longDateLongTime' | 'minute' | 'second' | 'shortDateShortTime'
		
		oRet['groupIndex']	:=	Nil
		oRet['hidingPriority']	:=	Nil
		//oRet['isBand']			:=	.F.
		oRet['lookup']		:=	Nil
		oRet['minWidth']	:=	Nil
		
		oRet['name']	:=	Nil
		//oRet['ownerBand']	:=	Nil
		oRet['showInColumnChooser']	:=	.T.
		oRet['showWhenGrouped']	:=	.F.
		oRet['width']		:=	Nil
		
	case cModel == 'formatObject'
		oRet['year'] 		:= Nil //'2-digit'
		oRet['month'] 		:= Nil //'narrow'
		oRet['day'] 		:= Nil //'2-digit'
		oRet['style'] 		:= Nil
		oRet['currency'] 	:= Nil
		oRet['useGrouping'] := Nil
	case cModel == 'lookup'
		oRet['allowClearing'] := .T.
		oRet['dataSource'] 	 := {}
		oRet['displayExpr'] 	 := 'label'
		oRet['valueExpr'] 	 := 'value'

	case cModel == 'pager'
		oRet['allowedPageSizes'] := {'50','100','500'}
		oRet['showInfo'] 	 := .t.
		oRet['showNavigationButtons'] 	 := .t.
		oRet['showPageSizeSelector'] 	 := .t.
		oRet['visible'] 	 := .t.
	
	case cModel == 'paging'
		oRet['enabled'] 	 := .T.
		oRet['pageIndex']  := 0
		oRet['pageSize'] 	 := 50

	case cModel == 'labelValueJson'
		oRet['label'] 	 := ""
		oRet['value'] 	 := ""
	case cModel == 'reportParams'
		oRet['label'] 	 := ""
		oRet['value'] 	 := ""
		oRet['help'] 	 := ""
	EndCase

Return oRet


Static Function ReadParams(cFile)

    LOCAL nHandle  := FOpen(cFile+".dxparam")
    Local oJSonResp := JsonObject():New()
    Local cParams := ""
    LOCAL nSize := 0
    If nHandle > 0
        nSize := FSEEK(nHandle, 0, 2)    
        FSEEK(nHandle, 0, 0)     // Retorna à posição inicial do ponteiro
        Fread(nHandle,@cParams,nSize)
        oJSonResp:FromJson(cParams)
        Fclose(nHandle)
    Else
        oJSonResp['error'] := i18n(STR0011,{cFile})//'Parameters file not found ['+cFile+'.dxparam'+']'
    Endif

Return oJSonResp

Static Function CleanFiles(cFile)

    Local oJSonResp 	:= JsonObject():New()
    LOCAL nHandle  	:= FOpen(cFile+".dxparam")
    LOCAL nSize 		:= 0
    Local cParams		:= "" 
    Local nX

    If nHandle > 0
        nSize 		:= FSEEK(nHandle, 0, 2)   
        FSEEK(nHandle, 0, 0)     // Retorna à posição inicial do ponteiro
        Fread(nHandle,@cParams,nSize)
        oJSonResp:FromJson(cParams)
        Fclose(nHandle)
        Ferase(cFile+".dxparam")

        //Delete all files created
        For nX:=1 To Len(oJSonResp['files'])
            TcDelFile(oJSonResp['files'][nX]+"_"+oJSonResp['controlKey'])
        Next
    Endif
    FreeObj(oJSonResp)

Return
                   
//Merge Russia R14 
                   
