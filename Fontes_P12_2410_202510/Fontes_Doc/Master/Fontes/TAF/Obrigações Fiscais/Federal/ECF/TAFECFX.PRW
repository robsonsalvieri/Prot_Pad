#Include "Protheus.ch" 

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFBLCX

Rotina extratora das informacoes para o Bloco X do ECF

@Param 	cTABCTL	->	Nome da tabela de controle de transações
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
Function TAFECFX( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"X"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.
Local lECF10		:= TAFAlsInDic( "V15" ) .and. TAFAlsInDic( "V17" ) .and. TafColumnPos("V55_ID") .and. Valtype(aWizard) == "A" .And. Len(aWizard) >= 1 .And. Len(aWizard[1]) >= 5 .And. aWizard[1][5] >= "0010"
Local lECF11		:= aWizard[1][5] >= "0011" .and. TAFAlsInDic( "T1C" )
 
//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegX280( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	if !lECF11
		RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X291" )
	endIf
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X292" )
	if !lECF11
		RegX300( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		RegX320( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	endIf
	RegX340( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	If lECF10
		RegsX360( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		RegsX365( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		RegsX370( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	EndIf	
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X390" )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X400" )
	RegX410( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegX420( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegX430( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	RegX450( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, lECF11 )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X460" )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X470" )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X480" )
	If lECF10
		RegX485( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
	EndIf 
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X490" )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X500" )
	RegsGener( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, "X510" )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegX001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegX001

Rotina para extrair e gravar as informacoes do Registro X001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX001( aECFInfo, cIndMov )

Local cDelimit := "|" 
Local cStrTxt  := ""

cStrTxt := cDelimit + "X001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "X001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX280

Rotina para extrair e gravar as informacoes do Registro X280.

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
Static Function RegX280( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, "X280" )

//Registro X280
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X280"											//01 - REG
	cStrTxt += cDelimit + ( cAliasQry )->CFL_CODIGO							//02 - IND_ATIV
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + TAFConType(( cAliasQry )->CFK_INDCON)			//03 - IND_CONCEDENTE
	Endif
	cStrTxt += cDelimit + ( cAliasQry )->CFM_CODIGO							//04 - IND_PROJ
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFK_ATOCON )			//05 - ATO_CONC
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CFK_VIGINI )			//06 - VIG_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CFK_VIGFIM )			//07 - VIG_FIM
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + TAFConType(( cAliasQry )->CFK_CNPJIN)			//08 - CNPJ_INCENTIVO
		cStrTxt += cDelimit + TAFConType(( cAliasQry )->C0A_CODIGO)			//09 - NCM_INCENTIVO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFK_RECINC, 16, 2 )   //10 - REC_LIQ_INCENTIVO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFK_VLINCE, 16, 2 )   //11 - VL_INCENTIVO
	Endif
	
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X280", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX300

Rotina para extrair e gravar as informacoes do Registro X300 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX300( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cTpMetodo := ""
Local cAliasQry := GetNextAlias()
Local cAliasFilh := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, "X300" )

//Registro X300
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	If ( cAliasQry )->CAY_TIPMET == "1"
		cTpMetodo := "PVE"
	ElseIf ( cAliasQry )->CAY_TIPMET == "2"
		cTpMetodo := "PVA"
	ElseIf ( cAliasQry )->CAY_TIPMET == "3"
		cTpMetodo := "PVV"
	ElseIf ( cAliasQry )->CAY_TIPMET == "4"
		cTpMetodo := "CAP"
	ElseIf ( cAliasQry )->CAY_TIPMET == "5"
		cTpMetodo := "PECEx"
	Else
		cTpMetodo := ""
	EndIf

	cStrTxt := cDelimit + "X300"												//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_NUMORD )				//02 - NUM_ORDEM
	cStrTxt += cDelimit + ( cAliasQry )->CAY_TIPEXP								//03 - TIP_EXP
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_DESCRI )				//04 - DESC_EXP
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_TOTOPE,IIF( ( cAliasQry )->CAY_TIPEXP == "04",.T.,.F.), 16, 2 ) //05 - TOT_OPER
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C0A_CODIGO )				//06 - COD_NCM
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_QUANTI,IIF( ( cAliasQry )->CAY_TIPEXP == "01",.F.,.T.), 16, 2 ) //07 - QTDE
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHJ_CODIGO )				//08 - UNI_MED
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CAY_INDOPE )				//09 - IND_OPER
	cStrTxt += cDelimit + cTpMetodo												//10 - TIP_MET
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_TPOPER )	     	//11 - OPER_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_DESCPA )	        //12 - DESC_BENS_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_IDPAEN )	        //13 - ID_PARTE_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_TPBEM )			//14 - TIP_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_DTUTIL)	        //15 - DAT_UTIL
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_DESCME)			//16 - CRIT_PAR
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CAY_DTNEGC)	        //17 - DAT_TRANS
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CAY_DTEMBQ)	        //18 - DAT_EMB
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V6U_CODFCO)			//19 - ID_FONT_COT
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_AJUPAR)			//20 - AJ_PAR 
	Endif
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_VLPAR,IIF( ( cAliasQry )->CAY_TIPEXP $ "01|02|03" .And. ( cAliasQry )->CAY_INDOPE == "1" ,.F.,.T.), 16, 2 ) //21 - VL_PAR
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_VLPRAT,IIF( ( cAliasQry )->CAY_TIPEXP $ "01|02|03".And. ( cAliasQry )->CAY_INDOPE == "1" ,.F.,.T.), 16, 2 ) //22 - VL_PRAT
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_QTDAJU,IIF( ( cAliasQry )->CAY_TIPEXP == "01",.F.,.T.), 16, 6 ) //23 - QTDE_AJ
	Endif
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_VLAJ,IIF( ( cAliasQry )->CAY_TIPEXP $ "01|02|03" .And. ( cAliasQry )->CAY_INDOPE == "1" ,.F.,.T.), 16, 2 )	//24 - VL_AJ
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_VLRCOT,IIF(cTpMetodo=="PECEx",.F.,.T.), 16, 2 ) //25 - VALOR_COT
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAY_NUMDEC)            //26 - NUM_DEC_EXP
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CAY_DTENPR)	        //27 - DAT_ENT_PREV
	Endif
	
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_TXJUR,IIF( ( cAliasQry )->CAY_TIPEXP == "04",.F.,.T.), 16, 2 )	//28 - VL_JUR
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_TXJMIN,IIF( ( cAliasQry )->CAY_TIPEXP == "04",.F.,.T.), 16, 2 ) //29 - VL_JUR_MIN
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CAY_TXJMAX,IIF( ( cAliasQry )->CAY_TIPEXP == "04",.F.,.T.), 16, 2 ) //30 - VL_JUR_MAX
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZT_CODIGO )				//31 - COD_CNC
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZU_SIGLAM )				//32 - TIP_MOEDA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X300", cStrTxt )

	nSeq ++
	
	IF aWizard[1][5] >= '0007'
		//Registro X305
		ECFQryX( cAliasFilh, aWizard, cFilSel, "X305",  ( cAliasQry )->CAY_ID)
	
		While ( cAliasFilh )->( !Eof() )

			cStrTxt := cDelimit + "X305"										//01 - REG
			cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->V6T_CODTPA )		//02 - TIP_AJUST
			cStrTxt += cDelimit + TAFConType( ( cAliasFilh )-> V6R_DOAJUS)		//03 - DESC_OUT_AJ
			cStrTxt += cDelimit + Val2Str( ( cAliasFilh )->V6R_VLRAJU, 16, 2 )	//04 - VALOR
			cStrTxt += cDelimit + TAFConType(( cAliasFilh )->V6R_FNTAJU)		//05 - FONT_AJU
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, "X305", cStrTxt )

			nSeq ++

			( cAliasFilh )->( DBSkip() )
		EndDo

		( cAliasFilh )->( DBCloseArea() )
	Endif

	//Registro X310
	ECFQryX( cAliasFilh, aWizard, cFilSel, "X310", ( cAliasQry )->CAY_ID )
	
	While ( cAliasFilh )->( !Eof() ) 

		cStrTxt := cDelimit + "X310"										//01 - REG
		cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->CAZ_NOME )		//02 - NOME
		cStrTxt += cDelimit + TAFConvPais( ( cAliasFilh )->C08_PAISSX )		//03 - PAIS
		cStrTxt += cDelimit + Val2Str( ( cAliasFilh )->CAZ_VLOPER, 16, 2 )	//04 - VL_OPER
		cStrTxt += cDelimit + ( cAliasFilh )->CAZ_CONDPE					//05 - COND_PES
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X310", cStrTxt )

		nSeq ++

		( cAliasFilh )->( DBSkip() )
	EndDo
	
	( cAliasFilh )->( DBCloseArea() )

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX320

Rotina para extrair e gravar as informacoes do Registro X320 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX320( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cTpMetodo := ""
Local cAliasQry := GetNextAlias()
Local cAliasFilh := GetNextAlias()


ECFQryX( cAliasQry, aWizard, cFilSel, "X320" )

//Registro X320
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	If ( cAliasQry )->CFV_TIPMET == "1"
		cTpMetodo := "PIC00"
	ElseIf ( cAliasQry )->CFV_TIPMET == "2"
		cTpMetodo := "PRL20"
	ElseIf ( cAliasQry )->CFV_TIPMET == "3"
		cTpMetodo := "PRL30"
	ElseIf ( cAliasQry )->CFV_TIPMET == "4"
		cTpMetodo := "PRL40"
	ElseIf ( cAliasQry )->CFV_TIPMET == "5"
		cTpMetodo := "PRL60"
	ElseIf ( cAliasQry )->CFV_TIPMET == "6"
		cTpMetodo := "CPL00"
	ElseIf ( cAliasQry )->CFV_TIPMET == "7"
		cTpMetodo := "PCI00"
	Else
		cTpMetodo := ""
	EndIf

	cStrTxt := cDelimit + "X320"											//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_NUMORD )			//02 - NUM_ORD
	cStrTxt += cDelimit + ( cAliasQry )->CFV_TIPEXP							//03 - TIP_IMP
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_DESCRI )			//04 - DESC_IMP
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_TOTOPE,IIF( ( cAliasQry )->CFV_TIPEXP == "04",.T.,.F.), 16, 2 ) //05 - TOT_OPER
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C0A_CODIGO )			//06 - COD_NCM
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_QUANTI,IIF( ( cAliasQry )->CFV_TIPEXP == "01",.F.,.T.), 16, 2 ) //07 - QTDE
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CHJ_CODIGO )			//08 - UNI_MED
	cStrTxt += cDelimit + cTpMetodo											//09 - TIP_MET
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + TAFConType( (cAliasQry)->C1L_CODIGO )				//10 - COD_INV
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_UTINPR )			//11 - UTIL_INS_PROD
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_OPAPPA )		    //12 - OPER_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_DESPAR )		    //13 - DESC_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_IDPAEN )		    //14 - ID_PARTE_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_TPPAR  )		    //15 - TIP_PAR
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_DTUTIL )		    //16 - DAT_UTIL
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_CRIDET )			//17 - CRIT_PAR
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CFV_DTTRAN)	        //18 - DAT_TRANS
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CFV_DTDUIM)	        //19 - DAT_DUIMP
		cStrTxt += cDelimit + TAFConType(  ( cAliasQry )->V6U_CODFCO)			//20 - ID_FONT_COT
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_AJUPAR )			//21 - AJ_PAR
	Endif
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_VLPAR,IIF( ( cAliasQry )->CFV_TIPEXP $ "01|02|03",.F.,.T.), 16, 2 ) //22 - VL_PAR
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_VLPRAT,IIF( ( cAliasQry )->CFV_TIPEXP $ "01|02|03",.F.,.T.), 16, 2 ) //23 - VL_PRAT
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_QTDAJU,IIF( ( cAliasQry )->CFV_TIPEXP == "01",.F.,.T.), 16, 6 ) //24 - QTDE_AJ
	Endif
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_VLAJ,.F., 16, 2 )			//25 - VL_AJ
	IF aWizard[1][5] >= '0007'
		cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_VLRCOT,IIF( cTpMetodo == "PCI00",.F.,.T.), 16, 2 )	//26 - VALOR_COT
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFV_NUMDEC )			//27 - NUM_DEC_IMP
		cStrTxt += cDelimit + Dt2Caract(  ( cAliasQry )->CFV_DTENPR)	        //28 - DAT_ENT_PREV
	Endif
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_TXJUR,IIF( ( cAliasQry )->CFV_TIPEXP == "04",.F.,.T.), 16, 2 ) //29 - VL_JUR
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_TXJMIN,IIF( ( cAliasQry )->CFV_TIPEXP == "04",.F.,.T.), 7, 4 ) //30 - VL_JUR_MIN
	cStrTxt += cDelimit + StrECF( ( cAliasQry )->CFV_TXJMAX,IIF( ( cAliasQry )->CFV_TIPEXP == "04",.F.,.T.), 7, 4 ) //31 - VL_JUR_MAX
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZT_CODIGO )			//32 - COD_CNC
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZU_CODIGO )			//33 - TIP_MOEDA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X320", cStrTxt )

	nSeq ++

	IF aWizard[1][5] >= '0007'
		//Registro X325
		ECFQryX( cAliasFilh, aWizard, cFilSel, "X325" , ( cAliasQry )->CFV_ID)

		While ( cAliasFilh )->( !Eof() )

			cStrTxt := cDelimit + "X325"										//01 - REG
			cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->V6T_CODTPA )		//02 - TIP_AJUST
			cStrTxt += cDelimit + TAFConType( ( cAliasFilh )-> V6S_DOAJUS)		//03 - DESC_OUT_AJ
			cStrTxt += cDelimit + Val2Str( ( cAliasFilh )->V6S_VLRAJU, 16, 2 )	//04 - VALOR
			cStrTxt += cDelimit + TAFConType(( cAliasFilh )->V6S_FNTAJU)		//05 - FONT_AJU
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, "X325", cStrTxt )

			nSeq ++

			( cAliasFilh )->( DBSkip() )
		EndDo

		( cAliasFilh )->( DBCloseArea() )

	EndIF

	//Registro X330
	ECFQryX( cAliasFilh, aWizard, cFilSel, "X330", ( cAliasQry )->CFV_ID )

	//Registro X330
	While ( cAliasFilh )->( !Eof() )

		cStrTxt := cDelimit + "X330"											//01 - REG
		cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->CFX_NOME )			//02 - NOME
		cStrTxt += cDelimit + TAFConvPais( ( cAliasFilh )->C08_PAISSX )			//03 - PAIS
		cStrTxt += cDelimit + Val2Str( ( cAliasFilh )->CFX_VLOPER, 16, 2 )		//04 - VL_OPER
		cStrTxt += cDelimit + ( cAliasFilh )->CFX_CONDPE						//05 - COND_PES
		
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X330", cStrTxt )

		nSeq ++

		( cAliasFilh )->( DBSkip() )
	EndDo

	( cAliasFilh )->( DBCloseArea() )

	( cAliasQry )->( DBSkip() )

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX340

Rotina para extrair e gravar as informacoes do Registro X340 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX340( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cLoop     := ""
Local cAliasQry := GetNextAlias()
Local lBlocX50  := Ecf50BlX()

ECFQryX( cAliasQry, aWizard, cFilSel, "X340" )

//Registro X340
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X340"											//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFY_RAZSOC )		//02 - RAZ_SOCIAL
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CFY_NIF )			//03 - NIF
	cStrTxt += cDelimit + TAFConType( (cAliasQry )->CFY_INDCTL) 		//04 - IND_CONTROLE
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )		//05 - PAIS
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CFY_INDREP )		//06 - IND_REPETRO
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CFY_INDCON )		//07 - IND_CONSOL
	cStrTxt += cDelimit + TAFConType(( cAliasQry )->CFY_MOTNCO)			//08 - MOT_NAO_CONSOL
	//Campo inserido a partir do Layout 2
	If aWizard[1,5] >= "0002" .and. TAFColumnPos( "CFY_CNPJ" )
		cStrTxt += cDelimit + AllTrim( ( cAliasQry )->CFY_CNPJ )		//09 - CNPJ
	EndIf
	If aWizard[1,5] >= "0002" .and. TAFColumnPos( "CFY_IDMOED" )
		//cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZU_SIGLAM )		//10 - MOEDA
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CZU_SIGLAM )		//10 - MOEDA
	EndIf
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X340", cStrTxt )

	nSeq ++

	cLoop := ( cAliasQry )->CFY_NIF
	
	//Registro X350
	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CFY_NIF == cLoop
	
		If AllTrim( ( cAliasQry )->REGISTRO ) == "X350" .AND. (! Empty(( cAliasQry )->CFZ_RECLIQ) .OR. ! Empty(( cAliasQry )->CFZ_VLCUST) .OR. ! Empty(( cAliasQry )->CFZ_LUCBRT) .OR. ! Empty(( cAliasQry )->CFZ_RECAUF) .OR. ! Empty(( cAliasQry )->CFZ_RECOPE) .OR. ! Empty(( cAliasQry )->CFZ_DSPFIN) .OR. ! Empty(( cAliasQry )->CFZ_DSPOPE) .OR. ! Empty(( cAliasQry )->CFZ_LUCOPE) .OR. ! Empty(( cAliasQry )->CFZ_RECPAR) .OR. ! Empty(( cAliasQry )->CFZ_RECOUT) .OR. ! Empty(( cAliasQry )->CFZ_DSPOUT) .OR. ! Empty(( cAliasQry )->CFZ_LUCIR)  .OR. ! Empty(( cAliasQry )->CFZ_IMPDEV) .OR. ! Empty(( cAliasQry )->CFZ_LUCPA) .OR. ! Empty(( cAliasQry )->CFZ_LUCANT) .OR. ! Empty(( cAliasQry )->CFZ_IMPARB) .OR. ! Empty(( cAliasQry )->CFZ_LUCAPO)) 
		
			cStrTxt := cDelimit + "X350"											//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_RECLIQ, 16, 2 )		//02 - REC_LIQ
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_VLCUST, 16, 2 )		//03 - CUSTOS
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCBRT, 16, 2 )		//04 - LUC_BRUTO
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_RECAUF, 16, 2 )		//05 - REC_AUFERIDAS
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_RECOPE, 16, 2 )		//06 - REC_OUTRAS_OPER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_DSPFIN, 16, 2 )		//07 - DESP_BRASIL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_DSPOPE, 16, 2 )		//08 - DESP_OPER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCOPE, 16, 2 )		//09 - LUC_OPER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_RECPAR, 16, 2 )		//10 - REC_PARTIC
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_RECOUT, 16, 2 )		//11 - REC_OUTRAS
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_DSPOUT, 16, 2 )		//12 - DESP_OUTRAS
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCIR, 16, 2 )		//13 - LUC_LIQ_ANT_IR
			If aWizard[1,5] >= "0008"
			   cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCANT, 16, 2 )	//14 - LUC_ARB_ANT_IMP
			EndIf
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_IMPDEV, 16, 2 )		//14 - IMP_DEV
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCPA, 16, 2 )		//15 - LUC_LIQ
			
			//Campos excluídos a partir do Layout 2
			If aWizard[1,5] == "0001"
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCANT, 16, 2 )		//16 - LUC_ARB_ANT_IMP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_IMPARB, 16, 2 )		//17 - IMP_DEV_ARB
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFZ_LUCAPO, 16, 2 )		//18 - LUC_ARB_PER_APUR
			EndIf
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )

			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X351" .AND. (! Empty(( cAliasQry )->CHL_RESINV) .OR. ! Empty(( cAliasQry )->CHL_RESPOS) .OR. ! Empty(( cAliasQry )->CHL_RESOPE) .OR. ! Empty(( cAliasQry )->CHL_RESREP) .OR. ! Empty(( cAliasQry )->CHL_RESNEG) .OR. ! Empty(( cAliasQry )->CHL_RESPTB) .OR. ! Empty(( cAliasQry )->CHL_RESPTR) .OR. ! Empty(( cAliasQry )->CHL_IMPPAG) .OR. ! Empty(( cAliasQry )->CHL_IMPPGR) .OR. ! Empty(( cAliasQry )->CHL_IMPREN) .OR. ! Empty(( cAliasQry )->CHL_IMPRER) .OR. ! Empty(( cAliasQry )->CHL_IMPREX)  .OR. ! Empty(( cAliasQry )->CHL_IMPRRE) .OR. ! Empty(( cAliasQry )->CHL_IMPRBR)) 

			cStrTxt := cDelimit + "X351"												//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESINV, 16, 2 )		//02 - RES_INV_PER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESPOS, 16, 2 )		//03 - RES_INV_PER_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESOPE, 16, 2 )		//04 - RES_ISEN_PETR_PER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESREP, 16, 2 )		//05 - RES_ISEN_PETR_PER_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESNEG, 16, 2 )		//06 - RES_NEG_ACUM
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESPTB, 16, 2 )		//07 - RES_POS_TRIB
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_RESPTR, 16, 2 )		//08 - RES_POS_TRIB_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPPAG, 16, 2 )		//09 - IMP_LUCR
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPPGR, 16, 2 )		//10 - IMP_LUCR_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPREN, 16, 2 )		//11 - IMP_PAG_REND
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPRER, 16, 2 )		//12 - IMP_PAG_REND_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPREX, 16, 2 )		//13 - IMP_RET_EXT
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPRRE, 16, 2 )		//14 - IMP_RET_EXT_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHL_IMPRBR, 16, 2 )		//15 - IMP_RET_BR
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X352" .AND. (! Empty(( cAliasQry )->CHM_RESPER) .OR. ! Empty(( cAliasQry )->CHM_RESPRE) .OR. ! Empty(( cAliasQry )->CHM_LUCDIS) .OR. ! Empty(( cAliasQry )->CHM_LUCDRE)) 

			cStrTxt := cDelimit + "X352"												//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHM_RESPER, 16, 2 )		//02 - RES_PER
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHM_RESPRE, 16, 2 )		//03 - RES_PER_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHM_LUCDIS, 16, 2 )		//04 - LUC_DISP
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHM_LUCDRE, 16, 2 )		//05 - LUC_DISP_REAL
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X353" .AND. (! Empty(( cAliasQry )->CHN_RESNEG) .OR. ! Empty(( cAliasQry )->CHN_RESNRE) .OR. ! Empty(( cAliasQry )->CHN_SLDNEG) .OR. ! Empty(( cAliasQry )->CHN_SLDNRE))

			cStrTxt := cDelimit + "X353"										//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_RESNEG, 16, 2 )	//02 - RES_NEG_UTIL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_RESNRE, 16, 2 )	//03 - RES_NEG_UTIL_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_SLDNEG, 16, 2 )	//04 - SALDO_RES_NEG_NAO_UTIL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_SLDNRE, 16, 2 )	//05 - SALDO_RES_NEG_NAO_UTIL_REAL

			if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_RPROP , 16, 2 )	//06 - RES_PROP
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHN_RPREAL, 16, 2 )	//07 - RES_PROP_REAL
			Endif

			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X354" .AND. (! Empty(( cAliasQry )->CHO_RESNEG) .OR. ! Empty(( cAliasQry )->CHO_RESNRE) .OR. ! Empty(( cAliasQry )->CHO_SLDNEG))

			cStrTxt := cDelimit + "X354"												//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHO_RESNEG, 16, 2 )		//02 - RES_NEG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHO_RESNRE, 16, 2 )		//03 - RES_NEG_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHO_SLDNEG, 16, 2 )		//04 - SALDO_RES_NEG
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X355"  .AND. (! Empty(( cAliasQry )->CHP_RENPAS) .OR. ! Empty(( cAliasQry )->CHP_RENPRE) .OR. ! Empty(( cAliasQry )->CHP_RENTOT) .OR. ! Empty(( cAliasQry )->CHP_RENTRE) .OR. ! Empty(( cAliasQry )->CHP_RENATV) .OR. ! Empty(( cAliasQry )->CHP_RENARE) .OR. ! Empty(( cAliasQry )->CHP_PERCEN))

			cStrTxt := cDelimit + "X355"												//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENPAS, 16, 2 )		//02 - REND_PASS_PROP
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENPRE, 16, 2 )		//03 - REND_PASS_PROP_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENTOT, 16, 2 )		//04 - REND_TOTAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENTRE, 16, 2 )		//05 - REND_TOTAL_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENATV, 16, 2 )		//06 - REND_ATIV_PROP
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_RENARE, 16, 2 )		//07 - REND_ATIV_PROP_REAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHP_PERCEN, 16, 2 )		//08 - PERCENTUAL
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X356" .AND. (! Empty(( cAliasQry )->CHQ_PERPAR) .OR. ! Empty(( cAliasQry )->CHQ_ATVTOT) .OR. ! Empty(( cAliasQry )->CHQ_PATLIQ))

			cStrTxt := cDelimit + "X356"											//01 - REG
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHQ_PERPAR, 5, 2 )		//02 - PERC_PART
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHQ_ATVTOT, 16, 2 )		//03 - ATIVO_TOTAL
			cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHQ_PATLIQ, 16, 2 )		//04 - PAT_LIQUIDO
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )
	
			nSeq ++

		ElseIf AllTrim( ( cAliasQry )->REGISTRO ) == "X357"

			if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005" .And. ;
			(! Empty(( cAliasQry )->V3M_PAIS) .OR. ! Empty(( cAliasQry )->V3M_NIF) .OR. ! Empty(( cAliasQry )->V3M_RAZSOC) .OR. ! Empty(( cAliasQry )->V3M_PERCPI) )

				cStrTxt := cDelimit + "X357"																			//01 - REG
				cStrTxt += cDelimit + AllTrim(Posicione("C08",3,xFilial("C08") + (cAliasQry)->V3M_PAIS,"C08_PAISSX")) 	//02 - PAIS
				cStrTxt += cDelimit + AllTrim((cAliasQry)->V3M_NIF)														//03 - NIF/CNPJ
				cStrTxt += cDelimit + AllTrim((cAliasQry)->V3M_RAZSOC)													//04 - RAZAO_SOCIAL
				cStrTxt += cDelimit + Val2Str((cAliasQry)->V3M_PERCPI,8,4)											   	//05 - PERCENTUAL
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, AllTrim( ( cAliasQry )->REGISTRO ), cStrTxt )

				nSeq ++
			endif
		EndIf

		( cAliasQry )->( DBSkip() )

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX410

Rotina para extrair e gravar as informacoes do Registro X410.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX410( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, "X410" )

//Registro X410
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X410"										//01 - REG
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )		//02 - PAIS
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CG0_HOMEDI )		//03 - IND_HOME_DISP
	cStrTxt += cDelimit + xFunTrcSN( ( cAliasQry )->CG0_SERVDI )		//04 - IND_SERV_DISP
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X410", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX420

Rotina para extrair e gravar as informacoes do Registro X420.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX420( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, "X420" )

//Registro X420
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X420"													//01 - REG
	cStrTxt += cDelimit + Iif( ( cAliasQry )->CG2_TIPROY == "1", "R", "P" )		//02 - TIP_ROY
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )					//03 - PAIS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLSW, 16, 2 )				//04 - VL_EXPL_DIR_SW
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLAUT, 16, 2 )				//05 - VL_EXPL_DIR_AUT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLMARC, 16, 2 )				//06 - VL_EXPL_MARCA
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLPAT, 16, 2 )				//07 - VL_EXPL_PAT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLKNOW, 16, 2 )				//08 - VL_EXPL_KNOW
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLFRAN, 16, 2 )				//09 - VL_EXPL_FRANQ
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG2_VLINT, 16, 2 )				//10 - VL_EXPL_INT
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X420", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX430

Rotina para extrair e gravar as informacoes do Registro X430.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX430( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, "X430" )

//Registro X430
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X430"											//01 - REG
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )			//02 - PAIS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLASSI, 16, 2 )		//03 - VL_SERV_ASSIST
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLTEC, 16, 2 )		//04 - VL_SERV_SEM_ASSIST
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLEXT, 16, 2 )		//05 - VL_SERV_SEM_ASSIST_EXT
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLJUR, 16, 2 )		//06 - VL_JURO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLDJU, 16, 2 )		//07 - VL_DEMAIS_JUROS
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG3_VLDIVI, 16, 2 )		//08 - VL_DIVID
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X430", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX450

Rotina para extrair e gravar as informacoes do Registro X450.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 22/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX450( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, lECF11 )

Local cDelimit   as character
Local cStrTxt    as character
Local cAliasQry  as character
Local cAliasFilh as character
Local oPrepare	 as object
Local cIdPai	 as character
Local cRegPai	 as character
Local cFilhX451	 as character

Default lECF11 := .F.

cDelimit   := "|"
cStrTxt    := ""
cAliasQry  := GetNextAlias()
cAliasFilh := GetNextAlias()
oPrepare   := nil
cIdPai	   := ""
cRegPai	   := "X450"
cFilhX451  := "X451"

ECFQryX( cAliasQry, aWizard, cFilSel, cRegPai, , @oPrepare )

//Registro X450
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"
	cIdPai := ( cAliasQry )->CG5ID

	cStrTxt := cDelimit + cRegPai											//01 - REG
	cStrTxt += cDelimit + TAFConvPais( ( cAliasQry )->C08_PAISSX )			//02 - PAIS
	If aWizard[1][5] < '0011'
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLASSI, 16, 2 )		//03 - VL_SERV_ASSIST
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLTEC, 16, 2 )		//04 - VL_SERV_SEM_ASSIST
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLEXT, 16, 2 )		//05 - VL_SERV_SEM_ASSIST_EXT
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLJPF, 16, 2 )		//06 - VL_JURO_PF
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLJPJ, 16, 2 )		//07 - VL_JURO_PJ
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_VLDJUR, 16, 2 )		//08 - VL_DEMAIS_JUROS
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_DIVIPF, 16, 2 )		//09 - VL_DIVID_PF
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CG5_DIVIPJ, 16, 2 )		//10 - VL_DIVID_PJ
	EndIf
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, cRegPai, cStrTxt )

	nSeq ++
	If oPrepare != Nil
    	oPrepare:Destroy()
        freeObj(oPrepare)
        oPrepare := Nil
    EndIf

	If lECF11
		ECFQryX( cAliasFilh, aWizard, cFilSel, cFilhX451, cIdPai , @oPrepare )

		While ( cAliasFilh )->( !Eof() )

			cStrTxt := cDelimit + cFilhX451												//01 - REG
			cStrTxt += cDelimit + Val2Str(Alltrim(( cAliasFilh )->COD_LINHA), 16, 2 )	//02 - COD_LINHA
			cStrTxt += cDelimit + Alltrim(( cAliasFilh )->DESC_LINHA)					//03 - DESC_LINHA
			cStrTxt += cDelimit + Val2Str(( cAliasFilh )->T1CVALOR, 16, 2 )				//04 - VAL_LINHA
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, cFilhX451, cStrTxt )

			nSeq ++

			( cAliasFilh )->( DBSkip() )
		EndDo
		( cAliasFilh )->( DBCloseArea() )
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
    	EndIf
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegX485

Rotina para extrair e gravar as informacoes do Registro X485.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Carlos Pister	
@Since 26/03/2024
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegX485( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  as character
Local cStrTxt   as character
Local cAliasQry as character

cDelimit  := "|"
cStrTxt   := ""
cAliasQry := GetNextAlias()
ECFQryX( cAliasQry, aWizard, cFilSel, "X485" )

//Registro X485
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X485"									//01 - REG
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_TPBENE )	    //02 - TIPO_BENEF
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_ATODEC )		//03 - ATO_DECL
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_CNPJIN )		//04 - CNPJ_INCORP
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_IDOB18 )		//05 - ID_OBRA_2018
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_IDOB20 )		//06 - ID_OBRA_2020
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_IDOBEI )		//07 - ID_OBRA_EEI
	cStrTxt += cDelimit + AllTrim( ( cAliasQry )->V55_PORTCE )		//08 - PORT_CEBAS
	cStrTxt += cDelimit + Dt2Caract(( cAliasQry )->V55_DTDOUC)		//09 - DT_DOU_PORT_CEBAS
	cStrTxt += cDelimit + Dt2Caract(( cAliasQry )->V55_DTINIC)		//10 - DT_INI_PORT_CEBAS
	cStrTxt += cDelimit + Dt2Caract(( cAliasQry )->V55_DTFIMC) 		//11 - DT_FIN_PORT_CEBAS
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X485", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()
//---------------------------------------------------------------------
/*/{Protheus.doc} RegsX365

Rotina para extrair e gravar as informacoes do Registro X365 e X366.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Karen Honda
@Since 04/04/2024
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegsX365( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  as character
Local cStrTxt   as character
Local cAliasQry as character

cDelimit  := "|"
cStrTxt   := ""
cAliasQry := GetNextAlias()
ECFQryX( cAliasQry, aWizard, cFilSel, "X365" )

//Registro X365
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X365"												//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V15_IDENT )				//02 - IDENTIFICADOR
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V15_NOME )					//03 - NOME_ENT
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X365", cStrTxt )
	nSeq ++

	//NIF ou TIN
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "1"									//02 - CODIGO
	cStrTxt += cDelimit + "NIF ou TIN"							//03 - DESCRICAO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V15_NIF )	//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++

	//País
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "2"									//02 - CODIGO
	cStrTxt += cDelimit + "País" 								//03 - DESCRICAO
	cStrTxt += cDelimit + cValToChar(Val(( cAliasQry )->C08_PAISSX))	// 04 - VALOR 
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++

	//Parte relacionada nos termos
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "3"									//02 - CODIGO
	cStrTxt += cDelimit + "Essa empresa é parte relacionada nos termos do art. 4º da Lei nº 14.596, de 14 de junho de 2023" //03 - DESCRICAO
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V15_PARREL == "1", "S", Iif( ( cAliasQry )->V15_PARREL == "2" , "N", "" ) ) )	//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++

	//entidade é caracterizada nas hipóteses previstas
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "4"									//02 - CODIGO
	cStrTxt += cDelimit + "Essa entidade é caracterizada nas hipóteses previstas nos arts. 24 e 24-A da Lei nº 9.430/1996" //03 - DESCRICAO
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V15_HIPOTE == "1", "S", Iif( ( cAliasQry )->V15_HIPOTE == "2" , "N", "" ) ) )	//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++

	//Total de pagamentos
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "5"									//02 - CODIGO
	cStrTxt += cDelimit + TAFConType( "Total de pagamentos" )   //03 - DESCRICAO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V15_VLRPGT, 16, 2 )		//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++

	//Total de recebimentos
	cStrTxt := cDelimit + "X366"								//01 - REG
	cStrTxt += cDelimit + "6"									//02 - CODIGO
	cStrTxt += cDelimit + TAFConType( "Total de recebimentos" ) //03 - DESCRICAO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V15_VLRREC, 16, 2 )		//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X366", cStrTxt )
	nSeq ++	

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegsX370

Rotina para extrair e gravar as informacoes do Registro X370/X371/X375.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Carlos Pister
@Since 04/04/2024
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegsX370( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit   as character
Local cStrTxt    as character
Local cAliasQry  as character
Local cAliasFilh as character
Local cDesc01 	 as character
Local cDesc02 	 as character
Local cDesc03 	 as character
Local cDesc04 	 as character
Local cDesc05 	 as character
Local cDesc06 	 as character
Local cDesc07 	 as character
Local cDesc08 	 as character
Local cDesc09 	 as character
Local cDesc10 	 as character
Local cDesc11 	 as character

cDelimit  	:= "|"
cStrTxt   	:= ""
cAliasQry 	:= GetNextAlias()
cAliasFilh  := GetNextAlias()
cDesc01		:= ""
cDesc02		:= ""
cDesc03		:= ""
cDesc04		:= ""
cDesc05		:= ""
cDesc06		:= ""
cDesc07		:= ""
cDesc08		:= ""
cDesc09		:= ""
cDesc10		:= ""
cDesc11		:= ""

ECFQryX( cAliasQry, aWizard, cFilSel, "X370" )

//Registro X370
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X370"												//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V15_IDENT )				//02 - IDENTIFICADOR
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_TPTRAN )				//03 - TIPO_TRANSACAO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V15_NOME )					//04 - NOME_ENT
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C08_PAISSX )				//05 - PAIS
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C0A_CODIGO )				//06 - COD_NCM
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_TPDEMA )				//07 - TIPO_DEMAIS
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_DBSDI )				//08 - DESCR_BSDI
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_VLTRAN, 16, 2 )			//09 - VL_TRANSACAO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_INDAJU )				//10 - IND_AJUSTES
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_VLESPO, 16, 2 )			//11 - VL_ESPONTANEO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_VLCOMP, 16, 2 )			//12 - VL_COMPENSATORIO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_TPAJUS )				//13 - TIP_AJ_COMPENSATORIO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_METODO )				//14 - METODO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_DMETOD )				//15 - DESCRICAO
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_COMINT == "1", "S", Iif( ( cAliasQry )->V17_COMINT == "2" , "N", "" ) ) )			//16 - COMP_INTENCIONAL
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_SINERG == "1", "S", Iif( ( cAliasQry )->V17_SINERG == "2" , "N", "" ) ) )			//17 - SINERGIA
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_INDTRA == "1", "S", Iif( ( cAliasQry )->V17_INDTRA == "2" , "N", "" ) ) )			//18 - IND_TRANS_COMBINADAS
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_INDDAD == "1", "S", Iif( ( cAliasQry )->V17_INDDAD == "2" , "N", "" ) ) )	    	//19 - IND_DADOS_MULTIP
	cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_INDSIM == "1", "S", Iif( ( cAliasQry )->V17_INDSIM == "2" , "N", "" ) ) )			//20 - IND_SIMPLIFIC
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X370", cStrTxt )

	nSeq ++
	
	//Registro X371
	ECFQryX( cAliasFilh, aWizard, cFilSel, "X371", ( cAliasQry )->V17_ID )

	While ( cAliasFilh )->( !Eof() )

		cStrTxt := cDelimit + "X371"											//01 - REG
		cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->C1O_CODIGO )			//02 - COD_CTA
		cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->V18_CODCUS )			//03 - COD_CCUS
		cStrTxt += cDelimit + Val2Str( ( cAliasFilh )->V18_VALOR, 16, 2 )		//04 - VALOR
		cStrTxt += cDelimit + TAFConType( ( cAliasFilh )->V18_INDVAL )			//05 - IND_VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X371", cStrTxt )

		nSeq ++

		( cAliasFilh )->( DBSkip() )
	EndDo

	( cAliasFilh )->( DBCloseArea() )

	//Registro X375
	If ( cAliasQry )->V17_METODO $ 'PRL|MCL|MLT'

		If ( cAliasQry )->V17_METODO == 'PRL'
			cDesc01 := "Empresa no Brasil - Receita Líquida"
			cDesc02 := "Empresa no Brasil - Lucro Bruto"
			cDesc03 := "Empresa no Brasil - Margem Bruta"
			cDesc04 := "Empresa no Exterior - Receita Líquida"
			cDesc05 := "Empresa Exterior - Lucro Bruto"
			cDesc06 := "Empresa Exterior - Margem Bruta"
			cDesc07 := "País da Parte Testada"
			cDesc08 := "Ajuste Risco - País"
			cDesc09 := "Empresa Comparável - Margem Bruta Mínima"
			cDesc10 := "Empresa Comparável - Margem Bruta Máxima"
			cDesc11 := "Comparável (Doméstico / Não Doméstico)"
		ElseIf ( cAliasQry )->V17_METODO == 'MCL'
			cDesc01 := "Empresa Brasil - Custos (diretos e indiretos)"
			cDesc02 := "Empresa Brasil - Lucro Bruto"
			cDesc03 := "Empresa Brasil - Margem Bruta"
			cDesc04 := "Empresa Exterior Custos (diretos e indiretos)"
			cDesc05 := "Empresa Exterior Lucro Bruto"
			cDesc06 := "Empresa Exterior Margem Bruta"
			cDesc07 := "Parte Testada - País"
			cDesc08 := "Ajuste Risco_País"
			cDesc09 := "Empresa Comparável - Margem Bruta Mínima"
			cDesc10 := "Empresa Comparável - Margem Bruta Máxima"
			cDesc11 := "Comparável (Doméstico / Não Doméstico)"
		ElseIf ( cAliasQry )->V17_METODO == 'MLT'
			cDesc01 := "Empresa Brasil - Lucro Operacional"
			cDesc02 := "Empresa Brasil - Valor Indicador"
			cDesc03 := "Empresa Brasil - Margem Líquida"
			cDesc04 := "Empresa Exterior - Lucro Operacional"
			cDesc05 := "Empresa Exterior Valor Indicador"
			cDesc06 := "Empresa Exterior Margem Líquida"
			cDesc07 := "Parte Testada - País"
			cDesc08 := "Ajuste Risco - País"
			cDesc09 := "Empresa Comparável - Margem Líquida Mínima"
			cDesc10 := "Empresa Comparável - Margem Líquida Máxima"
			cDesc11 := "Comparável"
		EndIf 
		
		If ( cAliasQry )->V17_METODO == 'MLT'
			//Indicador de Rentabilidade
			cStrTxt := cDelimit + "X375"											//01 - REG
			cStrTxt += cDelimit + "1"												//02 - CODIGO
			cStrTxt += cDelimit + "Indicador de Rentabilidade"						//03 - DESCRICAO
			cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_INDREN )			//04 - VALOR
			cStrTxt += cDelimit

			FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
			nSeq ++	
		EndIf
		//Nome da Parte Testada
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "2", "1")		//02 - CODIGO
		cStrTxt += cDelimit + "Nome da Parte Testada"								//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_NMPTES )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//País
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "3", "2")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc07												//03 - DESCRICAO
		cStrTxt += cDelimit + cValToChar(Val(( cAliasQry )->C08A_PAISSX))			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Brasil
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "4", "3")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc01												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMBRRL, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Brasil
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "5", "4")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc02												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMBRLB, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Brasil
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "6", "5")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc03												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMBRMB, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Exterior
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "7", "6")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc04												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMEXRL, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Exterior
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "8", "7")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc05												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMEXLB, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa no Exterior
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "9", "8")		//02 - CODIGO
		cStrTxt += cDelimit + cDesc06												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_EMEXMB, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Tipo de Comparável
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "10", "9")	//02 - CODIGO
		cStrTxt += cDelimit + "Tipo de Comparável"									//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_TIPOCP == "1", "I", Iif( ( cAliasQry )->V17_TIPOCP == "2" , "E", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Comparável
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "11", "10")	//02 - CODIGO
		cStrTxt += cDelimit + cDesc11												//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_COMPAR == "1", "D", Iif( ( cAliasQry )->V17_COMPAR == "2" , "N", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	 
		//Preço de ajuste
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "12", "11")	//02 - CODIGO
		cStrTxt += cDelimit + cDesc08               								//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_AJRCPS == "1", "S", Iif( ( cAliasQry )->V17_AJRCPS == "2" , "N", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa Comparável Minima
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "13", "12")	//02 - CODIGO
		cStrTxt += cDelimit + cDesc09												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_ECMBMA, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Empresa Comparável Máxima
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + IiF(( cAliasQry )->V17_METODO == 'MLT', "14", "13")	//02 - CODIGO
		cStrTxt += cDelimit + cDesc10												//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_ECMBMX, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
	
	ElseIf ( cAliasQry )->V17_METODO $ 'MDL'
		//Divisão de Resultados
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "1"													//02 - CODIGO
		cStrTxt += cDelimit + "Divisão de Resultados"								//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_DIVRES == "1", "AC", Iif( ( cAliasQry )->V17_AJRCPS == "2" , "AR", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Critérios ou Fatores de Rateio
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "2"													//02 - CODIGO
		cStrTxt += cDelimit + "Critérios ou Fatores de Rateio" 						//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_CRFTRT )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Resultado
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "3"													//02 - CODIGO
		cStrTxt += cDelimit + "Resultado"											//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_RESULT, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	

	ElseIf ( cAliasQry )->V17_METODO $ 'PIC'
		//Commodity
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "1"													//02 - CODIGO
		cStrTxt += cDelimit + "Commodity"											//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_COMDYT == "1", "S", Iif( ( cAliasQry )->V17_COMDYT == "2" , "N", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Tipo de Commodity
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "2"													//02 - CODIGO
		cStrTxt += cDelimit + "Tipo de Commodity" 									//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_TPCOMD )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Tipo de Comparável
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "3"													//02 - CODIGO
		cStrTxt += cDelimit + "Tipo de Comparável"									//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_TPCOMP == "1", "I", Iif( ( cAliasQry )->V17_TPCOMP == "2" , "E", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++
		//Usou Preço de Cotação
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "4"													//02 - CODIGO
		cStrTxt += cDelimit + "Usou Preço de Cotação"								//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->V17_PRCOTA == "1", "S", Iif( ( cAliasQry )->V17_PRCOTA == "2" , "N", "" ) ) )  //04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++
		//Fonte da Cotação
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "5"													//02 - CODIGO
		cStrTxt += cDelimit + "Fonte da Cotação" 									//03 - DESCRICAO
		cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V17_FTCOTA )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Preço da Cotação
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "6"													//02 - CODIGO
		cStrTxt += cDelimit + "Preço da Cotação"									//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_PRCCTA, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Data Inicial
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "7"													//02 - CODIGO
		cStrTxt += cDelimit + "Data Inicial - Precificação da Transação"    		//03 - DESCRICAO
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->V17_DTINIC )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Data Final
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "8"													//02 - CODIGO
		cStrTxt += cDelimit + "Data Final - Precificação da Transação"				//03 - DESCRICAO
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->V17_DTFINA )				//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Preço da Transação
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "9"													//02 - CODIGO
		cStrTxt += cDelimit + "Preço da Transação Controlada"			        	//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_PRTRAN, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	
		//Preço do Comparável
		cStrTxt := cDelimit + "X375"												//01 - REG
		cStrTxt += cDelimit + "10"													//02 - CODIGO
		cStrTxt += cDelimit + "Preço do Comparável"									//03 - DESCRICAO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->V17_PRCOMP, 16, 2 )			//04 - VALOR
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "X375", cStrTxt )
		nSeq ++	

	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()
//---------------------------------------------------------------------
/*/{Protheus.doc} RegsX360

Rotina para extrair e gravar as informacoes do Registro X360.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Karen Honda
@Since 04/04/2024
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegsX360( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()
Local cTpLoca	:= ""

ECFQryX( cAliasQry, aWizard, cFilSel, "X360" )

While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "X360"												//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_CODIGO )			//02 - CODIGO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_DESCRI )			//03 - DESCRICAO
	If Alltrim( ( cAliasQry )->CH6_CODIGO ) == "1"//Tipo de Arquivo Local?
		If ( cAliasQry )->CFT_TPLOCA == "1"
			cTpLoca := "AC" //Arquivo Local Completo
		ElseIf ( cAliasQry )->CFT_TPLOCA == "2"
			cTpLoca := "AS" //Arquivo Local Simplificado;
		ElseIf ( cAliasQry )->CFT_TPLOCA == "3"
			cTpLoca := "DD" //Dispensado de Entrega do Arquivo Local
		Else
			cTpLoca := "  "
		EndIf		
		cStrTxt += cDelimit + cTpLoca	//04 - VALOR
	ElseIf Alltrim( ( cAliasQry )->CH6_CODIGO ) == "34"		//Ajustes em função das regras de preço de transferência?								
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->CFT_AJTRAN == "1", "S", Iif( ( cAliasQry )->CFT_AJTRAN == "2" , "N", "" ) ) )  //04 - VALOR
	ElseIf Alltrim( ( cAliasQry )->CH6_CODIGO ) == "37"		//Houve reestruturação?
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->CFT_REESTR == "1", "S", Iif( ( cAliasQry )->CFT_REESTR == "2" , "N", "" ) ) )  //04 - VALOR
	ElseIf Alltrim( ( cAliasQry )->CH6_CODIGO ) == "38"		//Houve transferência de intangíveis?								
		cStrTxt += cDelimit + TAFConType( Iif( ( cAliasQry )->CFT_TRANIN == "1", "S", Iif( ( cAliasQry )->CFT_TRANIN == "2" , "N", "" ) ) )  //04 - VALOR
	Else
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFT_VALOR, 16, 2 )		//04 - VALOR
	EndIf	
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "X360", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegsGener

Rotina para extrair e gravar as informacoes dos Registros Genericos do Bloco X.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco
		cReg     -> Registro generico a ser gerado

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegsGener( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, cReg )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()

ECFQryX( cAliasQry, aWizard, cFilSel, cReg )

While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + cReg													//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_CODIGO )			//02 - CODIGO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_DESCRI )			//03 - DESCRICAO
	cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CFT_VALOR, 16, 2 )		//04 - VALOR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, cReg, cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryX

Executa as Querys para a extracao do Bloco X do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento
       cReg      -> Indica para qual Registro se refere a Query
	   cIdPai    -> Identificador do registro pai
	   oPrepare  -> Objeto para preparacao da Query

@Author Felipe C. Seolin
@Since 21/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryX( cAliasQry, aWizard, cFilSel, cReg, cIdPai, oPrepare )

Local cSelect  := ""
Local cSelect2 := ""
Local cSelect3 := ""
Local cSelect4 := ""
Local cSelect5 := ""
Local cSelect6 := ""
Local cSelect7 := ""
Local cSelect8 := ""
Local cFrom    := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := cFrom7   := cFrom8   := ""
Local cWhere   := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := cWhere7  := cWhere8  := ""
Local cOrderBy := ""
Local lBlocX50 := Ecf50BlX()
Local lVer007Cp:=  Iif(FindFunction("TAFECFVer"), TAFECFVer("0007"), TAFColumnPos("CAY_TPOPER"))
Local cQuery   := ""
Local aBind	   := {}
Local nI	   := 0

Default cIdPai 	 := ""
Default oPrepare := NIL

If cReg == "X280"
	
	cSelect := "CFL.CFL_CODIGO, CFM.CFM_CODIGO, CFK.CFK_ATOCON, CFK.CFK_VIGINI, CFK.CFK_VIGFIM "
	If lVer007Cp
		cSelect += ",CFK_INDCON, CFK.CFK_CNPJIN, C0A.C0A_CODIGO, CFK.CFK_RECINC, CFK.CFK_VLINCE "
	EndIf	
	cFrom := RetSqlName( "CFK" ) + " CFK "

	cFrom += "LEFT JOIN " + RetSqlName( "CFL" ) + " CFL "
	cFrom += "  ON CFL.CFL_FILIAL = '" + xFilial( "CFL" ) + "' "
	cFrom += " AND CFL.CFL_ID = CFK.CFK_IDBENF "
	cFrom += " AND CFL.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CFM" ) + " CFM "
	cFrom += "  ON CFM.CFM_FILIAL = '" + xFilial( "CFM" ) + "' "
	cFrom += " AND CFM.CFM_ID = CFK.CFK_IDINDP "
	cFrom += " AND CFM.D_E_L_E_T_ = '' "
	If lVer007Cp
		cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
		cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
		cFrom += " AND C0A.C0A_ID = CFK.CFK_NCMINC "
		cFrom += " AND C0A.D_E_L_E_T_ = '' "
	EndIf
	//cWhere := "    CFK.CFK_FILIAL IN (" + cFilSel + ") "
	cWhere := " CFK.CFK_FILIAL = '" + xFilial( "CFK" ) + "' "
	cWhere += "AND CFK.CFK_PERIOD >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND CFK.CFK_PERIOD <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFK.D_E_L_E_T_ = '' "

	cOrderBy := "CFK_FILIAL, CFK_VIGINI, CFK_VIGFIM "

ElseIf cReg $ "X300"

	cSelect := " CAY.CAY_ID, CAY.CAY_PERIOD, CAY.CAY_NUMORD, CAY.CAY_TIPEXP, CAY.CAY_DESCRI, CAY.CAY_TOTOPE, C0A.C0A_CODIGO, CAY.CAY_QUANTI, CHJ.CHJ_CODIGO, CAY.CAY_INDOPE, CAY.CAY_TIPMET, CAY.CAY_VLPAR, CAY.CAY_VLPRAT, CAY.CAY_VLAJ, CAY.CAY_TXJUR, CAY.CAY_TXJMIN, CAY.CAY_TXJMAX, CZT.CZT_CODIGO, CZU.CZU_SIGLAM "
	
	If lVer007Cp
		cSelect += ",  CAY.CAY_TPOPER, CAY.CAY_DESCPA, CAY.CAY_TPBEM, CAY.CAY_DTUTIL, CAY.CAY_DESCME, CAY.CAY_DTNEGC, CAY.CAY_DTEMBQ, V6U.V6U_CODFCO,CAY.CAY_AJUPAR, CAY.CAY_QTDAJU, CAY.CAY_VLRCOT, CAY.CAY_NUMDEC, CAY.CAY_DTENPR, CAY.CAY_IDPAEN "
	EndIf
	cFrom := RetSqlName( "CAY" ) + " CAY "

	cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
	cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
	cFrom += " AND C0A.C0A_ID = CAY.CAY_CODNCM "
	cFrom += " AND C0A.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1J" ) + " C1J "
	cFrom += "  ON C1J.C1J_FILIAL = '" + xFilial( "C1J" ) + "' "
	cFrom += " AND C1J.C1J_ID = CAY.CAY_UNIDAD "
	cFrom += " AND C1J.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CHJ" ) + " CHJ "
	cFrom += "  ON CHJ.CHJ_FILIAL = '" + xFilial( "CHJ" ) + "' "
	cFrom += " AND CHJ.CHJ_ID = C1J.C1J_IDUMEC "
	cFrom += " AND CHJ.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CZT" ) + " CZT "
	cFrom += "  ON CZT.CZT_FILIAL = '" + xFilial( "CZT" ) + "' "
	cFrom += " AND CZT.CZT_ID = CAY.CAY_IDCNC "
	cFrom += " AND CZT.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom += " AND CZU.CZU_ID = CAY.CAY_IDMOED "
	cFrom += " AND CZU.D_E_L_E_T_ = '' "
	If lVer007Cp
		cFrom += "LEFT JOIN " + RetSqlName( "V6U" ) + " V6U "
		cFrom += "  ON V6U.V6U_FILIAL = '" + xFilial( "V6U" ) + "' "
		cFrom += " AND V6U.V6U_ID = CAY.CAY_IDFCOT "
		cFrom += " AND V6U.D_E_L_E_T_ = '' "
	EndIf
	cWhere := " CAY.CAY_FILIAL = '" + xFilial( "CAY" ) + "' "
	cWhere += "AND CAY.CAY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CAY.D_E_L_E_T_ = '' "

	cOrderBy := "CAY_FILIAL, CAY_PERIOD "

ElseIf cReg $ "X310"

	cSelect := "  CAY.CAY_PERIOD, CAY.CAY_NUMORD, CAZ.CAZ_NOME, C08.C08_PAISSX, CAZ.CAZ_IDINC, CAZ.CAZ_VLOPER, CAZ.CAZ_CONDPE "

	cFrom := RetSqlName( "CAY" ) + " CAY "

	cFrom += "INNER JOIN " + RetSqlName( "CAZ" ) + " CAZ "
	cFrom += "  ON CAZ.CAZ_FILIAL = CAY.CAY_FILIAL "
	cFrom += " AND CAZ.CAZ_ID = CAY.CAY_ID
	cFrom += " AND CAZ.D_E_L_E_T_ = ''

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CAZ.CAZ_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cWhere := " CAY.CAY_FILIAL = '" + xFilial( "CAY" ) + "' "
	cWhere += "AND CAY.CAY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CAY.D_E_L_E_T_ = '' "
	cWhere += "AND CAY.CAY_ID = '"+cIdPai+"' "

	cOrderBy := " CAY_FILIAL, CAY_PERIOD, CAZ_IDINC "

ElseIf cReg $ "X305"

	cSelect := "  CAY.CAY_PERIOD, CAY.CAY_NUMORD,V6R_ID,V6R_NUMITE,V6R_DOAJUS,V6R_VLRAJU,V6R_FNTAJU,V6T_CODTPA "

	cFrom := RetSqlName( "CAY" ) + " CAY "

	cFrom += "INNER JOIN " + RetSqlName( "V6R" ) + " V6R "
	cFrom += "  ON V6R.V6R_FILIAL = CAY.CAY_FILIAL "
	cFrom += " AND V6R.V6R_ID = CAY.CAY_ID "
	cFrom += " AND V6R.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "V6T" ) + " V6T "
	cFrom += "  ON V6T.V6T_FILIAL = '" + xFilial( "V6T" ) + "' "
	cFrom += " AND V6T.V6T_ID = V6R.V6R_IDTPAJ "
	cFrom += " AND V6T.D_E_L_E_T_ = '' "

	cWhere := " CAY.CAY_FILIAL = '" + xFilial( "CAY" ) + "' "
	cWhere += "AND CAY.CAY_ID = '"+cIdPai+"' "
	cWhere += "AND CAY.CAY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CAY.D_E_L_E_T_ = '' "

	cOrderBy := " CAY_FILIAL, CAY_PERIOD, V6R_NUMITE "

ElseIf cReg $ "X320"

	cSelect := " CFV.CFV_ID, CFV.CFV_PERIOD, CFV.CFV_NUMORD, CFV.CFV_TIPEXP, CFV.CFV_DESCRI, CFV.CFV_TOTOPE, C0A.C0A_CODIGO, CFV.CFV_QUANTI, CHJ.CHJ_CODIGO, CFV.CFV_TIPMET, CFV.CFV_VLPAR, CFV.CFV_VLPRAT, CFV.CFV_VLAJ, CFV.CFV_TXJUR, CFV.CFV_TXJMIN, CFV.CFV_TXJMAX, CZT.CZT_CODIGO, CZU.CZU_CODIGO "
	If lVer007Cp
		cSelect += ", C1L.C1L_CODIGO,  CFV.CFV_UTINPR,CFV.CFV_OPAPPA,CFV.CFV_DESPAR,CFV.CFV_TPPAR,CFV.CFV_DTUTIL,CFV.CFV_CRIDET,CFV.CFV_DTTRAN,CFV.CFV_DTDUIM,V6U.V6U_CODFCO,CFV.CFV_AJUPAR "
		cSelect += ", CFV.CFV_QTDAJU, CFV.CFV_VLRCOT, CFV.CFV_NUMDEC, CFV.CFV_DTENPR,CFV.CFV_IDPAEN "
	EndIf
	cFrom := RetSqlName( "CFV" ) + " CFV "

	cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
	cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
	cFrom += " AND C0A.C0A_ID = CFV.CFV_CODNCM "
	cFrom += " AND C0A.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C1J" ) + " C1J "
	cFrom += "  ON C1J.C1J_FILIAL = '" + xFilial( "C1J" ) + "' "
	cFrom += " AND C1J.C1J_ID = CFV.CFV_UNIDAD "
	cFrom += " AND C1J.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CHJ" ) + " CHJ "
	cFrom += "  ON CHJ.CHJ_FILIAL = '" + xFilial( "CHJ" ) + "' "
	cFrom += " AND CHJ.CHJ_ID = C1J.C1J_IDUMEC "
	cFrom += " AND CHJ.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CZT" ) + " CZT "
	cFrom += "  ON CZT.CZT_FILIAL = '" + xFilial( "CZT" ) + "' "
	cFrom += " AND CZT.CZT_ID = CFV.CFV_IDCNC "
	cFrom += " AND CZT.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom += " AND CZU.CZU_ID = CFV.CFV_IDMOED "
	cFrom += " AND CZU.D_E_L_E_T_ = '' "
	If lVer007Cp
		cFrom += "LEFT JOIN " + RetSqlName( "V6U" ) + " V6U "
		cFrom += "  ON V6U.V6U_FILIAL = '" + xFilial( "V6U" ) + "' "
		cFrom += " AND V6U.V6U_ID = CFV.CFV_IDFOCO "
		cFrom += " AND V6U.D_E_L_E_T_ = '' "

		cFrom += "LEFT JOIN " + RetSqlName( "C1L" ) + " C1L "
		cFrom += "  ON C1L.C1L_FILIAL = '" + xFilial( "C1L" ) + "' "
		cFrom += " AND C1L.C1L_ID = CFV.CFV_IDITEM "
		cFrom += " AND C1L.D_E_L_E_T_ = '' "
	EndIf
	cWhere := " CFV.CFV_FILIAL = '" + xFilial( "CFV" ) + "' "
	cWhere += "AND CFV.CFV_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFV.D_E_L_E_T_ = '' "

	cOrderBy := "CFV_FILIAL, CFV_PERIOD "

ElseIf cReg $ "X325"

	cSelect := "  CFV.CFV_PERIOD, CFV.CFV_NUMORD,V6S_ID,V6S_NUMITE,V6S_DOAJUS,V6S_VLRAJU,V6S_FNTAJU,V6T_CODTPA "

	cFrom := RetSqlName( "CFV" ) + " CFV "

	cFrom += "INNER JOIN " + RetSqlName( "V6S" ) + " V6S "
	cFrom += "  ON V6S.V6S_FILIAL = CFV.CFV_FILIAL "
	cFrom += " AND V6S.V6S_ID = CFV.CFV_ID "
	cFrom += " AND V6S.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "V6T" ) + " V6T "
	cFrom += "  ON V6T.V6T_FILIAL = '" + xFilial( "V6T" ) + "' "
	cFrom += " AND V6T.V6T_ID = V6S.V6S_IDTPAJ "
	cFrom += " AND V6T.D_E_L_E_T_ = '' "

	cWhere := " CFV.CFV_FILIAL = '" + xFilial( "CFV" ) + "' "
	cWhere += "AND CFV.CFV_ID = '"+cIdPai+"' "
	cWhere += "AND CFV.CFV_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFV.D_E_L_E_T_ = '' "

	cOrderBy := "CFV_FILIAL, CFV_PERIOD, V6S_NUMITE "

ElseIf cReg $ "X330"

	cSelect := "  CFV.CFV_PERIOD, CFV.CFV_NUMORD,  CFX.CFX_NOME, C08.C08_PAISSX, CFX.CFX_VLOPER, CFX.CFX_CONDPE, CFX.CFX_IDINC"

	cFrom := RetSqlName( "CFV" ) + " CFV "

	cFrom += "INNER JOIN " + RetSqlName( "CFX" ) + " CFX "
	cFrom += "  ON CFX.CFX_FILIAL = CFV.CFV_FILIAL "
	cFrom += " AND CFX.CFX_ID = CFV.CFV_ID "
	cFrom += " AND CFX.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CFX.CFX_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cWhere := " CFV.CFV_FILIAL = '" + xFilial( "CFV" ) + "' "
	cWhere += "AND CFV.CFV_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFV.D_E_L_E_T_ = '' "
	cWhere += "AND CFV.CFV_ID = '"+cIdPai+"' "

	cOrderBy := "CFV_FILIAL, CFV_PERIOD, CFX.CFX_IDINC"

ElseIf cReg $ "X340"

	// ***************************************
	// UNION com informações do Registro X350
	// ***************************************

	cSelect := " 'X350' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect += ", CFY.CFY_CNPJ "
	EndIf
	cSelect += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect += ", CFZ.CFZ_RECLIQ, CFZ.CFZ_VLCUST, CFZ.CFZ_LUCBRT, CFZ.CFZ_RECAUF, CFZ.CFZ_RECOPE, CFZ.CFZ_DSPFIN, CFZ.CFZ_DSPOPE, CFZ.CFZ_LUCOPE, CFZ.CFZ_RECPAR, CFZ.CFZ_RECOUT, CFZ.CFZ_DSPOUT, CFZ.CFZ_LUCIR, CFZ.CFZ_IMPDEV, CFZ.CFZ_LUCPA, CFZ.CFZ_LUCANT, CFZ.CFZ_IMPARB, CFZ.CFZ_LUCAPO "

	//SELECT campos do Registro X351
	cSelect += ", 0 CHL_RESINV, 0 CHL_RESPOS, 0 CHL_RESOPE, 0 CHL_RESREP, 0 CHL_RESNEG, 0 CHL_RESPTB, 0 CHL_RESPTR, 0 CHL_IMPPAG, 0 CHL_IMPPGR, 0 CHL_IMPREN, 0 CHL_IMPRER, 0 CHL_IMPREX, 0 CHL_IMPRRE, 0 CHL_IMPRBR "

	//SELECT campos do Registro X352
	cSelect += ", 0 CHM_RESPER, 0 CHM_RESPRE, 0 CHM_LUCDIS, 0 CHM_LUCDRE "

	//SELECT campos do Registro X353
	cSelect += ", 0 CHN_RESNEG, 0 CHN_RESNRE, 0 CHN_SLDNEG, 0 CHN_SLDNRE "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect += ", 0 CHN_RPROP, 0 CHN_RPREAL "
	Endif

	//SELECT campos do Registro X354
	cSelect += ", 0 CHO_RESNEG, 0 CHO_RESNRE, 0 CHO_SLDNEG "

	//SELECT campos do Registro X355
	cSelect += ", 0 CHP_RENPAS, 0 CHP_RENPRE, 0 CHP_RENTOT, 0 CHP_RENTRE, 0 CHP_RENATV, 0 CHP_RENARE, 0 CHP_PERCEN "

	//SELECT campos do Registro X356
	cSelect += ", 0 CHQ_PERPAR, 0 CHQ_ATVTOT, 0 CHQ_PATLIQ "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect += ", ' ' V3M_PAIS, ' ' V3M_NIF, ' ' V3M_RAZSOC, 0 V3M_PERCPI "
	endif

	cFrom := RetSqlName( "CFY" ) + " CFY "

	cFrom += "LEFT JOIN " + RetSqlName( "CFZ" ) + " CFZ "
	cFrom += "  ON CFZ.CFZ_FILIAL = CFY.CFY_FILIAL "
	cFrom += " AND CFZ.CFZ_ID = CFY.CFY_ID "
	cFrom += " AND CFZ.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X351
	// ***************************************

	cSelect2 := " 'X351' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect2 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect2 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect2 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect2 += ", CHL.CHL_RESINV, CHL.CHL_RESPOS, CHL.CHL_RESOPE, CHL.CHL_RESREP, CHL.CHL_RESNEG, CHL.CHL_RESPTB, CHL.CHL_RESPTR, CHL.CHL_IMPPAG, CHL.CHL_IMPPGR, CHL.CHL_IMPREN, CHL.CHL_IMPRER, CHL.CHL_IMPREX, CHL.CHL_IMPRRE, CHL.CHL_IMPRBR "

	//SELECT campos do Registro X352
	cSelect2 += ", 0, 0, 0, 0 "

	//SELECT campos do Registro X353
	cSelect2 += ", 0, 0, 0, 0 "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect2 += ", 0, 0 "
	Endif

	//SELECT campos do Registro X354
	cSelect2 += ", 0, 0, 0 "

	//SELECT campos do Registro X355
	cSelect2 += ", 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X356
	cSelect2 += ", 0, 0, 0 "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect2 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom2 := RetSqlName( "CFY" ) + " CFY "

	cFrom2 += "LEFT JOIN " + RetSqlName( "CHL" ) + " CHL "
	cFrom2 += "  ON CHL.CHL_FILIAL = CFY.CFY_FILIAL "
	cFrom2 += " AND CHL.CHL_ID = CFY.CFY_ID "
	cFrom2 += " AND CHL.D_E_L_E_T_ = '' "

	cFrom2 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom2 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom2 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom2 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom2 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom2 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom2 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom2 += " AND CZU.D_E_L_E_T_ = '' "

	//SELECT campos do Registro X357

	//cWhere2 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere2 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere2 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere2 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X352
	// ***************************************

	cSelect3 := " 'X352' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect3 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect3 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect3 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect3 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X352
	cSelect3 += ", CHM.CHM_RESPER, CHM.CHM_RESPRE, CHM.CHM_LUCDIS, CHM.CHM_LUCDRE "

	//SELECT campos do Registro X353
	cSelect3 += ", 0, 0, 0, 0 "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect3 += ", 0, 0 "
	Endif

	//SELECT campos do Registro X354
	cSelect3 += ", 0, 0, 0 "

	//SELECT campos do Registro X355
	cSelect3 += ", 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X356
	cSelect3 += ", 0, 0, 0 "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect3 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom3 := RetSqlName( "CFY" ) + " CFY "

	cFrom3 += "LEFT JOIN " + RetSqlName( "CHM" ) + " CHM "
	cFrom3 += "  ON CHM.CHM_FILIAL = CFY.CFY_FILIAL "
	cFrom3 += " AND CHM.CHM_ID = CFY.CFY_ID "
	cFrom3 += " AND CHM.D_E_L_E_T_ = '' "

	cFrom3 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom3 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom3 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom3 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom3 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom3 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom3 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom3 += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere3 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere3 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere3 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere3 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X353
	// ***************************************

	cSelect4 := " 'X353' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect4 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect4 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect4 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect4 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X352
	cSelect4 += ", 0, 0, 0, 0 "

	//SELECT campos do Registro X353
	cSelect4 += ", CHN.CHN_RESNEG, CHN.CHN_RESNRE, CHN.CHN_SLDNEG, CHN.CHN_SLDNRE "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect4 += ", CHN.CHN_RPROP, CHN.CHN_RPREAL "
	Endif

	//SELECT campos do Registro X354
	cSelect4 += ", 0, 0, 0 "

	//SELECT campos do Registro X355
	cSelect4 += ", 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X356
	cSelect4 += ", 0, 0, 0 "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect4 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom4 := RetSqlName( "CFY" ) + " CFY "

	cFrom4 += "LEFT JOIN " + RetSqlName( "CHN" ) + " CHN "
	cFrom4 += "  ON CHN.CHN_FILIAL = CFY.CFY_FILIAL "
	cFrom4 += " AND CHN.CHN_ID = CFY.CFY_ID "
	cFrom4 += " AND CHN.D_E_L_E_T_ = '' "

	cFrom4 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom4 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom4 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom4 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom4 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom4 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom4 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom4 += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere4 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere4 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere4 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere4 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X354
	// ***************************************

	cSelect5 := " 'X354' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect5 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect5 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect5 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect5 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X352
	cSelect5 += ", 0, 0, 0, 0 "

	//SELECT campos do Registro X353
	cSelect5 += ", 0, 0, 0, 0 "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect5 += ", 0, 0 "
	Endif

	//SELECT campos do Registro X354
	cSelect5 += ", CHO.CHO_RESNEG, CHO.CHO_RESNRE, CHO.CHO_SLDNEG "

	//SELECT campos do Registro X355
	cSelect5 += ", 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X356
	cSelect5 += ", 0, 0, 0 "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect5 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom5 := RetSqlName( "CFY" ) + " CFY "

	cFrom5 += "LEFT JOIN " + RetSqlName( "CHO" ) + " CHO "
	cFrom5 += "  ON CHO.CHO_FILIAL = CFY.CFY_FILIAL "
	cFrom5 += " AND CHO.CHO_ID = CFY.CFY_ID "
	cFrom5 += " AND CHO.D_E_L_E_T_ = '' "

	cFrom5 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom5 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom5 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom5 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom5 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom5 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom5 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom5 += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere5 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere5 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere5 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere5 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X355
	// ***************************************

	cSelect6 := " 'X355' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect6 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect6 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect6 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect6 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X352
	cSelect6 += ", 0, 0, 0, 0 "

	//SELECT campos do Registro X353
	cSelect6 += ", 0, 0, 0, 0 "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect6 += ", 0, 0 "
	Endif

	//SELECT campos do Registro X354
	cSelect6 += ", 0, 0, 0 "

	//SELECT campos do Registro X355
	cSelect6 += ", CHP.CHP_RENPAS, CHP.CHP_RENPRE, CHP.CHP_RENTOT, CHP.CHP_RENTRE, CHP.CHP_RENATV, CHP.CHP_RENARE, CHP.CHP_PERCEN "

	//SELECT campos do Registro X356
	cSelect6 += ", 0, 0, 0 "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect6 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom6 := RetSqlName( "CFY" ) + " CFY "

	cFrom6 += "LEFT JOIN " + RetSqlName( "CHP" ) + " CHP "
	cFrom6 += "  ON CHP.CHP_FILIAL = CFY.CFY_FILIAL "
	cFrom6 += " AND CHP.CHP_ID = CFY.CFY_ID "
	cFrom6 += " AND CHP.D_E_L_E_T_ = '' "

	cFrom6 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom6 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom6 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom6 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom6 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom6 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom6 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom6 += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere6 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere6 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere6 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere6 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X356
	// ***************************************

	cSelect7 := " 'X356' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
	If TAFColumnPos( "CFY_CNPJ" ) 
		cSelect7 += ", CFY.CFY_CNPJ "
	EndIf
	cSelect7 += ", CZU.CZU_SIGLAM "
	//SELECT campos do Registro X350
	cSelect7 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X351
	cSelect7 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X352
	cSelect7 += ", 0, 0, 0, 0 "

	//SELECT campos do Registro X353
	cSelect7 += ", 0, 0, 0, 0 "
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect7 += ", 0, 0 "
	Endif

	//SELECT campos do Registro X354
	cSelect7 += ", 0, 0, 0 "

	//SELECT campos do Registro X355
	cSelect7 += ", 0, 0, 0, 0, 0, 0, 0 "

	//SELECT campos do Registro X356
	cSelect7 += ", CHQ.CHQ_PERPAR, CHQ.CHQ_ATVTOT, CHQ.CHQ_PATLIQ "

	//SELECT campos do Registro X357
	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect7 += ", ' ', ' ', ' ', 0 "
	endif

	cFrom7 := RetSqlName( "CFY" ) + " CFY "

	cFrom7 += "LEFT JOIN " + RetSqlName( "CHQ" ) + " CHQ "
	cFrom7 += "  ON CHQ.CHQ_FILIAL = CFY.CFY_FILIAL "
	cFrom7 += " AND CHQ.CHQ_ID = CFY.CFY_ID "
	cFrom7 += " AND CHQ.D_E_L_E_T_ = '' "

	cFrom7 += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom7 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom7 += " AND C08.C08_ID = CFY.CFY_PAIS "
	cFrom7 += " AND C08.D_E_L_E_T_ = '' "
	
	cFrom7 += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
	cFrom7 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
	cFrom7 += " AND CZU.CZU_ID = CFY.CFY_IDMOED "
	cFrom7 += " AND CZU.D_E_L_E_T_ = '' "

	//cWhere7 := "      CFY.CFY_FILIAL IN (" + cFilSel + ") "
	cWhere7 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
	cWhere7 += "  AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere7 += "  AND CFY.D_E_L_E_T_ = '' "

	// ***************************************
	// UNION com informações do Registro X357
	// ***************************************

	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"

		cSelect8 := " 'X357' REGISTRO, CFY.CFY_RAZSOC, CFY.CFY_NIF CFY_NIF, CFY.CFY_INDCTL, C08.C08_PAISSX, CFY.CFY_INDREP, CFY.CFY_INDCON, CFY.CFY_MOTNCO "
		If TAFColumnPos( "CFY_CNPJ" ) 
			cSelect8 += ", CFY.CFY_CNPJ "
		EndIf
		cSelect8 += ", CZU.CZU_SIGLAM "
		//SELECT campos do Registro X350
		cSelect8 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

		//SELECT campos do Registro X351
		cSelect8 += ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 "

		//SELECT campos do Registro X352
		cSelect8 += ", 0, 0, 0, 0 "

		//SELECT campos do Registro X353
		cSelect8 += ", 0, 0, 0, 0, 0, 0 "

		//SELECT campos do Registro X354
		cSelect8 += ", 0, 0, 0 "

		//SELECT campos do Registro X355
		cSelect8 += ", 0, 0, 0, 0, 0, 0, 0 "

		//SELECT campos do Registro X356
		cSelect8 += ", 0, 0, 0 "

		//SELECT campos do Registro X357
		cSelect8 += ", V3M.V3M_PAIS, V3M.V3M_NIF, V3M.V3M_RAZSOC, V3M.V3M_PERCPI "

		cFrom8 := RetSqlName( "CFY" ) + " CFY "

		cFrom8 += " LEFT JOIN " + RetSqlName( "V3M" ) + " V3M "
		cFrom8 += "  ON V3M.V3M_FILIAL = CFY.CFY_FILIAL "
		cFrom8 += "  AND V3M.V3M_ID = CFY.CFY_ID "
		cFrom8 += "  AND V3M.D_E_L_E_T_ = '' "

		cFrom8 += " LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
		cFrom8 += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
		cFrom8 += "  AND C08.C08_ID = CFY.CFY_PAIS "
		cFrom8 += "  AND C08.D_E_L_E_T_ = '' "
		
		cFrom8 += " LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
		cFrom8 += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
		cFrom8 += "  AND CZU.CZU_ID = CFY.CFY_IDMOED "
		cFrom8 += "  AND CZU.D_E_L_E_T_ = '' "

		cWhere8 := " CFY.CFY_FILIAL = '" + xFilial( "CFY" ) + "' "
		cWhere8 += " AND CFY.CFY_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
		cWhere8 += " AND CFY.D_E_L_E_T_ = '' "
	endif

	cOrderBy := "CFY_NIF, REGISTRO "

ElseIf cReg $ "X410"

	cSelect := "C08.C08_PAISSX, CG0.CG0_HOMEDI, CG0.CG0_SERVDI "

	cFrom := RetSqlName( "CG0" ) + " CG0 "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CG0.CG0_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	//cWhere := "    CG0.CG0_FILIAL IN (" + cFilSel + ") "
	cWhere := " CG0.CG0_FILIAL = '" + xFilial( "CG0" ) + "' "
	cWhere += "AND CG0.CG0_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CG0.D_E_L_E_T_ = '' "

	cOrderBy := "CG0_FILIAL, CG0_PERIOD "

ElseIf cReg $ "X420"

	cSelect := "CG2.CG2_TIPROY, C08.C08_PAISSX, CG2.CG2_VLSW, CG2.CG2_VLAUT, CG2.CG2_VLMARC, CG2.CG2_VLPAT, CG2.CG2_VLKNOW, CG2.CG2_VLFRAN, CG2.CG2_VLINT "

	cFrom := RetSqlName( "CG2" ) + " CG2 "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CG2.CG2_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	//cWhere := "    CG2.CG2_FILIAL IN (" + cFilSel + ") "
	cWhere := " CG2.CG2_FILIAL = '" + xFilial( "CG2" ) + "' "
	cWhere += "AND CG2.CG2_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CG2.D_E_L_E_T_ = '' "

	cOrderBy := "CG2_FILIAL, CG2_PERIOD "

ElseIf cReg $ "X430"

	cSelect := "C08.C08_PAISSX, CG3.CG3_VLASSI, CG3.CG3_VLTEC, CG3.CG3_VLEXT, CG3.CG3_VLJUR, CG3.CG3_VLDJU, CG3.CG3_VLDIVI "

	cFrom := RetSqlName( "CG3" ) + " CG3 "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = CG3.CG3_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	//cWhere := "    CG3.CG3_FILIAL IN (" + cFilSel + ") "
	cWhere := " CG3.CG3_FILIAL = '" + xFilial( "CG3" ) + "' "
	cWhere += "AND CG3.CG3_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CG3.D_E_L_E_T_ = '' "

	cOrderBy := "CG3_FILIAL, CG3_PERIOD "

ElseIf cReg $ "X450"

	//Campos para o registro X450
	cQuery := " SELECT C08.C08_PAISSX,"
	cQuery += " CG5.CG5_VLASSI, "
	cQuery += " CG5.CG5_VLTEC, "
	cQuery += " CG5.CG5_VLEXT, "
	cQuery += " CG5.CG5_VLJPF, "
	cQuery += " CG5.CG5_VLJPJ, "
	cQuery += " CG5.CG5_VLDJUR, "
	cQuery += " CG5.CG5_DIVIPF, "
	cQuery += " CG5.CG5_DIVIPJ, "
	cQuery += " CG5.CG5_ID CG5ID "

	cQuery += " FROM " + RetSqlName( "CG5" ) + " CG5 "

	cQuery += " LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cQuery += " ON C08.C08_FILIAL = ? "
	cQuery += " AND C08.C08_ID = CG5.CG5_PAIS "
	cQuery += " AND C08.D_E_L_E_T_ = ? "
	aAdd(aBind, xFilial( "C08" ) )
	aAdd(aBind, Space(1))

	cQuery += " WHERE CG5.CG5_FILIAL = ? "
	cQuery += " AND CG5.CG5_PERIOD BETWEEN ? AND ? "
	cQuery += " AND CG5.D_E_L_E_T_ = ? "
	aAdd(aBind, xFilial( "CG5" ) )
	aAdd(aBind, DToS( aWizard[1,1] ) )
	aAdd(aBind, DToS( aWizard[1,2] ) )
	aAdd(aBind, Space(1))

	cQuery += " ORDER BY CG5_FILIAL,"
	cQuery += " CG5_PERIOD "

	cQuery := ChangeQuery(cQuery)
	oPrepare := FwExecStatement():New(cQuery)

	for nI := 1 to len(aBind)
		oPrepare:setString( nI, aBind[nI] )
	next nI

	oPrepare:OpenAlias(cAliasQry)

ElseIf cReg $ "X451"

	//Campos para o registro X451
	cQuery := " SELECT T17.T17_CODIGO COD_LINHA, "
	cQuery += " T17.T17_DESCRI DESC_LINHA, "
	cQuery += " T1C.T1C_VALOR T1CVALOR "

	cQuery += " FROM " +RetSqlName( "T1C" ) + " T1C "

	cQuery += " RIGHT JOIN " + RetSqlName( "T17" ) + " T17 "
	cQuery += " ON T17.T17_FILIAL = ? "
	cQuery += " AND T17.T17_ID = T1C.T1C_IDCPAG "
	cQuery += " AND T17.D_E_L_E_T_ = ? "
	aAdd(aBind, xFilial( "T17" ) )
	aAdd(aBind, Space(1))

	cQuery += " AND T1C.T1C_ID = ? "
	cQuery += " AND T1C.D_E_L_E_T_ = ? "
	aAdd(aBind, cIdPai )
	aAdd(aBind, Space(1))

	cQuery += " WHERE T17.D_E_L_E_T_ = ? "
	aAdd(aBind, Space(1))

	cQuery := ChangeQuery(cQuery)
	oPrepare := FwExecStatement():New(cQuery)

	for nI := 1 to len(aBind)
		oPrepare:setString( nI, aBind[nI] )
	next nI

	oPrepare:OpenAlias(cAliasQry)

ElseIf cReg $ "X485"

	cSelect := "V55.V55_TPBENE, V55.V55_ATODEC, V55.V55_CNPJIN, V55.V55_IDOB18, V55.V55_IDOB20, V55.V55_IDOBEI, V55.V55_PORTCE, V55.V55_DTDOUC, V55.V55_DTINIC, V55.V55_DTFIMC "

	cFrom := RetSqlName( "V55" ) + " V55 "

	cWhere := " V55.V55_FILIAL = '" + xFilial( "V55" ) + "' "
	cWhere += "AND V55.V55_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND V55.V55_STATUS IN ('', '0') "
	cWhere += "AND V55.D_E_L_E_T_ = ' ' "

	cOrderBy := "V55_FILIAL, V55_PERIOD "

ElseIf cReg $ "X291|X292|X360|X390|X400|X460|X470|X480|X490|X500|X510"

	cSelect := "CH6.CH6_CODIGO, CH6.CH6_DESCRI, CFT.CFT_VALOR "
	If cReg == "X360"
		cSelect += ", CFT.CFT_TPLOCA, CFT.CFT_AJTRAN, CFT.CFT_REESTR, CFT.CFT_TRANIN "
	EndIf

	cFrom := RetSqlName( "CFT" ) + " CFT "

	cFrom += "INNER JOIN " + RetSqlName( "CFU" ) + " CFU "
	cFrom += "  ON CFU.CFU_FILIAL = '" + xFilial( "CFU" ) + "' "
	cFrom += " AND CFU.CFU_ID = CFT.CFT_IDRECF "
	cFrom += " AND CFU.D_E_L_E_T_ = ' ' "

	cFrom += "INNER JOIN " + RetSqlName( "CH6" ) + " CH6 "
	cFrom += "   ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
	cFrom += "  AND CH6.CH6_ID = CFT.CFT_IDCODL "
	cFrom += "  AND CH6.D_E_L_E_T_ = ' ' "

	//cWhere := "    CFT.CFT_FILIAL IN (" + cFilSel + ") "
	cWhere := " CFT.CFT_FILIAL = '" + xFilial( "CFT" ) + "' "
	cWhere += "AND CFT.CFT_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND CFU.CFU_CODIGO = '" + cReg + "' "
	cWhere += "AND CFT.D_E_L_E_T_ = ' ' "

	cOrderBy := "CFT_FILIAL " 
	If cReg $ "X291"
		cOrderBy += ",CH6_CODIGO "
	EndIf 	 
	cOrderBy += ",CFT_PERIOD "

ElseIf cReg $ "X365"

	cSelect := "V15.V15_ID, V15.V15_IDENT, V15.V15_NOME, V15.V15_NIF, "   
	cSelect += "V15.V15_PAIS, V15.V15_PARREL, V15.V15_HIPOTE, V15.V15_VLRPGT, V15.V15_VLRREC, C08.C08_PAISSX "

	cFrom := RetSqlName( "V15" ) + " V15 "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = V15.V15_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cWhere := " V15.V15_FILIAL = '" + xFilial( "V15" ) + "' "
	cWhere += "AND V15.V15_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND V15.V15_STATUS IN ('', '0') "
	cWhere += "AND V15.D_E_L_E_T_ = ' ' "

	cOrderBy := "V15.V15_FILIAL, V15.V15_PERIOD "

ElseIf cReg $ "X370"

	cSelect := "V17.V17_ID, V15.V15_IDENT, V17.V17_TPTRAN, V15.V15_NOME, C0A.C0A_CODIGO, V17.V17_TPDEMA, V17.V17_DBSDI, V17.V17_VLTRAN, V17.V17_INDAJU, "
	cSelect += "V17.V17_VLESPO, V17.V17_VLCOMP, V17.V17_TPAJUS, V17.V17_METODO, V17.V17_DMETOD, V17.V17_COMINT, V17.V17_SINERG, V17.V17_INDTRA, V17.V17_INDDAD, V17.V17_INDSIM, "
	cSelect += "V17.V17_NMPTES, V17.V17_PPTTES, V17.V17_EMBRRL, V17.V17_EMBRLB, V17.V17_EMBRMB, V17.V17_EMEXRL, V17.V17_EMEXLB, V17.V17_EMEXMB, V17.V17_TIPOCP, V17.V17_COMPAR, "
	cSelect += "V17.V17_AJRCPS, V17.V17_ECMBMA, V17.V17_ECMBMX, V17.V17_INDREN, V17.V17_DIVRES, V17.V17_CRFTRT, V17.V17_RESULT, V17.V17_COMDYT, V17.V17_TPCOMD, V17.V17_TPCOMP, "
	cSelect += "V17.V17_PRCOTA, V17.V17_FTCOTA, V17.V17_PRCCTA, V17.V17_DTINIC, V17.V17_DTFINA, V17.V17_PRTRAN, V17.V17_PRCOMP, C08.C08_PAISSX, C08A.C08_PAISSX C08A_PAISSX "

	cFrom := RetSqlName( "V17" ) + " V17 "

	cFrom += "LEFT JOIN " + RetSqlName( "V15" ) + " V15 "
	cFrom += " ON V15.V15_FILIAL = '" + xFilial( "V15" ) + "' "
	cFrom += " AND V15.V15_ID = V17.V17_IDIDEN "
	cFrom += " AND V15.D_E_L_E_T_ = ' ' "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
	cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08.C08_ID = V17.V17_PAIS "
	cFrom += " AND C08.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08A "
	cFrom += "  ON C08A.C08_FILIAL = '" + xFilial( "C08" ) + "' "
	cFrom += " AND C08A.C08_ID = V17.V17_PPTTES "
	cFrom += " AND C08A.D_E_L_E_T_ = '' "

	cFrom += "LEFT JOIN " + RetSqlName( "C0A" ) + " C0A "
	cFrom += "  ON C0A.C0A_FILIAL = '" + xFilial( "C0A" ) + "' "
	cFrom += " AND C0A.C0A_ID = V17.V17_CODNCM "
	cFrom += " AND C0A.D_E_L_E_T_ = '' "

	cWhere := " V17.V17_FILIAL = '" + xFilial( "V17" ) + "' "
	cWhere += "AND V17.V17_PERIOD BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND V17.V17_STATUS IN ('', '0') "
	cWhere += "AND V17.D_E_L_E_T_ = ' ' "

	cOrderBy := "V17.V17_FILIAL, V17.V17_PERIOD "

ElseIf cReg $ "X371"

	cSelect := "C1O.C1O_CODIGO, V18.V18_CODCUS, V18.V18_VALOR, V18.V18_INDVAL "

	cFrom := RetSqlName( "V18" ) + " V18 "

	cFrom += " INNER JOIN " + RetSqlName( "C1O" ) + " C1O "
	cFrom += "ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
	cFrom += "AND C1O.C1O_ID = V18.V18_IDCTA  "
	cFrom += "AND C1O.D_E_L_E_T_ = ' ' "

	cWhere := " V18.V18_FILIAL = '" + xFilial( "V18" ) + "' "
	cWhere += "AND V18.V18_ID = '" + cIdPai + "' "
	cWhere += "AND V18.D_E_L_E_T_ = ' ' "

	cOrderBy := " V18.V18_FILIAL, C1O_CODIGO " 	

EndIf

if !cReg $ 'X450|X451'
	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"
	cOrderBy := "%" + cOrderBy + "%"

	cSelect2  := "%" + cSelect2  + "%"
	cFrom2    := "%" + cFrom2    + "%"
	cWhere2   := "%" + cWhere2   + "%"

	cSelect3  := "%" + cSelect3  + "%"
	cFrom3    := "%" + cFrom3    + "%"
	cWhere3   := "%" + cWhere3   + "%"

	cSelect4  := "%" + cSelect4  + "%"
	cFrom4    := "%" + cFrom4    + "%"
	cWhere4   := "%" + cWhere4   + "%"

	cSelect5  := "%" + cSelect5  + "%"
	cFrom5    := "%" + cFrom5    + "%"
	cWhere5   := "%" + cWhere5   + "%"

	cSelect6  := "%" + cSelect6  + "%"
	cFrom6    := "%" + cFrom6    + "%"
	cWhere6   := "%" + cWhere6   + "%"

	cSelect7  := "%" + cSelect7  + "%"
	cFrom7    := "%" + cFrom7    + "%"
	cWhere7   := "%" + cWhere7   + "%"

	if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
		cSelect8  := "%" + cSelect8 + "%"
		cFrom8    := "%" + cFrom8   + "%"
		cWhere8   := "%" + cWhere8  + "%"
	endif

	If cReg == "X340"
		if lBlocX50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
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
		Else
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

				ORDER BY
					%Exp:cOrderBy%
			EndSql
		Endif
	Else
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
	Endif
EndIf

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} 

Função para verificar se será enviado o valor zerado ou em branco

@Param	nValor -> valor que será avaliado
		lVazio -> indica se retorna uma string vazia com zero formatada

@Return cValor -> Retorna o valor em caracter, podendo ser um numero formatado ou um string vazia

@Author Renan Gomes
@Since 30/04/2021
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function StrECF( nValue, lEmpty, nTam, nDec)
Local cValor 	:= ""
Default lEmpty 	:= .f.

	if nValue > 0 
		cValor := Val2Str(nValue,nTam,nDec)
	
	Else
		if lEmpty
			cValor := ""
		Else
			cValor := Val2Str(nValue,nTam,nDec)
		Endif
	Endif

Return cValor
