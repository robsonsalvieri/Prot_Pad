#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldAgcn from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldAgcn
    _Super:New()
Return self

Method validate(oEntity) Class CenVldAgcn
Return _Super:validate(oEntity)
