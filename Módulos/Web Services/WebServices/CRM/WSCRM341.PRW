#INCLUDE "WSCRM341.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSCRM341  ³Autor  ³Alexandre Inacio Lemes ³Data  ³29/01/2008  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service responsavel pelos suspects do Sistema            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Web Service de Controle do Usuario                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSERVICE CRMSUSPECT         DESCRIPTION STR0001 NAMESPACE "http://webservices.microsiga.com.br/crmsuspect.apw" //"Método de consulta aos susspects do sistema"
   WSDATA UserCode                 As String
   WSDATA Suspect                  As SuspectView
   WSDATA ListOfSuspect            As Array Of SuspectView
   WSDATA SuspectID                As String
   WSDATA Header                   AS Array Of BrwHeader
   WSDATA HeaderType               As String
   WSDATA TypeOfAddress            As Array Of GenericStruct
   WSDATA TypeOfPhone              As Array Of GenericStruct
   WSDATA QueryAddWhere            As String OPTIONAL
   WSDATA IndexKey                 As String

   WSMETHOD GetHeader         DESCRIPTION STR0002 //"Método que descreve as estruturas de retorno do serviço"
   WSMETHOD BrwSuspect        DESCRIPTION STR0003 //"Método de listagem dos suspects do sistema"
   WSMETHOD GetTypeOfPhone    DESCRIPTION STR0004 //"Método que descreve os tipos de telefone"
   WSMETHOD GetTypeOfAddress  DESCRIPTION STR0005 //"Método que descreve os tipos de endereço"
   WSMETHOD GetSuspect        DESCRIPTION STR0006 //"Método de consulta ao dados do suspect"
   WSMETHOD PutSuspect        DESCRIPTION STR0007 //"Método de atualizacao do suspect"
ENDWSSERVICE

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetHeader ³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao do header                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Estrutura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o header de uma estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE CRMSUSPECT

::Header := MtHeader(::HeaderType)

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwProspec³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos Suspects                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Expressao a ser adicionada na Query                   ³±±
±±³          ³ExpC3: Chave de retorno ( Expressao padrao CodeBase )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve os Suspects                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD BrwSuspect WSRECEIVE UserCode,QueryAddWhere,IndexKey WSSEND ListOfSuspect WSSERVICE CRMSUSPECT

Local aArea    := GetArea()
Local cAliasACH:= "ACH"
Local cQuery   := ""
Local cArquivo := ""
Local lRetorno := .T.
Local lQuery   := .F.
Local nX       := 0
#IFDEF TOP
Local aStru    := {}
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa os parametros DEFAULTs                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("ACH")
dbSetOrder(1)
DEFAULT ::IndexKey := ACH->(IndexKey())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificacao do acesso                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PrtChkUser(::UserCode,"CRMSUSPECT")
		
	cAliasACH := "GETSUSPECT"
	aStru  := ACH->(dbStruct())
	cQuery := "SELECT ACH_FILIAL,ACH_CODIGO,ACH_LOJA,ACH_RAZAO,ACH_NFANT,ACH_TIPO,ACH_CGC,ACH_END,ACH_BAIRRO,ACH_CIDADE,ACH_EST,ACH_CEP,ACH_DDI,ACH_DDD,ACH_TEL, "
	cQuery += "ACH_FAX,ACH_EMAIL,ACH_URL,ACH_CGC,ACH_CODPRO,ACH_LOJPRO,ACH_DTCONV,ACH_STATUS "
	cQuery += GetUserField("ACH")
	cQuery += "FROM "+RetSqlName("ACH")+" ACH "
	cQuery += "WHERE "
	cQuery += "ACH.ACH_FILIAL='"+xFilial("ACH")+"' AND "
	cQuery += "ACH.D_E_L_E_T_=' ' "
	cQuery := WsQueryAdd(cQuery,::QueryAddWhere)
	cQuery += "ORDER BY "+WsSqlOrder(::IndexKey)
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasACH)
	
	For nX := 1 To Len(aStru)
		If aStru[nX][2]<>"C" .And. FieldPos(aStru[nX][1])<>0
			TcSetField(cAliasACH,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf	    
	Next nX

	::ListOfSuspect := {}
	
	nX := 0
	While !Eof() .And. xFilial("ACH") == (cAliasACH)->ACH_FILIAL
	
		aadd(::ListOfSuspect,WsClassNew("SuspectView"))
		nX++
		GetSuspect(cAliasACH,@::ListOfSuspect[nX])
		dbSelectArea(cAliasACH)
		dbSkip()

	EndDo

	dbSelectArea(cAliasACH)
	dbCloseArea()
	dbSelectArea("ACH")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se ha dados a serem retornados                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( ::ListOfSuspect )
		lRetorno := .F.
		SetSoapFault("BRWSUSPECT",STR0008) //"Nenhum Suspect foi encontrado"
	EndIf
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetSuspec ³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos Suspects do sistema                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Codigo do Suspect                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve um Suspect cadastrado no sistema         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetSuspect WSRECEIVE UserCode,SuspectID WSSEND Suspect WSSERVICE CRMSUSPECT

Local aArea    := GetArea()
Local lRetorno := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificacao do acesso                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PrtChkUser(::UserCode,"CRMSUSPECT")
	dbSelectArea("ACH")
	dbSetOrder(1)
	If MsSeek(xFilial("ACH")+::SuspectId)
		GetSuspect("ACH",@::Suspect)
	Else
		lRetorno := .F.
		SetSoapFault("GETSUSPECT",STR0009) //"Suspect invalido"
	EndIf	
	
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetTypeOfA³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de demonstracao do TypeOfAddress                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o header de uma estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ WEB SERVICES                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetTypeOfAddress WSRECEIVE NULLPARAM WSSEND TypeOfAddress WSSERVICE CRMSUSPECT

::TypeOfPhone := {}
aadd(::TypeOfAddress,WsClassNew("GenericStruct"))
::TypeOfAddress[1]:Code := "1"
::TypeOfAddress[1]:Description := STR0010 //"COMERCIAL"

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetTypeOfP³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de demonstracao do TypeOfAddress                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o header de uma estrutura                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ WEB SERVICES                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetTypeOfPhone WSRECEIVE NULLPARAM WSSEND TypeOfPhone WSSERVICE CRMSUSPECT

::TypeOfPhone := {}
aadd(::TypeOfPhone,WsClassNew("GenericStruct"))
::TypeOfPhone[1]:Code := "1"
::TypeOfPhone[1]:Description := STR0010 //"COMERCIAL"
aadd(::TypeOfPhone,WsClassNew("GenericStruct"))
::TypeOfPhone[2]:Code := "2"
::TypeOfPhone[2]:Description := STR0011 //"FAX"

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PutSuspect³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao dos dados do Suspect                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpO2: Objeto do Suspect                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo efetua a atualizacao dos Suspects do sistema     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD PutSuspect WSRECEIVE UserCode,Suspect WSSEND SuspectID WSSERVICE CRMSUSPECT

Local aArea    := GetArea()
Local aDados   := {}
Local aErro    := {}
Local cErro    := ""
Local lRetorno := .T.
Local nX       := 0
Local nY       := 0
PRIVATE lMsErroAuto    := .F.
PRIVATE lAutoErrNoFile := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificacao do acesso                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PrtChkUser(::UserCode,"CRMSUSPECT")

	aadd(aDados,{"ACH_CODIGO"  ,::Suspect:SuspectCode,NIL})
	aadd(aDados,{"ACH_LOJA"    ,::Suspect:UnitSuspectCode,NIL})
	aadd(aDados,{"ACH_RAZAO"   ,::Suspect:Name,NIL})
	aadd(aDados,{"ACH_NFANT"   ,::Suspect:NickName,NIL})
	aadd(aDados,{"ACH_TIPO"    ,::Suspect:Type,NIL})
	aadd(aDados,{"ACH_CGC"     ,::Suspect:FederalID,NIL})
	aadd(aDados,{"ACH_EMAIL"   ,::Suspect:Email,NIL})
	aadd(aDados,{"ACH_URL"     ,::Suspect:HomePage,NIL})
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Permite Gravar o Prospect se o mesmo for encontrado no SUS              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SUS->(dbSetOrder(1))
	If SUS->(dbSeek(xFilial("SUS")+::Suspect:ProspectCode+::Suspect:UnitProspectCode)) .And. !Empty(::Suspect:ProspectCode+::Suspect:UnitProspectCode)
		aadd(aDados,{"ACH_CODPRO"  ,::Suspect:ProspectCode,NIL})
		aadd(aDados,{"ACH_LOJPRO"  ,::Suspect:UnitProspectCode,NIL})
		aadd(aDados,{"ACH_DTCONV"  ,::Suspect:ConvertProspectDate,NIL})	
		aadd(aDados,{"ACH_STATUS"  ,"6",NIL})
    Else 
		aadd(aDados,{"ACH_STATUS"  ,::Suspect:StatusCode,NIL}) 
    EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao dos enderecos                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 To Len(::Suspect:Addresses)
		If ::Suspect:Addresses[nY]:TypeOfAddress == "1"
			aadd(aDados,{"ACH_END",AllTrim(::Suspect:Addresses[nY]:Address)+","+::Suspect:Addresses[nY]:AddressNumber,NIL})
			aadd(aDados,{"ACH_CIDADE",::Suspect:Addresses[nY]:District,NIL})
			aadd(aDados,{"ACH_EST",::Suspect:Addresses[nY]:State,NIL}) 
			aadd(aDados,{"ACH_CEP",::Suspect:Addresses[nY]:ZipCode,NIL})
			aadd(aDados,{"ACH_BAIRRO",::Suspect:Addresses[nY]:Zone,NIL})
		Else
			lRetorno := .F.
			SetSoapFault("PUTSUSPECT",STR0012) //"TypeOfAddress invalido"
		EndIf 
	Next nY

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao dos telefones                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For nY := 1 To Len(::Suspect:Phones)
		Do Case
			Case ::Suspect:Phones[nY]:TypeOfPhone == "1"
				aadd(aDados,{"ACH_TEL",::Suspect:Phones[nY]:PhoneNumber,NIL})
				If !Empty( ::Suspect:Phones[nY]:LocalAreaCode )
					If Val(::Suspect:Phones[nY]:LocalAreaCode) <> 0
						aadd(aDados,{"ACH_DDD",::Suspect:Phones[nY]:LocalAreaCode,NIL})
					EndIf
				EndIf
				If !Empty( ::Suspect:Phones[nY]:CountryAreaCode )
					If Val(::Suspect:Phones[nY]:CountryAreaCode) <> 0
						aadd(aDados,{"ACH_DDI",::Suspect:Phones[nY]:CountryAreaCode,NIL})
					EndIf
				EndIf
			Case ::Suspect:Phones[nY]:TypeOfPhone == "2"
				aadd(aDados,{"ACH_FAX",::Suspect:Phones[nY]:PhoneNumber,NIL})
			OtherWise
				lRetorno := .F.
				SetSoapFault("PUTSUSPECT",STR0013) //"TypeOfPhone invalido"
		EndCase
	Next nX  
	
	PutUserFields("ACH",::Suspect:UserFields,@aDados)
	aDados := WsAutoOpc(aDados, .T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao do cadastro                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("ACH")
	dbSetOrder(1)
	If Empty(::Suspect:SuspectCode) .Or. !MsSeek(xFilial("ACH")+::Suspect:SuspectCode+::Suspect:UnitSuspectCode)
		nX := 3
	Else
		nX := 4
	EndIf  
	TmkA341(aDados,nX)
	If lMsErroAuto
		aErro := GetAutoGRLog()
   		cErro := ""
	    For nX := 1 To Len(aErro)
	 		cErro += aErro[nX] + Chr(13)+Chr(10)
	    Next nX
		SetSoapFault("PUTSUSPECT",cErro)
		lRetorno := .F.
	EndIf
	
	::SuspectID := ACH->ACH_CODIGO+ACH->ACH_LOJA
	
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetSuspect³Autor  ³Alexandre Inacio Lemes ³ Data ³29/01/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Metodo de recuperacao dos Suspect                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do ACH                                          ³±±
±±³          ³ExpO2: Objeto que sera atualizado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo atualiza o objeto Suspect passado por referencia ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetSuspect(cAliasACH,oObjeto)

Local nY := 0

oObjeto:SuspectCode            := (cAliasACH)->ACH_CODIGO
oObjeto:UnitSuspectCode        := (cAliasACH)->ACH_LOJA
oObjeto:Name                   := (cAliasACH)->ACH_RAZAO
oObjeto:NickName               := (cAliasACH)->ACH_NFANT
oObjeto:Type                   := (cAliasACH)->ACH_TIPO
oObjeto:FederalId              := (cAliasACH)->ACH_CGC
oObjeto:Email                  := (cAliasACH)->ACH_EMAIL
oObjeto:HomePage               := (cAliasACH)->ACH_URL
oObjeto:ProspectCode           := (cAliasACH)->ACH_CODPRO
oObjeto:UnitProspectCode       := (cAliasACH)->ACH_LOJPRO
oObjeto:ConvertProspectDate    := (cAliasACH)->ACH_DTCONV
oObjeto:StatusCode             := (cAliasACH)->ACH_STATUS
oObjeto:StatusDescription      := X3Combo("ACH_STATUS",(cAliasACH)->ACH_STATUS)
UserFields("ACH",@oObjeto:UserFields,cAliasACH)

nY := 0			
If !Empty((cAliasACH)->ACH_END)
	DEFAULT oObjeto:Addresses := {}
	aadd(oObjeto:Addresses,WsClassNew("AddressView"))
	nY++
	oObjeto:Addresses[nY]:TypeOfAddress := "1"
	oObjeto:Addresses[nY]:Address       := FisGetEnd((cAliasACH)->ACH_END)[1]
	oObjeto:Addresses[nY]:AddressNumber := AllTrim(Str(FisGetEnd((cAliasACH)->ACH_END)[2],8))
	oObjeto:Addresses[nY]:District      := (cAliasACH)->ACH_CIDADE
	oObjeto:Addresses[nY]:State         := (cAliasACH)->ACH_EST
	oObjeto:Addresses[nY]:ZipCode       := (cAliasACH)->ACH_CEP
	oObjeto:Addresses[nY]:Zone          := (cAliasACH)->ACH_BAIRRO
EndIf			
nY := 0
If !Empty((cAliasACH)->ACH_TEL)
	DEFAULT oObjeto:Phones := {}
	aadd(oObjeto:Phones,WsClassNew("PhoneView"))
	nY++
	oObjeto:Phones[nY]:TypeOfPhone     := "1"
	oObjeto:Phones[nY]:PhoneNumber     := AllTrim(Str(FisGetTel((cAliasACH)->ACH_TEL,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[3],15))
	oObjeto:Phones[nY]:LocalAreaCode   := AllTrim(Str(FisGetTel((cAliasACH)->ACH_TEL,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[2],15))
	oObjeto:Phones[nY]:CountryAreaCode := AllTrim(Str(FisGetTel((cAliasACH)->ACH_TEL,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[1],15))
EndIf
If !Empty((cAliasACH)->ACH_FAX)
	aadd(oObjeto:Phones,WsClassNew("PhoneView"))
	nY++
	oObjeto:Phones[nY]:TypeOfPhone     := "2"
	oObjeto:Phones[nY]:PhoneNumber     := AllTrim(Str(FisGetTel((cAliasACH)->ACH_FAX,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[3],15))
	oObjeto:Phones[nY]:LocalAreaCode   := AllTrim(Str(FisGetTel((cAliasACH)->ACH_FAX,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[2],15))
	oObjeto:Phones[nY]:CountryAreaCode := AllTrim(Str(FisGetTel((cAliasACH)->ACH_FAX,(cAliasACH)->ACH_DDD,(cAliasACH)->ACH_DDI)[1],15))
EndIf
Return(.T.)

Function WSCRM341Dummy()
Return 