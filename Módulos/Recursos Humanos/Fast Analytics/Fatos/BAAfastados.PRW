#INCLUDE "BADefinition.CH"

NEW ENTITY AFASTADOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAfastados
A tabela fato Afastados apresenta informacoes dos funcionarios
que estao ausentes no periodo selecionado.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAAfastados from BAEntity
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
Method Setup( ) Class BAAfastados
    _Super:Setup("Afastados", FACT, "SR8")
    
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
Method BuildQuery( ) Class BAAfastados
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_CAT, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_TPAUSENCIA, BK_VERBA, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR,  " + ; 
     		  " BK_FUNCPROC, BK_CID, DTALT, SEQ, TIPO, DTINICIAL, DTFINAL, DURACAO, DIASEMP, SALDOAPAGAR, DIASPAGOS, DIASPAGAR, CODINTMEDICO, STATUS,REGISTRO, INSTANCIA " + ;
              " FROM (" + ;
              " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_R8_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+R8_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_RCM_RCM_FILIAL+R8_TIPOAFA>> AS BK_TPAUSENCIA" + ;   
		                       ",<<KEY_SRV_RV_FILIAL+R8_PD>> AS BK_VERBA" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+SRA.RA_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+SRA.RA_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+SRA.RA_CLVL>> AS BK_CLASSE_VALOR" + ;     
                               ",<<KEY_RCJ_RCJ_FILIAL+RA_PROCES>> AS BK_FUNCPROC" + ;   
                               ",<<KEY_TMR_TMR_FILIAL+TMR_CID>> AS BK_CID" + ;        
		                       ",R8_DATA AS DTALT" + ;
		                       ",R8_SEQ AS SEQ" + ;
		                       ",R8_TIPO AS TIPO" + ;
		                       ",R8_DATAINI AS DTINICIAL" + ;
		                       ",R8_DATAFIM AS DTFINAL" + ;
		                       ",R8_DURACAO AS DURACAO" + ;
		                       ",R8_DIASEMP AS DIASEMP" + ;
		                       ",R8_SDPAGAR AS SALDOAPAGAR" + ;
		                       ",R8_DPAGOS AS DIASPAGOS" + ;
		                       ",R8_DPAGAR AS DIASPAGAR" + ;
		                       ",R8_CID AS CODINTMEDICO" + ;
		                       ",R8_STATUS AS STATUS" + ;
                               ",SR8.R_E_C_N_O_ AS REGISTRO" + ;
                               ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SR8_COMPANY>> SR8" + ;
                               " INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_R8_FILIAL>> " +;
                               "    AND RA_MAT = R8_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_R8_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON QB_FILIAL = <<SUBSTR_SQB_R8_FILIAL>> " +;
	                           "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_R8_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_R8_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCM_COMPANY>> RCM " +;
                               "   ON  RCM_FILIAL = <<SUBSTR_RCM_R8_FILIAL>> " +;
                               "   AND RCM_TIPO = SR8.R8_TIPOAFA " +;
                               "   AND RCM_TIPOAF <> '3' " +;
                               "   AND RCM.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SRV_COMPANY>> SRV " +;
                               "   ON  RV_FILIAL = <<SUBSTR_SRV_R8_FILIAL>> " +;
                               "   AND RV_COD = R8_PD " +;
                               "   AND SRV.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<CTT_COMPANY>> CTT" +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_R8_FILIAL>> " +;
	                           "    AND CTT_CUSTO = SRA.RA_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_R8_FILIAL>> " +;
	                           "    AND CTD_ITEM = SRA.RA_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_R8_FILIAL>> " +;
	                           "    AND CTH_CLVL = SRA.RA_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<RCJ_COMPANY>> RCJ " +;
                               "   ON  RCJ.RCJ_FILIAL = <<SUBSTR_RCJ_R8_FILIAL>> " +;
                               "   AND RCJ.RCJ_CODIGO = SR8.R8_PROCES " +;
                               "   AND RCJ.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<TMR_COMPANY>> TMR" +;
                               "    ON TMR.TMR_FILIAL = <<SUBSTR_TMR_R8_FILIAL>> " +;
	                           "    AND TMR.TMR_CID = SR8.R8_CID " +;
                               "    AND TMR.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SRE_COMPANY>> SRE" +;
                               "    ON  (SRE.RE_FILIALD = <<SUBSTR_SRE_R8_FILIAL>> OR SRE.RE_FILIALP = <<SUBSTR_SRE_R8_FILIAL>> )" +;
	                           "    AND (SRE.RE_MATD = SR8.R8_MAT OR SRE.RE_MATP = SR8.R8_MAT)" +;
                               "    AND SRE.D_E_L_E_T_ = ' ' " +; 
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
                               "              WHERE SRA.D_E_L_E_T_ = '' AND RA_CATFUNC <> 'A') HISTORICO ON HISTORICO.FILIAL = SR8.R8_FILIAL AND HISTORICO.MAT = SR8.R8_MAT AND SR8.R8_DATAINI  >= HISTORICO.INICIO AND SR8.R8_DATAFIM <= HISTORICO.FIM" +;    
		                       "WHERE ((SR8.R8_DATAINI <= <<START_DATE>> AND SR8.R8_DATAFIM >= <<FINAL_DATE>>)" + ;
	                            "      OR (SR8.R8_DATAINI >= <<START_DATE>> AND SR8.R8_DATAFIM <= <<FINAL_DATE>>)" + ;
	                            "      OR (SR8.R8_DATAINI >= <<START_DATE>> AND SR8.R8_DATAINI <= <<FINAL_DATE>>) " + ;
	                            "      OR (SR8.R8_DATAFIM >= <<START_DATE>> AND SR8.R8_DATAFIM <= <<FINAL_DATE>>))" + ;
                               " AND SR8.D_E_L_E_T_ = ' ' <<AND_XFILIAL_R8_FILIAL>> ) AFASTADOS"

Return cQuery
