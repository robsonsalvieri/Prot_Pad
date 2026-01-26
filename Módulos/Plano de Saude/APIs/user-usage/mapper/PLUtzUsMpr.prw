#include "TOTVS.CH"

Class PLUtzUsMpr from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLUtzUsMpr
    _Super:new()

    //Campo Protheus - atributo
    aAdd(self:aFields,{"BD6_CODPRO","procedureCode"})
    aAdd(self:aFields,{"BD6_DESPRO","procedureName"})
    aAdd(self:aFields,{"BD6_DATPRO","executionDate"})
    aAdd(self:aFields,{"BD6_NOMUSR","subscribername"})
    aAdd(self:aFields,{"BD6_CODRDA","healthProviderCode"})
    aAdd(self:aFields,{"BD6_NOMRDA","healthProviderName"})
    aAdd(self:aFields,{"BR8_CLASSE","serviceType"})
    aAdd(self:aFields,{"BJE_DESCRI","serviceTypeDescription"})
    aAdd(self:aFields,{"BD6_QTDPRO","quantity"})
    aAdd(self:aFields,{"BD6_CPFRDA","healthProviderDocument"})
    aAdd(self:aFields,{"BD6_CID"   ,"cid"})
    aAdd(self:aFields,{"BD6_DENREG","toothRegion"})
    aAdd(self:aFields,{"BD6_FADENT","face"})
    aAdd(self:aFields,{"BD6_VLRPAG","paidValue"})
    aAdd(self:aFields,{"BD6_VLRGLO","disallowanceValue"})
    aAdd(self:aFields,{"BD6_VLRTPF","coPaymentValue"})
    aAdd(self:aFields,{"BD6_TIPGUI","origin"})
    aAdd(self:aFields,{"BR8_TPPROC","procedureType"})
    aAdd(self:aFields,{"BA1_SEXO"  ,"gender"})
    aAdd(self:aFields,{"BA1_DATNAS","birthDate"})
    aAdd(self:aFields,{"BA1_DATINC","inclusionDate"})
    aAdd(self:aFields,{"BA1_DATBLO","blockDate"})
    aAdd(self:aFields,{"BA1_TIPUSU","userType"})
    aAdd(self:aFields,{"BA1_CODMUN","countyCode"})

    //Campos juncao de query
    aAdd(self:aFields,{"MATRIC"    ,"subscriberId"})
    aAdd(self:aFields,{"GUIAINT"   ,"hospitalizationNumber"})
    aAdd(self:aFields,{"STATUS"    ,"status"})
    
Return self