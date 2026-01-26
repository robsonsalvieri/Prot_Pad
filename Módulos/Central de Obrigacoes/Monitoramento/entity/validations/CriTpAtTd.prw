#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CriTpAtTd
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPATE
@author José Paulo
@since 07/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CriTpAtTd From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CriTpAtTd
	_Super:New()
	self:setCodCrit('M108')
	self:setMsgCrit('Código do Tipo de Atendimento Inválido.')
	self:setSolCrit('Preencha o Campo Código do tipo de atendimento conforme Tabela 50 - Terminologia de Tipo de Atendimento na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPATE')
	self:setCodAns('1602')
Return Self

Method getWhereCrit() Class CriTpAtTd
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '2' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " AND BKR_TIPATE <> ' ' "
	cQuery += " AND BKR_TIPATE NOT IN ( "
	cQuery += " SELECT B2R_CDTERM "
	cQuery += " FROM " + RetSqlName("B2R") + " "
	cQuery += " WHERE B2R_CODTAB = '50' "
	cQuery += " AND B2R_VIGDE <> '' "
	cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
	cQuery += " ) "
	
Return cQuery