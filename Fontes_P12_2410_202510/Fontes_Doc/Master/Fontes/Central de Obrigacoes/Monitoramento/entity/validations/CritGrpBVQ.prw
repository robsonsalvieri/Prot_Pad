#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBVQ
Classe abstrata das críticas em grupo das guias de fornecimento direto (BVQ)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBVQ From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBVQ
	_Super:New()
	self:setAlias('BVQ')
Return Self

Method getQryCrit() Class CritGrpBVQ
	Local cQuery := ""
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT BVQ_FILIAL B3F_FILIAL "
	cQuery += " 	,BVQ_CODOPE B3F_CODOPE "
	cQuery += " 	,BVQ_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BVQ_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BVQ_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BVQ.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BVQ_LOTE B3F_DESORI "
	cQuery += " 	,BVQ_CODOPE" +cConcat+ "BVQ_NMGPRE" +cConcat+ "BVQ_CDOBRI" +cConcat+ "BVQ_ANO" +cConcat+ "BVQ_CDCOMP" +cConcat+ "BVQ_LOTE" +cConcat+ "BVQ_DTPRGU B3F_IDEORI "
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
	cQuery += " FROM " + RetSqlName('BVQ') + " BVQ "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BVQ_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND BVQ_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BVQ_STATUS IN ('','1','2','3') "
	cQuery += " 	AND BVQ.D_E_L_E_T_ = ' ' "
Return cQuery
