#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTpInt
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPINT
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTpInt From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTpInt
	_Super:New()
	self:setCodCrit('M030')
	self:setMsgCrit('Tipo de Internação é inválido.')
	self:setSolCrit('Preencha o Campo de Tipo de Internação conforme tabela de domínio vigente na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPINT')
	self:setCodAns('1506')
Return Self

Method getWhereCrit() Class CritTpInt
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') )"
	cQuery += " 	AND BKR_TIPINT <> '' "
	cQuery += " 	AND ( (BKR_TIPINT<>'1') "
	cQuery += " 	AND (BKR_TIPINT<>'2') "
	cQuery += " 	AND (BKR_TIPINT<>'3') "
	cQuery += " 	AND (BKR_TIPINT<>'4') "
	cQuery += " 	AND (BKR_TIPINT<>'5') ) "
Return cQuery

