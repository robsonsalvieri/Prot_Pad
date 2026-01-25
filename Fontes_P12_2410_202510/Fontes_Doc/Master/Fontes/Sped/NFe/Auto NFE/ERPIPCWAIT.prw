#Include 'Protheus.ch' 
#INCLUDE "TOTVS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} ERPIPCGO()

Executa um processo em multiThreads.

@param	cFuncao	Nome da função do processamento. 	  
@param	cParX		Parametros de referencia para execução do processo

@return  

@author Cleiton Genuino
@since 		03/11/2016
@version 3.0

/*/
//-------------------------------------------------------------------
function ERPIPCGO(cFuncao, lWait, cSemaforo, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9, cPar10, cPar11, cPar12, cPar13)

	local bExec
	local lSend		:= .F.
 	
 	default lWait	:= .T.
 	default cSemaforo := ""	
			
	 	while !lSend    
		
			lSend := ipcgo(cSemaforo , cFuncao, cPar1, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9, cPar10, cPar11, cPar12, cPar13)	
					
			if lWait .and. !lSend 
				ERPInternal("ERPIPCWAIT[waiting for free Threads] [ " + dtoc(date()) + " : " + time()+"]")
				sleep(2000)
			else
				exit
			endif
	
		end

return lSend

//-------------------------------------------------------------------
/*/{Protheus.doc} preparaIPCWAIT()

Prepara Theads para processamento
  
@param

@return  

@author Cleiton Genuino
@since 		03/11/2016
@version 3.0

/*/
//-------------------------------------------------------------------
main function prepareIPCWAIT()
	
	local bBLoco 
	local cFuncao	:= ""
	local cPar1	:= ""
	local cPar2	:= ""
	local cPar3	:= ""
	local cPar4	:= ""
	local cPar5	:= ""
	local cPar6	:= ""
	local cPar7	:= ""
	local cPar8	:= ""
	local cPar9	:= ""
	local cPar10	:= ""
	local cPar11	:= ""
	local cPar12	:= ""
	local cPar13	:= ""
	local cPar14	:= ""
	local cPar15	:= ""
	local nTimeout :=  val(GetPvProfString(GetWebJob(), "ExpirationTime" , "30", GetADV97() ) )
	local lAtIpcgo := iif (getSrvProfString("ACTIVATE","OFF") == "ON",.T.,.F.) //Ativa IPCGO
	local nKillTime := seconds() + nTimeOut 
	local dDate 	:= date() 
    
    nTimeout := nTimeout * 1000

if lAtIpcgo
	
	while !killApp()
		
		ERPInternal("ERPIPCWAIT[waiting for call "+ cFuncao + "] [ " + dtoc(date()) + " : " + time()+"]")			
		
		if( ipcWaitEx( GetWebJob(), nKillTime, @cPar1, @cPar2, @cPar3, @cPar4, @cPar5, @cPar6, @cPar7, @cPar8, @cPar9, @cPar10, @cPar11, @cPar12, @cPar13, @cPar14, @cPar15) )
		
			cFuncao := cPar1
			
			ERPInternal("ERPIPCWAIT[running - " + cFuncao + "] [ " + dtoc(date()) + " : " + time()+"]")							
			
			bBLoco := &("{| |"+cFuncao+"(cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9, cPar10, cPar11, cPar12, cPar13, cPar14, cPar15)}")
						
			eval(bBLoco, cPar2, cPar3, cPar4, cPar5, cPar6, cPar7, cPar8, cPar9, cPar10, cPar11, cPar12, cPar13, cPar14, cPar15)		
			
			cPar1 := cPar2 := cPar3 := cPar4 := cPar5 := cPar6 := cPar7 := cPar8 := cPar9 := cPar10 := cPar11 := cPar12 := cPar13 := cPar14 := cPar15 := ""
		
		else
	
			exit
			
		endif
		
	    if( seconds() >= nKillTime .Or. Date() > dDate )
	        exit

	    endif		

	
	endDo
Else
	autoNfseMsg( " Chave do IPCGO ACTIVATE  Esta -->OFF ", .F. )
Endif

return



//-------------------------------------------------------------------
/*/{Protheus.doc} ERPInternal
Seta mensagem de informacao do processo em execucao no SmartClient Monitor e dbAcess Monitor

@author Cleiton Genuino
@since 		03/11/2016
@version 	P12
@see 		NIL
/*/
//-------------------------------------------------------------------
Function ERPInternal(cMsg)
	Local lMonitor	:= FindFunction("FWMonitorMsg")
	Default cMsg	:= ""
	
	If !Empty(cMsg)
		if lMonitor
			FWMonitorMsg(alltrim(cMsg))
		endif
 		TcInternal(1,alltrim(cMsg))
	EndIf

Return

