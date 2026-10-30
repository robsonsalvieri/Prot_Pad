//Function SetParam(cCodCli, cCliLoja, cCliente, cCond, cTransp, cFrete, cTabPrc, cManTes, cManPrc, cBloqPrc, cCondInt, cProDupl, cSfaFpg, cSfaFpgIni, aPrdPrefix)
Function SetParam(cCodCli,cCliLoja, cCliente, cCond,cTes,nIVA,cProDupl,aPrdPrefix,lVenda)
Local cPrdPrefix := ""
Local cPrefix := ""
Local nPos := 0
Local nPreTimes := 0
Local nPreLen := 0
Local nPosPeso:= 0


dbSelectArea("HA1")
dbSetorder(1)
dbSeek(RetFilial("HA1")+cCodCli+cCliLoja)
cCliente:=HA1->HA1_COD + "/" + HA1->HA1_LOJA + " - " + HA1->HA1_NOME

cCond := GetParam("MV_SFAVIST","001")
if lVenda
	cTes := AllTrim(GetParam("MV_SFTSVN",""))  
Else
	cTes := AllTrim(GetParam("MV_SFTSDE",""))  
Endif
// Permite a duplicacao de produtos no pedido
cProDupl := AllTrim(GetParam("MV_PRODUPL","F")) 
//Indica de quantos em quantos produtos o browse sera paginado na tela de pedido (v.2)
nPagProd := Val(AllTrim(GetParam("MV_SFPAGIN","50")))
//Verifica permissao para campo Qtde com decimais
cQtdDec := AllTrim(GetParam("MV_SFAQTDE","T"))
//USA SO PARA MEXICO 
//dbSelectArea("HF4")
//dbSetOrder(1)
//if dbSeek(cTes)
//	nIVA := HF4->HF4_ALIQ
//Endif	

// Verifica a Utilizacao do Prefixo na Consulta de Produtos
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF")+"MV_SFPROPR")
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


Return Nil