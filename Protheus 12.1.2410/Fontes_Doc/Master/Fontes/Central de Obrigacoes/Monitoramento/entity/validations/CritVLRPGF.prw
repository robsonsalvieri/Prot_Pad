#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRPGF
Descricao: 	Critica referente ao Campo.
				-> BKS_VLRPGF  
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRPGF From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRPGF
	_Super:New()
	self:setCodCrit('M067')
	self:setMsgCrit('O Valor pago diretamente ao fornecedor é inválido.')
	self:setSolCrit('Preencha corretamente o campo Valor do procedimento ou item assistencial individualizado ou do grupo pago pela operadora diretamente aos fornecedores conforme guia enviada.')
	self:setCpoCrit('BKS_VLRPGF')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLRPGF
	Local cQuery := ""
	cQuery += " 	AND BKS_VLRPGF < 0 "
Return cQuery