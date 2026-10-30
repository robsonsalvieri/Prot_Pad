#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW048.PRW
ITUP BUSINESS - TOTVS RENTAL
Envia e-mail com anexos via API
@TYPE FUNCTION
@AUTHOR Dennis Calabrez 
@SINCE 11/01/2026
/*/
WSRESTFUL LOCW048 DESCRIPTION "Metodo para enviar e-mail e anexos (se houver) - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para enviar e-mail e anexos (se houver) - Rental.</h2>" WSSYNTAX "/LOCW048"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW048
ITUP BUSINESS - TOTVS RENTAL
Envia e-mail com anexos via API
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 11/01/2026
/*/
WSMETHOD POST WSSERVICE LOCW048
Local bError    := {||}
Local cEnvLog   := ""
Local cBody     := DecodeUtf8(::GetContent())
Local aEmp      := {}
Local cCorpo    := "" 
Local cPara     := ""
Local cCc       := ""
Local cTitulo   := ""
Local aAnexos   := {}
Local nY        := 0
Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))
Local cPathBco  := ""
Local lLog      := .F.
Local lEnvio    := .F.
Private oJson   := Nil
Private cBase64 := ""
Private cRet    := ""
Private cMsg    := ""

	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )

    //caminho onde serão salvos os arquivo convertidos do base64
	cPathBco := cDirDoc + "\co" + cEmpAnt + "\shared\"		

	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")
		If lLog
			cRet := xAbreEnv1(aEmp[1],aEmp[2])

            If Empty(cRet)
                For nY := 1 To Len(oJson:anexos)
                    //Converto base64 e salvo no diretório
                    cRet    := xGAppArq(oJson:anexos[nY]:nomeArquivo,oJson:anexos[nY]:base64)

                    //adiciono no array para enviar os anexos por e-mail
                    If Empty(cRet)
                        aAdd(aAnexos,cPathBco+oJson:anexos[nY]:nomeArquivo)
                    EndIf                  
                Next

                cTitulo  := alltrim(oJson:titulo)
                cCorpo   := alltrim(oJson:corpo)
                cPara    := alltrim(oJson:para[1])
                cCc      := alltrim(oJson:cc[1])

                //Se tiver em branco o destinatário, o assunto ou o corpo do email
                If Empty(cPara) .Or. Empty(cTitulo) .Or. Empty(cCorpo)
                    cRet := "400 - "
                    cMsg := "Destinatario, Assunto ou Corpo do e-Mail vazio(s)!"
                    lRet := .F.
                EndIf                

                If Empty(cRet)
                    lEnvio := LOCW048A(cPara, cTitulo, cCorpo, aAnexos, cCc)
                Endif

            EndIf  
		Else
			cRet := "401 - "
			cMsg := "Credenciais de autenticacao invalidas ou ausentes, verifique o CNPJ da empresa Protheus"				
		EndIf	                                        
 		EndIf
	End Sequence   

	If Empty(cRet) .And. lEnvio
		cRet := "200 - "
		cMsg := "E-mail enviado com sucesso"
	EndIf       

    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'"}')) )
	
	
Return .T.

/*/{PROTHEUS.DOC} LOCW048A
ITUP BUSINESS - TOTVS RENTAL
Função para disparar e-mails
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 12/01/2026
/*/
Function LOCW048A(cPara, cTitulo, cCorpo, aAnexos, cCc)
Local aArea        := FWGetArea()
Local nAtual       := 0
Local lRet         := .T.
Local oMsg         := Nil
Local oSrv         := Nil
Local nRet         := 0
Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
Local cPass        := Alltrim(GetMV("MV_RELPSW"))
Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
Local nTimeOut     := GetMV("MV_RELTIME")
Local lUsaTLS      := .T.

Default cPara      := ""
Default cAssunto   := ""
Default cCorpo     := ""
Default aAnexos    := {}
Default lMostraLog := .F.
Default lUsaTLS    := .F.
   
   
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
   
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cCc      := cCc
        oMsg:cSubject := cTitulo
        oMsg:cBody    := cCorpo
   
        //Percorre os anexos para anexar no e-mail
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
            EndIf
        Next
        
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
   
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
   
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
   
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
   
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cRet := "511 - "
                cMsg := "Protocolo SMTP nao configurado no Protheus, verificar configuracoes de e-mail do SIGACFG"
                lRet := .F.
            EndIf
   
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cRet := "511 - "
                    cMsg := "SMTP noo conectou no Protheus, verificar configuracoes de e-mail do SIGACFG"
                    lRet := .F.
                EndIf
   
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                EndIf
   
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
            EndIf
        EndIf
    EndIf

    //Percorre os anexos para apagar os arquivos para não onerar o servidor com os arquivos
    nAtual := 0
    For nAtual := 1 To Len(aAnexos)
        //Se o arquivo existir
        If File(aAnexos[nAtual])
            FERASE(aAnexos[nAtual])  
        EndIf
    Next
     
    FWRestArea(aArea)
Return lRet
