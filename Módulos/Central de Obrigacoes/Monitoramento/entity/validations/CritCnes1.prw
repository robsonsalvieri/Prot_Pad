#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNES1
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Saúde
				-> BKR_CNES1
@author José Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNES1 From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNES1
	_Super:New()
	self:setCodCrit('M131' )
	self:setMsgCrit('Número do CNES Inválido .')
	self:setSolCrit('Preencha o campo com Número do CNES válido e existente no Ministério da Saúde.')
	self:setCpoCrit('BKR_CNES')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritCNES1
	Local cQuery := ""
	cQuery += " 	AND (BKR_CNES='') "
Return cQuery

