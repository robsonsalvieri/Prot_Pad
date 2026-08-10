#INCLUDE "SFPR101.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OpenFiles           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Abre todos os arquivos utilizados pelo SFA	 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
Local lRet       := .T.
Local cStr       := ""
Local aTable     := {}
Local cTable     := ""
Local nTblRecs   := ADVTBL->(RecCount())
Local nAtuRecs   := 0
Local cTblNoOpen := "ADV_IND/HEMP" + "HA3" + cEmpresa
Local nContem    := 0

ShowControl(oSayFile)
ShowControl(oMeterFiles)

dbSelectArea("ADVTBL")
dbSetOrder(1)
dbGoTop()
While !ADVTBL->(Eof()) .And. lRet
	nContem := At(AllTrim(ADVTBL->TBLNAME), cTblNoOpen)
	If cTable != AllTrim(ADVTBL->TBLNAME) .And. nContem = 0
		cTable := AllTrim(ADVTBL->TBLNAME)
		If File(cTable)	
			SetText(oSayFile, STR0001 + ADVTBL->DESCR + Space(5)) //"Abrindo "
			lRet := OpenFile(cTable)
		Else
			// Criar Tabela e Indices
			SetText(oSayFile, STR0002 + ADVTBL->DESCR + Space(5)) //"Criando "
			lRet := OpenFile(cTable, .T.)
		EndIf
	EndIf
	ADVTBL->(dbSkip())
	nAtuRecs += 1
	nMeterFiles := (nAtuRecs/nTblRecs) * 100
	SetMeter(oMeterFiles,nMeterFiles)
EndDo

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OpenFile            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Abre um arquivo 								 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias: Alias a ser aberto, nIndex - Quantida de Indices	  ³±±
±±³          ³ cEmpresa: Codigo da Empresa								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OpenFile(cTable, lCreate, lReindex)
Local nIndex := 1
Local cAlias := Substr(cTable,1,3)
Local lRet   := .F.
Local aStru  := {}

lCreate  := If(lCreate  = Nil, lCreate  := .F., lCreate)
lReindex := If(lReindex = Nil, lReindex := .F., lReindex)

// Cria tabela inexistente
If lCreate
	dbSelectArea("ADVTBL")
	dbSetOrder(1)
	While !ADVTBL->(Eof()) .And. AllTrim(ADVTBL->TBLNAME) = cTable
		//aAdd(aStru, {AllTrim(ADVTBL->FLDNAME), ADVTBL->FLDNAME, ADVTBL->FLDTYPE, ADVTBL->FLDLENDEC})
		aAdd(aStru, {AllTrim(ADVTBL->FLDNAME), ADVTBL->FLDTYPE, ADVTBL->FLDLEN, ADVTBL->FLDLENDEC})
		ADVTBL->(dbSkip())
	EndDo
	dbCreate(cTable, aStru, "LOCAL" )
	
	lRet := dbUseArea( .T., "LOCAL", cTable, cAlias, .T., .F. )
	
	dbSelectArea("ADVIND")
	dbSetOrder(1)
	If dbSeek(cTable) .And. lRet
		nIndex := 1
		While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
			dbSelectArea(cAlias)
			dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)
			dbSetIndex(AllTrim(ADVIND->NOME_IDX))
			dbSelectArea("ADVIND")
			ADVIND->(dbSkip())
		EndDo
	EndIf
Else
// Abrindo tabela
	lRet := dbUseArea( .T., "LOCAL", cTable, cAlias, .T., .F. )
	
	dbSelectArea("ADVIND")
	dbSetOrder(1)
	If dbSeek(cTable) .And. lRet
		// reindexa  as tabelas conforme parametro
		If lReindex
			nIndex := 1
			While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
				dbSelectArea(cAlias)
				dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)
				dbSetIndex(AllTrim(ADVIND->NOME_IDX))
				dbSelectArea("ADVIND")
				ADVIND->(dbSkip())
			EndDo		
		Else
			While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
				dbSelectArea(cAlias)
				If !File(AllTrim(ADVIND->NOME_IDX))
					dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)	
				EndIf
				dbSetIndex(AllTrim(ADVIND->NOME_IDX))
				dbSelectArea("ADVIND")
				ADVIND->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldSenha            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Senha							 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cSenha: senha digitada, lClose - Fecha a janela			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles)
Local lRet   := .T.
Local lClose := .F.

If AllTrim(cSenha) != AllTrim(HA3->A3_SENHA)
	MsgStop(STR0003,STR0004) //"Senha Invalida!"###"Aviso"
	nTry += 1
	lRet := .F.
	If nTry > nTimes
		lClose := .T.
	EndIf
Else
	lClose := .T.
	lRet := OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
EndIf

If lClose
	CloseDialog()
EndIf
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CtrFaixa            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle das Faixas de Codigo				 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CtrFaixa()
Local lAtu:= .F.
dbSelectArea("HA3")  
dbGoTop()
if Empty(HA3->A3_PEDINI)
	HA3->A3_PEDINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PEDFIM)
	HA3->A3_PEDFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PROXPED)
	HA3->A3_PROXPED		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_CLIINI)
	HA3->A3_CLIINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->A3_CLIFIM)
	HA3->A3_CLIFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->A3_PROXCLI)
	HA3->A3_PROXCLI		:= "000001"
	lAtu:= .T.
Endif 
if Val(HA3->A3_PROXCLI) < Val(HA3->A3_CLIINI)
	HA3->A3_PROXCLI		:= HA3->A3_CLIINI
	lAtu:= .T.
Endif
if Val(HA3->A3_PROXPED) < Val(HA3->A3_PEDINI)
	HA3->A3_PROXPED		:= HA3->A3_PEDINI
	lAtu:= .T.
Endif

if lAtu
	dbCommit()
Endif

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VrfPerm             ³Autor: Fabio Garbin  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica Permissao de Acesso no SFA atraves da Tabela Sync ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VrfPerm()
Local dDtLimite
Local dDtAtual  := Date()  // Data Atual
Local dDtFirst  := Date()  // Data do Primeiro Acesso
Local lRet      := .F.     // Retorno da Funcao
Local nNumDia   := 0       // Total de Dias sem sincronizacao
Local nDiaSync  := 0       // Maximo de dias sem sincronismo

dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_DTSYNC")
	nDiaSync := Val(HCF->CF_VALOR)
	dDtFirst := StoD(SyncDate())
	If nDiaSync = 0
		lRet := .T.
	Else
		dDtLimite := dDtFirst + nDiaSync
		If dDtAtual <= dDtLimite
			lRet := .T.
		Else
			nNumDia := nDiaSync + (dDtAtual - dDtLimite)
			MsgStop(STR0005 + Str(nNumDia,3,0) + STR0006, STR0007) //"Acesso ao SFA não está permitido. O sincronismo nao é realizado a "###" dia(s). Faça o sincronismo para ter acesso ao SFA."###"Acesso"
		EndIf
	EndIf
Else
	lRet := .T.	
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OpenEmp             ³Autor: Fabio Garbin  ³   07/11/2002   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Abre o arquivo de Empresa utilizado pelo SFA	 		   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OpenEmp()
Local cTblEmp := "HEMP"
Local lRet    := .T.
Local cMsgRet := ""

// Abre Tabela de Empresa
If !File(cTblEmp)
	cMsgRet := STR0014
	lRet    := .F.
Else	
	lRet := dbUseArea( .T., "LOCAL", cTblEmp, "EMP", .T., .F. )
	dbSetIndex(cTblEmp + "1")
	dbGotop()
	cEmpresa := EMP->EMP_COD + "0"
EndIf

// Abre Tabela de Dicionarios
If !File("ADV_TBL") .Or. !File("ADV_IND")
	cMsgRet := STR0015
	lRet    := .F.
ElseIf lRet
	// Abre Arquivo ADV_TBL
	lRet := dbUseArea( .T., "LOCAL", "ADV_TBL", "ADVTBL", .T., .F. )
	dbSetIndex("SYNC_IDX")
	dbGotop()
	If lRet
		// Abre Arquivo ADV_TBL	
		lRet := dbUseArea( .T., "LOCAL", "ADV_IND", "ADVIND", .T., .F. )
		dbSetIndex("ADV_IND_IDX")
		dbGotop()   
		// Abre Arquivo Vendedor (HA3)
    	If lRet
			lRet := dbUseArea( .T., "LOCAL", "HA3" + cEmpresa, "HA3", .T., .F. )
			dbSetIndex("HA3" + cEmpresa + "1")
			dbGotop()
			If !lRet
				cMsgRet := 	STR0008 + cEmpresa + ")." //"Falha na abertura da tabela de vendedor (HA3"
				lRet    := .F.
			EndIf
		Else
			cMsgRet := 	STR0009 //"Falha na abertura da tabela de indices (ADV_IND)."
			lRet    := .F.
		EndIf
	Else
		cMsgRet := 	STR0010 //"Falha na abertura da tabela de estruturas (ADV_TBL)."
		lRet    := .F.	
	EndIf
EndIf

If !lRet
    Alert(cMsgRet)
EndIf


Return lRet


Function InitSync(oSayFile, oMeterFiles, nMeterFiles)

dbCloseAll()

DoSync()
// Reabre as tabelas
If oSayFile <> Nil
	If OpenEmp()
		If OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
			HideControl(oSayFile)
			HideControl(oMeterFiles)	
			CtrFaixa()	//Acerta as faixas de cod. de pedidos/clientes

			// Reinicializa variaveis publicas
			cUltGrupo     := ""
			cCalcProtheus := ""
			cQtdDec       := ""
			cSfaPeso      := ""
			cUmPeso       := ""
			nPagProd      := 0
			nLastProd     := 0
			nI            := 0
			nGrupo        := 1
			aGrupo        := {}
			aProduto      := {}
			aStatCli      := {}			
		EndIf
	EndIf   
EndIf

Return Nil

//Verifica se existem os arquivos de dados necessários ao SFA
Function VrfArquivos()
Local aTables := {"HA3","HA1","HRT","HD7","HU5","HCF","HC5","HC6","HD5","HPR",;
"HTC","HTP","HB1","HBM","HE4","HAT","HA4","HX5","HE1","HF4","HCN","HCO","HCP",;
"HCQ","HCR","HCS","HCT","HMT","HIN"}
Local i:=1, cTable:="", lRet:=.T.

For i:=1 to Len(aTables)
	cTable := aTables[i]+cEmpresa
	If !File(cTable)
		MsgStop(STR0011 + cTable + STR0012, STR0013) //"A tabela "###" não foi exportada. Rever os serviços de exportação."###"Abertura SFA"
		lRet:=.F.	
	Endif
Next

// Abre Arquivo de Configuracoes (HCF)
If lRet
	lRet := dbUseArea( .T., "LOCAL", "HCF" + cEmpresa, "HCF", .T., .F. )
	dbSetIndex("HCF" + cEmpresa + "1")
	dbGotop()
EndIf

Return lRet

Function DirtyTable()
Local ni := 1
Local aTables := {} 
Local aRecs := {}
Local nMeter := 0
Local oDlg, oMeter
Local oFldTable, oBrwTable, oBrwRecs, oCol, oDirtyTable, oClose

aAdd(aTables, {STR0016 , "HC5"})
aAdd(aTables, {STR0017 , "HA1"})

DEFINE DIALOG oDlg TITLE STR0019

@ 150, 90 METER oMeter SIZE 60,5 FROM 0 TO 100 OF oDlg

ADD FOLDER oFldTable CAPTION STR0018 OF oDlg
@ 15,00 BROWSE oBrwTable SIZE 160,55 ACTION LoadRecs(aTables, GridRow(oBrwTable), aRecs, oBrwRecs, oMeter, nMeter) OF oFldTable
SET BROWSE oBrwTable ARRAY aTables
ADD COLUMN oCol TO oBrwTable ARRAY ELEMENT 1 HEADER STR0018 WIDTH 100
@ 130, 78 BUTTON oDirtyTable CAPTION STR0019 SIZE 40,12 ACTION MarkDirty(aTables, GridRow(oBrwTable), aRecs, oMeter, nMeter) OF oFldTable
@ 130, 120 BUTTON oClose CAPTION STR0020 SIZE 40,12 ACTION CloseDialog() OF oFldTable

@ 72,00 BROWSE oBrwRecs SIZE 160,55 OF oFldTable
SET BROWSE oBrwRecs ARRAY aRecs
ADD COLUMN oCol TO oBrwRecs ARRAY ELEMENT 1 HEADER "" WIDTH 10 MARK EDITABLE
ADD COLUMN oCol TO oBrwRecs ARRAY ELEMENT 2 HEADER "" WIDTH 45
ADD COLUMN oCol TO oBrwRecs ARRAY ELEMENT 3 HEADER "" WIDTH 90

HideControl(oMeter)
LoadRecs(aTables, GridRow(oBrwTable), aRecs, oBrwRecs, oMeter, nMeter)

ACTIVATE DIALOG oDlg

Function LoadRecs(aTables, nTable, aRecs, oBrwRecs, oMeter, nMeter)

//aSize(aRecs, 0)
aRecs := {}
nMeter := 0
SetMeter(oMeter, nMeter)
ShowControl(oMeter)

If aTables[nTable, 2] = "HC5"
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbGoTop()
	While !HC5->(Eof())
		If AllTrim(HC5->C5_STATUS) = "N"
			HA1->(dbSetOrder(1))
			HA1->(dbSeek(HC5->C5_CLI+HC5->C5_LOJA))
			aAdd(aRecs, {.F., HC5->C5_NUM, HA1->A1_NOME, Recno()})
		EndIf
		nMeter += 100 / HC5->(RecCount())
		SetMeter(oMeter, nMeter)
		HC5->(dbSkip())
	EndDo
ElseIf aTables[nTable, 2] = "HA1"
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbGoTop()
	While !HA1->(Eof())
		If AllTrim(HA1->A1_STATUS) = "N"
			aAdd(aRecs, {.F., HA1->A1_COD, HA1->A1_LOJA, Recno()})
			nMeter += 100 / HA1->(RecCount())
			SetMeter(oMeter, nMeter)
		EndIf
		HA1->(dbSkip())
	EndDo
EndIf
If Len(aRecs) > 0
	SetArray(oBrwRecs, aRecs)	
Else
	MsgAlert(STR0021 , STR0018 + aTables[nTable, 2])
EndIf

HideControl(oMeter)
Return Nil

Function MarkDirty(aTables, nTable, aRecs, oMeter, nMeter)

dbSelectArea(aTables[nTable, 2])
dbSetOrder(1)
ShowControl(oMeter)
If aTables[nTable, 2] = "HC5"
	For ni := 1 To Len(aRecs)
		If aRecs[ni, 1]
			GoTo(aRecs[ni, 4])
			SetDirty(aTables[nTable, 2], aRecs[ni, 4], .T.)
			dbSelectArea("HC6")
			dbSetOrder(1)
			If dbSeek(HC5->C5_NUM)
				While !HC6->(Eof()) .And. HC5->C5_NUM = HC6->C6_NUM
					SetDirty("HC6", Recno(), .T.)
					HC6->(dbSkip())
				EndDo
				dbSelectArea(aTables[nTable, 2])
			EndIf
			nMeter += 100 / Len(aRecs)
			SetMeter(oMeter, nMeter)
		EndIf
	Next
Else
	For ni := 1 To Len(aRecs)
		If aRecs[ni, 1]
			GoTo(aRecs[ni, 4])
			SetDirty(aTables[nTable, 2], aRecs[ni, 4], .T.)
			nMeter += 100 / Len(aRecs)
			SetMeter(oMeter, nMeter)
		EndIf
	Next
EndIf
HideControl(oMeter)
Return Nil
