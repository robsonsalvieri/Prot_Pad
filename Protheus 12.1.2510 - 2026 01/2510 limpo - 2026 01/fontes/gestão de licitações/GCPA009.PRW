#INCLUDE "PROTHEUS.ch"
#INCLUDE "GCPA009.ch"
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GCPA009    บAutor  ณ Totvs              บ Data ณ  01/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao dos dados para Pedidos de Venda, Pedidos de Compra e บฑฑ
ฑฑบ			 ณ Contratos conforme vencedores do edital.						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GCPA010, GCPA011 e GCPA013									บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GCPA009(cCodFil)

Local aCTBEnt 	:= CtbEntArr()
Local aRet 		:= {}
Local aGCP9QRY	:= {}
Local cQuery  	:= ""
Local cFornec 	:= ""
Local cLoja   	:= ""
Local cAliasQry := ""
Local cAliasSC1 := ""
Local nGCP9QTD	:= 0
Local nOrder	:= 1
Local nPos    	:= 0
Local oQry		:= Nil
Local lGCP9QRY  := Existblock('GCP9QRY')			//-- Ponto de entrada para adicao de filtro
Local lGCP9QTD	:= Existblock('GCP9QTD')			//-- Ponto de entrada para manipulacao da quantidade
Local lRatItens	:= SuperGetMV("MV_GCPRATP",.F.,.F.)	//-- Grava dados contabeis do pedido como rateio (SCH)
local lSCCNI	:= SuperGetMV("MV_SCLCNI",.F.,.F.)

default cCodFil	:= FWxFilial('CO3')

	cQuery := " SELECT COUNT(C1_NUMPR) AS USARAT "
	cQuery += " FROM " + RetSQLName('SC1')
	cQuery += " WHERE "
	cQuery += " 		C1_FILIAL		= ? "
	cQuery += " 	AND	C1_FILIAL		<> C1_FILENT "
	cQuery += " 	AND	C1_CODED		= ? "
	cQuery += " 	AND	C1_NUMPR		= ? "
	cQuery += " 	AND	D_E_L_E_T_		= ? "

	oQry := FwPreparedStatement():New( changeQuery(cQuery) )
	oQry:setString(1, FWxFilial("SC1"))
	oQry:setString(2, CO1->CO1_CODEDT)
	oQry:setString(3, CO1->CO1_NUMPRO)
	oQry:setString(4, ' ')
	cQuery := oQry:GetFixQuery()

	cAliasSC1 := MPSysOpenQuery(cQuery)

	oQry:Destroy()

	//-- Caso o edital seja de compra compartilhada, desabilita a utilizacao do rateio por item do pedido (SCH)
	lRatItens := lRatItens .And. Empty((cAliasSC1)->USARAT)
	
	(cAliasSC1)->(dbCloseArea())

	cQuery := " SELECT	CO3.CO3_FILIAL	FILIAL, "
	cQuery += " 		CO3.CO3_CODEDT	CODEDT, "
	cQuery += "			CO3.CO3_NUMPRO	NUMPROC, "
	cQuery += "			CO3.CO3_CODIGO	CODIGO, "
	cQuery += "			CO3.CO3_LOJA	LOJA, "
	cQuery += "			CO3.CO3_TIPO	TIPO, "

	If CO1->CO1_AVAL == "1"	 	// -- CO1_AVAL == '1' -> Edital por Item ### CO1_AVAL == '2' -> Edital por Lote
		cQuery += "			CO3.CO3_CODPRO	CODPRO, "
	Else
		cQuery += "			CO3.CO3_LOTE	LOTE, "
		cQuery += "			CP6.CP6_CODPRO	CODPRO, "
		cQuery += "			CP6.CP6_PRCUN	PRCUNI, "
	EndIf
		
	cQuery += "			CO3.CO3_VLUNIT	VLUNIT, "
	
	If lRatItens
		cQuery += "			CO2.CO2_QUANT	QUANT, "
		cQuery += "			CO2.CO2_ITEM	ITEM, "
	Else
		cQuery += "			COALESCE(SC1.C1_QUANT,CO2.CO2_QUANT)	QUANT, "
		cQuery += "			COALESCE(SC1.C1_ITEM,CO2.CO2_ITEM)	ITEM, "
	EndIf      
	
	cQuery += "			COALESCE(SC1.C1_CC,SB1.B1_CC) CC, "
	cQuery += "			COALESCE(SC1.C1_CONTA,SB1.B1_CONTA) CONTA, "
	cQuery += "			COALESCE(SC1.C1_ITEMCTA,SB1.B1_ITEMCC) ITEMCTA, "
	cQuery += "			COALESCE(SC1.C1_CLVL,SB1.B1_CLVL) CLVL, "
	cQuery += "			COALESCE(SC1.C1_NUM,'') NUMSC, "
	cQuery += "			COALESCE(SC1.C1_FILENT,'') FILENT "

	//-- Adiciona campos das novas entidades contabeis
	For nPos := 1 To Len(aCTBEnt)
		If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
			cQuery += ", COALESCE(SC1.C1_EC?CR, SB1.B1_EC?CR) EC?CR "
			cQuery += ", COALESCE(SC1.C1_EC?DB,SB1.B1_EC?DB) EC?DB "
		Else
			cQuery += ", SB1.B1_EC?CR EC?CR "
			cQuery += ", SB1.B1_EC?DB EC?DB "
		EndIf
	Next nPos

	If lGCP9QRY
		aGCP9QRY := Execblock('GCP9QRY',.F.,.F.)	//-- Ponto de entrada para adicao de campos na query
		If (lGCP9QRY := ValType(aGCP9QRY[1]) == "C" .And. ValType(aGCP9QRY[2]) == "C")
			cQuery += aGCP9QRY[1]
		EndIf
	EndIf

	cQuery += "FROM " +RetSqlName("CO3") +" CO3 "

	cQuery += " INNER JOIN " +RetSQLName("CO2") +" CO2 "
	cQuery += " 	ON	" + FwJoinFilial("CO2","CO3")
	cQuery += "		AND	CO2.CO2_CODEDT	= CO3.CO3_CODEDT "
	cQuery += "		AND	CO2.CO2_NUMPRO	= CO3.CO3_NUMPRO "

	If CO1->CO1_AVAL == "1"		 // -- CO1_AVAL == '1' -> Edital por Item ### CO1_AVAL == '2' -> Edital por Lote
		cQuery += "		AND CO2.CO2_CODPRO	= CO3.CO3_CODPRO "
		cQuery += "		AND CO2.CO2_ITEM	= CO3.CO3_ITEM "
		cQuery += "		AND	CO2.D_E_L_E_T_	= ? "
	Else
		cQuery += "		AND CO2.CO2_LOTE	= CO3.CO3_LOTE "
		cQuery += "		AND	CO2.D_E_L_E_T_	= ? "
		
		cQuery += "	INNER JOIN " +RetSQLName("CP6") +" CP6 "
		cQuery += " 	ON	" + FwJoinFilial("CP6","CO3")
		cQuery += " 	AND	CP6.CP6_CODEDT	= CO3.CO3_CODEDT " 
		cQuery += " 	AND	CP6.CP6_NUMPRO	= CO3.CO3_NUMPRO "
		cQuery += " 	AND CP6.CP6_REVISA	= CO3.CO3_REVISA "
		cQuery += " 	AND CP6.CP6_LOTE	= CO3.CO3_LOTE "
		cQuery += " 	AND CP6.CP6_CODIGO	= CO3.CO3_CODIGO "
		cQuery += " 	AND CP6.CP6_LOJA	= CO3.CO3_LOJA "
		cQuery += " 	AND	CP6.D_E_L_E_T_	= ? "
	EndIf

	cQuery += " LEFT JOIN " +RetSQLName("SB1") +" SB1 "
	cQuery += " 	ON	" + FwJoinFilial("SB1","CO2")
	cQuery += " 	AND	SB1.B1_COD		= CO2.CO2_CODPRO "
	cQuery += " 	AND	SB1.D_E_L_E_T_	= ? "

	cQuery += " LEFT JOIN " +RetSQLName("SC1") +" SC1 "
	cQuery += " 	ON	" + FwJoinFilial("SC1","CO2")
	cQuery += " 	AND	SC1.C1_CODED	= CO2.CO2_CODEDT "
	cQuery += " 	AND	SC1.C1_NUMPR	= CO2.CO2_NUMPRO "
	cQuery += " 	AND	SC1.C1_PRODUTO	= CO2.CO2_CODPRO "
	cQuery += " 	AND	SC1.D_E_L_E_T_	= ? "

	//-- Se rateio contabil na SCH, forca nao trazer SC1
	If lRatItens
		cQuery += "		AND SC1.C1_PRODUTO = ? "
	EndIf

	cQuery += " WHERE "
	cQuery += "			CO3.CO3_FILIAL	= ? "
	cQuery += " 	AND	CO3.CO3_CODEDT	= ? "
	cQuery += " 	AND	CO3.CO3_NUMPRO	= ? "
	cQuery += " 	AND	CO3.CO3_STATUS	= ? "

	//-- Ponto de entrada para adicao de filtro
	If lGCP9QRY
		cQuery += aGCP9QRY[2]
	EndIf

	cQuery += "		AND CO3.D_E_L_E_T_	= ?  "

	If lRatItens
		If lSCCNI
			cQuery += " ORDER BY FILIAL, CODIGO, LOJA, TIPO, FILENT"
		Else
			cQuery += " ORDER BY FILIAL, ITEM, TIPO, CODIGO, LOJA"
		EndIf
	ElseIf CO1->CO1_AVAL == "2"		 // -- CO1_AVAL == '1' -> Edital por Item ### CO1_AVAL == '2' -> Edital por Lote
		cQuery += " ORDER BY FILIAL, CODIGO, LOJA, FILENT, LOTE
	Else
		cQuery += " ORDER BY FILIAL, CODIGO, LOJA, FILENT, ITEM, CODPRO" 
	EndIf

	oQry := FwPreparedStatement():New( changeQuery(cQuery) )

	For nPos := 1 To Len(aCTBEnt)
		If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
		Else
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
			oQry:setUnsafe(nOrder++, aCTBEnt[nPos])
		EndIf
	Next nPos
	
	if CO1->CO1_AVAL == "1"
		oQry:setString(nOrder++, ' ')
	else
		oQry:setString(nOrder++, ' ')
		oQry:setString(nOrder++, ' ')
	endif

	oQry:setString(nOrder++, ' ')
	oQry:setString(nOrder++, ' ')

	if lRatItens
		oQry:setString(nOrder++, ' ')
	endif
	
	oQry:setString(nOrder++, cCodFil)
	oQry:setString(nOrder++, CO1->CO1_CODEDT)
	oQry:setString(nOrder++, CO1->CO1_NUMPRO)
	oQry:setString(nOrder++, '5')
	oQry:setString(nOrder++, ' ')
	
	cQuery := oQry:GetFixQuery()

	cAliasQry := MPSysOpenQuery(cQuery)

	oQry:Destroy()
	
	While (cAliasQry)->(!Eof())
		
		cFornec := (cAliasQry)->CODIGO
		cLoja   := (cAliasQry)->LOJA
		
		aAdd(aRet,Array(14))
		
		aTail(aRet)[1] := cFornec				//-- 1. Codigo do fornecedor
		aTail(aRet)[2] := cLoja					//-- 2. Loja do fornecedor
		aTail(aRet)[3] := (cAliasQry)->CODPRO	//-- 3. Codigo do produto
		
		//-- Ponto de entrada para manipulacao da quantidade
		If lGCP9QTD
			nGCP9QTD := Execblock('GCP9QTD',.F.,.F.,{cAliasQry})
			aTail(aRet)[4] := If(ValType(nGCP9QTD) == "N" .And. nGCP9QTD > 0, nGCP9QTD, (cAliasQry)->QUANT)
		Else
			aTail(aRet)[4] := (cAliasQry)->QUANT	//-- 4. Quantidade
		EndIf

		aTail(aRet)[5]	:= IIf(CO1->CO1_AVAL == "2",(cAliasQry)->PRCUNI,(cAliasQry)->VLUNIT)		//-- 5. Pre็o unitario
		aTail(aRet)[6]	:= (cAliasQry)->CODEDT														//-- 6. Codigo do edital
		aTail(aRet)[7]	:= (cAliasQry)->NUMPROC														//-- 7. Numero do processo
		aTail(aRet)[8]	:= If(!lRatItens,(cAliasQry)->CC,"")										//-- 8. Centro de custo
		aTail(aRet)[9]	:= If(!lRatItens,(cAliasQry)->CONTA,"")										//-- 9. Conta contabil
		aTail(aRet)[10] := If(!lRatItens,(cAliasQry)->ITEMCTA,"")									//-- 10. Item de conta
		aTail(aRet)[11] := If(!lRatItens,(cAliasQry)->CLVL,"")										//-- 11 Classe de valor
		aTail(aRet)[12] := If(!lRatItens .And. !Empty((cAliasQry)->NUMSC),(cAliasQry)->NUMSC,"")	//-- 12. Solicitacao
		aTail(aRet)[13] := If(!lRatItens .And. !Empty((cAliasQry)->NUMSC),PadR((cAliasQry)->ITEM,TamSX3("C1_ITEM")[1]),"")	//-- 13. Item
		aTail(aRet)[14] := (cAliasQry)->FILENT														//-- 14. Filial de Entrega
		
		//-- Adiciona entidades contabeis
		For nPos := 1 To Len(aCTBEnt)
			aAdd(aTail(aRet),If(!lRatItens,(cAliasQry)->&("EC"+aCTBEnt[nPos]+"CR"),""))
			aAdd(aTail(aRet),If(!lRatItens,(cAliasQry)->&("EC"+aCTBEnt[nPos]+"DB"),""))
		Next nPos
		
		If CO1->CO1_AVAL == '2'		 // -- CO1_AVAL == '1' -> Edital por Item ### CO1_AVAL == '2' -> Edital por Lote
			aAdd(aTail(aRet), (cAliasQry)->LOTE)
		EndIf
		
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	
	FwFreeArray(aCTBEnt)
	FwFreeArray(aGCP9QRY)

return aRet
