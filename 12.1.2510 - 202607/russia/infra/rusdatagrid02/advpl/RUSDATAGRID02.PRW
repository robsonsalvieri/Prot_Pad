#INCLUDE "RUSDATAGRID02.CH"
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
Function to be called from report to render Angular report on RUSDATAGRID01 component
@param cReport, character, Name of the function where definition will be read
@param cDD , character, Drilldown function
@param cKey , character, name of file where parameters are stored
@param lDelete , logical , use for debugging purposes, when .F., temporary files will not be deleted from database 

@author Rafael Silva
@since 07/07/2020
@version 1.0
*/
Function RU99X12_DATAGRID2(cReport,cDD,cKey,lDelete)
	_REPORTSERVICE	:=	cReport
	_REPORTKEY		:=	cKey
	_REPORTDD		:=	cDD
	_DELETELAST		:=	iif(lDelete,'1','0')

	 _lRecall := .F.
	FWCALLAPP('RUSDATAGRID02')

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

WSRESTFUL DXREPORTS2 DESCRIPTION STR0001 //'Service to be used along with Deveextreme library reports'
	WSDATA pageSize					As Number
	WSDATA page							As Number
	WSDATA deleteAfterLast			As Number
	WSDATA locale						As character
	WSDATA debug						As character
	WSMETHOD GET GETREPDEF ;
		DESCRIPTION STR0002 ;
		WSSYNTAX "GETREPDEF/{report}/{key}" ;
		PATH "GETREPDEF/{report}/{key}"

	WSMETHOD GET GETDATA ;
		DESCRIPTION STR0003;
		WSSYNTAX "GETDATA/{file}/{key}" ;
		PATH "GETDATA/{file}/{key}"

	WSMETHOD POST SETDATADD ;
		DESCRIPTION STR0004;
		WSSYNTAX "SETDATADD/{ddfunc}/{column}/{gridId}/{drillDownId}/{key}" ;
		PATH "SETDATADD/{ddfunc}/{column}/{gridId}/{drillDownId}/{key}"

END WSRESTFUL

WSMETHOD GET GETREPDEF  WSSERVICE DXREPORTS2
	Local lRet	:=	.T.
	Local cResponse:=""
	Local cError	:= ""
	Local oJson   := JsonObject():New()
	Local nX
	Local aSections := {}
	If ::locale <> nil
		fwSetidiom(::locale)
	Endif
	::SetContentType("application/json; charset=UTF-8")
	If Len(::aURLParms) <> 3
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+STR0005+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n(STR0006,{'3',Alltrim(str(Len(::aURLParms)))})+'"'+; //#1 parameters expected, received #2"
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	ElseIf !FindFunction(::aURLParms[2])
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "592",'+;
			'"message":"'+I18n(STR0007,{::aURLParms[2]})+'",'+; 
			'"detailedMessage": "'+I18n(STR0007,{::aURLParms[2]})+'"'+;
		'}'
	Else
		cResponse := &(::aURLParms[2]+"('"+::aURLParms[3]+"')")
		If Len(cResponse) >2
			cError := oJson:FromJson(cResponse)

			If cError == Nil
				If oJson['data']['sectionsQuantity'] <> len(oJson['data']['sections'])
					cError := STR0008 //'Sections quantity does not match with sections defined'
				Endif
				// Check if sections are consistently defined
				If Empty(cError)
					For nX:=1 to oJson['data']['sectionsQuantity']
						If(Ascan(aSections, oJson['data']['sections'][nX]['section'])) == 0
							aadd(aSections,oJson['data']['sections'][nX]['section'])
						Else
							cError := I18N(STR0009,{Alltrim(Str(oJson['sections'][nX]['section']))})
							Exit
						Endif
					Next
				Endif
				// Check if sections on Drill Downs are consistently defined
				If Empty(cError) .and. oJson['data']['drillDowns'] <> Nil
					For nX:=1 to Len(oJson['data']['drillDowns'])
						If oJson['data']['drillDowns'][nX]['drillDownType'] == 'angular'
							If(Ascan(aSections, oJson['data']['drillDowns'][nX]['section'])) == 0
								aadd(aSections,oJson['data']['drillDowns'][nX]['section'])
							Else
								cError := I18N(STR0010,{Alltrim(Str(oJson['data']['drillDowns'][nX]['section']))})
								Exit
							Endif
						Endif
					Next
				Endif
			Endif
			//Check if DrillDown Links are consistently defined
			If Empty(cError)

			Endif

			If !Empty(cError)
				cResponse := '{'+;
					'"type": "error",'+;
					'"code": "592",'+;
					'"message":"'+cError+'",'+; 
					'"detailedMessage": "'+cError+'"'+;
				'}'
			Endif
			::SetResponse(EncodeUTF8(cResponse))
		Else
			cResponse := '{'+;
				'"type": "warning",'+;
				'"code": "591",'+;
				'"message":"'+STR0011+'",'+; //"Query returned no data"
				'"detailedMessage": "'+STR0011+'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
			
		Endif
	Endif
	FreeObj(oJson)
Return lRet


WSMETHOD GET GETDATA  WSSERVICE DXREPORTS2
	Local lRet	:=	.T.
	Local cResponse:=""
	Local oJsonParams
	If ::locale <> nil
		fwSetidiom(::locale)
	Endif
	Default ::deleteAfterLast := '1'
	::SetContentType("application/json; charset=UTF-8")
	If Len(::aURLParms) <> 3
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+STR0005+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n(STR0006,{'3',Alltrim(str(Len(::aURLParms)))})+'"'+; //1 parameters expected, received #1"
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
		oJsonParams := JsonObject():New()	
		oJsonParams :=	STATICCALL(RU99X13_DXMODELS,ReadParams,::aURLParms[3])  
		If oJsonParams['error'] == Nil
			cResponse:=	GETDATA(::aURLParms[2],val(::page),val(::pageSize),Val(::deleteAfterLast),::aURLParms[3],oJsonParams)
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
				'"message":"'+STR0011+'",'+; //"Query returned no data"
				'"detailedMessage": "'+STR0011+'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
		Endif
		Else
			cResponse := '{'+;
				'"type": "error",'+;
				'"code": "591",'+;
				'"message":"'+oJsonParams['error'] +'",'+; //"Query returned no data"
				'"detailedMessage": "'+oJsonParams['error'] +'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
	Endif
		FreeObj(oJsonParams)
	Endif
Return lRet


WSMETHOD POST SETDATADD  WSSERVICE DXREPORTS2
	Local lRet	:=	.T.
	Local cResponse:=""
	Local cData := ""
	Local cBody	:= Self:GetContent()
	
	If ::locale <> nil
		fwSetidiom(::locale)
	Endif
	::SetContentType("application/json; charset=UTF-8")
	If Len(::aURLParms) <> 6
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+STR0005+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n(STR0006,{'6',Alltrim(str(Len(::aURLParms)))})+'"'+; //1 parameters expected, received #1"
		'}'
		::SetResponse(EncodeUTF8(cResponse))
 	ElseIf !FindFunction(::aURLParms[2])
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+I18n(STR0012,{::aURLParms[2]})+'",'+; 
		'"detailedMessage": "'+I18n(STR0012,{::aURLParms[2]})+'"'+; //1 parameters expected, received #1"
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
		cData := &(::aURLParms[2]+"('"+::aURLParms[3]+"','"+::aURLParms[4]+"','"+::aURLParms[5]+"','"+::aURLParms[6]+"','"+cBody+"')")
		If cData <> Nil
			cResponse := '{"data":'+cData+','+;
				'"status": "ok",'+;
				'"ok": "ok",'+;
				'"statusText":"ok"'+; //"Query returned no data"
			'}'

			::SetResponse(EncodeUTF8(cResponse))
		Else
			cResponse := '{'+;
				'"type": "warning",'+;
				'"code": "591",'+;
				'"message":"'+STR0011+'",'+; //"Query returned no data"
				'"detailedMessage": "'+STR0011+'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
		Endif
	Endif

Return lRet
/*{Protheus.doc} Getdata
Function to retrieve data from dxReports2 service report
@type function
@version  1.0
@author Bruno.s
@since 2/15/2021
@param cFile, character, File name to where get data from
@param nPage, numeric, page number
@param nPageSize, numeric, Page size
@param nDelete, numeric, Delete data table after retrieving content
@param cKey, character, key received by GETREPDEF method where information about report are stored
@param oJsonParams, object, Parameters stores in JSON format
@param cDebug, character, Parameter that defines if in debug mode to print console data
@return character, JSON text with data drm file
*/
Static Function Getdata(cFile, nPage, nPageSize, nDelete, cKey, oJsonParams,cDebug)
	Local cAliasQry   := GetNextAlias()
	Local oJsonResp   := JsonObject():New()

	Local cSuffix 		:= ''
	Local cQuery      := ''
	Local cQueryMax   := ''
	Local aStru       := {}
	Local cRet        := ""
	Local nMax 			:=	0
	Local lhasNext		:= .F.
	Local nRecsRet		:=	0
	Local nLast 		:= 0
	Local aStruct		:=	{}
	Local cFields		:=	""
	Local nX
	Local cOffset:= Str((nPage-1) * nPageSize)
	DEFAULT nDelete := 1
	

	cSuffix	:=	oJsonParams['controlKey']
	aStruct := TCStruct( cFile+"_"+cSuffix )
	For nX:= 1 To Len(aStruct)
		If aStruct[nX,1] <> 'R_E_C_N_O_' .And.;
			aStruct[nX,1] <> 'D_E_L_E_T_' .And.;
			aStruct[nX,1] <> 'R_E_C_D_E_L_' .And.;
			aStruct[nX,1]  <> 'S_T_A_M_P_' .And. ;
			aStruct[nX,1]  <> 'I_N_S_D_T_'
			cFields += ","+aStruct[nX,1]
		Endif
	Next
	cQuery      := 'SELECT R_E_C_N_O_ as RECNO_ '+cFields+' FROM  '+cFile+"_"+cSuffix+' ORDER BY R_E_C_N_O_ '
	cQueryMax   := 'SELECT COUNT(R_E_C_N_O_)  as MAXREC FROM  '+cFile+"_"+cSuffix
	
	cQueryMax   := ChangeQuery(cQueryMax)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryMax),cAliasQry,.T.,.F.)
	dbSelectArea( cAliasQry )
	nMax:= MAXREC
	DbCloseArea()

   If(TCGETDB()=='ORACLE')
      cQuery+= ' ROWNUM BETWEEN '+cOffset+" AND "+Str(Val(cOffset)+nPageSize)
    //ROWNUM <= 10
   ElseIf('MSSQL'$TCGETDB())
      cQuery+= ' OFFSET '+cOffset+" ROWS FETCH FIRST "+Str(nPageSize)+" ROWS ONLY "
      //OFFSET 10 ROWS FETCH FIRST 20 ROWS ONLY
   Else //POtsgreSql and others
      cQuery+= " LIMIT "+Str(nPageSize)+" OFFSET "+cOffset
      //LIMIT 3 OFFSET 2
   Endif
	cGetMemoBkp := TCConfig( 'GETMEMOINQUERY')
	TCConfig( 'SETMEMOINQUERY=ON' )
	cQuery   := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
	dbSelectArea( cAliasQry )
	aStru := DbStruct()

	While (cAliasQry)->( ! Eof() )
		cRet += ","+rec2Json(aStru,oJsonResp)
		lHasNext := (RECNO_ < nMax )
		nLast		:=	RECNO_
		(cAliasQry)->( dbSkip() )
		nRecsRet++
	EndDo
	dbSelectArea ( cAliasQry )
	DbCloseArea()
	If !lhasNext .And. nDelete == 1
		TcDelFile(cFile+"_"+cSuffix)
		If _lDebug .Or. cDebug == '1'
			FwLogMsg(I18n(STR0013,{cFile+"_"+cSuffix})) // 'File '+cFile+"_"+cSuffix+ ' deleted')
		Endif
	Endif
	TCConfig( 'SETMEMOINQUERY='+cGetMemoBkp)

cRet:=	'{   "hasNext": '+iif((nPage * nPageSize) < nMax,'true','false')+','+;
   			 '"count": '+STR(nRecsRet)+','+;
   			 '"total": '+STR(nMax)+','+;
				 '"items": ['+Substr(cRet,2)+"]"+;
				 '}'
	If _lDebug .Or. cDebug == '1'
		FwLogMsg(I18n(STR0014,{StrZero(nPage,2),StrZero(nPageSize,3),StrZero(nMax,3),StrZero(nRecsRet,3)}))
	Endif
Return cRet

/*/{Protheus.doc} Rec2Json
Converts QUERY record into JSON data
@type function
@version  1.0
@author Bruno.s
@since 2/15/2021
@param aStru, array, record structiure
@param oJsonResp, object, JSON file where data will be returned
@return character, JSON object received + new record in plain text format
/*/
Static Function Rec2Json(aStru,oJsonResp)
	Local nX
	For nX:=1 To Len(aStru)
		xValue := FieldGet(FieldPos(aStru[nX,1]))
		If ValType(xValue) == "C"
			oJsonResp[aStru[nX,1]]  :=  Alltrim(xValue)
		Else
			oJsonResp[aStru[nX,1]]  :=  xValue
		Endif			
	Next
	If Ascan(oJsonResp:GetNames(),"ID") == 0
		oJsonResp["ID"] := RECNO_
	Endif
Return oJsonResp:toJSon()




                   
//Merge Russia R14 

