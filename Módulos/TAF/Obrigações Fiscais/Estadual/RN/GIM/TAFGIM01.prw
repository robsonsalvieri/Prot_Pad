#Include 'Protheus.ch'

Function TAFGIM01(aWizard, cJobAux)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		as char
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Local nX     	  as numeric
	Local nValCt 	  as numeric
	Local nValBs 	  as numeric
	Local nValIc 	  as numeric
	Local nValSt 	  as numeric
	Local nTotValCt as numeric
	Local nTotValBs as numeric
	Local nTotValIc as numeric
	Local nTotValSt as numeric

	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local aArray as array

	Begin Sequence

		aArray := {}

		// Registro 01 - Cabeçalho
		cStrTxt := AllTrim(StrTran(aWizard[1][2], "/",""))
		cStrTxt += Substr(SM0->M0_INSC,1,9)
		cStrTxt += "N"
		cStrTxt += CRLF

		//Entradas CFOP Iniciadas por 1
		aArray := FnGIMApur("000002", "1", cData)

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "1", cData)

		// Registro 02 - Entradas do Estado
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt  //Soma Valores Contábeis
		nTotValBs += nValBs  //Soma Base de Cálculo
		nTotValIc += nValIc  //Soma Imposto Creditado
		nTotValSt += nValST  //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		//===================================================

		//Entradas CFOP Iniciadas por 2
		aArray := FnGIMApur("000002", "2", cData)

		nValCt := 0
		nValBs := 0
		nValIc := 0
		nValST := 0

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "2", cData)

		// Registro 03 - Entradas de Outros Estados
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt  //Soma Valores Contábeis
		nTotValBs += nValBs  //Soma Base de Cálculo
		nTotValIc += nValIc  //Soma Imposto Creditado
		nTotValSt += nValST  //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		//===================================================
		//Entradas CFOP Iniciadas por 3

		aArray := FnGIMApur("000002", "3", cData)

		nValCt := 0
		nValBs := 0
		nValIc := 0
		nValST := 0

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "3", cData)

		// Registro 04 - Entradas do Exterior
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt   //Soma Valores Contábeis
		nTotValBs += nValBs   //Soma Base de Cálculo
		nTotValIc += nValIc   //Soma Imposto Creditado
		nTotValSt += nValST   //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		// Registro 05 - Totais de Entradas
		cStrTxt += padL(cValToChar(nTotValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nTotValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nTotValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nTotValSt * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		//SAÍDAS

		//===================================================
		//Saídas CFOP Iniciadas por 5
		aArray := FnGIMApur("000002", "5", cData)

		nValCt := 0
		nValBs := 0
		nValIc := 0
		nValST := 0

		nTotValCt := 0
		nTotValBs := 0
		nTotValIc := 0
		nTotValSt := 0

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "5", cData)

		// Registro 06 - Saídas para o Estado
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt //Soma Valores Contábeis
		nTotValBs += nValBs //Soma Base de Cálculo
		nTotValIc += nValIc //Soma Imposto Creditado
		nTotValSt += nValST //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		//===================================================

		//Saídas CFOP Iniciadas por 6

		aArray := FnGIMApur("000002", "6", cData)

		nValCt := 0
		nValBs := 0
		nValIc := 0
		nValST := 0

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "6", cData)

		// Registro 07 - Saídas para Outros Estados
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt  //Soma Valores Contábeis
		nTotValBs += nValBs  //Soma Base de Cálculo
		nTotValIc += nValIc  //Soma Imposto Creditado
		nTotValSt += nValST  //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		//===================================================
		//Saídas CFOP Iniciadas por 7

		aArray := FnGIMApur("000002", "7", cData)

		nValCt := 0
		nValBs := 0
		nValIc := 0
		nValST := 0

		For nX := 1 To len(aArray)
			nValCt := aArray[nX, 1]
			nValBs := aArray[nX, 2]
			nValIc := aArray[nX, 3]
		Next

		nValSt := FnGIMApur("000004", "7", cData)

		// Registro 08 - Saídas para o Exterior
		cStrTxt += padL(cValToChar(nValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nValST * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF

		nTotValCt += nValCt  //Soma Valores Contábeis
		nTotValBs += nValBs  //Soma Base de Cálculo
		nTotValIc += nValIc  //Soma Imposto Creditado
		nTotValSt += nValST  //Soma Valor Contábil das Outras Operações p/ Substituição Tributária

		//Registro 09 - Totais de Saídas
		cStrTxt += padL(cValToChar(nTotValCt * 100),14) //Valores Contábeis
		cStrTxt += padL(cValToChar(nTotValBs * 100),14) //Base de Cálculo
		cStrTxt += padL(cValToChar(nTotValIc * 100),14) //Imposto Creditado
		cStrTxt += padL(cValToChar(nTotValSt * 100),14) //Valor Contábil das Outras Operações p/ Substituição Tributária
		cStrTxt += CRLF
		//==========================================================

		WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "01")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return

Function FnGIMApur(cTrib as char, cCFOP as char, cPeriodo as char)

	Local nValor 		as numeric
	Local cAliasQry	:= GetNextAlias()
	Local aArray as array

	Local cSelect as char
	Local cFrom 	as char
	Local cWhere 	as char

	aArray := {}

	cSelect := " SUM(C2F_VLOPE) VLCONT "

	If cTrib == "000002"
		cSelect += ", SUM(C2F_BASE) BASE, SUM(C2F_VALOR) IMPCRD "
	EndIf

	cFrom := RetSqlName('C20') + " C20,"
	cFrom += RetSqlName('C2F') + " C2F,"
	cFrom += RetSqlName('C0Y') + " C0Y "

	cWhere := "     C20.C20_FILIAL = '" + xFilial("C20") + "' "
	cWhere += " AND SUBSTRING(C20.C20_DTDOC,1,6) = '" + cPeriodo + "' "
	cWhere += " AND C20.C20_CODSIT IN ('000001', '000002', '000007', '000008', '000009')"

	/*
	========TIPOS DE DOCUMENTOS CONSIDERADOS===========

	000001	DOCUMENTO REGULAR
	000002 ESCRITURACAO EXTEMPORANEA DE DOCUMENTO REGULAR
	000007	DOCUMENTO FISCAL COMPLEMENTAR
	000008	ESCRITURACAO EXTEMPORANEA DE DOCUMENTO COMPLEMENTAR
	000009	DOCUMENTO FISCAL EMITIDO COM BASE EM REGIME ESPECIAL OU NORMA ESPECIFICA
	*/

	cWhere += " AND C2F.C2F_FILIAL = C20.C20_FILIAL "
	cWhere += " AND C2F.C2F_CHVNF  = C20.C20_CHVNF "
	cWhere += " AND C2F.C2F_CODTRI = '" + cTrib + "' "

	cWhere += " AND C0Y.C0Y_ID      = C2F.C2F_CFOP"
	cWhere += " AND SUBSTRING(C0Y.C0Y_CODIGO,1,1)= '" + cCFOP   + "' "

	cWhere += " AND C20.D_E_L_E_T_ 	= '' "
	cWhere += " AND C2F.D_E_L_E_T_ 	= '' "
	cWhere += " AND C0Y.D_E_L_E_T_ 	= '' "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasQry
       SELECT
             %Exp:cSelect%
       FROM
             %Exp:cFrom%
       WHERE
             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	If cTrib == "000002"
		AADD(aArray, {(cAliasQry)->VLCONT, (cAliasQry)->BASE, (cAliasQry)->IMPCRD})
		Return aArray
	Else
		nValor := (cAliasQry)->VLCONT
	EndIf

Return nValor

