#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"   

//-------------------------------------------------------------------
/*/{Protheus.doc} STDDelBrindeCesta
Function Exclui item da Cesta de Brinde

@author  Varejo
@version P11.8
@since   21/05/2014
@return  lRet				Retorna se deletou com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDelBrindeCesta(lCheca ) 

Local aArea		:= GetArea()									// Posicionamento atual da tabela 
Local nX 		 := 0   											// Contador
Local lRet 		 := .F.										// Retorna se deletou
Local nQtdItens  := STDPBLength("MGC") 						// Quantidade total de registros na cesta MGC 
Local oModel 	  := STDGPBModel()								// Objeto Model

Default lCheca := .F. //Checa se o brinde é por forma de pagto, que no caso só pode existir 1 brinde por Forma de Pagto e no caso 
                      // da Forma de Pgto ser limpa e ja exista um brinde incluido é ncessario excluí-lo da cesto 

//Cancelar o item da cesta MGC
For nX := 1 to  nQtdItens
	
	If !lCheca
		If alltrim(oModel:GetModel("MGCBRINDE"):acols[nX][12]) <> "" //Posicao da Forma de Pagamento
			oModel:GetModel("MGCBRINDE"):DeleteLine()
	   		lRet := .T.
		Endif
	Endif
		
Next nX 

RestArea(aArea)
Return lRet

        
//-------------------------------------------------------------------
/*/{Protheus.doc} STDSalvaBrindes
Function Salva brindes da Cesta de Brinde

@author  Varejo
@version P11.8
@since   21/05/2014
@return  lRet				Retorna se deletou com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSalvaBrindes() 
Local aArea		:= GetArea()														// Posicionamento atual da tabela 
Local oModel 		:= STDGPBModel()													// Objeto Model
Local aMGCFields	:= oModel:GetModel("MGCBRINDE"):GetStruct():GetFields()		// Array Campos MGC
Local nQtdItens 	:= STDPBLength("MGC") 											// quantidade total de registros na cesta MGC 
Local nX 			:= 0																// Contador X
Local nY			:= 0																// Contador Y

//Gravacao do Brinde
For nX := 1 to  nQtdItens //de onde esta vindo essa quantidade de Itens

	If oModel:GetModel("MGCBRINDE"):acols[nX][13] == .F. // Somente irá gravar na MGC se o item não estiver deletado
		
		DbSelectArea("MGC")
		oModel:GetModel("MGCBRINDE"):GoLine(nX)
		MGC->(DbSetOrder())
		
		RecLock("MGC",.T.)
		
		For nY := 1 To Len(aMGCFields)
			cField := aMGCFields[nY,MODEL_FIELD_IDFIELD]
			REPLACE &(cField) WITH STDGPBasket( "MGC" , cField)
		Next nY
		
		MGC->(MsUnlock())		
					
	Endif
Next nX 

RestArea(aArea)
Return 



