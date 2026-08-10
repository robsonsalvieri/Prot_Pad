#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLPGPR2
Descricao: 	Critica referente ao Campo.
				-> BVT_VLPGPR
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLPGPR2 From CritGrpBVT
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLPGPR2
	_Super:New()
	self:setCodCrit('M096')
	self:setMsgCrit('O campo Valor do item assistencial fornecido é inválido.')
	self:setSolCrit('A Valor do item assistencial fornecido deve ser maior que zero.')
	self:setCpoCrit('BVT_VLPGPR')
	self:setCodAns('5040')
Return Self

Method getWhereCrit() Class CritVLPGPR2
	Local cQuery := ""
	cQuery += " 	AND BVT_VLPGPR <= 0 "
Return cQuery