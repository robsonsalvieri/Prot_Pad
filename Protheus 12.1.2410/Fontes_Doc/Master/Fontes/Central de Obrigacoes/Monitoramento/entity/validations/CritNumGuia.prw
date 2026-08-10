#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritNumGuia
Descricao: 	Critica referente ao Campo.
				-> BKR_NMGPRE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritNumGuia From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritNumGuia
	_Super:New()
	self:setCodCrit('M007' )
	self:setMsgCrit('Numero da Guia do Prestador Inválido.')
	self:setSolCrit('Campo deve ser preenchido quando a origem da guia for igual a: 1-Rede Contratada/2-Rede Própria-Cooperados/3-Rede Própria-Demais Prestadores.')
	self:setCpoCrit('BKR_NMGPRE')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritNumGuia
	Local cQuery := ""
	cQuery += " 	AND ( ( ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) AND BKR_NMGPRE = '' ) "
	cQuery += " 		OR ( BKR_OREVAT = '4' AND BKR_NMGPRE <> '00000000000000000000' ) ) "
Return cQuery
