#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TafProcMT.ch'

#Define cNameMT   'TafStartMT'	//String com nome da função principal de processamento MT para definição do
								//nome do semaforo

#Define Arquivo_Tipo_Texto  '1' //Processamento via TEXTO na TAFST2
#Define Status_Pendente     '1' //Pendentes de Processamento na TAFST2

#Define X3noLoad  '1'
#Define X3loading '2'
#Define X3loaded  '3'

//cache dos principais campos das tabelas relacionadas a nota fiscal ( tms / gia )
STATIC aCacheTB := StrTokArr(("C20|C30|C35|C39|C2F"),'|')

//---------------------------------------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafStartMT

Realiza a execução dos processos de integração em MultThread

Serão abertas através desta função as threads que ficarão aguardando as chamadas do IPCGO

@param	cSemaphore - Nome do Semáforo que sá utilizado para aberura das threads
		nInteg     - Numero do processo que esta sendo executado
		lJob       - Indica se o processamento esta sendo realizado via Schedule
		aPar       - Array com as configurações para quando a chamada for via Schedule ou processos que utilizem esse array
		cMvTAFTALI - Conteúdo do parâmetro MV_TAFTALI
		cMvTAFTDB  - Conteúdo do parâmetro MV_TAFTDB
		nMvTAFPort - COnteúdo do parâmetro MV_TAFPORT
		nQtdThread - Quantidade de threads que devem ser usadas no processamento

@return lErrorProc - Indica se ocorreu erro na aberura das threads

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//---------------------------------------------------------------------------------------------------------------------------------
function TafStartMT( cSemaphore, nInteg, lJob, aPar, cMvTAFTALI, cMvTAFTDB, nMvTAFPort, nQtdThread)
 
local cJobAux    := ''

local nI         := 0
local nCount     := 0

local lErrorProc := .F.
local lErrorAmb  := .F.
local aJobAux    := {}

//Se nao existir, atribui valores default em variaveis privadas
if Type("_lIniMt") == "U"
	_lIniMt := .F.
endif

cSemaphore := Upper( cNameMT + '_' + AllTrim( Str( ThreadID() ) ) )

if !_lIniMt
	//--------------------------------------------------------------------------
	//Processamento na Interface TAFA428 ou Schedule TafFisMT	
	//Atribui Flag para nao entrar novamente nesse ponto e iniciar novas threads
	//--------------------------------------------------------------------------
	_lIniMt := .T.

	TAFConout( '*****Iniciando Abertura das Threads - Time -> ' + Time() + " *********",2,.T.,"INTEG" )

	//-----------------------------------------------------------------------	
	//Realiza a abertura das threads que serão utilizadas para processamento
	//-----------------------------------------------------------------------
	TafOPenMT( @cSemaphore, nInteg, lJob, @cJobAux, @aJobAux, aPar, cMvTAFTALI, cMvTAFTDB, nMvTAFPort, nQtdThread)

	//---------------------------------------------------------------------
	//Após iniciar as Threads fico no laço abaixo aguardando o término da 
	//abertura dos ambientes para seguir com a integração
	//---------------------------------------------------------------------
	while .T.		
		//--------------------------------------
		//Contador de Thread abertas com sucesso
		//--------------------------------------
		nCount := 0
	
		for nI := 1 to len( aJobAux )			
			//--------------------------------------------------------		
			//Status 1 = Thread já está preparada para o processamento
			//--------------------------------------------------------
			if GetGlbValue( aJobAux[nI][1] ) == '1'
				nCount += 1							
			//-------------------------------------------------------------------------------------------
			//Status 9 = Ocorreu erro na abertura da Thread, o processo de integração deverá ser abortado
			//-------------------------------------------------------------------------------------------		
			elseif GetGlbValue( aJobAux[nI][1] ) == '9'
				lErrorProc := .T.
				exit			
			//----------------------------------------------------------------------------
			//Status 8 = Ocorreu erro na abertura das tabelas internas de controle do TAF 
			//----------------------------------------------------------------------------		
			elseif GetGlbValue( aJobAux[nI][1] ) == '8'
				lErrorAmb := .T.
				exit			
			endif			
		next
		//--------------------------------------------------------------------------------------
		//Verifico se TODAS as threads já estão disponíveis para o processamento ou se ocorreu
		//erro na abertura de alguma Thread
		//-------------------------------------------------------------------------------------- 
		if ( nCount == len( aJobAux ) ) .or. lErrorProc	.or. lErrorAmb	
			exit
		endif	
	enddo	

	//-----------------------------------------------------------------------------------------
	//Encerro as variáveis globais abertas para controle de abertura dos ambientes nas threads 
	//-----------------------------------------------------------------------------------------
	for nI := 1 to len( aJobAux )
		ClearGlbValue( aJobAux[nI][1] )
	next

	//-------------------------------------------------------------------------------
	//Encerro as threads abertas caso tenha ocorrido erro na abertura de alguma delas
	//-------------------------------------------------------------------------------
	ErroProc(lErrorProc,nQtdThread, cSemaphore) 

	//---------------------------------------------------------------------------
	//Tratamento para quando ocorrer erro nas tabelas de controle internas do TAF
	//---------------------------------------------------------------------------
	if lErrorAmb
		lErrorProc := .T.		
		if !lJob
			MsgAlert( STR0001 ) //'Ambiente Desatualizado - Execute a Wizard de configuração através do Menu Miscelâne para atualizar o ambiente e liberar a utilização deste funcionalidade'
		endif
	endif
	TAFConout( '*****Finalizada Abertura das Threads - Time -> ' + Time() + " *********",2,.T.,"INTEG" )
endif

return lErrorProc 

//-------------------------------------------------------------------
/*{Protheus.doc} TafOPenMT

Realiza a abertura das threads 

@param	cSemaphore - Nome do Semáforo que sá utilizado para aberura das threads
		nInteg     - Numero do processo que esta sendo executado
		lJob       - Indica se o processamento esta sendo realizado via Schedule
		cJobAux    - Nome da variável global de cotrole que será criada nessa função
		aJobAux    - array com todos os cJobAux criados nessa função
		aPar       - Array com as configurações para quando a chamada for via Schedule ou processos que utilizem esse array
		cMvTAFTALI - Conteúdo do parâmetro MV_TAFTALI
		cMvTAFTDB  - Conteúdo do parâmetro MV_TAFTDB
		nMvTAFPort - COnteúdo do parâmetro MV_TAFPORT
		nQtdThread - Quantidade de threads que devem ser usadas no processamento

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
Function TafOPenMT( cSemaphore, nInteg, lJob, cJobAux, aJobAux, aPar, cMvTAFTALI, cMvTAFTDB, nMvTAFPort, nQtdThread)

local cThread     := ''
local cFunIpcGO   := 'TafExecMT' //Nome da função a ser executada na chamada do IPCGO
local nI          := 0
local lTafPool    := IsInCallStack("TAFA428") .Or. IsInCallStack("TafFisMT") .Or. IsInCallStack("TAFA500")

//--------------------------------------------
//Laço para abertura das threads
//-------------------------------------------- 
for nI := 1 to nQtdThread

	cThread := StrZero( nI , 2 )
	cJobAux := StrTran( 'cTAFProc2_' + FWGrpCompany() + FWCodFil() , ' ' , '_' ) + cThread

	//--------------------------------------------
	//Status 0 - Thread Aberta e processando
	//--------------------------------------------
	PutGlbValue( cJobAux , '0' )
	GlbUnlock()
	
	//----------------------------------------------------	
	// Adiciona o nome do arquivo de Job no array aJobAux
	//----------------------------------------------------
	aAdd( aJobAux , { cJobAux, cThread } )		
	
	TAFConout( 'MT - Iniciando a Thread -> ' + cThread,2,.T.,"INTEG" ) 
	StartJob( 'TafCheckMT', GetEnvServer(), .F., cSemaphore, cFunIpcGO, cEmpAnt, cFilAnt, cThread, nInteg, lJob, cJobAux, aPar, cMvTAFTALI, cMvTAFTDB, nMvTAFPort, lTafPool)
	
	//----------------------------------------------------------------------------------------
	//Aguardo 4 segundos para não haver concorrência na validação das tabelas tafst1 e tafst2
	//----------------------------------------------------------------------------------------
	Sleep( 1000 ) //recomendacao chamar em partes menores e mais vezes.
	Sleep( 1000 )
	Sleep( 1000 )
	Sleep( 1000 )
next nI

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafCheckMT

Função principal do StartJob responsável pela execução dos comandos realizados através do IPCGO

@param	cSemaphore - Nome do semaforo que será utilizado no processamento
		cFunIpcGO  - Nome da função que irá controlar o processmento das threads
		cEmp       - Empresa a ser aberto o ambiente
		cFil       - Filial a ser aberto o ambiente
		cThread    - Indicativo da thread que esta sendo executada
		nInteg     - Numero do processo que esta sendo executado
		lJob       - Indica se o processamento esta sendo realizado via Schedule
		cJobAux    - Nome da variável global de cotrole que será criada nessa função
		aPar       - Array com as configurações para quando a chamada for via Schedule ou processos que utilizem esse array
		cMvTAFTALI - Conteúdo do parâmetro MV_TAFTALI
		cMvTAFTDB  - Conteúdo do parâmetro MV_TAFTDB
		nMvTAFPort - COnteúdo do parâmetro MV_TAFPORT

@return 

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
Function TafCheckMT( cSemaphore, cFunIpcGO, cEmp, cFil, cThread, nInteg, lJob, cJobAux, aPar, cMvTAFTALI, cMvTAFTDB, nMvTAFPort, lTafPool)

local uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10

local nTimeOut   := 18000000 //30 Minutos para Time-out 	
	
Local cST1Alias  := ''   									 										
Local cTopBuild  := ''	

Local cTCBuild := 'TCGetBuild'
local cST1TAB	 := 'TAFST1'	
local cST2TAB	 := 'TAFST2'	
local cTAFXERP := 'TAFXERP'	

local nHdlTaf	  := 0			

local lFoundErr := .F.
local lErroAmb  := .F.
local lTAFConn  := .F.

local aTABDados := {} 
local aTabConf  := {} 			

local oError := ErrorBlock( { |Obj| lFoundErr := .T., TAFConout( 'MT - Mensagem de Erro: ' + Chr(10)+ Obj:Description,3,.T.,"INTEG" ) } )

local cBancoDB   := ''

local aTamSx3    := {}
local cCacheOp   := X3noLoad //"1"

Default lTafPool   := .F.

Private cXERPAlias := ''
Private cST2Alias  := ''

//---------------------------------------------------------------------------------
//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
//é exibida uma mensagem tratada do erro para o usuário final
//---------------------------------------------------------------------------------

TafConout('Thread( ' + cThread + ' ) - Emp: ' + cEmp + ', Fil: ' + cFil + ' - Em preparação de ambiente... ')
TcInternal( 1 , 'Thread( ' + cThread + ' ) - ' + ConType() + ' - Em preparação de ambiente... ' )

Begin Sequence
	//---------------------------------------------------------------------
	//Seto a empresa e filial necessárias para o processamento da Thread
	//---------------------------------------------------------------------
	RPCSetType( 3 )
	//Preparação do Grupo Empresa, nao eh necessario atualizar o cEmpAnt
	RPCSetEnv( cEmp, cFil,,,"TAF","TAFPROCMT")
	TAFConout( 'MT  - Ambiente da THREAD ' + cThread + ' criado com sucesso',2,.T.,"INTEG" )

	//Cache na primeira execucao
	TafLoadX3( @aTamSx3, @cCacheOp )

	//---------------------------------------------------------------------------------------------------	
	//Inicio as validações necessárias para realizar a conexão no banco das tabelas TAFST1 e TAFST2            
	//---------------------------------------------------------------------------------------------------
	if FindFunction( cTCBuild ) 		
		cTopBuild := &cTCBuild.()			 	  //Verificando a Build do ambiente
	endif
	
	cBancoDB := Upper( AllTrim( TcGetDB () ) )  //Verfica Banco utilizado 
	
	aTabConf := xTAFGetStru(cST2TAB)       	  //Chama funcao de retorno da estrutura das tabelas compartilhadas
		                
	cST1Alias	:= GetNextAlias()
	cST2Alias	:= GetNextAlias()
	cXERPAlias	:= GetNextAlias()	
	aTABDados	:= { { cST1TAB, cST1Alias }, { cST2TAB, cST2Alias }, { cTAFXERP, cXERPAlias } }
							
	//----------------------------------------------------
	//Verifica Conexoes/Tabela atraves da funcao TAFCONN()
	//----------------------------------------------------
	TAFConout( 'MT - Conectando as bases de dados... da Thread' + cThread,2,.T.,"INTEG" )
	lTAFConn := TAFConn( 1, nInteg, aTABDados, aTabConf, {}, aPar, cTopBuild, cBancoDB, lJob, @nHdlTaf,  cMvTAFTALI, cMvTAFTDB, nMvTAFPort )

	//--------------------------------------------------------------------------------------
	//Verifico se foi possível a conexão com o banco de dados das tabelas TAFST1 e/ou TAFST2
	//--------------------------------------------------------------------------------------
	if !lTAFConn
		
		////--------------------------------------------------------------------------------
		//Caso não consiga a conexão e já tenha criado conexão com a TAFST1, deve encerra-lá
		//----------------------------------------------------------------------------------
		If nHdlTaf > 0
			TCUnlink( nHdlTaf )
			nHdlTaf := 0
		EndIf
		
		lErroAmb := .T. 		
		TAFConout( 'MT - Não foi possível realizar a conexão com as tabelas TAFST1 e TAFST2',3,.T.,"INTEG" ) 
	else
	
		TAFConout( 'Base de dados da Thread ' + cThread + ' Conectada com sucesso ! ',2,.T.,"INTEG" )
		//---------------------------------------------------------------------------
		//Status 1 = Layout Totvs/ COnexão com TAFST1 e TAFST2 carregados com sucesso
		//---------------------------------------------------------------------------
		PutGlbValue( cJobAux , '1' )
		GlbUnlock()
			
	endif
		
End Sequence

TafConout('Thread( ' + cThread + ' ) - Emp: ' + cEmpAnt + ', Fil: ' + cFilAnt + ' - Processamento finalizado, aguardando... ' )
TcInternal( 1 , 'Thread( ' + cThread + ' ) - ' + ConType() + ' - Processamento finalizado, aguardando... ' )

//-----------------------------------------------------------------------------------------------		
//Somente realizo a espera do IPCGO se consegui realizar a conexão com as tabelas TAFST1 e TAFST2
//-----------------------------------------------------------------------------------------------
if !lFoundErr .and. !lErroAmb

	while !KillApp()
		
		//------------------------
		//Aguardando comando IPCGo
		//------------------------
		if IPCWaitEx( cSemaphore, nTimeOut, @uParm1, @uParm2, @uParm3, @uParm4, @uParm5, @uParm6, @uParm7, @uParm8, @uParm9, @uParm10 )

			/* Foi passado o cFilAnt como parametro, pois caso a rotina
			seja executada pela rotina TAFA428 ou TafFisMt, a outra thread
			que esta em espera pelo IpcWaitEx tem que ser saber qual cFilAnt 
			ira processar, visto que o pool de threads eh aberto uma unica vez 
			para todas as filiais. Ou seja, quando trocar a filial, eh necessario 
			informar a Thread que esta em espera, qual sera a filial a ser processada. */

			if lTafPool .And. ValType( uParm6 ) == 'C' .And. ValType( uParm7 ) == 'C'
				cFilAnt := uParm6
			endif

			//--------------------------------------------------------------------		
			//Tratamento para encerrar a Thread quando receber os comandos abaixo
			//--------------------------------------------------------------------
			if ValType( uParm1 ) == 'C' .and. uParm1 == 'E_X_I_T_'
				Exit
			endIf
	
			//---------------------
			//Funcao a ser executada
			//---------------------
			&cFunIpcGO.( uParm1, uParm2, uParm3, uParm4, uParm5, uParm6, uParm7, uParm8, uParm9, uParm10 )	
		
		//----------------------------------------------------------------------------------
		//Caso não seja executada nenhuma chamada IpcGo no tempo de Timeout encerro a thread
		//----------------------------------------------------------------------------------
		else
			Exit
			
		endIf
	endDo

//------------------------------------------------
//Caso tenha ocorrido erro na abertura das threads
//------------------------------------------------
else 
	
	//----------------------------------------------------
	//Status 9 - Indico Que ocorreu Erro no processamento
	//----------------------------------------------------
	if !lErroAmb
		PutGlbValue( cJobAux , '9' )
		GlbUnlock()
	
	//---------------------------------------------------------------
	//Indico que ocorreu erro na abertura das tabelas internas do TAF
	//---------------------------------------------------------------
	else
		PutGlbValue( cJobAux , '8' )
		GlbUnlock()
	
	endif
	
endif

//----------------------------------------------------
//Exibo a mensagem de erro no console caso ocorra
//----------------------------------------------------
ErrorBlock( oError )

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafExecMT
Função responsável por processar a funçaõ indicada na chamada do IPCGO

@param	cFunIpcGO  - Nome da função que será executada
		xParXX     - Parâmetro passado através do IPCGO

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
Function TafExecMT( cFunIpcGO, xPar02, xPar03, xPar04, xPar05, xPar06,xPar07, xPar08, xPar09, xPar10 )

&cFunIpcGO.( xPar02, xPar03, xPar04, xPar05, xPar06,xPar07, xPar08, xPar09, xPar10 )

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafProc2Mt

Realiza o processamento dos JOBs do TAF em MultThread

@Param oProcess   - Barra de progresso do processamento MT
		aCodFil    - Array com o nome das filiais onde devem ocorrer os 
					   processamentos ( Amarrações da C1E/CR9 )
		cSemaphore - Nome do semaforo que será utilizado no processamento
		nQtdThread - Quantidade de Threads que foram abertas para o processamento
		lJob       - Indica se o processamento está sendo realizado via schedule
		aLayout    - Array ja populado com o layout de carga das informações
		aLaydel    - Array ja populado com o layout de exclusao das informações

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//----------------------------------------------------------------------------
Function TafProc2Mt( oProcess, aCodFil, cSemaphore, nQtdThread, lJob, aLayout, aLaydel, lDelChild, aCpoObrig, cTicketXML )

Local cFuncInteg	:=	"TafIntJob2"
Local nX			:=	0
Local aThreads		:=	{}
Local lPriorit		:=	.F.
Local lWait			:=	.F.
Local nCont         :=  0
local aTamSx3    	:=  {}
local cCacheOp   	:=  X3noLoad //"1"

default lDelChild   := .T.
default aCpoObrig	:= {}
default cTicketXML  := ""

//Cache na primeira execucao, caso ja processado, carrega a global no array de referencia.
TafLoadX3( @aTamSx3, @cCacheOp )

//Se nao existir, atribui valores default em variaveis privadas
if type("_lNoCloseTH") == "U"
	_lNoCloseTH := .F.
endif

//-----------------------------------------
//Tratamento de barra de progresso para JOB
//-----------------------------------------
if !lJob
	oProcess:Set1Progress( 2 )
	oProcess:Inc1Progress( STR0002 + alltrim(str(nQtdThread)) + STR0003  ) //"Processando integração com "#" threads.."

	oProcess:Set2Progress( 2 )
	oProcess:Inc2Progress( STR0004 ) //"Filtrando registros..."
endif

//----------------------------------------------------------------------------------						
//Realiza a separação dos registros da tabela TAFST2 por thread, alimentando o array
//aThreads com o TPREG e o nome setado para cada Thread no campo TAFIDTHRD
//----------------------------------------------------------------------------------
TAFConout( '*****Inicia a query de filtro e update - Time -> ' + Time() + ' *********',2,.T.,"INTEG" )
TafQryMTThread( aCodFil, @aThreads, nQtdThread, cTicketXML )
TAFConout( '*****Encerra a query de filtro e update - Time -> ' + Time() + ' *********',2,.T.,"INTEG" )

//-----------------------------------------
//Tratamento de barra de progresso para JOB
//-----------------------------------------
if !lJob
	oProcess:Inc2Progress( STR0005 )
	oProcess:Set2Progress( len( aThreads ) )
endif

//--------------------------------------------------------------------------------------
//Ordeno o array por ordem obrigatória de processamento ( Cadastros antes de movimentos )
//--------------------------------------------------------------------------------------
aSort( aThreads,,, { |x,y| ( AllTrim( Str( x[3] ) ) + x[1] + x[2] < AllTrim( Str( y[3] ) ) + y[1] + y[2] ) } )

For nX := 1 to Len( aThreads )
	While .T.
		nQtdThread := TafInfoTh( cSemaphore )

		//Identifica se o Layout a ser processado é predecessor e possui prioridade
		If aThreads[nX][3] == 0 .or. aThreads[nX][3] == 1
			lPriorit := .T.
		Else
			lPriorit := .F.
		EndIf

		//Se for Layout predecessor com prioridade, e o Layout a ser processado for diferente do Layout processado
		//anteriormente, ou seja, houve uma troca de Layout no laço, deverá aguardar o final do processamento do Layout anterior.
		//Para isto, é verificado se a quantidade de threads livres é igual a quantidade de threads utilizadas.
		If lPriorit .and. nX > 1 .and. aThreads[nX][1] <> aThreads[nX - 1][1] .and. IPCCount( cSemaphore ) < nQtdThread
			lWait := .T.

		//Se não for Layout predecessor com prioridade, mas o Layout processado anteriormente for um Layout
		//predecessor com prioridade, deverá aguardar o final do processamento do Layout anterior.
		//Para isto, é verificado se a quantidade de threads livres é igual a quantidade de threads utilizadas.
		ElseIf !lPriorit .and. nX > 1 .and. ( aThreads[nX - 1][3] == 0 .or. aThreads[nX - 1][3] == 1 ) .and. IPCCount( cSemaphore ) < nQtdThread
			lWait := .T.

		//Se for o layout T154, aguarda todos os predecessores, para que não seja integrado antes do 
		//T013, pois, o T154 pode estar vinculado a um T013.
		ElseIf !lPriorit .and. nX > 1 .and.  aThreads[nX][3] == 4  .and. IPCCount( cSemaphore ) < nQtdThread
			lWait := .T.
		 
		Else
			lWait := .F.
		EndIf

		If IPCCount( cSemaphore ) > 0
			If !lWait
				//------------------------------------------
				//Tratamento de barra de progresso para JOB
				//------------------------------------------
				If !lJob
					oProcess:Inc2Progress( STR0006 + aThreads[nX][1] + "..." ) //"Integrando o Registro "
				EndIf

				TAFConout( "MTThread Inicio Proximo Lote " + aThreads[nX][1] + AllTrim( Str( nX ) ) + " #Horario: " + time(),2,.T.,"INTEG" )

				/* Foi passado o cFilAnt como parametro, pois caso a rotina 
				seja executada pela rotina TAFA428 ou TafFisMt, a outra thread
				que esta em espera pelo IpcWaitEx tem que ser saber qual cFilAnt 
				ira processar, visto que o pool de threads eh aberto uma unica vez 
				para todas as filiais. Ou seja, quando trocar a filial, eh necessario 
				informar a Thread que esta em espera, qual sera a filial a ser processada. */

				IPCGo( cSemaphore, cFuncInteg, aThreads[nX][1], aThreads[nX][2], aLayout, aLaydel, cFilAnt, cEmpAnt, aTamSx3, lDelChild, aCpoObrig )
				Exit
			Else
				TAFConout( "Quantidade de Threads " + AllTrim( Str( IpcCount( cSemaphore ) ) ),2,.T.,"INTEG" )
				TAFConout( "Aguardando término dos predecessores",2,.T.,"INTEG" )
				Sleep( 300 )
				Sleep( 300 )
			EndIf
		Else
			if ++nCont > 10
				TAFConout( "Processando " + aThreads[nX][1] + ' | Lote ' +  aThreads[nX][2],2,.T.,"INTEG" )
				nCont := 0
			endif
			Sleep( 300 )
		EndIf
	EndDo
Next nX

//-------------------------------------------------------------------------------------------------------------
//Caso o array esteja vazio significa que não existem informações na TAFST2 ou De/Para cadastrado na tabela C1E
//-------------------------------------------------------------------------------------------------------------

//Trecho comentado, com a implementação de integração multi filial, onde o usuário pode selecionar filiais (tela de seleção de filiais), mas
// pode não existir registros para determinada filial na TAFST2, ficou inviável a mensagem abaixo
//if len( aThreads ) == 0
//	Conout( 'Cadastro de complemento de empresa não cadastrado para essa filial e/ou não existem informações a serem integradas na tabela TAFST2' )
	
	//if !lJob
	//	msgalert( STR0007 ) //'Cadastro de complemento de empresa não cadastrado para essa filial e/ou não existem informações a serem integradas na tabela TAFST2' 
	//endif
//endif 

//--------------------------------------------------------
//Aguarda o término do processamento das threads iniciadas
//--------------------------------------------------------
if len( aThreads ) > 0

	while IPCCount( cSemaphore ) <> nQtdThread
		nQtdThread := TafInfoTh( cSemaphore )
		TAFConout( 'Aguardando termino do processamento',2,.T.,"INTEG" )
		Sleep( 1000 ) //recomendacao chamar em partes menores e mais vezes
		Sleep( 1000 )
		Sleep( 1000 )
	enddo
endif

/*
_lNoCloseTH inicia com valor .F., caso a variavel nao exista
ou nao tenha recebido um put com valor .T., a variavel _lNoCloseTH retornara falso, 
dessa forma garante o encerramento da thread, caso nao seja chamado em Mult-Thread.
@see TAFA428.prw \ Function FProcInt()
*/

if !_lNoCloseTH
	//-----------------------------------------
	//Tratamento de barra de progresso para JOB
	//-----------------------------------------
	if !lJob
		oProcess:Inc1Progress( STR0008 ) //"Encerrando Threads Abertas..."
		oProcess:Set2Progress( nQtdThread )
	endif

	//---------------------------------------------------
	//Encerro as threads abertas durante o processamento
	//---------------------------------------------------
	for nx := 1 to nQtdThread
		//-----------------------------------------
		//Tratamento de barra de progresso para JOB
		//-----------------------------------------
		if !lJob
			oProcess:Inc2Progress( STR0009 + strzero( nx, 2 ) + "..." )
		endif
			
		TAFConout( 'Encerrando a Thread ' + strzero( nx, 2 ),2,.T.,"INTEG" )
		IPCGo( cSemaphore, 'E_X_I_T_' )
	next
endif

//-----------------------------------------
//Tratamento de barra de progresso para JOB
//-----------------------------------------
if !lJob
	oProcess:Inc1Progress( STR0010 ) //"Processo Finalizado..."
	oProcess:Inc2Progress( STR0010 ) //"Processo Finalizado..."
endif

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafIntJob2

Realiza o processamento do JOB 2

@Param cTpreg        - Registro que será processado pela Thread
		cProcThread   - Código gravado no campo TAFIDTHRD que deve ser processado por essa thread
		aLayout       - Array ja populado com o layout de carga das informações
		aLaydel       - Array ja populado com o layout de exclusao das informações

@author Rodrigo Aguilar 
@since 13/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
function TafIntJob2( cTpreg, cProcThread, aLayout, aLaydel, cTafFl, cTafEmp, aTamSx3, lDelChild, aCpoObrig )

local _cKey       := ''
local _cTafKey    := ''

local cFilRegInt  := ''
local cIdThread   := StrZero( ThreadID(), 10 )

local cTAFCodTxt  := Arquivo_Tipo_Texto  //Somente para processamento via TEXTO
local cStsReady   := Status_Pendente     //Pendentes de Processamento	 

local nI          := 0
local nST2Rec	  := 0
local lEnd        := .F.
local lFindErr    := .F.

local aRecInt	    := {}					  //Armazena todos os Recnos que foram processados

local aDadosST2   := {}

local oError      := nil 

local lTafErrorLog  := .F.				  //Variável que controla caso ocorra erro no Begin Sequence

default aLayout := {}
default aLaydel := {}
default aTamSx3 := {}

default lDelChild := .T.
default aCpoObrig := {}

oError := ErrorBlock( { |Obj| FErrorTaf( Obj, @lTafErrorLog, 'TafIntJob2' ) } )

//---------------------------------------------
//Chave utilizada no Indice da tabela TAFST2
//---------------------------------------------
dbSelectArea(cST2Alias)
(cST2Alias)->( DBSetOrder( 7 ) ) 	//TAFIDTHRD + TAFCODMSG + TAFSTATUS + TAFFIL + TAFDATA + TAFHORA + TAFTICKET + TAFKEY + TAFSEQ

//--------------------------------------------------
//Chave utilizada no Indice da tabela C1E
//--------------------------------------------------
dbSelectArea('C1E')
C1E->( DBSetOrder( 7 ) ) 			//C1E_FILIAL + C1E_CODFIL + C1E_ATIVO

//--------------------------------------------
//Chave utilizada no Indice da tabela TAFXERP
//--------------------------------------------
dbSelectArea(cXERPAlias)
(cXERPAlias)->( DBSetOrder( 2 ) )  //TAFKEY

//--------------------------------
//Chave utilizada no Indice da SX3
//--------------------------------
SX3->( DBSetOrder( 2 ) ) 			//X3_CAMPO

//----------------------------------------------------------------
//Normalizo o código para o tamanho do IDTHREAD definido na tabela
//----------------------------------------------------------------
cProcThread := padr( cProcThread, 10 )
	
//---------------------------------------------------------------
//Posiciono no primeiro registro à ser processado por essa thread
//---------------------------------------------------------------		
_cKey := (cST2Alias)->( cProcThread + cTAFCodTxt + cStsReady ) 
if (cST2Alias)->( MsSeek( _cKey ) ) 
	
	//---------------------------------------------------------------------------------
	//Tratamento para que caso ocorra Erro durante o processamento não estoure na tela
	//é exibida uma mensagem tratada do erro para o usuário final
	//---------------------------------------------------------------------------------	
	//PtInternal( 1 , 'Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - Emp: ' + cEmpAnt + ', Fil: ' + cFilAnt + ' - Processando movimento ' + cTpreg )
	TafConout('Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - Emp: ' + cEmpAnt + ', Fil: ' + cFilAnt + ' - Processando movimento ' + cTpreg )
	TcInternal( 1 , 'Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - ' + ConType() + ' - Processando movimento ' + cTpreg )
	
	Begin Sequence 
	   	
		while (cST2Alias)->( !Eof() ) .and. _cKey == (cST2Alias)->( TAFIDTHRD + TAFCODMSG + TAFSTATUS ) .And. !KillApp()
			
			lTafErrorLog := .F.
						
			//--------------------------------------------------------------------------------------
			//O array será populado para cada TAFKEY da tabela TAFST2, recebendo a mensagem que será
			//interpretada e integrada para o TAF
			//--------------------------------------------------------------------------------------						
			aDadosST2 := {}			
						
			//-------------------------------------------------------------------------------------------
			//Monto chave unitário do registro ( Por TAFKEY ), para execução da TAFVERESTRU e TAFPROCLINE
			//-------------------------------------------------------------------------------------------
			_cTafKey := (cST2Alias)->( TAFIDTHRD + TAFCODMSG + TAFSTATUS + TAFFIL + dtos(TAFDATA) + TAFHORA + TAFTICKET + TAFKEY ) 
									
			//------------------------------------------------
			//Verifico se a mensagem possui erro de estrutura
			//------------------------------------------------
			nST2Rec := (cST2Alias)->( recno() )
			lFindErr  := TAFVerEstru( @lEnd, cST2Alias, aLayout, .F., cXERPAlias, _cTafKey, @aDadosST2, @aRecInt, @lTafErrorLog )

			if _cKey <> (cST2Alias)->( TAFIDTHRD + TAFCODMSG + TAFSTATUS )
				(cST2Alias)->( DbGoTo( nST2Rec ) )
			endif
			//----------------------------------------------------------------------------------------------------------------------			
			//Caso não tenha ocorrido erro log na validação de estrutura sigo com o processamento, caso contrário vou para o próximo
			//registro setando o corrente como inconsistente na TAFXERP
			//----------------------------------------------------------------------------------------------------------------------
			if !lTafErrorLog
						
				//------------------------------------------------------------------------------------			
				//Somente realizo a integração do registro caso não tenha ocorrido erro na validaçao 
				//de estrutura, assim seu status se mantém o mesmo após o processamento do TAFVerEstru
				//------------------------------------------------------------------------------------
				if !lFindErr	
					
					//-----------------------------------
					//Valida Chave Duplicada na mensagem
					//-----------------------------------
					cMsg := FGetDuplic( /*1*/, .F., .F., aDadosST2, @lTafErrorLog, aLayout, aTamSx3 )

					//-------------------------------------------------------------------------------			
					//Caso tenha ocorrido Error Log na validação acima avanço para o próximo registro,
					//caso contrário executo a integração do registro
					//-------------------------------------------------------------------------------
					if !lTafErrorLog

						//-------------------------------------------------------
						//Verifica se foi encontrada mensagem com chave duplicada
						//-------------------------------------------------------
						if empty( cMsg )
							//-------------------------------
							//Realizo a integração do TAFKEY
							//-------------------------------			
							cFilRegInt := (cST2Alias)->TAFFIL
							TAFProcLine(.F.,cST2Alias,cFilRegInt,@aDadosST2,/*5*/,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,cXERPAlias,.T.,@lTafErrorLog,aLayout,aLaydel,/*16*/,aTamSx3,lDelChild, aCpoObrig)

							//-----------------------------------------------
							//Caso tenha ocorrido error log gravo na TAFXERP
							//-----------------------------------------------
							if lTafErrorLog
								TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000016" )
							endif
						
						//------------------------------------
						//Gravo erro de duplicidade na TAFXERP
						//------------------------------------	
						else						
							TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000005" )						
						endif	
					
					//--------------------------------------------------------------------------------------------------------------------------
					//Ocorrerá Error Log na FGetDuplic quando na mensagem( TAFMSG) não for enviado algum campo que faça parte da chave (X2_UNIC)
					//--------------------------------------------------------------------------------------------------------------------------
					else
						TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000015" )						
					endif										
					
				endif	
			
			//-----------------------------------------------
			//Caso tenha ocorrido error log gravo na TAFXERP
			//-----------------------------------------------
			else
				TafGrvTick( cXERPAlias, "1", ( cST2Alias )->TAFKEY, ( cST2Alias )->TAFTICKET,,, "9", "000016" )						
			endif
			
			(cST2Alias)->( dbSkip() )						
		enddo	
	
		//-------------------------------------------------------------------------------------------
		//Após o processamento da integração realizo a alteração de status dos registros processados 
		//para 3 e gravo o id da Thread responsável pela integração
		//-------------------------------------------------------------------------------------------
		For nI := 1 to Len( aRecInt )
			
			(cST2Alias)->( dbGoTo( aRecInt[nI,1] ) )
		
			If RecLock( cST2Alias, .F. )
				(cST2Alias)->TAFSTATUS := '3'
				(cST2Alias)->TAFIDTHRD := cIdThread
				(cST2Alias)->( DBCommit(), MsUnLock() )
			EndIf
			
		Next
					
	End Sequence
	
	//PtInternal( 1 , 'Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - Emp: ' + cEmpAnt + ', Fil: ' + cFilAnt + ' - Processamento finalizado, aguardando... ' )
	TafConout('Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - Emp: ' + cEmpAnt + ', Fil: ' + cFilAnt + ' - Processamento finalizado, aguardando... ' )
	TcInternal( 1 , 'Thread( ' + AllTrim( cProcThread )+"/"+cIdThread + ' ) - ' + ConType() + ' - Processamento finalizado, aguardando... ' )
			
endif

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafQryMTThread

Realiza a divisão do processamento que será realizado no IPCGO, garantindo que o mesmo TAFKEY 
sempre seja processado pela mesma Thread devido a campo TAFSEQ( Sequencializador )


@Param aCodFil    - Filiais que devem ser consideradas no processamento ( C1E da filial que o usuario esta logado )
		aThreads   - Array com o controle de Threads, cada posição criada no array será um comando IPCGO
		             realizado para a MultThread
		nQtdThread - Quantidade de threads de processamento configurada

@author Rodrigo Aguilar 
@since 19/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
Function TafQryMTThread( aCodFil, aThreads, nQtdThread, cTicketXML )

local cProcThread := ''
local cSelect     := ''
local cUpdate     := ''
local cCodFil     := ''

local cRegsQry  := '25' 		//Quantidade de registros a serem processados por Thread
local nRestQry	:= 0

local cST2TAB	  := 'TAFST2'

local cBanco   := Upper(AllTrim(TcGetDB()))  

Local nLimite  := GetNewPar("MV_TAFLPRC",2000)
Local nQtdRegThr:= 0
local nX       := 0
local nTotReg  := 0
local nOrder   := 0
Local nSqlExec := 0
local cAlsThread := GetNextAlias()

Default nQtdThread	:=	0
Default cTicketXML  := ""

//------------------------------------------------------------------------------------
//atribuo as filiais ( TAFFIL ) relacionadas a empresa que executou o Job a uma string
//que sera utilizada na clausula WHERE
//------------------------------------------------------------------------------------
for nX := 1 to len( aCodFil )
	cCodFil	+=	"'" + allTrim( aCodFil[ nX ] ) + "', "
next nX
cCodFil :=	subStr( cCodFil , 1 , len( cCodFil ) - 2 )

//-----------------------------------------------------------------------------------------------------
//Busco todos os TAFTPREGS e o total de cada um que existem para processamento do job 2 na tabela TAFST2
//-----------------------------------------------------------------------------------------------------
cSelect := " SELECT ST2.TAFTPREG, COUNT( DISTINCT ST2.TAFKEY ) TOTAL FROM " + cST2TAB + " ST2 "

if !empty( cCodFil )
	cSelect += " WHERE ST2.TAFFIL IN ( " + cCodFil + " ) "	
else
	cSelect += " WHERE ST2.TAFFIL IN ( '' ) "
endif
cSelect += " AND ST2.TAFCODMSG = '1' "
cSelect += " AND ST2.TAFSTATUS = '1' "
if !Empty( cTicketXML ) //Tratamento para filtrar apenas o ultimo ticket extraido, utilizado no processo unico de geracao da nova gia sp
	cSelect += " AND ST2.TAFTICKET = '" + cTicketXML + "' "
endif
cSelect += " AND ST2.D_E_L_E_T_ = ' ' "

cSelect += " GROUP BY ST2.TAFTPREG "
cSelect += " ORDER BY ST2.TAFTPREG "

cSelect := ChangeQuery( cSelect )
dBUseArea( .T., "TOPCONN", TCGenQry( ,, cSelect ), cAlsThread, .T., .F. )
  
//-----------------------------------------------------------
//Laço executado para cada TPREG encontrado para processamento
//-----------------------------------------------------------
while (cAlsThread)->( !eof() )

	cTpReg := AllTrim( ( cAlsThread )->TAFTPREG ) //Registro a ser processado
	TAFConout( "Preparando processamento do registro " + cTpReg,2,.T.,"INTEG" )

 	//------------------------------------------------------------------------------
 	//Para o Registro T010, como ele faz referência a ele mesmo ( Conta Superior ),
 	//não é possível dividir o processamento em mais de uma thread.
 	//------------------------------------------------------------------------------ 
 	If cTpReg == "T010"
 		nTotReg := 1
 	//Tratamento para dividir o volume de movimento pela quantidade de threads configuradas, de forma a não exigir um número fixo, assim mantemos as threads sempre processando
 	ElseIf !( cTpReg $ "T087|T088" ) .and. nQtdThread > 0 .and. ( cAlsThread )->TOTAL > nQtdThread
 		nQtdRegThr := (cAlsThread)->TOTAL / nQtdThread
 		If nQtdRegThr > nLimite 
	 		nTotReg := Round((cAlsThread)->TOTAL / nLimite + 1, 0)
	 	Else 
	 		nTotReg := nQtdThread
	 	EndIf 
	 	
	 	cRegsQry := AllTrim( Str( Int( Min(nQtdRegThr, nLimite ) )) )
		nRestQry := MOD(( cAlsThread )->TOTAL, nQtdThread )
	
 	//Busco a quantidade de execuções que terei que realizar para o bloco
 	Else
 		nTotReg := ( cAlsThread )->TOTAL
		cRegsQry := "1"
 	EndIf
	    
	//----------------------------------------------------------------------------------------
	//Executo o UPDATE na TAFST2 setando no campo TAFIDTHRD qual thread será a responsável pelo
	//processamento de cada informação
	//----------------------------------------------------------------------------------------
	for nX := 1 to nTotReg
		
		//-------------------------------------------------------------------------------
		//Armazeno a quantidade de quebras que realizei para controlar a chamada do IPCGO
		//-------------------------------------------------------------------------------
		cProcThread := PadL( cEmpAnt + cvaltochar( len( aThreads ) + 1 ) , 10 , "0" )

		//-----------------------------------------------------------------------------------------------
		//Defino neste momento a ordem de prioridade que deve ser assumida para cada layout na importação
		//-----------------------------------------------------------------------------------------------
		if cTpReg $ ( 'T011|T005|T161|')
			nOrder := 0
		elseif cTpReg $ ( 'T003|T007|T010|T157|T159|T160|T135|') 
			nOrder := 1
		elseif  cTpReg $ ('T125|T134|')
			nOrder := 2
		elseif  !(cTpReg $ ('T154'))
			nOrder := 3
		else
			nOrder := 4
		endif						
		
		aAdd( aThreads, { cTpReg, cProcThread, nOrder} ) 

		//----------------------------------------------------------------------------------------------
		//No caso do registro T010 não existe quebra de processamento por Thread, assim uma única thread
		//processa todos os T010
		//----------------------------------------------------------------------------------------------	
		if cTpReg <> 'T010'
			if !( cBanco $ ( "|INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|" ) )
				cSelect := " SELECT DISTINCT TOP " + cRegsQry + " ST2.TAFKEY "

			elseif cBanco == 'INFORMIX'
				cSelect := "SELECT * FROM ( SELECT FIRST " + cRegsQry + " TAFKEY "

			else
				cSelect := " SELECT ST2.TAFKEY "
			endif		
		else
			if cBanco == 'INFORMIX'
				cSelect := "SELECT * FROM ( SELECT TAFKEY "
			else
				cSelect := " SELECT ST2.TAFKEY "
			endif		
		endif
		
		cSelect += " FROM " + cST2TAB + " ST2 "
		cSelect += " WHERE ST2.TAFFIL IN ( " + cCodFil + " ) "
		cSelect += " AND ST2.TAFCODMSG = '1' "
		cSelect += " AND ST2.TAFSTATUS = '1' "
		if !Empty( cTicketXML ) //Tratamento para filtrar apenas o ultimo ticket extraido, utilizado no processo unico de geracao da nova gia sp
			cSelect += " AND ST2.TAFTICKET = '" + cTicketXML + "' "
		endif
		cSelect += " AND ST2.TAFIDTHRD = ' ' "
		cSelect += " AND ST2.TAFTPREG = '" + cTpReg + "' "
		cSelect += " AND ST2.D_E_L_E_T_ = ' ' "
		
		//Para informix fecha o parenteses so subselect
		if cBanco == 'INFORMIX'	
			cSelect +=	")" 
		endif

		//----------------------------------------------------------------------------------------------
		//No caso do registro T010 não existe quebra de processamento por Thread, assim uma única thread
		//processa todos os T010
		//----------------------------------------------------------------------------------------------		
		if cTpReg <> 'T010'
			if cBanco == "ORACLE"
				cSelect += " AND ROWNUM <= " + cRegsQry
			elseIf cBanco == "DB2"
				cSelect += "FETCH FIRST " + cRegsQry + " ROWS ONLY "
			elseif cBanco $ "POSTGRES"
				cSelect += " LIMIT " + cRegsQry + " "
			endif
		endif

		//---------------------------------------------------------
		//Realizo o UPDATE no campo TAFIDTHRD filtrando por TAFKEY
		//---------------------------------------------------------
		cUpdate := " UPDATE " + cST2TAB + " "  							
		cUpdate += " SET TAFIDTHRD = '" + cProcThread + "' "		
		cUpdate += " WHERE "
		cUpdate += " TAFKEY IN ( " + cSelect + " ) AND "
		if !Empty( cTicketXML ) //Tratamento para filtrar apenas o ultimo ticket extraido, utilizado no processo unico de geracao da nova gia sp
			cUpdate += "TAFTICKET = '" + cTicketXML + "' AND "
			cUpdate += "TAFFIL IN ( " + cCodFil + " ) AND "
		endif
		cUpdate += " D_E_L_E_T_ = ' ' "
		nSqlExec := TCSQLExec( cUpdate )
		RtSqlExec(nSqlExec, cUpdate)
		
	next

	//Cria uma thread a mais, para os registros que sobraram na divisão das threads.
	If nRestQry > 0
		cProcThread := PadL( cEmpAnt + cvaltochar( len( aThreads ) + 1 ) , 10, "0" )

		//-----------------------------------------------------------------------------------------------
		//Defino neste momento a ordem de prioridade que deve ser assumida para cada layout na importação
		//-----------------------------------------------------------------------------------------------
		if cTpReg $ ( 'T011|T005|T161|')
			nOrder := 0
		elseif cTpReg $ ( 'T003|T007|T010|T157|T159|T160|T135|')
			nOrder := 1
		elseif  cTpReg $ ('T125|T134|')
			nOrder := 2
		elseif  !(cTpReg $ ('T154'))
			nOrder := 3
		else
			nOrder := 4
		endif

		aAdd( aThreads, { cTpReg, cProcThread, nOrder } ) 

		cSelect := " SELECT ST2.TAFKEY "
		cSelect += " FROM " + cST2TAB + " ST2 " 
		cSelect += " WHERE ST2.TAFFIL IN ( " + cCodFil + " ) "
		cSelect += " AND ST2.TAFCODMSG = '1' "
		cSelect += " AND ST2.TAFSTATUS = '1' "
		if !Empty( cTicketXML ) //Tratamento para filtrar apenas o ultimo ticket extraido, utilizado no processo unico de geracao da nova gia sp
			cSelect += " AND ST2.TAFTICKET = '" + cTicketXML + "' "
		endif
		cSelect += " AND ST2.TAFIDTHRD = ' ' AND ST2.TAFTPREG = '" + cTpReg + "' AND ST2.D_E_L_E_T_ = ' ' "

		//---------------------------------------------------------
		//Realizo o UPDATE no campo TAFIDTHRD filtrando por TAFKEY
		//---------------------------------------------------------
		cUpdate := " UPDATE " + cST2TAB + " "  							
		cUpdate += " SET TAFIDTHRD = '" + cProcThread + "' "  			
		cUpdate += " WHERE "		
		cUpdate += " TAFKEY IN ( " + cSelect + " ) AND "
		if !Empty( cTicketXML ) //Tratamento para filtrar apenas o ultimo ticket extraido, utilizado no processo unico de geracao da nova gia sp
			cUpdate += "TAFTICKET = '" + cTicketXML + "' AND "			
			cUpdate += "TAFFIL IN ( " + cCodFil + " ) AND "
		endif
		cUpdate += "D_E_L_E_T_ = ' ' "

		nSqlExec := TCSQLExec( cUpdate )
		RtSqlExec(nSqlExec, cUpdate)

		nRestQry := 0 
	EndIf
	(cAlsThread)->( dbSkip() )
enddo
(cAlsThread)->( dbCloseArea() )
 
return

//-------------------------------------------------------------------
/*{Protheus.doc} FErrorTaf

Função executada pelo ErrorBlock, printa o erro no console e altera o valor da variável de controle interno
de erro para posterior tratamento na função


@Param Obj           - Nome do objeto passado pelo ErrorBlock
		lTafErrorLog  - Variável de controle de erro
		             

@author Rodrigo Aguilar 
@since 23/05/2016
@version 1.0
*/ 
//--------------------------------------------------------------------
function FErrorTaf( Obj, lTafErrorLog, cFunc )

Local cTicketGia := GetGlbValue("FISAEXTEXC_TKTEXT") //Variavel global populada quando vier pelo processo unico da nova gia sp
Local cExcecao 	 := '-37' //DB error (Insert): -37 A operacao atual nao foi executada com sucesso (chave unica)
Default cFunc    := ''

if Valtype(cTicketGia) == "C" .And. !Empty(cTicketGia) .And. cFunc == 'TAFProcLine' .And. Valtype(Obj:Description) == "C" .And. cExcecao $ Obj:Description	
	cTabAlias := SubStr(Alltrim(Obj:Description),1,3)
	if ascan( aCacheTB , cTabAlias ) > 0 //Verifica se esta nas principais tabelas relacionadas a nota fiscal ( TMS / GIA )
		//Nao sera gravado tafticket com codigo 16(por erro de chave unica) no processo unico da nova gia sp
		//pois ja foi inserido em outro tafkey e a nota constara como valida no gerenciador de integracao.
		lTafErrorLog := .F. 
	endif
else
	lTafErrorLog := .T.
endif

TAFConout( 'MT - Mensagem de Erro: ' + Chr(10)+ Obj:Description,3,.T.,"INTEG" )

return

//-------------------------------------------------------------------
/*{Protheus.doc} TafInfoTh

@Param cSemaphore - Nome do pool de threads

@author Denis Souza / Henrique F.
@since 15/05/2020
@version 1.0
*/ 
//--------------------------------------------------------------------
Static Function TafInfoTh( cSemaphore )

	Local nTafQtTh 	:= 0
	Local aMonitor 	:= GetUserInfoArray()
	Local nX 	 	:= 0

	For nX := 1 To Len(aMonitor)
		If Alltrim(Upper(aMonitor[nX][5])) == "TAFCHECKMT"
			++nTafQtTh
		endif
	Next nX

Return nTafQtTh

//-------------------------------------------------------------------
/*{Protheus.doc} TafCacheX3
Necessario cachear os principais campos das notas,
devido alta qtd de registros, ex: 6.000.000 registros sequoia.
Foi necessario exclusivamente para movimentação de notas.

@Param aTamSx3 - Lista de campos para cachear

@author Denis Souza
@since 29/06/2021
@version 1.0
*/ 
//--------------------------------------------------------------------
Static Function TafCacheX3( aTamSx3 )

	Local nlA 	   := 1
	Local nlB 	   := 1
	Local nQtTB    := len( aCacheTB )
	Local nQtCmp   := 0
	Local aCampos  := {}
	Local aProp    := {}
	Local lVirtual := .F.

	Default aTamSx3 := {}

	for nlA := 1 to nQtTB
		aCampos := FWSX3Util():GetAllFields( aCacheTB[nlA] , lVirtual )
		nQtCmp  := len( aCampos )
		for nlB := 1 to nQtCmp
			aProp := FWSX3Util():GetFieldStruct( aCampos[nlB] )
			aadd( aTamSx3, { aProp[1], aProp[3] } )
		next nlB
	next nQtTB

	aSort( aTamSx3,,,{|x,y| x[1] < y[1]} )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TafLoadX3
Controle para saber se deve iniciar o carregamento da TafCacheX3,
ou apenas fazer o get nas variaveis globais.

@author  Denis Naves
@since   29/06/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function TafLoadX3( aTamSx3, cCacheOp )

	default aTamSx3  := {}
	default cCacheOp := ""

	GetGlbVars( 'ACACHEX3', @aTamSx3 )
	GetGlbVars( 'CLOADX3' , @cCacheOp )

	while cCacheOp == X3loading	//"2" carregando
		GetGlbVars('CLOADX3', @cCacheOp )
		TAFConout( "Aguardando cache SX3",2,.T.,"INTEG")
		sleep(250)
	enddo

	if len(aTamSx3) == 0 .And. cCacheOp == X3noLoad	//"1" nao carregado

		PutGlbVars( "CLOADX3", X3loading )	//"2" carregando
		
		TafCacheX3( @aTamSx3 )
		PutGlbVars( "ACACHEX3", aTamSx3 )	//referencia para as threads

		PutGlbVars( "CLOADX3" , X3loaded )	//"3" carregado
	endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafTmSx3
Verifica tamanho de campos cacheados, caso nao encontre no cache
como prioritario, sera utilizado a propria funcao padrao TamSX3.
Utilizado no TAFAINTEG e TAFTICKET

@author  Denis Naves
@since   29/06/2021
@version 1
/*/
//-------------------------------------------------------------------
Function TafTmSx3( cCol, aTamSx3 )

	local nTmSX3    := 0
	local nLenX3    := 0

	default cCol 	:= ''
	default aTamSx3 := {}

	nLenX3 := Len( aTamSx3 )

	if nLenX3 > 0
		nPos := aScan( aTamSx3, { |x| alltrim(x[1]) == cCol } )
		if nPos > 0
			nTmSX3 := aTamSx3[nPos][2]
		else
			nTmSX3 := TamSX3(cCol)[1] //funcao padrao, mantem o funcionamento anterior, caso nao encontre na relacao de cache.
		endif
	else
		nTmSX3 := TamSX3(cCol)[1] //funcao padrao, mantem o funcionamento anterior, caso nao encontre na relacao de cache.
	endif

Return nTmSX3

//-------------------------------------------------------------------
/*/{Protheus.doc} ErroProc
Encerra a thread com erro

@author  Karen Honda
@since   25/05/2022
@version 1
/*/
//-------------------------------------------------------------------
Static Function ErroProc(lErrorProc,nQtdThread,cSemaphore)
Local nI as Numeric

Default lErrorProc := .F.
Default nQtdThread := 0
Default cSemaphore := ""

If lErrorProc 
	for nI := 1 to nQtdThread		
		TAFConout( 'Encerrando a Thread ' + strzero( nI, 2 ),2,.T.,"INTEG" )
		IPCGo( cSemaphore, 'E_X_I_T_' )
	next
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RtSqlExec
Realiza o commit da query ou gera o erro

@author  Karen Honda
@since   25/05/2022
@version 1
/*/
//-------------------------------------------------------------------
Static Function RtSqlExec(nSqlExec,cUpdate)
Default nSqlExec := 0
If nSqlExec >= 0
	If InTransAction()
		TcSqlExec( "COMMIT" )
	EndIf
Else
	TAFConout( "Erro... " + TCSQLError() + " -> " + cUpdate,3,.T.,"INTEG" )
EndIf
Return
