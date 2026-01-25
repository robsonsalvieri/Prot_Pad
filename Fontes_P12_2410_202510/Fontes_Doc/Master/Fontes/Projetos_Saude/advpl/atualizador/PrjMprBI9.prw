#include "TOTVS.CH"

Class PrjMprBI9 from CenMapper

    Method New() Constructor

EndClass

Method New() Class PrjMprBI9
    _Super:new()

    aAdd(self:aFields,{"BI9_CODIGO" ,"codigo"   })
    aAdd(self:aFields,{"BI9_VERDIS" ,"versao"   })
    aAdd(self:aFields,{"BI9_STATAU" ,"statusAtualizacao"})
    //aAdd(self:aFields,{"BI9_DESERR" ,"DescErro" })
    aAdd(self:aFields,{"BI9_ATIVO"  ,"ativo"    })
    
Return self
