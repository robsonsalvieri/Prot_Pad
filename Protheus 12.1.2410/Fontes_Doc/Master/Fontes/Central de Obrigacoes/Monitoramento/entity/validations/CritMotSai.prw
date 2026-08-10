#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritMotSai
Descricao: 	Critica referente ao Campo.
				-> BKR_MOTSAI
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritMotSai From CritGrpBKR

	Method New() Constructor
	Method getWhereCrit()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo NEW
Descricao: Metodo Construtor da Classe 

@author Hermiro Júnior
@since 01/10/2019
/*/
//-------------------------------------------------------------------
Method New() Class CritMotSai

	_Super:New()
	self:setCodCrit('M040')
	self:setMsgCrit('O campo Motivo do Encerramento é inválido.')
	self:setSolCrit('Preencha o Campo Código do motivo de encerramento do atendimento, de acordo com a Tabela 39 - Terminologia de motivo de encerramento. ')
	self:setCpoCrit('BKR_MOTSAI')
	self:setCodANS('5033')
Return Self


Method getWhereCrit() Class CritMotSai
	Local cQuery := ""
		cQuery	+= " 	AND ( (BKR_TPEVAT='2') OR (BKR_TPEVAT='3') ) "
		cQuery	+= "	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
		cQuery += " 	AND ( BKR_MOTSAI = '' Or (BKR_MOTSAI <> '' "
		cQuery += " AND BKR_MOTSAI NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '39' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " ))))"

Return cQuery

	

