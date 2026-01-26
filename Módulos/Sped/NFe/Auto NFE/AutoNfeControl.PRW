#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"  

Static __cProcesso	:= "" 
Static __cEmpresa	:= ""
Static __cFilEmp	:= ""
Static __nLote		:= 0
Static __nThreads 	:= 0
Static __cSerie		:= ""

static __lAutomacao := findfunction("GetParAuto")

//------------------------------------------------------------------
/*/{Protheus.doc} validaAutoNfe
Valida o lock do processo principal.

@param cEmpresa				Emprsa
@param cFilEmp				Filial                          
@param cFilEmp				Serie
@param nLote				Numero de documentos por lote
@param nThreads				Numero de threads que serao abertas  

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12

/*/
//------------------------------------------------------------------
function validaAutoNfe( cProcesso, cEmpresa, cFilEmp, cSerie, nLote, nThreads)

local nX			:= 0
local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
local cProcName		:= ""
local cLockFile 	:= ""
local aJobsName 	:= {}
local nHdlJob		:= 0

private lUsaColab	:= UsaColaboracao("1")

default cEmpresa 	:= cEmpAnt
default cFilEmp 	:= cFilAnt
default nLote		:= 50
default nThreads	:= 1

//-----------------------------------------------
// Verifica se eh TC 2.0 e se executou o Update
//-----------------------------------------------
If lUsaColab
	lUsaColab := ColCheckUpd()
Endif     

//-------------------------------------------------------
// Soh validara parametro MV_SPEDURL caso nao for TC 2.0 
//-------------------------------------------------------
if Empty( Alltrim( cUrl ) ) .and. !lUsaColab

	autoNfeMsg( 'Parâmtro "MV_SPEDURL" não configurado', .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso )
	
else

	//-------------------------------------------
	// Inicializacao das variaveis
	//-------------------------------------------
	__cProcesso	:= cProcesso
	__cEmpresa	:= cEmpresa
	__cFilEmp	:= cFilEmp
	__nLote		:= nLote
	__nThreads	:= max(nThreads,1)
	__cSerie	:= cSerie
	
	cProcName	:= getProcName( cProcesso )
	cLockFile 	:= ""
	aJobsName 	:= { "autonfetrans", "autonfemon", "autonfecanc" }
	
	//-------------------------------------------
	// Montagem do arquivo do job principal
	//-------------------------------------------
	cLockFile := lower( aJobsName[val(__cProcesso)] + __cEmpresa + __cFilEmp + __cSerie ) + ".lck"
	
	//---------------------------------------------
	// Verifica se a thread principal esta rodando
	//---------------------------------------------
	for nX := 1 To 2
		nHdlJob := JobSetRunning( cLockFile, .T. )		
		if( nHdlJob >= 0  )	
		
			autoNfeMsg( "Iniciando o processo principal de " + cProcName, .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso) 
			autoNfeMsg( "Total de Threads habilitadas: " + alltrim(str(__nThreads)) , .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso) 
			
			autoNfeControl( cUrl , lUsaColab )
			
			//-------------------------------------------
			// Libera o Lock
			//-------------------------------------------
			JobSetRunning( cLockFile, .F., nHdlJob )
			
			autoNfeMsg( "Finalizando o processo principal de " + cProcName, .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso) 
				
			Exit
				
		Else
			
			//-------------------------------------------
			// Thread principal em Lock
			//-------------------------------------------
			autoNfeMsg( "Falha na inicialização do processo de " + cProcName, .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso) 
			
			sleep( 3000 )
			
		Endif
	
	next
	
endif

aJobsName	:=	aSize( aJobsName , 0 )
aJobsName	:=	nil

__cProcesso	:= nil
__cEmpresa	:= nil
__cFilEmp	:= nil
__nLote		:= nil
__nThreads 	:= nil
__cSerie	:= nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} autoNfeControl
Funcao que controla a execucao dos jobs dos processos do autoNFe.

@param cEmpresa	Emprsa
@param cFilEmp	Filial                          
@param cProcesso			Processos:	1 - Transmissão
										2 - Monitoramento
										3 - Cancelamento

@param nLote				Numero de documentos por lote
@param nThreads				Numero de threads que serao abertas  

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
static function autoNfeControl( cUrl, lUsaColab)

local aProcessa		:= {}
local aDocs			:= {}
local aModelo		:=  &(GetNewPar("MV_MODTAUT",'{"55"}'))  //verifica qual modelo de documento sera utilizado no schedulle
local cIdEnt		:= ""
local cAlias		:= "" 
local nCount		:= 0 
local nX			:= 0
local ni			:= 0
local lProcessa		:= .F.
local lLoop			:= .T.
local cUltHrProc	:= ""
local aJobsName		:= getJobsSecName()
local nTotReg		:= 0
local lMultThread	:= __nThreads > 1
local nQtdJobs		:= len(aJobsName)

default lUsaColab	:= UsaColaboracao("1")

cIdEnt := if(lUsaColab, "000000", getCfgEntidade() )

If Empty(aModelo)
	aModelo := {"55"} 
Endif	

delClassIntF()

for nX := 1 to len(aModelo)

	// Executa a query do processo
	cAlias := executeQuery( aModelo[nX] )
	
	if ( !empty(cAlias) )
		
		begin sequence
		
		RefresMoni(" Mod: " + aModelo[nX] )
		autoNfeMsg( "Iniciando processo dos documentos", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
		cUltHrProc := time()

		while (cAlias)->(!eof()) 
		
			lProcessa	:= .F.
				
			nCount++
			
			aDocs := preparaDocumento( cAlias, __cProcesso )
				
			delClassIntF()
			
			if len(aDocs) > 0
	
				autoNfeMsg( "Adicionando documento no lote ( Contagem: "+allTrim(str(nCount))+" )", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
	
				aAdd( aProcessa, aDocs )
				
			endif	
	
			(cAlias)->(dbSkip())
		
			if ( nCount == __nLote ) .Or. ( (cAlias)->(eof()) .And. ( !lProcessa .and. len(aProcessa) > 0 ) )
				
				lLoop := .T.
				while lLoop
					//valida se tem alguma thread disponvel
					for ni := 1 to nQtdJobs
						cLockFile := aJobsName[ni]
						if !lMultThread .or. !jobIsRunning( cLockFile )
							lLoop  := .F.
							Exit
						endIf
					next
					
					if !lLoop
						exit
					elseif !horaValida(cUltHrProc) //valida se passou mais de 1 hora aguardando
						autoNfeMsg( "O Processamento do modelo '" + aModelo[nX] + "' sera finalizado devido a falta de thread disponivel no tempo determinado.", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
						break
					endIf
					sleep(3000) //aguarda 3 seg para alguma liberação de threads
				end
				
				nTotReg 	+= nCount //totalizador de registros
				lProcessa	:= .T. 
			
				autoNfeMsg( "Inicio do processamento do documento", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
				
				If lUsaColab .or. __lAutomacao
					execJobAuto( cLockFile, __cProcesso, aProcessa, __cEmpresa, __cFilEmp, cIdEnt, cUrl, aModelo[nX], __cSerie , lUsaColab, .F. )
				Else
					autoNfeMsg("[" + alltrim(str(ThreadId())) + "]- Iniciando execucao 'execJobAuto' processo '" + __cProcesso  +"' - cLockFile: " + cLockFile)
					startJob( "execJobAuto", getEnvServer(), !lMultThread, cLockFile, __cProcesso, aProcessa, __cEmpresa, __cFilEmp, cIdEnt, cUrl, aModelo[nX], __cSerie, lUsaColab, .T.)
				EndIf
				if lMultThread
					sleep(3000) //aguarda 3 segundas para criação de semaforos
				endIf

				delClassIntF()
	
				aProcessa 	:= {} 
				nCount		:= 0
				
				//atualiza as horas da ultima execução
				cUltHrProc := time()
			endif						
				
		enddo

		end sequence
		
		delClassIntF()
		aProcessa 	:= {}
		nCount		:= 0

		(cAlias)->(dbCloseArea())
		
	endif
next

//tratamento para nao ter duas execuções de autonfe ao mesmo tempo (evitar transmissao duplicadas)
vldFimExec(aJobsName, lMultThread)

autoNfeMsg( "JOB Finalizado [Total de Registros: " + allTrim(str(nTotReg)) + "]", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)

aProcessa	:=	aSize( aProcessa , 0 )
aProcessa	:=	nil
aDocs		:=	aSize( aDocs , 0 )
aDocs		:=	nil
aModelo		:=	aSize( aModelo , 0 )
aModelo		:=	nil
aJobsName	:= 	aSize( aJobsName , 0 )
aJobsName	:=	nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Funcao retorna a query.

@param cProcesso	Tipo do processo     
					1 - Transmissao
					2 - Monitoramento
					3 - Cancelamento

@return cQuery		Query que sera executada

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
static function getQuery(cModelo)
      
local cQuery	:= ""

if ( __cProcesso == "1" )		// Transmissao

	cQuery := retQueryTrans( .T./*lAutoNFe*/, , , __cSerie, cModelo )

elseif ( __cProcesso == "2" )

	cQuery := retQueryMon( __cSerie, cModelo)
	
elseif ( __cProcesso == "3" )

	cQuery := retQueryCanc( __cSerie, cModelo)

endif

autoNfeMsg( "Query do processo de " + getProcName( __cProcesso ) + ": " + allTrim( cQuery ) )

return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} executeQuery
Funcao executa a query.

@param cQuery		Query que sera executada
@param cProcesso	Processo: 	1 - Transmissao
								2 - Monitoramento
								3 - Cancelamento			

@return cAlias		Alias da query executada

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
static function executeQuery( cModelo )

local cAlias	:= ""
local cQuery	:= ""
local cProcName	:= getProcName( __cProcesso )

// Retorna a query do processo
cQuery := getQuery( cModelo )

if !empty(cQuery)
	
	autoNfeMsg( "Executando query do processo de " + cProcName + " do modelo " + cModelo, .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)

	cAlias := getNextAlias()
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

	if __cProcesso == "1"
	
		TcSetField(cAlias,"F3_ENTRADA","D",08,0)

		TcSetField(cAlias,"F3_DTCANC","D",08,0)
	
	endif
		
	if ( (cAlias)->(eof()) )
	
		(cAlias)->(dbCloseArea())
		
		cAlias := ""

		autoNfeMsg( "Query nao retornou registros do processo " + cProcName + " do modelo " + cModelo, .T., __cEmpresa, __cFilEmp, __cSerie, __cProcesso) 
		
	endif  
	
endif

return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} preparaAmbiente
Funcao que prepara o ambiente.

@param cEmpresa		Emprsa
@param cFilEmp		Filial 

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function preparaAmbiente( cEmpresa, cFilEmp, cSerie , lUsaColab, lOpenEnv )
Local cCko := "" 
Local cCkp := "" 
local cCkq := ""

default lOpenEnv := .T.

autoNfeMsg( "Preparando ambiente", .T., cEmpresa, cFilEmp, cSerie )

if lUsaColab
	cCko := "CKOCOL" 
	cCkp := "CKP" 
	cCkq := "CKQ"
endif

if lOpenEnv
	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cFilEmp MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SB1","SB5","SF3","SF4","DT6",cCko,cCkp,cCkq
endif

autoNfeMsg( "Ambiente preparado" )

return

static function fechaAmbiente( lUsaColab, lOpenEnv )

	If !lUsaColab .and. lOpenEnv
		RESET ENVIRONMENT
	EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} preparaDocumento
Funcao que prepara os documentos a serem enviados.

@param cAlias		Alis da tabela
@param cProcesso	Tipo do processo     
					1-Transmissão
					2-Monitoramento
					3-Cancelamento
					
@return aProcessa	Arrays com os dados do documentos a ser processado

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function preparaDocumento( cAlias, cProcesso )

	local aProcessa	:= {}
				
	if ( cProcesso == "1" )	// Transmissao
	
		aProcessa := retDocsTrans( cAlias )
	
	elseif ( cProcesso == "2" )
	
		aProcessa := retDocsMon( cAlias )// Monitoramento
	
	elseif ( cProcesso == "3" )
	
		aProcessa := retDocsCan( cAlias) // Cancelamento
	
	endif

return aProcessa 

//-------------------------------------------------------------------
/*/{Protheus.doc} execJobAuto
Executa os jobs dos processos do Auto NF-e.

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
function execJobAuto( cLockFile, cProcesso, aProcessa, cEmpresa, cFilEmp, cIdEnt, cUrl, cModelo, cSerie , lUsaColab, lOpenEnv )

local nHdlJob		:= 0
local aJobSecExec	:= { "transmiteAutoNFE", "monitoraAutoNFe", "cancelaAutoNFe" }
local bBlock		:= {||}
local cFunc			:= ""

default lUsaColab  	:= UsaColaboracao("1")
default lOpenEnv	:= .T.

//-------------------------------------------
// Controle do Lock
//-------------------------------------------
nHdlJob	:= JobSetRunning( cLockFile, .T. )
         
If ( nHdlJob >= 0 )

	cFunc	:= aJobSecExec[val(cProcesso)]

	preparaAmbiente( cEmpresa, cFilEmp, cSerie , lUsaColab, lOpenEnv)

	RefresMoni(cFunc + " - " + cLockFile)
	autoNfeMsg( "Executando a thread " + cLockFile + " do processo de " + getProcName( cProcesso ), .T., cEmpresa, cFilEmp, cSerie , cProcesso )

	bBlock	:= &("{|| " + cFunc + "( cLockFile, cProcesso, aProcessa, cEmpresa, cFilEmp, cIdEnt, cUrl, cModelo, cSerie) }")
	
	eval(bBlock)

	autoNfeMsg( "Finalizando a thread " + cLockFile + " do processo de " + getProcName(cProcesso ), .T., cEmpresa, cFilEmp, cSerie , cProcesso) 
	
	fechaAmbiente( lUsaColab, lOpenEnv )

	//-------------------------------------------
	// Libera o Lock
	//-------------------------------------------
	JobSetRunning( cLockFile, .F., nHdlJob )
	
	delClassIntF()

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcName
Retorna o nome do processo

@param cProcesso		Codigo do processo:	1 - Transmissao
											2 - Monitoramento
											3 - Cancelamento

@return cProcName		Nome do processo

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
function getProcName( cProcesso )

local cProcName := ""

if ( cProcesso == "1" )

	cProcName := "Transmissao"
	
elseif ( cProcesso == "2" )

	cProcName := "Monitoramento"
	
elseif ( cProcesso == "3" )

	cProcName := "Cancelamento"
	
endif

return( cProcName )

//-------------------------------------------------------------------
/*/{Protheus.doc} autoNfeMsg
Funcao que executa conout

@param cMessage		Mensagem que sera apresentada no conout

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
function autoNfeMsg( cMessage, lCompleto, cEmpresa, cFilEmp, cSerie, cProcesso )

default lCompleto	:= .F.

if ( getSrvProfString( "AUTONFE_DEBUG" , "0" ) == "1" )

	if ( lCompleto )
		conout( "[AUTO NFE " + DtoC( date() ) + " - " + time() + " ( Processo: " + allTrim(cProcesso) + " Empresa: " + allTrim(cEmpresa) + " Filial: " + allTrim(cFilEmp) + " Serie: " + allTrim(cSerie) + " ) ] " + allTrim(cMessage)+CRLF )
	else
		conout( "[AUTO NFE " + DtoC( date() ) + " - " + time() + " ] " + allTrim(cMessage)+CRLF )
	endif
	
endif 

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getJobsSecName
Retorna os nomes dos jobs secundarios para execucao

@param cProcesso		Codigo do processo:	1 - Transmissao
											2 - Monitoramento
											3 - Cancelamento
@param cEmpresa			Codigo da Empresa
@param cFilial			Codigo da Filial da Empresa
@param cSerie			Serie do documento

@return aReturn			Array com os nomes do jobs secundarios

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
static function getJobsSecName()

local nX		:= 0
local aReturn	:= {}
local aJobsName	:= { "autonfetrans", "autonfemon", "autonfecanc" }

for nX := 1 To  __nThreads

	aadd( aReturn, lower( aJobsName[val(__cProcesso)] + __cEmpresa + __cFilEmp + __cSerie + StrZero(nX,2) + ".lck" ) )

next

return( aReturn )

//-------------------------------------------------------------------
/*/{Protheus.doc} horaValida
Valdia se esta dentro de uma hora
@param cUltHrProc		ultima hora de processamento
@return lRet			logico, se esta dentro de 1 hora
@author  Felipe S. Martinez
@since   21/05/2021
@version 12
/*/
//-------------------------------------------------------------------
static function horaValida(cUltHrProc)
local lRet		:= .T.
local cHrDif	:= elapTime( cUltHrProc, time() )

//valida se é menos de uma hora a ultima execucao
lRet :=  val(substr(cHrDif,1,2)) == 0 .or. ( val(substr(cHrDif,1,2)) == 1 .and. val(substr(cHrDif,4,2)) == 0 .and. val(substr(cHrDif,7,2)) == 0 ) 
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RefresMoni
Atualiza mensagem no monitores do Protheus e DBAccess
@param		cMsgAdd		string, mensagem adicional a ser informada no monitores
@return		nil
@author		Felipe S. Martinez
@since		21/05/2021
@version	12
/*/
//-------------------------------------------------------------------
static function RefresMoni(cMsgAdd)
local cMsgMon := ""
local lMonitor := ExistFunc("FwMonitorMsg")

Default cMsgAdd := ""

if !empty(__cProcesso )
	cMsgMon := allTrim("AUTONFE - Proc: " + allTrim(getProcName(__cProcesso)) + " Emp: " + allTrim(__cEmpresa) + "/" + allTrim(__cFilEmp) + " Serie: " + allTrim(__cSerie) + " " + cMsgAdd)
else
	cMsgMon := allTrim("AUTONFE - " + cMsgAdd)
endIf

TcInternal(1, cMsgMon )
if lMonitor
	FWMonitorMsg(cMsgMon)
endIf

return nil

/*/{Protheus.doc} vldFimExec
Verifica se pode encerrar a execução do AUTONFE quando multithread
@param		aJobsName	array, semaforo para lock de execução
@param		lMultThread	boolean, se ativo multithread ou nao
@return		nil
@author		Felipe S. Martinez
@since		19/08/2022
@version	12.1.33
/*/
static function vldFimExec(aJobsName, lMultThread)
local cLockFile	:= ""
local nQtdJobs	:= 0
local nControl	:= 1

if lMultThread

	sleep(5000) //aguarda 5 segundos para criacoes de semaforos

	nQtdJobs := len(aJobsName)

	autoNfeMsg( "Verificando execucoes de threads para finalizacao ( total: " + cValToChar(nQtdJobs) + ")", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
	
	while nQtdJobs >= nControl
		cLockFile := aJobsName[nControl]
		if jobIsRunning( cLockFile )
			autoNfeMsg( "Aguardando liberacao do semaforo para finalizacao de processo - " + cLockFile , .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
			sleep(5000) //5 segundos
		else
			autoNfeMsg( "Semaforo ja liberado - " + cLockFile , .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
			nControl++
		endIf
		
	endDo
endIf

return nil
