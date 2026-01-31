#include "TOTVS.CH"
#include "PLSMGER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PlHatBenef
Classe utilizada para buscar um beneficiário e todas entidades relacionadas
necessárias para o HAT. Quando o HAT não encontrar o beneficiário na base,
vai chamar o Endpoint que chama essa classe para buscar o beneficiário
@author  karine.limp
@since   09/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class PlHatBenef

    data cMatCpf
    data oJson
    data lSuccess

	Method New(cMatCpf) Constructor
	Method buscar()
    Method getQuery()

    Method buildJson()
    Method getResponse()
    
EndClass

Method New(cMatCpf) Class PlHatBenef
    self:cMatCpf := cMatCpf
    self:lSuccess := .T.
Return self

Method buscar() Class PlHatBenef

    local cQuery := self:getQuery()
    local lFound := .F.
    
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"plhatbenef",.F.,.T.)

    lFound := !plhatbenef->(EOF())
        
    if lFound
        self:buildJson()
    endIf
		
    plhatbenef->(DbCloseArea())

Return lFound

Method getQuery() Class PlHatBenef
    
    local cQuery    := ""
    local cCodInt := SubStr(self:cMatCpf,01,04)
    local cCodEmp := SubStr(self:cMatCpf,05,04)
    local cMatric := SubStr(self:cMatCpf,09,06)
    local cTipReg := SubStr(self:cMatCpf,15,02)
    local cDigito := SubStr(self:cMatCpf,17,01)

    cQuery := " SELECT " 

    cQuery += " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_CONEMP, BA1_VERCON, "
    cQuery += " BA1_SUBCON, BA1_VERSUB, BA1_CPFUSR, BA1_MATVID, BA1_NOMUSR, BA1_DATNAS, BA1_DATBLO, "
    cQuery += " BA1_SEXO,   BA1_DATINC, BA1_CODPLA, BA1_VERSAO, BA1_CEPUSR, BA1_CODMUN, "
    cQuery += " BA1_DATCAR, BA1_DTVLCR, BA1_TIPUSU, BA1_MATANT, BA1_INFGCB, BA1_INFCOB, "

    cQuery += " BTS_MATVID, BTS_CPFUSR, BTS_NOMUSR, BTS_DATNAS, BTS_SEXO,  "
    cQuery += " BTS_NRCRNA, BTS_TELEFO, BTS_CEPUSR, BTS_CODMUN, BTS_EMAIL, "

    cQuery += " BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, "
    cQuery += " BA3_SUBCON, BA3_VERSUB, BA3_DATBAS, BA3_CODPLA, BA3_COBNIV, "
    cQuery += " BA3_TIPOUS, BA3_CODCLI, BA3_LOJA,   BA3_INFCOB, BA3_INFGCB, "

    cQuery += " BI3_CODINT, BI3_CODIGO, BI3_VERSAO, BI3_CODSEG, BI3_DESCRI, BI3_GRUPO, "
    cQuery += " BI3_INFCOB, BI3_INFGCB, BI3_ALLRED, BI3_ABRANG, BI3_TODOS , BI3_CODACO, "

    cQuery += " BT5_CODINT, BT5_CODIGO, BT5_NUMCON, BT5_VERSAO, BT5_DATCON, "
    cQuery += " BT5_COBNIV, BT5_CODCLI, BT5_LOJA  , BT5_NOME  , BT5_DIASIN, "

    cQuery += " BQC_CODIGO, BQC_NUMCON, BQC_VERCON, BQC_CODINT, BQC_CODEMP, BQC_SUBCON, "
    cQuery += " BQC_VERSUB, BQC_DATCON, BQC_DESCRI, BQC_COBNIV, BQC_CODCLI, BQC_LOJA, "

    cQuery += " BT6_CODINT, BT6_CODIGO, BT6_NUMCON, BT6_VERCON, BT6_SUBCON, BT6_VERSUB, "
    cQuery += " BT6_CODPRO, BT6_VERSAO, BT6_CODSEG, BT6_INFCOB, BT6_INFGRC, BT6_ALLCRE "

    cQuery += " FROM " + RetSqlName("BA1") + " BA1 "

    cQuery += " INNER JOIN " + RetSqlName("BTS") + " BTS ON ( "
    cQuery += "         BTS_FILIAL = '" + xFilial("BTS") + "' "
    cQuery += "     AND BTS_MATVID = BA1_MATVID "
    cQuery += "     AND BTS.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BTS

    cQuery += " INNER JOIN " + RetSqlName("BA3") + " BA3 ON ( "
    cQuery += "         BA3_FILIAL = '" + xFilial("BA3") + "' "
    cQuery += "     AND BA3_CODINT = BA1_CODINT "
    cQuery += "     AND BA3_CODEMP = BA1_CODEMP "
    cQuery += "     AND BA3_MATRIC = BA1_MATRIC "
    cQuery += "     AND BA3.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BA3

    cQuery += " INNER JOIN " + RetSqlName("BI3") + " BI3 ON ( "
    cQuery += "         BI3_FILIAL  = '" + xFilial("BI3") + "' "
    cQuery += "     AND BI3_CODINT = BA1_CODINT "
    cQuery += "     AND BI3_CODIGO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_CODPLA ELSE BA3_CODPLA END "
    cQuery += "     AND BI3_VERSAO = CASE WHEN BA1_CODPLA <> ' ' THEN BA1_VERSAO ELSE BA3_VERSAO END "
    cQuery += "     AND BI3.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BI3

    cQuery += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON ( "
    cQuery += "         BT5_FILIAL  = '" + xFilial("BT5") + "' "
    cQuery += "     AND BT5_CODINT = BA1_CODINT "
    cQuery += "     AND BT5_CODIGO = BA1_CODEMP "
    cQuery += "     AND BT5_NUMCON = BA1_CONEMP "
    cQuery += "     AND BT5_VERSAO = BA1_VERCON "
    cQuery += "     AND BT5.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BT5 

    cQuery += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON ( "
    cQuery += "         BQC_FILIAL  = '" + xFilial("BQC") + "' "
    cQuery += "     AND BQC_CODIGO = BA1_CODINT || BA1_CODEMP "
    cQuery += "     AND BQC_NUMCON = BA1_CONEMP "
    cQuery += "     AND BQC_VERCON = BA1_VERCON "
    cQuery += "     AND BQC_SUBCON = BA1_SUBCON "
    cQuery += "     AND BQC_VERSUB = BA1_VERSUB "
    cQuery += "     AND BQC.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BQC

    cQuery += " LEFT JOIN " + RetSqlName("BT6") + " BT6 ON ( "
    cQuery += "         BT6_FILIAL = '" + xFilial("BT6") + "' "
    cQuery += "     AND BT6_CODINT = BQC_CODINT "
    cQuery += "     AND BT6_CODIGO = BA1_CODEMP "
    cQuery += "     AND BT6_NUMCON = BQC_NUMCON "
    cQuery += "     AND BT6_VERCON = BQC_VERCON "
    cQuery += "     AND BT6_SUBCON = BQC_SUBCON "
    cQuery += "     AND BT6_VERSUB = BQC_VERSUB "
    cQuery += "     AND BT6_CODPRO = BI3_CODIGO "
    cQuery += "     AND BT6_VERSAO = BI3_VERSAO "
    cQuery += "     AND BT6.D_E_L_E_T_ = ' ' "
    cQuery += " ) " // -- INDICE 1 BT6

    cQuery += " WHERE "

    cQuery += " BA1_FILIAL = '" + xFilial("BA1") + "' "
    cQuery += " AND ((BA1_CODINT = '" + cCodInt + "' "
    cQuery += " AND BA1_CODEMP = '" + cCodEmp + "' "
    cQuery += " AND BA1_MATRIC = '" + cMatric + "' "
    cQuery += " AND BA1_TIPREG = '" + cTipReg + "' "
    cQuery += " AND BA1_DIGITO = '" + cDigito + "')"
    cQuery += " OR  BA1_CPFUSR = '" + self:cMatCpf + "' "
    cQuery += " OR  BA1_MATANT = '" + self:cMatCpf + "') "
    cQuery += " AND BA1.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    
return cQuery

Method buildJson() Class PlHatBenef
    
    self:oJson := JsonObject():New()
    
    self:oJson["subscriberId"] := alltrim(plhatbenef->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
    self:oJson["contractNumber"] := alltrim(plhatbenef->BA1_CONEMP)
    self:oJson["contractVersion"] := alltrim(plhatbenef->BA1_VERCON)
    self:oJson["subcontractNumber"] := alltrim(plhatbenef->BA1_SUBCON)
    self:oJson["subcontractVersion"] := alltrim(plhatbenef->BA1_VERSUB)
    self:oJson["holderCpf"] := alltrim(plhatbenef->BA1_CPFUSR)
    self:oJson["personId"] := alltrim(plhatbenef->BA1_MATVID)
    self:oJson["name"] := alltrim(plhatbenef->BA1_NOMUSR)
    self:oJson["birthDate"] := alltrim(plhatbenef->BA1_DATNAS)
    self:oJson["blockedDate"] := alltrim(plhatbenef->BA1_DATBLO)
    self:oJson["gender"] := alltrim(plhatbenef->BA1_SEXO)
    self:oJson["effectiveDate"] := alltrim(plhatbenef->BA1_DATINC)
    self:oJson["healthInsuranceCode"] := alltrim(plhatbenef->BA1_CODPLA)
    self:oJson["healthInsuranceVersion"] := alltrim(plhatbenef->BA1_VERSAO)
    self:oJson["zipCode"] := alltrim(plhatbenef->BA1_CEPUSR)
    self:oJson["cityCode"] := alltrim(plhatbenef->BA1_CODMUN)
    self:oJson["waitingPeriodDate"] := alltrim(plhatbenef->BA1_DATCAR)
    self:oJson["cardExpiration"] := alltrim(plhatbenef->BA1_DTVLCR)
    self:oJson["holderRelationship"] := alltrim(plhatbenef->BA1_TIPUSU)
    self:oJson["oldSubscriberId"] := alltrim(plhatbenef->BA1_MATANT)
    self:oJson["enableCoverageGroup"] := alltrim(plhatbenef->BA1_INFGCB)
    self:oJson["enableCoverage"] := alltrim(plhatbenef->BA1_INFCOB)
    
    self:oJson["person"] := JsonObject():New()
    self:oJson["person"]["personId"] := alltrim(plhatbenef->BTS_MATVID)
    self:oJson["person"]["holderCpf"] := alltrim(plhatbenef->BTS_CPFUSR)
    self:oJson["person"]["name"] := alltrim(plhatbenef->BTS_NOMUSR)
    self:oJson["person"]["birthDate"] := alltrim(plhatbenef->BTS_DATNAS)
    self:oJson["person"]["gender"] := alltrim(plhatbenef->BTS_SEXO)
    self:oJson["person"]["nationalHealthCard"] := alltrim(plhatbenef->BTS_NRCRNA)
    self:oJson["person"]["phoneNumber"] := alltrim(plhatbenef->BTS_TELEFO)
    self:oJson["person"]["zipCode"] := alltrim(plhatbenef->BTS_CEPUSR)
    self:oJson["person"]["cityCode"] := alltrim(plhatbenef->BTS_CODMUN)
    self:oJson["person"]["email"] := alltrim(plhatbenef->BTS_EMAIL)

    self:oJson["family"] := JsonObject():New()
    self:oJson["family"]["healthInsuranceProvider"] := alltrim(plhatbenef->BA3_CODINT)
    self:oJson["family"]["companyId"] := alltrim(plhatbenef->BA3_CODEMP)
    self:oJson["family"]["familyCode"] := alltrim(plhatbenef->BA3_MATRIC)
    self:oJson["family"]["contractNumber"] := alltrim(plhatbenef->BA3_CONEMP)
    self:oJson["family"]["contractVersion"] := alltrim(plhatbenef->BA3_VERCON)
    self:oJson["family"]["subcontractNumber"] := alltrim(plhatbenef->BA3_SUBCON)
    self:oJson["family"]["subcontractVersion"] := alltrim(plhatbenef->BA3_VERSUB)
    self:oJson["family"]["effectiveDate"] := alltrim(plhatbenef->BA3_DATBAS)
    self:oJson["family"]["healthInsuranceCode"] := alltrim(plhatbenef->BA3_CODPLA)
    self:oJson["family"]["billingLevel"] := alltrim(plhatbenef->BA3_COBNIV)
    self:oJson["family"]["contractType"] := alltrim(plhatbenef->BA3_TIPOUS)
    self:oJson["family"]["clientCode"] := alltrim(plhatbenef->BA3_CODCLI)
    self:oJson["family"]["storeCode"] := alltrim(plhatbenef->BA3_LOJA)
    self:oJson["family"]["enableCoverage"] := alltrim(plhatbenef->BA3_INFCOB)
    self:oJson["family"]["enableCoverageGroup"] := alltrim(plhatbenef->BA3_INFGCB)
    
    self:oJson["product"] := JsonObject():New()
    self:oJson["product"]["healthInsuranceProvider"] := alltrim(plhatbenef->BI3_CODINT)
    self:oJson["product"]["healthInsuranceCode"] := alltrim(plhatbenef->BI3_CODIGO)
    self:oJson["product"]["healthInsuranceVersion"] := alltrim(plhatbenef->BI3_VERSAO)
    self:oJson["product"]["segmentation"] := alltrim(plhatbenef->BI3_CODSEG)
    self:oJson["product"]["description"] := alltrim(plhatbenef->BI3_DESCRI)
    self:oJson["product"]["group"] := alltrim(plhatbenef->BI3_GRUPO)
    self:oJson["product"]["enableCoverage"] := alltrim(plhatbenef->BI3_INFCOB)
    self:oJson["product"]["enableCoverageGroup"] :=alltrim(plhatbenef->BI3_INFGCB)
    self:oJson["product"]["allHealthProviders"] := alltrim(plhatbenef->BI3_ALLRED)
    self:oJson["product"]["coverage"] := alltrim(plhatbenef->BI3_ABRANG)
    self:oJson["product"]["standardTable"] := alltrim(plhatbenef->BI3_TODOS)
    self:oJson["product"]["roomType"] := alltrim(plhatbenef->BI3_CODACO)
    
    if !empty(alltrim(plhatbenef->BT5_CODIGO))

        self:oJson["contract"] := JsonObject():New()
        self:oJson["contract"]["healthInsuranceProvider"] := alltrim(plhatbenef->BT5_CODINT)
        self:oJson["contract"]["id"] := alltrim(plhatbenef->BT5_CODIGO)
        self:oJson["contract"]["number"] := alltrim(plhatbenef->BT5_NUMCON)
        self:oJson["contract"]["version"] := alltrim(plhatbenef->BT5_VERSAO)
        self:oJson["contract"]["date"] := alltrim(plhatbenef->BT5_DATCON)
        self:oJson["contract"]["billingLevel"] := alltrim(plhatbenef->BT5_COBNIV)
        self:oJson["contract"]["clientCode"] := alltrim(plhatbenef->BT5_CODCLI)
        self:oJson["contract"]["storeCode"] := alltrim(plhatbenef->BT5_LOJA)
        self:oJson["contract"]["name"] := alltrim(plhatbenef->BT5_NOME)
        self:oJson["contract"]["nonPaymentTolerance"] := plhatbenef->BT5_DIASIN

        self:oJson["contract"]["subContract"] := JsonObject():New()
        self:oJson["contract"]["subContract"]["id"] := alltrim(plhatbenef->BQC_CODIGO)
        self:oJson["contract"]["subContract"]["contractNumber"] := alltrim(plhatbenef->BQC_NUMCON)
        self:oJson["contract"]["subContract"]["contractVersion"] := alltrim(plhatbenef->BQC_VERCON)
        self:oJson["contract"]["subContract"]["healthInsuranceProvider"] := alltrim(plhatbenef->BQC_CODINT)
        self:oJson["contract"]["subContract"]["companyId"] := alltrim(plhatbenef->BQC_CODEMP)
        self:oJson["contract"]["subContract"]["number"] := alltrim(plhatbenef->BQC_SUBCON)
        self:oJson["contract"]["subContract"]["version"] := alltrim(plhatbenef->BQC_VERSUB)
        self:oJson["contract"]["subContract"]["date"] := alltrim(plhatbenef->BQC_DATCON)
        self:oJson["contract"]["subContract"]["description"] := alltrim(plhatbenef->BQC_DESCRI)
        self:oJson["contract"]["subContract"]["chargeLevel"] := alltrim(plhatbenef->BQC_COBNIV)
        self:oJson["contract"]["subContract"]["clientCode"] := alltrim(plhatbenef->BQC_CODCLI)
        self:oJson["contract"]["subContract"]["storeCode"] := alltrim(plhatbenef->BQC_LOJA)
        
        self:oJson["contract"]["productContract"] := JsonObject():New()
        self:oJson["contract"]["productContract"]["healthInsuranceProvider"] := alltrim(plhatbenef->BT6_CODINT)
        self:oJson["contract"]["productContract"]["companyId"] := alltrim(plhatbenef->BT6_CODIGO)
        self:oJson["contract"]["productContract"]["contractNumber"] := alltrim(plhatbenef->BT6_NUMCON)
        self:oJson["contract"]["productContract"]["contractVersion"] := alltrim(plhatbenef->BT6_VERCON)
        self:oJson["contract"]["productContract"]["subContractNumber"] := alltrim(plhatbenef->BT6_SUBCON)
        self:oJson["contract"]["productContract"]["subContractVersion"] := alltrim(plhatbenef->BT6_VERSUB)
        self:oJson["contract"]["productContract"]["healthInsuranceCode"] := alltrim(plhatbenef->BT6_CODPRO)
        self:oJson["contract"]["productContract"]["healthInsuranceVersion"] := alltrim(plhatbenef->BT6_VERSAO)
        self:oJson["contract"]["productContract"]["segmentation"] := alltrim(plhatbenef->BT6_CODSEG)
        self:oJson["contract"]["productContract"]["enableCoverage"] := alltrim(plhatbenef->BT6_INFCOB)
        self:oJson["contract"]["productContract"]["enableCoverageGroup"] := alltrim(plhatbenef->BT6_INFGRC)
        self:oJson["contract"]["productContract"]["allAccredited"] := alltrim(plhatbenef->BT6_ALLCRE)

    endIf

Return

Method getResponse() Class PlHatBenef
return self:oJson:toJson()