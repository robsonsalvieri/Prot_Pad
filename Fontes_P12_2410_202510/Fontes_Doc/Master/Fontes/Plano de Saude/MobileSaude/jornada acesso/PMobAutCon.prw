#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobAutCon

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Class PMobAutCon From PMobConfig

	// Propriedades de uso geral
	Data oRequestModel
	Data message

	Data oAuthModel
	Data cModelEndPoint

	// Login
	Data UserLogin
	Data UserPassword
	Data NewPassword

	// Lembrar senha
	Data dataNascimento

	// Criar usuário
	Data email

	Data aModel
	Data oBody
	Data UserMap
	Data oBeneficiario

	Method New() CONSTRUCTOR

	// Metodos obrigatorios do padrao definido
	Method GetModel()
	Method SetAuthParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)

	// Metodos de regras de negocio do serviço
	Method login()
	Method novoUsuario()
	Method reiniciarSenha()
	Method trocarSenha()

	Method CheckUser()
	Method CheckPassword()
	Method restartPass()
	Method CreatNewPass()
	Method SetNewPass()
	Method Create()
	Method SetLoginKeys()
	Method GetNewCod()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method New() Class PMobAutCon

	_Super:New() //Inicializa a classe herdada, responsável pelas configurações

	self:oAuthModel 		:= jSonObject():New()
	self:cModelEndPoint		:= nil
	self:oRequestModel 		:= nil
	self:message 			:= ""

	// Login
	self:UserLogin 			:= nil
	self:UserPassword		:= nil
	self:NewPassword		:= nil

	// Lembrar Senha
	self:dataNascimento		:= nil

	// Criar usuário
	self:email				:= nil

	self:aModel 			:= {}
	self:oBody			  	:= JsonObject():New()
	self:UserMap			:= JsonObject():New()
	self:oBeneficiario		:= nil
Return

/* Possíveis tipos de login
1   - Input exclusivo por matricula
	- BSW Exclusivo por matricula - ok
	- Se multicontrato
	- Descobrir o CPF
	- Chave do beneficiario é o CPF
	- Todas as demais requisições por CPF
	- Se não multicontrato
	- Chave do beneficiário é a própria matricula
	- Todas as demais requisições são fechadas na matriculas

2 - Input somente por CPF - ok
	- BSW exclusivo por CPF - ok
	- Multicontrato é obrigatório para login por CPF

3 - Input por CPF e matricula
	- BSW exclusivo por CPF - ok
	- Multicontrato é nativo neste caso
	- Se o imput for matricula
	- Descobrir o CPF
	- A chave do beneficiário é o CPF
	- Todas as demais requisições por CPF
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} login

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method login(lCreate) class PMobAutCon

	Default lCreate := .F.

	If !lCreate
		// DEFINE os parametros
		self:SetAuthParameters()

		// Verifica se o usuário existe
		If !self:CheckUser()
			self:oRequestModel:SetStatusResponse(.F.)
			self:oRequestModel:SetMessageResponse(self:message)

			Return(.F.)
		Endif

		// Confirma se a senha é valida
		If !self:CheckPassword()
			self:oRequestModel:SetStatusResponse(.F.)
			self:oRequestModel:SetMessageResponse(self:message)

			Return(.F.)
		Endif
	Endif

	// Se o perfil for beneficiário, Inicializa Beneficiários
	self:oBeneficiario := PMobBenef():New(self:UserMap)
	If !self:oBeneficiario:SetBeneficiaryMap()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oBeneficiario:GetMessage())
		Return(.F.)
	Endif

	// Beneficiario
	self:oRequestModel:SetDataResponse(self:oBeneficiario:GetContractMap())	// Contratos
	self:oRequestModel:SetDataResponse(self:oBeneficiario:GetBeneficiary()) 	// Beneficiários
	self:oRequestModel:SetDataResponse(self:oBeneficiario:GetUserLoggedMap()) // Usuário logado
	//self:oRequestModel:SetDataResponse(self:oBeneficiario:GetUserLoggedMap()) // Usuário logado

	// Adiciona o login ao cache. O método SetLoginToCache depende do parametro ['login']['useCache'] do configurador
	self:oBeneficiario:SetLoginToCache(self:oRequestModel:SetResponse())

Return(.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} trocarSenha

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method trocarSenha() class PMobAutCon

	// DEFINE os parametros
	self:SetAuthParameters()

	// Verifica se o usuário existe
	If !self:CheckUser()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)

		Return(.F.)
	Endif

	If !self:CheckPassword()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)
		Return(.F.)
	Endif

	// Grava a nova senha
	self:SetNewPass(self:NewPassword)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} reiniciarSenha

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method reiniciarSenha() class PMobAutCon

	// DEFINE os parametros
	self:SetAuthParameters()

	// Verifica se o usuário existe
	If !self:CheckUser()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)

		Return(.F.)
	Endif

	// Verifica informacoes adicionais solicitadas na criação do usuário
	If !self:restartPass()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)

		Return(.F.)
	Endif

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} novoUsuario

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method novoUsuario() class PMobAutCon

	// DEFINE os parametros
	self:SetAuthParameters()

	// Verifica se o usuário existe - se existir, retorna.
	If self:CheckUser()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)

		Return(.F.)
	Endif

	// Se o perfil for beneficiário, Inicializa Beneficiários
	self:oBeneficiario := PMobBenef():New(self:UserMap)
	If !self:oBeneficiario:CheckBeneficiaryExists(.T.)		// lOnlyConfirms = .T., apenas para confirmar se o usuário existe.
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oBeneficiario:GetMessage())
		Return(.F.)
	Endif

	// Se chegou até aqui, cria o usuário
	If !self:Create()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)

		Return(.F.)
	Endif

	// Chama a autenticação para retornar o mesmo payload de login
	If !self:login(.T.)
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:message)
	Endif

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} restartPass

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method restartPass() class PMobAutCon
	
	Local lRet := .T.
	Local cSql := ""

	If StrTran(self:dataNascimento, '-', '') != dTos(self:UserMap['dataNascimento']) .Or. ;
		Upper(self:email) != Upper(self:UserMap['email'])
		
		lRet := .F.
		self:message := "Os dados informados não correspondem a um usuário ativo"
	Else
		cSql := " UPDATE "+RetSqlName("BSW")+" SET BSW_SENHA = '" +self:UserPassWord+"' "
		cSql += " WHERE R_E_C_N_O_ = "+cValToChar(self:UserMap['id'])
		TcSqlExec(cSql)
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckUser

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method CheckUser() class PMobAutCon

	Local lRet := .T.
	Local cSql := ""
	Local lAddMap := .T.
	Local cUserLogin 	:= ""
	Local dDatNasc		:= cTod("")
	Local cEmail		:= ""
	Local nRecno		:= 0
	Local cSenha		:= ""
	Local nIndBA1       := 0

	aKeys := self:SetLoginKeys()
	If !aKeys[1]
		Return .F.
	Endif

	cSql := " SELECT * FROM "+RetSqlName("BSW")+" WHERE BSW_FILIAL = '"+xFilial("BSW")+"' "
	cSql += " AND BSW_LOGUSR = '"+self:UserLogin+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB1",.T.,.F.)

	If TRB1->( Eof() )
		lRet := .F.
	Endif

	If lRet
		If lower(self:cModelEndPoint) == lower("/mobileSaude/novoUsuario")		// É primeiro acesso e o usuário já existe, retorna falso e não prossegue
			self:message := "O usuário já existe. Utilize a opção Reiniciar Senha."
			lAddMap := .F.

		Else				// Qualquer outro método e o usuário existe. Então retorna OK
			lAddMap 	:= .T.
			cEmail		:= TRB1->BSW_EMAIL
			nRecno		:= TRB1->R_E_C_N_O_
			cSenha		:= Alltrim(TRB1->BSW_SENHA)
			cUserLogin	:= Alltrim(TRB1->BSW_LOGUSR)

			//BSW_LOGUSR com tamanho 17 busca por Matric, no outro caso, por CPF
			nIndBA1     := iif(len(Alltrim(TRB1->BSW_LOGUSR)) == 17,2,4)
			BA1->(DbSetOrder(nIndBA1))
			if BA1->(DbSeek(xFilial("BA1")+Alltrim(TRB1->BSW_LOGUSR)))   //dDatNasc := Stod(TRB1->BSW_DTNASC)
				dDatNasc := BA1->BA1_DATNAS
			endIf
		Endif

	Elseif !lRet .and. lower(self:cModelEndPoint) == lower("/mobileSaude/novoUsuario")	// É primeiro acesso e o usuário não existe, então prossegue
		lAddMap 	:= .T.
		dDatNasc 	:= self:dataNascimento
		cEmail		:= self:email
		nRecno		:= 0
		cSenha		:= self:UserPassword
		cUserLogin	:= self:UserLogin

	Else
		lAddMap	:= .F.	// Qualquer outro caso, não prossegue.
		self:message := "Usuário não encontrado"

	Endif

	If lAddMap
		self:UserMap['dataNascimento'] 	:= dDatNasc
		self:UserMap['email'] 			:= Alltrim(cEmail)
		self:UserMap['id']				:= nRecno
		self:UserMap['senha'] 			:= cSenha
		self:userMap['login']			:= aKeys[2]
	Endif

	TRB1->(dbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckPassword

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method CheckPassword() class PMobAutCon

	Local I		:= 0
	Local cCar		:= ""
	Local cTexto 	:= ""
	Local cSenhaPLS	:= ""
	Local lReturn := .T.

	If Len(self:userMap['senha']) <= 18
		// Senha Antiga: aplica algoritimo legado para descriptografar a senha
		For I := 1 To Len(cText) Step 3
			cCar := SubStr(cText, I, 3)
			cTexto += ( Chr(  ( Val(cCar)/3 )-1 ) )
		Next

		cSenhaPLS := Md5(cTexto)
	Else
		// Neste caso a senha já é um MD5
		cSenhaPLS := Alltrim(self:userMap['senha'])
	Endif


	lReturn := self:UserPassWord==cSenhaPLS

	If !lReturn
		self:message := "Senha Inválida"
	Endif

Return(lReturn)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetRequestModel(oRequestModel) class PMobAutCon
	self:oRequestModel := oRequestModel
	self:SetBody(oRequestModel:oBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetBody(oBody) class PMobAutCon
	self:oBody := oBody
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAuthParameters

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetAuthParameters() CLASS PMobAutCon

	If lower(self:cModelEndPoint) == lower("/mobileSaude/login")
		self:UserLogin 			:= self:oBody["login"]
		self:UserPassword		:= Md5(self:oBody["senha"])

	Elseif lower(self:cModelEndPoint) == lower("/mobileSaude/reiniciarSenha")
		self:UserLogin 			:= self:oBody["login"]
		self:dataNascimento		:= self:oBody["dataNascimento"]
		self:email				:= self:oBody["email"]
		self:UserPassword		:= Md5(self:oBody["senha"])
		
	Elseif lower(self:cModelEndPoint) == lower("/mobileSaude/trocarSenha")
		self:UserLogin 			:= self:oBody["login"]
		self:UserPassword		:= Md5(self:oBody["senhaAtual"])
		self:NewPassword		:= self:oBody["novaSenha"]

	Elseif lower(self:cModelEndPoint) == lower("/mobileSaude/novoUsuario")
		self:UserLogin 			:= self:oBody["login"]
		self:UserPassword		:= self:oBody["senha"]
		self:dataNascimento		:= self:oBody["dataNascimento"]
		self:email				:= self:oBody["email"]

	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method GetModel() CLASS PMobAutCon

	Local lRet := .T.

	Do Case

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/login")
			Aadd(self:aModel, "login")
			Aadd(self:aModel, "senha")

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/reiniciarSenha")
			Aadd(self:aModel, "login")
			Aadd(self:aModel, "dataNascimento")
			Aadd(self:aModel, "senha")
			Aadd(self:aModel, "email")

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/trocarSenha")
			Aadd(self:aModel, "login")
			Aadd(self:aModel, "senhaAtual")
			Aadd(self:aModel, "novaSenha")

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/novoUsuario")
			Aadd(self:aModel, "login")
			Aadd(self:aModel, "dataNascimento")
			Aadd(self:aModel, "senha")
			Aadd(self:aModel, "email")

		Otherwise
			lRet := .F.
	EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CreatNewPass

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method CreatNewPass() CLASS PMobAutCon

	Local cRandon := ""

	While .T.
		cRandon += Alltrim(Str(randomize(0,9)))

		If Len(Alltrim(cRandon)) >= 6
			Exit
		Endif
	Enddo

	If !Empty(cRandon) .and. Len(cRandon) >= 6
		self:SetNewPass(cRandon)

	Endif

Return cRandon


//-------------------------------------------------------------------
/*/{Protheus.doc} SetNewPass

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetNewPass(cSenha) CLASS PMobAutCon

	Local cSql := ""

	cSql := " UPDATE "+RetSqlName("BSW")+" SET BSW_SENHA = '" + md5(cSenha)+"' "
	cSql += " WHERE R_E_C_N_O_ = "+cValToChar(self:UserMap['id'])
	TcSqlExec(cSql)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Create

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method Create() CLASS PMobAutCon

	Local lRet    := .T.
	Local cCodigo := self:GetNewCod()
	Local cAcesso := self:oSettings['login']['accessPortal']
	Local cPerfil := self:oSettings['login']['accessPerfil']
	Local nCnt    := 0

	Begin Transaction

		BSW->( RecLock("BSW", .T.) )
		BSW->BSW_FILIAL := xFilial("BSW")
		BSW->BSW_CODUSR	:= cCodigo
		BSW->BSW_LOGUSR := self:UserLogin
		BSW->BSW_NOMUSR := Alltrim(self:oBeneficiario:aSitContract[1][7])

		// Se já existir, apenas atualiza.
		BSW->BSW_SENHA	:= Md5(self:UserPassword)
		BSW->BSW_EMAIL	:= self:email
		BSW->BSW_CODACE	:= cAcesso
		BSW->BSW_PERACE := cPerfil
		BSW->BSW_TIPCAR	:= "0"
		BSW->BSW_BIOMET	:= ""
		BSW->BSW_TPPOR	:= "3"
		BSW->BSW_DTSEN  := dDataBase
		BSW->( MsUnlock() )

		// Vou jogar no B49 as matriculas de todos os contratos do usuário. Isso aqui será apenas ilustrativo porque a nova API nao utiliza o B49 pra nada.
		for nCnt := 1 to len(self:oBeneficiario:aSitContract)
			B49->( RecLock("B49", .T.) )
			B49->B49_FILIAL := xFilial("B49")
			B49->B49_CODUSR := BSW->BSW_CODUSR
			B49->B49_BENEFI := self:oBeneficiario:aSitContract[nCnt][1] + self:oBeneficiario:aSitContract[nCnt][9] + self:oBeneficiario:aSitContract[nCnt][10]
			B49->( MsUnlock() )
		next

		// Ponto de entrada para manipular a gravacao da BSW/B49
		if ExistBlock("PMOBBE01")
			ExecBlock("PMOBBE01", .F., .F., {cCodigo})
		endIf

	End Transaction

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetLoginKeys

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetLoginKeys() CLASS PMobAutCon

	Local oMap := jSonObject():New()
	Local lRet := .T.

	oMap['userLogin'] 	  := self:userLogin
	oMap['BswKey'] 		  := self:oSettings['login']['loginBswKey']
	oMap['InputKey'] 	  := self:oSettings['login']['loginBswKey']
	oMap['multiContract'] := self:oSettings['login']['multiContract']

	oMap['chaveBeneficiario'] 	  := self:userLogin
	oMap['chaveBeneficiarioTipo'] := self:oSettings['login']['loginBswKey']

	If self:oSettings['login']['loginBswKey'] == 'MAT' // Login exclusivo por matricual
		If self:oSettings['login']['multiContract']	// Porem é multicontrato, significa que tenho que descobrir o CPF pois todas as demais requisições serão por PCF
			cCpf := PMobCpfMat(self:userLogin)	// Decobre o CPF a partir da matricula do usuário

			If Empty(cCpf)
				oMap['multiContract'] := .F.		// Se o CPF não for encontrado torna-se inviável o uso do multicontrato, por isso desligo ele aqui
			Else
				oMap['chaveBeneficiario'] 	  := cCpf		// Se o CPF for Localizado, ele se torna a achar para as demais requisições
				oMap['chaveBeneficiarioTipo'] := 'CPF'
			Endif
		Endif

	Elseif self:oSettings['login']['loginBswKey'] == 'CPF'	// Login é por CPF
		cCpf := self:userLogin
		If Len(self:userLogin) > 11 // Porem o imput foi por matricula, então vou precisar descobrir o CPF
			cCpf := PMobCpfMat(self:userLogin)	// Decobre o CPF a partir da matricula do usuário

			If Empty(cCpf)
				// Neste caso, se não for possível Localizar um CPF, o sistema vai dar erro.
				lRet := .F.
				self:message := "não existe um CPF vinculado a este usuário"
			Else
				// Se o CPF for Localizado, atribui ele como login e segue a vida
				self:userLogin	 := cCpf
				oMap['InputKey'] := 'MAT'
			Endif
		Endif

		oMap['chaveBeneficiario'] := cCpf
	Endif

Return({lRet, oMap})


//-------------------------------------------------------------------
/*/{Protheus.doc} GetNewCod

@author  Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method GetNewCod() CLASS PMobAutCon

	Local cCodigo := ''
	Local cSql    := ''

	cSql := " SELECT MAX(BSW_CODUSR) AS COD "
	cSql += " FROM "+RetsqlName("BSW")
	cSql += " WHERE BSW_FILIAL = '" +xFilial("BSW")+ "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),"TEMP",.F.,.T.)

	if !TEMP->(Eof())
		cCodigo := Soma1(alltrim(TEMP->COD))
	else
		cCodigo := Strzero(1,TamSx3("BSW_CODUSR")[1])
	endIf
	TEMP->( dbcloseArea() )

Return cCodigo
