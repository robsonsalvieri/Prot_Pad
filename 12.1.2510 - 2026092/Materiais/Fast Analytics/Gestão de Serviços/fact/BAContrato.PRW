#INCLUDE "BADEFINITION.CH"

NEW ENTITY CONTRATO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAContrato
Visualiza as informacoes dos Contratos de Prestacao de Servicos da area de GS.

@author  Marcia Junko Doi
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Class BAContrato from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Marcia Junko Doi
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAContrato
	_Super:Setup("Contrato", FACT, "CN9")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Marcia Junko Doi
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAContrato
	Local cQuery := ""
	
	cQuery := " SELECT " + ;
					"<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
					"<<KEY_FILIAL_CN9_FILIAL>> AS BK_FILIAL, " + ; 
					"<<KEY_SA1_A1_FILIAL+CN9_CLIENT+CN9_LOJACL>> AS BK_CLIENTE, " + ;
					"<<KEY_###_CN9_SITUAC>> AS BK_SITCONTRATO, " + ;
					"<<KEY_AOV_AOV_FILIAL+AOV_CODSEG>> AS BK_SEGMENTO, " + ;
					"CN9_NUMERO AS NUMERO_CONTRATO, " + ;
					"CN9_REVISA AS REVISAO_CONTRATO, " + ;
					"CASE WHEN SA1.A1_COD_MUN = ' ' " + ;
						"THEN <<KEY_CC2_A1_EST>> " + ;
						"ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> " + ;
					"END AS BK_REGIAO, " + ;
					"CNA_DTINI AS DATA_INICIAL, " + ;
					"CNA_DTFIM AS DATA_FINAL, " + ;
					"CNA_VLTOT AS VALOR_PREVISTO, " + ;  
					"(CNA_VLTOT - CNA_SALDO) AS VALOR_REALIZADO, " + ;
					"CNA_SALDO AS SALDO, " + ;	
					"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
					"<<KEY_MOEDA_CN9_MOEDA>> AS BK_MOEDA, " + ;
					"0 AS TAXA_MOEDA " + ;
				"FROM <<CN9_COMPANY>> CN9 " + ;
				"INNER JOIN <<CNA_COMPANY>> CNA " + ; 
					"ON CNA.CNA_FILIAL = <<SUBSTR_CNA_CN9_FILIAL>> " + ;
					"AND CNA.CNA_CONTRA = CN9.CN9_NUMERO " + ;
					"AND CNA.CNA_REVISA = CN9.CN9_REVISA " + ;
					"AND (CNA.CNA_DTINI BETWEEN <<START_DATE>> AND <<FINAL_DATE>>) " + ;
					"AND (CNA.CNA_DTFIM BETWEEN <<START_DATE>> AND <<FINAL_DATE>>) " + ;
					"AND CNA.D_E_L_E_T_ = ' ' " + ;
				"INNER JOIN <<TFJ_COMPANY>> TFJ " + ;
					"ON TFJ.TFJ_FILIAL = <<SUBSTR_TFJ_CN9_FILIAL>> " + ;
					"AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO " + ;
					"AND TFJ.TFJ_CONREV = CN9.CN9_REVISA " + ;
					"AND TFJ.TFJ_CONTRT <> ' ' " + ;
					"AND TFJ.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SA1_COMPANY>> SA1 " + ; //BK_CLIENTE
					"ON SA1.A1_FILIAL = <<SUBSTR_SA1_CN9_FILIAL>> " + ;
					"AND SA1.A1_COD = CN9.CN9_CLIENT " + ;
					"AND SA1.A1_LOJA = CN9.CN9_LOJACL " + ;
					"AND SA1.D_E_L_E_T_ = ' ' " + ;	
				"LEFT JOIN <<AOV_COMPANY>> AOV " + ;  // BK_SEGMENTO
					"ON AOV.AOV_FILIAL = <<SUBSTR_AOV_A1_FILIAL>> " + ;
					"AND AOV.AOV_CODSEG = SA1.A1_CODSEG " + ;
					"AND AOV.D_E_L_E_T_ = ' ' " + ;
				"WHERE " + ;
					"CN9.CN9_REVATU = '   ' " + ;
					"AND CN9.D_E_L_E_T_ = ' ' " + ;
					"<<AND_XFILIAL_CN9_FILIAL>> "

Return cQuery	