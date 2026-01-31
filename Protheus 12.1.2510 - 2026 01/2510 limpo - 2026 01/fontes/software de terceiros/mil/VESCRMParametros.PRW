#INCLUDE "PROTHEUS.CH"
#INCLUDE 'tbiconn.ch'

function VESCRMParametros()
return .t.

/*/{Protheus.doc} VESCRMParametros
	Classe responsavel por retornar os parametros de configuracao do SCRM Scania

	@type class
	@author Andre Luis Almeida
	@since 18/03/2019
/*/
Class VESCRMParametros
	Data oDados
	Data oArrHlp
	Data oSqlHlp
	Data oUtil

	Method New() CONSTRUCTOR
	Method DelimitaInit()
	Method DataHoraInit()
	Method VrnScrmInit()
EndClass

/*/{Protheus.doc} New
	Simples construtor

	@type function
	@author Andre Luis Almeida
	@since 18/03/2019
/*/
Method New() Class VESCRMParametros
	::oUtil   := DMS_Util():New()
	::oSqlHlp := DMS_SqlHelper():New()
	::oArrHlp := DMS_ArrayHelper():New()
return self

/*/{Protheus.doc} DelimitaInit
	Marca um ponto para separação da CargaInicial/Diario

	@type function
	@author Andre Luis Almeida
	@since 18/03/2019
/*/
Method DelimitaInit(dDtFinRef , cHrFinRef, _cCodigo, _cTagTit, _cTagData, _cTagHora) Class VESCRMParametros	
	Local oDados    := nil
	Local oObjDH    := nil 
	local cJsonConf := ''
	local nCont		:= 0

	default _cCodigo := 'SCRM_DLM'
	default _cTagTit := 'ULTIMA_EXECUCAO' 
	default _cTagData := 'DATA' 
	default _cTagHora := 'HORA' 

	oObjDH := DMS_DataContainer():New({{_cTagData, dtos(dDtFinRef) },{_cTagHora, cHrFinRef }})

	oDados := JsonObject():New()
	oDados[_cTagTit] := JsonObject():New()

	For nCont := 1 To Len(oObjDH:ADATA)
		oDados[_cTagTit][oObjDH:ADATA[nCont][1]] := oObjDH:ADATA[nCont][2]
	Next nCont
	cJsonConf := oDados:ToJson()

	dbselectArea("VRN")
	dbSetOrder(1)
	if VRN->(dbSeek(xFilial("VRN") + _cCodigo))
		if reclock("VRN", .F.)
			VRN->VRN_CONFIG := cJsonConf
			VRN->(msUnlock())
		endif
	else
		if VRN->(reclock("VRN", .T.))
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := _cCodigo
			VRN->VRN_CONFIG := cJsonConf
			VRN->(msUnlock())
		endif
	endif
return .T.

/*/{Protheus.doc} DataHoraInit
	Data/Hora em que foi delimitada a CargaInicial/Diario

	@type function
	@author Andre Luis Almeida
	@since 18/03/2019
/*/
Method DataHoraInit(_cCodigo) Class VESCRMParametros
	local oDados := nil
	Local oSCRMParametros := VESCRMParametros():New() 

	default _cCodigo := 'SCRM_DLM'

	oDados := oSCRMParametros:VrnScrmInit( _cCodigo )
Return oDados

/*/{Protheus.doc} GetWsUrl
	(Consulta parametros SCRM na tabela VRN)
	@author Emanuel Furtado
	@since 14/10/2025
/*/
Method VrnScrmInit(_cCodigo) Class VESCRMParametros
	local lExistCfg := .f.
	local oDados := nil
	local dDtExec := dDataBase - 1
	local cHrExec := substr(Time(),1,2)+substr(Time(),4,2)

	default _cCodigo := 'OFIA541' 

	dbselectArea("VRN")
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + _cCodigo))

	if lExistCfg
		oDados := JsonObject():New()
		oDados:FromJson( VRN->VRN_CONFIG )
	elseif alltrim(upper(_cCodigo)) == alltrim(upper('SCRM_DLM'))
		oDados := JsonObject():New()
		oDados:FromJson( '{ "ULTIMA_EXECUCAO": { "DATA": "' + DtoS(dDtExec) + '", "HORA": "' + Transform(cHrExec,"@R 99:99")+":00" + '" } }' )
	endif
	
Return oDados
