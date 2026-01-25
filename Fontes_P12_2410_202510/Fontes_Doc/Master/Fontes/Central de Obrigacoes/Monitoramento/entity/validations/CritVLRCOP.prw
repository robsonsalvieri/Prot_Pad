#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRCOP
Descricao: 	Critica referente ao Campo.
				-> BKS_VLRCOP  
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRCOP From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRCOP
	_Super:New()
	self:setCodCrit('M069')
	self:setMsgCrit('O Valor de co-participação é inválido.')
	self:setSolCrit('Preencha corretamente o campo Valor da co-participação do beneficiário referente à realização dos procedimentos conforme guia enviada.')
	self:setCpoCrit('BKS_VLRCOP')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLRCOP
	Local cQuery := ""
	cQuery += " 	AND BKS_VLRCOP < 0 "
Return cQuery
