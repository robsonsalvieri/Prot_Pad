/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FdaFPosRef ³ Autor ³ Henry Fila           ³ Data ³ 18.10.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca a posicao de acordo com a referencia fiscal            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function FdaFPosRef(cReferencia)

//Local aFdaCab  := {}
//Local aFdaItem := {}
Local nPosRef  := 0
Local nPos     := 0
//Public aFdaCab := {}


If SubStr(cReferencia,1,2) == "NF"
	nPos := ScanArray(aFdaCab, cReferencia,,,1)
	If nPos > 0
		nPosRef := aFdaCab[nPos,2]
	Endif	
Else	
	nPos := ScanArray(aFdaItem, cReferencia,,,1) 

	If nPos > 0
		nPosRef := aFdaItem[nPos,2]
	Endif	
Endif
 
Return nPosRef

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FdaNoRound ³ Autor ³ Henry Fila           ³ Data ³ 18.10.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nao arrendonda um valor numerico                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FdaNoRound(nValor,nDec)
//nMult := 10**nDec
Local nMult := 1 
Local ni

for ni:=1 to nDec 
    nMult*=10
Next

nValor := Int(nValor * nMult) / nMult

Return(nValor)

Function FdaCgRef(aFdaCab,aFdaItem)

Aadd(aFdaCab,{"NF_TIPONF"   ,01})
Aadd(aFdaCab,{"NF_INSCR"    ,02})
Aadd(aFdaCab,{"NF_GRPTRIB"  ,03})
Aadd(aFdaCab,{"NF_UFORIGEM" ,04})
Aadd(aFdaCab,{"NF_UFDEST"   ,05})
Aadd(aFdaCab,{"NF_CLIFOR"   ,06})
Aadd(aFdaCab,{"NF_LOJA"     ,07})
Aadd(aFdaCab,{"NF_NATUREZA" ,08})
Aadd(aFdaCab,{"NF_SUFRAMA"  ,09})
Aadd(aFdaCab,{"NF_MOEDA"    ,10})
Aadd(aFdaCab,{"NF_TXMOEDA"  ,11})
Aadd(aFdaCab,{"NF_BASEICM"  ,12})
Aadd(aFdaCab,{"NF_VALICM"   ,13})
Aadd(aFdaCab,{"NF_BASEIPI"  ,14})
Aadd(aFdaCab,{"NF_VALIPI"   ,15})

Aadd(aFdaItem,{"IT_PRODUTO" ,01})
Aadd(aFdaItem,{"IT_GRPTRIB" ,02})
Aadd(aFdaItem,{"IT_PRCVEN"  ,03})
Aadd(aFdaItem,{"IT_QTDVEN"  ,04})
Aadd(aFdaItem,{"IT_DESCONTO",05})
Aadd(aFdaItem,{"IT_VALMERC" ,06})
Aadd(aFdaItem,{"IT_FRETE"   ,07})
Aadd(aFdaItem,{"IT_DESPESA" ,08})
Aadd(aFdaItem,{"IT_SEGURO"  ,09})
Aadd(aFdaItem,{"IT_TES"     ,10})
Aadd(aFdaItem,{"IT_BASEICM" ,11})
Aadd(aFdaItem,{"IT_ALIQICM" ,12})
Aadd(aFdaItem,{"IT_VALICM"  ,13})
Aadd(aFdaItem,{"IT_BASEIPI" ,14})
Aadd(aFdaItem,{"IT_ALIQIPI" ,15})
Aadd(aFdaItem,{"IT_VALIPI"  ,16})
Aadd(aFdaItem,{"IT_BIPIORI" ,17})        
        
Return 
                                     
Function FdaCgVar() 
MV_ESTADO   := GetMV("MV_ESTADO","SP")
MV_ICMPAD   := GetMV("MV_ICMPAD")
MV_NORTE    := GetMV("MV_NORTE")
MV_ESTICM   := GetMV("MV_ESTICM")
MV_IPIBRUTO := GetMV("MV_IPIBRUTO")

Return 


