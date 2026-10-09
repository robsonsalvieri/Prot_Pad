#INCLUDE "BADEFINITION.CH"

NEW ENTITY ATENDALOCACAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAtendAlocacao
Visualiza as informações de Gestao de Atendimento - Alocacao da area de GS.

@author  Marcia Junko
@since   10/05/2018
/*/
//-------------------------------------------------------------------
Class BAAtendAlocacao from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Marcia Junko
@since   10/05/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAtendAlocacao
	_Super:Setup("Atendimento - Alocacao", FACT, "ABB")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   10/05/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAtendAlocacao
	Local cQuery := ""

	cQuery := "SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
			"<<KEY_FILIAL_ABB_FILIAL>> AS BK_FILIAL, " + ; 
			"<<KEY_AA1_AA1_FILIAL+AA1_CODTEC>> AS BK_ATENDENTE," + ;
			"<<KEY_ABS_ABS_FILIAL+ABS_LOCAL>> AS BK_LOCAL_ATENDIMENTO," + ;
			"<<KEY_SRJ_RJ_FILIAL+RJ_FUNCAO>> AS BK_FUNCAO," + ;
			"<<KEY_SQ3_Q3_FILIAL+Q3_CARGO>> AS BK_CARGO," + ;
			"SX5REG.X5_DESCRI AS DESCR_REGIAO, " + ;
			"ABB.ABB_DTINI AS DIA_DE_TRABALHO, " + ;
			"ABB.ABB_CHEGOU AS CHEGOU, " + ;
			"CASE " + ;
				"WHEN ABB_ATENDE = '1' THEN 'Sim' " + ;
				"WHEN ABB_ATENDE = '2' THEN 'Nao' " + ;
			"END AS ATENDE, " + ;
			"'1' AS QUANT, " + ;
			"<<CODE_INSTANCE>> AS INSTANCIA " + ;
			"FROM <<ABB_COMPANY>> ABB " + ;
			"INNER JOIN <<AA1_COMPANY>> AA1 " + ;
				"ON AA1.AA1_FILIAL = <<SUBSTR_AA1_ABB_FILIAL>> " + ;
				"AND AA1.AA1_CODTEC = ABB.ABB_CODTEC " + ;
				"AND AA1.D_E_L_E_T_ = ' ' " + ;
			"INNER JOIN <<ABQ_COMPANY>> ABQ " + ;
				"ON ABQ.ABQ_FILIAL = <<SUBSTR_ABQ_ABB_FILIAL>> " + ;
				"AND (ABQ_CONTRT||ABQ_ITEM||ABQ_ORIGEM) = ABB_IDCFAL " + ;
				"AND ABQ.D_E_L_E_T_ = ' ' " + ;
			"INNER JOIN <<TFF_COMPANY>> TFF " + ;
				"ON TFF.TFF_FILIAL = <<SUBSTR_TFF_ABQ_FILTFF>> " + ;
				"AND TFF_COD = ABQ_CODTFF " + ;
				"AND TFF_CONTRT = ABQ_CONTRT " + ;
				"AND TFF.D_E_L_E_T_ = ' ' " + ;	
			"INNER JOIN <<ABS_COMPANY>> ABS " + ;
				"ON ABS.ABS_FILIAL = <<SUBSTR_ABS_TFF_FILIAL>> " + ;
				"AND ABS_LOCAL = TFF_LOCAL " + ;
				"AND ABS.D_E_L_E_T_ = ' ' " + ;
			"INNER JOIN <<SRJ_COMPANY>> SRJ " + ;
				"ON SRJ.RJ_FILIAL = <<SUBSTR_SRJ_ABQ_FILTFF>> " + ;
				"AND SRJ.RJ_FUNCAO = ABQ.ABQ_FUNCAO " + ;
				"AND SRJ.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SQ3_COMPANY>> SQ3 " + ;
				"ON SQ3.Q3_FILIAL = <<SUBSTR_SQ3_ABQ_FILTFF>> " + ;
				"AND SQ3.Q3_CARGO = ABQ.ABQ_CARGO " + ; 
				"AND SQ3.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SX5_COMPANY>> SX5REG " + ;
				"ON SX5REG.X5_FILIAL = <<SUBSTR_SX5_ABS_FILIAL>> " + ;
				"AND SX5REG.X5_TABELA = 'A2' " + ;
				"AND SX5REG.X5_CHAVE = ABS.ABS_REGIAO " + ;
				"AND SX5REG.D_E_L_E_T_ = ' ' " + ;				
			"WHERE ABB_DTINI BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
				"AND ABB.ABB_CODIGO IN " + ;
				"( " + ;
					"SELECT A.ABB_CODIGO_AGR FROM " + ;
						"(SELECT ABB_CODTEC, ABB_DTINI, ABB_FILIAL, MIN(ABB_CODIGO) as ABB_CODIGO_AGR " + ;
						"FROM <<ABB_COMPANY>> ABB1 " + ;
						"WHERE ABB1.D_E_L_E_T_ = ' ' " + ;
						"GROUP BY ABB1.ABB_DTINI, ABB1.ABB_CODTEC, ABB1.ABB_FILIAL " + ;
					") A " + ;
				") " + ;
				"AND ABB.D_E_L_E_T_ = ' '  " + ;
				"<<AND_XFILIAL_ABB_FILIAL>> "
Return cQuery	
