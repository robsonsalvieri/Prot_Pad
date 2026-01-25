#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STBFINSERVICE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsGarEst
Verifica se o produto é do tipo Garantia Estendida

@param   cProductCode				Codigo do Produto
@author  Varejo
@version P11.8
@since   20/12/2016
@return  lRet						Retorno da validação
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIsGarEst( cProductCode )

Local 			lRet	 			:= .F.									// Retorna se é Garantia Estendida
Local 			aProduct			:= {}									// Array do Produto
Local 			cGarEstType  		:= SuperGetMv("MV_LJTPGAR",,"GE")	// Define o tipo do produto de Garantia Estendida

Default		cProductCode		:= ""						// Codigo do Produto

If ExistFunc("STDFindItem")
	aProduct	:= STDFindItem( cProductCode )
Else
	aProduct	:= {}
EndIf

If !EMPTY(aProduct)
	lRet := aProduct[ITEM_TIPO] == cGarEstType 
EndIf
			
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Adm_Item_ExtWarranty
Classe para Armazenamento de Informacoes de Itens Garantia Estendida

@param   
@author  Varejo
@version P11.8
@since   20/12/2016
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
CLASS Adm_Item_ExtWarranty
/*
	Declaracao das propriedades da Classe
*/
DATA aRecords As Array //Propriedade para armazenamento das informacoes

/*
	Declaracao dos Metodos da Classe
*/
METHOD New() CONSTRUCTOR 				//Metodo Construtor
METHOD SetGarEst(nItemLine, cCodItem) //Metodo para inserir informacoes no objeto
METHOD GetGarEst(nItemServFin)			//Metodo para pegar informacoes no objeto
METHOD ClearGarEst()						//Metodo para limpar informacoes no objeto
METHOD DelGarEst()						//Metodo para marcar item como deletado no objeto
METHOD SelGarEst()						//Metodo para marcar item como selecionado no objeto

ENDCLASS

/*
	Criacao do construtor para atribuir os valores default 
	para as propriedades e retorna Self
*/
METHOD New() CLASS Adm_Item_ExtWarranty

Self:aRecords := {} //Inicializa propriedade com tipo array

Return Self

/*
	Metodo para adicionar informacoes no objeto  	
*/
METHOD SetGarEst(cCodGarEst, nPriceGarEst, cCodItem, nItemLine,;
							 cTypeItem, nPriceItem, cSerieItem) CLASS Adm_Item_ExtWarranty   

Local lHabilita := .F.

Default		cCodGarEst			:= ""	//Codigo do Produto Servico Financeiro
Default		nPriceGarEst		:= 0	//Valor do Produto Servico Financeiro
Default		cCodItem			:= ""	//Codigo do Produto Vendido
Default		nItemLine			:= 0	//Numero de Item do Produto Vendido 
Default		cTypeItem			:= ""	//Tipo do Item - Utilizado para importacao de Orcamento
Default		nPriceItem			:= 0	//Valor total do produto vinculado à Garantia Estendida
Default		cSerieItem			:= 0	//Série do produto vinculado à Garantia Estendida

//Tratamento para importacao Garantia Estendida 
If cTypeItem == "IMP"
	lHabilita := .T.
EndIf

//Verifica se produto é uma Garantia
If ExistFunc("STDDescProd") .AND. STBIsGarEst( cCodGarEst )
	//Verifica se produto ja existe no objeto
	If aScan(Self:aRecords,{|xVar| xVar[1] == cCodGarEst .AND. xVar[3] == nPriceGarEst .AND. xVar[4] == cCodItem .AND.;
		xVar[6] == nItemLine .AND. xVar[7] == cTypeItem}) == 0
		
		//Adiciona item no objeto
		aAdd(Self:aRecords, ARRAY(11)) 
		Self:aRecords[Len(Self:aRecords), 1] 	:= cCodGarEst 				//Codigo do Produto Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 2] 	:= STDDescProd(cCodGarEst)	//Descricao do Produto Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 3] 	:= nPriceGarEst 				//Valor do Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 4] 	:= cCodItem 					//Codigo do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 5] 	:= STDDescProd(cCodItem)		//Descricao do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 6]	:= nItemLine 					//Numero do Item do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 7] 	:= cTypeItem 					//Tipo do Item - Utilizado na importacao de orcamento 
		Self:aRecords[Len(Self:aRecords), 8] 	:= .F. 							//Define se item esta deletado
		Self:aRecords[Len(Self:aRecords), 9] 	:= lHabilita					//Define se item selecionado para finalizacao de venda
		Self:aRecords[Len(Self:aRecords),10] 	:= nPriceItem 				//Valor Total do Produto vinculado à Garantia Estendida
		Self:aRecords[Len(Self:aRecords),11] 	:= cSerieItem 				//Série do Produto vinculado à Garantia Estendida
	EndIf
EndIf

Return Nil

/*
	Metodo para pegar informacoes do objeto
	Retorna posicao do array de acordo com o Item vendido (nItemLine)  	
*/
METHOD GetGarEst(nItemLine) CLASS Adm_Item_ExtWarranty

Local aRet := {}
Local nI	:= 0

Default		nItemLine	:= 0	//Numero de Item do Produto Vendido

ParamType 0 Var nItemLine AS Numeric Default 0

//Busca itens de servico conforme parametro
For nI := 1 To Len(Self:aRecords) 
	
	If nItemLine == 0 .OR. Self:aRecords[nI, 6] == nItemLine
		aAdd( aRet, aClone(Self:aRecords[nI]) ) 
	EndIf
	
Next nI

Return aRet

/*
	Metodo para limpar informacoes do objeto
	Retorna NIL
*/
METHOD ClearGarEst() CLASS Adm_Item_ExtWarranty

Self:aRecords := {} //Limpa propriedade com tipo array

Return Nil

/*
	Metodo para marcar item como deletado no objeto	  	
*/
METHOD DelGarEst(cCodGarEst, cCodItem, nItemLine) CLASS Adm_Item_ExtWarranty

Local nI := 0 //Contador

Default		cCodGarEst		:= ""	//Codigo do Produto Garantia Estendida
Default		cCodItem		:= ""	//Codigo do Produto Vendido
Default		nItemLine		:= 0	//Numero de Item do Produto Vendido

/* Busca itens de GE conforme parametro */
For nI := 1 To Len(Self:aRecords)
	/* Se item Garantia Estendida avulso, deleta o mesmo */	
	If STBIsGarEst( cCodGarEst )
		If AllTrim(Self:aRecords[nI, 1]) == AllTrim(cCodGarEst) 
			Self:aRecords[nI, 8] := .T.
		EndIf
	Else
		/* Senao deleta as Garantias Estendidas vinculadas */
		If AllTrim(Self:aRecords[nI, 4]) == AllTrim(cCodItem) .AND. Self:aRecords[nI, 6] == nItemLine  
			Self:aRecords[nI, 8] := .T.
		EndIf
	EndIf 
Next nI

Return Nil

/*
	Metodo para marcar selecao de item	  	
*/
METHOD SelGarEst(cCodGarEst, cCodItem, nItemLine, nValServ) CLASS Adm_Item_ExtWarranty

Local nI := 0 //Contador

Default		cCodGarEst		:= ""	//Codigo do Produto Garantia Estendida
Default		cCodItem		:= ""	//Codigo do Produto Vendido
Default		nItemLine		:= 0	//Numero de Item do Produto Vendido

/* Busca itens de servico conforme parametro */
For nI := 1 To Len(Self:aRecords)
	/* Seleciona Garantia Estendida vinculada */
	If AllTrim(Self:aRecords[nI, 1]) == AllTrim(cCodGarEst) .AND. AllTrim(Self:aRecords[nI, 4]) == AllTrim(cCodItem) .AND.; 
		Self:aRecords[nI, 6] == nItemLine .AND. Self:aRecords[nI, 3] == nValServ  
		
		Self:aRecords[nI, 9] := .T.
	EndIf	 
Next nI

Return Nil


