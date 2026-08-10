#Include "Protheus.ch"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

Static __cEmpresa	:= ""
Static __cFilEmp	:= ""
Static __cProcesso	:= "" 
Static __cSerie		:= ""
Static __nThreads 	:= 0
Static __nLote		:= 0

//------------------------------------------------------------------
/*/{Protheus.doc} validaAutoNfse
Valida o lock do processo principal. Para execução do JOB Auto NFS-e via Schedule.

@param cEmpresa				Empresa
@param cFilEmp				Filial
@param cProcesso	        Processo que sera executado: 1-Transmissão, 2-Monitoramento e 3-Cancelamento.
@param cSerie				Serie do documento
@param nThreads				Numero de threads que serao abertas  
@param nLote				Numero de documentos por lote

@author  Felipe Duarte Luna
@since   11/11/2021
@version 12.1.33

/*/
//------------------------------------------------------------------
function AutoNfseValida( cEmpresa, cFilEmp, cProcesso, cSerie, nThreads, nLote)

local nX			:= 0
local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
local cProcName		:= ""
local cLockFile 	:= ""
local aJobsName 	:= {}
local nHdlJob		:= 0
Local cRDMakeNFSe	:= ""
Local lMontaXML	:= .F.
Local cCodMun		:= Alltrim(SM0->M0_CODMUN)

Private cEntSai	:= "1"
private lUsaColab	:= UsaColaboracao("3",cEntSai)

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

	autoNfseMsg( 'Paramtro "MV_SPEDURL" nao configurado' + " .Thread ["+cValToChar(ThreadID())+"] ", .T.)
	
else

    If !Empty(cEmpresa) .And. !Empty(cFilEmp) .And. !Empty(cSerie)
        //-------------------------------------------
        // Inicializacao das variaveis
        //-------------------------------------------
        __cProcesso	:= cProcesso
        __cEmpresa	:= cEmpresa
        __cFilEmp	:= cFilEmp
        __nLote		:= nLote
        __nThreads	:= nThreads
        __cSerie	:= cSerie
          

        cProcName	:= getProcName( cProcesso )
        cLockFile 	:= ""
        aJobsName 	:= { "autonfsetrans", "autonfsemon", "autonfsecanc" }
        
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
            
                autoNfseMsg( "Iniciando o processo principal de " + __cProcesso + "-" + cProcName + " .Thread ["+cValToChar(ThreadID())+"] executando ... ", .T.) 
                autoNfseMsg( "Total de Threads habilitadas: " + alltrim(str(__nThreads)) + " .Thread ["+cValToChar(ThreadID())+"] ", .T.) 
                
                autoNfseControl( cUrl, lUsaColab, cRDMakeNFSe, lMontaXML )
                
                //-------------------------------------------
                // Libera o Lock
                //-------------------------------------------
                JobSetRunning( cLockFile, .F., nHdlJob )
                
                autoNfseMsg( "Finalizando o processo principal de " + __cProcesso + "-" + cProcName + " .Thread ["+cValToChar(ThreadID())+"] finalizando ... ")
                
				IF cCodMun $ "3505708"//Sleep incluido para barueri ws aguardar as threads filhas concluir o processo.
					sleep( 2000 )
				Endif
				
                Exit
                    
            Else
                
                //-------------------------------------------
                // Thread principal em Lock
                //-------------------------------------------
                autoNfseMsg( "Falha na inicialização do processo de " + __cProcesso + "-" + cProcName + " .Thread ["+cValToChar(ThreadID())+"] ", .T.) 
                
                sleep( 3000 )
                
            Endif
        
        next
    Else
        autoNfseMsg( "JOB nao possui configuracao, Informe a Serie da NFS-e a ser considerada no " + Procname()  + " .Thread ["+cValToChar(ThreadID())+"] ", .F. )
    EndIf    
	
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
/*/{Protheus.doc} autoNfseControl
Funcao que controla a execucao dos JOBs de processos do autoNFSe.

@param cEmpresa	    Empresa
@param cFilEmp	    Filial                          
@param cProcesso	Processo que sera executado: 1-Transmissão, 2-Monitoramento, 3-Cancelamento
@param nLote		Numero de documentos por lote
@param nThreads 	Numero de threads que serao abertas  
@param cSerie		Serie do documento, a ser processado pelo JOB.

@author  Felipe Duarte Luna
@since   11/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
function autoNfseControl( cURL, lUsaColab, cRDMakeNFSe, lMontaXML)

local aProcessa	:= {}
local aDocs		:= {}
local aProcesso	:= {}
Local cQuery		:= ""
local cAlias		:= "" 
local cCodMun		:= Alltrim(SM0->M0_CODMUN)
local cAviso		:= ""
local nx			:= 0
Local ni			:= 0
local lProcessa		:= .F.
local lLoop			:= .T.
local nCount		:= 0
Local cIdEnt	    := ""
Local lDebug	 	:= Iif(getSrvProfString("DEBUG_AUTONFSE","0") == "1",.T.,.F.)//Modo Debug
Local lAtIpcgo 		:= Iif(getSrvProfString("ACTIVATE","OFF") == "ON",.T.,.F.) //Ativa IPCGO
local cUltHrProc	:= ""
local aJobsName		:= getJobsSecName()
local nTotReg		:= 0
Local lMultThread	:= __nThreads > 1
Local aParamTSS		:= {"MV_NFSENAC","MV_IMNAC"} 
local lNfsenac		:= .F.

Private cEntSai	:= "1"
Private cErro		:= ""
Private lOk		:= .F.
Private cModeloNFSe := "1-NFS-e Prefeitura" // "1-NFS-e"
Private lImNac		:= .F.

default lUsaColab	:= UsaColaboracao("3",cEntSai)
default cRDMakeNFSe	:= "" 

cIdEnt	    := GetIdEntAuto()


if __cProcesso <> "2"
	aParamTSS := GetMvTSS( cIdEnt, aParamTSS )
	IF Len(aParamTSS) > 0 
		cModeloNFSe := IIf(!Empty(aParamTSS[1][2]) .AND. aParamTSS[1][2] $ "S" , "2-NFS-e Nacional", "1-NFS-e Prefeitura")		
		lNfsenac	:= IIf(!cModeloNFSe $ "1-NFS-e Prefeitura", .T., .F.)
		lImnac 		:= IIF(!Empty(aParamTSS[2][2]) .AND. aParamTSS[2][2] $ "S",.T.,.F.)
	Endif
endif


if __cProcesso <> "2"
	cRDMakeNFSe	:= getRDMakeNFSe(alltrim(cCodMun),cEntSai, lNfsenac)
	lMontaXML		:= lMontaXML(cCodMun,cEntSai)			
endif

if !Empty(__cProcesso)
	aadd(aProcesso, __cProcesso )
EndIf

delClassIntF()
autoNfseMsg( "JOB iniciado ( Lote: " + allTrim(str(__nLote)) + " Threads: " + allTrim(str(__nThreads)) + " )" + " .Thread ["+cValToChar(ThreadID())+"] executando... ")

For nx := 1 To Len (aProcesso)
	
	cProcesso	:= aProcesso[nx]

	//Monta query do processo
	cQuery		:= getQuery( cProcesso, __cSerie )
		
	//Executa a query do processo
	If lSetupTSS(lUsaColab)			
		cAlias := executeQuery( cQuery , cProcesso )
	Endif

	If ( !empty(cAlias) ) 

		begin sequence
		
		autoNfseMsg( "Iniciando processo dos documentos" + " .Thread ["+cValToChar(ThreadID())+"] ")
		cUltHrProc := time()
		
		while (cAlias)->(!eof())
			
			lProcessa	:= .F.
				
			nCount++

			aDocs := preparaDocumento( cAlias, cProcesso, cRDMakeNFSe, cIdEnt, lMontaXML, @cAviso )
				
			delClassIntF()
			
			if len(aDocs) > 0
	
				autoNfseMsg( "Adicionando documento no lote ( Contagem:"+allTrim(str(nCount))+" )" + " .Thread ["+cValToChar(ThreadID())+"] ")
	
				aAdd( aProcessa, aDocs)
			else
				autoNfseMsg( "Excluindo documento no lote ( Contagem:"+allTrim(str(nCount))+" )" + " .Thread ["+cValToChar(ThreadID())+"] ")
				(cAlias)->( dbSkip() ) ; Loop
			endif

			(cAlias)->(dbSkip())
			IIf (!empty(cAviso), autoNfseMsg( cAviso ), "" )

			if ( nCount == __nLote ) .Or. ( (cAlias)->(eof()) .And. ( !lProcessa .and. len(aProcessa) > 0 ) )
				
				lLoop := .T.
				while lLoop
					//valida se tem alguma thread disponvel
					for ni := 1 to len(aJobsName)
						cLockFile := aJobsName[ni]
						if !lMultThread .or. !jobIsRunning( cLockFile )
							lLoop  := .F.
							Exit
						endIf
					next
					
					if !lLoop
						exit
					elseif !horaValida(cUltHrProc) //valida se passou mais de 1 hora aguardando
						autoNfeMsg( "O Processamento do modelo '" + aModelo[nX] + "' sera finalizado devido a falta de thread disponivel no tempo determinado." + " .Thread ["+cValToChar(ThreadID())+"] ")
						break
					endIf
					sleep(3000) //aguarda 3 seg para alguma liberação de threads
				end
			
				nTotReg 	+= nCount //totalizador de registros
				lProcessa	:= .T.
			
				autoNfseMsg( "Iniciando processamento dos documentos" + " .Thread ["+cValToChar(ThreadID())+"] " )

				If lAtIpcgo .Or. lDebug
					lOk := execAutoNfse( cLockFile, __cEmpresa, __cFilEmp, aProcessa, cProcesso, cIdEnt, cUrl, __cSerie, cCodMun , cErro, lOk , __nLote, .F.)
				Else
					lOk := startJob( "execAutoNfse", getEnvServer(), !lMultThread, cLockFile, __cEmpresa, __cFilEmp, aProcessa, cProcesso, cIdEnt, cUrl, __cSerie, cCodMun ,@cErro, @lOk , __nLote, .T. )
				EndIf

				delClassIntF()

				aProcessa 	:= {} 
				nCount		:= 0

				//atualiza as horas da ultima execução
				cUltHrProc := time()
				
				autoNfseMsg( "Reiniciando montagem de novos lotes" + " .Thread ["+cValToChar(ThreadID())+"] " )
				
			endif
		enddo

		end sequence

		delClassIntF()
		aProcessa 	:= {}
		nCount		:= 0


		(cAlias)->(dbCloseArea())
			
	EndIf

	sleep(1000)

Next
	
sleep(1000)

autoNfseMsg( "JOB Finalizado [Total de Registros: " + allTrim(str(nTotReg)) + "]" + " .Thread ["+cValToChar(ThreadID())+"] ")

aProcessa	:=	aSize( aProcessa , 0 )
aProcessa	:=	nil
aDocs		:=	aSize( aDocs , 0 )
aDocs		:=	nil
aProcesso		:=	aSize( aProcesso , 0 )
aProcesso		:=	nil
aJobsName	:= 	aSize( aJobsName , 0 )
aJobsName	:=	nil

return

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
                                                                                                                   
autoNfseMsg( "Preparando ambiente" + " .Thread ["+cValToChar(ThreadID())+"] ", .F.)

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cFilEmp MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SB1","SB5","SF3","SF4"

autoNfseMsg( "Ambiente preparado" + " .Thread ["+cValToChar(ThreadID())+"] ", .F. )

return 

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
Static Function GetIdEntAuto(cError)
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
			autoNfseMsg( CRLF + " *** Verifique a conexao do TSS com o ERP *** "  + " .Thread ["+cValToChar(ThreadID())+"] " + CRLF+ cError )
		endif
EndIF

Return(cIdEnt)

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

autoNfseMsg( "Query do processo " + cProcesso + "-" + getProcName(cProcesso) + " selecionada: " + allTrim( cQuery )  + " .Thread ["+cValToChar(ThreadID())+"] " )

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
autoNfseMsg( "Executando query  :" + cMsgProc  + " .Thread ["+cValToChar(ThreadID())+"] ")

if !empty(cQuery)
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
	
	autoNfseMsg(cQuery)		
	if ( (cAlias)->(eof()) )
	
		(cAlias)->(dbCloseArea())
		
		cAlias := ""
		autoNfseMsg( "Query nao retornou registros" + " .Thread ["+cValToChar(ThreadID())+"] " )
	endif
else
	
	cAlias := ""

endif

return cAlias

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
/*/{Protheus.doc} execAutoNfse
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
function execAutoNfse( cLockFile, cEmpresa, cFilEmp, aProcessa, cProcesso, cIdEnt, cUrl, cSerie, cCodMun , cErro, lOk , nLote, lResetEnv )

Local nHdlJob		:= 0
local cFtpT			:= "3"
local cErrorMsg		:= ""
local cNotaini		:= iIf(cProcesso $ "1|3",iniFim(aProcessa,cProcesso)[1],)
local cNotaFin		:= iIf(cProcesso $ "1|3",iniFim(aProcessa,cProcesso)[2],)

Private cEntSai	:= "1"

default cErro := ""
default lOk   := .F.
default lResetEnv	:= .T.

//-------------------------------------------
// Controle do Lock
//-------------------------------------------
nHdlJob	:= JobSetRunning( cLockFile, .T. )

If ( nHdlJob >= 0 )

	preparaAmbiente( cEmpresa, cFilEmp )

	autoNfseMsg( "Executando a thread " + cLockFile + " do processo de "  + getProcName( cProcesso ) + " .Thread ["+cValToChar(ThreadID())+"] executando... ")

	if ( cProcesso == "1" )
		//Transmissão da NFSe
		lOk := envRemessaNFSe(cIdEnt,cUrl,aProcessa,.F.,"1",/*cNotasOk*/,/*lCanc*/,/*cCodCanc*/,cCodMun,/*lRecibo*/,@cErro)

		if lOk .and. cCodMun $ "3505708"	

			Fisa022XML(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,SToD(aProcessa[1][5]),,aProcessa[1][6],aProcessa,1,aProcessa[1][1],aProcessa[1][1],,,aProcessa[1][5], cFtpT, cUrl, cEntSai)	
			cErrorMsg := GetWscError()	
		
		endif

	elseif ( cProcesso == "2" )
		//Monitoramento da NFSe
		lOk := aNMExecProc( cIdEnt, cSerie, aProcessa ,/*dDataIni*/ ,/*dDataFim*/ , UsaColaboracao("3"), nLote)
	elseif ( cProcesso == "3" )
		//Cancelamento NFSe
		lOk := envRemessaNFSe(cIdEnt,cUrl,aProcessa,.F.,"1",/*cNotasOk*/,.T.,/*cCodCanc*/,cCodMun,/*lRecibo*/,@cErro)

			if lOk .and. cCodMun $ "3505708"	
				Fisa022XML(cIdEnt,cCodMun,cSerie,cNotaini,cNotaFin,SToD(aProcessa[1][5]),,aProcessa[1][6],aProcessa,1,aProcessa[1][1],aProcessa[1][1],,,aProcessa[1][5], cFtpT, cUrl, cEntSai)	
				cErrorMsg := GetWscError()	
			endif

	endif

	autoNfseMsg( "Finalizando a thread " + cLockFile + " do processo de " + getProcName(cProcesso ) + " .Thread ["+cValToChar(ThreadID())+"] ... " ) 

	If lResetEnv // Por está processando na Thread Principal o ambiente não será fechado, para evitar de deixar a Thread burra e ocasionar erro log.
		RESET ENVIRONMENT
	EndIf	

	//-------------------------------------------
	// Libera o Lock
	//-------------------------------------------
	JobSetRunning( cLockFile, .F., nHdlJob )
	
	delClassIntF()

EndIf	


return lOk


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
			conout("Configure o Parametro MV_SPEDURL, antes de utilizar esta opcao! NFS-e"  + " .Thread ["+cValToChar(ThreadID())+"] ")
		endif
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem comunicação com o TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. !(isConnTSS())
		lSetupTSS	:= .F.
		if lAlert
			conout(" *** Verifique a conexao do TSS com o ERP ***  NFS-e"  + " .Thread ["+cValToChar(ThreadID())+"] ")
		endif
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera alerta se estiver sem entidade gerada no TSS            		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSetupTSS	.And. Empty(GetIdEntAuto())
		lSetupTSS	:= .F.
		if lAlert
			MsgAlert("Sem entidade valida refazer o wizard de configuracao NFS-e"  + " .Thread ["+cValToChar(ThreadID())+"] ")
		endif
	EndIf
EndIf

Return lSetupTSS

//-------------------------------------------------------------------
/*/{Protheus.doc} UsaColaboracao
@param	cModelo     Verifica se parametro MV_TCNEW esta configurado para 0-Todos , 
1-NFE, 2-CTE, 3-NFS, 4-MDe, 5-MDfe ou 6-Recebimento.
@param 		cTipo		tipo da nota (entrada = "0" ; saida= "1")

@return lUsa Retorna .T. se Utiliza TOTVS Colaboração 2.0.

@author	Felipe Duarte Luna
@since		30/01/2018
@version	1.0
/*/
//-------------------------------------------------------------------
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
/*/{Protheus.doc} autoNfseMsg
Funcao que executa conout

@param cMessage		Mensagem que sera apresentada no conout

@author  Henrique Brugugnoli
@since   28/11/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function autoNfseMsg( cMessage, lCompleto )

default lCompleto	:= .T.

if ( getSrvProfString( "AUTONFSE_DEBUG" , "0" ) == "1" )

	if ( lCompleto )
		conout( "[AUTO NFSE " + DtoC( date() ) + " - " + time() + " ( Empresa: " + allTrim(__cEmpresa) + " Filial: " + allTrim(__cFilEmp) + " Processo: " + allTrim(__cProcesso) + " Serie: " + allTrim(__cSerie) + " ) ] " + allTrim(cMessage) + CRLF+ CRLF)
	else
		conout( "[AUTO NFSE " + DtoC( date() ) + " - " + time() + " ] " + allTrim(cMessage) + CRLF+ CRLF)
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
local aJobsName	:= { "autonfsetrans", "autonfsemon", "autonfsecanc" }

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
/*/{Protheus.doc} iniFim
Retorna a nota inicial e final para utilizar na geração do metodo GERAARQIMP quando a transmissao é pelo autonfsetrans
@param 		aNotas		Array com Notas
@author  Renan Botelho
@since   04/01/2023
@version 12
/*/
//-------------------------------------------------------------------
static function iniFim(aNotas, processo)

	local aRet	:= {}
	local nx	:= 0

	For nx := 1 To Len (aNotas)
		if nx == 1
			if processo $ "1|3"
				aAdd(aRet, aNotas[nx][2] )
			endif
		endif
		if nx == Len (aNotas)
			if processo $ "1|3"
				aAdd(aRet, aNotas[nx][2] )
			endif
		endif
	next
	
return aRet
