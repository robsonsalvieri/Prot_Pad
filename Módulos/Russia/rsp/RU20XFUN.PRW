#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU20XFUN.CH"



/*/{Protheus.doc} RU20XFUN02_fDescF6K()
    Returns the field description from F6K

    @type Function
    @param cTabName, Character, Code table.
           cKey, Character, Code table.
           nPosKey, Numeric, pos. start.
           nLenKey, Numeric, pos. end.
           nPosDesc, Numeric, pos. start.
           nLenDesc, Numeric, pos. end.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN02_fDescF6K(cTabName, cKey, nPosKey, nLenKey, nPosDesc, nLenDesc)
    Local cResult as Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character

    cResult := ""
    aArea := GetArea()

    If !Empty(cTabName)
        cSQL := "SELECT F6K_SEQUEN, F6K_CONTEU FROM " + RetSQLName("F6K") + " WHERE F6K_FILIAL = ? AND F6K_CODIGO = ?  AND D_E_L_E_T_=' ' ORDER BY F6K_SEQUEN "
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("F6K"))
        oStatement:SetString(2, cTabName)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        While !Eof() 
           
            If cKey == substr((cTab)->F6K_CONTEU, nPosKey, nLenKey)
                cResult := substr((cTab)->F6K_CONTEU, nPosDesc, nLenDesc)
            EndIf
            DbSkip()
            
        EndDo

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20XFUN03_WhenForSQSModule()
    Hides or reveals the field depending on the modules

    @type Function

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN03_WhenForSQSModule()
    Local aModuls as Array
    Local nMod07 as Numeric
    Local nMod40 as Numeric
    Local lRet as Logical

    lRet := .T.
    aModuls := FwMdLocRUS()

    nMod07 := Ascan(aModuls, {|x| x[01] == "07"} )
    nMod40 := Ascan(aModuls, {|x| x[01] == "40"} )

    If nMod07 > 0 .And. nMod40 > 0
        If aModuls[nMod07][02] == 1 .And. aModuls[nMod40][02] == 1
            lRet := .F.
        EndIf
    EndIf

Return lRet





/*/{Protheus.doc} RU20XFUN04_WhenForSQSModule()
    Hides or reveals the field depending on the modules

    @type Function

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN04_WhenForSQSModule()
    Local aModuls as Array
    Local nMod07 as Numeric
    Local nMod40 as Numeric
    Local lRet as Logical

    lRet := .T.
    aModuls := FwMdLocRUS()

    nMod07 := Ascan(aModuls, {|x| x[01] == "07"} )
    nMod40 := Ascan(aModuls, {|x| x[01] == "40"} )

    If nMod07 > 0 .And. nMod40 > 0
        If aModuls[nMod07][02] == 1 .And. aModuls[nMod40][02] == 1
            lRet := .F.
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} RU20XFUN05(cCode, nFunc)
    Check code in Table Registration

    @type Function
    @param cCode, Character, Code table.
           nFunc, Numeric, parametr cod.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN05(cCode, nFunc)
    Local cResult as Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character

    Local cTabNun as Character
    Local cTabNivel as Character


    cResult := ""
    aArea := GetArea()

    If !Empty(cCode)
        cSQL := "SELECT Q3_TABELA, Q3_TABNIVE, Q3_DESCSUM FROM " + RetSQLName("SQ3") + " WHERE Q3_FILIAL = ? AND Q3_CARGO = ?  AND D_E_L_E_T_=' '"

        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("SQ3"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        cTabNun := AllTrim((cTab)->Q3_TABELA)
        cTabNivel := AllTrim((cTab)->Q3_TABNIVE)

        If nFunc == 1
            cResult := AllTrim((cTab)->Q3_DESCSUM)
        ElseIf nFunc == 2
            cResult := AllTrim((cTab)->Q3_TABELA)
        ElseIf nFunc == 3
            cResult := AllTrim((cTab)->Q3_TABNIVE)
        EndIf

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf
    
    If nFunc == 4 .Or. nFunc == 5
        cSQL := "SELECT RB6_FAIXA,RB6_VALOR FROM " + RetSQLName("RB6") + " WHERE RB6_FILIAL= ? AND RB6_TABELA= ? AND RB6_NIVEL= ? AND D_E_L_E_T_=' ' ORDER BY RB6_FAIXA"

        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("RB6"))
        oStatement:SetString(2, cTabNun)
        oStatement:SetString(3, cTabNivel)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While (cTab)->(!Eof())
           
            If nFunc == 4 .And. AllTrim((cTab)->RB6_FAIXA) == '01'
                cResult := AllTrim((cTab)->RB6_VALOR)
            ElseIf nFunc == 5
                cResult := AllTrim((cTab)->RB6_VALOR)
            EndIf
            (cTab)->(DbSkip())
            
        EndDo
        
        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20XFUN06(cCode, nFunc)
    Returns salary skill and grades

    @type Function
    @param cCode, Character, Code table.
           nFunc, Numeric, parametr cod.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN06(cCode, nFunc)
    Local nResult as Numeric
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character

    Local cTabNun as Character
    Local cTabNivel as Character
    
    Local aSQ3Area As Array
    Local cAddrKey as Character
    Local cMemo as Character

    cTabNun := ""
    cTabNivel := ""

    cResult := ""
    aArea := GetArea()

    If !Empty(cCode)
        cSQL := "SELECT Q3_TABELA, Q3_TABNIVE, Q3_DESCSUM FROM " + RetSQLName("SQ3") + " WHERE Q3_FILIAL = ? AND Q3_CARGO = ?  AND D_E_L_E_T_=' '"

        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("SQ3"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        cTabNun := AllTrim((cTab)->Q3_TABELA)
        cTabNivel := AllTrim((cTab)->Q3_TABNIVE)
        cMemo := MSMM(SQ3->Q3_DHABILI,80,,,,,,"SQ3",,"RDY")
        M->QS_MSKILL := cMemo
        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    nResult := 0
    
    If (nFunc == 1 .Or. nFunc == 2) .And. !Empty(cTabNun) .And. !Empty(cTabNivel)
        cSQL := "SELECT RB6_FAIXA,RB6_VALOR FROM " + RetSQLName("RB6") + " WHERE RB6_FILIAL= ? AND RB6_TABELA= ? AND RB6_NIVEL= ? AND D_E_L_E_T_=' ' ORDER BY RB6_FAIXA"

        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("RB6"))
        oStatement:SetString(2, cTabNun)
        oStatement:SetString(3, cTabNivel)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While !Eof() 
            If nFunc == 1 .And. AllTrim((cTab)->RB6_FAIXA) == '01'
                nResult := (cTab)->RB6_VALOR
            ElseIf nFunc == 2
                nResult := (cTab)->RB6_VALOR
            EndIf
            DbSkip()
        EndDo
        
        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)

        RestArea(aArea)
    EndIf

Return nResult


/*/{Protheus.doc} RU20XFUN07(cCode, nFunc)
    Full name of the branch

    @type Function
    @param cCode, Character, Code table.
           nFunc, Numeric, parametr cod.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN07(cCode, nFunc)
    Local cResult as Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character
    Local cFil       As Character

    cResult := ''
    aArea := GetArea()

    If !Empty(cCode)
        cSQL := "SELECT BR_FULLNAM, BR_SHORTNM FROM SYS_BRANCH_L_RUS WHERE BR_COMPEMP = ? AND BR_COMPUNI= ? AND BR_BRANCH= ? AND D_E_L_E_T_=' '"
        cFil :=  M->QS_FILPOST
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, left(cFil,2))
        oStatement:SetString(2, SubStr(cFil,3,2))
        oStatement:SetString(3, right(cFil,2))
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        If nFunc == 1
            cResult := (cTab)->BR_FULLNAM
        ElseIf nFunc == 2
            cResult := (cTab)->BR_SHORTNM
        EndIf

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20XFUN08_RUSQSWHEN1()
    The function determines when a field can be opened for editing

    @type Function
    
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN08_RUSQSWHEN1()
    Local aModuls as Array
    Local nMod07 as Numeric
    Local nMod40 as Numeric
    Local lRet as Logical
    Local nX as Numeric

    lRet := .T.
    aModuls := FwMdLocRUS()

    For nX := 1 to Len(aModuls)
        If aModuls[nX][1] == 7
            nMod07 := aModuls[nX][2]
        EndIf

        If aModuls[nX][1] == 40
            nMod40 := aModuls[nX][2]
        EndIf
    Next

    If nMod07 > 0 .And. nMod40 > 0
        lRet := .F.
    EndIf

Return lRet




/*/{Protheus.doc} RU20XFUN09(cCode, nFunc)
    The function finds limits on salary grades

    @type Function
    @param cCode, Character, Code table.
           nFunc, Numeric, parametr cod.
           
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN09(cCode, nFunc)
    Local cResult as Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character
    Local cFil       As Character

    cResult := ''
    aArea := GetArea()

    If !Empty(cCode)
        cSQL := "SELECT BR_FULLNAM, BR_SHORTNM FROM SYS_BRANCH_L_RUS WHERE BR_COMPEMP = ? AND BR_COMPUNI= ? AND BR_BRANCH= ? AND D_E_L_E_T_=' '"
        cFil :=  M->QS_FILPOST
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, left(cFil,2))
        oStatement:SetString(2, SubStr(cFil,3,2))
        oStatement:SetString(3, right(cFil,2))
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        If nFunc == 1
            cResult := (cTab)->BR_FULLNAM
        ElseIf nFunc == 2
            cResult := (cTab)->BR_SHORTNM
        EndIf

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20XFUN10(cCode)
    Function to add job title

    @type Function
    @param cCode, Character, Code table.
           
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN10(cCode)
    Local cResult as Character

    Local aRCLArea As Array
    Local cAddrKey as Character

    aRCLArea := RCL->(GetArea())
    DbSelectArea("RCL")
    DbSetOrder(2) // RCL_FILIAL+RCL_POSTO
    DbGoTop()

    cAddrKey := M->QS_FILPOST + M->QS_POSTO

    If !Empty(Posicione("RCL", 2, cAddrKey , "RCL_CARGO"))
        cResult := RCL->RCL_CARGO
    EndIf

    RestArea(aRCLArea)

Return cResult



/*/{Protheus.doc} RU20XFUN11_ValidationBeforeJson()
    Checking the completion of fields before generating a Json file

    @type Function

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN11_ValidationBeforeJson()
    Local lRes as Logical
    Local cMsgText as Character

    lRes := .T.
    cMsgText := ""
    If Empty(AllTrim(M->QS_CDESPEC)) .Or. Empty(AllTrim(M->QS_WEXPER )) .Or. Empty(AllTrim(M->QS_WSCHEDU)) .Or. Empty(AllTrim(M->QS_CODSITE)) .Or. Empty(AllTrim(M->QS_POSIT))
        If Empty(AllTrim(M->QS_CDESPEC)) 
            cMsgText += Iif(Empty(cMsgText), "QS_CDESPEC", ", QS_CDESPEC")
        EndIf
        If Empty(AllTrim(M->QS_WEXPER)) 
            cMsgText += Iif(Empty(cMsgText), "QS_WEXPER", ", QS_WEXPER")
        EndIf
        If Empty(AllTrim(M->QS_WSCHEDU)) 
            cMsgText += Iif(Empty(cMsgText), "QS_WSCHEDU", ", QS_WSCHEDU")
        EndIf
        If Empty(AllTrim(M->QS_CODSITE)) 
            cMsgText += Iif(Empty(cMsgText), "QS_CODSITE", ", QS_CODSITE")
        EndIf
        If Empty(AllTrim(M->QS_POSIT)) 
            cMsgText += Iif(Empty(cMsgText), "QS_POSIT", ", QS_POSIT")
        EndIf

        If AT(cMsgText,",") > 0
            cMsgText := STR0009 + CRLF + CRLF + STR0001 + " " + cMsgText + " " + STR0002 
        Else
            cMsgText := STR0009 + CRLF + CRLF + STR0004 + " " + cMsgText + " " + STR0005 
        EndIf

        MsgInfo(cMsgText)
        lRes := .F.

    EndIf

Return lRes


/*/{Protheus.doc} RU20XFUN12_generationJson()
    Starts the Json file generation process

    @type Function

    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN12_generationJson()
    RU20D03()
Return 


/*/{Protheus.doc} RU20XFUN13_ValidationSumm()
    Checks the correctness of the entered amounts

    @type Function
    
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN13_ValidationSumm()

    Local nResult as Numeric
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character
    Local cCode      As Character

    Local cTabNun as Character
    Local cTabNivel as Character

    Local nSum1 as Numeric
    Local nSum2 as Numeric

    nResult := 0
    aArea := GetArea()

    cCode := M->QS_POSIT

    If !Empty(cCode)
        cSQL := "SELECT Q3_TABELA, Q3_TABNIVE, Q3_DESCSUM FROM " + RetSQLName("SQ3") + " WHERE Q3_FILIAL = ? AND Q3_CARGO = ?  AND D_E_L_E_T_=' '"
        
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("SQ3"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        cTabNun := AllTrim((cTab)->Q3_TABELA)
        cTabNivel := AllTrim((cTab)->Q3_TABNIVE)

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf
    
    If !Empty(cCode)
        cSQL := "SELECT RB6_FAIXA,RB6_VALOR FROM " + RetSQLName("RB6") + " WHERE RB6_FILIAL= ? AND RB6_TABELA= ? AND RB6_NIVEL= ? AND D_E_L_E_T_=' ' ORDER BY RB6_FAIXA"
        
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("RB6"))
        oStatement:SetString(2, cTabNun)
        oStatement:SetString(3, cTabNivel)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While (cTab)->(!Eof())
            If AllTrim((cTab)->RB6_FAIXA) == '01'
                nSum1 := (cTab)->RB6_VALOR
            Else
                nSum2 := (cTab)->RB6_VALOR
            EndIf
            (cTab)->(DbSkip())
        EndDo
        
        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    If (nSum1 != M->QS_FIRSTLE .Or. nSum2 != M->QS_FINALLE) .And. !Empty(M->QS_SALTABL)
        MsgInfo(STR0006 + CRLF + STR0007 + CRLF + STR0008)
    EndIf
    
    RestArea(aArea)

Return 


/*/{Protheus.doc} RU20XFUN03_WhenForSQSModule(cParam)
    Checks the correctness of the entered values

    @type Function
    @param cParam, Character, number of operation.

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN14_Validation(cParam)
    Local lRes as Logical
    lRes := .T.
    
    Do Case
        Case cParam == "QS_CDESPEC"
            lRes := Vazio() .Or. ValidF6K("R001",M->QS_CDESPEC,1,6)
        Case cParam == "QS_WEXPER"
            lRes := Vazio() .Or. ValidF6K("R002",M->QS_WEXPER,1,3)
        Case cParam == "QS_WSCHEDU"
            lRes := Vazio() .Or. ValidF6K("R003",M->QS_WSCHEDU,1,4)
        Case cParam == "QS_CODSITE"
            lRes := Vazio() .Or. ValidF6K("R004",M->QS_CODSITE,1,6)
        Case cParam == "QS_POSIT"
            lRet := ExistCpo("SQ3",M->QS_POSIT) .Or. Vazio()
    End Do

Return lRes



/*/{Protheus.doc} RU20XFUN15_TridderWorkPlase()
    Collects data from QS_DCITY QS_DSTRIT QS_DBUILD fields and generates a string

    @type Function

    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20XFUN15_TridderWorkPlase()
    Local cRes as Character
    cRes := AllTrim(M->QS_DCITY) + ', ' + AllTrim(M->QS_DSTRIT) + ', ' + AllTrim(M->QS_DBUILD)
    
Return cRes
