#INCLUDE "Protheus.ch"
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"     
#INCLUDE "STPOS.CH"
#INCLUDE "STBPAYMULTINEG.CH"

Static cPicDefault		:= "@E 9,999,999.99"	//Picture padrao para valores

#DEFINE POS_TIPO		1						// Tipo						
#DEFINE POS_QTDPARC	 	2						// Quantidade de Parcelas
#DEFINE POS_VLRPARC		3						// Valor Parcela
#DEFINE POS_VLRTOT 		4						// Valor Total
#DEFINE POS_VLRVEN 		5						// Valor até Vencimento
#DEFINE POS_ACRESC 		6						// Acrescimo
#DEFINE POS_VENCIM 		7						// Data Vencimento

//-------------------------------------------------------------------
/*{Protheus.doc} STBSimulMultiNeg
Acao para simular a Multi-Negociação

@param   	oListPayForms	- ListBox da Forma de Pagamento
@param 		oListDownPay	- Objeto ListBox de Entrada > Multi Negociacao
@param 		aTypeDown		- Conteudo dos tipos de Entrada
@param 		oDownPay		- Objeto Get correspondente a Entrada
@param 		nDownPay		- Valor correspondente a Entrada
@param 		aLblPayForms	- Representa os Labels da Forma de Pagamento
@param 		oBtnSimul		- Botão de Simulação
@param 		nLblTotEntr		- Valor correspondente ao Total de Entrada
@param 		nLblRestante	- Valor correspondente ao Valor Restante da Venda
@param 		aTpDownPay		- Array com conteudo de 8 labels referentes a entrada
@param 		aResume			- Representa label: Entrada,Qtd.Parc,Vencimento,Valor,Acrescimo,Total,Forma,AdminFin,Desconto
@param 		nSpace			- Tamanho de espaco entre uma informacao e outra
@param   	nSaleVal		- Valor da Venda
@param   	aItens			- Array com os itens da venda
@param   	oMultNegoc		- Objeto de integração da Multinegociação
@param   	aBrwContent		- Conteudo do Browse da Direita
@param   	oBrwContent		- Objeto do Browse da Direita
@param   	lEvenDesc		- Define se acao tem origem do evento de desconto
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBSimulMultiNeg(	oListPayForms,	oListDownPay,	aTypeDown,		oDownPay,  		;
							nDownPay,  		aLblPayForms,	oBtnSimul,	   	nLblTotEntr,	;
							nLblRestante,	aTpDownPay,		aResume,		nSpace,	   		;
							nSaleVal,		aItens,			oMultNegoc,		aBrwContent,	;
							oBrwContent,	lEvenDesc)

Local nFor 			:= 0 	//Variavel do laço
Local oRetItem		:= NIL 	//Objeto de itens da multi-negociação 
Local cCodigo 		:= ""	//Codigo da Forma de Pagamento da Regra
Local nValParcel	:= 0	//Valor de cada Parcela recalculado

Default lEvenDesc	:= .F. //Define se acao tem origem do evento de desconto

If oListPayForms:nAt == 0
	Return NIL
EndIF

If !lEvenDesc //Se a acao nao tem origem do evento de desconto, atualiza as formas de pagamentos
	STDLblPayForms(oListPayForms,@aLblPayForms,@aTypeDown,nSpace,nSaleVal)
	STIAtuObjEntr(oListDownPay,aTypeDown,oDownPay,@nDownPay,aLblPayForms,oBtnSimul,@nLblTotEntr,@nLblRestante,@aTpDownPay,@aResume)
EndIf

// Caso Necessitar de Entrada e o Valor de Entrada digitado estiver MENOR que o Necessário, critica a operacao
If VAL(aLblPayForms[05]) <> 0 .AND. nLblTotEntr < VAL(aLblPayForms[05])
	STFMessage(ProcName(),"STOP",STR0001 + aLblPayForms[05] + ".") //"É necessário inserir Entrada Maior ou Igual a "
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())

	STIMnClRight(@aResume,aLblPayForms)
	Return NIL
EndIF

// Caso Necessitar de Entrada e o Valor de Entrada digitado estiver maior que a venda, critica a operacao
If VAL(aLblPayForms[05]) <> 0 .AND. nLblTotEntr > nSaleVal
	STFMessage(ProcName(),"STOP",STR0002) //"O valor de Entrada é maior que o valor da venda."
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
	
	STIMnClRight(@aResume,aLblPayForms)
	Return NIL
EndIF

STFMessage(ProcName(),"STOP",STR0003) //"Selecione ao lado uma Negociação e Confirme."
STFShowMessage(ProcName())	
STFCleanMessage(ProcName())
	
cCodigo := SubStr(oListPayForms:aItems[oListPayForms:nAt],(00000000)+1	,TamSx3("MBT_CODIGO")[1]) //

aParcels 	:= {}
aBrwContent	:= {}

If !EMPTY(aItens)

	If oMultNegoc:oDadosCab:Count() > 0
		oMultNegoc:SetValor(nSaleVal)
		
		If FindFunction("Frt060Ret")
			nNCCUsada := Frt060Ret("NCC_USADA")
			oMultNegoc:SetValNCC(nNCCUsada)
		EndIf	
		
		oRetItem := oMultNegoc:TratReIten(cCodigo)
		
		Lj764CalPar(oRetItem			, oListPayForms:nAt	, oMultNegoc:GetValor()	, nLblTotEntr	,;
					@oMultNegoc			, NIL				, @aParcels				, NIL			,;
					aLblPayForms[7][1]	, aResume[09]		, NIL					, NIL	 		,;
					aLblPayForms[1]		)
				
		If Len(aParcels) > 0
			aBrwContent := {}
			For nFor := 1 To Len(aParcels)
				nValParcel := ( Val(StrTran(StrTran(aParcels[nFor,POS_VLRTOT],",",""),".",""))/100 ) / aParcels[nFor,POS_QTDPARC]
				aAdd(aBrwContent,{ ;
					STRZERO(nFor,2) +"-"+ aParcels[nFor,POS_TIPO]		, ;
					STRZERO(aParcels[nFor,POS_QTDPARC],2)				, ;
					Alltrim(Transform(nValParcel, cPicDefault))			, ;
					aParcels[nFor,POS_VLRTOT]  							, ;
					aParcels[nFor,POS_VLRVEN]  							, ;
					aParcels[nFor,POS_ACRESC]  							, ;
			   		DToC(aParcels[nFor,POS_VENCIM])						})
			Next nFor
			oBrwContent:SetArray(aBrwContent)
			oBrwContent:bLine := {||{	aBrwContent[oBrwContent:nAT,POS_TIPO]		,;
										aBrwContent[oBrwContent:nAT,POS_QTDPARC]	,;
										aBrwContent[oBrwContent:nAT,POS_VLRPARC]	,;  
										aBrwContent[oBrwContent:nAT,POS_VLRTOT]		,;
										aBrwContent[oBrwContent:nAT,POS_VLRVEN]		,;
										aBrwContent[oBrwContent:nAT,POS_ACRESC]		,;
										aBrwContent[oBrwContent:nAT,POS_VENCIM]		}}
			oBrwContent:Refresh() 
			
		EndIf
	
	Else
		oMultNegoc := Nil  
	EndIf
EndIf

Return NIL

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STBMnAjustItens
Retornar estrutura para aItens

@param   	aColsItens 	- Coluna dos Itens
@param   	aHeadItens 	- Cabecalho dos Itens
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	aRet
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STBMnAjustItens(aColsItens,aHeadItens)
Local aRet	:= {}	//Variavel de Retorno
Local nFor	:= 0	//Variavel do Laço

For nFor := 1 TO LEN(aColsItens)
	aAdd(aRet,{					   		;
		Val(aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ITEM'} )	]) 	,	;	// Item
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_PRODUTO'} )	]  	,	;	// Cod Produto
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_PRODUTO'} )	] 	,	;	// Cod Barras
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_DESCRI'} )	] 	,	;	// Descricao
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_QUANT'} )	] 	,	;	// Quantidade
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VRUNIT'} )	] 	,	;	// Vlr Unit
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VLRITEM'} )	] 	,	;	// Vlr Item
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VALDESC'} )	] 	,	;	// Vlr Desconto
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_SITTRIB'} )	]  	,	;	// Aliquota
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_VALIPI'} )	]	,	;	// IPI
		.F.																	,	;	
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ICMSRET'} )	] 	,	;	// Valor Icms retido
		aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_BRICMS'} )	]	,	;	// Deducao Icms
		Val(aColsItens[nFor][aScan( aHeadItens,{|x| x[2]=='L2_ITEM'} )	]) 	,	;	// Cod. ANVISA
		aColsItens[nFor][LEN(aColsItens[nFor])] 	   								,	;	// .F.
		aColsItens[nFor][LEN(aColsItens[nFor])-1]   									;	// .T.
		})
Next nFor

Return aRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STBAtuLblEntr
Alimenta os labels relacionados a Entradas

@param   	oListDownPay	- Objeto ListBox de Entrada > Multi Negociacao
@param   	aTpDownPay		- Array com conteudo de 8 labels referentes a entrada
@param   	oDownPay		- Objeto Get correspondente a Entrada
@param   	nDownPay		- Valor correspondente a Entrada
@param   	nLblTotEntr		- Valor correspondente ao Total de Entrada
@param   	nLblRestante	- Valor correspondente ao Valor Restante da Venda
@param   	nSaleVal		- Valor da Venda
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STBAtuLblEntr(	oListDownPay,aTpDownPay,oDownPay,nDownPay,nLblTotEntr,nLblRestante,nSaleVal )

Local cTipoEntr		:= ""										//Tipo de Entrada
Local nFor			:= 0										//Variavel de Laço
Local nTotalEntr	:= 0										//Total de Entradas
Local nPosAt		:= 0										//Posicao do traco
Local lAchou 		:= .F.										//Corresponde se achou entrada identica

If oListDownPay:nAt > 0
	cTipoEntr := oListDownPay:aItems[oListDownPay:nAt]
EndIf

If EMPTY(cTipoEntr)
	Return NIL
EndIF

cTipoEntr 	:= AllTrim( SubStr(cTipoEntr,At("-",cTipoEntr)+1,LEN(cTipoEntr)) )
nTotalEntr 	:= 0

// Se achar um label com o mesmo Tipo de Entrada, altera o valor na mesma casa
For nFor := 1 To Len(aTpDownPay)		
	If !EMPTY(aTpDownPay[nFor][01])
		nPosAt := At("-",aTpDownPay[nFor][01])
		If nPosAt > 0
			If AllTrim(SubStr(aTpDownPay[nFor][01],1,nPosAt-1)) == cTipoEntr				
				aTpDownPay[nFor][01] := cTipoEntr +" - "+ Alltrim(Transform(nDownPay, cPicDefault))
				If EMPTY(aTpDownPay[nFor][01])
					aTpDownPay[nFor][02] := ALLTRIM( SUBSTR( oListDownPay:aItems[oListDownPay:nAt],1,At("-",oListDownPay:aItems[oListDownPay:nAt])-1 ) )
				EndIf
				// Soma ao total de Entradas
				nTotalEntr += nDownPay
				lAchou := .T.
			Else
				// Apenas soma ao total de Entradas
				nTotalEntr += Val( SubStr(aTpDownPay[nFor][01],nPosAt+1,LEN(aTpDownPay[nFor][01])) )				
			EndIf			
		EndIf
	EndIf
Next nFor

// Se não achou um label com o mesmo Tipo de Entrada, adiciono um novo na proxima casa
If !lAchou
	// Caso Necessitar de Entrada e o Valor de Entrada digitado estiver MENOR que o Necessário, critica a operacao
	If nDownPay == 0
		STFMessage(ProcName(),"STOP",STR0004) //"É necessário inserir a Entrada."
		STFShowMessage(ProcName())	
		STFCleanMessage(ProcName())
		oDownPay:SetFocus()
		Return NIL
	EndIF
	
	For nFor := 1 To Len(aTpDownPay)
		If EMPTY(aTpDownPay[nFor][01])
			aTpDownPay[nFor][01] := cTipoEntr +" - "+ Alltrim(Transform(nDownPay, cPicDefault))
			aTpDownPay[nFor][02] := ALLTRIM( SUBSTR( oListDownPay:aItems[oListDownPay:nAt],1,At("-",oListDownPay:aItems[oListDownPay:nAt])-1 ) )
			// Soma ao total de Entradas
			nTotalEntr += nDownPay
			Exit
		EndIF
	Next nFor
	
EndIf

nLblTotEntr 	:= nTotalEntr
nLblRestante	:= nSaleVal - nTotalEntr

Return NIL

