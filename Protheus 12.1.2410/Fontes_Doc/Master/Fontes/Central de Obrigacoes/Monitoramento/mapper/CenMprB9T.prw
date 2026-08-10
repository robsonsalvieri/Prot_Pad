#include "TOTVS.CH"

Class CenMprB9T from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB9T
    _Super:new()

    aAdd(self:aFields,{"B9T_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"B9T_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B9T_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"B9T_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B9T_COMCOB" ,"periodCover"})
    aAdd(self:aFields,{"B9T_CPFCNP" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"B9T_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"B9T_RGOPIN" ,"ansRecordNumber"})
    aAdd(self:aFields,{"B9T_STATUS" ,"status"})
    aAdd(self:aFields,{"B9T_TPRGMN" ,"monitoringRecordType"})
    aAdd(self:aFields,{"B9T_VLRPRE" ,"presetValue"})
    aAdd(self:aFields,{"B9T_DATPRO" ,"processingDate"})
    aAdd(self:aFields,{"B9T_HORPRO" ,"processingTime"})
    aAdd(self:aFields,{"B9T_IDEPRE" ,"providerIdentifier"})
    aAdd(self:aFields,{"B9T_IDVLRP" ,"presetValueIdent"})
    aAdd(self:aFields,{"B9T_CNES" ,"cnes"})
    aAdd(self:aFields,{"B9T_CDMNPR" ,"cityOfProvider"})
    aAdd(self:aFields,{"B9T_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"B9T_HORINC" ,"inclusionTime"})

Return self
