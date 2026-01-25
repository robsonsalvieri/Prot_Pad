#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTipFat
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPFAT
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTipFat From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTipFat
	_Super:New()
	self:setCodCrit('M037')
	self:setMsgCrit('O Código do Tipo de Faturamento não é válido.')
	self:setSolCrit('Preencha o Campo Código do tipo do faturamento apresentado nesta guia conforme tabela de domínio na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPFAT')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritTipFat
	Local cQuery := ""
		cQuery += " 	AND ( (BKR_TPEVAT='3') OR (BKR_TPEVAT='4') ) "
		cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
		cQuery += " 	AND ( BKR_TIPFAT = '' Or (BKR_TIPFAT <> '' "
		cQuery += " AND BKR_TIPFAT NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '55' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " ))))"


Return cQuery

