#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldSaid from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldSaid
    _Super:New()
Return self

Method validate(oEntity) Class CenVldSaid
Return _Super:validate(oEntity)
