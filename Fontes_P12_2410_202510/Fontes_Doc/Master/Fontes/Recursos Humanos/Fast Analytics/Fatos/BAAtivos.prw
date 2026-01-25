#INCLUDE "BADefinition.CH"

NEW ENTITY ATIVOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAtivos
Visualiza as informa??es de Funcionarios Ativos.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Class BAAtivos from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padr?o.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAtivos
	_Super:Setup("Ativos", FACT, "SRA")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAtivos
	Local cQuery := ""  
    
	cQuery := " SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_TURNO, BK_ESTCIVL, BK_CAT, BK_GRINRAI, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_FUNCPROC, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR ," + ;
	          " ATIV_NOME, ATIV_APELIDO, ATIV_SEXO, ATIV_NACIONALIDADE, ATIV_NATURALIDADE," + ;
	          " ATIV_DTNASCIMENTO, ATIV_TIPOADM, ATIV_SITFOLH, ATIV_TIPOPAGAMENTO, ATIV_VIEMRAI, ATIV_RESCRAI," + ;
	          " ATIV_CATEGSEFIP, ATIV_CATEGESOCIAL, ATIV_TPCONTRATO, ATIV_SINDICATO, ATIV_CPF, ATIV_PIS, ATIV_RG, ATIV_NUMCP, ATIV_SERCP, ATIV_REGRAAPONT, ATIV_POSSUIPERI," + ; 
	          " ATIV_POSSUIINSAL, ATIV_DEFICIENTE, ATIV_POSSUIADCONF, ATIV_POSSUIADTRF, ATIV_POSSUIADPOSE, QTD_FUNCIONARIOS, ATIV_CODUNIC, ATIV_DTADMISSAO, ATIV_DTDEMISSAO, ATIV_DTAUX, " +;
			  " AFAST_FGTS, DATA_AFAST, INSTANCIA" + ;
	          " FROM (" + ;
	          " SELECT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
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
							   ",SRA.RA_NOME AS ATIV_NOME" + ;
							   ",SRA.RA_APELIDO AS ATIV_APELIDO" + ;
							   ",CASE SRA.RA_SEXO " + ;
							   "	WHEN 'F' THEN 'Feminino' " + ;
							   "	WHEN 'M' THEN 'Masculino' " + ;
							   " END AS ATIV_SEXO " + ;
							   ",SRA.RA_NACIONA AS ATIV_NACIONALIDADE" + ;
							   ",SRA.RA_NATURAL AS ATIV_NATURALIDADE" + ;
							   ",SRA.RA_NASC AS ATIV_DTNASCIMENTO" + ;
							   ",SRA.RA_TIPOADM AS ATIV_TIPOADM" + ;
							   ",SRA.RA_SITFOLH AS ATIV_SITFOLH" + ;
							   ",SRA.RA_TIPOPGT AS ATIV_TIPOPAGAMENTO" + ;
							   ",SRA.RA_VIEMRAI AS ATIV_VIEMRAI" + ;
							   ",SRA.RA_RESCRAI AS ATIV_RESCRAI" + ;
							   ",SRA.RA_CATEG AS ATIV_CATEGSEFIP" + ;
							   ",SRA.RA_CATEFD AS ATIV_CATEGESOCIAL" + ;
							   ",SRA.RA_TPCONTR AS ATIV_TPCONTRATO"  + ; 
							   ",SRA.RA_SINDICA AS ATIV_SINDICATO" + ;
							   ",SRA.RA_CIC AS ATIV_CPF" + ;
							   ",SRA.RA_PIS AS ATIV_PIS" + ;
							   ",SRA.RA_RG AS ATIV_RG" + ;
							   ",SRA.RA_NUMCP AS ATIV_NUMCP" + ;
							   ",SRA.RA_SERCP AS ATIV_SERCP" + ;
							   ",SRA.RA_REGRA AS ATIV_REGRAAPONT" + ;
							   ",CASE SRA.RA_ADCINS " + ;
							   "	WHEN '1' THEN 'Nao possui Periculosidade' " + ;
							   "	WHEN '2' THEN 'Possui Periculosidade' " + ;
							   "END AS ATIV_POSSUIPERI" + ;     
							   ",CASE SRA.RA_ADCINS " + ;
							   "	WHEN '1' THEN 'Nao possui Insalubridade' " + ;
							   "	WHEN '2' THEN 'Possui Insalubridade' " + ;
							   "END AS ATIV_POSSUIINSAL" + ;
							   ",CASE SRA.RA_TPDEFFI " + ;
							   "	WHEN '0' THEN 'Nao possui Deficiencia' " + ;
							   "	WHEN '1' THEN 'Fisica' " + ;
							   "	WHEN '2' THEN 'Auditiva' " + ;
							   "	WHEN '3' THEN 'Visual' " + ;
							   "	WHEN '4' THEN 'Intelectual(mental)' " + ;   
							   "	WHEN '5' THEN 'Multipla' " + ;
							   "	WHEN '6' THEN 'Reabilitado' " + ;
							   "END AS ATIV_DEFICIENTE" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADCCONF = 0 THEN 'Nao possui Adicional de Confianca' " + ;
							   "	ELSE 'Possui Adicional de Confianca' " + ;
							   "END AS ATIV_POSSUIADCONF" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADCTRF = 0 THEN 'Nao possui Adicional de Transferencia' " + ;
							   "	ELSE 'Possui Adicional de Transferencia' " + ;
							   "	END AS ATIV_POSSUIADTRF" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADTPOSE LIKE '%N%'  THEN 'Nao possui Adicional por Tempo de Servico' " + ;
							   "	ELSE 'Possui Adicional por Tempo de Servico' " + ;
							   "	END AS ATIV_POSSUIADPOSE" + ;
		                       ",1 AS QTD_FUNCIONARIOS" + ;
		                       ",SRA.RA_CODUNIC AS ATIV_CODUNIC" + ; 
				               ",ISNULL((CASE WHEN SRA.RA_RESCRAI IN  ('30','31')" + ;
				               "             THEN SRA.RA_ADMISSA" + ;
				               "             ELSE (SELECT min(SRE.RE_DATA) FROM <<SRE_COMPANY>> SRE WHERE SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP AND SRA.RA_CC = SRE.RE_CCP ) END),SRA.RA_ADMISSA)" + ;
				               " AS ATIV_DTADMISSAO" + ;  
				               ",ISNULL((CASE WHEN SRA.RA_RESCRAI NOT IN  ('30','31')" + ;
				               "             THEN SRA.RA_DEMISSA" + ;
				               "             ELSE (SELECT min(SRE.RE_DATA) FROM <<SRE_COMPANY>> SRE WHERE SRA.RA_FILIAL = SRE.RE_FILIALD AND SRA.RA_MAT = SRE.RE_MATD AND SRA.RA_CC = SRE.RE_CCD ) END),SRA.RA_DEMISSA)" + ;
				               " AS ATIV_DTDEMISSAO" + ;
				               ",CASE WHEN SRA.RA_RESCRAI IN  ('30','31')" + ;
				               "             THEN SRA.RA_DEMISSA" + ;
				               "             ELSE '' END" + ;
				               " AS ATIV_DTAUX" + ;
							   ",RA_AFASFGT AS AFAST_FGTS" +;
							   ",(SELECT DISTINCT SR8.R8_DATA FROM <<SR8_COMPANY>> SR8 WHERE  SR8.R8_MAT = SRA.RA_MAT AND SR8.R8_FILIAL = SRA.RA_FILIAL AND SRA.D_E_L_E_T_ = '' AND SR8.R8_DATAFIM = '' AND SR8.D_E_L_E_T_ = '') AS DATA_AFAST" + ;
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
		                       	" <<AND_XFILIAL_RA_FILIAL>> ) ATIVOS"	
	Return cQuery
