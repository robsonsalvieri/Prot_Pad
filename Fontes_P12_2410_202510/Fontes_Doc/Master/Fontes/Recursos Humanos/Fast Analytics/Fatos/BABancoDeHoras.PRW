#INCLUDE "BADefinition.CH"

NEW ENTITY BANCODEHORAS

//-------------------------------------------------------------------
/*/{Protheus.doc} BABancoDeHoras
A tabela fato Banco de Horas apresenta informacoes do banco de horas
dos funcionarios.

@author  raquel.andrade
@since   24/05/2019
/*/
//-------------------------------------------------------------------
Class BABancoDeHoras from BAEntity
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
Method Setup( ) Class BABancoDeHoras
    _Super:Setup("BancoDeHoras", FACT, "SPI")
    
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
Method BuildQuery( ) Class BABancoDeHoras
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_CAT, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_EVENTO, BK_TURNO, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR,  DTEVENTO, HRSNORMAIS, HRSVALORIZADAS, INSTANCIA " + ;
              " FROM (" + ;
              " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_PI_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_SRA_RA_FILIAL+PI_MAT>> AS BK_FUNCIONARIO" + ;
		                       ",<<KEY_SX5_X5_FILIAL+SRA.RA_CATFUNC>> AS BK_CAT" + ;
		                       ",<<KEY_SQB_QB_FILIAL+SRA.RA_DEPTO>> AS BK_DEPTO" + ; 
		                       ",<<KEY_SQ3_Q3_FILIAL+SRA.RA_CARGO>> AS BK_CARGO" + ;
		                       ",<<KEY_SRJ_RJ_FILIAL+SRA.RA_CODFUNC>> AS BK_FUNCAO" + ;
		                       ",<<KEY_SP9_P9_FILIAL+P9_CODIGO>> AS BK_EVENTO" + ;
		                       ",<<KEY_SR6_R6_FILIAL+SRA.RA_TNOTRAB>> AS BK_TURNO" + ;
		                       ",<<KEY_CTT_CTT_FILIAL+PI_CC>> AS BK_CENTRO_CUSTO" + ;
		                       ",<<KEY_CTD_CTD_FILIAL+SRA.RA_ITEM>> AS BK_ITEM_CONTABIL" + ;
		                       ",<<KEY_CTH_CTH_FILIAL+SRA.RA_CLVL>> AS BK_CLASSE_VALOR" + ;
		                       ",PI_DATA AS DTEVENTO" + ;
		                       ",ROUND(CAST(PI_QUANT AS INTEGER) + ( ( PI_QUANT - CAST(PI_QUANT AS INTEGER) ) / 0.6 ),4) AS HRSNORMAIS" + ;
		                       ",ROUND(CAST(PI_QUANTV AS INTEGER) + ( ( PI_QUANT - CAST(PI_QUANTV AS INTEGER) ) / 0.6 ),4) AS HRSVALORIZADAS" + ;
							   ",<<CODE_INSTANCE>> AS INSTANCIA " + ;
		                       "FROM <<SPI_COMPANY>> SPI" + ;
                               "  INNER JOIN <<SRA_COMPANY>> SRA " +;
                               "    ON RA_FILIAL = <<SUBSTR_SRA_PI_FILIAL>> " +;
                               "    AND RA_MAT = PI_MAT " +;
                               "    AND SRA.D_E_L_E_T_ = ' ' " +;
                               " INNER JOIN <<SX5_COMPANY>> SX5" +;
                               "    ON X5_FILIAL = <<SUBSTR_SX5_PI_FILIAL>> " +;
                               "    AND X5_TABELA = '28' " +;
                               "    AND X5_CHAVE = SRA.RA_CATFUNC " +;
                               "    AND SX5.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<SQB_COMPANY>> SQB" +;
                               "    ON QB_FILIAL = <<SUBSTR_SQB_PI_FILIAL>> " +;
	                           "    AND QB_DEPTO = SRA.RA_DEPTO " +;
                               "    AND SQB.D_E_L_E_T_ = ' ' " +;
                               "  LEFT JOIN <<SQ3_COMPANY>> SQ3 " +;
                               "    ON Q3_FILIAL = <<SUBSTR_SQ3_PI_FILIAL>> " +;
                               "    AND Q3_CARGO = SRA.RA_CARGO " +;
                               "    AND SQ3.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SRJ_COMPANY>> SRJ " +;
                               "    ON RJ_FILIAL = <<SUBSTR_SRJ_PI_FILIAL>> " +;
                               "    AND RJ_FUNCAO = SRA.RA_CODFUNC " +;
                               "    AND SRJ.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SP9_COMPANY>> SP9 " +;
                               "    ON  P9_FILIAL = <<SUBSTR_SP9_PI_FILIAL>> " +;
                               "    AND P9_CODIGO = PI_PD " +;
                               "    AND SP9.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<SR6_COMPANY>> SR6 " +;
                               "    ON R6_FILIAL = <<SUBSTR_SR6_PI_FILIAL>> " +;
                               "    AND R6_TURNO = SRA.RA_TNOTRAB " +;
                               "    AND SR6.D_E_L_E_T_ = ' ' " +;
                               "  INNER JOIN <<CTT_COMPANY>> CTT " +;
                               "    ON CTT_FILIAL = <<SUBSTR_CTT_PI_FILIAL>> " +;
                               "    AND CTT_CUSTO = PI_CC " +;
                               "    AND CTT.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTD_COMPANY>> CTD" +;
                               "    ON CTD_FILIAL = <<SUBSTR_CTD_PI_FILIAL>> " +;
	                           "    AND CTD_ITEM = SRA.RA_ITEM " +;
                               "    AND CTD.D_E_L_E_T_ = ' ' " +;
                               " LEFT JOIN <<CTH_COMPANY>> CTH" +;
                               "    ON CTH_FILIAL = <<SUBSTR_CTH_PI_FILIAL>> " +;
	                           "    AND CTH_CLVL = SRA.RA_CLVL " +;
                               "    AND CTH.D_E_L_E_T_ = ' ' " +;
		                       "WHERE ( SPI.PI_DATA >= <<START_DATE>> AND SPI.PI_DATA <= <<FINAL_DATE>> ) " +;
		                       " AND SPI.PI_STATUS = ' ' " +;
                               " AND SPI.D_E_L_E_T_ = ' '  " +;
                               " <<AND_XFILIAL_PI_FILIAL>> ) BANCODEHORAS" 

Return cQuery
