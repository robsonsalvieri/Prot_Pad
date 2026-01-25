#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBg9 - Groups Companies
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBg9 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBg9
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBg9

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"operator",self:getValue("BG9_CODINT")) 
    oJsonControl:setProp(oJson,"code",self:getValue("BG9_CODIGO")) 
    oJsonControl:setProp(oJson,"descrOfGroupCompanyC",self:getValue("BG9_DESCRI")) 
    oJsonControl:setProp(oJson,"reducedName",self:getValue("BG9_NREDUZ")) 
    oJsonControl:setProp(oJson,"allowReimb",self:getValue("BG9_PODREM")) 
    oJsonControl:setProp(oJson,"groupType",self:getValue("BG9_TIPO")) 
    oJsonControl:setProp(oJson,"oldCompanyCode",self:getValue("BG9_EMPANT")) 
    oJsonControl:setProp(oJson,"customerCode",self:getValue("BG9_CODCLI")) 
    oJsonControl:setProp(oJson,"store",self:getValue("BG9_LOJA")) 
    oJsonControl:setProp(oJson,"financClassCode",self:getValue("BG9_NATURE")) 
    oJsonControl:setProp(oJson,"supplier",self:getValue("BG9_CODFOR")) 
    oJsonControl:setProp(oJson,"store",self:getValue("BG9_LOJFOR")) 
    oJsonControl:setProp(oJson,"dueDate",self:getValue("BG9_VENCTO")) 
    oJsonControl:setProp(oJson,"use",self:getValue("BG9_USO")) 
    oJsonControl:setProp(oJson,"adjustmentMonth",self:getValue("BG9_MESREA")) 
    oJsonControl:setProp(oJson,"adjustmentIndex",self:getValue("BG9_INDREA")) 
    oJsonControl:setProp(oJson,"userMinCollecValue",self:getValue("BG9_VALFAI")) 
    oJsonControl:setProp(oJson,"paymentModeCode",self:getValue("BG9_TIPPAG")) 
    oJsonControl:setProp(oJson,"customerBank",self:getValue("BG9_BCOCLI")) 
    oJsonControl:setProp(oJson,"customerBranch",self:getValue("BG9_AGECLI")) 
    oJsonControl:setProp(oJson,"customerAccount",self:getValue("BG9_CTACLI")) 
    oJsonControl:setProp(oJson,"operatorBank",self:getValue("BG9_PORTAD")) 
    oJsonControl:setProp(oJson,"operatorBranch",self:getValue("BG9_AGEDEP")) 
    oJsonControl:setProp(oJson,"operatorAccount",self:getValue("BG9_CTACOR")) 
    oJsonControl:setProp(oJson,"chargeInterestNextMont",self:getValue("BG9_COBJUR")) 
    oJsonControl:setProp(oJson,"specialBranch",self:getValue("BG9_FILESP")) 
    oJsonControl:setProp(oJson,"dailyInterest",self:getValue("BG9_TAXDIA")) 
    oJsonControl:setProp(oJson,"dailyInterestValue",self:getValue("BG9_JURDIA")) 
    oJsonControl:setProp(oJson,"majority",self:getValue("BG9_MAIORI")) 
    oJsonControl:setProp(oJson,"regionCode",self:getValue("BG9_CODREG")) 
    oJsonControl:setProp(oJson,"regionDescription",self:getValue("BG9_DESREG")) 
    oJsonControl:setProp(oJson,"billingCompany",self:getValue("BG9_EMPFAT")) 
    oJsonControl:setProp(oJson,"billingBranch",self:getValue("BG9_FILFAT")) 
    oJsonControl:setProp(oJson,"descCompanyBillBranch",self:getValue("BG9_DESEMP")) 
    oJsonControl:setProp(oJson,"hspCompanyCode",self:getValue("BG9_HSPEMP")) 
    oJsonControl:setProp(oJson,"nrOfDefaultDays",self:getValue("BG9_DIASIN")) 
    oJsonControl:setProp(oJson,"onlendingCompany",self:getValue("BG9_REPASS")) 
    oJsonControl:setProp(oJson,"erpProductCode",self:getValue("BG9_CODSB1")) 
    oJsonControl:setProp(oJson,"invoiceOutflowType",self:getValue("BG9_CODTES")) 
    oJsonControl:setProp(oJson,"automaticCompensation",self:getValue("BG9_COMAUT")) 

Return oJson

Method destroy() Class PLSBg9
	_Super:destroy()
	DelClassIntF()
return