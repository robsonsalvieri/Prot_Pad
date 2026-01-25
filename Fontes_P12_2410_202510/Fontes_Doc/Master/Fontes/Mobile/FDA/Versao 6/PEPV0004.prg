//Ponto de Entrada: Recalculo do total do item c/ IPI (inclusao do item)
Function PEPV0004(aCabPed,aColIte)

Local nTotItem := 0
Local nIPI := 0
    
dbSelectArea("HB1")
dbSetOrder(1)      
dbSeek(aColIte[1,1])
If Found()
	nIPI := HB1->B1_IPI
Endif

If aColIte[7,1] > 0 	//desconto do item
	nTotItem := (aColIte[9,1] - (aColIte[9,1] * (aColIte[7,1] / 100)))
	nTotItem := nTotItem + (nTotItem * (nIPI / 100))
	aCabPed[11,1] := aCabPed[11,1] + nTotItem
Else 
	nTotItem := aColIte[9,1] + (aColIte[9,1] * (nIPI / 100))	
	aCabPed[11,1] := aCabPed[11,1] + nTotItem
Endif              

//Total arredondado
aCabPed[12,1] := Round(aCabPed[11,1],2)

Return aCabPed