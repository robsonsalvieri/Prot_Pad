#INCLUDE "BADEFINITION.CH"

NEW ENTITY REGISTROCUSTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARegistroCusto
Visualiza as informacoes de Registro de Custos da area de Gestao de Servicos.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Class BARegistroCusto from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARegistroCusto
	_Super:Setup("RegistroCusto", FACT, "TFJ")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   21/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARegistroCusto
	Local cQuery := ""
	
	cQuery := "SELECT " + ;
              " <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
              " <<KEY_FILIAL_TFL_FILIAL>> AS BK_FILIAL, " + ;
              " <<KEY_ABS_ABS_FILIAL+TFL_LOCAL>> AS BK_LOCAL_ATENDIMENTO, " + ;
              " <<KEY_SB1_''>> AS BK_ITEM, " + ;
              " TFL_CODIGO AS COD_LOCAL_PROP, " + ;
              " TFL_TOTRH AS TOTAL_ITEM_RH, " + ;
              " TFL_TOTMI AS TOTAL_ITEM_MI, " + ;
              " TFL_TOTMC AS TOTAL_MATERIAL_CONSUMO, " + ;
              " TFL_TOTLE AS TOTAL_LOC_EQUIPAMENTO, " + ;
              " TFL_TOTIMP AS TOTAL_IMPOSTO, " + ;
              " TFL_DTINI AS DATA_INICIAL, " + ;
              " TFL_DTFIM AS DATA_FINAL, " + ;
              " 0 AS VALOR_CUSTO, " + ;
              " '' AS TIPO_SERVICO, " + ;
              " '' AS ITEM_ORCAMENTO, " + ;
              " '1' AS QUANT, " + ;
              " TFL_CODPAI AS NUM_ORCAMENTO, " + ;
              " '' AS COD_LOCAL, " + ;
              " <<CODE_INSTANCE>> AS INSTANCIA " + ;
              "  FROM <<TFJ_COMPANY>> TFJ " + ;
              " INNER JOIN <<TFL_COMPANY>> TFL " +;
              "    ON TFL_FILIAL = <<SUBSTR_TFL_TFJ_FILIAL>> " +;
              "   AND TFL.D_E_L_E_T_= ' ' " + ;
              " INNER JOIN <<ABS_COMPANY>> ABS " +;
              "    ON ABS_LOCAL = TFL_LOCAL " +;
              "   AND ABS_FILIAL = <<SUBSTR_ABS_TFL_FILIAL>> " +;
              "   AND ABS.D_E_L_E_T_= ' ' " + ;
              " WHERE TFL_DTINI BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
              "   AND TFJ.D_E_L_E_T_ = ' ' " + ;
			  "   <<AND_XFILIAL_TFJ_FILIAL>> " + ;
              " UNION " + ;
              "SELECT " + ;
              " <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
              " <<KEY_FILIAL_TWZ_FILIAL>> AS BK_FILIAL, " + ;
              " <<KEY_ABS_''>> AS BK_LOCAL_ATENDIMENTO, " + ;
              " <<KEY_SB1_B1_FILIAL+TWZ_PRODUT>> AS BK_ITEM, " + ;
              " '' AS COD_LOCAL_PROP, " + ;
              " 0 AS TOTAL_ITEM_RH, " + ;
              " 0 AS TOTAL_ITEM_MI, " + ;
              " 0 AS TOTAL_MATERIAL_CONSUMO, " + ;
              " 0 AS TOTAL_LOC_EQUIPAMENTO, " + ;
              " 0 AS TOTAL_IMPOSTO, " + ;
              " TWZ_DTINC AS DATA_INICIAL, " + ;
              " '' AS DATA_FINAL, " + ;
              " TWZ_VLCUST AS VALOR_CUSTO, " + ;
              " TWZ_TPSERV AS TIPO_SERVICO, " + ;
              " TWZ_ITEM AS ITEM_ORCAMENTO, " + ;
              " '1' AS QUANT, " + ;
              " '' AS NUM_ORCAMENTO, " + ;
              " TWZ_LOCAL AS COD_LOCAL, " + ;
              " <<CODE_INSTANCE>> AS INSTANCIA " + ;
              "  FROM <<TWZ_COMPANY>> TWZ " + ;
			  "  LEFT JOIN <<SB1_COMPANY>> SB1 " +;
			  "    ON B1_FILIAL = <<SUBSTR_SB1_TWZ_FILIAL>> " + ; 
			  "   AND B1_COD = TWZ_PRODUT " + ;
			  "   AND SB1.D_E_L_E_T_ = ' ' " + ;
              " WHERE TWZ_DTINC BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
              "   AND TWZ.D_E_L_E_T_= ' ' " + ;
              "   <<AND_XFILIAL_TWZ_FILIAL>> "

Return cQuery	