#INCLUDE "SFCL101.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ClickClient()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de Selecionar o Cliente do Browse (Lista)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCliente, nCliente - Array e Posicao do Cliente selecionado³±±
±±³ 		 ³ oBrw - Browse do Cliente									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nCliente - Posicao do Cliente selecionado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ClickClient(nCliente,aCliente,oBrw)
if len(aCliente) == 0
	nCliente:= 0
Else 
	nCliente:=GridRow(oBrw)
Endif		               

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CLOrder()  	       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera a Ordenacao do Cliente no Browse			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCliente, nCliente - Array e Posicao do Cliente selecionado³±±
±±³ 		 ³ nTop - Armazena ultima posicao(registro) da tabela		  ³±±
±±³ 		 ³ nCargMax - Carga Maxima por Paginacao					  ³±±
±±³ 		 ³ nCampo - Ordem   										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CLOrder(nCliente,oBrw,aCliente,nTop,nCargMax,nCampo)

Local i:=1, c3oInd:=""

dbSelectArea("HA1")
if nCampo==3 // Sera uma pesquisa por CnPj
   MsgStatus("Aguarde... criando indice")
   c3oInd:="HA1"+cEmpresa+"3"
   INDEX ON Alltrim(HA1->A1_CGC) TO c3oInd 
   ClearStatus()
endif
dbSetOrder(nCampo)
dbGoTo(nTop)
aSize(aCliente,0)

CLChangeColun(@nCliente,oBrw,nCampo)

For i := 1 to nCargMax
	aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),HA1->A1_CGC })
	dbSkip()
	If Eof()
		break
	EndIf
Next
SetArray(oBrw, aCliente)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PesquisaCli()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de pesquisa do cadastro de clientes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPesquisa - valor a ser pesquisado                         ³±±
±±³			 ³ aCampo, nCampo - Array do Criterio de pesquisa de clientes ³±±
±±³ 		 ³ aCliente, nCliente - Array e Posicao do Cliente selecionado³±±
±±³ 		 ³ nCargMax - Numero maximo de clientes por pagina			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PesquisaCli(cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax)
Local nRec := 0, i := 1, cCriterio := Substr(aCampo[nCampo],1,1)
Local cAux	:=""
cPesquisa	:= Upper(cPesquisa)
SetText(oPesquisaTx,cPesquisa)
If nCampo == 2 //pesquisa por Nome
	dbSelectArea("HA1")
	dbSetOrder(2)
	dbSeek(cPesquisa)
	
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->A1_NOME
		//SetText(oPesquisaTx, cPesquisa)
		
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
//			aAdd(aCliente, Alltrim(HA1->A1_NOME))
			aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return Nil

ElseIf nCampo=1 //Pesquisa por codigo
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(cPesquisa)
	
	If HA1->(Found())
		cAux	:= HA1->A1_NOME
		//dbSelectArea("HA1")
		//dbSetOrder(2)
		//dbSeek(cAux)
	
        //if HA1->(Found())
			nRec := HA1->(Recno())
		
			dbGoTo(nRec)
			aSize(aCliente,0)
			For i := 1 to nCargMax
				aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),HA1->A1_CGC})
				dbSkip()
				If Eof()
				   break
				EndIf
			Next
			
			nTop := nRec // Atualiza nTop com a posicao localizada na tabela
			SetArray(oBrw, aCliente)
		//Else
		//	MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"
		//	cPesquisa := ""
		//	cAux	  :=""
		//Endif
	Else
		MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return

ElseIf nCampo == 3 .And. Substr(aCampo[nCampo],3,1)="P"  //Pesquisa por CnPj         
	dbSelectArea("HA1")
	dbSetOrder(3)
	dbSeek(cPesquisa)
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->A1_CGC
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
			aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),AllTrim(HA1->A1_CGC)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0003,STR0002) //"CNPJ/CPF de Cliente nao encontrado!" "###"Aviso"
		cPesquisa := ""
	EndIf 
	Return 	
EndIf

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SobeCli()           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que controle o LIst de CLientes 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCliente, nCliente - Array e Posicao do Cliente selecionado³±±
±±³ 		 ³ nCargMax - Numero maximo de clientes por pagina			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SobeCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo)
Local nRec := HA1->(Recno())
nCliente:=1

HA1->(dbGoTop())
If HA1->(Recno()) == nTop
	return
EndIf
HA1->(dbGoTo(nTop))
HA1->(dbSkip(-nCargMax))
nTop := HA1->(Recno())
ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Return nil
