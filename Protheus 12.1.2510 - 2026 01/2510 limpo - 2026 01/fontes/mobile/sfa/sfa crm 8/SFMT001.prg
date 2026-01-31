#INCLUDE "SFMT001.ch"
#include "eADVPL.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitMetas           ³Autor - Fabio Garbin ³ Data ³13/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela de Envio/Visualizacao de Mensagens (Funcoes:SFMT101)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function InitMetas()

Local oDlg, oSay, oSayPrd, oCol, oCboTipo, oSayMes, oCboMeses
Local oFldParam, oFldData, oBtnRet, oBrwMet, oSayGrp, oCboGrupo
Local aTipoMet 	:= {STR0001, STR0002} //"Mes"###"Grupo"
Local aCampo 	:= {}
Local aMeses 	:= {}
Local aGrupo 	:= {}
Local aMeta 	:= {}
Local cTable 	:= "HMT"
Local cPictVal	:= SetPicture("HPR","HPR_UNI")
Local cPrdDesc 	:= ""
Local nTamBox1	:= 100
Local nTamBox2	:= Iif(lNotTouch,35,70)
Local nCampo 	:= 1
Local nTipoMet 	:= 1
Local nMeses 	:= 1
Local nGrupo 	:= 1

#IFDEF __PALM__
	nTamBox1	:= 145
	nTamBox2	:= 70
#ENDIF

If !(Select("HMT")>0)
	MsgStop(STR0003 + cTable + STR0004,STR0005) //"Tabela de Metas "###" não encontrada!"###"Aviso"
	return nil
EndIf

// Carrega Array dos Meses
LoadMes(aMeses)
// Carrega Array dos Grupos
LoadGrupos(aGrupo)

DEFINE DIALOG oDlg TITLE STR0006 //"Metas do Vendedor"

ADD FOLDER oFldParam CAPTION STR0007 ON ACTIVATE MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo, oSayMes, oCboMeses) of oDlg //"Parametros"

@ 18,05 SAY oSay PROMPT STR0008 OF oFldParam //"Metas por "
// Tipos de Metas
@ 18,60 COMBOBOX oCboTipo VAR nTipoMet ITEMS aTipoMet ACTION MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo, oSayMes, oCboMeses) SIZE nTamBox1,nTamBox2 OF oFldParam
// Meses
@ 40,05 SAY oSayMes PROMPT STR0009 OF oFldParam //"Meses "
@ 40,60 COMBOBOX oCboMeses VAR nMeses ITEMS aMeses SIZE nTamBox1,nTamBox2 OF oFldParam
// Grupos
@ 40,05 SAY oSayGrp PROMPT STR0010 OF oFldParam //"Grupos : "
@ 40,60 COMBOBOX oCboGrupo VAR nGrupo ITEMS aGrupo SIZE nTamBox1,nTamBox2 OF oFldParam

ADD FOLDER oFldData CAPTION STR0011 ON ACTIVATE PesquisaMeta(nTipoMet, aMeta, aMeses[nMeses], aGrupo[nGrupo], oBrwMet, oFldData, oDlg) of oDlg //"Dados"

@ 30,05 BROWSE oBrwMet SIZE 145,100 /*ON CLICK PesqProd(oBrwMet, oSayPrd, @cPrdDesc, aMeta, 1)*/ OF oFldData
SET BROWSE oBrwMet ARRAY aMeta
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 1 HEADER "Produto" WIDTH 45
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 2 HEADER STR0012 WIDTH 55 ALIGN RIGHT //"Qtd"
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 3 HEADER STR0013 WIDTH 55 PICTURE cPictVal ALIGN RIGHT //"Valor"
//ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 4 HEADER STR0014 WIDTH 55 ALIGN RIGHT //"Qtd Real."
//ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 5 HEADER STR0015 WIDTH 55 PICTURE cPictVal ALIGN RIGHT //"Valor Real."

@ 110,05 SAY oSayPrd PROMPT cPrdDesc OF oFldData

//@ 130,070 BUTTON oBtnPsq CAPTION STR0016 SIZE 43,12 ACTION PesquisaMeta(nTipoMet, aMeta, aMeses[nMeses], aGrupo[nGrupo], oBrwMet, oFldData, oDlg) of oFldParam //"Pesquisar"
@ 135,110 BUTTON oBtnRet CAPTION STR0017  SIZE 43,12 ACTION CloseDialog() of oDlg //"Retornar"

MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo, oSayMes, oCboMeses)

ACTIVATE DIALOG oDlg

Return nil
