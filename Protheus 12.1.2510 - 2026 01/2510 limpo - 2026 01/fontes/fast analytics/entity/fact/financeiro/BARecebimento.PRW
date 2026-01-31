#INCLUDE "BADEFINITION.CH"

NEW ENTITY RECEBIMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecebimento
Visualiza as informacoes das Contas a Receber da area de Financeiro.

@author  Angelo Lee
@since   02/01/2018
/*/
//-------------------------------------------------------------------
Class BARecebimento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARecebimento
	_Super:Setup("Recebimento", FACT, "SE1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARecebimento
	Local cQuery := ""

	cQuery := " SELECT " + ;
		" <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
		" <<KEY_FILIAL_E1_FILIAL>> AS BK_FILIAL, " + ; 
		" <<KEY_SX5_TPTIT.X5_FILIAL+E1_TIPO>> AS BK_ESPEC_DOC, " + ;
		" <<KEY_SA1_A1_FILIAL+E1_CLIENTE+E1_LOJA>> AS BK_CLIENTE, " + ; 
		" <<KEY_SX5_STTIT.X5_FILIAL+E1_SITUACA>> AS BK_MODALCOBRANCA, " + ; 
		" <<KEY_CTT_CTT_FILIAL+E1_CCUSTO>> AS BK_CENTRO_CUSTO, " + ; 
		" <<KEY_SED_ED_FILIAL+E1_NATUREZ>> AS BK_NAT_FINANCEIRA, " + ; 
		" <<KEY_SA6_A6_FILIAL+E1_BCOCLI+E1_AGECLI+E1_CTACLI>> AS BK_BCO, " + ; 
		" <<KEY_FILIAL_E1_FILORIG>> AS BK_FILIAL_ORIGEM, " + ;
		" CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ;
		" <<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE, " + ;  
		" E1_EMISSAO AS DATA_DE_EMISSAO_TITULO, " + ; 
		" E1_VENCREA AS VENCIMENTO_REAL, " + ; 
		" E1_PREFIXO AS PREFIXO_TITULO, " + ; 
		" E1_NUM AS NUMERO_TITULO, " + ; 
		" E1_PARCELA AS NUMERO_DA_PARCELA, " + ;
		" E1_NUMBOR AS NUMERO_DO_BORDERO, "
		
	if (cPaisloc == "BRA")
		cQuery += "E1_VALOR AS VALOR_DA_MOVIMENTACAO, " +;	
		"E1_SALDO AS SALDO_RECEBER, " +;
		"E1_BAIXA AS DATA_DA_BAIXA_DO_TITULO, " +;
		"E1_DESCONT AS VALOR_DO_DESCONTO, " +;
		"E1_JUROS AS VALOR_DO_JUROS, " +;
		"E1_MULTA AS VALOR_DA_MULTA, " +; 
		"E1_ACRESC AS VALOR_ACRESCIMO, " +;
		"E1_DECRESC AS VALOR_DECRESCIMO, "
	else
		cQuery += " CASE WHEN E1_MOEDA = 1 THEN " +;
		" (CASE WHEN E1_TIPO <> 'NCC' AND E1_TIPO <> 'RA' THEN E1_VALOR ELSE - (E1_VALOR) END) " +;
		" ELSE (CASE WHEN E1_TIPO <> 'NCC' AND E1_TIPO <> 'RA' THEN E1_VALOR * E1_TXMOEDA ELSE - (E1_VALOR * E1_TXMOEDA) END) " +;
		" END AS VALOR_DA_MOVIMENTACAO, " +;
		" CASE WHEN E1_MOEDA = 1 THEN " +;
		" (CASE WHEN E1_TIPO <> 'NCC' AND SE1.E1_TIPO <> 'RA' THEN E1_SALDO ELSE - (E1_SALDO) END) " +;
		" ELSE (CASE WHEN E1_TIPO <> 'NCC' AND E1_TIPO <> 'RA' THEN E1_SALDO * E1_TXMOEDA ELSE - (E1_SALDO * E1_TXMOEDA) END) " +;
		" END AS SALDO_RECEBER, " +;
	    " E1_BAIXA AS DATA_DA_BAIXA_DO_TITULO, " +;
	    " CASE WHEN E1_MOEDA = 1 " +;
		"  THEN E1_DESCONT " +;
		"  ELSE E1_DESCONT * E1_TXMOEDA " +;
		" END AS VALOR_DO_DESCONTO, " +;
		" CASE WHEN E1_MOEDA = 1 " +;
		"  THEN E1_JUROS " +;
		"  ELSE E1_JUROS * E1_TXMOEDA " +;
		" END AS VALOR_DO_JUROS, " +;
		" CASE WHEN E1_MOEDA = 1 " +;
		"  THEN E1_MULTA " +;
		"  ELSE E1_MULTA * E1_TXMOEDA " +;
		" END AS VALOR_DA_MULTA, " +; 
		" CASE WHEN E1_MOEDA = 1 " +;
		"  THEN E1_ACRESC " +;
		"  ELSE E1_ACRESC * E1_TXMOEDA " +;
		"  END AS VALOR_ACRESCIMO, " +;
		" CASE WHEN E1_MOEDA = 1 " +;
		"  THEN E1_DECRESC " +;
		"  ELSE E1_DECRESC * E1_TXMOEDA " +;
		" END AS VALOR_DECRESCIMO, "
	endif	
		
	cQuery += "E1_MOVIMEN AS DATA_DA_DISPONIBILIDADE, " +;
	          "<<CODE_INSTANCE>> AS INSTANCIA, " +;
			  "<<KEY_MOEDA_E1_MOEDA>> AS BK_MOEDA, " +;
			  "COALESCE(E1_TXMOEDA,0) AS TAXA_MOEDA, " +;   
			  "E1_VENCORI AS VENCIMENTO_ORIGINAL, " + ; 
			  "E1_TIPO AS TIPO_DO_TITULO " + ;
		" FROM <<SE1_COMPANY>> SE1 " + ;
		" LEFT JOIN <<SA1_COMPANY>> SA1 " + ; 
		" ON A1_FILIAL = <<SUBSTR_SA1_E1_FILIAL>> " + ;
			" AND A1_COD = E1_CLIENTE " + ; 
			" AND A1_LOJA = E1_LOJA " + ;
			" AND SA1.D_E_L_E_T_ = ' ' " + ;
		" LEFT JOIN <<CTT_COMPANY>> CTT  " + ;
		" ON CTT_FILIAL = <<SUBSTR_CTT_E1_FILIAL>> " + ;
			" AND CTT_CUSTO = E1_CCUSTO " + ; 
			" AND CTT.D_E_L_E_T_= ' '  " + ;
		" LEFT JOIN <<SED_COMPANY>> SED  " + ;
		" ON ED_FILIAL = <<SUBSTR_SED_E1_FILIAL>> " + ;
			" AND ED_CODIGO = E1_NATUREZ " + ; 
			" AND SED.D_E_L_E_T_= ' '  " + ;
		" LEFT JOIN <<SA6_COMPANY>> SA6  " + ;
		" ON A6_FILIAL = <<SUBSTR_SA6_E1_FILIAL>> " + ;
			" AND A6_COD = E1_BCOCLI " + ; 
			" AND A6_AGENCIA = E1_AGECLI " + ; 
			" AND A6_NUMCON = E1_CTACLI " + ; 
			" AND SA6.D_E_L_E_T_= ' '  " + ;
		" LEFT JOIN <<SX5_COMPANY>> TPTIT " + ;
		" ON TPTIT.X5_FILIAL = <<ALIAS_TPTIT>><<SUBSTR_SX5_E1_FILIAL>> " + ;
			" AND TPTIT.X5_TABELA = '05' " + ;
			" AND TPTIT.X5_CHAVE = E1_TIPO " + ;
			" AND TPTIT.D_E_L_E_T_ = ' ' " + ;
		" LEFT JOIN <<SX5_COMPANY>> STTIT " + ;
		" ON STTIT.X5_FILIAL = <<ALIAS_STTIT>><<SUBSTR_SX5_E1_FILIAL>> " + ;
			" AND STTIT.X5_TABELA = '07' " + ;
			" AND STTIT.X5_CHAVE = E1_SITUACA " + ;
			" AND STTIT.D_E_L_E_T_ = ' ' " + ;
		" WHERE" +; 
		" ((E1_BAIXA BETWEEN <<START_DATE>> AND <<FINAL_DATE>> ) " + ;
		" OR (E1_VENCTO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> AND E1_TIPO = 'RA')) " + ;
       	" AND SE1.D_E_L_E_T_ = ' '  " + ;
		"  <<AND_XFILIAL_E1_FILIAL>> "

Return cQuery
