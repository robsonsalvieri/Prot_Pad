#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritQTDINF
Descricao: 	Critica referente ao Campo.
				-> BKS_QTDINF 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritQTDINF From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritQTDINF
	_Super:New()
	self:setCodCrit('M063')
	self:setMsgCrit('A Quantidade informada de procedimentos ou itens assistenciais é inválida.')
	self:setSolCrit('Preencha corretamente o campo Quantidade informada de procedimentos ou itens assistenciais conforme guia que foi enviada.')
	self:setCpoCrit('BKS_QTDINF')
	self:setCodAns('1806')
Return Self

Method getWhereCrit() Class CritQTDINF
	Local cQuery := ""
	cQuery += " 	AND BKS_QTDINF <= 0 "
Return cQuery