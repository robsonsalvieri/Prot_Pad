#include "TOTVS.CH"

Class CenMprRepr from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprRepr
    _Super:new()

    aAdd(self:aFields,{"B8N_CPFREP" ,"registrationOfIndividua"})
    aAdd(self:aFields,{"B8N_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8N_COMPEN" ,"addressComplement"})
    aAdd(self:aFields,{"B8N_BAIRRO" ,"district"})
    aAdd(self:aFields,{"B8N_CARGO" ,"representativeSPosition"})
    aAdd(self:aFields,{"B8N_CDIBGE" ,"ibgeCityCode"})
    aAdd(self:aFields,{"B8N_CODCEP" ,"postAddrCode"})
    aAdd(self:aFields,{"B8N_CODDDD" ,"nationalCallingCd"})
    aAdd(self:aFields,{"B8N_CODDDI" ,"internationalCallinfCd"})
    aAdd(self:aFields,{"B8N_DTEXRG" ,"idIssueDate"})
    aAdd(self:aFields,{"B8N_NMLOGR" ,"addressName"})
    aAdd(self:aFields,{"B8N_NOMEDE" ,"representativeSName"})
    aAdd(self:aFields,{"B8N_NUMERG" ,"idNumber"})
    aAdd(self:aFields,{"B8N_NUMLOG" ,"addressNumber"})
    aAdd(self:aFields,{"B8N_ORGEXP" ,"idIssuingBody"})
    aAdd(self:aFields,{"B8N_PAIS" ,"country"})
    aAdd(self:aFields,{"B8N_RAMAL" ,"extension"})
    aAdd(self:aFields,{"B8N_SIGLUF" ,"stateAcronym"})
    aAdd(self:aFields,{"B8N_TELEFO" ,"telephoneNumber"})

Return self
