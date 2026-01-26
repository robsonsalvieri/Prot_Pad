#INCLUDE "BADEFINITION.CH"
//#INCLUDE "BADEFAPP.CH"

NEW ENTITY GFEOCORRENCIA
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAOcorrencia
Cadastro de Ocorrencia
 
@author romeu,.schiessel    
@since 08/11/2018
/*/
//-------------------------------------------------------------------
Class BAOcorrencia from BAEntity
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
METHOD Setup() Class BAOcorrencia
	_Super:Setup("OcorrenciaGFE", FACT, "GWD")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Ocorrencia
 @return cQuery, string, query a ser processada.
 
@author romeu,.schiessel
@since  08/11/2018
/*/
//-------------------------------------------------------------------
METHOD BuildQuery() Class BAOcorrencia
Local cQuery := ""

cQuery += "SELECT DISTINCT "
cQuery += " <<KEY_COMPANY>> 			AS BK_EMPRESA "
cQuery += ",<<KEY_FILIAL_GW1_FILIAL>> 	AS BK_FILIAL "
cQuery += ",<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS>>    				AS BK_DOCCARGA "
cQuery += " ,<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GWU.GWU_SEQ>> AS BK_TRECHODOCCARGA "
cQuery += ",<<KEY_GW1_GW1.GW1_FILIAL+GW1.GW1_CDTPDC+GW1.GW1_EMISDC+GW1.GW1_SERDC+GW1.GW1_NRDC+GW1.GW1_DTEMIS+GWL.GWL_NROCO>> 	AS BK_OCORRENCIA "
cQuery += ",<<KEY_GU3_GU3EMT.GU3_FILIAL+GU3EMT.GU3_CDEMIT>> AS BK_EMITENTE "
cQuery += ",<<KEY_GU3_GU3RMT.GU3_FILIAL+GU3RMT.GU3_CDEMIT>> AS BK_REMETENTE "
cQuery += ",<<KEY_GU3_GU3DST.GU3_FILIAL+GU3DST.GU3_CDEMIT>> AS BK_DESTINATARIO "
cQuery += " ,<<KEY_GU3_GU3TRP.GU3_FILIAL+GU3TRP.GU3_CDEMIT>> AS BK_TRANSPORTADOR "
cQuery += " ,<<KEY_GU7_GU7ORI.GU7_FILIAL+GU7ORI.GU7_NRCID>>  AS BK_CIDADEORIGEM "
cQuery += " ,<<KEY_GU7_GU7DST.GU7_FILIAL+GU7DST.GU7_NRCID>>  AS BK_CIDADEDESTINO "
cQuery += ',GWD.GWD_NROCO  	AS "NumeroOcorrencia" '
cQuery += ',GWD.GWD_DTCRIA  AS "DataRegistro" '
cQuery += ',GWD.GWD_DTOCOR  AS "DataOcorencia" '
cQuery += ",CASE  "                                                    
cQuery += "   WHEN GU5.GU5_EVENTO = 1 THEN '1 - CALCULO ADICIONAL'  "
cQuery += "   WHEN GU5.GU5_EVENTO = 2 THEN '2 - CANCELAMENTO FRETE' "
cQuery += "   WHEN GU5.GU5_EVENTO = 3 THEN '3 - SIMPLES REGISTRO' "  
cQuery += "   WHEN GU5.GU5_EVENTO = 4 THEN '4 - REGISTRAR ENTREGA' " 
cQuery += "   ELSE '0 - NAO DEFINIDO' "                               
cQuery += ' END AS "EventoOcorrencia" '                              
cQuery += ",RTRIM(GWD_CDTIPO)||' - '||GU5.GU5_DESC  "
cQuery += 'AS "TipoOcorrencia" '
cQuery += ",RTRIM(GWD.GWD_CDMOT)||' - '||GU6.GU6_DESC  "
cQuery += 'AS "MotivoOcorrencia" '
cQuery += ",CASE "
cQuery += "   WHEN GU6.GU6_PROVOC = '1' THEN '1 - TRANSPORTADOR' "
cQuery += "   WHEN GU6.GU6_PROVOC = '2' THEN '2 - REMETENTE' "
cQuery += "   WHEN GU6.GU6_PROVOC = '3' THEN '3 - DESTINATARIO' "
cQuery += "   WHEN GU6.GU6_PROVOC = '4' THEN '4 - OUTRO' "
cQuery += ' END                          	AS "ProvocadorOcorrencia" '

If GFXCP12121("GWD_PESO")
    cQuery += ',GWD.GWD_PESO 			AS "PesoAferidoGranel" '
else
    cQuery += ',0 						AS "PesoAferidoGranel" '
end

cQuery += ',COALESCE(GWFI.GWFI_VLFRET,0) 	AS "ValorOcorrencia" '
cQuery += " FROM <<GWD_COMPANY>> GWD "
cQuery += " LEFT JOIN <<GWL_COMPANY>> GWL "
cQuery += "   ON GWL.GWL_FILIAL  = <<SUBSTR_GWD_GWL_FILIAL>> "
cQuery += "  AND GWL.GWL_NROCO   = GWD.GWD_NROCO "
cQuery += "  AND GWL.D_E_L_E_T_  = ' ' "
cQuery += " LEFT JOIN <<GW1_COMPANY>> GW1 "
cQuery += "   ON GW1.GW1_FILIAL  = <<SUBSTR_GW1_GWL_FILDC>>  "
cQuery += "  AND GW1.GW1_CDTPDC  = GWL.GWL_TPDC "
cQuery += "  AND GW1.GW1_EMISDC  = GWL.GWL_EMITDC "
cQuery += "  AND GW1.GW1_SERDC   = GWL.GWL_SERDC "
cQuery += "  AND GW1.GW1_NRDC    = GWL.GWL_NRDC "
cQuery += "  AND GW1.D_E_L_E_T_  = ' ' "
cQuery += " LEFT JOIN (SELECT GWF_FILIAL                  AS GWFI_FILIAL "
cQuery += "                  ,GWF_NROCO                   AS GWFI_NROCO "
cQuery += "                  ,SUM(COALESCE(GWF_VLAJUS,0)) AS GWFI_VLAJUS "
cQuery += "                  ,SUM(COALESCE(GWI_VLFRET,0)) AS GWFI_VLFRET "
cQuery += "              FROM <<GWF_COMPANY>> GWF "
cQuery += "             INNER JOIN <<GWI_COMPANY>> GWI "
cQuery += "                ON GWI.GWI_TOTFRE = '1' "
cQuery += "               AND GWI.GWI_FILIAL = <<SUBSTR_GWI_GWF_FILIAL>> "
cQuery += "               AND GWI.GWI_NRCALC = GWF.GWF_NRCALC "
cQuery += "               AND GWI.D_E_L_E_T_ = ' ' "
cQuery += "             WHERE GWF.D_E_L_E_T_ = ' ' "
cQuery += "             GROUP BY GWF_FILIAL "
cQuery += "                     ,GWF_NROCO "
cQuery += "           ) GWFI "
cQuery += "   ON GWFI.GWFI_FILIAL = <<SUBSTR_GWF_GWD_FILIAL>> "
cQuery += "  AND GWFI.GWFI_NROCO  = GWD.GWD_NROCO "
cQuery += "INNER JOIN <<GU5_COMPANY>> GU5 "
cQuery += "   ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO "
cQuery += "  AND GU5.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU6_COMPANY>> GU6 "
cQuery += "   ON GU6.GU6_FILIAL = <<SUBSTR_GU6_GWD_FILIAL>> "
cQuery += "  AND GU6.GU6_CDMOT  = GWD.GWD_CDMOT "
cQuery += "  AND GU6.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GWN_COMPANY>> GWN "
cQuery += "   ON GWN.GWN_FILIAL = <<SUBSTR_GWN_GW1_FILIAL>> "
cQuery += "  AND GWN.GWN_NRROM  = GW1.GW1_NRROM "
cQuery += "  AND GWN.D_E_L_E_T_ = ' ' "
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
cQuery += "INNER JOIN <<GWU_COMPANY>> GWU "
cQuery += "   ON GWU.GWU_FILIAL = <<SUBSTR_GWU_GW1_FILIAL>> "
cQuery += "  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
cQuery += "  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
cQuery += "  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
cQuery += "  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
cQuery += "  AND GWU.GWU_CDTRP  = GWD.GWD_CDTRP "
cquery += "  AND GWU.GWU_PAGAR  = 1 "
cQuery += "  AND GWU.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3EMT "
cQuery += "   ON GU3EMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3EMT.GU3_CDEMIT = GW1.GW1_EMISDC "
cQuery += "  AND GU3EMT.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN <<GU7_COMPANY>> GU7ORI "
cQuery += "   ON GU7ORI.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7ORI.GU7_NRCID  = COALESCE(RTRIM(NULLIF(GWU.GWU_NRCIDO , ' ')) , GU3EMT.GU3_NRCID)"
cQuery += "  AND GU7ORI.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU7_COMPANY>> GU7DST "
cQuery += "   ON GU7DST.GU7_FILIAL = <<SUBSTR_GU7_GWU_FILIAL>> "
cQuery += "  AND GU7DST.GU7_NRCID  = GWU.GWU_NRCIDD "
cQuery += "  AND GU7DST.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3TRP "
cQuery += "   ON GU3TRP.GU3_FILIAL = <<SUBSTR_GU3_GWU_FILIAL>> "
cQuery += "  AND GU3TRP.GU3_CDEMIT = COALESCE(RTRIM(NULLIF(GWD.GWD_CDTRP , ' ')) , GWU.GWU_CDTRP) "
cQuery += "  AND GU3TRP.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3RMT "
cQuery += "   ON GU3RMT.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3RMT.GU3_CDEMIT = GW1.GW1_CDREM "
cQuery += "  AND GU3RMT.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN <<GU3_COMPANY>> GU3DST "
cQuery += "   ON GU3DST.GU3_FILIAL = <<SUBSTR_GU3_GW1_FILIAL>> "
cQuery += "  AND GU3DST.GU3_CDEMIT = GW1.GW1_CDDEST "
cQuery += "  AND GU3DST.D_E_L_E_T_ = ' ' "
cQuery += "WHERE GWD.D_E_L_E_T_    = ' ' "
cQuery += "  AND GW1.GW1_DTIMPL >= <<START_DATE>> "
cQuery += "  AND GW1.GW1_DTIMPL <= <<FINAL_DATE>> "


Return cQuery
