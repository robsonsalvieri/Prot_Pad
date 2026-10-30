#INCLUDE "TOTVS.CH"

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAF_TSI - TAF SERVICE INTEGRATION

Disponibiliza seviço de threads para serem utilizados na integração do
ERP com o TAF Fiscal

[OnStart]
RefreshRate=120
JOBS=TAF_TSI

[TAF_TSI]
MAIN=TAF_TSI
Instances=3,3,1,1
PrepareIn=ALL
Environment=V12127
RefreshRate=30

@author Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 

Main Function TAF_TSI()

	Local cJobName
	Local cSecao
	Local cInstances
	Local cArqAppSrv
	Local cUUIDFil
	Local cChaveFil
	Local cAuxJobName

	Local nMin
	Local nMax
	Local nMinFree
	Local nInc
	Local nRefreshRate
	Local nX
	Local nValLock
	Local aInstances
	Local aEmpresas

	cJobName   := "TSI_ACCEPT"
	cSecao	   := "TAF_TSI"
	cUUIDFil   := "TSIJobID" //Identificador da sessão de Variáveis Globais
	cChaveFil  := "keyTSIJob"
	cArqAppSrv := getAdv97() //"APPSERVER.INI"
	cInstances := getPvProfString(cSecao,'Instances','',cArqAppSrv) //"6,6,1,1"
	aInstances := StrTokArr(cInstances,",")

	nMin 	 := IIf(Len(aInstances) > 0,Val(aInstances[1]),1) //6
	nMax 	 := IIf(Len(aInstances) > 1,Val(aInstances[2]),1) //6
	nMinFree := IIf(Len(aInstances) > 2,Val(aInstances[3]),0) //1
	nInc 	 := IIf(Len(aInstances) > 3,Val(aInstances[4]),0) //1

	nRefreshRate := Val(getPvProfString( cSecao , 'RefreshRate' , '' , cArqAppSrv )) //120

    //Cria uma nova sessão nomeada de Variáveis Globais agrupadas em duas tabelas
    //de HashMap, uma de dados primários a "Tabela X"
    //e outra para Listas de Valores a "Tabela A"
    //Ambas tabelas ("Tabela X" e "Tabela A") são compostas por "chave" e "valor"

    If VarSetUID(cUUIDFil)

		ConOut("[TAFTSI] Criando Secao TSIJobID para cache de filiais ...")

        //Inicia a transação em uma "chave", bloqueando o acesso aos seus valores nas tabelas "Tabela X" e "Tabela A"
		If VarBeginT(cUUIDFil, cChaveFil)

            //Adiciona Array com depara VarSetAD
			TAFSM0DePara(cUUIDFil,cChaveFil)

            /*Finaliza a transação*/
			If VarEndT(cUUIDFil, cChaveFil)
				ConOut("[TAFTSI] Encerrando transacao da secao " + cUUIDFil + " chave " +  cChaveFil)
			Else
				ConOut("[TAFTSI][ERROR] Erro no encerramento da transacao da secao " + cUUIDFil +  " chave " +  cChaveFil)
			EndIf

            //Recupera Array com de para
			aEmpresas := {}
			VarGetA(cUUIDFil,cChaveFil, @aEmpresas)

			If Len(aEmpresas) > 0

				For nX := 1 To Len(aEmpresas)

                    //Nome do Manual Job
					cAuxJobName := cJobName + "_" + aEmpresas[nX][1] //TSI_ACCEPT + GRUPO
					ConOut("ManualJob " + cAuxJobName)

					ManualJob(cAuxJobName /*Nome do Identificador do JOB */,;
						GetEnvServer() /*Ambiente que vai abrir esse cara */,;
						"IPC" /*Tipo do Job Mantenha com Ipc*/,;
						"TSI_START" /*Funcao que sera chamada quando uma nova thread subir*/,;
						"TSI_CONNECT" /*Funcao que sera chamada tova vez que mandar um ipcgo para ela*/,;
						"" /*Funcao que sera invocada quando a thread cair pelo timeout dela*/,;
						aEmpresas[nX][1]/*nao alterar eh o sessionkey*/,;
						nRefreshRate /*tempo que a thread sera reavalida e ira cair. Vamos manter 2 minutos. Se nao receber nada ela morre*/,;
						nMin /*Minimo de threads iniciadas. Se deixar 0 quando cair por timeout ele acabe*/,;
						nMax /*maximo de threads que ira subir*/,;
						nMinFree /*minimo de threads livres*/,;
						nInc /*incremento de threads livres*/ )
				Next nX
			Else
				ConOut("[TAFTSI][ERROR]Não encontrado empresas para inicialização do Job " + cJobName)
				ConOut("Verifique seu arquivo de empresas e a chave PrepareIn na secao " + cSecao)
			EndIf
		Else
			ConOut("[TAFTSI][ERROR] Não foi possivel Transacionar a chave " + cChaveFil + " no identificador de secao " + cUUIDFil)
		EndIf
    //Else
       //ConOut("[TAFTSI][ERROR] Erro na criação da sessão: " + cUUIDFil)
	Endif

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFSM0DePara 
Cria Array de De/Para de Filias TAF x ERP considerando todas as 
empresas/grupos.

@param cUUIDFil  	-> Identificador da seção
@param cChaveFil 	-> Chave utilizada na variavel.
@param lIgnoreProf 	-> Igora a chave secao TAF_TSI seçao PrepareIn
@param lNoPrepEnv 	-> Nao prepara o ambiente para a obtencao das filiais

@Return Nil 

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFSM0DePara(cUUIDFil,cChaveFil,lIgnoreProf,lNoPrepEnv)

	Local aEmpsSM0	:= {}
	Local nX	 	:= 0
	Local cCodEmp 	:= ""
	Local cNomeEmp	:= ""
	Local cEmpPos   := ""
	Local cModoC1E	:= ""
	Local cModoCR9	:= ""
	Local aDePara   := {}
	Local aEmpsProf := {}
	Local nPosEmp	:= 0
	Local nIndCR9	:= 0
	Local cSeekCR9	:= ''
	Local cComp		:= ''

	Default lIgnoreProf := .F.
	Default lNoPrepEnv 	:= .F.

	ConOut("Verificando De/Para de Filiais ...")

    aEmpsSM0 := TafGetSM0()

	If lIgnoreProf
		aEmpsProf := aClone(aEmpsSM0)
	Else
		aEmpsProf := TafProfEmp(aEmpsSM0)
	EndIf

	If Len(aEmpsProf) > 0
		cEmpPos := aEmpsProf[1][1]
		
		If !lNoPrepEnv
			RpcSetType( 3 )
			RpcSetEnv(cEmpPos,,,,"TAF","TAF_TSI",,,,.T.,)
		EndIf

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
				if TafIndexInDic("CR9", 4, .F.)
					nIndCR9 := 4
				else
					nIndCR9 := 3
				endif

				dbSelectArea("CR9")
				CR9->(dbSetOrder(nIndCR9))
			EndIf

			//Estrutura do Array de De/Para:
			//aDePara[n] - Array
			//aDePara[n][1] - Empresa
			//aDePara[n][2] - Array
			//aDePara[n][2][n][1] - Filial ERP
			//aDePara[n][2][n][2] - Filial TAF
			//aDePara[n][3] - Nome da Empresa/Grupo

			While C1E->(!Eof())
				aAdd(Atail(aDePara)[2],{AllTrim(C1E->C1E_CODFIL),C1E->C1E_FILTAF})

				if nIndCR9 == 4
					cSeekCR9 := xFilial("CR9") + C1E->C1E_ID +  C1E->C1E_VERSAO
					cComp := "C1E->C1E_ID+C1E->C1E_VERSAO == CR9->CR9_ID+CR9->CR9_VERSAO"
				elseif nIndCR9 == 3
					cSeekCR9 := xFilial("CR9") + C1E->C1E_ID + "1"
					cComp := "C1E->C1E_ID == CR9->CR9_ID"
				endif

				If CR9->(MsSeek( cSeekCR9 ))
					While CR9->(!Eof()) .And. &(cComp)
						aAdd(Atail(aDePara)[2],{AllTrim(CR9->CR9_CODFIL),C1E->C1E_FILTAF})
						CR9->(dbSkip())
					EndDo
				EndIf
				C1E->(dbSkip())
			EndDo
			C1E->(dbCloseArea())
		Next nX

		If VarSetAD(cUUIDFil, cChaveFil, aDePara)
			ConOut("[TAFTSI] Gravado filias com sucesso na secao: " + cUUIDFil + " chave "+ cChaveFil + ".")
		Else	
			ConOut("[TAFTSI][ERROR] Erro na gravacao das filias de De/Para")
		EndIf
	Else
		ConOut("[TAFTSI][ERROR] A chave PrepareIn nao foi preenchida na secao TAF_TSI.")	
	EndIf

	aSize(aEmpsSM0,0)
	aEmpsSM0 := Nil 

	aSize(aEmpsProf,0)
	aEmpsProf := Nil 

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafGetSM0 
Retorna array com os codigos das empresas ou grupos de empresas contidos na 
SM0

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafGetSM0()

	Local aEmpsRet 	:= {}
	Local nX 		:= 0
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
				ConOut("[TAF_TSI][INFO] Grupo localizado no arquivo de empresa: " + AllTrim(SM0->M0_CODIGO))
			EndIf
		EndIf

		SM0->(dbSkip())
	EndDo

Return (aEmpsRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafProfEmp 
Retorna as Empresas informadas na chave PrepareIn na seção TAF_TSI
validando se as mesmas existem no arquivo de empresa.

@param aEmpsSM0    -> Empresas contidas na SM0
@param lForceProf  -> Retorna todas as empresas do profile sem fazer a 
validação no arquivo de empresas.

@Return aEmpsVlds -> Array com os codigos das empresas/grupos

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafProfEmp(aEmpsSM0,lForceProf) 

	Local cSecao 		
	Local cArqAppSrv	
	Local cEmpsFile		
	Local aEmpsProf		
	Local aEmpsVlds		
	Local nX			
	Local nPosEmp		

	Default aEmpsSM0 := {}
	Default lForceProf  := .F.

	cSecao 		:= "TAF_TSI"
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
					ConOut("["+cSecao+"][WARN] Empresa " + AllTrim(aEmpsProf[nX]) + " Informada na chave PrepareIn da secao " + cSecao + " nao existe no arquivo de empresas.")
				EndIf
			Next nX
		Endif
	EndIf

	aSize(aEmpsProf,0)
	aEmpsProf := Nil

Return (aEmpsVlds)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TSI_START
Função executada na abertura do TSI_ACCEPT

@param cEmpresa - Codigo da Empresa para preparação do Ambiente

@author Evandro dos Santos O. Teixeira  / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TSI_START( cEmpresa )

	Local cUUIDFil
	Local cChaveFil
	Local cEmpresa

	Default cEmpresa := ""

	cUUIDFil   := "TSIJobID"
	cChaveFil  := "keyTSIJob" 

	If !Empty(cEmpresa)
		ConOut( "[TAF_TSI][TSI_START] Starting JobTafWS - Group Company: " + cEmpresa + " - Thread: " + allTrim( str( ThreadId() ) ) )

		RpcSetType( 3 )
		RpcSetEnv(cEmpresa,,,,"TAF","TAF_CFGJOB",,,,.T.,)

		ConOut( "[TAF_TSI][TSI_START] Started [RpcSetEnv] JobTafWS - Group Company: " + cEmpresa + " - Thread: " +  allTrim( str( ThreadId() ) ) + " - Data: " + DTOC(dDataBase)+ " - Hora: " + Time())
	Else
		ConOut("[TAF_TSI][TSI_START][ERROR] Não localizado a empresa na chave " + cChaveFil)
	EndIf

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} TSI_CONNECT 
Função de conexão com as threads criadas pela função TSI_START sob custódia do 
TAF_TSI

@cFunction - Nome da Função que a cFuncIPC irá executar
@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do WSREST (Header)
@cBody - Mensagem enviada no Body dos métodos WSREST (body)
@cParN - Parametros livres para passagem de parâmetros especificos da 
função.

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TSI_CONNECT(cFunction,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5 )

	Local oBlock

	Default aQryParam := {}
	Default cChave    := ""
	Default cBody     := ""
	Default cValorR   := ""

	oBlock := Nil

    ConOut("[TAF_TSI][TSI_CONNECT] Started IPCGo " + cFunction + "[InitializeProcess]")

    lRet := VarBeginT(cUId,cChave)

	lRet := VarSetXD(cUId,cChave,1)

	oBlock := ErrorBlock( { |e|jobTsiErro(e) , TAFEndPro( cChave , cUId , cValorR , {} , 9 )  } )
	
	BEGIN SEQUENCE
	    ConOut("[TAF_TSI][TSI_CONNECT] Calling " + cFunction + "- TSI_CONNECT")
		&cFunction.(cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)
	RECOVER
	    TAFEndPro( cChave , cUId , cValorR , {} , 9 )
	END SEQUENCE

	ErrorBlock( oBlock )

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} jobTsiErro 
Função executada pelo ErrorBlock da função TAF_CONNECT.

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function jobTsiErro(e)
	conOut( '[TAF_TSI][TSI_CONNECT][ERROR] ' + Chr(10)+ e:Description + Chr(10)+ e:ErrorStack)
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFEndPro 
Seta os valores de retorno e de finalização do Job

@cChave - Identificador da chave (tabela X) HashMap
@cUId	- Identificador da sessão de Variáveis Globais.
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aRetorno - Array de Retorno para a Thread principal.
@nVal - Valor de estado com o estado da chave (cChave).
1 - Job Iniciado
3 - Job Finalizado
9 - Encerramento em virtude de Erros

@author Luccas Curcio / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFEndPro( cChave, cUId , cValorR , aRetorno , nVal)

	Local lRet 

	lRet := VarSetAD( cUId , cValorR , aRetorno )
	lRet := VarSetXD( cUId , cChave , nVal )
	lRet := VarEndT( cUId , cChave )

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafEndCall 
Verifica se o processamento do Job em execução foi Finalizada.
obs. A utilização do VarBeginT é para verificar se a seção (cUId) teve a transação
finalizada.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap.
@nTry - Numero de verificações de finalização do Job.

@author Evandro dos Santos O. Teixeira/ Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafEndCall(cUId,cChave,nTry)

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
/*/{Protheus.doc} TSICALLIPC 

Executa o IPCGo nas Theads criadas pelo Job TAF_TSI.

@cFuncIPC	- Nome da função(Job) para execução do IPGGo (pool de Jobs)
@cFuncREST - Nome da Função que a cFuncIPC irá executar
@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do WSREST (Header)
@cBody - Mensagem enviada no Body dos métodos WSREST (body)
@cParN - Parametros livres para passagem de parâmetros especificos da 
função.

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TSICALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)

	Local nTry
	Local nVal
	Local lIPCGo

	Default aQryParam := {}
	Default cBody := ""

	nTry := 0
	lIPCGo := .F.

	ConOut("--------------> Grupo " + cChave + "[TAF_TSI][TSICALLIPC] Calling IPCGo - " + cFuncREST )

	While !IPCGo(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam,cBody,cPar1,cPar2,cPar3,cPar4,cPar5)
		If nTry <= 150
			Sleep(nTry * 1000)
			ConOut("[TAF_TSI][TSICALLIPC] Aguardando thread disponivel - " + cFuncREST )
			nTry++
		Else
			Exit
		EndIf
	Enddo

	lIPCGo  := IIf(nTry <= 150,.T.,.F.)
	nTry    := 0
	ConOut( "[TAF_TSI][TSICALLIPC] Waiting IPCGo - " + cFuncREST)
	lRet    := .F.

	If lIPCGo
		While(lRet == .F.)

			lRet := VarGetXD(cUId,cChave,@nVal)

			If nTry >= 150
				TAFEndPro(cChave,cUId,'',{},9)
				Exit
			Endif

			If TafIniCall(lRet,@nTry)
				lRet := TafFinCall(cUId,cChave,@nTry)
			EndIf
		End
	Else
		ConOut( "[TAF_TSI][TSICALLIPC][ERROR] IPCGo - " + cFuncREST + " - TimeOut - Nao ha Threads disponiveis.")
	EndIf

	ConOut( "[TAF_TSI][TSICALLIPC] Finished IPCGo - " + cFuncREST)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafIniCall 
Verifica se o Job foi iniciado, caso contratio soma +1 em nTry

@lRetGet - Retorno da função VarGetXD (verifica se houve inserção de conteudo
na varialve nVal)
@nTry - Numero de verificações de inicio do Job.

@author Evandro dos Santos O. Teixeira / Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafIniCall(lRetGet,nTry)
	If !lRetGet
		Sleep(100)
		nTry++
	Else 
		nTry := 0
	Endif
Return (lRetGet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafFinCall 
Verifica se o processamento do Job em execução foi Finalizada.
obs. A utilização do VarBeginT é para verificar se a seção (cUId) teve a transação
finalizada.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap.
@nTry - Numero de verificações de finalização do Job.

@author Evandro dos Santos O. Teixeira/ Denis Souza
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function TafFinCall(cUId,cChave,nTry)

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

//-------------------------------------------------------------------
/*/{Protheus.doc} TSISCH
Funcao para utilizar em schedule, com a finalidade de processar a integracao
de escopo Fiscal entre ERP e o TAF em MultThread.

@Param aParam:array
		aParam[1]:"T1"
		aParam[2]:"D MG 01 "
		aParam[3]:"000000"
		aParam[4]:"000003000001"

@Obs No Configurador colocamos apenas o nome dessa funcao TsiSch.
	 Os parametros acima serao recebidos de forma automatica, 
	 ao informar um grupo de empresa no configurador\schedule.

@Author Denis Souza
@Since 09/04/2020
/*/
//--------------------------------------------------------------------------- 
Function TSISCH( aParam )

Local cGrpJob  := aParam[1]
Local cFuncIPC := "TSI_ACCEPT_" + cGrpJob
Local cFunTSI  := "TSIENTPAG"
Local cUId 	   := "TSI_" + FWUUID(AllTrim(Str(Randomize(1,999999))))

TSICALLIPC( cFuncIPC, cFunTSI, cUId, cGrpJob )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TSIENTPAG

Funcao chamada em multthread Processamento da Entidade Paginada.

@Param aParam:array
		aParam[1]:"T1"
		aParam[2]:"D MG 01 "
		aParam[3]:"000000"
		aParam[4]:"000003000001"

@Obs No Configurador colocamos apenas o nome dessa funcao TsiSch.
	 Os parametros acima serao recebidos de forma automatica, 
	 ao informar um grupo de empresa no configurador\schedule.

@Author Denis Souza
@Since 09/04/2020
/*/
//--------------------------------------------------------------------------- 
Static Function TSIENTPAG( cUId, cGrpJob )

    local nlA 		:= 1
    default cUId 	:= ""
    default cGrpJob := ""

    for nlA := 1 to 120
        sleep(500)
        conout('--->Grupo ' + cGrpJob + ' Function TSIENTPAG Time ' + cvaltochar(time()) + " Contador " + cvaltochar(nlA) + " Thread" + AllTrim(Str(ThreadID())) )
    next nlA

    conout("------------> Fim TSIENTPAG")

Return Nil
