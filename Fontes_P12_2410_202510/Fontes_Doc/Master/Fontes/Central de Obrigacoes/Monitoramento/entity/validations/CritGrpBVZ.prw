#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBVZ
Classe abstrata das críticas em grupo outras formas de remuneração (BVZ)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBVZ From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBVZ
	_Super:New()
	self:setAlias('BVZ')
Return Self

Method getQryCrit() Class CritGrpBVZ
	Local cQuery := ""
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT BVZ_FILIAL B3F_FILIAL "
	cQuery += " 	,BVZ_CODOPE B3F_CODOPE "
	cQuery += " 	,BVZ_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BVZ_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BVZ_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BVZ.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BVZ_LOTE B3F_DESORI "
	cQuery += " 	,BVZ_CODOPE" +cConcat+ "BVZ_CPFCNP" +cConcat+ "BVZ_CDOBRI" +cConcat+ "BVZ_ANO" +cConcat+ "BVZ_CDCOMP" +cConcat+ "BVZ_LOTE" +cConcat+ "BVZ_DTPROC B3F_IDEORI "
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
	cQuery += " FROM " + RetSqlName('BVZ') + " BVZ "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BVZ_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND BVZ_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BVZ_STATUS IN ('','1','2','3') "
	cQuery += " 	AND BVZ.D_E_L_E_T_ = ' ' "
Return cQuery
