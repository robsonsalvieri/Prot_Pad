#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBi3 - Health Products
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBi3 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBi3
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBi3

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"allRda",self:getValue("BI3_ALLRED")) 
    oJsonControl:setProp(oJson,"allAccredited",self:getValue("BI3_ALLCRE")) 
    oJsonControl:setProp(oJson,"allUsers",self:getValue("BI3_ALLUSR")) 
    oJsonControl:setProp(oJson,"version",self:getValue("BI3_VERSAO")) 
    oJsonControl:setProp(oJson,"operator",self:getValue("BI3_CODINT")) 
    oJsonControl:setProp(oJson,"productCode",self:getValue("BI3_CODIGO")) 
    oJsonControl:setProp(oJson,"productDescription",self:getValue("BI3_DESCRI")) 
    oJsonControl:setProp(oJson,"summarDescript",self:getValue("BI3_NREDUZ")) 
    oJsonControl:setProp(oJson,"productGroup",self:getValue("BI3_GRUPO")) 
    oJsonControl:setProp(oJson,"planOwner",self:getValue("BI3_TIPPLA")) 
    oJsonControl:setProp(oJson,"planType",self:getValue("BI3_TIPO")) 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("BI3_DATINC")) 
    oJsonControl:setProp(oJson,"oldCode",self:getValue("BI3_CODANT")) 
    oJsonControl:setProp(oJson,"planStatus",self:getValue("BI3_STATUS")) 
    oJsonControl:setProp(oJson,"blockDate",self:getValue("BI3_DATBLO")) 
    oJsonControl:setProp(oJson,"cardDescription",self:getValue("BI3_DESCAR")) 
    oJsonControl:setProp(oJson,"dailyInterest",self:getValue("BI3_TAXDIA")) 
    oJsonControl:setProp(oJson,"chargeInterestSameMont",self:getValue("BI3_COBJUR")) 
    oJsonControl:setProp(oJson,"dailyInterestValue",self:getValue("BI3_JURDIA")) 
    oJsonControl:setProp(oJson,"class",self:getValue("BI3_NATURE")) 
    oJsonControl:setProp(oJson,"billType",self:getValue("BI3_TIPTIT")) 
    oJsonControl:setProp(oJson,"calcProRataCollection",self:getValue("BI3_COBRAT")) 
    oJsonControl:setProp(oJson,"pRataExitFMajority",self:getValue("BI3_RATMAI")) 
    oJsonControl:setProp(oJson,"considerProcStandard",self:getValue("BI3_TODOS")) 
    oJsonControl:setProp(oJson,"chargeProRataOnOutflo",self:getValue("BI3_RATSAI")) 
    oJsonControl:setProp(oJson,"ansRegistrationNumber",self:getValue("BI3_SUSEP")) 
    oJsonControl:setProp(oJson,"segment",self:getValue("BI3_CODSEG")) 
    oJsonControl:setProp(oJson,"paymentMode",self:getValue("BI3_MODPAG")) 
    oJsonControl:setProp(oJson,"ruled",self:getValue("BI3_APOSRG")) 
    oJsonControl:setProp(oJson,"accommodationCode",self:getValue("BI3_CODACO")) 
    oJsonControl:setProp(oJson,"coParticipation",self:getValue("BI3_CPFM")) 
    oJsonControl:setProp(oJson,"scope",self:getValue("BI3_ABRANG")) 
    oJsonControl:setProp(oJson,"productRegistrDate",self:getValue("BI3_DTRGPR")) 
    oJsonControl:setProp(oJson,"productApprovDate",self:getValue("BI3_DTAPPR")) 
    oJsonControl:setProp(oJson,"allOperators",self:getValue("BI3_ALLOPE")) 
    oJsonControl:setProp(oJson,"contractType",self:getValue("BI3_TIPCON")) 
    oJsonControl:setProp(oJson,"changeRange",self:getValue("BI3_MUDFAI")) 
    oJsonControl:setProp(oJson,"yearMonth",self:getValue("BI3_ANOMES")) 
    oJsonControl:setProp(oJson,"informCoverage",self:getValue("BI3_INFCOB")) 
    oJsonControl:setProp(oJson,"informCoverageGroup",self:getValue("BI3_INFGCB")) 
    oJsonControl:setProp(oJson,"enterSpCovUser",self:getValue("BI3_INFCBU")) 
    oJsonControl:setProp(oJson,"adTxLimValue",self:getValue("BI3_LIMTXA")) 
    oJsonControl:setProp(oJson,"comfortStandard",self:getValue("BI3_PADSAU")) 
    oJsonControl:setProp(oJson,"contractModel",self:getValue("BI3_MODCON")) 
    oJsonControl:setProp(oJson,"valueOfDupliOfDocket",self:getValue("BI3_VL2BOL")) 
    oJsonControl:setProp(oJson,"ediCode",self:getValue("BI3_CODPTU")) 
    oJsonControl:setProp(oJson,"ledgerAccount",self:getValue("BI3_CONTA")) 
    oJsonControl:setProp(oJson,"costCenter",self:getValue("BI3_CC")) 
    oJsonControl:setProp(oJson,"contractLegalClass",self:getValue("BI3_NATJCO")) 
    oJsonControl:setProp(oJson,"identCrMagneticStrip",self:getValue("BI3_IDECAR")) 
    oJsonControl:setProp(oJson,"hspPlanCode",self:getValue("BI3_HSPPLA")) 
    oJsonControl:setProp(oJson,"accommodationMultFactor",self:getValue("BI3_FATMUL")) 
    oJsonControl:setProp(oJson,"highRiskProduct",self:getValue("BI3_RISCO")) 
    oJsonControl:setProp(oJson,"commissionGroup",self:getValue("BI3_GRUCOM")) 
    oJsonControl:setProp(oJson,"monthlyFeeDiscount",self:getValue("BI3_DESMEN")) 
    oJsonControl:setProp(oJson,"individualCollectMode",self:getValue("BI3_COBCPF")) 
    oJsonControl:setProp(oJson,"billingMethod",self:getValue("BI3_FORFAT")) 
    oJsonControl:setProp(oJson,"allowRefund",self:getValue("BI3_REEMB")) 
    oJsonControl:setProp(oJson,"erpProductCode",self:getValue("BI3_CODSB1")) 
    oJsonControl:setProp(oJson,"invoiceOutflowType",self:getValue("BI3_CODTES")) 
    oJsonControl:setProp(oJson,"scpaCode",self:getValue("BI3_SCPA")) 
    oJsonControl:setProp(oJson,"showInPortal",self:getValue("BI3_PORTAL")) 
    oJsonControl:setProp(oJson,"numberOfUs",self:getValue("BI3_QTDUS")) 
    oJsonControl:setProp(oJson,"ediServiceNetwork",self:getValue("BI3_REDEDI")) 
    oJsonControl:setProp(oJson,"period",self:getValue("BI3_QTDPUS")) 
    oJsonControl:setProp(oJson,"unit",self:getValue("BI3_UNIPUS")) 
    oJsonControl:setProp(oJson,"considerSendingToRpc",self:getValue("BI3_CONRPC")) 
    oJsonControl:setProp(oJson,"contractType",self:getValue("BI3_TPCONT")) 
    oJsonControl:setProp(oJson,"beneficiaryType",self:getValue("BI3_TPBEN")) 
    oJsonControl:setProp(oJson,"scopeInCard",self:getValue("BI3_ABRCAR")) 
    oJsonControl:setProp(oJson,"situationAtAns",self:getValue("BI3_SITANS")) 
    oJsonControl:setProp(oJson,"planClassification",self:getValue("BI3_CLAPLS")) 
    oJsonControl:setProp(oJson,"referencedNetwork",self:getValue("BI3_REDREF")) 
    oJsonControl:setProp(oJson,"medicalForm",self:getValue("BI3_GUIMED")) 
    oJsonControl:setProp(oJson,"supplierType",self:getValue("BI3_TPFORN")) 
    oJsonControl:setProp(oJson,"considerAns",self:getValue("BI3_INFANS")) 
    oJsonControl:setProp(oJson,"typeOfProductForEdi",self:getValue("BI3_TPREDI")) 
    oJsonControl:setProp(oJson,"noDaysTolerance",self:getValue("BI3_MXDRMB")) 
    oJsonControl:setProp(oJson,"minValuReimbAccum",self:getValue("BI3_VMIRMB")) 
    oJsonControl:setProp(oJson,"coParticipationTablePo",self:getValue("BI3_TABCOP")) 
    oJsonControl:setProp(oJson,"descReferencedNetwork",self:getValue("BI3_RRFDES")) 
    oJsonControl:setProp(oJson,"eduServiceLocationCode",self:getValue("BI3_LATEDI")) 
    oJsonControl:setProp(oJson,"productClassification",self:getValue("BI3_CLASSE")) 
    oJsonControl:setProp(oJson,"documentReason",self:getValue("BI3_MOTDOC")) 
    oJsonControl:setProp(oJson,"userDrugstoreTempl",self:getValue("BI3_DROGAR")) 
    oJsonControl:setProp(oJson,"netTypeA1300",self:getValue("BI3_TIPRED")) 
    oJsonControl:setProp(oJson,"individualEntrepreneur",self:getValue("BI3_EMPIND")) 

Return oJson

Method destroy() Class PLSBi3
	_Super:destroy()
	DelClassIntF()
return