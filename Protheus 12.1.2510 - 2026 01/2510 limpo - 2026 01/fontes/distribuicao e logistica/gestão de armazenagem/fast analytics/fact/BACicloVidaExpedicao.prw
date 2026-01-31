#INCLUDE "BADEFINITION.CH"

NEW ENTITY CICVIDEXPEDICAO
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BACicloVidaExpedicao
Visualiza as informações de Ciclo de Vida de Expedição
 
@author   jackson.werka
@since    17/08/2018
/*/
//-------------------------------------------------------------------
Class BACicloVidaExpedicao from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.
 
@author  jackson.werka
@since   17/08/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACicloVidaExpedicao
	_Super:Setup("CicloVidaExpedicao", FACT, "SF2")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   17/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACicloVidaExpedicao
Local cQuery := ""

	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_F2_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " SC9.C9_CARGA AS CARGA_EXPED,"
	cQuery +=       " SC9.C9_PEDIDO AS PEDIDO_VENDA,"
	cQuery +=       " SF2.F2_DOC AS NOTA_FISCAL,"
	cQuery +=       " SF2.F2_SERIE AS SERIE_NOTA_FISCAL,"
	cQuery +=       " <<KEY_SA1_A1_FILIAL+C9_CLIENTE+C9_LOJA>> AS BK_CLIENTE,"
	cQuery +=       " SF2.F2_EMISSAO     || ' ' || SF2.F2_HORA || ':00' AS DATHOR_EMIS_NF," 
	cQuery +=       " MIN(DAK.DAK_DATA   || ' ' || DAK.DAK_HORA) AS DATHOR_MONT_CARGA,"
	cQuery +=       " MIN(DCF.DCF_DATA   || ' ' || DCF.DCF_HORA) AS DATHOR_INT_WMS,"
	cQuery +=       " MIN(D12.D12_DTGERA || ' ' || D12.D12_HRGERA) AS DATHOR_EXE_WMS,"
	cQuery +=       " MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI) AS DATHOR_INI_SEP,"
	cQuery +=       " MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM) AS DATHOR_FIM_SEP,"
	cQuery +=       " (SELECT MIN(D12.D12_DATINI || ' ' || D12.D12_HORINI)"
	cQuery +=         "  FROM <<DCF_COMPANY>> DCFC"
	cQuery +=         " INNER JOIN <<D12_COMPANY>> D12"
	cQuery +=         "    ON D12.D12_FILIAL = <<SUBSTR_D12_C9_FILIAL>>"
	cQuery +=         "   AND D12.D12_IDDCF = DCFC.DCF_ID"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '7'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE DCFC.DCF_FILIAL = <<SUBSTR_DCF_C9_FILIAL>>"
	cQuery +=         "   AND DCFC.DCF_DOCTO = SC9.C9_PEDIDO"
	cQuery +=         "   AND DCFC.DCF_CARGA = SC9.C9_CARGA"
	cQuery +=         "   AND DCFC.DCF_ORIGEM = 'SC9'"
	cQuery +=         "   AND DCFC.DCF_STSERV <> '0'"
	cQuery +=         "   AND DCFC.D_E_L_E_T_ = ' ' ) AS DATHOR_INI_COFC,"
	cQuery +=       " (SELECT MAX(D12.D12_DATFIM || ' ' || D12.D12_HORFIM)"
	cQuery +=         "  FROM <<DCF_COMPANY>> DCFC"
	cQuery +=         " INNER JOIN <<D12_COMPANY>> D12"
	cQuery +=         "    ON D12.D12_FILIAL = <<SUBSTR_D12_C9_FILIAL>>"
	cQuery +=         "   AND D12.D12_IDDCF = DCFC.DCF_ID"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         "   AND D12.D12_STATUS <> '0'"
	cQuery +=         "   AND D12.D_E_L_E_T_ = ' '"
	cQuery +=         " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery +=         "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery +=         "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery +=         "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery +=         "   AND DC5.DC5_OPERAC = '7'"
	cQuery +=         "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE DCFC.DCF_FILIAL = <<SUBSTR_DCF_C9_FILIAL>>"
	cQuery +=         "   AND DCFC.DCF_DOCTO = SC9.C9_PEDIDO"
	cQuery +=         "   AND DCFC.DCF_CARGA = SC9.C9_CARGA"
	cQuery +=         "   AND DCFC.DCF_ORIGEM = 'SC9'"
	cQuery +=         "   AND DCFC.DCF_STSERV <> '0'"
	cQuery +=         "   AND DCFC.D_E_L_E_T_ = ' ' ) AS DATHOR_FIM_COFC,"
	cQuery +=       " MIN(DCV.DCV_DATINI || ' ' || DCV.DCV_HORINI) AS DATHOR_INI_MNT_VOL,"
	cQuery +=       " MAX(DCV.DCV_DATFIM || ' ' || DCV.DCV_HORFIM) AS DATHOR_FIM_MNT_VOL,"
	cQuery +=       " MIN(D04.D04_DTINI  || ' ' || D04.D04_HRINI) AS DATHOR_INI_COF_EXP,"
	cQuery +=       " MAX(D04.D04_DTFIM  || ' ' || D04.D04_HRFIM) AS DATHOR_FIM_COF_EXP,"
	cQuery +=       " SF2.F2_EMISSAO AS DATA_EXTRACAO"
	cQuery += "  FROM <<SF2_COMPANY>> SF2"
	cQuery += " INNER JOIN <<SC9_COMPANY>> SC9"
	cQuery += "    ON SC9.C9_FILIAL = <<SUBSTR_SC9_F2_FILIAL>>"
	cQuery += "   AND SC9.C9_NFISCAL = SF2.F2_DOC"
	cQuery += "   AND SC9.C9_SERIENF = SF2.F2_SERIE"
	cQuery += "   AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SC5_COMPANY>> SC5"
	cQuery += "    ON SC5.C5_FILIAL = <<SUBSTR_SC5_C9_FILIAL>>"
	cQuery += "   AND SC5.C5_NUM = SC9.C9_PEDIDO"
	cQuery += "   AND SC5.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DCF_COMPANY>> DCF"
	cQuery += "    ON DCF.DCF_FILIAL = <<SUBSTR_DCF_C9_FILIAL>>"
	cQuery += "   AND DCF.DCF_ID = SC9.C9_IDDCF"
	cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DCR_COMPANY>> DCR"
	cQuery += "    ON DCR.DCR_FILIAL = <<SUBSTR_DCR_C9_FILIAL>>"
	cQuery += "   AND DCR.DCR_IDDCF = SC9.C9_IDDCF"
	cQuery += "   AND DCR.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<D12_COMPANY>> D12"
	cQuery += "    ON D12.D12_FILIAL = <<SUBSTR_D12_DCR_FILIAL>>"
	cQuery += "   AND D12.D12_IDDCF = DCR.DCR_IDORI"
	cQuery += "   AND D12.D12_IDMOV = DCR.DCR_IDMOV"
	cQuery += "   AND D12.D12_IDOPER = DCR.DCR_IDOPER"
	cQuery += "   AND D12.D12_STATUS <> '0'"
	cQuery += "   AND D12.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DC5_COMPANY>> DC5"
	cQuery += "    ON DC5.DC5_FILIAL = <<SUBSTR_DC5_D12_FILIAL>>"
	cQuery += "   AND DC5.DC5_SERVIC = D12.D12_SERVIC"
	cQuery += "   AND DC5.DC5_ORDEM = D12.D12_ORDTAR"
	cQuery += "   AND DC5.DC5_OPERAC IN ('3','4')"
	cQuery += "   AND DC5.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DAK_COMPANY>> DAK
	cQuery += "    ON DAK.DAK_FILIAL = <<SUBSTR_DAK_C9_FILIAL>>"
	cQuery += "   AND DAK.DAK_COD = SC9.C9_CARGA"
	cQuery += "   AND DAK.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<DCV_COMPANY>> DCV"
	cQuery += "    ON DCV.DCV_FILIAL = <<SUBSTR_DCV_C9_FILIAL>>"
	cQuery += "   AND DCV.DCV_CARGA = SC9.C9_CARGA"
	cQuery += "   AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO"
	cQuery += "   AND DCV.DCV_ITEM = SC9.C9_ITEM"
	cQuery += "   AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN"
	cQuery += "   AND DCV.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<D04_COMPANY>> D04"
	cQuery += "    ON D04.D04_FILIAL = <<SUBSTR_D04_C9_FILIAL>>"
	cQuery += "   AND D04.D04_CARGA = SC9.C9_CARGA"
	cQuery += "   AND D04.D04_PEDIDO = SC9.C9_PEDIDO"
	cQuery += "   AND D04.D04_ITEM = SC9.C9_ITEM"
	cQuery += "   AND D04.D04_SEQUEN = SC9.C9_SEQUEN"
	cQuery += "   AND D04.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SA1_COMPANY>> SA1"
	cQuery += "    ON SA1.A1_FILIAL = <<SUBSTR_SA1_C9_FILIAL>>"
	cQuery += "   AND SA1.A1_COD = SC9.C9_CLIENTE"
	cQuery += "   AND SA1.A1_LOJA = SC9.C9_LOJA"
	cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SF2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SF2.F2_EMISSAO >= <<START_DATE>>"
	cQuery +=   " AND SF2.F2_EMISSAO <= <<FINAL_DATE>>"
	cQuery += " GROUP BY SF2.F2_FILIAL,"
	cQuery +=       " SF2.F2_DOC,"
	cQuery +=       " SF2.F2_SERIE,"
	cQuery +=       " SF2.F2_EMISSAO," 
	cQuery +=       " SF2.F2_HORA,"
	cQuery +=       " SC9.C9_FILIAL,"
	cQuery +=       " SC9.C9_CARGA,"
	cQuery +=       " SC9.C9_PEDIDO,"
	cQuery +=       " SC9.C9_CLIENTE,"
	cQuery +=       " SC9.C9_LOJA,"
	cQuery +=       " SA1.A1_FILIAL"
Return cQuery