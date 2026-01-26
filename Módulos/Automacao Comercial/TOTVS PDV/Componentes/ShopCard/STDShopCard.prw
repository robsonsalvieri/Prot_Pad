#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"


Static cNumCartao 	:= ""  	// Numero do cartao
Static dValidade		:= Nil  	// Validade
Static nValue			:= 0  		// Valor
Static cLojaFid		:= ""  	// Loja


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDSShopCardValues
Seta valores que serao acessados na finalizacao da venda.
@param cNumCar 	 Numero do cartao
@param  dDtValid	 Validade
@param  nValor	 Valor
@param  cLoja		 Loja
@author  Varejo
@version P11.8
@since   23/05/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSShopCardValues( cNumCar , dDtValid , nValor , cLoja )

Default cNumCar		:= ""					// Numero do cartao
Default dDtValid		:= CtoD("  /  /  ") // Data validade
Default nValor		:= 0					// Valor
Default cLoja		:= ""					// Loja

ParamType 0 Var 	cNumCar 	As Character	Default 	""
ParamType 1 Var 	dDtValid	As Date		Default 	CtoD("  /  /  ")
ParamType 2 Var 	nValor 	As Numeric		Default 	0
ParamType 3 Var 	cLoja 		As Character	Default 	""
	

cNumCartao	:= cNumCar
dValidade	:= dDtValid
nValue		:= nValor
cLojaFid	:= cLoja
													
Return Nil		
											

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIncShopCardFunds
Chama funcao da retaguarda responsavel pela inclusao de saldo no ShopCard.
@param   cItemCode		Quantidade do Item 
@param	  oDAOProd			Modelo de dados contendo as informacoes do Produto
@author  Varejo
@version P11.8
@since   23/05/2012
@return  lRet - Inclui saldo?
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDIncShopCardFunds()
													
Local aArea		:= GetArea()  // Guarda area
Local aParam 		:= {}			// Array de parametros	
Local uResult		:= Nil			// Resultado generico
Local lRet		:= .F.			// retorno
Local cDoc		:= STDGPBasket("SL1","L1_DOC")		// Numero Documento
Local cSerie		:= STDGPBasket("SL1","L1_SERIE")	// Serie

aParam 	:= {cNumCartao,dValidade,nValue,cDoc,cSerie,cLojaFid}

If !STBRemoteExecute("CA280ISLD" ,aParam, NIL,.T. ,@uResult	)
	
	// Tratamento do erro de conexao
	STFMessage(ProcName(), "ALERT", "Por falta de comunicação, será gravada como contingência.")
Else
	lRet := uResult
EndIf

RestArea(aArea)

// Limpa variaveis static
cNumCartao := ""
dValidade	:= Ctod("")
nValue		:= 0
cLojaFid	:= ""

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpdShopCardFunds
Chama funcao da retaguarda responsavel por atualizar o saldo do ShopCard.
@param   oModelVenda		-	Model da venda
@param	  nItemLine	-	Numero do item
@author  Varejo
@version P11.8
@since   15/10/2012
@return  lRet			- 	Retorna True caso o ShopCard tenha saldo disponivel para a venda.
/*/
//-------------------------------------------------------------------
Function STDUpdShopCardFunds( oModelVenda , nItemLine )
																
Local aArea			:= GetArea()		// Guarda area
Local aParam 			:= {}				// Array de parametros
Local uResult			:= Nil				// Resultado generico
Local lRet			:= .F.				// Retorno
Local cNumCar			:= ""				// Numero do cartao
Local cDoc			:= ""				// Documento
Local cSerie			:= ""				// Serie
Local cLoja			:= ""				// Loja
Local nSaldoAbat		:= 0				// Saldo

Default oModelVenda		:= Nil
Default nItemLine		:= 1

ParamType 0 Var  oModelVenda  As Object	Default Nil
ParamType 1 Var 	nItemLine 		As Numeric	Default 	1

cNumCar	:= oModelVenda:GetValue("L4_NUMCART",nItemLine)
nSaldoAbat	:= oModelVenda:GetValue("L4_VALOR",nItemLine)
cDoc		:= STDGPBasket("SL1","L1_DOC",nItemLine)
cSerie		:= STDGPBasket("SL1","L1_SERIE",nItemLine)
cLoja		:= STDGPBasket("SL1","L1_LOJA",nItemLine)
aParam 	:= {cNumCar,nSaldoAbat,cDoc,cSerie,cLoja}
					
If !STBRemoteExecute( "Ca280ASld" ,aParam, NIL,.F.	,@uResult	)
		
	// Tratamento do erro de conexao
	STFMessage(ProcName(), "ALERT", "Por falta de comunicação, não será possivel prosseguir com a operação.")
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
	lRet := .F.
Else
	lRet := uResult
	uResult	  := Nil
EndIf

RestArea(aArea)

Return lRet

