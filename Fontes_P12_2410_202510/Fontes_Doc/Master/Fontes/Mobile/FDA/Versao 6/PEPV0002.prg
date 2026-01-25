//Ponto de Entrada: Inicializar campos do pedido
Function PEPV0002(aCabPed)

//Carregar observacao inicial
dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(aCabPed[3,1]+aCabPed[4,1])
If HA1->(Found())
	aCabPed[9,1] := HA1->A1_OBSERV1
Endif                    

//Iniciar data de entrega com data atual + 7
aCabPed[10,1] := Date() + 7

Return aCabPed