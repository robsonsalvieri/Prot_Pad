#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

static cCharacter	:= "_:," //Caracteres especiais permitidos

Function FisExecNPI(cFormula)

Local nResultado	:= 0
Local nCont			:= 0
Local nContPilha	:= 0
Local aFormula		:= {}
Local aPilha		:= {}

//Converte em array a fórmula
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//-------------------------------------------------
//Laço para percorrer todos os elementos da  fórmula
//-------------------------------------------------
For nCont := 1 to len( aFormula )	
	
	//--------------------------
	//Verifica se é um operador
	//--------------------------
	If aFormula[nCont] $ "+-*/"
		
		//-----------------------------------------------------------------------------------
		//Se for operador então fará o cálculo com os dois últimos operandos do topo da pilha
		//Pega o tamanho da pilha		
		//Proteção caso a pilha não tenha elementos suficiente para executar e não ocasionar error log
		//------------------------------------------------------------------------------------
		IF (nContPilha	:= Len( aPilha )) > 1
		
			//----------------------------------------------------------------
			//Realiza o cálculo considerndo os dois operandos do topo da pilha
			//----------------------------------------------------------------
			Do Case
				Case aFormula[nCont] == '/'
					nResultado	:= 	aPilha[nContPilha-1] / aPilha[nContPilha]
					
				Case aFormula[nCont] == '*'
					nResultado	:= 	aPilha[nContPilha-1] * aPilha[nContPilha]
					
				Case aFormula[nCont] == '+'
					nResultado	:= 	aPilha[nContPilha-1] + aPilha[nContPilha]
					
				Case aFormula[nCont] == '-'
					nResultado	:= 	aPilha[nContPilha-1] - aPilha[nContPilha]			
			EndCase
			
			//------------------------------------------------
			//Remove do Array os dois últimos operandos (POP)
			//------------------------------------------------
			ASize( aPilha, nContPilha - 2 ) 			
			
			//---------------------------------------------
			//Adiciona o resultado no topo da pilha (PUSH)
			//---------------------------------------------
			aadd( aPilha, nResultado )		
		Else
			//Se caiu aqui é porq existe algum erro na fórmula, o processamento deverá ser abortado.
			//TODO tratamento de erro

		EndiF
		
	Else		
	
		//-----------------------------------------------------------------------------------
		//Se não é um operador então é um operando, será adicionado no topo da pilha (PUSH)		
		//-----------------------------------------------------------------------------------
		nResultado	:= Val(StrTran(aFormula[nCont],",","."))
		aadd(aPilha, nResultado )
					
	EndIF
	
Next nCont

Return nResultado


 //-------------------------------------------------------------------
/*/{Protheus.doc} xFisSYard

Função que executa o algorítumo Shunting-Yar.
Recebe uma expressão aritimética e converte para uma expressão
no formato NPI - Notação Polonesa Invertida.

@param  cExpr	 	- Expressão aritimética convencional
@return cOutPut 	- Espressão convertida em NPI

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function xFisSYard(cExpr, cFormula)

Local cOutPut 		:= ""
Local cTokenProx 	:= ""
Local aPilha 		:= {}
Local nX 			:= 0
Local cForTmp		:= ""

Default cFormula := ""

//Percorre a expressão caracter por caracter para fazer canálise
For nX := 1 to Len(cExpr)		
	
	//Pega caracter
	cToken := SubStr(cExpr, nX, 1)
	

	//Pega próximo caracter
	cTokenProx := SubStr(cExpr, nX + 1, 1)
	
	// Se for caracter permitido, ou seja, se for um algarismo, ou se for letra, , virgula ou underscore então será permitido.
	If IsDigit(cToken) .Or. IsAlpha(cToken) .Or. cToken $ cCharacter 
		
		//Faco uma validacao do proximo token p/ ver se o numero tem mais de um digito
		//A verificação é a mesma feita anteriormente para saber se é um caracter válido
		//Se for um caracter válido é porq trata-se do mesmo operando, e por isso não será adiconado espaço.
		//Se não for um caracter/algarismo válido, então será adicionado espaço para separar
		cOutPut += cToken 

		cForTmp += cToken 
		If IsDigit(cTokenProx) .Or. IsAlpha(cTokenProx) .Or. cTokenProx $ cCharacter
			cOutPut	+= ""
		Else
			cOutPut	+= space(1)
			cFormula += " " + cForTmp
			cForTmp	:= ""
		EndIF

		
			
	// Se for operador vai para a pilha
	ElseIf isOperator(cToken)
				
		// Enquanto houver um operador no topo da pilha, verificar se o operador
		// da expressao tem precedencia MENOR do que o da pilha, ou seja, deve ser
		// resolvido APÓS ele. Se positivo, o operador da pilha (MAIOR precedencia)
		// vai para o output, e o operador da expressao vai para a pilha.
		While isOperator(ViewTop(aPilha)) .And. PesoOperador(ViewTop(aPilha))  >= PesoOperador(cToken) 
			cOutPut += xPop(aPilha) + " "
		EndDo	
	
		//Adiciona o operador na pilha
		xPush(aPilha, cToken)
		cFormula += " " + cToken
	
	// Se for abertura de parenteses vai para a pilha	
	ElseIf cToken == "("
	
		//Adiciona o parenteses na pilha
		xPush(aPilha, cToken)
		cFormula += " " + cToken
	
	// Se for fechamento de parenteses, retira da pilha e manda para a saida todos os operadores ateh
	// encontrar a abertura do parenteses. Quando encontrar a abertura soh retira da pilha e joga fora.
	ElseIf cToken == ")"
	
		cFormula += " " + cToken
		//Percorre a pilha para buscar todos operandos e operadores que estão dentro do parenstese que acabou de ser fechado
		While Len(aPilha) > 0
			
			//Verifica elemento do topo da pilha
			cTopo := ViewTop(aPilha)
			
			//Se for diferente de parenteses entao adiciona na string
			If cTopo <> "("
				//Adiciona operador/operando na string e retira do topo da pilha
				cOutPut += xPop(aPilha) + " "				
			Else
				//retira o parenteses da pilha e sai do laço
				xPop(aPilha)
				Exit
			EndIf
		EndDo
	
	EndIf

Next nX

// Fim de expressão: movo todos os operadores restantes da pilha p/ a saida
//Aqui restam os operadores que serão executados por último
While Len(aPilha) > 0
	cOutPut += xPop(aPilha) + space(1)
EndDo

// Retira espaços da expressao "Final"
cOutPut := AllTrim(cOutPut)

Return cOutPut

//-------------------------------------------------------------------
/*/{Protheus.doc} xPush

Adiciona elemento no final da pilha

@param array - aPilha - Pilha que deverá ser analisada
@param - xVal - Elemento a ser adicionado na pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xPush(aPilha, xVal)

aAdd(aPilha, xVal)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} xPop

Função que retira o elemento do topo da pilha

@param array - aPilha - Pilha que deverá ser analisada

@Return xRet-  Valor retirado do topo da pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xPop(aPilha)

Local xRet := ""

If Len(aPilha) > 0
	xRet := aPilha[Len(aPilha)]
	aDel(aPilha,Len(aPilha))
	aSize(aPilha,Len(aPilha) - 1)
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewTop

Função que retorna elemento do topo da pilha

@param array - aPilha - Pilha que deverá ser analisada

@Return  Valor do elemento do topo da pilha

@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function ViewTop(aPilha)
Local xRet := ""

If Len(aPilha) > 0
	xRet := aPilha[Len(aPilha)]
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isOperator

Função que verifica se caracter é um operador válido
@param cChar - Caractere
@Return bool - Verdadeiro se for um operador válido
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function isOperator(cChar)
Return cChar $ "+-/*"

//-------------------------------------------------------------------
/*/{Protheus.doc} PesoOperador

Função que retorna o peso/prioridade do operador.
O operador * tem prioridade maior que o operador + por exemplo

@param cOperador - Operador a ser analisado
@Return nRet - Peso do operador
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function PesoOperador(cOperador)
Local nPeso := 0

If cOperador $ "*/"
	nPeso := 2
ElseIf cOperador $ "+-"
	nPeso := 1
EndIf

Return nPeso

//-------------------------------------------------------------------
/*/{Protheus.doc} FisChkForm

Função que faz validação de sintaxe da formula aritimética, antes
que seja converitda em NPI.
@param cExpr - Expressão aritimética a ser valida
@Return cRet - Mensagem de erro caso tenha alguma inconsistência
@author Erick Dias
@since 24/01/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisChkForm(cExpr)

Local cRet 			:= ""
Local cToken 		:= ""
Local nX 			:= 0
Local nOperadores 	:= 0
Local nAbreParen 	:= 0
Local nFechaParen 	:= 0
Local nInvalid 		:= 0
Local cInvalid		:= ""
Local lErro			:= .F.

// Tratar a expressao.
// Por exemplo, retirar todos os espaços em branco, contar os parenteses, operadores e etc.
cExpr := StrTran(cExpr, " ", "")

//Passa por todos os caracteres para validar.
For nX := 1 to Len(cExpr)

	//Pega o caracter da string
	cToken := SubStr(cExpr, nX, 1)	
	
	//Abaixo os contadores
	Do Case	
		Case cToken == "("
			nAbreParen++			
		Case cToken == ")"
			nFechaParen++
			if nFechaParen > nAbreParen
				//Aqui fechou parenteses sem ter aberto antes....erro e abortar
				cRet	:= "Expressão contém fechamento de parenteses indevido..."
				lErro	:= .T.
				exit
			EndIF
		Case isOperator(cToken)
			nOperadores++
		Case !(IsDigit(cToken) .Or. IsAlpha(cToken) .Or. cToken $ cCharacter)
			nInvalid++			
			cInvalid += "'" + cToken + "' "
	EndCase

Next nX

// Carateres invalidos na expressao
If !lErro .AND. nInvalid > 0
	cRet	+= "Caracteres inválidos, por favor verifique: " + CRLF + CRLF + cInvalid + CRLF + CRLF
EndIf

// Numero de aberturas de parenteses deve ser igual o de fechamentos.
If !lErro .AND.  nAbreParen <> nFechaParen
	cRet	+= "Numero de aberturas de parenteses deve ser igual o de fechamentos."	+ CRLF + CRLF 
EndIf

Return cRet


/*/{Protheus.doc} listOper

    Retorna os operandos da fórmula. A fórmula enviada deve ter seus elementos
    separados por espaço. Exemplo de fórmula válida: "( B:200001 * A:200001 )".
    Veja que cada elemento da fórmula se destaca pelo espaço que há entre ele e
    o próximo elemento. Caso esse espaço não exista o retorno poderá ser incorreto.

    @type  Function
    @author anedino.santos
    @since 01/04/2025
    @version 12.1.2410
    @param cFormula, character, fórmula em expressão aritmética ou em NPI
    @param nType, numeric, tipo de operando a ser retornado: 0=TODOS, 1=PRIMARIO, 2=COMPOSTO
    @return aOperands, array, lista dos operandos da fórmula
/*/
Function listOper(cFormula, nType)
    local aElements := StrTokArr(alltrim(cFormula)," ") as array
    local aOperands := {} as array
    local nI as numeric

    default nType := 0

    for nI := 1 to len(aElements)
        if RetTypeFor(aElements[nI]) == "OPERANDO"
            if nType == 0 // todos
                aAdd(aOperands, aElements[nI])
            elseIf nType == operType(aElements[nI])
                aAdd(aOperands, aElements[nI])
            endif
        endif
    next nI

Return aOperands


/*/{Protheus.doc} operType

    Retorna o tipo do operando.
    Operando primário: todo operando que não foi gerado por uma formula.
    Operando composto: todo operando gerado por alguma formula - Base, Alíquita
    e valores de regras tributárias.

    @type  Function
    @author anedino.santos
    @since 01/04/2025
    @version 12.1.2410
    @param cOper, character, operando a ser verificado
    @return cType, character, retorna o tipo do operando 1=PRIMARIO, 2=COMPOSTO, 0=NÂO ENCONTRADO
/*/
Function operType(cOper)
    local nType := 0 as numeric

    if !Empty(cOper)
        dbSelectArea("CIN")
        dbSetOrder(1)
        if CIN->(MsSeek(xFilial("CIN") + cOper))
            if Alltrim(CIN->CIN_TREGRA) $ "1#2#6#7#8#11#12#13"
                nType := 2
            else
                nType := 1
            endif
        endif
        CIN->(dbCloseArea())
    endif

Return nType


/*/{Protheus.doc} isRegTrib

    Verifica se é um operando de regra tributária (BAS,ALQ, VAL, ISE, OUT, DIF).
    Se for retorna a Regra Tributária. Se não for, retorna string vazia.

    @type  Function
    @author anedino.santos
    @since 02/04/2025
    @version 12.1.2410
    @param cOper, character, operando
    @return cRet, character, retorna a regra tributária ou string vazia
/*/
Function isRegTrib(cOper)
    local cRet as character

    if subStr(cOper, 1, at(":", cOper)) $ "BAS:/ALQ:/VAL:/ISE:/OUT:/DIF:"
        cRet := subStr(cOper, at(":", cOper) + 1)
    endif

Return cRet
