#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PMSA200.CH"


/*{Protheus.doc} PMSA200EventRUS
@type 		class
@author Dmitry Borisov
@since 04/10/2023
@version 
@description Class to handle business procces of PMSA200RUS
*/

Class PMSA200EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
	Method AfterTTS()
EndClass

Method New() Class PMSA200EventRUS
Return Nil

/*{Protheus.doc} PMSA200EventRUS
@type 		method
@author Dmitry Borisov
@since 04/10/2023
@version 
@description Run syncronization with analytics on insert  
*/
Method AfterTTS(oModel, cModelId) Class PMSA200EventRUS 

    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        RU34XREP01("PMSA410", .F.)
    EndIf

Return Nil
                   
//Merge Russia R14 
                   
