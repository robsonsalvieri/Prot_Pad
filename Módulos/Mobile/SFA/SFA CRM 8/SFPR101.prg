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
Local cTblNoOpen := "ADV_IND/ADV_COLS/HHEMP"// + "/HA3" + cEmpresa
Local nContem    := 0
Local cAlias     := ""
Local nTableId   := 0
Local nRecno     := 0

//verificar se esta nulo                
If oSayFile <> Nil .And. oMeterFiles <> Nil
   ShowControl(oSayFile)
   ShowControl(oMeterFiles)
EndIf 

dbSelectArea("ADVTBL")
dbSetOrder(1)
dbGoTop()
//dbSeek(cEmpresa)
While !ADVTBL->(Eof()) /* .And. ADVTBL->TBL_EMP = cEmpresa*/ .And. lRet
	If ADVTBL->TBL_EMP = "@@" .Or. ADVTBL->TBL_EMP = cEmpresa
		cAlias := SubStr(AllTrim(ADVTBL->TBLNAME),1,3)
		//If At(cEmpresa,AllTrim(ADVTBL->TBLNAME)) = 0
			//nRecno   := ADVTBL->(Recno())
			nTableId := ADVTBL->TABLEID
			//If dbSeek(cAlias + cEmpresa)
			//	GoTo(nRecno)
			 //	While !ADVTBL->(Eof()) .And. nTableId == ADVTBL->TABLEID
			 //		ADVTBL->(dbSkip())
			 //	EndDo
			 //	Loop
			//Else
			//	GoTo(nRecno)
			//EndIf
		//EndIf
		nContem := At(AllTrim(ADVTBL->TBLNAME), cTblNoOpen)
		If nContem = 0
		//If cTable != AllTrim(ADVTBL->TBLNAME) .And. nContem = 0
			cTable := AllTrim(ADVTBL->TBLNAME)
			If File(cTable)	  
				If oSayFile <> Nil
				   SetText(oSayFile, STR0001 + ADVTBL->DESCR + Space(5)) //"Abrindo "   
			    EndIf
				lRet := OpenFile(nTableId, cTable,,)
			Else
				// Criar Tabela e Indices
				If oSayFile <> Nil
				   SetText(oSayFile, STR0002 + ADVTBL->DESCR + Space(5)) //"Criando "
				EndIf
				lRet := OpenFile(nTableId, cTable, .T.,)
			EndIf
		EndIf
	EndIf
	ADVTBL->(dbSkip())
	nAtuRecs += 1
	nMeterFiles := (nAtuRecs/nTblRecs) * 100
    If oMeterFiles <> Nil
       SetMeter(oMeterFiles,nMeterFiles)
    Endif
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
Function OpenFile(nTableId, cTable, lCreate, lReindex)

Local cAlias 	:= Substr(cTable,1,3)
Local cTableId 	:= Str(nTableId,4,0)
Local lRet   	:= .F.
Local aStru  	:= {}

lCreate  := If(lCreate  = Nil, lCreate  := .F., lCreate)
lReindex := If(lReindex = Nil, lReindex := .F., lReindex)

// Cria tabela inexistente
If lCreate
	dbSelectArea("ADVCOLS")
	dbSetOrder(1)
    If dbSeek(cTableId)
		While !ADVCOLS->(Eof()) .And. ADVTBL->TABLEID = nTableId
			//aAdd(aStru, {AllTrim(ADVTBL->FLDNAME), ADVTBL->FLDNAME, ADVTBL->FLDTYPE, ADVTBL->FLDLENDEC})
			aAdd(aStru, {AllTrim(ADVCOLS->FLDNAME), ADVCOLS->FLDTYPE, ADVCOLS->FLDLEN, ADVCOLS->FLDLENDEC})
			ADVCOLS->(dbSkip())
		EndDo
	Else
		MsgAlert("Campos nao encotrados na ADV_COLS.","Criacao " + cTable)
	EndIf
	dbCreate(cTable, aStru, "LOCAL" )
	
	lRet := dbUseArea( .T., "LOCAL", cTable, cAlias, .T., .F. )
	
	dbSelectArea("ADVIND")
	dbSetOrder(1)
	If dbSeek(cTableId) .And. lRet
		While !ADVIND->(Eof()) .And. nTableId = ADVIND->TABLEID
		//While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
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
	If dbSeek(cTableId) .And. lRet
		// reindexa  as tabelas conforme parametro
		If lReindex
			While !ADVIND->(Eof()) .And. nTableId = ADVIND->TABLEID
				dbSelectArea(cAlias)
				dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)
				dbSetIndex(AllTrim(ADVIND->NOME_IDX))
				dbSelectArea("ADVIND")
				ADVIND->(dbSkip())
			EndDo		
		Else
			While !ADVIND->(Eof()) .And. nTableId = ADVIND->TABLEID
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


If AllTrim(cSenha) != AllTrim(HA3->HA3_SENHA)
	MsgStop(STR0003,STR0004) //"Senha Invalida!"###"Aviso"
	nTry += 1
	lRet := .F.
	If nTry > nTimes
		lClose := .T.
	EndIf
Else
	lClose := .T.
	lRet := OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Entrada do Sistema ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("SFAPR001")
		ExecBlock("SFAPR001", .F., .F.)
	EndIf
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
dbSetOrder(1)
dbSeek(RetFilial("HA3"))

if Empty(HA3->HA3_PEDINI)
	HA3->HA3_PEDINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->HA3_PEDFIM)
	HA3->HA3_PEDFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->HA3_PROPED)
	HA3->HA3_PROPED		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->HA3_CLIINI)
	HA3->HA3_CLIINI		:= "000001"
	lAtu:= .T.
Endif
if Empty(HA3->HA3_CLIFIM)
	HA3->HA3_CLIFIM		:= "999999"
	lAtu:= .T.
Endif
if Empty(HA3->HA3_PROCLI)
	HA3->HA3_PROCLI		:= "000001"
	lAtu:= .T.
Endif 
if Val(HA3->HA3_PROCLI) < Val(HA3->HA3_CLIINI)
	HA3->HA3_PROCLI		:= HA3->HA3_CLIINI
Endif
if Val(HA3->HA3_PROPED) < Val(HA3->HA3_PEDINI)
	HA3->HA3_PROPED		:= HA3->HA3_PEDINI
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

If !VrfArquivos()
	Return Nil
EndIf

dbSelectArea("HCF")
dbSetOrder(1)
dbGoTop()

If dbSeek(RetFilial("HCF") + "MV_DTSYNC")
	nDiaSync := Val(HCF->HCF_VALOR)
	dDtFirst := StoD(SyncDate())
	If nDiaSync = 0
		lRet := .T.
	Else
		dDtLimite := dDtFirst + nDiaSync
		If dDtAtual <= dDtLimite
			lRet := .T.
		Else
			nNumDia := nDiaSync + (dDtAtual - dDtLimite)
			MsgStop(STR0005 + Str(nNumDia,3,0) + STR0006, STR0007) //"Acesso ao SFA nÒo estß permitido. O sincronismo nao Ú realizado a "###" dia(s). Faþa o sincronismo para ter acesso ao SFA."###"Acesso"
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
±±³Descri‡ao ³ Abre o arquivo de Empresa utilizado pelo SFA	 		   	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function OpenEmp(aEmp)

Local cTblEmp := "HHEMP"
Local cMsgRet := ""
Local lRet    := .T.
Local nRecEmp := 0

// Abre Tabela de Empresa
If !File(cTblEmp)
	cMsgRet := STR0014
	lRet    := .F.
Else	
	lRet := dbUseArea( .T., "LOCAL", cTblEmp, "HM0", .T., .F. )
	dbSetIndex(cTblEmp + "1")
	dbGotop()
	nRecEmp := HM0->(RecCount())
	If nRecEmp = 0
	    cMsgRet := STR0022
	    lRet    := .F.
	ElseIf nRecEmp = 1
    	    cEmpresa := AllTrim(HM0->HM0_COD)
	    cFilial := AllTrim(HM0->HM0_FILIAL)
	    cSufixo := AllTrim(HM0->HM0_SUFIXO)
  	    aAdd(aEmp, cEmpresa + "/" + HM0->HM0_FILIAL + "-" + HM0->HM0_NOME)
	Else
		If Empty(cEmpresa)
			HM0->(dbGoTop())
			While !HM0->(Eof())
			    aAdd(aEmp, AllTrim(HM0->HM0_COD) + "/" + HM0->HM0_FILIAL + "-" + HM0->HM0_NOME)
			    HM0->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

// Abre Tabela de Dicionarios
If !File("ADV_TBL") .Or. !File("ADV_IND") .Or. !File("ADV_COLS")
	cMsgRet := STR0015
	lRet    := .F.
ElseIf lRet
	// Abre Arquivo ADV_TBL
	lRet := dbUseArea( .T., "LOCAL", "ADV_TBL", "ADVTBL", .T., .F. )
	dbSetIndex("SYNC_IDX")
	dbGotop()

	If ADVTBL->(RecCount()) = 0
		cMsgRet := STR0025 // "Não há registros na tabela ADV_TBL"
		lRet    := .F.
	EndIf

	lRet := dbUseArea( .T., "LOCAL", "ADV_COLS", "ADVCOLS", .T., .F. )
	dbSetIndex("ADV_COLS_IDX")
	dbSetIndex("ADV_COLS_FLD")	// Abrindo o segundo indice da tabela
	dbSetOrder(1) 				// Restaurando no primeiro indice
	dbGotop()

	If ADVCOLS->(RecCount()) = 0
		cMsgRet := STR0026 // "Não há registros na tabela ADV_COLS"
		lRet    := .F.
	EndIf

	If lRet
		// Abre Arquivo ADV_IND
		lRet := dbUseArea( .T., "LOCAL", "ADV_IND", "ADVIND", .T., .F. )
		dbSetIndex("ADV_IND_IDX")
		dbGotop()   

		If ADVIND->(RecCount()) = 0
			cMsgRet := STR0027 //"Não há registros na tabela ADV_IND"
			lRet    := .F.
		EndIf

	Else
		cMsgRet := 	STR0009 //"Falha na abertura da tabela de indices (ADV_IND)."
		lRet    := .F.
	EndIf
Else
	If lRet
		cMsgRet := 	STR0010 //"Falha na abertura da tabela de estruturas (ADV_TBL / ADV_COLS)."
	EndIf
	lRet    := .F.	
EndIf

If !lRet
    Alert(cMsgRet)
EndIf

If lRet .And. !(Select("HCF") > 0)
   ADVTBL->(dbSeek(cEmpresa + "HCF"))
   dbUseArea( .T., "LOCAL", AllTrim(ADVTBL->TBLNAME), "HCF", .T., .F. )
   dbSetIndex(AllTrim(ADVTBL->TBLNAME) + "1")
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitSync            ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function InitSync(oSayFile, oMeterFiles, nMeterFiles)

Local aEmp    	:= {}
Local aConn 	:= {}
Local aConnVPN	:= {}
Local lEmp    	:= .F.
Local cUltPed 	:= ""
Local cTableVend := "HA3" + cEmpresa + cSufixo
Local ctablePara := "HCF" + cEmpresa + cSufixo
Local cConn		:= ""
Local cUser		:= ""
Local cPsw 		:= ""
Local cConnVPN	:= ""
Local cUserVPN	:= ""
Local cPswVPN	:= ""
Local nIniStr	:= ""
Local nPos		:= 0
Local lSync		:= .T.
Local nResult	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validaccoes antes do sincronismo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("SFAPR002")
	lSync := ExecBlock("SFAPR002", .F., .F.)
	If !lSync
		Return Nil
	EndIf
EndIf	

// Guarda o número do Ultimo Pedido
If File(cTableVend)
	If Select("HA3") > 0
		dbSelectArea("HA3")
		DbSetorder(1)
		dbGoTop()
		cUltPed := HA3->HA3_PROPED
#IFNDEF __PALM__
		If HA3->(FieldPos("HA3_CON")) > 0
			cConn := AllTrim(HA3->HA3_CON)
		EndIf
		If HA3->(FieldPos("HA3_USR")) > 0
            cUser := AllTrim(HA3->HA3_USR)
		EndIf
		If HA3->(FieldPos("HA3_PSW")) > 0
            cPsw := AllTrim(HA3->HA3_PSW)
		EndIf
		If HA3->(FieldPos("HA3_CONVPN")) > 0
            cConnVPN := AllTrim(HA3->HA3_CONVPN)
		EndIf
		If HA3->(FieldPos("HA3_USRVPN")) > 0
			cUserVPN := AllTrim(HA3->HA3_USRVPN)
		EndIf						
		If HA3->(FieldPos("HA3_PSWVPN")) > 0
			cPswVPN := AllTrim(HA3->HA3_PSWVPN)
		EndIf						
#ENDIF	
	EndIf
EndIf
#IFDEF __POCKET__
If File("HCF")
	If Select("HCF") > 0
		dbSelectArea("HCF")
		DbSetorder(1)
		If dbSeek(RetFilial("HCF")+"MV_SFACON")
			If (nPos := At(",",AllTrim(HCF->HCF_VALOR))) != 0
				cConn := SubStr(AllTrim(HCF->HCF_VALOR),1,nPos-1)
				nIniStr := nPos + 1
			EndIf
			If (nPos := At(",",AllTrim(HCF->HCF_VALOR))) != 0
				cUser := SubStr(AllTrim(HCF->HCF_VALOR),nIniStr,nPos-1)
				nIniStr := nPos + 1
			EndIf
			If Len(AllTrim(HCF->HCF_VALOR)) >= nIniStr .And. nIniStr > 2
				cPsw := SubStr(AllTrim(HCF->HCF_VALOR),nIniStr,Len(AllTrim(HCF->HCF_VALOR)))
			EndIf
		EndIf
		If dbSeek(RetFilial("HCF")+"MV_SFAVPN")
			If (nPos := At(",",AllTrim(HCF->HCF_VALOR))) != 0
				cConnVPN := SubStr(AllTrim(HCF->HCF_VALOR),1,nPos-1)
				nIniStr := nPos + 1
			EndIf
			If (nPos := At(",",AllTrim(HCF->HCF_VALOR))) != 0
				cUserVPN := SubStr(AllTrim(HCF->HCF_VALOR),nIniStr,nPos-1)
				nIniStr := nPos + 1
			EndIf
			If Len(AllTrim(HCF->HCF_VALOR)) >= nIniStr .And. nIniStr > 2
				cPswVPN := SubStr(AllTrim(HCF->HCF_VALOR),nIniStr,Len(AllTrim(HCF->HCF_VALOR)))
			EndIf
		EndIf
	EndIf
EndIf
If !Empty(AllTrim(cConn+cUser+cPSW))
	aAdd(aConn,cConn)
	aAdd(aConn,cUser)
	aAdd(aConn,cPsw)
	aAdd(aConn,.F.)
	SetRasParams(aConn)
EndIf

If !Empty(AllTrim(cConnVPN+cUserVPN+cPswVPN))
	aAdd(aConnVPN,cConnVPN)
	aAdd(aConnVPN,cUserVPN)
	aAdd(aConnVPN,cPswVPN)
	aAdd(aConn,.T.)
	SetRasParams(aConnVPN)
EndIf

#ENDIF
dbCloseAll()

//nResult := DoSync()
DoSync()

// Reabre as tabelas
If oSayFile <> Nil
	lEmp := OpenEmp(@aEmp) //.Or. !VrfArquivos()
	If lEmp
		If OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
			HideControl(oSayFile)
			HideControl(oMeterFiles)	

			// Verifica se o numero do pedido recebido é menor
			If File(cTableVend)
				If Select("HA3") > 0
					dbSelectArea("HA3")
					DbSetorder(1)
					dbGoTop()
					If cUltPed > HA3->HA3_PROPED
						HA3->HA3_PROPED := cUltPed
						dbCommit()
					Endif
				Endif
			Endif
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
		EndIf
	EndIf   
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada apos sincronismo                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("SFAPR003")
	ExecBlock("SFAPR003", .F., .F.,{nResult,lEmp})
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VrfArquivos          ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existem os arquivos de dados necessários ao SFA ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VrfArquivos()

Local aTables := {"HA3","HA1","HRT","HD7","HU5","HCF","HC5","HC6","HD5","HPR",;
"HTC","HTP","HB1","HB2","HBM","HE4","HAT","HA4","HX5","HE1","HF4","HCN","HCO","HCP",;
"HCQ","HCR","HCS","HCT","HMT","HIN"}
Local i		 :=1
Local cTable :=""
Local lRet	 :=.T.
/*
For i:=1 to Len(aTables)
	cTable := aTables[i]+cEmpresa
	If !File(cTable)
		MsgStop(STR0011 + cTable + STR0012, STR0013) //"A tabela "###" não foi exportada. Rever os serviços de exportação."###"Abertura SFA"
		lRet:=.F.	
	Endif
Next
*/
// Abre Arquivo de Configuracoes (HCF)
If lRet
	If ADVTBL->(dbSeek(cEmpresa + "HCF"))
		lRet := dbUseArea( .T., "LOCAL", AllTrim(ADVTBL->TBLNAME), "HCF", .T., .F. )
		dbSetIndex(AllTrim(ADVTBL->TBLNAME) + "1")
	Else
		MsgAlert("Tabela de parametros (HCF) não encontrada.", "VrfArquivos") 
	EndIf
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DirtyTable           ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
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
ADD COLUMN oCol TO oBrwRecs ARRAY ELEMENT 2 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwRecs ARRAY ELEMENT 3 HEADER "" WIDTH 50

HideControl(oMeter)
LoadRecs(aTables, GridRow(oBrwTable), aRecs, oBrwRecs, oMeter, nMeter)

ACTIVATE DIALOG oDlg

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³LoadRecs             ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function LoadRecs(aTables, nTable, aRecs, oBrwRecs, oMeter, nMeter)

aSize(aRecs, 0)
nMeter := 0
SetMeter(oMeter, nMeter)
ShowControl(oMeter)

If aTables[nTable, 2] = "HC5"
	dbSelectArea("HC5")
	dbSetOrder(1)
	dbSeek(RetFilial("HC5"))
	//dbGoTop()
	While !HC5->(Eof()) .And. HC5->HC5_FILIAL = RetFilial("HC5")
		If AllTrim(HC5->HC5_STATUS) = "N"
			HA1->(dbSetOrder(1))
			HA1->(dbSeek(RetFilial("HC5") + HC5->HC5_CLI+HC5->HC5_LOJA))
			aAdd(aRecs, {.F., HC5->HC5_NUM, HA1->HA1_NOME, Recno()})
		EndIf
		nMeter += 100 / HC5->(RecCount())
		SetMeter(oMeter, nMeter)
		HC5->(dbSkip())
	EndDo
ElseIf aTables[nTable, 2] = "HA1"
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1"))
	//dbGoTop()
	While !HA1->(Eof())
		If AllTrim(HA1->HA1_STATUS) = "N"
			aAdd(aRecs, {.F., HA1->HA1_COD, HA1->HA1_LOJA, Recno()})
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

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MarkDirty            ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
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
			If dbSeek(RetFilial("HC6") + HC5->HC5_NUM)
				While !HC6->(Eof()) .And. HC5->HC5_NUM = HC6->HC6_NUM
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

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ChoiceEmp            ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ChoiceEmp(aEmp, nEmp, aSenhaObj)

Local lRet    := .T.
Local nPos    := 0
Local cMsgRet := ""

nPos     := At("/", aEmp[nEmp,1])
cEmpresa := SubStr(aEmp[nEmp,1],1,nPos-1)
cFilial  := SubStr(aEmp[nEmp,1],nPos+1,2)

HHEMP->(dbSeek(cEmpresa + cFilial))

cSufixo := AllTrim(HM0->HM0_SUFIXO)

If lRet                                  
	dbSelectArea("ADVTBL")
	dbSetOrder(1)
	If dbSeek(cEmpresa + "HA3")
		//lRet := dbUseArea( .T., "LOCAL", "HA3" + cEmpresa, "HA3", .T., .F. )
		dbUseArea( .T., "LOCAL", AllTrim(ADVTBL->TBLNAME), "HA3", .T., .F. )
		//dbSetIndex("HA3" + cEmpresa + "1")
		dbSelectArea("HA3")
		dbSetIndex(AllTrim(ADVTBL->TBLNAME) + "1")

		// Verifica Arquivos
		If !VrfArquivos()
			InitSync()
			//Return .F.
		EndIf

	Else
		Alert("Tabela vendedor")
	EndIf
	dbGotop()
	If !lRet 	
		cMsgRet := STR0008 + cEmpresa + cSufixo + ")." //"Falha na abertura da tabela de vendedor (HA3)"
		lRet    := .F.
	EndIf
EndIf
If lRet
	For ni := 1 To Len(aSenhaObj)
		ShowControl(aSenhaObj[ni,1])
	Next
	If Len(aSenhaObj) > 0
		SetText(aSenhaObj[2,1], HA3->HA3_NREDUZ)
		SetText(aSenhaObj[4,1], HA3->HA3_COD)
	EndIf
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ChangeEmp            ³                     ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ChangeEmp(oSayFile, oMeterFiles, nMeterFiles, oBtnEmp)

Local aCmpEmp := {}
Local aRet    := {}
Local aEmp    := {}
Local aIndEmp := {}
Local lEmp    := .F.

Aadd(aCmpEmp,{"Empresa",HM0->(FieldPos("HM0_COD")),40}) //"Empresa"
Aadd(aCmpEmp,{"Filial",HM0->(FieldPos("HM0_FILIAL")),40}) //"Filial"
Aadd(aCmpEmp,{"Nome",HM0->(FieldPos("HM0_NOME")),100}) //"Nome"
Aadd(aCmpEmp,{"Sufixo",HM0->(FieldPos("HM0_SUFIXO")),25}) //Sufixo
Aadd(aIndEmp,{"Empresa + Filial + Sufixo",1})

SFConsPadrao("HM0",,,aCmpEmp,aIndEmp, aRet)

If Len(aRet) > 0
	If aRet[1,1] + aRet[2,1] = cEmpresa + cFilial
		Return Nil
	EndIf
Else
	Return Nil
EndIf

dbCloseAll()

// Reabre as tabelas
If oSayFile <> Nil
	lEmp := OpenEmp(@aEmp) //.Or. !VrfArquivos()
	If lEmp
	
		cEmpresa := aRet[1,1]
		cFilial  := aRet[2,1]
		cSufixo := AllTrim(HM0->HM0_SUFIXO)

		If OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
			HideControl(oSayFile)
			HideControl(oMeterFiles)	
			SetText(oBtnEmp, STR0023 + "/" + STR0024 +  ": " + cEmpresa + "/" + cFilial)
			ClearStatus()
		EndIf
	EndIf   
EndIf

Return Nil
