#include 'PROTHEUS.CH'

// Interface de array para ser enviada para o DAO
#DEFINE  TAMANHOPAY        	3 // Opcional
#DEFINE  TIPO        		1 // Obrigatório
#DEFINE  DESCRICAO        	2 // Opcional
#DEFINE  CODIGO        		3 // Opcional

Function STBCPaymentOptionsCreator ; Return  	// "dummy" function - Internal Use


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCPaymentOptionsCreator
Classe STBCPaymentOptionsCreator, cria e mostra opções de pagamento
@param   	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Class STBCPaymentOptionsCreator

Data OptPay

Data oPayX5
Data oAdmin
Data oConPay
Data oOptPag

//Construtor
Method STBCPaymentOptionsCreator(oPayX5, oAdmin, oConPay)
	
// Public
Method OptionsCreator()
	
// Interno
Method PayDefaut()
Method AdmOptionsCreator()
Method CondPagOptionsCreator()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCPaymentOptionsCreator
Classe STBCPaymentOptionsCreator, metodo construtor
@param   oFmX5   	Model com formas de Pagamento
@param   oAdmin  	Model com Adm Financeira (detalhes: Juros e Descontos)
@param   oConPag	Model com Condição de pagamento	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method STBCPaymentOptionsCreator(oPayX5, oAdmin, oConPay) Class STBCPaymentOptionsCreator

Self:oPayX5		:= oPayX5
Self:oAdmin		:= oAdmin
Self:oConPay	:= oConPay

Self:oOptPag := STDAOptionsPayments():STDAOptionsPayments()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OptionsCreator
@param   	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method OptionsCreator() Class STBCPaymentOptionsCreator

Self:PayDefaut()
Self:AdmOptionsCreator()
Self:CondPagOptionsCreator()

Self:oOptPag:GetAll()

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} AdmOptionsCreator
Metodo cria opcao baeada no SAE
@param   	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//--------------------------------------------------------------------
Method AdmOptionsCreator() Class STBCPaymentOptionsCreator

Local cTypePag	:= "" 	//Tipo de pagamento
Local nX 			:= 1	//Variavel de loop
Local aOpt			:= Array(TAMANHOPAY) //Tamanho do array

For nX := 1 To oPayX5:Lengt()

	oPayX5:GoLine(nX)
	cTypePag := oPayX5:GetValue("X5_TYPE")
	
	If Self:oAdmin:SeekLine({{ "X5_TYPE", cTypePag} })		
		aOpt[TIPO]			:=  oPayX5:GetValue("X5_TYPE")
		aOpt[DESCRICAO]		:=  oPayX5:GetValue("X5_DESC")
		aOpt[CODIGO]		:=  ""
		Self:oOptPag:Add(aOpt)
		// Renicia Array para não levar valor da posicao anterio
		aOpt		:= Array(TAMANHOPAY)
	EndIf

Next nX

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AdmOptionsCreator
Metodo cria opcao baeada no se4
@param   	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//--------------------------------------------------------------------
Method CondPagOptionsCreator() Class STBCPaymentOptionsCreator

Local nX 		:= 1		// Contador
Local aOpt		:= Array(TAMANHOPAY) //Tamanho do array

For nX := 1 To oConPay:Lengt()

	oConPay:GoLine(nX)
	
	aOpt[TIPO]			:=  oPayX5:GetValue("CP")
	aOpt[DESCRICAO]		:=  oPayX5:GetValue("E4_DESCRI")
	aOpt[CODIGO]		:=  oPayX5:GetValue("E4_CODIGO")
	
	Self:oOptPag:Add(aOpt)
	// Renicia Array para não levar valor da posicao anterio
	aOpt		:= Array(TAMANHOPAY)

Next nX

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} AdmOptionsCreator
Metodo cria opcao de Default
@param   	
@author  Varejo
@version P11.8
@since   24/04/2012
@return  Self
@obs     
@sample
/*/
//--------------------------------------------------------------------
Method PayDefaut() Class STBCPaymentOptionsCreator

Local nX 		:= 1		// Contador
Local aOpt		:= Array(TAMANHOPAY) //Tamanho do array

// Cheque
aOpt[TIPO]			:=  oPayX5:GetValue("CH")
aOpt[DESCRICAO]		:=  oPayX5:GetValue("Cheque")
aOpt[CODIGO]		:=  ""
Self:oOptPag:Add(aOpt)
// Renicia Array para não levar valor da posicao anterio
aOpt := Array(TAMANHOPAY)


// Cond Negociada
aOpt[TIPO]			:=  "CN"
aOpt[DESCRICAO]		:=  "Cond Negociada"
aOpt[CODIGO]		:=  ""
Self:oOptPag:Add(aOpt)
// Renicia Array para não levar valor da posicao anterio
aOpt := Array(TAMANHOPAY)


// Cond Negociada
aOpt[TIPO]			:=  "MN"
aOpt[DESCRICAO]		:=  "Multi Negociação"
aOpt[CODIGO]		:=  ""
Self:oOptPag:Add(aOpt)
// Renicia Array para não levar valor da posicao anterio
aOpt := Array(TAMANHOPAY)


// Analisar
//Self:oOptPag:Add("Diheiro")

Return