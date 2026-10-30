#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TREPORTDX.CH"

/*
test cases combinations (8):
FAT Smartclient
   MultiProtocolPort=1
      MultiProtocolPortSecure=1 (TEST1)
      MultiProtocolPortSecure=0 (TEST2)

WEB Smartclient through multiprotocolPort  (IP:APPLICATION PORT/webapp)
   MultiProtocolPort=1 
      MultiProtocolPortSecure=1 (TEST4)
      MultiProtocolPortSecure=0 (TEST5)

*/
STATIC _REPORTKEY
STATIC _REPORTCODE
//Turn on for debug purposes
STATIC _lDelete := .F.
//-------------------------------------------------------------------
/*{Protheus.doc} TREPORTDX(cReport,oData,oConfig,lDelete)
Function to be called from report to render Angular report on TREPORTDX component
@param cReportCode, character, Name of the report (FINR010, MATR990, etc.), ised for 
@param cReport, character, Name of the file to be saved on disk for report (informed by user)
@param oData , JSon Object, data for saving in temporary table
@param oConfig, JSon Object, Report configuration

@author Daniil Chizov
@since 16.8.2022
@version 1.0
*/
Function TREPORTDX(cReportCode,cReport,oData,oConfig)
   Local cDataFile := cReport As Character
   Local cFile  := Lower(CriaTrab(Nil, .F.)  ) As Character
   _REPORTKEY		:=	cFile
   _REPORTCODE		:=	cReportCode
   cFile += '_U'+__CUSERID 
   //TODO: Check if this is really needed after checking all test cases
   If TREPORTDX5_CheckHealth(.F.)
      TREPORTDX1_SAVECONFIG(oConfig,cDataFile,cFile)
      TREPORTDX2_SAVEDATA(oData,cDataFile)
      FWCALLAPP('treportdx')
      If _lDelete
         FERASE(cFile+".dxparam")
      EndIf
   Else
      //TODO: Move out from here to TREPORT
      Alert(STR0064, STR0063) // ('This option is only allowed when using multiport protocol','Ask admin to setup')
   EndIf
Return

//-------------------------------------------------------------------
/*{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Fun??o que pode ser chamada do PO-UI quando dentro do Protheus

@param oWebChannel, object, TWebEngine utilizado para renderizar o PO-UI
@param cType , character, Par?metro de tipo
@param cContent , character, Conteudo passado pelo PO-UI

@author 
@since 07/07/2022
@version 1.0
*/

Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Local oJSonResp As Object

	Do Case
	Case cType == "preLoad"
		oJSonResp := JsonObject():New()
		cJsonCompany	:=	'{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
		oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )

		cCode := '[{"key": "reportParams", "value":"'+_REPORTKEY+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "tReportCode", "value":"'+_REPORTCODE+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )
		
		cCode := '[{"key": "ERPLanguage", "value":"'+Alltrim(FwRetIdiom())+'"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )

		cCode := '[{"key": "isNotMock", "value":"true"}]'
		oWebChannel:AdvPLToJS( "setSession"   , cCode )
      
	Case cType == "recallApp"
		 _lRecall := .T.
	EndCase
Return

/*/{Protheus.doc} TREPORTDX1_SAVECONFIG
description
@type function
@author Daniil Chizov
@since 16.8.2022
@param oParamsValue, object, Report parametrization
@param cDataFile, character, File where report data is saved (on users spool)
@param cFile, character, File where to save setup
@return variant, return_description
/*/
Function TREPORTDX1_SAVECONFIG(oParamsValue, cDataFile,cFile)
   Local nX,nY As Numeric
   Local oRet := JsonObject():New() As Object
   Local cReportTitle :=   oParamsValue['data']['title'] As Character

   oRet['data'] := JsonObject():New()
   oRet['data']['columns'] := {}

   For nX:=1 To Len(oParamsValue['data']['columns'])
      oJsonColumn := GetDxModel("columns")
      aFields := oParamsValue['data']['columns'][nX]:getNames()
      For nY:= 1 To Len(aFields)
         oJsonColumn["allowGrouping"] := .T.
         If aFields[nY] =='__dataType'
            oJsonColumn["dataType"] 	:= Iif(oParamsValue['data']['columns'][nX][aFields[nY]]== "N", "number", Iif(oParamsValue['data']['columns'][nX][aFields[nY]]== "D", "date", "string"))
         ElseIf aFields[nY] =='__width'
            oJsonColumn["minWidth"] 	:= oParamsValue['data']['columns'][nX][aFields[nY]] * 10 // pixels for each character
         ElseIf aFields[nY] =='__picture'
            oJsonColumn["format"] := AdvPl2Dx('picture',oJsonColumn["dataType"] , oParamsValue['data']['columns'][nX]['__picture'])
         ElseIf substr(aFields[nY],1,2) <>'__'
            oJsonColumn[aFields[nY]] := oParamsValue['data']['columns'][nX][aFields[nY]]
         EndIf
      Next
      aAdd(oRet['data']['columns'], oJsonColumn)
      FreeObj(oJsonColumn)
   Next
   oRet['data']['sectionsReport'] := oParamsValue['data']['sectionstreport']
   oRet['data']['mainTitle'] := cReportTitle
   If oParamsValue['data']['params'] <> Nil 
      oRet['data']['params'] := oParamsValue['data']['params']
   EndIf
   oRet['configRaw'] := oParamsValue
   oRet['dataFile'] := cDataFile

   nHandle        := FCREATE(cFile+".dxparam", 0)
   FWRITE(nHandle, oRet:toJson())
   FClose(nHandle)

Return cFile

/*/{Protheus.doc} AdvPl2Dx
Converts ADVPL formats to DevExtreme formats
@type function
@author Daniil Chizov
@since 16.8.2022
@param cType, character, parameter type to be converted to DevExtreme format
@param cDataType, character, Type of data to be converted
@param cAdvplExp, character, AdvplExpression to be converted
@return JsonObject/string, Json Object or string with result expected by Devextreme format
/*/
Static function AdvPl2Dx(cType,cDataType,cAdvplExp)
   Local xRet := Nil
   
   If cType == 'picture'
      If cDataType == 'number' .And. !Empty(cAdvplExp)
         cAdvplExp := StrTran(cAdvplExp," ","")
         If ("@R") $ cAdvplExp .Or. ("@E") $ cAdvplExp 
            nPosDec  := At(".",cAdvplExp)
            nDecs    := Len(cAdvplExp)-nPosDec
            If nPosDec > 0 .And. nDecs > 0
               xRet := GetDxModel("format")
               xRet['type'] := 'fixedPoint'
               xRet['precision'] := nDecs
            EndIf
         EndIf
      EndIf
   EndIf

Return xRet 


/*/{Protheus.doc} TREPORTDX2_SAVEDATA
Saves data received from TREPORT in JSON file
@type function
@author Daniil Chizov
@since 16.8.2022
@param oData, object, Data in Json Format received from treport
@param cDataFile, character, File name
@return null
/*/
Function TREPORTDX2_SAVEDATA(oData, cDataFile)
   Local nHandle        := FCREATE(cDataFile, 0) As Numeric
   
   FWRITE(nHandle, oData:toJson())
   FClose(nHandle)

Return 


/*/{Protheus.doc} TREPORTDX Rest Service
Service responsible for communication betwenn FWCALLAPP object and backend
@type function
@author Daniil Chizov
@since 16.8.2022
/*/

WSRESTFUL TREPORTDX DESCRIPTION 'Service for treports into DevExtreme library reports. Used internally by FW team for TREPORT Output'
	WSDATA locale						As character
	WSDATA debug						As character
   WSDATA userCode AS STRING OPTIONAL

	WSMETHOD GET GETREPDEF ;
		DESCRIPTION 'Retrieves report definitions' ;
		WSSYNTAX "GETREPDEF/{key}" ;
		PATH "GETREPDEF/{key}"

	WSMETHOD GET GETDATA ;
		DESCRIPTION 'Retrieves report data';
		WSSYNTAX "GETDATA/{key}" ;
		PATH "GETDATA/{key}"

	WSMETHOD GET GETTRANSLATIONS ;
		DESCRIPTION 'Retrieves translation strings';
		WSSYNTAX "GETTRANSLATIONS/" ;
		PATH "GETTRANSLATIONS/"

   WSMETHOD GET PROFILE ;
      DESCRIPTION "Gets setup profiles" ;
      WSSYNTAX "profile/{Program}/{taskPro}/{typePro}";
      PATH "profile/{Program}/{taskPro}/{typePro}"  ;
	
   WSMETHOD POST PROFILE ;
      DESCRIPTION "Saves setup profile information" ;
      WSSYNTAX "profile/{Program}/{taskPro}/{typePro}";
      PATH "profile/{Program}/{taskPro}/{typePro}"  ;

   WSMETHOD DELETE PROFILE ;
      DESCRIPTION "Deletes setup profile information" ;
      WSSYNTAX "profile/{Program}/{taskPro}/{typePro}/{code}";
      PATH "profile/{Program}/{taskPro}/{typePro}/{code}"  ;

END WSRESTFUL


WSMETHOD GET GETTRANSLATIONS  WSSERVICE TREPORTDX
	Local lRet	:=	.T. As Logical
   Local cLanguage := "" As Character

	If ::locale <> Nil
		fwSetidiom(::locale)
	EndIf

   cLanguage := FwRetIdiom()
	::SetContentType("application/json; charset=UTF-8")
   oJsonRet := JsonObject():New()
   oJsonRet['data'] = JsonObject():New()
   oJsonRet['ok'] = 'ok'
   oJsonRet['code'] = '400'
   oJsonRet['ok'] = 'ok'
   oJsonRet['data'][cLanguage] := JsonObject():New()
   oJsonRet['data'][cLanguage]['Sum']:=STR0001
   oJsonRet['data'][cLanguage]['Average']:=STR0002
   oJsonRet['data'][cLanguage]['Minimum']:=STR0003
   oJsonRet['data'][cLanguage]['Maximum']:=STR0004
   oJsonRet['data'][cLanguage]['Count']:=STR0005
   oJsonRet['data'][cLanguage]['Current']:=STR0006
   oJsonRet['data'][cLanguage]['New']:=STR0007
   oJsonRet['data'][cLanguage]['Save']:=STR0008
   oJsonRet['data'][cLanguage]['Original']:=STR0009
   oJsonRet['data'][cLanguage]['Close']:=STR0010
   oJsonRet['data'][cLanguage]['Delete']:=STR0011
   oJsonRet['data'][cLanguage]['ConfirmSave']:=STR0012
   oJsonRet['data'][cLanguage]['ConfirmProfileOverwrite']:=STR0013
   oJsonRet['data'][cLanguage]['ProfileSaved']:=STR0014
   oJsonRet['data'][cLanguage]['ErrorSavingProfile']:=STR0015
   oJsonRet['data'][cLanguage]['SaveProfile']:=STR0016
   oJsonRet['data'][cLanguage]['ConfirmProfileDelete']:=STR0017
   oJsonRet['data'][cLanguage]['DeleteProfile']:=STR0018
   oJsonRet['data'][cLanguage]['ProfileDeleted']:=STR0019
   oJsonRet['data'][cLanguage]['GroupSummaries']:=STR0020
   oJsonRet['data'][cLanguage]['GridSummaries']:=STR0021
   oJsonRet['data'][cLanguage]['ErrorDeletingProfile_message']:=STR0022
   oJsonRet['data'][cLanguage]['ChooseSettingsToSave']:=STR0023
   oJsonRet['data'][cLanguage]['Filters']:=STR0024
   oJsonRet['data'][cLanguage]['PageSize']:=STR0025
   oJsonRet['data'][cLanguage]['ColumnsGrouping']:=STR0026
   oJsonRet['data'][cLanguage]['ColumnsSorting']:=STR0027
   oJsonRet['data'][cLanguage]['Summaries']:=STR0028
   oJsonRet['data'][cLanguage]['SaveTo']:=STR0029
   oJsonRet['data'][cLanguage]['Layout']:=STR0030
   oJsonRet['data'][cLanguage]['SaveAsDefault']:=STR0031
   oJsonRet['data'][cLanguage]['ColumnsSetup_fixed_position_visibility']:=STR0032
   oJsonRet['data'][cLanguage]['ErrorGettingSetup_injectMessage']:=STR0033
   oJsonRet['data'][cLanguage]['sourceOrder']:=STR0034
   oJsonRet['data'][cLanguage]['PivotTitle_injectMessage']:=STR0035
   oJsonRet['data'][cLanguage]['ErrorGettingData_injectMessage']:=STR0036
   oJsonRet['data'][cLanguage]['Loading']:=STR0037
   oJsonRet['data'][cLanguage]['None']:=STR0038
   oJsonRet['data'][cLanguage]['AbsoluteVariation']:=STR0039
   oJsonRet['data'][cLanguage]['PercentVariation']:=STR0040
   oJsonRet['data'][cLanguage]['PercentOfColumnTotal']:=STR0041
   oJsonRet['data'][cLanguage]['PercentOfRowTotal']:=STR0042
   oJsonRet['data'][cLanguage]['PercentOfColumnGrandTotal']:=STR0043
   oJsonRet['data'][cLanguage]['PercentOfRowGrandTotal']:=STR0044
   oJsonRet['data'][cLanguage]['PercentOfGrandTotal']:=STR0045
   oJsonRet['data'][cLanguage]['injectMessage_Year']:=STR0046
   oJsonRet['data'][cLanguage]['injectMessage_Quarter']:=STR0047
   oJsonRet['data'][cLanguage]['injectMessage_Month']:=STR0048
   oJsonRet['data'][cLanguage]['Total']:=STR0049
   oJsonRet['data'][cLanguage]['DrilldownData']:=STR0050
   oJsonRet['data'][cLanguage]['PivotOptions']:=STR0051
   oJsonRet['data'][cLanguage]['GeneralSetup']:=STR0052
   oJsonRet['data'][cLanguage]['DataFieldHeadersInRows']:=STR0053
   oJsonRet['data'][cLanguage]['RowHeaderTreeLayout']:=STR0054
   oJsonRet['data'][cLanguage]['WordWrapEnabled']:=STR0055
   oJsonRet['data'][cLanguage]['ShowColumnsGrandTotals']:=STR0056
   oJsonRet['data'][cLanguage]['ShowRowGrandTotals']:=STR0057
   oJsonRet['data'][cLanguage]['ShowRowTotals']:=STR0058
   oJsonRet['data'][cLanguage]['ShowColumnsTotals']:=STR0059
   oJsonRet['data'][cLanguage]['ShowTotalsPrior']:=STR0060
   oJsonRet['data'][cLanguage]['Sorting']:=STR0061
   oJsonRet['data'][cLanguage]['NA']:=STR0062
   ::SetResponse(EncodeUTF8(oJsonRet:toJson()))
	FreeObj(oJsonRet)
Return lRet

WSMETHOD GET GETREPDEF  WSSERVICE TREPORTDX
	Local lRet	:=	.T. As Logical
	Local cResponse:= "" As Character
	Local cFile As Character
   //Only for debugging purposes from angular, REMOVE BEFORE COMMITING, REST must be authenticated and user must be read from __cUserID
   Local cCodUsr 	   := Iif(Empty(::userCode),__CUSERID,::userCode) As Character

	If ::locale <> Nil
		fwSetidiom(::locale)
	EndIf

	::SetContentType("application/json; charset=UTF-8")

	If Len(::aURLParms) <> 2
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+STR0005+'",'+; //"Incorrect parameter count"
		'"detailedMessage": "'+I18n('STR0006',{'2',Alltrim(str(Len(::aURLParms)))})+'"'+; //#1 parameters expected, received #2"
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
   	oJsonParams := JsonObject():New()
      cFile := ::aURLParms[2]+'_U'+cCodUsr //RetCodUsr()
		oJsonParams :=	STATICCALL(RU99X13_DXMODELS,ReadParams,cFile)  
		If oJsonParams['error'] == Nil
         cResponse:=	TREPORTDX3_GETConfig(cFile)
         If len(cResponse ) > 0
         	::SetResponse(EncodeUTF8(cResponse))
         Else
            cResponse := '{'+;
               '"type": "error",'+;
               '"code": "591",'+;
               '"message":"'+STR0070 +'",'+; //"Query returned no data", Message: "Config for report file not found"
               '"detailedMessage": "'+STR0070 +'"'+; //"Query returned no data", Message: "Config for report file not found"
            '}'
   			::SetResponse(EncodeUTF8(cResponse))
         EndIf

		Else
			cResponse := '{'+;
				'"type": "error",'+;
				'"code": "591",'+;
				'"message":"'+oJsonParams['error'] +'",'+; //"Query returned no data"
				'"detailedMessage": "'+oJsonParams['error'] +'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
      EndIf
	   FreeObj(oJsonParams)
	EndIf

Return lRet

WSMETHOD GET GETDATA  WSSERVICE TREPORTDX
	Local lRet	:=	.T. As Logical
	Local cResponse := "" As Character
	Local oJsonParams As Object
   //Ony for debugging purposes from angular
   Local cCodUsr 	   := Iif(Empty(::userCode),__CUSERID,::userCode) As Character

	If ::locale <> Nil
		fwSetidiom(::locale)
	EndIf

	::SetContentType("application/json; charset=UTF-8")

	If Len(::aURLParms) <> 2
		lRet := .F.
		cResponse := '{'+;
			'"type": "error",'+;
			'"code": "590",'+;
			'"message": "'+ STR0065 +'",'+; //
		'"detailedMessage": "'+I18n("1 parameters expected, received #1",{Alltrim(str(Len(::aURLParms)))-1})+'"'+; //
		'}'
		::SetResponse(EncodeUTF8(cResponse))
	Else
		oJsonParams := JsonObject():New()	
      cFile := ::aURLParms[2]+'_U'+cCodUsr //RetCodUsr()
		oJsonParams :=	STATICCALL(RU99X13_DXMODELS,ReadParams,cFile)  
		If oJsonParams['error'] == Nil
         cResponse:=	TREPORTDX4_GETData(oJsonParams['dataFile'])
			If Len(cResponse) >0
		      cResponse := '{"data":'+cResponse+","+;
				'"status": "ok",'+;
				'"ok": "ok",'+;
				'"statusText":"ok"'+; //"Query returned no data"
			   '}'
            If _lDelete
               FERASE(oJsonParams['dataFile'])
            EndIf
			   ::SetResponse(EncodeUTF8(cResponse))
		   Else
            cResponse := '{'+;
               '"type": "error",'+;
               '"code": "591",'+;
               '"message":"'+ STR0071 +'",'+; //"Query returned no data", Message: "Report data file not found or no data generated"
               '"detailedMessage": "'+ STR0071 +'"'+; //"Query returned no data", Message: "Report data file not found or no data generated"
            '}'
            ::SetResponse(EncodeUTF8(cResponse))
   		EndIf
		Else
			cResponse := '{'+;
				'"type": "error",'+;
				'"code": "591",'+;
				'"message":"'+oJsonParams['error'] +'",'+; //"Query returned no data"
				'"detailedMessage": "'+oJsonParams['error'] +'"'+; //"Query returned no data"
			'}'
			::SetResponse(EncodeUTF8(cResponse))
	   EndIf
		FreeObj(oJsonParams)
	EndIf
Return lRet

WSMETHOD POST PROFILE PATHPARAM Program,TaskPro,TypePro WSRECEIVE userCode WSSERVICE TREPORTDX
   Local cBody 		:= self:getContent() As Character
   Local cCodUsrP 	:= "" As Character //Cod user to be saved profile
   Local cProgram 	:= "" As Character //Program name 
   Local ctaskPro  	:= "" As Character //task name at program
   Local ctypePro  	:= "" As Character
   Local oFwProfile	 := FWPROFILE():New() As Object
   Local oRet		    := JsonObject():New() As Object
   Local oBody		    := JsonObject():New() As Object
   Local idProfile    := '' As Character

   Self:SetContentType("application/json")

   If Len(::aURLParms) <> 4 
      lRet := .F.
      SetRestFault(001, STR0065) // "Incorrect parameter count"
   Else
      /*Can be any format
      */
      If !Empty(cBody)
         cBody 		:= DecodeUTF8(cBody)
         oBody:FromJson(cBody) 
   //        oJsonObj:FromJson(cBody) //cast to json object
         cCodUsrP 	   := Iif(Empty(::userCode),__CUSERID,::userCode)
         cProgram 	   := ::aURLParms[2]
         ctaskPro  	:= ::aURLParms[3]
         ctypePro  	:= ::aURLParms[4]
         oFwProfile:SetUser(cCodUsrP)
         oFwProfile:SetProgram(cProgram)
         oFwProfile:SetTask(ctaskPro)
         oFwProfile:SetType(ctypePro)
         oFwProfile:Activate()
         cProf := oFwProfile:LoadStrProfile()
         oProfToSave := JsonObject():New()
         If Empty(cProf)
            oProfToSave['default']:=''
            oProfToSave['profiles']:=Array(0)
         Else
            oProfToSave:FromJson(cProf)
         EndIf
         If oBody['body']['default'] <> ''
            oProfToSave['default']:=oBody['body']['default']
         EndIf
         nPosProf := Ascan(oProfToSave['profiles'],{|x| x['id'] == oBody['body']['profile']['id']})
         If nPosProf >0
            oProfToSave['profiles'][nPosProf] := oBody['body']['profile']
         Else
            aadd(oProfToSave['profiles'], oBody['body']['profile'])
         EndIf

         oFwProfile:SetStringProfile(oProfToSave:toJson())
         If oFwProfile:Save()
      // Devolve o retorno para o Rest
            idProfile := cProgram+'/'+ctaskPro+'/'+ctypePro
            oRet['status'] :="success"
            oRet["idProfile"] := idProfile
            oRet["cProgram"] := cProgram
            oRet["ctaskPro"] := ctaskPro
            oRet["ctypePro"] := ctypePro
            oRet["cCodUsrP"] := cCodUsrP
            oRet["data"] := oProfToSave
            ::SetResponse( oRet )
         Else
            SetRestFault(500, STR0066) // 'Error when saving'
            lRet := .F.
         EndIf
         oFwProfile:Destroy()
         oFwProfile:= Nil
         FreeObj(oFwProfile)
         FreeObj(oRet)

      Else
         SetRestFault(400, STR0067) // 'Body is empty'
         lRet := .F.
      EndIf
   EndIf


Return (.T.)


WSMETHOD GET PROFILE  PATHPARAM Program,taskPro,typePro WSRECEIVE userCode WSSERVICE TREPORTDX
   Local oRet		      As Object
   Local oFwProfile	   As Object
   Local cProf :=    '' As Character
   Local oJsonRet       As Object
   Local cCodUsrP 	:= iif(empty(::userCode),__CUSERID,::userCode) As Character
   Local cProgram 	:= ::aURLParms[2] As Character
   Local cTaskPro  	:= ::aURLParms[3] As Character
   Local cTypePro  	:= ::aURLParms[4] As Character

   Self:SetContentType("application/json")

   If Len(::aURLParms) <> 4 
      lRet := .F.
      SetRestFault(001, STR0065) // "Incorrect parameter count"
   Else

      oFwProfile	:= FWPROFILE():New()
      oFwProfile:SetUser(cCodUsrP)//RetCodUsr()
      oFwProfile:SetProgram(cProgram)
      oFwProfile:SetTask(ctaskPro)
      oFwProfile:SetType(ctypePro)
      oFwProfile:Activate()
      cProf := oFwProfile:LoadStrProfile()

      If !Empty(cProf)
         oRet:= JsonObject():New()
         oRet["status"] :="success"
         
         oJsonRet := JsonObject():new()
         ret := oJsonRet:FromJson(cProf) //test if its a json object

         If ValType(ret) == "U"
               oRet["data"] := oJsonRet
         Else
               oRet["data"] := cProf
         EndIf 
         FreeObj(oJsonRet)

         oRet["cProgram"] := cProgram
         oRet["ctaskPro"] := ctaskPro
         oRet["ctypePro"] := ctypePro
         oRet["cCodUsrP"] := cCodUsrP
         ::SetResponse( EncodeUtf8(oRet:toJson()) )
         FreeObj(oRet)
      EndIf
      oFwProfile:Destroy()
      FreeObj(oFwProfile)
   EndIf

Return (.T.)



WSMETHOD DELETE PROFILE PATHPARAM Program,taskPro,typePro,code WSRECEIVE userCode WSSERVICE TREPORTDX
   Local cCodUsrP 	    := "" As Character//Cod user to be saved profile
   Local cProgram 	    := "" As Character //Program name 
   Local ctaskPro  	:= "" As Character //task name at program
   Local ctypePro  	:= "" As Character
   Local oFwProfile	 := FWPROFILE():New() As Object
   Local oRet		    := JsonObject():New() As Object
   Local idProfile    := '' As Character

   Self:SetContentType("application/json")

   If Len(::aURLParms) <> 5 
      lRet := .F.
      SetRestFault(001, STR0065) // Incorrect parameter count
   Else
      cCodUsrP 	   := iif(empty(::userCode),__CUSERID,::userCode)
      cProgram 	   := ::aURLParms[2]
      ctaskPro  	   := ::aURLParms[3]
      ctypePro  	   := ::aURLParms[4]
      cCode  	      := ::aURLParms[5]
      oFwProfile:SetUser(cCodUsrP)
      oFwProfile:SetProgram(cProgram)
      oFwProfile:SetTask(ctaskPro)
      oFwProfile:SetType(ctypePro)
      oFwProfile:Activate()
      cProf := oFwProfile:LoadStrProfile()
      oProfToSave := JsonObject():New()

      If Empty(cProf)
         oProfToSave['default'] := ''
         oProfToSave['profiles'] := Array(0)
      Else
         oProfToSave:fromJson(cProf)
      EndIf

      nPosProf := Ascan(oProfToSave['profiles'],{|x| x['id'] == cCode})
      If nPosProf >0
         If oProfToSave['default']==cCode
            oProfToSave['default']:=''
         EndIf
         adel(oProfToSave['profiles'],nPosProf)
         oProfToSave['profiles'] := asize(oProfToSave['profiles'],len(oProfToSave['profiles'])-1)
         oFwProfile:SetStringProfile(oProfToSave:toJson())

         If oFwProfile:Save()
         // Devolve o retorno para o Rest
            idProfile := cProgram+'/'+ctaskPro+'/'+ctypePro
            oRet['status'] :="success"
            oRet["idProfile"] := idProfile
            oRet["cProgram"] := cProgram
            oRet["ctaskPro"] := ctaskPro
            oRet["ctypePro"] := ctypePro
            oRet["cCodUsrP"] := cCodUsrP
            oRet["data"] := oProfToSave
            ::SetResponse( oRet )
         Else
            SetRestFault(500, STR0069) // Error deleting profile
            lRet := .F.
         EndIf
         oFwProfile:Destroy()
         oFwProfile:= Nil
         FreeObj(oFwProfile)
         FreeObj(oProfToSave)
         FreeObj(oRet)
      Else
         SetRestFault(500, STR0068) // Profile not found
         lRet := .F.
      EndIf
   EndIf
Return(.T.)

Function TREPORTDX3_GETConfig(cFile)
   Local cRet := '' As Character

   If file(cFile+".dxparam")
      nHandle := Fopen(cFile+".dxparam")
      nSize := FSEEK(nHandle, 0, 2)    
      FSEEK(nHandle, 0, 0)     // Retorna à posição inicial do ponteiro
      Fread(nHandle,@cRet,nSize)
      Fclose(nHandle)
   EndIf
Return cRet

Function TREPORTDX4_GETDATA(cFile)
   Local cRet := '' As Character

   If file(cFile)
      nHandle := Fopen(cFile)
      nSize := FSEEK(nHandle, 0, 2)    
      FSEEK(nHandle, 0, 0)    
      Fread(nHandle,@cRet,nSize)
      Fclose(nHandle)
   EndIf 
Return cRet


/*/{Protheus.doc} TREPORTDX9_CANUSEDATAGRID
Function used from TREPORT to check if conditions are given to use datagrid reporting
@type function
@author Daniil Chizov
@since 16.8.2022
@return Logic, Return if can be used
/*/
Function TREPORTDX9_CANUSEDATAGRID()
    Static lCanUse

    If lCanUse == Nil
       lCanUSe := TREPORTDX5_CheckHealth()
    EndIf

Return lCanUse

/*/{Protheus.doc} TREPORTDX5_CheckHealth
Check if multiportprotocol is active  before calling report
@type function
@author Daniil Chizov
@since 16.8.2022
@param lWait, Logic, Defines if it mus wait for return
@return Logic, Return if can be used
/*/

Function TREPORTDX5_CheckHealth(lWait)
    Local lHasMPP := .F. As Logical
    Local lSSL := .F. As Logical
    GetPort( 1 , @lSSL, @lHasMPP )
Return lHasMPP 

                   
//Merge Russia R14 
                   
