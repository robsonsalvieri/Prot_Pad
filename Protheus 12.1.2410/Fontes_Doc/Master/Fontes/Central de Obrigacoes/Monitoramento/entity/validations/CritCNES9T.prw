#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNES9T
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Saúde
				-> B9T_CNES
@author José Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNES9T From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNES9T
	_Super:New()
	self:setCodCrit('M112' )
	self:setMsgCrit('Número do CNES Inválido .')
	self:setSolCrit('Preencha o campo com Número do CNES válido e existente no Ministério da Saúde.')
	self:setCpoCrit('B9T_CNES')
	self:setCodANS('1202')
Return Self

Method getWhereCrit() Class CritCNES9T
	Local cQuery := ""	
	cQuery += " 	AND (B9T_CNES='0000000') "
Return cQuery


