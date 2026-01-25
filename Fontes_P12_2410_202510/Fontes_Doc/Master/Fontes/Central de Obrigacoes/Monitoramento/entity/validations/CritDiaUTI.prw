#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDiaUTI
Descricao: 	Critica referente ao Campo.
				-> BKR_DIAUTI
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDiaUTI From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDiaUTI
	_Super:New()
	self:setCodCrit('M039' )
	self:setMsgCrit('O Número de diárias de UTI preenchida para uma guia inválida.')
	self:setSolCrit('O Número de diárias de UTI não deve ser preenchido para guia que não seja de Internação')
	self:setCpoCrit('BKR_DIAUTI')
	self:setCodAns('1304')
Return Self

Method getWhereCrit() Class CritDiaUTI
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT <> '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_DIAUTI <> '' "
Return cQuery


