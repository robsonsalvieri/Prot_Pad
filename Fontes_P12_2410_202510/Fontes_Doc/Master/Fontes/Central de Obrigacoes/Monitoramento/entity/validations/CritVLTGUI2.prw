#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTGUI2
Descricao: 	Critica referente ao Campo.
				-> BVQ_VLTGUI
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTGUI2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritVLTGUI2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M090')
	self:setMsgCrit('O valor total da pago é inválido.')
	self:setSolCrit('')
	self:setCpoCrit('BVQ_VLTGUI')
	self:setCodAns('')
Return Self

Method Validar() Class CritVLTGUI2
	Local lRet 		:= .T.
	Local oColBVT	:= nil

	If self:oEntity:getValue("valuePaidForm") < 0
		lRet := .F.
		self:setCodANS('5034')
		self:setSolCrit('O valor total da pago deve ser maior ou igual a zero.')
	Else
		
		oColBVT	:= CenCltBVT():New()
		oColBVT:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
		oColBVT:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
		oColBVT:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
		oColBVT:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
		oColBVT:setValue("providerFormNumber",self:oEntity:getValue("providerFormNumber"))

		If oColBVT:bscTotPgGui() != self:oEntity:getValue("valuePaidForm")
			lRet := .F.
			self:setCodANS('1706')
			self:setSolCrit('O valor total de pago deve ser igual a soma do valor pago dos procedimentos/itens assistenciais.')
		EndIf 
		oColBVT:destroy()
		FreeObj(oColBVT)
		oColBVT := nil
	EndIf
Return lRet
