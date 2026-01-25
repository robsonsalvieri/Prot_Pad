#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCdCboTd
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPATE
@author José Paulo
@since 07/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCdCboTd From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCdCboTd
	_Super:New()
	self:setCodCrit('M109')
	self:setMsgCrit('CBO do Executante Inválido.')
	self:setSolCrit('Preencha o Campo Código do tipo de atendimento conforme Tabela 24 - Terminologia de CBOS na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_CBOS')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritCdCboTd
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='1') OR (BKR_TPEVAT='2') ) "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " AND BKR_CBOS <> '999999' AND BKR_CBOS <> ''"
	cQuery += " AND BKR_CBOS NOT IN ( " 
	cQuery += " SELECT B2R_CDTERM "
	cQuery += " FROM " + RetSqlName("B2R") + " "
	cQuery += " WHERE B2R_CODTAB = '24' "
	cQuery += " AND B2R_VIGDE <> '' "
	cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
	cQuery += " ) "

Return cQuery