#include "eadvpl.ch"
#include "SFVN108.CH"

//Tela inicial
Function StatFinanc()
Local nAtraso	:= 0
Local oSay, oCbx, oDlgStat
Local oBtnRetornar, oBtnOk
Local nI := 0
Local aOpc := {STR0018, STR0019, STR0020}
Local nOpc := 1

DEFINE DIALOG oDlgStat TITLE STR0006

@ 30,20 SAY oSay PROMPT "Filtro: " OF oDlgStat
@ 30,70 COMBOBOX oCbx VAR nOpc ITEM aOpc SIZE 70,40 OF oDlgStat

@ 130,020 BUTTON oBtnOk CAPTION "Ok" ACTION LoadDupli(nOpc) SIZE 50,15 OF oDlgStat
@ 130,080 BUTTON oBtnRetornar CAPTION STR0004 ACTION CloseDialog() SIZE 50,15 OF oDlgStat

ACTIVATE DIALOG oDlgStat

Return Nil



//Carrega as duplicatas
Function LoadDupli(nOpc)
Local nAtraso	:= 0
Local lTemDupl  := .F.
Local cTitulos := ""
Local oBrwStat, oCol, oDlgStat
Local oBtnRetornar, oBtnDup
Local aStatCli	:= {}

aSize(aStatCli, 0)

HCF->(dbSetOrder(1))
If HCF->(dbSeek(RetFilial("HCF") + "MV_SFTPTIT"))        
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->HCF_VALOR)
Endif

MsgStatus(STR0007)

DEFINE DIALOG oDlgStat TITLE STR0006

@ 20,05 BROWSE oBrwStat SIZE 150,115 OF oDlgStat
SET BROWSE oBrwStat ARRAY aStatCli
//ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 1 HEADER ""	 WIDTH 20 
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 3 HEADER STR0001 WIDTH 100
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 1 HEADER STR0002 WIDTH 40
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 2 HEADER STR0003 WIDTH 25

@ 140,020 BUTTON oBtnRetornar CAPTION STR0004 ACTION CloseDialog() SIZE 50,15 OF oDlgStat
@ 140,080 BUTTON oBtnDup CAPTION STR0005 ACTION DetDupl(oBrwStat,aStatCli) SIZE 50,15 OF oDlgStat

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(RetFilial("HA1"))
//dbGoTop()

While !HA1->(Eof())
	       
	nAtraso := RetStatus(HA1->HA1_COD,HA1->HA1_LOJA,@lTemDupl,cTitulos)
	If nAtraso > 0 .And. lTemDupl
		If nOpc = 1 .Or. nOpc = 3
			aadd(aStatCli,{HA1->HA1_COD,HA1->HA1_LOJA,HA1->HA1_NOME})
			GridSetCellColor(oBrwStat, Len(aStatCli), 1, CLR_HRED, CLR_WHITE)
		EndIf
	ElseIf nAtraso <= 0 .And. lTemDupl
		If nOpc = 1 .Or. nOpc = 2
			aadd(aStatCli,{HA1->HA1_COD,HA1->HA1_LOJA,HA1->HA1_NOME})
			GridSetCellColor(oBrwStat, Len(aStatCli), 1, CLR_GREEN, CLR_WHITE)
		Endif
	Endif	
	dbSelectArea("HA1")
	dbSkip()
	
Enddo        

ClearStatus()

ACTIVATE DIALOG oDlgStat

Return nil


Function RetStatus(cCodCli, cLojaCli, lTemDupl, cTitulos)
Local nAtraso := 0

lTemDupl := .f.
dbSelectArea("HE1")
dbSetOrder(1)
dbSeek(RetFilial("HE1"))
//dbGoTop()
dbSeek( RetFilial("HE1") + cCodCli+cLojaCli,.f. )

While !HE1->(Eof()) .and. (HE1->HE1_CLI == cCodCli .and. HE1->HE1_LOJA == cLojaCli)
	If At(HE1->HE1_TIPO, cTitulos) == 0
		nAtraso	 := Date() - HE1->HE1_VENCTO
		lTemDupl := .t.	
		If nAtraso > 0	//existem titulos em atraso (sair)
			exit
		Endif
	Endif
	HE1->(dbSkip())
Enddo

Return nAtraso
          

//Exibe as duplicatas do cliente selecionado
Function DetDupl(oBrwStat,aStatCli) 
Local oDuplicatas,oBtnRetornar
Local oCol,oBrwDuplicatas
Local nLin:=GridRow(oBrwStat)
Local aDuplicatas := {}
Local cCodCli:="",cLoja:=""
Local nAtraso:=0

If Len(aStatCli) == 0
	MsgAlert(STR0022, STR0009)
	return nil
Endif

If nLin == 0 
	MsgAlert(STR0008, STR0009)
	return nil
Endif

cCodCli	:= aStatCli[nLin,1]
cLoja	:= aStatCli[nLin,2]

dbSelectArea("HE1")
dbSetOrder(1)
//dbSeek(RetFilial("HE1"))
//dbGoTop()
dbSeek( RetFilial("HE1") + cCodCli+cLoja,.f. )
While !HE1->(Eof()) .and. HE1->HE1_FILIAL = RetFilial("HE1") .And. HE1->HE1_CLI == cCodCli .and. HE1->HE1_LOJA == cLoja
	nAtraso := Date() - HE1->HE1_VENCTO
	AADD(aDuplicatas,{HE1->HE1_TIPO,HE1->HE1_EMISS,HE1->HE1_VENCTO, HE1->HE1_SALDO,HE1->HE1_NUM,HE1->HE1_PARCEL,nAtraso })
	dbSkip()
Enddo                                                

DEFINE DIALOG oDuplicatas TITLE STR0010

@ 18,03 SAY aStatCli[nLin,3] OF oDuplicatas
@ 35,5 TO 135,155 CAPTION STR0010 OF oDuplicatas
@ 43,10 BROWSE oBrwDuplicatas SIZE 140,87 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER STR0011 WIDTH 30
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER STR0012 WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER STR0013 WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER STR0014 WIDTH 50
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER STR0015 WIDTH 50
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER STR0021 WIDTH 40 
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 7 HEADER STR0016 WIDTH 40 

@ 140,050 BUTTON oBtnRetornar CAPTION STR0017 ACTION CloseDialog() SIZE 55,15 OF oDuplicatas

ACTIVATE DIALOG oDuplicatas

Return nil
