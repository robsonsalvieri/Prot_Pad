#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBVT
Classe abstrata das críticas em grupo dos itens de outras formas de remuneração (BVT)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBVT From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBVT
	_Super:New()
	self:setAlias('BVT')
Return Self

Method getQryCrit() Class CritGrpBVT
	Local cQuery := ""
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")
	
	cQuery += " SELECT BVT_FILIAL B3F_FILIAL "
	cQuery += " 	,BVT_CODOPE B3F_CODOPE "
	cQuery += " 	,BVT_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BVT_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BVT_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BVT.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BVT_LOTE B3F_DESORI "
	cQuery += " 	,BVT_CODOPE" +cConcat+ "BVT_NMGPRE" +cConcat+ "BVT_CDOBRI" +cConcat+ "BVT_ANO" +cConcat+ "BVT_CDCOMP" +cConcat+ "BVT_LOTE" +cConcat+ "BVT_DTPRGU" +cConcat+ "BVT_CODTAB" +cConcat+ "BVT_CODGRU" +cConcat+ "BVT_CODPRO B3F_IDEORI "
	cQuery += " 	,'" + self:getTpVld() + "' B3F_TIPO "
	cQuery += " 	,'" + self:getCpoCrit() + "' B3F_CAMPOS "
	cQuery += " 	,'" + self:getSolCrit() + "' B3F_SOLUCA "
	cQuery += " 	,'" + self:getStatus() + "' B3F_STATUS "
	cQuery += " 	,'" + self:getCodANS() + "' B3F_CRIANS "
	cQuery += " 	,'" + self:getMsgCrit() + "' B3F_DESCRI "
	cQuery += " 	,ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_) + (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName('B3F') + " B3F)  R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName('BVT') + " BVT "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BVT_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND BVT_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BVT_STATUS IN ('','1','2','3') "
	cQuery += " 	AND BVT.D_E_L_E_T_ = ' ' "
Return cQuery
