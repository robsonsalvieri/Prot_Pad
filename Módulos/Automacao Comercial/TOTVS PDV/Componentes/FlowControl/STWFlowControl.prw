#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFlowControl
Verifica se existe acao pendente para encerrar o fluxo de rotina, quando ocorre a saida inesperada do Sistema (Queda de energia) 
Obs.: Necessario para controle do processamento de algumas rotinas. Motivo: nao existe controle de transacao para ambiente Codebase e nas interacoes com perifericos 
@author  Varejo
@version P11.8
@since   15/08/2016
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWFlowControl( )

Local aAuxLIMsg	:= {}
Local cFunction	:= ""
Local cIdAction	:= ""
Local nX			:= 0
Local aGetFunc	:= {}
Local nPosFunc	:= 0

	
aAuxLIMsg := STDRetFlow()	//Retorna fluxo pendente de execucao

If Len(aAuxLIMsg) >= 3
	cFunction 	:= aAuxLIMsg[1]
	cIdAction	:= aAuxLIMsg[2] + "|" + aAuxLIMsg[3]
			
	//Verifica qual posicao do parametro de controle de fluxo
	If FindFunction('GetFuncPrm')
		aGetFunc := GetFuncPrm(cFunction)		
		nPosFunc := aScan(aGetFunc,{|x| Upper(AllTrim(x)) == "CFLOWACTION"})
	EndIf 
		
	cFunction += "("
	For nX := 4 To Len(aAuxLIMsg)			
		If (nX-2 <> nPosFunc) .AND. (nX-2 <> nPosFunc + 1)
			cFunction += IIF( ValType(aAuxLIMsg[nX]) == "C",aAuxLIMsg[nX], cValToChar(aAuxLIMsg[nX]) )
		Else
			cFunction += "'" + cIdAction + "'"  	
		EndIf
		
		If nX < Len(aAuxLIMsg)
			cFunction += ","
		EndIf 
					 		
	Next nX
	cFunction += ")"		
	
	LjMsgRun("Em 5 segundos será reprocessado a rotina: ["+aAuxLIMsg[1]+"] etapa: [" + aAuxLIMsg[2] + "] tentativa: "+AllTrim(aAuxLIMsg[3])+ " de 5","Reprocessamento de Rotina",{|| Sleep(5000)})

	//MacroExecuta Rotina para continuar o fluxo interrompido
	&(cFunction)				 
EndIf


						
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWFlwCheck
Verifica se existe acao pendente para encerrar o fluxo de rotina, quando ocorre a saida inesperada do Sistema (Queda de energia) 

@author  Varejo
@version P11.8
@since   15/08/2016
@return  lRet					Retorna se a venda está em andamento ou não
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWFlwCheck(cFlowAction, aParams)

Local lRet := .T.
	
Default cFlowAction 	:= ""
Default aParams		:= []	

Do Case
	
	Case cFlowAction == "STBCSCancCupPrint"
		lRet := CancCupPrint(aParams)				

EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWFlwCheck
Verifica se existe acao pendente para encerrar o fluxo de rotina, quando ocorre a saida inesperada do Sistema (Queda de energia) 

@author  Varejo
@version P11.8
@since   15/08/2016
@return  lRet					Retorna se a venda está em andamento ou não
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CancCupPrint(aParams)

Local cDoc			:= ""
Local nTamDocEcf	:= 6				//Tamnho do Numero do Cupom ( 6 ou 9 digitos)
Local lRet			:= .F.				

Default aParams	:= []

//Verificar se solicitacao de cancelamento do ultimo cupom foi realizada pelo ECF
//Regra: Somente entra nesse fluxo caso tenha enviado o comando de cancelamento,
//sendo assim, se o numero do proximo cupom for igual o cupom que deseja cancelar +1, sinalizar que conseguiu realizar o comando. 

cDoc			:= STBRetCup()
nTamDocEcf 	:= STBLenReceipt(cDoc)
cDoc			:= StrZero(Val(cDoc)-1,nTamDocEcf)

lRet := aParams[2] == cDoc

Return lRet 
