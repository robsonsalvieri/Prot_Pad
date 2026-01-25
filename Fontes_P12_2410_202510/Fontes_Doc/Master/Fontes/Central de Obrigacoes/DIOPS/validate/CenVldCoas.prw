#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldCoas from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldCoas
    _Super:New()
Return self

Method validate(oEntity) Class CenVldCoas
Return _Super:validate(oEntity)
