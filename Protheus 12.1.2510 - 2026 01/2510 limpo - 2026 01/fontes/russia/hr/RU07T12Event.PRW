#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07T12.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} RU07T12Event()
    Class of events for routine Tax Deductions.

    @type  Class
    @author vselyakov
    @since 14.04.2021
    @version 191205P
*/
Class RU07T12Event From FWModelEvent
    Method New() Constructor
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
Endclass

/*{Protheus.doc} New()
    Constructor of events class RU07T12Event().

    @type Method
    @author vselyakov
    @since 14.04.2021
    @version 191205P
*/
Method New() Class RU07T12Event
Return

/*{Protheus.doc} FieldPreVld()
    Class of events for routine Tax Deductions.

    @type  Method
    @author vselyakov
    @since 14.04.2021
    @version 191205P
    @param oSubModel, Object,    Object of submodel.
           cModelID,  Character, ID of model.
           cAction,   Character, The action to be taken on the table. It can take on the following values: SETVALUE, CANSETVALUE.
           cID,       Character, ID of field (field name).
           xValue,    Variable,  New value.
    @return lResult, Logical, Validation succeeded (.T.) or failed (.F.).
*/
Method FieldPreVld(oSubModel, cModelID, cAction, cID, xValue) Class RU07T12Event
    Local oModel     As Object
    Local oMdlHd     As Object
    Local cDDed      As Character
    Local nOperation As Numeric

    oModel := oSubModel:GetModel()
    nOperation := oModel:GetOperation()
    oMdlHd := oModel:GetModel("RU07T12_F5C")
    
    If cID == "F5C_DEDCOD" .AND. cAction == "SETVALUE"
        cDDed := RU07T12003(xValue)
        oModel:GetModel("RU07T12_F5C"):LoadValue('F5C_DDED', cDDed)
    EndIf

Return .T.
