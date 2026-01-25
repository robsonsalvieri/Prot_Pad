#INCLUDE "TOTVS.CH"

Class CritIDFORN From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritIDFORN
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M087')
	self:setMsgCrit('O Identificador da operação de fornecimento de materiais e medicamentos é inválido.')
	self:setSolCrit('O campo identificador de fornecimento direto de materiais e medicamentos deve ser preenchido e deve ser unico.')
	self:setCpoCrit('BVQ_NMGPRE')
	self:setCodAns('5053')
Return Self

Method Validar() Class CritIDFORN

	Local lRet 		:= .F.
	Local oColBVQ	:= nil

	If !Empty(AllTrim(FwCutOff((self:oEntity:getValue("providerFormNumber")))))
		oColBVQ 	:= CenCltBVQ():New()
	
		oColBVQ:setValue("operatorRecord",self:oEntity:getValue("operatorRecord")) //BVQ_CODOPE
		oColBVQ:setValue("requirementCode",self:oEntity:getValue("requirementCode")) //BVQ_CDOBRI
		oColBVQ:setValue("referenceYear",self:oEntity:getValue("referenceYear")) //BVQ_ANO
		oColBVQ:setValue("commitmentCode",self:oEntity:getValue("commitmentCode")) //BVQ_CDCOMP
		oColBVQ:setValue("monitoringRecordType",self:oEntity:getValue("monitoringRecordType")) //BVQ_TPRGMN
		oColBVQ:setValue("providerFormNumber",self:oEntity:getValue("providerFormNumber")) //BVQ_NMGPRE
		lRet := oColBVQ:getQtdNmPre() <= 1
		oColBVQ:destroy()
	EndIf

Return lRet
