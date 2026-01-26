#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFQ

Rotina extratora da informacoes para o Bloco Q do ECF.

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

@Author Henrique Pereira
@Since 16/03/2016
@Version 1.0
/*/
//---------------------------------------------------------------------

Function TAFECFQ( cTABCTL, aWizard, cFilSel, cJobAux )
Local oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description,3,.T.,"ECF" ) } )
Local cBloco		:=	"Q"
Local cIndMov		:=	"1"
Local cFil			:=	TurnFilObr( cFilSel )
Local nSeq			:=	2
Local aECFInfo	:=	{ cFil, DToS( aWizard[1,1] ), DToS( aWizard[1,2] ), cBloco }
Local lFound		:=	.T.

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
If !(aWizard[1][5]=='0001')
	Begin Sequence
	
		If TAFAlsInDic("T0M")
			RegQ100( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )
		EndIF
	
			//Executo Registro 001 por ultimo para saber se houve movimento no Bloco
		RegQ001( aECFInfo, cIndMov )
	
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

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} RegQ100

Rotina para extrair e gravar as informacoes do Registro P001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author Felipe C. Seolin
@Since 18/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegQ100( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit  := "|"
Local cStrTxt   := ""
Local cAliasQry := GetNextAlias()
Local cFormData	:= ""

ECFQryQ( cAliasQry, aWizard, cFilSel, "Q100" )

//Registro Q100
While ( cAliasQry )->( !Eof() )

		cIndMov := "0"

		//Formatando data
		cFormData := ( cAliasQry )->(Substr(T0M_DATA,7) + Substr(T0M_DATA,5,2) + Substr(T0M_DATA,1,4))

		cStrTxt := cDelimit + "Q100"									 			//01 - REG
		cStrTxt += cDelimit +  cFormData 											//02 - DATA
		cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T0M_NUMDOC)					//03 - DESCRICAO
		cStrTxt += cDelimit + ALLTRIM(( cAliasQry )->T0M_HIST)						//04 - TIPO
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T0M_VLENT, 16, 2 )			//05 - NIVEL
		cStrTxt += cDelimit + Val2Str(  ( cAliasQry )->T0M_VLSAI	, 16, 2 )		//06 - COD_NAT
		cStrTxt += cDelimit + Val2Str( ( cAliasQry )->T0M_SLDFIN	, 16, 2 )		//07 - COD_CTA_SUP		
		cStrTxt += cDelimit

		FExecSQL( aECFInfo, nSeq, "Q100", cStrTxt )

		nSeq ++

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

Static Function ECFQryQ(cAliasQry, aWizard, cFilSel, cReg) 

Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cOrderBy := ""

IF cReg == "Q100"

	cSelect := "  'Q100' REGISTRO, T0M.T0M_DATA , T0M.T0M_NUMDOC , T0M.T0M_HIST , "
	cSelect += "  T0M.T0M_VLENT , T0M.T0M_VLSAI , T0M.T0M_SLDFIN "
		
	cFrom := RetSqlName( "T0M" ) + " T0M "

	//cWhere := "T0M.T0M_FILIAL IN (" + cFilSel + ") "
	cWhere := " T0M.T0M_FILIAL = '" + xFilial( "T0M" ) + "' "
	cWhere += "AND T0M.T0M_DATA >= '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND T0M.T0M_DATA <= '" + DToS( aWizard[1,2] ) + "' "
	cWhere += "AND T0M.D_E_L_E_T_ = ' ' "

	cOrderBy := " T0M.T0M_FILIAL, T0M.T0M_DATA, T0M.T0M_NUMDOC "

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
EndIF

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} RegP001

Rotina para extrair e gravar as informacoes do Registro P001.

@Param	aECFInfo -> Informacoes gerais para tabela de controle de transacoes
		cIndMov  -> Indicador de movimento do bloco

@Author 
@Since 
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RegQ001( aECFInfo, cIndMov )

Local cDelimit := "|"
Local cStrTxt  := ""

cStrTxt := cDelimit + "Q001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "Q001", cStrTxt )

Return()
