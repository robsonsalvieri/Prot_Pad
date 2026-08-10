#Include "Totvs.ch"

#DEFINE INTER_OBST '3'
#DEFINE DECL_OBITO '2'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDecObt
Descricao: 	Critica referente ao Campo.
				-> BKR_TPEVAT
@author Everton Lima
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDecObt From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass
Method New() Class CritDecObt
	_Super:New()
	self:setCodCrit('M120')
	self:setMsgCrit('A declaração de óbito só deve constar em guias de internação.')
	self:setSolCrit('Não deve ser preenchido Declarações de Óbito em guias que não sejam de Resumo de Internação (Tipo 3).')
	self:setCpoCrit('BKR_TPEVAT')
	self:setCodANS('')
Return Self

/*
	Não deve ser incluido declarações de óbito
	Em guias que não sejam de internação

	Diferente de resumo de internação
	BKR_TPEVAT <> 3

	Declaração de Obito
	BN0_TIPO = 1
*/
Method getWhereCrit() Class CritDecObt
	Local cQuery := ""
	cQuery	+= " AND BKR_TPEVAT <> '" + INTER_OBST + "' "
	cQuery	+= " AND ( "
	cQuery	+= " 	SELECT count(*) FROM "+ RetSqlName("BN0") +" "
	cQuery	+= " 	WHERE 1=1 "
	cQuery	+= " 		AND BN0_CODOPE = BKR_CODOPE "
	cQuery	+= " 		AND BN0_TIPO = '" + DECL_OBITO + "' "
	cQuery	+= " 		AND BN0_NMGOPE = BKR_NMGOPE "
	cQuery	+= " 		AND BN0_ANO = BKR_ANO "
	cQuery	+= " 		AND BN0_CDCOMP = BKR_CDCOMP "
	cQuery	+= " 		AND BN0_CDOBRI = BKR_CDOBRI "
	cQuery	+= " ) > 0 "
Return cQuery