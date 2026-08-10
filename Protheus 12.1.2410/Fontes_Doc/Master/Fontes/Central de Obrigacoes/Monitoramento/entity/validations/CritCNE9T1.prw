#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNE9T1
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Saúde
				-> B9T_CNES
@author José Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNE9T1 From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNE9T1
	_Super:New()
	self:setCodCrit('M130' )
	self:setMsgCrit('Número do CNES Inválido .')
	self:setSolCrit('Preencha o campo com Número do CNES válido e existente no Ministério da Saúde.')
	self:setCpoCrit('B9T_CNES')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritCNE9T1
	Local cQuery := ""
	cQuery += " 	AND (B9T_CNES='') "
Return cQuery