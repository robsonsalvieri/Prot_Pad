#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} GTPUVldAut(cCodLocal, cRotina)
(long_description)
@type  Static Function
@author flavio.martins
@since 28/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPUVldAut(cCodLocal, cRotina)
Local lRet      := .T.
//Local cAliasTmp := GetNextAlias()
//Local cQuery    := ''

Default cRotina   := ''
Default cCodLocal := ''

// Do Case
// 	Case cRotina == "GTPU015"
// 		cQuery := '%' + " H7N.H7N_CDFECH = 'T' " + '%'
// EndCase

/* Alias cAliasTmp

    SELECT H7N_COD FROM %Table:H7M% H7M 
    INNER JOIN %Table:H7N% H7N ON H7N.H7N_FILIAL = %xFilial:H7N%
        AND H7N.H7N_CODLOC = H7M.H7M_COD 
        AND H7N.H7N_COD = %Exp:__cUserID%
        AND %Exp:cQuery%
        AND H7N.%NotDel%
    WHERE
    H7M.H7M_FILIAL = %xFilial:H7N%
    AND H7M.H7M_COD = %Exp:cCodLocal%
    AND H7M.%NotDel%

EndSql

If  (cAliasTmp)->(ScopeCount()) == 0 
    lRet := .F.
    FwAlertInfo('Usuário não tem permissão para executar esta ação')
Endif

(cAliasTmp)->(dbCloseArea())*/

Return lRet

