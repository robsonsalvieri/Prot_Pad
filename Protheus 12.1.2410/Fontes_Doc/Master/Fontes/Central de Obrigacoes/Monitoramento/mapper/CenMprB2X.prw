#include "TOTVS.CH"

Class CenMprB2X from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2X
    _Super:new()

    aAdd(self:aFields,{"B2X_SEQUEN" ,"formSequential"})
    aAdd(self:aFields,{"B2X_VLRPRE" ,"presetValue"})
    aAdd(self:aFields,{"B2X_CDMNPR" ,"cityOfProvider"})
    aAdd(self:aFields,{"B2X_CNES" ,"cnes"})
    aAdd(self:aFields,{"B2X_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B2X_COMCOB" ,"periodCover"})
    aAdd(self:aFields,{"B2X_CPFCNP" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"B2X_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"B2X_EXCLU" ,"exclusionId"})
    aAdd(self:aFields,{"B2X_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"B2X_IDEPRE" ,"providerIdentifier"})
    aAdd(self:aFields,{"B2X_IDVLRP" ,"presetValueIdent"})
    aAdd(self:aFields,{"B2X_PROCES" ,"processed"})
    aAdd(self:aFields,{"B2X_RGOPIN" ,"ansRecordNumber"})
    aAdd(self:aFields,{"B2X_ROBOID" ,"roboId"})

Return self
