#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDREGI
Descricao: 	Critica referente ao Campo.
				-> BKS_CDREGI 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDREGI From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCDREGI
	_Super:New()
	self:setCodCrit('M061' )
	self:setMsgCrit('O Código de Identificação da região da boca é inválido.')
	self:setSolCrit('Preencha corretamente o campo Identificação da região da boca de acordo com a tabela de domínio de regiões vigente na versão que a guia foi enviada.')
	self:setCpoCrit('BKS_CDREGI')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritCDREGI
	Local cQuery := ""
	cQuery += " 	AND BKS_CDDENT <> '' "
	cQuery += " 	AND (BKS_CDREGI = ''  OR BKS_CDREGI NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '42' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " )))"

Return cQuery