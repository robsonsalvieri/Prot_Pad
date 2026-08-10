#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltGUI
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTGUI
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltGUI From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltGUI
	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M049')
	self:setMsgCrit('O Valor Total Pago ao Prestador Executante é inválido.')
	self:setSolCrit('')
	self:setCpoCrit('BKR_VLTPGP')
	self:setCodAns('5034')
Return Self
	
Method getWhereCrit() Class CritVltGUI
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') ) "
	cQuery += " 	AND ( BKR_VLTDIA+BKR_VLTPGP+BKR_VLTTAX+BKR_VLTMAT+BKR_VLTOPM+BKR_VLTMED <> BKR_VLTGUI ) "
Return cQuery

