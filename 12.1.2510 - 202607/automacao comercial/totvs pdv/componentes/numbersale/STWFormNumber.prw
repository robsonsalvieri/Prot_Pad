#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFormNumber
Workflow para geracao da numeracao de venda.

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWFormNumber()

Local nMvTpNrNfs := SuperGetMV( "MV_TPNRNFS" ) 	//Define o tipo de controle da numeracao dos documentos de saida ( 1-SX5 | 2-SXE/SXF | 3-SD9 )
Local lMvCtrlFol	:= SuperGetMV( "MV_CTRLFOL" ) 	//Define se utiliza ou nao o controle de formulario
Local cCOONumber	:= STBNumCoo()						//Recupera o numero do coo
Local cFabNumber	:= STBNumFab()						//Recupera o numero de fabricacao
Local cInterQtd	:= STBQtdeInt()					//Recupera a quantidade de intervencoes da impressora

If lMvCtrlFol
	//Controle de formulario	
	STDEspeFor()
ElseIf !Empty(cCOONumber) .AND. !Empty(cFabNumber) .AND. !Empty(cInterQtd)
	//Se a impressora conseguir retornar o numero de Coo + Numero de Fabricao e Qtd de intervencoes
	//entao utiliza essas 3 combinacoes para formar a numeracao da venda.
		
ElseIf !Empty(cCOONumber)
	//Se a impressora retornar o numero de fabricacao e Qtd de intervencoes, entao utiliza a
	//combinacao de numero de coo + serie Lg_Serie

Else
	If nMvTpNrNfs = 1 .OR. nMvTpNrNfs = 2
		STBNumSx5()		
	Else
		STBNumSd9()		
	EndIf	
EndIf
	
Return Nil