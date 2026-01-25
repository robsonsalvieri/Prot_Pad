#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMPCARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAComprasCart
Visualiza as informacoes das compras carteira da area de Materiais.

@author  Angelo Lee
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Class BAComprasCart from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Angelo Lee
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAComprasCart
	_Super:Setup("ComprasCarteira", FACT, "SC7")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@author Angelo Lee
@since  16/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAComprasCart
	Local cQuery := ""
	
	//-------------------------------------------
	// Lookups
	//-------------------------------------------
	cQuery := " SELECT " + ;
		          "<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	              "<<KEY_FILIAL_C7_FILIAL>> AS BK_FILIAL, " + ; 
	              "<<KEY_SA2_A2_FILIAL+C7_FORNECE+C7_LOJA>> AS BK_FORNECEDOR, " + ; 
	              "<<KEY_SX5_GRPFORN.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR, " + ; 
	              "<<KEY_###_C7_TPOP>> AS BK_SITUACAO_COMPRA, " + ;
	              "<<KEY_SAH_AH_FILIAL+C7_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ; 
	              "<<KEY_SX5_FAMAT.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL, " + ; 
	              "<<KEY_ACU_ACU_FILIAL+ACU_COD>> AS BK_FAMILIA_COMERCIAL, " + ;
	              "<<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " + ; 
	              "<<KEY_SB1_B1_FILIAL+C7_PRODUTO>> AS BK_ITEM, " + ; 
	              "<<KEY_SY1_Y1_FILIAL+C7_COMPRA>> AS BK_COMPRADOR, " + ; 
	              "<<KEY_SE4_E4_FILIAL+C7_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ; 
	              "<<KEY_CTT_CTT_FILIAL+C7_CC>> AS BK_CENTRO_DE_CUSTO, " + ; 
	      		  "CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO, "

	//-------------------------------------------
	// Atributos
	//-------------------------------------------
	cQuery +=     "ISNULL( C7_DATPRF,  '' ) AS DATA_PREVISAO_ENTREGA, " + ; 
		          "ISNULL( C7_EMISSAO, '' ) AS DATA_EMISSAO_PEDIDO_COMPRA, " + ;
	              "<<EXTRACTION_DATE>> AS DATA_DA_EXTRACAO, " + ;
	              "C7_NUMSC AS ORDEM, " + ;
	              "C7_NUM AS PEDIDO, "

	//-------------------------------------------
	// Indicadores
	//-------------------------------------------
	IF (cPaisloc == "BRA")
    	cQuery += "( C7_QUANT - C7_QUJE ) AS QUANTIDADE_CARTEIRA, " +;
				  "((C7_QUANT - C7_QUJE) * C7_PRECO) AS VALOR_CARTEIRA, "

	ELSE
		cQuery += "((C7_QUANT - C7_QUJE) * (C7_PRECO * (CASE " +; 
															"WHEN (C7_TXMOEDA <> 0 ) THEN C7_TXMOEDA " +;
															"ELSE M2_MOEDA2 "+;
														"END))) AS VALOR_CARTEIRA, " +;
				   "( C7_QUANT - C7_QUJE ) AS QUANTIDADE_CARTEIRA, "										
	ENDIF
    
	cQuery +=     "CASE " + ;
	              	"WHEN ( <<DATEDIFF(DD, C7_DATPRF, <<EXTRACTION_DATE>> ) >> ) > 0 " + ;
	              		"THEN ( <<DATEDIFF(DD, C7_DATPRF, <<EXTRACTION_DATE>> )>> ) " + ;
	              		"ELSE 0 " + ;
	              	"END AS DIAS_ATRASADOS_CARTEIRA, " + ;
	              "CASE " + ; 
	              	"WHEN ( <<DATEDIFF(DD, C7_DATPRF, <<EXTRACTION_DATE>> )>> ) > 0 " + ;
	                "THEN 1 " + ;
	                "ELSE 0 " + ;
	              "END AS NUMERO_ENTREGAS_ATRASADAS, " + ;
                  "<<CODE_INSTANCE>> AS INSTANCIA, " +;
                  "<<KEY_MOEDA_C7_MOEDA>> AS BK_MOEDA, " +;
                  "COALESCE(C7_TXMOEDA,0) AS TAXA_MOEDA " +;
              "FROM <<SC7_COMPANY>> SC7 " + ;
	              "LEFT JOIN <<SB1_COMPANY>> SB1 ON " + ; // Item
	                  "B1_FILIAL = <<SUBSTR_SB1_C7_FILIAL>> " + ;
	                  "AND B1_COD = C7_PRODUTO " + ;
	                  "AND SB1.D_E_L_E_T_ = ' ' " + ;
	              "LEFT JOIN <<ACV_COMPANY>> ACV ON ACV_FILIAL = <<SUBSTR_ACV_C7_FILIAL>> " + ; // Familia Comercial
	                  "AND ACV_CODPRO = C7_PRODUTO " + ;
	                  "AND ACV.D_E_L_E_T_ = ' ' " + ;
                  "LEFT JOIN <<ACU_COMPANY>> ACU ON ACU_FILIAL = <<SUBSTR_ACU_ACV_FILIAL>> " + ;
	                  "AND ACU_COD = ACV.ACV_CATEGO " + ;
	                  "AND ACU_FILIAL = ACV.ACV_FILIAL " + ;
	                  "AND ACU.D_E_L_E_T_ = ' ' " + ;
                  "LEFT JOIN <<SA2_COMPANY>> SA2 ON A2_FILIAL = <<SUBSTR_SA2_C7_FILIAL>> " + ; // Fornecedor
	                  "AND A2_COD = C7_FORNECE " + ;
	                  "AND A2_LOJA = C7_LOJA " + ;
	                  "AND SA2.D_E_L_E_T_ = ' ' " + ;
                  "LEFT JOIN <<SAH_COMPANY>> SAH ON AH_FILIAL = <<SUBSTR_SAH_C7_FILIAL>> " + ; // Unidade de medida
	                  "AND AH_UNIMED = C7_UM " + ;
	                  "AND SAH.D_E_L_E_T_ = ' ' " + ;
                  "LEFT JOIN <<SBM_COMPANY>> SBM ON BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>> " + ; // Grupo Estoque
	                  "AND BM_GRUPO = B1_GRUPO " + ;
					  "AND SBM.D_E_L_E_T_ = '' " + ;
                  "LEFT JOIN <<SY1_COMPANY>> SY1 ON Y1_FILIAL = <<SUBSTR_SY1_C7_FILIAL>> " + ; // Comprador
	                  "AND Y1_COD = C7_COMPRA " + ;
	                  "AND SY1.D_E_L_E_T_ = ' ' " + ;
	              "LEFT JOIN <<SE4_COMPANY>> SE4 ON E4_FILIAL = <<SUBSTR_SE4_C7_FILIAL>> " + ; // Condicao de pagamento
	                  "AND E4_CODIGO = C7_COND " + ;
	                  "AND SE4.D_E_L_E_T_ = ' ' " + ;
	              "LEFT JOIN <<CTT_COMPANY>> CTT ON CTT_FILIAL = <<SUBSTR_CTT_C7_FILIAL>> " + ; // Centro de custo 
	                  "AND CTT_CUSTO = C7_CC " + ;
	                  "AND CTT.D_E_L_E_T_ = ' ' " + ;
	              "LEFT JOIN <<SD1_COMPANY>> SD1 ON D1_FILIAL = <<SUBSTR_SD1_C7_FILIAL>> " + ;
	                  "AND D1_PEDIDO = C7_NUM " + ;
	                  "AND D1_ITEMPC = C7_ITEM " + ;
	                  "AND SD1.D_E_L_E_T_ = ' ' " + ;
				  "LEFT JOIN <<SX5_COMPANY>> FAMAT ON FAMAT.X5_FILIAL = <<ALIAS_FAMAT>><<SUBSTR_SX5_C7_FILIAL>> " +; //Familia Material
					  "AND FAMAT.X5_TABELA = '02' " + ;
					  "AND FAMAT.X5_CHAVE = B1_TIPO " + ;
					  "AND FAMAT.D_E_L_E_T_ = ' ' " + ;
				  "LEFT JOIN <<SX5_COMPANY>> GRPFORN ON GRPFORN.X5_FILIAL = <<ALIAS_GRPFORN>><<SUBSTR_SX5_C7_FILIAL>> " +; //Grupo Fornecedor
					  "AND GRPFORN.X5_TABELA = 'Y7' " + ;
					  "AND GRPFORN.X5_CHAVE = A2_GRUPO " + ;
					  "AND GRPFORN.D_E_L_E_T_ = ' ' " + ;
				  "LEFT JOIN <<SM2_COMPANY>> SM2 ON M2_DATA = C7_EMISSAO " +;
	                  "AND SM2.D_E_L_E_T_ = ' ' " +;	  
              "WHERE " + ;
                  "C7_RESIDUO <> 'S' " + ;
                  "AND (C7_QUANT - C7_QUJE > 0) " + ;
                  "AND SC7.D_E_L_E_T_ = ' ' " + ; 
				  "<<AND_XFILIAL_C7_FILIAL>> "

Return cQuery
