#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldAgim from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldAgim
    _Super:New()
Return self

Method validate(oEntity) Class CenVldAgim
Return _Super:validate(oEntity)
