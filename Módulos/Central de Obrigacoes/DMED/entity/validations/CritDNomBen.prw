#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDNomBen
Descricao: 	Critica referente ao Campo.
				-> B2W_NOMBEN
@author lima.everton
@since 10/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDNomBen From CritGrpB2W
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDNomBen
	_Super:New()
	self:setCodCrit('DM01')
	self:setMsgCrit('Nome do Beneficiário inválido.')
	self:setSolCrit('O campo é de preenchimento obrigatório.')
	self:setCpoCrit('B2W_NOMBEN')
	self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDNomBen
	Local cQuery := ""
	Local cDB	 := TCGetDB()

	If cDB $ 'ORACLE/POSTGRES'
		cQuery += "  AND ( LENGTH(B2W_NOMBEN) = 0 OR  LENGTH(B2W_NOMBEN) > 60 ) "
	else
		cQuery += "  AND ( LEN(B2W_NOMBEN) = 0 OR  LEN(B2W_NOMBEN) > 60 ) "
	Endif
	cQuery += " AND B2W_IDEREG IN ('1','3') "
Return cQuery
