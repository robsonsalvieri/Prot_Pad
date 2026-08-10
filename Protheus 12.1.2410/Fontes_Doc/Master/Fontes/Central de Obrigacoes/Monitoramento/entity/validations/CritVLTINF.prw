#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTINF
Descricao: 	Critica referente ao Campo.
				-> BVZ_VLTINF
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTINF From CritGrpBVZ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLTINF
	_Super:New()
	self:setCodCrit('M103')
	self:setMsgCrit('O campo Valor total informado é inválido.')
	self:setSolCrit('O campo Valor total informado deve ser maior que zero.')
	self:setCpoCrit('BVZ_VLTINF')
	self:setCodAns('5040')
Return Self

Method getWhereCrit() Class CritVLTINF
	Local cQuery := ""
	cQuery += " 	AND BVZ_VLTINF <= 0 "
Return cQuery