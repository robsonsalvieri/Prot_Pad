#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'DBSTRUCT.CH'
#INCLUDE 'SHELL.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MailTafSet
Envio de email centralizador


@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function MailTafSet(jDados, cEndPoint)
	/*Local cDe 	:= */       
	Local cPara 	:= ' '    
	//Local cCc		:=        
	Local cCCO		:= "admin.smartfiscal@totvs.com.br"
	Local cAssunto	:= 'Bem vindo ao Smart e-Social, ambiente ' + Upper(GetEnvServer()) + ' !'
	/*Local cAnexo	:=     */
	Local cMsg		:= ' '  
	Local nUsuario  := 0
	Local nUsu      := 0
	/*Local cServer	:=    
	Local cEmail	:=     
	Local cPass		:=      
	Local lAuth		:=      
	Local cContAuth	:=  
	Local cPswAuth	:=   
	Local lSSL		:=       
	Local lTLS		:=        
	*/
	Local cTextPad  := ''
	Local cUrlStatus:= ''
	
	Default cEndPoint := 'Contate o suporte da TOTVS'
	
	cUrlStatus:= cEndPoint
	cUrlStatus:= StrTran(cUrlStatus,'https://app','https://status')
	
	For nUsuario:=1 To Len(jDados['usuarios'])-1
		cTextPad:=""
		If nUsuario == 1 .and. jDados['usuarios'][1]["usuario"] <> "erro"
			cPara:= jDados['usuarios'][1]['email'] 

			If cPara = NIL
				cPara := "e-mail não informado"
			Endif

			cTextPad+='<td width="580" height="0" valign="top" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #494440;font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif;font-size: 14px;font-weight: 400;font-style: normal;line-height: 1.6;">'
			cTextPad+= "<h1><b> Bem Vindo ao SMART eSocial !</b></h1> "
			cTextPad+= "Acesso Inicial ao WebApp Smart eSocial - Ambiente de <b>" + Upper(GetEnvServer()) + "</b><br>" 
			cTextPad+= "Você esta recebendo no seu email " + cPara + ",<br>"+"suas credenciais de acesso ao ambiente de <b>" + Upper(GetEnvServer()) +" </b> do <b>SMART eSocial</b> que você solicitou.<br>"
			cTextPad+= "Tudo já está parametrizado e você só precisa usar seu ERP, no entanto, se alguma  operação for necessária no seu Smart eSocial, utilize o usuário <b>TAF1</b>, este é seu acesso pessoal.<br>" 

			If Len( jDados['usuarios'] ) > 1
				cTextPad+= "Você também está recebendo as credenciais solicitadas para o(s) e-mail(s) "

				For nUsu:= 1 To Len(jDados['usuarios'])-1
					If jDados['usuarios'][nUsu]["usuario"] <> "erro"
						If nUsu > 1
							cTextPad += " e "
						Endif

						If jDados['usuarios'][nUsu]['email'] <> Nil
							cTextPad += jDados['usuarios'][nUsu]['email']
						EndIf
					Endif
				Next

				cTextPad += ", mas fique tranquilo, estas credenciais também foram enviadas para este(s) e-mail(s).<br>"

				//cTextPad+= "Também foi criado um usuário  para comunicação entre o ERP e o Smart eSocial, é o <b>TAFWS</b>, ele está abaixo para seu conhecimento, pois já foi parametrizado no ERP.<br>"
				cTextPad+= "Para integridade e segurança do ambiente no primeiro acesso sera solicitada a alteração da senha randômica e automática gerada pelo Smart eSocial.<br>" 
				cTextPad+= "Os usuarios criados são:<br><br>"

				For nUsu:= 1 To Len(jDados['usuarios'])-1
					cTextPad+= "usuário: <b>" + jDados['usuarios'][nUsu]["usuario"] +  "</b> - Senha: <b>"+ jDados["usuarios"][nUsu]["senha"] + "</b><br><br>"
				Next
			Endif

			cTextPad+="O acesso ao ambiente de <b>" + Upper(GetEnvServer()) + "</b> é feito através do endereço:<br> <b>" + cEndPoint + "</b><br><br>"
			cTextPad+="A consulta ao status dos serviços pode ser feitas através do link:<br> <b>" + cUrlStatus + "</b><br><br>"
			cTextPad+='	</span></td>'
		Else
			cPara:= jDados['usuarios'][nUsuario]['email'] 
			If !Empty(cPara)
				cTextPad+='<td width="580" height="0" valign="top" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #494440;font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif;font-size: 14px;font-weight: 400;font-style: normal;line-height: 1.6;">'
				cTextPad+= "<h1><b> Bem Vindo ao SMART eSocial !</b></h1> "
				cTextPad+= "Acesso Inicial ao WebApp Smart eSocial - Ambiente de <b>" + Upper(GetEnvServer()) + "</b><br>" 
				cTextPad+= "Você está recebendo no seu email " + jDados['usuarios'][nUsuario]['email'] + " suas credenciais de acesso ao ambiente de <b>" + Upper(GetEnvServer()) + "</b> do <b>Smart eSocial</b>, este acesso foi solicitado por " + jDados['usuarios'][1]['email'] + ", qualquer dúvida faça contato com ele através do e-mail " + jDados['usuarios'][1]['email'] + ".<br>"
				cTextPad+= "Tudo já está parametrizado e você só precisa usar seu ERP, no entanto, se alguma  operação for necessária no seu Smart eSocial, utilize o usuário <b>" + jDados['usuarios'][nUsuario]['usuario'] + "</b>, este é seu acesso pessoal.<br>" 
				cTextPad+= "Para integridade e segurança do ambiente no primeiro acesso sera solicitada a alteração da senha randômica e automática gerada pelo Smart eSocial.<br>" 
				cTextPad+= "O seu usuário criado é: <br><br>"
				cTextPad+= "usuário: <b>" + jDados['usuarios'][nUsuario]["usuario"] +  "</b> - Senha: <b>"+ jDados["usuarios"][nUsuario]["senha"] + "</b><br><br>"
				cTextPad+="O acesso ao ambiente de <b>" + Upper(GetEnvServer()) + "</b> é feito através do endereço:<br> <b>" + cEndPoint + "</b><br><br>"
				cTextPad+='	</span></td>'
			EndIf
		EndIf	 
		
		If !Empty(cTextPad)
			cMsg+='<html>'
			cMsg+='<head>'
			cMsg+='<title>EMKT - Smart eSocial</title>'
			cMsg+='<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
			cMsg+='</head>'
			cMsg+='<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'
			cMsg+='<!-- Save for Web Slices (emkt_Smart_Analytics_v2.psd) -->'
			cMsg+='<table width="700" height="auto" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;" align="center" idforbackup="rkydbecohjok">'
			cMsg+='	<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
			cMsg+='		<td width="700" height="257" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="257" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="257" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="257" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="700" height="257" valign="top" style="font-size: 0;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_01.jpg" width="700" height="257" border="0" style="display: block; border: 0;" alt="SMART eSocial - TOTVS" title="SMART eSocial - TOTVS"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
			cMsg+='		<td width="700" height="0" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="0" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2"></td>'
			cMsg+='								<td width="580" height="0" valign="top" style="font-size: 0;">'
			cMsg+='									<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='										<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='										<tr valign="top" style="font-size: 0;">'
			cMsg+='											<td width="580" height="54" valign="top" style="font-size: 0;">'
			cMsg+='												<table width="580" height="54" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='													<tr valign="top" style="font-size: 0;">'
			cMsg+='														<td width="580" height="54" valign="top" style="font-size: 0;">'
			cMsg+='															<table width="580" height="54" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='																<tr valign="top" style="font-size: 0;">'
			cMsg+='																</tr>'
			cMsg+='																</tbody>'
			cMsg+='															</table>'
			cMsg+='														</td>'
			cMsg+='													</tr>'
			cMsg+='													</tbody>'
			cMsg+='												</table>'
			cMsg+='											</td>'
			cMsg+='										</tr>'
			cMsg+='										<tr valign="top" style="font-size: 0;">'
			cMsg+='											<td width="580" height="36" valign="top" style="font-size: 0;">'
			cMsg+='												<table width="580" height="36" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='													<tr valign="top" style="font-size: 0;">'
			cMsg+='														<td width="580" height="36" valign="top" style="font-size: 0;">'
			cMsg+='															<table width="580" height="36" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='																<tr valign="top" style="font-size: 0;">'
			cMsg+='																</tr>'
			cMsg+='																</tbody>'
			cMsg+='															</table>'
			cMsg+='														</td>'
			cMsg+='													</tr>'
			cMsg+='													</tbody>'
			cMsg+='												</table>'
			cMsg+='											</td>'
			cMsg+='										</tr>'
			cMsg+='										<tr valign="top" style="font-size: 0;">'
			cMsg+='											<td width="580" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2">'
			cMsg+='												<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='													<tr valign="top" style="font-size: 0;">'
			cMsg+='														<td width="580" height="0" valign="top" style="font-size: 0;">'
			cMsg+='															<table width="580" height="0" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='																<tr valign="top" style="font-size: 0;">'
			cMsg+= cTextPad
			cMsg+='																</tr>'
			cMsg+='																</tbody>'
			cMsg+='															</table>'
			cMsg+='														</td>'
			cMsg+='													</tr>'
			cMsg+='													</tbody>'
			cMsg+='												</table>'
			cMsg+='											</td>'
			cMsg+='										</tr>'
			cMsg+='										<tr valign="top" style="font-size: 0;">'
			cMsg+='											<td width="580" height="18" valign="top" style="font-size: 0;">'
			cMsg+='												<table width="580" height="18" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='													<tr valign="top" style="font-size: 0;">'
			cMsg+='														<td width="580" height="18" valign="top" style="font-size: 0;">'
			cMsg+='															<table width="580" height="18" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='																<tr valign="top" style="font-size: 0;">'
			cMsg+='																	<td width="580" height="18" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #494440; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 14px; font-weight: 700; font-style: normal; line-height: normal;">Atenciosamente,</span></td>'
			cMsg+='																</tr>'
			cMsg+='																</tbody>'
			cMsg+='															</table>'
			cMsg+='														</td>'
			cMsg+='													</tr>'
			cMsg+='													</tbody>'
			cMsg+='												</table>'
			cMsg+='											</td>'
			cMsg+='										</tr>'
			cMsg+='										<tr valign="top" style="font-size: 0;">'
			cMsg+='											<td width="580" height="53" valign="top" style="font-size: 0;">'
			cMsg+='												<table width="580" height="53" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='													<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='													<tr valign="top" style="font-size: 0;">'
			cMsg+='														<td width="580" height="53" valign="top" style="font-size: 0;">'
			cMsg+='															<table width="580" height="53" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='																<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='																<tr valign="top" style="font-size: 0;">'
			cMsg+='																	<td width="580" height="53" valign="top" style="font-size: 0; text-align: left;" bgcolor="#f0f1f2"><span style="color: #139dc0; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 700; font-style: normal; line-height: normal;">Equipe Smart Fiscal TOTVS</span></td>'
			cMsg+='																</tr>'
			cMsg+='																</tbody>'
			cMsg+='															</table>'
			cMsg+='														</td>'
			cMsg+='													</tr>'
			cMsg+='													</tbody>'
			cMsg+='												</table>'
			cMsg+='											</td>'
			cMsg+='										</tr>'
			cMsg+='										</tbody>'
			cMsg+='									</table>'
			cMsg+='								</td>'
			cMsg+='								<td width="60" height="0" valign="top" style="font-size: 0;" bgcolor="#f0f1f2"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;">'
			cMsg+='		<td width="700" height="29" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="29" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="29" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="29" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="580" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="60" height="29" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;">'
			cMsg+='		<td width="700" height="48" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="48" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="48" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="48" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="261" height="48" valign="top" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Interaja conosco <br>nas redes sociais'
			cMsg+='<span style="color: #000000;font-size: 4px;line-height: 25px;">a</span>'
			cMsg+='<br></span></td>'
			cMsg+='								<td width="36" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="283" height="48" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Quer saber mais sobre <br>a TOTVS?'
			cMsg+='<span style="color: #000000;font-size: 4px;line-height: 25px;">a</span></span></td>'
			cMsg+='								<td width="60" height="48" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;" bgcolor="#000000">'
			cMsg+='		<td width="700" height="40" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="40" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="40" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="40" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="40" valign="top" style="font-size: 0;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_24.jpg" width="60" height="40" border="0" style="display: block; border: 0;" alt="" title=""></td>'
			cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.linkedin.com/company/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_25.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Linkedin" title="Linkedin"></a></td>'
			cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.facebook.com/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_26.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Facebook" title="Facebook"></a></td>'
			cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.instagram.com/totvsbrasil/" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_27.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Instagran" title="Instagran"></a></td>'
			cMsg+='								<td width="32" height="40" valign="top" style="font-size: 0;"><a href="https://www.youtube.com/totvs" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_28.jpg" width="32" height="40" border="0" style="display: block; border: 0;" alt="Youtube" title="Youtube"></a></td>'
			cMsg+='								<td width="133" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="36" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="283" height="40" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">Assine nossa newsletter e fique <br>por dentro das novidades.</span></td>'
			cMsg+='								<td width="60" height="40" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;">'
			cMsg+='		<td width="700" height="33" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="33" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="33" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="33" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="261" height="33" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #ffffff; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 19px; font-weight: 700; font-style: normal; line-height: normal;">Ou entre em contato</span></td>'
			cMsg+='								<td width="36" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="283" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="60" height="33" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;">'
			cMsg+='		<td width="700" height="49" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="49" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="49" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="49" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="142" height="49" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">LIGUE<br><span style="color: #e38f2b;font-weight: bold;">0800 70 98 100</span></span></td>'
			cMsg+='								<td width="119" height="49" valign="middle" style="font-size: 0; text-align: left;" bgcolor="#000000"><span style="color: #989898; font-family: ' + " 'Segoe UI', Frutiger, 'Frutiger Linotype', 'Dejavu Sans', 'Helvetica Neue'," + ' Arial, sans-serif, sans-serif; font-size: 16px; font-weight: 400; font-style: normal; line-height: normal;">ACESSE<br><a href="https://v4.aloweb.com.br/chat/atendimentos/standalone?token=z0lIts0hQQCnbF9O5SiUSt1KunmGYQYbeNbTcWJg&amp;id=235" target="_blank" border="0" style="color: #e38f2b;font-weight: bold;border: 0;cursor: pointer;text-decoration: none;">CHAT ONLINE</a></span></td>'
			cMsg+='								<td width="36" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="184" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"><a href="https://www.totvs.com/" target="_blank" border="0" style="text-decoration: none; display: block; border: 0; font-size: 0; cursor: pointer;"><img src="http://tdn.totvs.com/download/attachments/367238621/emkt_Smart_Analytics_42.jpg" width="184" height="49" border="0" style="display: block; border: 0;" alt="Clique aqui!" title="Clique aqui!"></a></td>'
			cMsg+='								<td width="99" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="60" height="49" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	<tr valign="top" style="font-size: 0;">'
			cMsg+='		<td width="700" height="24" valign="top" style="font-size: 0;">'
			cMsg+='			<table width="700" height="24" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='				<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='				<tr valign="top" style="font-size: 0;">'
			cMsg+='					<td width="700" height="24" valign="top" style="font-size: 0;">'
			cMsg+='						<table width="700" height="24" valign="top" border="0" cellpadding="0" cellspacing="0" style="font-size: 0;">'
			cMsg+='							<tbody valign="top" border="0" style="font-size: 0;">'
			cMsg+='							<tr valign="top" style="font-size: 0;">'
			cMsg+='								<td width="60" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="261" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="36" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="283" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='								<td width="60" height="24" valign="top" style="font-size: 0;" bgcolor="#000000"></td>'
			cMsg+='							</tr>'
			cMsg+='							</tbody>'
			cMsg+='						</table>'
			cMsg+='					</td>'
			cMsg+='				</tr>'
			cMsg+='				</tbody>'
			cMsg+='			</table>'
			cMsg+='		</td>'
			cMsg+='	</tr>'
			cMsg+='	</tbody>'
			cMsg+='</table>'
			cMsg+='<!-- End Save for Web Slices -->'
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+=''
			cMsg+='</body>'
			cMsg+='</html>'

			// grava o HTML antes de encaminhar o email
			TAFMAILGrvHtm(cMsg)

			If !(TAFSETMAIL( /*cDe*/,;
						cPara,;
						/*cCc*/,;
						cCCO,;
						cAssunto,;
						/*cAnexo*/,;
						cMsg,;
						/*cServer*/,;
						/*cEmail*/,;
						/*cPass*/,;
						/*lAuth*/,;
						/*cContAuth*/,;
						/*cPswAuth*/,;
						/*lSSL*/,;
						/*lTLS*/))
				//SetOk(.F.)
			EndIf
		Endif

		cMsg:=""
	Next	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSETMAIL
Rotina Generica de Envio de E-mail.
Uso Geral.

@param 	cDe	   		Remetente
@param 	cPara		Destinatario, quando mais de um separar por ";"
@param 	cCc			Destinatario de Copia, quando mais de um separar por ";"
@param 	cAssunto	Assunto
@param 	cAnexo		Anexo a ser enviado, devem estar abaixo do RootPath, com caminho completo
e quando mais de um separados por ";"
@param 	cMsg		Mensagem do e-mail no formato texto ou html

@sample
TAFSETMAIL( "MeuNome", "destinatario@totvs.com.br",, "Teste de Envio",, "<b>TESTE DE ENVIO<b>" )

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFSETMAIL( cDe, cPara, cCc, cCCO, cAssunto, cAnexo, cMsg, cServer, cEmail, cPass, lAuth, cContAuth, cPswAuth, lSSL, lTLS)
Local lResulConn := .T.
Local lResulsend := .T.
Local cError     := ''
Local lRet       := .T.
Local nA         := 0
Local cFrom      := ''

ParamType 0  Var cDe       As Character Optional Default NIL
ParamType 1  Var cPara     As Character
ParamType 2  Var cCc       As Character Optional Default NIL
ParamType 3  Var cCCO      As Character Optional Default ""
ParamType 4  Var cAssunto  As Character
ParamType 5  Var cAnexo    As Character Optional Default NIL
ParamType 6  Var cMsg      As Character Optional Default ""
ParamType 7  Var cServer   As Character Optional Default Trim( SuperGetMV( 'MV_RELSERV',, '' ) )  // smtp.dominio.com.br ou 200.181.100.51
ParamType 8  Var cEmail    As Character Optional Default Trim( SuperGetMV( 'MV_RELACNT',, '' ) )  // fulano@dominio.com.br
ParamType 9  Var cPass     As Character Optional Default Trim( SuperGetMV( 'MV_RELPSW' ,, '' ) )  // senha
ParamType 9  Var lAuth     As Logical   Optional Default       SuperGetMV( 'MV_RELAUTH',, .F.  )  // Tem Autenticacao ?
ParamType 10 Var cContAuth As Character Optional Default Trim( SuperGetMV( 'MV_RELACNT',, '' ) )  // Conta Autenticacao
ParamType 11 Var cPswAuth  As Character Optional Default Trim( SuperGetMV( 'MV_RELAPSW',, '' ) )  // Senha Autenticacao
ParamType 12 Var lSSL      As Logical   Optional Default       SuperGetMV( 'MV_RELSSL',, .F.   )  // Utiliza protocolo SSL
ParamType 13 Var lTLS      As Logical   Optional Default       SuperGetMV( 'MV_RELTLS',, .F.   )  // Utiliza protocolo TLS
If Empty( cServer ) .AND. Empty( cEmail ) .AND. Empty( cPass )
	lRet := .F.
	cMsg := "[TAFSETMAIL|ERRO] - Não foram definidos um ou mais parâmetros de configuração para envio de e-mail pelo Protheus." 

	ConOut(  FwTimeStamp(3)  + ' ' + cMsg )

	If !IsBlind()
		Conout( cMsg, cAssunto )
	EndIf

	Return lRet
EndIf

cDe      := IIf( cDe == NIL, SuperGetMV( 'MV_RELFROM',, "Microsiga Protheus " + GetVersao() ), AllTrim( cDe ) ) 
cDe      := IIf( Empty( cDe ), cEmail, cDe )
cPara    := AllTrim( cPara )
cCC      := AllTrim( cCC )
cAssunto := IIf( Empty( cAssunto), "<sem assunto>", AllTrim( cAssunto ) ) 
cAnexo   := AllTrim( cAnexo )
cAnexo   := IIf(  Left( cAnexo, 1 ) == ';', SubStr( cAnexo, 2 )                  , cAnexo )
cAnexo   := IIf( Right( cAnexo, 1 ) == ';', SubStr( cAnexo, 1, Len( cAnexo) - 1 ), cAnexo )

If lAuth
	If Empty( cContAuth ) .OR. Empty( cPswAuth )
		lRet := .F.
		cMsg := "[TAFSETMAIL|ERRO] - Não foram definidas conta ou palavra-passe de autenticação para envio de e-mail pelo Protheus." 

		ConOut(  FwTimeStamp(3)  + ' ' + cMsg )

		If !IsBlind()
			Conout( cMsg, cAssunto )
		EndIf

		Return lRet
	EndIf
EndIf

lResulConn := MailSmtpOn( cServer, cEmail, cPass,, lTLS, lSSL )

If !lResulConn
	lRet := .F.

	GET MAIL ERROR cError
	cMsg := "[TAFSETMAIL|ERRO] - Falha na conexão para envio de e-mail" + ' (' + cError + ' )' 
	ConOut(  FwTimeStamp(3)  + ' ' +  cMsg )

	If !IsBlind()
		Conout( cMsg, cAssunto )
	EndIf

	Return lRet
EndIf

If lAuth
	//
	// Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
	//
	If !( lRet := MailAuth( cContAuth, cPswAuth )   )
		//
		// Se nao conseguiu fazer a Autenticacao usando o E-mail completo,
		// tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		//
		If !lRet
			nA        := At( '@', cContAuth )
			cContAuth := IIf( nA > 0, SubStr( cContAuth, 1, nA - 1 ), cContAuth )

			If !( lRet  := MailAuth( cContAuth, cPswAuth ) )
				lRet := .F.
				cMsg := "[TAFSETMAIL|ERRO] - Não conseguiu autenticar conta de e-mail" + ' ( ' + cContAuth + ' )' 

				ConOut(  FwTimeStamp(3) + ' ' + cMsg )

				If !IsBlind()
					Conout( cMsg )
				EndIf

			//	DISCONNECT SMTP SERVER

				Return lRet
			EndIf

		EndIf
	EndIf
EndIf

cFrom := cDe
If AllTrim( Lower( cDe ) ) <> AllTrim( Lower( cEmail ) )
	cFrom := AllTrim( cDe ) + ' <' + AllTrim( cEmail ) + '>'
EndIf

If      Empty( cCc ) .AND.  Empty( cAnexo ) .And. Empty( cCCO )
	SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend

ElseIf  Empty( cCc ) .AND. !Empty( cAnexo ) .And. Empty( cCCO )
	SEND MAIL FROM cFrom TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

ElseIf  Empty( cCc ) .AND. !Empty( cAnexo ) .And. !Empty( cCCO )
	SEND MAIL FROM cFrom TO cPara BCC cCCO SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

ElseIf !Empty( cCc ) .AND.  Empty( cAnexo ) .And. Empty( cCCO )
	SEND MAIL FROM cFrom TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend

ElseIf !Empty( cCc ) .AND.  Empty( cAnexo ) .And. !Empty( cCCO )
	SEND MAIL FROM cFrom TO cPara CC cCc BCC cCCO SUBJECT cAssunto BODY cMsg RESULT lResulSend

Else
	SEND MAIL FROM cFrom TO cPara CC cCc BCC cCCO SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

EndIf

If !lResulSend
	GET MAIL ERROR cError
	lRet := .F.
	cMsg := "[TAFSETMAIL|ERRO] - Falha no envio do e-mail " + ' ( ' + cError + ' )' // "Falha no envio do e-mail "

	ConOut(  FwTimeStamp(3)  + ' ' + cMsg )

	If !IsBlind()
		Conout( cMsg, cAssunto )
	EndIf
Else
	ConOut( "Enviado e-mail para: " + '[' + cPara    + ']' ) // "Enviado e-mail Para: "
	ConOut( "            Assunto: " + '[' + cAssunto + ']' ) // "            Assunto: "
EndIf

DISCONNECT SMTP SERVER

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMAILGrvHtm
Rotina Generica de gravação do E-mail a ser enviado
Uso Geral.

@param 	cLog	   	Mensagem a ser encaminhada

@sample
TAFMAILGrvHtm( "MeuNome, destinatario@totvs.com.br" )

@author Renato Campos
@since 14/08/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFMAILGrvHtm(cMsgLog)

Local cArqLog	:= "/"
Local nHdl	:= 0                           //Handle do arquivo
Local cEOL	:= CHR(13)+CHR(10)            //Final de Linha
Local lRet := .T.

//Incluo o nome do arquivo no caminho ja selecionado pelo usuario
cArqLog := "SMARTMAIL_" + dTos(dDataBase) + StrTran(Time(),":","") + ".html"

If (nHdl := FCreate(cArqLog)) == -1
	Conout( "[TAFMAILGrvHtm|ERRO] - Nao foi possível criar o arquivo de nome ( " + cArqLog + " )! Verifique os acessos da máquina." )
	lRet := .F.
EndIf

If lRet .And. ( FWrite(nHdl,cMsgLog,Len(cMsgLog)) != Len(cMsgLog) )
	Conout( "[TAFMAILGrvHtm|ERRO] - Ocorreu um erro na gravacao do arquivo: " + cArqLog + "." )
	lRet := .F.
EndIf

FClose(nHdl)

Return