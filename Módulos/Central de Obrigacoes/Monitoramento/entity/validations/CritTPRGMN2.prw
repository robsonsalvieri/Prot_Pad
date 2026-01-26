#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTPRGMN2
Descricao: 	Critica referente ao Campo.
				-> BVZ_TPRGMN
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTPRGMN2 From CritGrpBVZ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTPRGMN2
	_Super:New()
	self:setCodCrit('M098' )
	self:setMsgCrit('O campo de Indicador do tipo de registro é inválido.')
	self:setSolCrit('O Campo Indicador do tipo de registro deve ser preenchido com 1-Inclusão, 2-Alteração ou 3 Exclusão.')
	self:setCpoCrit('BVZ_TPRGMN')
	self:setCodAns('M098')
Return Self

Method getWhereCrit() Class CritTPRGMN2
	Local cQuery := ""
	cQuery += " 	AND ( "
	cQuery += " 	(BVZ_TPRGMN <> '1') "
	cQuery += " 	AND (BVZ_TPRGMN <> '2') "
	cQuery += " 	AND (BVZ_TPRGMN <> '3') "
	cQuery += " 	) "

Return cQuery