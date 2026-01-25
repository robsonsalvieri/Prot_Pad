#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDATPROC
Descricao: 	Critica referente ao Campo.
				-> BVZ_DTPROC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDATPROC From CritGrpBVZ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDATPROC
	_Super:New()
	self:setCodCrit('M099')
	self:setMsgCrit('O campo de Data do processamento é inválido.')
	self:setSolCrit('O Campo data do processamento deve ser menor que a data atual.')
	self:setCpoCrit('BVZ_DTPROC')
	self:setCodAns('1323')
Return Self

Method getWhereCrit() Class CritDATPROC
	Local cQuery := ""
	cQuery += " 	AND BVZ_DTPROC > '" + DToS(Date()) + "' "
Return cQuery