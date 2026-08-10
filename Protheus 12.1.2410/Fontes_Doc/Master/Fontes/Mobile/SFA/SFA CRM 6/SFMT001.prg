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

Local oDlg, oSay, oSayPrd
Local oFldParam, oFldData, oBtnPsq, oBtnRet
Local aCampo := {}, nCampo := 1
Local oCboTipo, nTipoMet := 1, aTipoMet := {STR0002, STR0018} //"Grupo"### "Produto"
Local nMeses := 1, aMeses := {}
Local nGrupo := 1, aGrupo := {}
Local oBrwMet, cColuna1 := "", cItemDesc := ""
Local nMetaType := 0
Local aMeta := {}
Local cTable := "HMT"+cEmpresa
Local oCol
Local cPerMeta := "", cDataIni := ""
Local oMeterMeta

If !File(cTable)
	MsgStop(STR0003 + cTable + STR0004,STR0005) //"Tabela de Metas "###" não encontrada!"###"Aviso"
	return nil
EndIf

dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_SFAMTTP")
	nMetaType := Val(HCF->CF_VALOR)
Else
	nMetaType := 1
Endif

dbSelectArea("HMT")
dbSetOrder(1)
dbGotop()

If HMT->(Reccount()) = 0
	MsgStop(STR0019,STR0005)
	Return Nil
EndIf

cDataIni := HMT->MT_DATA

If nMetaType = 1  // Mensal 
	cPerMeta := DtoC(StoD(cDataIni)) + " a " + DtoC((StoD(cDataIni) + 30))
ElseIf nMetaType = 2 // Semanal
	cPerMeta := DtoC(StoD(cDataIni)) + " a " + DtoC((StoD(cDataIni) + 7))
ElseIf nMetaType = 3 // Diária
	cPerMeta := DtoC(StoD(cDataIni)) + " a " + DtoC(StoD(cDataIni))
Else
	MsgAlert("Opção de metas não configurada", "Metas")
	Return Nil
Endif

// Carrega Array dos Meses
LoadMes(aMeses)

// Carrega Array dos Grupos
LoadGrupos(aGrupo)

DEFINE DIALOG oDlg TITLE STR0006 //"Metas do Vendedor"
ADD FOLDER oFldParam CAPTION STR0007 of oDlg //"Parametros"

@ 18,05 SAY oSay PROMPT "Periodo de Metas:" OF oFldParam //"Periodo de Metas: "
@ 18,50 GET oSay VAR cPerMeta READONLY NO UNDERLINE OF oFldParam

@ 40,05 SAY oSay PROMPT STR0008 OF oFldParam //"Metas por "
// Tipos de Visualizaçao Metas
#IFDEF __PALM__
	@ 40,60 COMBOBOX oCboTipo VAR nTipoMet ITEMS aTipoMet SIZE 145,70 OF oFldParam
#ELSE
	@ 40,60 COMBOBOX oCboTipo VAR nTipoMet ITEMS aTipoMet SIZE 100,70 OF oFldParam
#ENDIF

@ 150, 90 METER oMeterMeta SIZE 65, 5 FROM 0 TO 100 OF oDlg

HideControl(oMeterMeta)

@ 130,070 BUTTON oBtnPsq CAPTION STR0016 SIZE 43,12 ACTION PesquisaMeta(nTipoMet, aMeta, @cColuna1, oMeterMeta, oBrwMet, oFldData, oDlg) of oFldParam //"Pesquisar"
@ 130,114 BUTTON oBtnRet CAPTION STR0017  SIZE 43,12 ACTION CloseDialog() of oFldParam//"Retornar"

ADD FOLDER oFldData CAPTION STR0011 ON ACTIVATE AtuFolderData(oBrwMet,aMeta) of oDlg //"Dados"

@ 18,05 BROWSE oBrwMet SIZE 150,95 ON CLICK PesqItem(oBrwMet, oSayPrd, aMeta, @cItemDesc, nTipoMet) OF oFldData
SET BROWSE oBrwMet ARRAY aMeta
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 1 HEADER cColuna1 WIDTH 45
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 2 HEADER STR0012 WIDTH 55 ALIGN RIGHT //"Qtd"
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 3 HEADER STR0013 WIDTH 55 ALIGN RIGHT //"Valor"
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 4 HEADER STR0014 WIDTH 55 ALIGN RIGHT //"Qtd Real."
ADD COLUMN oCol TO oBrwMet ARRAY ELEMENT 5 HEADER STR0015 WIDTH 55 ALIGN RIGHT //"Valor Real."

@ 125, 05 GET oSayPrd VAR cItemDesc SIZE 120,10  READONLY NO UNDERLINE OF oFldData

ACTIVATE DIALOG oDlg

Return .T.