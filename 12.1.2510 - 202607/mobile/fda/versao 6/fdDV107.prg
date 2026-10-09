#include "eADVPL.ch"
#INCLUDE "FDDV107.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± < INDICE DAS FUNCOES  > ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±
±± @1.  PVPrepPed -> Funcao que Prepara a Entrada e a Saida da tela de Pedido
±± @2.  PVNumPed -> Captura o Codigo do Pedido do Array na Linha Selecionada
±±      (Caso seja Alteracao ou Ult. Pedidos)
±± @3.  PVProxPed -> Controle da Faixa de Cod. de Pedido, capturando o CodProxPed 
±± @4.  PVAtuaProxPed -> Controle da Faixa de Cod. de Pedido, atualizando o CodProxPed 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Prep. Pedidos       ³Autor - Paulo Lima   ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±³			 ³ PVPrePed  -> Prepara a Entrada e Saida da Tela de Pedidos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao /3 - Ult.Pedido(Cons.) ´±±
±±³			 ³4 - Ult.Pedido (Gerar Novo Pedido)   	     		 		  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo V.  ³06/07/04³Adapatacao da Rorina Para Pronta entrega         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PDPrepDev(nOperacao,oBrwDev,aDev,cNumDev,cCodCli, cLojaCli)
//Variaveis Locais
Local aCabPed	:= {}, aItePed	:= {}, aColIte := {}
Local cObs := "", cNumPedSrc := ""
Local nTotPed :=0.00, nRTotPed :=0.00 //NRTotPed Total do Pedido Arrendondado
Local nCond	:= 1, nTab := 1, nUltPedRow := 0, nI:=1
Local dData := dDataBase

// ---------------------- < - >  CABECALHO DO PEDIDO < - > ----------------------
/*    
Informacoes do Array do Cabec. do Pedido
Coluna (1): Conteudo/Valor da Variavel
Coluna (2): FieldPos (Campo da Tabela Associado HC5)
Linha Descricao
*/                                       

// 1 -   Código do Pedido
AADD(aCabPed,{cNumDev, 						HF1->(FieldPos("F1_DOC"))		})
// 2 -   Operacao ( 1/2/3/4 )
AADD(aCabPed,{nOperacao,					0								})
// 3 -   Codigo do Cliente 
AADD(aCabPed,{cCodCli,						HF1->(FieldPos("F1_FORNECE"))		})
// 4 -   Loja do Cliente 
AADD(aCabPed,{cLojaCli,						HF1->(FieldPos("F1_LOJA"))		})
// 5 -   Codigo da Rota
AADD(aCabPed,{"",							0								})
// 6 -   Codigo do Roteiro
AADD(aCabPed,{"",							0								})
// 7 -   Cond. de Pagto. 
AADD(aCabPed,{"",							HF1->(FieldPos("F1_COND"))		})
// 8 -   Tabela de Preco 
AADD(aCabPed,{"",							0								})
// 9 -   Observacao                               
AADD(aCabPed,{"", 							0								})
// 10 -  Data de Entrega 
AADD(aCabPed,{dDataBase,					0								})
// 11 -  Total do Pedido
AADD(aCabPed,{0.00,		  					0								})  
// 12 -  Total Arredondado do Pedido
AADD(aCabPed,{0.00,		  					0								})
// 13 -  Tranportadora do Pedido
AADD(aCabPed,{"",							0								})
// 14 -  Valor da Indenizacao
AADD(aCabPed,{0.00                       , 0								})
// 15 -  Forma de Pagamento
AADD(aCabPed,{""                         , 0								})
// 16 -  Tipo de Frete
AADD(aCabPed,{"F"                        , 0								})
// 17 -  Peso do Pedido
AADD(aCabPed,{0.00                        , 0})                        

//PONTO DE ENTRADA: Complemento ou Alteracao do Array de Cabecalho de Pedidos
#IFDEF _PEPV0006_
	//Objetivo:
	//Retorno: aCabPed
	uRet := PEPV0006(aCabPed)
#ENDIF


PDMontaColIte(aColIte)

// ---------------------- < PARTE 1: ENTRADA DA TELA DO PEDIDO > ----------------------
//Carga dos Arrays da Tela de Pedido (com o uso da consulta padrao não sera mais necessario)
// Se for Inclusao de Pedido
If aCabPed[2,1] == 1
	MsgStatus(STR0003) //"Criando Pedido... Aguarde"
	if !PDProxPed(aCabPed[1,1])
		Return Nil
	Endif
Else
	If aCabPed[2,1]==2
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PDNumPed(oBrwDev,aDev,aCabPed[1,1])
			Return Nil
		EndIf
	Elseif aCabPed[2,1] == 3
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PDNumPed(oBrwDev,aDev,aCabPed[1,1])
			Return Nil
		Endif
	ElseIf aCabPed[2,1] == 4
		MsgStatus(STR0004) //"Carregando Pedido... Aguarde"
		If !PDNumPed(oBrwDev,aDev,aCabPed[1,1])
			Return Nil
		Else
			cNumPedSrc := aCabPed[1,1]
			If !PDProxPed(aCabPed[1,1])
				Return Nil
			EndIf
		Endif
	Endif		
	If !Empty(aCabPed[1,1])
		dbSelectArea("HF1")     
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
            		aCabPed[nI,1] :=	HF1->(FieldGet(aCabPed[nI,2]))
        	    Endif
            Next

			/*
    		If aCabPed[2,1] !=  4 	// Se for diferente de Ult. Pedidos
	    		//Restaura total do pedido
    			aCabPed[11,1] := HF1->F1_VALOR
    			aCabPed[12,1] := Round(aCabPed[11,1],2)
    		Endif
    		*/
    		
			PDItPed(aCabPed,aColIte,aItePed, cNumPedSrc)
			dbSelectArea("HF1")
        EndIf
 	EndIf
EndIf

// --------------------- < PARTE 2: CARREGA A TELA DO PEDIDO > ----------------------------
If aCabPed[2,1] == 3  // Se for Ult. Pedidos para consulta, chama a Tela de Confirmacao de Pedidos
	PVConfirmPed(aItePed, aCabPed[11,1], 0, .F., .T., "F", 0)
Else
	ClearStatus()
	InitPDEsp(aCabPed,aItePed,aColIte)
Endif


// ---------------------- < PARTE 3: SAIDA DA TELA DO PEDIDO > ----------------------------

//Se for Inclusao, Atualizar Faixa de Codigo de Pedido 
If aCabPed[2,1] == 1 .Or. aCabPed[2,1] == 4
	dbSelectArea("HF1")
	dbSetOrder(1)
	if dbSeek(aCabPed[1,1]) 
		AADD(aDev,{aCabPed[1,1],HF1->F1_EMISSAO,HF1->F1_VALOR}) 
		SetArray(oBrwDev,aDev)
		PDAtuaProxPed(aCabPed[1,1])
	EndIf
Endif	

Return Nil
           

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PDExcDev            ³Autor - Paulo Lima   ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui um Pedido								 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ³±±
±±³			 ³ aPedido: Array de Pedidos		  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PDExcDev(oBrwDev, aDev, cNumDev,cCodCli, cLojaCli)
Local nI:=0
Local cResp	:=""
Local dData := dDataBase

If Len(aDev)=0
	MsgAlert(STR0010) //"Nenhum Pedido Selecionado para ser Excluido"
	Return Nil
Endif
	
//cResp:=if(MsgYesOrNo("Você deseja Excluir o Pedido?","Cancelar"),"Sim","Não")
If !MsgYesOrNo(STR0011,STR0012) //"Você deseja Excluir o Pedido?"###"Cancelar"
	Return Nil
EndIf      

PDNumPed(oBrwDev,aDev,@cNumdev)

dbSelectArea("HF1")
dbSetOrder(1) 
dbGoTop()

If dbSeek(cNumDev)
	// Guarda a data para excluir o Atendimento
	dData := HF1->F1_EMISSAO
	
	dbDelete()      
	dbSkip()
		
	dbSelectArea("HD1")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(cNumDev)

	While !Eof() .And. HD1->D1_DOC = cNumDev
		dbDelete()	
		dbSkip()			
	EndDo
	
	nI := GridRow(oBrwDev)
	
	aDel(aDev, nI)
	aSize(aDev, Len(aDev)-1)
	SetArray(oBrwDev, aDev)
	
	GrvAtend(2, cNumDev, , cCodCli, cLojaCli, dData)
		
	MsgAlert(STR0013) //"Pedido Excluído com sucesso"

Endif

Return Nil
