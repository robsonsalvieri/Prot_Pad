#INCLUDE "PROTHEUS.CH"

#Define cTABECF "TAFECF_" + cEmpAnt	//Tabela de informações geradas pelo ECF
#Define cTABCTL "TAFGERCTL"				//Tabela de controle de transações
#Define cObrig "ECF"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFXECF

Esta rotina tem como objetivo a geracao do Arquivo Magnetico do ECF por
meio das tabelas de controle do TAF.

@Param ( Nil )

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
@Since 10/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFXECF(aWizAut)

Local cNomWiz		:=	cObrig + FwGetCodFilial
Local cECFAlias		:=	""
Local cCTLAlias		:=	""
Local cDriver		:=	__CRDD
Local cTopBuild		:=	Iif( FindFunction( "TCGetBuild" ), TCGetBuild(), "" )
Local aTabECF		:=	xTAFGetStru( "TAFECF" )
Local aTabCTL		:=	xTAFGetStru( cTABCTL )
Local aTopInfo		:=	FwGetTopInfo()
Local lMsgAlert		:=	.F.
Local aErros		:= {}
Local cFunction 	:= ProcName()
Local nOpc      	:= 2 //View
Local lAuto			:= nil
Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Default aWizAut		:= {}

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//Atualiza variavel de automação
lAuto := len(aWizAut) > 0

//Prepara informações das tabelas de controle
cECFAlias := GetNextAlias()
cCTLAlias := GetNextAlias()

if (TamSX3("CAD_CTA")[1] == 36 .and. TamSX3("CAE_CTA")[1] <> 36) .Or.;
	(TamSX3("CAF_CTA")[1] == 36 .and. TamSX3("CAG_CTA")[1] <> 36) 
	lMsgAlert := .T.
endif

//Realiza a criação das duas tabelas de controle de geração do Sped ECF ( Caso não exista )
If xTAFCriaTB( , aTopInfo, cTABECF, cECFAlias, cDriver, aTabECF[1], aTabECF[2], cTopBuild,,,,@aErros  ) .and. xTAFCriaTB( , aTopInfo, cTABCTL, cCTLAlias, cDriver, aTabCTL[1], aTabCTL[2], cTopBuild,,,,@aErros  )
	If !Empty( aErros )
		Aviso( "Erro Encontrado", aErros[1,6], { "OK" }, 3 ) //##"Erro Encontrado" ##"Ok"
	Else
		if lMsgAlert
			MsgInfo("Ambiente desatualizado, é necessário executar o UPDDISTR exclusivo do ECF já disponível para download no portal do cliente, porém, esta mensagem não irá abortar a operação. ")
		endif

		//Protect Data / Log de acesso / Central de Obrigacoes
		Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

		if lAuto 
			ProcECF( , cNomWiz, cECFAlias, cCTLAlias, aWizAut )
		else	
			FWMsgRun(, { |oSay| ProcECF( oSay, cNomWiz, cECFAlias, cCTLAlias, aWizAut ) } , "Processando", "Processando a rotina...")
		endif			

	EndIf
Else
	if !lAuto
		If !Empty( aErros )
			Aviso( "Erro Encontrado", aErros[1,6], { "OK" }, 3 ) //##"Erro Encontrado" ##"Ok"
		Else
			Aviso( "Ambiente Desatualizado", "Execute a Wizard de Configuração através do Menu Miscelanea para atualizar o ambiente e liberar a utilização desta funcionalidade", { "Encerrar" }, 3 )
		EndIf
	endif	
EndIf

//Fechando os alias utilizados durante o processamento
If Select(cECFAlias)  > 0 
	( cECFAlias )->( DBCloseArea() )
EndIf

If Select(cCTLAlias)  > 0
	( cCTLAlias )->( DBCloseArea() )
EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aTabECF, 0 )
aSize( aTabCTL, 0 )

//Zerando as variáveis utilizadas
aTabECF := Nil
aTabCTL := Nil

//Limpando a memória
DelClassIntf()

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcECF

Inicia o processamento para geracao do ECF

@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
       oProcess  -> Objeto da barra de progresso da emissao do ECF
       cNomWiz   -> Nome da Wizard criada para o ECF
       cECFAlias -> Alias da tabela de informacoes geradas pelo ECF
       cCTLAlias -> Alias da tabela de controle de transacoes
	   aWizAut	 -> Variavel que indica se é uma chamada de automação e define seus parametros.

@Return ( Nil )

@Author Felipe C. Seolin
@Since 13/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ProcECF( oSay, cNomWiz, cECFAlias, cCTLAlias, aWizAut )

Local cFunction	:=	""
Local cSemaphore	:=	""
Local cFilSel		:=	"'" + AllTrim( cFilAnt ) + "' "
Local cIdPeriodo	:=	""
Local cJobAux		:=	""
Local cErrorECF	:=	""
Local cErrorTrd	:=	""

Local nQtdThread	:=	0
Local nI			:=	0
Local nProgress1	:=	0
Local nTryExec	:=	0

Local aWizard		:=	aClone(aWizAut)
Local aBlocosECF	:=	{}
Local aContab		:=	{}
Local aJobAux		:=	{}

Local lMultThread	:=	.F.
Local lProc			:=	.T.
Local lAuto 		:=  len(aWizAut) > 0 //Automação

//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
if !lAuto
	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf
endif

//Manipula as variáveis de período da wizard, pois no ECF é utilizado uma consulta para a tabela de Parâmetros de Abertura ECF ( CHD )
DBSelectArea( "CHD" )
CHD->( DBSetOrder( 1 ) )
If CHD->( MsSeek( xFilial( "CHD" ) + aWizard[1,1] ) )
	cIdPeriodo := aWizard[1,1]
	aWizard[1,1] := CHD->CHD_PERINI
	aWizard[1,2] := CHD->CHD_PERFIN
EndIf

//Bloco de geração das informações nas tabelas de controle
If lProc

	//Apresenta tela de seleção de contabilistas
	aContab := FGetContab( cFilSel, aWizard[1,5], lAuto )

	//Alimentando o array com os blocos que devem ser processados
	aBlocosECF := xTafGetObr( cObrig )

	//Seleção dos blocos que serão processados
	lProc := SelBlcObrg( cObrig, cCTLAlias, aWizard, cFilSel, @aBlocosECF , lAuto )

	If lProc

		//Alimentando a variável de controle da barra de status do processamento
		if !lAuto
			For nI := 1 to Len( aBlocosECF )
				If aBlocosECF[nI,1]
					nProgress1 ++
				EndIf
			Next nI

			nProgress1 := nProgress1 + 2		

			oSay:cCaption := "Preparando o Ambiente..." 
			ProcessMessages()
		endif	

		//Este laço realiza a verificação de todos os blocos do ECF que o usuário selecionou para o processamento
		For nI := 1 to Len( aBlocosECF )

			//Indica se o usuário selecionou o bloco
			If aBlocosECF[nI,1]

				//Deleta as informações do mesmo período/filial contidos na tabela temporária
				xDelObrig( cObrig, aBlocosECF[nI,3], aWizard, cFilSel, cTABECF, cTABCTL )

				//Função que realiza o controle da tabela de gerenciamento de geração dos blocos
				xTafCTLObr( "1", aBlocosECF[nI,3], aWizard, cFilSel, cCTLAlias, cTABCTL, cObrig )

				//Busco função de geração do Bloco
				cFunction := aBlocosECF[nI,2]

				//Processamento Multi Thread
				If lMultThread

					//Inicializa variavel global de controle das Threads
					cJobAux := StrTran( "cECF_" + FwGrpCompany() + FwCodFil(), ' ', '_' ) + StrZero( nI , 2 )

					//Seto o Status da Variavel como "0", ou seja, pendente de processamento
					PutGlbValue( cJobAux, "0" )
					GlbUnlock()

					//Adiciona o nome do arquivo de Job no array aJobAux
					aAdd( aJobAux, { cJobAux, aBlocosECF[nI,3] } )

					//Variavel de controle de Start das Execuções
					nTryExec := 0

					While .T.
						If IPCGo( cSemaphore, cObrig, cFunction, cTABCTL, aWizard, cFilSel, cJobAux, cIdPeriodo, aContab, cECFAlias )
							if !lAuto
								TAFConout( "*** Iniciando a Função  " + cFunction + " ***",1,.T.,"ECF" )
								oSay:cCaption := "Executando o Bloco... " + Right(rtrim(cFunction),1)
								ProcessMessages()
							endif	
							Exit
						Else
							nTryExec ++
							Sleep( 2000 )
						EndIf

						//Caso ocorra erro em 25 tentativas de iniciar a Thread aborta informando ao usuário o erro
						If nTryExec > 25
							//cErrorTrd := "Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo, caso o erro persista entre em contato com o administrador do sistema"
							cErrorTrd := "Não foi possivel realizar a inicialização das threads. Por favor reinicie o processo, caso o erro persista entre em contato com o administrador do sistema"
							Exit
						EndIf
					EndDo

				//MonoThread
				Else

					if !lAuto
						oSay:cCaption := "Executando o Bloco..." + aBlocosECF[nI,3]
						ProcessMessages()
					endif	

					&cFunction.( cTABCTL, aWizard, cFilSel, cJobAux, cIdPeriodo, aContab, cECFAlias )

				EndIf
			EndIf

			//Caso seja encontrado algum erro durante o processamento aborto a execução
			If !Empty( cErrorTrd )
				Exit
			EndIf

		Next nI

	else

		oSay:cCaption := "Cancelando a geração do arquivo..." 
		ProcessMessages()

	EndIf

endif

//Verifico se não ocorreu erro na inicialização das Threads
If Empty( cErrorTrd )

	//Quando o processamento se realizar em Multi Thread eu realizo a verificação do status de processamento da geração do bloco
	If lMultThread
	
		nProgress1 := nProgress1 - 2

		While .T.

			//Neste laço eu verifico quais blocos já foram encerrados para atualizar a barra de processamento de geração do ECF
			For nI := 1 to Len( aJobAux )

				//Nome da variável global de gerenciamento das threads
				cJobAux := aJobAux[nI,1]
				cGLBVALUE := 	GetGlbValue( cJobAux )

				Do Case

					//Quando o status for igual a 1 significa que o bloco foi encerrado, sendo assim atribuo + 1 na barra de processamento
					Case cGLBVALUE == "1"

						//Atualizando a barra de processamento
						nProgress1 --
						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )

					//O Tipo 9 ocorre quando ocorre Error Log na execução do bloco
					Case cGLBVALUE == "9"

						nProgress1 --
						cErrorECF += "," + aJobAux[nI,2] + " "

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )
					OtherWise
						nProgress1 --
				EndCase

			Next

			//Quando a variável for menor que zero significa que todos os blocos foram encerrados
			If nProgress1 <= 0
				Exit
			EndIf

			//Aguarda 1 segundo antes de executar a próxima verificação
			Sleep( 1000 )
		EndDo

		//Encerrando as threads utilizadas no processamento
		xFinalThread( cSemaphore, nQtdThread )
	EndIf
Else

	//Encerrando as threads utilizadas no processamento
	xFinalThread( cSemaphore, nQtdThread )

EndIf

//Tratamento para quando o processamento tem problemas

If !lAuto .and. ( !lProc .or. !Empty( cErrorECF ) .or. !Empty( cErrorTrd ) )

	//Cancelado o processamento
	if !lProc

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )
	
	//Erro na inicialização das threads
	elseif !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorECF := "Ocorreu um erro fatal durante a geração do(s) Bloco(s) " + SubStr( cErrorECF, 2, Len( cErrorECF ) )
		cErrorECF += "do Sped ECF " + Chr( 10 ) + Chr( 10 )
		cErrorECF += "Favor reprocessar a geração deste(s) bloco(s), caso o erro persista entre em contato "
		cErrorECF += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorECF, { "Sair" } )

	EndIf

Else

	//Tratamento para exibir mensagem no console quando processamento multi thread
	If lMultThread
		TAFConout( "*** Realizando geração do arquivo magnético ***",1,.T.,"ECF" )
	EndIf

	if !lAuto
		oSay:cCaption := "Consolidando as informações e gerando arquivo..."
		ProcessMessages()
	endif	

	If lProc .and. GerTxtECF( oSay, cECFAlias, cCTLAlias, aWizard, cFilSel, lAuto )
		if !lAuto; MsgAlert( "Arquivo Gerado com Sucesso!" ); endif
	EndIf

EndIf


//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtECF

Geracao do Arquivo Magnetico do ECF no diretorio selecionado.

@Param oProcess  -> Objeto da barra de progresso da emissao do ECF
       cECFAlias -> Alias da tabela de informacoes geradas pelo ECF
       cCTLAlias -> Alias da tabela de controle de transacoes
       aWizard   -> Array com as informacoes da Wizard
       cFilSel   -> Filiais selecionadas para o processamento

@Return ( Nil )

@Author Felipe C. Seolin
@Since 10/07/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtECF( oSay, cECFAlias, cCTLAlias, aWizard, cFilSel, lAuto )

Local cAliasECF  := GetNextAlias()
Local cAliasCONT := GetNextAlias()
Local cAlias9900 := GetNextAlias()
Local cFil       := TurnFilObr( cFilSel )
Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""
Local cGroupBy   := ""
Local cOrderBy   := ""
Local cBloco     := "0"
Local cDelimit   := "|"
Local cStrTxt    := ""
Local cDir       := ""
Local cFileDest  := ""
Local cTxtSys    := CriaTrab( , .F. ) + ".TXT"
Local nHandle    := MsFCreate( cTxtSys )
Local nErro      := 0
Local nQtd990    := 0
Local nQtd9990   := 0
Local nQtd9999   := 0
Local lErro      := .F.
Local lRet       := .T.

//Carrego as variáveis com as informações passadas na wizard
cDir := AllTrim( aWizard[1,3] )

//Tratamento para Linux onde a barra é invertida
If GetRemoteType() == 2
	If !Empty( cDir ) .and. ( SubStr( cDir, Len( cDir ), 1 ) <> "/" )
		cDir += "/"
	EndIf
Else
	If !Empty( cDir ) .and. ( SubStr( cDir, Len( cDir ), 1 ) <> "\" )
		cDir += "\"
	EndIf
EndIf

//Monto nome do arquivo que será gerado
cFileDest := AllTrim( cDir ) + AllTrim( aWizard[1,4] )

If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
	cFileDest := cFileDest + ".TXT"
EndIf

//Executa o contador de registros a serem gerados no arquivo magnético
cSelect := "COUNT( * ) COUNT "

cFrom := cTABECF + " "

cWhere := "    FILIAL = '" + cFil + "' "
cWhere += "AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasCONT
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
EndSql

if !lAuto
	oSay:cCaption := 'Aguarde... Gerando arquivo...'
	ProcessMessages()
endif

//Executa a geração do arquivo magnético
cSelect := "R_E_C_N_O_ "

cFrom := cTABECF + " "

cWhere := "    FILIAL = '" + cFil + "' "
cWhere += "AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
cWhere += "AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "

cOrderBy := "BLOCO, REGSEQ "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"
cOrderBy := "%" + cOrderBy + "%"

BeginSql Alias cAliasECF
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
	ORDER BY
		%Exp:cOrderBy%
EndSql

( cECFAlias )->( DBGoTo( ( cAliasECF )->R_E_C_N_O_ ) )

While ( cAliasECF )->( !Eof() ) .and. !lErro


	nErro := WrtStrTxt( nHandle, ( cECFAlias )->LINREG + CRLF )

	If nErro < 0
		lErro := .T.
		xTAFMsgJob( "Problema ao gravar arquivo. Erro: " + Str( FError(), 4 ) )
	EndIf

	nQtd990 ++
	nQtd9999 ++

	( cAliasECF )->( DBSkip() )

	( cECFAlias )->( DBGoTo( ( cAliasECF )->R_E_C_N_O_ ) )

	//Geração do registro 990 de cada Bloco
	If cBloco <> ( cECFAlias )->BLOCO

		nQtd990 ++
		nQtd9999 ++

		cStrTxt := cDelimit + cBloco + "990"					//01 - REG
		cStrTxt += cDelimit + AllTrim( Str( nQtd990 ) )		//02 - QTD_LIN
		cStrTxt += cDelimit

		nErro := WrtStrTxt( nHandle, cStrTxt + CRLF )

		If nErro < 0
			lErro := .T.
			xTAFMsgJob( "Problema ao gravar arquivo. Erro: " + Str( FError(), 4 ) )
		EndIf

		cBloco := ( cECFAlias )->BLOCO
		nQtd990 := 0

	EndIf

EndDo

//Bloco 9
If !lErro

	//Registro 9001
	cStrTxt := cDelimit + "9001"	//01 - REG
	cStrTxt += cDelimit + "0"		//02 - IND_DAD
	cStrTxt += cDelimit

	nQtd9990 ++

	//Registro 9900
	cSelect := "BLOCO, REGISTRO, COUNT( REGISTRO ) QTD "

	cFrom := cTABECF + " "

	cWhere := "    FILIAL = '" + cFil + "' "
	cWhere += "AND PERINI = '" + DToS( aWizard[1,1] ) + "' "
	cWhere += "AND PERFIN = '" + DToS( aWizard[1,2] ) + "' "

	cGroupBy := "BLOCO, REGISTRO "

	cOrderBy := "REGISTRO "

	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"
	cGroupBy := "%" + cGroupBy + "%"
	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAlias9900
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%EXP:cWhere%
		GROUP BY
			%Exp:cGroupBy%
		ORDER BY
			%Exp:cOrderBy%
	EndSql

	cBloco := ( cAlias9900 )->BLOCO

	While ( cAlias9900 )->( !Eof() )

		If cBloco <> ( cAlias9900 )->BLOCO
			cStrTxt += CRLF
			cStrTxt += cDelimit + "9900"			//01 - REG
			cStrTxt += cDelimit + cBloco + "990"	//02 - REG_BLC
			cStrTxt += cDelimit + "1"				//03 - QTD_REG_BLC
			cStrTxt += cDelimit						//04 - VERSAO
			cStrTxt += cDelimit						//05 - ID_TAB_DIN
			cStrTxt += cDelimit

			nQtd9990 ++

			cBloco := ( cAlias9900 )->BLOCO
		EndIf

		cStrTxt += CRLF
		cStrTxt += cDelimit + "9900"									//01 - REG
		cStrTxt += cDelimit + ( cAlias9900 )->REGISTRO					//02 - REG_BLC
		cStrTxt += cDelimit + AllTrim( Str( ( cAlias9900 )->QTD ) )	//03 - QTD_REG_BLC
		cStrTxt += cDelimit												//04 - VERSAO
		cStrTxt += cDelimit												//05 - ID_TAB_DIN
		cStrTxt += cDelimit

		nQtd9990 ++

		( cAlias9900 )->( DBSkip() )

		//Utilizado para o último registro 990
		If ( cAlias9900 )->( Eof() )
			cStrTxt += CRLF
			cStrTxt += cDelimit + "9900"			//01 - REG
			cStrTxt += cDelimit + cBloco + "990"	//02 - REG_BLC
			cStrTxt += cDelimit + "1"				//03 - QTD_REG_BLC
			cStrTxt += cDelimit						//04 - VERSAO
			cStrTxt += cDelimit						//05 - ID_TAB_DIN
			cStrTxt += cDelimit

			nQtd9990 ++
		EndIf

	EndDo

	( cAlias9900 )->( DBCloseArea() )

	nQtd9990 += 2

	//Registro 9990
	cStrTxt += CRLF
	cStrTxt += cDelimit + "9990"						//01 - REG
	cStrTxt += cDelimit + AllTrim( Str( nQtd9990 ) )	//02 - QTD_LIN
	cStrTxt += cDelimit

	nQtd9999 += nQtd9990

	//Registro 9999
	cStrTxt += CRLF
	cStrTxt += cDelimit + "9999"						//01 - REG
	cStrTxt += cDelimit + AllTrim( Str( nQtd9999 ) )	//02 - QTD_LIN
	cStrTxt += cDelimit

	nErro := WrtStrTxt( nHandle, cStrTxt + CRLF )

	If nErro < 0
		lErro := .T.
		xTAFMsgJob( "Problema ao gravar arquivo. Erro: " + Str( FError(), 4 ) )
	EndIf

EndIf

If lErro
	lRet := .F.
Else
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )
EndIf

( cAliasECF )->( DBCloseArea() )
( cAliasCONT )->( DBCloseArea() )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetContab

Tela de seleção de contabilistas.

@Param cFilSel - Filiais selecionadas para o processamento

@Return aLista - Vetor de contabilistas selecionados

@Author Felipe C. Seolin
@Since 05/12/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FGetContab( cFilSel, cVersion, lAuto )

Local oDialog		:=	Nil
Local oCheckBox		:=	Nil	
Local oListBox		:=	Nil
Local oOk			:= LoadBitmap( GetResources(), "LBOK" )
Local oNo			:= LoadBitmap( GetResources(), "LBNO" )
Local nI			:= 0
Local nPos			:= 0
Local aLista		:= Nil
Local aListBox		:=	{}
Default cVersion	:= "" 
Default lAuto		:= .f.	

aLista := FQryContab( cFilSel, lAuto )

If !lAuto .and. !Empty( aLista )

	For nI := 1 to Len( aLista )
		aAdd( aListBox, { aLista[nI,1], aLista[nI,2], aLista[nI,3], aLista[nI,4], aLista[nI,5], aLista[nI,7] } )
	Next nI

	Define MsDialog oDialog Title "Tela de Seleção" STYLE DS_MODALFRAME From 145,0 to 445,628 Of oMainWnd Pixel

		oDialog:lEscClose := .F.

		@05,15 to 125,300 Label "Marque os contabilistas a serem considerados no processamento" Of oDialog  Pixel

		@15,20 CheckBox oCheckBox Prompt "Inverte Seleção" Size 50,10 Of oDialog Pixel On Click( aEval( aListBox, { |x| x[1] := Iif( x[1] == .T., .F., .T. ) } ), oListBox:Refresh( .F. ) )

		@30,20 ListBox oListBox Fields Header "", "Filial", "Nome", "Cód Qualificação", "Qualificação", "CPF/CNPJ" Size 273,090 On DblClick( aListBox := xFunFClTroca( oListBox:nAt, aListBox,nil,cVersion ), oListBox:Refresh() ) NoScroll Of oDialog Pixel
			oListBox:SetArray( aListBox )
			oListBox:bLine := { || { Iif( aListBox[oListBox:nAt,1], oOk, oNo ), aListBox[oListBox:nAt,2], aListBox[oListBox:nAt,3], aListBox[oListBox:nAt,4], aListBox[oListBox:nAt,5], aListBox[oListBox:nAt,6] } }

		Define sButton From 134,270 Type 1 Action oDialog:End() Enable Of oDialog

	Activate MsDialog oDialog Centered

	For nI := 1 to Len( aListBox )
		nPos := aScan( aLista, { |x| AllTrim(x[7]+x[4]) == AllTrim(aListBox[nI,6]+aListBox[nI,4]) } )
		if nPos > 0
			aLista[nPos,1] := aListBox[nI,1]
		endif
	Next nI

EndIf

Return( aLista )

//-------------------------------------------------------------------
/*/{Protheus.doc} FQryContab

Query com seleção de contabilistas.

@Param cFilSel - Filiais selecionadas para o processamento

@Return aLista - Lista de contabilistas elegíveis para seleção

@Author Felipe C. Seolin
@Since 05/12/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FQryContab( cFilSel, lAuto )

Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cOrderBy	:=	""
Local cAliasQry	:=	GetNextAlias()
Local aLista		:=	{}
Local cCPFCNPJ	:= ""
Default lAuto := .f.

cSelect := "C2J.C2J_FILIAL, C2J.C2J_NOME, C2J.C2J_TPESTA, C2J.C2J_CPF , C2J.C2J_CNPJ ,"
cSelect += "CW4.CW4_CODIGO, CW4.CW4_DESCRI, C2J.R_E_C_N_O_ RECNO "

cFrom := RetSqlName( "C2J" ) + " C2J "

cFrom += "LEFT JOIN " + RetSqlName( "CW4" ) + " CW4 "
cFrom += "  ON CW4.CW4_FILIAL = '" + xFilial( "CW4" ) + "' "
cFrom += " AND CW4.CW4_ID = C2J.C2J_IDCODQ "
cFrom += " AND CW4.D_E_L_E_T_ = '' "

//cWhere += "    C2J_FILIAL IN (" + cFilSel + ") "
cWhere += "    C2J_FILIAL = '" + xFilial( "C2J" ) + "' "
cWhere += "AND C2J.D_E_L_E_T_ = ''

cOrderBy := "C2J.C2J_FILIAL, C2J.C2J_NOME "

cSelect  := "%" + cSelect   + "%"
cFrom    := "%" + cFrom     + "%"
cWhere   := "%" + cWhere    + "%"
cOrderBy := "%" + cOrderBy  + "%"

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

While ( cAliasQry )->( !Eof() )
	cCPFCNPJ := IIf((cAliasQry)->C2J_TPESTA == "1",(cAliasQry)->C2J_CPF,(cAliasQry)->C2J_CNPJ)
	aAdd( aLista, { lAuto, ( cAliasQry )->C2J_FILIAL, ( cAliasQry )->C2J_NOME, ( cAliasQry )->CW4_CODIGO, ( cAliasQry )->CW4_DESCRI, ( cAliasQry )->RECNO, cCPFCNPJ } )
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return( aLista )

//-------------------------------------------------------------------
/*/{Protheus.doc} FExecSQL

Executa a inserção de informações na tabela auxiliar de geração da
obrigação acessória.

@Param	aECFInfo	-	Informações gerais para tabela de controle de transações
		nSeq		-	Seqüência de gravação do Bloco
		cReg		-	Registro da obrigação acessória
		cStrTxt	-	Linha do arquivo texto

@Return

@Author Felipe C. Seolin
@Since 08/08/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FExecSQL( aECFInfo, nSeq, cReg, cStrTxt )

Local cInsert	:= "INSERT INTO " + cTABECF + " ( FILIAL, PERINI, PERFIN, BLOCO, REGSEQ, REGISTRO, LINREG ) VALUES "
Local cValues	:=	""
Local cBanco	:=	Upper( AllTrim( TcGetDB() ) )

//Tratamento para adicionar o Pipe ( '|' ) ao final da string de linha do texto
//pois o comando TCSQLExec está inserindo informações sem o último caracter em ORACLE
If cBanco == "ORACLE"
	cStrTxt += "|"
EndIf

cValues := "( '" + aECFInfo[1] + "', '" + aECFInfo[2] + "', '" + aECFInfo[3] + "', '" + aECFInfo[4] + "', '" + StrZero( nSeq, 10 ) + "', '" + cReg + "', '" + cStrTxt + "' ) "


If cBanco == 'INFORMIX' 

	if select(cTABECF) <= 0
		Use &(cTABECF) Alias &(cTABECF) SHARED NEW Via __CRDD
	endif
	if Reclock( cTABECF , .T. )
		(cTABECF)->FILIAL 	:= aECFInfo[1]
		(cTABECF)->PERINI	:= STOD(aECFInfo[2])
		(cTABECF)->PERFIN	:= STOD(aECFInfo[3])
		(cTABECF)->BLOCO	:= aECFInfo[4]
		(cTABECF)->REGSEQ	:= StrZero( nSeq, 10 )
		(cTABECF)->REGISTRO	:= cReg
		(cTABECF)->LINREG	:= cStrTxt
		(cTABECF)->(MsUnlock())
	endif

else
	If TCSQLExec( cInsert + cValues ) < 0 
		TAFConOut( "ECF - Erro na instrução - " + cInsert + cValues,3,.T.,"ECF" )
		TAFConOut( "ECF - TCSQLError() - " + TCSQLError(),3,.T.,"ECF" )
	EndIf
endif


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConvPais

@Author Luccas Curcio
@Since	24/09/2015
@Version 1.0

/*/
//-------------------------------------------------------------------
function TAFConvPais( cCod )

local	cRet	:=	''

cRet	:=	TAFConType( str( val ( cCod ) ) )

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Construção dos painéis para geração do arquivo.

@Return	aRet	-	Parametrização necessária para a rotina xFunWizard

@Author	Felipe C. Seolin
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

Local cNomWiz		:=	cObrig + FwGetCodFilial
Local cNomeAnt	:=	" "
Local cTitObj1	:=	""
Local cTitObj2	:=	""
Local nTamPer		:=	TamSX3( "CHD_ID" )[1]
Local nPos			:=	0
Local aTxtApre	:=	{}
Local aPaineis	:=	{}
Local aItens1		:=	{}
Local aRet			:=	{}
Local lWebApp		:= GetRemoteType() = 5
Local lWhen			:= !lWebApp //Se for WebApp, nao passa pelo campo.

aAdd( aTxtApre, "Parâmetros necessários." )
aAdd( aTxtApre, "" )	
aAdd( aTxtApre, "Preencha corretamente as informações solicitadas." )
aAdd( aTxtApre, "Informações necessárias para a geração do meio-magnético ECF." )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 0     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], "Preencha corretamente as informações solicitadas." )
aAdd( aPaineis[nPos], "Parâmetros para Geração" )
aAdd( aPaineis[nPos], {} )

//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1 := "Identificador Período"
cTitObj2 := "Período"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

cTitObj1 := Replicate( "X", nTamPer )
cTitObj2 := Replicate( "X", nTamPer )

aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, nTamPer,,, "CHD", { "xValWizCmp", 2, { "CHD", "1" } }, { "xFunVldWiz", "ECF-PERIODO" } } )
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, nTamPer, { .T., "" } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1 := "Diretório do Arquivo Destino"
cTitObj2 := "Nome do Arquivo Destino"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

cTitObj1 := Replicate( "X", 50 )
cTitObj2 := Replicate( "X", 20 )

if lWebApp
	//Se for WebApp, cria o campo "Diretório" desabilitado.
	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,,,,,,,,,,,,,lWhen} )
else
	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,, { "xValWizCmp", 3, { "", "" } }, { "xFunVldWiz", "ECF-DIRETORIO" } } )
endif
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,, { "xValWizCmp", 4, { "", "" } } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1 := "Versão"
cTitObj2 := ""

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

cTitObj1 := Replicate( "X", 4 )

aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 4,,,"CZV", { "xValWizCmp", 5, { "CZV", "2" } }, { "xFunVldWiz", "ECF-VERSAO" } } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------------------------------------------------------------------//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                     PAINEL 1     															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], "Preencha corretamente as informações solicitadas." )
aAdd( aPaineis[nPos], "Tipo de Arquivo" )
aAdd( aPaineis[nPos], {} )

//--------------------------------------------------------------------------------------------------------------------------------------------------//
cTitObj1 := "Escrituração Retificadora?"
cTitObj2 := "Número do Recibo da ECF Anterior"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

aItens1 := {}
aAdd( aItens1, "S-ECF retificadora" )
aAdd( aItens1, "N-ECF original" )
aAdd( aItens1, "F–ECF original mudança forma tributação" )

cTitObj2 := Replicate( "X", 41 )

aAdd( aPaineis[nPos,3], { 3,,,,, aItens1,,} )
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 41,,,, { "xValWizCmp", 6, { "", "" } }, { "xFunVldWiz", "ECF-RECIBO" } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------------------------------------------------------------------//

aAdd( aRet, aTxtApre )
aAdd( aRet, aPaineis )
aAdd( aRet, cNomWiz )
aAdd( aRet, cNomeAnt )
aAdd( aRet, Nil )
aAdd( aRet, Nil )
aAdd( aRet, { || TAFXECF() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFECFVer

Valida se existem os campos criados para versão especifica do ECF
@param cVersao, caracter, versão da ECF Ex: 0001,0007
@Return	lRet	-	Retorna .T. se existirem os campos necessários para a versão criados no ambiente

@Author	Karen Honda
@Since		21/09/2021
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFECFVer(cVersao)
Local lRet as Logical

Default cVersao := "0001"
lRet := .T.
If cVersao == "0007"
	lRet := TAFColumnPos("CFK_INDCON") .and. TAFColumnPos("CFK_NCMINC") .and. TAFColumnPos("CFK_CNPJIN") .and. TAFColumnPos("CFK_RECINC"); //X280
	  .and. TAFColumnPos("CAY_TPOPER") .and. TAFColumnPos("CAY_IDFCOT") .and. TAFColumnPos("CAY_DESCPA") .and. TAFColumnPos("CAY_IDPAEN"); //X300
	  .and. TAFColumnPos("CFV_UTINPR") .and. TafColumnPos("CFV_IDFOCO") .and. TafColumnPos("CFV_TPPAR")  .and. TAFColumnPos("CFV_AJUPAR")  //X320
EndIf

Return lRet
