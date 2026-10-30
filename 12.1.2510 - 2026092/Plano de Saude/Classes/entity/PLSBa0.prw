#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBa0 - Health Operators
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBa0 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBa0
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBa0

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"companyIdentCode",self:getValue("BA0_CODIDE")) 
    oJsonControl:setProp(oJson,"operator",self:getValue("BA0_CODINT")) 
    oJsonControl:setProp(oJson,"operator",self:getValue("BA0_NOMINT")) 
    oJsonControl:setProp(oJson,"operator",self:getValue("BA0_CLAINT")) 
    oJsonControl:setProp(oJson,"operatorGroup",self:getValue("BA0_GRUOPE")) 
    oJsonControl:setProp(oJson,"clearingHouse",self:getValue("BA0_CAMCOM")) 
    oJsonControl:setProp(oJson,"ansRegistrationNumber",self:getValue("BA0_SUSEP")) 
    oJsonControl:setProp(oJson,"cnpj",self:getValue("BA0_CGC")) 
    oJsonControl:setProp(oJson,"stateRegistration",self:getValue("BA0_INCEST")) 
    oJsonControl:setProp(oJson,"eMail",self:getValue("BA0_EMAIL")) 
    oJsonControl:setProp(oJson,"homePageInInternet",self:getValue("BA0_SITE")) 
    oJsonControl:setProp(oJson,"foundationDate",self:getValue("BA0_DATFUN")) 
    oJsonControl:setProp(oJson,"zip",self:getValue("BA0_CEP")) 
    oJsonControl:setProp(oJson,"address",self:getValue("BA0_END")) 
    oJsonControl:setProp(oJson,"number",self:getValue("BA0_NUMEND")) 
    oJsonControl:setProp(oJson,"complement",self:getValue("BA0_COMPEN")) 
    oJsonControl:setProp(oJson,"district",self:getValue("BA0_BAIRRO")) 
    oJsonControl:setProp(oJson,"cityCode",self:getValue("BA0_CODMUN")) 
    oJsonControl:setProp(oJson,"city",self:getValue("BA0_CIDADE")) 
    oJsonControl:setProp(oJson,"state",self:getValue("BA0_EST")) 
    oJsonControl:setProp(oJson,"phone01",self:getValue("BA0_TELEF1")) 
    oJsonControl:setProp(oJson,"phone02",self:getValue("BA0_TELEF2")) 
    oJsonControl:setProp(oJson,"phone03",self:getValue("BA0_TELEF3")) 
    oJsonControl:setProp(oJson,"fax01",self:getValue("BA0_FAX1")) 
    oJsonControl:setProp(oJson,"fax02",self:getValue("BA0_FAX2")) 
    oJsonControl:setProp(oJson,"fax03",self:getValue("BA0_FAX3")) 
    oJsonControl:setProp(oJson,"headquarterOrBranch",self:getValue("BA0_MATFIL")) 
    oJsonControl:setProp(oJson,"operModality",self:getValue("BA0_MODOPE")) 
    oJsonControl:setProp(oJson,"supplierCode",self:getValue("BA0_CODFOR")) 
    oJsonControl:setProp(oJson,"unit",self:getValue("BA0_LOJA")) 
    oJsonControl:setProp(oJson,"reinmbTable",self:getValue("BA0_TBRFRE")) 
    oJsonControl:setProp(oJson,"rdaPaymTable",self:getValue("BA0_CODTAB")) 
    oJsonControl:setProp(oJson,"customerCode",self:getValue("BA0_CODCLI")) 
    oJsonControl:setProp(oJson,"customerUnit",self:getValue("BA0_LOJCLI")) 
    oJsonControl:setProp(oJson,"finClssCode",self:getValue("BA0_NATURE")) 
    oJsonControl:setProp(oJson,"relationship",self:getValue("BA0_TIPOPE")) 
    oJsonControl:setProp(oJson,"rdmakeExpFImpExp",self:getValue("BA0_EXPIDE")) 
    oJsonControl:setProp(oJson,"userIdentName",self:getValue("BA0_NOMCAR")) 
    oJsonControl:setProp(oJson,"slip2NdCopyValue",self:getValue("BA0_VL2BOL")) 
    oJsonControl:setProp(oJson,"oprCostStd",self:getValue("BA0_VLCSOP")) 
    oJsonControl:setProp(oJson,"dueDate",self:getValue("BA0_VENCTO")) 
    oJsonControl:setProp(oJson,"typeOfDueDate",self:getValue("BA0_TIPVEN")) 
    oJsonControl:setProp(oJson,"oprCostDueDate",self:getValue("BA0_VENCUS")) 
    oJsonControl:setProp(oJson,"tpOpCostDueDate",self:getValue("BA0_TIPCUS")) 
    oJsonControl:setProp(oJson,"ediSendVersion",self:getValue("BA0_ENVPTU")) 
    oJsonControl:setProp(oJson,"ediRecVersion",self:getValue("BA0_RECPTU")) 
    oJsonControl:setProp(oJson,"ediEMail",self:getValue("BA0_EMAPTU")) 
    oJsonControl:setProp(oJson,"personRespEdi",self:getValue("BA0_RESPTU")) 
    oJsonControl:setProp(oJson,"rdaCode",self:getValue("BA0_CODRDA")) 
    oJsonControl:setProp(oJson,"onLineOperCia",self:getValue("BA0_ONLINE")) 
    oJsonControl:setProp(oJson,"retroacLimitDay",self:getValue("BA0_DIARET")) 
    oJsonControl:setProp(oJson,"seqControlA100",self:getValue("BA0_A100")) 
    oJsonControl:setProp(oJson,"seqControlA300",self:getValue("BA0_A300")) 
    oJsonControl:setProp(oJson,"seqControlA600",self:getValue("BA0_A600")) 
    oJsonControl:setProp(oJson,"seqControlA700",self:getValue("BA0_A700")) 
    oJsonControl:setProp(oJson,"interAuthLimit",self:getValue("BA0_LIMCH")) 
    oJsonControl:setProp(oJson,"typeOfAuthLimit",self:getValue("BA0_TIPLIM")) 
    oJsonControl:setProp(oJson,"validLevel",self:getValue("BA0_NIVVAL")) 
    oJsonControl:setProp(oJson,"gnt",self:getValue("BA0_GNT")) 
    oJsonControl:setProp(oJson,"blockConfinement",self:getValue("BA0_BLOINO")) 
    oJsonControl:setProp(oJson,"paymentMode",self:getValue("BA0_TIPPAG")) 
    oJsonControl:setProp(oJson,"customerBank",self:getValue("BA0_BCOCLI")) 
    oJsonControl:setProp(oJson,"customerBranch",self:getValue("BA0_AGECLI")) 
    oJsonControl:setProp(oJson,"customerAccount",self:getValue("BA0_CTACLI")) 
    oJsonControl:setProp(oJson,"bankOfCarrier",self:getValue("BA0_PORTAD")) 
    oJsonControl:setProp(oJson,"branchOfCarrier",self:getValue("BA0_AGEDEP")) 
    oJsonControl:setProp(oJson,"accountOfCarrier",self:getValue("BA0_CTACOR")) 
    oJsonControl:setProp(oJson,"sourceCompany",self:getValue("BA0_EMPORI")) 
    oJsonControl:setProp(oJson,"baseForCopartnership",self:getValue("BA0_BASCOP")) 
    oJsonControl:setProp(oJson,"scope",self:getValue("BA0_ABRANG")) 
    oJsonControl:setProp(oJson,"ddd",self:getValue("BA0_DDD")) 
    oJsonControl:setProp(oJson,"legalClass",self:getValue("BA0_NATJUR")) 
    oJsonControl:setProp(oJson,"modality",self:getValue("BA0_MODALI")) 
    oJsonControl:setProp(oJson,"segmentation",self:getValue("BA0_SEGMEN")) 
    oJsonControl:setProp(oJson,"area",self:getValue("BA0_CODREG")) 
    oJsonControl:setProp(oJson,"pulvActions",self:getValue("BA0_ACOPUL")) 
    oJsonControl:setProp(oJson,"totalActions",self:getValue("BA0_TOTACO")) 
    oJsonControl:setProp(oJson,"extension1",self:getValue("BA0_RAMAL1")) 
    oJsonControl:setProp(oJson,"extension2",self:getValue("BA0_RAMAL2")) 
    oJsonControl:setProp(oJson,"extension3",self:getValue("BA0_RAMAL3")) 
    oJsonControl:setProp(oJson,"genPswrdForChemoAtchm",self:getValue("BA0_SENQUI")) 
    oJsonControl:setProp(oJson,"disallowanceRecMax",self:getValue("BA0_MAXRG")) 
    oJsonControl:setProp(oJson,"genPswrdForRadtnAtach",self:getValue("BA0_SENRAD")) 
    oJsonControl:setProp(oJson,"tpOperadoraEdi",self:getValue("BA0_TPOPED")) 
    oJsonControl:setProp(oJson,"tissVersion",self:getValue("BA0_TISVER")) 
    oJsonControl:setProp(oJson,"genPswrdForOpmeAttach",self:getValue("BA0_SENOPM")) 
    oJsonControl:setProp(oJson,"disallowanceResTerm",self:getValue("BA0_PRZREC")) 
    oJsonControl:setProp(oJson,"exchangePaymentTerm",self:getValue("BA0_TPPAG")) 
    oJsonControl:setProp(oJson,"disallowTermResource",self:getValue("BA0_CRIPRZ")) 
    oJsonControl:setProp(oJson,"termDisallowTable",self:getValue("BA0_TABPRZ")) 
    oJsonControl:setProp(oJson,"disallowForResorLim",self:getValue("BA0_CRILIM")) 
    oJsonControl:setProp(oJson,"limitDisallowTable",self:getValue("BA0_TABLIM")) 
    oJsonControl:setProp(oJson,"operatorSelfmanaged",self:getValue("BA0_AUTGES")) 
    oJsonControl:setProp(oJson,"requestClinicalAttachm",self:getValue("BA0_DIGANE")) 
    oJsonControl:setProp(oJson,"displayedValue",self:getValue("BA0_VLRAPR")) 
    oJsonControl:setProp(oJson,"endpointAuditAuthori",self:getValue("BA0_ENDPOI")) 

Return oJson

Method destroy() Class PLSBa0
	_Super:destroy()
	DelClassIntF()
return