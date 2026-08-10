#INCLUDE "SFVN004.ch"

Function FolderDuplicatas(oDuplicatas, aDuplicatas, oBrwDuplicatas, oCol, oDlg)

Local  nAtraso := 0
Local  nColTit := 8.5*TamADVC("HE1_NUM",1)
Local  cPictVal := SetPicture("HPR","HPR_UNI")

// Duplicatas
ADD FOLDER oDuplicatas CAPTION STR0001 OF oDlg //"Duplicatas"
@ 40,5 TO 140,155 CAPTION STR0001 OF oDuplicatas //"Duplicatas"

dbSelectArea("HE1")
dbSetOrder(1)
//dbGoTop()
dbSeek(RetFilial("HE1") + HA1->HA1_COD+HA1->HA1_LOJA,.f. )
While !Eof() .and. HE1->HE1_CLI == HA1->HA1_COD .and. HE1->HE1_LOJA == HA1->HA1_LOJA
	nAtraso := Date() - HE1->HE1_VENCTO
	AADD(aDuplicatas,{HE1->HE1_TIPO,HE1->HE1_EMISS,HE1->HE1_VENCTO, HE1->HE1_SALDO,HE1->HE1_NUM,HE1->HE1_PARCEL,nAtraso })
	dbSkip()
Enddo

@ 50,10 BROWSE oBrwDuplicatas SIZE 140,83 OF oDuplicatas
SET BROWSE oBrwDuplicatas ARRAY aDuplicatas
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 1 HEADER STR0002 WIDTH 30 //"Tipo"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 2 HEADER STR0003 WIDTH 45 //"Emissao"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 3 HEADER STR0004 WIDTH 45 //"Vencto."
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 4 HEADER STR0005 WIDTH 50 PICTURE cPictVal //"Valor"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 5 HEADER STR0006 WIDTH nColTit //"Título Nº"
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 6 HEADER STR0039 WIDTH 20 //"Parc."
ADD COLUMN oCol TO oBrwDuplicatas ARRAY ELEMENT 7 HEADER STR0007 WIDTH 35 //"Dias Atrasado"

Return Nil


Function FolderPosicao(oPosicao, aPosicao, oBrwPosicao, oCol, oDlg)

ADD FOLDER oPosicao    CAPTION STR0008 OF oDlg //"Financeira"
@ 40,5 TO 140,155 CAPTION STR0009 OF oPosicao //"Posição Financeira"
  
If HA1->(FieldPos("HA1_SALGEN")) <> 0
	AADD(aPosicao,{STR0010,HA1->HA1_SALGEN})//Especif. Verdes Mares //"SALDO:"
Else
	AADD(aPosicao,{STR0010,""}) //"SALDO:"
Endif
AADD(aPosicao,{STR0001,HA1->HA1_SALDUP}) //"Duplicatas"
AADD(aPosicao,{STR0011,HA1->HA1_VACUM}) //"Ano"
AADD(aPosicao,{STR0012,HA1->HA1_LC})    //Acrescentado em 27/12/02 //"Limite Cr."
AADD(aPosicao,{STR0013,""}) //"ATRASO:"
AADD(aPosicao,{STR0005,HA1->HA1_ATR}) //"Valor"
AADD(aPosicao,{STR0014,HA1->HA1_PAGATR}) //"Nº. Pagtos"
AADD(aPosicao,{STR0015,HA1->HA1_METR}) //"Média"
AADD(aPosicao,{STR0016,HA1->HA1_MATR}) //"Maior"
AADD(aPosicao,{STR0017,""}) //"CHEQUES:"
AADD(aPosicao,{STR0018,HA1->HA1_CHQDEV}) //"Devolvido"
AADD(aPosicao,{STR0019,HA1->HA1_DTULCH}) //"Ult.Devolv"
AADD(aPosicao,{STR0020,""}) //"COMPRAS:"
AADD(aPosicao,{STR0021,HA1->HA1_NROCOM}) //"Nº"
AADD(aPosicao,{STR0022,HA1->HA1_PRICOM}) //"1ª"
AADD(aPosicao,{STR0023,HA1->HA1_ULTCOM}) //"Última"
AADD(aPosicao,{STR0024,""}) //"TÍTULOS:"
AADD(aPosicao,{STR0025,HA1->HA1_TITPRO}) //"Protestados"

@ 50,10 BROWSE oBrwPosicao SIZE 140,84 OF oPosicao
SET BROWSE oBrwPosicao ARRAY aPosicao
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwPosicao ARRAY ELEMENT 2 HEADER "" WIDTH 50

Return Nil


Function FolderDetCli(oDetCli, aDetCli, oBrwDetCli, oCol, oDlg)

ADD FOLDER oDetCli CAPTION STR0026 OF oDlg //"Cliente"
@ 40,5 TO 140,155 CAPTION STR0027 OF oDetCli //"Detalhe do Cliente"

AADD(aDetCli,{STR0028,HA1->HA1_NOME}) //"R.Soc."
AADD(aDetCli,{STR0029,HA1->HA1_NREDUZ}) //"Fant."
AADD(aDetCli,{STR0030,HA1->HA1_END}) //"End."
AADD(aDetCli,{STR0031,HA1->HA1_BAIRRO}) //"Bairro"
AADD(aDetCli,{STR0032,HA1->HA1_CEP}) //"CEP"
AADD(aDetCli,{STR0033,HA1->HA1_MUN}) //"Cid."
AADD(aDetCli,{STR0034,HA1->HA1_EST}) //"UF"
AADD(aDetCli,{STR0035,HA1->HA1_TEL}) //"Tel"
AADD(aDetCli,{STR0036,HA1->HA1_CGC}) //"CGC"
AADD(aDetCli,{STR0037,HA1->HA1_INSCR}) //"IE"
AADD(aDetCli,{STR0038,HA1->HA1_EMAIL}) //"E-Mail"

@ 50,10 BROWSE oBrwDetCli SIZE 140,84 OF oDetCli
SET BROWSE oBrwDetCli ARRAY aDetCli
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 1 HEADER "" WIDTH 30
ADD COLUMN oCol TO oBrwDetCli ARRAY ELEMENT 2 HEADER "" WIDTH 85

Return Nil
