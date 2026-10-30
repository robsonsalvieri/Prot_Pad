#INCLUDE "PROTHEUS.CH"

#DEFINE nCommit 500 //Limite da string a ser confirmada na tabela ( Desenvolver tratamento )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFECFV
@type			function
@description	Rotina extratora das informações para o Bloco V da ECF.
@author			Felipe C. Seolin
@since			24/04/2018
@version		1.0
@param			cTABCTL	-	Nome da tabela de controle de transações
				aWizard	-	Array com as informações da Wizard
				cFilSel	-	Filiais selecionadas para o processamento
				cJobAux	-	Responsável pelo controle de término do Bloco - Multithread
@obs			Luccas ( 31/03/2016 ): Devido a mudança em relação ao compartilhamento das tabelas
				do TAF ( inicialmente todas eram exclusivas, mas o cliente pode optar por ter tabelas
				compartilhadas, por exemplo Plano de Contas, Centro de Custo, Itens, etc. ), as rotinas
				de geração das obrigações tiveram que ser alteradas ( em algumas situações ) para a
				utilização da função xFilial ao invés da variável cFilSel.
				O conteúdo desta variável é o mesmo de cFilAnt, pois a ECF não fornece a opção
				de ser gerada para várias filiais, ela é gerada a partir da filial logada que
				deve ser a Matriz ou SCP.
				A variável cFilSel foi mantida no programa de geração do arquivo por compatibilidade
				de funções e para preenchimento do campo FILIAL da tabela TAFECF_XX.
/*/
//---------------------------------------------------------------------
Function TAFECFV( cTABCTL, aWizard, cFilSel, cJobAux, cIdPeriodo )

Local oError	as object
Local cBloco	as char
Local cIndMov	as char
Local cFil		as char
Local nSeq		as numeric
Local aECFInfo	as array
Local lFound	as logical
Local lGeraV	as logical

oError		:=	ErrorBlock( { |Obj| TAFConout( "Mensagem de Erro: " + Chr( 10 ) + Obj:Description,3,.T.,"ECF" ) } )
cBloco		:=	"V"
cIndMov	:=	"1"
cFil		:=	TurnFilObr( cFilSel )
nSeq		:=	2
aECFInfo	:=	{ cFil, DToS( aWizard[1][1] ), DToS( aWizard[1][2] ), cBloco }
lFound		:=	.T.
lGeraV		:=	.F.

	DBSelectArea( "CHD" )
	CHD->( DBSetOrder( 1 ) )
	If CHD->( MsSeek( xFilial( "CHD" ) + cIdPeriodo ) )
		
		lGeraV := (CHD->CHD_DEREX == "1" ) 
				
	EndIf

If aWizard[1][5] > "0003" .AND. lGeraV //Bloco criado no layout 0004

	//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
	Begin Sequence
		RegV010( aECFInfo, @nSeq, aWizard, cFilSel, @cIndMov )

		//Executo Registro 001 por último para saber se houve movimento no Bloco
		RegV001( aECFInfo, cIndMov )
	Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux, "9" )
		GlbUnlock()
	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multithread
		PutGlbValue( cJobAux, "1" )
		GlbUnlock()

		//Altera o Status da tabela de controle para 2, indicando que o bloco foi processado
		xTafCTLObr( "2", cBloco, aWizard, cFilSel,, cTABCTL, "ECF" )
	EndIf
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegV001
@type			function
@description	Rotina para extrair e gravar as informações do Registro V001.
@author			Felipe C. Seolin
@since			24/04/2018
@version		1.0
@param			aECFInfo	-	Informações gerais para tabela de controle de transações
				cIndMov		-	Indicador de movimento do bloco
/*/
//---------------------------------------------------------------------
Static Function RegV001( aECFInfo, cIndMov )

Local cDelimit	as char
Local cStrTxt	as char

cDelimit	:=	"|"
cStrTxt		:=	""

cStrTxt := cDelimit + "V001"	//01 - REG
cStrTxt += cDelimit + cIndMov	//02 - IND_DAD
cStrTxt += cDelimit

FExecSQL( aECFInfo, 1, "V001", cStrTxt )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} RegV010
@type			function
@description	Rotina para extrair e gravar as informações do Registro V010 e seus filhos.
@author			Felipe C. Seolin
@since			24/04/2018
@version		1.0
@param			aECFInfo	-	Informações gerais para tabela de controle de transações
				nSeq		-	Seqüência de gravação do Bloco
				aWizard		-	Array com as informações da Wizard
				cFilSel		-	Filiais selecionadas para o processamento
				cIndMov		-	Indicador de movimento do bloco
/*/
//---------------------------------------------------------------------
Static Function RegV010( aECFInfo, nSeq, aWizard, cFilSel, cIndMov )

Local cDelimit	as char
Local cStrTxt	as char
Local cCodInst	as char
Local cMes		as char
Local cCodLan	as char
Local cAliasQry	as char
Local nI		as numeric
Local nValor	as numeric
Local aAux		as array
Local aResp		as array
Local aDerex	as array

cDelimit	:=	"|"
cStrTxt		:=	""
cCodInst	:=	""
cMes		:=	""
cCodLan		:=	""
cAliasQry	:=	GetNextAlias()
cQryResp	:=	GetNextAlias()
nI			:=	0
nValor		:=	0
aAux		:=	{}
aResp		:=	{}
aDerex		:=	{}

//Os cadastros para este Bloco foram construídos separando os cadastros do movimento, pensando em reaproveitamento de cadastros.
//Esta não foi a construção utilizada na concepção da ECF, portanto, a modelagem de dados deste Bloco difere das demais.
//Para resolver todas as informações na query, foi necessário adaptar a impressão do arquivo texto no banco de dados,
//armazenando os filhos em array, para gravar no banco de dados com o sequencial correto. Desta forma, a chamada da função FExecSQL
//deixou de ser executada após posicionamento na linha da query, para ser executada em um laço com os arrays de cadastro e movimento.

ECFQryV( cAliasQry, aWizard, cFilSel )

While ( cAliasQry )->( !Eof() )

	cIndMov := "0"

	cStrTxt := cDelimit + "V010"									//01 - REG
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->V1Q_NOME )		//02 - NOME_INSTITUICAO
	cStrTxt += cDelimit + TAFConType( ( cAliasQry )->C08_JURIDI )	//03 - PAIS
	cStrTxt += cDelimit + ( cAliasQry )->CZU_SIGLAM					//04 - TIP_MOEDA
	cStrTxt += cDelimit

	FExecSQL( aECFInfo, nSeq, "V010", cStrTxt )

	nSeq ++

	cCodInst := ( cAliasQry )->V1Q_CODIGO

	EcfQryRes(cQryResp,cCodInst)
	//MemoWrite('c:\temp\EcfQryRes.txt',GetLastQuery()[2])
	while (cQryResp)->(!eof())

		cStrTxt := cDelimit + 'V020'								//01 - REG
		cStrTxt += cDelimit + TAFConType( (cQryResp)->V1R_NOME )	//02 - NOME
		cStrTxt += cDelimit + TAFConType( (cQryResp)->V1R_ENDERE )	//03 - ENDERECO
		cStrTxt += cDelimit + TAFConType( (cQryResp)->V1P_CODIGO )	//04 - TIPO_DO_C
		cStrTxt += cDelimit + TAFConType( (cQryResp)->V1R_NUMDOC )	//05 - NI
		cStrTxt += cDelimit + TAFConType( (cQryResp)->V3T_CODCTA )	//06 - IDENT_CONTA
		cStrTxt += cDelimit	

		aAdd( aResp, cStrTxt )
		(cQryResp)->(DbSkip())
	enddo
	(cQryResp)->(DbCloseArea())
	
	//Laço por Código da Instituição
	While ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->V1Q_CODIGO == cCodInst

		cMes := StrZero( Month( SToD( ( cAliasQry )->V1S_DATA ) ), 2 )

		//Armazenamento do Período dos Lançamentos
		If !Empty( cMes )
			cStrTxt := cDelimit + "V030"	//01 - REG
			cStrTxt += cDelimit + cMes		//02 - MES
			cStrTxt += cDelimit

			aAdd( aDerex, { "V030", cStrTxt } )

			//Laço por Mês para armazenar os Lançamentos de forma ordenada
			While ( cAliasQry )->( !Eof() ) .and. StrZero( Month( SToD( ( cAliasQry )->V1S_DATA ) ), 2 ) == cMes

				//Armazenamento dos Lançamentos
				//Utiliza o mesmo array que o Período, pois se trata de Registro Filho na hierarquia do Layout
				If !Empty( ( cAliasQry )->CH6_CODIGO )
					nValor := nValor + ( cAliasQry )->V1S_VALOR

					cStrTxt := cDelimit + "V100"									//01 - REG
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_CODIGO )	//02 - CODIGO
					cStrTxt += cDelimit + TAFConType( ( cAliasQry )->CH6_DESCRI )	//03 - DESCRICAO
					cStrTxt += cDelimit + Val2Str( nValor, 16, 2 )					//04 - VALOR
					cStrTxt += cDelimit

					//aAdd( aDerex, { "V100", cStrTxt } )
				EndIf

				//Inteligência para somar o valor caso o próximo Código de Lançamento seja o mesmo
				cCodLan := ( cAliasQry )->CH6_CODIGO

				( cAliasQry )->( DBSkip() )

				If cCodLan <> ( cAliasQry )->CH6_CODIGO
					aAdd( aDerex, { "V100", cStrTxt } )
					nValor := 0
				EndIf

			EndDo
		EndIf

	EndDo

	//Grava no Banco de Dados os dados coletados dos Responsáveis pela Movimentação
	For nI := 1 to Len( aResp )
		FExecSQL( aECFInfo, nSeq, "V020", aResp[nI] )
		nSeq ++
	Next nI

	//Grava no Banco de Dados os dados coletados dos Lançamentos por Período
	For nI := 1 to Len( aDerex )
		FExecSQL( aECFInfo, nSeq, aDerex[nI,1], aDerex[nI,2] )
		nSeq ++
	Next nI

	//Limpeza dos arrays para iniciar novo controle na próxima Instituição
	aResp := {}
	aDerex := {}

EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ECFQryV
@type			function
@description	Executa a Query principal para a extração do Bloco V da ECF.
@author			Felipe C. Seolin
@since			24/04/2018
@version		1.0
@param			cAliasQry	-	Alias para gravação da Query
				aWizard		-	Array com as informações da Wizard
				cFilSel		-	Filiais selecionadas para o processamento
/*/
//---------------------------------------------------------------------
Static Function ECFQryV( cAliasQry, aWizard, cFilSel )

Local cSelect	as char
Local cFrom		as char
Local cWhere	as char
Local cOrderBy	as char

cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""

cSelect := "  V1Q.V1Q_CODIGO, V1Q.V1Q_NOME, C08.C08_JURIDI, CZU.CZU_SIGLAM "
cSelect += ", V1R.V1R_NOME, V1R.V1R_ENDERE, V1P.V1P_CODIGO, V1R.V1R_NUMDOC, V1S.V1S_CODCTA "
cSelect += ", V1S.V1S_DATA "
cSelect += ", CH6.CH6_CODIGO, CH6.CH6_DESCRI, V1S.V1S_VALOR "

cFrom := RetSqlName( "V1S" ) + " V1S "

cFrom += "INNER JOIN " + RetSqlName( "V1Q" ) + " V1Q "
cFrom += "   ON V1Q.V1Q_FILIAL = V1S.V1S_FILIAL "
cFrom += "  AND V1Q.V1Q_ID = V1S.V1S_IDCODI "
cFrom += "  AND V1Q.D_E_L_E_T_ = '' "

cFrom += "INNER JOIN " + RetSqlName( "V1R" ) + " V1R "
cFrom += "   ON V1R.V1R_FILIAL = V1S.V1S_FILIAL "
cFrom += "  AND V1R.V1R_ID = V1S.V1S_IDRESP "
cFrom += "  AND V1R.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "C08" ) + " C08 "
cFrom += "  ON C08.C08_FILIAL = '" + xFilial( "C08" ) + "' "
cFrom += " AND C08.C08_ID = V1Q.V1Q_PAIS "
cFrom += " AND C08.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CZU" ) + " CZU "
cFrom += "  ON CZU.CZU_FILIAL = '" + xFilial( "CZU" ) + "' "
cFrom += " AND CZU.CZU_ID = V1Q.V1Q_IDMOED "
cFrom += " AND CZU.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "V1P" ) + " V1P "
cFrom += "  ON V1P.V1P_FILIAL = '" + xFilial( "V1P" ) + "' "
cFrom += " AND V1P.V1P_ID = V1R.V1R_IDTPDO "
cFrom += " AND V1P.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFrom += "  ON CH6.CH6_FILIAL = '" + xFilial( "CH6" ) + "' "
cFrom += " AND CH6.CH6_ID = V1S.V1S_IDCODL "
cFrom += " AND CH6.D_E_L_E_T_ = '' "

cWhere := "    V1S.V1S_FILIAL = '" + xFilial( "V1S" ) + "' "
cWhere += "AND V1S.V1S_DATA BETWEEN '" + DToS( aWizard[1,1] ) + "' AND '" + DToS( aWizard[1,2] ) + "' "
cWhere += "AND V1S.D_E_L_E_T_ = '' "

cOrderBy := "V1Q.V1Q_CODIGO, V1S.V1S_DATA, CH6.CH6_CODIGO "

cSelect		:= "%" + cSelect + "%"
cFrom		:= "%" + cFrom + "%"
cWhere		:= "%" + cWhere + "%"
cOrderBy	:= "%" + cOrderBy + "%"

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

//---------------------------------------------------------------------
/*/{Protheus.doc} EcfQryRes
@type			function
@description	Executa a Query para devolver os responsveis pela instituição passada por parâmetro
@author			Carlos E. N. da Silva
@since			9/05/2019
@version		1.0
@param			cAliasQry -> Alias para gravação da Query
				cCodResp -> Cdigo da Instituicao 
/*/
//---------------------------------------------------------------------
Static function EcfQryRes(cQryResp,cCodInst)

Local cSelect	as char
Local cFrom		as char
Local cWhere	as char
Local cOrderBy	as char

cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""

cSelect := " V1R.V1R_NOME, "
cSelect += " V1R.V1R_ENDERE, "
cSelect += " V1R.V1R_NUMDOC, "
cSelect += " V3T.V3T_CODCTA, "
cSelect += " V1P.V1P_CODIGO "

cFrom := RetSqlName( 'V1Q' ) + " V1Q "
cFrom += "	INNER JOIN " + RetSqlName('V3T') + " V3T ON V3T.V3T_FILIAL = '" + xFilial('V3T') + "' AND V3T.V3T_ID = V1Q.V1Q_ID AND V3T.D_E_L_E_T_ = ' ' "
cFrom += "	INNER JOIN " + RetSqlName('V1R') + " V1R ON V1R.V1R_FILIAL = '" + xFilial('V1R') + "' AND V1R.V1R_ID = V3T.V3T_IDRESP AND V1R.V1R_NUMDOC != ' ' AND V1R.D_E_L_E_T_ = ' ' "
cFrom += "	INNER JOIN " + RetSqlName('V1P') + " V1P ON V1P.V1P_FILIAL = '" + xFilial('V1P') + "'  AND V1P.V1P_ID = V1R.V1R_IDTPDO AND V1P.V1P_CODIGO != ' ' AND  V1P.D_E_L_E_T_ = ' ' "

cWhere := " V1Q.D_E_L_E_T_ = ' ' "
cWhere += "	AND V1Q.V1Q_FILIAL = '" + xFilial('V1Q') + "' "
cWhere += " AND V1Q.V1Q_CODIGO = '" + cCodInst + "' "

cSelect		:= "%" + cSelect + "%"
cFrom		:= "%" + cFrom + "%"
cWhere		:= "%" + cWhere + "%"

BeginSql Alias cQryResp

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

return()	
