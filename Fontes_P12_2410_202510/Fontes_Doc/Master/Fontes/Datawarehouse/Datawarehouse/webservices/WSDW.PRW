#INCLUDE "WSDW.ch"
#include "dwincs.ch"
#Include "APWEBSRV.CH"

WSService SigaDW description STR0001 NAMESPACE "http://webservices.microsiga.com.br/sigadw.apw" //"Ferramenta para administra็ใo e uso de <i>Datawarehouses</i>. Permitindo criar e manter as estruturas das dimens๕es, cubos e consultas, al้m de possuir uma ferramenta proprietแria para <i>ETL (Extraction, Transformation and Load)</i> de dados.<br>Podendo acessar as tabelas do <i>SigaAdv</i> e de sistemas legados."
  WSData SESSIONID 		as String
  WSData HOST      		as String
  WSData USUARIO   		as String
  WSData SENHA    		as String
  WSDATA DW             as String
  WSDATA DWID             as String
  WSData DWNAME   		as String 
  WSData WSSESSION 		as String
  WSData CONSULTA  		as String
  WSData RETORNO   		as String
  WSData USERLOGIN		as String
  WSData USERPASSWORD 	as String
  WSData RETBOOL   		as Boolean  
  WSData CUBEID   		as Integer
  WSData CONSULTAID 	as Integer
  WSData QUERYLIST  	as Array Of QueryList
  WSData DWLIST  		as Array Of DWList  
  WSData CUBELIST	  	as Array Of CubeList  
  WSData CUBEDETAIL	  	as Array Of CubeDetail
  WSData CONSULTASTRU  	as Array Of ConsultaStru
  WsData CONVALUE		as Array Of DWConFieldValue
  WSData RETVALUE  		as Boolean OPTIONAL
  WsData CONFIELDX		as DWConFieldName OPTIONAL
  WsData CONFIELDY		as DWConFieldName OPTIONAL
  WsData INDICATORS  	as DWConFieldName OPTIONAL

  WSMethod LOGIN         description STR0002 //"Inicia uma sessใo de trabalho no servi็o do <b>SigaDW</b>."
  WSMethod LOGOUT        description STR0003 //"Encerra a sessใo de trabalho, previamente iniciada."
  WSMethod LOGINDW       description STR0004 //"Inicia uma conexใo a um <i>datawarehouse</i> para uso."
  WSMethod LOGOUTDW      description STR0005 //"Encerra a conexใo, previamente iniciada."
  WSMethod INICTABLE     description STR0006 //"Inicializa uma consulta em formato de tabela."
  WSMethod INICGRAPH     description STR0007 //"Inicializa uma consulta em formato de grแfico."
  WSMethod PROCCONS      description STR0008 //"Processa a pagina็ใo dos dados de uma consulta previamente inicializada." 
  WSMethod RETDW         description STR0009 //"Retorna uma lista dos <i>datawarehouses</i> disponํveis para acesso." 
  WSMethod RETCUBES 	 description STR0010 //"Retorna uma lista dos <i>cubos</i> disponํveis para acesso." 
  WSMethod RETCUBE  	 description STR0011 //"Retorna os detalhes de um <i>cubo</i>." 
  WSMethod LISTCONSULTAS description STR0012 //"Retorna uma lista das <i>consultas</i> disponํveis para acesso." 
  WSMethod RETCONSULTA	 description STR0013 //"Retorna uma lista dos <i>cubos</i> disponํveis para acesso." 

EndWSService

WSSTRUCT ConsultaStru
	WSDATA ID	 		As String
	WSDATA NAME 		As String
	WSDATA ALIAS	 	As String 
	WSDATA DESCRIPTION 	As String 
	WSDATA FIELDSY 		As Array Of FieldsDet 	OPTIONAL
	WSDATA FIELDSX 		As Array Of FieldsDet 	OPTIONAL
	WSDATA MEASURES	 	As Array Of FieldsDet 	OPTIONAL //Indicadores
ENDWSSTRUCT

WSSTRUCT FieldsValue
	WSDATA VALOR 	As String
ENDWSSTRUCT

WSSTRUCT FieldsDet
	WSDATA NAME 		As String
	WSDATA TYPE 		As String
	WSDATA SIZE    		As String
	WSDATA DECIMAL  	As String 
	WSDATA DESC		  	As String 
	WSDATA ID		  	As String 
	WSDATA TEMPORAL 	As String 
	WSDATA VALUES	 	As Array Of FieldsValue OPTIONAL	
ENDWSSTRUCT

WSSTRUCT CubeList
	WSDATA IMPORTATIONDATE 	As String
	WSDATA IMPORTATIONHOUR 	As String
	WSDATA ID    			As String
	WSDATA NAME  			As String 
	WSDATA DESCRIPTION  	As String 
	WSDATA INUSE    	   	As Boolean
ENDWSSTRUCT

WSSTRUCT QueryList
	WSDATA ID    			As String
	WSDATA NAME  			As String 
	WSDATA DESCRIPTION  	As String 
	WSDATA QUERYTYPE	   	As String 
	WSDATA LOGIN    	   	As String 
 	WSDATA USERNAME	   		As String 
ENDWSSTRUCT

WSSTRUCT CubeDetail
	WSDATA ID    			As String
ENDWSSTRUCT
           
WSSTRUCT DWList
	WSDATA NAME  			As String 
	WSData ID 	            as Integer
ENDWSSTRUCT

WSSTRUCT DWConFieldName
	WSDATA NAME  			As String 
ENDWSSTRUCT

WSSTRUCT DWConFieldValue
	WSDATA NAME  			As String 
	WSDATA TYPE  			As String 
	WSDATA VALUE 			As String 
ENDWSSTRUCT

/*--------------------------------------------------------------------------------------
login(Host,Dw,UserLogin,UserPassword) 
		Efetua o login

Args.: 	UserLogin, estrutura (string, string) com o login e senha .
	 	Host : Nome do Host Exemplo: 127.0.0.1/dw
		Dw	 : Nome do DataWareHouse

Ret. : 	string, retorna um SessionID que serแ utilizado nas demais chamadas
--------------------------------------------------------------------------------------*/
WSMethod LOGIN WSReceive HOST,DW,USERLOGIN,USERPASSWORD WSSend SessionID WSService SigaDW
	local lRet := .t.
	initSession()
	
	::SessionID := cBIMakeKey("SIGADW")
	
	SPE_Login	:= alltrim(::USERLOGIN)
	SPE_Senha	:= alltrim(::USERPASSWORD)
	SDW_HOST	:= alltrim(::HOST)
	SDW_USER	:= SPE_Login
	SDW_PASS	:= SPE_Senha
	SDW_SESSION := "" //Sera Carregado quando o usuario logar no DW.
	SDW_DW 		:= ""
	
	saveSession(::SessionID)
	lRet := login(SDW_HOST, SDW_USER, SDW_PASS, ::SessionID)
	
	if !lRet
		SetSoapFault(STR0032,STR0033 + ::SessionID)//"ERRO HTTPPOST LOGIN" -  "Erro ao executar HTTPPOST de login. Session:ID "
	endif
	
	if lRet .and. ! empty(::DW)
		lRet := loginDw(::DW, ::SessionID)
	endif
return lRet

/*--------------------------------------------------------------------------------------
loginDW(SessionID) 
		Conecta um datawarehouse

Args.: 	SessionID	: sessao do Datawarehouse
		DWNAME		: Nome do DataWareHouse

Ret. : 	boolean, retorna .t. se conseguir conectar.
--------------------------------------------------------------------------------------*/
WSMethod LOGINDW WSReceive SESSIONID, DWNAME WSSend RETBOOL WSService SigaDW
	if loadSession(::SESSIONID)
		if ! empty(::DWNAME)
			::RETBOOL := loginDw(::DWNAME,::SessionID)
		else
			SetSoapFault(STR0014,STR0015)//"ERRO HTML LOGINDW" - "Informe o nome do DataWareHouse."
			::RETBOOL	:=	.f.
		endif
	endif
return ::RETBOOL

/*-------------------------------------------------------------------------------------
logout(SessionID) 	Efetuar o logout.
Args.: SessionID, string de identifica็ใo da sessใo
Ret. : boolean: true se conseguir desconectar
--------------------------------------------------------------------------------*/
WSMethod LOGOUT WSReceive SESSIONID WSSend RETBOOL WSService SigaDW
	local lRet := .t.

	if !loadSession(::SessionID)
		lRet := .f.
	else
		::RetBool := lRet
 	endif

return lRet

/*-------------------------------------------------------------------------------------
logout(SessionID) Desconecta do Datawarehouse.
Args.: SessionID, string de identifica็ใo da sessใo
Ret. : boolean: true se conseguir desconectar
--------------------------------------------------------------------------------*/
WSMethod LOGOUTDW WSReceive WSSESSION WSSend RETORNO WSService SigaDW
	local lRet := .t.

  	if !loadSession(::WSSESSION)
    	lRet := .f.
		::RETORNO := ""    	
  	else
        SDW_DW		:= ""
		SDW_SESSION := ""
		saveSession(::WSSESSION)//Apos as alteracoes grava os novos dados na sessao.
    	::RETORNO	:= "VARIAVIES DELETADAS"
  	endif                       
  
return lRet

/*-------------------------------------------------------------------------------------
INICTABLE(SessionID,CONSULTA)
	Executa uma consulta em formato de tabela.
Args.: SessionID: string de identifica็ใo da sessใo
	   Consulta	: ID da consulta.	
Ret. : string Pagina com a consulta
--------------------------------------------------------------------------------*/
WSMethod INICTABLE WSReceive WSSESSION, CONSULTA WSSend RETORNO WSService SigaDW
	local cRet := "", lRet := .t.
	local nPos := 0
	
	::RETORNO := ""
	
	if !loadSession(::WSSESSION)
		lRet := .f.
	else
			SDW_URL := SDW_HOST+"/w_sigadw3.apw"
			SDW_GETURL := "type=1&oper=10&showTitle=false&action="+AC_QUERY_EXEC+"&id="+::CONSULTA
			lRet := .t.
	endif
	
	saveSession(::WSSESSION)

return lRet

/*-------------------------------------------------------------------------------------
PROCCONS(SessionID)
	Processa a pagina็ใo dos dados de uma consulta previamente inicializada. 
Args.: SessionID: string de identifica็ใo da sessใo
Ret. : string Pagina com a consulta
--------------------------------------------------------------------------------*/
WSMethod PROCCONS WSReceive WSSESSION WSSend RETORNO WSService SigaDW

	local cRet := ""
	local lRet := .t.
	
	::RETORNO := ""
	
	if !loadSession(::WSSESSION)
		lRet := .f.
	else
	 	cRet := wsHttpPost(SDW_URL, SDW_GETURL,,,aGetCook())

		if empty(cRet)
			SetSoapFault(STR0019,STR0020)//"ERRO HTTPPOST TABPAGE" - "Erro ao executar HTTPPOST do tabpage"
			lRet := .f.
		else
			::Retorno := cRet
		endif
	endif
	
	saveSession(::WSSESSION)

Return lRet

/*-------------------------------------------------------------------------------------
INICGRAPH(SessionID,CONSULTA)
		Inicializa uma consulta em formato de grแfico
Args.: 	SessionID	: string de identifica็ใo da sessใo.
		Consulta	: Consulta para processamento.
Ret. : string Pagina com a consulta
--------------------------------------------------------------------------------*/
WSMethod INICGRAPH WSReceive WSSESSION, CONSULTA WSSend RETORNO WSService SigaDW
	Local lRet		:= .t.

	::RETORNO := ""
	SDW_URL		:= ""
	SDW_GETURL	:= ""

	if !loadSession(::WSSESSION)
	   	lRet := .f.
	else
	
			SDW_URL := SDW_HOST+"/w_sigadw3.apw"
			SDW_GETURL := "type=2&oper=10&showTitle=false&action="+AC_QUERY_EXEC+"&id="+::CONSULTA
			lRet := .t.
	
	endif
	
	saveSession(::WSSESSION)
  
return lRet

/*-------------------------------------------------------------------------------------
LISTCONSULTAS(SessionID)
		Retorna a estrutura de uma consulta.
Args.: 	SessionID	: string de identifica็ใo da sessใo.
Ret. : RETCONSULTA : Estrutura da consulta
--------------------------------------------------------------------------------*/
WSMethod RETCONSULTA WSReceive WSSESSION,CONSULTAID,RETVALUE WSSend CONSULTASTRU WSService SigaDW
	Local lRet := .t.
	Local oXmlCons := nil
	Local oConsultas := nil
	Local cXmlCons := nil
	Local cError := ""
	Local cWarning := ""
	Local cParameters := ""
	
	::CONSULTASTRU := {}
	
	if loadSession(::WSSESSION)
		cParameters	:= "idConsulta="+dwStr(::CONSULTAID)
		cParameters	+= "&listValues=" + iif(::RETVALUE,"true","false")
		
		
		cXmlCons := wsHttpPost(SDW_HOST+"/w_sigadw3.apw", "action="+AC_WS_REQUEST+"&cmd="+CMD_GETCONSTRUCT, cParameters,,aGetCook())
		
		
		if(valtype(cXmlCons)== "C" .and. ! empty(cXmlCons))
			oXmlCons 	:= XmlParser(cXmlCons, '_', @cError, @cWarning)
			if empty(cError) .and. valtype(XmlChildEx(oXmlCons:_CONSULTAS,"_CONSULTA"))!="U"
				oConsultas	:= oXmlCons:_CONSULTAS:_CONSULTA
				aadd(::CONSULTASTRU,WsClassNew("ConsultaStru"))
				
				//Adicionando os campos do eixo y
				if valtype(XmlChildEx(oConsultas:_DIMENSIONS_Y,"_DIMENSION_Y"))!="U"
					addConStruItem(oConsultas:_DIMENSIONS_Y:_DIMENSION_Y,@::CONSULTASTRU[1]:FIELDSY,::RETVALUE)
				endif
				
				//Adicionando os campos do eixo x
				if valtype(XmlChildEx(oConsultas:_DIMENSIONS_X,"_DIMENSION_X"))!="U"
					addConStruItem(oConsultas:_DIMENSIONS_X:_DIMENSION_X,@::CONSULTASTRU[1]:FIELDSX,::RETVALUE)
				endif
				
				//Adicionando os indicadores
				if valtype(XmlChildEx(oConsultas:_INDICADORES,"_INDICADOR"))!="U"
					addConStruItem(oConsultas:_INDICADORES:_INDICADOR,@::CONSULTASTRU[1]:MEASURES,::RETVALUE)
				endif
				
				//Detalhes da consulta
				::CONSULTASTRU[1]:DESCRIPTION	:=	oConsultas:_DESCRIPTION:TEXT
				::CONSULTASTRU[1]:NAME			:=	oConsultas:_NAME:TEXT
				::CONSULTASTRU[1]:ALIAS			:=	oConsultas:_ALIAS:TEXT
				::CONSULTASTRU[1]:ID			:=	oConsultas:_ID:TEXT
			else
				SetSoapFault(STR0023,STR0024)//"ERRO HTTPPOST LISTCONSULTAS" -"Nao foi possivel parsear o XML."
				lRet := .f.
			endif
		else
			SetSoapFault(STR0023,STR0025)//"ERRO HTTPPOST LISTCONSULTAS" - "Nao existe dados para criacao do XML."
			lRet := .f.
		endif
	else
		lRet := .f.
	endif

return lRet


static function addConStruItem(oConsulta,oStruConsulta,lInsDet)
    Local nItem	:=	0
    
    if valtype(oConsulta)== "A"
		//Adicionando a estrutura dos campos.				
		oStruConsulta := {}
		nContador 	:=	len(oConsulta)
		for nItem := 1 to  nContador
			aadd(oStruConsulta,WsClassNew("FieldsDet"))
			oStruConsulta[nItem]:NAME 		:= oConsulta[nItem]:_NAME:TEXT
			oStruConsulta[nItem]:SIZE 		:= oConsulta[nItem]:_SIZE:TEXT
			oStruConsulta[nItem]:TYPE 		:= oConsulta[nItem]:_TYPE:TEXT 
			oStruConsulta[nItem]:DECIMAL 	:= oConsulta[nItem]:_DECIMAL:TEXT 
			oStruConsulta[nItem]:DESC		:= oConsulta[nItem]:_DESC:TEXT 
			oStruConsulta[nItem]:ID			:= oConsulta[nItem]:_ID:TEXT 
			oStruConsulta[nItem]:TEMPORAL	:= oConsulta[nItem]:_TEMPORAL:TEXT 
			//Adicionando os valores
			if lInsDet
				addConValues(@oStruConsulta[nItem]:VALUES,oConsulta[nItem]:_VALUES)
			endif			
		next nItem
	else
		oStruConsulta := {}
		aadd(oStruConsulta,WsClassNew("FieldsDet"))
		oStruConsulta[1]:NAME 		:= oConsulta:_NAME:TEXT
		oStruConsulta[1]:SIZE 		:= oConsulta:_SIZE:TEXT
		oStruConsulta[1]:TYPE 		:= oConsulta:_TYPE:TEXT 
		oStruConsulta[1]:DECIMAL 	:= oConsulta:_DECIMAL:TEXT 
		oStruConsulta[1]:DESC		:= oConsulta:_DESC:TEXT 
		oStruConsulta[1]:ID			:= oConsulta:_ID:TEXT 
		oStruConsulta[1]:TEMPORAL	:= oConsulta:_TEMPORAL:TEXT 

		//Adicionando os valores
		if lInsDet
			addConValues(@oStruConsulta[1]:VALUES,oConsulta:_VALUES)
		endif			
	endif					

return .t.

/*
*Adiciona os valores da consulta.
*/
static function addConValues(oConsulta,oValues)
	Local nItem		:=	0
	Local aValores	:=	{}
	Local nContador	:=	0
	
	if valtype(XmlChildEx(oValues,"_VALUE"))!="U"
		
		if (valtype(oValues:_VALUE)== "A")
			aValores	:= oValues:_VALUE
			oConsulta := {}
			nContador 	:=	len(aValores)
			
			for nItem := 1 to  nContador
				aadd(oConsulta,WsClassNew("FieldsValue"))
				oConsulta[nItem]:VALOR	:= aValores[nItem]:TEXT
			next nItem
						
		else
			oConsulta := {}
			aadd(oConsulta,WsClassNew("FieldsValue"))
			oConsulta[1]:VALOR 		:= oValues:_VALUE:TEXT
		endif
	endif   

return .t.


/*-------------------------------------------------------------------------------------
LISTCONSULTAS(SessionID)
		Lista as consultas que este usuแrio tem acesso.
Args.: 	SessionID	: string de identifica็ใo da sessใo.
Ret. : QUERYLIST : Lista com as consultas
--------------------------------------------------------------------------------*/
WSMethod LISTCONSULTAS WSReceive WSSESSION,DWID WSSend QUERYLIST WSService SigaDW
	Local lRet		 := .t.
	Local nItem		 :=	0
	Local nQtdCons	 :=	0
	Local oXmlCons	 :=	nil
	Local oConsultas :=	nil
	
	::QUERYLIST		:=	{}
	
	if loadSession(::WSSESSION)
		oXmlCons := getListConsultas(DWID)
		if(valtype(oXmlCons)== "O")
			oConsultas	:= oXmlCons:_CONSULTAS:_CONSULTA
			if valtype(oConsultas) == "O"
				oConsultas := { oConsultas }
			endif
			nQtdCons 	:= len(oConsultas)
			for nItem := 1 to  nQtdCons
				aadd(::QUERYLIST,WsClassNew("QueryList"))
				::QUERYLIST[nItem]:ID          := oConsultas[nItem]:_ID:TEXT
				::QUERYLIST[nItem]:NAME        := oConsultas[nItem]:_NOME:TEXT
				::QUERYLIST[nItem]:DESCRIPTION := oConsultas[nItem]:_DESCRICAO:TEXT
				::QUERYLIST[nItem]:QUERYTYPE   := oConsultas[nItem]:_TIPO:TEXT
				::QUERYLIST[nItem]:LOGIN       := oConsultas[nItem]:_LOGIN:TEXT
				::QUERYLIST[nItem]:USERNAME    := oConsultas[nItem]:_USER_NAME:TEXT
			next nItem
			//		else
			//		    SetSoapFault(STR0023,STR0024)//"ERRO HTTPPOST LISTCONSULTAS" - "Nao foi possivel parsear o XML."
			//		    lRet := .f.
		endif
	else
		SetSoapFault(STR0023,STR0025)//"ERRO HTTPPOST LISTCONSULTAS" - "Nao existe dados para criacao do XML."
		lRet := .f.
	endif

return lRet


/*-------------------------------------------------------------------------------------
RETCUBES(SessionID)
		Lista os Cubos que este usuแrio tem acesso.
Args.: 	SessionID	: string de identifica็ใo da sessใo.
Ret. : CUBELIST : Lista com os cubos
--------------------------------------------------------------------------------*/
WSMethod RETCUBES WSReceive WSSESSION WSSend CUBELIST WSService SigaDW
	Local lRet		:= .t.
	Local nItem		:=	0
	Local nQtdCube	:=	0
	Local oXmlCube	:=	nil
	Local oCubos	:=	nil
	Local cXmlCubos	:=	nil
	Local cError	:=	""
	Local cWarning	:=	""
	
	::CUBELIST		:=	{}
	
	if loadSession(::WSSESSION)
		
		cXmlCubos	:= wsHttpPost(SDW_HOST+"/w_sigadw3.apw", "action="+AC_WS_REQUEST+"&cmd="+CMD_GETXMLCUBOS,,,aGetCook())
		
		
		if(valtype(cXmlCubos)== "C")
			oXmlCube 	:= XmlParser(cXmlCubos, '_', @cError, @cWarning)
			
			if empty(cError) .and. valtype(XmlChildEx(oXmlCube:_CUBESLIST,"_CUBELIST"))!="U"
				oCubos	:= oXmlCube:_CUBESLIST:_CUBELIST
				if valtype(oCubos)== "A"
					nQtdCube:= len(oCubos)
					
					for nItem := 1 to  nQtdCube
						aadd(::CUBELIST,WsClassNew("CubeList"))
						::CUBELIST[nItem]:ID				:= oCubos[nItem]:_ID:TEXT
						::CUBELIST[nItem]:NAME				:= oCubos[nItem]:_NOME:TEXT
						::CUBELIST[nItem]:DESCRIPTION 		:= oCubos[nItem]:_DESCRICAO:TEXT
						
						::CUBELIST[nItem]:IMPORTATIONDATE	:= ""
						::CUBELIST[nItem]:IMPORTATIONHOUR	:= ""
						::CUBELIST[nItem]:INUSE				:= .T.
						
					next nItem
				else
					aadd(::CUBELIST,WsClassNew("CubeList"))
					::CUBELIST[1]:ID		   		:= oCubos:_ID:TEXT
					::CUBELIST[1]:NAME				:= oCubos:_NOME:TEXT
					::CUBELIST[1]:DESCRIPTION 		:= oCubos:_DESCRICAO:TEXT
					
					::CUBELIST[1]:INUSE				:= .T.
					::CUBELIST[1]:IMPORTATIONDATE	:= ""
					::CUBELIST[1]:IMPORTATIONHOUR	:= ""
					
				endif
				
			else
				SetSoapFault(STR0023,STR0024)//"ERRO HTTPPOST LISTCONSULTAS" - "Nao foi possivel parsear o XML."
				lRet := .f.
			endif
		else
			SetSoapFault(STR0023,STR0025)//"ERRO HTTPPOST LISTCONSULTAS" - "Nao existe dados para criacao do XML."
			lRet := .f.
		endif
	else
		lRet := .f.
	endif
	
return lRet


/*-------------------------------------------------------------------------------------
RETCUBE(SessionID,CubeID)
		Lista os Cubos que este usuแrio tem acesso.
Args.: 	SessionID	: string de identifica็ใo da sessใo.
		CubeID		: string de identifica็ใo do cubo.
Ret. : CUBEDETALTHE : Lista com os detalhes do cubo
--------------------------------------------------------------------------------*/
WSMethod RETCUBE WSReceive WSSESSION,CUBEID WSSend CUBEDETAIL WSService SigaDW
	Local lRet		:= .t.
	Local oXmlCube	:=	nil
	Local cXmlCubo 	:=	nil
	Local cError	:=	""
	Local cWarning	:=	""
	
	::CUBELIST		:=	{}
	
	if loadSession(::WSSESSION)
		
		cXmlCubos	:= wsHttpPost(SDW_HOST+"/w_sigadw3.apw", "action="+AC_WS_REQUEST+"&cmd="+CMD_GETXMLCUBO,"&idCube="+dwStr(CUBEID),,aGetCook())
		
		
		if(valtype(cXmlCubo )== "C")
			oXmlCube 	:= XmlParser(cXmlCubo , '_', @cError, @cWarning)
		else
			SetSoapFault(STR0023,STR0025)//"ERRO HTTPPOST LISTCONSULTAS","Nao existe dados para criacao do XML."
			lRet := .f.
		endif
	else
		lRet := .f.
	endif
	
return lRet


/*-------------------------------------------------------------------------------------
RETDW(SessionID)
		Lista os DataWareHouses
Args.: SessionID	: string de identifica็ใo da sessใo.
Ret. : DWLIST 		: Lista com as consultas
--------------------------------------------------------------------------------*/
WSMethod RETDW WSReceive WSSESSION WSSend DWLIST WSService SigaDW
	Local lRet 		:= .t.
	Local aDWList   := {}
	Local nDw		:=	0
	Local oDwList	:= nil
	
	::DWLIST := {}
	
	if loadSession(::WSSESSION)
		aDWList := getRetDW(::WSSESSION)
		if valType(aDWList) == "U"
			SetSoapFault(STR0028,STR0029)//"ERRO HTTPPOST RETDW","Erro ao executar HTTPPOST de Retorno de DW"
			lRet := .f.
		else
			for nDw := 1 to len(aDWList)
				oDwList	:= WsClassNew("DwList")
				oDwList:NAME := aDWList[nDw][1]
				oDwList:ID := aDWList[nDw][2]
				aadd(::DWLIST,oDwList)
			next nDw
			
			lRet := nDw > 1
			if !lRet
				SetSoapFault(STR0028,STR0030)//"ERRO HTML DW","HTML sem informa็ใo de DW"
			endif
		endif
	else
		lRet := .f.
	endif
    
return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณinitSessionบAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a Sessao.                                               บฑฑ
ฑฑบ          ณ                                  						   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ นฑฑ
ฑฑบUse       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ ฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
static function initSession()

    public SDW_HOST 	:= ""
    public SDW_USER 	:= ""
    public SDW_PASS 	:= ""
    public SDW_DW 		:= ""
    public SDW_SESSION 	:= ""
    public SDW_URL 		:= ""
    public SDW_GETURL 	:= ""

return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณsaveSessionบAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSalva a Sessao                                               บฑฑ
ฑฑบ          ณArquivo: Numero da sessao		      						   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ นฑฑ
ฑฑบUse       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ ฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
static Function saveSession(Arquivo)

	save all like "SDW_*" to &(Arquivo)

return .t.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอ อออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณloadSessionบAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุออ ออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz um post.                                                 บฑฑ
ฑฑบ          ณcSessionID: Numero da sessao								   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ นฑฑ
ฑฑบUse       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ ผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ ฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function loadSession(cSessionID)
	Local lRet := file(iif(valType(cSessionID)=="C" .and. ! empty(cSessionID), cSessionID, time()) + ".mem")

	If ( lRet )
		initSession()
     	restore from &(cSessionID) additive
	Else              
		DWCallStack()
        SetSoapFault("Session",STR0031)//"Sessao invalida. Para execucao deste servico e necessario fazer o login."
	EndIf
		
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณwsHttpPostบAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz um post.                                                บฑฑ
ฑฑบ          ณcUrl: URL executar esta funcao o usuario deve estar logado  บฑฑ
ฑฑบ          ณcpGet: Parametros do Post.                                  บฑฑ
ฑฑบ          ณcpPost: Post                                                บฑฑ
ฑฑบ          ณnTimeout: Timeout                                           บฑฑ
ฑฑบ          ณaHeader : Cookie da sessao                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function wsHttpPost(cURL, cpGet, cpPost, nTimeout, aHeader)
	if !("http" $ cURL)
		cURL :=	"http://" + cURL
	endif
	
	if valType(cpGet) == "C"
		cpGet += "&ws=on"
	endif

return httppost(cURL, cpGet, cpPost, nTimeout, aHeader)

                       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณlogin   	บAuthor ณAlan Candido        บ Date ณ  27/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua o login do usuแrio ao SigaDW.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function login(acDW_HOST, acUSER, acPASS, acSessionID)
	Local lRet    := .t.
	Local cPagRet := ""
	Local nPos    := 0
	
	cPagRet := wsHttpPost(acDW_HOST+"/w_sigadw3.apw","action=login","edUser="+acUSER+"&edPassword="+acPASS,,{"Content-Type: application/x-www-form-urlencoded"})
	if ! (valtype(cPagRet) == "U")
		lRet := "?action=selectdw" $ cPagRet
		nPos := at("DWSESSIONID", cPagRet)
	endif
	
	if nPos == 0
		SetSoapFault(STR0035,STR0036 + acSessionID)//"ERRO RETORNO DWSESSION" - "HTML sem informa็ใo de session. SessionID: "
		lRet := .f.
	else
		SDW_SESSION := substr(cPagRet, nPos+22, 255)
		SDW_SESSION := substr(SDW_SESSION, 1, at(">", SDW_SESSION)-2)
		saveSession(acSessionID)	//Apos as alteracoes grava os novos dados na sessao.
	endif

return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณloginDw	บAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega um Dataware house.                                  บฑฑ
ฑฑบ          ณAntes  de executar esta funcao o usuario deve estar logado  บฑฑ
ฑฑบ          ณno sistema.                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function loginDw(cDWName, cWsSession)
	Local cPagRet	 :=	".t."
	Local lRet		 :=	.t.
	Local nPos 		 := 0
	Local aDWList    := {}
	Local cDwSession := ""
	
	aDWList := getRetDW(cWsSession)
	if valType(aDWList) == "U"
		SetSoapFault(STR0032,STR0033+ cWsSession + " - P1")//"ERRO HTTPPOST LOGIN" -  "Erro ao executar HTTPPOST de login. Session:ID "
		lRet := .f.
	else
		nPos := ascan(aDWList, { |x| alltrim(x[1]) == alltrim(cDWName) })
		if nPos == 0
			SetSoapFault(STR0032,STR0033+ cWsSession + " - P2")//"ERRO HTTPPOST LOGIN" -  "Erro ao executar HTTPPOST de login. Session:ID "
			lRet := .f.
		else
			cPagRet := wsHttpPost(SDW_HOST+"/w_sigadw3.apw","action=selectdw&dw="+dwStr(aDWList[nPos,2]),,,aGetCook())
			if empty(cPagRet)
				SetSoapFault(STR0032,STR0033+ cWsSession + " - P3")//"ERRO HTTPPOST LOGIN" -  "Erro ao executar HTTPPOST de login. Session:ID "
				lRet := .f.
			elseif ! ("aph/apl: h_dwBuildAba()" $ cPagRet)
				SetSoapFault(STR0032, STR0034 + cWsSession)//"ERRO HTML LOGIN" - "HTML com login invแlido. SessionID: "
				lRet := .f.
			endif
		endif
	endif	
	
	cPagRet := wsHttpPost(SDW_HOST+"/w_sigadw.apw","cmd=login","edUsuario="+SDW_USER+"&edPassword="+SDW_PASS+"&edDatawarehouse="+cDWName+"&cbFull=on",,{"Content-Type: application/x-www-form-urlencoded"})
	if empty(cPagRet)
		SetSoapFault(STR0032,STR0033+ cWsSession)//"ERRO HTTPPOST LOGIN" -  "Erro ao executar HTTPPOST de login. Session:ID "
		lRet := .f.
	elseif rat("./h_m00main.apw", cPagRet) <> 0
		SetSoapFault(STR0032, STR0034 + cWsSession)//"ERRO HTML LOGIN" - "HTML com login invแlido. SessionID: "
		lRet := .f.
	else
		nPos := at("DWSESSIONID", cPagRet)
		if nPos == 0
			SetSoapFault(STR0035,STR0036 + cWsSession)//"ERRO RETORNO DWSESSION" - "HTML sem informa็ใo de session. SessionID: "
			lRet := .f.
		else
			cDwSession 	:= substr(cPagRet, nPos+22, 255)
			cDwSession 	:= substr(cDwSession, 1, at(">", cDwSession)-2)
			SDW_SESSION	:= cDwSession
			SDW_DW		:= cDwName
			//Apos as alteracoes grava os novos dados na sessao.
			saveSession(cWsSession)
		endif
	endif

return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณaGetCook	บAuthor ณAlexandre Silva     บ Date ณ  20/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Cook com a sessao do DW                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function aGetCook()    
	conout('----->>>> ' + SDW_SESSION)
return { "Content-Type: application/x-www-form-urlencoded" ,;
         "Cookie: SESSIONID=" + SDW_SESSION + "; DW="+SDW_DW }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณRPOisR4     บAuthor ณAlan Candido      บ Date ณ  27/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDevolve a lista de DWดs                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function getRetDW(acSession)		
	Local cRet    := ""
	Local aRet    := {}
	Local aDwList := nil
	Local nInd    := 0
	
	cRet := wsHttpPost(SDW_HOST+"/w_sigadw3.apw", "action="+AC_WS_REQUEST+"&cmd="+CMD_GETLISTDW,,,aGetCook())
	if !empty(cRet)
		aDwList := {}
		aRet := DWToken(cRet, "!")
		aEval(aRet, { |x| x := dwToken(x, "|"), aadd(aDwList, { x[1], x[2] })})
	endif	

return aDwList

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณRPOisR4     บAuthor ณAlan Candido      บ Date ณ  27/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDevolve o release do RPO                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function getListConsultas(DWID)     
	Local cXmlCons := ""
	Local oXmlCons := NIL
	Local cError   := ""
	Local cWarning := ""
	
	cXmlCons := wsHttpPost(SDW_HOST+"/w_sigadw3.apw", "action="+AC_WS_REQUEST+"&cmd="+CMD_GETXMLCONSULTAS+"/" +alltrim(cBIStr(DWID))+ "/",,,aGetCook())

	if(valtype(cXmlCons)== "C")
		oXmlCons := XmlParser(cXmlCons, '_', @cError, @cWarning)
		if !empty(cError) .or. valtype(XmlChildEx(oXmlCons:_CONSULTAS,"_CONSULTA")) =="U"
			oXmlCons := nil
		endif
	endif
return oXmlCons    
