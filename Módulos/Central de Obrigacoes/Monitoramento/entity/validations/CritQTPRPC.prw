#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritQTPRPC
Descricao: 	Critica referente ao Campo.
				-> BKT_QTPRPC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritQTPRPC From CritGrpBKT

	Method New() Constructor
	Method getWhereCrit()

EndClass

Method New() Class CritQTPRPC
	_Super:New()
	self:setAlias('BKT')
	self:setCodCrit('M072' )
	self:setMsgCrit('O Quantidade paga de procedimentos ou itens assistenciais que compõe o pacote é inválido.')
	self:setSolCrit('Preencha corretamente o campo Quantidade do procedimento ou item assistencial que compõe o pacote pago pela operadora conforme Guia enviada.')
	self:setCpoCrit('BKT_QTPRPC')
	self:setCodAns('1806')

Return Self

Method getWhereCrit() Class CritQTPRPC
	Local cQuery := ""
	cQuery += " 	AND BKT_QTPRPC <= 0 "
Return cQuery