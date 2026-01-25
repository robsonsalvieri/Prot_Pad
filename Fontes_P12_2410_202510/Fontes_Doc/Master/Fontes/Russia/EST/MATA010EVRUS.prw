#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'
#include "FWEVENTVIEWCONSTS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} MATA010EVRUS
Class for catch events for locale Russia

@type 		Class
@author 	Dmitry Borisov
@since		15.01.2024
/*/
//-------------------------------------------------------------------
CLASS MATA010EVRUS FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	
    METHOD AfterTTS()
	
ENDCLASS

/*/{Protheus.doc} New()
    Class initialization method

    @type method
    @return 

    @author Dmitry Borisov
    @since 2024/01/15
    @example New()
*/
METHOD New() CLASS MATA010EVRUS
Return

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
METHOD AfterTTS(oModel, cID) CLASS MATA010EVRUS
    If oModel:GetOperation() == MODEL_OPERATION_INSERT	
        RU34XREP01("MATA010", .F.)
    EndIf
Return
