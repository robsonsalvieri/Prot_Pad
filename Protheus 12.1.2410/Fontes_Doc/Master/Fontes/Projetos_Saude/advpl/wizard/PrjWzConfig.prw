#include 'protheus.ch'

Static _barra := iif(IsSrvUnix(),"/","\")

STATIC lisBlind := isBlind()

Function PrjWzConfig(cProduto,cArquivo,aProcesso)
	Local oPanel 		:= nil
	Local aPerg 		:= {}
	Local oStepWiz		:= nil
	Private oWzCfg 		:= nil
	Private oDlg 		:= nil
	Default aProcesso	:= {"SIB"}
	Default cProduto	:= "SIGACEN"
	Default cArquivo	:= ""
	oWzCfg 		:= PrjWzConfig():New()
	If oWzCfg:getFiles(cProduto,cArquivo) .AND. oWzCfg:loadJson()
		if oWzCfg:oneProcess()
			oWzCfg:useProcess()
		Else
			aAdd(aPerg,{2,"Processo",0,oWzCfg:aProcess,100,"",.T.})
			if  lisBlind .Or. paramBox( aPerg,"Wizard de configuração",@aProcesso,/*bOK*/,/*aButtons*/,/*lCentered*/.T.,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.F.,/*lUserSave*/.F. )
				if !empty(aProcesso[1])
					oWzCfg:useProcess(aProcesso)
				EndIf
			Else
				Return
			EndIf
		EndIf
		If !empty(aProcesso[1]) .And. oWzCfg:checkFunc()
			If Len(oWzCfg:getProcess()) > 0 .And. !empty(aProcesso[1])
				If !lisBlind
					DEFINE DIALOG oDlg TITLE 'Wizard Configurador' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
					oDlg:nWidth := 1024
					oDlg:nHeight := 600
					oPanel:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
					oPanel:Align := CONTROL_ALIGN_ALLCLIENT
				EndIf
				oStepWiz:= FWWizardControl():New(oPanel)
				oStepWiz:ActiveUISteps()
				If !Empty(oWzCfg:defPages(oStepWiz)) .And. !lisBlind
					oStepWiz:Activate()
					ACTIVATE DIALOG oDlg CENTER
				EndIf
				If oWzCfg:lFimOk .OR. lisBlind
					oWzCfg:finishWzd()
					MsgInfo("Wizard executado com sucesso!")
				EndIf
			EndIf
		EndIf
	ElseIf !Empty(oWzCfg:aFileName)
		oWzCfg:errorJson()
	EndIf
	oWzCfg:destroy()
	FreeObj(oWzCfg)
	oWzCfg := nil
Return oStepWiz

Function PrjExtFunc(cRet,aFuncObr)
	Local cFuncs := ""
	Local nFunc := 0
	Local nLen := 0
	Default cRet := ""
	Default aFuncObr := {}

	nLen := Len(aFuncObr)
	For nFunc := 1 to nLen
		If !FindFunction(aFuncObr[nFunc])
			cFuncs += IIf(!Empty(cFuncs), ",","") + aFuncObr[nFunc]
		EndIf
	Next nFunc
	If !Empty(cFuncs)
		cRet += "A(s) função(ões) " + cFuncs + " não existe(m)"
	EndIf
Return Empty(cRet)

Function PrjExtCmp(cRet,aCmpObr)
	Local cAlias := ""
	Local cCmps := ""
	Local nCmp := 0
	Local nLen := 0
	Default cRet := ""
	Default aCmpObr := {}

	nLen := Len(aCmpObr)
	For nCmp := 1 to nLen
		cAlias := SubStr(aCmpObr[nCmp],1,3)
		If !FWAliasInDic(cAlias, .F.) .OR. &(cAlias+"->(FieldPos('"+aCmpObr[nCmp]+"'))") == 0
			cCmps += IIf(!Empty(cCmps), ",","") + aCmpObr[nCmp]
		EndIf
	Next nCmp
	If !Empty(cCmps)
		cRet += IIf(!Empty(cRet),CRLF,"") + "O(s) campo(s) " + cCmps + " não existe(m)"
	EndIf
Return Empty(cRet)

Class PrjWzConfig
	Data aPages
	Data oJson
	Data cVersion
	Data cFolder
	Data aFileName
	Data cUrl
	Data cRequest
	Data aProcess
	Data aSchedList
	Data aParamList
	Data aArquiList
	Data aMileList
	Data aCsvList
	Data aFuncPrin
	Data aCampoPrin
	Data aFinishmsg
	Data nFile
	Data nLenFiles
	Data nUsrProc
	Data nProcess
	Data lFimOk

	Method new() Constructor
	Method destroy()
	Method getFiles(cProduto,cArquivo)
	Method loadJson()
	Method loadProcess()
	Method oneProcess()
	Method useProcess()
	Method getJson(lCanSave)
	Method latestVersion(cJsonLocal)
	Method checkJson()
	Method checkFunc()
	Method errorJson()
	Method defPages(oStepWiz)
	Method getPosPage()
	Method getPages()
	Method getProcess()
	Method finishWzd()
EndClass

Method new() Class PrjWzConfig
	self:aPages 	:= {}
	self:aProcess 	:= {}
	self:aSchedList	:= {}
	self:aParamList	:= {}
	self:aFileName	:= {}
	self:aArquiList	:= {}
	self:aMileList	:= {}
	self:aCsvList	:= {}
	self:aFuncPrin	:= {}
	self:aCampoPrin	:= {}
	self:aFinishmsg	:=  {}
	self:cVersion	:= ""
	self:cUrl 		:= "https://cobprostorage.blob.core.windows.net"
	self:nFile	 	:= 1
	self:nLenFiles 	:= 1
	self:nUsrProc 	:= 1
	self:nProcess 	:= 1
	self:oJson 		:= JsonObject():New()
	self:lFimOk 	:= .F.
Return self

Method getFiles(cProduto,cArquivo) Class PrjWzConfig
	Local oJson 	:= JsonObject():New()
	Local cJsonList	:= ""
	Local oWzFiles 	:= nil
	Local lRet		:= .T.
	Default cProduto:= "SIGACEN"
	self:aFileName	:= {}
	self:cFolder	:= _barra + cProduto + _barra
	self:cRequest 	:= "/files/CONFIGURACAO/" + strtran(self:cFolder,_barra,"") + ".json"
	oWzFiles := PrjWzFiles():New(self:cFolder, strtran(self:cFolder,_barra,"") + ".json")
	oWzFiles:getRest(self:cURL, self:cRequest)
	cJsonList := oWzFiles:getResult()
	If !Empty(cJsonList)
		oJson:FromJson(cJsonList)
		self:aFileName := oJson:GetJSonObject('arquivos')
	Else
		self:aFileName := oWzFiles:getFileNames()
		If Empty(self:aFileName)
			MsgAlert(oWzFiles:getErro())
			lRet := .F.
		EndIf
	EndIf
	if !Empty(cArquivo)
		self:aFileName	:= Array( 1, cArquivo )
		lRet := .T.
	EndIf

	FreeObj(oWzFiles)
	oWzFiles := nil
	FreeObj(oJson)
	oJson := nil
Return lRet

Method destroy() Class PrjWzConfig
	Local nPage := 0
	Local nLenPages := len(self:aPages)
	If nLenPages > 0
		For nPage := 1 to nLenPages
			FreeObj(self:aPages[nPage])
			self:aPages[nPage] := nil
		Next nPage
	EndIf
	If self:oJson <> nil
		//self:oJson:destroy()
		FreeObj(self:oJson)
		self:oJson := nil
	EndIf
Return

Method getJson (lCanSave) Class PrjWzConfig
	Local cJson 	:= ""
	Local oWzFiles 	:= nil
	Default lCanSave := .T.
	self:cRequest 	:= "/files/CONFIGURACAO/" + self:aFileName[self:nFile]
	oWzFiles := PrjWzFiles():New(self:cFolder, self:aFileName[self:nFile])
	oWzFiles:getRest(self:cURL, self:cRequest)
	cJson := oWzFiles:getResult()
	If lCanSave
		If (!(oWzFiles:saveFile(cJson)) .Or. Empty(cJson)) .And. !Empty(oWzFiles:getErro())
			MsgAlert(oWzFiles:getErro())
		EndIf
	EndIf
	FreeObj(oWzFiles)
	oWzFiles := nil
Return cJson

Method loadJson() Class PrjWzConfig
	Local cJson		:= ""
	Local oWzFiles	:= nil
	Local cErr		:= ""
	Local lOk 		:= .F.
	Local nFile		:= self:nFile
	self:nLenFiles 	:= Len(self:aFileName)
	For nFile := 1 To self:nLenFiles
		oWzFiles := PrjWzFiles():New(self:cFolder, self:aFileName[nFile])
		cJson := oWzFiles:readFile()
		FreeObj(oWzFiles)
		oWzFiles := nil
		If Empty(cJson)
			If lisBlind .OR. MsgNoYes("O arquivo " + self:aFileName[nFile] + " não foi encontrado. Deseja efetuar o download agora?","Wizard Saude")
				cJson := self:getJson()
			EndIf
		Else
			If !self:latestVersion(cJson)
				If lisBlind .OR. MsgNoYes("Existe uma nova versão do arquivo " + self:aFileName[nFile] + ". Deseja efetuar o download agora?","Wizard Saude")
					cJson := self:getJson()
				EndIf
			EndIf
		EndIf
		if Len(cJson) > 0
			cErr := self:oJson:FromJson(cJson)
			if self:checkJson() .And. Empty(cErr)
				self:loadProcess()
				lOk := .T.
			EndIf
		EndIf
		cJson := ""
	Next nFile
Return lOk

Method latestVersion(cJsonLocal) Class PrjWzConfig
	Local oJsonLocal 	:= JsonObject():New()
	Local oJsonCloud 	:= JsonObject():New()
	Local cJsonCloud 	:= ""
	Local cVerLocal		:= ""
	Local cVerCloud		:= ""
	Default lRet		:= .T.
	Default cJsonLocal	:= ""
	oJsonLocal:FromJson(cJsonLocal)
	cJsonCloud := self:getJson(.F.)
	If !Empty(cJsonCloud)
		oJsonCloud:FromJson(cJsonCloud)
		cVerLocal	:= iif(!empty(oJsonLocal["version"]), oJsonLocal["version"], iif(!empty(oJsonLocal["versao"]),oJsonLocal["versao"],""))
		cVerCloud	:= iif(!empty(oJsonCloud["version"]), oJsonCloud["version"], iif(!empty(oJsonCloud["versao"]),oJsonCloud["versao"],""))
		If cVerLocal < cVerCloud
			lRet := .F.
		EndIf
	Else
		MsgInfo("Não foi possível buscar atualizações","Wizard Saude")
	EndIf
	FreeObj(oJsonLocal)
	oJsonLocal := nil
	FreeObj(oJsonCloud)
	oJsonCloud := nil
Return lRet

Method checkJson() Class PrjWzConfig
	Local aErr 	:= {}
	Local nProcess	:= 0
	Local lOk 	:= .F.
	if !empty(self:oJson["processos"]) .And. (!empty(self:oJson["version"]) .Or. !empty(self:oJson["versao"]))
		aadd(aErr, !empty(self:oJson["processos"]))
		aadd(aErr, iif(!empty(self:oJson["version"]), .T., iif(!empty(self:oJson["versao"]),.T.,.F.)) )
		For nProcess := 1 To Len(self:oJson["processos"])
			aadd(aErr, !empty(self:oJson["processos"][nProcess]["processo"]))
		Next nProcess
		lOk := empty(AScan(aErr, .F.))
	EndIf
Return lOk

Method errorJson() Class PrjWzConfig
	Local nFile 	:= self:nFile
	For nFile := 1 To self:nLenFiles
		If File(PrjWzLinux(self:cFolder) + self:aFileName[nFile])
			MsgAlert("Existe alguma inconsistência no arquivo " + self:aFileName[nFile] + ". Verifique","Wizard Saude")
		EndIf
	Next nFile
Return

Method loadProcess() Class PrjWzConfig
	Local nProcess		:= 0
	Local nLenProces	:= Len(self:oJson["processos"])
	if self:oJson <> nil
		For nProcess := 1 To nLenProces
			if !Empty(self:oJson["processos"][nProcess]["ativo"])
				if !Empty(self:oJson["processos"][nProcess]["processo"])
					aAdd(self:aProcess, self:oJson["processos"][nProcess]["processo"])
				Else
					aAdd(self:aProcess,{.F.})
				EndIf
				if !Empty( self:oJson["processos"][nProcess]:GetJSonObject('listaschedules'))
					aAdd(self:aSchedList, self:oJson["processos"][nProcess]:GetJSonObject('listaschedules'))
				Else
					aAdd(self:aSchedList,{.F.})
				EndIf
				if !Empty( self:oJson["processos"][nProcess]:GetJSonObject('listaparametros'))
					aAdd(self:aParamList, self:oJson["processos"][nProcess]:GetJSonObject('listaparametros'))
				Else
					aAdd(self:aParamList,{.F.})
				EndIf
				if !Empty( self:oJson["processos"][nProcess]:GetJSonObject('listaarquivos'))
					aAdd(self:aArquiList, self:oJson["processos"][nProcess]:GetJSonObject('listaarquivos'))
				Else
					aAdd(self:aArquiList,{.F.})
				EndIf
				if !Empty( self:oJson["processos"][nProcess]:GetJSonObject('listamile'))
					aAdd(self:aMileList, self:oJson["processos"][nProcess]:GetJSonObject('listamile'))
				Else
					aAdd(self:aMileList,{.F.})
				EndIf
				if !Empty( self:oJson["processos"][nProcess]:GetJSonObject('listacsv'))
					aAdd(self:aCsvList, self:oJson["processos"][nProcess]:GetJSonObject('listacsv'))
				Else
					aAdd(self:aCsvList,{.F.})
				EndIf
				if !Empty(self:oJson["processos"][nProcess]["funcaoprincipal"])
					aAdd(self:aFuncPrin, self:oJson["processos"][nProcess]:GetJSonObject("funcaoprincipal"))
				Else
					aAdd(self:aFuncPrin,{.F.})
				EndIf
				if !Empty(self:oJson["processos"][nProcess]["campoprincipal"])
					aAdd(self:aCampoPrin, self:oJson["processos"][nProcess]:GetJSonObject("campoprincipal"))
				Else
					aAdd(self:aCampoPrin,{.F.})
				EndIf
				if !Empty(self:oJson["processos"][nProcess]["finishmsg"])
					aAdd(self:aFinishmsg, self:oJson["processos"][nProcess]:GetJSonObject("finishmsg"))
				Else
					aAdd(self:aFinishmsg,{.F.})
				EndIf
			EndIf
		Next
	EndIf
	self:nProcess := Len(self:aProcess)
Return self:aProcess

Method oneProcess() Class PrjWzConfig
Return self:nProcess == 1

Method useProcess(aProcess) Class PrjWzConfig
	Default aProcess 	:= self:aProcess

	self:nUsrProc 	:= Max(1,AScan( self:aProcess, aProcess[1]))
	self:aProcess 	:= aProcess
	If self:nUsrProc > 0
		if !Empty(self:aSchedList)
			self:aSchedList := self:aSchedList[self:nUsrProc]
		EndIf
		if !Empty(self:aParamList)
			self:aParamList := self:aParamList[self:nUsrProc]
		EndIf
		if !Empty(self:aArquiList)
			self:aArquiList := self:aArquiList[self:nUsrProc]
		EndIf
		if !Empty(self:aMileList)
			self:aMileList := self:aMileList[self:nUsrProc]
		EndIf
		if !Empty(self:aCsvList)
			self:aCsvList := self:aCsvList[self:nUsrProc]
		EndIf
		if !Empty(self:aFuncPrin)
			self:aFuncPrin 	:= self:aFuncPrin[self:nUsrProc]
		EndIf
		if !Empty(self:aCampoPrin)
			self:aCampoPrin	:= self:aCampoPrin[self:nUsrProc]
		EndIf
		if !Empty(self:aFinishmsg)
			self:aFinishmsg	:= self:aFinishmsg[self:nUsrProc]
		EndIf
	EndIf
Return

Method checkFunc() Class PrjWzConfig
	Local cErro := ""
	Default lRet := .T.
	If !Empty(self:aFuncPrin[1])
		lRet := PrjExtFunc(@cErro,self:aFuncPrin)
		If !lRet
			MsgAlert(cErro,"Wizard Saude")
		EndIf
	EndIf
	If !Empty(self:aCampoPrin[1])
		lRet := PrjExtCmp(@cErro,self:aCampoPrin)
		If !lRet
			MsgAlert(cErro,"Wizard Saude")
		EndIf
	EndIf
Return lRet

Method defPages(oStepWiz) Class PrjWzConfig
	Local oPage1 	:= nil
	Local oPage2 	:= nil
	Local oPage3 	:= nil
	Local oPage4 	:= nil
	Local oPage5 	:= nil
	local bNext		:= {||}
	Local lTemSched := len(self:aSchedList) > 0 .And. valType(self:aSchedList[1]) == "J"
	Local lTemParam := len(self:aParamList) > 0 .And. !Empty(self:aParamList[1])
	Local lTemArqui := len(self:aArquiList) > 0 .And. valType(self:aArquiList[1]) == "J"
	Local lTemMile	:= len(self:aMileList) 	> 0 .And. valType(self:aMileList[1]) == "J"
	Local lTemCsv	:= len(self:aCsvList) 	> 0 .And. valType(self:aCsvList[1])	== "J"

	if lTemSched
		oPage1 := PrjWzPgScd():New(self:aSchedList)
		lUltPag := !lTemParam .AND. !lTemArqui .AND. !lTemMile .AND. !lTemCsv
		bNext := IIf(lUltPag, {|| self:lFimOk := oPage1:vldNextAction(), oDlg:End()},{|| oPage1:vldNextAction()})
		oNewPag := oStepWiz:AddStep("1", {|oPanel|oPage1:makeScreen(oPanel)})
		oNewPag:SetStepDescription(self:aProcess[1] + " - " + oPage1:cTitle)
		oNewPag:SetNextAction(bNext)
		oNewPag:SetCancelAction({||, oPage1:vldCancelAction(), oDlg:End()})
		oNewPag:SetCancelWhen({||oPage1:CancelWhen()})
		aAdd(self:aPages,oPage1)
	EndIf
	if lTemParam
		oPage2 := PrjWzPgPrm():New(self:aParamList)
		lUltPag := !lTemArqui .AND. !lTemMile .AND. !lTemCsv
		bNext := IIf(lUltPag, {|| self:lFimOk := oPage2:vldNextAction(), oDlg:End()},{|| oPage2:vldNextAction()})
		oNewPag := oStepWiz:AddStep("2", {|oPanel|oPage2:makeScreen(oPanel)})
		oNewPag:SetStepDescription(self:aProcess[1] + " - " + oPage2:cTitle)
		oNewPag:SetNextAction(bNext)
		oNewPag:SetCancelAction({||, oPage2:vldCancelAction(), oDlg:End()})
		oNewPag:SetCancelWhen({||oPage2:CancelWhen()})
		aAdd(self:aPages,oPage2)
	EndIf
	if lTemArqui
		oPage3 := PrjWzPgArq():New(self:aArquiList)
		lUltPag := !lTemMile .AND. !lTemCsv
		bNext := IIf(lUltPag, {|| self:lFimOk := oPage3:vldNextAction(), oDlg:End()},{|| oPage3:vldNextAction()})
		oNewPag := oStepWiz:AddStep("3", {|oPanel|oPage3:makeScreen(oPanel)})
		oNewPag:SetStepDescription(self:aProcess[1] + " - " + oPage3:cTitle)
		oNewPag:SetNextAction(bNext)
		oNewPag:SetCancelAction({||, oPage3:vldCancelAction(), oDlg:End()})
		oNewPag:SetCancelWhen({||oPage3:CancelWhen()})
		aAdd(self:aPages,oPage3)
	EndIf
	if lTemMile
		oPage4 := PrjWzPgMil():New(self:aMileList)
		lUltPag := !lTemCsv
		bNext := IIf(lUltPag, {|| self:lFimOk := oPage4:vldNextAction(), oDlg:End()},{|| oPage4:vldNextAction()})
		oNewPag := oStepWiz:AddStep("4", {|oPanel|oPage4:makeScreen(oPanel)})
		oNewPag:SetStepDescription(self:aProcess[1] + " - " + oPage4:cTitle)
		oNewPag:SetNextAction(bNext)
		oNewPag:SetCancelAction({||, oPage4:vldCancelAction(), oDlg:End()})
		oNewPag:SetCancelWhen({||oPage4:CancelWhen()})
		aAdd(self:aPages,oPage4)
	EndIf
	if lTemCsv
		bNext := {|| self:lFimOk := oPage5:vldNextAction(), oDlg:End()}
		oPage5 := PrjWzPgCsv():New(self:aCsvList)
		oNewPag := oStepWiz:AddStep("5", {|oPanel|oPage5:makeScreen(oPanel)})
		oNewPag:SetStepDescription(self:aProcess[1] + " - " + oPage5:cTitle)
		oNewPag:SetNextAction(bNext)
		oNewPag:SetCancelAction({||, oPage5:vldCancelAction(), oDlg:End()})
		oNewPag:SetCancelWhen({||oPage5:CancelWhen()})
		aAdd(self:aPages,oPage5)
	EndIf
Return self:aPages

Method getPages() Class PrjWzConfig
return self:aPages

Method getProcess() Class PrjWzConfig
return self:aProcess

Method finishWzd() Class PrjWzConfig
	Local nPage := 0
	Local nMsg 	:= 1
	Local nLenPages := len(self:aPages)
	For nPage := 1 to nLenPages
		self:aPages[nPage]:endProcess()
	Next nPage
	If !Empty(self:aFinishmsg[1])
		For nMsg := 1 To Len(self:aFinishmsg)
			MsgInfo(self:aFinishmsg[nMsg])
		Next nMsg
	EndIf
Return