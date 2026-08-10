#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltCOP
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTCOP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltCOP From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritVltCOP
	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M051')
	self:setMsgCrit('O Valor total de co-participação é inválido.')
	self:setSolCrit('')
	self:setCpoCrit('BKR_VLTCOP')
	self:setCodAns('')
Return Self

Method Validar() Class CritVltCOP
	Local lRet 		:= .T.
	Local oColBKS	:= nil

	If self:oEntity:getValue("coPaymentTotalValue") < 0
		lRet := .F.
		self:setCodANS('5034')
		self:setSolCrit('O Valor total de co-participação da Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração.')
	Else
		If AllTrim(self:oEntity:getValue("aEventType")) $ '1,2,4'
			oColBKS	:= CenCltBKS():New()
			oColBKS:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBKS:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBKS:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBKS:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBKS:setValue("operatorFormNumber",self:oEntity:getValue("operatorFormNumber"))
			oColBKS:setValue("batchCode",self:oEntity:getValue("batchCode"))
			oColBKS:setValue("formProcDt",self:oEntity:getValue("formProcDt"))

			If oColBKS:bscTotCop() != self:oEntity:getValue("coPaymentTotalValue")
				lRet := .F.
				self:setCodANS('5050')
				self:setSolCrit('O Valor total de co-participação da Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração.')
			EndIf 
			oColBKS:destroy()
			FreeObj(oColBKS)
			oColBKS := nil
		EndIf
	EndIf
Return lRet
 