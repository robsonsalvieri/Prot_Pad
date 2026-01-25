#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltDia
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTDIA
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltDia From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltDia
	_Super:New()
	self:setCodCrit('M044')
	self:setMsgCrit('O Valor Total Pago nas Diárias da Guia é inválido.')
	self:setSolCrit('O Valor Total Pago nas Diárias da Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração. ')
	self:setCpoCrit('BKR_VLTDIA')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltDia
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') )"
	cQuery += " 	AND BKR_VLTDIA < 0 "
Return cQuery
