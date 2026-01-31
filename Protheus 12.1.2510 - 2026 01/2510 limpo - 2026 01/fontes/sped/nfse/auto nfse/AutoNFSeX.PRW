#INCLUDE "PROTHEUS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} AutoNFSeX
JOB Auto NFSe.

@author  Henrique Brugugnoli
@since   27/11/2012
@version 11.8

@param Se lOnDemand será necessário configurar a sessão de smartjob 
Projeto ainda não foi liberado oficialmente pela Totvs Tec não implementar.
;===================================================
;==================  SMARTJOB  =====================
;===================================================
[SMARTJOB]
minjobs=1
maxjobs=50
;===================================================
;==================  IPCGO  =========================
;===================================================
[IPC_GO]
main=prepareIPCWAIT
environment=P127
instances=16,20
ExpirationTime=300
ExpirationDelta=1

/*/
//------------------------------------------------------------------- 
main function AutoNFSeX(lAutomato)                                                  

local cTable		:= "NFSECFG"   
local cGlobal 	:= ""
Local cErro		:= ""
local cGlobalPrf	:= "anfse_p_"
local cNewFunc	:= ""
Local lSmartjob  	:= iif ("maxjobs" $ getSrvProfString("SMARTJOB", "maxjobs"),.T.,.F.)
Local lOnDemand	:= iif ("MAXTHREAD" $ getSrvProfString("AUTO_NFSE", "MAXTHREAD"),.T.,.F.)
Local lOnIpcgo	:= iif ("instances" $ getSrvProfString("IPC_GO", "instances"),.T.,.F.)
Local lAtIpcgo	:= iif (getSrvProfString("ACTIVATE","OFF") == "ON",.T.,.F.) //Ativa IPCGO
Local lAtSmartjob	:= iif (getSrvProfString("ACTIVATE","0") == "1",.T.,.F.) //Ativa SmartJob    
Local lisRunning	:= .F.
Local lOk  		:= .F.
Local lDebug		:= iif (getSrvProfString("DEBUG_AUTONFSE","0") == "1",.T.,.F.)
Local cDebug_Emp	:= getSrvProfString("DEBUG_EMPRESA"," ") 
Local cDebug_Fili	:= getSrvProfString("DEBUG_FILIAL"," ")
Local cDebug_Seri	:= getSrvProfString("DEBUG_SERIE"," ")
local isLocked := .F.
Local cDescricao	:= ""
Default lAutomato	:= .F. 

SET DELETED ON

If FindFunction("ERPIPCGO") .And. lOnIpcgo 
	If lAtIpcgo
		Conout ("IPCGO ACTIVATE  Esta -->ON  " + " start: " + getEnvServer() + " - execute: " + time())	
	Else
		Conout ("IPCGO ACTIVATE  Esta -->OFF " + " start: " + getEnvServer() + " - execute: " + time())	
	EndIf 
EndIf

If lDebug .And. !Empty(cDebug_Emp) .And. !Empty(cDebug_Fili) .And. !Empty(cDebug_Seri)
Conout ("************************************************************")
Conout ("*                      MODO DEBUG                          *")
Conout ("*Emp.-"+cDebug_Emp+"-Fil.-"+cDebug_Fili+"-Ser."+cDebug_Seri)
Conout ("************************************************************")
Endif


autoNfseMsg( "Iniciando JOB Auto NFSe --->", .F. )
autoNfseMsg( "Abrindo configuracoes...:", .F. )     

if ( openNfseCfg() )
	autoNfseMsg( "Configuracoes abertas...: NFSECFG ", .F. )
	
	if ( (cTable)->(eof()) )
		autoNfseMsg( "JOB nao possui configuracao, por favor efetuar a configuracao.:", .F. )
		return
	endif
	
else
	autoNfseMsg( "Falha ao carregar as configuracoes o processo sera interrompido.:", .F. )
	return
endif                    

cId := ""

VarSetUID("AUTONFSE",.T.)

while !killApp()
	
	(cTable)->(dbGoTop())
	
	
	while ( (cTable)->(!eof()) )
		If !lAutomato		
			lisRunning := isRunning( (cTable)->ID ) 
		Else
			lisRunning := .T.
		EndIf
		if ( (cTable)->ATIVO == "1" .and. (lisRunning .or. !empty(cId) ))
			cId 		:= (cTable)->ID
			cProcesso	:= (cTable)->PROCESSO
			cEmpresa	:= iif (lDebug,cDebug_Emp,allTrim((cTable)->EMPRESA))
			cFilEmp		:= iif (lDebug,cDebug_Fili,alltrim((cTable)->FILIAL))
			cSerie		:= iif (lDebug,cDebug_Seri,(cTable)->SERIE)
			nLote		:= (cTable)->LOTE
			nThreads	:= (cTable)->THREAD
			cDescricao	:= allTrim( (cTable)->DESCRICAO )
			
			cGlobal := cGlobalPrf + cId + "_" + cProcesso + "_" + cEmpresa + "_" + cFilEmp + "_" + allTrim(cSerie)
			
			If lAutomato .Or. lDebug		
				putGlbValue( cGlobal, "0" )
			EndIf
			if (  (!varGetXD("AUTONFSE", cGlobal, @isLocked) .or. !isLocked) .And. !Empty(cEmpresa) .And. !Empty(cFilEmp) ) 
				
				autoNfseMsg( "JOB iniciando processo da configuracao: " + cDescricao, .F. )
			
				If FindFunction("ERPIPCGO") .And. lAtIpcgo .And. lOnIpcgo .And. !lDebug
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envio com controle de processamento por theads parametrizar levando em 			³ 
				//³ consideração o numero de licenças disponiveis 										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ									  			  	
				  	ERPIPCGO("ipcNfseJobControl", .T.,"IPC_GO",cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro,  .T. )				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Função smartJob em processo de validação na Totvs |TEC implementação piloto		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				Elseif FindFunction("smartJob") .And. lSmartjob .And. lAtSmartjob
					conout("*-* SmartJob Thread: " + cValtochar(threadid()) + " start: " + getEnvServer() + " - execute: " + time())
					//Chamado a função da TEC via macro execução pois estava ocorrendo erro em alguns clientes informando que a função não existe.
					cNewFunc := "smartjob"					
					&cNewFunc.( "autoNfseJobControl", getEnvServer(), .F., cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk  )
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Controle de theads por: startJob 														³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
					If !lAutomato .And. !lDebug
						sleep(1000) //sleep )
						startJob( "autoNfseJobControl", getEnvServer(), .F., cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk, lAutomato  )
					Else
						if lAtIpcgo
							ipcNfseJobControl(cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk, iif (lDebug,.F.,.T.)/*lAutomato*/)
						Else
							autoNfseJobControl(cEmpresa, cFilEmp, cProcesso, nLote, nThreads, cSerie, cGlobal, cErro , lOk, iif (lDebug,.F.,.T.)/*lAutomato*/)
						EndIf
					EndIf
				EndIf		
			endif
			
		endif
		
		If lAutomato 	
			Exit
		EndIf
		(cTable)->(dbSkip())
		
	end
			
	if lAutomato 
		Exit
	Else
		autoNfseMsg( "JOB em espera para o proximo processamento", .F. )	
		sleep(5000) //sleep 
	EndIf

end

return

//-------------------------------------------------------------------
/*/{Protheus.doc} isRunning
Verifica se o processo daquele ID ja esta no ar.

@author  Henrique Brugugnoli
@since   04/12/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function isRunning( cID )

Local cArqLck	:= GetPathSemaforo()+"autonfse_"+cID+".lck"

Local lContinua	:= .T.

makeDir(GetPathSemaforo())

If File(cArqLck)
   	If FOpen(cArqLck,16) < 0
		lContinua := .F.
	EndIf
Else
	If FCreate(cArqLck) < 0
		lContinua := .F.
	EndIf
EndIf 

return lContinua