#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritQTDINF2
Descricao: 	Critica referente ao Campo.
				-> BVT_QTDINF
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritQTDINF2 From CritGrpBVT
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritQTDINF2
	_Super:New()
	self:setCodCrit('M095')
	self:setMsgCrit('O campo Quantidade do item assistencial fornecido ao beneficiário é inválido.')
	self:setSolCrit('A quantidade de itens fornecidos deve ser maior que zero.')
	self:setCpoCrit('BVT_QTDINF')
	self:setCodAns('1806')
Return Self

Method getWhereCrit() Class CritQTDINF2
	Local cQuery := ""
	cQuery += " 	AND BVT_QTDINF <= 0 "
Return cQuery