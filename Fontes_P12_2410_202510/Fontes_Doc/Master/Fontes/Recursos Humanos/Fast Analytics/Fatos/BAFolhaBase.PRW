#INCLUDE "BADefinition.CH"

NEW ENTITY BASEFOLHA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFolhaBase
A tabela fato Base Folha apresenta informacoes das bases
de cálculo feitos em Folha de Pagamento dos funcionarios.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAFolhaBase from BAEntity
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
Method Setup( ) Class BAFolhaBase
    _Super:Setup("BaseFolha", FACT, "SRC")
    
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
Method BuildQuery( ) Class BAFolhaBase
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_CAT, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_VERBA, BK_FUNCPROC, BK_PERIODO, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR, BK_ROTEIRO,  TIPO1, " + ;
    		  " HORAS, VALOR, DTPAGAMENTO, PERIODO,INSTANCIA " + ;
              " FROM (" + ;
              " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_RC_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+RC_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SRV_RV_FILIAL+RC_PD>> AS BK_VERBA" + ;
		                       ",<<KEY_RCJ_RCJ_FILIAL+RC_PROCES>> AS BK_FUNCPROC" + ;
		                       ",<<KEY_RCH_RCH_FILIAL+RC_PROCES+RC_PERIODO+RC_SEMANA+RC_ROTEIR>> AS BK_PERIODO" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+RC_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+RC_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+RC_CLVL>> AS BK_CLASSE_VALOR" + ;    
		                       ",<<KEY_SRY_RY_FILIAL+RC_ROTEIR>> AS BK_ROTEIRO" + ;          
		                       ",RC_TIPO1 AS TIPO1" + ;
		                       ",RC_HORAS AS HORAS" + ;
		                       ",RC_VALOR AS VALOR" + ;
		                       ",RC_DATA AS DTPAGAMENTO" + ;
		                       ",RC_PERIODO || '01' AS PERIODO" + ;	
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SRC_COMPANY>> SRC" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_RC_FILIAL>> " +;
	                           "    AND RA_MAT = RC_MAT " +;
	                           "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_RC_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON QB_FILIAL = <<SUBSTR_SQB_RC_FILIAL>> " +;
	                           "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_RC_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_RC_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  RV_FILIAL = <<SUBSTR_SRV_RC_FILIAL>> " +;
                               "   AND RV_COD = RC_PD " +;
                               "   AND RV_TIPOCOD IN ('3','4') " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ_FILIAL = <<SUBSTR_RCJ_RC_FILIAL>> " +;
                               "   AND RCJ_CODIGO = RC_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCH_COMPANY>> RCH " +;
                               "    ON RCH_FILIAL = <<SUBSTR_RCH_RC_FILIAL>> " +;
	                           "    AND RCH_PROCES = RC_PROCES " +;
	                           "    AND RCH_PER = RC_PERIODO " +;
	                           "    AND RCH_ROTEIR = RC_ROTEIR " +;
	                           "    AND RCH_NUMPAG = RC_SEMANA " +;
                               "    AND RCH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_RC_FILIAL>> " +;
	                           "    AND CTT_CUSTO = RC_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_RC_FILIAL>> " +;
	                           "    AND CTD_ITEM = RC_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_RC_FILIAL>> " +;
	                           "    AND CTH_CLVL = RC_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRY_COMPANY>> SRY" +;
                               "    ON RY_FILIAL = <<SUBSTR_SRY_RC_FILIAL>> " +;
	                           "    AND RY_CALCULO = RC_ROTEIR " +;
                               "    AND SRY.D_E_L_E_T_ = ' ' " +;
		                       "WHERE ( RC_PERIODO >= <<START_DATE>> AND RC_PERIODO <= <<FINAL_DATE>> ) " + ; 
                               " AND SRC.D_E_L_E_T_ = ' ' " + ;
                               " <<AND_XFILIAL_RC_FILIAL>> ) BASFOLHASRC" + ;
              " UNION ALL" + ;
              " (SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_RD_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+RD_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SRV_RV_FILIAL+RD_PD>> AS BK_VERBA" + ;
		                       ",<<KEY_RCJ_RCJ_FILIAL+RD_PROCES>> AS BK_FUNCPROC" + ;
		                       ",<<KEY_RCH_RCH_FILIAL+RD_PROCES+RD_PERIODO+RD_SEMANA+RD_ROTEIR>> AS BK_PERIODO" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+RD_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+RD_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+RD_CLVL>> AS BK_CLASSE_VALOR" + ;
		                       ",<<KEY_SRY_RY_FILIAL+RD_ROTEIR>> AS BK_ROTEIRO" + ; 
		                       ",RD_TIPO1 AS TIPO1" + ;
		                       ",RD_HORAS AS HORAS" + ;
		                       ",RD_VALOR AS VALOR" + ;
		                       ",RD_DATPGT AS DTPAGAMENTO" + ;
		                       ",RD_PERIODO || '01' AS PERIODO" + ;	
							   ",<<CODE_INSTANCE>> AS INSTANCIA "  + ;                 
		                       "FROM <<SRD_COMPANY>> SRD" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_RD_FILIAL>> " +;
	                           "    AND RA_MAT = RD_MAT " +;
	                           "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_RD_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON QB_FILIAL = <<SUBSTR_SQB_RD_FILIAL>> " +;
	                           "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_RD_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_RD_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +; 
                               " INNER JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  RV_FILIAL = <<SUBSTR_SRV_RD_FILIAL>> " +;
                               "   AND RV_COD = RD_PD " +;
                               "   AND RV_TIPOCOD IN ('3','4') " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ_FILIAL = <<SUBSTR_RCJ_RD_FILIAL>> " +;
                               "   AND RCJ_CODIGO = RD_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCH_COMPANY>> RCH " +;
                               "    ON RCH_FILIAL = <<SUBSTR_RCH_RD_FILIAL>> " +;
	                           "    AND RCH_PROCES = RD_PROCES " +;
	                           "    AND RCH_PER = RD_PERIODO " +;
	                           "    AND RCH_ROTEIR = RD_ROTEIR " +;
	                           "    AND RCH_NUMPAG = RD_SEMANA " +;
                               "    AND RCH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_RD_FILIAL>> " +;
	                           "    AND CTT_CUSTO = RD_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_RD_FILIAL>> " +;
	                           "    AND CTD_ITEM = RD_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_RD_FILIAL>> " +;
	                           "    AND CTH_CLVL = RD_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRY_COMPANY>> SRY" +;
                               "    ON RY_FILIAL = <<SUBSTR_SRY_RD_FILIAL>> " +;
	                           "    AND RY_CALCULO = RD_ROTEIR " +;
                               "    AND SRY.D_E_L_E_T_ = ' ' " +;
		                       "WHERE ( RD_PERIODO >= <<START_DATE>> AND RD_PERIODO <= <<FINAL_DATE>> ) " + ; 
                               " AND SRD.D_E_L_E_T_ = ' ' " + ;
                               " <<AND_XFILIAL_RD_FILIAL>> ) " 

Return cQuery
