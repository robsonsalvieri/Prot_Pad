#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTpCons
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPCON
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTpCons  From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTpCons
	_Super:New()
	self:setCodCrit('M026')
	self:setMsgCrit('Tipo de Consulta Inválido.')
	self:setSolCrit('Preencha o Código do tipo de consulta realizada conforme tabela de domínio vigente na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPCON')
	self:setCodAns('1603')
Return Self

Method getWhereCrit() Class CritTpCons
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='1') OR (BKR_TPEVAT='2') ) "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND ( BKR_TIPCON = '' Or (BKR_TIPCON <> '' "
	cQuery += " AND BKR_TIPCON NOT IN ( "
	cQuery += " SELECT B2R_CDTERM "
	cQuery += " FROM " + RetSqlName("B2R") + " "
	cQuery += " WHERE B2R_CODTAB = '52' "
	cQuery += " AND B2R_VIGDE <> '' "
	cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
	cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

	cQuery += " )) ))"

Return cQuery

