#INCLUDE "TOTVS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} Class KendoChart
Classe para criar grï¿½ficos baseados na KendoUI
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Class KendoChart FROM LongNameClass

    Data oDialog
    Data oWebEngine
    Data oWebChannel
    Data oLabel
    Data aOptions
    Data cPath
    Data cLink
    Data nHeight
    Data nWidth
    Data lReport

    Method AddChart()
    Method ApplyHistogramStyles()
    Method GetCategories()
    Method GetComments()
    Method GetKendoAxis()
    Method GetLimits()
    Method getLink()
    Method GetSeries()
    Method GetTheme()
    Method GetValueAxis()
    Method IsPrthDark()
    Method JsToAdvpl()
    Method LoadChart()
    Method New() Constructor
    Method Print()
    Method SetAxisCrossingValue()
    Method SetCategories()
    Method setComments()
    Method SetData()
    Method SetKendoAxis()
    Method SetLabelPadding()
    Method SetLimits()
    Method SetSeries()
    Method SetValueAxis()

EndClass

/*/{Protheus.doc} GetTheme
Identifica se o protheus esta configurado com o tema dark e se a release é maior ou igula a 12.1.2410 para setar o tema escuro nos graficos.
@author rafael.kleestadt
@since 09/07/2024
@version 1.0
@return cTheme, caractere, tema a ser usado nos graficos do CEP
@see https://docs.telerik.com/kendo-ui/api/javascript/dataviz/ui/chart/configuration/theme
/*/
Method GetTheme() Class KendoChart
    Local cTheme := "default"

    If GetRPORelease() <= '12.1.2410' .And. ::IsPrthDark() .And. !::lReport
        cTheme := "metroblack"
    EndIf

Return cTheme

/*/{Protheus.doc} IsPrthDark
Identifica se o protheus esta configurado com o tema dark
@author rafael.kleestadt
@since 25/07/2024
@version 1.1
@return true or false, logical, true se o a chave theme esta configurada com black
@see https://tdn.totvs.com/x/iTZSMg
/*/
Method IsPrthDark() Class KendoChart

Local cTheme  := totvs.framework.css.getNewWebAppTheme()
    
Return iIf(!Empty(cTheme) .and. cTheme == "DARK", .T., .F.) //Valida se o tema ativo é o dark


//-------------------------------------------------------------------
/*/{Protheus.doc} Method New()
Método construtor classe KendoChart
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method New(oDialog, nHeight, nWidth) Class KendoChart
    Local cFile       := "kendouichart.app"
    Local cLink       := ""
    Local cTempPath   := ""
    Local oQLGrafico  := GraficosQualidadeX():New()

    Static cPathPng   := ""
    Static oInstance  := NIL

    oInstance := Self

    If Empty(nHeight) .or. Empty(nWidth) .or. Empty(oDialog)
        UserException("Existem parâmetros do construtor não preenchidos")
        Return
    EndIf

    ::oDialog     := oDialog
    ::aOptions    := {}  
    ::cPath       := ""
    ::nHeight     := nHeight
    ::nWidth      := nWidth

    cTempPath := oQLGrafico:retorna_Local_Artefatos_Graficos()

	If !Resource2File(cFile,  cTempPath + cFile)
    	UserException("Não foi possível copiar o arquivo "+cFile+" para o diretório temporário")
		Return
    EndIf

    cPath := cTempPath + "kendouichart\"

    If !ExistDir(cPath)
        If MakeDir(cPath) != 0
            UserException("Não foi possível criar o diretório" + cPath)
            Return
        EndIf
    EndIf

    If FUnzip(cTempPath + cFile, cPath) != 0
		UserException("Não foi possível descompactar os arquivos necessários para execução dos gráficos")
		Return
	Else
		FErase(cTempPath + cFile)  
    EndIf

    ::oWebChannel := TWebChannel():New()
    ::oWebChannel:Connect()

    If !::oWebChannel:lConnected
    	UserException("Erro na conexao com o WebSocket")
    	Return
    EndIf

    cLink := Self:getLink()
    cPathPng := oQLGrafico:retorna_Local_Imagens_Graficos()

    ::oWebChannel:bJsToAdvpl := {|self,codeType,codeContent| oInstance:JsToAdvpl(self,codeType,codeContent) } 
    ::oWebEngine := TWebEngine():New(::oDialog, 0, 0, nWidth, nHeight, NIL, ::oWebChannel:nPort)
    ::oWebEngine:Navigate(cLink)
    ::oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

Return Self


/*/{Protheus.doc} getLink
Método que monta e retorna o link para o método navigate da classe TWebEngine
@type  METHOD
@author rafael.kleestadt
@since 27/10/2022
@version 1.0
@param param_name, param_type, param_descr
@return cLink, caractere, link para o método navigate da classe TWebEngine
@see (links_or_references)
/*/
METHOD getLink() Class KendoChart
    Local cEndPoint  := Nil
    Local cLink      := ""
    Local lSSL       := Nil
    Local lSSLProxy  := Nil //SSL configurado no proxy reverso
    Local lSSLServer := .T. //SSL configurado no APP Server
    Local oQLGrafico := Nil

    If Empty(GetRmtInfo()[9])    //SmartClient
        oQLGrafico := GraficosQualidadeX():New()
        cLink := oQLGrafico:retorna_Local_Artefatos_Graficos() + "kendouichart\" + "kendouichart\src\KendoChart.html"
    Else
        cEndPoint := GetEndPoint()
        lSSLProxy := Iif(lSSLProxy == Nil .AND. (Upper(Left(cEndPoint , 5)) = "HTTPS" .OR. ":443"$cEndPoint ), .T., lSSLProxy)
        lSSLProxy := Iif(lSSLProxy == Nil .AND. Upper(Left(cEndPoint , 4)) = "HTTP" , .F., lSSLProxy)
        GetPort(1, @lSSLServer )
        
        lSSL := Iif(lSSLProxy == Nil, lSSLServer, lSSLProxy)

        cLink :=  Iif(lSSL,"https://","http://") + GetEndPointIP() + "/app-root/kendouichart/kendouichart/src/KendoChart.html"
        cLink := StrTran(cLink, ":"+cValToChar(GetPvProfileInt("WEBAPP", "PORT", 0, GetSrvIniName())), ":"+cValToChar(GetPort(1)))
    EndIf

    conout(cLink)

Return cLink

//-------------------------------------------------------------------
/*/{Protheus.doc} Method JsToAdvpl(self,cCodeType,cCodeContent)
Método de interpretação de chamadas recebidas do JS pelo WebChannel
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method JsToAdvpl(self, cCodeType, cCodeContent) Class KendoChart

    Do Case
        Case cCodeType == "pageStarted"
            ::LoadChart()
        Case cCodeType == "saveImage"
            QIEMIMGGRAF(self, cCodeContent, cPathPng)
        OtherWise
            Return
    EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Method SetSeries()
Método para setar séries do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method SetSeries(cId, aSeries) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['series'] := aSeries, .F.)})
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Method GetSeries()
Método para retornar séries do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method GetSeries(cId) Class KendoChart
    
    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['series'], {|x| Aadd(aTemp, x:GetSeries()) })
    Else
        Return nil
    EndIf

Return aTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} Method LoadChart()
Método que carrega gráfico com dados do json serializado informado
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method SetData(cId, aData) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['data'] := aData, .F.)})
Return

/*/{Protheus.doc} KendoComments
Classe para manipular os comentarios do grafico
@author rafael.kleestadt
@since 16/06/2020
@version 1.0
/*/
Class KendoComments from LongNameClass

    Data oKendoComment

    Method New() Constructor
    Method GetComment()
    
EndClass

Method GetComment() Class KendoComments
Return ::oKendoComment

//-------------------------------------------------------------------
/*/{Protheus.doc} Method LoadChart()
Método que carrega gráfico com dados do json serializado informado
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method LoadChart() Class KendoChart

    Local oOptions  as object
    Local nI        as numeric
    Local nX        as numeric

    oOptions := JsonObject():New()

    For nX := 1 To Len(::aOptions)
        If !Empty(::aOptions[nX]['limits'])
            For nI := 1 To Len(::aOptions[nX]['limits'])
                ::aOptions[nX]['limits'][nI]:oLimit['data'] := Array(Len(::aOptions[nX]['data']))
                AFill(::aOptions[nX]['limits'][nI]:oLimit['data'], ::aOptions[nX]['limits'][nI]:GetValue())
            Next nI
        EndIf

        ::aOptions[nX]['seriesDefault']  := JsonObject():New()

        If ::aOptions[nX]['lHistogram']
            ::ApplyHistogramStyles(::aOptions[nX]['chartId'])
        EndIf

        If !Empty(::aOptions[nX]['myValueAxis'])
            ::aOptions[nX]['valueAxis'] := ::GetValueAxis(::aOptions[nX]['chartId'])
        EndIf

        ::aOptions[nX]['mySeries'] := ::GetSeries(::aOptions[nX]['chartId'])

		If !Empty(::aOptions[nX]['categoryAxis'])
        	::aOptions[nX]['myCategoryAxis'] := ::GetCategories(::aOptions[nX]['chartId'])
		EndIf
        
        If !Empty(::aOptions[nX]['limits'])
            AEval(::aOptions[nX]['limits'] , {|x| Aadd(::aOptions[nX]['mySeries'], x:oLimit)})
        EndIf

        If !Empty(::aOptions[nX]['myAxis'])
            ::aOptions[nX]['myAxis'] := ::GetKendoAxis(::aOptions[nX]['chartId'])
        EndIf

        If !Empty(::aOptions[nX]['chartComment'])
            ::aOptions[nX]['chartComment'] := ::GetComments(::aOptions[nX]['chartId'])
        EndIf

        ::aOptions[nX]['theme'] := ::GetTheme(::aOptions[nX]['chartId'])

    Next nX

    oOptions['charts'] := ::aOptions 
    oOptions['report'] := ::lReport
    If GetRPORelease() <= '12.1.2410' .And. ::IsPrthDark() .And. !::lReport
        oOptions['bodyBackgroundColor'] := "black"
    EndIf

    ::oWebChannel:AdvplToJs("loadChart", oOptions:ToJson())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Method LoadChart()
Método que carrega gráfico com dados do json serializado informado
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method Print() Class KendoChart
    ::oWebEngine:PrintPDF()
Return

/*/{Protheus.doc} New
Construtor da classe KendoComments
@author rafael.kleestadt
@since 16/06/2020
@version 1.0
@param cComment, caracter, string contendo o texto a ser inserido
@return Self, object, return_description
/*/
Method New(cComment) Class KendoComments

    ::oKendoComment := JsonObject():New()

    If !Empty(cComment)
        ::oKendoComment['chartComment'] := cComment
    EndIf

Return Self

/*/{Protheus.doc} GetComments
Getter dos comments da classe KendoChart
@author rafael.kleestadt
@since 16/06/2020
@version 1.0
@param cId, caracter, id do grafico
@return Self, object, return_description
/*/
Method GetComments(cId) Class KendoChart

    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['chartComment'], {|x|Aadd(aTemp, x:GetComment())})
    Else
        Return nil
    EndIf

Return aTemp

/*/{Protheus.doc} SetComments
Setter dos comments da classe KendoChart
@author rafael.kleestadt
@since 16/06/2020
@version 1.0
@param cId, caracter, id do grafico
@param aComments, array, array contendo os comentarios do grafico
@return Self, object, return_description
/*/
Method SetComments(cId, aComments) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['chartComment'] := aComments, .F.)})
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Method SetCategories()
Método que seta as informações a serem apresentadas nas categorias
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method SetCategories(cId, aCategories) Class KendoChart

    Local nI as numeric

    nI := 1

    For nI := 1 To Len(aCategories)
        aCategories[nI]:oCategory['axisCrossingValue'] := {0, Len(aCategories) + 10}   
    Next    

    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['categoryAxis'] := aCategories, .F.)})
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAxisCrossingValue
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method SetAxisCrossingValue(aCategories, value) Class KendoChart
Local nI := 0

    For nI := 1 To Len(aCategories)
        aCategories[nI]:oCategory['axisCrossingValue'] := {0, value + 1}
    Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Method GetCategories()
Método para retornar categorias do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method GetCategories(cId) Class KendoChart
    
    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['categoryAxis'], {|x|Aadd(aTemp, x:GetCategory())})
    Else
        Return nil
    EndIf

Return aTemp
//-------------------------------------------------------------------
/*/{Protheus.doc} Method GetCategories()
Método para retornar categorias do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method GetValueAxis(cId) Class KendoChart
    
    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['myValueAxis'], {|x|Aadd(aTemp, x:GetAxis())})
    Else
        Return nil
    EndIf

Return aTemp
//-------------------------------------------------------------------
/*/{Protheus.doc} GetKendoAxis(cId)
Método para retornar eixos do gráfico
/*/
//-------------------------------------------------------------------
Method GetKendoAxis(cId) Class KendoChart
    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['myAxis'], {|x|Aadd(aTemp, x:GetAxis())})
    Else
        Return nil
    EndIf

Return aTemp
//-------------------------------------------------------------------
/*/{Protheus.doc} Method SetLimits(aLimits)
Método que seta os limites X e Y
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method SetLimits(cId, aLimits) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['limits'] := aLimits, .F.)})
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Method SetLabelPadding
Método que seta o pading das labels
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method SetLabelPadding(nTop, nLeft) Class KendoChart
    ::oLabel := JsonObject():New()

    ::oLabel['padding'] := JsonObject():New()

    If !Empty(nTop)
        ::oLabel['padding']['top'] := nTop
    EndIf

    If !Empty(nLeft)
        ::oLabel['padding']['left'] := nLeft
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Method GetCategories()
Método para retornar categorias do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method GetLimits(cId) Class KendoChart
    
    Local aTemp as array
    Local nPos  as numeric
    
    aTemp := {}

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})

    If nPos > 0
        AEval(::aOptions[nPos]['limits'],{|x| Aadd(aTemp, x:GetLimit())})
    Else
        Return nil
    EndIf

Return aTemp
//-------------------------------------------------------------------
/*/{Protheus.doc} Method ApplyHistogramStyles()
Método aplicar histogram styles
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method ApplyHistogramStyles(cId) Class KendoChart

    Local nI   as numeric
    Local nPos as numeric

    nPos := AScan(::aOptions, {|x| x['chartId'] == cId})
    
    If nPos > 0
        For nI := 1 To Len(::aOptions[nPos]['series'])
            ::aOptions[nPos]['series'][nI]:oSeries['gap']                 := -0.1
            ::aOptions[nPos]['series'][nI]:oSeries['spacing']             := 0
            ::aOptions[nPos]['series'][nI]:oSeries['overlay']             := JsonObject():New()
            ::aOptions[nPos]['series'][nI]:oSeries['overlay']['gradient'] := "none"
            ::aOptions[nPos]['series'][nI]:oSeries['border']              := JsonObject():New()
            ::aOptions[nPos]['series'][nI]:oSeries['border']['width']     := 0
            ::aOptions[nPos]['series'][nI]:oSeries['markers']             := JsonObject():New()
            ::aOptions[nPos]['series'][nI]:oSeries['markers']['visible']  := .F.
        Next nI
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method AddChart(cId, cTitle, cLabelPos, lHistogram, lLabelVisible, nWidth, nHeight, ltransitions, cFontTitle) Class KendoChart

    Local oOption as object 
    
    Default lLabelVisible := .T.
    Default ltransitions  := .T.
    Default nWidth        := 650
    Default nHeight       := 275
    Default cFontTitle    := "15px sans-serif"

    oOption := JsonObject():New()
   
    oOption['chartId']       := cId
    oOption['lHistogram']    := lHistogram
    oOption['labelPosition'] := cLabelPos 
    oOption['labelVisible']  := lLabelVisible 
    oOption['transitions']   := ltransitions

    oOption['title']                     := JsonObject():New()
    oOption['title']['font']             := cFontTitle
    oOption['title']['text']             := cTitle
    oOption['title']['margin']           := JsonObject():New()
    oOption['title']['margin']['top']    := 1
    oOption['title']['margin']['bottom'] := 0
    oOption['chartArea']           := JsonObject():New()
    oOption['chartArea']['width']  := nWidth
    oOption['chartArea']['height'] := nHeight

    Aadd(::aOptions, oOption)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method SetValueAxis(cId, aAxis) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['myValueAxis'] := aAxis, .F.)})
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Class KendoSeries
Classe para criar séries
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Class KendoSeries from LongNameClass

    Data oSeries 

    Method New() Constructor
    Method GetSeries()
    Method RemoveMarkers()
    Method SetWidth()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} Method New()
Determina número de séries e quais os campos utilizados para montar o gráfico.
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method New(cName, cField, cCategoryField, cCategoryAxis, cValueAxis, cType, cStyle, cColor, lLabels, cDashType, cMakerType, lVsbleLeg, cFormatLbl, cFontLabel) Class KendoSeries

    Default cStyle    := "smooth"
	Default cColor    := "#0C6C94"
	Default lLabels   := .F.
	Default cDashType := "solid"
	Default lVsbleLeg := .T.
	Default cFormatLbl := "{0:N4}"
	Default cFontLabel := "7px sans-serif"

    ::oSeries := JsonObject():New()

	::oSeries['name']            := cName
	::oSeries['type']            := cType
	::oSeries['style']           := cStyle
	::oSeries['dashType']        := cDashType
    ::oSeries['color']           := cColor
    ::oSeries['visibleInLegend'] := lVsbleLeg

    If !Empty(cMakerType)
        ::oSeries['markers'] := JsonObject():New()
        ::oSeries['markers']['visible'] := .T.
        ::oSeries['markers']['type']    := cMakerType
    EndIf

	If Upper(cType) <> "SCATTER"
		::oSeries['field'] := cField

		If !Empty(cCategoryField)
			::oSeries['categoryField'] := cCategoryField
			::oSeries['categoryAxis']  := cCategoryAxis
		EndIf
	Else
		::oSeries['yField'] := cField
		::oSeries['xField'] := cCategoryField
	EndIf
	
	If !Empty(cValueAxis)
		::oSeries['axis'] := cValueAxis
	EndIf

    If lLabels
        ::oSeries['labels'] := JsonObject():New()
        ::oSeries['labels']['visible']    := .T.
        If cCategoryAxis = "cat1"
            ::oSeries['labels']['position']   := "center"
            ::oSeries['labels']['background'] := "transparent"
        else
            ::oSeries['labels']['position']   := "top"
            ::oSeries['labels']['background'] := "white"
            ::oSeries['labels']['padding']    := 1
            ::oSeries['labels']['format']     := cFormatLbl
            ::oSeries['labels']['border']     := JsonObject():New()
            ::oSeries['labels']['border']['width']   := 1
            ::oSeries['labels']['border']['color']   := "black"
            ::oSeries['labels']['border']['padding'] := 1
            ::oSeries['labels']['font'] := cFontLabel
        EndIf
    EndIf

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method GetSeries() Class KendoSeries
Return ::oSeries

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method RemoveMarkers() Class KendoSeries

	::oSeries['markers']  := .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method SetWidth(nWidth) Class KendoSeries

	::oSeries['width']  := nWidth

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Class KendoCategory
Classe para criar objetos de dados para gráficos kendo
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Class KendoCategory from LongNameClass

    Data oCategory

    Method New() Constructor
    Method AddNote()
    Method SetNoteLength()
    Method GetCategory()

EndClass

/*/{Protheus.doc} Method New()
método construtor da classe KendoCategory
@author Lucas Briesemeister
@since 2019
@version version
@param cName, caractere, identificador da categoria do gráfico
@param cBaseUnit, caractere, unidade base para formatação das labels 
@param lJustified, lógico, determina se as categorias devem ser distribuídas de maneira uniforme ao longo do eixo, mesmo que haja variações no espaço entre os dados.
@param lVisible, lógico, determina se as categorias devem estar visiveis
@param xRotation, float, rotação das labels das categorias
@param lTemAxis, lógico, compatibilidade
@param lLblVisibl, lógico, determina se a label da categoria deve estar visivel
@param cFormatLbl, caractere, determina  aformatação da label da categoria
@param cFontLbCat, caractere, determina a fonte da label
@return Self, objeto, objeto da classe KendoCategory conforme parametrização
/*/
Method New(cName, cBaseUnit, lJustified, lVisible, xRotation, lTemAxis, lLblVisibl, cFormatLbl, cFontLbCat) Class KendoCategory
Local lCriouJson := .F.

DEFAULT cFontLbCat := "15px sans-serif"
DEFAULT cFormatLbl := "{0:N4}"
DEFAULT lLblVisibl := .T.

    ::oCategory := JsonObject():New()
    
    ::oCategory['name'] := cName

    If !Empty(cBaseUnit)
        ::oCategory['baseUnit'] := cBaseUnit
    EndIf

    ::oCategory['justified'] := lJustified
    ::oCategory['visible']   := lVisible

    If !Empty(xRotation)
        ::oCategory['labels']             := JsonObject():New()
        ::oCategory['labels']['rotation'] := xRotation
        lCriouJson := .t.
    EndIf

    If !lCriouJson
        ::oCategory['labels'] := JsonObject():New()
    EndIf
    ::oCategory['labels']['visible'] := lLblVisibl
    ::oCategory['labels']['format']  := cFormatLbl
    ::oCategory['labels']['font']    := cFontLbCat

    ::oCategory['notes']                            := JsonObject():New()
    ::oCategory['notes']['line']                    := JsonObject():New()
    //::oCategory['notes']['line']['length']          := 300
    ::oCategory['notes']['icon']                    := JsonObject():New()
    ::oCategory['notes']['icon']['border']          := JsonObject():New()
    ::oCategory['notes']['icon']['border']['width'] := 0
    ::oCategory['notes']['data']                    := {}
    If IsInCallStack("QPPA170") .Or. IsInCallStack("QPPR170") 
        ::oCategory['majorGridLines'] := JsonObject():New()
        ::oCategory['majorGridLines']['visible'] := .F.
    Endif

Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} Method AddNote(nValue, cNote)
Adicionas notas (linhas verticais) no gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method AddNote(nValue, cNote, cColor, cDashType, nLinLength) Class KendoCategory

    Local oNote as object

    oNote := JsonObject():New()

    oNote['line']             := JsonObject():New()
    oNote['line']['color']    := cColor
    oNote['line']['dashType'] := cDashType
    oNote['line']['length']   := nLinLength
    oNote['value']            := nValue
    oNote['label']            := JsonObject():New()
    oNote['label']['text']    := cNote

    Aadd(::oCategory['notes']['data'], oNote)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Method SetNoteLength(nPixels)
@author  Marcos Wagner Jr.
/*/
//-------------------------------------------------------------------
Method SetNoteLength(nPixels) Class KendoCategory

::oCategory['notes']['line']['length'] := nPixels

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Method GetCategory() Class KendoCategory
Return ::oCategory
//-------------------------------------------------------------------
/*/{Protheus.doc} Class KendoLimit
Classe para definir linhas de limite
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Class KendoLimit

    Data oLimit
    Data nValue
    Data lVertical

    Method New() Constructor
    Method GetValue()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} Method New()
Determina os valores que serão usados nas categorias do gráfico
@author  Lucas Briesemeister
/*/
//-------------------------------------------------------------------
Method New(cName, nValue, cColor, cDashType, lVertical, cMakerType) Class KendoLimit

	Default cColor     := "#c64840" 
    Default cDashType  := "dash"
	Default cMakerType := ""
	Default lVertical  := .f.

    ::oLimit := JsonObject():New()
    
    ::oLimit['name']     := cName
    ::oLimit['data']     := {}
    ::oLimit['color']    := cColor
    ::oLimit['dashType'] := cDashType
    If lVertical
    	::oLimit['type']     := "scatterLine"
    Else
    	::oLimit['type']     := "line"
    EndIf
    ::oLimit['markers']  := JsonObject():New()

    
    If !Empty(cMakerType)
        ::oLimit['markers']            := JsonObject():New()
        ::oLimit['markers']['visible'] := .T.
        ::oLimit['markers']['type']    := cMakerType
    Else
        ::oLimit['markers']['visible'] := .F.
    EndIf

    ::nValue := nValue

Return Self

Method GetValue() Class KendoLimit
Return ::nValue
//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Class KendoValueAxis from LongNameClass

    Data oAxis

    Method New() Constructor
    Method GetAxis()

EndClass

/*/{Protheus.doc} New
Método construtor da classe KendoValueAxis
@author rafael.kleestadt
@since 15/10/2024
@version version
@param cName, caractere, identificador do componente do eixo
@param cDescritpion, caractere, titulo do eixo
@param nMinValue, numérico, valor minimo fixado
@param nMaxValue, numérico, valor maximo fixado
@param nStepValue, numérico, define a distância entre os principais marcadores ou linhas de grade do eixo
@param nAxsCrosVal, numérico, ponto em que um eixo cruza outro no gráfico
@param cFontLabel, caractere, tamanho e tipo da fonte do eixo
@param lLabelVisible, lógico, indica se a label do eixo estará visível ou não
@param lLnAxisVisible, lógico, indica se a linha do eixo estará visível ou não
@return self, objeto, objeto da classe KendoValueAxis conforme parametrização
/*/
Method New(cName, cDescritpion, nMinValue, nMaxValue, nStepValue, nAxsCrosVal, cFontLabel, lLabelVisible, lLnAxisVisible) Class KendoValueAxis
    DEFAULT cFontLabel     := "15px sans-serif"
    DEFAULT nMaxValue      := NIL
    DEFAULT nMinValue      := NIL
    DEFAULT lLabelVisible  := .T.
    DEFAULT lLnAxisVisible := .T.

    ::oAxis := JsonObject():New()

    If !Empty(cName)
        ::oAxis['name'] := cName
    EndIf

    If !Empty(cDescritpion)
        ::oAxis['title'] := JsonObject():New()
        ::oAxis['title']['text'] := cDescritpion
    EndIf

    ::oAxis['labels'] := JsonObject():New()
    ::oAxis['labels']['font'] := cFontLabel
    ::oAxis['labels']['visible'] := lLabelVisible

    ::oAxis['line'] := JsonObject():New()
    ::oAxis['line']['visible'] := lLnAxisVisible

    ::oAxis['min'] := nMinValue
    ::oAxis['max'] := nMaxValue
    
    If !Empty(nAxsCrosVal)
        ::oAxis['axisCrossingValues'] := {nAxsCrosVal, 0}
    EndIf

    If !Empty(nStepValue)
        ::oAxis['majorUnit'] := nStepValue
    EndIf

Return Self

Method GetAxis() Class KendoValueAxis
Return ::oAxis

/*/{Protheus.doc} methodName
Setter do objeto myAxis da classe KendoChart
@author rafael.kleestadt / lucas.briesemeister
@since 30/04/2020
@version version
@param cId, caractere, identificador unico do grafico
@param aAxis, array, array com os objetos criados pelo construtor da classe KendoAxis
@return return_var, return_type, return_description
/*/
Method SetKendoAxis(cId, aAxis) Class KendoChart
    AEval(::aOptions, {|x| IIF(x['chartId'] == cId, x['myAxis'] := aAxis, .F.)})
Return

/*/{Protheus.doc} className
Classe para manipular os eixos do grafico
@author rafael.kleestadt / lucas.briesemeister
@since 30/04/2020
@version 1.0
/*/
Class KendoAxis from LongNameClass

    Data oKendoAxis

    Method New() Constructor
    Method AddNoteAxis()
    Method GetAxis()
    
EndClass

/*/{Protheus.doc} new 
Implementação do construtor da classe KendoAxis
@author rafael.kleestadt / lucas.briesemeister
@since 30/04/2020
@version 1.0
@param cEixo, caractere, eixo que esta sendo manipulado(x ou y)
@param nMin, number, posição minima do eixo que esta sendo manipulado(x ou y)
@param nMax, number, posição maxima do eixo que esta sendo manipulado(x ou y)
@param nStep, number, degrau das marcações do eixo 
@return return_var, return_type, return_description
/*/
Method New(cEixo, nMin, nMax, nStep, nAxsCrosVal, nMajorUnit, nLblRotat, cFontLabel) Class KendoAxis
DEFAULT cFontLabel := "15px sans-serif"
    
    ::oKendoAxis := JsonObject():New()

    If !Empty(cEixo) //informar x ou y
        if Upper(cEixo) == "X"
            ::oKendoAxis['name'] := 'xAxis'
        Else
            ::oKendoAxis['name'] := 'yAxis'
        EndIf
    EndIf

    If !Empty(nMin)
        ::oKendoAxis['min'] := nMin
    EndIf

    If !Empty(nMin)
        ::oKendoAxis['max'] := nMax
    EndIf
    
    If !Empty(nAxsCrosVal)
        ::oKendoAxis['axisCrossingValues'] := {nAxsCrosVal, 0}
    EndIf

    If !Empty(nStep)
        ::oKendoAxis['step'] := {nStep, 0}
    EndIf

    If !Empty(nMajorUnit)
        ::oKendoAxis['majorUnit'] := nMajorUnit
    EndIf
    
    If !Empty(nLblRotat)
        ::oKendoAxis['labels'] := JsonObject():New()
        ::oKendoAxis['labels']['rotation'] := nLblRotat
        ::oKendoAxis['labels']['font'] := cFontLabel
    EndIf

    ::oKendoAxis['notes']                            := JsonObject():New()
    ::oKendoAxis['notes']['icon']                    := JsonObject():New()
    ::oKendoAxis['notes']['icon']['border']          := JsonObject():New()
    ::oKendoAxis['notes']['icon']['border']['width'] := 0
    ::oKendoAxis['notes']['data']                    := {}

Return Self

/*/{Protheus.doc} AddNoteAxis 
Implementação do metodo qe adiciona notes da classe KendoAxis
@author rafael.kleestadt
@since 07/07/2020
@version 1.0
@param cEixo, caractere, eixo que esta sendo manipulado(x ou y)
@param nMin, number, posição minima do eixo que esta sendo manipulado(x ou y)
@param nMax, number, posição maxima do eixo que esta sendo manipulado(x ou y)
@param nStep, number, degrau das marcações do eixo 
@return return_var, return_type, return_description
/*/
Method AddNoteAxis(nValue, cNote, cColor, cDashType, nLinLength) Class KendoAxis

    Local oNote as object

    oNote := JsonObject():New()

    oNote['line']             := JsonObject():New()
    oNote['line']['color']    := cColor
    oNote['line']['dashType'] := cDashType
    oNote['value']            := nValue
    oNote['line']['length']   := nLinLength
    oNote['label']            := JsonObject():New()
    oNote['label']['text']    := cNote

    Aadd(::oKendoAxis['notes']['data'], oNote)

Return

/*/{Protheus.doc} GetAxis
Getter do atributo oKendoAxis da classe KendoAxis
@author rafael.kleestadt / lucas.briesemeister
@since 30/04/2020
@version 1.0
@param param_name, param_type, param_descr
@return oKendoAxis, object, objeto com as propriedades do eixo configurado
/*/
Method GetAxis() Class KendoAxis
Return ::oKendoAxis
