#INCLUDE "WSTMS010.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSTMS010  ³ Autor ³Gustavo Almeida        ³ Data ³10.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service das funcionalidades de configurações do Portal   ³±±
±±³          ³ TMS - Gestão de Transportes.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
/*/    

WSSTRUCT UserStr
   WSDATA UserLogin	  	      AS String    		 //-- Cadastro de usuário Campo (Login)
	WSDATA UserPsw      	      AS String   		 //-- Cadastro de usuário Campo (Senha)
	WSDATA UserMail 	         AS String     		 //-- Cadastro de usuário Campo (Email)
	WSDATA UserCGC      	      AS String   		 //-- Cadastro de usuário Campo (CNPJ/CPF)
	WSDATA UserDDD		 	      AS String    		 //-- Cadastro de usuário Campo (DDD)
	WSDATA UserTel     	      AS String    		 //-- Cadastro de usuário Campo (Telefone)
	WSDATA UserName    	      AS String   		 //-- Cadastro de usuário Campo (Nome)
	WSDATA UserTradeName       AS String    		 //-- Cadastro de usuário Campo (Nome Reduzido)
	WSDATA UserAdress	         AS String    		 //-- Cadastro de usuário Campo (Endereço)
	WSDATA UserCity            AS String 		  	 //-- Cadastro de usuário Campo (Municipio)
	WSDATA UserState           AS String 		 	 //-- Cadastro de usuário Campo (Estado)
	WSDATA UserDistrict 	      AS String 		 	 //-- Cadastro de usuário Campo (Bairro)
	WSDATA UserZip 	         AS String 		    //-- Cadastro de usuário Campo (Cep)
	WSDATA UserAreaCode	      AS String Optional //-- Região de Origem do Solicitante
ENDWSSTRUCT

WSSTRUCT DLA
	WSDATA DLAAdressSeq     AS String          //-- Sequencia de Endereco
	WSDATA DLAAdress        AS String          //-- Endereco
	WSDATA DLADistrict      AS String          //-- Bairro
	WSDATA DLAAreaCode      AS String Optional //-- Codigo Regiao
	WSDATA DLACity          AS String Optional //-- Municipio
	WSDATA DLAState         AS String Optional //-- Estado
	WSDATA DLAZip           AS String Optional //-- Cep
ENDWSSTRUCT 

WSSTRUCT DUY
	WSDATA DUYAreaGroup     AS String 			 //-- Grupo de Região 
	WSDATA DUYDescription   AS String 			 //-- Descrição da Região 
	WSDATA DUYState         AS String 			 //-- Estado
ENDWSSTRUCT

WSSTRUCT BrowserGeneric
	WSDATA BGCode          AS String          //-- Código Generico
	WSDATA BGDescription   AS String          //-- Descrição Generica
ENDWSSTRUCT 

WSSTRUCT TRGResult
	WSDATA TRGValue01      AS String          //-- Valor de Gatilho 01
	WSDATA TRGValue02      AS String			   //-- Valor de Gatilho 02
	WSDATA TRGValue03      AS String			   //-- Valor de Gatilho 03
	WSDATA TRGValue04      AS String			   //-- Valor de Gatilho 04
	WSDATA TRGValue05      AS String  			//-- Valor de Gatilho 05
ENDWSSTRUCT	

WSSTRUCT Sx3Box
	WSDATA SBValue01       AS String          //-- Valor de box 1
	WSDATA SBDescription   AS String			   //-- Descrição para o valor
ENDWSSTRUCT	

WSSERVICE TMSCFGUSER DESCRIPTION STR0001     //"Serviço de configuração (<b>Portal TMS</b>)"
	
	WSDATA UserCode  		  AS String                    //-- Codigo de usuário de portal
	WSDATA UserLogin	  	  AS String                    //-- Login de usuário de portal
	WSDATA AreaCode	  	  AS String                    //-- Região de Origem do Solicitante
	WSDATA UserData	  	  AS UserStr                   //-- Dados do Usuário
   WSDATA Confirm  	  	  AS Boolean                   //-- Confirmação 
	WSDATA ErrorMsg     	  AS String                    //-- Mensagem de Erro
   WSDATA TypHeader  	  AS String                    //-- Tipo Montagem de Header conforme SX3
   WSDATA TypBrowser  	  AS String                    //-- Tipo Montagem de Browser para F3     
   WSDATA Header     	  AS Array Of BrwHeader        //-- Estrutura em WSXLIB                  
   WSDATA BrowserDLA  	  AS Array Of DLA              //-- Estrutura de Listagem para F3 de Sequencia de Endereços 
   WSDATA BrowserDLC  	  AS Array Of BrowserGeneric   //-- Estrutura de Listagem para F3 de Tipo/Serviço de Transporte
   WSDATA BrowserDUY 	  AS Array Of DUY              //-- Estrutura de Listagem para F3 de Região de Origem
   WSDATA BrowserSB1      AS Array Of BrowserGeneric   //-- Estrutura de Listagem para F3 de Produto
   WSDATA BrowserMG       AS Array Of BrowserGeneric   //-- Estrutura de Listagem para F3 de Embalagem
   WSDATA TrgField        AS String                    //-- Campo configurado para gatilho
   WSDATA TrgVField01     AS String                    //-- Valor 01 Base para gatilho
   WSDATA TrgValueReturn  AS TRGResult                 //-- Retorno do gatilho 
   WSDATA ChgDelAdressSeq AS String                    //-- Seq. para excluir/alteração 
   WSDATA AdressSeq   	  AS DLA                       //-- Objeto com os dados de sequencia de endereços
   WSDATA MVParam         AS String                    //-- Paramentro
   WSDATA ParamValue      AS String                    //-- Valor do Paramentro
   WSDATA TypeDLC  	     AS String Optional           //-- Tipo de Listagem para F3 de Tipo/Serviço de Transporte
   WSDATA FieldSx3        AS String                    //-- Campo em Sx3 para retorno de valores em Box
   WSDATA Sx3BoxValues    AS Array Of Sx3Box           //-- Estrutura de valores de box em Sx3
   
   WSMETHOD PutNewUser
   WSMETHOD PutChgUser
   WSMETHOD GetChgUser
   WSMETHOD GetPwdUser
	WSMETHOD GetFirstLog
	WSMETHOD GetHeader
	WSMETHOD GetBrowserDLA
	WSMETHOD GetBrowserDLC
	WSMETHOD GetBrowserDUY
	WSMETHOD GetBrowserSB1
	WSMETHOD GetBrowserMG
	WSMETHOD GetTrgInfo
	WSMETHOD PutAreaRequestor 
	WSMETHOD PutAdressSeq  
	WSMETHOD GetAdressSeq
	WSMETHOD ChgAdressSeq
	WSMETHOD GetParameterValue
	WSMETHOD GetSx3Box
	
ENDWSSERVICE
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ PutNewUser   ³ Autor ³Gustavo Almeida    ³ Data ³10.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de Inclusão dados do novo usuário.                    ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD PutNewUser WSRECEIVE UserData WSSEND ErrorMsg WSSERVICE TMSCFGUSER
                                                     
Local aArea    	:= GetArea()
Local cAliasQry   := GetNextAlias()
Local nI       	:= 0
Local cUserCod 	:= ""
Local aDirUsu  	:= {}
Local aDestE   	:= { ::UserData:UserMail }
Local aDestI   	:= {}
Local aCabDUE     := {}
Local aCabecario  := {}
Local aIteDVJ     := {}
Local aItens      := {}
Local cSubject 	:= STR0002 //"TOTVS - Confirmação de cadastramento de usuário Portal TMS"
Local cBody    	:= "<font face='verdana' size='2'>"
Local cQuery      := ""
Local lEditMsg 	:= .F.
Local cMsgMail    := ""
Local lExistLogin := .F.
Local lR5      	:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  	:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     	:= .T.

Private lMsErroAuto := .F. 

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	Begin Transaction 
	
	//-- Verificação se já existe login cadastrado em base
	cQuery	:= "SELECT AI3_LOGIN "
	cQuery	+= "  FROM "+RetSqlName("AI3")+" AI3 "
	cQuery	+= " WHERE AI3.AI3_FILIAL = '"+xFilial("AI3")+"'"
	cQuery	+= "   AND AI3.AI3_LOGIN  = '"+::UserData:UserLogin+"'"
	cQuery	+= "   AND AI3.D_E_L_E_T_ = ' ' "
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If (cAliasQry)->(!Eof()) 
		lExistLogin := .T.
		::ErrorMsg  := STR0003+" <br /> "+STR0004 //"Usuário já cadastrado no sistema" ### "Por favor informar outro usuário!"
	EndIf  
	
	(cAliasQry)->(dbCloseArea()) 
	
	
	//-- Verificação se já tem CNPJ/CPF cadastrado em base
	DUE->(dbSetOrder(5))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserData:UserCGC)) .And. !lExistLogin
		lExistLogin := .T.                                                                          
		::ErrorMsg  := STR0007+" <br /> "+STR0008 //"CNPJ/CPF já cadastrado no sistema" ### "Por favor informar outro CNPJ/CPF!"
	EndIf 
	
	//-- Verificação se já tem e-mail cadastrado em base
	cQuery	:= "SELECT DUE_EMAIL "
	cQuery	+= "  FROM "+RetSqlName("DUE")+" DUE "
	cQuery	+= " WHERE DUE.DUE_FILIAL = '"+xFilial("DUE")+"'"
	cQuery	+= "   AND DUE.DUE_EMAIL  = '"+::UserData:UserMail+"'"
	cQuery	+= "   AND DUE.D_E_L_E_T_ = ' ' "
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If (cAliasQry)->(!Eof()) 
		lExistLogin := .T.
		::ErrorMsg  := STR0026+" <br /> "+STR0027 //"E-mail já cadastrado no sistema" ### "Por favor informar outro e-mail!"
	EndIf 
	//-- Fim da Verificação
	
	If !lExistLogin
		//-- Inclusão de Dados em Usuários de Portal
		cUserCod := GetSx8Num("AI3","AI3_CODUSU")
		If __lSX8
			ConfirmSx8()
		EndIf	
		
		RecLock("AI3",.T.)
		AI3->AI3_FILIAL := xFilial("AI3")
		AI3->AI3_LOGIN  := ::UserData:UserLogin
		AI3->AI3_PSW    := ::UserData:UserPsw
		AI3->AI3_NOME   := ::UserData:UserName
		AI3->AI3_CODUSU := cUserCod
		AI3->AI3_ADMIN  := "2" //-- Restrições para Usuário
		AI3->(MsUnLock())
		
		//-- Montagem do cBody do e-mail
		cBody += "<br />" 
		cBody += "<b>"+STR0015+"</b>" //"Acesso ao Portal TMS"
		cBody += "<br />"
		cBody += "<b>"+STR0016+"</b>" //"Login: "
		cBody += ::UserData:UserLogin
		cBody += "<br />"
		cBody += "<b>"+STR0017+"</b>" //"Senha: "
		cBody += ::UserData:UserPsw
		cBody += "<br /></font>"    
		
		//-- Configuração de Acessos
		//-- Webservices do Portal TMS Configuração Inicial
		aAdd(aDirUsu,"TMSCFGUSER")           //-- Configurações de Usuário
		aAdd(aDirUsu,"TMSTRACKING")          //-- Tracking
		aAdd(aDirUsu,"TMSPICKUPORDER")       //-- Solicitação de Coleta 
		aAdd(aDirUsu,"TMSFREIGHTQUOTATION")  //-- Cotação de Frete
		
		For nI := 1 To Len(aDirUsu)
			RecLock("AI6",.T.)                 
		   AI6->AI6_FILIAL := xFilial("AI6")
		   AI6->AI6_CODUSU := cUserCod
			AI6->AI6_WEBSRV := aDirUsu[nI]
			AI6->(MsUnLock())
		Next nI
		
      //-- Solicitante
		aAdd(aCabDUE,{"DUE_DDD"   ,::UserData:UserDDD      ,NIL})
		aAdd(aCabDUE,{"DUE_TEL"   ,::UserData:UserTel      ,NIL})
		aAdd(aCabDUE,{"DUE_NOME"  ,::UserData:UserName     ,NIL})
		aAdd(aCabDUE,{"DUE_NREDUZ",::UserData:UserTradeName,NIL})
		aAdd(aCabDUE,{"DUE_END"   ,::UserData:UserAdress   ,NIL})
		aAdd(aCabDUE,{"DUE_EST"   ,::UserData:UserState    ,NIL})
		aAdd(aCabDUE,{"DUE_MUN"   ,::UserData:UserCity     ,NIL})
		aAdd(aCabDUE,{"DUE_BAIRRO",::UserData:UserDistrict ,NIL})
		aAdd(aCabDUE,{"DUE_CEP"   ,::UserData:UserZip      ,NIL})
		aAdd(aCabDUE,{"DUE_CGC"   ,::UserData:UserCGC      ,NIL})
		aAdd(aCabDUE,{"DUE_EMAIL" ,::UserData:UserMail     ,NIL})
		aAdd(aCabDUE,{"DUE_DATCAD",dDataBase               ,NIL})
		aAdd(aCabDUE,{"DUE_CADPOR","1"                     ,NIL})//-- Inclusão Efetuada via Portal (Pad. "Sim")
		aAdd(aCabDUE,{"DUE_USEPOR",cUserCod                ,NIL})//-- Cód. de usuário para amarração com o solicitante
		aAdd(aCabDUE,{"DUE_TIPTRA","1"                     ,NIL})//-- Tipo de Transporte para cadastro (Pad. "Rodoviário")
		aAdd(aCabDUE,{"DUE_TIPCOL","1"                     ,NIL})//-- Tipo de Coleta  para cadastro (Pad. "Digitada") 
		
		//-- Produto Genérico
		aAdd(aItens,{"DVJ_CODPRO",SuperGetMv("MV_PROGEN",.F.,""),NIL})//-- Produto Genérico
		aAdd(aItens,{"DVJ_CODEMB","CX"                          ,NIL})
		aAdd(aIteDVJ,aItens)
					
		MsExecAuto({|x,y,z| TmsA440(x,y,z)},aCabDUE,aIteDVJ,3)
		
	EndIf
	
	End Transaction

	If !lExistLogin
		If !lMsErroAuto
			::ErrorMsg := STR0009+"<br /><br />"  //"Cadastramento de usuário efetuado com sucesso!"
			lSendMail  := TMSMAIL( aDestE, aDestI, cSubject, cBody, lEditMsg,, @cMsgMail )
			
			If lSendMail
				::ErrorMsg += STR0010 //"Enviado e-mail com usuário e senha para o endereço cadastrado"
			EndIf	
			
			::ErrorMsg += cMsgMail
		Else
	   	::ErrorMsg += "<br /><br /><pre>"+MemoRead(NomeAutoLog())+"</pre>"
	   	Ferase(NomeAutoLog()) 
	   EndIf
	EndIf
		
	RestArea(aArea)

EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ PutChgUser   ³ Autor ³Gustavo Almeida    ³ Data ³ 25.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de alteração de dados do usuário.                     ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD PutChgUser WSRECEIVE UserData, UserCode  WSSEND ErrorMsg WSSERVICE TMSCFGUSER
                                                      
Local aArea    := GetArea()
Local aDestE   := { ::UserData:UserMail }
Local aDestI   := {}
Local cSubject := STR0011 //"TOTVS - Confirmação de alteração de cadastro do Portal TMS"
Local cBody    := "<font face='verdana' size='2'>"+STR0014 //"Alteração de cadastro do portal efetuada para o usuário: "
Local lEditMsg := .F.
Local cMsgMail := ""
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	Begin Transaction 
	
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		RecLock("DUE",.F.)                 
			DUE->DUE_NOME   := ::UserData:UserName
			DUE->DUE_NREDUZ := ::UserData:UserTradeName
			DUE->DUE_END    := ::UserData:UserAdress
			DUE->DUE_EST    := ::UserData:UserState
			DUE->DUE_MUN    := ::UserData:UserCity
			DUE->DUE_BAIRRO := ::UserData:UserDistrict
			DUE->DUE_CEP    := ::UserData:UserZip
			DUE->DUE_CGC    := ::UserData:UserCGC
			DUE->DUE_EMAIL  := ::UserData:UserMail
			DUE->DUE_CDRSOL := ::UserData:UserAreaCode
		MsUnLock()
	EndIf
	
	//-- Montagem do cBody do e-mail
	cBody += "<br /><br />"
	cBody += "<b>"+STR0018+"</b>"+::UserData:UserName+"<br />"           //"Nome: "
	cBody += "<b>"+STR0019+"</b>"+::UserData:UserTradeName+"<br />"      //"Nome Fantasia: "
	cBody += "<b>"+STR0020+"</b>"+::UserData:UserAdress+"<br />"         //"Endereço: "
	cBody += "<b>"+STR0021+"</b>"+::UserData:UserState+"<br />"          //"Estado: "
	cBody += "<b>"+STR0022+"</b>"+::UserData:UserCity+"<br />"           //"Cidade: "
	cBody += "<b>"+STR0023+"</b>"+::UserData:UserDistrict+"<br />"       //"Bairro: "
	cBody += "<b>"+STR0024+"</b>"+::UserData:UserZip+"<br />"            //"CEP: "
	cBody += "<b>"+STR0025+"</b>"+::UserData:UserAreaCode+"<br /></font>"//"Reg.Origem: "
	
	End Transaction

	::ErrorMsg := STR0012+"<br /><br />" //"Alteração de dados do usuário efetuado com sucesso!"
	
	lSendMail  := TMSMAIL( aDestE, aDestI, cSubject, cBody, lEditMsg,, @cMsgMail )
	
	If lSendMail
		::ErrorMsg += STR0013 //'Enviado e-mail informativo de alteração.'
	EndIf	

	::ErrorMsg += STR0029+cMsgMail //'E-mail informativo de alteração não enviado: '

	RestArea(aArea)

EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetChgUser   ³ Autor ³Gustavo Almeida    ³ Data ³25.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para retornar as informações cadastradas do usuário.  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetChgUser WSRECEIVE UserCode WSSEND UserData WSSERVICE TMSCFGUSER
                                                      
Local aArea   := GetArea() 
Local lR5     := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf
//-- Recuperando Dados de Usuários Portal

If lRet
	Begin Transaction 
	
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
	
		::UserData:UserDDD       := DUE->DUE_DDD
		::UserData:UserTel       := DUE->DUE_TEL
		::UserData:UserName      := DUE->DUE_NOME
		::UserData:UserTradeName := DUE->DUE_NREDUZ
		::UserData:UserAdress    := DUE->DUE_END
		::UserData:UserState     := DUE->DUE_EST
		::UserData:UserCity      := DUE->DUE_MUN 
		::UserData:UserDistrict  := DUE->DUE_BAIRRO
		::UserData:UserZip       := DUE->DUE_CEP
		::UserData:UserCGC       := DUE->DUE_CGC 
		::UserData:UserMail      := DUE->DUE_EMAIL
		::UserData:UserAreaCode  := DUE->DUE_CDRSOL
		
	EndIf 
	   
	AI3->(dbSetOrder(1))
	If AI3->(dbSeek(xFiliaL('AI3')+::UserCode))
		::UserData:UserLogin     := AI3->AI3_LOGIN
	EndIf
	
	End Transaction
	
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetPwdUser   ³ Autor ³Gustavo Almeida    ³ Data ³25.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para retornar a senha do usuário via e-mail.          ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetPwdUser WSRECEIVE UserLogin WSSEND ErrorMsg WSSERVICE TMSCFGUSER
                                                      
Local aArea    := GetArea()
Local aDestE   := {}
Local aDestI   := {}
Local cSubject := STR0028 //"TOTVS - Recuperação de senha do Portal TMS"
Local cBody    := "<font face='verdana' size='2'>"
Local lEditMsg := .F.
Local cMsgMail := "" 
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf  

If lRet
	//-- Recuperando Dados de Usuários Portal
	Begin Transaction 

	AI3->(dbSetOrder(2))
	If AI3->(dbSeek(xFiliaL('AI3')+::UserLogin)) //-- Recupera dados de usuário do portal
	
		DUE->(dbSetOrder(4))
		If DUE->(dbSeek(xFiliaL('DUE')+AI3->AI3_CODUSU)) //-- Recupera o e-mail do usuário em solicitante
			aAdd( aDestE, DUE->DUE_EMAIL )		
		EndIf 
	
	EndIf 

	//-- Montagem do cBody do e-mail
	cBody += "<br />" 
	cBody += "<b>"+STR0015+"</b>" //"Acesso ao Portal TMS"
	cBody += "<br />"
	cBody += "<b>"+STR0016+"</b>" //"Login: "
	cBody += ::UserLogin
	cBody += "<br />"
	cBody += "<b>"+STR0017+"</b>" //"Senha: "
	cBody += AI3->AI3_PSW
	cBody += "<br /></font>"
	   
	End Transaction
	
	lSendMail  := TMSMAIL( aDestE, aDestI, cSubject, cBody, lEditMsg,, @cMsgMail )
		
	If lSendMail
		::ErrorMsg += STR0010 //"Enviado e-mail com usuário e senha para o endereço cadastrado"
	EndIf	
		
	::ErrorMsg += cMsgMail
	
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetFirstLog³ Autor ³   Gustavo Almeida    ³ Data ³18.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que verifica se é primeiro acesso ao portal.          ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetFirstLog WSRECEIVE UserCode WSSEND Confirm WSSERVICE TMSCFGUSER

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""                                         
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T. 

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	//-- Mudança para do nModulo para o SIGATMS (43)
	nModulo:= 43
	
	//-- Verificar pelo preenchimento do campo Região de Origem.
	cQuery	:= "SELECT DUE_USEPOR, DUE_CDRSOL "
	cQuery	+= "  FROM "+RetSqlName("DUE")+" DUE "
	cQuery	+= " WHERE DUE.DUE_FILIAL = '"+xFilial("DUE")+"'"
	cQuery	+= "   AND DUE.DUE_USEPOR = '"+::UserCode+"'"
	cQuery	+= "   AND DUE.D_E_L_E_T_ = ' ' "
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If (cAliasQry)->(!Eof()) 
		If Empty((cAliasQry)->DUE_CDRSOL)
			::Confirm := .T.
		Else
			::Confirm := .F.
		EndIf
	Else
		::Confirm := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetHeader  ³ Autor ³   Gustavo Almeida    ³ Data ³20.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna o Header de Regiões de Origem no primeiro ³±±
±±³          ³ acesso ao portal.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetHeader WSRECEIVE TypHeader WSSEND Header WSSERVICE TMSCFGUSER

Local aArea  := GetArea()
Local nX     := 0
Local nI
Local aCamps := {}
Local lR5    := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet   := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	//--  Cabeçalho [Genérico] Codigo | Descrição
	If ::TypHeader = "SB1" .Or. ::TypHeader = "MG" .Or. ::TypHeader = "DLC" //-- Produtos/Embalagem/Tipo de Transportes em F3 
	
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		If ::TypHeader = "SB1" .Or. ::TypHeader = "DLC"
			::Header[nX]:HeaderTitle:= RetTitle("B1_COD")
		ElseIf ::TypHeader = "MG"
			::Header[nX]:HeaderTitle:= RetTitle("AH_UNIMED")
		EndIf
		::Header[nX]:HeaderField   := "CODE"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()    
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		
		::Header[nX]:HeaderTitle:= RetTitle("B1_DESC")
		::Header[nX]:HeaderField   := "DESCRIPTION"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO) 
	
	ElseIf ::TypHeader = "DUY" //-- Região de Origem para F3
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUY_GRPVEN")
		::Header[nX]:HeaderField   := "CODE"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()    
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUY_DESCRI")
		::Header[nX]:HeaderField   := "DESCRIPTION"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		  
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUY_EST")
		::Header[nX]:HeaderField   := "STATE"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()    
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
	
	ElseIf ::TypHeader = "DLA" //-- Sequencia de Endereços em F3
	
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_SEQEND")
		::Header[nX]:HeaderField   := "ADRESSSEQ"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()    
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_END")
		::Header[nX]:HeaderField   := "ADRESS"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO) 
	
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_BAIRRO")
		::Header[nX]:HeaderField   := "DISTRICT"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
	
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_MUN")
		::Header[nX]:HeaderField   := "CITY"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO) 
	
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_EST")
		::Header[nX]:HeaderField   := "STATE"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DUL_CEP")
		::Header[nX]:HeaderField   := "ZIP"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()   
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
	ElseIf ::TypHeader = "SEQEND"
	
		aAdd(aCamps,{"DUL_CDRDES","CDRDES","A"})
		aAdd(aCamps,{"DUL_END"   ,"DULEND","A"})
		aAdd(aCamps,{"DUL_BAIRRO","BAIRRO","A"})
		aAdd(aCamps,{"DUL_MUN"   ,"MUN"   ,"V"})
		aAdd(aCamps,{"DUL_EST"   ,"EST"   ,"V"})
		aAdd(aCamps,{"DUL_CEP"   ,"CEP"   ,"A"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]+aCamps[nI][3]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	   
	ElseIf ::TypHeader = "NUMSOLCOL"
		aAdd(::Header,WSClassNew("BrwHeader"))
		nX++
		::Header[nX]:HeaderTitle   := RetTitle("DT5_NUMSOL")
		::Header[nX]:HeaderField   := "NUMSOL"
		::Header[nX]:HeaderPicture := SX3->X3_PICTURE
		::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
		::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
		::Header[nX]:HeaderType    := SX3->X3_TIPO
		::Header[nX]:HeaderComboBox:= X3CBox()    
		::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
		
	ElseIf ::TypHeader = "SOLCOLCAB"
	
		aAdd(aCamps,{"DT5_DATSOL","DATSOL","V"})
		aAdd(aCamps,{"DT5_HORSOL","HORSOL","V"})
		aAdd(aCamps,{"DT5_DDD"   ,"DDD"   ,"V"})
		aAdd(aCamps,{"DT5_TEL"   ,"TEL"   ,"V"})	
		aAdd(aCamps,{"DT5_CODSOL","CODSOL","V"})	
		aAdd(aCamps,{"DT5_NOME"  ,"NOME"  ,"V"})
		aAdd(aCamps,{"DT5_SEQEND","SEQEND","A"})
		aAdd(aCamps,{"DT5_END"   ,"DT5END","V"})
		aAdd(aCamps,{"DT5_BAIRRO","BAIRRO","V"})
		aAdd(aCamps,{"DT5_MUN"   ,"MUN"   ,"V"})
		aAdd(aCamps,{"DT5_EST"   ,"EST"   ,"V"})
		aAdd(aCamps,{"DT5_CEP"   ,"CEP"   ,"V"})
		aAdd(aCamps,{"DT5_CDRORI","CDRORI","V"})
		aAdd(aCamps,{"DT5_REGORI","REGORI","V"})
		aAdd(aCamps,{"DT5_TIPTRA","TIPTRA","A"})
		aAdd(aCamps,{"DT5_OBS"   ,"OBS"   ,"A"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]+aCamps[nI][3]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	   
	ElseIf ::TypHeader = "SOLCOLITE"
	   
		aAdd(aCamps,{"DUM_ITEM"  ,"ITEM"  ,"V"})
		aAdd(aCamps,{"DUM_CODPRO","CODPRO","A"})
		aAdd(aCamps,{"DUM_DESPRO","DESPRO","V"})
		aAdd(aCamps,{"DUM_CODEMB","CODEMB","A"})	
		aAdd(aCamps,{"DUM_DESEMB","DESEMB","V"})
		aAdd(aCamps,{"DUM_QTDVOL","QTDVOL","A"})
		aAdd(aCamps,{"DUM_PESO"  ,"PESO"  ,"A"})
		aAdd(aCamps,{"DUM_PESOM3","PESOM3","A"})
		aAdd(aCamps,{"DUM_VALMER","VALMER","A"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]+aCamps[nI][3]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next
	   
	ElseIf ::TypHeader = "COTFRECAB"
	
		aAdd(aCamps,{"DT4_DATCOT","DATCOT","V"})
		aAdd(aCamps,{"DT4_HORCOT","HORCOT","V"})
		aAdd(aCamps,{"DT4_DDD"   ,"DDD"   ,"V"})	
		aAdd(aCamps,{"DT4_TEL"   ,"TEL"   ,"V"})
		aAdd(aCamps,{"DT4_CODSOL","CODSOL","V"})
		aAdd(aCamps,{"DT4_NOMSOL","NOMSOL","V"})
		aAdd(aCamps,{"DT4_CDRORI","CDRORI","A"})
		aAdd(aCamps,{"DT4_REGORI","REGORI","V"})
		aAdd(aCamps,{"DT4_CDRDES","CDRDES","A"})
		aAdd(aCamps,{"DT4_REGDES","REGDES","V"})
		aAdd(aCamps,{"DT4_SERTMS","SERTMS","A"})
		aAdd(aCamps,{"DT4_DESSVT","DESSVT","V"})
		aAdd(aCamps,{"DT4_TIPTRA","TIPTRA","A"})
		aAdd(aCamps,{"DT4_DESTPT","DESTPT","V"})
		aAdd(aCamps,{"DT4_TIPFRE","TIPFRE","A"})
		aAdd(aCamps,{"DT4_PRZVAL","PRZVAL","V"})
		aAdd(aCamps,{"DT4_OBS"   ,"OBS"   ,"A"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]+aCamps[nI][3]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	   
	ElseIf ::TypHeader = "COTFREITE"
	
		aAdd(aCamps,{"DVF_ITEM"  ,"ITEM"  ,"V"})
		aAdd(aCamps,{"DVF_CODPRO","CODPRO","A"})
		aAdd(aCamps,{"DVF_DESPRO","DESPRO","V"})
		aAdd(aCamps,{"DVF_CODEMB","CODEMB","A"})	
		aAdd(aCamps,{"DVF_DESEMB","DESEMB","V"})
		aAdd(aCamps,{"DVF_QTDVOL","QTDVOL","A"})
		aAdd(aCamps,{"DVF_PESO"  ,"PESO"  ,"A"})
		aAdd(aCamps,{"DVF_PESOM3","PESOM3","A"})
		aAdd(aCamps,{"DVF_VALMER","VALMER","A"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]+aCamps[nI][3]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	ElseIf ::TypHeader = "PICKUPORDER"
	
		aAdd(aCamps,{"DT5_STATUS","STATUS"})
		aAdd(aCamps,{"DT5_NUMSOL","NUMSOL"})
		aAdd(aCamps,{"DT5_DATSOL","DATSOL"})
		aAdd(aCamps,{"DT5_HORSOL","HORSOL"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next
	    
	ElseIf ::TypHeader = "FREIGHTQUOTATION"
	
		aAdd(aCamps,{"DT4_STATUS","STATUS"})
		aAdd(aCamps,{"DT4_NUMCOT","NUMCOT"})
		aAdd(aCamps,{"DT4_DATCOT","DATCOT"})
		aAdd(aCamps,{"DT4_HORCOT","HORCOT"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	     
	ElseIf ::TypHeader = "TRACKINGBRW"
	
		aAdd(aCamps,{"DT6_STATUS","STATUS"})
		aAdd(aCamps,{"DT6_FILDOC","FILDOC"})
		aAdd(aCamps,{"DT6_DOC"   ,"DOC"   })	
		aAdd(aCamps,{"DT6_SERIE" ,"SERIE" })
		aAdd(aCamps,{"DT6_DATEMI","DATEMI"})
		aAdd(aCamps,{"DT6_HOREMI","HOREMI"})
	   
	   For nI:= 1 To Len(aCamps)
		   aAdd(::Header,WSClassNew("BrwHeader"))
			nX++
			::Header[nX]:HeaderTitle   := RetTitle(aCamps[nI][1])
			::Header[nX]:HeaderField   := aCamps[nI][2]
			::Header[nX]:HeaderPicture := SX3->X3_PICTURE
			::Header[nX]:HeaderSize    := SX3->X3_TAMANHO
			::Header[nX]:HeaderDec     := SX3->X3_DECIMAL
			::Header[nX]:HeaderType    := SX3->X3_TIPO
			::Header[nX]:HeaderComboBox:= X3CBox()    
			::Header[nX]:HeaderOblig   := X3OBRIGAT(SX3->X3_CAMPO)
			::Header[nX]:HeaderF3      := SX3->X3_F3
	   Next 
	   		
	EndIf	
	
	RestArea(aArea)

EndIf
	 
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetBrowserDUY³ Autor ³   Gustavo Almeida  ³ Data ³21.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna as regiões configuradas para o portal TMS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrowserDUY WSRECEIVE NULLPARAM WSSEND BrowserDUY WSSERVICE TMSCFGUSER

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""     
Local nX        := 1
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T. 

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	cQuery := "SELECT DUY_GRPVEN, DUY_DESCRI, DUY_EST, DUY_FILDES "
	cQuery += "  FROM "+RetSqlName("DUY")+" DUY "
	cQuery += " WHERE DUY.DUY_FILIAL  = '"+xFilial("DUY")+"'"
	cQuery += "   AND DUY.DUY_PORTMS  = '1'" //-- Exibe região em portal
	cQuery += "   AND DUY.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY DUY.DUY_GRPVEN "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	While (cAliasQry)->(!Eof()) 
		//-- Mondagem da listagem
		aAdd(::BrowserDUY,WSClassNew("DUY")) 
		::BrowserDUY[nX]:DUYAreaGroup   := (cAliasQry)->DUY_GRPVEN //-- Código da região	
		::BrowserDUY[nX]:DUYDescription := (cAliasQry)->DUY_DESCRI //-- Descrição da região
		::BrowserDUY[nX]:DUYState       := (cAliasQry)->DUY_EST    //-- Estado da Região
		nX++
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetBrowserDLC ³ Autor ³ Gustavo Almeida   ³ Data ³21.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna os tipos de transportes para o portal TMS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrowserDLC WSRECEIVE TypeDLC WSSEND BrowserDLC WSSERVICE TMSCFGUSER

Local aTipTra := {}
Local nX      := 0
Local lR5     := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    := .T.

//-- Mudança para do nModulo para o SIGATMS (43)
Private nModulo := 43  //-- Modulo do TMS

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	If ::TypeDLC = "SERTMS"
		aTipTra := aClone(TMSValField("SERTMS",,"",,.T.))
		
		For nX := 1 To Len(aTipTra)
			aAdd(::BrowserDLC,WSClassNew("BrowserGeneric"))
			::BrowserDLC[nX]:BGCode        := aTipTra[nX][1]         //-- Código do Serviço de transporte	
			::BrowserDLC[nX]:BGDescription := UPPER(aTipTra[nX][2])  //-- Descrição do Serviço de transporte	
		Next nX
		
	Else
		aTipTra := aClone(TMSValField("TIPTRA",,"",,.T.))
		
		For nX := 1 To Len(aTipTra)
			aAdd(::BrowserDLC,WSClassNew("BrowserGeneric"))
			::BrowserDLC[nX]:BGCode        := aTipTra[nX][1]         //-- Código do tipo de transporte	
			::BrowserDLC[nX]:BGDescription := UPPER(aTipTra[nX][2])  //-- Descrição do tipo de transporte	
		Next nX	
	EndIf
EndIf	  

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetBrowserSB1 ³ Autor ³ Gustavo Almeida   ³ Data ³21.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna os produtos para o portal TMS.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrowserSB1 WSRECEIVE NULLPARAM WSSEND BrowserSB1 WSSERVICE TMSCFGUSER

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""     
Local nX        := 1
Local lR5     	 := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    	 := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	cQuery := "SELECT B1_COD, B1_DESC "
	cQuery += "  FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SB5")+" SB5 "
	cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "   AND SB1.B1_FILIAL = SB5.B5_FILIAL
	cQuery += "   AND SB1.B1_COD    = SB5.B5_COD "
	cQuery += "   AND SB5.B5_PORTMS = '1' " //-- Exibe no portal tms
	cQuery += "   AND SB1.D_E_L_E_T_= '' "
	cQuery += "   AND SB5.D_E_L_E_T_= '' " 
	cQuery += " ORDER BY SB1.B1_COD "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	 
	While (cAliasQry)->(!Eof()) 
		//-- Mondagem da listagem 
		aAdd(::BrowserSB1,WSClassNew("BrowserGeneric")) 
		::BrowserSB1[nX]:BGCode        := (cAliasQry)->B1_COD  //-- Código do Produto	
		::BrowserSB1[nX]:BGDescription := (cAliasQry)->B1_DESC //-- Descrição do Produto
		nX++
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetBrowserMG ³ Autor ³ Gustavo Almeida    ³ Data ³21.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna as embalagens cadastradas para o portal   ³±±
±±³Descri‡…o ³ TMS.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrowserMG WSRECEIVE NULLPARAM WSSEND BrowserMG WSSERVICE TMSCFGUSER

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""     
Local nX        := 1
Local lR5     	 := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 	 := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	cQuery := "SELECT AH_UNIMED, AH_DESCPO "
	cQuery += "  FROM "+RetSqlName("SAH")+" SAH "
	cQuery += " WHERE SAH.AH_FILIAL = '"+xFilial("SAH")+"' "
	cQuery += "   AND SAH.D_E_L_E_T_= '' "
	cQuery += " ORDER BY SAH.AH_UNIMED "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	 
	While (cAliasQry)->(!Eof()) 
		//-- Mondagem da listagem
		aAdd(::BrowserMG,WSClassNew("BrowserGeneric")) 
		::BrowserMG[nX]:BGCode        := (cAliasQry)->AH_UNIMED  //-- Código da Embalagem	
		::BrowserMG[nX]:BGDescription := (cAliasQry)->AH_DESCPO  //-- Descrição da embalagem
		nX++
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetBrowserDLA ³ Autor ³Gustavo Almeida    ³ Data ³23.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna as sequencias de endereços cadastradas do ³±±
±±³          ³ usuário.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetBrowserDLA WSRECEIVE UserCode WSSEND BrowserDLA WSSERVICE TMSCFGUSER

Local aArea    := GetArea()
Local cAliasQry:= GetNextAlias()
Local cQuery   := ""     
Local nX       := 1
Local cUserDDD := ""
Local cUserTel := ""
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.
Local cUserCdSol:= ""

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf  

If lRet
	//Usuario      
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		cUserDDD := DUE->DUE_DDD
		cUserTel := DUE->DUE_TEL
		cUserCdSol:= DUE->DUE_CODSOL
	EndIf
	
	cQuery := "SELECT DUL_SEQEND, DUL_END, DUL_BAIRRO, DUL_MUN, "
	cQuery += "       DUL_EST, DUL_CEP "
	cQuery += "  FROM "+RetSqlName("DUL")+" DUL "
	cQuery += " WHERE DUL.DUL_FILIAL  = '"+xFilial("DUL")+"'"
	cQuery += "   AND DUL.DUL_CODSOL = '"+cUserCdSol+"' "
	cQuery += "   AND DUL.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY DUL.DUL_SEQEND "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	While (cAliasQry)->(!Eof())
	  
		//-- Mondagem da listagem
		aAdd(::BrowserDLA,WSClassNew("DLA")) 
		::BrowserDLA[nX]:DLAAdressSeq := (cAliasQry)->DUL_SEQEND
		::BrowserDLA[nX]:DLAAdress    := (cAliasQry)->DUL_END 
		::BrowserDLA[nX]:DLADistrict  := (cAliasQry)->DUL_BAIRRO
		::BrowserDLA[nX]:DLACity      := (cAliasQry)->DUL_MUN 
		::BrowserDLA[nX]:DLAState     := (cAliasQry)->DUL_EST
		::BrowserDLA[nX]:DLAZip       := (cAliasQry)->DUL_CEP    
		nX++
		
		(cAliasQry)->(dbSkip())
		
	EndDo 
	
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetTrgInfo ³ Autor ³   Gustavo Almeida    ³ Data ³18.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna resultados para gatinho.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  
WSMETHOD GetTrgInfo WSRECEIVE TrgField, TrgVField01 WSSEND TrgValueReturn WSSERVICE TMSCFGUSER
  
Local aArea       := GetArea()
Local cAliasQry   := GetNextAlias()
Local cQuery      := ""
Local cUserDDD    := ""
Local cUserTel    := ""
Local aTraDescr   := {}
Local aTratVField := {}
Local nX          := 0                  
Local lR5     		:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 		:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    		:= .T.
Local cUserCdSol	:= ""
//-- Mudança para do nModulo para o SIGATMS (43)
Private nModulo := 43  //-- Modulo do TMS

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	//-- Gatilho para descrição de região
	If ::TrgField = "REGORI" .Or. ::TrgField == "CDRORI" .Or. ::TrgField == "CDRDES"
		cQuery := "SELECT DUY_GRPVEN, DUY_DESCRI, DUY_EST"
		cQuery += "  FROM "+RetSqlName("DUY")+" DUY "
		cQuery += " WHERE DUY.DUY_FILIAL  = '"+xFilial("DUY")+"'"
		cQuery += "   AND DUY.DUY_GRPVEN  = '"+::TrgVField01+"'"
		cQuery += "   AND DUY.D_E_L_E_T_  = ' '"
		cQuery += " ORDER BY DUY.DUY_GRPVEN "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		If (cAliasQry)->(!Eof())
			::TrgValueReturn:TrgValue01 := (cAliasQry)->DUY_DESCRI
			::TrgValueReturn:TrgValue02 := (cAliasQry)->DUY_EST
		Else
			::TrgValueReturn:TrgValue01 := ""
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	//-- Gatilho para descrição de Tipo/Serviço de transpote
	ElseIf ::TrgField == "TIPTRA" .Or. ::TrgField == "SERTMS" 
	
		aTraDescr := TMSValField(::TrgField,,"",,.T.)
		
		For nX:=1 To Len(aTraDescr)
		   If aTraDescr[nX][1] == ::TrgVField01
				::TrgValueReturn:TrgValue01 := UPPER(aTraDescr[nX][2])	
			EndIf
	   Next nX
		
	//-- Gatilho para descrição de produtos
	ElseIf ::TrgField == "CODPRO"
		cQuery := "SELECT B1_COD, B1_DESC "
		cQuery += "  FROM "+RetSqlName("SB1")+" SB1"
		cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery += "   AND SB1.B1_COD    = '"+::TrgVField01+"' "
		cQuery += "   AND SB1.D_E_L_E_T_= '' "
		cQuery += " ORDER BY SB1.B1_COD "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		 
		If (cAliasQry)->(!Eof())
			::TrgValueReturn:TrgValue01 := (cAliasQry)->B1_DESC
		Else
			::TrgValueReturn:TrgValue01 := ""
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	//-- Gatilho para descrição de embalagem
	ElseIf ::TrgField == "CODEMB"
		cQuery := "SELECT AH_UNIMED, AH_DESCPO "
		cQuery += "  FROM "+RetSqlName("SAH")+" SAH"
		cQuery += " WHERE SAH.AH_FILIAL = '"+xFilial("SAH")+"' "
		cQuery += "   AND SAH.AH_UNIMED = '"+::TrgVField01+"' "
		cQuery += "   AND SAH.D_E_L_E_T_= '' "
		cQuery += " ORDER BY SAH.AH_UNIMED "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		 
		If (cAliasQry)->(!Eof())
			::TrgValueReturn:TrgValue01 := (cAliasQry)->AH_DESCPO
		Else
			::TrgValueReturn:TrgValue01 := ""
		EndIf
		(cAliasQry)->(dbCloseArea())
			
	//-- Gatilho para numeração de sequencia de endereço (PWSTMS1C)
	ElseIf ::TrgField == "SEQENDNEW"
		
		//Usuario      
		DUE->(dbSetOrder(4))
		If DUE->(dbSeek(xFiliaL('DUE')+::TrgVField01))
			cUserDDD := DUE->DUE_DDD
			cUserTel := DUE->DUE_TEL
			cUserCdSol := DUE->DUE_CODSOL
		EndIf
	   
		cQuery := "SELECT DUL_SEQEND "
		cQuery += "  FROM "+RetSqlName("DUL")+" DUL"
		cQuery += " WHERE DUL.DUL_FILIAL = '"+xFilial("DUL")+"' "
		cQuery += "   AND DUL.DUL_CODSOL = '"+cUserCdSol+"' "
		cQuery += "   AND DUL.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY DUL_SEQEND DESC "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		 
		If (cAliasQry)->(!Eof())
			::TrgValueReturn:TrgValue01 := StrZero((Val((cAliasQry)->DUL_SEQEND))+1,2)
		Else
			::TrgValueReturn:TrgValue01 := "01"
		EndIf
		(cAliasQry)->(dbCloseArea())
				 
	//-- Gatilho para  de sequencia de endereço (PWSTMS22)
	ElseIf ::TrgField == "SEQEND"
		
		//Usuario      
		DUE->(dbSetOrder(4))
		aTratVField := STRTOKARR(::TrgVField01, ';')
		
		If DUE->(dbSeek(xFiliaL('DUE')+aTratVField[1]))
			cUserDDD := DUE->DUE_DDD
			cUserTel := DUE->DUE_TEL
			cUserCdSol:= DUE->DUE_CODSOL
		EndIf
	   
	   If aTratVField[2] <> "NIL"
			cQuery := "SELECT DUL_END, DUL_MUN, DUL_EST, DUL_CEP, DUL_BAIRRO "
			cQuery += "  FROM "+RetSqlName("DUL")+" DUL"
			cQuery += " WHERE DUL.DUL_FILIAL = '"+xFilial("DUL")+"' "
			cQuery += "   AND DUL.DUL_CODSOL = '"+cUserCdSol+"' "
			cQuery += "   AND DUL.DUL_SEQEND = '"+aTratVField[2]+"' "
			cQuery += "   AND DUL.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			
			If (cAliasQry)->(!Eof())
				::TrgValueReturn:TrgValue01 := (cAliasQry)->DUL_END
				::TrgValueReturn:TrgValue02 := (cAliasQry)->DUL_MUN
				::TrgValueReturn:TrgValue03 := (cAliasQry)->DUL_EST
				::TrgValueReturn:TrgValue04 := (cAliasQry)->DUL_CEP
				::TrgValueReturn:TrgValue05 := (cAliasQry)->DUL_BAIRRO
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			::TrgValueReturn:TrgValue01 := DUE->DUE_END
			::TrgValueReturn:TrgValue02 := DUE->DUE_MUN
			::TrgValueReturn:TrgValue03 := DUE->DUE_EST
			::TrgValueReturn:TrgValue04 := DUE->DUE_CEP
			::TrgValueReturn:TrgValue05 := DUE->DUE_BAIRRO  
		EndIf
			
	EndIf
	RestArea(aArea)
EndIf
	 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ PutAreaRequestor³ Autor ³Gustavo Almeida ³ Data ³28.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para atualizar regiao do solicitante                  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD PutAreaRequestor WSRECEIVE AreaCode,UserCode WSSEND Confirm WSSERVICE TMSCFGUSER

Local aAreaDUE := DUE->(GetArea())
Local lR5     	:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 	:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    	:= .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFilial('DUE')+UserCode))
		RecLock("DUE",.F.) 
	   DUE->DUE_CDRSOL := ::AreaCode
		MsUnLock()    
	EndIf
	
	::Confirm := .T.
	
	RestArea(aAreaDUE)
EndIf

Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ PutAdressSeq ³ Autor ³Gustavo Almeida    ³ Data ³24.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para Inclusão/Alterar de dados para sequencia de      ³±±
±±³          ³ endereços do solicitante.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD PutAdressSeq WSRECEIVE UserCode, AdressSeq WSSEND ErrorMsg WSSERVICE TMSCFGUSER

Local aAreaDUE := DUE->(GetArea())
Local aRotAuto := {}
Local lR5     	:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 	:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    	:= .T.

Private lMsErroAuto := .F.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet 
	//-- Inclusão de Sequencia
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		DUE->(dbSetOrder(1))
		aRotAuto := { { 'DUL_CODSOL'   , DUE->DUE_CODSOL         ,Nil },;
						  { 'DUL_END'   , ::AdressSeq:DLAAdress  ,Nil },;
						  { 'DUL_BAIRRO', ::AdressSeq:DLADistrict,Nil },;
						  { 'DUL_CDRDES', ::AdressSeq:DLAAreaCode,Nil },;
						  { 'DUL_MUN'   , ::AdressSeq:DLACity    ,Nil },;
						  { 'DUL_EST'   , ::AdressSeq:DLAState   ,Nil },;
						  { 'DUL_CEP'   , ::AdressSeq:DLAZip     ,Nil } }
		MSExecAuto({|x,y| TMSA450(x,y)},aRotAuto,3)	
		If lMsErroAuto
		   ::ErrorMsg := "<pre>"+MemoRead(NomeAutoLog())+"</pre>"
		   Ferase(NomeAutoLog())
		Else
			::ErrorMsg := ""	   
		EndIf
	EndIf
		
	RestArea(aAreaDUE)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetAdressSeq ³ Autor ³Gustavo Almeida    ³ Data ³24.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de recuperação de dados para alteração/visualização de³±±
±±³          ³ sequencia de endereços do solicitante.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetAdressSeq WSRECEIVE UserCode, ChgDelAdressSeq WSSEND AdressSeq WSSERVICE TMSCFGUSER

Local aArea    := GetArea()
Local lR5     	:= GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 	:= VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    	:= .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	//-- Sequencia de endereço solicitada
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		If DUL->(dbSeek(xFiliaL('DUL')+DUE->DUE_DDD+DUE->DUE_TEL+::ChgDelAdressSeq))
			::AdressSeq:DLAAdressSeq := DUL->DUL_SEQEND 
			::AdressSeq:DLAAdress    := DUL->DUL_END
			::AdressSeq:DLADistrict  := DUL->DUL_BAIRRO
			::AdressSeq:DLAAreaCode  := DUL->DUL_CDRDES
			::AdressSeq:DLACity      := DUL->DUL_MUN
			::AdressSeq:DLAState     := DUL->DUL_EST
			::AdressSeq:DLAZip       := DUL->DUL_CEP
		EndIf   
	
	EndIf
	
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ ChgAdressSeq ³ Autor ³Gustavo Almeida    ³ Data ³24.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para Alterar de dados para sequencia de endereços do  ³±±
±±³          ³ solicitante.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD ChgAdressSeq WSRECEIVE UserCode, AdressSeq, ChgDelAdressSeq WSSEND ErrorMsg WSSERVICE TMSCFGUSER

Local aArea         := GetArea()
Local lR5     		  := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao 		  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    		  := .T.
Private lMsErroAuto := .F.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		DUE->(dbSetOrder(1))
		aRotAuto := { { 'DUL_CODSOL'   , DUE->DUE_CODSOL          ,Nil },;
						  { 'DUL_SEQEND', ::AdressSeq:DLAAdressSeq,Nil },;
						  { 'DUL_END'   , ::AdressSeq:DLAAdress   ,Nil },;
						  { 'DUL_BAIRRO', ::AdressSeq:DLADistrict ,Nil },;
						  { 'DUL_CDRDES', ::AdressSeq:DLAAreaCode ,Nil },;
						  { 'DUL_MUN'   , ::AdressSeq:DLACity     ,Nil },;
						  { 'DUL_EST'   , ::AdressSeq:DLAState    ,Nil },;
						  { 'DUL_CEP'   , ::AdressSeq:DLAZip      ,Nil } }
		MSExecAuto({|x,y| TMSA450(x,y)},aRotAuto,4)	
		If lMsErroAuto
		   ::ErrorMsg := "<pre>"+MemoRead(NomeAutoLog())+"</pre>"
		   Ferase(NomeAutoLog())
		Else
			::ErrorMsg := ""	   
		EndIf
	EndIf 
	
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetParameterValue³ Autor ³Gustavo Almeida ³ Data ³17.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para retronar valor de um paramentro.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetParameterValue WSRECEIVE MVParam WSSEND ParamValue WSSERVICE TMSCFGUSER 

Local lR5     := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	::ParamValue := SuperGetMV(::MVParam,.F.,"")
	
	If Valtype(::ParamValue) == "L"
		If ::ParamValue
			::ParamValue := "T"
		Else
			::ParamValue := "F"
		EndIf
	ElseIf Valtype(::ParamValue) == "N"
		::ParamValue := Str(::ParamValue)
	EndIf
EndIf

Return .T.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetSx3Box   ³ Autor ³Gustavo Almeida      ³ Data ³22.03.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método para retronar valor de um paramentro.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/  

WSMETHOD GetSx3Box WSRECEIVE FieldSx3 WSSEND Sx3BoxValues WSSERVICE TMSCFGUSER

Local aSx3Box := {}
Local nI      := 0
Local lR5     := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet    := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	aSx3Box:= aClone(RetSx3Box( Posicione("SX3", 2, FieldSx3, "X3CBox()" ),,, 1 ))
	
	For nI:= 1 To Len(aSx3Box)
	   aAdd(::Sx3BoxValues,WSClassNew("Sx3Box"))
		::Sx3BoxValues[nI]:SBValue01     := aSx3Box[nI][2]
		::Sx3BoxValues[nI]:SBDescription := aSx3Box[nI][3]
	Next nI 
EndIf

Return .T.
