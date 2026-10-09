#Include "Protheus.ch" 

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFU

Rotina extratora da informacoes para o Bloco U do ECF.

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
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFU( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"U"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegU030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegU001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegU001

Rotina para extrair e gravar as informacoes do Registro U001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegU001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "U001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "U001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegU030

Rotina para extrair e gravar as informacoes do Registro U030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegU030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()

ECFQryU( cAliasQry, aWizard, cFilSel )

//Registro U030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "U030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEY_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEY_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "U030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CEY_DTINI + ( cAliasQry )->CEY_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEY_DTINI + ( cAliasQry )->CEY_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro U100
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "U100"

			If !Empty( ( cAliasQry )->U100_CODIGO )

				cStrTxt := cDelimit + "U100"																					 						//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U100_CODIGO )								 										//02 - CODIGO
				cStrTxt += cDelimit + AllTrim( ( cAliasQry )->U100_DESCRI )								 										//03 - DESCRICAO
				cStrTxt += cDelimit + Iif( ( cAliasQry )->U100_TPCTA == "0", "S", "A" )							 								//04 - TIPO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U100_NIVEL )										 								//05 - NIVEL
				cStrTxt += cDelimit + TAFConType(( cAliasQry )->U100_C2R_CODIGO)									 								//06 - COD_NAT
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U100_CHA_CODIGO )							 										//07 - COD_CTA_SUP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEZ_SALINI, 16, 2 )									 								//08 - VAL_CTA_REF_INI
				cStrTxt += cDelimit + Iif( Empty( ( cAliasQry )->CEZ_INDINI ), "", Iif( ( cAliasQry )->CEZ_INDINI == "1", "D", "C" ) )		//09 - IND_VAL_CTA_REF_INI

				if aWizard[1,5] >= "0005" .and. TafColumnPos( "CEZ_VLRTD" ) // Campos Layout versão 5 do ECF
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEZ_VLRTD, 16, 2 )       // 10 - VAL_CTA_REF_DEB
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEZ_VLRTC, 16, 2 )       // 11 - VAL_CTA_REF_CRED
				EndIf

				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEZ_SALFIN, 16, 2 )										 							//10 - VAL_CTA_REF_FIN
				cStrTxt += cDelimit + Iif( Empty( ( cAliasQry )->CEZ_INDFIN ), "", Iif( ( cAliasQry )->CEZ_INDFIN == "1", "D", "C" ) )		//11 - IND_VAL_CTA_REF_FIN
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "U100", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro U150
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "U150"

			If !Empty( ( cAliasQry )->U150_CODIGO )

				cStrTxt := cDelimit + "U150"																					 						//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U150_CODIGO )																		//02 - CODIGO
				cStrTxt += cDelimit + AllTrim( ( cAliasQry )->U150_DESCRI )																		//03 - DESCRICAO
				cStrTxt += cDelimit + Iif( ( cAliasQry )->U150_TPCTA == "0", "S", "A" )															//04 - TIPO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U150_NIVEL )																		//05 - NIVEL
				cStrTxt += cDelimit + TAFConType(( cAliasQry )->U150_C2R_CODIGO)																	//06 - COD_NAT
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U150_CHA_CODIGO )																	//07 - COD_CTA_SUP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHG_VALOR, 16, 2 )																	//08 - VALOR
				cStrTxt += cDelimit + Iif( Empty( ( cAliasQry )->CHG_INDVAL ), "", Iif( ( cAliasQry )->CHG_INDVAL == "1", "C", "D" ) )		//09 - IND_VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "U150", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro U180
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "U180"

			If !Empty( ( cAliasQry )->U180_CODIGO )

				cStrTxt := cDelimit + "U180"												//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U180_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + AllTrim( ( cAliasQry )->U180_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->U180_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "U180", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro U182
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "U182"

			If !Empty( ( cAliasQry )->U182_CODIGO )

				cStrTxt := cDelimit + "U182"								 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->U182_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + AllTrim( ( cAliasQry )->U182_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->U182_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "U182", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryU

Executa a Query principal para a extracao do Bloco U do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryU( cAliasQry, aWizard, cFilSel )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := ""
Local cOrderBy := ""
Local lVs5ECF  := IIf( aWizard[1,5] >= "0005" .and. TafColumnPos( "CEZ_VLRTD" ), .T., .F. )

//Registro U100

cSelect := "  'U100' REGISTRO, CEY.CEY_FILIAL, CEY.CEY_DTINI, CEY.CEY_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CHA.CHA_CODIGO U100_CODIGO, CHA.CHA_DESCRI U100_DESCRI, CHA.CHA_TPCTA U100_TPCTA, CHA.CHA_NIVEL U100_NIVEL, C2R.C2R_CODIGO U100_C2R_CODIGO, CHACHA.CHA_CODIGO U100_CHA_CODIGO, CEZ.CEZ_SALINI, CEZ.CEZ_INDINI, CEZ.CEZ_SALFIN, CEZ.CEZ_INDFIN "

if lVs5ECF // Campos Layout versão 5 do ECF
	cSelect += ", CEZ.CEZ_VLRTD, CEZ.CEZ_VLRTC "
Endif

cSelect += ", '' U150_CODIGO, '' U150_DESCRI, '' U150_TPCTA, '' U150_NIVEL, '' U150_C2R_CODIGO, '' U150_CHA_CODIGO, 0 CHG_VALOR, '' CHG_INDVAL "
cSelect += ", '' U180_CODIGO, '' U180_DESCRI, 0 U180_VALOR "
cSelect += ", '' U182_CODIGO, '' U182_DESCRI, 0 U182_VALOR "

cFrom := RetSqlName( "CEY" ) + " CEY "

cFrom += "LEFT JOIN " + RetSqlName( "CEZ" ) + " CEZ "
cFrom += "  ON CEZ.CEZ_FILIAL = CEY.CEY_FILIAL "
cFrom += " AND CEZ.CEZ_ID = CEY.CEY_ID "
cFrom += " AND CEZ.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CEY.CEY_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHA.CHA_ID = CEZ.CEZ_IDCODC "
cFrom += " AND CHA.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom += " AND C2R.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere := "    CEY.CEY_FILIAL IN (" + cFilSel + ") "
cWhere := " CEY.CEY_FILIAL = '" + xFilial( "CEY" ) + "' "
cWhere += "AND CEY.CEY_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CEY.CEY_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CEY.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registro U150

cSelect2 := "  'U150' REGISTRO, CEY.CEY_FILIAL, CEY.CEY_DTINI, CEY.CEY_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lVs5ECF
	cSelect2 += ", 0, 0 "
EndIf

cSelect2 += ", CHA.CHA_CODIGO, CHA.CHA_DESCRI, CHA.CHA_TPCTA, CHA.CHA_NIVEL, C2R.C2R_CODIGO, CHACHA.CHA_CODIGO, CHG.CHG_VALOR, CHG.CHG_INDVAL "

cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "

cFrom2 := RetSqlName( "CEY" ) + " CEY "

cFrom2 += "LEFT JOIN " + RetSqlName( "CHG" ) + " CHG "
cFrom2 += "  ON CHG.CHG_FILIAL = CEY.CEY_FILIAL "
cFrom2 += " AND CHG.CHG_ID = CEY.CEY_ID "
cFrom2 += " AND CHG.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CEY.CEY_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom2 += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom2 += " AND CHA.CHA_ID = CHG.CHG_IDCODC "
cFrom2 += " AND CHA.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom2 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom2 += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom2 += " AND C2R.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom2 += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom2 += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom2 += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere2 := "    CEY.CEY_FILIAL IN (" + cFilSel + ") "
cWhere2 := " CEY.CEY_FILIAL = '" + xFilial( "CEY" ) + "' "
cWhere2 += "AND CEY.CEY_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CEY.CEY_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CEY.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Registro U180

cSelect3 := "  'U180' REGISTRO, CEY.CEY_FILIAL, CEY.CEY_DTINI, CEY.CEY_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lVs5ECF
	cSelect3 += ", 0, 0 "
EndIf

cSelect3 += ", '', '', '', '', '', '', 0, '' "
cSelect3 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CFI.CFI_VALOR "
cSelect3 += ", '', '', 0 "

cFrom3 := RetSqlName( "CEY" ) + " CEY "

cFrom3 += "LEFT JOIN " + RetSqlName( "CFI" ) + " CFI "
cFrom3 += "  ON CFI.CFI_FILIAL = CEY.CEY_FILIAL "
cFrom3 += " AND CFI.CFI_ID = CEY.CEY_ID "
cFrom3 += " AND CFI.CFI_REGECF = '01' "
cFrom3 += " AND CFI.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom3 += " AND CAH.CAH_ID = CEY.CEY_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom3 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom3 += " AND CH6.CH6_ID = CFI.CFI_IDCODC "
cFrom3 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere3 := "    CEY.CEY_FILIAL IN (" + cFilSel + ") "
cWhere3 := " CEY.CEY_FILIAL = '" + xFilial( "CEY" ) + "' "
cWhere3 += "AND CEY.CEY_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere3 += "AND CEY.CEY_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere3 += "AND CEY.D_E_L_E_T_ = '' "

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

//Registro U182

cSelect4 := "  'U182' REGISTRO, CEY.CEY_FILIAL, CEY.CEY_DTINI, CEY.CEY_DTFIN, CAH.CAH_CODIGO "
cSelect4 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lVs5ECF
	cSelect4 += ", 0, 0 "
EndIf

cSelect4 += ", '', '', '', '', '', '', 0, '' "
cSelect4 += ", '', '', 0 "
cSelect4 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CFI.CFI_VALOR "

cFrom4 := RetSqlName( "CEY" ) + " CEY "

cFrom4 += "LEFT JOIN " + RetSqlName( "CFI" ) + " CFI "
cFrom4 += "  ON CFI.CFI_FILIAL = CEY.CEY_FILIAL "
cFrom4 += " AND CFI.CFI_ID = CEY.CEY_ID "
cFrom4 += " AND CFI.CFI_REGECF = '02' "
cFrom4 += " AND CFI.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom4 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom4 += " AND CAH.CAH_ID = CEY.CEY_IDPERA "
cFrom4 += " AND CAH.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom4 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom4 += " AND CH6.CH6_ID = CFI.CFI_IDCODC "
cFrom4 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere4 := "    CEY.CEY_FILIAL IN (" + cFilSel + ") "
cWhere4 := " CEY.CEY_FILIAL = '" + xFilial( "CEY" ) + "' "
cWhere4 += "AND CEY.CEY_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere4 += "AND CEY.CEY_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere4 += "AND CEY.D_E_L_E_T_ = '' "

cSelect4 := "%" + cSelect4 + "%"
cFrom4   := "%" + cFrom4   + "%"
cWhere4  := "%" + cWhere4  + "%"

//Ordenacao da Query

cOrderBy := "CEY_FILIAL, CAH_CODIGO, REGISTRO "

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

	ORDER BY
		%Exp:cOrderBy%

EndSql

Return()
