#Include 'Protheus.ch'

Function TAFGIM03(aWizard, cJobAux)

	//13º Registro - ICMS do Período (Normal / Substituição)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local nValSdoApu as numeric
	Local nValIcmRet as numeric

	Begin Sequence

		DbSelectArea("C2S")
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .AND. xFilial("C2S") == xFilial("C2S")

		 		If (!(	Substr(DtoS(C2S->C2S_DTINI),1,6) == cData .AND. ;
		 			  	Substr(DtoS(C2S->C2S_DTFIN),1,6) == cData))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif

		 		nValSdoApu := C2S->C2S_SDOAPU 	//Saldo Devedor Apurado no Período

				C2S->(dbSkip())
			EndDo
		EndIf

	 	nValIcmRet := FnGetValue(cData)

	 	cStrTxt := padL(cValToChar(nValSdoApu * 100),14) //Saldo Devedor Apurado no Período
		cStrTxt += padL(cValToChar(nValIcmRet * 100),14) //Valor Total do ICMS Retido por Terceiros Relativo às Aquisições Sujeitas à ST
		cStrTxt += CRLF

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "03")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "3" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return


Static Function FnGetValue(cPeriodo)

	Local cStrQuery	:= ""
	Local cAliasQry		:= GetNextAlias()

	Local cSelect as char
	Local cFrom 	as char
	Local cWhere 	as char

	cSelect := " SUM(C2F_VALOR) VALOR  "
	cFrom   := RetSqlName('C20') + ' C20, '
	cFrom   += RetSqlName('C2F') + ' C2F '
	cWhere  := "     C20.C20_FILIAL  = '" + xFilial("C20") + "' "
	cWhere  += " AND C20.C20_INDOPE  = '0' "
	cWhere  += " AND C20.C20_CODSIT IN ('000001', '000002', '000007', '000008', '000009')"

	/*
	========TIPOS DE DOCUMENTOS CONSIDERADOS===========

	000001	DOCUMENTO REGULAR
	000002 ESCRITURACAO EXTEMPORANEA DE DOCUMENTO REGULAR
	000007	DOCUMENTO FISCAL COMPLEMENTAR
	000008	ESCRITURACAO EXTEMPORANEA DE DOCUMENTO COMPLEMENTAR
	000009	DOCUMENTO FISCAL EMITIDO COM BASE EM REGIME ESPECIAL OU NORMA ESPECIFICA
	*/

	cWhere  += " AND SUBSTRING(C20.C20_DTDOC,1,6)	= '" + cPeriodo + "' "
	cWhere  += " AND C2F.C2F_FILIAL  = C20.C20_FILIAL "
	cWhere  += " AND C2F.C2F_CHVNF   = C20.C20_CHVNF  "
	cWhere  += " AND C2F.C2F_CODTRI  = '000004' "
	cWhere  += " AND C20.D_E_L_E_T_  = '' "
	cWhere  += " AND C2F.D_E_L_E_T_  = '' "

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

