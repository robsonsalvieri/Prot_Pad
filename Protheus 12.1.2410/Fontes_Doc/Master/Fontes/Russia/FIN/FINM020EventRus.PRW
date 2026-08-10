#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} FINM020EventRus
@type           Class
@description    Call Revaluation before Write-off on AP
@author         Nikita.Lysenko
@since          24/03/2021
@version        1.0
@project        MA3 - Russia
*/
Class FINM020EventRus From FwModelEvent 
	Method New() CONSTRUCTOR
    Method BeforeTTS()
EndClass

/*{Protheus.doc} New
@type           Method
@description    
@author         Nikita.Lysenko
@since          24/03/2021
@version        1.0
@project        MA3 - Russia
*/
Method New() Class FINM020EventRus
Return Nil

/*{Protheus.doc} BeforeTTS
@type           Method
@description    Recalculation of values of document values according to new values of exchange rates
@author         Nikita.Lysenko
@modified       Anton.Stepanov // because new FINA080
@since          24/03/2021
@version        1.1
@project        MA3 - Russia
*/
Method BeforeTTS(oModel, cModelID) Class FINM020EventRus
Return .T.








                   
//Merge Russia R14 
                   
