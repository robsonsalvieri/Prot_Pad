#include 'protheus.ch'

Class PrjArtefato From CenEntity
	Data cCodigo
	Data cVersion
	Data cTipArq 
	Data cNomeArq
	Data cRotina
    Data cFileConf
    Data cFolder
    Data cDestino
    Data cUrl
    Data cRequest
	Data cErro
	Data oConfig
	Data lNoMove
	Data oConfRoti 
	Data aFuncObr
	Data aCmpObr
	Data lAtivo

	Method new(cCodigo,cVersion,oConfig) Constructor
	Method destroy()
	Method setConfig(oConfig)
	Method getConfig()
	Method loadArtefato()
	Method setErro(cErro)
	Method getErro()
	Method downAndSave()
	Method lancaRotina()
	Method moveDestino()
	Method limpTemp()
	Method getCfgRepo()
	Method verifMove()
	Method lockArtefato()
	Method unlockArtefato()
	Method podeExecutar()
	Method saveErro()
	Method sucessoAtualizacao()
	Method estaAtualizado()
	Method IniciaProcesso()
	Method FinalizaProcesso()
	Method falhaAtualizacao()
	Method verifAtivo()
	Method SaveManual() 

EndClass

Method new(cCodigo,cVersion,oConfig) Class PrjArtefato
	Default cCodigo := BI8->BI8_CODIGO
	Default cVersion := allTrim(BI8->BI8_ULTVER)
	_Super:new()
	self:cCodigo 	:= cCodigo
    self:cVersion 	:= cVersion
    self:cFileConf 	:= "versoesArtefatos.json"
    self:cFolder 	:= "\tempPrj\"
    self:cUrl 		:= "https://arte.engpro.totvs.com.br"
    self:cRequest 	:= "/public/sigapls/artefatos/"
	self:cErro		:= ""
	self:oConfig	:= oConfig
	self:aFuncObr	:= {}
	self:aCmpObr	:= {}
Return self

Method destroy() Class PrjArtefato
	if self:oConfig != nil
		self:oConfig:destroy()
		FreeObj(self:oConfig)
		self:oConfig:= nil
	EndIf
Return

Method setConfig(oConfig) Class PrjArtefato
	self:oConfig := oConfig
Return

Method getConfig() Class PrjArtefato
	Local cErrParse	:= ""
	Local cArqJson	:= ""
	Local oWzFiles := nil

	If self:oConfig == nil 
		self:oConfig := JsonObject():New()
		oWzFiles := PrjWzFiles():New(self:cFolder, self:cFileConf)
		cArqJson := oWzFiles:readFile()
		If Empty(cArqJson)
			self:setErro(oWzFiles:getErro())
			self:oConfig := self:getCfgRepo()
		Else
			cErrParse := self:oConfig:FromJson(cArqJson)
			If !Empty(cErrParse)
				self:setErro(cErrParse)
				self:oConfig := self:getCfgRepo()
			EndIf
		EndIf
		FreeObj(oWzFiles)
		oWzFiles := nil
	EndIf

Return self:oConfig

Method loadArtefato() Class PrjArtefato
	Local oConfig       := self:getConfig()
	Local lFound := aScan(oConfig:getNames(),{|cProp| cProp == self:cCodigo}) > 0
	//Alimentando objeto artefato para enviar a rotina
	If Empty(self:getErro())
		If lFound
			self:cNomeArq	:= oConfig[self:cCodigo]["arquivo"]
			self:cURL		:= oConfig[self:cCodigo][self:cVersion]["repositorio"] 
			self:cRequest	:= oConfig[self:cCodigo][self:cVersion]["uri"] 
			self:cRotina	:= oConfig[self:cCodigo][self:cVersion]["rotina"] 
			self:cTipArq	:= oConfig[self:cCodigo][self:cVersion]["tipoArquivo"] 
			self:cDestino	:= oConfig[self:cCodigo][self:cVersion]["destino"]
			self:lNoMove	:= self:verifMove()
			self:oConfRoti	:= oConfig[self:cCodigo][self:cVersion]["versao"]["configuracoes"]
			self:aFuncObr	:= oConfig[self:cCodigo][self:cVersion]["versao"]["funcoesObrigatorias"]
			self:aCmpObr	:= oConfig[self:cCodigo][self:cVersion]["versao"]["camposObrigatorios"]
			self:lAtivo		:= !Empty(oConfig[self:cCodigo][self:cVersion]["ativo"]) .AND. oConfig[self:cCodigo][self:cVersion]["ativo"]
		Else
			self:setErro("Não encontrou o artefato " + self:cCodigo + " no arquivo de configuração.")
		EndIf
	EndIf

Return lFound

Method setErro(cErro) Class PrjArtefato
	self:cErro := cErro
Return

Method getErro() Class PrjArtefato
Return self:cErro

Method downAndSave() Class PrjArtefato
	Local oWzFiles	:= nil
	Local cArquivo	:= ""
	Local lDownOk	:= .F.
	
	If self:loadArtefato()
		If Empty(self:cDestino) .And. !self:lNoMove
			self:setErro("Informe a pasta de destino") 
		Else
			cArquivo	:= self:cNomeArq + "_" + self:cVersion + "." + self:cTipArq
			oWzFiles := PrjWzFiles():New(self:cFolder,cArquivo)
			oWzFiles:checkFolder(self:cFolder)
			oWzFiles:checkFolder(self:cDestino) //Cria destino se não houver
			if isBlind()
				lDownOk := oWzFiles:getRest(self:cURL,self:cRequest)
			Else
				MsgRun ( "Aguarde, os arquivos estão sendo baixados" , "Processando", { || lDownOk := oWzFiles:getRest(self:cURL,self:cRequest)} )
			Endif
			If lDownOk
			//If oWzFiles:getRest(self:cURL,self:cRequest)
				If oWzFiles:saveFile(oWzFiles:getResult())
					If self:moveDestino()
						oWzFiles:cFolder := self:cDestino
						oWzFiles:extrairArq()
					EndIf
				EndIf
			EndIf
			If !Empty(oWzFiles:getErro())
				self:setErro(oWzFiles:getErro())
			EndIf
		EndIf

		FreeObj(oWzFiles)
		oWzFiles := nil
	EndIf

Return Empty(self:getErro())

Method podeExecutar() Class PrjArtefato
	Local lPode	:= .T.
	Local cErro	:= ""
	Default self:aFuncObr := {}
	Default self:aCmpObr := {}
	
	aAdd(self:aFuncObr,self:cRotina)
	PrjExtFunc(@cErro,self:aFuncObr)
	PrjExtCmp(@cErro,self:aCmpObr)
	lPode := Empty(cErro)
	If !lPode
		cErro += CRLF + "A rotina " + self:cRotina + " não poderá ser executada"
		self:setErro(cErro)
	EndIf
Return lPode

Method lancaRotina() Class PrjArtefato
	Local lSucesso	:= .F.
	Local cRotina :=  AllTrim(self:cRotina) + "(self)"
	Default self:cRotina := ""

	If self:podeExecutar()
		if isBlind()
			lSucesso := &(cRotina)
		Else
			oProcess := MsNewProcess():New( { || lSucesso := &(cRotina) } , "Processando" , "Aguarde..." , .f. )
			oProcess:Activate()  

			FreeObj(oProcess)
			oProcess := nil
		EndIf
	EndIf
	
    If !lSucesso .AND. Empty(self:getErro())
		self:setErro("Houve um erro na atualização")
	Endif

Return lSucesso

Method moveDestino() Class PrjArtefato
	Local cArquivo	:= self:cNomeArq + "_" + self:cVersion + "." + self:cTipArq
	Local lSuccess	:= .T.
	
	If !self:lNoMove
		lSuccess := _CopyFile(self:cFolder+cArquivo,self:cDestino+cArquivo)
		
		If File(self:cFolder+cArquivo)
			FErase(self:cFolder+cArquivo)
		EndIf

		If !lSuccess
			self:setErro("Não foi possível movimentar os arquivos " + cArquivo + " para a pasta " + self:cDestino+cArquivo)
		Endif
	Endif

Return lSuccess

Method getCfgRepo() Class PrjArtefato
	
	Local oPrjCfgArt	:= PrjCfgArt():New()
	Local oCfgRepo		:= oPrjCfgArt:getConfig()

	oPrjCfgArt:destroy()
    FreeObj(oPrjCfgArt)
    oPrjCfgArt := nil
	
Return oCfgRepo

Method verifMove() Class PrjArtefato
	
	Local lMovimenta := .F.		

	If self:cDestino == "n"
		self:lNoMove := .T.
	Endif
	
Return lMovimenta

Method lockArtefato(cNome) Class PrjArtefato

	Local lLock := .F.
	Default cNome	:= ""

	lLock := LockByName(cNome, .T., .T.)
	If !lLock
		self:setErro("Não foi possível atualizar o Artefato " + cNome + ", o mesmo já se encontra em outro processo de atualização.")
	Endif

Return lLock

Method unlockArtefato(cNome) Class PrjArtefato

	Local lUnlock	:= .F.
	Default cNome		:= ""

	lUnlock := UnlockByName(cNome, .T., .T.)
	
Return lUnlock

Method saveErro() Class PrjArtefato
	
	Local oPrjCltBI8	:= PrjCltBI8():new()
	Local oPrjCltBI9	:= PrjCltBI9():new()

	oPrjCltBI8:setValue("BI8_CODIGO",self:cCodigo)
	If oPrjCltBI8:bscChaPrim()
		oPrjCltBI8:getNext()
		oPrjCltBI8:mapFromDao()
		oPrjCltBI8:setValue("BI8_DESERR",self:getErro())
		oPrjCltBI8:commit()
	Endif

	oPrjCltBI9:setValue("BI9_CODIGO",self:cCodigo)
	oPrjCltBI9:setValue("BI9_VERDIS",self:cVersion)
	If oPrjCltBI9:bscChaPrim()
		oPrjCltBI9:getNext()
		oPrjCltBI9:mapFromDao()
		oPrjCltBI9:setValue("BI9_DESERR",self:getErro())
		oPrjCltBI9:commit()
	Endif

	FreeObj(oPrjCltBI8)
	oPrjCltBI8 := nil
	FreeObj(oPrjCltBI9)
	oPrjCltBI9 := nil

Return

Method sucessoAtualizacao(lAtuAut) Class PrjArtefato
	
	Local cStatus		:= ""
	Local oPrjCltBI8	:= PrjCltBI8():new()
	Local oPrjCltBI9	:= PrjCltBI9():new()
	Local dDiaAtuali	:= Date()
	Local cHoraAtual	:= Time()
	Default lAtuAut		:= .F.

	cStatus := self:estaAtualizado()

	oPrjCltBI8:setValue("BI8_CODIGO",self:cCodigo)
	If oPrjCltBI8:bscChaPrim()
		oPrjCltBI8:getNext()
		oPrjCltBI8:mapFromDao()
		oPrjCltBI8:setValue("BI8_VERLOC",self:cVersion)
		oPrjCltBI8:setValue("BI8_STATUS",cStatus)
		If lAtuAut
			oPrjCltBI8:setValue("BI8_STATAU","1")
		Else
			oPrjCltBI8:setValue("BI8_STATAU","")
		Endif
		oPrjCltBI8:setValue("BI8_DATA",dDiaAtuali)
		oPrjCltBI8:setValue("BI8_HORA",cHoraAtual)
		oPrjCltBI8:commit()
	Endif

	oPrjCltBI9:setValue("BI9_CODIGO",self:cCodigo)
	oPrjCltBI9:setValue("BI9_VERDIS",self:cVersion)
	If oPrjCltBI9:bscChaPrim()
		oPrjCltBI9:getNext()
		oPrjCltBI9:mapFromDao()
		If lAtuAut
			oPrjCltBI9:setValue("BI9_STATAU","1")
		Else
			oPrjCltBI9:setValue("BI9_STATAU","")
		Endif
		oPrjCltBI9:commit()
	Endif

	FreeObj(oPrjCltBI8)
	oPrjCltBI8 := nil
	FreeObj(oPrjCltBI9)
	oPrjCltBI9 := nil
	
Return

Method estaAtualizado() Class PrjArtefato
	
	Local oPrjCltBI8:= PrjCltBI8():new()
	Local oVersoes	:= nil
	Local cAtual	:= ""
	Local cVerAtual	:= ""
	
	oVersoes	:= self:oConfig[self:cCodigo]["versoes"]
	cVerAtual	:= self:oConfig[self:cCodigo][oVersoes[1]]["versao"]["nome"]

	//Gravo última versão disponível
	oPrjCltBI8:setValue("BI8_CODIGO",self:cCodigo)
	If oPrjCltBI8:bscChaPrim()
		oPrjCltBI8:getNext()
		oPrjCltBI8:mapFromDao()
		oPrjCltBI8:setValue("BI8_ULTVER",cVerAtual)
		oPrjCltBI8:commit()
	Endif
	
	//Verifico se a atualização realizada é a última disponível
	If cVerAtual == self:cVersion
		cAtual := "1"
	Else
		cAtual := "0"
	Endif

	FreeObj(oPrjCltBI8)
	oPrjCltBI8 := nil

Return cAtual

Method IniciaProcesso(lAtuAut) Class PrjArtefato
	
	Local lLocado := .F.
	Local oPrjCltBI8	:= PrjCltBI8():new()
	Local oPrjCltBI9	:= PrjCltBI9():new()
	Default lAtuAut		:= .F.

	If self:lockArtefato(self:cCodigo)
		lLocado := .T.
		oPrjCltBI8:setValue("BI8_CODIGO",self:cCodigo)
		If oPrjCltBI8:bscChaPrim()
			oPrjCltBI8:getNext()
			oPrjCltBI8:mapFromDao()
			oPrjCltBI8:setValue("BI8_STATAU","2")
			oPrjCltBI8:commit()
		Endif

		oPrjCltBI9:setValue("BI9_CODIGO",self:cCodigo)
		oPrjCltBI9:setValue("BI9_VERDIS",self:cVersion)
		If oPrjCltBI9:bscChaPrim()
			oPrjCltBI9:getNext()
			oPrjCltBI9:mapFromDao()
			oPrjCltBI9:setValue("BI9_STATAU","2")
			oPrjCltBI9:commit()
		Endif

	Endif

	FreeObj(oPrjCltBI8)
	oPrjCltBI8 := nil
	FreeObj(oPrjCltBI9)
	oPrjCltBI9 := nil

Return lLocado

Method verifAtivo() Class PrjArtefato
	If !self:lAtivo
		self:setErro("A versão do artefato não está ativa!")
	Endif
Return self:lAtivo

Method FinalizaProcesso() Class PrjArtefato
	self:unlockArtefato(self:cCodigo)
Return

Method falhaAtualizacao(lAtuAut) Class PrjArtefato
	
	Local oPrjCltBI8	:= PrjCltBI8():new()
	Local oPrjCltBI9	:= PrjCltBI9():new()
	Default lAtuAut		:= .F.

	oPrjCltBI8:setValue("BI8_CODIGO",self:cCodigo)
	If oPrjCltBI8:bscChaPrim()
		oPrjCltBI8:getNext()
		oPrjCltBI8:mapFromDao()
		If lAtuAut
			oPrjCltBI8:setValue("BI8_STATAU","0")
		Else
			oPrjCltBI8:setValue("BI8_STATAU","")
		Endif
		oPrjCltBI8:commit()
	Endif

	oPrjCltBI9:setValue("BI9_CODIGO",self:cCodigo)
	oPrjCltBI9:setValue("BI9_VERDIS",self:cVersion)
	If oPrjCltBI9:bscChaPrim()
		oPrjCltBI9:getNext()
		oPrjCltBI9:mapFromDao()
		If lAtuAut
			oPrjCltBI9:setValue("BI9_STATAU","0")
		Else
			oPrjCltBI9:setValue("BI9_STATAU","")
		Endif
		oPrjCltBI9:commit()
	Endif

	FreeObj(oPrjCltBI8)
	oPrjCltBI8 := nil
	FreeObj(oPrjCltBI9)
	oPrjCltBI9 := nil

Return

Method SaveManual() Class PrjArtefato
	Local oWzFiles	:= nil
	Local cArquivo	:= ""
	
	If self:loadArtefato()
		If Empty(self:cDestino) .And. !self:lNoMove
			self:setErro("Informe a pasta de destino") 
		Else
			cArquivo	:= self:cNomeArq + "_" + self:cVersion + "." + self:cTipArq
			oWzFiles := PrjWzFiles():New(self:cFolder,cArquivo)
			oWzFiles:checkFolder(self:cFolder)
			oWzFiles:checkFolder(self:cDestino)
			If self:moveDestino()
				oWzFiles:cFolder := self:cDestino
				oWzFiles:extrairArq()
			EndIf		
			If !Empty(oWzFiles:getErro())
				self:setErro(oWzFiles:getErro())
			EndIf
		EndIf

		FreeObj(oWzFiles)
		oWzFiles := nil
	EndIf

Return Empty(self:getErro())