#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritRgOpIn
Descricao: 	Critica referente ao Campo de Registro do Operador Intermediario
				-> BKR_RGOPIN
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritRgOpIn From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritRgOpIn
	_Super:New()
	self:setCodCrit('M105')
	self:setMsgCrit('Registro ANS da Operadora Intermediária Invalido.')
	self:setSolCrit('O número do registro da Operadora intermediária deve ser diferente da Operadora que enviou o arquivo.')
	self:setCpoCrit('BKR_RGOPIN')
	self:setCodAns('5027')
Return Self

Method getWhereCrit() Class CritRgOpIn
	Local cQuery := ""
	cQuery += " AND (BKR_CODOPE = BKR_RGOPIN) " 	
Return cQuery