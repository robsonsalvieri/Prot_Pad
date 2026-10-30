#INCLUDE "PLSMPROM.ch"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBROWSE.CH'

//--------------------------------------------------------------------------------
/*/{Protheus.doc} PLVldItem
Encapsula a chamada da função PlsWFProc para limpar os objetos criados
@author Everton.Mateus
@since 04/08/2017
@version P12
/*/
//---------------------------------------------------------------------------------
Function PlsWFProc(cCodProcess, cDescProcess, cSubject, cBody, cToWF, cCCWF, cBccWF, cHtmlFile, aCposEDataWF, xAttach, lPrcCpo,lEnv)

	Local cWFID := ""

	//Valores padrões
	Default cCodProcess	:= "000001"
	Default cDescProcess	:= "WF Informativo"
	Default cSubject		:= "WF Informativo"
	Default cBody			:= ""
	Default cToWF			:= ""
	Default cCCWF			:= ""
	Default cBccWF		:= ""
	Default cHtmlFile		:= ""//\workflow\testeWF.htm"
	Default aCposEDataWF	:= {}
	Default xAttach		:= ""
	Default lPrcCpo		:= .F.
	Default lEnv		:= .T.

	cWFID := SPlsWFProc(@cCodProcess, @cDescProcess, @cSubject, @cBody, @cToWF, @cCCWF, @cBccWF, @cHtmlFile, aCposEDataWF, @xAttach, @lPrcCpo,@lEnv)
	delClassIntF()

Return(cWFID)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} SPlsWFProc
Função para processamento de WorkFlow
@author Rogério Tabosa
@since 26/01/2012
@version P12
/*/
//---------------------------------------------------------------------------------
Static Function SPlsWFProc(cCodProcess, cDescProcess, cSubject, cBody, cToWF, cCCWF, cBccWF, cHtmlFile, aCposEDataWF, xAttach, lPrcCpo,lEnv)

	Local cMsgTrk			:= ""
	Local oProcess		:= nil		
	Local cTo				:= ""
	Local cCC				:= ""
	Local cWFID		   	:= ""
	Local nI				:= 0
	Local lRetArq := .F. 			

	Default cCodProcess	:= "000001"
	Default cDescProcess	:= "WF Informativo"
	Default cSubject		:= "WF Informativo"
	Default cBody			:= ""
	Default cToWF			:= ""
	Default cCCWF			:= ""
	Default cBccWF		:= ""
	Default cHtmlFile		:= ""//\workflow\testeWF.htm"
	Default aCposEDataWF	:= {}
	Default xAttach		:= ""
	Default lPrcCpo		:= .F.
	Default lEnv		:= .T.

	Begin Sequence

		oProcess	:= TWFProcess():New(cCodProcess, cDescProcess) 
		
		If !Empty(cHtmlFile)
		
			If FILE(cHtmlFile)
				lRetArq := .T.
			Else
				MsgInfo("O Arquivo informado no cadastro de sinalizadores nao existe!")	  
				lEnv := .F.
				Return
			EndIf	

		EndIf

		If !Empty(cHtmlFile)
			oProcess:NewTask("Preparando WorkFlow de Autorizacao" + cDescProcess, cHtmlFile)		
			Conout("(INICIO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
		else
			// Necessário instanciar o objeto oHTML quando o método NewTask não for executado para não ocorrer error log durante envio do workflow
			oProcess:oHTML := TWFHtml():New()
		EndIf
		// Arquivo Anexo
		If Valtype(xAttach) == "C" // Caracter com arquivo pra anexar ou array com mais de um anexo
			If !Empty(xAttach)
				oProcess:AttachFile(xAttach)
		EndIf
		ElseIf Valtype(xAttach) == "A"
			For nI := 1 To Len(xAttach)
				If !Empty(xAttach[nI])
					oProcess:AttachFile(xAttach[nI])
				EndIf
			Next nI 
		EndIf
		oProcess:cSubject	:= cSubject
		oProcess:cBody		:= cBody
		oProcess:UserSiga	:= __cUserId
		cWFID				:= oProcess:fProcessID + oProcess:fTaskId
			
		If Empty(cToWF) .AND. Empty(cCCWF) .AND. Empty(cBccWF) 
			cMsgTrk	:= "Endereço do destinatário não informado! [" + cCodProcess+"|"+cDescProcess + "]"
			ConOut(cMsgTrk)
			oProcess:Track( cCodProcess, cMsgTrk)
		Else
			If !Empty(cToWF)
				oProcess:cTo := cToWF
			EndIf
			If !Empty(cCCWF)
				oProcess:cCC := cCCWF
			EndIf
			If !Empty(cBccWF)
				oProcess:cBcc := cBccWF
			EndIf
		EndIf
		
		If Len(aCposEDataWF) > 0
			For nI := 1 To Len(aCposEDataWF)
				if valtype(oProcess:oHTML) <> "U"
					If oProcess:oHTML:ExistField(1, aCposEDataWF[nI,1])
						oProcess:oHTML:ValByName( aCposEDataWF[nI,1],If(lPrcCpo,&(aCposEDataWF[nI,2]),aCposEDataWF[nI,2]))
					EndIf
				endif
			Next nI
		EndIf
		oProcess:Start()
		              
	End Sequence

	FreeObj(oProcess)
	oProcess := Nil
Return(cWFID)
