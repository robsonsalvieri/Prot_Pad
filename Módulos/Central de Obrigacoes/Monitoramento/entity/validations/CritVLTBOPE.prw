#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTBOPE
Descricao: 	Critica referente ao Campo.
				-> BVQ_VLTTBP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTBOPE From CritGrpBVQ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLTBOPE
	_Super:New()
	self:setCodCrit('M088' )
	self:setMsgCrit('Valor total da tabela propria é inválido.')
	self:setSolCrit('Preencha o campo Valor total da tabela propria com um valor maior ou igual a zero.')
	self:setCpoCrit('BVQ_VLTTBP')
	self:setCodANS('5034')
Return Self

Method getWhereCrit() Class CritVLTBOPE
	Local cQuery := ""
	cQuery += " 	AND BVQ_VLTTBP < 0 "
Return cQuery