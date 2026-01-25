#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDTPRGU2
Descricao: 	Critica referente ao Campo.
				-> BVT_DTPRGU
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDTPRGU2 From CritGrpBVT
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDTPRGU2
	_Super:New()
	self:setCodCrit('M089')
	self:setMsgCrit('O campo Data de fornecimento dos itens assistenciais é inválido.')
	self:setSolCrit('O foi preenchida incorretamente. Corrija o problema a data de Fornecimento que seja menor que a data atual.')
	self:setCpoCrit('BVT_DTPRGU')
	self:setCodAns('1323')
Return Self

Method getWhereCrit() Class CritDTPRGU2
	Local cQuery := ""
	cQuery += " 	AND ( BVT_DTPRGU > '" + DToS(Date()) + "' OR BVT_DTPRGU = ' ' )     "
Return cQuery
