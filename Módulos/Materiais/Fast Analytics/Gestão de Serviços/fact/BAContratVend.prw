#INCLUDE "BADEFINITION.CH"

NEW ENTITY CONTVENDEDOR

//-------------------------------------------------------------------
/*/{Protheus.doc} BAContratVend
Visualiza as informacoes dos Contratos de Vendedores da area de GS.

@author  Angelo Lee
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Class BAContratVend from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Angelo Lee
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAContratVend
	_Super:Setup("Contrato Vendedor", FACT, "CN9")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Angelo Lee
@since   29/10/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAContratVend
	Local cQuery := ""
	
	cQuery := " SELECT " + ;
					"<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
					"<<KEY_FILIAL_CN9_FILIAL>> AS BK_FILIAL, " + ; 
                    "<<KEY_SA3_A3_FILIAL+CNU_CODVD>> AS BK_VENDEDOR, " + ;
					"<<KEY_###_CN9_SITUAC>> AS BK_SITCONTRATO, " + ;
					"CN9_NUMERO AS NUMERO_CONTRATO, " + ;
					"CN9_REVISA AS REVISAO_CONTRATO, " + ;
					"CN9_SALDO AS SALDO, " + ;
					"CN9_VLATU AS VALOR_ATUAL, " + ;
					"CN9_DTINIC AS DATA_INICIAL, " + ;
					"CN9_DTFIM AS DATA_FINAL, " + ;
					"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
					"<<KEY_MOEDA_CN9_MOEDA>> AS BK_MOEDA, " + ;
					"0 AS TAXA_MOEDA " + ;
				"FROM <<CN9_COMPANY>> CN9 " + ;
				"INNER JOIN <<TFJ_COMPANY>> TFJ " + ;
					"ON TFJ.TFJ_FILIAL = <<SUBSTR_TFJ_CN9_FILIAL>> " + ;
					"AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO " + ;
					"AND TFJ.TFJ_CONREV = CN9.CN9_REVISA " + ;
					"AND TFJ.TFJ_CONTRT <> ' ' " + ;
					"AND TFJ.D_E_L_E_T_ = ' ' " + ;
                "LEFT JOIN <<CNU_COMPANY>> CNU " + ; 
                    "ON CNU.CNU_FILIAL = <<SUBSTR_CNU_CN9_FILIAL>> " + ;
                    "AND CNU.CNU_CONTRA = CN9.CN9_NUMERO " + ;
                    "AND CNU.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<SA3_COMPANY>> SA3 " + ; //BK_VENDEDOR
					"ON SA3.A3_FILIAL = <<SUBSTR_SA3_CNU_FILIAL>> " + ;
					"AND SA3.A3_COD = CNU.CNU_CODVD " + ;
					"AND SA3.D_E_L_E_T_ = ' ' " + ;
				"WHERE " + ;
                    "CN9.CN9_REVATU = '   ' " + ;
					"AND CN9_DTINIC BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;	
					"AND CN9_DTFIM BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;	
					"AND CN9.D_E_L_E_T_ = ' ' " + ;
					"<<AND_XFILIAL_CN9_FILIAL>> "
					
Return cQuery	