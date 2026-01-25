#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltGLO
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTGLO
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltGLO From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltGLO
	_Super:New()
	self:setCodCrit('M048')
	self:setMsgCrit('O Valor total medicamentos é inválido.')
	self:setSolCrit('O Valor total medicamentos da Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração. ')
	self:setCpoCrit('BKR_VLTGLO')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltGLO
	Local cQuery := ""
	cQuery += " 	AND BKR_VLTGLO < 0 "
Return cQuery


