#include "TOTVS.CH"

Class CenMprBw8 from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBw8
    _Super:new()

    aAdd(self:aFields,{"BW8_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BW8_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BW8_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BW8_MATRIC" ,"registration"})
    aAdd(self:aFields,{"BW8_NMGPRE" ,"providerFormNumber"})
    aAdd(self:aFields,{"BW8_PROCES" ,"processed"})
    aAdd(self:aFields,{"BW8_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"BW8_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"BW8_EXCLU" ,"exclusionId"})
    aAdd(self:aFields,{"BW8_ROBOID" ,"roboId"})
    
	aAdd(self:aExpand,{"monitDirectSupplyEvents"})

Return self
