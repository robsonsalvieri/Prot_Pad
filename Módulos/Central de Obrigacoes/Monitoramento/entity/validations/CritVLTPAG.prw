#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTPAG
Descricao: 	Critica referente ao Campo.
				-> BVZ_VLTPAG
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTPAG From CritGrpBVZ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLTPAG
	_Super:New()
	self:setCodCrit('M106')
	self:setMsgCrit('O campo Valor total pago ao recebedor na competência é inválido.')
	self:setSolCrit('O valor total pago na competência deve ser maior ou igual a zero.')
	self:setCpoCrit('BVZ_VLTPAG')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLTPAG
	Local cQuery := ""
	cQuery += " 	AND BVZ_VLTPAG < 0 "
Return cQuery