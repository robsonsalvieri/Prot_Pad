#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBKS
Classe abstrata das críticas em grupo dos procedimentos das guias do monitoramento TISS (BKS)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBKS From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBKS
	_Super:New()
	self:setAlias('BKS')
Return Self

Method getQryCrit() Class CritGrpBKS
	Local cQuery := "" 
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT BKS_FILIAL B3F_FILIAL "
	cQuery += " 	,BKS_CODOPE B3F_CODOPE "
	cQuery += " 	,BKS_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BKS_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BKS_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BKS.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BKS_LOTE B3F_DESORI "
	cQuery += " 	,BKS_CODOPE" +cConcat+ "BKS_NMGOPE" +cConcat+ "BKS_CDOBRI" +cConcat+ "BKS_ANO" +cConcat+ "BKS_CDCOMP" +cConcat+ "BKS_LOTE" +cConcat+ "BKS_DTPRGU" +cConcat+ "BKS_CODGRU" +cConcat+ "BKS_CODTAB" +cConcat+ "BKS_CODPRO" +cConcat+ "BKS_CDDENT" +cConcat+ "BKS_CDREGI" +cConcat+ "BKS_CDFACE B3F_IDEORI "
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
	cQuery += " FROM " + RetSqlName('BKS') + " BKS "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BKS_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND BKS_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BKS_STATUS IN ('1','2','3') "
	cQuery += " 	AND BKS.D_E_L_E_T_ = ' ' "
Return cQuery
