//Ponto de Entrada: Recalculo do total do pedido -exclusao do item
Function PEPV0005( aCabPed, aItePed, nItePed )

Local nTotItem := 0
Local nIPI := 0
    
dbSelectArea("HB1")
dbSetOrder(1)      
dbSeek(aItePed[nItePed,1])
If Found()
	nIPI := HB1->B1_IPI
Endif

//Exclui valor do total do pedido
If aItePed[nItePed,7] > 0             
	nTotItem := aItePed[nItePed,9] - (aItePed[nItePed,9] * (aItePed[nItePed,7] / 100))
	nTotItem := nTotItem + (nTotItem * (nIPI / 100))        
	aCabPed[11,1] := aCabPed[11,1] - nTotItem
Else
	nTotItem := aItePed[nItePed,9] + (aItePed[nItePed,9] * (nIPI / 100))    
	aCabPed[11,1] := aCabPed[11,1] - nTotItem
Endif              

//Total arredondado
aCabPed[12,1] := Round(aCabPed[11,1],2)

Return nil
