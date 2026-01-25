#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"          
#INCLUDE "LJCTransPaymentHub.CH"  

Function LJCTransPaymentHub ; Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCTransPaymentHub
Responsavel em processar as informacoes comuns das transacoes do Payment Hub

@type       Class
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCTransPaymentHub

	Data oPaymentHub					//Objeto do tipo LJCComPaymentHub
	Data cSimbMoeda                 	//Simbolo da moeda corrente
	
	Method New()
	Method TratarRet()
	Method TratPad()
    Method Confirmar()
    Method Desfazer()
	Method CarregCup()
	Method MontaCup()
	Method ReceiptToArr()
	Method DecodeReceipt()

EndClass         

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJCTransPaymentHub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return Self, Objeto, Objeto de representação da classe LJCTransPaymentHub.
/*/
//-------------------------------------------------------------------------------------
Method New(oPaymentHub) Class LJCTransPaymentHub

	Self:oPaymentHub := oPaymentHub
    
	Self:cSimbMoeda := SuperGetMV("MV_SIMB1")

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TratarRet
Trata e cria os objetos de retorno.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oDadosTran, Objeto, Objeto representando os dados da transação.

@return oDadosTran, Objeto, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method TratarRet(oDadosTran) Class LJCTransPaymentHub
	
Local oRetPayHub := Nil				//Objeto do tipo LJCRetornoPayHub

//Armazena o retorno do Payment Hub
oRetPayHub := Self:oPaymentHub:GetRetorno()

Do Case

	Case oDadosTran:nTipoTrans == _CREDITO .OR.	oDadosTran:nTipoTrans == _DEBITO .OR. oDadosTran:nTipoTrans == _PAGDIGPIX
		 
		//Cria o objeto de retorno para cartao
		oDadosTran:oRetorno := LJCRetTransacaoCCCD():New()
		
		//Alimenta os dados padrao do retorno
		Self:TratPad(@oDadosTran, @oRetPayHub)
		 
		oDadosTran:oRetorno:cAdmFin					:= oRetPayHub:cAdmFin 
		oDadosTran:oRetorno:lJurosLoja				:= oRetPayHub:lJurosLoja			        
		oDadosTran:oRetorno:cTipCart    			:= oRetPayHub:cInstit
		oDadosTran:oRetorno:aAdmin					:= aClone( oRetPayHub:aAdmin ) 
		oDadosTran:oRetorno:nParcs					:= oRetPayHub:nParcelas
		oDadosTran:oRetorno:cCodBand 				:= oRetPayHub:cTpCartao
		oDadosTran:oRetorno:cIdtransaction 			:= oRetPayHub:cIdtransaction
		oDadosTran:oRetorno:cProcessorTransactionId	:= oRetPayHub:cProcessorTransactionId
		oDadosTran:oRetorno:cExternalTransactionId	:= oRetPayHub:cExternalTransactionId

	Case oDadosTran:nTipoTrans == _ADMINISTRATIVA
    	
    	//Cria o objeto de retorno para funcoes administrativa
		oDadosTran:oRetorno := LJCRetTransacaoADM():New()

		//Alimenta os dados padrao do retorno
		Self:TratPad(@oDadosTran, @oRetPayHub)
    	
EndCase

Return oDadosTran

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TratPad
Trata o retorno padrao das transacoes Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@param oDadosTran, Objeto, Objeto representando os dados da transação.
@param oRetPayHub, Objeto, Objeto do tipo LJCRetornoPayHub

@return Nulo, Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method TratPad(oDadosTran, oRetPayHub) Class LJCTransPaymentHub

	oRetPayHub:cViaCliente          := Self:MontaCup(oRetPayHub:aViaCliente) 
	oRetPayHub:cViaCaixa            := Self:MontaCup(oRetPayHub:aViaCaixa) 
	oDadosTran:oRetorno:oViaCliente := Self:CarregCup(oRetPayHub:cViaCliente)
	oDadosTran:oRetorno:oViaCaixa   := Self:CarregCup(oRetPayHub:cViaCaixa)

	oDadosTran:oRetorno:lTransOK    := oRetPayHub:lTransOK
	oDadosTran:oRetorno:dData       := oRetPayHub:dData
	oDadosTran:oRetorno:cHora       := oRetPayHub:cHora
    oDadosTran:oRetorno:cAutoriz    := oRetPayHub:cCodAuto
	oDadosTran:oRetorno:cViaCaixa   := oRetPayHub:cViaCaixa
	oDadosTran:oRetorno:cViaCliente := oRetPayHub:cViaCliente
	oDadosTran:oRetorno:cNsu        := oRetPayHub:cNsuPayHub
	oDadosTran:oRetorno:cNsuAutor   := oRetPayHub:cNsuAuto
	oDadosTran:oRetorno:cRede       := oRetPayHub:cRede
	oDadosTran:oRetorno:cDocCanc    := oRetPayHub:cDocCanRei
	oDadosTran:oRetorno:dDataCanc   := oRetPayHub:dDataCanRei
	
	If UPPER(oRetPayHub:cErrorReason) == "BUSY" 
		oDadosTran:oRetorno:cErrorReason := STR0001 // -- "Terminal ocupado."
	ElseIf UPPER(oRetPayHub:cErrorReason) == "CANCEL" 
		oDadosTran:oRetorno:cErrorReason := STR0002 // -- "Cancelado pelo terminal ou tempo esgotado."
	ElseIf !Empty(oRetPayHub:cErrorReason)
		oDadosTran:oRetorno:cErrorReason := oRetPayHub:cErrorReason
	EndIf 

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Confirmar
Confirmar as operacoes pendentes.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oTransacao, Objeto, Objeto representando os dados da transação.

@return Nulo, Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method Confirmar(oTransacao) Class LJCTransPaymentHub 
	
	Local nCount := 0
		
	For nCount := 1 To oTransacao:Count()
	    //Seta a transacao
		Self:oPaymentHub:SetTrans(oTransacao:Elements(nCount))
	    //Confirma a transacao
		Self:oPaymentHub:FinTrans(1)
	Next
	
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Desfazer
Desfaz as operacoes pendentes.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oTransacao, Objeto, Objeto representando os dados da transação.

@return Nulo, Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method Desfazer(oTransacao) Class LJCTransPaymentHub 
   	
	Local nCount := 0				//Variavel auxiliar contador
		
	For nCount := 1 To oTransacao:Count()
	    //Seta a transacao
		Self:oPaymentHub:SetTrans(oTransacao:Elements(nCount))
	    //Desfaz a transacao
		Self:oPaymentHub:FinTrans(0)
	Next
   	
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregCup
Carrega o cupom do Payment Hub no objeto LJCList.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param cRetCupom, Caractere, Informação do comprovante da transação.

@return oCupom, Objeto, Objeto representando os dados do comprovante da transação.
/*/
//-------------------------------------------------------------------------------------
Method CarregCup(cRetCupom) Class LJCTransPaymentHub
	
	Local oCupom 	:= LJCList():New()	//Objeto do tipo LJCList para armazenar o espelho do cupom de TEF
	Local cDelimit 	:= CHR(10)			//Delimitador
	Local lLoop		:= .T.
	Local nPos		:= 0
	Local cAux		:= ""
			
	While lLoop
	    //Procura o delimitador na string
		nPos := At(cDelimit, cRetCupom)
	    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			cAux := Substr(cRetCupom, 1, nPos-1)
			cRetCupom := Substr(cRetCupom, nPos + 1)
			
			If cAux != cDelimit
				oCupom:Add(cAux)
			Endif
		Else
			If !Empty(cRetCupom)
				oCupom:Add(cRetCupom)
			EndIf
			
			lLoop := .F.
		EndIf
	End    
	
Return oCupom

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCup
Monta o comprovante da transação do Payment Hub formatado.

@type       Method
@author     JMM
@since      30/07/2020
@version    12.1.27

@param aCupom, Array, Dados do Comprovante retornado da API do Payment Hub.

@return cRet, Caractere, Comprovante da transação do Payment Hub formatado.
/*/
//-------------------------------------------------------------------------------------
Method MontaCup(aCupom) Class LJCTransPaymentHub
	
	Local cRet 			:= ""
	Local aViaComprv 	:= {}
	Local cLinha        := ""
	Local nCols         := IIF( !Empty(LjGetStation("LG_LARGCOL")), LjGetStation("LG_LARGCOL"), 40 )
	Local nEspCentro    := nCols
	Local nX			:= 0
	Local nY			:= 0
	Local cDelimit 		:= CHR(10) //Delimitador
	Local cProperty		:= ""

    // Formata o Array
    aViaComprv := Self:ReceiptToArr( aCupom )

    // Faz o Decode
    aViaComprv := Self:DecodeReceipt( aViaComprv )

	For nX := 1 To Len(aViaComprv)

		For nY := 1 To Len(aViaComprv[nX])

			cProperty := Upper(AllTrim(aViaComprv[nX][nY][01]))

			Do Case

				Case cProperty == "KEY"
					cLinha := " " + cDelimit

				Case cProperty == "NAME"
					If Upper(AllTrim(aViaComprv[nX][nY+1][01])) == "KEY"
						cLinha += PadC( aViaComprv[nX][nY][02], nCols )
					Else
						cLinha += aViaComprv[nX][nY][02]
						nEspCentro := nEspCentro - Len(aViaComprv[nX][nY][02])
					EndIf
				
				Case cProperty == "VALUE"
					nEspCentro  := nEspCentro - Len(aViaComprv[nX][nY][02])
					cLinha      += Space(nEspCentro) + aViaComprv[nX][nY][02]
					nEspCentro  := nCols
				
			EndCase

			cRet        += cLinha
			cLinha      := ""

		Next nY

	Next nX

	If !Empty(cRet)
		cRet += + CHR(10) + CHR(13)
		cRet += + CHR(10) + CHR(13)
	EndIf

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReceiptToArr
Formata o retorno das informações do comprovante e retorna em array.

@type       Method
@author 	JMM
@since 		27/07/2020
@version 	12.1.27

@param aReceipt, Array, Array com o retorno da via que se deseja imprimir.

@return aRet, Array, Array formatado com as informações do comprovante.
/*/
//-------------------------------------------------------------------------------------
Method ReceiptToArr(aReceipt) Class LJCTransPaymentHub
Local aRet  	:= {}
Local aLinha 	:= {}
Local nX		:= 0
Local nY		:= 0

For nX := 1 To Len(aReceipt)
	aLinha := StrTokArr( aReceipt[nX]:GetJsonText("text"), "&" )

	For nY := 1 To Len(aLinha)
		aLinha[nY] := StrTokArr( aLinha[nY], "=" )
	Next nY

	AADD(aRet, aLinha)
Next nX

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} DecodeReceipt
Efetua a decodificação do texto enviado no comprovante da transação.

@type       Method
@author 	JMM
@since 		27/07/2020
@version 	12.1.27

@param aReceipt, Array, Array com o texto a ser decodificado.

@return aReceipt, Array, Array com o texto decodificado.
/*/
//-------------------------------------------------------------------------------------
Method DecodeReceipt(aReceipt) Class LJCTransPaymentHub
Local nX	:= 0
Local nY	:= 0

For nX := 1 To Len(aReceipt)
	If Len(aReceipt[nX]) > 1

        For nY := 1 To Len(aReceipt[nX])
            If Upper(AllTrim(aReceipt[nX][nY][01])) == "NAME" .OR. Upper(AllTrim(aReceipt[nX][nY][01])) == "VALUE"
                aReceipt[nX][nY][02] := FWURIDecode( UnEscape( aReceipt[nX][nY][02] ) )
                aReceipt[nX][nY][02] := LjDecUTF8(aReceipt[nX][nY][02])
            EndIf
        Next nY

    EndIf
Next nX

Return aReceipt

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjDecUTF8
Trata caracteres especiais padrão UTF8, pois a função FWURIDecode do Frame não trata tudo.
*** Quando a função do frame estiver tratando tudo, essa função LjDecUTF8 poderá ser excluida.

@type  		Function
@author 	JMM
@since 		27/07/2020
@version 	12.1.27

@param cString, Caracter, String a ser tratada.

@return cRet, Caracter, String tratada.
/*/
//-------------------------------------------------------------------------------------
Static Function LjDecUTF8(cString)
Local cRet 			:= ""
Local nX 			:= 0
Local aListaUtf8 	:= { {"%2F","/"} , {"%3A",":"} , {"%2f","/"} , {"%3a",":"} }

For nX := 1 To Len(aListaUtf8)
    cRet := StrTran(cString, aListaUtf8[nX][01], aListaUtf8[nX][02])
    If cRet <> cString
        Exit
    EndIf
Next nX

Return cRet
