#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDMUNPR
Descricao: 	Critica referente ao Campo.
				-> B9T_CDMNPR
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDMUNPR From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCDMUNPR
	_Super:New()
	self:setCodCrit('M077')
	self:setMsgCrit('O Município de localização do prestador executante é inválido.')
	self:setSolCrit('Preencha corretamente o campo Código IBGE do município de localização do prestador executante, com um código válido no IBGE.')
	self:setCpoCrit('B9T_CDMNPR')
	self:setCodAns('5030')
Return Self

Method getWhereCrit() Class CritCDMUNPR
	Local cQuery := ""
	cQuery += " 	AND B9T_CDMNPR NOT IN ( "
	cQuery += " 		SELECT BID_CODMUN FROM " + RetSqlName("BID") 
	cQuery += " 		WHERE BID_FILIAL = '" + xFilial("BID") + "' " 
	cQuery += " 		AND D_E_L_E_T_ = ' ' )" 	
Return cQuery