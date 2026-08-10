#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpB9T
Classe abstrata das críticas em grupo valor pré-estabelecido (B9T)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpB9T From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpB9T
	_Super:New()
	self:setAlias('B9T')
Return Self

Method getQryCrit() Class CritGrpB9T
	Local cQuery := ""
	Local cDB	 := TCGetDB()
	Local cTable := RetSqlName("B9T")
	Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT B9T_FILIAL B3F_FILIAL "
	cQuery += " 	,B9T_CODOPE B3F_CODOPE "
	cQuery += " 	,B9T_CDOBRI B3F_CDOBRI "
	cQuery += " 	,B9T_CDCOMP B3F_CDCOMP "
	cQuery += " 	,B9T_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	," + cTable + ".R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,B9T_LOTE B3F_DESORI "
	cQuery += " 	,B9T_CODOPE" +cConcat+ "B9T_CNES" +cConcat+ "B9T_CPFCNP" +cConcat+ "B9T_CDMNPR" +cConcat+ "B9T_RGOPIN" +cConcat+ "B9T_IDVLRP" +cConcat+ "B9T_COMCOB" +cConcat+ "B9T_CDOBRI" +cConcat+ "B9T_ANO" +cConcat+ "B9T_CDCOMP" +cConcat+ "B9T_LOTE B3F_IDEORI "
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
	cQuery += " FROM " + RetSqlName('B9T') + " "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND B9T_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND B9T_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND B9T_STATUS IN ('','1','2','3') "
	cQuery += " 	AND " + cTable + ".D_E_L_E_T_ = ' ' "
Return cQuery
