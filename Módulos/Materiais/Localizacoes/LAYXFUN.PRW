#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LAYXTXT   ºAutor  ³Andres Demarziani   ºFecha ³  31/10/17   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LAYXTXT(cText)
Return Capital(AllTrim(cText))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAlin     ºAutor  ³Andres Demarziani   ºFecha ³  31/10/17   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LAYFALIN(xVal, cAlin, nTam)
Local cRet := ""

Default cAlin := "I"
Default nTam  := 18

	If ValType(xVal)=="N"
		cRet := AllTrim(Transform(xVal, PesqPict("SF2","F2_BASIMP1")))
	ElseIf ValType(xVal)=="D"
		cRet := DToC(xVal)
	Else
		cRet := xVal
	EndIf
	
	If cAlin=="D"
		cRet := PadL(cRet, nTam)
	Else
		cRet := PadR(cRet, nTam)
	EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCodBar   ºAutor  ³Andres Demarziani   ºFecha ³  31/10/17   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LAYCBAR(cCodComp, cDoc, cVctoCae, cAliasQry, cEspecie)
Local cCode := StrTran(Alltrim(SM0->M0_CGC),"-","")
Local _N := 0

Default cCodComp := ""
Default cDoc     := ""
Default cVctoCae := ""
Default cAliasQry := ""
Default cEspecie := ""

DToC(cVctoCae)

	cCode += cCodComp
	cCode += Left(cDoc,4) + Iif(cEspecie $ "NF/NDC", ((cAliasQry)->F2_CAEE), (cAliasQry)->F1_CAEE) + Substr(DToC(cVctoCae),1,4) + Substr(DToC(cVctoCae),5,2) + Substr(DToC(cVctoCae),7,2)

	//CALCULO DE DIGITO VERIFICADOR
	_E1 := 0
	_E2 := 0
	_E3 := 0
	_E4 := 0
	_E5 := 0

	//ETAPA1: Suma de las posiciones inpares
	For _N:=1 to len(cCode) step 2
		_E1 +=Val(Substr(cCode,_N,1))
	next _N

	//ETAPA2: Multiplicar la suma anterior por 3
	_E2 := _E1*3

	//ETAPA3: Suma las posiciones pares
	For _N:=2 to len(cCode) step 2
		_E3 +=Val(Substr(cCode,_N,1))
	next _N

	//ETAPA4: Suma reasultados de etapas 2 y 3
	_E4 := _E2 + _E3

	//ETAPA5: Buscar menor numero que que sumado al resultado de etapa 4 de un multiplo de 10.
	_E5 := 10 - Val(Right(str(_E4),1))

	cCode := cCode + Alltrim(Str(_E5))

Return (cCode)


/*/{Protheus.doc} LayJson
	Función para crear json a partir de array.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param aJson - Array - Variable de tipo Array con atributos para crear objeto json.
	@return oJson - Json - Objeto json.
	/*/
Function LayJson(aJson)
Local oJson              As json
Local nX        := 0    As numeric
Local cJson     := ""   As Character

Default aJson := {}

    cJson := '{'
    For nX := 1 To Len(aJson)
        cJson += Iif(nX>1,',','') + '"' + aJson[nX] + '":""'
    Next
    cJson += '}'

    oJson := JsonObject():New()
    oJson:FromJson(cJson)

Return oJson


///-------------------------------------------------------///
/*/{Protheus.doc} BuscaSFB
	Función para buscar los registros de la tabla SFB.
	@type  Function
	@author santos.rafael
	@since 05/12/2022
/*/
Function BuscaSFB()
Local cSFBqry := GetNextAlias()
local aSFB := {}
Local aSFBGan := {}
Local aSFBIb := {}
Local aAliqIva := {}
Local aAliqIvp := {}

BeginSQL alias cSFBqry
	SELECT SFB.FB_CLASSIF, SFB.FB_TIPO, SFB.FB_CLASSE, SFB.FB_CODIGO, SFB.FB_ALIQ, SFB.FB_CPOLVRO
	FROM %table:SFB% SFB 
	WHERE SFB.FB_FILIAL = %Exp:(xFilial("SFB"))% AND SFB.%notdel%
EndSql

while (cSFBqry)->(!EOF())
	if (cSFBqry)->FB_CODIGO == 'PGA'
		aadd(aSFBGan, {"Perc. Gcia.", (cSFBqry)->FB_CODIGO, (cSFBqry)->FB_ALIQ, (cSFBqry)->FB_CPOLVRO})
	Endif

	if (cSFBqry)->FB_CLASSIF == "3" .and. (cSFBqry)->FB_TIPO == "N" .and. (cSFBqry)->FB_CLASSE == "P"
		aadd(aAliqIvp, {"Perc. IVA.", (cSFBqry)->FB_CODIGO, (cSFBqry)->FB_ALIQ, (cSFBqry)->FB_CPOLVRO})
	Endif

	if SubStr((cSFBqry)->FB_CODIGO, 1, 2) == 'IB'
		aadd(aSFBIb, {"Perc. IIBB", (cSFBqry)->FB_CODIGO, (cSFBqry)->FB_ALIQ, (cSFBqry)->FB_CPOLVRO})
	Endif

	if (cSFBqry)->FB_CLASSIF == "3" .and. (cSFBqry)->FB_TIPO == "N" .and. (cSFBqry)->FB_CLASSE == "I"
		aadd(aAliqIva, {"IVA "+AllTrim(str((cSFBqry)->FB_ALIQ))+"%", (cSFBqry)->FB_CODIGO, (cSFBqry)->FB_ALIQ, (cSFBqry)->FB_CPOLVRO})
	endif

	(cSFBqry)->(dbSkip())
EndDo

aadd(aSFB, {aSFBGan, aAliqIvp, aAliqIva, aSFBIb})

Return aSFB
