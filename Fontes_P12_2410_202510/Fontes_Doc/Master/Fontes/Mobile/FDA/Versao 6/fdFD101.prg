#INCLUDE "FDFD101.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FDData			   ³Autor - Ary Medeiros ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona data para o Fechamento do Dia		 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Acao :    ³Click no Botao oBtn Caption Data                      	  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oData      -> Campo Data da Consulta						  ´±±
±±³			 ³dData      -> Data da Consulta    						  ´±±
±±³			 ³ * Parametros para uso no FDChange 						  ´±±
±±³			 ³nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl		  ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/***************************************************************************/
/* Seleciona data para o Fechamento do Dia                                 */
/***************************************************************************/
Function FDData(oData, dData,nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,aShow,oLbl)

dData := SelectDate(STR0001,dData) //"Selecione data..."
SetText(oData,dData)
FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FDChange			   ³Autor - Ary Medeiros ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seleciona tipo de view:     					 			  ³±±
±±³			 ³ 1-) Clientes Positivados    					 			  ³±±
±±³			 ³ 2-) Clientes Nao Positivados    					 		  ³±±
±±³			 ³ 3-) Resumo do Dia        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Acao :    ³Click no ListBox oLbx                     				  ´±±
±±³          ³FechamentoDia()		                     				  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nOpt       -> Tipo View 									  ´±±
±±³			 ³aOptions   -> Array do Tipo View     						  ´±±
±±³			 ³oBox       -> Box do Tipo View            				  ´±±
±±³			 ³oPosit     -> Box dos Clientes Positivados				  ´±±
±±³			 ³oOco       -> Box dos Clientes nao Positivados			  ´±±
±±³			 ³oResumo    -> Box do Resumo do Dia     					  ´±±
±±³			 ³dData      -> Data da Consulta    						  ´±±
±±³			 ³aShow      -> Array do Resultado do Tipo View selecionado   ´±±
±±³			 ³oLbl       -> Label Tipo View  							  ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)
Local nPedidos := 0, nTotVend := 0, nItems := 0, nVisitas := 0, nOcor := 0
Local cData    :=dTos(dData)
Local nNotas   := 0, nTotNot := 0
SetText(oBox,aOptions[nOpt])
aSize(aShow,0)
If nOpt == 1
	If HAT->(dbSeek(cData))
		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
			If HAT->AT_FLGVIS == "1"
				HA1->(dbSetOrder(1))
				HA1->(dbSeek(HAT->AT_CLI))
				AADD(aShow,{ HA1->A1_NOME, HAT->AT_LOJA })
				nOcor++
			EndIf
			HAT->(dbSkip())
		End
	EndIf
	HideControl(oOcorr)
	HideControl(oResumo)
	SetArray(oPosit,aShow)
	ShowControl(oPosit)
	SetText(oLbl,STR0002 + AllTrim(Str(nOcor))) //"Clientes positivados: "
	ShowControl(oLbl)
ElseIf nOpt == 2
	If HAT->(dbSeek(cData))
		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
	 		If HAT->AT_FLGVIS == "2"
	 			HA1->(dbSetOrder(1))
	 			HA1->(dbSeek(HAT->AT_CLI))
		  		HX5->(dbSeek("OC"+HAT->AT_OCO))
	      		AADD(aShow,{ HA1->A1_NOME, HAT->AT_LOJA ,HX5->X5_DESCRI })
		  		nOcor++
	   		EndIf
	   		HAT->(dbSkip())
		End
  	EndIf
  	HideControl(oPosit)
  	HideControl(oResumo)
  	ShowControl(oOcorr)
  	SetText(oLbl,STR0003 + AllTrim(Str(nOcor))) //"Ocorrências: "
  	ShowControl(oLbl)
ElseIf nOpt == 3
 	If HAT->(dbSeek(cData))
   		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
   			If HAT->AT_FLGVIS == "1"
     			nPedidos++                
	  			nItems   += HAT->AT_QTDIT
       			nTotVend += HAT->AT_VALPED
    		ElseIf HAT->AT_FLGVIS == "2"
      			nOcor++
   			EndIf
   			nVisitas++
   			HAT->(dbSkip())
	 	End
  	EndIf	
  	AADD(aShow,{STR0004,AllTrim(Str(nPedidos,0))}) //"Pedidos:"
  	AADD(aShow,{STR0005, Transform(nTotVend,"@E 9999999.99")}) //"Vendas:"
  	AADD(aShow,{STR0006, Transform(if(nPedidos>0,nTotVend/nPedidos,0),"@E 9999999.99")}) //"Vendas x pedido:"
  	AADD(aShow,{STR0007, AllTrim(Str(if(nPedidos>0,nItems/nPedidos,0)))}) //"Items x pedido:"
  	AADD(aShow,{STR0008,AllTrim(Str(nVisitas))}) //"Visitas:"
  	AADD(aShow,{STR0009,AllTrim(Str(nOcor))}) //"Ocorrências:"
  	AADD(aShow,{STR0010,Transform(if(nVisitas>0,(100*nPedidos)/nVisitas,0),"@E 999.99")+"%"}) //"% Positivação:"
  	HideControl(oPosit)
  	HideControl(oOcorr)
  	SetArray(oResumo,aShow)
  	ShowControl(oResumo)
  	HideControl(oLbl)
ElseIf nOpt == 4
 	If HAT->(dbSeek(cData))
   		While !HAT->(Eof()) .And. HAT->AT_DATA == cData
   			If HAT->AT_FLGVIS == "4"
     			nNotas++                
	  			nItems   += HAT->AT_QTDIT
       			nTotNot  += HAT->AT_VALPED
    		ElseIf HAT->AT_FLGVIS == "4"
      			nOcor++
   			EndIf
   			nVisitas++
   			HAT->(dbSkip())
	 	End
  	EndIf	
  	AADD(aShow,{STR0011,AllTrim(Str(nNotas,0))}) //"Notas:"
  	AADD(aShow,{STR0005, Transform(nTotNot,"@E 9999999.99")}) //"Vendas:"
  	AADD(aShow,{STR0012, Transform(if(nNotas>0,nTotNot/nNotas,0),STR0013)}) //"Vendas x Notas:"###"@E 9999999.99"
  	AADD(aShow,{STR0014, AllTrim(Str(if(nNotas>0,nItems/nNotas,0)))}) //"Items x Notas:"
  	AADD(aShow,{STR0008,AllTrim(Str(nVisitas))}) //"Visitas:"
  	AADD(aShow,{STR0009,AllTrim(Str(nOcor))}) //"Ocorrências:"
  	AADD(aShow,{STR0010,Transform(if(nVisitas>0,(100*nNotas)/nVisitas,0),"@E 999.99")+"%"}) //"% Positivação:"
  	HideControl(oPosit)
  	HideControl(oOcorr)
  	SetArray(oResumo,aShow)
  	ShowControl(oResumo)
  	HideControl(oLbl)
 	
EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FDClean			   ³Autor - Ary Medeiros ³ Data ³27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Limpa historico de atendimento   			 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Acao :    ³Click no Button oBtn Caption "Limpar"                       ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Todos os Parametros do FDChange, para uso na mesma		  ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/***************************************************************************/
/* Limpa historico de atendimento                                          */
/***************************************************************************/
Function FDClear(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

if !MsgYesOrNo(STR0015,STR0016) //"Limpa histórico de atendimento?"###"Fechamento do Dia"
  return
endif

MsgStatus(STR0017) //"Aguarde..."
HA1->(dbSetOrder(1))
HAT->(dbGoTop())
While !HAT->(Eof())
   if HA1->(dbSeek(HAT->AT_CLI))
      HA1->A1_FLGVIS := ""
   endif
   HAT->(dbSkip())
end
HAT->(__dbZap())
ClearStatus()
FDChange(nOpt,aOptions,oBox,oPosit,oOcorr,oResumo,dData,aShow,oLbl)

Return Nil
