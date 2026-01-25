#INCLUDE "PROTHEUS.CH"  
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STBFINSERVICE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsBulkServ
Verifica se o produto serviço é avulso..

@param   cProductCode				Codigo do Produto
@author  Varejo
@version P11.8
@since   11/06/2014
@return  lRet						Retorno da validação
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIsBulkServ( cProductCode )

Local 			lRet	 			:= .F.						// Retorna Serviço Avulso?
Local 			aProductCode		:= {}						// Array do Produto de Serviço

Default		cProductCode		:= ""						// Codigo do Produto

ParamType 0 Var cProductCode AS Character	Default ""

aProductCode := STDProdServ(cProductCode)								

If !EMPTY(aProductCode)
	lRet := aProductCode[05] == "2" //Produto não Vinculado (Avulso)
EndIf
			
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsPriceRange
Verifica se o produto serviço é precificado por faixa de preço

@param   cProductCode				Codigo do Produto
@author  Varejo
@version P11.8
@since   11/06/2014
@return  lRet						Retorno da validação
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIsPriceRange( cProductCode )

Local 			lRet	 			:= .F.						// Retorna Serviço Avulso?
Local 			aProductCode		:= {}						// Array do Produto de Serviço

Default		cProductCode		:= ""						// Codigo do Produto

ParamType 0 Var cProductCode AS Character	Default ""

aProductCode := STDProdServ(cProductCode)								

If !EMPTY(aProductCode)
	lRet := aProductCode[04] == "1" //Tipo de Precificação	1=Faixa de Preco;2=Fixo
EndIf
			
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBIsFinService
Verifica se o produto é do tipo serviço financeiro

@param   cProductCode				Codigo do Produto
@author  Varejo
@version P11.8
@since   11/06/2014
@return  lRet						Retorno da validação
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBIsFinService( cProductCode )

Local 			lRet	 			:= .F.									// Retorna se é serviço financeiro
Local 			aProduct			:= {}									// Array do Produto
Local 			cServType	   		:= SuperGetMv("MV_LJTPSF",,"SF")	// Define o tipo do produto de servico financeiro

Default		cProductCode		:= ""						// Codigo do Produto

ParamType 0 Var cProductCode AS Character	Default ""

aProduct	:= STDFindItem( cProductCode )

If !EMPTY(aProduct)
	lRet := aProduct[ITEM_TIPO] == cServType 
EndIf
			
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Adm_Item_FinService
Classe para Armazenamento de Informacoes de Itens Servicos Financeiros

@param   
@author  Varejo
@version P11.8
@since   01/07/2014
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
CLASS Adm_Item_FinService
/*
	Declaracao das propriedades da Classe
*/
DATA aRecords As Array //Propriedade para armazenamento das informacoes

/*
	Declaracao dos Metodos da Classe
*/
METHOD New() CONSTRUCTOR 				//Metodo Construtor
METHOD SetServFin(nItemLine, cCodItem) //Metodo para inserir informacoes no objeto
METHOD GetServFin(nItemServFin)			//Metodo para pegar informacoes no objeto
METHOD ClearServFin()					//Metodo para limpar informacoes no objeto
METHOD DelServFin()						//Metodo para marcar item como deletado no objeto
METHOD SelServFin()						//Metodo para marcar item como selecionado no objeto

ENDCLASS

/*
	Criacao do construtor para atribuir os valores default 
	para as propriedades e retorna Self
*/
METHOD New() CLASS Adm_Item_FinService

Self:aRecords := {} //Inicializa propriedade com tipo array

Return Self

/*
	Metodo para adicionar informacoes no objeto  	
*/
METHOD SetServFin(cCodServProd, nPriceServFin, cCodItem, nItemLine, cTypeItem) CLASS Adm_Item_FinService   

Local lHabilita := .F.

Default		cCodServProd		:= ""	//Codigo do Produto Servico Financeiro
Default		nPriceServFin		:= 0	//Valor do Produto Servico Financeiro
Default		cCodItem			:= ""	//Codigo do Produto Vendido
Default		nItemLine			:= 0	//Numero de Item do Produto Vendido 
Default		cTypeItem			:= ""	//Tipo do Item - Utilizado para importacao de Orcamento

ParamType 0 Var cCodServProd 	AS Character	Default ""
ParamType 1 Var nPriceServFin 	AS Numeric		Default 0
ParamType 2 Var cCodItem 		AS Character	Default ""
ParamType 3 Var nItemLine 		AS Numeric		Default 0
ParamType 4 Var cTypeItem 		AS Character	Default ""

//Tratamento para importacao Servico Financeiro
If cTypeItem == "IMP"
	lHabilita := .T.
Else
	lHabilita := STBIsBulkServ(cCodServProd)
EndIf

//Verifica se pproduto Servico Financeiro
If STBIsFinService( cCodServProd )
	//Verifica se produto ja existe no objeto
	If aScan(Self:aRecords,{|xVar| xVar[1] == cCodServProd .AND. xVar[3] == nPriceServFin .AND. xVar[4] == cCodItem .AND.;
		xVar[6] == nItemLine .AND. xVar[7] == cTypeItem}) == 0
		
		//Adiciona item no objeto
		aAdd(Self:aRecords, ARRAY(9)) 
		Self:aRecords[Len(Self:aRecords), 1] 	:= cCodServProd 				//Codigo do Produto Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 2] 	:= STDDescProd(cCodServProd)	//Descricao do Produto Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 3] 	:= nPriceServFin 				//Valor do Servico Financeiro
		Self:aRecords[Len(Self:aRecords), 4] 	:= cCodItem 					//Codigo do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 5] 	:= STDDescProd(cCodItem)		//Descricao do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 6]	:= nItemLine 					//Numero do Item do Produto Vendido
		Self:aRecords[Len(Self:aRecords), 7] 	:= cTypeItem 					//Tipo do Item - Utilizado na importacao de orcamento 
		Self:aRecords[Len(Self:aRecords), 8] 	:= .F. 							//Define se item esta deletado
		Self:aRecords[Len(Self:aRecords), 9] 	:= lHabilita					//Define se item selecionado para finalizacao de venda
	EndIf
EndIf

Return Nil

/*
	Metodo para pegar informacoes do objeto
	Retorna posicao do array de acordo com o Item vendido (nItemLine)  	
*/
METHOD GetServFin(nItemLine) CLASS Adm_Item_FinService

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
METHOD ClearServFin() CLASS Adm_Item_FinService

Self:aRecords := {} //Limpa propriedade com tipo array

Return Nil

/*
	Metodo para marcar item como deletado no objeto	  	
*/
METHOD DelServFin(cCodServProd, cCodItem, nItemLine) CLASS Adm_Item_FinService

Local nI := 0 //Contador

Default		cCodServProd	:= ""	//Codigo do Produto Servico Financeiro
Default		cCodItem		:= ""	//Codigo do Produto Vendido
Default		nItemLine		:= 0	//Numero de Item do Produto Vendido

ParamType 0 Var cCodServProd 	AS Character	Default ""
ParamType 1 Var cCodItem 		AS Character	Default ""
ParamType 2 Var nItemLine 		AS Numeric 		Default 0

/* Busca itens de servico conforme parametro */
For nI := 1 To Len(Self:aRecords)
	/* Se item Servico Financeiro avulso, deleta o mesmo */	
	If STBIsFinService( cCodServProd )
		If AllTrim(Self:aRecords[nI, 1]) == AllTrim(cCodServProd) 
			Self:aRecords[nI, 8] := .T.
		EndIf
	Else
		/* Senao deleta os Servicos Financeiros vinculados */
		If AllTrim(Self:aRecords[nI, 4]) == AllTrim(cCodItem) .AND. Self:aRecords[nI, 6] == nItemLine  
			Self:aRecords[nI, 8] := .T.
		EndIf
	EndIf 
Next nI

Return Nil

/*
	Metodo para marcar selecao de item	  	
*/
METHOD SelServFin(cCodServProd, cCodItem, nItemLine, nValServ) CLASS Adm_Item_FinService

Local nI := 0 //Contador

Default		cCodServProd	:= ""	//Codigo do Produto Servico Financeiro
Default		cCodItem		:= ""	//Codigo do Produto Vendido
Default		nItemLine		:= 0	//Numero de Item do Produto Vendido

ParamType 0 Var cCodServProd 	AS Character	Default ""
ParamType 1 Var cCodItem 		AS Character	Default ""
ParamType 2 Var nItemLine 		AS Numeric 		Default 0

/* Busca itens de servico conforme parametro */
For nI := 1 To Len(Self:aRecords)
	/* Seleciona Servicos Financeiros vinculados */
	If AllTrim(Self:aRecords[nI, 1]) == AllTrim(cCodServProd) .AND. AllTrim(Self:aRecords[nI, 4]) == AllTrim(cCodItem) .AND.; 
		Self:aRecords[nI, 6] == nItemLine .AND. Self:aRecords[nI, 3] == nValServ  
		
		Self:aRecords[nI, 9] := .T.
	EndIf	 
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBVldClient
Verifica se o cliente da venda possui criticas cadastrais

@param   aFinItens		Array com as informacoes de Servico Financeiro
@param   aCriticCli		Array que contera as criticas
@author  Varejo
@version P11.8
@since   14/07/2014
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBVldClient( aFinItens, aCriticCli )

Default aFinItens := {}
Default aCriticCli := {}

ParamType 0 Var aFinItens 	As Array Default {}
ParamType 1 Var aCriticCli 	As Array Default {}

/* Efetua validacao do cliente */
aCriticCli := aClone(STDVldClient(aFinItens))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBPermUser
Verifica se usuario tem permissao para vender Servicos Financeiros

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	15/07/2014
@return  	lRet	Usuario possui permissao para verder Servico Finaneiro
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPermUser()

Local lRet := STFProFile(38)[1] //Retorno de permissao do usuario para Servico Financeiro 

/* Se usuario sem permissao exibe mensagem */
If !lRet
	If lUsaDisplay                    
		// Inicia Evento
		STFFireEvent(ProcName(0), "STDisplay", {StatDisplay(), "2C" + STR0001}) //"Senha invalida ou acesso negado" 
	EndIf
	
	STFMessage(ProcName(),"STOP",STR0002 + cUserName + STR0003) //#"Atenção, " ##" sem permissão para vender Serviços Financeiros com crítica de cliente" 
	STFShowMessage(ProcName())
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDelServFin
Deleta servico financeiro avulo ou atrelado do objeto 

@param 		cProdCode	Codigo do produto deletado
@param 		nItem		Item do produto deletado  
@param 		lServFin	Servico Financeiro avulso	
@author  	Vendas & CRM
@version 	P12
@since   	22/07/2014
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDelServFin(cProdCode, nItem, lServFin)

Default	 cProdCode	:= ""	//Codigo do Produto Vendido
Default	 nItem		:= 0	//Numero de Item do Produto Vendido
Default	 lServFin	:= .F.	//Flag Servico Financeiro avulso

ParamType 0 Var cProdCode 	AS Character	Default ""
ParamType 1 Var nItem 		AS Numeric 		Default 0
ParamType 2 Var lServFin 	AS Logical 		Default .F.

/* Se produto Servico Financeiro deleta o mesmo 
   Senao envia produto e item para delecao de servicos financeiros atrelados */    		  		
STWItemFin(	4 							,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear - 4=Del) 
			IIF(lServFin, cProdCode, ""),;	//Codigo Servico Financeiro			
			0							,; 	//Valor do Servico Financeiro					
			IIF(lServFin, "", cProdCode),;	//Codigo Produto Vendido			
			IIF(lServFin, 0, nItem) 	,; 	//Item Produto Vendido
			""							)	//Tipo Item - Usado para importacao de Orcamento

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} STBSubNotFiscal
Adiciona valor no totalizador não fiscal

@param   nValue				Valor
@author  Varejo
@version P11.8
@since   23/07/2014
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBSubNotFiscal( nValue )

Local oTotal := STFGetTot()		// Totalizador

Default nValue  	:= 0	

ParamType 0 Var  nValue As Numeric	 Default 0

oTotal:SetValue( "L1_NOTFISCAL" , oTotal:GetValue("L1_NOTFISCAL") - nValue )

Return Nil 

//-------------------------------------------------------------------
/* {Protheus.doc} STBVldQtdProd
Valida quantidade do produto de cobertura no vinculo de Servico Financeiro

@param   nItemProd			Item do produto de cobertura
@author  Varejo
@version P11.8
@since   24/07/2014
@return  lRet				Permite continuar o vinculo
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBVldQtdProd(nItemProd)

Local lRet 			:= .T.				//Retorno da funcao
Local aLines      	:= FwSaveRows()		//Array de linhas
Local oModelCesta	:= STDGPBModel()	//Model da cesta

/* Carrega Modelo Detalhes */
oModelCesta := oModelCesta:GetModel("SL2DETAIL")

/* Posiciona na linha do produto cobertura*/
oModelCesta:GoLine(nItemProd)

/* Verifica quantidade do produto cobertura */
If oModelCesta:GetValue("L2_QUANT") > 1
	lRet := .F.
	
	STFMessage(ProcName(),"STOP", STR0005) //#"Quantidade do Produto de cobertura maior que 1, não permitido vincular" 
	STFShowMessage(ProcName())
EndIf

FwRestRows(aLines)

Return lRet
