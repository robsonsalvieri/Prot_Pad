#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritNrGuiaOp
Descricao: 	Critica referente ao Campo.
				-> BKR_NMGOPE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritNrGuiaOp From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritNrGuiaOp
	_Super:New()
	self:setCodCrit('M006' )
	self:setMsgCrit('Numero da Guia na Operadora inválido.')
	self:setSolCrit('Campo deve ser preenchido quando a origem da guia for igual a: 1-Rede Contratada/2-Rede Própria-Cooperados/3-Rede Própria-Demais Prestadores.')
	self:setCpoCrit('BKR_NMGOPE')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritNrGuiaOp
	Local cQuery := ""
	cQuery += " 	AND ( ( ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') )  AND BKR_NMGOPE = '' ) "
	cQuery += " 		OR ( BKR_OREVAT = '4' AND BKR_NMGOPE <> '00000000000000000000' ) ) "
Return cQuery