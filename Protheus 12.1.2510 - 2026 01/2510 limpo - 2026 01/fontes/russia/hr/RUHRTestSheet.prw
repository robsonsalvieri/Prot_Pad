#INCLUDE "PROTHEUS.CH"


Static aTests := {"SNILS_VldTest()", "MilitaryID_VldTest()", "BankAccountNumber_VldTest()"}


Function RUHRTEST()
    Local lResult As Logical
    Local nI As Numeric
    Local bFunc As Block
    Local cName As Char

    lResult := .T. 

    For nI := 1 To Len(aTests)
        If lResult
            cName := "{ || " + aTests[nI] + " }"
            bFunc := &cName
            lResult := Eval(bFunc)
        Else
            UserException("Function " + aTests[nI-1] + "failed")
        EndIf
    Next nI

Return lResult



Static Function SNILS_VldTest()
    Local lResult As Logical

    lResult := .F.

    lResult     := RU99X02SNILS("789 608 151 70")
    If lResult  != RU99X02SNILS("435 226 517 74")
        lResult := RU99X02SNILS("806-332-841 87")
    EndIf

Return lResult


Static Function MilitaryID_VldTest()
    Local lResult As Logical

    lResult := .F.

    lResult     := RU99X04MID(chr(195)+chr(196)+"789 608 1")
    If lResult  != RU99X04MID("4232444444")
        lResult := RU99X04MID(chr(195)+chr(196)+chr(185)+"8063328")
    EndIf

Return lResult

Static Function BankAccountNumber_VldTest()
    Local lResult As Logical

    lResult := .F.

    lResult     := RU99X05ACC("40702810838120108695", "044525225")
    If lResult  != RU99X05ACC("01234567890123456789", "045402751")
        lResult := RU99X05ACC("40502810238000130020", "044525225")
    EndIf

Return lResult