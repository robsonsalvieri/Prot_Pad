#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY ITEMDOCUMENTOCARGAGFE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAItemDocumentoCarga
Cadastro de ItemDocumentoCarga
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BAItemDocumentoCarga from BAEntity
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
METHOD Setup() Class BAItemDocumentoCarga
	_Super:Setup("ItemDocumentoCargaGFE", FACT, "GW8")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
ItemDocumentoCarga
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BAItemDocumentoCarga
Local cQuery := ""

cQuery += "SELECT "
cQuery += " <<KEY_COMPANY>> 			AS BK_EMPRESA "
cQuery += ",<<KEY_FILIAL_GW1_FILIAL>> 	AS BK_FILIAL "
cQuery += ",<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS>>    							AS BK_DOCCARGA "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GW8.GW8_SEQ+GW8.GW8_ITEM>>    AS BK_ITEMDOCCARGA "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GWU.GWU_SEQ>> AS BK_TRECHODOCCARGA "
cQuery += ",<<KEY_GU3_GU3EMT.GU3_FILIAL+GU3EMT.GU3_CDEMIT>> AS BK_EMITENTE "
cQuery += ",<<KEY_GU3_GU3RMT.GU3_FILIAL+GU3RMT.GU3_CDEMIT>> AS BK_REMETENTE "
cQuery += ",<<KEY_GU3_GU3DST.GU3_FILIAL+GU3DST.GU3_CDEMIT>> AS BK_DESTINATARIO "
cQuery += " ,<<KEY_GU3_GU3TRP.GU3_FILIAL+GU3TRP.GU3_CDEMIT>> AS BK_TRANSPORTADOR "
cQuery += " ,<<KEY_GU7_GU7ORI.GU7_FILIAL+GU7ORI.GU7_NRCID>>  AS BK_CIDADEORIGEM "
cQuery += " ,<<KEY_GU7_GU7DST.GU7_FILIAL+GU7DST.GU7_NRCID>>  AS BK_CIDADEDESTINO "
cQuery += ',GW1.GW1_DTIMPL             AS "DataImplantacaoDocCarga" '
cQuery += ',GW8.GW8_SEQ                AS "SequenciaItemDocCarga" '
cQuery += ',GW8.GW8_ITEM               AS "CodigoItemDocCarga" '
cQuery += ',GW8.GW8_DSITEM             AS "DescricaoItemDocCarga" '
cQuery += ',GW8.GW8_QTDE               AS "QuantidadeItemDocCarga" '

if GFXCP12117('GW8_UNIMED')
    cQuery += ',GW8.GW8_UNIMED         AS "UnidadeMedidaItemDocCarga" '
else
    cQuery += ",'  '                   "
	cQuery += 'AS "UnidadeMedidaItemDocCarga" '
end

cQuery += ',GW8.GW8_VALOR              AS "ValorItemDocCarga" '
cQuery += ',GW8.GW8_VOLUME             AS "VolumeItemDocCarga" '
cQuery += ',GW8.GW8_PESOC              AS "PesoCubadoItemDocCarga" '
cQuery += ',GW8.GW8_PESOR              AS "PesoItemDocCarga" '
cQuery += ',GW8.GW8_CFOP               AS "CfopItemDocCarga" '
cQuery += ',GW8.GW8_INFO1              AS "InfContabil_1_ItemDocCarga" '
cQuery += ',GW8.GW8_INFO2              AS "InfContabil_2_ItemDocCarga" '
cQuery += ',GW8.GW8_INFO3              AS "InfContabil_3_ItemDocCarga" '
cQuery += ',GW8.GW8_INFO4              AS "InfContabil_4_ItemDocCarga" '
cQuery += ',GW8.GW8_INFO5              AS "InfContabil_5_ItemDocCarga" '
cQuery += ',GW8.GW8_UNINEG             AS "UnidadeNegocioItemDocCarga" '
cQuery += "FROM <<GW1_COMPANY>>  GW1 "
cQuery += "INNER JOIN <<GW8_COMPANY>> GW8 "
cQuery += "   ON GW8.GW8_FILIAL = <<SUBSTR_GW8_GW1_FILIAL>> "
cQuery += "  AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
cQuery += "  AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
cQuery += "  AND GW8.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GWU_COMPANY>> GWU "
cQuery += "   ON GWU.GWU_FILIAL = <<SUBSTR_GWU_GW1_FILIAL>>  "
cQuery += "  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
cQuery += "  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
cQuery += "  AND GWU.GWU_PAGAR  = 1 "
cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3EMT "
cQuery += "   ON GU3EMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3EMT.GU3_CDEMIT = GW1.GW1_EMISDC "
cQuery += "  AND GU3EMT.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3RMT "
cQuery += "   ON GU3RMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3RMT.GU3_CDEMIT = GW1.GW1_CDREM "
cQuery += "  AND GU3RMT.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3DST "
cQuery += "   ON GU3DST.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3DST.GU3_CDEMIT = GW1.GW1_CDDEST "
cQuery += "  AND GU3DST.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3TRP "
cQuery += "   ON GU3TRP.GU3_FILIAL = <<SUBSTR_GU3_GWU_FILIAL>> "
cQuery += "  AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP "
cQuery += "  AND GU3TRP.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GU7_COMPANY>> GU7ORI "
cQuery += "   ON GU7ORI.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7ORI.GU7_NRCID  = COALESCE(RTRIM(NULLIF(GWU.GWU_NRCIDO,' ')),GU3EMT.GU3_NRCID) "
cQuery += "  AND GU7ORI.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU7_COMPANY>> GU7DST "
cQuery += "   ON GU7DST.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7DST.GU7_NRCID  = GWU.GWU_NRCIDD "
cQuery += "  AND GU7DST.D_E_L_E_T_ = ' ' "
cQuery += "WHERE GW1.D_E_L_E_T_ = ' ' "
cQuery += "  AND GW1.GW1_DTIMPL >= <<START_DATE>> "
cQuery += "  AND GW1.GW1_DTIMPL <= <<FINAL_DATE>> "


Return cQuery
