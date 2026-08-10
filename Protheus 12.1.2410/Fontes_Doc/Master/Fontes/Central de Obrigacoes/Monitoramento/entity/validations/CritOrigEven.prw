#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritOrigEven
Descricao: 	Critica referente ao Campo Versão do Componente TISS.
				-> BKR_VTISPR
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritOrigEven From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritOrigEven
	_Super:New()
	self:setCodCrit('M011')
	self:setMsgCrit('Indicador de Origem da Guia Inválido.')
	self:setSolCrit('Preencha a origem da guia de acordo com a tabela domínio 40 vigente na versão que a guia foi enviada.' )
	self:setCpoCrit('BKR_OREVAT')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritOrigEven
	Local cQuery := ""
		cQuery += " 	AND ( BKR_OREVAT = '' Or (BKR_OREVAT <> '' "
		cQuery += " AND BKR_OREVAT NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '40' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " ))))"

Return cQuery
	