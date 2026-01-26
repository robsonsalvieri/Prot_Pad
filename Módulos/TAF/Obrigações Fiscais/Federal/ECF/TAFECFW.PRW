#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFW

Rotina geradora do Bloco W do ECF.

@Param	cTABCTL	->	Nome da tabela de controle de transações
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread
@Author Henrique Pereira
@Since 21/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------

Function TAFECFW( cTABCTL, aWizard, cFilSel, cJobAux )
Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description + Chr( 10 )+ Obj:ErrorStack,3,.T.,"ECF" ) } )
Local cBloco		:=	"W"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel ) 
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

DbSelectArea("C08") // Necessário abertua para posterior uso

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
If aWizard[1][5]>='0003' // Apenas para leiaute 0003 em diante
	Begin Sequence	
		If TAFAlsInDic("T67") .And. TAFAlsInDic("T68") .And. TAFAlsInDic("T69") .And. TAFAlsInDic("T6A")
			RegW100( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		EndIF	
			//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
		RegW001( aECFInfo, cIndMov )	
		Recover
		lFound := .F.	
	End Sequence
EndIf

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
C08->(DbCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RegW100
Rotina para extrair e gravar as informacoes do Registro W001.
@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco
@Author Henrique Pereira
@Since 21/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegW100( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )
Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()
Local cJurCon	:= ""
Local cJurSub	:= ""
Local cIdT67    := ""
Local cIndCont  := ""
Local cIndEnt   := ""
Local cIndMod   := ""
Local cDtIni    := ""
Local cDtFim    := ""

ECFQryW( cAliasQry, aWizard, cFilSel, "W100", aECFInfo )

//Registro W100
While ( cAliasQry )->( !Eof() )
	cJurCon	 :=	POSICIONE("C08",3,XFILIAL("C08")+( cAliasQry )->T67_IDJURC,"C08_JURIDI")
	cJurSub	 :=	POSICIONE("C08",3,XFILIAL("C08")+( cAliasQry )->T67_IDJURS,"C08_JURIDI")
	cIdT67	 := ( cAliasQry )->T67_ID
	cIndCont := xFunTrcSN(( cAliasQry )->T67_IDCONT)
	cIndEnt  := ALLTRIM(( cAliasQry )->T67_IENTRG)
	cIndMod  := ALLTRIM(( cAliasQry )->T67_INDMOD)
	cDtIni   := ""
	cDtFim   := ""

	//Caso [W100.IND_CONTROLADORA seja igual a "S"(Sim) e W100.IND_ENTREGA seja igual a "2" ( Controladora final do do grupo multinacional)] ou
	//[W100.IND_ENTREGA seja igual a "3" ( Própria entidade declarante da ECF ) e W100.IND_MODALIDADE esteja preenchido], os campo W100.DT_INI e W100.DT_FIN serao habilitados.
	if (cIndCont == "S" .And. cIndEnt == "2") .Or. (cIndEnt == "3" .And. !Empty(cIndMod))
		cDtIni := Dt2Caract(( cAliasQry )->T67_DTINI)
		cDtFim := Dt2Caract(( cAliasQry )->T67_DTFIM)
	endif

	cStrTxt := cDelimit + "W100"							 //01 - REG
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_NOMULT) //02 - NOME_MULTINACIONAL
	cStrTxt += cDelimit + cIndCont							 //03 - IND_CONTROLADORA
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_NCONTR) //04 - NOME_CONTROLADORA
	cStrTxt += cDelimit + ALLTRIM(cJurCon) 					 //05 - JURISDICAO_CONTROLADORA
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_TIN)	 //06 - TIN_CONTROLADORA
	cStrTxt += cDelimit + cIndEnt							 //07 - IND_ENTREGA
	cStrTxt += cDelimit + cIndMod							 //08 - IND_MODALIDADE
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_SUBSTI) //09 - NOME_SUBSTITUTA
	cStrTxt += cDelimit + ALLTRIM(cJurSub)					 //10 - JURISDICAO_SUBSTITUTA
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_TINSUB) //11 - TIN_SUBSTITUTA
	cStrTxt += cDelimit + cDtIni							 //12 - DT_INI
	cStrTxt += cDelimit + cDtFim							 //13 - DT_FIN
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_MOEDA)	 //14 - TIP_MOEDA
	cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T67_IDIOMA) //15 - IND_IDIOMA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "W100", cStrTxt )
	nSeq++
	cIndMov = '0'
	( cAliasQry )->( DBSkip() )
EndDo
RegW200( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, cIdT67 )
RegW300( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, cIdT67 )
( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegW200

Rotina para extrair e gravar as informacoes do Registro W200.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Henrique Pereira
@Since 21/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegW200( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, cIdT67 )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cJuridc	  := ""
Local cIdT68	  := ""

	DBSelectArea( "T68" )
	T68->( DBSetOrder( 1 ) )
	If T68->( MsSeek( xFilial( "T68" ) + cIdT67 ) )
		//Registro W200
			While T68->( !Eof() ) .And. T68->T68_ID ==  cIdT67
				cIdT68 := T68->T68_ID
				cJuridc := POSICIONE("C08",3,XFILIAL("C08")+T68->T68_IDJURI,"C08_JURIDI")				
				cStrTxt := cDelimit + "W200"									 		//01 - REG
				cStrTxt += cDelimit + ALLTRIM(cJuridc)									//02 - JURISDICAO
				cStrTxt += cDelimit + Iif(T68->T68_VLRECE > 0,Val2Str(T68->T68_VLRECE,19,0),'')		//03 - VL_REC_NAO_REL_EST
				cStrTxt += cDelimit + Iif(T68->T68_VLRECR > 0,Val2Str(T68->T68_VLRECR,19,0),'')		//04 - VL_REC_NAO_REL
				cStrTxt += cDelimit + Iif(T68->T68_VLRELE > 0,Val2Str(T68->T68_VLRELE,19,0),'')		//05 - VL_REC_REL_EST
				cStrTxt += cDelimit + Iif(T68->T68_VLRELR > 0,Val2Str(T68->T68_VLRELR,19,0),'')		//06 - VL_REC_REL
				cStrTxt += cDelimit + Iif(T68->T68_VLTOTE > 0,Val2Str(T68->T68_VLTOTE,19,0),'')		//07 - VL_REC_TOTAL_EST
				cStrTxt += cDelimit + Iif(T68->T68_VLTOTA > 0,Val2Str(T68->T68_VLTOTA,19,0),'')		//08 - VL_REC_TOTAL
				cStrTxt += cDelimit + Iif(T68->T68_LPESTR > 0,Val2Str(T68->T68_LPESTR,19,0),'')		//09 - VL_LUC_PREJ_ANTES_IR_EST
				cStrTxt += cDelimit + Iif(T68->T68_LPREAL > 0,Val2Str(T68->T68_LPREAL,19,0),'')		//10 - VL_LUC_PREJ_ANTES_IR
				cStrTxt += cDelimit + Iif(T68->T68_IRESTR > 0,Val2Str(T68->T68_IRESTR,19,0),'')		//11 - VL_IR_PAGO_EST
				cStrTxt += cDelimit + Iif(T68->T68_IRREAL > 0,Val2Str(T68->T68_IRREAL,19,0),'')		//12 - VL_IR_PAGO
				cStrTxt += cDelimit + Iif(T68->T68_IRDEVE > 0,Val2Str(T68->T68_IRDEVE,19,0),'')		//13 - VL_IR_DEVIDO_EST
				cStrTxt += cDelimit + Iif(T68->T68_IRDEVR > 0,Val2Str(T68->T68_IRDEVR,19,0),'')		//14 - VL_IR_DEVIDO
				cStrTxt += cDelimit + Iif(T68->T68_CPSOCE > 0,Val2Str(T68->T68_CPSOCE,19,0),'')		//15 - VL_CAP_SOC_EST
				cStrTxt += cDelimit + Iif(T68->T68_CPSOCR > 0,Val2Str(T68->T68_CPSOCR,19,0),'')		//16 - VL_CAP_SOC
				cStrTxt += cDelimit + Iif(T68->T68_LACUME > 0,Val2Str(T68->T68_LACUME,19,0),'')		//17 - VL_LUC_ACUM_EST 
				cStrTxt += cDelimit + Iif(T68->T68_LACUMR > 0,Val2Str(T68->T68_LACUMR,19,0),'')		//18 - VL_LUC_ACUM
				cStrTxt += cDelimit + Iif(T68->T68_ATVTES > 0,Val2Str(T68->T68_ATVTES,19,0),'')		//19 - VL_ATIV_TANG_EST
				cStrTxt += cDelimit + Iif(T68->T68_ATVTR  > 0,Val2Str(T68->T68_ATVTR ,19,0),'')		//20 - VL_ATIV_TANG
				cStrTxt += cDelimit + Iif(T68->T68_NUMEMP > 0,Val2Str(T68->T68_NUMEMP,7,0) ,'')		//21 - NUM_EMP 
				cStrTxt += cDelimit
				FExecSQL( aECFInfo, nSeq, "W200", cStrTxt )

				RegW250( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov, cIdT68, T68->T68_IDJURI)
						
				nSeq ++		
			 T68->( DBSkip() )
		EndDo
		
	EndIf


T68->( DBCloseArea() )
Return()

/*/{Protheus.doc} RegW250
Rotina para extrair e gravar as informacoes do Registro W250.
@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco
@Author Henrique Pereira
@Since 21/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegW250( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, cIdT68, cIDJPAI )
Local cDelimit  := "|"
Local cStrTxt   := ""
Local cJurDif	  := ""
Local cJurTin   := ""
Local cJurNi	  := "" 

//ECFQryW( cAliasQry, aWizard, cFilSel, "W250" )

DBSelectArea( "T69" )
T69->( DBSetOrder( 1 ) ) 
	If T69->( MsSeek( xFilial( "T69" ) + cIdT68 + cIDJPAI ) )
	//Registro W200  
		While T69->( !Eof() ) .And. T69->T69_ID ==  cIdT68 .and. T69->T69_IDJPAI == cIDJPAI
	
			cJurDif := POSICIONE("C08",3,XFILIAL("C08")+T69->T69_IDJRDF,"C08_JURIDI")
			cJurTin := POSICIONE("C08",3,XFILIAL("C08")+T69->T69_IDJRTI,"C08_JURIDI")
			cJurNi  := POSICIONE("C08",3,XFILIAL("C08")+T69->T69_IDJRNI,"C08_JURIDI")
			
			cStrTxt := cDelimit + "W250"									 		//01 - REG
			cStrTxt += cDelimit + ALLTRIM(cJurDif)									//02 - JUR_DIFERENTE
			cStrTxt += cDelimit + ALLTRIM(T69->T69_NOME)				//03 - NOME
			cStrTxt += cDelimit + ALLTRIM(T69->T69_TIN)				//04 - TIN
			cStrTxt += cDelimit + ALLTRIM(cJurTin)									//05 - JURISDICAO_TIN
			cStrTxt += cDelimit + ALLTRIM(T69->T69_NI)					//06 - NI
			cStrTxt += cDelimit + ALLTRIM(cJurNi)									//07 - JURISDICAO_NI
			cStrTxt += cDelimit + ALLTRIM(T69->T69_TIPONI)			//08 - TIPO_NI
			cStrTxt += cDelimit + ALLTRIM(T69->T69_TIPEND)			//09 - TIP_END
			cStrTxt += cDelimit + ALLTRIM(T69->T69_ENDERE)			//10 - ENDEREÇO
			cStrTxt += cDelimit + ALLTRIM(T69->T69_NUMTEL)			//11 - NUM_TEL
			cStrTxt += cDelimit + ALLTRIM(T69->T69_EMAIL)				//12 - EMAIL
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_1)			//13 - ATIV_1
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_2)			//14 - ATIV_2
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_3)			//15 - ATIV_3
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_4)			//16 - ATIV_4
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_5)			//17 - ATIV_5
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_6)			//18 - ATIV_6
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_7)			//19 - ATIV_7
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_8)			//20 - ATIV_8
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV_9)			//21 - ATIV_9
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV10)			//22 - ATIV_10
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV11)			//23 - ATIV_11
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV12)			//24 - ATIV_12
			cStrTxt += cDelimit + xFunTrcSN(T69->T69_ATIV13)			//25 - ATIV_13
			cStrTxt += cDelimit + ALLTRIM(T69->T69_DESCOU)			//26 - DESC_OUTROS
			cStrTxt += cDelimit + ALLTRIM(T69->T69_OBSERV)			//27 - OBSERVAÇÃO
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, "W250", cStrTxt )		
					
			nSeq ++
	
			T69->( DBSkip() )
		EndDo
	EndIf

T69->( DBCloseArea() )
Return()

/*/{Protheus.doc} RegW300
Rotina para extrair e gravar as informacoes do Registro W300.
@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco
@Author Henrique Pereira
@Since 21/03/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegW300( aECFInfo, nSeq, aWizard, cFilSel, cIndMov, cIdT67 )
Local cDelimit  := "|"
Local cStrTxt   := ""
Local nJuridc	  := ""

	DBSelectArea( "T6A" )
	T6A->( DBSetOrder( 1 ) )
	If T6A->( MsSeek( xFilial( "T6A" ) + cIdT67 ) )
		//Registro W200
		While T6A->( !Eof() ) .And. T6A->T6A_ID ==  cIdT67
			
			nJuridc := POSICIONE("C08",3,XFILIAL("C08")+T6A->T6A_IDJURI,"C08_JURIDI")
			
			cStrTxt := cDelimit + "W300"									 		//01 - REG
			cStrTxt += cDelimit + ALLTRIM(nJuridc)									//02 - JURISDICAO
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_RNRELC)			//03 - IND_REC_NAO_REL
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_RRELAC)			//04 - IND_REC_REL
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_RECTOT)			//05 - IND_REC_TOTAL
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_LPANIR)			//06 - IND_LUC_PREJ_ANTES_IR			
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_IRPAGO)			//07 - IND_IR_PAGO
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_IRDEVI)			//08 - IND_IR_DEVIDO
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_CAPSOC)			//09 - IND_CAP_SOC
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_LUCACU)			//10 - IND_LUC_ACUM
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_ATIVOT)			//11 - IND_ATIV_TANG
			cStrTxt += cDelimit + xFunTrcSN(T6A->T6A_NUMEMP)			//12 - IND_NUM_EMP
			cStrTxt += cDelimit + ALLTRIM(T6A->T6A_OBS)				//13 - OBSERVAÇÃO
			cStrTxt += cDelimit + "W300FIM"											//14 - FIM_OBSERVACAO
			cStrTxt += cDelimit
			
			FExecSQL( aECFInfo, nSeq, "W300", cStrTxt )		
					
			nSeq ++
	
			T6A->( DBSkip() )
		EndDo

	T6A->( DBCloseArea() )
	EndIf
Return()

/*/{Protheus.doc} ECFQryW
Query para filtrar os lancamentos na tebela T67 (INFO. GRUP. MULT. ENTDAD. DEC)

@Param	
cAliasQry -> apelido da query
aWizard   -> parametros da tela
cFilSel	  -> string filial selecionada(s)
aECFInfo  -> Informacoes gerais para tabela de controle de transacoes
@Author Denis Souza
@Since 20/06/2022
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryW(cAliasQry, aWizard, cFilSel, cReg, aECFInfo)

Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""
Local cOrderBy   := ""

Default aECFInfo := Array(4)

cSelect := " 'W100' W100, T67.T67_NOMULT,T67.T67_IDCONT,T67.T67_NCONTR,T67.T67_IDJURC,T67.T67_TIN,T67.T67_SUBSTI, "
cSelect += " T67.T67_IDJURS,T67.T67_TINSUB,T67.T67_DTINI,T67.T67_DTFIM,T67.T67_MOEDA,T67.T67_IDIOMA,T67.T67_IENTRG,T67.T67_INDMOD, T67.T67_ID "

cFrom := RetSqlName( "T67" ) + " T67 "

cWhere := " T67.T67_FILIAL = '" + xFilial( "T67" ) + "' "

If Len(aECFInfo) > 0 //os campos de datas não são obrigatórios no cadastro
	cWhere += " AND "
	cWhere += " ( "
	cWhere +=   " (CASE WHEN T67.T67_DTFIM >= T67.T67_DTINI THEN T67.T67_DTFIM ELSE T67.T67_DTINI END) BETWEEN '" + aECFInfo[2] + "' AND '" + aECFInfo[3] + "' "	
	cWhere +=   " OR (T67.T67_DTINI = '' AND T67.T67_DTFIM = '') "	
	cWhere += " ) "
EndIf

cWhere 	 += " AND T67.D_E_L_E_T_ = '' "
cOrderBy := "T67_FILIAL"

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"
cOrderBy := "%" + cOrderBy + "%"

If !Empty(cSelect)
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
EndIf

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RegW001
Rotina para extrair e gravar as informacoes do Registro W001.
@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco
@Author 
@Since 
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegW001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "W001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "W001", cStrTxt )

Return()
