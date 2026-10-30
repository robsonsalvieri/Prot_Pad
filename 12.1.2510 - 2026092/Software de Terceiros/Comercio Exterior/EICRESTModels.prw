#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

static lAPIRest := nil

Class EICRestModels From FwRestModel
	
	Method Activate()
	Method DeActivate()

EndClass

//-------------------------------------------------------------------
Method Activate() Class EICRestModels
   lAPIRest := .T.
Return _Super:Activate()

//-------------------------------------------------------------------
Method DeActivate() Class EICRestModels
   lAPIRest := .F.
Return _Super:DeActivate()


function EasyIsRest()
   if lAPIRest == nil
      lAPIRest := .F.
   endif
return lAPIRest

//-------------------------------------------------------------------
/* Publicação dos modelos que são disponibilizados no REST */
PUBLISH MODEL REST NAME EICCP400 SOURCE EICCP400 RESOURCE OBJECT EICRestModels
