#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBKT
Classe abstrata das críticas em grupo dos procedimentos das guias do monitoramento TISS (BKT)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBKT From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBKT
	_Super:New()
	self:setAlias('BKT')
Return Self

Method getQryCrit() Class CritGrpBKT
	Local cQuery := ""
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT BKT_FILIAL B3F_FILIAL "
	cQuery += " 	,BKT_CODOPE B3F_CODOPE "
	cQuery += " 	,BKT_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BKT_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BKT_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BKT.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BKT_LOTE B3F_DESORI "
	cQuery += " 	,BKT_CODOPE" +cConcat+ "BKT_NMGOPE" +cConcat+ "BKT_CDOBRI" +cConcat+ "BKT_ANO" +cConcat+ "BKT_CDCOMP" +cConcat+ "BKT_LOTE" +cConcat+ "BKT_DTPRGU" +cConcat+ "BKT_CODTAB" +cConcat+ "BKT_CODPRO" +cConcat+ "BKT_CDTBIT" +cConcat+ "BKT_CDPRIT B3F_IDEORI "
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
	cQuery += " FROM " + RetSqlName('BKT') + " BKT "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BKT_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BKT_CODOPE = '" + self:getOper() + "' "
	cQuery += " 	AND BKT_STATUS IN ('','1','2','3') "
	cQuery += " 	AND BKT.D_E_L_E_T_ = ' ' "
Return cQuery
