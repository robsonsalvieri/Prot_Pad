#Include 'Protheus.ch'
#Define cObrig "GIM-RN"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGIRN

Esta rotina tem como objetivo a geracao do Arquivo GIM - RN

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGIM()
Local cNomWiz    := cObrig + FWGETCODFILIAL
Local lEnd       := .F.

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess := Nil

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//Cria objeto de controle do processamento
oProcess := TAFProgress():New( { |lEnd| ProcGIMRN( @lEnd, @oProcess, cNomWiz ) }, "Processando GIM - RN" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcGIMRN

Inicia o processamento para geracao da GIM - RN


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
	   oProcess  -> Objeto da barra de progresso da emissao da GIM-RN
	   cNomWiz   -> Nome da Wizard criada para a GIM


@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
*/

Static Function ProcGIMRN( lEnd, oProcess, cNomWiz )

Local cSemaphore	:=	""
Local cJobAux		:=	""
Local cErrorGIM	:=	""
Local cErrorTrd	:=	""

Local nI			:=	0
Local nX			:= 	0
Local nProgress1	:=	0
Local nTryExec	:=	0

Local aWizard		:=	{}
Local aJobAux		:=	{}
Local aRegGim		:=	{}

//Variáveis de Thread
Local lMultThread	:=	.F.
Local nQtdThread	:=	0
Local lProc		:=	.T.



//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

If lProc

	//Alimentando o array com os registros que devem ser processados juntamente com seus respectivos filhos
	aRegGim := xTafGetObr( cObrig ) //- Original como deve ser feito


	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 11
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress( "Preparando o Ambiente..." )

	For nX:=1 to Len(aRegGim)
		cFunction := aRegGim[nX,2]

	//Processamento Multi Thread
		If lMultThread

			//Inicializa variavel global de controle das Threads
			cJobAux := StrTran( "cGIM_" + FwGrpCompany() + FwCodFil(), ' ', '_' ) + StrZero( nX , 2 )

			//Seto o Status da Variavel como "0", ou seja, pendente de processamento
			PutGlbValue( cJobAux, "0" )
			GlbUnlock()

			//Adiciona o nome do arquivo de Job no array aJobAux
			aAdd( aJobAux, { cJobAux, aRegGim[nX,3] } )

			//Variavel de controle de Start das Execuções
			nTryExec := 0

			While .T.
				If IPCGo( cSemaphore, cObrig, cFunction, aWizard, SM0->M0_CODIGO, cJobAux )
					Exit
				Else
					nTryExec ++
					Sleep( 1000 )
				EndIf

				//Caso ocorra erro em 10 tentativas de iniciar a Thread aborta informando ao usuário o erro
				If nTryExec > 6
					cErrorTrd := "Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo. Caso o erro persista entre em contato com o administrador do sistema"
					Exit
				EndIf
			EndDo
		Else //Processamento Mono Thread
			oProcess:Inc1Progress( "Executando o Processamento..."	)
			&cFunction.(aWizard, cJobAux)
		EndIf
		//Caso seja encontrado algum erro durante o processamento aborto a execução
		If !Empty( Alltrim(cErrorTrd) )
			Exit
		EndIf
	Next nX
Else
	oProcess:Inc1Progress( "Processamento cancelado" )
	oProcess:Inc2Progress( "Clique em Finalizar" )
	oProcess:nCancel = 1
EndIf


//Verifico se não ocorreu erro na inicialização das Threads
If Empty( cErrorTrd )

	//Quando o processamento se realizar em Multi Thread eu realizo a verificação do status de processamento da geração do bloco
	If lMultThread

		While .T.

			//Neste laço eu verifico quais blocos já foram encerrados para atualizar a barra de processamento de geração do ECF
			For nI := 1 to Len( aJobAux )

				//Nome da variável global de gerenciamento das threads
				cJobAux := aJobAux[nI,1]

				Do Case

					//Quando o status for igual a 1 significa que o bloco foi encerrado, sendo assim atribuo + 1 na barra de processamento
					Case GetGlbValue( cJobAux ) == "1"

						//Atualizando a barra de processamento
						nProgress1 --
						oProcess:Inc1Progress( "Encerrando o Registro..." + aJobAux[nI,2] )

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )

					//O Tipo 9 ocorre quando ocorre Error Log na execução do bloco
					Case GetGlbValue( cJobAux ) == "9"

						nProgress1 --
						cErrorGIM += "," + aJobAux[nI,2] + " "

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )
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
If oProcess:nCancel == 1 .or. !Empty( cErrorGIM ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorGIM := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorGIM, 2, Len( cErrorGIM ) )
		cErrorGIM += "da GIM-RN " + Chr( 10 ) + Chr( 10 )
		cErrorGIM += "Favor efetuar o reprocessamento da GIM-RN, caso o erro persista entre em contato "
		cErrorGIM += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorGIM, { "Sair" } )

	EndIf

Else

	//Atualizando a barra de processamento
	oProcess:Inc1Progress( "Informações processadas" )
	oProcess:Inc2Progress( "Consolidando as informações e gerando arquivo..." )


	If GerTxtCons( aWizard )
		//Atualizando a barra de processamento
		oProcess:Inc2Progress( "Arquivo gerado com sucesso." )
		msginfo("Arquivo gerado com sucesso!")
	Else
		oProcess:Inc2Progress( "Falha na geração do arquivo." )
	EndIf


EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@author Jean Battista Grahl Espindola
@since	27/08/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens1	:= {}

	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}

   	aAdd (aItens1, "0 - Não")
   	aAdd (aItens1, "1 - Sim")

	aAdd (aTxtApre, "Processando Empresa.")
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
	aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético GIM-RN.")

	//============= Painel 0 ==============

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIM-RN.")
	aAdd (aPaineis[nPos], {})

	//Coluna1																//Coluna 2
	cTitObj1	:=	"Diretório do Arquivo Destino:";					cTitObj2	:=	"Mês/Ano Referência:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 100);					    		cTitObj2	:=	"99/9999"
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                      	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	//PAINEL 1
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético GIM-RN")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//Coluna1																//Coluna 2
	cTitObj1	:=	"Observação:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	Replicate ("X", 30)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,30});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                      	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	"Observação:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	Replicate ("X", 30)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,30});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});                      	aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	"Observação:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	Replicate ("X", 30)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,30});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXGIM() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGIM

Geracao do Arquivo TXT da GIM-RN.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo GIM
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtGIM( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "GIMRN" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, "Não foi possível criar o diretório \Obrigacoes_TAF\GIMRN. Erro: " + cValToChar( FError() ) , 1, 0 )

		lRet	:=	.F.

	endIf

endIf

if lRet

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "/" )
			cDirName += "/"
		EndIf
	Else
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "\" )
			cDirName += "\"
		EndIf
	EndIf

	//Monto nome do arquivo que será gerado
	cFileDest := AllTrim( cDirName ) + cReg

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".txt"
		cFileDest := cFileDest + ".txt"
	EndIf

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da GIM RN. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author Jean Battista Grahl Espindola
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 						//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	AllTrim(TAFGetPath( "2" , "GIMRN" ))		              //diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".gim"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""
Local cData 		:= AllTrim(StrTran(aWizard[1][2], "/","")) + "AA"

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
			cFileDest += Alltrim(cData) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" )
			cFileDest += Alltrim(cData) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
			cFileDest += Alltrim(cData) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" )
			cFileDest += Alltrim(cData) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := GIMFilesTxt(cPathTxt)
	for nx := 1 to Len( aFiles )

		//Verifica se o arquivo foi encontrado no diretorio
		if File( aFiles[nx][1] )

			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()				//POSICIONO NO TOPO

			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
	 			cStrTxtFIM += cBuffer + CRLF
				FT_FSKIP()
			endDo
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".gim"
		cFileDest := AllTrim(cFileDest) + ".gim"
	EndIf

	WrtStrTxt( nHandle, cStrTxtFIM )

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

Return( lRet )

// ----------------------------
static function GIMFilesTxt(cPathTxt)

	Local aRet	:=	{}

	AADD(aRet,{cPathTxt+"01.TXT"})
	AADD(aRet,{cPathTxt+"02.TXT"})
	AADD(aRet,{cPathTxt+"03.TXT"})
	AADD(aRet,{cPathTxt+"04.TXT"})
	AADD(aRet,{cPathTxt+"05.TXT"})
	AADD(aRet,{cPathTxt+"06.TXT"})
	AADD(aRet,{cPathTxt+"07.TXT"})
	AADD(aRet,{cPathTxt+"08.TXT"})
	AADD(aRet,{cPathTxt+"09.TXT"})
	AADD(aRet,{cPathTxt+"10.TXT"})
	AADD(aRet,{cPathTxt+"11.TXT"})
	AADD(aRet,{cPathTxt+"99.TXT"})

return( aRet )
