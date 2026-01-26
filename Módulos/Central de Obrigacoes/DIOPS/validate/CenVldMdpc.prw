#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldMdpc from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldMdpc
    _Super:New()
Return self

Method validate(oEntity) Class CenVldMdpc
Return _Super:validate(oEntity)
