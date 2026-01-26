#INCLUDE "BADEFINITION.CH"

NEW ENTITY ATENDAUSENCIA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAtendAusencia
Visualiza as informacoes de Gestao de Atendimento - Ausencia da area de GS.

@author  Marcia Junko
@since   10/05/2018
/*/
//-------------------------------------------------------------------
Class BAAtendAusencia from BAEntity
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
Method Setup( ) Class BAAtendAusencia
	_Super:Setup("Atendimento - Ausencia", FACT, "ABR")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   10/05/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAtendAusencia
	Local cQuery := ""

	cQuery := "SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
			"<<KEY_FILIAL_ABR_FILIAL>> AS BK_FILIAL, " + ; 
			"<<KEY_AA1_AA1_FILIAL+AA1_CODTEC>> AS BK_ATENDENTE, " + ;
			"<<KEY_ABS_ABS_FILIAL+ABS_LOCAL>> AS BK_LOCAL_ATENDIMENTO, " + ;
			"<<KEY_SRJ_RJ_FILIAL+RJ_FUNCAO>> AS BK_FUNCAO, " + ;
			"<<KEY_SQ3_Q3_FILIAL+Q3_CARGO>> AS BK_CARGO, " + ;
			"<<KEY_ABN_ABN_FILIAL+ABN_CODIGO>> AS BK_MOTIVO_MANUTENCAO, " + ;
			"SX5REG.X5_DESCRI AS DESCR_REGIAO, " + ;
			"SX5TPMANUT.X5_DESCRI AS DESCR_TIPO_MANUTENCAO, " + ;
			"ABR.ABR_DTINI AS DATA_DA_AUSENCIA, " + ;
			"'1' AS QUANT, " + ;
			"<<CODE_INSTANCE>> AS INSTANCIA " + ;
			"FROM <<ABR_COMPANY>> ABR " + ;
			"INNER JOIN <<ABB_COMPANY>> ABB " + ;
				"ON ABB.ABB_FILIAL = <<SUBSTR_ABB_ABR_FILIAL>> " + ;
				"AND ABB.ABB_CODIGO = ABR.ABR_AGENDA " + ;
				"AND ABB.D_E_L_E_T_ = ' ' " + ;
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
			"INNER JOIN <<ABN_COMPANY>> ABN " + ;
				"ON ABN.ABN_FILIAL = <<SUBSTR_ABN_ABR_FILIAL>> " + ;
				"AND ABN.ABN_CODIGO = ABR.ABR_MOTIVO " + ;
				"AND ABN.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SX5_COMPANY>> SX5REG " + ;
				"ON SX5REG.X5_FILIAL = <<SUBSTR_SX5_ABS_FILIAL>> " + ;
				"AND SX5REG.X5_TABELA = 'A2' " + ;
				"AND SX5REG.X5_CHAVE = ABS.ABS_REGIAO " + ;
				"AND SX5REG.D_E_L_E_T_ = ' ' " + ;				
			"INNER JOIN <<SX5_COMPANY>> SX5TPMANUT " + ;
				"ON SX5TPMANUT.X5_FILIAL = <<SUBSTR_SX5_ABN_FILIAL>> " + ;
				"AND SX5TPMANUT.X5_TABELA = 'I5' " + ;
				"AND SX5TPMANUT.X5_CHAVE = ABN.ABN_TIPO " + ;
				"AND SX5TPMANUT.D_E_L_E_T_ = ' ' " + ;				
			"WHERE ABR_DTINI BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
				"AND ABR.D_E_L_E_T_ = ' '  " + ;
				"<<AND_XFILIAL_ABR_FILIAL>> "

Return cQuery	
