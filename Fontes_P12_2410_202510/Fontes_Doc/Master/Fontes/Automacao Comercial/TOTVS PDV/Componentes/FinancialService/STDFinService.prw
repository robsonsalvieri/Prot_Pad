#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STDFINSERVICE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDProdServ
Retorna array do produto serviço.

@param   cProductCode				Codigo do Produto
@param   cServiceCode				Codigo do Serviço
@author  Varejo
@version P11.8
@since   11/06/2014
@return  aRet						Retorno do produto serviço
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDProdServ( cProductCode, cServiceCode )

Local			aArea				:= GetArea() 				// Guarda area atual
Local 			aRet	 			:= {}						// Retorno do Serviço
Local 			lSeek				:= .F.						// Encontrou o Serviço?

Default		cProductCode		:= ""						// Codigo do Produto
Default		cServiceCode		:= ""						// Codigo do Serviço

ParamType 0 Var cProductCode AS Character	Default ""
ParamType 1 Var cServiceCode AS Character	Default ""

If !EMPTY(cProductCode)

	DbSelectArea("MG8")
	DbSetOrder(2) //MG8_FILIAL+MG8_PRDSB1
	lSeek := DbSeek ( xFilial("MG8") + cProductCode )		

ElseIf !EMPTY(cServiceCode)	 

	DbSelectArea("MG8")
	DbSetOrder(1) //MG8_FILIAL+MG8_CODIGO
	lSeek := DbSeek ( xFilial("MG8") + cServiceCode )
	
EndIf

If lSeek
		
	Aadd( aRet , MG8->MG8_CODIGO			) // [01]Cod. Servico
	Aadd( aRet , MG8->MG8_DESCRI			) // [02]Descricao 
	Aadd( aRet , MG8->MG8_PRDSB1			) // [03]Prd.Serv. na venda
	Aadd( aRet , MG8->MG8_TPPREC			) // [04]Tipo de Precificação	1=Faixa de Preco;2=Fixo
	Aadd( aRet , MG8->MG8_TPXPRD			) // [05]Vinculado 				1=Sim;2=Nao
	Aadd( aRet , MG8->MG8_REGRA 			) // [06]Regra Cliente
	
EndIf

//Restaura area anterior	
RestArea(aArea)								
			
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDServPrice
Retorna o valor do serviço baseado por Faixa de Preço

@param   cProdSerCode				Codigo do Produto Servico
@param   cProdSalCode				Codigo do Produto Vendido
@param   cGroupCode					Codigo do Grupo do Produto Vendido
@param   nProdPrice					Preco do Produto Vendido
@author  Varejo
@version P11.8
@since   11/06/2014
@return  nRet						Retorno do preço do produto servico
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDServPrice( cProdSerCode, cProdSalCode, cGroupCode, nProdPrice )

Local		aArea				:= GetArea() 				//Guarda area atual
Local		aAreaMBF			:= MBF->(GetArea()) 		//Guarda area MBF atual
Local		aAreaMBL			:= MBL->(GetArea()) 		//Guarda area MBL atual
Local 		nRet	 			:= 0						//Retorno do preço do produto serviço
Local 		lAchou				:= .F.						//Flag se encontrou Faixa de Preco

Default		cProdSerCode		:= ""						//Codigo do Produto Servico
Default		cProdSalCode		:= ""						//Codigo do Produto Vendido
Default		cGroupCode			:= ""						//Codigo do Grupo do Produto da Venda
Default		nProdPrice			:= 0						//Preco do Produto da Venda

ParamType 0 Var cProdSerCode	AS Character	Default ""
ParamType 1 Var cProdSalCode  	AS Character	Default ""
ParamType 2 Var cGroupCode   	AS Character	Default ""
ParamType 3 Var nProdPrice   	AS Numeric 		Default 0        

If !EMPTY(cProdSerCode)
	//1 - Busca Faixa de Preco do Servico Financeiro pelo codigo do servico
	MBF->(dbSetOrder(1)) //MBF_FILIAL + MBF_PRDGAR + MBF_PRODPR + MBF_GRUPO
	
	If MBF->(dbSeek(xFilial("MBF") + cProdSerCode + cProdSalCode));
		.AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM)
		
		lAchou := .T.
	Else //2 - Busca Faixa de Preco do Servico Financeiro pelo grupo
		MBF->(dbSetOrder(5)) //MBF_FILIAL + MBF_GRUPO + MBF_PRODPR
						
		If MBF->(dbSeek(xFilial("MBF") + cGroupCode))
			While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_GRUPO) == xFilial("MBF") + cGroupCode  
				If MBF->MBF_PRDGAR == cProdSerCode .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM )				
					lAchou := .T.
					Exit
				EndIf
				
				MBF->(dbSkip())
			EndDo
		EndIf	 			 		   		          
	EndIf
	
	//Se encontrou Faixa de Preco, busca valor nos itens (MBF)
	If lAchou
		MBL->(dbSetOrder(1)) //MBL_FILIAL + MBL_CODIGO + MBL_ITEM   
		
		If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
			While MBL->(!EOF()) .AND. (MBL->MBL_FILIAL = xFilial("MBL")) .AND. (MBF->MBF_CODIGO == MBL->MBL_CODIGO)									
				
				//Armazena Valor do Servico Financeiro
				If nProdPrice >= MBL->MBL_VLINI .AND. nProdPrice <= MBL->MBL_VLFIM 
					nRet := MBL->MBL_VALOR
				EndIf
				
				MBL->(dbSkip())
			EndDo
		EndIf													
	EndIf
EndIf

//Restaura areas
RestArea(aAreaMBF)
RestArea(aAreaMBL) 
RestArea(aArea)								
			
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDProdInfo
Retorna o Preco/Grupo/Preco do Produto da Venda

@param   cProdCode					Codigo do Produto da Venda
@param   cGroupCode					Codigo do Grupo do Produto da Vena
@param   nProdPrice					Preco do Produto da Venda
@author  Varejo
@version P11.8
@since   27/06/2014
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDProdInfo( cProdCode, cGroupCode, nProdPrice )

Local aArea			:= GetArea() 				//Guarda area atual
Local aAreaSB1 		:= SB1->(GetArea())		//Guarda area atual
Local aLines      	:= FwSaveRows()			//Array de linhas
Local oModelCesta		:= STDGPBModel()			//Model da cesta

Default		cProdCode		:= ""				//Codigo do Produto da Venda
Default		cGroupCode		:= ""				//Codigo do Grupo do Produto da Venda
Default		nProdPrice		:= 0				//Preco do Produto da Venda

ParamType 0 Var cProdCode	AS Character	Default ""
ParamType 1 Var cGroupCode	AS Character	Default ""
ParamType 2 Var nProdPrice	AS Numeric 		Default 0        

//Carrega Modelo Detalhes
oModelCesta := oModelCesta:GetModel("SL2DETAIL")

//Armazena informacoes
cProdCode 	:= oModelCesta:GetValue("L2_PRODUTO") 							//Codigo	 
cGroupCode	:= Posicione("SB1", 1, xFilial("SB1" + cProdCode), "B1_GRUPO") //Grupo
nProdPrice 	:= STWFormPr(cProdCode) 										//Preco
 
//Restaura areas
FwRestRows(aLines)
RestArea(aAreaSB1)
RestArea(aArea)	

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDServItens
Busca todos os servicos Vinculados ao produto e armazena no objeto

@param   cCodItem				Codigo do Produto Vendido
@param   nItemLine				Item do Produto Vendido
@param   cTypeItem				Tipo do Item - Importacao de Orcamentos
@author  Varejo
@version P11.8
@since   02/07/2014
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDServItens( cCodItem, nItemLine, cTypeItem )

Local aArea			:= GetArea() 				//Guarda area atual
Local aAreaSB1	:= SB1->(GetArea())		//Guarda area SB1
Local cGroupCode 	:= ""
Local nProdPrice	:= 0

Default	 cCodItem 	:= ""	 //Codigo do Produto da Venda
Default	 nItemLine 	:= 0	 //Item do Produto da Venda
Default	 cTypeItem 	:= ""	 //Tipo do Item - Importacao de Orcamentos

ParamType 0 Var cCodItem	AS Character	Default ""
ParamType 1 Var nItemLine	AS Numeric		Default 0
ParamType 2 Var cTypeItem	AS Character	Default ""

If cTypeItem <> "IMP"		//Se veio da importação, não insiro todos os serviços financeiros escolhido pelo cliente.
	/*
		Busca Grupo do Produto da Venda
	*/	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))	//B1_FILIAL+B1_COD
	DbSeek( xFilial("SB1") + cCodItem )
	cGroupCode := SB1->B1_GRUPO //Grupo

	/*
		Busca Preco do Produto da Venda
	*/	
	nProdPrice := STWFormPr( cCodItem )	

	//Valida se produto permite Servicos Financeiros Vinculados
	If !EMPTY(cCodItem) .And. Posicione("SB0", 1, xFilial("SB0") + Padr(cCodItem, TamSx3("B0_COD")[1]), "SB0->B0_SERVFIN") == "1"	
		/*
			Busca Faixa de Preco do Servico Financeiro pelo codigo do produto
		*/
		MBF->(dbSetOrder(4)) //MBF_FILIAL + MBF_PRODPR + MBF_GRUPO
		MBL->(dbSetOrder(1)) //MBL_FILIAL + MBL_CODIGO + MBL_ITEM
	
		If MBF->(dbSeek(xFilial("MBF") + cCodItem)) ;
			.AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM);
			.AND. STBIsFinService(MBF->MBF_PRDGAR) 
			
			While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_PRODPR) == xFilial("MBF") + cCodItem ;
				.AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM)		   	
			
				If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
					While MBL->(!EOF()) .AND. (MBL->MBL_FILIAL = xFilial("MBL")) .AND. (MBF->MBF_CODIGO == MBL->MBL_CODIGO)									
						If (MBL->MBL_FILIAL = xFilial("MBL")) .AND. (MBF->MBF_CODIGO == MBL->MBL_CODIGO);
							.AND. nProdPrice >= MBL->MBL_VLINI .AND. nProdPrice <= MBL->MBL_VLFIM 
							/*
								Armazena Itens Servico Financeiro					
							*/
							STWItemFin(	1				,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear)
						 				MBF->MBF_PRDGAR	,;	//Codigo Servico Financeiro			
						 				MBL->MBL_VALOR	,;	//Valor do Servico Financeiro					
						 				cCodItem		,;	//Codigo Produto Vendido			
						 				nItemLine		,;	//Item Produto Vendido
						 				cTypeItem		) 	//Tipo Item - Usado para importacao de Orcamento
						EndIf
					
						MBL->(dbSkip())
					EndDo				
				EndIf
			
				MBF->(dbSkip())
			EndDo	
		EndIf
	
		/*
			Busca Faixa de Preco do Servico Financeiro pelo grupo
		*/
		MBF->(dbSetOrder(5)) //MBF_FILIAL + MBF_GRUPO + MBF_PRODPR	
	
		If !Empty(cGroupCode) .AND. MBF->(dbSeek(xFilial("MBF") + cGroupCode)) ;
			.AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM);
			.AND. STBIsFinService(MBF->MBF_PRDGAR)
		
			While MBF->(!EOF()) .AND. MBF->(MBF_FILIAL + MBF_GRUPO) == xFilial("MBF") + cGroupCode ;
				.AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM)			   	
				If MBL->(dbSeek(xFilial("MBL") + MBF->MBF_CODIGO))
					While MBL->(!EOF()) .AND. (MBL->MBL_FILIAL = xFilial("MBL")) .AND. (MBF->MBF_CODIGO == MBL->MBL_CODIGO)									
						If (MBL->MBL_FILIAL = xFilial("MBL")) .AND. (MBF->MBF_CODIGO == MBL->MBL_CODIGO);
						.AND. nProdPrice >= MBL->MBL_VLINI .AND. nProdPrice <= MBL->MBL_VLFIM 
							/*
								Armazena Itens Servico Financeiro					
							*/
							STWItemFin(1					,;	//Tipo do Processo (1=Set - 2=Get - 3=Clear) 
										MBF->MBF_PRDGAR		,;	//Codigo Servico Financeiro			
										MBL->MBL_VALOR		,;	//Valor do Servico Financeiro					
										cCodItem			,;	//Codigo Produto Vendido			
										nItemLine			,; 	//Item Produto Vendido	
										cTypeItem			) 	//Tipo Item - Usado para importacao de Orcamento
						EndIf
					
						MBL->(dbSkip())
					EndDo				
				EndIf
			
				MBF->(dbSkip())
			EndDo								 			 		   		          
		EndIf

	EndIf

	//Restaura areas
	RestArea(aAreaSB1)
	RestArea(aArea)
	
EndIf
			
Return Nil			

//-------------------------------------------------------------------
/*/{Protheus.doc} STDDescProd
Retorna a Descricao do Produto

@param   cCodProd				Codigo do Produto
@author  Varejo
@version P11.8
@since   02/07/2014
@return  cDescProd				Descricao do Produto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDescProd(cCodProd)

Local aArea	 		:= GetArea() 	//Guarda area atual
Local cDescProd 	:= ""			//Descricao do produto 

Default	 cCodProd 	:= ""	 

ParamType 0 Var cCodProd	AS Character	Default ""

SB1->(dbSetOrder(1))

/*
	Descricao do Produto
*/
If !Empty(cCodProd) .AND. SB1->(dbSeek(xFilial("SB1") + cCodProd))
	cDescProd := AllTrim(SB1->B1_DESC) 
EndIf

/*
	Restaura areas
*/
RestArea(aArea)

Return cDescProd

//-------------------------------------------------------------------
/*/{Protheus.doc} STDVldClient
Function para Buscar as criticas cadastrais do Cliente quando Item Servico Financeiro

@param   aFinItens		Array com as informacoes de Servico Financeiro   
@author  Varejo
@version P11.8
@since   14/07/2014
@return  aRet				Array  com as criticas cadastrais do cliente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDVldClient(aFinItens)

Local aArea			:= GetArea() 						//Guarda area atual
Local aAreaSA1		:= SA1->(GetArea())					//Guarda area SA1
Local aAreaMG7		:= MG7->(GetArea())					//Guarda area MG7
Local aAreaMG8		:= MG8->(GetArea())					//Guarda area MG8
Local cMsgCritic	:= ""								//Mensagem de critica
Local aRet 			:= {} 								//Array com Retorno das criticas cadastrais do cliente
Local nI 			:= 0								//Contador
Local xRet			:= Nil 								//Retorno da Formula
Local cCustomer 	:= STDGPBasket("SL1", "L1_CLIENTE")	//Codigo do Cliente
Local cStore	 	:= STDGPBasket("SL1", "L1_LOJA")	//Loja do Cliente

Default	 aFinItens 	:= {}	 

ParamType 0 Var aFinItens	AS Array	Default {}

SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
MG7->(dbSetOrder(1)) //MG7_FILIAL + MG7_CODIGO + MG7_ITEM
MG8->(dbSetOrder(2)) //MG8_FILIAL + MG8_PRDSB1

/* Valida se os campos do cadastro de cliente estao preenchidos */
If SA1->(dbSeek(xFilial("SA1") + cCustomer + cStore))  	
	For nI := 1 to Len(aFinItens)
		/* Valida se item nao esta deletado e se existe regra de cliente */
		If !aFinItens[nI][8] .AND. MG8->(dbSeek(xFilial("MG8") + aFinItens[nI][1])) .AND. MG7->(dbSeek(xFilial("MG7") + MG8->MG8_REGRA))
			While MG7->(!EOF()) .AND. MG7->MG7_CODIGO == MG8->MG8_REGRA 
				/* Valida Campos Obrigatorios */
				If !Empty(MG7->MG7_CAMPO) 
					If Empty(&("SA1->" + MG7->MG7_CAMPO))
						/* Adiciona criticas de campos no array */
						If Empty(MG7->MG7_MSGPD)
							SX3->(DbSetOrder(2))
							SX3->(DbSeek(MG7->MG7_CAMPO))
							
							/* Armazena mensagem de critica */
							cMsgCritic := STR0001 + Alltrim(X3Titulo()) + " (" + Alltrim(MG7->MG7_CAMPO) + ") " +  STR0002 //#"O campo " ##"não esta preenchido." 
							
							/* Adiciona mensagem no Array se nao for repetida */
							If aScan(aRet,{|x| x == cMsgCritic}) == 0
								aAdd(aRet, cMsgCritic)
							EndIf									
						Else
							/* Armazena mensagem de critica */
							cMsgCritic := Alltrim(MG7->MG7_MSGPD)
							
							/* Adiciona mensagem no Array se nao for repetida */
							If aScan(aRet,{|x| x == cMsgCritic}) == 0
								aAdd(aRet, cMsgCritic)	
							EndIf																																
						EndIf												
					EndIf
				EndIf
				
				/* Valida Formulas */
				If !Empty(MG7->MG7_FORMUL)				
					xRet:= &(Alltrim(MG7->MG7_FORMUL))
					
					/* Valida se Formula eh valida */
					If ValType(xRet) <> "L"
						If Empty(MG7->MG7_MSGPD)
							/* Armazena mensagem de critica */
							cMsgCritic := STR0003 //"Erro ao executar a fórmula - Retorno deve ser Lógico."
							
							/* Adiciona mensagem no Array se nao for repetida */
							If aScan(aRet,{|x| x == cMsgCritic}) == 0
								aAdd(aRet, cMsgCritic)
							EndIf						
						Else
							/* Armazena mensagem de critica */
							cMsgCritic := Alltrim(MG7->MG7_MSGPD)
							
							/* Adiciona mensagem no Array se nao for repetida */
							If aScan(aRet,{|x| x == cMsgCritic}) == 0
								aAdd(aRet, cMsgCritic)
							EndIf																						
						EndIf											
					Else
						/* Adiciona criticas de formulas no array */
						If !xRet		
							If Empty(MG7->MG7_MSGPD)
								/* Armazena mensagem de critica */
								cMsgCritic := STR0004 //"Validação de  fórmula - Mensagem não preenchida"
								
								/* Adiciona mensagem no Array se nao for repetida */
								If aScan(aRet,{|x| x == cMsgCritic}) == 0
									aAdd(aRet, cMsgCritic)
								EndIf																													
							Else
								/* Armazena mensagem de critica */
								cMsgCritic := Alltrim(MG7->MG7_MSGPD)								
								
								/* Adiciona mensagem no Array se nao for repetida */
								If aScan(aRet,{|x| x == cMsgCritic}) == 0
									aAdd(aRet, cMsgCritic)
								EndIf																											
							EndIf																
						EndIf
					EndIf
				EndIf
				
				MG7->(dbSkip())
			EndDo
		EndIf
	Next nI
EndIf

/* Restaura areas */
RestArea(aAreaSA1)
RestArea(aAreaMG7)
RestArea(aAreaMG8)
RestArea(aArea)

Return aRet 				

//-------------------------------------------------------------------
/*/{Protheus.doc} STDPrintServ
Function para Buscar alimentar Rdmake dos Relatorios Gerenciais - Servico Financeiro

@param   aSelIten		Array com o item selecionado de Servico Financeiro 
@param   aRelSF			Array que contera os itens selecionados para impressao  
@author  Varejo
@version P11.8
@since   24/07/2014
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDPrintServ(aSelIten, aRelSF)

Local cImpRGer	:= SuperGetMV("MV_RELGART",, "U_LOJR600A") //Rdmake de Impressao
Local aArea		:= GetArea() 		//Guarda area atual
Local aAreaMG8	:= MG8->(GetArea())	//Guarda area MG8

Default	 aSelIten 	:= {}	 
Default	 aRelSF 	:= {}

ParamType 0 Var aSelIten	AS Array	Default {}
ParamType 1 Var aRelSF		AS Array	Default {}

/* Busca Cadastro de Servicos Financeiros */
MG8->(dbSetOrder(2))		

If MG8->(DbSeek(xFilial("MG8") + aSelIten[1]))
	/* Armazena Rdmake */                        
	If !Empty(MG8->MG8_RDMAKE)
		cImpRGer := MG8->MG8_RDMAKE
	EndIf		
	
	/* Array com informacoes para impressao */ 
	aAdd(aRelSF,{aSelIten[4], aSelIten[5], Str(a410Arred(aSelIten[3] * 1,"L2_VLRITEM"), TamSx3("L2_VLRITEM")[1],; 
			TamSx3("L2_VLRITEM")[2]), ""/*SERIE*/, MG8->MG8_CODIGO, AllTrim(MG8->MG8_DESCRI), ""/*Vlr.SF*/, cImpRGer})  				 	                                                                         
EndIf

/* Restaura areas */
RestArea(aAreaMG8)
RestArea(aArea)
		
Return Nil	

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpdServFin
Function para atualizar campos de Servicos Financeiros vinculados a produtos        

@param   cItemPrd		Item do produto vendido 
@param   cCodPrd		Codigo do produto vendido  
@author  Varejo
@version P11.8
@since   28/07/2014
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDUpdServFin(cItemPrd, cCodPrd)

Local aArea		:= GetArea() 		//Guarda area atual
Local aAreaSL2	:= SL2->(GetArea())	//Guarda area SL2

Default	 cItemPrd 	:= ""	 
Default	 cCodPrd 	:= ""

ParamType 0 Var cItemPrd	AS Character	Default ""
ParamType 1 Var cCodPrd		AS Character	Default ""

/* Atualiza campos com produto de venda */
RecLock("SL2", .F.)
SL2->L2_ITEMCOB := cItemPrd
SL2->L2_PRDCOBE	:= cCodPrd
SL2->(MsUnloCk())

/* Restaura areas */
RestArea(aAreaSL2)
RestArea(aArea)
			
Return Nil			

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFinVinc
Function para Verificar se Produto Financeiro vinculado e sem amarracao        

@param   oMdlIte		Objeto Cesta de produtos 
@param   nItem			Item anterior ao produto    
@author  Varejo
@version P11.8
@since   19/05/2015
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDFinVinc(oMdlIte, nItem)

Local aArea	 := GetArea() 		//Guarda area atual
Local aAreaSL2 := SL2->(GetArea())	//Guarda area SL2
Local aLines   := FwSaveRows()		//Array de linhas
Local nI	 	 := nItem - 1			//Contador do item anterior

Default oMdlIte 	:= Nil	 
Default nItem 	:= 0

ParamType 0 Var oMdlIte	As Object		Default Nil
ParamType 1 Var nItem	AS Numeric		Default 0

/* Verifica se item anterior e a cobertura do Servico Financeiro */
While nI > 0 
	oMdlIte:GoLine(nI)	
	
	/* Valida se produto cobertura nao e Servico Financeiro */
	If !STBIsFinService(STDGPBasket("SL2", "L2_PRODUTO"))		 
		RecLock("SL2",.F.)
			SL2->L2_ITEMCOB := STDGPBasket("SL2", "L2_ITEM")
			SL2->L2_PRDCOBE := STDGPBasket("SL2", "L2_PRODUTO")
		MsUnLock() 		
		
		Exit
	EndIf
	
	nI-- 		
EndDo
	
/* Restaura posicao do item */
oMdlIte:GoLine(nItem)

/* Restaura areas */
FwRestRows(aLines)
RestArea(aAreaSL2)
RestArea(aArea)

Return Nil


