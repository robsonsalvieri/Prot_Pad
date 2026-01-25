#Include "Protheus.ch"

#Define nCommit 500 //Limite da string a ser confirmada na tabela( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFK

Rotina extratora da informacoes para o Bloco K do ECF.

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
@Since 01/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFECFK( cTABCTL, aWizard, cFilSel, cJobAux )

Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"K"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

	RegK030( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

	//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
	RegK001( aECFInfo, cIndMov )

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
/*/{Protheus.doc} RegK001

Rotina para extrair e gravar as informacoes do Registro K001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 01/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegK001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "K001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "K001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegK030

Rotina para extrair e gravar as informacoes do Registro K030 e seus filhos.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		nSeq     -> Sequencia de gravacao do Bloco
		aWizard  -> Array com as informacoes da Wizard
		cFilSel  -> Filiais selecionadas para o processamento
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 01/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegK030( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cLoop     := ""
Local cPeriodo  := ""
Local cAliasQry := GetNextAlias()
Local lCpEcf50  := VerEcf50()

ECFQryK( cAliasQry, aWizard, cFilSel )

//Registro K030
While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "K030"										//01 - REG
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CAC_DTINI )		//02 - DT_INI
	cStrTxt += cDelimit + Dt2Caract( ( cAliasQry )->CAC_DTFIN )		//03 - DT_FIN
	cStrTxt += cDelimit + ( cAliasQry )->CAH_CODIGO					//04 - PER_APUR
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "K030", cStrTxt )

	nSeq ++

	cPeriodo := ( cAliasQry )->CAC_DTINI + ( cAliasQry )->CAC_DTFIN + ( cAliasQry )->CAH_CODIGO

	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->CAC_DTINI + ( cAliasQry )->CAC_DTFIN + ( cAliasQry )->CAH_CODIGO == cPeriodo

		//Registro K155
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "K155"

			If !Empty( ( cAliasQry )->CAD_C1O_CODIGO + ( cAliasQry )->CAD_C1P_CODCUS )

				cStrTxt := cDelimit + "K155"														//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAD_C1O_CODIGO )				//02 - COD_CTA
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAD_C1P_CODCUS )				//03 - COD_CCUS
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAD_VLRSLI, 16, 2 )				//04 - VL_SLD_INI
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAD_SITSLI == "1", "D", "C" )		//05 - IND_VL_SLD_INI
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAD_VLRDEB, 16, 2 )				//06 - VL_DEB
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAD_VLRCRD, 16, 2 )				//07 - VL_CRED
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAD_VLRSLF, 16, 2 )				//08 - VL_SLD_FIN
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAD_SITSLF == "1", "D", "C" )		//09 - IND_VL_SLD_FIN
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "K155", cStrTxt )

				nSeq ++

				cLoop := ( cAliasQry )->CAD_C1O_CODIGO + ( cAliasQry )->CAD_C1P_CODCUS

				//Registro K156
				While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "K155" .and. ((( cAliasQry )->CAD_C1O_CODIGO + ( cAliasQry )->CAD_C1P_CODCUS) == cLoop)
					If !Empty( ( cAliasQry )->CAE_CHA_CODIGO )
						if lCpEcf50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005"
							cStrTxt := cDelimit + "K156"											//01 REG
							cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAE_CHA_CODIGO )		//02 COD_CTA_REF
							cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAE_VLRSI , 16, 2 )		//03 VL_SLD_INI
							cStrTxt += cDelimit + Iif( ( cAliasQry )->CAE_SITSI == "1", "D", "C" )	//04 IND_VL_SLD_INI
							cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAE_VLRDB , 16, 2 )		//05 VL_DEB
							cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAE_VLRCR , 16, 2 )		//06 VL_CRED
							cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAE_VLRREF, 16, 2 )		//07 VL_SLD_FIN
							cStrTxt += cDelimit + Iif( ( cAliasQry )->CAE_SITVLR == "1", "D", "C" )	//08 IND_VL_SLD_FIN
						Else
							cStrTxt := cDelimit + "K156"											//01 - REG
							cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAE_CHA_CODIGO )		//02 - COD_CTA_REF
							cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAE_VLRREF, 16, 2 )		//03 - VL_SLD_FIN
							cStrTxt += cDelimit + Iif( ( cAliasQry )->CAE_SITVLR == "1", "D", "C" )	//04 - IND_VL_SLD_FIN
						EndIf

						cStrTxt += cDelimit

						FExecSQL( aECFInfo, nSeq, "K156", cStrTxt )

						nSeq ++

					EndIf

					( cAliasQry )->( DBSkip() )
				EndDo

			Else

				( cAliasQry )->( DBSkip() )
			EndIf

		EndDo

		//Registro K355
		While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO ) == "K355"

			If !Empty( ( cAliasQry )->CAF_C1O_CODIGO + ( cAliasQry )->CAF_C1P_CODCUS )

				cStrTxt := cDelimit + "K355"														//01 - REG
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAF_C1O_CODIGO )				//02 - COD_CTA
				cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAF_C1P_CODCUS )				//03 - COD_CCUS
				cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAF_VLRSLF, 16, 2 )				//04 - VL_SLD_FIN
				cStrTxt += cDelimit + Iif( ( cAliasQry )->CAF_SITSLF == "1", "D", "C" )		//05 - IND_VL_SLD_FIN
				cStrTxt += cDelimit

				FExecSQL( aECFInfo, nSeq, "K355", cStrTxt )

				nSeq ++

				cLoop := ( cAliasQry )->CAF_C1O_CODIGO+( cAliasQry )->CAF_C1P_CODCUS 

				//Registro K356
				While ( cAliasQry )->( !Eof() ) .and. AllTrim( ( cAliasQry )->REGISTRO )== "K355" .and. ((( cAliasQry )->CAF_C1O_CODIGO+( cAliasQry )->CAF_C1P_CODCUS)  == cLoop)

					If !Empty( ( cAliasQry )->CAG_CHA_CODIGO )

						cStrTxt := cDelimit + "K356"														//01 - REG
						cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CAG_CHA_CODIGO )				//02 - COD_CTA_REF
						cStrTxt += cDelimit + Val2Str( ( cAliasQry )->CAG_VLRREF, 16, 2 )				//03 - VL_SLD_FIN
						cStrTxt += cDelimit + Iif( ( cAliasQry )->CAG_SITVLR == "1", "D", "C" )		//04 - IND_VL_SLD_FIN
						cStrTxt += cDelimit

						FExecSQL( aECFInfo, nSeq, "K356", cStrTxt )

						nSeq ++

					EndIf

					( cAliasQry )->( DBSkip() )
				EndDo

			Else

				( cAliasQry )->( DBSkip() )
			EndIf

		EndDo

	EndDo

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryK

Executa a Query principal para a extracao do Bloco K do ECF.

@Param cAliasQry -> Alias para gravacao da Query
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Author Felipe C. Seolin
@Since 15/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ECFQryK( cAliasQry, aWizard, cFilSel )

Local cSelect  := cSelect2 := ""
Local cFrom    := cFrom2   := ""
Local cWhere   := cWhere2  := ""
Local cOrderBy := ""
Local lCpEcf50 := VerEcf50()

//Registros K155 e K156
cSelect := " 'K155' REGISTRO, CAC.CAC_FILIAL, CAC.CAC_DTINI, CAC.CAC_DTFIN, CAH.CAH_CODIGO "
cSelect += ", C1O.C1O_CODIGO CAD_C1O_CODIGO, C1P.C1P_CODCUS CAD_C1P_CODCUS, CAD.CAD_VLRSLI, CAD.CAD_SITSLI, CAD.CAD_VLRDEB, CAD.CAD_VLRCRD, CAD.CAD_VLRSLF, CAD.CAD_SITSLF "
cSelect += ", CHA.CHA_CODIGO CAE_CHA_CODIGO, CAE.CAE_VLRREF, CAE.CAE_SITVLR "
if lCpEcf50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005" 
	cSelect += ", CAE.CAE_VLRSI, CAE.CAE_VLRDB, CAE.CAE_VLRCR, CAE.CAE_SITSI "
EndIf

cSelect += ", '' CAF_C1O_CODIGO, '' CAF_C1P_CODCUS, 0 CAF_VLRSLF, '' CAF_SITSLF "
cSelect += ", '' CAG_CHA_CODIGO, 0 CAG_VLRREF, '' CAG_SITVLR "

cFrom := RetSqlName( "CAC" ) + " CAC "

cFrom += "LEFT JOIN " + RetSqlName( "CAD" ) + " CAD "
cFrom += "  ON CAD.CAD_FILIAL = CAC.CAC_FILIAL "
cFrom += " AND CAD.CAD_ID = CAC.CAC_ID "
cFrom += " AND CAD.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAE" ) + " CAE "
cFrom += "  ON CAE.CAE_FILIAL = CAD.CAD_FILIAL "
cFrom += " AND CAE.CAE_ID = CAD.CAD_ID "
cFrom += " AND CAE.CAE_CTA = CAD.CAD_CTA "
cFrom += " AND CAE.CAE_CODCUS = CAD.CAD_CODCUS "
cFrom += " AND CAE.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom += " AND CAH.CAH_ID = CAC.CAC_IDPERA "
cFrom += " AND CAH.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
cFrom += "  ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
cFrom += " AND C1O.C1O_ID = CAD.CAD_CTA "
cFrom += " AND C1O.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
cFrom += "  ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
cFrom += " AND C1P.C1P_ID = CAD.CAD_CODCUS "
cFrom += " AND C1P.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom += " AND CHA.CHA_ID = CAE.CAE_IDCTAR "
cFrom += " AND CHA.D_E_L_E_T_ = '' "

//cWhere := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
cWhere := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
cWhere += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND CAC.D_E_L_E_T_ = '' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

//Registros K355 e K356

cSelect2 := " 'K355' REGISTRO, CAC.CAC_FILIAL, CAC.CAC_DTINI, CAC.CAC_DTFIN, CAH.CAH_CODIGO "
cSelect2 += ", '', '', 0, '', 0, 0, 0, '' "
cSelect2 += ", '', 0, '' "
if lCpEcf50 .And. Len(aWizard[1]) >= 5 .And. aWizard[1,5] >= "0005" 
	cSelect2 += ", 0, 0, 0, '' "
endif
cSelect2 += ", C1O.C1O_CODIGO, C1P.C1P_CODCUS, CAF.CAF_VLRSLF, CAF.CAF_SITSLF "
cSelect2 += ", CHA.CHA_CODIGO, CAG.CAG_VLRREF, CAG.CAG_SITVLR "

cFrom2 := RetSqlName( "CAC" ) + " CAC "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAF" ) + " CAF "
cFrom2 += "  ON CAF.CAF_FILIAL = CAC.CAC_FILIAL "
cFrom2 += " AND CAF.CAF_ID = CAC.CAC_ID "
cFrom2 += " AND CAF.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAG" ) + " CAG "
cFrom2 += "  ON CAG.CAG_FILIAL = CAF.CAF_FILIAL "
cFrom2 += " AND CAG.CAG_ID = CAF.CAF_ID "
cFrom2 += " AND CAG.CAG_CTA = CAF.CAF_CTA "
cFrom2 += " AND CAG.CAG_CODCUS = CAF.CAF_CODCUS "
cFrom2 += " AND CAG.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CAH" ) + " CAH "
cFrom2 += "  ON CAH.CAH_FILIAL = '" + xFilial( "CAH" ) + "' "
cFrom2 += " AND CAH.CAH_ID = CAC.CAC_IDPERA "
cFrom2 += " AND CAH.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "C1O" ) + " C1O "
cFrom2 += "  ON C1O.C1O_FILIAL = '" + xFilial( "C1O" ) + "' "
cFrom2 += " AND C1O.C1O_ID = CAF.CAF_CTA "
cFrom2 += " AND C1O.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "C1P" ) + " C1P "
cFrom2 += "  ON C1P.C1P_FILIAL = '" + xFilial( "C1P" ) + "' "
cFrom2 += " AND C1P.C1P_ID = CAF.CAF_CODCUS "
cFrom2 += " AND C1P.D_E_L_E_T_ = '' "

cFrom2 += "LEFT JOIN " + RetSqlName( "CHA" ) + " CHA "
cFrom2 += "  ON CHA.CHA_FILIAL = '" + xFilial( "CHA" ) + "' "
cFrom2 += " AND CHA.CHA_ID = CAG.CAG_IDCTAR "
cFrom2 += " AND CHA.D_E_L_E_T_ = '' "

//cWhere := "    CAC.CAC_FILIAL IN (" + cFilSel + ") "
cWhere2 := "    CAC.CAC_FILIAL = '" + xFilial( "CAC" ) + "' "
cWhere2 += "AND CAC.CAC_DTINI >= '" + DToS( aWizard[1,1] ) + "' "
cWhere2 += "AND CAC.CAC_DTFIN <= '" + DToS( aWizard[1,2] ) + "' "
cWhere2 += "AND CAC.D_E_L_E_T_ = '' "

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"

//Ordenacao da Query

cOrderBy := "CAC_FILIAL, CAH_CODIGO, REGISTRO "

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

	ORDER BY
		%Exp:cOrderBy%

EndSql

Return()
