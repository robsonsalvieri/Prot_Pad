#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH" 
#INCLUDE "STWCustomerSelection.CH"


//-------------------------------------------------------------------
/*/ {Protheus.doc} STWCustomerSelection
WorkFlow responsavel pela selecao de clientes.
@param   cKey			- Chave para busca no Back-Office
@author  Varejo 
@version P11.8
@since   26/09/2012
@return  oModelCliente - Retorna model do cliente  
/*/
//-------------------------------------------------------------------
Function STWCustomerSelection(cKey,cOrc, aMDJ)

Local lOffline 		:= .T. 							// Por questoes tecnicas, a busca pelo cliente sera feita apenas offline, porem a busca online ja esta implementada
Local aDadosCli 		:= {} 								// Array de dados do cliente
Local aParam 			:= {}  							// Array de parametros
Local cCliente 		:= "" 								// Cliente 
Local cLojaCli 		:= "" 								// Loja do cliente
Local cCliPad		:= SuperGetMv("MV_CLIPAD") 		// Cliente padrao
Local cLojaPad		:= SuperGetMV("MV_LOJAPAD") 	// Loja padrao
Local oModelCliente 	:= Nil 							// Model de cliente
Local uResult			:= Nil 							// Resultado generico
Local lSelNcc			:= ExistBlock("STSelNcc")		//Existe ponto de entrada para selecao da NCC?	
Local aSelNcc			:= {}								//Recebe o retorno do ponto de entrada STSelNcc
Local lImport			:= .F.							//Variavel de controle para importação de orçamento com NCC

Default cKey 		:= ""
Default cOrc 		:= ""
Default aMDJ		:= {} 

ParamType 0 var  cKey 			As Character	Default ""				

If !lOffline // Busca na retaguarda

	While .T. 		
		//  Trecho para recebimento do model do cliente
		
		aParam := {xFilial("SA1")+cKey,lOffline}		
		
		// Tratamento do erro de conexao
		If !STBRemoteExecute("STDCustomerData", aParam,,, @uResult)			
			 
			
			//TO DO: STFMessage(ProcName(), "STOP", oServer:cStatusDescription)
			STFMessage(ProcName(), "ALERT", STR0001 ) //"Por falta de comunicação com o Back-Office, será selecionado o cliente padrão."
			
			// Como houve falha na conexao, sera selecionado o cliente padrao e sera iniciado o processo offline.
			cKey 			:= cCliPad+cLojaPad
			lOffline 		:= .T.
			
			
			//Esse Exit sai do processo Online, iniciando logo em seguida o processo offline,
			//onde sera setado na cesta os dados do cliente padrao.			
			Exit 
			
		Else 
			oModelCliente := STDFilCliData(uResult)							
			uResult := Nil				
		EndIf
				
		//TO DO: RECEBER OS DADOS DO CLIENTE DA RETAGUARDA E ATUALIZAR AS INFORMACOES NO PDV.
		cCliente := oModelCliente:GetValue("SA1MASTER","A1_COD")
		cLojaCli := oModelCliente:GetValue("SA1MASTER","A1_LOJA")
		
		Exit	
	End	
EndIf


If lOffline  
	//  Atribuicao do model do cliente à variavel de Retorno.
	
	oModelCliente := STDCustomerData(xFilial("SA1")+cKey,lOffline)
	cCliente := oModelCliente:GetValue("SA1MASTER","A1_COD")
	cLojaCli := oModelCliente:GetValue("SA1MASTER","A1_LOJA")
	
EndIf

If Empty(cCliente) .AND. Empty(cLojaCli) .AND. !Empty(cKey) 
	cCliente := SubStr(cKey,1,Len(CriaVar("A1_COD")))
	cLojaCli := SubStr(cKey,Len(CriaVar("A1_COD")) + 1,Len(CriaVar("A1_LOJA")))
EndIf


If Substr(SuperGetMV("MV_USACRED"),2,1) == "S" .AND. (AllTrim(cCliente)+AllTrim(cLojaCli)) <> (AllTrim(cCliPad)+AllTrim(cLojaPad))
	/*   
	  Trecho para recebimento do model das NCCs do cliente
	*/
	
	//Como será utilizado o cliente do PDV listamos as NCCs do cliente informado no PDV.
	If (!Empty(cOrc) .And. SuperGetMV("MV_LJIPCOR",.F.,0) <> 1 )
		lImport := .T.
	EndIf
	aParam := {cCliente,cLojaCli,lImport,cOrc}	
	If lSelNcc
		aSelNcc := ExecBlock("STSelNcc",.F.,.F.,aParam)
		If Len(aSelNcc) > 0
			STDSetNCCs("1",aSelNcc)
			aSelNcc := {}
		EndIf
	Else		

		If (LjGetCPDV()[1] .OR. LjGetCPDV()[2]) .AND. Len(aMDJ)>0
			aParam := {cCliente, cLojaCli, lImport, cOrc, aMDJ}	
		Endif 

		If !STBRemoteExecute("STDFindNCCModel", aParam,,, @uResult)			
			// Tratamento do erro de conexao
			STFMessage(ProcName(), "ALERT", STR0002 )  //"Por falta de comunicação com o Back-Office, as NCCs do cliente não serão carregadas."		
			STFShowMessage(ProcName())		
		Else
			STDSetNCCs("1",uResult)
			uResult := Nil
		EndIf
	EndIf
EndIf

Return oModelCliente

//-------------------------------------------------------------------
/*{Protheus.doc} STBValidCliPad
Funcao que verifica se o cliente digitado pelo usuario eh o cliente padrao. Caso seja, seta lSearchOffline para True, 
a fim de forcar todo o processo de selecao de clientes para ocorrer em ambiente local.
@param   cKey			- Chave para busca no Back-Office
@author  Varejo 
@version P11.8
@since   26/09/2012
@return  lRet 			- Retorna True caso o cliente digitado seja o cliente padrao, o que forca a pesquisa em ambiente local.
*/
//-------------------------------------------------------------------

Function STBValidCliPad( cKey )

Local cCliPad			:= SuperGetMv( "MV_CLIPAD" )		//Cliente Padrao
Local cLojaPad		:= SuperGetMV( "MV_LOJAPAD")		//Loja Padrao do cliente
Local lRet			:= .F.									//Retorno

Default cKey      := ""

ParamType 0 var  cKey 			As Character	Default ""				

If (cKey == cCliPad+cLojaPad)
	lRet := .T.
EndIf

Return lRet

