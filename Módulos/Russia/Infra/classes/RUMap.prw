#INCLUDE "PROTHEUS.CH"

/*/
{Protheus.doc} RuMap
    Custom THashMap realization with safe GetValue method

    @type Class
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
/*/
Class RuMap From THashMap
    Data cClassName As Char

    Method New() Constructor

    Method ClassName()
    Method GetValue(xKey)
    Method Contains(xKey)
    Method Keys()
    Method Implode(cDelimeter)

EndClass

/*/
{Protheus.doc} New()
    Default RUMap constructor

    @type Method
    @params
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
    @return oRUMap,    Object,    Empty RUMap instance
/*/
Method New() Class RUMap
    :New()
    ::cClassName := "RUMap"
Return Self

/*/
{Protheus.doc} ClassName()
    Returns name of the class

    @type Method
    @params
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
    @return cClassName,    Char,    Name of RUMap class
/*/
Method ClassName() Class RUMap
Return ::cClassName

/*/
{Protheus.doc} GetValue()
    Returns stored value by given key or Nil in case of its absence.

    @type Method
    @params xKey,    Undefined,    Key (can be Numeric, Char or Date)
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
    @return xResult,    Undefined,    Stored value or Nil
/*/
Method GetValue(xKey) Class RUMap
    Local xValue
    Local xResult

    If ::Get(xKey, xValue)
        xResult := xValue
    Else
        xResult := Nil
    EndIf

Return xResult

/*/
{Protheus.doc} GetValue()
    Check if hashmap contains given key

    @type Method
    @params xKey,    Undefined,    Key (can be Numeric, Char or Date)
    @author dtereshenko
    @since 10/16/2019
    @version 12.1.23
    @return lResult,    Logical,    Verification result
/*/
Method Contains(xKey) Class RUMap
    Local lResult As Logical
    Local xValue

    lResult := ::Get(xKey, xValue)

Return lResult

/*/
{Protheus.doc} Keys()
    Returns array of hashmap keys

    @type Method
    @params
    @author dtereshenko
    @since 10/16/2019
    @version 12.1.23
    @return aKeys,    Array,    Array of hashmap keys
/*/
Method Keys() Class RUMap
    Local aItems As Array
    Local aKeys As Array
    Local nI As Numeric

    ::List(aItems)

    aKeys := {}

    For nI := 1 To Len(aItems)
        AAdd(aKeys, aItems[nI][1])
    Next nI

Return aKeys

/*
{Protheus.doc} Implode(cDelimeter As Char)
    Packs up maps elements into string separated by transfered delimeter

    @type Method
    @params cDelimeter   Char   Separator between elements
    @return cContent     Char   String with full content of the map
    @author dtereshenko
    @since 2020/09/10
    @version 12.1.23
*/
Method Implode(cDelimeter) Class RUMap
    Local aItems As Array
    Local nI As Numeric
    Local uKey
    Local uValue
    Local cContent := ""

    ::List(aItems)

    For nI := 1 To Len(aItems)
        uKey := aItems[nI][1]
        uValue := aItems[nI][2]

        If ValType(uKey) == "D"
            uKey := DToS(uKey)
        ElseIf ValType(uKey) == "N"
            uKey := CValToChar(uKey)
        EndIf

        If ValType(uValue) == "O"
            uValue := "Object"
        ElseIf ValType(uValue) == "U"
            uValue := "Null"
        ElseIf ValType(uValue) == "D"
            uValue := DToS(uValue)
        ElseIf ValType(uValue) == "N"
            uValue := CValToChar(uValue)
        EndIf

        cContent += uKey + "=" + uValue + cDelimeter
    Next nI

Return cContent

/*/
{Protheus.doc} RUMap_GetValueTest()
    RUMap:GetValue unit test

    @type Function
    @params
    @author dtereshenko
    @since 09/30/2019
    @version 12.1.23
    @return lResult,    Logical,    Test result
/*/
Function RUMap_GetValueTest()
    Local oMap As Object
    Local cTestKey As Char
    Local cTestValue As Char
    Local lResult As Logical

    cTestKey := "TestKey"
    cTestValue := "TestValue"

    oMap := RUMap():New()
    oMap:Set(cTestKey, cTestValue)

    lResult := ( oMap:GetValue(cTestKey) == cTestValue )

Return lResult
