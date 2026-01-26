#include 'protheus.ch'
#include 'fwschedule.ch'
#include 'FWMVCDEF.CH'

#DEFINE CMPCAMPO	1
#DEFINE CMPTIPO		2
#DEFINE CMPSIZE		3
#DEFINE CMPDECIMAL	4
#DEFINE CMPTITULO	5
#DEFINE CMPEXIBE	6
#DEFINE CMPOBRIG	7
#DEFINE CMPWHEN 	8

Static _barra := iif(IsSrvUnix(),"/","\")
Static __cTabTmp := ""
Static __aCampos := {}

Class PrjWzPgMil From PrjWzPgArq
	Method new(aDados) Constructor
	Method getTabFlds()
	Method getTabTemp()
	Method addMoreFields()
	Method getXML()
	Method getFile()
	Method fileType()
	Method getZipFiles()
	Method endProcess()
	Method applyLayMile()

EndClass

Method new(aDados) Class PrjWzPgMil
	_Super:new(aDados)
	self:cTitle 	:= "Layout Mile"
	self:cDescri 	:= "Aplicar Layout MILE"
Return self

Method getTabFlds() Class PrjWzPgMil
	If Empty(self:aCampos)
		_Super:getTabFlds()
		//{CMPCAMPO,CMPTIPO,CMPSIZE,CMPDECIMAL,CMPTITULO,CMPEXIBE,CMPOBRIG,CMPWHEN}
		aAdd(self:aCampos,{"XML"		,"M",9999999,0,"XML"		,.F.,.F.,.F.})
		aAdd(self:aCampos,{"LAYOUT"		,"C",060	,0,"Layout"		,.T.,.F.,.F.})
		aAdd(self:aCampos,{"DESCRI"		,"C",300	,0,"Descrição"	,.T.,.F.,.F.})
		__aCampos := self:aCampos
	EndIf	
Return self:aCampos

Method getTabTemp() Class PrjWzPgMil
	Local oTabTemp := _Super:getTabTemp()
	__cTabTmp := _Super:getTabTemp():getAlias()
Return oTabTemp

Method getZipFiles() Class PrjWzPgMil
	Local oWzFiles 	:= PrjWzFiles():New(self:cDestino, self:cFileName)
	Local nLenXML	:= 0
	Local nXML		:= 1
	Local aXML		:= {}
	Local cNome 	:= ""
	SplitPath(self:cFileName, /* @cDrive*/, /* @cDiretorio*/,  @cNome, /*@cExt*/)
	oWzFiles:getWDClient(self:cURL, self:cRequest)
	If oWzFiles:extrairArq(.T.)
		self:cDestino += cNome + _barra
		oWzFiles:cFolder := self:cDestino
		aXML := oWzFiles:getFileNames("*.xml*")
		If !Empty(aXML)
			nLenXML := Len(aXML)
			ProcRegua(nLenXML)
			For nXML := 1 To nLenXML
				IncProc()
				If nXML > 1
					RecLock(cTabTemp,.T.)
					(cTabTemp)->ID 			:= AllTrim(StrZero(self:nID,4))
				EndIf
				(cTabTemp)->FILENAME	:= self:cFileName	:= aXML[nXML]
				(cTabTemp)->DESTINO 	:= self:cDestino
				(cTabTemp)->ENVDOK		:= "XX"
				self:getFile(.F.)
				(cTabTemp)->(msUnLock())
				self:nID += 1
				self:nTotReg += 1
			Next nXML
		EndIf
	EndIf
	If !Empty(oWzFiles:getErro())
		MsgAlert(oWzFiles:getErro())
	EndIF
	FreeObj(oWzFiles)
	oWzFiles := nil
Return

Method getFile(lGet) Class PrjWzPgMil
	Local oWzFiles		:= PrjWzFiles():New(self:cDestino, self:cFileName)
	Default lGet	:= .T.
	If lGet
		If !(oWzFiles:getRest(self:cURL, self:cRequest) .And. oWzFiles:saveFile())
			MsgAlert(oWzFiles:getErro())
		EndIf
	EndIf
	self:fileType()
	FreeObj(oWzFiles)
	oWzFiles := nil
Return

Method fileType() Class PrjWzPgMil
	Local cExt := ""
	SplitPath(self:cFileName, /* @cDrive*/, /* @cDiretorio*/,  /*@cNome*/, @cExt)
	If lower(cExt) == ".xml"
		self:getXML()
	Endif
Return

Method getXML() Class PrjWzPgMil
	Local oXml			:= TXmlManager():New()
	If oXml:ParseFile(self:cDestino + self:cFileName)
		(cTabTemp)->XML			:= MemoRead(self:cDestino + self:cFileName)
		(cTabTemp)->LAYOUT		:= oXML:XPathGetNodeValue("/CFGA600/XZ1MASTER/XZ1_LAYOUT")
		(cTabTemp)->DESCRI		:= oXML:XPathGetNodeValue("/CFGA600/XZ1MASTER/XZ1_DESC")
	EndIF
	FreeObj(oXml)
	oXml := nil
Return

Method addMoreFields() Class PrjWzPgMil
	If self:lUnzip
		Processa({|| self:getZipFiles()})
	Else
		self:getFile()                          
		self:nID += 1
	EndIf
Return

Method endProcess() Class PrjWzPgMil
	Processa({|| self:applyLayMile()}, "Aplicando Layouts" )
Return

Method applyLayMile() Class PrjWzPgMil
	Local cTabTemp	:= self:getTabTemp():getAlias()                                      
	Local oModel	:= nil
	Local cLayout	:= ""
	Local cXXJ		:= RetSqlName("XXJ")
	Local cXML		:= ""
	Local aAreaXXJ	:= {}

	if (select(cXXJ)==0)
		FWOpenXXJ() 
	endIf
	aAreaXXJ	:= XXJ->( GetArea() )
	DbSelectArea("XXJ")
	XXJ->( DbSetOrder(1) )
	oModel := FWLoadModel( 'CFGA601' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	ProcRegua(self:nTotReg)
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (cTabTemp)->ENVDOK == self:oMark:cMark
			self:cFileName	:= Alltrim((cTabTemp)->FILENAME)
			self:cDestino	:= Alltrim((cTabTemp)->DESTINO)
			cLayout			:= AllTrim((cTabTemp)->LAYOUT)
			cXML			:= AllTrim((cTabTemp)->XML)
			IncProc("Aplicando layout " + self:cFileName)
			If !Empty(cXML)
				If !Empty( cLayout ) .And. XXJ->(DbSeek( cLayout ))
					RecLock("XXJ",.F.)
					XXJ->( DbDelete() )
					XXJ->( MsUnlock() )
				EndIf
				oModel:Activate()
				If oModel:LoadXmlData( cXML )
					If oModel:VldData()
						oModel:CommitData()
					EndIf
				EndIf
				oModel:Deactivate()
			EndIf
		EndIf
		(cTabTemp)->(dbSkip())
	Enddo
	FreeObj(oModel)
	oModel := nil
	RestArea( aAreaXXJ )
Return