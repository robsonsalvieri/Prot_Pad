#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07T13RUS.CH"

/*/
{Protheus.doc} RUHRElnXMLReader

    Class for reading xml of ELN.

    @type Class
    @author dchizhov
    @since 15.11.2023
    @version 12.1.33
/*/
Class RUHRElnXMLReader From LongNameClass

    Data aTablePerson As Array     // Array of reading person
    Data aPerson      As Array     // Array data of current reading person
    Data oXMLReader   As Object    // TXMLManager
    Data cPathXML     As Character // Path to XML-file
    Data aCompType    As Array     // Array of complex types storing the necessary information
    Data cError       As Character // Error message
    Data nDepthsElem  As Numeric
    Data nCSE         As Numeric   // Count system element in array of person
    
    Method New(cPath) Constructor
    Method ReadXML()
    Method ReadComplexXML(oXML)
    Method ReadElemXML(oXML)
    Method ReadPeriodsXML(oXML)
    Method ReadChildsXML(oXML)

    Method LoadPerFromDictionary()

    Method PersInitialize()
    Method GetStateEmplByCode(cCode)
    Method Destroy()

EndClass

/*/
{Protheus.doc} New(cPath)

    Default constructor.

    @type Method
    @params cPath, Character, Path to XML.
    @author dchizhov
    @since 15.11.2023
    @version 12.1.33
    @return RUHRElnXMLReader, Object, RUHRElnXMLReader instance.
    @example RUCalcAbsenceType := RUCalcAbsenceType():New(cType, cPD, cID, dStart, dFinish)
/*/
Method New(cPath) Class RUHRElnXMLReader

    Self:oXMLReader   := TXMLManager():New()
    Self:cPathXML     := cPath
    Self:aTablePerson := {}
    Self:aPerson      := ::PersInitialize()
    Self:nCSE         := 2
    Self:nDepthsElem  := 0
    Self:aCompType    := {"getPrivateLNDataResponse",;
                            "fileOperationsLnUserGetPrivateLNDataOut", ;
                            "data", ;
                            "outRowset", ;
                            "treatPeriods", ;
                            "treatFullPeriod", ;
                            "servData" }

Return Self

/*/
{Protheus.doc} ReadXML()

    This method Parse XML and write result into Array of class.

    @type Method
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return lSuccess, Logical, Success parse XML.
    @example lSuccess := oXMLReader:ReadXML()
/*/
Method ReadXML() Class RUHRElnXMLReader
    
    Local lSuccess As Logical
    Local nCount   As Numeric
    Local nNode    As Numeric

    lSuccess := ::oXMLReader:ParseFile(::cPathXML)

    If lSuccess
        nCount := ::oXMLReader:DOMSiblingCount()

        For nNode := 1 To nCount
            lSuccess := ::ReadComplexXML(::oXMLReader)
            If lSuccess .And. nNode < nCount
                lSuccess := ::oXMLReader:DOMNextNode()
            EndIf
        Next nNode
    EndIf
    If !lSuccess
        ::cError := ::oXMLReader:Error()
    EndIf

Return lSuccess

/*/
{Protheus.doc} ReadComplexXML(oXML)

    This method Parse XML and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object? which reading).
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return 
    @example ::ReadComplexXML(::oXMLReader)
/*/
Method ReadComplexXML(oXML) Class RUHRElnXMLReader

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local lReturn As Logical

    Begin Sequence
        lReturn := oXML:DOMChildNode()
        nCount := oXML:DOMSiblingCount()
        For nNode := 1 To nCount
            If !lReturn
                Break
            ElseIf AScan(::aCompType, {|X| X == oXML:cName}) > 0
                lReturn := ::ReadComplexXML(oXML)
            ElseIf oXML:cName == "responseRow" .Or. oXML:cName == "row"
                lReturn := ::ReadElemXML(oXML)
            ElseIf oXML:cName == "treatPeriod"
                ::ReadPeriodsXML(oXML)
            ElseIf oXML:cName == "servFullData"
                ::ReadChildsXML(oXML)
            ElseIf AScan(::aPerson, {|X| X[1] == oXML:cName}, 3) > 1 .Or. oXML:cName == "treatDt1" .Or. oXML:cName == "treatDt2"
                oXML:DOMParentNode()
                lReturn := ::ReadElemXML(oXML)
                Break
            EndIf
            lReturn := oXML:DOMNextNode() .Or. nNode >= nCount
        Next nNode
        oXML:DOMParentNode()
    End Sequence

Return lReturn

/*/
{Protheus.doc} ReadElemXML(oXML)

    This method Parse XML and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object? which reading).
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return lReturn, Logical, IsSuccess
    @example ::ReadElemXML(oXML)
/*/
Method ReadElemXML(oXML) Class RUHRElnXMLReader

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local nItem   As Numeric
    Local lReturn As Logical
    Local lParent As Logical

    lReturn := oXML:DOMChildNode()
    nCount := oXML:DOMSiblingCount()
    nNode := 1
    lParent := .T.
    ::nDepthsElem += 1

    While nNode <= nCount .And. lReturn
        If !lReturn
            Break
        EndIf
        nItem := AScan(::aPerson, {|X| X[1] == oXML:cName}, 3)
        If nItem > 1
            If ValType(::aPerson[nItem, 2]) == "D"
                ::aPerson[nItem, 2] := SToD(StrTran(oXML:cText, "-", ""))
                If Year(::aPerson[nItem, 2]) < 1990
                    ::aPerson[nItem, 2] := CTod("//")
                EndIf
            Else
                ::aPerson[nItem, 2] := oXML:cText
            EndIf
            // ::aPerson[nItem, 2] := Iif(oXML:cName == "lnDate", SToD(StrTran(oXML:cText, "-", "")), oXML:cText)
        ElseIf oXML:cName == "treatPeriods" .Or. oXML:cName == "servData"
            ::ReadComplexXML(oXML)
        ElseIf oXML:cName == "hospitalBreach"
            ::ReadElemXML(oXML)
        ElseIf oXML:cName == "treatPeriod"
            ::ReadPeriodsXML(oXML)
        ElseIf oXML:cName == "servFullData"
            ::ReadChildsXML(oXML)
        ElseIf oXML:cName == "treatDt1" .Or. oXML:cName == "treatDt2"
            oXML:DOMParentNode()
            ::ReadPeriodsXML(oXML)
            Exit
        EndIf
        nNode += 1
        lReturn := oXML:DOMNextNode() .Or. nNode > nCount
    EndDo
    If lReturn .And. ::nDepthsElem == 1
        Aadd(::aTablePerson, ::aPerson)
        ::aPerson := ::PersInitialize()
    EndIf
    If lParent
        oXML:DOMParentNode()
    EndIf
    ::nDepthsElem -= 1

Return lReturn

/*/
{Protheus.doc} ReadPeriodsXML(oXML)

    This method Parse XML (read periods) and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object? which reading).
    @params lPer, Logical, Periods.
    @author dchizhov
    @since 16.11.2023
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example ::ReadPeriodsXML(oXML)
/*/
Method ReadPeriodsXML(oXML) Class RUHRElnXMLReader

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local aPeriod As Array
    Local lReturn As Logical

    Default lPer := .F.

    lReturn := oXML:DOMChildNode()
    nCount := oXML:DOMSiblingCount()
    nNode := 1
    aPeriod := {CToD("//"),CToD("//")}

    While nNode <= nCount .And. lReturn
        If oXML:cName == "treatDt1"
            aPeriod[1] := SToD(StrTran(oXML:cText, "-", ""))
        ElseIf oXML:cName == "treatDt2"
            aPeriod[2] := SToD(StrTran(oXML:cText, "-", ""))
        EndIf
        nNode += 1
        lReturn := oXML:DOMNextNode() .Or. nNode > nCount
    EndDo
    If lReturn
        If Year(aPeriod[1]) < 1990
            aPeriod[1] := CTod("//")
        EndIf
        If Year(aPeriod[2]) < 1990
            aPeriod[2] := CTod("//")
        EndIf
        Aadd(::aPerson[2], aPeriod)
    EndIf
    oXML:DOMParentNode()

Return lReturn

/*/
{Protheus.doc} ReadChildsXML(oXML)

    This method Parse XML (read part by child) and write result into Array of class.

    @type Method
    @params oXML, Object, Object for read xml (current object? which reading).
    @params lPer, Logical, Periods.
    @author dchizhov
    @since 13.13.2023
    @version 12.1.23.10
    @return lReturn, Logical, IsSuccess
    @example ::ReadChildsXML(oXML)
/*/
Method ReadChildsXML(oXML) Class RUHRElnXMLReader

    Local nCount  As Numeric
    Local nNode   As Numeric
    Local nItem   As Numeric
    Local lReturn As Logical

    Default lPer := .F.

    lReturn := oXML:DOMChildNode()
    nCount := oXML:DOMSiblingCount()
    nNode := 1

    While nNode <= nCount .And. lReturn
        If oXML:cName == "reason1"
            nItem := AScan(::aPerson, {|X| X[1] == oXML:cName}, 3)
            If Empty(::aPerson[nItem, 2])
                ::aPerson[nItem, 2] := oXML:cText
            EndIf
        EndIf
        nNode += 1
        lReturn := oXML:DOMNextNode() .Or. nNode > nCount
    EndDo
    oXML:DOMParentNode()

Return lReturn

/*/
{Protheus.doc} LoadPerFromDictionary()

    This method Load data from employee dictionary.

    @type Method
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return lReturn, Logical, IsSuccess
    @example lSuccess := oXMLReader:LoadPerFromDictionary()
/*/
Method LoadPerFromDictionary() Class RUHRElnXMLReader

    Local lResult  As Logical
    Local lSeeAll  As Logical
    Local nOrder   As Numeric
    Local nI       As Numeric
    Local cKey     As Character
    Local aArea    As Array
    Local aSRAArea As Array

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    DbSelectArea("SRA")
    nOrder := RetOrdem("SRA", "RA_CIC")
    SRA->(DbSetOrder(nOrder))

    // cKey := xFilial("SRA") + ::aTablePerson[1, 2, 2]
    For nI := 1 To Len(::aTablePerson)
        cKey := ::aTablePerson[nI, ::nCSE + 1, 2]
        If SRA->(DbSeek(cKey, .T.))
            Aadd(::aTablePerson[nI, 1], SRA->RA_MAT)
            Aadd(::aTablePerson[nI, 1], SRA->RA_FILIAL)
            Aadd(::aTablePerson[nI, 1], SRA->RA_CIC)
            Aadd(::aTablePerson[nI, 1], SRA->RA_NOMECMP)
            Aadd(::aTablePerson[nI, 1], ::GetStateEmplByCode(SRA->RA_SITFOLH))
            Aadd(::aTablePerson[nI, 1], SRA->RA_PROCES)
            Aadd(::aTablePerson[nI, 1], CValToChar(SRA->(RecNo())))
        Else
            Aadd(::aTablePerson[nI, 1], Space(TamSX3("RA_MAT")[1]))
            Aadd(::aTablePerson[nI, 1], Space(TamSX3("RA_FILIAL")[1]))
            Aadd(::aTablePerson[nI, 1], Space(TamSX3("RA_CIC")[1]))
            Aadd(::aTablePerson[nI, 1], Space(TamSX3("RA_NOMECMP")[1]))
            Aadd(::aTablePerson[nI, 1], STR0014) // "NO"
            Aadd(::aTablePerson[nI, 1], Space(TamSX3("RA_PROCES")[1]))
            Aadd(::aTablePerson[nI, 1], Space(10))
        EndIf
    Next nI
    
    lResult := .T.

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lResult



/*/
{Protheus.doc} PersInitialize()

    This method Create empty array for Person.

    @type Method
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return aPerson, Array, Empty Array for Person data.
    @example Self:aPerson := ::PersInitialize()
/*/
Method PersInitialize() Class RUHRElnXMLReader

    Local aPerson As Array
    
    aPerson := {{}, {}, {"snils", ""}, {"surname", ""}, {"name", ""}, {"patronymic", ""}, {"lnCode", ""}, ;
    {"lnDate", CToD("//")}, {"reason1", ""}, {"lnState", ""}, {"lpuName", ""}, {"idMo", ""}, ;
    {"lpuOgrn", ""}, {"dt1Ln", CToD("//")}, {"dt2Ln", CToD("//")}, {"hospitalBreachDt", CToD("//")}}

Return aPerson

/*/
{Protheus.doc} GetStateEmplByCode(cCode)

    This method Create empty array for Person.

    @type Method
    @params cCode, Character, Code of state employee.
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @return cRet, Character, Description of state by employee.
    @example Aadd(::aTablePerson[nI, 1], GetStateEmplByCode(SRA->RA_SITFOLH))
/*/
Method GetStateEmplByCode(cCode) Class RUHRElnXMLReader

    Local cKey As Character
    Local cRet As Character

    cKey := AllTrim(cCode)

    Do Case
        Case Empty(cKey)
            cRet := STR0017 // "WORKS"
        Case cKey == "A"
            cRet := STR0016 // "ABSENCE"
        Case cKey == "D"
            cRet := STR0015 // "FIRED"
        OtherWise
            cRet := FDesc("SX5", "31" + SRA->RA_SITFOLH, "X5DESCRI()", , SRA->RA_FILIAL)
    EndCase

Return cRet

/*/
{Protheus.doc} Destroy()

    Destructor.

    @type Method
    @author dchizhov
    @since 16.11.2023
    @version 12.1.33
    @example oXMLReader:Destroy()
/*/
Method Destroy() Class RUHRElnXMLReader

    FreeObj(::aTablePerson)
    FreeObj(::aPerson)
    FreeObj(::aCompType)
    FreeObj(::oXMLReader)

    ::aTablePerson := Nil
    ::aPerson := Nil
    ::aCompType := Nil
    ::oXMLReader := Nil

Return 
