#include "TOTVS.CH"

Class PrjMprBI8 from CenMapper

    Method New() Constructor

EndClass

Method New() Class PrjMprBI8
    _Super:new()

    aAdd(self:aFields,{"BI8_CODIGO" ,"codigo"})
    aAdd(self:aFields,{"BI8_NOME"   ,"artefato"})
    aAdd(self:aFields,{"BI8_STATUS" ,"status"})
    aAdd(self:aFields,{"BI8_ULTVER" ,"versao"})
    aAdd(self:aFields,{"BI8_VERLOC" ,"versaoLocal"})
    aAdd(self:aFields,{"BI8_ATUAUT" ,"atualizaAutomatico"})
    aAdd(self:aFields,{"BI8_STATAU" ,"statusAtuaAuto"})
    aAdd(self:aFields,{"BI8_DATA"   ,"data"})
    aAdd(self:aFields,{"BI8_HORA"   ,"hora"})
    //aAdd(self:aFields,{"BI8_DESERR" ,"descErro"})
    aAdd(self:aFields,{"BI8_DESCUS" ,"destCustomizavel"})
    
Return self
