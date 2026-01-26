#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

Static __lECFCent := GetMv("MV_TAFCENT", .F., .T.) // Define se a apuração da ecf é feita de forma centralizada.

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFM

Rotina extratora da informacoes para o Bloco M do ECF.

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
@Since 14/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFM( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"M"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegM010( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegM030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegM001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegM001

Rotina para extrair e gravar as informacoes do Registro M001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 14/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegM001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "M001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "M001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegM010

Rotina para extrair e gravar as informacoes do Registro M010.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 14/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegM010( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryM( cAliasQry, aWizard, cFilSel, "M010" )

//Registro M010
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "M010"													// REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFR_CODCTA )					// COD_CTA_B
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFR_DCODCT )					// DESC_CTA_LAL
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CFR_DTLAL )						// DT_AP_LAL
	if len(aWizard[1]) >= 5 .And. aWizard[1,5] >= '0005'
		If TAFAlsInDic( 'V3K' ) .and. TAFColumnPos( 'CFR_IDCODP' )
			cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V3K_CODIGO )				// COD_PB_RFB
		endif	
	else
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH8_CODIGO )				// COD_LAN_ORIG	
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH8_DESCRI )				// DESC_LAN_ORIG
	endif
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CFR_DTLIM )						// DT_LIM_LAL
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CFR_TRIBUT == "1", "I", "C" )			// COD_TRIBUTO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFR_VLSALD, 16, 2 )				// Vl_SALDO_INI
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CFR_INDSAL == "1", "D", "C" )			// IND_Vl_SALDO_INI
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFR_CNPJ )						// CNPJ_SIT_ESP
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "M010", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegM030

Rotina para extrair e gravar as informacoes do Registro M030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 06/08/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegM030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cIndLan   := ""
Local cCodTrib  := ""
Local cLoop     := ""
Local cLoopfilho:= ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()

ECFQryM( cAliasQry, aWizard, cFilSel, "M030" )

//Registro M030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "M030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEN_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEN_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "M030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CEN_DTINI + ( cAliasQry )->CEN_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEN_DTINI + ( cAliasQry )->CEN_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro M300
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M300"

			If !Empty(( cAliasQry )->M300_CH8_CODIGO)
				cStrTxt := cDelimit + "M300"												//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M300_CH8_CODIGO )		//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M300_CH8_DESCRI )		//03 - DESCRICAO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M300_CH8_TPLANC )		//04 - TIPO_LANCAMENTO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CEO_TIPORL )			//05 - IND_RELACAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEO_VLRLC, 16, 2 )		//06 - VALOR
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CEO_HISTLC )			//07 - HIST_LAN_LAL
				cStrTxt += cDelimit
	
				FExecSQL( aECFInfo, nSeq, "M300", cStrTxt )
	
				nSeq ++
	
				cLoop := ( cAliasQry )->REG_FILHO
			EndIf

			//Registro M305
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M300" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M305_CFR_CODCTA )

					cStrTxt := cDelimit + "M305"													//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M305_CFR_CODCTA )			//02 - COD_CTA_B
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEP_VLRLC, 16, 2 )			//03 - VL_CTA
					//04 - IND_VL_CTA 
					If ( cAliasQry )->M300_CH8_TPLANC $ "E|P" // Se E-Exclusão ou P-Compensacao Prejuizo
						cStrTxt += cDelimit + "C"
					Else // A=Adição ou L=Lucro
						cStrTxt += cDelimit + "D" 	
					EndIf	
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M305", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

			cLoop := ( cAliasQry )->REG_FILHO

			//Registro M310
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M300" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M310_C1O_CODIGO )				

					cStrTxt := cDelimit + "M310"														//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M310_C1O_CODIGO )				//02 - COD_CTA
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M310_C1P_CODCUS )				//03 - COD_CCUS
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEQ_VLRLC, 16, 2 )				//04 - VL_CTA
					cStrTxt += cDelimit + ( cAliasQry )->CEQ_INDVLR									//05 - IND_VL_CTA
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M310", cStrTxt )

					nSeq ++

				EndIf
				
				cLoopFilho := ( cAliasQry )->M310_C1O_CODIGO + ( cAliasQry )->M310_C1P_CODCUS	

				//Registro M312
				While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M300" .and. ( cAliasQry )->REG_FILHO == cLoop .and. (( cAliasQry )->M310_C1O_CODIGO + ( cAliasQry )->M310_C1P_CODCUS) == cLoopFilho

					If !Empty( ( cAliasQry )->M312_CFS_NUMLCT )

						cStrTxt := cDelimit + "M312"											//01 - REG
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M312_CFS_NUMLCT )	//02 - NUM_LCTO
						cStrTxt += cDelimit

						FExecSQL( aECFInfo, nSeq, "M312", cStrTxt )

						nSeq ++

					EndIf

					( cAliasQry )->( DBSkip() )
					
				EndDo
				
			EndDo

			cLoop := ( cAliasQry )->REG_FILHO

			//Registro M315
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M300" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M315_C1G_TPPROC ) .OR. !Empty( ( cAliasQry )->M315_C1G_NUMPROC )

					cStrTxt := cDelimit + "M315"													//01 - REG
					cStrTxt += cDelimit + ( cAliasQry )->M315_C1G_TPPROC							//02 - IND_PROC
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M315_C1G_NUMPRO )			//03 - NUM_PROC
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M315", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

		EndDo

		//Registro M350
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M350"

			If !Empty( ( cAliasQry )->M350_CH8_CODIGO )
			
				cStrTxt := cDelimit + "M350"												//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M350_CH8_CODIGO )		//02 - CODIGO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M350_CH8_DESCRI )		//03 - DESCRICAO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M350_CH8_TPLANC )		//04 - TIPO_LANCAMENTO
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHR_TIPORL )			//05 - IND_RELACAO
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHR_VLRLC, 16, 2 )		//06 - VALOR
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHR_HISTLC )			//07 - HIST_LAN_LAL
				cStrTxt += cDelimit
	
				FExecSQL( aECFInfo, nSeq, "M350", cStrTxt )
	
				nSeq ++
			
			EndIf

			cLoop := ( cAliasQry )->REG_FILHO

			//Registro M355
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M350" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M355_CFR_CODCTA )

					cStrTxt := cDelimit + "M355"														//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M355_CFR_CODCTA )				//02 - COD_CTA_B
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHS_VLRLC, 16, 2 )				//03 - VL_CTA
					cStrTxt += cDelimit + Iif( ( cAliasQry )->CHS_INDLC == "1", "D", "C" )		//04 - IND_VL_CTA
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M355", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

			cLoop := ( cAliasQry )->REG_FILHO

			//Registro M360
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M350" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M360_C1O_CODIGO )

					cStrTxt := cDelimit + "M360"														//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M360_C1O_CODIGO )				//02 - COD_CTA
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M360_C1P_CODCUS )				//03 - COD_CCUS
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHT_VLRLC, 16, 2 )				//04 - VL_CTA
					cStrTxt += cDelimit + ( cAliasQry )->CHT_INDVLR									//05 - IND_VL_CTA
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M360", cStrTxt )

					nSeq ++

				EndIf
				
				cLoopFilho := ( cAliasQry )->M360_C1O_CODIGO + ( cAliasQry )->M360_C1P_CODCUS 

				//Registro M362
				While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M350" .and. ( cAliasQry )->REG_FILHO == cLoop .and. ( ( cAliasQry )->M360_C1O_CODIGO + ( cAliasQry )->M360_C1P_CODCUS ) == cLoopFilho

					If !Empty( ( cAliasQry )->M362_CFS_NUMLCT )

						cStrTxt := cDelimit + "M362"												//01 - REG
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M362_CFS_NUMLCT )		//02 - NUM_LCTO
						cStrTxt += cDelimit

						FExecSQL( aECFInfo, nSeq, "M362", cStrTxt )

						nSeq ++

					EndIf

					( cAliasQry )->( DBSkip() )
					
				EndDo
				
			EndDo

			cLoop := ( cAliasQry )->REG_FILHO
			
			//Registro M365
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M350" .and. ( cAliasQry )->REG_FILHO == cLoop

				If !Empty( ( cAliasQry )->M365_C1G_TPPROC ) .OR. !Empty( ( cAliasQry )->M365_C1G_NUMPROC )

					cStrTxt := cDelimit + "M365"												//01 - REG
					cStrTxt += cDelimit + ( cAliasQry )->M365_C1G_TPPROC						//02 - IND_PROC
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M365_C1G_NUMPRO )		//03 - NUM_PROC
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "M365", cStrTxt )

					nSeq ++

				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

		EndDo

		//Registro M410
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M410"

			If !Empty( ( cAliasQry )->CET_IDLCTO )

				If ( cAliasQry )->CET_IDLCTO == "1"
					cIndLan := "CR"
				ElseIf ( cAliasQry )->CET_IDLCTO == "2"
					cIndLan := "DB"
				ElseIf ( cAliasQry )->CET_IDLCTO == "3"
					cIndLan := "PF"
				ElseIf ( cAliasQry )->CET_IDLCTO == "4"
					cIndLan := "BC"
				Else
					cIndLan := ""
				EndIf
				
				If ( cAliasQry )->CET_CODTRI == "1"
					cCodTrib := "I"
				ElseIf ( cAliasQry )->CET_CODTRI == "2"
					cCodTrib := "C"
				Else
					cCodTrib := ""	
				EndIf

				cStrTxt := cDelimit + "M410"												//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M410_CFR_CODCTA )		//02 - COD_CTA_LAL
				cStrTxt += cDelimit + cCodTrib												//03 - COD_TRIBUTO 
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CET_VLRLC, 16, 2 )		//04 - VAL_LAN_LALB_PB
				cStrTxt += cDelimit + cIndLan												//05 - IND_VAL_LAN_LALB_PB
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M410_CTA_CODIGO )		//06 - COD_CTA_LAL_CTP
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CET_HISTLC )			//07 - HIST_LAN_LALB
				cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CET_TRIDIF )			//08 - IND_LAN_ANT
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "M410", cStrTxt )

				nSeq ++

				cLoop := ( cAliasQry )->( M410_CFR_CODCTA + CET_CODTRI + M410_CTA_CODIGO )

				//Registro M415
				While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M410" .and. ;
						( cAliasQry )->( M410_CFR_CODCTA + CET_CODTRI + M410_CTA_CODIGO ) == cLoop

					If !Empty( ( cAliasQry )->M415_C1G_TPPROC ) .OR. !Empty( ( cAliasQry )->M415_C1G_NUMPRO )

						cStrTxt := cDelimit + "M415"												//01 - REG
						cStrTxt += cDelimit + ( cAliasQry )->M415_C1G_TPPROC						//02 - IND_PROC
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M415_C1G_NUMPRO )		//03 - NUM_PROC
						cStrTxt += cDelimit

						FExecSQL( aECFInfo, nSeq, "M415", cStrTxt )

						nSeq ++

					EndIf

					( cAliasQry )->( DBSkip() )
				EndDo

			Else

				( cAliasQry )->( DBSkip() )
			EndIf

		EndDo

		//Registro M500
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "M500"

			If !Empty( ( cAliasQry )->M500_CFR_CODCTA )
			
				If ( cAliasQry )->CEV_CODTRI == "1"
					cCodTrib := "I"
				ElseIf ( cAliasQry )->CEV_CODTRI == "2"
					cCodTrib := "C"
				Else
					cCodTrib := ""	
				EndIf

				cStrTxt := cDelimit + "M500"														//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->M500_CFR_CODCTA )				//02 - COD_CTA_B
				cStrTxt += cDelimit + cCodTrib														//03 - COD_TRIBUTO 
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEV_VLRSLI, 16, 2 )				//04 - SD_INI_LAL
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CEV_SITSLI == "1", "D", "C" )		//05 - IND_SD_INI_LAL
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEV_VLRPTA, 16, 2 )				//06 - VL_LCTO_PARTE_A
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CEV_STVLPA == "1", "C", "D" )		//07 - IND_VL_LCTO_PARTE_A
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEV_VLRPTB, 16, 2 )				//08 - VL_LCTO_PARTE B
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CEV_STVLPB == "1", "C", "D" )		//09 - IND_VL_LCTO_PARTE B
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEV_VLRFIN, 16, 2 )				//10 - SD_FIM_LAL
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CEV_SITFIN == "1", "D", "C" )		//11 - IND_ SD_FIM_LAL B
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "M500", cStrTxt )

				nSeq ++

			EndIf

			( cAliasQry )->( DBSkip() )
		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryM

Executa a Query principal para a extracao do Bloco M do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento
       cReg      -> Indica para qual Registro se refere a Query

@Author Felipe C. Seolin
@Since 16/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryM( cAliasQry, aWizard, cFilSel, cReg )

Local cSelect  := cSelect2 := cSelect3 := cSelect4 := cSelect5 := cSelect6 := cSelect7 := cSelect8 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := cFrom7   := cFrom8   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := cWhere7  := cWhere8  := ""
Local cOrderBy := ""

If cReg == "M010"

	cSelect := "CFR.CFR_CODCTA, CFR.CFR_DCODCT, CFR.CFR_DTLAL, CH8.CH8_CODIGO, CH8.CH8_DESCRI, CFR.CFR_DTLIM, CFR.CFR_TRIBUT, CFR.CFR_VLSALD, CFR.CFR_INDSAL, CFR.CFR_CNPJ "

	cFrom := RetSqlName( "CFR" ) + " CFR "

	cFrom += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom += "  ON CH8.CH8_FILIAL = '" + xFilial( "CH8" ) + "' "
	cFrom += " AND CH8.CH8_ID = CFR.CFR_IDCODL "
	cFrom += " AND CH8.D_E_L_E_T_ = '' "

	if len(aWizard[1]) >= 5 .And. aWizard[1,5] >= '0005'
		If TAFAlsInDic( 'V3K' ) .and. TAFColumnPos( 'CFR_IDCODP' )
			cSelect += ', V3K.V3K_CODIGO'
			
			cFrom += "LEFT JOIN " + RetSqlName( "V3K" ) + " V3K "
			cFrom += "  ON V3K.V3K_FILIAL = '" + xFilial( "V3K" ) + "' "
			cFrom += " AND V3K.V3K_ID = CFR.CFR_IDCODP "
			cFrom += " AND V3K.D_E_L_E_T_ = '' "
		endif	
	endif	

	cWhere := "    CFR.CFR_FILIAL = '" + xFilial("CFR" ) + "' "
	cWhere += "AND CFR.CFR_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFR.D_E_L_E_T_ = '' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	//Ordenacao da Query

	cOrderBy := "CFR_FILIAL, CFR_PERIOD "

	cOrderBy  := "%" + cOrderBy  + "%"

ElseIf cReg == "M030"

	//Registros e-Lalur e e-Lacs

	cSelect := " 'M300' REGISTRO,'M305' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect += ",CH8.CH8_CODIGO M300_CH8_CODIGO,CH8.CH8_DESCRI M300_CH8_DESCRI,CH8.CH8_TPLANC M300_CH8_TPLANC,CEO.CEO_TIPORL,CEO.CEO_VLRLC,CEO.CEO_HISTLC "
	cSelect += ",CFR.CFR_CODCTA M305_CFR_CODCTA,CEP.CEP_VLRLC,CEP.CEP_INDLC "
	cSelect += ",'' M310_C1O_CODIGO,'' M310_C1P_CODCUS,0 CEQ_VLRLC,'' CEQ_INDVLR "
	cSelect += ",'' M312_CFS_NUMLCT "
	cSelect += ",'' M315_C1G_TPPROC,'' M315_C1G_NUMPRO "
	
	cSelect += ",'' M350_CH8_CODIGO,'' M350_CH8_DESCRI,'' M350_CH8_TPLANC,'' CHR_TIPORL,0 CHR_VLRLC,'' CHR_HISTLC "
	cSelect += ",'' M355_CFR_CODCTA,0 CHS_VLRLC,'' CHS_INDLC "
	cSelect += ",'' M360_C1O_CODIGO,'' M360_C1P_CODCUS,0 CHT_VLRLC,'' CHT_INDVLR "
	cSelect += ",'' M362_CFS_NUMLCT "
	cSelect += ",'' M365_C1G_TPPROC,'' M365_C1G_NUMPRO "
	
	cSelect += ",'' M410_CFR_CODCTA,'' CET_CODTRI,0 CET_VLRLC,'' CET_IDLCTO,'' M410_CTA_CODIGO,'' CET_HISTLC,'' CET_TRIDIF "
	cSelect += ",'' M415_C1G_TPPROC,'' M415_C1G_NUMPRO "
	cSelect += ",'' M500_CFR_CODCTA,'' CEV_CODTRI,0 CEV_VLRSLI,'' CEV_SITSLI,0 CEV_VLRPTA,'' CEV_STVLPA,0 CEV_VLRPTB,'' CEV_STVLPB,0 CEV_VLRFIN,'' CEV_SITFIN "

	cFrom := RetSqlName( "CEN" ) + " CEN "

	cFrom += "LEFT JOIN " + RetSqlName( "CEO" ) + " CEO "
	cFrom += "ON CEO.CEO_FILIAL=CEN.CEN_FILIAL "
	cFrom += "AND CEO.CEO_ID=CEN.CEN_ID "
	cFrom += "AND CEO.D_E_L_E_T_='' "

	cFrom += "LEFT JOIN " + RetSqlName( "CEP" ) + " CEP "
	cFrom += "ON CEP.CEP_FILIAL=CEO.CEO_FILIAL "
	cFrom += "AND CEP.CEP_ID=CEO.CEO_ID "
	cFrom += "AND CEP.CEP_IDCODL=CEO.CEO_IDCODL "
	cFrom += " AND CEP.D_E_L_E_T_='' "
	
	cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom += "AND CAH.D_E_L_E_T_='' "

	cFrom += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom += "AND CH8.CH8_ID=CEO.CEO_IDCODL "
	cFrom += "AND CH8.D_E_L_E_T_='' "

	cFrom += "LEFT JOIN " + RetSqlName( "CFR" ) + " CFR "
	cFrom += "ON CFR.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
	cFrom += "AND CFR.CFR_ID=CEP.CEP_IDCTA "
	cFrom += "AND CFR.D_E_L_E_T_='' "

	//cWhere := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CEN.D_E_L_E_T_='' "

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	//Registro M300, M310 e M312

	cSelect2 := " 'M300' REGISTRO,'M310' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect2 += ",CH8.CH8_CODIGO M300_CH8_CODIGO,CH8.CH8_DESCRI,CH8.CH8_TPLANC,CEO.CEO_TIPORL,CEO.CEO_VLRLC,CEO.CEO_HISTLC "
	cSelect2 += ",'',0,'' "
	cSelect2 += ",C1O.C1O_CODIGO,C1P.C1P_CODCUS,CEQ.CEQ_VLRLC,CEQ.CEQ_INDVLR "
	cSelect2 += ",CFS.CFS_NUMLCT "
	cSelect2 += ",'','' "
	
	cSelect2 += ",'' M350_CH8_CODIGO,'','','',0,'' "
	cSelect2 += ",'',0,'' "
	cSelect2 += ",'','',0,'' "
	cSelect2 += ",'' "
	cSelect2 += ",'','' "
	
	cSelect2 += ",'','',0,'','','','' "
	cSelect2 += ",'','' "
	cSelect2 += ",'','',0,'',0,'',0,'',0,'' "

	cFrom2 := RetSqlName( "CEN" ) + " CEN "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CEO" ) + " CEO "
	cFrom2 += "ON CEO.CEO_FILIAL=CEN.CEN_FILIAL "
	cFrom2 += "AND CEO.CEO_ID=CEN.CEN_ID "
	cFrom2 += "AND CEO.D_E_L_E_T_='' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CEQ" ) + " CEQ "
	cFrom2 += "ON CEQ.CEQ_FILIAL=CEO.CEO_FILIAL "
	cFrom2 += "AND CEQ.CEQ_ID=CEO.CEO_ID "
	cFrom2 += "AND CEQ.CEQ_IDCODL=CEO.CEO_IDCODL "
	cFrom2 += "AND CEQ.D_E_L_E_T_='' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CER" ) + " CER "
	cFrom2 += "ON CER.CER_FILIAL=CEQ.CEQ_FILIAL "
	cFrom2 += "AND CER.CER_ID=CEQ.CEQ_ID "
	cFrom2 += "AND CER.CER_IDCODL=CEQ.CEQ_IDCODL "
	cFrom2 += "AND CER.CER_CTA=CEQ.CEQ_CTA "
	cFrom2 += "AND CER.CER_CODCUS=CEQ.CEQ_CODCUS "
	cFrom2 += "AND CER.D_E_L_E_T_='' 

	cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom2 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom2 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom2 += "AND CAH.D_E_L_E_T_='' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom2 += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom2 += "AND CH8.CH8_ID=CEO.CEO_IDCODL "
	cFrom2 += "AND CH8.D_E_L_E_T_='' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom2 += "ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cFrom2 += "AND C1O.C1O_ID=CEQ.CEQ_CTA "
	cFrom2 += "AND C1O.D_E_L_E_T_='' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom2 += "ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
	cFrom2 += "AND C1P.C1P_ID=CEQ.CEQ_CODCUS "
	cFrom2 += "AND C1P.D_E_L_E_T_='' "
	
	cFrom2 += "LEFT JOIN " + RetSqlName( "CFS" ) + " CFS ON "
	//Tratamento necessário caso os lançamentos contábeis não sejam centralizados
	If __lECFCent
		cFrom2 += "CFS.CFS_FILIAL = '" + xFilial( "CFS" ) + "' AND "
	EndIf
	cFrom2 += "CFS.CFS_ID=CER.CER_IDNUML "
	cFrom2 += "AND CFS.D_E_L_E_T_='' "
	
	//cWhere2 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere2 := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere2 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere2 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere2 += "AND CEN.D_E_L_E_T_='' "

	cSelect2 := "%" + cSelect2 + "%"
	cFrom2   := "%" + cFrom2   + "%"
	cWhere2  := "%" + cWhere2  + "%"


	//Registro M300 e M315

	cSelect3 := " 'M300' REGISTRO,'M315' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect3 += ",CH8.CH8_CODIGO M300_CH8_CODIGO,CH8.CH8_DESCRI,CH8.CH8_TPLANC,CEO.CEO_TIPORL,CEO.CEO_VLRLC,CEO.CEO_HISTLC "
	cSelect3 += ",'',0,'' "
	cSelect3 += ",'','',0,'' "
	cSelect3 += ",'' "
	cSelect3 += ",C1G.C1G_TPPROC,C1G.C1G_NUMPRO "
	
	cSelect3 += ",'' M350_CH8_CODIGO,'','','',0,'' "
	cSelect3 += ",'',0,'' "
	cSelect3 += ",'','',0,'' "
	cSelect3 += ",'' "
	cSelect3 += ",'','' "
	
	cSelect3 += ",'','',0,'','','','' "
	cSelect3 += ",'','' "
	cSelect3 += ",'','',0,'',0,'',0,'',0,'' "

	cFrom3 := RetSqlName( "CEN" ) + " CEN "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CEO" ) + " CEO "
	cFrom3 += "ON CEO.CEO_FILIAL=CEN.CEN_FILIAL "
	cFrom3 += "AND CEO.CEO_ID=CEN.CEN_ID "
	cFrom3 += "AND CEO.D_E_L_E_T_='' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CES" ) + " CES "
	cFrom3 += "ON CES.CES_FILIAL=CEO.CEO_FILIAL "
	cFrom3 += "AND CES.CES_ID=CEO.CEO_ID "
	cFrom3 += "AND CES.CES_IDCODL=CEO.CEO_IDCODL "
	cFrom3 += "AND CES.D_E_L_E_T_='' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom3 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom3 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom3 += "AND CAH.D_E_L_E_T_='' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom3 += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom3 += "AND CH8.CH8_ID=CEO.CEO_IDCODL "
	cFrom3 += "AND CH8.D_E_L_E_T_='' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "C1G" ) + " C1G "
	cFrom3 += "ON C1G.C1G_FILIAL = '" + xFilial( "C1G" ) + "' "
	cFrom3 += "AND C1G.C1G_ID=CES.CES_IDPROC "
	cFrom3 += "AND C1G.D_E_L_E_T_='' "

	cWhere3 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere3 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere3 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere3 += "AND CEN.D_E_L_E_T_='' "

	cSelect3 := "%" + cSelect3 + "%"
	cFrom3   := "%" + cFrom3   + "%"
	cWhere3  := "%" + cWhere3  + "%"

	
	//Registro M350 e M355 

	cSelect4 := " 'M350' REGISTRO,'M355' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect4 += ",'' M300_CH8_CODIGO,'','','',0,'' "
	cSelect4 += ",'',0,'' "
	cSelect4 += ",'','',0,'' "
	cSelect4 += ",'' "
	cSelect4 += ",'','' "
	
	cSelect4 += ",CH8.CH8_CODIGO M350_CH8_CODIGO,CH8.CH8_DESCRI,CH8.CH8_TPLANC,CHR.CHR_TIPORL,CHR.CHR_VLRLC,CHR.CHR_HISTLC "
	cSelect4 += ",CFR.CFR_CODCTA,CHS.CHS_VLRLC,CHS.CHS_INDLC "
	cSelect4 += ",'','',0,'' "
	cSelect4 += ",'' "
	cSelect4 += ",'','' "
	
	cSelect4 += ",'','',0,'','','','' "
	cSelect4 += ",'','' "
	cSelect4 += ",'','',0,'',0,'',0,'',0,'' "

	cFrom4 := RetSqlName( "CEN" ) + " CEN "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CHR" ) + " CHR "
	cFrom4 += "ON CHR.CHR_FILIAL=CEN.CEN_FILIAL "
	cFrom4 += "AND CHR.CHR_ID=CEN.CEN_ID "
	cFrom4 += "AND CHR.D_E_L_E_T_='' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CHS" ) + " CHS "
	cFrom4 += "ON CHS.CHS_FILIAL=CHR.CHR_FILIAL "
	cFrom4 += "AND CHS.CHS_ID=CHR.CHR_ID "
	cFrom4 += "AND CHS.CHS_IDCODL=CHR.CHR_IDCODL "
	cFrom4 += "AND CHS.D_E_L_E_T_='' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom4 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom4 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom4 += "AND CAH.D_E_L_E_T_='' "
	
	cFrom4 += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom4 += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom4 += "AND CH8.CH8_ID=CHR.CHR_IDCODL "
	cFrom4 += "AND CH8.D_E_L_E_T_='' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CFR" ) + " CFR "
	cFrom4 += "ON CFR.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
	cFrom4 += "AND CFR.CFR_ID=CHS.CHS_IDCTA "
	cFrom4 += "AND CFR.D_E_L_E_T_='' "

	//cWhere4 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere4 := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere4 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere4 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere4 += "AND CEN.D_E_L_E_T_='' "

	cSelect4 := "%" + cSelect4 + "%"
	cFrom4   := "%" + cFrom4   + "%"
	cWhere4  := "%" + cWhere4  + "%"

	//Registro M350, M360 e M362

	cSelect5 := " 'M350' REGISTRO,'M360' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect5 += ",'' M300_CH8_CODIGO,'','','',0,'' "
	cSelect5 += ",'',0,'' "
	cSelect5 += ",'','',0,'' "
	cSelect5 += ",'' "
	cSelect5 += ",'','' "
	
	cSelect5 += ",CH8.CH8_CODIGO M350_CH8_CODIGO,CH8.CH8_DESCRI,CH8.CH8_TPLANC,CHR.CHR_TIPORL,CHR.CHR_VLRLC,CHR.CHR_HISTLC "
	cSelect5 += ",'',0,'' "
	cSelect5 += ",C1O.C1O_CODIGO,C1P.C1P_CODCUS,CHT.CHT_VLRLC,CHT.CHT_INDVLR "
	cSelect5 += ",CFS.CFS_NUMLCT"
	cSelect5 += ",'','' "
	
	cSelect5 += ",'','',0,'','','','' "
	cSelect5 += ",'','' "
	cSelect5 += ",'','',0,'',0,'',0,'',0,'' "

	cFrom5 := RetSqlName( "CEN" ) + " CEN "

	cFrom5 += "LEFT JOIN " + RetSqlName( "CHR" ) + " CHR "
	cFrom5 += "ON CHR.CHR_FILIAL=CEN.CEN_FILIAL "
	cFrom5 += "AND CHR.CHR_ID=CEN.CEN_ID "
	cFrom5 += "AND CHR.D_E_L_E_T_='' "
	
	cFrom5 += "LEFT JOIN " + RetSqlName( "CHT" ) + " CHT "
	cFrom5 += "ON CHT.CHT_FILIAL=CHR.CHR_FILIAL "
	cFrom5 += "AND CHT.CHT_ID=CHR.CHR_ID "
	cFrom5 += "AND CHT.CHT_IDCODL=CHR.CHR_IDCODL "
	cFrom5 += "AND CHT.D_E_L_E_T_='' "
	
	cFrom5 += "LEFT JOIN " + RetSqlName( "CHU" ) + " CHU "
	cFrom5 += "ON CHU.CHU_FILIAL=CHT.CHT_FILIAL "
	cFrom5 += "AND CHU.CHU_ID=CHT.CHT_ID "
	cFrom5 += "AND CHU.CHU_IDCODL=CHT.CHT_IDCODL "
	cFrom5 += "AND CHU.CHU_CTA=CHT.CHT_CTA "
	cFrom5 += "AND CHU.CHU_CODCUS=CHT.CHT_CODCUS "
	cFrom5 += "AND CHU.D_E_L_E_T_='' 
	
	cFrom5 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom5 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom5 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom5 += "AND CAH.D_E_L_E_T_='' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom5 += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom5 += "AND CH8.CH8_ID=CHR.CHR_IDCODL "
	cFrom5 += "AND CH8.D_E_L_E_T_='' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom5 += "ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cFrom5 += "AND C1O.C1O_ID=CHT.CHT_CTA "
	cFrom5 += "AND C1O.D_E_L_E_T_='' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom5 += "ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
	cFrom5 += "AND C1P.C1P_ID=CHT.CHT_CODCUS "
	cFrom5 += "AND C1P.D_E_L_E_T_='' "
	
	cFrom5 += "LEFT JOIN " + RetSqlName( "CFS" ) + " CFS ON "
	If __lECFCent
		cFrom5 += "CFS.CFS_FILIAL = '" + xFilial( "CFS" ) + "' AND "
	EndIf
	cFrom5 += "CFS.CFS_ID = CHU.CHU_IDNUML "
	cFrom5 += "AND CFS.D_E_L_E_T_ = '' "

	cWhere5 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere5 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere5 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere5 += "AND CEN.D_E_L_E_T_='' "

	cSelect5 := "%" + cSelect5 + "%"
	cFrom5   := "%" + cFrom5   + "%"
	cWhere5  := "%" + cWhere5  + "%"

	//Registro M350 e M365

	cSelect6 := " 'M350' REGISTRO,'M365' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect6 += ",'' M300_CH8_CODIGO,'','','',0,'' "
	cSelect6 += ",'',0,'' "
	cSelect6 += ",'','',0,'' "
	cSelect6 += ",'' "
	cSelect6 += ",'','' "
	
	cSelect6 += ",CH8.CH8_CODIGO M350_CH8_CODIGO,CH8.CH8_DESCRI,CH8.CH8_TPLANC,CHR.CHR_TIPORL,CHR.CHR_VLRLC,CHR.CHR_HISTLC "
	cSelect6 += ",'',0,'' "
	cSelect6 += ",'','',0,'' "
	cSelect6 += ",'' "
	cSelect6 += ",C1G.C1G_TPPROC,C1G.C1G_NUMPRO "
	
	cSelect6 += ",'','',0,'','','','' "
	cSelect6 += ",'','' "
	cSelect6 += ",'','',0,'',0,'',0,'',0,'' "
	
	cFrom6 := RetSqlName( "CEN" ) + " CEN "

	cFrom6 += "LEFT JOIN " + RetSqlName( "CHR" ) + " CHR "
	cFrom6 += "ON CHR.CHR_FILIAL=CEN.CEN_FILIAL "
	cFrom6 += "AND CHR.CHR_ID=CEN.CEN_ID "
	cFrom6 += "AND CHR.D_E_L_E_T_='' "
	
	cFrom6 += "LEFT JOIN " + RetSqlName( "CHV" ) + " CHV "
	cFrom6 += "ON CHV.CHV_FILIAL=CHR.CHR_FILIAL "
	cFrom6 += "AND CHV.CHV_ID=CHR.CHR_ID "
	cFrom6 += "AND CHV.CHV_IDCODL=CHR.CHR_IDCODL "
	cFrom6 += "AND CHV.D_E_L_E_T_='' "

	cFrom6 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom6 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom6 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom6 += "AND CAH.D_E_L_E_T_='' "

	cFrom6 += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
	cFrom6 += "ON CH8.CH8_FILIAL='" + xFilial( "CH8" ) + "' "
	cFrom6 += "AND CH8.CH8_ID=CHR.CHR_IDCODL "
	cFrom6 += "AND CH8.D_E_L_E_T_='' "
	
	cFrom6 += "LEFT JOIN " + RetSqlName( "C1G" ) + " C1G "
	cFrom6 += "ON C1G.C1G_FILIAL = '" + xFilial( "C1G" ) + "' "
	cFrom6 += "AND C1G.C1G_ID=CHV.CHV_IDPROC "
	cFrom6 += "AND C1G.D_E_L_E_T_='' "

	//cWhere6 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere6 := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere6 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere6 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere6 += "AND CEN.D_E_L_E_T_='' "

	cSelect6 := "%" + cSelect6 + "%"
	cFrom6   := "%" + cFrom6   + "%"
	cWhere6  := "%" + cWhere6  + "%"
	
	//Registro M410 e M415

	cSelect7 := " 'M410' REGISTRO,'M415' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect7 += ",'' M300_CH8_CODIGO,'','','',0,'' "
	cSelect7 += ",'',0,'' "
	cSelect7 += ",'','',0,'' "
	cSelect7 += ",'' "
	cSelect7 += ",'','' "
	
	cSelect7 += ",'' M350_CH8_CODIGO,'','','',0,'' "
	cSelect7 += ",'',0,'' "
	cSelect7 += ",'','',0,'' "
	cSelect7 += ",'' "
	cSelect7 += ",'','' "
	
	cSelect7 += ",CFRCTA.CFR_CODCTA,CET.CET_CODTRI,CET.CET_VLRLC,CET.CET_IDLCTO,CFRCTACP.CFR_CODCTA,CET.CET_HISTLC,CET_TRIDIF "
	cSelect7 += ",C1G.C1G_TPPROC,C1G.C1G_NUMPRO "
	cSelect7 += ",'','',0,'',0,'',0,'',0,'' "

	cFrom7 := RetSqlName( "CEN" ) + " CEN "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CET" ) + " CET "
	cFrom7 += "ON CET.CET_FILIAL=CEN.CEN_FILIAL "
	cFrom7 += "AND CET.CET_ID=CEN.CEN_ID "
	cFrom7 += "AND CET.D_E_L_E_T_='' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CEU" ) + " CEU "
	cFrom7 += "ON CEU.CEU_FILIAL=CET.CET_FILIAL "
	cFrom7 += "AND CEU.CEU_ID=CET.CET_ID "
	cFrom7 += "AND CEU.CEU_CTA=CET.CET_IDCTA "
	cFrom7 += "AND CEU.CEU_IDLCTO=CET.CET_IDLCTO "
	cFrom7 += "AND CEU.CEU_CTACP=CET.CET_IDCTAC "
	cFrom7 += "AND CEU.D_E_L_E_T_='' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom7 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom7 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom7 += "AND CAH.D_E_L_E_T_='' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CFR" ) + " CFRCTA "
	cFrom7 += "ON CFRCTA.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
	cFrom7 += "AND CFRCTA.CFR_ID=CET.CET_IDCTA "
	cFrom7 += "AND CFRCTA.D_E_L_E_T_='' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CFR" ) + " CFRCTACP "
	cFrom7 += "ON CFRCTACP.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
	cFrom7 += "AND CFRCTACP.CFR_ID=CET.CET_IDCTAC "
	cFrom7 += "AND CFRCTACP.D_E_L_E_T_='' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "C1G" ) + " C1G "
	cFrom7 += "ON C1G.C1G_FILIAL = '" + xFilial( "C1G" ) + "' "
	cFrom7 += "AND C1G.C1G_ID=CEU.CEU_IDPROC "
	cFrom7 += "AND C1G.D_E_L_E_T_='' "

	//cWhere7 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere7 := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere7 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere7 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere7 += "AND CEN.D_E_L_E_T_='' "

	cSelect7 := "%" + cSelect7 + "%"
	cFrom7   := "%" + cFrom7   + "%"
	cWhere7  := "%" + cWhere7  + "%"

	//Registro M500

	cSelect8 := " 'M500' REGISTRO,'M500' REG_FILHO,CEN.CEN_FILIAL,CEN.CEN_DTINI,CEN.CEN_DTFIN,CAH.CAH_CODIGO "
	cSelect8 += ",'' M300_CH8_CODIGO,'','','',0,'' "
	cSelect8 += ",'',0,'' "
	cSelect8 += ",'','',0,'' "
	cSelect8 += ",'' "
	cSelect8 += ",'','' "
	
	cSelect8 += ",'' M350_CH8_CODIGO,'','','',0,'' "
	cSelect8 += ",'',0,'' "
	cSelect8 += ",'','',0,'' "
	cSelect8 += ",'' "
	cSelect8 += ",'','' "
	
	cSelect8 += ",'','',0,'','','','' "
	cSelect8 += ",'','' "
	cSelect8 += ",CFR.CFR_CODCTA,CEV.CEV_CODTRI,CEV.CEV_VLRSLI,CEV.CEV_SITSLI,CEV.CEV_VLRPTA,CEV.CEV_STVLPA,CEV.CEV_VLRPTB,CEV.CEV_STVLPB,CEV.CEV_VLRFIN,CEV.CEV_SITFIN "

	cFrom8 := RetSqlName( "CEN" ) + " CEN "

	cFrom8 += "LEFT JOIN " + RetSqlName( "CEV" ) + " CEV "
	cFrom8 += "ON CEV.CEV_FILIAL=CEN.CEN_FILIAL "
	cFrom8 += "AND CEV.CEV_ID=CEN.CEN_ID "
	cFrom8 += "AND CEV.D_E_L_E_T_='' "

	cFrom8 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
	cFrom8 += "ON CAH.CAH_FILIAL='" + xFilial( "CAH" ) + "' "
	cFrom8 += "AND CAH.CAH_ID=CEN.CEN_IDPERA "
	cFrom8 += "AND CAH.D_E_L_E_T_='' "

	cFrom8 += "LEFT JOIN " + RetSqlName( "CFR" ) + " CFR "
	cFrom8 += "ON CFR.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
	cFrom8 += "AND CFR.CFR_ID=CEV.CEV_IDCTA "
	cFrom8 += "AND CFR.D_E_L_E_T_='' "

	//cWhere8 := " CEN.CEN_FILIAL IN(" + cFilSel + ") "
	cWhere8 := " CEN.CEN_FILIAL = '" + xFilial( "CEN" ) + "' "
	cWhere8 += "AND CEN.CEN_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere8 += "AND CEN.CEN_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere8 += "AND CEN.D_E_L_E_T_='' "

	cSelect8 := "%" + cSelect8 + "%"
	cFrom8   := "%" + cFrom8   + "%"
	cWhere8  := "%" + cWhere8  + "%"

	//Ordenacao da Query

	cOrderBy := "CEN_FILIAL,CAH_CODIGO,REGISTRO,M300_CH8_CODIGO,M350_CH8_CODIGO,REG_FILHO "

	cOrderBy := "%" + cOrderBy + "%"

EndIf

If cReg == "M010"

	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
		ORDER BY
			%Exp:cOrderBy%

	EndSql

ElseIf cReg == "M030"

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

		UNION

		SELECT
			%Exp:cSelect7%
		FROM
			%Exp:cFrom7%
		WHERE
			%Exp:cWhere7%

		UNION

		SELECT
			%Exp:cSelect8%
		FROM
			%Exp:cFrom8%
		WHERE
			%Exp:cWhere8%

		ORDER BY
			%Exp:cOrderBy%

	EndSql

EndIf

Return()
