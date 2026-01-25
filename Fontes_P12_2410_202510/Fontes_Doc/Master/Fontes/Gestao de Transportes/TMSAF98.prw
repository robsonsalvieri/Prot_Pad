#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TMSAF98.CH"

/*
{Protheus.doc} TMSAF98()
Gera Integração Protheus x YMS
@type  Function
@author Valdemar Roberto Mognon
@since 03/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF98()

/*
Transportadora de ?		MV_PAR01
Transportadora até ?	MV_PAR02
Motorista de ?			MV_PAR03
Motorista até ?			MV_PAR04
Veículo de ?			MV_PAR05
Veículo até ?			MV_PAR06
Cliente de ?			MV_PAR07
Loja de ?				MV_PAR08
Cliente até ?			MV_PAR09
Loja até ?				MV_PAR10
Produto de ?			MV_PAR11
Produto até ?			MV_PAR12
Reenviar registros ?	MV_PAR13
*/

/*
Aadd(aParamBox,{9,STR0004,,20,12,.T.})				//-- "Notas Fiscais"
Aadd(aParamBox,{5,STR0035,.F.,60,,.T.})				//-- "Notas"
Aadd(aParamBox,{5,STR0036,.F.,60,,.T.})				//-- "Produtos das Notas"
Aadd(aParamBox,{5,STR0037,.F.,60,,.T.})				//-- "Clientes das Notas"

Aadd(aParamBox,{9,STR0005,,20,12,.T.})				//-- "Documentos de Transporte"
Aadd(aParamBox,{5,STR0038,.F.,60,,.T.})				//-- "Documentos"
Aadd(aParamBox,{5,STR0039,.F.,60,,.T.})				//-- "Produtos dos Documentos"
Aadd(aParamBox,{5,STR0040,.F.,60,,.T.})				//-- "Clientes dos Documentos"

Aadd(aParamBox,{1,STR0006,dDataIni,"","","","",50,.T.})	//-- "Data Inicial"
Aadd(aParamBox,{1,STR0007,dDataFim,"","","","",50,.T.})	//-- "Data Final"
Aadd(aParamBox,{2,STR0008,2,aJaEnv,50,"",.T.}) 			//-- "Já Enviados"
If ParamBox(aParamBox,STR0001,@aRetParam)	//-- "Gera Integração Protheus x YMS"*/
If Pergunte( 'TMSAF98', .T. )
	//-- Cadastros
	If !Empty(MV_PAR02)
		FWMsgrun( , { || Tmsaf98Qry( 1, 1, , , MV_PAR13, MV_PAR01, MV_PAR02 ) }, STR0010, STR0011 )	//-- "Aguarde" ### "Selecionando Cadastros das Transportadoras"
	EndIf
	If !Empty(MV_PAR04)
		FWMsgrun( , { || Tmsaf98Qry( 1, 2, , , MV_PAR13, MV_PAR03, MV_PAR04 ) }, STR0010, STR0011 )	//-- "Aguarde" ### "Selecionando Cadastros dos Motoristas"
	EndIf
	If !Empty(MV_PAR06)
		FWMsgrun( , { || Tmsaf98Qry( 1, 3, , , MV_PAR13, MV_PAR05, MV_PAR06 ) }, STR0010, STR0011 )	//-- "Aguarde" ### "Selecionando Cadastros dos Veículos"
	EndIf
	/*If aParams[5]
		FWMsgrun(,{|| Tmsaf98Qry(1,4,,,aParams[nTamPar])},STR0010,STR0011)	//-- "Aguarde" ### "Selecionando Cadastros dos Fornecedores"
	EndIf*/

	//-- Pedidos
	If !Empty(MV_PAR12)
		FWMsgrun( , { || Tmsaf98Qry( 2, 2, , , MV_PAR13, MV_PAR11, MV_PAR12 ) }, STR0010, STR0012 )	//-- "Aguarde" ### "Selecionando Produtos dos Pedidos"
	EndIf
	If !Empty(MV_PAR09) .AND. !Empty(MV_PAR10)
		FWMsgrun( , { || Tmsaf98Qry( 2, 3, , , MV_PAR13 ) }, , )	//-- "Aguarde" ### "Selecionando Clientes dos Pedidos"
	EndIf
	/*If aParams[6]
		FWMsgrun(,{|| Tmsaf98Qry(2,1,aParams[nTamPar-2],aParams[nTamPar-1],aParams[nTamPar])},STR0010,STR0012)	//-- "Aguarde" ### "Selecionando Movimento de Pedidos"
	EndIf*/
EndIf

Return

/*
{Protheus.doc} TMSAF98Qry()
Selecionando os registros
@type  Function
@author Valdemar Roberto Mognon
@since 03/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMSAF98Qry( nAcao, nTabela, dDatIni, dDatFim, nTipo, cParDe, cParAte )

Local cQuery    := ""
Local cCodFon   := ""
Local cAlias    := ""
Local cCodReg   := ""
Local cBasCpo   := ""
Local cCodRegOri:= ""
Local cCodFonOri:= ""
Local cTabConf	:= ""
Local cSGBD		:= Upper(TCGetDB())
Local oYMS		:= Nil
Local oAgend	:= Nil
Local aCodReg   := {}
Local lB1Block	:= SB1->( ColumnPos( 'B1_MSBLQL' ) ) > 0
Local lA1Block	:= SA1->( ColumnPos( 'A1_MSBLQL' ) ) > 0

Default nAcao   := 0
Default nTabela := 0
Default dDatIni := dDataBase - 1
Default dDatFim := dDataBase - 1
Default nTipo   := 0

nTipo := If(ValType(nTipo) == "C", Val(nTipo), nTipo )

oYMS  := TMSBCACOLENT():New("DNS")

oAgend  := TMSBCACOLENT():New("DNT")

If oAgend:DbGetToken() .And. !Empty(oAgend:filext)
	cCodFon	 := "11"
	cTabConf := "DNT"
ElseIf oYMS:DbGetToken() .And. !Empty(oYMS:filext)
	cCodFon	 := "10"
	cTabConf := "DNS"
EndIf

aCodReg    := {	{ 1, 1, "SA4", "1000", "A4",	cCodFon },;
				{ 1, 2, "DA4", "2000", "DA4",	cCodFon },;
				{ 1, 3, "DA3", "3000", "DA3",	cCodFon },;//{1,4,"SA2","4000", "A2","10"},
				{ 2, 1, "SC9", "6000", "C9",	cCodFon },;
				{ 2, 2, "SB1", "5000", "B1",	cCodFon },;
				{ 2, 3, "SA1", "4000", "A1",	cCodFon } }
				//{3,1,"SF2","5020", "F2","10"},{3,2,"SB1","5021", "B1","10"},{3,3,"SA1","5022", "A1","10"},;
				//{4,1,"DT6","5030","DT6","10"},{4,2,"SB1","5031", "B1","10"},{4,3,"SA1","5032", "A1","10"}}

If nAcao > 0 .And. nTabela > 0
	cAlias     := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == nTabela}),3]
	cCodReg    := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == nTabela}),4]
	cBasCpo    := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == nTabela}),5]
	cCodFon    := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == nTabela}),6]
	If nAcao > 1
		cCodRegOri := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == 1}),4]
		cCodFonOri := aCodReg[Ascan(aCodReg,{|x| x[1] == nAcao .And. x[2] == 1}),6]
	EndIf
EndIf

If nAcao == 1 .OR. nAcao == 2	//-- Cadastros - Fornecedores - Motoristas - Veículos
	cQuery := " SELECT "
	
	If !(cSGBD $ "ORACLE|POSTGRES|DB2|MYSQL")
		cQuery += " TOP 100 "
	EndIf

	cQuery += cAlias + ".R_E_C_N_O_ REGISTRO "
	cQuery += " FROM " + RetSqlName(cAlias) + " " + cAlias + " "
	cQuery += " WHERE " + cBasCpo + "_FILIAL = '" + xFilial(cAlias) + "' "
	
	If cAlias <> "SA1"
		cQuery += " AND " + cBasCpo + "_COD BETWEEN '" + cParDe + "' AND '" + cParAte + "' "
	Else
		cQuery += " AND A1_COD BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR09 + "' "
		cQuery += " AND A1_LOJA BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR10 + "' "
		cQuery += " AND A1_EST <> 'EX' "
	EndIf

	If nTipo == 1	//-- Somente os já enviados
		cQuery += " AND EXISTS ( SELECT 1 "
		cQuery += 				" FROM " + RetSqlName("DN4") + " DN4 "
		cQuery += 				" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
		cQuery += 						" AND DN4_CODFON = '" + cCodFon + "' "
		cQuery += 						" AND DN4_CODREG = '" + cCodReg + "' "
		cQuery += 						" AND DN4_CHAVE  = (" + cBasCpo + "_FILIAL + " + cBasCpo + "_COD) "
		cQuery += 						" AND DN4.D_E_L_E_T_ = ' ')"
	ElseIf nTipo == 2	//-- Somente os ainda não enviados
		cQuery += " AND NOT EXISTS ( SELECT 1 "
		cQuery += 					" FROM " + RetSqlName("DN4") + " DN4 "
		cQuery += 					" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
		cQuery += 							" AND DN4_CODFON = '" + cCodFon + "' "
		cQuery += 							" AND DN4_CODREG = '" + cCodReg + "' "
		cQuery += 							" AND DN4_CHAVE  = (" + cBasCpo + "_FILIAL + " + cBasCpo + "_COD) "
		cQuery += 							" AND DN4.D_E_L_E_T_ = ' ')"
	EndIf

	If ( cAlias == 'SA1' .AND. lA1Block ) .OR. ( cAlias == 'SB1' .AND. lB1Block )
		cQuery += " AND " + cBasCpo + "_MSBLQL <> '1' "
	EndIf
	
	If cSGBD $ "ORACLE"
		cCond   += " AND ROWNUM < 100 "
	ElseIf cSGBD == "POSTGRES" .OR. cSGBD == "MYSQL" .OR. cSGBD == "DB2"
		cCond   += " AND LIMIT 100 "
	EndIf

	cQuery += "   AND " + cAlias + ".D_E_L_E_T_ = ' ' "

	If cAlias $ 'SA1|SB1'
		cQuery += " ORDER BY " + cAlias + ".R_E_C_N_O_ DESC "
	EndIf

	cQuery := ChangeQuery(cQuery)
	FWMsgrun( , { || Tmsaf98DN5( nAcao, nTabela, cQuery, cAlias, cCodFon, cCodReg ) }, STR0010, STR0015 )	//-- "Aguarde" ### "Processando Cadastro de Transportadoras"
EndIf
/*
If nAcao == 2 .AND. cCodFon == "11"	//-- Pedidos Liberados
	If nTabela == 2	//-- Produtos dos Pedidos
		cQuery := " SELECT SB1.R_E_C_N_O_ REGISTRO "
		cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
		cQuery +=		" JOIN " + RetSqlName("SC9") + " SC9 "
		cQuery +=				" ON C9_FILIAL  = '" + xFilial("SC9") + "' "
		cQuery +=				" AND C9_BLOQUEI = '" + Space(Len(SC9->C9_BLOQUEI)) + "' "
		cQuery +=				" AND C9_DATALIB BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery +=				" AND C9_PRODUTO = B1_COD "
		cQuery +=				" AND C9_NFISCAL = '" + Space(Len(SC9->C9_NFISCAL)) + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += 			" AND EXISTS ( SELECT 1 "
			cQuery += 							" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery +=							" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery +=							" AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery +=							" AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery +=							" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery +=							" AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += 			" AND NOT EXISTS ( SELECT 1 "
			cQuery += 								" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 								" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 										" AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery +=										" AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery +=										" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery +=										" AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=				" AND SC9.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += 	" AND EXISTS ( SELECT 1 "
			cQuery +=					" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 					" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 					" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += 					" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += 					" AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += 					" AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += 	" AND NOT EXISTS ( SELECT 1 "
			cQuery += 						" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 						" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 						" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += 						" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += 						" AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += 						" AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=	" AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=	" ORDER BY SB1.R_E_C_N_O_ "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5( nAcao, nTabela, cQuery, cAlias, cCodFon, cCodReg ) }, STR0010, STR0020 )	//-- "Aguarde" ### "Processando Cadastro de Produtos dos Pedidos"
	EndIf

	If nTabela == 3	//-- Clientes dos Pedidos
		cQuery := " SELECT SA1.R_E_C_N_O_ REGISTRO "
		cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
		cQuery += 		" JOIN " + RetSqlName("SC9") + " SC9 "
		cQuery += 				" ON C9_FILIAL  = '" + xFilial("SC9") + "' "
		cQuery += 				" AND C9_BLOQUEI = '" + Space(Len(SC9->C9_BLOQUEI)) + "' "
		cQuery += 				" AND C9_DATALIB BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery += 				" AND C9_CLIENTE = A1_COD "
		cQuery += 				" AND C9_LOJA    = A1_LOJA "
		cQuery += 				" AND C9_NFISCAL = '" + Space(Len(SC9->C9_NFISCAL)) + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += 			" AND EXISTS ( SELECT 1 "
			cQuery += 							" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 							" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 									" AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += 									" AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += 									" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery += 									" AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += 			" AND NOT EXISTS ( SELECT 1 "
			cQuery += 								" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery +=								" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery +=										" AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery +=										" AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery +=										" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery +=										" AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=				" AND SC9.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery +=	" AND EXISTS ( SELECT 1 "
			cQuery += 				" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 				" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 						" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += 						" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery +=						" AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery +=						" AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery +=	" AND NOT EXISTS ( SELECT 1 "
			cQuery += 					" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += 					" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += 							" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += 							" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += 							" AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery += 							" AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += 		" AND SA1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun( , { || Tmsaf98DN5( nAcao, nTabela, cQuery, cAlias, cCodFon, cCodReg ) }, STR0010, STR0021 )	//-- "Aguarde" ### "Processando Cadastro de Clientes dos Pedidos"
	EndIf

	If nTabela == 1	//-- Pedidos
		cQuery := " SELECT SC9.R_E_C_N_O_ REGISTRO, SC5.R_E_C_N_O_ SC5REG "
		cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
		cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
		cQuery +=				" ON SC5.C5_FILIAL = '" + FWxFilial("SC5") + "' AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE C9_FILIAL  = '" + xFilial("SC9") + "' "
		cQuery +=	" AND C9_BLOQUEI = '" + Space(Len(SC9->C9_BLOQUEI)) + "' "
		cQuery +=	" AND C9_DATALIB BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery +=	" AND C9_NFISCAL = '" + Space(Len(SC9->C9_NFISCAL)) + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += 	" AND EXISTS ( SELECT 1 "
			cQuery +=					" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery +=					" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery +=					" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery +=					" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery +=					" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery +=					" AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += 	" AND NOT EXISTS ( SELECT 1 "
			cQuery +=						" FROM " + RetSqlName("DN4") + " DN4 "
			cQuery +=						" WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery +=							" AND DN4_CODFON = '" + cCodFon + "' "
			cQuery +=							" AND DN4_CODREG = '" + cCodReg + "' "
			cQuery +=							" AND DN4_CHAVE  = (C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED) "
			cQuery +=							" AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=	" AND SC9.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tf98DN5Ped(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0019)	//-- "Aguarde" ### "Processando Movimento de Pedidos"
	EndIf

EndIf
If nAcao == 3	//-- Notas Fiscais
	If nTabela == 1	//-- Nota
		cQuery := "SELECT SF2.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " WHERE F2_FILIAL = '" + xFilial("SF2") + "' "
		cQuery += "   AND F2_EMISSAO BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND SF2.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0022)	//-- "Aguarde" ### "Processando Movimento de Notas Fiscais"
	EndIf

	If nTabela == 2	//-- Produtos das Notas
		cQuery := "SELECT SB1.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += "  JOIN " + RetSqlName("SF2") + " SF2 "
		cQuery += "    ON F2_FILIAL  = '" + xFilial("SF2") + "' "
		cQuery += "   AND F2_EMISSAO BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                  AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                      AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += "  JOIN " + RetSqlName("SD2") + " SD2 "
		cQuery += "    ON D2_FILIAL  = '" + xFilial("SD2") + "' "
		cQuery += "   AND D2_DOC     = F2_DOC "
		cQuery += "   AND D2_SERIE   = F2_SERIE "
		cQuery += "   AND D2_CLIENTE = F2_CLIENTE "
		cQuery += "   AND D2_LOJA    = F2_LOJA "
		cQuery += "   AND D2_COD     = B1_COD "
		cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0023)	//-- "Aguarde" ### "Processando Cadastro de Produtos das Notas Fiscais"
	EndIf

	If nTabela == 3	//-- Clientes das Notas
		cQuery := "SELECT SA1.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("SA1") + " SA1 "
		cQuery += "  JOIN " + RetSqlName("SF2") + " SF2 "
		cQuery += "    ON F2_FILIAL  = '" + xFilial("SF2") + "' "
		cQuery += "   AND F2_EMISSAO BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery += "   AND F2_CLIENTE = A1_COD "
		cQuery += "   AND F2_LOJA    = A1_LOJA "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                  AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                      AND DN4_CHAVE  = (F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND SF2.D_E_L_E_T_ = ' ' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0024)	//-- "Aguarde" ### "Processando Cadastro de Clientes das Notas Fiscais"
	EndIf
EndIf

If nAcao == 4	//-- Documentos de Transporte
	If nTabela == 1	//-- Documentos
		cQuery := "SELECT DT6.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "
		cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "   AND DT6_DATEMI BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery += "   AND DT6_BLQDOC <> '1' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0025)	//-- "Aguarde" ### "Processando Movimento de Documentos de Transporte"
	EndIf
	
	If nTabela == 2	//-- Produtos dos Documentos
		cQuery := "SELECT SB1.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "   AND DT6_DATEMI BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery += "   AND DT6_BLQDOC <> '1' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                  AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                      AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		cQuery += "  JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
		cQuery += "   AND DTC_DOC    = DT6_DOC "
		cQuery += "   AND DTC_SERIE  = DT6_SERIE "
		cQuery += "   AND DTC_CODPRO = B1_COD "
		cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (B1_FILIAL + B1_COD) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0026)	//-- "Aguarde" ### "Processando Cadastro de Produtos dos Documentos de Transporte"
	EndIf
	
	If nTabela == 3	//-- Clientes dos Documentos
		cQuery := "SELECT SA1.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("SA1") + " SA1 "
		cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "   AND DT6_DATEMI BETWEEN '" + DToS(dDatIni) + "' AND '" + DToS(dDatFim) + "' "
		cQuery += "   AND DT6_BLQDOC <> '1' "
		cQuery += "   AND DT6_CLIDEV = A1_COD "
		cQuery += "   AND DT6_LOJDEV = A1_LOJA "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                  AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFonOri + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodRegOri + "' "
			cQuery += "                      AND DN4_CHAVE  = (DT6_FILIAL + DT6_FILDOC + DT6_DOC + DT6_SERIE) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		If nTipo == 1	//-- Somente os já enviados
			cQuery += "   AND EXISTS (SELECT 1 "
			cQuery += "                 FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                  AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                  AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                  AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery += "                  AND DN4.D_E_L_E_T_ = ' ')"
		ElseIf nTipo == 2	//-- Somente os ainda não enviados
			cQuery += "   AND NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + RetSqlName("DN4") + " DN4 "
			cQuery += "                    WHERE DN4_FILIAL = '" + xFilial("DN4") + "' "
			cQuery += "                      AND DN4_CODFON = '" + cCodFon + "' "
			cQuery += "                      AND DN4_CODREG = '" + cCodReg + "' "
			cQuery += "                      AND DN4_CHAVE  = (A1_FILIAL + A1_COD + A1_LOJA) "
			cQuery += "                      AND DN4.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		FWMsgrun(,{|| Tmsaf98DN5(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)},STR0010,STR0027)	//-- "Aguarde" ### "Processando Cadastro de Clientes dos Documentos de Transporte"
	EndIf
EndIf
*/

Return

/*
{Protheus.doc} TMSAF98DN5()
Aciona a Gravação dos dados nas tabelas de integração.
@type  Function
@author Valdemar Roberto Mognon
@since 03/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSAF98DN5( nAcao, nTabela, cQuery, cAlias, cCodFon, cCodReg )

Local aAreas    := {GetArea()}
Local cAliasQry := ""
Local oYMS		:= Nil
Local oAgend	:= Nil
Local nReg		:= 0

Default nAcao   := 0
Default nTabela := 0
Default cQuery  := ""
Default cAlias  := ""
Default cCodFon := ""
Default cCodReg := ""

If nAcao > 0 .And. nTabela > 0 .And. !Empty(cQuery)
	DbSelectArea("DNS")
	DbSelectArea("DNT")
	//DbSelectArea("DNS")
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	While (cAliasQry)->(!Eof())
		
		If nReg <> (cAliasQry)->REGISTRO
			nReg := (cAliasQry)->REGISTRO
			&(cAlias + "->(DbGoTo(" + AllTrim(Str((cAliasQry)->REGISTRO)) + "))")

			oYMS  := TMSBCACOLENT():New("DNS")

			oAgend  := TMSBCACOLENT():New("DNT")
			
			If oAgend:DbGetToken() .And. !Empty(oAgend:filext)
				TMSF98Gdd( "DNT", oAgend, cAlias, cCodReg )
			ElseIf nAcao == 1 .AND. oYMS:DbGetToken() .And. !Empty(oYMS:filext)
				TMSF98Gdd( "DNS", oYMS, cAlias, cCodReg )
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())

	EndDo

	(cAliasQry)->(DbCloseArea())	
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*
{Protheus.doc} TMSAF98DN5()
Aciona a Gravação dos dados nas tabelas de integração.
@type  Function
@author Valdemar Roberto Mognon
@since 03/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
/*
Function Tf98DN5Ped(nAcao,nTabela,cQuery,cAlias,cCodFon,cCodReg)

Local aAreas    := {GetArea()}
Local cAliasQry := ""
Local cSubProc	:= "0003"
Local oAgend	:= Nil
Local nReg		:= 0

Default nAcao   := 0
Default nTabela := 0
Default cQuery  := ""
Default cAlias  := ""
Default cCodFon := ""
Default cCodReg := ""

If nAcao > 0 .And. nTabela > 0 .And. !Empty(cQuery)
	DbSelectArea("DNS")
	//DbSelectArea("DNS")
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	While (cAliasQry)->(!Eof())
		
		If nReg <> (cAliasQry)->SC5REG
			nReg := (cAliasQry)->SC5REG
			SC5->( DbGoTo( (cAliasQry)->REGISTRO ) )
			SC9->( DbGoTo( (cAliasQry)->REGISTRO ) )
			
			oAgend  := TMSBCACOLENT():New("DNT")
			
			If oAgend:DbGetToken() .And. !Empty(oAgend:filext)
				TMSF98Gdd( "DNT", oAgend, cAlias, cCodReg, cSubProc )
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())

	EndDo

	(cAliasQry)->(DbCloseArea())	
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return
*/
/*
{Protheus.doc} TMSF98Gdd()
Grava histórico das integrações
@type  Function
@author Rodrigo.Pirolo
@since 11/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Static Function TMSF98Gdd( cAliasObj, oObj, cAlias, cCodReg, cSubProc )

Local aAreaTab  := {}
Local aLayout	:= {}
Local aStruct   := {}
Local aIndice   := {}
Local aAlias	:= {}
Local aProcs	:= {}
Local cProcesso := ""
Local cCndDep   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0

Default cAliasObj	:= ""
Default oObj		:= Nil
Default cAlias		:= ""
Default cCodReg		:= ""
Default cSubProc	:= ""

If !Empty(cAliasObj)
	cReg := cValtoChar(oObj:config_recno)
	&( cAliasObj +"->( DbGoTo( " + cReg + " ) ) " )
	//-- Define Viagens
	aAreaTab := &(cAlias + "->(GetArea())")
	
	//-- Inicializa a estrutura
	aStruct  := TMSMntStru( oObj:CodFon, .T., cSubProc )
	TMSSetVar( "aStruct", aStruct )

	For nCntFor1 := 1 To Len(aStruct)
		//-- Ainda não foi processado
		//-- Não depende de outro registro
		//-- Não é adicional de nenhum outro registro
		//-- Condição do Registro do Layout atendida ou não informada
		If cAlias == aStruct[nCntFor1,3]
			//-- Define o processo
			aIndice := BscChave(cAlias,aStruct[1,4])
			
			cProcesso := ""
			For nCntFor2 := 1 To Len(aIndice)
				cProcesso += &(cAlias + "->" + aIndice[nCntFor2])
			Next nCntFor2

			TMSSetVar("cProcesso", oObj:Alias_Config + oObj:CodFon + cProcesso )

			//-- Inicializa o localizador
			TMSSetVar("aLocaliza",{})

			If Empty(aStruct[nCntFor1,9])
				cCndDep := ".T."
			Else
				cCndDep := AllTrim(aStruct[nCntFor1,9])
			EndIf

			If aStruct[nCntFor1,10] == "2" .And. Empty(aStruct[nCntFor1,6]) .And.;
				(Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor1,1] +  aStruct[nCntFor1,2]}) == 0) .And. &(cCndDep)

				aLayout := BscLayout(aStruct[nCntFor1,1],aStruct[nCntFor1,2])
				
				If !Empty(aLayout)
					If Empty(aStruct[nCntFor1,6])
						//-- Inicia a gravação dos registros
						MontaReg( Aclone(aLayout), nCntFor1, .T., "", .T. )
						TMSCtrLoop( Aclone(aLayout), nCntFor1 )
						
						/*nPos := Ascan( aProcs, { |x| x[1] == oObj:Alias_Config + oObj:CodFon + cProcesso } )
						If oObj:Alias_Config == "DNT" .AND. cAlias $ 'SA1/SB1' .AND. nPos == 0
							AAdd( aAlias, oObj:Alias_Config )
							AAdd( aProcs, { oObj:Alias_Config + oObj:CodFon + cProcesso } )
							TMSAI86AUX( oObj:Alias_Config + oObj:CodFon + cProcesso, , aAlias )
						EndIf*/
					EndIf
				EndIf
			EndIf

			aStruct := TMSGetVar("aStruct")
		EndIf

	Next nCntFor1

	RestArea(aAreaTab)
	FwFreeArray(aAreaTab)
EndIf

Return 

/*
{Protheus.doc} TMSF98Dt()
Grava histórico das integrações
@type  Function
@author Rodrigo.Pirolo
@since 11/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TMSF98Dt( dData )

	Local cRet		:= ""
	Default dData	:= ""

	If ValType(dData) == "D"
		cRet := SubStr(DToS(DA4->DA4_DTVCNH),1,4)+"-"+SubStr(DToS(DA4->DA4_DTVCNH),5,2)+"-"+SubStr(DToS(DA4->DA4_DTVCNH),7,2)
	EndIf

Return cRet

/*
{Protheus.doc} TMSF98PsVl()
Grava histórico das integrações
@type  Function
@author Rodrigo.Pirolo
@since 11/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
/*Function TMSF98PV( nTipoRet, nQtdLib, cProd, cNumPed )

	Local aAreaSB1	:= { SB1->(GetArea()), SB5->(GetArea()), GetArea() }
	Local nValor	:= 0
	Local nRet		:= 0

	Default nTipoRet:= 0
	Default nQtdLib	:= 0
	Default cProd	:= ""
	Default lCabec	:= .F.

	If nTipoRet == 1
		nValor := Posicione( "SB1", 1, xFilial("SB1") + cProd, "B1_PESO" )
		nRet := nValor * nQtdLib
	ElseIf nTipoRet == 2
		DbSelectArea("SB5")
		SB5->( DbSetOrder(1) )
		nValor := 1
		If SB5->( DbSeek( xFilial("SB5") + cProd ) )
			nValor := SB5->B5_ESPESS * SB5->B5_COMPR * SB5->B5_LARG
		EndIf
		nRet := nValor * nQtdLib
	EndIf

	AEval( aAreaSB1, { |x,y| RestArea(x), FwFreeArray(x) } )

Return cValToChar(nRet)
*/
/*
{Protheus.doc} TMSF98PsVl()
Grava histórico das integrações
@type  Function
@author Rodrigo.Pirolo
@since 11/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
/*
Function TMSF98Co( cArea, nIndice, cChave, cCampo, lData )

Local aAreaTab	:= {}
Local xRet		:= Nil

Default cArea	:= ""
Default nIndice	:= 0
Default cChave	:= ""
Default cCampo	:= ""
Default lData	:= .F.

	aAreaTab := &( cArea + "->(GetArea())" )

	xRet := Posicione( cArea, nIndice, cChave, cCampo )
	
	If lData
		xRet := ConvDat( xRet, "0900" )
	EndIf

	RestArea(aAreaTab)
	FwFreeArray(aAreaTab)

Return xRet

Static Function ConvDat(dData,cHora)
Local cRet      := ""

Default dData  := CToD("")
Default cHora  := ""

If !Empty(dData) .And. !Empty(cHora)
	cRet := SubStr(DToS(dData),1,4) + "-" + SubStr(DToS(dData),5,2) + "-" + SubStr(DToS(dData),7,2) + "T" + SubStr(cHora,1,2) + ":" + ;
			SubStr(cHora,3,2) + ":00.000Z"
EndIf

Return cRet
*/
/*
{Protheus.doc} TMSF98PsVl()
Grava histórico das integrações
@type  Function
@author Rodrigo.Pirolo
@since 11/04/2024
@version 1
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/

Function TMF98TpVei( cTipVei, nTipo )

	Local aAreas	:= { DA3->(GetArea()), DUT->(GetArea()), GetArea() }
	Local cRet		:= ""
	Local cCatVei	:= ""
	Local cTipCar	:= ""
	Local nPos		:= 0
	Local aTipoVei	:= {	{ "1",	"AUTOMOVEL"		},;
							{ "6",	"BITREM"		},;
							{ "3",	"CARRETA"		},;
							{ "2",	"CAVALO_MECANICO"},;
							{ "5",	"UTILITARIO"	} }
							/* No app existem estas outras opções
								Bitruck
								Carreta_31T
								Carreta_35T
								Motocicleta 15
								Nenhum
								Outros
								Rodotrem
								Toco
								Tracado
								Truck
								Van
								VUC
							*/
	Local aTipoCar	:= {	{ "00",	"NENHUM"			},;//00 NAO APLICAVEL
							{ "01",	"GRADE_BAIXA"		},;//01 ABERTA
							{ "02",	"BAU"				},;//02 FECHADA/BAU
							{ "03",	"GRANELEIRO"		},;//03 GRANELERA
							{ "04",	"PORTA_CONTAINER"	},;//04 PORTA CONTAINER
							{ "05",	"SIDER"				},;//05 SIDER
							{ "06",	"BAU_FRIGORIFICO"	} }//06 BAÚ FRIGORÍFICO 15
							/* No app existem estas outras opções
								Canavieira
								Florestal
								Boiadeira
								Silo
								Tanque
								Cegonha
								Botijoes Gas
								Munck
								Poliguindaste
							*/
	
	If nTipo == 1
		
		cCatVei := Posicione( "DUT", 1, FwxFilial("DUT") + cTipVei, "DUT_CATVEI" )

		nPos := Ascan( aTipoVei, { |x| x[1] == cCatVei } )

		If nPos > 0
			cRet := aTipoVei[nPos,2]
		EndIf

	ElseIf nTipo == 2
		
		cTipCar := Posicione( "DUT", 1, FwxFilial("DUT") + cTipVei, "DUT_TIPCAR" )

		nPos := Ascan( aTipoCar, { |x| x[1] == cTipCar } )

		If nPos > 0
			cRet := aTipoCar[nPos,2]
		EndIf

	EndIf

	AEval( aAreas, { |x,y| RestArea(x), FwFreeArray(x) } )
Return cRet

/*{Protheus.doc} BscIDMot
Busca ID Externo do Motorista
@type Function
@author Valdemar Roberto Mognon
@since 09/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
/*
Function BscIDExt( cChave, cCodFon, cCodReg )

Local cRet   := ""
Local aAreas := { DA4->(GetArea()), GetArea() }

Default cCodMot := ""
Default cCodFon := ""
Default lChkLst := .F.
cRet   := cChave
If AliasInDic("DN4")
	DN4->(DbSetOrder(1)) // DN4_FILIAL, DN4_CODFON, DN4_CODREG, DN4_CHAVE
	If DN4->( DbSeek( xFilial("DN4") + cCodFon + cCodReg + cChave ) ) .AND. DN4->DN4_STATUS == "1"
		cRet := DN4->DN4_IDEXT
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cRet
*/
/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()

Local aParam := { "P",;			// Tipo R para relatorio P para processo
                  "TMSAF98",;	// Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;		// Alias
                  ,;			// Array de ordens
                  "Filtragem de dados para integração com YMS SAAS ou Agendamento SAAS." }		// Descrição do Schedule

Return aParam
