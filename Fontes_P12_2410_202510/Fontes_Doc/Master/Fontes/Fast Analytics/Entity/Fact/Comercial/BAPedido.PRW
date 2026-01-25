#INCLUDE "BADEFINITION.CH"

NEW ENTITY PEDIDO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPedido
Visualiza as informacoes dos Pedidos de Venda da area de Comercial

@author  henrique.cesar
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BAPedido from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  henrique.cesar
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPedido
	_Super:Setup("Pedido", FACT, "SC5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author henrique.cesar
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPedido
	Local cQuery := ""
	
	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ; 
		"<<KEY_FILIAL_C5_FILIAL>> AS BK_FILIAL, " + ;
		"<<KEY_SA1_A1_FILIAL+C5_CLIENTE+C5_LOJACLI>> AS BK_CLIENTE, " + ; 
		"<<KEY_SA4_A4_FILIAL+C5_TRANSP>> AS BK_TRANSPORTADORA, " + ;
		"<<KEY_SA3_A3_FILIAL+C5_VEND1>> AS BK_VENDEDOR, " + ;
		"<<KEY_SE4_E4_FILIAL+C5_CONDPAG>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;
		"<<KEY_SB1_B1_FILIAL+C6_PRODUTO>> AS BK_ITEM, " + ;
		"<<KEY_SF4_F4_FILIAL+C6_TES>> AS BK_TES, " + ;
		"CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ; 
        "C5_NUM AS NUMERO_DO_PEDIDO,  " + ;
		"C5_EMISSAO AS DATA_DA_VENDA," + ;
        "C6_ENTREG AS DATA_DA_ENTREGA, " + ;
        "C6_ITEM AS NUMERO_DO_ITEM, "
	    
	if (cPaisloc == "BRA")
		cQuery += "C6_VALOR AS VL_VENDA_TOTAL, " +;
		"C6_QTDVEN AS QTDE_VENDIDA, " +;
		"C6_PRCVEN AS VL_PRECO_UNITARIO, " +;
		"C6_VALOR AS VL_VENDA_MERCADORIA, " +;
		"C6_VALOR AS VL_VENDA_LIQUIDA, " +;
		"C6_PRUNIT AS VL_PRECO_LISTA, "
	else
		cQuery += "C6_QTDVEN AS QTDE_VENDIDA, " +;
				  "CASE WHEN C5_MOEDA = 1 " +;
				  " THEN C6_VALOR " +;
				  " ELSE C6_VALOR * C5_TXMOEDA " +;
				  "END AS VL_VENDA_TOTAL, " +;
				  "CASE WHEN C5_MOEDA = 1 " +;
				  " THEN C6_PRCVEN " +;
				  " ELSE C6_PRCVEN * C5_TXMOEDA " +;
				  "END AS VL_PRECO_UNITARIO, " +;
				  "CASE WHEN C5_MOEDA = 1 " +;
				  " THEN C6_VALOR " +;
				  " ELSE C6_VALOR * C5_TXMOEDA " +;
				  "END AS VL_VENDA_MERCADORIA, " +;
				  "CASE WHEN C5_MOEDA = 1 " +;
				  " THEN C6_VALOR " +;
				  " ELSE C6_VALOR * C5_TXMOEDA " +;
				  "END AS VL_VENDA_LIQUIDA, " +;
				  "CASE WHEN C5_MOEDA = 1 " +;
				  " THEN C6_PRUNIT " +;
				  " ELSE C6_PRUNIT * C5_TXMOEDA " +;
				 "END AS VL_PRECO_LISTA, "
	endif
		
	cQuery += "CASE WHEN C9_BLEST = ' ' AND C9_BLCRED = '  ' THEN 'Liberado' ELSE 'Bloqueado' END STATUS_DO_ITEM_DO_PEDIDO, " + ; 
	    "CASE WHEN C5_LIBEROK = '  ' AND C5_NOTA = '  ' AND C5_BLQ = '  ' THEN 'Aberto' " + ;
		   "WHEN C5_NOTA <> '  ' OR C5_LIBEROK = 'E' AND C5_BLQ = '  ' THEN 'Encerrado' " + ;
           "WHEN (C5_LIBEROK <> '  ' AND C5_NOTA = '  ' AND C5_BLQ = '  ') THEN 'Liberado' " + ;
           "WHEN (C5_BLQ = '1') THEN 'Bloqueio por Regra' " + ;
           "WHEN (C5_BLQ= '2') THEN 'Bloqueio por Verba' END STATUS_DO_PEDIDO, " + ;
		   "<<CODE_INSTANCE>> AS INSTANCIA, " +; 
           "<<KEY_MOEDA_C5_MOEDA>> AS BK_MOEDA, " +;
           "COALESCE(C5_TXMOEDA,0) AS TAXA_MOEDA " +;
      	 "FROM <<SC5_COMPANY>> SC5 " + ;
      	"INNER JOIN <<SC6_COMPANY>> SC6 " + ; 
		   "ON C6_FILIAL = <<SUBSTR_SC6_C5_FILIAL>> " + ;
	   	  "AND C6_NUM = C5_NUM " + ;
          "AND SC6.D_E_L_E_T_ = ' ' " + ;
        "INNER JOIN <<SF4_COMPANY>> SF4 " + ;
	       "ON F4_FILIAL = <<SUBSTR_SF4_C5_FILIAL>>  " + ;
		  "AND SC6.C6_TES = SF4.F4_CODIGO " + ; 
		  "AND SF4.D_E_L_E_T_ = ' ' " + ;
		 "LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
		   "ON B1_FILIAL = <<SUBSTR_SB1_C5_FILIAL>> " + ;
		  "AND B1_COD = C6_PRODUTO " + ;
		  "AND SB1.D_E_L_E_T_ = ' ' " + ;
		 "LEFT JOIN <<SA4_COMPANY>> SA4 " + ;
		   "ON A4_FILIAL = <<SUBSTR_SA4_C5_FILIAL>> " + ;
		  "AND A4_COD = C5_TRANSP " + ;
		  "AND SA4.D_E_L_E_T_ = ' ' " + ;
		 "LEFT JOIN <<SA1_COMPANY>> SA1 " + ;
		   "ON A1_FILIAL = <<SUBSTR_SA1_C5_FILIAL>> " + ;
		  "AND A1_COD = C5_CLIENTE " + ;
		  "AND A1_LOJA = C5_LOJACLI " + ;
		  "AND SA1.D_E_L_E_T_ = ' ' " + ;
		 "LEFT JOIN <<SA3_COMPANY>> SA3 " + ;
		   "ON A3_FILIAL = <<SUBSTR_SA3_C5_FILIAL>> " + ;
		  "AND A3_COD = C5_VEND1 " + ;
		  "AND SA3.D_E_L_E_T_ = ' ' " + ;
		 "LEFT JOIN <<SE4_COMPANY>> SE4 " + ;
		   "ON E4_FILIAL = <<SUBSTR_SE4_C5_FILIAL>> " + ;
		  "AND E4_CODIGO = C5_CONDPAG " + ;
		  "AND SE4.D_E_L_E_T_ = ' ' " + ;
         "LEFT JOIN (SELECT C9_BLEST, C9_BLCRED, C9_PEDIDO, C9_PRODUTO, C9_ITEM, C9_FILIAL " + ; 
                      "FROM <<SC9_COMPANY>> SC9 " + ; 
                     "WHERE SC9.D_E_L_E_T_ = ' ' " + ;
  	                   "AND C9_SEQUEN = (SELECT MAX(C9_SEQUEN) " + ;
                    	                  "FROM <<SC9_COMPANY>> A " + ;
                  		                 "WHERE A.C9_FILIAL = SC9.C9_FILIAL " + ;
                  			               "AND A.C9_PEDIDO = SC9.C9_PEDIDO " + ;
                  			               "AND A.C9_PRODUTO = SC9.C9_PRODUTO " + ;
                   			               "AND A.C9_ITEM = SC9.C9_ITEM " + ;
                  			               "AND A.D_E_L_E_T_ = ' ') ) C9 " + ; 
           "ON C9.C9_PEDIDO = C6_NUM " + ;
  	      "AND C9.C9_PRODUTO = C6_PRODUTO " + ;
	      "AND C9.C9_ITEM = C6_ITEM " + ;
	      "AND C9.C9_FILIAL = <<SUBSTR_SC9_C5_FILIAL>> " + ; 
		"WHERE C5_EMISSAO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
		  "AND C5_TIPO = 'N' " + ;   
          "AND SC5.D_E_L_E_T_ = ' ' " + ; 
          " <<AND_XFILIAL_C5_FILIAL>> "

Return cQuery