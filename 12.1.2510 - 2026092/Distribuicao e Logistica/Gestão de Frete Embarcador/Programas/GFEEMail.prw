#INCLUDE 'PROTHEUS.CH'
#INCLUDE "AP5MAIL.CH"

Function GFEEmail()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEEmail()

@author
@since 5/6/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEEmail FROM LongNameClass 

	DATA lStatus
	DATA cMensagem
	DATA cBodyMail
	DATA cTextBody
	DATA cTextSummary
	DATA cTextTable
	DATA nColHeader
	DATA nColText
	DATA cHeaderTable
	DATA cColumnTable

	// ENVIO DE EMAIL
	DATA cPara
	DATA cAssunto
	DATA cBody
	DATA lMsg
	DATA aFiles

	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy(oObject)
	
	// Metodos a serem utilizados na criação do email
	METHOD addTextBody(cText)
	METHOD addTextTable(cText)
	METHOD addHeaderTable(nAlign,cText)
	METHOD addColumnTable(nAlign,cText)
	METHOD addTextSummary(cText)
	METHOD getEmail()

	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD getStatus()
	METHOD getMensagem()

	// Metodos internos, sem necessidade de utilização fora da classe
	METHOD setBodyMail(cBodyMail)
	METHOD setTextBody(cTextBody)
	METHOD setTextSummary(cTextSummary)
	METHOD setTextTable(cTextTable)
	METHOD incColHeader()
	METHOD incColText()

	METHOD getBodyMail()
	METHOD getTextBody()
	METHOD getTextSummary()
	METHOD getTextTable()
	METHOD getColHeader()
	METHOD getAlign(nAlign)
	METHOD getHeaderTable()
	METHOD getColumnTable()
	METHOD getColText()

	// ENVIO DE EMAIL
	METHOD sendEmail()

	METHOD setPara(cPara)
	METHOD setAssunto(cAssunto)
	METHOD setBody(cBody)
	METHOD setMsg(lMsg)
	METHOD setFiles(aFiles)

	METHOD getPara()
	METHOD getAssunto()
	METHOD getBody()
	METHOD getMsg()
	METHOD getFiles()

ENDCLASS

METHOD New() Class GFEEmail
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEEmail
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEEmail
	Self:cBodyMail := ""
	Self:cTextBody := ""
	Self:cTextSummary := ""
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:nColHeader	:= 0
	Self:nColText	:= 0
	Self:cHeaderTable	:= ""
	Self:cColumnTable	:= "" 
	Self:setPara("")
	Self:setAssunto("")
	Self:setBody("")
	Self:setMsg(.F.)
	Self:setFiles({})
Return

METHOD addTextBody(cText) CLASS GFEEmail
	Self:setTextBody(cText)
Return

METHOD addTextTable(cText) CLASS GFEEmail
	Self:setTextTable(cText)
Return

METHOD addHeaderTable(nAlign,cText) CLASS GFEEmail
	Local cAlign	:= Self:getAlign(nAlign)
	Self:incColHeader()
	Self:cHeaderTable += '<td align="' + cAlign + '"><b>' + cText + '</b></td>'
Return

METHOD addColumnTable(nAlign,cText) CLASS GFEEmail
	Local cAlign	:= Self:getAlign(nAlign)
	
	If Self:getColText() == 0
		Self:cColumnTable += '<tr>'
	EndIf
	Self:incColText()
	Self:cColumnTable += '<td align="' + cAlign + '">' + cText + '</td>'
	If Self:getColText() == Self:getColHeader()
		Self:cColumnTable += '</tr>'
		Self:nColtext	:= 0
	EndIf
Return

METHOD addTextSummary(cText) CLASS GFEEmail
	Self:setTextSummary(cText)
Return

METHOD getAlign(nAlign) CLASS GFEEmail
	Local cRet	:= ""
	
	if nAlign == 1
		cRet	:= "left"
	ElseIf nAlign == 2
		cRet	:= "center"
	ElseIF nAlign == 3
		cRet	:= "right"
	EndIf
Return cRet

METHOD getEmail() CLASS GFEEmail
	Local cEmail	:= ""

	cEmail:= '<html><head><style type="text/css">' + ;
							'td { font-family:verdana; font-size:12px}' + ; 
							'p  { font-family:verdana; font-size:12px}' + ; 
						'</style></head><body>'
	
	cEmail += '<p>' + Self:getTextBody() + '</p>'
	
	cEmail += '<table cellpadding="2" width="100%">'
	
	if !Empty(Self:getTextTable())
		cEmail += '<tr>' + ;
						'<td colspan="' + cValToChar(Self:GetColHeader())+ '" align="center" bgcolor="#08364D">' + ;
							'<span style="color:white;font-size:12px;"><b>' + Self:getTextTable() + '<b></span>' + ;
						'</td>' + ;
					'</tr>'
	
		cEmail +='<tr bgcolor="#EDEDED">' + ;
					Self:getHeaderTable() + ;
				'</tr>'
	
		cEmail +=Self:getColumnTable()
	EndIf

	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="center" bgcolor="#08364D"><span style="color:"#08364D""></td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="left" ></td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="left" >' + Self:getTextSummary() + '</td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="left" ></td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="left" ></td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="center"><span style="font-size:10px;"><b>TOTVS S.A. - TODOS OS DIREITOS RESERVADOS<b></span></td></tr>'
	cEmail +='<tr><td colspan="' + cValToChar(Self:GetColHeader())+ '" align="center"><span style="font-size:9px;">Mensagem automática favor não responder.</span></td></tr>'

	cEmail += '</table></body></html>'
	
Return cEmail

METHOD sendEmail() CLASS GFEEmail
	Local aRetMail
	
	aRetMail := GFEMail(Self:getPara(), Self:getAssunto(), Self:getBody(), Self:getMsg(), Self:getFiles())
	Self:setStatus(aRetMail[1])
	Self:setMensagem(aRetMail[2])
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFEEmail
	Self:lStatus := lStatus
Return
METHOD setMensagem(cMensagem) CLASS GFEEmail
	Self:cMensagem := cMensagem
Return
METHOD setBodyMail(cBodyMail) CLASS GFEEmail
	Self:cBodyMail += cBodyMail
Return
METHOD setTextBody(cTextBody) CLASS GFEEmail
	Self:cTextBody += cTextBody 
Return
METHOD setTextSummary(cTextSummary) CLASS GFEEmail
	Self:cTextSummary += cTextSummary
Return
METHOD setTextTable(cTextTable) CLASS GFEEmail
	Self:cTextTable := cTextTable
Return
METHOD incColHeader() CLASS GFEEmail
	Self:nColHeader ++
Return
METHOD incColText() CLASS GFEEmail
	Self:nColtext ++
Return
METHOD setPara(cPara) CLASS GFEEmail
	Self:cPara := cPara
Return
METHOD setAssunto(cAssunto) CLASS GFEEmail
	Self:cAssunto := cAssunto
Return
METHOD setBody(cBody) CLASS GFEEmail
	Self:cBody := cBody
Return
METHOD setMsg(lMsg) CLASS GFEEmail
	Self:lMsg := lMsg
Return
METHOD setFiles(aFiles) CLASS GFEEmail
	Self:aFiles := aFiles
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFEEmail
Return Self:lStatus

METHOD getMensagem() CLASS GFEEmail
Return Self:cMensagem

METHOD getBodyMail() CLASS GFEEmail
Return Self:cBodyMail

METHOD getTextBody() CLASS GFEEmail
Return Self:cTextBody

METHOD getTextSummary() CLASS GFEEmail
Return Self:cTextSummary

METHOD getTextTable() CLASS GFEEmail
Return Self:cTextTable

METHOD getColHeader() CLASS GFEEmail
Return Self:nColHeader

METHOD getColText() CLASS GFEEmail
Return Self:nColText

METHOD getHeaderTable() CLASS GFEEmail
Return Self:cHeaderTable

METHOD getColumnTable() CLASS GFEEmail
Return Self:cColumnTable

METHOD getPara() CLASS GFEEmail
Return Self:cPara

METHOD getAssunto() CLASS GFEEmail
Return Self:cAssunto

METHOD getBody() CLASS GFEEmail
Return Self:cBody

METHOD getMsg() CLASS GFEEmail
Return Self:lMsg

METHOD getFiles() CLASS GFEEmail
Return Self:aFiles