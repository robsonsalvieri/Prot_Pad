#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY TRECHODOCUMENTOCARGAGFE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BATrechoDocumentoCarga
Cadastro de TrechoDocumentoCarga
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BATrechoDocumentoCarga from BAEntity
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
METHOD Setup() Class BATrechoDocumentoCarga
	_Super:Setup("TrechoDocumentoCargaGFE", FACT, "GWD")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
TrechoDocumentoCarga
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BATrechoDocumentoCarga
Local cQuery := ""

cQuery += " SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA "
cQuery += " ,<<KEY_FILIAL_GW1_FILIAL>> AS BK_FILIAL "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS>>    		   	AS BK_DOCCARGA "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GWU.GWU_SEQ>> AS BK_TRECHODOCCARGA "
cQuery += ",<<KEY_GU3_GU3EMT.GU3_FILIAL+GU3EMT.GU3_CDEMIT>> 	AS BK_EMITENTE "
cQuery += ",<<KEY_GU3_GU3RMT.GU3_FILIAL+GU3RMT.GU3_CDEMIT>> 	AS BK_REMETENTE "
cQuery += ",<<KEY_GU3_GU3DST.GU3_FILIAL+GU3DST.GU3_CDEMIT>> 	AS BK_DESTINATARIO "
cQuery += " ,<<KEY_GU3_GU3TRP.GU3_FILIAL+GU3TRP.GU3_CDEMIT>> 	AS BK_TRANSPORTADOR "
cQuery += " ,<<KEY_GU7_GU7ORI.GU7_FILIAL+GU7ORI.GU7_NRCID>>  	AS BK_CIDADEORIGEM "
cQuery += " ,<<KEY_GU7_GU7DST.GU7_FILIAL+GU7DST.GU7_NRCID>>  	AS BK_CIDADEDESTINO "
cQuery += ' ,GW1.GW1_DTIMPL      								AS DataImplantacaoDocCarga '
cQuery += ' ,GWU.GWU_SEQ                                        AS SequenciaTrechoDocCarga '
cQuery += " ,CASE "
cQuery += "    WHEN GWU.GWU_PAGAR = '1' THEN '1 - PAGAR' "
cQuery += "    WHEN GWU.GWU_PAGAR = '2' THEN '2 - PAGO' "
cQuery += "    ELSE '0 - ERRO'  "
cQuery += '  END AS FreteTrechoDocCarga '
cQuery += ' ,GW1.GW1_DTLIB  	AS DataLiberacaoDocCarga '
cQuery += ' ,GW1.GW1_DTPENT  	AS DataPrevistaEntregaDocCarga '
cQuery += ' ,GWUDT.GWU_DTENT 	AS DataEntregaDocCarga '
cQuery += ' ,GWUDT.GWU_DTCALC 	AS DataEfetivaEntregaDocCarga '
cQuery += " ,CASE "
cQuery += "   WHEN GW1.GW1_DTPENT = '        '                                  	   THEN '0 - SEM DATA PREVISTA' "
cQuery += "   WHEN GW1.GW1_DTPENT = GWUDT.GWU_DTCALC AND GWUDT.GWU_DTENT <> '        ' THEN '1 - ENTREGUE NO PRAZO' "
cQuery += "   WHEN GW1.GW1_DTPENT < GWUDT.GWU_DTCALC AND GWUDT.GWU_DTENT <> '        ' THEN '2 - ENTREGUE COM ATRASO' "
cQuery += "   WHEN GW1.GW1_DTPENT > GWUDT.GWU_DTCALC AND GWUDT.GWU_DTENT <> '        ' THEN '3 - ENTREGUE ANTECIPADO' "
If TcGetDB() == 'ORACLE'
    cQuery += "   WHEN GW1.GW1_DTPENT < TO_CHAR(sysdate, 'YYYYMMDD') AND GWUDT.GWU_DTENT = '        ' THEN '4 - EM TRANSITO - FORA DO PRAZO' "
    cQuery += "   WHEN GW1.GW1_DTPENT > TO_CHAR(sysdate, 'YYYYMMDD') AND GWUDT.GWU_DTENT = '        ' THEN '5 - EM TRANSITO - DENTRO DO PRAZO' "
Else
    cQuery += "   WHEN GW1.GW1_DTPENT < CONVERT(VARCHAR,GETDATE(),112) AND GWUDT.GWU_DTENT = '        ' THEN '4 - EM TRANSITO - FORA DO PRAZO' "
    cQuery += "   WHEN GW1.GW1_DTPENT > CONVERT(VARCHAR,GETDATE(),112) AND GWUDT.GWU_DTENT = '        ' THEN '5 - EM TRANSITO - DENTRO DO PRAZO' "
EndIf
cQuery += ' END AS EficienciaDocCarga '
cQuery += ' ,GWU.GWU_DTPENT AS DtPrevEntTrechoDocCarga '
cQuery += ' ,GWU.GWU_DTENT  AS DataEntregaTrechoDocCarga '
If TcGetDB() == 'ORACLE'
    cQuery += " ,CASE WHEN GWU.GWU_DTENT= '        ' THEN TO_CHAR(sysdate, 'YYYYMMDD') ELSE GWU.GWU_DTENT END"
Else
    cQuery += " ,IIF(GWU.GWU_DTENT= '        ',CONVERT(VARCHAR,GETDATE(),112),GWU.GWU_DTENT ) "
EndIf
cQuery += ' AS DtEfetivEntrSeqDocCarga '
cQuery += ",CASE "
cQuery += "   WHEN GWU.GWU_DTPENT = '        ' 									  THEN '0 - SEM DATA PREVISTA' "
cQuery += "   WHEN GWU.GWU_DTPENT = GWU.GWU_DTENT AND GWU.GWU_DTENT <> '        ' THEN '1 - ENTREGUE NO PRAZO' "
cQuery += "   WHEN GWU.GWU_DTPENT < GWU.GWU_DTENT AND GWU.GWU_DTENT <> '        ' THEN '2 - ENTREGUE COM ATRASO' "
cQuery += "   WHEN GWU.GWU_DTPENT > GWU.GWU_DTENT AND GWU.GWU_DTENT <> '        ' THEN '3 - ENTREGUE ANTECIPADO' "
If TcGetDB() == 'ORACLE'
    cQuery += "   WHEN GWU.GWU_DTPENT < TO_CHAR(sysdate, 'YYYYMMDD') AND GWU.GWU_DTENT = '        ' THEN '4 - EM TRANSITO - FORA DO PRAZO' "
    cQuery += "   WHEN GWU.GWU_DTPENT > TO_CHAR(sysdate, 'YYYYMMDD') AND GWU.GWU_DTENT = '        ' THEN '5 - EM TRANSITO - DENTRO DO PRAZO' "
Else
    cQuery += "   WHEN GWU.GWU_DTPENT < CONVERT(VARCHAR,GETDATE(),112) AND GWU.GWU_DTENT = '        ' THEN '4 - EM TRANSITO - FORA DO PRAZO' "
    cQuery += "   WHEN GWU.GWU_DTPENT > CONVERT(VARCHAR,GETDATE(),112) AND GWU.GWU_DTENT = '        ' THEN '5 - EM TRANSITO - DENTRO DO PRAZO' "
EndIf
cQuery += ' END AS EficienciaTrechoDocCarga '
cQuery += " FROM <<GW1_COMPANY>> GW1 "
cQuery += "INNER JOIN <<GWU_COMPANY>> GWU "
cQuery += "   ON GWU.GWU_FILIAL = <<SUBSTR_GWU_GW1_FILIAL>>  "
cQuery += "  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
cQuery += "  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
cQuery += "  AND GWU.GWU_PAGAR  = 1 "
cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN (SELECT GWUDTE.GWU_FILIAL "
cQuery += "                  ,GWUDTE.GWU_CDTPDC "
cQuery += "                  ,GWUDTE.GWU_EMISDC "
cQuery += "                  ,GWUDTE.GWU_SERDC "
cQuery += "                  ,GWUDTE.GWU_NRDC "
cQuery += "                  ,GWUDTE.GWU_CDTRP "
cQuery += "                  ,GWUDTE.GWU_DTENT "
cQuery += "                  ,GWUDTE.GWU_SEQ "
cQuery += "                  ,CASE "
If TcGetDB() == 'ORACLE'
    cQuery += "                     WHEN GWUDTE.GWU_DTENT = '        ' THEN TO_CHAR(sysdate, 'YYYYMMDD') "
Else
    cQuery += "                     WHEN GWUDTE.GWU_DTENT = '        ' THEN CONVERT(VARCHAR,GETDATE(),112) "
EndIf
cQuery += "                   ELSE GWUDTE.GWU_DTENT "
cQuery += "                   END GWU_DTCALC "
cQuery += "              FROM <<GWU_COMPANY>> GWUDTE "
cQuery += "             WHERE GWUDTE.D_E_L_E_T_ = ' ' "
cQuery += "               AND GWUDTE.GWU_SEQ = (SELECT MAX(GWUMX.GWU_SEQ) "
cQuery += "                                       FROM <<GWU_COMPANY>> GWUMX "
cQuery += "                                      WHERE GWUMX.GWU_FILIAL = GWUDTE.GWU_FILIAL "
cQuery += "                                        AND GWUMX.GWU_CDTPDC = GWUDTE.GWU_CDTPDC "
cQuery += "                                        AND GWUMX.GWU_EMISDC = GWUDTE.GWU_EMISDC "
cQuery += "                                        AND GWUMX.GWU_SERDC = GWUDTE.GWU_SERDC "
cQuery += "                                        AND GWUMX.GWU_NRDC = GWUDTE.GWU_NRDC "
cQuery += "                                        AND GWUMX.GWU_CDTRP = GWUDTE.GWU_CDTRP "
cQuery += "                                        AND GWUMX.D_E_L_E_T_ = ' ' "
cQuery += "                                    ) "
cQuery += "           ) GWUDT "
cQuery += "   ON GWUDT.GWU_FILIAL = <<SUBSTR_GWU_GW1_FILIAL>> "
cQuery += "  AND GWUDT.GWU_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GWUDT.GWU_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GWUDT.GWU_SERDC = GW1.GW1_SERDC "
cQuery += "  AND GWUDT.GWU_NRDC = GW1.GW1_NRDC "
cQuery += "  AND GWUDT.GWU_SEQ = GWU.GWU_SEQ "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3EMT "
cQuery += "   ON GU3EMT.GU3_FILIAL = <<SUBSTR_GU3_GWU_FILIAL>> "
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
cQuery += " LEFT JOIN <<GU7_COMPANY>> GU7ORI "
cQuery += "   ON GU7ORI.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7ORI.GU7_NRCID = COALESCE(RTRIM(NULLIF(GWU.GWU_NRCIDO,' ')),GU3EMT.GU3_NRCID) "
cQuery += "  AND GU7ORI.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU7_COMPANY>> GU7DST "
cQuery += "   ON GU7DST.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7DST.GU7_NRCID = GWU.GWU_NRCIDD "
cQuery += "  AND GU7DST.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3TRP "
cQuery += "   ON GU3TRP.GU3_FILIAL = <<SUBSTR_GU3_GWU_FILIAL>> "
cQuery += "  AND GU3TRP.GU3_CDEMIT = GWU.GWU_CDTRP "
cQuery += "  AND GU3TRP.D_E_L_E_T_ = ' ' "
cQuery += "WHERE GW1.D_E_L_E_T_ = ' ' "
cQuery += "  AND GW1.GW1_DTIMPL >= <<START_DATE>> "
cQuery += "  AND GW1.GW1_DTIMPL <= <<FINAL_DATE>> "

Return cQuery
