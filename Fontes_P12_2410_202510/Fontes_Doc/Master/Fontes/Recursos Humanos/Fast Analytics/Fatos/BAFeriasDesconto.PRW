#INCLUDE "BADefinition.CH"

NEW ENTITY DescFerias

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFeriasDesconto
A tabela fato Desconto Férias apresenta informacoes dos
descontos feitos em férias dos funcionarios.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAFeriasDesconto from BAEntity
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
Method Setup( ) Class BAFeriasDesconto
    _Super:Setup("DescFerias", FACT, "SRC")
    
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
Method BuildQuery( ) Class BAFeriasDesconto
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_CAT, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_VERBA, BK_FUNCPROC, BK_PERIODO, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR, " +;
              " BK_ROTEIRO, TIPO1, HORAS, VALOR, DTGERACAO, DTPAGAMENTO, PERIODO, INSTANCIA    " + ;
              " FROM (" + ;
              " SELECT  <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
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
		                       ",RC_DTREF AS DTGERACAO" + ;
		                       ",RC_DATA AS DTPAGAMENTO" + ;
                               ",RC_PERIODO || '01' AS PERIODO " + ;
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SRC_COMPANY>> SRC" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON SRA.RA_FILIAL = <<SUBSTR_SRA_RC_FILIAL>> " +;
	                           "    AND SRA.RA_MAT = RC_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON SX5.X5_FILIAL = <<SUBSTR_SX5_RC_FILIAL>> " +;
                               "    AND SX5.X5_TABELA = '28' " +;
                               "    AND SX5.X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON SQB.QB_FILIAL = <<SUBSTR_SQB_RC_FILIAL>> " +;
	                           "    AND SQB.QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON SQ3.Q3_FILIAL = <<SUBSTR_SQ3_RC_FILIAL>> " +;
                               "    AND SQ3.Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON SRJ.RJ_FILIAL = <<SUBSTR_SRJ_RC_FILIAL>> " +;
                               "    AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  SRV.RV_FILIAL = <<SUBSTR_SRV_RC_FILIAL>> " +;
                               "   AND SRV.RV_COD = RC_PD " +;
		                       "   AND ((SRV.RV_TIPOCOD IN ('2') AND SRV.RV_CODFOL NOT IN ('0065','0232')) OR SRV.RV_CODFOL = '0168') " + ;
                               "   AND SRV.RV_CODFOL NOT IN ('0102') " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ.RCJ_FILIAL = <<SUBSTR_RCJ_RC_FILIAL>> " +;
                               "   AND RCJ.RCJ_CODIGO = RC_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCH_COMPANY>> RCH " +;
                               "    ON RCH_FILIAL = <<SUBSTR_RCH_RC_FILIAL>> " +;
	                           "    AND RCH.RCH_PROCES = RC_PROCES " +;
	                           "    AND RCH.RCH_PER = RC_PERIODO " +;
	                           "    AND RCH.RCH_ROTEIR = RC_ROTEIR " +;
	                           "    AND RCH.RCH_NUMPAG = RC_SEMANA " +;
                               "    AND RCH.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT.CTT_FILIAL = <<SUBSTR_CTT_RC_FILIAL>> " +;
	                           "    AND CTT.CTT_CUSTO = RC_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD.CTD_FILIAL = <<SUBSTR_CTD_RC_FILIAL>> " +;
	                           "    AND CTD.CTD_ITEM = RC_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH.CTH_FILIAL = <<SUBSTR_CTH_RC_FILIAL>> " +;
	                           "    AND CTH.CTH_CLVL = RC_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRY_COMPANY>> SRY" +;
                               "    ON SRY.RY_FILIAL = <<SUBSTR_SRY_RC_FILIAL>> " +;
	                           "    AND SRY.RY_CALCULO = RC_ROTEIR " +;
                               "    AND SRY.D_E_L_E_T_ = ' ' " +;  
		                       "WHERE (  SRC.RC_PERIODO >= <<START_DATE>> AND SRC.RC_PERIODO <= <<FINAL_DATE>>  ) " + ;
                               " AND SRC.RC_TIPO2 = 'K'  " + ;
                               " AND SRC.D_E_L_E_T_ = ' '  " + ;
                               " <<AND_XFILIAL_RD_FILIAL>> " + ;
            " UNION ALL " + ; 
            " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
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
		                       ",RD_DTREF AS DTGERACAO" + ;
		                       ",RD_DATPGT AS DTPAGAMENTO" + ;
                               ",RD_PERIODO || '01' AS PERIODO " + ;
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SRD_COMPANY>> SRD" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON SRA.RA_FILIAL = <<SUBSTR_SRA_RD_FILIAL>> " +;
	                           "    AND SRA.RA_MAT = RD_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON SX5.X5_FILIAL = <<SUBSTR_SX5_RD_FILIAL>> " +;
                               "    AND SX5.X5_TABELA = '28' " +;
                               "    AND SX5.X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON SQB.QB_FILIAL = <<SUBSTR_SQB_RD_FILIAL>> " +;
	                           "    AND SQB.QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON SQ3.Q3_FILIAL = <<SUBSTR_SQ3_RD_FILIAL>> " +;
                               "    AND SQ3.Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON SRJ.RJ_FILIAL = <<SUBSTR_SRJ_RD_FILIAL>> " +;
                               "    AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  SRV.RV_FILIAL = <<SUBSTR_SRV_RD_FILIAL>> " +;
                               "   AND RV_COD = RD_PD " +;
		                       "   AND ((SRV.RV_TIPOCOD IN ('2') AND SRV.RV_CODFOL NOT IN ('0065','0232')) OR SRV.RV_CODFOL = '0168') " + ;
                               "   AND SRV.RV_CODFOL NOT IN ('0102') " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ.RCJ_FILIAL = <<SUBSTR_RCJ_RD_FILIAL>> " +;
                               "   AND RCJ.RCJ_CODIGO = RD_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCH_COMPANY>> RCH " +;
                               "    ON RCH_FILIAL = <<SUBSTR_RCH_RD_FILIAL>> " +;
	                           "    AND RCH.RCH_PROCES = RD_PROCES " +;
	                           "    AND RCH.RCH_PER = RD_PERIODO " +;
	                           "    AND RCH.RCH_ROTEIR = RD_ROTEIR " +;
	                           "    AND RCH.RCH_NUMPAG = RD_SEMANA " +;
                               "    AND RCH.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT.CTT_FILIAL = <<SUBSTR_CTT_RD_FILIAL>> " +;
	                           "    AND CTT.CTT_CUSTO = RD_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD.CTD_FILIAL = <<SUBSTR_CTD_RD_FILIAL>> " +;
	                           "    AND CTD.CTD_ITEM = RD_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH.CTH_FILIAL = <<SUBSTR_CTH_RD_FILIAL>> " +;
	                           "    AND CTH.CTH_CLVL = RD_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRY_COMPANY>> SRY" +;
                               "    ON SRY.RY_FILIAL = <<SUBSTR_SRY_RD_FILIAL>> " +;
	                           "    AND SRY.RY_CALCULO = RD_ROTEIR " +;
                               "    AND SRY.D_E_L_E_T_ = ' ' " +;  
		                       "WHERE (  RD_PERIODO >= <<START_DATE>> AND RD_PERIODO <= <<FINAL_DATE>>) " + ;
                               " AND SRD.RD_TIPO2 = 'K'  " + ;
                               " AND SRD.D_E_L_E_T_ = ' '  " + ;
                               " <<AND_XFILIAL_RD_FILIAL>> " + ;
            " UNION ALL " + ; 
            " SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_RR_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+RR_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ; 
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SRV_RV_FILIAL+RR_PD>> AS BK_VERBA" + ;
		                       ",<<KEY_RCJ_RCJ_FILIAL+RR_PROCES>> AS BK_FUNCPROC" + ;
		                       ",<<KEY_RCH_RCH_FILIAL+RR_PROCES+RR_PERIODO+RR_SEMANA+RR_ROTEIR>> AS BK_PERIODO" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+RR_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+RR_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+RR_CLVL>> AS BK_CLASSE_VALOR" + ;
		                       ",<<KEY_SRY_RY_FILIAL+RR_ROTEIR>> AS BK_ROTEIRO" + ; 
		                       ",RR_TIPO1 AS TIPO1" + ;
		                       ",RR_HORAS AS HORAS" + ;
		                       ",RR_VALOR AS VALOR" + ;
		                       ",RR_DATA AS DTGERACAO" + ;
		                       ",RR_DATAPAG AS DTPAGAMENTO" + ;
                               ",RR_PERIODO || '01' AS PERIODO " + ;
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SRR_COMPANY>> SRR" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON SRA.RA_FILIAL = <<SUBSTR_SRA_RR_FILIAL>> " +;
	                           "    AND SRA.RA_MAT = RR_MAT " +;
	                           "    AND SRA.RA_PROCES = RR_PROCES " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON SX5.X5_FILIAL = <<SUBSTR_SX5_RR_FILIAL>> " +;
                               "    AND SX5.X5_TABELA = '28' " +;
                               "    AND SX5.X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON SQB.QB_FILIAL = <<SUBSTR_SQB_RR_FILIAL>> " +;
	                           "    AND SQB.QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON SQ3.Q3_FILIAL = <<SUBSTR_SQ3_RR_FILIAL>> " +;
                               "    AND SQ3.Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON SRJ.RJ_FILIAL = <<SUBSTR_SRJ_RR_FILIAL>> " +;
                               "    AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  SRV.RV_FILIAL = <<SUBSTR_SRV_RR_FILIAL>> " +;
                               "   AND SRV.RV_COD = RR_PD " +;
		                       "   AND (SRV.RV_TIPOCOD IN ('2') AND SRV.RV_CODFOL IN ('0065','0232')) " + ;
                               "   AND SRV.RV_CODFOL NOT IN ('0102') " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ.RCJ_FILIAL = <<SUBSTR_RCJ_RR_FILIAL>> " +;
                               "   AND RCJ.RCJ_CODIGO = RR_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCH_COMPANY>> RCH " +;
                               "    ON RCH.RCH_FILIAL = <<SUBSTR_RCH_RR_FILIAL>> " +;
	                           "    AND RCH.RCH_PROCES = RR_PROCES " +;
	                           "    AND RCH.RCH_PER = RR_PERIODO " +;
	                           "    AND RCH.RCH_ROTEIR = RR_ROTEIR " +;
	                           "    AND RCH.RCH_NUMPAG = RR_SEMANA " +;
                               "    AND RCH.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT.CTT_FILIAL = <<SUBSTR_CTT_RR_FILIAL>> " +;
	                           "    AND CTT.CTT_CUSTO = RR_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD.CTD_FILIAL = <<SUBSTR_CTD_RR_FILIAL>> " +;
	                           "    AND CTD.CTD_ITEM = RR_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON  CTH.CTH_FILIAL = <<SUBSTR_CTH_RR_FILIAL>> " +;
	                           "    AND CTH.CTH_CLVL = RR_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SRY_COMPANY>> SRY" +;
                               "    ON  SRY.RY_FILIAL = <<SUBSTR_SRY_RR_FILIAL>> " +;
	                           "    AND SRY.RY_CALCULO = RR_ROTEIR " +;
                               "    AND SRY.D_E_L_E_T_ = ' ' " +;    
                               " INNER JOIN <<SRH_COMPANY>> SRH" +;
                               "   ON  SRH.RH_FILIAL = <<SUBSTR_SRY_RR_FILIAL>> " +;
							   "   AND SRH.RH_MAT = RR_MAT " +;
							   "   AND SRH.RH_PERIODO = RR_PERIODO " +;
							   "   AND SRH.RH_ROTEIR = RR_ROTEIR " +;
							   "   AND SRH.RH_DATAINI = RR_DATA " +;
							   "   AND SRH.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SRD_COMPANY>> SRD" +;
                               "    ON SRD.RD_FILIAL = <<SUBSTR_SRY_RD_FILIAL>> " +;
	                           "    AND SRD.RD_MAT = RR_MAT " +;
                               "    AND SRD.RD_PERIODO = RR_PERIODO " +;
                               "    AND SRD.RD_TIPO2 = 'K' " +;
                               "    AND SRD.RD_PD = (SELECT SRV.RV_COD FROM <<SRV_COMPANY>> SRV WHERE RV_FILIAL = <<SUBSTR_SRV_RD_FILIAL>> AND SRV.D_E_L_E_T_ = ' ' AND SRV.RV_CODFOL = '0168')" +;
                               " LEFT JOIN <<SRC_COMPANY>> SRC" +;
                               "    ON SRC.RC_FILIAL = <<SUBSTR_SRY_RC_FILIAL>> " +;
	                           "    AND SRC.RC_MAT = RR_MAT " +;
                               "    AND SRC.RC_PERIODO = RR_PERIODO " +;
                               "    AND SRC.RC_TIPO2 = 'K' " +;
                               "    AND SRC.RC_PD = (SELECT SRV.RV_COD FROM <<SRV_COMPANY>> SRV WHERE RV_FILIAL = <<SUBSTR_SRV_RC_FILIAL>> AND SRV.D_E_L_E_T_ = ' ' AND SRV.RV_CODFOL = '0168')" +;
                               " INNER JOIN ( SELECT SRA.RA_FILIAL AS FILIAL, SRA.RA_MAT AS MAT, " +;
                               "              CASE WHEN LAG(SRA.RA_DEMISSA,1,'X') OVER(PARTITION BY SRA.RA_CIC ORDER BY SRA.R_E_C_N_O_) = 'X' " + ;
							   "	               THEN SRA.RA_DEMISSA " + ;
							   "	               ELSE LAG(SRA.RA_DEMISSA,1,'X') OVER(PARTITION BY SRA.RA_CIC ORDER BY SRA.R_E_C_N_O_) " + ;
							   "              END AS INICIO, " + ;
                               "              CASE WHEN SRA.RA_DEMISSA = '' " + ;
							   "	               THEN '20501231' " + ;
							   "	               ELSE SRA.RA_DEMISSA " + ;
							   "               END AS FIM " + ;
                               "              , SRA.R_E_C_N_O_ " +;
                               "             FROM <<SRA_COMPANY>> SRA" +;
                               "              WHERE SRA.D_E_L_E_T_ = '' AND RA_CATFUNC <> 'A') HISTORICO ON HISTORICO.FILIAL = SRR.RR_FILIAL AND HISTORICO.MAT = SRR.RR_MAT AND  SRR.RR_PERIODO  >= HISTORICO.INICIO AND SRR.RR_PERIODO <= HISTORICO.FIM" +;                             
                               " WHERE (SRR.RR_PERIODO >= <<START_DATE>> AND SRR.RR_PERIODO <= <<FINAL_DATE>> )  " +;
                               "    AND SRR.D_E_L_E_T_ = ' '  " + ;
                               "    AND SRD.RD_MAT IS NULL  " + ;
                               "    AND SRC.RC_MAT IS NULL  " + ;
                               " <<AND_XFILIAL_RR_FILIAL>> ) DESCFERIAS" 

Return cQuery
