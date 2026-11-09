#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade CenBI0 - Indicadores IDSS
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBI0 from CenEntity

    Method New()

    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBI0
    _Super:New()
Return self

Method serialize(oJsonControl) Class CenBI0

    Local oJson := JsonObject():New()
    Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"healthInsurerCode",self:getValue("healthInsurerCode"))
    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear"))
    oJsonControl:setProp(oJson,"numeratorTissRatio",self:getValue("numeratorTissRatio"))
    oJsonControl:setProp(oJson,"denominatorTissRatio",self:getValue("denominatorTissRatio"))
    oJsonControl:setProp(oJson,"partialTissRatio",self:getValue("partialTissRatio"))
    oJsonControl:setProp(oJson,"totalTissRatio",self:getValue("totalTissRatio"))

Return oJson

Method destroy() Class CenBI0
    _Super:destroy()
    DelClassIntF()
return