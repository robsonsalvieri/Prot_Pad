#INCLUDE "BADEFINITION.CH"

NEW ENTITY COMPRECEBIMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAComprasRec
Visualiza as informacoes de recebimento de compras da area de Materiais.

@author  Andreia Lima
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Class BAComprasRec from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAComprasRec
	_Super:Setup("ComprasRecebimento", FACT, "SD1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andreia Lima
@since   16/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAComprasRec
	Local cQuery := ""

	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, <<KEY_FILIAL_D1_FILIAL>> AS BK_FILIAL, " + ;
	          " <<KEY_SB1_B1_FILIAL+D1_COD>> AS BK_ITEM, " + ;
	          " <<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " + ;
	          " <<KEY_SA2_A2_FILIAL+D1_FORNECE+D1_LOJA>> AS BK_FORNECEDOR, " + ;
	          " <<KEY_SX5_GRPFOR.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR, " + ;
	          " <<KEY_SA4_A4_FILIAL+F1_TRANSP>> AS BK_TRANSPORTADORA, " + ;
	          " <<KEY_SX5_FAMAT.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL, " + ;	
	          " <<KEY_ACU_ACU_FILIAL+ACU_COD>> AS BK_FAMILIA_COMERCIAL, " + ;
	          " <<KEY_SY1_Y1_FILIAL+C7_COMPRA>> AS BK_COMPRADOR, " + ;
	          " <<KEY_SE4_E4_FILIAL+F1_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;	
	          " <<KEY_SX5_CFOP.X5_FILIAL+D1_CF>> AS BK_CFOP, " + ;
 	          " <<KEY_CTT_CTT_FILIAL+D1_CC>> AS BK_CENTRO_DE_CUSTO, " + ;
	          " <<KEY_SF4_F4_FILIAL+D1_TES>> AS BK_TES, " + ;
  	          " <<KEY_SAH_AH_FILIAL+D1_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
	          " CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO, " + ;
	          " CASE WHEN ( C7_QUJE > 0 ) AND ( C7_QUJE < C7_QUANT) THEN <<KEY_###_'R'>> WHEN ( C7_QUJE >= C7_QUANT ) THEN <<KEY_###_'I'>> ELSE <<KEY_###_''>> END AS BK_SITUACAO_COMPRA, " + ; 
	          " D1_PEDIDO PEDIDO, " + ; 
	          " D1_ITEM SEQCIA, " + ;
	          " D1_DOC NUMNF, " + ; 			
              " D1_EMISSAO DATANF, " + ; 	
              " D1_DTDIGIT AS DATA, " + ;  	
              " D1_SERIE SERNF, " + ;
              " D1_REMITO REMITO, " + ;
              " D1_SERIREM SERREM, " + ;
              " D1_ITEMREM ITEREM, " + ;
              " D1_QUANT QRECEB, "

    IF (cPaisloc == "BRA")
        cQuery += " D1_TOTAL VRECEB, "
    ELSE
        cQuery += " CASE " +;
                  "   WHEN F1_MOEDA = 1 THEN D1_TOTAL " +;
		          "   ELSE D1_TOTAL * F1_TXMOEDA " +;
		          " END AS VRECEB, "
    ENDIF          

    cQuery += " C7_NUMSC ORDEM, " + ;
              " C7_EMISSAO DTEPED, " + ; 	
              " C7_DATPRF DTPREV, " + ; 
              " C1_EMISSAO DTEORD, " + ; 
              " CASE WHEN (ISNULL(C7_DATPRF,  '') = '') OR (C7_DATPRF = NULL) OR " + ; 
	                  " (ISNULL(D1_DTDIGIT, '') = '') OR (D1_DTDIGIT = NULL) OR " + ; 
	                  " (D1_DTDIGIT > C7_DATPRF) THEN 0 " + ; 
	                " ELSE <<DATEDIFF(DD, D1_DTDIGIT, C7_DATPRF)>> " + ;
	          " END AS QDIAAN, " + ;
              " CASE WHEN (ISNULL(C7_DATPRF,  '') = '') OR (C7_DATPRF = NULL) OR " + ; 
	                  " (ISNULL(D1_DTDIGIT, '') = '') OR (D1_DTDIGIT = NULL) OR " + ; 
	                  " (C7_DATPRF > D1_DTDIGIT) THEN 0 " + ; 
	          "  ELSE <<DATEDIFF(DD, C7_DATPRF, D1_DTDIGIT)>> " + ;
	          " END AS QDIAAT, " + ; 
              " CASE WHEN <<DATEDIFF(DD, D1_DTDIGIT, C7_DATPRF)>> > 0 THEN 1 " + ;
	          "  ELSE 0 " + ;
	          " END AS QRECAN, " + ;
              " CASE WHEN <<DATEDIFF(DD, C7_DATPRF, D1_DTDIGIT)>> < 0 THEN 1 " + ;
	          "  ELSE 0 " + ;
	          " END AS QRECAT, " + ; 
              " CASE WHEN (<<DATEDIFF(DD, D1_DTDIGIT, C7_DATPRF)>> = 0) AND " + ; 
	                  " (<<DATEDIFF(DD, C7_DATPRF, D1_DTDIGIT)>> = 0) THEN 1 " + ;
	          "  ELSE 0 " + ;     
	          " END AS QRECDT, " + ; 
              " CASE WHEN (D1_QUANT >= C7_QUANT) THEN 1 " + ; 
	          "  ELSE 0 " + ;     
	          " END AS QRECUN, " + ; 
              " <<CODE_INSTANCE>> AS INSTANCIA, " + ;
              " <<KEY_MOEDA_F1_MOEDA>> AS BK_MOEDA, " + ;
              " COALESCE(F1_TXMOEDA,0) AS TAXA_MOEDA " + ;
              " FROM <<SD1_COMPANY>> SD1 " + ;	 
              " LEFT JOIN <<SB1_COMPANY>> SB1 " + ;  //Produto
              "   ON B1_FILIAL = <<SUBSTR_SB1_D1_FILIAL>> " + ;
              "  AND B1_COD = D1_COD " + ;
              "  AND SB1.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SBM_COMPANY>> SBM " + ; //Grupo estoque
              "   ON BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>> " + ; 
              "  AND BM_GRUPO = B1_GRUPO " + ;
              "  AND SBM.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SX5_COMPANY>> FAMAT " + ; //Familia Material
			  "   ON FAMAT.X5_FILIAL = <<ALIAS_FAMAT>><<SUBSTR_SX5_D1_FILIAL>> " + ;              
              "  AND FAMAT.X5_TABELA = '02' " + ;
	          "  AND FAMAT.X5_CHAVE = B1_TIPO " + ;
	          "  AND FAMAT.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SA2_COMPANY>> SA2 " + ; //Fornecedor
              "   ON A2_FILIAL = <<SUBSTR_SA2_D1_FILIAL>> " + ;
	          "  AND A2_COD = D1_FORNECE " + ;
	          "  AND A2_LOJA = D1_LOJA " + ;
	          "  AND SA2.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SX5_COMPANY>> GRPFOR " + ; //Grupo fornecedor
			  "   ON GRPFOR.X5_FILIAL = <<ALIAS_GRPFOR>><<SUBSTR_SX5_D1_FILIAL>> " + ;              
              "  AND GRPFOR.X5_TABELA = 'Y7' " + ;
	          "  AND GRPFOR.X5_CHAVE = A2_GRUPO " + ;
	          "  AND GRPFOR.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<CTT_COMPANY>> CTT " + ; //Centro de custo
              "   ON CTT_FILIAL = <<SUBSTR_CTT_D1_FILIAL>> " + ;
	          "  AND CTT_CUSTO = D1_CC " + ;
	          "  AND CTT.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SF1_COMPANY>> SF1 " + ; //Transportadora
              "   ON F1_FILIAL = <<SUBSTR_SF1_D1_FILIAL>> " + ;
              "  AND F1_DOC = D1_DOC " + ;
              "  AND F1_SERIE = D1_SERIE " + ;
              "  AND F1_FORNECE = D1_FORNECE " + ;
              "  AND F1_LOJA = D1_LOJA " + ;
              "  AND SF1.D_E_L_E_T_ = '' " + ;
              " LEFT JOIN <<SA4_COMPANY>> SA4 " + ;
              "   ON A4_FILIAL = <<SUBSTR_SA4_F1_FILIAL>> " + ;
              "  AND A4_COD = F1_TRANSP " + ;
              "  AND SA4.D_E_L_E_T_ = '' " + ;
              " LEFT JOIN <<SE4_COMPANY>> SE4 " + ; //Condicao de pagto
              "   ON E4_FILIAL = <<SUBSTR_SE4_F1_FILIAL>> " + ;
              "  AND E4_CODIGO = F1_COND " + ;
              "  AND SE4.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<ACV_COMPANY>> ACV " + ; //Familia Comercial
              "   ON ACV_FILIAL = <<SUBSTR_ACV_D1_FILIAL>> " + ;
              "  AND ACV_CODPRO = D1_COD " + ;
              "  AND ACV.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<ACU_COMPANY>> ACU " + ;
              "   ON ACU_FILIAL = <<SUBSTR_ACU_ACV_FILIAL>> " + ;              
              "  AND ACU_COD = ACV.ACV_CATEGO " + ;
              "  AND ACU.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SC7_COMPANY>> SC7 " + ; //Pedido de compra  
              "   ON C7_FILIAL = <<SUBSTR_SC7_D1_FILIAL>> " + ;
              "  AND C7_NUM = D1_PEDIDO " + ;
              "  AND C7_ITEM = D1_ITEMPC " + ;
              "  AND C7_PRODUTO = D1_COD " + ;
              "  AND SC7.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SC1_COMPANY>> SC1 " + ; //Solicitacao de compra
              "   ON C1_FILIAL = <<SUBSTR_SC1_C7_FILIAL>> " + ; 
              "  AND C1_NUM = C7_NUMSC " + ; 
              "  AND C1_ITEM = C7_ITEMSC " + ;
              "  AND C1_PRODUTO = C7_PRODUTO " + ;
              "  AND SC1.D_E_L_E_T_ = '' " + ;
              " LEFT JOIN <<SY1_COMPANY>> SY1 " + ; //Comprador
              "   ON Y1_FILIAL = <<SUBSTR_SY1_C7_FILIAL>> " + ;              
              "  AND Y1_COD = C7_COMPRA " + ;
              "  AND SY1.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SX5_COMPANY>> CFOP " + ; //CFOP
			  "   ON CFOP.X5_FILIAL = <<ALIAS_CFOP>><<SUBSTR_SX5_D1_FILIAL>> " + ;              
              "  AND CFOP.X5_TABELA = '13' " + ;
	          "  AND CFOP.X5_CHAVE = D1_CF " + ;
	          "  AND CFOP.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SF4_COMPANY>> SF4 " + ; //TES
			  "   ON F4_FILIAL = <<SUBSTR_SF4_D1_FILIAL>> " + ;              
              "  AND F4_CODIGO = D1_TES " + ;
	          "  AND SF4.D_E_L_E_T_ = ' ' " + ;
              " LEFT JOIN <<SAH_COMPANY>> SAH " + ; //Unidade de medida
              "   ON AH_FILIAL = <<SUBSTR_SAH_D1_FILIAL>> " + ;
	          "  AND AH_UNIMED = D1_UM " + ; 
	          "  AND SAH.D_E_L_E_T_ = ' ' " + ;	
              " WHERE D1_ORIGLAN <> 'LF' " + ;
              "  AND D1_TIPO NOT IN ('D','B') " + ;
              "  AND D1_DTDIGIT BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
              "  AND SD1.D_E_L_E_T_ = ' ' " + ;
              "  <<AND_XFILIAL_D1_FILIAL>> "
	
Return cQuery	
