#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFBLCJ

Rotina extratora da informacoes para o Bloco J do ECF.

@Param	cTABCTL	->	Nome da tabela de controle de transações
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread

@obs Luccas ( 31/03/2016 ): Devido a mudança em relação ao compartilhamento das tabelas
do TAF ( inicialmente todas eram exclusivas, mas o cliente pode optar por ter tabelas
compartilhadas, por exemplo Plano de Contas, Centro de Custo, Itens, etc. ), as rotinas
de geração das obrigações tiveram que ser alteradas ( em algumas situações ) para a
utilização da função xFilial ao invés da variável cFilSel.
O conteúdo desta variável é o mesmo de cFilAnt, pois a ECF não fornece a opção
de ser gerada para várias filiais, ela é gerada a partir da filial logada que
deve ser a Matriz ou SCP.
A variável cFilSel foi mantida no programa de geração do arquivo por compatibilidade
de funções e para preenchimento do campo FILIAL da tabela TAFECF_XX.

@Author Felipe C. Seolin
@Since 30/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFJ( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"J"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegJ050( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegJ100( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegJ001( aECFInfo, cIndMov )

Recover
	lFound := .F.

End Sequence

//Tratamento para ocorrência de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

	//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
	xTafCTLObr( "2", cBloco, aWizard, cFilSel,, cTABCTL, "ECF" )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegJ001

Rotina para extrair e gravar as informacoes do Registro J001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 30/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegJ001( aECFInfo, cIndMov )

Local cDelimit	:=	"|"
Local cStrTxt		:=	""

cStrTxt := cDelimit + "J001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "J001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegJ050

Rotina para extrair e gravar as informacoes do Registro J050 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 11/08/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegJ050( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit	:=	"|"
Local cStrTxt		:=	""
Local cLoop		:=	""
Local cLoopFilho	:=	""
Local cCodSup		:=	""
Local aCodSup		:=	{}
Local cAliasQry	:=	GetNextAlias()

ECFQryJ( cAliasQry, aWizard, cFilSel, "J050" )

C1O->( DBSetOrder( 3 ) )

//Registro J050
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	If !Empty( ( cAliasQry )->C1O_CODSUP )
		FGeraSup( ( cAliasQry )->C1O_CODSUP, aECFInfo, @nSeq, @aCodSup )
	EndIf

	C1O->( DBGoTo( ( cAliasQry )->C1O_CODSUP ) )
	cCodSup := C1O->C1O_CODIGO

	cStrTxt := cDelimit + "J050"														//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->C1O_DTALT )						//02 - DT_ALT
	cStrTxt += cDelimit + TAFConType(( cAliasQry )->C2R_CODIGO)						//03 - COD_NAT
	cStrTxt += cDelimit + Iif( ( cAliasQry )->C1O_INDCTA == "0", "S", "A" )		//04 - IND_CTA
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1O_NIVEL )					//05 - NÍVEL
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->J050_CODIGO )					//06 - COD_CTA
	//cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1O_CODSUP )				//07 - COD_CTA_SUP
	cStrTxt += cDelimit + TAFConType( cCodSup )										//07 - COD_CTA_SUP
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1O_DESCRI )					//08 - CTA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "J050", cStrTxt )

	nSeq ++

	cLoop := ( cAliasQry )->J050_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->J050_CODIGO == cLoop

		//Registro J051
		If AllTrim( ( cAliasQry )->REGISTRO ) == "J051" .and. !Empty( ( cAliasQry )->J051_CODIGO )

			cLoopFilho := ( cAliasQry )->( J050_CODIGO + REGISTRO )

			While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->( J050_CODIGO + REGISTRO ) == cLoopFilho 

				If !Empty( ( cAliasQry )->J051_CODIGO )

					cStrTxt := cDelimit + "J051"											//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1P_CODCUS )		//02 - COD_CCUS
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->J051_CODIGO )		//03 - COD_CTA_REF
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "J051", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

		//Registro J053
		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "J053" .and. !Empty( ( cAliasQry )->CHH_CODGRU )

			cLoopFilho := ( cAliasQry )->( J050_CODIGO + REGISTRO )

			While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->( J050_CODIGO + REGISTRO ) == cLoopFilho 

				If !Empty( ( cAliasQry )->CHH_CODGRU )

					cStrTxt := cDelimit + "J053"											//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHH_CODGRU )		//02 - COD_IDT
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->J053_CODIGO )		//03 - COD_CNT_CORR
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHI_CODIGO )		//04 - NAT_SUB_CNT
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "J053", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

		Else

			( cAliasQry )->( DBSkip() )
		EndIf

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegJ100

Rotina para extrair e gravar as informacoes do Registro J100.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 11/08/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegJ100( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryJ( cAliasQry, aWizard, cFilSel, "J100" )

//Registro J100
While ( cAliasQry )->( !Eof() )

	if !empty( ( cAliasQry )->C1P_CODCUS )
	
		cIndMov := "0"
	
		cStrTxt := cDelimit + "J100"						   					//01 - REG
		cStrTxt += cDelimit + DT2Caract( ( cAliasQry )->C1P_DTALT )			//02 - DT_ALT
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1P_CODCUS )		//03 - COD_CCUS
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1P_CCUS )			//04 - CCUS
		cStrTxt += cDelimit
	
		FExecSQL( aECFInfo, nSeq, "J100", cStrTxt )
	
		nSeq ++
	
	endif

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FGeraSup

Rotina para gerar Registro J050 das Contas Superiores

@Param	nRecno		->	Número do registro da conta superior
		aECFInfo	->	Informações gerais para tabela de controle de transações
		nSeq		->	Seqüência de gravação do Bloco
		aCtaSup	->	Array com as contas superiores já gravadas

@Author Felipe C. Seolin
@Since 25/03/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGeraSup( nRecno, aECFInfo, nSeq, aCodSup )

Local cDelimit	:=	"|"
Local cStrTxt		:=	""
Local cConta		:=	""
Local nI			:=	0
Local aCtaSup		:=	{}
Local lLoop		:=	.T.

C1O->( DBGoTo( nRecno ) )

While lLoop

	If AllTrim( C1O->C1O_CODIGO ) <> cConta
		aAdd( aCtaSup, { C1O->C1O_NIVEL, C1O->( Recno() ), "" } )

		cConta := AllTrim( C1O->C1O_CODIGO )

		If C1O->( MsSeek( xFilial( "C1O" ) + C1O->C1O_CTASUP ) )
			aCtaSup[Len( aCtaSup ),3] := C1O->C1O_CODIGO
		Else
			lLoop := .F.
		EndIf
	Else
		lLoop := .F.
	EndIf

EndDo

aSort( aCtaSup,,, { |x,y| x[1] < y[1] } )

For nI := 1 to Len( aCtaSup )

	C1O->( DBGoTo( aCtaSup[nI,2] ) )

	If aScan( aCodSup, C1O->C1O_CODIGO ) == 0

		aAdd( aCodSup, C1O->C1O_CODIGO )

		cStrTxt := cDelimit + "J050"																							//01 - REG
		cStrTxt += cDelimit + Dt2Caract( C1O->C1O_DTALT )																	//02 - DT_ALT
		cStrTxt += cDelimit + TAFConType( Posicione( "C2R", 3, xFilial( "C2R" ) + C1O->C1O_CODNAT, "C2R_CODIGO" ) )	//03 - COD_NAT
		cStrTxt += cDelimit + Iif( C1O->C1O_INDCTA == "0", "S", "A" )														//04 - IND_CTA
		cStrTxt += cDelimit + TAFConType( C1O->C1O_NIVEL )																	//05 - NÍVEL
		cStrTxt += cDelimit + TAFConType( C1O->C1O_CODIGO )																	//06 - COD_CTA
		cStrTxt += cDelimit + TAFConType( aCtaSup[nI,3] )																	//07 - COD_CTA_SUP
		cStrTxt += cDelimit + TAFConType( C1O->C1O_DESCRI )																	//08 - CTA
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "J050", cStrTxt )

		nSeq ++

	EndIf

Next nI

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryJ

Executa a Query principal para a extracao do Bloco J do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento
       cReg      -> Indica para qual Registro se refere a Query

@Author Felipe C. Seolin
@Since 11/08/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryJ( cAliasQry, aWizard, cFilSel, cReg )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := cSelect5 := cSelect6 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := ""
Local cOrderBy := ""

/*If cReg == "J050"

	//J051

	cSelect := " 'J051' REGISTRO, C1O.C1O_CODIGO J050_CODIGO, C1O.C1O_DTALT, C2R.C2R_CODIGO, C1O.C1O_INDCTA, C1O.C1O_NIVEL, C1OC1O.C1O_CODIGO C1O_CODSUP, C1O.C1O_DESCRI "
	cSelect += ", CHA.CHA_CODIGO J051_CODIGO, C1P.C1P_CODCUS "
	cSelect += ", '' CHH_CODGRU, '' J053_CODIGO, '' CHI_CODIGO "

	cFrom := RetSqlName( "C1O" ) + " C1O "

	cFrom += "LEFT JOIN " + RetSqlName( "CH5" ) + " CH5 "
	cFrom += "   ON CH5.CH5_FILIAL = C1O.C1O_FILIAL "
	cFrom += "  AND CH5.CH5_ID = C1O.C1O_ID "
	
	If TAFColumnPos( "CH5_ANOCAL" )
		
		cFrom += "  AND ( CH5.CH5_ANOCAL = '" + AllTrim( Str( Year( aWizard[1,2] ) ) ) + "' "
		
		//Para as retificações da entrega em 2014 devo pesquisar também pelo conteúdo deste campo em branco, pois
		//foi criado apenas para a entrega da ECF a partir de 2015.
		If AllTrim( Str( Year( aWizard[1,2] ) ) ) == "2014"
			cFrom += "   OR CH5.CH5_ANOCAL = '' ) "
		Else
			cFrom += " ) "
		Endif
		
	Endif

	cFrom += "  AND CH5.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
	cFrom += "   ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
	cFrom += "  AND CHA.CHA_ID = CH5.CH5_IDCTAR "
	cFrom += "  AND CHA.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom += " AND C2R.C2R_ID = C1O.C1O_CODNAT "
	cFrom += " AND C2R.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom += "  ON C1OC1O.C1O_FILIAL = C1O.C1O_FILIAL "
	cFrom += " AND C1OC1O.C1O_ID = C1O.C1O_CTASUP "
	cFrom += " AND C1OC1O.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom += "  ON C1P.C1P_FILIAL = CH5.CH5_FILIAL "
	cFrom += " AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom += " AND C1P.D_E_L_E_T_ = '' "

	cWhere := " C1O.C1O_FILIAL IN ( '" + xFilial( "C1O" ) + "' ) "
	//cWhere := " C1O.C1O_FILIAL IN ( " + cFilSel + " ) "
	
	If TAFColumnPos( "C1O_DTCRIA" )
		cWhere += "AND C1O.C1O_DTCRIA <= '" + DToS( aWizard[1,2] ) + "' "
	Endif
	
	cWhere += "AND C1O.D_E_L_E_T_ = '' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	//J053

	cSelect2 := " 'J053' REGISTRO, C1O.C1O_CODIGO J050_CODIGO, C1O.C1O_DTALT, C2R.C2R_CODIGO, C1O.C1O_INDCTA, C1O.C1O_NIVEL, C1OC1O.C1O_CODIGO C1O_CODSUP, C1O.C1O_DESCRI "
	cSelect2 += ", '', '' "
	cSelect2 += ", CHH.CHH_CODGRU, C1OCHH.C1O_CODIGO, CHI.CHI_CODIGO "

	cFrom2 := RetSqlName( "C1O" ) + " C1O "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CHH" ) + " CHH "
	cFrom2 += "   ON CHH.CHH_FILIAL = C1O.C1O_FILIAL "
	cFrom2 += "  AND CHH.CHH_ID = C1O.C1O_ID "
	
	If TAFColumnPos( "CHH_ANOCAL" )
		
		cFrom2 += "  AND ( CHH.CHH_ANOCAL = '" + AllTrim( Str( Year( aWizard[1,2] ) ) ) + "' "
		
		//Para as retificações da entrega em 2014 devo pesquisar também pelo conteúdo deste campo em branco, pois
		//foi criado apenas para a entrega da ECF a partir de 2015.
		If AllTrim( Str( Year( aWizard[1,2] ) ) ) == "2014"
			cFrom2 += "   OR CHH.CHH_ANOCAL = '' ) "
		Else
			cFrom2 += " ) "
		EndIf
		
	Endif
	
	cFrom2 += "  AND CHH.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom2 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom2 += " AND C2R.C2R_ID = C1O.C1O_CODNAT "
	cFrom2 += " AND C2R.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom2 += "  ON C1OC1O.C1O_FILIAL = C1O.C1O_FILIAL "
	cFrom2 += " AND C1OC1O.C1O_ID = C1O.C1O_CTASUP "
	cFrom2 += " AND C1OC1O.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OCHH "
	cFrom2 += "  ON C1OCHH.C1O_FILIAL = CHH.CHH_FILIAL "
	cFrom2 += " AND C1OCHH.C1O_ID = CHH.CHH_CNTCOR "
	cFrom2 += " AND C1OCHH.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CHI" ) + " CHI "
	cFrom2 += "  ON CHI.CHI_FILIAL = '" + xFilial( "CHI" ) + "' "
	cFrom2 += " AND CHI.CHI_ID = CHH.CHH_IDNATC "
	cFrom2 += " AND CHI.D_E_L_E_T_ = '' "

	cWhere2 := " C1O.C1O_FILIAL IN ( '" + xFilial( "C1O" ) + "' ) "
	//cWhere2 := " C1O.C1O_FILIAL IN ( " + cFilSel + " ) "
	
	If TAFColumnPos( "C1O_DTCRIA" )
		cWhere2 += "AND C1O.C1O_DTCRIA <= '" + DToS( aWizard[1,2] ) + "' "
	Endif
	
	cWhere2 += "AND C1O.D_E_L_E_T_ = '' "

	cSelect2 := "%" + cSelect2 + "%"
	cFrom2   := "%" + cFrom2   + "%"
	cWhere2  := "%" + cWhere2  + "%"

	//Ordenacao da Query

	cOrderBy := "J050_CODIGO, REGISTRO "

	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAliasQry

			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%

		UNION

			SELECT
				%Exp:cSelect2%
			FROM
				%Exp:cFrom2%
			WHERE
				%Exp:cWhere2%

		ORDER BY
			%Exp:cOrderBy%

	EndSql*/
	
If cReg == "J050"

	//Registros J050 e J051 dos movimentos dos registros K155 e K156

	cSelect := "DISTINCT 'J051' REGISTRO, C1OCAD.C1O_CODIGO J050_CODIGO, C1OCAD.C1O_DTALT, C2R.C2R_CODIGO, C1OCAD.C1O_INDCTA, C1OCAD.C1O_NIVEL, C1OC1O.R_E_C_N_O_ C1O_CODSUP, C1OCAD.C1O_DESCRI "
	cSelect += "       , CHA.CHA_CODIGO J051_CODIGO, C1P.C1P_CODCUS "
	cSelect += "       , '' CHH_CODGRU, '' J053_CODIGO, '' CHI_CODIGO "

	cFrom := RetSqlName( "CAC" ) + " CAC "

	cFrom += "INNER JOIN " + RetSqlName( "CAD" ) + " CAD "
	cFrom += "   ON CAD.CAD_FILIAL = CAC.CAC_FILIAL "
	cFrom += "  AND CAD.CAD_ID = CAC.CAC_ID "
	cFrom += "  AND CAD.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CAE" ) + " CAE "
	cFrom += "  ON CAE.CAE_FILIAL = CAD.CAD_FILIAL "
	cFrom += " AND CAE.CAE_ID = CAD.CAD_ID "
	cFrom += " AND CAE.CAE_CTA = CAD.CAD_CTA "
	cFrom += " AND CAE.CAE_CODCUS = CAD.CAD_CODCUS "
	cFrom += " AND CAE.D_E_L_E_T_ = '' "

	cFrom += "INNER JOIN " + RetSqlName( "C1O" ) + " C1OCAD "
	//cFrom += "   ON C1OCAD.C1O_FILIAL = CAD.CAD_FILIAL "
	cFrom += "   ON C1OCAD.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom += "  AND C1OCAD.C1O_ID = CAD.CAD_CTA "
	cFrom += "  AND C1OCAD.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CH5" ) + " CH5 "
	//cFrom += "   ON CH5.CH5_FILIAL = CAE.CAE_FILIAL "
	cFrom += "   ON CH5.CH5_FILIAL = '" + xFilial('CH5') + "' "
	cFrom += "  AND CH5.CH5_ID = CAE.CAE_CTA "
	cFrom += "  AND CH5.CH5_IDCTAR = CAE.CAE_IDCTAR "
	cFrom += "  AND CH5.CH5_CODCUS = CAE.CAE_CODCUS "
	cFrom += "  AND CH5.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
	cFrom += "   ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
	cFrom += "  AND CHA.CHA_ID = CH5.CH5_IDCTAR "
	cFrom += "  AND CHA.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom += " AND C2R.C2R_ID = C1OCAD.C1O_CODNAT "
	cFrom += " AND C2R.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom += "  ON C1OC1O.C1O_FILIAL = C1OCAD.C1O_FILIAL "
	cFrom += " AND C1OC1O.C1O_ID = C1OCAD.C1O_CTASUP "
	cFrom += " AND C1OC1O.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	//cFrom += "  ON C1P.C1P_FILIAL = CH5.CH5_FILIAL "
	cFrom += "  ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom += " AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom += " AND C1P.D_E_L_E_T_ = '' "

	//cWhere := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CAC.D_E_L_E_T_ = '' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	//Registros J050 e J053 dos movimentos dos registros K155 e K156

	cSelect2 := "DISTINCT 'J053' REGISTRO, C1OCAD.C1O_CODIGO J050_CODIGO, C1OCAD.C1O_DTALT, '', '', '', 0, '' "
	cSelect2 += "       , '', '' "
	cSelect2 += "       , CHH.CHH_CODGRU, C1OCHH.C1O_CODIGO, CHI.CHI_CODIGO "

	cFrom2 := RetSqlName( "CAC" ) + " CAC "

	cFrom2 += "INNER JOIN " + RetSqlName( "CAD" ) + " CAD "
	cFrom2 += "   ON CAD.CAD_FILIAL = CAC.CAC_FILIAL "
	cFrom2 += "  AND CAD.CAD_ID = CAC.CAC_ID "
	cFrom2 += "  AND CAD.D_E_L_E_T_ = '' "

	cFrom2 += "INNER JOIN " + RetSqlName( "C1O" ) + " C1OCAD "
	cFrom2 += "   ON C1OCAD.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom2 += "  AND C1OCAD.C1O_ID = CAD.CAD_CTA "
	cFrom2 += "  AND C1OCAD.D_E_L_E_T_ = '' "

	cFrom2 += "INNER JOIN " + RetSqlName( "CHH" ) + " CHH "
	cFrom2 += "   ON CHH.CHH_FILIAL = '" + xFilial('CHH') + "' "
	cFrom2 += "  AND CHH.CHH_ID = C1OCAD.C1O_ID "
	cFrom2 += "  AND CHH.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OCHH "
	cFrom2 += "  ON C1OCHH.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom2 += " AND C1OCHH.C1O_ID = CHH.CHH_CNTCOR "
	cFrom2 += " AND C1OCHH.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CHI" ) + " CHI "
	cFrom2 += "   ON CHI.CHI_FILIAL = '" + xFilial( "CHI" ) + "' "
	cFrom2 += "  AND CHI.CHI_ID = CHH.CHH_IDNATC "
	cFrom2 += "  AND CHI.D_E_L_E_T_ = '' "

	//cWhere2 := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere2 := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere2 += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere2 += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere2 += "AND CAC.D_E_L_E_T_ = '' "

	cSelect2 := "%" + cSelect2 + "%"
	cFrom2   := "%" + cFrom2   + "%"
	cWhere2  := "%" + cWhere2  + "%"

	//Registros J050 e J051 dos movimentos dos registros K355 e K356

	cSelect3 := "DISTINCT 'J051' REGISTRO, C1OCAF.C1O_CODIGO J050_CODIGO, C1OCAF.C1O_DTALT, C2R.C2R_CODIGO, C1OCAF.C1O_INDCTA, C1OCAF.C1O_NIVEL, C1OC1O.R_E_C_N_O_, C1OCAF.C1O_DESCRI "
	cSelect3 += "       , CHA.CHA_CODIGO, C1P.C1P_CODCUS "
	cSelect3 += "       , '', '', '' "

	cFrom3 := RetSqlName( "CAC" ) + " CAC "

	cFrom3 += "INNER JOIN " + RetSqlName( "CAF" ) + " CAF "
	cFrom3 += "   ON CAF.CAF_FILIAL = CAC.CAC_FILIAL "
	cFrom3 += "  AND CAF.CAF_ID = CAC.CAC_ID "
	cFrom3 += "  AND CAF.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CAG" ) + " CAG "
	cFrom3 += "  ON CAG.CAG_FILIAL = CAF.CAF_FILIAL "
	cFrom3 += " AND CAG.CAG_ID = CAF.CAF_ID "
	cFrom3 += " AND CAG.CAG_CTA = CAF.CAF_CTA "
	cFrom3 += " AND CAG.CAG_CODCUS = CAF.CAF_CODCUS "
	cFrom3 += " AND CAG.D_E_L_E_T_ = '' "

	cFrom3 += "INNER JOIN " + RetSqlName( "C1O" ) + " C1OCAF "
	cFrom3 += "   ON C1OCAF.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom3 += "  AND C1OCAF.C1O_ID = CAF.CAF_CTA "
	cFrom3 += "  AND C1OCAF.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CH5" ) + " CH5 "
	cFrom3 += "    ON CH5.CH5_FILIAL = '" + xFilial('CH5') + "' "
	cFrom3 += "   AND CH5.CH5_ID = CAG.CAG_CTA "
	cFrom3 += "   AND CH5.CH5_IDCTAR = CAG.CAG_IDCTAR "
	cFrom3 += "   AND CH5.CH5_CODCUS = CAG.CAG_CODCUS "
	cFrom3 += "   AND CH5.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
	cFrom3 += "   ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
	cFrom3 += "  AND CHA.CHA_ID = CH5.CH5_IDCTAR "
	cFrom3 += "  AND CHA.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom3 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom3 += " AND C2R.C2R_ID = C1OCAF.C1O_CODNAT "
	cFrom3 += " AND C2R.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom3 += "  ON C1OC1O.C1O_FILIAL = C1OCAF.C1O_FILIAL "
	cFrom3 += " AND C1OC1O.C1O_ID = C1OCAF.C1O_CTASUP "
	cFrom3 += " AND C1OC1O.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom3 += "  ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom3 += " AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom3 += " AND C1P.D_E_L_E_T_ = '' "

	//cWhere3 := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere3 := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere3 += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere3 += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere3 += "AND CAC.D_E_L_E_T_ = '' "

	cSelect3 := "%" + cSelect3 + "%"
	cFrom3   := "%" + cFrom3   + "%"
	cWhere3  := "%" + cWhere3  + "%"

	//Registros J050 e J053 dos movimentos dos registros K355 e K356

	cSelect4 := "DISTINCT 'J053' REGISTRO, C1OCAF.C1O_CODIGO J050_CODIGO, C1OCAF.C1O_DTALT, '', '', '', 0, '' "
	cSelect4 += "       , '', '' "
	cSelect4 += "       , CHH.CHH_CODGRU, C1OCHH.C1O_CODIGO, CHI.CHI_CODIGO "

	cFrom4 := RetSqlName( "CAC" ) + " CAC "

	cFrom4 += "INNER JOIN " + RetSqlName( "CAF" ) + " CAF "
	cFrom4 += "   ON CAF.CAF_FILIAL = CAC.CAC_FILIAL "
	cFrom4 += "  AND CAF.CAF_ID = CAC.CAC_ID "
	cFrom4 += "  AND CAF.D_E_L_E_T_ = '' "

	cFrom4 += "INNER JOIN " + RetSqlName( "C1O" ) + " C1OCAF "
	cFrom4 += "   ON C1OCAF.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom4 += "  AND C1OCAF.C1O_ID = CAF.CAF_CTA "
	cFrom4 += "  AND C1OCAF.D_E_L_E_T_ = '' "

	cFrom4 += "INNER JOIN " + RetSqlName( "CHH" ) + " CHH "
	cFrom4 += "   ON CHH.CHH_FILIAL = '" + xFilial('CHH') + "' "
	cFrom4 += "  AND CHH.CHH_ID = C1OCAF.C1O_ID "
	cFrom4 += "  AND CHH.D_E_L_E_T_ = '' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OCHH "
	cFrom4 += "  ON C1OCHH.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom4 += " AND C1OCHH.C1O_ID = CHH.CHH_CNTCOR "
	cFrom4 += " AND C1OCHH.D_E_L_E_T_ = '' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CHI" ) + " CHI "
	cFrom4 += "   ON CHI.CHI_FILIAL = '" + xFilial( "CHI" ) + "' "
	cFrom4 += "  AND CHI.CHI_ID = CHH.CHH_IDNATC "
	cFrom4 += "  AND CHI.D_E_L_E_T_ = '' "

	//cWhere4 := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere4 := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere4 += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere4 += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere4 += "AND CAC.D_E_L_E_T_ = '' "

	cSelect4 := "%" + cSelect4 + "%"
	cFrom4   := "%" + cFrom4   + "%"
	cWhere4  := "%" + cWhere4  + "%"

	//Registros J050 e J051 dos movimentos dos registros M310

	cSelect5 := "DISTINCT 'J051' REGISTRO, C1O.C1O_CODIGO J050_CODIGO, C1O.C1O_DTALT, C2R.C2R_CODIGO, C1O.C1O_INDCTA, C1O.C1O_NIVEL, C1OC1O.R_E_C_N_O_, C1O.C1O_DESCRI "
	cSelect5 += "       , '', '' "
	cSelect5 += "       , '', '', '' "

	cFrom5 := RetSqlName( "CEN" ) + " CEN "

	cFrom5 += "INNER JOIN " + RetSqlName( "CEO" ) + " CEO "
	cFrom5 += "   ON CEO.CEO_FILIAL = CEN.CEN_FILIAL "
	cFrom5 += "  AND CEO.CEO_ID = CEN.CEN_ID "
	cFrom5 += "  AND CEO.D_E_L_E_T_ = '' "

	cFrom5 += "INNER JOIN " + RetSqlName( "CEQ" ) + " CEQ "
	cFrom5 += "   ON CEQ.CEQ_FILIAL = CEO.CEO_FILIAL "
	cFrom5 += "  AND CEQ.CEQ_ID = CEO.CEO_ID "
	cFrom5 += "  AND CEQ.CEQ_IDCODL = CEO.CEO_IDCODL "
	cFrom5 += "  AND CEQ.D_E_L_E_T_ = '' "

	cFrom5 += "INNER JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom5 += "   ON C1O.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom5 += "  AND C1O.C1O_ID = CEQ.CEQ_CTA "
	cFrom5 += "  AND C1O.D_E_L_E_T_ = '' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom5 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom5 += " AND C2R.C2R_ID = C1O.C1O_CODNAT "
	cFrom5 += " AND C2R.D_E_L_E_T_ = '' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom5 += "  ON C1OC1O.C1O_FILIAL = C1O.C1O_FILIAL "
	cFrom5 += " AND C1OC1O.C1O_ID = C1O.C1O_CTASUP "
	cFrom5 += " AND C1OC1O.D_E_L_E_T_ = '' "

	//cWhere5 := "    CEN.CEN_FILIAL IN (" + cFilSel + ") "
	cWhere5 := "    CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere5 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere5 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere5 += "AND CEN.D_E_L_E_T_ = '' "

	cSelect5 := "%" + cSelect5 + "%"
	cFrom5   := "%" + cFrom5   + "%"
	cWhere5  := "%" + cWhere5  + "%"

	//Registros J050 e J051 dos movimentos dos registros M360

	cSelect6 := "DISTINCT 'J051' REGISTRO, C1O.C1O_CODIGO J050_CODIGO, C1O.C1O_DTALT, C2R.C2R_CODIGO, C1O.C1O_INDCTA, C1O.C1O_NIVEL, C1OC1O.R_E_C_N_O_, C1O.C1O_DESCRI "
	cSelect6 += "       , '', '' "
	cSelect6 += "       , '', '', '' "

	cFrom6 := RetSqlName( "CEN" ) + " CEN "

	cFrom6 += "INNER JOIN " + RetSqlName( "CHR" ) + " CHR "
	cFrom6 += "   ON CHR.CHR_FILIAL = CEN.CEN_FILIAL "
	cFrom6 += "  AND CHR.CHR_ID = CEN.CEN_ID "
	cFrom6 += "  AND CHR.D_E_L_E_T_ = '' "

	cFrom6 += "INNER JOIN " + RetSqlName( "CHT" ) + " CHT "
	cFrom6 += "   ON CHT.CHT_FILIAL = CHR.CHR_FILIAL "
	cFrom6 += "  AND CHT.CHT_ID = CHR.CHR_ID "
	cFrom6 += "  AND CHT.CHT_IDCODL = CHR.CHR_IDCODL "
	cFrom6 += "  AND CHT.D_E_L_E_T_ = '' "

	cFrom6 += "INNER JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom6 += "   ON C1O.C1O_FILIAL = '" + xFilial('C1O') + "' "
	cFrom6 += "  AND C1O.C1O_ID = CHT.CHT_CTA "
	cFrom6 += "  AND C1O.D_E_L_E_T_ = '' "

	cFrom6 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
	cFrom6 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
	cFrom6 += " AND C2R.C2R_ID = C1O.C1O_CODNAT "
	cFrom6 += " AND C2R.D_E_L_E_T_ = '' "

	cFrom6 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1OC1O "
	cFrom6 += "  ON C1OC1O.C1O_FILIAL = C1O.C1O_FILIAL "
	cFrom6 += " AND C1OC1O.C1O_ID = C1O.C1O_CTASUP "
	cFrom6 += " AND C1OC1O.D_E_L_E_T_ = '' "

	//cWhere6 := "    CEN.CEN_FILIAL IN (" + cFilSel + ") "
	cWhere6 := "    CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere6 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere6 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere6 += "AND CEN.D_E_L_E_T_ = '' "

	cSelect6 := "%" + cSelect6 + "%"
	cFrom6   := "%" + cFrom6   + "%"
	cWhere6  := "%" + cWhere6  + "%"

	//Ordenacao da Query

	cOrderBy := "J050_CODIGO, REGISTRO "

	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAliasQry

			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%

		UNION

			SELECT
				%Exp:cSelect2%
			FROM
				%Exp:cFrom2%
			WHERE
				%Exp:cWhere2%

		UNION

			SELECT
				%Exp:cSelect3%
			FROM
				%Exp:cFrom3%
			WHERE
				%Exp:cWhere3%

		UNION

			SELECT
				%Exp:cSelect4%
			FROM
				%Exp:cFrom4%
			WHERE
				%Exp:cWhere4%

		UNION

			SELECT
				%Exp:cSelect5%
			FROM
				%Exp:cFrom5%
			WHERE
				%Exp:cWhere5%

		UNION

			SELECT
				%Exp:cSelect6%
			FROM
				%Exp:cFrom6%
			WHERE
				%Exp:cWhere6%

		ORDER BY
			%Exp:cOrderBy%

	EndSql



ElseIf cReg == "J100"

	cSelect := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom := RetSqlName( "C1P" ) + " C1P "

	cWhere := " C1P.C1P_FILIAL IN ( '" + xFilial( "C1P" ) + "' ) "
	//cWhere := " C1P.C1P_FILIAL IN ( " + cFilSel + " ) "
	
	If TAFColumnPos( "C1P_DTCRIA" )
		cWhere += "AND C1P.C1P_DTCRIA <= '" + DToS( aWizard[1,2] ) + "' "
	Endif
	
	cWhere += "AND C1P.D_E_L_E_T_ = '' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	
	//Registros J100 dos movimentos do registro J051 ( K156 )

	cSelect := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom := RetSqlName( "CAC" ) + " CAC "

	cFrom += "INNER JOIN " + RetSqlName( "CAD" ) + " CAD "
	cFrom += "   ON CAD.CAD_FILIAL = CAC.CAC_FILIAL "
	cFrom += "  AND CAD.CAD_ID = CAC.CAC_ID "
	cFrom += "  AND CAD.D_E_L_E_T_ = '' "

	cFrom += "INNER JOIN " + RetSqlName( "CAE" ) + " CAE "
	cFrom += "   ON CAE.CAE_FILIAL = CAD.CAD_FILIAL "
	cFrom += "  AND CAE.CAE_ID = CAD.CAD_ID "
	cFrom += "  AND CAE.CAE_CTA = CAD.CAD_CTA "
	cFrom += "  AND CAE.CAE_CODCUS = CAD.CAD_CODCUS "
	cFrom += "  AND CAE.D_E_L_E_T_ = '' "

	cFrom += "INNER JOIN " + RetSqlName( "CH5" ) + " CH5 "
	cFrom += "   ON CH5.CH5_FILIAL = '" + xFilial('CH5') + "' "
	cFrom += "  AND CH5.CH5_ID = CAE.CAE_CTA "
	cFrom += "  AND CH5.CH5_IDCTAR = CAE.CAE_IDCTAR "
	cFrom += "  AND CH5.CH5_CODCUS = CAE.CAE_CODCUS "
	cFrom += "  AND CH5.D_E_L_E_T_ = '' "

	cFrom += "INNER JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom += "   ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom += "  AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom += "  AND C1P.D_E_L_E_T_ = '' "

	//cWhere := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CAC.D_E_L_E_T_ = '' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	//Registros J100 dos movimentos do registro J051 ( K356 )

	cSelect2 := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom2 := RetSqlName( "CAC" ) + " CAC "

	cFrom2 += "INNER JOIN " + RetSqlName( "CAF" ) + " CAF "
	cFrom2 += "  ON CAF.CAF_FILIAL = CAC.CAC_FILIAL "
	cFrom2 += " AND CAF.CAF_ID = CAC.CAC_ID "
	cFrom2 += " AND CAF.D_E_L_E_T_ = '' "

	cFrom2 += "INNER JOIN " + RetSqlName( "CAG" ) + " CAG "
	cFrom2 += "  ON CAG.CAG_FILIAL = CAF.CAF_FILIAL "
	cFrom2 += " AND CAG.CAG_ID = CAF.CAF_ID "
	cFrom2 += " AND CAG.CAG_CTA = CAF.CAF_CTA "
	cFrom2 += " AND CAG.CAG_CODCUS = CAF.CAF_CODCUS "
	cFrom2 += " AND CAG.D_E_L_E_T_ = '' "

	cFrom2 += "INNER JOIN " + RetSqlName( "CH5" ) + " CH5 "
	cFrom2 += "   ON CH5.CH5_FILIAL = '" + xFilial('CH5') + "' "
	cFrom2 += "  AND CH5.CH5_ID = CAG.CAG_CTA "
	cFrom2 += "  AND CH5.CH5_IDCTAR = CAG.CAG_IDCTAR "
	cFrom2 += "  AND CH5.CH5_CODCUS = CAG.CAG_CODCUS "
	cFrom2 += "  AND CH5.D_E_L_E_T_ = '' "

	cFrom2 += "INNER JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom2 += "   ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom2 += "  AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom2 += "  AND C1P.D_E_L_E_T_ = '' "

	//cWhere2 := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
	cWhere2 := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
	cWhere2 += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere2 += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere2 += "AND CAC.D_E_L_E_T_ = '' "

	cSelect2 := "%" + cSelect2 + "%"
	cFrom2   := "%" + cFrom2   + "%"
	cWhere2  := "%" + cWhere2  + "%"

	//Registros J100 dos movimentos dos registros M310

	cSelect3 := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom3 := RetSqlName( "CEN" ) + " CEN "

	cFrom3 += "INNER JOIN " + RetSqlName( "CEO" ) + " CEO "
	cFrom3 += "   ON CEO.CEO_FILIAL = CEN.CEN_FILIAL "
	cFrom3 += "  AND CEO.CEO_ID = CEN.CEN_ID "
	cFrom3 += "  AND CEO.D_E_L_E_T_ = '' "

	cFrom3 += "INNER JOIN " + RetSqlName( "CEQ" ) + " CEQ "
	cFrom3 += "   ON CEQ.CEQ_FILIAL = CEO.CEO_FILIAL "
	cFrom3 += "  AND CEQ.CEQ_ID = CEO.CEO_ID "
	cFrom3 += "  AND CEQ.CEQ_IDCODL = CEO.CEO_IDCODL "
	cFrom3 += "  AND CEQ.D_E_L_E_T_ = '' "

	cFrom3 += "INNER JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom3 += "   ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom3 += "  AND C1P.C1P_ID = CEQ.CEQ_CODCUS "
	cFrom3 += "  AND C1P.D_E_L_E_T_ = '' "

	//cWhere3 := "    CEN.CEN_FILIAL IN (" + cFilSel + ") "
	cWhere3 := "    CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere3 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere3 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere3 += "AND CEN.D_E_L_E_T_ = '' "

	cSelect3 := "%" + cSelect3 + "%"
	cFrom3   := "%" + cFrom3   + "%"
	cWhere3  := "%" + cWhere3  + "%"

	//Registros J100 dos movimentos dos registros M360

	cSelect4 := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom4 := RetSqlName( "CEN" ) + " CEN "

	cFrom4 += "INNER JOIN " + RetSqlName( "CHR" ) + " CHR "
	cFrom4 += "   ON CHR.CHR_FILIAL = CEN.CEN_FILIAL "
	cFrom4 += "  AND CHR.CHR_ID = CEN.CEN_ID "
	cFrom4 += "  AND CHR.D_E_L_E_T_ = '' "

	cFrom4 += "INNER JOIN " + RetSqlName( "CHT" ) + " CHT "
	cFrom4 += "   ON CHT.CHT_FILIAL = CHR.CHR_FILIAL "
	cFrom4 += "  AND CHT.CHT_ID = CHR.CHR_ID "
	cFrom4 += "  AND CHT.CHT_IDCODL = CHR.CHR_IDCODL "
	cFrom4 += "  AND CHT.D_E_L_E_T_ = '' "

	cFrom4 += "INNER JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom4 += "   ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom4 += "  AND C1P.C1P_ID = CHT.CHT_CODCUS "
	cFrom4 += "  AND C1P.D_E_L_E_T_ = '' "

	//cWhere4 := "    CEN.CEN_FILIAL IN (" + cFilSel + ") "
	cWhere4 := "    CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere4 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere4 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere4 += "AND CEN.D_E_L_E_T_ = '' "

	cSelect4 := "%" + cSelect4 + "%"
	cFrom4   := "%" + cFrom4   + "%"
	cWhere4  := "%" + cWhere4  + "%"
	
	cSelect5 := "DISTINCT C1P.C1P_CODCUS, C1P.C1P_DTALT, C1P.C1P_CCUS "

	cFrom5 := RetSqlName( "C1O" ) + " C1O "
	cFrom5 += "LEFT JOIN " + RetSqlName( "CH5" ) + " CH5 "
	cFrom5 += "   ON CH5.CH5_FILIAL = '" + xFilial('CH5') + "' "
	cFrom5 += "  AND CH5.CH5_ID = C1O.C1O_ID "
	cFrom5 += "  AND CH5.D_E_L_E_T_ = '' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom5 += "  ON C1P.C1P_FILIAL = '" + xFilial('C1P') + "' "
	cFrom5 += " AND C1P.C1P_ID = CH5.CH5_CODCUS "
	cFrom5 += " AND C1P.D_E_L_E_T_ = '' "

	//cWhere5 := "    C1O.C1O_FILIAL IN ( " + cFilSel + " ) "
	cWhere5 := "    C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cWhere5 += "AND C1O.D_E_L_E_T_ = '' "
	

	cSelect5 := "%" + cSelect5 + "%"
	cFrom5   := "%" + cFrom5   + "%"
	cWhere5  := "%" + cWhere5  + "%"

	//Ordenacao da Query

	cOrderBy := "C1P_CODCUS "

	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAliasQry

			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%

		UNION

			SELECT
				%Exp:cSelect2%
			FROM
				%Exp:cFrom2%
			WHERE
				%Exp:cWhere2%

		UNION

			SELECT
				%Exp:cSelect3%
			FROM
				%Exp:cFrom3%
			WHERE
				%Exp:cWhere3%

		UNION

			SELECT
				%Exp:cSelect4%
			FROM
				%Exp:cFrom4%
			WHERE
				%Exp:cWhere4%
				
		UNION

			SELECT
				%Exp:cSelect5%
			FROM
				%Exp:cFrom5%
			WHERE
				%Exp:cWhere5%

		ORDER BY
			%Exp:cOrderBy%


	EndSql

EndIf

Return()
