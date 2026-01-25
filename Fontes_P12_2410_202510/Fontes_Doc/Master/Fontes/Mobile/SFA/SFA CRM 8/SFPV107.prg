#INCLUDE "SFPV107.ch"
#include "eADVPL.ch"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
±±
±± @1.  PVPrepPed -> Funcao que Prepara a Entrada e a Saida da tela de Pedido
±± @2.  PVNumPed -> Captura o Codigo do Pedido do Array na Linha Selecionada
±±      (Caso seja Alteracao ou Ult. Pedidos)
±± @3.  PVProxPed -> Controle da Faixa de Cod. de Pedido, capturando o CodProxPed 
±± @4.  PVAtuaProxPed -> Controle da Faixa de Cod. de Pedido, atualizando o CodProxPed 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ Prep. Pedidos       ≥Autor - Paulo Lima   ≥ Data ≥27/06/02 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Modulo de Pedidos        					 			  ≥±±
±±≥			 ≥ PVPrePed  -> Prepara a Entrada e Saida da Tela de Pedidos  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFA CRM 6.0                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥NOperacao 1- Inclusao /2 - Alteracao /3 - Ult.Pedido(Cons.) ¥±±
±±≥			 ≥4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ¥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista    ≥ Data   ≥Motivo da Alteracao                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PVPrepPed(nOperacao,oBrwPedido,aPedido,oBrwUltPed,aUltPed,cNumPed,cCodCli, cLojaCli, cCodPer, cCodRot, cIteRot, aClientes, nCliente, oCliente)
//Variaveis Locais
Local aCabPed	:= {}, aItePed	:= {}, aColIte := {}, aCond :={}, aTab	:= {}
Local cObs := "", cNumPedSrc := ""
Local nTotPed :=0.00, nRTotPed :=0.00 //NRTotPed Total do Pedido Arrendondado
Local nCond	:= 1, nTab := 1, nUltPedRow := 0, nI:=1
Local dData := Date()
Local aRestCab	:=	RestoreArray("SaveCab")
Local aRestIte	:=	RestoreArray("SaveIte")
Local lRestaura	:=	.F.

RegisterArray("SaveCab",aCabPed)
RegisterArray("SaveIte",aItePed)
If ValType(aRestCab) == "A" .And. !Empty(aRestCab)
	If Len(aRestCab)>=4
		If AllTrim(aRestCab[3,1])==AllTrim(cCodCli) .And. Alltrim(aRestCab[4,1]) == AllTrim(cLojaCli) 
			lRestaura := .T.
			aCabPed := aRestCab
			If ValType(aRestIte) == "A" .And. !Empty(aRestIte)
				aItePed := aRestIte
			EndIf
		EndIf
	EndIf
EndIf

// Verifica se existe alguma ocorrencia de nao positivacao
dbSelectArea("HA1")
dbSetOrder(1)
If dbSeek(RetFilial("HA1") + cCodCli + cLojaCli)
	If HA1->HA1_FLGVIS = "2"
		If MsgYesorNo(STR0001, STR0002) //"Existe ocorrencia para este cliente. Deseja exclui-la ?"###"Ocorrencia"
			ACGrvTabOco(cCodPer, cCodRot, cIteRot,"0","", .F.)
			GrvAtend(4, , "", HA1->HA1_COD, HA1->HA1_LOJA,)
			aClientes[nCliente,1]:="NVIS"
			// Exclui a ocorrencia
			dbSelectArea("HD5")
			dbSetOrder(1)
			If dbSeek(RetFilial("HD5") + HA1->HA1_COD + HA1->HA1_LOJA + DtoS(dData))
				dbDelete()
			EndIf
		Else
			Return Nil
		EndIf
	EndIf
EndIf

// ---------------------- < - >  CABECALHO DO PEDIDO < - > ----------------------
/*    
Informacoes do Array do Cabec. do Pedido
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos (Campo da Tabela Associado HC5)
Linha Descricao
1 -   CÛdigo do Pedido
2 -   Operacao ( 1/2/3/4 )
3 -   Codigo do Cliente 
4 -   Loja do Cliente 
5 -   Codigo da Rota
6 -   Codigo do Roteiro
7 -   Cond. de Pagto. 
8 -   Tabela de Preco 
9 -   Observacao                               
10 -  Data de Entrega (Esse campo sera gravado na Tabela HC6)
11 -  Total do Pedido
12 -  Total Arredondado do Pedido
13 -  Tranportadora do Pedido
14 -  Valor da Indenizacao
15 -  Forma de Pagamento
16 -  Tipo de Frete
17 -  Peso do Pedido
*/

/*
cNumPed:
1 - Incluir Ped.
2 - Alterar Ped.
3 - Visualizar Itens
4 - Copiar Ped.
5 - Visualizar Ped.
*/

If !lRestaura
	AADD(aCabPed,{cNumPed, 						HC5->(FieldPos("HC5_NUM"))		}) // 01
	AADD(aCabPed,{nOperacao,					0								}) // 02
	AADD(aCabPed,{cCodCli,						HC5->(FieldPos("HC5_CLI"))		}) // 03
	AADD(aCabPed,{cLojaCli,						HC5->(FieldPos("HC5_LOJA"))		}) // 04
	AADD(aCabPed,{cCodRot,						0								}) // 05
	AADD(aCabPed,{cIteRot,						0								}) // 06
	AADD(aCabPed,{"",							HC5->(FieldPos("HC5_COND"))		}) // 07
	AADD(aCabPed,{"",							HC5->(FieldPos("HC5_TAB"))		}) // 08
	AADD(aCabPed,{space(Len(HC5->HC5_MENOTA)), HC5->(FieldPos("HC5_MENOTA"))	}) // 09
	AADD(aCabPed,{Date(),						0								}) // 10
	AADD(aCabPed,{0.00,		  					0								}) // 11
	AADD(aCabPed,{0.00,		  					0								}) // 12
	AADD(aCabPed,{space(Len(HC5->HC5_TRANSP)),	HC5->(FieldPos("HC5_TRANSP"))	}) // 13
	AADD(aCabPed,{0.00                       , HC5->(FieldPos("HC5_DESCONT"))	}) // 14
	AADD(aCabPed,{""                         , HC5->(FieldPos("HC5_FORMPG"))	}) // 15
	AADD(aCabPed,{"F"                        , HC5->(FieldPos("HC5_TPFRET"))	}) // 16
	AADD(aCabPed,{0.00                        , 0								}) // 17
	AADD(aCabPed,{0.00                        , HC5->(FieldPos("HC5_DESC1"))	}) // 18
	AADD(aCabPed,{0.00                        , HC5->(FieldPos("HC5_DESC2"))	}) // 19
	AADD(aCabPed,{0.00                        , HC5->(FieldPos("HC5_DESC3"))	}) // 20
	AADD(aCabPed,{0.00                        , HC5->(FieldPos("HC5_DESC4"))	}) // 21
EndIf


//PONTO DE ENTRADA: Complemento ou Alteracao do Array de Cabecalho de Pedidos
#IFDEF _PEPV0006_
	//Objetivo:
	//Retorno: aCabPed
	uRet := PEPV0006(aCabPed)
#ENDIF

If ExistBlock("SFA_PV001")
	aCabPed := ExecBlock("SFA_PV001", .F., .F., {aCabPed})
EndIf
If !lRestaura .or. Len(aColIte) == 0
	PVMontaColIte(aColIte)
EndIf
// ---------------------- < PARTE 1: ENTRADA DA TELA DO PEDIDO > ----------------------
//Carga dos Arrays da Tela de Pedido (com o uso da consulta padrao n„o sera mais necessario)

If aCabPed[2,1] == 1 // Inclusao de Pedido
	MsgStatus(STR0003) //"Criando Pedido... Aguarde"
	if !PVProxPed(aCabPed[1,1])
		ClearStatus()
		Return Nil
	Endif
Else
	If aCabPed[2,1] == 2 .Or. aCabPed[2,1] == 5 // Alteracao ou VisualizaÁ„o
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
	   	If !PVNumPed(oBrwPedido,aPedido,aCabPed[1,1])
	   		ClearStatus()
			Return Nil
		Endif 
	ElseIf aCabPed[2,1] == 3 // Consulta de Itens de Ultimo pedido
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PVNumPed(oBrwUltPed,aUltPed,aCabPed[1,1])    
	   		ClearStatus()
			Return Nil
		Endif 
	ElseIf aCabPed[2,1] == 4 // Copiar Pedido
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PVNumPed(oBrwUltPed,aUltPed,aCabPed[1,1])
			ClearStatus()
			Return Nil
		Else
			cNumPedSrc := aCabPed[1,1]
			If !PVProxPed(aCabPed[1,1])
				ClearStatus()
				Return Nil
			EndIf
		Endif
	Endif
	
	If !Empty(aCabPed[1,1])
		dbSelectArea("HC5")     
		dbSetOrder(2)
		If aCabPed[2,1] == 4  // Gera Novo Pedido a Partir da Consulta de Ultimos Pedidos
			dbSeek(RetFilial("HC5") + aCabPed[3,1] + aCabPed[4,1] + cNumPedSrc)
		Else
			dbSeek(RetFilial("HC5") + aCabPed[3,1] + aCabPed[4,1] + aCabPed[1,1])
		EndIf
        If Found()
        	// O For Inicia em 2, para que o numero do pedido nao seja alterado
        	For nI:=2 to Len(aCabPed)
        		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero
            		aCabPed[nI,1] :=	HC5->(FieldGet(aCabPed[nI,2]))
        	    Endif
            Next

    		If aCabPed[2,1] !=  4 	// Se for diferente de Ult. Pedidos
	    		//Restaura total do pedido
    			aCabPed[11,1] := HC5->HC5_VALOR
    			aCabPed[12,1] := Round(aCabPed[11,1],TamADVC("HC5_VALOR",2))
    		Endif
    		
			PVItPed(aCabPed,aColIte,aItePed, cNumPedSrc)
			dbSelectArea("HC5")
        EndIf                                                                   
 	EndIf
EndIf

// --------------------- < PARTE 2: CARREGA A TELA DO PEDIDO > ----------------------------

ClearStatus()

If aCabPed[2,1] == 3  // Se consulta de itens do ultimo pedido, chama a Tela de Confirmacao de Pedidos
	PVConfirmPed(aItePed, aCabPed, aCabPed[14,1], aCabPed[21,1],"F", .F., .T.)
Else
	
		//InitPV(aCabPed,aItePed,aCond,aTab,aColIte,lRestaura)
	If ExistBlock("SFAPV102")
		ExecBlock("SFAPV102", .F., .F., {aCabPed,aItePed,aCond,aTab,aColIte,lRestaura})
	Else	
		//TELA DE PEDIDO V.2 DESCONTINUADA!!!
	HCF->( dbSeek(RetFilial("HCF") + "MV_SFATPED") )
   	If HCF->(Found())
	 	If AllTrim(HCF->HCF_VALOR) == "2"
			InitPV2(aCabPed,aItePed,aCond,aTab,aColIte)	//Tela de Pedido V. 2
	  	Else
			InitPV(aCabPed,aItePed,aCond,aTab,aColIte,lRestaura)	//Tela de Pedido V. 1
	  	Endif
   	Else
		InitPV(aCabPed,aItePed,aCond,aTab,aColIte,lRestaura)	//Tela de Pedido V. 1	
		Endif
	Endif
Endif  

// ---------------------- < PARTE 3: SAIDA DA TELA DO PEDIDO > ----------------------------

//Se for Inclusao, Atualizar Informacoes Array de Roteiros ou Cliente
//					e Faixa de Codigo de Pedido 
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(RetFilial("HC5") + aCabPed[1,1]) 
	If HC5->(Found())
		AADD(aPedido,{aCabPed[1,1],HC5->HC5_EMISS,HC5->HC5_COND,LoadStatus(HC5->HC5_STATUS)})
		SetArray(oBrwPedido,aPedido)
		PVAtuaProxPed(aCabPed[1,1])
	EndIf
	If Len(aPedido)>0 
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(RetFilial("HA1") + aCabPed[3,1]+aCabPed[4,1])
			HA1->HA1_FLGVIS := "1"
    		dbCommit()
    		SetDirty("HA1",HA1->(Recno()),.F.)
		Endif
		If Empty(aCabPed[5,1])
			dbSelectArea("HD7")
			dbSetOrder(3)
			If dbSeek(RetFilial("HD7") + DtoS(Date()) + aCabPed[3,1]+aCabPed[4,1])
				HD7->HD7_FLGVIS := "1"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)
			If dbSeek(RetFilial("HD7") + cCodPer+aCabPed[5,1]+aCabPed[6,1])
				HD7->HD7_FLGVIS := "1"
	    		dbCommit()
			Endif
		Endif		
		aClientes[nCliente,1] := "POSI"
	//	SetArray(oCliente,aClientes)
	Endif
Endif	

Return Nil
