#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECF0

Rotina extratora da informacoes para o Bloco 0 do ECF.

@Param	cTABCTL	->	Nome da tabela de controle de transações
		aWizard	->	Array com as informacoes da wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread
		cIdPeriodo	->	ID do período de escrituração
		aContab	->	Contabilistas selecionados

@Return ( Nil )

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
@Since 13/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECF0( cTABCTL, aWizard, cFilSel, cJobAux, cIdPeriodo, aContab )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"0"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	1
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.
Local cTpECFScp	    := ''

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	DBSelectArea( "CHD" )
	CHD->( DBSetOrder( 1 ) )
	If CHD->( MsSeek( xFilial( "CHD" ) + cIdPeriodo ) )
		Reg0000( aECFInfo, @nSeq, aWizard, @cIndMov, @cTpECFScp )
		//Adiciono + 1 no contador, pois a sequência 2 se refere ao registro 0001.
		nSeq ++
		Reg0010( aECFInfo, @nSeq, aWizard, @cIndMov )
		Reg0020( aECFInfo, @nSeq, @cIndMov,aWizard )
		If CHD->CHD_INDPJH == '1'
			Reg0021( aECFInfo, @nSeq, aWizard )
		EndIf
		Reg0030( aECFInfo, @nSeq, @cIndMov )
		if cTpECFScp == '1' //TipECF
			Reg0035( aECFInfo, @nSeq, @cIndMov )
		endif
		Reg0930( aECFInfo, @nSeq, aWizard, aContab, @cIndMov )

	EndIf

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	Reg0001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} Reg0000

Rotina para extrair e gravar as informacoes do Registro 0000.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cIndMov  -> Indicador de movimento do bloco
		cTpECFScp-> Tipo ECF Identificacao das SCP
@Return ( Nil )

@Author Felipe C. Seolin
@Since 18/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0000( aECFInfo, nSeq, aWizard, cIndMov, cTpECFScp )

Local cDelimit 	:= "|"
Local cStrTxt  	:= ""
Local cCodSCP  	:= "" 

cTpECFScp := CHD->CHD_TPECF

cStrTxt := cDelimit + "0000"																					//01 - REG
cStrTxt += cDelimit + "LECF"																					//02 - NOME_ESC
cStrTxt += cDelimit + TAFConType( aWizard[1,5] )																//03 - COD_VER
cStrTxt += cDelimit + TAFConType( VldIE( Iif( RetPessoa( SM0->M0_CGC ) == "J", SM0->M0_CGC, "" ) ) )			//04 - CNPJ
cStrTxt += cDelimit + TAFConType( SM0->M0_NOMECOM )																//05 - NOME
cStrTxt += cDelimit + TAFConType ( CHD->CHD_INDINI )															//06 - IND_SIT_INI_PER
cStrTxt += cDelimit + TAFConType ( CHD->CHD_INDESP )															//07 - SIT_ESPECIAL
cStrTxt += cDelimit + Iif( Empty( CHD->CHD_PATCIS ), "", Val2Str( ( CHD->CHD_PATCIS  ), 16, 2 ) )				//08 - PAT_REMAN_CIS
cStrTxt += cDelimit + Dt2Caract( CHD->CHD_DTSIT  )																//09 - DT_SIT_ESP
cStrTxt += cDelimit + Dt2Caract( CHD->CHD_PERINI  )																//10 - DT_INI
cStrTxt += cDelimit + Dt2Caract( CHD->CHD_PERFIN  )																//11 - DT_FIM
cStrTxt += cDelimit + TAFConType( aWizard[2,1], 1 )																//12 - RETIFICADORA
cStrTxt += cDelimit + TAFConType( aWizard[2,2] )																//13 - NUM_REC
cStrTxt += cDelimit + TAFConType( cTpECFScp )																	//14 - TIP_ECF

//Registro se Encontra devidamente posicionado no CHD // tratatamento bloco T001AM
If cTpECFScp == '2' //S.C.P 
	cStrTxt += cDelimit + GetScpCnpj( TAFConType( CHD->CHD_IDCODS ) )
Else //Mantem Funcionamento Padrao
	cStrTxt += cDelimit +  cCodSCP																				//15 - COD_SCP
EndIf

cStrTxt += cDelimit

FExecSQL( aECFInfo, nSeq, "0000", cStrTxt )

nSeq ++
   
Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0001

Rotina para extrair e gravar as informacoes do Registro 0001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 11/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "0001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 2, "0001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0010

Rotina para extrair e gravar as informacoes do Registro 0010.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 18/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0010( aECFInfo, nSeq, aWizard, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""
Local cDiffco	 := ""

If aWizard[1][5] <> '0001'
	cDiffco	:= Iif(CHD->CHD_OPTRTT == "1","",CHD->CHD_DIFFCO)
Else
	cDiffco	:= Iif(CHD->CHD_OPTRTT == "2","",CHD->CHD_DIFFCO)
EndIF 

cStrTxt := cDelimit + "0010"																												//01 - REG
cStrTxt += cDelimit																															//02 - HASH_ECF_ANTERIOR
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_OPTREF )																							//03 - OPT_REFIS
If aWizard[1][5] < '0007'																									
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_OPTPAE )																						//04 - OPT_PAES
Endif
cStrTxt += cDelimit + TAFConType( CHD->CHD_FORTRB )																							//04 - FORMA_TRIB
cStrTxt += cDelimit + Iif( Empty( CHD->CHD_APIRCS ), "", Iif( CHD->CHD_APIRCS == "1", "T", "A" ) )											//05 - FORMA_APUR
cStrTxt += cDelimit + TAFConType( CHD->CHD_CODQUA )																							//06 - COD_QUALIF_PJ
cStrTxt += cDelimit + TAFConType( CHD->CHD_TRBPER )																							//07 - FORMA_TRIB_PER
cStrTxt += cDelimit + TAFConType( CHD->CHD_APUEST )																							//08 - MES_BAL_RED
cStrTxt += cDelimit + Iif( Empty( CHD->CHD_TIPESC ), "", Iif( CHD->CHD_TIPESC == "1", "L", "C" ) )											//09 - TIP_ESC_PRE
cStrTxt += cDelimit + TAFConType( Posicione( "CH0", 1, xFilial( "CH0" ) + CHD->CHD_IDTIPE, "CH0_CODIGO" ) )									//10 - TIP_ENT
cStrTxt += cDelimit + Iif( Empty( CHD->CHD_ATTRBI ), "", Iif( CHD->CHD_ATTRBI == "1", "A", Iif( CHD->CHD_ATTRBI == "2", "T", "D" ) ) )		//11 - FORMA_APUR_I
cStrTxt += cDelimit + Iif( Empty( CHD->CHD_APCSLI ), "", Iif( CHD->CHD_APCSLI == "1", "A", Iif( CHD->CHD_ATTRBI == "2", "T", "D" ) ) )		//12 - APUR_CSLL
If aWizard[1][5] < '0003'
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_OPTRTT )																						//13 - OPT_EXT_RTT
	cStrTxt += cDelimit + xFunTrcSN( cDiffco )																							    //14 - DIF_FCONT
Else
	If "P" $ TAFConType( CHD->CHD_TRBPER ) // Escriturar CHD_RECREC apenas se em algum dos períodos conter lucropresumido
		cStrTxt += cDelimit + CHD->CHD_RECREC																								//13 - IND_REC_RECEITA
	Else
		cStrTxt  += cDelimit
	EndIf	
EndIf
cStrTxt += cDelimit

FExecSQL( aECFInfo, nSeq, "0010", cStrTxt )

nSeq ++

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0020

Rotina para extrair e gravar as informacoes do Registro 0020.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 25/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0020( aECFInfo, nSeq, cIndMov, aWizard )

Local cDelimit	:=	"|"
Local cStrTxt	:=	""
Local cIndAlq	:=	''

DBSelectArea( "CHD" )
If TAFColumnPos( "CHD_IDCSLL" ) .AND. !AWizard[01][05]=='0001'
	cIndAlq	:= CHD->CHD_IDCSLL 
Else
	cIndAlq	:= xFunTrcSN( CHD->CHD_INDALQ )
EndIF

cStrTxt := cDelimit + "0020"								//01 - REG
cStrTxt += cDelimit + AllTrim(cIndAlq)						//02 - IND_ALIQ_CSLL
cStrTxt += cDelimit + AllTrim( Str( CHD->CHD_QTDSCP ) )		//03 - IND_QTE_SCP
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDADM )			//04 - IND_ADM_FUN_CLU
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPAC )			//05 - IND_PART_CONS
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDOPE )			//06 - IND_OP_EXT
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDOPV )			//07 - IND_OP_VINC
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPJE )			//08 - IND_PJ_ENQUAD
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPAE )			//09 - IND_PART_EXT
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDATV )			//10 - IND_ATIV_RURAL
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDLUC )			//11 - IND_LUC_EXP
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDRED )			//12 - IND_RED_ISEN
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDFIN )			//13 - IND_FIN
If aWizard[1][5] < '0007'
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDDOA )		//14 - IND_DOA_ELEIT
Endif
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPAG )			//15 - IND_PART_COLIG
If aWizard[1][5] < '0007'
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDVEN )		//16 - IND_VEND_EXP
Endif
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDREC )			//17 - IND_ REC_EXT
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDEXT )			//18 - IND_ATIV_EXT
If aWizard[1][5] < '0007'
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDEXP )		//19 - IND_COM_EXP
Endif
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPGE )			//20 - IND_PGTO_EXT
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDECO )			//21 - IND_E-COM_TI
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDROY )			//22 - IND_ROY_REC
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDROP )			//23 - IND_ROY_PAG
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDREN )			//24 - IND_REND_SERV
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDREM )			//25 - IND_PGTO_REM
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDINO )			//26 - IND_INOV_TEC
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDCAP )			//27 - IND_CAP_INF
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPJH )			//28 - IND_PJ_HAB
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPOL )			//29 - IND_POLO_AM
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDZON )			//30 - IND_ZON_EXP
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDARE )			//31 - IND_AREA_COM

If aWizard[1][5] > "0002" //Campo criado no layout 0003
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_INDPAP )		//32 - IND_PAIS_A_PAIS
EndIf

If aWizard[1][5] > "0003" //Campo criado no layout 0004
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_DEREX ) 		//33 - IND_DEREX
EndIf

If aWizard[1][5] > "0009" //Campo criado no layout 0010
	If TAFColumnPos( "CHD_TRANSF" )
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_TRANSF ) 		//34 - IND_PR_TRANSF
	EndIf
EndIf

cStrTxt += cDelimit

FExecSQL( aECFInfo, nSeq, "0020", cStrTxt )

nSeq ++

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0021

Rotina para extrair e gravar as informacoes do Registro 0020.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Henrique Perereira
@Since 17/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0021( aECFInfo, nSeq, aWizard )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "0021"								//01 - REG
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IREPES )			//02 - IND_REPES
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IRECAP )			//03 - IND_RECAP
cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IPADIS )			//04 - IND_PADIS 

If aWizard[1,5] == "0009"
	cStrTxt += cDelimit + xFunTrcSN( "2" )
Elseif aWizard[1,5] < "0009"
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IPATVD )			//05 - IND_PATVD
EndIf

cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IREIDI )			//06 - IND_REIDI

If aWizard[1,5] == "0009"
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//07 - IND_REPENEC
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//08 - IND_REICOMP
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//09 - IND_RETAERO
Elseif aWizard[1,5] < "0009"
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IREPEC )			//07 - IND_REPENEC
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REICMP )			//08 - IND_REICOMP
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REAERO )			//09 - IND_RETAERO
EndIf

cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_RECINE )			//10 - IND_RECINE

If aWizard[1,5] == "0009"
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//11 - IND_RESIDUOS_SOLID
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//12 - IND_RECOPA
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//13 - IND_COPA_DO_MUND 
Elseif aWizard[1,5] < "0009"
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_RESSOL )			//11 - IND_RESIDUOS_SOLID
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_RECOPA )			//12 - IND_RECOPA
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_HBFIFA )			//13 - IND_COPA_DO_MUND
EndIf


cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IRETID )			//14 - IND_RETID

If aWizard[1,5] == "0009"
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//15 - IND_REPNBL_REDES 
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//16 - IND_REIF 
	cStrTxt += cDelimit + xFunTrcSN( "2" )			//17 - IND_OLIMPIADAS
Elseif aWizard[1,5] < "0009"
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_RPNLBI )			//15 - IND_REPNBL_REDES
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IDREIF )			//16 - IND_REIF
	cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_OLIMPI )			//17 - IND_OLIMPIADAS
EndIf

//Versão 0010
If aWizard[1,5] > "0009"
	If TAFColumnPos( "CHD_OLBUNK" ) .and. TAFColumnPos( "CHD_REPORT" ) .and. TAFColumnPos( "CHD_RETII" ) .and.;
       TAFColumnPos( "CHD_IRPMCM" ) .and. TAFColumnPos( "CHD_IRETEE" )  .and. TAFColumnPos( "CHD_IEBAS" ) .and.;
       TAFColumnPos( "CHD_REPTRI" ) .and. TAFColumnPos( "CHD_REPTRN" ) .and. TAFColumnPos( "CHD_REPTRP" ) .and.;
       TAFColumnPos( "CHD_REPTRT" )
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_OLBUNK )			//08 - IND_OLEO_BUNKER
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REPORT )			//09 - IND_REPORTO
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_RETII )			//10 - IND_RET_II
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IRPMCM )			//11 - IND_RET_PMCMV
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IRETEE )			//12 - IND_RET_EEI
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_IEBAS )			//13 - IND_EBAS
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REPTRI )			//14 - IND_REPETRO_INDUSTRIALIZACAO
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REPTRN )			//15 - IND_REPETRO_NACIONAL
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REPTRP )			//16 - IND_REPETRO_PERMANENTE
		cStrTxt += cDelimit + xFunTrcSN( CHD->CHD_REPTRT )			//17 - IND_REPETRO_TEMPORARIO
	EndIf
EndIf

cStrTxt += cDelimit

FExecSQL( aECFInfo, nSeq, "0021", cStrTxt )

nSeq ++

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0030

Rotina para extrair e gravar as informacoes do Registro 0030.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 26/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0030( aECFInfo, nSeq, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cEmail    := ""
Local aEndereco := {}

//Aloco as informacoes do endereco em variavel para nao reprocessar a mesma rotina outras vezes
aEndereco := TAFGetEnd( SM0->M0_ENDENT )

DBSelectArea( "C1E" )
C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL + C1E_FILTAF + C1E_ATIVO
If C1E->( MsSeek( xFilial( "C1E" ) + FwGetCodFilial + "1" ) )
	cEmail := C1E->C1E_EMAIL
EndIf

cStrTxt := cDelimit + "0030"																							//01 - REG
cStrTxt += cDelimit + TAFConType( SM0->M0_NATJUR )																		//02 - COD_NAT
cStrTxt += cDelimit + TAFConType( SM0->M0_CNAE )																		//03 - CNAE_FISCAL
cStrTxt += cDelimit + TAFConType( aEndereco[1] )																		//04 - Endereço
cStrTxt += cDelimit + Iif( !Empty( aEndereco[2] ), aEndereco[3], "SN" )													//05 - NUM
cStrTxt += cDelimit + TAFConType( Iif( !Empty( SM0->M0_COMPENT ), SM0->M0_COMPENT, aEndereco[4] ) )						//06 - COMPL
cStrTxt += cDelimit + TAFConType( SM0->M0_BAIRENT )																		//07 - BAIRRO
cStrTxt += cDelimit + TAFConType( SM0->M0_ESTENT )																		//08 - UF
cStrTxt += cDelimit + Iif( Upper( SM0->M0_ESTENT ) == "EX", "", TAFConType( SM0->M0_CODMUN ) )							//09 - COD_MUN
cStrTxt += cDelimit + TAFConType( SM0->M0_CEPENT )																		//10 - CEP
cStrTxt += cDelimit + AllTrim( Str( TAFGetTel( SM0->M0_TEL )[2] ) ) + AllTrim( Str( TAFGetTel( SM0->M0_TEL )[3] ) )		//11 - NUM_TEL
cStrTxt += cDelimit + TAFConType( cEmail )																				//12 - EMAIL
cStrTxt += cDelimit

FExecSQL( aECFInfo, nSeq, "0030", cStrTxt )

nSeq ++

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0035

Rotina para extrair e gravar as informacoes do Registro 0035.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		cIndMov  -> Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 27/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0035( aECFInfo, nSeq, cIndMov )

Local cDelimit	:= "|"
Local cStrTxt		:= ""
Local cSelect		:= ""
Local cFrom		:= ""
Local cWhere		:= ""
Local cDescSCP	:= ""
Local cCodSCP		:= ""
Local cAliasQry := GetNextAlias()
Local lCUWCnpj	:= TAFColumnPos('CUW_CNPJ')


cSelect := " DISTINCT "
if !lCUWCnpj
	cSelect += " C1ESCP.C1E_FILTAF, C1ESCP.C1E_CODFIL, C1ESCP.C1E_NOME "
else
	cSelect += " C1E.C1E_FILTAF, CUW.CUW_CODSCP, CUW.CUW_CNPJ, CUW.CUW_NOMSCP "
endif	

cFrom := RetSqlName( "C1E" ) + " C1E "
cFrom += " INNER JOIN " + RetSqlName('CUW') + " CUW ON CUW.CUW_FILIAL = '" + xFilial('CUW') + "' AND CUW.CUW_ID = C1E_ID AND CUW.D_E_L_E_T_ = '' "
if !lCUWCnpj
	cFrom += " INNER JOIN " + RetSqlName('C1E') + " C1ESCP ON C1ESCP.C1E_FILIAL = '" + xFilial('C1E') + "' AND C1ESCP.C1E_ID = CUW.CUW_CODSCP AND C1ESCP.C1E_ATIVO = '1' AND C1ESCP.D_E_L_E_T_ = '' "
endif	

cWhere := " C1E.D_E_L_E_T_ = '' "
cWhere += "	AND C1E.C1E_FILIAL = '" + xFilial('C1E') + "' "
cWhere += "	AND C1E.C1E_FILTAF = '" + FwGetCodFilial + "' "
cWhere += "	AND C1E.C1E_ATIVO = '1' "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	if !lCUWCnpj 
		cDescSCP := AllTrim( ( cAliasQry )->C1E_CODFIL ) + " - " + AllTrim( ( cAliasQry )->C1E_NOME )
		cCodSCP := Posicione( 'SM0', 1, cEmpAnt + ( cAliasQry )->C1E_FILTAF , "M0_CGC")
	else
		if empty((cAliasQry)->CUW_CODSCP)
			cCodSCP	 := alltrim( ( cAliasQry )->CUW_CNPJ ) 
			cDescSCP := alltrim( ( cAliasQry )->CUW_NOMSCP ) 
		else
			cCodSCP := Posicione( 'SM0', 1, cEmpAnt + (cAliasQry)->C1E_FILTAF , 'M0_CGC')
			aRetC1E := GetAdvFVal('C1E',{'C1E_CODFIL','C1E_NOME'},xFilial('C1E')+(cAliasQry)->CUW_CODSCP+'1',5)
			cDescSCP := AllTrim(aRetC1E[1]) + " - " + AllTrim(aRetC1E[2])
		endif	
	endif	

	cStrTxt := cDelimit + "0035"						//01 - REG
	cStrTxt += cDelimit + cCodSCP						//02 - COD_SCP
	cStrTxt += cDelimit + TAFConType( cDescSCP )		//03 - NOME_SCP
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "0035", cStrTxt )

	nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Reg0930

Rotina para extrair e gravar as informacoes do Registro 0930.

@Param	aECFInfo	->	Informacoes gerais para tabela de controle de transacoes
		nSeq		->	Sequencia de gravacao do Bloco
		aWizard	->	Array com as informacoes da Wizard
		aContab	->	Contabilistas selecionados
		cIndMov	->	Indicador de movimento do bloco

@Return ( Nil )

@Author Felipe C. Seolin
@Since 30/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Reg0930( aECFInfo, nSeq, aWizard, aContab, cIndMov )

Local cDelimit	:=	"|"
Local cStrTxt		:=	""
Local cCodQua		:=	""
Local nI			:=	0

For nI := 1 to Len( aContab )

	If aContab[nI,1]

		C2J->( DBGoTo( aContab[nI,6] ) )

		cIndMov := "0"

		DBSelectArea( "CW4" )
		CW4->( DBSetOrder( 1 ) )
		If CW4->( MsSeek( xFilial( "CW4" ) + C2J->C2J_IDCODQ ) )
			cCodQua := CW4_CODIGO
		EndIf

		cStrTxt := cDelimit + "0930"														//01 - REG
		cStrTxt += cDelimit + TAFConType( C2J->C2J_NOME )									//02 - IDENT_NOM
		cStrTxt += cDelimit + Iif( C2J->C2J_TPESTA == "1", C2J->C2J_CPF, C2J->C2J_CNPJ )	//03 - IDENT_CPF_CNPJ
		cStrTxt += cDelimit + TAFConType( cCodQua )											//04 - IDENT_QUALIF
		cStrTxt += cDelimit + TAFConType( C2J->C2J_CRC )									//05 - IND_CRC
		cStrTxt += cDelimit + TAFConType( C2J->C2J_EMAIL )									//06 - EMAIL
		cStrTxt += cDelimit + TAFConType( C2J->C2J_DDD ) + TAFConType( C2J->C2J_FONE )		//07 - FONE
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "0930", cStrTxt )

		nSeq ++

	EndIf

Next nI

Return()

Static Function TafFlScp()

Local aEmpsRet 	:= {}
Local alGetSM0  := GetArea()

OpenSm0(,.T.)

While SM0->(!Eof())
	If !Deleted()
		//if cEmpAnt == SM0->M0_CODIGO
			aAdd( aEmpsRet , { AllTrim(SM0->M0_CODIGO) , AllTrim(SM0->M0_CODFIL) ,  AllTrim(SM0->M0_CGC) } )
		//endif
	EndIf
	SM0->(dbSkip())
EndDo

RestArea( alGetSM0 )

Return (aEmpsRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetScpCnpj

Executa a pesquisa ao CNPJ da SCP

@Param	cIdScp	->	Id da SCP cadastrado no parâmetro de abertura da ecf

@Return ( Nil )

@Author Henrique Pereira
@Since 02/09/2020
@Version 1.0
/*/
//---------------------------------------------------------------------

static function GetScpCnpj(cIdScp)
Local cRet 			as character
Local cBkpFilAnt	as character 
Local alGetSM0 		as array
Local alGetC1E		as array 
Local aUtilData		as array
Local aUtilFlds		as array 
Local alGetCUW		as array 

Default cIdScp	:= ''

cRet := ' '
cBkpFilAnt	:=	cFilAnt
aUtilData	:=	{ }
alGetCUW	:=	{ }
alGetC1E	:=	{ }
alGetSM0  	:= 	{ }
aUtilFlds	:= 	{ }	

	if !empty(cIdScp)
		alGetCUW	:=	CUW->(GetArea())
		DbSelectArea( 'CUW' )
		CUW->( DbSetOrder(1) )
		if CUW->( Dbseek( xFilial( 'CUW' ) + cIdScp ) ) //CUW_FILIAL, CUW_ID(6), CUW_CODSCP(6)
			if !empty(CUW->CUW_CODSCP) .and. !empty(CUW->CUW_CNPJ)				
				cRet := 'Configuração não conforme'
			elseIf !empty(CUW->CUW_CODSCP)  .and. empty(CUW->CUW_CNPJ)				
				alGetC1E	:=	C1E->(GetArea())
				alGetSM0  	:= 	SM0->(GetArea())	 			
				C1E->(DbSetOrder(2))
				if C1E->(DbSeek(xFilial('C1E')+CUW->CUW_CODSCP))
					cFilAnt	:= C1E->C1E_FILTAF
					aUtilFlds	:= { "M0_CGC" }	 
					aUtilData 	:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , aUtilFlds) 
					
					if len(aUtilData) > 0
						cRet := TAFConType(aUtilData[1][2])
					endif
				endif

				RestArea( alGetC1E )
				RestArea( alGetSM0 ) 
				FwFreeArray(aUtilFlds)
				FwFreeArray(aUtilData)
				FwFreeArray(alGetC1E)
				FwFreeArray(alGetSM0) 

			elseIf empty(CUW->CUW_CODSCP)  .and. !empty(CUW->CUW_CNPJ)

				cRet := TAFConType(CUW->CUW_CNPJ)	

			endif
		else //Efetua busca pelo cnpj na CUW
			if findfunction( "TafScpCNPJ" ) .And. len(cIdScp) == 14 .And. CGC(cIdScp)
				cRet := TafScpCNPJ( cIdScp, "CUW.CUW_CNPJ" )
			endif
		endif
		RestArea( alGetCUW )
		FwFreeArray( alGetCUW )
	endif

cFilAnt	:=	cBkpFilAnt

return cRet
