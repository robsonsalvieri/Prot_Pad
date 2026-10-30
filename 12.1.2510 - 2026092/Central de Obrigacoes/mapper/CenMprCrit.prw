#include "TOTVS.CH"

Class CenMprCrit from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprCrit
    _Super:new()

    aAdd(self:aFields,{"B3F_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B3F_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"B3F_CHVORI" ,"originRegAcknowlegm"})
    aAdd(self:aFields,{"B3F_CODCRI" ,"reviewCode"})
    aAdd(self:aFields,{"B3F_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B3F_DESORI" ,"originDescription"})
    aAdd(self:aFields,{"B3F_IDEORI" ,"originIdentKey"})
    aAdd(self:aFields,{"B3F_ORICRI" ,"reviewOrigin"})
    aAdd(self:aFields,{"B3F_ANO" ,"commitReferenceYear"})
    aAdd(self:aFields,{"B3F_TIPO" ,"type"})
    aAdd(self:aFields,{"B3F_CAMPOS" ,"affectedFields"})
    aAdd(self:aFields,{"B3F_SOLUCA" ,"suggestOfRevSolution"})
    aAdd(self:aFields,{"B3F_STATUS" ,"reviewStatus"})
    aAdd(self:aFields,{"B3F_CRIANS" ,"ansCritCode"})
    aAdd(self:aFields,{"B3F_DESCRI" ,"reviewDescription"})

Return self
