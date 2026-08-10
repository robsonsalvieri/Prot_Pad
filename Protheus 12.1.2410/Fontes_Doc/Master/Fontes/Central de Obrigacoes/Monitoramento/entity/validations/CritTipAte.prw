#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTipAte
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPATE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTipAte From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTipAte
	_Super:New()
	self:setCodCrit('M036')
	self:setMsgCrit('Código do Tipo de Atendimento não informado.')
	self:setSolCrit('Preencha o Campo Código do tipo de atendimento conforme Tabela 50 - Terminologia de Tipo de Atendimento na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPATE')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritTipAte
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '2' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_TIPATE = '' "
Return cQuery
