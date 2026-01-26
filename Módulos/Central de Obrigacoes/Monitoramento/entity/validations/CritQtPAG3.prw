#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritQTPAG3
Descricao: 	Critica referente ao Campo.
				-> BKS_QTDPAG
@author José PAulo
@since 20/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritQTPAG3 From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritQTPAG3
	_Super:New()
	self:setCodCrit('M113')
	self:setMsgCrit('A Quantidade paga de procedimentos ou itens assistenciais é inválida.')
	self:setSolCrit('A Quantidade paga de procedimentos deve ser maior que zero, quando o valor pago do procedimento estiver preenchido.')
	self:setCpoCrit('BKS_QTDPAG')
	self:setCodAns('1806')
Return Self

Method getWhereCrit() Class CritQTPAG3
	Local cQuery := ""
	cQuery += " 	AND BKS_QTDPAG <= 0 AND BKS_VLPGPR > 0 "
Return cQuery