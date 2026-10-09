#INCLUDE "FDVN102.ch"

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
dbSelectArea("HC5")
dbSetOrder(2)                    
alert( indexkey() )
alert( cCodCli+cLojaCli )
dbSeek( cCodCli+cLojaCli,.f. )
While !Eof() .and. HC5->C5_CLI == cCodCli .and. HC5->C5_LOJA == cLojaCli
	cStPedido:=""
	cNumPed  :=""
	cNumPed  :=HC5->C5_NUM
// Se for Novo Pedido: Carrega no Pedidos, Senao carrega nos Ult. Pedidos
	if HC5->C5_STATUS = "N"
//		-> aPedido: Array do Mod. de Pedidos
		If HC5->(IsDirty())		//Nao transmitido
			AADD(aPedido,{cNumPed,HC5->C5_EMISS,HC5->C5_COND}) 
		Endif
	Else
		// -> aUltPed: Array do Mod. dos Ultimos Pedidos
		// Verifica se o Pedido esta Parcial
		If SubStr(HC5->C5_STATUS,1,1) = "P"
			cStPedido := STR0001 //"Parc. "
		EndIf
		// Define o Status do Pedido		
		If At("A", HC5->C5_STATUS) > 0
			cStPedido += STR0002 //"Aberto"
		ElseIf At("BE", HC5->C5_STATUS) > 0
			cStPedido += STR0003 //"Bloqueado Estoque"
		ElseIf At("BC", HC5->C5_STATUS) > 0
			cStPedido += STR0004 //"Bloqueado Credito"
		ElseIf At("B", HC5->C5_STATUS) > 0
			cStPedido += STR0005 //"Bloqueado"
		ElseIf At("E", HC5->C5_STATUS) > 0
			cStPedido += STR0006 //"Encerrado"
		ElseIf At("L", HC5->C5_STATUS) > 0
			cStPedido += STR0007 //"Liberado"
		ElseIf At("R", HC5->C5_STATUS) > 0
			cStPedido += STR0008 //"Residuo"
		ElseIf At("P", HC5->C5_STATUS) > 0
			cStPedido += STR0009			 //"Processado"
		Else
			cStPedido := STR0010    //"Indefinido"
		EndIf	
/*
		HCF->(dbSetOrder(1))
		HCF->(dbSeek("SP"+HC5->C5_STATUS))
		if HCF->(Found())
			cStPedido	:=Alltrim(HCF->CF_VALOR) 
		Else
			cStPedido	:="Indefinido"   
		Endif
*/
		AADD(aUltPed,{cNumPed,HC5->C5_EMISS, cStPedido }) 
	Endif

	dbSkip()  
	
Enddo

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
Function PVExcPed(oBrwPedido, aPedido, cNumPed,aClientes,nCliente,oCliente,cCodCli, cLojaCli, cCodRot,cIteRot)
Local nI:=0
Local cResp	:=""
Local dData := Date()

If Len(aPedido)=0
	MsgAlert(STR0011) //"Nenhum Pedido Selecionado para ser Excluido"
	Return Nil
Endif
	
//cResp:=if(MsgYesOrNo("Você deseja Excluir o Pedido?","Cancelar"),"Sim","Não")
If !MsgYesOrNo(STR0012,STR0013) //"Você deseja Excluir o Pedido?"###"Cancelar"
	Return Nil
EndIf      

PVNumPed(oBrwPedido,aPedido,@cNumPed)

dbSelectArea("HC5")
dbSetOrder(1) 
dbGoTop()

If dbSeek(cNumPed)
	// Guarda a data para excluir o Atendimento
	dData := HC5->C5_EMISS
	
	dbDelete()      
	dbSkip()
		
	dbSelectArea("HC6")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(cNumPed)

	While !Eof() .And. HC6->C6_NUM = cNumPed
		dbDelete()	
		dbSkip()			
	EndDo
	
	nI := GridRow(oBrwPedido)
	
	aDel(aPedido, nI)
	aSize(aPedido, Len(aPedido)-1)
	SetArray(oBrwPedido, aPedido)
	
	GrvAtend(2, cNumPed, , HC5->C5_CLI, HC5->C5_LOJA, dData)
		
	MsgAlert(STR0014) //"Pedido Excluído com sucesso"

	If Len(aPedido)<= 0 	
		// Atualiza Flag para nao visitado, se nao houvere mais pedidos para o cliente
		dbSelectArea("HA1")
		dbSetOrder(1)
		If dbSeek(cCodCli+cLojaCli)
			HA1->A1_FLGVIS := "0"
    		dbCommit()
		Endif

		If Empty(cCodRot)
			dbSelectArea("HD7")
			dbSetOrder(3)	
			If dbSeek(DtoS(Date()) + cCodCli + cLojaCli)
				HD7->AD7_FLGVIS := "0"
	    		dbCommit()
			Endif
		Else
			dbSelectArea("HD7")
			dbSetOrder(1)		
			If dbSeek(cCodRot+cIteRot)
				HD7->AD7_FLGVIS := "0"
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
  HCN->(dbSeek(cCodCli+cLojaCli))
  if HCN->(Found())
  	nTop := HCN->(Recno())
  endif      
  lInicio := .t.
Else
  HCN->(dbGoTo(nTop))
Endif

//If !HCN->(Eof()) .And. (HCN->F2_CLIENTE == cCodCli .And. HCN->F2_LOJA == cLojaCli)
	aSize(aConsumo,0)
	For i := 1 to nCargMax
	   if !HCN->(Eof()) .And. (HCN->F2_CLIENTE == cCodCli .And. HCN->F2_LOJA == cLojaCli)
			AADD(aConsumo,{HCN->F2_PROD,HCN->F2_ANOANT, HCN->F2_MESANT,HCN->F2_MESATU}) 
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
if !HCN->(Eof()) .And. (HCN->F2_CLIENTE == cCodCli .And. HCN->F2_LOJA == cLojaCli)
   nTop := HCN->(Recno())
else
   return nil
endif
Return ACCrgConsumo(cCodCli,cLojaCli,aConsumo,oBrwConsumo,@nTop)


Function ConsumoUp(cCodCli,cLojaCli,aConsumo,oBrwConsumo,nTop)
HCN->(dbGoTo(nTop))
HCN->(dbSkip(-GridRows(oBrwConsumo)))
if !HCN->(Bof()) .And. (HCN->F2_CLIENTE == cCodCli .And. HCN->F2_LOJA == cLojaCli)
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
//nOperacao = 5 - Inclusao/Alteracao de Nota ( Pronta entrega )
//nOperacao = 6 - Exclusao de Nota ( Pronta entrega )
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
	If !dbSeek(cNumPed)
		Return Nil
	EndIf
ElseIf nOperacao = 3 .Or. nOperacao = 4
	dbSelectArea("HA1")
	dbSetOrder(1)
	If !dbSeek(cCodCli+cCodLoja)
		Return Nil
	EndIf
ElseIf nOperacao = 5  // Inclusao da Nota (Pronta Entrega)
	dbSelectArea("HF2")
	dbSetOrder(1)
	If !dbSeek(cNumPed) // Uso a mesma variavel do pedido.
		Return Nil
	EndIf
EndIf

// Atualiza tabela de Atendimentos
If nOperacao = 1
	dbSelectArea("HAT")
	dbSetOrder(1)
	If !dbSeek(DtoS(HC5->C5_EMISS) + "1" + HC5->C5_NUM)
		dbAppend()
		lGravaAtend := .T.
		lInclui := .T. 
	Else
		lGravaAtend := .T.
	EndIf
ElseIf nOperacao = 2 
	dbSelectArea("HAT")
	dbSetOrder(1)
	If dbSeek(cData + "1" + cNumPed)
		dbDelete()
	EndIf	
ElseIf nOperacao = 3
	dbSelectArea("HAT")
	dbSetOrder(2)
	If !dbSeek(cData+"2"+cCodCli+cCodLoja)
		dbAppend()
		lGravaAtend := .T.
		lInclui := .T. 
	Else
		lGravaAtend := .T.
	EndIf
ElseIf nOperacao = 4
	dbSelectArea("HAT")
	dbSetOrder(2)
	If dbSeek(cData + "2" + cCodCli + cCodLoja)
		dbDelete()
	EndIf
ElseIf nOperacao = 5 // inclusao da nota Pronta entrega 
	dbSelectArea("HAT")
	dbSetOrder(1)
	If !dbSeek(DtoS(HF2->F2_EMISSAO) + "4" + HF2->F2_DOC)
		dbAppend()
		lGravaAtend := .T.
		lInclui := .T. 
	Else
		lGravaAtend := .T.
	EndIf         
ElseIf nOperacao = 6  // Exclusao da Nota (Pronta Entrega) 
	dbSelectArea("HAT")
	dbSetOrder(1)
	If dbSeek(cData + "4" + cNumPed)
		dbDelete()
	EndIf		
EndIf

If lGravaAtend
	If nOperacao = 1
		cFlgVis := "1"
		HAT->AT_NUMPED := cNumPed
		HAT->AT_VALPED := HC5->C5_VALOR
		HAT->AT_QTDIT  := HC5->C5_QTDITE
	ElseIf nOperacao = 3
		cFlgVis := "2"
		HAT->AT_OCO    := cOcorrencia
    ElseIf nOperacao = 5 // Nota Pronta Entrega		
   		cFlgVis := "4"
		HAT->AT_NUMPED := cNumPed 
		HAT->AT_VALPED := HF2->F2_VALBRUT
		HAT->AT_QTDIT  := HF2->F2_QTDITE
	
	Else
		cFlgVis := "0"
	EndIf
	If lInclui 
	   HAT->AT_DATA   := cData
	Endif   
	HAT->AT_CLI    := cCodCli
	HAT->AT_LOJA   := cCodLoja
	HAT->AT_FLGVIS := cFlgVis
	HAT->AT_STATUS := cStatus
EndIf
Return Nil