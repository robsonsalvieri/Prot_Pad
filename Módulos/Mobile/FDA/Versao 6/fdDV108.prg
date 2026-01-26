#INCLUDE "FDPV108.ch"
// Carrega os Itens do Pedido no Array utilizado no Browser da Tela de Pedidos
Function PDItPed(aCabPed, aColIte,aItePed, cNumPedSrc)
Local cNumPed   := ""
Local cStPedido := ""
Local cUmPeso := ""
Local nPosPeso:= 0

If aCabPed[2,1] == 4 // Ultimos Pedidos
	cNumPed := cNumPedSrc
Else				 //Alteracao
	cNumPed := aCabPed[1,1]
Endif                      

dbSelectArea("HD1")     
dbSetOrder(1)
If dbSeek(cNumPed)
	aSize(aItePed,0)

	// Parametro do Peso	
	HCF->(dbSetOrder(1))
	If HCF->(dbSeek("MV_SFAPESO"))
		nPosPeso := At(",",HCF->CF_VALOR)
		cUmPeso := Substr(HCF->CF_VALOR,nPosPeso+1, 1)
	Else 
		cUmPeso := "1"
	EndIf	

	//Se for Ult. Pedidos ou Consulta de Itens do ult. pedido
	If aCabPed[2,1] == 4 .Or. aCabPed[2,1] == 3
		aCabPed[10,1] := dDataBase
		//Carga de Ult. pedido com atualizacao dos precos
		PDUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido,cUmPeso)
		Return nil
	Else      // Se for Alteracao do Pedido
		aCabPed[10,1] := dDataBase				
	Endif						

	While !Eof() .And. HD1->D1_DOC == cNumPed
		dbSelectArea("HB1")
		dbSetOrder(1)
		if dbSeek(HD1->D1_COD)
			aColIte[2,1]:= AllTrim(HB1->B1_DESC)


			// Calculo do Peso			
			If HB1->(FieldPos("B1_PBRUTO")) > 0
				nPrdPeso := HB1->B1_PBRUTO
				If 	cUmPeso = "1"
					aCabPed[17,1] := aCabPed[17,1] + (HD1->D1_QUANT * nPrdPeso)
				Else
					If HB1->B1_TIPCONV = "M"
						nPrdPeso := Round(nPrdPeso * HB1->B1_CONV,2)
					Else
						nPrdPeso := Round(nPrdPeso / HB1->B1_CONV,2)
					EndIf
					aCabPed[17,1] := aCabPed[17,1] + (HD1->D1_QUANT * nPrdPeso)
				EndIf
			EndIf

		Else  
		    //Produto nao encontrado, subtrair o item do Total e ler o proximo
			//Total pedido = Total pedido - (qtde * (preco - (preco * (desct / 100))))
			//aCabPed[11,1] := aCabPed[11,1] - (HD1->D1_QUANT * HD1->D1_VUNIT )
			//aCabPed[12,1] := Round(aCabPed[11,1],2)
			dbSelectArea("HD1") 
			dbSkip()
			Loop
		Endif
				
     	For nI:=1 to Len(aColIte)
     		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
     			// Verifica Status do Item
     			If nI != 14
  					aColIte[nI,1]:= HD1->(FieldGet(aColIte[nI,2]))
  				Else
					cStPedido := STR0009    //"Indefinido"
					aColIte[nI,1] := cStPedido
  				EndIf
			Endif
		Next 


		AADD(aItePed,Array(Len(aColIte)))
		For nI := 1 to Len(aColIte)
		  aItePed[Len(aItePed),nI] := aColIte[nI,1]
		Next
		
		PVCalcPed(aCabPed,aColIte,aItePed,Len(aItePed),.T.,,.F.)


		dbSelectArea("HD1")
		dbSkip()
	Enddo
EndIf
Return Nil


//Carrega/atualiza precos do Ult. pedido
Function PDUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido, cUmPeso)

While !Eof() .And. HD1->D1_DOC == cNumPed
	dbSelectArea("HB1")
	dbSetOrder(1)
	if dbSeek(HD1->D1_COD)
		aColIte[2,1]:= AllTrim(HB1->B1_DESC)
		
		If HB1->(FieldPos("B1_PBRUTO")) > 0
			nPrdPeso := HB1->B1_PBRUTO
			If 	cUmPeso = "1"
				aCabPed[17,1] := aCabPed[17,1] + (HD1->D1_QUANT * nPrdPeso)
			Else
				If HB1->B1_TIPCONV = "M"
					nPrdPeso := Round(nPrdPeso * HB1->B1_CONV,2)
				Else
					nPrdPeso := Round(nPrdPeso / HB1->B1_CONV,2)
				EndIf
				aCabPed[17,1] := aCabPed[17,1] + (HD1->D1_QTDVEN * nPrdPeso)
			EndIf
		EndIf


	Else    //Produto nao encontrado na base atual, ler o proximo
		dbSelectArea("HD1") 
		dbSkip()
		Loop
	Endif
			
    For nI:=1 to Len(aColIte)
    	If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
     		If nI == 6 //Atualizar preco com o preco atual de tabela
               	HPR->( dbSetOrder(1) )
               	HPR->( dbSeek(HD1->D1_COD+aCabPed[8,1]) )
               	If HPR->(Found())
	               	aColIte[nI,1] := HPR->PR_UNI
               	Else
               		aColIte[nI,1] := HD1->(FieldGet(aColIte[nI,2])) 
               	Endif
               	dbSelectArea("HD1")
       		ElseIf nI == 9 //Atualizar total do item
       			aColIte[nI,1] := aColIte[4,1] * aColIte[6,1]
  			ElseIf nI == 14// Verifica Status do Item
				cStPedido := STR0009    //"Indefinido"
				aColIte[nI,1] := cStPedido
			Else
  				aColIte[nI,1]:= HD1->(FieldGet(aColIte[nI,2]))				
  			EndIf
		Endif
	Next 

	AADD(aItePed,Array(Len(aColIte)))
	For nI := 1 to Len(aColIte)
	  aItePed[Len(aItePed),nI] := aColIte[nI,1]
	Next
	//Recalcula pedido c/ os novos precos
	PVCalcPed(aCabPed,aColIte,aItePed,Len(aItePed),.T.,,.F.)

	dbSelectArea("HD1")
	dbSkip()
Enddo

Return nil

//CAPTURA O CODIGO DO PEDIDO NO ARRAY NA LINHA SELECIONADA (Pedido ou Ult. Pedido)
Function PDNumPed(oBrw,aArray,cNumDev)
Local nLinha :=0
if Len(aArray)<=0
	MsgAlert(STR0010) //"Nenhum Pedido Selecionado"
	Return .F.
Endif
nLinha:=GridRow(oBrw)
cNumDev:=aArray[nLinha,1]
Return .T.

// FAIXA DE CODIGO DE PEDIDOS
Function PDProxPed(cNumDev)
Local nNumDev		:=0
Local lEncontrou	:= .F.

cNumDev	:=	"000001"
// -------------------------------------------------------------------------
// --> Faca ateh encontrar um Codigo Valido (Codigo nao existente na Tabeba) 
//     ou ter excedido a Faixa de Codigos.
// -------------------------------------------------------------------------
While lEncontrou == .F.
	dbSelectArea("HF1")
	dbSetOrder(1)
	dbSeek(cNumDev)      
	if Found()
		nNumDev := Val(cNumDev)+1
		cNumDev:= StrZero(nNumDev,6)	
	Else
		lEncontrou :=.T.
	Endif
EndDo
Return .T.

//Atualiza o Prox. Pedido do HA3
Function PDAtuaProxPed(cNumPed)
Return Nil

Function PDMontaColIte(aColIte)
/*
// ---------------------- < - >  COLUNAS DO ARRAY DO ITEM DO PEDIDO  < - > ----------------------
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos ( Campo da Tabela Associado)
Linha Descricao
1 -   Código do Produto
2 -   Descricao do Produto
3 -   Grupo do Produto
4 -   Qtde de Venda
5 -   Tabela de Preco
6 -   Preco de Venda
7 -   Desconto 
8 -   Tes                               
9 -   Valor do Item
10 -  Codigo da Bonificacao ( Se for Item Bonificado )
11 -  Bonificacao
12 -  Quantidade Liberada
13 -  Quantidade Entregue
14 -  Status 
ESPECIFICO DA EFFEM
15 - Percentual do IVA
16 - Valor Total do item com IVA       
*/
Local cTesDev := GetParam("MV_FDATDEV","009")
aSize(aColIte,0)

AADD(aColIte,{"",		HD1->(FieldPos("D1_COD"))			})
AADD(aColIte,{"",		0 									})
AADD(aColIte,{"",		0									})
AADD(aColIte,{0.00,		HD1->(FieldPos("D1_QUANT"))			})
AADD(aColIte,{"",		0									})
AADD(aColIte,{0.00,		HD1->(FieldPos("D1_VUNIT"))			})
AADD(aColIte,{0.00,		0									})
AADD(aColIte,{cTesDev,	HD1->(FieldPos("D1_TES"))			})
AADD(aColIte,{0.00,		HD1->(FieldPos("D1_TOTAL"))			})
AADD(aColIte,{"",		0									})
AADD(aColIte,{0,		0									})
AADD(aColIte,{0,		0									})
AADD(aColIte,{0,		0									})
AADD(aColIte,{"N",		0									})

AADD(aColIte,{0,		HD1->(FieldPos("D1_IVA"))			})
AADD(aColIte,{0,		0									})

Return Nil

