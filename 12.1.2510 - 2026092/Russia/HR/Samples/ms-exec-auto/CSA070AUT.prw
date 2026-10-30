#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "CSAA070.CH"

/*{Protheus.doc} CSA070AUT()
@description Execute Automatic Generation for Directory of Salary/Tariff Rates
in accordance with data from specification NP_Specification_HR-HC-38-8_Directory for Tariff Rate_ENG

This is a sample!!

@author raquel.andrade
@since 06/07/2018
@version P12.1.17
@type function
*/
User Function CSA070AUT()
Local aAdvSize		As Array	
Local aAreaAlias	As Array  
Local aInfoAdvSize	As Array
Local aObjSize		As Array
Local aObjCoords	As Array
Local aAreas		As Array
Local nOpcA			As Numeric		
Local oDlg			As Object
Local oFont 		As Object
Local oType			As Object
Local oArea			As Object

Private cType		As Character
Private cArea		As Character

aAdvSize		:= {}	
aAreaAlias		:= GetArea()  
aInfoAdvSize	:= {}
aObjSize		:= {}
aObjCoords		:= {}
aAreas			:= {"77", "11", "51", "10", "42"}	 // some real codes of Areas in F5C
nOpcA			:= 0.00		
cType			:= Space(TamSX3("F5B_CODE")[1]) 	
cArea			:= Space(TamSX3("F5C_CODE")[1]) 	

	dbSelectArea("RBR")
	dbSelectArea("RB6")
           
    // An example of rendering a window with a user data request. Just an example.
	Begin Sequence
	        					   
		aAdvSize		:= MsAdvSize( , .T., 300)
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 10 , 10 }
		aAdd( aObjCoords , { 015 , 020 , .F. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )            
		                       
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
		DEFINE MSDIALOG oDlg TITLE "Directory of Salary/Tariff Rates Upload" FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
	        		
			@ aObjSize[1,1]+05, aObjSize[1,2]+30 SAY "Salary/Tariff Type" SIZE 146,10 OF oDlg PIXEL FONT oFont
			@ aObjSize[1,1]+05, aObjSize[1,2]+90 MSGET oType VAR cType SIZE 050,10 OF oDlg PIXEL  F3 'F5B' VALID ExistCpo('F5B') 	
			
			@ aObjSize[1,1]+25, aObjSize[1,2]+30 SAY "Salary/Tariff Area" SIZE 146,10 OF oDlg PIXEL FONT oFont
			@ aObjSize[1,1]+25, aObjSize[1,2]+90 MSCOMBOBOX oCombo VAR cArea ITEMS aAreas SIZE 050,010 OF oDlg PIXEL  

			
			oDlg:bSet15 := { ||If( 	C70AutVld(),( nOpcA := 1.00 , oDlg:End() ), ( nOpcA := 0.00 , oDlg:End() ) )}		
			
			oDlg:bSet24 := { ||  nOpcA :=  0.00 , oDlg:End() }
	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , oDlg:bSet15 , oDlg:bSet24 ) 
	
		If nOpcA == 1 		   
		   C70AutGr()
		EndIf 
			
	End Sequence
	
	RestArea( aAreaAlias ) 
	
Return Nil

/*/{Protheus.doc} C70AutVld()
@description Validate existence of key of generation.
/*/
Function C70AutVld()
Local lRet	As Logical

	lRet	:= .T.
	dbSelectArea("RBR")
	dbSetOrder(2) //RBR_FILIAL+RBR_CDTYP+RBR_CDARE+RBR_TABELA
	If dbSeek(xFilial("RBR") + cType + AllTrim(cArea))
		If !MsgYesNo( STR0113 )
			lRet := .F.
		EndIf
	EndIf

Return( lRet )

/*{Protheus.doc} C70AutGr())
@description Execute Automatic Generation in accordance with parameters.
The main function that loads information into dictionaries. 
Uses the program's CSAA070(xAutoCab,xAutoItens,nOpcAuto,lEAutMU) ability to download data without an interface.
*/
Function C70AutGr()

	u_C70Aut01(cType,cArea) // Tariff 01
	u_C70Aut02(cType,cArea) // Tariff 02
	u_C70Aut03(cType,cArea) // Tariff 03
	u_C70Aut04(cType,cArea) // Tariff 04
	u_C70Aut05(cType,cArea) // Tariff 05
	u_C70Aut06(cType,cArea) // Tariff 06
	u_C70Aut07(cType,cArea) // Tariff 07

Return