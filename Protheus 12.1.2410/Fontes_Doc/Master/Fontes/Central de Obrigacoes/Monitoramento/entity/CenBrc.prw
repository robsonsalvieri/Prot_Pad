#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBrc - monitFormPackages
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBrc from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBrc
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBrc

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"itemProCode",self:getValue("itemProCode")) /* Column BRC_CDPRIT */ 
    oJsonControl:setProp(oJson,"itemTableCode",self:getValue("itemTableCode")) /* Column BRC_CDTBIT */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRC_CODOPE */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BRC_SEQGUI */ 
    oJsonControl:setProp(oJson,"sequentialItem",self:getValue("sequentialItem")) /* Column BRC_SEQITE */ 
    oJsonControl:setProp(oJson,"packageQuantity",self:getValue("packageQuantity")) /* Column BRC_QTPRPC */ 

Return oJson

Method destroy() Class CenBrc
	_Super:destroy()
	DelClassIntF()
return