#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTIPADM
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPADM 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTIPADM From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTIPADM
	_Super:New()
	self:setCodCrit('M054')
	self:setMsgCrit('O Código do caráter do atendimento é inválido.')
	self:setSolCrit('Preencha corretamente o campo Código do caráter do atendimento conforme tabela de domínio vigente na versão que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPADM')
	self:setCodAns('5031')
Return Self

Method getWhereCrit() Class CritTIPADM
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='2') OR (BKR_TPEVAT='3') ) "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND (BKR_TIPADM = '' OR ((BKR_TIPADM<>'1') AND (BKR_TIPADM<>'2')) )"
Return cQuery
