#INCLUDE "WFC003.ch" 
#include "SIGAWF.CH"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"

PUBLISH MODEL REST NAME WFC003 SOURCE WFC003

//-------------------------------------------------------------------
/*/{Protheus.doc} WFC003

CADASTRO DE E-MAILS DO WORKFLOW - Funcao principal do cadastro de e-mail do workflow

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------

Function WFC003()

	Private oMark 
		
	oMark := FWMarkBrowse():New() 
	 
	//Definição da tabela a ser utilizada 
	oMark:SetAlias('WF7') 
	
	//Habilita o semáforo
	oMark:SetSemaphore(.T.)
	 
	// Define a legenda  
	oMark:AddLegend("WF7_ATIVO", "GREEN" ) 
	oMark:AddLegend("!WF7_ATIVO", "RED") 
	  
	// Ativação da classe 
	oMark:Activate() 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função de criação do menu de opções da rotina

@author Henrique Makauskas
@since 07/07/2014
@version P12
@param aRot Array com as definições das opções do menu da rotina
@return aRot Retornar o array preenchido com as suas definições

/*/
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRot := {}
	
	ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_PESQUISAR 	ACCESS 0 //"Pesquisar"
	ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_VISUALIZAR 	ACCESS 0 //"Visualizar"
	ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_INCLUIR 	ACCESS 0 //"Incluir"
	ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_ALTERAR 	ACCESS 0 //"Alterar"
	ADD OPTION aRot TITLE STR0006 ACTION 'VIEWDEF.WFC003' 	OPERATION WF_EXCLUIR 	ACCESS 0 //"Excluir"
	ADD OPTION aRot TITLE STR0007 ACTION 'WF3SndMsg' 		OPERATION 6 				ACCESS 0 //"Enviar"
	ADD OPTION aRot TITLE STR0008 ACTION 'WF3SndAllMsg' 		OPERATION 7 				ACCESS 0 //"Enviar Todos"
	ADD OPTION aRot TITLE STR0009 ACTION 'WF3RcvMsg' 		OPERATION 8 				ACCESS 0 //"Receber"
	ADD OPTION aRot TITLE STR0010 ACTION 'WF3RcvAllMsg' 		OPERATION 9 				ACCESS 0 //"Receber Todos"

Return aRot

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função de criação da interface

@author Henrique Makauskas
@since 07/07/2014
@version P12
@return oView Objeto da interface da aplicação

/*/
//-------------------------------------------------------------------

Static Function ViewDef

	// Criação do objeto do modelo de dados da Interface
	Local oModel := FWLoadModel("WFC003")
	
	// Criação da estrutura de dados utilizada na interface
	Local oStWF7 := FWFormStruct( 2 , "WF7")	
	Local oView := Nil
	
	// Protocolo configurado no .INI (POP3 ou IMAP)
	Local cProtocol := WFGetProtocol()[2]
	
	// Array de opções para campo WF7_SMTPSE
	Local aSmtpse := {STR0066,STR0067,STR0068}
	
	// Campos virtuais de OAuth 2.0 (DSERBA1-18680) na estrutura de VIEW.
	// FWFormStruct(2,'WF7') monta a view a partir do SX3 e, como estes campos
	// nao existem no dicionario, precisam ser adicionados aqui - caso contrario
	// os SetProperty (grupo/combo/lookup) abaixo nao encontram o campo e nada e
	// renderizado. A adicao fica isolada em WF3AddVwFld.
	// Trava por ambiente (WF3OAuthOn): so renderiza quando WF_OAUTH2_ACTIVE=1.
	If WF3OAuthOn()
		WF3AddVwFld(oStWF7)
	EndIf

	// Cria o objeto da View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_WF7', oStWF7, 'FORMWF7')
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_WF7','TELA')

	// Botao de Consentimento do usuario OAuth 2.0 (DSERBA1-18680).
	// Disponivel apenas em Inclusao/Alteracao; a acao (WF3Consent) valida o
	// contexto (tipo OAuth 2.0 + ID do provedor) e aciona o consentimento do
	// Framework. Fora de transacao - nao conflita com a regra "sem UI em transacao".
	// Trava por ambiente (WF3OAuthOn): so adiciona quando WF_OAUTH2_ACTIVE=1.
	// If WF3OAuthOn()
	// 	oView:AddUserButton( STR0122, "", {|| WF3Consent() }, STR0122, , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )
	// EndIf
	
	// Cria os grupos para agrupamentos de campos
	oStWF7:AddGroup( 'CaixaCorreio', STR0030, 'TELA', 2 )
	oStWF7:AddGroup( 'Remetente', STR0034, 'TELA', 1 )
	oStWF7:AddGroup( 'ReceberMensagens', STR0016 + " (" + cProtocol + ")", 'TELA', 2 )
	oStWF7:AddGroup( 'Login', STR0040, 'TELA', 1 )
	oStWF7:AddGroup( 'EnviarMensagens', STR0013, 'TELA', 2 )
	oStWF7:AddGroup( 'Autenticacao', STR0046, 'TELA', 1 ) 
	oStWF7:AddGroup( 'Seguranca', STR0065, 'TELA', 1 )
	
	// Agrupamento  - Caixa de Correio 
	oStWF7:SetProperty( 'WF7_PASTA', MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_TEMPO' , MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_REMETE', MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' ) 
	oStWF7:SetProperty( 'WF7_ENDERE' , MVC_VIEW_GROUP_NUMBER, 'CaixaCorreio' )
	// Sub Grupo - Remetente
	oStWF7:SetProperty( 'WF7_REMETE', MVC_VIEW_GROUP_NUMBER, 'Remetente' ) 
	oStWF7:SetProperty( 'WF7_ENDERE' , MVC_VIEW_GROUP_NUMBER, 'Remetente' ) 
	 
	// Agrupamento  - Receber Mensagens 
	If (cProtocol == "IMAP")		
		oStWF7:SetProperty( 'WF7_IMAPPR', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
		oStWF7:SetProperty( 'WF7_IMAPSR' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )
		oStWF7:RemoveField('WF7_POP3SR')
		oStWF7:RemoveField('WF7_POP3PR')			
	Else // Padrão - POP3		
		oStWF7:SetProperty( 'WF7_POP3SR', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
		oStWF7:SetProperty( 'WF7_POP3PR' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )		
		oStWF7:RemoveField('WF7_IMAPPR')
		oStWF7:RemoveField('WF7_IMAPSR')	
	End
	oStWF7:SetProperty( 'WF7_CONTA', MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' ) 
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_GROUP_NUMBER, 'ReceberMensagens' )
	//Sub Grupo - Login
	oStWF7:SetProperty( 'WF7_CONTA', MVC_VIEW_GROUP_NUMBER, 'Login' ) 
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_GROUP_NUMBER, 'Login' )
	
	// Agrupamento  - Enviar mensagens
	oStWF7:SetProperty( 'WF7_SMTPSR', MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_SMTPPR' , MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_AUTUSU', MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' ) 
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_GROUP_NUMBER, 'EnviarMensagens' )
	// Sub Grupo - Autenticação
	oStWF7:SetProperty( 'WF7_AUTUSU', MVC_VIEW_GROUP_NUMBER, 'Autenticacao' ) 
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_GROUP_NUMBER, 'Autenticacao' )
	// Sub Grupo - Autenticação - Campos virtuais OAuth 2.0 (DSERBA1-18680)
	// Trava por ambiente (WF3OAuthOn): posiciona/combo/lookup so quando ativo.
	If WF3OAuthOn()
		oStWF7:SetProperty( 'TYPE_AUTH' , MVC_VIEW_GROUP_NUMBER, 'Autenticacao' )
		oStWF7:SetProperty( 'ID_PROV'   , MVC_VIEW_GROUP_NUMBER, 'Autenticacao' )
	EndIf
	// Sub Grupo - Protocolo de Segurança	
	oStWF7:SetProperty( 'WF7_SMTPSE' , MVC_VIEW_GROUP_NUMBER, 'Seguranca' )
	
	// Transformação dos campos de senha e ComboBox	
	oStWF7:SetProperty( 'WF7_SMTPSE' , MVC_VIEW_COMBOBOX, aSmtpse )
	oStWF7:SetProperty( 'WF7_SENHA' , MVC_VIEW_PICT, '@*' )
	oStWF7:SetProperty( 'WF7_AUTSEN' , MVC_VIEW_PICT, '@*' )

	// Combo e F3 dos campos virtuais OAuth 2.0 (DSERBA1-18680) - so quando ativo.
	If WF3OAuthOn()

		// Combo do Tipo de Autenticação. WF3AuthCbo retorna o array no formato
		// "codigo=descricao" ("basic=..." / "oauth2=..."), fazendo o combo gravar
		// diretamente a string do contrato (basic/oauth2) no campo TYPE_AUTH.
		oStWF7:SetProperty( 'TYPE_AUTH' , MVC_VIEW_COMBOBOX, WF3AuthCbo() )

		// Consulta (F3) do ID do Provedor oAuth. WF3LoadProv cria a consulta
		// "_lookup_provider" em memoria (obrigatorio ANTES de vincular o F3). Se o
		// recurso do Framework nao estiver disponivel, a tela abre sem o F3.
		// If WF3LoadProv()
		// 	oStWF7:SetProperty( 'ID_PROV' , MVC_VIEW_LOOKUP, "_lookup_provider" )
		// EndIf

	EndIf
		
	//Campos não utilizados
	oStWF7:RemoveField('WF7_DTELEF')
	oStWF7:RemoveField('WF7_MAPISR')
	oStWF7:RemoveField('WF7_MAPIPR')	
	oStWF7:RemoveField('WF7_TCONEX')
	oStWF7:RemoveField('WF7_DNOME')
	oStWF7:RemoveField('WF7_DCONTA')
	oStWF7:RemoveField('WF7_DSENHA')
	oStWF7:RemoveField('WF7_SSL')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3AddVwFld

Adiciona os campos virtuais de OAuth 2.0 (TYPE_AUTH e ID_PROV) a estrutura
de VIEW (DSERBA1-18680). Isolado em Static Function para nao inserir o
AddField multi-linha diretamente sob o If da trava por ambiente na ViewDef.
Os campos nao existem no SX3; sao 100% runtime, marcados como virtuais.

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param oStWF7 Estrutura de view (FWFormViewStruct) da WF7
@return Nil

/*/
//-------------------------------------------------------------------
Static Function WF3AddVwFld(oStWF7)

	oStWF7:AddField( ;
		'TYPE_AUTH'   , ; // [01] C Nome do campo (ID)
		'26'          , ; // [02] C Ordem
		STR0118       , ; // [03] C Titulo ("Tipo Autent.")
		STR0118       , ; // [04] C Descricao
		Nil           , ; // [05] A Array de help
		'C'           , ; // [06] C Tipo do campo
		'@!'          , ; // [07] C Picture
		Nil           , ; // [08] B Bloco de Picture Var
		Nil           , ; // [09] C Consulta F3
		.T.           , ; // [10] L Indica se o campo e alteravel
		Nil           , ; // [11] C Pasta do campo
		Nil           , ; // [12] C Agrupamento do campo
		Nil           , ; // [13] A Lista de valores permitidos (Combo)
		Nil           , ; // [14] N Tamanho maximo da maior opcao do combo
		Nil           , ; // [15] C Inicializador de Browse
		.T.             ) // [16] L Indica se o campo e virtual

	oStWF7:AddField( ;
		'ID_PROV'     , ; // [01] C Nome do campo (ID)
		'27'          , ; // [02] C Ordem
		STR0119       , ; // [03] C Titulo ("ID Provedor")
		STR0119       , ; // [04] C Descricao
		Nil           , ; // [05] A Array de help
		'C'           , ; // [06] C Tipo do campo
		'@!'          , ; // [07] C Picture
		Nil           , ; // [08] B Bloco de Picture Var
		Nil           , ; // [09] C Consulta F3
		.T.           , ; // [10] L Indica se o campo e alteravel
		Nil           , ; // [11] C Pasta do campo
		Nil           , ; // [12] C Agrupamento do campo
		Nil           , ; // [13] A Lista de valores permitidos (Combo)
		Nil           , ; // [14] N Tamanho maximo da maior opcao do combo
		Nil           , ; // [15] C Inicializador de Browse
		.T.             ) // [16] L Indica se o campo e virtual

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função de criação do modelo de dados

@author Henrique Makauskas
@since 07/07/2014
@version P12
@param aRot Array com as definições das opções do menu da rotina
@return oModel Objeto da interface da aplicação

/*/
//-------------------------------------------------------------------

Static Function ModelDef

	// Criação do objeto do modelo de dados
	Local oStWF7 := FWFormStruct( 1 , 'WF7')
	Local oModel := Nil
	
	// Campos virtuais de OAuth 2.0 (DSERBA1-18680) - declarados 100% em runtime,
	// sem qualquer entrada no dicionario de dados (SX3). Os IDs coincidem com as
	// chaves do JSON persistido no cofre (TYPE_AUTH / ID_PROV), evitando traducao
	// entre a tela e o cofre. Tamanhos conforme contrato do Framework oAuth.
	// Trava por ambiente (WF3OAuthOn): so declara os campos quando o recurso
	// estiver liberado no .ini (WF_OAUTH2_ACTIVE=1); caso contrario, a rotina
	// se comporta exatamente como antes da feature.
	If WF3OAuthOn()

	// [01] Tipo de Autenticacao - combo Basic / OAuth 2.0 (valor: basic / oauth2)
	oStWF7:AddField( ;
		STR0118        , ; // [01] C Titulo do campo ("Tipo Autent.")
		STR0118        , ; // [02] C ToolTip do campo
		'TYPE_AUTH'    , ; // [03] C Identificador (ID) do campo
		'C'            , ; // [04] C Tipo do campo
		6              , ; // [05] N Tamanho do campo
		0              , ; // [06] N Decimal do campo
		Nil            , ; // [07] B Code-block de validacao do campo
		Nil            , ; // [08] B Code-block de validacao When do campo
		Nil                        , ; // [09] A Lista de valores permitidos do campo
		.F.                        , ; // [10] L Indica se o campo tem preenchimento obrigatorio
		{|oMdl| WF3GetAuth(oMdl) } , ; // [11] B Code-block de inicializacao (carga do cofre)
		.F.                        , ; // [12] L Indica se trata de um campo chave
		.T.                        , ; // [13] L Indica se o campo pode receber valor em update
		.T.                          ) // [14] L Indica se o campo e virtual

	// [02] ID do Provedor oAuth - consulta _lookup_provider (SYS_OAUTH_PROVIDER)
	oStWF7:AddField( ;
		STR0119        , ; // [01] C Titulo do campo ("ID Provedor")
		STR0119        , ; // [02] C ToolTip do campo
		'ID_PROV'      , ; // [03] C Identificador (ID) do campo
		'C'            , ; // [04] C Tipo do campo
		6              , ; // [05] N Tamanho do campo
		0              , ; // [06] N Decimal do campo
		Nil            , ; // [07] B Code-block de validacao do campo
		Nil            , ; // [08] B Code-block de validacao When do campo
		Nil                        , ; // [09] A Lista de valores permitidos do campo
		.F.                        , ; // [10] L Indica se o campo tem preenchimento obrigatorio
		{|oMdl| WF3GetProv(oMdl) } , ; // [11] B Code-block de inicializacao (carga do cofre)
		.F.                        , ; // [12] L Indica se trata de um campo chave
		.T.                        , ; // [13] L Indica se o campo pode receber valor em update
		.T.                          ) // [14] L Indica se o campo e virtual

	// Comportamento dinamico do campo Senha (DSERBA1-18680): a senha (Basic) so
	// fica habilitada quando o Tipo de Autenticacao e Basic. A regra e delegada a
	// WF3IsBasic (Static Function testavel), que recebe a string do contrato
	// gravada em TYPE_AUTH (basic/oauth2). Tipo vazio (registro legado) e tratado
	// como Basic. Nao se usa RemoveField pois a decisao muda durante a edicao.
	oStWF7:SetProperty( 'WF7_SENHA', MODEL_FIELD_WHEN, {|oMdl| WF3IsBasic(oMdl:GetValue('TYPE_AUTH')) } )

	// Comportamento dinamico dos campos de autenticacao de ENVIO (SMTP) x OAuth 2.0
	// (DSERBA1-18680), conforme o Tipo de Autenticacao selecionado em TYPE_AUTH:
	//   - Basic     : Usuario/Senha SMTP (WF7_AUTUSU/WF7_AUTSEN) habilitados;
	//                 ID do Provedor (ID_PROV) desabilitado.
	//   - OAuth 2.0 : Usuario/Senha SMTP desabilitados; ID do Provedor habilitado.
	// A decisao reutiliza WF3IsBasic (Static Function testavel) que le a string do
	// contrato (basic/oauth2). Tipo vazio (registro legado) e tratado como Basic.
	// Usa-se MODEL_FIELD_WHEN (nao RemoveField) porque a decisao muda durante a
	// edicao, acompanhando a troca do combo pelo usuario.
	oStWF7:SetProperty( 'WF7_AUTUSU', MODEL_FIELD_WHEN, {|oMdl|  WF3IsBasic(oMdl:GetValue('TYPE_AUTH')) } )
	oStWF7:SetProperty( 'WF7_AUTSEN', MODEL_FIELD_WHEN, {|oMdl|  WF3IsBasic(oMdl:GetValue('TYPE_AUTH')) } )
	oStWF7:SetProperty( 'ID_PROV'  , MODEL_FIELD_WHEN, {|oMdl| !WF3IsBasic(oMdl:GetValue('TYPE_AUTH')) } )

	// Libera edicao dos campos VIRTUAIS de OAuth 2.0 em ALTERACAO (DSERBA1-18680).
	// Por padrao, o MVC marca campo virtual como nao-atualizavel em update
	// (MODEL_FIELD_NOUPD implicitamente .T.), o que travava o combo TYPE_AUTH e o
	// ID_PROV ao Alterar uma conta ja existente - impedindo, por exemplo, trocar de
	// Basic para OAuth 2.0. Setando NOUPD como .F. os campos passam a aceitar edicao
	// em update; a habilitacao continua governada pelo MODEL_FIELD_WHEN (TYPE_AUTH
	// sempre editavel; ID_PROV somente quando o tipo for OAuth 2.0).
	oStWF7:SetProperty( 'TYPE_AUTH', MODEL_FIELD_NOUPD, .F. )
	oStWF7:SetProperty( 'ID_PROV'  , MODEL_FIELD_NOUPD, .F. )

	EndIf

	oModel:=MPFormModel():New('WFC003', /*Bloco Pre*/, /*Bloco Pos*/, /*Bloco Commit*/)
	If WF3OAuthOn()
		oModel:=MPFormModel():New('WFC003', /*Bloco Pre*/, /*Bloco Pos*/, {|oMdl| WFC003Commit(oMdl)})
	EndIf
	oModel:AddFields('FORMWF7',/*cOwner*/, oStWF7 )
	oModel:SetDescription(STR0001)
	oModel:GetModel('FORMWF7'):SetDescription(STR0001)

	// Carga dos campos virtuais de OAuth 2.0 na ativacao do modelo (DSERBA1-18680).
	// Campos virtuais (TYPE_AUTH/ID_PROV) NAO possuem coluna fisica na WF7, logo o
	// framework nao os recarrega em Alteracao/Visualizacao - o code-block de init
	// tem semantica de Inclusao. Sem esta carga, GetValue('TYPE_AUTH') retorna vazio
	// quando os blocos MODEL_FIELD_WHEN sao avaliados em Alteracao, o que travava a
	// edicao dos campos de autenticacao. O SetActivate le o cofre e popula os campos
	// via LoadValue ANTES da avaliacao dos When (padrao de carga usado em telas MVC
	// com campos virtuais). Trava por ambiente (WF3OAuthOn).
	If WF3OAuthOn()
		oModel:SetActivate( {|oMdl| WF3Activate(oMdl) } )
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3Activate

Carga dos campos virtuais de OAuth 2.0 (TYPE_AUTH e ID_PROV) na ativacao
do modelo (DSERBA1-18680). Como sao campos virtuais (sem coluna fisica na
WF7), o framework nao os recarrega automaticamente em Alteracao/Visualizacao.
Esta funcao le os valores do cofre (via WF3GetAuth/WF3GetProv) e os aplica
ao submodelo FORMWF7 com LoadValue, garantindo que TYPE_AUTH tenha valor
ANTES de os code-blocks MODEL_FIELD_WHEN dos campos de autenticacao serem
avaliados - caso contrario, GetValue('TYPE_AUTH') retornaria vazio em
Alteracao e a habilitacao dos campos ficaria incorreta.

So executa em operacoes que abrem um registro existente (Alteracao e
Visualizacao); na Inclusao o proprio code-block de init ja cuida do valor
default. Usa LoadValue (nao SetValue) por ser carga interna do modelo, que
nao dispara validacoes/gatilhos de edicao do usuario.

@type Static Function
@author Victor Vieira
@since 09/09/2026
@version P12
@param oModel Objeto do modelo MVC (MPFormModel)
@return Nil

/*/
//-------------------------------------------------------------------
Static Function WF3Activate(oModel)

	Local oFormWF7 := Nil As Object
	Local nOper    := 0   As Numeric

	nOper := oModel:GetOperation()

	// Somente em Alteracao e Visualizacao (registro existente). Na Inclusao o
	// init do campo virtual ja retorna o default ("basic").
	If nOper == MODEL_OPERATION_UPDATE .Or. nOper == MODEL_OPERATION_VIEW

		oFormWF7 := oModel:GetModel('FORMWF7')

		// Le do cofre e popula os campos virtuais antes da avaliacao dos When
		oFormWF7:LoadValue( 'TYPE_AUTH', WF3GetAuth(oFormWF7) )
		oFormWF7:LoadValue( 'ID_PROV'  , WF3GetProv(oFormWF7) )

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3AuthCbo

Retorna o array de rotulos do combo de Tipo de Autenticacao usado no
campo virtual TYPE_AUTH da ViewDef. A ordem dos rotulos define a
posicao persistida pelo combo MVC e deve ser mantida em sincronia com
as funcoes de conversao WF3AuthVal (posicao -> valor) e WF3AuthPos
(valor -> posicao).

Posicao 1 = Basic Authentication (valor de contrato "basic")
Posicao 2 = OAuth 2.0            (valor de contrato "oauth2")

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@return aCombo Array de caracteres com os rotulos do combo

/*/
//-------------------------------------------------------------------
Static Function WF3AuthCbo()
// Formato "codigo=descricao": o combo grava o CODIGO (basic/oauth2) no campo e
// exibe a descricao. Assim o campo TYPE_AUTH armazena diretamente a string do
// contrato do Framework oAuth, sem conversao de posicao.
Return { "basic=" + STR0120, "oauth2=" + STR0121 } //"Basic Authentication" / "OAuth 2.0"

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3SafeKey

Monta a chave unica do cofre para uma caixa de correio do Workflow,
identica a composicao usada na gravacao (WFC003Commit): empresa | filial
da WF7 | pasta. Centralizar aqui garante que gravacao e leitura usem
exatamente a mesma chave (restricao do FWSafeVault).

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param cPasta Caixa de correio (WF7_PASTA)
@return cKey  Chave do cofre em maiusculas

/*/
//-------------------------------------------------------------------
Static Function WF3SafeKey(cPasta)

	Default cPasta := ""

Return Upper(AllTrim(cEmpAnt +'|'+ xFilial('WF7') +'|'+ AllTrim(cPasta)))

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3GetAuth

Code-block de inicializacao do campo virtual TYPE_AUTH: ao abrir a conta
(Alteracao/Visualizacao), le o Tipo de Autenticacao do cofre e retorna a
string do contrato (basic/oauth2), que o combo usa como codigo. Conta sem
entrada no cofre (registro legado) retorna "basic", conforme edge case da
spec. A leitura e centralizada em WFSafe (restricao de pilha do cofre:
quem grava deve ler).

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param oMdl Objeto do submodelo MVC (FORMWF7)
@return cValue Tipo de autenticacao ("basic" default, ou "oauth2")

/*/
//-------------------------------------------------------------------
Static Function WF3GetAuth(oMdl)

	Local cKey   := "" As Character
	Local cValue := "" As Character

	cKey   := WF3SafeKey(oMdl:GetValue('WF7_PASTA'))
	cValue := WFSafe(cKey, 'TYPE_AUTH', 'GET')

	// Registro legado sem entrada no cofre assume Basic
	If Empty(cValue)
		cValue := "basic"
	EndIf

Return cValue

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3GetProv

Code-block de inicializacao do campo virtual ID_PROV: ao abrir a conta
(Alteracao/Visualizacao), le o ID do Provedor do cofre. Conta sem entrada
no cofre retorna vazio. Leitura centralizada em WFSafe (mesma chave da
gravacao).

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param oMdl Objeto do submodelo MVC (FORMWF7)
@return cIdProv ID do provedor armazenado, ou "" se inexistente

/*/
//-------------------------------------------------------------------
Static Function WF3GetProv(oMdl)

	Local cKey := "" As Character

	cKey := WF3SafeKey(oMdl:GetValue('WF7_PASTA'))

Return WFSafe(cKey, 'ID_PROV', 'GET')

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3OAuthOn

Feature flag do recurso OAuth 2.0 do Workflow (DSERBA1-18680). Le a chave
WF_OAUTH2_ACTIVE da secao [General] do appserver.ini (arquivo do ambiente
em uso, obtido via GetAdv97). O recurso so e liberado quando a chave vale
"1"; o default e "0" (inativo), de modo que ambientes sem a chave configurada
NAO exibem os campos/combo/lookup/botao de OAuth 2.0 - a trava por ambiente.

Exemplo no appserver.ini, secao [General]:
  WF_OAUTH2_ACTIVE=1   ; 0=Inativo (default), 1=Ativo

@type Function
@author Victor Vieira
@since 04/09/2026
@version P12
@return lOn .T. somente quando a chave estiver definida como "1"

/*/
//-------------------------------------------------------------------
Function WF3OAuthOn()

	Local cValue := "" As Character

	// Le do appserver.ini do ambiente em uso; default "0" (inativo) quando ausente
	cValue := GetPvProfString("General", "WF_OAUTH2_ACTIVE", "0", GetAdv97())

Return AllTrim(cValue) == "1"

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3IsBasic

Regra de decisao que indica se o Tipo de Autenticacao corrente e Basic.
Isolada em Static Function para ser testavel via StaticCall (AdvPR) e
reutilizada pelo code-block When do campo de Senha. O campo TYPE_AUTH
armazena diretamente a string do contrato (basic/oauth2), gravada pelo
combo. Tipo vazio (registro legado) e tratado como Basic, conforme edge
case da spec.

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param cValue Valor do Tipo de Autenticacao ("basic"/"oauth2")
@return lBasic .T. quando o tipo e Basic (ou vazio/legado)

/*/
//-------------------------------------------------------------------
Static Function WF3IsBasic(cValue)

	Local lBasic := .T. As Logical

	Default cValue := ""

	If Lower(AllTrim(cValue)) == "oauth2"
		lBasic := .F.
	EndIf

Return lBasic

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3LoadProv

Cria em memoria a consulta padrao de provedores oAuth ("_lookup_provider")
do Framework, chamando totvs.framework.oauth.common.lookup_provider(). A
consulta nao existe fisicamente no dicionario (SXB); precisa ser criada em
runtime ANTES de ser vinculada ao F3 do campo ID do Provedor.

O recurso depende da LIB do Framework oAuth. Caso indisponivel, a falha e
tratada (Try/Catch) e registrada via FWLogMsg, e a rotina segue sem o F3 -
a tela abre normalmente, apenas sem a consulta (edge case previsto na spec).

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@return lOk .T. se a consulta foi criada e pode ser vinculada ao F3

/*/
//-------------------------------------------------------------------
// Static Function WF3LoadProv()

// 	Local lOk       := .T. As Logical
// 	Local bErrorBkp := ErrorBlock( {|oErr| Break(oErr) } )

// 	// Fonte AdvPL (.PRW): Try/Catch e exclusivo do TLPP. O padrao de protecao
// 	// aqui e ErrorBlock -> Break capturado por Begin Sequence / Recover Using.
// 	Begin Sequence

// 		// Cria a consulta dinamica em memoria (obrigatorio antes de vincular o F3)
// 		totvs.framework.oauth.common.lookup_provider()

// 	Recover

// 		// Recurso indisponivel nesta versao do Framework
// 		lOk := .F.
// 		FWLogMsg("WARN", , 'WF3LoadProv', , , , STR0127) //"Recurso de provedores oAuth nao disponivel nesta versao do Framework."

// 	End Sequence

// 	// Restaura o ErrorBlock anterior
// 	ErrorBlock( bErrorBkp )

// 	If !lOk
// 		FWLogMsg("WARN", , 'WF3LoadProv', , , , STR0126) //"Falha ao carregar a consulta de provedores oAuth."
// 	EndIf

// Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3VldCons

Valida o contexto necessario para o consentimento OAuth 2.0, de forma
isolada e testavel (StaticCall/AdvPR), sem depender da tela nem do
Framework. Regras:
  - o Tipo de Autenticacao precisa ser OAuth 2.0;
  - o ID do Provedor precisa estar preenchido.

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@param cTypeAuth Valor do Tipo de Autenticacao ("basic"/"oauth2") OU a
                 posicao numerica do combo (1/2)
@param cIdProv   ID do provedor informado na tela
@return nStatus  0 = contexto valido; 1 = tipo diferente de OAuth 2.0;
                 2 = ID do provedor nao informado

/*/
//-------------------------------------------------------------------
// Static Function WF3VldCons(cTypeAuth, cIdProv)

// 	Local nStatus := 0 As Numeric

// 	Default cTypeAuth := ""
// 	Default cIdProv   := ""

// 	If WF3IsBasic(cTypeAuth)
// 		// Tipo nao e OAuth 2.0 (inclui Basic e legado vazio)
// 		nStatus := 1
// 	ElseIf Empty(AllTrim(cIdProv))
// 		// OAuth 2.0 sem ID de provedor
// 		nStatus := 2
// 	EndIf

// Return nStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3Consent

Acao do botao de Consentimento do usuario (DSERBA1-18680). Le os campos
virtuais do modelo, valida o contexto via WF3VldCons e, se valido,
monta o JSON da conta (contrato do Framework oAuth) e aciona o fluxo de
consentimento totvs.framework.oauth.common.consent().

Escopo desta Story: disponibilizar o consentimento acionavel. A gravacao
dos tokens obtidos (ACCESS_TK/REFRESH_TK/EXPIRES_AT) pertence a US do fluxo
de autenticacao/envio - aqui apenas informamos o sucesso ao usuario.

Executado com a tela em edicao, FORA de transacao - nao ha conflito com a
regra de "sem UI em transacao" (aplicavel ao WFC003Commit).

@type Static Function
@author Victor Vieira
@since 04/09/2026
@version P12
@return lRet .T. se o consentimento foi realizado com sucesso

/*/
//-------------------------------------------------------------------
// Static Function WF3Consent()

// 	Local lRet         := .F.  As Logical
// 	Local oModel       := Nil  As Object
// 	Local oFormWF7     := Nil  As Object
// 	Local jAccount     := Nil  As Json
// 	Local oAuth2Client := Nil  As Object
// 	Local nEvent       := 0    As Numeric
// 	Local cMessage     := ""   As Character
// 	Local cIdProv      := ""   As Character
// 	Local nStatus      := 0    As Numeric

// 	// Obtem o modelo ativo (robusto: independe do que o bloco do botao recebe)
// 	oModel   := FWModelActive()
// 	oFormWF7 := oModel:GetModel('FORMWF7')
// 	cIdProv  := AllTrim(oFormWF7:GetValue('ID_PROV'))

// 	// Validacao de contexto (regra isolada e testavel)
// 	nStatus := WF3VldCons(oFormWF7:GetValue('TYPE_AUTH'), cIdProv)

// 	If nStatus == 1
// 		Help( , , 'WF3Consent', , STR0123, 1, 0 ) //""Selecione o tipo de autenticação OAuth 2.0 para realizar o consentimento"
// 		Return .F.
// 	ElseIf nStatus == 2
// 		Help( , , 'WF3Consent', , STR0124, 1, 0 ) //"Informe o ID do provedor antes de realizar o consentimento."
// 		Return .F.
// 	EndIf

// 	// Monta o JSON da conta conforme contrato do Framework oAuth.
// 	// Esta Story grava apenas Tipo de Autenticacao e ID do Provedor; tokens
// 	// (ACCESS_TK/REFRESH_TK/EXPIRES_AT) sao de outra US - enviados vazios.
// 	jAccount := JsonObject():New()
// 	jAccount["EMAIL"]      := AllTrim(oFormWF7:GetValue('WF7_ENDERE'))
// 	jAccount["ID_PROV"]    := cIdProv
// 	jAccount["TYPE_AUTH"]  := "oauth2"
// 	jAccount["ACCESS_TK"]  := ""
// 	jAccount["REFRESH_TK"] := ""
// 	jAccount["EXPIRES_AT"] := 0
// 	jAccount["PASSWORD"]   := ""
// 	jAccount["MAIL_FROM"]  := ""

// 	// Instancia via Create (nao consulta a SYS_OAUTH_ACCOUNT - modelo multi-contas)
// 	oAuth2Client := totvs.framework.oauth.client():Create(jAccount)

// 	If oAuth2Client:HasError(@nEvent, @cMessage)
// 		totvs.framework.oauth.common.showError(oAuth2Client, "Consent_Error")
// 		FwFreeObj(oAuth2Client)
// 		jAccount := Nil
// 		Return .F.
// 	EndIf

// 	// Aciona o fluxo de consentimento com tela (.T.)
// 	lRet := totvs.framework.oauth.common.consent( , oAuth2Client, .T. )

// 	If lRet
// 		FWAlertSuccess(STR0125) //"Consentimento realizado com sucesso."
// 	Else
// 		totvs.framework.oauth.common.showError(oAuth2Client, "Consent_Error")
// 	EndIf

// 	// Libera recursos (padrao do exemplo oficial do Framework para esta classe)
// 	FwFreeObj(oAuth2Client)
// 	jAccount := Nil

// Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WFC003Commit

Bloco de commit do MVC que intercepta os campos de credenciais do modelo,
persiste os valores sensiveis no cofre seguro (WFSafe) e zera os
campos no modelo antes da gravacao na tabela WF7.

Utiliza uma chave unica por caixa de correio, agrupando todos os campos
de credenciais no cofre. O array aSafeFields passou a ser uma lista de
pares { <chaveNoJSON>, <tamanho>, <lSX3> }: campos reais (existentes no
SX3) sao gravados com PadR no tamanho declarado; os campos virtuais de
OAuth 2.0 (TYPE_AUTH/ID_PROV, DSERBA1-18680) sao gravados com AllTrim,
SEM PadR - padding com espacos a direita quebraria a comparacao das
strings do contrato ("basic"/"oauth2") no fluxo de envio. Isso elimina a
dependencia de TamSX3 para campos que nao existem no dicionario.

@type Static Function
@author Victor Vieira
@since 12/08/2026
@version P12
@param oModel Objeto do modelo MVC (MPFormModel)
@return lRet .T. se o commit foi realizado com sucesso

/*/
//-------------------------------------------------------------------
Static Function WFC003Commit(oModel)

	Local lRet       := .T.
	Local oFormWF7   := oModel:GetModel('FORMWF7')
	Local cSafeKey   := WF3SafeKey(oFormWF7:GetValue('WF7_PASTA'))
	Local aFields    := {}
	// Pares { <chaveJSON>, <tamanho>, <lSX3> }. lSX3 = .T. aplica PadR (campo
	// real do dicionario); lSX3 = .F. grava com AllTrim (campo virtual OAuth 2.0).
	Local aSafeFields := { ;
		{ 'WF7_SENHA' , 100, .T. }, ;
		{ 'WF7_AUTSEN',  50, .T. }, ;
		{ 'WF7_DSENHA',  50, .T. }, ;
		{ 'TYPE_AUTH' ,   6, .F. }, ;
		{ 'ID_PROV'   ,   6, .F. }  ;
	}
	Local cField     := ""
	Local nTam       := 0
	Local lIsSX3     := .T.
	Local cValue     := ""
	Local nI         := 0
	// Trava por ambiente (DSERBA1-18680): lida uma unica vez (nunca dentro do loop).
	// Com o recurso inativo, os campos virtuais nao existem no modelo, entao sao
	// ignorados no loop - o commit processa apenas os campos reais (comportamento
	// original preservado).
	// Local lOAuthOn   := WF3OAuthOn()

	// Itera sobre os campos sensiveis definidos no array.
	// Para cada campo: captura o valor, converte o combo de Tipo de Autenticacao
	// para a string do contrato (basic/oauth2), adiciona ao array do cofre
	// (PadR apenas para campos reais) e zera no modelo os campos reais.
	If oFormWF7:getOperation() != MODEL_OPERATION_DELETE
		For nI := 1 To Len(aSafeFields)

			cField := aSafeFields[nI][1]
			nTam   := aSafeFields[nI][2]
			lIsSX3 := aSafeFields[nI][3]

			// Campos virtuais (OAuth 2.0) so quando o recurso estiver ativo
			If !lIsSX3 
				Loop
			EndIf

			// TYPE_AUTH ja armazena a string do contrato (basic/oauth2), gravada
			// pelo combo no formato "codigo=descricao" - persiste direto.
			cValue := AllTrim(oFormWF7:GetValue(cField))

			If !Empty(cValue)
				If lIsSX3
					aAdd(aFields, {cField, PadR(cValue, nTam)})
				// Else
				// 	aAdd(aFields, {cField, cValue})
				EndIf
			EndIf

			// Zera no modelo apenas os campos reais, para nao persistir na WF7.
			// Campos virtuais nao vao para a tabela e nao devem ser zerados aqui.
			If lIsSX3
				oFormWF7:LoadValue(cField, '')
			EndIf

		Next nI

		// Persiste no cofre seguro se houver campos a proteger
		If Len(aFields) > 0
			WFSafe(cSafeKey, aFields, 'PUT')
		EndIf
	else
		// Se for exclusao, remove a chave do cofre
		WFSafe(cSafeKey, , 'DELETE')	
	EndIf	

	// Executa a gravacao padrao do modelo na tabela WF7
	Begin Transaction
		FWFormCommit(oModel)
	End Transaction

Return lRet

/******************************************************************************
	
******************************************************************************/

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3SndMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3SndMsg()

	Local cMsg := STR0012 //'Deseja enviar mensagens da caixa de correio "%c"?'
	
	If MsgYesNo( FormatStr( cMsg, Upper( AllTrim( WF7->WF7_PASTA ) ) ), STR0013 ) //"Enviar mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFSndMsg", { cEmpAnt, cFilAnt, AllTrim( WF7->WF7_PASTA ), .T. } } )
	End
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3SndAllMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3SndAllMsg()
	
	Local cMsg := STR0014 //"Deseja enviar mensagens para todas as caixas de correio?"
	
	If MsgYesNo( cMsg, STR0013 ) //"Enviar mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFSndMsgAll", { cEmpAnt, cFilAnt } } )
	End
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3RcvMsg

Envia todas as mensagens criadas e que estao na caixa de saida (OUTBOX)
referida conta em que o curso do browser esta posicionado atualmente.

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3RcvMsg()

	Local cMsg := STR0015 //'Deseja receber mensagens da caixa de correio "%c"?'
	
	If MsgYesNo( FormatStr( cMsg, Upper( AllTrim( WF7->WF7_PASTA ) ) ), STR0016 ) //"Receber mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFRcvMsg", { cEmpAnt, cFilAnt, AllTrim( WF7->WF7_PASTA ), .T. } } )
	End
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WF3RcvAllMsg

Recebe as mensagens de todas as conta cadastradas

@author Henrique Makauskas
@since 07/07/2014
@version P12

/*/
//-------------------------------------------------------------------
Function WF3RcvAllMsg()
	
	local cMsg := STR0017 //"Deseja receber mensagens para todas as caixas de correio?"
	
	If MsgYesNo( cMsg, STR0016 ) //"Receber mensagens"
		StartJob( "WFLauncher", GetEnvServer(), .F., { "WFRcvMsgAll", { cEmpAnt, cFilAnt } } )
	End
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WFSafe

Funcao unificada para operacoes no cofre seguro do Protheus (FWSafeVault).
Encapsula as operacoes de gravacao (PUT), recuperacao (GET) e remocao
(DELETE) em um unico ponto de entrada, com validacoes de parametros
e verificacao de existencia da chave no cofre antes de cada operacao.

Recebe a chave (safeKey) e um segundo parametro cujo tipo varia conforme
a operacao. Internamente monta o JSON via WFSafeJson antes de persistir.

Comportamento por operacao:
  - PUT    : Monta o JSON e grava no cofre usando a safeKey como identificador.
             Se a chave ja existir, registra log informativo e sobrescreve.
             Retorna .T. em sucesso, .F. em falha de validacao.
  - GET    : Recupera os dados associados a safeKey.
             Se aFields for omitido ou array vazio, retorna a string JSON
             completa armazenada no cofre.
             Se aFields for uma string com o nome de um campo (ex: 'WF7_SENHA'),
             faz o parse do JSON internamente e retorna apenas o valor
             daquele campo (AllTrim), ou string vazia se nao encontrado.
  - DELETE : Remove a entrada do cofre pela safeKey.
             Retorna .T. se removida, .F. se a chave nao existir ou for invalida.

Exemplos de uso:
  // Gravar
  WFSafe('SMTP_CONFIG', {{'usuario', 'admin'}, {'senha', 'MinhaS3nha!'}}, 'PUT')

  // Recuperar JSON completo
  cDados := WFSafe('SMTP_CONFIG',, 'GET')

  // Recuperar valor de um campo especifico
  cSenha := WFSafe('SMTP_CONFIG', 'WF7_SENHA', 'GET')

  // Remover
  WFSafe('SMTP_CONFIG',, 'DELETE')

@author Victor Vieira
@since 15/07/2026
@version P12
@param cSafeKey  Identificador unico da credencial no cofre (obrigatorio)
@param xFields   Para PUT: Array de pares {campo, valor} (obrigatorio).
                 Para GET: String com nome do campo a recuperar (opcional).
                           Se omitido, retorna o JSON completo.
                 Para DELETE: nao utilizado (pode ser omitido).
@param cOper     Operacao desejada: 'PUT', 'GET' ou 'DELETE' (case-insensitive)
@return xRet     Para PUT e DELETE: .T. (sucesso) ou .F. (falha/validacao).
                 Para GET sem campo: string JSON completa, ou '' se nao existir.
                 Para GET com campo: valor do campo (AllTrim), ou '' se nao encontrado.

/*/
//-------------------------------------------------------------------
Function WFSafe(cSafeKey, aFields, cOper)

	Local oVault    := Nil   As Object
	Local cOperUp   := ""    As Character
	Local cJson     := ""    As Character
	Local cContent  := ""    As Character
	Local xRet      := .F.

	Default cSafeKey := ""
	Default aFields  := {}
	Default cOper    := ""

	// ----------------------------------------------------------
	// Validacao dos parametros obrigatorios
	// ----------------------------------------------------------
	If ValType(cSafeKey) != 'C' .Or. Empty(cSafeKey)
		FWLogMsg("WARN", , 'WFSafe', , , , STR0108) //"cSafeKey invalido ou vazio."
		Return .F.
	EndIf

	If ValType(cOper) != 'C' .Or. Empty(cOper)
		FWLogMsg("WARN", , 'WFSafe', , , , STR0101) //"cOper invalido ou vazio."  
		Return .F.
	EndIf

	// Normaliza operacao para maiusculo evitando sensibilidade a case
	cOperUp := Upper(AllTrim(cOper))

	If !cOperUp $ 'PUT|GET|DELETE'
		FWLogMsg("WARN", , 'WFSafe', , , , StrTran(STR0102, '%1', cOper)) //"cOper [%1] nao reconhecida. Use PUT, GET ou DELETE." 
		Return .F.
	EndIf

	// Para PUT o array de campos e obrigatorio
	If cOperUp == 'PUT'
		If ValType(aFields) != 'A' .Or. Len(aFields) == 0
			FWLogMsg("WARN", , 'WFSafe', , , , STR0104) //"aFields invalido ou vazio para operacao PUT."
			Return .F.
		EndIf
	EndIf

	// ----------------------------------------------------------
	// Inicializa o cofre
	// ----------------------------------------------------------
	oVault := FwSafeVault():New()

	// ----------------------------------------------------------
	// Executa a operacao solicitada
	// ----------------------------------------------------------
	Do Case

		Case cOperUp == 'PUT'

			// Monta o JSON a partir da chave e dos campos/valores
			cJson := WFSafeJson(cSafeKey, aFields)

			// Verifica se a chave ja existe no cofre
			cContent := oVault:Get(cSafeKey)

			If !Empty(cContent)
				FWLogMsg("INFO", , 'WFSafe', , , , StrTran(STR0105, '%1', cSafeKey)) //"Chave [%1] ja existe no cofre. Sobrescrevendo." 
			EndIf

			// Grava o JSON completo no cofre usando a safeKey como identificador
			oVault:Put(cSafeKey, cJson)
			xRet := .T.

		Case cOperUp == 'GET'

			// GET retorna string JSON armazenada ou valor de um campo especifico
			cContent := oVault:Get(cSafeKey)

			If Empty(cContent)
				FWLogMsg("INFO", , 'WFSafe', , , , StrTran(STR0106, '%1', cSafeKey)) //"Chave [%1] nao encontrada no cofre. Retornando vazio."
				xRet := ""
			Else
				// Se aFields informado com nome do campo, extrai apenas o valor solicitado
				If ValType(aFields) == 'C' .And. !Empty(aFields)
					xRet := WFSafeGetField(cContent, aFields)
				Else
					xRet := cContent
				EndIf
			EndIf

		Case cOperUp == 'DELETE'

			// Verifica existencia antes de tentar remover
			cContent := oVault:Get(cSafeKey)

			If Empty(cContent)
				FWLogMsg("WARN", , 'WFSafe', , , , StrTran(STR0107, '%1', cSafeKey)) //"Chave [%1] nao encontrada no cofre. Nada a remover."
				FreeObj(oVault)
				Return .F.
			EndIf

			// Deletar um dado que foi armazenado
			oVault:Delete(cSafeKey)
			xRet := .T.

	EndCase

	// ----------------------------------------------------------
	// Libera recursos
	// ----------------------------------------------------------
	FreeObj(oVault)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WFSafeJson

Funcao auxiliar que monta o JSON estruturado para persistencia no cofre.
Recebe a chave identificadora e um array de pares {campo, valor},
retornando a string JSON serializada no formato esperado pelo cofre.

Estrutura do JSON gerado:
  {
    "safeKey": "<cSafeKey>",
    "safeItems": [ { "<campo1>": "<valor1>", "<campo2>": "<valor2>", ... } ]
  }

@type Static Function
@author Victor Vieira
@since 15/07/2026
@version P12
@param cSafeKey  Identificador unico da credencial (obrigatorio)
@param aFields   Array de pares {campo, valor} - cada elemento eh {cNomeCampo, cValor}
@return cJson    String JSON serializada, ou "" em caso de falha de validacao

/*/
//-------------------------------------------------------------------
Static Function WFSafeJson(cSafeKey, aFields)

	Local jPayload  := Nil   As Json
	Local jItem     := Nil   As Json
	Local aItems    := {}    As Array
	Local cJson     := ""    As Character
	Local nI        := 0     As Numeric

	// ----------------------------------------------------------
	// Validacao dos parametros
	// ----------------------------------------------------------
	If ValType(cSafeKey) != 'C' .Or. Empty(cSafeKey)
		FWLogMsg("WARN", , 'WFSafeJson', , , , STR0108) //"cSafeKey invalido ou vazio." 
		Return ""
	EndIf

	If ValType(aFields) != 'A' .Or. Len(aFields) == 0
		FWLogMsg("WARN", , 'WFSafeJson', , , , STR0109) //"aFields invalido ou vazio." 
		Return ""
	EndIf

	// ----------------------------------------------------------
	// Monta o objeto JSON
	// ----------------------------------------------------------
	jPayload := JsonObject():New()
	jPayload['safeKey'] := AllTrim(cSafeKey)

	// Monta o item (objeto com os pares campo/valor)
	jItem := JsonObject():New()

	For nI := 1 To Len(aFields)

		// Valida que cada elemento eh um sub-array de 2 posicoes
		If ValType(aFields[nI]) != 'A' .Or. Len(aFields[nI]) < 2
			FWLogMsg("WARN", , 'WFSafeJson', , , , StrTran(STR0110, '%1', cValToChar(nI))) //"aFields[%1] nao eh um par {campo, valor} valido. Ignorando."
			Loop
		EndIf

		If ValType(aFields[nI][1]) != 'C' .Or. Empty(aFields[nI][1])
			FWLogMsg("WARN", , 'WFSafeJson', , , , StrTran(STR0111, '%1', cValToChar(nI))) //"Nome do campo na posicao [%1] invalido. Ignorando." 
			Loop
		EndIf

		If ValType(aFields[nI][2]) != 'C'
			FWLogMsg("WARN", , 'WFSafeJson', , , , StrTran(STR0112, '%1', aFields[nI][1])) //"Valor do campo [%1] nao eh Character. Ignorando."
			Loop
		EndIf

		jItem[AllTrim(aFields[nI][1])] := aFields[nI][2]

	Next nI

	// Monta o array safeItems com o item
	aItems := {}
	aAdd(aItems, jItem)
	jPayload['safeItems'] := aItems

	// Serializa para string
	cJson := jPayload:ToJson()

	// ----------------------------------------------------------
	// Libera recursos
	// ----------------------------------------------------------
	
	jItem := Nil
	jPayload := Nil 
	
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} WFSafeGetField

Funcao auxiliar que recebe o conteudo JSON armazenado no cofre e extrai
o valor de um campo especifico contido no array safeItems.

Estrutura esperada do JSON:
  {
    "safeKey": "<chave>",
    "safeItems": [ { "<campo1>": "<valor1>", "<campo2>": "<valor2>", ... } ]
  }

A funcao faz o parse do JSON, localiza a propriedade correspondente ao
nome do campo informado dentro do primeiro elemento de safeItems e
retorna seu valor (string). Se o campo nao for encontrado ou o JSON
for invalido, retorna string vazia.

@type Static Function
@author Victor Vieira
@since 13/08/2026
@version P12
@param cJsonContent  String JSON obtida do cofre (retorno do FwSafeVault:Get)
@param cFieldName    Nome do campo cujo valor se deseja obter (ex: 'WF7_SENHA')
@return cValue       Valor do campo solicitado (AllTrim), ou "" se nao encontrado

/*/
//-------------------------------------------------------------------
Static Function WFSafeGetField(cJsonContent, cFieldName)

	Local jParsed   := Nil   As Json
	Local aItems    := {}    As Array
	Local jItem     := Nil   As Json
	Local cValue    := ""    As Character

	Default cJsonContent := ""
	Default cFieldName   := ""

	// Validacao basica dos parametros
	If Empty(cJsonContent) .Or. Empty(cFieldName)
		Return ""
	EndIf

	// Parse do JSON armazenado no cofre
	jParsed := JsonObject():New()

	If jParsed:FromJson(cJsonContent) != Nil
		FWLogMsg("WARN", , 'WFSafeGetField', , , , STR0114) //"Falha ao interpretar JSON do cofre."
		FreeObj(jParsed)
		Return ""
	EndIf

	// Obtem o array safeItems
	aItems := jParsed['safeItems']

	If ValType(aItems) != 'A' .Or. Len(aItems) == 0
		FWLogMsg("WARN", , 'WFSafeGetField', , , , STR0115) //"safeItems nao encontrado ou vazio no JSON."
		FreeObj(jParsed)
		Return ""
	EndIf

	// Busca no primeiro item do array (padrao atual: 1 item com N campos)
	jItem := aItems[1]

	// Tenta obter o valor pela chave informada e pela variacao Upper
	cValue := jItem[AllTrim(cFieldName)]

	If ValType(cValue) != 'C' .Or. Empty(cValue)
		cValue := jItem[Upper(AllTrim(cFieldName))]
	EndIf

	If ValType(cValue) == 'C' .And. !Empty(cValue)
		cValue := AllTrim(cValue)
	Else
		cValue := ""
		FWLogMsg("INFO", , 'WFSafeGetField', , , , StrTran(STR0117, '%1', cFieldName)) //"Campo [%1] nao encontrado no cofre."
	EndIf

	// Libera recursos
	FreeObj(jParsed)

Return cValue
