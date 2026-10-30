#INCLUDE "SFVN102.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACCrgPed            ³Autor - Paulo Lima   ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega array dos ultimos pedidos e Pedidos	 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ³±±
±±³			 ³ aPedido, aUltPed: Arrays de Ult. Pedidos e Pedidos		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACCrgPed(cCodCli, cLojaCli, aPedido, aUltPed)
Local cStPedido   := ""
Local cNumPed	  := ""

aSize(aPedido,0)
aSize(aUltPed,0)

dbSelectArea("HC5")
dbSetOrder(2)
dbSeek( RetFilial("HC5") + cCodCli+cLojaCli,.f. )
While !Eof() .and. HC5->HC5_CLI == cCodCli .and. HC5->HC5_LOJA == cLojaCli
	
	cNumPed		:= HC5->HC5_NUM
	cStPedido	:= LoadStatus(HC5->HC5_STATUS)
	
	// Se for Novo Pedido: Carrega no Pedidos, Senao carrega nos Ult. Pedidos
	If Alltrim(HC5->HC5_STATUS) $ "N/BS"
		If HC5->(IsDirty())				//Nao transmitido
			AADD(aPedido,{cNumPed,HC5->HC5_EMISS,HC5->HC5_COND,cStPedido})
		ElseIf HC5->HC5_STATUS = "BS"	// Bloqueado SFA
			AADD(aPedido,{cNumPed,HC5->HC5_EMISS,HC5->HC5_COND,cStPedido}) 
		Endif
	Else
		AADD(aUltPed,{cNumPed,HC5->HC5_EMISS, cStPedido })
	Endif
	
	dbSkip()
	
Enddo

// Ponto de Entrada ao final da funcao de atualizacao das abas do pedido
// Possibilitando a manutencao dos arrays aPedido e aUltPed
If ExistBlock("SFAVN003")
	ExecBlock("SFAVN003", .F., .F., {aPedido, aUltPed })
EndIf


Return Nil                                                        

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PVExcPed            ³Autor - Paulo Lima   ³ Data ³         ³±±
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
Function PVExcPed(oBrwPedido, aPedido, cNumPed,aClientes,nCliente,oCliente,cCodCli, cLojaCli, cCodPer, cCodRot,cIteRot)
Local nI:=0
Local cResp	:=""
Local dData := Date()

If Len(aPedido)=0
	MsgAlert(STR0010) //"Nenhum Pedido Selecionado para ser Excluido"
	Return Nil
Endif
	
//cResp:=if(MsgYesOrNo("Você deseja Excluir o Pedido?","Cancelar"),"Sim","Não")
If !MsgYesOrNo(STR0011,STR0012) //"Você deseja Excluir o Pedido?"###"Cancelar"
	Return Nil
EndIf      

PVNumPed(oBrwPedido,aPedido,@cNumPed)

dbSelectArea("HC5")
dbSetOrder(1) 
//dbGoTop()
If dbSeek(RetFilial("HC5") + cNumPed)

	If ExistBlock("SFAPV019")
		If !ExecBlock("SFAPV019", .F., .F., {aPedido,cNumPed})
			Return NIL
		EndIf
	EndIf

	// Guarda a data para excluir o Atendimento
	dData := HC5->HC5_EMISS
	
	dbDelete()      
	dbSkip()
		
	dbSelectArea("HC6")
	dbSetOrder(1)
	//dbGoTop()
	dbSeek(RetFilial("HC6") + cNumPed)

	While !Eof() .And. HC6->HC6_NUM = cNumPed
		dbDelete()	
		dbSkip()			
	EndDo
	
	nI := GridRow(oBrwPedido)
	
	aDel(aPedido, nI)
	aSize(aPedido, Len(aPedido)-1)
	SetArray(oBrwPedido, aPedido)
	
	GrvAtend(2, cNumPed, , HC5->HC5_CLI, HC5->HC5_LOJA, dData)
		
	MsgAlert(STR0013) //"Pedido Excluído com sucesso"

	If Len(aPedido)<= 0 	
		// Atualiza Flag para nao visitado, se nao houvere mais pedidos para o cliente
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(RetFilial("HA1") + cCodCli+cLojaCli)
			HA1->HA1_FLGVIS := "0"
    		dbCommit()
    		SetDirty("HA1",HA1->(Recno()),.F.)
		Endif

		If Empty(cCodRot)
			dbSelectArea("HD7")
			dbSetOrder(3)	
			If dbSeek(RetFilial("HD7") + DtoS(Date()) + cCodCli + cLojaCli)
				HD7->HD7_FLGVIS := "0"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)		
			If dbSeek(RetFilial("HD7") + cCodPer + cCodRot + cIteRot)
				HD7->HD7_FLGVIS := "0"
	    		dbCommit()
			Endif
		Endif		
		aClientes[nCliente,1]:="NVIS"
	Endif
Endif

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACCrgConsumo        ³Autor - Paulo Lima   ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega array de consumo						 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCli: Codigo do Cliente, cLojaCli: Loja do Cliente	  ³±±
±±³			 ³ aConsumo: Array de Pedidos		  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,nTop)

Local i, nCargMax:=GridRows(oBrwConsumo)
Local lInicio := .f.

If nTop == 0 
  HCN->(dbSetOrder(1))
  HCN->(dbSeek(RetFilial("HCN") + cCodCli+cLojaCli))
  if HCN->(Found())
  	nTop := HCN->(Recno())
  endif      
  lInicio := .t.
Else
  HCN->(dbGoTo(nTop))
Endif

//If !HCN->(Eof()) .And. (HCN->HCN_CLIENT == cCodCli .And. HCN->HCN_LOJA == cLojaCli)
	aSize(aConsumo,0)
	For i := 1 to nCargMax
	   if !HCN->(Eof()) .And. (HCN->HCN_CLIENT == cCodCli .And. HCN->HCN_LOJA == cLojaCli)
			AADD(aConsumo,{HCN->HCN_PROD,HCN->HCN_ANOANT, HCN->HCN_MESANT,HCN->HCN_MESATU}) 
	   else
		  break
	   endif
	   HCN->(dbSkip())
	Next                   
	If lInicio == .f.
		SetArray(oBrwConsumo,aConsumo)
	Endif
//Endif

Return Nil  


Function ConsumoDown(cCodCli,cLojaCli,aConsumo,oBrwConsumo,nTop)
HCN->(dbGoTo(nTop))
HCN->(dbSkip(GridRows(oBrwConsumo)))
if !HCN->(Eof()) .And. (HCN->HCN_CLIENT == cCodCli .And. HCN->HCN_LOJA == cLojaCli)
   nTop := HCN->(Recno())
else
   return nil
endif
Return ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)


Function ConsumoUp(cCodCli,cLojaCli,aConsumo,oBrwConsumo,nTop)
HCN->(dbGoTo(nTop))
HCN->(dbSkip(-GridRows(oBrwConsumo)))
if !HCN->(Bof()) .And. (HCN->HCN_CLIENT == cCodCli .And. HCN->HCN_LOJA == cLojaCli)
	nTop := HCN->(Recno())                            
else 
	return nil
endif
Return ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)

       

Function GrvAtend(nOperacao, cNumPed, cOcorrencia, cCodCli, cCodLoja, dData)
//nOperacao = 1 - Inclusao/Alteracao de Pedido
//nOperacao = 2 - Exclusao de Pedido
//nOperacao = 3 - Inclusao/Alteracao de Ocorrencia
//nOperacao = 4 - Exclusao de Ocorrencia
Local cStatus := "N"
Local cFlgVis := "0"
Local cAlias  := ""
Local cData	  := ""
Local lGravaAtend := .F.
Local lInclui := .f. 

If dData = Nil
	dData := Date()
EndIf
cData := DtoS(dData)

If nOperacao = 1
	dbSelectArea("HC5")
	dbSetOrder(1)
	If !dbSeek(RetFilial("HC5") + cNumPed)
		Return Nil
	EndIf
ElseIf nOperacao = 3 .Or. nOperacao = 4
	dbSelectArea("HA1")
	dbSetOrder(1)
	If !dbSeek(RetFilial("HA1") + cCodCli+cCodLoja)
		Return Nil
	EndIf
EndIf

// Atualiza tabela de Atendimentos
If nOperacao = 1
	dbSelectArea("HAT")
	dbSetOrder(1)
	If !dbSeek(RetFilial("HAT") + DtoS(HC5->HC5_EMISS) + "1" + HC5->HC5_NUM)
		dbAppend()
		lGravaAtend := .T.
		lInclui := .T. 
	Else
		lGravaAtend := .T.
	EndIf
ElseIf nOperacao = 2
	dbSelectArea("HAT")
	dbSetOrder(1)
	If dbSeek(RetFilial("HAT") + cData + "1" + cNumPed)
		dbDelete()
	EndIf	
ElseIf nOperacao = 3
	dbSelectArea("HAT")
	dbSetOrder(2)
	If !dbSeek(RetFilial("HAT") + cData+"2"+cCodCli+cCodLoja)
		dbAppend()
		lGravaAtend := .T.
		lInclui := .T. 
	Else
		lGravaAtend := .T.
	EndIf
ElseIf nOperacao = 4
	dbSelectArea("HAT")
	dbSetOrder(2)
	If dbSeek(RetFilial("HAT") + cData + "2" + cCodCli + cCodLoja)
		dbDelete()
	EndIf
EndIf

If lGravaAtend
	If nOperacao = 1
		cFlgVis := "1"
		HAT->HAT_NUMPED := cNumPed
		HAT->HAT_VALPED := HC5->HC5_VALOR
		HAT->HAT_QTDIT  := HC5->HC5_QTDITE
	ElseIf nOperacao = 3
		cFlgVis := "2"
		HAT->HAT_OCO    := cOcorrencia
	Else
		cFlgVis := "0"
	EndIf
	If lInclui 
	   HAT->HAT_DATA   := dData
	Endif   
	HAT->HAT_FILIAL	:= RetFilial("HAT") //cFilial
	HAT->HAT_CLI    := cCodCli
	HAT->HAT_LOJA   := cCodLoja
	HAT->HAT_FLGVIS := cFlgVis
	HAT->HAT_STATUS := cStatus
EndIf
Return Nil
