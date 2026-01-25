#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBPAYCDPG.CH"

Static nValAcrs 	:= 0 		//Valor do acrescimo
Static cAcres		:= "" 		//Tipo de Acrescimo financeiro
Static aParcelas	:= {}		//Parcelas gerada pela funcao Condicao()
Static cCondicao	:= ""		//Codigo da condicao de pagamento
Static cForma		:= ""		//Forma de pagamento
Static aDiasPgChck	:= {}		// Dias das parcelas da Condicao de Pagamento em Cheque
Static aAcresFin	:= {0,0}	// Dados do acréscomo financeiro aAcresFin[1] -> Valor,  aAcresFin[1] -> Aliquota


//-------------------------------------------------------------------
/*/{Protheus.doc} STBChkIsVp
Verifica se o tipo do vale presente selecionado é do tipo VP

@param   	oMdlGrd - Grid do Model
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - tipo do vale presente selecionado é do tipo VP
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBChkIsVp( oMdlGrd )
Local lRet 	:= .T.	//Variavel de retorno
Local nI 		:= 0 	//Variavel de loop

Default oMdlGrd := Nil

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	If oMdlGrd:GetValue('L4_MARCAR') .AND. AllTrim(oMdlGrd:GetValue('L4_FORMA')) == 'VP' 
		lRet := .F.
		STFMessage("STBPayCdPg", "Alert", STR0001) //"Para o caso de Vale-Presente, utilize Forma de Pagamento ao invés de Cond. Pagamento."
		STFShowMessage("STBPayCdPg")		
		Exit
	EndIf
Next nI


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBChkTpCP
Verifica o tipo de condicao selecionada

@param   	oMdlGrd - Grid do Model	
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - tipo e CP
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBChkTpCP( oMdlGrd )

Local nI 	:= 0 			//Variavel de loop
Local lRet	:= .T. 			//Variavel de retorno
Local oTotal:= STFGetTot() 	//Totalizador

Default oMdlGrd := Nil

cForma := ""  //Limpa variavel estatica para nao preencher pagamento automaticamente quando o MV_CONDPAD estiver vazio.

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	If oMdlGrd:GetValue('L4_MARCAR')
		
		cCondicao 	:= oMdlGrd:GetValue('L4_CODIGO')
		cForma		:= oMdlGrd:GetValue('L4_FORMA')
		
		If AllTrim(oMdlGrd:GetValue('L4_TIPO')) == 'A'
			lRet := .F.
			// Retornar a tela das formas de pagamento
			STIPayCancel()
			STFMessage("STBPayCdPg", "Alert",STR0002) // "A condição de pagamento do tipo A é de uso exclusivo dos ambientes de veículos e oficinas."
			STFShowMessage("STBPayCdPg")		
		ElseIf AllTrim(oMdlGrd:GetValue('L4_TIPO')) == '9'
			lRet := .F.
			// Retornar a tela das formas de pagamento
			STIPayCancel()
			STFMessage("STBPayCdPg", "Alert", STR0003) //"A condição de pagamento do tipo 9 é de uso exclusivo do faturamento."
			STFShowMessage("STBPayCdPg")
		ElseIf Empty(AllTrim(cForma))
			//Se na condicao de pagamento o E4_FORMA nao esta preenchido, assume como padrao o cheque.
			cForma = 'CH'
		EndIf
		Exit
	EndIf
Next nI 

/* Verifica limites da condição de pagamento */
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
If SE4->(DbSeek(xFilial("SE4")+ cCondicao))
	If SE4->E4_SUPER <> 0 .and. oTotal:GetValue("L1_VLRTOT") > SE4->E4_SUPER
		lRet := .F.
		// Retornar a tela das formas de pagamento, necessário para não perder o foco da tela
		STIPayCancel()
		STFMessage("STBPayCdPg", "STOP",STR0004) // "A condição de pagamento possui limite de pagamento inferior ao valor total da venda."
		STFShowMessage("STBPayCdPg")
	ElseIf SE4->E4_INFER <> 0 .and. oTotal:GetValue("L1_VLRTOT") < SE4->E4_INFER
		lRet := .F.
		// Retornar a tela das formas de pagamento
		STIPayCancel()
		STFMessage("STBPayCdPg", "STOP",STR0005) // "A condição de pagamento possui limite de pagamento superior ao valor total da venda."
		STFShowMessage("STBPayCdPg")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBApliDes
Aplicando desconto

@param   	oMdlGrd - Grid do Model
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - aplicou desconto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBApliDes( oMdlGrd )
Local nI 		:= 0 	//Variavel de loop
Local lDesTot	:= STBCDPGDes()

Default oMdlGrd := Nil

For nI := 1 to oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	
	If oMdlGrd:GetValue('L4_MARCAR') .And. oMdlGrd:GetValue('L4_DESCFIN') > 0
		If lDesTot
			STFSetTot("L1_DESCNF", oMdlGrd:GetValue('L4_DESCFIN'))
		EndIf
		STWTotDisc( oMdlGrd:GetValue('L4_DESCFIN') , 'P', 'CP', .T.)
		Exit
	EndIf
Next nI

Return .T.
 
//-------------------------------------------------------------------
/*/{Protheus.doc} STBApliAcr
Aplicando acrescimo

@param   	oMdlGrd - Grid do Model
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - aplicou acrescimo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBApliAcr( oMdlGrd )

Local nI 		  := 0				//Variavel de loop
Local aAcres	  := {}				//Acrescimo em valor
Local oTotal 	  := STFGetTot()	// Recebe o Objeto totalizador
Local lRecebTitle := STIGetRecTit()	// Indica se eh recebimento de titulos

Default oMdlGrd := Nil

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	If oMdlGrd:GetValue('L4_MARCAR') .AND. oMdlGrd:GetValue('L4_ACRSFIN') > 0
		
		aAcres := STBDiscConvert( oMdlGrd:GetValue('L4_ACRSFIN') , 'P' )
		STWAddIncrease( aAcres[1] , oMdlGrd:GetValue('L4_ACRSFIN') )   

		If Len(aAcres) > 0 .AND. aAcres[1] > 0 
			STBSetAcresFin(aAcres[1], aAcres[2])
			LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Acréscimo Financeiro incluso ", aAcres[1] )	
		EndIf

		// Se for recebimento de títulos não traz o acrescimo da condição de pagamento
		// Necessário para evitar erro na baixa do título.
		If lRecebTitle
			oTotal:SetValue("L1_VLRTOT",oTotal:GetValue( "L1_VLRTOT"))
			STFMessage("STBPayCdPg", "ALERT", STR0006)  //"Acréscimo financeiro só é permitido na seleção do título."
			STFShowMessage("STBPayCdPg")
		EndIf 
		Exit
	Else
		nValAcrs := 0	
	EndIf
Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBParcCp
Gera as parcelas da condicao de pagamento

@param   	
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - Gerou parcelas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBParcCp()

Local lCalcFin 	:= (SuperGetMv("MV_CALCFIN",,"M")== "F")  //Variavel para controle do parametro MV_CALCFIN = [F]inanciado
Local nI			:= 0 											//Variavel de loop
Local oTotal		:= STFGetTot()								//Recebe o Objeto totalizador	
Local nTotal		:= oTotal:GetValue("L1_VLRTOT")				//Total da venda

aParcelas := {}

If !Empty(cCondicao)
	If nValAcrs > 0
		If cAcres $ 'N '
			aParcelas := Condicao( nTotal, cCondicao, , , , , , nValorAcrs )
		Else
			aParcelas := Condicao( nTotal - nValAcrs, cCondicao )
		EndIf
	Else
		aParcelas := Condicao( nTotal, cCondicao )
	EndIf
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTratPar
Tratamento das parcelas geradas

@param   	
@author  	Varejo
@version 	P11.8
@since   	26/03/2013
@return  	lRet - Tratou parcelas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTratPar()

Local nI := 0 //Variavel de loop

If nValAcrs > 0

	If cAcres $ 'JN '
	
		If lCalcFin .AND. Len(aParcelas) > 0
			
			For nI := 1 To Len(aParcelas)
				
				If aParcelas[nX][1] = dDatabase

					If cAcres <> "J"          
						aParcelas[nX][2] -= nValorAcrs / Len( aParcelas )
					EndIf

				EndIf
							
			Next nI
			
			If cAcres == "J"
				aParcelas[1][2] += nValorAcrs
			EndIf
			
			
		EndIf
		
	ElseIf cAcres == "S"

		aEval( aParcelas,{ |ExpA1,nCntFor| nValRat += If( nCntFor == 1, 0, ExpA1[2] ) } )
		aEval( aParcelas,{ |ExpA1,nCntFor| nValTot += ExpA1[2] } )
					
		For nI := 1 to Len( aParcelas )
			If nI == 1
				aParcelas[nI][2] := nValorAcrs
			Else
				aParcelas[nI][2] := NoRound( nValTot * ( aParcelas[nI][2] / nValRat ), nDecimais )
			EndIf
		Next nI
		
	EndIf

EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetTpPay
Retorna o tipo da forma de pagamento

@param   	
@author  	Varejo
@version 	P11.8
@since   	27/03/2013
@return  	cForma - Forma de pagamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetTpPay()
Return AllTrim(cForma)


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetTpPay
Retorna o tipo da forma de pagamento

@param   	
@author  	Varejo
@version 	P11.8
@since   	27/03/2013
@return  	cForma - Forma de pagamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCdPg()
Return AllTrim(cCondicao)



//-------------------------------------------------------------------
/*/{Protheus.doc} STBTrnsCard
Condicao de pagamento com transacao TEF

@param   cTypePay - Tipo de pagamento	
@author  	Varejo
@version 	P11.8
@since   	27/03/2013
@return  	lRet - Retorna se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTrnsCard( cTypePay )

Local oTEF20 	:= STBGetTEF()
Local lRet		:= .F.
Local oPanPayCrd    := STIGetPan()    // Gera uma copia do oPanPayment original

Default cTypePay    := ""

ParamType 0 Var 	cTypePay 	As Character	Default 	""

If ValType(oTEF20) <> 'O' .OR. oTEF20:LATIVO == .F. // Se não utilizar TEF chama tela de cartão manual
   
   STIAddNewPan( oPanPayCrd, ,cTypePay )
   
Else
  
   lRet := STWTypeTran(Nil, oTEF20, AllTrim(cTypePay), Len(aParcelas))

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTrnsCheck
Condicao de pagamento com transacao de Cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	01/04/2013
@return  	lRet - Retorna se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTrnsCheck(aCondPg)

Local oPainel		:= Eval(STIGetBlCod())
Local bBlCod		:= STIGetBlCod()
Local cCondPg		:=	""	// Condicao de pagamento
Local aDiasPgChck	:= {} 	// Array com a condicao de pagamento Iindica para a funao STICHConfPay que a operação é via Condição de Pagamento
Local nX			:= 0 	// Contador do For

Default aCondPg		:= {} 	// Array com as Condicoes de Pagamento da SE4

For nX := 1 to Len(aCondPg)
	If aCondPg[nX][1][1][1]
		cCondPg := aCondPg[nX][1][1][2]		
		aDiasPgChck := STDCondPad(cCondPg)
		aDiasPgChck := aDiasPgChck[1][8]
	EndIf
Next nX

STBSetDPgChck( aDiasPgChck )

STICHConfPay(Nil, Nil, Nil, bBlCod, oPainel)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBTrnsCp
Inclui a condicao de pagamento no model

@param   	
@author  	Varejo
@version 	P11.8
@since   	28/03/2013
@return  	lRet - Retorna se executou corretamente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTrnsCp()
Local oTotal	:= STFGetTot()								//Recebe o Objeto totalizador	
Local nTotal	:= oTotal:GetValue("L1_VLRTOT")				//Total da venda

STIAddPay(cForma, Nil, Len(aParcelas), .T., /*cCodVp*/, nTotal)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetParc()
Retorna a variavel de parcelas

@param   	
@author  	Varejo
@version 	P11.8
@since   	28/03/2013
@return  	aParcelas - Informacoes das parcelas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetParc()
Return aParcelas

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetParc()
Limpa o array a parcelas

@param   	
@author  	Varejo
@version 	P11.8
@since   	28/03/2013
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetParc()
aParcelas := {}
Return .T.
          
//-------------------------------------------------------------------
/*/{Protheus.doc} STBCDPGAtuBasket()
Atualiza campos referente a Condição de pagamento na Cesta.

@param   	
@author  	Varejo
@version 	P11.8
@since   	28/03/2013
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCDPGAtuBasket(lLimpa)

Default lLimpa := .F.

If FindFunction("STDSCondPG")
	STDSCondPG(Iif(lLimpa,"",STBGetCdPg()))
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCDPGDes()
Valida se os fontes tratam o desconto condição de pagamento
com desconto no total

@author  	Varejo
@version 	P12
@since   	11/05/2018
@return  	.T.
/*/
//-------------------------------------------------------------------
Function STBCDPGDes()
Local lRet					:= .F.
Local dDtFontes				:= Ctod("14/05/2018")
Local lSTBDiscountTotalSale := GetApoInfo("STBDiscountTotalSale.PRW")[4] >= dDtFontes
Local lSTBImportSale		:= GetApoInfo("STBImportSale.PRW")[4] >= dDtFontes
Local lSTBPayCdPg			:= GetApoInfo("STBPayCdPg.PRW")[4] >= dDtFontes
Local lSTBPayment			:= GetApoInfo("STBPayment.PRW")[4] >= dDtFontes
Local lSTBValues			:= GetApoInfo("STBValues.PRW")[4] >= dDtFontes
Local lSTDProductBasket		:= GetApoInfo("STDProductBasket.PRW")[4] >= dDtFontes
Local lSTFTotalUpdate		:= GetApoInfo("STFTotalUpdate.PRW")[4] >= dDtFontes
Local lSTIDiscountTotal		:= GetApoInfo("STIDiscountTotal.PRW")[4] >= dDtFontes

lRet := lSTBDiscountTotalSale .And. lSTBImportSale .And. lSTBPayCdPg .And.;
 		lSTBPayment .And. lSTBValues .And. lSTDProductBasket .And. ;
 		lSTFTotalUpdate .And. lSTIDiscountTotal

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetParc()
Retorna o array aDiasPgChck

@param   	
@author  	JMM
@version 	V12.1.25
@since   	22/07/2019
@return  	aDiasPgChck - Intervalo de dias da Condicao de Pagamento (SE4)
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetDPgChck()
Return aDiasPgChck

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetParc()
Atribui valor ao array aDiasPgChck

@param   	
@author  	JMM
@version 	V12.1.25
@since   	22/07/2019
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetDPgChck( aValue )
Default aValue := {}

aDiasPgChck := aValue

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetAcresFin()
Atribui valor ao array aAcresFin

@param		nValor -> Valor do acrescimo, nAliq	 -> aliquota do acrescimo
@author  	JMM
@version 	V12.1.25
@since   	03/10/2019
@return  	.T.
/*/
//-------------------------------------------------------------------
Function STBSetAcresFin( nValor, nAliq )

aAcresFin[1] := nValor
aAcresFin[2] := nAliq

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetAcresFin()
Retorna valor do array aAcresFin

@param   	
@author  	JMM
@version 	V12.1.25
@since   	03/10/2019
@return  	valor do array aAcresFin
/*/
//-------------------------------------------------------------------
Function STBGetAcresFin()

Return aAcresFin


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRstCdPg()
Reseta a variável static sCondicao

@param   	
@author  	caio.okamoto
@version 	V12.1.33
@since   	23/06/2021
@return  	nil
/*/
//-------------------------------------------------------------------
Function STBRstCdPg()
cCondicao:=""
Return 

/*/{Protheus.doc} STBCondPad
	rotina criada para resolver o problema quando o Totvs PDV é online e conflita com o MV_CONDPAD	
	da Retaguarda. Para isso criamos o PE para que o Totvs PDV tenha seu próprio parâmetro
	@type  Function
	@author caio.okamoto
	@since 22/04/2025
	@version 12
	@return cCondPad, caracter, Condição de Pagamento 
	/*/
Function STBCondPad()
Local cCondPad := ""
Local lPECondPad := ExistBlock("STCondPad")

If lPECondPad 
	LjGrvLog(NIL, "Antes da execução do PE STCondPad",{STBIsImpOrc(), STIGetRecTit()})  
	cCondPad := ExecBlock( "STCondPad",.F.,.F. , {STBIsImpOrc(), STIGetRecTit()})
	LjGrvLog(NIL, "Depois da execução do PE STCondPad",cCondPad )  
Else
	cCondPad:= SuperGetMv('MV_CONDPAD',.F.,'')	
Endif 

Return cCondPad
