#include 'protheus.ch'

Class PrjCfgArt
	Data cFolder
	Data cFileName
	Data cUrl
	Data cRequest
	Data cErro
	
	Method new() Constructor
	Method getConfig()
	Method getErro()
	Method setErro(cErro)
	Method destroy()
	Method atualizaTabelas(oConfig)
	Method getOwnConf(cOwnConf)
	Method getSigaCen()
	Method getDefault()

EndClass

Method new(cOwnConf) Class PrjCfgArt
	Default cOwnConf := ""
	self:cFolder := "\tempPrj\"
	self:cErro := ""
	self:getOwnConf(cOwnConf)
Return self

Method destroy() Class PrjCfgArt
Return

Method getErro() Class PrjCfgArt
Return self:cErro

Method setErro(cErro) Class PrjCfgArt
	self:cErro := cErro
Return

Method getConfig() Class PrjCfgArt
	Local oConfig 	:= JsonObject():New()
	Local oWzFiles 	:= PrjWzFiles():New(self:cFolder, self:cFileName)
	Local cErrParse	:= ""
	
	If oWzFiles:getRest(self:cURL, self:cRequest+self:cFileName)
		cErrParse := oConfig:FromJson(oWzFiles:getResult())
		If !Empty(cErrParse)
			self:setErro(cErrParse)
		Else
			oWzFiles:saveFile() //Salva na tempprj
		EndIf
	EndIf
	If !Empty(oWzFiles:getErro())
		self:setErro(oWzFiles:getErro())
	EndIf
	FreeObj(oWzFiles)
	oWzFiles := nil
Return oConfig

Method atualizaTabelas(oConfig) Class PrjCfgArt
	Local oVersoes		:= nil	
	Local nArtefatos	:= 0
	Local nVersoes		:= 0
	Local nArtefato		:= 0 
	Local nVersao		:= 0
	Local cCodigo		:= ""
	Local lAtivo		:= .F.
	Local cUltimaVer	:= ""

	Local oPrjCltBI8		:= PrjCltBI8():new()
	Local oPrjCltBI9		:= PrjCltBI9():new()
	Default oConfig		:= self:getConfig()

	nArtefatos	:= Len(oConfig["artefatos"])
	//Percorro todos artefatos
	for nArtefato := 1 to nArtefatos
		cCodigo := "" //Limpa codigo anterior
		cCodigo := oConfig["artefatos"][nArtefato] //Seto artefato
		oVersoes := oConfig[cCodigo]["versoes"] 
		nVersoes := Len(oVersoes)

		oPrjCltBI8:setValue("BI8_CODIGO",oConfig[cCodigo]["codigo"])
		
		lInclui := !oPrjCltBI8:bscChaPrim()
		If oPrjCltBI8:found()
			oPrjCltBI8:getNext()
			oPrjCltBI8:mapFromDao()
		EndIf
		oPrjCltBI8:setValue("BI8_NOME",oConfig[cCodigo]["artefato"])
		cUltimaVer := oConfig[cCodigo][oVersoes[1]]["versao"]["nome"]
		oPrjCltBI8:setValue("BI8_ULTVER",cUltimaVer)
		If lInclui
			oPrjCltBI8:setValue("BI8_STATUS","2")
			oPrjCltBI8:setValue("BI8_ATUAUT","0")
		Else
			If cUltimaVer == oPrjCltBI8:getValue("BI8_VERLOC")
				oPrjCltBI8:setValue("BI8_STATUS","1")
			Elseif Empty(oPrjCltBI8:getValue("BI8_VERLOC"))
				oPrjCltBI8:setValue("BI8_STATUS","2")
			Else
				oPrjCltBI8:setValue("BI8_STATUS","0")
			Endif
		Endif
		oPrjCltBI8:commit(lInclui)

		for nVersao := 1 to nVersoes
			lAtivo := !Empty(oConfig[cCodigo][oVersoes[nVersao]]["ativo"]) .AND. oConfig[cCodigo][oVersoes[nVersao]]["ativo"]
			oPrjCltBI9:setValue("BI9_CODIGO",oConfig[cCodigo]["codigo"])
			oPrjCltBI9:setValue("BI9_VERDIS",oConfig[cCodigo][oVersoes[nVersao]]["versao"]["nome"])
			lInclui := !oPrjCltBI9:bscChaPrim()
			If oPrjCltBI9:found()
				oPrjCltBI9:getNext()
				oPrjCltBI9:mapFromDao()
			EndIf
			If lAtivo
				oPrjCltBI9:setValue("BI9_ATIVO","1")
			Else
				oPrjCltBI9:setValue("BI9_ATIVO","0")
			Endif
			oPrjCltBI9:commit(lInclui)
		next
	next

	FreeObj(oPrjCltBI8)	
	oConfig := nil
	FreeObj(oPrjCltBI9)
	oConfig := nil
	FreeObj(oConfig)
	oConfig := nil
	FreeObj(oVersoes)
	oVersoes := nil

Return

Method getOwnConf(cOwnConf) Class PrjCfgArt
	If cOwnConf == "SIGACEN"
		self:getSigaCen()
	Else
		self:getDefault()
	EndIf
Return

Method getSigaCen() Class PrjCfgArt
    self:cFileName := "versoesArtefatosSigaCen.json"
    self:cUrl := "https://cobprostorage.blob.core.windows.net"
    self:cRequest := "/files/SIGACEN/"
Return

Method getDefault() Class PrjCfgArt
    self:cFileName := "versoesArtefatos.json"
    self:cUrl := "https://arte.engpro.totvs.com.br"
    self:cRequest := "/public/sigapls/artefatos/"
Return
