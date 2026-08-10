#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "VEIW122.CH"

WSRESTFUL dms_files_handler DESCRIPTION STR0011 //WebService para lidar com envio e recebimento de arquivos

	WSDATA fileNAme as STRING

	WSMETHOD POST sendFile DESCRIPTION STR0008 WSSYNTAX "/dms_files_handler" PATH "/dms_files_handler" //Recebe arquivo via REST
	WSMETHOD GET getFile DESCRIPTION STR0009 WSSYNTAX "/dms_files_handler/download?{fileName}" PATH "/dms_files_handler/download" //Envia um arquivo via REST
	WSMETHOD DELETE deleteFile DESCRIPTION STR0010 WSSYNTAX "/dms_files_handler/delete?{fileName}" PATH "/dms_files_handler/delete" //Apaga um arquivo via REST

END WSRESTFUL

/*/{Protheus.doc} sendFile
	EndPoint Post para api REST responsável por receber um arquivo do cliente e salva-lo no servidor.

	@type function
	@author Renan Migliaris
	@since 21/01/2025
/*/
WSMETHOD POST sendFile WSSERVICE dms_files_handler

	local oWriter		:= nil
	local oResp 		:= nil
	local oConfig		:= nil
	local cFilCon		:= ''
	local cHeader		:= ''
	local cCont			:= ''
	local cBound        := ''
	local cFilNam		:= ''
	local cOriNam		:= ''
	local cExt		  	:= ''
	local cDir		  	:= ''
	local nBStart		:= 0
	local nFStart		:= 0
	local nCStart		:= 0 //inicio do conteudo do arquivo
	local nCEnd			:= 0 //fim do conteudo do arquivo
	local nFEnd			:= 0
	local nLDot			:= 0
	local aExt  		:= {}
	local lRet  		:= .F.

	::SetContentType("multipart/form-data")

	oConfig := JsonObject():New()
	oConfig := getRestConfig()

	cDir := oConfig['restConfig']['directory']
	aExt := oConfig['restConfig']['extensions']

	//Recuperando o boundary do binario (no header do request)
	cHeader 	:= self:GetHeader("Content-Type")
	nBStart 	:= At("boundary=", cHeader) + 9
	cBound 		:= alltrim(Substr(cHeader, nBStart))

	//Recuperando o nome do arquivo a ser salvo (no cabecalho do request recebido via body)
	cCont 		:= self:GetContent()
	nFStart 	:= At('filename="', cCont) + 10
	nFEnd		:= At('"', cCont, nFStart) - 1
	cFilNam		:= Substr(cCont, nFStart, nFEnd - nFStart + 1)
	nLDot       := rat('.', cFilNam)
	cExt 	  	:= Substr(cFilNam, nLDot)

	//verificar dentro do array de extensões se é uma extensão permitida
	if aScan(aExt, cExt) == 0 
		SetRestFault(400, STR0012) //Extensao de arquivo nao permitida
		return(.F.)
	endif

	// Recuperando o conteúdo do arquivo
	nCStart := At('filename="', cCont) + 10
	nFEnd := At('"', cCont, nCStart) - 1
	cFilNam := Substr(cCont, nCStart, nFEnd - nCStart + 1)
	cOriNam := cFilNam

	// Posicionar o início do conteúdo do arquivo
	nCStart := At('Content-Type:', cCont, nFEnd)
	nCStart := At(chr(10), cCont, nCStart) + 3

	// Posicionar o fim do conteúdo do arquivo
	nCEnd := At("--" + cBound, cCont, nCStart) - 1

	// Extração do conteúdo
	cFilCon := Substr(cCont, nCStart, nCEnd - nCStart)

	// Renomeando o arquivo
	cFilNam := RandByTime() + RandByDate() + cExt
	
	if !ExistDir(cDir)
		MakeDir(cDir)
	endif

	oWriter := FwFileWriter():New(cDir + cFilNam, .T.)

	if !oWriter:Create()
		SetRestFault(400, STR0001) //Ocorreu um erro durante a criação do arquivo
		lRet := .F.
	else
		oWriter:Write(cFilCon)
		oWriter:Close()

		oResp := JsonObject():New()
		oResp['fileName'	] 	:= cFilNam
		oResp['originalName' ]	:= cOriNam	
		HandleResponse(oResp, 200, STR0002) //Arquivo salvo com sucesso!
		::setResponse(oResp:ToJson())
		lRet := .T.
	endif

return lRet

/*/{Protheus.doc} sendFile
	EndPoint GET para api REST responsável por atraves de um nome de arquivo recupera-lo do servidor e enviar para o cliente.

	@type function
	@author Renan Migliaris
	@since 21/01/2025
/*/
WSMETHOD GET getFile WSRECEIVE fileName WSSERVICE dms_files_handler
	
	local oFile			:= nil
	local oConfig		:= nil
	local cFile         := ''
	local cPath 	   	:= ''
	local lRet 			:= .T.

	oConfig := JsonObject():New()
	oConfig := getRestConfig()

	cPath := oConfig['restConfig']['directory']

	if Empty(self:fileName) 
		SetRestFault(400, STR0003)  //Não foi informado o nome do arquivo!
		return(.F.)
	endif

	oFile := FWFileReader():New(cPath + self:fileName)

	if (oFile:open())
		
		cFile := oFile:FullRead()
		oFile:Close()
		::SetHeader("Content-Disposition", "attachment; filename=" + '"' + self:fileName + '"')
		::SetHeader("Content-Type", getContentType(self:fileName))
		::SetResponse(cFile)

		lRet := .T.
	else 
		SetRestFault(404, STR0004) //Não foi possível recuperar o arquivo
		lRet := .F.
	endif

return lRet 

/*/{Protheus.doc} sendFile
	EndPoint GET para api REST responsável por atraves de um nome de arquivo verificar a existencia desse e deleta-lo.

	@type function
	@author Renan Migliaris
	@since 21/01/2025
/*/
WSMETHOD DELETE deleteFile WSRECEIVE fileName WSSERVICE dms_files_handler

	local oResp 		:= JsonObject():New()
	local oConfig		:= JsonObject():New()
	local cPath			:= ''
	local cFullNam		:= ''
	local nHandle		:= 0
	local lRet			:= .F.
	
	oConfig := getRestConfig()

	cPath := oConfig['restConfig']['directory']

	if Empty(self:fileName)
		SetRestFault(400, STR0005) //Favor informar o nome do arquivo
		return(.F.)
	endif

	cFullNam := cPath + self:fileName	

	nHandle := FErase(cFullNam, , .T.) 

	if nHandle == 0
		HandleResponse(oResp, 200, STR0006) //Arquivo deletado com sucesso!
		::setResponse(oResp:ToJson())
		lRet := .T.
	else	
		SetRestFault(404, STR0007) // Não foi encontrado um arquivo com o nome informado
		lRet := .F.
	endif

return lRet

Static Function HandleResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage
Return .T.

/*/{Protheus.doc} getContentType
	Visa identificar devidamente o tipo de arquivo para o setup do content-type
	@type  Static Function
	@author Renan Migliaris
	@version version
	@param fileName, character, nome do arquivo (inclusive com sua extensao)
	@return cCont, character, string ja atualizada para o content-type
	@see https://developer.mozilla.org/en-US/docs/Web/HTTP/MIME_types/Common_types
/*/
Static Function getContentType(fileName)
	
	local cCont 		:= ''
	local cExt			:= ''
	local nLDot 		:= 0

	nLDot := rat('.', fileName)
	cExt := Lower(Substr(fileName, nLDot))

	Do Case
		// Documentos
		Case cExt == '.pdf'
			cCont := 'application/pdf'
		Case cExt == '.doc'
			cCont := 'application/msword'
		Case cExt == '.docx'
			cCont := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
		Case cExt == '.xls'
			cCont := 'application/vnd.ms-excel'
		Case cExt == '.xlsx'
			cCont := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
		Case cExt == '.ppt'
			cCont := 'application/vnd.ms-powerpoint'
		Case cExt == '.pptx'
			cCont := 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
		Case cExt == '.txt'
			cCont := 'text/plain'

		// Compactação
		Case cExt == '.zip'
			cCont := 'application/zip'
		Case cExt == '.rar'
			cCont := 'application/x-rar-compressed'

		// Imagens
		Case cExt == '.jpg' .or. cExt == '.jpeg'
			cCont := 'image/jpeg'
		Case cExt == '.png'
			cCont := 'image/png'
		Case cExt == '.gif'
			cCont := 'image/gif'
		Case cExt == '.bmp'
			cCont := 'image/bmp'
		Case cExt == '.tiff'
			cCont := 'image/tiff'
		Case cExt == '.svg'
			cCont := 'image/svg+xml'
		Case cExt == '.ico'
			cCont := 'image/vnd.microsoft.icon'
		Case cExt == '.webp'
			cCont := 'image/webp'
		Case cExt == '.heif'
			cCont := 'image/heif'
		Case cExt == '.heic'
			cCont := 'image/heic'
		Case cExt == '.avif'
			cCont := 'image/avif'

		// Áudio
		Case cExt == '.mp3'
			cCont := 'audio/mpeg'
		Case cExt == '.wav'
			cCont := 'audio/wav'

		// Vídeos
		Case cExt == '.mp4'
			cCont := 'video/mp4'
		Case cExt == '.avi'
			cCont := 'video/x-msvideo'
		Case cExt == '.mpeg' .or. cExt == '.mpg'
			cCont := 'video/mpeg'
		Case cExt == '.mov'
			cCont := 'video/quicktime'
		Case cExt == '.wmv'
			cCont := 'video/x-ms-wmv'
		Case cExt == '.flv'
			cCont := 'video/x-flv'
		Case cExt == '.webm'
			cCont := 'video/webm'
		Case cExt == '.mkv'
			cCont := 'video/x-matroska'
		Case cExt == '.ogv'
			cCont := 'video/ogg'
		Case cExt == '.3gp'
			cCont := 'video/3gpp'
		Case cExt == '.3g2'
			cCont := 'video/3gpp2'

		// Padrão
		Otherwise
			cCont := 'application/octet-stream'
	EndCase

Return cCont

/*/{Protheus.doc} getRestConfig
	Recupera informações de configuração do rest
	@type  Static Function
	@author Renan Migliaris
	@since 27/01/2025
/*/
Static Function getRestConfig

	local oRet 		:= JsonObject():new()
	local cParser 	:= ''

	dbSelectArea("VRN")
	dbSetOrder(1)
	dbSeek(xFilial("VRN") + "VEIW123")

	if VRN->(Found())
		cParser := VRN->VRN_CONFIG
		oRet:FromJson(cParser)
	endif
	
	dbCloseArea()
Return oRet
