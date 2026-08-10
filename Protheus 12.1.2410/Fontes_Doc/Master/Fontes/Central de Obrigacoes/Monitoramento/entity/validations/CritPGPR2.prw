#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritPGPR2
Descricao: 	Critica referente ao Campo.
				-> BKS_VLPGPR 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritPGPR2 From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritPGPR2
	_Super:New()
	self:setCodCrit('M066' )
	self:setMsgCrit('O Valor pago do procedimento é inválido.')
	self:setSolCrit('Valor pago do procedimento não pode ser negativo e deve ser maior que zero quando a quantidade paga for informada.')
	self:setCpoCrit('BKS_VLPGPR')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritPGPR2
	Local cQuery := ""
	cQuery += " AND BKS_QTDPAG > 0 AND BKS_VLPGPR = 0 "
Return cQuery