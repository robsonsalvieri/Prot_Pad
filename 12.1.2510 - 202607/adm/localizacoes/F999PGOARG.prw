#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999PGOARG
	Clase responsable por el evento de reglas de negocio referente al proceso formas de pago para Argentina
	@type 		Class
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@since		12/05/2026
/*/
Class F999PGOARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@since		12/05/2026
/*/
Method New() Class F999PGOARG
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	Jose.Gonzalez
	@version	12.1.2410 / Superior
	@since		12/05/2026
	@param
	@return		lRet - lógico - resultado de la validación
/*/
Method VldActivate() Class F999PGOARG
Local lRet	:= .T.
	
	self:GetEvent("F999PGO"):lPag1		:= .T.
	
	self:GetEvent("F999PGO"):lChEQU		:= .T.

	self:GetEvent("F999PGO"):lElt		:= .T.

	self:GetEvent("F999PGO"):lCBU		:= .T.
	
	self:GetEvent("F999PGO"):lTalao		:= .T.

	self:GetEvent("F999PGO"):lBxE2		:= .T.

Return lRet
