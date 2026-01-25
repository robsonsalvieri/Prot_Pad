#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritQTPAG2
Descricao: 	Critica referente ao Campo.
				-> BKS_QTDPAG
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritQTPAG2 From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritQTPAG2
	_Super:New()
	self:setCodCrit('M065')
	self:setMsgCrit('A Quantidade paga de procedimentos ou itens assistenciais é inválida.')
	self:setSolCrit('Preencha corretamente o campo Quantidade paga de procedimentos ou itens assistenciais conforme guia enviada.')
	self:setCpoCrit('BKS_QTDPAG')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritQTPAG2
	Local cQuery := ""
	cQuery += " 	AND BKS_QTDPAG < 0 "
Return cQuery