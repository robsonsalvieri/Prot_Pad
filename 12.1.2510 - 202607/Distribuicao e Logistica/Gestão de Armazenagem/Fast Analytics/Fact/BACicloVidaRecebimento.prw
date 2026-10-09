#INCLUDE "BADEFINITION.CH"

NEW ENTITY CICVIDRECEBIMENTO
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BACicloVidaRecebimento
Visualiza as informações de Ciclo de Vida de Recebimento
 
@author   jackson.werka
@since    20/08/2018
/*/
//-------------------------------------------------------------------
Class BACicloVidaRecebimento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.
 
@author  jackson.werka
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACicloVidaRecebimento
	_Super:Setup("CicloVidaRecebimento", FACT, "SF1")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   20/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACicloVidaRecebimento
Local cQuery := ""

	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_DCF_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " 'SOLTO' AS TIP_PROCESSO,"
	cQuery +=       " DCF.DCF_DOCTO AS NOTA_FISCAL,"
	cQuery +=       " DCF.DCF_SERIE AS SERIE_NOTA_FISCAL,"
	cQuery +=       " <<KEY_SA2_A2_FILIAL+DCF_CLIFOR+DCF_LOJA>> AS BK_FORNECEDOR,"
	cQuery +=       " (SELECT MIN(DCFC.DCF_DATA || ' ' || DCFC.DCF_HORA)" // Menor Data/Hora de integração da conferencia convocada no WMS
	cQuery +=         "  FROM <<DCF_COMPANY>> DCFC"
	cQuery +=         " INNER JOIN <<D12_COMPANY>> D12"
	cQuery +=         "    ON D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery +=         "   AND D12.D12_IDDCF = DCFC.DCF_ID"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE DCFC.DCF_FILIAL = DCF.DCF_FILIAL"
	cQuery +=         "   AND DCFC.DCF_DOCTO = DCF.DCF_DOCTO"
	cQuery +=         "   AND DCFC.DCF_SERIE = DCF.DCF_SERIE"
	cQuery +=         "   AND DCFC.DCF_CLIFOR = DCF.DCF_CLIFOR"
	cQuery +=         "   AND DCFC.DCF_LOJA = DCF.DCF_LOJA"
	cQuery +=         "   AND DCFC.DCF_ORIGEM = 'SD1'"
	cQuery +=         "   AND DCFC.DCF_STSERV <> '0'"
	cQuery +=         "   AND DCFC.D_E_L_E_T_ = ' ' ) AS DATHOR_COF_CONV,"
	cQuery +=       " (SELECT MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI)" // Menor Data/Hora de inicio da conferencia convocada no WMS
	cQuery +=         "  FROM <<D12_COMPANY>> D12"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery +=         "   AND D12.D12_DOC = DCF.DCF_DOCTO"
	cQuery +=         "   AND D12.D12_SERIE = DCF.DCF_SERIE"
	cQuery +=         "   AND D12.D12_CLIFOR = DCF.DCF_CLIFOR"
	cQuery +=         "   AND D12.D12_LOJA = DCF.DCF_LOJA"
	cQuery +=         "   AND D12.D12_ORIGEM = 'SD1'"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' ') AS DATHOR_INI_COFC,"
	cQuery +=       " (SELECT MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM)" // Maior Data/Hora de final da conferência convocada no WMS
	cQuery +=         "  FROM <<D12_COMPANY>> D12"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery +=         "   AND D12.D12_DOC = DCF.DCF_DOCTO"
	cQuery +=         "   AND D12.D12_SERIE = DCF.DCF_SERIE"
	cQuery +=         "   AND D12.D12_CLIFOR = DCF.DCF_CLIFOR"
	cQuery +=         "   AND D12.D12_LOJA = DCF.DCF_LOJA"
	cQuery +=         "   AND D12.D12_ORIGEM = 'SD1'"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' ') AS DATHOR_FIM_COFC,"
	cQuery +=       " NULL AS DATHOR_INT_UNT," // Menor Data/Hora de geração da demanda de unitização
	cQuery +=       " MAX(DCW.DCW_DATGER || ' ' || DCW.DCW_HORGER) AS DATHOR_COF_RECB," // Maior Data/Hora de geração da conferência do recebimento
	cQuery +=       " NULL AS DATHOR_INI_COFR," // Menor Data/Hora de inicio da Unitização/Conferência
	cQuery +=       " NULL AS DATHOR_FIM_COFR," // Maior Data/Hora de finalização da Unitização/Conferência
	cQuery +=       " MIN(DCF.DCF_DATA   || ' ' || DCF.DCF_HORA)   AS DATHOR_INT_WMS," // Menor Data/Hora de integração do endereçamento com o WMS
	cQuery +=       " MIN(D12.D12_DTGERA || ' ' || D12.D12_HRGERA) AS DATHOR_EXE_WMS," // Menor Data/Hora de execução da ordem de serviço do WMS
	cQuery +=       " MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI) AS DATHOR_INI_END," // Menor Data/Hora de inicio do endereçamento no WMS
	cQuery +=       " MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM) AS DATHOR_FIM_END," // Maior Data/Hora de final do endereçamento no WMS
	cQuery +=       " MAX(D12.D12_DATFIM) AS DATA_EXTRACAO"
	cQuery +=  " FROM <<DCF_COMPANY>> DCF"
	cQuery += " INNER JOIN <<SF1_COMPANY>> SF1"
	cQuery += "    ON SF1.F1_FILIAL = <<SUBSTR_SF1_DCF_FILIAL>>"
	cQuery += "   AND SF1.F1_DOC = DCF.DCF_DOCTO"
	cQuery += "   AND SF1.F1_SERIE = DCF.DCF_SERIE"
	cQuery += "   AND SF1.F1_FORNECE = DCF.DCF_CLIFOR"
	cQuery += "   AND SF1.F1_LOJA = DCF.DCF_LOJA"
	cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DCR_COMPANY>> DCR"
	cQuery += "    ON DCR.DCR_FILIAL = <<SUBSTR_DCR_DCF_FILIAL>>"
	cQuery += "   AND DCR.DCR_IDDCF = DCF.DCF_ID"
	cQuery += "   AND DCR.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<D12_COMPANY>> D12"
	cQuery += "    ON D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery += "   AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery += "   AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery += "   AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery += "   AND D12.D12_STATUS <> '0'"
	cQuery += "   AND D12.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery += "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery += "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery += "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery += "   AND DC5.DC5_OPERAC IN ('1','2')"
	cQuery += "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DCX_COMPANY>> DCX"
	cQuery += "    ON DCX.DCX_FILIAL = <<SUBSTR_DCX_F1_FILIAL>>"
	cQuery += "   AND DCX.DCX_DOC = SF1.F1_DOC"
	cQuery += "   AND DCX.DCX_SERIE = SF1.F1_SERIE"
	cQuery += "   AND DCX.DCX_FORNEC = SF1.F1_FORNECE"
	cQuery += "   AND DCX.DCX_LOJA = SF1.F1_LOJA"
	cQuery += "   AND DCX.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DCW_COMPANY>> DCW"
	cQuery += "    ON DCW.DCW_FILIAL = <<SUBSTR_DCW_DCX_FILIAL>>"
	cQuery += "   AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ"
	cQuery += "   AND DCW.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SA2_COMPANY>> SA2"
	cQuery += "    ON SA2.A2_FILIAL = <<SUBSTR_SA2_DCF_FILIAL>>"
	cQuery += "   AND SA2.A2_COD = DCF.DCF_CLIFOR"
	cQuery += "   AND SA2.A2_LOJA = DCF.DCF_LOJA"
	cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCF.DCF_ORIGEM = 'SD1'"
	cQuery +=   " AND DCF.DCF_STSERV <> '0'"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=   " AND D12.D12_DATFIM >= <<START_DATE>>"
	cQuery +=   " AND D12.D12_DATFIM <= <<FINAL_DATE>>"
	cQuery +=   " AND NOT EXISTS (SELECT 1 " // Não pode existir nenhuma quantidade pendente de endereçamento
	cQuery +=                    "  FROM <<DCF_COMPANY>> DCFB"
	cQuery +=                    " INNER JOIN <<DCR_COMPANY>> DCRB"
	cQuery +=                    "    ON DCRB.DCR_FILIAL = <<SUBSTR_DCR_DCF_FILIAL>>"
	cQuery +=                    "   AND DCRB.DCR_IDDCF = DCFB.DCF_ID"
	cQuery +=                    "   AND DCFB.D_E_L_E_T_ = ' '"
	cQuery +=                    " INNER JOIN <<D12_COMPANY>> D12B"
	cQuery +=                    "    ON D12B.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery +=                    "   AND D12B.D12_IDDCF = DCRB.DCR_IDORI"
	cQuery +=                    "   AND D12B.D12_IDMOV = DCRB.DCR_IDMOV"
	cQuery +=                    "   AND D12B.D12_IDOPER = DCRB.DCR_IDOPER"
	cQuery +=                    "   AND D12B.D12_STATUS IN ('2','3','4')"
	cQuery +=                    "   AND D12B.D_E_L_E_T_ = ' '"
	cQuery +=                    " WHERE DCFB.DCF_FILIAL = DCF.DCF_FILIAL"
	cQuery +=                      " AND DCFB.DCF_DOCTO = DCF.DCF_DOCTO"
	cQuery +=                      " AND DCFB.DCF_SERIE = DCF.DCF_SERIE"
	cQuery +=                      " AND DCFB.DCF_CLIFOR = DCF.DCF_CLIFOR"
	cQuery +=                      " AND DCFB.DCF_LOJA = DCF.DCF_LOJA"
	cQuery +=                      " AND DCFB.DCF_ORIGEM = DCF.DCF_ORIGEM"
	cQuery +=                      " AND DCFB.DCF_STSERV <> '0'"
	cQuery +=                      " AND DCFB.D_E_L_E_T_ = ' ')"
	cQuery += " GROUP BY DCF.DCF_FILIAL,"
	cQuery +=          " DCF.DCF_DOCTO,"
	cQuery +=          " DCF.DCF_SERIE,"
	cQuery +=          " DCF.DCF_CLIFOR,"
	cQuery +=          " DCF.DCF_LOJA,"
	cQuery +=          " DCW.DCW_EMBARQ,"
	cQuery +=          " SA2.A2_FILIAL"
	cQuery += " UNION ALL "
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_D0Q_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " 'UNITIZADO' AS TIP_PROCESSO,"
	cQuery +=       " D0Q.D0Q_DOCTO AS NOTA_FISCAL,"
	cQuery +=       " D0Q.D0Q_SERIE AS SERIE_NOTA_FISCAL,"
	cQuery +=       " <<KEY_SA2_A2_FILIAL+D0Q_CLIFOR+D0Q_LOJA>> AS BK_FORNECEDOR,"
	cQuery +=       " (SELECT MIN(DCFC.DCF_DATA || ' ' || DCFC.DCF_HORA)" // Menor Data/Hora de integração da conferencia convocada no WMS
	cQuery +=         "  FROM <<DCF_COMPANY>> DCFC"
	cQuery +=         "  INNER JOIN <<D12_COMPANY>> D12"
	cQuery +=         "    ON D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery +=         "   AND D12.D12_IDDCF = DCFC.DCF_ID"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE DCFC.DCF_FILIAL = <<SUBSTR_DCF_D0Q_FILIAL>>"
	cQuery +=         "   AND DCFC.DCF_DOCTO = D0Q.D0Q_DOCTO"
	cQuery +=         "   AND DCFC.DCF_SERIE = D0Q.D0Q_SERIE"
	cQuery +=         "   AND DCFC.DCF_CLIFOR = D0Q.D0Q_CLIFOR"
	cQuery +=         "   AND DCFC.DCF_LOJA = D0Q.D0Q_LOJA"
	cQuery +=         "   AND DCFC.DCF_ORIGEM = 'SD1'"
	cQuery +=         "   AND DCFC.DCF_STSERV <> '0'"
	cQuery +=         "   AND DCFC.D_E_L_E_T_ = ' ' ) AS DATHOR_COF_CONV,"
	cQuery +=       " (SELECT MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI) " // Menor Data/Hora de inicio da conferencia convocada no WMS
	cQuery +=         "  FROM <<D12_COMPANY>> D12"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE D12.D12_FILIAL = <<SUBSTR_D12_D0Q_FILIAL>>"
	cQuery +=         "   AND D12.D12_DOC = D0Q.D0Q_DOCTO"
	cQuery +=         "   AND D12.D12_SERIE = D0Q.D0Q_SERIE"
	cQuery +=         "   AND D12.D12_CLIFOR = D0Q.D0Q_CLIFOR"
	cQuery +=         "   AND D12.D12_LOJA = D0Q.D0Q_LOJA"
	cQuery +=         "   AND D12.D12_ORIGEM = 'SD1'"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' ' ) AS DATHOR_INI_COFC,"
	cQuery +=       " (SELECT MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM)" // Maior Data/Hora de final da conferência convocada no WMS
	cQuery +=         "  FROM <<D12_COMPANY>> D12"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '6'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE D12.D12_FILIAL = <<SUBSTR_D12_D0Q_FILIAL>>"
	cQuery +=         "   AND D12.D12_DOC = D0Q.D0Q_DOCTO"
	cQuery +=         "   AND D12.D12_SERIE = D0Q.D0Q_SERIE"
	cQuery +=         "   AND D12.D12_CLIFOR = D0Q.D0Q_CLIFOR"
	cQuery +=         "   AND D12.D12_LOJA = D0Q.D0Q_LOJA"
	cQuery +=         "   AND D12.D12_ORIGEM = 'SD1'"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' ') AS DATHOR_FIM_COFC,"
	cQuery +=       " MIN(D0Q.D0Q_DATA   || ' ' || D0Q.D0Q_HORA)   AS DATHOR_INT_UNT,"  // Menor Data/Hora de geração da demanda de unitização
	cQuery +=       " MAX(DCW.DCW_DATGER || ' ' || DCW.DCW_HORGER) AS DATHOR_COF_RECB," // Maior Data/Hora de geração da conferência do recebimento
	cQuery +=       " MIN(D0R.D0R_DATINI || ' ' || D0R.D0R_HORINI) AS DATHOR_INI_UNIT," // Menor Data/Hora de inicio da Unitização/Conferência
	cQuery +=       " MAX(D0R.D0R_DATFIM || ' ' || D0R.D0R_HORFIM) AS DATHOR_FIM_UNIT," // Maior Data/Hora de finalização da Unitização/Conferência
	cQuery +=       " MIN(DCF.DCF_DATA   || ' ' || DCF.DCF_HORA)   AS DATHOR_INT_WMS,"  // Menor Data/Hora de integração do endereçamento com o WMS
	cQuery +=       " MIN(D12.D12_DTGERA || ' ' || D12.D12_HRGERA) AS DATHOR_EXE_WMS,"  // Menor Data/Hora de execução da ordem de serviço do WMS
	cQuery +=       " MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI) AS DATHOR_INI_END,"  // Menor Data/Hora de inicio do endereçamento no WMS
	cQuery +=       " MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM) AS DATHOR_FIM_END,"  // Maior Data/Hora de final do endereçamento no WMS
	cQuery +=       " MAX(D12.D12_DATFIM) AS DATA_EXTRACAO" 
	cQuery += "  FROM <<D0Q_COMPANY>> D0Q"
	cQuery += " INNER JOIN <<D0S_COMPANY>> D0S"
	cQuery += "    ON D0S.D0S_FILIAL = <<SUBSTR_D0S_D0Q_FILIAL>>"
	cQuery += "   AND D0S.D0S_IDD0Q = D0Q.D0Q_ID"
	cQuery += "   AND D0S.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<D0R_COMPANY>> D0R"
	cQuery += "    ON D0R.D0R_FILIAL = <<SUBSTR_D0R_D0S_FILIAL>>"
	cQuery += "   AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT"
	cQuery += "   AND D0R.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DCF_COMPANY>> DCF"
	cQuery += "    ON DCF.DCF_FILIAL = <<SUBSTR_DCF_D0R_FILIAL>>"
	cQuery += "   AND DCF.DCF_ID = D0R.D0R_IDDCF"
	cQuery += "   AND DCF.DCF_STSERV <> '0'"
	cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<D12_COMPANY>> D12"
	cQuery += "    ON D12.D12_FILIAL = <<SUBSTR_D12_DCF_FILIAL>>"
	cQuery += "   AND D12.D12_IDDCF = DCF.DCF_ID"
	cQuery += "   AND D12.D12_STATUS <> '0'"
	cQuery += "   AND D12.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DCX_COMPANY>> DCX"
	cQuery += "    ON DCX.DCX_FILIAL = <<SUBSTR_DCX_D0Q_FILIAL>>"
	cQuery += "   AND DCX.DCX_DOC = D0Q.D0Q_DOCTO"
	cQuery += "   AND DCX.DCX_SERIE = D0Q.D0Q_SERIE"
	cQuery += "   AND DCX.DCX_FORNEC = D0Q.D0Q_CLIFOR"
	cQuery += "   AND DCX.DCX_LOJA = D0Q.D0Q_LOJA"
	cQuery += "   AND DCX.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DCW_COMPANY>> DCW"
	cQuery += "    ON DCW.DCW_FILIAL = <<SUBSTR_DCW_DCX_FILIAL>>"
	cQuery += "   AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ"
	cQuery += "   AND DCW.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SA2_COMPANY>> SA2"
	cQuery += "    ON SA2.A2_FILIAL = <<SUBSTR_SA2_D0Q_FILIAL>>"
	cQuery += "   AND SA2.A2_COD = D0Q.D0Q_CLIFOR"
	cQuery += "   AND SA2.A2_LOJA = D0Q.D0Q_LOJA"
	cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D0Q.D0Q_ORIGEM = 'SD1'"
	cQuery +=   " AND D0Q.D_E_L_E_T_ = ' '"
	cQuery +=   " AND D12.D12_DATFIM >= <<START_DATE>>"
	cQuery +=   " AND D12.D12_DATFIM <= <<FINAL_DATE>>"
	cQuery += "   AND NOT EXISTS (SELECT 1" // Não pode existir nenhum unitizador não endereçado, ou alguma demanda pendente de unitização
	cQuery +=                    "  FROM <<D0Q_COMPANY>> D0Q2"
	cQuery +=                    " INNER JOIN <<D0S_COMPANY>> D0S2"
	cQuery +=                    "    ON D0S2.D0S_FILIAL = <<SUBSTR_D0S_D0Q_FILIAL>>"
	cQuery +=                    "   AND D0S2.D0S_IDD0Q = D0Q2.D0Q_ID"
	cQuery +=                    "   AND D0S2.D_E_L_E_T_ = ' '"
	cQuery +=                    " INNER JOIN <<D0R_COMPANY>> D0R2"
	cQuery +=                    "    ON D0R2.D0R_FILIAL = <<SUBSTR_D0R_D0Q_FILIAL>>"
	cQuery +=                    "   AND D0R2.D0R_IDUNIT = D0S2.D0S_IDUNIT"
	cQuery +=                    "   AND D0R2.D_E_L_E_T_ = ' '"
	cQuery +=                    "  WHERE D0Q2.D0Q_FILIAL = D0Q.D0Q_FILIAL"
	cQuery +=                       " AND D0Q2.D0Q_ORIGEM = D0Q.D0Q_ORIGEM"
	cQuery +=                       " AND D0Q2.D0Q_DOCTO = D0Q.D0Q_DOCTO"
	cQuery +=                       " AND D0Q2.D0Q_SERIE = D0Q.D0Q_SERIE"
	cQuery +=                       " AND D0Q2.D0Q_CLIFOR = D0Q.D0Q_CLIFOR"
	cQuery +=                       " AND D0Q2.D0Q_LOJA = D0Q.D0Q_LOJA"
	cQuery +=                       " AND D0Q2.D_E_L_E_T_ = ' '"
	cQuery +=                       " AND ((D0Q2.D0Q_QUANT > D0Q2.D0Q_QTDUNI) OR D0R2.D0R_STATUS <> '4'))" 
	cQuery += " GROUP BY D0Q.D0Q_FILIAL,"
	cQuery +=       " D0Q.D0Q_DOCTO,"
	cQuery +=       " D0Q.D0Q_SERIE,"
	cQuery +=       " D0Q.D0Q_CLIFOR,"
	cQuery +=       " D0Q.D0Q_LOJA,"
	cQuery +=       " SA2.A2_FILIAL"
Return cQuery