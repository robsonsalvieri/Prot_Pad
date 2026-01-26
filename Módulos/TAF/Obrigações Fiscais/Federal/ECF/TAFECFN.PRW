#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFN

Rotina extratora da informacoes para o Bloco N do ECF.

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
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFN( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError    AS OBJECT
Local cBloco    AS CHARACTER
Local cIndMov   AS CHARACTER
Local cFil	    AS CHARACTER
Local nSeq	    AS NUMBER
Local aECFInfo  AS ARRAY
Local lFound    AS BOOLEAN
Local lN605     AS BOOLEAN

oError    := ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
cBloco    := "N"
cIndMov   := "1"
cFil	    := TurnFilObr( cFilSel )
nSeq	    := 2
aECFInfo  := { cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
lFound    := .T.
lN605     := .F.

Default aWizard := {}

if AliasInDic("V57") .And. TafColumnPos("CEA_FAPULE") .And. Valtype(aWizard) == "A" .And. Len(aWizard) >= 1 .And. Len(aWizard[1]) >= 5 .And. aWizard[1][5] >= "0010"
	lN605 := .T.
endif

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegN030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, lN605 )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegN001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegN001

Rotina para extrair e gravar as informacoes do Registro N001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegN001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "N001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "N001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegN030

Rotina para extrair e gravar as informacoes do Registro N030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegN030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, lN605 )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()
Local lAddN600  := .F.
Local lAdd4805  := .F.
Local lGerBlocN := .F.
Default lN605 	:= .F.

ECFQryN( cAliasQry, aWizard, cFilSel, lN605 )

//Verifica se ira gerar algum N
While ( cAliasQry )->( !Eof() )

	//O lucro presumido nao gerou nenhum lançamento inclusive nao deve gerar o N620 e estava saindo o N030 fixo, o PVA não aceita N030 no presumido.
	lGerBlocN := ( AllTrim((cAliasQry)->REGISTRO ) == "N500" .And. !Empty((cAliasQry)->N500_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N600" .And. !Empty((cAliasQry)->N600_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N605" .And. (cAliasQry)->N605_CEA_FAPULE == '2'   ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N610" .And. !Empty((cAliasQry)->N610_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N615" .And. !Empty((cAliasQry)->CEC_BCALC )       ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N620" .And. !Empty((cAliasQry)->N620_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N630" .And. !Empty((cAliasQry)->N630_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N650" .And. !Empty((cAliasQry)->N650_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N660" .And. !Empty((cAliasQry)->N660_CH6_CODIGO ) ) .Or.;
				 ( AllTrim((cAliasQry)->REGISTRO ) == "N670" .And. !Empty((cAliasQry)->N670_CH6_CODIGO ) )

	if lGerBlocN
		exit
	endif
	( cAliasQry )->( DBSkip() )
EndDo

//Registro N030
( cAliasQry )->( DbGoTop() )
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	if lGerBlocN
		cStrTxt := cDelimit + "N030"									//01 - REG
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEA_DTINI )		//02 - DT_INI
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEA_DTFIN )		//03 - DT_FIN
		cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "N030", cStrTxt )

		nSeq ++
	endif

	cPeriodo := ( cAliasQry )->CEA_DTINI + ( cAliasQry )->CEA_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEA_DTINI + ( cAliasQry )->CEA_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro N500
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N500"

			If !Empty( ( cAliasQry )->N500_CH6_CODIGO )

				cStrTxt := cDelimit + "N500"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N500_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N500_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N500_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N500", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N600
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N600"

			If !Empty( ( cAliasQry )->N600_CH6_CODIGO )

				cStrTxt := cDelimit + "N600"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N600_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N600_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N600_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N600", cStrTxt )

				nSeq ++
				lAddN600 := .T.
			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		if lN605
			If AllTrim((cAliasQry )->REGISTRO) == "N605" .And. (cAliasQry)->N605_CEA_FAPULE == '2'
				cStrTxt := cDelimit + "N600"  //01 - REG
				cStrTxt += cDelimit + "48.05" //02 - CODIGO
				cStrTxt += cDelimit + "Tipo de Apuração do Lucro da Exploração" //03 - DESCRICAO
				cStrTxt += cDelimit + "2" 	  //2=Contabilidade
				cStrTxt += cDelimit
				FExecSQL( aECFInfo, nSeq, "N600", cStrTxt )
				nSeq++
			elseif lAddN600 .and. !lAdd4805
				cStrTxt := cDelimit + "N600"  //01 - REG
				cStrTxt += cDelimit + "48.05" //02 - CODIGO
				cStrTxt += cDelimit + "Tipo de Apuração do Lucro da Exploração" //03 - DESCRICAO
				cStrTxt += cDelimit + "1"	  //1=Proporção entre a receita líquida da atividade incentivada e a receita líquida total
				cStrTxt += cDelimit
				FExecSQL( aECFInfo, nSeq, "N600", cStrTxt )
				nSeq++	

				lAdd4805 := .T.	
			endif

			//Registro N605
			While (cAliasQry)->(!Eof()) .And. AllTrim((cAliasQry )->REGISTRO) == "N605"
				if (cAliasQry)->N605_CEA_FAPULE == '2'
					cStrTxt := cDelimit + "N605"									//01 REG
					cStrTxt += cDelimit + TAFConType((cAliasQry)->N605_C1O_CODIGO )	//02 COD_CTA
					cStrTxt += cDelimit + TAFConType((cAliasQry)->N605_C1P_CODIGO )	//03 COD_CCUS
					cStrTxt += cDelimit + Val2Str((cAliasQry)->N605_V57_VALOR,16,2) //04 VALOR
					cStrTxt += cDelimit + TAFConType((cAliasQry)->N605_V57_INDVLR)	//05 IND_VALOR
					cStrTxt += cDelimit
					FExecSQL( aECFInfo, nSeq, "N605", cStrTxt )
					nSeq++
				endif
				(cAliasQry)->(DBSkip())
			EndDo
		endif

		//Registro N610
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N610"

			If !Empty( ( cAliasQry )->N610_CH6_CODIGO )

				cStrTxt := cDelimit + "N610"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N610_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N610_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N610_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N610", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N615
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N615"

			If !Empty( ( cAliasQry )->CEC_BCALC )

				cStrTxt := cDelimit + "N615"									 			//01 - REG
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_BCALC, 16, 2 )		//02 - BASE_CALC
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFINOR, 5, 2 )		//03 - PER_INCEN_FINOR
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFINOR, 16, 2 )		//04 - VL_LIQ_INCEN_FINOR
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFINAN, 5, 2 )		//05 - PER_INCEN_FINAM
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFINAN, 16, 2 )		//06 - VL_LIQ_INCEN_FINAM
				If aWizard[1][5] == '0001'
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_SUBTOT, 16, 2 )		//07 - VL_SUBTOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PERSUB, 16, 2 )		//08 - PER_VL_SUBTOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PFUNRE, 5, 2 )		//09 - PER_INCEN_FUNRES
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_VFUNRE, 16, 2 )		//10 - VL_LIQ_INCEN_FUNRES
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_TOTAL, 16, 2 )		//11 - VL_TOTAL
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_PERTOT, 16, 2 )		//12 - PER_VL_TOTAL
				ELse
					//A partir de 2015 o registro N615 possui somente 7 campos.
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEC_TOTAL, 16, 2 )		//07 - VL_TOTAL				
				EndIF
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N615", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N620
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N620"

			If !Empty( ( cAliasQry )->N620_CH6_CODIGO )

				cStrTxt := cDelimit + "N620"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N620_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N620_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N620_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N620", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N630
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N630"

			If !Empty( ( cAliasQry )->N630_CH6_CODIGO )

				cStrTxt := cDelimit + "N630"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N630_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N630_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N630_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N630", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N650
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N650"

			If !Empty( ( cAliasQry )->N650_CH6_CODIGO )

				cStrTxt := cDelimit + "N650"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N650_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N650_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N650_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N650", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N660
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N660"

			If !Empty( ( cAliasQry )->N660_CH6_CODIGO )

				cStrTxt := cDelimit + "N660"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N660_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N660_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N660_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N660", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

		//Registro N670
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "N670"

			If !Empty( ( cAliasQry )->N670_CH6_CODIGO )

				cStrTxt := cDelimit + "N670"									 				//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N670_CH6_CODIGO )			//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->N670_CH6_DESCRI )			//03 - DESCRICAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->N670_CEB_VALOR, 16, 2 )		//04 - VALOR
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "N670", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryN

Executa a Query principal para a extracao do Bloco N do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 17/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryN( cAliasQry, aWizard, cFilSel, lN605  )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := cSelect5 := cSelect6 := cSelect7 := cSelect8 := cSelect9 := cSelect10 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := cFrom7   := cFrom8   := cFrom9   := cFrom10   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := cWhere7  := cWhere8  := cWhere9  := cWhere10  := ""
Local cOrderBy := ""

Default lN605 := .F.

//Registro N500
cSelect := "  'N500' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CH6.CH6_CODIGO N500_CH6_CODIGO, CH6.CH6_DESCRI N500_CH6_DESCRI, CEB.CEB_VALOR N500_CEB_VALOR "
cSelect += ", '' N600_CH6_CODIGO, '' N600_CH6_DESCRI, 0 N600_CEB_VALOR "
cSelect += ", '' N610_CH6_CODIGO, '' N610_CH6_DESCRI, 0 N610_CEB_VALOR "
cSelect += ", 0 CEC_BCALC, 0 CEC_PFINOR, 0 CEC_VFINOR, 0 CEC_PFINAN, 0 CEC_VFINAN, 0 CEC_SUBTOT, 0 CEC_PERSUB, 0 CEC_PFUNRE , 0 CEC_VFUNRE , 0 CEC_TOTAL, 0 CEC_PERTOT "
cSelect += ", '' N620_CH6_CODIGO, '' N620_CH6_DESCRI, 0 N620_CEB_VALOR "
cSelect += ", '' N630_CH6_CODIGO, '' N630_CH6_DESCRI, 0 N630_CEB_VALOR "
cSelect += ", '' N650_CH6_CODIGO, '' N650_CH6_DESCRI, 0 N650_CEB_VALOR "
cSelect += ", '' N660_CH6_CODIGO, '' N660_CH6_DESCRI, 0 N660_CEB_VALOR "
cSelect += ", '' N670_CH6_CODIGO, '' N670_CH6_DESCRI, 0 N670_CEB_VALOR "
if lN605
	cSelect += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom := RetSqlName( "CEA" ) + " CEA "

cFrom += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom += " AND CEB.CEB_REGECF = '01' "
cFrom += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N600
cSelect2 := "  'N600' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', 0 "
cSelect2 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect2 += ", '', '', 0 "
cSelect2 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
if lN605
	cSelect2 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom2 := RetSqlName( "CEA" ) + " CEA "
cFrom2 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom2 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom2 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom2 += " AND CEB.CEB_REGECF = '02' "
cFrom2 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom2 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom2 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom2 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere2 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere2 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N610
cSelect3 := "  'N610' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect3 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
if lN605
	cSelect3 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom3 := RetSqlName( "CEA" ) + " CEA "
cFrom3 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom3 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom3 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom3 += " AND CEB.CEB_REGECF = '03' "
cFrom3 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom3 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom3 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom3 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom3 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere3 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere3 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere3 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere3 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N615
cSelect4 := "  'N615' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", CEC.CEC_BCALC, CEC.CEC_PFINOR, CEC.CEC_VFINOR, CEC.CEC_PFINAN, CEC.CEC_VFINAN, CEC.CEC_SUBTOT, CEC.CEC_PERSUB, CEC.CEC_PFUNRE, CEC.CEC_VFUNRE, CEC.CEC_TOTAL, CEC.CEC_PERTOT "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
if lN605
	cSelect4 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom4 := RetSqlName( "CEA" ) + " CEA "
cFrom4 += "LEFT JOIN " + RetSqlName( "CEC" ) + " CEC "
cFrom4 += "  ON CEC.CEC_FILIAL = CEA.CEA_FILIAL "
cFrom4 += " AND CEC.CEC_ID = CEA.CEA_ID "
cFrom4 += " AND CEC.D_E_L_E_T_ = ' ' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom4 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom4 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom4 += " AND CAH.D_E_L_E_T_ = ' ' "

cWhere4 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere4 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere4 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere4 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N620
cSelect5 := "  'N620' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect5 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
if lN605
	cSelect5 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom5 := RetSqlName( "CEA" ) + " CEA "
cFrom5 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom5 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom5 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom5 += " AND CEB.CEB_REGECF = '04' "
cFrom5 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom5 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom5 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom5 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom5 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom5 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom5 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere5 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere5 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere5 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere5 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N630
cSelect6 := "  'N630' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
if lN605
	cSelect6 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom6 := RetSqlName( "CEA" ) + " CEA "

cFrom6 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom6 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom6 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom6 += " AND CEB.CEB_REGECF = '05' "
cFrom6 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom6 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom6 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom6 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom6 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom6 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom6 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere6 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere6 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere6 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere6 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N650
cSelect7 := "  'N650' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
if lN605
	cSelect7 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif
cFrom7 := RetSqlName( "CEA" ) + " CEA "

cFrom7 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom7 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom7 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom7 += " AND CEB.CEB_REGECF = '07' "
cFrom7 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom7 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom7 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom7 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom7 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom7 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom7 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere7 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere7 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere7 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere7 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N660
cSelect8 := "  'N660' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
cSelect8 += ", '', '', 0 "
if lN605
	cSelect8 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif
cFrom8 := RetSqlName( "CEA" ) + " CEA "

cFrom8 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom8 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom8 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom8 += " AND CEB.CEB_REGECF = '08' "
cFrom8 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom8 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom8 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom8 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom8 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom8 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom8 += " AND CH6.D_E_L_E_T_ = '' "

cWhere8 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere8 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere8 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere8 += "AND CEA.D_E_L_E_T_ = ' ' "

//Registro N670
cSelect9 := "  'N670' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", '', '', 0 "
cSelect9 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEB.CEB_VALOR "
if lN605
	cSelect9 += ", '' N605_C1O_CODIGO, '' N605_C1P_CODIGO, 0 N605_V57_VALOR, '' N605_V57_INDVLR, '' N605_CEA_FAPULE "
endif

cFrom9 := RetSqlName( "CEA" ) + " CEA "

cFrom9 += "LEFT JOIN " + RetSqlName( "CEB" ) + " CEB "
cFrom9 += "  ON CEB.CEB_FILIAL = CEA.CEA_FILIAL "
cFrom9 += " AND CEB.CEB_ID = CEA.CEA_ID "
cFrom9 += " AND CEB.CEB_REGECF = '09' "
cFrom9 += " AND CEB.D_E_L_E_T_ = ' ' "

cFrom9 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom9 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom9 += " AND CAH.CAH_ID = CEA.CEA_IDPERA "
cFrom9 += " AND CAH.D_E_L_E_T_ = ' ' "

cFrom9 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom9 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom9 += " AND CH6.CH6_ID = CEB.CEB_IDCODL "
cFrom9 += " AND CH6.D_E_L_E_T_ = ' ' "

cWhere9 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
cWhere9 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere9 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere9 += "AND CEA.D_E_L_E_T_ = ' ' "

if lN605
	cSelect10 := " 'N605' REGISTRO, CEA.CEA_FILIAL, CEA.CEA_DTINI, CEA.CEA_DTFIN, CAH.CAH_CODIGO "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", '', '', 0 "
	cSelect10 += ", C1O.C1O_CODIGO, C1P.C1P_CODCUS, V57.V57_VALOR, V57.V57_INDVLR "
	cSelect10 += ", CEA.CEA_FAPULE N605_CEA_FAPULE "

	cFrom10 := RetSqlName( "CEA" ) + " CEA "

	cFrom10 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom10 += "ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
	cFrom10 += "AND CAH.CAH_ID = CEA.CEA_IDPERA "
	cFrom10 += "AND CAH.D_E_L_E_T_ = ' ' "

	cFrom10 += "INNER JOIN " + RetSqlName( "V57" ) + " V57 "
	cFrom10 += "ON V57.V57_FILIAL = CEA.CEA_FILIAL "
	cFrom10 += "AND V57.V57_ID = CEA.CEA_ID "
	cFrom10 += "AND V57.D_E_L_E_T_ = ' ' "

	cFrom10 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
	cFrom10 += "ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
	cFrom10 += "AND CH6.CH6_ID = V57.V57_IDCODL "
	cFrom10 += "AND CH6.D_E_L_E_T_ = ' ' "

	cFrom10 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom10 += "ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cFrom10 += "AND C1O.C1O_ID = V57.V57_CTA "
	cFrom10 += "AND C1O.D_E_L_E_T_ = ' ' "

	cFrom10 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom10 += "ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
	cFrom10 += "AND C1P.C1P_ID = V57.V57_CODCUS "
	cFrom10 += "AND C1P.D_E_L_E_T_ = ' ' "

	cWhere10 := "CEA.CEA_FILIAL = '" + xFilial( "CEA" ) + "' "
	cWhere10 += "AND CEA.CEA_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere10 += "AND CEA.CEA_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere10 += "AND CEA.D_E_L_E_T_ = ' ' "
endif

//Ordenacao da Query
cOrderBy := "CEA_FILIAL, CAH_CODIGO, REGISTRO "

cQry :=   cSelect  + " FROM " + cFrom  + " WHERE " + cWhere
cQry += " UNION SELECT " + cSelect2 + " FROM " + cFrom2 + " WHERE " + cWhere2
cQry += " UNION SELECT " + cSelect3 + " FROM " + cFrom3 + " WHERE " + cWhere3
cQry += " UNION SELECT " + cSelect4 + " FROM " + cFrom4 + " WHERE " + cWhere4
cQry += " UNION SELECT " + cSelect5 + " FROM " + cFrom5 + " WHERE " + cWhere5
cQry += " UNION SELECT " + cSelect6 + " FROM " + cFrom6 + " WHERE " + cWhere6
cQry += " UNION SELECT " + cSelect6 + " FROM " + cFrom6 + " WHERE " + cWhere6
cQry += " UNION SELECT " + cSelect7 + " FROM " + cFrom7 + " WHERE " + cWhere7
cQry += " UNION SELECT " + cSelect8 + " FROM " + cFrom8 + " WHERE " + cWhere8
cQry += " UNION SELECT " + cSelect9 + " FROM " + cFrom9 + " WHERE " + cWhere9
if lN605
	cQry += " UNION SELECT " + cSelect10 + " FROM " + cFrom10 + " WHERE " + cWhere10
endif

cQry += " ORDER BY " + cOrderBy

cQry := "%" + cQry + "%"

BeginSql Alias cAliasQry
	SELECT %Exp:cQry%
EndSql

Return Nil
