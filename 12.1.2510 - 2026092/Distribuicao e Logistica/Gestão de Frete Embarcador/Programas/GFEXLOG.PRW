#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF CHR(13)+CHR(10) // FINAL DE LINHA

#DEFINE GFELOG_DISABLED "1"
#DEFINE GFELOG_INFO "2"
#DEFINE GFELOG_DEBUG "3"
#DEFINE GFELOG_CONSOLE "4"

#DEFINE GFEVP_TELA "1"
#DEFINE GFEVP_ARQUIVO "2"
#DEFINE GFEVP_AMBOS "3"


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog
Classe de controle de Log
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS GFELog
	DATA cFilename
	DATA cFullFile
	DATA cTitulo
	DATA cBody
	DATA cLogOption
	DATA lShowConsole

	// Declaração dos Métodos da Classe
	METHOD New(cFilename, cTitulo, cLogOption) CONSTRUCTOR
	METHOD EnableConsole()
	METHOD Add(cTexto, nIdent)
	METHOD AddDebug(cTexto, nIdent)
	METHOD ShowParameters(cPergunte)
	METHOD NewLine(nCont)
	METHOD Save()
	METHOD CheckLimit()
	METHOD EndLog()
	METHOD ChangeFilename(cNewFile)
ENDCLASS


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:New
Constructor do log
Generico

Parâmetros:
	cFilename: Nome do Arquivo (Sem espaço, diretório ou extensão)
	cTitulo  : Título
	cLogOption: Nível de log: 1=Desabilitado, 2=Info, 3=Debug
	           Server para generalizar o controle da geração dentro da classe ao invés do programa chamador

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD New(cFilename, cTitulo, cLogOption, lChangeFN, lPrintCab) Class GFELog
	Default cLogOption := GFELOG_DISABLED
	Default lChangeFN  := .T.
	Default lPrintCab  := .T.

	Self:cTitulo 	:= cTitulo
	Self:cFilename 	:= cFilename
	Self:cFullFile 	:= cFilename
	Self:cLogOption	:= cLogOption
	Self:cBody		:= ""
	Self:lShowConsole := .F.

	If empty(cLogOption)
		Self:cLogOption := "1"
	Endif 
	
	If Self:cLogOption == GFELOG_CONSOLE
		GFEConout("INFO", Self:cTitulo + " : Início do Log " + Replicate("-", 20))
	EndIf

	If Self:cLogOption $ GFELOG_INFO + GFELOG_DEBUG

		If lChangeFN
			Self:ChangeFilename(cFilename)
		EndIf

		If lPrintCab
			Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
			Self:cBody := Self:cBody + "Gestão Frete Embarcador - " + Self:cTitulo + CRLF
			Self:cBody := Self:cBody + "Data da Geração: " + Dtoc(Date()) + " - " + Time() + CRLF
			Self:cBody := Self:cBody + "Usuário: " + cUserName + CRLF
			Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
			Self:NewLine(2)
		EndIf

	EndIf

Return Self



//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:EnableConsole
Habilita saída via console.log
Generico

@author Israel A. Possoli
@since 02/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EnableConsole() Class GFELog
	Self:lShowConsole := .T.
Return Nil




//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:EndLog
Constructor do log
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EndLog() Class GFELog
	If Self:cLogOption == GFELOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == GFELOG_CONSOLE
		GFEConout("INFO", Self:cTitulo + " : Fim do processamento " + Replicate("-", 20))
		Return
	EndIf

	Self:NewLine(2)
	Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
	Self:cBody := Self:cBody + "Término da Geração: " + Dtoc(Date()) + " - " + Time() + CRLF
	Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
	Self:Save()
Return Nil




//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:Add
Constructor do log
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Add(cTexto, nIdent) Class GFELog
	Default nIdent := 0
	Default cTexto := ""

	If Self:cLogOption == GFELOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == GFELOG_CONSOLE .OR. Self:lShowConsole
		GFEConout("INFO", "[" + PADR(Time(), 8) + "]" + Self:cTitulo + " : " + cTexto)
		
		If Self:cLogOption == GFELOG_CONSOLE
			Return Nil
		EndIf
	EndIf

	If Empty(cTexto)
		Self:NewLine()
		Return Nil
	EndIf
	
	If Self:cLogOption == GFELOG_DEBUG
		Self:cBody := Self:cBody + "[" + PADR(Time(), 8) + "]" + Space(2)
	EndIf

	If nIdent > 0
		Self:cBody := Self:cBody + Replicate(" ", nIdent * 2)
	EndIf
	
	Self:CheckLimit()
	
	Self:cBody := Self:cBody + cTexto + CRLF
	
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:AddDebug
Adiciona um texto de log para tipo Debug
Generico

@author Israel A. Possoli
@since 27/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddDebug(cTexto, nIdent) Class GFELog
	Default nIdent := 0
	
	If Self:cLogOption != GFELOG_DEBUG
		Return
	EndIf
	
	Self:cBody := Self:cBody + "[" + PADR(Time(), 8) + "]" + Space(2) + Replicate(" ", nIdent * 2) + cTexto + CRLF
	
	If Self:lShowConsole
		GFEConout("INFO", "[" + PADR(Time(), 8) + "] GFELOG : " + cTexto)
	EndIf

	Self:CheckLimit()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:ShowParameters
Adiciona uma linha em branco
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD ShowParameters(cPergunte) Class GFELog
	/*Local nTextSize := 0
	Local nI	:= 0
	Local nOpc
	Local cValue
	Local aItens := {}
	Local aValue := {}

	Self:Add("Parâmetros ------------------------")
	
	cPergunte := PadR(AllTrim(cPergunte), 10)

	dbSelectArea("SX1")
	dbSetOrder(1)
	dbSeek(cPergunte)
	While !SX1->( Eof() ) .AND. SX1->X1_GRUPO = cPergunte	
		nI++
		If Len(AllTrim(SX1->X1_PERGUNT)) > nTextSize
			nTextSize := Len(AllTrim(SX1->X1_PERGUNT))
		EndIf

		aADD(aItens, AllTrim(SX1->X1_PERGUNT))
		cValue := &("MV_PAR" + If(nI <= 9, "0", "") + AllTrim(cValToChar(nI)))
		
		If SX1->X1_GSC == "C"
			nOpc := AllTrim(cValToChar(cValue))
			
			If nOpc == "1"
				aADD(aValue, X1Def01())
			ElseIf nOpc == "2"
				aADD(aValue, X1Def02())
			ElseIf nOpc == "3"
				aADD(aValue, X1Def03())
			ElseIf nOpc == "4"
				aADD(aValue, X1Def04())
			ElseIf nOpc == "5"
				aADD(aValue, X1Def05())
			Else
				aADD(aValue, X1Def01())
			EndIf
		Else
			aADD(aValue, AllTrim(cValue))
		EndIf

		SX1->( dbSkip() )
	EndDo

	For nI := 1 To Len(aItens)
		Self:Add(aItens[nI] + Replicate(".", nTextSize - Len(aItens[nI])) + ": " + aValue[nI])
		// cValue := &("MV_PAR" + If(nI <= 9, "0", "") + AllTrim(cValToChar(nI)))
		// Self:Add(aItens[nI] + Replicate(".", nTextSize - Len(aItens[nI])) + ": " + cValToChar(cValue))
	Next

	Self:NewLine()*/

Return Nil




//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:NewLine
Adiciona uma linha em branco
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD NewLine(nCont) Class GFELog
	Default nCont := 1

	If Self:cLogOption == GFELOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == GFELOG_CONSOLE
		GFEConout("INFO", Self:cTitulo)
		Return
	EndIf

	If Self:cLogOption == GFELOG_DEBUG
		Self:cBody := Self:cBody + Replicate("[" + PADR(Time(), 8) + "]" + CRLF, nCont)
	Else
		Self:cBody := Self:cBody + Replicate(CRLF, nCont)
	EndIf
	

	Self:CheckLimit()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:CheckLimit
Checa se a string chegou no tamanho limite, salva o log se for necessário
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD CheckLimit()  Class GFELog
	If Self:cLogOption == GFELOG_DISABLED
		Return
	EndIf

	// 400 KB
	If Len(Self:cBody) > 409600
		Self:Save()
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:ChangeFilename
Altera o nome do arquivo
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD ChangeFilename(cNewFile)  Class GFELog
	Local cMV_DRTLOG := SuperGetMv("MV_DRTLOG",,"")
	Local cSep := "/"
	
	Self:cFilename := cNewFile

	If Self:cLogOption != GFELOG_INFO .AND. Self:cLogOption != GFELOG_DEBUG
		Return
	EndIf

	If Empty(cMV_DRTLOG)
		Self:cFullFile := Self:cFilename + "_" + GFENOW() + ".log"
	Else
		// Se for diretório fixo (C:\temp\ por exemplo) e a barra for normal, corrige o separador de diretórios
		If SubStr(cMV_DRTLOG, 3, 1) == "\"
			cSep := "\"
		EndIf
		
		// Se o final de MV_DRTLOG possuir barra, limpa o separador
		If SubStr(cMV_DRTLOG, len(cMV_DRTLOG), 1) == "/" .OR. SubStr(cMV_DRTLOG, len(cMV_DRTLOG), 1) == "\"
			cSep := ""
		EndIf
		
		Self:cFullFile := cMV_DRTLOG + cSep + Self:cFilename + "_" + GFENOW() + ".log"
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFELog:Save
Salva e limpa a variável do corpo do log
Generico

@author Israel A. Possoli
@since 25/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Save()  Class GFELog
	Local nHandle 	:= 0
	Local cLock		:= ""

	If Self:cLogOption != GFELOG_INFO .AND. Self:cLogOption != GFELOG_DEBUG
		Return
	EndIf
	
	cLock := "GFEXLOG" + Self:cFullFile
		
	If LockByName(cLock, .F., .F.)

		If !File(Self:cFullFile)  // Arquivo não existe
			// Cria o arquivo de log
			nHandle := FCreate(Self:cFullFile, FC_NORMAL)
			FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
		Else	// Arquivo existe
			nHandle := FOpen(Self:cFullFile, FO_READWRITE)
			FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
		EndIf
	
		FWrite(nHandle, Self:cBody, Len(Self:cBody)) // Grava o conteudo da variavel no arquivo de log
	
		FClose(nHandle) // Fecha o arquivo de log
	
		Self:cBody := ""
		
		UnLockByName(cLock, .F., .F.)
		ClearGlbValue('GFEXLOG*', 10)				
	EndIf

Return Nil


/* =============================================================================================================== */


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc
Classe para visualizar o resultado do processamento de uma rotina
Generico

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS GFEViewProc
	DATA cBody
	DATA cBodyDetail
	DATA nLinhas
	DATA lEnabledLog
	DATA GFELog
	DATA cIcon
	DATA lLimite
	DATA lLimiteDetail

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD EnableLog(cFileName, cTitulo)
	METHOD Add(cTexto, nIdent)
	METHOD AddDetail(cTexto, nIdent)
	METHOD AddErro(cTexto, nIdent)
	METHOD AddOnlyLog(cTexto, nIdent)
	METHOD Show(cTitulo, cSubTitulo, cTituloDetail, cMsgOnDetail)
	METHOD EmptyMsg()
	METHOD SetWarningIcon()
	METHOD StrContain(cStr,lDetail)
ENDCLASS


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:New
Constructor da classe de visualização do processamento
Generico

Parâmetros:
	cFilename: Nome do Arquivo (Sem espaço, diretório ou extensão)
	cTitulo  : Título
	cLogOption: Nível de log: 1=Desabilitado, 2=Info, 3=Debug
	           Server para generalizar o controle da geração dentro da classe ao invés do programa chamador

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD New() Class GFEViewProc
	Self:cBody 		 := ""
	Self:cBodyDetail := ""
	Self:nLinhas     := 0
	Self:lEnabledLog := .F.
	Self:cIcon		 := "OK"
	Self:lLimite 	 := .F.			// Flag que identifica se atingiu o limite máximo de caracteres, usado para evitar fazer o cálculo de bytes a toda chamado em Add
	Self:lLimiteDetail := .F.		// Flag que identifica se atingiu o limite máximo de caracteres, usado para evitar fazer o cálculo de bytes a toda chamado em AddDetail
Return Self


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:Add
Habilita a geração de log automática com o resultado do processamento
Generico

@author Israel A. Possoli
@since 08/12/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EnableLog(cFileName, cTitulo) Class GFEViewProc
	If Self:lEnabledLog
		Return Nil
	EndIf

	Self:lEnabledLog := .T.
	Self:GFELog := GFELog():New(cFileName, "Resultado de processamento - " + cTitulo, GFELOG_INFO)

Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:Add
Adiciona mensagens
Generico

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Add(cTexto, nIdent) Class GFEViewProc
	Default nIdent := 0
	Default cTexto := "" 
	
	If Self:lLimite
		Return Nil
	EndIf
	
	If Empty(cTexto)
		Self:cBody := Self:cBody + CRLF

		If Self:lEnabledLog
			Self:GFELog:NewLine()
		EndIf
		Return Nil
	EndIf
	
	// Verifica se a concatenação de cBodyDetail e cTexto, ultrapassa de 0.99 MB (margem de 10 KB)
	// 1 MB = 1048576 bytes
	// 0.99 MB = 1 MB - 10 KB = 1038336 bytes (10.000 caracteres)
	If Len(Self:cBody + cTexto) > 1038336
		Self:cBody := Self:cBody + "..." + CRLF
		Self:lLimite := .T.
		Return Nil
	EndIf	

	If nIdent > 0
		Self:cBody := Self:cBody + Replicate(" ", nIdent * 2)
	EndIf

	Self:cBody := Self:cBody + cTexto + CRLF

	If Self:lEnabledLog
		Self:GFELog:Add(cTexto, nIdent)
	EndIf

	Self:nLinhas++
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:AddOnlyLog
Adiciona mensagens
Generico

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddOnlyLog(cTexto, nIdent) Class GFEViewProc
	Default nIdent := 0
	Default cTexto := ""

	If Self:lEnabledLog
		Self:GFELog:Add(cTexto, nIdent)
	EndIf
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:Add
Adiciona mensagens de detalhes
Generico

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddDetail(cTexto, nIdent) Class GFEViewProc
	Default nIdent := 0
	Default cTexto := ""
	
	If Self:lLimiteDetail
		Return Nil
	EndIf
	
	// Verifica se a concatenação de cBodyDetail e cTexto, ultrapassa de 0.99 MB (margem de 10 KB)
	// 1 MB = 1048576 bytes
	// 0.99 MB = 1 MB - 10 KB = 1038336 bytes (10.000 caracteres)
	If Len(Self:cBodyDetail + cTexto) > 1038336
		Self:cBodyDetail := Self:cBodyDetail + "..." + CRLF
		Self:lLimiteDetail := .T.
		Return Nil
	EndIf	

	If Empty(cTexto)
		Self:cBodyDetail := Self:cBodyDetail + CRLF
		Return Nil
	EndIf

	If nIdent > 0
		Self:cBodyDetail := Self:cBodyDetail + Replicate(" ", nIdent * 2)
	EndIf

	Self:cBodyDetail := Self:cBodyDetail + cTexto + CRLF
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:AddErro
Adiciona mensagens de detalhes
Generico

@author Israel A. Possoli
@since 02/07/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddErro(cTexto, nIdent) Class GFEViewProc
	Self:AddDetail(cTexto, nIdent)
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:Show
Mostra a tela com o resultado do processamento
Generico

@param cMsgOnDetail Mostra uma mensagem no final do resultado caso exista alguma mensagem de detalhamento/erro

@author Israel A. Possoli
@since 30/11/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Show(cTitulo, cSubTitulo, cTituloDetail, cMsgOnDetail) Class GFEViewProc
	Local nI
	Default cTitulo    		:= "Resultado"
	Default cSubTitulo 		:= "Resumo"
	Default cTituloDetail 	:= "Erros"
	Default cMsgOnDetail 	:= "Ocorreram erros durante o processamento. Clique no botão '" + cTituloDetail + "' para mais detalhes"

	If !Empty(cMsgOnDetail) .AND. !Empty(Self:cBodyDetail)
		Self:cBody := Self:cBody + CRLF + cMsgOnDetail
	EndIf

	If Self:lEnabledLog
		If !Empty(Self:cBodyDetail)
			Self:GFELog:Save()
			Self:GFELog:Add()
			Self:GFELog:Add(Replicate("-", 120))
			Self:GFELog:Add(cTituloDetail)
			Self:GFELog:Add(Replicate("-", 120))
			Self:GFELog:Add()
			Self:GFELog:Add(Self:cBodyDetail)
		EndIf

		Self:GFELog:EndLog()
	EndIf

	If !isBlind()
		DEFINE MSDIALOG oDlg TITLE "Frete Embarcador - " + cTitulo From 0,0 To 18,70 /* OF oMainWnd */
			oPanelSummary := tPanel():Create(oDlg,01,01,,,,,,,0,0)
			oPanelSummary:Align := CONTROL_ALIGN_ALLCLIENT

		@ 4, 020 SAY cSubTitulo + " :" SIZE 130,7 PIXEL OF oPanelSummary

	    oTMultiget1 := TMultiget():New(15,07,{|u|If(Pcount()>0,Self:cBody:=u,Self:cBody)},;
	                           oPanelSummary,266,100,,,,,,.T.,,,,,,.T.)

		oTBitmap 		:= TBitmap():Create(oPanelSummary,01,06,32,32,,If(Empty(Self:cBodyDetail), Self:cIcon, "UPDERROR"),.T., ,,.F.,.F.,,,.F.,,.T.,,.F.)
		oButtonOK   	:= tButton():New(119,7,'OK',oPanelSummary,{|| oDlg:End()},40,12,,,,.T.)

		// Detalhes
		If !Empty(Self:cBodyDetail)
			oButtonDetail	:= tButton():New(119,49, cTituloDetail + ' >>',oPanelSummary,{|| oPanelSummary:Hide(), oPanelDetail:Show()},40,12,,,,.T.)

			oPanelDetail := tPanel():Create(oDlg,01,01,,,,,,,0,0)
			oPanelDetail:Align := CONTROL_ALIGN_ALLCLIENT
			oPanelDetail:Hide()

			@ 4, 020 SAY cTituloDetail + " :" SIZE 130,7 PIXEL OF oPanelDetail

	    	oTMultiDetail := TMultiget():New(15,07,{|u|If(Pcount()>0,Self:cBodyDetail:=u,Self:cBodyDetail)},;
	                           oPanelDetail,266,100,,,,,,.T.,,,,,,.T.)

			oButtonOK   	:= tButton():New(119,7,'OK',oPanelDetail,{|| oDlg:End()},40,12,,,,.T.)
			oButtonSummary	:= tButton():New(119,49,'<< Voltar',oPanelDetail,{|| oPanelDetail:Hide(), oPanelSummary:Show()},40,12,,,,.T.)
			oTBitmap 		:= TBitmap():Create(oPanelDetail,01,06,32,32,,"UPDERROR", .T., ,,.F.,.F.,,,.F.,,.T.,,.F.)

		EndIf

		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:VerifyMsg
Verifica se a variavel que armazena a mensagem está vazia
Generico

@author Lidiomar Fernando dos S. Machado
@since 17/04/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EmptyMsg() Class GFEViewProc

Return Empty(Self:cBody)


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:VerifyMsg
Verifica se a mensagem que está sendo incluída já existe em cBody.
Parâmetros:
	cStr: String a ser verificada
	lDetail: Se é mensagem detalhe ou não.
Generico

@author Lidiomar Fernando dos S. Machado
@since 17/04/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD StrContain(cStr,lDetail) Class GFEViewProc
	Local lRet
	Local cStrBody
	Default lDetail := .T.
	
	If lDetail 
		cStrBody := Self:cBodyDetail
	Else 
		cStrBody := Self:cBody
	EndIf
	
	lRet := cStr $ cStrBody  
	
Return lRet


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEViewProc:SetWarningIcon
Define o ícone padão como Warning
Generico

@author Israel A. Possoli
@since 02/07/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD SetWarningIcon() Class GFEViewProc
	Self:cIcon := "UPDWARNING"
Return Nil
