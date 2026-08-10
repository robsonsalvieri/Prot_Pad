#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldComp from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldComp
    _Super:New()
Return self

Method validate(oEntity) Class CenVldComp
Return _Super:validate(oEntity)
