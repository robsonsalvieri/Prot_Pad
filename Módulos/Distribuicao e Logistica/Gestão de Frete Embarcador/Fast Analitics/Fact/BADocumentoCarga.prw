#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY DOCUMENTOCARGAGFE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BADocumentoCarga
Cadastro de DocumentoCarga
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BADocumentoCarga from BAEntity
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
METHOD Setup() Class BADocumentoCarga
	_Super:Setup("DocumentoCargaGFE",FACT, "GW1")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
DocumentoCarga
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BADocumentoCarga
Local cQuery := ""

cQuery += "SELECT DISTINCT "
//cQuery += "  <<KEY_COMPANY>> 			AS BK_EMPRESA "
//cQuery += " ,<<KEY_FILIAL_GW1_FILIAL>> 	AS BK_FILIAL "
cQuery += "  <<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS>>  AS BK_DOCCARGA "
cQuery += ' ,GW1.GW1_FILIAL  AS "FilialDocCarga" '
cQuery += ' ,GW1.GW1_CDTPDC  AS "TipoDocCarga" '
cQuery += ' ,GW1.GW1_NRDC    AS "NumeroDocCarga" '
cQuery += ' ,GW1.GW1_SERDC   AS "SerieDocCarga" '
cQuery += ' ,GW1.GW1_DTEMIS  AS "DataEmissaoDocCarga" '
cQuery += ' ,GW1.GW1_DTIMPL  AS "DataImplantacaoDocCarga" '
cQuery += ' ,GW1.GW1_DTPSAI  AS "DataPrevistaSaidaDocCarga" '
cQuery += ' ,GW1.GW1_DTSAI   AS "DataSaidaDocCarga" '
cQuery += " ,CASE "
cQuery += "   WHEN GW1.GW1_SIT = '1' THEN '1 - DIGITADO' "
cQuery += "   WHEN GW1.GW1_SIT = '2' THEN '2 - BLOQUEADO' "
cQuery += "   WHEN GW1.GW1_SIT = '3' THEN '3 - LIBERADO' "
cQuery += "   WHEN GW1.GW1_SIT = '4' THEN '4 - EMBARCADO' "
cQuery += "   WHEN GW1.GW1_SIT = '5' THEN '5 - ENTREGUE' "
cQuery += "   WHEN GW1.GW1_SIT = '6' THEN '6 - RETORNADO' "
cQuery += "   WHEN GW1.GW1_SIT = '7' THEN '7 - CANCELADO' "
cQuery += "   WHEN GW1.GW1_SIT = '8' THEN '8 - SINISTRADO' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '  END AS "SituacaoDocCarga" '
cQuery += " ,CASE "
cQuery += "   WHEN GW1.GW1_TPFRET = '1' THEN '1 - CIF' "
cQuery += "   WHEN GW1.GW1_TPFRET = '2' THEN '2 - CIF REDESPACHO' "
cQuery += "   WHEN GW1.GW1_TPFRET = '3' THEN '3 - FOB' "
cQuery += "   WHEN GW1.GW1_TPFRET = '4' THEN '4 - FOB REDESPACHO' "
cQuery += "   WHEN GW1.GW1_TPFRET = '5' THEN '5 - CONSIGNADO' "
cQuery += "   WHEN GW1.GW1_TPFRET = '6' THEN '6 - CONSIGNADO REDESPACHO' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '  END 			AS "TipoFreteDocCarga" '
cQuery += " ,CASE "
cQuery += "   WHEN GW1.GW1_USO = '1' THEN '1 - INDUSTRIALIZACAO/VENDA' "
cQuery += "   WHEN GW1.GW1_USO = '2' THEN '2 - USO/CONSUMO' "
cQuery += "   WHEN GW1.GW1_USO = '3' THEN '3 - ATIVO IMOBILIZADO' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '  END  											AS "FinalidadeUsoDocCarga" '
cQuery += ' ,GW1.GW1_REPRES 									AS "RepresentanteDocCarga" '
cQuery += ' ,GW1.GW1_REGCOM                                  AS "RegiaoComercialDocCarga" '
cQuery += ' ,GW1.GW1_NRROM                                  AS "RomaneioDocCarga" '
cQuery += " ,CASE "
cQuery += "   WHEN GWN.GWN_SIT = '1' THEN '1 - DIGITADO' "
cQuery += "   WHEN GWN.GWN_SIT = '2' THEN '2 - EMITIDO' "
cQuery += "   WHEN GWN.GWN_SIT = '3' THEN '3 - LIBERADO' "
cQuery += "   WHEN GWN.GWN_SIT = '4' THEN '4 - ENCERRADO' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '  END                                        AS "SituacaoRomaneio" '
cQuery += " ,RTRIM(GWN.GWN_CDTPVC)||' - '||GV3.GV3_DSTPVC "
cQuery += 'AS "TipoVeiculoRomaneio" '
cQuery += " ,RTRIM(GWN.GWN_CDCLFR)||' - '||GUB.GUB_DSCLFR "
cQuery += 'AS "ClassificacaoFreteRomaneio" '
cQuery += " ,RTRIM(GWN.GWN_CDTPOP)||' - '||GV4.GV4_DSTPOP "
cQuery += 'AS "TipoOperacaoRomaneio" '
cQuery += " ,CASE "
cQuery += "   WHEN GWN.GWN_CALC = '1' THEN '1 - CALCULADO' "
cQuery += "   WHEN GWN.GWN_CALC = '2' THEN '2 - NAO CALCULADO' "
cQuery += "   WHEN GWN.GWN_CALC = '3' THEN '3 - SEM SUCESSO' "
cQuery += "   WHEN GWN.GWN_CALC = '4' THEN '4 - RECALCULAR' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '  END AS "SituacaoCalculo" '
cQuery += " FROM <<GW1_COMPANY>>  GW1 "
cQuery += " LEFT JOIN <<GWN_COMPANY>> GWN "
cQuery += "   ON GWN.GWN_FILIAL = <<SUBSTR_GWN_GW1_FILIAL>> "
cQuery += "  AND GWN.GWN_NRROM  = GW1.GW1_NRROM "
cQuery += "  AND GWN.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GWU_COMPANY>> GWU "
cQuery += "   ON GWU.GWU_FILIAL = <<SUBSTR_GWU_GW1_FILIAL>>  "
cQuery += "  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
cQuery += "  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
cQuery += "  AND GWU.GWU_PAGAR  = 1 "
cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GV3_COMPANY>> GV3 "
cQuery += "   ON GV3.GV3_FILIAL = <<SUBSTR_GV3_GWN_FILIAL>> "
cQuery += "  AND GV3.GV3_CDTPVC = GWN.GWN_CDTPVC "
cQuery += "  AND GV3.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GUB_COMPANY>> GUB "
cQuery += "   ON GUB.GUB_FILIAL = <<SUBSTR_GUB_GWN_FILIAL>> "
cQuery += "  AND GUB.GUB_CDCLFR = GWN.GWN_CDCLFR "
cQuery += "  AND GUB.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GV4_COMPANY>> GV4 "
cQuery += "   ON GV4.GV4_FILIAL = <<SUBSTR_GV4_GWN_FILIAL>> "
cQuery += "  AND GV4.GV4_CDTPOP = GWN.GWN_CDTPOP "
cQuery += "  AND GV4.D_E_L_E_T_ = ' ' "
cQuery += " WHERE GW1.D_E_L_E_T_  = ' ' "
cQuery += "  AND GW1.GW1_DTIMPL >= <<START_DATE>> "
cQuery += "  AND GW1.GW1_DTIMPL <= <<FINAL_DATE>> " 

Return cQuery
