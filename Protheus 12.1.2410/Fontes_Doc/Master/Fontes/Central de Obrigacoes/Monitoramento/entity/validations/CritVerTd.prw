#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVerTd
Descricao: 	Critica referente ao Campo Versão do Componente TISS.
				-> BKR_VTISPR
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVerTd From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVerTd
	_Super:New()
	self:setCodCrit('M111')
	self:setMsgCrit('Versão TISS Inválida.')
	self:setSolCrit('Preencha a versão da guia de acordo com a tabela domínio 69, vigente na versão que a guia foi enviada.' )
	self:setCpoCrit('BKR_VTISPR')
	self:setCodAns('5028')
Return Self

Method getWhereCrit() Class CritVerTd
	Local cQuery := ""
		cQuery += " 	AND ( BKR_VTISPR = '' Or (BKR_VTISPR <> '' "
		cQuery += " AND BKR_VTISPR NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '69' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " ))))"

Return cQuery
	