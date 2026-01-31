#INCLUDE "SFVN004.ch"
Function FolderDuplicatas(oDuplicatas, aDuplicatas, oBrwDuplicatas, oCol, oDlg)
Local  nAtraso := 0
// Duplicatas
ADD FOLDER oDuplicatas CAPTION STR0001 OF oDlg //"Duplicatas"
@ 40,5 TO 140,155 CAPTION STR0001 OF oDuplicatas //"Duplicatas"

dbSelectArea("HE1")
dbSetOrder(1)
dbGoTop()
dbSeek( HA1->A1_COD+HA1->A1_LOJA,.f. )
While !Eof() .and. HE1->E1_CLIENTE == HA1->A1_COD .and. HE1->E1_LOJA == HA1->A1_LOJA
	nAtraso := Date() - HE1->E1_VENCTO
	AADD(aDuplicatas,{HE1->E1_TIPO,HE1->E1_EMISSAO,HE1->E1_VENCTO, HE1->E1_SALDO,HE1->E1_NUM,HE1->E1_PARCELA, nAtraso })
	dbSkip()
//	If nAtraso > 0
//		GridSetCellColor(oBrwDuplicatas, Len(aDuplicatas), 1, CLR_HRED, CLR_WHITE)
//	EndIf
Enddo

@ 50,10 BROWSE oBrwDuplicatas SIZE 140,83 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER STR0002 WIDTH 30 //"Tipo"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER STR0003 WIDTH 45 //"Emissao"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER STR0004 WIDTH 45 //"Vencto."
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER STR0005 WIDTH 50 //"Valor"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER STR0006 WIDTH 40 //"Título Nº"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER STR0039 WIDTH 20 //"Parc."
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 7 HEADER STR0007 WIDTH 35 //"Dias Atrasado"

Return Nil


Function FolderPosicao(oPosicao, aPosicao, oBrwPosicao, oCol, oDlg)

ADD FOLDER oPosicao    CAPTION STR0008 OF oDlg //"Financeira"
@ 40,5 TO 140,155 CAPTION STR0009 OF oPosicao //"Posição Financeira"
  
If HA1->(FieldPos("A1_SALGEN")) <> 0
	AADD(aPosicao,{STR0010,HA1->A1_SALGEN})//Especif. Verdes Mares //"SALDO:"
Else
	AADD(aPosicao,{STR0010,""}) //"SALDO:"
Endif
AADD(aPosicao,{STR0001,HA1->A1_SALDUP}) //"Duplicatas"
AADD(aPosicao,{STR0011,HA1->A1_VACUM}) //"Ano"
AADD(aPosicao,{STR0012,HA1->A1_LC})    //Acrescentado em 27/12/02 //"Limite Cr."
AADD(aPosicao,{STR0013,""}) //"ATRASO:"
AADD(aPosicao,{STR0005,HA1->A1_ATR}) //"Valor"
AADD(aPosicao,{STR0014,HA1->A1_PAGATR}) //"Nº. Pagtos"
AADD(aPosicao,{STR0015,HA1->A1_METR}) //"Média"
AADD(aPosicao,{STR0016,HA1->A1_MATR}) //"Maior"
AADD(aPosicao,{STR0017,""}) //"CHEQUES:"
AADD(aPosicao,{STR0018,HA1->A1_CHQDEVO}) //"Devolvido"
AADD(aPosicao,{STR0019,HA1->A1_DTULCHQ}) //"Ult.Devolv"
AADD(aPosicao,{STR0020,""}) //"COMPRAS:"
AADD(aPosicao,{STR0021,HA1->A1_NROCOM}) //"Nº"
AADD(aPosicao,{STR0022,HA1->A1_PRICOM}) //"1ª"
AADD(aPosicao,{STR0023,HA1->A1_ULTCOM}) //"Última"
AADD(aPosicao,{STR0024,""}) //"TÍTULOS:"
AADD(aPosicao,{STR0025,HA1->A1_TITPROT}) //"Protestados"

@ 50,10 BROWSE oBrwPosicao SIZE 140,84 OF oPosicao
SET BROWSE oBrwPosicao ARRAY aPosicao
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 2 HEADER "" WIDTH 50

Return Nil


Function FolderDetCli(oDetCli, aDetCli, oBrwDetCli, oCol, oDlg)

ADD FOLDER oDetCli CAPTION STR0026 OF oDlg //"Cliente"
@ 40,5 TO 140,155 CAPTION STR0027 OF oDetCli //"Detalhe do Cliente"

AADD(aDetCli,{STR0028,HA1->A1_NOME}) //"R.Soc."
AADD(aDetCli,{STR0029,HA1->A1_NREDUZ}) //"Fant."
AADD(aDetCli,{STR0030,HA1->A1_END}) //"End."
AADD(aDetCli,{STR0031,HA1->A1_BAIRRO}) //"Bairro"
AADD(aDetCli,{STR0032,HA1->A1_CEP}) //"CEP"
AADD(aDetCli,{STR0033,HA1->A1_MUN}) //"Cid."
AADD(aDetCli,{STR0034,HA1->A1_EST}) //"UF"
AADD(aDetCli,{STR0035,HA1->A1_TEL}) //"Tel"
AADD(aDetCli,{STR0036,HA1->A1_CGC}) //"CGC"
AADD(aDetCli,{STR0037,HA1->A1_INSCR}) //"IE"
AADD(aDetCli,{STR0038,HA1->A1_EMAIL}) //"E-Mail"

@ 50,10 BROWSE oBrwDetCli SIZE 140,84 OF oDetCli
SET BROWSE oBrwDetCli ARRAY aDetCli
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 1 HEADER "" WIDTH 30
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 2 HEADER "" WIDTH 85

Return Nil