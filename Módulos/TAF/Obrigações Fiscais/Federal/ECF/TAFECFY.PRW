#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFECFY

Rotina extratora da informacoes para o Bloco Y do ECF.

@Param	cTABCTL	->	Nome da tabela de controle de transações
		aWizard	->	Array com as informações da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do bloco - Multi Thread
		cIdPeriodo	->	ID do período de escrituração
		aContab	->	Contabilistas selecionados
		cECFAlias	->	Alias da tabela de informações geradas pelo ECF

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
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFY( cTABCTL, aWizard, cFilSel, cJobAux, cIdPeriodo, aContab, cECFAlias )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"Y" 
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegY520( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	IF aWizard[1][5] < '0007'
		//Registro foi excluído a partir do layout 0007
		RegY540( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		RegY550( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		RegY560( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	EndIF
	RegY570( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	IF aWizard[1][5] < '0007'
		//Registro foi excluído a partir do layout 0007
		RegY580( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	EndIF
	
	RegY590( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY600( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	IF aWizard[1][5]== '0001'
		//Registro foi excluído a partir de 2015
		RegY611( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	EndIF
	RegY612( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY620( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY630( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY640( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY660( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY665( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	IF aWizard[1][5] < '0007'
		RegY671( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	Endif
	Regy672( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY680( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY682( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	IF aWizard[1][5] < '0007'
		RegY690( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	Endif
	RegY700( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY720( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegY800( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, cECFAlias )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegY001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegY001

Rotina para extrair e gravar as informacoes do Registro Y001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "Y001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "Y001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY520

Rotina para extrair e gravar as informacoes do Registro Y520.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY520( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y520" )

//Registro Y520
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y520"																										//01 - REG
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CFQ_TIPEXT == "1", "R", Iif( ( cAliasQry )->CFQ_TIPEXT == "2", "P", "" ) )	//02 - TIP_EXT
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )																	//03 - PAIS
	cStrTxt += cDelimit + ( cAliasQry )->CFQ_FORMA																					//04 - FORMA
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->CHK_CODIGO )																		//05 - NAT_OPER
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFQ_VLPERI, 16, 2 )																//06 - VL_PERIODO
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y520", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY540

Rotina para extrair e gravar as informacoes do Registro Y540.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY540( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y540" )

//Registro Y540
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y540"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGH_CNPJ								//02 - CNPJ_ESTAB
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGH_VLREC, 16, 2 )		//03 - VL_REC_ESTAB
	cStrTxt += cDelimit + ( cAliasQry )->CZS_CODIGO							//04 - CNAE
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y540", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY550

Rotina para extrair e gravar as informacoes do Registro Y550.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY550( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y550" )

//Registro Y550
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y550"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGI_CNPJ								//02 - CNPJ_EXP
	cStrTxt += cDelimit + ( cAliasQry )->C0A_CODIGO							//03 - COD_NCM
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGI_VLVEND, 16, 2 )		//04 - VL_VENDA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y550", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY560

Rotina para extrair e gravar as informacoes do Registro Y560.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY560( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y560" )

//Registro Y560
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y560"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGJ_CNPJ								//02 - CNPJ
	cStrTxt += cDelimit + ( cAliasQry )->C0A_CODIGO							//03 - COD_NCM
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGJ_VLCOMP, 16, 2 )		//04 - VL_COMPRA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGJ_VLEXP, 16, 2 )		//05 - VL_EXP
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y560", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY570

Rotina para extrair e gravar as informacoes do Registro Y570.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY570( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y570" )

//Registro Y570
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y570"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CEX_CNPJ				 				//02 - CNPJ_FON
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CEX_NOMEMP)			//03 - NOM_EMP
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CEX_ORGPUB )			//04 - IND_ORG_PUB
	cStrTxt += cDelimit + ( cAliasQry )->CW9_CODIGO							//05 - COD_REC
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEX_RENDIM, 16, 2 )		//06 - VL_REND
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEX_IRRET, 16, 2 )		//07 - IR_RET
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEX_CSLLRE, 16, 2 )		//08 - CSLL_RET
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y570", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY580

Rotina para extrair e gravar as informacoes do Registro Y580.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY580( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y580" )

//Registro Y580
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y580"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGK_CNPJ								//02 - CNPJ
	cStrTxt += cDelimit + ( cAliasQry )->CGK_TIPBEN							//03 - TIP_BENEF
	cStrTxt += cDelimit + ( cAliasQry )->CGK_DOACAO							//04 - FORM_DOA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGK_VLDOA, 16, 2 )		//05 - VL_DOA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y580", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY590

Rotina para extrair e gravar as informacoes do Registro Y590.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY590( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y590" )

//Registro Y590
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y590"												//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CW6_CODIGO )			//02 - TIP_ATIVO
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )			//03 - PAIS
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGL_DISCRI )			//04 - DISCRIMINACAO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGL_VLANT, 16, 2 )		//05 - VL_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGL_VLATU, 16, 2 )		//06 - VL_ATUAL
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y590", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY600

Rotina para extrair e gravar as informacoes do Registro Y600.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY600( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cQualif   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y600" )

//Registro Y600
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	If ( cAliasQry )->CGM_QUASOC == "1"
		cQualif := "PF"
	ElseIf ( cAliasQry )->CGM_QUASOC == "2"
		cQualif := "PJ"
	ElseIf ( cAliasQry )->CGM_QUASOC == "3"
		cQualif := "FI"
	Else
		cQualif := ""
	EndIf

	cStrTxt := cDelimit + "Y600"												//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CGM_INCSOC )			//02 - DT_INCL_SOC
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CGM_FIMSOC )			//03 - DT_FIM_SOC
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )			//04 - PAIS
	cStrTxt += cDelimit + cQualif												//05 - IND_QUALIF_SOCIO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGM_CPFCNP )			//06 - CPF_CNPJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGM_NOMEMP )			//07 - NOM_EMP
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGN_CODIGO )			//08 - QUALIF
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_PERTOT, 8, 4 )		//09 - PERC_CAP_TOT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_PERVOT, 8, 4 )		//10 - PERC_CAP_VOT
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGM_CPFLEG )			//11 - CPF_REP_LEG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGM_QUALEG )			//12 - QUALIF_REP_LEG
	If TAFColumnPos("CGM_VLRMTR") .And. TAFColumnPos("CGM_VLLCDV") .And. ;
	   TAFColumnPos("CGM_JURCAP") .And. TAFColumnPos("CGM_VLDMRD") .And. ;
	   TAFColumnPos("CGM_VLIRRT") .And. ;
	   aWizard[1,1] >= CToD( "01/12/2015" ) .And. aWizard[1,2] >= CToD( "01/12/2015" )
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_VLRMTR, 16,2 )			//13 - VL_REM_TRAB
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_VLLCDV, 16,2 )			//14 - VL_LUC_DIV
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_JURCAP, 16,2 )			//15 - VL_JUR_CAP
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_VLDMRD, 16,2 )			//16 - VL_DEM_REND
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGM_VLIRRT, 16,2 )			//17 - VL_IR_RET
	EndIf
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y600", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY611

Rotina para extrair e gravar as informacoes do Registro Y611.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY611( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y611" )

//Registro Y611
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y611"														//01 - REG
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )					//02 - PAIS
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CEM_PESSOA == "1", "PF", "PJ" )		//03 - IND_PF_PJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CEM_CNPJ )						//04 - CPF_CNPJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CEM_NOMEMP )					//05 - NOM_EMP
	cStrTxt += cDelimit + ( cAliasQry )->CGN_CODIGO									//06 - QUALIF
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEM_REMTRA, 16, 2 )				//07 - VL_REM_TRAB
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEM_LUCDIV, 16, 2 )				//08 - VL_LUC_DIV
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEM_JURCAP, 16, 2 )				//09 - VL_JUR_CAP
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEM_DEMREN, 16, 2 )				//10 - VL_DEM_REND
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEM_IRRET, 16, 2 )				//11 - VL_IR_RET
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y611", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY612

Rotina para extrair e gravar as informacoes do Registro Y612.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY612( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y612" )

//Registro Y612
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y612"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGO_CPF								//02 - CPF
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGO_NOME )				//03 - NOME
	cStrTxt += cDelimit + ( cAliasQry )->CGN_CODIGO							//04 - QUALIF
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGO_VLREN, 16, 2 )		//05 - VL_REM_TRAB
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGO_VLDEM, 16, 2 )		//06 - VL_DEM_REND
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGO_VLIR, 16, 2 )		//07 - VL_IR_RET
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y612", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY620

Rotina para extrair e gravar as informacoes do Registro Y620.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY620( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y620" )

//Registro Y620
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y620"												//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CGP_DTEVEN )			//02 - DT_EVENTO
	cStrTxt += cDelimit + ( cAliasQry )->CGP_INDREL							//03 - IND_RELAC
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )			//04 - PAIS
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGP_CNPJ )				//05 - CNPJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGP_NOMEMP )			//06 - NOM_EMP
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGP_VALREA, 16, 2 )		//07 - VALOR_REAIS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGP_VALORI, 16, 2 )		//08 - VALOR_ESTR
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGP_PERTOT, 8, 4 )		//09 - PERC_CAP_TOT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGP_PERVOT, 8, 4 )		//10 - PERC_CAP_VOT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGP_RESPAT, 16, 2 )		//11 - RES_EQ_PAT
	cStrTxt += cDelimit + Dt2Caract( (cAliasQry )->CGP_DTAQUI )				//12 - DATA_AQUIS
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CGP_INDCAR )			//13 - IND_PROC_CART
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->CGP_NUMCAR )				//14 - NUM_PROC_CART
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->CGP_NOMCAR )				//15 - NOME_CART
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CGP_INDRFB )			//16 - IND_PROC_RFB
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->CGP_NUMRFB )				//17 - NUM_PROC_RFB
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y620", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY630

Rotina para extrair e gravar as informacoes do Registro Y630.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY630( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y630" )

//Registro Y630
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y630"												//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGQ_CNPJ								//02 - CNPJ
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGQ_QUOTIS, 12, 0 )		//03 - QTE_QUOT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGQ_QUOTA, 12, 0 )		//04 - QTE_QUOTA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGQ_PATRIM, 16, 2 )		//05 - PATR_FIN_PER
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CGQ_DTABER )			//06 - DAT_ABERT
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CGQ_DTENCE )			//07 - DAT_ENCER
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y630", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY640

Rotina para extrair e gravar as informacoes do Registro Y640 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY640( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cLoop     := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y640" )

//Registro Y640
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y640"												//01 - REG
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGR_CNPJCO)				//02 - CNPJ
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGR_CONDDE)				//03 - COND_DECL
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGR_VLCONS, 16, 2 )		//04 - VL_CONS
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGR_CNPJLI)				//05 - CNPJ_LID
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGR_VLDECL, 16, 2 )		//06 - VL_DECL
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y640", cStrTxt )

	nSeq ++

	cLoop := ( cAliasQry )->CGR_ID

	//Registro Y650
	While ( cAliasQry )->(!Eof()) .And. (cAliasQry)->CGR_ID == cLoop
	
		If !Empty(AllTrim((cAliasQry)->CGS_CNPJEM))
		
			cStrTxt := cDelimit + "Y650"												//01 - REG
			cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGS_CNPJEM)				//02 - CNPJ
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGS_VLPART, 16, 2 )		//03 - VL_PART
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, "Y650", cStrTxt )

			nSeq ++
		EndIf

		( cAliasQry )->( DBSkip() )
	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY660

Rotina para extrair e gravar as informacoes do Registro Y660.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY660( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y660" )

//Registro Y660
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y660"												//01 - REG
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGT_CNPJ)					//02 - CNPJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CGT_NOMEMP )			//03 - NOM_EMP
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGT_PERPAT, 5, 2 )		//04 - PERC_PAT_LIQ
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y660", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY665

Rotina para extrair e gravar as informacoes do Registro Y665.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 03/12/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY665( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()
Local cMetCtl   := ""

ECFQryY( cAliasQry, aWizard, cFilSel, "Y665" )

//Registro Y665
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	If ( cAliasQry )->CHF_MTDCTL == "1"
		cMetCtl := "A"
	ElseIf ( cAliasQry )->CHF_MTDCTL == "2"
		cMetCtl := "B"
	ElseIf ( cAliasQry )->CHF_MTDCTL == "3"
		cMetCtl := "C"
	ElseIf ( cAliasQry )->CHF_MTDCTL == "4"
		cMetCtl := "D"
	ElseIf ( cAliasQry )->CHF_MTDCTL == "5"
		cMetCtl := "E"
	ElseIf ( cAliasQry )->CHF_MTDCTL == "6"
		cMetCtl := "F"
	EndIf

	cStrTxt := cDelimit + "Y665"																				//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C1O_CODIGO )												//02 - COD_CTA
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CTA_C1P_CODCUS )											//03 - COD_CCUS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHF_VLSDSC, 16, 2 )											//04 - VL_SALDO_SOC
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CHF_INDSOC == "1", "D", "C" )										//05 - IND_VL_SALDO_SOC
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHF_VLSDFI, 16, 2 )											//06 - VL_SALDO_FIS
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CHF_INDFIS == "1", "D", "C" )										//07 - IND_VL_SALDO_FIS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHF_VLDFSD, 16, 2 )											//08 - DIF_SALDOS
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CHF_INDDIF == "1", "D", "C" )										//09 - IND_DIF_SALDOS
	cStrTxt += cDelimit + TAFConType( cMetCtl )																	//10 - MET_CONTR
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHF_CODSUB )												//11 - COD_SUBCONT
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->SUB_C1P_CODCUS )											//12 - COD_CCUS_SUB
	cStrTxt += cDelimit + Iif( TAFColumnPos( "CHF_SUBAUX" ) , TAFConType( ( cAliasQry )->CHF_SUBAUX ) , "" )	//13 - COD_SUBCONT_ AUX
	cStrTxt += cDelimit + Iif( TAFColumnPos( "CHF_CUSAUX" ) , TAFConType( ( cAliasQry )->CHF_CUSAUX ) , "" )	//14 - COD_CCUS_SUB_AUX
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y665", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY671

Rotina para extrair e gravar as informacoes do Registro Y671.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY671( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y671" )

//Registro Y671
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y671"												//01 - REG
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_AQMAQ, 16, 2 )		//02 - VL_AQ_MAQ
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_DOACRI, 16, 2 )		//03 - VL_DOA_CRIANCA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_DOAIDO, 16, 2 )		//04 - VL_DOA_IDOSO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_AQATIV, 16, 2 )		//05 - VL_AQ_IMOBILIZADO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_BXATIV, 16, 2 )		//06 - VL_BX_IMOBILIZADO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_BINCIN, 16, 2 )		//07 - VL_INC_INI
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_BINCFI, 16, 2 )		//08 - VL_INC_FIN
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_CRCSLL, 16, 2 )		//09 - VL_CSLL_DEPREC_INI
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_CBSIOF, 16, 2 )		//10 - VL_OC_SEM_IOF
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_FHALRE, 16, 2 )		//11 - VL_FOLHA_ALIQ_RED
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGU_ALQRED, 16, 2 )		//12 - VL_ALIQ_RED
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGU_ALTCAP)				//13 - IND_ALTER_CAPITAL
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGU_OBNCSL)				//14 - IND_BCN_CSLL
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y671", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY672

Rotina para extrair e gravar as informacoes do Registro Y672.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY672( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y672" )

While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y672"												//01 - REG
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CAPANT, 16, 2 )		//02 - VL_CAPITAL_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CAPITA, 16, 2 )		//03 - VL_CAPITAL
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_ESTANT, 16, 2 )		//04 - VL_ESTOQUE_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_ESTOQU, 16, 2 )		//05 - VL_ESTOQUES
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CAIANT, 16, 2 )		//06 - VL_CAIXA_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CAIXA, 16, 2 )		//07 - VL_CAIXA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_APLANT, 16, 2 )		//08 - VL_APLIC_FIN_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_APLFIN, 16, 2 )		//09 - VL_APLIC_FIN
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CTRANT, 16, 2 )		//10 - VL_CTA_REC_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CTAREC, 16, 2 )		//11 - VL_CTA_REC
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CTPANT, 16, 2 )		//12 - VL_CTA_PAG_ANT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_CTAPAG, 16, 2 )		//13 - VL_CTA_PAG
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_COMMER, 16, 2 )		//14 - VL_COMPRA_MERC
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_COMATI, 16, 2 )		//15 - VL_COMPRA_ATIVO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_RECEIT, 16, 2 )		//16 - VL_RECEITAS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_TOTATI, 16, 2 )		//17 - TOT_ATIVO
	
	If aWizard[1][5] < '0005'
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_FOLHA, 16, 2 )		//18 - VL_FOLHA
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGV_ALQRED, 5, 2 )		//19 - VL_ALIQ_RED
	EndIf

	If aWizard[1][5] < '0003'
		cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGV_REGAPU)				//20 - IND_REG_APUR
	EndIf
	
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGV_INDEST)				// If ( aWizard[1][5] < '0002', 21 - IND_AVAL_ESTOQ, 20 - IND_AVAL_ESTOQ)  
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y672", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY680

Rotina para extrair e gravar as informacoes do Registro Y680 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY680( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cLoop     := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y680" )

//Registro Y680
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y680"						//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CGW_MES		//02 - MES
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y680", cStrTxt )

	nSeq ++

	cLoop := ( cAliasQry )->CGW_MES

	//Registro Y681
	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CGW_MES == cLoop

		cStrTxt := cDelimit + "Y681"												//01 - REG
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_CODIGO )			//02 - CODIGO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_DESCRI )			//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGX_VALOR, 16, 2 )		//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "Y681", cStrTxt )

		nSeq ++

		( cAliasQry )->( DBSkip() )
	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY682

Rotina para extrair e gravar as informacoes do Registro Y682.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY682( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y682" )

//Registro Y682
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y682"												//01 - REG
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGY_MES)					//02 - MES
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGY_ACRPAT, 16, 2 )		//03 - ACRES_PATR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y682", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY690

Rotina para extrair e gravar as informacoes do Registro Y690.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 24/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY690( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y690" )

//Registro Y690
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y690"												//01 - REG
	cStrTxt += cDelimit + AllTrim(( cAliasQry )->CGZ_MES)					//02 - MES
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CGZ_RECBRU, 16, 2 )		//03 - VL_REC_BRU
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y690", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY700

Rotina para extrair e gravar as informações do Registro Y700.

@Param	aECFInfo	->	Informações gerais para tabela de controle de transações
		nSeq		->	Seqüência de gravação do Bloco
		aWizard	->	Array com as informações da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cIndMov	->	Indicador de movimento do bloco

@Author	Felipe C. Seolin
@Since		28/09/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function RegY700( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit	:=	"|"
Local cStrTxt		:=	""
Local cLoop		:=	""
Local cAliasQry	:=	GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y700" )

//Registro Y700
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cLoop := ( cAliasQry )->T27RECNO

	T27->( DBGoTo( cLoop ) )

	cStrTxt := cDelimit + "Y700"								//01 - REG
	cStrTxt += cDelimit + TAFConType( T27->T27_NUMDOS )		//02 - NUM_EDOSSIE
	cStrTxt += cDelimit + Dt2Caract( T27->T27_DTINAT )		//03 - DT_INI_ATO
	cStrTxt += cDelimit + Dt2Caract( T27->T27_DTFNAT )		//04 - DT_FIN_ATO
	cStrTxt += cDelimit + TAFConType( T27->T27_ANOINI )		//05 - ANO_INI
	cStrTxt += cDelimit + TAFConType( T27->T27_ANOFIN )		//06 - ANO_FIN
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDODB )		//07 - OP_PDEP_BRASIL
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDODE )		//08 - OP_PDEP_EXT_TNF
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDOER )		//09 - OP_PDEP_EXT_TF
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDOIB )		//10 - OP_PINDEP_BRASIL
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDOIE )		//11 - OP_PINDEP_EXT_TNF
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDOID )		//12 - OP_PINDEP_EXT_TF
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDGAF )		//13 - GER_ATIV_FISCAL
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDRSO )		//14 - REORG_SOC
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDGPT )		//15 - GER_PAS_TERC
	cStrTxt += cDelimit + T27->T27_INDBGP						//16 - BENEF_GER_PAS
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDRBT )		//17 - REDUC_BASE_TRIB
	cStrTxt += cDelimit + xFunTrcSN( T27->T27_INDRAT )		//18 - REDUC_ATIVO
	cStrTxt += cDelimit + Val2Str( T27->T27_PERCRA, 6, 2 )	//19 - PERC_REDUC_ATIVO
	cStrTxt += cDelimit + TAFConType( T27->T27_DSCSUM )		//20 - DESC_SUM
	cStrTxt += cDelimit + TAFConType( T27->T27_FUNJUR )		//21 - FUND_JUR
	cStrTxt += cDelimit + TAFConType( T27->T27_JSTSUM )		//22 - FUND_JUST_SUM
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y700", cStrTxt )

	nSeq ++

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->T27RECNO == cLoop

		If !Empty( ( cAliasQry )->T26_CODIGO + ( cAliasQry )->T28_ANOTRB )

			cStrTxt := cDelimit + "Y710"											//01 - REG
			cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T26_CODIGO )		//02 - COD_TRIB
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T28_VLRTRB, 16, 2 )	//03 - VL_TRIB
			cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T28_ANOTRB )		//04 - ANO
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, "Y710", cStrTxt )

			nSeq ++
		EndIf

		( cAliasQry )->( DBSkip() )
	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY720

Rotina para extrair e gravar as informações do Registro Y720.

@Param	aECFInfo	->	Informações gerais para tabela de controle de transações
		nSeq		->	Seqüência de gravação do Bloco
		aWizard	->	Array com as informações da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cIndMov	->	Indicador de movimento do bloco

@Author	Felipe C. Seolin
@Since		28/09/2015
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function RegY720( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y720" )

//Registro Y720
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "Y720"										//01 - REG
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T29_VLRLUC, 16, 2 )	//02 - LUC_LIQ
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->T29_DTLUCL )		//03 - DT_LUC_LIQ
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T29_VLRREC, 16, 2 )	//04 - REC_BRUT_ANT
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T29_ITMCAO )		//05 - INTIMACAO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->T29_INTATR )		//06 - INT_ATRASO
	Endif

	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "Y720", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegY800

Rotina para extrair e gravar as informacoes do Registro Y800.

@Param	aECFInfo	->	Informações gerais para tabela de controle de transações
		nSeq		->	Seqüência de gravação do bloco
		aWizard	->	Array com as informações da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cIndMov	->	Indicador de movimento do bloco
		cECFAlias	->	Alias da tabela de informações geradas pelo ECF

@Author Felipe C. Seolin
@Since 07/10/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegY800( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, cECFAlias )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryY( cAliasQry, aWizard, cFilSel, "Y800" )

//Registro Y800
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	CH9->( DBGoTo( ( cAliasQry )->RECNO ) )

	cStrTxt := cDelimit + "Y800"						//01 - REG
	If aWizard[1][5] > '0002'// campos substituidos no laiaute 0003
		cStrTxt += cDelimit + AllTrim( CH9->CH9_TIPDOC )	//02 - TIPO_DOC 
		cStrTxt += cDelimit + AllTrim( CH9->CH9_DESC )	//03 - DESCRICAO  
		cStrTxt += cDelimit 									//4 – HASH Este campo não deve ser informado no arquivo de importação pois será calculado pelo sistema
		cStrTxt += cDelimit + AllTrim( CH9->CH9_ARQRTF )	//05 - ARQ_RTF
		cStrTxt += cDelimit + "Y800FIM"						//06 - IND_FIM_RTF 
	Else
		cStrTxt += cDelimit + AllTrim( CH9->CH9_ARQRTF )	//02 - ARQ_RTF
		cStrTxt += cDelimit + "Y800FIM"						//03 - IND_FIM_RTF
	EndIf
	cStrTxt += cDelimit

	If RecLock( cECFAlias, .T. )

		( cECFAlias )->FILIAL	:=	aECFInfo[1]
		( cECFAlias )->PERINI	:=	SToD( aECFInfo[2] )
		( cECFAlias )->PERFIN	:=	SToD( aECFInfo[3] )
		( cECFAlias )->BLOCO		:=	aECFInfo[4]
		( cECFAlias )->REGSEQ	:=	StrZero( nSeq, 10 )
		( cECFAlias )->REGISTRO	:=	"Y800"
		( cECFAlias )->LINREG	:=	cStrTxt

		( cECFAlias )->( MsUnlock() )
	EndIf

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryY

Executa as Querys para a extracao do Bloco Y do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento
       cReg      -> Indica para qual Registro se refere a Query

@Author Felipe C. Seolin
@Since 23/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryY( cAliasQry, aWizard, cFilSel, cReg )

Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrderBy := ""
Local lVer007Cp:=  Iif(FindFunction("TAFECFVer"), TAFECFVer("0007"), TAFColumnPos("T29_ITMCAO"))

If cReg == "Y520"

	cSelect := "CFQ.CFQ_TIPEXT, C08.C08_PAISSX, CFQ.CFQ_FORMA, CHK.CHK_CODIGO, CFQ.CFQ_VLPERI "

	cFrom := RetSqlName( "CFQ" ) + " CFQ "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CFQ.CFQ_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1N" ) + " C1N "
	cFrom += "  ON C1N.C1N_FILIAL = '" + xFilial( "C1N" ) + "' "
	cFrom += " AND C1N.C1N_ID = CFQ.CFQ_NATOPE "
	cFrom += " AND C1N.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CHK" ) + " CHK "
	cFrom += "  ON CHK.CHK_FILIAL = '" + xFilial( "CHK" ) + "' "
	cFrom += " AND CHK.CHK_ID = C1N.C1N_IDNATE  "
	cFrom += " AND CHK.D_E_L_E_T_ = '' "

	//cWhere := "    CFQ.CFQ_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CFQ.CFQ_FILIAL = '" + xFilial( "CFQ" ) + "' "
	cWhere += "AND CFQ.CFQ_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFQ.D_E_L_E_T_ = '' "

	cOrderBy := "CFQ_FILIAL, CFQ_PERIOD "

ElseIf cReg == "Y540"

	cSelect := "CGH.CGH_CNPJ, CGH.CGH_VLREC, CZS.CZS_CODIGO "

	cFrom := RetSqlName( "CGH" ) + " CGH "

	cFrom += "LEFT JOIN " + RetSqlName( "CZS" ) + " CZS "
	cFrom += "  ON CZS.CZS_FILIAL = '" + xFilial( "CZS" ) + "' "
	cFrom += " AND CZS.CZS_ID = CGH.CGH_IDCNAE  "
	cFrom += " AND CZS.D_E_L_E_T_ = '' "

	//cWhere := "    CGH.CGH_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGH.CGH_FILIAL = '" + xFilial( "CGH" ) + "' "
	cWhere += "AND CGH.CGH_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGH.D_E_L_E_T_ = '' "

	cOrderBy := "CGH_FILIAL, CGH_PERIOD "

ElseIf cReg == "Y550"

	cSelect := "CGI.CGI_CNPJ, C0A.C0A_CODIGO, CGI.CGI_VLVEND "

	cFrom := RetSqlName( "CGI" ) + " CGI "

	cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
	cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
	cFrom += " AND C0A.C0A_ID = CGI.CGI_CODNCM "
	cFrom += " AND C0A.D_E_L_E_T_ = '' "

	//cWhere := "    CGI.CGI_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGI.CGI_FILIAL = '" + xFilial( "CGI" ) + "' "
	cWhere += "AND CGI.CGI_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGI.D_E_L_E_T_ = '' "

	cOrderBy := "CGI_FILIAL, CGI_PERIOD "

ElseIf cReg == "Y560"

	cSelect := "CGJ.CGJ_CNPJ, C0A.C0A_CODIGO, CGJ.CGJ_VLCOMP, CGJ.CGJ_VLEXP "

	cFrom := RetSqlName( "CGJ" ) + " CGJ "

	cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
	cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
	cFrom += " AND C0A.C0A_ID = CGJ.CGJ_CODNCM "
	cFrom += " AND C0A.D_E_L_E_T_ = '' "

	//cWhere := "    CGJ.CGJ_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGJ.CGJ_FILIAL = '" + xFilial( "CGJ" ) + "' "
	cWhere += "AND CGJ.CGJ_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGJ.D_E_L_E_T_ = '' "

	cOrderBy := "CGJ_FILIAL, CGJ_PERIOD "

ElseIf cReg == "Y570"

	cSelect := "CEX.CEX_CNPJ, CEX.CEX_NOMEMP, CEX.CEX_ORGPUB, CW9.CW9_CODIGO, CEX.CEX_RENDIM, CEX.CEX_IRRET, CEX.CEX_CSLLRE"

	cFrom := RetSqlName( "CEX" ) + " CEX "

	cFrom += "LEFT JOIN " + RetSqlName( "CW9" ) + " CW9 "
	cFrom += "  ON CW9.CW9_FILIAL = '" + xFilial( "CW9" ) + "' "
	cFrom += " AND CW9.CW9_ID = CEX.CEX_IDREC "
	cFrom += " AND CW9.D_E_L_E_T_ = '' "

	//cWhere := "    CEX.CEX_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CEX.CEX_FILIAL = '" + xFilial( "CEX" ) + "' "
	cWhere += "AND CEX.CEX_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CEX.D_E_L_E_T_ = '' "

	cOrderBy := "CEX_FILIAL, CEX_PERIOD "

ElseIf cReg == "Y580"

	cSelect := "CGK.CGK_CNPJ, CGK.CGK_TIPBEN, CGK.CGK_DOACAO, CGK.CGK_VLDOA "

	cFrom := RetSqlName( "CGK" ) + " CGK "

	//cWhere := "    CGK.CGK_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGK.CGK_FILIAL = '" + xFilial( "CGK" ) + "' "
	cWhere += "AND CGK.CGK_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGK.D_E_L_E_T_ = '' "

	cOrderBy := "CGK_FILIAL, CGK_PERIOD "

ElseIf cReg == "Y590"

	cSelect := "CW6.CW6_CODIGO, C08.C08_PAISSX, CGL.CGL_DISCRI, CGL.CGL_VLANT, CGL.CGL_VLATU "

	cFrom := RetSqlName( "CGL" ) + " CGL "

	cFrom += "LEFT JOIN " + RetSqlName( "CW6" ) + " CW6 "
	cFrom += "  ON CW6.CW6_FILIAL = '" + xFilial( "CW6" ) + "' "
	cFrom += " AND CW6.CW6_ID = CGL.CGL_IDTATV "
	cFrom += " AND CW6.D_E_L_E_T_ = '' "


	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CGL.CGL_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	//cWhere := "    CGL.CGL_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGL.CGL_FILIAL = '" + xFilial( "CGL" ) + "' "
	cWhere += "AND CGL.CGL_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGL.D_E_L_E_T_ = '' "

	cOrderBy := "CGL_FILIAL, CGL_PERIOD "

ElseIf cReg == "Y600"

	cSelect := "CGM.CGM_INCSOC, CGM.CGM_FIMSOC, C08.C08_PAISSX, CGM.CGM_QUASOC, CGM.CGM_CPFCNP, CGM.CGM_NOMEMP, CGN.CGN_CODIGO, CGM.CGM_PERTOT, CGM.CGM_PERVOT, CGM.CGM_CPFLEG, CGM.CGM_QUALEG "
	 If TAFColumnPos("CGM_VLRMTR") .AND. TAFColumnPos("CGM_VLLCDV") .AND. TAFColumnPos("CGM_JURCAP") .AND. TAFColumnPos("CGM_VLDMRD") .AND. TAFColumnPos("CGM_VLIRRT")
		cSelect += " , CGM.CGM_VLRMTR, CGM.CGM_VLLCDV, CGM.CGM_JURCAP, CGM.CGM_VLDMRD, CGM.CGM_VLIRRT "
    EndIf
	cFrom := RetSqlName( "CGM" ) + " CGM "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CGM.CGM_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CGN" ) + " CGN "
	cFrom += "  ON CGN.CGN_FILIAL = '" + xFilial( "CGN" ) + "' "
	cFrom += " AND CGN.CGN_ID = CGM.CGM_IDQUAL "
	cFrom += " AND CGN.D_E_L_E_T_ = '' "

	//cWhere := "    CGM.CGM_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGM.CGM_FILIAL = '" + xFilial( "CGM" ) + "' "
	cWhere += "AND CGM.CGM_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGM.D_E_L_E_T_ = '' "

	cOrderBy := "CGM_FILIAL, CGM_PERIOD "

ElseIf cReg == "Y611"

	cSelect := "C08.C08_PAISSX, CEM.CEM_PESSOA, CEM.CEM_CNPJ, CEM.CEM_NOMEMP, CGN.CGN_CODIGO, CEM.CEM_REMTRA, CEM.CEM_LUCDIV, CEM.CEM_JURCAP, CEM.CEM_DEMREN, CEM.CEM_IRRET "

	cFrom := RetSqlName( "CEM" ) + " CEM "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CEM.CEM_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CGN" ) + " CGN "
	cFrom += "  ON CGN.CGN_FILIAL = '" + xFilial( "CGN" ) + "' "
	cFrom += " AND CGN.CGN_ID = CEM.CEM_IDQUAL "
	cFrom += " AND CGN.D_E_L_E_T_ = '' "

	//cWhere := "    CEM.CEM_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CEM.CEM_FILIAL = '" + xFilial( "CEM" ) + "' "
	cWhere += "AND CEM.CEM_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CEM.D_E_L_E_T_ = '' "

	cOrderBy := "CEM_FILIAL, CEM_PERIOD "

ElseIf cReg == "Y612"

	cSelect := "CGO.CGO_CPF, CGO.CGO_NOME, CGN.CGN_CODIGO, CGO.CGO_VLREN, CGO.CGO_VLDEM, CGO.CGO_VLIR "

	cFrom := RetSqlName( "CGO" ) + " CGO "

	cFrom += "LEFT JOIN " + RetSqlName( "CGN" ) + " CGN "
	cFrom += "  ON CGN.CGN_FILIAL = '" + xFilial( "CGN" ) + "' "
	cFrom += " AND CGN.CGN_ID = CGO.CGO_IDQUA "
	cFrom += " AND CGN.D_E_L_E_T_ = '' "

	//cWhere := "    CGO.CGO_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGO.CGO_FILIAL = '" + xFilial( "CGO" ) + "' "
	cWhere += "AND CGO.CGO_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGO.D_E_L_E_T_ = '' "

	cOrderBy := "CGO_FILIAL, CGO_PERIOD "

ElseIf cReg == "Y620"

	cSelect := "CGP.CGP_DTEVEN, CGP.CGP_INDREL, C08.C08_PAISSX, CGP.CGP_CNPJ, CGP.CGP_NOMEMP, CGP.CGP_VALREA, CGP.CGP_VALORI, CGP.CGP_PERTOT "
	cSelect += ", CGP.CGP_PERVOT, CGP.CGP_RESPAT, CGP.CGP_DTAQUI, CGP.CGP_INDCAR, CGP.CGP_NUMCAR, CGP.CGP_NOMCAR, CGP.CGP_INDRFB, CGP.CGP_NUMRFB "

	cFrom := RetSqlName( "CGP" ) + " CGP "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CGP.CGP_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	//cWhere := "    CGP.CGP_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGP.CGP_FILIAL = '" + xFilial( "CGP" ) + "' "
	cWhere += "AND CGP.CGP_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGP.D_E_L_E_T_ = '' "

	cOrderBy += "CGP_FILIAL, CGP_PERIOD "

ElseIf cReg == "Y630"

	cSelect := "CGQ.CGQ_CNPJ, CGQ.CGQ_QUOTIS, CGQ.CGQ_QUOTA, CGQ.CGQ_PATRIM, CGQ.CGQ_DTABER, CGQ.CGQ_DTENCE "

	cFrom := RetSqlName( "CGQ" ) + " CGQ "

	//cWhere := "    CGQ.CGQ_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGQ.CGQ_FILIAL = '" + xFilial( "CGQ" ) + "' "
	cWhere += "AND CGQ.CGQ_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGQ.D_E_L_E_T_ = '' "

	cOrderBy := "CGQ_FILIAL, CGQ_PERIOD "

ElseIf cReg == "Y640"

	cSelect := "  CGR.CGR_ID , CGR.CGR_CNPJCO, CGR.CGR_CONDDE, CGR.CGR_VLCONS, CGR.CGR_CNPJLI, CGR.CGR_VLDECL "
	cSelect += ", CGS.CGS_CNPJEM  , CGS.CGS_VLPART"

	cFrom := RetSqlName( "CGR" ) + " CGR "

	cFrom += "LEFT JOIN " + RetSqlName( "CGS" ) + " CGS "
	cFrom += "  ON CGS.CGS_FILIAL = CGR.CGR_FILIAL "
	cFrom += " AND CGS.CGS_ID = CGR.CGR_ID "
	cFrom += " AND CGS.D_E_L_E_T_ = '' "

	//cWhere := "    CGR.CGR_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGR.CGR_FILIAL = '" + xFilial( "CGR" ) + "' "
	cWhere += "AND CGR.CGR_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGR.D_E_L_E_T_ = '' "

	cOrderBy := "CGR_FILIAL, CGR_PERIOD "

ElseIf cReg == "Y660"

	cSelect := "CGT.CGT_CNPJ, CGT.CGT_NOMEMP, CGT.CGT_PERPAT "

	cFrom := RetSqlName( "CGT" ) + " CGT "

	//cWhere := "    CGT.CGT_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGT.CGT_FILIAL = '" + xFilial( "CGT" ) + "' "
	cWhere += "AND CGT.CGT_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGT.D_E_L_E_T_ = '' "

	cOrderBy := "CGT_FILIAL, CGT_PERIOD "

ElseIf cReg == "Y665"

	cSelect := "C1O.C1O_CODIGO, C1P.C1P_CODCUS CTA_C1P_CODCUS, CHF.CHF_VLSDSC, CHF.CHF_INDSOC, CHF.CHF_VLSDFI, CHF.CHF_INDFIS, CHF.CHF_VLDFSD, CHF.CHF_INDDIF, CHF.CHF_MTDCTL, CHF.CHF_CODSUB , C1PSUB.C1P_CODCUS SUB_C1P_CODCUS "
	
	If TAFColumnPos( "CHF_SUBAUX" ) .And. TAFColumnPos( "CHF_CUSAUX" )
		cSelect	+=	" , CHF_SUBAUX, CHF_CUSAUX "
	Endif

	cFrom := RetSqlName( "CHF" ) + " CHF "

	cFrom += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom += "  ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cFrom += " AND C1O.C1O_ID = CHF.CHF_CODCTA "
	cFrom += " AND C1O.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
	cFrom += "  ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
	cFrom += " AND C1P.C1P_ID = CHF.CHF_CODCUS "
	cFrom += " AND C1P.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1PSUB "
	cFrom += "  ON C1PSUB.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
	cFrom += " AND C1PSUB.C1P_ID = CHF.CHF_CCUSUB "
	cFrom += " AND C1PSUB.D_E_L_E_T_ = '' "

	//cWhere := "     CHF.CHF_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CHF.CHF_FILIAL = '" + xFilial( "CHF" ) + "' "
	cWhere += " AND CHF.CHF_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += " AND CHF.D_E_L_E_T_ = '' "

	cOrderBy := "CHF_FILIAL, CHF_PERIOD "

ElseIf cReg == "Y671"

	cSelect := "CGU.CGU_AQMAQ, CGU.CGU_DOACRI, CGU.CGU_DOAIDO, CGU.CGU_AQATIV, CGU.CGU_BXATIV, CGU.CGU_BINCIN, CGU.CGU_BINCFI, CGU.CGU_CRCSLL, CGU.CGU_CBSIOF, CGU.CGU_FHALRE, CGU.CGU_ALQRED, CGU.CGU_ALTCAP, CGU.CGU_OBNCSL "

	cFrom := RetSqlName( "CGU" ) + " CGU "

	//cWhere := "    CGU.CGU_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGU.CGU_FILIAL = '" + xFilial( "CGU" ) + "' "
	cWhere += "AND CGU.CGU_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGU.D_E_L_E_T_ = '' "

	cOrderBy := "CGU_FILIAL, CGU_PERIOD "

ElseIf cReg $ "Y672"

	cSelect := "CGV.CGV_CAPANT,CGV.CGV_CAPITA, CGV.CGV_ESTANT, CGV.CGV_ESTOQU, CGV.CGV_CAIANT, CGV.CGV_CAIXA, CGV.CGV_APLANT, CGV.CGV_APLFIN, CGV.CGV_CTRANT, CGV.CGV_CTAREC, CGV.CGV_CTPANT, CGV.CGV_CTAPAG, CGV.CGV_COMMER, CGV.CGV_COMATI, CGV.CGV_RECEIT, CGV.CGV_TOTATI, CGV.CGV_FOLHA, CGV.CGV_ALQRED, CGV.CGV_REGAPU, CGV.CGV_INDEST "

	cFrom := RetSqlName( "CGV" ) + " CGV "

	//cWhere := "    CGV.CGV_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGV.CGV_FILIAL = '" + xFilial( "CGV" ) + "' "
	cWhere += "AND CGV.CGV_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGV.D_E_L_E_T_ = '' "

	cOrderBy := "CGV_FILIAL, CGV_PERIOD "

ElseIf cReg $ "Y680"

	cSelect := "  CGW.CGW_MES "
	cSelect += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CGX.CGX_VALOR "

	cFrom := RetSqlName( "CGW" ) + " CGW "

	cFrom += "LEFT JOIN " + RetSqlName( "CGX" ) + " CGX "
	cFrom += "  ON CGX.CGX_FILIAL = CGW.CGW_FILIAL "
	cFrom += " AND CGX.CGX_ID = CGW.CGW_ID "
	cFrom += " AND CGX.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
	cFrom += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
	cFrom += " AND CH6.CH6_ID = CGX.CGX_IDCODC "
	cFrom += " AND CH6.D_E_L_E_T_ = '' "

	//cWhere := "    CGW.CGW_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGW.CGW_FILIAL = '" + xFilial( "CGW" ) + "' "
	cWhere += "AND CGW.CGW_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGW.D_E_L_E_T_ = '' "

	cOrderBy := "CGW_FILIAL, CGW_MES, CH6_CODIGO "

ElseIf cReg $ "Y682"

	cSelect := "CGY.CGY_MES, CGY.CGY_ACRPAT "

	cFrom := RetSqlName( "CGY" ) + " CGY "

	//cWhere := "    CGY.CGY_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGY.CGY_FILIAL = '" + xFilial( "CGY" ) + "' "
	cWhere += "AND CGY.CGY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGY.D_E_L_E_T_ = '' "

	cOrderBy := "CGY_FILIAL, CGY_PERIOD "

ElseIf cReg $ "Y690"

	cSelect := "CGZ.CGZ_MES, CGZ.CGZ_RECBRU "

	cFrom := RetSqlName( "CGZ" ) + " CGZ "

	//cWhere := "    CGZ.CGZ_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CGZ.CGZ_FILIAL = '" + xFilial( "CGZ" ) + "' "
	cWhere += "AND CGZ.CGZ_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CGZ.D_E_L_E_T_ = '' "

	cOrderBy := "CGZ_FILIAL, CGZ_PERIOD "

ElseIf cReg $ "Y700"

	cSelect := "T27.R_E_C_N_O_ T27RECNO, T26.T26_CODIGO, T28.T28_VLRTRB, T28.T28_ANOTRB "

	cFrom := RetSqlName( "T27" ) + " T27 "

	cFrom += "LEFT JOIN " + RetSqlName( "T28" ) + " T28 "
	cFrom += "  ON T28.T28_FILIAL = T27.T27_FILIAL "
	cFrom += " AND T28.T28_ID = T27.T27_ID "
	cFrom += " AND T28.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "T26" ) + " T26 "
	cFrom += "  ON T26.T26_FILIAL = '" + xFilial( "T26" ) + "'
	cFrom += " AND T26.T26_ID = T28.T28_IDCODT "
	cFrom += " AND T26.D_E_L_E_T_ = '' "

	//cWhere := "    T27.T27_FILIAL IN (" + cFilSel + ") "
	cWhere := "    T27.T27_FILIAL = '" + xFilial( "T27" ) + "' "
	cWhere += "AND T27.T27_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND T27.D_E_L_E_T_ = '' "

	cOrderBy := "T27_FILIAL, T27_PERIOD "

ElseIf cReg $ "Y720"

	cSelect := "T29.T29_VLRLUC, T29.T29_DTLUCL, T29.T29_VLRREC "
	If lVer007Cp
		cSelect += ", T29.T29_ITMCAO, T29.T29_INTATR "
	EndIf
	cFrom := RetSqlName( "T29" ) + " T29 "

	//cWhere := "    T29.T29_FILIAL IN (" + cFilSel + ") "
	cWhere := "    T29.T29_FILIAL = '" + xFilial( "T29" ) + "' "
	cWhere += "AND T29.T29_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND T29.D_E_L_E_T_ = '' "

	cOrderBy := "T29_FILIAL, T29_PERIOD "

ElseIf cReg $ "Y800"

	cSelect := "CH9.R_E_C_N_O_ RECNO "

	cFrom := RetSqlName( "CH9" ) + " CH9 "

	//cWhere := "    CH9.CH9_FILIAL IN (" + cFilSel + ") "
	cWhere := "    CH9.CH9_FILIAL = '" + xFilial( "CH9" ) + "' "
	cWhere += "AND CH9.CH9_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CH9.D_E_L_E_T_ = '' "

	cOrderBy := "CH9_FILIAL, CH9_PERIOD "

EndIf

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"
cOrderBy := "%" + cOrderBy + "%"

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

Return()
