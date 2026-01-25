#include "TOTVS.CH"

Class CenMprDepn from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprDepn
    _Super:new()

    aAdd(self:aFields,{"B8Z_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8Z_CNPJ" ,"legalEntityNatRegister"})
    aAdd(self:aFields,{"B8Z_CODCEP" ,"postAddrCode"})
    aAdd(self:aFields,{"B8Z_CODDDD" ,"longDistanceCode"})
    aAdd(self:aFields,{"B8Z_CODDDI" ,"internationalCallinfCd"})
    aAdd(self:aFields,{"B8Z_BAIRRO" ,"district"})
    aAdd(self:aFields,{"B8Z_CDIBGE" ,"ibgeCityCode"})
    aAdd(self:aFields,{"B8Z_COMDEP" ,"addressComplement"})
    aAdd(self:aFields,{"B8Z_EMAIL" ,"eMail"})
    aAdd(self:aFields,{"B8Z_NMLOGR" ,"addressName"})
    aAdd(self:aFields,{"B8Z_NOMRAZ" ,"corporateName"})
    aAdd(self:aFields,{"B8Z_NUMLOG" ,"addressNumber"})
    aAdd(self:aFields,{"B8Z_RAMAL" ,"extensionLine"})
    aAdd(self:aFields,{"B8Z_SIGLUF" ,"stateAcronym"})
    aAdd(self:aFields,{"B8Z_TELEFO" ,"telephoneNumber"})
    aAdd(self:aFields,{"B8Z_TIPODE" ,"dependenceType"})

Return self
