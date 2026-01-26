#Include "Protheus.ch"
#INCLUDE "TAFXGSP.CH"

#define DS_MODALFRAME 128

Static cObrig := "GIA-SP"
//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXGSP

Esta rotina tem como objetivo a geracao do Arquivo Magnetico da Nova GIA - SP

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXGSP(lAutomato)
Local cNomWiz   := ""
Local lEnd      := .F.
Local lEnvOk	:= .T.
Local aWizard	:= {} //Default
Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()
Local cFunction := " "
Local nOpc      := 2 //View
Local aCNPJIE   := {}

Default lAutomato 	:= .F. //Default

Private oProcess := Nil

cFunction := cRoutine

//Função para gravar o uso de rotinas e enviar ao LS (License Server)

Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

//cCode: Sempre use "LS006"
//cUser: Codigo do usuário, é opcional, o default é pegar o codigo do usuario logado
//cModule: Codigo do modulo
//cRoutine: Nome do programa"

//Recebo o nome da wizard
cNomWiz := Iif (!lAutomato, cObrig + FWGETCODFILIAL, "" )

If !lAutomato
	if findFunction("TAFObrVldEnv")
		lEnvOk := TAFObrVldEnv( { "C1H_RAMO" } )
	endif

	If lEnvOk
		//Protect Data / Log de acesso / Central de Obrigacoes
		Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc),)

		//Cria objeto de controle do processamento
		oProcess := TAFProgress():New( { |lEnd| ProcGIASP( @lEnd, @oProcess, cNomWiz, , , @aCNPJIE ) }, "Processando GIA" )
		oProcess:Activate()
	EndIf
Else
	ProcGIASP( @lEnd, @oProcess, cNomWiz, aWizard, lAutomato )
EndIf

//Limpando a memória
DelClassIntf()

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcGIASP

Inicia o processamento para geracao da GIA

@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario
       oProcess  -> Objeto da barra de progresso da emissao da GIA-SP
       cNomWiz   -> Nome da Wizard criada para a GIA
       
@Return ( Nil )

@Author Paulo V.B. Santana
@Since 15/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Static Function ProcGIASP( lEnd, oProcess, cNomWiz, aWizard, lAutomato, aCNPJIE )

Local cFunction		:=	""
Local cSemaphore	:=	""
Local cFilSel		:=	""
Local cJobAux		:=	""
Local cErrorGIA		:=	""
Local cErrorTrd		:=	""
Local cObrig		:= "GIA-SP"
Local cInscEst		:= ""
Local cCNPJ			:= ""
Local cCNAE			:= ""
Local cIn			:= ""

Local nIniThread	:=	0
Local nIniTimeOut	:=	0
Local nQtdThread	:=	0
Local nTimeOut		:=	0
Local nI			:=	0
Local nX			:=  0
Local nPos			:=	0
Local nProgress1	:=	0
Local nTryExec		:=	0
Local nCancelar		:=	0
Local nPosi			:=  1
Local nCount		:=  1
Local nY			:=  0
Local aSizeWindow 	:=  0
Local nLinIni   	:=  0
Local nLinFin   	:=  0
Local nColIni   	:=  0
Local nColFin   	:=  0
Local nAteLin       :=  0
Local nDlgFin		:=  0

Local aMV_TAFMTOF	:= {}
Local aRegGia		:= {}
Local aFiliais		:= {}
Local aContab		:= {}
Local aJobAux		:= {}
Local aSM0			:= {}
Local aGetSM0		:= SM0->(GetArea())
Local lAglutina     := .F.
Local lCNPJIE		:= .F.
Local lSomaFil		:= .F.
Local lMultThread	:= .F.
Local lProc			:= .T.
Local lTafFisMod	:= .F.
Local cInscEst		:= ""
Local cMesReF		:= ""
Local cAnoRef		:= ""
Local cErroInt		:= ''

Local dInicial		:= CTOD("  /  /    ")
Local dFinal  		:= CTOD("  /  /    ")			
Local cYearGia		:= " "

Local oDlg 			:= Nil
Local cMsgGia		:= ''

Default lEnd		:= .F.
Default oProcess	:= Nil
Default cNomWiz		:= ""
Default aWizard		:= {}
Default lAutomato	:= .F.
Default aCNPJIE		:= {}

//Função genérica para realizar a preperação do ambiente e iniciar as Threads no caso de Multi Processsamento
//xParObrMT( cObrig, @cSemaphore, @lMultThread, @nQtdThread )

//Carrega informações na wizard
If !lAutomato

	If !xFunLoadProf( cNomWiz , @aWizard )
		Return( Nil )
	EndIf

	cYearGia := aWizard[1][13]
	dInicial := CTOD("01/"+Substr(aWizard[1][12],1,2)+"/"+cYearGia)
	dFinal   := LastDay(dInicial)	

	if TemRegSFT( DtoS(dInicial), DtoS(dFinal), .F. ) //Verifica se o cliente utiliza o TAF como módulo
		if FWSX6Util():ExistsParam("MV_TAFFPRO")
			PUTMV("MV_TAFFPRO", .T. )
		endif
	endif

	lTafFisMod := GetNewPar("MV_TAFFPRO",.F.)

	if lTafFisMod //Apenas para TAF como módulo Protheus

		cMsgGia := 'Esse processo irá buscar as notas fiscais do Protheus e irá realizar a integração dos dados no TAF para o período selecionado. "
		cMsgGia += 'As movimentações já existentes no TAF, serão deletadas e inseridas novamente para atualização dos dados com base na ultima extração efetuada.' + CRLF + CRLF
		cMsgGia += 'O tempo de geração do arquivo nesse modo varia conforme a quantidade de movimentações existentes no ERP. Deseja continuar?'
		
		//Caso "Origem dados" = "01-ERP" Chama extração e integração dos dados antes da geração do arquivo da Gia-SP
		if left(aWizard[1][17],1) == '1' .and. Aviso('Geração GIA-SP', cMsgGia , {'Sim','Não'}, 2, 'Atenção!!!' ) = 1
			if !IntegraERP(@cErroInt,aWizard[1][18], dInicial, dFinal); MsgStop(cErroInt); endif
		else

			lProc := TafStXPend( DtoS(dInicial), DtoS(dFinal), "TAFST1" )
			if lProc
				lProc := TafStXPend( DtoS(dInicial), DtoS(dFinal), "TAFST2" )
			endif

			if lProc
				aSizeWindow := MsAdvSize()
				nLinIni   	:= aSizeWindow[7] //Definindo a Linha Inicial da tela inicial que será criada
				nLinFin   	:= aSizeWindow[6] //Definindo a Linha  Final da tela inicial que será criada
				nColIni   	:= aSizeWindow[2] //Definindo a Coluna Inicial da tela inicial que será criada
				nColFin   	:= aSizeWindow[5] //Definindo a Coluna Final da tela inicial que será criada

				TafDimDlg(nColFin, nLinFin, @nAteLin, @nDlgFin)

				DEFINE DIALOG oDlg TITLE STR0016 FROM (nLinFin * 0.2),(nLinFin * 0.2) TO nAteLin, nDlgFin PIXEL Style DS_MODALFRAME //"Notas Integradas ( ERP X TAF )"

					@ (nColIni*0.2), (nColIni*0.3) TO (nColIni*0.7), (nColIni*4) LABEL STR0017 OF oDlg PIXEL //"Deseja Gerar o Relatório Comparativo?"
					nGera  := 2 //Default Nao
					aItems := { STR0021, STR0022 } //"Sim"##"Não"

					oRadio1 := TRadMenu():New ( (nColIni*0.85),(nColIni*0.27),aItems,,oDlg,,,,,,,,(nColIni*3.35),(nColIni*0.4),,,,.T.)
					oRadio1:bSetGet := {|u|Iif (PCount()==0,nGera,nGera:=u)}

					@ (nColIni*1.7), (nColIni*0.3) 	TO (nColIni*2.2), (nColIni*4) LABEL STR0018 OF oDlg PIXEL //"Forma de Exibição?"
					nExib  := 1
					aItems := { STR0019, STR0020 } //"Apenas Divergências"##"Todas as Notas"

					oRadio2 := TRadMenu():New ((nColIni*2.35),(nColIni*0.27),aItems,,oDlg,,,,,,,,(nColIni*3.35),(nColIni*0.4),,,,.T.)
					oRadio2:bSetGet := {|u|Iif (PCount()==0,nExib,nExib:=u)}

					oTButton1 := TButton():New( (nColIni*3.35), (nColIni*0.2), STR0023, oDlg,{|| lProc := .F., oDlg:End() }, (nColIni*1.35),(nColIni*0.4),,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
					oTButton2 := TButton():New( (nColIni*3.35), (nColIni*1.85), STR0024, oDlg,{|| lProc := .T., oDlg:End() }, (nColIni*1.35),(nColIni*0.4),,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
					oDlg:lEscClose := .F.
				ACTIVATE DIALOG oDlg CENTERED

				if lProc .And. nGera == 1
					TNGiaSpRel( dInicial , dFinal, nExib ) //Efetua Chamada do Relatorio
					lProc := MsgYesNo(STR0025) //"Deseja gerar o arquivo final no destino informado ?"
				endif
			endif
		endif
	endif

    aWizard[1][9] := IIF(Len(Alltrim(aWizard[1][9]))==1,Padl(Alltrim(aWizard[1][9]),2,'0'),aWizard[1][9])
    aWizard[1][12] := IIF(Len(Alltrim(aWizard[1][12]))==1,Padl(Alltrim(aWizard[1][12]),2,'0'),aWizard[1][12])
	
Else
	If FindFunction("GetParAuto")
		aWizard := GetParAuto("TAFXGSPTestCase")
	Endif
EndIf



//Verificação das filiais selecionadas para processamento da operação
If lProc .And. "1" $ aWizard[1,5] //seleciona filiais "1 - Sim"
	//verifica se utiliza aglutinacao
	if Upper(Alltrim(aWizard[1,15])) == "1 - POR CNPJ"
		aadd( aCNPJIE , {.T., .F.} )
	elseif Upper(Alltrim(aWizard[1,15])) == "2 - POR CNPJ+IE"
		aadd( aCNPJIE , {.T., .T.} )
	endif

	aFiliais := xFunTelaFil( .T.,,,.T.,,,,,,@aCNPJIE )

	If Empty( aFiliais )
		lProc := .F.
	Else

		If Len( aFiliais ) > 0
	
			For nI := 1 to Len( aFiliais )
				
				DbSelectArea ("SM0")
				SM0->(msseek (cEmpAnt+aFiliais[nI][2], .T.))
				
				If aFiliais[nI][1]//Filial Selecionada
					AADD(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_INSC, SM0->M0_CGC})				
				Endif
			Next

		EndIf
	EndIf
Else
	AADD(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_INSC})	
EndIf

If lProc

	lAglutina	:= ValType(aWizard[1,15]) == "C" .And. SubStr(aWizard[1,15],1,1) >= "1" .And. Len(aSM0) > 1
	lCNPJIE		:= ValType(aWizard[1,15]) == "C" .And. SubStr(aWizard[1,15],1,1) == "2" .And. Len(aSM0) > 1
	
	//Alimentando o array com os registros que devem ser processados juntamente com seus respectivos filhos
	aRegGia := xTafGetObr( cObrig )

	TAFConout( "Tempo de Inicio " + Time() ,1,.T.,"GIA") 

	If !lAutomato
		
		//Alimentando a variável de controle da barra de status do processamento
	
		nProgress1 := 7
		oProcess:Set1Progress( nProgress1 )

		//Iniciando o Processamento
		oProcess:Inc1Progress( "Preparando o Ambiente..." )
		
	EndIf

	For nI:=1 to Len(aSM0)

		If !(nI > Len(aSM0)) 
		
			SM0->(msseek (aSM0[nI][1]+aSM0[nI][2]))

			cFilSel		:= Alltrim(SM0->M0_CODFIL)
			cInscEst	:= Alltrim(SM0->M0_INSC)
			cCNPJ		:= Alltrim(SM0->M0_CGC)
			cCNAE		:= Alltrim(SM0->M0_CNAE)

			Iif( Len(aSM0[nI]) > 3 .AND. lCNPJIE, AglutVlr(@aSM0, @cIn, cCNPJ, cInscEst),  ) //Se foi selecionado "Aglutina: 2 - Por CNPJ+IE"

			For nX:=1 to Len(aRegGia)
			
				cFunction := aRegGIA[nX,2]
				
				//Processamento Multi Thread
				If lMultThread 

					//Inicializa variavel global de controle das Threads
					cJobAux := StrTran( "cGIA_" + FwGrpCompany() + FwCodFil(), ' ', '_' ) + StrZero( nI , 2 )

					//Seto o Status da Variavel como "0", ou seja, pendente de processamento
					PutGlbValue( cJobAux, "0" )
					GlbUnlock()

					//Adiciona o nome do arquivo de Job no array aJobAux
					aAdd( aJobAux, { cJobAux, aRegGIA[nI,3] } )

					//Variavel de controle de Start das Execuções
					nTryExec := 0
				
					While .T.
						If IPCGo( cSemaphore, cObrig, cFunction, aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil )
							Exit
						Else
							nTryExec ++
							Sleep( 1000 )
						EndIf

						//Caso ocorra erro em 10 tentativas de iniciar a Thread aborta informando ao usuário o erro
						If nTryExec > 10
							cErrorTrd := "Ocorreu um erro fatal durante a inicialização das Threads, por favor reinicie o processo. Caso o erro persista entre em contato com o administrador do sistema"
							Exit
						EndIf
					EndDo

					//MonoThread
				Else
					If !lAutomato
						oProcess:Inc1Progress( "Executando o Processamento...")
					EndIf	
					&cFunction.( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn)
				EndIf
			
				//Caso seja encontrado algum erro durante o processamento aborto a execução
				If !Empty( Alltrim(cErrorTrd) )
					Exit
				EndIf
				
			Next nX
	
		EndIf

	Next nI

//Processamento Cancelado
Else
	If !lAutomato
		oProcess:Inc1Progress( "Processamento cancelado" )
		oProcess:Inc2Progress( "Clique em Finalizar" )
		oProcess:nCancel = 1
	EndIf	

EndIf

RestArea(aGetSM0)

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
						If !lAutomato
							nProgress1 --
							oProcess:Inc1Progress( "Encerrando o Registro..." + aJobAux[nI,2] )
						EndIf

						//Encerro da execução da variável em memória
						ClearGlbValue( cJobAux )

					//O Tipo 9 ocorre quando ocorre Error Log na execução do bloco
					Case GetGlbValue( cJobAux ) == "9"

						nProgress1 --
						cErrorGIA += "," + aJobAux[nI,2] + " "

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

//Tratamento para o botão cancelar
If !lAutomato
	nCancelar	:= oProcess:nCancel
Else
	nCancelar	:= 0
EndIf

//Tratamento para quando o processamento tem problemas
If nCancelar == 1 .or. !Empty( cErrorGIA ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If nCancelar == 1

		Aviso( "Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" } )

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( "Atenção!", cErrorTrd, { "Sair" } )

	//Erro na execução dos Blocos
	Else

		cErrorGIA := "Ocorreu um erro fatal durante a geração do(s) Registro(s) " + SubStr( cErrorGIA, 2, Len( cErrorGIA ) )
		cErrorGIA += "da GIA-SP " + Chr( 10 ) + Chr( 10 )
		cErrorGIA += "Favor efetuar o reprocessamento da GIA-SP, caso o erro persista entre em contato "
		cErrorGIA += "com o administrador de sistemas / suporte Totvs" + Chr( 10 ) + Chr( 10 )

		Aviso( "Atenção!", cErrorGIA, { "Sair" } )

	EndIf

Else

	//Atualizando a barra de processamento
	If !lAutomato
		oProcess:Inc1Progress( "Informações processadas" )
		oProcess:Inc2Progress( "Consolidando as informações e gerando arquivo..." )
	EndIf

	If GerTxtCons( aSM0, aWizard, lAglutina )
		//Atualizando a barra de processamento
		If !lAutomato
			oProcess:Inc2Progress( "Arquivo gerado com sucesso." )
		EndIf
		msginfo("Arquivo gerado com sucesso!")
	Else
		If !lAutomato
			oProcess:Inc2Progress( "Falha na geração do arquivo." )
		EndIf
	EndIf

	TAFConout( "Tempo Final " + Time() ,1,.T.,"GIA") 

EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

Construção dos painéis para geração do arquivo.

@Return	aRet	-	Parametrização necessária para a rotina xFunWizard

@author Vitor Henrique
@since	22/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()	

Local	cNomWiz	:= cObrig+FWGETCODFILIAL 
Local 	cNomeAnt 	:= ""	
Local	aTxtApre	:= {}
Local	aPaineis	:= {}
Local	aItens1		:= {}
Local	aItens2		:= {}
Local	cTitObj1	:= ""
Local	cTitObj2	:= ""	
Local	aRet		:= {}
Local 	lWebApp		:= GetRemoteType() = 5
Local 	lWhen		:= !lWebApp //Se for WebApp, nao passa pelo campo.
Local 	lOpcExt		:= TcGetDb() $ 'MSSQL7' .and. GetAPOInfo('EXTFISXTAF.PRW')[4] >= ctod('19/07/2021')

aAdd (aTxtApre, "Processando Empresa.")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético GIA-SP")
	
//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Informações necessárias para a geração do meio-magnético NOVA GIA.")
aAdd (aPaineis[nPos], {})

cTitObj1	:=	"Diretório do Arquivo Destino" ;						cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 100);									cTitObj2	:=	Replicate ("X", 100)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50,,,,,,,,,,,,,,,lWhen});	aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})


cTitObj1	:=	"Versão do Sistema Nova GIA" ;							cTitObj2	:=	"Versão do Layout Nova GIA"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 4);							    		cTitObj2	:=	Replicate ("X", 4)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});						aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})



cTitObj1	:=	"Selecione Filiais:";							cTitObj2	:=  "Tipo de Gia:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "0 - Não"); 										aAdd (aItens2, "01 - Normal") 
aAdd (aItens1, "1 - Sim");										aAdd (aItens2, "02 - Substitutiva") 							

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})



cTitObj1	:=	"GIA com Movimento:";							cTitObj2	:=  "Gia Trasmitida:" 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

aItens1	:=	{}; 												aItens2	:=	{}
aAdd (aItens1, "0 - Não"); 										aAdd (aItens2, "0 - Não")
	 										
aAdd (aItens1, "1 - Sim");										aAdd (aItens2, "1 - Sim")								

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});				    aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


cTitObj1	:=	"Mês Ref." ;									cTitObj2	:=	"Regime Tributário"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
																aItens2	:=	{}
																aAdd (aItens2, "01 - RPA (Regime Periódico de Apuração)") 
																aAdd (aItens2, "02 - RES (Regime por Estimativa)")
																aAdd (aItens2, "03 - RPA-DISPENSADO")
																aAdd (aItens2, "04 - Simples-ST") 

cTitObj1	:=	Replicate ("X", 02)							
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})



cTitObj1	:=	"Ano Ref." ;									cTitObj2	:=	"Mês Ref. Inicial"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 04);							cTitObj2	:=	Replicate ("X", 02)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})



cTitObj1	:=	"Ano Ref. Inicial" ;							cTitObj2	:=	"ICMS Fixado"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

cTitObj1	:=	Replicate ("X", 04);							cTitObj2	:=	Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"Aglutina:";									cTitObj2	:=	"Rateio DIPAM 2.5:"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
aItens1	:=	{};                                                 aItens2 := {}
aAdd (aItens1, "0 - Não");                                      aAdd( aItens2, "01 - Distribuição/Geração" )
aAdd (aItens1, "1 - Por CNPJ");                                 aAdd( aItens2, "02 - Comercialização" )
aAdd (aItens1, "2 - Por CNPJ+IE");

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});                 aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
aAdd(aPaineis[nPos][3], {0,"",,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"Origem dados:";								cTitObj2	:=	"Integração:"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
aItens1	:=	{};                                                 aItens2 := {}
aAdd (aItens1, "0 - TAF");                                      aAdd( aItens2, "01 - Cadastro/Movimentos" )
if lOpcExt; aAdd (aItens1, "1 - ERP"); endif;                   aAdd( aItens2, "02 - Somente movimentos" )
	

aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,,,,,,,,,,,,,lOpcExt});  aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,,,,,,,,,,,,,lOpcExt})
aAdd(aPaineis[nPos][3], {0,"",,,,,,});                          	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd(aPaineis[nPos][3], {1,"",,,,,,});                          	aAdd (aPaineis[nPos][3], {1,"",,,,,,})

aAdd( aRet, aTxtApre )
aAdd( aRet, aPaineis )
aAdd( aRet, cNomWiz )
aAdd( aRet, cNomeAnt )
aAdd( aRet, Nil )
aAdd( aRet, Nil )
aAdd( aRet, { || TAFXGSP() } )	//Code Block para o botão "Finalizar" deve executar a rotina responsável pela geração do arquivo

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FDipCFOP

Tela de seleção de relacionamento DIPAM-B X CFOPs.

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function FDipCFOP( )
Local nOpc := GD_INSERT+GD_UPDATE+GD_DELETE
Local nCont			:= 0
Local aArea			:= GetArea()
Local lExistGet
Local aAlter := {}

Private aColsGrid:= {}
Private aHeaGrid:= {}
Private oBrowDCFO
Private oDlg1
Private noBrw := 0

MHoBrowDCFO()
MCoBrwDCFO()

For nCont := 1 to Len(aHeaGrid)
	aAdd(aAlter,aHeaGrid[nCont,2])
Next nCont

oDlg1     := MSDialog():New( 091,232,502,820,"CFOPs por DIPAM-B",,,.F.,,,,,,.T.,,,.T. )

oBrowDCFO := MsNewGetDados():New(024,016,216,368,nOpc,"AllwaysTrue","AllwaysTrue",""      ,aAlter    ,000    ,999 ,"AllwaysTrue","","AllwaysTrue",oDlg1,aHeaGrid,aColsGrid)

oBrowDCFO:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg1:bInit 		:= EnchoiceBar(oDlg1,{|| GravaGrid(),oDlg1:End()},{|| oDlg1:End()})
oDlg1:lCentered	:= .T.
oDlg1:Activate()

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MCoBrwDCFO

MHoBrowDCFO() - Monta aHeaGrid da MsNewGetDados p/Alias: CZQ

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function MHoBrowDCFO()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("CZQ")
While !Eof() .and. SX3->X3_ARQUIVO == "CZQ" 
		If Alltrim(SX3->X3_CAMPO) $ "CZQ_CODDIP|CZQ_CODCFO|"
     		noBrw++
  			aAdd( aHeaGrid, { AlLTrim( X3Titulo() ),; // 01 - Titulo
				SX3->X3_CAMPO,;
           	SX3->X3_PICTURE,;
           	SX3->X3_TAMANHO,;
           	SX3->X3_DECIMAL,;
           	"",;
           	"",;
           	SX3->X3_TIPO,;
           	SX3->X3_F3		,;				// 09 - F3
			 	SX3->X3_CONTEXT ,;       	// 10 - Contexto
			 	SX3->X3_CBOX		,; 	  	  	// 11 - ComboBox
		    	"xFRelacao()", } ) 		   // 12 - Relacao
  		Endif
  		
   DbSkip()
End

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MCoBrwDCFO

MCoBrwDCFO() - Monta aColsGrid da MsNewGetDados para o Alias: CZQ

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function MCoBrwDCFO()
Local aAux := {}
Local nX   := 0 
Local cAliasQry	:=	GetNextAlias()

BuscaCFOP(cAliasQry)

(cAliasQry)->(dbGoTop())  
nAux:=0
While !(cAliasQry)->(eof())
	AADD(aColsGrid,Array(noBrw+1))
	nAux++
	For nX:=1 to noBrw
		If ( aHeaGrid[nX][2] == "CZQ_CODDIP")
			aColsGrid[nAux][nX] := POSICIONE("CW5",1,xFilial("CW5")+(cAliasQry)->DIPAM,"CW5_CODIGO")
		Elseif ( aHeaGrid[nX][2] == "CZQ_CODCFO")
			aColsGrid[nAux][nX] := POSICIONE("C0Y",3,xFilial("C0Y")+(cAliasQry)->CFOP,"C0Y_CODIGO")
		Else	
			aColsGrid[nAux][nX] := CZQ->(FieldGet(FieldPos(aHeaGrid[nX][2]))) 
		Endif
	Next 
	aColsGrid[Len(aColsGrid),noBrw+1]:=.F.
	
	(cAliasQry)->(DBSKIP()) 
End
(cAliasQry)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaGrid

Grava na Tabela as Informações da GRID.

@Param 

@Return 

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaGrid()
Local cIdDipam := ""
Local cIdCfop	 := ""
Local nTamACOLS:= 0
Local lGrava := .T.
Local cAlias := "CZQ"
local i      := 0

nTamACOLS := len( oBrowDCFO:Acols )
nTamAGrid := len( aColsGrid )

Begin Transaction
	dbSelectArea("CZQ")
	dbSetOrder(2)
	
	For i:=1 to len(oBrowDCFO:aCols) 
		cIdDipam := POSICIONE("CW5",2,xFilial("CW5")+oBrowDCFO:aCols[i][1],"CW5_ID")
 		cIdCfop  := POSICIONE("C0Y",1,xFilial("C0Y")+oBrowDCFO:aCols[i][2],"C0Y_ID")
		lGrava	  := dbSeek(xFilial("CZQ")+cIdCfop)
		
		If oBrowDCFO:aCols[i,Len(oBrowDCFO:aHeader)+1] .And. lGrava 
			RecLock(cAlias,!lGrava)
			( cAlias ) ->( dbDelete() )
			MsUnlock()	
		ElseIf !oBrowDCFO:Acols[i,Len(oBrowDCFO:aHeader)+1]	
			If lGrava	
				RecLock(cAlias,.F.)
			Else	
				RecLock(cAlias,.T.)
			Endif
			( cAlias )->CZQ_FILIAL := xFilial("CZQ")
			( cAlias )->CZQ_ID     := cIdDipam
			( cAlias )->CZQ_IDCFOP := cIdCfop
			msUnlock()
		Endif	
	Next
	
End Transaction

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} xFRelacao

Função para retirar o X3_RELACAO do campo

@Author Paulo Sérgio V.B. Santana
@Since 16/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xFRelacao( )
cRet:= ""
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaCFOP

Query com seleção de cfops utilizadas no período

@Author Paulo Sérgio V.B. Santana
@Since 20/04/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Function BuscaCFOP(cAliasQry)

Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cOrderBy	:=	""
Local cGroupBy	:=	""

cSelect:= " C2F.C2F_CFOP CFOP, CZQ.CZQ_ID DIPAM "
cFrom  := RetSqlName("C2F") + " C2F "
cFrom  += " LEFT JOIN " + RetSqlname('CZQ') + " CZQ ON C2F.C2F_CFOP = CZQ.CZQ_IDCFOP "
cWhere := " C2F.D_E_L_E_T_='' AND CZQ.D_E_L_E_T_=''  "
cGroupBy:=" C2F.C2F_CFOP, CZQ.CZQ_ID "
cOrderBy:=" C2F.C2F_CFOP, CZQ.CZQ_ID "

cSelect:= "%" + cSelect + "%"
cFrom  := "%" + cFrom   + "%"
cWhere := "%" + cWhere   + "%"
cGroupBy := "%" + cGroupBy   + "%"
cOrderBy := "%" + cOrderBy   + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	GROUP BY
		%Exp:cGroupBy%
	order BY
		%Exp:cOrderBy%
EndSql

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtGIA

Geracao do Arquivo TXT da GIA. Gera o arquivo dos registros e arquivo 
consolidado

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo ECF
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Paulo V.B. Santana
@Since 22/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtGIA( nHandle, cTXTSys, cReg)

Local	cDirName		:=	'' 
Local	cFileDest		:=	""
Local	lRetDir			:=	.T.
Local	lRet			:=	.T.
Local 	lAutomato		:= IsBlind() 

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !lAutomato
	cDirName := TAFGetPath( "2" , "GIASP" )
else
	cDirName := '\baseline\'
endif	

if !File( cDirName )
	lRetDir := FWMakeDir( cDirName )
	if lRetDir == .F.
		//cDirName	:=	""
		Help( ,,"CRIADIR",, "Não foi possível criar o diretório " + cDirName + " Erro: " + cValToChar( FError() ) , 1, 0 )
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
	
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest, .t. )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da GIA. Gera o arquivo dos registros e arquivo 
consolidado

@Return ( Nil )

@Author Paulo V.B. Santana
@Since 22/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aSM0 , aWizard, lAglutina )

Local cFileDest  	:=	""
Local cPathTxt		:=	TAFGetPath( "2" , "GIASP" )		                     //diretorio onde foram gerados os arquivos txt temporarios
Local ny			:=	0
Local nx			:=	0
Local cInscEst		:=	''
Local cTxtSys		:=	'' 
Local nHandle		:=	0  
Local aFiles		:=	{}
Local nQtdcr05		:= IIf(lAglutina,Len(aSM0),1) //Len(aSM0)
Local cQtdCR05		:= ""
Local cStrTxt		:= ""
Local cStrTxt01		:= ""
Local cStrTxt05		:= ""
Local cStrTxtFIM	:= ""

Default lAglutina   := .F.

cStrTxtC01:= TAFGS01( aWizard, nQtdcr05 ) //Alimenta a variável com as informações do registro CR=01

//Tratamento para Linux onde a barra é invertida
If GetRemoteType() == 2
	If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
		cPathTxt += "/"
	EndIf
Else
	If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
		cPathTxt += "\"
	EndIf
EndIf

For ny:=1 to Len( aSM0 )
	
	cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
	nHandle		:=	MsFCreate( cTxtSys )

	cInscEst := Alltrim(aSM0[ny][3])
	
	aFiles := GIAFilesTxt(cPathTxt,cInscEst)
	
	 //Limpo as Variáveis
	//cStrTxt    := ""
	cStrTxt05  := ""
	cStrTxtfim := ""
	cQtdCR05   := ""
	
	for nx := 1 to Len( aFiles )
		
		//Verifica se o arquivo foi encontrado no diretorio 
		if File( aFiles[nx][1] ) 
			
			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()				//POSICIONO NO TOPO
			
			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
    			If substr(cBuffer,1,3)=="QTD"
    				cQtdCR05+= substr(cBuffer,4,4)
    			Else
     				cStrTxtfIM += cBuffer + CRLF
     			Endif
 				FT_FSKIP()
    		endDo
    	endif
	next
	
	If File(cPathTxt+"CR05" + cInscEst + ".TXT" )
		
		FT_FUSE(cPathTxt+"CR05" + cInscEst + ".TXT" )	
		FT_FGOTOP()											
			
		while !FT_FEOF()
	    	cBuffer := FT_FREADLN()
    		cStrTxt05 += cBuffer + cQtdCR05 + CRLF
    		FT_FSKIP()
 		endDo
 		
    Endif	
	
	If lAglutina
		If Empty(cStrTxt)
			cStrTxt += cStrTxtC01
		EndIf
		cStrTxt += cStrTxt05+cStrTxtFim
	Else
		cStrTxt := cStrTxtC01+cStrTxt05+cStrTxtFim
	EndIf

	//atribuo inicialmente o diretorio de destino do arquivo e valido a barra e linux
	cFileDest	:=	allTrim( aWizard[ 1 , 1 ] )

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
		EndIf
	Else
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
		EndIf
	EndIf

	//acrescento o nome do arquivo no diretorio selecionado pelo usuario
	cFileDest	+=	Alltrim(aWizard[1][2] )	//diretorio + nome do arquivo final ( consolidado )

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".PRF" 
		cFileDest := cFileDest + IIF(lAglutina,'', '_' + cInscEst) + ".PRF"
	EndIf
	
	If !lAglutina
		WrtStrTxt( nHandle, cStrTxt )
	
		lRet := SaveTxt( nHandle, cTxtSys, cFileDest )
	EndIf

next

If lAglutina
	WrtStrTxt( nHandle, cStrTxt )

	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )
EndIf

Return( lRet )

// ----------------------------
static function GIAFilesTxt(cPathTxt,cInscEst)

Local aRet	:=	{}

AADD(aRet,{cPathTxt+"CR07"+cInscEst+".TXT"})
AADD(aRet,{cPathTxt+"CR10"+cInscEst+".TXT"})
AADD(aRet,{cPathTxt+"CR20"+cInscEst+".TXT"})
AADD(aRet,{cPathTxt+"CR30"+cInscEst+".TXT"})
AADD(aRet,{cPathTxt+"CR31"+cInscEst+".TXT"})

return( aRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS01

Função que retorna o conteúdo das informações do registro CR=01

@Param cStrTxt -> Variavél que contém todas as informações do arquivo

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFGS01( aWizard, nQtdcr05 )
Local cStrTxt:= " "

cStrTxt:= "01"                     											 //CodigoRegistro
cStrTxt+= "01"                     											 //TipoDocto
cStrTxt+= dtos(dDatabase)			                                       //DataGeração
cStrTxt+= substr(Time(),1,2)+substr(Time(),4,2)+substr(Time(),7,2)        //HoraGeração
cStrTXT+= "0000"																	 //VersãoFrontEnd
cStrTXT+= Alltrim(aWizard[1][4])							                  //VersãoPref
cStrTxT+= Strzero(nQtdcr05,4) 													//Q05
cStrTxT+= CRLF 																	//Separadores

Return (cStrTxT)

//---------------------------------------------------------------------
/*/{Protheus.doc} AglutVlr

Função que manipula o array aSM0

@Param 
aSM0 -> Array contendo as filiais selecionadas para processamento
cIn -> String contendo as filiais que possuem o mesmo CNPJ e IE e devem
ser aglutinadas
cCNPJ -> CNPJ usado para buscar as filiais que serão aglutinadas
cInscEst -> IE usada para buscar as filiais que serão aglutinadas

@Author Matheus Prada
@Since 27/08/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function AglutVlr(aSM0, cIn, cCNPJ, cInscEst)

	Local aFils := aClone(aSM0)
	Local nX    := 0
	Local nPos  := 1

	For nX := 0 to Len(aSM0)
		If !(nPos > Len(aFils))
			nPos := aScan(aFils, {|x| alltrim(x[3]) == cInscEst .AND. alltrim(x[4])== cCNPJ  }, nPos )
			If nPos > 1
				cIn += "/"+Alltrim(aFils[nPos][2])
				aDel(aFils,nPos)
				aSize(aFils,Len(aFils)-1)
			EndIf
			nPos++
		EndIf
	Next nX
	aSM0 := {}
	For nX:= 1 to Len(aFils)
		If !Empty(aFils[nX])
			AADD(aSM0, aFils[nX])
		EndIf
	Next nX
	aFils := {}
	aFils := StrtokArr(cIn, "/")
	For nX := 1 to Len(aFils)
		If nX > 1
			cIn += " , '" + aFils[nX] + "'"
		Else
			cIn := "'" + aFils[nX] + "'"
		EndIf
	Next nX
	while "''" $ cIn
		cIn := StrTran( cIn, "''", "'" )
	enddo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR126

TAFR126() - Relatorio para conferencia de Notas Integradas.
Opcao Chamada Diretamente do Menu

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFR126()

Local oReport	:= Nil
Local oObj 		:= Nil
Local aPergunte := {}

oObj := FWSX1Util():New()
oObj:AddGroup("TAFREGINTE")
oObj:SearchGroup()
aPergunte := oObj:GetGroup("TAFREGINTE")

TR126FIM() ////Tela de aviso de encerramento da rotina

//verifica existencia do grupo de perguntas com a devida qtd de campos
if len( aPergunte ) > 1 .And. len( aPergunte[2] ) >= 3
	If FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
else
	MsgInfo(STR0002) //"O Grupo de Perguntas não foi encontrado, favor aplicar o último pacote periódico do TAF disponível."
endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TNGiaSpRel

TNGiaSpRel() - Relatorio para conferencia de Notas Integradas.
Chamado no propria Wizard da central de obrigacoes

@Param
 dInicial - Data Inicio Competencia Obrigacao
 dFinal   - Data Fim Competencia Obrigacao
 nExib    - Forma de Exibicao do Relatorio

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TNGiaSpRel( dInicial , dFinal, nExib )

Local oReport

Default dInicial := CTOD("  /  /    ")
Default dFinal 	 := CTOD("  /  /    ")
Default nExib 	 := 1

TR126FIM() //Tela de aviso de encerramento da rotina

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef( dInicial , dFinal, nExib )
	oReport:PrintDialog()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

ReportDef() - Secao ( colunas do relatorio )

@Param
 dInicial - Data Inicio Competencia Obrigacao
 dFinal   - Data Fim Competencia Obrigacao
 nExib    - Forma de Exibicao do Relatorio

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef( dInicial , dFinal, nExib )

	Local cAreaTmp	 := ""
	Local cPerg 	 := ""
	Local cNmProg	 := funname()
	Local nTamFil    := 0
	Local nTamDoc    := 0
	Local nTamSer    := 0
	Local nTamCliFor := 0

	Default dInicial := CTOD("  /  /    ")
	Default dFinal	 := CTOD("  /  /    ")
	Default nExib	 := 1

	if cNmProg == 'TAFR126'
		cPerg := "TAFREGINTE" //Tam Max 10
		Pergunte( cPerg, .F. ) // Carrega os MV_PAR do grupo de perguntas
	endif

	oReport := TReport():New(STR0004, STR0004, cPerg, {|oReport| ReportPrint(oReport, dInicial, dFinal, nExib, @cAreaTmp)}, STR0005) //"Conf Notas Integradas"##"Relatório para conferência das integrações referente aos Documentos Fiscais que possuem tributação."
	oSectionNF := TRSection():New( oReport, STR0006, , , , , , .F. ) //Notas
	oSectionNF:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página

	nTamFil    := TamSX3( "C20_FILIAL" )[1]
	nTamDoc    := TamSX3( "C20_NUMDOC" )[1]
	nTamSer    := TamSX3( "C20_SERIE" )[1]
	nTamCliFor := TamSX3( "C1H_CODPAR" )[1]

	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->FIL"	, "(cAreaTmp)", STR0007, , nTamFil	 , ,{|| (cAreaTmp)->FIL	    }) //"Filial"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->LADOERP", "(cAreaTmp)", STR0008, , 01		 , ,{|| (cAreaTmp)->LADOERP }) //"ERP?"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->LADOTAF", "(cAreaTmp)", STR0009, , 01		 , ,{|| (cAreaTmp)->LADOTAF }) //"TAF?"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->DTES" 	, "(cAreaTmp)", STR0010, , 10		 , ,{|| DtoC(Stod((cAreaTmp)->DTES)) }) //"Dt.Ent"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->TIPOMOV", "(cAreaTmp)", STR0011, , 07	     , ,{|| (cAreaTmp)->TIPOMOV }) //"(E)nt.(S)ai"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->CODPAR"	, "(cAreaTmp)", STR0012, , nTamCliFor, ,{|| (cAreaTmp)->CODPAR  }) //"Cli.For"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->NUMDOC"	, "(cAreaTmp)", STR0013, , nTamDoc	 , ,{|| (cAreaTmp)->NUMDOC  }) //"Num.Doc"
	oCell := TRCell():New( oSectionNF, "(cAreaTmp)->SERIE" 	, "(cAreaTmp)", STR0014, , nTamSer	 , ,{|| (cAreaTmp)->SERIE   }) //"Serie"

	oReport:HideParamPage() //Define se será permitida a alteração dos parâmetros do relatório
	oReport:SetLandScape()	//Define orientação de página do relatório como paisagem

	if cNmProg == "TAFOBRIG" 	//Desabilita parametros na central de obrigacoes
		oReport:ParamReadOnly() //Parâmetros não poderão ser alterados pelo usuário
	endif

	oReport:DisableOrientation() //Desabilita a seleção da orientação (Retrato/Paisagem)
	oReport:HideFooter()		 //Define que não será impresso o rodapé padrão da página

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

ReportPrint() - Queries para geracao do relatorio

@Param
 oReport  - Objeto relatorio
 dInicial - Data Inicio Competencia Obrigacao
 dFinal   - Data Fim Competencia Obrigacao
 nExib    - Forma de Exibicao do Relatorio
 cAreaTmp - Alias Tabela Temporaria

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport, dInicial, dFinal, nExib, cAreaTmp )

Local oSectionNF  := Nil
Local oTTRel  	  := Nil
Local nOpc		  := 0
Local cAliasRelNF := ""
Local c_EntSai	  := ""
Local c_QueryMT   := ""
Local c_DtAteGia  := ""
Local c_JobAux	  := ""
Local cFltInt013  := "3" //Movimentos
Local cNmProg	  := funname()
Local l_MultThr   := .F.
Local l_TafKey 	  := .F.
Local lFltRnf013  := .F.
Local lRelConfNT  := .T.
Local lProc 	  := .T.
Local a_Thread	  := {}
Local lRelGia	  := .T.
local lJob	  	  := isBlind()

Default dInicial := CtoD("  /  /    ")
Default dFinal 	 := CtoD("  /  /    ")
Default cAreaTmp := ""
Default nExib 	 := 1

if cNmProg == 'TAFR126' .or. lJob

	dInicial := MV_PAR01
	dFinal 	 := MV_PAR02
	nExib	 := MV_PAR03

	lProc := TemRegSFT( DtoS(dInicial), DtoS(dFinal), .T. ) //Verifica se o cliente utiliza o TAF como módulo

	if lProc
		if FWSX6Util():ExistsParam("MV_TAFFPRO")
			PUTMV("MV_TAFFPRO", .T.)
		endif
		lProc := GetNewPar("MV_TAFFPRO", .F.)
	endif
endif

if lProc
	//Monta Estrutura Temporaria
	cAreaTmp := GiaTmpTbl( @oTTRel )
	DbSelectArea( cAreaTmp )
	( cAreaTmp )->(DbSetOrder(1))

	c_EntSai	:= "E"	//Query ERP Entrada
	cAliasRelNF := fQueryPrin( c_EntSai, c_QueryMT, c_DtAteGia, l_TafKey, l_MultThr, a_Thread, c_JobAux, lFltRnf013, cFltInt013, lRelConfNT, DtoS(dInicial), DtoS(dFinal), lRelGia )
	TafTmpTblAtu( cAliasRelNF, cAreaTmp, .T., .F. ) 

	c_EntSai	:= "S"	//Query ERP Saida
	cAliasRelNF := fQueryPrin( c_EntSai, c_QueryMT, c_DtAteGia, l_TafKey, l_MultThr, a_Thread, c_JobAux, lFltRnf013, cFltInt013, lRelConfNT, DtoS(dInicial), DtoS(dFinal), lRelGia )
	TafTmpTblAtu( cAliasRelNF, cAreaTmp, .T., .F. )

	c_EntSai	:= "E"	//Query TAF Entrada
	cAliasRelNF := fQueryTAF( c_EntSai, DtoS(dInicial), DtoS(dFinal) )
	TafTmpTblAtu( cAliasRelNF, cAreaTmp, .F., .T. )
	
	c_EntSai	:= "S"	//Query TAF Saida
	cAliasRelNF := fQueryTAF( c_EntSai, DtoS(dInicial), DtoS(dFinal) )
	TafTmpTblAtu( cAliasRelNF, cAreaTmp, .F., .T. )

	if nExib == 1 //Apenas Divergencias
		cSql := "DELETE FROM " + oTTRel:GetRealName() + " WHERE LADOERP = LADOTAF "	
		nOpc := TcSqlExec(cSql)
	endif

    if nOpc >= 0
		oSectionNF := oReport:Section(1)
		( cAreaTmp )->(DbGoTop())
		While !(cAreaTmp)->(Eof()) .And. !oReport:Cancel()
			oSectionNF:Init()
			oSectionNF:PrintLine()
			(cAreaTmp)->(dbSkip())
		EndDo

		oSectionNF:Finish()

		oSectionNF:SetHeaderPage(.F.)
		oSectionNF:SetHeaderBreak(.F.)
		oSectionNF:SetHeaderSection(.F.)
    EndIF

	//Limpa Estrutura Temporaria
	oTTRel:Delete() //oTTRel:GetRealName()
endif

Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} fQueryTAF

@Param
	cEntSai   - Escopo entrada ou saida
	cDtIniRef - Data inicial do periodo
	cDtFimRef - Data final do periodo
 
@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function fQueryTAF(cEntSai, cDtIniRef, cDtFimRef)

Local cAliasDoc := ""
Local cSelect   := ""
Local cFrom     := ""
Local cWhere    := ""
Local cGroup    := ""
Local cOrder    := ""
Local cIndOpe   := ""

Default cEntSai := ""

cAliasDoc	:= ""
cSelect		:= ""
cFrom   	:= ""
cWhere  	:= ""
cGroup		:= ""
cOrder		:= ""
cIndOpe		:= ""

if cEntSai == 'S'//Saida
	cIndOpe := '1'
else
	cIndOpe := '0'
endif

cAliasDoc := GetNextAlias()

//Notas C/ Tributo
cSelect := " A.C20_FILIAL FILIAL "
cSelect += " ,CAST( CASE WHEN A.C20_INDOPE = '1' THEN 'Saida' ELSE 'Entrada' END as char(7)) TIPOMOV "
cSelect += " ,B.C1H_CODPAR CLIEFOR,A.C20_SERIE SERIE,A.C20_NUMDOC NFISCAL,A.C20_DTES DTES "

cFrom := RetSqlName("C20") + " A "
cFrom += " INNER JOIN " + RetSqlName("C1H") + " B ON B.C1H_FILIAL = '" + xFilial("C1H") + "' AND B.C1H_ID = A.C20_CODPAR AND B.D_E_L_E_T_ = ' ' "
cFrom += " INNER JOIN " + RetSqlName("C30") + " C ON C.C30_FILIAL = A.C20_FILIAL AND C.C30_CHVNF = A.C20_CHVNF AND C.D_E_L_E_T_ = ' ' "
cFrom += " INNER JOIN " + RetSqlName("C35") + " D ON D.C35_FILIAL = C.C30_FILIAL AND D.C35_CHVNF = C.C30_CHVNF AND D.C35_NUMITE = C.C30_NUMITE AND D.C35_CODTRI <> ' ' AND D.D_E_L_E_T_ = ' ' "

cWhere := " A.C20_FILIAL = '" + xFilial("C20") + "' "
cWhere += " AND A.C20_DTES BETWEEN '" + cDtIniRef + "' AND '" + cDtFimRef + "'"
cWhere += " AND A.C20_INDOPE = '" + cIndOpe + "' "
cWhere += " AND A.C20_CODSIT NOT IN ('000003','000004','000005','000006') "
cWhere += " AND A.D_E_L_E_T_ = ' ' "

cGroup := " A.C20_FILIAL,A.C20_INDOPE,B.C1H_CODPAR,A.C20_SERIE,A.C20_NUMDOC,A.C20_DTES "

cOrder := "FILIAL, TIPOMOV, DTES, CLIEFOR, NFISCAL, SERIE"

//+Notas C/ Complemento IPI
cSelect2 := " E.C20_FILIAL FILIAL "
cSelect2 += " ,CAST( CASE WHEN E.C20_INDOPE = '1' THEN 'Saida' ELSE 'Entrada' END as char(7)) TIPOMOV "
cSelect2 += " ,F.C1H_CODPAR CLIEFOR,E.C20_SERIE SERIE,E.C20_NUMDOC NFISCAL,E.C20_DTES DTES "

cFrom2 := RetSqlName("C20") + " E "
cFrom2 += " INNER JOIN " + RetSqlName("C1H") + " F ON F.C1H_FILIAL = '" + xFilial("C1H") + "' AND F.C1H_ID = E.C20_CODPAR AND F.D_E_L_E_T_ = ' ' "
cFrom2 += " INNER JOIN " + RetSqlName('C30') + " G ON G.C30_FILIAL = E.C20_FILIAL AND G.C30_CHVNF = E.C20_CHVNF AND G.D_E_L_E_T_ = ' ' "
cFrom2 += " INNER JOIN " + RetSqlName('C0Y') + " H ON H.C0Y_FILIAL = '" + xFilial("C0Y") + "' AND H.C0Y_ID = G.C30_CFOP AND H.D_E_L_E_T_ = ' ' "

cWhere2 := " E.C20_FILIAL = '" + xFilial("C20") + "' "
cWhere2 += " AND E.C20_DTES BETWEEN '" + cDtIniRef + "' AND '" + cDtFimRef + "' "
cWhere2 += " AND E.C20_TPDOC = '000004' "
cWhere2 += " AND E.C20_INDOPE = '" + cIndOpe + "' "
cWhere2 += " AND E.C20_CODSIT NOT IN ('000003','000004','000005','000006') "  //RETIRADA DAS NOTAS CANCELADAS E INUTILIZADAS
cWhere2 += " AND E.D_E_L_E_T_ = ' ' "

cGroup2 := " E.C20_FILIAL,E.C20_INDOPE,F.C1H_CODPAR,E.C20_SERIE,E.C20_NUMDOC,E.C20_DTES "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"
cGroup	:= "%" + cGroup  + "%"

cSelect2 := "%" + cSelect2 + "%"
cFrom2   := "%" + cFrom2   + "%"
cWhere2  := "%" + cWhere2  + "%"
cGroup2	 := "%" + cGroup2  + "%"

cOrder	:= "%" + cOrder  + "%"

BeginSql Alias cAliasDoc
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	GROUP BY
		%Exp:cGroup%
	UNION
	SELECT
		%Exp:cSelect2%
	FROM
		%Exp:cFrom2%
	WHERE
		%Exp:cWhere2%
	GROUP BY
		%Exp:cGroup2%
	ORDER BY
		%Exp:cOrder%
EndSql

DbSelectArea(cAliasDoc)
(cAliasDoc)->(DbGoTop())

Return cAliasDoc

//--------------------------------------------------------------------------
/*/{Protheus.doc} GiaTmpTbl

Monta Estrutura Temporaria

@Param
	oTTRel - Objeto Tabela Temporaria

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function GiaTmpTbl( oTTRel ) 

	Local cNmTTRel	 := ""
	Local aTTRel 	 := {}
	Local nTamFil	 := 0
	Local nTamDoc	 := 0
	Local nTamSer	 := 0
	Local nTamCliFor := 0

	Default oTTRel := Nil

	cNmTTRel := GetNextAlias()

	nTamFil    := TamSX3( "C20_FILIAL" )[1]
	nTamDoc    := TamSX3( "C20_NUMDOC" )[1]
	nTamSer    := TamSX3( "C20_SERIE" )[1]
	nTamCliFor := TamSX3( "C1H_CODPAR" )[1]
	nTamID 	   := nTamFil + nTamDoc + nTamSer + nTamCliFor + 1 + 1 + 7 + 10

	aTTRel := { {'ID'	  , 'C', nTamID		, 0},;
				{'FIL'	  , 'C', nTamFil	, 0},;
				{'LADOTAF', 'C', 001		, 0},;
				{'LADOERP', 'C', 001		, 0},;
				{'TIPOMOV', 'C', 007		, 0},;
				{'NUMDOC' , 'C', nTamDoc	, 0},;
				{'SERIE'  , 'C', nTamSer	, 0},;
				{'DTES'   , 'C', 010	 	, 0},;
				{'CODPAR' , 'C', nTamCliFor , 0} }

	oTTRel := FWTemporaryTable():New( cNmTTRel, aTTRel )
	oTTRel:AddIndex("1", {"ID"} )
	oTTRel:Create() //oTTRel:getRealName()

Return cNmTTRel

//--------------------------------------------------------------------------
/*/{Protheus.doc} TafTmpTblAtu

Atualiza Tabela Temporaria

@Param
	cAliasRelNF	- Alias Query Executada Lado ERP ou TAF
	cAreaTmp	- Alias Tabela Temporaria
	lERP		- Indica se existe nas tabelas do ERP
	lTAF		- Indica se existe nas tabelas do TAF

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function TafTmpTblAtu( cAliasRelNF, cAreaTmp, lERP, lTAF )

Local cId	  := ""
Local cSeek   := ""
Local cCliFor := ""
Local cTpMov  := ""

Default cAliasRelNF := ""
Default cAreaTmp 	:= ""
Default lERP 		:= .F.
Default lTAF 		:= .F.

if !Empty( cAliasRelNF )

	While !(cAliasRelNF)->(Eof())

		if lERP
			cCliFor := AllTrim((cAliasRelNF)->FOR_CLI ) //F ou C
			cCliFor += AllTrim(StrTran((cAliasRelNF)->CLIEFOR, " ", "")) //Codigo
			cCliFor += AllTrim(StrTran((cAliasRelNF)->LOJA, " ", ""))	 //Loja
		else
			cCliFor := AllTrim(StrTran((cAliasRelNF)->CLIEFOR, " ", ""))
		endif

		cTpMov := AllTrim( (cAliasRelNF)->TIPOMOV )

		cId := AllTrim( (cAliasRelNF)->FILIAL  ) + '|'
		cId += cTpMov					 		 + '|'
		cId += cCliFor 							 + '|'
		cId += AllTrim( (cAliasRelNF)->SERIE   ) + '|'
		cId += AllTrim( (cAliasRelNF)->NFISCAL ) + '|'
		cId += AllTrim( (cAliasRelNF)->DTES    )

		cSeek := !(cAreaTmp)->( DbSeek( cId ) )

		RecLock( cAreaTmp , cSeek)
			(cAreaTmp)->ID  := cId
			(cAreaTmp)->FIL := (cAliasRelNF)->FILIAL
			if cSeek //Inclusao
				(cAreaTmp)->LADOTAF	:= iif( lTAF, 'S', 'N' )
				(cAreaTmp)->LADOERP	:= iif( lERP, 'S', 'N' )
			else
				if lTAF //Alteracap
					(cAreaTmp)->LADOTAF	:= 'S'
				else
					(cAreaTmp)->LADOERP	:= 'S'
				endif
			endif
			(cAreaTmp)->TIPOMOV	:= cTpMov
			(cAreaTmp)->NUMDOC	:= (cAliasRelNF)->NFISCAL
			(cAreaTmp)->SERIE	:= (cAliasRelNF)->SERIE
			(cAreaTmp)->DTES	:= (cAliasRelNF)->DTES
			(cAreaTmp)->CODPAR	:= cCliFor
		(cAreaTmp)->(MsUnlock())

		(cAliasRelNF)->(dbSkip())
	EndDo

	(cAliasRelNF)->(DbCloseArea())
endif

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} TemRegSFT

Existe registro na tabela SFT para o periodo da geracao da obrigacao

@Param
	dInicial - Data inicial do periodo
	dFinal   - Data final do periodo
	lMsg     - Funcao dispara mensagem ?

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function TemRegSFT( dInicial, dFinal, lMsg )

Local lAliasSFT := AliasInDic("SFT")
Local cAlias	:= ""
Local cAliasSFT := ""
Local cSelect  	:= ""
Local cFrom    	:= ""
Local cWhere   	:= ""
Local cTopRow  	:= ""
Local cOrderBy 	:= ""
Local lRet 		:= .T.
Local cBd  	   	:= Alltrim( Upper( TcGetDb( ) ) )

Default dInicial := CtoD("  /  /    ")
Default dFinal	 := CtoD("  /  /    ")
Default lMsg     := .F.

cAlias := GetNextAlias()

if lAliasSFT
	cAliasSFT := RetSqlname('SFT')
	if len( cAliasSFT ) > 3 .And. TCCanOpen( cAliasSFT )
		If cBd $ "ORACLE|DB2|POSTGRES|OPENEDGE|"
			cSelect := " R_E_C_N_O_ "
			If cBd $ "ORACLE|"
				cTopRow := " AND ROWNUM <= 1 "
			ElseIf cBd $ "POSTGRES|"
				cTopRow := " LIMIT 1 "
			Elseif  cBd $ "DB2|"
				cTopRow := " FETCH FIRST 1 ROWS ONLY "
			EndIf
		ElseIf cBd $ "INFORMIX|"
			cSelect := " FIRST 1 SFT.R_E_C_N_O_  "
		ElseIf cBd $ "MSSQL7|"
			cSelect := " TOP 1 R_E_C_N_O_  "
		EndIf

		cFrom  := cAliasSFT + " SFT "

		cWhere := "	SFT.FT_FILIAL = '" + xFilial("SFT") + "' "

		if valtype( dInicial ) == "C" .And. valtype( dfinal ) == "C" .And. !empty( StrTran( dInicial , "/" , "" ) ) .And. !empty( StrTran( dfinal , "/" , "" ) )
			cWhere += "	AND SFT.FT_ENTRADA BETWEEN '" + dInicial + "' AND '" + dFinal + "' AND SFT.D_E_L_E_T_ = ' ' "
		endif

		cOrderBy := " SFT.R_E_C_N_O_ DESC "

		If !(cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
			cWhere  += cTopRow
		Elseif (cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
			cOrderBy += cTopRow
		EndIf

		cSelect  := "%" + cSelect  + "%"
		cFrom	 := "%" + cFrom	   + "%"
		cWhere	 := "%" + cWhere   + "%"
		cOrderBy := "%" + cOrderBy + "%"

		BeginSql Alias cAlias
			SELECT 	 %Exp:cSelect%
			FROM	 %Exp:cFrom%
			WHERE 	 %Exp:cWhere%
			ORDER BY %Exp:cOrderBy%
		EndSql

		//Nao deve ser controlado por existencia de registro na SFT, ja que o relatorio tambem lista as divergencias
		//que foram adicionadas no TAF e no ERP nao. Caso NAO exista registros na SFT ainda assim devera ser gerado o relatorio
		(cAlias)->(DbGoTop())
		If (cAlias)->(!Eof())
			lRet :=	.T.
		Else
			If Upper(FunName()) $ ( "TAFAINTEG|TAFLOAD|TAFA552B" )
				lRet := .F.
			EndIf
		Endif
	else
		lRet := .F.
		if lMsg
			MsgInfo( STR0028 ) //"Não foi possível realizar abertura da tabela SFT. Não será possível prosseguir."
		endif
	endif
else
	lRet := .F.
	if lMsg
		MsgInfo( STR0029 ) //"A tabela SFT não foi encontrada no ambiente. Não será possível prosseguir."
	endif
endif

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} TafStXPend

Existe registro do bloco T013 na tabela TAFST1 ou TAFST2 pendente de processamento 
para o periodo da geracao da obrigacao.

@Param
	dInicial - Data inicial do periodo
	dFinal   - Data final do periodo

@Author Denis Souza
@Since 11/02/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function TafStXPend( dInicial, dFinal, cTab )

Local cBd  	   := Alltrim( Upper( TcGetDb( ) ) )
Local lTafStX  := .F.
Local lRet 	   := .T.
Local cAlias   := ""
Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cTopRow  := ""
Local cOrderBy := ""
Local cFilEnv  := ""

Default dInicial := CtoD("  /  /    ")
Default dFinal 	 := CtoD("  /  /    ")
Default cTab 	 := "TAFST2"

lTafStX := Iif(TCCanOpen( cTab ), .T., .F. )

if lTafStX
	cAlias := GetNextAlias()

	If cBd $ "ORACLE|DB2|POSTGRES|OPENEDGE|"
		cSelect := " R_E_C_N_O_ "
		If cBd $ "ORACLE|"
			cTopRow := " AND ROWNUM <= 1 "
		ElseIf cBd $ "POSTGRES|"
			cTopRow := " LIMIT 1 "
		Elseif  cBd $ "DB2|"
			cTopRow := " FETCH FIRST 1 ROWS ONLY "
		EndIf
	ElseIf cBd $ "INFORMIX|"
		cSelect := " FIRST 1 R_E_C_N_O_  "
	ElseIf cBd $ "MSSQL7|"
		cSelect := " TOP 1 R_E_C_N_O_  "
	EndIf

	cFilEnv := AllTrim(Posicione('C1E',3,xFilial('C1E') + Padr( cFilAnt, TamSX3( "C1E_FILTAF" )[1] ) + "1", 'C1E_CODFIL'))

	cFrom  := cTab
	cWhere := " TAFSTATUS = '1' AND TAFIDTHRD = ' ' AND TAFTPREG = 'T013' "
	cWhere += " AND TAFFIL = '" +  cFilEnv + "' "
	if cTab == "TAFST2"
		cWhere += " AND TAFDATA BETWEEN '" + dInicial + "' AND '" + dFinal + "' "
	endif
	cWhere += " AND D_E_L_E_T_ = ' ' "
	cOrderBy := " R_E_C_N_O_ DESC "

	If !(cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
		cWhere  += cTopRow
	Elseif (cBd $ "|DB2|POSTGRES|" ) .AND. !Empty(cTopRow)
		cOrderBy += cTopRow
	EndIf

	cSelect  := "%" + cSelect  + "%"
	cFrom	 := "%" + cFrom	   + "%"
	cWhere	 := "%" + cWhere   + "%"
	cOrderBy := "%" + cOrderBy + "%"

	BeginSql Alias cAlias
		SELECT 	 %Exp:cSelect%
		FROM	 %Exp:cFrom%
		WHERE 	 %Exp:cWhere%
		ORDER BY %Exp:cOrderBy%
	EndSql

	(cAlias)->(DbGoTop())
	If (cAlias)->(!Eof())
		lRet :=	.F.
	EndIf

	if !lRet
		lRet := MsgYesNo(STR0015) //"Existem notas pendentes de processamento no período informado, deseja prosseguir?"
	endif
endif

Return lRet

//--------------------------------------------------------------------------
/*/{Protheus.doc} TafDimDlg

Tratamento para dimensionar o tamanho final da odlg de acordo com a resolução

@Param
	nColFin
	nLinFin
	nAteLin
	nDlgFin

@Author Denis Souza
@Since 05/05/2020
@Version 1.0
/*/
//---------------------------------------------------------------------------

Static Function TafDimDlg( nColFin, nLinFin, nAteLin, nDlgFin )
	
	Local lRetrato := .F.

	Default nColFin := 0
	Default nLinFin := 0
	Default nAteLin := 0
	Default nDlgFin := 0

	if nLinFin > nColFin
		lRetrato := .T.
	endif

	if lRetrato
		//Monitor Vertical 1080 x 1920
		if nColFin >= 1050 .And. nLinFin >= 1890
			nAteLin := (nColFin*0.55) //largura
			nDlgFin := (nColFin*0.57) //comprimento
		//Monitor Vertical 1050 x 1680
		elseif nColFin >= 800 .And. nLinFin >= 1000
			nAteLin := (nColFin*0.58)
			nDlgFin := (nColFin*0.60)
		//Monitor Vertical 720 x 1280
		elseif nColFin >= 700 .And. nLinFin >= 800
			nAteLin := (nColFin*0.65)
			nDlgFin := (nColFin*0.67)
		//Monitor Vertical 600 x 1280
		elseif nColFin >= 580 .And. nLinFin >= 1000
			nAteLin := (nColFin*0.80)
			nDlgFin := (nColFin*0.85)
		//Monitor Vertical 600 x 800
		else
			nAteLin := (nColFin*0.62)
			nDlgFin := (nColFin*0.64)
		endif
	else //paisagem
		//Monitor Horizontal 1920 x 1080
		if nColFin >= 1720 .And. nLinFin >= 800
			nAteLin := (nColFin*0.23) //largura
			nDlgFin := (nColFin*0.23) //comprimento
		//Monitor Horizontal 1600 x 900
		elseif nColFin >= 1586 .And. nLinFin >= 700
			nAteLin := (nColFin*0.26) //largura
			nDlgFin := (nColFin*0.28) //comprimento
		//Monitor Horizontal 1400 x 1050
		elseif nColFin >= 1366 .And. nLinFin >= 849
			nAteLin := (nColFin*0.30) //largura
			nDlgFin := (nColFin*0.31) //comprimento
		//Monitor Horizontal 1440 x 900
		elseif nColFin >= 1366 .And. nLinFin >= 700
			nAteLin := (nColFin*0.27) //largura
			nDlgFin := (nColFin*0.28) //comprimento
		//Monitor Horizontal 1366 x 768
		elseif nColFin >= 1266 .And. ( nLinFin >= 428 .And. nLinFin < 592  )
			nAteLin := (nColFin*0.27)
			nDlgFin := (nColFin*0.28)
		//Monitor Horizontal 1280 x 768
		elseif nColFin >= 1266 .And. ( nLinFin >= 592 .And. nLinFin < 649  )
			nAteLin := (nColFin*0.28)
			nDlgFin := (nColFin*0.29)
		//Monitor Horizontal 1366 x 768
		elseif nColFin >= 1266 .And. ( nLinFin >= 650 .And. nLinFin < 830  )
			nAteLin := (nColFin*0.31)
			nDlgFin := (nColFin*0.33)
		//Monitor Horizontal 1280 X 1024
		elseif nColFin >= 1266 .And. nLinFin >= 830
			nAteLin := (nColFin*0.33)
			nDlgFin := (nColFin*0.35)
		//Monitor Horizontal 1024 x 768
		elseif nColFin >= 900 .And. nLinFin >= 580
			nAteLin := (nColFin*0.35)
			nDlgFin := (nColFin*0.37)
		//Monitor Horizontal 800 x 600
		Else
			nAteLin := (nColFin*0.40)
			nDlgFin := (nColFin*0.45)
		endif
	endif

Return Nil


/*{Protheus.doc} IntegraERP() -------------------------------------------
Faz a extração e integração dos dados antes de gerar o arquivo da GIA-SP

@Param
	cTicketGia - Ticket gerado na extração dos dados para GIA-SP

@Author Carlos Eduardo N. da Silva
@Since 28/06/2021
@Version 1.0------------------------------------------------------------*/
Static Function IntegraERP(cMsgErro,cTipoInt,dInicial,dFinal)
Local lRet 		 := .t.
Local cTicketGia := ''
Local oQryTmp 	 := Nil
Local lDelChild	 := .f.

Private lCadMov	:= left(cTipoInt,2) == '01' //Variavel usada no fonte FisExtWix_Class quando a origem dos dados for 1-ERP.

//Posiciono no pergunte do Extrator Fiscal
Pergunte( 'FISAEXTJOB' , .f. )

//Mudo os Mvs conforme a necessida da extração
MV_PAR01 := 2 // Periodo Mensal
MV_PAR03 := dInicial
MV_PAR04 := dFinal
MV_PAR05 := 2 // tipo de saída: Banco a Banco
MV_PAR09 := '1'	//Tipo de movimento: 1-Ambos
MV_PAR11 := 'ZZZZZZZZZ'
MV_PAR13 := 'ZZZ'
MV_PAR57 :=	iif( lCadMov , '3' , '2' )  //'2'
MV_PAR58 := '2'

//Cria tabela temporaria
TblNfKey(@oQryTmp)

//Executa a rotina de extração.
FWMsgRun(, {|oSay| FisaExtExc(, oQryTmp:GetRealName()) }, "Processando", "Extraindo dados do ERP...")

//Verifico se obeteve sucesso na extração dos dados.
cTicketGia := GetGlbValue("FISAEXTEXC_TKTEXT")

if VldExtInt(cTicketGia)
	//Baseado nos dados que serão integrados, limpa as tabelas de movimento do TAF caso ja tenham sidos integrados anteriormente.
	TafUpdLote(,,oQryTmp:GetRealName())

	//integra dados extridos com o TAF
	TAFAInteg(/*1*/,2,/*3*/,/*4*/,.f.,/*6*/,'',.t.,/*9*/,/*10*/,cTicketGia,/*12*/,/*13*/,lDelChild)
	
	//Caso não tenha integrado algum layout, da a opcao de abrir o gerenciador de integração.
	if VldExtInt(cTicketGia,.t.) .and. Aviso( 'Integração', 'Alguns layouts não puderam ser integrados, deseja abrir o Gerenciador de Integração?', { 'Sim', 'Não' }, 2 ) = 1
		TAFTicket(.t.)	
	endif
else
	cMsgErro := 'A extração dos dados não pode ser concluída, favor verificar console.log!!!'
	lRet := .f.
endif

//devera ficar ao fim da funcao, pois limpa tb a variavel cTicketGia que esta alocada no mesmo endereco da memoria global.
ClearGlbValue("FISAEXTEXC_TKTEXT")

oQryTmp:Delete()

return lRet


/*{Protheus.doc} ExtratOk(cTicketGia)--------------------------------------
Verifica se existe o ticket passado por parâentro na tabela TAFST2 e se o 
Status é igual a '1'

@Param
	cTicketGia - Ticket gerado na extração dos dados para GIA-SP

@Author Carlos Eduardo N. da Silva
@Since 28/06/2021
@Version 1.0---------------------------------------------------------------*/
Static Function VldExtInt(cTicketGia,lIntegra)
Local lRet 		:= .f.
Local cQuery	:= ''
Local cTable 	:= 'TAFST2'
Local cStatus	:= '1'
Local cAliasQry	:= GetNextAlias()
Default lIntegra := .f.

if lIntegra
	cTable	:= 'TAFXERP'
	cStatus	:= '9'
endif

cQuery := " SELECT COUNT(*) CONT FROM " + cTable
cQuery += "	WHERE D_E_L_E_T_ = ' ' "
cQuery += "		AND TAFTICKET = '" + cTicketGia + "' " 
cQuery += "		AND TAFSTATUS = '" + cStatus + "' "
DBUseArea(.t., 'TOPCONN', TCGenQry(,,cQuery), cAliasQry , .f., .t. )

lRet := (cAliasQry)->CONT > 0
(cAliasQry)->(DbCloseArea())

return lRet

/*{Protheus.doc} TblNfKey(cAlias)--------------------------------------
Cria tabela temporária para guardar informações da nota fiscal que serão
extraidas

@Param
	oQryTmp - Objeto da tabela temporaria

@Author Carlos Eduardo N. da Silva
@Since 01/07/2021
@Version 1.0---------------------------------------------------------------*/
Static Function TblNfKey(oQryTmp)
Local lRet 		:= .f.
Local aStruct := {{'FILIAL' , GetSx3Cache('C20_FILIAL','X3_TIPO'), GetSx3Cache('C20_FILIAL','X3_TAMANHO'), GetSx3Cache('C20_FILIAL','X3_DECIMAL')},;			      
                  {'CODMOD' , GetSx3Cache('C20_CODMOD','X3_TIPO'), GetSx3Cache('C20_CODMOD','X3_TAMANHO'), GetSx3Cache('C20_CODMOD','X3_DECIMAL')},;
                  {'INDOPE' , GetSx3Cache('C20_INDOPE','X3_TIPO'), GetSx3Cache('C20_INDOPE','X3_TAMANHO'), GetSx3Cache('C20_INDOPE','X3_DECIMAL')},;
			      {'TPDOC'  , GetSx3Cache('C20_TPDOC' ,'X3_TIPO'), GetSx3Cache('C20_TPDOC' ,'X3_TAMANHO'), GetSx3Cache('C20_TPDOC' ,'X3_DECIMAL')},;
                  {'INDEMI' , GetSx3Cache('C20_INDEMI','X3_TIPO'), GetSx3Cache('C20_INDEMI','X3_TAMANHO'), GetSx3Cache('C20_INDEMI','X3_DECIMAL')},;
                  {'CODPAR' , GetSx3Cache('C20_CODPAR','X3_TIPO'), GetSx3Cache('C20_CODPAR','X3_TAMANHO'), GetSx3Cache('C20_CODPAR','X3_DECIMAL')},;
                  {'CODSIT' , GetSx3Cache('C20_CODSIT','X3_TIPO'), GetSx3Cache('C20_CODSIT','X3_TAMANHO'), GetSx3Cache('C20_CODSIT','X3_DECIMAL')},;
                  {'SERIE'  , GetSx3Cache('C20_SERIE' ,'X3_TIPO'), GetSx3Cache('C20_SERIE' ,'X3_TAMANHO'), GetSx3Cache('C20_SERIE' ,'X3_DECIMAL')},;
                  {'SUBSER' , GetSx3Cache('C20_SUBSER','X3_TIPO'), GetSx3Cache('C20_SUBSER','X3_TAMANHO'), GetSx3Cache('C20_SUBSER','X3_DECIMAL')},;
                  {'NUMDOC' , GetSx3Cache('C20_NUMDOC','X3_TIPO'), GetSx3Cache('C20_NUMDOC','X3_TAMANHO'), GetSx3Cache('C20_NUMDOC','X3_DECIMAL')},;
                  {'DTDOC'  , GetSx3Cache('C20_DTDOC' ,'X3_TIPO'), GetSx3Cache('C20_DTDOC' ,'X3_TAMANHO'), GetSx3Cache('C20_DTDOC' ,'X3_DECIMAL')},;
                  {'DTES'   , GetSx3Cache('C20_DTES'  ,'X3_TIPO'), GetSx3Cache('C20_DTES'  ,'X3_TAMANHO'), GetSx3Cache('C20_DTES'  ,'X3_DECIMAL')} }

oQryTmp := FWTemporaryTable():New(,aStruct)
oQryTmp:AddIndex('1', {'FILIAL','CODMOD','INDOPE','TPDOC','INDEMI','CODPAR','CODSIT','SERIE','SUBSER','NUMDOC','DTDOC','DTES'} )
oQryTmp:Create()

return lRet

//------------------------------------------------------------------------------------
/*/{Protheus.doc} TR126FIM
Apresenta mensagem de descontinuação do relatório TAFR126 
@type			Function
@author			Jose Felipe
@since			23/05/2024
@version		1.0
/*/
//------------------------------------------------------------------------------------
Static Function TR126FIM()

	Local cButton		:= ""
	Local cMsg  		:= ""
	Local oModal 		:= Nil
	Local oContainer 	:= Nil
	Local oBtn1			:= Nil
	Local oBtn2			:= Nil
	Local oFontButtons  := Nil
	Local oFontSub		:= Nil
	Local oSay			:= Nil
	Local oFont			:= Nil

	oFontSub 				:= TFont():New('Arial',, -16, .T.)
	oFontButtons 			:= TFont():New('Arial',, -16, .T.)
	oFontButtons:Underline 	:= .T.
	oFontButtons:Bold 		:= .T.

	oModal := FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0030) 																						// "Utilize o Smart View"
	oModal:SetSize(190, 400)
	oModal:CreateDialog()

	oFont := TFont():New('Courier new',, -18, .T.)

	cMsg := '<div align="justify">'
	cMsg += '	<br>' + STR0031 + '</br>'																		// "Prezado cliente, temos este relatório disponível em Smart View."

	cMsg 	+= '	<p>' + STR0032 + '</b></p>' 																// "Para consultar documentos divergentes e outras informações de maneira clara e detalhada, utilize o Smart View. Simplifique sua análise e obtenha insights mais precisos com essa ferramenta eficiente e intuitiva!"

	cButton := STR0033																							// "Estou Ciente"
	cMsg 	+= '	<p>' + STR0034 + ' <b>' + STR0035 + '</b>. '												// "Este relatório será descontinuado a partir da release: " / 12.1.2510					
	
	cMsg += '	<p>' + STR0036 + '</p>' 																		// "Clique nos links abaixo e saiba mais!"
	cMsg += '</div>'

	oModal:addCloseButton(Nil, cButton)

	oFont 	:= TFont():New('Courier new',, -22, .T.)

	oSay	:= TSay():New(30, 15, {|| cMsg },,, oFontSub,,,, .T.,,, 350, 130,,,,,, .T.)

	oBtn1 	:= THButton():New(140, 10, STR0037, oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com/display/PROT/Smart+View+-+TAF", "", "C:\", 1)}, 150, 20,oFontButtons, STR0037 )					// "Como configurar o Smart View?"
	oBtn2 	:= THButton():New(140, 180, STR0038, oContainer, {|| ShellExecute("Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=761504177", "", "C:\", 1 )}, 215, 20, oFontButtons, STR0038)		// "Como utilizar a conferência de documentos integrados?"
		
	oBtn1:SetCss("QPushButton{ color: #21a4c4; }")
	oBtn2:SetCss("QPushButton{ color: #21a4c4; }")

	oModal:Activate()

Return
