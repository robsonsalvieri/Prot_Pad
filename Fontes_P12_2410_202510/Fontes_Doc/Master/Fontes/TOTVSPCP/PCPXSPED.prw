#Include "Protheus.ch"
#Include "TbIconn.ch"
#Include "PCPXSPED.ch"

Static oSD3 := NIL
Static oSB1 := NIL
Static oSC2 := NIL

Static cK235Ali := NIL
Static cK270Ali := NIL
Static cK275Ali := NIL
Static cK292Ali := NIL

/*------------------------------------------------------------------------//
//Programa:	  PCPLayout 
//Autor:	  Ricardo Prandi 
//Data:		  11/09/2018
//Descricao:  Funcao responsavel pela montagem do layout das tabelas
//            tempor·rias do bloco K para o PCP
//Parametros: 1 - cBloco   - Nome do bloco para geracao do Layout
//            2 - aCampos  - Array com os campos que dever„o ser criados
//            3 - aIndices - Array com os Ìndices que dever„o ser criados
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/
Function PCPLayout(cBloco,aCampos,aIndices,cVersSped)

Local nTamFil		:= TamSX3("D1_FILIAL" )[1]
Local nTamDt		:= TamSX3("D1_DTDIGIT")[1]
Local nTamOP		:= TamSX3("D3_OP"     )[1]
Local nTamCod		:= TamSX3("B1_COD"    )[1]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamReg		:= 4
Local aTamQtd		:= {16,If(cVersSped < '013',3,6)}

Do Case
	Case cBloco == "K230"
		//Criacao do Arquivo de Trabalho - BLOCO K230              
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_INI_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"DT_FIN_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_ENC"		,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTDORI"		,"N",aTamQtd[1],aTamQtd[2]}) // Nao integra Bloco K
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
	
	Case cBloco == "K235"
		//Criacao do Arquivo de Trabalho - BLOCO K235             
		aCampos := {}
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"DT_SAIDA"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"COD_INS_SU"	,"C",nTamCod			,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"EMPENHO"		,"C",1					,0}) // Nao integra Bloco K
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
	
	Case cBloco == "K260"
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Criacao do Arquivo de Trabalho - BLOCO K260              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0})
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"DT_SAIDA"	,"D",nTamDt				,0})
		AADD(aCampos,{"QTD_SAIDA"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"DT_RET"		,"D",nTamDt				,0})
		AADD(aCampos,{"QTD_RET"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_OP_OS","COD_ITEM"})
		
	Case cBloco == "K265"
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Criacao do Arquivo de Trabalho - BLOCO K265              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		AADD(aCampos,{"FILIAL"		,"C",nTamFil			,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"			,"C",nTamReg			,0})
		AADD(aCampos,{"COD_OP_OS"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM"	,"C",nTamCod			,0})
		AADD(aCampos,{"QTD_CONS"	,"N",aTamQtd[1],aTamQtd[2]})
		AADD(aCampos,{"QTD_RET"		,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_OP_OS","COD_ITEM"})
		
	Case cBloco == "K290"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K290
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"DT_INI_OP"   ,"D",nTamDt             ,0})
		AADD(aCampos,{"DT_FIN_OP"	,"D",nTamDt				,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP"})
		
	Case cBloco == "K291"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K291
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM "   ,"C",nTamCod            ,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
		
	Case cBloco == "K292"
		//CriaÁ„o do Arquivo de Trabalho - BLOCO K292
		aCampos := {}
		AADD(aCampos,{"FILIAL"      ,"C",nTamFil            ,0}) // Nao integra Bloco K
		AADD(aCampos,{"REG"         ,"C",nTamReg            ,0})
		AADD(aCampos,{"COD_DOC_OP"	,"C",nTamOP				,0}) // Nao integra Bloco K
		AADD(aCampos,{"COD_ITEM "   ,"C",nTamCod            ,0})
		AADD(aCampos,{"QTD"			,"N",aTamQtd[1],aTamQtd[2]})
		// Indices
		AADD(aIndices,{"FILIAL","COD_DOC_OP","COD_ITEM"})
		
EndCase

Return {aCampos,aIndices}

/*------------------------------------------------------------------------//
//Programa:	  REGANTG 
//Autor:	  Ricardo Peixoto
//Data:		  11/10/2018
//Descricao:  Funcao responsavel pelo ajuste do legado SD3
//Parametros: 1 - dDataDe		- Data Inicial da Apuracao   
//			  2 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGANTG(dDataDe,dDataAte)

Local cQuery	 := ""
Local cAliasTmp  := GetNextAlias()
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local lInicializ := .T.
Local dData

//Verifica se È primeira vez
cQuery := " select count (*) REGISTROS from "+RetSqlName("SD3") + " SD3 where SD3.D3_PERBLK <> '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
If (cAliasTmp)->REGISTROS > 0
	lInicializ := .F.
EndIf
(cAliasTmp)->(dbCloseArea())

If lInicializ == .T.
	dData := FirstDate(dDataDe)
	dData := DaySub(dData,1)
	cMes := Month(dData)
	cAno := Year(dData)
	cQuery := " UPDATE "+RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' WHERE D3_EMISSAO <= '" + DtoS(dData) + "' "
	MATExecQry(cQuery)
EndIf

Return

/*------------------------------------------------------------------------//
//Programa:	  REGESTOR 
//Autor:	  Ricardo Peixoto
//Data:		  11/10/2018
//Descricao:  Funcao responsavel pelo ajuste de estornos considerados em sped posterior
//Parametros: 1 - dDataDe		- Data Inicial da Apuracao   
//			  2 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGESTOR(dDataDe,dDataAte)

Local cQuery	 := ""
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local cFuncSubst:= If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX","SUBSTR","SUBSTRING")

cQuery := " UPDATE "+RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
			" WHERE D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +;
			" AND D3_PERBLK <> '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' " +;
			" AND '01/"+STR(cMes,2)+'/'+STR(cAno,4)+"' < '01/'"+MatiConcat()+cFuncSubst+"(D3_PERBLK,1,2)"+MatiConcat()+"'/'"+MatiConcat()+cFuncSubst+"(D3_PERBLK,3,4) "
MATExecQry(cQuery)

Return

/*------------------------------------------------------------------------//
//Programa:	  SETPERBLK 
//Autor:	  Ricardo Peixoto
//Data:		  24/10/2018
//Descricao:  Funcao responsavel pelo ajuste do campo PERBLK
//Parametros: 1 - cPERBLK		- Conte˙do atual D3_PERBLK
//			  2 - iSD3RECNO		- Recno a ser alterado
//			  2 - cMes			- Mes da extraÁ„o
//			  2 - cAno			- Ano da extraÁ„o
//Uso: 		  PCPXSPED
//------------------------------------------------------------------------*/

Function SETPERBLK(cPERBLK, iSD3RECNO, cMes, cAno)
Local cQuery		:= ""

//carrega o periodo em que o registro foi considerado no bloco
If cPERBLK == PADR(Nil,tamSX3('D3_PERBLK')[1])
	//grava D3 como processado
	cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "' WHERE R_E_C_N_O_ = " + STR(iSD3RECNO)
	MATExecQry(cQuery)
ElseIf (CtoD('01/'+STR(cMes,2)+'/'+STR(cAno,4)) - CtoD('01/'+SubStr(cPERBLK,1,2)+'/'+SubStr(cPERBLK,3,4))) < 0
	//grava D3 como processado
	cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "' WHERE R_E_C_N_O_ = " + STR(iSD3RECNO)
	MATExecQry(cQuery)
EndIf

Return


/*------------------------------------------------------------------------//
//Programa:	  REGK230 
//Autor:	  Ricardo Prandi 
//Data:		  10/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K230
//Parametros: 1 - cAliK230		- Alias do arquivo de trabalho do Bloco
//            2 - cAliK235      - Alias do arquivo de trabalho do K235
//            3 - cAli0210      - Alias do arquivo de trabalho do 0210   
//			  4 - dDataDe		- Data Inicial da Apuracao   
//			  5 - dDataAte		- Data Final da Apuracao 
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK230(cAliK230,cAliK235,cAli0210,dDataDe,dDataAte,lRepross)

Local cQuery	 := ""
Local cAliasTmp  := GetNextAlias()
Local cAliasTmp1 := GetNextAlias()
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cSVSFilial := ""
Local cMes       := Month(dDataDe)
Local cAno       := Year(dDataDe)
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local OVALMINIMO

If Type("nRegsto") = "U"
	PRIVATE nRegsto := .F.
EndIf

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVS") + " WHERE VS_FILIAL ='"+xFilial("SVS")+"' AND VS_MESSPED = '" + STR(cMes,2) + "' AND VS_ANOSPED = '" + STR(cAno,4) + "' AND VS_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K230',"PCP K230 - INICIO BUSCA DADOS: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
//GRAVAR AS OPS PROCESSADAS NO PERIODO
ProcLogAtu('PCP K230',"PCP K230 - INICIO INSERT TR2303: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
BKCriaTemp("TR2303")
cQuery := " INSERT INTO TR2303 ( T2303_OP, R_E_C_N_O_ )
cQuery += " SELECT DISTINCT SD3.D3_OP , MAX(SD3.R_E_C_N_O_) "
cQuery += "   FROM " + RetSqlName("SD3") + " SD3 "
cQuery += "  WHERE SD3.D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SD3.D3_OP <> ' ' " 
cQuery += "    AND SD3.D3_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "    AND SD3.D3_ESTORNO <> 'S' " 
cQuery += "  GROUP BY SD3.D3_OP "
MATExecQry(cQuery)
ProcLogAtu('PCP K230',"PCP K230 - FIM INSERT TR2303: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K230',"PCP K230 - INICIO INSERT TR2304: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
BKCriaTemp("TR2304")
cQuery := " INSERT INTO TR2304 ( T2304_QTD, T2304_COD, T2304_OP, R_E_C_N_O_  )
cQuery += " SELECT Sum(CASE " 
cQuery += "            WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( SD3C.D3_QUANT *- 1 ) " 
cQuery += "            WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " 
cQuery += "            ELSE 0 " 
cQuery += "            END) AS QUANT, " 
cQuery += "        SD3C.D3_COD, " 
cQuery += "        SD3C.D3_OP, "
cQuery += "        MAX(SD3C.R_E_C_N_O_) "
cQuery += "   FROM " + RetSqlName("SD3") + " SD3C, " 
cQuery += "        TR2303, "
cQuery += "        " + RetSqlName("SC2") + " SC2, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " + RetSqlName("SB1") + " SB1_OP " 
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ1 " +; 
	                 " ON SBZ1.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ1.BZ_COD     = SB1_OP.B1_COD " +; 
	                " AND SBZ1.D_E_L_E_T_ = ' ', "
	
	cQuery += " " + RetSqlName("SB1") + " SB1_COMP "
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ2 " +; 
	                 " ON SBZ2.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ2.BZ_COD     = SB1_COMP.B1_COD " +; 
	                " AND SBZ2.D_E_L_E_T_ = ' ' "

Else
	cQuery += "        " + RetSqlName("SB1") + " SB1_OP, " 
	cQuery += "        " + RetSqlName("SB1") + " SB1_COMP "
EndIf

cQuery += "	 WHERE SD3C.D3_FILIAL    = '" + xFilial('SD3') + "' " 
cQuery += "    AND SD3C.D_E_L_E_T_   = ' ' " 
cQuery += "    AND TR2303.T2303_OP   = SD3C.D3_OP "
cQuery += "    AND SC2.C2_FILIAL     = '" + xFilial('SC2') + "' " 
cQuery += "    AND SC2.D_E_L_E_T_    = ' ' " 
cQuery += "	   AND SC2.C2_OP         = SD3C.D3_OP "
cQuery += "    AND SC2.C2_ITEM       <> 'OS' "
cQuery += "    AND SC2.C2_TPPR       IN ( 'I', ' ' ) " 
cQuery += "    AND SC2.C2_PRODUTO    <> SD3C.D3_COD " 
cQuery += "    AND SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_OP.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " 

//cQuery += "	   AND SB1_OP.B1_TIPO    NOT IN (" + cTipo05 + ") "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ1.BZ_TIPO,SB1_OP.B1_TIPO) "
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "NOT IN  (" + cTipo05 + ") "


cQuery += "    AND SB1_COMP.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_COMP.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SB1_COMP.B1_COD     = SD3C.D3_COD " 

//cQuery += "	   AND SB1_COMP.B1_TIPO    NOT IN (" + cTipo05 + ") " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ2.BZ_TIPO,SB1_COMP.B1_TIPO) "
Else
	cQuery += " AND SB1_COMP.B1_TIPO "
EndIf
//cQuery += "NOT IN  (" + cTipo05 + ") "

cQuery += "NOT IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo05+","+cTipo10+")

//K235 considera os tipos - 00, 01, 02, 03, 04, 05 e 10.
//K291 considera os tipo - 03 e 04

cQuery += "  GROUP BY SD3C.D3_OP, " 
cQuery += "           SD3C.D3_COD " 

MATExecQry(cQuery)
ProcLogAtu('PCP K230',"PCP K230 - FIM INSERT TR2304: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K230',"PCP K230 - INICIO INSERT TR2305: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
BKCriaTemp("TR2305")
cQuery := " INSERT INTO TR2305 (T2305_OP, "
cQuery += "                     T2305_QTD, "
cQuery += "                     R_E_C_N_O_ ) "
cQuery += " SELECT TR2304.T2304_OP, Min(TR2304.T2304_QTD) , MAX(TR2304.R_E_C_N_O_)  " 
cQuery += "   FROM TR2304 "  
cQuery += "  GROUP BY TR2304.T2304_OP "  
MATExecQry(cQuery)
ProcLogAtu('PCP K230',"PCP K230 - FIM INSERT TR2305: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K230',"PCP K230 - INICIO INSERT 2 TR2305: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
//BKCriaTemp("TR2305")
cQuery := " INSERT INTO TR2305 (T2305_OP, "
cQuery += "                     T2305_QTD, "
cQuery += "                     R_E_C_N_O_ ) "
cQuery += " SELECT T2303_OP, 0 , R_E_C_N_O_ "
cQuery += "   FROM TR2303 "
cQuery += "  WHERE NOT EXISTS ( SELECT 1  " 
cQuery += "                       FROM TR2304 "  
cQuery += "                      WHERE T2304_OP = T2303_OP)
MATExecQry(cQuery)
ProcLogAtu('PCP K230',"PCP K230 - FIM INSERT 2 TR2305: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K230',"PCP K230 - INICIO INSERT TR2300: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
BKCriaTemp("TR2300")
cQuery := " INSERT INTO TR2300 (T2300_QTD, "
cQuery += "                     T2300_OP, "
cQuery += "                     T2300_COD, "
cQuery += "                     T2300_FIL, "
cQuery += "                     T2300_PBLK, "
cQuery += "                     T2300_RECN, "
cQuery += "                     T2300_EST, "
cQuery += "                     T2300_TIPO, "
cQuery += "                     T2300_DTIN, "
cQuery += "                     T2300_DTFI, "
cQuery += "                     T2300_QTOR, "
cQuery += "                     T2300_VLMI, "
cQuery += "                     R_E_C_N_O_ ) "
cQuery += " SELECT Sum(SD3.D3_QUANT), " 
cQuery += "        SD3.D3_OP, " 
cQuery += "        SD3.D3_COD, " 
cQuery += "        SD3.D3_FILIAL, " 
cQuery += "        SD3.D3_PERBLK, " 
cQuery += "        SD3.R_E_C_N_O_ , " 
cQuery += "        SD3.D3_ESTORNO, " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " "      + MatIsNull() + "(SBZ1.BZ_TIPO,SB1.B1_TIPO), "
Else
	cQuery += "        SB1.B1_TIPO, " 
EndIf

cQuery += "        SC2.C2_DATPRI AS DTINI, " 
cQuery += "        SC2.C2_DATRF AS DTFIM, " 
cQuery += "        SC2.C2_QUANT AS QTDORI, " 
cQuery += "        ORDEM2.VALMINIMO, "
cQuery += "        SD3.R_E_C_N_O_  "  
cQuery += "   FROM " + RetSqlName("SD3") + " SD3 "
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 " 
cQuery += "     ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1.B1_COD     = SD3.D3_COD "
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "   LEFT JOIN " + RetSqlName("SBZ") + " SBZ1 " 
	cQuery += "     ON SBZ1.BZ_FILIAL  = '" + xFilial('SBZ') + "' " 
	cQuery += "    AND SBZ1.BZ_COD     = SB1.B1_COD " 
	cQuery += "    AND SBZ1.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "   JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "  	ON SD3.D3_OP      = SC2.C2_OP "				
cQuery += "    AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " 
cQuery += "    AND SC2.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SC2.C2_ITEM    <> 'OS' " 
cQuery += "    AND SC2.C2_PRODUTO = SD3.D3_COD " 
cQuery += "    AND SC2.C2_TPPR    IN ( 'I', ' ' ) "
cQuery += "   JOIN (SELECT TR2305.T2305_OP, T2305_QTD AS VALMINIMO " 
cQuery += "           FROM TR2305 ) ORDEM2 " 
cQuery += "     ON ORDEM2.T2305_OP = SD3.D3_OP " 
cQuery += "  WHERE SD3.D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SD3.D3_OP <> ' ' " 
cQuery += "    AND SD3.D3_CF IN ( 'PR0', 'PR1' ) " 
cQuery += "    AND SD3.D3_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "    AND SB1.B1_CCCUSTO = ' ' " 

//cQuery += "    AND SB1.B1_TIPO IN (" + cTipo03 + "," + cTipo04 + ") " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ1.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf
cQuery += " IN  (" + cTipo03 + "," + cTipo04 + ") "

cQuery += "     AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "     AND SD3.D3_ESTORNO <> 'S' " 
cQuery += "   GROUP BY SD3.D3_OP, " 
cQuery += "            SD3.D3_COD, " 
cQuery += "            SD3.D3_FILIAL, " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " + MatIsNull() + "(SBZ1.BZ_TIPO,SB1.B1_TIPO),"
Else
	cQuery += " SB1.B1_TIPO, " 
EndIf

cQuery += "            SC2.C2_DATPRI, " 
cQuery += "            SC2.C2_DATRF, " 
cQuery += "            SC2.C2_QUANT, " 
cQuery += "            SD3.D3_PERBLK, " 
cQuery += "            SD3.R_E_C_N_O_, " 
cQuery += "            SD3.D3_ESTORNO, " 
cQuery += "            ORDEM2.VALMINIMO, "
cQuery += "            SD3.R_E_C_N_O_ " 
MATExecQry(cQuery)
ProcLogAtu('PCP K230',"PCP K230 - FIM INSERT TR2300: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

CrgDtIni("1")

ProcLogAtu('PCP K230',"PCP K230 - INICIO BUSCA DADOS TR2300: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
cQuery := " SELECT T2300_QTD, "
cQuery += "        T2300_OP, "
cQuery += "        T2300_COD, "
cQuery += "        T2300_FIL, "
cQuery += "        T2300_PBLK, "
cQuery += "        T2300_RECN, "
cQuery += "        T2300_EST, "
cQuery += "        T2300_TIPO, "
cQuery += "        T2300_DTIN, "
cQuery += "        T2300_DTFI, "
cQuery += "        T2300_QTOR, "
cQuery += "        T2300_VLMI "
cQuery += "   FROM TR2300 "
cQuery += "  ORDER BY T2300_OP "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

ProcLogAtu('PCP K230',"PCP K230 - DURANTE BUSCA DADOS TR2300: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

cSVSFilial := xFilial("SVS")

While !(cAliasTmp)->(Eof())

	OVALMINIMO := (cAliasTmp)->T2300_VLMI
	If OVALMINIMO != Nil .And. OVALMINIMO < 0
		//verifica se tem 235
		dbSelectArea("SVT")
		dbSetOrder(2)
		dbSeek(xFilial("SVT")+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T2300_OP)
		While !Eof() .And. VT_OP == (cAliasTmp)->T2300_OP
			OVALMINIMO := 1
			SVT->(dbSkip())
		End
	EndIf

	If OVALMINIMO != Nil .And. OVALMINIMO < 0
		(cAliasTmp)->(dbSkip())
	Else	
		SETPERBLK((cAliasTmp)->T2300_PBLK, (cAliasTmp)->T2300_RECN, cMes, cAno)
			
		//grava tabela fÌsica para guardar histÛrico
		SVS->(dbSetOrder(2))
		If !SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T2300_OP+(cAliasTmp)->T2300_COD+ cChamada ))
			//************************************************************************
			// Bloco K230
			//************************************************************************
			Reclock("SVS",.T.)
			SVS->VS_PRGORI  := cChamada
			SVS->VS_FILIAL  := cSVSFilial
			SVS->VS_MESSPED := STR(cMes,2)
			SVS->VS_ANOSPED := STR(cAno,4)
			SVS->VS_REG     := "K230"
			SVS->VS_DTINIOP := GetDtIni((cAliasTmp)->T2300_OP) //GetIniProd((cAliasTmp)->T2300_OP)
			SVS->VS_DTFIMOP := If(StoD((cAliasTmp)->T2300_DTFI) > dDataAte,StoD(""),StoD((cAliasTmp)->T2300_DTFI))
			SVS->VS_OP      := (cAliasTmp)->T2300_OP
			SVS->VS_PRODUTO := (cAliasTmp)->T2300_COD
			SVS->VS_QTDENC  := (cAliasTmp)->T2300_QTD
			SVS->VS_QTDORI  := (cAliasTmp)->T2300_QTOR
			SVS->(MsUnlock())
			(cAliasTmp)->(dbSkip())			
		Else
			//************************************************************************
			// Bloco K230 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T2300_OP+(cAliasTmp)->T2300_COD+ cChamada ))
	    	While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4) .And. SVS->VS_OP == (cAliasTmp)->T2300_OP .And. SVS->VS_PRODUTO == (cAliasTmp)->T2300_COD .And. SVS->VS_PRGORI == cChamada
	    		RecLock("SVS",.F.,.T.)
	    		SVS->VS_QTDENC += (cAliasTmp)->T2300_QTD
	    		SVS->(MsUnlock())
				SVS->(dbSkip())
	    	EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
	EndIf		
EndDo
(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K230',"PCP K230 - FIM BUSCA DADOS TR2300: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K230',"PCP K230 - INICIO CARREGA TABELA TR2301: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR2301")

//Inicia a Gravacao das Producoes Zeradas, nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
cQuery := "  INSERT INTO TR2301 (  T2301_OP, "
cQuery += "                        T2301_DTRF, "
cQuery += "                        T2301_COD, "
cQuery += "                        T2301_QTD, "	
cQuery += "                        T2301_TIPO, "	
cQuery += "                        R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT SVT.VT_OP, "
cQuery += "        SC2.C2_DATRF, "
cQuery += "        SC2.C2_PRODUTO, "
cQuery += "        SC2.C2_QUANT, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO), "
Else
	cQuery += " SB1.B1_TIPO, " 
EndIf

cQuery += "        SC2.R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("SVT") + " SVT "
cQuery += " JOIN " + RetSqlName("SC2") + " SC2 " 
cQuery += "   ON SVT.VT_FILIAL = '" + xFilial("SVT") + "' " 
cQuery += "  AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' " 
cQuery += "  AND SC2.D_E_L_E_T_ = ' ' " 			
cQuery += "  AND SVT.VT_OP      = SC2.C2_OP "         	 
cQuery += "  AND SVT.VT_MESSPED = '" + STR(cMes,2) + "' "
cQuery += "  AND SVT.VT_ANOSPED = '" + STR(cAno,4) + "' "
cQuery += "  AND NOT EXISTS (SELECT 1 " 
cQuery += " 				   FROM " + RetSqlName("SVS") + " SVS " 
cQuery += " 				  WHERE SVS.VS_FILIAL = '" + xFilial("SVS") + "' " 
cQuery += " 					AND SVT.VT_FILIAL  = '" + xFilial("SVT") + "' " 
cQuery += " 					AND SVS.VS_OP      = SVT.VT_OP " 
cQuery += "                     AND SVS.VS_MESSPED = SVT.VT_MESSPED " 
cQuery += "                     AND SVS.VS_ANOSPED = SVT.VT_ANOSPED ) "
cQuery += " JOIN "+RetSqlName("SB1") + " SB1 " 
cQuery += "   ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "  AND SB1.B1_COD     = SC2.C2_PRODUTO " 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
      
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += 	" LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
			  	" ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
				" AND SBZ.BZ_COD     = SB1.B1_COD " +; 
			  	" AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE SVT.D_E_L_E_T_ = ' ' "

MATExecQry(cQuery)

ProcLogAtu('PCP K230',"PCP K230 - FIM CARREGA TABELA TR2301: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K230',"PCP K230 - INICIO EXCLUS√O TABELA SVT x TR2301: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR2302")

cQuery := " INSERT INTO TR2302 ( T2302_OP,  R_E_C_N_O_ ) "
cQuery += " SELECT DISTINCT VT_OP, R_E_C_N_O_ "
cQuery += "   FROM " + RetSqlName("SVT") + " SVT "
cQuery += "  WHERE VT_FILIAL  = '" + xFilial("SVT") + "' "
cQuery += "    AND VT_MESSPED = '" + STR(cMes,2) + "' "
cQuery += "    AND VT_ANOSPED = '" + STR(cAno,4) + "' "
cQuery += "    AND VT_PRGORI  = '" + cChamada + "' "
cQuery += "    AND EXISTS ( SELECT 1 "
cQuery += "                   FROM TR2301 "
cQuery += "                  WHERE T2301_OP = VT_OP " 
cQuery += "                    AND T2301_TIPO NOT IN ( " + cTipo03 + " ," + cTipo04 + " ) ) "
MATExecQry(cQuery)

cQuery := " DELETE FROM  " + RetSqlName("SVT") 
cQuery += "  WHERE EXISTS ( SELECT 1 "
cQuery += "                   FROM TR2302 "
cQuery += "                  WHERE T2302_OP = VT_OP ) "
MATExecQry(cQuery)

ProcLogAtu('PCP K230',"PCP K230 - DURANTE EXCLUS√O TABELA SVT x TR2301: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

cQuery := " SELECT T2302_OP "
cQuery += "   FROM TR2302 "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp1,.T.,.T.)

While !(cAliasTmp1)->(Eof())
	If (cAliK235)->(MsSeek(cSVSFilial+(cAliasTmp1)->T2302_OP)) // FILIAL+COD_DOC_OP+COD_ITEM
		While (cAliK235)->(FILIAL+COD_DOC_OP) == cSVSFilial+(cAliasTmp1)->T2302_OP
			
			Reclock(cAliK235,.F.)
			DbDelete()
			(cAliK235)->(MsUnLock())
			(cAliK235)->(dbSkip())

			cTabD3 := RetSqlName("SD3")

			cUpdateD3 := " UPDATE " + cTabD3 + " " 
			cUpdateD3 += "    SET D3_PERBLK = ' ' "
			cUpdateD3 += "  WHERE D3_FILIAL = '" + xFilial('SD3') + "' " 
			cUpdateD3 += "    AND D3_OP = '" +(cAliasTmp1)->T2302_OP+ "' "
			cUpdateD3 += "    AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
			
			MATExecQry(cUpdateD3)	
		EndDo
	EndIf
	(cAliasTmp1)->(dbSkip())
EndDo

(cAliasTmp1)->(dbCloseArea())


ProcLogAtu('PCP K230',"PCP K230 - FIM EXCLUS√O TABELA SVT x TR2301: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

CrgDtIni("2")

ProcLogAtu('PCP K230',"PCP K230 - INICIO PRODUCOES ZERADAS: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

cQuery := " SELECT T2301_OP, "
cQuery += "        T2301_DTRF, "
cQuery += "        T2301_COD, "
cQuery += "        T2301_QTD, "	
cQuery += "        T2301_TIPO "
cQuery += "   FROM TR2301 "
cQuery += "  WHERE NOT EXISTS ( SELECT 1 "
cQuery += "                       FROM TR2302 "
cQuery += "                      WHERE T2302_OP = T2301_OP ) "
cQuery += "  ORDER BY T2301_OP "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

ProcLogAtu('PCP K230',"PCP K230 - DURANTE PRODUCOES ZERADAS: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

While !(cAliasTmp)->(Eof())

	//grava tabela fÌsica para guardar histÛrico
	SVS->(dbSetOrder(2))
	If !SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T2301_OP+(cAliasTmp)->T2301_COD+ cChamada ))

		//*************************************************************************************
		// Bloco K230 - nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
		//*************************************************************************************
		RecLock("SVS",.T.)
		SVS->VS_PRGORI  := cChamada
		SVS->VS_FILIAL  := cSVSFilial
		SVS->VS_MESSPED := STR(cMes,2)
		SVS->VS_ANOSPED := STR(cAno,4)
		SVS->VS_REG     := "K230"
		SVS->VS_DTINIOP := GetDtIni((cAliasTmp)->T2301_OP)  //GetIniProd((cAliasTmp)->T2301_OP)
		SVS->VS_DTFIMOP := If(STOD((cAliasTmp)->T2301_DTRF) > dDataAte, StoD(""), STOD((cAliasTmp)->T2301_DTRF))
		SVS->VS_OP      := (cAliasTmp)->T2301_OP
		SVS->VS_PRODUTO := (cAliasTmp)->T2301_COD
		SVS->VS_QTDENC  := 0
		SVS->VS_QTDORI  := (cAliasTmp)->T2301_QTD
		SVS->(MsUnlock())				
	EndIf
	(cAliasTmp)->(dbSkip())	

	/*
	Else
		//************************************************************************
		// Bloco K230 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************	
		SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T2301_OP+(cAliasTmp)->T2301_COD+ cChamada ))
	    While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4) .And. SVS->VS_OP == (cAliasTmp)->T2301_OP .And. SVS->VS_PRODUTO == (cAliasTmp)->T2301_COD .And. SVS->VS_PRGORI == cChamada
	    	RecLock("SVS",.F.,.T.)
	    	SVS->VS_QTDENC += (cAliasTmp)->T2301_QTD
	    	SVS->(MsUnlock())
			SVS->(dbSkip())
	    EndDo
		(cAliasTmp)->(dbSkip())
	*/	
EndDo
(cAliasTmp)->(dbCloseArea())
ProcLogAtu('PCP K230',"PCP K230 - FIM PRODUCOES ZERADAS: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
ProcLogAtu('PCP K230',"PCP K230 - INICIO TEMP SPED: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
SVS->(dbSetOrder(2))
SVS->(dbSeek(cSVSFilial+STR(cMes,2)+STR(cAno,4)))
While SVS->(!Eof()) .And. SVS->VS_FILIAL == cSVSFilial .And. SVS->VS_MESSPED == STR(cMes,2) .And. SVS->VS_ANOSPED == STR(cAno,4)
	If SVS->VS_PRGORI == cChamada
		Reclock(cAliK230,.T.)
		(cAliK230)->FILIAL			:= cSVSFilial
		(cAliK230)->REG				:= "K230"
		(cAliK230)->DT_INI_OP		:= SVS->VS_DTINIOP
		(cAliK230)->DT_FIN_OP		:= SVS->VS_DTFIMOP
		(cAliK230)->COD_DOC_OP		:= SVS->VS_OP
		(cAliK230)->COD_ITEM		:= SVS->VS_PRODUTO
		(cAliK230)->QTD_ENC			:= SVS->VS_QTDENC
		(cAliK230)->QTDORI			:= SVS->VS_QTDORI
		(cAliK230)->(MsUnLock())
		nRegsto++
	EndIf
	SVS->(dbSkip())
EndDo
MsUnlock()
ProcLogAtu('PCP K230',"PCP K230 - FIM TEMP SPED: " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K230',"PCP K230 - INICIO OPS ENCERRADAS SEM MVTO " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
//gravaÁ„o de OPs encerradas no perÌodo, mas sem movimentaÁıes no mesmo.
cQuery := " SELECT VS_OP, "
cQuery += "        VS_PRODUTO, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) TIPO, "
Else
	cQuery += "SB1.B1_TIPO TIPO, "
EndIf

cQuery += "        C2_DATRF, "
cQuery += "        MAX(SVS.R_E_C_N_O_)  AS REQSVS "
cQuery += "   FROM " + RetSqlName("SVS") + " SVS " 
cQuery += "   LEFT JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "     ON C2_OP = VS_OP " 
cQuery += "    AND SC2.D_E_L_E_T_ = ' ' " 
cQuery += "    AND C2_FILIAL      = VS_FILIAL "

cQuery += " JOIN "+RetSqlName("SB1") + " SB1 " 
cQuery += "   ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "  AND SB1.B1_COD     = SC2.C2_PRODUTO " 
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
      
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += 	" LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
			  	" ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
				" AND SBZ.BZ_COD     = SC2.C2_PRODUTO " +; 
			  	" AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  WHERE VS_DTFIMOP <> C2_DATRF "
cQuery += "    AND VS_DTFIMOP = '        ' " 
cQuery += "    AND VS_FILIAL  = '" + xFilial("SVS") + "' "
cQuery += "    AND C2_DATRF BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "    AND ( SELECT COUNT(*) "
cQuery += "            FROM " + RetSqlName("SVS") + " SVS2 "
cQuery += "           WHERE VS_FILIAL = '" + xFilial("SVS") + "' "
cQuery += "             AND SVS2.VS_OP = SVS.VS_OP "
cQuery += "             AND SVS2.VS_DTFIMOP <> '        ' ) = 0 " 
cQuery += " GROUP BY VS_OP, VS_PRODUTO, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) , "
Else
	cQuery += "SB1.B1_TIPO , "
EndIf
cQuery += "        C2_DATRF "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

ProcLogAtu('PCP K230',"PCP K230 - DURANTE OPS ENCERRADAS SEM MVTO " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

SVS->(dbSetOrder(2))
While !(cAliasTmp)->(Eof())

	If (cAliasTmp)->TIPO $ cTipo05
		(cAliasTmp)->(dbSkip())
		LOOP
	EndIf

	//possui encerramento em periodo posterior ao sped. n„o gerar pendencia
	If STOD((cAliasTmp)->C2_DATRF) <= dDataAte

		SVS->(dbGoTo((cAliasTmp)->REQSVS))
		
		//grava temporaria para arquivo sped
		Reclock(cAliK230,.T.)
		(cAliK230)->FILIAL			:= cSVSFilial
		(cAliK230)->REG				:= "K230"
		(cAliK230)->DT_INI_OP		:= SVS->VS_DTINIOP
		(cAliK230)->DT_FIN_OP		:= STOD((cAliasTmp)->C2_DATRF)
		(cAliK230)->COD_DOC_OP		:= SVS->VS_OP
		(cAliK230)->COD_ITEM		:= SVS->VS_PRODUTO
		(cAliK230)->QTD_ENC			:= 0
		(cAliK230)->QTDORI			:= SVS->VS_QTDORI
		
		//clonar com qtd zerada (cAliK230)->QTD_ENC
		RecLock("SVS",.T.)
		SVS->VS_PRGORI  := cChamada
		SVS->VS_FILIAL  := cSVSFilial
		SVS->VS_MESSPED := STR(cMes,2)
		SVS->VS_ANOSPED := STR(cAno,4)
		SVS->VS_REG     := "K230"
		SVS->VS_DTINIOP := (cAliK230)->DT_INI_OP
		SVS->VS_DTFIMOP := (cAliK230)->DT_FIN_OP
		SVS->VS_OP      := (cAliK230)->COD_DOC_OP
		SVS->VS_PRODUTO := (cAliK230)->COD_ITEM
		SVS->VS_QTDENC  := (cAliK230)->QTD_ENC
		SVS->VS_QTDORI  := (cAliK230)->QTDORI
		SVS->(MsUnlock())
		(cAliK230)->(MsUnLock())
		nRegsto++
	EndIf	
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K230',"PCP K230 - FIM OPS ENCERRADAS SEM MVTO " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K230',"PCP K230 - INICIO K0210 " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//Gravacao do Registro 0210 com base nas producoes do Registro K230
If !lEstMov
	(cAliK230)->(dbGoTop())
	While !(cAliK230)->(Eof())
		REG0210(cAli0210,(cAliK230)->COD_ITEM,(cAliK230)->DT_INI_OP,(cAliK230)->DT_INI_OP,(cAliK230)->COD_DOC_OP,.F.,lRePross)
		(cAliK230)->(dbSkip())
	EndDo
EndIf

ProcLogAtu('PCP K230',"PCP K230 - FIM K0210 " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return

/*/{Protheus.doc} Busca Data de Inicio da OP
	Busca data de inicio da OP para o K230 - performance
	@type  Static Function
	@author Michele Girardi
	@since 24/04/2023
	@version 1.0
	@param cOP
/*/

Static Function GetDtIni(cOP)
Local cQuery     := ""
Local dRet 		 := StoD("")
Local cAliasTmp	 := CriaTrab(Nil,.F.)

Static cCacheDt

oPrepDtIn := cCacheDt

If oPrepDtIn == Nil
	cQuery := " SELECT T230D_DTIN "
	cQuery += "   FROM TR230D "
	cQuery += "  WHERE T230D_OP = ? "

	cQuery    := ChangeQuery(cQuery)
	oPrepDtIn := FWPreparedStatement():New(cQuery) //Construtor da carga.
	cCacheDt  := oPrepDtIn
EndIf

oPrepDtIn:SetString(01, cOP)
cQuery := oPrepDtIn:GetFixQuery() //Retorna a query com os par‚metros j· tratados e substituÌdos.
cAliasTmp := MPSysOpenQuery(cQuery, cAliasTmp) //Abre um alias com a query informada.

If !(cAliasTmp)->(Eof())
	dRet := StoD((cAliasTmp)->T230D_DTIN)
EndIf

(cAliasTmp)->(dbCloseArea())

Return dRet

/*/{Protheus.doc} Carrega data de inicio
	Carrega data de inicio da OP para o K230 - performance
	@type  Static Function
	@author Michele Girardi
	@since 24/04/2023
	@version 1.0
	@param cTipo
/*/

Static Function CrgDtIni(cTipo)
Local cQuery := ""

BKCriaTemp("TR230D")

If cTipo == '1'
	cQuery := " INSERT INTO TR230D (T230D_DTIN, T230D_OP, R_E_C_N_O_) "
	cQuery += " SELECT MIN(D3_EMISSAO) DTINICIO, SD3.D3_OP, MAX(SD3.R_E_C_N_O_) "
	cQuery += "   FROM " + RetSqlName("SD3") + " SD3, "
	cQuery += "        TR2300 "
	cQuery += "  WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
	cQuery += "    AND SD3.D3_ESTORNO = ' ' "
	cQuery += "    AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "    AND T2300_OP = SD3.D3_OP "
	cQuery += "  GROUP BY SD3.D3_OP" 
Else
	cQuery := " INSERT INTO TR230D (T230D_DTIN, T230D_OP, R_E_C_N_O_) "
	cQuery += " SELECT MIN(D3_EMISSAO) DTINICIO, SD3.D3_OP, MAX(SD3.R_E_C_N_O_) "
	cQuery += "   FROM " + RetSqlName("SD3") + " SD3, "
	cQuery += "        TR2301 "
	cQuery += "  WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
	cQuery += "    AND SD3.D3_ESTORNO = ' ' "
	cQuery += "    AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "    AND T2301_OP = SD3.D3_OP "
	cQuery += "  GROUP BY SD3.D3_OP"
EndIf

MATExecQry(cQuery)

Return Nil

/*/{Protheus.doc} BKCriaTemp
	CriaÁ„o de tabelas para processamento do Bloco K
	@type  Static Function
	@author Michele Girardi
	@since 18/04/2023
	@version 1.0
	@param cId
/*/

Static Function BKCriaTemp(cId)

Local aFields := {}
Local cCampo  := ' '
Local cNCampo := ' '

//REGISTRO K235
If cId == 'TR235S1'
    cNCampo := 'TS1_QUANT'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_COD'
    cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_OP'
    cCampo  := 'D3_OP'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_EMIS'
    cCampo  := 'D3_EMISSAO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_FILIAL'
    cCampo  := 'D3_FILIAL'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_PERBLK'
    cCampo  := 'D3_PERBLK'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})

    cNCampo := 'TS1_ESTORN'
    cCampo  := 'D3_ESTORNO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_TRT'
    cCampo  := 'D3_TRT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS1_PRDORG'
    cCampo  := 'D4_PRDORG'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})	
EndIf

If cId == 'TR235S2'
	cNCampo := 'TS2_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS2_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235S3'
	cNCampo := 'TS3_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS3_PROD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS3_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235S4'
	cNCampo := 'TS4_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS4_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235S5'
	cNCampo := 'TS5_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})

	cNCampo := 'TS5_QUANT'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_EMIS'
    cCampo  := 'D3_EMISSAO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_FILIAL'
    cCampo  := 'D3_FILIAL'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

    cNCampo := 'TS5_PERBLK'
    cCampo  := 'D3_PERBLK'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_ESTORN'
    cCampo  := 'D3_ESTORNO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_TRT'
    cCampo  := 'D3_TRT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TS5_PRDORG'
    cCampo  := 'D4_PRDORG'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})	
EndIf  

If cId == 'TR235CP'
	cNCampo := 'TCP_QUANT'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TCP_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TCP_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TCP_EMIS'
    cCampo  := 'D3_EMISSAO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TCP_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TCP_PRDORG'
    cCampo  := 'D4_PRDORG'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})	

	cNCampo := 'TCP_MES'
    aAdd(aFields, {cNCampo,'C',02,0})

	cNCampo := 'TCP_ANO'
    aAdd(aFields, {cNCampo,'C',04,0})
EndIf  

If cId == 'TR235U1' 
	cNCampo := 'TU1_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})
	
	cNCampo := 'TU1_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU1_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU1_EMIS'
    cCampo  := 'D3_EMISSAO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235U2' 
	cNCampo := 'TU2_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU2_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235U3' 
	cNCampo := 'TU3_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU3_PROD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU3_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235U4' 
	cNCampo := 'TU4_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU4_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235U5' 
	cNCampo := 'TU5_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})

	cNCampo := 'TU5_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU5_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'TU5_EMIS'
    cCampo  := 'D3_EMISSAO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR235U6'
	cNCampo := 'TU6_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})
EndIf

If cId == 'TR235CO'
	cNCampo := 'TUCO_OP'
	cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

//REGISTRO K230
If cId == 'TR2300'
	cNCampo := 'T2300_QTD'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_FIL'
    cCampo  := 'D3_FILIAL'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_PBLK'
    cCampo  := 'D3_PERBLK'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_RECN'
    aAdd(aFields, {cNCampo,'N',12,0})

	cNCampo := 'T2300_EST'
    cCampo  := 'D3_ESTORNO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_TIPO'
    cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_DTIN'
    cCampo  := 'C2_DATPRI'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_DTFI'
    cCampo  := 'C2_DATRF'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_QTOR'
    cCampo  := 'C2_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2300_VLMI'
    cCampo  := 'C2_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR2301'
	cNCampo := 'T2301_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2301_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2301_QTD'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2301_TIPO'
	cCampo  := 'B1_TIPO'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2301_DTRF'
	cCampo  := 'C2_DATRF'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR2302'
	cNCampo := 'T2302_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR230D'
	cNCampo := 'T230D_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T230D_DTIN'
	cCampo  := 'C2_DATRF'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR2303'
	cNCampo := 'T2303_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR2304'
	cNCampo := 'T2304_QTD'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2304_COD'
	cCampo  := 'D3_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2304_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})
EndIf

If cId == 'TR2305'
	cNCampo := 'T2305_OP'
    cCampo  := 'D3_OP'
	aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'T2305_QTD'
    cCampo  := 'D3_QUANT'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})	
EndIf

//Deleta Tabela no Banco, caso exista
lOk := TCDelFile(cId)

//Cria Tabela no Banco
dbCreate(cId, aFields, "TOPCONN")

Return 

/*------------------------------------------------------------------------//
//Programa:	  REGK235 
//Autor:	  Ricardo Prandi 
//Data:		  11/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K235
//Parametros: 1 - cAliK235      - Alias do arquivo de trabalho do K235
//            2 - dDataDe		    - Data Inicial da Apuracao   
//			      3 - dDataAte	   	- Data Final da Apuracao
//            4 - cAliK270      - Alias do arquivo de trabalho do K270
//            5 - cAliK275      - Alias do arquivo de trabalho do K275
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK235(cAliK235,dDataDe,dDataAte,cAliK270,cAliK275,lRepross)

Local cAliasTmp  := GetNextAlias()
Local cAliasTot  := GetNextAlias()
Local cAno       := Year(dDataDe)
Local cChamada   := If (lRepross, "SPEDFISCAL", "MATR241 ")
Local cDadosProd := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes       := Month(dDataDe)
Local cQuery     := ""
Local cRecD3     := ""
Local cSD4Filial := ""
Local cSVTFilial := ""
Local cTabD3     := ""
Local cUpdateD3  := ""
Local nTotal     := 0

If Type("nRegsto") = "U"
	PRIVATE nRegsto := .F.
EndIf

cK235Ali := cAliK235

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

ProcLogAtu('PCP K235',"PCP K235 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVT") + " WHERE VT_FILIAL ='"+xFilial("SVT")+"' AND VT_MESSPED = '" + STR(cMes,2) + "' AND VT_ANOSPED = '" + STR(cAno,4) + "' AND VT_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Busca os dados para geraÁ„o do K235
ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235S1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235S1") 

cQuery := "  INSERT INTO TR235S1 ( TS1_QUANT, "
cQuery += "                        TS1_COD, "
cQuery += "                        TS1_OP, "
cQuery += "                        TS1_EMIS, "
cQuery += "                        TS1_FILIAL, "
cQuery += "                        TS1_PERBLK, "
cQuery += "                        TS1_RECNO, "
cQuery += "                        TS1_ESTORN, "
cQuery += "                        TS1_TRT, "
cQuery += "                        TS1_PRDORG, "	
cQuery += "                        R_E_C_N_O_ )"	
cQuery += "  SELECT SUM(CASE "
cQuery += "             WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT *- 1 ) "
cQuery += "             WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) "
cQuery += "             ELSE 0 END) QUANT, "			
cQuery += "     	    SD3.D3_COD, "
cQuery += " 	    SD3.D3_OP, "
cQuery += " 	    Max(D3_EMISSAO) D3_EMISSAO, "
cQuery += "         SD3.D3_FILIAL, "
cQuery += "         SD3.D3_PERBLK, "
cQuery += "         SD3.R_E_C_N_O_  SD3RECNO, "
cQuery += "         SD3.D3_ESTORNO, "
cQuery += "         SD3.D3_TRT, "
cQuery += "         ' ', "
cQuery += "         SD3.R_E_C_N_O_  "
cQuery += "    FROM " + RetSqlName("SD3") + " SD3 " 
cQuery += "   WHERE SD3.D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += "     AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "     AND SD3.D3_OP <> ' ' "
cQuery += "     AND ( SD3.D3_CF LIKE ( 'RE%' ) OR SD3.D3_CF LIKE ( 'DE%' ) ) "
cQuery += "     AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
cQuery += "     AND SD3.D3_COD     NOT LIKE 'MOD%' "
cQuery += "     AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "     AND SD3.D3_ESTORNO = ' ' "
cQuery += "   GROUP BY SD3.D3_COD, "
cQuery += "            SD3.D3_OP, "
cQuery += "            SD3.D3_EMISSAO, "
cQuery += "            SD3.D3_FILIAL, "
cQuery += "            SD3.D3_PERBLK, "
cQuery += "            SD3.R_E_C_N_O_, "
cQuery += "            SD3.D3_ESTORNO, "
cQuery += "            SD3.D3_TRT "
cQuery += "	 HAVING ( SUM(CASE "
cQuery += "               WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "               WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) "
cQuery += "               ELSE 0 END) ) <> 0 

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235S1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235S2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235S2")
	
cQuery := "  INSERT INTO TR235S2 ( TS2_COD, "
cQuery += "                        TS2_TIPO, "	
cQuery += "                        R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT SB1_SD3.B1_COD, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " +MatIsNull() + "(SBZ.BZ_TIPO,SB1_SD3.B1_TIPO), 
Else
	cQuery += " SB1_SD3.B1_TIPO, "
EndIf
 
cQuery += "        SB1_SD3.R_E_C_N_O_ "
cQuery += "   FROM TR235S1 SD3_1, " + RetSqlName("SB1") + " SB1_SD3 " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1_SD3.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  WHERE SB1_SD3.D_E_L_E_T_ = ' ' "
cQuery += "    AND SB1_SD3.B1_FILIAL  = '" + xFilial('SB1') + "' "
cQuery += "    AND SB1_SD3.B1_CCCUSTO = ' ' "
cQuery += "    AND SB1_SD3.B1_COD     NOT LIKE 'MOD%' "
cQuery += "    AND SD3_1.TS1_COD      = SB1_SD3.B1_COD "

//cQuery += "    AND SB1_SD3.B1_TIPO    IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_SD3.B1_TIPO) "
Else
	cQuery += " AND SB1_SD3.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235S2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235S3    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235S3")

cQuery := "  INSERT INTO TR235S3 ( TS3_COD, "
cQuery += "                        TS3_PROD, "	
cQuery += "                        TS3_OP, "	
cQuery += "                        R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT SD3_1.TS1_COD C2D3COD,  SC2.C2_PRODUTO C2PROD, SD3_1.TS1_OP  C2OP, MAX(SD3_1.TS1_RECNO)"
cQuery += "   FROM " + RetSqlName("SC2") + " SC2 , TR235S1 SD3_1 "  "
cQuery += "  WHERE SC2.C2_FILIAL   = '" + xFilial('SC2') + "' "
cQuery += "    AND SC2.D_E_L_E_T_  = ' ' "
cQuery += "    AND SC2.C2_ITEM    <> 'OS' "
cQuery += "    AND SC2.C2_TPPR IN ( 'I', ' ' )
cQuery += "    AND SD3_1.TS1_OP  = SC2.C2_OP " 
cQuery += "    AND SD3_1.TS1_COD <> SC2.C2_PRODUTO "
cQuery += "  GROUP BY SD3_1.TS1_COD ,  SC2.C2_PRODUTO , SD3_1.TS1_OP "

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235S3    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235S4    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235S4")

cQuery := "  INSERT INTO TR235S4 ( TS4_COD, "
cQuery += "                        TS4_TIPO, "	
cQuery += "                        R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT SB1_OP.B1_COD, " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO), "
Else
	cQuery += " SB1_OP.B1_TIPO , "
EndIf

cQuery += "        SB1_OP.R_E_C_N_O_ "
cQuery += "   FROM TR235S3 SC2_1, " + RetSqlName("SB1") + " SB1_OP " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1_OP.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  WHERE SB1_OP.B1_FILIAL   = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_OP.D_E_L_E_T_  = ' ' "
cQuery += "    AND SB1_OP.B1_CCCUSTO  = ' ' "
cQuery += "	   AND SB1_OP.B1_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SB1_OP.B1_COD = SC2_1.TS3_PROD " 

//cQuery += "    AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO) "
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235S4    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

		
ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235S5    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235S5")
	
cQuery := "  INSERT INTO TR235S5 ( TS5_RECNO, "
cQuery += "                        TS5_QUANT, "	
cQuery += "                        TS5_COD, "	
cQuery += "                        TS5_OP, "	
cQuery += "                        TS5_EMIS, "	
cQuery += "                        TS5_FILIAL, "	
cQuery += "                        TS5_PERBLK, "	
cQuery += "                        TS5_ESTORN, "	
cQuery += "                        TS5_TRT, "	
cQuery += "                        TS5_TIPO, "	
cQuery += "                        TS5_PRDORG, "	
cQuery += "                        R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT SD3_1.TS1_RECNO, "
cQuery += "        SD3_1.TS1_QUANT," 
cQuery += "        SD3_1.TS1_COD," 
cQuery += "        SD3_1.TS1_OP," 
cQuery += "        SD3_1.TS1_EMIS," 
cQuery += "        SD3_1.TS1_FILIAL," 
cQuery += "        SD3_1.TS1_PERBLK," 
cQuery += "        SD3_1.TS1_ESTORN," 
cQuery += "        SD3_1.TS1_TRT," 
cQuery += "        SB1_SD3.TS2_TIPO," 
cQuery += "        SD3_1.TS1_PRDORG, " 
cQuery += "        SD3_1.TS1_RECNO " 
cQuery += "   FROM TR235S1 SD3_1 , TR235S2 SB1_SD3, TR235S3 SC2_1, TR235S4 SB1_SC2  "
cQuery += "  WHERE SD3_1.TS1_COD    = SB1_SD3.TS2_COD "
cQuery += "    AND SD3_1.TS1_OP     = SC2_1.TS3_OP "
cQuery += "    AND SD3_1.TS1_COD    = SC2_1.TS3_COD "
cQuery += "    AND SB1_SC2.TS4_COD  = SC2_1.TS3_PROD  "
cQuery += "    AND SD3_1.TS1_QUANT <> 0 "

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235S5    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K235',"PCP K235 - INICIO Montagem query TR235CP    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235CP")

cQuery := "	SELECT Sum(TS5_QUANT)   QUANT2, "
cQuery += "        MIN(TS5_EMIS)    D3_EMISSAO, "
cQuery += "        MIN(TS5_PRDORG)  PRDORG, " 
cQuery += "        TS5_COD          D3_COD, "
cQuery += "        TS5_OP           D3_OP, "
cQuery += "        TS5_TIPO         TIPO, "
cQuery += "        MAX(R_E_C_N_O_)  RECNO "
cQuery += "   FROM TR235S5 " 
//cQuery += "  WHERE TS5_TIPO NOT IN ("+cTipo05+") "
cQuery += "  WHERE TS5_TIPO IN ("+cTipo03+","+cTipo04+") "
cQuery += "  GROUP BY TS5_COD, TS5_OP, TS5_TIPO  "
cQuery += " HAVING Sum(TS5_QUANT) < 0 "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

(cAliasTmp)->(DbGoTop())
While !(cAliasTmp)->(Eof())

	If (cAliasTmp)->QUANT2 < 0
		cQuery := "  INSERT INTO TR235CP ( TCP_QUANT, "
		cQuery += "                        TCP_EMIS, "	
		cQuery += "                        TCP_PRDORG, "	
		cQuery += "                        TCP_COD, "	
		cQuery += "                        TCP_OP, "	
		cQuery += "                        TCP_TIPO, "	
		cQuery += "                        TCP_MES, "
		cQuery += "                        TCP_ANO, "
		cQuery += "                        R_E_C_N_O_ ) "
		cQuery += "  VALUES ( "
		cQuery += "          '" + CValToChar((cAliasTmp)->QUANT2) + "', "
		cQuery += "          '" + (cAliasTmp)->D3_EMISSAO + "', "
		cQuery += "          '" + (cAliasTmp)->PRDORG + "', "
		cQuery += "          '" + (cAliasTmp)->D3_COD + "', "
		cQuery += "          '" + (cAliasTmp)->D3_OP + "', "
		cQuery += "          '" + (cAliasTmp)->TIPO + "', "
		cQuery += "          '" + STR(cMes,2) + "', " 
		cQuery += "          '" + STR(cAno,4) + "', "
		cQuery += "          '" + CValToChar((cAliasTmp)->RECNO) + "' "
		cQuery += "         )"

		MATExecQry(cQuery)
	EndIf
	(cAliasTmp)->(dbSkip())		
EndDo
(cAliasTmp)->(dbCloseArea())

nTotal := 0
cQuery := " SELECT COUNT(*) qtd_total "
cQuery += "   FROM TR235CP "
cQuery += "  WHERE TCP_MES =  '" + STR(cMes,2) + "' "
cQuery += "    AND TCP_ANO =  '" + STR(cAno,4) + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.T.)

If !(cAliasTot)->(Eof())
	nTotal := (cAliasTot)->qtd_total
EndIf

If nTotal == 0
	cQuery := "  INSERT INTO TR235CP ( TCP_QUANT, "
	cQuery += "                        TCP_EMIS, "	
	cQuery += "                        TCP_PRDORG, "	
	cQuery += "                        TCP_COD, "	
	cQuery += "                        TCP_OP, "	
	cQuery += "                        TCP_TIPO, "	
	cQuery += "                        TCP_MES, "
	cQuery += "                        TCP_ANO, "
	cQuery += "                        R_E_C_N_O_ ) "
	cQuery += "	 VALUES ( 0, ' ', ' ',' ', ' ',' ','" + STR(cMes,2) + "', '" + STR(cAno,4) + "' , 1)"

	MATExecQry(cQuery)
EndIf

cQuery := " DELETE FROM TR235S5 "
cQuery += "  WHERE EXISTS ( SELECT 1  "
cQuery += "                   FROM TR235CP CO "
cQuery += "                  WHERE CO.TCP_OP = TR235S5.TS5_OP) "

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM Montagem query TR235CP    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))


ProcLogAtu('PCP K235',"PCP K235 - INICIO LEITURA TR235S5    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

cQuery := "	SELECT Sum(TS5_QUANT)   QUANT2, "
cQuery += "        MIN(TS5_EMIS)    D3_EMISSAO, "
cQuery += "        MIN(TS5_PRDORG)  PRDORG, " 
cQuery += "        TS5_COD          D3_COD, "
cQuery += "        TS5_OP           D3_OP, "
cQuery += "        TS5_TIPO         TIPO "
cQuery += "   FROM TR235S5 " 
cQuery += "  GROUP BY TS5_COD, TS5_OP, TS5_TIPO  "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
ProcLogAtu('PCP K235',"PCP K235 - FIM LEITURA TR235S5    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//ProcLogAtu('PCP K235',"PCP K235 - INICIO BUSCA CO PRODU«√O    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
//Processamento para avaliar co produÁıes quando n„o existem estruturas.
//oCoProd := JsonObject():New()
//fValCoProd(@oCoProd,cAliasTmp)	
//ProcLogAtu('PCP K235',"PCP K235 - FIM BUSCA CO PRODU«√O    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If lEstMov
	dbSelectArea("SD4")
	dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
EndIf
	 
//Carrega as filiais uma ˙nica vez
cSD4Filial := xFilial("SD4")
cSVTFilial := xFilial("SVT")

ProcLogAtu('PCP K235',"PCP K235 - INICIO CARREGA TABELA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

(cAliasTmp)->(DbGoTop())
While !(cAliasTmp)->(Eof())
	
	/*
	cIndice := (cAliasTmp)->D3_OP
	If (oCoProd:HasProperty(cIndice) .and. oCoProd[cIndice] < 0)
		(cAliasTmp)->(DbSkip())
		Loop
	EndIf
	*/

	If ((cAliasTmp)->TIPO $ cTipo05 ) .And. (cAliasTmp)->QUANT2 < 0 //Quando for subproduto negativo n„o considerar
		(cAliasTmp)->(DbSkip())
		Loop
	EndIf

	//grava tabela fÌsica para guardar histÛrico
	SVT->(dbSetOrder(2))
	If !SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		//************************************************************************
		// Bloco K235
		//************************************************************************
		Reclock("SVT",.T.)
		SVT->VT_PRGORI  := cChamada
		SVT->VT_FILIAL  := cSVTFilial
		SVT->VT_MESSPED := STR(cMes,2)
		SVT->VT_ANOSPED := STR(cAno,4)
		SVT->VT_REG     := "K235"
		SVT->VT_DTSAIDA := StoD((cAliasTmp)->D3_EMISSAO)
		SVT->VT_PRODUTO := (cAliasTmp)->D3_COD
		SVT->VT_QUANT   := (cAliasTmp)->QUANT2
		SVT->VT_PRODORI := (cAliasTmp)->PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
		SVT->VT_OP      := (cAliasTmp)->D3_OP
			 
		If lEstMov
			If SD4->(MsSeek(cSD4Filial+(cAliasTmp)->(D3_OP+D3_COD)))
				SVT->VT_EMPENHO := "S"
			EndIf
		EndIf
			
		SVT->(MsUnlock())
		(cAliasTmp)->(dbSkip())			
	Else
		//************************************************************************
		// Bloco K235 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************	
		SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	    While SVT->(!Eof()) .And. SVT->VT_FILIAL == cSVTFilial .And. SVT->VT_MESSPED == STR(cMes,2) .And. SVT->VT_ANOSPED == STR(cAno,4) .And. SVT->VT_OP == (cAliasTmp)->D3_OP .And. SVT->VT_PRODUTO == (cAliasTmp)->D3_COD .And. SVT->VT_PRGORI == cChamada 
	    	RecLock("SVT",.F.,.T.)
	    	SVT->VT_QUANT += (cAliasTmp)->QUANT2
	    	SVT->(MsUnlock())
			SVT->(dbSkip())
	    EndDo
		(cAliasTmp)->(dbSkip())
	EndIf					
EndDo

ProcLogAtu('PCP K235',"PCP K235 - FIM CARREGA TABELA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
(cAliasTmp)->(dbCloseArea())


//CRIA TEMP 1 PARA USAR NO UPDATE DO CAMPO D3_PERBLK DA SD3
ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U1 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235U1")

cQuery := "  INSERT INTO TR235U1 ( TU1_RECNO, "
cQuery += "                        TU1_OP, "
cQuery += "                        TU1_COD, "	
cQuery += "                        TU1_EMIS, "	
cQuery += "                        R_E_C_N_O_ )"		
cQuery += " SELECT SD3_1.R_E_C_N_O_ SD3RECNO, SD3_1.D3_OP, SD3_1.D3_COD, SD3_1.D3_EMISSAO, SD3_1.R_E_C_N_O_ SD3RECNO1 " 
cQuery += "   FROM " + RetSqlName("SD3") + " SD3_1 " 
cQuery += "	 WHERE SD3_1.D3_FILIAL   = '" + xFilial('SD3') + "' " 
cQuery += "    AND SD3_1.D_E_L_E_T_  = ' ' " 
cQuery += "    AND SD3_1.D3_OP      <> ' ' " 
cQuery += "	   AND (SD3_1.D3_CF LIKE ('RE%') OR SD3_1.D3_CF LIKE ('DE%')) "
cQuery += "    AND SD3_1.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
cQuery += "	   AND SD3_1.D3_ESTORNO <> 'S' "
cQuery += "    AND NOT EXISTS ( SELECT 1  "
cQuery += "                   FROM TR235CP CO "
cQuery += "                  WHERE CO.TCP_OP = SD3_1.D3_OP) "

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM TEMP TR235U1 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//CRIA TEMP 2 PARA USAR NO UPDATE DO CAMPO D3_PERBLK DA SD3
ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U2 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235U2")

cQuery := "  INSERT INTO TR235U2 ( TU2_COD, "
cQuery += "                        TU2_TIPO, "
cQuery += "                        R_E_C_N_O_ )"		
cQuery += " SELECT DISTINCT SB1_SD3.B1_COD, "  

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += + MatIsNull() + "(SBZ.BZ_TIPO,SB1_SD3.B1_TIPO), 
Else
	cQuery += " SB1_SD3.B1_TIPO, "
EndIf

cQuery += "        SB1_SD3.R_E_C_N_O_ "
cQuery += "   FROM TR235U1 SD3_1, " + RetSqlName("SB1") + " SB1_SD3 "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1_SD3.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  WHERE SB1_SD3.D_E_L_E_T_ = ' ' "
cQuery += "    AND SB1_SD3.B1_FILIAL  = '" + xFilial('SB1') + "' "
cQuery += "    AND SB1_SD3.B1_CCCUSTO = ' ' "
cQuery += "    AND SB1_SD3.B1_COD     NOT LIKE 'MOD%' "
cQuery += "    AND SD3_1.TU1_COD      = SB1_SD3.B1_COD "

//cQuery += "    AND SB1_SD3.B1_TIPO    IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_SD3.B1_TIPO) "
Else
	cQuery += " AND SB1_SD3.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")


MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM TEMP TR235U2 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//CRIA TEMP 3 PARA USAR NO UPDATE DO CAMPO D3_PERBLK DA SD3
ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U3 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235U3")

cQuery := "  INSERT INTO TR235U3 ( TU3_COD, "
cQuery += "                        TU3_PROD, "
cQuery += "                        TU3_OP, "
cQuery += "                        R_E_C_N_O_ )"		
cQuery += " SELECT DISTINCT SD3_1.TU1_COD C2D3COD,  SC2.C2_PRODUTO C2PROD, SD3_1.TU1_OP  C2OP, MAX(SD3_1.TU1_RECNO)"
cQuery += "   FROM " + RetSqlName("SC2") + " SC2 , TR235U1 SD3_1 "  "
cQuery += "  WHERE SC2.C2_FILIAL   = '" + xFilial('SC2') + "' "
cQuery += "    AND SC2.D_E_L_E_T_  = ' ' "
cQuery += "    AND SC2.C2_ITEM    <> 'OS' "
cQuery += "    AND SC2.C2_TPPR IN ( 'I', ' ' )
cQuery += "    AND SD3_1.TU1_OP = SC2.C2_OP " 
cQuery += "    AND SD3_1.TU1_COD <> SC2.C2_PRODUTO "
cQuery += "  GROUP BY SD3_1.TU1_COD ,  SC2.C2_PRODUTO , SD3_1.TU1_OP "
   
MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - FIM TEMP TR235U3 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//CRIA TEMP 4 PARA USAR NO UPDATE DO CAMPO D3_PERBLK DA SD3
ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U4 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

BKCriaTemp("TR235U4")

cQuery := "  INSERT INTO TR235U4 ( TU4_COD, "
cQuery += "                        TU4_TIPO, "
cQuery += "                        R_E_C_N_O_ )"		
cQuery += " SELECT DISTINCT SB1_OP.B1_COD, " 

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "" + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO) ," 
Else
	cQuery += " SB1_OP.B1_TIPO, "
EndIf

cQuery += "        SB1_OP.R_E_C_N_O_ "
cQuery += "   FROM TR235U3 SC2_1, "  + RetSqlName("SB1") + " SB1_OP "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1_OP.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  WHERE SB1_OP.B1_FILIAL   = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_OP.D_E_L_E_T_  = ' ' "
cQuery += "    AND SB1_OP.B1_CCCUSTO  = ' ' "
cQuery += "	   AND SB1_OP.B1_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SB1_OP.B1_COD = SC2_1.TU3_PROD " 

//cQuery += "    AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO) "
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U4 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

/// TEMP DOS REGISTROS QUE ALTERADOS  ///

ProcLogAtu('PCP K235',"PCP K235 - INICIO TEMP TR235U5 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
BKCriaTemp("TR235U5")

cUpdateD3 := "  INSERT INTO TR235U5 ( TU5_RECNO, "
cUpdateD3 += "                        TU5_COD, "
cUpdateD3 += "                        TU5_OP, "
cUpdateD3 += "                        TU5_EMIS, "
cUpdateD3 += "                        R_E_C_N_O_ )"	
cUpdateD3 += " SELECT DISTINCT SD3_1.TU1_RECNO, SD3_1.TU1_COD,  SD3_1.TU1_OP, SD3_1.TU1_EMIS, SD3_1.TU1_RECNO "
cUpdateD3 += "    FROM TR235U1 SD3_1 , TR235U2 SB1_SD3, TR235U3 SC2_1, TR235U4 SB1_SC2  "
cUpdateD3 += "   WHERE SD3_1.TU1_COD   = SB1_SD3.TU2_COD "
cUpdateD3 += "     AND SD3_1.TU1_OP    = SC2_1.TU3_OP "
cUpdateD3 += "     AND SD3_1.TU1_COD   = SC2_1.TU3_COD "
cUpdateD3 += "     AND SB1_SC2.TU4_COD  = SC2_1.TU3_PROD  "

MATExecQry(cUpdateD3)

ProcLogAtu('PCP K235',"PCP K235 - FIM TEMP TR235U5 : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
					
//UPDATE USANDO A VIEW
ProcLogAtu('PCP K235',"PCP K235 - INICIO UPDATE PERBLK : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//FunÁ„o para atualizar o D3_PERBLK - K235
AtuD3K235(dDataDe,dDataAte)

ProcLogAtu('PCP K235',"PCP K235 - FIM UPDATE PERBLK : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))	
///////FIM MARCA«√O DO CAMPO D3_PERBLK A SD3
		

ProcLogAtu('PCP K235',"PCP K235 - Limpar histÛrico    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

// Limpa T4H (275) antecipadamente para o caso de devoluÁ„o no periodo
cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - Gravar temporaria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))



//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
SVT->(dbSetOrder(2))
SVT->(dbSeek(cSVTFilial+STR(cMes,2)+STR(cAno,4)))
While SVT->(!Eof()) .And. SVT->VT_FILIAL == cSVTFilial .And. SVT->VT_MESSPED == STR(cMes,2) .And. SVT->VT_ANOSPED == STR(cAno,4)
	If SVT->VT_PRGORI == cChamada
		If SVT->VT_QUANT > 0
			Reclock(cAliK235,.T.)
			(cAliK235)->FILIAL     := cSVTFilial
			(cAliK235)->REG        := "K235"
			(cAliK235)->DT_SAIDA   := SVT->VT_DTSAIDA
			(cAliK235)->COD_ITEM   := SVT->VT_PRODUTO
			(cAliK235)->QTD        := SVT->VT_QUANT
			(cAliK235)->COD_DOC_OP := SVT->VT_OP
			(cAliK235)->COD_INS_SU := SVT->VT_PRODORI
			(cAliK235)->EMPENHO    := SVT->VT_EMPENHO
			(cAliK235)->(MsUnLock())
			nRegsto++
		Else	
			//************************************************************************
			// Bloco K275 para componentes e acabado. N„o cria para produto retrabalho
			//************************************************************************
			/*
			Reclock("T4H",.T.)
			T4H->T4H_PRGORI := cChamada
			T4H->T4H_FILIAL := cSVTFilial //chave
			T4H->T4H_MESSPE := STR(cMes,2)
			T4H->T4H_ANOSPE := STR(cAno,4)
			T4H->T4H_REG    := "K275"
			T4H->T4H_PRODUT := SVT->VT_PRODUTO
			T4H->T4H_QTD_NE := SVT->VT_QUANT * -1
			T4H->T4H_INS_SU := SVT->VT_PRODORI
			T4H->T4H_OP     := SVT->VT_OP //chave
			T4H->T4H_BLK_CO := "K235" //controle interno - bloco corrigido
			T4H->T4H_CF     := "DE0"
			T4H->(MsUnlock())
			*/
			// Eliminar K235 para devoluÁ„o
			RecLock("SVT", .F.)
			SVT->(DBDelete())
			SVT->(MsUnlock())
		EndIf
	EndIf
	SVT->(dbSkip())			
EndDo
MsUnlock()

/*
// OS REGISTROS DE PRODU«√O EST√O SENDO MARCADOS NO PROCESSAMENTO DO K230 //

ProcLogAtu('PCP K235',"PCP K235 - MarcaÁ„o de registros INICIO   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//***************************************
//Busca os dados para marcaÁ„o de leitura
//***************************************
cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
                          " ELSE 0 END) AS QUANT, " +;
                 " SD3.D3_COD, "+; 
                 " SD3.D3_OP, " +; 
                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_ AS SD3RECNO " +; 
            " FROM " + RetSqlName("SD3") + " SD3 " +;
            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
             " AND SB1.B1_COD     = SD3.D3_COD " +; 
             " AND SB1.D_E_L_E_T_ = ' ' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "JOIN " + RetSqlName("SC2") + " SC2 " 		
    	cQuery += " ON SD3.D3_OP      = SC2.C2_OP " 

		cQuery +=  " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
          " AND SC2.D_E_L_E_T_ = ' ' " +; 
          " AND SC2.C2_ITEM   <> 'OS' " +; 
          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
          " AND SB1_OP.D_E_L_E_T_ = ' ' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
	                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
	               " AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF

cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ = ' ' " +; 
            " AND SD3.D3_OP     <> ' ' " +; 
            " AND (SD3.D3_CF  LIKE ('PR%')) " +; 
            " AND SB1.B1_CCCUSTO = ' ' " +; 
            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
            " AND SD3.D_E_L_E_T_ = ' ' " +; 
            " AND SD3.D3_CF         <> 'DE1' " +;                      
            " AND (SELECT COUNT(*) FROM " + RetSqlName("SD4") + " SD4 " +; 
            "      WHERE SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " +; 
            "      AND SD4.D4_OP     = SD3.D3_OP " +;
            "      AND SD4.D_E_L_E_T_ = ' ' " +; 
            "      AND SD4.D4_QTDEORI < 0) = 0 "
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf

cQuery += "    IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += "          SD3.D3_PERBLK, SD3.R_E_C_N_O_ "   
cQuery += "HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
cQuery += " ORDER BY 4,3,2 "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

ProcLogAtu('PCP K235',"PCP K235 - MarcaÁ„o de registros DURANTE   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

While !(cAliasTmp)->(Eof())
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K235',"PCP K235 - MarcaÁ„o de registros FIM   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
*/

/*
ProcLogAtu('PCP K235',"PCP K235 - CriaÁ„o TEMP TR235U6 INICIO   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
BKCriaTemp("TR235U6")

cQuery := "  INSERT INTO TR235U6  ( TU6_RECNO, "	
cQuery += "                         R_E_C_N_O_ )"
cQuery += " SELECT DISTINCT D5.TU5_RECNO, D5.TU5_RECNO
cQuery += "   FROM TR235U5 D5 " 
cQuery += "  WHERE NOT EXISTS ( SELECT 1 "
cQuery += "                       FROM " + RetSqlName("SVT") + " SVT " 
cQuery += "                       WHERE SVT.VT_MESSPED   = '" + STR(cMes,2) + "' "
cQuery += "                         AND SVT.VT_ANOSPED   = '" + STR(cAno,4) + "' "
cQuery += "                         AND SVT.VT_PRODUTO   = D5.TU5_COD "
cQuery += "                         AND SVT.VT_OP        = D5.TU5_OP "
cQuery += "                         AND SVT.VT_FILIAL    = '" + xFilial('SVT') + "' "
cQuery += "                         AND SVT.D_E_L_E_T_   = ' ' ) " 
cQuery += "    AND NOT EXISTS ( SELECT 1 "
cQuery += "                       FROM " + RetSqlName("T4H") + " T4H " 
cQuery += "                       WHERE T4H.T4H_MESSPE  = '" + STR(cMes,2) + "' "
cQuery += "                         AND T4H.T4H_ANOSPE  = '" + STR(cAno,4) + "' "
cQuery += "                         AND T4H.T4H_PRODUT  = D5.TU5_COD "
cQuery += "                         AND T4H.T4H_OP      = D5.TU5_OP	"
cQuery += "                         AND T4H.T4H_BLK_CO  = 'K235' " 
cQuery += "                         AND T4H.T4H_FILIAL  = '" + xFilial('T4H') + "' "
cQuery += "                         AND T4H.D_E_L_E_T_  = ' ' ) " 

MATExecQry(cQuery)

ProcLogAtu('PCP K235',"PCP K235 - CriaÁ„o TEMP TR235U6 FIM   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

ProcLogAtu('PCP K235',"PCP K235 - UPDATE D3_PERBLK INICIO   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

cTabD3 := RetSqlName("SD3")
cRecD3 := cTabD3 +'.R_E_C_N_O_'

cUpdateD3 := " UPDATE " + cTabD3 + " " 
cUpdateD3 += "    SET D3_PERBLK = ' ' "
cUpdateD3 += "  WHERE D3_CF      = 'DE0' "
cUpdateD3 += "    AND D3_FILIAL  = '" + xFilial('SD3') + "' "
cUpdateD3 += "    AND EXISTS ( SELECT 1  "
cUpdateD3 += "                   FROM TR235U6 D6 "
cUpdateD3 += "                  WHERE D6.TU6_RECNO = " +cRecD3+ " ) "

MATExecQry(cUpdateD3)

ProcLogAtu('PCP K235',"PCP K235 - UPDATE D3_PERBLK FIM   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
*/
ProcLogAtu('PCP K235',"PCP K235 - Fim de funÁ„o   : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return

/*/{Protheus.doc} fValCoProd
	VerificaÁ„o de produÁ„o conjunta independente do empenho.
	@type  Static Function
	@author mauricio.joao
	@since 13/09/2022
	@version 1.0
	@param oCoProd, object, lista de ordens de produÁ„o com produÁ„o conjunta. 
	@param cAliasTmp, char, alias da tabela temporaria.
/*/
Static Function fValCoProd(oCoProd,cAliasTmp)

Local aAreaTmp := (cAliasTmp)->(GetArea())

	While !(cAliasTmp)->(Eof())	
		cIndice := (cAliasTmp)->D3_OP

		If (cAliasTmp)->QUANT2 > 0
			(cAliasTmp)->(DbSkip())
			Loop
		EndIf
		
		If !((cAliasTmp)->TIPO $ cTipo05 )
			oCoProd[cIndice] := (cAliasTmp)->QUANT2
		EndIf
		
		(cAliasTmp)->(DbSkip())
	EndDo

RestArea(aAreaTmp)

Return .T.

/*------------------------------------------------------------------------//
//Programa:	  REGK290 
//Autor:	  Ricardo Peixoto
//Data:		  21/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K290
//Parametros: 1 - cAliK290      - Alias do arquivo de trabalho do K290
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/
Function REGK290(cAliK290,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cAliasTot     := GetNextAlias()
Local cSVUFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local nTotal        := 0

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVU") + " WHERE VU_MESSPED = '" + STR(cMes,2) + "' AND VU_ANOSPED = '" + STR(cAno,4) + "' AND VU_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

nTotal := 0
cQuery := " SELECT COUNT(*) qtd_total "
cQuery += "   FROM TR235CP "
cQuery += "  WHERE TCP_MES =  '" + STR(cMes,2) + "' "
cQuery += "    AND TCP_ANO =  '" + STR(cAno,4) + "' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.T.)

If !(cAliasTot)->(Eof())
	nTotal := (cAliasTot)->qtd_total
EndIf

//Busca os dados para geraÁ„o do K290
cQuery := " SELECT SUM(SD3.D3_QUANT) AS QUANT, "
cQuery += "        SD3.D3_OP, " 
cQuery += "        SD3.D3_COD, " 
cQuery += "        SD3.D3_FILIAL, "
cQuery += "        SD3.D3_PERBLK, " 
cQuery += "        SD3.R_E_C_N_O_ AS SD3RECNO, "
cQuery += "        SD3.D3_ESTORNO, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf

cQuery += "        SC2.C2_DATPRI AS DTINI, " 
cQuery += "        SC2.C2_DATRF AS DTFIM, " 
cQuery += "        SC2.C2_QUANT AS QTDORI "
cQuery += "   FROM "+RetSqlName("SD3") + " SD3 " 
cQuery += "   JOIN "+RetSqlName("SB1") + " SB1 " 
cQuery += "     ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1.B1_COD     = SD3.D3_COD " 
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
      
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " 
	cQuery += "   ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " 
	cQuery += "  AND SBZ.BZ_COD     = SB1.B1_COD " 
	cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "  JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "    ON SD3.D3_OP      = SC2.C2_OP "
cQuery += "   AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " 
cQuery += "   AND SC2.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SC2.C2_ITEM    <> 'OS' " 
cQuery += "   AND SC2.C2_PRODUTO = SD3.D3_COD " 
cQuery += "   AND SC2.C2_TPPR    IN ('I',' ') "
           
// validaÁ„o de empenho negativo
cQuery += "  JOIN " + RetSqlName("SD4") + " SD4 " 
cQuery += "    ON SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " 
cQuery += "   AND SD4.D4_OP     = SD3.D3_OP " 
cQuery += "   AND SD4.D4_QTDEORI < 0 " 
cQuery += "   AND SD4.D4_COD = ( SELECT B1_COD " 
cQuery += "                       FROM " + RetSqlName("SB1") + " SB1D4 " 
cQuery += "                      WHERE SB1D4.b1_filial = '" + xFilial('SB1') + "' "
cQuery += "                        AND SB1D4.B1_COD = SD4.D4_COD "
cQuery += "                        AND SB1D4.B1_TIPO IN ( "+cTipo03+","+cTipo04+" ) 
cQuery += "                        AND SB1D4.D_E_L_E_T_ = ' ' ) " 
cQuery += "   AND SD4.D_E_L_E_T_ = ' ' "          
cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " 
cQuery += "   AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SD3.D3_OP      <> ' ' "
cQuery += "   AND SD3.D3_CF      IN ('PR0','PR1') " 
cQuery += "   AND SD3.D3_COD     NOT LIKE 'MOD%' "
cQuery += "   AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "   AND SB1.B1_CCCUSTO = ' ' " 
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) " 
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "    IN (" + cTipo03 + "," + cTipo04 + "," + cTipo06 + ") "
cQuery += "   AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SD3.D3_ESTORNO <> 'S' " 

If nTotal > 0
	cQuery += "   AND EXISTS ( SELECT 1 FROM TR235CP WHERE TCP_OP = SD3.D3_OP )
EndIf


cQuery += " GROUP BY SD3.D3_OP, " 
cQuery += "          SD3.D3_COD, "
cQuery += "          SD3.D3_FILIAL, "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += " SB1.B1_TIPO, "
EndIf

cQuery += "  SC2.C2_DATPRI, " 
cQuery += "  SC2.C2_DATRF, " 
cQuery += "  SC2.C2_QUANT, "          
cQuery += "  SD3.D3_PERBLK, "
cQuery += "  SD3.R_E_C_N_O_, "
cQuery += "  SD3.D3_ESTORNO "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

cSVUFilial := xFilial("SVU")

While !(cAliasTmp)->(Eof())
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)

	//grava tabela fÌsica para guardar histÛrico
	SVU->(dbSetOrder(1))
	If !SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+ cChamada))
		//************************************************************************
		// Bloco K290
		//************************************************************************
		Reclock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := GetIniProd((cAliasTmp)->D3_OP)
		SVU->VU_DTFIMOP := If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
		SVU->VU_OP      := (cAliasTmp)->D3_OP
		SVU->(MsUnlock())					
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())


//Inicia a Gravacao das Producoes Zeradas, nas situacoes em que houveram apenas Requisicoes no Periodo de Apuracao
cQuery := " SELECT DISTINCT SVW.VW_OP, "
cQuery += "        SC2.C2_DATRF, " 
cQuery += "        SC2.C2_PRODUTO, "
cQuery += "        SC2.C2_QUANT "
cQuery += "   FROM " + RetSqlName("SVW") + " SVW " 
cQuery += "   JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "     ON SVW.VW_FILIAL  = '" + xFilial("SVW") + "' " 
cQuery += "    AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "   
cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "           
cQuery += "    AND SVW.VW_OP      = SC2.C2_OP "			
cQuery += "    AND SVW.VW_MESSPED = '" + STR(cMes,2) + "' "
cQuery += "    AND SVW.VW_ANOSPED = '" + STR(cAno,4) + "' "
cQuery += "    AND NOT EXISTS (SELECT 1 " 
cQuery += "                      FROM " + RetSqlName("SVU") + " SVU "
cQuery += "                     WHERE SVU.VU_FILIAL = '" + xFilial("SVU") + "' " 
cQuery += "                       AND SVW.VW_FILIAL = '" + xFilial("SVW") + "' " 
cQuery += "                       AND SVU.VU_OP     = SVW.VW_OP " 
cQuery += "                       AND SVU.VU_MESSPED = SVW.VW_MESSPED " 
cQuery += "                       AND SVU.VU_ANOSPED = SVW.VW_ANOSPED ) "
                                
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	//grava tabela fÌsica para guardar histÛrico
	SVU->(dbSetOrder(1))
	If !SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->VW_OP+ cChamada))
		//************************************************************************
		// Bloco K290
		//************************************************************************
		Reclock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := GetIniProd((cAliasTmp)->VW_OP)
		SVU->VU_DTFIMOP := If(STOD((cAliasTmp)->C2_DATRF) > dDataAte, StoD(""), STOD((cAliasTmp)->C2_DATRF))
		SVU->VU_OP      := (cAliasTmp)->VW_OP
		SVU->(MsUnlock())		
	EndIf
	(cAliasTmp)->(dbSkip())	
EndDo
(cAliasTmp)->(dbCloseArea())

//MsUnlock()

//gravaÁ„o de OPs encerradas no perÌodo, mas sem movimentaÁıes no mesmo.
cQuery := " SELECT SVU.VU_OP, MAX(SVU.R_E_C_N_O_)  AS REQSVU, SC2.C2_DATRF " 
cQuery += "   FROM " + RetSqlName("SVU") + " SVU " 
cQuery += "   LEFT JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "     ON SC2.C2_OP      = SVU.VU_OP " 
cQuery += "    AND SC2.C2_FILIAL  = SVU.VU_FILIAL " 
cQuery += "    AND SC2.D_E_L_E_T_ = ' ' " 
cQuery += "  WHERE SVU.VU_DTFIMOP <> SC2.C2_DATRF " 
cQuery += "    AND SVU.VU_DTFIMOP = '        ' " 
cQuery += "    AND SVU.VU_FILIAL  = '" + xFilial("SVU") + "' "
cQuery += "    AND SC2.C2_DATRF BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "    AND ( SELECT COUNT(*) "
cQuery += "            FROM " + RetSqlName("SVU") + " SVU2 "
cQuery += "           WHERE SVU2.VU_FILIAL  = '" + xFilial("SVU") + "' "
cQuery += "             AND SVU2.VU_OP = SVU.VU_OP "
cQuery += "             AND SVU2.VU_DTFIMOP <> '        ' ) = 0 " 
cQuery += "  GROUP BY SVU.VU_OP, SC2.C2_DATRF "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

SVU->(dbSetOrder(1))
While !(cAliasTmp)->(Eof())
	SVU->(dbGoTo((cAliasTmp)->REQSVU))		

	dDtIni := SVU->VU_DTINIOP
	dDtFim := STOD((cAliasTmp)->C2_DATRF)
	cDocOp := SVU->VU_OP	
	
	If SVU->VU_PRGORI == cChamada .And. SVU->VU_FILIAL == cSVUFilial .And. SVU->VU_MESSPED == STR(cMes,2) .And. SVU->VU_ANOSPED == STR(cAno,4) .And. SVU->VU_REG == "K290" .And. SVU->VU_OP == (cAliK290)->COD_DOC_OP	
		RecLock("SVU",.F.)
		SVU->VU_DTFIMOP := STOD((cAliasTmp)->C2_DATRF)
		SVU->(MsUnlock())
	Else
		//clonar com qtd zerada (cAliK230)->QTD_ENC
		RecLock("SVU",.T.)
		SVU->VU_PRGORI  := cChamada
		SVU->VU_FILIAL  := cSVUFilial
		SVU->VU_MESSPED := STR(cMes,2)
		SVU->VU_ANOSPED := STR(cAno,4)
		SVU->VU_REG     := "K290"
		SVU->VU_DTINIOP := dDtIni
		SVU->VU_DTFIMOP := dDtFim
		SVU->VU_OP      := cDocOp
		SVU->(MsUnlock())	
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
SVU->(dbSetOrder(1))
SVU->(dbSeek(cSVUFilial+STR(cMes,2)+STR(cAno,4)))
While SVU->(!Eof()) .And. SVU->VU_FILIAL == cSVUFilial .And. SVU->VU_MESSPED == STR(cMes,2) .And. SVU->VU_ANOSPED == STR(cAno,4)
	If SVU->VU_PRGORI == cChamada
		Reclock(cAliK290,.T.)
		(cAliK290)->FILIAL			:= cSVUFilial
		(cAliK290)->REG				:= "K290"
		(cAliK290)->DT_INI_OP		:= SVU->VU_DTINIOP
		(cAliK290)->DT_FIN_OP		:= SVU->VU_DTFIMOP
		(cAliK290)->COD_DOC_OP		:= SVU->VU_OP
		(cAliK290)->(MsUnLock())
		nRegsto++
	EndIf
	SVU->(dbSkip())
EndDo

Return

/*------------------------------------------------------------------------//
//Programa:	  PROCK292 
//Autor:	  Ricardo Peixoto 
//Data:		  21/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K292
//Parametros: 1 - cAliK292      - Alias do arquivo de trabalho do K292
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK292(cAliK292,dDataDe,dDataAte,lRepross,cLeiaute)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSVWFilial    := xFilial("SVV")
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create
Local lREGK290NEW	:= SuperGetMV("MV_BLK290N",.F.,.F.)

Default cLeiaute    := "1"

cK292Ali := cAliK292

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

ProcLogAtu('PCP K292',"PCP K292 - InÌcio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If lREGK290NEW .Or. (cDadosProd == 'SBZ' .And. lCpoBZTP)
	REGK290NEW(cAliK292,dDataDe,dDataAte,cChamada)
	If cLeiaute == "0"
		ProcDelAli()
	EndIf
	Return
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE VW_MESSPED = '" + STR(cMes,2) + "' AND VW_ANOSPED = '" + STR(cAno,4) + "' AND VW_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K292',"PCP K292 - SQL/ORA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

TCDelFile('VWSEL1')
	
//Busca os dados para geraÁ„o do K292
cQuery := " CREATE VIEW VWSEL1 AS "	
cQuery += " SELECT SUM(CASE " 
cQuery += "               WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT *- 1 ) " 
cQuery += " 	          WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += " 	       ELSE 0 " 
cQuery += "            END) AS QUANT, " 
cQuery += "        SD3.D3_COD, "
cQuery += "        SD3.D3_OP, "
cQuery += "        MAX(D3_EMISSAO) AS D3_EMISSAO, " 
cQuery += "        SD3.D3_FILIAL, "
cQuery += "        SD3.D3_PERBLK, "
cQuery += "        SD3.R_E_C_N_O_  AS SD3RECNO, " 
cQuery += "        SD3.D3_ESTORNO " 
cQuery += "   FROM (( SELECT DISTINCT ORDEM.D3_OP " 
cQuery += " 		   FROM (SELECT SUM(CASE "
cQuery += " 						       WHEN SD3C_N2.D3_CF LIKE ( 'DE%' ) THEN " 
cQuery += "                                     (SD3C_N2.D3_QUANT *- 1 ) " 
cQuery += " 							   WHEN SD3C_N2.D3_CF LIKE ( 'RE%' ) THEN "
cQuery += " 									(SD3C_N2.D3_QUANT ) " 
cQuery += " 							ELSE 0 " 
cQuery += " 							END) AS QUANT, " 
cQuery += " 					    SD3C_N2.D3_COD, " 
cQuery += " 					    SD3C_N2.D3_OP " 
cQuery += " 	               FROM " + RetSqlName("SD3") + " SD3C_N2 "
cQuery += " 	              WHERE SD3C_N2.D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += " 			        AND SD3C_N2.D_E_L_E_T_ = ' ' " 
cQuery += "                     AND SD3C_N2.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += " 	              GROUP BY SD3C_N2.D3_OP, " 
cQuery += " 			               SD3C_N2.D3_COD, " 
cQuery += " 			               SD3C_N2.D3_FILIAL " 
cQuery += " 	             HAVING Sum(CASE " 
cQuery += " 				               WHEN SD3C_N2.D3_CF LIKE ( 'DE%' ) THEN "
cQuery += " 					                (SD3C_N2.D3_QUANT *- 1 ) " 
cQuery += " 				               WHEN SD3C_N2.D3_CF LIKE ( 'RE%' ) THEN "
cQuery += " 					                (SD3C_N2.D3_QUANT ) " 
cQuery += " 				            ELSE 0 " 
cQuery += " 				            END) < 0) ORDEM " 
cQuery += "   JOIN " 
cQuery += " 	   (SELECT SB1_SD3.B1_COD, " 
cQuery += " 			   SB1_SD3.B1_TIPO " 
cQuery += " 		  FROM " + RetSqlName("SB1") + " SB1_SD3 " 
cQuery += " 		 WHERE SB1_SD3.D_E_L_E_T_ = ' ' " 
cQuery += " 		   AND SB1_SD3.B1_FILIAL = '" + xFilial('SB1') + "' " 
cQuery += " 		   AND SB1_SD3.B1_TIPO IN ("+cTipo03+","+cTipo04+")) SB1_SD3_1_N2  " 
cQuery += " 		    ON SB1_SD3_1_N2.B1_COD = ORDEM.D3_COD " 
cQuery += " 		  JOIN " 
cQuery += " 		       (SELECT SC2_N2.C2_PRODUTO, "
cQuery += "	                       SC2_N2.C2_OP  C2_OP "
cQuery += " 			      FROM " + RetSqlName("SC2") + " SC2_N2 "
cQuery += " 			     WHERE SC2_N2.C2_FILIAL = '" + xFilial('SC2') + "' " 
cQuery += " 				   AND SC2_N2.D_E_L_E_T_ = ' ' "
cQuery += " 				   AND SC2_N2.C2_ITEM   <> 'OS' " 
cQuery += " 				   AND SC2_N2.C2_TPPR IN ( 'I', ' ' )) SC2_1_N2 "
cQuery += " 		    ON ORDEM.D3_OP  = SC2_1_N2.C2_OP " 
//cQuery += " 		   AND ORDEM.D3_COD <> SC2_1_N2.C2_PRODUTO " 
cQuery += " 		  JOIN (SELECT SB1_OP_N2.B1_COD, " 
cQuery += " 					   SB1_OP_N2.B1_TIPO " 
cQuery += " 			      FROM " + RetSqlName("SB1") + " SB1_OP_N2 " 
cQuery += " 			     WHERE SB1_OP_N2.B1_FILIAL = '" + xFilial('SB1') + "' " 
cQuery += " 				   AND SB1_OP_N2.D_E_L_E_T_ = ' ' ) SB1_OP_N2 " 
cQuery += " 		    ON SB1_OP_N2.B1_COD = SC2_1_N2.C2_PRODUTO))  SD3_NEG "
cQuery += "   JOIN " + RetSqlName("SD3") + " SD3 ON SD3_NEG.D3_OP = SD3.D3_OP "
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 " 
cQuery += "     ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1.B1_COD = SD3.D3_COD " 
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' " 
cQuery += "   JOIN " + RetSqlName("SC2") + " SC2 " 
cQuery += "	    ON SD3.D3_OP = SC2.C2_OP "
cQuery += "    AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " 
cQuery += "    AND SC2.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SC2.C2_ITEM <> 'OS' " 
cQuery += "    AND SC2.C2_TPPR IN ( 'I', ' ' ) " 
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1_OP " 
cQuery += "     ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_OP.B1_COD = SC2.C2_PRODUTO " 
cQuery += "    AND SB1_OP.D_E_L_E_T_ = ' ' " 
cQuery += "  WHERE SD3.D3_FILIAL = '" + xFilial('SD3') + "' " 
//cQuery += "    AND SD3.D3_COD <> SC2.C2_PRODUTO " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SD3.D3_OP <> ' ' " 
cQuery += "    AND (SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) "
cQuery += "    AND SB1.B1_CCCUSTO = ' ' "
cQuery += "    AND SB1.B1_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SB1.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
cQuery += "    AND SB1_OP.B1_CCCUSTO = ' ' " 
cQuery += "    AND SB1_OP.B1_COD NOT LIKE 'MOD%' " 
cQuery += "    AND SB1_OP.B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
cQuery += "    AND SD3.D3_ESTORNO <> 'S' " 
cQuery += "  GROUP BY SD3.D3_OP, " 
cQuery += "           SD3.D3_COD, " 
cQuery += "           SD3.D3_FILIAL, " 
cQuery += "           SD3.D3_PERBLK, " 
cQuery += "           SD3.R_E_C_N_O_, " 
cQuery += "           SD3.D3_ESTORNO " 
cQuery += " HAVING (Sum(CASE " 
cQuery += "                WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "                WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += "             ELSE 0 " 
cQuery += "             END) ) <> 0 
	

cUpdateD3 := " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ = ' ' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	
	cUpdateD3 += "JOIN " + RetSqlName("SC2") + " SC2 " 	            
	cUpdateD3 +=   " ON SD3.D3_OP      = SC2.C2_OP "			
	cUpdateD3 += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	          " AND SC2.D_E_L_E_T_ = ' ' " +; 
	          " AND SC2.C2_ITEM   <> 'OS' " +; 
	          " AND SC2.C2_TPPR   IN ('I',' ') " +; 
	         " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	           " ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	          " AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	          " AND SB1_OP.D_E_L_E_T_ = ' ' "          
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ = ' ' " 
	EndIF
	
	cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ = ' ' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') " +; 
	            "  OR  SD3.D3_CF  LIKE ('DE%')) " +; 
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ = ' ' "

				//" AND SD3.D3_COD <> SC2.C2_PRODUTO " +;
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cUpdateD3 += " AND SB1.B1_TIPO "
	EndIf
	
	cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cUpdateD3 += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cUpdateD3 += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
	cUpdateD3 += " AND (select min(QUANT) from ( " +;
						" SELECT Sum(CASE " +;
									 " WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( SD3C.D3_QUANT *- 1 ) " +;
									 " WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " +;
									 " ELSE 0 " +;
								   " END)        AS QUANT, " +;
							   " SD3C.D3_COD, " +;
							   " SD3C.D3_OP " +;
						" FROM   "+RetSqlName("SD3") + " SD3C " +;
							   " JOIN "+RetSqlName("SB1") + " SB1 " +;
								 " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1.B1_COD = SD3C.D3_COD " +;
									" AND SB1.D_E_L_E_T_ = ' ' " +;
									" AND SB1.B1_TIPO IN ("+cTipo03+","+cTipo04+") " +;
							   " JOIN "+RetSqlName("SC2") + " SC2 "
								
								cUpdateD3 +=  " ON SD3C.D3_OP = SC2.C2_OP "
								
								cUpdateD3 += 	" AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " +;
									" AND SC2.D_E_L_E_T_ = ' ' " +;
									" AND SC2.C2_ITEM <> 'OS' " +;
									" AND SC2.C2_TPPR IN ( 'I', ' ' ) " +;
							   " JOIN "+RetSqlName("SB1") + " SB1_OP " +;
								 " ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " +;
									" AND SB1_OP.B1_COD = SC2.C2_PRODUTO " +;
									" AND SB1_OP.D_E_L_E_T_ = ' ' " +;
						" WHERE  SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " +;
							   " AND SD3C.D3_COD <> SC2.C2_PRODUTO " +;
							   " AND SD3C.D_E_L_E_T_ = ' ' " +;
							   " AND SD3C.D3_OP = SD3.D3_OP " +;
						" GROUP  BY SD3C.D3_OP, " +;
								  " SD3C.D3_COD, " +;
								  " SD3C.D3_FILIAL " +;
						" ) ORDEM )  < 0 "
	cUpdateD3 += " AND SD3.D3_ESTORNO <> 'S' "	
	
	If  TCGetDB() $ "ORACLE"

			cUpdateD3 := " FROM "+;
			"   (SELECT D3_COD, "+;
			"           D3_OP, "+;
			"           R_E_C_N_O_ "+;
			" 	 FROM " + RetSqlName("SD3") + " SD3 "+;
			"    WHERE D_E_L_E_T_ = ' ' "+;
			"      AND D3_FILIAL = '" + xFilial('SD3') + "' "+; 
			"      AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "+; 
			"      AND D_E_L_E_T_ = ' ' "+;
			"      AND D3_OP <> ' ' "+;
			"      AND (D3_CF LIKE ('RE%') "+;
			"           OR D3_CF LIKE ('DE%')) "+;
			"      AND D3_ESTORNO <> 'S' ) SD3 "+;
			" JOIN "

		cUpdateD3 += "   (SELECT B1_COD "+;
			"    FROM " + RetSqlName("SB1") + " SB1 "+;
			"    WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+; 
			"      AND D_E_L_E_T_ = ' ' "+;
			"      AND B1_CCCUSTO = ' ' "+;
			"      AND B1_COD NOT LIKE 'MOD%' "+;
			"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1 ON SB1.B1_COD = SD3.D3_COD "+;	
			" JOIN "

		cUpdateD3 += "   (SELECT C2_PRODUTO, " +;
			"           C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD AS C2_OP  "+;
			"    FROM " + RetSqlName("SC2") + " SC2 "+;
			"    WHERE C2_FILIAL = '" + xFilial('SC2') + "' "+; 
			"      AND D_E_L_E_T_ = ' ' "+; 
			"      AND C2_ITEM <> 'OS' "+; 
			"      AND C2_TPPR IN ('I', "+; 
			"                      ' ') ) SC2 ON SD3.D3_OP = SC2.C2_OP "
			
			//cUpdateD3 += " AND SD3.D3_COD <> SC2.C2_PRODUTO "+; 
			
			cUpdateD3 += " JOIN "
			
		cUpdateD3 += "   (SELECT B1_COD "+; 
			"    FROM " + RetSqlName("SB1") + " SB1 "+;
			"    WHERE D_E_L_E_T_ = ' ' "+;
			"      AND B1_FILIAL = '" + xFilial('SB1') + "' "+; 
			"      AND B1_CCCUSTO = ' ' "+;
			"      AND B1_COD NOT LIKE 'MOD%' "+;
			"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") ) SB1_OP1 ON SB1_OP1.B1_COD = SC2.C2_PRODUTO  "+;
			" JOIN "

		cUpdateD3 += "   (SELECT SD3C.D3_OP, "+; 
			"           Min(QUANT) "+; 
			"    FROM "+; 
			"      (SELECT Sum(CASE "+; 
			"                      WHEN D3_CF LIKE ('DE%') THEN (D3_QUANT *- 1) "+; 
			"                      WHEN D3_CF LIKE ('RE%') THEN (D3_QUANT) "+; 
			"                      ELSE 0 "+; 
			"                  END) AS QUANT, "+; 
			"              D3_COD, "+; 
			"              D3_OP "+; 
			"       FROM " + RetSqlName("SD3") + " SD3 "+;
			"       WHERE D3_FILIAL = '" + xFilial('SD3') + "' "+;
			"         AND D_E_L_E_T_ = ' ' GROUP  BY D3_OP, "+;
			"                                         D3_COD, "+;
			"                                         D3_FILIAL ) SD3C "+;
			"    JOIN "
		cUpdateD3 += " (SELECT B1_COD "+;
			"       FROM " + RetSqlName("SB1") + " SB1 "+;
			"       WHERE D_E_L_E_T_ = ' ' "+;
			"         AND B1_FILIAL = '" + xFilial('SB1') + "' "+;
			"         AND B1_TIPO IN ('PI', "+;
			"                         'PA') ) SB1 ON SB1.B1_COD = SD3C.D3_COD "+;
			"    JOIN " 

		cUpdateD3 += " (SELECT C2_PRODUTO, "+;
			"        C2_NUM" + cCharSoma + "C2_ITEM" + cCharSoma + "C2_SEQUEN" + cCharSoma + "C2_ITEMGRD AS C2_OP  "+;
			"    	FROM " + RetSqlName("SC2") + " SC2 "+;
			"   	WHERE C2_FILIAL = '" + xFilial('SC2') + "' "+; 
			"         AND D_E_L_E_T_ = ' ' "+;
			"         AND C2_ITEM <> 'OS' "+;
			"         AND C2_TPPR IN ('I', "+;
			"                         ' ') ) SC2_2 ON SD3C.D3_OP = SC2_2.C2_OP "+;
			"    JOIN "
		
		cUpdateD3 += " (SELECT B1_COD "+;
			"       FROM " + RetSqlName("SB1") + " SB1 "+;
			"       WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+;
			"         AND D_E_L_E_T_ = ' ' ) SB1_OP_2 ON SB1_OP_2.B1_COD = SC2_2.C2_PRODUTO "+;
			"    AND SD3C.D3_COD <> SC2_2.C2_PRODUTO "+;
			"    GROUP BY SD3C.D3_OP "+;
			"    HAVING Min(QUANT) < 0) SD3_NEGAT ON SD3.D3_OP = SD3_NEGAT.D3_OP "

	EndIf

	ProcLogAtu('PCP K292',"PCP K292 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
				" 	WHERE R_E_C_N_O_ IN " +;
				" (SELECT SD3.R_E_C_N_O_ " + cUpdateD3 + " ) "

	MATExecQry(cUpdateD3) 
	
	ProcLogAtu('PCP K292',"PCP K292 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K292',"PCP K292 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP " +;
				" FROM VWSEL1 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K292',"PCP K292 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof())
			
		//grava tabela fÌsica para guardar histÛrico
		SVW->(dbSetOrder(1))
		If !SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			//************************************************************************
			// Bloco K292
			//************************************************************************
			Reclock("SVW",.T.)
			SVW->VW_PRGORI  := cChamada
			SVW->VW_FILIAL  := cSVWFilial
			SVW->VW_MESSPED := STR(cMes,2)
			SVW->VW_ANOSPED := STR(cAno,4)
			SVW->VW_REG     := "K292"
			SVW->VW_OP      := (cAliasTmp)->D3_OP
			SVW->VW_PRODUTO := (cAliasTmp)->D3_COD
			SVW->VW_QUANT   := (cAliasTmp)->QUANT
			SVW->(MsUnlock())
			
		Else
	
			//************************************************************************
			// Bloco K292 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVW->(!Eof()) .And. SVW->VW_FILIAL == cSVWFilial .And. SVW->VW_MESSPED == STR(cMes,2) .And. SVW->VW_ANOSPED == STR(cAno,4) .And. SVW->VW_OP == (cAliasTmp)->D3_OP .And. SVW->VW_PRODUTO == (cAliasTmp)->D3_COD .And. SVW->VW_PRGORI == cChamada
		    	RecLock("SVW",.F.,.T.)		    	
		    	SVW->VW_QUANT += (cAliasTmp)->QUANT
		    	SVW->(MsUnlock())
				SVW->(dbSkip())
		    EndDo
		
		EndIf		
			
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
		
	TCDelFile('VWSEL1')
	
fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)

If cLeiaute == "0"
	ProcDelAli()
EndIf

ProcLogAtu('PCP K292',"PCP K292 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return


/*/{Protheus.doc} REGK290NEW
	Processamento alternativo do registro k292 para performance.
	@type  Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
	@param param_name, param_type, param_descr

	/*/
Function REGK290NEW(cAliK292,dDataDe,dDataAte,cChamada)

Local cQuery		:= ""
Local cSVWFilial	:= xFilial("SVV")
Local CSVVFilial	:= ""
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)

Local nOp as numeric
Local nX as numeric
Local nBulk as numeric
Local nMovs as numeric

Local oBulkSVV as object
Local oBulkSVW as object
Local aFields as array

fColetaSB1()
fColetaSC2()
fColetaSD3(dDataDe,dDataAte)

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE VV_MESSPED = '" + STR(cMes,2) + "' AND VV_ANOSPED = '" + STR(cAno,4) + "' AND VV_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE VW_MESSPED = '" + STR(cMes,2) + "' AND VW_ANOSPED = '" + STR(cAno,4) + "' AND VW_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

aOPs := oSD3:GetNames()
oGroup := JsonObject():New() //Agrupador de movimentaÁıes por operaÁ„o
oCoProd := JsonObject():New() //Identificador de ops com co produÁ„o

oBulkSVW := FWBulk():new(RetSqlName("SVW"))

aFields := {}
aAdd(aFields, {"VW_PRGORI"})
aAdd(aFields, {"VW_FILIAL"})
aAdd(aFields, {"VW_MESSPED"})
aAdd(aFields, {"VW_ANOSPED"})
aAdd(aFields, {"VW_REG"})
aAdd(aFields, {"VW_OP"})
aAdd(aFields, {"VW_PRODUTO"})
aAdd(aFields, {"VW_QUANT"})

oBulkSVW:setFields(aFields)

oBulkSVV := FWBulk():new(RetSqlName("SVV"))

aFields := {}
aAdd(aFields, {"VV_PRGORI"})
aAdd(aFields, {"VV_FILIAL"})
aAdd(aFields, {"VV_MESSPED"})
aAdd(aFields, {"VV_ANOSPED"})
aAdd(aFields, {"VV_REG"})
aAdd(aFields, {"VV_OP"})
aAdd(aFields, {"VV_PRODUTO"})
aAdd(aFields, {"VV_QUANT"})

oBulkSVV:setFields(aFields)

For nOp := 1 to len(aOPs)    

    cOp := aOPs[nOp]
    aRecnos := oSD3[cOp]:GetNames()
    oGroup[cOp] := JsonObject():New() 

    For nX := 1 to len(aRecnos)        
        cCod    := oSD3[cOp][aRecnos[nX]]:GetJsonText('COD')
        cCf     := oSD3[cOp][aRecnos[nX]]:GetJsonText('CF')      
        cQuant  := oSD3[cOp][aRecnos[nX]]:GetJsonText('QUANT')
        cTipo   := oSD3[cOp][aRecnos[nX]]:GetJsonText('TIPO')
        cRecno  := oSD3[cOp][aRecnos[nX]]:GetJsonText('RECNO')

        If left(cCf,2) == 'DE' 
            If !oGroup[cOp]:HasProperty(cCod)
                oGroup[cOp][cCod] := Val(cQuant)
            Else
                oGroup[cOp][cCod] += Val(cQuant)
            EndIf        
        EndIf

        If left(cCf,2) $ 'RE|PR'
            If !oGroup[cOp]:HasProperty(cCod)
                oGroup[cOp][cCod] := Val(cQuant)
            Else
                oGroup[cOp][cCod] += Val(cQuant)
            EndIf        
        EndIf

    Next nX  

    oDadosBulk := JsonObject():New()
    aGroup := oGroup[cOp]:GetNames()
    //Carrega as filiais uma ˙nica vez
    cSVWFilial := xFilial("SVW")
    CSVVFILIAL := xFilial("SVV")

	lBulk := .F.
    For nX := 1 to len(aGroup) 
        //Valida se existe produto negativo apÛs o agrupamento dos movimentos.
        //Identifica que È co produÁ„o.
        If oGroup[cOp][aGroup[nX]] < 0 .And. oSB1[aGroup[nX]]["TIPO"] $ ""+cTipo03+"|"+cTipo04+"" 
			lBulk := .T. 
			Exit			
        EndIf
    Next nX  

	If lBulk
		aMovimentos := oSD3[cOp]:GetNames()
		For nMovs := 1 to len(aMovimentos)  
			cCod        := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('COD')
			cCf         := Left(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('CF'),2)     
			nQuant      := Val(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('QUANT'))
			cTipo       := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('TIPO')
			dEmissao    := STOD(oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('EMISSAO'))
			cRecno      := oSD3[cOp][aMovimentos[nMovs]]:GetJsonText('RECNO')		

			//Validar a data de emissao, sÛ vai pro bulk o que estiver dentro do prazo.
			If dEmissao >= dDataDe .AND. dEmissao <= dDataAte
				lBulk := .T.
				If !oDadosBulk:HasProperty(cCod)
					oDadosBulk[cCod] := JsonObject():New()  
					If !oDadosBulk[cCod]:HasProperty(cCf)
						oDadosBulk[cCod][cCf] := JsonObject():New()  
						oDadosBulk[cCod][cCf]['QUANT'] := nQuant
						oDadosBulk[cCod][cCf]['RECNO'] := "'"+cRecno+"',"
					EndIf
				Else
					If !oDadosBulk[cCod]:HasProperty(cCf)
						oDadosBulk[cCod][cCf] := JsonObject():New()  
						oDadosBulk[cCod][cCf]['QUANT'] := nQuant
						oDadosBulk[cCod][cCf]['RECNO'] := "'"+cRecno+"',"
					Else
						If oDadosBulk[cCod]:HasProperty('DE')
							oDadosBulk[cCod]['DE']['QUANT'] += nQuant
							oDadosBulk[cCod]['DE']['RECNO'] += "'"+cRecno+"',"
						Else
							oDadosBulk[cCod][cCf]['QUANT'] += nQuant
							oDadosBulk[cCod][cCf]['RECNO'] += "'"+cRecno+"',"
						EndIf
					EndIf
				EndIf
			EndIf 
		Next nMov

		//Faz o bulk
		aBulk := oDadosBulk:GetNames()
		cRecnos := ''
		For nBulk := 1 to len(aBulk) 

			//Produto possui RE e DE
			// RE > DE -> K292
			// RE < DE -> K291		
			If (oDadosBulk[aBulk[nBulk]]:HasProperty("RE") .AND. oDadosBulk[aBulk[nBulk]]['RE']['QUANT'] != NIL) .And.;
				(oDadosBulk[aBulk[nBulk]]:HasProperty("DE") .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] != NIL)

				cQtdSaldo := oDadosBulk[aBulk[nBulk]]['RE']['QUANT'] + oDadosBulk[aBulk[nBulk]]['DE']['QUANT']

				If cQtdSaldo > 0
				// RE > DE -> K292 -- Validar tipo					
					If oSB1[aBulk[nBulk]]["TIPO"] $ ""+cTipo00+"|"+cTipo01+"|"+cTipo02+"|"+cTipo03+"|"+cTipo04+"|"+cTipo05+"|"+cTipo10+""
						oBulkSVW:addData({cChamada,cSVWFilial,STR(cMes,2),STR(cAno,4),'K292',cOp,aBulk[nBulk],cQtdSaldo})
						cRecnos += oDadosBulk[aBulk[nBulk]]['RE']['RECNO']
						cRecnos += oDadosBulk[aBulk[nBulk]]['DE']['RECNO']
					EndIf
				Else
					If cQtdSaldo < 0
					// RE < DE -> K291 -- Validar tipo
						If oSB1[aBulk[nBulk]]["TIPO"] $ ""+cTipo03+"|"+cTipo04+"" 
							oBulkSVV:addData({cChamada,cSVVFilial,STR(cMes,2),STR(cAno,4),'K291',cOp,aBulk[nBulk],cQtdSaldo*-1})
							cRecnos += oDadosBulk[aBulk[nBulk]]['RE']['RECNO']
							cRecnos += oDadosBulk[aBulk[nBulk]]['DE']['RECNO']
						EndIf
					EndIf
				EndIf				
			EndIf

			//Produto possui somente RE
			//K292
			If (oDadosBulk[aBulk[nBulk]]:HasProperty("RE") .AND. oDadosBulk[aBulk[nBulk]]['RE']['QUANT'] != NIL) .And.;
				!(oDadosBulk[aBulk[nBulk]]:HasProperty("DE") .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] != NIL)
				
				//Validar tipo
				If oSB1[aBulk[nBulk]]["TIPO"] $ ""+cTipo00+"|"+cTipo01+"|"+cTipo02+"|"+cTipo03+"|"+cTipo04+"|"+cTipo05+"|"+cTipo10+""
					oBulkSVW:addData({cChamada,cSVWFilial,STR(cMes,2),STR(cAno,4),'K292',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['RE']['QUANT']})  
					cRecnos += oDadosBulk[aBulk[nBulk]]['RE']['RECNO']
				EndIf
			EndIf

			//Produto possui somente DE
			//K291
			If (oDadosBulk[aBulk[nBulk]]:HasProperty("DE") .AND. oDadosBulk[aBulk[nBulk]]['DE']['QUANT'] != NIL) .And.;
				!(oDadosBulk[aBulk[nBulk]]:HasProperty("RE") .AND. oDadosBulk[aBulk[nBulk]]['RE']['QUANT'] != NIL)
				
				//Validar tipo
				If oSB1[aBulk[nBulk]]["TIPO"] $ ""+cTipo03+"|"+cTipo04+"" 
					oBulkSVV:addData({cChamada,cSVVFilial,STR(cMes,2),STR(cAno,4),'K291',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['DE']['QUANT']*-1})
					cRecnos += oDadosBulk[aBulk[nBulk]]['DE']['RECNO']
				EndIf
			EndIf
			
			//Produto possui PR
			//K291
			If oDadosBulk[aBulk[nBulk]]:HasProperty("PR") .AND. oDadosBulk[aBulk[nBulk]]['PR']['QUANT'] != NIL                         
				
				//Validar tipo
				If oSB1[aBulk[nBulk]]["TIPO"] $ ""+cTipo03+"|"+cTipo04+"" 
					oBulkSVV:addData({cChamada,cSVVFilial,STR(cMes,2),STR(cAno,4),'K291',cOp,aBulk[nBulk],oDadosBulk[aBulk[nBulk]]['PR']['QUANT']})  			                  
					cRecnos += oDadosBulk[aBulk[nBulk]]['PR']['RECNO']
				EndIf
			EndIf
		Next nBulk

		oBulkSVV:Flush()
		oBulkSVW:Flush()		
		
		//executa update para marcar d3_perblk
		If !Empty(cRecnos)
			cRecnos := left(cRecnos,len(cRecnos)-1)
			cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
						" 	WHERE R_E_C_N_O_ IN ("+cRecnos+")" 
		
			MATExecQry(cQuery )
		EndIf
		FwFreeObj(oDadosBulk)
	EndIf	

Next nOp

oBulkSVW:Close()
oBulkSVW:Destroy()
oBulkSVV:Close()
oBulkSVV:Destroy()
FwFreeObj(oBulkSVW)

fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)

fLimpezaDic()

Return 

/*/{Protheus.doc} fGravaK292
	Grava a SVW
	@type  Static Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
/*/
Static Function fGravaK292(cAliK292,cSVWFilial,cMes,cAno,cChamada)	

	ProcLogAtu('PCP K292',"PCP K292 - Cria tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	//******************************************
	// Grava tabela tempor·ria para rodar o SPED
	//******************************************
	SVW->(dbSetOrder(1))
	SVW->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)))
	While SVW->(!Eof()) .And. SVW->VW_FILIAL == cSVWFilial .And. SVW->VW_MESSPED == STR(cMes,2) .And. SVW->VW_ANOSPED == STR(cAno,4)
		If SVW->VW_PRGORI == cChamada
			If SVW->VW_QUANT > 0
				Reclock(cAliK292,.T.)
				(cAliK292)->FILIAL     := SVW->VW_FILIAL
				(cAliK292)->REG        := "K292"
				(cAliK292)->COD_DOC_OP := SVW->VW_OP
				(cAliK292)->COD_ITEM   := SVW->VW_PRODUTO
				(cAliK292)->QTD        := SVW->VW_QUANT
				(cAliK292)->(MsUnLock())
				nRegsto++
			Else
				RecLock("SVW", .F.)
				SVW->(DBDelete())
				SVW->(MsUnLock())
			EndIf
		EndIf
		SVW->(dbSkip())
	EndDo
	MsUnlock()
Return 

/*/{Protheus.doc} fLimpezaDic
	Limpeza de dicion·rio
	@type  Static Function
	@author mauricio.joao
	@since 24/08/2022
	@version 1.0
/*/
Static Function fLimpezaDic()
Local cQuery := ""

ProcLogAtu('PCP K291 E K292',"PCP K291 E K292 - Limpeza de dicion·rio    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

// limpa registros deletados
cQuery := " DELETE FROM " + RetSqlName("SVU") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVW") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("SVS") + " WHERE D_E_L_E_T_ = '*' AND VS_FILIAL ='"+xFilial("SVS")+"' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("SVT") + " WHERE D_E_L_E_T_ = '*' AND VT_FILIAL ='"+xFilial("SVT")+"' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4G") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

cQuery := " DELETE FROM " + RetSqlName("T4E") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4F") + " WHERE D_E_L_E_T_ = '*' "
MATExecQry(cQuery)

ProcLogAtu('PCP K291 E K292',"PCP K291 E K292 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
Return



/*/{Protheus.doc} fColetaSB1
    Cria um objeto json com dados de produto (sb1).
    @type  Static Function
    @author mauricio.joao
    @since 12/08/2022
    @version 1.0
	lCpoBZTP Private da MATXSPED.
/*/
Static Function fColetaSB1()
Local oStatement
Local cQuery
Local cAliasSB1 := GetNextAlias()
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")

oSB1 := JsonObject():New()

oStatement := FWPreparedStatement():New()
cQuery := "SELECT SB1.B1_FILIAL, "
cQuery += "       SB1.B1_COD,"

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) TIPO "
Else
	cQuery += "SB1.B1_TIPO TIPO "
EndIf

cQuery += "  FROM " + RETSQLNAME("SB1") + " SB1 "	

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
						" ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
					" AND SBZ.BZ_COD     = SB1.B1_COD " +; 
					" AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
oStatement:SetQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oStatement:GetFixQuery() ),cAliasSB1) 

While (cAliasSB1)->(!Eof()) 
    
    cIndex := (cAliasSB1)->(B1_COD) 

    oSB1[cIndex] := JSonObject():New()
    oSB1[cIndex]['PRODUTO'] := (cAliasSB1)->(B1_COD)
    oSB1[cIndex]['TIPO']    := (cAliasSB1)->(TIPO)

(cAliasSB1)->(DbSkip())

EndDo

oStatement:Destroy()
FwFreeObj(oStatement)

Return .T.


/*/{Protheus.doc} fColetaSC2
    Cria um objeto json com dados de ordens de produÁ„o (sc2).
    @type  Static Function
    @author mauricio.joao
    @since 12/08/2022
    @version 1.0
/*/
Static Function fColetaSC2()
Local oStatement
Local cQuery
Local cAliasSC2 := GetNextAlias()

oSC2 := JsonObject():New()

oStatement := FWPreparedStatement():New()
cQuery := "SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD FROM " + RETSQLNAME("SC2") + " SC2 "
cQuery += " WHERE SC2.D_E_L_E_T_ = ' ' AND SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery += " AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ( 'I', ' ' )  "

oStatement:SetQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oStatement:GetFixQuery() ),cAliasSC2) 

While (cAliasSC2)->(!Eof()) 
    
    cIndex := (cAliasSC2)->(C2_NUM)+(cAliasSC2)->(C2_ITEM)+(cAliasSC2)->(C2_SEQUEN)+(cAliasSC2)->(C2_ITEMGRD)
	
    oSC2[cIndex] := cIndex

(cAliasSC2)->(DbSkip())

EndDo

oStatement:Destroy()
FwFreeObj(oStatement)

Return .T.

/*/{Protheus.doc} fColetaSD3
	Cria um objeto json com dados de movimentaÁ„o interna (sd3).
	@type  Static Function
	@author mauricio.joao
	@since 18/08/2022
	@version 1.0
/*/

Static Function fColetaSD3(dDataDe,dDataAte)
Local oPrepare  as object 
Local cAliasSD3 := GetNextAlias()	
//Local lOpFechadas := SUPERGETMV('MV_BLK290', .F., .F.) //PERFORMANCE.
Local lOpFechadas := .T. //Foi alterado na funÁ„o antigo do K290 para sempre considerar o mes corrente

oSD3 := JsonObject():New()

cQuery := " SELECT SD3.D3_FILIAL, SD3.D3_OP, SD3.R_E_C_N_O_, SD3.D3_EMISSAO, SD3.D3_COD, SD3.D3_CF, (CASE "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT * - 1) "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) "
cQuery +=                    " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT)"
cQuery +=                    " ELSE 0 "
cQuery +=                    " END) QUANT "
cQuery += " FROM " + RETSQLNAME("SD3") + " SD3 "
cQuery += " WHERE SD3.D_E_L_E_T_ = ' ' "
cQuery += " AND SD3.D3_FILIAL = '"+xFilial("SD3")+"' "
If lOpFechadas
	cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "
EndIf
cQuery += " AND SD3.D3_OP <> '' "
cQuery += " AND SD3.D3_ESTORNO = ''  "
cQuery += " AND SD3.D3_COD NOT LIKE 'MOD%' "
cQuery += " ORDER BY SD3.D3_OP, SD3.D3_COD "
    
cQuery := ChangeQuery(cQuery)

oPrepare := FWPreparedStatement():New(cQuery) 

DbUseArea(.T.,"TOPCONN",TCGENQRY(,, oPrepare:GetFixQuery() ),cAliasSD3) 

While (cAliasSD3)->(!Eof())
    cIndex := (cAliasSD3)->(D3_OP)

	If oSC2:HasProperty(cIndex)
		cRecno := CValToChar((cAliasSD3)->(R_E_C_N_O_))

		//ValidaÁ„o se o produto da movimentaÁ„o est· no filtro do oSB1
		If !oSB1:HasProperty((cAliasSD3)->(D3_COD))
			(cAliasSD3)->(DbSkip())
			Loop
		EndIf
			
		cTipo := oSB1[(cAliasSD3)->(D3_COD)]["TIPO"]

		If !oSD3:HasProperty(cIndex)
			oSD3[cIndex] := JSonObject():New()   
		EndIf

		If !oSD3[cIndex]:HasProperty(cRecno)
			oSD3[cIndex][cRecno] := JSonObject():New()
			oSD3[cIndex][cRecno]['COD']     := (cAliasSD3)->(D3_COD)
			oSD3[cIndex][cRecno]['CF']      := (cAliasSD3)->(D3_CF)
			oSD3[cIndex][cRecno]['QUANT']   := (cAliasSD3)->(QUANT)
			oSD3[cIndex][cRecno]['EMISSAO'] := (cAliasSD3)->(D3_EMISSAO)
			oSD3[cIndex][cRecno]['TIPO']    := cTipo
			oSD3[cIndex][cRecno]['RECNO']   := cRecno
		EndIf
	EndIf 	 

(cAliasSD3)->(DbSkip())

EndDo

Return .T.

/*------------------------------------------------------------------------//
//Programa:	  PROCK291 
//Autor:	  Ricardo Peixoto 
//Data:		  24/09/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K291
//Parametros: 1 - cAliK291      - Alias do arquivo de trabalho do K291
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK291(cAliK291,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSVVFilial    := xFilial("SVV")
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create
Local lREGK290NEW	:= SuperGetMV("MV_BLK290N",.F.,.F.)

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

ProcLogAtu('PCP K291',"PCP K291 - InÌcio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If lREGK290NEW .Or. ( cDadosProd == 'SBZ' .And. lCpoBZTP)
	fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)
	Return
EndIf

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("SVV") + " WHERE VV_MESSPED = '" + STR(cMes,2) + "' AND VV_ANOSPED = '" + STR(cAno,4) + "' AND VV_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K291',"PCP K291 - SQL/ORA    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

TCDelFile('VWSEL9')
	
//Busca os dados para geraÁ„o do K291
cQuery := " CREATE VIEW VWSEL9 AS "
cQuery += " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " 
cQuery += "                 WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " 
cQuery += "                 WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) "
cQuery += "            ELSE 0 END) AS QUANT, " 
cQuery += "        SD3.D3_COD, "
cQuery += "        SD3.D3_OP, " 
cQuery += "        MAX(D3_EMISSAO) AS D3_EMISSAO, " 
cQuery += "        SD3.D3_FILIAL, " 
cQuery += "        SD3.D3_PERBLK, " 
cQuery += "        SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO "
	
cUpdateD3 := " FROM " + RetSqlName("SD3") + " SD3 " 
cUpdateD3 += " JOIN " + RetSqlName("SB1") + " SB1 "
cUpdateD3 += "   ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cUpdateD3 += "  AND SB1.B1_COD     = SD3.D3_COD " 
cUpdateD3 += "  AND SB1.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "  AND SB1.B1_TIPO IN ("+cTipo03+","+cTipo04+") "
	
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " 
	cUpdateD3 += "   ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' "
	cUpdateD3 += "  AND SBZ.BZ_COD     = SB1.B1_COD " 
	cUpdateD3 += "  AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
	
cUpdateD3 += " JOIN " + RetSqlName("SC2") + " SC2 "					  
cUpdateD3 += "   ON SD3.D3_OP      = SC2.C2_OP "				
cUpdateD3 += "  AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " 
cUpdateD3 += "  AND SC2.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "  AND SC2.C2_ITEM   <> 'OS' " 
cUpdateD3 += "  AND SC2.C2_TPPR   IN ('I',' ') " 
cUpdateD3 += " JOIN " + RetSqlName("SB1") + " SB1_OP " 
cUpdateD3 += "   ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cUpdateD3 += "  AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " 
cUpdateD3 += "  AND SB1_OP.D_E_L_E_T_ = ' ' "
	          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " 
	cUpdateD3 += "  ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " 
	cUpdateD3 += " AND SBZ_OP.BZ_COD     = SB1.B1_COD " 
	cUpdateD3 += " AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF
	
cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' "
cUpdateD3 += "   AND SD3.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "   AND SD3.D3_OP     <> ' ' " 
cUpdateD3 += "   AND (SD3.D3_CF  LIKE ('PR%') "
cUpdateD3 += "       OR SD3.D3_CF  LIKE ('DE%') " 
cUpdateD3 += "       OR SD3.D3_CF  LIKE ('RE%')) " 
cUpdateD3 += "   AND SB1.B1_CCCUSTO = ' ' " 
cUpdateD3 += "   AND SB1.B1_COD NOT LIKE 'MOD%' " 
cUpdateD3 += "   AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cUpdateD3 += "   AND SD3.D_E_L_E_T_ = ' ' " 
	            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cUpdateD3 += " AND SB1.B1_TIPO "
EndIf
	
cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " 
cUpdateD3 += " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cUpdateD3 += " AND SB1_OP.B1_TIPO "
EndIf
	
cUpdateD3 += "  IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cUpdateD3 += " AND (SELECT MIN(QUANT) "
cUpdateD3 += "        FROM (SELECT Sum(CASE "
cUpdateD3 += "                            WHEN SD3C.D3_CF LIKE ( 'DE%' ) THEN ( SD3C.D3_QUANT *- 1 ) " 
cUpdateD3 += "                            WHEN SD3C.D3_CF LIKE ( 'RE%' ) THEN ( SD3C.D3_QUANT ) " 
cUpdateD3 += "                         ELSE 0 "
cUpdateD3 += "                         END) AS QUANT, " 
cUpdateD3 += "                     SD3C.D3_COD, " 
cUpdateD3 += "                     SD3C.D3_OP " 
cUpdateD3 += "                FROM " +RetSqlName("SD3") + " SD3C " 
cUpdateD3 += "                JOIN "+RetSqlName("SB1") + " SB1 " 
cUpdateD3 += "                  ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " 
cUpdateD3 += "                 AND SB1.B1_COD = SD3C.D3_COD " 
cUpdateD3 += "                 AND SB1.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "                 AND SB1.B1_TIPO IN ("+cTipo03+","+cTipo04+") "
cUpdateD3 += "                JOIN "+RetSqlName("SC2") + " SC2 " 
cUpdateD3 += "                  ON SD3C.D3_OP = SC2.C2_OP "
cUpdateD3 += "                 AND SC2.C2_FILIAL = '" + xFilial('SC2') + "' " 
cUpdateD3 += "                 AND SC2.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "                 AND SC2.C2_ITEM <> 'OS' " 
cUpdateD3 += "                 AND SC2.C2_TPPR IN ( 'I', ' ' ) " 
cUpdateD3 += "                JOIN "+RetSqlName("SB1") + " SB1_OP " 
cUpdateD3 += "                  ON SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " 
cUpdateD3 += "                 AND SB1_OP.B1_COD = SC2.C2_PRODUTO " 
cUpdateD3 += "                 AND SB1_OP.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "               WHERE SD3C.D3_FILIAL = '" + xFilial('SD3') + "' " 
cUpdateD3 += "                 AND SD3C.D3_COD <> SC2.C2_PRODUTO " 
cUpdateD3 += "                 AND SD3C.D_E_L_E_T_ = ' ' " 
cUpdateD3 += "                 AND SD3C.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " 
cUpdateD3 += "                 AND SD3C.D3_OP = SD3.D3_OP " 
cUpdateD3 += "               GROUP BY SD3C.D3_OP, " 
cUpdateD3 += "                        SD3C.D3_COD, " 
cUpdateD3 += "                        SD3C.D3_FILIAL ) ORDEM ) < 0 "
cUpdateD3 += " AND SD3.D3_ESTORNO <> 'S' "

If TCGetDB() $ "ORACLE" 
	cUpdateD3 := " FROM "+;
		"  (SELECT D3_COD,    "+;
		"         D3_OP,"+;
		"		  D3_CF,"+;
		"		  D3_QUANT,"+;
		"		  D3_EMISSAO,"+;
		"		  D3_FILIAL,"+;
		"		  D3_PERBLK,"+;
		"		  D3_ESTORNO,"+;
		"          R_E_C_N_O_"+;
		"   FROM "+RetSqlName("SD3")+" SD3 "+;
		"   WHERE D_E_L_E_T_ = ' ' "+;
		"     AND D3_FILIAL = '" + xFilial('SD3') + "' "+;
		"     AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "+; 		
		"     AND D_E_L_E_T_ = ' ' "+;
		"     AND D3_OP <> ' ' "+;
		"     AND (D3_CF LIKE ('PR%') "+;
		"          OR D3_CF LIKE ('DE%') "+;
		"          OR D3_CF LIKE ('RE%')) "+;
		"     AND D3_ESTORNO <> 'S' ) SD3 "+;
		"JOIN "

		cUpdateD3 += "   (SELECT B1_COD "+;
		"   FROM "+RetSqlName("SB1")+" SB1"+;
		"   WHERE B1_FILIAL = '" + xFilial('SB1') + "'  "+;
		"     AND D_E_L_E_T_ = ' ' "+;
		"     AND B1_CCCUSTO = ' ' "+;
		"     AND B1_COD NOT LIKE 'MOD%' "+;
		"     AND B1_TIPO IN ("+cTipo03+", "+;
		"                     "+cTipo04+") ) SB1 ON SB1.B1_COD = SD3.D3_COD "+;
		"JOIN "

		cUpdateD3 += "  (SELECT C2_PRODUTO, SC2.C2_NUM"+ cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AS C2_OP"+;
		"   FROM "+RetSqlName("SC2")+" SC2 "+;
		"   WHERE C2_FILIAL = '" + xFilial('SC2') + "'  "+;
		"     AND D_E_L_E_T_ = ' ' "+;
		"     AND C2_ITEM <> 'OS' "+;
		"     AND C2_TPPR IN ('I', "+;
		"                     ' ') ) SC2 ON SD3.D3_OP = SC2.C2_OP "+;
		"JOIN "

		cUpdateD3 += "  (SELECT B1_COD "+;
		"   FROM "+RetSqlName("SB1")+" SB1 "+;
		"   WHERE D_E_L_E_T_ = ' ' "+;
		"     AND B1_FILIAL = '" + xFilial('SB1') + "'  "+;
		"     AND B1_CCCUSTO = ' ' "+;
		"     AND B1_COD NOT LIKE 'MOD%' "+;
		"      AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+")) SB1_OP1 ON SB1_OP1.B1_COD = SC2.C2_PRODUTO "+;	
		"JOIN "

		cUpdateD3 += "  (SELECT SD3C.D3_OP, "+;
		"          Min(QUANT) "+;
		"   FROM "+;
		"     (SELECT Sum(CASE "+;
		"                     WHEN D3_CF LIKE ('DE%') THEN (D3_QUANT *- 1) "+;
		"                     WHEN D3_CF LIKE ('RE%') THEN (D3_QUANT) "+;
		"                     ELSE 0 "+;
		"                 END) AS QUANT, "+;
		"             D3_COD, "+;
		"             D3_OP "+;
		"      FROM "+RetSqlName("SD3")+" SD3 "+;
		"      WHERE D3_FILIAL = '" + xFilial('SD3') + "'  "+;
		"        AND D_E_L_E_T_ = ' ' GROUP  BY D3_OP, "+;
		"                                        D3_COD, "+;
		"                                        D3_FILIAL ) SD3C "+;
		"   JOIN "

		cUpdateD3 += "     (SELECT B1_COD "+;
		"      FROM "+RetSqlName("SB1")+" SB1 "+;
		"      WHERE D_E_L_E_T_ = ' ' "+;
		"        AND B1_FILIAL = '" + xFilial('SB1') + "' ) SB1 ON SB1.B1_COD = SD3C.D3_COD "+;
		"   JOIN "

		cUpdateD3 += "  (SELECT C2_PRODUTO, SC2.C2_NUM"+ cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AS C2_OP "+;
		"      FROM "+RetSqlName("SC2")+" SC2 "+;
		"      WHERE C2_FILIAL = '" + xFilial('SC2') + "'  "+;
		"        AND D_E_L_E_T_ = ' ' "+;
		"        AND C2_ITEM <> 'OS' "+;
		"        AND C2_TPPR IN ('I', "+;
		"                        ' ') ) SC2_2 ON SD3C.D3_OP = SC2_2.C2_OP "+;
		"   JOIN "

		cUpdateD3 += "     (SELECT B1_COD "+;
		"      FROM "+RetSqlName("SB1")+" SB1 "+;
		"      WHERE B1_FILIAL = '" + xFilial('SB1') + "' "+;
		"        AND D_E_L_E_T_ = ' ' ) SB1_OP_2 ON SB1_OP_2.B1_COD = SC2_2.C2_PRODUTO "+;
		"   AND SD3C.D3_COD <> SC2_2.C2_PRODUTO "+;
		"   GROUP BY SD3C.D3_OP "+;
		"   HAVING Min(QUANT) < 0) SD3_NEGAT ON SD3.D3_OP = SD3_NEGAT.D3_OP  "
	ENDIF
	
	cQuery += cUpdateD3 //compartilha where para update e select
	cQuery += " GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO "          
	
	cQuery += " HAVING (Sum(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT * -1) ELSE 0 END)) <> 0 "
	

	ProcLogAtu('PCP K291',"PCP K291 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " +;
				" 	WHERE R_E_C_N_O_ IN " +;
				" (SELECT SD3.R_E_C_N_O_ " + cUpdateD3 + " ) "	
	
	MATExecQry(cUpdateD3) 
	
	ProcLogAtu('PCP K291',"PCP K291 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K291',"PCP K291 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP " +;
				" FROM VWSEL9 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K291',"PCP K291 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//Carrega as filiais uma ˙nica vez
	cSVVFilial := xFilial("SVV")
	
	While !(cAliasTmp)->(Eof())
		
		//grava tabela fÌsica para guardar histÛrico
		SVV->(dbSetOrder(1))
		If !SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		
			//************************************************************************
			// Bloco K291
			//************************************************************************
			Reclock("SVV",.T.)
			SVV->VV_PRGORI  := cChamada
			SVV->VV_FILIAL  := cSVVFilial
			SVV->VV_MESSPED := STR(cMes,2)
			SVV->VV_ANOSPED := STR(cAno,4)
			SVV->VV_REG     := "K291"
			SVV->VV_OP      := (cAliasTmp)->D3_OP
			SVV->VV_PRODUTO := (cAliasTmp)->D3_COD
			SVV->VV_QUANT   := (cAliasTmp)->QUANT
			SVV->(MsUnlock())
			
		Else
			//************************************************************************
			// Bloco K291 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************
			SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While SVV->(!Eof()) .And. SVV->VV_FILIAL == cSVVFilial .And. SVV->VV_MESSPED == STR(cMes,2) .And. SVV->VV_ANOSPED == STR(cAno,4) .And. SVV->VV_OP == (cAliasTmp)->D3_OP .And. SVV->VV_PRODUTO == (cAliasTmp)->D3_COD .And. SVV->VV_PRGORI == cChamada
		    	RecLock("SVV",.F.,.T.)		    	
		    	SVV->VV_QUANT += (cAliasTmp)->QUANT
		    	SVV->(MsUnlock())
				SVV->(dbSkip())
		    EndDo
		
		EndIf
		
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())

	TCDelFile('VWSEL9')

fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)

fLimpezaDic()

Return

/*/{Protheus.doc} fGravaK291
	@type  Static Function
	@author user
	@since 24/08/2022
	@version 1.0
/*/
Static Function fGravaK291(cAliK291,cSVVFilial,cMes,cAno,cChamada)

	ProcLogAtu('PCP K291',"PCP K291 - Cria tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

	//******************************************
	// Grava tabela tempor·ria para rodar o SPED
	//******************************************
	SVV->(dbSetOrder(1))
	SVV->(dbSeek(cSVVFilial+STR(cMes,2)+STR(cAno,4)))
	While SVV->(!Eof()) .And. SVV->VV_FILIAL == cSVVFilial .And. SVV->VV_MESSPED == STR(cMes,2) .And. SVV->VV_ANOSPED == STR(cAno,4)
		If SVV->VV_PRGORI == cChamada
			If SVV->VV_QUANT > 0
				Reclock(cAliK291,.T.)
				(cAliK291)->FILIAL     := SVV->VV_FILIAL
				(cAliK291)->REG        := "K291"
				(cAliK291)->COD_DOC_OP := SVV->VV_OP
				(cAliK291)->COD_ITEM   := SVV->VV_PRODUTO
				(cAliK291)->QTD        := SVV->VV_QUANT
				(cAliK291)->(MsUnLock())
				nRegsto++
			Else
				RecLock("SVV", .F.)
				SVV->(DBDelete())
				SVV->(MsUnLock())
			EndIf
		EndIf
		SVV->(dbSkip())
	EndDo
	MsUnlock()
Return 


/*------------------------------------------------------------------------//
//Programa:	  PROCK275
//Autor:	  Ricardo Peixoto 
//Data:		  05/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K275
//            CorreÁıes: K235, K265
//Parametros: 1 - cAliK275      - Alias do arquivo de trabalho do K275
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK275PRO(cAliK275,dDataDe,dDataAte,lRepross,cAliK280)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cT4HFilial    := ""
Local cSVKFilial    := ""
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local nSaldo		:= 0
Local cChamada   	:= If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")

cK275Ali := cAliK275

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

//Tabela para o perÌodo j· limpa.

ProcLogAtu('PCP K275',"PCP K275 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

TCDelFile('VWSEL1')
	
//Busca os dados para geraÁ„o do K275
cQuery := " CREATE VIEW VWSEL1 AS "
cQuery += " SELECT SD3_SD4_1.BLOCO,  " 
cQuery += "        SD3_SD4_1.QUANT, " 
cQuery += "        SD3_SD4_1.D3_COD, "
cQuery += "        SD3_SD4_1.D3_OP, "
cQuery += "        SD3_SD4_1.D3_EMISSAO, "
cQuery += "        SD3_SD4_1.D3_FILIAL, "
cQuery += "        SD3_SD4_1.D3_PERBLK, "
cQuery += "        SD3_SD4_1.SD3RECNO, "
cQuery += "        SD3_SD4_1.D3_CF, "
cQuery += "        SD3_SD4_1.D4_PRDORG, "
cQuery += "        SC2_1.C2_PRODUTO "
cQuery += "   FROM (SELECT SD3_1.BLOCO,  "
cQuery += "                SD3_1.QUANT,  "
cQuery += "                SD3_1.D3_COD,  "
cQuery += "                SD3_1.D3_OP,  " 
cQuery += "                SD3_1.D3_EMISSAO,  "
cQuery += "                SD3_1.D3_FILIAL,  "
cQuery += "                SD3_1.D3_PERBLK,  " 
cQuery += "                SD3_1.SD3RECNO,  " 
cQuery += "                SD3_1.D3_CF, "
cQuery += "                SD4_1.D4_PRDORG " 
cQuery += "           FROM (SELECT 'K235' AS BLOCO, "
cQuery += "                        SUM(CASE " 
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) " 
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'ER%' ) THEN ( SD3.D3_QUANT * -1 )  "
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'PR%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += "                        ELSE 0 " 
cQuery += "                        END) AS QUANT, " 
cQuery += "                        D3_COD,  "
cQuery += "                        D3_OP,  " 
										
						           If(TCGetDB() $ "ORACLE/DB2/400/INFORMIX")
cQuery += "                      		MAX(D3_EMISSAO) AS D3_EMISSAO, " 
                                   Else
cQuery += "								Cast(Max(D3_EMISSAO) AS CHAR(8)) AS D3_EMISSAO, "
                                   EndIf
									   	
cQuery += " 					   D3_FILIAL,  "
cQuery += "                        D3_PERBLK,  " 
cQuery += "                        R_E_C_N_O_ AS SD3RECNO, "
cQuery += "                        D3_CF,  "
cQuery += "                        D3_TRT,  "
cQuery += "                        D3_LOTECTL,  "
cQuery += "                        D3_NUMLOTE,  "
cQuery += "                        D3_LOCAL,  "
cQuery += "                        D3_ORDEM  "
cQuery += "                   FROM " + RetSqlName("SD3") + " SD3 " 
cQuery += "                  WHERE D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += "                    AND D_E_L_E_T_ = ' '  "
cQuery += "                    AND D3_OP <> ' ' "
cQuery += "                    AND ( D3_CF LIKE 'RE%' " 
cQuery += "                          OR D3_CF LIKE 'DE%' " 
cQuery += "                          OR D3_CF LIKE 'ER%' " 
cQuery += "                          OR D3_CF LIKE 'PR%' ) " 
cQuery += "                    AND (D3_EMISSAO < '" + DtoS(dDataDe) + "' "
cQuery += "                         AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' "
cQuery += "                              OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " 
cQuery += "                    AND D3_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
cQuery += "                    AND D_E_L_E_T_ = ' ' " 
cQuery += "                    AND ( D3_OP NOT IN (SELECT D4_OP " 
cQuery += "                                          FROM " + RetSqlName("SD4") + " SD4 " 
cQuery += "                                         WHERE D4_FILIAL = '" + xFilial('SD4') + "' " 
cQuery += "                                           AND D_E_L_E_T_ = ' ' " 
cQuery += "                                           AND D4_QTDEORI < 0 ))  "
cQuery += "                  GROUP BY D3_OP, "
cQuery += "                           D3_COD, "
cQuery += "                           D3_FILIAL, "
cQuery += "                           D3_PERBLK, "
cQuery += "                           R_E_C_N_O_, "
cQuery += "                           D3_CF, "
cQuery += "                           D3_TRT, "
cQuery += "                           D3_LOTECTL, "
cQuery += "                           D3_NUMLOTE, "
cQuery += "                           D3_LOCAL, "
cQuery += "                           D3_ORDEM) SD3_1 " 
cQuery += "   LEFT OUTER JOIN (SELECT D4_FILIAL, " 
cQuery += " 					      D4_COD, " 
cQuery += "                           D4_OP, " 
cQuery += "                           D4_TRT, "
cQuery += "                           D4_LOTECTL, " 
cQuery += "                           D4_NUMLOTE, " 
cQuery += "                           D4_LOCAL, "
cQuery += "                           D4_ORDEM, "
cQuery += "                           D4_PRDORG "
cQuery += "                      FROM " + RetSqlName("SD4") + " " 
cQuery += "                     WHERE D_E_L_E_T_ = ' ' ) SD4_1 " 
cQuery += "     ON SD4_1.D4_FILIAL = SD3_1.D3_FILIAL " 
cQuery += "    AND SD4_1.D4_COD     = SD3_1.D3_COD " 
cQuery += "    AND SD4_1.D4_OP      = SD3_1.D3_OP " 
cQuery += "    AND SD4_1.D4_TRT     = SD3_1.D3_TRT "  
cQuery += "    AND SD4_1.D4_LOTECTL = SD3_1.D3_LOTECTL " 
cQuery += "    AND SD4_1.D4_NUMLOTE = SD3_1.D3_NUMLOTE " 
cQuery += "    AND SD4_1.D4_LOCAL   = SD3_1.D3_LOCAL "
cQuery += "    AND SD4_1.D4_ORDEM   = SD3_1.D3_ORDEM ) SD3_SD4_1 "
cQuery += "   JOIN (SELECT B1_COD " 
cQuery += "           FROM " + RetSqlName("SB1") + " SB1 " 

		If cDadosProd == 'SBZ' .And. lCpoBZTP
			cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	       			         " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	          		        " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	          		        " AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf

cQuery += "          WHERE B1_CCCUSTO = ' '  " 
cQuery += "            AND B1_COD NOT LIKE 'MOD%' " 

//cQuery += "            AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf
cQuery += "	IN  ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 

cQuery += "            AND SB1.B1_FILIAL  = '" + xFilial('SB1') + "' "
cQuery += "            AND SB1.D_E_L_E_T_ = ' ') SB1_SD3_1 " 

cQuery += "     ON SB1_SD3_1.B1_COD = SD3_SD4_1.D3_COD " 						
cQuery += "   JOIN (SELECT C2_PRODUTO, C2_OP AS C2_OP "
cQuery += "           FROM " + RetSqlName("SC2") + " SC2 " 
cQuery += "          WHERE C2_FILIAL  = '" + xFilial('SC2') + "' "
cQuery += "            AND D_E_L_E_T_ = ' '  " 
cQuery += "            AND C2_ITEM <> 'OS' " 
cQuery += "            AND C2_TPPR IN ('I', ' ')) SC2_1 " 
cQuery += "     ON SD3_SD4_1.D3_OP = SC2_1.C2_OP " 
cQuery += "   JOIN (SELECT B1_COD " 
cQuery += "           FROM " + RetSqlName("SB1") + " SB1_OP " 

		If cDadosProd == 'SBZ' .And. lCpoBZTP
			cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	       			         " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	          		        " AND SBZ.BZ_COD     = SB1_OP.B1_COD " +; 
	          		        " AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf

cQuery += "          WHERE B1_CCCUSTO = ' '  "
cQuery += "            AND B1_COD NOT LIKE 'MOD%' " 

//cQuery += "            AND B1_TIPO IN ("+cTipo03+","+cTipo04+") "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO) "
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "	IN  ("+cTipo03+","+cTipo04+") "

cQuery += "            AND SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' " 
cQuery += "            AND SB1_OP.D_E_L_E_T_ = ' ') SB1_OP_1 "
cQuery += "     ON SC2_1.C2_PRODUTO = SB1_OP_1.B1_COD "
cQuery += " UNION " 
cQuery += " SELECT SD3_SD4_1.BLOCO, "
cQuery += "        SD3_SD4_1.QUANT, " 
cQuery += "        SD3_SD4_1.D3_COD, "
cQuery += "        SD3_SD4_1.D3_OP, " 
cQuery += "        SD3_SD4_1.D3_EMISSAO, " 
cQuery += "        SD3_SD4_1.D3_FILIAL, "
cQuery += "        SD3_SD4_1.D3_PERBLK, " 
cQuery += "        SD3_SD4_1.SD3RECNO, " 
cQuery += "        SD3_SD4_1.D3_CF, " 
cQuery += "        SD3_SD4_1.D4_PRDORG, " 
cQuery += "        SC2_1.C2_PRODUTO " 
cQuery += "   FROM (SELECT SD3_1.BLOCO, " 
cQuery += "                SD3_1.QUANT, "
cQuery += "                SD3_1.D3_COD, "
cQuery += "                SD3_1.D3_OP, "
cQuery += "                SD3_1.D3_EMISSAO, "
cQuery += "                SD3_1.D3_FILIAL, "
cQuery += "                SD3_1.D3_PERBLK, " 
cQuery += "                SD3_1.SD3RECNO, " 
cQuery += "                SD3_1.D3_CF, " 
cQuery += "                SD4_1.D4_PRDORG " 
cQuery += "           FROM (SELECT 'K265' AS BLOCO, " 
cQuery += "                        SUM(CASE "
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'RE%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'ER%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "                        WHEN SD3.D3_CF LIKE ( 'PR%' ) THEN ( SD3.D3_QUANT ) " 
cQuery += "                        ELSE 0 " 
cQuery += "                        END) AS QUANT, "
cQuery += "                        D3_COD, "
cQuery += "                        D3_OP, " 

                                   If(TCGetDB() $ "ORACLE/DB2/400/INFORMIX")
cQuery += 								" MAX(D3_EMISSAO) AS D3_EMISSAO, " 
                                   Else
cQuery += 						   		" Cast(Max(D3_EMISSAO) AS CHAR(8)) AS D3_EMISSAO, "
                                   EndIf

cQuery += "                        D3_FILIAL, "
cQuery += "                        D3_PERBLK, "
cQuery += "                        R_E_C_N_O_  AS SD3RECNO, "
cQuery += "                        D3_CF, "
cQuery += "                        D3_TRT, "
cQuery += "                        D3_LOTECTL, "
cQuery += "                        D3_NUMLOTE, "
cQuery += "                        D3_LOCAL, " 
cQuery += "                        D3_ORDEM " 
cQuery += "                   FROM " + RetSqlName("SD3") + " SD3 "
cQuery += "                  WHERE D3_FILIAL = '" + xFilial('SD3') + "' " 
cQuery += "                    AND D_E_L_E_T_ = ' '  "
cQuery += "                    AND D3_OP <> ' ' " 
cQuery += "                    AND (D3_CF LIKE 'RE%' " 
cQuery += "                         OR D3_CF LIKE 'DE%' " 
cQuery += "                         OR D3_CF LIKE 'ER%' " 
cQuery += "                         OR D3_CF LIKE 'PR%' ) " 
cQuery += "                    AND (D3_EMISSAO < '" + DtoS(dDataDe) + "' " 
cQuery += "                         AND (D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' "
cQuery += "                              OR D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " 
cQuery += "                    AND D3_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
cQuery += "                    AND D_E_L_E_T_ = ' '  " 
cQuery += "                  GROUP BY D3_OP, "
cQuery += "                           D3_COD, "
cQuery += "                           D3_FILIAL, "
cQuery += "                           D3_PERBLK, "
cQuery += "                           R_E_C_N_O_, "
cQuery += "                           D3_CF, "
cQuery += "                           D3_TRT, "
cQuery += "                           D3_LOTECTL, "
cQuery += "                           D3_NUMLOTE, "
cQuery += "                           D3_LOCAL, "
cQuery += "                           D3_ORDEM) SD3_1 " 
cQuery += "          LEFT OUTER JOIN (SELECT D4_FILIAL, " 
cQuery += "                                  D4_COD, "
cQuery += "                                  D4_OP, "
cQuery += "                                  D4_TRT, "
cQuery += "                                  D4_LOTECTL, "
cQuery += "                                  D4_NUMLOTE, " 
cQuery += "                                  D4_LOCAL, "
cQuery += "                                  D4_ORDEM, "
cQuery += "                                  D4_PRDORG "
cQuery += "                             FROM " + RetSqlName("SD4") + " " 
cQuery += "                            WHERE D_E_L_E_T_ = ' ' ) SD4_1 " 
cQuery += "                       ON SD4_1.D4_FILIAL  = SD3_1.D3_FILIAL " 
cQuery += "                      AND SD4_1.D4_COD     = SD3_1.D3_COD " 
cQuery += "                      AND SD4_1.D4_OP      = SD3_1.D3_OP " 
cQuery += "                      AND SD4_1.D4_TRT     = SD3_1.D3_TRT " 
cQuery += "                      AND SD4_1.D4_LOTECTL = SD3_1.D3_LOTECTL " 
cQuery += "                      AND SD4_1.D4_NUMLOTE = SD3_1.D3_NUMLOTE " 
cQuery += "                      AND SD4_1.D4_LOCAL   = SD3_1.D3_LOCAL "
cQuery += "                      AND SD4_1.D4_ORDEM   = SD3_1.D3_ORDEM ) SD3_SD4_1 "
cQuery += "   JOIN (SELECT B1_COD " 
cQuery += "           FROM " + RetSqlName("SB1") + " SB1 " 

		If cDadosProd == 'SBZ' .And. lCpoBZTP
			cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	       			         " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	          		        " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	          		        " AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf

cQuery += "          WHERE B1_CCCUSTO = ' ' " 
cQuery += "            AND B1_COD NOT LIKE 'MOD%' "

//cQuery += "            AND B1_TIPO IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf
cQuery += "	IN  ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") " 

cQuery += "            AND SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "            AND SB1.D_E_L_E_T_ = ' ') SB1_SD3_1 " 
cQuery += "     ON SB1_SD3_1.B1_COD = SD3_SD4_1.D3_COD " 		
cQuery += "   JOIN (SELECT C2_PRODUTO, C2_OP AS C2_OP "
cQuery += "           FROM " + RetSqlName("SC2") + " SC2 "
cQuery += "          WHERE C2_FILIAL = '" + xFilial('SC2') + "' " 
cQuery += "            AND D_E_L_E_T_ = ' ' "
cQuery += "            AND C2_ITEM <> 'OS' " 
cQuery += "            AND C2_TPPR IN ( 'R' ) ) SC2_1 "
cQuery += "     ON SD3_SD4_1.D3_OP = SC2_1.C2_OP "
cQuery += "   JOIN (SELECT B1_COD " 
cQuery += "           FROM " + RetSqlName("SB1") + " SB1_OP " 

		If cDadosProd == 'SBZ' .And. lCpoBZTP
			cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	       			         " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	          		        " AND SBZ.BZ_COD     = SB1_OP.B1_COD " +; 
	          		        " AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf

cQuery += "          WHERE B1_CCCUSTO = ' ' " 
cQuery += "            AND B1_COD NOT LIKE 'MOD%' " 

//cQuery += "            AND B1_TIPO IN ("+cTipo03+","+cTipo04+") " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1_OP.B1_TIPO) "
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "	IN  ("+cTipo03+","+cTipo04+") " 

cQuery += "            AND SB1_OP.B1_FILIAL = '" + xFilial('SB1') + "' "
cQuery += "            AND SB1_OP.D_E_L_E_T_ = ' ') SB1_OP_1 " 
cQuery += "     ON SC2_1.C2_PRODUTO = SB1_OP_1.B1_COD "

//cQuery := ChangeQuery(cQuery) 
MATExecQry(cQuery)

cQuery := " SELECT BLOCO, "
cQuery += "        QUANT, "
cQuery += "        D3_COD, "
cQuery += "        D3_OP, "
cQuery += "        D3_EMISSAO, "
cQuery += "        D3_FILIAL, "
cQuery += "        D3_PERBLK, "
cQuery += "        SD3RECNO, "
cQuery += "        D3_CF, "
cQuery += "        D4_PRDORG, "
cQuery += "        C2_PRODUTO "
cQuery += "   FROM VWSEL1 "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
ProcLogAtu('PCP K275',"PCP K275 - Montagem query 1    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
While !(cAliasTmp)->(Eof()) //mantida leitura geral para marcar PERBLK
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo
	
(cAliasTmp)->(dbCloseArea())
	

ProcLogAtu('PCP K275',"PCP K275 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
//varre view para otimizar calculo de quantidades
cQuery := "	SELECT BLOCO, " 
cQuery += "		   SUM(QUANT) QUANT2, " 
cQuery += "		   D3_OP, " 
cQuery += "		   D3_COD, " 
cQuery += "		   MIN(D3_EMISSAO) D3_EMISSAO, " 
cQuery += "		   MIN(D3_FILIAL)  D3_FILIAL, " 
cQuery += "		   MIN(C2_PRODUTO) C2_PRODUTO, " 
cQuery += "		   ' '             D4_PRDORG, " 
cQuery += "		   D3_CF "
cQuery += "	  FROM VWSEL1 " 
cQuery += "	 GROUP BY D3_OP, " 
cQuery += "		      D3_COD, " 
cQuery += "			  BLOCO, "
cQuery += "			  D3_CF "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
//Carrega as filiais uma ˙nica vez
cT4HFilial := xFilial("T4H")
cSVKFilial := xFilial("SVK")
	
ProcLogAtu('PCP K275',"PCP K275 - Finalizando buscas    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
While !(cAliasTmp)->(Eof())
		
	//grava tabela fÌsica para guardar histÛrico
	T4H->(dbSetOrder(2))
	If !T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
		
		// nao cria 275 para RE
		SVK->(dbSetOrder(2))
		If (!SVK->(dbSeek(cSVKFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD)) .AND. !SVK->(dbSeek(cSVKFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO))) .Or. (cAliasTmp)->D3_CF == "ER0" 
		
			//************************************************************************
			// Bloco K275 para componentes e acabado. N„o cria para produto retrabalho
			//************************************************************************
			Reclock("T4H",.T.)
			T4H->T4H_PRGORI  := cChamada
			T4H->T4H_FILIAL := cT4HFilial //chave
			T4H->T4H_MESSPE := STR(cMes,2)
			T4H->T4H_ANOSPE := STR(cAno,4)
			T4H->T4H_REG    := "K275"
			T4H->T4H_PRODUT := (cAliasTmp)->D3_COD
			If (cAliasTmp)->QUANT2 >= 0
				T4H->T4H_QTD_PO := (cAliasTmp)->QUANT2
			Else
				T4H->T4H_QTD_NE := (cAliasTmp)->QUANT2 * -1
			EndIf

			If (cAliasTmp)->BLOCO == "K235" .Or. (cAliasTmp)->BLOCO == "K255"
				T4H->T4H_INS_SU := (cAliasTmp)->D4_PRDORG //GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
			Else
				T4H->T4H_INS_SU := ""
			EndIf

			T4H->T4H_OP     := (cAliasTmp)->D3_OP //chave
			T4H->T4H_BLK_CO := (cAliasTmp)->BLOCO //controle interno - bloco corrigido
			T4H->T4H_CF     := (cAliasTmp)->D3_CF
			T4H->(MsUnlock())
		EndIf	
	Else		
		//**************************************************************
		// Bloco K275 - atualiza quantidades para multiplos apontamentos
		//**************************************************************
		T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada))
	    While T4H->(!Eof()) .And. T4H->T4H_FILIAL == cT4HFilial .And. T4H->T4H_MESSPE == STR(cMes,2) .And. T4H->T4H_ANOSPE == STR(cAno,4) .And. T4H->T4H_OP == (cAliasTmp)->D3_OP .And. T4H->T4H_PRODUT == (cAliasTmp)->D3_COD .And. T4H->T4H_PRGORI == cChamada
	    	RecLock("T4H",.F.,.T.)
		    	
	    	nSaldo := T4H->T4H_QTD_PO - T4H->T4H_QTD_NE
	    	nSaldo += (cAliasTmp)->QUANT2
		    	
	    	If nSaldo >= 0
				T4H->T4H_QTD_PO := nSaldo
				T4H->T4H_QTD_NE := 0
			Else
				T4H->T4H_QTD_NE := nSaldo * -1
				T4H->T4H_QTD_PO := 0
			EndIf
				
			T4H->(MsUnlock())
			T4H->(dbSkip())
	    EndDo	
	EndIf
		
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

TCDelFile('VWSEL1')	

ProcLogAtu('PCP K275',"PCP K275 - Gravar temporaria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4H->(dbSetOrder(2))
T4H->(dbSeek(cT4HFilial+STR(cMes,2)+STR(cAno,4)))
While T4H->(!Eof()) .And. T4H->T4H_FILIAL == cT4HFilial .And. T4H->T4H_MESSPE == STR(cMes,2) .And. T4H->T4H_ANOSPE == STR(cAno,4)
	If T4H->T4H_PRGORI == cChamada .And. (T4H->T4H_QTD_NE != 0 .Or. T4H->T4H_QTD_PO != 0)
		If T4H->T4H_CF != "ER0" .And. T4H->T4H_CF != "PR0" //nao mostrar acabado, ser· eliminado no K270
			Reclock(cAliK275,.T.)
			(cAliK275)->FILIAL     := cT4HFilial //chave
			(cAliK275)->REG        := "K275"
			(cAliK275)->COD_ITEM   := T4H->T4H_PRODUT
			(cAliK275)->QTD_COR_P  := T4H->T4H_QTD_PO
			(cAliK275)->QTD_COR_N  := T4H->T4H_QTD_NE
			(cAliK275)->COD_INS_SU := T4H->T4H_INS_SU
			(cAliK275)->COD_OP_OS  := T4H->T4H_OP //chave
			(cAliK275)->CHAVE      := "K270" + T4H->T4H_OP //chave
			(cAliK275)->(MsUnLock())
			nRegsto++
		EndIf
	EndIf
	If (T4H->T4H_QTD_NE == 0 .And. T4H->T4H_QTD_PO == 0)
		RecLock("T4H", .F.)
		T4H->(DBDelete())
		T4H->(MsUnLock())
	EndIf
	T4H->(dbSkip())
EndDo
MsUnlock()

//Busca os dados para geraÁ„o do K280
cQuery := "SELECT "
cQuery += 	"T4H_BLK_CO, "
cQuery += 	"(SELECT MIN(D3_EMISSAO) FROM "+ RetSqlName("SD3") + " WHERE D3_FILIAL = T4H_FILIAL AND D3_OP = T4H_OP AND D3_COD = T4H_PRODUT) AS DTINI, "
cQuery += 	"T4H_PRODUT, "
cQuery += 	"CASE WHEN T4H_QTD_NE > 0 THEN T4H_QTD_NE ELSE T4H_QTD_PO END AS T4HQUANT "
cQuery += "FROM "+ RetSqlName("T4H") + " "
cQuery += "WHERE T4H_MESSPE ='"+ STR(cMes,2) +"' "
cQuery += "AND T4H_ANOSPE ='"+ STR(cAno,4) +"' "
cQuery += "AND T4H_PRGORI ='"+ cChamada +"' "
cQuery += "AND T4H_CF <> 'ER0' "
cQuery += "AND T4H_CF <> 'PR0' "
cQuery += "AND D_E_L_E_T_ =' ' "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	BlkReg280(cT4HFilial,(cAliasTmp)->T4H_BLK_CO,LastDay(STOD((cAliasTmp)->DTINI)),dDataAte,(cAliasTmp)->T4H_PRODUT,(cAliasTmp)->T4HQUANT,,,cAliK280)
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K275',"PCP K275 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return



/*------------------------------------------------------------------------//
//Programa:	  PROCK270
//Autor:	  Ricardo Peixoto 
//Data:		  05/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K270
//            CorreÁıes: K230, K260, K291, K292
//Parametros: 1 - cAliK270      - Alias do arquivo de trabalho do K270
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK270PRO(cAliK270,dDataDe,dDataAte,lRepross,cAliK280)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cT4GFilial    := ""
Local cSVKFilial    := ""

cK270Ali := cAliK270

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("T4G") + " WHERE T4G_MESSPE = '" + STR(cMes,2) + "' AND T4G_ANOSPE = '" + STR(cAno,4) + "' AND T4G_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Busca os dados para geraÁ„o do K270
cQuery := " SELECT " +;
			" SC2.C2_NUM, " +;
			" (SELECT MIN(D3_EMISSAO) FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = T4H_FILIAL AND D3_OP = T4H_OP AND D3_COD = T4H_PRODUT)     AS DTINI," +;
			" SC2.C2_datrf      AS DTFIM, " +;
			" T4H_OP, " +;
			" C2_PRODUTO, " +;
			" T4H_BLK_CO, " +;
		    " T4H_PRODUT, " +;
		    " T4H_QTD_PO, " +;
		    " T4H_QTD_NE, " +;
		    " T4H_BLK_CO " +;
			" from " + RetSqlName("T4H") + " T4H " +;
			       " JOIN " + RetSqlName("SC2") + " SC2 " 
					cQuery +=  " ON T4H_OP = SC2.C2_OP " 
					cQuery += " AND SC2.D_E_L_E_T_ = ' ' " +;
						" AND SC2.C2_PRODUTO = T4H.T4H_PRODUT " +;
						" AND SC2.C2_FILIAL = T4H.T4H_FILIAL " +;
			" WHERE T4H_FILIAL = '" + xFilial('T4H') + "' " +; 
            " AND T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' " +;
            " AND T4H_PRGORI = '" + cChamada + "' " +;
            " AND T4H.D_E_L_E_T_ = ' ' "


cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

//Carrega as filiais uma ˙nica vez
cT4GFilial := xFilial("T4G")
cSVKFilial := xFilial("SVK")

While !(cAliasTmp)->(Eof())

	cPA := (cAliasTmp)->C2_PRODUTO
	
	//********************************
	// Troca codigo do produto RE x PA
	//********************************
	//A troca do produto deve ser feita somente para retrabalho
	If (cAliasTmp)->T4H_BLK_CO == 'K265'
		SVK->(dbSetOrder(1))
		SVK->(dbSeek(cSVKFilial+(cAliasTmp)->C2_PRODUTO ))
  		While SVK->(!Eof()) .And. SVK->VK_FILIAL == cSVKFilial .And. SVK->VK_COD == (cAliasTmp)->C2_PRODUTO
    		cPA := SVK->VK_PRDORI
			SVK->(dbSkip())
  		EndDo
	EndIf
	
	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T4H_OP+cPA+ cChamada ))
	
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := "K270"
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_COD_OP := (cAliasTmp)->T4H_OP //chave
		T4G->T4G_COD_IT := cPA
		T4G->T4G_QTD_PO := (cAliasTmp)->T4H_QTD_PO
		T4G->T4G_QTD_NE := (cAliasTmp)->T4H_QTD_NE
		//controle interno - bloco corrigido
		Do Case
			Case (cAliasTmp)->T4H_BLK_CO == 'K235'
				T4G->T4G_ORIGEM := '1'
				T4G->T4G_BLK_CO := 'K230'
			Case (cAliasTmp)->T4H_BLK_CO == 'K255'
				T4G->T4G_ORIGEM := '2'
				T4G->T4G_BLK_CO := 'K250'
			Case (cAliasTmp)->T4H_BLK_CO == 'K215'
				T4G->T4G_ORIGEM := '3'
				T4G->T4G_BLK_CO := 'K210'
			Case (cAliasTmp)->T4H_BLK_CO == 'K265'
				T4G->T4G_ORIGEM := '4'
				T4G->T4G_BLK_CO := 'K260'
			Case (cAliasTmp)->T4H_BLK_CO == 'K220'
				T4G->T4G_ORIGEM := '5'
				T4G->T4G_BLK_CO := 'K220'
			Case (cAliasTmp)->T4H_BLK_CO == 'K291'
				T4G->T4G_ORIGEM := '6'
				T4G->T4G_BLK_CO := 'K291'
			Case (cAliasTmp)->T4H_BLK_CO == 'K292'
				T4G->T4G_ORIGEM := '7'
				T4G->T4G_BLK_CO := 'K292'
			Case (cAliasTmp)->T4H_BLK_CO == 'K301'
				T4G->T4G_ORIGEM := '8'
				T4G->T4G_BLK_CO := 'K301'
			Case (cAliasTmp)->T4H_BLK_CO == 'K302'
				T4G->T4G_ORIGEM := '9'
				T4G->T4G_BLK_CO := 'K302'
		EndCase
		T4G->(MsUnlock())
		
		//eliminar T4H do acabado
		cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_OP = '"+(cAliasTmp)->T4H_OP+"' AND T4H_PRODUT = '"+cPA+"' AND T4H_PRGORI = '" + cChamada + "' "
		MATExecQry(cQuery)
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

//Busca os dados para geraÁ„o do K270 quando tem somente REQ, sem PRO
cQuery := " SELECT " +;
			" SC2.C2_NUM, " +;
			" (SELECT MIN(D3_EMISSAO) FROM " + RetSqlName("SD3") + " WHERE D3_FILIAL = T4H_FILIAL AND D3_OP = T4H_OP AND D3_COD = T4H_PRODUT)     AS DTINI," +;
			" SC2.C2_datrf      AS DTFIM, " +;
			" T4H_OP, " +;
			" C2_PRODUTO, " +;
			" T4H_BLK_CO, " +;
		    " T4H_PRODUT, " +;
		    " T4H_QTD_PO, " +;
		    " T4H_QTD_NE, " +;
		    " T4H_BLK_CO " +;
			" from " + RetSqlName("T4H") + " T4H " +;
			       " JOIN " + RetSqlName("SC2") + " SC2 " 
					cQuery +=   " ON T4H_OP = SC2.C2_OP " 				
					cQuery += " AND SC2.D_E_L_E_T_ = ' ' " +;
			            " AND SC2.C2_FILIAL = T4H.T4H_FILIAL " +;
			" WHERE T4H_FILIAL = '" + xFilial('T4H') + "' " +; 
            " AND T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' " +;
            " AND T4H_PRGORI = '" + cChamada + "' " +;
            " AND T4H.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())

	cPA := (cAliasTmp)->C2_PRODUTO
	
	//********************************
	// Troca codigo do produto RE x PA
	//********************************
	//A troca do produto deve ser feita somente para retrabalho
	If (cAliasTmp)->T4H_BLK_CO == 'K265'
		SVK->(dbSetOrder(1))
		SVK->(dbSeek(cSVKFilial+(cAliasTmp)->C2_PRODUTO))
  		While SVK->(!Eof()) .And. SVK->VK_FILIAL == cSVKFilial .And. SVK->VK_COD == (cAliasTmp)->C2_PRODUTO
    		cPA := SVK->VK_PRDORI
			SVK->(dbSkip())
  		EndDo
	EndIf
	
	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->T4H_OP+cPA+ cChamada ))
	
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := "K270"
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->DTINI)))
		T4G->T4G_COD_OP := (cAliasTmp)->T4H_OP //chave
		T4G->T4G_COD_IT := cPA
		T4G->T4G_QTD_PO := 0
		T4G->T4G_QTD_NE := 0
		//controle interno - bloco corrigido
		Do Case
			Case (cAliasTmp)->T4H_BLK_CO == 'K235'
				T4G->T4G_ORIGEM := '1'
				T4G->T4G_BLK_CO := 'K230'
			Case (cAliasTmp)->T4H_BLK_CO == 'K255'
				T4G->T4G_ORIGEM := '2'
				T4G->T4G_BLK_CO := 'K250'
			Case (cAliasTmp)->T4H_BLK_CO == 'K215'
				T4G->T4G_ORIGEM := '3'
				T4G->T4G_BLK_CO := 'K210'
			Case (cAliasTmp)->T4H_BLK_CO == 'K265'
				T4G->T4G_ORIGEM := '4'
				T4G->T4G_BLK_CO := 'K260'
			Case (cAliasTmp)->T4H_BLK_CO == 'K220'
				T4G->T4G_ORIGEM := '5'
				T4G->T4G_BLK_CO := 'K220'
			Case (cAliasTmp)->T4H_BLK_CO == 'K291'
				T4G->T4G_ORIGEM := '6'
				T4G->T4G_BLK_CO := 'K291'
			Case (cAliasTmp)->T4H_BLK_CO == 'K292'
				T4G->T4G_ORIGEM := '7'
				T4G->T4G_BLK_CO := 'K292'
			Case (cAliasTmp)->T4H_BLK_CO == 'K301'
				T4G->T4G_ORIGEM := '8'
				T4G->T4G_BLK_CO := 'K301'
			Case (cAliasTmp)->T4H_BLK_CO == 'K302'
				T4G->T4G_ORIGEM := '9'
				T4G->T4G_BLK_CO := 'K302'
		EndCase
		T4G->(MsUnlock())
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

//eliminar T4H do acabado
cQuery := " DELETE FROM " + RetSqlName("T4H") + " WHERE T4H_MESSPE = '" + STR(cMes,2) + "' AND T4H_ANOSPE = '" + STR(cAno,4) + "' AND T4H_CF = 'ER0' AND T4H_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

//Iniciando calculo para 291 e 292
cQuery := " SELECT SC2.C2_datpri  AS DTINI, " 
cQuery += "        SC2.C2_datrf   AS DTFIM, " 
cQuery += "        CASE " 
cQuery += "           WHEN SD3.D3_ESTORNO = 'S'  AND SD3.D3_CF LIKE ( 'ER%' ) THEN 'K291' "
cQuery += "	          WHEN SD3.D3_ESTORNO = 'S'  AND SD3.D3_CF LIKE ( 'RE%' ) THEN 'K291' " 
cQuery += "	          WHEN SD3.D3_ESTORNO <> 'S' AND SD3.D3_CF LIKE ( 'PR%' ) THEN 'K291' " 
cQuery += "           WHEN SD3.D3_ESTORNO <> 'S' AND SD3.D3_CF LIKE ( 'DE%' ) THEN 'K291' " 
cQuery += "           ELSE 'K292' " 
cQuery += "        END AS BLOCO, " 
cQuery += "        SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT) " 
cQuery += "                 WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "                 WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " 
cQuery += "                 WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " 
cQuery += "                 ELSE 0 END) AS QUANT, " 
cQuery += "        SD3.D3_COD, "
cQuery += "        SD3.D3_OP, " 
cQuery += "        MAX(D3_EMISSAO) AS D3_EMISSAO, " 
cQuery += "        SD3.D3_FILIAL, " 
cQuery += "        SD3.D3_PERBLK, "
cQuery += "        SD3.R_E_C_N_O_ AS SD3RECNO, "  
cQuery += "        SD3.D3_CF, "
cQuery += "        D3_ESTORNO "
cQuery += "   FROM " + RetSqlName("SD3") + " SD3 "
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "     ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' "
cQuery += "    AND SB1.B1_COD     = SD3.D3_COD " 
cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " 
	cQuery += "   ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' "
	cQuery += "  AND SBZ.BZ_COD     = SB1.B1_COD " 
	cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "   JOIN " + RetSqlName("SC2") + " SC2 "
cQuery += "     ON SD3.D3_OP       = SC2.C2_OP " 
cQuery += "    AND SC2.C2_FILIAL   = '" + xFilial('SC2') + "' " 
cQuery += "    AND SC2.D_E_L_E_T_  = ' ' " 
cQuery += "    AND SC2.C2_ITEM     <> 'OS' " 
cQuery += "    AND SC2.C2_TPPR   IN ('I',' ') " 
cQuery += "   JOIN " + RetSqlName("SB1") + " SB1_OP " 
cQuery += "     ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " 
cQuery += "    AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " 
cQuery += "    AND SB1_OP.D_E_L_E_T_ = ' ' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP "
	cQuery += "   ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' "
	cQuery += "  AND SBZ_OP.BZ_COD     = SB1.B1_COD "
	cQuery += "  AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF

// validaÁ„o de empenho negativo
/*
cQuery += "   JOIN " + RetSqlName("SD4") + " SD4 "
cQuery += "     ON SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " 
cQuery += "    AND SD4.D4_OP     = SD3.D3_OP "
cQuery += "    AND SD4.D4_QTDEORI < 0 " 
cQuery += "    AND SD4.D_E_L_E_T_ = ' ' "
*/
cQuery += "  WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
cQuery += "    AND SD3.D3_OP     <> ' ' " 
cQuery += "    AND (SD3.D3_CF  LIKE ('RE%') " 
cQuery += "         OR SD3.D3_CF  LIKE ('ER%') "
cQuery += "         OR SD3.D3_CF  LIKE ('DE%') "
cQuery += "         OR SD3.D3_CF  LIKE ('PR%')) " 
cQuery += "    AND SB1.B1_CCCUSTO = ' ' " 
cQuery += "    AND SB1.B1_COD NOT LIKE 'MOD%' " 
cQuery += "    AND (SD3.D3_EMISSAO < '" + DtoS(dDataDe) + "' "  
cQuery += "         AND (SD3.D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "' "
cQuery += "          OR SD3.D3_PERBLK = '" + STR(cMes,2)+STR(cAno,4) + "  ')) " 
cQuery += "    AND SD3.D_E_L_E_T_ = ' ' " 
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf
cQuery += "	    IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo10+") "

cQuery += "    AND SB1_OP.B1_CCCUSTO = ' ' " 
cQuery += "    AND SB1_OP.B1_COD NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf
cQuery += "     IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "

// validaÁ„o de empenho negativo
cQuery += " AND EXISTS ( SELECT 1  "
cQuery += "                FROM " + RetSqlName("SD4") + " SD4 " 
cQuery += "               WHERE SD4.D4_FILIAL  = '" + xFilial('SD4') + "' " 
cQuery += "                 AND SD4.D4_OP     = SD3.D3_OP "
cQuery += "                 AND SD4.D4_QTDEORI < 0 " 
cQuery += "                 AND SD4.D_E_L_E_T_ = ' ' ) " 

cQuery += "  GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += "           SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_CF,  "
cQuery += "           D3_ESTORNO, C2_datpri, C2_datrf "
cQuery += "  ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

//Carrega as filiais uma ˙nica vez
cSVWFilial := xFilial("SVV")

While !(cAliasTmp)->(Eof())

	//grava tabela fÌsica para guardar histÛrico
	T4G->(dbSetOrder(2))
	If !T4G->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		//************************************************************************
		// Bloco K270
		//************************************************************************
		Reclock("T4G",.T.)
		T4G->T4G_PRGORI  := cChamada
		T4G->T4G_FILIAL  := cT4GFilial //chave
		T4G->T4G_MESSPE := STR(cMes,2)
		T4G->T4G_ANOSPE := STR(cAno,4)
		T4G->T4G_REG    := 'K270'
		T4G->T4G_DT_INI := Dtos(FirstDate(Stod((cAliasTmp)->D3_EMISSAO)))
		T4G->T4G_DT_FIN := Dtos(LastDate(Stod((cAliasTmp)->D3_EMISSAO)))
		T4G->T4G_COD_OP := (cAliasTmp)->D3_OP //chave
		T4G->T4G_COD_IT := (cAliasTmp)->D3_COD
		
		If (cAliasTmp)->QUANT >= 0
			T4G->T4G_QTD_PO := (cAliasTmp)->QUANT
		Else
			T4G->T4G_QTD_NE := (cAliasTmp)->QUANT * -1
		EndIf
		
		T4G->T4G_BLK_CO := (cAliasTmp)->BLOCO
		
		If T4G->T4G_BLK_CO == 'K291'
			T4G->T4G_ORIGEM := '6'
		Else
			T4G->T4G_ORIGEM := '7'
		EndIf
		
		T4G->(MsUnlock())		
	Else
		//************************************************************************
		// Bloco K270 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************
		T4G->(dbSetOrder(2))
		T4G->(dbSeek(cSVWFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	    
		While T4G->(!Eof()) .And. T4G->T4G_FILIAL == cT4GFilial .And. T4G->T4G_MESSPE == STR(cMes,2) .And. T4G->T4G_ANOSPE == STR(cAno,4) .And. T4G->T4G_COD_OP == (cAliasTmp)->D3_OP .And. T4G->T4G_COD_IT == (cAliasTmp)->D3_COD .And. T4G->T4G_PRGORI == cChamada 
	    	RecLock("T4G",.F.,.T.)
	    	
	    	nSaldo := T4G->T4G_QTD_PO - T4G->T4G_QTD_NE
	    	nSaldo += (cAliasTmp)->QUANT
	    	
	    	If nSaldo >= 0
				T4G->T4G_QTD_PO := nSaldo
				T4G->T4G_QTD_NE := 0
			Else
				T4G->T4G_QTD_NE := nSaldo * -1
				T4G->T4G_QTD_PO := 0
			EndIf

			T4G->(MsUnlock())
			T4G->(dbSkip())
	    EndDo	
	EndIf
	
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

fAjus270(cMes, cAno)

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4G->(dbSetOrder(2))
T4G->(dbSeek(cT4GFilial+STR(cMes,2)+STR(cAno,4)))
While T4G->(!Eof()) .And. T4G->T4G_FILIAL == cT4GFilial .And. T4G->T4G_MESSPE == STR(cMes,2) .And. T4G->T4G_ANOSPE == STR(cAno,4)
	If T4G->T4G_PRGORI == cChamada
		Reclock(cAliK270,.T.)
		(cAliK270)->FILIAL     := T4G->T4G_FILIAL //chave
		(cAliK270)->REG        := T4G->T4G_REG
		(cAliK270)->COD_ITEM   := T4G->T4G_COD_IT
		(cAliK270)->DT_INI_AP  := Stod(T4G->T4G_DT_INI)
		(cAliK270)->DT_FIN_AP  := Stod(T4G->T4G_DT_FIN)
		(cAliK270)->QTD_COR_P  := T4G->T4G_QTD_PO
		(cAliK270)->QTD_COR_N  := T4G->T4G_QTD_NE
		(cAliK270)->ORIGEM     := T4G->T4G_ORIGEM
		(cAliK270)->COD_OP_OS  := T4G->T4G_COD_OP //chave
		(cAliK270)->CHAVE      := "K270" + T4G->T4G_COD_OP //chave
		(cAliK270)->(MsUnLock())
		nRegsto++
	EndIf
	T4G->(dbSkip())
EndDo
MsUnlock()

//Busca os dados para geraÁ„o do K280
cQuery := "SELECT "
cQuery += 	"T4G_BLK_CO, "
cQuery += 	"T4G_DT_INI, "
cQuery += 	"T4G_COD_IT, "
cQuery += 	"CASE WHEN T4G_QTD_NE > 0 THEN T4G_QTD_NE*-1 ELSE T4G_QTD_PO END AS T4GQUANT "
cQuery += "FROM "+ RetSqlName("T4G") + " "
cQuery += "WHERE T4G_MESSPE ='"+ STR(cMes,2) +"' "
cQuery += "AND T4G_ANOSPE ='"+ STR(cAno,4) +"' "
cQuery += "AND T4G_PRGORI ='"+ cChamada +"' "
cQuery += "AND D_E_L_E_T_ =' ' "

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	BlkReg280(cT4GFilial,(cAliasTmp)->T4G_BLK_CO,LastDay(Stod((cAliasTmp)->T4G_DT_INI)),dDataAte,(cAliasTmp)->T4G_COD_IT,(cAliasTmp)->T4GQUANT,,,cAliK280)
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

//*****************************************
//Iniciando marcaÁ„o nos estornos n„o lidos
//*****************************************
cQuery := " SELECT SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_PERBLK " +; 
		  " FROM "+RetSqlName("SD3") + " SD3 " +;
		  " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ = ' ' " +; 
		    " AND (SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "') " +;
		    " AND SD3.D3_ESTORNO = 'S' " +; 
		    " AND SD3.D3_PERBLK = '" + PADR(Nil,tamSX3('D3_PERBLK')[1]) + "'

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())	
	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

Return



/*------------------------------------------------------------------------//
//Programa:	  REGK265 
//Autor:	  Ricardo Peixoto 
//Data:		  19/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K265
//Parametros: 1 - cAliK265      - Alias do arquivo de trabalho do K265
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK265(cAliK265,dDataDe,dDataAte,lRepross,l300)

Local cQuery		:= ""
Local cUpdateD3		:= ""
Local cUpdateD31	:= ""
Local cUpdateD32	:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSD4Filial	:= ""
Local cT4FFilial    := ""
Local cSVKFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada   	:= If (lRepross, "SPEDFISCAL", "MATR241   ")
Local cCharSoma     := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ") //n„o usar ChangeQuery para update e create

If Type("nRegsto") = "U"
	PRIVATE nRegsto := .F.
EndIf

Default l300 := .F.

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If l300
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

ProcLogAtu('PCP K265',"PCP K265 - Inicio de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//Limpa tabela para o perÌodo.
cQuery := " DELETE FROM " + RetSqlName("T4F") + " WHERE T4F_MESAPU = '" + STR(cMes,2) + "' AND T4F_ANOAPU = '" + STR(cAno,4) + "' AND T4F_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)
cQuery := " DELETE FROM " + RetSqlName("T4E") + " WHERE T4E_MESAPU = '" + STR(cMes,2) + "' AND T4E_ANOAPU = '" + STR(cAno,4) + "' AND T4E_PRGORI = '" + cChamada + "' "
MATExecQry(cQuery)

ProcLogAtu('PCP K265',"PCP K265 - Limpa view    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

If TCGetDB() $ "ORACLE/DB2/400/INFORMIX"

	//Busca os dados para geraÁ„o do K265
	cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +;
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_estorno, SC2.C2_PRODUTO, SD3.D3_CF " +; 
	            " FROM " + RetSqlName("SD3") + " SD3 " +;
	            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	             " AND SB1.B1_COD     = SD3.D3_COD " +; 
	             " AND SB1.D_E_L_E_T_ = ' ' "
	
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		                " AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	
	cQuery += "JOIN " + RetSqlName("SC2") + " SC2 "+;
				" ON SD3.D3_OP      = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD "+;
				" AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	        	" AND SC2.D_E_L_E_T_ = ' ' " +; 
	        	" AND SC2.C2_ITEM   <> 'OS' " +; 
	        	" AND SC2.C2_TPPR   IN ('R') " +; 
	        	" JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	        	" ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	        	" AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	        	" AND SB1_OP.D_E_L_E_T_ = ' ' "
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		                " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		               " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		               " AND SBZ_OP.D_E_L_E_T_ = ' ' " 
	EndIF
	
	cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	            " AND SD3.D_E_L_E_T_ = ' ' " +; 
	            " AND SD3.D3_OP     <> ' ' " +; 
	            " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') ) " +;
	            " AND SB1.B1_CCCUSTO = ' ' " +; 
	            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	            " AND D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	            " AND SD3.D_E_L_E_T_ = ' ' " 
	            
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
	Else
		cQuery += " AND SB1.B1_TIPO "
	EndIf
	
	cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
	If cDadosProd == 'SBZ' .And. lCpoBZTP
		cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
	Else
		cQuery += " AND SB1_OP.B1_TIPO "
	EndIf
	
	cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
	cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "   
	cQuery += "ORDER BY 4,3,2"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cT4FFilial := xFilial("T4F")
	
	While !(cAliasTmp)->(Eof())
	
		If lRepross
			SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)
		EndIf	
	
		If (cAliasTmp)->D3_ESTORNO != 'S'
		
			//grava tabela fÌsica para guardar histÛrico
			T4F->(dbSetOrder(1))
			If !T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		
				SVK->(dbSetOrder(2))
				If !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD+ cChamada )) .AND. !SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO+ cChamada ))
				
					//************************************************************************
					// Bloco K265
					//************************************************************************
					Reclock("T4F",.T.)
					T4F->T4F_PRGORI  := cChamada
					T4F->T4F_FILIAL  := cT4FFilial
					T4F->T4F_MESAPU  := STR(cMes,2)
					T4F->T4F_ANOAPU  := STR(cAno,4)
					T4F->T4F_REG     := "K265"
					T4F->T4F_PRODUT  := (cAliasTmp)->D3_COD
					If (cAliasTmp)->QUANT > 0
						T4F->T4F_QTDCON  := (cAliasTmp)->QUANT
						T4F->T4F_QTDRET  := 0
					Else
						T4F->T4F_QTDRET  := (cAliasTmp)->QUANT * -1
						T4F->T4F_QTDCON  := 0
					EndIf
					T4F->T4F_OP      := (cAliasTmp)->D3_OP
					T4F->(MsUnlock())
					(cAliasTmp)->(dbSkip())
					
				Else
				
					cPA := (cAliasTmp)->D3_COD
					SVK->(dbSetOrder(1))
					SVK->(dbSeek(cT4FFilial+(cAliasTmp)->D3_COD))
				    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cT4FFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD
				    	cPA := SVK->VK_PRDORI
						SVK->(dbSkip())
				    EndDo
				
					//********************************************************************************************
					//Grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
					//********************************************************************************************
					T4E->(dbSetOrder(1))
					If !T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
				
						//************************************************************************
						// Bloco K260
						//************************************************************************
						Reclock("T4E",.T.)
						T4E->T4E_PRGORI  := cChamada
						T4E->T4E_FILIAL  := cT4FFilial
						T4E->T4E_MESAPU  := STR(cMes,2)
						T4E->T4E_ANOAPU  := STR(cAno,4)
						T4E->T4E_REG     := "K260"
						T4E->T4E_OP      := (cAliasTmp)->D3_OP
						T4E->T4E_PRODUT  := cPA
						T4E->T4E_QTSAID  := (cAliasTmp)->QUANT
						T4E->T4E_QTRET   := 0
						T4E->(MsUnlock())
							
						(cAliasTmp)->(dbSkip())
					Else
						//************************************************************************
						// Bloco K260 - ajuste de quantidades em multiplos apontamentos
						//************************************************************************	
						T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
					    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4FFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada
					    	RecLock("T4E",.F.,.T.)		    	
					    	T4E->T4E_QTSAID  += (cAliasTmp)->QUANT
					    	T4E->T4E_QTRET   := 0
					    	T4E->(MsUnlock())
							T4E->(dbSkip())
					    EndDo
						(cAliasTmp)->(dbSkip())
					EndIf
					//********************************************************************************************
					//grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
					//********************************************************************************************
				
					
				EndIf
			Else
				//************************************************************************
				// Bloco K265 - ajuste de quantidades em multiplos apontamentos
				//************************************************************************	
				T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
			    While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4) .And. T4F->T4F_OP == (cAliasTmp)->D3_OP .And. T4F->T4F_PRODUT == (cAliasTmp)->D3_COD .And. T4F->T4F_PRGORI == cChamada
			    	RecLock("T4F",.F.,.T.)
			    	
			    	If (cAliasTmp)->QUANT > 0
						T4F->T4F_QTDCON  += (cAliasTmp)->QUANT
					Else
						T4F->T4F_QTDRET  += (cAliasTmp)->QUANT * -1
					EndIf
			    	
			    	T4F->(MsUnlock())
					T4F->(dbSkip())
			    EndDo
				(cAliasTmp)->(dbSkip())
			EndIf
				
				
		Else
			(cAliasTmp)->(dbSkip())
		EndIf
			
		
	EndDo

Else

	TCDelFile('VWSEL1')
	
	//Busca os dados para geraÁ„o do K265
	cQuery := " CREATE VIEW VWSEL1 AS "
	cQuery += " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) " +;
	                          " WHEN SD3.D3_CF LIKE ('ER%') THEN (SD3.D3_QUANT*-1) " +; 
	                          " ELSE 0 END) AS QUANT, " +;
	                 " SD3.D3_COD, "+; 
	                 " SD3.D3_OP, " +; 
	                 " MAX(D3_EMISSAO) AS D3_EMISSAO, " +; 
	                 " SD3.D3_FILIAL, " +;
	                 " SD3.D3_PERBLK, " +;
	                 " SD3.R_E_C_N_O_ AS SD3RECNO, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "+;
			  " FROM " + RetSqlName("SD3") + " SD3"
	
	cUpdateD31 := " WHERE R_E_C_N_O_ IN ( SELECT SD3.R_E_C_N_O_ "+;
	           							 " FROM " + RetSqlName("SD3") + " SD3 " 

										 
	cUpdateD3 :=           				 " JOIN " + RetSqlName("SB1") + " SB1 " +; 
	             						 " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	            						 " AND SB1.B1_COD     = SD3.D3_COD " +; 
	       							     " AND SB1.D_E_L_E_T_ = ' ' "

	
										If cDadosProd == 'SBZ' .And. lCpoBZTP
											cUpdateD3 += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
		               										    " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		              										   " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
		          									           " AND SBZ.D_E_L_E_T_ = ' ' "
										EndIf
	
										cUpdateD3 += " JOIN " + RetSqlName("SC2") + " SC2 "
										cUpdateD3 +=   " ON SD3.D3_OP      = SC2.C2_OP "
										cUpdateD3 += "  AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
	        									     "  AND SC2.D_E_L_E_T_ = ' ' " +; 
	        								         "  AND SC2.C2_ITEM   <> 'OS' " +; 
	        										 "  AND SC2.C2_TPPR   IN ('R') " +; 
	        										 " JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
	    										     "   ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
	        							  			 "  AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
	        									     "  AND SB1_OP.D_E_L_E_T_ = ' ' "
	          
										If cDadosProd == 'SBZ' .And. lCpoBZTP
											cUpdateD3 += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
		           									     " ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
		             									 " AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
		           									     " AND SBZ_OP.D_E_L_E_T_ = ' ' " 
										EndIF
	
										cUpdateD3 += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
	           										 " AND SD3.D_E_L_E_T_ = ' ' " +; 
	           										 " AND SD3.D3_OP     <> ' ' " +; 
	            									 " AND (SD3.D3_CF  LIKE ('RE%') OR SD3.D3_CF  LIKE ('DE%') OR SD3.D3_CF  LIKE ('ER%') ) " +;
	          									     " AND SB1.B1_CCCUSTO = ' ' " +; 
	           										 " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
	           										 " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
	          										 " AND SD3.D_E_L_E_T_ = ' ' " +;
	           										 " AND SD3.D3_ESTORNO <> 'S' "
	            
										If cDadosProd == 'SBZ' .And. lCpoBZTP
											cUpdateD3 += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
										Else
											cUpdateD3 += " AND SB1.B1_TIPO "
										EndIf
	
										cUpdateD3 += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
										cUpdateD3 += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
	       											 " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
	          
										If cDadosProd == 'SBZ' .And. lCpoBZTP
											cUpdateD3 += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
										Else
											cUpdateD3 += " AND SB1_OP.B1_TIPO "
										EndIf
	
										cUpdateD3 += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
	
										cQuery += cUpdateD3 //compartilha where para update e select
										cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
										cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF "   

										cUpdateD3 += " )"
	
	cUpdateD32 := " AND D3_FILIAL  = '" + xFilial('SD3') + "' " 
	
	//executa update para marcar d3_perblk
	cUpdateD3 := " UPDATE " + RetSqlName("SD3") + " SET D3_PERBLK = '" + STR(cMes,2) + STR(cAno,4) + "' " + cUpdateD31 + cUpdateD3 + cUpdateD32
	MATExecQry(cUpdateD3) 
	
	ProcLogAtu('PCP K265',"PCP K265 - Registros marcados    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//cria view para leitura
	MATExecQry(cQuery)
	
	ProcLogAtu('PCP K265',"PCP K265 - Montagem query 2    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	//varre view para otimizar calculo de quantidades
	cQuery := "	SELECT " +;
				" Sum(CASE WHEN D3_CF LIKE ( 'RE%' ) THEN ( QUANT ) ELSE 0 END) AS QUANTPOS, " +;
				" Sum(CASE WHEN D3_CF LIKE ( 'DE%' ) THEN ( QUANT *- 1 ) ELSE 0 END) AS QUANTNEG, " +;
				" SUM(QUANT) AS QUANT, " +;
				" D3_COD, " +;
				" D3_OP, " +;
				" MIN(D3_EMISSAO) AS D3_EMISSAO, " +;
				" MIN(D3_FILIAL) AS D3_FILIAL, " +;
				" MIN(C2_PRODUTO) AS C2_PRODUTO " +;
				" FROM VWSEL1 " +;
				" GROUP BY D3_OP, " +;
						 " D3_COD "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	ProcLogAtu('PCP K265',"PCP K265 - Busca concluÌda    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	
	//Carrega as filiais uma ˙nica vez
	cSD4Filial := xFilial("SD4")
	cT4FFilial := xFilial("T4F")
	cSVKFilial := xFilial("SVK")
	
	ProcLogAtu('PCP K265',"PCP K265 - Leitura de movimentos    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
	
	While !(cAliasTmp)->(Eof())
	
		//grava tabela fÌsica para guardar histÛrico
		T4F->(dbSetOrder(1))
		If !T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
	
			SVK->(dbSetOrder(2))
			If !SVK->(dbSeek(cSVKFilial+(cAliasTmp)->C2_PRODUTO+(cAliasTmp)->D3_COD)) .AND. !SVK->(dbSeek(cSVKFilial+(cAliasTmp)->D3_COD+(cAliasTmp)->C2_PRODUTO))
			
				//************************************************************************
				// Bloco K265
				//************************************************************************
				Reclock("T4F",.T.)
				T4F->T4F_PRGORI  := cChamada
				T4F->T4F_FILIAL  := cT4FFilial
				T4F->T4F_MESAPU  := STR(cMes,2)
				T4F->T4F_ANOAPU  := STR(cAno,4)
				T4F->T4F_REG     := "K265"
				T4F->T4F_PRODUT  := (cAliasTmp)->D3_COD
				T4F->T4F_QTDCON  := (cAliasTmp)->QUANTPOS
				T4F->T4F_QTDRET  := (cAliasTmp)->QUANTNEG
				T4F->T4F_OP      := (cAliasTmp)->D3_OP
				T4F->(MsUnlock())
				(cAliasTmp)->(dbSkip())
				
			Else
			
				cPA := (cAliasTmp)->D3_COD
				SVK->(dbSetOrder(1))
				SVK->(dbSeek(cSVKFilial+(cAliasTmp)->D3_COD))
			    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cSVKFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD
			    	cPA := SVK->VK_PRDORI
					SVK->(dbSkip())
			    EndDo
			
				//********************************************************************************************
				//Grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
				//********************************************************************************************
				T4E->(dbSetOrder(1))
				If !T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
			
					//************************************************************************
					// Bloco K260
					//************************************************************************
					Reclock("T4E",.T.)
					T4E->T4E_PRGORI  := cChamada
					T4E->T4E_FILIAL  := cT4FFilial
					T4E->T4E_MESAPU  := STR(cMes,2)
					T4E->T4E_ANOAPU  := STR(cAno,4)
					T4E->T4E_REG     := "K260"
					T4E->T4E_OP      := (cAliasTmp)->D3_OP
					T4E->T4E_PRODUT  := cPA
					T4E->T4E_QTSAID  := (cAliasTmp)->QUANT
					T4E->T4E_QTRET   := 0
					T4E->(MsUnlock())
						
					(cAliasTmp)->(dbSkip())
				Else
					//************************************************************************
					// Bloco K260 - ajuste de quantidades em multiplos apontamentos
					//************************************************************************	
					T4E->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
				    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4FFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada
				    	RecLock("T4E",.F.,.T.)		    	
				    	T4E->T4E_QTSAID  += (cAliasTmp)->QUANT
				    	T4E->T4E_QTRET   := 0
				    	T4E->(MsUnlock())
						T4E->(dbSkip())
				    EndDo
					(cAliasTmp)->(dbSkip())
				EndIf
				//********************************************************************************************
				//grava tabela fÌsica para guardar histÛrico no K260 para quantidade de saÌda do retrabalhado
				//********************************************************************************************
			
				
			EndIf
		Else
			//************************************************************************
			// Bloco K265 - ajuste de quantidades em multiplos apontamentos
			//************************************************************************	
			T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+(cAliasTmp)->D3_COD+ cChamada ))
		    While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4) .And. T4F->T4F_OP == (cAliasTmp)->D3_OP .And. T4F->T4F_PRODUT == (cAliasTmp)->D3_COD .And. T4F->T4F_PRGORI == cChamada
		    	RecLock("T4F",.F.,.T.)
		    	T4F->T4F_QTDCON  := (cAliasTmp)->QUANTPOS
				T4F->T4F_QTDRET  := (cAliasTmp)->QUANTNEG
		    	T4F->(MsUnlock())
				T4F->(dbSkip())
		    EndDo
			(cAliasTmp)->(dbSkip())
		EndIf
				
			
		
	EndDo
	
EndIf

(cAliasTmp)->(dbCloseArea())

ProcLogAtu('PCP K265',"PCP K265 - CriaÁ„o de tempor·ria    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4F->(dbSetOrder(1))
T4F->(dbSeek(cT4FFilial+STR(cMes,2)+STR(cAno,4)))
While T4F->(!Eof()) .And. T4F->T4F_FILIAL == cT4FFilial .And. T4F->T4F_MESAPU == STR(cMes,2) .And. T4F->T4F_ANOAPU == STR(cAno,4)
	If T4F->T4F_PRGORI == cChamada
		Reclock(cAliK265,.T.)
		(cAliK265)->FILIAL     := T4F->T4F_FILIAL
		(cAliK265)->REG        := T4F->T4F_REG
		(cAliK265)->COD_ITEM   := T4F->T4F_PRODUT
		(cAliK265)->QTD_CONS   := T4F->T4F_QTDCON
		(cAliK265)->QTD_RET    := T4F->T4F_QTDRET
		(cAliK265)->COD_OP_OS  := T4F->T4F_OP
		(cAliK265)->(MsUnLock())
		nRegsto++
	EndIf
	T4F->(dbSkip())
EndDo
MsUnlock()

ProcLogAtu('PCP K265',"PCP K265 - Fim de funÁ„o    : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

Return

/*------------------------------------------------------------------------//
//Programa:	  REGK260 
//Autor:	  Ricardo Peixoto 
//Data:		  19/10/2018
//Descricao:  Funcao responsavel pela gravacao do Registro K260
//Parametros: 1 - cAliK265      - Alias do arquivo de trabalho do K260
//            2 - dDataDe		- Data Inicial da Apuracao   
//			  3 - dDataAte		- Data Final da Apuracao
//Uso: 		  MATXSPED
//------------------------------------------------------------------------*/

Function REGK260(cAliK260,dDataDe,dDataAte,lRepross)

Local cQuery		:= ""
Local cAliasTmp		:= GetNextAlias()
Local cSD4Filial	:= ""
Local cT4EFilial    := ""
Local cSVKFilial    := ""
Local cDadosProd    := SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cMes          := Month(dDataDe)
Local cAno          := Year(dDataDe)
Local cPA           := ''
Local cChamada      := If (lRepross, "SPEDFISCAL", "MATR241   ")
Local dDataProc

If Type("nRegsto") = "U"
	PRIVATE nRegsto := .F.
EndIf

//retirada validaÁ„o por parametro
lRepross := .T.
cChamada := "SPEDFISCAL"

If IsInCallStack("MATC300")
	cChamada := "MATC300   "
EndIf

GrvOpSC2()

//Limpeza da tabela feita na funÁ„o K265

//Busca os dados para geraÁ„o do K260
cQuery := " SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('PR%') THEN (SD3.D3_QUANT) " +; 
                          " ELSE 0 END) AS QUANT, " +;
                 " SD3.D3_COD, "+; 
                 " SD3.D3_OP, " +; 
                 " MIN(D3_EMISSAO) D3_EMISSAO, " +; 
                 " SD3.D3_FILIAL, " +;
                 " SD3.D3_PERBLK, " +;
                 " SD3.R_E_C_N_O_  SD3RECNO, " +;
				 " SD3.D3_ESTORNO, " +;
				 " SC2.C2_PRODUTO, " +;
				 " SD3.D3_CF, " +; 
                 " SC2.C2_DATPRI DTINI, " +; 
          		 " SC2.C2_DATRF  DTFIM " +; 
            " FROM " + RetSqlName("SD3") + " SD3 " +;
            " JOIN " + RetSqlName("SB1") + " SB1 " +; 
              " ON SB1.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
             " AND SB1.B1_COD     = SD3.D3_COD " +; 
             " AND SB1.D_E_L_E_T_ = ' ' "

If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ " +; 
	                 " ON SBZ.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
	                " AND SBZ.BZ_COD     = SB1.B1_COD " +; 
	                " AND SBZ.D_E_L_E_T_ = ' ' "
EndIf

cQuery += "JOIN " + RetSqlName("SC2") + " SC2 "
		
			cQuery +=   " ON SD3.D3_OP      = SC2.C2_OP "
			cQuery += " AND SC2.C2_FILIAL  = '" + xFilial('SC2') + "' " +; 
        	" AND SC2.D_E_L_E_T_ = ' ' " +; 
        	" AND SC2.C2_ITEM   <> 'OS' " +; 
        	" AND SC2.C2_TPPR   IN ('R') " +; 
        	" JOIN " + RetSqlName("SB1") + " SB1_OP " +; 
			" ON SB1_OP.B1_FILIAL  = '" + xFilial('SB1') + "' " +; 
			" AND SB1_OP.B1_COD     = SC2.C2_PRODUTO " +; 
			" AND SB1_OP.D_E_L_E_T_ = ' ' "
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " SBZ_OP " +; 
					" ON SBZ_OP.BZ_FILIAL  = '" + xFilial('SBZ') + "' " +; 
					" AND SBZ_OP.BZ_COD     = SB1.B1_COD " +; 
					" AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF

cQuery += " WHERE SD3.D3_FILIAL  = '" + xFilial('SD3') + "' " +; 
            " AND SD3.D_E_L_E_T_ = ' ' " +; 
            " AND SD3.D3_OP     <> ' ' " +; 
            " AND (SD3.D3_CF  LIKE ('PR%') ) " +;
            " AND SB1.B1_CCCUSTO = ' ' " +; 
            " AND SB1.B1_COD NOT LIKE 'MOD%' " +; 
            " AND SD3.D3_EMISSAO BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' " +; 
            " AND SD3.D_E_L_E_T_ = ' ' "  +;
            " AND SD3.D3_ESTORNO <> 'S' "
            
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += " AND SB1.B1_TIPO "
EndIf

cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += " AND SB1_OP.B1_CCCUSTO = ' ' " +; 
          " AND SB1_OP.B1_COD     NOT LIKE 'MOD%' " 
          
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += " AND " + MatIsNull() + "(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += " AND SB1_OP.B1_TIPO "
EndIf

cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo06+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
cQuery += " SD3.D3_PERBLK, SD3.R_E_C_N_O_, SD3.D3_ESTORNO, SC2.C2_PRODUTO, SD3.D3_CF, SC2.C2_DATPRI, SC2.C2_DATRF "   
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

//Carrega as filiais uma ˙nica vez
cSD4Filial := xFilial("SD4")
cT4EFilial := xFilial("T4E")
cSVKFilial := xFilial("SVK")

While !(cAliasTmp)->(Eof())

	SETPERBLK((cAliasTmp)->D3_PERBLK, (cAliasTmp)->SD3RECNO, cMes, cAno)

	cPA := (cAliasTmp)->D3_COD
	SVK->(dbSetOrder(1))
	SVK->(dbSeek(cSVKFilial+(cAliasTmp)->D3_COD))
    While SVK->(!Eof()) .And. SVK->VK_FILIAL == cSVKFilial .And. SVK->VK_COD == (cAliasTmp)->D3_COD .And. !Empty(SVK->VK_PRDORI)
    	cPA := SVK->VK_PRDORI
		SVK->(dbSkip())
    EndDo

	dDataProc := Stod((cAliasTmp)->D3_EMISSAO)

	//grava tabela fÌsica para guardar histÛrico
	T4E->(dbSetOrder(1))
	If !T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada))
			
		//***********************************************************************
		// Bloco K260
		//***********************************************************************
		Reclock("T4E",.T.)
		T4E->T4E_PRGORI  := cChamada
		T4E->T4E_FILIAL  := cT4EFilial
		T4E->T4E_MESAPU  := STR(cMes,2)
		T4E->T4E_ANOAPU  := STR(cAno,4)
		T4E->T4E_REG     := "K260"
		T4E->T4E_OP      := (cAliasTmp)->D3_OP
		T4E->T4E_PRODUT  := cPA
		T4E->T4E_DTSAID  := dDataProc //Data de saÌda do estoque
		T4E->T4E_QTSAID  := 0
		T4E->T4E_DTRET   := dDataProc //Data de retorno ao estoque (entrada) 
		T4E->T4E_QTRET   := (cAliasTmp)->QUANT 
		T4E->T4E_SEMRET  := "S" //Indicador de OP sem produto retrabalho - validador
		T4E->(MsUnlock())			
	Else
		//************************************************************************
		// Bloco K260 - ajuste de quantidades em multiplos apontamentos
		//************************************************************************	
		T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)+(cAliasTmp)->D3_OP+cPA+ cChamada ))
	    While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4EFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_OP == (cAliasTmp)->D3_OP .And. T4E->T4E_PRODUT == cPA .And. T4E->T4E_PRGORI == cChamada	    				
			RecLock("T4E",.F.,.T.)		    	

			If Empty(T4E->T4E_DTSAID) .Or. dDataProc < T4E->T4E_DTSAID
				T4E->T4E_DTSAID  := dDataProc
				T4E->T4E_DTRET   := dDataProc
			EndIf

			T4E->T4E_QTRET   += (cAliasTmp)->QUANT
			T4E->(MsUnlock())
			T4E->(dbSkip())
	    EndDo
	EndIf		
	(cAliasTmp)->(dbSkip())	
EndDo
(cAliasTmp)->(dbCloseArea())

//******************************************
// Grava tabela tempor·ria para rodar o SPED
//******************************************
T4E->(dbSetOrder(1))
T4E->(dbSeek(cT4EFilial+STR(cMes,2)+STR(cAno,4)))
While T4E->(!Eof()) .And. T4E->T4E_FILIAL == cT4EFilial .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4)
	If T4E->T4E_PRGORI == cChamada
		Reclock(cAliK260,.T.)
		(cAliK260)->FILIAL     := T4E->T4E_FILIAL
		(cAliK260)->REG        := T4E->T4E_REG
		(cAliK260)->COD_ITEM   := T4E->T4E_PRODUT
		(cAliK260)->COD_OP_OS  := T4E->T4E_OP	
		(cAliK260)->DT_SAIDA   := T4E->T4E_DTSAID
		(cAliK260)->QTD_SAIDA  := T4E->T4E_QTSAID
		(cAliK260)->DT_RET     := T4E->T4E_DTRET
		(cAliK260)->QTD_RET    := T4E->T4E_QTRET	
		(cAliK260)->(MsUnLock())
		nRegsto++
	EndIf
	T4E->(dbSkip())
EndDo
MsUnlock()

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK235V12     ≥ Autor ≥ Materiais        ≥ Data ≥ 28/07/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao do Registro K235           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliasTRB   = Alias do arquivo de trabalho do Bloco         ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK235V12(cAliK235,dDataDe,dDataAte,cAliK270,cAliK275)

Local cQuery	:= ""
Local cAliasTmp	:= GetNextAlias()
Local cSD4Filial:= ""
Local cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local aProdNeg	:= {}
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

cQuery := "SELECT SUM(CASE WHEN SD3.D3_CF LIKE ('DE%') THEN (SD3.D3_QUANT*-1) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END) QUANT, "
cQuery += "SD3.D3_COD, SD3.D3_OP, MAX(D3_EMISSAO) D3_EMISSAO, SD3.D3_FILIAL FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIF
//tratamento para a concatenÁ„o no postgres.		
If TCGetDB() $ "POSTGRES"
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) AND "	           			           					
Else
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AND "		          			          				
EndIf

cQuery += "SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND SC2.C2_TPPR IN ('I',' ') "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1_OP ON SB1_OP.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1_OP.B1_COD = SC2.C2_PRODUTO AND SB1_OP.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ_OP ON SBZ_OP.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ_OP.BZ_COD = SB1.B1_COD AND SBZ_OP.D_E_L_E_T_ = ' ' " 
EndIF
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D_E_L_E_T_ = ' ' AND "
cQuery += "SD3.D3_ESTORNO = ' ' AND SD3.D3_OP <> ' ' AND "
cQuery += "(SD3.D3_CF LIKE ('RE%') OR SD3.D3_CF LIKE ('DE%')) AND SB1.B1_CCCUSTO = ' ' AND "
cQuery += "SB1.B1_COD NOT LIKE 'MOD%' AND D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND "
cQuery += "'"+DtoS(dDataAte)+"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_CF <> 'DE1' AND "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += "	IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") AND "
cQuery += "SB1_OP.B1_CCCUSTO = ' ' AND SB1_OP.B1_COD NOT LIKE 'MOD%' AND "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ_OP.BZ_TIPO,SB1_OP.B1_TIPO)"
Else
	cQuery += "SB1_OP.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL "
cQuery += "Having (Sum(CASE WHEN SD3.D3_CF LIKE ( 'DE%' ) THEN ( SD3.D3_QUANT * -1 ) "
cQuery += "WHEN SD3.D3_CF LIKE ('RE%') THEN (SD3.D3_QUANT) ELSE 0 END)) <> 0 "
cQuery += "ORDER BY 4,3,2"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If lEstMov
	dbSelectArea("SD4")
	dbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
EndIf

cSD4Filial := xFilial("SD4")
While !(cAliasTmp)->(Eof())
	If (cAliasTmp)->QUANT >= 0
		Reclock(cAliK235,.T.)
		(cAliK235)->FILIAL          := (cAliasTmp)->D3_FILIAL
		(cAliK235)->REG             := "K235"
		(cAliK235)->DT_SAIDA        := StoD((cAliasTmp)->D3_EMISSAO)
		(cAliK235)->COD_ITEM        := (cAliasTmp)->D3_COD
		(cAliK235)->QTD             := (cAliasTmp)->QUANT
		(cAliK235)->COD_DOC_OP      := (cAliasTmp)->D3_OP
		(cAliK235)->COD_INS_SU      := GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)
		If lEstMov
			If SD4->(MsSeek(cSD4Filial+(cAliK235)->(COD_DOC_OP+COD_ITEM)))
				(cAliK235)->EMPENHO := "S"
			EndIf
		EndIf
		(cAliK235)->(MsUnLock())
		nRegsto++
		(cAliasTmp)->(dbSkip())
	Else
		AADD(aProdNeg,{(cAliasTmp)->D3_FILIAL,"K235",StoD((cAliasTmp)->D3_EMISSAO),(cAliasTmp)->D3_COD,(cAliasTmp)->QUANT,;
			(cAliasTmp)->D3_OP,GetSubst((cAliasTmp)->D3_COD,(cAliasTmp)->D3_OP,dDataDe,dDataAte)}) 
		(cAliasTmp)->(dbSkip())
	EndIf
EndDo

If Len(aProdNeg) > 0
	REGK27X(cAliK270,cAliK275,dDataDe,dDataAte,aProdNeg,aProdNeg[1][2])
EndIf	

(cAliasTmp)->(dbCloseArea())

Return


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK230V12     ≥ Autor ≥ Materiais        ≥ Data ≥ 28/07/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao do Registro K230           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliasTRB   = Alias do arquivo de trabalho do Bloco         ≥±±
±±≥          ≥ cAliK235    = Alias do arquivo de trabalho do K235          ≥±±
±±≥          ≥ cAli0210    = Alias do arquivo de trabalho do 0210          ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK230V12(cAliK230,cAliK235,cAli0210,dDataDe,dDataAte,lRepross)

Local cQuery	:= ""
Local cFilSC2	:= xFilial("SC2")
Local cAliasTmp	:= GetNextAlias()
Local cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cCharSoma  := If(TCGetDB() $ "ORACLE/POSTGRES/DB2/400/INFORMIX"," || "," + ")

cQuery := "SELECT SUM(SD3.D3_QUANT) QUANT, SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf
cQuery += "SC2.C2_DATPRI DTINI, SC2.C2_DATRF DTFIM, SC2.C2_QUANT QTDORI FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
EndIf
//tratamento para a concatenÁ„o no postgres.		
If TCGetDB() $ "POSTGRES"
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = TRIM(SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD) AND "	           			           					
Else
	cQuery += "JOIN "+RetSqlName("SC2")+" SC2 ON SD3.D3_OP = SC2.C2_NUM" + cCharSoma + "SC2.C2_ITEM" + cCharSoma + "SC2.C2_SEQUEN" + cCharSoma + "SC2.C2_ITEMGRD AND "		          			          				
EndIf
cQuery += "SC2.C2_FILIAL = '"+xFilial('SC2')+"' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_ITEM <> 'OS' AND "
cQuery += "SC2.C2_PRODUTO = SD3.D3_COD AND SC2.C2_TPPR IN ('I',' ') "
cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' AND SD3.D_E_L_E_T_ = ' ' AND SD3.D3_ESTORNO = ' ' AND "
cQuery += "SD3.D3_OP <> ' ' AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_COD NOT LIKE 'MOD%' AND "
cQuery += "SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' AND "
cQuery += "SB1.B1_CCCUSTO = ' ' AND " 
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) " 
Else
	cQuery += "SB1.B1_TIPO "
EndIf
cQuery += " IN ("+cTipo03+","+cTipo04+") AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY SD3.D3_OP, SD3.D3_COD, SD3.D3_FILIAL, "
If cDadosProd == 'SBZ' .And. lCpoBZTP
	cQuery += MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO), " 
Else
	cQuery += "SB1.B1_TIPO, "
EndIf
cQuery += "SC2.C2_DATPRI, SC2.C2_DATRF, SC2.C2_QUANT "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	Reclock(cAliK230,.T.)
	(cAliK230)->FILIAL			:= (cAliasTmp)->D3_FILIAL
	(cAliK230)->REG				:= "K230"
	(cAliK230)->DT_INI_OP		:= GetIniProd((cAliasTmp)->D3_OP)
	(cAliK230)->DT_FIN_OP		:= If(StoD((cAliasTmp)->DTFIM) > dDataAte,StoD(""),StoD((cAliasTmp)->DTFIM))
	(cAliK230)->COD_DOC_OP		:= (cAliasTmp)->D3_OP
	(cAliK230)->COD_ITEM		:= (cAliasTmp)->D3_COD
	(cAliK230)->QTD_ENC			:= (cAliasTmp)->QUANT
	(cAliK230)->QTDORI			:= (cAliasTmp)->QTDORI
	(cAliK230)->(MsUnLock())
	nRegsto++
	(cAliasTmp)->(dbSkip())
EndDo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Inicia a Gravacao das Producoes Zeradas, nas situacoes    ≥
//≥ em que houveram apenas Requisicoes no Periodo de Apuracao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

dbselectArea(cAliK230)
dbSetOrder(1)
dbSelectArea("SC2")
dbSetOrder(1)
(cAliK235)->(dbGoTop())

While !(cAliK235)->(Eof())
	If !(cAliK230)->(DBSeek((cAliK235)->FILIAL+(cAliK235)->COD_DOC_OP))
		If (SC2->(MsSeek(cFilSC2+(cAliK235)->COD_DOC_OP)))
			Reclock(cAliK230,.T.)
			(cAliK230)->FILIAL			:= (cAliK235)->FILIAL
			(cAliK230)->REG				:= "K230"
			(cAliK230)->DT_INI_OP		:= GetIniProd((cAliK235)->COD_DOC_OP)
			(cAliK230)->DT_FIN_OP		:= If(SC2->C2_DATRF > dDataAte,StoD(""),SC2->C2_DATRF)
			(cAliK230)->COD_DOC_OP		:= (cAliK235)->COD_DOC_OP
			(cAliK230)->COD_ITEM		:= SC2->C2_PRODUTO
			(cAliK230)->QTD_ENC			:= 0
			(cAliK230)->QTDORI			:= SC2->C2_QUANT
			(cAliK230)->(MsUnLock())
			nRegsto++
		EndIf
	EndIf
	(cAliK235)->(dbSkip())
EndDo

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Gravacao do Registro 0210 com base nas producoes do Registro K230        ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If !lEstMov
	(cAliK230)->(dbGoTop())
	While !(cAliK230)->(Eof())
		REG0210(cAli0210,(cAliK230)->COD_ITEM,dDataDe,dDataAte,(cAliK230)->COD_DOC_OP,.T.,lRePross)
		(cAliK230)->(dbSkip())
	EndDo
EndIf

(cAliasTmp)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTmp
Cria tabelas tempor·rias do bloco parametrizado.
    
@author Renan Roeder
@since  Nov 13, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function PCPTabTemp(cBloco)
Local cAliasTRB := ""
Local nX := 0
Local aStrReg := {}
//Local cVerBlk := VerBlocoK(dDataDe)
Local aLayout := {}

aLayout := SPDLayout(cBloco)

cAliasTRB := UPPER(cBloco)+"_"+CriaTrab(,.F.)

// aStrReg
//      [1] := Alias da tabela temporaria a ser criada
//      [2] := Nome da tabela temporaria criada via dbcreate no driver sqlite
//      [3,n] := Conjunto de nome de indices da tabela quando a tabela È cria 
//      [4] := Objeto criado via FWTemporaryTable
//
aStrReg := {cAliasTRB ,NIL ,{} ,NIL}

aStrReg[4] := FWTemporaryTable():New( aStrReg[1] ) 
aStrReg[4]:SetFields( aClone(aLayout[1]) )
For nX := 1 to len(aLayout[2])
    aStrReg[4]:AddIndex(StrZero(nX,2), aClone(aLayout[2,nX]) )
Next nX
aStrReg[4]:Create()

Return cAliasTRB

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ REGK26X        ≥ Autor ≥ Materiais        ≥ Data ≥ 11/08/16 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao responsavel pela gravacao dos Registros K260 e K265  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAliK260    = Alias do arquivo de trabalho do K260          ≥±±
±±≥          ≥ cAliK265    = Alias do arquivo de trabalho do K265          ≥±±
±±≥          ≥ dDataDe     = Data Inicial da Apuracao                      ≥±±
±±≥          ≥ dDataAte    = Data Final da Apuracao                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function REGK26X(cAliK260,cAliK265,dDataDe,dDataAte)

If Existblock("REGK26X")
	Execblock("REGK26X",.F.,.F.,{cAliK260,cAliK265,dDataDe,dDataAte})
EndIf

Return

/*/{Protheus.doc} VldBlkTp
	FunÁao para validar o conte˙do dos par‚metros MV_BLKTP.
	N„o È permitido informar nos par‚metros MV_BLKTP o mesmo valor padr„o definido.
	Por exemplo:
	MV_BLKTP02 o default È tipo 'EM'
    MV_BLKTP05 se informar 'SP','EM' barrar o processamento do bloco K
	Pois, o tipo 'EM' est· redundante.
	@type  Function
	@author ana.paula
	@since 22/07/2022
	/*/
Function VldBlkTp(aTipos)

Local aValidacao := {}
Local lRet       := .T.
Local nExist     := 0
Local nTipo      := 0
Local cTipos := ''
Default aTipos     := {}

If Empty(aTipos)
    cTipos := ''
    cTipos += If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) + ','// 00: Mercadoria Revenda
    cTipos += If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) + ',' // 01: Materia-Prima
    cTipos += If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) + ',' // 02: Embalagem
    cTipos += If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) + ',' // 03: Produto em Processo
    cTipos += If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) + ',' // 04: Produto Acabado
    cTipos += If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) + ',' // 05: SubProduto
    cTipos += If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) + ',' // 06: Produto Intermediario
    cTipos += If(SuperGetMv("MV_BLKTP07",.F.,"'MC'")== " ","'MC'", SuperGetMv("MV_BLKTP07",.F.,"'MC'")) + ',' // 07: Material de Consumo
    cTipos += If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'"))  // 10: Outros Insumos
   
   aTipos := STRTOKARR( cTipos, ',')
EndIf

For nTipo := 1 to len(aTipos)
	nExist := aScan(aValidacao,{|x|x==aTipos[nTipo]})
	If nExist <= 0
		Aadd(aValidacao, aTipos[nTipo])
	else
		lRet := .F.
		exit
	EndIf
Next nTipo
	
Return lRet

/*/{Protheus.doc} GrvOpSC2(cError)
    @type  Static Function
    @author Michele Lais Girardi
    @since 08/11/2022
    @version 1.0
    @param cError, Char, DescriÁ„o do erro
    @return lRet, LÛgico, Indica se atualizou as ordens com sucesso
    /*/
Function GrvOpSC2()

	Local lRet    := .T.
	Local cSql    := ""
	Local nResult := 0

	Static cGrvOp

	If cGrvOp == Nil
		cSql := " UPDATE " + RetSqlName("SC2") + " SET C2_OP = "

    	If Upper(TcGetDb()) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
			cSql += " C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD "
		Else
			cSql += " C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD "
		EndIf

		cSql += " WHERE C2_FILIAL  = '" + xFilial("SC2") + "' "
		cSql +=   " AND D_E_L_E_T_ = ' ' "
		cSql +=   " AND C2_OP      = ' ' "

		nResult := TcSqlExec(cSql)

		If nResult < 0
			//cError := TCSQLError() + cSql
			//lRet   := .F.
		EndIf

		cGrvOp := 'S'
	EndIf

Return lRet

/*/{Protheus.doc} ProcDelAli
	FunÁ„o para limpar as tabelas (Alias) dos registros que n„o s„o gerados no leiaute simplicado
	do Bloco K
	@type  Function
	@author ana.paula
	@since 07/12/2022
	@version version
	/*/
Function ProcDelAli()

aChave270 := {}
nPos      := 0

	If !Empty(cK235Ali)
		(cK235Ali)->(dbGoTop())
		While !(cK235Ali)->(Eof())
			Reclock(cK235Ali,.F.)
			DbDelete()
			(cK235Ali)->(MsUnLock())
			nRegsto--
			(cK235Ali)->(dbSkip())
		EndDo
	EndIf

	If !Empty(cK270Ali)
		(cK270Ali)->(dbGoTop())
		While !(cK270Ali)->(Eof())
			If (cK270Ali)->ORIGEM == "4" .Or. (cK270Ali)->ORIGEM == "7"				 
				Reclock(cK270Ali,.F.)
				DbDelete()
				(cK270Ali)->(MsUnLock())
				nRegsto--
			EndIf

			If (cK270Ali)->ORIGEM == "1" .And. (cK270Ali)->QTD_COR_N == 0 .And. (cK270Ali)->QTD_COR_P == 0
				Reclock(cK270Ali,.F.)
				DbDelete()
				(cK270Ali)->(MsUnLock())
				nRegsto--
			EndIf

			If (cK270Ali)->ORIGEM == "1" .Or. (cK270Ali)->ORIGEM == "4" .Or.; 		 
				(cK270Ali)->ORIGEM == "6" .Or. (cK270Ali)->ORIGEM == "7" 
				AADD(aChave270,(cK270Ali)->CHAVE)
			EndIf

			(cK270Ali)->(dbSkip())
		EndDo
	EndIf

	If !Empty(cK275Ali)
		(cK275Ali)->(dbGoTop())
		While !(cK275Ali)->(Eof())
			nPos := aScan(aChave270,{|x| x == (cK275Ali)->CHAVE })

			If nPos > 0
				Reclock(cK275Ali,.F.)
				DbDelete()
				(cK275Ali)->(MsUnLock())	
				nRegsto--			
			EndIf
			(cK275Ali)->(dbSkip())
		EndDo
	EndIf

	If !Empty(cK292Ali)
		(cK292Ali)->(dbGoTop())
		While !(cK292Ali)->(Eof())
			Reclock(cK292Ali,.F.)
			DbDelete()
			(cK292Ali)->(MsUnLock())
			nRegsto--
			(cK292Ali)->(dbSkip())
		EndDo
	EndIf		

Return 

/*/{Protheus.doc} fAjus270()
    @type  Static Function
    @author Michele Lais Girardi
    @since 06/06/2023
    @version 1.0
    @param cMes, cAno
    @return nil
    /*/
Static Function fAjus270(cMes, cAno)

Local cAlias1  := GetNextAlias()
Local cAlias2  := GetNextAlias()
Local cQuery1  := ""
Local cQuery2  := ""
Local cQuery3  := ""
Local cOp      := ""

//Existem casos em que a produÁ„o È de um SP e no mÍs corrente a OP n„o È listada no K230 - OK
//PorÈm no mÍs seguinte essa produÁ„o est· entrando incorretamente como uma correÁ„o
// ISSUE - DMANSMARTSQUAD1-26922
//Foi criada a funÁ„o para excluir essas OPs no arquivo de correÁ„o K270

//Busca todas OPs do K270 referente ao K291
//CorreÁıes de co-produto
cQuery1 := " SELECT DISTINCT T4G.T4G_COD_OP "
cQuery1 += "   FROM " + RetSqlName("T4G") + " T4G " 
cQuery1 += "  WHERE T4G.T4G_ANOSPE = '" + STR(cAno,4) + "' " 
cQuery1 += "    AND T4G.T4G_MESSPE = '" + STR(cMes,2) + "' "
cQuery1 += "    AND T4G.T4G_REG    = 'K270' "
cQuery1 += "    AND T4G.T4G_BLK_CO = 'K291' "
cQuery1 += "    AND T4G.T4G_FILIAL = '" +xFilial("T4G")+ "' "
cQuery1 += "    AND T4G.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cAlias1,.T.,.T.)	

While (cAlias1)->(!Eof())
	cOp :=  (cAlias1)->T4G_COD_OP

	//verificar para a OP se existe um K291 cujo produto seja PA ou PP
	cQuery2 := " SELECT COUNT(*) REGS "
	cQuery2 += "   FROM " + RetSqlName("T4G") + " T4G, " + RetSqlName("SB1") + " SB1 " 
	cQuery2 += "  WHERE T4G.T4G_ANOSPE = '" + STR(cAno,4) + "' " 
	cQuery2 += "    AND T4G.T4G_MESSPE = '" + STR(cMes,2) + "' "
	cQuery2 += "    AND T4G.T4G_REG    = 'K270' "
	cQuery2 += "    AND T4G.T4G_BLK_CO = 'K291' "
	cQuery2 += "    AND T4G.T4G_FILIAL = '" +xFilial("T4G")+ "' "
	cQuery2 += "    AND T4G.D_E_L_E_T_  = ' ' "
	cQuery2 += "    AND T4G.T4G_COD_OP = '" + cOp + "' " 
	cQuery2 += "    AND SB1.B1_COD     = T4G.T4G_COD_IT "
	cQuery2 += "    AND SB1.B1_TIPO    IN ("+cTipo03+","+cTipo04+") "
	cQuery2 += "    AND SB1.B1_FILIAL   = '" +xFilial("SB1")+ "' "
	cQuery2 += "    AND SB1.D_E_L_E_T_  = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery2),cAlias2,.T.,.T.)

	If (cAlias2)->REGS == 0
		//Se n„o existir um K291 cujo produto seja PA ou PP excluir - N„o deve listar
		cQuery3 := " DELETE FROM " + RetSqlName("T4G") + " " 
		cQuery3 += "  WHERE T4G_ANOSPE = '" + STR(cAno,4) + "' " 
		cQuery3 += "    AND T4G_MESSPE = '" + STR(cMes,2) + "' "
		cQuery3 += "    AND T4G_REG    = 'K270' "
		cQuery3 += "    AND T4G_FILIAL = '" +xFilial("T4G")+ "' "
		cQuery3 += "    AND T4G_COD_OP = '" + cOp + "' " 
		cQuery3 += "    AND D_E_L_E_T_  = ' ' "
		MATExecQry(cQuery3)
	EndIf
	(cAlias2)->(dbCloseArea())

	(cAlias1)->(dbSkip())
EndDo
	
(cAlias1)->(dbCloseArea())

Return 

/*/{Protheus.doc} LockSPEDBlk()
	FunÁ„o para ligar/desligar sem·foro de indicaÁ„o do processamento do Bloco K
    @type  Function
    @author Ana Paula dos Santos
    @since 12/04/2024
    @version 1.0
    @param lBloqueio, logical, indica se liga ou desliga o sem·foro (T=Liga/F=Desliga)
    @return lRet, logical, indica se o Bloco K j· est· em processamento (T=j· est· em processamento/F=n„o est· em processamento)
    /*/
Function LockSPEDBlk(lBloqueio)
Local lLockBlk := (SUPERGETMV("MV_LOCKBLK", .T., "N") == "S")
Local lRet     := .F.
Local cRotina  := FunName()

Default lBloqueio := .F.

if lLockBlk
	If lBloqueio 
		if !LockByName("EXECBLK",.T.)
			Help( ,, cRotina,,STR0001, 1, 0 )//"Processamento do Bloco K j· est· em execuÁ„o." 		
			lRet := .T.
		endif
	else
		UnLockByName("EXECBLK",.T.)
	EndIf
Endif

Return lRet

/*/{Protheus.doc} AtuD3K235()
	FunÁ„o para atualizar o campo D3_PERBLK referente ao K235
    @type  Static Function
    @author Michele Lais Girardi
    @since 20/08/2024
    @version 1.0
    @param 
    @return 
/*/
Static Function AtuD3K235(dDataDe,dDataAte)

Local cAliasTot  := GetNextAlias()
Local cAnoDe     := Year(dDataDe)
Local cMesDe     := Month(dDataDe)
Local cAnoAte    := Year(dDataAte)
Local cMesAte    := Month(dDataAte)
Local cEmissao   := ""
Local cQuery     := ""
Local cTabD3     := ""
Local cUpdateD3  := ""
Local lAtu       := .T.
Local n1         := 0
Local nDias      := 0
Local nTotal     := 0

//Se estiver processando para o mesmo mÍs e ano
If cMesDe == cMesAte .And. cAnoDe == cAnoAte

	nTotal := 0
	cQuery := " SELECT COUNT(*) qtd_total "
	cQuery += "   FROM TR235U5 "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTot,.T.,.T.)

	If !(cAliasTot)->(Eof())
		nTotal := (cAliasTot)->qtd_total
	EndIf

	(cAliasTot)->(dbCloseArea())

	lAtu := .T.
	If nTotal > 0
		lAtu := .F.

		//Busca a diferenÁa em dias
		nDias := DateDiffDay(dDataDe, dDataAte) + 1

		For n1 := 1 TO nDias
			
			If n1 > 1
				dDataNova := DaySum(dDataNova, 1)
				cEmissao := DtoS(dDataNova)					
			Else				
				dDataNova := dDataDe
				cEmissao  := DtoS(dDataNova)	
			EndIf

			ProcLogAtu('PCP K235',"AtuD3K235 PCP K235 - DATA ATU " + cEmissao + ". INICIO UPDATE PERBLK : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))

			cTabD3 := RetSqlName("SD3")
			cRecD3 := cTabD3 +'.R_E_C_N_O_'

			cUpdateD3 := " UPDATE " + cTabD3 + " " 
			cUpdateD3 += "    SET D3_PERBLK = '" + STR(cMesDe,2) + STR(cAnoDe,4) + "' "
			cUpdateD3 += "  WHERE EXISTS ( SELECT 1  "
			cUpdateD3 += "                   FROM TR235U5 SD3_1   "
			cUpdateD3 += "                  WHERE SD3_1.TU5_EMIS = '" + cEmissao + "' " 
			cUpdateD3 += "                    AND SD3_1.TU5_RECNO = " +cRecD3+ " ) "

			MATExecQry(cUpdateD3)

			ProcLogAtu('PCP K235',"AtuD3K235 PCP K235 - DATA ATU " + cEmissao + ". FIM UPDATE PERBLK : " + Alltrim(DtoC(Date())) + " - " + Alltrim(Time()))
		Next n1					
	EndIf	
Else
	lAtu := .T.
EndIf

If lAtu
	cTabD3 := RetSqlName("SD3")
	cRecD3 := cTabD3 +'.R_E_C_N_O_'

	cUpdateD3 := " UPDATE " + cTabD3 + " " 
	cUpdateD3 += "    SET D3_PERBLK = '" + STR(cMesDe,2) + STR(cAnoDe,4) + "' "
	cUpdateD3 += "  WHERE EXISTS ( SELECT 1  "
	cUpdateD3 += "                   FROM TR235U5 SD3_1   "
	cUpdateD3 += "                  WHERE SD3_1.TU5_RECNO = " +cRecD3+ " ) "

	MATExecQry(cUpdateD3)
EndIf	

Return 
