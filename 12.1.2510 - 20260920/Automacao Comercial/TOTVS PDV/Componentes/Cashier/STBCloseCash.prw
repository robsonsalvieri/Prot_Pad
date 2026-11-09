#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STBCLOSECASH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBAutCloseCash
Verifica Autorizacao(permissao) de usuario e caixa para 
Abrir/Fechar o caixa
@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  aRet 	Retorna permissao sim ou nao/ Supervisor
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBAutCloseCash()

Local cSupervisor 	:= ""				// Usuario Supervisor
Local aRet			:= {.F.,""} 		// Retorno

// Verifica permissao de usuario
If ChkPsw(41)
	
	//Verifica permissao de caixa	
	aRet := STFProFile( 4 )// 4 - Permissao para abrir e fechar o caixa
	   

	If !aRet[1]
	
	    If lUsaDisplay                    
	 		// Inicia Evento
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "2C"+ STR0001 } ) //"Senha invalida ou acesso negado"
		End
		
		// Usuario / sem permissao para Abrir/Reabrir/Fechar o Caixa. / Atenção	
		STFMessage("OpenCash","STOP","Atencao, Usuario " + cUserName + STR0002) //Sem permissao para Abrir/Fechar o Caixa		
		
		If lUsaDisplay
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "2E"+ STR0003 } ) //"Codigo do Produto: "
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "1E"+ " " } )
   		End
		
	Endif	

EndIf

Return aRet


