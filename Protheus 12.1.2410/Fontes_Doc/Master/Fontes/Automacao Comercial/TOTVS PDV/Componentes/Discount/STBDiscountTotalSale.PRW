#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STBDISCOUNTTOTALSALE.CH"

Static lDiscTotPDV := .F.	// Indica se foi concedido desconto no Total da Venda pelo PDV

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValScreenDisc
Valida abertura de tela para desconto na venda

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Indica se pode abrir a tela de desconto no total
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValScreenDisc()
Local lRet		:= .T.				// Retorna se pode realizar a abertura de tela
Local oTotal 	:= STFGetTot()		// Recebe o Objeto totalizador	

/*/
	Valida Total Zerado
/*/
If lRet
	If oTotal:GetValue( "L1_VLRTOT" ) <= 0
		lRet := .F.                                 			
	EndIf
EndIf		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValDisc
Function Valida Desconto no Total da Venda

@param   nValDesc			Valor do Desconto
@param   cType				Tipo do Desconto. Se P - Percentual ou V - Valor.
@param   cOrigin			Define a procedência do desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Indica se pode ser realizado o desconto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValDisc( nValDesc , cType , cOrigin, aDescOrc )

Local 		lRet	 		:= .T.						// Encontrou item?
Local		nTotPerc		:= 0						// Percentual total( Percentual dos Itens + Percentual Total )
Local		nTotValor		:= 0						// Valor total( Valor dos Itens + Valor Total )
Local		nTotSale		:= 0						// Valor total da venda         
Local		lValUser		:= .F.						// Define se valida permissao de caixa
Local		oTotal 			:= STFGetTot()				// Recebe o Objeto totalizador	

Default		nValDesc		:= 0						// Valor do Desconto
Default		cType			:= ""						// Tipo do Desconto. Se P - Percentual ou V - Valor.
Default		cOrigin			:= ""		   				// Define a procedência do desconto
Default		aDescOrc		:= {0,0}					// Array com Informações sobre desconto no orçamento, sendo ele; valor total e percentual total.
   
nTotSale := oTotal:GetValue( "L1_VLRTOT" )

If cOrigin == "US" 		//  Desconto de usuário
	lValUser := .T.
EndIf

// Parametros errados
If lRet .AND. ( nValDesc <= 0 ) .OR. Empty(cType)
	lRet := .F.
	STFMessage("TotDesc","STOP", STR0001) //"Parametros do desconto nao compatíveis."
EndIf

// Valor Percentual acima do limite
If lRet .AND. cType == "P"
	If nValDesc > 99.00 // 99.91 ja da erro no ecf 
		lRet := .F.
		STFMessage("TotDesc","STOP", STR0002) //"Percentual de desconto acima do limite."
	EndIF
EndIf

// Valor Percentual acima do limite
If lRet .AND. cType == "V"
	If nValDesc >= nTotSale  
		lRet := .F.
		STFMessage("TotDesc","STOP", "Valor do desconto acima do limite.") //"Valor do desconto acima do limite."
	EndIF
EndIf

// Total da venda zerado
If lRet .AND. nTotSale == 0
	lRet := .F.
	STFMessage("TotDesc","STOP", STR0003) //"Não é possível realizar desconto para venda com total igual a zero."
EndIf

// Desconto maior ou igual ao total da venda
If lRet .AND. cType == "V"
	If nValDesc >= nTotSale
		lRet := .F.
		STFMessage("TotDesc","STOP", STR0004) //"Não é possível realizar desconto de um valor maior que o valor total da venda.
	EndIf
EndIf	

// Verifica permissao do caixa
If lRet .AND. lValUser
	lRet := STBValPermission( nValDesc , cType, aDescOrc )
EndIf	

Return lRet
	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} STBValPermission
Verifica permissão do caixa para conceder desconto

@param   nValDesc			Valor do Desconto
@param   cType				Tipo do Desconto. Se P - Percentual ou V - Valor.
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Indica se pode ser realizado o desconto no valor desejado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBValPermission( nValDesc , cType, aDescOrc ) 

Local		nTotSale		:= 0						// Valor total da venda
Local		oTotal			:= NIL						// Objeto Total 
Local		nAux			:= 0						// Variavel auxiliar
Local		nValueDesc		:= 0						// Valor efetivo do desconto a validar
Local		nPercDesc		:= 0						// Percentual efetivo do desconto a validar
Local		oTotal 			:= STFGetTot()			    // Recebe o Objeto totalizador	
Local 		aRet			:= {} 						// Retorno da liberação do Supervisor- retorna: retorno (T ou F), nome do supervisor e codigo do supervisor  

Default		nValDesc		:= 0						// Valor do Desconto
Default		cType			:= ""						// Tipo do Desconto. Se P - Percentual ou V - Valor.
Default 	aDescOrc		:= {0,0}					// Array com Informações sobre desconto no orçamento, sendo ele; valor total e percentual totoal.



nTotSale	:= oTotal:GetValue( "L1_VLRTOT"	)
aDiscount	:= STBDiscConvert( nValDesc , cType , nTotSale + aDescOrc[1]) // -- Somo o valor do desconto no orçamento apenas calculo do percentual
nValueDesc	:= aDiscount[1]
nPercDesc	:= aDiscount[2]
    
aRet := STFProfile( 11 , NIL , nPercDesc , nValueDesc , "T", , ,nTotSale )

If aRet[1]  .AND. STDRsnDesc()
	STDAddSupD (0,,aRet[3])
EndIf

Return aRet[1]


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTotDiscApply
Verifica permissão do caixa para conceder desconto

@param   nValDesc			Valor do Desconto
@param   cType				Tipo do Desconto. Se P - Percentual ou V - Valor.
@param   cOrigin			Define a procedência do desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Indica se foi aplicado desconto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTotDiscApply(  nValDesc , cType , cOrigin , lAccumulate ) 
Local 		lRet			:= .F.				// Retorno funcao
Local		nValDiscount	:= 0				// Valor do desconto
Local		nPerDiscount	:= 0				// Percentual do disconto      
Local		nTotSale		:= 0				// Valor total da venda
Local		oTotal 			:= STFGetTot()		// Recebe o Objeto totalizador
Local		lRecebTitle 	:= STIGetRecTit()	// Indica se eh recebimento de titulos
Local		lDesTot			:= ExistFunc("STBCDPGDes") .And. STBCDPGDes()
Local		lDesTotAnt		:= .F.				// Indica se ja foi concedido desconto no Total (F7)
Local		nTotDA1			:= IIF(ExistFunc('STDGetDA1'),STDGetDA1(),0) // Total dos itens para conceder o desconto
Local 		oRaas			:= Nil
Local 		oFidelityC		:= Nil
Local 		nValDFidel		:= 0
Local 		nDescTot		:= 0 

Default		nValDesc		:= 0						// Valor do Desconto
Default		cType			:= ""						// Tipo do Desconto. Se P - Percentual ou V - Valor.
Default		cOrigin			:= ""	   					// Define a procedência do desconto
Default		lAccumulate		:= .F.						// Acumula com descontos anteriores


LjGrvLog( ,"STBTotDiscApply | Inicio | Chamada por: " + ProcName(1), )

nDescTot:= Iif(cOrigin == "RULEDISC", oTotal:GetValue("L1_DESCONT"), STBTaxRet( Nil ,"NF_DESCTOT") )

nTotSale		:= IIF(nTotDA1 > 0, nTotDA1, oTotal:GetValue( "L1_VLRTOT"))
lDesTotAnt		:= !nDescTot == 0
aDiscount		:= STBDiscConvert( nValDesc , cType , nTotSale + Iif(cOrigin == "RULEDISC",oTotal:GetValue("L1_DESCONT"),0 ) )
nValDiscount	:= aDiscount[1]
nPerDiscount	:= aDiscount[2]

//Acumula valor do desconto
If lAccumulate
	nValDiscount += nDescTot
	nPerDiscount += STBDiscConvert( nDescTot , "V" , oTotal:GetValue( "L1_VLRTOT") + nDescTot)[2]
EndIf

LjGrvLog( ,"STBTotDiscApply | nTotSale -> " + cValToChar(nTotSale ), )
LjGrvLog( ,"STBTotDiscApply | lDesTotAnt -> " + cValToChar( lDesTotAnt ), )
LjGrvLog( ,"STBTotDiscApply | nTotDA1 -> " + cValToChar( nTotDA1 ), )
LjGrvLog( ,"STBTotDiscApply | lDesTot -> " + cValToChar( lDesTot ), )
LjGrvLog( ,"STBTotDiscApply | nValDiscount -> " + cValToChar( nValDiscount ), )

/*
Criada referencia para que seja possível validar
posteriormente se foi utilizado desconto no 
total da venda e se existe a referencia no model;
Além de não poder pegar o desconto acumulado pois a referência
da matxfis NF_DESCTOT vai somar todos os descontos dados 
no TotvsPDV
*/

If lDesTot 

	LjGrvLog( ,"STBTotDiscApply | Tipo do Desconto (cType): " + cType, )
	LjGrvLog( ,"STBTotDiscApply | Valor do Desconto: " + STR(nValDiscount), )

	If cOrigin == "US" //Desconto no Total - F7
		STDSPBasket("SL1","L1_DESCTOT", nValDiscount)
		lRet := .T.
	EndIf
	
	If cOrigin == "RULEDISC" .AND. !(lDesTotAnt .AND. procname(2) $ "STWRULETOTAL")

		If ExistFunc("LjxRaasInt") .And. LjxRaasInt()		
			oRaas := STBGetRaas()

			If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
				oFidelityC := oRaas:GetFidelityCore()
				If oFidelityC:ChoseToUse()
					nValDFidel := oFidelityC:GetBonus()
				EndIf 
			EndIf 
		EndIf

		If lDesTotAnt // Zera desconto anterior			
			If nTotDA1 > 0
				nValDiscount := ((nTotDA1 - nValDFidel) * ( nPerDiscount / 100 )) + nValDFidel
			Else
				// Calcula o desconto desconsiderando o desconto concedido via F7
				nValDiscount := (((nTotSale + nDescTot) - nValDFidel) * ( nPerDiscount / 100 )) + nValDFidel
			EndIf
		EndIf
	
		STDSPBasket("SL1","L1_DESCTOT", nValDiscount)
		lRet := .T.

	ElseIf cOrigin == "RULEDISC"	
		LjGrvLog( ,"STBTotDiscApply | Desconto referente a Regra de Desconto não aplicado, verificar campo LF_OPCDESC !" , )
	EndIf	

	If cOrigin == "CP" //Desconto Financeiro da Condição de Pagamento (SE4)
		oTotal:SetValue("L1_DESCFIN",nValDiscount)
		lRet := .T.
	EndIf

	If cOrigin == "FIDELITYCORE"
		STDSPBasket("SL1","L1_DESCTOT", nValDiscount)
		lRet := .T.
	EndIf 

EndIf

If nValDiscount >= 0
	STBTaxAlt( "NF_DESCTOT"	, nValDiscount	)
	
	If ExistFunc ("STBAjusICM") //Ao Aplicar o Desconto Ajusto a Base e o valor do ICMS
		STBAjusICM()
	EndIf
EndIf

/* Se for recebimento de títulos não traz o 
	desconto da condição de pagamento
 Necessário para evitar erro na baixa do título.*/
If lRecebTitle .AND. nValDiscount > 0
	oTotal:SetValue("L1_VLRTOT",nTotSale)
	STFMessage("TotDesc", "ALERT",STR0007)  //"Desconto financeiro só é permitido na seleção do título."
EndIf

LjGrvLog( ,"STBTotDiscApply | Fim | lRet: " +  cValToChar( lRet ) , )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDiscConvert
Retorna valores percentual em valor e vice-versa

@param   nValDesc			Valor do Desconto
@param   cType				Tipo do Desconto. Se P - Percentual ou V - Valor.
@param   nTotSale			Total da venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet				Retorna valores percentual em valor e vice-versa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDiscConvert( nValDesc , cType , nTotSale ) 

Local 		aRet			:= {}				// Retorno funcao
Local		nValueDisc		:= 0				// Valor efetivo do desconto a validar
Local		nPercDesc		:= 0				// Percentual efetivo do desconto a validar
Local		nAux			:= 0				// Variavel auxiliar
Local 		oTotal 			:= STFGetTot()		// Totalizador

Default		nValDesc		:= 0				// Valor do Desconto
Default		cType			:= ""				// Tipo do Desconto. Se P - Percentual ou V - Valor.
Default		nTotSale		:= 0				// Total da venda

If nTotSale <= 0
	nTotSale := oTotal:GetValue("L1_VLRTOT")	
EndIf

If ( nValDesc >= 0 ) .AND. ( nTotSale > 0 ) .AND. ( !Empty(cType) )
	
	Do Case                              
		Case cType = "P"
			// Procura saber qual o VALOR do total corresponde ao PERCENTUAL desejado
			nAux := nTotSale * ( nValDesc / 100 )
			
			nValueDisc	:= STBRound( nAux )
			nPercDesc	:= STBRound( nValDesc )	
	
		Case cType = "V"
			// Procura saber qual o PERCENTUAL do total corresponde ao VALOR desejado
			nAux := ( nValDesc / nTotSale ) * 100
			
			nValueDisc	:= STBRound( nValDesc )
			nPercDesc	:= STBRound( nAux )
	EndCase
	
EndIf

AADD( aRet	,	nValueDisc	)
AADD( aRet	,	nPercDesc	)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBDiscIncrease
Tratamento desconto e acréscimo

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se registrou desconto/acréscimo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDiscIncrease()        

Local lRet			:= .T.						// Retorna se registrou desconto/acréscimo
Local oTotal		:= STFGetTot()				// Totalizador	
Local nDiscount		:= 0						// Valor do desconto
Local nIncrease		:= 0						// Valor do acréscimo
Local nDiff			:= 0						// Valor de IPI e ICMS Solidario
Local lItemNF		:= STBExistNItemFiscal()	// Indica se existe item não-fiscal na venda
Local lItEntrega	:= STBTemEntr()				// Indica se existe item de entrega na venda

nDiscount	:= oTotal:GetValue("L1_DESCONT")

If STBIsImpOrc() .And. lItEntrega .And. lItemNF
	nIncrease	:= (	oTotal:GetValue( "L1_ACRSFIN"	)	)
Else
	nIncrease	:= (	oTotal:GetValue( "L1_ACRSFIN"	) + ;
						oTotal:GetValue( "L1_FRETE"		) + ;
						oTotal:GetValue( "L1_SEGURO"	) + ;
						oTotal:GetValue( "L1_DESPESA"	)	)
EndIf

nDiff := STBGValDifTx() //Calcula valores de IPI e ICMS Solidario 

If nDiff > 0
	nIncrease += nDiff
EndIf

Do Case 

	Case nDiscount > 0 .AND. nIncrease > 0
		
		lRet := STBDiscAndIncrease(nDiff)  
		
	Case nDiscount > 0
	
		lRet := STBPrintDiscount(nDiscount)
	
	Case nIncrease > 0 
	
		lRet := STWPrintIncrease(nIncrease)
		 
EndCase

If lRet .AND. (nDiscount > 0 .OR. nIncrease > 0)
	STBDiscRefresh()
EndIf
			 
Return lRet
      

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDiscAndIncrease
Tratamento para desconto e acréscimo na mesma venda

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se registrou desconto e/ou acréscimo na impressora
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDiscAndIncrease(nTxDiff)

Local lRet			:= .T.				// Retorno da funcao
Local oTotal		:= STFGetTot()		// Totalizador	
Local nDiscount		:= 0				// Valor do desconto
Local nIncrease		:= 0				// Valor do acr´éscimo
Local nDifference	:= 0				// Diferença entre Desconto e Acréscimo

Default nTxDiff		:= 0				// Diferenca

nDiscount	:= oTotal:GetValue("L1_DESCONT")

nIncrease	:= (	oTotal:GetValue( "L1_ACRSFIN"	) + ;
					oTotal:GetValue( "L1_FRETE"		) + ;
					oTotal:GetValue( "L1_SEGURO"	) + ;
					oTotal:GetValue( "L1_DESPESA"	)	)

If nTxDiff > 0
	nIncrease += nTxDiff
EndIf 
					
If nDiscount > 0 .AND. nIncrease > 0

	Do Case 
		
		/*/
			Desconto
		/*/	
		Case nDiscount > nIncrease
			
			nDifference := nDiscount - nIncrease			
			lRet := STBPrintDiscount(nDifference)
		
		/*/
			Acréscimo
		/*/
		Case nIncrease > nDiscount
		
			nDifference := nIncrease - nDiscount		    
			lRet := STWPrintIncrease(nDifference)			
		
		/*/
			Ambos são iguais
		/*/
		Otherwise      
		
			lRet := .T.
			
	EndCase
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPrintDiscount
Registra desconto no total na impressora

@param   nDiscount			Valor do desconto no total
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se registrou desconto na impressora
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintDiscount( nDiscount )

Local lRet				:= .T.				// Retorna se registro desconto na impressora
Local nTotal			:= 0				// Valor Total
Local aRetPrinter		:= {}				// Armazena retorno da impressora
Local oTotal 			:= STFGetTot()		// Totalizador
Local nOpt 				:= 2            	// Opção selecionada pelo usuário para tentar novamente
Local lTentaTiva 		:= .T.      		// controle de tentativa  

Default	nDiscount		:= 0				// Valor do desconto no total

ParamType 0 Var nDiscount As Numeric	  Default 0 

If STFUseFiscalPrinter()	    
	
	If STWGetIsOpenReceipt() // Cupom Aberto?		 
		
		If nDiscount <= 0		    
			nDiscount := oTotal:GetValue( "L1_DESCONT"	)		
		EndIf			
		
		If nDiscount > 0			
		
			nDiscount	:= nDiscount * STBFactor()[1]
			
			nTotal		:= STBFactor()[3]
					
												
			aRetPrinter := STFFireEvent(	ProcName(0)				  									, ;		// Nome do processo
						   						"STDescTot"				  								, ;		// Nome do evento
						   						{AllTrim(Str(STBRoundCurrency( nDiscount ),14,2)) 		, ;	   	// 01 - VALOR DESCONTO
						   						AllTrim(Str(STBRoundCurrency( nTotal ),14,2))   		} )		// 02 - Valor Total	
		   					
			If Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N" .AND. aRetPrinter[1] <> 0
						
				While lTentaTiva 
								
					STFMessage("TEFImprime", "YESNO", STR0006 ) //"Impressora não responde. Deseja imprimir novamente?"
					nOpt := If(STFShowMessage("TEFImprime"),2,0) 
				
					//2=SIM
					If nOpt == 2
					
						Sleep(1000)
												
						aRetPrinter := STFFireEvent(	ProcName(0)				  								, ;		// Nome do processo
			   												"STDescTot"				  							, ;		// Nome do evento
			   												{AllTrim(Str(STBRoundCurrency( nDiscount ),14,2)) 	, ;	   	// 01 - VALOR DESCONTO
			   												AllTrim(Str(STBRoundCurrency( nTotal ),14,2))   	} )		// 02 - Valor Total							
					
						//Erro na impressao
						If Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N"	.AND. aRetPrinter[1] <> 0		
							lTentaTiva := .T.
						Else
							lTentaTiva := .F.	
						EndIf
					
					Else				
						lTentaTiva := .F.					
					EndIf	
			
				EndDo
	
			EndIf
							   					
			If Len(aRetPrinter) > 0 .AND. ValType(aRetPrinter[1]) == "N"
				
				If aRetPrinter[1] == 0					
					lRet := .T.					
				Else					
					lRet := .F.			
					STFMessage("STDiscount","STOP", STR0005) //"Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada."					
				EndIf     
			
			Else 				
				lRet := .F.	
				STFMessage("STDiscount","STOP", STR0005) //	"Não foi possível registrar o Desconto no Total do Cupom. Operação não efetuada."			
			EndIf
			 
		Else		
			lRet := .T.			
		EndIf
		
	Else	
		lRet := .T.		
	EndIf
	
Else
	lRet := .T.
EndIf 			   					

STFShowMessage("STDiscount")

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBDiscRefresh
Atualiza os valores de todos os itens da MATXFIS para a cesta e para o banco. 
Caso concedido desconto ou acréscimo por exemplo

@param   
@author  Varejo
@version P11.8



@since   29/03/2012
@return 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDiscRefresh()        

Local nI				:= 0				// Contador

For nI := 1 To STDPBLength("SL2")

	STBRefshItBasket( nI )
	STDSaveSale(nI)

Next nI
				 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValDifTx
Apura os valores de IPI e Valor de ICMS Solidario a serem acrescidos 
no total da venda.

@param
@author  Varejo
@version P11.8
@since   25/05/2015
@return  nTxDiff - Valor de IPI + ICMS solidario.
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STBGValDifTx()
Local nTxDiff	:= 0
Local nI		:= 0
Local nValSol	:= 0
Local nValIpi	:= 0
Local lCfgTrib  as logical //Verifica se Configurador de Tributos esta habilitado
Local jCfgTaxes as json

lCfgTrib  := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.)
jCfgTaxes := JsonObject():New()

If STBTaxRet(, "NF_VALIPI") > 0 .Or. STBTaxRet(, "NF_VALSOL") > 0 

	For nI := 1 To STDPBLength("SL2")		
		
		If !STDPBIsDeleted( "SL2", nI )
			jCfgTaxes := If(lCfgTrib, STBGetTax("000056", nI), JsonObject():New()) //Configurador de Tributos - Id ICMS-ST = 000056
						
			If Len(jCfgTaxes) > 0
				If STBVerTotTax("000056", 1)
					nValSol += STBTaxRet(nI, "IT_VALSOL")
				EndIf
			ElseIf AllTrim( STBGetTESInfo( "F4_INCSOL" , AllTrim(STBTaxRet(nI,"IT_TES"))) ) != "N" //Verifica se TES configurado para agregar ICMS Solidario
				nValSol += STBTaxRet(nI, "IT_VALSOL")
			EndIf

			jCfgTaxes := If(lCfgTrib, STBGetTax("000022", nI), JsonObject():New()) //Configurador de Tributos - Id IPI = 000022

			If Len(jCfgTaxes) > 0
				If STBVerTotTax("000022", 1)
					nValIpi += STBTaxRet(nI, "IT_VALIPI")
				EndIf
			Else
				nValIpi += STBTaxRet(nI, "IT_VALIPI")
			EndIf
		EndIf			
	Next nI

	nTxDiff := (nValSol + nValIpi)

EndIf

FreeObj(jCfgTaxes)
jCfgTaxes := Nil

Return nTxDiff

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetDiscTotPDV
Seta valor a variavel estatica lDiscTotPDV
@param   	lDiscount			Logico - Desonto no Total da Venda pelo PDV
@author  	JMM
@version 	P12.1.23
@since   	22/05/2019
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetDiscTotPDV( lDiscount )
lDiscTotPDV := lDiscount
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetDiscTotPDV
Retorna o valor de lDiscTotPDV
@param   
@author  	JMM
@version 	P12.1.23
@since   	22/05/2019
@return  	lDiscTotPDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetDiscTotPDV()
Return(lDiscTotPDV)
