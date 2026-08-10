#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmTokenDTA() 
Função que retorna o token de autorização do DTA
@author flavio.martins
@since 22/09/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmTokenDTA() 
Local oRest    := FwRest():New("https://dtalogsapi.azurewebsites.net")
Local aHeaders := {}
Local oRequest := JSonObject():New()
Local cToken   := ''
Local oObj	   := Nil

oRest:SetPath("/api/productKey/auth/token")

AAdd(aHeaders, "Content-Type: application/json")

oRequest['totvsId']     := "JQVHR9fdsNPHsT8W41CnpPzboT6NPIlA8oTmQnv2dvQkZhz2jDQOJq+olcnUnOjtyMwDe+si/x6/kOUl+CRgrQ=="
oRequest['projectId']   := "62f3ffd4-f804-4262-a0f5-d9171be06d20"
oRequest['user']        := "mestre"
oRequest['contingency'] := ""

oRest:SetPostParams(FwJsonSerialize(oRequest, .F., .F., .T.))

If oRest:Post(aHeaders)

    FwJsonDeserialize(oRest:GetResult(),@oObj)
    cToken := oObj:TOKEN
Endif

oRest    := Nil
oRequest := Nil

Return cToken

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmVisExtrct() 
Função que consulta o DTA Vision
@author flavio.martins
@since 22/09/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmVisExtrct(cCodProd, cRequest, oResponse)
Local lRet          := .T.
Local cToken        := ''
Local oRest         := FwRest():New("https://dtavisionapi.azurewebsites.net")
Local oObj	        := Nil
Local aHeaders      := {}
Local cBoundary     := "----WebKitFormBoundaryFbmu0bODj7UvfQEV"
Local cPostParms    := ''
Local docType       := 'pdf'
Local cFileContent  := ''
Local cFileName     := ''
Local cQuery        := ''
Local oQryTmp 		:= Nil
Local cAliasTmp 	:= Nil

Default cRequest    := ''
Default cCodProd    := ''
Default oResponse   := JSonObject():New()

dbSelectArea('SB1')
SB1->(dbSetOrder(1))

If SB1->(dbSeek(xFilial('SB1')+cCodProd))

	cQuery := " SELECT JOE.JOE_NOMARQ, JOE.JOE_EXTARQ, JOE.JOE_NOMORI FROM " + RetSqlName("JOE") + " JOE "
	cQuery += " WHERE JOE.JOE_FILIAL = ?"
	cQuery += " AND JOE.JOE_CODPRO = ? "
	cQuery += " AND JOE.D_E_L_E_T_ = ' '"

	oQryTmp := FwPreparedStatement():New(cQuery)

	oQryTmp:SetString(1, xFilial("JOE"))
	oQryTmp:SetString(2, cCodProd)

	cQuery    := oQryTmp:GetFixQuery()
	cAliasTmp := MpSysOpenQuery(cQuery)

	If Empty((cAliasTmp)->JOE_NOMARQ)
		oResponse['message'] := "Produto não possui documentos anexados"
        lRet     := .F.
    Endif
Else
	oResponse['message'] := "Código de produto não encontrado"
    lRet     := .F.
Endif

If lRet 

    cToken := FsmTokenDTA()

    oRest:SetPath("/api/dta-vision-ocr/dataExtract")

    cFileName := (cAliasTmp)->JOE_NOMARQ

    cFileContent := RetFileCnt(cFileName)

    Aadd(aHeaders, "Authorization: Bearer " + cToken)
    Aadd(aHeaders, "User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')" )
    Aadd(aHeaders, "Content-Type: multipart/form-data; boundary=" + cBoundary )
    
    cPostParms += '--' + cBoundary
    cPostParms += CRLF
    cPostParms += 'Content-Disposition: form-data; name="UserFieldsJson"'
    cPostParms += CRLF
    cPostParms += CRLF
    cPostParms += '[{ "fieldName":' + '"' + EncodeUTF8(cRequest) + '" , "fieldType": "string" }]'
    cPostParms += CRLF
    cPostParms += '--' + cBoundary
    cPostParms += CRLF
    cPostParms += 'Content-Disposition: form-data; name="file"; filename="'+cFileName+'"'
    cPostParms += CRLF
    cPostParms += 'Content-Type: application/' + docType
    cPostParms += CRLF
    cPostParms += CRLF
    cPostParms += CRLF
    cPostParms += cFileContent + CRLF
    cPostParms += '--' + cBoundary + '--'

    oRest:SetPostParams(cPostParms)

    If oRest:Post(aHeaders)

        FwJsonDeserialize(oRest:GetResult(),@oObj)
        oResponse:FromJSON(oObj:JSONDOC)
    Endif

    oRest     := Nil

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFileCnt() 
Função que retorna o conteudo de um determinado documento para envio na API DTA Vision
@author flavio.martins
@since 22/09/2025
@version 1.0
*/
//-------------------------------------------------------------------
Static Function RetFileCnt(cFileName)
Local cContent  := ''
Local cBuffer   := ""
Local nHandle   := 0
Local nBytes    := 0
Local nFileSize := 0
Local cPath     := '\FSM\DOCUMENTOSPRODUTO\'

Default cFileName := ''

nHandle := FOPEN(cPath+cFileName) 

If nHandle > -1
    nFileSize := FSeek(nHandle, 0, FS_END)
    FSeek(nHandle,0,FS_SET)
    While (nBytes := FREAD(nHandle, @cBuffer, nFileSize)) > 0 
        cContent += cBuffer
    EndDo

    FCLOSE(nHandle)

EndIf

Return  cContent
