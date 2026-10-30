#INCLUDE "SFPV006.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Detalhe do Item     ³Autor - Paulo Lima   ³ Data ³03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Pedidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1 (Tela de Pedido V. 1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aItePed, aObj 											  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Exibir em outro Dialog o Detalhe do Item 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Cleber M.  ³22/03/04| Exibicao do SubTotal com Desconto               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function PVDetIte(aItePed,aObj,cManTes)

Local oDetIte, oBtnRet
Local oTxtDIProd, oTxtDIQtde, oTxtDIPrc, oTxtDIDesc, oTxtDITotIte, oTxtDITes
Local nItePed:=0, nSubTot:=0
Local cPictVal		:= SetPicture("HPR","HPR_UNI")
Local cPictDes		:= SetPicture("HB1","HC6_DESC")

Default cManTes := "N"

if Len(aItePed) == 0
	Return Nil
Endif
nItePed := GridRow(aObj[3,1])

nSubTot := aItePed[nItePed,4] * Round(aItePed[nItePed,6],TamADVC("HC6_PRCVEN",2))

DEFINE DIALOG oDetIte TITLE STR0001 //"Detalhe do Item"
@ 22,4 TO 135,157 CAPTION STR0002 OF oDetIte //"Descricao do Produto:"

@ 32,07 GET oTxtDIProd VAR aItePed[nItePed,2] MULTILINE READONLY SIZE 142,25 of oDetIte

@ 61,07 SAY STR0003 of oDetIte //"Qtde: "
@ 61,55 GET oTxtDIQtde VAR aItePed[nItePed,4] READONLY SIZE 50,12 of oDetIte
@ 75,07 SAY STR0004 of oDetIte //"Preço: "
@ 75,55 GET oTxtDIPrc VAR aItePed[nItePed,6] PICTURE cPictVal READONLY SIZE 50,12 of oDetIte
@ 89,07 SAY STR0005 of oDetIte //"Desconto: "
@ 89,55 GET oTxtDIDesc VAR aItePed[nItePed,7] PICTURE cPictDes READONLY SIZE 50,12 of oDetIte
@ 89,106 SAY "%" of oDetIte

If cManTes == "S"
	@ 103,07 SAY "TES: " of oDetIte
	@ 103,55 GET oTxtDITes VAR aItePed[nItePed,8] READONLY SIZE 50,12 of oDetIte
EndIf

@ 117,07 SAY STR0006 of oDetIte //"Total Item: "
@ 117,55 GET oTxtDITotIte VAR nSubTot PICTURE cPictVal READONLY SIZE 50,12 of oDetIte

@ 142,4 BUTTON oBtnRet CAPTION STR0007 SIZE 154,12 ACTION CloseDialog() of oDetIte //"OK"

ACTIVATE DIALOG oDetIte

Return Nil


//Recalcula os itens do pedido na troca da cond. de pagto (inteligente)
Function PVRecalcula(aCabPed,aObj,aColIte,aItePed,nTelaPed) 
Local ni := 1, nItePed := 0
Local cProd := ""
Local cQtd	:= ""
Local cUsaRgDesc := SFGetMv("MV_SFRGDSC",,"S")
Local nFldTabSz := 0
If Len(aItePed) > 0 

	MsgStatus(STR0008) //"Alterando pedido, aguarde..."
      
	//Zera totais do cabec. do pedido 
	aCabPed[11,1] := 0
	aCabPed[12,1] := 0        
	nItePed:=Len(aItePed)
	nFldTabSz := TamADVC("HPR_TAB",1) - Len(AllTrim(aCabPed[8,1]))
	For ni := 1 to Len(aItePed) 
	      
		//Busa preco de tabela
		dbSelectArea("HPR")
		If HPR->(FieldPos("HPR_QTDLOT")) != 0 .And. HPR->(FieldPos("HPR_INDLOT")) != 0
			cProd := aItePed[ni,1]
			cQtd  := StrTran( StrZero(aItePed[ni,4],18,2), ",", ".")
			If !Empty(cProd) .And. !Empty(aCabPed[8,1]) .And. !Empty(aItePed[ni,4])
				HPR->(dbSetOrder(2))
				HPR->(DbSeek( RetFilial("HPR")+ALlTrim(cProd)+Space(Len(HPR->HPR_PROD)-Len(AllTrim(cProd)))+AllTrim(aCabPed[8,1])+Space(nFldTabSz)+cQtd, .T.))
				If !HPR->(Eof()) .And. AllTrim(HPR->HPR_PROD) == AllTrim(cProd) .And. AllTrim(HPR->HPR_TAB) == Alltrim(aCabPed[8,1]) .And. HPR->HPR_QTDLOT >= aColIte[4,1]
					aItePed[ni,6] := HPR->HPR_UNI
					aItePed[ni,16] := HPR->HPR_UNI
				EndIf
			EndIf
		EndIf
		
		//Limpa o descto
		aItePed[ni,7] := 0
		If cUsaRgDesc == "S"
			// Verifica/aplica a regra de desconto para o item
			RGAplDescIte(aCabPed[3,1], aCabPed[4,1], aCabPed[7,1], aCabPed[8,1], aCabPed[15,1], , aItePed,ni)
		EndIf
		// Atualiza tabela de preço
		aItePed[ni,5] := aCabPed[8,1]
		// Atualiza Valor do Item (SubTotal)
		aItePed[ni,9] := aItePed[ni,4] * aItePed[ni,6]
	                
		// Recalcula total do pedido
		aCabPed[11,1] := aCabPed[11,1] + aItePed[ni,9]
		aCabPed[12,1] := Round(aCabPed[11,1],TamADVC("HC5_VALOR",2))	

	Next                             
	  
	ClearStatus()
	If nTelaPed == 1
		  SetArray(aObj[3,1],aItePed)	//Browse de itens
	Endif
	SetText(aObj[1,4],aCabPed[12,1]) //Total
Endif

Return nil         


/*   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Condicao Inteligente ³Autor - Cleber M.    ³ Data ³21/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Preenche a tabela de preco de acordo com a cond. de pagto  ³±±
±±³			 ³ selecionada (usando a tab. de Regras de Neg.)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0.1                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCliente   -> Cod. do Cliente								  ´±±
±±³			 ³cLoja      -> Loja do Cliente	 	     		   			  ´±±
±±³			 ³cCond      -> Cond. de Pagto. 				   			  ´±±
±±³			 ³(Retorna a tabela de preco encontrada)					  ´±±
±±³			 ³															  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RGCondInt(cCliente,cLoja,cCond)
Local lContinua := .T.
Local cTab 		:= ""
Local lGrpVen	:= HCS->(FieldPos("HCS->HCS_GRPVEN")) > 0

dbSelectArea("HCS")
dbSetOrder(1)
dbSeek(RetFilial("HCS"))
//dbGoTop()
dbSelectArea("HA1")
HA1->(dbSetOrder(1))
HA1->(dbSeek( RetFilial("HA1") + cCliente + cLoja ))
While !Eof() .And. lContinua
	If 	(HCS->HCS_CODCLI = cCliente .Or. Empty(HCS->HCS_CODCLI) ).And.;
		(Iif(lGrpVen,HCS->HCS_GRPVEN = HA1->HA1_GRPVEN,.T.) .Or. Iif(lGrpVen,Empty(HCS->HCS_GRPVEN),.T.) ).And.;
		(HCS->HCS_LOJA = cLoja .Or. Empty(HCS->HCS_LOJA) )
			
			HCT->( dbSetOrder(3) )	//Cod. da Regra + Cond. Pagto.
			HCT->( dbSeek(RetFilial("HCT") + HCS->HCS_CODREG+cCond) )
			If HCT->(Found())
				cTab := HCT->HCT_CODTAB
				lContinua := .F.                    	
				break
			Endif
    Endif
    
    dbSelectArea("HCS")
    dbSkip()
Enddo

Return cTab


Function UpdTpFrete(aCabPed, aTpFrete, nOpcFre)
	aCabPed[16,1] := Substr(aTpFrete[nOpcFre],1,1)
Return Nil
