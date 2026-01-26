#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMPRAS

//-------------------------------------------------------------------
/*/{Protheus.doc} BACompras
Visualiza as informacoes dos Pedidos de Compra.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Class BACompras from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACompras
	_Super:Setup("Compras", FACT, "SC7")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACompras
	Local cQuery := ""

	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
       		"<<KEY_FILIAL_C7_FILIAL>> AS BK_FILIAL, " + ;
   			"<<KEY_SA2_A2_FILIAL+C7_FORNECE+C7_LOJA>> AS BK_FORNECEDOR, " + ;
			"<<KEY_SB1_B1_FILIAL+C7_PRODUTO>> AS BK_ITEM, " + ;
			"<<KEY_SE4_E4_FILIAL+C7_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;
			"<<KEY_CTT_CTT_FILIAL+C7_CC>> AS BK_CENTRO_DE_CUSTO, " + ;
			"<<KEY_SAH_AH_FILIAL+C7_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
			"<<KEY_SY1_Y1_FILIAL+C7_COMPRA>> AS BK_COMPRADOR, " + ;
			"<<KEY_SF4_F4_FILIAL+C7_TES>> AS BK_TES, " + ;
			"<<KEY_ACU_ACU_FILIAL+ACU_COD>> AS BK_FAMILIA_COMERCIAL, " + ;
			"CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO, " + ; 
			"CASE " + ;
				"WHEN ( C7_QUJE > 0 ) AND ( C7_QUJE < C7_QUANT) THEN <<KEY_###_'R'>> " + ;
				"WHEN ( C7_QUJE >= C7_QUANT ) THEN <<KEY_###_'I'>> " + ;
				"ELSE <<KEY_###_''>> " + ;
			"END AS BK_SITUACAO_COMPRA, " + ;
			"C7_NUMSC ORDEM, " + ;
			"C7_NUM PEDIDO, " + ;
			"ISNULL( C7_EMISSAO, '' ) AS  DATA, " + ;
			"ISNULL( C7_DATPRF, '' ) AS DTENTR, " + ;
			"ISNULL( C1_EMISSAO, '' ) AS DTEORD, " + ;
			"1 QORDCP, " + ;
			"C7_VALIPI VIPICP, " + ;
			"C7_VALICM VICMCP, " + ;
			"0 VIPINC, " + ;
			"0 VIPNIN, " + ;
			"CASE WHEN ( C7_RESIDUO = 'S' ) THEN C7_QUJE ELSE C7_QUANT END AS QCOMPR, "
			
	IF (cPaisloc == "BRA")
		cQuery += "CASE WHEN ( C7_RESIDUO = 'S' ) THEN ( C7_QUJE * C7_PRECO ) ELSE C7_TOTAL END AS VCOMPR, "
	ELSE 
		cQuery += "CASE WHEN (C7_RESIDUO = 'S') THEN " +;
          			"(CASE WHEN (C7_MOEDA = 1) THEN " +;
             			"C7_QUJE * C7_PRECO " +;
            		"ELSE " +;
             			"C7_QUJE * (C7_PRECO * "+;
						"(CASE WHEN (C7_TXMOEDA <> 0) THEN " +;
                			"C7_TXMOEDA " +;
               			"ELSE " +;
                			"M2_MOEDA2 " +;
             			"END)) " +;
          			"END) " +;
         		"ELSE " +;
          			"(CASE WHEN (C7_MOEDA = 1) THEN " +;
             			"C7_TOTAL " +;
            		"ELSE " +;
             			"(C7_TOTAL * "+;
						"(CASE WHEN (C7_TXMOEDA <> 0) THEN " +;
                			"C7_TXMOEDA " +;
               			"ELSE " +;
                			"M2_MOEDA2 " +;
             			"END)) " +;
          			"END) " +;
       			"END AS VCOMPR, "
	ENDIF

	cQuery += "<<CODE_INSTANCE>> AS INSTANCIA, "
	cQuery += "<<KEY_MOEDA_C7_MOEDA>> AS BK_MOEDA, "
	cQuery += "COALESCE(C7_TXMOEDA,0) AS TAXA_MOEDA "

	cQuery += " FROM <<SC7_COMPANY>> SC7 " + ;
			"LEFT JOIN <<SB1_COMPANY>> SB1 ON B1_FILIAL = <<SUBSTR_SB1_C7_FILIAL>> " + ; // Produto
				"AND B1_COD = C7_PRODUTO " + ;
				"AND SB1.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SA2_COMPANY>> SA2 ON A2_FILIAL = <<SUBSTR_SA2_C7_FILIAL>> " + ; // Fornecedor 
				"AND A2_COD = C7_FORNECE " + ;
				"AND A2_LOJA = C7_LOJA " + ;
				"AND SA2.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SE4_COMPANY>> SE4 ON E4_FILIAL = <<SUBSTR_SE4_C7_FILIAL>> " + ; // Condicao de pagamento
				"AND E4_CODIGO = C7_COND " + ;
				"AND SE4.D_E_L_E_T_ = ' ' " + ;			
			"LEFT JOIN <<SF4_COMPANY>> SF4 ON F4_FILIAL = <<SUBSTR_SF4_C7_FILIAL>> " + ; // TES
				"AND F4_CODIGO = C7_TES " + ;
				"AND SF4.D_E_L_E_T_ = ' ' " + ;	
			"LEFT JOIN <<CTT_COMPANY>> CTT ON CTT_FILIAL = <<SUBSTR_CTT_C7_FILIAL>> " + ; // Centro de custo
				"AND CTT_CUSTO = C7_CC " + ;
				"AND CTT.D_E_L_E_T_ = ' ' " + ;			
			"LEFT JOIN <<SY1_COMPANY>> SY1 ON Y1_FILIAL = <<SUBSTR_SY1_C7_FILIAL>> " + ; // Comprador
				"AND Y1_COD = C7_COMPRA " + ;
				"AND SY1.D_E_L_E_T_ = ' ' " + ;			
			"LEFT JOIN <<ACV_COMPANY>> ACV ON ACV_FILIAL = <<SUBSTR_ACV_C7_FILIAL>> " + ; // Familia Comercial
				"AND ACV_CODPRO = C7_PRODUTO " + ;
				"AND ACV.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<ACU_COMPANY>> ACU ON ACU_FILIAL = <<SUBSTR_ACU_ACV_FILIAL>> " + ;
				"AND ACU_COD = ACV.ACV_CATEGO " + ;
			 	"AND ACU.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SC1_COMPANY>> SC1 ON C1_FILIAL = <<SUBSTR_SC1_C7_FILIAL>> " + ; // Solicitacao de compra
				"AND C1_NUM = C7_NUMSC " + ;
				"AND C1_ITEM = C7_ITEMSC " + ;
				"AND SC1.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SAH_COMPANY>> SAH ON AH_FILIAL = <<SUBSTR_SAH_C7_FILIAL>> " + ; // Unidade de medida
				"AND AH_UNIMED = C7_UM " + ;
				"AND SAH.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SM2_COMPANY>> SM2 ON M2_DATA = C7_EMISSAO " +; //Moeda
				"AND SM2.D_E_L_E_T_ = ' '" +;
		" WHERE " + ;
			  "C7_EMISSAO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
			  "AND (C7_RESIDUO <> 'S' OR C7_QUJE > 0) " + ;
			  "AND SC7.D_E_L_E_T_ = ' ' " + ;
			  "<<AND_XFILIAL_C7_FILIAL>> "

Return cQuery