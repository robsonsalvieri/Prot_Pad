#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRIN2
Descricao: 	Critica referente ao Campo.
				-> BKS_VLRINF 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRIN2 From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRIN2
	_Super:New()
	self:setCodCrit('M064')
	self:setMsgCrit('A Valor informado de procedimentos ou itens assistenciais é inválido.')
	self:setSolCrit('Preencha corretamente o campo Valor informado de procedimentos ou itens assistenciais conforme guia enviada.')
	self:setCpoCrit('BKS_VLRINF')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLRIN2
	Local cQuery := ""
	cQuery += " 	AND BKS_VLRINF < 0 "
Return cQuery