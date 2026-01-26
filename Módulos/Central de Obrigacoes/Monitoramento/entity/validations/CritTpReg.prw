#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CRITTPREG
Descricao: 	Critica referente ao Campo Indicador de Tipo de Registro.
				-> BKR_TPRGMN
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTpReg From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTpReg
	_Super:New()
	self:setCodCrit('M008')
	self:setMsgCrit('O contéudo do campo Tipo Registro Monitoramento não pode ser vazio ou diferente de 1, 2 ou 3.')
	self:setSolCrit('Preencha o campo com 1, 2 ou 3')
	self:setCpoCrit('BKR_TPRGMN')
	self:setCodAns('')
 Return Self

Method getWhereCrit() Class CritTpReg
	Local cQuery := ""
	cQuery += " 	AND BKR_TPRGMN NOT IN ('1','2','3') "
Return cQuery