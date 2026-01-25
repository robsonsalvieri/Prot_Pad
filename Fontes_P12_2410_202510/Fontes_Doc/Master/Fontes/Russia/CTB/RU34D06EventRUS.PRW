#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D06.CH"

/*/{Protheus.doc} RU34D06EventRUS
    This class needs for run validation in RU34D06

    @type class
    @return 

    @author Dmitry Borisov
    @since 2023/10/31
    @version 12.1.33
    @example RU34D06EventRUS
*/
Class RU34D06EventRUS From FWModelEvent
    Method New() Constructor
    Method GridLinePreVld()
    Method GridPosVld()
    Method ModelPosVld()
    Method ModelPreVld()
    Method AfterTTS()
EndClass

Method New() Class RU34D06EventRUS
Return Nil

/*/{Protheus.doc} ModelPreVld(oModel, cModelId)
    This method needs for validation and recalculation EndDate (F5S_DVALEN) in RU34D06 

    @type method
    @param oModel = object with model
    @param cModelId = String with model id, example "F5OMASTER"
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/12
    @version 12.1.33
    @example ModelPreVld(oModel, cModelId)
*/
Method ModelPreVld(oModel, cModelId) Class RU34D06EventRUS
    Local lRet := .T.
    Local nX := 0
    Local oModelF5S := oModel:GetModel("F5SDETAIL")
    Local nLine := oModelF5S:GetLine()

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. cModelId == "F5OMASTER" .And. !Empty(AllTrim(oModel:GetValue(cModelId,"F5O_F5QCOD"))) ;
    .And. oModelF5S:Length() > 0
        For nX := 1 To oModelF5S:Length()
            If oModelF5S:GetValue("F5S_F5QCOD", nX) != oModel:GetValue(cModelId,"F5O_F5QCOD")
                oModelF5S:GoLine(nX)
                lRet := oModelF5S:LoadValue("F5S_F5QCOD",oModel:GetValue(cModelId, "F5O_F5QCOD"))
            EndIf
        Next nX
        oModelF5S:GoLine(nLine)
    EndIf

Return (lRet)

/*/{Protheus.doc} GridLinePreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrentValue)
    This method needs for validation and recalculation EndDate (F5S_DVALEN) in RU34D06 

    @type method
    @param oSubModel = object with model
    @param cModelId = String with model id, example "F5SDETAIL"
    @param nLine = numeric, line number in grid
    @param cAction = String, contains current action example: "SETVALUE", "DELETE"
    @param cId = String, field name
    @param xValue = variable, new field value
    @param xCurrVal = variable, old field value
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/31
    @version 12.1.33
    @example GridLinePreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrVal)
*/
Method GridLinePreVld(oSubModel, cModelId, nLine, cAction, cId, xValue, xCurrVal) Class RU34D06EventRUS
    Local lRet  := .T.
    Local nX    := 0
    Local oView := FWViewActive()
    Local aF5Qlist := {}

    If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oSubModel:GetOperation() == MODEL_OPERATION_INSERT
        // Start date change validation
        If cAction == "SETVALUE" .And. cId == "F5S_DVALST"
            If (nLine == 1 .And. xValue <> CTOD("01.01.1900")) .Or. oSubModel:Length() <> nLine
                lRet := .F.
                Help("",1,"RU34D06",,STR0006,1,0,,,,,,{STR0007}) // Start date cannot be changed
            EndIf

            If lRet .And. nLine > 1 .And. xValue <> Nil .And. !Empty(xValue)
                nX := nLine
                While nX > 1
                    nX--
                    If !oSubModel:IsDeleted(nX) .And. oSubModel:GetValue("F5S_DVALST", (nX)) >= xValue
                        lRet := .F.
                        Help("",1,"RU34D06",,STR0006,1,0,,,,,,{STR0008}) // Start date cannot be less than the date of the previous entry
                        Exit
                    EndIf
                EndDo
            EndIf
        EndIf

        // No contract with primary docs
        If lRet
            If cAction == "DELETE" .Or. cAction == "SETVALUE"
                If nLine == 1 .And. cAction == "DELETE"
                    lRet := .F.
                    Help("",1,"RU34D06",,STR0012,1,0,,,,,,{STR0013})
                EndIf
                
                If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE
                    If lRet .And. cId != "F5S_DVALST"
                        aF5Qlist := RU34D06004(.T., {nLine})
                        If Len(aF5Qlist) > 0
                            lRet := .F.
                            Help("",1,"RU34D06",,STR0012,1,0,,,,,,{STR0018})
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf

        If lRet .And. nLine > 1 
            If ("DELETE" $ cAction) .Or. (cAction == "SETVALUE" .And. cId == "F5S_DVALST")
                If !oSubModel:IsDeleted(nLine-1)
                    oSubModel:GoLine(nLine-1)
                    If "DELETE" $ cAction
                        oSubModel:LoadValue("F5S_DVALEN",IIF( cAction == "UNDELETE", oSubModel:GetValue("F5S_DVALST", (nLine)) - 1,  oSubModel:GetValue("F5S_DVALEN", (nLine))))
                    Else
                        oSubModel:LoadValue("F5S_DVALEN", xValue - 1)
                    EndIf
                    oSubModel:GoLine(nLine)
                    oView:Refresh()
                EndIf
            EndIf
        EndIf
    EndIf
Return (lRet)

/*/{Protheus.doc} GridPosVld(oSubModel, cModelId)
    This method needs for validation sequential deletion of grid items in RU34D06 

    @type method
    @param oSubModel = Object with model
    @param cModelId  = String with model id, example "F5SDETAIL"
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/31
    @version 12.1.33
    @example GridPosVld(oSubModel, cModelId)
*/
Method GridPosVld(oSubModel, cModelId) Class RU34D06EventRUS
    Local nX         := 0
    Local nI         := 0
    Local lRet       := .T.
    Local aChanged   := {}
    Local aF5Qlist   := {}

    If ValType(oSubModel)=='O' .And. oSubModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oSubModel:GetOperation() == MODEL_OPERATION_INSERT
        aChanged := oSubModel:GetLinesChanged(MODEL_GRID_LINECHANGED_DELETED)
        If Len(aChanged) > 1
            lRet := .F.
            Help("",1,"RU34D06",,STR0012,1,0,,,,,,{STR0011})
        EndIf
        If lRet 
            aChanged := RU34D06006(oSubModel)
            If Len(aChanged) > 0
                aF5Qlist := RU34D06004(.T., aChanged)
                For nX := 1 To Len(aChanged)
                    If !oSubModel:IsDeleted(aChanged[nX])
                        If Empty(AllTrim(oSubModel:GetValue("F5S_PAYAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_PAYAR" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_ADVAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_ADVAR" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_CFAR"  , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_PRFAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_CSTAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_PRFAR" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_CSTAR" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_LEGAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_VATAC" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_LEGAR" , aChanged[nX]))) .And.;
                        Empty(AllTrim(oSubModel:GetValue("F5S_VATAR" , aChanged[nX]))) .And.;
                        IIf(oSubModel:GetStruct():HasField("F5S_EC09DB"),Empty(AllTrim(oSubModel:GetValue("F5S_EC09DB", aChanged[nX]))),.T.)
                            lRet := .F.
                            Help("",1,"RU34D06",,STR0012,1,0,,,,,,{STR0010})
                            Exit
                        EndIf
                        If Len(aF5Qlist) > 0
                            For nI := 1 To Len(aF5Qlist)
                                F5Q->(DbGoTo(aF5Qlist[nI]))
                                If F5Q->F5Q_EDATE >= oSubModel:GetValue("F5S_DVALST", aChanged[nX]) .And.;
                                F5Q->F5Q_EDATE <= oSubModel:GetValue("F5S_DVALEN", aChanged[nX]) .And. ;
                                (F5Q->F5Q_PAYAC  != oSubModel:GetValue("F5S_PAYAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_PAYAR  != oSubModel:GetValue("F5S_PAYAR" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_ADVAC  != oSubModel:GetValue("F5S_ADVAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_ADVAR  != oSubModel:GetValue("F5S_ADVAR" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_CFAR   != oSubModel:GetValue("F5S_CFAR"  , aChanged[nX]) .Or. ;
                                F5Q->F5Q_PRFAC  != oSubModel:GetValue("F5S_PRFAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_CSTAC  != oSubModel:GetValue("F5S_CSTAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_PRFAR  != oSubModel:GetValue("F5S_PRFAR" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_CSTAR  != oSubModel:GetValue("F5S_CSTAR" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_LEGAC  != oSubModel:GetValue("F5S_LEGAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_VATAC  != oSubModel:GetValue("F5S_VATAC" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_LEGAR  != oSubModel:GetValue("F5S_LEGAR" , aChanged[nX]) .Or. ;
                                F5Q->F5Q_VATAR  != oSubModel:GetValue("F5S_VATAR" , aChanged[nX]) .Or. ;
                                IIf(oSubModel:GetStruct():HasField("F5S_EC09DB"),F5Q->F5Q_EC09DB != oSubModel:GetValue("F5S_EC09DB", aChanged[nX]),.T.))
                                    lRet := .F.
                                    Help("",1,"RU34D06",,STR0012,1,0,,,,,,{STR0018})
                                    Exit
                                EndIf
                            Next nI
                        EndIf
                    EndIf
                    If !lRet
                        Exit
                    EndIf
                Next nX
            EndIf
        EndIf
    EndIf
Return (lRet)

/*/{Protheus.doc} AfterTTS(oModel, cModelId)
    This method needs update related contracts

    @type method
    @param oSubModel = Object with model
    @param cModelId  = String with model id, example "F5SDETAIL"
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/01
    @version 12.1.33
    @example AfterTTS(oModel, cModelId)
*/
Method AfterTTS(oModel, cModelId) Class RU34D06EventRUS
    Local aF5Qlist  := {}

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        aF5Qlist := RU34D06004(.F.,{})
        If Len(aF5Qlist) > 0
            RU34D06005(aF5Qlist, oModel)
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} ModelPosVld(oModel, cModelId)
    This method needs for validation on delete, insert operation in RU34D06 
    If rule has any contracts deletion is not allowed

    @type method
    @param oModel   = Object with model
    @param cModelId = String with model id, example "F5OMASTER"
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/27
    @version 12.1.33
    @example ModelPosVld(oModel, cModelId)
*/
Method ModelPosVld(oModel, cModelId) Class RU34D06EventRUS
    Local lRet     := .T.

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        lRet := RU34XFUN08(STR0012, STR0017, "RU34D06", "F5O")
    EndIf

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        lRet := ExistChav("F5O", oModel:GetValue("F5OMASTER", "F5O_CTYPE") + oModel:GetValue("F5OMASTER", "F5O_GRCNS") + oModel:GetValue("F5OMASTER", "F5O_F5QCOD"))
    EndIf
Return (lRet)
                   
//Merge Russia R14 
                   
