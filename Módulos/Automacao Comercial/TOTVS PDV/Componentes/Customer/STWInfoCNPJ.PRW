#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STWInfoCNPJ.CH"
#INCLUDE "POSCSS.CH"

Static lInfCPF	   := .F. // Indica se a tela de CPF ja foi apresentada ao cliente.

//-------------------------------------------------------------------
/*/{Protheus.doc}STWInfoCNPJ 
Informar CNPJ do Cliente 
@param1   	ExpC1 - Codigo Cliente
@param2		ExpC2 - Loja do Cliente
@param3		ExpC3 - Nome do Cliente
@param4		ExpC4 - Endereco do Cliente
@param5		ExpL1 - Informa dados
@param6		ExpL2 - Informa Endereco
@author  	Varejo 
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STWInfoCNPJ(lInfoCnpj,lTelaFimVnd,lObrigaLJ950)
Local lRet			:= .F.
Local cParCgc		:= SPACE(TamSX3("A1_CGC")[1])		// Variavel criada para enviar cgc 
Local oCliModel 	:= STDGCliModel()					// Model do Cliente	
Local lPrintCNPJ	:= .T.								// Indica se o CNPJ sera impresso na nota
Local cCliente  	:= oCliModel:GetValue("SA1MASTER","A1_COD")
Local cLojaCli  	:= oCliModel:GetValue("SA1MASTER","A1_LOJA")
Local cEndCli   	:= ""
Local cNomeCli  	:= ""
Local cDocCliSL1	:= ""
Local lInfoEnd		:= .T.
Local lCliPad		:= .F.

Default lInfoCnpj	:= .F. //Opção do menu "Informar CNPJ/CPF"
Default lTelaFimVnd	:= .F.
Default lObrigaLJ950:= .F.

/* Caso a venda tenha sido recuperada, significa que o CPF/CNPJ ja foi fornecido anteriormente. */
If STBIsRecovered()
	lInfCPF := .T.
ElseIf lInfoCnpj
	lInfCPF := !STWValInfCPF()
EndIf

If !lInfCPF .Or. IsInCallStack('STWNxtTelaIt') 
	If  !STBIsPaf()
		lPrintCNPJ	:= LJAnalisaLeg(30)[1] .Or. lObrigaLJ950	//Verificar se é São Paulo?		
		lInfoEnd	:= LJAnalisaLeg(58)[1]	//RS Informa o Endereço?
	Else
		lPrintCNPJ := .T.
		lInfoEnd := .T.
	EndIf
	
	If lPrintCNPJ
		lRet := .T.
		
		lCliPad := (Alltrim(cCliente) == Alltrim(SuperGetMV("MV_CLIPAD"))) .AND. (Alltrim(cLojaCli) == Alltrim(SuperGetMV("MV_LOJAPAD")))
		
		If lCliPad		
			//Executa a tela para perguntar o CGC
			cNomeCli := SPACE(TamSX3("A1_NOME")[1])
			cEndCli  := SPACE(TamSX3("A1_END")[1])
		Else
			//Executa a tela para perguntar o CGC
			If lInfoEnd
				cNomeCli 	:= IF(Empty(oCliModel:GetValue("SA1MASTER","A1_NOME"))  	,SPACE(TamSX3("A1_NOME")[1])   	,;
									AllTrim(oCliModel:GetValue("SA1MASTER","A1_NOME")))
				cEndCli  	:= IF(Empty(oCliModel:GetValue("SA1MASTER","A1_END"))		,SPACE(TamSX3("A1_END")[1]) 	,;
									AllTrim(oCliModel:GetValue("SA1MASTER","A1_END")))
			EndIf
		EndIf
	 
		//Caso jah tenha digitado ou cliente cadastrado, mostro o mesmo CPF para não ter que digitar novamente
		If STIGInfCPF()
			If !Empty(STDGPBasket("SL1","L1_CGCCLI"))
				cDocCliSL1 := STDGPBasket("SL1","L1_CGCCLI")
			ElseIf !Empty(AllTrim(STDGPBasket("SL1","L1_PFISICA")))	
				cDocCliSL1 := STDGPBasket("SL1","L1_PFISICA")
			EndIf
		EndIf
		If !Empty(AllTrim(cDocCliSL1))
			cParCgc		:= cDocCliSL1
		Else
			If lCliPad
				cParCgc		:= Nil
			Else
				cParCgc		:= IF(Empty(oCliModel:GetValue("SA1MASTER","A1_CGC")) .And. Empty(oCliModel:GetValue("SA1MASTER","A1_PFISICA"))	,SPACE(TamSX3("A1_CGC")[1])    ,;
							   IF(!Empty(oCliModel:GetValue("SA1MASTER","A1_CGC")), oCliModel:GetValue("SA1MASTER","A1_CGC"), AllTrim(oCliModel:GetValue("SA1MASTER","A1_PFISICA"))))
			EndIf
		EndIf

		STIInfoCNPJ(cParCgc,cNomeCli, cEndCli, lInfoEnd,lTelaFimVnd)
	Else
		//Configura a variável do CNPJ
		STI7InfCPF(.T.)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STI7InfCPF
Controla o valor da variavel static lInfCPF, que indica se a tela de CPF ja foi solicitada.

@param1   	lSet			.T. 
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STI7InfCPF(lSet)
DEFAULT lSet := .F.

lInfCPF := lSet

If !lSet					//Na reinicialização, eu deixo em branco o CPF,nome,endereço digitado
	STD7CPFOverReceipt("","","")
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIGInfCPF
Retorna o valor da variavel static lInfCPF, que indica se a tela de CPF ja foi solicitada.

@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	lInfCPF - Indica se a tela de CPF ja foi solicitada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGInfCPF()
Return lInfCPF

//-------------------------------------------------------------------
/*{Protheus.doc} STWValInfCPF
Verifica se a venda foi inicada e o cupom ja foi aberto, pois 
não poderá ser informado CPF com cupom em andamento.

@author  	Vendas & CRM
@version 	P11
@since   	06/07/2015
@return  	lRet - Indica se poderá (.T.) ser informado o CPF.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STWValInfCPF()
Local lRet			:= .T.												//Retorno da função
Local oTotal		:= STFGetTot()										//Total da venda
Local lEmitNFCe		:= STBGetNFCE()										//Valida se é NFC-e
Local nLjInfDocCli	:= IIF(ExistFunc("LjInfDocCli"), LjInfDocCli(), 1)	// Retorno do parametro MV_LJDCCLI

If nLjInfDocCli <= 1 .And. !lEmitNFCe .And. oTotal:GetValue( "L1_VLRTOT" ) > 0
	STFMessage(ProcName(), "STOP", STR0012) //"Não é possível informar o CPF, pois o cupom fiscal já foi aberto."
	STFShowMessage( ProcName() )
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDitaCPF
Envia comando para ser executado na DLL e retorna a resposta.
		
@author  	JMM
@version 	P12.1.25
@since   	13/08/2019
@return  	cRet	- Retorno da DLL ( CPF do Cliente )
@obs     
/*/
//-------------------------------------------------------------------	
Function STWDitaCPF()
Local cRet		:= SPACE(TamSX3("A1_CGC")[1])									// Retorno do CPF
Local aRet		:= {.F.,""}														// Array de retorno, [01] = Comunicou com PinPad, [02] = CPF
Local cEntrada 	:= "011111DIGITE SEU CPF                  CONFIRME O CPF  "		// Mensagem a ser apresentada no visor do PinPad
Local cSaida	:= "011100000000000"											// Usado para retorno com o CPF digitado pelo cliente
Local cRetDLL	:= "-1"															// Retorno de sucesso ou não ao comando da DLL
Local oTEF20	:= STBGetTEF()
Local lDigtCPF	:= GetAPOInfo("LOJA1926.PRW")[4] >= Ctod("26/08/2019")
Local aTxtTerm	:= {.F.,""}														// Retorno do metodo ImptTxTerm
Local lPPadAdyen:= .F. 															// Processo com pinpad Adyen. Projeto parado, enviar defult .F. 

LjGrvLog( "STWDitaCPF", "Inicio" )

If lDigtCPF

	STFMessage("Waiting","FWMSGRUN",STR0023) //Aguardando informação via PinPad...
	STFShowMessage("Waiting")

	ProcessMessage()//Garante que a mensagem de "aguarde" seja exibida

	// Chama o metodo para digitação do CPF
	If lPPadAdyen .AND. ExistFunc("LjUsePayHub") .And. LjUsePayHub() .And. ValType(oTEF20:oConfig:oComPaymentHub) == "O" .AND. oTEF20:oConfig:ISPgtoDig()
		aTxtTerm := oTEF20:oConfig:oComPaymentHub:ImptTxTerm()
		If aTxtTerm[1]
			cSaida := aTxtTerm[2]
			cRetDLL := aTxtTerm[3]
		EndIf
	Else
		cRetDLL := oTef20:oConfig:oComSitef:CPFPinPad(cEntrada, @cSaida )
	EndIf	

	Do Case
		Case cRetDLL == "0"

			cSaida := SubStr(cSaida,1,11)

			// Valida o CPF digitado
			If CGC( cSaida, , .F. ) .AND. !STWVldNRep(cSaida)
				aRet[01] := .T.
				aRet[02] :=	cSaida
				LjGrvLog( "STWDitaCPF", "CPF digitado via PinPad válido!",cRetDLL )
			Else
				LjGrvLog( "STWDitaCPF", "CPF Inválido!",cRetDLL )
				STFMessage("CPF", "POPUP", STR0017 ) // "CPF Inválido!"
				STFShowMessage( "CPF")
			EndIf
		Case cRetDLL == "-43"
			LjGrvLog( "STWDitaCPF", "Problema com o PinPad. Verifique!",cRetDLL )
			STFMessage("CPF", "POPUP", STR0018 ) // "Problema com o PinPad. Verifique!"
			STFShowMessage( "CPF")

		Case cRetDLL == "-2"
			LjGrvLog( "STWDitaCPF", "Operação cancelada!",cRetDLL )
			STFMessage("CPF", "POPUP", STR0019 ) // "Operação cancelada!"
			STFShowMessage( "CPF")

		OtherWise
			LjGrvLog( "STWDitaCPF",  "Verifique o serviço do Sitef! O serviço está indisponível ou o tempo de espera foi excedido.",cRetDLL )
			STFMessage("CPF", "POPUP", STR0020 + CHR(13)+CHR(10) + STR0021 ) //"Verifique o serviço TEF! O serviço está indisponível ou o tempo de espera foi excedido."
			STFShowMessage( "CPF")
	EndCase

	If aRet[01]	 
		cRet := aRet[02]
	EndIf
	
	STFCleanMessage("Waiting")
	STFCleanInterfaceMessage()

EndIf

LjGrvLog( "STWDitaCPF", "Fim" )

Return cRet
