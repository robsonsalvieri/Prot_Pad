#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0400
Gera o reguitro 0400 da DECLANN-IPM
@parametro aWizard, nValor, nCont
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 

Function TAFDE0400(aWizard, nValor, nCont)

	Local cQuery 	as character
	Local cAlias    as character
	Local aBind     as array
	Local oPrepare  as object
	Local nA  		as numeric

	Local cTxtSys  	as character
	Local nHandle   as numeric
	Local cReg 		as character

	Local cPerApu	as character
	Local cStrTxt 	as character

	cQuery	 	:= ""
	cAlias	 	:= ""
	aBind 		:= {}
	oPrepare 	:= Nil
	nA			:= 0

	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle     := MsFCreate( cTxtSys )
	cReg 		:= "0400"

	cPerApu		:= Substr(aWizard[2][1],1,4)
	cStrTxt 	:= "" 

	cQuery := " SELECT T39.T39_TIPREG TIPREG, T36.T36_VLRDIS VLRDIS, T37.T37_CODDIS CODDIS, T2D.T2D_CODMUN CODMUN "
	cQuery += " FROM " + RetSQLName("T39") + " T39"
	cQuery += " INNER JOIN " + RetSQLName("T36") + " T36 ON T36.T36_FILIAL = T39.T39_FILIAL AND T36.T36_ID = T39.T39_ID AND T36.D_E_L_E_T_ = ? "
	aAdd(aBind, space(1))
	cQuery += " INNER JOIN " + RetSQLName("T37") + " T37 ON T37.T37_FILIAL = ? AND T37.T37_ID = T36.T36_IDCODI AND T37.D_E_L_E_T_ = ? "
	aAdd(aBind,  xFilial("T37"))
	aAdd(aBind, space(1))
	cQuery += " INNER JOIN " + RetSQLName("T2D") + " T2D ON T2D.T2D_FILIAL = ? AND T2D.T2D_IDMUN = T36.T36_IDCODL AND T2D.T2D_TPCLAS = ? AND T2D.D_E_L_E_T_ = ? "
	aAdd(aBind,  xFilial("T2D"))
	aAdd(aBind, "MUNRJ")
	aAdd(aBind, space(1))
	cQuery += " WHERE T39.T39_FILIAL = ? "
	aAdd(aBind,  xFilial("T39"))
	cQuery += " AND T39.T39_ANOREF = ? "
	aAdd(aBind, cPerApu)
	cQuery += " AND T39.D_E_L_E_T_ = ? "
	aAdd(aBind, space(1))

	oPrepare := FwExecStatement():New( cQuery )

	For nA := 1 to len(aBind)
	    oPrepare:setString( nA, aBind[nA] )
	Next nA

	cQuery := oPrepare:getFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

	While (cAlias)->( !Eof() )

		cStrTxt := "0400"												//Tipo 							  	- Valor Fixo: 0200
		cStrTxt += "000000000000001"									//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001

		If (cAlias)->TIPREG == '2'                                 		//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples Nacional
			cStrTxt += "N"
		Else
			cStrTxt += "S"
		EndIf

		cStrTxt += StrZero(Val((cAlias)->CODDIS),5)

		cStrTxt += StrZero(Val((cAlias)->CODMUN),8)						//Código da Localidade

		nValor  += (cAlias)->VLRDIS 									//Carrega parametro para contabilizar no registro 9999
		cStrTxt += StrTran(StrZero((cAlias)->VLRDIS, 16, 2),".","")
		
		cStrTxt := Left(cStrTxt,48) + space(307)						//Filler 									- Preencher com espaços em branco
					
		nCont ++
		cStrTxt += StrZero(nCont,5) 									//Número da linha							- Número da linha
		cStrTxt += CRLF 												//Proxima Linha
		WrtStrTxt( nHandle, cStrTxt )

		(cAlias)->( DBSkip() )
	EndDo

	(cAlias)->(dbCloseArea())

	If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	EndIf

	GerTxtDERJ( nHandle, cTxtSys, cReg )
	
Return

