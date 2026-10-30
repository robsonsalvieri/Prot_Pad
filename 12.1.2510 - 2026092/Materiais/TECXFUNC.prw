#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tecQtdHour

@description Retorna a quantidade de Horas, em numérico ou em string.
             
@Param  cHora[Opcional-Default=""], String, Hora a ser convertida. Aceita apenas HHHH:MM:SS, HH:MM:SS, HHH:MM ou HH:MM
        cType[Opcional-Default="N"], String, Tipo de retorno esperado. "C" -> Retorno String
                                                                       "N" -> Retorno Numérico

@Return xResult, Numeric ou String, Quantidade de horas
                 **Parametros inválidos de hora ou cType retorna Numeric 0 ou String vazia ""

@Exemplos de uso:   tecQtdHour("10:30:00","N") --> 10.5
                    tecQtdHour("10:30:00","C") --> "10.5"
                    tecQtdHour("   10:30","C") --> "10.5"
                    tecQtdHour("1233:00") -------> 1233
                    tecQtdHour("10:55:37") ------> 10.92694444
                    tecQtdHour("10:77","C") -----> "0" --- Hora inválida
                    tecQtdHour("10:77") ---------> 0 ----- Hora inválida
                    tecQtdHour("String") --------> 0 ----- Parametro inválido
                    tecQtdHour(oObjeto) ---------> 0 ----- Parametro inválido
                    tecQtdHour("10:30","W") -----> 0 ----- Parametro cType inválido
                    tecQtdHour("10:30", 12) -----> 0 ----- Parametro cType inválido

@author	jack.junior
@since	05/12/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Function tecQtdHour(cHora,cType)
    Local aPartes := {}
    Local nHora   := 0
    Local nMin    := 0
    Local nResult := 0
    Local nSeg    := 0
	Local nX      := 0
	Local xResult := 0
	Default cHora := ""
	Default cType := "N"

    // Inicializa o resultado corretamente:
    If cType == "C"
        xResult := "0"
    ElseIf cType == "N"
        xResult := 0
    EndIf

    If ValType(cHora) == "C"
        cHora := AllTrim(cHora)
        If !Empty(cHora) .And. (cType == "C" .Or. cType == "N")
            // Valida se o parametro se trata de Hora:
            If tecVldHour(cHora)

                // Quebra a string pelo ":"  
                aPartes := StrTokArr(AllTrim(cHora), ":")

                For nX := 1 To Len(aPartes)
                    If nX == 1
                        // Horas:
                        nHora := Val(aPartes[1])
                    ElseIf nX == 2
                        // Minutos:
                        nMin  := Val(aPartes[2])
                    ElseIf nX == 3
                        // Segundos:
                        nSeg := Val(aPartes[3])
                    EndIf
                Next nX

                // Faz a conta: "10:30" é igual a 10.5
                nResult := nHora + (nMin / 60) + (nSeg / 3600)

                If cType == "C"
                    // Transforma em String:
                    xResult := AllTrim(Str(nResult))
                ElseIf cType == "N"
                    // Mantém formato Numérico:
                    xResult := nResult
                EndIf
            EndIf
        EndIf
    EndIf

Return xResult

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tecVldHour

@description Valida se o parâmetro passado é String no formato Hora específico:
                -Formatos aceitos: HH:MM ou HH:MM:SS (Horas, minutos, segundos)
                -A quantidade de "H" (horas) pode ser aumentada, ex: HHHHHH:MM:SS ou HHHH:MM
             
@Param  cHora[Opcional->Default=""], qualquer tipo.

@Return lRet, Logic, .T. ou .F.

@Exemplos de uso:   tecVldHour("10:30:25") -----> .T.
                    tecVldHour("10:59") --------> .T.
                    tecVldHour("11231230:59") --> .T.
                    tecVldHour("5890:59:01") ---> .T.
                    tecVldHour("10:61:30") -----> .F. --- Minutos até 59
                    tecVldHour("410:54:61") ----> .F. --- Segundos até 59
                    tecVldHour("58:90:59:01") --> .F. --- Regex inválido
                    tecVldHour("AA90:59:01") ---> .F. --- Regex inválido
                    tecVldHour("String") -------> .F. --- Parâmetro inválido
                    tecVldHour(oObjeto) --------> .F. --- Parâmetro inválido
                    tecVldHour(10) -------------> .F. --- Parâmetro inválido
                    tecVldHour() ---------------> .F. --- Sem Parâmetro

@author	jack.junior
@since	05/12/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Function tecVldHour(cHora)
	Local lRet    := .F.
	Local oRegex  := Nil
	Default cHora := ""

	If !Empty(cHora) .And. ValType(cHora) == "C"
		// Verifica a Expressão para validar se é HORA em formatos específicos:
		oRegex := tlpp.regex.Regex():New("")

        If oRegex:Matches("^[0-9]{2,}:(?:[0-5][0-9])(?:[:][0-5][0-9])?$", cHora)
            lRet := .T.
        EndIf

	EndIf
Return lRet

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tecRound

@description    Arredondamento de casas decimais:
                    1- Recebe uma variável de qualquer tipo; 
                    2- Tenta transformar em numérico:
                        -Se conseguir arredonda de acordo com o número de decimais desejado.
                        -Se não conseguir retorna 0.
             
@Param  xValue[Opcional->Default=0], qualquer tipo.
        nDec[Opcional->Default=2], Numeric, Quantidade de casas decimais para arredondamento

@Return nRetVal, Numeric, valor arredondado.

@Exemplos de uso:   tecRound("10.5632", 1) -------> 10.6
                    tecRound(10.5432, 1) ---------> 10.5
                    tecRound(10.5432) ------------> 10.54
                    tecRound(10.5785552, 3) ------> 10.589
                    tecRound("String teste", 2) --> 0
                    tecRound(oObjeto) ------------> 0
                    tecRound() -------------------> 0

@author	jack.junior
@since	05/12/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Function tecRound(xValue,nDec)
    Local nRetVal  := 0
    Default nDec   := 2
    Default xValue := 0

    nRetVal := Round(tecVal(xValue), nDec)

Return nRetVal

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tecVal

@description A função recebe uma variável de qualquer tipo e tenta converter em numérico.
             
@Param  xValue[Opcional-Default=0], qualquer tipo. 

@Return nRetVal, Numeric, valor numérico caso consiga converter. Caso não consiga retorna 0.

@Exemplos de uso:   tecVal(10.5432) ---------> 10.5432
                    tecVal(-50) -------------> -50
                    tecVal("10.5432") -------> 10.5432
                    tecVal("-710.32") -------> -710.32
                    tecVal("10.a5432") ------> 0
                    tecVal("String teste") --> 0
                    tecVal(oObjeto) ---------> 0
                    tecVal() ----------------> 0

@author	jack.junior
@since	05/12/2025
/*/
//----------------------------------------------------------------------------------------------------------------
Function tecVal(xValue)
    Local nRetVal  := 0
    Local oRegex   := Nil
    Default xValue := 0

    If ValType(xValue) == "C"
        oRegex := tlpp.regex.Regex():New("")
        //Valida se a String é Valor (positivo ou negativo)
        If oRegex:Matches("^-?[0-9]+(\.[0-9]+)?$", xValue)
            nRetVal := Val(xValue)
        EndIf
    ElseIf ValType(xValue) == "N"
        nRetVal := xValue
    EndIf

Return nRetVal

//----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} tecExistCPO

@description A função verifica se um registro existe no banco de dados
             
@Param  cAlias, string, Alias a ser pesquisado 
        cChave, string, Chave a ser pesquisada com filial
        nIndice, numeric, Indice utilizado na pesquisa

@Return lRet, logico, se existe a chave

@author	jack.junior
@since	27/04/2026
/*/
//----------------------------------------------------------------------------------------------------------------
Function tecExistCPO(cAlias, cChave, nIndice)

    Local aArea     := GetArea()
    Local lRet      := .F.
    Default cAlias  := ""
    Default cChave  := ""
    Default nIndice := 1

    If ValType(cAlias) == "C" .And. ;
        !Empty(cAlias) .And. ;
        ValType(cChave) == "C" .And. ;
        !Empty(cChave) .And. ;
        ValType(nIndice) == "N" 

        dbSelectArea(cAlias)
        dbSetOrder(nIndice)

        If (cAlias)->( MsSeek(cChave) )
            lRet := .T.
        EndIf

    EndIf

    RestArea(aArea)

Return lRet
