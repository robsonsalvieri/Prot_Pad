#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBRemoteExecute.CH"

#DEFINE RET_PENDENTE 	"00" 	// Não processado
#DEFINE RET_OK			"OK" 	// Processamento OK
#DEFINE RET_ERRO			"ER" 	// Falha no processamento


Static aRotinas		:= {}		// Rotinas da dicionario XXY ([1] - Processo / [2] - Descricao / [3] - Funcao)
Static aPrioridade 	:= {} 		// Array com a lista de rotinas na ordem de prioridade
  

//--------------------------------------------------------
/*/{Protheus.doc} STBRemoteExecute()
Executa remotamente uma função na retaguarda. Se não houver conexão pode-se gravar localmente para execução posterior (contingência).
@param	cProcess		ID do processo (XXY_ID)
@param	aParams			Parametros da rotina a ser executada
@param	aReturnOK		Array de retornos OK da rotina a ser executada
@param	lContingency	.T. para gravacao da contingencia caso nao haja comunicacao / .F. para nao gravar a contingencia (passando parametro por referencia retorna se foi utilizada a gravacao da contingencia no processo)
@param	uResult			Resultado da execucao da rotina (referencia)
@param 	cType			Tipo da operacao
@param 	cKeyOri			Chave de origem
@param 	nCodRet			Codigo de retorno do componente FWCallFunctionality
@param 	cDescError		Descricao do erro caso ocorra. passar por referencia 
@param  lPPdvOnCPdv		lógico - Indica que processo executado pelo STWUpdata se trata de registro do PDV Online com Central de PDV
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 lRetorno	.T. Quando gravado com sucesso / .F. Quando erro na gravacao
/*/
//--------------------------------------------------------
Function STBRemoteExecute(	cProcess	, aParams , aReturnOK	, lContingency	,;
							uResult 	, cType   , cKeyOri		, nCodRet 		,;
							cDescError  , lPdvOn  , lPPdvOnCPdv	)


Local aArea 	 		:= GetArea()	// Save da area de trabalho
Local lRetorno			:= .F.	// Retorno função
Local oRetornoCall 		:= Nil	// Retorno da execucao remota (FW)
Local aRetornoCall 		:= {}	// Retorno da execucao remota (FW)
Local uRetorno 			:= .F.	// Resultado da execucao da funcao (oRetornoCall:uResult)
Local nSeconds 			:= 0 	// Armazena segundos inicial
Local lSemaforo         := ExistFunc("STILoadSem") .AND. !IsBlind()
Local lPDVOnline		:= ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv()
Local lConnHost			:= Nil	// -- Variavel de controle  que indica se tem conexão com a retaguarda
Local lAutomato 		:= IIf(Type("lAutomatoX")<>"L",.F.,lAutomatoX)	//Teste Automatizado
Local lPdvOnCPdv		:= LjGetCPDV()[1] .AND. STFGetOnPdv() // TOTVS PDV ONLINE COM CENTRAL DE PDV.	

Default nCodRet			:= 0			// Apenas Indica se teve conec
Default cProcess		:= ""			// ID do processo (XXY_ID)
Default aParams			:= {}			// Parametros da rotina a ser executada
Default aReturnOK		:= {}			// Array de retornos OK da rotina a ser executada
Default lContingency 	:= .F.			// para gravacao da contingencia caso nao haja comunicacao
Default uResult		 	:= Nil			// Resultado da execucao da rotina (referencia)
Default cType			:= ""			// Tipo da operacao
Default cKeyOri			:= ""			// Chave de origem
Default cDescError		:= ""  			// Descricao do erro caso ocorra. passar por referencia 
Default lPdvOn			:= .F.
Default lPPdvOnCPdv		:= .F. 			// Indica que processo executado pelo STWUpdata se trata de registro do PDV Online com Central de PDV


ParamType 0 Var 		cProcess 		As Character	Default 	""
ParamType 1 Var   		aParams 		As Array		Default 	{}
ParamType 2 Var   		aReturnOK 		As Array		Default 	{}
ParamType 3 var  		lContingency	As Logical		Default 	.F.
ParamType 5 Var 		cType 			As Character	Default 	""
ParamType 6 Var 		cKeyOri 		As Character	Default 	""  


If lPPdvOnCPdv 
// ENTRA AQUI SOMENTE QUANDO O PROCESSO É EXECUTADO PELO STWUDATA PARA SUBIR REGISTRO DO PDVONLINE COM CENTRAL PDV
	lPdvOnCPdv := lPPdvOnCPdv
Endif 

If !Empty(cProcess)

	If !lPDVOnline
		lPDVOnline := lPdvOn
	EndIf
	// Ajusta o tamanho para 10
	cProcess 		:= Upper(SubStr(cProcess,1,10))
		
	LjGrvLog( "RemoteExecute","Antes da chamada FWCallFunctionality: " + cProcess )	

	nSeconds := Seconds() // Armazena segundos inicial
	
	If !lPDVOnline	.OR. (lPdvOnCPdv .AND. (!cProcess$"FR271HARQ|STBIMPORTR|STBISGETOP"))
		// -- Varifica se existe comunicação com a retaguarda
		GetGlbVars( "lConnHost",  @lConnHost)

		If  ValType( lConnHost ) <>  "L" .Or. ( ValType( lConnHost ) ==  "L" .AND. lConnHost )
			// Executa rotina pela funcao do FW, e trata o objeto de retorno
			oRetornoCall	:= FWCallFunctionality(cProcess, aParams)
		Else
			oRetornoCall := STFExecOn():New() 
			oRetornoCall:nStatusCode 		:= -105 	// -- -105 : Não foi possível conectar ao host superior
			oRetornoCall:cStatusDescription := STR0001 	// -- "Não foi possível conectar ao host superior"
		EndIf

	Else
		lContingency := .F.
		
		If lAutomato
			aRetornoCall := StartJob("STFExecOn",getenvserver(),.T.,cProcess,aParams,cEmpAnt,cFilAnt,.T.)//PDV Online (PDV diretamente na retaguarda)
		Else
			aRetornoCall := STFExecOn(cProcess,aParams)			
		EndIf

		oRetornoCall := STFExecOn():New() 
		If ValType(aRetornoCall)=="A" .AND. len(aRetornoCall) > 0
			oRetornoCall:nStatusCode 		:= aRetornoCall[1]
			oRetornoCall:cStatusDescription := aRetornoCall[2]
			oRetornoCall:uResult 			:= aRetornoCall[3]
			oRetornoCall:oStatusError 		:= aRetornoCall[4]
		EndIf
	Endif
	
	LjGrvLog( "RemoteExecute","Depois da chamada FWCallFunctionality: " + cProcess + " | Tempo: " + AllTrim(Str(Seconds() - nSeconds) ) )	
	
	/*
	//--------------------------------------------------------------------
	Status e Erros do Componente de Comunicacao
	 0   : Ok
	-101 : Funcionalidade não encontrada no componente de comunicacao
	-102 : Função não encontrada no RPO
	-103 : Ocorreu um erro na execução da funcionalidade
	-104 : Protocolo de comunicação não configurado no servidor
	-105 : Não foi possível conectar ao host superior
	-106 : Não foi possível deserializar os parametros (JSON)
	-107 : Ocorreu um erro durante a execução da funcionalidade no host superior
	-108 : Não existe host responsável pela execução da	funcionalidade   
	//--------------------------------------------------------------------
	*/
	nCodRet := 0		
	If Valtype(oRetornoCall) == "O"
		nCodRet := oRetornoCall:nStatusCode	
		LjGrvLog( "RemoteExecute","Retorno nCodRet:",nCodRet )
		If nCodRet < 0			
			If nCodRet == -106 // -106 : 'Nao foi possivel deserializar os parametros (JSON)
				lContingency := .F.
				cDescError := AllTrim(oRetornoCall:cStatusDescription)
				LjGrvLog( "RemoteExecute","Retornou erro deserializar objeto",cDescError )
			Else
				If lContingency
					LjGrvLog( "RemoteExecute","sera gravado como contingência ")
					lRetorno := STBRecordLocalContingency(	cProcess, aParams, aReturnOK , cType ,;
																cKeyOri									)[1]
					lContingency := .F.
				Else
					//Exibe mensagem com erro de comunicacao
					Conout( "cStatusDescription : " + AllTrim(oRetornoCall:cStatusDescription) )
					LjGrvLog( "RemoteExecute", "cStatusDescription : " + AllTrim(oRetornoCall:cStatusDescription) )
					
					// Se houve erro na execucao no servidor mostra erro no console
					If nCodRet == -103 .AND. ValType(oRetornoCall:oStatusError) == "O"						
						cDescError := Left( oRetornoCall:oStatusError:ErrorStack , 254 )
						Conout( "RemoteExecute: " + cDescError )
						LjGrvLog( "RemoteExecute","Retornou erro execucao ",cDescError )
					EndIf	
				EndIf
			EndIf
			
			//Atualiza semaforo de conexao com Retaguarda
			If lSemaforo .AND. IsInCallStack("STIPOSMAIN")
    			If nCodRet == -104 .Or. nCodRet == -105                
                    STILoadSem(.F., .F.) //Nao conectado
                Else
                    STILoadSem(.F., .T.) //Conectado
                EndIf
            EndIf 
		Else
			// Armazena status de contingencia para acesso por referencia
			lContingency := .F.
			// Armazena retorno da funcao para acesso por referencia
			uResult := oRetornoCall:uResult
			
			If Len(aReturnOK) > 0
				lRetorno := (Ascan(aReturnOK, {|x| ValType(x) ==  Valtype(uResult) .AND. x == uResult}) > 0)
				LjGrvLog( "RemoteExecute","Retorno específico ")
			Else
				lRetorno := .T.
				LjGrvLog( "RemoteExecute","Retornou corretamente ")
			EndIf
			//Atualiza semaforo de conexao com retaguarda
			If lSemaforo .AND. IsInCallStack("STIPOSMAIN")
                STILoadSem(.F., .T.) //Conectado
            EndIf 
		EndIf  
	EndIf 	
Else
	lRetorno := .F.
	LjGrvLog( "RemoteExecute","Não retornou um objeto valido" )	
EndIf

RestArea(aArea) // Restaura area

LjGrvLog( "RemoteExecute","Retorno:" , lRetorno )	

Return lRetorno


//--------------------------------------------------------
/*/{Protheus.doc} STBRecordLocalContingency()
Grava os dados na tabela de contingencia
@param		cProcess		ID do processo (XXY_ID)
@param		aParams		Parametros da rotina a ser executada
@param		aReturnOK	 	Array de retornos OK da rotina a ser executada
@param 	cType				Tipo da operacao
@param 	cKeyOri			Chave de origem
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 lRetorno	.T. Quando gravado com sucesso / .F. Quando erro na gravacao
/*/
//--------------------------------------------------------
Function STBRecordLocalContingency(	cProcess	, aParams	, aReturnOK , cType 	,;
										 	cKeyOri 										)    

Local aArea 	 		:= GetArea()	// Save da area de trabalho
Local lRetorno 	 	:= .F.			// Retorno da gravacao da tabela MES     
Local aRet			:= {.F.}			// Retono da funcao

Default cProcess		:= ""			// ID do processo (XXY_ID)
Default aParams		:= {}			// Parametros da rotina a ser executada
Default aReturnOK	:= {}			// Array de retornos OK da rotina a ser executada
Default cType		:= ""			// Tipo da operacao
Default cKeyOri		:= ""			// Chave de origem
                                             
ParamType 0 Var 		cProcess 	As Character	Default 	""
ParamType 1 Var   	aParams 	As Array	Default 	{}
ParamType 2 Var   	aReturnOK 	As Array	Default 	{}
ParamType 3 Var 		cType 		As Character	Default 	""
ParamType 4 Var 		cKeyOri 	As Character	Default 	""                                          
                                             

DbSelectArea("MES")
If Reclock("MES", .T.)
	REPLACE	MES->MES_FILIAL	WITH	xFilial("MES")				// xFilial da tabela
	REPLACE	MES->MES_SEQ		WITH	GetSXENum("MES", "MES_SEQ")	// Numeracao automatica
	REPLACE	MES->MES_ESTACAO	WITH	STFGetStation("LG_CODIGO")	// xFilial da tabela
	REPLACE	MES->MES_DATA		WITH	dDataBase					// Data base do sistema
	REPLACE	MES->MES_HORA		WITH	SubStr(Time(), 1, 5)		// Horario
	REPLACE	MES->MES_PROCESS	WITH	cProcess					// Nome da rotina a ser executada
	REPLACE	MES->MES_PARAMS	WITH	FwJsonSerialize(aParams)	// Parametros da rotina a ser executada
	REPLACE	MES->MES_RETOK	WITH	FwJsonSerialize(aReturnOK)	// Possiveis retornos OK da rotina a ser executada
	REPLACE	MES->MES_SITUA	WITH	RET_PENDENTE				// Status de execucao da rotina      
	
	REPLACE	MES->MES_TIPO		WITH	cType 	// Status de execucao da rotina - "01" = Reserva


	// Guarda Filial e Chave de origem de quem chamou contingencia para posterior 
	// gravacao do resultado na origem apos execucao 
	REPLACE	MES->MES_FILORI	WITH	cFilAnt						// Status de execucao da rotina	
	REPLACE	MES->MES_KEYORI	WITH	cKeyOri				
	
	ConfirmSX8()
	MES->(MsUnlock())
	lRetorno := .T. 
	
	aRet[1] :=  lRetorno 				// Retorno da funcao
	Aadd(aRet, MES->(RecNo())		) // recno da MES
	
EndIf

MES->(DbCloseArea())
RestArea(aArea)    
           


Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} STBRemoteExecute
Job de processamento de contingencias executado na retaguarda
@author  Varejo
@version P11.8
@since   14/08/2012
@return  Nil
@obs     
@sample
/*/
//--------------------------------------------------------
Function STWJOBContingency( cEmp , cFil , cPdv )

Local lPrepEnv		:= .F.						// Verifica se deve preparar o Ambiente
Local lConnect		:= .F.						//Se conectou no server


Default cEmp		:= ""							// Empresa para processamento
Default cFil		:= ""							// Filial para processamento
Default cPdv		:= "001"						// Conteudo do terceiro parametro (Parm3 do mp8srv.ini)


//Aguarda para evitar erro de __CInternet
Sleep(5000)

lPrepEnv := !Empty(cEmp) .AND. !Empty(cFil)


If lPrepEnv
	RPCSetType(3)
	// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
	RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
Else
	Conout("Não foram informados os parametros do processo no arquivo INI")	
EndIf

//Testa a comunicacao atraves da STFTestRemoteExecute
lConnect := STFTestRemoteExecute()

If lConnect
	ConOut("Com conexao com o Host, o sera realizado processo de contingencia - ProcessContingency")
	ProcessContingency()
	ConOut("Final do processo de contingencia - ProcessContingency")
Else
	ConOut("Sem conexao com o Host, o nao sera realizado processo de contingencia - ProcessContingency")
EndIf

FWCloseFunctionality() // Desconecta do Host Superior para liberar memoria alocada


If lPrepEnv
	RESET ENVIRONMENT 
EndIf
	

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} ProcessContingency()
Processa as contingencias podendo ser por lotes, respeitando as prioridades caso existam
@author  Varejo
@version P11.8
@since   14/08/2012
@return  Nil
@obs     
@sample
*/
//--------------------------------------------------------
Static Function ProcessContingency()

Local aArea 			:= GetArea()						// Save da area de trabalho
Local nMaxPacote		:= SuperGetMv("MV_MAXUPL", Nil, 50)	// Maximo de execucao de rotinas por lote
Local nCount			:= 0								// Contador de rotinas executadas
Local aParams			:= {}								// Array de parametros da rotina
Local aRetornosOK	:= {}								// Array de retornos ok da rotina a ser executada
Local lOK				:= .F.								// Status de execucao da rotina .T. OK / .F. Erro
Local nX				:= 0								// Contador
Local uRet				:= NIL 							//Retorno da Rotina
Local nTamRet			:= 0 								//Tamanho do array de retorno
Local cSitua			:= ""								//Situação da Contingência
Local cChave			:= ""								//Chave do Registro
Local cCmpChave 		:= "Chave: MES_PROCESS/MES_SEQ/MES_ESTACAO: "							//Campos da Chave
Local aMesRec			:= {} //Array de Registros da MES
Local nC				:= 0	//Contador de registro

MES->(DbSetOrder(2) ) // MES_FILIAL+MES_SITUA

cChave := xFilial("MES") + AllTrim(RET_PENDENTE)
MES->(DbSeek(cChave))
While MES->(!Eof()) .AND.  MES->( MES_FILIAL + MES->MES_SITUA == cChave)
	aAdd( aMesRec, MES->(Recno()))
	MES->(Dbskip(1))
	If ++nCount >= nMaxPacote
		Exit
	EndIf
EndDo

For nC := 1 to Len(aMesRec)

	MES->(DbGoTo(aMesRec[nC]))
	aRetornosOK := {}
	aParams		:= {}
	
	cSitua := ""
	cChave := MES->(MES_PROCESS+"/"+MES_SEQ+"/"+MES_ESTACAO)
	
	If FWJsonDeserialize(MES->MES_RETOK, @aRetornosOK) .AND. FWJsonDeserialize(MES->MES_PARAMS, @aParams)
	
		If ValType(aRetornosOK) == "A" .AND.   (nTamRet := Len(aRetornosOK)) > 0
			lOK := .F.
			uRet := DynamicCall(AllTrim(MES->(MES_PROCES)), aParams)[2]
			
			//Trata o tipo do retorno, pois a rotina de recebimento em contingencia offline tem 2 tipos de retorno: lógico e caractere
			For nX := 1 to nTamRet
				If ValType(uRet) ==  ValType(aRetornosOK[nX])
					lOK :=  uRet == aRetornosOK[nX]
					If lOK
						Exit
					EndIf
				EndIf
				
			Next nX 
			
			LjGrvLog( "ProcessContingency", "ProcessContingency Retorno de execução " + cCmpChave + cChave + "{lOk, uREt} ", {lOk, uRet})
			If lOK			
				cSitua := RET_OK
			Else
				cSitua := RET_ERRO
			EndIf				
		Else
			lOk := DynamicCall(AllTrim(MES->(MES_PROCES)), aParams)[1]
			LjGrvLog( "ProcessContingency", "ProcessContingency Retorno de execução " + cCmpChave + cChave + "{lOk} ", {lOk})

			If lOK			
				cSitua := RET_OK
			EndIf					
		EndIf
		
	Else
		LjGrvLog( "ProcessContingency", "ProcessContingency Erro ao desserializar parâmetro")		
		cSitua :=  RET_ERRO				
	EndIf
	
	If !Empty(cSitua)
		RecLock("MES", .F.)
		REPLACE MES->MES_SITUA WITH cSitua
		MES->(MsUnlock())
	EndIf
			
Next nC


MES->(DbCloseArea())

RestArea(aArea)

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} LoadPriority
Carrega o array estatico de ordem de prioridades de execucao (tabela MET)
@author  Varejo
@version P11.8
@since   14/08/2012
@return  Nil
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function LoadPriority()

Local cAliasProcess	:= ""							// Guardara Alias temporario da query executada
Local aArea 			:= GetArea()					// Save da area de trabalho
Local nTamSX3			:= TamSx3("MET_PROCES")[1]	// Tamanho do campo

	  
cAliasProcess	:= GetNextAlias()	// Alias temporario da query executada  
  
BeginSQL alias cAliasProcess
	SELECT 
		MET_PROCES PROCES,
		MET_PRIORI PRIORI
	FROM 
		%table:MET% MET
	WHERE
		MET.%notDel%
	ORDER BY MET_PRIORI ASC
EndSql

aPrioridade := {}

While (cAliasProcess)->(!EOF())
	Aadd(aPrioridade, PadR((cAliasProcess)->(PROCES), nTamSX3))
	(cAliasProcess)->(DbSkip())
End Do

(cAliasProcess)->(DbCloseArea())



RestArea(aArea)

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} DynamicCall
Executa rotinas de forma dinamica, passando o nome do processo e parametros
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Aret[1] Retorna se executou a funcao no server
@return	 Aret[1] uRetorno	 Variante
@obs     
@sample
*/
//--------------------------------------------------------
Static Function DynamicCall( cProcess, aParams )

Local nI 				:= 0		// Contador
Local uRetorno			:= Nil		// Retorno da funcao
Local cParametros		:= ""		// Parametros da funcao
Local lRet		  		:= .F.		// Retorno

Default cProcess 		:= ""
Default aParams 		:= {}

ParamType 0 Var 	cProcess 	As Character	Default 	""
ParamType 1 Var   	aParams 	As Array	Default 	{}

For nI := 1 To Len(aParams)
	cParametros += IIF(nI <> 1, ", ", "") + "aParams[" + AllTrim(Str(nI)) + "]"
Next nI

//uRetorno := Eval(&("{|| " + cProcess + "(" + cParametros + ")}"))          

//Tenta executar novamente o processo que esta em contingencia
lRet := STBRemoteExecute( cProcess , aParams , Nil , .F. , @uRetorno )

Return ({lRet, uRetorno})


//--------------------------------------------------------
/*/{Protheus.doc} GetFunction()
Retorna o nome da funcao de acordo com o ID (XXY_ID)
@param	 cProcess	XXY_ID da rotina
@author  Varejo
@version P11.8
@since   01/10/2012
@return	 cRetorno	 - nome da funcao
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function GetFunction( cProcess )

Local cRetorno 		:= ""	// Retorno da funcao
Local nPos 			:= 0	// Posicao do array, retorno do Ascan

Default cProcess	:= ""

ParamType 0 Var 	cProcess 	As Character	Default 	""

nPos :=	Ascan(aRotinas, {|x| Upper(Alltrim(x[1])) == Upper(AllTrim(cProcess))})
If nPos > 0
	cRetorno := aRotinas[nPos][3]
EndIf

Return cRetorno


//--------------------------------------------------------
/*/{Protheus.doc} LoadArrayFunctions
Carrega o array de funcoes estatico
@author  Varejo
@version P11.8
@since   14/08/2012
@return	 Nil
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function LoadArrayFunctions()

Local aArea := GetArea()	// Save da area de trabalho

aRotinas := {}

FWOpenXXY()
DbSetOrder(1)

While XXY->(!EOF())
	Aadd(aRotinas, {XXY->XXY_ID, XXY->XXY_DESC, XXY->XXY_FUNC})
	XXY->(DbSkip())
End Do

XXY->(DbCloseArea())
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} STTMTT
Função chamada pela lib e executada no host MASTER sem a necessidade de funcionalidade cadastrada ou vinculo com perfil. 

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@param oX, Object, Objeto enviado pela camada de framework com dados referente a requisição 
@param cFunction, Caracter, Função que será executada no Host superio
@param aParams, Array, Contem os parametros da função (cFunction)
@return uResult, Indefinido, Retorna para camada inferior o retorno da função (cFunction)
/*/
//-------------------------------------------------------------------------------------------------------

Function STCOMDIR(oX,cFunction,aParams)
Local lVirgula 	:= .F.
Local nParams  	:= 0
Local uResult  	:= Nil

Default cFunction 	:= ""
Default aParams 	:= {}

If !Empty(cFunction)
	cFunction += "("
	For nParams := 1 To len(aParams)
		If lVirgula  
			cFunction += ", " 
		EndIf 
		lVirgula := .T.
		cFunction += "aParams[" + cValtoChar(nParams) + "]"
	Next
	cFunction += ")"
	
	uResult := &(cFunction)
	
EndIf 

return uResult



