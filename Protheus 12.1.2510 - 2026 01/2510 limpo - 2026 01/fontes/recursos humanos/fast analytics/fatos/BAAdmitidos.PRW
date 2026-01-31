#INCLUDE "BADefinition.CH"

NEW ENTITY ADMITIDOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAdmitidos
A tabela fato Admitidos apresenta informacoes dos funcionarios
admitidos no periodo selecionado.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAAdmitidos from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padr?o.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAdmitidos
    _Super:Setup("Admitidos", FACT, "SRA")
    
    //---------------------------------------------------------
	// Define que a extra??o da entidade ser? por m?s
	//---------------------------------------------------------
	//_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAdmitidos
	Local cQuery := ""

	cQuery := " SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_TURNO, BK_ESTCIVL, BK_CAT, BK_GRINRAI, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_FUNCPROC, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR ," + ;
	          " FUNC_DTADMISSAO, QTD_ADMITIDOS, FUNC_DTDEMISSAO, FUNC_DTAUX, INSTANCIA" + ;
	          " FROM (" + ;
	          " SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
	                           ",<<KEY_FILIAL_RA_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+RA_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SR6_R6_FILIAL+RA_TNOTRAB>> AS BK_TURNO" + ;
		                       ",<<KEY_SX5_CAT.X5_FILIAL+RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SX5_EST.X5_FILIAL+RA_ESTCIVI>> AS BK_ESTCIVL" + ;
		                       ",<<KEY_SX5_INS.X5_FILIAL+RA_GRINRAI>> AS BK_GRINRAI" + ;
		                       ",<<KEY_SQB_QB_FILIAL+RA_DEPTO>> AS BK_DEPTO" + ; 
		                       ",<<KEY_SQ3_Q3_FILIAL+RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_RCJ_RCJ_FILIAL+RA_PROCES>> AS BK_FUNCPROC" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+RA_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+RA_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+RA_CLVL>> AS BK_CLASSE_VALOR" + ;
		                       ",1 AS QTD_ADMITIDOS" + ;
							   ",SRA.RA_ADMISSA AS FUNC_DTADMISSAO" + ;
							   ",SRA.RA_DEMISSA AS FUNC_DTDEMISSAO" + ;
							   ",CASE WHEN SRA.RA_RESCRAI IN  ('30','31')" + ;
				               "             THEN SRA.RA_DEMISSA" + ;
				               "             ELSE '' END" + ;
				               " AS FUNC_DTAUX" + ;
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SRA_COMPANY>> SRA" + ;  
							   " LEFT JOIN <<SX5_COMPANY>> EST" +;
							   " 	ON EST.X5_FILIAL = <<SUBSTR_SX5_RA_FILIAL>> " +;
							   " 	AND EST.X5_TABELA = '33' "  +;
							   " 	AND EST.X5_CHAVE = SRA.RA_ESTCIVI " +; 
							   " 	AND EST.D_E_L_E_T_ = ' ' "  +;
							   " LEFT JOIN <<SX5_COMPANY>> INS"  +;
							   " 	ON INS.X5_FILIAL = <<SUBSTR_SX5_RA_FILIAL>> " +;
							   " 	AND INS.X5_TABELA = '26' " +;
							   " 	AND INS.X5_CHAVE = SRA.RA_GRINRAI " +;
							   " 	AND INS.D_E_L_E_T_ = ' ' " +;
		                       " LEFT JOIN <<SR6_COMPANY>> SR6" +;
		                       "	ON R6_FILIAL = <<SUBSTR_SR6_RA_FILIAL>> " +;
		                       "	AND R6_TURNO = RA_TNOTRAB " +;
		                       "	AND SR6.D_E_L_E_T_ = ' ' " +;
	                           " INNER JOIN <<SX5_COMPANY>> CAT" +;
	                           "    ON CAT.X5_FILIAL = <<SUBSTR_SX5_RA_FILIAL>> " +;
	                           "    AND CAT.X5_TABELA = '28' " +;
	                           "    AND CAT.X5_CHAVE = RA_CATFUNC " +;
	                           "    AND CAT.D_E_L_E_T_ = ' ' " +;
	                           " LEFT JOIN <<SQB_COMPANY>> SQB" +;
	                           "    ON QB_FILIAL = <<SUBSTR_SQB_RA_FILIAL>> " +;
	                           "    AND QB_DEPTO = RA_DEPTO " +;
	                           "    AND SQB.D_E_L_E_T_ = ' ' " +;
	                           " LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
	                           "    ON Q3_FILIAL = <<SUBSTR_SQ3_RA_FILIAL>> " +;
	                           "    AND Q3_CARGO = RA_CARGO " +;
	                           "    AND SQ3.D_E_L_E_T_ = ' ' " +;
	                           " INNER JOIN <<SRJ_COMPANY>> SRJ " +;
	                           "    ON RJ_FILIAL = <<SUBSTR_SRJ_RA_FILIAL>> " +;
	                           "    AND RJ_FUNCAO = RA_CODFUNC " +;
	                           "    AND SRJ.D_E_L_E_T_ = ' ' " +;
	                           " INNER JOIN <<RCJ_COMPANY>> RCJ " +;
	                           "   ON  RCJ_FILIAL = <<SUBSTR_RCJ_RA_FILIAL>> " +;
	                           "   AND RCJ_CODIGO = RA_PROCES " +;
	                           "   AND RCJ.D_E_L_E_T_ = ' ' " +;
	                           " INNER JOIN <<CTT_COMPANY>> CTT" +;
	                           "    ON CTT_FILIAL = <<SUBSTR_CTT_RA_FILIAL>> " +;
	                           "    AND CTT_CUSTO = RA_CC " +;
	                           "    AND CTT.D_E_L_E_T_ = ' ' " +;
	                           " LEFT JOIN <<CTD_COMPANY>> CTD" +;
	                           "    ON CTD_FILIAL = <<SUBSTR_CTD_RA_FILIAL>> " +;
	                           "    AND CTD_ITEM = RA_ITEM " +;
	                           "    AND CTD.D_E_L_E_T_ = ' ' " +;
	                           " LEFT JOIN <<CTH_COMPANY>> CTH" +;
	                           "    ON CTH_FILIAL = <<SUBSTR_CTH_RA_FILIAL>> " +;
	                           "    AND CTH_CLVL = RA_CLVL " +;
	                           "    AND CTH.D_E_L_E_T_ = ' ' " +;
		                       	"WHERE SRA.D_E_L_E_T_ = ' ' " + ;
		                       	" <<AND_XFILIAL_RA_FILIAL>> ) ADMISSAO"

Return cQuery
