#INCLUDE 'totvs.ch'
#DEFINE cEnt Chr(13)+Chr(10)
#DEFINE IntegMapUser 1
#DEFINE IntegMapBeneficiary 2

CLASS PMobBenef FROM PMobConfig

	// Objetos referente ao modelo de entrada
	Data oUserMap

	// Tratamento do cache
	Data oLoginCache

	// Propriedades para uso geral
	Data loginMap
	Data chaveBeneficiario
	Data lMultiContract
	Data lLoginByCPF

	//  Response PayLoad properties 
	Data oContracts
	Data oBeneficiary 
	Data oContractMap
	Data oGraceMap
	Data oIntegrationMap
	Data oUserLoggedMap
	Data oPermissionsMap

	Data oTitularMap 

	Data message

	Data cTitular 		 		
	Data cConjuge 				
	Data lUseCache 			
	Data aSitContract 

	// Constructor
	Method New() CONSTRUCTOR

	// Sobre o beneficiário 
	Method CheckBeneficiaryExists()
	Method SetBeneficiaryMap()
	Method GetBeneficiaryMap()

	// Sobre os contratos 
	Method SetContractMap()
	Method GetContractMap()

	// Sobre as carencias 
	Method SetGraceMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCodPla, cVerPla, dDatCar, cSexo)
	Method GetGraceMap()

	// Sobre o mapa de integração
	Method SetIntegrationMap()
	Method GetIntegrationMap()

	// Sobre os dados do usuário logafdo
	Method SetUserLoggedMap()
	Method GetUserLoggedMap()

	// Sobre as permissoes de acesso de cada contrato 
	Method SetPermissionsMap()
	Method GetPermissionsMap()

	// Sobre as mensagens de retorno 
	Method GetMessage()

	// Tratamento de cache
	Method CheckLoginCache()
	Method SetLoginToCache()
	Method GetLoginFROMCache()

	// Sobre os dados do titular de cada contrato
	Method SetTitularMap()
	Method GetTitularMap()

	// Sobre o perfil do usuário 
	Method SetUserProfile()
	Method GetUserProfile()

	// Sobre as informacoes complementares do contrato
	Method GetContactInfo()

	// Sobre os dados de endereço do beneficiário 
	Method GetAddressInfo()

	// Validacoes gerais
	Method IsUserLoggedIn()
	Method IsValidUser()
	Method IsTitular(cTipUsr)

	Method GetCustomer()
	Method GetFamily()
	Method GetProduct()	
	Method GetLocator()  
	Method retDadMask(xItem,cTipo)
	Method gerQryBenef()
	Method retPhone(cDDD,cPhone)
	Method removeDot(cExp)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New

Construtor da classe
@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method New(oUserMap) CLASS PMobBenef
	// Inicializa a classe herdada, responsável pelo modelo de dados do retorno 
	_Super:New()

	// Objetos referentes ao modelo de retorno	
	self:oContractMap 	:= jSonObject():New()
	self:oBeneficiary 	:= jSonObject():New()
	self:oGraceMap		:= jSonObject():New()
	self:oIntegrationMap:= jSonObject():New()
	self:oUserLoggedMap := jSonObject():New()
	self:oPermissionsMap:= jSonObject():New()

	self:oTitularMap 		:= jSonObject():New()

	// Tratamento do cache
	self:oLoginCache	:= jSonObject():New()

	self:message		:= ""
	self:oContractMap['contratos'] := {}
	self:oBeneficiary['beneficiarios'] := {}

	// Objetos referente ao modelo de entrada.
	self:loginMap	:= oUserMap['login']

	self:lUseCache 	  := self:oSettings['login']['useCache']
	self:cTitular 	  := self:oSettings['beneficiary']['typeUsrTitular'] 		
	self:cConjuge 	  := self:oSettings['beneficiary']['typeUsrConjuge']
	self:aSitContract := {}

	// Assinala 
	self:lMultiContract 	:= self:loginMap['multiContract']
	self:lLoginByCPF		:= self:loginMap['chaveBeneficiarioTipo']=='CPF'
	self:chaveBeneficiario	:= self:loginMap['chaveBeneficiario']

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckBeneficiaryExists

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method CheckBeneficiaryExists(lOnlyConfirms) Class PMobBenef

	Local lRet := .T.
	Local lLogged := .F.	
	Local cSql := ""	
	Local oMatric	:= nil
	Default lOnlyConfirms := .F.

	cSql := " SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO, BA1.BA1_DATNAS, BA1.BA1_NOMUSR, BA1_EMAIL, BA1_TIPREG, BA1_DIGITO, "
	cSql += " BA1.BA1_CPFUSR, BA1_TIPUSU, BA1.BA1_GRAUPA, BA1.BA1_MATVID, BA1_DATBLO, BA1_MOTBLO, BA1_CONSID, "
	cSql += " BG3.BG3_LOGIN, BG3.BG3_BLQCAR, BG1.BG1_LOGIN, BG1.BG1_BLQCAR "
	cSql += " FROM "+RetSqlName("BA1")+" BA1 "
	cSql += "	LEFT JOIN "+RetSqlName("BG3")+" BG3 ON BG3.BG3_FILIAL = '"+xFilial("BG3")+"' "
	cSql += "		AND BG3.BG3_CODBLO = BA1.BA1_MOTBLO
	cSql += "		AND BG3.D_E_L_E_T_ = ' ' "
	cSql += "	LEFT JOIN "+RetSqlName("BG1")+" BG1 ON BG1.BG1_FILIAL = '"+xFilial("BG1")+"' "
	cSql += "		AND BG1.BG1_CODBLO = BA1.BA1_MOTBLO
	cSql += "		AND BG1.D_E_L_E_T_ = ' ' "	
	cSql += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "

	If self:lLoginByCPF .or. self:lMultiContract 
		cSql += " AND BA1.BA1_CPFUSR = '"+self:chaveBeneficiario+"' "

	Else
		oMatric := PMobSplMat(self:chaveBeneficiario)
		cSql += " AND BA1.BA1_CODINT = '"+oMatric['codInt']+"' "
		cSql += " AND BA1.BA1_CODEMP = '"+oMatric['codEmp']+"' "
		cSql += " AND BA1.BA1_MATRIC = '"+oMatric['matric']+"' "
		cSql += " AND BA1.BA1_TIPREG = '"+oMatric['tipReg']+"' "
		cSql += " AND BA1.BA1_DIGITO = '"+oMatric['digito']+"' "
	Endif

	cSql += " AND BA1.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRB1",.F.,.T.)

	If TRB1->(Eof())
		self:message := "Não existe beneficiário ativo o usuário informado. Entre em contato!"
		TRB1->( dbCloseArea() )

		Return .F.
	Endif

	// Apura a situação do usuário em cada familia 
	While !TRB1->(Eof())

		// Tratamento do bloquei0
		If !self:IsValidUser(TRB1->BA1_DATBLO, TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
		TRB1->BA1_CPFUSR,;
		Iif(TRB1->BA1_CONSID=='U', TRB1->BG3_LOGIN, TRB1->BG1_LOGIN),;
		Iif(TRB1->BA1_CONSID=='U', TRB1->BG3_BLQCAR, TRB1->BG1_BLQCAR))

			TRB1->( dbSkip() )
			Loop
		Endif		

		// Registra o usuário logado
		If !lLogged 
			self:SetUserLoggedMap(TRB1->BA1_CODINT, TRB1->BA1_CODEMP, TRB1->BA1_MATRIC, TRB1->BA1_TIPREG,;
			 					  TRB1->BA1_DIGITO, TRB1->BA1_CPFUSR, TRB1->BA1_MATVID, self:chaveBeneficiario, NIL, TRB1->BA1_TIPUSU)
			lLogged := .T.
		Endif

		Aadd(self:aSitContract, {TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),;	// 1
		TRB1->BA1_CPFUSR,;	// 2
		TRB1->BA1_TIPUSU,;	// 3
		TRB1->BA1_GRAUPA,;	// 4
		Stod(TRB1->BA1_DATBLO),;	// 5
		Stod(TRB1->BA1_DATNAS),;	// 6
		TRB1->BA1_NOMUSR,;	// 7
		TRB1->BA1_EMAIL,;	// 8
		TRB1->BA1_TIPREG,;	// 9
		TRB1->BA1_DIGITO})	// 10

		// Se o login for matricula não for Multi-contratro, não deve existir mais de um registro vinculado ao usuário logado. Este ponto garante a integridade dessa regra de negocio.
		If !self:lLoginByCPF .and. !self:lMultiContract 
			Exit
		Endif

		TRB1->(dbSkip())			
	Enddo

	If Len(self:aSitContract) == 0 
		self:message := "Não existe beneficiário ativo o usuário informado. Entre em contato!"

		TRB1->( dbCloseArea() )	
		Return .F.
	Endif

	TRB1->( dbCloseArea() )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IsValidUser

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method IsValidUser(dDatBlo, cMatric, cCpf, cBlqUserAction, cBlqFamilyAction) Class PMobBenef
	Local lRet := .T.

	if ValType(dDatBlo) == "C"
		dDatBlo := Stod(dDatBlo)
	endIf

	// Tratamento dos bloqueados
	If !Empty(dDatBlo) .AND. (dDatBlo < dDataBase)	// Está bloqueado ?
		If self:IsUserLoggedIn(cMatric, cCpf)	// Eh o cara que fez o login 
			If cBlqUserAction == '2' // Ele pode fazer o login ? 
				lRet := .F. // Não pode 
			Endif			
		Else // Nao, eh do grupo familiar
			If cBlqFamilyAction == '1' // O motivo permite visualizar o cartao 
				lRet := .F. // Não pode 				
			Endif			
		Endif 
	Endif

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} IsUserLoggedIn

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method IsUserLoggedIn(cMatric,cCpf) Class PMobBenef
	Local lRet := .F. 

	If self:lLoginByCpf .and. (self:chaveBeneficiario == cCpf)
		lRet := .T.

	Elseif !self:lLoginByCpf .and. (self:chaveBeneficiario == cMatric)
		lRet := .T.

	Endif 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBeneficiaryMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetBeneficiaryMap() Class PMobBenef

	Local cSql   := ""
	Local cAlias := ""
	Local nLen   := 0
	Local lTitular   := .F.
	Local lConjuge   := .F.
	Local aRetPhone  := {}
	Local cTelefone  := ''
	Local cCelular   := ''
	Local cLayCarVir := ''
	Local cCodAco := ''
	Local cCodPadSau := ''
	Local aRetTok    := {.F.,""}
	Local nSeedTp    := GetNewPar("MV_PLSTKST", 1)      //Token Seed Type 1=Text; 2=Base64; 3=Hex
	Local nSHAxTk    := GetNewPar("MV_PLSTKSH", 5)      //Token SHA Function 3=SHA-1; 5=SHA-256; 7=SHA-512
	Local nDigits    := GetNewPar("MV_PLSTKDG", 6)      //Token Number of Digits
	Local nX         := GetNewPar("MV_PLSTKTS", 30*60)  //Token Time Step
	Local lLogUser   := .T.
	Local lFieldTok  := BA1->(fieldPos("BA1_TKSEED")) > 0 
	Local lPMOBBE02  := ExistBlock("PMOBBE02")
	Local lPMOBBE03  := ExistBlock("PMOBBE03")
	Local lPMOBBE04  := Existblock("PMOBBE04")
	Local lPMOBBE07  := Existblock("PMOBBE07")
	Local lFreeBA1 := .T.

	BI4->(DbSetOrder(1))
	BN5->(DbSetOrder(1))
	BI6->(DbSetOrder(1))
	BA1->(DbSetOrder(2))

	// Verifica se o usuário existe no cahce. Se existir, busca de lá pra ganhar performance 	
	If self:lUseCache .and. self:CheckLoginCache()
		self:GetLoginFROMCache()
		Return .T.
	Endif

	If !self:CheckBeneficiaryExists()
		Return .F.		
	Endif

	cSql := self:gerQryBenef()
	
	PlsQuery(cSql, "TRB1")

	If TRB1->(Eof())
		self:message := "Não existe beneficiários ativos o usuário informado. Entre em contato!"
		TRB1->( dbCloseArea() )

		Return .F.

	ElseIf BA1->(MsSeek(xFilial("BA1")+TRB1->(MATRICULA)))    
		
		lFreeBA1 := BA1->(MsRLock())
		if !lFreeBA1
			self:message := "Por favor, tente novamente mais tarde!"
			TRB1->( dbCloseArea() )
			
			Return .F.
		Endif
	Endif

	While !TRB1->( Eof() )
		cContract := TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

		// Localiza a configuração do contrato
		If (nPos := Ascan(self:aSitContract, {|x| x[1] == cContract})) == 0
			TRB1->( dbSkip() )
			Loop
		Endif					
		lTitular := (self:aSitContract[nPos][3] == self:cTitular)
		lConjuge := (self:aSitContract[nPos][4] == self:cConjuge)

		// DEFINE o mapa do titular			
		self:SetTitularMap(TRB1->BA1_CODINT, TRB1->BA1_CODEMP, TRB1->BA1_MATRIC)

		// Multi-contratos: incrementa um novo contrato na estrutura de retorno
		self:SetContractMap(TRB1->BA1_CODINT, TRB1->BA1_CODEMP, TRB1->BA1_MATRIC,;
		TRB1->BA3_TIPOUS,;
		TRB1->BA3_COBNIV,;
		TRB1->BQC_NREDUZ,;
		TRB1->BA1_GRAUPA,;
		TRB1->BA1_DATBLO,;
		TRB1->BA1_MOTBLO)

		// Trata os contratos
		While !TRB1->( Eof() ) .and. cContract == TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
			// DEFINE quem entra e quem não entra no payload de retorno, conforme regra abaixo:
			// Se o login é titular, entra todos da familia 
			// Se for um dependente conjuge, entra todos os demais dependentes e não entra o titular 
			// Se for outro tipo de dependente ou outro tipo de usuário, só entra ele mesmo
			
			//Se lTitular, nada faz: entra todos os usuários 
			if !lTitular .and. lConjuge
				// Entra todos os dependentes dispensa o titular  
				if TRB1->BA1_TIPUSU == self:cTitular 
					TRB1->( dbSkip() )
					Loop
				endIf
				
			elseIf !lTitular .and. !lConjuge
				// Entra apenas o proprio 
				if TRB1->BA1_CPFUSR == TRB1->CPFUSR_TITULAR
					TRB1->( dbSkip())
					Loop
				endIf
			endIf

			// Tratamento do bloqueio
			If !self:IsValidUser(TRB1->BA1_DATBLO,;
				TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
				TRB1->BA1_CPFUSR,;
				Iif(TRB1->BA1_CONSID=='U', TRB1->BG3_LOGIN, TRB1->BG1_LOGIN),;
				Iif(TRB1->BA1_CONSID=='U', TRB1->BG3_BLQCAR, TRB1->BG1_BLQCAR))

				TRB1->( dbSkip() )
				Loop
			Endif

			// So traz o usuario que logou
			if !lTitular .and. !lConjuge .And. !self:IsUserLoggedIn(TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), TRB1->BA1_CPFUSR)
				TRB1->( dbSkip() )
				Loop
			endIf

			BA3->(DbGoTo(TRB1->RECNOBA3 ))


			// Prepara o objeto para receber a lista de beneficiários 
			Aadd(self:oBeneficiary['beneficiarios'], jSonObject():New())
			nLen := Len(self:oBeneficiary['beneficiarios'])

			// Identifica onde o plano está configurado: familia ou usuário
			cAlias := iif(!Empty(TRB1->BA1_CODPLA),"BA1","BA3") 
		
			// Dados do titular 
			self:oBeneficiary['beneficiarios'][nLen]["matriculaTitular"]			:= self:oTitularMap['matriculaTitular'] 
			self:oBeneficiary['beneficiarios'][nLen]["nomeTitular"]					:= self:oTitularMap['nomeTitular'] 
			self:oBeneficiary['beneficiarios'][nLen]["emailTitular"]				:= self:oTitularMap['emailTitular']			
			self:oBeneficiary['beneficiarios'][nLen]["telefoneTitular"]				:= self:oTitularMap['telefoneTitular']
			self:oBeneficiary['beneficiarios'][nLen]["celularTitular"]				:= self:oTitularMap['celularTitular']
			self:oBeneficiary['beneficiarios'][nLen]["cpfTitular"]					:= self:oTitularMap['cpfTitular']

			// Dados do beneficiario
			self:oBeneficiary['beneficiarios'][nLen]["matricula"]					:= self:retDadMask(TRB1->MATRICULA)
			self:oBeneficiary['beneficiarios'][nLen]["matriculaAntiga"]				:= self:retDadMask(TRB1->BA1_MATANT)
			self:oBeneficiary['beneficiarios'][nLen]["matriculaFuncionario"]		:= self:retDadMask(TRB1->BA1_MATEMP)
			self:oBeneficiary['beneficiarios'][nLen]["nome"]						:= self:retDadMask(TRB1->BA1_NOMUSR)
			self:oBeneficiary['beneficiarios'][nLen]["sexo"]						:= self:retDadMask(TRB1->BA1_SEXO)
			self:oBeneficiary['beneficiarios'][nLen]["dataNascimento"]				:= self:retDadMask(TRB1->BA1_DATNAS,"D")
			self:oBeneficiary['beneficiarios'][nLen]["cpf"]							:= self:retDadMask(TRB1->BA1_CPFUSR)

			// Dados do contato 
			aRetPhone := self:retPhone(TRB1->BA1_DDD,TRB1->BA1_TELEFO)
			cTelefone := aRetPhone[1]
			cCelular  := aRetPhone[2]

			self:oBeneficiary['beneficiarios'][nLen]["celular"]						:= self:GetContactInfo('celular','celularTitular',cCelular, "")					
			self:oBeneficiary['beneficiarios'][nLen]["telefone"]					:= self:GetContactInfo('telefone','telefoneTitular',cTelefone, "")
			self:oBeneficiary['beneficiarios'][nLen]["email"]						:= self:GetContactInfo('email','emailTitular',self:retDadMask(TRB1->BA1_EMAIL), "")

			// Dados do endereço
			self:oBeneficiary['beneficiarios'][nLen]["endereco"]					:= self:GetAddressInfo('endereco', 'endereco', self:retDadMask(TRB1->BA1_ENDERE))
			self:oBeneficiary['beneficiarios'][nLen]["bairro"]						:= self:GetAddressInfo('bairro'  , 'bairro'  , self:retDadMask(TRB1->BA1_BAIRRO))
			self:oBeneficiary['beneficiarios'][nLen]["cep"]							:= self:GetAddressInfo('cep'     , 'cep'     , self:retDadMask(TRB1->BA1_CEPUSR))
			self:oBeneficiary['beneficiarios'][nLen]["cidade"]						:= self:GetAddressInfo('cidade'  , 'cidade'  , self:retDadMask(TRB1->BA1_MUNICI))
			self:oBeneficiary['beneficiarios'][nLen]["estado"]						:= self:GetAddressInfo('estado'  , 'estado'  , self:retDadMask(TRB1->BA1_ESTADO))

			// Dados sobre dependencia 
			self:oBeneficiary['beneficiarios'][nLen]["tipoUsuario"]					:= self:retDadMask(TRB1->BA1_TIPUSU)					
			self:oBeneficiary['beneficiarios'][nLen]["grauParentescoId"]			:= self:retDadMask(TRB1->BA1_GRAUPA)
			self:oBeneficiary['beneficiarios'][nLen]["grauParentescoDescricao"]		:= self:retDadMask(TRB1->BRP_DESCRI)

			// Dados do plano 
			self:oBeneficiary['beneficiarios'][nLen]["convenioId"]					:= self:retDadMask(TRB1->&(cAlias+"_CODPLA"))
			self:oBeneficiary['beneficiarios'][nLen]["convenioDescricao"]			:= self:retDadMask(TRB1->&(cAlias+"_DESPLA"))
			self:oBeneficiary['beneficiarios'][nLen]["convenioAbrangencia"]			:= self:retDadMask(TRB1->&(cAlias+"_DESABR"))

			cCodAco := IIF(!Empty(TRB1->BA1_CODPLA), TRB1->BA1CODACO, TRB1->BA3CODACO)
			cCodPadSau := IIF(!Empty(TRB1->BA1_CODPLA), TRB1->BA1PADSAU, TRB1->BA3PADSAU)
			
			If(BI4->(DbSeek(xFilial("BI4")+cCodAco)))
				self:oBeneficiary['beneficiarios'][nLen]["convenioAcomodacao"]			:= self:retDadMask(BI4->BI4_DESCRI)
			Endif
			If(BN5->(DbSeek(xFilial("BN5")+TRB1->(BA1_CODINT+cCodPadSau))))
				self:oBeneficiary['beneficiarios'][nLen]["convenioPadraoConforto"]		:= self:retDadMask(BN5->BN5_DESCRI)
			Endif
			If(BI6->(DbSeek(xFilial("BI6")+TRB1->(BI3_CODSEG))))
				self:oBeneficiary['beneficiarios'][nLen]["convenioSegmentacao"]			:= self:retDadMask(BI6->BI6_DESCRI)
			Endif
			self:oBeneficiary['beneficiarios'][nLen]["convenioModalidadeCobranca"]	:= self:retDadMask(TRB1->&(cAlias+"_MODPAG"))
			self:oBeneficiary['beneficiarios'][nLen]["convenioRegulamentacao"]		:= self:retDadMask(TRB1->&(cAlias+"_REGULAMENTACAO"))
			self:oBeneficiary['beneficiarios'][nLen]["convenioTipoPessoa"]			:= self:retDadMask(TRB1->BA3_TIPPES)
			If(BII->(DbSeek(xFilial("BII")+TRB1->(BA3_TIPOUS))))
				self:oBeneficiary['beneficiarios'][nLen]["convenioTipoContrato"]		:= self:retDadMask(BII->BII_DESCRI)
			Endif					
			self:oBeneficiary['beneficiarios'][nLen]["convenioAns"]					:= self:retDadMask(TRB1->BA1_CONVANS)
			self:oBeneficiary['beneficiarios'][nLen]["convenioParticipativo"]		:= Iif(Alltrim(TRB1->&(cAlias+"_COPART")) == '1', .T., .F.)
			self:oBeneficiary['beneficiarios'][nLen]["convenioAbrangenciaVerso"]	:= ""

			// Dados do cartão 
			self:oBeneficiary['beneficiarios'][nLen]["cartaoValidade"]				:= self:retDadMask(TRB1->BA1_DTVLCR,"D")
			self:oBeneficiary['beneficiarios'][nLen]["cartaoVia"]					:= self:retDadMask(TRB1->BA1_VIACAR,"N")
			self:oBeneficiary['beneficiarios'][nLen]["numeroCns"]					:= self:retDadMask(TRB1->BA1_CNS)
			
			cLayCarVir := "" 		

			Do Case 	
				Case !Empty(TRB1->BA1_LCVIRT)
					cLayCarVir := TRB1->BA1_LCVIRT

				Case !Empty(TRB1->BA3_LCVIRT)
					cLayCarVir := TRB1->BA3_LCVIRT

				Case !Empty(TRB1->BT6_BA1_LCVIRT)
					cLayCarVir := TRB1->BT6_BA1_LCVIRT

				Case !Empty(TRB1->BT6_BA3_LCVIRT)
					cLayCarVir := TRB1->BT6_BA3_LCVIRT

				Case !Empty(TRB1->BQC_LCVIRT)
					cLayCarVir := TRB1->BQC_LCVIRT

				Case !Empty(TRB1->BI3_BA1_LCVIRT)
					cLayCarVir := TRB1->BI3_BA1_LCVIRT

				Case !Empty(TRB1->BI3_BA3_LCVIRT)
					cLayCarVir := TRB1->BI3_BA3_LCVIRT
			EndCase

			If lPMOBBE03
				cLayCarVir := Execblock("PMOBBE03", .F., .F., {cLayCarVir,;
					TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
					TRB1->&(cAlias+"_CODPLA"),;
					TRB1->&(cAlias+"_VERSAO"),;
					TRB1->BA1_TIPUSU,;
					TRB1->BA1_GRAUPA})				
			Endif

			self:oBeneficiary['beneficiarios'][nLen]["modeloCartao"] := Alltrim(cLayCarVir)

			// Dados do contrato
			self:oBeneficiary['beneficiarios'][nLen]["codigoContrato"] := Alltrim(cContract)
			self:oBeneficiary['beneficiarios'][nLen]["dataContratacao"]	:= self:retDadMask(TRB1->BA1_DATINC,"D")
			self:oBeneficiary['beneficiarios'][nLen]["dataInicioCobertura"]	:= self:retDadMask(TRB1->BA1_DATCAR,"D")

			// Dados da empresa
			If TRB1->BA3_TIPOUS == "1" // Pessoa Física
				self:oBeneficiary['beneficiarios'][nLen]["chaveEmpresaContratante"]	:= self:oTitularMap['cpfTitular']
				self:oBeneficiary['beneficiarios'][nLen]["nomeEmpresaContratante"] := self:oTitularMap['nomeTitular']
				self:oBeneficiary['beneficiarios'][nLen]["contratoEmpresaContratante"] := self:oTitularMap['matriculaTitular']
			Else // Pessoa Juridica 		
				self:oBeneficiary['beneficiarios'][nLen]["chaveEmpresaContratante"]	:= self:retDadMask(TRB1->BQC_CNPJ)
				self:oBeneficiary['beneficiarios'][nLen]["nomeEmpresaContratante"] := self:retDadMask(TRB1->BQC_NREDUZ)
				self:oBeneficiary['beneficiarios'][nLen]["contratoEmpresaContratante"] := self:retDadMask(TRB1->BQC_CHAVE_CONTRATO)
			EndIf

			// Dados sobre o tipo de rede
			if lPMOBBE07
				cRedeAtend := Execblock("PMOBBE07", .F., .F., {self:oBeneficiary})
				if !empty(cRedeAtend)
					self:oBeneficiary['beneficiarios'][nLen]["redeAtendimento"]	:= cRedeAtend
				endIf
			endIf

			// Gera e retorna seed para Token de Atendimento. Grava também na BA1.
			If lFieldTok
				lLogUser := self:IsUserLoggedIn(TRB1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO), TRB1->BA1_CPFUSR)
				aRetTok := PLSTKSEEDG(Alltrim(TRB1->MATRICULA), lLogUser)
				If aRetTok[1]
					self:oBeneficiary['beneficiarios'][nLen]['custom'] := {}
					Aadd(self:oBeneficiary['beneficiarios'][nLen]['custom'], jSonObject():New())
					self:oBeneficiary['beneficiarios'][nLen]['custom'][1]['chave']       := "seed"
					self:oBeneficiary['beneficiarios'][nLen]['custom'][1]['valor']       := aRetTok[2]
					Aadd(self:oBeneficiary['beneficiarios'][nLen]['custom'], jSonObject():New())
					self:oBeneficiary['beneficiarios'][nLen]['custom'][2]['chave']       := "hash"
					self:oBeneficiary['beneficiarios'][nLen]['custom'][2]['valor']       := Iif(nSHAxTk==3,"SHA-1",Iif(nSHAxTk==5,"SHA-256","SHA-512"))
					Aadd(self:oBeneficiary['beneficiarios'][nLen]['custom'], jSonObject():New())
					self:oBeneficiary['beneficiarios'][nLen]['custom'][3]['chave']       := "seedType"
					self:oBeneficiary['beneficiarios'][nLen]['custom'][3]['valor']       := Iif(nSeedTp==1,"Text",Iif(nSeedTp==2,"Base64","Hex"))
					Aadd(self:oBeneficiary['beneficiarios'][nLen]['custom'], jSonObject():New())
					self:oBeneficiary['beneficiarios'][nLen]['custom'][4]['chave']       := "digits"
					self:oBeneficiary['beneficiarios'][nLen]['custom'][4]['valor']       := nDigits
					Aadd(self:oBeneficiary['beneficiarios'][nLen]['custom'], jSonObject():New())
					self:oBeneficiary['beneficiarios'][nLen]['custom'][5]['chave']       := "timeStep"
					self:oBeneficiary['beneficiarios'][nLen]['custom'][5]['valor']       := nX
				Endif
			EndIf

			// Da liberdade do cliente adicionar campos proprios ao modelo de dados 
			If lPMOBBE02
				oPMobBe02 := Execblock("PMOBBE02", .F., .F., {self:oBeneficiary})
				self:oBeneficiary['beneficiarios'][nLen]["custom"] := oPMobBe02:GetJsonObject('custom')
			Endif

			// DEFINE as carencias do usuário 
			self:SetGraceMap(TRB1->BA1_CODINT,;
				TRB1->BA1_CODEMP,;
				TRB1->BA1_MATRIC,;
				TRB1->BA1_TIPREG,;
				TRB1->BA1_DIGITO,;
				Alltrim(TRB1->&(cAlias+"_CODPLA")),;
				Alltrim(TRB1->&(cAlias+"_VERSAO")),;
				TRB1->BA1_DATCAR,;
				TRB1->BA1_SEXO)			

			self:oBeneficiary['beneficiarios'][nLen]["carencias"]		:= self:GetGraceMap():GetJsonObject('carencias')
			self:oBeneficiary['beneficiarios'][nLen]["dataFinalCpt"]	:= self:retDadMask(TRB1->BA1_DATCPT,"D")

			// DEFINE as chaves que serão utilizadas para demais integrações
			self:SetIntegrationMap(	TRB1->BA1_CODINT, TRB1->BA1_CODEMP, TRB1->BA1_MATRIC, TRB1->BA1_TIPREG, TRB1->BA1_DIGITO,;
			 						TRB1->BA1_CPFUSR, BA1->BA1_MATVID, IntegMapBeneficiary, TRB1->BA1_TIPUSU)			 						
			self:oBeneficiary['beneficiarios'][nLen]['integracao'] := self:GetIntegrationMap()

			// Este ponto de entrada permite ao cliente manipular o Payload de retorno. Não será feito nenhuma validação sobre o conteúdo alterado.
			If lPMOBBE04
				oObjBackup := Execblock("PMOBBE04", .F., .F., {self:oBeneficiary})

				If ValType(oObjBackup) == "O"
					self:oBeneficiary := oObjBackup				
				Endif
			Endif

			TRB1->( dbSKip() )			
		Enddo	
	Enddo

	TRB1->( dbCloseArea() )
	
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBeneficiaryMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetBeneficiaryMap() Class PMobBenef

Return(self:oBeneficiary)


//-------------------------------------------------------------------
/*/{Protheus.doc} IsTitular

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method IsTitular(cTipUsr) CLASS PMobBenef
	Local cTipTit := "00"
Return(cTipUsr==cTipTit)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetTitularMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetTitularMap(cCodInt, cCodEmp, cMatric) CLASS PMobBenef

	Local cTipTit   := self:oSettings['beneficiary']['typeUsrTitular']  //configurador
	Local aRetPhone := {}
	Local cTelefone := ''
	Local cCelular  := ''
	Local cSql      := ""
	Local cCodPla
	Local cDesPla
	Local lReturn	:= .T.
	Local cMessage  := ""

	cSql := " SELECT BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMUSR, BA1_EMAIL, BA1_DDD, BA1_TELEFO, BA1_CPFUSR, "
	cSql += "    BA1_TIPUSU, BA1_GRAUPA, BA1_MATVID, BA1_CODPLA, BA1_MOTBLO, BA1_DATBLO,BI3_BA1.BI3_DESCRI BA1_DESPLA,"
	cSql += "    BA3_CODPLA, BI3_BA3.BI3_DESCRI BA3_DESPLA, BA3_COBNIV, BA3_CODCLI, BA3_LOJA, BA3_TIPOUS, BA3_MOTBLO, BA3_DATBLO, "
	cSql += "    BA1.BA1_ENDERE,BA1.BA1_BAIRRO, BA1.BA1_CEPUSR, BA1.BA1_MUNICI, BA1.BA1_ESTADO " 
	cSql += " FROM "+RetSqlName("BA1")+" BA1 "
	cSql += " INNER JOIN "+RetSqlName("BA3")+" BA3 On BA3.BA3_FILIAL = '"+xFilial("BA3")+"' "
	cSql += "    AND BA3.BA3_CODINT = BA1_CODINT "
	cSql += "    AND BA3.BA3_CODEMP = BA1_CODEMP "
	cSql += "    AND BA3.BA3_MATRIC = BA1_MATRIC "
	cSql += "    AND BA3.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN "+RetSqlName("BI3")+" BI3_BA3 on BI3_BA3.BI3_FILIAL = '"+xFilial("BI3")+"' " 
	cSql += "    AND BI3_BA3.BI3_CODINT = BA3.BA3_CODINT "
	cSql += "    AND BI3_BA3.BI3_CODIGO = BA3.BA3_CODPLA "
	cSql += "    AND BI3_BA3.BI3_VERSAO = BA3.BA3_VERSAO "		
	cSql += "    AND BI3_BA3.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN "+RetSqlName("BI3")+" BI3_BA1 on BI3_BA1.BI3_FILIAL = '"+xFilial("BI3")+"' "
	cSql += "    AND BI3_BA1.BI3_CODINT = BA1.BA1_CODINT "
	cSql += "    AND BI3_BA1.BI3_CODIGO = BA1.BA1_CODPLA "
	cSql += "    AND BI3_BA1.BI3_VERSAO = BA1.BA1_VERSAO "
	cSql += "    AND BI3_BA1.D_E_L_E_T_ = ' ' "
	cSql += " WHERE BA1_CODINT = '"+cCodInt+"' "
	cSql += "    AND BA1_CODEMP = '"+cCodEmp+"' "
	cSql += "    AND BA1_MATRIC = '"+cMatric+"' "
	cSql += "    AND BA1_TIPUSU = '"+cTipTit+"' "
	cSql += "    AND BA1.D_E_L_E_T_ = ' ' "

	PlsQuery(cSql, "TRBTIT")

	If !TRBTIT->(Eof())
		self:oTitularMap['nomeTitular']      := self:retDadMask(TRBTIT->BA1_NOMUSR)
		self:oTitularMap['matriculaTitular'] := self:retDadMask(TRBTIT->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
		self:oTitularMap['emailTitular']     := self:retDadMask(TRBTIT->BA1_EMAIL)

		aRetPhone := self:retPhone(TRBTIT->BA1_DDD,TRBTIT->BA1_TELEFO)
		cTelefone := aRetPhone[1]
		cCelular  := aRetPhone[2]

		self:oTitularMap['celularTitular']  := cCelular
		self:oTitularMap['telefoneTitular'] := cTelefone
		self:oTitularMap['cpfTitular']      := self:retDadMask(TRBTIT->BA1_CPFUSR)

		self:oTitularMap['endereco'] := jSonObject():New()
		self:oTitularMap['endereco']['endereco'] := self:retDadMask(TRB1->BA1_ENDERE)
		self:oTitularMap['endereco']['bairro']	 := self:retDadMask(TRB1->BA1_BAIRRO)
		self:oTitularMap['endereco']['cep']  	 := self:retDadMask(TRB1->BA1_CEPUSR)
		self:oTitularMap['endereco']['cidade']	 := self:retDadMask(TRB1->BA1_MUNICI)
		self:oTitularMap['endereco']['estado']	 := self:retDadMask(TRB1->BA1_ESTADO)

		self:oTitularMap['planoTitular'] := jSonObject():New()		
		If !Empty(TRBTIT->BA1_CODPLA)
			cCodPla := Alltrim(TRBTIT->BA1_CODPLA)
			cDesPla := Alltrim(TRBTIT->BA1_DESPLA)
		Else
			cCodPla := Alltrim(TRBTIT->BA3_CODPLA)
			cDesPla := Alltrim(TRBTIT->BA3_DESPLA)
		Endif

		self:oTitularMap['planoTitular']['codigo']    := cCodPla
		self:oTitularMap['planoTitular']['descricao'] := cDespla
	Else
		lReturn := .F.
		cMessage := "Não localizamos os dados do titular."
	Endif

	TRBTIT->(dbCloseArea())
Return lReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} GetTitularMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetTitularMap(cProperty) CLASS PMobBenef
Return self:oTitularMap[cProperty]


//-------------------------------------------------------------------
/*/{Protheus.doc} SetContractMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetContractMap(cCodInt, cCodEmp, cMatric, cTipUsr, cNivelCob, cNomeEmp, cGrauPa, dDatBlo, cMotBlo, lFROMCache) CLASS PMobBenef

	Local nLen		:= 0
	Default lFROMCache := .F.

	If lFROMCache
		// Login do cache
		self:oContractMap['contratos'] := self:oLoginCache:GetJsonObject("contratos")

	Else
		Aadd(self:oContractMap['contratos'], jSonObject():New())
		nLen := Len(self:oContractMap['contratos'])

		self:oContractMap['contratos'][nLen]['codigoContrato'] := Alltrim(cCodInt+cCodEmp+cMatric)
		self:oContractMap['contratos'][nLen]['tipo'] := "beneficiario"	

		if cTipUsr == '1' // Pessoa fisica pura 		
			self:oContractMap['contratos'][nLen]['nome'] := self:GetTitularMap("nomeTitular")
		
		elseIf cTipUsr == "2" .and. cNivelCob == "1" // Pessoa juridica com nivel de cobranca na familia 
			self:oContractMap['contratos'][nLen]['nome'] := self:GetTitularMap("nomeTitular")
		
		else // Caso contrario, contrato empresarial
			self:oContractMap['contratos'][nLen]['nome'] := Alltrim(cNomeEmp)
		endIf

		// Determina as permissões do contrato. 
		self:SetPermissionsMap(cCodInt+cCodEmp+cMatric, cTipUsr, cNivelCob, cNomeEmp, cGrauPa, dDatBlo, cMotBlo)
		self:oContractMap['contratos'][nLen]['permissoes'] := self:GetPermissionsMap():GetJsonObject("permissoes")

		// Adiciona informações importantes sobre o perfil do usuário
		self:oContractMap['contratos'][nLen]['perfil'] := jSonObject():New()
		self:oContractMap['contratos'][nLen]['perfil']['dependencia']    := cTipUsr
		self:oContractMap['contratos'][nLen]['perfil']['grauParentesco'] := cGrauPa		
		self:oContractMap['contratos'][nLen]['perfil']['dataBloqueio']   := dTos(dDatBlo)
		self:oContractMap['contratos'][nLen]['perfil']['motivoBloqueio'] := cMotBlo	
	Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetContractMap

Resume o objeto oContractMap para ter o formato do payload de retorno
@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetContractMap() CLASS PMobBenef

	Local oContract := jSonObject():New()
	Local nCnt := 1
	Local nLen := 0 

	oContract['contratos'] := {}	
	For nCnt := 1 to Len(self:oContractMap['contratos'])
		Aadd(oContract['contratos'], jSonObject():New())
		nLen := Len(oContract['contratos'])

		oContract['contratos'][nLen]['codigoContrato'] 	:= self:oContractMap['contratos'][nCnt]['codigoContrato']
		oContract['contratos'][nLen]['tipo']			:= self:oContractMap['contratos'][nCnt]['tipo']
		oContract['contratos'][nLen]['permissoes']		:= self:oContractMap['contratos'][nCnt]['permissoes']
		oContract['contratos'][nLen]['nome']			:= self:oContractMap['contratos'][nCnt]['nome']	
	Next

Return(oContract)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
// Retorn a mensagem de erro, se houver. 
Method GetMessage() CLASS PMobBenef
Return(self:message)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetGraceMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetGraceMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCodPla, cVerPla, dDatCar, cSexo) CLASS PMobBenef

	Local aAux := {}
	Local nCnt := 0 
	Local nLen := 0

	// Redefine o objeto
	self:oGraceMap['carencias'] := {}

	 if Existblock("PMOBBE05")			
	 	aAux := Execblock("PMOBBE05", .F., .F., {cCodInt+cCodEmp+cMatric+cTipReg+cDigito,cCodPla,cVerPla,dDatCar})
	 else
	 	// Carencias padrões
	 	aAux := PLSCLACAR(cCodInt,(cCodInt+cCodEmp+cMatric+cTipReg+cDigito),dDataBase)
	
	 endIf

	If ValType(aAux) == "A" .and. Len(aAux) > 0
		For nCnt := 1 to len(aAux[2])
			// Prepara o objeto para receber a lista de carencias ...
			Aadd(self:oGraceMap['carencias'], jSonObject():New())
			nLen := Len(self:oGraceMap['carencias'])

			self:oGraceMap['carencias'][nLen]['tipoServico'] := Alltrim(aAux[2][nCnt][2]) 
			self:oGraceMap['carencias'][nLen]['carencia'] 	 := Alltrim(Iif(aAux[2][nCnt][3]<dDataBase, "Cumprida",Dtoc(aAux[2][nCnt][3])))
		Next
	Endif
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetGraceMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetGraceMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCodPla, cVerPla, dDatCar, cSexoEnum) CLASS PMobBenef
Return(self:oGraceMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetUserLoggedMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetUserLoggedMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCpfUsr, cMatVida, cUserLogged, lFROMCache, cTipUsu) CLASS PMobBenef

	Default lFROMCache := .F.

	// Inicializa o objeto
	self:oUserLoggedMap['usuarioLogado'] := jSonObject():New()

	If lFROMCache
		self:oUserLoggedMap['usuarioLogado'] := self:oLoginCache:GetJsonObject("usuarioLogado")

	Else
		self:oUserLoggedMap['usuarioLogado']['localizadorMensageria'] := cMatVida // No pls a chave comum entre todos os beneficiários do mesmo individo é a matricual da VIDA.
		self:oUserLoggedMap['usuarioLogado']['login'] := cUserLogged

		self:SetIntegrationMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCpfUsr, cMatVida, IntegMapUser, cTipUsu)
		self:oUserLoggedMap['usuarioLogado']['integracao'] := self:GetIntegrationMap()
	Endif

Return

Method GetUserLoggedMap() CLASS PMobBenef
Return(self:oUserLoggedMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetIntegrationMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetIntegrationMap(cCodInt, cCodEmp, cMatric, cTipReg, cDigito, cCpfUsr, cMatVida, cTypeIntegrationMap, cTipUsu) CLASS PMobBenef

	// Necessário redefinir a propriedade a cada novo ciclo.
	self:oIntegrationMap:= jSonObject():New()
	

	// Dados exclusivos da entidade Beneficiário
	self:oIntegrationMap['chaveBeneficiario'] 		:= self:loginMap['chaveBeneficiario']
	self:oIntegrationMap['chaveBeneficiarioTipo'] 	:= self:loginMap['chaveBeneficiarioTipo']
	self:oIntegrationMap['multiContract'] 			:= self:loginMap['multiContract']
	self:oIntegrationMap['matriculaVida'] 			:= cMatVida
	self:oIntegrationMap['tipoUsuario'] 			:= cTipUsu
	self:oIntegrationMap['matriculaContrato'] 		:= cCodInt+cCodEmp+cMatric+cTipReg+cDigito


Return

Method GetIntegrationMap() CLASS PMobBenef
Return(self:oIntegrationMap)


//-------------------------------------------------------------------
/*/{Protheus.doc} SetPermissionsMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetPermissionsMap(cContract, cTipUsr, cNivelCob, cNomeEmp, cGrauPa, dDatBlo, cMotBlo) CLASS PMobBenef

	Local oFeactures := self:oSettings:GetJsonObject( 'appFeactures' )
	Local lAcesso  := .F.
	Local lOcultar := .F.
	Local cMsgBloq := ""
	Local nCnt     := 0
	Local aRet     := {}
	
	self:oPermissionsMap := jSonObject():New()
	self:oPermissionsMap['permissoes'] := {}

	// Por padrão, todas as Feactures são liberadas. As restrições serão levantadas junto ao cliente durante a implantação
	for nCnt := 1 to Len(oFeactures)
		Aadd(self:oPermissionsMap['permissoes'], jSonObject():New())
		
		lAcesso  := iif(oFeactures[nCnt]:GetJsonText("acesso")=="0",.F.,.T.)
		lOcultar := iif(oFeactures[nCnt]:GetJsonText("ocultar")=="0",.F.,.T.)
		cMsgBloq := oFeactures[nCnt]:GetJsonText("mensagemBloqueio")

		self:oPermissionsMap['permissoes'][nCnt]['funcionalidade'] := oFeactures[nCnt]:GetJsonText("cod")
		self:oPermissionsMap['permissoes'][nCnt]['acesso'] :=  lAcesso
		self:oPermissionsMap['permissoes'][nCnt]['mensagemBloqueio'] := iif(Empty(cMsgBloq),NIL,cMsgBloq)
		self:oPermissionsMap['permissoes'][nCnt]['ocultar']	:=  lOcultar
	next

	// Executa ponto de entrada para tratamento de permissões especificas do cliente
	if ExistBlock("PMOBBE06")	
		cJsonPerm := FwJsonSerialize(self:oPermissionsMap)
		aRet := Execblock("PMOBBE06", .F., .F., {cJsonPerm, cContract, cTipUsr, cNivelCob, cNomeEmp, cGrauPa, dDatBlo, cMotBlo})
		if ValType(aRet) == "A" .And. len(aRet) > 0 

			self:oPermissionsMap := jSonObject():New()
			self:oPermissionsMap['permissoes'] := {}
			for nCnt := 1 to Len(aRet)
				Aadd(self:oPermissionsMap['permissoes'], jSonObject():New())
				self:oPermissionsMap['permissoes'][nCnt]['funcionalidade']   := aRet[nCnt,1]
				self:oPermissionsMap['permissoes'][nCnt]['acesso']           := aRet[nCnt,2]
				self:oPermissionsMap['permissoes'][nCnt]['mensagemBloqueio'] := aRet[nCnt,3]
				self:oPermissionsMap['permissoes'][nCnt]['ocultar']	         := aRet[nCnt,4]
			next

		endIf		
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetPermissionsMap

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetPermissionsMap(cContract, cTipUsr, cNivelCob, cNomeEmp, cGrauPa, dDatBlo, cMotBlo) CLASS PMobBenef

Return(self:oPermissionsMap)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetContactInfo

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetContactInfo(cBenefiaryMap, cTitularMap, xContent, xDefault) CLASS PMobBenef

	Local xRet := nil 

	If !Empty(xContent)
		xRet := xContent

	Elseif Empty(xContent) .and. self:oSettings['businessRules']['useContactFromTitular']
		xRet := self:oTitularMap[cTitularMap]
		
	Else
		xRet := xDefault
		
	Endif

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAddressInfo

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetAddressInfo(cBenefiaryMap, cTitularMap, xContent) CLASS PMobBenef

	Local xRet := nil 

	If !Empty(xContent)
		xRet := xContent

	Elseif Empty(xContent) .and. self:oSettings['businessRules']['useAdressFromTitular']
		xRet := self:oTitularMap['endereco'][cTitularMap]

	Endif

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckLoginCache

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method CheckLoginCache(lCache) CLASS PMobBenef

	Local cCacheResult := ""
	Local lRet := .T.
	Local cSql := ""
	Local lInvalida := .F.
	Local cData     := DtoS(Date())
	Default lCache := .T.

	if !self:lUseCache 
		lRet := .F.
	else
		cSql := " SELECT BJV.R_E_C_N_O_ RECNO FROM "+RetSqlName("BJV")+" BJV "
		cSql += " WHERE BJV.BJV_FILIAL = '"+xFilial("BJV")+"' "
		cSql += "   AND BJV.BJV_CODOPE = '"+PlsIntPad()+"' "	
		cSql += "   AND BJV.BJV_LOGIN = '"+Alltrim(self:chaveBeneficiario)+"' "
		cSql += "   AND BJV.BJV_ATIVO = '1' "
		cSql += "   AND BJV.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB1",.T.,.F.)
		
		if TRB1->( Eof() )
			lRet := .F.
		else
			BJV->(dbGoto(TRB1->RECNO))
			// Checa a validade do cache
			if (DToS(BJV->BJV_DTVALI) < cData ) .Or. (DToS(BJV->BJV_DTVALI) == cData .and. BJV->BJV_HRVALI < Time() )
				lRet := .F.
				lInvalida := .T.
	
			// Registra o jSon contido no cache
			elseIf lCache
				cCacheResult := Decode64(BJV->BJV_CACHE)
				self:oLoginCache:FROMJson(cCacheResult)
			endIf

			if lInvalida
				if !BJV->( Eof() )
					BJV->( Reclock("BJV", .F.) )
					BJV->BJV_ATIVO := '0'
					BJV->( MsUnlock() )
				endIf
			endIf

		endIf
		TRB1->( dbCloseArea() )
	
	endIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetLoginFROMCache

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method GetLoginFROMCache() CLASS PMobBenef

	Local lRet := .T.

	If !self:lUseCache 
		lRet := .F.
	Else
		// Seta os contratos
		self:SetContractMap( nil, nil, nil, nil, nil, nil, nil, nil, nil, .T.)

		// Seta usuário logado
		self:SetUserLoggedMap( nil, nil, nil, nil, nil, nil, nil, nil, .T.)

		// Seta os beneficiários
		self:oBeneficiary['beneficiarios'] := self:oLoginCache:GetJsonObject("beneficiarios")		
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetLoginToCache

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method SetLoginToCache(oLogin) CLASS PMobBenef

	Local ntimeToExpires := self:oSettings['login']['timeToExpireCache']
	Local cLogin64
	Local dDate := Date()
	Local cTime := Time()
	Local lFindCache := .F.

	If !self:lUseCache 
		Return .F.
	Endif

	If !self:CheckLoginCache(.F.)
		SomaDiaHor(@dDate,@cTime,ntimeToExpires)
		cLogin64 := Encode64(oLogin)

		BJV->(DBSetOrder(1))
		lFindCache := BJV->(MsSeek(FWXFilial("BJV")+PlsIntPad()+self:chaveBeneficiario+"1")) // 1 = Ativo

		BJV->( Reclock("BJV", !lFindCache) )
		BJV->BJV_FILIAL := xFilial("BJV")
		BJV->BJV_CODOPE := PlsIntPad()
		BJV->BJV_LOGIN  := self:chaveBeneficiario
		BJV->BJV_CACHE  := cLogin64
		BJV->BJV_DTVALI := dDate
		BJV->BJV_HRVALI := cTime
		BJV->BJV_ATIVO	:= '1'
		BJV->( MsUnlock() )
	Endif
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} removeDot

@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method retPhone(cDDD,cPhone) CLASS PMobBenef

	Local cTelefone := ''
	Local cCelular  := ''

	cDDD   := Alltrim(self:removeDot(cDDD))
	cPhone := Alltrim(self:removeDot(cPhone))

	if !Empty(cDDD) .And. len(cDDD) == 3 .And. Substr(cDDD,1,1) == "0"
		cDDD := Substr(cDDD,2,len(cDDD))
	endIf

	if !Empty(cPhone) .And. len(cPhone) > 10 .And. Substr(cPhone,1,1) == "0"
		cPhone := Substr(cPhone,2,len(cPhone))
	endIf
	
	if len(cDDD+cPhone) == 10
		cTelefone := cDDD+cPhone
	elseIf len(cDDD+cPhone) == 11
		cCelular  := cDDD+cPhone
	endIf

Return {cTelefone,cCelular}


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadMask

@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method retDadMask(xItem,cTipo) CLASS PMobBenef

	Local xRet
	Default cTipo := "C"

	if cTipo == "C"
		xRet := iif(Empty(xItem),'',Alltrim(xItem))

	elseIf cTipo == "D"
		xRet := iif(Empty(xItem),'',Transform(Dtos(xItem), "@R 9999-99-99"))

	elseIf cTipo == "N"
		xRet := xItem

	endIf
	
Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} gerQryBenef

	Retorna a query principal

@author  Geraldo (Mobile Saude) / Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method gerQryBenef() CLASS PMobBenef


	Local cSql := ""
	Local oMatric
	Local cBDUtilizado := AllTrim(TCGetDB())

	// Busca todos os contratos o CPF consta como beneficiário
	cSql += " SELECT * FROM ("  + cEnt
	cSql += "	SELECT "	+ cEnt
	cSql += "	BTS.BTS_NRCRNA BA1_CNS, " + cEnt
	cSql += "	BA1.BA1_MATVID, " + cEnt
	cSql += "	BA1.BA1_CPFUSR BA1_CHAVE_BENEFICIARIO, " + cEnt 	

	If cBDUtilizado	$ "ORACLE|DB2|POSTGRES"		
		cSql += " BA1.BA1_CODINT || BA1.BA1_CODEMP || BA1.BA1_MATRIC || BA1.BA1_TIPREG || BA1.BA1_DIGITO MATRICULA, " + cEnt
	Else
		cSql += " BA1.BA1_CODINT + BA1.BA1_CODEMP + BA1.BA1_MATRIC + BA1.BA1_TIPREG + BA1.BA1_DIGITO MATRICULA, " + cEnt
	EndIf

	cSql += "	BA1.BA1_MATANT, "  + cEnt
	cSql += " 	BA1.BA1_MATEMP, " 		+ cEnt		
	cSql += "	BA1.BA1_NOMUSR, "  + cEnt
	cSql += "	BA1.BA1_VIACAR, "+ cEnt
	cSql += "	BA1.BA1_DTVLCR, "+ cEnt
	cSql += "	BA1.BA1_CODINT, "+ cEnt
	cSql += "	BA1.BA1_CODEMP, "+ cEnt
	cSql += "	BA1.BA1_MATRIC, "+ cEnt
	cSql += "	BA1.BA1_TIPREG, "+ cEnt
	cSql += "	BA1.BA1_DIGITO, "+ cEnt
	cSql += "	BA1.BA1_DATNAS, "		+ cEnt
	cSql += "	BA1.BA1_CPFUSR, "+ cEnt
	cSql += "	BA1.BA1_DDD, BA1.BA1_TELEFO, "+ cEnt 
	cSql += "	BA1.BA1_EMAIL, "	+ cEnt
	cSql += "	BA1.BA1_ENDERE,BA1.BA1_BAIRRO, BA1.BA1_CEPUSR, BA1.BA1_MUNICI, BA1.BA1_ESTADO, "+ cEnt 
	cSql += "	BA1.BA1_TIPUSU, "+ cEnt
	cSql += "	BA1.BA1_GRAUPA, "+ cEnt
	cSql += "		BRP.BRP_DESCRI, " 	+ cEnt			
	cSql += "	BA1.BA1_DATINC, "+ cEnt
	cSql += "	BA1.BA1_DATCAR, "+ cEnt
	cSql += "	BA1.BA1_DATCPT,	"+ cEnt
	cSql += "	BA1.BA1_MOTBLO, "+ cEnt
	cSql += "	BA1.BA1_DATBLO, "+ cEnt
	cSql += "	BA1.BA1_CONSID, "+ cEnt
	cSql += "	'' BA1_MODCART,	"	+ cEnt
	cSql += "	'' BA1_NOME_SOCIAL, "+ cEnt
	cSql += "	BA1.BA1_LCVIRT, "+ cEnt
	cSql += "	CASE  "+ cEnt
	cSql += "		WHEN BA1.BA1_SEXO = '1' "+ cEnt  
	cSql += "			THEN  'M'  "+ cEnt
	cSql += "		WHEN BA1.BA1_SEXO = '2' "+ cEnt  
	cSql += "			THEN  'F'  "+ cEnt
	cSql += "		ELSE  "+ cEnt
	cSql += "			'N' "  + cEnt
	cSql += "		END AS BA1_SEXO, "+ cEnt 
	cSql += "	BA1.BA1_CODPLA, "+ cEnt
	cSql += "		BA1.BA1_VERSAO, "+ cEnt
	cSql += "		BI3_BA1.BI3_LCVIRT BI3_BA1_LCVIRT, "+ cEnt						
	cSql += "		BI3_BA1.BI3_DESCRI BA1_DESPLA, " 			+ cEnt
	cSql += "		BI3_BA1.BI3_SUSEP  BA1_CONVANS,	"+ cEnt
	cSql += "		'' BA1_REDATEND, "+ cEnt
	cSql += "		BI3_BA1.BI3_ABRANG BA1_ABRANG, "+ cEnt
	cSql += "		BI3_BA3.BI3_CODIGO, "+ cEnt
	cSql += "		BI3_BA3.BI3_VERSAO, "+ cEnt
	cSql += "		BI3_BA1.BI3_CODACO AS BA1CODACO, "+ cEnt
	cSql += "		BI3_BA3.BI3_CODACO AS BA3CODACO, "+ cEnt
	cSql += "		BI3_BA1.BI3_PADSAU AS BA1PADSAU, "+ cEnt
	cSql += "		BI3_BA3.BI3_PADSAU AS BA3PADSAU, "+ cEnt
	cSql += "		BI3_BA3.BI3_CODSEG, "+ cEnt 	
	cSql += "		BF7_BA1.BF7_DESORI BA1_DESABR, "+ cEnt
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_MODPAG = '1' "+ cEnt  
	cSql += "				THEN  'Pre-Pagamento' "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_MODPAG = '2' "  + cEnt
	cSql += "				THEN  'Demais Modalidades' " + cEnt
	cSql += "			WHEN BI3_BA1.BI3_MODPAG = '3'  "+ cEnt
	cSql += "				THEN  'Pos-Estabelecido'  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_MODPAG = '4'  "+ cEnt
	cSql += "				THEN  'Misto (Pre/Pos)'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'Não Definida' "+ cEnt  
	cSql += "		END AS BA1_MODPAG, "+ cEnt
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_CPFM  = '1' "+ cEnt  
	cSql += "				THEN  'S'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'N' "+ cEnt
	cSql += "		END AS BA1_COPART, " + cEnt
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_APOSRG  = '0' "+ cEnt  
	cSql += "				THEN  'NÃO REGULAMENTADO'  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_APOSRG  = '1'  "+ cEnt
	cSql += "				THEN  'REGULAMENTADO'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'ADAPTADO' "+ cEnt  
	cSql += "		END AS BA1_REGULAMENTACAO, "+ cEnt 	
	cSql += "	BA3_NUMCON,  "+ cEnt
	cSql += "	BA3_COBNIV, "+ cEnt
	cSql += "	BA3_CODCLI, "+ cEnt
	cSql += "	BA3_LOJA, "+ cEnt
	cSql += "	BA3.BA3_MOTBLO, "+ cEnt	
	cSql += "	BA3.BA3_DATBLO, "+ cEnt
	cSql += "	BA3.BA3_LCVIRT, "+ cEnt
	cSql += "	BA3_CODPLA, "+ cEnt
	cSql += "		BA3.BA3_VERSAO, "+ cEnt
	cSql += "		BI3_BA3.BI3_LCVIRT BI3_BA3_LCVIRT, "+ cEnt
	cSql += "		BI3_BA3.BI3_DESCRI BA3_DESPLA, " 			+ cEnt	
	cSql += "		BI3_BA3.BI3_SUSEP BA3_CONVANS, "+ cEnt
	cSql += "		'' BA3_REDATEND, "+ cEnt
	cSql += "		BI3_BA3.BI3_ABRANG BA3_ABRANG, "+ cEnt 	
	cSql += "		BF7_BA3.BF7_DESORI BA3_DESABR, "+ cEnt
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA3.BI3_MODPAG = '1' "+ cEnt  
	cSql += "				THEN  'Pre-Pagamento' "+ cEnt
	cSql += "			WHEN BI3_BA3.BI3_MODPAG = '2' "  + cEnt
	cSql += "				THEN  'Demais Modalidades' "  + cEnt
	cSql += "			WHEN BI3_BA3.BI3_MODPAG = '3'  "+ cEnt
	cSql += "				THEN  'Pos-Estabelecido'  "+ cEnt
	cSql += "			WHEN BI3_BA3.BI3_MODPAG = '4'  "+ cEnt
	cSql += "				THEN  'Misto (Pre/Pos)'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'Não Definida' "+ cEnt  
	cSql += "			END AS BA3_MODPAG, "+ cEnt
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA3.BI3_CPFM  = '1' "+ cEnt  
	cSql += "				THEN  'S'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'N' "  + cEnt
	cSql += "			END AS BA3_COPART, "+ cEnt 
	cSql += "		CASE  "+ cEnt
	cSql += "			WHEN BI3_BA3.BI3_APOSRG  = '0' "+ cEnt  
	cSql += "				THEN  'NÃO REGULAMENTADO'  "+ cEnt
	cSql += "			WHEN BI3_BA1.BI3_APOSRG  = '1'  "+ cEnt
	cSql += "				THEN  'REGULAMENTADO'  "+ cEnt
	cSql += "			ELSE  "+ cEnt
	cSql += "				'ADAPTADO' "+ cEnt  
	cSql += "			END AS BA3_REGULAMENTACAO, "+ cEnt 		

	cSql += "	BA3.BA3_TIPOUS, "+ cEnt
	cSql += "	CASE  "+ cEnt
	cSql += "		WHEN BA3.BA3_TIPOUS = '1' "+ cEnt
	cSql += "			THEN  'PESSOA FISICA'  "+ cEnt
	cSql += "		ELSE  "+ cEnt
	cSql += "			'PESSOA JURIDICA' "+ cEnt  
	cSql += "		END AS BA3_TIPPES, "+ cEnt
	cSql += "	BA3.R_E_C_N_O_ AS RECNOBA3, "+ cEnt

	If cBDUtilizado	$ "ORACLE|DB2|POSTGRES"
		cSql += " BQC_CODIGO || BQC_NUMCON || BQC_VERCON || BQC_SUBCON || BQC_VERSUB BQC_CHAVE_CONTRATO, "+ cEnt 
	Else
		cSql += " BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB BQC_CHAVE_CONTRATO, "+ cEnt
	EndIf

	cSql += "	BQC_CNPJ, "+ cEnt
	cSql += "	BQC_NREDUZ, "+ cEnt
	cSql += "	BQC_SUBCON, "+ cEnt
	cSql += "	BQC_COBNIV, "+ cEnt
	cSql += "	BQC_CODCLI, " + cEnt
	cSql += "	BQC_LOJA, "+ cEnt
	cSql += "	BQC.BQC_LCVIRT, "+ cEnt

	cSql += "	BT5_COBNIV, "+ cEnt
	cSql += "	BT5_CODCLI, "+ cEnt
	cSql += "	BT5_LOJA, "+ cEnt

	cSql += "	BG9_CODCLI, " + cEnt
	cSql += "	BG9_LOJA,    "			+ cEnt

	cSql += " BG1_LOGIN, "+ cEnt
	cSql += " BG1_BLQCAR, "	+ cEnt
	cSql += " BG3_LOGIN, "+ cEnt
	cSql += " BG3_BLQCAR, "+ cEnt

	cSql += " BT6_BA1.BT6_LCVIRT BT6_BA1_LCVIRT, "+ cEnt
	cSql += " BT6_BA3.BT6_LCVIRT BT6_BA3_LCVIRT, " + cEnt
	If self:lLoginByCPF .or. self:lMultiContract
		cSql += "	(SELECT BA1_X.BA1_CPFUSR FROM "+RetSqlName("BA1")+" BA1_X WHERE BA1_X.BA1_FILIAL = '"+xFilial("BA1")+"' "  	+ cEnt			
		cSql += "		AND BA1_X.BA1_CODINT = BA1.BA1_CODINT " 				+ cEnt
		cSql += "		AND BA1_X.BA1_CODEMP = BA1.BA1_CODEMP "			+ cEnt
		cSql += "		AND BA1_X.BA1_MATRIC = BA1.BA1_MATRIC "					+ cEnt
		cSql += "		AND BA1_X.BA1_CPFUSR = '"+self:chaveBeneficiario+"' "+ cEnt
		cSql += "		AND BA1_X.D_E_L_E_T_ = ' ' "+ cEnt

		cSql += "	) CPFUSR, "+ cEnt
	Endif
	cSql += "	(SELECT BA1_Y.BA1_CPFUSR FROM "+RetSqlName("BA1")+" BA1_Y WHERE BA1_Y.BA1_FILIAL = '"+xFilial("BA1")+"' "+ cEnt 				
	cSql += "		AND BA1_Y.BA1_CODINT = BA1.BA1_CODINT 	"			+ cEnt
	cSql += "		AND BA1_Y.BA1_CODEMP = BA1.BA1_CODEMP 	"			+ cEnt
	cSql += "		AND BA1_Y.BA1_MATRIC = BA1.BA1_MATRIC 	"			+ cEnt
	cSql += "		AND BA1_Y.BA1_TIPUSU = 'T' "+ cEnt
	cSql += "		AND BA1_Y.D_E_L_E_T_ = ' '"+ cEnt
	cSql += "	) CPFUSR_TITULAR, "+ cEnt

	cSql += "	BA1.D_E_L_E_T_ " + cEnt
	
	cSql += "	FROM "+RetSqlName("BA1")+" BA1 " + cEnt
	cSql += "		INNER JOIN "+RetSqlName("BTS")+" BTS on BTS.BTS_FILIAL = '"+xFilial("BTS")+"' "+ cEnt
	cSql += "			AND BTS.BTS_MATVID = BA1.BA1_MATVID "+ cEnt
	cSql += "			AND BTS.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		INNER JOIN "+RetSqlName("BA3")+" BA3 On BA3.BA3_FILIAL = '"+xFilial("BA3")+"' "+ cEnt	
	cSql += "			AND BA3.BA3_CODINT = BA1.BA1_CODINT " 	+ cEnt
	cSql += "			AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "	+ cEnt
	cSql += "			AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "	+ cEnt
	cSql += "			AND BA3.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BI3")+" BI3_BA3 on BI3_BA3.BI3_FILIAL = '"+xFilial("BA3")+"'"+ cEnt		
	cSql += "			AND BI3_BA3.BI3_CODINT = BA3.BA3_CODINT " 	+ cEnt
	cSql += "			AND BI3_BA3.BI3_CODIGO = BA3.BA3_CODPLA "	+ cEnt
	cSql += "			AND BI3_BA3.BI3_VERSAO = BA3.BA3_VERSAO "	+ cEnt
	cSql += "			AND BI3_BA3.D_E_L_E_T_ = ' ' "
	cSql += "		LEFT JOIN "+RetSqlName("BI3")+" BI3_BA1 on BI3_BA1.BI3_FILIAL = '"+xFilial("BI3")+"' "+ cEnt 	
	cSql += "			AND BI3_BA1.BI3_CODINT = BA1.BA1_CODINT " 	+ cEnt
	cSql += "			AND BI3_BA1.BI3_CODIGO = BA1.BA1_CODPLA "	+ cEnt
	cSql += "			AND BI3_BA1.BI3_VERSAO = BA1.BA1_VERSAO "	+ cEnt
	cSql += "			AND BI3_BA1.D_E_L_E_T_ = ' ' "
	cSql += "		INNER JOIN "+RetSqlName("BG9")+" BG9 on BG9.BG9_FILIAL = '"+xFilial("BG9")+"' "  	+ cEnt
	cSql += "			AND BG9.BG9_CODINT = BA1.BA1_CODINT " 	+ cEnt
	cSql += "			AND BG9.BG9_CODIGO = BA1.BA1_CODEMP "	+ cEnt
	cSql += "			AND BG9.D_E_L_E_T_ = ' ' "
	cSql += "		LEFT JOIN "+RetSqlName("BT5")+" BT5 ON BT5.BT5_FILIAL = '"+xFilial("BT5")+"' "+ cEnt 	
	cSql += "			AND BT5.BT5_CODINT = BA1.BA1_CODINT " 	+ cEnt
	cSql += "			AND BT5.BT5_CODIGO = BA1.BA1_CODEMP "	+ cEnt
	cSql += "			AND BT5.BT5_NUMCON = BA1.BA1_CONEMP "	+ cEnt
	cSql += "			AND BT5.BT5_VERSAO = BA1.BA1_VERCON "	+ cEnt
	cSql += "			AND BT5.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BQC")+" BQC On BQC.BQC_FILIAL = '"+xFilial("BQC")+"' "+ cEnt  	
	cSql += "			AND BQC.BQC_CODINT = BA1.BA1_CODINT " 	+ cEnt
	cSql += "			AND BQC.BQC_CODEMP = BA1.BA1_CODEMP "	+ cEnt
	cSql += "			AND BQC.BQC_NUMCON = BA1.BA1_CONEMP "	+ cEnt
	cSql += "			AND BQC.BQC_VERCON = BA1.BA1_VERCON "	+ cEnt
	cSql += "			AND BQC.BQC_SUBCON = BA1.BA1_SUBCON "	+ cEnt
	cSql += "			AND BQC.BQC_VERSUB = BA1.BA1_VERSUB "	+ cEnt
	cSql += "			AND BQC.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BT6")+" BT6_BA1 On BT6_BA1.BT6_FILIAL = '"+xFilial("BT6")+"' "+ cEnt  	
	cSql += "			AND BT6_BA1.BT6_CODINT = BQC.BQC_CODINT " 	+ cEnt
	cSql += "			AND BT6_BA1.BT6_CODIGO = BQC.BQC_CODEMP "	+ cEnt
	cSql += "			AND BT6_BA1.BT6_NUMCON = BQC.BQC_NUMCON "	+ cEnt
	cSql += "			AND BT6_BA1.BT6_VERCON = BQC.BQC_VERCON "	+ cEnt
	cSql += "			AND BT6_BA1.BT6_SUBCON = BQC.BQC_SUBCON "	+ cEnt
	cSql += "			AND BT6_BA1.BT6_VERSUB = BQC.BQC_VERSUB "+ cEnt
	cSql += "			AND BT6_BA1.BT6_CODPRO = BA1.BA1_CODPLA "+ cEnt
	cSql += "			AND BT6_BA1.BT6_VERSAO = BA1.BA1_VERSAO "+ cEnt
	cSql += "			AND BT6_BA1.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BT6")+" BT6_BA3 On BT6_BA3.BT6_FILIAL = '"+xFilial("BT6")+"' "+ cEnt  	
	cSql += "			AND BT6_BA3.BT6_CODINT = BQC.BQC_CODINT " 	+ cEnt
	cSql += "			AND BT6_BA3.BT6_CODIGO = BQC.BQC_CODEMP "	+ cEnt
	cSql += "			AND BT6_BA3.BT6_NUMCON = BQC.BQC_NUMCON "	+ cEnt
	cSql += "			AND BT6_BA3.BT6_VERCON = BQC.BQC_VERCON "	+ cEnt
	cSql += "			AND BT6_BA3.BT6_SUBCON = BQC.BQC_SUBCON "	+ cEnt
	cSql += "			AND BT6_BA3.BT6_VERSUB = BQC.BQC_VERSUB "+ cEnt
	cSql += "			AND BT6_BA3.BT6_CODPRO = BA3.BA3_CODPLA "+ cEnt
	cSql += "			AND BT6_BA3.BT6_VERSAO = BA3.BA3_VERSAO "+ cEnt
	cSql += "			AND BT6_BA3.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		INNER JOIN "+RetSqlName("BRP")+" BRP on BRP.BRP_FILIAL = '"+xFilial("BRP")+"' "+ cEnt  
	cSql += "			AND BRP.BRP_CODIGO = BA1.BA1_GRAUPA "+ cEnt
	cSql += "			AND BRP.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BF7")+" BF7_BA1 on BF7_BA1.BF7_FILIAL  = '"+xFilial("BF7")+"' "+ cEnt
	cSql += "			AND BF7_BA1.BF7_CODORI = BI3_BA1.BI3_ABRANG "+ cEnt
	cSql += "			AND BF7_BA1.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "		LEFT JOIN "+RetSqlName("BF7")+" BF7_BA3 on BF7_BA3.BF7_FILIAL  = '"+xFilial("BF7")+"' "+ cEnt
	cSql += "			AND BF7_BA3.BF7_CODORI = BI3_BA3.BI3_ABRANG "+ cEnt
	cSql += "			AND BF7_BA3.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "	LEFT JOIN "+RetSqlName("BG3")+" BG3 ON BG3.BG3_FILIAL = '"+xFilial("BG3")+"' "
	cSql += "		AND BG3.BG3_CODBLO = BA1.BA1_MOTBLO "+ cEnt
	cSql += "		AND BG3.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "	LEFT JOIN "+RetSqlName("BG1")+" BG1 ON BG1.BG1_FILIAL = '"+xFilial("BG1")+"' "+ cEnt
	cSql += "		AND BG1.BG1_CODBLO = BA3.BA3_MOTBLO "+ cEnt
	cSql += "		AND BG1.D_E_L_E_T_ = ' ' "+ cEnt
	cSql += "	) CPF "+ cEnt
	cSql += " WHERE "+ cEnt

	If self:lLoginByCpf .or. self:lMultiContract 	// login por CPF ou por Matricula + Multicontrato
		cSql += " CPFUSR = '"+self:chaveBeneficiario+"' " + cEnt
	Else
		oMatric := PMobSplMat(self:chaveBeneficiario)
		cSql += " BA1_CODINT = '"	+oMatric['codInt']+"' " + cEnt
		cSql += " AND BA1_CODEMP = '"+oMatric['codEmp']+"' "+ cEnt
		cSql += " AND BA1_MATRIC = '"+oMatric['matric']+"' "+ cEnt
	Endif

	cSql += "  AND D_E_L_E_T_ = ' ' " + cEnt

	cSql += " ORDER BY BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG "+ cEnt


Return cSql


//-------------------------------------------------------------------
/*/{Protheus.doc} removeDot

@author  Renan Sakai
@version P12
@since   06/09/18
/*/
//-------------------------------------------------------------------
Method removeDot(cExp) CLASS PMobBenef

	cExp := StrTran(cExp,"-"," ")                                       
	cExp := StrTran(cExp,"."," ")
	cExp := StrTran(cExp,"´"," ") 
	cExp := StrTran(cExp,","," ") 
	cExp := StrTran(cExp,"("," ") 
	cExp := StrTran(cExp,")"," ") 
	cExp := StrTran(cExp,"/"," ") 
	cExp := StrTran(cExp,"\"," ") 
	cExp := StrTran(cExp,":"," ") 
	cExp := StrTran(cExp,"^"," ")
	cExp := StrTran(cExp,"*"," ")
	cExp := StrTran(cExp,"$"," ")
	cExp := StrTran(cExp,"#"," ")
	cExp := StrTran(cExp,"!"," ")
	cExp := StrTran(cExp,"["," ")
	cExp := StrTran(cExp,"]"," ")
	cExp := StrTran(cExp,"?"," ")
	cExp := StrTran(cExp,";"," ")
	cExp := StrTran(cExp,"ç","c")
	cExp := StrTran(cExp,"`"," ")
	cExp := StrTran(cExp,Chr(166)," ")
	cExp := StrTran(cExp,Chr(167)," ")
	cExp := StrTran(cExp,"á","a")
	cExp := StrTran(cExp,"ã","a")                                     
	cExp := StrTran(cExp,"à","a")
	cExp := StrTran(cExp,"â","a")
	cExp := StrTran(cExp,"é","e")
	cExp := StrTran(cExp,"è","e")
	cExp := StrTran(cExp,"ê","e")
	cExp := StrTran(cExp,"í","i")
	cExp := StrTran(cExp,"ì","i")
	cExp := StrTran(cExp,"ó","o")
	cExp := StrTran(cExp,"ò","o")
	cExp := StrTran(cExp,"õ","o")
	cExp := StrTran(cExp,"ô","o")
	cExp := StrTran(cExp,"ú","u")
	cExp := StrTran(cExp,"ù","u")
	cExp := StrTran(cExp,"Á","A")
	cExp := StrTran(cExp,"À","A")
	cExp := StrTran(cExp,"Â","A")
	cExp := StrTran(cExp,"Ã","A")
	cExp := StrTran(cExp,"É","E")
	cExp := StrTran(cExp,"È","E")
	cExp := StrTran(cExp,"Ê","E")
	cExp := StrTran(cExp,"Í","I")
	cExp := StrTran(cExp,"Ì","I")
	cExp := StrTran(cExp,"Ó","O")
	cExp := StrTran(cExp,"Ò","O")
	cExp := StrTran(cExp,"Õ","O")
	cExp := StrTran(cExp,"Ô","O")
	cExp := StrTran(cExp,"Ú","U")
	cExp := StrTran(cExp,"Ç","C")
	cExp := StrTran(cExp,"@"," ")
	cExp := StrTran(cExp,"%"," ")
	cExp := StrTran(cExp,"~"," ")
	cExp := StrTran(cExp,"¨"," ")
	cExp := StrTran(cExp,"{"," ")
	cExp := StrTran(cExp,"}"," ")
	cExp := StrTran(cExp,"+"," ")
	cExp := StrTran(cExp,"-"," ")
	cExp := StrTran(cExp,"="," ")
	cExp := StrTran(cExp,"_"," ")
	cExp := StrTran(cExp,"<"," ")
	cExp := StrTran(cExp,">"," ")
	cExp := StrTran(cExp,"&"," ")
	cExp := StrTran(cExp,"|"," ")

Return(cExp)
