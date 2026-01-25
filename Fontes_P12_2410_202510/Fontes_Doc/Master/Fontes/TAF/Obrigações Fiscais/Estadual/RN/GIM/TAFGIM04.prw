#Include 'Protheus.ch'

Function TAFGIM04(aWizard, cJobAux)

	//14º Registro - ICMS do Período (Substituto pelas Saídas – Prestações de Serviço / Mercadorias)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		as char
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local nValColA as numeric
	Local nValColB as numeric

	Begin Sequence

	 	nValColA := FnGetValue(cData, "000010") //Período, C1L_TIPITE
	 	nValColB := FnGetValue(cData, "000001") //Período, C1L_TIPITE

	 	cStrTxt := padL(cValToChar(nValColA * 100),14) //Saldo Devedor Apurado no Período
		cStrTxt += padL(cValToChar(nValColB * 100),14) //Valor Total do ICMS Retido por Terceiros Relativo às Aquisições Sujeitas à ST
		cStrTxt += CRLF

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "04")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "4" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf
Return

Static Function FnGetValue(cPeriodo, cTipi)

	Local cAliasQry		:= GetNextAlias()

	Local cSelect as char
	Local cFrom 	as char
	Local cWhere 	as char

	cSelect := "SUM(C35_VALOR) VALOR  "

	cFrom   := RetSqlName('C20') + ' C20, '
	cFrom   += RetSqlName('C30') + ' C30, '
	cFrom   += RetSqlName('C35') + ' C35, '
	cFrom   += RetSqlName('C1L') + ' C1L '

	cWhere  := " 	C20.C20_FILIAL  = '" + xFilial("C20") + "' "
	cWhere  += " AND C20.C20_INDOPE  = '1' "
	cWhere  += " AND SUBSTRING(C20.C20_DTDOC,1,6)	= '" + cPeriodo + "' "
	cWhere  += " AND C20.C20_CODSIT IN ('000001', '000002', '000007', '000008', '000009')"

	/*
	========TIPOS DE DOCUMENTOS CONSIDERADOS===========

	000001	DOCUMENTO REGULAR
	000002 ESCRITURACAO EXTEMPORANEA DE DOCUMENTO REGULAR
	000007	DOCUMENTO FISCAL COMPLEMENTAR
	000008	ESCRITURACAO EXTEMPORANEA DE DOCUMENTO COMPLEMENTAR
	000009	DOCUMENTO FISCAL EMITIDO COM BASE EM REGIME ESPECIAL OU NORMA ESPECIFICA
	*/

	cWhere  += " AND C30.C30_FILIAL  = C20.C20_FILIAL "
	cWhere  += " AND C30.C30_CHVNF   = C20.C20_CHVNF  "
	cWhere  += " AND C1L.C1L_FILIAL  = C20.C20_FILIAL "
	cWhere  += " AND C1L.C1L_ID      = C30.C30_CODITE "
	cWhere  += " AND C1L.C1L_TIPITE  = '" + cTipi + "'"
	cWhere  += " AND C35.C35_FILIAL  = C30.C30_FILIAL "
	cWhere  += " AND C35.C35_CHVNF   = C30.C30_CHVNF  "
	cWhere  += " AND C35.C35_NUMITE  = C30.C30_NUMITE "
	cWhere  += " AND C35.C35_CODITE  = C30.C30_CODITE "
	cWhere  += " AND C35.C35_CODTRI  = '000004' "
	cWhere  += " AND C20.D_E_L_E_T_  = '' "
	cWhere  += " AND C30.D_E_L_E_T_  = '' "
	cWhere  += " AND C35.D_E_L_E_T_  = '' "
	cWhere  += " AND C1L.D_E_L_E_T_  = '' "

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
