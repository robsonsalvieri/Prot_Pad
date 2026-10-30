#INCLUDE "BADEFINITION.CH"

NEW ENTITY RECARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecCarteira
Visualiza as informacoes do Contas a Receber Carteira da area Financeiro.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Class BARecCarteira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARecCarteira
	_Super:Setup("ReceberCarteira", FACT, "SE1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARecCarteira
    Local cQuery := ""
	
    cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, <<KEY_FILIAL_E1_FILIAL>> AS BK_FILIAL, " + ;
              "<<KEY_FILIAL_E1_FILORIG>> AS BK_FILIAL_ORIGEM, " + ;
              "<<KEY_SX5_TIPO.X5_FILIAL+E1_TIPO>> AS BK_ESPEC_DOC, " + ;
              "<<KEY_SA6_A6_FILIAL+E1_BCOCLI+E1_AGEDEP+E1_NUMCON>> AS BK_BCO, " + ;
              "<<KEY_CTT_CTT_FILIAL+E1_CCUSTO>> AS BK_CENTRO_CUSTO, " + ;
              "<<KEY_SED_ED_FILIAL+E1_NATUREZ>> AS BK_NAT_FINANCEIRA, " + ;
              "<<KEY_SA1_A1_FILIAL+E1_CLIENTE+E1_LOJA>> AS BK_CLIENTE, " + ;
              "<<KEY_SA3_A3_FILIAL+E1_VEND1>> AS BK_VENDEDOR, " + ;
              "<<EXTRACTION_DATE>> AS DATA_DA_EXTRACAO, " + ;
              "CASE WHEN SA1.A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO, " + ;
              "E1_EMISSAO AS DATA_DE_EMISSAO, " + ; 
              "E1_VENCREA AS VENCIMENTO_REAL, " + ; 
              "E1_PREFIXO AS PREFIXO_TITULO, " + ; 
              "E1_NUM AS NUMERO_TITULO, " + ; 
              "E1_PARCELA AS NUMERO_DA_PARCELA, " + ;
              "E1_NUMBOR AS NUMERO_DO_BORDERO, "

    if (cPaisloc == "BRA")
        cQuery += "E1_SALDO AS SALDO_RECEBER, " +;
                  "E1_SITUACA AS SITUACAO_TITULO, "
    else
        cQuery += "E1_SITUACA AS SITUACAO_TITULO, " +;
                  "CASE WHEN E1_MOEDA = 1 THEN " +;
                        "(CASE WHEN E1_TIPO <> 'NCC' AND E1_TIPO <> 'RA' " +; 
                                "THEN E1_SALDO " +;
                                "ELSE - (E1_SALDO) " +; 
                                "END) " +;
                        "ELSE (CASE WHEN E1_TIPO <> 'NCC' AND E1_TIPO <> 'RA' " +; 
                                "THEN E1_SALDO * E1_TXMOEDA " +;
                                "ELSE - (E1_SALDO * E1_TXMOEDA) " +;
                                "END) " +;
                        "END AS SALDO_RECEBER, " 
    endif

    cQuery += "<<CODE_INSTANCE>> AS INSTANCIA, "
    cQuery += "<<KEY_MOEDA_E1_MOEDA>> AS BK_MOEDA, "
    cQuery += "COALESCE(E1_TXMOEDA,0) AS TAXA_MOEDA, "
    cQuery += "<<KEY_SA1_A1_FILIAL+A1_TIPO>> as BK_GRUPO_CLIENTE," 
    cQuery += "<<KEY_SX5_TIPO.X5_FILIAL+E1_SITUACA>> AS BK_MODALCOBRANCA, " 
    cQuery += "E1_VENCORI AS VENCIMENTO_ORIGINAL, "    
    cQuery += "E1_TIPO AS TIPO_DO_TITULO "             
       
    cQuery += "FROM <<SE1_COMPANY>> SE1 " + ; 
        "LEFT JOIN <<SX5_COMPANY>> TIPO " + ;
        "ON TIPO.X5_FILIAL = <<ALIAS_TIPO>><<SUBSTR_SX5_E1_FILIAL>> " + ;
	"   AND TIPO.X5_TABELA = '05' " + ;
	"   AND TIPO.X5_CHAVE = SE1.E1_TIPO " + ;
	"   AND TIPO.D_E_L_E_T_ = ' ' " + ;
	"LEFT JOIN <<SA6_COMPANY>> SA6 " + ; 	
       "ON SA6.A6_FILIAL = <<SUBSTR_SA6_E1_FILIAL>> " + ; 
       "   AND SA6.A6_COD = SE1.E1_BCOCLI " + ;
       "   AND SA6.A6_AGENCIA = SE1.E1_AGEDEP " + ;
       "   AND SA6.A6_NUMCON = SE1.E1_NUMCON " + ; 
       "   AND SA6.D_E_L_E_T_ = ' ' " + ;
       "LEFT JOIN <<CTT_COMPANY>> CTT " + ; 	
       "ON CTT.CTT_FILIAL = <<SUBSTR_CTT_E1_FILIAL>> " + ; 
       "   AND CTT.CTT_CUSTO = SE1.E1_CCUSTO " + ;
       "   AND CTT.D_E_L_E_T_ = ' ' " + ;
       "LEFT JOIN <<SED_COMPANY>> SED " + ; 	
       "ON SED.ED_FILIAL = <<SUBSTR_SED_E1_FILIAL>> " + ; 
       "   AND SED.ED_CODIGO = SE1.E1_NATUREZ " + ;
       "   AND SED.D_E_L_E_T_ = ' ' " + ; 
       "LEFT JOIN <<SA3_COMPANY>> SA3 " + ; 	
       "ON SA3.A3_FILIAL = <<SUBSTR_SA3_E1_FILIAL>> " + ; 
       "   AND SA3.A3_COD = SE1.E1_VEND1 " + ;
       "   AND SA3.D_E_L_E_T_ = ' ' " + ; 
       "LEFT JOIN <<SA1_COMPANY>> SA1 " + ; 
       "ON SA1.A1_FILIAL = <<SUBSTR_SA1_E1_FILIAL>> " + ;
       "  AND SA1.A1_COD = SE1.E1_CLIENTE " + ; 
       "  AND SA1.A1_LOJA = SE1.E1_LOJA  " + ;
       "  AND SA1.D_E_L_E_T_= ' '  " + ;
       "WHERE SE1.E1_SALDO = SE1.E1_VALOR " + ;
       "  AND SE1.D_E_L_E_T_ = ' '  " + ;
       "  <<AND_XFILIAL_E1_FILIAL>> "

Return cQuery	
