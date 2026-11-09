#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU20D02RUS.CH"
#INCLUDE "INKEY.CH"


#DEFINE EXPERIENCE_CODES "01|02|03"

/*/{Protheus.doc} RU20D02Event()
    Class of events for routine RU20D02RUS.

    @type Class
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Class RU20D02Event From FWModelEvent

    Method New() Constructor

    Method Activate(oSubModel, lCopy)
    Method GridPosVld(oSubModel, cModelID)

Endclass

/*/{Protheus.doc} New()
    Creates a new class element.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Method New() Class RU20D02Event
Return


/*/{Protheus.doc} Activate(oSubModel, cModelID)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2024/02/12
    @version 12.1.2310
*/
Method Activate(oSubModel, lCopy) Class RU20D02Event
    Local nI        As Numeric
    Local nJ        As Numeric
    Local oViewAux
    Local oViewStruct
    Local oViewF6I
    Local oStruF6K
    Local oStruF6I
    Local aSTHead as Array
    Local xValue

    aSTHead := {}

    oStruF6K := oSubModel:GetModel("RU20D02_F6K")
    oStruF6I := oSubModel:GetModel("RU20D02_F6I")
    oViewAux := FWViewActive()
    oViewStruct := oViewAux:GetViewStruct("RU20D02_F6K")
    oViewF6I := oViewAux:GetViewStruct("RU20D02_F6I")
    aSTHead := RU20D02001(F6I->F6I_CODIGO)

    For nI := 1 To oStruF6K:Length()
        oStruF6K:GoLine(nI)
        For nJ := 1 to len(aSTHead)
            xValue := SUBSTR(oStruF6K:GetValue("F6K_CONTEU"),aSTHead[nJ][4], aSTHead[nJ][5])
            If aSTHead[nJ][3] == "N"    // Numeric
                xValue := Val(xValue)
            ElseIf aSTHead[nJ][3] == "D"    // Date
                xValue := CTOD(xValue)
            EndIf
            oStruF6K:LoadValue( aSTHead[nJ][1], xValue)
        Next nJ
    Next nI

Return 


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
        cSQL := "SELECT F6I_CAMPOS,F6I_DESCPO,F6I_TIPO,F6I_TAMAN, F6I_PICTUR FROM " + RetSQLName("F6I") + " WHERE F6I_FILIAL = ? AND F6I_CODIGO = ? ORDER BY F6I_ORDEM "
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


/*/{Protheus.doc} GridPosVld(oSubModel, cModelID)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2021/05/24
    @version 191205P
*/
Method GridPosVld(oSubModel, cModelID) Class RU20D02Event
    Local lResultValid As Logical
    Local oModel As Object

    Local lRet as Logical
    Local nOperation as Numeric
    Local nI        As Numeric
    Local nJ        As Numeric
    Local oViewAux
    Local oViewStruct
    Local oViewF6I
    Local oStruF6K
    Local oStruF6I
    Local cStr as Character
    Local cStrNum as Character
    Local aSTHead as Array

    aSTHead := {}
    oModel := oSubModel:GetModel()

    oStruF6K := oModel:GetModel("RU20D02_F6K")
    oStruF6I := oModel:GetModel("RU20D02_F6I")
    oViewAux := FWViewActive()
    oViewStruct := oViewAux:GetViewStruct("RU20D02_F6K")
    oViewF6I := oViewAux:GetViewStruct("RU20D02_F6I")

    aSTHead := RU20D02001(F6I->F6I_CODIGO)

    lRet := .T.
    nOperation := oModel:GetOperation() 

    lResultValid := .T.
    cStrNum := "0"

    If lResultValid 
        If nOperation == MODEL_OPERATION_UPDATE
            For nI := 1 To oStruF6K:Length()
                cStr := ''
                oStruF6K:GoLine(nI)
                For nJ := 1 to len(aSTHead)
                    If aSTHead[nJ][3] == "N"    // Numeric
                        cStr := cStr + Padr(cValToChar(oStruF6K:GetValue(aSTHead[nJ][1])),aSTHead[nJ][5],Space(1))
                    ElseIf aSTHead[nJ][3] == "D"    // Date
                        xValue := DTOS(xValue)
                    ElseIf aSTHead[nJ][3] == "C"    // Date
                        cStr := cStr + oStruF6K:GetValue(aSTHead[nJ][1])
                    EndIf
                Next nJ
                oStruF6K:LoadValue( "F6K_CONTEU", cStr)
                If Empty(oStruF6K:GetValue("F6K_FILIAL"))
                    oStruF6K:LoadValue( "F6K_FILIAL", F6I->F6I_FILIAL)
                EndIf
                If Empty(oStruF6K:GetValue("F6K_SEQUEN"))
                    oStruF6K:LoadValue( "F6K_SEQUEN", Right("000" + cValToChar( val(cStrNum)+1),3) )
                EndIf
                If Empty(oStruF6K:GetValue("F6K_CODIGO"))
                    oStruF6K:LoadValue( "F6K_CODIGO", F6I->F6I_CODIGO)
                EndIf
                
                cStrNum := oStruF6K:GetValue("F6K_SEQUEN")
            Next nI
        EndIf
    EndIf
Return lResultValid
