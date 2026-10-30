#INCLUDE "LOCA059.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

FUNCTION LOCX059A(_CREMET, _CDEST, _CCC, _CASSUNTO, CBODY, _CANEXO, _CCCO, _LMSG)

Local lEnvioOK 		:= .F.	// Variavel que verifica se foi conectado OK
Local lMailAuth		:= SuperGetMv("MV_RELAUTH",,.F.) // Servidor de email necessita autenticação
Local cMailServer	:= SuperGetMv("MV_RELSERV",, "") // Nome do servidor de email
Local cMailConta	:= SuperGetMV("MV_RELACNT",, "") // Conta no envio de emails
Local cMailSenha	:= SuperGetMV("MV_RELPSW" ,, "") // Senha da conta
Local lUseSSL		:= SuperGetMV("MV_RELSSL" ,,.F.) // utiliza conexão segura
Local lUseTLS		:= SuperGetMV("MV_RELTLS" ,,.F.) // SMTP com conexão segura
Local oMail			:= NIL
Local nErro			:= 0
Local nArqErro		:= 0
Local cMsgErro		:= ""
Local cUsuario		:= SubStr(cMailConta,1,At("@",cMailConta)-1)
Local cFrom         := SuperGetMV("MV_RELFROM",,"" ) // email remetente
Local oMessage		:= NIL
Local nPort			:= 0
Local nPortIMAP		:= 0
Local nAt			:= 0
Local cServer		:= ""
Local nX			:= 0
Local lErroFile	    := .F.

Local cSubject		:= _CASSUNTO
Local cMensagem		:= CBODY
Local cEmail 		:= _CDEST

DEFAULT aFiles 		:= {}
DEFAULT lMensagem 	:= .T.
DEFAULT cError		:= ""

If (!Empty(cMailServer)) .AND. (!Empty(cMailConta)) .AND. (!Empty(cMailSenha))
	
	oMail	:= TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	nAt	:=  At(':' , cMailServer)
	
	// Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do método oMail:Init().
	// A documentacao de TMailManager pode ser consultada por aqui : http://tdn.totvs.com/x/moJXBQ
	If ( nAt > 0 )
		cServer		:= SubStr(cMailServer , 1 , (nAt - 1) )
		nPort		:= Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
	Else
		cServer		:= cMailServer
	EndIf
	
	oMail:Init(cServer, cServer, cMailConta, cMailSenha , nPortIMAP , nPort)	
	//Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
	
	nErro := oMail:SMTPConnect()
		
	If ( nErro == 0 )

		If lMailAuth

			// try with account and pass
			nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
			If nErro != 0
				// try with user and pass
//				nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
//				If nErro != 0
//				    If lMensagem 
//						If cError <> "S"
//							Aviso(OemToAnsi("Atencao"),OemToAnsi("Falha na conexão com servidor de e-mail") + CHR(13) + oMail:GetErrorString(nErro) ,{"Ok"})	//"Atencao"###"Falha na conexão com servidor de e-mail"	
//						Else
//							"Falha na Autenticação no Envio do E-mail - Verifique o conteúdo dos parâmetros MV_RELACNT / MV_RELPSW."   
//							cError	:= OemToAnsi(STR0027)
//							cError	:= OemToAnsi("Falha na Autenticação no Envio do E-mail - Verifique o conteúdo dos parâmetros MV_RELACNT / MV_RELPSW.")
//						EndIf
//					EndIf
//					Return Nil
//				EndIf
			EndIf
		Endif
		
		oMessage := TMailMessage():New()
		
		//Limpa o objeto
		oMessage:Clear()
		
		//Popula com os dados de envio
		oMessage:cFrom 		:= cFrom
		oMessage:cTo 		:= cEmail
		oMessage:cCc 		:= ""
		oMessage:cBcc 		:= ""
		oMessage:cSubject 	:= cSubject
		oMessage:cBody 		:= cMensagem
//      anexos - ainda não liberado
/*		
		For nX :=1 to Len(aFiles)
			nArqErro := oMessage:AttachFile( aFiles[nX] )
			
			If (nArqErro < 0)
				If cError <> "S"
//					Aviso(OemToAnsi("Erro") + OemToAnsi(STR0023),"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
				Else
					// "Falha de Anexo de Arquivo - Verifique as configurações de permissão do caminho indicado no parâmetro MV_RELT." 
//					cError := OemToAnsi(STR0026)
				EndIf
				lErroFile	:= .T.
				Exit
			EndIf
		Next		
*/		
		If !lErroFile
			//Envia o e-mail
			nErro := oMessage:Send( oMail )
			
			If !(nErro == 0)
//				cMsgErro := oMail:GetErrorString(nErro)
//				If cError <> "S"					
//					Aviso(OemToAnsi("Atencao") + OemToAnsi("Falha na conexão com servidor de e-mail"),"Falha no envio do e-mail. Erro retornado: " + CHR(13) + cMsgErro,{"OK"})
//				Else
					// "Falha no Envio do E-mail - Verifique o email" 
//					cError	:= OemToAnsi("Falha no Envio do E-mail")
//				EndIf
			Else
				lEnvioOk	:= .T.
			EndIf
		EndIf
	
		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	Else
//		If cError <> "S"
//			cMsgErro := oMail:GetErrorString(nErro)
//			Aviso(OemToAnsi("Atencao"),OemToAnsi("Falha na conexão com servidor de e-mail") + CHR(13) + cMsgErro ,{"Ok"})	//"Atencao"###"Falha na conexão com servidor de e-mail"
//		Else
			// "Falha na Conexão com Servidor de E-mail -Verifique a configuração de Servidor de Email no módulo SIGACFG e parâmetros"   
//			cError := OemToAnsi("Falha na Conexão com Servidor de E-mail -Verifique a configuração de Servidor de Email no módulo SIGACFG e parâmetros" )
//		EndIf
	EndIf
	
Else

	If ( Empty(cMailServer) )
		Help(" ",1,"SEMSMTP")//"O Servidor de SMTP nao foi configurado !!!" ,"Atencao"
	EndIf

	If ( Empty(cMailConta) )
		Help(" ",1,"SEMCONTA")//"A Conta do email nao foi configurado !!!" ,"Atencao"
	EndIf
	
	If Empty(cMailSenha)
		Help(" ",1,"SEMSENHA")	//"A Senha do email nao foi configurado !!!" ,"Atencao"
	EndIf
	
EndIf

Return( lEnvioOK )
/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
ENVIO DE E-MAIL
@TYPE FUNCTION
@AUTHOR DENNIS CALABREZ
@SINCE 28/01/2025
@VERSION P12
@HISTORY DSERLOCA-5295
/*/
FUNCTION LOCA05909(_CREMET, _CDEST, _CCC, _CASSUNTO, CBODY, _CANEXO, _CCCO, _LMSG)

	LOCX059A(_CREMET, _CDEST, _CCC, _CASSUNTO, CBODY, _CANEXO, _CCCO, _LMSG)

Return()
