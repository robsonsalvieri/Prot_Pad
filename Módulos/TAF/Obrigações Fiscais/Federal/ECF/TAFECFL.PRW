#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFECFL

Rotina extratora da informacoes para o Bloco L do ECF.

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
@Since 11/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFL( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"L"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegL030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegL001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegL001

Rotina para extrair e gravar as informacoes do Registro L001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 11/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegL001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "L001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "L001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegL030

Rotina para extrair e gravar as informacoes do Registro L030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 11/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegL030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()

ECFQryL( cAliasQry, aWizard, cFilSel )

//Registro L030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "L030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CAP_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CAP_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO						//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "L030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CAP_DTINI + ( cAliasQry )->CAP_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CAP_DTINI + ( cAliasQry )->CAP_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro L100
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "L100"

			If !Empty( ( cAliasQry )->CAQ_CHA_CODIGO )

				cStrTxt := cDelimit + "L100"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAQ_CHA_CODIGO )				//02 - CODIGO
				cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->CAQ_CHA_DESCRI)					//03 - DESCRICAO
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAQ_CHA_TPCTA == "1", "S", "A" )		//04 - TIPO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAQ_CHA_NIVEL )				//05 - NIVEL
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAQ_C2R_CODIGO)				//06 - COD_NAT
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAQCHA_CHA_CODIGO )			//07 - COD_CTA_SUP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAQ_SALINI, 16, 2 )				//08 - VAL_CTA_REF_INI
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAQ_INDINI == "1", "D", "C" )			//09 - IND_VAL_CTA_REF_INI
				
				If aWizard[1,5] >= "0005" .and. TafColumnPos( "CAQ_VLRTD" ) 					// Campos Layout versão 5 do ECF
                    cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAQ_VLRTD, 16, 2 ) 			// 10 - VAL_CTA_REF_DEB
                    cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAQ_VLRTC, 16, 2 ) 			// 11 - VAL_CTA_REF_CRED
                EndIf
																								// Se for a versão 5 do ECF os campos a seguir são 12 e 13
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAQ_SALFIN, 16, 2 )				//10 - VAL_CTA_REF_FIN
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAQ_INDFIN == "1", "D", "C" )			//11 - IND_VAL_CTA_REF_FIN
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "L100", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro L200
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "L200"

			If !Empty( ( cAliasQry )->CAR_INDAVA )

				cStrTxt := cDelimit + "L200"						//01 - REG
				cStrTxt += cDelimit + ( cAliasQry )->CAR_INDAVA	//02 - IND_AVAL_ESTOQ
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "L200", cStrTxt )
				
			EndIf
			
			nSeq ++
			//cLoop := ( cAliasQry )->CAR_INDAVA

			//Registro L210
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "L200" //.and. ( cAliasQry )->CAR_INDAVA == cLoop

				If !Empty( ( cAliasQry )->CAS_CH6_CODIGO )

					cStrTxt := cDelimit + "L210"												//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAS_CH6_CODIGO )		//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAS_CH6_DESCRI )		//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAS_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "L210", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

		EndDo

		//Registro L300
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "L300"

			If !Empty( ( cAliasQry )->CAT_CHA_CODIGO )

				cStrTxt := cDelimit + "L300"														//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAT_CHA_CODIGO )				//02 - CODIGO
				cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->CAT_CHA_DESCRI )				//03 - DESCRICAO
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAT_CHA_TPCTA == "1", "S", "A" )	//04 - TIPO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAT_CHA_NIVEL )				//05 - NIVEL
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAT_C2R_CODIGO)				//06 - COD_NAT
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CATCHA_CHA_CODIGO )			//07 - COD_CTA_SUP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAT_SALFIN, 16, 2 )				//08 - VALOR
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAT_INDFIN == "1", "C", "D" )		//09 - IND_ VALOR 
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "L300", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryL

Executa a Query principal para a extracao do Bloco L do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 16/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryL( cAliasQry, aWizard, cFilSel )

Local cSelect	:= cSelect2 := cSelect3 := ""
Local cFrom		:= cFrom2   := cFrom3   := ""
Local cWhere	:= cWhere2  := cWhere3  := ""
Local cOrderBy	:= ""
Local lVrsECF	:= Iif(aWizard[1,5] >= "0005" .and. TafColumnPos( "CAQ_VLRTD" ), .T., .F.)

//Registro L100
cSelect := "  'L100' REGISTRO, CAP.CAP_FILIAL, CAP.CAP_DTINI, CAP.CAP_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CHA.CHA_CODIGO CAQ_CHA_CODIGO, CHA.CHA_DESCRI CAQ_CHA_DESCRI, CHA.CHA_TPCTA CAQ_CHA_TPCTA, CHA.CHA_NIVEL CAQ_CHA_NIVEL, C2R.C2R_CODIGO CAQ_C2R_CODIGO, CHACHA.CHA_CODIGO CAQCHA_CHA_CODIGO

If lVrsECF //Se for a versão 5 do ECF
	cSelect += ", CAQ.CAQ_VLRTD , CAQ.CAQ_VLRTC "
EndIf

cSelect += ", CAQ.CAQ_SALINI, CAQ.CAQ_INDINI, CAQ.CAQ_SALFIN, CAQ.CAQ_INDFIN "
cSelect += ", '' CAR_INDAVA "
cSelect += ", '' CAS_CH6_CODIGO, '' CAS_CH6_DESCRI, 0 CAS_VALOR "
cSelect += ", '' CAT_CHA_CODIGO, '' CAT_CHA_DESCRI, '' CAT_CHA_TPCTA, '' CAT_CHA_NIVEL, '' CAT_C2R_CODIGO, '' CATCHA_CHA_CODIGO, 0 CAT_SALFIN, '' CAT_INDFIN "

cFrom := RetSqlName( "CAP" ) + " CAP "

cFrom += "LEFT JOIN " + RetSqlName( "CAQ" ) + " CAQ "
cFrom += "  ON CAQ.CAQ_FILIAL = CAP.CAP_FILIAL "
cFrom += " AND CAQ.CAQ_ID = CAP.CAP_ID "
cFrom += " AND CAQ.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CAP.CAP_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHA.CHA_ID = CAQ.CAQ_IDCODC "
cFrom += " AND CHA.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom += " AND C2R.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere := "    CAP.CAP_FILIAL IN (" + cFilSel + ") "
cWhere := "    CAP.CAP_FILIAL = '" + xFilial( "CAP" ) + "' "
cWhere += "AND CAP.CAP_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CAP.CAP_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CAP.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registros L200 e L210

cSelect2 := "  'L200' REGISTRO, CAP.CAP_FILIAL, CAP.CAP_DTINI, CAP.CAP_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', '', '', '', '' "

If lVrsECF
	cSelect2 += ", 0, 0 "	
EndIf

cSelect2 += ", 0, '', 0, '' "
cSelect2 += ", CAR.CAR_INDAVA "
cSelect2 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CAS.CAS_VALOR "
cSelect2 += ", '', '', '', '', '', '', 0, '' "

cFrom2 := RetSqlName( "CAP" ) + " CAP "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAR" ) + " CAR "
cFrom2 += "  ON CAR.CAR_FILIAL = '" + xFilial("CAR") + "' "
cFrom2 += " AND CAR.CAR_ID = CAP.CAP_ID "
cFrom2 += " AND CAR.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAS" ) + " CAS "
cFrom2 += "  ON CAS.CAS_FILIAL = CAP.CAP_FILIAL "
cFrom2 += " AND CAS.CAS_ID = CAP.CAP_ID "
//cFrom2 += " AND CAS.CAS_ID = CAR.CAR_ID "
//cFrom2 += " AND CAS.CAS_INDAVA = CAR.CAR_INDAVA "
cFrom2 += " AND CAS.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CAP.CAP_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom2 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom2 += " AND CH6.CH6_ID = CAS.CAS_IDCODC "
cFrom2 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere2 := "    CAP.CAP_FILIAL IN (" + cFilSel + ") "
cWhere2 := "    CAP.CAP_FILIAL = '" + xFilial( "CAP" ) + "' "
cWhere2 += "AND CAP.CAP_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CAP.CAP_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CAP.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Registro L300

cSelect3 := "  'L300' REGISTRO, CAP.CAP_FILIAL, CAP.CAP_DTINI, CAP.CAP_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', '', '', '', '' "

If lVrsECF
	cSelect3 += ", 0, 0 "
EndIf

cSelect3 += ", 0, '', 0, '' "
cSelect3 += ", '' "
cSelect3 += ", '', '', 0 "
cSelect3 += ", CHA.CHA_CODIGO, CHA.CHA_DESCRI, CHA.CHA_TPCTA, CHA.CHA_NIVEL, C2R.C2R_CODIGO, CHACHA.CHA_CODIGO, CAT.CAT_SALFIN, CAT.CAT_INDFIN "

cFrom3 := RetSqlName( "CAP" ) + " CAP "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAT" ) + " CAT "
cFrom3 += "  ON CAT.CAT_FILIAL = CAP.CAP_FILIAL "
cFrom3 += " AND CAT.CAT_ID = CAP.CAP_ID "
cFrom3 += " AND CAT.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom3 += " AND CAH.CAH_ID = CAP.CAP_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom3 += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom3 += " AND CHA.CHA_ID = CAT.CAT_IDCODC "
cFrom3 += " AND CHA.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom3 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom3 += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom3 += " AND C2R.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom3 += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom3 += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom3 += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere3 := "    CAP.CAP_FILIAL IN (" + cFilSel + ") "
cWhere3 := "    CAP.CAP_FILIAL = '" + xFilial( "CAP" ) + "' "
cWhere3 += "AND CAP.CAP_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere3 += "AND CAP.CAP_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere3 += "AND CAP.D_E_L_E_T_ = '' "

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

//Ordenacao da Query

cOrderBy := "CAP_FILIAL, CAH_CODIGO, REGISTRO "

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

	ORDER BY
		%Exp:cOrderBy%

EndSql

Return() 
