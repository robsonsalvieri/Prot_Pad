#INCLUDE "SFPV108.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVItPed   บAutor  ณMarcelo Vieira      บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os Itens do Pedido no Array utilizado no            บฑฑ
ฑฑบ          ณ Browser da Tela de Pedidos                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVItPed(aCabPed, aColIte,aItePed, cNumPedSrc)

Local cNumPed   := ""
Local cStPedido := ""
Local cUmPeso   := ""
Local nPrdPeso  := 0
Local nPosPeso  := 0

If aCabPed[2,1] == 4 // Ultimos Pedidos
	cNumPed := cNumPedSrc
Else				 //Alteracao
	cNumPed := aCabPed[1,1]
Endif

dbSelectArea("HC6")
dbSetOrder(1)
If dbSeek(RetFilial("HC6") + cNumPed)
	aSize(aItePed,0)
	
	// Parametro do Peso
	HCF->(dbSetOrder(1))
	If HCF->(dbSeek(RetFilial("HCF") + "MV_SFAPESO"))
		nPosPeso := At(",",HCF->HCF_VALOR)
		cUmPeso := Substr(HCF->HCF_VALOR,nPosPeso+1, 1)
	Else
		cUmPeso := "1"
	EndIf
	
	//Se for Ult. Pedidos
	If aCabPed[2,1] == 4
		aCabPed[10,1] := Date()
		aCabPed[11,1] := 0
		aCabPed[12,1] := 0
		//Carga de Ult. pedido com atualizacao dos precos
		PVUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido,cUmPeso)
		Return nil
	Else      // Consulta dos itens
		aCabPed[10,1] := HC6->HC6_ENTREG
	Endif
	
	While !Eof() .And. HC6->HC6_NUM == cNumPed
		dbSelectArea("HB1")
		dbSetOrder(1)
		if dbSeek(RetFilial("HB1") + HC6->HC6_PROD)
			aColIte[2,1]:= AllTrim(HB1->HB1_DESC)
			
			// Calculo do Peso
			If HB1->(FieldPos("HB1_PBRUTO")) > 0
				nPrdPeso := HB1->HB1_PBRUTO
				
				If cUmPeso = "2"
					If HB1->HB1_TIPCON = "M"
						nPrdPeso := Round(nPrdPeso * HB1->HB1_CONV,2)
					Else
						nPrdPeso := Round(nPrdPeso / HB1->HB1_CONV,2)
					EndIf
					aCabPed[17,1] := aCabPed[17,1] + (HC6->HC6_QTDVEN * nPrdPeso)
				Else
					aCabPed[17,1] := aCabPed[17,1] + (HC6->HC6_QTDVEN * nPrdPeso)
				EndIf
				
			EndIf
			
		Else
			//Produto nao encontrado, subtrair o item do Total e ler o proximo
			//Total pedido = Total pedido - (qtde * (preco - (preco * (desct / 100))))
			aCabPed[11,1] := aCabPed[11,1] - (HC6->HC6_QTDVEN * Round((HC6->HC6_PRCVEN - (HC6->HC6_PRCVEN * (HC6->HC6_DESC / 100))),TamADVC("HC5_VALOR",2)))
			aCabPed[12,1] := Round(aCabPed[11,1],TamADVC("HC5_VALOR",2))
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
					cStPedido := LoadStatus(HC6->HC6_STATUS)
					aColIte[nI,1] := HC6->HC6_STATUS
					aColIte[15,1] := cStPedido
				EndIf
			Endif
		Next
		
		//Atualiza Peso do Item
		aColIte[17,1] := aCabPed[17,1]
		
		// Adiciona o Item se nao for Item de Bonificacao
		If HC6->HC6_BONIF <> 1
			//	AADD(aItePed,{AllTrim(HC6->HC6_PROD),Alltrim(HB1->HB1_DESC),HC6->HC6_GRUPO,HC6->HC6_QTDVEN,HC6->HC6_TABELA,HC6->HC6_PRCVEN, HC6->HC6_DESC, HC6->HC6_TES, HC6->HC6_VALOR,"",0 })
			
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVUltPed  บAutor  ณMarcelo Vieira      บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega/atualiza precos do Ult. pedido                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVUltPed(aCabPed,aColIte,aItePed,cNumPed,cStPedido, cUmPeso)

Local cQtd		:= ""
Local nPrdPeso  := 0

While !Eof() .And. HC6->HC6_NUM == cNumPed
	dbSelectArea("HB1")
	dbSetOrder(1)
	if dbSeek(RetFilial("HB1") + HC6->HC6_PROD)
		aColIte[2,1]:= AllTrim(HB1->HB1_DESC)
		
		If HB1->(FieldPos("HB1_PBRUTO")) > 0
			nPrdPeso := HB1->HB1_PBRUTO
			If 	cUmPeso = "2"
				If HB1->HB1_TIPCON = "M"
					nPrdPeso := Round(nPrdPeso * HB1->HB1_CONV,2)
				Else
					nPrdPeso := Round(nPrdPeso / HB1->HB1_CONV,2)
				EndIf
				aCabPed[17,1] := aCabPed[17,1] + (HC6->HC6_QTDVEN * nPrdPeso)
			Else
				aCabPed[17,1] := aCabPed[17,1] + (HC6->HC6_QTDVEN * nPrdPeso)
			EndIf
		EndIf
		
		
	Else    //Produto nao encontrado na base atual, ler o proximo
		dbSelectArea("HC6")
		dbSkip()
		Loop
	Endif
	
	For nI:=1 to Len(aColIte)
		If aColIte[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
			If nI == 6 //Atualizar preco com o preco atual de tabela
				HPR->( dbSetOrder(1) )
				If HPR->(FieldPos("HPR_INDLOT")) != 0
					cQtd	:= StrTran( StrZero(HC6->HC6_QTDVEN,Len(HPR->HPR_INDLOT),2), ",", ".")
					HPR->( dbSeek(RetFilial("HPR") + HC6->HC6_PROD + aCabPed[8,1] + cQtd ) )
				Else
					HPR->( dbSeek(RetFilial("HPR") + HC6->HC6_PROD + aCabPed[8,1] ) )
				EndIf
				If HPR->(Found())
					aColIte[nI,1] := HPR->HPR_UNI
				Else
					aColIte[nI,1] := HC6->(FieldGet(aColIte[nI,2]))
				Endif
				dbSelectArea("HC6")
			ElseIf nI == 9 //Atualizar total do item
				aColIte[nI,1] := aColIte[4,1] * aColIte[6,1]
			ElseIf nI == 14// Verifica Status do Item
				
				cStPedido := LoadStatus(HC6->HC6_STATUS)
				aColIte[nI,1] := If(aCabPed[2,1] == 4,"N", HC6->HC6_STATUS)
				aColIte[15,1] := If(aCabPed[2,1] == 4,"Novo", cStPedido )
			Else
				aColIte[nI,1]:= HC6->(FieldGet(aColIte[nI,2]))
			EndIf
		Endif
	Next
	
	// Adiciona o Item se nao for Item de Bonificacao
	If HC6->HC6_BONIF <> 1
		
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVNumPed  บAutor  ณMarcelo Vieira      บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCaptura o codigo do pedido no array na linha selecionada    บฑฑ
ฑฑบ          ณ(Pedido ou Ult.Pedido)                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVNumPed(oBrw,aArray,cNumPed)

Local nLinha :=0

if Len(aArray)<=0
	MsgAlert(STR0010) //"Nenhum Pedido Selecionado"
	Return .F.
Endif
nLinha:=GridRow(oBrw)
cNumPed:=aArray[nLinha,1]

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPVProxPed บAutor  ณMarcelo Vieira      บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaixa de Codigo de Pedidos                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVProxPed(cNumPed)

Local nNumPed		:=0
Local lEncontrou	:= .F.

dbSelectArea("HA3")
dbSeek(RetFilial("HA3"))

If Val(HA3->HA3_PROPED) > Val(HA3->HA3_PEDFIM)
	MsgAlert(STR0011) //"A Faixa de C๓digo Pedido excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C๓digo de Pedido"
	Return .F.
Endif

cNumPed	:=	AllTrim(HA3->HA3_PROPED)
// -------------------------------------------------------------------------
// --> Faca ateh encontrar um Codigo Valido (Codigo nao existente na Tabeba)
//     ou ter excedido a Faixa de Codigos.
// -------------------------------------------------------------------------
While lEncontrou == .F.
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(RetFilial("HC5") + cNumPed)
	if Found()
		nNumPed := Val(cNumPed)+1
		cNumPed:= StrZero(nNumPed,6)
		If nNumPed > Val(HA3->HA3_PEDFIM)
			MsgAlert(STR0011) //"A Faixa de C๓digo Pedido excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C๓digo de Pedido"
			Return .F.
		Endif
	Else
		lEncontrou :=.T.
	Endif
EndDo

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบFuncao    ณPVAtuaProxPed บAutor  ณMarcelo Vieira      บ Data ณ         บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o Prox. Pedido do HA3                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVAtuaProxPed(cNumPed)

Local nNumPed:=0

dbSelectArea("HA3")
dbSeek(RetFilial("HA3"))
//dbGoTop()
nNumPed:=Val(cNumPed) + 1
cNumPed:=StrZero(nNumPed,6)
HA3->HA3_PROPED :=cNumPed
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
1 -   C๓digo do Pedido
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

AADD(aCabPed,{cNumPed, 		HC5->(FieldPos("HC5_NUM"))		})
AADD(aCabPed,{nOperacao,	0								})
AADD(aCabPed,{cCodCli,		HC5->(FieldPos("HC5_CLI"))		})
AADD(aCabPed,{cLojaCli,		HC5->(FieldPos("HC5_LOJA"))		})
AADD(aCabPed,{cCodRot,		0								})
AADD(aCabPed,{cIteRot,		0								})
AADD(aCabPed,{"",			HC5->(FieldPos("HC5_COND"))		})
AADD(aCabPed,{"",			HC5->(FieldPos("HC5_TAB"))		})
AADD(aCabPed,{space(60), 	HC5->(FieldPos("HC5_MENOTA"))	})
AADD(aCabPed,{NIL,0											})
AADD(aCabPed,{0.00,		  	0								})
AADD(aCabPed,{0.00,		  	0								})

Return nil
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบFuncao    ณPVAtuaProxPed บAutor  ณMarcelo Vieira      บ Data ณ         บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o Prox. Pedido do HA3                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PVMontaColIte(aColIte)
/*
// ---------------------- < - >  COLUNAS DO ARRAY DO ITEM DO PEDIDO  < - > ----------------------
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos ( Campo da Tabela Associado)
Linha Descricao
1 -   C๓digo do Produto
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
15 -  Descricao do Status
16 -  Preco unitario
17 -  Peso Bruto

*/
aSize(aColIte,0)

AADD(aColIte,{"",		HC6->(FieldPos("HC6_PROD"))			}) // 01
AADD(aColIte,{"",		0 									}) // 02
AADD(aColIte,{"",		HC6->(FieldPos("HC6_GRUPO"))		}) // 03
AADD(aColIte,{0.00,		HC6->(FieldPos("HC6_QTDVEN"))		}) // 04
AADD(aColIte,{"",		HC6->(FieldPos("HC6_TABELA"))		}) // 05
AADD(aColIte,{0.00,		HC6->(FieldPos("HC6_PRCVEN"))		}) // 06
AADD(aColIte,{0.00,		HC6->(FieldPos("HC6_DESC"))			}) // 07
AADD(aColIte,{"",		HC6->(FieldPos("HC6_TES"))			}) // 08
AADD(aColIte,{0.00,		HC6->(FieldPos("HC6_VALOR"))		}) // 09
AADD(aColIte,{"",		0									}) // 10
AADD(aColIte,{0,		HC6->(FieldPos("HC6_BONIF"))		}) // 11
AADD(aColIte,{0,		HC6->(FieldPos("HC6_QTDLIB"))		}) // 12
AADD(aColIte,{0,		HC6->(FieldPos("HC6_QTDENT"))		}) // 13
AADD(aColIte,{"N",		HC6->(FieldPos("HC6_STATUS"))		}) // 14
AADD(aColIte,{"",		0		}) 						       // 15
AADD(aColIte,{0.00,		HC6->(FieldPos("HC6_PRUNIT"))		}) // 16
AADD(aColIte,{0.00,		0		})                             // 17 - Peso
AADD(aColIte,{0.00,		0		})                             // 18 - Quantidade auxiliar

//PONTO DE ENTRADA: Complemento ou Alteracao do Array de Itens do Pedidos
#IFDEF _PEPV0007_
	//Objetivo:
	//Retorno:
	uRet := PEPV0007(aColIte)
#ENDIF
If ExistBlock("SFAPV004")
	aColIte := ExecBlock("SFAPV004", .F., .F., {aColIte})
EndIf
Return Nil

//Calcula desconto conforme parametro (T=Protheus, F=Outros)
Function PVCalcDescto(aColIte,aItePed,nItePed,lAdcIte)
Local nTotItem := 0

If cCalcProtheus == "T"	//Desconto Protheus
	If lAdcIte
		// Total item = qtde * (preco - (preco * (desct / 100)))
		nTotItem := aColIte[4,1] * Round((aColIte[6,1] - (aColIte[6,1] * (aColIte[7,1] / 100))),TamADVC("HC6_VALOR",2))
	Else
		nTotItem := aItePed[nItePed,4] * Round((aItePed[nItePed,6] - (aItePed[nItePed,6] * (aItePed[nItePed,7] / 100))),TamADVC("HC6_VALOR",2))
	Endif
Else	//Desconto Padrao
	If lAdcIte
		// Total item = total item - (total item * (desct / 100))
		nTotItem := aColIte[9,1] - Round((aColIte[9,1] * (aColIte[7,1] / 100)),TamADVC("HC6_VALOR",2))
	Else
		nTotItem := aItePed[nItePed,9] - Round((aItePed[nItePed,9] * (aItePed[nItePed,7] / 100)),TamADVC("HC6_VALOR",2))
	Endif
Endif

Return nTotItem


Function PVCalcPed(aCabPed,aColIte,aItePed,nItePed,lAdcIte,aObj,lIncPed)
Local nVlrItem := 0
Local nSubTotal:= 0
Local nValDescIte := 0
Local nDescPed :=0
Local nValAcreIte := 0
Local nAcrePed := 0
//PONTO DE ENTRADA: Calculos do Pedido
#IFDEF _PEPV0010_
	//Objetivo:
	//Retorno:
	uRet := PEPV0010(aCabPed,aColIte,aItePed,nItePed,aObj,lAdcIte,lIncPed)
#ELSE
	
	For ni := 1 To Len(aItePed)
		nSubTotal += aItePed[ni,16] * aItePed[ni,4]
		//Calcula somente o que nao for item de bonificacao
		If aItePed[ni,11] <> 1
			If aItePed[ni,16] > 0 .And. aItePed[ni,6] > 0
				nValDescIte := 0
				nValAcreIte := 0
				If aItePed[ni,16] > aItePed[ni,6] //Se o preco de tabela for maior que o preco de venda
					nValDescIte := Round( aItePed[ni,4] * (aItePed[ni,16] - aItePed[ni,6]) ,TamADVC("HC6_PRCVEN",2))			
				ElseIf aItePed[ni,6] > aItePed[ni,16] //Se o preco de venda for maior que o preco de tabela
					nValAcreIte := Round( aItePed[ni,4] * (aItePed[ni,6] - aItePed[ni,16]) ,TamADVC("HC6_PRCVEN",2))					
				EndIf
			nDescPed += nValDescIte
			nAcrePed += nValAcreIte
		        Endif
		Endif
	Next

	If lAdcIte
		aCabPed[11,1] := (nSubTotal + nAcrePed) - nDescPed
	Else
		aCabPed[11,1] := (nSubTotal + nAcrePed) - nDescPed
	Endif
	
	aCabPed[12,1] := Round(aCabPed[11,1],TamADVC("HC5_VALOR",2))
	if lIncPed
		SetText(aObj[1,4],aCabPed[12,1])
		//SetArray(aObj[3,1],aItePed)
	Endif
#ENDIF

Return Nil
