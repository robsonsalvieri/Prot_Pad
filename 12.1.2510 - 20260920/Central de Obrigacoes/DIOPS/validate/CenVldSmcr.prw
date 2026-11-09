#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldSmcr from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldSmcr
    _Super:New()
Return self

Method validate(oEntity) Class CenVldSmcr
Return _Super:validate(oEntity)
