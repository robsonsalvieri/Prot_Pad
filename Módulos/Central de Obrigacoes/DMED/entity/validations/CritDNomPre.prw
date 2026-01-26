#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDDatNas
Descricao: 	Critica referente ao Campo.
				-> B2W_NOMPRE
@author lima.everton
@since 10/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDNomPre From CritGrpB2W
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDNomPre
	_Super:New()
	self:setCodCrit('DM02')
	self:setMsgCrit('Nome do prestador inválido.')
	self:setSolCrit('O campo é de preenchimento obrigatório, e no máximo de 60 posições para o nome da pessoa física. Para PJ o tamanho é de no máximo 150 posições.')
	self:setCpoCrit('B2W_NOMPRE')
	self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDNomPre
	Local cQuery := ""
	Local cDB	 := TCGetDB()

	If cDB $ 'ORACLE/POSTGRES'
		cQuery += "  AND ( ( LENGTH(B2W_CPFBEN) = 11 AND LENGTH(B2W_NOMPRE) > 60 ) OR  LENGTH(B2W_NOMPRE) = 0 ) "
	else
		cQuery += "  AND ( ( LEN(B2W_CPFBEN) = 11 AND LEN(B2W_NOMPRE) > 60 ) OR  LEN(B2W_NOMPRE) = 0 ) "
	Endif
	cQuery += " AND B2W_IDEREG IN ('2','4') "
Return cQuery

