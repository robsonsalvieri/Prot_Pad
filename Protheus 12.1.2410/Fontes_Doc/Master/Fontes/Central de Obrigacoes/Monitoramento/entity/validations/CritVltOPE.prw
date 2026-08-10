#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltOPE
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTOPM
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltOPE From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltOPE
	_Super:New()
	self:setCodCrit('M047' )
	self:setMsgCrit('O Valor total das órteses, próteses e materiais especiais selecionados (OPME) é inválido.')
	self:setSolCrit('O Valor total das órteses, próteses e materiais especiais selecionados (OPME) da Guia não pode ser um valor menor que 0 nas operações de Inclusão ou Alteração. ')
	self:setCpoCrit('BKR_VLTOPM')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltOPE
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') ) "
	cQuery += " 	AND BKR_VLTOPM < 0 "
Return cQuery