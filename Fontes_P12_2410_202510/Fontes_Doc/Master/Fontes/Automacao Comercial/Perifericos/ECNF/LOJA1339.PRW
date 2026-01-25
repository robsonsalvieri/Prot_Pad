#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"

Function LOJA1339 ; Return 	 // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºClasse    ³LJANfDaruma      ºAutor  ³Vendas Clientes     º Data ³  05/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe abstrata, possui as funcoes comuns para todos os ECF'S do   º±±
±±º			 ³modelo LJANfDaruma											     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Class LJANfDaruma From LJAEcnf
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
		
	Method New(oTotvsApi)														//Metodo construtor
	Method AbrirPorta(cPorta)													//Abre a porta serial para comunicacao com o ECF
	Method FechaPorta(cPorta)													//Fechar a porta serial	
   	Method InicVar()															//Inicializando variaveis
	Method ImpTextoNf(cTexto)
	Method StImp()
	Method CarregMsg()
	Method ImpCodeBar(cTipo,cTexto) 											//Imprime codigo de barras
	Method AbrirGavet()
	Method ImpBitMap(cArquivo)
	Method CortaPapel()
EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³New   	       ºAutor  ³Vendas Clientes     º Data ³  05/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe LJANfDaruma.     			    	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto														     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method New(oTotvsApi) Class LJANfDaruma
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
    
    //Inicializando variaveis
    ::oFormasVen := Nil

    //Carrega as mensagens
	::CarregMsg()
	
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³AbrirPortaºAutor  ³Vendas Clientes     º Data ³  06/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo responsavel pela abertura da porta serial.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Numero da porta COM (nao utilizado)						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto LJCRetornoEcf										  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method AbrirPorta(cPorta) Class LJANfDaruma
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({DARUMANF,"rStatusImpressora_DUAL_DarumaFramework"}) 
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)    
    
 	//Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} LJANfDaruma
Método responsável pelo retorno do status da impressora.     
@author  	Varejo
@version 	P11.8
@since   	13/02/2017
@sample
@return  	oRetorno
/*/
//-------------------------------------------------------- 
Method FechaPorta(cPorta) Class LJANfDaruma
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({DARUMANF,"rStatusImpressora_DUAL_DarumaFramework"}) 
    
	//Envia o comando
	cRetorno := ::EnviarCom(oParams)    
    
 	//Trata o retorno
	oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InicVar   ºAutor  ³Vendas Clientes     º Data ³  06/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo responsavel em inicializar variaveis                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto LJCRetornoEcf										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method InicVar() Class LJANfDaruma

	::oFormasVen := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AbrirPortaºAutor  ³Vendas Clientes     º Data ³  06/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo responsavel pela abertura da porta serial.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Numero da porta COM (nao utilizado)						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto LJCRetornoEcf										  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method StImp() Class LJANfDaruma 
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({DARUMANF,"regPortaComunicacao_DUAL_DarumaFramework"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
        
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³ImpTextoNf       ºAutor  ³Vendas Clientes     º Data ³  05/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel por enviar texto a impresora						     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja 			                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1 (1 - cTexto) - Modelo do ecf selecionado.		   	         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto														     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method ImpTextoNf(cTexto) Class LJANfDaruma 
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao      
	Local cTxtAux	:= cTexto
	Local cTxtAux_1 := ""	
	Local cCmdCorre := ""           //comando de correção quando utilizado QrCode
	Local nPos		:= 0
	Local nPosCodBar:= 0			//Codigo de barras
	Local lUseSat	:= LjUseSat()  //Utiliza SAT
	Local aTextoImp := {}	

	Default cTexto	:= ""
	
	//Insere a Tag que define o tamanho do QrCode na Daruma
	nPos := At(TAG_QRCODE_INI,cTxtAux)
	If nPos > 0	//codigo do tipo QRCODE
		cCmdCorre := TAG_NIVELQRCD_INI + "M" + TAG_NIVELQRCD_FIM
		cTxtAux := StrTran(cTxtAux,TAG_QRCODE_FIM,cCmdCorre+TAG_QRCODE_FIM)		
	EndIf
	
	If lUseSAT
		nPosCodBar := At(TAG_COD128_INI,cTxtAux)
		If nPosCodBar > 0
			cCmdCorre := "<w2><h50>"
			cTxtAux := Stuff(cTxtAux,nPosCodBar+Len(TAG_COD128_INI),0,cCmdCorre)
			
			cCmdCorre := "</h50></w2>"
			nPosCodBar := At(TAG_COD128_FIM,cTxtAux)
			cTxtAux := Stuff(cTxtAux,nPosCodBar,0,cCmdCorre)
			
			//Centralizar
			cTxtAux := "<ce>" + cTxtAux + "</ce>"
		EndIf
	EndIf	
    
    //Tratamento para nao enviar Tag <fe> quando NFC-e, a inclusao da Tag <fe> causa conflito em conjunto com demais Tags utilizadas na NFC-e
	If cTexto == "<GUI></GUI>"
		oParams		:= ::PrepParam({DARUMANF,"iImprimirTexto_DUAL_DarumaFramework",  TAG_GUIL_INI+TAG_GUIL_FIM, "0"})
	Else
		If Len(cTxtAux) >= 12000
			cTxtAux_1 := ""
			aTextoImp := {}
			nPos := At(CHR(10),cTxtAux)
			
			While nPos > 0
				nPos	:= At(CHR(10),cTxtAux)
				cTxtAux_1+= Substr(cTxtAux,1,nPos)
				cTxtAux	 := Substr(cTxtAux,nPos+1,Len(cTxtAux)) 
				cTxtAux_1:= cTxtAux_1
				
				If Len(cTxtAux_1) >= 5000
					Aadd(aTextoImp,cTxtAux_1)
					cTxtAux_1 := ""
				EndIf
			EndDo
			
			If Len(cTxtAux_1) > 0
				Aadd(aTextoImp,cTxtAux_1)
			EndIf

			For nPos:= 1 to Len(aTextoImp)
				oParams	 := ::PrepParam({DARUMANF,"iImprimirTexto_DUAL_DarumaFramework", aTextoImp[nPos], "0"})
				cRetorno := ::EnviarCom(oParams)
			Next nX
			
			oParams := NIL
		EndIf
		
		If !Empty(cTxtAux)
			oParams	:= ::PrepParam({DARUMANF,"iImprimirTexto_DUAL_DarumaFramework", cTxtAux, "0"})
		EndIf
    EndIf
	
	If oParams <> NIL
		cRetorno := ::EnviarCom(oParams)
		oRetorno := ::TratarRet(cRetorno)
	Else
		oRetorno := ::TratarRet("1") //Resultado sem erro
	EndIf
    
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CarregMsg ºAutor  ³Vendas Clientes     º Data ³  06/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo responsavel pelo carregamento das mensagens de    	  º±±
±±º          ³resposta possiveis da impressora.			  		  	  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nenhum													  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³nenhum													  º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method CarregMsg() Class LJANfDaruma
	::AdicMsgECF("0", "Erro interno", ERRO)
	::AdicMsgECF("1", "Resultado sem erro", OK)
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºMetodo    ³ImpCodeBar      ºAutor  ³Varejo				   º Data ³  31/10/13º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel por imprimir codigo de barras na impressora	    	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja 			                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPC1 (1 - cTexto) - Tipo do Codigo de barras		   	         	 º±±
±±ºParametros³EXPC1 (1 - cTexto) - Conteudo do codigos de barras.			   	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto														     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Method ImpCodeBar(cTipo,cTexto) Class LJANfDaruma 
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cTextoAux 	:= ""			
	Local cComando	:= ""
	Local nLen			:= 0
	Local lConfigDef	:= .T.

	Default cTexto	:= ""
	Default cTipo		:= ""
	
	cTextoAux := cTexto
	
	If cTipo == TAG_COD128_INI

		cComando := "ImprimeCodigoBarrasCODE128"

		//Como a largura padrão é 1, a qtde de caracteres do codbar é 28
		nLen	:= Len(cTextoAux)
		If nLen > 28
			cTextoAux := Substr(cTextoAux,1,28)
		EndIf
		
	ElseIf cTipo == TAG_UPCA_INI
		cComando := "ImprimeCodigoBarrasUPCA" 
		      
	ElseIf cTipo == "UPCE"
		cComando := "ImprimeCodigoBarrasUPCE"
		
	ElseIf cTipo == TAG_EAN13_INI

		cComando := "ImprimeCodigoBarrasEAN13"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 9
		nLen	:= Len(cTextoAux)
		If nLen > 12
			cTextoAux := Substr(cTextoAux,1,12)
		EndIf
		
	ElseIf cTipo == TAG_EAN8_INI

		cComando := "ImprimeCodigoBarrasEAN8"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 9
		nLen	:= Len(cTextoAux)
		If nLen > 7
			cTextoAux := Substr(cTextoAux,1,7)
		EndIf
		
	ElseIf cTipo == TAG_CODE39_INI
		
		cComando := "ImprimeCodigoBarrasCODE39"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 9
		nLen	:= Len(cTextoAux)
		If nLen > 9
			cTextoAux := Substr(cTextoAux,1,9)
		EndIf
		
	ElseIf cTipo == TAG_CODE93_INI
	
		cComando := "ImprimeCodigoBarrasCODE93"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 9
		nLen	:= Len(cTextoAux)
		If nLen > 9
			cTextoAux := Substr(cTextoAux,1,9)
		EndIf
		
	ElseIf cTipo == TAG_ITF
		
		cComando := "ImprimeCodigoBarrasITF"
		
	ElseIf cTipo == TAG_CODABAR_INI
		
		cComando:= "ImprimeCodigoBarrasCODABAR"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 12
		nLen	:= Len(cTextoAux)
		If nLen > 12
			cTextoAux := Substr(cTextoAux,1,12)
		EndIf
		
	ElseIf cTipo == TAG_ISBN
		cComando := "ImprimeCodigoBarrasISBN"

	ElseIf cTipo == TAG_MSI_INI

		cComando := "ImprimeCodigoBarrasMSI"
		//Como a largura padrão é 1, a qtde de caracteres do codbar é 10
		nLen	:= Len(cTextoAux)
		If nLen > 10
			cTextoAux := Substr(cTextoAux,1,10)
		EndIf
		
	ElseIf cTipo == TAG_PLESSEY
		cComando := "ImprimeCodigoBarrasPLESSEY"
		
	ElseIf cTipo == TAG_QRCODE_INI
	    cComando := "ImprimeCodigoQRCODE"
		lConfigDef := .F.
		
	ElseIf cTipo == TAG_PDF_INI
		cComando := "ImprimeCodigoBarrasPDF147"
		lConfigDef := .F.
		
	Else
		oRetorno := NIL
	EndIf
	
	oRetorno := ::VerPapel()
	
	If oRetorno:cAcao == OK
		oRetorno	:= Nil
		
		//Prepara os parametros de envio
		oParams := ::PrepParam({DARUMANF,"iImprimirTexto_DUAL_DarumaFramework",  "<fe>"+cTexto+"</fe>", "0"})
			
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    //Trata o retorno
	    oRetorno := ::TratarRet(cRetorno)
		
    EndIf
    
Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do comando de abrir gaveta
@param   Sem parametro
@author  Varejo
@version P11.8
@since   09/12/2014
@return  oRetorno
/*/
//-------------------------------------------------------
Method AbrirGavet() Class LJANfDaruma
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial

oParams := ::PrepParam({DARUMANF,"iAcionarGaveta_DUAL_DarumaFramework"})

//Envia o comando
cRetorno := ::EnviarCom(oParams)

//Trata o retorno
oRetorno := ::TratarRet(cRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do comando de corte de papel
@param   Sem parametro
@author  Varejo
@version P11.8
@since   30/03/2016
@return  oRetorno
/*/
//-------------------------------------------------------
Method CortaPapel() Class LJANfDaruma
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial

oParams	:= ::PrepParam({DARUMANF,"iImprimirTexto_DUAL_DarumaFramework",  TAG_GUIL_INI+TAG_GUIL_FIM, "0"})
cRetorno:= ::EnviarCom(oParams)
oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do comando para impressao de arquivo .BMP
@param   
  cArquivo: contem o caminho e o nome do arquivo .BMP que 
            será impresso  
@author  Varejo
@version P11.8
@since   09/12/2014
@return  oRetorno
/*/
//-------------------------------------------------------
Method ImpBitMap(cArquivo) Class LJANfDaruma
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

Default cArquivo	:= ""
    
oRetorno := NIL
    	
//cArquivo : caminho com nome do arquivo com extensão .bmp / "0" : refere-se a orientação da imagem a ser impressa, neste caso retrato
oParams		:= ::PrepParam({DARUMANF,"iImprimirBMP_DUAL_DarumaFramework", cArquivo}) 		
cRetorno 	:= ::EnviarCom(oParams)
oRetorno	:= ::TratarRet(cRetorno)

Return oRetorno
