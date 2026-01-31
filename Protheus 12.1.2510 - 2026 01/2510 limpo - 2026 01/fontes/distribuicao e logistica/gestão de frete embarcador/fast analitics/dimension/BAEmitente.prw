#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY EMITENTEGFE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAEMITENTE
Cadastro de Emitente
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BAEMITENTE from BAEntity
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
METHOD Setup() Class BAEMITENTE
	_Super:Setup("EmitenteGFE", DIMENSION, "GU3")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Emitente
 @return cQuery, string, query a ser processada.
 
@author romeu.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BAEMITENTE
Local cQuery := ""

cQuery += "SELECT "
cQuery += " <<KEY_GU3_GU3.GU3_FILIAL+GU3.GU3_CDEMIT>> 	AS BK_EMITENTE "
cQuery += ', GU3.GU3_FILIAL                          AS "FilialEmitente" '
cQuery += ', GU3.GU3_CDEMIT                          AS "CodigoEmitente" '
cQuery += ', GU3.GU3_NMEMIT                          AS "NomeEmitente" '
cQuery += ', GU3.GU3_NMABRV                          AS "NomeAbreviadoEmitente" '
cQuery += ', GU3.GU3_CDGREM                          AS "GrupoEmpresaEmitente" '
cQuery += ', GU3.GU3_CDGRED                          AS "GrupoEDIEmitente" '
cQuery += ', GU3.GU3_CDGRGL                          AS "GrupoGerencialEmitente" '
cQuery += ", <<KEY_GU7_GU7.GU7_FILIAL+GU7.GU7_NRCID>>  	AS BK_CIDADE "
cQuery += ', GU3.GU3_NATUR AS "TipoPessoa" '
cQuery += ', GU3.GU3_IDFED AS "CNPJCPFEmitente" '
cQuery += ", CASE "
cQuery += "    WHEN GU3.GU3_CATTRP = '1' THEN '1 - EMPRESA COMERCIAL' "
cQuery += "    WHEN GU3.GU3_CATTRP = '2' THEN '2 - AUTONOMO' "
cQuery += "    WHEN GU3.GU3_CATTRP = '3' THEN '3 - COOPERATIVA' "
cQuery += "    WHEN GU3.GU3_CATTRP = '4' THEN '4 - OPERADOR LOGISTICO' "
cQuery += "    WHEN GU3.GU3_CATTRP = '5' THEN '5 - DISTRIBUIDOR' "
cQuery += "    WHEN GU3.GU3_CATTRP = '6' THEN '6 - CORREIOS' "
cQuery += "    WHEN GU3.GU3_CATTRP = '7' THEN '7 - PROPRIO EMBARCADOR' "
cQuery += "    WHEN GU3.GU3_CATTRP = '8' THEN '8 - OUTROS' "
cQuery += "    ELSE '0 - NAO INFORMADO' "
cQuery += '  END 			AS "CategoriaTransportador" '
cQuery += ", CASE "
cQuery += "    WHEN GU3.GU3_MODAL = '1' THEN '1 - NAO INFORMADO' "
cQuery += "    WHEN GU3.GU3_MODAL = '2' THEN '2 - RODOVIARIO' "
cQuery += "    WHEN GU3.GU3_MODAL = '3' THEN '3 - FERROVIARIO' "
cQuery += "    WHEN GU3.GU3_MODAL = '4' THEN '4 - AEREO' "
cQuery += "    WHEN GU3.GU3_MODAL = '5' THEN '5 - AQUAVIARIO' "
cQuery += "    WHEN GU3.GU3_MODAL = '6' THEN '6 - DUTOVAIARIO' "
cQuery += "    WHEN GU3.GU3_MODAL = '7' THEN '7 - MULTIMODAL' "
cQuery += "    ELSE '1 - NAO INFORMADO'  "
cQuery += '  END            AS "ModalTransportador" '
cQuery += ', GU3.GU3_EMFIL  AS "Emitente?" '
cQuery += ', GU3.GU3_TRANSP AS "Transportador?" '
cQuery += ', GU3.GU3_CLIEN  AS "Cliente?" '
cQuery += ', GU3.GU3_FORN   AS "Fornecedor?" '
cQuery += ', GU3.GU3_AUTON  AS "Autonomo?" '
cQuery += "FROM <<GU3_COMPANY>> GU3 "
cQuery += "INNER JOIN <<GU7_COMPANY>> GU7 "
cQuery += "   ON GU7.GU7_FILIAL = <<SUBSTR_GU7_GU3_FILIAL>>  "
cQuery += "  AND GU7.GU7_NRCID  = GU3.GU3_NRCID "
cQuery += "  AND GU7.D_E_L_E_T_ = '' "
cQuery += "WHERE GU3.D_E_L_E_T_ = '' "

Return cQuery
