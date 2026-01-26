#INCLUDE "BADefinition.CH"

NEW ENTITY FUNCIONARIOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFuncionários
Visualiza as informa??es de Funcionarios.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Class BAFuncionarios from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAFuncionarios
	_Super:Setup("Funcionarios", DIMENSION, "SRA")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr?i a query da entidade.
@return cQuery, string, query a ser processada.

@author  raquel.andrade
@since   29/08/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAFuncionarios
	Local cQuery := ""  
    
	cQuery := " SELECT BK_EMPRESA, BK_FILIAL, BK_FUNCIONARIO, BK_TURNO, BK_ESTCIVL, BK_CAT, BK_GRINRAI, BK_DEPTO, BK_CARGO, BK_FUNCAO, BK_FUNCPROC, BK_CENTRO_CUSTO, BK_ITEM_CONTABIL, BK_CLASSE_VALOR , BK_HISTSAL" + ;
	          " FUNC_MAT, FUNC_NOME, FUNC_APELIDO, FUNC_SEXO, FUNC_NACIONALIDADE, FUNC_NATURALIDADE," + ;
	          " FUNC_DTNASCIMENTO, FUNC_TIPOADM, FUNC_SITFOLH, FUNC_TIPOPAGAMENTO, FUNC_VIEMRAI, FUNC_RESCRAI," + ;
	          " FUNC_CATEGSEFIP, FUNC_CATEGESOCIAL, FUNC_TPCONTRATO, FUNC_SINDICATO, FUNC_CPF, FUNC_PIS, FUNC_RG, FUNC_NUMCP, FUNC_SERCP, FUNC_REGRAAPONT, FUNC_POSSUIPERI," + ; 
	          " FUNC_POSSUIINSAL, FUNC_DEFICIENTE, FUNC_POSSUIADCONF, FUNC_POSSUIADTRF, FUNC_POSSUIADPOSE, FUNC_CODUNIC, FUNC_DTADMISSAO, FUNC_DTDEMISSAO," + ;
			  " FUNC_DTAUX, FUNCHRSDIA, FUNC_RACACOR, FUNC_TMPCASA, FUNC_TMPULTSAL, FUNC_GERFUNC, FUNC_DTALTSAL, FUNC_LIDER, INSTANCIA" + ;
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
							   ",<<KEY_SR7_R7_FILIAL+RA_MAT>> AS BK_HISTSAL" + ;
							   ",SRA.RA_MAT AS FUNC_MAT" + ;
							   ",SRA.RA_NOME AS FUNC_NOME" + ;
							   ",SRA.RA_APELIDO AS FUNC_APELIDO" + ;
							   ",CASE SRA.RA_SEXO " + ;
							   "	WHEN 'F' THEN 'Feminino' " + ;
							   "	WHEN 'M' THEN 'Masculino' " + ;
							   " END AS FUNC_SEXO " + ;
							   ",SRA.RA_NACIONA AS FUNC_NACIONALIDADE" + ;
							   ",SRA.RA_NATURAL AS FUNC_NATURALIDADE" + ;
							   ",SRA.RA_NASC AS FUNC_DTNASCIMENTO" + ;
							   ",SRA.RA_ADMISSA AS FUNC_DTADMISSAO" + ;
							   ",SRA.RA_DEMISSA AS FUNC_DTDEMISSAO" + ;
							   ",SRA.RA_TIPOADM AS FUNC_TIPOADM" + ;
							   ",SRA.RA_SITFOLH AS FUNC_SITFOLH" + ;
							   ",SRA.RA_TIPOPGT AS FUNC_TIPOPAGAMENTO" + ;
							   ",SRA.RA_VIEMRAI AS FUNC_VIEMRAI" + ;
							   ",SRA.RA_RESCRAI AS FUNC_RESCRAI" + ;
							   ",SRA.RA_CATEG AS FUNC_CATEGSEFIP" + ;
							   ",SRA.RA_CATEFD AS FUNC_CATEGESOCIAL" + ;
							   ",SRA.RA_TPCONTR AS FUNC_TPCONTRATO"  + ; 
							   ",SRA.RA_SINDICA AS FUNC_SINDICATO" + ;
							   ",SRA.RA_CIC AS FUNC_CPF" + ;
							   ",SRA.RA_PIS AS FUNC_PIS" + ;
							   ",SRA.RA_RG AS FUNC_RG" + ;
							   ",SRA.RA_NUMCP AS FUNC_NUMCP" + ;
							   ",SRA.RA_SERCP AS FUNC_SERCP" + ;
							   ",SRA.RA_REGRA AS FUNC_REGRAAPONT" + ;
							   ",CASE SRA.RA_ADCINS " + ;
							   "	WHEN '1' THEN 'Nao possui Periculosidade' " + ;
							   "	WHEN '2' THEN 'Possui Periculosidade' " + ;
							   "END AS FUNC_POSSUIPERI" + ;     
							   ",CASE SRA.RA_ADCINS " + ;
							   "	WHEN '1' THEN 'Nao possui Insalubridade' " + ;
							   "	WHEN '2' THEN 'Possui Insalubridade' " + ;
							   "END AS FUNC_POSSUIINSAL" + ;
							   ",CASE SRA.RA_TPDEFFI " + ;
							   "	WHEN '0' THEN 'Nao possui Deficiencia' " + ;
							   "	WHEN '1' THEN 'Fisica' " + ;
							   "	WHEN '2' THEN 'Auditiva' " + ;
							   "	WHEN '3' THEN 'Visual' " + ;
							   "	WHEN '4' THEN 'Intelectual(mental)' " + ;   
							   "	WHEN '5' THEN 'Multipla' " + ;
							   "	WHEN '6' THEN 'Reabilitado' " + ;
							   "END AS FUNC_DEFICIENTE" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADCCONF = 0 THEN 'Nao possui Adicional de Confianca' " + ;
							   "	ELSE 'Possui Adicional de Confianca' " + ;
							   "END AS FUNC_POSSUIADCONF" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADCTRF = 0 THEN 'Nao possui Adicional de Transferencia' " + ;
							   "	ELSE 'Possui Adicional de Transferencia' " + ;
							   "	END AS FUNC_POSSUIADTRF" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_ADTPOSE LIKE '%N%'  THEN 'Nao possui Adicional por Tempo de Servico' " + ;
							   "	ELSE 'Possui Adicional por Tempo de Servico' " + ;
							   "	END AS FUNC_POSSUIADPOSE" + ;
		                       ",SRA.RA_CODUNIC AS FUNC_CODUNIC" + ; 
				               ",CASE WHEN SRA.RA_RESCRAI IN  ('30','31')" + ;
				               "             THEN SRA.RA_DEMISSA" + ;
				               "             ELSE '' END" + ;
				               " AS FUNC_DTAUX" + ;
							   ",CONVERT(VARCHAR(100), SRA.RA_HRSDIA) AS FUNCHRSDIA" + ;
							   ",CASE  " + ;
							   "	WHEN RA_RACACOR = 1 THEN 'INDIGENA'" + ;
							   "	WHEN RA_RACACOR = 2 THEN 'BRANCA'" + ;
							   "	WHEN RA_RACACOR = 6 THEN 'AMARELA'" + ;
							   "    WHEN RA_RACACOR = 8 THEN 'PARDA'" + ;
							   "    WHEN RA_RACACOR = 4 THEN 'PRETA'" + ;
							   "ELSE 'NÃO INFORMADO'" + ;
							   "END AS FUNC_RACACOR" + ;
							   ",CASE  " + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 179 THEN '1'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 364 THEN '2'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 1094 THEN '3'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 1824 THEN '4'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 2554 THEN '5'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 3284 THEN '6'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) > 3284 THEN '7'" + ;
							   "ELSE 'N/A' END AS FUNC_TMPCASA" + ;
							   ",CASE  " + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 179 THEN '1'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 364 THEN '2'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 1094 THEN '3'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 1824 THEN '4'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 2554 THEN '5'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) <= 3284 THEN '6'" + ;
							   "	WHEN DATEDIFF(DAY, SR7.R7_DATA, GETDATE()) > 3284 THEN '7'" + ;
							   "ELSE ( CASE" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 179 THEN '1'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 364 THEN '2'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 1094 THEN '3'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 1824 THEN '4'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 2554 THEN '5'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) <= 3284 THEN '6'" + ;
							   "	WHEN DATEDIFF(DAY, SRA.RA_ADMISSA, GETDATE()) > 3284 THEN '7'" + ;
							   "ELSE 'N/A' END) END AS FUNC_TMPULTSAL" + ;
							   ",CASE  " + ;
							   "	WHEN SRA.RA_NASC = NULL THEN 'N/A'" + ;
							   "	WHEN DATEPART(YEAR, SRA.RA_NASC) <= 1964 THEN 'BABY BOOMER'" + ;
							   "	WHEN DATEPART(YEAR, SRA.RA_NASC) BETWEEN 1965 AND 1980 THEN 'X'" + ;
							   "	WHEN DATEPART(YEAR, SRA.RA_NASC) BETWEEN 1981 AND 1996 THEN 'Y'" + ;
							   "	WHEN DATEPART(YEAR, SRA.RA_NASC) BETWEEN 1997 AND 2012 THEN 'Z'" + ;
							   "ELSE 'ALFA' END AS FUNC_GERFUNC" + ;
							   ",CASE  " + ;
							   "	WHEN SR7.R7_DATA IS NULL THEN SRA.RA_ADMISSA  " + ;
							   "ELSE SR7.R7_DATA END AS FUNC_DTALTSAL" + ;
							   ",CASE  " + ;
							   "	WHEN RA_FILIAL = SQB.QB_FILRESP AND RA_MAT = SQB.QB_MATRESP THEN '1'" + ;
							   "ELSE '0' END AS FUNC_LIDER" + ;
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
							   " LEFT JOIN <<SR7_COMPANY>> SR7" +;
							   "    ON  R7_FILIAL = RA_FILIAL" +;
							   "    AND R7_MAT = RA_MAT" +;
							   "    AND SR7.R7_DATA = (SELECT MAX(SR72.R7_DATA) FROM <<SR7_COMPANY>> SR72" +;
							   "                       WHERE SR72.R7_FILIAL = SRA.RA_FILIAL AND SR72.R7_MAT = SRA.RA_MAT" +;
							   "    						 AND (SR72.R7_TIPO IN ( <<SAL_INCREASE_TYPE>> ) OR CONCAT(<<SAL_INCREASE_TYPE>>,'') = ''))" + ;
							   "    AND SR7.D_E_L_E_T_ = ' ' " + ;
		                       " WHERE SRA.D_E_L_E_T_ = ' ' " + ;
		                       " <<AND_XFILIAL_RA_FILIAL>> ) FUNCIONARIOS"	
	Return cQuery
