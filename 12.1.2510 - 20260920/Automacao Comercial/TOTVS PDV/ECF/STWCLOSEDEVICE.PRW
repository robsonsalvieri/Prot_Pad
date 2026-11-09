#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseDevice
Fecha Variaveis do Sistema 
@param 	oNewTEF - Objeto TEF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet - Retorna se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseDevice(oNewTEF) 

Local aRet := {} 	//Array de retorno 
Local lRet := .T.	//Retorno

Default oNewTEF := STBGetTef()


If Valtype(oNewTEF) == "O" 
	If oNewTEF:lAtivo

		oNewTEF:Fechar() 
	EndIf 
	oNewTEF :=	FreeObj(oNewTEF)
EndIf     


IF !Empty(STFGetStat("GAVETA")) .AND. !Empty(STFGetStat("PORTGAV"))  
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STDrawerClose"																,;		// Nome do evento
							{STFGetStat("GAVETA")														,;	
							STFGetStat("PORTGAV"),;
							STFGetStat("PORTIF")} )

EndIf



If !Empty(STFGetStat("OPTICO")) .AND. !Empty(STFGetStat("PORTOPT"))    
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STReaderClose"																,;		// Nome do evento
							{STFGetStat("OPTICO")														,;	
							STFGetStat("PORTOPT"),;
							'F'} )
	
EndIf


If !Empty(STFGetStat("IMPCHQ") )  .AND. !Empty(STFGetStat("PORTCHQ"))
	//Fecha a impressora de cheques     
	aRet :=	STFFireEvent(	ProcName(0)															,;		// Nome do processo
							"STCHClose"																,;		// Nome do evento
							{STFGetStat("PORTCHQ") } ) 
	
EndIf 

If !Empty(STFGetStat("CMC7") )  .AND. !Empty(	STFGetStat("PORTMC7") )
	
	aRet :=	STFFireEvent(	ProcName(0)															,;		// Nome do processo
							"STCM7Close"																,;		// Nome do evento
							{																			,;		// 
							STFGetStat("PORTMC7") } )


EndIf     

If !Empty(STFGetStat("BALANCA") )  .AND. !Empty(STFGetStat("PORTBAL") )
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STBalanceClose"																,;		// Nome do evento
						    {STFGetStat("PORTBAL")} )


EndIf 

If !Empty(STFGetStat("PORTIF")) .AND. !Empty(STFGetStat("IMPFISC"))

	aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
									"STCloseCom"																,;		// Nome do evento
									{STFGetStat("PORTIF") } ) 

EndIf
    
/*aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
							"STReleaseObj"																,;		// Nome do evento
							{} )      */

Return lRet


