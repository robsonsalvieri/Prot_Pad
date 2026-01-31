#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STBNotConcSale
Function responsável por enviar os comandos de uma venda não concomitante
@param   		1- aArray - Dados da abertura do cupom fiscal
            	2- aArray - Dados dos Itens do cupom fiscal
            	3- aArray - Dados dos pagamentos do cupom fiscal
@param			Array de Itens            	
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	lRet - Se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBNotConcSale( aOpencup , aItens )

Local lRet 			:= .T.				// Retorno
Local nRet 			:= -1				// Retorno Função ECF
Local nX				:= 0            // Controle While array Itens

Default aOpenCup		:= {}					// Item do Array que deve ser inicializado
Default aItens		:= {}				// Array de otimizacao de Inicializacao 

ParamType 0 Var  	aOpencup	As Array	Default {}
ParamType 1 Var 	aItens 		As Array	Default {}

//Executa Função de Abertura do Cupom
nRet := STWOpenReceipt(	aOpencup[1][1], aOpencup[1][2], aOpencup[1][3], aOpencup[1][4],;
							aOpencup[1][5], aOpencup[1][6])

//Verifica retorno de função de abertura do Cupom Fiscal
If nRet = 0
	
	//Processa os Itens do Cupom Fiscal
	For nX := 1 To Len(aItens)
		nRet:= STWRegItem( 	aItens[nX][1], aItens[nX][2], aItens[nX][3], aItens[nX][4],;
								aItens[nX][5], aItens[nX][6], aItens[nX][7], aItens[nX][8])
		If nRet <> 0
			STFMessage("STBNotConcSale","ALERT","Falha no Registro do Item Não Concomitante")
			lRet := .F.
	    EndIf    
	Next nX	
EndIf
	

Return lRet