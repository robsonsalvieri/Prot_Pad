#INCLUDE "ATDIMP.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ATDIMP    ºAutor  ³Marcelo Vieira      º Data ³  14/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime Atendimento Selecionado                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SFA CRM 6.0.1                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³                   									         	  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATDImp(dData)
Local aResumo1:={},aResumo2:={},aResumo3:={},aResumo4:={}
Local nCol:=1 
Local nOcor:=0  ,nOcor1:=0 ,nOcor2:=0  ,nPedidos1:=0,nItems1:=0  ,nTotVend1:=0
Local nPedidos3:=0,nTotVend3:=0,nItems3:=0,nTotNot3:=0,nOcor3:=0   ,nVisitas3:=0
Local nNotas4:=0,nItems4:=0,nTotNot4:=0,nOcor4:=0   ,nVisitas4:=0
Local cDataImp:=Dtoc(dData)
Local cData   :=dTos(dData)

If !MsgYesOrNo(STR0001,STR0002) //"Confirma a impressao ?"###"Cancelar"
   Return 
endif                                              

If HAT->(RetFilial("HAT")+dbSeek(cData))
	While !HAT->(Eof()) .And. HAT->HAT_FILIAL == RetFilial("HAT").And. HAT->HAT_DATA == cData
		// Primeiro Monta o Array com Ocorrencias de venda
		If HAT->HAT_FLGVIS == "1"
			HA1->(dbSetOrder(1))
			HA1->(dbSeek(RetFilial("HA1")+HAT->AT_CLI))
			AADD(aResumo1,{ HA1->HA1_NOME, HAT->HAT_LOJA, HAT->HAT_NUMPED, HAT->HAT_VALPED  })
			nOcor3++
			nPedidos3++
			nVisitas3++
			nItems3   += HAT->HAT_QTDIT
			nTotVend3 += HAT->HAT_VALPED
			
		EndIf
		// Segundo - Monta o Array com Resumo Ocorrencias de nao positivacao 
		If HAT->HAT_FLGVIS == "2"
			HA1->(dbSetOrder(1))
			HA1->(RetFilial("HA1")+dbSeek(HAT->HAT_CLI))
			HX5->(dbSeek(RetFilial("HX5")+"OC"+HAT->HAT_OCO))
			AADD(aResumo2,{ HA1->HA1_NOME, HAT->HAT_LOJA ,HX5->HX5_DESCRI })
			nOcor2++
		EndIf
		// Terceiro - Monta o Array com Resumo das notas
		If HAT->HAT_FLGVIS == "4"
			nNotas4++
			nItems4   += HAT->HAT_QTDIT
			nTotNot4  += HAT->HAT_VALPED
			nOcor4++
			nVisitas4++
		endif
		
		HAT->(dbSkip())
		
	Enddo
else
	MsgStop( STR0003, cDataImp ) //"Nao existem dados nesta data"
	Return 
	
EndIf    
         
//Finaliza os arrays totalizadores 
// Resumo dos pedidos 
if  nOcor3 > 0
	AADD(aResumo3,{STR0004,AllTrim(Str(nPedidos3,0))}) //"Pedidos:"
	AADD(aResumo3,{STR0005, Transform(nTotVend3,"@E 9999999.99")}) //"Vendas:"
	AADD(aResumo3,{STR0006, Transform(if(nPedidos3>0,nTotVend3/nPedidos3,0),"@E 9999999.99")}) //"Vendas x pedido:"
	AADD(aResumo3,{STR0007, AllTrim(Str(if(nPedidos3>0,nItems3/nPedidos3,0)))}) //"Items x pedido:"
	AADD(aResumo3,{STR0008,AllTrim(Str(nVisitas3))}) //"Visitas:"
	AADD(aResumo3,{STR0009,AllTrim(Str(nOcor3))}) //"Ocorrencias:"
	AADD(aResumo3,{STR0010,Transform(if(nVisitas3>0,(100*nPedidos3)/nVisitas3,0),"@E 999.99")+"%"}) //"% Positivacao:"
endif
//Resumo das Notas 
if nOcor4 > 0 
	AADD(aResumo4,{STR0011,AllTrim(Str(nNotas4,0))}) //"Notas:"
	AADD(aResumo4,{STR0005, Transform(nTotNot4,"@E 9999999.99")}) //"Vendas:"
	AADD(aResumo4,{STR0012, Transform(if(nNotas4>0,nTotNot4/nNotas4,0),"@E 9999999.99")}) //"Vendas x Notas:"
	AADD(aResumo4,{STR0013, AllTrim(Str(if(nNotas4>0,nItems4/nNotas4,0)))}) //"Items x Notas:"
	AADD(aResumo4,{STR0008,AllTrim(Str(nVisitas4))}) //"Visitas:"
	AADD(aResumo4,{STR0009,AllTrim(Str(nOcor4))}) //"Ocorrencias:"
	AADD(aResumo4,{STR0010,Transform(if(nVisitas4>0,(100*nNotas4)/nVisitas4,0),"@E 999.99")+"%"}) //"% Positivacao:"
endif

// Segue para impressao 

ImprAtd(cDataImp,aResumo1,aResumo2,aResumo3,aResumo4 )

Return nil

//Layout de Impressao do Fechamento do dia  
Function Impratd(cDataimp,aResumo1,aResumo2,aResumo3,aResumo4)
Local nRes1:=Len(aResumo1)
Local nRes2:=Len(aResumo2)
Local nRes3:=Len(aResumo3)
Local nRes4:=Len(aResumo4)
Local n1   :=0 

MsgStatus( STR0014 ) //"Aguarde..."

if File("adprintlib-syslib.prc") .Or. File("Advprint.dll") 
   SET DEVICE TO PRINT		//Direciona p/ impressora
else 
   MsgStop( "impressora não encontrada", "Aviso")   
   Return 
endif

//Cabec. do Pedido
@ Prow()+1,1  PSAY EMP->EMP_NOME
@ Prow()+2,1  PSAY STR0015 //"Fechamento do dia :"
@ Prow()  ,23 PSAY cDataImp
@ Prow()+1,1  PSAY STR0016      //"Vendedor"
@ Prow()  ,13 PSAY ": " + HC5->HC5_VEND1 + " - " + HA3->HA3_NREDUZ
@ Prow()+1,1  PSAY Replicate("_",55) //replicate

// Imprime ocorrencias de nao venda
n1   :=0 
If nRes2 > 0
   @ Prow()+1,1  PSAY STR0017  //"Ocorrencias de nao venda"
   For n1:=1 to nRes2
	   @ Prow()+1,1  PSAY Alltrim(aResumo2[n1,1])
	   @ Prow()  ,25 PSAY Alltrim(aResumo2[n1,2])
   	   @ Prow()  ,30 PSAY Alltrim(aResumo2[n1,3])
   Next	
   @ Prow()+1,1  PSAY Replicate("_",55) //replicate
endif

// Imprime Resumo de pedidos
n1   :=0 
If nRes1 > 0
   @ Prow()+1,1  PSAY STR0018  //"Resumo de pedidos"
   For n1:=1 to nRes1
	   @ Prow()+1,1  PSAY Alltrim(aResumo1[n1,1])
	   @ Prow()  ,25 PSAY Alltrim(aResumo1[n1,2])
	   @ Prow()  ,30 PSAY Alltrim(aResumo1[n1,3])
	   @ Prow()  ,38 PSAY Alltrim( Transform(aResumo1[n1,4],"@E 9999999.99") )
   Next	
   @ Prow()+1,1  PSAY Replicate("_",55) //replicate
   For n1:=1 to nRes3
	   @ Prow()+1,1  PSAY aResumo3[n1,1]
	   @ Prow()  ,10 PSAY aResumo3[n1,2]
   Next	
   @ Prow()+1,1  PSAY Replicate("_",55) //replicate
endif

// Imprime ocorrencias de nao venda
n1   :=0 
If nRes4 > 0
   @ Prow()+1,1  PSAY STR0019  //"Resumo das Notas"
   For n1:=1 to nRes4
	   @ Prow()+1,1  PSAY aResumo4[n1,1]
	   @ Prow()  ,21 PSAY aResumo4[n1,2]
   Next	
   @ Prow()+1,1  PSAY Replicate("_",55) //replicate   
endif

SET DEVICE TO SCREEN	//Redireciona p/ tela
ClearStatus()

Alert(STR0020) //"Impressao finalizada"

Return nil
