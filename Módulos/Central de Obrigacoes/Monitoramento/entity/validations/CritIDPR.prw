#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDPR
Descricao: 	Critica referente ao Campo.
				-> B9T_IDVLRP
@author p.drivas
@since 01/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDPR From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritIDPR
	_Super:New()
	self:setCodCrit('M114')
	self:setMsgCrit('Identificador já informado.')
	self:setSolCrit('Preencha com um valor ainda não utilizado')
	self:setCpoCrit('B9T_IDVLRP')
	self:setCodAns('5053')
Return Self

Method getWhereCrit() Class CritIDPR
	Local cQuery := ""
	Local cTable := RetSqlName("B9T")
	cQuery += "	AND ( SELECT COUNT(B9T_IDVLRP) FROM " + RetSQLName(cTable)  + " AS B9TF  "
	cQuery += " WHERE " + cTable + ".B9T_IDVLRP = B9TF.B9T_IDVLRP AND D_E_L_E_T_ = '' ) > 1 "
Return cQuery