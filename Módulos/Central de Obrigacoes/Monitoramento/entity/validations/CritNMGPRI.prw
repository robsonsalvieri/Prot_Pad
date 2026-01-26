#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritNMGPRI
Descricao: 	Critica referente ao Campo.
				-> BKR_NMGPRI 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritNMGPRI From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritNMGPRI
	_Super:New()
	self:setCodCrit('M053' )
	self:setMsgCrit('O Número da guia principal de SP/SADT ou de Tratamento Odontológico é inválido.')
	self:setSolCrit('Preencha corretamente o campo Número da guia principal de SP/SADT ou de Tratamento Odontológico.')
	self:setCpoCrit('BKR_NMGPRI')
	self:setCodAns('1307')
Return Self

Method getWhereCrit() Class CritNMGPRI
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='2') OR (BKR_TPEVAT='4') ) "
	cQuery += " 	AND ( ( ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) AND BKR_NMGPRI = '' ) "
	cQuery += " 		OR ( BKR_OREVAT = '4' AND BKR_NMGPRI <> '000000000000000000' ) ) "	
Return cQuery