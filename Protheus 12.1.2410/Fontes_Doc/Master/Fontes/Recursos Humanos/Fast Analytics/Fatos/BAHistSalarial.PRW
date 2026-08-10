#INCLUDE "BADefinition.CH"

NEW ENTITY HISTSALARIAL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAHistSalarial
A tabela fato historico Salarial apresenta informacoes de Historico Salarial.
dos funcionarios.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAHistSalarial from BAEntity
    Method Setup( ) CONSTRUCTOR
    Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padr?o.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAHistSalarial
    _Super:Setup("HistSalarial", FACT, "SR7")
    
    //---------------------------------------------------------
	// Define que a extra??o da entidade ser? por m?s
	//---------------------------------------------------------
	//_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAHistSalarial
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_FUNCAO, BK_CARGO, BK_CAT, DTALTER, TIPO, CODFUNCAO, CODCARGO, CATFUNC,INSTANCIA " + ;
              " FROM (" + ;
              " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_R7_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+R7_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+R7_FUNCAO>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+R7_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+R7_CATFUNC>> AS BK_CAT" + ;	                       
		                       ",R7_DATA AS DTALTER" + ;
		                       ",R7_TIPO AS TIPO" + ;
		                       ",R7_FUNCAO AS CODFUNCAO" + ;
		                       ",R7_CARGO AS CODCARGO" + ;
		                       ",R7_CATFUNC AS CATFUNC" + ;
						       ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SR7_COMPANY>> SR7" + ;
                               "  INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_R7_FILIAL>> " +;
                               "    AND RA_MAT = R7_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_R7_FILIAL>> " +;
                               "    AND RJ_FUNCAO = R7_FUNCAO " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_R7_FILIAL>> " +;
                               "    AND Q3_CARGO = R7_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SX5_COMPANY>> SX5 " +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_R7_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = R7_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
		                       "WHERE ( SR7.R7_DATA >= <<START_DATE>> AND SR7.R7_DATA <= <<FINAL_DATE>> ) " +;
                               " AND SR7.D_E_L_E_T_ = ' '  " +;
                               " <<AND_XFILIAL_R7_FILIAL>> ) HISTSALARIAL"

Return cQuery
