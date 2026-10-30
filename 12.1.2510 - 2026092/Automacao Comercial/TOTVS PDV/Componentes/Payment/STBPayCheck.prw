#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBPAYCHECK.CH"

Static lCheck 	:= .F. 	//Se utilizou cheque ou nao
Static nParcels 	:= 0 		//Numero de parcelas
Static oTEF20		:= Nil		//Objeto do TEF 

//-------------------------------------------------------------------
/*/{Protheus.doc} STBLeCMC7
Faz a leitura do cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	02/03/2013
@return	aRet - array com dados do cheque  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBLeCMC7()

Local oMdl 		:= STIGetMdl()						//Get no model do cheque
Local oModel		:= oMdl:GetModel("CHECKMASTER")		//Model master
Local aRet		:= {}									//Retorno dos dados do cheque
Local aDados		:= {}									//Quantidade de parcelas
Local nI			:= 0									//Variavel de Loop

For nI := 1 To oModel:GetValue("L4_PARCELAS")

	STFMessage("STBPayCheck", "OK", STR0001) //"Posicione o cheque no CMC7 para leitura!"
	STFShowMessage("STBPayCheck")

	Aadd(aDados, nI)
	Aadd(aRet, STFFireEvent(ProcName(0), "STReadCmc7", aDados ))
	aDados := {}

Next nI 

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBConCheck
Faz a consulta do cheque

@param   	aRetCheck - Array com informacoes do TEF
@author  	Varejo
@version 	P11.8
@since   	02/03/2013
@return	lRet - Informa se executou corretamente  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBConCheck( aRetCheck )
Local oMdl 	:= STIGetMdl()					//Get no model do cheque
Local oModel	:= oMdl:GetModel("CHECKMASTER")	//Model master
Local nValor	:= oModel:GetValue("L4_VALOR")	//Valor do pagamento em cheque  
Local dDtVenc	:= oModel:GetValue("L4_DATA")	//Vencimento do cheque
Local cCupom 	:= STBRetCup()					//Numero do cupom
Local cCgcCli	:= STDGPBasket("SL1","L1_CGCCLI")
Local cTipoCli	:= ""
Local nI		:= 0								//Variavel de loop
Local nX		:= 0

Default aRetCheck := {}

oTEF20		:= STBGetTEF()	
aRetCheck	:= STWGetCkRet()

If ValType(cCgcCli) <> "C"
	cCgcCli := ""
EndIf

For nI := 1 To Len(aRetCheck)
	If ValType(aRetCheck[1][1][1]) == "A"
		nX := 1
		While nX <= Len(aRetCheck[1]) .AND. Len(aRetCheck[1]) > 0 
			oDados := LJCDadosTransacaoCheque():New(nValor, Val(cCupom), Date(), Time(),;
													Val(aRetCheck[nI][1][nX][1]), Val(aRetCheck[nI][1][nX][3]), Val(aRetCheck[nI][1][nX][4]), Val(aRetCheck[nI][1][nX][2]),;
   													 	 0, 0, 0, dDtVenc, Val(aRetCheck[nI][1][nX][5]),cTipoCli,cCgcCli)
			   													 	
			oRetTran := oTEF20:Cheque():Consultar(@oDados)   
			
			If oRetTran:oRetorno:lTransOk 
			
				oTEF20:Cupom():Inserir("G",	oRetTran:oRetorno:oViaCaixa,oRetTran:oRetorno:oViaCliente,	"H",;
			   							  oTEF20:Cheque():GetTotalizador(),oTEF20:Cheque():GetFormaPgto(oTEF20:Formas()), oRetTran:nValor, 1,;
										  0)
											
				If nX == Len(aRetCheck[1])
					lCheck := .T.
					STBInsCheck()
				EndIf
			
				nX++
			Else
				adel(aRetcheck[1], nX) //deleta a transacao
				aSize(aRetCheck[1], Len(aRetCheck[1]) -1) //deleta o array
			EndIf
   		End
	Else
		oDados := LJCDadosTransacaoCheque():New(nValor, Val(cCupom), Date(), Time(),;
													 Val(aRetCheck[nI][1][1]), Val(aRetCheck[nI][1][3]), Val(aRetCheck[nI][1][4]), Val(aRetCheck[nI][1][2]),;
		   											 0, 0, 0, dDtVenc, Val(aRetCheck[nI][1][5]), Nil, Nil)
		   								
		oRetTran := oTEF20:Cheque():Consultar(oDados)   
		
		If oRetTran:oRetorno:lTransOk 
		
			oTEF20:Cupom():Inserir("G",	oRetTran:oRetorno:oViaCaixa,oRetTran:oRetorno:oViaCliente,	"H",;
		   							   oTEF20:Cheque():GetTotalizador(),oTEF20:Cheque():GetFormaPgto(oTEF20:Formas()), oRetTran:nValor, 1,;
										0)
										
			If nI == Len(aRetCheck)
				lCheck := .T.
				STBInsCheck()
			EndIf
		
		Else
			adel(aRetcheck, nI) //deleta a transacao
			aSize(aRetCheck, Len(aRetCheck) -1) //deleta o array
		EndIf
	EndIf
Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPrintChk
Impressao do cheque

@param   	aRetCheck - Array com informacoes do TEF	
@author  	Varejo
@version 	P11.8
@since   	04/03/2013
@return	lRet - Informa se executou corretamente  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrintChk(aRetCheck)

Local oMdl 	:= STIGetMdl()					//Get no model do cheque
Local oModel	:= oMdl:GetModel("CHECKMASTER")	//Model master
Local aDados	:= {}								//Dados para impressao do cheque
Local nI		:= 0								//Variavel de Loop

Default aRetCheck := {}

ParamType 0 Var   	aRetCheck 	As Array	Default 	{}

For nI := 1 To oModel:GetValue("L4_PARCELAS")	
	STFMessage("STBPayCheck", "OK", STR0002 + AllTrim(Str(nI)) + STR0003) //"º cheque para impressao!"
	STFShowMessage("STBPayCheck")
	aDados :=  STBPrepDat( aRetCheck, nI, oModel:GetValue("L4_PARCELAS"), oModel:GetValue("L4_VALOR") )
	STFFireEvent(ProcName(0), "STCHPRINTS", aDados)
Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPrepDat()
Prepara os dados para impressao do cheque

@param   	aRetCheck - Array com informacoes do TEF
@param   nI - Linha posicionada
@param    Numero das parelas
@param    Valor 	
@author  	Varejo
@version 	P11.8
@since   	04/03/2013
@return	lRet  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBPrepDat(aRetCheck, nI, nParcels, nVal)

Local aRet 				:= {}		// Retorno

Default aRetCheck   	:= {}
Default nI				:= 0
Default nParcels			:= 0	
Default nVal				:= 0

ParamType 0 Var  aRetCheck 	As Array	Default 	{}
ParamType 1 Var 	nI 				As Numeric	Default 	0
ParamType 2 Var 	nParcels 		As Numeric	Default 	0
ParamType 3 Var 	nVal 			As Numeric	Default 	0

Aadd(aRet,	aRetCheck[nI][1][1]) 				//Banco
Aadd(aRet,	AllTrim(Str((nVal / nParcels))))	//Valor
Aadd(aRet,	If(Empty(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM))//Favorecido
Aadd(aRet,	Left(SM0->M0_CIDCOB,15))				//Cidade
Aadd(aRet,	DToS(Date()))							//Data
Aadd(aRet,	"")										//Mensagem
Aadd(aRet,	"")										//Verso
Aadd(aRet,	"")										//Extenso
Aadd(aRet,	"")										//Chancela

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBInsCheck()
Chama a funcao para inserir o pagamento de cheque na grid

@param   	
@author  	Varejo
@version 	P11.8
@since   	11/03/2013
@return	lRet - Informa se executou corretamente  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBInsCheck()

Local oMdl 	:= STIGetMdl()					//Get no model do cheque
Local oModel	:= oMdl:GetModel("CHECKMASTER")	//Model master

STIAddPay("CH", oModel, oModel:GetValue("L4_PARCELAS"))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSetCheck
Set na variavel lCheck para .F.

@param   	
@author  	Varejo
@version 	P11.8
@since   	11/03/2013
@return	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSetCheck()
lCheck := .F.
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetCheck
Retorna o valor de lCheck

@param   	
@author  	Varejo
@version 	P11.8
@since   	11/03/2013
@return	lRet - Retorna o valor de lCheck	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCheck()

Local lRet := lCheck 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetPcls
Retorna o numero do cheque a ser preenchido pelo usuario

@param   	
@author  	Varejo
@version 	P11.8
@since   	12/03/2013
@return	nParcels - Retorna o numero do cheque 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetPcls()
Return nParcels


//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetRetChk
Retorno das variaveis da consulta de cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	05/04/2013
@return	oTEF20 - Retorno das variaveis da consulta de cheque
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetChkRet()
Return oTEF20

