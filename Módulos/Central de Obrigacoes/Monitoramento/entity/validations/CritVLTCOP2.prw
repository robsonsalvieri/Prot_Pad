#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTCOP2
Descricao: 	Critica referente ao Campo.
				-> BVQ_VLTCOP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTCOP2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritVLTCOP2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M091')
	self:setMsgCrit('O valor total da coparticipação inválido.')
	self:setSolCrit('')
	self:setCpoCrit('BVQ_VLTCOP')
	self:setCodAns('')
Return Self

Method Validar() Class CritVLTCOP2
	Local lRet 		:= .T.
	Local oColBVT	:= nil

	If self:oEntity:getValue("coPaymentTotalValue") < 0
		lRet := .F.
		self:setCodANS('5034')
		self:setSolCrit('O valor total da coparticipação deve ser maior ou igual a zero.')
	Else
		If AllTrim(self:oEntity:getValue("monitoringRecordType")) == '1' // Inclusao 
			oColBVT	:= CenCltBVT():New()
			oColBVT:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBVT:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBVT:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBVT:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBVT:setValue("providerFormNumber",self:oEntity:getValue("providerFormNumber"))

			If oColBVT:bscTotCop() != self:oEntity:getValue("coPaymentTotalValue")
				lRet := .F.
				self:setCodANS('1706')
				self:setSolCrit('O valor total de Coparticipação deve ser igual a soma do valor fornecido dos procedimentos/itens assistenciais.')
			EndIf 
			oColBVT:destroy()
			FreeObj(oColBVT)
			oColBVT := nil
		EndIf
	EndIf
Return lRet
