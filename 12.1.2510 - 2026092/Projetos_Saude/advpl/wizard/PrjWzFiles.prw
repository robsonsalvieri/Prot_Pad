#include 'protheus.ch'

Static _barra := iif(IsSrvUnix(),"/","\")

Class PrjWzFiles
    Data cFolder
    Data cFileName
	Data cURL
	Data cRequest
	Data xResult
	Data cError

    Method new(cFolder, cFileName) Constructor
	Method getErro()
	Method setErro(cError)
    Method checkFolder(cFolder)
	Method readFile()
    Method getFileNames(cExt, cFolder)
	Method getRest(cURL, cRequest)
	Method getResult()
	Method getWDClient(cURL, cRequest)
    Method saveFile(oResult)
    Method downloadErr(cErr)
    Method extrairArq(lAddFolder)
EndClass

Method new(cFolder, cFileName) Class PrjWzFiles
	Default cFolder		:= ""
	Default cFileName	:= ""
	self:cFolder    	:= PrjWzLinux(cFolder)
    self:cFileName  	:= cFileName
	self:checkFolder()
Return self

Method getErro() Class PrjWzFiles
Return self:cError

Method setErro(cError) Class PrjWzFiles
	self:cError := cError
Return

Method checkFolder(cFolder) Class PrjWzFiles
	Local cBarra 	:= _barra
	Local aFolder 	:= {}
	Local nFolder	:= 0
	Local nLenFolder	:= 0
	Default cFolder := self:cFolder

	If !(ExistDir(cFolder))
		aFolder := StrTokArr(cFolder,cBarra)
		cFolder := cBarra
		nLenFolder := Len(aFolder)
		For nFolder := 1 To nLenFolder
			cFolder += aFolder[nFolder] + cBarra
			MakeDir(cFolder)
		Next nFolder
	EndIf
Return

Method readFile() Class PrjWzFiles
	Local cFile 		:= ""
	Local cFileInc 		:= self:cFolder + self:cFileName
	Local oFileRead 	:= FWFILEREADER():New(cFileInc)
	if oFileRead:Open()
		while (oFileRead:hasLine())
			cFile += oFileRead:GetLine()
		EndDo
		oFileRead:Close()
	Else
		self:setErro("Não foi possível abrir o arquivo: " + self:cFileName )
	EndIf
	FreeObj(oFileRead)
	oFileRead := nil
Return cFile

Method getFileNames(cExt, cFolder) Class PrjWzFiles
    Local nFile         := 1
    Local aFiles        := {}
    Local aFileNames    := {}
    Local nLenFiles     := 0
	Default cExt		:= "*.*"
	Default cFolder 	:= self:cFolder

    aFiles        := Directory(PrjWzLinux(cFolder + cExt))
    nLenFiles     := Len( aFiles )
	If nLenFiles > 0
        For nFile := 1 to nLenFiles
            aAdd(aFileNames, aFiles[nFile,1] )
        Next nFile
    EndIf
Return aFileNames

Method getRest(cURL, cRequest) Class PrjWzFiles
	Local aHeader 		:= {}
	Local oRest 		:= nil
	Local lRet			:= .F.
	self:xResult		:= ""
	self:cURL 			:= cURL
	self:cRequest 		:= cRequest

	oRest 	:= FwRest():New(self:cURL)
	oRest:SetPath(self:cRequest)
	oRest:nTimeout := 600
	If (oRest:Get(aHeader))
		self:xResult := oRest:GetResult()
		lRet := .T.
	Else
		self:downloadErr(oRest:GetLastError())
	EndIf
	FreeObj(oRest)
	oRest := nil
Return lRet

Method getResult() Class PrjWzFiles
Return self:xResult

Method getWDClient(cURL, cRequest) Class PrjWzFiles
	Local xRet
	Local aInfo 	:= {}
	Local cRootPath := PrjWzLinux(GetSrvProfString("ROOTPATH",""))
	self:cURL 			:= cURL
	self:cRequest 		:= cRequest
	xRet := WDClient("GET", cRootPath + self:cFolder + self:cFileName, self:cURL + self:cRequest, "", "", @aInfo)
	Do Case
		Case xRet == 0
			xRet := .T.
		Case xRet == 1
			self:downloadErr(aInfo[1])
			xRet := .F.
		Case xRet == 2
			self:downloadErr(aInfo[2])
			xRet := .F.
	EndCase
Return xRet

Method saveFile(oResult) Class PrjWzFiles
	Local nHandle := -1
	Local lSuccess := .T.
	Default oResult := self:xResult
	If File(self:cFolder + self:cFileName)
		FErase(self:cFolder + self:cFileName)
	EndIf
	nHandle := FCreate(self:cFolder + self:cFileName,NIL,NIL,.F.)
	If nHandle >= 0
		FWrite(nHandle, oResult)
	EndIf
	If (!File(self:cFolder + self:cFileName))
		lSuccess := .F.
		self:setErro("Erro ao criar arquivo - FERROR " + str(FError(),4) )
	EndIf
	FClose(nHandle)
Return lSuccess

Method downloadErr(cErr) Class PrjWzFiles
	Local cCodHttp 	:= SubStr( cValToChar(cErr), 0, 3 )
	Local cTitleErr := "Erro " + cCodHttp + " no Download do arquivo: " + self:cFileName + CRLF
	Local cMsgErr 	:= "Verifique sua conexão a internet ou o arquivo .json."
	Do Case
		Case cCodHttp == "7"
			cMsgErr := "Faltando nome de arquivo local"
		Case cCodHttp == "8" .Or. cCodHttp == "9"
			cMsgErr := "Faltando valor da url"
		Case cCodHttp == "13"
			cMsgErr := "Erro ao abrir/criar arquivo local"
		Case cCodHttp >= "400" .And. cCodHttp < "499"
			cMsgErr := "O site "+ AllTrim(self:cUrl) + AllTrim(self:cRequest) + " não foi encontrado, verifique o endereço URL no arquivo .json."
		Case cCodHttp >= "500" .And. cCodHttp < "599"
			cMsgErr := "O site "+ AllTrim(self:cUrl) + AllTrim(self:cRequest) + " está indisponível no momento. Tente novamente mais tarde."
	EndCase
	self:setErro(cTitleErr + cMsgErr)
return

Method extrairArq(lAddFolder) Class PrjWzFiles
	Local nRet 			:= 0
	Local nFiles 		:= 0
	Local lRet			:= .T.
	Local cExt 			:= ""
	Local cNome			:= ""
	Local cFolder		:= self:cFolder
	Default lAddFolder 	:= .F.
	SplitPath(self:cFileName, /* @cDrive*/, /* @cDiretorio*/,  @cNome, @cExt)
	If lAddFolder
		cFolder += cNome + _barra
		self:checkFolder(cFolder)
	EndIf
	Do Case
		Case lower(cExt) == ".zip"
			nRet := FUnzip(self:cFolder + self:cFileName,cFolder)
		Case lower(cExt) == ".tar"
			lRet := TarDecomp(self:cFolder + self:cFileName,cFolder,@nFiles,.F.)
		Otherwise
			lRet := .F.
	EndCase
	If nRet != 0 .Or. !lRet
		self:setErro("Falha ao descompactar o arquivo " + self:cFileName,"Wizard Saúde")
	EndIf
Return lRet

Function PrjWzLinux(cConteudo)
	If  !IsSrvUnix()
		cConteudo := StrTran(cConteudo,"/","\")
	Else
		cConteudo := StrTran(cConteudo,"\","/")
	EndIf   
	cConteudo := lower(cConteudo)
Return cConteudo