#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWREASONFORLOSTSALE.CH"




//-------------------------------------------------------------------
/*/{Protheus.doc} STWRsnLtSl
Motivo de Venda Perdida

@param   nItemLine			Linha do Item na Venda
@param   oReasons           Objeto motivo de venda perdida
@param   cJustific			, caractere, texto da justicativa de cancelamento
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRsnLtSl( nItemLine , oReasons, cJustific )

Local cItemCod			:= ""					// Codigo Produto
Local nAmount			:= 1					// Quantidade
Local cCodCli			:= ""					// Codigo do Cliente
Local cStoreCli			:= ""					// Loja do Cliente
Local cSeller			:= ""					// Codigo Vendedor
Local dDate				:= dDataBase			// Data da nao venda
Local nPosSel			:= 0					// Posicao do objeto selecionado
Local cCodReason		:= ""					// Codigo do motivo
Local aRsnCanIt			:= {}					// array para receber o objeto oReasons e justificativa

Default nItemLine 		:= 0					// Linha do Item na Venda
Default oReasons		:= Nil					// objeto motivo da venda
Default cJustific		:= "" 					// justificativa 

ParamType 0 Var nItemLine	As Numeric		Default 0

If SuperGetMV ("MV_LJMVPE",,.F.)  .AND. oReasons <> Nil // Usa Movimento de Venda Perdida? 
	
	If !IsInCallStack("STWRsnLCanCup") 
	
		aRsnCanIt := IIF(Existfunc("STIGTRsnLstIt"), STIGTRsnlstIt(),{})

		If Len(aRsnCanIt)> 0
			oReasons		:= aRsnCanIt[1]	// objeto motivo de perda da venda
			cJustific		:= aRsnCanIt[2]	// justificativa
		Endif

	Endif 

	nPosSel := oReasons:GetPos()
	If nPosSel > 0
		cCodReason :=  SubStr(oReasons:aItems[nPosSel],1,TamSX3("MBR_MOTIVO")[1])
	EndIf	


	If nItemLine > 0 .AND. !Empty(cCodReason)
		
		cItemCod 	:= STBTaxRet( nItemLine , "IT_PRODUTO" )
		nAmount 	:= STBTaxRet( nItemLine , "IT_QUANT"	)
		cSeller		:= STDGPBasket("SL2","L2_VEND",nItemLine)
		cCodCli		:= STDGPBasket("SL1","L1_CLIENTE")
		cStoreCli	:= STDGPBasket("SL1","L1_LOJA")
		
		STDAddLostSale( 	nItemLine	, cItemCod 	, nAmount		, cCodCli 			, ;
							cStoreCli	, cSeller		, dDate		, cCodReason		, ;
							cJustific)	
   
	
	EndIf   
	
	IIF(Existfunc("STISTRsnlstIt"), STISTRsnlstIt(),Nil)
	
EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} STWRsnLCanCup
Gravação de Motivo de Venda Perdida para Cancelamento de Cupom de Venda

@author  caio.okamoto
@version P12
@since   23/04/2024
@param cL1_Filial, caractere, filial
@param cL1_Num	 , caractere, numero da venda
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWRsnLCanCup(cL1_Filial, cL1_Num)

Local nQtdtem		:= STDPBLength("SL2") 
Local nX 			:= 1
Local aReasons		:= {}

Default cL1_Num		:= ""
Default cL1_Filial	:= ""

If SuperGetMV ("MV_LJMVPE",,.F.) //motivo da venda perdida
	
	aReasons	:= Iif(ExistFunc("STIGTRsnCanCup"), STIGTRsnCanCup(), {})

	if Len(aReasons) == 2 .and. !Empty(aReasons[1])  .AND. !Empty(aReasons[2]) 

		If !Empty(cL1_Filial) .AND. !Empty(cL1_Num)//gravação de motivo da perda de uma venda finalizada
			
			STWRsnlstVF(aReasons[1],aReasons[2], cL1_Filial, cL1_Num )

		Else //gravação de motivo da perda de uma venda em progresso
			
			For nX := 1 to nQtdtem
				STWRsnLtSl( nX , aReasons[1],aReasons[2] )
			Next nX

		Endif 
	Endif

	STDRecLostSale()

	Iif(ExistFunc("STISTRsnCanCup"), STISTRsnCanCup(), Nil)

Endif 

Return 


/*/{Protheus.doc} STWRsnlstVF
	Rotina para gravar motivo de perda da venda de um cupom finalizado 	
	
	@type  Function
	@author caio.okamoto
	@since 24/04/2024
	@version version
	@param oReasons  , object   , contem lista de motivo de perda de venda
	@param cJustific , caractere, texto complementar do motivo da perda de venda
	@param cL1_Filial, caractere, filial
	@param cL1_Num	 , caractere, numero da venda

	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function STWRsnlstVF( oReasons,cJustific,cL1_Filial, cL1_Num )
Local nPosSel		:= 0
Local cCodReason	:= ""
			
nPosSel := oReasons:GetPos()

If nPosSel > 0
	cCodReason :=  SubStr(oReasons:aItems[nPosSel],1,TamSX3("MBR_MOTIVO")[1])
EndIf	

SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
SL2->(dbSeek(cL1_Filial + cL1_Num))

While SL2->(!EOF()) .And. SL2->L2_FILIAL == cL1_Filial .And. SL2->L2_NUM == cL1_Num
	STDAddLostSale( Val(SL2->L2_ITEM), SL2->L2_PRODUTO 	, SL2->L2_QUANT		, SL1->L1_CLIENTE	, ;
					SL1->L1_LOJA	 , SL2->L2_VEND		, SL2->L2_EMISSAO	, cCodReason		, ;
					cJustific		 , SL2->L2_NUM		, SL2->L2_SERIE		, SL2->L2_DOC		 )	

	SL2->(dbSkip())
EndDo 

Return 


/*/{Protheus.doc} STWVldRsnInf
	(Rotina para certificar se o Motivo da Perda de Venda foi informado)
	@type Function
	@author caio.okamoto
	@since 29/10/2024
	@version 12
	@param oReasons, object, objeto TList do Motivo da Perda de Venda
	@param cJustific, caractere, justificativa 
	@return lRet, lógico, .T. se foi informado OU não está parametrizado
/*/
Function STWVldRsnInf(oReasons, cJustfic)
Local lRet		:= .T. 
Local nPosSel	:= 0

Default oReasons := Nil 
Default cJustfic := ""

If !Empty(oReasons)
	nPosSel := oReasons:GetPos()
	If Empty(nPosSel) 
		STFMessage("STWVldRsnInf", "POPUP", STR0001)//"É necessário selecionar o motivo de cancelamento.
		STFShowMessage("STWVldRsnInf")
		lRet:= .F.
	Endif 
Endif 

Return lRet
