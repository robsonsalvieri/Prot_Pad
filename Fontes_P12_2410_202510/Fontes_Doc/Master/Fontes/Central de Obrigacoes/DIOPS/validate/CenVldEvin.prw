#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldEvin from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldEvin
    _Super:New()
Return self

Method validate(oEntity) Class CenVldEvin
Return _Super:validate(oEntity)
