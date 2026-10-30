#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLPEECB   ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Monta plano, especialidade, estado, cidade, bairro         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLPEECB()
LOCAL nTp    	:= paramixb[1] 
LOCAL cCodEsp	:= paramixb[2] 
LOCAL cCodEst	:= paramixb[3] 
LOCAL cCodMun	:= paramixb[4] 
LOCAL cSql	 	:= ""
local cNomBAQ	:= RetSQLName("BAQ")
local cFilBAX	:= xFilial("BAX")
local cNomBAX	:= RetSQLName("BAX")
local cFilBB8	:= xFilial("BB8")
local cNomBB8	:= RetSQLName("BB8")
local cCodOpe	:= PlsIntPad()
local aDadBind	:= {}

Do Case
	
	// Especialidades
	Case nTp == 1
		cSql := " SELECT DISTINCT BAQ_CODESP CODIGO, BAQ_DESCRI DESCRICAO "
		cSql += "  FROM " + cNomBAX + "," +  cNomBAQ
		cSql += " WHERE BAX_FILIAL 	= ? "					/*1*/					
		cSql += "   AND BAX_CODINT 	= ? "					/*2*/
		cSql += "   AND BAX_GUIMED	= ? "					/*3*/
		cSql += "   AND BAX_DATBLO 	= ? "					/*4*/
		cSql += "   AND " + cNomBAX + ".D_E_L_E_T_ = ? "	/*5*/
		cSql += "   AND BAQ_FILIAL 	= BAX_FILIAL "
		cSql += "   AND BAQ_CODINT	= BAX_CODINT "
		cSql += "   AND BAQ_CODESP	= BAX_CODESP "
		cSql += "   AND " + cNomBAQ + ".D_E_L_E_T_ = ? "	/*6*/
		csql += "   ORDER BY BAQ_DESCRI"
		
		aDadBind := {/*1*/cFilBAX, /*2*/cCodOpe, /*3*/'1', /*4*/' ', /*5*/' ', /*6*/' '}	
	

	// Estados dos planos x especialidades
	Case nTp == 2
		cSql := " SELECT DISTINCT X5_CHAVE CODIGO, X5_DESCRI DESCRICAO "
		cSql += "   FROM " + cNomBB8 + "," + cNomBAX+ "," + RetSQLName("SX5")
		cSql += "  WHERE BB8_FILIAL = ? " 							/*1*/
		cSql += "    AND BB8_CODINT = ? " 							/*2*/
		cSql += "    AND BB8_DATBLO = ? " 							/*3*/
		cSql += "    AND " + cNomBB8 + ".D_E_L_E_T_ = ? " 			/*4*/
		cSql += "    AND BAX_FILIAL = BB8_FILIAL " 			
		cSql += "    AND BAX_CODINT = BB8_CODINT "
		
		If !Empty(cCodEsp)	
			cSql += "    AND BAX_CODESP = ? "						/*5*/
		EndIf	
		
		cSql += "    AND " + cNomBAX + ".D_E_L_E_T_ = ? "			/*6*/
		cSql += "    AND X5_TABELA 	= ? " 							/*7*/ //'12' "
		cSql += "    AND X5_CHAVE  	= BB8_EST "
		cSql += "    AND " + RetSQLName("SX5") + ".D_E_L_E_T_ = ? " /*8*/
		csql += "    ORDER BY X5_DESCRI "
		
		aDadBind := {/*1*/cFilBB8, /*2*/cCodOpe, /*3*/' ', /*4*/' ', /*5*/cCodEsp, /*6*/' ', /*7*/'12', /*8*/' '}

	
	// Cidades dos estados x planos x especialidades
	Case nTp == 3
		cSql := " SELECT DISTINCT BB8_CODMUN CODIGO ,BB8_MUN DESCRICAO"
		cSql += "   FROM " + cNomBB8 + "," + cNomBAX
		cSql += "  WHERE BB8_FILIAL	= ? "					/*1*/
		cSql += "    AND BB8_CODINT	= ? "					/*2*/					
		cSql += "    AND BB8_DATBLO	= ? "					/*3*/
		
		If !Empty(cCodEst)
			cSql += " AND BB8_EST = ? "						/*4*/
		EndIf	                                          
		
		cSql += "    AND " + cNomBB8 + ".D_E_L_E_T_ = ? "	/*5*/
		cSql += "    AND BAX_FILIAL = BB8_FILIAL "
		cSql += "    AND BAX_CODINT = BB8_CODINT "

		If !Empty(cCodEsp)	
			cSql += " AND BAX_CODESP = ? "					/*6*/
		EndIf	

		cSql += "    AND " + cNomBAX + ".D_E_L_E_T_ = ? "	/*7*/
		csql += "    ORDER BY BB8_MUN "

		aDadBind := {/*1*/cFilBB8, /*2*/cCodOpe, /*3*/' ', /*4*/cCodEst, /*5*/' ', /*6*/cCodEsp, /*7*/' '}

	
	// Bairros das cidades x estados x planos x especialidades
	Case nTp == 4
		cSql := " SELECT DISTINCT BB8_BAIRRO CODIGO ,BB8_BAIRRO DESCRICAO"
		cSql += "   FROM " + cNomBB8 + "," + cNomBAX
		cSql += "  WHERE BB8_FILIAL =  ? "					/*1*/
		cSql += "    AND BB8_CODINT =  ? "					/*2*/
	    cSql += "    AND BB8_DATBLO =  ? "					/*3*/
	    cSql += "    AND BB8_BAIRRO <> ? "					/*4*/

		If !Empty(cCodEst)
			cSql += " AND BB8_EST = ? "						/*5*/
		EndIf	                                          
        
		If !Empty(cCodMun)
			cSql += " AND BB8_CODMUN = ? "					/*6*/
		EndIf
			
		cSql += "    AND " + cNomBB8 + ".D_E_L_E_T_ = ? "	/*7*/
		cSql += "    AND BAX_FILIAL = BB8_FILIAL "
		cSql += "    AND " + cNomBAX + ".D_E_L_E_T_ = ? "	/*8*/
		cSql += "    AND BAX_CODINT = BB8_CODINT "

		If !Empty(cCodEsp)	
			cSql += " AND BAX_CODESP = ? "					/*9*/	
		EndIf	
		cSql += "    ORDER BY BB8_BAIRRO "

		aDadBind := {/*1*/cFilBB8, /*2*/cCodOpe, /*3*/' ', /*4*/' ', /*5*/cCodEst, /*6*/cCodMun, /*7*/' ', /*8*/' ', /*9*/cCodEsp }

EndCase		  

Return( {cSql, aDadBind} )
