#INCLUDE "TOTVS.CH"
#DEFINE REPOSITORY_UTILS agd.repositoryUtils.agdRepositoryUtils
/*/{Protheus.doc}AGDX030
Verifica se a TES atualiza estoque
@type function
@version P12
@author scheronlini.martins
@since 10/04/2025
@return Logical, return_true or false
/*/
function AGDX030(cTES)
	Local lRet      := .T.
	Local cQuery     := ""
	Local oRepositoryUtils := REPOSITORY_UTILS():New()
	Local aAtuEst 
	Local cAtuEst 

		cQuery := " SELECT F4_ESTOQUE"
		cQuery += " FROM "+ retSqlName('SF4') +" SF4 "
		cQuery += " WHERE F4_FILIAL = ? "
		cQuery += " AND F4_CODIGO = ? "
		cQuery += " AND SF4.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery( cQuery )

		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)
		oStatement:SetString(1, FWxFilial('SF4'))
		oStatement:SetString(2, cTES)
		cQuery := oStatement:GetFixQuery()

		if len(oRepositoryUtils:freeQueryToArray(cQuery, {"F4_ESTOQUE"})) > 0
			aAtuEst := oRepositoryUtils:freeQueryToArray(cQuery, {"F4_ESTOQUE"})
			cAtuEst := aAtuEst[1]:getJsonObject("F4_ESTOQUE")
			If AllTrim(cAtuEst) == 'N'
				lRet := .F.
			endif
		ENDIF

return lRet
