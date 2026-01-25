#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldPact from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldPact
    _Super:New()
Return self

Method validate(oEntity) Class CenVldPact
Return _Super:validate(oEntity)
