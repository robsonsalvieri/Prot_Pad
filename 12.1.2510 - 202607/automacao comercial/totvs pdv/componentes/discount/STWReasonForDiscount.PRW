#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STWREASONFORDISCOUNT.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRsnDesc
Function Motivo de Desconto

@param	nItemLine			Linha do Item na Venda (Passar 99999 para Desconto no Total)
@param	cMotCode			Codigo do Motivo de Desconto	
@param	cObs				String obs
@param	cItemCode			Codigo do Produto	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se efetuou Motivo de Desconto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRsnDesc( nItemLine	,	cMotCode	,	cObs	,	cItemCode, ;
						cCodSup )

Local lRet				:= .T.				   				// Retorna se efetuou Motivo de Desconto10%2
Local cType				:= ""								// Tipo de desconto. Se ITEM ou TOTAL
Local cRFDFromRD		:= SuperGetMV("MV_LJMDRD", ,"")		// Codigo do Motivo de Desconto via Regra de Desconto

Default nItemLine 		:= 0					// Linha do Item na Venda
Default cMotCode 		:= ""					// Codigo do Motivo de Desconto	
Default cObs 			:= ""					// String obs
Default cItemCode 		:= ""					// Codigo do Produto
Default cCodSup			:= "" 					// Código do Supervisor que liberou o desconto

// Verifica se utiliza motivo de desconto. Existindo algum registro no cadastro utiliza.
lRet := STDRsnDesc()
			
// Verifica se o item e valido
If lRet	
	If nItemLine <= 0 
	
		lRet := .F.                                                                             
		STFMessage("STRsnDesc","STOP", STR0001) //"Nao é possível atribuir Motivo de Desconto para item 0"
		
	EndIf
EndIf	

If lRet
		
	// Se nao foi passado o motivo de desconto, chama tela.
	If Empty(cMotCode)

		/*/
			Get do motivo informado via interface
		/*/
		cMotCode := STIGetReason()
		cObs	 := STIGetObsReason()
		lRet := !(Empty(cMotCode))					
					
	Else
	
		If cMotCode == "REGRA DE DESCONTO"
		
			/*/
				Validar se cadastra Motivo de Desconto por Regra de desconto
			/*/
			If !Empty(cRFDFromRD)
												
				If STDRFDFromRD(cRFDFromRD) // Verifica se utiliza					
					cMotCode := cRFDFromRD 					
				Else				
					lRet := .F.					
				EndIf 
				
			Else				
				lRet := .F.			
			EndIf
		
		EndIf
		
	EndIf
	
	If lRet		
	
		If nItemLine == 99999
			cType = "VALOR"
		Else
			cType = "ITEM"
			If Empty( cItemCode )
				cItemCode := STBTaxRet( nItemLine , "IT_PRODUTO" )
			EndIf
		EndIf		
			
		STDAddReason( 	nItemLine	, cMotCode , cObs ,	cItemCode , ;
							cType 	, cCodSup	) 
					
	EndIf 
			
EndIf

STFShowMessage("STRsnDesc")
		
Return lRet






