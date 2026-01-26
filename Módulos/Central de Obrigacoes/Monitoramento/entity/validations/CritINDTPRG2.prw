#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritINDTPRG22
Descricao: 	Critica referente ao Campo.
				-> BVQ_TPRGMN
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritINDTPRG2 From CritGrpBVQ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritINDTPRG2
	_Super:New()
	self:setCodCrit('M081')
	self:setMsgCrit('O Indicador do tipo de registro é inválido.')
	self:setSolCrit('Preencha corretamente o campo Indicador de tipo do registro que está sendo enviado à ANS.')
	self:setCpoCrit('BVQ_TPRGMN')
	self:setCodAns('M081')
Return Self

Method getWhereCrit() Class CritINDTPRG2
	Local cQuery := ""
	cQuery += " 	AND ( (BVQ_TPRGMN<>'1') AND (BVQ_TPRGMN<>'2') AND (BVQ_TPRGMN<>'3') ) "
Return cQuery