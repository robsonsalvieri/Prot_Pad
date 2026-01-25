#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBt5 - Contract Company Group
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBt5 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBt5
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBt5

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"operator",self:getValue("BT5_CODINT")) 
    oJsonControl:setProp(oJson,"code",self:getValue("BT5_CODIGO")) 
    oJsonControl:setProp(oJson,"contractNumber",self:getValue("BT5_NUMCON")) 
    oJsonControl:setProp(oJson,"version",self:getValue("BT5_VERSAO")) 
    oJsonControl:setProp(oJson,"contractDate",self:getValue("BT5_DATCON")) 
    oJsonControl:setProp(oJson,"contractType",self:getValue("BT5_TIPCON")) 
    oJsonControl:setProp(oJson,"formerContractNumber",self:getValue("BT5_ANTCON")) 
    oJsonControl:setProp(oJson,"chargeThisLevel",self:getValue("BT5_COBNIV")) 
    oJsonControl:setProp(oJson,"customerCode",self:getValue("BT5_CODCLI")) 
    oJsonControl:setProp(oJson,"store",self:getValue("BT5_LOJA")) 
    oJsonControl:setProp(oJson,"customerName",self:getValue("BT5_NOME")) 
    oJsonControl:setProp(oJson,"financialClassCode",self:getValue("BT5_NATURE")) 
    oJsonControl:setProp(oJson,"supplier",self:getValue("BT5_CODFOR")) 
    oJsonControl:setProp(oJson,"store",self:getValue("BT5_LOJFOR")) 
    oJsonControl:setProp(oJson,"dueDate",self:getValue("BT5_VENCTO")) 
    oJsonControl:setProp(oJson,"interchangeSubContract",self:getValue("BT5_INTERC")) 
    oJsonControl:setProp(oJson,"paymentMode",self:getValue("BT5_MODPAG")) 
    oJsonControl:setProp(oJson,"interchangeType",self:getValue("BT5_TIPOIN")) 
    oJsonControl:setProp(oJson,"allOperators",self:getValue("BT5_ALLOPE")) 
    oJsonControl:setProp(oJson,"interchangeOperator",self:getValue("BT5_OPEINT")) 
    oJsonControl:setProp(oJson,"importedFile",self:getValue("BT5_IMPORT")) 
    oJsonControl:setProp(oJson,"notifyAns",self:getValue("BT5_INFANS")) 
    oJsonControl:setProp(oJson,"paymentModeCode",self:getValue("BT5_TIPPAG")) 
    oJsonControl:setProp(oJson,"customerBank",self:getValue("BT5_BCOCLI")) 
    oJsonControl:setProp(oJson,"customerBranch",self:getValue("BT5_AGECLI")) 
    oJsonControl:setProp(oJson,"customerAccount",self:getValue("BT5_CTACLI")) 
    oJsonControl:setProp(oJson,"operatorBank",self:getValue("BT5_PORTAD")) 
    oJsonControl:setProp(oJson,"operatorBranch",self:getValue("BT5_AGEDEP")) 
    oJsonControl:setProp(oJson,"operatorAccount",self:getValue("BT5_CTACOR")) 
    oJsonControl:setProp(oJson,"chargeInterNextMonth",self:getValue("BT5_COBJUR")) 
    oJsonControl:setProp(oJson,"dailyInterestPercentage",self:getValue("BT5_TAXDIA")) 
    oJsonControl:setProp(oJson,"dailyInterestAmount",self:getValue("BT5_JURDIA")) 
    oJsonControl:setProp(oJson,"majority",self:getValue("BT5_MAIORI")) 
    oJsonControl:setProp(oJson,"allowReimburs",self:getValue("BT5_PODREM")) 
    oJsonControl:setProp(oJson,"nrOfDefaultDays",self:getValue("BT5_DIASIN")) 
    oJsonControl:setProp(oJson,"surplusType",self:getValue("BT5_CODTES")) 
    oJsonControl:setProp(oJson,"erpProductCode",self:getValue("BT5_CODSB1")) 
    oJsonControl:setProp(oJson,"disused",self:getValue("BT5_CODANS")) 
    oJsonControl:setProp(oJson,"ansCodeReciprocity",self:getValue("BT5_CODOPE")) 
    oJsonControl:setProp(oJson,"automaticCompensation",self:getValue("BT5_COMAUT")) 
    oJsonControl:setProp(oJson,"addedToRiskPool",self:getValue("BT5_AGR309")) 

Return oJson

Method destroy() Class PLSBt5
	_Super:destroy()
	DelClassIntF()
return