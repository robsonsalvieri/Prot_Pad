#Include 'Protheus.ch'

Function TAFGIRMOVT(aWizard, nValor, nCont, nOP)
	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )

	Local cMesRefer  	:= Substr(aWizard[1][4],1,2) //Mes Referencia
	Local cAnoRefer	    := Substr(aWizard[1][4],4,4) //Ano Referencia
	Local cStrTxt		:= ""
	Local cStrTxtAux	:= ""

	If nOP == 1
		cStrTxtAux := ""
		cStrTxtAux := fnRegMovto("0120", @nValor, cAnoRefer + cMesRefer, 0, 4, @nCont) //Registro 0120

		If(cStrTxtAux != "")
			cStrTxt += cStrTxtAux
		EndIf

		cStrTxtAux := ""
		cStrTxtAux := fnRegMovto("0130", @nValor, cAnoRefer + cMesRefer, 4, 8, @nCont) //Registro 0130

		If(cStrTxtAux != "")
			cStrTxt += cStrTxtAux
		EndIf

		Begin Sequence
			WrtStrTxt( nHandle, cStrTxt )

			GerTxtGIRJ( nHandle, cTxtSys, "MOVTO1" )

			Recover
			lFound := .F.
		End Sequence
	ElseIf nOP == 2
		cStrTxtAux := ""
		cStrTxtAux := fnRegMvtEn(@nValor, cAnoRefer + cMesRefer, "0", "2", @nCont)

		If(cStrTxtAux != "")
			cStrTxt += cStrTxtAux
		EndIf

		cStrTxtAux := ""
		cStrTxtAux := fnRegMvtEn(@nValor, cAnoRefer + cMesRefer, "1", "6", @nCont)

		If(cStrTxtAux != "")
			cStrTxt += cStrTxtAux
		EndIf

		Begin Sequence
			WrtStrTxt( nHandle, cStrTxt )

			GerTxtGIRJ( nHandle, cTxtSys, "MOVTO2" )

			Recover
			lFound := .F.
		End Sequence
	ElseIf nOP == 3
		cStrTxtAux := ""
		cStrTxtAux := fnRegMvtZF(@nValor, cAnoRefer + cMesRefer, @nCont)

		If(cStrTxtAux != "")
			cStrTxt += cStrTxtAux
		EndIf

		Begin Sequence
			WrtStrTxt( nHandle, cStrTxt )

			GerTxtGIRJ( nHandle, cTxtSys, "MOVTO3" )

			Recover
			lFound := .F.
		End Sequence
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SldCredAnt

Rotina retorna o Saldo Saldo Credor do Período Anterior.

@Param cAnoMesRef -> Ano/Mês de referencia

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function fnRegMovto(cRegistro, nValor, cPeriodo, cCFOPIni, cCFOPFin, nCont)

Local cStrTxt := ""

Local nValRet  := 0
Local nValBase := 0

Local cStrQuery1        := ""
Local cAlias1			:= GetNextAlias()

Local cStrQuery2        := ""
Local cAlias2			:= GetNextAlias()

Local cCodCfop := ""
Local cCFOP    := ""
Local nValBaseST := 0
Local nValImpCrd := 0

	cStrQuery1 := " SELECT SUM(C6Z_BASE) BASE, SUM(C6Z_IMPCRD) IMPCRD, SUM(C6Z_VLCONT) VLCONT, SUM(C6Z_ISENNT) ISENNT, SUM(C6Z_OUTROS) OUTROS, C6Z_CFOP CFOP "
	cStrQuery1 +=	"   FROM " +  RetSqlName('C6Z') + ' C6Z ' + ',' 
	cStrQuery1 +=					RetSqlName('C2S') + ' C2S '
	cStrQuery1 += "  WHERE C6Z.C6Z_FILIAL             = '" + xFilial("C6Z") + "' "
	cStrQuery1 += "    AND C2S.C2S_FILIAL             = C6Z.C6Z_FILIAL "
	cStrQuery1 +=	"    AND C2S_ID         				 = C6Z_ID "
	cStrQuery1 +=	"    AND C6Z.D_E_L_E_T_ 				!= '*' "
	cStrQuery1 +=	"    AND C2S.D_E_L_E_T_ 				!= '*' "
	
	if "ORACLE" $ Upper(TcGetDB())
		cStrQuery1 +=	"    AND SUBSTR(C2S_DTINI,1,6)  = '" + cPeriodo + "' "
	   	cStrQuery1 +=	"    AND SUBSTR(C2S_DTFIN,1,6)  = '" + cPeriodo + "' "
	Else
	   	cStrQuery1 +=	"    AND SUBSTRING(C2S_DTINI,1,6)  = '" + cPeriodo + "' "
	   	cStrQuery1 +=	"    AND SUBSTRING(C2S_DTFIN,1,6)  = '" + cPeriodo + "' "
	EndIf
	
	cStrQuery1 +=	" GROUP BY C6Z_CFOP "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery1),cAlias1,.T.,.T.)
	DbSelectArea(cAlias1)

	While (cAlias1)->(!Eof())

	   	cCodCfop := Substr(POSICIONE("C0Y",3,xFilial("C0Y")+ (cAlias1)->CFOP ,"C0Y_CODIGO"),1,1)
       cCFOP    := POSICIONE("C0Y",3,xFilial("C0Y")+(cAlias1)->CFOP,"C0Y_CODIGO")

		cStrQuery2 := " SELECT SUM(C7A_IMPCRD) IMPCRD, SUM(C7A_BASE) VLRBASE"
		cStrQuery2 +=	"   FROM " +  RetSqlName('C7A') + ' C7A ' + ','
		cStrQuery2 +=					RetSqlName('C3J') + ' C3J ' + ',' 
		cStrQuery2 +=					RetSqlName('C0Y') + ' C0Y '
		cStrQuery2 += "  WHERE C7A.C7A_FILIAL             = '" + xFilial("C7A") + "' "
		cStrQuery2 += "    AND C3J.C3J_FILIAL             =  C7A.C7A_FILIAL "
		cStrQuery2 += "    AND C7A.C7A_ID 					 =  C3J.C3J_ID
		cStrQuery2 += "    AND C7A.C7A_CFOP 				 =  C0Y.C0Y_ID
		cStrQuery2 +=	"    AND C0Y.C0Y_CODIGO 				 = '" + cCFOP + "' "
		
		if "ORACLE" $ Upper(TcGetDB())
			cStrQuery2 +=	" AND SUBSTR(C3J_DTINI,1,6)   = '" + cPeriodo + "' "
			cStrQuery2 +=	" AND SUBSTR(C3J_DTFIN,1,6)   = '" + cPeriodo + "' "
		Else
			cStrQuery2 +=	" AND SUBSTRING(C3J_DTINI,1,6)   = '" + cPeriodo + "' "
			cStrQuery2 +=	" AND SUBSTRING(C3J_DTFIN,1,6)   = '" + cPeriodo + "' "
		EndIf
		
		cStrQuery2 +=	"    AND C7A.D_E_L_E_T_ 				!= '*' "
		cStrQuery2 +=	"    AND C3J.D_E_L_E_T_ 				!= '*' "
		cStrQuery2 +=	"    AND C0Y.D_E_L_E_T_ 				!= '*' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery2),cAlias2,.T.,.T.)
       DbSelectArea(cAlias2)

		If (VAL(cCodCfop) > cCFOPIni .AND. VAL(cCodCfop) < cCFOPFin)
			cStrTxt += cRegistro
			cStrTxt += StrZero(1,15) 			    	 		  //Identificador da Declaração
		 	cStrTxt += cCFOP                      	 	 		  //Código fiscal de Operação
		 	cStrTxt += StrZero((cAlias1)->VLCONT  * 100	,15) //Valor Contábil
		 	cStrTxt += StrZero((cAlias1)->BASE    * 100	,15) //Valor da Base de Cálculo
		 	cStrTxt += StrZero((cAlias1)->IMPCRD  * 100	,15) //Valor do Imposto
		 	cStrTxt += StrZero((cAlias1)->ISENNT  * 100	,15) //Valor de Operações Isentas
		 	cStrTxt += StrZero((cAlias1)->OUTROS  * 100	,15) //Valor de Outras Operações

		 	nValor += 	(cAlias1)->VLCONT + (cAlias1)->BASE + (cAlias1)->IMPCRD + (cAlias1)->ISENNT + (cAlias1)->OUTROS

		 	nValBaseST := 0
		 	nValImpCrd := 0		 
		 	
			nValBaseST := (cAlias2)->VLRBASE
			nValImpCrd := (cAlias2)->IMPCRD

			nValor += 	nValBaseST + nValImpCrd

			cStrTxt += StrZero(nValBaseST  * 100 	,15) //Valor da Base de Cálculo ST
			cStrTxt += StrZero(nValImpCrd  * 100  	,15) //Valor do Imposto Retido ST

			cStrTxt += space(717)       				 //Filler
			cStrTxt += StrZero(nCont,5) 				 //Contador de linha
			cStrTxt += CRLF
			nCont++

		EndIf
		(cAlias2)->(DbCloseArea())
		(cAlias1)->(DbSkip())
	EndDo
	(cAlias1)->(DbCloseArea())

Return cStrTxt

Static Function fnRegMvtEn(nValor, cPeriodo, cIndOper, sNatur, nCont)

	Local cRegistro 	:= IF ((cIndOper == "0"), "0210", "0220")
	Local cCDGIRJ 	:= ""
	Local cDataIni 	:= ""
	Local cDataFin 	:= ""

	Local cStrQuery	:= ""
	Local cNovoAlias  := GetNextAlias()

	Local cCodCfop := ""

	Local cStrTxt := ""
	Local nPos 	:= 0
	Local aArray 	:= {}
	Local lAchou 	:= .F.

	Local nValOutOpe 	:= 0
	Local nValMerc  	:= 0
	Local nValNC 		:= 0
	Local nValCont 	:= 0
	Local nValBasNC	:= 0
	Local nValBaseC	:= 0
	Local nValBase0 	:= 0 //Entrada
	Local nValBase1 	:= 0 //Saída
	Local nValICMSST	:= 0

	cStrQuery := " SELECT C1H_UF UF, C2F_CODTRI CODTRI, C20_CHVNF CHVNF, SUM(C2F_VLOPE) VLOPE, SUM(C2F_BASE) BASE, SUM(C2F_VLISEN) VLISEN, SUM(C2F_VLOUTR) VLOUTR  "
	cStrQuery += "   FROM " + 	RetSqlName('C20') + ' C20 ' + ',' 
	cStrQuery += 				  	RetSqlName('C1H') + ' C1H ' + ','
	cStrQuery += 					RetSqlName('C2F') + ' C2F ' + ','
	cStrQuery += 					RetSqlName('C02') + ' C02 ' + ','
	cStrQuery += 					RetSqlName('C0Y') + ' C0Y '
	cStrQuery += "  WHERE C20.C20_FILIAL                = '" + xFilial("C20") + "' "
	cStrQuery += "    AND C1H.C1H_FILIAL                = C20.C20_FILIAL "
	cStrQuery += "    AND C2F.C2F_FILIAL                = C20.C20_FILIAL "
	cStrQuery += "    AND C20.C20_CODPAR                = C1H.C1H_ID "
	cStrQuery += "    AND C20.C20_INDOPE    			   = '" + cIndOper + "' "
	cStrQuery += "    AND C2F.C2F_CHVNF                 = C20.C20_CHVNF "
	
	cStrQuery += "    AND C02.C02_CODIGO NOT IN ( '02','03','04','05') "
	//cStrQuery += "    AND C02.C02_FILIAL        = C20.C20_FILIAL "
	cStrQuery += "    AND C20.C20_CODSIT = C02.C02_ID " 
	
	If "ORACLE" $ Upper(TcGetDB())
		cStrQuery += " AND SUBSTR(C20.C20_DTDOC,1,6)  = '" + cPeriodo + "' "
		cStrQuery += " AND SUBSTR(C0Y.C0Y_CODIGO,1,1) = '" + sNatur + "' "
	Else
		cStrQuery += " AND SUBSTRING(C20.C20_DTDOC,1,6)  = '" + cPeriodo + "' "
		cStrQuery += " AND SUBSTRING(C0Y.C0Y_CODIGO,1,1) = '" + sNatur + "' "
	EndIf
	cStrQuery += "    AND C0Y.C0Y_ID                    = C2F.C2F_CFOP"
	cStrQuery += "    AND C2F.C2F_CODTRI                = '000002' "

	If (sNatur == "6")
		cStrQuery += " AND C1H.C1H_SUFRAM = ' ' "
	EndIf

	cStrQuery += "    AND C20.D_E_L_E_T_ 				  != '*' "
	cStrQuery += "    AND C1H.D_E_L_E_T_ 				  != '*' "
	cStrQuery += "    AND C2F.D_E_L_E_T_ 				  != '*' "
	cStrQuery += "    AND C0Y.D_E_L_E_T_ 				  != '*' "
	cStrQuery += " GROUP BY C1H.C1H_UF, C2F.C2F_CODTRI, C20.C20_CHVNF "
	cStrQuery += " ORDER BY C1H.C1H_UF"

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)

	While (cNovoAlias)->(!Eof())

		If(len(aArray) = 0)
			AADD(aArray, {cRegistro, (cNovoAlias)->UF, (cNovoAlias)->CODTRI, (cNovoAlias)->VLOPE, (cNovoAlias)->BASE, (cNovoAlias)->VLISEN, (cNovoAlias)->VLOUTR})
			(cNovoAlias)->(DbSkip())
			Loop
		Endif

		For nPos := 1 To len(aArray)
			lAchou := .F.
			If(aArray[nPos,2] == (cNovoAlias)->UF .AND. aArray[nPos,3] == (cNovoAlias)->CODTRI)
				lAchou := .T.
			   	aArray[nPos,4] += (cNovoAlias)->VLOPE
			   	aArray[nPos,5] += (cNovoAlias)->BASE
				aArray[nPos,6] += (cNovoAlias)->VLISEN
				aArray[nPos,7] += (cNovoAlias)->VLOUTR
			EndIf
		Next nPos

		If(!lAchou)
			AADD(aArray, {cRegistro, (cNovoAlias)->UF, (cNovoAlias)->CODTRI, (cNovoAlias)->VLOPE, (cNovoAlias)->BASE, (cNovoAlias)->VLISEN, (cNovoAlias)->VLOUTR})
		EndIf

		(cNovoAlias)->(DbSkip())
	EndDo

	For nPos := 1 To len(aArray)
		If TAFColumnPos( "C09_CDGIRJ" )
			cCDGIRJ := POSICIONE("C09",3,xFilial("C09") + aArray[nPos,2], "C09_CDGIRJ")
		EndIf
		
		nValOutOpe	:= aArray[nPos,6] + aArray[nPos,7]
		nValBase    := 0			
		nValMerc  	:= 0
		nValNC 		:= 0
		nValCont 	:= 0
		nValBasNC	:= 0
		nValBaseC 	:= 0
		nValICMSST	:= 0

		If (cIndOper == "0")

			nValBase 	:= aArray[nPos,5]
			nValICMSST	:= BuscaValorCont('5',.T., cIndOper, cPeriodo, sNatur, aArray[nPos,2], "000004")	//Valor de Outros Produtos
			nValMerc	:= aArray[nPos,4]

			cStrTxt += cRegistro
			cStrTxt += StrZero(1,15) 			    	 	//Identificador da Declaração
		 	cStrTxt += StrZero(VAL(cCDGIRJ), 3)          	//Código de UF
		 	cStrTxt += StrZero(nValMerc 	* 100	,15) 	//Valor Contábil
		 	cStrTxt += StrZero(nValBase   	* 100	,15)	//Valor da Base de Cálculo
	 		cStrTxt += StrZero(nValOutOpe 	* 100	,15) 	//Valor de Outras Operações
		 	cStrTxt += StrZero(0	,15) 						//Valor de Petróleo e Energia
		 	cStrTxt += StrZero(nValICMSST 	* 100	,15)   //Valor de Outros Produtos
			cStrTxt += space(748)       		 			//Filler
		Else
			nValNC 	:= BuscaValorCont('1', .F., cIndOper, cPeriodo, sNatur, aArray[nPos,2], aArray[nPos,3]) 	//Valor Contábil Não Contribuinte
		 	nValCont 	:= BuscaValorCont('2', .T., cIndOper, cPeriodo, sNatur, aArray[nPos,2], aArray[nPos,3]) 	//Valor Contábil Contribuinte
		 	nValBasNC	:= BuscaValorCont('3', .F., cIndOper, cPeriodo, sNatur, aArray[nPos,2], aArray[nPos,3]) 	//Valor da Base de Cálculo Não Contribuinte
		 	nValBaseC	:= BuscaValorCont('4', .T., cIndOper, cPeriodo, sNatur, aArray[nPos,2], aArray[nPos,3]) 	//Valor da Base de Cálculo Contribuinte
		 	nValICMSST	:= BuscaValorCont('5', .T., cIndOper, cPeriodo, sNatur, aArray[nPos,2], "000004")  			//Valor de Outros Produtos

			cStrTxt += cRegistro
			cStrTxt += StrZero(1,15) 			    	 	//Identificador da Declaração
		 	cStrTxt += StrZero(VAL(cCDGIRJ), 3)          	//Código de UF
		 	cStrTxt += StrZero(nValNC     * 100 ,15)		//Valor Contábil Não Contribuinte
		 	cStrTxt += StrZero(nValCont   * 100 ,15) 		//Valor Contábil Contribuinte
		 	cStrTxt += StrZero(nValBasNC  * 100 ,15) 		//Valor da Base de Cálculo Não Contribuinte
		 	cStrTxt += StrZero(nValBaseC  * 100 ,15)		//Valor da Base de Cálculo
	 		cStrTxt += StrZero(nValOutOpe * 100 ,15) 		//Valor de Outras Operações
		 	cStrTxt += StrZero(nValICMSST * 100 ,15) 		//Valor de Outros Produtos
			cStrTxt += space(733)       				 	//Filler
		EndIf

		cStrTxt += StrZero(nCont,5) 				 		//Contador de linha
		cStrTxt += CRLF
		nCont++

		nValor +=	nValBase + nValOutOpe + nValMerc + nValNC + nValCont + nValBasNC + nValBaseC + nValICMSST
	Next nPos

Return cStrTxt

Static Function fnRegMvtZF(nValor, cPeriodo, nCont)

	Local cRegistro 	:= "0230"
	Local cCodMun 	:= ""

	Local cStrQuery	:= ""
	Local cNovoAlias  := GetNextAlias()

	Local cStrTxt := ""
	Local cHora 	:= ""

	Local nValBase  	:= 0
	Local nValOutOpe	:= 0
	Local nValICMSST	:= 0

	Local cNumDocto := ""

	cStrQuery := " SELECT C20_CHVNF CHVNF, C1H_CODMUN CODMUN, C20_SERIE SERIE, C20_SUBSER SUBSER, C20_VLDOC VLDOC, C20_NUMDOC NUMDOC, "
	cStrQuery += "        C20_DTDOC DTDOC, SUM(C2F_VLISEN) VLISEN, C1H_CNPJ CNPJ, C1H_SUFRAM SUFRAM "
	cStrQuery += "   FROM " +   RetSqlName('C20') + ' C20' + ', '
	cStrQuery += 					RetSqlName('C2F') + ' C2F' + ', ' 
	cStrQuery += 					RetSqlName('C1H') + ' C1H' + ', '
	cStrQuery += 					RetSqlName('C02') + ' C02' + ', '
	cStrQuery += 					RetSqlName('C0Y') + ' C0Y'
	cStrQuery += "  WHERE C20.C20_FILIAL               = '" + xFilial("C20") + "' " //FILIAL
	cStrQuery += "    AND C1H.C1H_FILIAL               = C20.C20_FILIAL " 			//PARTICIPANTE
	cStrQuery += "    AND C2F.C2F_FILIAL               = C20.C20_FILIAL " 			//IMPOSTO
	cStrQuery += "    AND C20.C20_CODPAR               = C1H.C1H_ID "
	If "ORACLE" $ Upper(TcGetDB())
	        cStrQuery += "    AND SUBSTR(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
	        cStrQuery += "    AND SUBSTR(C0Y.C0Y_CODIGO,1,1)= '6'"
	Else
	        cStrQuery += "    AND SUBSTRING(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
	        cStrQuery += "    AND SUBSTRING(C0Y.C0Y_CODIGO,1,1)= '6'"
	EndIf
	cStrQuery += "    AND C02.C02_CODIGO NOT IN ( '02','03','04','05') "
	//cStrQuery += "    AND C02.C02_FILIAL        = C20.C20_FILIAL "
	cStrQuery += "    AND C20.C20_CODSIT = C02.C02_ID " 
	cStrQuery += "    AND C2F.C2F_CHVNF                = C20.C20_CHVNF"
	cStrQuery += "    AND C0Y.C0Y_ID                   = C2F.C2F_CFOP"
	cStrQuery += "    AND C2F.C2F_CODTRI               = '000002'"
	cStrQuery += "    AND C1H.C1H_SUFRAM IS NOT NULL AND C1H.C1H_SUFRAM != ' ' "
	cStrQuery += "    AND C20.D_E_L_E_T_ 				 != '*' "
	cStrQuery += "    AND C1H.D_E_L_E_T_ 				 != '*' "
	cStrQuery += "    AND C2F.D_E_L_E_T_ 				 != '*' "
	cStrQuery += "    AND C0Y.D_E_L_E_T_ 				 != '*' "
	cStrQuery += " GROUP BY C20_CHVNF, C1H_CODMUN, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_VLDOC, C1H_CNPJ, C1H_SUFRAM "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)

	While (cNovoAlias)->(!Eof())

		cCodMun := POSICIONE("T2D",2,xFilial("T2D") + (cNovoAlias)->CODMUN + "MUNZFRJ", "T2D_CODMUN")
		cHora	 := POSICIONE("C20",4,xFilial("C20") + (cNovoAlias)->CHVNF, "C20_HSAIEN")

		cNumDocto = trim((cNovoAlias)->NUMDOC)

		If (len(cNumDocto) > 6 )
			cNumDocto := Substr(cNumDocto,len(cNumDocto) - 5, 6)
		EndIf

		cStrTxt += cRegistro
		cStrTxt += StrZero(1,15) 			    	 		//Identificador da Declaração
	 	cStrTxt += StrZero(VAL(cCodMun), 8)          	 	//Código de UF
	 	cStrTxt += Substr((cNovoAlias)->SERIE,1,3)    	//Numero de Série da Nota Fiscal
 		cStrTxt += Substr((cNovoAlias)->SUBSER,1,2)		//Numero de Subsérie da Nota Fiscal
	 	cStrTxt += StrZero(VAL(cNumDocto),6)	//Numero da Nota Fiscal

	 	cStrTxt += (cNovoAlias)->DTDOC + StrZero(VAL(Substr(StrTran(cHora,":",""),1,6)),6)					//Data de Emissão
	 	cStrTxt += StrZero((cNovoAlias)->VLDOC  * 100 ,15) 	//Valor da Nota Fiscal
	 	cStrTxt += StrZero((cNovoAlias)->VLISEN * 100 ,15) 	//Valor de Isentas
	 	cStrTxt += (cNovoAlias)->CNPJ 						//Número do CNPJ
	 	cStrTxt += StrZero(VAL((cNovoAlias)->SUFRAM),9)	//Número de Inscrição SUFRAMA
		cStrTxt += space(740)       				 		//Filler

		cStrTxt += StrZero(nCont,5) 				 		//Contador de linha
		cStrTxt += CRLF
		nCont++

		nValor +=	(cNovoAlias)->VLDOC + (cNovoAlias)->VLISEN

		(cNovoAlias)->(DbSkip())
	EndDo

Return cStrTxt

Function BuscaValorCont(cTipo, lContrib, cIndOper, cPeriodo, sNatur, cUF, cCODTRI)

	Local nValor 		:= 0
	Local cStrQuery 	:= ''
	Local cNovoAlias2	:= GetNextAlias()

	// cTipo
	// 1 - //Valor Contábil Não Contribuinte
	// 2 - //Valor Contábil Contribuinte
	// 3 - //Valor da Base de Cálculo Não Contribuinte
	// 4 - //Valor da Base de Cálculo
	// 5 - //Valor de Outros Produtos ( ICMS ST)

	//cStrQuery := " SELECT C20_CHVNF CHVNF, SUM(C20_VLMERC) VLMERC, SUM(C2F_BASE) BASE, SUM(C2F_VALOR) VALOR"
	cStrQuery := " SELECT SUM(C2F_VLOPE) VLOPE, SUM(C2F_BASE) BASE, SUM(C2F_VALOR) VALOR "	
	cStrQuery += "   FROM " + 	RetSqlName('C20') + ' C20 ' + ','
	cStrQuery += 				RetSqlName('C1H') + ' C1H ' + ','
	cStrQuery += 				RetSqlName('C02') + ' C02 ' + ','
	cStrQuery += 				RetSqlName('C2F') + ' C2F ' + ','	
	cStrQuery += 				RetSqlName('C0Y') + ' C0Y '
	cStrQuery += "  WHERE C20.C20_FILIAL               = '" + xFilial("C20") + "' "
	cStrQuery += "    AND C1H.C1H_FILIAL               = C20.C20_FILIAL "
	cStrQuery += "    AND C2F.C2F_FILIAL               = C20.C20_FILIAL "	
	cStrQuery += "    AND C20.C20_CODPAR               = C1H.C1H_ID "
	cStrQuery += "    AND C20.C20_INDOPE    		      = '" + cIndOper + "' "
        
	If "ORACLE" $ Upper(TcGetDB())
		cStrQuery += "    AND SUBSTR(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
		cStrQuery += "    AND SUBSTR(C0Y.C0Y_CODIGO,1,1)= '" + sNatur   + "' "
	Else
		cStrQuery += "    AND SUBSTRING(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
		cStrQuery += "    AND SUBSTRING(C0Y.C0Y_CODIGO,1,1)= '" + sNatur   + "' "
	EndIf
	
	cStrQuery += "    AND C0Y.C0Y_ID                   = C2F.C2F_CFOP"
	cStrQuery += "    AND C2F.C2F_CHVNF                = C20.C20_CHVNF "
	cStrQuery += "    AND C2F.C2F_CODTRI 		 		  = '" + cCODTRI + "' "
	cStrQuery += "    AND C1H_UF 			 			  = '" + cUF     + "' "

	cStrQuery += "    AND C02.C02_CODIGO NOT IN ( '02','03','04','05') "
	//cStrQuery += "    AND C02.C02_FILIAL        = C20.C20_FILIAL "
	cStrQuery += "    AND C20.C20_CODSIT = C02.C02_ID " 
	If (lContrib)
		cStrQuery += "    AND C1H.C1H_IE != ' ' AND C1H.C1H_IE != 'ISENTO' AND C1H.C1H_IE IS NOT NULL "
	Else //Não Contribuinte
		cStrQuery += "    AND (C1H.C1H_IE = ' ' OR C1H.C1H_IE = 'ISENTO' OR C1H.C1H_IE IS NULL) "
	EndIf

	cStrQuery += "    AND C20.D_E_L_E_T_ 	!= '*' "
	cStrQuery += "    AND C1H.D_E_L_E_T_ 	!= '*' "
	cStrQuery += "    AND C2F.D_E_L_E_T_ 	!= '*' "
	cStrQuery += "    AND C0Y.D_E_L_E_T_ 	!= '*' "

	If (sNatur == "6")
		cStrQuery += "    AND C1H.C1H_SUFRAM = ' ' AND C1H.C1H_SUFRAM IS NOT NULL "
	EndIf

	//cStrQuery += "    GROUP BY C20_CHVNF "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias2,.T.,.T.)
	DbSelectArea(cNovoAlias2)

	nValor := 0
	While (cNovoAlias2)->(!Eof())

		If  cTipo == '1' .OR. cTipo == '2'
			nValor += (cNovoAlias2)->VLOPE
		ElseIf cTipo == '5'
			nValor += (cNovoAlias2)->VALOR
		Else
			nValor += (cNovoAlias2)->BASE
		EndIf
		(cNovoAlias2)->(DbSkip())
	EndDo

Return nValor
