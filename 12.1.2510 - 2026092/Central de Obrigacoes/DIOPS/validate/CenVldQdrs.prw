#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldQdrs from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldQdrs
    _Super:New()
Return self

Method validate(oEntity) Class CenVldQdrs
Return _Super:validate(oEntity)
