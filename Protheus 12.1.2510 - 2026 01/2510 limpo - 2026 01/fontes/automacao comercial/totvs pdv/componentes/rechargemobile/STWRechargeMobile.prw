#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STWRECHARGEMOBILE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRecMob
Workflow para recarga de celular

Quando o código do item for informado, o sistema assume como uma recarga fiscal
caso contrário é uma recarga não fiscal.

@param   	cCodeItem Codigo do item de recarga
@param   	oNewTEF Objeto TEf
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	aRetTEF - Array com informacoes do TEF
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STWRecMob(cCodeItem, oNewTEF)

Local oDados 		:= Nil							//Instancia da classe de transacao de recarda de celular
Local oRetTran	:= Nil							//Retorno da transacao da recarga
Local aRet		:= {}							//Retorno da função
Local cNumCup		:= Space(STBLenReceipt())	//Numero do cupom
Local aRetTEF		:= {}							//Retorno do TEF 
Local nDecimais 	:= 0 							//Numero de casas decimais
Local aDados 		:= {}   						//Dados da transacao
Local lEmitNfce	:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe() // Sinaliza se utiliza NFC-e
Local lFisPrint		:= STFGetCfg("lUseECF")			//usa impressora fiscal
Local lLgSerNFisc := .F. //Campo de série não fiscal
Local cMsgLog		:= ""						//Mensagem de Log da Recarga
            
Default cCodeItem 	:= ""    
Default oNewTEF		:= STBGetTEF()

// Evento pegar Numero do cupom
If Empty(cCodeItem) 

	If Type("nMoedaCor") <> "U"
		nDecimais  	:= MsDecimais(nMoedaCor)
	Else
		nDecimais  	:= MsDecimais(1)
	EndIf    

EndIf


//Buca o Numero do Cupom Fiscal
aDados := { cNumCup , Nil}

If lFisPrint
	aRet := 	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
							"STGetReceipt"																,;		// Nome do evento
							aDados)
EndIf
    
If lFisPrint .AND. !lEmitNfce .And. (Len(aRet) == 0 .OR. aRet[1] <> 0 .OR. Len(aDados) == 0)      
   	MsgStop( STR0001, "STGetReceipt" ) //"Falha na obtenção do cupom"
Else
   
	cNumCup := aDados[1] 
	
	If !lFisPrint  //Se for NFe
 	    //NFCe pega o numero Da última venda
	    cNumCup := STDCSLastSale("L1_DOC")
    EndIf

	If Empty(cCodeItem )
			    
	    cNumCup := Soma1(cNumCup)	
	EndIf	
	
	oDados := LJCDadosTransacaoRC():New(0, Val(cNumCup), Date(), Time())
	
	If STBProdRec(cCodeItem)
		
		oRetTran := oNewTef:RecargaCel():RecFis(oDados)
		
		If oRetTran:oRetorno:lTransOk
		
			oNewTef:Cupom():Inserir("V",	oRetTran:oRetorno:oViaCaixa,oRetTran:oRetorno:oViaCliente,	"R",;
			   				   oNewTef:RecargaCel():GetTotalizador(),	oNewTef:RecargaCel():GetFormaPgto(oRetTran:oRetorno:cForma, oNewTef:Formas())	,					oRetTran:oRetorno:nValor,			1,;
											0)
	
		
			STBSetPric(oRetTran:oRetorno:nValor)
			
			aAdd(aRetTEF,{'Transacao', .T.})
			aAdd(aRetTEF,{'Hora', oRetTran:oRetorno:cHora})
			aAdd(aRetTEF,{'Data', oRetTran:oRetorno:dData})
			aAdd(aRetTEF,{'Valor', oRetTran:oRetorno:nValor})
			aAdd(aRetTEF,{'Cupom', oRetTran:nCupom})
			aAdd(aRetTEF,{'ViaCaixa', oRetTran:oRetorno:cViaCaixa})
			aAdd(aRetTEF,{'ViaCliente', oRetTran:oRetorno:cViaCliente})  
	
			//oNewTef:Confirmar() - Confirmacao da transacao e na venda		
			STBSetRec(aRetTEF)			
		Else
			STBSetPric(0)
			aAdd(aRetTEF,{'Transacao', .F.})
		EndIf
		
	ElseIf Empty(cCodeItem)

	
		lLgSerNFisc := SLG->(ColumnPos("LG_SERNFIS")) > 0 
		
		If ( lLgSerNFisc .AND. !Empty(STFGetStat("SERNFIS")) )  .OR. lFisPrint
		
	
			oRetTran := oNewTef:RecargaCel():RecNFis(oDados)
		
		
			If oRetTran:oRetorno:lTransOk
		
				
				oNewTef:Cupom():Inserir(		"V"											,;
												oRetTran:oRetorno:oViaCaixa				,;
												oRetTran:oRetorno:oViaCliente			,;
												"RNF"											,;
					   				   			oNewTef:RecargaCel():GetTotalizador()	,;	
					   				   			oNewTef:RecargaCel():GetFormaPgto(oRetTran:oRetorno:cForma)	,;
					   				   			oRetTran:oRetorno:nValor					,;
					   				   			1											,;
												0											)
				
				If oNewTEF:Cupom():Imprimir()
					oNewTef:Confirmar()
			 		//Gravação da transação
					STBRechMob(oRetTran)
				Else 
					oNewTef:Desfazer()
				EndIf
				
			EndIf		
		Else
			cMsgLog := STR0002 //"Para realizar a Recarga Não-Fiscal é necessário criar e informar o campo LG_SERNFIS, criado no compatibilizador U_UPDLO111"
			STFMessage("STWRecMob", "STOP", cMsgLog)
			STFShowMessage("STWRecMob")
			LjGrvLog( "STWRecMob",cMsgLog)	
		EndIf	
	
	EndIf

EndIf

If ValType(oDados) == "O"
	FreeObj(oDados)
	oNewTef:oConfig:oRecCel:oTrans:aColecao := {}
EndIf		

Return aRetTEF


 
