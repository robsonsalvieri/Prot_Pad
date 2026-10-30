#INCLUDE "Protheus.ch"
#INCLUDE "GPEA370.CH"
#INCLUDE 'FWMVCDEF.CH'

//Recuperar versão de envio
Static cVersEnvio 	:= ""
Static cVersGPE   	:= ""
Static lIntTAF    	:=  ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 0 )
Static lCargSQ3		:= SuperGetMv("MV_CARGSQ3",,.F.) //Define se o envio do evento S-1030 serão feito pela tabela SQ3 e não pela SRJ (Padrão .F. -> SRJ).
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static cEFDAviso	:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
Static lMsbql
Static cCompSQ3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA370  ³ Autor ³ Emerson Campos                    ³ Data ³ 04/02/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Cargos versão MVC                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA370()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL NA VERSAO MVC              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr. ³15/10/2012³M12RH01         ³Requisito RHU210_03_03. Retirado ajustas e  ³±±
±±³            ³          ³                ³processamento sem MVC.                      ³±±
±±³Raquel Hager³15/06/2016³TVKGSL          ³Ajuste para exclusão de Cargos pelo GPE .   ³±±
±±³Gabriel A.  ³14/07/2016³TVMMI8          ³Ajuste para deixar o campo Q3_CARGO habilita³±±
±±³            ³          ³                ³do na inclusão.                             ³±±
±±³Cícero Alves³17/08/2016³TVREZ5          ³Adicionado Centro de Custo na chave única   ³±±
±±³            ³          ³                ³				                            ³±±
±±³Cícero Alves³27/09/2016³TWDNAY          ³Ajuste para permitir a utilização da rotina ³±±
±±³            ³          ³                ³sem interface (testes automatizados)        ³±±
±±|Claudinei S.|19/09/2017|DRHESOCP-904    |Inclusão da chamada para a rotina histórico |±±
±±|            |          |                |de cargos em ações relacionadas - AUDESP    |±±
±±³E.Moskovkina³13/10/2016³MA3A-718        ³RUS-Localization: Changes on Model/View in  ³±±
±±³Raquel H.   ³          ³                ³accordance with localized MVC.  	        ³±±
±±³Wesley Alves|³18/08/2020³DRHGCH-20762   ³Envio de dados para gravar na RJP quando    ³±±
±±³Pereira.   ³          ³                 ³houver alteração de registros.  	        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA370

Local cFiltraRh
Local oBrwSQ3

Private lCopy := .F. //Compatibilizacao com TRMA020

    // Endereca a funcao de BROWSE
	Pyme_Dic_Ajust("SQ3", .F.)
	oBrwSQ3 := BrowseDef()

	oBrwSQ3:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author E. Moskovkina
@since 03/10/2017
@version 1.0
@project MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrwSQ3
Local cFiltraRh

oBrwSQ3 := FWmBrowse():New()
oBrwSQ3:SetAlias( 'SQ3' )
oBrwSQ3:SetDescription(STR0001)	//"Cargo"

//Inicializa o filtro utilizando a funcao FilBrowse
cFiltraRh	:= CHKRH(FunName(),"SQ3","1")
//Filtro padrao do Browse conforme tabela SQ3 (Cargo)
oBrwSQ3:SetFilterDefault(cFiltraRh)

If hasSmartX()    
    oBrwSQ3:SetSmartX( 1, .T. ) // Q3_FILIAL + Q3_CARGO + Q3_CC - Cargo + Centro de Custo
EndIf    

Return oBrwSQ3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA370'  OPERATION 2 ACCESS 0 //"Visualizar"
	If cPaisLoc != "RUS"
		ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA370'  OPERATION 3 ACCESS 0 //"Incluir"
		ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA370' 	OPERATION 4 ACCESS 0 //"Alterar"
		ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.GPEA370'  OPERATION 5 ACCESS 0 //"Excluir"
		ADD OPTION aRotina TITLE STR0010  ACTION 'VIEWDEF.GPEA370'	OPERATION 9 ACCESS 0 //"Copiar"
	EndIf

	If SuperGetMv('MV_AUDESP',, .F.)
		ADD OPTION aRotina TITLE STR0016  ACTION 'fHistAud()'	OPERATION 9 ACCESS 0 //""Historico de Cargos""
	Endif
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Cargos                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSQ3 := FWFormStruct( 1, 'SQ3', /*bAvalCampo*/,/*lViewUsado*/ )
Local oMdlSQ3

// Blocos de codigo do modelo
Local bPosValid 	:= { |oMdl| Gp370PosVal( oMdl )}
Local bCommit		:= { |oMdl| Gp370Grav( oMdl )}
// Bloco de codigo doa Fields
Local bTOkVld		:= { |oMdl| Gp370TOk( oMdl )}

	//Monta o campos virtuais "Memo"
	FWMemoVirtual(oStruSQ3, Gp370MSMM())
	oStruSQ3:RemoveField( "Q3_CLASSE" )

	oStruSQ3:SetProperty( 'Q3_CARGO' , MODEL_FIELD_WHEN, {|| IsBlind() .OR. INCLUI })
	If cPaisLoc <> "RUS"
		oStruSQ3:SetProperty( 'Q3_CC'    , MODEL_FIELD_WHEN, {|| IsBlind() .OR. INCLUI })
	EndIf

	// Cria o objeto do Modelo de Dados
	oMdlSQ3 := MPFormModel():New('GPEA370', /*bPreValid*/, bTOkVld, bCommit, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlSQ3:AddFields( 'MODELGPEA370', /*cOwner*/, oStruSQ3, /*bLOkVld*/, 	Nil, /*bCarga*/ )

	oMdlSQ3:SetPrimaryKey( { "Q3_FILIAL", "Q3_CARGO", "Q3_CC" } )

	// Adiciona a descricao do Modelo de Dados
	oMdlSQ3:SetDescription(STR0001)	//"Cargo"

	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlSQ3:GetModel( 'MODELGPEA370' ):SetDescription(STR0001)	//"Cargo"

Return oMdlSQ3

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Cargos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oMdlSQ3   := FWLoadModel( 'GPEA370' )
// Cria a estrutura a ser usada na View
Local oStruSQ3 := FWFormStruct( 2, 'SQ3' )
Local oView

	//Remove campos de gravacao do ID dos memos
	oStruSQ3:RemoveField( "Q3_DESCDET" )
	oStruSQ3:RemoveField( "Q3_DRESP"   )
	oStruSQ3:RemoveField( "Q3_DRELINT" )
	oStruSQ3:RemoveField( "Q3_DHABILI" )
	oStruSQ3:RemoveField( "Q3_CLASSE" )
	If cPaisLoc $ "RUS"
		oStruSQ3:RemoveField( "Q3_CC" )
	EndIf
	If cModulo $ "CSA|TRM|ORG|RSP|TCF"
		oStruSQ3:SetProperty( "Q3_GRUPO", MODEL_FIELD_OBRIGAT, ".T." )
	Endif

	// Retira os códigos da Audesp
	If !SuperGetMv('MV_AUDESP',, .F.)
		oStruSQ3:RemoveField( "Q3_ADTPCAR" )
		oStruSQ3:RemoveField( "Q3_ADTPJU" )
		oStruSQ3:RemoveField( "Q3_ADTPESC" )
		oStruSQ3:RemoveField( "Q3_ADATIV" )
		oStruSQ3:RemoveField( "Q3_ADTPROV" )
		oStruSQ3:RemoveField( "Q3_ADHORAS" )
		oStruSQ3:RemoveField( "Q3_ADCP" )
		oStruSQ3:RemoveField( "Q3_ADRESP" )
	Endif

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlSQ3 )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_GPEA370', oStruSQ3, 'MODELGPEA370' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_GPEA370', 'FORMFIELD' )

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp370PosVal ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do Cadastro de Cargos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp370PosVal( oMdlSQ3 )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlSQ3 = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp370PosVal( oMdlSQ3 )
Local lRetorno      := .T.
Local nOperation

	// Seta qual é a operacao corrente
	nOperation := oMdlSQ3:GetOperation()

	If nOperation == 5
		//Valida exclusao se for DBF, para TOP o proprio MVC trata atraves do relacionamento no SX9
		#IFNDEF TOP
			dbSelectArea("SRJ")
			dbSetOrder(4)
			If dbSeek(xFilial("SRJ")+SQ3->Q3_CARGO)
				Help("",1,"TR020NPODE")// Este cargo nao pode ser excluido. Verifique os cargos na funcao
				lRetorno := .F.
			EndIf
		#ENDIF
	EndIf
Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp370Grav   ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pelo commit do Cadastro de Cargos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp370Grav( oMdlSQ3 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlSQ3 = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp370Grav( oMdlSQ3 )
Local lRetorno       := .T.
Local nOperation
Local aSaveLines
Local lCommit		 := .F.
Local cCodCargo		 := SQ3->Q3_CARGO
Local oViewActiv	 := FwViewActive()
Local lIntegrac := SUPERGETMV('MV_RHNG', .F., .F.)

	// Seta qual é a operacao corrente
	nOperation := oMdlSQ3:GetOperation()
	// Salva as posicoes das FWFormGrids do Model
	aSaveLines := FWSaveRows()
	// Fornece o objeto da classe FWFormModel ativo no momento, para ser utilizado nas regras de validacao.
	FWModelActive( oMdlSQ3 )
    /* Realiza os tratamentos necessarios para gravacao dos formularios de edicao. A Gravacao e
    realizada em niveis onde o primeiro elemento do modelo e posteriormente seus filhos sao gravados.*/
	// --> Se possuir registro na SQ4, deixa usuário decidir se realmente irá excluir
    If nOperation == 5 .And. VerSQ4(cCodCargo)
    	If MsgYesNo(OemToAnsi(STR0012) + Chr(10) + Chr(13) + OemToAnsi(STR0013) ,OemToAnsi(STR0011))
    		lCommit:= FWFormCommit( oMdlSQ3 )
    		oViewActiv:SetDeleteMessage(OemToAnsi(STR0011), OemToAnsi(STR0015))
    	Else
    		oViewActiv:SetDeleteMessage(OemToAnsi(STR0011), OemToAnsi(STR0014))
    	EndIf
    Else
    	FWFormCommit( oMdlSQ3 )
    EndIf
    // Restaura as posicoes das FWFormGrids do Model
	FWRestRows( aSaveLines )

    // Integracao PIMS GRAOS
	If (nOperation == 3 .OR. nOperation == 4) .And. SuperGetMV("MV_PIMSINT",.F.,.F.) .And. FindFunction("PIMSGeraXML")
	    PIMSGeraXML("Position",STR0001,"2","SQ3") //--## Cargo
	EndIf
	//Integração com o SIGAMDT
	If SuperGetMV( "MV_MDTGPE" , .F. , "N" ) == "S" .And. nOperation == 3 .And. FindFunction("MDTW030")
		MDTW030( "SQ3" , M->Q3_CARGO ) //Executa o W.F. de Aviso do SESMT
	EndIf

	If nOperation == 5 .And. lCommit
		EraseSQ4( cCodCargo )
	EndIf

	If ( lIntegrac)
		fPrepDadosApi(nOperation)
	EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp370MSMM   ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com os campos memo do Cadastro de Cargos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp370MSMM(  )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao ha                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aMemos                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp370MSMM()
Local aMemos := {}

	dbSelectArea("SX3")
	dbSetOrder(2)

	If dbSeek("Q3_DRESP")
		Aadd(aMemos,{"Q3_DRESP","Q3_MEMO2","RDY"})
	Endif
	If cPaisLoc <> "RUS"
		If dbSeek("Q3_DESCDET")
			Aadd(aMemos,{"Q3_DESCDET","Q3_MEMO1","RDY"})
		Endif
		If dbSeek("Q3_DRELINT")
			Aadd(aMemos,{"Q3_DRELINT","Q3_MEMO3","RDY"})
		Endif
		If dbSeek("Q3_DHABILI")
			Aadd(aMemos,{"Q3_DHABILI","Q3_MEMO4","RDY"})
		Endif
	EndIf
Return aMemos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp370TOk    ³ Autor ³ Emerson               ³ Data ³ 04/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tudo Ok do Cadastro de Cargos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp370TOk( oGrid, oMdlSQ3 )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oGrid   = Objeto da Grid                                     ³±±
±±³          ³ oMdlSQ3 = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp370TOk( oMdlSQ3 )

Local cCargo		:= ""
Local dDataAux   := dDataBase
Local cData      := cValToChar( StrZero( Month(dDataAux), 2 ) ) + cValToChar( Year(dDataAux))
Local cAnoMes    := cValToChar( Year(dDataAux)) + "-" + cValToChar( StrZero( Month(dDataAux), 2 ) )
Local cChave     := ""
Local cStatus    := ""
Local cFilEnv    := ""
Local cDescr     := ""
Local cCBO       := ""

Local nOperation := oMdlSQ3:GetOperation()

Local aErros     := {}
Local aFilInTaf  := {}
Local aArrayFil  := {}
Local aCposVal   := {}
Local aArea		 := GetArea()

Local lSemFilial := .F.
Local lIntegra   := .F.
Local lRetorno       := .T.
Local oMdl		:= oMdlSQ3:GetModel("MODELGPEA370")

Local cMsgErro	 := ""
Local aInfoC	 := {}
Local cChaveMid	 := ""
Local cStatMid   := ""
Local cOpcRJE	 := "I"
Local cRetfRJE	 := ""
Local nRecRJE    := 0
Local cOperNew	 := ""
Local cRetfNew	 := ""
Local cStatNew	 := ""
Local cRetKey	 := ""
Local cVersMW	 := ""
Local lNovoRJE	 := .F.
Local cMsgRJE    := ""
Local dDtGer	:= Date()
Local cHrGer	:= Time()
Local cXml		:= ""
Local aDados	:= {}
Local nOpcao		:= 3
Local cTpInsc	:= ""
Local cNRInsc   := ""
Local lAdmPubl	:= .F.
Local lRetRJE   := .T.
Local lS1000	:= .F.
Local lVldInteg	:= .T.

DEFAULT lMsbql	:= SQ3->( ColumnPos( "Q3_MSBLQL" ) ) > 0

If cPaisLoc <> "RUS"
	If nOperation == 3 .Or. (nOperation == 4 .And. (oMdl:IsFieldUpdated("Q3_CC") .Or. oMdl:IsFieldUpdated("Q3_CARGO")))
		lRetorno := !SQ3->(dbSeek(xFilial("SQ3")+oMdl:GetValue("Q3_CARGO")+oMdl:GetValue("Q3_CC")))

		If !lRetorno
			Help(,,STR0011,,OemToAnsi(STR0019),1,0)  //"Atencao"###"Registro já existe na base de dados! (Cargo + Centro Custo)"
		EndIf
	EndIf

	If lRetorno

		//Verificando versão do GPE
		lIntegra := Iif(FindFunction("fVersEsoc"), fVersEsoc("S-1030", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE, @cVersMW), .F. )

		If FindFunction("ESocMsgVer") .And. lIntTaf .And.!lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
			If ( cValToChar(nOpcao) $ "4|3" )
				//"Atenção! A versão do leiaute GPE é xxx e a do TAF é xxx, sendo assim, estão divergentes. O Evento xxx não será integrado com o TAF, e consequentemente, não será enviado ao RET.
				//Caso prossiga a informação será atualizada somente na base do GPE. Deseja continuar?"
				If ESocMsgVer(.F.,"S-1030", cVersGPE, cVersEnvio)
					lVldInteg := .F.
				Else
					lVldInteg := .F.
					Help(,,,OemToAnsi(STR0011),OemToAnsi(STR0037),1,0)//##"Atenção"
					Return .F.
				EndIf
			EndIf
		EndIf

		If lMsbql .And. nOperation == MODEL_OPERATION_UPDATE .And. oMdl:GetValue("Q3_MSBLQL") == "1" .And. oMdl:GetValue("Q3_MSBLQL") != SQ3->Q3_MSBLQL .And. fVldAtiv( oMdl:GetValue("Q3_CARGO") )
			lRetorno	:= .F.
			Help( " ", 1, OemToAnsi(STR0011), Nil, OemToAnsi(STR0038), 1, 0 )//"Atenção"##"Não é possivel efetuar o bloqueio do cargo pois há funcionários ativos vinculados"
		EndIf
		
		If lRetorno .And. (lInttaf .Or. lMiddleware)
			If Len(FwFldGet('Q3_MEMO1')) > 999
				lRetorno	:= .F.
				Help(,,,OemToAnsi(STR0011),OemToAnsi(STR0039),1,0)//##"O campo Ds.Detalhada ultrapassou o número de caracteres permitido para tag dscAtivDes no eSocial (999)."
			EndIf
		EndIf

		//----------------------------------
		//| E X T E M P O R Â N E O  S-1030
		//----------------------------------
		//Se a integração estiver ativa e não for consistência de tabela
		If lRetorno .And. ((lInttaf .Or. lMiddleware) .And. cVersGPE < "9.0" ) .And. lVldInteg .And. FUNNAME() <> "GPEM035"   .And. ( IIF(FindFunction("fChkFMat"),lRet:=fChkFMat("S-1030"),.T.)) .And. lCargSQ3

			If SQ3->(ColumnPos( 'Q3_CBO' )) > 0
				If SQ3->(ColumnPos( 'Q3_ACUM' )) > 0 .And. !Empty(oMdl:GetValue("Q3_ACUM"))
					aAdd(aCposVal,oMdl:GetValue("Q3_ACUM"))
					aAdd(aCposVal,oMdl:GetValue("Q3_CTESP"))
					aAdd(aCposVal,oMdl:GetValue("Q3_DEDEXC"))
					aAdd(aCposVal,oMdl:GetValue("Q3_LEI"))
					aAdd(aCposVal,oMdl:GetValue("Q3_DTLEI"))
					aAdd(aCposVal,oMdl:GetValue("Q3_SIT"))
				EndIf
			Else
				Help(,,,""/*OemToAnsi(STR0011)*/,OemToAnsi(STR0020)+ CRLF + CRLF + OemToAnsi(STR0021),1,0)//##"Atenção"
				Return .F.
			EndIf

			If !lMiddleware
				//Identificando Filial de Envio
				fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf
			Endif

			//Tratamento de compartilhamento da tabela SQ3
			If Empty( xFilial("SQ3") )
				lSemFilial := .T.
			EndIf

			//Montando as variaveis utilizadas na chave de pesquisa
			If lMiddleware
				cCargo	:= Iif(lSemFilial, AllTrim(oMdl:GetValue("Q3_CARGO")), AllTrim(xFilial("SQ3") + oMdl:GetValue("Q3_CARGO")))
			Else
				cCargo	:= IIf(lSemFilial, AllTrim(oMdl:GetValue("Q3_CARGO")), AllTrim(If(Empty(SQ3->Q3_FILIAL), cFilEnv, SQ3->Q3_FILIAL) + oMdl:GetValue("Q3_CARGO")))// AllTrim(SQ3->Q3_FILIAL + oMdl:GetValue("Q3_CARGO") ) )
			EndIf

			cDescr  := AllTrim(oMdl:GetValue("Q3_DESCSUM"))
			cCBO    := oMdl:GetValue("Q3_CBO")
			cChave  := cCargo + ";" + cData

			If !lMiddleware

				//-------------------------------------------------
				//| Função centralizadora para gerar Extemporâneos
				//| Extemporâneo S-1035: GY_CODIGO + MMAAAA
				//-------------------------------------------------
				nOperation := fVerExtemp( "S-1030", cChave, nOperation, @cStatus )

				//-------------------------------------------------
				//| Baseado no evento de retorno, geramos o nOpc
				//| nOpc irá variar de 3 <inclusao>, 4 <alteracao> e 5 <exclusao>
				//----------------------------------------------------------------
				If ( nOperation > 0 )
					//Realizando integração do evento
					lRet := fCarrFun( cCargo, cDescr, cCBO, nOperation, cAnoMes,@aErros,cFilEnv,aCposVal, .F. )

					If( !lRetorno )
						Help(,,,OemToAnsi(STR0011),aErros[1],1,0)//##"Atenção"

					ElseIf FindFunction("fEFDMsg") .AND. lRet
						fEFDMsg()
					EndIf
				Else
					lRet := .F.
				EndIf
			Else
				If  !ChkFile("RJE") .And. ChkFile("RJ9")
					MsgInfo(OemToAnsi(STR0022)) //"Tabela RJE não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
					lRetorno		:= .F.
				Elseif ChkFile("RJE")
					// verificar os predecessores - evento S1000
					cStatus := "-1"
					lS1000 := fVld1000( AnoMes(dDataBase), @cStatus )
					//	* 1 - Não enviado - Gravar por cima do registro encontrado
					//	* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
					//	* 3 - Retorno com Erro - Gravar por cima do registro encontrado
					//	* 4 - Retorno com Sucesso -?Efetivar a gravação

					If lS1000 //evento S-1000
						fPosFil( cEmpAnt, cFilAnt )
						aInfoC   := fXMLInfos()

						IF LEN(aInfoC) >= 4
							cTpInsc  := aInfoC[1]
							lAdmPubl := aInfoC[4]
							cNrInsc  := aInfoC[2]
						ELSE
							cTpInsc  := ""
							lAdmPubl := .F.
							cNrInsc  := "0"
						ENDIF

						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1030" + Padr(xFilial("SQ3", cFilAnt) + oMdl:GetValue("Q3_CARGO"), fTamRJEKey(), " ") + AnoMes(dDataBase)
						cStatMid := "-1"

						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatMid, @cOpcRJE, @cRetfRJE, @nRecRJE )

						If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
							//Retorno pendente impede o cadastro
							If cStatMid == "2"
								cMsgErro 	:= STR0023//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
								lRetorno	:= .F.
							EndIf
							//Alteração
							If nOperation == MODEL_OPERATION_UPDATE
								//Evento de exclusão sem transmissão impede o cadastro
								If cOpcRJE == "E" .And. cStatMid != "4"
									cMsgErro 	:= STR0024//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
									lRetorno	:= .F.
								//Não existe na fila, será tratado como inclusão
								ElseIf cStatMid == "-1"
									nOpcao 		:= 3
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								//Evento sem transmissão, irá sobrescrever o registro na fila
								ElseIf cStatMid $ "1/3"
									If cOpcRJE == "A"
										nOpcao 	:= 4
									EndIf
									cOperNew 	:= cOpcRJE
									cRetfNew	:= cRetfRJE
									cStatNew	:= "1"
									lNovoRJE	:= .F.
								//Evento diferente de exclusão transmitido, irá gerar uma retificação
								ElseIf cOpcRJE != "E" .And. cStatMid == "4"
									nOpcao 		:= 4
									cOperNew 	:= "A"
									cRetfNew	:= "2"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								//Evento de exclusão transmitido, será tratado como inclusão
								ElseIf cOpcRJE == "E" .And. cStatMid == "4"
									nOpcao 		:= 3
									cOperNew 	:= "I"
									cRetfNew	:= "1"
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
								//Exclusão
							ElseIf nOperation == MODEL_OPERATION_DELETE
								nOpcao 		:= 5
								//Evento de exclusão sem transmissão impede o cadastro
								If cOpcRJE == "E" .And. cStatMid != "4"
									cMsgErro 	:= STR0024//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
									lRetorno		:= .F.
								//Evento diferente de exclusão transmitido irá gerar uma exclusão
								ElseIf cOpcRJE != "E" .And. cStatMid == "4"
									cOperNew 	:= "E"
									cRetfNew	:= cRetfRJE
									cStatNew	:= "1"
									lNovoRJE	:= .T.
								EndIf
							EndIf
						ElseIf nOperation == MODEL_OPERATION_INSERT
							//Retorno pendente impede o cadastro
							If cStatMid == "2"
								cMsgErro 	:= STR0025//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
								lRetorno		:= .F.
							//Evento de exclusão sem transmissão impede o cadastro
							ElseIf cOpcRJE == "E" .And. cStatMid != "4"
								cMsgErro 	:= STR0024//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
								lRetorno		:= .F.
							//Evento sem transmissão, irá sobrescrever o registro na fila
							ElseIf cStatMid $ "1/3"
								nOpcao		:= Iif( cOpcRJE == "I", 3, 4 )
								cOperNew 	:= cOpcRJE
								cRetfNew	:= cRetfRJE
								cStatNew	:= "1"
								lNovoRJE	:= .F.
							//Evento diferente de exclusão transmitido, irá gerar uma retificação
							ElseIf cOpcRJE != "E" .And. cStatMid == "4"
								cOperNew 	:= "A"
								cRetfNew	:= "2"
								cStatNew	:= "1"
								lNovoRJE	:= .T.
							//Será tratado como inclusão
							Else
								cOperNew 	:= "I"
								cRetfNew	:= "1"
								cStatNew	:= "1"
								lNovoRJE	:= .T.
							EndIf
						EndIf

						If lRetorno
							lRetRJE    := fCarrFun( cCargo, oMdl:GetValue("Q3_DESCSUM"), oMdl:GetValue("Q3_CBO"), nOpcao, cAnoMes, @aErros, xFilial("SQ3", cFilAnt), aCposVal, .F. , cVersMW, @cXml, @cRetKey)
							If lRetRJE
								aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("SQ3", cFilAnt), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1030", AnoMes(dDataBase), xFilial("SQ3", cFilAnt) +  oMdl:GetValue("Q3_CARGO"), cRetKey, cRetfNew, "12", cStatNew, dDtGer, cHrGer, cOperNew } )

								//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
								If !( nOpcao == 5 .And. ((cOpcRJE == "E" .And. cStatMid == "4") .Or. cStatMid $ "-1/1/3") )
									If !( lRetorno := fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
										cMsgRJE := STR0026//"Ocorreu um erro na gravação do registro na tabela RJE"
									EndIf
									//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
								ElseIf nOpcao == 5 .And. cStatMid != "-1" .And. !(cOpcRJE == "E" .And. cStatMid == "4")
									If !( lRetorno := fExcluiRJE( nRecRJE ) )
										cMsgRJE := STR0027//"Ocorreu um erro na exclusão do registro na tabela RJE"
									EndIf
								EndIf
							Else
								lRetorno := .F.
								Help(,,,OemToAnsi(STR0011),aErros[1],1,0)//##"Atenção"
							Endif
						Else
							Help(,,,OemToAnsi(STR0011),cMsgErro,1,0)//##"Atenção"
						Endif
					Else
						lRetorno := .T.
						cMsgRJE := OemtoAnsi(STR0028)
						do Case
							case cStatus == "-1" // nao encontrado na base de dados
								cMsgRJE := OemtoAnsi(STR0029) //"Registro do evento S-1000 não localizado na base de dados"
							case cStatus == "1" // nao enviado para o governo
								cMsgRJE := OemtoAnsi(STR0030) //"Registro do evento S-1000 não transmitido para o governo"
							case cStatus == "2" // enviado e aguardando retorno do governo
								cMsgRJE := OemtoAnsi(STR0031) //"Registro do evento S-1000 aguardando retorno do governo"
							case cStatus == "3" // enviado e retornado com erro
								cMsgRJE := OemtoAnsi(STR0032) //"Registro do evento S-1000 retornado com erro do governo"
						endcase

						// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
						If cEFDAviso == "0"
							MsgInfo(cMsgRJE,OemToAnsi(STR0011))
							lRetorno		:= .T.
						elseIf cEFDAviso == "1"
						   	lRetorno := .F.
						   	Help(,,,OemToAnsi(STR0011),cMsgRJE,1,0)//##"Atenção"
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif

	If lRetorno .And. SuperGetMV( "MV_MDTGPE", .F., "N" ) == "S" .And. FindFunction( "mdtesoCar" )
		lRetorno := mdtesoCar( nOperation, .T., oMdl )
	EndIf

EndIf

RestArea(aArea)
Return lRetorno

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ DesCarCC		³Autor³  Kelly Soares     ³ Data ³25/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³ Obtem descricao do Cargo conforme Centro de Custo.         ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ SRA->RA_CC                 								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Inicializador padrao do campo RA_DCARGO                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function DesCarCC(cCargo)

Local aArea := GetArea()
Local cRet	:= ""
DEFAULT cCargo := SRA->RA_CARGO

cRet := FDESC("SQ3", cCargo + SRA->RA_CC, "Q3_DESCSUM",,SRA->RA_FILIAL)
If Empty(cret)
	cRet := FDESC("SQ3", cCargo			, "Q3_DESCSUM",,SRA->RA_FILIAL)
Endif

RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef   ºAutor  ³Microsiga           º Data ³  18/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e   º±±
±±º          ³ envio de informacoes do cadastro de Cargos                  º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA370                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersion )

Local aRet := {}
aRet:= GPEI370 ( cXml, nTypeTrans, cTypeMessage, cVersion )

Return aRet

/*/{Protheus.doc} EraseSQ4
Função para eliminar os registros da tabela SQ4 (TVAEL3)
@type function
@author Raquel Hager
@since 15/06/2016
@version 1.0
@param cCargo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function EraseSQ4( cCargo )
Local aArea 	:= GetArea()
Local aAreaSQ4	:= SQ4->( GetArea() )

	DbSelectArea("SQ4")
	SQ4->( DbSetOrder(1) )
	SQ4->( DbGoTop() )

	If SQ4->( DbSeek( xFilial("SQ4") + AllTrim(cCargo) ) )
		While SQ4->( !Eof() ) .And. SQ4->( Q4_FILIAL + Q4_CARGO ) == xFilial("SQ4") + cCargo
			RecLock("SQ4", .F.)
			SQ4->( DbDelete() )
			SQ4->( MsUnlock() )

			SQ4->( DbSkip() )
		EndDo
	EndIf

RestArea( aAreaSQ4 )
RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fHistAud      ºAutor  ³Marcia Moura       º Data ³ 14/11/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que avalia se apresenta ou não a tela de cadastro    º±±
±±º          ³historicos de cargos - audesp                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA370 - Acoes relacionas "Historico de Cargos"           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fHistAud()
Local aArea			:= GetArea()
Local aKeys			:= GetKeys()
Local lRet := .T.

If TableInDic("RS8")
	IF ( RS8->( ColumnPos( "RS8_FILIAL" ) ) > 0 )
		FWExecView(OemtoAnsi(STR0001), "GPEA371", MODEL_OPERATION_UPDATE,,{||.T.}) //"Histórico de Cargos"
	EndiF
Else
	Help( " ", 1, OemToAnsi(STR0011),, OemToAnsi(STR0018), 1, 0 ) // "Tabela RS8 não encontrada, para utilizar esta opção é necessário executar o UPDDISTR"
	Return lRet
Endif

RestKeys(aKeys , .T.)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} VerSQ4
Função para verificar se há registros no cadastro de habilidades vinculados ao cargo que está sendo excluído
@type function
@author Raquel Hager
@since 15/06/2016
@version 1.0
@param cCargo, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function VerSQ4( cCargo )
Local aArea 	:= GetArea()
Local aAreaSQ4	:= SQ4->( GetArea() )
Local lRet		:= .F.

	DbSelectArea("SQ4")
	SQ4->( DbSetOrder(1) )
	If SQ4->( DbSeek( xFilial("SQ4") + AllTrim(cCargo) ) )
		lRet := .T.
	EndIf

RestArea( aAreaSQ4 )
RestArea( aArea )

Return(lRet)


/*/{Protheus.doc} fPrepDadosApi
Processo para preparar os dados de inclusão/alteração/deleção para
integração via API REST.

@since	18/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fPrepDadosApi(nOpcao)

	Local aArea		:= GetArea()

	Local cOperacao := ""

	If nOpcao == 5
		cOperacao := "E"
	ElseIf nOpcao == 4
		cOperacao := "A"
	ElseIf nOpcao == 3
		cOperacao := "I"
	EndIf

	If nOpcao == 3 .Or. nOpcao == 4 .Or. nOpcao == 5
		fSQ3ToRJP(cOperacao)
	EndIf

	RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} fSQ3ToRJP
Processo para enviar os dados de inclusão/alteração/deleção para
integração via API REST.

@since	18/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Function fSQ3ToRJP(cOperacao)

	Local cHoraAt   := Time()
	Local cProces   := "SQ3"
	Local cUserId   := SubStr(cUsuario,7,15)
	Local cFIlSQ3   := xFilial("SQ3")
	Local cChave	:= cEmpAnt + "|" + cFIlSQ3 + "|" + SQ3->Q3_CARGO + "|" + SQ3->Q3_CC
	Local aSM0		:= {}
	Local nX		:= 0
	Local cFilSM0	:= ""
	Local lRet		:= .F.
	
	//Static
	Default cCompSQ3 	:= FWModeAccess("SQ3",1) + FWModeAccess("SQ3",2) + FWModeAccess("SQ3",3)
	
	Default cOperacao := ""
	
	If cOperacao $ 'I|A|E' //Inclusão, Alteração ou Exclusão		
		
		If cCompSQ3 <> "EEE"
			aSM0	:= FWAllFilial(FWCompany("SQ3"), FWUnitBusiness("SQ3"), cEmpAnt, .F.)
			// Quando SQ3 for Compartilhada o Cargo deve ser enviado para todas as Filiais que visualizam esse cargo
			For nX := 1 To Len(aSM0)
				If cCompSQ3 == "CCC" // Se totalmente compartilhado inclui a filial na chave conforme foi alinhado com a NG
					cChave := cEmpAnt + "|" + aSM0[nX] + "|" + SQ3->Q3_CARGO + "|" + SQ3->Q3_CC
				Else
					cFilSM0 := Substr(aSM0[nX], 1, Len(AllTrim(SQ3->Q3_FILIAL)))
					If !( cFilSM0 == AllTrim(SQ3->Q3_FILIAL) )
						Loop
					EndIf
				EndIf
				fSetDeptoRJP(aSM0[nX], cProces, cChave, cOperacao, DDATABASE, cHoraAt, cUserId, .T.)
				lRet := .T.
			Next nX
		Else
			fSetDeptoRJP(cFIlSQ3, cProces, cChave, cOperacao, DDATABASE, cHoraAt, cUserId)
			lRet := .T.
		EndIf	
		
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldAtiv()
Função que efetua a verificação se há funcionários ativos vinculados ao cargo
@author  Allyson Luiz Mesashi
@since   28/04/2022
/*/
//-------------------------------------------------------------------
Static Function fVldAtiv( cCodCargo )

Local cAliasQRY	:= "QRYSRA"
Local cQuery	:= ""
Local cTabSRA	:= RetSqlName("SRA")
Local cTabSQ3	:= RetSqlName("SQ3")
Local lTemAtiv	:= .F.

cQuery	:= "SELECT COUNT(*) AS CONT "
cQuery 	+= "FROM " + cTabSQ3 + " SQ3 "
cQuery 	+= "INNER JOIN " + cTabSRA + " SRA "
cQuery 	+= "ON " + FWJoinFilial( "SQ3", "SRA" ) + " AND SRA.RA_CARGO = SQ3.Q3_CARGO AND SRA.RA_SITFOLH != 'D' AND SRA.D_E_L_E_T_ = ' ' "
cQuery 	+= "WHERE SQ3.Q3_FILIAL = '" + xFilial("SQ3") + "' "
cQuery 	+= "AND SQ3.Q3_CARGO = '" + cCodCargo + "' "
cQuery 	+= "AND SQ3.D_E_L_E_T_ = ' ' "

dbUseArea(.T., "TOPCONN", TcGenQry( Nil, Nil, cQuery), cAliasQRY, .T., .T.)

lTemAtiv := (cAliasQRY)->CONT > 0

(cAliasQRY)->( dbCloseArea() )

Return lTemAtiv
