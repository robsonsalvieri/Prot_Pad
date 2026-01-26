#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W700.CH"
/*/{Protheus.doc} RU44W700EventRUS
    This class needs for run validation in RU34D06

    @type class
    @author Dmitry Borisov
    @since 2024/05/29
    @version R14
    @example RU44W700EventRUS
*/
Class RU44W700EventRUS From FWModelEvent
    Method New() Constructor
    Method FieldPreVld()
EndClass

Method New() Class RU44W700EventRUS
Return Nil

/*/{Protheus.doc} FieldPreVld(oSubModel, cModelId, cAction, cId, xValue)
    This method needs for field data validation

    @type method
    @param oSubModel = object with model
    @param cModelId = String with model id
    @param cAction = String with action name, example: SETVALUE
    @param cId = String with field name for SX3, example: AJK_PROJET
    @param xValue = variant with new value of field
    @return lRet

    @author Dmitry Borisov
    @since 2024/05/29
    @version R14
    @example FieldPreVld(oSubModel, cModelId, cAction, cId, xValue)
*/
Method FieldPreVld(oSubModel, cModelId, cAction, cId, xValue) Class RU44W700EventRUS
    Local lRet := .T.
    
    If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cAction == "SETVALUE" .And. cId == "AJK_SITUAC"
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '3' .And. xValue == '2'
            cMessage := STR0013
            lRet := .F.
        EndIf
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '2' .And. xValue == '3'
            cMessage := STR0026
            lRet := .F.
        EndIf
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '1' .And. (xValue == Nil .Or. Empty(xValue))
            cMessage := STR0027
            lRet := .F.
        EndIf
        If !lRet
            oSubModel:SetErrorMessage(cModelId, cId,cModelId,cId,STR0028,cMessage,xValue, oSubModel:GetValue("AJK_SITUAC"))
        EndIf
    EndIf
Return (lRet)
                   
//Merge Russia R14 
                   
