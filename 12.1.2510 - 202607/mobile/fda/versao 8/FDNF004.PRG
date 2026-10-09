#INCLUDE "FDNF004.ch"
#include "eADVPL.ch"

Function NFConfirmNf(aIteNot, nTotNot, nDescNotRG, lConfirmNot, lCons, cSfaInd, nTotInd)
Local oDlg, oBrw, oCol                                
Local oBtnVltNot, oBtnConfNot
Local oTxtSIte, oTxtSTNot, oTxtTNot, oTxtDNot, oTxtInden
Local nSIte:= 0, nSTNot:= 0, nTNot :=0, nDNot:=0, nTotIPI:=0,nTotIcm:=0
Local nTotNotSDesc := 0 // Variavel que soma o total da Nota sem desconto
Local nDescNot := 0 // Variavel que soma o total dos Descontos da Nota dados pelo vendedor
Local nInd := Round(nTotInd,2) //Valor da indenizacao
Local nTotImpostos := 0
nSIte	:=Len(aIteNot)
nSTNot	:=Round(nTotNot,2)
nDNot	:=Round(nDescNotRG,2)

If lCons
	DEFINE DIALOG oDlg TITLE STR0001 //"Consulta dos Itens da Nota"
else
	DEFINE DIALOG oDlg TITLE STR0002 //"Confirmação da Nota"
Endif

For ni := 1 To Len(aIteNot)
	If cCalcProtheus == "T"
		nDescNot := nDescNot + (aIteNot[ni,6] * Round((aIteNot[ni,23] * (aIteNot[ni,13] / 100)),2))
		nTotICM  := nTotICM  + aIteNot[ni,9]
		nTotIPI  := nTotIPI  + aIteNot[ni,10]
	Else
		nDescNot := nDescNot + ((aIteNot[ni,6] * aIteNot[ni,23]) * (aIteNot[ni,13]/100))
		nTotICM  := nTotICM  + aIteNot[ni,9]
		nTotIPI  := nTotIPI  + aIteNot[ni,10]
	Endif
	nTotNotSDesc := nTotNotSDesc + (aIteNot[ni,6] * aIteNot[ni,23])
Next

// Total da Nota com todos os descontos (Regra de Desconto e Vendedor)
nTNot := nTotNotSDesc - nDNot - nDescNot + nTotICM + nTotIPI

// Desconta a Indenizacao do Total de Notido
If cSfaInd = "T"
	nTNot := nTNot - nInd
EndIf
nTNot := Round(nTNot,2)
nTotImpostos := nTotIPI + nTotICM

@ 20,02 BROWSE oBrw SIZE 155,70 OF oDlg
SET BROWSE oBrw ARRAY aIteNot
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3   HEADER STR0003 WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 43  HEADER STR0004 WIDTH 150	//Acresc. 11/06/03 //"Descr."
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6   HEADER STR0005 WIDTH 40 //"Qtde"
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6 HEADER STR0006 WIDTH 40 //"Qtde Ent"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 23  HEADER STR0007 WIDTH 40 //"Preco"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 13  HEADER STR0008 WIDTH 40 //"Desconto"
If !lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 11 HEADER STR0009 WIDTH 30 //"Tes"
EndIf
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8 HEADER STR0010 WIDTH 45 //"Sub Tot."
If lCons
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 14 HEADER STR0011 WIDTH 80 //"Status"
EndIf
@ 94,7 SAY STR0012 of oDlg //"Item(ns): "
@ 94,50 GET oTxtSIte VAR nSIte READONLY SIZE 40,12 of oDlg

If cSfaInd == "T"
	@ 94,93 SAY STR0013 of oDlg //"Inden.: "
	@ 94,123 GET oTxtInden VAR nInd READONLY SIZE 40,12 of oDlg
Endif

@ 106,7 SAY STR0014 of oDlg //"SubTotal: "
@ 106,50 GET oTxtSTNot VAR nTotNotSDesc READONLY SIZE 80,12 of oDlg

@ 118,7 SAY STR0015 of oDlg //"Desconto: "
@ 118,50 GET oTxtDNot VAR nDescNot READONLY SIZE 40,12 of oDlg

@ 118,93 SAY STR0016 of oDlg //"Impost.: "
@ 118,123 GET oTxtDNot VAR nTotImpostos READONLY SIZE 40,12 of oDlg

@ 130,7 SAY STR0017 of oDlg //"Total: "
@ 130,50 GET oTxtTNot VAR nTNot READONLY SIZE 80,12 of oDlg

if !lCons 
	@ 145,10 BUTTON oBtnConfNot CAPTION STR0018 ACTION NFFecConfT(lConfirmNot) SIZE 65,10 OF oDlg //"Confirmar"
Endif
@ 145,85 BUTTON oBtnVltNot CAPTION BTN_BITMAP_CANCEL SYMBOL  ACTION NFFecConfF(lConfirmNot,aIteNot)SIZE 65,10 OF oDlg

ACTIVATE DIALOG oDlg

Return Nil                                                          

Function NFFecConfT(lConfirmNot)
	lConfirmNot := .T.
	CloseDialog() 
Return Nil

Function NFFecConfF(lConfirmNot, aIteNot)
Local nCont:=len(aIteNot)

lConfirmNot := .F. 
CloseDialog() 
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Detalhe do Item     ³Autor - Paulo Lima   ³ Data ³03/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Notidos        					 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA CRM 6.0                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aIteNot, nIteNot											  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo: ³ Exibir em outro Dialog o Detalhe do Notido			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function NFDetIte(aIteNot, nIteNot)
Local oDetIte, oBtnRet
Local oTxtDIProd, oTxtDIQtde, oTxtDIPrc, oTxtDIDesc, oTxtDITotIte

if Len(aIteNot) ==0
	Return Nil
Endif

DEFINE DIALOG oDetIte TITLE STR0019 //"Detalhe do Item"
@ 22,4 TO 135,157 CAPTION STR0020 OF oDetIte //"Descricao do Produto:"
@ 32,07 GET oTxtDIProd VAR aIteNot[nIteNot,2] MULTILINE VSCROLL READONLY SIZE 142,50 of oDetIte
@ 80,07 SAY STR0021 of oDetIte //"Qtde: "
@ 80,52 GET oTxtDIQtde VAR aIteNot[nIteNot,6] READONLY SIZE 60,12 of oDetIte
@ 92,07 SAY STR0022 of oDetIte //"Preço: "
@ 92,52 GET oTxtDIPrc VAR aIteNot[nIteNot,23] READONLY SIZE 60,12 of oDetIte
@ 104,07 SAY STR0015 of oDetIte //"Desconto: "
@ 104,52 GET oTxtDIDesc VAR aIteNot[nIteNot,13] READONLY SIZE 60,12 of oDetIte
@ 116,07 SAY STR0017 of oDetIte //"Total: "
@ 116,52 GET oTxtDITotIte VAR aIteNot[nIteNot,8] READONLY SIZE 60,12 of oDetIte
@ 142,4 BUTTON oBtnRet CAPTION BTN_BITMAP_OK SYMBOL SIZE 154,12 ACTION CloseDialog() of oDetIte

ACTIVATE DIALOG oDetIte

Return Nil


//Recalcula os itens da Nota na troca da cond. de pagto (inteligente)
Function NFRecalcula(aCabNot,aObj,aColIte,aIteNot) 
Local ni := 1, nIteNot := 0
Local nVlrItem := 0

If Len(aIteNot) > 0 

	  MsgStatus(STR0023) //"Alterando Notido, aguarde..."


      //Zera totais do cabec. do Notido 
      aCabNot[15,1] := 0        
      nIteNot:=Len(aIteNot)

      For ni := 1 to Len(aIteNot) 
	      
          dbSelectArea("HPR")
       	  dbSetOrder(1)
		  dbSeek(RetFilial("HPR")+aIteNot[ni,1]+aCabNot[7,1])	//Procura preço de venda usando a nova tabela
			
		  If !Eof()                        
		     aIteNot[ni,6] := HPR->HPR_UNI
		  Else           
			 dbSelectArea("HB1")
			 dbSetOrder(1)
			 dbSeek(RetFilial("HB1")+aIteNot[ni,1])     
			 aIteNot[ni,6] := HB1->HB1_PRV1
		  Endif                                 
		  // Atualiza tabela de preço
		  aIteNot[ni,5] := aCabNot[7,1]
     	  // Atualiza Valor do Item (SubTotal)
	      aIteNot[ni,9] := aIteNot[ni,4] * aIteNot[ni,6]
	      //Limpa o descto
	      aIteNot[ni,7] := 0
	      // Verifica/aplica a regra de desconto para o item
	      RGAplDescIte(aCabNot[3,1], aCabNot[4,1], aCabNot[7,1], aCabNot[7,1], "", aIteNot, ni, aColIte)
	                
	      // Recalcula total do Nota
	      if aIteNot[ni,7] > 0
			  nVlrItem := PVCalcDescto(aColIte,aIteNot,ni,.F.)
			  aCabNot[15,1] := aCabNot[15,1] + nVlrItem
		  else
	    	  aCabNot[15,1] := aCabNot[15,1] + aIteNot[ni,9]
		  endif
	      aCabNot[35,1] := Round(aCabNot[15,1],2)	

	  Next                             
	  
	  ClearStatus()
	  SetArray(aObj[3,1],aIteNot)		//Browse de itens
	  SetText(aObj[1,4],aCabNot[35,1]) //Total
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
Function RGCondIntNF(cCliente,cLoja,cCond)
Local lContinua := .T.
Local cTab := ""

dbSelectArea("HCS")
dbSetOrder(1)
dbGoTop()

While !Eof() .And. lContinua

	If (HCS->HCS_CODCLI = cCliente .Or. Empty(HCS->HCS_CODCLI) ).And.;
			(HCS->HCS_LOJA = cLoja .Or. Empty(HCS->HCS_LOJA) )
			
			HCT->( dbSetOrder(3) )	//Cod. da Regra + Cond. Pagto.
			HCT->( dbSeek(RetFilial("HCT")+HCS->HCS_CODREG+cCond) )
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

Function UpdTpFreteNF(aCabNot, aTpFrete, nOpcFre)
	aCabNot[43,1] := Substr(aTpFrete[nOpcFre],1,1)
Return Nil

Function FolderDupli2(oDuplicatas, aDuplicatas,oBrwDuplicatas, oCol, oDlg)
Local oBtnAltRec, oBtnIncRec,oBtnExcRec,oBtnImpRec

Local  nAtraso := 0

// Recebimento
ADD FOLDER oDuplicatas CAPTION STR0024 OF oDlg //"Recebe"
@ 37,5 TO 140,155 CAPTION STR0025 OF oDuplicatas //"Recebimento"
@ 45,07 BUTTON oBtnIncRec  CAPTION STR0026 ACTION RCPrepRec(oDuplicatas,aDuplicatas,oBrwDuplicatas)  SIZE 45,10 OF oDuplicatas //"Baixar"
//RCPrepRec(1,oBrwRec,aNotas,cNumNot,cCodCli, cLojaCli, cCodRot, cIteRot, aClientes, nCliente, oCliente) SIZE 45,10 OF oDuplicatas
@ 45,57 BUTTON oBtnAltRec  CAPTION STR0027 ACTION Alert(STR0028) SIZE 45,10 OF oDuplicatas //"Canc.Bx"###"Alterar Rec"
@ 45,107 BUTTON oBtnExcRec CAPTION STR0029 ACTION Alert(STR0030) SIZE 45,10 OF oDuplicatas //"Excluir"###"Excluir Rec"
@ 123,135 BUTTON oBtnImpRec  CAPTION BTN_BITMAP_PRINTER SYMBOL ACTION Alert(STR0031) SIZE 45,10 OF oDuplicatas //"Impr.rec"

dbSelectArea("HE1")
dbSetOrder(1)
dbGoTop()

dbSeek( RetFilial("HE1")+HA1->HA1_COD+HA1->HA1_LOJA,.T. )
While !Eof() .And. HE1->HE1_FILIAL == RetFilial("HE1") .and. HE1->HE1_CLIENTE == HA1->HA1_COD .and. HE1->HE1_LOJA == HA1->HA1_LOJA
	nAtraso := Date() - HE1->HE1_VENCTO
	AADD(aDuplicatas,{HE1->HE1_NUM,HE1->HE1_PARCELA,HE1->HE1_TIPO,HE1->HE1_EMISSAO,HE1->HE1_VENCTO,HE1->HE1_SALDO,nAtraso })
	dbSkip()
Enddo

@ 61,10 BROWSE oBrwDuplicatas SIZE 140,62 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER STR0032 WIDTH 40 //"Título Nº"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER STR0033 WIDTH 40 //"Parcela"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER STR0034 WIDTH 30 //"Tipo"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER STR0035 WIDTH 45 //"Emissao"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER STR0036 WIDTH 45 //"Vencto."
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER STR0037 WIDTH 50 //"Valor"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 7 HEADER STR0038 WIDTH 40 //"Dias Atrasado"

Return Nil
