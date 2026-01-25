#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDE0500
Gera o reguitro 0500 da DECLANN-IPM
@parametro aWizard, nValor, nCont
@author 
@since 
@version 1.0
@Altered by Pister in 31/10/2024 Refatoração
/*/ 
//-------------------------------------------------------------------- 

Function TAFDE0500(aWizard, nValor, nCont)

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
	cREG 		:= "0500"

	cPerApu		:= Substr(aWizard[2][1],1,4)
	cStrTxt 	:= ""

	cQuery := " SELECT T39_TIPREG TIPREG, T38_MES MES, T38_RECBRU RECBRU, T38_RECEMP RECEMP "
	cQuery += " FROM " + RetSQLName("T39") + " T39"
	cQuery += " INNER JOIN " + RetSQLName("T38") + " T38 ON T38.T38_FILIAL = T39.T39_FILIAL AND T38.T38_ID = T39.T39_ID AND T38.D_E_L_E_T_ = ? "
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

		cStrTxt := "0500"												//Tipo 							  	- Valor Fixo: 0200
		cStrTxt += "000000000000001"									//Número Seqüencial da Declaração	- Valor Fixo: 000000000000001
		cStrTxt += (cAlias)->MES

		If (cAlias)->TIPREG == '2'										//Regime do Registro	- N = Normal, Estimativa e Outros;S = Simples 
			cStrTxt += "N"
		Else
			cStrTxt += "S"
		EndIf

		nValor  += (cAlias)->RECBRU 									//Carrega parametro para contabilizar no registro 9999
		cStrTxt += StrTran(StrZero((cAlias)->RECBRU, 16, 2),".","")		//Valor da Receita Bruta do Estabelecimento
					
		nValor  += (cAlias)->RECEMP //Carrega parametro para contabilizar no registro 9999
		cStrTxt += StrTran(StrZero((cAlias)->RECEMP, 16, 2),".","")		//Valor da Receita Bruta da Empresa
					
		cStrTxt += "000000000000000"									//Valor da Receita Bruta de Substituição Tributária do Estabelecimento	- Valor Fixo: 000000000000000
		cStrTxt += "000000000000000"									//Valor da Receita Bruta de Substituição Tributária do Estabelecimento	- Valor Fixo: 000000000000000
		cStrTxt := Left(cStrTxt,83) + space(273	)						//Filler 									- Preencher com espaços em branco
					
		nCont ++
		cStrTxt += StrZero(nCont,5)										//Número da linha							- Número da linha
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
