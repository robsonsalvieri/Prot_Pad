#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/////////////////////////////////////////////////////////
/*/{Protheus.doc} PLMNG001
Progama destinado a configuracao de e-mails podendo ser customizado
por rotina
/*/
Function PLMNG001()

	Local oBrwCfg := NIL

	oBrwCfg := FWmBrowse():New()
	oBrwCfg:SetAlias( "BZD" )
	oBrwCfg:SetDescription("Gerenciador de Contas de E-mail")
	oBrwCfg:SetUseFilter(.T.)
	oBrwCfg:SetUseCaseFilter(.T.)
	oBrwCfg:Activate()

Return

/////////////////////////////////////////////////////////
/*/{Protheus.doc} MenuDef
Menu de opcoes
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Visualizar" Action "VIEWDEF.PLMNG001" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    Action "VIEWDEF.PLMNG001" OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    Action "VIEWDEF.PLMNG001" OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    Action "VIEWDEF.PLMNG001" OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Imprimir"   Action "VIEWDEF.PLMNG001" OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title "Copiar"     Action "VIEWDEF.PLMNG001" OPERATION 9 ACCESS 0

Return aRotina

/////////////////////////////////////////////////////////
/*/{Protheus.doc} ModelDef
/*/
Static Function ModelDef()

	STATIC oModel := NIL

	// Cria o objeto do Modelo de Dados
	Local oStrBZD  := FWFormStruct(1,"BZD")
	Local oStrBZF  := FWFormStruct(1,"BZF")

	lExistBZF := Len(oStrBZF:aFields) > 0
	oStrBZF:SetProperty("BZF_FUNCFG",MODEL_FIELD_OBRIGAT,.T.)
	oModel := MPFormModel():New("PLMNG001",, {|oModel|ValidaPos(oModel)})
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "BZDMASTER", NIL, oStrBZD )
	oModel:SetPrimaryKey( { "BZD_FILIAL", "BZD_ID" } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( "Configuração" )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( "BZDMASTER" ):SetDescription( "Gerenciador de contas de e-mail genérico")

	oModel:addGrid("BZFDETAIL","BZDMASTER",oStrBZF)
	oModel:SetRelation("BZFDETAIL", { { "BZF_FILIAL", "xFilial( 'BZF' )"  }, { "BZF_IDBZD", "BZD_ID" } }, BZF->(IndexKey(1)) )
	oModel:GetModel( "BZFDETAIL" ):SetDescription( "Configuração x Rotina" ) 
	oModel:GetModel( "BZFDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "BZFDETAIL" ):SetUniqueLine( {"BZF_FUNCFG"} )
	
Return oModel

/////////////////////////////////////////////////////////
/*/{Protheus.doc} ViewDef
/*/
Static Function ViewDef()  

	// Cria a estrutura a ser usada na View
	Local oStrBZF := FWFormStruct( 2, "BZF" )

	// Cria a estrutura a ser usada na View
	Local oModel   := FWLoadModel( "PLMNG001" )
	Local oStruBZD := FWFormStruct(2, "BZD")
	Local oView    := FWFormView():New()

	// Define qual o Modelo de dados será utilizado

	oView:SetModel( oModel )
	oView:AddField("VIEW_BZD" , oStruBZD,"BZDMASTER" )
	oView:AddGrid("VIEW_BZF" , oStrBZF,"BZFDETAIL")

	oView:CreateHorizontalBox( "BOX1", 50)
	oView:CreateVerticalBox( "FORMBZD", 100, "BOX1")
	oView:CreateHorizontalBox( "BOX4", 50)
	oView:CreateFolder( "FOLDER5", "BOX4")

	oView:AddSheet("FOLDER5","BZFDETAIL","Função x Configuração")

	oView:CreateHorizontalBox( "FORMBZF", 100, /*owner*/, /*lUsePixel*/, "FOLDER5", "BZFDETAIL")

	oStruBZD:AddGroup( "GRUPO01"     , "Dados da Configuração", "", 3  )
	oStruBZD:SetProperty("BZD_ID"    , MVC_VIEW_GROUP_NUMBER, "GRUPO01")
	oStruBZD:SetProperty("BZD_TITCFG", MVC_VIEW_GROUP_NUMBER, "GRUPO01")
	
	oStruBZD:AddGroup( "GRUPO02", "Configuração Para Logar na Conta", "", 3)
	oStruBZD:SetProperty("BZD_USUARI", MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_SENHA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_REMTNT", MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_SMTP"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_PORTA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_TLS"   , MVC_VIEW_GROUP_NUMBER, "GRUPO02")
	oStruBZD:SetProperty("BZD_SSL"   , MVC_VIEW_GROUP_NUMBER, "GRUPO02")

	oStruBZD:AddGroup("GRUPO03", "Dados de Autenticação", "", 3)
	oStruBZD:SetProperty("BZD_AUTENT", MVC_VIEW_GROUP_NUMBER, "GRUPO03")
	oStruBZD:SetProperty("BZD_USUAUT", MVC_VIEW_GROUP_NUMBER, "GRUPO03")
	oStruBZD:SetProperty("BZD_SENAUT", MVC_VIEW_GROUP_NUMBER, "GRUPO03")

	oStruBZD:AddGroup("GRUPO04", "Configuração de Envio", "", 3)
	oStruBZD:SetProperty("BZD_REMTNT", MVC_VIEW_GROUP_NUMBER, "GRUPO04")
	oStruBZD:SetProperty("BZD_SMTP"  , MVC_VIEW_GROUP_NUMBER, "GRUPO04")
	oStruBZD:SetProperty("BZD_PORTA" , MVC_VIEW_GROUP_NUMBER, "GRUPO04")
	oStruBZD:SetProperty("BZD_TLS"   , MVC_VIEW_GROUP_NUMBER, "GRUPO04")
	oStruBZD:SetProperty("BZD_SSL"   , MVC_VIEW_GROUP_NUMBER, "GRUPO04")

	oStruBZD:AddGroup( "GRUPO05", "Dados do E-mail", "", 3 )
	oStruBZD:SetProperty( "BZD_ASSUNT", MVC_VIEW_GROUP_NUMBER, "GRUPO05")
	oStruBZD:SetProperty( "BZD_FUNCAO", MVC_VIEW_GROUP_NUMBER, "GRUPO05")
	oStruBZD:SetProperty( "BZD_HTML"  , MVC_VIEW_GROUP_NUMBER, "GRUPO05")

	oView:SetOwnerView("VIEW_BZD","FORMBZD")
	oView:SetOwnerView("VIEW_BZF","FORMBZF")

	// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_BZF", "BZF_ID" )

Return oView

/////////////////////////////////////////////////////////
/*/{Protheus.doc} ValidMail
Valida o email informado esta no formato correto
/*/
Function ValidMail(cEmail)

	Local lRerMail := .T.
	Default cEmail := ""

	If !IsEmail(cEmail)
		lRerMail := .F.
		Help( ,, "Email" ,, "O e-mail não está no formato correto (Exemplo@exemplo.com)", 1,0)
	EndIf
	
Return lRerMail

////////////////////////////////////////////////
/*/{Protheus.doc} ValidaPos
Validacoes pos confirmação do modelo
/*/
Static Function ValidaPos(oCfgModel)

	Local lRetPos := .T.
	
	lRetPos := VldCmpAut(oCfgModel)

	If lRetPos	
		lRetPos := CriptSenha(oCfgModel)
	EndIf

Return lRetPos

////////////////////////////////////////////////
/*/{Protheus.doc} CriptSenha
Criptografa a senha do e-mail
/*/
Static Function CriptSenha(oCfgModel)

	Local cSenhaCprt  := ""
	Local lRetCript   := .T.
	Default oCfgModel := NIL

	If oCfgModel:GetModel("BZDMASTER"):IsFieldUpdated("BZD_SENHA")

		cSenhaCprt := FWAES_encrypt(alltrim(oCfgModel:GetModel("BZDMASTER"):GetValue("BZD_SENHA")))
		
		If !oCfgModel:GetModel("BZDMASTER"):SetValue("BZD_SENHA",cSenhaCprt )
			lRetCript := .F.
			Help( ,, "Senha" ,, "Não foi possível criptografar a senha, tente novamente.", 1,0)
		EndIf
	EndIf

	If oCfgModel:GetModel("BZDMASTER"):IsFieldUpdated("BZD_SENAUT")

		cSenhaCprt := FWAES_encrypt(alltrim(oCfgModel:GetModel("BZDMASTER"):GetValue("BZD_SENAUT")))
		
		If !oCfgModel:GetModel("BZDMASTER"):SetValue("BZD_SENAUT",cSenhaCprt )
			lRetCript := .F.
			Help( ,, "Senha" ,, "Não foi possível criptografar a senha, tente novamente.", 1,0)
		EndIf
	EndIf
	
Return lRetCript

/////////////////////////////////////////////////////////////////
/*/{Protheus.doc} VldCmpAut
Caso o campo de autenticação esteja como sim, o sitema obriga 
a preenhcer os dados de autenticação
/*/
Static Function VldCmpAut(oCfgModel)

	Local lRetVld     := .T.
	Default oCfgModel := NIL

	If oCfgModel:GetModel("BZDMASTER"):GetValue("BZD_AUTENT") == "1" //Sim

		If Empty(oCfgModel:GetModel("BZDMASTER"):GetValue("BZD_USUAUT")) .OR. ;
		   Empty(oCfgModel:GetModel("BZDMASTER"):GetValue("BZD_SENAUT"))

			lRetVld := .F.
			
			Help( ,, "Autentica" ,, "É obrigatório informar o usuário de autenticação e a senha/token de autenticação", 1,0)
		EndIf
	EndIf
	
Return lRetVld
