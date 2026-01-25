Function SetParam(cCodCli, cCliLoja, cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix, cA1GrpVen)
Local cPrdPrefix := ""
Local cPrefix := ""
Local nPos := 0
Local nPreTimes := 0
Local nPreLen := 0
Local nPosPeso:= 0

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(cCodCli+cCliLoja)
cCliente:=HA1->A1_COD + "/" + HA1->A1_LOJA + " - " + HA1->A1_NOME
cCond 	   := Alltrim(HA1->A1_COND) 
cTransp    := Alltrim(HA1->A1_TRANSP)
cSfaFpgIni := Alltrim(HA1->A1_FORPAG)
cFrete     := Alltrim(HA1->A1_TPFRET)

If HA1->(FieldPos("A1_GRPVEN")) <> 0
   cA1GrpVen  := Alltrim(HA1->A1_GRPVEN)
else  
   cA1GrpVen  :=""
endif 
dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SFAMTES")//Permite ou nao ao vendedor manipular a TES
if !eof()
	cManTes:=AllTrim(HCF->CF_VALOR)
else
	cManTes:="N"
Endif              

dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SEMPREC")//Permite ou nao ao vendedor digitar o preco (quando nao houver)
if !eof()
	cManPrc:=AllTrim(HCF->CF_VALOR)
else
	cManPrc:="N"
Endif

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek("MV_BLOQPRC")//Bloqueio do campo preco
if !eof()
	cBloqPrc := AllTrim(HCF->CF_VALOR)
else
	cBloqPrc :=	"S"
endif
                   
dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SFCONDI")//Habilita ou nao a cond. de pagto. inteligente (T ou F)
if !eof()
	cCondInt:=AllTrim(HCF->CF_VALOR)
else
	cCondInt:="F"
Endif              
                    
//Indica de quantos em quantos produtos o browse sera paginado na tela de pedido (v.2)
dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_SFPAGIN")
if !eof()
	nPagProd:=Val(HCF->CF_VALOR)
else
	nPagProd:=50 //default
endif

dbSelectArea("HCF")
dbSetorder(1)
dbSeek("MV_PRODUPL") //Habilita ou nao a duplicacao de produtos no pedido (T ou F)
if !Eof()
	cProDupl := AllTrim(HCF->CF_VALOR)
else
	cProDupl := "F"
Endif              

If cCondInt == "T" .And. !Empty(cCond)
	cTabPrc := RGCondInt(cCodCli,cCliLoja,cCond)
Else
	If HA1->(FieldPos("A1_TABELA")) <> 0
		cTabPrc := Alltrim(HA1->A1_TABELA)
	Endif
Endif

// Forma de Pagamento
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAFPG"))
	cSfaFpg := HCF->CF_VALOR
Else 
	cSfaFpg := "F"
EndIf

// Peso do Pedido
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAPESO"))
	nPosPeso := At(",",HCF->CF_VALOR)
	cSfaPeso := Substr(HCF->CF_VALOR,1,1)
	cUmPeso := Substr(HCF->CF_VALOR,nPosPeso+1, 1)
Else 
	cSfaPeso := "F"
	cUmPeso := "1"
EndIf	

//Verifica permissao para campo Qtde com decimais
HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFAQTDE"))
	cQtdDec := AllTrim(HCF->CF_VALOR)
Else 
	cQtdDec := "T"
EndIf	


// Verifica a Utilizacao do Prefixo na Consulta de Produtos
SetPrefix(aPrdPrefix)	

Return Nil
