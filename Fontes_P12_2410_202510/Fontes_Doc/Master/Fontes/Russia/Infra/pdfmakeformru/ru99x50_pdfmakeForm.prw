#INCLUDE 'totvs.ch'
#DEFINE MAXSIZE (4.8 * 1048576)
Static _CCONTENT
Static _CENCODING
Static _cFileNAme
Static _cOptions

Function ru99x50_pdfmakeForm(cContent,cEncoding,cOptions,cFileName)
    DEFAULT cEncoding := 'windows-1251'
    DEFAULT cOptions := Ru99x50_01_GetOptionsTemplate():toJson()
    DEFAULT cFileName := 'ru99x50_pdfmakeform'

    _CCONTENT := cContent
    _CENCODING := cEncoding
    _cFileNAme := cFileName
    _cOptions := cOptions

    If Len(cContent) < MAXSIZE
        FWCallApp('ru99x50_pdfmakeform')
    Else
        MsgStop('Maximum size exceeded','Maximum size exceeded')
    EndIf
    _CCONTENT := Nil
Return

/*/
{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
    Fun??o que pode ser chamada do PO-UI quando dentro do Protheus

    @param oWebChannel, object, TWebEngine utilizado para renderizar o PO-UI
    @param cType , character, Par?metro de tipo
    @param cContent , character, Conteudo passado pelo PO-UI

    @author Willian Yoshiaki Kazahaya
    @since 07/07/2020
    @version 1.0
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
    Local oJSonResp
    Local cBody

    Do Case
    Case cType == "preLoad"
        oJSonResp := JsonObject():New()
        cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
        oWebChannel:AdvPLToJS( "setCompany", cJsonCompany  )

        cCode := '[{"key": "reportJson", "value":"'+Encode64(_CCONTENT)+'"}]'
        oWebChannel:AdvPLToJS( "setSession", cCode )
        cCode := '[{"key": "reportEncoding", "value":"'+_CENCODING+'"}]'
        oWebChannel:AdvPLToJS( "setSession", cCode )

        cCode := '[{"key": "reportOptions", "value":"'+Encode64(_cOptions)+'"}]'
        oWebChannel:AdvPLToJS( "setSession", cCode )

        cCode := '[{"key": "reportFileName", "value":"'+_cFileNAme+'"}]'
        oWebChannel:AdvPLToJS( "setSession", cCode )

        cCode := '[{"key": "ERPLanguage", "value":"'+Alltrim(FwRetIdiom())+'"}]'
        oWebChannel:AdvPLToJS( "setSession", cCode )
    Case cType == "print"
        cBin := Decode64(cContent)
        nHdl := FCreate(_cFileNAme+'.pdf')
        fWrite(nHdl,cBin)
        FClose(nHdl)
        cPath := GetTempPath(.T.)
        CPYS2t(_cFileNAme+'.pdf',cPath)
        Ferase(_cFileNAme+'.pdf')
        ShellExecute('Open',cPath+_cFileNAme+'.pdf',cPath+_cFileNAme+'.pdf',cPath,1)
        //ShellExecute('Print','',cPath+_cFileNAme+'.pdf',cPath,1)
        //ShellExecute('Browser',cPath+_cFileNAme+'.pdf','',cPath,1)
    Case cType == "OpenDoc"
        oJSonResp := JsonObject():New()
        oJSonResp:FromJson(cContent)
        cBody   :=oJSonResp['body']:toJSon()
        FreeObj(oJSonResp)
    EndCase
Return

Function Ru99x50_01_GetOptionsTemplate()
    Local oObject := JsonObject():New()

    /*
    oObject['showToolbar'] := .T.
    oObject['showSidebarButton'] := .T.
    oObject['showFindButton'] := .T.
    oObject['showPagingButtons'] := .T.
    oObject['showZoomButtons'] := .T.
    oObject['showPresentationModeButton'] := .F.
    oObject['showOpenFileButton'] := .F.
    oObject['showPrintButton'] := .T.
    oObject['showDownloadButton'] := .T.
    oObject['showBookmarkButton'] := .F.
    oObject['showSecondaryToolbarButton'] := .T.
    oObject['showRotateButton'] := .F.
    oObject['showHandToolButton'] := .F.
    oObject['showScrollingButton'] := .T.
    oObject['showSpreadButton'] := .F.
    oObject['textLayer'] := .T.
    oObject['showPropertiesButton'] := .F.
    oObject['useBrowserLocale'] := .T. 
    oObject['height'] := "95vh"
    oObject['zoom'] := "100%"

    to be implemented

    */
Return oObject
                   
//Merge Russia R14 

