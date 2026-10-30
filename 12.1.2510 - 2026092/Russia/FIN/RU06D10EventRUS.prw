#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Class RU06D10EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method GridLinePreVld()
    Method ModelPosVld()
    Method AfterTTS()
				
EndClass

Method New() Class RU06D10EventRUS
Return Nil

/*/{Protheus.doc} GridLinePreVld
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@description this method is used for total' counting and perfom trigger
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU06D10EventRUS
    Local lDel as Logical

    lDel := .F.
    If cAction == "DELETE"
        lDel := .T.
    Endif
    If cAction == "UNDELETE" .OR. cAction == "DELETE"
        RU06D10016_UpdTotal("F6W_WRITT", oSubModel:oFormModelOwner:oFormModel, .T., lDel, nLine)
        RU06D10016_UpdTotal("F6W_RECEIV", oSubModel:oFormModelOwner:oFormModel, .T., lDel, nLine)
    Elseif cAction == "SETVALUE"
        If cId == "F6W_BNKNUM" .AND. xValue != xCurrentValue
            RU06D10030_FillF4C(oSubModel, nLine)
        Elseif cId == "F6W_PAYORD" .AND. xValue != xCurrentValue
            RU06D10046_FillAfterF49(oSubModel, nLine)
        EndIf      
    EndIf      
Return .T.

/*/{Protheus.doc} ModelPosVld
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
*/
Method ModelPosVld(oModel, cModelID) Class RU06D10EventRUS
    Local lRet as Logical
    Local nOperation as Numeric

    lRet := .T.
    nOperation := oModel:GetOperation() 

    If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
        lRet := RU06D10002_VldBeforeSave(oModel)
    EndIf

Return lRet

/*/{Protheus.doc} AfterTTS
@author Olga Galyandina
@since 01/03/2024
@version 14
*/
Method AfterTTS(oModel, cModelID) Class RU06D10EventRUS
    Local lRet as Logical
    Local nOperation as Numeric

    lRet := .T.
    nOperation := oModel:GetOperation() 

    If cModelID == "RU06D10"
        lRet := RU06D10042_SetStatus(oModel)
    EndIf

Return lRet
                   
//Merge Russia R14 
                   
