#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STDKitSales
Gera a lista de códigos de produtos que fazem parte do Produto Kit passado por parametro.
@param	 cCodProdKit	  Codigo do produto que sera analisado para ofertar outros
@author  Varejo
@version P11.8
@since   25/07/2012
@return	 Vetor de codigos de produtos a serem sugeridos
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDKitSales(cCodProdKit)

Local aArea			:= GetArea() 	// Gurada area
Local aRetorno		:= {}			// Retorno da funcao, vetor de codigos de produtos a serem sugeridos
Local nDesconto		:= 0			// Caso o desconto esteja preenchida no cabecalho, esta variavel sera alimentada.

Default cCodProdKit	:= ""

ParamType 0 Var cCodProdKit As Character Default ""  
                    

DbSelectArea("MEU")
MEU->(DbSetOrder(1)) // MEU_FILIAL+MEU_CODIGO 
If MEU->(DbSeek(xFilial("MEU") + PadR(cCodProdKit,TamSX3("MEU_CODIGO")[1])))
	If !Empty(MEU->MEU_DESCNT) // Caso o desconto esteja preenchido no cabecalho, esse desconto sera utilizado.
		nDesconto := MEU->MEU_DESCNT
	EndIf
EndIf

DbSelectArea("MEV")
MEV->(DbSetOrder(1)) // MEV_FILIAL+MEV_CODKIT+MEV_PRODUT 

If MEV->(DbSeek(xFilial("MEV") + PadR(cCodProdKit,TamSX3("MEV_CODKIT")[1])))
	While !MEV->(Eof()) .AND. (AllTrim(MEV->MEV_CODKIT) == AllTrim(cCodProdKit))
		AAdd(aRetorno, {MEV->MEV_PRODUT,IIF(!Empty(nDesconto),nDesconto,MEV->MEV_DESCNT),MEV->MEV_QTD})
		MEV->(DbSkip())
	End Do
EndIf

RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------
/*/{Protheus.doc} STDPrcKit
Rotina para retornar preço do Kit para consulta de produto
@type function
@author Caio Okamoto
@since 22/02/2022
@version P12 
@param	 cCodProdKit, 	caractere	,	Codigo do produto kit
@param	 cCustomer	, 	caractere	,	Codigo do cliente
@param	 cFil		, 	caractere	,	Codigo da Filial
@param	 cStore		, 	caractere	,	Codigo da Loja
@param 	 nQtde		,	numérico	,	Quantidade do Item
@param	 nMoeda		,	numérico	,	Moeda
@return   				numérico	,	Valor do Kit
/*/
//-------------------------------------------------------------
Function STDPrcKit(cCodProdKit, cCustomer, cFil, cStore, nMoeda, nQtde )

Local aItensKit		:= {}		
Local nI			:= 0	
Local nPrecoKit		:= 0
Local nPrecoItem	:= 0

Default cCodProdKit	:= ""
Default cCustomer 	:= "" 
Default cFil	  	:= ""
Default cStore		:= ""
Default nMoeda		:= 0
Default nQtde		:= 1
           
aItensKit := STDKitSales(cCodProdKit)

If Len(aItensKit) > 0

	For nI := 1 To Len(aItensKit)
		nPrecoItem := STWFormPr( aItensKit[nI][1], cCustomer, cFil, cStore,	nMoeda, nQtde )
		nPrecoItem := STBArred((nPrecoItem - (nPrecoItem * aItensKit[nI][2])/100) * aItensKit[nI][3])
		nPrecoKit  += nPrecoItem
	Next nI
	
EndIf

Return nPrecoKit
