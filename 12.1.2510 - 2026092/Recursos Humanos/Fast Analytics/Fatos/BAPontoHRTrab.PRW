#INCLUDE "BADefinition.CH"

NEW ENTITY HrTrabPonto

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPontoHRTrab
A tabela fato Ponto Horas Trabalhadas apresenta informacoes dos horas 
trabalhadas para os funcionários.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BAPontoHRTrab from BAEntity
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
Method Setup( ) Class BAPontoHRTrab
    _Super:Setup("HrTrabPonto", FACT, "SPC")
    
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
Method BuildQuery( ) Class BAPontoHRTrab
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_CAT, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_EVENTO, BK_TURNO, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR, DTEVENTO, HORAS, INSTANCIA " + ;
              " FROM (" + ;
              " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_PC_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+PC_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SP9_P9_FILIAL+PC_PD>> AS BK_EVENTO" + ;
		                       ",<<KEY_SR6_R6_FILIAL+PC_TURNO>> AS BK_TURNO" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+PC_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+SRA.RA_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+SRA.RA_CLVL>> AS BK_CLASSE_VALOR" + ;	
		                       ",PC_DATA AS DTEVENTO" + ;                       
		                       ",ROUND(CAST(PC_QUANTC AS INTEGER) + ( ( PC_QUANTC - CAST(PC_QUANTC AS INTEGER) ) / 0.6 ),4) AS HORAS" + ;
                               ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SPC_COMPANY>> SPC" + ;
                               "  INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_PC_FILIAL>> " +;
	                           "    AND RA_MAT = PC_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_PC_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON QB_FILIAL = <<SUBSTR_SQB_PC_FILIAL>> " +;
	                           "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_PC_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_PC_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SP9_COMPANY>> SP9 " +;
                               "    ON  P9_FILIAL = <<SUBSTR_SP9_PC_FILIAL>> " +;
	                           "    AND P9_CODIGO = PC_PD " +;
                               "    AND P9_IDPON IN ('001A','004A') " +;
                               "    AND SP9.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SR6_COMPANY>> SR6 " +;
                               "    ON R6_FILIAL = <<SUBSTR_CTT_PC_FILIAL>> " +;
                               "    AND R6_TURNO = PC_TURNO " +;
                               "    AND SR6.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<CTT_COMPANY>> CTT " +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_PC_FILIAL>> " +;
                               "    AND CTT_CUSTO = PC_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_PC_FILIAL>> " +;
	                           "    AND CTD_ITEM = SRA.RA_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_PC_FILIAL>> " +;
	                           "    AND CTH_CLVL = SRA.RA_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
		                       "WHERE ( SPC.PC_DATA >= <<START_DATE>> AND SPC.PC_DATA <= <<FINAL_DATE>> )" + ; 
                               " AND SPC.D_E_L_E_T_ = ' '  " + ;
                               " <<AND_XFILIAL_PC_FILIAL>> ) HRTRABABERTO" + ;
              " UNION ALL " + ;
              " (SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
              					",<<KEY_FILIAL_PH_FILIAL>> AS BK_FILIAL" + ;
						        ",<<KEY_SRA_RA_FILIAL+PH_MAT>> AS BK_FUNCIONARIO" + ;
		                        ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                        ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ;
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
						        ",<<KEY_SP9_P9_FILIAL+PH_PD>> AS BK_EVENTO" + ;
		                        ",<<KEY_SR6_R6_FILIAL+PH_TURNO>> AS BK_TURNO" + ;
		                        ",<<KEY_CTT_CTT_FILIAL+PH_CC>> AS BK_CENTRO_CUSTO" + ;
		                        ",<<KEY_CTD_CTD_FILIAL+SRA.RA_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                        ",<<KEY_CTH_CTH_FILIAL+SRA.RA_CLVL>> AS BK_CLASSE_VALOR" + ;	
						        ",PH_DATA AS DTEVENTO" + ;
		                        ",ROUND(CAST(PH_QUANTC AS INTEGER) + ( ( PH_QUANTC - CAST(PH_QUANTC AS INTEGER) ) / 0.6 ),4) AS HORAS" + ;
                                ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
			                    "FROM <<SPH_COMPANY>> SPH" + ;
	                            "  INNER JOIN <<SRA_COMPANY>> SRA " +;
	                            "    ON RA_FILIAL = <<SUBSTR_SRA_PH_FILIAL>> " +;
	                            "    AND RA_MAT = PH_MAT " +;
                                "    AND SRA.D_E_L_E_T_ = ' ' " +;
                                " INNER JOIN <<SX5_COMPANY>> SX5" +;
                                "    ON X5_FILIAL = <<SUBSTR_SX5_PH_FILIAL>> " +;
                                "    AND X5_TABELA = '28' " +;
                                "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                                "    AND SX5.D_E_L_E_T_ = ' ' " +;
                                " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                                "    ON QB_FILIAL = <<SUBSTR_SQB_PH_FILIAL>> " +;
	                            "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                                "    AND SQB.D_E_L_E_T_ = ' ' " +;  
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_PH_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_PH_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +; 
	                            "  INNER JOIN <<SP9_COMPANY>> SP9 " +;
	                            "    ON  P9_FILIAL = <<SUBSTR_SP9_PH_FILIAL>> " +;
	                            "    AND P9_CODIGO = PH_PD " +;
                                "    AND P9_IDPON IN ('001A','004A') " +;
                                "    AND SP9.D_E_L_E_T_ = ' ' " +;
                                "  INNER JOIN <<SR6_COMPANY>> SR6 " +;
                                "    ON R6_FILIAL = <<SUBSTR_CTT_PH_FILIAL>> " +;
                                "    AND R6_TURNO = PH_TURNO " +;
                                "    AND SR6.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<CTT_COMPANY>> CTT " +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_PH_FILIAL>> " +;
                               "    AND CTT_CUSTO = PH_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_PH_FILIAL>> " +;
	                           "    AND CTD_ITEM = SRA.RA_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_PH_FILIAL>> " +;
	                           "    AND CTH_CLVL = SRA.RA_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
			                    "WHERE ( SPH.PH_DATA >= <<START_DATE>> AND SPH.PH_DATA <= <<FINAL_DATE>> )" + ; 
	                            " AND SPH.D_E_L_E_T_ = ' '  " + ;
	                            " <<AND_XFILIAL_PH_FILIAL>> )" 

Return cQuery
