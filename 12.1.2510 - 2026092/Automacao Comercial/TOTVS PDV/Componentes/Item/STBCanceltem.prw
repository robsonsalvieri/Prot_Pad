#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"     
#INCLUDE "STBCANCELTEM.CH"
#INCLUDE "STPOS.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValCnItem
Valida o cancelamento do Item

@param   nItem				Numero do item na venda
@param   cItemCode			Codigo do Item
@author  Varejo
@version P11.8
@since   01/06/2012
@return  lRet  - Retorna validacao da funcao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValCnItem( nItem , oModelCesta )

Local lRet			:= .F.								//Retorno
Local aLines		:= FwSaveRows()						//Linhas do model
Local nTotItens		:= 0								//Total de Itens
Local nI			:= 0								//Itens da Cesta
Local lLjLsPre		:= SuperGetMv("MV_LJLSPRE",, .F.) 	//Funcionalidade de Lista de Presente Ativa
Local lItFiscNFi	:= .F.								//Verifica se existe o item fiscal e não fiscal para cancelamento no ECF (FieldPos)
Local aEstrItNFisc	:= {}								//Estrutura do Item Cancelado (FieldPos)

Default	nItem	    := 0								// Numero do item na venda
Default oModelCesta := Nil

	
ParamType 0 Var nItem	  AS Numeric	Default 0
ParamType 1 Var oModelCesta AS Object	Default Nil


//verifica se existe o item fiscal e não fiscal para cancelamento de item no ECF (FieldPos do Model)
aEstrItNFisc := STDGetProperty( "L2_ITFISC" )

lItFiscNFi	:= Len(aEstrItNFisc) > 0


/*/
	Verificar se o item existe	nas funcoes fiscais
/*/	
If ( STBTaxFoun("IT",nItem) )
	
	oModelCesta:GoLine(nItem)	

	/*/
		Valida se o item e de um orcamento importado, nao permitindo o seu cancelamento					     
	/*/
	If Empty(oModelCesta:GetValue("L2_NUMORIG")) .OR. oModelCesta:GetValue("L2_VENDIDO") == "N"
		lRet := .T.   
	Else
		lRet := .F.	     
		STFMessage("STCancelItem","STOP",STR0001)	              //"Atencao, Nao e possivel cancelar itens de orcamentos importados"
    EndIf
    
    // Verifica se houve alguma transação tef, impossibilita sua continuação
	If (STWChkTef("CC") .Or. STWChkTef("PD") .Or. STWChkTef("PX")) .And. STIGetCard() .And. STIGetTotal() > 0
		lRet := .F.
		STFMessage("STCancelItem","STOP",STR0010) //"Atenção, não é possível cancelar itens, após pagamento parcial"
	EndIf
    
Else	
	lRet := .F.
	STFMessage("STCancelItem","STOP",STR0002) //"Atencao, Item nao encontrado nas funcoes fiscais"
EndIf

If lRet
	If oModelCesta:IsDeleted()
		lRet := .F.
		STFMessage("STCancelItem","STOP",STR0007) //"Este item já foi cancelado!"
	EndIf
EndIf

STFShowMessage("STCancelItem")	

FwRestRows(aLines)
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCnAllItem
Valida se e possivel cancelar todos ou so o ultimo item

@param   nItem				Numero do item na venda
@param   cItemCode			Codigo do Item
@author  Varejo
@version P11.8
@since   01/06/2012
@return  lRet  - Retorna validacao da funcao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCnAllItem()

Local aLines      := FwSaveRows() 							// Linhas do model
Local nRet        := 0											// Retorno
Local cRetStatus  := "TODOS"									// Retorno evento
Local oModelCesta := STDGPBModel() 							// Model da cesta de vendas

oModelCesta := oModelCesta:GetModel("SL2DETAIL")
	
// Inicia Evento
STFFireEvent(ProcName(0), "GetStatusECF", { "4", @cRetStatus } )
		
// Caso apenas o ultimo item da impressora possa ser cancelado, entra no IF		
If Upper(AllTrim(cRetStatus))<>"TODOS"			
	
	oModelCesta:GoLine(oModelCesta:Length())
	If oModelCesta:IsDeleted()
		nRet := 1
	Else
		nRet := 2
	EndIf
Else
	nRet := 3				  
EndIF	  	 
	
FwRestRows(aLines)
	
Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} STBCnFindItem
Realiza a busca do item que sera cancelado.

@param   cItemCode			Codigo do Item
@param  	oModelCesta 	   Model da cesta de vendas
@param  	nItem       	   numero do item
@param  	nQuantCancel			Quantidade a cancelar
@author  	Varejo
@version P11.8
@since   01/06/2012
@return  lRet  - Retorna validacao da funcao
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBCnFindItem( cGetProd )
Local nRet			:= 0									//Retorno com o numero do item na cesta
Local nX			:= 0									//Variavel para For	
Local nMVljTpCnc	:= SuperGetMV("MV_LJTPCNC",,0)			//Parametro que determina o tipo da busca no cancelamento onde 0 realiza a busca por codigo do produto e 1 por numero do item na cesta
Local cRet			:= ''

cGetProd := AllTrim(cGetProd)


If !Empty(cGetProd)
	
	If nMVljTpCnc == 0 //Priorizo a busca por codigo do produto
		cRet := STBCncPPrd(cGetProd)
		
		If STBIsDigit(cRet)
			nRet := Val(cRet)
		Else
			nRet := STBPegaIT(cRet)
		EndIf

		If nRet == 0
			nRet := STBCncPIt(cGetProd)
		EndIf

	Else //Priorizo a busca por Numero do item na cesta
	
		nRet := STBCncPIt(cGetProd)
		 	
		If nRet == 0
			cRet := STBCncPPrd(cGetProd)

			If STBIsDigit(cRet)
				nRet := Val(cRet)
			Else
				nRet := STBPegaIT(cRet)
			EndIf

		EndIf

	EndIf 

	If nRet == 0
		STFMessage(ProcName(),"STOP",STR0008) //"Produto não encontrado na lista"
		STFShowMessage(ProcName())
	EndIf

EndIf
Return nRet
                                                                                                                                                                     
//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsDigit
Valida se uma cadeia de caracteres tem somente numeros
@param   cStr - Texto a ser avaliado
@author  Varejo
@version P12
@since   21/11/2016
@return  lRet - Retorna se a string eh somete numerica
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBIsDigit(cStr)

Local lRet := .T. 	//Retorna se a string eh somete numerica
Local nY 	:= 0 	//Contador

Default cStr := ""

If Empty(cStr)
	lRet := .F.
Else
	For nY := Len(cStr) To 1 Step -1
		lRet := If( SubStr(cStr,nY,1) $ "0123456789" , lRet , .F. )
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCncPIt
Retorna o numero do item para cancelamento buscando por Item 
@author  Lucas Novais (lnovais)
@version P12.1.17
@since   15/10/2018
@return  lRet - Retorna o numero do item 
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function STBCncPIt(cGetProd)
Local nItem 		:= 0 	//Variavel que rotorna o numero do item na cesta de produtos

If STBIsDigit(cGetProd)
	nItem := Val(cGetProd)
Else
	nItem := STBPegaIT(cGetProd)
EndIf

//Busca o item na MatxFis
If !STBTaxFoun("IT",nItem) 
	nItem := 0
EndIf 

Return nItem

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCncPPrd
Retorna o numero do item para cancelamento buscando por produto 
@author  Lucas Novais (lnovais)
@version P12.1.17
@since   15/10/2018
@return  lRet - Retorna o numero do item
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function STBCncPPrd(cGetProd)
Local oModelCesta   := STDGPBModel()	// Model da cesta
Local aInfoItem 	:= {}				// Retorna as informações sobre os itens
Local nX			:= 0				// Variavel para For
Local cItem			:= ''				// Variavel que retorna o numero do item na cesta de produtos

cGetProd := AllTrim(cGetProd)

oModelCesta := oModelCesta:GetModel("SL2DETAIL")

/*/
	Busca item na base de dados
/*/
aInfoItem	:= STWFindItem( cGetProd )
	
// Encontrou o item?
If aInfoItem[ITEM_ENCONTRADO]
	nX := oModelCesta:Length()
	
	While nX >= 1

		oModelCesta:GoLine(nX)

		If AllTrim(oModelCesta:GetValue("L2_PRODUTO")) == Alltrim(aInfoItem[ITEM_CODIGO]) .AND. !oModelCesta:IsDeleted()
			cItem := oModelCesta:GetValue("L2_ITEM")
			Exit
		EndIf

		nX--
	EndDo

EndIf
 
Return cItem