#INCLUDE "BADEFINITION.CH"

NEW ENTITY PAGCARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPagCarteira
Visualiza as informacoes de Contas a Pagar Carteira da area do Financeiro.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Class BAPagCarteira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPagCarteira
	_Super:Setup("PagamentoCarteira", FACT, "SE2")   
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPagCarteira
	Local cQuery := ""
	
	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, <<KEY_FILIAL_E2_FILIAL>> AS BK_FILIAL, " + ; 
              "       <<KEY_FILIAL_E2_FILORIG>> AS BK_FILIAL_ORIGEM, " + ;
              "       <<KEY_SX5_TIPO.X5_FILIAL+E2_TIPO>> AS BK_ESPEC_DOC, " + ;
              "       <<KEY_SA6_A6_FILIAL+E2_BCOPAG+A6_AGENCIA+A6_NUMCON>> AS BK_BCO, " + ;
              "       <<KEY_CTT_CTT_FILIAL+E2_CCUSTO>> AS BK_CENTRO_CUSTO, " + ;
              "       <<KEY_SED_ED_FILIAL+E2_NATUREZ>> AS BK_NAT_FINANCEIRA, " + ;              
              "       <<KEY_SA2_A2_FILIAL+E2_FORNECE+E2_LOJA>> AS BK_FORNECEDOR, " + ;
              "       <<KEY_SX5_GRU.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR, " + ;      
              "		 <<EXTRACTION_DATE>> AS DATA_DA_EXTRACAO, " + ;        
              "       CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO, " + ;
              "       E2_EMISSAO AS DATA_DE_EMISSAO, E2_VENCREA AS VENCIMENTO_REAL, " + ;
              "	      E2_PREFIXO AS PREFIXO_TITULO, E2_NUM AS NUMERO_TITULO, E2_PARCELA AS NUMERO_DA_PARCELA, E2_NUMBOR AS NUMERO_DO_BORDERO, "
              
    if (cPaisloc == "BRA")
		    cQuery += "E2_SALDO AS SALDO, "
    else
        cQuery += "CASE WHEN E2_MOEDA = 1 " +;
			      " THEN E2_SALDO " +;
		          " ELSE E2_SALDO * E2_TXMOEDA " +;
		          "END AS SALDO, "
    endif

    cQuery += "<<CODE_INSTANCE>> AS INSTANCIA, "
	cQuery += "<<KEY_MOEDA_E2_MOEDA>> AS BK_MOEDA, "
	cQuery += "COALESCE(E2_TXMOEDA,0) AS TAXA_MOEDA, " 
    cQuery += "E2_VENCORI AS VENCIMENTO_ORIGINAL, " 
    cQuery += "E2_TIPO AS TIPO_DO_TITULO "              
              
    cQuery += "  FROM <<SE2_COMPANY>> SE2 " + ; 
              "  LEFT JOIN <<SX5_COMPANY>> TIPO " + ;
			  "    ON TIPO.X5_FILIAL = <<ALIAS_TIPO>><<SUBSTR_SX5_E2_FILIAL>> " + ;
			  "   AND TIPO.X5_TABELA = '05' " + ;
			  "   AND TIPO.X5_CHAVE = E2_TIPO " + ;
			  "   AND TIPO.D_E_L_E_T_ = ' ' " + ;              
              "  LEFT JOIN <<SA6_COMPANY>> SA6 " + ; 	
              "    ON SA6.A6_FILIAL = <<SUBSTR_SA6_E2_FILIAL>> " + ; 
              "   AND SA6.A6_COD = SE2.E2_BCOPAG " + ;
              "   AND SA6.A6_AGENCIA = SE2.E2_FORAGE " + ;
	          "   AND SA6.A6_NUMCON = SE2.E2_FORCTA " + ; 
              "   AND SA6.D_E_L_E_T_ = ' ' " + ;
              "  LEFT JOIN <<CTT_COMPANY>> CTT " + ; 	
              "    ON CTT.CTT_FILIAL = <<SUBSTR_CTT_E2_FILIAL>> " + ; 
              "   AND CTT.CTT_CUSTO = SE2.E2_CCUSTO " + ;
              "   AND CTT.D_E_L_E_T_ = ' ' " + ;
              "  LEFT JOIN <<SED_COMPANY>> SED " + ; 	
              "    ON SED.ED_FILIAL = <<SUBSTR_SED_E2_FILIAL>> " + ; 
              "   AND SED.ED_CODIGO = SE2.E2_NATUREZ " + ;
              "   AND SED.D_E_L_E_T_ = ' ' " + ;
              "  LEFT JOIN <<SA2_COMPANY>> SA2 " + ;	
              "    ON SA2.A2_FILIAL = <<SUBSTR_SA2_E2_FILIAL>> " + ;
              "   AND SA2.A2_COD = SE2.E2_FORNECE " + ;
              "   AND SA2.A2_LOJA = SE2.E2_LOJA " + ;	
              "   AND SA2.D_E_L_E_T_ = ' ' " + ;
              "  LEFT JOIN <<SX5_COMPANY>> GRU " + ;
			  "    ON GRU.X5_FILIAL = <<ALIAS_GRU>><<SUBSTR_SX5_E2_FILIAL>> " + ;
			  "   AND GRU.X5_TABELA = 'Y7' " + ;
			  "   AND GRU.X5_CHAVE = A2_GRUPO " + ;
			  "   AND GRU.D_E_L_E_T_ = ' ' " + ;              
              " WHERE SE2.E2_SALDO = SE2.E2_VALOR " + ;
              "   AND SE2.D_E_L_E_T_ = ' ' " + ;
              "   <<AND_XFILIAL_E2_FILIAL>> " 
			   
Return cQuery	
