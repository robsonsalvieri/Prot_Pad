#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D08.CH"

/*/{Protheus.doc} RU01D08EventRUS
    This class needs for run validation in RU01D08

    @type class
    @return 

    @author Dmitry Borisov
    @since 2023/09/27
    @version 12.1.33
    @example RU01D08EventRUS
*/
Class RU01D08EventRUS From FWModelEvent
    Method New() Public Constructor
    Method GridLinePreVld() Public
EndClass

Method New() Class RU01D08EventRUS
Return Nil

/*/{Protheus.doc} GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    This method needs for validation and recalculation EndDate (F59_ENDDAT) in RU01D08 

    @type method
    @param oSubModel = object with model
    @param cModelID = String with model id, example "F59DETAIL"
    @param nLine = numeric, line number in grid
    @param cAction = String, contains current action example: "SETVALUE", "DELETE"
    @param cId = String, field name
    @param xValue = variable, new field value
    @param xCurrVal = variable, old field value
    @return lRet

    @author Dmitry Borisov
    @since 2023/09/27
    @version 12.1.33
    @example GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrVal)
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrVal) Class RU01D08EventRUS
    Local lRet  := .T.
    Local nX    := 0
    Local oView := FWViewActive()

    If nLine == 1 .And. cAction == "SETVALUE" .And. cId == "F59_BEGDAT" .And. xValue <> CTOD("01.01.1900")
        lRet := .F.
        Help("",1,"RU01D08",,STR0008,1,0,,,,,,{STR0006})
    EndIf
    If lRet .And. nLine > 1 
        If cAction == "SETVALUE" 
            If cId == "F59_BEGDAT" .And. xValue <> Nil .And. !Empty(xValue)
                nX := nLine
                While nX > 1
                    nX--
                    If !oSubModel:IsDeleted(nX) .And. oSubModel:GetValue("F59_BEGDAT", (nX)) >= xValue
                        lRet := .F.
                        Help("",1,"RU01D08",,STR0008,1,0,,,,,,{STR0007})
                        Exit
                    EndIf
                EndDo
                If lRet .And. !oSubModel:IsDeleted(nLine-1)
                    oSubModel:GoLine(nLine-1)
                    oSubModel:LoadValue("F59_ENDDAT",xValue - 1)
                    oSubModel:GoLine(nLine)
                    oView:Refresh()
                EndIf
            EndIf
        ElseIf cAction == "DELETE"
            If lRet .And. !oSubModel:IsDeleted(nLine-1)
                oSubModel:GoLine(nLine-1)
                oSubModel:LoadValue("F59_ENDDAT",oSubModel:GetValue("F59_ENDDAT", (nLine)))
                oSubModel:GoLine(nLine)
                oView:Refresh()
            EndIf
        EndIf
    EndIf
Return (lRet)
