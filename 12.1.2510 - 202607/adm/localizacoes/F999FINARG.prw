#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999FINARG
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999FINARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999FINARG
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999FINARG
Local lRet			:= .T.
	
	self:GetEvent("F999FIN"):lPrCCR     := .T.

	self:GetEvent("F999FIN"):lCposAdic  := .T.

	self:GetEvent("F999FIN"):lReIvSU 	:= SuperGetMv("MV_RETIVA") == "S" .And. SuperGetMv("MV_RETSUSS") == "S"

Return lRet
