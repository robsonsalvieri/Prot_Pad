#INCLUDE 'Protheus.ch'
#INCLUDE 'POSCSS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FLY01LOGIN.CH'

Static oDlg				:= Nil //Obj dialog bkg
Static lAuthentic			:= .F.		//valida se o usuario foi autenticado
Static cCryptKey 			:= "!TOTVS@PDV#MOBILE$" //Chave de criptografia

//-------------------------------------------------------------------
/*/{Protheus.doc} Fly01Login
Classe responsavel pelo Login do Fly01

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
CLASS Fly01Login FROM LongNameClass

	DATA oOwner
	DATA oAlertEmailPwd
	DATA oAlertWrongPwd
	DATA oWrongAlert
	
	//Panels 
	DATA oPnHeader
	DATA oPnLogin
	DATA oPnAskRegister
	DATA oPnRegister
	DATA oPnForgetPassword

	//Panels - dimensoes
	DATA nHeightLogin 
	DATA nHeightAskRegister 
	DATA nHeightHeader
	DATA nHeightForgotPsw
	
	
	//auxiliares de posicionamento
	DATA nMarginLeft 
	DATA nMarginTop
	
	//dimensoes gerais (total)
	DATA nWidthTotal
	DATA nHeightTotal 
	DATA nTopDefault
	DATA nLeftDefault
	
	//dimensoes Campos
	DATA nWidthUtil 
	DATA nHeightField
	
	DATA cGetUser 
	DATA cGetPsw 
	DATA cRepUsrPwd
	DATA cEmail
	DATA cNomeLoja 
	DATA oGetEmail
	DATA oEmail
	DATA cEndereco
	DATA cCidade
	
	DATA oGetLoja
	DATA oGetPwd
	DATA oGetRepPwd	
	DATA oGetEnd
	DATA oListEstado
	DATA oGetCid
	
	DATA lAlwaysConnected
	
	DATA aFontLogin 
	DATA aFontAccount 

	DATA lUserCreated

	//METODOS DA CLASSE
	METHOD New()
	METHOD SetOwner()
	
	METHOD Activate()
	METHOD DeActivate()
	
	METHOD GetHeader()
	METHOD GetLogin()
	METHOD GetForgotPassword()
	METHOD GetAskRegister()
	METHOD GetRegister()
	
	METHOD GetAlertWrongPwd()
	METHOD GetAlertEmailPwd()
	METHOD AlertWrong()
	
	
	METHOD ValidLogin()
	METHOD ValidEmail()
	METHOD ValidCadastro()
	METHOD ValidGetDef()
	METHOD ValidPsw()
	
	METHOD HideHeader()
	METHOD HideLogin()
	METHOD HideForgotPassword()
	METHOD HideAskRegister()
	METHOD HideRegister()
	METHOD HideAlertWrongPwd()
	METHOD HideAlertEmailPwd()
	METHOD HideAlertWrong()
	
	METHOD ShowHeader()
	METHOD ShowLogin()
	METHOD ShowForgotPassword()
	METHOD ShowAskRegister()
	METHOD ShowRegister()
	
	METHOD ShowAlert()
	
	
	METHOD Fly01Cadastro()

END CLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} Fly01Login
Metodo construtor Login do Fly01

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD NEW(oOwner) CLASS Fly01Login

If !Empty(oOWner)
	self:oOwner := oOwner
	oOwner:ReadClientCoors(.T., .T.)
EndIf

self:oAlertEmailPwd := nil
self:oAlertWrongPwd := nil
self:nMarginLeft := 15
self:nMarginTop := 8

self:lAlwaysConnected :=  PADR(STFUserGetInfo("LF_FRTAUTO"),TamSx3("LF_FRTAUTO")[1]) == "1" //manter conectado

self:lUserCreated := UserCreated() //usuario já criado

self:cEmail 	 := Space(50)
self:cNomeLoja := Space(40)
self:cEndereco := Space(50)
self:cCidade 	 := Space(50)
	
If self:lAlwaysConnected 

	//usuario
	self:cGetUser := PADR(STFUserGetInfo("LF_ACESSO"),TamSx3("LF_ACESSO")[1]) //usuario por email

	//senha
	self:cGetPsw  := STFUserGetInfo("LF_NUMCART")//senha ainda criptografada	
	self:cGetPsw  := STFRC4DeCrypt( AllTrim(self:cGetPsw) ,cCryptKey, .F.) //Senha descriptografada		
	self:cGetPsw  := PADR(self:cGetPsw,TamSx3("LF_NUMCART")[1])//senha

Else
	self:cGetUser := Space(TamSx3("LF_ACESSO")[1]) //usuario por email
	self:cGetPsw  := Space(TamSx3("LF_NUMCART")[1])//senha
EndIf		

self:aFontLogin := {'15' ,.T.}
self:aFontAccount := {'16' ,.F.}

self:nHeightAskRegister := 80
Self:nHeightHeader := 25
Self:nHeightLogin := 135
Self:nHeightForgotPsw := 120

self:nHeightField := 16

self:nHeightTotal := self:nHeightHeader + self:nHeightLogin + self:nHeightAskRegister
self:nWidthTotal := 180
self:nTopDefault := (oOwner:nClientHeight/2-self:nHeightTotal)/2
self:nLeftDefault := (oOwner:nWidth/2-self:nWidthTotal)/2

self:nWidthUtil := ( self:nWidthTotal - (self:nMarginLeft * 2) )


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Metodo Ativacao da classe

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD Activate() Class FLY01LOGIN

self:GetHeader()
Self:GetLogin()
Self:GetAskRegister()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
Metodo GetHeader

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetHeader() CLASS Fly01Login

Local oTitle		:= Nil //Obj Titulo
Local oPanelLine 	:= Nil //painel apenas para desenhar linha branca 

Self:oPnHeader := tPanel():New(self:nTopDefault,self:nLeftDefault,"",self:oOwner,,,,,,self:nWidthTotal,self:nHeightHeader)
Self:oPnHeader:SetCss(POSCSS (GetClassName(Self:oPnHeader), CSS_PANEL_LOGINGHEADER, .T. ))


@ self:nMarginTop,self:nMarginLeft SAY oTitle PROMPT STR0001 SIZE self:nWidthUtil,30 OF Self:oPnHeader PIXEL //"PONTO DE VENDA - PDV"
oTitle:SetCss(POSCSS (GetClassName(oTitle), CSS_BREADCUMB ))

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetLogin
Metodo GetLogin

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetLogin()  CLASS Fly01Login

Local nLine 		:= self:nMarginTop  	//Determina a posicao linha

self:oPnLogin := tPanel():New((Self:oPnHeader:nTop+Self:oPnHeader:nHeight)/2,Self:oPnHeader:nLeft/2,"",self:oOwner,,,,,,self:nWidthTotal,self:nHeightLogin)
self:oPnLogin:SetCss(POSCSS (GetClassName(self:oPnLogin), CSS_PANEL_LOGINMAIN ))
CreatePanelLine(Self:oPnLogin)

@ nLine,self:nMarginLeft SAY oUser PROMPT STR0002 SIZE self:nWidthUtil,020 OF self:oPnLogin PIXEL //"Email"
oUser:SetCss(POSCSS (GetClassName(oUser), CSS_LABEL_FOCAL, self:aFontLogin ))

nLine += 12
@ nLine,self:nMarginLeft GET oGetUser VAR self:cGetUser WHEN {|| .T. } SIZE self:nWidthUtil,self:nHeightField OF self:oPnLogin PIXEL
oGetUser:SetCss(POSCSS (GetClassName(oGetUser), CSS_GET_FOCAL ))

nLine += 25
@ nLine,self:nMarginLeft SAY oPassword PROMPT STR0003 SIZE self:nWidthUtil,020 OF self:oPnLogin PIXEL //"Senha"
oPassword:SetCss(POSCSS (GetClassName(oPassword), CSS_LABEL_FOCAL, self:aFontLogin))

nLine += 12
@ nLine,self:nMarginLeft GET oGetPsw VAR Self:cGetPsw SIZE self:nWidthUtil,self:nHeightField  OF self:oPnLogin PIXEL PASSWORD
oGetPsw:SetCss(POSCSS (GetClassName(oGetPsw), CSS_GET_FOCAL ))			

nLine += 30
@ nLine,self:nMarginLeft CHECKBOX oChkConnected  VAR self:lAlwaysConnected  PROMPT STR0004 SIZE (self:nWidthUtil/2)-5,020 OF self:oPnLogin PIXEL //"Manter conectado"
oChkConnected:SetCss(POSCSS (GetClassName(oChkConnected), CSS_CHECKBOX_DEFAULT ))		

nLine += 20
@ nLine, self:nMarginLeft BUTTON oBtnLogin PROMPT STR0005 SIZE self:nWidthUtil,self:nHeightField+4 ACTION {|| self:ValidLogin() } OF self:oPnLogin PIXEL //"ENTRAR"
oBtnLogin:SetCss(POSCSS( GetClassName(oBtnLogin), CSS_BTN_FOCAL) )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidLogin
Metodo GetLogin

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ValidLogin()  CLASS Fly01Login

Local aArea		:= GetArea() 				//Salva area
Local lRet			:= .F.						//Retorno 

lAuthentic := .F.

//esconde msgs de erros anteriores
self:HideAlertWrongPwd()
self:HideAlertWrong()

DbSelectArea("SLF")                                      
DbSetOrder(1)//LF_FILIAL+LF_COD
If DbSeek( xFilial("SLF")+ "USR" )

	If !Empty(self:cGetUser) .AND. !Empty(Self:cGetPsw)
		lRet := .T.
		//Valida usuario e senha
	
		lRet := lRet .AND. AllTrim(SLF->LF_ACESSO) 						 == AllTrim(self:cGetUser) 		//Email
		
		lRet := lRet .AND. STFRC4DeCrypt( AllTrim(SLF->LF_NUMCART) )   == AllTrim(Self:cGetPsw) 		//Senha  
		
	EndIf	

EndIf

__cInterNet := Nil //Força essa variavel para nao entrar em modo automatico(IsBlind())

//Atualiza variavel estatica de controle de acesso
lAuthentic := lRet

//Validade Versao Demostrativa
//Se vencida nao deixa prossegir login
If lAuthentic .AND. STFTypeOperation() == "DEMONSTRACAO"
	If !VerDemValid()
		MS_QUIT()	//Fecha aplicacao
	EndIf
EndIf	

If lAuthentic
	//Atualiza informacoes de lembrete de usuario
	self:Fly01Cadastro() 
	//Fecha tela de login para iniciar o sistema
	oDlg:End()
Else
	//mostra mensagem de erro
	self:GetAlertWrongPwd()	
EndIf

RestArea(aArea)	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAskRegister
Metodo GetAskRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetAskRegister()  CLASS Fly01Login

Local nLine := self:nMarginTop

self:oPnAskRegister:= tPanel():New((self:oPnLogin:nTop+self:oPnLogin:nHeight)/2,self:oPnLogin:nLeft/2,"",self:oOwner,,,,,,self:nWidthTotal,self:nHeightAskRegister)
self:oPnAskRegister:SetCss(POSCSS (GetClassName(self:oPnAskRegister), CSS_PANEL_LOGINASKREG ))
CreatePanelLine(Self:oPnAskRegister)

@ nLine,self:nMarginLeft SAY oTitle PROMPT STR0006 SIZE self:nWidthUtil,030 OF self:oPnAskRegister PIXEL //"Não tem cadastro? Informe Seu email"
oTitle:SetCss(POSCSS (GetClassName(oTitle), CSS_LABEL_FOCAL, self:aFontAccount ))


nLine += 15
@ nLine,self:nMarginLeft GET self:oEmail VAR Self:cEmail WHEN {|| .T. } SIZE self:nWidthUtil,self:nHeightField OF self:oPnAskRegister PIXEL
self:oEmail:lReadOnly :=  UserCreated()  //so habilita se nao tiver user cadastrado
self:oEmail:bValid := {|| self:ValidEmail(self:oEmail ,self:cEmail ) } 
self:oEmail:SetCss(POSCSS (GetClassName(self:oEmail), CSS_GET_FOCAL ))


nLine += 26
@ nLine, self:nMarginLeft BUTTON oBtnReg PROMPT STR0007 SIZE self:nWidthUtil,self:nHeightField+4 ACTION {|| IIF(self:ValidEmail(self:oEmail ,self:cEmail ),self:GetRegister(),) } OF self:oPnAskRegister PIXEL //"CADASTRE-SE"
oBtnReg:SetCss(POSCSS( GetClassName(oBtnReg), CSS_BTN_NORMAL) )
oBtnReg:bWhen := {|| !UserCreated()  }//so habilita se nao tiver user cadastrado

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetForgotPassword
Metodo GetForgotPassword

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetForgotPassword()  CLASS Fly01Login

Local nLine := self:nMarginTop	//Linha

self:oPnForgetPassword := tPanel():New((Self:oPnHeader:nTop+Self:oPnHeader:nHeight)/2,Self:oPnHeader:nLeft/2,"",self:oOwner,,,,,,Self:nWidthTotal,self:nHeightForgotPsw)
self:oPnForgetPassword:SetCss(POSCSS (GetClassName(self:oPnForgetPassword), CSS_PANEL_LOGINFOOTER, .T. ))


@ nLine,self:nMarginLeft SAY oTitle PROMPT STR0008 SIZE self:nWidthUtil,030 OF self:oPnForgetPassword PIXEL //"Esqueci minha senha"
oTitle:SetCss(POSCSS (GetClassName(oTitle), CSS_LABEL_FOCAL, {'17' ,.T.} ))

CreatePanelLine(self:oPnForgetPassword)

nLine += 20
@ nLine,self:nMarginLeft SAY oSayEmail PROMPT STR0009 SIZE self:nWidthUtil,030 OF self:oPnForgetPassword PIXEL //"Informe seu email de cadastro"
oSayEmail:SetCss(POSCSS (GetClassName(oSayEmail), CSS_LABEL_FOCAL,{'15' ,.F.} ))

nLine += 15
@ nLine,self:nMarginLeft GET self:oEmail VAR self:cEmail WHEN {|| .T. } SIZE self:nWidthUtil,self:nHeightField OF self:oPnForgetPassword PIXEL
self:oEmail:SetCss(POSCSS (GetClassName(self:oEmail), CSS_GET_FOCAL ))

nLine += 35
@ nLine,self:nMarginLeft BUTTON oBtnReg PROMPT STR0010 SIZE self:nWidthUtil,self:nHeightField+4 ACTION {|| self:HideForgotPassword(), self:ShowLogin(), self:ShowAskRegister(), self:GetAlertEmailPwd() } OF self:oPnForgetPassword PIXEL //"RECUPERAR SENHA"
oBtnReg:SetCss(POSCSS( GetClassName(oBtnReg), CSS_BTN_FOCAL) )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetRegister
Metodo GetRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetRegister()  CLASS Fly01Login

Local oPnHeader		:= Nil		//Panel cabecario
Local oPnBody 		:= Nil		//Panel principal
Local nPanelWidth 	:= 400		//Largura panel
local nHeightBody 	:= 180		//altura paenl principal1
Local nHeightFooter 	:= 40 		//Altura panel inferior
Local nHeightHeader 	:= 25		//Altura panel cabecalho
Local nWidthUtil 		:= nPanelWIdth - self:nMarginLeft 		          	//Tamanho Panel
Local nWidthField 	:= (nPanelWidth - (3 * self:nMarginLeft))/2		//Tamanho campo
Local nTop 			:=  (self:oOwner:nClientHeight/2-(nHeightBody+nHeightHeader+nHeightFooter))/2 		//Posicao Top
Local nLeft 			:= (self:oOwner:nWidth/2-nPanelWIdth)/2		   //Posicao Esquerda
Local nLine 			:= 7.5		//Linha
Local nLeft2column 	:= self:nMarginLeft * 2 + nWidthField		//Posicao esquerda

//Oculta mensagens anteriores
self:HideAlertWrongPwd()

self:cGetPsw 		   	:= Space(TamSx3("LF_NUMCART")[1])//senha
self:cRepUsrPwd  		:= Space(TamSx3("LF_NUMCART")[1])//Confirmar senha

self:oPnRegister:= tPanel():New(nTop,nLeft,"",self:oOwner,,,,,,nPanelWIdth,nHeightBody+nHeightHeader+nHeightFooter)

oPnHeader:= tPanel():New(0,0,"",self:oPnRegister,,,,,,nPanelWIdth,nHeightHeader)
oPnHeader:SetCss(POSCSS (GetClassName(oPnHeader), CSS_PANEL_LOGINGHEADER ))

@ nLine,self:nMarginLeft SAY oTitle PROMPT STR0011 SIZE nWidthUtil,nHeightHeader OF oPnHeader PIXEL //"Estamos quase lá! Só precisamos de mais algumas informações"
oTitle:SetCss(POSCSS (GetClassName(oTitle), CSS_BREADCUMB ))

oPnBody := tPanel():New(nHeightHeader,0,"",self:oPnRegister,,,,,,nPanelWIdth,nHeightBody)
oPnBody:SetCss(POSCSS (GetClassName(oPnBody), CSS_PANEL_LOGINMAIN ))
CreatePanelLine(oPnBody)


nLine += 5
@ nLine,self:nMarginLeft SAY oSayLoja PROMPT STR0012 SIZE nWidthField,020 OF oPnBody PIXEL //"Nome da Empresa"
oSayLoja:SetCss(POSCSS (GetClassName(oSayLoja), CSS_LABEL_FOCAL, self:aFontLogin ))

@ nLine,nLeft2column SAY oSayEmail PROMPT STR0002 SIZE nWidthField,020 OF oPnBody PIXEL //"Email"
oSayEmail:SetCss(POSCSS (GetClassName(oSayEmail), CSS_LABEL_FOCAL, self:aFontLogin ))

nLine += 12

//Nome da Empresa
@ nLine,self:nMarginLeft GET self:oGetLoja VAR self:cNomeLoja WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL Picture "@!"
self:oGetLoja:SetCss(POSCSS (GetClassName(self:oGetLoja), CSS_GET_FOCAL ))

//Email
@ nLine, nLeft2column GET self:oGetEmail VAR self:cEmail WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL 
self:oGetEmail:SetCss(POSCSS (GetClassName(self:oGetEmail), CSS_GET_FOCAL ))

nLine += 30

@ nLine,self:nMarginLeft SAY oSayPsw PROMPT STR0003 SIZE nWidthField,020 OF oPnBody PIXEL //"Senha"
oSayPsw:SetCss(POSCSS (GetClassName(oSayPsw), CSS_LABEL_FOCAL, self:aFontLogin ))

@ nLine,nLeft2column SAY oSayRepPwd PROMPT STR0013 SIZE nWidthField,020 OF oPnBody PIXEL //"Repetir Senha"
oSayRepPwd:SetCss(POSCSS (GetClassName(oSayRepPwd), CSS_LABEL_FOCAL, self:aFontLogin ))

nLine += 12

//Senha
@ nLine,self:nMarginLeft GET self:oGetPwd VAR self:cGetPsw WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL PASSWORD
self:oGetPwd:SetCss(POSCSS (GetClassName(self:oGetPwd), CSS_GET_FOCAL ))

//Confirmar Senha
@ nLine, nLeft2column GET self:oGetRepPwd VAR self:cRepUsrPwd WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL PASSWORD
self:oGetRepPwd:SetCss(POSCSS (GetClassName(self:oGetRepPwd), CSS_GET_FOCAL ))

nLine += 30

@ nLine,self:nMarginLeft SAY oSayEnd PROMPT STR0014 SIZE nWidthField,020 OF oPnBody PIXEL //"Endereço"
oSayEnd:SetCss(POSCSS (GetClassName(oSayEnd), CSS_LABEL_FOCAL, self:aFontLogin ))

@ nLine,nLeft2column SAY oSayPhone PROMPT STR0015 SIZE nWidthField,020 OF oPnBody PIXEL //"Estado"
oSayPhone:SetCss(POSCSS (GetClassName(oSayPhone), CSS_LABEL_FOCAL, self:aFontLogin ))

nLine += 12

//Endereco
@ nLine,self:nMarginLeft GET self:oGetEnd VAR self:cEndereco WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL Picture "@!"
self:oGetEnd:SetCss(POSCSS (GetClassName(self:oGetEnd), CSS_GET_FOCAL ))

//Estado
self:oListEstado := TListBox():Create(oPnBody, nLine, nLeft2column, Nil, STDUF(), nWidthField,self:nHeightField * 4 ,,,,,.T.,,{|| },,,,)
self:oListEstado:SetCSS( POSCSS (GetClassName(self:oListEstado), CSS_LISTBOX )) 
self:oListEstado:GoTop()


nLine += 30

@ nLine,self:nMarginLeft SAY oSayCid PROMPT STR0016 SIZE nWidthField,020 OF oPnBody PIXEL //"Cidade"
oSayCid:SetCss(POSCSS (GetClassName(oSayCid), CSS_LABEL_FOCAL, self:aFontLogin ))

nLine += 12

//Cidade
@ nLine,self:nMarginLeft GET self:oGetCid VAR self:cCidade WHEN {|| .T. } SIZE nWidthField,self:nHeightField OF oPnBody PIXEL Picture "@!"
self:oGetCid:SetCss(POSCSS (GetClassName(self:oGetCid), CSS_GET_FOCAL ))

oPnFooter := tPanel():New(nHeightHeader+nHeightBody,0,"",self:oPnRegister,,,,,,nPanelWIdth,nHeightFooter)
oPnFooter:SetCss(POSCSS (GetClassName(oPnFooter), CSS_PANEL_LOGINFOOTER ))
CreatePanelLine(oPnFooter)

@ 10, nPanelWidth/2 - nWidthField/2 BUTTON oBtnNewUser PROMPT STR0017 SIZE nWidthField,self:nHeightField+4  ACTION {|| IIF( self:ValidCadastro()  , (self:Fly01Cadastro(), self:HideRegister()) , ) } OF oPnFooter PIXEL //"COMEÇAR A USAR O PDV"
oBtnNewUser:SetCss(POSCSS( GetClassName(oBtnNewUser), CSS_BTN_FOCAL) )

//Foco inicial
self:oGetLoja:SetFocus()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidEmail
Metodo valida email

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ValidEmail(oObjGetValid , cEmail)  CLASS Fly01Login

Local lRet := .F. //Controle de Validacao 

Default oObjGetValid := Nil
Default cEmail 		:= ""


If oObjGetValid <> Nil 

	lRet := .T.
	
	IIf(lRet 	, lRet := "@" 	$ cEmail 			,)
	IIf(lRet 	, lRet := ".COM" 	$ UPPER(cEmail) 	,)
	IIf(lRet 	, lRet := Len(AllTrim(cEmail)) > 6	,)
	
	//troca CSS 
	If lRet
		oObjGetValid:SetCss(POSCSS (GetClassName(oObjGetValid), CSS_GET_FOCAL ))
		self:HideAlertWrong()
	Else
		oObjGetValid:SetCss(POSCSS (GetClassName(oObjGetValid), CSS_GET_ERROR ))
		self:AlertWrong(STR0018)//"Email inválido!"
	EndIf

EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidGetDef
Metodo validacao padrao dos Gets

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ValidGetDef(oObjValid , cSTR)  CLASS Fly01Login

Local lRet := .F. //Controle de Validacao 

Default oObjValid := Nil
Default cSTR 		:= ""


If oObjValid <> Nil 

	lRet := .T.
	
	IIf(lRet 	, lRet := !Empty(cSTR) 			,)
	
	//troca CSS 
	If lRet
		oObjValid:SetCss(POSCSS (GetClassName(oObjValid), CSS_GET_FOCAL ))
		self:HideAlertWrong()
	Else
		oObjValid:SetCss(POSCSS (GetClassName(oObjValid), CSS_GET_ERROR ))
		self:AlertWrong(STR0019)//"Campo de preenchimento Obrigatório não informado!"
	EndIf

EndIf	

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPsw
Metodo Valida senha digitada igual senha confirmada

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ValidPsw(oObjValid)  CLASS Fly01Login

Local lRet := .T. //Controle de Validacao 

Default oObjValid := Nil

IIf(lRet 	, lRet := (AllTrim(self:cRepUsrPwd )	== AllTrim(self:cGetPsw	))	,) 

//troca CSS 
If lRet
	oObjValid:SetCss(POSCSS (GetClassName(oObjValid), CSS_GET_FOCAL ))
	self:HideAlertWrong()
Else
	oObjValid:SetCss(POSCSS (GetClassName(oObjValid), CSS_GET_ERROR ))
	self:AlertWrong(STR0020)//"Senha diferente da informada!"
EndIf



Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCadastro
Metodo Valida Cadastro

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ValidCadastro()  CLASS Fly01Login

Local lRet := .T. //Controle de Validacao 

lRet := lRet .AND. self:ValidGetDef(	self:oGetLoja 		, self:cNomeLoja 	)
lRet := lRet .AND. self:ValidEmail(	self:oGetEmail 		, self:cEmail 	)
lRet := lRet .AND. self:ValidGetDef(	self:oGetLoja 		, self:cGetPsw 	)
lRet := lRet .AND. self:ValidPsw(		self:self:oGetRepPwd 					)
lRet := lRet .AND. self:ValidGetDef(	self:oGetEnd     		, self:cEndereco 	)
lRet := lRet .AND. self:ValidGetDef(	self:oGetCid     		, self:cCidade 	)


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} HideHeader
Metodo HideHeader

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideHeader()  CLASS Fly01Login
Self:oPnHeader:Hide()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} HideLogin
Metodo HideLogin

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideLogin()  CLASS Fly01Login
Self:oPnLogin:Hide()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} HideForgotPassword
Metodo HideForgotPassword

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideForgotPassword()  CLASS Fly01Login
Self:oPnForgetPassword:Hide()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} HideAskRegister
Metodo HideAskRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideAskRegister()  CLASS Fly01Login
Self:oPnAskRegister:Hide()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} HideRegister
Metodo HideRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideRegister()  CLASS Fly01Login
Self:oPnRegister:Hide()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowHeader
Metodo ShowHeader

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ShowHeader()  CLASS Fly01Login
Self:oPnHeader:Show()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowLogin
Metodo ShowLogin

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ShowLogin()  CLASS Fly01Login
Self:oPnLogin:Show()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowForgotPassword
Metodo ShowForgotPassword

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ShowForgotPassword()  CLASS Fly01Login
Self:oPnForgetPassword:Show()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowAskRegister
Metodo ShowAskRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ShowAskRegister()  CLASS Fly01Login
Self:oPnAskRegister:Show()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowRegister
Metodo ShowRegister

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD ShowRegister()  CLASS Fly01Login
Self:oPnRegister:Show()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AlertWrong
Metodo AlertWrong

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD AlertWrong(cMsg) CLASS Fly01Login

Local nWidth 	:= 0 	//Largura 
Local nHeight := 0	//Altura

Default cMsg := ""

If self:oWrongAlert == nil
	
	self:oWrongAlert := FlyMsgBalloon():New(self:oOwner)
	self:oWrongAlert:SetText(cMsg, .T.)
	Self:oWrongAlert:SetMinWidth(self:nWidthTotal)
	self:oWrongAlert:SetBackgroundColor('#FFC926')
	self:oWrongAlert:SetTextColor('#FFFFFF')
	nHeight := self:oWrongAlert:GetHeight()
	self:oWrongAlert:SetTop((self:nTopDefault/2 + nHeight/2)/2)
	nWidth := self:oWrongAlert:GetWidth()
	self:oWrongAlert:SetLeft((self:oOwner:nWidth/2-nWidth)/2)
	self:oWrongAlert:SetImg("fwskin_alert_white.svg")
	self:oWrongAlert:Activate()

Else
	self:oWrongAlert:SetText(cMsg, .T.)
	self:oWrongAlert:Show()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HideAlertWrong
Metodo HideAlertWrong

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideAlertWrong()  CLASS Fly01Login
If self:oWrongAlert <> nil
	Self:oWrongAlert:Hide()
EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAlertWrongPwd
Metodo GetAlertWrongPwd

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetAlertWrongPwd() CLASS Fly01Login

Local nWidth 		:= 0 	//Largura
Local nHeight 	:= 0	//Altura

If self:oAlertWrongPwd == nil
	
	self:oAlertWrongPwd := FlyMsgBalloon():New(self:oOwner)
	self:oAlertWrongPwd:SetText(STR0021, .T.)//"Usuário ou senha incorretos"
	Self:oAlertWrongPwd:SetMinWidth(self:nWidthTotal)
	self:oAlertWrongPwd:SetBackgroundColor('#FFC926')
	self:oAlertWrongPwd:SetTextColor('#FFFFFF')
	nHeight := self:oAlertWrongPwd:GetHeight()
	self:oAlertWrongPwd:SetTop((self:nTopDefault/2 + nHeight/2)/2)
	nWidth := self:oAlertWrongPwd:GetWidth()
	self:oAlertWrongPwd:SetLeft((self:oOwner:nWidth/2-nWidth)/2)
	self:oAlertWrongPwd:SetImg("fwskin_alert_white.svg")
	self:oAlertWrongPwd:Activate()

Else
	self:oAlertWrongPwd:Show()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HideAlertWrongPwd
Metodo HideAlertWrongPwd

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideAlertWrongPwd()  CLASS Fly01Login
If self:oAlertWrongPwd <> nil
	Self:oAlertWrongPwd:Hide()
EndIf
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} GetAlertEmailPwd
Metodo GetAlertEmailPwd

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD GetAlertEmailPwd() CLASS Fly01Login

Local nWidth  := 0   //Tamanho
Local nHeight := 0	//Altura

If self:oAlertEmailPwd == nil
	
	self:oAlertEmailPwd := FlyMsgBalloon():New(self:oOwner)
	self:oAlertEmailPwd:SetText(STR0022, .T.)//"Verifique as informações de senha no e-mail de cadastro"
	self:oAlertEmailPwd:SetBackgroundColor('#7BC400')
	self:oAlertEmailPwd:SetTextColor('#FFFFFF')
	nHeight := self:oAlertEmailPwd:GetHeight()
	self:oAlertEmailPwd:SetTop((self:nTopDefault/2 + nHeight/2)/2)
	nWidth := self:oAlertEmailPwd:GetWidth()
	self:oAlertEmailPwd:SetLeft((self:oOwner:nWidth/2-nWidth)/2)
	self:oAlertEmailPwd:SetImg("fwskin_success_white.svg")
	self:oAlertEmailPwd:Activate()

Else
	self:oAlertEmailPwd:Show()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HideAlertEmailPwd
Metodo HideAlertEmailPwd

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
METHOD HideAlertEmailPwd()  CLASS Fly01Login
If self:oAlertEmailPwd <> nil
	Self:oAlertEmailPwd:Hide()
EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CreatePanelLine
Function CreatePanelLine
Cria uma linha para fazer a borda. Solução para não ficar exibindo 
sobre a borda lateral (diminuindo um pixel de cada lado)
@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreatePanelLine(oOwner)

Local oPanel := Nil //Panel principal

oPanel := tPanel():New(0,0,"",oOwner,,,,,,(oOwner:nWidth/2),1)
oPanel:SetCss(POSCSS (GetClassName(oPanel), CSS_PANEL_LINEAUX, .T. ))

Return oPanel



//-------------------------------------------------------------------
/*/{Protheus.doc} OpenFLY01Open
User Function testes Fly01Login

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function FLY01Open()

Local aRes					:= GetScreenRes()		// Recupera Resolução atual
Local nWidth				:= aRes[1]				// Largura 
Local nHeight				:= aRes[2]				// Altura 
Local oLogin				:= Nil 				//Obj Login
Local cUser 				:= "1"					//Usuario do sistema
Local cPasswd 			:= "1"					//Senha
Local cEmp 				:= "T1"				//Empresa
Local cFil 				:= "D MG 01 "  		//Filial
Local cCallBack 			:= "STIPosMain()"		//Programa principal
Local aTables 			:= {"SLF"}				//Tabelas a serem abertas antes do login 
Local oPanel				:= Nil					//Painel principal

//abre o ambiente com a empresa e filial 
RpcSetEnv( cEmp,cFil, , " ", "FRT", , aTables)

//Seta autenticacao inicial como falso
lAuthentic := .F.

DEFINE DIALOG oDlg Pixel Of GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) 

	oDlg:nWidth 	:= nWidth 
	oDlg:nHeight 	:= nHeight  
	
	oPanel:= tPanel():New(00,000,"",oDlg,,,,,,000,000)
	oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
	oPanel:SetCss('QFrame{ background-color: #DDDDDD; }')
		
		
	oLogin := FLY01LOGIN():New(oPanel)
	oLogin:Activate()


ACTIVATE DIALOG oDlg CENTER 

//Limpa o ambiente, liberando a licença e fechando as conexões 
RpcClearEnv() 

//Caso valid o usuario, inicia autenticacao no Protheus
If lAuthentic 
	Fly01Authentication(cUser, cPasswd, cEmp, cFil, cCallBack)
Else
	MS_QUIT()	//Fecha aplicacao
EndIf

Return .T.



//--------------------------------------------------------
/*/{Protheus.doc} STFUserGetInfo
Retorna informacoes do usuario

@param   	uCampos	 - Informa o campo ou os campos que deseja retornar o valor da SLG
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	uReturn - Retorna o valor do campo ou dos campos que foi solicitado na funcao
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFUserGetInfo(uCampos)

Local aArea		:= GetArea() 				//Salva area
Local uReturn		:= ""						//Retorno da funcao
Local nI			:= 0 						//Variavel de loop
Local xRet			:= ""						//Variavel que armazena o nome do campo

Default uCampos  	:= Nil
	
DbSelectArea("SLF")                                      
DbSetOrder(1)//LF_FILIAL+LF_COD

If DbSeek( xFilial("SLF")+ "USR" )

	If ValType(uCampos) == "A"
	
		uReturn := {}
		
		For nI := 1 To Len(uCampos)
		
			xRet := FieldGet( FieldPos( If(! Left(uCampos[nI],3) == "LF_","LF_","") + uCampos[nI]))
			
			If ValType(xRet) == "C" 
				xRet := xRet
			EndIf
			
			AAdd(uReturn,xRet)
			
		Next nI			
	
	Else
		
		uReturn := FieldGet( FieldPos( If(! Left(uCampos,3) == "LF_","LF_","") + uCampos))		

		If Valtype(uReturn) == "C" 
			uReturn := uReturn
		EndIf
				
	EndIf
	
EndIf

RestArea(aArea)	
	
Return uReturn


//--------------------------------------------------------
/*/{Protheus.doc} UserCreated()
Retorna se ja possui usuario criado

@param   	
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	lRet - Retorna se ja possui usuario criado
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function UserCreated()

Local aArea		:= GetArea() 				//Salva area
Local lRet			:= .T.						//Retorno 

	
DbSelectArea("SLF")                                      
DbSetOrder(1)//LF_FILIAL+LF_COD
If DbSeek( xFilial("SLF")+ "USR" )

	IIf(lRet 	, lRet := !Empty(SLF->LF_ACESSO) 			,)//usuario email
	IIf(lRet 	, lRet := !Empty(SLF->LF_NUMCART) 			,)//Senha
	
Else
	lRet			:= .F.	
EndIf

RestArea(aArea)	
	
Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} UpdUser()
Cria ou atualiza informações do usuario

@param   	
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	lRet - Retorna se cadastrou/atualizou  usuario
@obs     
@sample
/*/
//--------------------------------------------------------
Method Fly01Cadastro()  CLASS Fly01Login

Local aArea		:= GetArea() 				//Salva area
Local lRet			:= .T.						//Retorno 

	
DbSelectArea("SLF")                                      
DbSetOrder(1)//LF_FILIAL+LF_COD
If DbSeek( xFilial("SLF")+ "USR" )

	RecLock("SLF",.F.)

	SLF->LF_FRTAUTO := IIf(self:lAlwaysConnected,"1","0")// lembrar usuario

	SLF->( MsUnLock() )
	
Else
	
	RecLock("SLF",.T.)
	
	SLF->LF_FILIAL  := xFilial("SLF")
	SLF->LF_COD 	  := "USR"       		//Usuario
	SLF->LF_ACESSO  := self:cEmail 		//Email
	
	//Senha
	SLF->LF_NUMCART := Rc4Crypt( AllTrim(self:cGetPsw) , cCryptKey, .T.  )	//Senha criptografada
	
	
	SLF->LF_FRTAUTO := IIf(self:lAlwaysConnected,"1","0")// lembrar usuario
	
	SLF->( MsUnLock() )
	
	//Seta email cadastrado para tela inicial ja estar preenchida
	self:cGetUser := self:cEmail
	
	//Se for versao demostrativa
	If STFTypeOperation() == "DEMONSTRACAO"
		//Valida por 14 dias. Dia atual(1) + 13
		//Grava vencimento da versao demostrativa criptografado
		STFSetStat( {{ "LG_PAFMD5"		, Rc4Crypt( DtoS(Date()+13) ,cCryptKey, .T.)		}} )
	EndIf	
	
EndIf

RestArea(aArea)	
	
Return lRet



//--------------------------------------------------------
/*/{Protheus.doc} VerDemValid()
Valida se a versao demonstrativa esta valida

@param   	
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	lRet - Retorna se ja possui usuario criado
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function VerDemValid()

Local cCryptVenc	  	:= "" //Vencimento criptografado
Local cDecryptVenc  	:= "" //Vencimento decriptografado
Local dDataVenc		:= dDatabase-1 //Inicia data de vencimento sempre vencida
Local lRet				:= .T.	//Retorno

cCryptVenc := AllTrim(STFGetStation("LG_PAFMD5") )

If !Empty(cCryptVenc)
	cDecryptVenc :=  STFRC4DeCrypt( cCryptVenc )		
	dDataVenc := STOD(cDecryptVenc)
EndIf	

//Data maior q o vencimento ou menor que o periodo inicial sai do sistema
If (dDatabase > dDataVenc ) .OR. ( dDatabase < dDataVenc-13 )
	//Seta data antiga para nao mais permitir entrar no sistema
	//Nem se voltar a data conseguira entrar
	lRet := .F.
	STFSetStat( {{ "LG_PAFMD5"		, Rc4Crypt( DtoS(Date()-(365*15)) ,cCryptKey, .T.)		}} )
	FWAlertInfo( STR0023  + CRLF + CRLF + STR0024 + " Fly01.com.br")//"Versão expirada!" ### "Saiba como contratar em:  Fly01.com.br"
	MS_QUIT()	//Fecha aplicacao
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFRC4Crypt
Realiza a geração da Cryptografia
@param   cTxt 		Texto a ser descryptografado
@author  Varejo
@version P11.8
@since   05/05/2015
@return  cToken 		Texto a ser descryptografado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFRC4DeCrypt(cTxt)

Local cRet  := ""
Local nX    := 0

Default cTxt := ""

For nX := 1 To Len(cTxt)
	cRet += chr(CTON( SubStr(cTxt, nX, 2) , 16))
	nX++   
Next nX

cRet := RC4Crypt( cRet , cCryptKey, .F.)

Return cRet


