//Ponto de Entrada: Calculo do preço de venda
Function PEPV0003(aColIte,aCabPed)

Local nPrBruto	:= aColIte[6,1]
Local cCondicao := aCabPed[7,1]
Local nAcresc 	:= 0
Local nDescCli 	:= 0
Local nPreco 	:= 0

dbSelectArea("HE4")
dbSetOrder(1)
dbSeek(cCondicao)
If HE4->(Found())
	nAcresc := HE4->E4_ACRESC
Endif

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(aCabPed[3,1]+aCabPed[4,1])	//Codigo + loja
If HA1->(Found())
	nDescCli := HA1->A1_DESC
Endif

nPreco := nPrBruto + (nPrBruto * (nAcresc / 100))
nPreco := nPreco - (nPreco * (nDescCli / 100))
nPreco := Round(nPreco,2)

Return nPreco