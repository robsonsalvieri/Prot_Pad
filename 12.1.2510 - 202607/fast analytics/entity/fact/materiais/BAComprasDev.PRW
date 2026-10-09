#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMPDEVOLUCAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAComprasDev
Visualiza as informacoes de devolucoes de compras da area de Materiais.

@author  Andreia Lima
@since   19/02/2018
/*/
//-------------------------------------------------------------------
Class BAComprasDev from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   19/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAComprasDev
	_Super:Setup("ComprasDevolucao", FACT, "SD2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andreia Lima
@since   19/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAComprasDev
	Local cQuery := ""

	cQuery := "SELECT " +;
              "<<KEY_COMPANY>> AS BK_EMPRESA, <<KEY_FILIAL_D2_FILIAL>> AS BK_FILIAL, " + ;
	            "<<KEY_SA2_A2_FILIAL+D2_CLIENTE+D2_LOJA>> AS BK_FORNECEDOR, " +;
	            "<<KEY_CTT_CTT_FILIAL+D1_CC>> AS BK_CENTRO_DE_CUSTO, " +;
	            "<<KEY_SF4_F4_FILIAL+D2_TES>> AS BK_TES, " +;
	            "<<KEY_SB1_B1_FILIAL+D2_COD>> AS BK_ITEM, " +;
              "<<KEY_SAH_AH_FILIAL+D2_UM>> AS BK_UNIDADE_DE_MEDIDA, " +;
	            "<<KEY_SE4_E4_FILIAL+F1_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " +;
	            "<<KEY_ACU_ACU_FILIAL+ACV_CATEGO>> AS BK_FAMILIA_COMERCIAL, " +;
	            "<<KEY_SX5_FAMAT.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL, " +;
	            "<<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " +;	          
	            "<<KEY_SA4_A4_FILIAL+F1_TRANSP>> AS BK_TRANSPORTADORA, " +;
	            "<<KEY_###_'D'>> AS BK_SITUACAO_COMPRA, " +; 
	            "<<KEY_SX5_GRPFOR.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR, " +;
	            "CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO, " +;
              "D2_DOC AS NUMERO_NOTA_FISCAL, " +;
              "D2_SERIE AS SERIE_NOTA_FISCAL, " +;
              "D2_EMISSAO AS DATA_DA_EMISSAO, " +;
              "D1_PEDIDO AS NUMERO_PEDIDO, " +;
              "D1_ITEMPC AS ITEM_PEDIDO, " +;
              "D2_QUANT AS QUANTIDADE_DEVOLVIDA, "
    
    IF (cPaisloc == "BRA") 
      cQuery += "D2_TOTAL AS VALOR_DEVOLVIDO, "
    ELSE
      cQuery += "CASE " +; 
		              "WHEN F1_MOEDA = 1 THEN D2_TOTAL " +;
		              "ELSE D2_TOTAL * F1_TXMOEDA " +;
		            "END AS VALOR_DEVOLVIDO, "
    ENDIF

    cQuery += "<<CODE_INSTANCE>> AS INSTANCIA, "
    cQuery += "<<KEY_MOEDA_F1_MOEDA>> AS BK_MOEDA, "
    cQuery += "COALESCE(F1_TXMOEDA,0) AS TAXA_MOEDA "

    cQuery += "FROM <<SD2_COMPANY>> SD2 " +;
              "LEFT JOIN <<SA2_COMPANY>> SA2 " +; //Fornecedor
	              "ON A2_FILIAL = <<SUBSTR_SA2_D2_FILIAL>> " +; 
	             "AND A2_COD = D2_CLIENTE " +;
	             "AND A2_LOJA = D2_LOJA " +;
               "AND SA2.D_E_L_E_T_ = ' ' " + ;
              "LEFT JOIN <<SX5_COMPANY>> GRPFOR " +; //Grupo fornecedor
			          "ON GRPFOR.X5_FILIAL = <<ALIAS_GRPFOR>><<SUBSTR_SX5_D2_FILIAL>> " +;              
               "AND GRPFOR.X5_TABELA = 'Y7' " +;
	             "AND GRPFOR.X5_CHAVE = A2_GRUPO " +;
	             "AND GRPFOR.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SB1_COMPANY>> SB1 " +;  //Produto
                "ON B1_FILIAL = <<SUBSTR_SB1_D2_FILIAL>> " +;
               "AND B1_COD = D2_COD " +;
               "AND SB1.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SBM_COMPANY>> SBM " +; //Grupo estoque
                "ON BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>> " +; 
               "AND BM_GRUPO = B1_GRUPO " +;
               "AND SBM.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SX5_COMPANY>> FAMAT " +; //Familia Material
			          "ON FAMAT.X5_FILIAL = <<ALIAS_FAMAT>><<SUBSTR_SX5_D2_FILIAL>> " +;              
               "AND FAMAT.X5_TABELA = '02' " +;
	             "AND FAMAT.X5_CHAVE = B1_TIPO " +;
	             "AND FAMAT.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SAH_COMPANY>> SAH " +; //Unidade de medida
                "ON AH_FILIAL = <<SUBSTR_SAH_D2_FILIAL>> " +;
	             "AND AH_UNIMED = D2_UM " +; 
	             "AND SAH.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<ACV_COMPANY>> ACV " +; //Familia Comercial
                "ON ACV_FILIAL = <<SUBSTR_ACV_D2_FILIAL>> " +;
               "AND ACV_CODPRO = D2_COD " +;
               "AND ACV.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<ACU_COMPANY>> ACU " +;
                "ON ACU_FILIAL = <<SUBSTR_ACU_ACV_FILIAL>> " +;              
               "AND ACU_COD = ACV.ACV_CATEGO " +;
               "AND ACU.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SD1_COMPANY>> SD1 " +; //Centro de Custo
                "ON D1_FILIAL = <<SUBSTR_SD1_D2_FILIAL>> " +;
	             "AND D1_COD = D2_COD " +; 
	             "AND D1_DOC = D2_NFORI " +;
	             "AND D1_SERIE = D2_SERIORI " +;
	             "AND D1_FORNECE = D2_CLIENTE " +;
	             "AND D1_LOJA = D2_LOJA " +;
	             "AND SD1.D_E_L_E_T_ = ' ' " + ;
              "LEFT JOIN <<CTT_COMPANY>> CTT " +; 
                "ON CTT_FILIAL = <<SUBSTR_CTT_D1_FILIAL>> " +;
	             "AND CTT_CUSTO = D1_CC " +;
	             "AND CTT.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SF4_COMPANY>> SF4 " +; //TES
			          "ON F4_FILIAL = <<SUBSTR_SF4_D2_FILIAL>> " +;              
               "AND F4_CODIGO = D2_TES " +;
	             "AND SF4.D_E_L_E_T_ = ' ' " +;
              "LEFT JOIN <<SF1_COMPANY>> SF1 " +; //Transportadora
                "ON F1_FILIAL = <<SUBSTR_SF1_D2_FILIAL>> " +;
               "AND F1_DOC = D2_NFORI " +;
               "AND F1_SERIE = D2_SERIORI " +;
               "AND F1_FORNECE = D2_CLIENTE " +;
               "AND F1_LOJA = D2_LOJA "

      if (cPaisloc == "BRA")         
        cQuery += "AND F1_TIPO = D2_TIPO "
      endif         
      
      cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + ;
              "LEFT JOIN <<SA4_COMPANY>> SA4 " +;
                "ON A4_FILIAL = <<SUBSTR_SA4_F1_FILIAL>> " +;
               "AND A4_COD = F1_TRANSP " +;
               "AND SA4.D_E_L_E_T_ = ' ' " + ;
              "LEFT JOIN <<SE4_COMPANY>> SE4 " +; //Condicao de pagto
                "ON E4_FILIAL = <<SUBSTR_SE4_F1_FILIAL>> " +;
               "AND E4_CODIGO = F1_COND " +;
               "AND SE4.D_E_L_E_T_ = ' ' " +;
             "WHERE SD2.D_E_L_E_T_ = ' ' " +;
               "AND D2_TIPO = 'D' " +;
               "AND D2_ORIGLAN <> 'LF' " +;
               "AND D2_EMISSAO <= <<FINAL_DATE>> " +;
               "<<AND_XFILIAL_D2_FILIAL>> "
              
Return cQuery	
