#INCLUDE "plsmvld.ch"
#include "TOPCONN.CH"
#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSNotifica
Funcao que faz o envio de alertas via e-mail, portal ou whatsapp
@author Nicole Luna
@since 19/06/2024
@version P12

@param cCodBQ7, string, codigo do processo que enviara o alerta customizado (BQ7_CODIGO) - obrigatorio
@param cChave, string, codigo prestador *ou* matricula beneficiario - obrigatorio
/*/
//-------------------------------------------------------------------

Function PLSNotifica(cCodBQ7, cChave, cParam, cEmail)
    Local cEndpoint      := ""
    Local nX             := 0
    Local aHeader        := {}
    Local aDadHeader     := {}
    Local oRestClient    := NIL
    Local lSuccess       := .T.
    Local oJsonBody      := JsonObject():new()
    Local cRetCode       := ""
    Local cResponse      := ""
    Local nMaxTry 	     := 3
    Local nTry           := 1
    Local lSendAgain     := .T.
    Local cDtAtual       := DDATABASE
    Local cIdentity      := ""
    Local oPLMailMsg     := nil
    Local cErroMail      := ""
    Local cNumBPL        := ""
    Local aRet           := {}
    Local cHtml          := nil
    Local cUrl	         := getNewPar("MV_PLTURL","")
    Local cPath	         := getNewPar("MV_PLTPTH","")
    Local cOpeId	     := ""
    Local cToken	     := getNewPar("MV_PLTTKN","")
    Local cWppTel        := ""
    Local cWppNom        := ""
    Local aDecoded       := AESDecrypt( 2, alltrim(getNewPar("MV_PLTOP","")), "46b5e59b2fd342bf8fee10c561958725", "d89a8633204d02f9" ) 
    Default cCodBQ7      := ""
    Default cChave       := ""
    Default cParam       := ""
    Default cEmail       := ""
    
    if !empty(cCodBQ7) .AND. !empty(cChave)
        If Empty(cEmail)
            if Len(cChave) == 6 //Codigo do prestador, buscar email na BAU
                cIdentity := " PRESTADOR "
                BAU->(DbSetOrder(1))
                if BAU->(MsSeek(xFilial("BAU") + cChave))
                    cEmail := alltrim(BAU->BAU_EMAIL)
                    cWppTel := alltrim(BAU->BAU_WPP)
                    cWppNom := alltrim(BAU->BAU_NOME)
                endif
            else //Matricula do beneficiario, buscar email na BA1
                cIdentity := " BENEFICIARIO "
                BA1->(DbSetOrder(2))	
                if BA1->(MsSeek(xFilial("BA1") + cChave))
                    cEmail := alltrim(BA1->BA1_EMAIL)
                    cWppTel := alltrim(BA1->BA1_WPP)
                    cWppNom := alltrim(BA1->BA1_NOMUSR)
                endif
            endif
        EndIf

        PLSLogNot("INICIANDO ENVIO DO ALERTA " + cCodBQ7 + " PARA " + cIdentity + cChave)

        //Posiciona o registro na BQ7
        BQ7->(DbSetOrder(1))
        if BQ7->(MsSeek(xFilial("BQ7")+cCodBQ7)) 

            PLSLogNot("Alerta informado encontrado, o envio dos alertas sera realizado.")

            //Realiza o envio de notificacoes via portais 
            if BQ7->BQ7_NOTIF == '1'

                if BQ7->BQ7_TIPNOT == '1' //1 = Portal Autorizador
                    cEndpoint := GetnewPar('MV_PHATURL', '')

                    if !empty(cEndpoint)
                        aAdd(aHeader,'Content-Type: application/json')
                        aDadHeader := PLGDadHead()

                        for nX := 1 to len(aDadHeader)
                            aAdd(aHeader, aDadHeader[nX,1] + ": " + aDadHeader[nX,2])
                        next

                        cHtml := PLEditHTML(alltrim(BQ7->BQ7_TXTNOT))

                        PLSLogNot("INICIANDO PROCESSO DE ENVIO DE ALERTA PARA O PORTAL AUTORIZADOR ")
                        PLSLogNot("Authorization: " + aDadHeader[1,2] + ",IdTenant: " + aDadHeader[2,2] + ",TenantName: " + aDadHeader[3,2])
                        PLSLogNot("Conteudo da Mensagem: " + cHtml)

                        oJsonBody["userID"]      := "1"
                        oJsonBody["type"]        := "0"
                        oJsonBody["message"]     := cHtml
                        oJsonBody["filter"]      := alltrim(cChave)
                        oJsonBody["title"]       := alltrim(BQ7->BQ7_TITNOT)
                        oJsonBody["expireDate"]  := DTOS(cDtAtual + 90) //3 meses para expirar

                        PLSLogNot("Json de envio: " + oJsonBody:toJson())

                        while lSendAgain .and. nTry <= nMaxTry
                            oRestClient := FWRest():New(cEndPoint + "v1/notification")
                            oRestClient:setPath("")
                            oRestClient:SetPostParams(oJsonBody:toJson())

                            lSuccess := oRestClient:Post(aHeader)
                            cRetCode := oRestClient:getHttpCode()
                            lSuccess := lSuccess .OR. (cRetCode >= "200" .AND. cRetCode <= "299")

                            if  lSuccess
                                cResponse := oRestClient:GetResult()
                                lSendAgain := .F.
                                PLSLogNot("Sucesso ao enviar alerta ao Portal Autorizador - Resposta: " + cResponse)
                            else
                                 if cRetCode == "404" //NotFound
                                    lSendAgain := .F.
                                else
                                    lSendAgain := .T.
                                endIf
                                PLSLogNot("Erro ao enviar alerta ao Portal Autorizador: " + oRestClient:getLastError())
                            endif
                            nTry++
                            sleep(500)
                        enddo
                    else
                        PLSLogNot("Nao sera possivel enviar alerta via portal autorizador, MV_PHATURL nao configurado.")
                    endif
                elseif BQ7->BQ7_TIPNOT == '2' //2 = Portal Beneficiario
                    cHtml := PLEditHTML(alltrim(BQ7->BQ7_TXTNOT),cParam)

                    PLSLogNot("INICIANDO PROCESSO DE ENVIO DE ALERTA PARA O PORTAL BENEFICIARIO ")
                    PLSLogNot("Conteudo da Mensagem: " + cHtml)              
    
                    cNumBPL := PLSA625Cd("BPL_CODIGO","BPL",1,"D_E_L_E_T_"," ")

                    DbSelectArea("BPL")
                    RecLock("BPL", .T.)	
                    BPL->BPL_FILIAL := xFilial("BPL")	
                    BPL->BPL_CODIGO := cNumBPL
                    BPL->BPL_TITULO := alltrim(BQ7->BQ7_TITNOT)
                    BPL->BPL_VIGINI := cDtAtual 
                    BPL->BPL_VIGFIN := cDtAtual + 90 //3 meses para expirar
                    BPL->BPL_CODDEP := ""
                    BPL->BPL_NOTICI := cHtml
                    BPL->BPL_TIPUSU := "2"
                    BPL->BPL_CHAVE  := alltrim(cChave)
                    MsUnLock() 
                endif 
            else 
                PLSLogNot("Alerta via portal nao sera enviado, esta configurado para nao enviar.")
            endif

            if BQ7->BQ7_EMAIL == '1'
                if !empty(cEmail)
                    PLSLogNot("INICIANDO PROCESSO DE ENVIO DE ALERTA VIA E-MAIL")
                    aRet  := PLSetImg(alltrim(BQ7->BQ7_TXTEMA))
                    cHtml := PLEditHTML(aRet[2],cParam)
                    oPLMailMsg := PLMailMessage():New()
                    If oPLMailMsg:Connect()
		            	oPLMailMsg:SetEmailTo(cEmail)
		            	oPLMailMsg:SetSubject(alltrim(BQ7->BQ7_TITNOT))
		            	oPLMailMsg:SetMessage(cHtml)
                        oPLMailMsg:SetImg(aRet[1])
		            	oPLMailMsg:SendEmail()
		            EndIf
                    cErroMail := oPLMailMsg:GetMessageError()

			        if(!empty(cErroMail))
			        	PLSLogNot("Erro ao enviar alerta para o e-mail " + cEmail + ": " + cErroMail)
			        else 
			        	PLSLogNot("Sucesso ao enviar alerta para o e-mail " + cEmail + ". Mensagem do e-mail: " + cHtml)
			        endif
                else
                
                    PLSLogNot("Nao sera possivel enviar email, email nao informado para ")
                endif
            else
                PLSLogNot("Alerta via e-mail nao sera enviado, esta configurado para nao enviar.")
            endif

            if BQ7->BQ7_WPP == '1' .and. !empty(cWppTel) .and.  !empty(cWppNom) // verificamos se esta habilitado a notificação e se temos o numero para ser enviado a notificação 
                cOpeId   := aDecoded [2]
                if  !empty(BQ7->BQ7_TEMPLA) .and. !empty(cUrl) .and. !empty(cPath) .and. !empty(cOpeId) .and. !empty(cToken) // verificamos se as parametrizações necessarias estao ok

                    oJsonBody := nil
                    oRestClient := nil
                    aHeader := {}

                    PLSLogNot("INICIANDO PROCESSO DE ENVIO DE ALERTA VIA WHATSAPP")

                    oRestClient := FWRest():New(cUrl)
		            oRestClient:setPath(cPath)

                    aadd(aHeader, 'Authorization: Bearer '+ cToken)
		            aadd(aHeader, 'Content-Type: application/json')	
                    
                    oJsonBody := JsonObject():New()
                    oJsonBody["template_message_id"] := alltrim(BQ7->BQ7_TEMPLA)
                    oJsonBody["recipient_number"] := alltrim(cWppTel)
                    oJsonBody["country_code"] := Substr(alltrim(cWppTel),0,2)
                    oJsonBody["sent_by"] := "bot"
                    oJsonBody["operator_id"] := alltrim(cOpeId)
                    oJsonBody["variables"] := {}
                    aadd(oJsonBody["variables"] , alltrim(cWppNom))
                    aadd(oJsonBody["variables"] , alltrim(tallosValue(cCodBQ7, cParam)))

                    oRestClient:SetPostParams(oJsonBody:toJson())
                    oRestClient:SetChkStatus(.F.)

                    if oRestClient:Post(aHeader)
                        cError := ""
                        nStatus := HTTPGetStatus(@cError)

                        if nStatus >= 200 .And. nStatus <= 299
                            if !empty(oRestClient:getResult())
			        	        PLSLogNot("Sucesso ao enviar alerta de WHATSAPP para o numero: " + cWppTel)
                            endif
                        else 
                            PLSLogNot("Ocorreu um erro ao enviar mensagem: " + oRestClient:cResult)
                        endif
                    else 
                        PLSLogNot("Ocorreu um erro ao se comunicar com a api da Tallos")
                    endif 
                else
                    PLSLogNot("Verifique se o campo BQ7_TEMPLA está preenchido e verifique se os parametros: MV_TURL, MV_TPATH, MV_TOPID, MV_TTOKEN estão configurados.")
                endif
            else
                PLSLogNot("Alerta via WHATSAPP nao sera enviado, esta configurado para nao enviar.")
            endif

            If( existBlock( "PLNOTIF" ) )
		        execBlock( "PLNOTIF",.F.,.F.,{ cParam } )
	        EndIf
        else
            PLSLogNot("Alerta informado nao foi encontrado: " + cCodBQ7)
        endif
    else
        PLSLogNot("Nao foi possivel enviar o alerta, verificar se os parametros cCodBQ7 e cChave foram informados.")
    endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSLogNot
Monta o arquivo de log da funcao PLSNotifica

@author  Nicole Luna
@version P12
@since    19/06/2024
/*/
//-------------------------------------------------------------------
Function PLSLogNot(cMsg, lDateTime, cLogFile)

    Default cMsg := ""
    Default cLogFile := "pls_notifica.log"    

    PlsPtuLog("[" + AllTrim(Str(ThreadID())) + "]["+Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + " - " + Time()+"] " + cMsg, cLogFile)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLEditHTML

@author  Nicole Luna
@version P12
@since    19/06/2024
/*/
//-------------------------------------------------------------------
Function PLEditHTML(cHtml,cParam)
    cHtml := PLSetCSS(cHtml)
    cHtml := PLUpdAlias(cHtml,cParam)
return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSetImg
Busca imagens no HTML informado, retorna SRC das tags imgs e substitui por "cid:nome_da_imagem" 

@author  Nicole Luna
@version P12
@since    25/06/2024
/*/
//-------------------------------------------------------------------
Function PLSetImg(cHtml)
    Local aSrcs         := Array(0)
    Local nStartPos     := 1
    Local nEndPos       := 0
    Local cHtmlMod      := cHtml
    Local cTag          := ""
    Local cSrc          := ""
    Local nSrcStart     := 0
    Local nSrcEnd       := 0
    Local cFileName     := ""
    Local cPadrao       := ''

    if BQ7->(fieldpos("BQ7_LAYPAD")) == 0 .or. BQ7->BQ7_LAYPAD <> '0'
        
        cPadrao += '<!DOCTYPE html>'
        cPadrao += '<html lang="en">'
        cPadrao += '   <head>'
        cPadrao += '      <meta charset="UTF-8">'
        cPadrao += '      <meta name="viewport" content="width=device-width, initial-scale=1.0">'
        cPadrao += '      <link rel="stylesheet" href="notificacoes-pls/style.css">'
        cPadrao += '   </head>'
        cPadrao += '   <body>'
        cPadrao += '      <div class="container">'
        cPadrao += '      <table>'
        cPadrao += '         <tbody>'
        cPadrao += '            <tr>'
        cPadrao += '               <td>'
        cPadrao += '                  <center>'
        cPadrao += '                     <table>'
        cPadrao += '                        <tbody>'
        cPadrao += '                           <tr>'
        cPadrao += '                              <td>'
        cPadrao += '                                 <div>'
        cPadrao += '									<img src="notificacoes-pls/logo.jpeg" title="logo" class="img-logo"> '
        cPadrao += cHtml
        cPadrao += '                                 </div>'
        cPadrao += '                              </td>'
        cPadrao += '                           </tr>'
        cPadrao += '                        </tbody>'
        cPadrao += '                     </table>'
        cPadrao += '                  </center>'
        cPadrao += '               </td>'
        cPadrao += '            </tr>'
        cPadrao += '         </tbody>'
        cPadrao += '      </table>'
        cPadrao += '      <div>'
        cPadrao += '   </body>'
        cPadrao += '</html>'
        cHtmlMod := cPadrao
    endif
    
    Do While (nStartPos := At("<img", cHtmlMod, nEndPos + 1)) > 0
        nEndPos := At(">", cHtmlMod, nStartPos)
        If nEndPos <> 0
            cTag := SubStr(cHtmlMod, nStartPos, nEndPos - nStartPos + 1)
            nSrcStart := At("src=", cTag)
            If nSrcStart > 0
                nSrcStart += Len("src=")
                If SubStr(cTag, nSrcStart, 1) == '"' .OR. SubStr(cTag, nSrcStart, 1) == "'"
                    nSrcEnd := At(SubStr(cTag, nSrcStart, 1), cTag, nSrcStart + 1)
                    cSrc := SubStr(cTag, nSrcStart + 1, nSrcEnd - nSrcStart - 1)
                    AAdd(aSrcs, cSrc)
                    cFileName := SubStr(cSrc, Rat("/", cSrc) + 1)
                    cTag := Stuff(cTag, nSrcStart + 1, nSrcEnd - nSrcStart - 1, "cid:" + cFileName)
                    cHtmlMod := Stuff(cHtmlMod, nStartPos, nEndPos - nStartPos + 1, cTag)
                    nEndPos := nStartPos + Len(cTag) - 1
                EndIf
            EndIf
        EndIf
    EndDo
    
Return { aSrcs, cHtmlMod }

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSetCSS
Lê o arquivo css informado na tag <link rel="stylesheet" href=""> e injeta no html na tag <style> 

@author  Nicole Luna
@version P12
@since    25/06/2024
/*/
//-------------------------------------------------------------------
Function PLSetCSS(cHtml)
Local oFile  := Nil
    Local cStyle := ""
    Local nStartPos := 0
    Local nEndPos := 0
    Local cHref := ""
    Local nHrefStart := 0
    Local nHrefEnd := 0
    Local cUpdatedHtml := ""
    Local cLinkTag := ""
    
    nStartPos := At('<link rel="stylesheet"', cHtml)
    If nStartPos > 0
        nEndPos := At(">", cHtml, nStartPos) + 1 // Inclui o '>'
        If nEndPos > 0
            // Tag <link> completa
            cLinkTag := SubStr(cHtml, nStartPos, nEndPos - nStartPos)
            
            // Valor do atributo href dentro da tag <link>
            nHrefStart := At('href=', cHtml, nStartPos)
            If nHrefStart > 0 .And. nHrefStart < nEndPos
                nHrefStart += Len('href=')
                If SubStr(cHtml, nHrefStart, 1) == '"' .OR. SubStr(cHtml, nHrefStart, 1) == "'"
                    nHrefEnd := At(SubStr(cHtml, nHrefStart, 1), cHtml, nHrefStart + 1)
                    cHref := SubStr(cHtml, nHrefStart + 1, nHrefEnd - nHrefStart - 1)
                    
                    // Substitui todas as barras '/' por barras invertidas '\'
                    cHref := StrTran(cHref, "/", "\")
                    
                    // Le o arquivo CSS usando o caminho extraido
                    oFile := FWFileReader():New(cHref)
                    If (oFile:Open())
                        While (oFile:hasLine())
                            cStyle += oFile:GetLine()
                        EndDo
                        oFile:Close()
                    EndIf
                EndIf
            EndIf
            
            // Remove a tag <link> do HTML
            cHtml := StrTran(cHtml, cLinkTag, "")
        EndIf
    EndIf
    
    // Encontra a tag <head>
    nStartPos := At('<head>', cHtml)
    If nStartPos > 0
        nEndPos := nStartPos + Len('<head>')
        // Insere a tag <style> dentro do <head>
        cUpdatedHtml := SubStr(cHtml, 1, nEndPos) + CRLF + '<style type="text/css">' + CRLF + cStyle + CRLF + '</style>' + CRLF + SubStr(cHtml, nEndPos + 1)
    Else
        cUpdatedHtml := cHtml
    EndIf

Return cUpdatedHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PLUpdAlias
Macroexecuta as variaveis informadas [%ALIAS->CAMPO%] 

@author  Nicole Luna
@version P12
@since    26/06/2024
/*/
//-------------------------------------------------------------------
Function PLUpdAlias(cHtml,cParam)
    Local nStartPos     := 0
    Local nEndPos       := 0
    Local cValor        := ""
    Local cMacro        := ""
    Default cParam      := ''

    // Primeira ocorrência de [% no HTML
    nStartPos := At("[%", cHtml)

    While nStartPos > 0
        // Fechamento %]
        nEndPos := At("%]", cHtml, nStartPos)
        
        If nEndPos > 0
            // Conteúdo 
            cMacro := SubStr(cHtml, nStartPos + 2, nEndPos - nStartPos - 2)
            
            If !empty(cMacro)               
                cValor := &(cMacro)
            endif

            Do Case
                Case ValType(cValor) == "D"
                    cValor := DToC(cValor)
                Case ValType(cValor) == "N"
                    cValor := LTrim(Str(cValor))
                Case ValType(cValor) == "L"
                    cValor := If(cValor, "'True'", "'False'")
            endcase

            cValor := alltrim(cvaltochar(cValor))

            // Substituir a macro no HTML pelo valor
            cHtml := Stuff(cHtml, nStartPos, (nEndPos + 2) - nStartPos, cValor)

            cValor := ''
        EndIf
        
        // Procurar a próxima ocorrência de [% no HTML
        nStartPos := At("[%", cHtml, nStartPos + 1)
    EndDo

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} tallosValue
000001 - auditoria 
000002 - faturamento

@author  Daniel Silva
@version P12
@since    19/09/2024
/*/
//-------------------------------------------------------------------
static function tallosValue(cCodigo, cParam)

    local cValor := ""
    Default cCodigo := ""
    Default cParam := ""

    if (cCodigo == "000001")
        cValor := &('B53->B53_NUMGUI')
    elseif (cCodigo == "000002")
        cValor := &('BCI->BCI_CODPEG')
    elseif (cCodigo == "000003") .AND. !empty(cParam)
        cValor := cParam
    elseif !empty(cParam)
        cValor := cParam
    endif 

Return cValor
