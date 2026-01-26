#include "protheus.ch"


Template Function PCLCapAbast()

Local nOpc 		:= 0                                             
Local oTime1    := NIL //era private
Local oTime2    := NIL//era private
Local _nID   //talvez erro

Private aDadosBMB 	:= {}//era private

Private _nControl   := 0 
Private oAPET 		:= Nil 
//Private oDlg		:= Nil 

/*Estrutura do aDadosBMB
1 - Selecionado Valor lógico padrao .F.
2 - Estado 	 	ES especifica o estado atual da bomba
3 - Bico   	 	BC o bico equivalente às informações
4 - VlrTot 	 	VA o valor abastecido pelo bico	
5 - VlrUni	 	PU o preço unitário
6 - Volume 	 	VL o volume
7 - Encerrante 	EC oencerrante
*/
 
// vai sumir 

	DEFINE MSDIALOG oDlg FROM  31,58 TO 300,778 TITLE "ABASTECIMENTOS" PIXEL                      

		@ 05,05 LISTBOX oLbx1 FIELDS HEADER " *", "Bico", "Descrição", "Valor Unitário", "Volume", "Valor Total", "Data", "Hora"  SIZE 345, 85 OF oDlg PIXEL ;
		ON DBLCLICK (MARK_OPC())    

	   	DEFINE TIMER oTime1 INTERVAL 2000 ACTION T_PCLLeAbast() OF oDlg
	   	DEFINE TIMER oTime2 INTERVAL 30000 ACTION T_PCLCarAbast() OF oDlg                                                                                   
		
		DEFINE SBUTTON FROM 104, 262 TYPE 21 ENABLE OF oDlg ACTION (T_PCLCarAbast()) // BOTAO REFRESH
		DEFINE SBUTTON FROM 104, 292 TYPE 1 ENABLE OF oDlg ACTION (T_PCLGeraOrc(), T_PCLCarAbast()) // BOTAO OK
		DEFINE SBUTTON FROM 104, 322 TYPE 2  ENABLE OF oDlg ACTION (oDlg:End()) // BOTAO CANCELAR
 
		T_PCLCarAbast()
       	oTime1:Activate()
       	oTime2:Activate()
 
	ACTIVATE MSDIALOG oDlg CENTERED                                                      

Return Nil                                                                                 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inverte a marca do ListBox.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MARK_OPC()
 
	_nID := oLbx1:nAt
	
	If (aDadosBMB[oLbx1:nAt, 8] == .F.)
		Return
	EndIf
	
	IF (aDadosBMB[oLbx1:nAt, 1] == .F.)
		aDadosBMB[_nID,1] := .T.
	else
		aDadosBMB[_nID,1] := .F.
	EndIF
	
	oLbx1:Refresh()

Return
		
