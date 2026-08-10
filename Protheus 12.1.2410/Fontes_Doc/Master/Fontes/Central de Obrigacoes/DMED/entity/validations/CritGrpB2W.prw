#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpB2W
Classe abstrata das críticas em grupo das guias do monitoramento TISS (B2W)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpB2W From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpB2W
	_Super:New()
	self:setAlias('B2W')
Return Self

Method getQryCrit() Class CritGrpB2W
	Local cQuery := ""
	Local cDB	 := TCGetDB()
	Local cTable := RetSqlName("B2W")
	Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT B2W_FILIAL B3F_FILIAL "
	cQuery += " 	,B2W_CODOPE B3F_CODOPE "
	cQuery += " 	,B2W_CODOBR B3F_CDOBRI "
	cQuery += " 	,B2W_CDCOMP B3F_CDCOMP "
	cQuery += " 	,B2W_ANOCMP B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	," + cTable + ".R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,B2W_NOMBEN B3F_DESORI "
	cQuery += " 	,B2W_CODOPE"+cConcat+"B2W_CODOBR"+cConcat+"B2W_ANOCMP"+cConcat+"B2W_CDCOMP"+cConcat+"B2W_CPFTIT"+cConcat+"B2W_CPFBEN"+cConcat+"B2W_DTNASD"+;
		cConcat+"B2W_NOMBEN"+cConcat+"B2W_CPFPRE"+cConcat+"B2W_IDEREG B3F_IDEORI "
	cQuery += " 	,'" + self:getTpVld() + "' B3F_TIPO "
	cQuery += " 	,'" + self:getCpoCrit() + "' B3F_CAMPOS "
	cQuery += " 	,'" + self:getSolCrit() + "' B3F_SOLUCA "
	cQuery += " 	,'" + self:getStatus() + "' B3F_STATUS "
	cQuery += " 	,'" + self:getCodANS() + "' B3F_CRIANS "
	cQuery += " 	,'" + self:getMsgCrit() + "' B3F_DESCRI "
	cQuery += " 	,ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_) + "

	If cDB == "POSTGRES"
		cQuery += "COALESCE"
	Elseif cDB == "ORACLE"
		cQuery += "NVL"
	Else
		cQuery += "ISNULL"
	Endif

	cQuery += "((SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName('B3F') + " B3F),0)  R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName('B2W') + " "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND B2W_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND B2W_STATUS IN ('','1','2','3') "
	cQuery += " 	AND B2W_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND " + cTable + ".D_E_L_E_T_ = ' ' "
Return cQuery
