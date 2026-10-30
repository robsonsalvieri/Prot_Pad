#INCLUDE "FDVN104.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACCrgCto            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Array de Contatos 				 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ³±±
±±³			 ³ aContato - Array dos Contatos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACCrgCto(cCodCli,cLojaCli,aContato)
Local cFuncao:="",nTam:=0

nTam := 6 - Len(cCodCli)
dbSelectArea("HU5")
dbSetOrder(2)
If nTam > 0
	dbSeek(RetFilial("HU5")+cCodCli+space(nTam)+cLojaCli)
Else
	dbSeek(RetFilial("HU5")+cCodCli + cLojaCli)
Endif

While !Eof() .And. HU5->HU5_FILIAL == RetFilial("HU5") .And. HU5->U5_CLIENTE == cCodCli .And. HU5->U5_LOJA == cLojaCli

    cFuncao:=""
	dbSelectArea("HX5")
	dbSetOrder(1)
	dbSeek(RetFilial("HX5")+"UM" + HU5->U5_FUNCAO)
	If !Eof()
		cFuncao	:=HX5->X5_DESCRI
	Endif      

	AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})

	dbSelectArea("HU5")	
 	dbSkip()
Enddo

Return Nil   

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AcManCon            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega Array de Contatos 				 			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpCon - Operacao (1=Inclusao, 2=Alteracao, 3=Detalhe)	  ³±±
±±³			 ³ cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ³±±
±±³			 ³ aContato - Array dos Contatos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function AcManCon(nOpCon, oBrwContato,aContato,cCodCli, cLojaCli)
Local cCodCon	:=space(6), cFuncao	:=""
Local nLinha:=0, nTam := 0
Local lAt	:=.F.
if !nOpCon==1
	if Len(aContato) == 0
	    MsgAlert(STR0001,STR0002) //"Nenhum contato selecionado!"###"Cad. Contato"
		Return Nil
	Endif	
	nLinha  := GridRow(oBrwContato)    
	cCodCon	:= aContato[nLinha,1]
Endif

InitContato(nOpCon,cCodCli, cLojaCli,@cCodCon,@lAt)

//Ocorreu alguma Acao no Modulo de Contatos ( Inclusao, Alteracao ou Exclusao)?
// Corpo para atualizacao do Browse de Contatos
if lAt
	nTam := 6 - Len(cCodCli)
	dbSelectArea("HU5")
	dbSetOrder(1)
	If nTam > 0
		dbSeek(RetFilial("HU5")+cCodCli+space(nTam)+cLojaCli+cCodCon) 
	Else                                             
		dbSeek(RetFilial("HU5")+cCodCli+cLojaCli+cCodCon) 
	Endif
	//Incluiu ou Alterou um Contato
	if HU5->(Found())
	
	    cFuncao:=""
		dbSelectArea("HX5")
		dbSetOrder(1)
		dbSeek(RetFilial("HX5")+"UM" + HU5->U5_FUNCAO)
		If !Eof()
			cFuncao	:=HX5->X5_DESCRI
		Endif      
	
	    If nOpCon==1 
			AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})
		Else
			aContato[nLinha,2] := AllTrim(HU5->U5_CONTAT)
			aContato[nLinha,3] := cFuncao
		Endif
	//Excluiu o Contato
	Else
		aDel(aContato,nLinha)
		aSize(aContato,Len(aContato)-1)
	Endif
	SetArray(oBrwContato,aContato)

Endif	
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACCrgPar        ³Autor - Marcelo Vieira   ³ Data ³15.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega array dos Parametros do SFA  (So visualizacao )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACCrgPar(aParametro)
Local nLinhas:=0
dbSelectArea("HCF")
dbSetOrder(1)
dbGotop()
While !Eof() 
      AADD(aParametro,{HCF->CF_PARAM,HCF->CF_VALOR}) 
      dbSkip()  
Enddo
// Descobre quantos elementos contem o array
nLinhas:=Len(aParametro)

// Ordena o Array por ordem de parametro 
SortArray(aParametro, 1, nLinhas,, 1) 

Return 
