#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldPesl from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldPesl
    _Super:New()
Return self

Method validate(oEntity) Class CenVldPesl
Return _Super:validate(oEntity)
