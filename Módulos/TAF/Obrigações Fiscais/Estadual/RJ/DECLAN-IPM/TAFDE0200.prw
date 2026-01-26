#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0200
Gera o reguitro 0200 da DECLANN-IPM
@parametro aWizard, nValor, nCont
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 
Function TAFDE0200(aWizard, nValor, nCont)

	Local cTxtSys    as character	
	Local nHandle    as numeric
	Local cReg 	     as character
	Local cDtInc	 as character
	Local cDtFim	 as character
	Local cQuery 	 as character
	Local cAlias     as character
	Local aBind      as array
	Local oPrepare   as object
	Local cTipReg 	 as character

	//CFOP - Entrada
	Local nVlrEntEstado 	as numeric
	Local nVlrEntOutEstado 	as numeric
	Local nVlrEntExterior	as numeric
	Local nVlrEntAnoBase	as numeric

	//Saída
	Local nVlrSaiEstado 	as numeric
	Local nVlrSaiOutEstado 	as numeric
	Local nVlrSaiExterior	as numeric
	Local nVlrSaiAnoBase	as numeric
	Local cStrTxt 			as character

	cTxtSys  			:= CriaTrab( , .F. ) + ".TXT"
	nHandle     		:= MsFCreate( cTxtSys )
	cReg 				:= "0200"
	cDtInc   			:= ""
	cDtFim   			:= ""
	cQuery	 			:= ""
	cAlias	 			:= ""
	aBind 				:= {}
	oPrepare 			:= Nil
	cTipReg     		:= ""		
	nVlrEntEstado 		:= 0
	nVlrEntOutEstado 	:= 0
	nVlrEntExterior		:= 0
	nVlrEntAnoBase		:= 0
	nVlrSaiEstado 	 	:= 0
	nVlrSaiOutEstado 	:= 0
	nVlrSaiExterior		:= 0
	nVlrSaiAnoBase		:= 0
	cStrTxt 			:= ""

	nCont := 2

	cStrTxt := "0200"			 //Tipo - Valor Fixo: 0200
	cStrTxt += "000000000000001" //Número Seqüencial da Declaração	- Valor Fixo: 000000000000001

	DbSelectArea("T39")
	DbSetOrder(2)
	If DbSeek(xFilial("T39") + Substr(aWizard[2][1],1,4))                                                                                                   
		//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples
		If T39->T39_TIPREG == '2'
			cTipReg := "N"		
		Else
			cTipReg := "S"			
		EndIf
	EndIf

	cStrTxt += cTipReg

	If aWizard[3][1] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][2] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][3] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][4] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][5] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][6] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf
	If aWizard[3][7] == '0 - Não'
		cStrTxt += "N"
	Else
		cStrTxt += "S"
	EndIf

	cDtInc := Substr(aWizard[2][1],1,4) + "0101"
	cDtFim := Substr(aWizard[2][1],1,4) + "1231"

	cQuery := " SELECT C0Y.C0Y_CODIGO CFOP "
	cQuery += " ,C6Z.C6Z_VLCONT VALOR "
	cQuery += " FROM " + RetSQLName("C2S") + " C2S"
	cQuery += " INNER JOIN " + RetSQLName("C6Z") + " C6Z ON C6Z.C6Z_FILIAL = C2S.C2S_FILIAL AND C6Z.C6Z_ID = C2S.C2S_ID AND C6Z.D_E_L_E_T_ = ? "
	aAdd(aBind, space(1))
	cQuery += " INNER JOIN " + RetSQLName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = ? AND C0Y.C0Y_ID = C6Z.C6Z_CFOP AND C0Y.D_E_L_E_T_ = ? "
	aAdd(aBind,  xFilial("C0Y"))
	aAdd(aBind, space(1))
	cQuery += " WHERE C2S.C2S_FILIAL = ? "
	aAdd(aBind,  xFilial("C2S"))
	cQuery += " AND C2S.C2S_DTINI BETWEEN ? AND ? "
	aAdd(aBind, cDtInc)
	aAdd(aBind, cDtFim)
	cQuery += " AND C2S.D_E_L_E_T_ = ? "
	aAdd(aBind, space(1))

	oPrepare := FwExecStatement():New( cQuery )

	TafSetPrepare(oPrepare,aBind)

	cQuery := oPrepare:getFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

	While (cAlias)->( !Eof() )
		
		cCodCfop := SubString((cAlias)->CFOP,1,1)

		//Soma Entradas no Ano-Base - Estado (Ficha "Resumo Geral")
		If cCodCfop == '1'
			nVlrEntEstado += (cAlias)->VALOR
		ElseIf cCodCfop == '2'
			nVlrEntOutEstado += (cAlias)->VALOR
		ElseIf cCodCfop == '3'
			nVlrEntExterior += (cAlias)->VALOR
		//Soma Saídas no Ano-Base - Estado (Ficha "Resumo Geral")
		ElseIf cCodCfop == '5'
			nVlrSaiEstado += (cAlias)->VALOR
		ElseIf cCodCfop == '6'
			nVlrSaiOutEstado += (cAlias)->VALOR
		ElseIf cCodCfop == '7'
			nVlrSaiExterior += (cAlias)->VALOR
		EndIf

		(cAlias)->( DBSkip() )
	EndDo

	(cAlias)->(dbCloseArea())

	If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	EndIf
		
	nVlrEntAnoBase := nVlrEntEstado + nVlrEntOutEstado + nVlrEntExterior //Total
	nVlrSaiAnoBase := nVlrSaiEstado + nVlrSaiOutEstado + nVlrSaiExterior //Total

	nValor := nVlrEntEstado + nVlrEntOutEstado + nVlrEntExterior + nVlrEntAnoBase + nVlrSaiEstado + nVlrSaiOutEstado +  nVlrSaiExterior + nVlrSaiAnoBase

	cStrTxt += StrTran(StrZero(nVlrEntEstado    , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntOutEstado , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntExterior  , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntAnoBase   , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiEstado	, 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiOutEstado , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiExterior  , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiAnoBase   , 16, 2),".","")

	nVlrEntEstado    := 0
    nVlrEntOutEstado := 0
    nVlrEntExterior  := 0
    nVlrEntAnoBase   := 0
    nVlrSaiEstado    := 0
    nVlrSaiOutEstado := 0
    nVlrSaiExterior  := 0
    nVlrSaiAnoBase   := 0

	If aWizard[3][1] == '1 - Sim' .And. aWizard[3][3] == '1 - Sim' .And. aWizard[3][4] == '1 - Sim'

		cCodCfop := ""
		cQuery   := ""
		aBind	 := {}

		cQuery := " SELECT C0Y.C0Y_CODIGO CFOP "
		cQuery += " ,C2P.C2P_VLIPI VALOR "
		cQuery += " FROM " + RetSQLName("C2N") + " C2N"
		cQuery += " INNER JOIN " + RetSQLName("C2P") + " C2P ON C2P.C2P_FILIAL = C2N.C2N_FILIAL AND C2P.C2P_ID = C2N.C2N_ID AND C2P.D_E_L_E_T_ = ? "
		aAdd(aBind, space(1))
		cQuery += " INNER JOIN " + RetSQLName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = ? AND C0Y.C0Y_ID = C2P.C2P_CFOP AND C0Y.D_E_L_E_T_ = ? "
		aAdd(aBind,  xFilial("C0Y"))
		aAdd(aBind, space(1))
		cQuery += " WHERE C2N.C2N_FILIAL= ? "
		aAdd(aBind,  xFilial("C2N"))
		cQuery += " AND C2N.C2N_INDAPU = ? "
		aAdd(aBind, "0")
		cQuery += " AND C2N.C2N_DTINI BETWEEN ? AND ? "
		aAdd(aBind, cDtInc)
		aAdd(aBind, cDtFim)
		cQuery += " AND C2N.D_E_L_E_T_ = ? "
		aAdd(aBind, space(1))

		oPrepare := FwExecStatement():New( cQuery )

		TafSetPrepare(oPrepare,aBind)

		cQuery := oPrepare:getFixQuery()
		cAlias := MPSysOpenQuery(cQuery)

		While (cAlias)->( !Eof() )

			cCodCfop := SubString((cAlias)->CFOP,1,1)

			//Soma Entradas no Ano-Base - Estado (Ficha "Resumo Geral")
			If cCodCfop == '1'
				nVlrEntEstado -= (cAlias)->VALOR
			ElseIf cCodCfop == '2'
				nVlrEntOutEstado -= (cAlias)->VALOR
			ElseIf cCodCfop == '3'
				nVlrEntExterior -= (cAlias)->VALOR
			//Soma Saídas no Ano-Base - Estado (Ficha "Resumo Geral")
			ElseIf cCodCfop == '5'
				nVlrSaiEstado -= (cAlias)->VALOR
			ElseIf cCodCfop == '6'
				nVlrSaiOutEstado -= (cAlias)->VALOR
			ElseIf cCodCfop == '7'
				nVlrSaiExterior -= (cAlias)->VALOR
			EndIf

			(cAlias)->( DBSkip() )
		EndDo

		(cAlias)->(dbCloseArea())

		If oPrepare != Nil
			oPrepare:Destroy()
			oPrepare := nil
		EndIf

		nVlrEntAnoBase := nVlrEntEstado + nVlrEntOutEstado + nVlrEntExterior //Total
		nVlrSaiAnoBase := nVlrSaiEstado + nVlrSaiOutEstado + nVlrSaiExterior //Total
		nValor += nVlrEntAnoBase + nVlrSaiAnoBase
	EndIf

	cStrTxt += StrTran(StrZero(nVlrEntEstado   , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntOutEstado, 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntExterior , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrEntAnoBase  , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiEstado   , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiOutEstado, 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiExterior , 16, 2),".","")
	cStrTxt += StrTran(StrZero(nVlrSaiAnoBase  , 16, 2),".","")

	cStrTxt := Left(cStrTxt,268) + space(88) //Filler - Preencher com espaços em branco

	nCont ++
	cStrTxt += StrZero(nCont,5) //Número da linha - Número da linha
	cStrTxt += CRLF
	WrtStrTxt( nHandle, cStrTxt )

	GerTxtDERJ( nHandle, cTxtSys, cReg )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSetPrepare
Realiza atribuicao dos filtros, seja string ou array
para utilizacao do bind nas queries com FwExecStatement e OpenAlias
@parametro oPrepare nil, aBind {}
@author Carlos Pister	
@since 31/10/2024
@version 1.0
/*/ 
//-------------------------------------------------------------------- 
Static Function TafSetPrepare(oObj,aBind)

	Local nA := 0

	Default oObj := Nil
	Default aBind := {}

	For nA := 1 to len(aBind)
        oObj:setString( nA, aBind[nA] )
	Next nA

Return Nil
