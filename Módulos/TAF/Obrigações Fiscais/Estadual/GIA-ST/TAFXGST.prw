#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "Tafxgst.ch"
#Define cObrig "GIA-ST"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGST

Esta rotina tem como objetivo a geracao do Arquivo GIA-ST

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGST()
Local cNomWiz    := cObrig + FWGETCODFILIAL
Local lEnd       := .F.
Local cFunction	 := ProcName()
Local nOpc     	 := 2 //View

Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess := Nil
Private aWizard	:= {}

	//Função para gravar o uso de rotinas e enviar ao LS (License Server)
	Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

	//Protect Data / Log de acesso / Central de Obrigacoes
	Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

   	//Cria objeto de controle do processamento
   	oProcess := TAFProgress():New( { |lEnd| ProcGIAST( @lEnd, @oProcess, cNomWiz ) }, STR0001 )
   	oProcess:Activate()

   	//Limpando a memória
   	DelClassIntf()

Return()

//--------------------------------------------------------------------------
/*/{Protheus.doc} ProcGIAST

Inicia o processamento para geracao da GIA-ST


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
		oProcess  -> Objeto da barra de progresso da emissao da GIA-ST
		cNomWiz   -> Nome da Wizard criada para a GIA


@Return ( Nil )

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------


Static Function ProcGIAST( lEnd, oProcess, cNomWiz )

Local cErrorGIA	 	as char
Local cErrorTrd	 	as char
Local cCodigo  		as Char
Local cNome			as Char
Local cCodMun  		as Char
Local cCNAE    		as Char
Local cInscEst 		as Char
Local cUF     		as Char
Local cUFID 		as Char

Local nI			as Numeric
Local nX			as Numeric
Local nPos			as Numeric
Local aJobAux		as Array
Local aFiliais		as Array
Local cFunction     as char
Local nQtdReg       as numeric

Local lProc			as Logical

//Variáveis de Thread
Local cSemaphore	as Char
Local cJobAux    	as Char
Local nQtdThread	as Numeric
Local lMultThread	as Logical
Local aRegGIAST  	as array
Local nTryExec   	as numeric

Private aFil := {}

//**********************
// INICIALIZA VARIÁVEIS
//**********************

cErrorGIA	:= ""
cErrorTrd	:= ""
cCodigo  	:= ""
cNome		:= ""
cCodMun  	:= ""
cCNAE    	:= ""
cInscEst 	:= ""
cUF     	:= ""
cUFID 		:= ""
cFunction 	:= ""

nI			:= 0
nX			:= 0
nPos		:= 0
nTryExec    := 0
nQtdReg     := 4
aJobAux		:= {}
aFiliais	:= {}
aFil		:= {}
aRegGIAST   := {}

lProc		:= .T.

//Variáveis de Thread
cJobAux    	:= ""
cSemaphore	:= ""
nQtdThread	:= 0
lMultThread	:= .F.

//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

DBSELECTAREA("C09")
C09->(DBSETORDER(1))
//Verificação das filiais selecionadas para processamento da operação
If "1" $ aWizard[2,5]
  	aFiliais := xFunTelaFil( .T. )
	If Empty( aFiliais )
		lProc := .F.
	Else
		If Len( aFiliais ) > 0
          For nI := 1 to Len( aFiliais )
				If aFiliais[nI][1]
					cCodigo := aFiliais[nI][2]
					cNome	:= Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_FILIAL")
					cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CODMUN")
					cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CNAE")
					cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_INSC")
					cUF     := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_ESTCOB")
					cTel    := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_TEL")
					cCgc    := Posicione('SM0',1,SM0->M0_CODIGO + aFiliais[nI][2],"M0_CGC")
										
					If (DBSEEK(xFilial("C09")+cUF))
						cUFID := C09->C09_ID
					Endif

					AADD(aFil,{cCodigo, cNome, cCodMun, cCNAE, cInscEst,cUF, cUFID, cTel, cCgc})
				Endif
			Next
		EndIf
	EndIf
Else
	cNome	:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_FILIAL")
	cCodMun := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CODMUN")
	cCNAE   := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CNAE")
	cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")
	cUF     := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_ESTCOB")
	cTel    := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_TEL")
	cCgc    := Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_CGC")
	
	If (DBSEEK(xFilial("C09")+cUF))
		cUFID := C09->C09_ID
	Endif

	AADD(aFil,{cFilAnt, cNome, cCodMun, cCNAE, cInscEst, cUF, cUFID, cTel, cCgc})
EndIf

If lProc

	
	//Alimentando o array com os registros que devem ser processados juntamente com seus respectivos filhos
	aRegGIAST := xTafGetObr( cObrig ) //- Original como deve ser feito

	//Alimentando a variável de controle da barra de status do processamento
	oProcess:Set1Progress( 4 )	
    IIF(lMultThread, oProcess:Set2Progress( 7 ), oProcess:Set2Progress( 3 ))
    
	//Iniciando o Processamento
	oProcess:Inc1Progress( STR0002 ) //"Processando..."	
	oProcess:Inc2Progress( STR0003 ) //"Buscando informações..."
	
	For nI := 1 To Len(aFil)
        //Geração GIA-ST       
        
        ClearGlbValue( "nQtdAnxI_"+aFil[nI][1] )
        ClearGlbValue( "nQtdAnxII_"+aFil[nI][1] )
        ClearGlbValue( "nQtdAnxIII_"+aFil[nI][1] )
        
        For nX:=1 to Len(aRegGIAST)
			cFunction := aRegGIAST[nX,2]			
			
			//Processamento Multi Thread				
			If lMultThread 
			
				//Inicializa variavel global de controle das Threads
				cJobAux := StrTran( "cGIAST_" + FwGrpCompany() + aFil[nI][1], ' ', '_' ) + StrZero( nX , 2 )

				//Seto o Status da Variavel como "0", ou seja, pendente de processamento
				PutGlbValue( cJobAux, "0" )
				GlbUnlock()

				//Adiciona o nome do arquivo de Job no array aJobAux
				aAdd( aJobAux, { cJobAux, aRegGIAST[nX,3] } )

				//Variavel de controle de Start das Execuções
				nTryExec := 0		
				
				While .T.
					If IPCGo( cSemaphore, cObrig, cFunction,aWizard, aFil[nI], cJobAux )
						Exit
					Else
						nTryExec ++
						Sleep( 1000 )
					EndIf

					//Caso ocorra erro em 10 tentativas de iniciar a Thread aborta informando ao usuário o erro
					If nTryExec > 10
						cErrorTrd := STR0004 // Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo. Caso o erro persista entre em contato com o administrador do sistema
						Exit
					EndIf
				EndDo				
					
			Else //Processamento Mono Thread				
				&cFunction.(aWizard,aFil[nI], cJobAux)				
			EndIf			
			//Caso seja encontrado algum erro durante o processamento aborto a execução
			If !Empty( Alltrim(cErrorTrd) )
				Exit
			EndIf
		Next nX
	Next nI	
Else
	oProcess:Inc1Progress( STR0006 ) //Processamento cancelado
	oProcess:Inc2Progress( STR0007 ) //Clique em finalizar
	oProcess:nCancel = 1

EndIf

oProcess:Inc1Progress( STR0008 ) //Finalizando Processamento do Registros...

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
						nQtdReg --
						oProcess:Inc2Progress( STR0009 + " " + aJobAux[nI,2] + "..." ) //Encerrando ..

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )

					//O Tipo 9 ocorre quando ocorre Error Log na execução do bloco
					Case GetGlbValue( cJobAux ) == "9"

						nQtdReg --
						cErrorGIA += "," + aJobAux[nI,2] + " "

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )
				EndCase

			Next

			//Quando a variável for menor que zero significa que todos os blocos foram encerrados
			If nQtdReg <= 0
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

oProcess:Inc1Progress( STR0010 )
oProcess:Inc2Progress( STR0009 + " Anexo Principal" )

 //Zerando os arrays utilizados durante o processamento
 aSize( aJobAux, 0 )

 //Zerando as Variaveis utilizadas
 aJobAux := {}

 cFunction := "TAFGSTA0"
 xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )
 
 For nX := 1 To Len(aFil) 	
     
     //Processamento Multi Thread				
	If lMultThread 
	
		//Inicializa variavel global de controle das Threads
		cJobAux := StrTran( "cGIAST_" + FwGrpCompany() + aFil[nX][1], ' ', '_' ) + StrZero( nX , 2 )

		//Seto o Status da Variavel como "0", ou seja, pendente de processamento
		PutGlbValue( cJobAux, "0" )
		GlbUnlock()

		//Adiciona o nome do arquivo de Job no array aJobAux
		aAdd( aJobAux, { cJobAux, "Resgistro Principal" } )

		//Variavel de controle de Start das Execuções
		nTryExec := 0		
		
		While .T.
			If IPCGo( cSemaphore, cObrig, cFunction,aWizard, aFil[nX], cJobAux )
				Exit
			Else
				nTryExec ++
				Sleep( 1000 )
			EndIf

			//Caso ocorra erro em 10 tentativas de iniciar a Thread aborta informando ao usuário o erro
			If nTryExec > 10
				cErrorTrd := STR0004 // Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo. Caso o erro persista entre em contato com o administrador do sistema
				Exit
			EndIf
		EndDo				
			
	Else //Processamento Mono Thread				
		TAFGSTA0 (aWizard, aFil[nX], cJobAux)						
	EndIf			
	//Caso seja encontrado algum erro durante o processamento aborto a execução
	If !Empty( Alltrim(cErrorTrd) )
		Exit
	EndIf
	
	ClearGlbValue( "nQtdAnxI_"+aFil[nX,1])
    ClearGlbValue( "nQtdAnxII_"+aFil[nX,1] )
    ClearGlbValue( "nQtdAnxIII_"+aFil[nX,1])
 Next nX
 
 //Verifico se não ocorreu erro na inicialização das Threads
If Empty( cErrorTrd )

	//Quando o processamento se realizar em Multi Thread eu realizo a verificação do status de processamento da geração do bloco
	If lMultThread

		While .T.

			//Neste laço eu verifico quais blocos já foram encerrados para atualizar a barra de processamento de geração do ECF
			For nX := 1 to Len( aJobAux )

				//Nome da variável global de gerenciamento das threads
				cJobAux := aJobAux[nX,1]

				Do Case

					//Quando o status for igual a 1 significa que o bloco foi encerrado, sendo assim atribuo + 1 na barra de processamento
					Case GetGlbValue( cJobAux ) == "1"

						//Atualizando a barra de processamento
						nQtdReg --
						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )

					//O Tipo 9 ocorre quando ocorre Error Log na execução do bloco
					Case GetGlbValue( cJobAux ) == "9"

						nQtdReg --
						cErrorGIA += "," + aJobAux[nX,2] + " "

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )
				EndCase

			Next

			//Quando a variável for menor que zero significa que todos os blocos foram encerrados
			If nQtdReg <= 0
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
If oProcess:nCancel == 1 .or. !Empty( cErrorGIA ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( STR0011, STR0012, { "Sair" } ) //A geração do arquivo foi cancelada com sucesso!

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( STR0011, cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorGIA := STR0013 + " " + SubStr( cErrorGIA, 2, Len( cErrorGIA ) )  	//"Ocorreu um erro fatal durante a geração do(s) Registro(s) "
		cErrorGIA += STR0014 + " " + Chr( 10 ) + Chr( 10 )
		cErrorGIA += STR0015 													//Favor efetuar o reprocessamento da GIA-ST, caso o erro persista entre em contato 
		cErrorGIA += STR0016 + Chr( 10 ) + Chr( 10 )							//com o administrador de sistemas / suporte Totvs 

		Aviso( STR0011, cErrorGIA, { "Sair" } )

	EndIf

Else
	//Tratamento para exibir mensagem no console quando processamento multi thread
	
	//Atualizando a barra de processamento	
	oProcess:Inc1Progress( STR0017 ) //Consolidando as informações e gerando arquivo...

	If GerTxtCons( aWizard )
		//Atualizando a barra de processamento
		oProcess:Inc2Progress( STR0019 ) 		//Registros da obrigação processados.
		oProcess:Inc1Progress( STR0018 )  		//Informações processadas		
		msginfo(STR0020)						//Arquivo gerado com sucesso!
	Else
		oProcess:Inc2Progress( STR0022 ) //Falha na geração do arquivo.
		oProcess:Inc1Progress( STR0021 ) //Processamento não realizado.		
	EndIf	

EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local 	cAction     := ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}
// PAINEL-1
	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens4	:= {}
	Local	aItens5	:= {}	
	Local	aItens6	:= {}
	Local	aItens7	:= {}
	Local	aItens8	:= {}

	Local	cTitObj1	:= ""
	Local	cTitObj2	:= ""
	Local	aRet		:= {}


	aAdd (aTxtApre, STR0023)  //Processando Empresa.
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0024) //Preencha corretamente as informações solicitadas.
	aAdd (aTxtApre, STR0025) //Informações necessárias para a geração do meio-magnético GIA-ST.

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 0³
	//ÀÄÄÄÄÄÄÄÄÙ

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0026) //Preencha corretamente as informações solicitadas - INFORMAÇÕES DA GIA.
	aAdd (aPaineis[nPos], STR0027) //Informações necessárias para a geração do meio-magnético GIA-ST.
	aAdd (aPaineis[nPos], {})


	//Coluna1																//Coluna 2
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1 := STR0028 //Diretório do Arquivo Destino
	cTitObj2 := STR0029 //Nome do Arquivo Destino

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	cTitObj1 := Replicate( "X", 50 )
	cTitObj2 := Replicate( "X", 20 )

	aAdd( aPaineis[nPos,3], { 2,, cTitObj1, 1,,,, 50,,,,, { "xFunVldWiz", "ECF-DIRETORIO" } } )
	aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 20,,,,,,} )

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	STR0030 //Mês Referência
	cTitObj2	:=	STR0031 //Ano Referência

	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )

	aAdd (aItens1, STR0032)   //01 - Janeiro    
	aAdd (aItens1, STR0033)   //02 - Fevereiro  
	aAdd (aItens1, STR0034)   //03 - Março      
	aAdd (aItens1, STR0035)   //04 - Abril      
	aAdd (aItens1, STR0036)   //05 - Meio       
	aAdd (aItens1, STR0037)   //06 - Junho      
	aAdd (aItens1, STR0038)   //07 - Julho      
	aAdd (aItens1, STR0039)   //08 - Agosto     
	aAdd (aItens1, STR0040)   //09 - Setembro   
	aAdd (aItens1, STR0041)   //10 - Outubro    
	aAdd (aItens1, STR0042)   //11 - Novembro   
	aAdd (aItens1, STR0043)   //12 - Dezembro   

	cTitObj2 :=	"@E 9999"

	aAdd (aPaineis[nPos,3], {3,,,,,aItens1,,,,,})
	aAdd( aPaineis[nPos,3], {2,,cTitObj2,2,0,,,4})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
   
//---------------------------------------------------------------------------------------------------------------
	//Versão do Arquivo:									"Gia de Substituição?"
	cTitObj1	:=	STR0044;	 							cTitObj2	:=	STR0045      
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1 := Replicate( "X", 02 );   					aAdd (aItens4, STR0046) //Não
	 														aAdd (aItens4, STR0047) //Sim
	aAdd (aPaineis[nPos,3],  {2,, cTitObj1, 1,,,, 02});		aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,})

    aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


    
//---------------------------------------------------------------------------------------------------------------    
    
	cTitObj1	:=	STR0048  //UF Favorecida
	aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,,} )
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aItens7,"AL - Alagoas")
	aAdd (aItens7,"AM - Amazônas")
	aAdd (aItens7,"AP - Amapá")
	aAdd (aItens7,"BA - Bahia")
	aAdd (aItens7,"CE - Ceara")
	aAdd (aItens7,"DF - Distrito Federal")
	aAdd (aItens7,"ES - Espírito Santo")
	aAdd (aItens7,"GO - Goiás")
	aAdd (aItens7,"MA - Maranhão")
	aAdd (aItens7,"MG - Minas Gerais")
	aAdd (aItens7,"MS - Mato Grosso do Sul")
	aAdd (aItens7,"MT - Mato Grosso")
	aAdd (aItens7,"PA - Pará")
	aAdd (aItens7,"PB - Paraíba")
	aAdd (aItens7,"PE - Pernambuco")
	aAdd (aItens7,"PI - Piauí")
	aAdd (aItens7,"PR - Paraná")
	aAdd (aItens7,"RJ - Rio de Janeiro")
	aAdd (aItens7,"RN - Rio Grande Norte")
	aAdd (aItens7,"RO - Rondônia")
	aAdd (aItens7,"RR - Roraima")
	aAdd (aItens7,"RS - Rio Grande do Sul")
	aAdd (aItens7,"SC - Santa Catariana")
	aAdd (aItens7,"SE - Sergipe")
	aAdd (aItens7,"SP - São Paulo")
	aAdd (aItens7,"TO - Tocantins")	
	
	aAdd (aPaineis[nPos,3], {3,,,,,aItens7,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					


//--------------------------------------------------------------------------------------------------------------------------------------------------//

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 1³
	//ÀÄÄÄÄÄÄÄÄÙ

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0026) //Preencha corretamente as informações solicitadas - INFORMAÇÕES DA GIA.
	aAdd (aPaineis[nPos], STR0027) //Informações necessárias para a geração do meio-magnético GIA-ST.
	aAdd (aPaineis[nPos], {})
	
	//---------------------------------------------------------------------------------------------------------------
	//Gia sem Movimento?									//EC Nº 87/15 com movimento?
	cTitObj1	:=	STR0049;								cTitObj2	:=	STR0050
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens2, STR0046);								aAdd (aItens3, STR0046) //SIM
	aAdd (aItens2, STR0047);								aAdd (aItens3, STR0047) //NÃO
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,});			aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,})

    aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	
	//---------------------------------------------------------------------------------------------------------------
	//Distribuidor de Combustível ou TRR?					Efetuou transferência para UF favorecida?
	cTitObj1	:=	STR0051;								cTitObj2	:=	STR0052
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens5, STR0046);								aAdd (aItens6, STR0046) //NÃO
	aAdd (aItens5, STR0047);								aAdd (aItens6, STR0047) //SIM
	aAdd (aPaineis[nPos][3], {3,,,,,aItens5,,,,,});			aAdd (aPaineis[nPos][3], {3,,,,,aItens6,,,,,})

   aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha	
   
   //--------------------------------------------------------------------------------------------------------------------------------------------------//
	//"Seleciona Filial?"									Inf. Complementares
	cTitObj1	:=	STR0053;								cTitObj2	:=	STR0054
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aItens8, STR0046);								cTitObj2 := Replicate( "X", 185 )
	aAdd (aItens8, STR0047)								
															
    aAdd (aPaineis[nPos][3], {3,,,,,aItens8,,,,,});			aAdd( aPaineis[nPos,3], {2,, cTitObj2, 1,,,, 185,,,,,,})
    aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
    
    //--------------------------------------------------------------------------------------------------------------------------------------------------//

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 2³
	//ÀÄÄÄÄÄÄÄÄÙ

	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0026) //Preencha corretamente as informações solicitadas - INFORMAÇÕES DA GIA.
	aAdd (aPaineis[nPos], STR0027) //Informações necessárias para a geração do meio-magnético GIA-ST.
	aAdd (aPaineis[nPos], {})
	
	cTitObj1	:=	STR0055		 //Contabilista:													
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})											
                                                                                         
	cTitObj1	:=	Replicate ("X", 36)													
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} )	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	 
	//---------------------------------------------------------------------------------------------------------------	
   
    cTitObj2	:=	STR0056 //Local do declarante:
    aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} )
    
    cTitObj2 := Replicate( "X", 60 )
    aAdd( aPaineis[nPos,3], {2,, cTitObj2, 1,,,, 60,,,,,,})
    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    
    //---------------------------------------------------------------------------------------------------------------
    aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
    
    cTitObj2    :=      STR0058 //Cadastro de Compl. Fiscais
    aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,} ) 
    cTitObj2    :=      STR0059 //Abrir programa
    cAction := "TAFA456('000015')" 
    aAdd( aPaineis[nPos,3], { 7, cTitObj2,,,,,,,,,,,,,,, cAction } ) 
    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
   
	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXGST() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGST

Geracao do Arquivo TXT da GIA-ST.
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo GIA-ST
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtGST( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "GIA-ST" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )

	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""

		Help( ,,"CRIADIR",, STR0057 + " "+ cValToChar( FError() ) , 1, 0 ) //Não foi possível criar o diretório \Obrigacoes_TAF\GIA-ST. Erro:

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

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
	EndIf

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da GIA-ST. Gera o arquivo dos registros e arquivo
consolidado

@Return ( Nil )

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt		:=	TAFGetPath( "2" , "GIA-ST" )			              	//diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".txt"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""

cNomeArq := aWizard[1,2]

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" )
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" )
			cFileDest += Alltrim(cNomeArq) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := GIAFilesTxt(cPathTxt)
	for nx := 1 to Len( aFiles )
			
		//Verifica se o arquivo foi encontrado no diretorio
		if File( aFiles[nx][1] )

			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()				//POSICIONO NO TOPO

			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
	   			IF(len(cBuffer) == 1023)
	   				cStrTxtFIM += cBuffer	   			
	   			Else
	   				cStrTxtFIM += cBuffer  + CRLF
	   			EndIf 
				FT_FSKIP()
			endDo			
			FT_FUSE()
			FERASE( aFiles[nx][1] )
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".txt"
	EndIf

	WrtStrTxt( nHandle, cStrTxtFIM )

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )	
	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GIAFilesTxt

GIAFilesTxt() - Arquivos por bloco da GIA

@Author Rafael Völtz
@Since 05/09/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function GIAFilesTxt( cPathTxt )

Local aRet	:=	{}
Local nPos  as Numeric

For nPos := 1 To Len(aFil)
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_A0.TXT"}) //Registro Principal
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_A1.TXT"}) //Devolução
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_A2.TXT"}) //Ressarcimento
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_A3.TXT"}) //Transferência 	
 	AADD(aRet,{cPathTxt + aFil[nPos,1] + "_A4.TXT"}) //Difal
Next nPos

Return( aRet )

