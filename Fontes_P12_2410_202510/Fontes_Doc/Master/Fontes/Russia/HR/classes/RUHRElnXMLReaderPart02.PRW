#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07T14RUS.CH"

/*/
{Protheus.doc} RUHRElnDataForElnItem

    Class storing data for ELN item.

    @type Class
    @author dchizhov
    @since 06.02.2024
    @version 12.1.23.10
/*/
Class RUHRElnDataForElnItem From LongNameClass

    Data cTypeOfItem  As Character  // Type of item
    Data cNumberOfELN As Character // Number of ELN
    Data cSNILS       As Character // SNILS (RA_CIC)
    Data cNome        As Character // Name (RA_NOMECMP)
    Data nCDays       As Numeric   // Count base days for calculation
    Data aLastYear    As Numeric   // Income for last two year ({year, income}, {year, income})
    Data nYExperience As Numeric   // Year of experience
    Data nMExperience As Numeric   // Mounth of experience
    Data nRegKoeff    As Numeric   // Regional koefficient
    Data nKoeffNNWT   As Numeric   // Koefficient of non full working time
    Data dDateStart   As Date      // Income for the second year from previous years
    Data dDateFin     As Date      // Income for the second year from previous years

    Method New(cType) Constructor

    Method Validate(lSee)
    Method SetDefEmptyVal()

EndClass

/*/
{Protheus.doc} New(cType)

    Default constructor.

    @type Method
    @params cType, Character, Type of element.
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @return RUHRElnXMLReaderPart02, Object, RUHRElnXMLReaderPart02 instance.
    @example Private oRU07XFU01 := RUHRElnDataForElnItem():New("01")
/*/
Method New(cType) Class RUHRElnDataForElnItem

    Self:cTypeOfItem := cType
    Self:aLastYear := {{Nil, Nil}, {Nil, Nil}}
    Self:SetDefEmptyVal()

Return Self

/*/
{Protheus.doc} SetDefEmptyVal()

    Set default (empty) value.

    @type Method
    @params
    @author dchizhov
    @since 13.02.2024
    @version 12.1.23.10
    @return
    @example Private oRU07XFU01 := RUHRElnDataForElnItem():New("01")
/*/
Method SetDefEmptyVal() Class RUHRElnDataForElnItem

    Self:cNumberOfELN := Nil
    Self:cSNILS := Nil
    Self:cNome := Nil
    Self:nCDays := Nil
    Self:aLastYear[1, 1] := Nil
    Self:aLastYear[1, 2] := Nil
    Self:aLastYear[2, 1] := Nil
    Self:aLastYear[2, 2] := Nil
    Self:nYExperience := Nil
    Self:nMExperience := Nil
    Self:nRegKoeff := -1
    Self:nKoeffNNWT := Nil
    Self:dDateStart := Nil
    Self:dDateFin := Nil

Return .T.

/*/
{Protheus.doc} Validate(lSee)

    This method check of filling data.

    @type Method
    @params lSee, Logical, See message of warning.
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @return lSuccess, Logical, All data is filling.
    @example oXMLReader := RUHRElnXMLReaderPart02():New(cPath)
/*/
Method Validate(lSee) Class RUHRElnDataForElnItem

    Local lSeeMess As Logical
    Local lSuccess As Logical

    lSeeMess:= !IsBlind() .And. lSee
    If ::cTypeOfItem =="01"
        lSuccess :=  ValType(::cNumberOfELN) == "U" .Or. ValType(::cSNILS) == "U" .Or. ValType(::cNome) == "U" .Or. ValType(::nCDays) == "U" .Or. ValType(::nYExperience) == "U" ;
        .Or. ValType(::nMExperience) == "U" .Or. ValType(::nRegKoeff) == "U" .Or. ::nRegKoeff <= 0 .Or. /*ValType(::nKoeffNNWT) == "U" .Or.*/ ValType(::dDateStart) == "U" ;
        .Or. ValType(::dDateFin) == "U" .Or. ValType(::aLastYear[1, 1]) == "U" .Or. ValType(::aLastYear[1, 2]) == "U" ;
        .Or. ValType(::aLastYear[2, 1]) == "U" .Or. ValType(::aLastYear[2, 2]) == "U" 
        lSuccess := !lSuccess
    EndIf

    If lSeeMess .And. !lSuccess
        MsgInfo(STR0047, STR0046) // "Not all required fields are filled in", "Warning"
    EndIf

Return lSuccess

/*/
{Protheus.doc} RUHRElnXMLReaderPart02

    Class for reading xml of ELN.

    @type Class
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
/*/
Class RUHRElnXMLReaderPart02 From LongNameClass

    Data aTableData As Array       // Array of reading person
    Data oXMLReader   As Object    // TXMLManager
    Data cPathXML     As Character // Path to XML-file
    Data cTypeOfRead  As Character // Path to XML-file
    Data aCompType    As Array     // Array of complex types storing the necessary information
    Data aSimpleType  As Array     // Array of simple types storing the necessary information
    Data aSpecType    As Array     // Array of special types (this type need of special logic)
    Data aListOfNameS As Array     // Array of Name Space
    Data cError       As Character // Error message
    Data cUnexeptErr  As Character // Error message (not from reader)
    Data nDepthsElem  As Numeric   // Depth of reading
    Data nCSE         As Numeric   // Count system element in array of person
    Data oJsonStruct  As Object    // Json corresponds to the CML structure required for reading.
    
    Method New(cPath, cType) Constructor
    Method ReadXML()
    Method PreReadXML(oXML, oJson)
    Method ReadComplexXML(oXML, oJson)
    Method ReadElemXML(oXML, oJson)
    Method ReadSpecElemXML(oXML, oJson)
    Method ReaderAttr001(oWJson, oXML, oJson)

    Method GetListComplexType()
    Method GetListSimpleType()
    Method GetListSpecType()
    Method Build01JsonStructXml01()
    Method ChangeNameSpaceJson(oJson, cNameFrom, cNameTo)
    Method BuildJsonFromXml(oXMLPath)
    Method GetStructOfNeedData()
    Method GetListNameSpace(oXML)
    Method GetNameAndNS(oXML, cNS)

    Method SpecialReader001(oXML, oJson)

    Method AddRemoveStack(nType, cName)
    Method GetError(e, lErro, cError)
    Method Destroy()

EndClass

/*/
{Protheus.doc} New(cPath, cType)

    Default constructor.

    @type Method
    @params cPath, Character, Path to XML.
    @params cType, Character, Type of reader XML.
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @return RUHRElnXMLReaderPart02, Object, RUHRElnXMLReaderPart02 instance.
    @example oXMLReader := RUHRElnXMLReaderPart02():New(cPath)
/*/
Method New(cPath, cType) Class RUHRElnXMLReaderPart02

    Self:oXMLReader   := TXMLManager():New()
    Self:cPathXML     := cPath
    Self:cTypeOfRead  := cType
    Self:aTableData   := {{1}}
    Self:nCSE         := 1
    Self:nDepthsElem  := 0
    Self:aCompType    := Self:GetListComplexType()
    Self:aSimpleType  := Self:GetListSimpleType()
    Self:aSpecType    := Self:GetListSpecType()
    Self:cUnexeptErr  := ""

Return Self

/*/
{Protheus.doc} ReadXML()

    This method Parse XML and write result into Array of class.

    @type Method
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @return lSuccess, Logical, Success parse XML.
    @example lSuccess := oXMLReader:ReadXML()
/*/
Method ReadXML() Class RUHRElnXMLReaderPart02
    
    Local lSuccess As Logical
    Local lNReadEl As Logical
    Local nCount   As Numeric
    Local nNode    As Numeric
    Local bError   As Block

    lSuccess := ::oXMLReader:ParseFile(::cPathXML)
    lNReadEl := .T.
    ::aListOfNameS := ::GetListNameSpace(::oXMLReader)
    ::oJsonStruct := ::Build01JsonStructXml01()

    If lSuccess
        nCount := ::oXMLReader:DOMSiblingCount()
        bError := ErrorBlock( { |e| ::GetError(e, @lReturn, @::cUnexeptErr) } )
        Begin Sequence
            For nNode := 1 To nCount
                If ::oJsonStruct:HasProperty(::oXMLReader:cName) .And. ::oJsonStruct[::oXMLReader:cName]["complex"]
                    lSuccess := .F.
                    aAdd(::aTableData, ::GetStructOfNeedData())
                    ::aTableData[1, 1] += 1
                    lSuccess := ::ReadComplexXML(::oXMLReader, ::oJsonStruct[::oXMLReader:cName])
                    lNReadEl := .F.
                    ASort(::aTableData[::aTableData[1, 1]]["LastInfo"], , , { |X, Y| X["calc"]["value"] < Y["calc"]["value"]})
                EndIf

                If lSuccess .And. nNode < nCount
                    lSuccess := .F.
                    lSuccess := ::oXMLReader:DOMNextNode()
                EndIf
            Next nNode
            If lNReadEl
                While ::oXMLReader:DOMHasPrevNode()
                    ::oXMLReader:DOMPrevNode()
                EndDo
                lSuccess := ::PreReadXML(::oXMLReader, ::oJsonStruct)
            EndIf
        End Sequence
        ErrorBlock(bError)
    EndIf
    If !lSuccess
        ::cError := Iif(Empty(::cUnexeptErr), ::oXMLReader:Error(), ::cUnexeptErr)
    EndIf

Return lSuccess

/*/
{Protheus.doc} PreReadXML(oXML, oJson)

    This method read xml if in struct getting file there are elements before the supposed root.

    @type Method
    @params oXML, Object, Object for read xml (current object, which reading).
    @params oJson, Object, Json struct for read xml (current object, which reading).
    @author dchizhov
    @since 14.02.2024
    @version 12.1.23.10
    @return lSuccess, Logical, Is success
    @example lSuccess := ::PreReadXML(::oXMLReader, ::oJsonStruct)
/*/
Method PreReadXML(oXML, oJson) Class RUHRElnXMLReaderPart02

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local lSuccess As Logical
    Local cName   As Character
    Local cNSName As Character

    nCount := oXML:DOMSiblingCount()
    For nNode := 1 To nCount
        cName := ::GetNameAndNS(oXML, @cNSName)
        If !lSuccess
            Break
        ElseIf oJson:HasProperty(cName) .And. oJson[cName]["complex"] .And. oJson["node"][cName]["nameSpace"] == cNSName
            lSuccess := .F.
            aAdd(::aTableData, ::GetStructOfNeedData())
            ::aTableData[1, 1] += 1
            lSuccess := ::ReadComplexXML(oXML, oJson[cName])
            lNReadEl := .F.
            ASort(::aTableData[::aTableData[1, 1]]["LastInfo"], , , { |X, Y| X["calc"]["value"] < Y["calc"]["value"]})
        Else
            If oXML:DOMHasChildNode()
                lSuccess := oXML:DOMChildNode()
                If lSuccess
                    lSuccess := ::PreReadXML(oXML, oJson)
                    oXML:DOMParentNode()
                EndIf
            EndIf
        EndIf

        If lSuccess .And. nNode < nCount
            lSuccess := .F.
            lSuccess := oXML:DOMNextNode()
        EndIf
    Next nNode

Return lSuccess

/*/
{Protheus.doc} ReadComplexXML(oXML, oJson)

    This method Parse XML and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object, which reading).
    @params oJson, Object, Json struct for read xml (current object, which reading).
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @return lReturn, Logical, Is success
    @example lSuccess := ::ReadComplexXML(::oXMLReader, ::oJsonStruct[::oXMLReader:cName])
/*/
Method ReadComplexXML(oXML, oJson) Class RUHRElnXMLReaderPart02

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local lReturn As Logical
    Local cName   As Character
    Local cNSName As Character

    lReturn := oXML:DOMChildNode()
    nCount := oXML:DOMSiblingCount()
    ::nDepthsElem += 1
    For nNode := 1 To nCount
        cName := ::GetNameAndNS(oXML, @cNSName)
        If !lReturn
            Break
        ElseIf oJson["node"]:HasProperty(cName) .And. oJson["node"][cName]["nameSpace"] == cNSName
            If oJson["node"][cName]["exception"]
                lReturn := ::ReadSpecElemXML(oXML, oJson["node"][cName])
            ElseIf oJson["node"][cName]["complex"]
                lReturn := ::ReadComplexXML(oXML, oJson["node"][cName])
            Else
                lReturn := ::ReadElemXML(oXML, oJson["node"][cName])
            EndIf
        EndIf
        lReturn := oXML:DOMNextNode() .Or. nNode >= nCount
    Next nNode
    ::nDepthsElem -= 1
    oXML:DOMParentNode()

Return lReturn

/*/
{Protheus.doc} ReadElemXML(oXML, oJson)

    This method Parse XML and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object, which reading).
    @params oJson, Object, Json struct for read xml (current object, which reading).
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example lReturn := ::ReadElemXML(oXML, oJson)
/*/
Method ReadElemXML(oXML, oJson) Class RUHRElnXMLReaderPart02

    Local lReturn As Logical

    ::aTableData[2][oXML:cName] := JsonObject():New()
    If oJson["type"] == "C"
        ::aTableData[2][oJson["nameProperty"]]["value"] := oXML:cText
    ElseIf oJson["type"] == "N"
        ::aTableData[2][oJson["nameProperty"]]["value"] := Val(oXML:cText)
    ElseIf oJson["type"] == "D"
        ::aTableData[2][oJson["nameProperty"]]["value"] := SToD(StrTran(oXML:cText, "-", ""))
    EndIf
    ::ReaderAttr001(::aTableData[2][oXML:cName], oXML, oJson)
    
Return lReturn

/*/
{Protheus.doc} ReadSpecElemXML(oXML, oJson)

    This method Parse XML and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object, which reading).
    @params oJson, Object, Json struct for read xml (current object, which reading).
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example lReturn := ::ReadSpecElemXML(oXML, oJson)
/*/
Method ReadSpecElemXML(oXML, oJson) Class RUHRElnXMLReaderPart02

    Local lReturn As Logical
    Local lNExist As Logical

    lReturn := .T.
    lNExist := .T.
    If ::cTypeOfRead == "1"
        If oXML:cName == "year" .And. oJson["nameSpace"] $ "|integration:types:proactive:benefit1|integration:types:proactive:benefit2|"
            lNExist := .F.
            lReturn := ::SpecialReader001(oXML, oJson, {"calc", "baseSum"})
        EndIf
    EndIf
    If lNExist
        UserException(STR0040 + " " + oXML:cName) // "The following element could not be found in the given structure:"
    EndIf

Return lReturn

/*/
{Protheus.doc} ReaderAttr001(oWJson, oXML, oJson)

    This method reading attributte for element.

    @type Method
    @params oWJson, Object, Object in whitch write result.
    @params oXML,   Object, Object for read xml (current object, which reading).
    @params oJson,  Object, Json struct for read xml (current object, which reading).
    @author dchizhov
    @since 01.02.2024
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example ::ReaderAttr001(::aTableData[2][oXML:cName], oXML, oJson)
/*/
Method ReaderAttr001(oWJson, oXML, oJson) Class RUHRElnXMLReaderPart02
    
    Local lReturn As Logical
    Local aAttr   As Array
    Local nI      As Numeric

    lReturn := .T.

    If ::cTypeOfRead $"|1|"
        aAttr := {"editable", "required"}
        For nI := 1 To Len(aAttr)
            oWJson[aAttr[nI]] := Iif(Empty(oXML:DomGetAtt(aAttr[nI])), oJson[aAttr[nI]], Upper(oXML:DomGetAtt(aAttr[nI])) == "TRUE")
        Next nI
    EndIf
    
Return lReturn

/*/
{Protheus.doc} Method SpecialReader001(oXML, oJson)

    This method reading year from some types.

    @type Method
    @params oXML, Object, Object for read xml (current object, which reading).
    @params oJson, Object, Json struct for read xml (current object, which reading).
    @params aElem, Array, Array of element for reading.
    @author dchizhov
    @since 01.02.2024
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example lReturn := ::SpecialReader001(oXML, oJson)
/*/
Method SpecialReader001(oXML, oJson, aElem) Class RUHRElnXMLReaderPart02

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local nItem   As Numeric
    Local lReturn As Logical
    Local cName   As Character
    Local cNSName As Character
    Local cNElem  As Character
    Local oJsonYe As Object

    lReturn := oXML:DOMChildNode()
    nCount := oXML:DOMSiblingCount()
    oJsonYe := JsonObject():New()
    ::nDepthsElem += 1
    cNElem := ""
    For nNode := 1 To nCount
        cName := ::GetNameAndNS(oXML, @cNSName)
        If !lReturn
            Break
        ElseIf oJson["node"]:HasProperty(cName) .And. oJson["node"][cName]["nameSpace"] == cNSName
            nItem := AScan(aElem, {|X| X == cName})
            If nItem > 0
                oJsonYe[cName] := JsonObject():New()
                oJsonYe[cName]["value"] := oXML:cText
                ::ReaderAttr001(oJsonYe[cName], oXML, oJson)
            EndIf
        EndIf
        lReturn := oXML:DOMNextNode() .Or. nNode >= nCount
    Next nNode
    If lReturn
        AEval(aElem, {|X| cNElem += Iif(oJsonYe:HasProperty(X), "", X + CRLF)})
        If Empty(cNElem)
            aAdd(::aTableData[2]["LastInfo"], oJsonYe)
        Else
            UserException(STR0041 + CRLF + cNElem) // "Element not found in XML:"
        EndIf
    EndIf
    ::nDepthsElem -= 1
    oXML:DOMParentNode()

Return lReturn

/*/
{Protheus.doc} GetStructOfNeedData()

    This method create new line for data table.

    @type Method
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return xReturn
    @example Self:aTableData := {, Self:GetStructOfNeedData()}
/*/
Method GetStructOfNeedData() Class RUHRElnXMLReaderPart02

    Local xReturn As Object

    xReturn := JsonObject():New()
    
    If Self:cTypeOfRead == "1"
        xReturn:FromJson('{"socialAssistNum":{}, "code":{}, "snils":{}, "lastName":{}, "firstName":{}, ' + ;
        '"middleName":{}, "insurYY":{}, "insurMM":{}, "baseCalcDays":{}, "kfReg":{}, "kfShortDays":{}, "begin":{}, "end":{}}')
        xReturn["LastInfo"] := {}
    EndIf

Return xReturn

/*/
{Protheus.doc} GetListSimpleType()

    This method create array of simple type.

    @type Method
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return oReturn, Object, Json object for data.
    @example Self:aSimpleType  := Self:GetListSimpleType()
/*/
Method GetListSimpleType() Class RUHRElnXMLReaderPart02

    Local aReturn As Array

    If Self:cTypeOfRead == "1"
        aReturn := {{"code", "integration:types:proactive:benefit1"}, {"snils", "integration:types:proactive:benefit1"}, ;
        {"lastName", "integration:types:person"}, {"firstName", "integration:types:person"}, {"middleName", "integration:types:person"}, ;
        {"insurYY", "integration:types:proactive:benefit1"}, {"insurMM", "integration:types:proactive:benefit1"}, ;
        {"kfReg", "integration:types:proactive:benefit1"}, {"kfShortDays", "integration:types:proactive:benefit1"}, ;
        {"begin", "integration:types:proactive:benefit1"}, {"end", "integration:types:proactive:benefit1"}}
    EndIf

Return aReturn

/*/
{Protheus.doc} GetListSimpleType()

    This method create array of complex type.

    @type Method
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return oReturn, Object, Json object for data.
    @example Self:aSimpleType  := Self:GetListSimpleType()
/*/
Method GetListComplexType() Class RUHRElnXMLReaderPart02

    Local aReturn As Array

    If Self:cTypeOfRead == "1"
        aReturn := {{"integration:types:proactive", "confirmationRequest"}, ;
        {"integration:types:proactive:benefit1", "benefit1Approve", "elnInfo", "insuredInfo", "fullName", "calculationData", "years", "experience", "payPeriodFSS"}, ;
        {"benefit2Approve"}, {"benefit4Approve"}, {"benefit5Approve"}, {"benefit6Approve"}}
    EndIf

Return aReturn

/*/
{Protheus.doc} GetListSpecType()

    This method create array of special type (need special logic).

    @type Method
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return oReturn, Object, Json object for data.
    @example Self:aSimpleType  := Self:GetListSimpleType()
/*/
Method GetListSpecType() Class RUHRElnXMLReaderPart02

    Local aReturn As Array

    If Self:cTypeOfRead == "1"
        aReturn := {{"year", "integration:types:proactive:benefit1"}}
    EndIf

Return aReturn

/*/
{Protheus.doc} Build01JsonStructXml01()

    This method create Json fo struct of needable data from XML.

    @type Method
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return oJson, Object, Json object for data.
    @example ::oJsonStruct := ::Build01JsonStructXml01()
/*/
Method Build01JsonStructXml01() Class RUHRElnXMLReaderPart02

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()
    If Self:cTypeOfRead == "1"
        BeginContent var cJson
        {
            "confirmationRequest": {
                "nameSpace": "integration:types:proactive",
                "exception": false,
                "complex": true,
                "node": {
                    "socialAssistNum": {
                        "nameSpace": "integration:types:proactive",
                        "exception": false,
                        "complex": false,
                        "editable": false,
                        "required": true,
                        "nameProperty": "socialAssistNum",
                        "type": "C"
                    },
                    "benefit1Approve": {
                        "nameSpace": "integration:types:proactive:benefit1",
                        "exception": false,
                        "complex": true,
                        "node": {
                            "elnInfo": {
                                "nameSpace": "integration:types:proactive:benefit1",
                                "exception": false,
                                "complex": true,
                                "node": {
                                    "code": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": false,
                                        "required": true,
                                        "nameProperty": "code",
                                        "type": "C"
                                    }
                                }
                            },
                            "insuredInfo": {
                                "nameSpace": "integration:types:proactive:benefit1",
                                "exception": false,
                                "complex": true,
                                "node": {
                                    "snils": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": false,
                                        "required": true,
                                        "nameProperty": "snils",
                                        "type": "C"
                                    },
                                    "fullName": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": true,
                                        "node": {
                                            "firstName": {
                                                "nameSpace": "integration:types:person",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "firstName",
                                                "type": "C"
                                            },
                                            "lastName": {
                                                "nameSpace": "integration:types:person",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "lastName",
                                                "type": "C"
                                            },
                                            "middleName": {
                                                "nameSpace": "integration:types:person",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "middleName",
                                                "type": "C"
                                            }
                                        }
                                    }
                                }
                            },
                            "calculationData": {
                                "nameSpace": "integration:types:proactive:benefit1",
                                "exception": false,
                                "complex": true,
                                "node": {
                                    "baseCalcDays": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "nameProperty": "baseCalcDays",
                                        "type": "N"
                                    },
                                    "years": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": true,
                                        "node": {
                                            "year": {
                                                "nameSpace": "integration:types:proactive:benefit1",
                                                "exception": true,
                                                "complex": true,
                                                "node": {
                                                    "calc": {
                                                        "nameSpace": "integration:types:proactive:benefit1",
                                                        "exception": true,
                                                        "complex": false,
                                                        "editable": true,
                                                        "required": true,
                                                        "type": "C"
                                                    },
                                                    "baseSum": {
                                                        "nameSpace": "integration:types:proactive:benefit1",
                                                        "exception": true,
                                                        "complex": false,
                                                        "editable": true,
                                                        "required": true,
                                                        "type": "C"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    "kfReg": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": true,
                                        "required": true,
                                        "nameProperty": "kfReg",
                                        "type": "C"
                                    },
                                    "kfShortDays": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": true,
                                        "required": true,
                                        "nameProperty": "kfShortDays",
                                        "type": "C"
                                    },
                                    "experience": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": true,
                                        "node": {
                                            "insurYY": {
                                                "nameSpace": "integration:types:proactive:benefit1",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "insurYY",
                                                "type": "N"
                                            },
                                            "insurMM": {
                                                "nameSpace": "integration:types:proactive:benefit1",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "insurMM",
                                                "type": "N"
                                            }
                                        }
                                    },
                                    "payPeriodFSS": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": true,
                                        "node": {
                                            "begin": {
                                                "nameSpace": "integration:types:proactive:benefit1",
                                                "exception": false,
                                                "complex": false,
                                                "editable": true,
                                                "required": true,
                                                "nameProperty": "begin",
                                                "type": "D"
                                            },
                                            "end": {
                                                "nameSpace": "integration:types:proactive:benefit1",
                                                "exception": false,
                                                "complex": false,
                                                "editable": false,
                                                "required": true,
                                                "nameProperty": "end",
                                                "type": "D"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    "benefit2Approve":{
                        "nameSpace": "integration:types:proactive:benefit2",
                        "exception": false,
                        "complex": true,
                        "node": {
                            "elnInfo": {
                            },
                            "insuredInfo": {
                            },
                            "calculationData": {
                            },
                            "vacation": {
                                "nameSpace": "integration:types:proactive:benefit2",
                                "exception": false,
                                "complex": true,
                                "node": {
                                    "beginDate": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": true,
                                        "required": true,
                                        "nameProperty": "begin",
                                        "type": "D"
                                    },
                                    "endDate": {
                                        "nameSpace": "integration:types:proactive:benefit1",
                                        "exception": false,
                                        "complex": false,
                                        "editable": false,
                                        "required": true,
                                        "nameProperty": "end",
                                        "type": "D"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        EndContent
                                // ,
                    // "benefit4Approve":{
                    //     "nameSpace":,
                    //     "exception": false,
                    //     "node":[]
                    // },
                    // "benefit5Approve":{
                    //     "nameSpace":,
                    //     "exception": false,
                    //     "node":[]
                    // },
                    // "benefit6Approve":{
                    //     "nameSpace":,
                    //     "exception": false,
                    //     "node":[]
                    // }
        oJson:FromJson(cJson)
        // copying a similar structure
            cJson := oJson["confirmationRequest"]["node"]["benefit1Approve"]["node"]["elnInfo"]:ToJson()
            oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"]["elnInfo"]:FromJson(cJson)
            cJson := oJson["confirmationRequest"]["node"]["benefit1Approve"]["node"]["insuredInfo"]:ToJson()
            oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"]["insuredInfo"]:FromJson(cJson)
            cJson := oJson["confirmationRequest"]["node"]["benefit1Approve"]["node"]["calculationData"]:ToJson()
            oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"]["calculationData"]:FromJson(cJson)
            oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"]["calculationData"]["node"]:DelName("payPeriodFSS")
            ::ChangeNameSpaceJson(oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"], "integration:types:proactive:benefit1", "integration:types:proactive:benefit2")
        // end copying
    EndIf

Return oJson

/*/
{Protheus.doc} ChangeNameSpaceJson(oJson, cNameFrom, cNameTo)

    This method create Json fo struct of needable data from XML.

    @type Method
    @param oJson, Object, Json where namespace need change
    @param cNameFrom, Character, Namespace to change
    @param cNameTo, Character, Namespace to change to
    @author dchizhov
    @since 13.02.2024
    @version 12.1.23.10
    @return oJson, Object, Json object
    @example ::ChangeNameSpaceJson(oJson["confirmationRequest"]["node"]["benefit2Approve"]["node"], "integration:types:proactive:benefit1", "integration:types:proactive:benefit2")
/*/
Method ChangeNameSpaceJson(oJson, cNameFrom, cNameTo) Class RUHRElnXMLReaderPart02

    Local aTemp As Array
    Local nI    As Numeric

    If ValType(oJson) == "J"
        aTemp := oJson:GetNames()

        For nI := 1 To Len(aTemp)
            If aTemp[nI] == "nameSpace" 
                If oJson[aTemp[nI]] == cNameFrom
                    oJson[aTemp[nI]] := cNameTo
                EndIf
            Else
                ::ChangeNameSpaceJson(oJson[aTemp[nI]], cNameFrom, cNameTo)
            EndIf
        Next nI
    EndIf

Return oJson

/*/
{Protheus.doc} GetListNameSpace(oXML)

    This method get list of namespace.

    @type Method
    @param oXML, Object, XML from wich get list of namespace
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return aReturn, Array, List of namespace.
    @example ::aListOfNameS := ::GetListNameSpace(::oXMLReader)
/*/
Method GetListNameSpace(oXML) Class RUHRElnXMLReaderPart02

    Local aReturn As Array
    Local nI      As Numeric
    Local nInd    As Numeric

    If Self:cTypeOfRead $ "|1|"
        aReturn := oXML:DOMGetNsList()
        For nI := 1 To Len(aReturn)
            nInd := At("integration", aReturn[nI, 2])
            aReturn[nI, 2] := StrTran(SubStr(SubStr(aReturn[nI, 2], 1, RAt("v", aReturn[nI, 2]) - 2), nInd), "/", ":")
        Next nI
    EndIf

Return aReturn

/*/
{Protheus.doc} GetNameAndNS(oXML, cNS)

    This method get name and namespace current element.

    @type Method
    @param oXML, Object,    XML from wich get data
    @param cNS,  Character, Name space of element
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return cName, Character, Name of current element.
    @example Self:aSimpleType  := Self:GetListSimpleType()
/*/
Method GetNameAndNS(oXML, cNS) Class RUHRElnXMLReaderPart02

    Local cName As Character
    Local nInd  As Numeric

    cName := oXML:cName
    cNS := SubStr(oXML:cPath, 1, RAt(":", oXML:cPath) - 1)
    cNS := SubStr(cNS, RAt("/", oXML:cPath) + 1)
    nInd := AScan(::aListOfNameS, {|X| X[1] == cNS})
    If nInd > 0
        cNS := ::aListOfNameS[nInd, 2]
    Else
        UserException(STR0032 + " " + cNS + " '" + STR0033) // "namespace", not find in list
    EndIf

Return cName

/*/
{Protheus.doc} BuildJsonFromXml(oXMLPath)

    This method build json by struct of xsd. (developer helper function)

    @type Method
    @param oXML, Object, XML from wich get data
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return cJson, Character, Json.
    @example cJson := RUHRElnXMLReaderPart02():BuildJsonFromXml()
/*/
Method BuildJsonFromXml() Class RUHRElnXMLReaderPart02

    Local nNode   As Numeric
    Local nCount  As Numeric
    Local cName   As Numeric
    Local cNSName As Numeric
    Local lFirst  As Logical
    Local cJson   As Character
    Local cChild  As Character

    ::oXMLReader:DOMChildNode()
    nCount := ::oXMLReader:DOMSiblingCount()
    cJson := ""
    cChild := ""
    lFirst := .F.

    For nNode := 1 To nCount
        cName := ::GetNameAndNS(::oXMLReader, @cNSName)
        If (nIndex := AScan(::aCompType, {|X| X[1] == cNSName})) > 0 .And. AScan(::aCompType[nIndex], {|X| X == cName}, 2) > 0
            cChild := ::BuildJsonFromXml()
            cJson += Iif(lFirst, "," + CRLF, "") + '"' + cName + '": {' + CRLF + '"nameSpace": ' + '"' + cNSName + '",' + CRLF + '"exception": false,' + CRLF + ;
            '"complex": true,' + CRLF + '"node": {' + cChild + CRLF + '}' + CRLF + '}' + CRLF + '}'
            lFirst := .T.
        ElseIf AScan(::aSimpleType, {|X| X[1] == ::oXMLReader:cName}) > 0
            cJson += Iif(lFirst, "," + CRLF, "") + '"' + cName + '": {' + CRLF + '"nameSpace": ' + '"' + cNSName + '",' + CRLF + '"exception": false,' + CRLF + ;
            '"complex": false' + CRLF + '}'
            lFirst := .T.
        ElseIf AScan(::aSpecType, {|X| X[1] == ::oXMLReader:cName}) > 0
            cJson += Iif(lFirst, "," + CRLF, "") + '"' + cName + '": {' + CRLF + '"nameSpace": ' + '"' + cNSName + '",' + CRLF + '"exception": true,' + CRLF + ;
            '"complex": false' + CRLF + '}'
            lFirst := .T.
        EndIf
        cJson := "{" + CRLF + cJson + CRLF + "}"
        ::oXMLReader:DOMNextNode()
    Next nNode
    ::oXMLReader:DOMParentNode()

Return cJson

/*/
{Protheus.doc} GetError(e, lErro, cError)

    This method for getting error.

    @type Method
    @param e,      Object,    Object of error.
    @param lErro,  Logical,   Is error.
    @param cError, Character, Message of error.
    @author dchizhov
    @since 31.01.2024
    @version 12.1.23.10
    @return 
    @example Self:aSimpleType  := Self:GetListSimpleType()
/*/
Method GetError(e, lErro, cError) Class RUHRElnXMLReaderPart02

    lErro := e:gencode > 0
    cError += "Error:" + CRLF + CRLF +  e:description + CRLF + CRLF + "Stack:" + CRLF + e:errorstack + CRLF + CRLF
    Break

Return 

/*/
{Protheus.doc} Destroy()

    Destructor.

    @type Method
    @author dchizhov
    @since 30.01.2024
    @version 12.1.23.10
    @example oXMLReader:Destroy()
/*/
Method Destroy() Class RUHRElnXMLReaderPart02

    AEval(::aTableData, {|X| FreeObj(X), X := Nil})
    FreeObj(::aTableData)
    FreeObj(::aCompType)
    FreeObj(::aSimpleType)
    FreeObj(::aSpecType)
    FreeObj(::aListOfNameS)
    FreeObj(::oXMLReader)
    FreeObj(::oJsonStruct)

    ::aTableData := Nil
    ::aCompType := Nil
    ::aSimpleType := Nil
    ::aSpecType := Nil
    ::aListOfNameS := Nil
    ::oXMLReader := Nil
    ::oJsonStruct := Nil

Return 
