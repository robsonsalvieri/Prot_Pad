#INCLUDE "SFXFUN.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ StoD		           ³Autor: Fabio Garbin  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Converte uma string no formato (yyyymmdd) para data        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cData: Sring da data							 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function StoD(cData)
Local cDia := ""
Local cMes := ""
Local cAno := ""
Local dData := Date()

cData := AllTrim(cData)

If Len(cData) != 8
	MsgAlert("Data inválida.", "Conversào StoD")
	Return cData
EndIf

cDia := SubStr(cData,7,2)
cMes := SubStr(cData,5,2)
cAno := SubStr(cData,3,2)

dData := CtoD(cDia + "/" + cMes + "/" + cAno)

Return dData      

/* 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ aScan	           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Procura umm valor dentro de um array    			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aArray: Array onde sera feita a procura					  ³±±
±±³			 ³ vPesq: valor a ser pesquisado, nIni: Posicao inicial		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function aScan(aArray,vPesq,nIni,nQtd)
Local i:=1
if nIni==0
	nIni:=1
Endif
if nQtd==0 .or. nQtd > len(aArray)
	nQtd:=Len(aArray)
Endif
for i:=nIni to nQtd
	if aArray[i] == vPesq
		Return Nil
	Endif
Next
Return i

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ aOrdena	           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ordena um array                        			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aArray: Array que sera ordenado       					  ³±±
±±³			 ³ nIni: Posicao inicial		  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function aOrdena(aArray,nIni,nQtd)
Local aCopia:={}
Local i:=1, j:=1, l:=1
Local lFim:= .F.
Local oProx,oProx2

if nIni==0
	nIni:=1
Endif

if nQtd == 0 .or. nQtd > len(aArray)
	nQtd :=Len(aArray)
Endif

For i:=nIni to nQtd        
	lFim := .T.
	For j:=i to len(aCopia)
		if aArray[i] < aCopia[j]
			oProx:=aCopia[j]
			if (j+1)<=len(aCopia[j])
				oProx2:=aCopia[l+1]
			else
    			oProx2:=0
   			endif

			for l:=j to Len(aCopia)
				if l == j
					aCopia[l]:=aArray[i]
				else
					aCopia[l]:=oProx
					oProx:=oProx2    
					if (l+1)<=len(aCopia[j])
	        			oProx2:=aCopia[l+1]
	    			else
	    				oProx2:=0
	    			endif
	    		Endif
			Next               
			lFim:= .F.
			break
 
		Endif			

	Next

	if lFim
		AADD(aCopia,aArray[I])
    Else      
    	AADD(aCopia,oProx)
    Endif

Next
		
Return aCopia                      


//Function SFConsPadrao(cAlias,cVar,oObj,nIndice, aRet)  
Function SFConsPadrao(cAlias,cVar,oObj,aCamp,aInd, aRet)
Local oDlg, oBrwCP, oBtnUp, oBtnDown, oBtnLeft, oBtnRight
Local oBtnOK, oBtnCanc, oBtnPesq,oInd,oPesq
Local cPesq:=""
Local aArray :={},aOrdem:={}, aCombo:= {}
Local nOrdem:=1, nTop:=0,nInd:=1, nX:=1
Local oCol

DEFINE DIALOG oDlg TITLE STR0001 //"Consulta Padrão:"
@ 15,01 BROWSE oBrwCP SIZE 135,100 NO SCROLL of oDlg
SET BROWSE oBrwCP ARRAY aArray                                    

For nI:=1 to Len(aCamp)
	ADD COLUMN oCol TO oBrwCP ARRAY ELEMENT nI HEADER aCamp[nI,1] WIDTH aCamp[nI,3]
Next                                                                    

For nX:=1 to Len(aInd)
	Aadd(aCombo,aInd[nX,1])
Next

@ 34,140 BUTTON oBtnUp CAPTION UP_ARROW SYMBOL SIZE 12,12 ACTION CPUp(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg
@ 48,140 BUTTON oBtnRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,12 ACTION GridRight(oBrwCP) of oDlg
@ 62,140 BUTTON oBtnLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,12 ACTION GridLeft(oBrwCP) of oDlg
@ 76,140 BUTTON oBtnDown CAPTION DOWN_ARROW SYMBOL SIZE 12,12 ACTION CPDown(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg
@ 120,05 SAY STR0002 of oDlg //"Pesquisar por:"
@ 120,70 COMBOBOX oInd VAR nInd ITEMS aCombo SIZE 60,50 of oDlg   
@ 132,05 GET oPesq VAR cPesq SIZE 150,15 of oDlg
@ 146,05 BUTTON oBtnOK CAPTION STR0003 SIZE 45,12 ACTION CPRet(oBrwCP,aArray,@cVar,oObj, aCamp, aRet) of oDlg //"OK"
@ 146,55 BUTTON oBtnCanc CAPTION STR0004 SIZE 45,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 146,105 BUTTON oBtnPesq CAPTION STR0005 SIZE 45,12 ACTION CPPesq(cAlias,@cPesq,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg //"Pesquisar"

CPLoad(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd)

ACTIVATE DIALOG oDlg

Return Nil

Function CPRet(oBrwCP,aArray,cVar,oObj, aCamp, aRet)
Local nArray:=0
Local ni := 0
If Len(aArray) == 0 
	cVar:= ""
Else       
	nArray:= GridRow(oBrwCP)
	cVar:= aArray[nArray,1]
	If aRet != Nil
		aRet := Array(Len(aCamp))
		For ni := 1 To Len(aRet)
			aRet[ni,1] := aArray[nArray, ni]
		Next
	EndIf
Endif
SetText(oObj,cVar)
CloseDialog()
Return Nil     

Function CPDown(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)                   
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(GridRows(oBrwCP))
if !Eof()
   nTop := Recno()
Else
   return nil
endif     
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)

Function CPUp(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(-GridRows(oBrwCP))
if !Bof()
   nTop := Recno()
else
	dbGoTop()
    nTop := Recno()
endif
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)

Function CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
Local nCargMax:=1,nJ:=1,nZ:=1             
Local aLocal:= {}              

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
if nTop ==0
	dbGoTop()
	if !Eof()
	    nTop := Recno()
	Endif
Else
	dbGoTo(nTop)
Endif

aSize(aArray,0)       
nCargMax:=GridRows(oBrwCP)
For nI:=1 to nCargMax
	if !Eof()
		AADD(aArray,Array(Len(aCamp)))
		For nZ := 1 to Len(aCamp)
			aArray[Len(aArray),nZ] := FieldGet(aCamp[nZ,2])
		Next
		dbSkip()
	Else
		nI:=nCargMax +1
	Endif
Next
aSize(aLocal,0)
SetArray(oBrwCP,aArray)

Return Nil

Function CPPesq(cAlias,cPesq,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nCargMax := GridRows(oBrwCP)
Local aPesq:={}     
Local nJ:=1, nZ:=1             
Local nOrdem:=aInd[nInd,2]
Local cTipoCnd := ""
cPesq:=AllTrim(cPesq)
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
if dbSeek(cPesq)

    If cAlias=="HE4"
		cTipoCnd := If(HE4->(FieldPos("E4_TIPO")) > 0, HE4->E4_TIPO, "")
    endif

	aSize(aArray,0)                   
	nTop:=RecNo()

	For nI:=1 to nCargMax
		if !Eof()
			aSize(aPesq,0)
			For nJ:=1 to Len(aCamp)
				Aadd(aPesq,FieldGet(aCamp[nJ,2]))				
			Next
			AADD(aArray,Array(Len(aPesq)))
			For nZ := 1 to Len(aPesq)
			  aArray[Len(aArray),nZ] := aPesq[nZ,1]
			Next
			dbSelectArea(cAlias)
			dbSkip()
		else
			nI:=nCargMax +1
		endif          
	Next
Else
	MsgAlert(STR0006 + cPesq + STR0007 + aInd[nInd,1] + STR0008) //"Pesquisa "###" por "###" não encontrada"
Endif
aSize(aPesq,0)
SetArray(oBrwCP,aArray)

Return Nil

Function SetPicture(cAlias, nFldPos)
Local cPict  := ""
Local nRec   := ADVTBL->(Recno())
Local cTable := cAlias + cEmpresa
dbSelectArea("ADVTBL")
dbSetOrder(1)
If dbSeek(cTable + Space(15-Len(cTable)) + StrZero(nFldPos,3))
	cPict := "@E " + Replicate("9", ADVTBL->FLDLEN) + "." + Replicate("9", ADVTBL->FLDLENDEC)
Else
	cPict := "@E 999,999.99"
EndIf
ADVTBL->(dbGoTo(nRec))
Return cPict


// Verifica a Utilizacao do Prefixo na Consulta de Produtos
Function SetPrefix(aPrdPrefix)
Local cPrdPrefix := ""
Local cPrefix := ""
Local nPos := 0
Local nPreTimes := 0
Local nPreLen := 0

dbSelectArea("HCF")
dbSetorder(1)
If dbSeek("MV_SFPROPR")
	cPrdPrefix := AllTrim(HCF->CF_VALOR)
	cPrdPrefix += ","

	// Parametro 1 = Prefixo
	nPos := At(",", cPrdPrefix)
	cPrefix := SubStr(cPrdPrefix, 1 , nPos - 1)
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))


	// Parametro 2 = Numero de Vezes
	nPos := At(",", cPrdPrefix)
	nPreTimes := Val(SubStr(cPrdPrefix, 1 , nPos - 1))
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))

	If nPreTimes <= 0
		nPreTimes := 0
	EndIf

	// Parametro 3 = tamanho maximo da string
	nPos := At(",", cPrdPrefix)
	nPreLen := Val(SubStr(cPrdPrefix, 1 , nPos - 1))
	If nPreLen <= 0
		nPreLen := 0
	EndIf

	aAdd(aPrdPrefix, {cPrefix, nPreTimes, nPreLen})
Else
	aAdd(aPrdPrefix, {"", 0, 0})
Endif

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  GetMV              ³Autor: Marcelo Vieira³ Data ³10.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Obtem um parametro criado na tabela HCF                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar,cValorOpc    				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GetMV(cPar,cValorOpc)
Local cRet:=""                
Local cCampos:="MV_ICMPAD"

if ValType(cValorOpc)=="U" 
   cValorOpc:="" 
endif

dbSelectArea("HCF")
dbSetOrder(1)
if dbSeek(cPar)
   cRet:=HCF->CF_VALOR
Else
   cRet:=cValorOpc
endif

IF cPar$cCampos
   cRet:=Val(cRet) 
Else
   cRet:=Alltrim(cRet)
Endif
Return cRet