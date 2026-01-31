#INCLUDE "BADEFINITION.CH"

NEW ENTITY DEVOLUCOES

//-------------------------------------------------------------------
/*/{Protheus.doc} BADevolucoes
Visualiza as informacoes das Notas Fiscais de devolucoes da area de Comercial.

@author  Helio Leal
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Class BADevolucoes from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BADevolucoes
	_Super:Setup("Devolucoes", FACT, "SD1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BADevolucoes
    Local cQuery := ""
    
	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, <<KEY_FILIAL_D1_FILIAL>> AS BK_FILIAL, " + ;
				"D1_DTDIGIT AS DATA_DE_DEVOLUCAO, " + ;
				"<<KEY_SX5_CFOP.X5_FILIAL+D1_CF>> AS BK_CFOP, " + ;
				"D1_SERIE AS SERIE_DOCUMENTO_CLIENTE, " + ;
				"D1_DOC AS NUMERO_DOCUMENTO_CLIENTE, " + ;
				"F2_SERIE AS SERIE_NOTA_FISCAL, " + ;
				"F2_DOC AS NUMERO_DA_NOTA_FISCAL, " + ;
				"D1_ITEM AS NUMERO_DO_ITEM_DO_DOCUMENTO, " + ;
				"D1_DOC || D1_SERIE AS NUMERO_DO_ITEM_DA_NF," + ;
				"D1_REMITO AS NUMERO_DO_REMITO, " + ;
				"D1_SERIREM AS SERIE_DO_REMITO, " + ;
				"D1_ITEMREM AS ITEM_DO_REMITO, " + ;
				"<<KEY_SF4_F4_FILIAL+D1_TES>> AS BK_TES, " + ;
				"<<KEY_SE4_E4_FILIAL+F2_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;
				"<<KEY_SB1_B1_FILIAL+D1_COD>> AS BK_ITEM, " + ;
				"<<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " + ;
				"<<KEY_SA3_A3_FILIAL+F2_VEND1>> AS BK_VENDEDOR, " + ;
				"<<KEY_SA1_A1_FILIAL+D1_FORNECE+D1_LOJA>> AS BK_CLIENTE, " + ;
				"<<KEY_SAH_AH_FILIAL+D1_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
				"CASE WHEN SA1.A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ;
				"D1_QUANT AS QTDE_DEVOLVIDA_ITEM, "
	
	if (cPaisloc == "BRA")
		cQuery += "D1_TOTAL+D1_VALIPI+D1_ICMSRET AS VL_DEVOLUCAO_TOTAL, "
	else
		cQuery += "CASE WHEN F2_MOEDA = 1 " +;
				  " THEN D1_TOTAL " +;
			      " ELSE D1_TOTAL * F2_TXMOEDA " +;
		          "END AS VL_DEVOLUCAO_TOTAL, "
	endif				

	cQuery += "D1_VALICM AS VL_ICMS_DEVOLUCAO, " + ;
			  "D1_VALIPI AS VL_IPI_DEVOLUCAO, "

	if (cPaisloc == "BRA")
		cQuery += "(D1_TOTAL - (D1_VALICM + D1_VALIMP5 + D1_VALIMP6 + D1_VALDESC)) AS VL_DEVOLUCAO_LIQUIDA, " +;
				  "D1_TOTAL - D1_VALDESC AS VL_DEVOLUCAO_MERCADORIA, "
	else
		cQuery += "CASE WHEN F2_MOEDA = 1 " +;
			      " THEN (D1_TOTAL - (D1_VALICM + D1_VALIMP5 + D1_VALIMP6 + D1_VALDESC)) " +;
		          " ELSE (D1_TOTAL - (D1_VALICM + D1_VALIMP5 + D1_VALIMP6 + D1_VALDESC)) * F2_TXMOEDA " +;
		          "END AS VL_DEVOLUCAO_LIQUIDA, " +;
				  "CASE WHEN F2_MOEDA = 1 " +;
			      " THEN D1_TOTAL - D1_VALDESC " +;
				  " ELSE (D1_TOTAL - D1_VALDESC) * F2_TXMOEDA " +;
				  "END AS VL_DEVOLUCAO_MERCADORIA, "
	endif			
	
	cQuery += "D1_VALIMP6 AS VL_PIS_DEVOLUCAO, " + ;
			"D1_VALIMP5 AS VL_COFINS_DEVOLUCAO, " + ;
			"D1_ICMSRET AS VL_ICMS_SUBST_DEVOLUCAO, "
			
	if (cPaisloc == "BRA")
		cQuery += "D1_VALDESC AS VL_DESCONTO_DEVOLUCAO, " +;
                  "D1_VALINS AS VL_INSS_DEVOLUCAO, "
	else
		cQuery += "D1_VALINS AS VL_INSS_DEVOLUCAO, " +;
		          "CASE WHEN F2_MOEDA = 1 " +;
				  " THEN D1_VALDESC " +;  
				  " ELSE D1_VALDESC * F2_TXMOEDA " +;
				  "END AS VL_DESCONTO_DEVOLUCAO, "		
	endif			

	cQuery += "<<CODE_INSTANCE>> AS INSTANCIA, "
	cQuery += "<<KEY_MOEDA_F2_MOEDA>> AS BK_MOEDA, "
	cQuery += "COALESCE(F2_TXMOEDA,0) AS TAXA_MOEDA "
	
	cQuery += " FROM <<SD1_COMPANY>> SD1 " + ;
			  "INNER JOIN <<SF2_COMPANY>> SF2 " + ;
					 "ON SF2.D_E_L_E_T_ = ' ' " + ;
					 "AND F2_FILIAL = <<SUBSTR_SF2_D1_FILIAL>>  " + ;
					 "AND F2_DOC = D1_NFORI " + ;
					 "AND F2_SERIE = D1_SERIORI " + ;
					 "AND F2_CLIENTE = D1_FORNECE " + ;
					 "AND F2_LOJA = D1_LOJA " + ;
				"INNER JOIN <<SB1_COMPANY>> SB1 " + ;
					 "ON B1_FILIAL = <<SUBSTR_SB1_F2_FILIAL>> " + ;
					 "AND SB1.B1_COD = D1_COD " + ;
					 "AND SB1.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SF4_COMPANY>> SF4 " + ;
					 "ON F4_FILIAL = <<SUBSTR_SF4_D1_FILIAL>> " + ;
					 "AND D1_TES = F4_CODIGO " + ;
					 "AND SF4.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SE4_COMPANY>> SE4 " + ;
					 "ON E4_FILIAL = <<SUBSTR_SE4_D1_FILIAL>> " + ;
					 "AND E4_CODIGO = F2_COND " + ;
					 "AND SE4.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SBM_COMPANY>> SBM " + ;
					 "ON BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>> " + ;
					 "AND BM_GRUPO = B1_GRUPO " + ;
					 "AND SBM.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SA3_COMPANY>> SA3 " + ;
					"ON A3_FILIAL = <<SUBSTR_SA3_F2_FILIAL>> " + ;
					"AND A3_COD = SF2.F2_VEND1 " + ;
					"AND SA3.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SA1_COMPANY>> SA1 " + ;
					"ON A1_FILIAL = <<SUBSTR_SA1_F2_FILIAL>> " + ;
					"AND SA1.A1_COD = SF2.F2_CLIENTE " + ;
					"AND SA1.A1_LOJA = SF2.F2_LOJA " + ;
					"AND SA1.D_E_L_E_T_= ' ' " + ;
				"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
					"ON AH_FILIAL = <<SUBSTR_SAH_D1_FILIAL>> " + ;
					"AND AH_UNIMED = SD1.D1_UM " + ;
					"AND SAH.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SX5_COMPANY>> CFOP " + ;
				   "ON X5_FILIAL = <<ALIAS_CFOP>><<SUBSTR_SX5_D1_FILIAL>> " + ;
					"AND X5_TABELA = '13' " + ;
					"AND X5_CHAVE = D1_CF " + ;
					"AND CFOP.D_E_L_E_T_ = ' ' " + ;
				"WHERE D1_DTDIGIT BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
				    "AND SD1.D_E_L_E_T_ = ' '  " + ;
				    "<<AND_XFILIAL_D1_FILIAL>> "
Return cQuery	
