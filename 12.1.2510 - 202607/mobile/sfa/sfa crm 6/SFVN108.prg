#include "eadvpl.ch"
#include "SFVN108.CH"

Function StatFinanc()
Local nAtraso	:= 0
Local oBrwStat, oCbx, oCol, oDlgStat
Local oBtnRetornar, oBtnDup
Local aStatCli := {}
Local nI := 0
Local aOpc := {"Todos", "Adimplentes", "Inadimplentes"}
Local nOpc := 1
DEFINE DIALOG oDlgStat TITLE "Status Duplicatas"
#ifdef __PALM__
	@ 0,95 COMBOBOX oCbx VAR nOpc ITEM aOpc SIZE 60,40 ACTION LoadDupli(@aStatCli, oBrwStat, nOpc) OF oDlgStat
#ELSE
	@ 0,85 COMBOBOX oCbx VAR nOpc ITEM aOpc SIZE 60,40 ACTION LoadDupli(@aStatCli, oBrwStat, nOpc) OF oDlgStat
#ENDIF

@ 20,05 BROWSE oBrwStat SIZE 150,115 OF oDlgStat
SET BROWSE oBrwStat ARRAY aStatCli
//ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 1 HEADER ""	 WIDTH 20 
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 3 HEADER STR0001 WIDTH 130
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 1 HEADER STR0002 WIDTH 40 
ADD COLUMN oCol TO oBrwStat ARRAY ELEMENT 2 HEADER STR0003 WIDTH 25

@ 140,025 BUTTON oBtnRetornar CAPTION "Fechar" ACTION CloseDialog() SIZE 50,15 OF oDlgStat
@ 140,085 BUTTON oBtnDup CAPTION "Ver Dupl" ACTION DetDupl(oBrwStat,aStatCli) SIZE 50,15 OF oDlgStat

LoadDupli(@aStatCli, oBrwStat, nOpc)

ACTIVATE DIALOG oDlgStat

Return nil

Function LoadDupli(aStatCli, oBrwStat, nOpc)
Local nAtraso	:= 0
Local lTemDupl  := .F.
Local cTitulos := ""

aSize(aStatCli, 0)

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif
MsgStatus(STR0007)

dbSelectArea("HA1")
dbSetOrder(2)
dbGoTop()
While !HA1->(Eof())	
	nAtraso := RetStatus(HA1->A1_COD,HA1->A1_LOJA,@lTemDupl,cTitulos)
	If nAtraso > 0 .And. lTemDupl
		If nOpc = 1 .Or. nOpc = 3
			aadd(aStatCli,{HA1->A1_COD,HA1->A1_LOJA,HA1->A1_NOME})
			GridSetCellColor(oBrwStat, Len(aStatCli), 1, CLR_HRED, CLR_WHITE)
		EndIf
	ElseIf nAtraso <= 0 .And. lTemDupl
		If nOpc = 1 .Or. nOpc = 2
			aadd(aStatCli,{HA1->A1_COD,HA1->A1_LOJA,HA1->A1_NOME})
			GridSetCellColor(oBrwStat, Len(aStatCli), 1, CLR_GREEN, CLR_WHITE)
		Endif
	Endif
	dbSelectArea("HA1")
	dbSkip()	
Enddo        
SetArray(oBrwStat, aStatCli)
ClearStatus()

Return nil


Function RetStatus(cCodCli, cLojaCli, lTemDupl, cTitulos)
Local nAtraso := 0
dbSelectArea("HE1")
dbSetOrder(1)
dbSeek( cCodCli+cLojaCli,.f. )
While !HE1->(Eof()) .And. (HE1->E1_CLIENTE == cCodCli .and. HE1->E1_LOJA == cLojaCli)
	If At(AllTrim(HE1->E1_TIPO), cTitulos) == 0
		nAtraso	 := Date() - HE1->E1_VENCTO
		If nAtraso > 0	//existem titulos em atraso (sair)
			lTemDupl := .T.
			Exit
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

If nLin == 0
	MsgAlert(STR0008, STR0009)
	return nil
Endif

cCodCli	:= aStatCli[nLin,1]
cLoja	:= aStatCli[nLin,2]

dbSelectArea("HE1")
dbSetOrder(1)
dbGoTop()
dbSeek( cCodCli+cLoja,.f. )
While !Eof() .and. HE1->E1_CLIENTE == cCodCli .and. HE1->E1_LOJA == cLoja
	nAtraso := Date() - HE1->E1_VENCTO
	AADD(aDuplicatas,{HE1->E1_TIPO,HE1->E1_EMISSAO,HE1->E1_VENCTO, HE1->E1_SALDO,HE1->E1_NUM,HE1->E1_PARCELA, nAtraso })
	dbSkip()
Enddo

DEFINE DIALOG oDuplicatas TITLE "Duplicatas"

@ 18,03 SAY aStatCli[nLin,3] OF oDuplicatas
@ 35,5 TO 135,155 CAPTION "Duplicatas" OF oDuplicatas

@ 43,10 BROWSE oBrwDuplicatas SIZE 140,87 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER STR0011 WIDTH 30
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER STR0012 WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER STR0013 WIDTH 45
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER STR0014 WIDTH 50
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER STR0015 WIDTH 40
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER STR0018 WIDTH 40 
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 7 HEADER STR0016 WIDTH 40 
@ 140,050 BUTTON oBtnRetornar CAPTION STR0017 ACTION CloseDialog() SIZE 55,15 OF oDuplicatas

ACTIVATE DIALOG oDuplicatas

Return nil