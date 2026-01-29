#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} FINV999PER
	Clase responsable por el evento de reglas de negocio de localización Peru
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		07/10/2025
/*/
Class FINV999PER From FwModelEvent 

	Method New() CONSTRUCTOR

	Method VldActivate()

EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		07/10/2025
/*/
Method New() Class FINV999PER
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		07/10/2025
/*/
Method VldActivate(oModel) Class FINV999PER
Local lRet			:= .T.

	self:GetEvent("FINV999"):lPeru := .T.

Return lRet
