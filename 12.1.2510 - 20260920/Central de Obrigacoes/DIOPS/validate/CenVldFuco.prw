#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldFuco from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldFuco
    _Super:New()
Return self

Method validate(oEntity) Class CenVldFuco
Return _Super:validate(oEntity)
