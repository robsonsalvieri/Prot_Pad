#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY CIDADEGFE
 

//-------------------------------------------------------------------
/*/{Protheus.doc} BACIDADE
Cadastro de cidade.
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BACIDADE from BAEntity
	Method Setup() CONSTRUCTOR
	Method BuildQuery()
EndClass
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.
 
@author romeu.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD Setup() Class BACIDADE
	_Super:Setup("CidadeGFE", DIMENSION, "GU7")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Cidade
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BACIDADE
Local cQuery := ""
 
cQuery += "SELECT "
cQuery += " <<KEY_GU7_GU7.GU7_FILIAL+GU7.GU7_NRCID>> 	AS BK_CIDADE "
cQuery += ' ,GU7.GU7_NRCID  AS "CodigoCidade" '
cQuery += ' ,GU7.GU7_NMCID  AS "NomeCidade" '
cQuery += ',GU7.GU7_CDUF   AS "UnidadeFederacao" '
cQuery += ',GU7.GU7_CDPAIS AS "CodigoPais" '
cQuery += ',SYA.YA_DESCR   AS "NomePais" '
cQuery += "FROM <<GU7_COMPANY>> GU7 "
cQuery += "LEFT JOIN <<SYA_COMPANY>> SYA ON SYA.YA_CODGI = GU7.GU7_CDPAIS "
cQuery += "AND SYA.D_E_L_E_T_ = '' "
cQuery += "WHERE GU7.D_E_L_E_T_  = '' "


Return cQuery
