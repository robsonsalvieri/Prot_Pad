#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY GFECNH
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BARATEIOFRETECONHECIMENTOGFE
retorna os valores de frete Rateio por documento de carga
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BARateioFrtConhecimento from BAEntity
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
METHOD Setup() Class BARateioFrtConhecimento
	_Super:Setup("RateioFreteConhecimentoGFE", FACT, "GW3")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
RATEIOFRETECONHECIMENTOGFE
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BARateioFrtConhecimento
Local cQuery := ""

cQuery += "SELECT "
cQuery += " <<KEY_COMPANY>> 			AS BK_EMPRESA "
cQuery += ",<<KEY_FILIAL_GW1_FILIAL>> 	AS BK_FILIAL "
cQuery += ",<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS>>    							AS BK_DOCCARGA "
cQuery += ",<<KEY_GWM_GWM.GWM_FILIAL+GWM.GWM_CDTPDC+GWM.GWM_EMISDC+GWM.GWM_SERDC+GWM.GWM_NRDC+GWM.GWM_DTEMIS+GWM.GWM_SEQGW8+GWM.GWM_ITEM>>  AS BK_ITEMDOCCARGA "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GWU.GWU_SEQ>> AS BK_TRECHODOCCARGA "
cQuery += ",<<KEY_GU3_GU3EMT.GU3_FILIAL+GU3EMT.GU3_CDEMIT>> 	AS BK_EMITENTE "
cQuery += ",<<KEY_GU3_GU3RMT.GU3_FILIAL+GU3RMT.GU3_CDEMIT>> 	AS BK_REMETENTE "
cQuery += ",<<KEY_GU3_GU3DST.GU3_FILIAL+GU3DST.GU3_CDEMIT>> 	AS BK_DESTINATARIO "
cQuery += " ,<<KEY_GU3_GU3TRP.GU3_FILIAL+GU3TRP.GU3_CDEMIT>> 	AS BK_TRANSPORTADOR "
cQuery += " ,<<KEY_GU7_GU7ORI.GU7_FILIAL+GU7ORI.GU7_NRCID>>  	AS BK_CIDADEORIGEM "
cQuery += " ,<<KEY_GU7_GU7DST.GU7_FILIAL+GU7DST.GU7_NRCID>>  	AS BK_CIDADEDESTINO "
//
cQuery += ", CASE "
cQuery += "   WHEN GWM.GWM_TPDOC = 1 THEN '1 - CALCULO FRETE' "
cQuery += "	  WHEN GWM.GWM_TPDOC = 2 THEN '2 - DOCUMENTO FRETE' "
cQuery += "   WHEN GWM.GWM_TPDOC = 3 THEN '3 - CONTRATO AUTONOMO' "
cQuery += "	  WHEN GWM.GWM_TPDOC = 4 THEN '4 - ESTIMATIVA FRETE' "
cQuery += "   ELSE '0 - NAO DEFINIDO' "
cQuery += '	END AS "TipoDocumentoRateio" '
//
cQuery += ', GW1.GW1_DTIMPL as "DataImplantacaoDocCarga" '
cQuery += ', GW3.GW3_DTENT AS "DataImplatcaoDocFrete" '
cQuery += ', GW3.GW3_DTEMIS AS "DataEmissaoDocFrete" '
cQuery += ', GW3.GW3_NRDF AS "NumeroDocFrete" '
cQuery += ', GW3.GW3_SERDF AS "SerieDocFrete" '
cQuery += ', GW3.GW3_VLDF  AS "ValorDocFrete" '
cQuery += ', GW3.GW3_VLIMP  AS "ValorIcmsDocFrete" '
cQuery += ', GW3.GW3_VLPIS  AS "ValorPisDocFrete" '
cQuery += ', GW3.GW3_VLCOF  AS "ValorCofinsDocFrete" '
cQuery += ",  RTRIM(GVT.GVT_CDESP)||' - '||GVT.GVT_DSESP  
cQuery += 'AS "EspecieDocFrete" '
cQuery += ", CASE "
cQuery += "    WHEN GW3.GW3_TPDF = '1' THEN '1 - NORMAL' "
cQuery += "    WHEN GW3.GW3_TPDF = '2' THEN '2 - COMPLEMENTAR VALOR' "
cQuery += "    WHEN GW3.GW3_TPDF = '3' THEN '3 - COMPLEMENTAR IMPOSTO' "
cQuery += "    WHEN GW3.GW3_TPDF = '4' THEN '4 - REENTREGA' "
cQuery += "    WHEN GW3.GW3_TPDF = '5' THEN '5 - DEVOLUCAO' "
cQuery += "    WHEN GW3.GW3_TPDF = '6' THEN '6 - REDESPACHO' "
cQuery += "    WHEN GW3.GW3_TPDF = '7' THEN '7 - SERVICO' "
cQuery += '  END AS "TipoDocFrete" '
cQuery += ", CASE "
cQuery += "    WHEN GW3.GW3_SIT = '3' THEN '3 - APROVADO SISTEMA' "
cQuery += "    WHEN GW3.GW3_SIT = '4' THEN '4 - APROVADO USUARIO' "
cQuery += '  END  AS "AprovacaoDocFrete" '
//
cQuery += ', GU3EFT.GU3_NMEMIT AS "EmitenteFaturaFrete" '
cQuery += ', GW6.GW6_SERFAT  AS "SerieFaturaFrete" '
cQuery += ', GW6.GW6_NRFAT AS "NumeroFaturaFrete" '
cQuery += ', GW6.GW6_DTEMIS AS "DataEmissaoFaturaFrete" '
cQuery += ', GW6.GW6_DTCRIA AS "DataImplantacaoFaturaFrete" '
cQuery += "	, CASE "
cQuery += "		WHEN GW6.GW6_SITAPR = 1 THEN '1 - RECEBIDA' "
cQuery += "		WHEN GW6.GW6_SITAPR = 2 THEN '2 - BLOQUEADA' "
cQuery += "		WHEN GW6.GW6_SITAPR = 3 THEN '3 - APROVADA SISTEMA' "
cQuery += "		WHEN GW6.GW6_SITAPR = 4 THEN '4 - APROVADA USUARIO' "
cQuery += "		ELSE '0 - NAO DEFINIDA' "
cQuery += '	 END AS "SituacaoFaturaFrete" '
cQuery += ', GW6.GW6_VLFATU  AS "ValorFaturaFrete" '
cQuery += ', GW6.GW6_VLDESC  AS "ValorDescontoFaturaFrete" '
cQuery += ', GW6.GW6_VLJURO  AS "ValorJurosFaturaFrete" '
//
if GFXCP12117('GW6_DINDEN')
   cQuery += ', GW6.GW6_DINDEN  AS "VlDescIndFaturaFrete" '
else 
   cQuery += ', 0 AS "VlDescIndFaturaFrete" '
end
//
cQuery += ", '' "
cQuery += 'AS "EmitenteContratoFrete" '
cQuery += ", '' "
cQuery +=' AS "NumeroContratoFrete" '
cQuery += ", '' 
cQuery += 'AS "DataEmissaoContratoFrete" '
cQuery += ", '' "
cQuery += 'AS "DataImplantacaoContratoFrete" '
cQuery += ", '' "
cQuery += 'AS "SituacaoContratoFrete" '
cQuery += ", 0  "
cQuery += 'AS "ValorContratoFrete" '
cQuery += ", 0  "
cQuery += 'AS "ValorDescontoContratoFrete" '
cQuery += ", 0  "
cQuery += 'AS "ValorAdicionalContratoFrete" '
//
cQuery += ', GW8.GW8_ITEM    AS "CodigoItemDocCarga" '
cQuery += ', GW8.GW8_DSITEM  AS "DescricaoItemDocCarga" '
cQuery += ', GW8.GW8_QTDE    AS "QuantidadeItemDocCarga" '
//
if GFXCP12117('GW8_UNIMED')
    cQuery += ',GW8.GW8_UNIMED         AS "UnidadeMedidaItemDocCarga" '
else
    cQuery += ",'  '                   "
	cQuery += 'AS "UnidadeMedidaItemDocCarga" '
end
//
cQuery += ', GW8.GW8_VALOR   AS "ValorItemDocCarga" '
cQuery += ', GW8.GW8_VOLUME  AS "VolumeItemDocCarga" '
cQuery += ', GW8.GW8_PESOC   AS "PesoCubadoItemDocCarga" '
cQuery += ', GW8.GW8_PESOR   AS "PesoItemDocCarga" '
cQuery += ', GW8.GW8_CFOP    AS "CfopItemDocCarga" '
cQuery += ', GW8.GW8_INFO1   AS "InfContabil_1_ItemDocCarga" '
cQuery += ', GW8.GW8_INFO2   AS "InfContabil_2_ItemDocCarga" '
cQuery += ', GW8.GW8_INFO3   AS "InfContabil_3_ItemDocCarga" '
cQuery += ', GW8.GW8_INFO4   AS "InfContabil_4_ItemDocCarga" '
cQuery += ', GW8.GW8_INFO5   AS "InfContabil_5_ItemDocCarga" '
cQuery += ', GW8.GW8_UNINEG  AS "UnidadeNegocioItemDocCarga" '
//
cQuery += ', GWM.GWM_UNINEG  AS "UnidadeNegocioRateio" '
cQuery += ', GWM.GWM_GRPCTB  AS "GrupoContabilRateio" '
cQuery += ', GWM.GWM_GRP1    AS "GrupoContabil1Rateio" '
cQuery += ', GWM.GWM_GRP2    AS "GrupoContabil2Rateio" '
cQuery += ', GWM.GWM_GRP3    AS "GrupoContabil3Rateio" '
cQuery += ', GWM.GWM_GRP4    AS "GrupoContabil4Rateio" '
cQuery += ', GWM.GWM_GRP5    AS "GrupoContabil5Rateio" '
cQuery += ', GWM.GWM_GRP6    AS "GrupoContabil6Rateio" '
cQuery += ', GWM.GWM_GRP7    AS "GrupoContabil7Rateio" '
//
cQuery += ', 0 AS "ValorFreteRateioCalculado" '
cQuery += ', 0 AS "ValorIcmsRateioCalculado" '
cQuery += ', 0 AS "ValorPisRateioCalculado" '
cQuery += ', 0 AS "ValorCofinsRateioCalculado" '
//
if SUPERGETMV('MV_CRIRAT',.F.,'1') = '1' //peso do item
	cQuery += ',GWM.GWM_VLFRET AS "ValorFreteRateioConhecimento" '
	cQuery += ',GWM.GWM_VLICMS AS "ValorIcmsRateioConhecimento" '
	cQuery += ',GWM.GWM_VLPIS  AS "ValorPisRateioConhecimento" '
	cQuery += ',GWM.GWM_VLCOFI AS "ValorCofinsRateioConhecimento" '
elseif SUPERGETMV('MV_CRIRAT',.F.,'1') = '2' //valor do item
	cQuery += ',GWM.GWM_VLFRE1 AS "ValorFreteRateioConhecimento" '
	cQuery += ',GWM.GWM_VLICM1 AS "ValorIcmsRateioConhecimento" '
	cQuery += ',GWM.GWM_VLPIS1 AS "ValorPisRateioConhecimento" '
	cQuery += ',GWM.GWM_VLCOF1 AS "ValorCofinsRateioConhecimento" '
elseif SUPERGETMV('MV_CRIRAT',.F.,'1') = '3' //volume(m³) do item
	cQuery += ',GWM.GWM_VLFRE3 AS "ValorFreteRateioConhecimento" '
	cQuery += ',GWM.GWM_VLICM3 AS "ValorIcmsRateioConhecimento" '
	cQuery += ',GWM.GWM_VLPIS3 AS "ValorPisRateioConhecimento" '
	cQuery += ',GWM.GWM_VLCOF3 AS "ValorCofinsRateioConhecimento" '
elseif SUPERGETMV('MV_CRIRAT',.F.,'1') = '4' //quantidade de itens
	cQuery += ',GWM.GWM_VLFRE2 AS "ValorFreteRateioConhecimento" '
	cQuery += ',GWM.GWM_VLICM2 AS "ValorIcmsRateioConhecimento" '
	cQuery += ',GWM.GWM_VLPIS2 AS "ValorPisRateioConhecimento" '
	cQuery += ',GWM.GWM_VLCOF2 AS "ValorCofinsRateioConhecimento" '
else // outros 
	cQuery += ',GWM.GWM_VLFRET AS "ValorFreteRateioConhecimento" '
	cQuery += ',GWM.GWM_VLICMS AS "ValorIcmsRateioConhecimento" '
	cQuery += ',GWM.GWM_VLPIS  AS "ValorPisRateioConhecimento" '
	cQuery += ',GWM.GWM_VLCOFI AS "ValorCofinsRateioConhecimento" '
End
//
cQuery += ', 0 AS "ValorFreteRateioContrato" '
cQuery += ', 0 AS "ValorIcmsRateioContrato" '
cQuery += ', 0 AS "ValorPisRateioContrato" '
cQuery += ', 0 AS "ValorCofinsRateioContrato" '
//
cQuery += ', 0 AS "ValorAjusteCalculo" '
///
cQuery += "  FROM <<GWU_COMPANY>>  GWU "
cQuery += " INNER JOIN <<GWM_COMPANY>>  GWM "
cQuery += "    ON GWM.GWM_FILIAL = <<SUBSTR_GWM_GWU_FILIAL>>  "
cQuery += "   AND GWM.GWM_CDTPDC = GWU.GWU_CDTPDC "
cQuery += "   AND GWM.GWM_EMISDC = GWU.GWU_EMISDC "
cQuery += "   AND GWM.GWM_SERDC  = GWU.GWU_SERDC "
cQuery += "   AND GWM.GWM_NRDC   = GWU.GWU_NRDC "
cQuery += "   AND GWM.GWM_CDTRP  = GWU.GWU_CDTRP "
cQuery += "	  AND GWM.GWM_TPDOC ='2' /*Calculado*/ "
cQuery += "   AND GWM.D_E_L_E_T_ = ' ' "
cQuery += "	INNER JOIN <<GW1_COMPANY>> GW1                       "
cQuery += "    ON GW1.GW1_FILIAL  = <<SUBSTR_GW1_GWM_FILIAL>> "
cQuery += "   AND GW1.GW1_CDTPDC  = GWM.GWM_CDTPDC "
cQuery += "   AND GW1.GW1_EMISDC  = GWM.GWM_EMISDC "
cQuery += "   AND GW1.GW1_SERDC   = GWM.GWM_SERDC "
cQuery += "   AND GW1.GW1_NRDC    = GWM.GWM_NRDC "
CqUERY += "   AND GW1.GW1_DTIMPL >= <<START_DATE>> "
CqUERY += "   AND GW1.GW1_DTIMPL <= <<FINAL_DATE>> "
cQuery += "   AND GW1.D_E_L_E_T_  = ' ' "
cQuery += " INNER JOIN <<GW8_COMPANY>> GW8 "
cQuery += "    ON GW8.GW8_FILIAL = <<SUBSTR_GW8_GW1_FILIAL>> "
cQuery += "   AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "   AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
cQuery += "   AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
cQuery += "   AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
cQuery += "   AND GW8.GW8_SEQ    = GWM.GWM_SEQGW8 "
cQuery += "   AND GW8.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GU3_COMPANY>> GU3EMT "
cQuery += "    ON GU3EMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "   AND GU3EMT.GU3_CDEMIT = GW1.GW1_EMISDC "
cQuery += "   AND GU3EMT.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GU3_COMPANY>> GU3RMT "
cQuery += "    ON GU3RMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "   AND GU3RMT.GU3_CDEMIT = GW1.GW1_CDREM "
cQuery += "   AND GU3RMT.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GU3_COMPANY>> GU3DST "
cQuery += "    ON GU3DST.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "   AND GU3DST.GU3_CDEMIT = GW1.GW1_CDDEST "
cQuery += "   AND GU3DST.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GU3_COMPANY>> GU3TRP "
cQuery += "    ON GU3TRP.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "   AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP "
cQuery += "   AND GU3TRP.D_E_L_E_T_ = ' ' "
cQuery += "  LEFT JOIN <<GU7_COMPANY>> GU7ORI "
cQuery += "    ON GU7ORI.GU7_FILIAL = <<SUBSTR_GU7_GW1_FILIAL>> "
cQuery += "   AND GU7ORI.GU7_NRCID  = GU3EMT.GU3_NRCID "
cQuery += "   AND GU7ORI.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GU7_COMPANY>> GU7DST "
cQuery += "    ON GU7DST.GU7_FILIAL = <<SUBSTR_GU7_GW1_FILIAL>> "
cQuery += "   AND GU7DST.GU7_NRCID  = GU3DST.GU3_NRCID "
cQuery += "   AND GU7DST.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN <<GW4_COMPANY>> GW4 "
cQuery += "    ON GW4.GW4_FILIAL = GWM.GWM_FILIAL "
cQuery += "   AND GW4.GW4_TPDC   = GWM.GWM_CDTPDC "
cQuery += "   AND GW4.GW4_EMISDC = GWM.GWM_EMISDC "
cQuery += "   AND GW4.GW4_SERDC  = GWM.GWM_SERDC "
cQuery += "   AND GW4.GW4_NRDC   = GWM.GWM_NRDC "
CqUERY += " INNER JOIN <<GW3_COMPANY>> GW3 "
CqUERY += "    ON GW3.GW3_FILIAL = <<SUBSTR_GW3_GW4_FILIAL>> "
CqUERY += "   AND GW3.GW3_EMISDF = GW4.GW4_EMISDF "
CqUERY += "   AND GW3.GW3_NRDF   = GW4.GW4_NRDF "
CqUERY += "   AND GW3.GW3_SERDF  = GW4.GW4_SERDF "
CqUERY += "   AND GW3.GW3_DTEMIS = GW4.GW4_DTEMIS "
CqUERY += "   AND GW3.GW3_SIT IN ('3', '4') /*APROVADO*/ "
CqUERY += "   AND  GW3.D_E_L_E_T_ = ' ' "
CqUERY += " INNER JOIN <<GVT_COMPANY>> GVT "
CqUERY += "    ON GVT.GVT_FILIAL = <<SUBSTR_GVT_GW3_FILIAL>> "
CqUERY += "   AND GVT.GVT_CDESP  = GW3.GW3_CDESP "
CqUERY += "   AND GVT.D_E_L_E_T_ = ' ' "
CqUERY += "  LEFT JOIN <<GW6_COMPANY>> GW6  "
CqUERY += "    ON GW6.GW6_FILIAL = <<SUBSTR_GW6_GW3_FILIAL>> "
CqUERY += "   AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT "
CqUERY += "   AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT "
CqUERY += "   AND GW6.GW6_SERFAT = GW3.GW3_SERFAT "
CqUERY += "   AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA "
CqUERY += "   AND GW6.GW6_SITAPR IN ('3','4') /*APROVADO*/ "
CqUERY += "   AND GW6.D_E_L_E_T_ = ' ' "
CqUERY += "  LEFT JOIN <<GU3_COMPANY>> GU3EFT  "
CqUERY += "    ON GU3EFT.GU3_FILIAL = <<SUBSTR_GU3_GW6_FILIAL>> "
CqUERY += "   AND GU3EFT.GU3_CDEMIT = GW6.GW6_EMIFAT "
CqUERY += "   AND GU3EFT.D_E_L_E_T_ = ' '  "
cQuery += " WHERE GWU.D_E_L_E_T_ = ' ' "
cQuery += "   AND GWU.GWU_PAGAR = 1 "

Return cQuery
