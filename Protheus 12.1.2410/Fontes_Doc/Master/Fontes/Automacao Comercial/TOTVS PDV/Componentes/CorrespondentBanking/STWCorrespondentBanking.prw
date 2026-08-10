#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWCORRESPONDENTBANKING.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCorBank
Correspondente bancario. 
Responsavel por pagamento e extorno de contas ultilizando funcoes TEF 2.0

@param   oNewTEF 		Objeto TEF	
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Nil
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STWCorBank( oNewTEF )

Local oDados 				:= Nil												//Instancia da classe de correspondente bancario
Local oRetTran			:= Nil												//Retorno da transacao 
Local aRet				:= {}												//Retorno da funcao
Local cStation			:= STFGetStat("CODIGO")                    //Codigo da estacao atual
Local cNumCup				:= space(STBLenReceipt())						//Numero do Cupom
Local cSimbCoin			:= ""												//Simbolo da moeda do pagamento
Local nDecimais 			:= 0   											//Decimais
Local aDados				:= {}               							//Array de dados
Local lLgSerNFisc := .F. //Campo de série não fiscal
Local cMsgLog		:= ""						//Mensagem de Log da Recarga
Local cPrefTit		:= "" 							//Prefixo do título
Local aNotas		:= {}							//Array com numeração de NFce
Local lFisPrint		:= STFGetCfg("lUseECF")			//usa impressora fiscal


Default oNewTEF		:= STBGetTEF()

If Type("nMoedaCor") <> "U"
	nDecimais  	:= MsDecimais(nMoedaCor)
Else
	nDecimais  	:= MsDecimais(1)
EndIf


aDados := {cNumCup, Nil}
If lFisPrint
//Buca o Numero do Cupom Fiscal
	
	aRet 	:= 	STFFireEvent(	ProcName(0)				,;		// Nome do processo
							"STGetReceipt"			,;		// Nome do evento
							aDados )

EndIf

If lFisPrint .And. (Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) == 0)      
   	MsgStop( STR0001 , "STGetReceipt" )    //"Falha na obtenção do cupom"
Else
	
	
	cNumCup 	:= aDados[1]
	
	If !lFisPrint  //Se for NFe
 	    //NFCe pega o numero Da última venda
	    cNumCup := STDCSLastSale("L1_DOC")
    EndIf
	
	cNumCup := Soma1(cNumCup)
	
	cPrefTit := STFGetStat("LG_SERIE")	
	lLgSerNFisc := SLG->(ColumnPos("LG_SERNFIS")) > 0 
		
	If ( lLgSerNFisc .AND. !Empty(cPrefTit := STFGetStat("SERNFIS")) ) .OR. lFisPrint
	
		//Testo se é nfce para pegar o numero do cupom pelo ljxdnota

		If !lFisPrint
			LjxDNota( cPrefTit , 3, .F., 1, @aNotas,,,,,,,,,,,,, "DOCNF" ) // DOC/SERIE
			
			If Len(aNotas) > 0 .AND. Len(aNotas[1]) > 1
				cNumCup := aNotas[1][2]
			Else
				cNumCup := ""				
			EndIf
		EndIf
	
		If !Empty(cNumCup)
			oDados 	:= LJCDadosTransacaoCB():New( 0, Val(cNumCup), Date(), Time())	
	
			oRetTran := oNewTef:CorrespBanc():EfetuaPgto(oDados) 
			
			
			If oRetTran:oRetorno:lTransOk
			
				// Pega pagamento utilizado 
				cSimbCoin :=	oNewTef:CorrespBanc():GetFormaPg()
			
				//retorna a forma do CB bancario
					
				oNewTef:Cupom():Inserir(	"V"									,;
											oRetTran:oRetorno:oViaCaixa		,;
											oRetTran:oRetorno:oViaCliente	,;
											"B"									,;
					   				   		oNewTef:CorrespBanc():GetTotalizador(),;
					   				   		oNewTef:CorrespBanc():GetFormaPg(),;
					   				   		oRetTran:oRetorno:nVlrTotCB		,;
					   				   		1									,;
											0									) 
											
				If oNewTEF:Cupom():Imprimir()
					
					// Confirma transacao
					oNewTEF:Confirmar()  
					//Gravacao da transacao
					STBRecCorBank( oRetTran:oRetorno , cSimbCoin , AllTrim(Str(Val(cNumCup))), cPrefTit)
					
				Else 
					oNewTEF:Desfazer()
				EndIf	
				
			Else
				oNewTEF:Desfazer()
				STFMessage("STCorBank","STOP", STR0002)	//"Atencao, Nao foi possivel realizar a transacao com correspondente bancario"
				STFShowMessage("STCorBank")	
			EndIf		
		Else

			STFMessage("STCorBank2","STOP", STR0001)	//"Falha na obtenção do cupom"
			STFShowMessage("STCorBank2")	
		EndIf
	Else
		cMsgLog := STR0003 //"Para transações em Correspondente Bancário é necessário criar e informar o campo LG_SERNFIS, criado no compatibilizador U_UPDLO111"
		STFMessage("STCorBank", "STOP", cMsgLog)
		STFShowMessage("STCorBank")
		LjGrvLog( "STCorBank",cMsgLog)	

	EndIf
EndIf


If ValType(oDados) == "O"
	FreeObj(oDados)
EndIf
If ValType(oRetTran) == "O"
	FreeObj(oRetTran)
EndIf

Return Nil



