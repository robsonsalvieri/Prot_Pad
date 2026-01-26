#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldCcop from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldCcop
    _Super:New()
Return self

Method validate(oEntity) Class CenVldCcop
Return _Super:validate(oEntity)
