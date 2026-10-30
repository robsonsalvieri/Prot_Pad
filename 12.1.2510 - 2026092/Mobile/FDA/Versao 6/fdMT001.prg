#INCLUDE "FDMT001.ch"
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

Local oDlg, oSay, oSayGrp, oSayPrd
Local oFldParam, oFldData, oBtnPsq, oBtnRet
Local aCampo := {}, nCampo := 1
Local oCboTipo, nTipoMet := 1, aTipoMet := {STR0001, STR0002} //"Mes"###"Grupo"
Local oCboMeses, nMeses := 1, aMeses := {}
Local oCboGrupo, nGrupo := 1, aGrupo := {}
Local oBrwMet, cColuna1 := "", cPrdDesc := ""
Local aMeta := {}
Local cTable := "HMT"+cEmpresa
Local oCol

If !File(cTable)
	MsgStop(STR0003 + cTable + STR0004,STR0005) //"Tabela de Metas "###" não encontrada!"###"Aviso"
	return nil
EndIf

// Carrega Array dos Meses
LoadMes(aMeses)
// Carrega Array dos Grupos
LoadGrupos(aGrupo)

DEFINE DIALOG oDlg TITLE STR0006 //"Metas do Vendedor"

ADD FOLDER oFldParam CAPTION STR0007 ON ACTIVATE MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo) of oDlg //"Parametros"

@ 18,05 SAY oSay PROMPT STR0008 OF oFldParam //"Metas por "
// Tipos de Metas
#IFDEF __PALM__
	@ 18,60 COMBOBOX oCboTipo VAR nTipoMet ITEMS aTipoMet ACTION MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo) SIZE 145,70 OF oFldParam
#ELSE
	@ 18,60 COMBOBOX oCboTipo VAR nTipoMet ITEMS aTipoMet ACTION MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo) SIZE 100,70 OF oFldParam
#ENDIF
// Meses
@ 40,05 SAY oSay PROMPT STR0009 OF oFldParam //"Meses "
#IFDEF __PALM__
	@ 40,60 COMBOBOX oCboMeses VAR nMeses ITEMS aMeses SIZE 145,70 OF oFldParam
#ELSE
	@ 40,60 COMBOBOX oCboMeses VAR nMeses ITEMS aMeses SIZE 100,70 OF oFldParam
#ENDIF

// Grupos
@ 62,05 SAY oSayGrp PROMPT STR0010 OF oFldParam //"Grupos : "
#IFDEF __PALM__
	@ 62,60 COMBOBOX oCboGrupo VAR nGrupo ITEMS aGrupo SIZE 145,70 OF oFldParam
#ELSE
	@ 62,60 COMBOBOX oCboGrupo VAR nGrupo ITEMS aGrupo SIZE 100,70 OF oFldParam
#ENDIF
ADD FOLDER oFldData CAPTION STR0011 of oDlg //"Dados"

@ 30,05 BROWSE oBrwMet SIZE 145,80 ON CLICK PesqProd(oBrwMet, oSayPrd, @cPrdDesc, aMeta, 1) OF oFldData
SET BROWSE oBrwMet ARRAY aMeta
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 1 HEADER cColuna1 WIDTH 45
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 2 HEADER STR0012 WIDTH 55 //"Qtd"
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 3 HEADER STR0013 WIDTH 55 //"Valor"
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 4 HEADER STR0014 WIDTH 55 //"Qtd Real."
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 5 HEADER STR0015 WIDTH 55 //"Valor Real."

@ 110,05 SAY oSayPrd PROMPT cPrdDesc OF oFldData

@ 130,070 BUTTON oBtnPsq CAPTION BTN_BITMAP_SEARCH SYMBOL SIZE 43,12 ACTION PesquisaMeta(nTipoMet, aMeta, aMeses[nMeses], aGrupo[nGrupo], @cColuna1, oBrwMet, oFldData, oDlg) of oDlg
@ 130,114 BUTTON oBtnRet CAPTION STR0016  SIZE 43,12 ACTION CloseDialog() of oDlg //"Retornar"

MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo)

ACTIVATE DIALOG oDlg

Return nil