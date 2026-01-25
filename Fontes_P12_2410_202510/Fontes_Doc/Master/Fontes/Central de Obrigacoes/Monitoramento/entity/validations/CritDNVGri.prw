#Include "Totvs.ch"

#DEFINE RESU_INTER '3'
#DEFINE DNASC_VIVO '1'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDNVGri
Descricao: 	Critica referente ao Campo.
				-> BKR_TPEVAT
@author Everton Lima
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDNVGri From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDNVGri
	_Super:New()
	self:setCodCrit('M118')
	self:setMsgCrit('A informação da Declaração de Nascido Vivo só pode constar em guias de Resumo de Internação.')
	self:setSolCrit('Não deve ser preenchido Declarações de Nascidos Vivos em guias que não sejam de Resumo de Internação (Tipo 3).')
	self:setCpoCrit('BKR_TPEVAT')
	self:setCodANS('')
Return Self

/*
	Não deve ser incluido declarações de nascido vivo
	Em guias que não sejam de internação

	Diferente de resumo de internação
	BKR_TPEVAT <> 3

	Declaração de nascido vivo
	BN0_TIPO = 1
*/
Method getWhereCrit() Class CritDNVGri
	Local cQuery := ""
	cQuery	+= " AND BKR_TPEVAT <> '" + RESU_INTER + "' "
	cQuery	+= " AND ( "
	cQuery	+= " 	SELECT count(*) FROM "+ RetSqlName("BN0") +" "
	cQuery	+= " 	WHERE 1=1 "
	cQuery	+= " 		AND BN0_CODOPE = BKR_CODOPE "
	cQuery	+= " 		AND BN0_TIPO = '" + DNASC_VIVO + "' "
	cQuery	+= " 		AND BN0_NMGOPE = BKR_NMGOPE "
	cQuery	+= " 		AND BN0_ANO = BKR_ANO "
	cQuery	+= " 		AND BN0_CDCOMP = BKR_CDCOMP "
	cQuery	+= " 		AND BN0_CDOBRI = BKR_CDOBRI "
	cQuery	+= " ) > 0 "
Return cQuery



