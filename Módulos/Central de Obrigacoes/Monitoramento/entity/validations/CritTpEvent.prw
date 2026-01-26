#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTpEvent
Descricao: 	Critica referente ao Campo Id Prestador Executante
				-> BKR_IDEEXC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTpEvent From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTpEvent
	_Super:New()
	self:setCodCrit('M009')
	self:setMsgCrit('Indicador Inválido no Campo de Tipo da Guia.')
	self:setSolCrit('Corrija o conteúdo do campo Tip da Guia.' )
	self:setCpoCrit('BKR_TPEVAT')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritTpEvent
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT<>'1') "
	cQuery += " 	AND (BKR_TPEVAT<>'2') "
	cQuery += " 	AND (BKR_TPEVAT<>'3') "
	cQuery += " 	AND (BKR_TPEVAT<>'4') "
	cQuery += " 	AND (BKR_TPEVAT<>'5') ) "
Return cQuery

