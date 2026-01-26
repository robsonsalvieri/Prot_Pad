#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldLcpr from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldLcpr
    _Super:New()
Return self

Method validate(oEntity) Class CenVldLcpr
Return _Super:validate(oEntity)
