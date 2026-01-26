#Include 'Protheus.ch'

Function TAFGIM10(aWizard, cJobAux)

	//20º Registro - Estoque

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		as char
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local nValEst as numeric

	Begin Sequence

		nValEst := FnGetValue(aWizard[1][2])

	 	cStrTxt := Substr(aWizard[1][2],1,2)
	 	cStrTxt += Substr(aWizard[1][2],4,4)
		cStrTxt += padL(cValToChar(nValEst * 100),14) //Valor Total do ICMS Retido por Terceiros Relativo às Aquisições Sujeitas à ST
		cStrTxt += CRLF

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "10")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "10" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return

Static Function FnGetValue(cData as char)

	Local cAliasQry	:= GetNextAlias()
	Local cDataIni	as char
	Local cDataFim	as char

	Local cSelect as char
	Local cFrom 	as char
	Local cWhere 	as char

	cDataFim	:= Dtos(Lastday(CTOD("01/" + cData),0))

	cSelect	:= " C5A_VINV VALOR"

	cFrom	:= RetSqlName( 'C5A' ) + " C5A "

	cWhere 	:= "  	  C5A.C5A_FILIAL  = '" + xFilial("C5A") + "' "
	cWhere 	+= " AND C5A_DTINV       = '" + cDataFim + "' "
	cWhere 	+= " AND C5A.D_E_L_E_T_  = '' "

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

	Return (cAliasQry)->VALOR

	(cAliasQry)->(DbCloseArea())

Return 0


