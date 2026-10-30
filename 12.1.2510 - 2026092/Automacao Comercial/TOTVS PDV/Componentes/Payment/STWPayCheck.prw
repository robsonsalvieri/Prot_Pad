#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWPAYCHECK.CH"

Static aRetCheck	:= {} 					//Dados do cheque
Static lUsaConCh	:= STWChkTef("CH")	//Utiliza Consulta de Cheque


//--------------------------------------------------------------------
/*/{Protheus.doc} STWPayCheck
Executa as funcionalidades de leitura, consulta e impressao de cheque

@param lCheck  			Campo checado
@param oPanGetPaym		Objeto pegar pagamento
@param nPosHozPan		Posicao horizontal
@param nPosAltPan 		Posicao Altura
@param nTamLagPan		Tamanho Largura
@param nTamAltPan		Tamanho Altura 	
@author  	Varejo
@version 	P11.8
@since   	04/03/2013
@return  	lRet - Se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWPayCheck( 	lCheck		, bCreatePan 	)

Local lUsaCMC7 		:= STFUseCmc7()		//Utiliza CMC7
Local lUsaImpCh		:= STFUsePrtCh()		//Utiliza Impressao de Cheque
Local lCallDataChk	:= .F.				// Indica se o STIDATACHECK foi chamado

Default lCheck 			:= .F.
Default bCreatePan		:= 	Nil

ParamType 0 var 	lCheck 			As Logical	Default 	.F.

If lUsaImpCh .AND. !lCheck .AND. Len(aRetCheck) > 0
	
	STBPrintChk(aRetCheck)
	aRetCheck := {}
		
ElseIf lCheck

	/*	Dados do cheque por CMC7 ou manual	*/
	If lUsaCMC7
		
		aRetCheck	:= {}
		aRetCheck 	:= STBLeCMC7()
		
		/* Consulta do cheque */
		If lUsaConCh
			STBConCheck(aRetCheck)
		Else
			STBInsCheck()
		EndIf
		
	Else
		lCallDataChk := .T.
		STIDataCheck(bCreatePan)
	EndIf
	
EndIf

If !lCallDataChk 
	// Caso o fonte de interface STIDataCheck nao seja chamado, habilito as opcoes do pagamento.
	STIEnblPaymentOptions()
EndIf

Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} STWGetCkRet
Retorna os dados do cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	05/04/2013
@return  	aRet - Dados do cheque
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWGetCkRet()

Local aRet := aRetCheck // Dados do cheque

Return aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} STWSetCkRet
Seta os dados do cheque

@param   	aRet
@author  	Varejo
@version 	P11.8
@since   	05/04/2013
@return  	lRet - Se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWSetCkRet(aRet)

If !Empty(aRet)
	aAdd(aRetCheck, aRet)
Else
	aRetCheck := {}
	
	If FindFunction("STBClearCk")
		STBClearCk()
	EndIf
EndIf	

Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} STWConChk
Consulta cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	05/04/2013
@return  	lRet - Se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWConChk()

// Consulta do cheque 
If lUsaConCh
	STBConCheck(aRetCheck)
Else
	STBInsCheck()
EndIf

Return .T.


//--------------------------------------------------------------------
/*/{Protheus.doc} STWValField
Valida campos

@param   	
@author  	Varejo
@version 	P11.8
@since   	04/12/2015
@return  	lRet - Retorna se o campo é vazio
@obs     
@sample
/*/
//--------------------------------------------------------------------
Function STWValField(cCampo, cConteudo)

Local lRet := .T.

If Empty(cConteudo)
	lRet := .F.
	STFMessage(ProcName(),"STOP", STR0001 + cCampo + STR0002)	//Campo '<campo>' deve ser preenchido.
	STFShowMessage(ProcName())
Else
	STFCleanInterfaceMessage()
EndIf

Return lRet
