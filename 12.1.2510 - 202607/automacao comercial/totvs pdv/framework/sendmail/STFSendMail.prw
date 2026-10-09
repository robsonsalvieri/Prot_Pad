#INCLUDE 'Protheus.ch'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "STFSENDMAIL.CH"
#INCLUDE "POSCSS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} STFSendMail
Envia e-mail ao Superior

@param 
@author  Varejo
@version P12
@since   04/02/2015
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STFSendMail(cParamText, cAssunto, lFormatText, lEnviaConf)

Local	cError			:= ""	// Bloco de erro
Local	lOk				:= .T. // Se conseguiu conectar no servidor SMTP
Local	lSendOk		:= .T.	// Se o e-mail foi enviado com sucesso	
Local	cMailConta		:= SuperGetMv("MV_RELFROM",,"")   // Conta 
Local	cMailServer	:= SuperGetMv("MV_RELSERV",,"")       // Servidor SMTP
Local	cMailSenha 	:= SuperGetMv("MV_RELPSW",,"")        // Senha     
Local 	cMailToSup		:= SuperGetMv("MV_LJEMSUP",,"")       // Mensagem customizada do cliente
Local 	aTo 			:= UsrSuper()		// Retorna dados do superior
Local 	lRet			:= .T.				// Retorno se existe e-mail do superior
Local 	cCaixa			:= STDNumCash() 	// Retorna o código do Caixa que está logado
Local  cTexto        := ""            // Texto a ser enviado no e-mail
Local  aFormatTxt    := {}            // Armazena a mensagem formatada
Local  nX            := 0             // Contador

Default lFormatText  := .F.             // Se deverá formatar o texto
Default cParamText   := ""              // Corpo do e-mail
Default cAssunto     := STR0003         //"Info. Limite Sangria"
Default lEnviaConf	:= .T.				// Envio confirmação para a tela se o e-mail foi enviado

If Len(aTo) >= 1
	If Len(aTo[1]) >= 14
		If Empty(aTo[1][14]) // Se não tiver e-mail cadastrado do superior não tenta enviar
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf		
Else
	lRet := .F.
EndIf


If lFormatText
    
    aFormatTxt := STRTOKARR(cParamText,Chr(10)+Chr(13)) 
    cParamText := ""
    
    For nX = 1 to Len(aFormatTxt)    
        cParamText += aFormatTxt[nX] + "<br>" 
    Next nX
    
EndIf

If lRet

	If Empty(cMailToSup)
		cTexto := cParamText 
	Else
	 	If ExistFunc(cMailToSup)
	 		cTexto := &(cMailToSup) //Macro executa
	 	Else
	 		cTexto := cParamText
	 	EndIf 
	EndIf
	
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	
	SEND MAIL FROM AllTrim(cMailConta) to aTo[1][14] SUBJECT cAssunto BODY cTexto RESULT lSendOk 
		
	If !lSendOk
		Conout (STR0004 + cError) //"Erro no envio do email"
	Else
		If lEnviaConf
			MsgAlert(STR0005) // "E-mail enviado com sucesso"
		EndIf
	EndIf
		
	If lOk
		DISCONNECT SMTP SERVER
	EndIf
Else
	If IsInCallStack("STDVERLIMSAN") //Só posso emitir alerta se veio do controle de limite de sangria
		MsgAlert("Favor cadastrar com urgência o código e o e-mail do supervisor. Avise a gerência!") //"Favor cadastrar com urgência o código e o e-mail do supervisor. Avise a gerência!"
	EndIf

Endif

Return


//-------------------------------------------------------------------
/*{Protheus.doc} UsrSuper
Busca informações do Superior do Caixa logado

@param 
@author  Varejo
@version P12
@since   04/02/2015
@return  aUserSup
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function UsrSuper()

Local nI			:= 0 	// Contador
Local cSuperiores	:= "" 	// Armazena o Superior
Local aReturn		:= {}	// Retorno da função do Frame
Local aUserSup	:= {}	// Array com todos os dados do Superior

aReturn := FWSFUsrSup(__cUserID)

For nI := 1 to Len(aReturn)
   cSuperiores := aReturn[nI]
Next nI

If PswSeek(cSuperiores)
	aUserSup := PswRet()
EndIf

Return aUserSup


//-------------------------------------------------------------------
/*{Protheus.doc} STFSendMail
Envia e-mail a partir das configuracoes realizadas 
no SIGACFG Ambiente/E-mail-Proxy/Configurar

@param	  cAssunto    Assunto do email
@param   cMsgEmail   Mensagem de email
@param   lFormatText Formata o texto do email com quebra de linhas
@param   cDestinat   Destinatarios separado por ;
@param   cErro       Controle de erro do envio usar por referencia ;
@author  rafael.pessoa
@version P11.8
@since   18/05/2016
@return  lSendOk - Email enviado
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STFMail( cAssunto , cMsgEmail, lFormatText , cDestinat ,;
					 cErro    )

Local	cError			:= ""	// Bloco de erro
Local	lOk				:= .F. // Se conseguiu conectar no servidor SMTP
Local	lSendOk		:= .F.	// Se o e-mail foi enviado com sucesso	
Local	cMailFrom		:= AllTrim(SuperGetMv("MV_RELFROM",,"") )      // Mail From 
Local	cMailConta		:= AllTrim(SuperGetMv("MV_RELACNT",,""))       // Conta
Local	cMailServer	:= AllTrim(SuperGetMv("MV_RELSERV",,"") )      // Servidor SMTP
Local	cMailSenha 	:= AllTrim(SuperGetMv("MV_RELPSW",,"")  )      // Senha   
Local  lAutentic 		:= SuperGetMv("MV_RELAUTH",,.F.) 					 // Usa Autenticacao	
Local  cTexto        := ""            // Texto a ser enviado no e-mail
Local  aFormatTxt    := {}            // Armazena a mensagem formatada
Local  nX            := 0             // Contador
Local 	cUser			:= ""				// Usuario para tentativa de atenticacao
Local  nA            := 0             // Separador

Default cAssunto     := ""				  // Assunto do email
Default cMsgEmail   	:= ""              // Corpo do e-mail
Default lFormatText  := .F.             // Se deverá formatar o texto
Default cDestinat   	:= ""              // Destinatario
Default cErro			:= ""				// Controla erro de envio do email uar por referencia

If lFormatText
    
    aFormatTxt := STRTOKARR(cMsgEmail,Chr(10)+Chr(13)) 
     
    For nX = 1 to Len(aFormatTxt)    
        cTexto += aFormatTxt[nX] + "<br>" 
    Next nX
Else
    cTexto := cMsgEmail
EndIf


CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

If lOk

	//Caso utiliza autenticacao
	If lAutentic
		lOk := MailAuth(cMailConta, cMailSenha)
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, 
		//tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		If lOk
			LjGrvLog( "STFMail" , "Usuario autenticado." )	
		Else
			nA 		:= At("@",cMailConta)
			cUser	:= If(nA>0,Subs(cMailConta,1,nA-1),cMailConta)
			lOk 	:= MailAuth(cUser, cMailSenha)
		Endif

	Endif
	
	If lOk 
		SEND MAIL FROM cMailFrom to cDestinat SUBJECT cAssunto BODY cTexto RESULT lSendOk
		
		If lSendOk
			LjGrvLog( "STFMail" , "Email Enviado com sucesso." )	
		Else		
			GET MAIL ERROR cErro
			LjGrvLog( "STFMail" , "Não conseguiu enviar email. " + cErro )
			LjGrvLog( "STFMail" , "Caso tenha dificuldades no envio de e-mail tente setar a porta do smtp. " + ;
			                      "Exemplo: smtp.suaempresa.com.br:587 ou smtp.suaempresa.com.br:465"  )
			
		EndIf	
		
		DISCONNECT SMTP SERVER
	Else
		LjGrvLog( "STFMail" , "Usuario não autenticado." )		
	EndIf
	 	

Else	
	GET MAIL ERROR cErro
	LjGrvLog( "STFMail" , "Não conseguiu conectar no serviço SMTP. " + cErro  )	
EndIf

Return lSendOk



//-------------------------------------------------------------------
/*/{Protheus.doc} STFMailTest
Tela para teste de envio de email

@param   	
@author  	R.P.R
@version 	P12
@since   	18/01/2017
@return  	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFMailTest()

Local aRes				:= GetScreenRes()	// Recupera Resolução atual
Local nWidth			:= aRes[1]		// Largura 
Local nHeight			:= aRes[2]		// Altura 
Local oModal			:= Nil			//Dialog Modal
Local oContainer		:= Nil			//Container	
Local oPanel			:= Nil			//Painel
Local oFont 			:= TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)//Fontes
Local oGetMail			:= Nil			// Obj end email
Local cEmail			:= Space(250) 	//Destinatário email
Local nColL				:= 20			//Coluna Esquerda padrao

oModal := FWDialogModal():New()
	
oModal:SetBackground(.F.)
oModal:SetTitle(STR0007)//"Teste de Envio de email"

//Monta tela com 30% do tamanho Total
nWidth  := (nWidth/2)  * 0.3
nHeight := (nHeight/2) * 0.3

oModal:SetFreeArea(nWidth,nHeight)
oModal:createDialog()
oModal:createFormBar()

oPanel := oModal:getPanelMain()

oModal:AddButton( STR0012 , {|| STFTstSendMail(cEmail) } , ; //"Enviar E-mail"
					 	"", , .T., .F., .T., {||.T.} )

oModal:addCloseButton({||oModal:Deactivate()}, STR0013 )//"Sair"

@ 20,nColL SAY oSayNomeParam PROMPT STR0014 SIZE (nWidth * 0.8) ,50  FONT oFont OF oPanel PIXEL//"Digite o destinário de E-mail"

//"Get email"
@ 40,nColL MSGET oGetMail VAR cEmail SIZE (nWidth * 0.8) , 20 OF oPanel PIXEL 
oGetMail:SetCSS( POSCSS(CSS_GET_FOCAL) ) 

oModal:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFValidEmail
Realiza teste de envio de email

@param   	cEmail - Email a ser validado
@author  	R.P.R
@version 	P12
@since   	18/01/2017
@return  	lRet - Retorno do teste de email  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFTstSendMail(cEmail)

Local lRet 			:= .F. 	//Retorno
Local cError		:= ""	//Bloco de erro

Default cEmail := ""

cEmail := AllTrim(cEmail)

If !Empty(cEmail) .AND. ISEMAIL(cEmail)
	
	If STFMail( STR0007 , STR0007 , .F. , cEmail, ;//"Teste de envio de E-mail"
				 @cError )  //"Enviar E-mail"
				  
		FWAlertSuccess("",STR0005)//"E-mail enviado com sucesso"
		lRet 			:= .T.
	Else
	 	FWAlertError(	STR0008 + CRLF + ; //"Verifique se o destinatário existe e revise as configurações de E-mail no Módulo SIGACFG."
	 					STR0009 + cError  ,STR0004)//" Erro: ""Erro no envio do email"
	EndIf
			
Else
	FWAlertError(STR0010,STR0011)//"Verifique o E-mail digitado, informar apenas um e-mail para o teste." "E-mail Inválido"
EndIf	

Return lRet

