#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STBAddFlow
Inclui registro para controle de fluxo

@author  Varejo
@version P11.8
@since   15/08/2016
@return  Nil 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBAddFlow( cFlowAction,aParams )

Local cStation 	:= PADR(STFGetStation("CODIGO"),TamSX3("LI_ESTACAO")[1]) // Estacao atual, utilizado na gravacao da SLI de controle de fluxo
Local cFunction	:= ProcName(1)					// Rotina que sera controlada
Local cParams		:= ""
Local nX			:= 0
Local cAuxLIMsg	:= ""
Local nCountRep	:= 1	//Qtde de vezes que reprocessou o fluxo(FlowAction)
Local aFlowAction	:= {}

Default cFlowAction := ""
Default aParams		:= []								

LjGrvLog( "Controle de Fluxo", "Entrou controle de fluxo cFlowAction:",cFlowAction)

//Verifica se ja tentou reprocessar mesma etapa do fluxo, limita qtde de tentativas de reprocessar mesmo fluxo para evitar looping infinito e travamento do PDV
aFlowAction := StrTokArr( cFlowAction, "|" ) //IdAction|Qtde
If Len(aFlowAction) > 1
	nCountRep 		:= Val(aFlowAction[2]) + 1	//incrementa contador
	cFlowAction	:= aFlowAction[1]			//ajusta nome do fluxo removendo informacao de Qtde
EndIf

//Monta parametros para execucao da Function
For nX := 1 To Len(aParams)
	cParams += IIF( ValType(aParams[nX]) == "C","'"+aParams[nX]+"'", cValToChar(aParams[nX]) ) + IIF( nX < Len(aParams),"|","") 	
Next nX

//Quando qtde de vezes que tentou reprocessar o mesmo fluxo atingir 3(se necessario, criar param para definir a qtde maxima), gera log e nao tenta novamente, para evitar looping infinito
If nCountRep >= 6
	LjGrvLog( "Controle de Fluxo", "Abortou reprocessamento de Fluxo. Motivo: Atingiu a quantidade de tentativas(5)",cFlowAction)
	cFlowAction := ""	
EndIf

If !Empty(cFlowAction) 
	cAuxLIMsg := cFunction + "|" + cFlowAction + "|" + Str(nCountRep) + "|" + cParams
Else 
	cAuxLIMsg := "OK" //Rotina utilizada para popular SLI(STFSLICreate) não considera LI_MSG vazio, por esse motivo é adicionado texto padrao "OK" 
EndIf	

LjGrvLog( "Controle de Fluxo", "Sera adicionado comando tabela SLI(Tipo: FLW) - LI_MSG:",cAuxLIMsg)

If !STFSLICreate( cStation, "FLW", cAuxLIMsg , "SOBREPOE" )
	LjGrvLog( "Controle de Fluxo", "Nao foi possivel incluir controle de fluxo(SLI)",cFlowAction)
EndIf
						
Return Nil
