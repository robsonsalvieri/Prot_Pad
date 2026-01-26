#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE "CRM980EventDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventRUS
Class for catch events for locale Russia

@type 		Class
@author 	Dmitry Borisov
@since		15.01.2024
/*/
//-------------------------------------------------------------------
Class CRM980EventRUS From FwModelEvent 

	Method New() CONSTRUCTOR
    //---------------------
	// PreValidation Model. 
	//---------------------
	Method ModelPreVld()

	Method AfterTTS()
		
EndClass

/*/{Protheus.doc} New()
    Class initialization method

    @type method
    @return 

    @author Dmitry Borisov
    @since 2024/01/15
    @example New()
*/
Method New() Class CRM980EventRUS
Return Nil

/*/{Protheus.doc} ModelPreVld(oModel, cModelId)
    This method needs for validation on delete operation in CRMA980 
    If customer has already used in contracts (F5Q), delete operation not allowed

    @type method
    @param oModel   = Object with model
    @param cID = String with model id, example "SA1MASTER"
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/15
    @example ModelPreVld(oModel, cID)
*/
Method ModelPreVld(oModel,cID) Class CRM980EventRUS
    Local lValid    := .T.
    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        lValid := RU34XFUN08(STR0009, STR0010, "CRMA980", "SA1")
    EndIf
Return (lValid)

/*/{Protheus.doc} AfterTTS(oModel, cModelId)
    This method needs for analytic records creation

    @type method
    @param oModel   = Object with model
    @param cID = String with model id, example "SA1MASTER"
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/15
    @example AfterTTS(oModel, cID)
*/
Method AfterTTS(oModel,cID) Class CRM980EventRUS
	Local nOperation	:= oModel:GetOperation()
	
	If nOperation == MODEL_OPERATION_INSERT
        RU34XREP01("CRMA980", .F.)
	EndIf
Return Nil
//Merge Russia R14                   
