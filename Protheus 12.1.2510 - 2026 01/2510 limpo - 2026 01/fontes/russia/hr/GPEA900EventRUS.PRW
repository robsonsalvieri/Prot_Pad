#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA900.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "RUHCM274.CH"

#DEFINE EXPERIENCE_CODES "01|02|03"

/*/{Protheus.doc} GPEA900Event()
    Class of events for routine GPEA900RUS.

    @type Class
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Class GPEA900Event From FWModelEvent

    Method New() Constructor
    Method FieldPreVld(oSubModel, cModelID, cAction, cID, xValue)
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Method FieldPosVld(oSubModel, cModelID)
    Method GridPosVld(oSubModel, cModelID)

Endclass

/*/{Protheus.doc} New()
    Creates a new class element.

    @type Method
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Method New() Class GPEA900Event
Return


/*/{Protheus.doc} FieldPreVld(oSubModel, cModelID, cAction, cID, xValue)
    Intercepting field validation.

    @type Method
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Method FieldPreVld(oSubModel, cModelID, cAction, cID, xValue) Class GPEA900Event
    Local oModel As Object
    Local oModelRGE As Object
    Local oModelF5G As Object
    Local oModelF5H As Object
    Local nX As Numeric
    Local oView  as Object
    Local nYearIn As Numeric
    Local nMonthIn As Numeric
    Local nDayIn As Numeric
    Local nYearFi As Numeric
    Local nMonthFi As Numeric
    Local nDayFi As Numeric
    Local nFocus As Numeric
    Local lUserAnswer As Logical
    Local dDateIn As Date
    Local dDateOut As Date
    Local aCurExperience := {} As Array

    oModel := oSubModel:GetModel()
    oModelRGE := oModel:GetModel("GPEA900_RGE")
    oModelF5G := oModel:GetModel("GPEA900_F5G")
    oModelF5H := oModel:GetModel("GPEA900_F5H")

    lResultValid := .T.

    If lResultValid
        If cID == "RGE_DATAIN" .And. cAction == "SETVALUE"

            For nX := 1 To oModelF5G:Length()
                oModelF5G:GoLine(nX)
                oModelF5G:LoadValue("F5G_DATAIN", xValue)
            Next nX
            For nX := 1 To oModelF5H:Length()
                oModelF5H:GoLine(nX)
                oModelF5H:LoadValue("F5H_DATAIN", xValue)
            Next nX

        EndIf
    EndIf 

    If lResultValid
        oView := FwViewActive()
        If (cID == "RGE_DATAIN" .And. cAction == "SETVALUE") .Or. (cID == "RGE_DATAFI" .And. cAction == "SETVALUE")
            
            dDateIn := oModelRGE:GetValue("RGE_DATAIN")
            dDateOut := oModelRGE:GetValue("RGE_DATAFI")

            If (cID == "RGE_DATAIN" .And. cAction == "SETVALUE")
                dDateIn := xValue
            EndIf

            If (cID == "RGE_DATAFI" .And. cAction == "SETVALUE")
                dDateOut := xValue
            EndIf

            If Year(dDateIn) > 0 .And. Year(dDateOut) > 0

                lUserAnswer := MsgYesNo(STGP90020, STGP90019)

                If lUserAnswer
                    aCurExperience := DateDiffYMD(dDateIn, dDateOut)
                    nYearFi := aCurExperience[1]
                    nMonthFi := aCurExperience[2]
                    nDayFi := aCurExperience[3]

                    For nX := 1 To oModelF5H:Length()
                        oModelF5H:GoLine(nX)
                        If oModelF5H:GetValue("F5H_CODE") $ EXPERIENCE_CODES
                            oModelF5H:SetValue("F5H_YEARS", nYearFi)
                            oModelF5H:LoadValue("F5H_MONTHS", nMonthFi)
                            oModelF5H:LoadValue("F5H_DAYS", nDayFi)
                        EndIf
                    Next nX

                    oModelF5H:GoLine(1)
                    nFocus := GetFocus()
                    oView:Refresh()
                    SetFocus(nFocus)
                EndIf
            EndIf
        EndIf
    EndIf

Return lResultValid


/*/{Protheus.doc} GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Intercepting Grid validation.

    @type Method
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class GPEA900Event
    Local lResultValid As Logical
    Local oModel As Object
    Local oModelRGE As Object
    Local oModelF5G As Object
    Local oModelF5H As Object
    local nLGrid1 as Numeric
    local nLGrid2 as Numeric
    Local nX As Numeric
    
    lResultValid := .T.
    oModel := oSubModel:GetModel()
    oModelRGE := oModel:GetModel("GPEA900_RGE")
    oModelF5G := oModel:GetModel("GPEA900_F5G")
    oModelF5H := oModel:GetModel("GPEA900_F5H")

    nLGrid1 := oModelF5G:Length()
    nLGrid2 := oModelF5H:Length()

    If cAction == "SETVALUE" 
        If cModelID == "GPEA900_F5G"
            oModelF5G:GoLine(nLine)
            oModelF5G:LoadValue("F5G_DATAIN", oModelRGE:GetValue("RGE_DATAIN"))
        EndIF

        If cModelID == "GPEA900_F5H"
            oModelF5H:GoLine(nLine)
            oModelF5H:LoadValue("F5H_DATAIN", oModelRGE:GetValue("RGE_DATAIN"))
        EndIF
    EndIf

    If cId == "F5G_YEAR" .And. cAction == "SETVALUE"
        If Year(oModelRGE:GetValue("RGE_DATAFI")) > 0
            If Val(xValue) < Year(oModelRGE:GetValue("RGE_DATAIN")) .Or. Val(xValue) > Year(oModelRGE:GetValue("RGE_DATAFI"))
                Help(,, STGP90004,, STGP90004, 1, 0) //The year according to reference 182n must be in the range of the period of work in the organization
                lResultValid := .F.
            EndIf
        Else
            If Val(xValue) < Year(oModelRGE:GetValue("RGE_DATAIN")) 
                Help(,, STGP90004,, STGP90004, 1, 0) //The year according to reference 182n must be in the range of the period of work in the organization
                lResultValid := .F.
            EndIf
        EndIf

        If lResultValid .And. oModelF5G:Length() != 1
            
            For nX := 1 To oModelF5G:Length()
                oModelF5G:GoLine(nX)
                If oModelF5G:GetValue("F5G_YEAR") == xValue .And. nLine != nX
                    Help(,, STGP90008,, STGP90008, 1, 0,,,,,, {OemToAnsi(STGP90009)}) //The year according to reference 182n must be unique
                                                                                      //Check records and enter new value
                    lResultValid := .F.
                EndIf
            Next nX

        EndIf
    EndIf

    If cId == "F5G_DAYS" .And. cAction == "SETVALUE"
        If Val(xValue) > 366
            Help(,, STGP90005,, STGP90005, 1, 0) //The value must be in the range 0-366
            lResultValid := .F.
        EndIf
    EndIf

    If cId == "F5H_CODE" .And. cAction == "SETVALUE"

        If oModelF5H:Length() != 1
            For nX := 1 To oModelF5H:Length() 
                oModelF5H:GoLine(nX)
                If oModelF5H:GetValue("F5H_CODE") == xValue .And. nLine != nX
                    Help(,, STGP90010,, STGP90010, 1, 0,,,,,, {OemToAnsi(STGP90011)}) //The year according to reference 182n must be unique
                                                                                      //Check records and enter new value
                    lResultValid := .F.
                EndIf
            Next nX
        EndIf
        If lResultValid
            oModelF5H:GoLine(nLine)
            oModelF5H:LoadValue("F5H_DESC", GPEA9RUS_GetDescByS211(xValue))
            oView := FwViewActive()

            If Year(oModelRGE:GetValue("RGE_DATAFI")) > 0 .And. Year(oModelRGE:GetValue("RGE_DATAIN")) > 0

                nYearIn := Year(oModelRGE:GetValue("RGE_DATAIN"))
                nMonthIn := Month(oModelRGE:GetValue("RGE_DATAIN"))
                nDayIn := Day(oModelRGE:GetValue("RGE_DATAIN"))

                nYearFi := Year(oModelRGE:GetValue("RGE_DATAFI"))
                nMonthFi := Month(oModelRGE:GetValue("RGE_DATAFI"))
                nDayFi := Day(oModelRGE:GetValue("RGE_DATAFI"))

                If nDayFi > nDayIn
                    nDayFi := nDayFi - nDayIn + 1
                Else
                    nMonthFi := nMonthFi - 1
                    nDayFi := nDayFi - nDayIn + 1 + 30
                EndIf

                If nMonthFi >= nMonthIn
                    nMonthFi := nMonthFi - nMonthIn
                Else
                    nYearFi := nYearFi - 1
                    nMonthFi := nMonthFi - nMonthIn + 12
                EndIf

                nYearFi := nYearFi - nYearIn

                If xValue $ EXPERIENCE_CODES
                    oModelF5H:LoadValue("F5H_YEARS", nYearFi)
                    oModelF5H:LoadValue("F5H_MONTHS", nMonthFi)
                    oModelF5H:LoadValue("F5H_DAYS", nDayFi)
                EndIf
                
                oView:Refresh()
                
            EndIf

        EndIf
    EndIf

    If cId == "F5H_MONTHS" .And. cAction == "SETVALUE"
        If xValue > 11
            Help(,, STGP90006,, STGP90006, 1, 0,) //The value must be in the range 0-11
            lResultValid := .F.
        EndIf
    EndIf

    If cId == "F5H_DAYS" .And. cAction == "SETVALUE"
        If xValue > 30
            Help(,, STGP90007,, STGP90007, 1, 0) //The value must be in the range 0-30
            lResultValid := .F.
        EndIf
    EndIf

Return lResultValid


/*/{Protheus.doc} FieldPosVld(oSubModel, cModelID)
    Interception of field post-validation check.

    @type Method
    @author iprokhorenko
    @since 2021/05/12
    @version 191205P
*/
Method FieldPosVld(oSubModel, cModelID) Class GPEA900Event
    Local lResultValid As Logical
    Local oModel As Object
    Local oModelRGE As Object
    Local oModelF5G As Object
    Local oModelF5H As Object
    Local oView  as Object
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character

    lResultValid := .T.
    oModel := oSubModel:GetModel()
    oModelRGE := oModel:GetModel("GPEA900_RGE")
    oModelF5G := oModel:GetModel("GPEA900_F5G")
    oModelF5H := oModel:GetModel("GPEA900_F5H")
    oView := FwViewActive()

    If lResultValid
        aArea := GetArea()

        oStatement := FWPreparedStatement():New(" SELECT COUNT(*) AS LINES FROM " + RetSQLName("RGE") + " WHERE RGE_FILIAL = ? AND RGE_MAT = ? AND RGE_DATAIN = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("RGE"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, DToS(oModelRGE:GetValue("RGE_DATAIN")))
        cTab := MPSysOpenQuery(oStatement:GetFixQuery(), "cTab")

        If (cTab->LINES > IIf(oModel:GetOperation() == 4, 1, 0))
            lResultValid := .F.
            Help(,, STGP90014,, STGP90015, 1, 0,,,,,, {OemToAnsi(STGP90016)})
            //The start date is the same as this employee's other entries!
            //You cannot create entries with the same start dates
            //You need to change the start date of the period
        EndIf
        
        oStatement:Destroy()
        FwFreeObj(oStatement)
        RestArea(aArea)
    EndIf

Return lResultValid


/*/{Protheus.doc} GridPosVld(oSubModel, cModelID)
    Interception of grid post-validation check.

    @type Method
    @author iprokhorenko
    @since 2021/05/24
    @version 191205P
*/
Method GridPosVld(oSubModel, cModelID) Class GPEA900Event
    Local lResultValid As Logical
    Local oModel As Object
    Local oModelRGE As Object
    Local oModelF5G As Object
    Local oModelF5H As Object
    Local nX As Numeric
    Local dDataIn As Date
    Local dDataFi As Date

    lResultValid := .T.
    oModel := oSubModel:GetModel()
    oModelRGE := oModel:GetModel("GPEA900_RGE")
    oModelF5G := oModel:GetModel("GPEA900_F5G")
    oModelF5H := oModel:GetModel("GPEA900_F5H")

    dDataIn := oModelRGE:GetValue("RGE_DATAIN")
    dDataFi := oModelRGE:GetValue("RGE_DATAFI")

    If lResultValid 
        For nX := 1 To oModelF5G:Length()
            oModelF5G:GoLine(nX)
            If Empty(oModelF5G:GetValue("F5G_YEAR")) .And. ;
               (!Empty(oModelF5G:GetValue("F5G_DAYS")) .Or. ;
               !Empty(oModelF5G:GetValue("F5G_DOCNO")) .Or. ;
               oModelF5G:GetValue("F5G_AMT") > 0 )
                lResultValid := .F.
            ElseIf !Empty(oModelF5G:GetValue("F5G_YEAR"))
                If Year(oModelRGE:GetValue("RGE_DATAFI")) > 0
                    If Val(oModelF5G:GetValue("F5G_YEAR")) < Year(oModelRGE:GetValue("RGE_DATAIN")) .Or. ;
                    Val(oModelF5G:GetValue("F5G_YEAR")) > Year(oModelRGE:GetValue("RGE_DATAFI"))
                        lResultValid := .F.
                    EndIf
                Else
                    If Val(oModelF5G:GetValue("F5G_YEAR")) < Year(oModelRGE:GetValue("RGE_DATAIN")) 
                        lResultValid := .F.
                    EndIf
                EndIf
            EndIf
        Next nX

        If !lResultValid 
            Help(,, STGP90004,, STGP90004, 1, 0) // The year according to reference 182n must be in the range of the period of work in the organization
        EndIf
    EndIf

    If lResultValid 
        For nX := 1 To oModelF5H:Length()
            oModelF5H:GoLine(nX)
            If (oModelF5H:GetValue("F5H_YEARS") > 0 .Or. ;
               oModelF5H:GetValue("F5H_MONTHS") > 0 .Or. ;
               oModelF5H:GetValue("F5H_DAYS") > 0 ) .And. ;
               Empty(oModelF5H:GetValue("F5H_CODE"))
                lResultValid := .F.
            EndIf
        Next nX

        If !lResultValid
            Help(,, STGP90017,, STGP90017, 1, 0,,,,,, {OemToAnsi(STGP90018)}) // Empty field experience code
                                                                              // Check the records and enter the seniority code
        EndIf
    EndIf

Return lResultValid
