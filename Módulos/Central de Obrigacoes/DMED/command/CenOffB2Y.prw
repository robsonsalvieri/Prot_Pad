#include "TOTVS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc}
Class CenOffB2Y
Classe responsável por inserir os registros na B2Y sem a necessidade de API
@author david.juan
@since 04/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Class CenOffB2Y from CenOffApi

    Data healthInsurerCode as String
    Data ssnHolder as String
    Data titleHolderEnrollment as String
    Data dependentSsn as String
    Data dependentEnrollment as String
    Data expenseKey as String
    Data period as String
    Data holderName as String
    Data dependentName as String
    Data dependentBirthDate as String
    Data dependenceRelationships as String
    Data expenseAmount as String
    Data refundAmount as String
    Data previousYearRefundAmt as String
    Data providerSsnEin as String
    Data providerName as String
    Data status as String
    Data processed as String
    Data roboId as String
    Data inclusionTime as String
    Data exclusionId as String

    Method New(cJson) Constructor
    Method getData()

EndClass

Method New(cJson) Class CenOffB2Y
    _Super:New(cJson)
Return self

Method getData() Class CenOffB2Y
    _Super:getData()
    self:healthInsurerCode := ""
    self:ssnHolder := ""
    self:titleHolderEnrollment := ""
    self:dependentSsn := ""
    self:dependentEnrollment := ""
    self:expenseKey := ""
    self:period := ""
    self:holderName := ""
    self:dependentName := ""
    self:dependentBirthDate := ""
    self:dependenceRelationships := ""
    self:expenseAmount := ""
    self:refundAmount := ""
    self:previousYearRefundAmt := ""
    self:providerSsnEin := ""
    self:providerName := ""
    self:status := ""
    self:processed := ""
    self:roboId := ""
    self:inclusionTime := ""
    self:exclusionId := ""
    self:oRequest := CenReqB2Y():New(self, "b2y-post_insert_offline")
Return