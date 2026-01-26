#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#Include "TopConn.ch"
#INCLUDE "FILEIO.CH"
#include "veiw123.ch"


WSRESTFUL dms_configs DESCRIPTION STR0001 //Configurações do rest dms

	WSDATA codigo 		as STRING
	WSDATA iTestEnv 	as STRING

	WSMETHOD POST createRule  DESCRIPTION STR0002 WSSYNTAX "/dms_configs/create" 		    PATH "/dms_configs/create" //Cria congiguração do rest
	WSMETHOD GET  getRule 	  DESCRIPTION STR0003 WSSYNTAX "/dms_configs/get?{codigo}" 	PATH "/dms_configs/get" //Retorna json contendo as configurações do rest dms (codigo obrigatorio)
	WSMETHOD PUT  updateRule  DESCRIPTION STR0004 WSSYNTAX "/dms_configs/update?{codigo}"  PATH "/dms_configs/update" //Recebe json contendo atualizações do rest dms (codigo obrigatorio)

END WSRESTFUL

WSMETHOD POST createRule WSSERVICE dms_configs
	
	local oResp         := JsonObject():New()
	local oRequest 		:= JsonObject():New()
	local oConf         := JsonObject():New()
	local cParser  		:= ''
	local cPath			:= ''
	local cCode			:= 'VEIW123' //codigo de configuracao apenas do rest
	local lRet			:= .F.	

	::SetContentType("application/json; charset=utf-8")

	cParser := self:GetContent()

	oRequest:FromJson(cParser)

	if oRequest['extensions'] == nil .or. oRequest['directory'] == nil
		SetRestFault(400, encodeUTF8(STR0005)) //Arquivo de configurações inválido 
		return .F.
	endif
	
	cPath := formatPath(oRequest['directory'])
	oRequest['directory'] := cPath

	oConf['restConfig'] := oRequest
	cParser := oConf:ToJson()

	begin transaction
		dbSelectArea("VRN")
		dbSetOrder(1)
		dbSeek(xFilial("VRN") + cCode)

		if VRN->(found())
			msUnlock()
			SetRestFault(400, encodeUTF8(STR0006)) //Configuração já existente
			lRet := .F.	
		else
			if !reclock("VRN", .T.) .or. !empty(::iTestEnv)

				disarmTransaction()
				msUnlock()
				SetRestFault(400, encodeUTF8(STR0008)) //Erro ao criar configuração
				lRet := .F.

			else
				
				VRN->VRN_FILIAL := xFilial("VRN")
				VRN->VRN_CODIGO := cCode		
				VRN->VRN_CONFIG := cParser

				msUnlock()
				HandleResponse(oResp, 200, encodeUTF8(STR0007))
				::setResponse(oResp:ToJson())
				lRet := .T.

			endif
		endif

	end transaction

return lRet

WSMETHOD GET getRule WSRECEIVE codigo WSSERVICE dms_configs

	local oResp         := JsonObject():New()
	local lRet			:= .F.

	::SetContentType("application/json; charset=utf-8")

	if empty(::codigo)
		SetRestFault(400, encodeUTF8(STR0009)) //Código obrigatório
		return .F.
	endif

	dbSelectArea("VRN")
	dbSetOrder(1)
	dbSeek(xFilial("VRN") + alltrim(::codigo))
	
	if VRN->(found())
		oResp:FromJson(VRN->VRN_CONFIG)

		::setStatus(200)
		::setResponse(oResp:ToJson())
		lRet := .T.
	else
		SetRestFault(404, encodeUTF8(STR0010)) //Configuração não encontrada
		lRet := .F.
	endif

return lRet

WSMETHOD PUT updateRule  WSRECEIVE codigo WSSERVICE dms_configs

	local oResp         := JsonObject():New()
	local oSettings 	:= JsonObject():New()
	local oRequest		:= JsonObject():New()
	local lRet			:= .F.
	local cParser  		:= ''
	local cRequest      := ''
	local cDir 			:= ''

	::SetContentType("application/json; charset=utf-8")


	if empty(::codigo)
		SetRestFault(400, encodeUTF8(STR0009))
		return .F.
	endif

	dbSelectArea("VRN")
	dbSetOrder(1)
	dbSeek(xFilial("VRN") + ::codigo)

	if VRN->(found())
		
		cParser := VRN->VRN_CONFIG

		oSettings:FromJson(cParser) //configuracoes salvas no banco

		cRequest := self:GetContent() //configuracoes enviadas pelo cliente
		oRequest:FromJson(cRequest)
		
		if !empty(oRequest['extensions'])  
			oSettings['restConfig']['extensions'] 	:= oRequest['extensions']
		endif

		if !empty(oRequest['directory'])
			cDir := oRequest['directory']
			cDir := formatPath(cDir)
			oSettings['restConfig']['directory'] 	:= cDir
		endif

		if empty(oRequest['extensions']) .and. empty(oRequest['directory'])
			SetRestFault(400, encodeUTF8(STR0011)) //Nenhuma configuração enviada
			return(.F.)
		endif

		begin transaction
			if !reclock("VRN", .F.) .or. !empty(::iTestEnv)

				disarmTransaction()
				msUnlock()
				SetRestFault(400, encodeUTF8(STR0013)) //Erro ao atualizar configuração
				lRet := .F.

			else

				cParser := oSettings:ToJson()

				VRN->VRN_CONFIG := cParser

				msUnlock()
				HandleResponse(oResp, 200, encodeUTF8(STR0012)) //Configuração atualizada com sucesso
				::setStatus(200)
				::setResponse(oResp:ToJson())
				lRet := .T.


			endif
		end transaction
	else
		
		SetRestFault(404, encodeUTF8(STR0010)) //Configuração não encontrada
		lRet := .F.

	endif

return lRet

Static Function HandleResponse(oResponse, nCode, cMessage)
    oResponse['code'] := nCode
    oResponse['message'] := cMessage
Return .T.

/*/{Protheus.doc} formatPath
	Garante que a formatacao do path fornecido seja /path/
	@type  Static Function
	@author Renan Augusto
	@since 27/01/2025
	@version version
	@param cPath, character, caminho recebido para tratamento
	@return cNPath, character, caminho tratado
/*/
Static Function formatPath(cPath)
	
	local cNPath := cPath

    If !SubStr(cNPath, 1, 1) == "/"
        cNPath := "/" + cNPath
    EndIf
        
    If !SubStr(cNPath, Len(cNPath), 1) == "/"
        cNPath += "/"
    EndIf
	
Return cNPath
