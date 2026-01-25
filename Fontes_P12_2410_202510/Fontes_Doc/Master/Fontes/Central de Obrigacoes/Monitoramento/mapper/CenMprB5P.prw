#include "TOTVS.CH"

Class CenMprB5P from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB5P
    _Super:new()

    aAdd(self:aFields,{"B5P_CDCMGU" ,"formFieldIdentifier"})
    aAdd(self:aFields,{"B5P_CDCMER" ,"errorCode"})
    aAdd(self:aFields,{"B5P_DESERR" ,"errorDescription"})
    aAdd(self:aFields,{"B5P_NIVERR" ,"errorLevel"})
    aAdd(self:aFields,{"B5P_CODOPE" ,"ansRegister"})
    aAdd(self:aFields,{"B5P_CMPLOT" ,"batchPeriod"})
    aAdd(self:aFields,{"B5P_NUMLOT" ,"batchNumber"})
    aAdd(self:aFields,{"B5P_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"B5P_NMGPRE" ,"providerFormNumber"})
    aAdd(self:aFields,{"B5P_IDREEM" ,"refundIdentifier"})
    aAdd(self:aFields,{"B5P_DATPRO" ,"processingDate"})
    aAdd(self:aFields,{"B5P_CODPAD" ,"tableCode"})
    aAdd(self:aFields,{"B5P_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"B5P_CDDENT" ,"toothCode"})
    aAdd(self:aFields,{"B5P_CDFACE" ,"toothFaceCode"})
    aAdd(self:aFields,{"B5P_CDREGI" ,"regionCode"})
    aAdd(self:aFields,{"B5P_CODGRU" ,"procedureGroup"})
    aAdd(self:aFields,{"B5P_CNES"   ,"cnes"})
    aAdd(self:aFields,{"B5P_CPFCGC" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"B5P_CONCAM" ,"fieldContent"})

Return self
