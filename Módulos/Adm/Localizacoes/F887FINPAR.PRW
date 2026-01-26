#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINPAR
Clase responsable por el evento de reglas de negocio de 
localización de Paraguay

@type 		Class
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Class F887FINPAR From FwModelEvent 

	Method New() CONSTRUCTOR
	Method VldActivate() 
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Method New() Class F887FINPAR
	
Return Nil

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		06/07/2022
/*/
Method VldActivate(oModel) Class F887FINPAR
Local cCredMed	:=  GetSESTipos({|| ES_RCOPGER == "1"},"1")
Local cCredInm	:= 	GetSESTipos({|| ES_RCOPGER == "2"},"1")
Local lRet		:= .T.

	self:GetEvent("F887FIN"):cCredMed := IIf(Empty(cCredMed),"CH |CC |CD ",cCredMed)
	self:GetEvent("F887FIN"):cCredInm := IIf(Empty(cCredInm),"TF |EF ",cCredInm)
	self:GetEvent("F887FIN"):lDocTran := .T.
	self:GetEvent("F887FIN"):lProcede := .F.
	self:GetEvent("F887FIN"):lTasa := .F.
	self:GetEvent("F887FIN"):lSituaca := .T.

Return lRet
