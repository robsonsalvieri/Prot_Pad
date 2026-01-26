#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldSpid from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldSpid
    _Super:New()
Return self

Method validate(oEntity) Class CenVldSpid
Return _Super:validate(oEntity)
