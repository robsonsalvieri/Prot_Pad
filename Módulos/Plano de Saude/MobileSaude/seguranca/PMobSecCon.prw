#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobSecCon

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Class PMobSecCon From PMobConfig

	// Propriedades de uso geral
	Data oRequestModel

	Data cModelEndPoint
	Data clientId 
	Data clientSecret
	Data aModel
	Data oBody
	Data token

	Method New() CONSTRUCTOR

	// Metodos obrigatorios do padrao definido
	Method GetModel()
	Method SetAuthParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)

	// Metodos de regras de negocio do serviço
	Method GetToken()
	Method CheckUserAPI()
	Method CheckToken(cToken)
	Method GetTimeToExpireToken()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method New() Class PMobSecCon

	// Inicializa a classe herdada de configuração 
	_Super:New()

	self:cModelEndPoint	:= nil
	self:oRequestModel 	:= nil

	self:clientId 		:= nil
	self:clientSecret	:= nil

	self:aModel 		:= {}
	self:oBody			:= JsonObject():New()
	self:token			:= ""
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetToken

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetToken() class PMobSecCon

	Local oBeneficiario := nil 
	// Gera o token 
	Local nX := Randomize( 1, 1750 )
	Local nY := Randomize( nX, 100000 )
	Local nZ := 0
	Local nRandom := 0	
	Local aTime := {}
	Local cChave := ""
	Local nCnt := 1
	Local aCompose 	:= {}
	Local oToken	:= {}
	Local aTimeToExpireToken := {}
	Local lFindToken := .F.

	// DEFINE os parametros 
	self:SetAuthParameters()

	// Verifica se o usuário existe
	If !self:CheckUserAPI()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetStatusCode(401)
		self:oRequestModel:SetMessageResponse("Não autorizado")	
		Return(.F.)
	Endif

	// Constroi o token
	GetTimeStamp(Date() , aTime)

	For nCnt := 1 to len(self:ClientId)
		cKey := SubStr(self:ClientId, nCnt, 1)
		If Val(cKey) > 0
			Aadd(aCompose, Val(cKey))
		Endif
	Next

	If Len(aCompose) > 0
		nRandom := iif(Len(aCompose)==1,2,Len(aCompose))
		nZ := Randomize( 1, nRandom )	
		nY := (nY*aCompose[nZ])

		nRandom := iif(Len(aCompose)==1,2,Len(aCompose))
		nZ := Randomize( 1, nRandom )
		aTime[1] := Alltrim(Str((Val(aTime[1]) * nZ)))
	Endif

	cChave := Alltrim(Str(nX)) + aTime[1] + Alltrim(Str(nY))
	cChave := md5(cChave)

	For nCnt := 1 to 3
		nZ := Randomize( 4, (len(cChave)-4) )
		cChave := Stuff(cChave, nZ, 0, '-')
	Next

	aTimeToExpireToken := self:GetTimeToExpireToken()

	BJZ->(DBSetOrder(1))
	lFindToken := BJZ->(MsSeek(FWXFilial("BJZ")+PlsIntPad()+cChave))

	BJZ->( RecLock("BJZ", !lFindToken) )
	BJZ->BJZ_FILIAL := xFilial("BJZ")
	BJZ->BJZ_CODOPE := PlsIntPad()
	BJZ->BJZ_TOKEN  := cChave
	BJZ->BJZ_ATIVO  := "1"
	BJZ->BJZ_CLIID  := self:clientId
	BJZ->BJZ_SECRET := self:clientSecret	
	BJZ->BJZ_DTEXPI := aTimeToExpireToken[2]
	BJZ->BJZ_HREXPI := aTimeToExpireToken[3]
	BJZ->( MsUnlock() )

	// Prepara o retorno
	oToken := jSonObject():New()

	oToken['auth'] := jSonObject():New() 
	oToken['auth']['chave'] := "Access"
	oToken['auth']['token'] := cChave
	oToken['auth']['expiracao'] := aTimeToExpireToken[1]

	self:oRequestModel:SetDataResponse(oToken) 


	/* - modelo de dados do payload de retorno
	/exemplo da API
	"auth": [
	{
	"chave": "Access",
	"token": "Bearer AbCdEf123456"
	},
	{
	"chave": "custom-auth",
	"token": "JWT AbCdEf123456"
	}
	*/

Return(.T.)	


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckUserAPI

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method CheckUserAPI() class PMobSecCon

	Local lRet := .T. 
	Local cSql := ""

	cSql := " SELECT B7Y_SECRET FROM "+RetSqlName("B7Y")
	cSql += " WHERE B7Y_FILIAL = '"+xFilial("B7Y")+"' "
	cSql += " AND B7Y_CODOPE = '"+PlsIntPad()+"' "
	cSql += " AND B7Y_CLIID = '"+self:ClientId+"' "
	cSql += " AND B7Y_STATUS = '1' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	PlsQuery(cSql, "TRB1")

	If TRB1->( Eof() )
		lRet := .F.
	Else
		If Alltrim(TRB1->B7Y_SECRET) !=  self:clientSecret
			lRet := .F.
		Endif		
	Endif

	TRB1->(dbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) class PMobSecCon
	self:oRequestModel := oRequestModel	
	self:SetBody(oRequestModel:oBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) class PMobSecCon
	self:oBody := oBody
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAuthParameters

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetAuthParameters() CLASS PMobSecCon

	Local lRet := .T.

	self:clientId 	  := self:oBody["clientId"]
	self:clientSecret := self:oBody["clientSecret"]

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetModel() CLASS PMobSecCon

	Local lRet := .T.

	If self:cModelEndPoint == "/mobileSaude/token"
		Aadd(self:aModel, "clientId")
		Aadd(self:aModel, "clientSecret")
	Else
		lRet := .F.	
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetTimeToExpireToken

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetTimeToExpireToken() class PMobSecCon

	Local ntimeToExpires := self:oSettings['security']['timeToExpires']
	Local dDate := Date()
	Local cHour := Time()
	Local sDate := ""
	Local cDateFormatter := ""
	Local aRet := {} 

	If Valtype(ntimeToExpires) == 'N' .and. ntimeToExpires > 0 
		SomaDiaHor(@dDate,@cHour,ntimeToExpires)
		sDate := dTos(dDate)
		cDateFormatter := Substr(sDate,1,4)+"-"+Substr(sDate,5,2)+"-"+Substr(sDate,7,2)+" "
		cDateFormatter += cHour+""+":00-3:00"
	Else
		// Token não expira neste caso
		cHour := ""
		sDate := ""
		cDateFormatter := ""
	Endif

	aRet := {cDateFormatter, dDate, cHour}

Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckToken

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method CheckToken(cToken) class PMobSecCon

	Local aRet := {}
	Local dDate := Date()
	Local cTime := Time()
	Local lStatus 	:= .T.
	Local nCode		:= 0
	Local cMessage	:= ""

	If ValType(cToken) == "U" .or. Empty(cToken)
		nCode := 403
		cMessage := "Não autorizado. Obrigatorio informar token de acesso no header da requisição."
		lStatus := .F.
	Else
		cSql := " SELECT * FROM "+RetSqlName("BJZ")+" WHERE BJZ_FILIAL = '"+xFilial("BJZ")+"' "
		cSql += " AND BJZ_CODOPE = '"+PlsIntPad()+"' " 
		cSql += " AND BJZ_TOKEN = '"+Alltrim(cToken)+"' "
		cSql += " AND BJZ_ATIVO = '1' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB1",.T.,.F.)

		If TRB1->( Eof() )
			nCode := 401
			cMessage := "1-Não autorizado."
			lStatus  := .F.
		Else
			If Stod(TRB1->BJZ_DTEXPI) < dDate
				lStatus := .F.
			Elseif Stod(TRB1->BJZ_DTEXPI) == dDate .and. TRB1->BJZ_HREXPI < cTime
				lStatus := .F.
			Endif

			If !lStatus 
				nCode := 401
				cMessage := "2-Não autorizado."

				BJZ->(dbGoto(TRB1->R_E_C_N_O_))
				If !BJZ->( Eof() )
					BJZ->( RecLock("BJZ", .F.) )
					BJZ->BJZ_ATIVO := '0'
					BJZ->BJZ_DATBLO := Date()
					BJZ->( MsUnlock() )
				Endif
			Endif
		Endif

		TRB1->( dbCloseArea() )
	Endif

	aRet := {lStatus, nCode, cMessage}

Return(aRet)