#include "fdpv108.ch"

// Carrega os Itens do Pedido no Array utilizado no Browser da Tela de Pedidos
Function PVItPed(aCabPed, aColIte,aItePed, cNumPedSrc)
Local cNumPed   := ""
Local cStPedido := ""

If aCabPed[2,1] == 4 // Ultimos Pedidos
	cNumPed := cNumPedSrc
Else				 //Alteracao
	cNumPed := aCabPed[1,1]
Endif                      

dbSelectArea("HC6")     
dbSetOrder(1)
If dbSeek(cNumPed)
	aSize(aItePed,0)
	if aCabPed[2,1] ==  4 	// Se for Ult. Pedidos
		aCabPed[10,1] := Date()
		//Carga de Ult. pedido com atualizacao dos precos
		PVUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido)
		Return nil
	Else      // Se for Alteracao do Pedido
		aCabPed[10,1] := HC6->C6_ENTREG						
	Endif						

	While !Eof() .And. HC6->C6_NUM == cNumPed
		dbSelectArea("HB1")
		dbSetOrder(1)
		if dbSeek(HC6->C6_PROD)
			aColIte[2,1]:= AllTrim(HB1->B1_DESC)
		Else  
		    //Produto nao encontrado, subtrair o item do Total e ler o proximo
			//Total pedido = Total pedido - (qtde * (preco - (preco * (desct / 100))))
			aCabPed[11,1] := aCabPed[11,1] - (HC6->C6_QTDVEN * Round((HC6->C6_PRCVEN - (HC6->C6_PRCVEN * (HC6->C6_DESC / 100))),2))
			aCabPed[12,1] := Round(aCabPed[11,1],2)
			dbSelectArea("HC6") 
			dbSkip()
			Loop
		Endif
				
     	For nI:=1 to Len(aColIte)
     		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
     			// Verifica Status do Item
     			If nI != 14
  					aColIte[nI,1]:= HC6->(FieldGet(aColIte[nI,2]))
  				Else
					If HC6->C6_STATUS = "A"
						cStPedido := STR0001 //"Aberto"
					ElseIf HC6->C6_STATUS = "R"
						cStPedido := STR0002 //"Elim. Resíduo"
					ElseIf HC6->C6_STATUS = "BE"
						cStPedido := STR0003 //"Bloq. Estoque"
					ElseIf HC6->C6_STATUS = "BC"
						cStPedido := STR0004 //"Bloq. Crédito"
					ElseIf HC6->C6_STATUS = "B"
						cStPedido := STR0005 //"Bloqueado"
					ElseIf HC6->C6_STATUS = "E"
						cStPedido := STR0006 //"Encerrado"
					ElseIf HC6->C6_STATUS = "L"
						cStPedido := STR0007 //"Liberado"
					ElseIf HC6->C6_STATUS = "PE"
						cStPedido := STR0008 //"Parc. Encerrado"
					Else
						cStPedido := STR0009    //"Indefinido"
					EndIf
					aColIte[nI,1] := cStPedido
  				EndIf
			Endif
		Next 

		// Adiciona o Item se nao for Item de Bonificacao
		If HC6->C6_BONIF <> 1
		//	AADD(aItePed,{AllTrim(HC6->C6_PROD),Alltrim(HB1->B1_DESC),HC6->C6_GRUPO,HC6->C6_QTDVEN,HC6->C6_TABELA,HC6->C6_PRCVEN, HC6->C6_DESC, HC6->C6_TES, HC6->C6_VALOR,"",0 })

			AADD(aItePed,Array(Len(aColIte)))
			For nI := 1 to Len(aColIte)
			  aItePed[Len(aItePed),nI] := aColIte[nI,1]
			Next

			//PVCalcPed(aCabPed,aColIte,aItePed,Len(aItePed),.T.,,.F.)
		EndIf

		dbSelectArea("HC6")
		dbSkip()
	Enddo
EndIf
Return Nil


//Carrega/atualiza precos do Ult. pedido
Function PVUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido)

While !Eof() .And. HC6->C6_NUM == cNumPed
	dbSelectArea("HB1")
	dbSetOrder(1)
	if dbSeek(HC6->C6_PROD)
		aColIte[2,1]:= AllTrim(HB1->B1_DESC)
	Else    //Produto nao encontrado na base atual, ler o proximo
		dbSelectArea("HC6") 
		dbSkip()
		Loop
	Endif
			
    For nI:=1 to Len(aColIte)
    	If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
     		If nI == 6 //Atualizar preco com o preco atual de tabela
               	HPR->( dbSetOrder(1) )
               	HPR->( dbSeek(HC6->C6_PROD+aCabPed[8,1]) )
               	If HPR->(Found())
	               	aColIte[nI,1] := HPR->PR_UNI
               	Else
               		aColIte[nI,1] := HC6->(FieldGet(aColIte[nI,2])) 
               	Endif
               	dbSelectArea("HC6")
       		ElseIf nI == 9 //Atualizar total do item
       			aColIte[nI,1] := aColIte[4,1] * aColIte[6,1]
  			ElseIf nI == 14// Verifica Status do Item
				If HC6->C6_STATUS = "A"
					cStPedido := STR0001 //"Aberto"
				ElseIf HC6->C6_STATUS = "R"
					cStPedido := STR0002 //"Elim. Resíduo"
				ElseIf HC6->C6_STATUS = "BE"
					cStPedido := STR0003 //"Bloq. Estoque"
				ElseIf HC6->C6_STATUS = "BC"
					cStPedido := STR0004 //"Bloq. Crédito"
				ElseIf HC6->C6_STATUS = "B"
					cStPedido := STR0005 //"Bloqueado"
				ElseIf HC6->C6_STATUS = "E"
					cStPedido := STR0006 //"Encerrado"
				ElseIf HC6->C6_STATUS = "L"
					cStPedido := STR0007 //"Liberado"
				ElseIf HC6->C6_STATUS = "PE"
					cStPedido := STR0008 //"Parc. Encerrado"
				Else
					cStPedido := STR0009    //"Indefinido"
				EndIf
				aColIte[nI,1] := cStPedido
			Else
  				aColIte[nI,1]:= HC6->(FieldGet(aColIte[nI,2]))				
  			EndIf
		Endif
	Next 

	// Adiciona o Item se nao for Item de Bonificacao
	If HC6->C6_BONIF <> 1

		AADD(aItePed,Array(Len(aColIte)))
		For nI := 1 to Len(aColIte)
		  aItePed[Len(aItePed),nI] := aColIte[nI,1]
		Next
		//Recalcula pedido c/ os novos precos
		PVCalcPed(aCabPed,aColIte,aItePed,Len(aItePed),.T.,,.F.)
	EndIf

	dbSelectArea("HC6")
	dbSkip()
Enddo

Return nil


//CAPTURA O CODIGO DO PEDIDO NO ARRAY NA LINHA SELECIONADA (Pedido ou Ult. Pedido)
Function PVNumPed(oBrw,aArray,cNumPed)
Local nLinha :=0
if Len(aArray)<=0
	MsgAlert(STR0010) //"Nenhum Pedido Selecionado"
	Return .F.
Endif
nLinha:=GridRow(oBrw)
cNumPed:=aArray[nLinha,1]
Return .T.

// FAIXA DE CODIGO DE PEDIDOS
Function PVProxPed(cNumPed)
Local nNumPed		:=0
Local lEncontrou	:= .F.

dbSelectArea("HA3")
dbGoTop()

if Val(HA3->A3_PROXPED) > Val(HA3->A3_PEDFIM)
	MsgAlert(STR0011) //"A Faixa de Código Pedido excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de Código de Pedido"
	Return .F.
Endif

cNumPed	:=	AllTrim(HA3->A3_PROXPED)
// -------------------------------------------------------------------------
// --> Faca ateh encontrar um Codigo Valido (Codigo nao existente na Tabeba) 
//     ou ter excedido a Faixa de Codigos.
// -------------------------------------------------------------------------
While lEncontrou == .F.
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(cNumPed)      
	if Found()
		nNumPed := Val(cNumPed)+1
		cNumPed:= StrZero(nNumPed,6)	
		If nNumPed > Val(HA3->A3_PEDFIM)
			MsgAlert(STR0011) //"A Faixa de Código Pedido excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de Código de Pedido" 
			Return .F.
		Endif
	Else
		lEncontrou :=.T.
	Endif
EndDo
Return .T.

//Atualiza o Prox. Pedido do HA3
Function PVAtuaProxPed(cNumPed)
Local nNumPed:=0
dbSelectArea("HA3")
dbGoTop()                
nNumPed:=Val(cNumPed) + 1
cNumPed:=StrZero(nNumPed,6)
HA3->A3_PROXPED :=cNumPed
dbCommit()

Return Nil

/*
Function PVMontaCabPed(aCabPed)

aSize(aCabPed,0)
// ---------------------- < - >  CABECALHO DO PEDIDO < - > ----------------------
/*    
Informacoes do Array do Cabec. do Pedido
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos (Campo da Tabela Associado HC5)
Linha Descricao
1 -   Código do Pedido
2 -   Operacao ( 1/2/3/4 )
3 -   Codigo do Cliente 
4 -   Loja do Cliente 
5 -   Codigo da Rota
6 -   Codigo do Roteiro
7 -   Cond. de Pagto. 
8 -   Tabela de Preco 
9 -   Observacao                               
10 -  Data de Entrega (Esse campo sera gravado na Tabela HC6.
11 -  Total do Pedido
12 -  Total Arredondado do Pedido

AADD(aCabPed,{cNumPed, 		HC5->(FieldPos("C5_NUM"))		})
AADD(aCabPed,{nOperacao,	0								})
AADD(aCabPed,{cCodCli,		HC5->(FieldPos("C5_CLI"))		})
AADD(aCabPed,{cLojaCli,		HC5->(FieldPos("C5_LOJA"))		})
AADD(aCabPed,{cCodRot,		0								})
AADD(aCabPed,{cIteRot,		0								})
AADD(aCabPed,{"",			HC5->(FieldPos("C5_COND"))		})
AADD(aCabPed,{"",			HC5->(FieldPos("C5_TAB"))		})
AADD(aCabPed,{space(60), 	HC5->(FieldPos("C5_MENNOTA"))	})
AADD(aCabPed,{NIL,0											})
AADD(aCabPed,{0.00,		  	0								})  
AADD(aCabPed,{0.00,		  	0								})

Return nil
*/
Function PVMontaColIte(aColIte)
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

*/
aSize(aColIte,0)

AADD(aColIte,{"",		HC6->(FieldPos("C6_PROD"))			})
AADD(aColIte,{"",		0 									})
AADD(aColIte,{"",		HC6->(FieldPos("C6_GRUPO"))			})
AADD(aColIte,{0.00,		HC6->(FieldPos("C6_QTDVEN"))		})
AADD(aColIte,{"",		HC6->(FieldPos("C6_TABELA"))		})
AADD(aColIte,{0.00,		HC6->(FieldPos("C6_PRCVEN"))		})
AADD(aColIte,{0.00,		HC6->(FieldPos("C6_DESC"))			})
AADD(aColIte,{"",		HC6->(FieldPos("C6_TES"))			})
AADD(aColIte,{0.00,		HC6->(FieldPos("C6_VALOR"))			})
AADD(aColIte,{"",		0									})
AADD(aColIte,{0,		HC6->(FieldPos("C6_BONIF"))			})
AADD(aColIte,{0,		HC6->(FieldPos("C6_QTDLIB"))		})
AADD(aColIte,{0,		HC6->(FieldPos("C6_QTDENT"))		})
AADD(aColIte,{"N",		HC6->(FieldPos("C6_STATUS"))		})

//PONTO DE ENTRADA: Complemento ou Alteracao do Array de Itens do Pedidos
#IFDEF _PEPV0007_
	//Objetivo:
	//Retorno: 
	uRet := PEPV0007(aColIte)
#ENDIF

Return Nil

//Calcula desconto conforme parametro (T=Protheus, F=Outros)
Function PVCalcDescto(aColIte,aItePed,nItePed,lAdcIte)
Local nTotItem := 0

If cCalcProtheus == "T"	//Desconto Protheus
	If lAdcIte
		// Total item = qtde * (preco - (preco * (desct / 100)))
		nTotItem := aColIte[4,1] * Round((aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100))),2)
	Else
		nTotItem := aItePed[nItePed,4] * Round((aItePed[nItePed,6] - (aItePed[nItePed,6] * (aItePed[nItePed,7] / 100))),2)
	Endif
Else	//Desconto Padrao
	If lAdcIte 
		// Total item = total item - (total item * (desct / 100))
		nTotItem := aColIte[9,1] - Round((aColIte[9,1] * (aColIte[7,1] / 100)),2)
	Else
		nTotItem := aItePed[nItePed,9] - Round((aItePed[nItePed,9] * (aItePed[nItePed,7] / 100)),2)
	Endif
Endif

Return nTotItem
                

Function PVCalcPed(aCabPed,aColIte,aItePed,nItePed,lAdcIte,aObj,lIncPed)
Local nVlrItem := 0
//PONTO DE ENTRADA: Calculos do Pedido
#IFDEF _PEPV0010_                
	//Objetivo: 
	//Retorno: 
	uRet := PEPV0010(aCabPed,aColIte,aItePed,nItePed,aObj,lAdcIte,lIncPed)
#ELSE
	If lAdcIte
		If aColIte[7,1] > 0
			nVlrItem := PVCalcDescto(aColIte,aItePed,nItePed,lAdcIte)
			//aCabPed[11,1] := aCabPed[11,1] + (aColIte[9,1] - (aColIte[9,1] * (aColIte[7,1] / 100)))
			aCabPed[11,1] := aCabPed[11,1] + nVlrItem
		Else
			aCabPed[11,1] := aCabPed[11,1] + aColIte[9,1]
		EndIf
		aCabPed[12,1] := Round(aCabPed[11,1],2)
	Else
		if aItePed[nItePed,7] > 0
			nVlrItem := PVCalcDescto(aColIte,aItePed,nItePed,lAdcIte)
			//aCabPed[11,1] := aCabPed[11,1] - (aItePed[nItePed,9] - (aItePed[nItePed,9] * (aItePed[nItePed,7] / 100)))
			aCabPed[11,1] := aCabPed[11,1] - nVlrItem
		else
			aCabPed[11,1] := aCabPed[11,1] - aItePed[nItePed,9]
		endif
		aCabPed[12,1] := Round(aCabPed[11,1],2)
	Endif		
	if lIncPed
		SetText(aObj[1,4],aCabPed[12,1])
		//SetArray(aObj[3,1],aItePed)
	Endif
#ENDIF
Return Nil