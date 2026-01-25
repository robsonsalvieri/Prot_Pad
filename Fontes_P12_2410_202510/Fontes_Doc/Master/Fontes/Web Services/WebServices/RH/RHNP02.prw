#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP02.CH"

Function RHNP02()
Return .T.

	Private cMRrhKeyTree := ""


//*********************************************************
// Serviço de dados referentes ao colaborador
//*********************************************************
WSRESTFUL Data	DESCRIPTION STR0001 FORMAT APPLICATION_JSON
WSDATA employeeId   AS String
WSDATA Token  		As String
WSDATA page			As String  Optional
WSDATA pageSize		As String  Optional

//****************************** GETs ***********************************
WSMETHOD GET getImage ;
 DESCRIPTION STR0008 ; //"Retorna a foto do colaborador"
 PATH		"/profile/image/{employeeId}"    ;
 WSSYNTAX	"data/profile/image/{employeeId}";
 PRODUCES	"application/json;charset=utf-8"

WSMETHOD GET getIsCoord ;
 DESCRIPTION STR0010 ; //"Retorna se o usuário é coordenador"
 PATH		"/profile/isCoordinator/{employeeId}"    ;
 WSSYNTAX	"data/profile/isCoordinator/{employeeId}";
 PRODUCES	"application/json;charset=utf-8"

WSMETHOD GET getProfile;
 DESCRIPTION STR0009 ; //"Retorna os dados cadastrais do colaborador"
 WSSYNTAX	"/data/profile/{employeeId} || data/profile/summary/{employeeId}";

WSMETHOD GET getReqProfile;
 DESCRIPTION STR0017 ; //"Retorna as solicitações de alteração de dados cadastrais - eSocial."
 PATH		"/profile/requests/{employeeId}";
 WSSYNTAX	"/data/profile/requests/{employeeId}";

WSMETHOD GET LogrTypes;
DESCRIPTION STR0047 ; //"Retorna os tipos de logradouro."
PATH		"/locale/addressType";
WSSYNTAX	"/data/locale/addressType";

WSMETHOD GET Cidades;
DESCRIPTION STR0039 ; //"Retorna as cidades."
PATH		"/locale/city";
WSSYNTAX	"/data/locale/city";

WSMETHOD GET Estados;
DESCRIPTION STR0042 ; //"Retorna os estados."
PATH		"/locale/state";
WSSYNTAX	"/data/locale/state";

WSMETHOD GET Paises;
DESCRIPTION STR0043 ; //"Retorna os estados."
PATH		"/locale/country";
WSSYNTAX	"/data/locale/country";

WSMETHOD GET Instrucoes;
DESCRIPTION STR0044 ; //"Retorna os graus de instrução."
PATH		"/profile/degreeOfEducation/{employeeId}";
WSSYNTAX	"data/profile/degreeOfEducation/{employeeId}";

WSMETHOD GET CategsCNH;
DESCRIPTION STR0045 ; //"Retorna as categorias da CNH."
PATH		"/profile/driverLicense/{employeeId}";
WSSYNTAX	"data/profile/driverLicense/{employeeId}";

WSMETHOD GET CivisEst;
DESCRIPTION STR0046 ; //"Retorna os estados civis."
PATH		"/profile/maritalStatus/{employeeId}";
WSSYNTAX	"data/profile/maritalStatus/{employeeId}";

WSMETHOD GET TiposDeps;
DESCRIPTION STR0068 ; //"Retorna os tipos de dependentes do eSocial."
PATH		"/profile/degreeOfDependence/{employeeId}";
WSSYNTAX	"data/profile/degreeOfDependence/{employeeId}";

//****************************** POSTs ***********************************
WSMETHOD POST ReqProfile;
 DESCRIPTION STR0038 ; //"Inclui uma solicitação de alteração de dados cadastrais"
 PATH		"/profile/request/{employeeId}";
 WSSYNTAX	"/data/profile/request/{employeeId}";


//****************************** DELETEs ***********************************
WSMETHOD DELETE delRequestProfile ;
  DESCRIPTION STR0034 ; //"Serviço DEL responsável pela exclusão da solicitação de alteração de dados cadastrais."
  WSSYNTAX "/profile/request/{employeedId}/{requestId}" ;
  PATH     "/data/profile/request/{employeedId}/{requestId}" ;
  PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL


// -------------------------------------------------------------------
// - GET RESPONSÁVEL EM RETORNAR A FOTO DO COLABORADOR.
// -------------------------------------------------------------------
WSMETHOD GET getImage	 	 ;
	HEADERPARAM Token 	 ;
	PATHPARAM employeeId ;
	WSREST Data

	Local oItemRet		:= JsonObject():New()
	Local oItem			:= JsonObject():New()
	Local aMessages		:= {}
	Local aDataLogin  	:= {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cRD0Login		:= ""
	Local cBranchVld	:= ""
	Local cRD0Cod		:= ""
	Local cMatSRA		:= ""
	Local aIdFunc		:= STRTOKARR( ::aURLParms[3], "|" )
	Local lGestor		:= ( Len(aIdFunc) > 0 ) .And. !( "current" $ Self:employeeId )
	Local aQryParam		:= Self:aQueryString
	Local nPos			:= 0
	Local lBirthdates	:= .F. 

	If ( nPos := aScan(aQryParam, { |x| Lower(x[1]) == "birthdates" } ) ) > 0
		lBirthdates := ( aQryParam[nPos,2] == "true" )
	EndIf

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	
	cToken  := Self:GetHeader('Authorization')
	cKeyId 	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len( aDataLogin ) > 0
		cMatSRA 	:= aDataLogin[1]
		cRD0Login 	:= aDataLogin[2]
		cRD0Cod 	:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
	EndIf

	If lBirthdates .Or. getPermission(cBranchVld, ;
					 cMatSRA,    ;
					 If(lGestor, aIdFunc[1],cBranchVld ),;
					 If(lGestor, aIdFunc[2], cMatSRA ) )
		DataImage(oItem, aMessages, cRD0Login, cBranchVld, aIdFunc)
	Else
		oItemRet["content"] := fGetImgDefault()
		oItemRet["type"]	:= "jpg"

		oItem["data"] 		:= oItemRet
		oItem["length"]		:= 1
		oItem["messages"]	:= {}
	EndIf

	If len(aMessages) > 0
		oItem["data"] 		:= {}
		oItem["length"] 	:= ( Len(oItem["data"]) )
		oItem["messages"] 	:= aMessages
	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cjson)

Return(.T.)


// -------------------------------------------------------------------
// - GET RESPONSÁVEL EM RETORNAR SE O USUÁRIO É COORDENADOR.
// -------------------------------------------------------------------
WSMETHOD GET getIsCoord 	 ;
		HEADERPARAM Token 	 ;
		PATHPARAM employeeId ;
		WSREST Data

	Local oItem			:= JsonObject():New()
	Local oMessages		:= JsonObject():New()
	Local nLenParms		:= Len(::aURLParms)
	Local aMessages		:= {}
	Local aDataLogin 	:= {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cRD0Login		:= ""
	Local cBranchVld	:= ""
	Local cRD0Cod		:= ""
	Local cMatSRA		:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	
	cToken  := Self:GetHeader('Authorization')
	cKeyId 	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cRD0Login  := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If Empty(cRD0Login) .Or. Empty(cBranchVld)
		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0002) //"Dados inválidos."
		Aadd(aMessages,oMessages)
	ElseIf nLenParms == 3 .And. !Empty(::aURLParms[3]) .And. ::aURLParms[2] == "isCoordinator"
		oItem["isCoordinator"] := fGetTeamManager(cBranchVld, cMatSRA) 	//Verifica se a matricula logada e de um gestor
	Else
		Aadd(aMessages,EncodeUTF8(STR0003)) //"O parâmetro employeeId é necessário para o serviço de dados do colaborador."
	EndIf

	If len(aMessages) > 0
		oItem["data"] 		:= {}
		oItem["length"] 	:= ( Len(oItem["data"]) )
		oItem["messages"] 	:= aMessages
	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cjson)

Return(.T.)


// -------------------------------------------------------------------
// - GET RESPONSÁVEL EM RETORNAR OS DADOS CADASTRAIS DO COLABORADOR.
// -------------------------------------------------------------------
WSMETHOD GET getProfile ;
	HEADERPARAM Token 	 ;
	PATHPARAM employeeId ;
	WSREST Data

	Local oItem			:= NIL
	Local nLenParms		:= Len(::aURLParms)
	Local aIdFunc       := {}
	Local aDataLogin	:= {}
	Local cMessages		:= ""
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cRD0Login		:= ""
	Local cBranchVld	:= ""
	Local cRD0Cod		:= ""
	Local cEmpFunc		:= cEmpAnt
	Local cMatSRA		:= ""
	Local cService		:= ""
	Local lRet			:= .T.
	Local lGestor		:= .F.
	Local lHabil		:= .F.
	Local lSummary		:= IF((::aURLParms[2] == "summary"), .T., .F.)
	Local cRoutine		:= "W_PWSA260.APW" //Dados Cadastrais

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	
	cToken  := Self:GetHeader('Authorization')
	cKeyId 	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cRD0Login  := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If nLenParms > 0
		If  nLenParms == 3 .And. ::aURLParms[2] == "summary" .And. !Empty(::aURLParms[3]) .And. (::aUrlParms[3] != "%7Bcurrent%7D") .and. (::aUrlParms[3] != "{current}")
			aIdFunc := STRTOKARR( ::aUrlParms[3], "|" )
		ElseIf nLenParms == 2 .And. ::aURLParms[1] == "profile" .And. !Empty(::aURLParms[2]) .And. (::aUrlParms[2] != "%7Bcurrent%7D") .and. (::aUrlParms[2] != "{current}")
			aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
		EndIf

		If Len(aIdFunc) > 1
			//valida se o solicitante da requisição pode ter acesso as informações
			If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cBranchVld	:= aIdFunc[1]
				cMatSRA		:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lGestor 	:= .T.
			Else
				SetRestFault(400, EncodeUTF8( STR0014 )) //Você está tentando acessar dados de um funcionário que não faz parte do seu time.
				Return .F.
			EndIf
		EndIf
	EndIF

	cService := Iif( !lGestor,  "profile", "teamManagementProfile" )

	//Valida Permissionamento
	If !lSummary
		fPermission(aDataLogin[5], cRD0Login, cRD0Cod, cService, @lHabil)
		If !lHabil
			SetRestFault(400, EncodeUTF8(STR0013) ) //Permissão negada ao serviço do Perfil
			Return (.F.)
		EndIf
	EndIf

	If Empty(cRD0Login) .Or. Empty(cBranchVld)
		SetRestFault(400, EncodeUTF8( STR0002 )) //"Dados inválidos."
		Return .F.
	ElseIf !Empty(cBranchVld) .And. !Empty(cMatSRA)
		oItem := GetDataForJob("36", { cBranchVld, cMatSRA, cEmpFunc, lGestor, lSummary }, cEmpFunc, cEmpAnt)
	Else
		cMessages := EncodeUTF8(STR0003) //"O parâmetro employeeId é necessário para o serviço de dados do colaborador."
	EndIf

	If !Empty(cMessages)
		SetRestFault(400, cMessages)
		lRet := .F.
	Else
		cJson := oItem:ToJson()
		::SetResponse(cjson)
	EndIf

Return lRet

// -------------------------------------------------------------------
// - GET SOLICITAÇÕES DE ALTERAÇÃO CADASTRAL.
// -------------------------------------------------------------------

WSMETHOD GET getReqProfile ; 
	PATHPARAM employeeId ;
	WSREST Data

	Local aDataLogin := {}
	local aData      := {}

	Local cBranchVld := ""
	Local cEmp       := cEmpAnt
	Local cMatSRA    := ""
	Local cJson      := ""
	Local cRD0Cod    := ""
	Local cToken     := ""
	Local cKeyId     := ""

	Local lHabil     := .F.

	Local nIniCount  := 0
	Local nFimCount  := 0
	Local nCount     := 0

	Local oItems	:= JsonObject():New()

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cRD0Cod	   := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	fPermission(cBranchVld, cMatSRA, cRD0Cod, "profileRequests", @lHabil)

	If !lHabil
		SetRestFault(400, EncodeUTF8(STR0018)) //"Permissão negada para visualizar as solicitações de alteração de dados cadastrais - eSocial."
		Return(.F.)
	EndIf

	//Faz o controle de paginação
	If Empty(Self:page) .Or. Self:page == "1"  
		nIniCount := 1 
		nFimCount := If( Empty(Self:pageSize), 10, Val(Self:pageSize) )
	Else
		nIniCount := ( Val(Self:pageSize) * ( Val(Self:page) - 1 ) ) + 1
		nFimCount := ( nIniCount + Val(Self:pageSize) ) - 1
	EndIf

	If(!Empty(cBranchVld) .And. !Empty(cMatSRA))
		aData := getProfReqRH3(cEmp, cBranchVld, cMatSRA, @nCount, nIniCount, nFimCount)
	EndIf

	oItems["hasNext"] := (nCount > nFimCount)
	oItems["items"]   := aData

	cJson := oItems:ToJson()

	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// RETORNA UMA LISTA DOS TIPOS DE LOGRADOURO
// -------------------------------------------------------------------
WSMETHOD GET LogrTypes WSSERVICE Data

Local oLogr      := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""
Local cBranchVld := ""


Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cToken  	:= Self:GetHeader('Authorization')
cKeyId     	:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld := aDataLogin[5]	
EndIf

If !Empty( cBranchVld )
	oLogr := fLogrTypes( cBranchVld, aQryParam )
EndIf

cJson := oLogr:ToJson()
::SetResponse(cJson)

FreeObj( oLogr )

Return .T.

// -------------------------------------------------------------------
// RETORNA UMA LISTA DE CIDADES
// -------------------------------------------------------------------
WSMETHOD GET Cidades WSSERVICE Data

Local oCidades   := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""
Local cBranchVld := ""
Local cMatSRA    := ""


Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cToken  	:= Self:GetHeader('Authorization')
cKeyId     	:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld	:= aDataLogin[5]
	cMatSRA		:= aDataLogin[1]		
EndIf

If !Empty( cBranchVld ) .And. !Empty( cMatSRA )
	oCidades := fCidades( cBranchVld, cMatSRA, aQryParam )
EndIf

cJson := oCidades:ToJson()
::SetResponse(cJson)

FreeObj( oCidades )

Return .T.


// -------------------------------------------------------------------
// RETORNA UMA LISTA DE ESTADOS
// -------------------------------------------------------------------
WSMETHOD GET Estados WSSERVICE Data

Local oEstados   := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""
Local cBranchVld := ""


Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cKeyId     	:= Self:GetHeader('keyId')
cToken  	:= Self:GetHeader('Authorization')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld	:= aDataLogin[5]		
EndIf

If !Empty( cBranchVld )
	oEstados := fEstados( cBranchVld, aQryParam )
EndIf

cJson := oEstados:ToJson()
::SetResponse(cJson)

FreeObj( oEstados )

Return .T.

// -------------------------------------------------------------------
// RETORNA UMA LISTA DE PAISES
// -------------------------------------------------------------------
WSMETHOD GET Paises WSSERVICE Data

Local oPaises   := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""
Local cBranchVld := ""


Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cKeyId     	:= Self:GetHeader('keyId')
cToken  	:= Self:GetHeader('Authorization')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld	:= aDataLogin[5]		
EndIf

If !Empty( cBranchVld )
	oPaises := fPaises( cBranchVld, aQryParam )
EndIf

cJson := oPaises:ToJson()
::SetResponse(cJson)

FreeObj( oPaises )

Return .T.

// -------------------------------------------------------------------
// RETORNA UMA LISTA DOS GRAU DE INSTRUÇÃO
// -------------------------------------------------------------------
WSMETHOD GET Instrucoes WSSERVICE Data

Local oGraus     := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""
Local cBranchVld := ""


Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cToken  	:= Self:GetHeader('Authorization')
cKeyId     	:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld	:= aDataLogin[5]		
EndIf

If !Empty( cBranchVld )
	oGraus := fGrInstr( cBranchVld, aQryParam )
EndIf

cJson := oGraus:ToJson()
::SetResponse(cJson)

FreeObj( oGraus )

Return .T.
// -------------------------------------------------------------------
// RETORNA A LISTA COM AS CATEGORIAS DA CNH
// -------------------------------------------------------------------
WSMETHOD GET CategsCNH WSSERVICE Data

Local oCategs    := JsonObject():New()

Local aDataLogin := {}

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""

Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cKeyId     	:= Self:GetHeader('keyId')
cToken  	:= Self:GetHeader('Authorization')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	oCategs := fCategsCNH()
EndIf

cJson := oCategs:ToJson()
::SetResponse(cJson)

FreeObj( oCategs )

Return .T.

// -------------------------------------------------------------------
// RETORNA A LISTA COM OS ESTADOS CIVIS
// -------------------------------------------------------------------
WSMETHOD GET CivisEst WSSERVICE Data

Local oEstCivis  := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""

Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cKeyId     	:= Self:GetHeader('keyId')
cToken  	:= Self:GetHeader('Authorization')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	cBranchVld	:= aDataLogin[5]		
EndIf

If !Empty( cBranchVld )
	oEstCivis := fEstCivis( cBranchVld, aQryParam )
EndIf


cJson := oEstCivis:ToJson()
::SetResponse(cJson)

FreeObj( oEstCivis )

Return .T.

// -------------------------------------------------------------------
// RETORNA A LISTA COM OS TIPOS DE DEPENDENTES.
// -------------------------------------------------------------------
WSMETHOD GET TiposDeps WSSERVICE Data

Local oTipos  	 := JsonObject():New()

Local aDataLogin := {}
Local aQryParam	 := Self:aQueryString

Local cJson      := ""
Local cToken     := ""
Local cKeyId     := ""

Self:SetHeader('Access-Control-Allow-Credentials' , "true")
cKeyId     	:= Self:GetHeader('keyId')
cToken  	:= Self:GetHeader('Authorization')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

If Len(aDataLogin) > 0
	oTipos := fTpsDeps(aQryParam)
EndIf

cJson := oTipos:ToJson()
::SetResponse(cJson)

FreeObj( oTipos )

Return .T.

// -------------------------------------------------------------------
// INCLUI A REQUISICAO DE ALTERAÇÃO CADASTRAL
// -------------------------------------------------------------------
WSMETHOD POST ReqProfile PATHPARAM employeeId WSSERVICE Data

	Local oOBJ			:= JsonObject():New()
	Local oItem			:= JsonObject():New()
	Local cBody 		:= Self:GetContent()
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cMatSRA	 	:= ""
	Local cBranchVld 	:= ""
	Local cVision	 	:= ""
	Local cMsg			:= ""
	Local cEmpSolic		:= cEmpAnt
	Local cRoutine		:= "W_PWES01.APW" 	//Alteracao Cadastral - eSocial
	Local dDataDefault 	:= CTOD("//")
	Local nX			:= 0
	Local nZ			:= 0
	Local lRet			:= .F.
	Local lHabil		:= .F.
	Local lAddress		:= .F.
	Local lDoctos		:= .F.
	Local lContacts		:= .F.
	Local lRic			:= .F.
	Local lCompData		:= .F.
	Local lDefs			:= .F.
	Local lClass		:= .F.
	Local lNasc			:= .F.

	Local aIdDep		:= {}

	//Para facilitar a identificação, as variaveis foram definidas da seguinte forma:
	//Campo da tabela SRA trocando o prefixo [RA_] por [C]. => Exemplo: RA_BAIRRO vira cBAIRRO
	Local codMunCad		:= ""
	Local nacionalidade	:= ""

	Local cLOGRTP 		:= ""
	Local cLOGRDSC		:= ""
	Local cLOGRNUM		:= ""
	Local cCEP			:= ""
	Local cBAIRRO		:= ""
	Local cCOMPLEM		:= ""
	Local cMUNICIP		:= ""
	Local cESTADO  		:= ""

	Local numRic		:= ""
	Local emisRic		:= ""
	Local ufRic			:= ""
	Local cdMuRic		:= ""
	Local dExPric		:= ""

	Local dddFone		:= ""
	Local telefone		:= ""
	Local dddCel		:= ""
	Local celular		:= ""

	Local portDef		:= ""
	Local obsDef		:= ""

	Local grauInst		:= ""

	Local estCiv		:= ""

	Local numProcMenor  := ""
	
	Local recAposen		:= ""

	Local numCp			:= ""
	Local serCp			:= ""
	Local ufCp			:= ""

	Local codigoInsc	:= ""
	Local oCEmis		:= ""
	Local oCDtExp		:= ctod("//")
	Local oCDtVal		:= ctod("//")

	Local cEMAIL		:= ""
	Local cEMAIL2		:= ""

	Local cFileTipe     := ""
	Local cFileContent  := ""

	Local categoriaCnh	:= ""
	Local ufCnh			:= ""
	Local cHABILIT		:= ""
	Local cCNHORG 		:= ""
	Local dDTEMCNH		:= CTOD("//")
	Local dDTVCCNH		:= CTOD("//")

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	oRequest				:= WSClassNew("TRequest")
	oRequest:RequestType	:= WSClassNew("TRequestType")
	oRequest:Status			:= WSClassNew("TRequestStatus")
	oESocRequest			:= WSClassNew("TFieldsInput")
	oDependent				:= WSClassNew("FieldsDependents")

	cToken     	:= Self:GetHeader('Authorization')
	cKeyId     	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]			
	EndIf

	fPermission(cBranchVld, cMatSRA, cCodRD0, "profileRequests", @lHabil)

	If !lHabil
		SetRestFault(400, EncodeUTF8(STR0018)) //"Permissão negada para visualizar as solicitações de alteração de dados cadastrais - eSocial."
		Return(.F.)
	EndIf

	If( fVerPendRH3( cEmpAnt, cBranchVld, cMatSRA, "2", {"1","4"} ) )
		SetRestFault(400, EncodeUTF8(STR0067)) //"Não é possível editar as informações do seu perfil, pois já existe uma solicitação em andamento, aguarde a sua aprovação."
		Return(.F.)
	EndIf

	If !Empty( cBody )

		oItem:FromJson(cBody)

		//Anexo
		If oItem:hasProperty("hasAttachment") .And. oItem["hasAttachment"] == .T.
			cFileTipe	:= Iif(oItem:hasProperty("file"),oItem["file"]["type"]," ")
			cFileContent:= Iif(oItem:hasProperty("file"),oItem["file"]["content"]," ")

			If ( Empty(cFileContent) .Or. (Empty(cFileTipe) .Or. !cFileTipe $ ("jpg||jpeg||pdf||png||JPG||JPEG||PDF||PNG")) )
				SetRestFault(400, EncodeUTF8(STR0069)) //"Anexo inválido. Selecione um arquivo de imagem do tipo JPG, PNG ou PDF."
				Return(.F.)
			EndIf
		EndIf

		//Dados da requisicao de alteração cadastral
		//Endereco
		If oItem:hasProperty("addresses") .And. ValType(oItem["addresses"]) == "A" .And. Len( oItem["addresses"] ) > 0
			oOBJ 		:= oItem["addresses"][1]
			cLOGRTP 	:= AllTrim( oOBJ["addressType"]["abbr"] ) // tipo logradouro
			cLOGRDSC    := AllTrim( oOBJ["name"] ) // descrição logradouro / endereço.
			cLOGRNUM	:= AllTrim(oOBJ["number"]) //Número Logradouro
			cCEP		:= AllTrim(oOBJ["zipcode"]) //CEP
			cBAIRRO		:= AllTrim(oOBJ["neighborhood"]) //Bairro
			cMUNICIP    := AllTrim(oOBJ["city"]["id"]) // Cidade.
			cCOMPLEM	:= AllTrim(oOBJ["complement"])//Complemento do Endereco
			cESTADO  	:= AllTrim(oOBJ["city"]["state"]["id"])//Estado
			lAddress	:= .T.
		EndIf

		//Contatos
		If oItem:hasProperty("contacts")
			// Email
			If ValType(oItem["contacts"]["emails"]) == "A" .And. Len( oItem["contacts"]["emails"] ) > 0
				For nX := 1 To Len( oItem["contacts"]["emails"] )
					oOBJ := oItem["contacts"]["emails"][nX]
					If oOBJ["type"] == "work"
						cEMAIL	:= oOBJ["email"] //Endereco do E-Mail
					Else
						cEMAIL2 := oOBJ["email"] //Email Alternativo
					EndIf
				Next nX
			EndIf

			If ValType(oItem["contacts"]["phones"]) == "A" .And. Len( oItem["contacts"]["phones"] ) > 0
				For nX := 1 To Len( oItem["contacts"]["phones"] )
					oOBJ := oItem["contacts"]["phones"][nX]
					If oOBJ["id"] == "casa"
						dddFone	:= If( Empty(oOBJ["number"]) , "", cValToChar( oOBJ["ddd"] ) )// ddd telefone.
						telefone := oOBJ["number"] 			 // numero telefone
					Else
						dddCel :=  If( Empty(oOBJ["number"]) , "", cValToChar( oOBJ["ddd"] ) )   // ddd cel.
						celular := oOBJ["number"]            // celular.
					EndIf
				Next nX
			EndIf
			lContacts := !Empty(cEMAIL + cEMAIL2 + dddFone + telefone + dddCel + celular)
		EndIf

		//Documentos
		If oItem:hasProperty("documents") .And. ValType(oItem["documents"]) == "A" .And. Len( oItem["documents"] ) > 0
			For nX := 1 To Len( oItem["documents"] )
				oOBJ := oItem["documents"][nX]
				
				//Carteira de motorista
				If oOBJ["type"] == "driverLicense"
					For nZ := 1 To Len( oOBJ["fields"] )
						If oOBJ["fields"][nZ]["type"] == "other"
							categoriaCnh := oOBJ["fields"][nZ]["value"]
						EndIf
						If oOBJ["fields"][nZ]["type"] == "number"
							cHABILIT := oOBJ["fields"][nZ]["value"]
						EndIf
						If oOBJ["fields"][nZ]["type"] == "sender"
							cCNHORG := oOBJ["fields"][nZ]["value"]
						EndIf
						If oOBJ["fields"][nZ]["type"] == "senderDate"
							dDTEMCNH := StoD( Format8601(.T.,oOBJ["fields"][nZ]["value"],,.T.) )
						EndIf
						If oOBJ["fields"][nZ]["type"] == "dueDate"
							dDTVCCNH := StoD( Format8601(.T.,oOBJ["fields"][nZ]["value"],,.T.) )
						EndIf
						If oOBJ["fields"][nZ]["type"] == "senderState"
							ufCnh := oOBJ["fields"][nZ]["value"]
						EndIf															
					Next nZ
				EndIf

				//Carteira de Trabalho - CTPS
				If oOBJ["type"] == "workCard"
					For nZ := 1 To Len( oOBJ["fields"] )
						If oOBJ["fields"][nZ]["type"] == "number"
							numCp := oOBJ["fields"][nZ]["value"]
						EndIf
						If oOBJ["fields"][nZ]["type"] == "series"
							serCp := oOBJ["fields"][nZ]["value"]
						EndIf
						If oOBJ["fields"][nZ]["type"] == "senderState"
							ufCp := oOBJ["fields"][nZ]["value"]
						EndIf													
					Next nZ
				EndIf
			Next nX
			lDoctos := !Empty(cHABILIT + cCNHORG + numCp + serCp + ufCp) .Or. !Empty(dDTEMCNH) .Or. !Empty(dDTVCCNH) 
		EndIf

		//Dependentes.
		// Realiza a alteração da SRB
		If oItem:hasProperty("dependents") .And. ValType(oItem["dependents"]) == "A" .And. Len( oItem["dependents"] ) > 0
			For nX := 1 To Len( oItem["dependents"] )
				If ChkCPF( oItem["dependents"][nX]["cpf"], .T.)
					oDependent := WSClassNew("FieldsDependents")
					oDependent:cicAux 	:= ""
					oDependent:tpDepAux := ""
					oDependent:cicDep   := oItem["dependents"][nX]["cpf"]
					oDependent:tpDep 	:= oItem["dependents"][nX]["degreeOfDependence"]["id"]
					aIdDep 		   		:= StrTokArr(oItem["dependents"][nX]["id"], "|" )
					fUpdDep( aIdDep, oDependent, @cMsg )
				else
					SetRestFault(400, EncodeUTF8(STR0070)) //"CPF Inválido - Não será possível gravar a solicitação."
					Return(.F.)
				EndIf	
			Next nX	
		EndIf

		//RIC
		If oItem:hasProperty("civilRegistration")
			numRic   := AllTrim( oItem["civilRegistration"]["number"] )
			emisRic  := AllTrim( oItem["civilRegistration"]["organizationEmitter"] )
			dExPric  := StoD( Format8601(.T.,oItem["civilRegistration"]["emitterDate"],,.T.) )
			ufRic    := AllTrim( oItem["civilRegistration"]["state"]["id"] )
			cdMuRic  := AllTrim( oItem["civilRegistration"]["city"]["id"] )
			lRic := !Empty( numRic ) .Or.!Empty( emisRic ) .Or. !Empty( dExPric ) .Or.!Empty( ufRic ) .Or. !Empty( cdMuRic )
		EndIf

		//Deficiência.
		If oItem:hasProperty("desabilities")
			If ValType( oItem["desabilities"]["desabilities"] ) == "A" .And. Len( oItem["desabilities"]["desabilities"] ) > 0
				For nX := 1 To Len( oItem["desabilities"]["desabilities"] )
					portDef += if( oItem["desabilities"]["desabilities"][nX]["value"] == .T.,;
					 			   oItem["desabilities"]["desabilities"][nX]["id"], "*"  )
				Next nX
			EndIf
			obsDef  := AllTrim( oItem["desabilities"]["observation"] )
			lDefs := .T.
		EndIf

		// Dados complementares.
		If oItem:hasProperty("complementaryData")
			
			//Grau de Instrução.
			grauInst := AllTrim( oItem["complementaryData"]["degreeOfEducation"]["id"] )
			// Estado Civil.
			estCiv	:= AllTrim( oItem["complementaryData"]["maritalStatus"]["id"] )
			//aponsentadoria.
			recAposen := AllTrim( oItem["complementaryData"]["retirement"])

			//processo menor.
			numProcMenor := AllTrim( oItem["complementaryData"]["minorProcessNumber"])
			lCompData := .T.
		EndIf

		//Orgão de classe.
		If oItem:hasProperty("organizationClassDocument")
			codigoInsc 	:= AllTrim( oItem["organizationClassDocument"]["classNumber"] )
			oCEmis 		:= AllTrim( oItem["organizationClassDocument"]["organizationSender"] )
			oCDtExp 	:= StoD( Format8601(.T., oItem["organizationClassDocument"]["senderDate"],, .T. ) )
			oCDtVal 	:= StoD( Format8601(.T., oItem["organizationClassDocument"]["dueDate"],, .T. ) )
			lClass 		:= .T.	
		EndIf

		// Dados de nascimento.
		If oItem:hasProperty("personalData")
			codMunCad 		:= AllTrim( oItem["personalData"]["bornCity"]["id"] )
			nacionalidade 	:= AllTrim( oItem["personalData"]["bornCity"]["state"]["country"]["id"] )
		EndIf

		If ( lAddress .Or. lDoctos .Or. lContacts .Or. lRic .Or. lCompData .Or. lDefs .Or. lNasc )

			//Obtem os dados da estrutura hierarquica
			aVision 		:= GetVisionAI8(cRoutine, cBranchVld)
			cVision 		:= aVision[1][1]

			//Dados do cabecalho da requisicao
			oRequest:Branch 				:= cBranchVld
			oRequest:Registration			:= cMatSRA
			oRequest:ApproverBranch			:= ""
			oRequest:ApproverRegistration 	:= ""
			oRequest:EmpresaAPR				:= ""
			oRequest:Empresa				:= cEmpSolic
			oRequest:StarterBranch			:= cBranchVld
			oRequest:StarterRegistration	:= cMatSRA
			oRequest:ApproverLevel		    := 99
			oRequest:Vision					:= cVision

			//Dados dos itens da requisicao
			//-------------------------------------
			//Endereço
			oESocRequest:tipoLogradouro := cLOGRTP
			oESocRequest:logrDesc 		:= decodeUtf8(cLOGRDSC)
			oESocRequest:numLogradouro 	:= cLOGRNUM
			oESocRequest:cep 			:= cCEP
			oESocRequest:bairro 		:= decodeUtf8(cBAIRRO)
			oESocRequest:complemento 	:= decodeUtf8(cCOMPLEM)
			oESocRequest:codMun 		:= cMUNICIP
			oESocRequest:est 			:= cESTADO

			//Contatos/E-mail
			oESocRequest:email 			:= cEMAIL
			oESocRequest:emailAlt 		:= cEMAIL2

			//Contatos telefones.
			oESocRequest:dddFone		:= dddFone
			oESocRequest:telefone		:= telefone
			oESocRequest:dddCel			:= dddCel
			oESocRequest:celular		:= celular

			//Documentos/CNH
			oESocREquest:categoriaCnh	:= categoriaCnh
			oESocRequest:habilit 		:= cHABILIT
			oESocRequest:cnhOrg 		:= decodeUtf8(cCNHORG)
			oESocRequest:dtEmCnh 		:= dDTEMCNH
			oESocRequest:dtVcCnh 		:= dDTVCCNH
			oESocRequest:ufCnh			:= ufCnh

			//Documentos/CTPS
			oESocRequest:numCp 			:= numCp
			oESocRequest:serCp 			:= serCp
			oESocRequest:ufCp 			:= ufCp

			//RIC
			oESocRequest:numRic			:= numRic
			oESocRequest:emisRic		:= decodeUtf8(emisRic)
			oESocRequest:ufRic			:= ufRic
			oESocRequest:cdMuRic		:= cdMuRic
			oESocRequest:dExPric		:= dExPric

			//Deficiência.
			oESocRequest:portDef		:= portDef
			oESocRequest:obsDef			:= decodeUtf8(obsDef)

			//Estado Civil
			oESocRequest:estCiv			:= estCiv

			// Grau de Instruçaõ
			oESocRequest:grauInst		:= grauInst

			//Aposentadoria
			oESocRequest:recAposen		:= recAposen

			//processo menor
			oESocRequest:numProcMenor	:= numProcMenor

			//Orgãos de Classe.
			oESocRequest:codigoInsc		:= codigoInsc
			oESocRequest:oCEmis			:= decodeUtf8(oCEmis)
			oESocRequest:oCDtExp		:= oCDtExp
			oESocRequest:oCDtVal		:= oCDtVal
			
			//Dados de nascimenti
			oESocRequest:nacionalidade  := nacionalidade
			oESocRequest:codMunCad  	:= codMunCad

			//Datas ainda sem tratamento com valores default p/ nao gerar erro na gravacao da RH4
			oESocRequest:rneDexp		:= dDataDefault
			oESocRequest:DatCheg		:= dDataDefault
			oESocRequest:dtNasc			:= dDataDefault
			oESocRequest:dtEntra		:= dDataDefault
			oESocRequest:dtBaixa		:= dDataDefault

			//-------------------------------------

			AddAlteracaoESocial( oRequest, oESocRequest, "MEURH", .T., @cMsg, NIL, cFileContent, cFileTipe )

			lRet := Empty(cMsg)		
		EndIf
	EndIf

	If lRet
		cJson := oItem:ToJson()
		Self:SetResponse(cJson)
	EndIf

	If( !lRet, SetRestFault(400, cMsg), Nil )

	FREEOBJ( oOBJ )
	FREEOBJ( oDependent )
	FREEOBJ( obsDef )
	FREEOBJ( oItem )
	FREEOBJ( oRequest )
	FREEOBJ( oESocRequest )

Return( lRet )


// -------------------------------------------------------------------
// - DEL SOLICITAÇÕES DE ALTERAÇÃO CADASTRAL.
// -------------------------------------------------------------------

WSMETHOD DELETE delRequestProfile WSREST Data

	Local aMessages      := {}
	Local aDataLogin     := {}
	Local aUrlParam      := ::aUrlParms

	Local cBranchReq     := ""
	Local cMatSRAReq     := ""
	Local cEmpReq        := ""
	Local cToken         := ""
	Local cKeyId         := ""
	Local cRD0Cod        := ""
	Local cJson          := ""
	Local cCodReq        := ""
	Local cRestFault     := ""

	Local lRet           := .T.
	Local lContinua      := .T.
	Local oMsgReturn     := Nil
	Local oItemData      := Nil
	Local oItem          := Nil


	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cRD0Cod     := aDataLogin[3]
	EndIf

	If Len(aUrlParam) > 0 .And. !Empty(aUrlParam[4])
		aIdFunc := STRTOKARR( aUrlParam[4], "|" )
		If Len(aIdFunc) > 3
			cBranchReq := aIdFunc[1]
			cMatSRAReq := aIdFunc[2]
			cEmpReq    := aIdFunc[3]
			cCodReq    := aIdFunc[4]
		EndIf
	EndIf

	fPermission(cBranchReq, cMatSRAReq, cRD0Cod, "profileRequests", @lContinua)

	If !lContinua
		cRestFault := EncodeUTF8(STR0035) //"Permissão negada para exclusão de solicitações de alteração de dados cadastrais"
	EndIf

	If Empty(cRestFault)
		Begin Transaction
			//Deleta registros na RH3 e RH4.
			DelRH3RH4(cBranchReq, cCodReq, @lContinua)
			//Caso a exclusão na RH3 e RH4 aconteça, exclui os registros na RGK e RDY.
			If !lContinua
				cRestFault := EncodeUTF8(STR0036) //"Solicitação de alteração não pode ser excluída pois já foi aprovada."
			Else
				DelRGKRDY(cBranchReq, cMatSRAReq, cCodReq)
			EndIf
		End Transaction
	EndIf

	If Empty(cRestFault)

		oMsgReturn     := JsonObject():New()
		oItemData      := JsonObject():New()
		oItem          := JsonObject():New()

		HttpSetStatus(204)

		oMsgReturn["type"]      := "success"
		oMsgReturn["code"]      := "204"
		oMsgReturn["detail"]    := EncodeUTF8(STR0037) //"Exclusão realizada com sucesso"
		Aadd(aMessages, oMsgReturn)

		oItem["data"]           := oItemData
		oItem["messages"]       := aMessages
		oItem["length"]         := 1

		cJson :=  oItem:ToJson()
		::SetResponse(cJson)
	Else
		lRet := .F.
		SetRestFault(400, cRestFault, .T.)
	EndIf

Return(lRet)


// -------------------------------------------------------------------
// -------------------------------------------------------------------
// - FUNÇÕES GENERICAS DO SERVIÇO DATA/PROFILE.
// -------------------------------------------------------------------
Function DataProfile( cBranchVld, cMatSRA, cEmpSRA, lGestor, lSummary, lJob, cUID)
	Local oClass		:= NIL
	Local oRICCity		:= NIL
	Local oRICStat		:= NIL
	Local oRICCoun		:= NIL
	Local oRic			:= NIL
	Local oComplData    := NIL
	Local oEstCivil		:= NIL
	Local oGrauInstr	:= NIL
	Local oDefs 		:= NIL
	Local oSummary 		:= NIL
	Local oCoordinator	:= NIL
	Local oItemData	 	:= NIL
	Local oTeams		:= NIL
	Local oAddresses	:= NIL
	Local oAddreType	:= NIL
	Local oNumberPhone	:= NIL
	Local oNumberCel	:= NIL
	Local oEmailWork	:= NIL
	Local oEmailPersonal:= NIL
	Local oState		:= NIL
	Local oCountry		:= NIL
	Local oPersonalData	:= NIL
	Local oBornCity		:= NIL
	Local oContacts		:= NIL
	Local oFlProperties := NIL
	Local oMessages		:= NIL
	Local oItem			:= NIL
	Local aDateGMT		:= {}
	Local aDocs			:= {}
	Local aEmails		:= {}
	Local aPhones		:= {}
	Local aAddressBody	:= {}
	Local aTeams		:= {}
	Local aData			:= {}
	Local aAreaSRA		:= {}
	Local aCoordinator  := {}
	Local aStructREST	:= {}
	Local aFlProperties	:= {}
	Local aVision		:= {}
	Local cRoutine		:= "W_PWSA260.APW" // Dados Cadastrais - Utilizada para buscar a VISÃO a partir da rotina; (AI8_VISAPV) na função GetVisionAI8().
	Local lNomeSoc      := .F.
	Local cVision		:= ""
	Local cCodPais		:= ""
	Local cOrgCfg		:= ""
	
	Default lSummary    := .F.
	Default lGestor		:= .F.
	Default lJob		:= .F.

	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpSRA, cBranchVld )
	EndIf

	lNomeSoc := SuperGetMv("MV_NOMESOC", NIL, .F.)
	cOrgCfg  := SuperGetMv("MV_ORGCFG", NIL, "0")

    // - Efetua o posicionamento no funcionário (SRA)
	dbSelectArea("SRA")
	SRA->( dbSetOrder(1) )
	If SRA->( dbSeek( cBranchVld + cMatSRA ))

		If !lSummary
			// ----------------------------------------------
			// - A Função GetVisionAI8() devolve por padrão
			// - Um Array com a seguinte estrutura:
			// - aVision[1][1] := "" - AI8_VISAPV
			// - aVision[1][2] := 0  - AI8_INIAPV
			// - aVision[1][3] := 0  - AI8_APRVLV
			// - Por isso as posições podem ser acessadas
			// - Sem problemas, ex: cVision := aVision[1][1]
			// ----------------------------------------------
			aVision := GetVisionAI8(cRoutine, SRA->RA_FILIAL)
			cVision := aVision[1][1]
			
			// --------------------------------------
			// - aStructREST - Estrutura Hierarquica
			// - Do Funcionário Logado.
			// --------------------------------------
			aAreaSRA    := SRA->( GetArea() )

			cMRrhKeyTree := fMHRKeyTree(SRA->RA_FILIAL, SRA->RA_MAT)
			aStructREST  := APIGetStructure("", cOrgCfg, cVision, SRA->RA_FILIAL, SRA->RA_MAT, , , , , SRA->RA_FILIAL, SRA->RA_MAT, , , , , .T., {cEmpAnt})

			RestArea(aAreaSRA)

			//Só busca o coordenador, se a ApiGetStructure retornou dados corretos.
			If Len(aStructREST) > 0 .And. !(ValType(aStructREST[1]) == "L")
				aCoordinator := CoordInfos(aClone(aStructREST),SRA->RA_MAT,SRA->RA_FILIAL)
			EndIf

			//Cria os objetos JSON
			oClass			:= JsonObject():New()
			oRICCity		:= JsonObject():New()
			oRICStat		:= JsonObject():New()
			oRICCoun		:= JsonObject():New()
			oRIC			:= JsonObject():New()
			oDefs			:= JsonObject():New()
			oComplData      := JsonObject():New()
			oEstCivil		:= JsonObject():New()
			oGrauInstr		:= JsonObject():New()
			oSummary 		:= JsonObject():New()
			oCoordinator	:= JsonObject():New()
			oItemData	 	:= JsonObject():New()
			oTeams			:= JsonObject():New()
			oAddresses		:= JsonObject():New()
			oAddreType		:= JsonObject():New()
			oNumberPhone	:= JsonObject():New()
			oNumberCel		:= JsonObject():New()
			oEmailWork		:= JsonObject():New()
			oEmailPersonal	:= JsonObject():New()
			oState			:= JsonObject():New()
			oCountry		:= JsonObject():New()
			oPersonalData	:= JsonObject():New()
			oBornCity		:= JsonObject():New()
			oContacts		:= JsonObject():New()
			oMessages		:= JsonObject():New()

			// - Summary
			oSummary["id"] 						:= SRA->RA_FILIAL +"|" + SRA->RA_MAT
			oSummary["name"]					:= Alltrim( EncodeUTF8(If(lNomeSoc .And. !Empty(SRA->RA_NSOCIAL), SRA->RA_NSOCIAL, SRA->RA_NOME)))
			oSummary["roleDescription"] 		:= Alltrim( EncodeUTF8( FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC",,SRA->RA_FILIAL ) ) )

			oItemData["summary"] 				:= oSummary
			oItemData["positionLevel"]			:= Alltrim( EncodeUTF8(fDesc("SQ3",SRA->RA_CARGO,"SQ3->Q3_DESCSUM",,SRA->RA_FILIAL )) )
			oItemData["registry"]				:= SRA->RA_MAT

			aDateGMT							:= Iif(!Empty(SRA->RA_ADMISSA),LocalToUTC( DTOS(SRA->RA_ADMISSA), "12:00:00" ),{})
			oItemData["admissionDate"]			:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

			If !empty(SRA->RA_DEPTO)
				oItemData["department"]         := Alltrim( EncodeUTF8( fDesc("SQB",SRA->RA_DEPTO,"QB_DESCRIC",, xFilial("SQB" , SRA->RA_FILIAL) ) ) )
				oTeams["name"]					:= Alltrim( EncodeUTF8( fDesc("SQB", GetDepSup(SRA->RA_DEPTO,SRA->RA_FILIAL),"QB_DESCRIC") ) )//Alltrim( EncodeUTF8( fDesc("SQB", SRA->RA_DEPTO,"QB_DESCRIC") ) ) // - Protheus não possui o conceito de times, portanto segue o valor do department, para adequar a API.
				oTeams["default"]   			:= .T.
			Else
				oItemData["department"]         := ""
				oTeams["name"]                  := ""
				oTeams["default"]               := .F.
			EndIf

			Aadd(aTeams, oTeams)

			oItemData["teams"] 					:= aTeams

			// Dados complementares ao Perfil, somente se não for gestor, para alterações de dados do eSocial
			oItemData["complementaryData"] := NIL
			oItemData["dependents"]        := NIL
			oItemData["civilRegistration"] := NIL
			oItemData["desabilities"]      := NIL
			oPersonalData["motherName"] := NIL
			oPersonalData["fatherName"] := NIL
			If !lGestor
				//Grau de instrução
				oGrauInstr["id"]   := AllTrim( SRA->RA_GRINRAI )
				oGrauInstr["name"] := Alltrim( ;
									  EncodeUTF8( ;
									  Upper( ;
									  fDesc("SX5","26" + SRA->RA_GRINRAI,"X5Descri()",, xFilial("SX5" , SRA->RA_FILIAL) ) ) ) )
				oComplData["degreeOfEducation"] := oGrauInstr
				
				//Estado Civil
				oEstCivil["id"]   := AllTrim( SRA->RA_ESTCIVI )
				oEstCivil["name"] := Alltrim( ;
									 EncodeUTF8( ;
									 Upper( ;
									 fDesc("SX5","33" + SRA->RA_ESTCIVI,"X5Descri()",, xFilial("SX5" , SRA->RA_FILIAL) ) ) ) )
				oComplData["maritalStatus"] := oEstCivil

				//Aposentadoria
				oComplData["retirement"] := AllTrim( SRA->RA_EAPOSEN )

				//Processo para menor de 14 anos trabalhando.
				oComplData["minorProcessNumber"] := AllTrim( SRA->RA_NJUD14 )
				
				// Adiciona
				oItemData["complementaryData"] := oComplData

				//Dependentes.
				oItemData["dependents"] := fProfDep( SRA->RA_FILIAL, SRA->RA_MAT )

				//Nome do pai e da mãe.
				oPersonalData["motherName"] := AllTrim( EncodeUTF8( SRA->RA_MAE ) )
				oPersonalData["fatherName"] := AllTrim( EncodeUTF8( SRA->RA_PAI ) )

				//Dados relacionados à deficiência.
				oDefs["observation"] := AllTrim( EncodeUTF8( Upper( SRA->RA_OBSDEFI ) ) )
				oDefs["desabilities"] := fSetDef( SRA->RA_PORTDEF )
				oItemData["desabilities"] := oDefs

				//Registro de identificação civil - RIC
				//Atribui pais fixo - Brasil.
				oRICCoun["id"]   := "01058"
				oRICCoun["name"] := Upper( EncodeUTF8( STR0041 ) )
				oRICCoun["abbr"] := "BR"

				//Busca estado
				oRICStat["id"]   	  := Alltrim(SRA->RA_UFRIC )
				oRICStat["name"] 	  := Alltrim(SRA->RA_UFRIC )
				oRICStat["abbr"]      :=Alltrim(SRA->RA_UFRIC )
				oRICStat["country"]   := oRICCoun

				// Busca cidade.
				oRICCity["id"]         := Alltrim(SRA->RA_CDMURIC)
				oRICCity["name"]		:= If( !Empty( SRA->RA_CDMURIC ) .And. !Empty( SRA->RA_UFRIC ), ;
										Alltrim( ;
										EncodeUTF8( ;
										fDesc("CC2",SRA->RA_UFRIC+SRA->RA_CDMURIC,"CC2_MUN",,SRA->RA_FILIAL) ) ), ;
										"" )
				oRICCity["state"]      := oRICStat

				oRIC["number"]              := Alltrim( SRA->RA_NUMRIC )
				oRIC["organizationEmitter"] := Alltrim( EncodeUTF8( SRA->RA_EMISRIC ) )
				oRIC["emitterDate"]         := If( !Empty( SRA->RA_DEXPRIC ), FormatGMT( DTOS( SRA->RA_DEXPRIC ), .T. ), "" )
				oRIC["state"]				:= oRICStat
				oRIC["city"]				:= oRICCity

				oItemData["civilRegistration"] := oRIC

				//Busca dados de orgão de classe.
				oClass["classNumber"]        := AllTrim( SRA->RA_CODIGO )
				oClass["organizationSender"] := AllTrim( SRA->RA_OCEMIS )
				oClass["senderDate"] 		 := If( !Empty( SRA->RA_OCDTEXP ), FormatGMT( DTOS( SRA->RA_OCDTEXP ), .T. ) , "" )
				oClass["dueDate"]            := If( !Empty( SRA->RA_OCDTVAL ), FormatGMT( DTOS( SRA->RA_OCDTVAL ), .T. ), "" )

				oItemData["organizationClassDocument"] := oClass
			EndIf

			// - Coordinator
			If (Len(aCoordinator) > 0)
				oCoordinator["id"] 					:= aCoordinator[3] +"|" +aCoordinator[4]
				oCoordinator["name"]				:= Alltrim( EncodeUTF8(If(lNomeSoc .And. !Empty(aCoordinator[5]), aCoordinator[5], aCoordinator[1])))
				oCoordinator["roleDescription"]		:= If(Len(aCoordinator) >= 2, EncodeUTF8(aCoordinator[2]), "")

				oItemData["coordinator"] 			:= oCoordinator
			EndIf

			oItemData["gender"]					:= Iif( SRA->RA_SEXO == "M", "Masculino", "Feminino")
			oItemData["nickname"]				:= Alltrim( EncodeUTF8(SRA->RA_APELIDO) )

			// - Data de Nascimento no format UTC
			aDateGMT							:= {}
			aDateGMT 							:= Iif(!Empty(SRA->RA_NASC),LocalToUTC( DTOS(SRA->RA_NASC), "12:00:00" ),{})
			oItemData["bornDate"]				:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
			IF cPaisLoc == "BRA"
				oItemData["bornCity"]			:= Alltrim( EncodeUTF8(SRA->RA_MUNNASC) )
			ENDIF
			oItemData["nacionality"]			:= Alltrim( EncodeUTF8( fDesc("CCH",SRA->RA_NACIONC,"CCH_PAIS",,SRA->RA_FILIAL) ) )

			oPersonalData["nickname"]			:= Alltrim( EncodeUTF8(SRA->RA_APELIDO) )
			oPersonalData["gender"]				:= Iif( SRA->RA_SEXO == "M", "Masculino", "Feminino")

			// - Data de Nascimento no format UTC
			aDateGMT							:= {}
			aDateGMT 							:= Iif(!Empty(SRA->RA_NASC),LocalToUTC( DTOS(SRA->RA_NASC), "12:00:00" ),{})
			oPersonalData["bornDate"]			:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

			// Cidade, estado e pais de nascimento.
			oCountry["id"]						:= AllTrim( EncodeUTF8( SRA->RA_NACIONC ) )
			IF cPaisLoc == "BRA"
				oCountry["name"]				:= Alltrim( EncodeUTF8( fDesc("CCH",SRA->RA_NACIONC,"CCH_PAIS",,SRA->RA_FILIAL) ) )
			ENDIF

			oState["id"]						:= Alltrim( EncodeUTF8( SRA->RA_NATURAL ) )
			oState["abbr"]						:= Alltrim( EncodeUTF8( SRA->RA_NATURAL ) )
			oState["name"]						:= Alltrim( EncodeUTF8( SRA->RA_NATURAL ) )
			oState["country"]					:= oCountry
			oBornCity["state"]					:= oState

			oBornCity["id"]						:= Alltrim( EncodeUTF8( SRA->RA_CODMUNN ) )
			IF cPaisLoc == "BRA"
				oBornCity["name"]				:= Alltrim( EncodeUTF8(SRA->RA_MUNNASC) )
			ENDIF
			oBornCity["abbr"]					:= Nil
			oBornCity["country"]				:= oCountry
			oPersonalData["bornCity"]			:= oBornCity

			oItemData["personalData"]			:= oPersonalData

			// - Adresses
			IF cPaisLoc == "BRA"
				oAddresses["id"]				:= "pessoal"
				oAddresses["abbr"]				:= Alltrim( EncodeUTF8( SRA->RA_LOGRTP ) )
				oAddresses["name"]				:= Alltrim( EncodeUTF8( fDescRCC("S054", SRA->RA_LOGRTP, 1, 4, 5, 20) ) )
			ENDIF

			oAddreType["addressType"]			:= oAddresses
			oAddreType["name"]					:= AllTrim( EncodeUTF8( SRA->RA_LOGRDSC ) )
			oAddreType["default"]				:= .T.
			oAddreType["type"]					:= "home"
			oAddreType["id"]					:= "pessoal"
			oAddreType["zipcode"]				:= Alltrim( EncodeUTF8(SRA->RA_CEP) )
			IF cPaisLoc == "BRA"
				oAddreType["number"]			:= Alltrim( EncodeUTF8(SRA->RA_LOGRNUM) )
			ENDIF

			oAddreType["complement"]			:= Alltrim( EncodeUTF8(SRA->RA_COMPLEM) )
			oAddreType["neighborhood"]			:= Alltrim( EncodeUTF8(SRA->RA_BAIRRO) )

			oCountry							:= JsonObject():New()
			oCountry["id"]						:= "01058"
			oCountry["abbr"]					:= ""
			IF cPaisLoc == "BRA"
				cCodPais 						:= IIf( Empty(SRA->RA_RESEXT) .Or. SRA->RA_RESEXT == "2" , "01058", AllTrim(SRA->RA_PAISEXT) )
				oCountry["name"]				:= Alltrim( EncodeUTF8( fDesc("CCH",cCodPais,"CCH_PAIS",,SRA->RA_FILIAL) ) )
			ENDIF

			oState								:= JsonObject():New()
			oState["id"]						:= Alltrim( EncodeUTF8(SRA->RA_ESTADO) )
			oState["abbr"]						:= Alltrim( EncodeUTF8(SRA->RA_ESTADO) )
			oState["name"]						:= Alltrim( EncodeUTF8(SRA->RA_ESTADO) )

			oAddresses							:= JsonObject():New()
			oAddresses["id"]					:= AllTrim( EncodeUTF8( SRA->RA_CODMUN ) )
			oAddresses["name"]					:= Alltrim( EncodeUTF8(SRA->RA_MUNICIP) )
			oAddresses["abbr"]					:= Alltrim( EncodeUTF8(SRA->RA_MUNICIP) )
			oAddresses["country"]				:= oCountry
			oState["country"]					:= oCountry
			oAddresses["state"]					:= oState

			oAddreType["city"]					:= oAddresses

			Aadd(aAddressBody, oAddreType)

			oItemData["addresses"] 				:= aAddressBody

			// - Phone
			IF cPaisLoc == "BRA"
				oNumberPhone["id"]				:= "casa"
				oNumberPhone["ddd"]				:= Val(Alltrim( SRA->RA_DDDFONE ))
			ENDIF
			oNumberPhone["region"]				:= Nil
			oNumberPhone["number"]				:= Alltrim( SRA->RA_TELEFON )
			oNumberPhone["default"]				:= .T.
			oNumberPhone["type"]				:= "home"

			Aadd(aPhones, oNumberPhone )

			// - Phone
			IF cPaisLoc == "BRA"
				oNumberCel["id"]					:= "celular"
				oNumberCel["region"]				:= Nil
				oNumberCel["ddd"]					:= Val(Alltrim( SRA->RA_DDDCELU ))
				oNumberCel["number"]				:= Alltrim( SRA->RA_NUMCELU )
				oNumberCel["default"]				:= .F.
				oNumberCel["type"]					:= "mobile"

				Aadd(aPhones, oNumberCel )
			ENDIF

			// - E-mails
			oFlProperties := JsonObject():New()
			oFlProperties["field"] 			:= "emails.profissional"
			oFlProperties["visible"]		:= .T.
			oFlProperties["editable"]		:= .F.
			oFlProperties["required"]		:= .F.

			oEmailWork["id"] 				:= "profissional"
			oEmailWork["email"]				:= Alltrim( EncodeUTF8( SRA->RA_EMAIL ) )
			oEmailWork["default"]			:= .T.
			oEmailWork["type"]				:= EncodeUTF8("work")
			oEmailWork["props"]				:= oFlProperties

			Aadd(aEmails, oEmailWork)

			// - E-mails
			IF cPaisLoc == "BRA"
				oFlProperties := JsonObject():New()
				oFlProperties["field"] 			:= "emails.pessoal"
				oFlProperties["visible"]		:= .T.
				oFlProperties["editable"]		:= .F.
				oFlProperties["required"]		:= .F.

				oEmailPersonal["id"]			:= "pessoal"
				oEmailPersonal["email"]			:= Alltrim( EncodeUTF8( SRA->RA_EMAIL2 ) )
				oEmailPersonal["default"]		:= .F.
				oEmailPersonal["type"]			:= EncodeUTF8("home")
				oEmailPersonal["props"]			:= oFlProperties

				Aadd(aEmails, oEmailPersonal)
			ENDIF

			oContacts["phones"]					:= aPhones
			oContacts["emails"]					:= aEmails
			oItemData["contacts"]				:= oContacts

			oItemData["webReferences"]			:= {}

			// - Obtém os Documentos necessários
			GetDocuments(@aDocs)
			oItemData["documents"]				:= aDocs

			//-----------------------------------
			//Adiciona tratamento para visualizacao e edicao de campos - FieldProperties
			//-----------------------------------

			//Nao exibir o campo Equipe porque nao e usado no Protheus
			oFlProperties := JsonObject():New()
			oFlProperties["field"] 				:= "teams.name"
			oFlProperties["visible"]			:= .F.
			oFlProperties["editable"]			:= .F.
			oFlProperties["required"]			:= .F.

			Aadd(aFlProperties, oFlProperties)

			//Exibe o Apelido apenas de tiver sido informado no cadastro
			If Empty(SRA->RA_APELIDO)
				oFlProperties := JsonObject():New()
				oFlProperties["field"] 			:= "personalData.nickname"
				oFlProperties["visible"]		:= .F.
				oFlProperties["editable"]		:= .F.
				oFlProperties["required"]		:= .F.

				Aadd(aFlProperties, oFlProperties)
			EndIf

			oItemData["props"]		:= aFlProperties

		Else
			oItemData	 	:= JsonObject():New()
			// - Summary
			oItemData["id"] 				:= SRA->RA_FILIAL +"|" +SRA->RA_MAT
			oItemData["name"]				:= Alltrim( EncodeUTF8(If(lNomeSoc .And. !Empty(SRA->RA_NSOCIAL), SRA->RA_NSOCIAL, SRA->RA_NOME)))
			oItemData["roleDescription"] 	:= Alltrim( EncodeUTF8( FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC",,SRA->RA_FILIAL ) ) )

			aDateGMT						:= Iif(!Empty(SRA->RA_ADMISSA),LocalToUTC( DTOS(SRA->RA_ADMISSA), "12:00:00" ),{})
			oItemData["admissionDate"]		:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

			//Situação do funcionário
			oItemData["employeeStatus"]		:= Iif( Empty(SRA->RA_SITFOLH), "N", SRA->RA_SITFOLH)

			// - Data de Nascimento no format UTC
			aDateGMT						:= {}
			aDateGMT						:= Iif(!Empty(SRA->RA_NASC),LocalToUTC( DTOS(SRA->RA_NASC), "12:00:00" ),{})
			oItemData["bornDate"]		    := Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

			// Verifica se o funcionário está substituindo o gestor para exibir as notificações de aprovação
			// ou se há alguma requisição no seu passo de aprovação
			oItemData["isSubstitute"]       := Len( fGetSupNotify(SRA->RA_FILIAL, SRA->RA_MAT) ) > 0 .Or. ;
											   fChkRH3Apr(SRA->RA_FILIAL, SRA->RA_MAT)
		EndIf

		Aadd(aData, oItemData)
		oItem 				:= JsonObject():New()
		oItem["data"] 		:= oItemData
		oItem["length"] 	:= Len(aData)
		oItem["messages"] 	:= Iif( Empty(aData), EncodeUTF8(STR0004), "" ) //"Não foi possível carregar os dados para colaborador: "

		//Limpa os objetos.
		FreeObj( oRICCity )
		FreeObj( oRICStat )
		FreeObj( oRICCoun )
		FreeObj( oRIC )
		FreeObj( oDefs )
		FreeObj( oComplData )
		FreeObj( oEstCivil )
		FreeObj( oGrauInstr )
		FreeObj( oSummary )
		FreeObj( oCoordinator )
		FreeObj( oTeams	)
		FreeObj( oAddresses	)
		FreeObj( oAddreType	)
		FreeObj( oNumberPhone )
		FreeObj( oNumberCel )
		FreeObj( oEmailWork )
		FreeObj( oEmailPersonal	)
		FreeObj( oState	)
		FreeObj( oCountry )
		FreeObj( oPersonalData )
		FreeObj( oBornCity )
		FreeObj( oContacts )
		FreeObj( oMessages )
		FreeObj( oItemData )
	EndIf

	If lJob
      //Atualiza a variavel de controle que indica a finalizacao do JOB
      PutGlbValue(cUID, "1")
   EndIf

Return( oItem )

Function DataImage(oItem, aMessages, cRD0Login, cBranchVld, aFunc)
	Local cQryRD0	 	:= GetNextAlias()
	Local oItemRet		:= JsonObject():New()
	Local cRD0Branch	:= ""
	Local cBkpMod		:= cModulo //Variável publica com o modulo que está startado. Por padrão em ambientes REST vem como FAT.
	Local aRet			:= {}
	Local nPos		   	:= 0
	Local nIdFunc	   	:= 0
	Local cFuncFoto		:= ""
	Local cMatRD0		:= ""
	Local cBranchRD0	:= ""
	Local cFilSRA 		:= ""
	Local cMatSRA 		:= ""
	Local cQrySRA		:= ""
	Local __cDelete 	:= "% SRA.D_E_L_E_T_ = ' ' %"
	Local cEmpSRA		:= cEmpAnt

	Default oItem    	:= JsonObject():New()
	Default aMessages	:= {}
	Default cRd0Login	:= {}
	Default cBranchVld	:= FwCodFil()
	Default aFunc		:= {}

	oItemRet["content"]	:= ""
	oItemRet["type"]	:= ""

	nIdFunc	:= Len(aFunc)

	cModulo := "GPE" // Atribui o módulo GPE para consultar corretamente as fotos no banco de dados.
	If !empty(aFunc) .and. (Alltrim(aFunc[1]) == "{current}" .Or. Alltrim(aFunc[1]) == "%7Bcurrent%7D")
		//Busca foto do colaborador logado
		cRD0Branch := xFilial("RD0", cBranchVld)
		BEGINSQL ALIAS cQryRD0
    	SELECT RD0.RD0_NOME, RD0.RD0_CODIGO, RD0.RD0_CIC, RD0.RD0_LOGIN, RD0.RD0_BITMAP
    	FROM %table:RD0% RD0
    	WHERE RD0_FILIAL =  %Exp:cRD0Branch% AND
        	RD0.RD0_LOGIN = %exp:Upper(cRD0Login)%  OR
        	RD0.RD0_CIC   = %exp:cRD0Login%  AND
        	RD0.%notDel%
		ENDSQL

		If !(cQryRD0)->(Eof())
			cFuncFoto := (cQryRD0)->RD0_BITMAP

			//busca matriculas associada a pessoa, para capturar a foto do SRA
			If GetAccessEmployee(cRD0Login, @aRet, .T., .T.)
				If Len(aRet) >= 1
					nPos := Ascan(aRet,{|x| !(x[10] $ "30/31")})
					If nPos > 0
						cMatRD0     := aRet[nPos][1]
						cBranchRD0  := aRet[nPos][3]
					Else
						cMatRD0     := aRet[1][1]
						cBranchRD0  := aRet[1][3]
					EndIf
				EndIf

				dbSelectArea("SRA")
				SRA->( dbSetOrder(1) )
				If (SRA->( dbSeek( xFilial("SRA" , cBranchRD0) + cMatRD0) ))
					If !empty(SRA->RA_BITMAP)
						cFuncFoto := Alltrim(SRA->RA_BITMAP)
					EndIf
				EndIf

				oItemRet["content"] := RetFoto_( SRA->RA_FILIAL, SRA->RA_MAT, cFuncFoto )
				oItemRet["type"]    := "jpg"
			EndIf
		EndIf
		(cQryRD0)->( DbCloseArea() )

	Else
		If nIdFunc > 1 
		
			cFilSRA := aFunc[1]
			cMatSRA := aFunc[2]
			cEmpSRA := If( nIdFunc > 2, aFunc[3], cEmpAnt )

			cQrySRA 	:= GetNextAlias()
			__cSRAtab 	:= "%" + RetFullName("SRA", cEmpSRA) + "%"

			BeginSql ALIAS cQrySRA
			SELECT RA_FILIAL, RA_MAT, RA_BITMAP 
			FROM %exp:__cSRAtab% SRA
			WHERE 
				SRA.RA_FILIAL = %Exp:cFilSRA% AND
				SRA.RA_MAT = %Exp:cMatSRA% AND
				%exp:__cDelete%
			EndSql

			If (cQrySRA)->(!Eof())
				cFuncFoto := Alltrim( (cQrySRA)->RA_BITMAP )
			EndIf

			If !empty(cFuncFoto)
				oItemRet["content"] := RetFoto_( (cQrySRA)->RA_FILIAL, (cQrySRA)->RA_MAT, cFuncFoto )
				oItemRet["type"]    := "jpg"
			EndIf

			(cQrySRA)->( DBCloseArea() )

		EndIf
	EndIf

	cModulo := cBkpMod //Volta ao modulo original
	oItem["data"] 		:= oItemRet
	oItem["length"]		:= 1

	oItemRet			:= Nil
	oItemRet			:= JsonObject():New()
	oItem["messages"] 	:= {}

Return( oItem )

Function RetFoto_(Filial,Matricula,cFoto)
	Local cBmpPict
	Local nTamMax		:= 204800 //200Kb
	Local cLine			:= ""
	Local cRet			:= ""
	Local cNewImg		:= ""	
	Local cPathPict		:= GetSrvProfString("Startpath","")
	Local cExtensao		:= ".JPG"
	Local lProcImg		:= .T.
	Local lContinua		:= .T.
	Local lMRHLoadImg	:= ExistBlock("MRHLoadImg")
	Local nTamFile		:= 0
	Local cImgFile		:= ""

	Matricula := AllTrim(Matricula)

	If !Empty( cBmpPict := Upper( AllTrim( cFoto ) ) )
		cImgFile := cBmpPict+Filial+Matricula
		If RepExtract(cBmpPict,cPathPict+cImgFile)

			If !File(cPathPict+cImgFile+cExtensao)
				cExtensao := ".BMP"
				lContinua := File(cPathPict+cImgFile+cExtensao)
			EndIf

			If lContinua

				//Se a imagem for BMP converte para JPG
				If cExtensao ==  ".BMP"
					cNewImg := cImgFile + "_new"
					If ( BmpToJpg (cPathPict+cImgFile+cExtensao, cPathPict+cNewImg+cExtensao) ) == 0
						fErase(cPathPict+cImgFile+cExtensao)
						cImgFile := cNewImg
					EndIf
				EndIf

				oFile := FwFileReader():New(cPathPict+cImgFile+cExtensao)

				//Se houver erro de abertura da foto abandona processamento
				If oFile:Open()
					nTamFile := oFile:getFileSize()

					If lMRHLoadImg
						If ( ValType( nTamMax := ExecBlock("MRHLoadImg", .F. , .F. ,{Filial,Matricula,cFoto}) ) == "N" )
							If nTamFile > nTamMax
								lProcImg := .F.
								cLine := ""
							EndIf
						EndIf
					EndIf

					//Processa o arquivo ou exibe uma imagem padrao caso o arquivo supere 200Kb
					If lProcImg .And. nTamMax >= nTamFile
						cLine := oFile:FullRead()
					EndIf

					//Fecha o arquivo aberto e exclui a imagem
					oFile:Close()
					fErase(cPathPict+cImgFile+cExtensao)					
				EndIf
			EndIf
		EndIf
	EndIf

	//Gera imagem padrão já Encode64 apenas quando o tamanho do arquivo for maior que o tamanho máximo definido.
	//Caso não exista no cadastro de funcionários, será gerada a imagem que atualmente já é usada.
	If nTamFile > nTamMax
		cLine := fGetImgDefault()
		
		//Exibe no console a informacao sobre a imagem do funcionario
		Conout(">>> "+ STR0010 +" ("+ Filial +"/"+ Matricula +") "+ STR0011 +" ("+ cValToChar(nTamMax) +" Bytes). " + STR0012 ) //"A matricula"#"ultrapassa o limite de bytes"#"Sera utilizada uma imagem padrao"
	EndIf

	If !Empty(cLine)
		If nTamFile < nTamMax
			cRet := Encode64(cLine)
		Else
			cRet := cLine
		EndIf
	EndIf
		
Return cRet

Function GetDocuments(aDocs)
	Local oFieldsDoc	:= JsonObject():New()
	Local oDocuments	:= JsonObject():New()
	Local aFieldsDoc	:= {}
	Local aDateGMT		:= {}
	Local aBoxCNH       := Iif(cPaisLoc == "BRA", RetSx3Box( Posicione("SX3", 2, "RA_CATCNH", "X3CBox()" ),,, 1 ), {})

	Default aDocs		:= {}

	// -------------------------------------------------------
	// - Documents
	oDocuments["type"] 					:= "brid"
	oDocuments["label"]					:= "brid"

	// - BRID - RG
	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_RG )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= "99999999-99"
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc

	// - ESTADO EMISSOR
	oFieldsDoc 							:= JsonObject():New()
	oFieldsDoc["type"] 					:= "senderState"
	oFieldsDoc["value"]					:= SRA->RA_RGUF
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= Nil
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc

	// - ESTADO EMISSOR
	oFieldsDoc 							:= JsonObject():New()
	oFieldsDoc["type"] 					:= "sender"
	oFieldsDoc["value"]					:= SRA->RA_RGORG
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= Nil
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc

	// - DATA DE EMISSÃO
	IF cPaisLoc == "BRA"
		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "senderDate"

		aDateGMT							:= Iif(!Empty(SRA->RA_DTRGEXP),LocalToUTC( DTOS(SRA->RA_DTRGEXP), "12:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= "99/99/9999"
		Aadd(aFieldsDoc, oFieldsDoc)
	ENDIF

	oDocuments["fields"]				:= aFieldsDoc
	Aadd(aDocs, oDocuments)

	// ------------------------------------------------
	// - DOCUMENTS - CPF
	// - Nódulo responsável para o WIDGET DE CPF no UX.
	aFieldsDoc := {}
	oFieldsDoc := JsonObject():New()
	oDocuments := JsonObject():New()

	// - CPF
	oDocuments["type"] 					:= "cpf"
	oDocuments["label"]					:= "cpf"

	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_CIC )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= "999.999.999-99"
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc

	Aadd(aDocs, oDocuments)

	// ----------------------------------------------------------------
	// - DOCUMENTS - CARTEIRA DE TRABALHO - WORKCARD
	// - Nódulo responsável para o WIDGET DE CARTEIRA DE TRABALHO no UX.
	aFieldsDoc := {}
	oFieldsDoc := JsonObject():New()
	oDocuments := JsonObject():New()

	// - CARTEIRA DE TRABALHO
	oDocuments["type"] 					:= "workCard"
	oDocuments["label"]					:= "workCard"

	// NÚMERO
	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_NUMCP )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)

	// SÉRIE
	oFieldsDoc 							:= JsonObject():New()
	oFieldsDoc["type"] 					:= "series"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_SERCP )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)

	// ESTADO EMISSOR
	oFieldsDoc 							:= JsonObject():New()
	oFieldsDoc["type"] 					:= "senderState"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_UFCP )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)

	// DATA DE EMISSÃO
	IF cPaisLoc == "BRA"
		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "senderDate"
		aDateGMT							:= Iif(!Empty(SRA->RA_DTCPEXP),LocalToUTC( DTOS(SRA->RA_DTCPEXP), "00:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "00:00:00")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)
		oDocuments["fields"]				:= aFieldsDoc
		Aadd(aDocs, oDocuments)
	ENDIF

	// ------------------------------------------------
	// - DOCUMENTS - PIS - WORKCARD
	// - Nódulo responsável para o WIDGET DE PIS no UX.
	aFieldsDoc							:= {}
	oFieldsDoc							:= JsonObject():New()
	oDocuments							:= JsonObject():New()
	oDocuments["type"] 		  			:= "pis"
	oDocuments["label"]					:= "pis"

	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_PIS)
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= "999.99999.99-9"
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc
	Aadd(aDocs, oDocuments)

	// --------------------------------------------------------------
	// - DOCUMENTS - TITULO DE ELEITOR
	// - Nódulo responsável para o WIDGET DE TITULO DE ELEITOR no UX.
	aFieldsDoc							:= {}
	oFieldsDoc							:= JsonObject():New()
	oDocuments							:= JsonObject():New()
	oDocuments["type"] 					:= "elector"
	oDocuments["label"]					:= "elector"

	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_TITULOE)
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= "9999999999-99"
	Aadd(aFieldsDoc, oFieldsDoc)

	oFieldsDoc 							:= JsonObject():New()
	oFieldsDoc["type"] 					:= "zone"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_ZONASEC)
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)

	IF cPaisLoc == "BRA"
		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "section"
		oFieldsDoc["value"]					:= Alltrim( SRA->RA_SECAO)
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)
		oDocuments["fields"]				:= aFieldsDoc
		Aadd(aDocs, oDocuments)
	ENDIF

	// -------------------------------------------------------
	// - DOCUMENTS - RESERVISTA
	// - Nódulo responsável para o WIDGET DE RESERVISTA no UX.
	aFieldsDoc 							:= {}
	oFieldsDoc 							:= JsonObject():New()
	oDocuments 							:= JsonObject():New()
	oDocuments["type"] 					:= "war"
	oDocuments["label"]					:= "war"

	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_RESERVI )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)
	oDocuments["fields"]				:= aFieldsDoc
	Aadd(aDocs, oDocuments)

	// ------------------------------------------------
	// - DOCUMENTS - CNH
	// - Nódulo responsável para o WIDGET DE CNH no UX.
	aFieldsDoc							:= {}
	aDateGMT							:= {}
	oFieldsDoc							:= JsonObject():New()
	oDocuments							:= JsonObject():New()

	oDocuments["type"] 					:= "driverLicense"
	oDocuments["label"]					:= "driverLicense"

	oFieldsDoc["type"] 					:= "number"
	oFieldsDoc["value"]					:= Alltrim( SRA->RA_HABILIT )
	oFieldsDoc["label"]					:= Nil
	oFieldsDoc["mask"]					:= ""
	Aadd(aFieldsDoc, oFieldsDoc)

	oFieldsDoc 							:= JsonObject():New()
	IF cPaisLoc == "BRA"
		//Exibe o código da categoria da CNH
		oFieldsDoc["type"]				:= "other"
		oFieldsDoc["value"]				:= If( !Empty( SRA->RA_CATCNH ), ; 
												Alltrim(aBoxCNH[Ascan( aBoxCNH, { |aBox| aBox[2] = SRA->RA_CATCNH } )][1]), ;
												"")
		oFieldsDoc["label"]				:= If( !Empty( SRA->RA_CATCNH ), ;
												EncodeUTF8(STR0007), ; //"Categoria"
												"" )
		oFieldsDoc["mask"]				:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "sender"
		oFieldsDoc["value"]					:= Alltrim( EncodeUTF8(SRA->RA_CNHORG))
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "senderState"
		oFieldsDoc["value"]					:= Alltrim( EncodeUTF8(SRA->RA_UFCNH))
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "senderDate"
		aDateGMT							:= Iif(!Empty(SRA->RA_DTEMCNH),LocalToUTC( DTOS(SRA->RA_DTEMCNH), "12:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "dueDate"

		aDateGMT						    := {}
		aDateGMT							:= Iif(!Empty(SRA->RA_DTVCCNH),LocalToUTC( DTOS(SRA->RA_DTVCCNH), "12:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)
		oDocuments["fields"]				:= aFieldsDoc
		Aadd(aDocs, oDocuments)

		// --------------------------------------------------------
		// - DOCUMENTS - PASSAPORTE
		// - Nódulo responsável ppara o WIDGET DE PASSAPORTE no UX.
		aFieldsDoc 							:= {}
		aDateGMT   							:= {}
		oFieldsDoc 							:= JsonObject():New()
		oDocuments 							:= JsonObject():New()

		oDocuments["type"] 					:= "passport"
		oDocuments["label"]					:= Nil
		oFieldsDoc["type"] 					:= "number"
		oFieldsDoc["value"]					:= Alltrim( SRA->RA_NUMEPAS )
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "originCountry"
		oFieldsDoc["value"]					:= Alltrim( EncodeUTF8(FDESC("CCH",SRA->RA_CODPAIS,"CCH_PAIS",,SRA->RA_FILIAL) ) )
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "senderDate"
		aDateGMT							:= Iif(!Empty(SRA->RA_DEMIPAS),LocalToUTC( DTOS(SRA->RA_DEMIPAS), "12:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oFieldsDoc 							:= JsonObject():New()
		oFieldsDoc["type"] 					:= "dueDate"
		aDateGMT						    := {}
		aDateGMT							:= Iif(!Empty(SRA->RA_DVALPAS),LocalToUTC( DTOS(SRA->RA_DVALPAS), "12:00:00" ),{})
		oFieldsDoc["value"]					:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		oFieldsDoc["label"]					:= Nil
		oFieldsDoc["mask"]					:= ""
		Aadd(aFieldsDoc, oFieldsDoc)

		oDocuments["fields"]				:= aFieldsDoc
		Aadd(aDocs, oDocuments)
	ENDIF

Return(Nil)

Function CoordInfos(aStructREST,cMat,cBranchVld)
	Local aRet			:= {}
	Local nX			:= 0
	Local nI			:= 0

	Default aStructREST := {}
	Default cMat		:= ""
	Default cBranchVld  := FwCodFil()

	For nX := 1 To Len(aStructREST)
		For nI := 1 To Len(aStructRest[nX]:ListOfEmployee)
			If aStructRest[nX]:ListOfEmployee[nI]:Registration == cMat

				Aadd(aRet,Alltrim(aStructRest[nX]:ListOfEmployee[nI]:NameSup))
				Aadd(aRet, fSupGetPosition( aStructRest[nX]:ListOfEmployee[nI]:SupFilial, aStructRest[nX]:ListOfEmployee[nI]:SupRegistration, aStructRest[nX]:ListOfEmployee[nI]:SupEmpresa ) )
				Aadd(aRet,Alltrim(aStructRest[nX]:ListOfEmployee[nI]:SupFilial))
				Aadd(aRet,Alltrim(aStructRest[nX]:ListOfEmployee[nI]:SupRegistration))
				Aadd(aRet,Alltrim(aStructRest[nX]:ListOfEmployee[nI]:SocialNameSup))
				Exit

			EndIf
		Next nI
	Next nX

Return( aRet )

/*/{Protheus.doc} fGetImgDefault
Retorna uma imagem padrão Base64
@type		Static Function
@author		Henrique Ferreira
@since		01/10/2020
@return		cImg, Retorna uma imagem padrão já em base64.
/*/
Static Function fGetImgDefault()

    Local cImg := ""

    cImg += "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAGXRFWHRTb2Z0d2Fy"
    cImg += "ZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyVpVFh0WE1MOmNvbS5hZG9iZS54bXAA"
    cImg += "AAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5U"
    cImg += "Y3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6"
    cImg += "eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ2MCwgMjAyMC8w"
    cImg += "NS8xMi0xNjowNDoxNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRw"
    cImg += "Oi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpE"
    cImg += "ZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRv"
    cImg += "YmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNv"
    cImg += "bS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20v"
    cImg += "eGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRv"
    cImg += "YmUgUGhvdG9zaG9wIDIxLjIgKE1hY2ludG9zaCkiIHhtcE1NOkluc3RhbmNlSUQ9"
    cImg += "InhtcC5paWQ6RkY0REZGQjJGQ0Q0MTFFQUI1NDBGNTM2RDU3RjZDQjkiIHhtcE1N"
    cImg += "OkRvY3VtZW50SUQ9InhtcC5kaWQ6RkY0REZGQjNGQ0Q0MTFFQUI1NDBGNTM2RDU3"
    cImg += "RjZDQjkiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1w"
    cImg += "LmlpZDpGRjRERkZCMEZDRDQxMUVBQjU0MEY1MzZENTdGNkNCOSIgc3RSZWY6ZG9j"
    cImg += "dW1lbnRJRD0ieG1wLmRpZDpGRjRERkZCMUZDRDQxMUVBQjU0MEY1MzZENTdGNkNC"
    cImg += "OSIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4g"
    cImg += "PD94cGFja2V0IGVuZD0iciI/PhOAlewAAAfaSURBVHja1FtrTFNnGH45UAoWrRUK"
    cImg += "pTiZGDRm8zZioqgkwxlvLPMSJYxkgJGYuGhM/OGPxRGX7Ac//KUuGJKRLdEMQbdk"
    cImg += "I6JRl+iEaFA0BDMlwWyZhVKQm0UBwb1PLdob7ek5/Vr6JieU0/Od732e837v7XyN"
    cImg += "qaioIJFiMpnSJicnD01MTHzEf838N5UP/evXr3V8aHBNXFzcOB/22NjYQT56JEmy"
    cImg += "8N92/nuqu7vbKlK/OEGgcxjc0VevXn1mtVqNb9688Xs9ExI/Ojoazx8NfHzoPL0j"
    cImg += "Jibmm6SkJFtCQsI1jUZzsqur696MJSAjIyOFAdeMjIx8yk9NF4p7grgXL14Y+Sji"
    cImg += "f4sSExPts2bN+pMJKXv27FnvjCBg4cKF8axgdU9PT/H4+HisSHN9+fKljo8CtoZu"
    cImg += "o9F4jq2j/OnTp2Nq7impGZyWlnbCYrEM2Wy2r0SDdxXMhTkxN3QIOwFmszlXp9P1"
    cImg += "8/r+lteuliIkmBs6QBfoFBYC2MEdZHO/Zbfb59IMEegCnaCbUAJ43f3IjJ9hDy/R"
    cImg += "DBPoBN2gY8gJgKMzGAz3eN2VBQppkRToBh2hK3QOCQG4UW9v7z/9/f2fUJQIdIXO"
    cImg += "WVlZ8aoJGBgYaB4eHjZRlAl0ZiKaVRGA9RRNT96XJQTyCZI/b89mVEZRLsDgLzpI"
    cImg += "08V5HnhqJju8YBwjsHCqniubgMHBwYaZGOrUhEj2ZQ2yCEhNTT0hOsnhUhfz0OrV"
    cImg += "qx0HPuOc6GQJ2PwWQwgbXGUdE6lIdnY2FRYWogfg+ZSotraWOjo6hM09NDR0jMP6"
    cImg += "964FlOQROqpF5fZc29O6deuouLjYC7yzKeL4DtfgWhHC5boWlavPJYB6ntdJsSj2"
    cImg += "ly9fTps2bQp4Ha5ZsWKFMCsARmD1IgDNDFElbXx8PG3btk329Vu3bnWMEVVKA6sX"
    cImg += "AejkiGJ9zZo1pNXKX1m4FmNEiStWBwHp6ek56LaIWvvr168PehzGiPIFwIq+5TsC"
    cImg += "2CyOimI7ISFBkTljDMYKzA2OviMA3VtRE+n1+oiMlRERHJgl9O05STCKmohr84iM"
    cImg += "lZEYGYFdwksLkTk/Mx2RsXJqBGCX8MZGZObHiYeaml5oegzssACz4MaE4ifEqatQ"
    cImg += "AoAdFpAqchKYcVtbW9DjHjx4QGNjY6ItIBUE6Emw3LlzJ+gxLS0twstkYJfwllb0"
    cImg += "RFxh0sOHD2Vf39ra6hgThj6BTuIkSBOOrkxDQwP19fXJKVbo8uXL4WqUaCRR6aan"
    cImg += "YD2fPXuW2tvbp73m0aNHVFVVJXztu5XD2JwQrskArL6+3qclcH5OdXV1QmO/jx7E"
    cImg += "OAiwUxhl9uzZPjO8xMREx3fhFGCXsC0lHJNhqa1atYqOHDlCkuS733r48GFH4yRc"
    cImg += "yxLY47Anh95vSxEiZrPZ0RCZP39+oCdCu3btcjRKGxsbhUcCYI/DhiRRE6Dbu3nz"
    cImg += "Zlq0aJG8AU1NROfP0wf8sRx+gSOC1WajupwcsruU1Dr2JTtu3iTtyIjb8N/z88mW"
    cImg += "lCTfATJ2WADc8o6QelY28Y0bNzoanEFJbq6DADpz5q1fcJpm6eLFVMVkcuLiOL/l"
    cImg += "7l3Kvn3bbWgbzxcMeKcFYCeadCqUaw5mXFJSEjz4KamsJOIn6SrG06fp4IIFpNFo"
    cImg += "KJ/T6mXXr7t938FzXQyy6wTMwC5hH55Op7OFytEVFBRQZmam8pvoODGtribip+4q"
    cImg += "yaWltI8JyLt0ye18z5Il9FtenoJpdDZgl5xtq2uhIGAxK71y5Ur1N8rKIqqp8Tqd"
    cImg += "fsz9nc0QO9Wf2GnaFbTcpjBLTrM9GQoC8hQ8Cb/+4MKFab8e5ZyhfudOReBdMTsI"
    cImg += "YFO4h02IavRNTk7Gy5XQhpE9e4iOH/f5VePu3fTvvHmKbguswPyOAAh2YKoNeSGX"
    cImg += "zk6i2lqfX61tbnaEQyXiilVyWRNl7GUnlOo6d26IXyjb2SDLORt48sQ34Y8fO8Jh"
    cImg += "sAKMwOpFAPbe6vX6c0r1nafQHKeV/fuJbtxwP+cRHhEO84PsNvGDOue6zzjOo1Ap"
    cImg += "Hx4eLlTyhvjKlSt09erVkGD/grO8jz3u9dfevdTO0aG0pYW0Lr1ChMX+OXOoVUbo"
    cImg += "1Wq1o9hfbLO9j/puVQnemzNDlQqbC3jDpPrYcP++F3gkOteWLqUurZZ+LSrymnvL"
    cImg += "xYu04PlzOU+/0nNztVdZZrVaKzhJGKAISG5HR8BE52+TiW5y7Hd7ssPDVMCk+XOK"
    cImg += "wARsXuHQ18XsC7bzMrgV7n1C/3Eo/eXAAbdzfZzfe8b6G8uWkcUo/2UWx/xJfvrb"
    cImg += "7XbvSO+TAIvF0mQymQ5h7204d4oFE9dhCXLT85SUlEPs+Jp8Fm7TDeRE4QceWENR"
    cImg += "LsAALNNWrv4Gs7fcZzAY7kcreOgODH5Ldxmecy2Hx+5oAw+dmYC1AXsXgS5A2GAz"
    cImg += "yowmS4Cu0Lmzs3NMNQFTJPT39+cYjcaacDUslfYjoCN0lftjqqDCHNZTWlra1wgr"
    cImg += "Mw08dIJugda8KgKmogNXfhsilSxNl+RAJ3/ePmQETOUJnFQYmPHvkF9HCjjmhg7Q"
    cImg += "BTopuYeqTA+pZUZGxhxedz+rKaWVlLSY02w2z/GV3oaNgLc9i84xXnclbIKm5OTk"
    cImg += "P9R2lgJ1cjAH5sKcan81Om0qrEScNfbn+Oz642nsxlKaTsOro3vr+uNpvEQNqfMU"
    cImg += "8aSc/bYvnWSo/vm8mo1WgeR/AQYAccLexB0DE8MAAAAASUVORK5CYII="

Return cImg

/*/{Protheus.doc} fEmptyMemo
Verifica se um campo memo é vazio, descartando as quebras de linha
@type   Static Function
@author Henrique Ferreira
@since 25/11/2022
@version	1.0
@return lRet
/*/
Static Function fEmptyMemo(cCpoMemo)

Local lRet := .F.
Local cQuebra := CHR(13) + CHR(10)
Default cCpoMemo := ""

cCpoMemo := STRTRAN(cCpoMemo,cQuebra,"")

If Empty(cCpoMemo)
	lRet := .T.
EndIf

Return lRet
