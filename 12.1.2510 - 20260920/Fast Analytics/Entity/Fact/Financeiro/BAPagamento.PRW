#INCLUDE "BADEFINITION.CH"

NEW ENTITY PAGAMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPagamento
Visualiza as informacoes das titulos a pagar que foram emitidos e que
foram parcialmente ou totalmente pagos.

@author  Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Class BAPagamento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao

@author  Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPagamento
	_Super:Setup("Pagamento", FACT, "SE2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPagamento
	Local cQuery := ""

	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA " + ; 
		",<<KEY_FILIAL_E2_FILIAL>> AS BK_FILIAL " + ;
		",<<KEY_SX5_DOCESP.X5_FILIAL+E2_TIPO>> AS BK_ESPEC_DOC " + ;
		",<<KEY_###_''>> AS BK_TPCARTEIRA " + ;
		",<<KEY_CTT_CTT_FILIAL+E2_CCUSTO>> AS BK_CENTRO_CUSTO " + ;
		",<<KEY_SED_ED_FILIAL+E2_NATUREZ>> AS BK_NAT_FINANCEIRA " + ;
		",<<KEY_SA2_A2_FILIAL+E2_FORNECE+E2_LOJA>> AS BK_FORNECEDOR " + ;
		",<<KEY_FILIAL_E2_FILORIG>> AS BK_FILIAL_ORIGEM " + ;
		",CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO " + ;
		",<<KEY_SX5_GRPFORN.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR " + ;
		",<<KEY_SA6_A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON>> AS BK_BCO " + ;
		",E2_EMISSAO AS DATA_DE_EMISSAO " + ;
		",E2_BAIXA AS DATA_DA_BAIXA_DO_TITULO " + ;
		",E2_MOVIMEN AS DATA_DA_MOVIMENTACAO " + ;
		",E2_VENCREA AS VENCIMENTO_REAL " + ;
		",E2_NUM AS NUMERO_TITULO " + ;
		",E2_PARCELA AS NUMERO_DA_PARCELA " + ;
		",E2_NUMBOR AS NUMERO_DO_BORDERO " + ;		
		",E2_LOJA AS LOJA " + ;
		",A2_TIPO AS TIPO_DE_FORNECEDOR " + ;		
		",E2_PREFIXO AS PREFIXO_TITULO " + ;
		",E2_SEQBX AS SEQUENCIA_DA_BAIXA"

	if (cPaisloc == "BRA")
		cQuery += ",E2_VALOR AS VALOR_DA_MOVIMENTACAO " +;
		",E2_SALDO AS VALOR_VENCIMENTO " +;
		",E2_DESCONT AS VALOR_DO_DESCONTO " +;
		",E2_JUROS AS VALOR_DO_JUROS " +;
		",E2_MULTA AS VALOR_DA_MULTA " +;
		",E2_ACRESC AS VALOR_ACRESCIMO " +;
		",E2_DECRESC AS VALOR_DECRESCIMO "
	else
		cQuery += ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_VALOR " +;
		          " ELSE E2_VALOR * E2_TXMOEDA " +;
		          "END AS VALOR_DA_MOVIMENTACAO " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_SALDO " +;
		          "ELSE E2_SALDO * E2_TXMOEDA " +;
 		          "END AS VALOR_VENCIMENTO " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_DESCONT " +;
		          " ELSE E2_DESCONT * E2_TXMOEDA " +;
		          "END AS VALOR_DO_DESCONTO " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_JUROS " +;
		          " ELSE E2_JUROS * E2_TXMOEDA " +;
		          "END AS VALOR_DO_JUROS " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_MULTA " +;
		          " ELSE E2_MULTA * E2_TXMOEDA " +;
		          "END AS VALOR_DA_MULTA " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_ACRESC " +;
		          " ELSE E2_ACRESC * E2_TXMOEDA " +;
		          "END AS VALOR_ACRESCIMO " +;
		          ",CASE WHEN E2_MOEDA = 1 " +;
		          " THEN E2_DECRESC " +;
		          " ELSE E2_DECRESC * E2_TXMOEDA " +;
		          "END AS VALOR_DECRESCIMO "
	endif		
		
	cQuery += ",E2_DATALIB AS DATA_DA_DISPONIBILIDADE " +;
              ",<<CODE_INSTANCE>> AS INSTANCIA " +;
              ",<<KEY_MOEDA_E2_MOEDA>> AS BK_MOEDA " +;
              ",COALESCE(E2_TXMOEDA,0) AS TAXA_MOEDA " +;
			  ",E2_VENCORI AS VENCIMENTO_ORIGINAL " + ;
			  ",E2_TIPO AS TIPO_DO_TITULO " + ;
		"FROM <<SE2_COMPANY>> SE2 " + ;
		"LEFT JOIN <<SA2_COMPANY>> SA2 ON A2_FILIAL = <<SUBSTR_SA2_E2_FILIAL>> " + ;
			"AND A2_COD = E2_FORNECE " + ;
			"AND A2_LOJA = E2_LOJA " + ;
			"AND SA2.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SA6_COMPANY>> SA6 ON A6_FILIAL = <<SUBSTR_SA6_E2_FILIAL>> " + ;
			"AND SA6.A6_COD = E2_BCOPAG " + ;
			"AND SA6.A6_AGENCIA = E2_FORAGE " + ;
			"AND SA6.A6_NUMCON = E2_FORCTA " + ; 
			"AND SA6.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SX5_COMPANY>> DOCESP " + ;
			"ON DOCESP.X5_FILIAL = <<ALIAS_DOCESP>><<SUBSTR_SX5_E2_FILIAL>> " + ;
				"AND DOCESP.X5_TABELA = '05' " + ;
				"AND DOCESP.X5_CHAVE = E2_TIPO " + ;
				"AND DOCESP.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<CTT_COMPANY>> CTT " + ;
			"ON CTT_FILIAL = <<SUBSTR_CTT_E2_FILIAL>> " + ;
				"AND CTT_CUSTO = E2_CCUSTO " + ;
				"AND CTT.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SED_COMPANY>> SED " + ;
			"ON ED_FILIAL = <<SUBSTR_SED_E2_FILIAL>> " + ;
				"AND ED_CODIGO = E2_NATUREZ " + ;
				"AND SED.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN <<SX5_COMPANY>> GRPFORN " + ;
			"ON GRPFORN.X5_FILIAL = <<ALIAS_GRPFORN>><<SUBSTR_SX5_E2_FILIAL>> " + ;
				"AND GRPFORN.X5_TABELA = 'Y7' " + ;
				"AND GRPFORN.X5_CHAVE = A2_GRUPO " + ;
				"AND GRPFORN.D_E_L_E_T_ = ' ' " + ;
		"WHERE " + ;
			"((E2_BAIXA BETWEEN <<START_DATE>> AND <<FINAL_DATE>> ) " + ;
			"OR (E2_VENCTO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> AND E2_TIPO = 'PA')) " + ;
			"AND SE2.D_E_L_E_T_ = ' ' " + ;
			" <<AND_XFILIAL_E2_FILIAL>> "
Return cQuery	
