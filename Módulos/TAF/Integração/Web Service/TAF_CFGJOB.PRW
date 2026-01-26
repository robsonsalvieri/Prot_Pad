#INCLUDE  "TOTVS.CH" 

#DEFINE JOBNAME 		01
#DEFINE SECAOAPPSERVER 	02
#DEFINE UIIDFILIAIS 	03
#DEFINE KEYFILIAIS 		04

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAF_CFGJOB 

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Main Function TAF_CFGJOB()

	Local aEmpresas    as array
	Local aInstances   as array
	Local aVarsCfg     as array
	Local cArqAppSrv   as character
	Local cAuxJobName  as character
	Local cChaveFil    as character
	Local cInstances   as character
	Local cJobName     as character
	Local cSecao       as character
	Local cUUIDFil     as character
	Local nInc         as numeric
	Local nMax         as numeric
	Local nMin         as numeric
	Local nMinFree     as numeric
	Local nRefreshRate as numeric
	Local nX           as numeric

	aVarsCfg := TAFCfgJVarsFil()

	cJobName   := aVarsCfg[JOBNAME] 		//"TAF_ACCEPT"
	cSecao	   := aVarsCfg[SECAOAPPSERVER]  //"TAF_CFGJOB"
	cUUIDFil   := aVarsCfg[UIIDFILIAIS] 	//"tafJobID"
	cChaveFil  := aVarsCfg[KEYFILIAIS] 		//"keyTafJob"

	cArqAppSrv := getAdv97()

	cInstances := getPvProfString(cSecao,'Instances','',cArqAppSrv)

	If Empty(AllTrim(cInstances))
		cInstances := getPvProfString('HTTPURI','Instances','',cArqAppSrv)
	EndIf 

	aInstances := StrTokArr(cInstances,",")
	
	nMin 		:= IIf(Len(aInstances) > 0,Val(aInstances[1]),1)
	nMax 		:= IIf(Len(aInstances) > 1,Val(aInstances[2]),1)
	nMinFree 	:= IIf(Len(aInstances) > 2,Val(aInstances[3]),0)
	nInc 		:= IIf(Len(aInstances) > 3,Val(aInstances[4]),0)
	nRefreshRate := Val(getPvProfString( cSecao , 'RefreshRate' , '' , cArqAppSrv ))

	If VarSetUID(cUUIDFil) 

		ConOut("[TAF_CFGJOB] Criando Secao para cache de filiais ...")

		If VarBeginT(cUUIDFil, cChaveFil)

			TAFGetDePara(cUUIDFil,cChaveFil)

			If VarEndT(cUUIDFil, cChaveFil)
				ConOut("[TAF_CFGJOB] Encerrando transacao da secao " + cUUIDFil + " chave " +  cChaveFil)
			Else
				ConOut("[TAF_CFGJOB][ERROR] Erro no encerramento da transacao da secao " + cUUIDFil +  " chave " +  cChaveFil)
			EndIf 

			aEmpresas := {}
			VarGetA(cUUIDFil,cChaveFil, @aEmpresas)

			If Len(aEmpresas) > 0

				For nX := 1 To Len(aEmpresas)
					
					cAuxJobName := cJobName + "_" + aEmpresas[nX][1]
					
					ConOut("ManualJob " + cAuxJobName)
					
					ManualJob(cAuxJobName,;
							  GetEnvServer(),;
							  "IPC"/*Type*/,;
							  "TAF_START"/*OnStart*/,;
							  "TAF_CONNECT"/*OnConnect*/,;
							  ""/*OnExit*/,;
							  aEmpresas[nX][1],;
							  nRefreshRate,;
							  nMin,;
							  nMax,;
							  nMinFree,;
							  nInc)

				Next nX 

			Else

				ConOut("[TAF_CFGJOB][ERROR]Não encontrado empresas para inicialização do Job " + cJobName)
				ConOut("Verifique seu arquivo de empresas e a chave PrepareIn na secao " + cSecao)


			EndIf

		Else

			ConOut("[TAF_CFGJOB][ERROR] Não foi possivel Transacionar a chave " + cChaveFil + " no identificador de secao " + cUUIDFil)

		EndIf

	EndIf
	
Return Nil 

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAF_START 
Função executada na abertura do TAF_ACCEPT

@param cEmpresa - Codigo da Empresa para preparação do Ambiente

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAF_START(cEmpresa)

	Local cUUIDFil  
	Local cChaveFil 
	Local aVarsCfg

	Default cEmpresa	:= ""

	aVarsCfg := TAFCfgJVarsFil()

	cUUIDFil   := aVarsCfg[UIIDFILIAIS] //"tafJobID"
	cChaveFil  := aVarsCfg[KEYFILIAIS]  //"keyTafJob"

	If !Empty(cEmpresa)

		ConOut( "[TAF_CFGJOB][TAF_START] Starting JobTafWS - Group Company: " + cEmpresa + " - Thread: " + allTrim( str( ThreadId() ) ) )

		RpcSetType( 3 )
		RpcSetEnv(cEmpresa,,,,"TAF","TAF_CFGJOB",,,,.T.,)

		ConOut( "[TAF_CFGJOB][TAF_START] Started [RpcSetEnv] JobTafWS - Group Company: " + cEmpresa + " - Thread: " +  allTrim( str( ThreadId() ) ) + " - Data: " + DTOC(dDataBase)+ " - Hora: " + Time())

	Else
		ConOut("[TAF_CFGJOB][TAF_START][ERROR] Não localizado a empresa na chave " + cChaveFil)
	EndIf 

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAF_CONNECT 
Função de conexão com as threads criadas pela função TAF_START sob custódia do 
TAF_CFGJOB.

@cFunction - Nome da Função que a cFuncIPC irá executar
@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do WSREST (Header)
@cBody - Mensagem enviada no Body dos métodos WSREST (body)
@cParN - Parametros livres para passagem de parâmetros especificos da 
função.

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAF_CONNECT(cFunction,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5 )

	Local oBlock 

	Default aQryParam := {}
	Default cChave := ""
	Default cBody := ""
	Default cValorR := ""
	
	oBlock := Nil

    ConOut("[TAF_CFGJOB][TAF_CONNECT] Started IPCGo [InitializeProcess]")
	lRet := VarBeginT(cUId,cChave)
	lRet := VarSetXD(cUId,cChave,1)
	
	oBlock := ErrorBlock( { |e|jobCfgErro(e) , TAFFinishWS( cChave , cUId , cValorR , {} , 9 )  } )
	
	BEGIN SEQUENCE
	    ConOut("[TAF_CFGJOB][TAF_CONNECT] Calling " + cFunction + "- TAF_Connect")
		&cFunction.(cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)
	RECOVER
	    TAFFinishWS( cChave , cUId , cValorR , {} , 9 )
	END SEQUENCE
	
	ErrorBlock( oBlock )	

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAF_MTESOCIAL

Função de conexão com as threads criadas pela função TAF_START sob custódia do TAF_CFGJOB.

@param cFuncInteg	-	Nome da Função que a IPC irá executar
@param cFilsErp		-	Código das Filiais do ERP
@param cFilTAF		-	Código de Filial do TAF
@param cIDThread	-	Identificador da Thread ( customizado )
@param cParN		-	Parâmetros livres para passagem de parâmetros específicos da função

@author		Felipe C. Seolin
@since		02/08/2018
@version	1.0
/*/
//--------------------------------------------------------------------------- 
Function TAF_MTESOCIAL( cFuncInteg, cFilsErp, cFilAnt, cIDThread, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7 )

Local oBlock	:=	Nil

ConOut( "[TAF_CFGJOB][TAF_MTESOCIAL] Started IPCGo [InitializeProcess]" )

oBlock := ErrorBlock( { |x| ConOut( "[TAF_CFGJOB][TAF_MTESOCIAL][ERROR] " + Chr( 10 ) + x:Description + Chr( 10 ) + x:ErrorStack ) } )

BEGIN SEQUENCE
	ConOut( "[TAF_CFGJOB][TAF_MTESOCIAL] Calling " + cFuncInteg + "- TAF_MTESOCIAL" )
	&cFuncInteg.( cFilsErp, cFilAnt, cIDThread, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7 )
END SEQUENCE

ErrorBlock( oBlock )

Return( .T. )

//----------------------------------------------------------------------------
/*/{Protheus.doc} jobCfgErro 
Função executada pelo ErrorBlock da função TAF_CONNECT.

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function jobCfgErro(e)
	conOut( '[TAF_CFGJOB][TAF_CONNECT][ERROR] ' + Chr(10)+ e:Description + Chr(10)+ e:ErrorStack)
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFCALLIPC 
Executa o IPCGo nas Theads criadas pelo Job TAF_CFGJOB.

@cFuncIPC	- Nome da função(Job) para execução do IPGGo (pool de Jobs)
@cFuncREST - Nome da Função que a cFuncIPC irá executar
@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do WSREST (Header)
@cBody - Mensagem enviada no Body dos métodos WSREST (body)
@cParN - Parametros livres para passagem de parâmetros especificos da 
função.

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)

	Local nTry		
	Local nVal 		
	Local lIPCGo 	

	Default aQryParam := {}
	Default cBody := ""
	
	nTry := 0
	lIPCGo := .F.

	ConOut("[TAF_CFGJOB][TAFCALLIPC] Calling IPCGo - " + cFuncREST )
	
	While !IPCGo(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)
		If nTry <= 150
			Sleep(nTry * 1000)
			ConOut("[TAF_CFGJOB][TAFCALLIPC] Aguardando thread disponivel - " + cFuncREST )
			nTry++
		Else
			Exit 
		EndIf
	Enddo
	
	lIPCGo := IIf(nTry <= 150,.T.,.F.)
	nTry := 0
	ConOut( "[TAF_CFGJOB][TAFCALLIPC] Waiting IPCGo - " + cFuncREST)
	lRet := .F.

	If lIPCGo
		While(lRet == .F.)
			
			lRet := VarGetXD(cUId,cChave,@nVal)
				
			If nTry >= 150
				TAFFinishWS(cChave,cUId,'',{},9)
				Exit
			Endif
			
			If checkBeginCall(lRet,@nTry) 		
				lRet := checkEndCall(cUId,cChave,@nTry)
			EndIf
		End
	Else
		ConOut( "[TAF_CFGJOB][TAFCALLIPC][ERROR] IPCGo - " + cFuncREST + " - TimeOut - Nao ha Threads disponiveis.")
	EndIf 

	ConOut( "[TAF_CFGJOB][TAFCALLIPC] Finished IPCGo - " + cFuncREST)
	
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFSCALLIPC 
Executa o IPCGo nas Theads criadas pelo Job TAF_CFGJOB e não espera a função 
terminar. (não segura a thread)

@cFuncIPC	- Nome da função(Job) para execução do IPGGo (pool de Jobs)
@cFuncREST - Nome da Função que a cFuncIPC irá executar
@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do WSREST (Header)
@cBody - Mensagem enviada no Body dos métodos WSREST (body)
@cParN - Parametros livres para passagem de parâmetros especificos da 
função

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--
Function TAFSCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)

	Local nTry			
	Local lIPCGo 	

	Default aQryParam := {}
	Default cBody := ""
	
	nTry := 0
	lIPCGo := .F.

	ConOut("[TAF_CFGJOB][TAFCALLIPC] Calling IPCGo - " + cFuncREST )
	
	While !IPCGo(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)
		If nTry <= 150
			Sleep(nTry * 1000)
			ConOut("[TAF_CFGJOB][TAFCALLIPC] Aguardando thread disponivel - " + cFuncREST )
			nTry++
		Else
			Exit 
		EndIf
	Enddo
	
	lRet := IIf(nTry <= 150,.T.,.F.)

	ConOut( "[TAF_CFGJOB][TAFCALLIPC] Finished IPCGo - " + cFuncREST)
	
Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFSPCALLIPC

Executa o IPCGo nas threads criadas pelo job TAF_CFGJOB e não espera a função terminar ( Não segura a thread )
Não possui os parâmetros obrigatórios utilizados no REST.

@param cFuncIPC		-	Nome da função ( Job ) para execução do IPGGo ( Pool de Jobs )
@param cFuncInteg	-	Nome da Função que a IPC irá executar
@param cFilsErp		-	Código das Filiais do ERP
@param cFilTAF		-	Código de Filial do TAF
@param cIDThread	-	Identificador da Thread ( customizado )
@param cParN		-	Parâmetros livres para passagem de parâmetros específicos da função

@author		Evandro dos Santos O. Teixeira
@since		29/05/2017
@version	1.0
/*/
//--
Function TAFSPCALLIPC( cFuncIPC, cFuncInteg, cFilsErp, cFilAnt, cIDThread, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7 )

Local nTry	:=	0
Local lRet	:=	.T.

ConOut( "[TAF_CFGJOB][TAFSPCALLIPC] Calling IPCGo - " + cFuncInteg )

While !IPCGo( cFuncIPC, cFuncInteg, cFilsErp, cFilAnt, cIDThread, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7 )
	If nTry <= 150
		Sleep( nTry * 1000 )
		ConOut( "[TAF_CFGJOB][TAFSPCALLIPC] Aguardando thread disponivel - " + cFuncInteg )
		nTry ++
	Else
		Exit
	EndIf
EndDo

lRet := Iif( nTry <= 150, .T., .F. )

ConOut( "[TAF_CFGJOB][TAFSPCALLIPC] Finished IPCGo - " + cFuncInteg )

Return( lRet )

//----------------------------------------------------------------------------
/*/{Protheus.doc} checkEndCall 
Verifica se o processamento do Job em execução foi Finalizada.
obs. A utilização do VarBeginT é para verificar se a seção (cUId) teve a transação
finalizada.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap.
@nTry - Numero de verificações de finalização do Job.

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function checkEndCall(cUId,cChave,nTry)

	Local nVal 
	Local lRetEnd 
		
	lRetEnd := .F.
	nVal := 0
	
	lRetEnd :=  VarBeginT(cUId,cChave) .and. VarGetXD(cUId,cChave,@nVal) .and. ( nVal == 3 .or. nVal == 9 )
	
	If !lRetEnd
		Sleep(100)
		nTry++
	Else
		nTry := 0
	EndIf

Return lRetEnd

//----------------------------------------------------------------------------
/*/{Protheus.doc} checkBeginCall 
Verifica se o Job foi iniciado, caso contratio soma +1 em nTry

@lRetGet - Retorno da função VarGetXD (verifica se houve inserção de conteudo
na varialve nVal)
@nTry - Numero de verificações de inicio do Job.

@author Evandro dos Santos O. Teixeira
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function checkBeginCall(lRetGet,nTry)
	If !lRetGet
		Sleep(100)
		nTry++
	Else 
		nTry := 0
	Endif
Return (lRetGet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFFinishWS 
Seta os valores de retorno e de finalização do Job

@cChave - Identificador da chave (tabela X) HashMap
@cUId	- Identificador da sessão de Variáveis Globais.
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aRetorno - Array de Retorno para a Thread principal.
@nVal - Valor de estado com o estado da chave (cChave).
1 - Job Iniciado
3 - Job Finalizado
9 - Encerramento em virtude de Erros

@author Luccas Curcio
@since 29/05/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFFinishWS( cChave, cUId , cValorR , aRetorno , nVal)

	Local lRet 

	lRet := VarSetAD( cUId , cValorR , aRetorno )
	lRet := VarSetXD( cUId , cChave , nVal )
	lRet := VarEndT( cUId , cChave )

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFGetDePara 
Cria Array de De/Para de Filias TAF x ERP considerando todas as 
empresas/grupos.

@param cUUIDFil  	-> Identificador da seção
@param cChaveFil 	-> Chave utilizada na variavel.
@param lIgnoreProf 	-> Igora a chave secao TAF_CFGJOB seçao PrepareIn
@param lNoPrepEnv 	-> Nao prepara o ambiente para a obtencao das filiais

@Return Nil 

@author Evandro dos Santos O. Teixeira
@since 13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFGetDePara( cUUIDFil as character, cChaveFil as character, lIgnoreProf as logical, lNoPrepEnv as logical )

	Local aDePara   as array
	Local aEmpsProf as array
	Local aEmpsSM0  as array
	Local aSM0      as array
	Local cCNPJ     as character
	Local cCodEmp   as character
	Local cComp     as character
	Local cEmpPos   as character
	Local cModoC1E  as character
	Local cModoCR9  as character
	Local cNomeEmp  as character
	Local cSeekCR9  as character
	Local nIndCR9   as numeric
	Local nX        as numeric

	Default lIgnoreProf := .F.
	Default lNoPrepEnv 	:= .F.

	ConOut("Verificando De/Para de Filiais ...")

	aDePara   := {}
	aEmpsProf := {}
	aEmpsSM0  := TafGetEmps()
	aSM0      := {}
	cCNPJ     := ""
	cCodEmp   := ""
	cComp     := ""
	cEmpPos   := ""
	cModoC1E  := ""
	cModoCR9  := ""
	cNomeEmp  := ""
	cSeekCR9  := ""
	nIndCR9   := 0
	nIndCR9   := 0
	nX        := 0

	If lIgnoreProf 
		aEmpsProf :=  aClone(aEmpsSM0)
	Else
		aEmpsProf := TafGetProfEmp(aEmpsSM0) 
	EndIf 

	If Len(aEmpsProf) > 0

		cEmpPos := aEmpsProf[1][1]

		If !lNoPrepEnv
			RpcSetType( 3 )
			RpcSetEnv(cEmpPos,,,,"TAF","TAF_CFGJOB",,,,.T.,)
		EndIf 

		If cPaisLoc == "BRA"

			For nX := 1 To Len(aEmpsProf)

				cCodEmp  := aEmpsProf[nX][1]
				cNomeEmp := aEmpsProf[nX][2]

				aAdd(aDePara,{cCodEmp,{},cNomeEmp})

				If cCodEmp != cEmpPos

					EmpOpenFile("C1E","C1E",1,.T.,cCodEmp, @cModoC1E )

					If TafIndexInDic("CR9", 4, .F.)
						EmpOpenFile("CR9","CR9",4,.T.,cCodEmp, @cModoCR9 )
					Else
						EmpOpenFile("CR9","CR9",3,.T.,cCodEmp, @cModoCR9 )
					EndIf 

				Else

					dbSelectArea("C1E")
					C1E->(dbSetOrder(1))

					//Verifica existencia do indice 4 na tabela CR9
					If TafIndexInDic("CR9", 4, .F.)
						nIndCR9 := 4
					Else
						nIndCR9 := 3
					EndIf

					dbSelectArea("CR9")
					CR9->(dbSetOrder(nIndCR9))

				EndIf

				aSM0 := FWLoadSM0()

				/*+--------------------------------------------------------------+
				| Estrutura do Array de De/Para:  		 				   	   |
				|											                   |
				| aDePara[n] - Array						                   |
				| aDePara[n][1] - Empresa     			                   	   |	
				| aDePara[n][2] - Array					                       |
				| aDePara[n][2][n][1] - Filial ERP  		                   |
				| aDePara[n][2][n][2] - Filial TAF		                       |	
				| aDePara[n][2][n][3] - CNPJ da Filial	                       |	
				| aDePara[n][3] - Nome da Empresa/Grupo						   |
				+--------------------------------------------------------------+*/

				While C1E->(!Eof())

					If !Deleted() .And. C1E->C1E_ATIVO == "1"
				
						cCNPJ := getCNPJbyFil(aSM0,C1E->C1E_FILTAF)
						aAdd(Atail(aDePara)[2],{AllTrim(C1E->C1E_CODFIL),C1E->C1E_FILTAF,cCNPJ})

						If nIndCR9 == 4

							cSeekCR9 := xFilial("CR9") + C1E->C1E_ID +  C1E->C1E_VERSAO
							cComp := "C1E->C1E_ID+C1E->C1E_VERSAO == CR9->CR9_ID+CR9->CR9_VERSAO"

						ElseIf nIndCR9 == 3

							cSeekCR9 := xFilial("CR9") + C1E->C1E_ID + "1"
							cComp := "C1E->C1E_ID == CR9->CR9_ID"

						EndIf

						If CR9->(MsSeek( cSeekCR9 ))

							While CR9->(!Eof()) .And. &(cComp)
								aAdd(Atail(aDePara)[2],{AllTrim(CR9->CR9_CODFIL),C1E->C1E_FILTAF,cCNPJ})
								CR9->(dbSkip())
							EndDo

						EndIf

					EndIf 

					C1E->(dbSkip())

				EndDo
				
				C1E->(dbCloseArea())

			Next nX

		Else

			ConOut("[TAF_CFGJOB][ERROR] A funcao TAFGetDePara so pode ser executada no pais Brasil.")

		EndIf

		If VarSetAD(cUUIDFil, cChaveFil, aDePara)
			ConOut("[TAF_CFGJOB] Gravado filias com sucesso na secao: " + cUUIDFil + " chave "+ cChaveFil + ".")
		Else	
			ConOut("[TAF_CFGJOB][ERROR] Erro na gravacao das filias de De/Para")
		EndIf

	Else
		ConOut("[TAF_CFGJOB][ERROR] A chave PrepareIn nao foi preenchida na secao TAF_CFGJOB.")	
	EndIf

	aSize(aEmpsSM0,0)
	aEmpsSM0 := Nil 

	aSize(aEmpsProf,0)
	aEmpsProf := Nil 

Return Nil 

//----------------------------------------------------------------------------
/*/{Protheus.doc} getCNPJbyFil 

@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function getCNPJbyFil(aSM0,cFilTaf)

	Local nPosSM0   := 0
	Local cCNPJ 	:= ""

	Default aSM0 := FWLoadSM0()
	Default cFilTaf := ""

	nPosSM0 := aScan(aSM0,{|emp|AllTrim(emp[2]) == AllTrim(cFilTaf)}) //[2] == SM0_CODFIL
	If nPosSM0 > 0
		cCnpj := AllTrim(aSM0[nPosSM0][18]) //[18] == SM0_CGC
	EndIf 

Return cCnpj

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafGetProfEmp 
Retorna as Empresas informadas na chave PrepareIn na seção TAF_CFGJOB
validando se as mesmas existem no arquivo de empresa.

@param aEmpsSM0    -> Empresas contidas na SM0
@param lForceProf  -> Retorna todas as empresas do profile sem fazer a 
validação no arquivo de empresas.

@Return aEmpsVlds -> Array com os codigos das empresas/grupos

@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TafGetProfEmp(aEmpsSM0,lForceProf) 

	Local cSecao 		
	Local cArqAppSrv	
	Local cEmpsFile		
	Local aEmpsProf		
	Local aEmpsVlds		
	Local nX			
	Local nPosEmp	
	Local aVarsCfg	

	Default aEmpsSM0 := {}
	Default lForceProf  := .F.

	aVarsCfg := TAFCfgJVarsFil()

	cSecao	 	:= aVarsCfg[SECAOAPPSERVER] //"TAF_CFGJOB"
	cArqAppSrv	:= getAdv97()
	cEmpsFile 	:= getPvProfString( cSecao , 'PrepareIn' , '' , cArqAppSrv )
	aEmpsVlds	:= {}
	aEmpsProf   := {}

	//Quando a chave PrepareIn for igual a ALL não preciso validar por que já pego as empresas do sigamat
	If Upper(cEmpsFile) == "ALL"
		aEmpsVlds :=  aClone(aEmpsSM0)
	Else

		If lForceProf
			aEmpsVlds := StrTokArr2(cEmpsFile,",")
		Else

			aEmpsProf := StrTokArr2(cEmpsFile,",")

			For nX := 1 To Len(aEmpsProf)
				
				nPosEmp := aScan(aEmpsSM0,{|emp|AllTrim(emp[1]) == AllTrim(aEmpsProf[nX])})
				If nPosEmp > 0
					aAdd(aEmpsVlds,{AllTrim(aEmpsProf[nX]),aEmpsSM0[nPosEmp][2]})
				Else
					ConOut("[TAF_CFGJOB][WARN] Empresa " + AllTrim(aEmpsProf[nX]) + " Informada na chave PrepareIn da secao " + cSecao + " nao existe no arquivo de empresas.")
				EndIf

			Next nX
		Endif
	EndIf

	aSize(aEmpsProf,0)
	aEmpsProf := Nil 

Return (aEmpsVlds)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafEmpInProf 
Verifica se a Empresa/Grupo do TAF está contida no vetor de Empresas.

@param aEmpsProf -> Array com as empresas contidas no profile.
@param cEmpTaf - Empresa/Grupo do Taf a ser verificada

@author Evandro dos Santos O. Teixeira
@since 13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TafEmpInProf(aEmpsProf,cEmpTaf)

	Local lExist := .F.
	Local nPosEmp := 0

	nPosEmp := aScan(aEmpsProf,{|emp|AllTrim(emp) == cEmpTaf})
	lExist := IIf(nPosEmp > 0,.T.,.F.)

Return lExist

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafGetEmps 
Retorna array com os codigos das empresas ou grupos de empresas contidos na 
SM0

@author Evandro dos Santos O. Teixeira
@since 13/12/2017
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TafGetEmps()

	Local aEmpsRet 	:= {}
	Local nPosEmp 	:= 0

	OpenSm0(,.T.)

	SM0->(dbGoTop())

	While SM0->(!Eof())
		
		If !Deleted()
			nPosEmp := 0
			
			If Len(aEmpsRet) > 0
				nPosEmp := aScan(aEmpsRet,{|x|AllTrim(x[1]) ==  AllTrim(SM0->M0_CODIGO) })
			EndIf

			//Verifico se a empresa não existe no array de retorno.
			If nPosEmp == 0
				aAdd(aEmpsRet,{AllTrim(SM0->M0_CODIGO),AllTrim(SM0->M0_NOME)})
				ConOut("[TAF_CFGJOB][INFO] Grupo localizado no arquivo de empresa: " + AllTrim(SM0->M0_CODIGO))
			EndIf
		EndIf

		SM0->(dbSkip())
	EndDo

Return (aEmpsRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFCfgJVarsFil 
Retorna Variáveis públicas(HashMap) utilizadas para armazenamento das filiais
e demais variáveis relativas ao Job utilizado no processamento. 

@return [1] - JobName - Nome do semáforo utilizado no ManualJob
		[2] - Seção	  - Nome da seção no arquivo appserver.ini que indica
		as chaves a serem utilizadas no ManualJob
		[3] - UUid da seção criada para as variáveis HashMap (VarSetUID)
		[4] - Chave utilizada para gravação e retorno das filiais (chave 
		tabela X, filiais tabela A)

@author Evandro dos Santos O. Teixeira
@since 09/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFCfgJVarsFil()
Return {"TAF_ACCEPT","TAF_CFGJOB","tafJobID","keyTafJob"}
