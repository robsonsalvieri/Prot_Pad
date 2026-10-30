#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldCrcd from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldCrcd
    _Super:New()
Return self

Method validate(oEntity) Class CenVldCrcd
Return _Super:validate(oEntity)
