#include "totvs.ch"
#include "fileio.ch"
#include "OFCNHPrimWsDir.ch"

Function OFCNH0016();Return

/*/{Protheus.doc} OFCNHPrimWsDir
	Classe que representa o webservice para controle de arquivos do prim
	
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/ 
Class OFCNHPrimWsDir from OFCNHPrimWs
	Data oWsConnect
	Data oConfig
	Data oUser
	Data aFiles
	Data lDirLoaded
	Data cBrand

	// acoes do webservice
	Data cActDir
	Data cActCommit
	Data cActLogin
	Data cActLogout
	Data cActDownload
	Data cActUpload

	// retornos do webservice
	Data cLoginId
	Data cSincom
	Data cMarket
	Data cDocId
	Data lLoggedIn
	Data cLastDownload

	Method New() CONSTRUCTOR
	Method Dir()
	Method Login()
	Method Logout()
	Method Commit()
	Method Download()
	Method Upload()
	Method AnalisaRetorno()
	Method ColetaDadosRetorno()
	Method ColetaArquivos()
	Method Enviar()
	Method FormatDate()
	Method ClearDirCache()
	Method sendChunk()
EndClass 

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method New(oUser) Class OFCNHPrimWsDir
local oConfig := OFCNHPrimConfig():New()

	_Super:New()
	::oUser          := oUser
	::oConfig        := oConfig:GetConfig()
	::oWsConnect     := OFCNHPrimWsConnect():New(oUser)
	::cSincom        := oConfig:cDealerCode
	::cMarket        := oConfig:cMarket
	::cActDir        := 'cconDir'
	::cActCommit     := 'cconCommit'
	::cActLogin      := 'cconLogin'
	::cActLogout     := 'cconLogout'
	::cActDownload   := 'cconGet'
	::cActUpload     := 'cconPost'
	::cBrand         := '00'
	::lDirLoaded     := .F.
	::lLoggedIn      := .F.
	::aFiles         := {}

	if ::oConfig["AMBIENTE"] == "TEST"
		::cEndWsdl     := 'http://www.itmil.com.br/stg_cconWsAutDotNet.wsdl'
	else
		::cEndWsdl     := 'http://www.itmil.com.br/cconWsAutDotNet.wsdl'
	endif
Return SELF


/*/{Protheus.doc} ClearDirCache
	Limpa o cache de arquivos para que sejam lidos novamente do ws, usado
	quando um arquivo foi alterado no webservice e é necessário rebusca-los com 
	informação atualizada

	@type function
	@author Vinicius Gati
	@since 23/03/2018
/*/
Method ClearDirCache() Class OFCNHPrimWsDir
	self:aFiles     := {}
	self:lDirLoaded := .F.
Return .t.

/*/{Protheus.doc} Upload
	Faz upload de um arquivo

	@type function
	@author Vinicius Gati
	@since 21/03/2018
/*/
Method Upload( cFilePath, cFileName ) Class OFCNHPrimWsDir
local aContent    := {}
local cBuffer     := ''
local nX, nX1     := 1
local nChunksSend := 0
local cOnlyName   := left( cFileName, RAT( ".", cFileName )-1 )
local oFile
local cData       := ""
local nHandle
local nTamTxt     := 0
local nCurrent    := 0
local cBufTxt     := ""
local nIntChunks	:= 0

	self:cDocId   := ''

	GzCompress( cFilePath + cFileName, cFilePath + cOnlyName + '.gzip')

	nHandle := fOpen( cFilePath + cOnlyName + '.gzip' )

	nTamTxt := FSEEK( nHandle, 0, FS_END )
	FSEEK( nHandle, 0 )

	while nCurrent < nTamTxt
		nCurrent += FREAD( nHandle, @cBufTxt, 4096 )
		cData += cBufTxt
	endDo

	fClose( nHandle )
	fErase( cFilePath + cOnlyName + '.gzip' )

	sPostRet := lower(OFXFA019C_Str2Hex(cData))

	cByteHex := ''
	For nX := 1 to Len(sPostRet)
		cByteHex += substr(sPostRet, nX, 1)
		if len(cByteHex) == 2
			AADD(aContent, cByteHex)
			cByteHex := ''
		endif
	Next

	nBytes      := Len(aContent)
	nChunks     := nBytes / 1000000
	nIntChunks  := int(nChunks)
	for nX1 := 1 to nBytes

		cOperation := iif( nChunks < 1, 'end:0', iif( nX1 == 1 .AND. nChunks > 1, 'start', iif( nX1 > 1 .AND. nChunksSend <= nIntChunks, 'next', 'end' ) ) )

		cBuffer += alltrim(aContent[nX1])
		if len(cBuffer) >= 2000000
			self:sendChunk(cBuffer, iif(nChunksSend == 0, cOperation:='start',cOperation ), len(cBuffer), self:cDocId)
			nChunksSend ++
			cBuffer := ''
		endif
	next
	if Len(cBuffer) > 0
		self:sendChunk(cBuffer, cOperation, nBytes, self:cDocId)
	endif
	if empty( self:cError)
		oFile := OFCNHPrimWsFile():New()
		oFile:cFileId := self:cDocId
		self:Commit(oFile)
	endif

return self:cCodeRet != '-2'

/*/{Protheus.doc} sendChunk
	Envia um pedaço de arquivo ou arquivo inteiro para cnh

	@type function
	@author Vinicius Gati
	@since 28/03/2018
/*/
Method sendChunk(cBuffer, cOperation, nFullSize, cDocId) Class OFCNHPrimWsDir
	local cXml     := ''
	default cDocId := ''

	cXml += '<urn:cconPost soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
	cXml += '  <Ticket      xsi:type="xsd:string">XXXXXXXTICKETXXXXXXX</Ticket>'
	cXml += '  <ServiceId   xsi:type="xsd:string">XXXXXXXSERVICEXXXXXXX</ServiceId>'
	cXml += '  <LoginId     xsi:type="xsd:string">XXXXXXXLOGINXXXXXXX</LoginId>'
	cXml += '  <DocId       xsi:type="xsd:string">'+cDocId+'</DocId>'
	cXml += '  <DocAppl     xsi:type="xsd:string">PRIM</DocAppl>'
	cXml += '  <DocType     xsi:type="xsd:string">PRIM2</DocType>'
	cXml += '  <Compress    xsi:type="xsd:string"></Compress>'
	cXml += '  <Encoding    xsi:type="xsd:string">asciihex</Encoding>' 
	cXml += '  <Operation   xsi:type="xsd:string">'+cOperation+'</Operation>' // start, next, end
	cXml += '  <ChunkLength xsi:type="xsd:string">'+alltrim(str(LEN(cBuffer)/2))+'</ChunkLength>' // len do conteudo dividido por 2
	cXml += '  <Buffer      xsi:type="xsd:string">'+cBuffer+'</Buffer>' // conteudo enviado
	cXml += '  <DestMarket  xsi:type="xsd:string"></DestMarket>'
	cXml += '  <DestApplic  xsi:type="xsd:string">PRIM</DestApplic>'
	cXml += '  <DestUser    xsi:type="xsd:string"></DestUser>'
	cXml += '</urn:cconPost>'
return self:Enviar(self:cActUpload, cXml)


/*/{Protheus.doc} Download
	Faz o download de um arqiuvo e decoda para gzip normal para importação
	
	@type function
	@author Vinicius Gati
	@since 23/03/2018
/*/
Method Download(oFile)  Class OFCNHPrimWsDir
	local oArrHlp    := DMS_ArrayHelper():New()
	local cData      := ''
	local cPath      := ''
	local cFilePath  := ''
	local cFileName  := ''
	local cXml       := ''
	local cLen       := ''
	local aFileData  := {} // de 1 mb em 1mb para jogar em arquivo
	local nX         := 1
	local lGzDecomp  := .F.
	local nSize      := Val(oFile:cSize) * 2
	local nChunks    := nSize / 999999
	local sPostRet   := ''
	local lFileOK    := .F.
	local lMemoWrite := .F.

	if nChunks < 1
		nChunks := 1
	endif

	for nX := 1 to nChunks
		if nChunks == 1 // pedaco unico
			cLen := STR( VAL(oFile:cSize)*2 )
		else
			cLen := '999999'
			if nX == nChunks
				nLastChunkSize := nSize - ((nChunks-1)*999999)
				cLen := STR(nLastChunkSize)
			endif
		endif

		cXml += '  <urn:cconGet soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
		cXml += '    <Ticket      xsi:type="xsd:string">XXXXXXXTICKETXXXXXXX</Ticket>'
		cXml += '    <ServiceId   xsi:type="xsd:string">XXXXXXXSERVICEXXXXXXX</ServiceId>'
		cXml += '    <LoginId     xsi:type="xsd:string">XXXXXXXLOGINXXXXXXX</LoginId>'
		cXml += '    <DocId       xsi:type="xsd:string">'+oFile:cFileId+'</DocId>'
		cXml += '    <DocAppl     xsi:type="xsd:string"></DocAppl>'
		cXml += '    <DocType     xsi:type="xsd:string"></DocType>'
		cXml += '    <Compress    xsi:type="xsd:string">'+oFile:cCompress+'</Compress>'
		cXml += '    <Encoding    xsi:type="xsd:string">asciihex</Encoding>'
		cXml += '    <Operation   xsi:type="xsd:string">'+IIF(nX == 1, 'start', 'next')+'</Operation>' // start ou next para inicar inicio do arquivo ou complemento
		cXml += '    <ChunkLength xsi:type="xsd:string">'+ALLTRIM(cLen)+'</ChunkLength>' // tamanho em bytes
		cXml += '  </urn:cconGet>'
		if self:Enviar(self:cActDownload, cXml, IIF( nX == nChunks, .T., .F. ))
			AADD(aFileData, self:cLastDownload)
		endif
	next

	if Len(aFileData) > 0
		cData      := oArrHlp:Join(aFileData, '')
		cPath      := GetSrvProfString("Rootpath","") + oFile:cFullFilePath
		cFileName  := cFilAnt + '_' + oFile:cFileId
		cFilePath  := cPath + cFileName + ".gz"
		
		sPostRet := OFXFA021C_Hex2Str(cData)

        lMemoWrite := memowrite(oFile:cFullFilePath + cFileName + ".gz", sPostRet)

		lGzDecomp := GzDecomp( oFile:cFullFilePath + cFileName + ".gz", oFile:cFullFilePath )
		if lGzDecomp
			fRename( oFile:cFullFilePath + cFileName, oFile:cFullFilePath + cFileName + ".dat" )
			fErase( oFile:cFullFilePath + cFileName + ".gz" )
			lFileOK := .T.
		endif
	endif

return iif( lFileOK, oFile:cFullFilePath + cFileName + ".dat", "" )


/*/{Protheus.doc} Commit
	Commita uma acao de download ou upload para o servidor

	@type function
	@author Vinicius Gati
	@since 21/03/2018
/*/
Method Commit(oFile) Class OFCNHPrimWsDir
	local cXml  := ''
	cXml += '<urn:cconCommit soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
	cXml += '  <Ticket     xsi:type="xsd:string">XXXXXXXTICKETXXXXXXX</Ticket>'
	cXml += '  <ServiceId  xsi:type="xsd:string">XXXXXXXSERVICEXXXXXXX</ServiceId>'
	cXml += '  <LoginId    xsi:type="xsd:string">XXXXXXXLOGINXXXXXXX</LoginId>'
	cXml += '  <DocId      xsi:type="xsd:string">'+oFile:cFileId+'</DocId>'
	cXml += '</urn:cconCommit>'
	if ! self:Enviar(self:cActCommit, cXml)
		return .f.
	endif
Return .t.

/*/{Protheus.doc} Login
	Login

	@type function
	@author Vinicius Gati
	@since 07/03/2018
/*/
Method Login() Class OFCNHPrimWsDir
	local cXml := ''

	if ! self:oWsConnect:lConectado
		if ! self:oWsConnect:Connect()
			return .f.
		endif
	endif

	cXml += "  <urn:cconLogin soapenv:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'> "
	cXml += "    <Ticket              xsi:type='xsd:string'>"+self:oWsConnect:cTicket+"</Ticket> "
	cXml += "    <ServiceId           xsi:type='xsd:string'>"+self:oWsConnect:cServiceId+"</ServiceId> "
	cXml += "    <Market              xsi:type='xsd:string'>"+self:cMarket+"</Market> "
	cXml += "    <Application         xsi:type='xsd:string'>"+self:cApplication+"</Application> "
	cXml += "    <Brand               xsi:type='xsd:string'>"+self:cBrand+"</Brand> "
	cXml += "    <Sincom              xsi:type='xsd:string'>"+self:cSincom+"</Sincom> "
	cXml += "    <CertificationSystem xsi:type='xsd:string'>"+self:cCertification+"</CertificationSystem> "
	cXml += "  </urn:cconLogin> "
	_Super:Enviar(self:cActLogin, cXml)
	self:AnalisaRetorno()
	if self:cCodeRet == '-2'
		self:oWsConnect:Renew()
	endif
	if self:cCoderet != "0"
		return .F.
	endif
	if ! Empty(self:cLoginId)
		self:lLoggedIn := .T.
	endif
Return .T.

/*/{Protheus.doc} Logout
	Fazlogout

	@type function
	@author Vinicius Gati
	@since 07/03/2018
/*/
Method Logout() Class OFCNHPrimWsDir
	local cXml := ''
	if ! self:lLoggedIn
		return .f.
	endif

	cXml += "  <urn:cconLogout soapenv:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'> "
	cXml += "    <Ticket    xsi:type='xsd:string'>XXXXXXXTICKETXXXXXXX</Ticket> "
	cXml += "    <ServiceId xsi:type='xsd:string'>XXXXXXXSERVICEXXXXXXX</ServiceId> "
	cXml += "    <LoginId   xsi:type='xsd:string'>XXXXXXXLOGINXXXXXXX</LoginId> "
	cXml += "  </urn:cconLogout> "
	if self:Enviar(self:cActLogout, cXml, .F.)
		freeobj(self:oWsConnect) // remove objeto atual de conexao pois fez logout
		self:oWsConnect := OFCNHPrimWsConnect():New(self:oUser)
		self:lLoggedIn  := .F.
		self:cLoginId   := ''
	else
		return .F.
	endif
Return .T.

/*/{Protheus.doc} Dir
	Metodo para listar os arquivos existentes na cnh
	
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method Dir(cFileName) Class OFCNHPrimWsDir
local cStatus      := '' // nao utilizado
local cDateFormat  := 'YYYY/MM/DD HH24:MI:SS'
local cXml         := ''
local cFileGroup   := ''
local cDirTypes    := 'downloadable' // downloadable:downloaded:uploaded:
local cDateStart   := ''
local cDateEnd     := ''
local lRet         := .t.
default cFileName  := '*'

	if self:lDirLoaded
		return .t.
	endif

	cXml += "  <urn:cconDir soapenv:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'> "
	cXml += "    <Ticket     xsi:type='xsd:string'>"+self:oWsConnect:cTicket+"</Ticket> "
	cXml += "    <ServiceId  xsi:type='xsd:string'>"+self:oWsConnect:cServiceId+"</ServiceId> "
	cXml += "    <LoginId    xsi:type='xsd:string'>"+self:cLoginId+"</LoginId> "
	cXml += "    <DirTypes   xsi:type='xsd:string'>"+cDirTypes+"</DirTypes> "
	cXml += "    <FileGroup  xsi:type='xsd:string'>"+cFileGroup+"</FileGroup> "
	cXml += "    <FileName   xsi:type='xsd:string'>"+cFileName+"</FileName> "
	cXml += "    <Status     xsi:type='xsd:string'>"+cStatus+"</Status> "
	cXml += "    <DateStart  xsi:type='xsd:string'>"+cDateStart+"</DateStart> "
	cXml += "    <DateEnd    xsi:type='xsd:string'>"+cDateEnd+"</DateEnd> "
	cXml += "    <DateFormat xsi:type='xsd:string'>"+cDateFormat+"</DateFormat> "
	cXml += "  </urn:cconDir> "
	if self:Enviar(self:cActDir, cXml)

		lRet := IIF(self:cCodeRet != '0', .f., .t.)

	endif
	self:lDirLoaded := .t.
Return lRet

/*/{Protheus.doc} Enviar
	Enviar que chama o enviar da classe pai, porem nesse eu tenho que ter <br>
	certeza que já foi feito o pedido do ticket ou prelogin pela classe WsConnect

	@type function
	@author Vinicius Gati
	@since 07/03/2018
/*/
Method Enviar(cAction, cXml) Class OFCNHPrimWsDir
	if ! self:lLoggedIn
		if ! self:Login()
			self:cError := "falha login"
			return .f.
		endif
	endif

	// Estes dados precisam de conexao, então faz mais sentido colocar pouco 
	// antes de enviar a conexao e coleta dos mesmos, do que ficar 
	// garantindo em cada metodo que usa se foi feita conexao e estao ok
	cXml := STRTRAN(cXml, "XXXXXXXTICKETXXXXXXX" , self:oWsConnect:cTicket)
	cXml := STRTRAN(cXml, "XXXXXXXSERVICEXXXXXXX", self:oWsConnect:cServiceId)
	cXml := STRTRAN(cXml, "XXXXXXXLOGINXXXXXXX"  , self:cLoginId)
	if ! Empty(self:cLoginId)
		// conout("login: " + self:cLoginId + " action: " + cAction)
		if self:cLoginId == "-1"
			return .f.
		endif
	endif
	_Super:Enviar(cAction, cXml)
	self:AnalisaRetorno()
	if self:cCodeRet == '-2'
		self:oWsConnect:Renew()
	endif
Return self:cCodeRet == '0'

/*/{Protheus.doc} AnalisaRetorno
	Analisa o retorno navegando e coletando informacoes

	@type function
	@author Vinicius Gati
	@since 17/03/2018
/*/
Method AnalisaRetorno() Class OFCNHPrimWsDir
	oXml := TXmlManager():New()
	xRet := oXml:Parse(self:cLastResponse)
	if xRet == .F.
		self:cError := oXML:Error()
		return .f.
	endif
	oXml:DOMChildNode()
	oXml:DOMChildNode()
	oXml:DOMChildNode()
	self:ColetaDadosRetorno(oXml)
	do while oXml:DomNextNode()
		self:ColetaDadosRetorno(oXml)
	end do
Return

/*/{Protheus.doc} ColetaDadosRetorno
	vai pegar os dados do xml retornado

	@type function
	@author Vinicius Gati
	@since 06/03/2018
/*/
Method ColetaDadosRetorno(oXml) Class OFCNHPrimWsDir
	local cTag := lower(oXml:cName)
	if cTag == "loginid"
		self:cLoginId := oXml:cText
	elseif cTag == "return"
		self:cCoderet := oXml:cText
	elseif cTag == "buffer"
		self:cLastDownload := oXml:cText
	elseif cTag == "fileinfos"
		self:ColetaArquivos(oXml)
	elseif cTag == 'docid'
		self:cDocId := oXml:cText
	endif
Return

/*/{Protheus.doc} ColetaDadosArquivos
	Coleta os arquivos da acao dir
	
	@type function
	@author Vinicius Gati
	@since 17/03/2018
/*/
Method ColetaArquivos(oXml) Class OFCNHPrimWsDir
	local oFile  := Nil
	local nItens := LEN( oXML:DOMGetChildArray() )
	self:aFiles  := {}

	if oXml:DOMChildNode()
		do while 'item' == lower(oXml:cName) .AND. Len(self:aFiles) < nItens
			oFile := OFCNHPrimWsFile():New()
			oXml:DOMChildNode()
			do while oXml:DomNextNode()
				oFile:SetAttr(oXml:cName, oXml:cText)
			end do
			if Empty(oFile:cFileId)
				return
			else
				Aadd(self:aFiles, oFile)
			endif
			oXml:DOMParentNode()
			oXml:DomNextNode()
		end do
	endif
return

/*/{Protheus.doc} FormatDate
	Formata a data conforme pedido na apostila da cconn

	@type function
	@author Vinicius Gati
	@since 09/03/2018
/*/
Method FormatDate(dData, cHora, lFim) Class OFCNHPrimWsDir
	cData    := DTOS(dData)
	cHoraFmt := IIF(lFim, '23:59:59', '00:00:00')
	if ! Empty(cHora)
		//TODO: acho que nao vai precisar pq não trabalhamos com hora mas vamos ver
	endif
Return left(cData, 4) + "/" + Substr(cData, 5, 2) + "/" + Right(dData, 2) + cHoraFmt
