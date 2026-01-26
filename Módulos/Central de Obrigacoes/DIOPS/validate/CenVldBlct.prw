#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldBlct from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldBlct
    _Super:New()
Return self

Method validate(oEntity) Class CenVldBlct
Return _Super:validate(oEntity)
