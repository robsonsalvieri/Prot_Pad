#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"  

static __aGlobal	:= {}   
static __cEmpresa	:= ""
static __cFilEmp	:= ""
static __cProcesso	:= ""

static __cSerie	 	:= ""

//---------------------------------------------------------------------
/*/{Protheus.doc} autonfseJobControl
Funcao que controla a execucao dos JOBs de processos do autoNFSe.

@param cEmpresa	Empresa
@param cFilEmp	Filial                          
@param cProcesso	Processo que sera executado 
					1-Transmissão
					2-Monitoramento
					3-Cancelamento
@param nLote		Numero de documentos por lote
@param nThreads	Numero de threads que serao abertas  

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
function autoNfseJobControl( cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk )

local aProcessa	:= {}
local aTemp		:= {}
local cQuery		:= ""
local cAlias		:= "" 
local cRDMakeNFSe	:= ""
local cCodMun		:= ""
local cURL			:= ""
local cGlobal1	:= ""
local cAviso		:= ""
local nx			:= 0
local nCount		:= 0

local lProcessa	:= .F.
local lMontaXML	:= .F.
local aProcesso	:= {}
Private cEntSai	:= "1"
Private cIdEnt	:= ""
default cErro		:= "" 
default lOk		:= .F. 
default cGlobal	:= "anfse_p_" + "001" + "_" + cProcesso + "_" + cEmpresa + "_" + cFilEmp + "_" + allTrim(cSerie)

VarSetUID("AUTONFSE",.T.)

if !Empty(cEmpresa) .And. !Empty(cFilEmp) .And. !Empty(cSerie)

__cEmpresa		:= Alltrim(cEmpresa)
__cFilEmp		:= Alltrim(cFilEmp)
__cProcesso	:= cProcesso
__cSerie		:= cSerie

varSetXD("AUTONFSE", cGlobal, .T.)

autoNfseMsg( "JOB iniciado ( Lote: " + allTrim(str(nLote)) + " Threads: " + allTrim(str(nThreads)) + " )" )

preparaAmbiente( __cEmpresa	, __cFilEmp )


if cProcesso == "4"
	aadd(aProcesso,"1")
	aadd(aProcesso,"2")
	aadd(aProcesso,"3")
Else
	aadd(aProcesso, cProcesso )
EndIf

While !killApp()

	For nx := 1 To Len (aProcesso)
		
		cProcesso	:= aProcesso[nx]

		cCodMun	:= SM0->M0_CODMUN
		
		cQuery		:= getQuery( cProcesso, cSerie )
		
		cURL		:= Padr( GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250 )
		
		cIdEnt		:= GetIdEntAuto()
		
		lUsaColab	:= UsaColaboracao("3",cEntSai)
		
		delClassIntF()


		if cProcesso <> "2"
			cRDMakeNFSe	:= getRDMakeNFSe(alltrim(cCodMun),cEntSai)
			lMontaXML		:= lMontaXML(cCodMun,cEntSai)
			
		endif
		cAlias := executeQuery( cQuery , cProcesso )
	
		if ( !empty(cAlias) )
			
			autoNfseMsg( "Iniciando processo dos documentos" )
			
			while (cAlias)->(!eof())
				
				lProcessa	:= .F.
						
				nCount++
				cAviso := ''
				aTemp := preparaDocumento( cAlias, cProcesso, cRDMakeNFSe, cIdEnt, lMontaXML, @cAviso )
					
				delClassIntF()
					
				if len(aTemp) > 0
		
					autoNfseMsg( "Adicionando documento no lote ( Contagem:"+allTrim(str(nCount))+" )" )
		
					aAdd( aProcessa, aTemp)
				else
					autoNfseMsg( "Excluindo documento no lote ( Contagem:"+allTrim(str(nCount))+" )" )
					(cAlias)->( dbSkip() ); Loop
				endif
		
				if (!empty(cAviso), autoNfseMsg( cAviso ), "" )
					if nCount == nLote
					
						lProcessa	:= .T.
					
						autoNfseMsg( "Inicio do processamento do documento" )
					
						cGlobal1 := existeThread( cEmpresa, cFilEmp, cSerie, cProcesso, nThreads )
					
						processaDocumento( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal1, cIdEnt, cUrl, cSerie, cCodMun , @cErro, @lOk , nLote )
						
						delClassIntF()
						
						aProcessa 	:= {}
						nCount		:= 0
						
						autoNfseMsg( "Reiniciando montagem de novos lotes" )
						
					endif
						
					(cAlias)->(dbSkip())
					
				end
				
				if ( !lProcessa .and. !empty(aProcessa) )
				
					lProcessa	:= .T.
					
					autoNfseMsg( "Inicio do processamento do documento" )
				
					cGlobal1 := existeThread( cEmpresa, cFilEmp, cSerie, cProcesso, nThreads )
				
					processaDocumento( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal1, cIdEnt, cUrl, cSerie, cCodMun, @cErro, @lOk , nLote )
		
					delClassIntF()
						
					aProcessa 	:= {}
					nCount		:= 0
							
				endif
				
				(cAlias)->(dbCloseArea())
				
			endif

			sleep( 3 * 1000) //sleep )

		Next
		
		sleep( 5 * 1000) //5 segundos sleep )

	end
	varSetXD("AUTONFSE", cGlobal, .F.)	

	RESET ENVIRONMENT

	autoNfseMsg( "JOB Finalizado", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
EndIf

return 


//------------------------------------------------------------------- 
/*/{Protheus.doc} IPCnfseJobControl
Funcao que controla a execucao dos JOBs de processos do autoNFSe.

@param cEmpresa	Empresa
@param cFilEmp	Filial                          
@param cProcesso	Processo que sera executado 
					1-Transmissão
					2-Monitoramento
					3-Cancelamento
@param nLote		Numero de documentos por lote
@param nThreads	Numero de threads que serao abertas  

@author  Cleiton Genuino
@since   18/11/2016
@version 12
/*/
//-------------------------------------------------------------------
function ipcNfseJobControl( cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk )

local aProcessa	:= {}
local aTemp		:= {}
local cQuery		:= ""
local cAlias		:= "" 
local cRDMakeNFSe	:= ""
local cCodMun		:= ""
local cURL			:= ""
local cGlobal1	:= ""
local cAviso		:= ""
local nx			:= 0
local nCount		:= 0

local lProcessa	:= .F.
local lMontaXML	:= .F.
local aProcesso	:= {}
Private cEntSai	:= "1"
Private cIdEnt	:= ""
default cErro		:= ""
default lOk		:= .F.
default cGlobal	:= "anfse_p_" + "001" + "_" + cProcesso + "_" + cEmpresa + "_" + cFilEmp + "_" + allTrim(cSerie)

VarSetUID("AUTONFSE",.T.)
if !Empty(cEmpresa) .And. !Empty(cFilEmp) .And. !Empty(cSerie)

__cEmpresa		:= cEmpresa
__cFilEmp		:= cFilEmp
__cProcesso	:= cProcesso
__cSerie		:= cSerie

varSetXD("AUTONFSE", cGlobal, .T.)

autoNfseMsg( "JOB iniciado ( Lote: " + allTrim(str(nLote)) + " Threads: " + allTrim(str(nThreads)) + " )" )

preparaAmbiente( cEmpresa, cFilEmp )


if cProcesso == "4"
	aadd(aProcesso,"1")
	aadd(aProcesso,"2")
	aadd(aProcesso,"3")
Else
	aadd(aProcesso, cProcesso )
EndIf


	For nx := 1 To Len (aProcesso)
		
		cProcesso	:= aProcesso[nx]

		cCodMun	:= SM0->M0_CODMUN
		
		cQuery		:= getQuery( cProcesso, cSerie )
		
		cURL		:= Padr( GetNewPar("MV_SPEDURL","http://localhost:8080/nfse"),250 )
		
		cIdEnt		:= GetIdEntAuto()
		
		lUsaColab	:= UsaColaboracao("3",cEntSai)
		
		delClassIntF()


		if cProcesso <> "2"
			cRDMakeNFSe	:= getRDMakeNFSe(alltrim(cCodMun),cEntSai)
			lMontaXML		:= lMontaXML(cCodMun,cEntSai)
			
		endif
		
		If lSetupTSS(lUsaColab)
			cAlias := executeQuery( cQuery , cProcesso )
		Endif
		
	
		if ( !empty(cAlias) ) 
			
			autoNfseMsg( "Iniciando processo dos documentos" )
			
			while (cAlias)->(!eof())
				
				lProcessa	:= .F.
						
				nCount++
				cAviso := ''	
				aTemp := preparaDocumento( cAlias, cProcesso, cRDMakeNFSe, cIdEnt, lMontaXML, @cAviso )
					
				delClassIntF()
					
				if len(aTemp) > 0
		
					autoNfseMsg( "Adicionando documento no lote ( Contagem:"+allTrim(str(nCount))+" )" )
		
					aAdd( aProcessa, aTemp)
				else
					autoNfseMsg( "Excluindo documento no lote ( Contagem:"+allTrim(str(nCount))+" )" )
					(cAlias)->( dbSkip() ) ; Loop
				endif
		
				if (!empty(cAviso), autoNfseMsg( cAviso ), "" )
					if nCount == nLote
					
						lProcessa	:= .T.
					
						autoNfseMsg( "Inicio do processamento do documento" )
					
						//cGlobal1 := existeThread( cEmpresa, cFilEmp, cSerie, cProcesso, nThreads )
					
						processaDocumento( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun , @cErro, @lOk , nLote )
						
						delClassIntF()
						
						aProcessa 	:= {}
						nCount		:= 0
						
						autoNfseMsg( "Reiniciando montagem de novos lotes" )
						
					endif
						
					(cAlias)->(dbSkip())
					
				end
				
				if ( !lProcessa .and. !empty(aProcessa) )
				
					lProcessa	:= .T.
					
					autoNfseMsg( "Inicio do processamento do documento" )
				
					//cGlobal1 := existeThread( cEmpresa, cFilEmp, cSerie, cProcesso, nThreads )
				
					processaDocumento( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun, @cErro, @lOk , nLote )
		
					delClassIntF()
						
					aProcessa 	:= {}
					nCount		:= 0
							
				endif
				
				(cAlias)->(dbCloseArea())
				
		endif

			sleep(1000)

		Next
		
		sleep(1000)

	varSetXD("AUTONFSE", cGlobal, .F.)	

	RESET ENVIRONMENT

	autoNfseMsg( "JOB Finalizado", .T., __cEmpresa, __cFilEmp, __cSerie , __cProcesso)
EndIf


return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getQuery
Funcao retorna a query.

@param cProcesso	Tipo do processo     
					1-Transmissão
					2-Monitoramento
					3-Cancelamento

@return cQuery	Query que sera executada

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function getQuery( cProcesso, cSerie )
      
local cQuery	:= ""

if ( cProcesso == "1" )
	cQuery := aNJTRetQuery( cSerie,  )
elseif ( cProcesso == "2" )
	cQuery := aNJMRetQuery( cSerie,  )
elseif ( cProcesso == "3" )
	cQuery := aNJCRetQuery( cSerie, )
endif

autoNfseMsg( "Query do processo " + cProcesso + " selecionada: " + allTrim( cQuery ) )

return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} executeQuery
Funcao executa a query.

@param cQuery	Query que sera executada

@return cAlias	Alias da query executada

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function executeQuery( cQuery , cProcesso )

local cAlias	:= getNextAlias()
Default cProcesso := "4"

if cProcesso     $ '1'
	cMsgProc := " 1-Transmissao"
elseif cProcesso $ '2'
	cMsgProc := " 2-Monitoramento"
elseif cProcesso $ '3'
	cMsgProc := " 3-Cancelamento"
Endif
autoNfseMsg( "Executando query  :" + cMsgProc )

if !empty(cQuery)
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	
	autoNfseMsg(cQuery)		
	if ( (cAlias)->(eof()) )
	
		(cAlias)->(dbCloseArea())
		
		cAlias := ""
		autoNfseMsg( "Query nao retornou registros" )
	endif
else
	
	cAlias := ""

endif

return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} preparaAmbiente
Funcao que prepara o ambiente.

@param cEmpresa	Empresa
@param cFilEmp		Filial

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function preparaAmbiente( cEmpresa, cFilEmp )
                                                                                                                   
autoNfseMsg( "Preparando ambiente", .F. )

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cFilEmp MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SB1","SB5","SF3","SF4"

autoNfseMsg( "Ambiente preparado", .F. )

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
static function preparaDocumento( cAlias, cProcesso, cRDMakeNFSe, cIdEnt,lMontaXML, cAviso )
local lProcessa		:= .T.
local aValNFe		:= {}
local aProcessa		:= {}
local lAutVlNfse	:= ExistBlock( "AUTVLNFSE" )

If lAutVlNfse                                       
	If Select( cAlias ) > 0 .And. 	( cAlias )->( FieldPos( 'F3_FILIAL'  ) ) > 0 .And. ( cAlias )->( FieldPos( 'F3_ENTRADA' ) ) > 0 .And.;
									( cAlias )->( FieldPos( 'F3_NFISCAL' ) ) > 0 .And. ( cAlias )->( FieldPos( 'F3_SERIE' 	) ) > 0 .And.;
									( cAlias )->( FieldPos( 'F3_CLIEFOR' ) ) > 0 .And. ( cAlias )->( FieldPos( 'F3_LOJA' 	) ) > 0 .And.;
									( cAlias )->( FieldPos( 'F3_ESPECIE' ) ) > 0 .And. ( cAlias )->( FieldPos( 'F3_FORMUL' 	) ) > 0

		Aadd( aValNFe,IIf( ( cAlias )->F3_CFO < "5","E","S" ) )
		Aadd( aValNFe,( cAlias )->F3_FILIAL		)
		Aadd( aValNFe,( cAlias )->F3_ENTRADA	)
		Aadd( aValNFe,( cAlias )->F3_NFISCAL	) 
		Aadd( aValNFe,( cAlias )->F3_SERIE		)
		Aadd( aValNFe,( cAlias )->F3_CLIEFOR	)
		Aadd( aValNFe,( cAlias )->F3_LOJA		)
		Aadd( aValNFe,( cAlias )->F3_ESPECIE	)
		Aadd( aValNFe,( cAlias )->F3_FORMUL		)

		lProcessa := ExecBlock( "AUTVLNFSE", .F.,.F., aValNFe )
	EndIf
EndIf

If !( lProcessa ) 
	cAviso := '[AUTVLNFSE]->[ '+ aValNFe[ 1 ] +' ][ '+ aValNFe[ 2 ] +' ][ '+ Dtoc( Stod( aValNFe[ 3 ] ) ) +' ][ '+ aValNFe[ 4 ] +' ][ '+ aValNFe[ 5 ] +' ]-Rejeitado pelo Usuário via Ponto de Entrada'
	autoNfseMsg( cAviso )
Else
	if ( cProcesso == "1" )										 
		aProcessa := montaRemessaNFSe( cAlias ,cRdMakeNFSe ,/*lCanc*/,/*cCodCanc*/,/*cMotCancela*/,cIdent ,/*lMontaXML*/ ,/*cCodTit*/ ,@cAviso ,/*aTitIssRet*/ )
	elseif ( cProcesso == "2" )
		aProcessa := aNMRetDoc( cAlias )
	elseif ( cProcesso == "3" )
		aProcessa := montaRemessaNFSe( cAlias ,cRDMakeNFSe , .T. ,/*cCodCanc*/,/*cMotCancela*/, cIdEnt, lMontaXML ,/*cCodTit*/ ,@cAviso ,/*aTitIssRet*/ )
	endif
EndIf

return aProcessa

//-------------------------------------------------------------------
/*/{Protheus.doc} processaDocumento
Funcao que processa os documentos a serem enviados.

@param aProcessa	Arrays com os dados do documentos a ser processado  
@param cProcesso	Tipo do processo     
					1-Transmissão
					2-Monitoramento
					3-Cancelamento

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function processaDocumento( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun, cErro, lOk , nLote )
Local lDebug	 := iif (getSrvProfString("DEBUG_AUTONFSE","0") == "1",.T.,.F.)//Modo Debug
local lAtIpcgo := iif (getSrvProfString("ACTIVATE","OFF") == "ON",.T.,.F.) //Ativa IPCGO
default cErro := ""
default lOk 	:= .F.

autoNfseMsg( "Iniciando processamento dos documentos" )

If lAtIpcgo .Or. lDebug
lOk := autoNfseExec( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun , cErro, lOk , nLote)
Else
lOk := startJob( "autoNfseExec", getEnvServer(), .F., cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun ,@cErro, @lOk , nLote )
EndIf

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} autoNfseExec
Funcao que executa o processamento.

@param aProcessa	Arrays com os dados do documentos a ser processado
@param cProcesso	Tipo do processo
					1-Transmissão
					2-Monitoramento
					3-Cancelamento

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
function autoNfseExec( cEmpresa, cFilEmp, aProcessa, cProcesso, cGlobal, cIdEnt, cUrl, cSerie, cCodMun , cErro, lOk , nLote)

default cErro := ""
default lOk   := .F.

preparaAmbiente( cEmpresa, cFilEmp )


if ( cProcesso == "1" )
	//Transmissão da NFSe
	lOk := envRemessaNFSe(cIdEnt,cUrl,aProcessa,.F.,"1",/*cNotasOk*/,/*lCanc*/,/*cCodCanc*/,cCodMun,/*lRecibo*/,@cErro)
elseif ( cProcesso == "2" )
	//Monitoramento da NFSe
	lOk := aNMExecProc( cIdEnt, cSerie, aProcessa ,/*dDataIni*/ ,/*dDataFim*/ , UsaColaboracao("3"), nLote)
elseif ( cProcesso == "3" )
	//Cancelamento NFSe
	lOk := envRemessaNFSe(cIdEnt,cUrl,aProcessa,.F.,"1",/*cNotasOk*/,.T.,/*cCodCanc*/,cCodMun,/*lRecibo*/,@cErro)

endif

//RESET ENVIRONMENT

putGlbValue( cGlobal, "0" )

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} existeThread
Funcao que verifica se existe thread ociosa para executar.

@param cEmpresa		Empresa
@param cFilEmp		Filial 
@param cProcesso	Tipo do processo     
					1-Transmissão
					2-Monitoramento
					3-Cancelamento

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function existeThread( cEmpresa, cFilEmp, cSerie ,cProcesso, nThreads )

//local cGlobal	:= "AN_"+allTrim(cEmpresa)+"_"+allTrim(cFilEmp)+"_"+allTrim(cProcesso)+"_"
local cGlobal	:= "anfse_p_" + "001" + "_" + cProcesso + "_" + cEmpresa + "_" + cFilEmp + "_" + allTrim(cSerie)
local cValue	:= ""

local lProcessa	:= .F.

local nX 

autoNfseMsg( "Verificando a existencia de thread para processar" ) 

while .T. .and. len(__aGlobal) == nThreads .and. !lProcessa

	for nX := 1 to len(__aGlobal)
		
		cValue := getGlbValue( __aGlobal[nX] )
		
		if ( !empty(cValue) .And. cValue == "0" )
			lProcessa	:= .T.
			exit
		endif
		
	next nX 
	
	if ( lProcessa )
		exit
	else
		sleep(2000)
	endif
	
end 

if ( len(__aGlobal) < nThreads )

	cGlobal := cGlobal + allTrim(str(len(__aGlobal)+1))
	
	aAdd(__aGlobal,cGlobal) 
	
else
	cGlobal := cGlobal + allTrim(str(nX))
endif

putGlbValue( cGlobal, "1" )

autoNfseMsg( "Thread ociosa pronta para ser usada" )

return cGlobal

//-------------------------------------------------------------------
/*/{Protheus.doc} autoNfseMsg
Funcao que executa conout

@param cMessage		Mensagem que sera apresentada no conout

@author  Henrique Brugugnoli
@since   28/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
function autoNfseMsg( cMessage, lCompleto )

default lCompleto	:= .T.

if ( getSrvProfString( "AUTONFSE_DEBUG" , "0" ) == "1" )

	if ( lCompleto )
		conout( "[AUTO NFSE " + DtoC( date() ) + " - " + time() + " ( Empresa: " + allTrim(__cEmpresa) + " Filial: " + allTrim(__cFilEmp) + " Processo: " + allTrim(__cProcesso) + " Serie: " + allTrim(__cSerie) + " ) ] " + allTrim(cMessage) + CRLF+ CRLF)
	else
		conout( "[AUTO NFSE " + DtoC( date() ) + " - " + time() + " ] " + allTrim(cMessage) + CRLF+ CRLF)
	endif
	
endif

return


//------------------------------------------------------------------
static function UsaColaboracao(cModelo,cTipo)
Local lUsa := .F.
Default cModelo	:= "3"
Default cTipo		:= "1"

If cTipo $ '1'
	If FindFunction("ColUsaColab")
		lUsa := ColUsaColab(cModelo)
	endif
endif
return (lUsa)

//-------------------------------------------------------------------
/*/{Protheus.doc} lSetupTSS
Valida o setup necessário para utilização da integração do ERP com o TSS

@author		Cleiton Genuino da Silva
@since		15.12.2016
/*/
//-------------------------------------------------------------------
Static Function lSetupTSS(lUsaColab)
Local lSetupTSS	:= .T.
Local lAlert		:= .T.
Default lUsaColab	:= .F.

If !lUsaColab
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Wizard config - Chama se URL vazia            					 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Padr(GetNewPar("MV_SPEDURL",""),250))
		lSetupTSS	:= .F.
		if lAlert
			conout("Configure o Parâmetro MV_SPEDURL, antes de utilizar esta opção! NFS-e")
		endif
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem comunicação com o TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. !(isConnTSS())
		lSetupTSS	:= .F.
		if lAlert
			conout(" *** Verifique a conexão do TSS com o ERP ***  NFS-e")
		endif
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem entidade gerada no TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. Empty(GetIdEntAuto())
		lSetupTSS	:= .F.
		if lAlert
			MsgAlert("Sem entidade valida refazer o wizard de configuração NFS-e")
		endif
	EndIf
EndIf

Return lSetupTSS
//-----------------------------------------------------------------------

//---------------------------------------------------------------
/*/{Protheus.doc} GetIdEntAuto
Obtem o codigo da entidade apos enviar o post para o Totvs Service

@author Renato Nagib
@since 21/11/2011
@version 1.0 

@param		nenhum
			  
@return cIdEnt		Entidade
/*/
//-----------------------------------------------------------------------
Function GetIdEntAuto(cError)
Local cIdEnt 	  := ""
Local lUsaColab := UsaColaboracao("3")
Default cError  := ""

IF lUsaColab
	if !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 3.0",{"Ok"},3)
	else
		cIdEnt := "000000"
	endif
Else
		if isConnTSS(@cError) // Verifica a conexão do TSS antes de iniciar o processo de validação da entidade
			cIdEnt := getCfgEntidade(@cError)
		else
			autoNfseMsg( CRLF + " *** Verifique a conexao do TSS com o ERP *** " + CRLF+ cError )
		endif
EndIF

Return(cIdEnt)