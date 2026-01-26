#INCLUDE "BADEFINITION.CH"

NEW ENTITY NOTAFISCAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BANotaFiscal
Visualiza as informacoess das Notas Fiscais de Saida da area de Comercial.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Class BANotaFiscal from BAEntity
	Method Setup() CONSTRUCTOR
	Method BuildQuery()
	Method BuildQryBRA()
	Method BuildQryMI()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BANotaFiscal
	_Super:Setup("NotaFiscal", FACT, "SF2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BANotaFiscal
	Local cQuery := ""
	
	if (cPaisloc == "BRA")
		cQuery := ::BuildQryBRA()
	else
		cQuery := ::BuildQryMI()
	endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQryBRA
Query para o Brasil.

@author  Andreia Lima
@since   12/06/2020
/*/
//-------------------------------------------------------------------
Method BuildQryBRA() Class BANotaFiscal
	Local cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
		"<<KEY_FILIAL_D2_FILIAL>> AS BK_FILIAL, " + ; 
		"F2_SERIE AS SERIE_DA_NOTA_FISCAL, " + ; 
		"F2_DOC AS NUMERO_DA_NOTA_FISCAL, " + ; 
		"D2_PEDIDO AS NUMERO_PEDIDO_VENDA, " + ; 
		"D2_ITEM AS NUMERO_ITEM, " + ; 
		"CASE WHEN LTRIM(RTRIM(F2_EMISSAO)) = ' ' THEN ' ' ELSE F2_EMISSAO END AS DATA_DE_EMISSAO, " + ; 
		"CASE WHEN LTRIM(RTRIM(F2_EMINFE)) = ' ' THEN ' ' ELSE F2_EMINFE END AS DATA_SAIDA_NF, " + ;
		"F2_TPFRETE AS TIPO_DE_FRETE, " + ; 
		"D2_TIPO AS TIPO_DE_NOTA_FISCAL, " + ; 
		"D2_ORIGLAN AS ORIGEM_DO_LANCAMENTO, " + ;
		"<<KEY_SB1_B1_FILIAL+D2_COD>> AS BK_ITEM, " + ; 
		"<<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " + ; 
		"<<KEY_SA3_A3_FILIAL+F2_VEND1>> AS BK_VENDEDOR, " + ;
		"<<KEY_SF4_F4_FILIAL+D2_TES>> AS BK_TES, " + ;
		"<<KEY_SX5_CFOP.X5_FILIAL+D2_CF>> AS BK_CFOP, " + ;
		"<<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE, " + ; 
		"<<KEY_SA1_A1_FILIAL+D2_CLIENTE+D2_LOJA>> AS BK_CLIENTE, " + ; 
		"CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ; 
		"<<KEY_SE4_E4_FILIAL+F2_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;
		"<<KEY_ACY_ACY_FILIAL+A1_GRPVEN>> AS BK_REGIAO_COMERCIAL, " + ; 
		"<<KEY_SAH_AH_FILIAL+D2_UM>> AS BK_UNIDADE_DE_MEDIDA, " + ;
		"<<FORMATVALUE(D2_VALBRUT)>> AS VL_FATURAMENTO_TOTAL, " + ; 
		"<<FORMATVALUE(D2_VALICM)>> AS VL_ICMS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALIPI)>> AS VL_IPI_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALFRE)>> AS VL_FRETE_NF, " + ; 
		"<<FORMATVALUE(D2_DESPESA)>> AS VL_DESPESA, " + ; 
		"<<FORMATVALUE(D2_TOTAL)>> AS VL_FATURAMENTO_MERCADORIA, " + ; 
		"<<FORMATVALUE(D2_VALIMP6)>> AS VL_PIS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALIMP5)>> AS VL_COFINS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_QUANT)>> AS QTD_FATURADA_ITEM, " + ; 
		"<<FORMATVALUE(D2_VALISS)>> AS VL_ISS_FATURAMENTO, " + ;
		"<<FORMATVALUE(D2_ICMSRET)>> AS VL_ICMS_SUBST_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_DESCON)>> AS VL_DESCONTO_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALIRRF)>> AS VL_IRF_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALINS)>> AS VL_INSS_FATURAMENTO, " + ;
		"<<FORMATVALUE(D2_PESO * D2_QUANT,12,4)>> AS PESO_LIQUIDO, " + ; 
		"<<FORMATVALUE(B1_PESBRU * D2_QUANT,12,4)>> AS PESO_BRUTO, " + ; 
		"1 AS QTD, " + ; 
		"<<FORMATVALUE(D2_PRUNIT)>> AS VL_UNITARIO, " + ; 
		"<<FORMATVALUE(D2_SEGURO)>> AS VL_SEGURO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " +; 
		"<<KEY_MOEDA_F2_MOEDA>> AS BK_MOEDA, " +;
		"COALESCE(F2_TXMOEDA,0) AS TAXA_MOEDA " +;
		"FROM <<SD2_COMPANY>> SD2 " + ; 
		"INNER JOIN <<SF2_COMPANY>> SF2 " + ; 
		"ON F2_FILIAL = <<SUBSTR_SF2_D2_FILIAL>> " + ;
			"AND F2_CLIENTE = D2_CLIENTE " + ; 
			"AND F2_LOJA = D2_LOJA  " + ;
			"AND F2_DOC = D2_DOC  " + ;
			"AND F2_SERIE = D2_SERIE  " + ;
			"AND SF2.D_E_L_E_T_= ' '  " + ;
		"INNER JOIN  <<SB1_COMPANY>> SB1  " + ;
		"ON B1_FILIAL = <<SUBSTR_SB1_D2_FILIAL>> " + ;
			"AND SB1.B1_COD = SD2.D2_COD " + ; 
			"AND SB1.D_E_L_E_T_= ' '  " + ;
		"INNER JOIN <<SF4_COMPANY>> SF4 " + ;
		"ON F4_FILIAL = <<SUBSTR_SF4_D2_FILIAL>> " + ;
			"AND SF4.F4_CODIGO = SD2.D2_TES " + ; 
			"AND SF4.D_E_L_E_T_ = ' '  " + ;
		"LEFT JOIN <<SA1_COMPANY>> SA1 " + ;
		"ON A1_FILIAL = <<SUBSTR_SA1_D2_FILIAL>> " + ;  
			"AND SA1.A1_COD = SF2.F2_CLIENTE " + ;
			"AND SA1.A1_LOJA = SF2.F2_LOJA " + ; 
			"AND SA1.D_E_L_E_T_= ' '  " + ;
		"LEFT JOIN <<SBM_COMPANY>> SBM " + ;
		"ON BM_FILIAL = <<SUBSTR_SBM_D2_FILIAL>> " + ;
			"AND BM_GRUPO = B1_GRUPO " + ;
			"AND SBM.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SA3_COMPANY>> SA3 " + ;
		"ON A3_FILIAL = <<SUBSTR_SA3_D2_FILIAL>> " + ;
			"AND A3_COD = F2_VEND1 " + ;
			"AND SA3.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SX5_COMPANY>> CFOP " + ;
		"ON X5_FILIAL = <<ALIAS_CFOP>><<SUBSTR_SX5_D2_FILIAL>> " + ;
			"AND X5_TABELA = '13' " + ;
			"AND X5_CHAVE = D2_CF " + ;
			"AND CFOP.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SE4_COMPANY>> SE4 " + ;
		"ON E4_FILIAL = <<SUBSTR_SE4_D2_FILIAL>> " + ;
			"AND E4_CODIGO = F2_COND " + ;
			"AND SE4.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<ACY_COMPANY>> ACY " + ;
		"ON ACY_FILIAL = <<SUBSTR_ACY_D2_FILIAL>> " + ;
			"AND ACY_GRPVEN = A1_GRPVEN " + ;
			"AND ACY.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
		"ON AH_FILIAL = <<SUBSTR_SAH_D2_FILIAL>> " + ;
			"AND AH_UNIMED = D2_UM " + ;
			"AND SAH.D_E_L_E_T_ = ' ' " + ;
       "WHERE  D2_EMISSAO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
       	"AND D2_TIPO NOT IN ('B', 'D' ) " + ;
       	"AND SD2.D_E_L_E_T_ = ' '  " + ;
       	"<<AND_XFILIAL_D2_FILIAL>> " 

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQryMI()
Query para o Mercado Internacional.
Criado devido o MI usar uma ordem fixa nas colunas, sendo
que para manter essa ordem com um unico metodo para BRA e MI
seriam necessários muitos IFs para verificar o pais

@author  Andreia Lima
@since   12/06/2020
/*/
//-------------------------------------------------------------------

Method BuildQryMI() Class BANotaFiscal
	Local cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
		"<<KEY_FILIAL_D2_FILIAL>> AS BK_FILIAL, " + ; 
		"F2_SERIE AS SERIE_DA_NOTA_FISCAL, " + ; 
		"F2_DOC AS NUMERO_DA_NOTA_FISCAL, " + ; 
		"D2_PEDIDO AS NUMERO_PEDIDO_VENDA, " + ; 
		"D2_ITEM AS NUMERO_ITEM, " + ; 
		"CASE WHEN LTRIM(RTRIM(F2_EMISSAO)) = ' ' THEN ' ' ELSE F2_EMISSAO END AS DATA_DE_EMISSAO, " +;
		"' ' AS DATA_SAIDA_NF, " +;
		"F2_TPFRETE AS TIPO_DE_FRETE, " + ; 
		"D2_TIPO AS TIPO_DE_NOTA_FISCAL, " + ; 
		"D2_ORIGLAN AS ORIGEM_DO_LANCAMENTO, " + ;
		"<<KEY_SB1_B1_FILIAL+D2_COD>> AS BK_ITEM, " + ; 
		"<<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE, " + ; 
		"<<KEY_SA3_A3_FILIAL+F2_VEND1>> AS BK_VENDEDOR, " + ;
		"<<KEY_SF4_F4_FILIAL+D2_TES>> AS BK_TES, " + ;
		"<<KEY_SX5_CFOP.X5_FILIAL+D2_CF>> AS BK_CFOP, " + ;
		"<<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE, " + ; 
		"<<KEY_SA1_A1_FILIAL+D2_CLIENTE+D2_LOJA>> AS BK_CLIENTE, " + ; 
		"CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ; 
		"<<KEY_SE4_E4_FILIAL+F2_COND>> AS BK_CONDICAO_DE_PAGAMENTO, " + ;
		"<<KEY_ACY_ACY_FILIAL+A1_GRPVEN>> AS BK_REGIAO_COMERCIAL, " + ; 
		"<<KEY_SAH_AH_FILIAL+D2_UM>> AS BK_UNIDADE_DE_MEDIDA, " +;
		"CASE WHEN F2_MOEDA = 1 THEN " +;
			"CASE WHEN D2_VALBRUT = 0 " +;
			"	THEN D2_TOTAL + D2_VALIMP1 " +;
			"	ELSE D2_VALBRUT " +;
			"END " +;
		"ELSE " +;
			"CASE WHEN D2_VALBRUT = 0 " +;
			"	THEN (D2_TOTAL + D2_VALIMP1) * F2_TXMOEDA " +;
			"	ELSE D2_VALBRUT * F2_TXMOEDA " +;
			"END " +;
		"END AS VL_FATURAMENTO_TOTAL," +;
		"<<FORMATVALUE(D2_VALICM)>> AS VL_ICMS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALIPI)>> AS VL_IPI_FATURAMENTO, " +;
		"CASE WHEN F2_MOEDA = 1 " +;
		" THEN D2_VALFRE " +;
		" ELSE D2_VALFRE * F2_TXMOEDA " +;
		"END AS VL_FRETE_NF, " +;
		"CASE WHEN F2_MOEDA = 1 " +;
		" THEN D2_DESPESA " +;
		" ELSE D2_DESPESA * F2_TXMOEDA " +;
		"END AS VL_DESPESA, " +;
		"CASE WHEN F2_MOEDA = 1 " +;
		" THEN D2_TOTAL " +;
		" ELSE D2_TOTAL * F2_TXMOEDA " +;
		"END AS VL_FATURAMENTO_MERCADORIA, " +;
		"<<FORMATVALUE(D2_VALIMP6)>> AS VL_PIS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_VALIMP5)>> AS VL_COFINS_FATURAMENTO, " + ; 
		"<<FORMATVALUE(D2_QUANT)>> AS QTD_FATURADA_ITEM, " + ; 
		"<<FORMATVALUE(D2_VALISS)>> AS VL_ISS_FATURAMENTO, " +;
		"<<FORMATVALUE(D2_ICMSRET)>> AS VL_ICMS_SUBST_FATURAMENTO, " +;
		"CASE WHEN F2_MOEDA = 1 " +;
		" THEN D2_DESCON " +;
		" ELSE D2_DESCON * F2_TXMOEDA " +;
		"END AS VL_DESCONTO_FATURAMENTO, " +;		
		"0 AS VL_IRF_FATURAMENTO, " +;
		"<<FORMATVALUE(D2_VALINS)>> AS VL_INSS_FATURAMENTO, " + ;
		"<<FORMATVALUE(D2_PESO * D2_QUANT,10,3)>> AS PESO_LIQUIDO, " + ; 
		"<<FORMATVALUE(B1_PESBRU * D2_QUANT,11,4)>> AS PESO_BRUTO, " + ; 
		"1 AS QTD, " +;
		"CASE " +;
		"WHEN F2_MOEDA = 1 " +;
			"THEN CASE " +;
				"WHEN D2_PRUNIT > 0 " +;
					"THEN D2_PRUNIT " +;
				"ELSE (D2_TOTAL + D2_DESCON) / D2_QUANT " +;
				"END " +;
		"ELSE CASE " +; 
			"WHEN D2_PRUNIT > 0 " +;
				"THEN D2_PRUNIT * F2_TXMOEDA " +;
			"ELSE ((D2_TOTAL + D2_DESCON) / D2_QUANT) * F2_TXMOEDA " +;
			"END " +;
		"END AS VL_UNITARIO, " +;
		"CASE WHEN F2_MOEDA = 1 " +;
		" THEN D2_SEGURO " +;
		" ELSE D2_SEGURO * F2_TXMOEDA " +; 
		"END AS VL_SEGURO, " +;
		"<<CODE_INSTANCE>> AS INSTANCIA, " +; 
		"<<KEY_MOEDA_F2_MOEDA>> AS BK_MOEDA, " +;
		"COALESCE(F2_TXMOEDA,0) AS TAXA_MOEDA " +;
		" FROM <<SD2_COMPANY>> SD2 " + ; 
		"INNER JOIN <<SF2_COMPANY>> SF2 " + ; 
		"ON F2_FILIAL = <<SUBSTR_SF2_D2_FILIAL>> " + ;
			"AND F2_CLIENTE = D2_CLIENTE " + ; 
			"AND F2_LOJA = D2_LOJA  " + ;
			"AND F2_DOC = D2_DOC  " + ;
			"AND F2_SERIE = D2_SERIE  " + ;
			"AND SF2.D_E_L_E_T_= ' '  " + ;
		"INNER JOIN  <<SB1_COMPANY>> SB1  " + ;
		"ON B1_FILIAL = <<SUBSTR_SB1_D2_FILIAL>> " + ;
			"AND SB1.B1_COD = SD2.D2_COD " + ; 
			"AND SB1.D_E_L_E_T_= ' '  " + ;
		"INNER JOIN <<SF4_COMPANY>> SF4 " + ;
		"ON F4_FILIAL = <<SUBSTR_SF4_D2_FILIAL>> " + ;
			"AND SF4.F4_CODIGO = SD2.D2_TES " + ; 
			"AND SF4.D_E_L_E_T_ = ' '  " + ;
		"LEFT JOIN <<SA1_COMPANY>> SA1 " + ;
		"ON A1_FILIAL = <<SUBSTR_SA1_D2_FILIAL>> " + ;  
			"AND SA1.A1_COD = SF2.F2_CLIENTE " + ;
			"AND SA1.A1_LOJA = SF2.F2_LOJA " + ; 
			"AND SA1.D_E_L_E_T_= ' '  " + ;
		"LEFT JOIN <<SBM_COMPANY>> SBM " + ;
		"ON BM_FILIAL = <<SUBSTR_SBM_D2_FILIAL>> " + ;
			"AND BM_GRUPO = B1_GRUPO " + ;
			"AND SBM.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SA3_COMPANY>> SA3 " + ;
		"ON A3_FILIAL = <<SUBSTR_SA3_D2_FILIAL>> " + ;
			"AND A3_COD = F2_VEND1 " + ;
			"AND SA3.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SX5_COMPANY>> CFOP " + ;
		"ON X5_FILIAL = <<ALIAS_CFOP>><<SUBSTR_SX5_D2_FILIAL>> " + ;
			"AND X5_TABELA = '13' " + ;
			"AND X5_CHAVE = D2_CF " + ;
			"AND CFOP.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SE4_COMPANY>> SE4 " + ;
		"ON E4_FILIAL = <<SUBSTR_SE4_D2_FILIAL>> " + ;
			"AND E4_CODIGO = F2_COND " + ;
			"AND SE4.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<ACY_COMPANY>> ACY " + ;
		"ON ACY_FILIAL = <<SUBSTR_ACY_D2_FILIAL>> " + ;
			"AND ACY_GRPVEN = A1_GRPVEN " + ;
			"AND ACY.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SAH_COMPANY>> SAH " + ;
		"ON AH_FILIAL = <<SUBSTR_SAH_D2_FILIAL>> " + ;
			"AND AH_UNIMED = D2_UM " + ;
			"AND SAH.D_E_L_E_T_ = ' ' " + ;
       "WHERE D2_EMISSAO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
       	"AND D2_TIPO NOT IN ('B', 'D' ) " + ;
       	"AND SD2.D_E_L_E_T_ = ' '  " + ;
       	"<<AND_XFILIAL_D2_FILIAL>> " 

Return cQuery
