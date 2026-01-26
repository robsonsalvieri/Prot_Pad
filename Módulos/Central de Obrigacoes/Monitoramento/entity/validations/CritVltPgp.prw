/*

#Include "Totvs.ch"

Class CritVltPgp From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltPgp
	_Super:New()
	self:setCodCrit('M043')
	self:setMsgCrit('O Valor Total Pago nos Procedimentos realizados na Guia é inválido.')
	self:setSolCrit('O Valor Total Pago nos Procedimentos realizados na Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração.')
	self:setCpoCrit('BKR_VLTPGP')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltPgp
	Local cQuery := ""
	cQuery += " 	AND BKR_TPRGMN = '1' "
	cQuery += " 	AND BKR_VLTPGP < 0 "
Return cQuery


*/
