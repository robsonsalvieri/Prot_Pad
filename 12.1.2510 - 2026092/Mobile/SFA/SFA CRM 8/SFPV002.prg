Function SetParam(cCodCli, cCliLoja, cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix, cPsqGrp, lCodigo, cManDte)
Local cPrdPrefix := ""
Local cPrefix := ""
Local nPos := 0
Local nPreTimes := 0
Local nPreLen := 0
Local nPosPeso:= 0

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(RetFilial("HA1") + cCodCli+cCliLoja)
cCliente:=HA1->HA1_COD + "/" + HA1->HA1_LOJA + " - " + HA1->HA1_NOME
cCond 	   := Alltrim(HA1->HA1_COND) 
cTransp    := Alltrim(HA1->HA1_TRANSP)
cSfaFpgIni := Alltrim(HA1->HA1_FORPAG)
cFrete     := If(!Empty(Alltrim(HA1->HA1_TPFRET)),Alltrim(HA1->HA1_TPFRET),"F")

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF") + "MV_SFAMTES")//Permite ou nao ao vendedor manipular a TES
if !eof()
	cManTes:=AllTrim(HCF->HCF_VALOR)
else
	cManTes:="N"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF") + "MV_SEMPREC")//Permite ou nao ao vendedor digitar o preco (quando nao houver)
if !eof()
	cManPrc:=AllTrim(HCF->HCF_VALOR)
else
	cManPrc:="N"
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF") + "MV_BLOQPRC")//Bloqueio do campo preco
if !eof()
	cBloqPrc := AllTrim(HCF->HCF_VALOR)
else
	cBloqPrc :=	"S"
endif
                   
dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF") + "MV_SFCONDI")//Habilita ou nao a cond. de pagto. inteligente (T ou F)
if !eof()
	cCondInt:=AllTrim(HCF->HCF_VALOR)
else
	cCondInt:="F"
Endif              
                    
//Indica de quantos em quantos produtos o browse sera paginado na tela de pedido (v.2)
dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF") + "MV_SFPAGIN")
if !eof()
	nPagProd:=Val(HCF->HCF_VALOR)
else
	nPagProd:=50 //default
endif

dbSelectArea("HCF")
dbSetorder(1)
dbSeek(RetFilial("HCF") + "MV_PRODUPL") //Habilita ou nao a duplicacao de produtos no pedido (T ou F)
if !Eof()
	cProDupl := AllTrim(HCF->HCF_VALOR)
else
	cProDupl := "F"
Endif              

If cCondInt == "T" .And. !Empty(cCond)
	cTabPrc := RGCondInt(cCodCli,cCliLoja,cCond)
EndIf
If Empty(cTabPrc)
	If HA1->(FieldPos("HA1_TABELA")) <> 0
		cTabPrc := Alltrim(HA1->HA1_TABELA)
	Endif
Endif

// Forma de Pagamento
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAFPG"))
	cSfaFpg := HCF->HCF_VALOR
Else 
	cSfaFpg := "F"
EndIf

//Verifica permissao para campo Qtde com decimais
HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAQTDE"))
	cQtdDec := AllTrim(HCF->HCF_VALOR)
Else 
	cQtdDec := "T"
EndIf	

// Verifica a Utilizacao do Prefixo na Consulta de Produtos
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFPROPR")
	cPrdPrefix := AllTrim(HCF->HCF_VALOR)
	cPrdPrefix += ","

	// Parametro 1 = Prefixo
	nPos := At(",", cPrdPrefix)
	cPrefix := SubStr(cPrdPrefix, 1 , nPos - 1)
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))
	
	// Parametro 2 = Numero de Vezes
	nPos := At(",", cPrdPrefix)
	nPreTimes := Val(SubStr(cPrdPrefix, 1 , nPos - 1))
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))
	
	// Parametro 3 = tamanho maximo da string
	nPos := At(",", cPrdPrefix)
	nPreLen := Val(SubStr(cPrdPrefix, 1 , nPos - 1))

	aAdd(aPrdPrefix, {cPrefix, nPreTimes, nPreLen})
Else
	aAdd(aPrdPrefix, {"", "", ""})
Endif

// Parametro de Pesquisa na Tela 2 de pedido
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFAPEGR")
	cPsqGrp := AllTrim(HCF->HCF_VALOR)
else
	cPsqGrp := "S"
Endif              

// Parametro que define a ordem padrao para pesquisa de produtos na Tela 2 de pedido
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFPROR")
	lCodigo := If(AllTrim(HCF->HCF_VALOR) = "1", .T., .F.)
Else
	lCodigo := .T.
Endif              

// Permite manipular data de entrega
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFAMDTE")//Permite ou nao ao vendedor manipular a data de entrega
	cManDte:=AllTrim(HCF->HCF_VALOR)
else
	cManDte:="S"
Endif

//Indica uso do peso bruto no pedido
cSfaPeso := SFGetMv("MV_SFAPESO",.F.,"F")
If "T" $ cSfaPeso
	nPosPeso := At(",",cSfaPeso)
	If nPosPeso > 0
		cUmPeso	 := Substr(cSfaPeso,nPosPeso+1,1)
	EndIf
	cSfaPeso := "T"
EndIf

Return Nil
