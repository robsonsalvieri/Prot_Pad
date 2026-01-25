#INCLUDE "PROTHEUS.CH"                                                   	
#INCLUDE "TOPCONN.CH"
#INCLUDE "WSPLSPTUBATCH.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PTWebA530
EndPoint de recebimento de um PTU A530 - baixarAvisoWS 

@author  PLS TEAM
@version P12
@since   02/05/18
/*/
//------------------------------------------------------------------- 
Function PTWebA530() 
Local cRet       := ""
Local cNameSpace := "" 
Local cErro := ""  
Local aRet       := {}
Local aRetObj    := {}
Local aRetVld    := {}   
Local aCab       := {}
Local lRetObj    := .F.
Local cEnv := GetEnvServer()
Local cEmp := AllTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
Local cFil := AllTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))

If !Empty(cEmp) 
	RpcSetEnv( cEmp,cFil,,,cEnv,,)  
	aRetObj := PLVldXmlP2(HttpOtherContent(),"a530","nc_Transacoes-V1_00_00.xsd","V1_00_00")
	HttpCtType( "text/xml; charset=iso-8859-1") //Indica o Enconding
   
	lRetObj    := aRetObj[1]
	oObjXml    := aRetObj[2] 
	cRootNS    := aRetObj[3] 
	cErro      := aRetObj[4]
	cNameSpace := aRetObj[5]   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se tudo ok, processa o arquivo          								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetObj
		cRet := PLSP530(oObjXml,cRootNS,cNameSpace)     
		PtLogPTWeb("530",cRet,"Gerando Resposta a530","Soap de resposta:")
	Else
		cRet := STR0001 + cErro //"Erro ao carregar o Soap: "
	EndIf  
Else
    cRet := STR0002 +cEnv+STR0003 //"A ENVIRONMENT [" ### " ] não tem declarada as variaveis cEmp e cFil."
EndIf

Return(cRet)        



//-------------------------------------------------------------------
/*/{Protheus.doc} PLVldXmlP2
Ajusta um soap de recebimento para montagem do objeto de trabalho

@author  PLS TEAM
@version P12
@since   02/05/18
/*/
//------------------------------------------------------------------- 
Function PLVldXmlP2(cSoap,cLayout,cSchema,cVersion,cNameSpace)
Local cSoapAux   := ''   
Local cMsg       := ''
Local nPos       := 0
Local nX         := 0
Local lRet       := .T. 
Local oXml
Local oObjXml   
Local cErro      := ""
Local cAviso     := ""
Local cRoot      := ""
Local aNS        := {}
Default cVersion := "V1_00_00"          
Default cNameSpace := ''
//Monta log 
PtLogPTWeb(Substr(cLayout,2,len(cLayout)),cSoap,"Recebendo Transacao "+cLayout,"Soap Recebido:")

nPos := At("BODY",Upper(cSoap))
cSoapAux := Substr(cSoap,nPos+4,len(cSoap))    
nPos := At(">",Upper(cSoapAux))
cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))  

nPos := At("BODY",Upper(cSoapAux)) 
For nX := 1 to nPos 
	If Substr(cSoapAux,nPos-nX,1) == "<"
		cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
		Exit
	EndIf   
Next

If nPos == 0 .Or. Empty(cSoap)
	cErro := STR0004 //"Erro com o pacote Soap recebido"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria diretorios                                   					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !ExistDir("\plsptu")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\") == 3  
		cErro := STR0005 //"Não foi possivel criar o diretorio \plsptu"    
	EndIf      
EndIf

If !ExistDir("\plsptu\"+cLayout)
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\"+cLayout) == 3  
		cErro := STR0005+cLayout //"Não foi possivel criar o diretorio \plsptu\"   
	EndIf      
EndIf

If !ExistDir("\plsptu\"+cLayout+"\schemas\")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\"+cLayout+"\schemas\") == 3
		cErro := STR0005+cLayout+"\schemas\" //"Não foi possivel criar o diretorio \plsptu\"
	EndIf 
EndIf  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve erro fatal finaliza							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !Empty(cErro)
	Return {.f.,oXml,cRoot,cMsg,cNameSpace}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identificar o namespace                           					     	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
nPos := At("CABECALHOTRANSACAO",Upper(cSoapAux))   
If Substr(cSoapAux,nPos-1,1) == ":"
	nPosNamSpc := nPos-2
	For nX := 1 to nPosNamSpc
		If Substr(cSoapAux,nPosNamSpc-nX,1) == "<"     
			cNameSpace := Substr(cSoapAux,nPosNamSpc - nX +1,nPosNamSpc - (nPosNamSpc - nX))
			Exit
		EndIf   
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para montagem do arquivo para validacao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                        
cSoapAux := EncodeUTF8(cSoapAux)
nPos := At(">",Upper(cSoapAux))      
cSoapPt1 := Substr(cSoapAux,1,nPos-1)
cSoapPt2 := Substr(cSoapAux,nPos,len(cSoapAux))
cSoapXml := cSoapPt1 + ' xmlns:'+cNameSpace+'="http://nc.unimed.coop.br/schemas/'+cVersion+'"'+cSoapPt2  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a validacao do XML gerado pelo TranXml com o XSD 				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If (!XmlSVldSch( cSoapXml, "\plsptu\"+cLayout+"\schemas\"+cSchema, @cErro,@cAviso)) 
	cMsg := Iif( !Empty(cErro),STR0006 +cErro,"") //"Erro: "
	cMsg += Iif( !Empty(cAviso),STR0007+cAviso,"") //"Aviso: "
 	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto com o Soap enviado                  					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If lRet
	oXML := TXmlManager():New()
	lRet := oXML:Parse(cSoapXml)
	If lRet 
		aNS := oXML:XPathGetRootNsList()
		oXML:XPathRegisterNs( aNS[1][1],aNS[1][2] )
		cRoot := aNS[1][1]
	Else
		cErro := oXML:Error()
	EndIf
EndIf

Return {lRet,oXml,cRoot,cMsg,cNameSpace}


//-------------------------------------------------------------------
/*/{Protheus.doc} PTSoapRes
Monta cabecalho e fim do arquivo de Soap de Resposta

Parametros:
	cSoapRet - string com o soap
	cTagTrans - tag com o nome do arquivo
	lIni - se esta abrindo o cabecalho
	lFim - se esta encerrando o arquivo
	aCab - array com dados do cabecalho
	cHash - hash do arquivo
	cTagBody - indica uma tag de abertura/fechamento de body diferenciada
	lWS - indica se exibe a string 'WS' nas tags principais
	cVersion - versao do arquivo
	lTagBody - se gera a tag body (avaliar se sera utilizado)

@author  PLS TEAM
@version P12
@since   21/07/16
/*/
//------------------------------------------------------------------- 
Function PTSoapRes(cSoapRet,cTagTrans,lIni,lFim,aCab,cHash,cTagBody,lWS,cVersion,lTagBody) 
Local cNameSpace := "" //Arquivo de retorno envia namespace vazio
Default lIni  := .F.                                          
Default lFim  := .F. 
Default aCab  := {}
Default cHash := ""   
Default cTagBody  := ""
Default lWS      := .T.
Default cVersion := "V1_00_00"
Default lTagBody := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa arquivo														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIni  
	cSoapRet += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' + Chr(13)+Chr(10)
	cSoapRet += '<soap:Body>'+ Chr(13)+Chr(10)
	cSoapRet += '<'+cTagTrans+iif(lWS,'WS','')+' xmlns="http://nc.unimed.coop.br/schemas/'+cVersion+'">' + Chr(13)+Chr(10)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta cabecalho															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSoapRet += '<'+cNameSpace+'cabecalhoTransacao>'+ Chr(13)+Chr(10)
	cSoapRet += '<'+cNameSpace+'tipoTransacao>'+aCab[1]+'</'+cNameSpace+'tipoTransacao>'+ Chr(13)+Chr(10)
	cHash += aCab[1]
	If !Empty(aCab[2])
		cSoapRet += '<'+cNameSpace+'codigoUnimedOrigemMensagem>'+cValtoChar(Val(aCab[2]))+'</'+cNameSpace+'codigoUnimedOrigemMensagem>' + Chr(13)+Chr(10)
		cHash += cValtoChar(Val(aCab[2]))
	Endif	
	If !Empty(aCab[3])
		cSoapRet += '<'+cNameSpace+'codigoUnimedDestinoMensagem>'+cValtoChar(Val(aCab[3]))+'</'+cNameSpace+'codigoUnimedDestinoMensagem>'+ Chr(13)+Chr(10)
		cHash += cValtoChar(Val(aCab[3]))
	EndIf  
	cSoapRet += '<'+cNameSpace+'versaoTransacao>'+ aCab[4]+'</'+cNameSpace+'versaoTransacao>'+ Chr(13)+Chr(10)
	cHash += aCab[1]
	cSoapRet += '</'+cNameSpace+'cabecalhoTransacao>' + Chr(13)+Chr(10)
	If lTagBody
		cSoapRet += '<'+cNameSpace+IIF(!Empty(cTagBody),cTagBody,cTagTrans)+'>'+ Chr(13)+Chr(10)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza arquivo														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFim  
	If lTagBody
		cSoapRet += '</'+cNameSpace+IIF(!Empty(cTagBody),cTagBody,cTagTrans)+'>'+ Chr(13)+Chr(10)
	EndIf	  
	cSoapRet += '<'+cNameSpace+'hash>'+cHash+'</'+cNameSpace+'hash>'+ Chr(13)+Chr(10)
	cSoapRet += '</'+cNameSpace+cTagTrans+iif(lWS,'WS>','>') + Chr(13)+Chr(10)    
	cSoapRet += '</soap:Body>' + Chr(13)+Chr(10)
	cSoapRet += '</soap:Envelope>' + Chr(13)+Chr(10)
Endif

Return cSoapRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} PTVldXmlLy
Valida XML de Envio (resposta ou envio de mensagem) com seu respectivo XSD

@author  PLS TEAM
@version P12
@since   02/05/18
/*/
//------------------------------------------------------------------- 
Function PTVldXmlLy(cSoapXml,lEnv,cSchema,cVersion,cLayout)    
Local cNameSpace:= "v1"
Local cErro     := ""
Local cAviso    := ""  
Local cMsg      := ""  
Local cAux1     := ""
Local cAux2     := ""
Local cVersao   := ""
Local lOk       := .T.
Default lEnv      := .F.
Default cSchema   := "nc_Transacoes-V1_00_00.xsd"
Default cVersion  := "V1_1_0 "

If lEnv   
	cSoapXml  := Substr(cSoapXml,At("<soapenv:Body>",cSoapXml) + len("<soapenv:Body>")) 
	cAux1     := Substr(cSoapXml,1,At(">",cSoapXml)- 1)   
	cAux2     := Substr(cSoapXml,At(">",cSoapXml),len(cSoapXml))   
	cVersao   := ' xmlns="http://nc.unimed.coop.br/schemas/'+cVersion+'" xmlns:'+cNameSpace+'="http://nc.unimed.coop.br/schemas/'+cVersion+'"' 
	cSoapXml  := cAux1 + cVersao + cAux2
	cSoapXml  := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
	cSoapXml  := Substr(cSoapXml,1,At("</soapenv:Body>",cSoapXml) -1)    
Else
	If At("soap:Fault",cSoapXml) > 0 
		cSoapXml := Substr(cSoapXml,At("<detail>",cSoapXml) + len("<detail>")) 
		cSoapXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
		cSoapXml := Substr(cSoapXml,1,At("</detail>",cSoapXml) -1) 
	Else
		cSoapXml := Substr(cSoapXml,At("<soap:Body>",cSoapXml) + len("<soap:Body>")) 
		cSoapXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'+cSoapXml
		cSoapXml := Substr(cSoapXml,1,At("</soap:Body>",cSoapXml) -1) 
	EndIf   
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a validação do XML gerado pelo TranXml com o XSD 				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If (!XmlSVldSch( cSoapXml, "\plsptu\"+cLayout+"\schemas\"+cSchema, @cErro,@cAviso)) 
	cMsg := STR0008 //"Problemas ao gerar arquivo de envio\resposta."
	cMsg += Iif( !Empty(cErro),STR0006 +cErro,"") //"Erro: " 
	cMsg += Iif( !Empty(cAviso),STR0007+cAviso,"") //"Aviso: "
 	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {}) 
 	lOk := .F.
EndIf 

Return({lOk,cMsg}) 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRetTagWB
Funcao para retornar um elemento de um Objeto baseado em um XML

Parametros:    
	cNameSpace -> Namespace padrao da estrutura
	cPai       -> Tag da estrutura principal
	cTree      -> Estrutura de tags a partir da pai que se deseja obeter a informacao

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//------------------------------------------------------------------- 
Function PLRetTagW2(oObjXml,cNameSpace,cTree,cTpDado,nCompZero)
Local cString := ""
Local xRet    := ""
Local nX      := 0
Local aAux    := {}
Local aNS     := {}
Local nChar   := 0
Default cNameSpace  := ""
Default cTpDado    := "C"
Default nCompZero  := 0

aAux := StrTokArr( cTree,"\")
If (nChar := At(":",oObjXml:cPath)) > 0
	cString := "/"+cNameSpace+Substr(oObjXml:cPath,nChar,len(oObjXml:cPath))
Else
	cString := oObjXml:cPath
EndIf
	
For nX := 1 to len(aAux)
	cString += "/"+iif(!Empty(cNameSpace),cNameSpace+":","")+aAux[nX]
Next

If oObjXml:XPathHasNode(cString)  
	xRet := oObjXml:XPathGetNodeValue(cString) 
	
	If cTpDado == "D"
		xRet := Replace(xRet,"-","")	
	EndIf          
//Casos onde pode repetir a tag, mas foi enviado somente uma (codigos de glosa por exemplo) 	
/*ElseIf Substr(cString,len(cString)-3,4) == "[1]:"
	cString := Substr(cString,1,len(cString)-4)+":"  
	If Type(Substr(cString,1,len(cString)-1)) == "O"     
		xRet := &(Upper(cString+"TEXT"))
		
		If cTpDado == "D"
			xRet := Stod(Replace(xRet,"-",""))	
		EndIf    
	EndIf	*/		
EndIf

If nCompZero > 0
	xRet := Strzero(Val(xRet),nCompZero)  
EndIf

Return xRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} PTXmlWbTag
Gera arquivo XML A530

@author  Renan Sakai
@since   09/01/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PTXmlWbTag(cTag,cNameSpace,cConteudo,cStrHash,lAbreFecha,lAbre,lFecha,lBco)      
Local cRet := ""
Default cNameSpace := ""
Default cStrHash   := ""
Default cConteudo  := ""
Default lAbreFecha := .F.
Default lAbre      := .F.
Default lFecha     := .F.
Default lBco       := .F.

If lAbreFecha   
	If !Empty(cConteudo) .Or. lBco
		cRet := "<"+cNameSpace+":"+cTag+">"+cConteudo+"</"+cNameSpace+":"+cTag+">" 
	Else        
		Return(cRet)  
		//cRet := "</v1:"+cTag+">
	EndIf
Endif

If lAbre
	cRet := "<"+cNameSpace+":"+cTag+">
EndIf

If lFecha
	cRet := "</"+cNameSpace+":"+cTag+">
EndIf    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona conteudo para variavel de hash geral                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cConteudo)
	cStrHash += cConteudo
EndIf

Return(cRet+CRLF)



//-------------------------------------------------------------------
/*/{Protheus.doc} PLTWsdlMan
Gera os arquivos .pem para conectar com o WebService

@author  Renan Sakai
@version P12
@since   24/11/2016   

Parametros: 
   [1] - Caminho do PFX
   [2] - Caminho do Certificado
   [3] - Caminho da Key
   [4] - Senha do Certificado   
   [5] - Url do EndPoint
   [6] - Codigo da transacao para log
/*/
//-------------------------------------------------------------------     
Function PLTWsdlMng(cXml,aParam) 
Local oWsdl       
Local cPFX   := aParam[1]
Local cCert  := aParam[2]
Local cKey   := aParam[3] 
Local cPass  := aParam[4]
Local cError := ""    
Local cSoap  := ""           
Local cUrl   := aParam[5]   
Local lRet   := .T.
Local nAt    := 0

//Extrai o Cert do arquivo PFX
If !File(cCert)
	If !PFXCert2PEM( cPFX, cCert, @cError, cPass )
		cError += STR0009 + Chr(10) //"Não foi possível gerar o arquivo Cert."
		lRet := .F.
	EndIf
EndIf

//Extrai a Key do arquivo PFX
If !File(cKey)
	If !PFXKey2PEM( cPFX, cKey, @cError, cPass )
		cError += STR0010 + Chr(10) //"Não foi possível gerar o arquivo Key."      
		lRet := .F.
	EndIf        
EndIf

If !File(cPFX)
	cError += STR0011 + Chr(10) //"Certificado não encontrado" 
	lRet := .F.
EndIf

If lRet

	oWsdl := TwsdlManager():New()
	oWsdl:cSSLCertFile     := cCert
	oWsdl:cSSLKeyFile      := cKey
	oWsdl:cSSLKeyPwd       := cPass   
	oWsdl:bNoCheckPeerCert := .T. 

	//Realiza o Parse da URL com o EndPoint
	If oWsdl:ParseURL( cURL ) 
		aOps := oWsdl:ListOperations() 
		If len(aOps) > 0  
			cOper := aOps[1][1]
		
			//Seta a Operacao		 
			If oWsdl:SetOperation(cOper)
				PtLogPTWeb(aParam[6],cXml,"Enviando Soap a"+aParam[6],"Soap Enviado:") 
				
				//Envia o SOAP			
				oWsdl:SendSoapMsg(EncodeUTF8(cXml))
				cSoap := (oWsdl:GetSoapResponse() )
		    EndIf
		Else
			lRet   := .F.
			cError := STR0012 //"Não foi possível realizar a comunicacao: Nao foi possivel encontrar a lista de Operacoes do WebService"
		Endif		    
	EndIf  

	If Empty(cSoap)
		cError := STR0013 //"Não foi possível realizar a comunicacao: Operadora Fora do Ar"
	Else
		PtLogPTWeb(aParam[6],cSoap,"Resposta do EndPoint","Soap Recebido:")
	EndIf
	
	//Processa a resposta de erro
	If !lRet .And. !Empty(oWsdl:cError)
		If (nAt := At('FAULT STRING:',Upper(oWsdl:cError)) ) > 0 
			cError := STR0014 + Substr(oWsdl:cError,nAt+len('FAULT STRING:'),len(oWsdl:cError)) //"Não foi possível realizar a comunicacao: "
		Else
			cError := STR0014 + oWsdl:cError // "Não foi possível realizar a comunicacao: "
		EndIf	
		lRet := .F.
	EndIf 
EndIf

freeObj(oWsdl)               
oWsdl := nil

Return({lRet,cSoap,cError})      


//-------------------------------------------------------------------
/*/{Protheus.doc} PtLogPTWeb
Funcao generica para geracao dos logs de WebServices PTU

@author  Renan Sakai
@version P12
@since   24/11/2016   
/*/
//-------------------------------------------------------------------   
Function PtLogPTWeb(cLayout,cSoap,cMsg1,cMsg2)   

If GetNewPar("MV_P"+cLayout+"LOG",.F.) 
	PlsPtuLog("-----------------------------------------------", "ptu"+cLayout+".log")
	PlsPtuLog(cMsg1, "ptu"+cLayout+".log")
	PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time(), "ptu"+cLayout+".log")
	PlsPtuLog("-----------------------------------------------", "ptu"+cLayout+".log")
	PlsPtuLog(cMsg2, "ptu"+cLayout+".log")
	PlsPtuLog(""   , "ptu"+cLayout+".log")
	PlsPtuLog(cSoap, "ptu"+cLayout+".log")   
	PlsPtuLog(""   , "ptu"+cLayout+".log")
	PlsPtuLog(""   , "ptu"+cLayout+".log")
EndIf

Return
