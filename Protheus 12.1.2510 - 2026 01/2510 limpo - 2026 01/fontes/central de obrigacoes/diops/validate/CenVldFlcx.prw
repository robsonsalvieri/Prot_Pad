#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldFlcx from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldFlcx
    _Super:New()
Return self

Method validate(oEntity) Class CenVldFlcx
Return _Super:validate(oEntity)
