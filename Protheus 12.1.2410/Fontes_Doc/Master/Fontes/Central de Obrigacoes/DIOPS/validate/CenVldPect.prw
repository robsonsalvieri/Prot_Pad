#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldPect from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldPect
    _Super:New()
Return self

Method validate(oEntity) Class CenVldPect
Return _Super:validate(oEntity)
