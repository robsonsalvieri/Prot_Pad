#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDMRValid
Valida se existe cadastros válidos de midia

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se existem registros válidos de midia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDMRValid()

Local lRet 		:= .F. 			// Retorna se existem cadastros validos
Local aArea 	:= GetArea()			// Armazena alias corrente
  
DbSelectArea("SUH")
DbSetOrder(1)  // UH_FILIAL + UH_MIDIA  

If DbSeek(xFilial("SUH"),.T.)  
	While !EOF()
    	If SUH->UH_VALIDO=="1"
			lRet := .T.
			Exit
		EndIf
		DbSkip()
	EndDo	
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDMRGet
Busca as midias cadastradas

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   aMidias					Retorna As midias cadastradas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDMRGet()

Local aMidias	:= {}	   			// Retorna as midias cadastradas
Local aArea 	:= GetArea()		// Armazena alias corrente
  
DbSelectArea("SUH")
DbSetOrder(1)  // UH_FILIAL + UH_MIDIA  

If DbSeek(xFilial("SUH"))  

	While !EOF() .AND. ( xFilial("SUH") == SUH->UH_FILIAL )
	
    	If SUH->UH_VALIDO == "1"    	
    		AADD( aMidias , { SUH->UH_MIDIA , SUH->UH_DESC } )    	
		EndIf
		
		SUH->(DbSkip())
		
	EndDo	

EndIf

RestArea(aArea)

Return aMidias


