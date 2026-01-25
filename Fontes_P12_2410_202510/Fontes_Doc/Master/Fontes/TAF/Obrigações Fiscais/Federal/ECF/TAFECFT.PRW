#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFT

Rotina extratora da informacoes para o Bloco T do ECF.

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
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFT( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| Conout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ),3,.T.,"ECF" } )
Local cBloco		:=	"T"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegT030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegT001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegT001

Rotina para extrair e gravar as informacoes do Registro T001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegT001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "T001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "T001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegT030

Rotina para extrair e gravar as informacoes do Registro T030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegT030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()

ECFQryT( cAliasQry, aWizard, cFilSel )

//Registro T030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "T030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEJ_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEJ_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "T030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CEJ_DTINI + ( cAliasQry )->CEJ_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEJ_DTINI + ( cAliasQry )->CEJ_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro T120
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "T120"

			If !Empty( ( cAliasQry )->T120_CH6_CODIGO )

				cStrTxt := cDelimit + "T120"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T120_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T120_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T120_CEK_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "T120", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro T150
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "T150"

			If !Empty( ( cAliasQry )->T150_CH6_CODIGO )

				cStrTxt := cDelimit + "T150"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T150_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T150_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T150_CEK_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "T150", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro T170
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "T170"

			If !Empty( ( cAliasQry )->T170_CH6_CODIGO )

				cStrTxt := cDelimit + "T170"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T170_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T170_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T170_CEK_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "T170", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro T181
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "T181"

			If !Empty( ( cAliasQry )->T181_CH6_CODIGO )

				cStrTxt := cDelimit + "T181"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T181_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T181_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T181_CEK_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "T181", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryT

Executa a Query principal para a extracao do Bloco T do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryT( cAliasQry, aWizard, cFilSel )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := ""
Local cOrderBy := ""

//Registro T120

cSelect := "  'T120' REGISTRO, CEJ.CEJ_FILIAL, CEJ.CEJ_DTINI, CEJ.CEJ_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CH6.CH6_CODIGO T120_CH6_CODIGO, CH6.CH6_DESCRI T120_CH6_DESCRI, CEK.CEK_VALOR T120_CEK_VALOR "
cSelect += ", '' T150_CH6_CODIGO, '' T150_CH6_DESCRI, 0 T150_CEK_VALOR "
cSelect += ", '' T170_CH6_CODIGO, '' T170_CH6_DESCRI, 0 T170_CEK_VALOR "
cSelect += ", '' T181_CH6_CODIGO, '' T181_CH6_DESCRI, 0 T181_CEK_VALOR "

cFrom := RetSqlName( "CEJ" ) + " CEJ "

cFrom += "LEFT JOIN " + RetSqlName( "CEK" ) + " CEK "
cFrom += "  ON CEK.CEK_FILIAL = CEJ.CEJ_FILIAL "
cFrom += " AND CEK.CEK_ID = CEJ.CEJ_ID "
cFrom += " AND CEK.CEK_REGECF = '01' "
cFrom += " AND CEK.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) +  "' "
cFrom += " AND CAH.CAH_ID = CEJ.CEJ_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) +  "' "
cFrom += " AND CH6.CH6_ID = CEK.CEK_IDCODC "
cFrom += " AND CH6.D_E_L_E_T_ = '' "

//cWhere := "    CEJ.CEJ_FILIAL IN (" + cFilSel + ") "
cWhere := "    CEJ.CEJ_FILIAL = '" + xFilial( "CEJ" ) + "' "
cWhere += "AND CEJ.CEJ_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CEJ.CEJ_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CEJ.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registro T150

cSelect2 := "  'T150' REGISTRO, CEJ.CEJ_FILIAL, CEJ.CEJ_DTINI, CEJ.CEJ_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', 0 "
cSelect2 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEK.CEK_VALOR "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "

cFrom2 := RetSqlName( "CEJ" ) + " CEJ "

cFrom2 += "LEFT JOIN " + RetSqlName( "CEK" ) + " CEK "
cFrom2 += "  ON CEK.CEK_FILIAL = CEJ.CEJ_FILIAL "
cFrom2 += " AND CEK.CEK_ID = CEJ.CEJ_ID "
cFrom2 += " AND CEK.CEK_REGECF = '02' "
cFrom2 += " AND CEK.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) +  "' "
cFrom2 += " AND CAH.CAH_ID = CEJ.CEJ_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom2 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) +  "' "
cFrom2 += " AND CH6.CH6_ID = CEK.CEK_IDCODC "
cFrom2 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere2 := "    CEJ.CEJ_FILIAL IN (" + cFilSel + ") "
cWhere2 := " CEJ.CEJ_FILIAL = '" + xFilial( "CEJ" ) + "' "
cWhere2 += "AND CEJ.CEJ_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CEJ.CEJ_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CEJ.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Registro T170

cSelect3 := "  'T170' REGISTRO, CEJ.CEJ_FILIAL, CEJ.CEJ_DTINI, CEJ.CEJ_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEK.CEK_VALOR "
cSelect3 += ", '', '', 0 "

cFrom3 := RetSqlName( "CEJ" ) + " CEJ "

cFrom3 += "LEFT JOIN " + RetSqlName( "CEK" ) + " CEK "
cFrom3 += "  ON CEK.CEK_FILIAL = CEJ.CEJ_FILIAL "
cFrom3 += " AND CEK.CEK_ID = CEJ.CEJ_ID "
cFrom3 += " AND CEK.CEK_REGECF = '03' "
cFrom3 += " AND CEK.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) +  "' "
cFrom3 += " AND CAH.CAH_ID = CEJ.CEJ_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom3 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) +  "' "
cFrom3 += " AND CH6.CH6_ID = CEK.CEK_IDCODC "
cFrom3 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere3 := "    CEJ.CEJ_FILIAL IN (" + cFilSel + ") "
cWhere3 := " CEJ.CEJ_FILIAL = '" + xFilial( "CEJ" ) + "' "
cWhere3 += "AND CEJ.CEJ_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere3 += "AND CEJ.CEJ_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere3 += "AND CEJ.D_E_L_E_T_ = '' "

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

//Registro T181

cSelect4 := "  'T181' REGISTRO, CEJ.CEJ_FILIAL, CEJ.CEJ_DTINI, CEJ.CEJ_DTFIN, CAH.CAH_CODIGO "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEK.CEK_VALOR "

cFrom4 := RetSqlName( "CEJ" ) + " CEJ "

cFrom4 += "LEFT JOIN " + RetSqlName( "CEK" ) + " CEK "
cFrom4 += "  ON CEK.CEK_FILIAL = CEJ.CEJ_FILIAL "
cFrom4 += " AND CEK.CEK_ID = CEJ.CEJ_ID "
cFrom4 += " AND CEK.CEK_REGECF = '04' "
cFrom4 += " AND CEK.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom4 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) +  "' "
cFrom4 += " AND CAH.CAH_ID = CEJ.CEJ_IDPERA "
cFrom4 += " AND CAH.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom4 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) +  "' "
cFrom4 += " AND CH6.CH6_ID = CEK.CEK_IDCODC "
cFrom4 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere4 := "    CEJ.CEJ_FILIAL IN (" + cFilSel + ") "
cWhere4 := " CEJ.CEJ_FILIAL = '" + xFilial( "CEJ" ) + "' "
cWhere4 += "AND CEJ.CEJ_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere4 += "AND CEJ.CEJ_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere4 += "AND CEJ.D_E_L_E_T_ = '' "

cSelect4 := "%" + cSelect4 + "%"
cFrom4   := "%" + cFrom4   + "%"
cWhere4  := "%" + cWhere4  + "%"

//Ordenacao da Query

cOrderBy := "CEJ_FILIAL, CAH_CODIGO, REGISTRO "

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
