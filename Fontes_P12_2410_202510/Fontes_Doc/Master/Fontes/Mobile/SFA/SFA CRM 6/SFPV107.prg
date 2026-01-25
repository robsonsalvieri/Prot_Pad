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

// Verifica se existe alguma ocorrencia de nao positivacao
dbSelectArea("HA1")
dbSetOrder(1)
If dbSeek(cCodCli + cLojaCli)
	If HA1->A1_FLGVIS = "2"
		If MsgYesorNo(STR0001, STR0002) //"Existe ocorrencia para este cliente. Deseja exclui-la ?"###"Ocorrencia"
			ACGrvTabOco(cCodPer, cCodRot, cIteRot,"0","", .F.)
			GrvAtend(4, , "", HA1->A1_COD, HA1->A1_LOJA,)
			aClientes[nCliente,1]:="NVIS"
			// Exclui a ocorrencia
			dbSelectArea("HD5")
			dbSetOrder(1)
			If dbSeek(HA1->A1_COD + HA1->A1_LOJA + DtoS(dData))
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
18 -  Parcela1 negociada 
19 -  Venc da Parcela1 negociada
20 -  Parcela2 negociada 
21 -  Venc da Parcela2 negociada
22 -  Parcela3 negociada 
23 -  Venc da Parcela3 negociada
24 -  Parcela4 negociada 
25 -  Venc da Parcela4 negociada
*/                                       

AADD(aCabPed,{cNumPed, 						HC5->(FieldPos("C5_NUM"))		})
AADD(aCabPed,{nOperacao,					0								})
AADD(aCabPed,{cCodCli,						HC5->(FieldPos("C5_CLI"))		})
AADD(aCabPed,{cLojaCli,						HC5->(FieldPos("C5_LOJA"))		})
AADD(aCabPed,{cCodRot,						0								})
AADD(aCabPed,{cIteRot,						0								})
AADD(aCabPed,{"",							HC5->(FieldPos("C5_COND"))		})
AADD(aCabPed,{"",							HC5->(FieldPos("C5_TAB"))		})
AADD(aCabPed,{"" , HC5->(FieldPos("C5_MENNOTA"))	})
AADD(aCabPed,{Date(),						0								})
AADD(aCabPed,{0.00,		  					0								})  
AADD(aCabPed,{0.00,		  					0								})
AADD(aCabPed,{"",	HC5->(FieldPos("C5_TRANSP"))	})
AADD(aCabPed,{0.00                       , HC5->(FieldPos("C5_DESCONT"))	})
AADD(aCabPed,{""                         , HC5->(FieldPos("C5_FORMAPG"))	})
AADD(aCabPed,{"F"                        , HC5->(FieldPos("C5_TPFRETE"))	})
AADD(aCabPed,{0.00                        , 0})

AADD(aCabPed,{0.00                       , HC5->(FieldPos("C5_PARC1"))	})
AADD(aCabPed,{CTOD("")                   , HC5->(FieldPos("C5_DATA1"))	})
AADD(aCabPed,{0.00                       , HC5->(FieldPos("C5_PARC2"))	})
AADD(aCabPed,{CTOD("")                   , HC5->(FieldPos("C5_DATA2"))	})
AADD(aCabPed,{0.00                       , HC5->(FieldPos("C5_PARC3"))	})
AADD(aCabPed,{CTOD("")                   , HC5->(FieldPos("C5_DATA3"))	})
AADD(aCabPed,{0.00                       , HC5->(FieldPos("C5_PARC4"))	})
AADD(aCabPed,{CTOD("")                   , HC5->(FieldPos("C5_DATA4"))	})
//PONTO DE ENTRADA: Complemento ou Alteracao do Array de Cabecalho de Pedidos
#IFDEF _PEPV0006_
	//Objetivo:
	//Retorno: aCabPed
	uRet := PEPV0006(aCabPed)
#ENDIF


PVMontaColIte(aColIte)

// ---------------------- < PARTE 1: ENTRADA DA TELA DO PEDIDO > ----------------------
//Carga dos Arrays da Tela de Pedido (com o uso da consulta padrao n„o sera mais necessario)

// Se for Inclusao de Pedido
If aCabPed[2,1] == 1
	MsgStatus(STR0003) //"Criando Pedido... Aguarde"
	if !PVProxPed(aCabPed[1,1])
		Return Nil
	Endif
Else
	If aCabPed[2,1]==2
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PVNumPed(oBrwPedido,aPedido,aCabPed[1,1])
			Return Nil
		EndIf
	Elseif aCabPed[2,1] == 3
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PVNumPed(oBrwUltPed,aUltPed,aCabPed[1,1])
			Return Nil
		Endif
	ElseIf aCabPed[2,1] == 4
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PVNumPed(oBrwUltPed,aUltPed,aCabPed[1,1])
			Return Nil
		Else
			cNumPedSrc := aCabPed[1,1]
			If !PVProxPed(aCabPed[1,1])
				Return Nil
			EndIf
		Endif
	Endif		
	If !Empty(aCabPed[1,1])
		dbSelectArea("HC5")     
		dbSetOrder(2)
		If aCabPed[2,1] == 4  // Gera Novo Pedido a Partir da Consulta de Ultimos Pedidos
			dbSeek(aCabPed[3,1] + aCabPed[4,1] + cNumPedSrc)
		Else
			dbSeek(aCabPed[3,1] + aCabPed[4,1] + aCabPed[1,1])
		EndIf
		If Found()
      	// O For Inicia em 2, para que o numero do pedido nao seja alterado
        	For nI:=2 to Len(aCabPed)
        		If aCabPed[nI,2] <> 0  // Se o FIELDPOS for Diferente de Zero     				
            		aCabPed[nI,1] :=	HC5->(FieldGet(aCabPed[nI,2]))

            		If aCabPed[2,1] == 4 .And. nI = 8 // Quando Copia de Pedido, verificar a tabela padrao do cliente
							If aCabPed[nI,1] != HA1->A1_TABELA
								aCabPed[nI,1] := HA1->A1_TABELA
							EndIf
						EndIf
				Endif
			Next

    		If aCabPed[2,1] !=  4 	// Se for diferente de Ult. Pedidos
	    		//Restaura total do pedido
    			aCabPed[11,1] := HC5->C5_VALOR
    			aCabPed[12,1] := Round(aCabPed[11,1],2)
    		Endif
    		
			PVItPed(aCabPed,aColIte,aItePed, cNumPedSrc)
			dbSelectArea("HC5")
        EndIf
 	EndIf
EndIf

// --------------------- < PARTE 2: CARREGA A TELA DO PEDIDO > ----------------------------
If aCabPed[2,1] == 3  // Se for Ult. Pedidos para consulta, chama a Tela de Confirmacao de Pedidos
	PVConfirmPed(aItePed, aCabPed[11,1], 0, .F., .T., "F", 0)
Else
	ClearStatus()
	HCF->( dbSeek("MV_SFATPED") )
	If HCF->(Found())
		If AllTrim(HCF->CF_VALOR) == "2"
			InitPV2(aCabPed,aItePed,aCond,aTab,aColIte)	//Tela de Pedido V. 2
		Else
			InitPV(aCabPed,aItePed,aCond,aTab,aColIte)	//Tela de Pedido V. 1
		Endif
	Else
		InitPV(aCabPed,aItePed,aCond,aTab,aColIte)	//Tela de Pedido V. 1	
	Endif
Endif


// ---------------------- < PARTE 3: SAIDA DA TELA DO PEDIDO > ----------------------------

//Se for Inclusao, Atualizar Informacoes Array de Roteiros ou Cliente
//					e Faixa de Codigo de Pedido 
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(aCabPed[1,1]) 
	If HC5->(Found())
		AADD(aPedido,{aCabPed[1,1],HC5->C5_EMISS,HC5->C5_COND}) 
		SetArray(oBrwPedido,aPedido)
		PVAtuaProxPed(aCabPed[1,1])
	EndIf
	If Len(aPedido)>0 
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(aCabPed[3,1]+aCabPed[4,1])
			HA1->A1_FLGVIS := "1"
    		dbCommit()
		Endif
		If Empty(aCabPed[5,1])
			dbSelectArea("HD7")
			dbSetOrder(3)
			If dbSeek(DtoS(Date()) + aCabPed[3,1]+aCabPed[4,1])
				HD7->AD7_FLGVIS := "1"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)
			If dbSeek(cCodPer+aCabPed[5,1]+aCabPed[6,1])
				HD7->AD7_FLGVIS := "1"
	    		dbCommit()
			Endif
		Endif		
		aClientes[nCliente,1] := "POSI"
	//	SetArray(oCliente,aClientes)
	Endif
Endif	

Return Nil
