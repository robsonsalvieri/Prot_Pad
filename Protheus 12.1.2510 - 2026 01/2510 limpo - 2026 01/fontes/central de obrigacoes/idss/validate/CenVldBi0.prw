#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldBi0 from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldBi0
    _Super:New()
Return self

Method validate(oEntity) Class CenVldBi0
Return _Super:validate(oEntity)
