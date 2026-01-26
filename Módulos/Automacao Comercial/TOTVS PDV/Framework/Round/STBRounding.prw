#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cImpressora	:= ""	//Impressora utilizada  	

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRound
Arredonda a parte decimal do valor especificado no parametro de 
acordo com a quantidades de casas decimais solicitadas, ou
se não for passado usa padrao do sistema

@param   nValue			Valor para arredondar
@param   nDecimal		Quantidade de casas decimais para arredondar
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nValue - Retorna um valor passado por parametro arredondando
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRound( nValue ,	nDecimal )

Default nValue   := 0										//Valor para arredondar
Default nDecimal := MsDecimais(STBGetCurrency())		//Quantidade de casas decimais para arredondar

ParamType 0 Var nValue	 	AS Numeric	Default 0
ParamType 1 Var nDecimal 	AS Numeric	Default MsDecimais(STBGetCurrency())

nValue := Round(	nValue ,	nDecimal )
		
Return nValue


//-------------------------------------------------------------------
/*/{Protheus.doc} STBNoRound
Retorna um valor, truncando a parte decimal do valor especificado no 
parametro de acordo com a quantidade de casas decimais solicitadas

@param   nValue			Valor para arredondar
@param   nDecimal		Quantidade de casas decimais para arredondar
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nValue - Retorna um valor passado por parametro arredondando
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBNoRound( nValue ,	nDecimal )
 
 Default nValue   := 0									//Valor para arredondar
Default nDecimal := MsDecimais(STBGetCurrency())		//Quantidade de casas decimais para arredondar

ParamType 	0 Var nValue	 	AS Numeric	Default 0
ParamType 	1 Var nDecimal 	AS Numeric	Default MsDecimais(STBGetCurrency())

nValue := NoRound(	nValue ,	nDecimal )
		
Return nValue



//-------------------------------------------------------------------
/*/{Protheus.doc} STBRoundNoRound
Trunca a parte decimal do valor especificado no parametro de 
acordo com a quantidade de casas decimais solicitadas e depois 
arredonda o valor truncado.

@param   nValue			Valor para arredondar
@param   nRDecimal		Quantidade de casas decimais para arredondar
@param   nTDecimal		Quantidade de casas decimais para truncar
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nValue - Retorna um valor passado por parametro arredondando
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRoundNoRound( nValue ,	nRDecimal , nTDecimal )
 
Default  nValue   	:= 0									//Valor para arredondar
Default  nRDecimal 	:= MsDecimais(STBGetCurrency())		//Quantidade de casas decimais para arredondar
Default  nTDecimal 	:= MsDecimais(STBGetCurrency())		//Quantidade de casas decimais para truncar

ParamType 0 Var nValue	 	AS Numeric		Default 0
ParamType 1 Var nRDecimal 	AS Numeric		Default MsDecimais(STBGetCurrency())
ParamType 2 Var nTDecimal 	AS Numeric		Default MsDecimais(STBGetCurrency())

// Trunca
nValue :=  NoRound( nValue , nTDecimal )


// Arredonda o valor ja truncado
nValue :=  Round( nValue 	, 	nRDecimal	)
		
Return nValue


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRoundCurrency
Trunca a parte decimal do valor especificado no parametro de 
acordo com a quantidade de casas decimais solicitadas e depois 
arredonda o valor truncado.

@param nValue 			Valor a ser arredondado
@param nMoedaIni		Moeda de partida	
@param nMoedaFinal		Moeda de destino	
@param dData 			Data base da Conversao
@param nCDecimal	 	Decimal para truncamento da Moeda
@param nTaxap 			Taxap	
@param nTaxad 			Taxad		
@param nRDecimal 		Decimal para arredondamento final da Moeda

@author  Varejo
@version P11.8
@since   23/05/2012
@return  nValue - Retorna um valor passado por parametro arredondando
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRoundCurrency( nValue 		, nMoedaIni 	, nMoedaFinal	, 	dData 		,;
								nCDecimal		, nTaxap	 	, nTaxad		,	nRDecimal  )
 

Default nValue 			:=	0									//	Valor a ser arredondado
Default nMoedaIni 		:=	1 									//	Moeda de partida	
Default nMoedaFinal		:=	1 									//	Moeda de destino	
Default dData 			:=	dDataBase							//	Data base da Conversao
Default nCDecimal	 	:=  MsDecimais(STBGetCurrency())	//	Decimal para truncamento da Moeda
Default nTaxap 			:=  0									//	Taxap	 	
Default nTaxad 			:=  0									//	Taxad 		
Default nRDecimal 		:=  MsDecimais(STBGetCurrency())	//	Decimal para arredondamento final da Moeda
	
	
ParamType 0 Var nValue	 	AS Numeric		Default 0
ParamType 1 Var nMoedaIni 	AS Numeric		Default 1
ParamType 2 Var nMoedaFinal	AS Numeric		Default 1
ParamType 3 Var dData	 	AS Date		Default dDataBase
ParamType 4 Var nCDecimal 	AS Numeric		Default MsDecimais(STBGetCurrency())
ParamType 5 Var nTaxap 		AS Numeric		Default 0
ParamType 6 Var nTaxad 		AS Numeric		Default 0
ParamType 7 Var nRDecimal 	AS Numeric		Default MsDecimais(STBGetCurrency())
	

// Converte valor na moeda atual para moeda solicitada
nValue 		:= 	xMoeda( 	nValue 		, nMoedaIni 	, nMoedaFinal	, 	dData 		,;
								nCDecimal		, nTaxap	 	, nTaxad						)

// Arredonda o valor ja convertido anteriormente
nValue 		:=  Round( 	nValue 	, 	nRDecimal )
		
Return nValue


//-------------------------------------------------------------------
/*/{Protheus.doc} STBArred
Arredonda ou trunca o valor de acordo com o campo e a configuracao

@param nValue 		Valor a ser arredondado
@param nDecimal		Quantidade de casas decimais para arredondar
@param cField			Campo de referencia para arredondamento
@param cRound			Define se Arredonda ou Trunca valor
@author  Varejo
@version P11.8
@since   23/05/2012
@return  nValue - Retorna um valor passado por parametro arredondando
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBArred( 	nValue	, nDecimal , cField , cRound )
Local aArea    	:= GetArea()							// Guarda area 
Local aAreaSX3 	:= SX3->(GetArea())						// Guarda area SX3 
Local nDecimal 	:= 0									// Quantidade de casas decimais para arredondar
Local cRound	:= ""									// Armazena configuração se Arredonda ou trunca valores

Default nValue		:= 0								// Valor para arredondar
Default	nDecimal	:= 0								// Quantidade de casas decimais para arredondar
Default cField		:= ""								// Campo de referencia para arredondamento
Default cRound		:= ""								// Define se Arredonda ou Trunca valor
	
If nDecimal <= 0
	If Empty(cField)
		nDecimal	:=	MsDecimais(STBGetCurrency())
	Else
		nDecimal 	:= TamSX3(cField)[2]
	EndIf
EndIf

If Empty(cRound)
	cRound := STBRuleArred()
EndIf

//Valida se a impressora irá tratar a regra
If STBImpRnd5()
	//Efetua arredondamento ou truncamento de acordo com o numero 5
	cRound := STBRound5(nValue,cRound) 
EndIf	

If cRound == "R"
	nValue := STBRound( nValue ,	nDecimal )
ElseIf cRound == "T"
	nValue := STBNoRound( nValue ,	nDecimal )
EndIf

//Retorna o estado de entrada
RestArea(aAreaSX3)
RestArea(aArea)

LjGrvLog("STBArred", "cRound ==", cRound )

Return nValue

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRuleArred
Determina configuração se Arredonda ou Trunca valores

@param 
@author  Varejo
@version P11.8
@since   23/05/2012
@return  cRound - Retorna configuração se trunca ou arredonda valores
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRuleArred()

Local cRound		:= ""		// Retorna se arredonda ou trunca valores
Local aDados		:= {"13", space(20)} // Pega Estatus 13 do ECF para saber se trunca ou arredonda

/*/
	Se utiliza impressora fiscal, utiliza o status da impressora
	Senão, utiliza parametro MV_ARREFAT
/*/
If STFUseFiscalPrinter()
	
	aRet := STFFireEvent( 	ProcName(0)			,; // Nome do processo
								"STPrinterStatus" 	,; // Nome do evento
								aDados 				)

	// 0-Arredonda 	1-Trunca 
	If aRet[1] == 1
		LjGrvLog( , "ECF-Trunca") 
		cRound := "T"
	Else
		LjGrvLog( , "ECF-Arredonda")
		cRound := "R"
	EndIf	

Else

	/*/
		Dependendo do parametro Arredonda ou Trunca o valor
	/*/
	If ( SuperGetMv("MV_ARREFAT") == "S" )
		cRound := "R"
	Else
		cRound := "T"
	EndIf
	
EndIf

Return cRound

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRound5
Rotina responsável por realizar tratamento quando o numero 5 for de decisão.
Casos:
- Se o algarismo decimal seguinte for menor que 5, o anterior não se modifica.
- Se o algarismo decimal seguinte for maior que 5, o anterior incrementa-se em uma unidade.
- Se o algarismo decimal seguinte for igual a 5, deve-se verificar o anterior, se ele for par não se modifica, 
  se ele for ímpar incrementa-se uma unidade.

Exemplos:
O número 12,652 seria arredondado para 12,65
O número 12,658 seria arredondado para 12,66
O número 12,865 seria arredondado para 12,86
O número 12,875 seria arredondado para 12,88

@param	 nValue 
@author  bruno.inoue
@version P11.8
@since   23/05/2017
@return  cRound - Se arredonda ou trunca
/*/
//-------------------------------------------------------------------
Function STBRound5(nValue,cCfgRndECF)
Local cRound	:= "R"			//Tipo Arredonda ou Trunca
Local nUltVal	:= 0			//Ultimo valor
Local nAntVal	:= 0			//Penultimo Valor
Local cValue	:= ""			//Numero convertido para caracter

Default nValue		:= 0
Default cCfgRndECF	:= "" //Deve ser deixado o default vazio pra não interferir, caso param não enviado

/*Deve considerar a regra de arredondamento/truncamento da impressora */ 
If !Empty(cCfgRndECF)
	cRound := cCfgRndECF
EndIf

If nValue > 0
	nValue 	:= NoRound(nValue,3)					//Trunca o valor para 3 casas
	cValue	:= AllTrim(STR(nValue))
	nUltVal := Val(SubStr(cValue,Len(cValue),1))  	//Ultimo
	nAntVal := Val(SubStr(cValue,Len(cValue)-1,1))	//Penultimo
	//Valida se o ultimo numero é 5
	If nUltVal == 5
		//Valida se o numero anterior ao 5 é par, se for trunca
		If nAntVal%2 == 0
			cRound := "T"
		EndIF
	EndIf	
EndIf	

Return cRound

//-------------------------------------------------------------------
/*/{Protheus.doc} STBImpRnd5
Verifica se a impressora irá utilizar a regra para arredondar ou truncar o valor 
conforme definido na função STBRound5

@author  bruno.inoue
@version P11.8
@since   23/05/2017
@return  lRet
/*/
//-------------------------------------------------------------------
Function STBImpRnd5()
Local lRet	:= .F.	
Local lPos	:= STFIsPOS()	// Pos?

If Empty(AllTrim(cImpressora))
	If lPos
		cImpressora	:= STFGetStation("IMPFISC")	//modelo da impressora configurada
	Else
		cImpressora	:= LjGetStation("IMPFISC")	//modelo da impressora configurada
	EndIf
EndIf

cImpressora	 := Upper(cImpressora)

If 'BEMATECH' $ cImpressora .And. 'FI' $ cImpressora  .And. ('4000' $ cImpressora .Or. '4200' $ cImpressora)
	LjGrvLog("STBImpRnd5()", "ECF-BEmatech")
	lRet := .T.
EndIf

Return lRet
