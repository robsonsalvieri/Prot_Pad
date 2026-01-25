#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFP

Rotina extratora da informacoes para o Bloco P do ECF.

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
Function TAFECFP( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"P"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1][1] ), DToS( aWizard[1][2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegP030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegP001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegP001

Rotina para extrair e gravar as informacoes do Registro P001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegP001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "P001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "P001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegP030

Rotina para extrair e gravar as informacoes do Registro P030 e seus filhos.

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
Static Function RegP030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()
Local cDtInicio := aWizard[1][1]
Local cDtFinal  := aWizard[1][2]
Local cCEG 
Local lBlpEcf50 := EcfBlP50()

cCEG := TAGetCEG(cDtInicio,cDtFinal)

While (cCEG)->(!EOF())
	cDtInicio :=stod((cCEG)->CEG_DTINI) 
	cDtFinal  :=stod((cCEG)->CEG_DTFIN)

	ECFQryP( cAliasQry, cDtInicio,cDtFinal,cFilSel )
	
	( cAliasQry )->(DbGotop())
	//Registro P030
	While ( cAliasQry )->( !Eof() )
	
		cIndMov := "0"
	
		cStrTxt := cDelimit + "P030"										//01 - REG
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEG_DTINI )		//02 - DT_INI
		cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CEG_DTFIN )		//03 - DT_FIN
		cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
		cStrTxt += cDelimit
		
		FExecSQL( aECFInfo, nSeq, "P030", cStrTxt )
	
		nSeq ++
	
		cPeriodo := ( cAliasQry )->CEG_DTINI + ( cAliasQry )->CEG_DTFIN + ( cAliasQry )->CAH_CODIGO
	
		While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CEG_DTINI + ( cAliasQry )->CEG_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo
	
			//Registro P100
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P100"
	
				If !Empty( ( cAliasQry )->P100_CHA_CODIGO )
					If lBlpEcf50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
						cStrTxt := cDelimit + "P100"									 					//01 - REG
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_CODIGO )					//02 - CODIGO
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_DESCRI )					//03 - DESCRICAO
						cStrTxt += cDelimit + Iif( ( cAliasQry )->P100_CHA_TPCTA == "1", "S", "A" )			//04 - TIPO
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_NIVEL )					//05 - NIVEL
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_C2R_CODIGO)					//06 - COD_NAT
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHACHA_CODIGO )				//07 - COD_CTA_SUP
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_SALINI, 16, 2 )					//08 - VAL_CTA_REF_INI
						cStrTxt += cDelimit + Iif( ( cAliasQry )->CEH_INDINI == "1", "D", "C" )				//09 - IND_VAL_CTA_REF_INI
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_VLRTD, 16, 2 )					//10 - VAL_CTA_REF_DEB 	
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_VLRTC, 16, 2 )					//11 - VAL_CTA_REF_CRED
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_SALFIN, 16, 2 )					//12 - VAL_CTA_REF_FIN
						cStrTxt += cDelimit + Iif( ( cAliasQry )->CEH_INDFIN == "1", "D", "C" )				//13 - IND_VAL_CTA_REF_FIN
						
					Else
						cStrTxt := cDelimit + "P100"									 					//01 - REG
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_CODIGO )					//02 - CODIGO
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_DESCRI )					//03 - DESCRICAO
						cStrTxt += cDelimit + Iif( ( cAliasQry )->P100_CHA_TPCTA == "1", "S", "A" )			//04 - TIPO
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHA_NIVEL )					//05 - NIVEL
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_C2R_CODIGO)					//06 - COD_NAT
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P100_CHACHA_CODIGO )				//07 - COD_CTA_SUP
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_SALINI, 16, 2 )					//08 - VAL_CTA_REF_INI
						cStrTxt += cDelimit + Iif( ( cAliasQry )->CEH_INDINI == "1", "D", "C" )				//09 - IND_VAL_CTA_REF_INI
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CEH_SALFIN, 16, 2 )					//10 - VAL_CTA_REF_FIN
						cStrTxt += cDelimit + Iif( ( cAliasQry )->CEH_INDFIN == "1", "D", "C" )				//11 - IND_VAL_CTA_REF_FIN
					EndIf
					
					cStrTxt += cDelimit

					FExecSQL( aECFInfo, nSeq, "P100", cStrTxt )
		
					nSeq ++
		
				EndIf
	
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P130
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P130"
		
				If !Empty( ( cAliasQry )->P130_CEI_CODIGO )
	
					cStrTxt := cDelimit + "P130"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P130_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P130_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P130_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P130", cStrTxt )
	
					nSeq ++
		
				EndIf
	
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P150
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P150"
		
				If !Empty( ( cAliasQry )->P150_CHA_CODIGO )
	
					cStrTxt := cDelimit + "P150"									 						//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P150_CHA_CODIGO )					//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P150_CHA_DESCRI )					//03 - DESCRICAO
					cStrTxt += cDelimit + Iif( ( cAliasQry )->P150_CHA_TPCTA == "1", "S", "A" )		//04 - TIPO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P150_CHA_NIVEL )					//05 - NIVEL
					cStrTxt += cDelimit + TAFConType(( cAliasQry )->P150_C2R_CODIGO)									//06 - COD_NAT
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P150_CHACHA_CODIGO )				//07 - COD_CTA_SUP
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CHE_SALFIN, 16, 2 )					//08 - VALOR
					cStrTxt += cDelimit + Iif( ( cAliasQry )->CHE_INDFIN == "1", "C", "D" )			//09 - IND_VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P150", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P200
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P200"
		
				If !Empty( ( cAliasQry )->P200_CEI_CODIGO )
		
					cStrTxt := cDelimit + "P200"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P200_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P200_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P200_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P200", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P230
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P230"
		
				If !Empty( ( cAliasQry )->P230_CEI_CODIGO )
		
					cStrTxt := cDelimit + "P230"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P230_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P230_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P230_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P230", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P300
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P300"
		
				If !Empty( ( cAliasQry )->P300_CEI_CODIGO )
		
					cStrTxt := cDelimit + "P300"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P300_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P300_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P300_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P300", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
	
			//Registro P400
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P400"
	
				If !Empty( ( cAliasQry )->P400_CEI_CODIGO )
		
					cStrTxt := cDelimit + "P400"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P400_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P400_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P400_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P400", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
		
			//Registro P500
			While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "P500"
		
				If !Empty( ( cAliasQry )->P500_CEI_CODIGO )
		
					cStrTxt := cDelimit + "P500"									 				//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P500_CEI_CODIGO )			//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->P500_CEI_DESCRI )			//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( ( cAliasQry )->P500_CEI_VALOR, 16, 2 )		//04 - VALOR
					cStrTxt += cDelimit
		
					FExecSQL( aECFInfo, nSeq, "P500", cStrTxt )
		
					nSeq ++
		
				EndIf
		
				( cAliasQry )->( DBSkip() )
			EndDo
		
		EndDo
	EndDo
	( cAliasQry )->( DBCloseArea() )
	(cCEG)->(DbSkip())
EndDo
(cCEG)->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryP

Executa a Query principal para a extracao do Bloco P do ECF.

@Param cAliasQry 	-> Alias para gravacao da Query
       cDtInicio   -> Data Inicial do Periodo
       cDtFinal	-> Data Final do Periodo
       cFilSel   	-> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryP( cAliasQry, cDtInicio,cDtFinal,cFilSel )

Local cSelect   := cSelect2 := cSelect3 := cSelect4 := cSelect5 := cSelect6 := cSelect7 := cSelect8 := ""
Local cFrom     := cFrom2   := cFrom3   := cFrom4   := cFrom5   := cFrom6   := cFrom7   := cFrom8   := ""
Local cWhere    := cWhere2  := cWhere3  := cWhere4  := cWhere5  := cWhere6  := cWhere7  := cWhere8  := ""
Local cOrderBy  := ""
Local lBlpEcf50 := EcfBlP50()

//Registro P100

cSelect := "  'P100' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect += ", CHA.CHA_CODIGO P100_CHA_CODIGO, CHA.CHA_DESCRI P100_CHA_DESCRI, CHA.CHA_TPCTA P100_CHA_TPCTA, CHA.CHA_NIVEL P100_CHA_NIVEL, C2R.C2R_CODIGO P100_C2R_CODIGO, CHACHA.CHA_CODIGO P100_CHACHA_CODIGO, CEH.CEH_SALINI, CEH.CEH_INDINI, CEH.CEH_SALFIN, CEH.CEH_INDFIN "

if lBlpEcf50
	cSelect += ", CEH.CEH_VLRTD, CEH.CEH_VLRTC "
endif

cSelect += ", '' P130_CEI_CODIGO, '' P130_CEI_DESCRI, 0 P130_CEI_VALOR "
cSelect += ", '' P150_CHA_CODIGO, '' P150_CHA_DESCRI, '' P150_CHA_TPCTA, '' P150_CHA_NIVEL, '' P150_C2R_CODIGO, '' P150_CHACHA_CODIGO, 0 CHE_SALFIN, '' CHE_INDFIN "
cSelect += ", '' P200_CEI_CODIGO, '' P200_CEI_DESCRI, 0 P200_CEI_VALOR "
cSelect += ", '' P230_CEI_CODIGO, '' P230_CEI_DESCRI, 0 P230_CEI_VALOR "
cSelect += ", '' P300_CEI_CODIGO, '' P300_CEI_DESCRI, 0 P300_CEI_VALOR "
cSelect += ", '' P400_CEI_CODIGO, '' P400_CEI_DESCRI, 0 P400_CEI_VALOR "
cSelect += ", '' P500_CEI_CODIGO, '' P500_CEI_DESCRI, 0 P500_CEI_VALOR "

cFrom := RetSqlName( "CEG" ) + " CEG "

cFrom += "INNER JOIN " + RetSqlName( "CEH" ) + " CEH "
cFrom += "  ON CEH.CEH_FILIAL = CEG.CEG_FILIAL "
cFrom += " AND CEH.CEH_ID = CEG.CEG_ID "
cFrom += " AND CEH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHA.CHA_ID = CEH.CEH_IDCODC "
cFrom += " AND CHA.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom += " AND C2R.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere += "AND CEG.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registro P130

cSelect2 := "  'P130' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50 
	cSelect2 += ", 0 , 0 "
endif

cSelect2 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "
cSelect2 += ", '', '', '', '', '', '', 0, '' "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "
cSelect2 += ", '', '', 0 "

cFrom2 := RetSqlName( "CEG" ) + " CEG "

cFrom2 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom2 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom2 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom2 += " AND CEI.CEI_REGECF = '01' "
cFrom2 += " AND CEI.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom2 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom2 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom2 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere2 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere2 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere2 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere2 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere2 += "AND CEG.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Registro P150

cSelect3 := "  'P150' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect3 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50
	cSelect3 += ", 0 , 0 "
endif

cSelect3 += ", '', '', 0 "
cSelect3 += ", CHA.CHA_CODIGO, CHA.CHA_DESCRI, CHA.CHA_TPCTA, CHA.CHA_NIVEL, C2R.C2R_CODIGO, CHACHA.CHA_CODIGO CHA_CHA_CODIGO, CHE.CHE_SALFIN, CHE.CHE_INDFIN "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "
cSelect3 += ", '', '', 0 "

cFrom3 := RetSqlName( "CEG" ) + " CEG "

cFrom3 += "INNER JOIN " + RetSqlName( "CHE" ) + " CHE "
cFrom3 += "  ON CHE.CHE_FILIAL = CEG.CEG_FILIAL "
cFrom3 += " AND CHE.CHE_ID = CEG.CEG_ID "
cFrom3 += " AND CHE.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom3 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom3 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom3 += " AND CAH.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom3 += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom3 += " AND CHA.CHA_ID = CHE.CHE_IDCODC "
cFrom3 += " AND CHA.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "C2R" ) + " C2R "
cFrom3 += "  ON C2R.C2R_FILIAL = '" + xFilial( "C2R" ) + "' "
cFrom3 += " AND C2R.C2R_ID = CHA.CHA_CODNAT "
cFrom3 += " AND C2R.D_E_L_E_T_ = '' "

cFrom3 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHACHA "
cFrom3 += "  ON CHACHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom3 += " AND CHACHA.CHA_ID = CHA.CHA_IDCTAS "
cFrom3 += " AND CHACHA.D_E_L_E_T_ = '' "

//cWhere3 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere3 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere3 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere3 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere3 += "AND CEG.D_E_L_E_T_ = '' "

cSelect3 := "%" + cSelect3 + "%"
cFrom3   := "%" + cFrom3   + "%"
cWhere3  := "%" + cWhere3  + "%"

//Registro P200

cSelect4 := "  'P200' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect4 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50 
	cSelect4 += ", 0 , 0 "
endif

cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', '', '', '', '', 0, '' "
cSelect4 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "
cSelect4 += ", '', '', 0 "

cFrom4 := RetSqlName( "CEG" ) + " CEG "

cFrom4 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom4 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom4 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom4 += " AND CEI.CEI_REGECF = '02' "
cFrom4 += " AND CEI.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom4 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom4 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom4 += " AND CAH.D_E_L_E_T_ = '' "

cFrom4 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom4 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom4 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom4 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere4 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere4 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere4 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere4 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere4 += "AND CEG.D_E_L_E_T_ = '' "

cSelect4 := "%" + cSelect4 + "%"
cFrom4   := "%" + cFrom4   + "%"
cWhere4  := "%" + cWhere4  + "%"

//Registro P230

cSelect5 := "  'P230' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect5 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50 
	cSelect5 += ", 0 , 0 "
endif

cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', '', '', '', '', 0, '' "
cSelect5 += ", '', '', 0 "
cSelect5 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "
cSelect5 += ", '', '', 0 "

cFrom5 := RetSqlName( "CEG" ) + " CEG "

cFrom5 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom5 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom5 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom5 += " AND CEI.CEI_REGECF = '03' "
cFrom5 += " AND CEI.D_E_L_E_T_ = '' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom5 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom5 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom5 += " AND CAH.D_E_L_E_T_ = '' "

cFrom5 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom5 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom5 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom5 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere5 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere5 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere5 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere5 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere5 += "AND CEG.D_E_L_E_T_ = '' "

cSelect5 := "%" + cSelect5 + "%"
cFrom5   := "%" + cFrom5   + "%"
cWhere5  := "%" + cWhere5  + "%"

//Registro P300

cSelect6 := "  'P300' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect6 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50
	cSelect6 += ", 0 , 0 "
endif

cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', '', '', '', '', 0, '' "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "
cSelect6 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "
cSelect6 += ", '', '', 0 "
cSelect6 += ", '', '', 0 "

cFrom6 := RetSqlName( "CEG" ) + " CEG "

cFrom6 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom6 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom6 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom6 += " AND CEI.CEI_REGECF = '04' "
cFrom6 += " AND CEI.D_E_L_E_T_ = '' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom6 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom6 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom6 += " AND CAH.D_E_L_E_T_ = '' "

cFrom6 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom6 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom6 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom6 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere6 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere6 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere6 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere6 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere6 += "AND CEG.D_E_L_E_T_ = '' "

cSelect6 := "%" + cSelect6 + "%"
cFrom6   := "%" + cFrom6   + "%"
cWhere6  := "%" + cWhere6  + "%"

//Registro P400

cSelect7 := "  'P400' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect7 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50 
	cSelect7 += ", 0 , 0 "
endif


cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', '', '', '', '', 0, '' "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", '', '', 0 "
cSelect7 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "
cSelect7 += ", '', '', 0 "

cFrom7 := RetSqlName( "CEG" ) + " CEG "

cFrom7 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom7 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom7 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom7 += " AND CEI.CEI_REGECF = '05' "
cFrom7 += " AND CEI.D_E_L_E_T_ = '' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom7 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom7 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom7 += " AND CAH.D_E_L_E_T_ = '' "

cFrom7 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom7 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom7 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom7 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere7 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere7 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere7 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere7 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere7 += "AND CEG.D_E_L_E_T_ = '' "

cSelect7 := "%" + cSelect7 + "%"
cFrom7   := "%" + cFrom7   + "%"
cWhere7  := "%" + cWhere7  + "%"

//Registro P500

cSelect8 := "  'P500' REGISTRO, CEG.CEG_FILIAL, CEG.CEG_DTINI, CEG.CEG_DTFIN, CAH.CAH_CODIGO "
cSelect8 += ", '', '', '', '', '', '', 0, '', 0, '' "

if lBlpEcf50 
	cSelect8 += ", 0 , 0 "
endif

cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', '', '', '', '', 0, '' "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", '', '', 0 "
cSelect8 += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, CEI.CEI_VALOR "

cFrom8 := RetSqlName( "CEG" ) + " CEG "

cFrom8 += "INNER JOIN " + RetSqlName( "CEI" ) + " CEI "
cFrom8 += "  ON CEI.CEI_FILIAL = CEG.CEG_FILIAL "
cFrom8 += " AND CEI.CEI_ID = CEG.CEG_ID "
cFrom8 += " AND CEI.CEI_REGECF = '06' "
cFrom8 += " AND CEI.D_E_L_E_T_ = '' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom8 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom8 += " AND CAH.CAH_ID = CEG.CEG_IDPERA "
cFrom8 += " AND CAH.D_E_L_E_T_ = '' "

cFrom8 += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom8 += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom8 += " AND CH6.CH6_ID = CEI.CEI_IDCODC "
cFrom8 += " AND CH6.D_E_L_E_T_ = '' "

//cWhere8 := "    CEG.CEG_FILIAL IN (" + cFilSel + ") "
cWhere8 := "    CEG.CEG_FILIAL = '" + xFilial( "CEG" ) + "' "
cWhere8 += "AND CEG.CEG_DTINI >= '" + DToS( cDtInicio ) + "' "
cWhere8 += "AND CEG.CEG_DTFIN <= '" + DToS( cDtFinal ) + "' "
cWhere8 += "AND CEG.D_E_L_E_T_ = '' "

cSelect8 := "%" + cSelect8 + "%"
cFrom8   := "%" + cFrom8   + "%"
cWhere8  := "%" + cWhere8  + "%"

//Ordenacao da Query

cOrderBy := "CEG_FILIAL, CAH_CODIGO, REGISTRO "

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

Return() 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAGetCEG

Executa a Query para verificação dos períodos pertencentes ao ano,
no caso de geração Trimestral.

@Param 	cDtIni 	-> Data inicial do período 
       	cDtFIM -> Data final do Periodo
@Author Graziella Bianchin 
@Since 19/07/2017
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAGetCEG(cDtIni,cDtFIM)

Local cAlias := GetNextAlias()

BeginSql Alias cAlias

SELECT CEG.R_E_C_N_O_, CEG_DTINI, CEG_DTFIN
FROM %Table:CEG% CEG
WHERE CEG.%NotDel% AND CEG_FILIAL = %xFilial:CEG% AND CEG_DTINI >= %Exp:cDtIni% AND CEG_DTFIN <= %Exp:cDtFIM%

EndSql

Return cAlias
