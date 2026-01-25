#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU20D02RUS.CH"

/*/{Protheus.doc} RU20D02()
    Experience and 182H. Based on GPEA900 procedure.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D02()

    Local oBrowse as object
    Local aArea := GetArea()
    Private aRotina

    DbSelectArea('F6I')
    F6I->(dbSetOrder(1))
    
    aRotina := MenuDef()
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)
Return Nil


/*/{Protheus.doc} BrowseDef()
    Browse for RU20D02 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function BrowseDef()
    Local oBrowse as Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F6I") 
    oBrowse:SetDescription(STR0001)
    oBrowse:SetFilterDefault("F6I->F6I_ORDEM == '01'")
    
Return oBrowse


/*/{Protheus.doc} ModelDef()
    Model for RU20D02 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function ModelDef()
    Local oModel As Object
    Local oStruF6I As Object

    Local oStructF6K As Object

    Local oEvent As Object // Events.
    Local aSTHead As Character
    Local nX as Numeric

    aSTHead := RU20D02001(F6I->F6I_CODIGO)

    oModel := MPFormModel():New('RU20D02')

    oEvent := RU20D02Event():New()

    oStructF6K := FWFormStruct(1,"F6K")
    oStruF6I := FWFormStruct(1,"F6I")

    For nX := 1 to len(aSTHead)
        oStructF6K:AddField(aSTHead[nX][2],;
                     aSTHead[nX][2],;
                     aSTHead[nX][1],;
                     aSTHead[nX][3],;//"C",;
                     aSTHead[nX][5],;
                     0,;
                     NIL,;
                     FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."),;
                     NIL,;
                     .F.,;
                     NIL,;
                     NIL,;
                     .F.,;
                     .T.)

        oStructF6K:SetProperty( aSTHead[nX][1],MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."))

    Next nX
    
    oModel:AddFields("RU20D02_F6I",, oStruF6I)
    oModel:AddGrid("RU20D02_F6K", "RU20D02_F6I", oStructF6K)
    
    oModel:SetPrimaryKey({"F6I_FILIAL", "F6I_CODIGO"})

    oModel:SetRelation('RU20D02_F6K', {{'F6K_FILIAL','F6I_FILIAL'}, {'F6K_CODIGO','F6I_CODIGO'}})

    oModel:SetDescription(STR0001) //Reference

    oModel:InstallEvent("RU20D02_Event",, oEvent) 
Return oModel


/*/{Protheus.doc} ViewDef()
    View for RU20D02 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function ViewDef()
    Local oModel As Object
    Local oStructF6I As Object
    Local oView As Object
    Local oStrF6K As Object
    Local aSTHead As Character
    Local nX as Numeric

    aSTHead := RU20D02001(F6I->F6I_CODIGO)

    oModel := FwLoadModel("RU20D02")

    oModelF6K := oModel:GetModel("RU20D02_F6K")
    oStrF6K := FWFormStruct(2, "F6K")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oStructF6I := FWFormStruct(2,"F6I")

    oStructF6I:RemoveField("F6I_FILIAL")
    oStructF6I:RemoveField("F6I_ORDEM")
    oStructF6I:RemoveField("F6I_PICTUR")
    oStructF6I:RemoveField("F6I_PROCES")
    oStructF6I:RemoveField("F6I_TIPO")
    oStructF6I:RemoveField("F6I_TAMAN")
    oStructF6I:RemoveField("F6I_DECIMA")
    oStructF6I:RemoveField("F6I_VALID")
    oStructF6I:RemoveField("F6I_PADRAO")
    oStructF6I:RemoveField("F6I_VERSAO")
    oStructF6I:RemoveField("F6I_SHOWMA")
    oStructF6I:RemoveField("F6I_PESQ")
    oStructF6I:RemoveField("F6I_MODULO")
    oStructF6I:RemoveField("F6I_CAMPOS")
    oStructF6I:RemoveField("F6I_DESCPO")

    oView:AddField("RU20D02_F6I", oStructF6I)
    
    For nX := 1 to len(aSTHead)
        oStrF6K:AddField(    aSTHead[nX][1],;
                            cValToChar(nX+4),;
                            aSTHead[nX][2],;
                            aSTHead[nX][2],;
                            NIL,;
                            aSTHead[nX][3],;//"C",;
                            aSTHead[nX][6],;//"@!",;
                            NIL,;
                            NIL,;
                            .T.,;
                            NIL,;
                            NIL,;
                            NIL,;
                            aSTHead[nX][5],;
                            NIL,;
                            .F.,;
                            NIL,;
                            NIL)
        oStrF6K:SetProperty( aSTHead[nX][1], MVC_VIEW_CANCHANGE, .T. )
        
    Next nX

    oStrF6K:RemoveField("F6K_CONTEU")

    oView:AddGrid("RU20D02_F6K", oStrF6K, "RU20D02_F6K")

    oView:CreateHorizontalBox("HEADBOX", 10)
    oView:CreateHorizontalBox("GRIDBOX", 90)

    oView:SetOwnerView("RU20D02_F6I", "HEADBOX")
    oView:SetOwnerView('RU20D02_F6K', 'GRIDBOX')

    oView:SetCloseOnOk({ || .T. }) 
Return oView


/*/{Protheus.doc} MenuDef()
    Menu for RU20D02 routine.

    @type Function
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function MenuDef()

Local aRotina :=  {}

    aAdd( aRotina, { STR0003, 'VIEWDEF.RU20D02', 0, 2, 0, NIL } ) // View
    aAdd( aRotina, { STR0005, 'VIEWDEF.RU20D02', 0, 4, 0, NIL } ) // Edit
    aAdd( aRotina, { STR0008, 'RU20D0201', 0, 9, 0, NIL } ) // Import
Return aRotina


/*/{Protheus.doc} RU20D02001()
    Returns a list of table fields from F6I

    @type Function
    @param cCode, Character, Code table.
           
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Static Function RU20D02001(cCode)
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local aDataSign  As Array
    Local aRes       As Array
    Local cSQL       As Character

    aDataSign := {}
    aRes := {}
    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        cSQL := "SELECT F6I_CAMPOS,F6I_DESCPO,F6I_TIPO,F6I_TAMAN, F6I_PICTUR FROM " + RetSQLName("F6I") + " WHERE F6I_FILIAL = ? AND F6I_CODIGO = ? AND D_E_L_E_T_=' ' ORDER BY F6I_ORDEM "
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("F6I"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        While (cTab)->(!Eof())
            Aadd(aRes, {AllTrim((cTab)->F6I_CAMPOS),AllTrim((cTab)->F6I_DESCPO) ,(cTab)->F6I_TIPO, IIf(len(aRes)<1, 1, aRes[len(aRes)][4] + aRes[len(aRes)][5]), (cTab)->F6I_TAMAN, (cTab)->F6I_PICTUR})
            (cTab)->(DbSkip())
        EndDo

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return aRes


/*/{Protheus.doc} RU20D02002_fDescF6K()
    Returns the value of a field from F6K

    @type Function
    @param cTabName, Character, Code table.
           cKey, Character, search key.
           nPosKey, Numeric, pos. start search.
           nLenKey, Numeric, pos. end search.
           nPosDesc, Character, pos. start desc.
           nLenDesc, Character, pos. end desc.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D02002_fDescF6K(cTabName, cKey, nPosKey, nLenKey, nPosDesc, nLenDesc)
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
        
        While (cTab)->(!Eof())
           
            If cKey == substr((cTab)->F6K_CONTEU, nPosKey, nLenKey)
                cResult := substr((cTab)->F6K_CONTEU, nPosDesc, nLenDesc)
            EndIf
            (cTab)->(DbSkip())
            
        EndDo

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20D02005()
    Trigger for SQS fields. Returns a description depending on the code

    @type Function
    @param cCode, Character, Code table.
           nFunc, Character, parametr Code.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D02005(cCode, nFunc)
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

        (cTab)->(DBCloseArea())

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
        
        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


/*/{Protheus.doc} RU20D02006()
    Trigger for SQS fields. Returns a description depending on the code

    @type Function
    @param cCode, Character, Code table.
           nFunc, Character, parametr Code.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D02006(cCode, nFunc)
    Local nResult as Numeric
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character
    Local cTabNun as Character
    Local cTabNivel as Character

    nResult := 0
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

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf
    
    If nFunc == 1 .Or. nFunc == 2
        cSQL := "SELECT RB6_FAIXA,RB6_VALOR FROM " + RetSQLName("RB6") + " WHERE RB6_FILIAL= ? AND RB6_TABELA= ? AND RB6_NIVEL= ? AND D_E_L_E_T_=' ' ORDER BY RB6_FAIXA"
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("RB6"))
        oStatement:SetString(2, cTabNun)
        oStatement:SetString(3, cTabNivel)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While (cTab)->(!Eof())
            If nFunc == 1 .And. AllTrim((cTab)->RB6_FAIXA) == '01'
                nResult := (cTab)->RB6_VALOR
            ElseIf nFunc == 2
                nResult := (cTab)->RB6_VALOR
            EndIf
            (cTab)->(DbSkip())
        EndDo
        
        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return nResult


/*/{Protheus.doc} RU20D02007()
    Trigger for SQS fields. Returns a description depending on the code

    @type Function
    @param cCode, Character, Code table.
           nFunc, Character, parametr Code.
    @author iprokhorenko
    @since 2024/03/21
    @version 12.1.2310
*/
Function RU20D02007(cCode, nFunc)
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

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)
Return cResult


