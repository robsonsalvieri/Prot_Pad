#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EEC.CH"
#include 'EICCP401.CH'
#Include "TOPCONN.CH"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"

static lCanUseApp

// Utilizadas para alterar o status do catalogo quando Integrado para obsoleto e a proxima sequencia do histórico ser incluído como Integrado (pendente: fabricante/país)
// Cenario: houve somente alteração de vinculação ou desvinculação do fabricante/país, devido a validação do portal unico "Já existem produtos semelhantes/idênticos cadastrado"
// não podemos mais consumir o post do catalogo sendo que nao houve alteração
static _lAltFabr  := .F. // Variavel para indicar que houve alteração do fabricante/origem
static _lAltInf   := .F. // Variavel para indicar que houve alteração de informação no catalogo de produto, exceto para as informações do fabricante/origem

/*
Programa   : EICCP4010   
Objetivo   : Rotina - Integração do Catalogo de Produtos
Retorno    : Nil
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function EICCP401(aCapaAuto,nOpcAuto)
Local lRet := .T.
Local aArea := GetArea()
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1
Local cModoAcEK9	:= FWModeAccess("EK9",3)
Local cModoAcEKA	:= FWModeAccess("EKA",3)
Local cModoAcEKB	:= FWModeAccess("EKB",3)
Local cModoAcEKD	:= FWModeAccess("EKD",3)
Local cModoAcEKE	:= FWModeAccess("EKE",3)
Local cModoAcEKF	:= FWModeAccess("EKF",3)
Local cModoAcSB1	:= FWModeAccess("SB1",3)
Local cModoAcSA2	:= FWModeAccess("SA2",3)
local lLibAccess  := .F.
local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

Private aRotina
Private lCP401Auto := ValType(aCapaAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
Private lMultiFil
Private lEkbPAis     := EKB->(ColumnPos("EKB_PAIS")) > 0
Private lEKFVincFB   := EKF->(ColumnPos("EKF_VINCFB")) > 0 
Private oChannel
Private oJsonAtt     := jsonObject():New()
Private lPOUIOKLD    := .F.

aCores :={{ "EKD_STATUS == '1' " ,"ENABLE"       ,STR0009 },; //"Integrado"
          { "EKD_STATUS == '6' " ,"BR_AZUL_CLARO",STR0028 },; //"Registrado Manualmente"
          { "EKD_STATUS == '5' " ,"BR_AZUL"      ,STR0027 },; //"Integrado (pendente: fabricante/país)"
          { "EKD_STATUS == '2' " ,"BR_AMARELO"   ,STR0008 },; //"Pendente de Integração"
          { "EKD_STATUS == '4' " ,"BR_PRETO"     ,STR0025 },; //"Falha de Integração"
          { "EKD_STATUS == '3' " ,"DISABLE"      ,STR0010 }} //"Obsoleto"

if lExecFunc
   FwBlkUserFunction(.T.)
endif

lLibAccess := AmIin(17)

if lExecFunc
   FwBlkUserFunction(.F.)
endif

if !lLibAccess
   return nil
endif

lMultiFil := cModoAcEK9 == "C" .and. (cModoAcSB1 == "E" .and. cModoAcSA2 == "E")

If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
   EasyHelp(STR0018,STR0014) //"O Modo de compatilhamento está diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "###Atenção
Else

	If !lCP401Auto
		oBrowse := FWMBrowse():New()                                 //Instanciando a Classe
		oBrowse:SetAlias("EKD")                                      //Informando o Alias 
		oBrowse:SetMenuDef("EICCP401")                               //Nome do fonte do MenuDef
		oBrowse:SetDescription(STR0007)                              //Histórico de Integração do Catálogo de Produtos 

		For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
		
		oBrowse:SetAttach( .T. )                                     //Habilita a exibição de visões e gráficos
		oBrowse:SetViewsDefault(GetVisions())                        //Configura as visões padrão
		oBrowse:ForceQuitButton()                                    //Força a exibição do botão fechar o browse para fechar a tela                                                              
		oBrowse:Activate()                                           //Ativa o Browse 
	Else
		aRotina	:= MenuDef(.T.)
		INCLUI := nOpcAuto == INCLUIR                                //Definições de WHEN dos campos
		ALTERA := nOpcAuto == ALTERAR
		EXCLUI := nOpcAuto == EXCLUIR
		If ALTERA .Or. EXCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) == 0
				EasyHelp(STR0019,STR0014)//"A Operação de Exclusão ou Alteração deve conter a Versão do Catálogo."####"Atenção"
				lRet := .F.
			EndIf
		EndIf
		If INCLUI
			If aScan(aCapaAuto,{|x| x[1] == "EKD_VERSAO"}) > 0
				EasyHelp(STR0020,STR0014)//"Na Operação de Inclusão não é permitido informar o campo de Versão do Catálogo."###"Atenção"
				lRet := .F.
			EndIf
		EndIf
		If lRet
			EasyMbAuto(nOpcAuto,aCapaAuto,"EKD",,,ModelDef(),{{"EKDMASTER",aCapaAuto}})
		EndIf
	EndIf
   FreeObj(oChannel)
EndIf
FreeObj(oJsonAtt)
RestArea(aArea)
Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aRotina
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function MenuDef(lExecauto)
Local aRotina := {}

Default lExecauto := .F.

aAdd( aRotina, { STR0001 , "AxPesqui"         , 0, 1, 0, NIL } )	//'Pesquisar'
aAdd( aRotina, { STR0002 , 'VIEWDEF.EICCP401' , 0, 2, 0, NIL } )	//'Visualizar'
If lExecauto
   aAdd( aRotina, { STR0003 , 'VIEWDEF.EICCP401' , 0, 3, 0, NIL } )	//'Incluir'
EndIf
aAdd( aRotina, { STR0026 , 'CP401Canc'        , 0, 4, 0, NIL } )	//'Tornar Obsoleto'
aAdd( aRotina, { STR0005 , 'VIEWDEF.EICCP401' , 0, 5, 0, NIL } )	//'Excluir'
aAdd( aRotina, { STR0006 , 'CP401Legen'       , 0, 1, 0, NIL } )	//'Legenda'
aAdd( aRotina, { STR0030 , 'CP401Log'         , 0, 2, 0, NIL } )	//'Log de Integração'


Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ModelDef()
Local oStruEKD			:= FWFormStruct( 1, "EKD", , /*lViewUsado*/ )
Local oStruEKE 		:= FWFormStruct( 1, "EKE", , /*lViewUsado*/ )
Local oStruEKF			:= FWFormStruct( 1, "EKF", , /*lViewUsado*/ )
Local oStruEKI			:= FWFormStruct( 1, "EKI", , /*lViewUsado*/ )
Local oModel			// Modelo de dados que será construído	
Local bPosValidacao	:= {|oModel| CP401POSVL(oModel)}
Local bCommit			:= {|oModel| CP401COMMIT(oModel)}
Local oMdlEvent      := CP401EV():New()
// Criação do Modelo
oModel := MPFormModel():New( "EICCP401", /*bPreValidacao*/, bPosValidacao, bCommit )
oModel:AddFields("EKDMASTER", /*cOwner*/ ,oStruEKD )                                               //Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:SetPrimaryKey( { "EKD_FILIAL", "EKD_COD_I" , "EKD_VERSAO"} )                                //Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0007)                                                                     //"Histórico de Integração do Catálogo de Produtos"
oModel:GetModel("EKDMASTER"):SetDescription(STR0007)                                               //Adiciona a descrição do Componente do Modelo de Dados "Histórico de Integração do Catálogo de Produtos "

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Relação de Produtos
oModel:AddGrid("EKEDETAIL","EKDMASTER", oStruEKE, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKEDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum PRODUTO //MFR 11/02/2022 OSSME-6595
oModel:GetModel("EKEDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKEDETAIL"):SetNoInsertLine(.T.)
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Fabricantes
oModel:AddGrid("EKFDETAIL","EKDMASTER", oStruEKF, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKFDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Fabricante
oModel:GetModel("EKFDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKFDETAIL"):SetNoInsertLine(.T.)
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")

// Adiciona ao modelo uma estrutura de formulário de edição por grid - Atributos
CpoModel( oStruEKI )
oModel:AddGrid("EKIDETAIL","EKDMASTER", oStruEKI, /*bLinePre*/ ,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
oModel:GetModel("EKIDETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Atributo
oModel:GetModel("EKIDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("EKIDETAIL"):SetNoInsertLine(.T.)
oStruEKI:RemoveField("EKI_COD_I")
oStruEKI:RemoveField("EKI_VERSAO")

//Modelo de relação entre Capa - Produto Referencia(EK9) e detalhe Relação de Produtos(EKA)

oModel:SetRelation('EKEDETAIL', {{ 'EKE_FILIAL'	, 'xFilial("EKE")'  },;
											{ 'EKE_COD_I'	, 'EKD_COD_I' },;
											{ 'EKE_VERSAO' , 'EKD_VERSAO'}}, EKE->(IndexKey(1)) )
							

oModel:SetRelation('EKFDETAIL', {{ 'EKF_FILIAL'	, 'xFilial("EKF")'  },;
											{ 'EKF_COD_I'	, 'EKD_COD_I' },;
											{ 'EKF_VERSAO' , 'EKD_VERSAO'}}, EKF->(IndexKey(1)) )

oModel:SetRelation('EKIDETAIL', {{ 'EKI_FILIAL'	, 'xFilial("EKI")'  },;
											{ 'EKI_COD_I'	, 'EKD_COD_I' },;
											{ 'EKI_VERSAO' , 'EKD_VERSAO'}}, EKI->(IndexKey(1)) )
										
oModel:InstallEvent("CP401EV", , oMdlEvent)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function ViewDef()
Local oStruEKD := FWFormStruct( 2, "EKD" )
Local oStruEKE := FWFormStruct( 2, "EKE", , /*lViewUsado*/ )
Local oStruEKF := FWFormStruct( 2, "EKF" )
Local oStruEKI := FWFormStruct( 2, "EKI" )
Local oView
Local oModel   := FWLoadModel( "EICCP401" )
Local cOrdIDPort
Local aFieldsEKD
Local nI
//Cria o objeto de View
oView := FWFormView():New()                          // Adiciona no nosso View um controle do tipo formulário
oView:SetModel( oModel )                             // Define qual o Modelo de dados será utilizado na View
//oView:SetContinuousForm(.T.)

// Cria o grupo de folders principal (100% da tela)
oView:CreateHorizontalBox('TELA', 100)
oView:CreateFolder("MAIN", "TELA") 

// Cria os folders
oView:addSheet("MAIN", "F_CATALOGO_PRODUTOS", STR0033) // "Catálogo de Produtos"
oView:addSheet("MAIN", "F_ATRIBUTOS", STR0024) // Relação de Atributos
oView:addSheet("MAIN", "F_RELACAO_PROD", STR0034) // "Relação de Produtos x Origens/Fabricantes"

// Cria as divisões nas telas
oView:CreateHorizontalBox( 'CAT_PROD'     , 100,,,'MAIN', 'F_CATALOGO_PRODUTOS')
oView:CreateHorizontalBox( 'REL_ATRI'     , 100,,,'MAIN', 'F_ATRIBUTOS')
oView:CreateHorizontalBox( 'REL_PROD_SUP' , 50 ,,,'MAIN', 'F_RELACAO_PROD')
oView:CreateHorizontalBox( 'REL_PROD_INF' , 50 ,,,'MAIN', 'F_RELACAO_PROD')

oView:AddField('CATALOGO_PRODUTOS', oStruEKD, 'EKDMASTER')
oView:SetOwnerView('CATALOGO_PRODUTOS', 'CAT_PROD')

oStruEKD:RemoveField("EKD_NALADI")
oStruEKD:RemoveField("EKD_GPCBRK")
oStruEKD:RemoveField("EKD_GPCCOD")
oStruEKD:RemoveField("EKD_UNSPSC")

oStruEKD:AddGroup("1", STR0035, "1", 2) //"Cadastrais"
oStruEKD:AddGroup("2", STR0036, "2", 2) //"Integração"
oStruEKD:AddGroup("3", STR0037, "3", 2) //"Dados Complementares"

aFieldsEKD := oStruEKD:GetFields()
For nI := 1 To Len(aFieldsEKD)
   aEval(aFieldsEKD, {|x| oStruEKD:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[11]) })
Next
oStruEKD:SetNoFolder(.T.)

If EKD->(ColumnPos("EKD_VATUAL")) > 0
   cOrdIDPort := oStruEKD:GetProperty("EKD_IDPORT", MVC_VIEW_ORDEM)
   oStruEKD:SetProperty("EKD_VATUAL", MVC_VIEW_ORDEM, Soma1(cOrdIDPort))
EndIf

If canUseApp()
   oView:AddOtherObject("VIEW_EKI", {|oPanel| CPCallApp(oPanel)})
Else
   //Identificação do componente
   oView:AddGrid("VIEW_EKI",oStruEKI , "EKIDETAIL")
   oView:EnableTitleView( "VIEW_EKI", STR0024 ) //"Relação de Atributos"

   oStruEKI:RemoveField("EKI_VERSAO")
   oStruEKI:RemoveField("EKI_COD_I")
   oStruEKI:RemoveField("EKI_VALOR")

   if oStruEKI:HasField("EKI_CONDTE")
      oStruEKI:RemoveField("EKI_CONDTE")
   endif
EndIf

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKE",oStruEKE , "EKEDETAIL")
oStruEKE:RemoveField("EKE_COD_I")
oStruEKE:RemoveField("EKE_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKE:RemoveField("EKE_FILORI")
EndIf

//Identificação do componente
oView:EnableTitleView( "VIEW_EKE", STR0021 ) //"Relação de Produtos"
oView:SetOwnerView( "VIEW_EKE", 'REL_PROD_SUP' )

// Devido as atualizações do portal unico, foi retirado a obrigatoriedade do campo TIN e criado um novo campo Codigo
// Assim será alterado o titulo do campo EKJ_TIN para Código e será o primeiro campo da tela, sendo não editável
// Observação: no portal unico foi migrado a informação cadastrado no campo TIN para o campo Código
oStruEKF:SetProperty('EKF_OPERFB' , MVC_VIEW_TITULO , STR0031 ) // "Código"
oStruEKF:SetProperty('EKF_OPERFB' , MVC_VIEW_DESCR  , STR0032 ) // "Código Portal Único"

//Adiciona no nosso View um controle do tipo FormGrid(antiga getdados)
oView:AddGrid("VIEW_EKF",oStruEKF , "EKFDETAIL")
oStruEKF:RemoveField("EKF_COD_I")
oStruEKF:RemoveField("EKF_VERSAO")
If IsMemVar('lMultiFil') .And. !lMultiFil
	oStruEKF:RemoveField("EKF_FILORI")
EndIf

//Identificação do componente
oView:EnableTitleView( "VIEW_EKF", STR0022 ) //"Relação de Fabricantes"

oView:SetOwnerView( "VIEW_EKF", 'REL_PROD_INF' )

//Identificação do componente
oView:SetOwnerView("VIEW_EKI", 'REL_ATRI')

Return oView

/*
Programa   : CP401Canc
Objetivo   : Cancelar um Registro
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Function CP401Canc(oMdl)
Local lRet := .T. 
Local oModel
Local lExec := .T.

   oModel := FWLoadModel("EICCP401")                                   //Carrega o modelo de dados para alteração
   oModel:SetOperation(4)
   oModel:Activate()

   If !oModel:GetModel():GetValue("EKDMASTER","EKD_STATUS") $ '1|6'
      EasyHelp(STR0013,STR0014) //"Apenas é possível cancelar registro de integração do catálogo de produto com os status '1-Integrado' e '6-Registrado Manualmente' " #Atenção
      lRet := .F.
   EndIf

   If lRet .And. !lCP401Auto
      lExec := MsgYesNo(STR0011)                                          //"Confirma o cancelamento do registro desta integração de produto do catálogo ?"
   EndIf

   If lRet .And. lExec
      oModel:GetModel():GetModel("EKDMASTER"):SetValue("EKD_STATUS",'3')  //Alteracao Status do registro
      If oModel:VldData()
         lRet := oModel:CommitData()
      Else
         lRet := .F.
      EndIf
      If !lRet
         EasyHelp(GetErrMessage(oModel),STR0014)
      EndIf
   EndIf

   oModel:Deactivate()
   //Limpa o Objeto pra liberar memória
   FreeObj(oModel)

Return lRet

/*
Programa   : CP401Fecha
Objetivo   : Ação ao clicar no botao cancelar
Retorno    : Logico
Autor      : Tiago Santos
Data/Hora  : Abril/2024
Obs.       :
*/
Static Function CP401Fecha(oPanel)
If canUseApp() .And. ValType(oChannel) == "O"
   oChannel:AdvPLToJS("closeAppProductCatalog",'') //Força fechar o App
   FreeObj(oChannel)
   FreeObj(oPanel)
EndIf
Return .T.

/*
Programa   : CP401POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Nilson Cesar
Data/Hora  : 09/12/2019
Obs.       :
*/
Static Function CP401POSVL(oMdl)
Local lRet := .T.

Do Case 
   Case oMdl:GetOperation() == 5  //Excluir
	   If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") <> "2"
		   EasyHelp(STR0012,STR0014) //"Apenas é possível excluir registro de integração do catálogo de produto com status '2-Não integrado' " #Atenção
		   lRet := .F.
	   EndIf
   Case oMdl:GetOperation() == 4  //Cancelar
      If oMdl:GetModel():GetValue("EKDMASTER","EKD_STATUS") == '3' .And. !EKD->EKD_STATUS $ '1|6'
		   EasyHelp(STR0013,STR0014) //"Apenas é possível cancelar registro de integração do catálogo de produto com status '1-Integrado' ou '6-Registrado Manualmente' " #Atenção
		   lRet := .F.
      EndIf
		
End Case

Return lRet

Static Function CP401COMMIT(oMdl)
Local lRet := .T.
Local cErro:= ""
Local cCatalogo := oMdl:GetModel():GetValue("EKDMASTER","EKD_COD_I")
Begin Transaction
	If oMdl:GetOperation() == 3  //Incluir	
		If TemNaoInteg(cCatalogo) //Posciona EKD
			cErro := DelNaoInteg(cCatalogo,EKD->EKD_VERSAO)
		EndIf
		If Empty(cErro)
			CancelaTudo(oMdl, cCatalogo)
		EndIf
	ElseIf oMdl:GetOperation() == 4  //Tornar Obsoleto
      EK9->(dbSetOrder(1))
      If EK9->(dbSeek( xFilial("EK9") + cCatalogo ))
         EK9->(RecLock("EK9",.F.))
         EK9->EK9_STATUS := "4" //Bloqueado
         EK9->EK9_VSMANU := " "
         EK9->EK9_VATUAL := " "
         EK9->(MsUnlock())
      EndIf

   EndIf
	If Empty(cErro)
		FWFormCommit(oMdl)
	Else
		DisarmTransaction()
	EndIf
End Transaction

If !Empty(cErro)
	EasyHelp(cErro,STR0014)
	lRet := .F.
EndIf

if !FWIsInCallStack("DelNaoInteg")
   CP401AltInf(.F.)
   setAltFab(.F.)
endif

Return lRet
/*
Programa   : CP401Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP401Legen()
Local aCores := {}

   aCores := { {"BR_AMARELO"   ,STR0008 },; //"Pendente de Integração"
               {"ENABLE"       ,STR0009 },; //"Integrado"
               {"BR_AZUL"      ,STR0027 },; //"Integrado (pendente: fabricante/país)"
               {"BR_AZUL_CLARO",STR0028 },; //"Registrado Manualmente"
               {"BR_VERMELHO"  ,STR0010 },; //"Obsoleto"
               {"BR_PRETO"     ,STR0025 }}  //"Falha de Integração"

   BrwLegenda(STR0007,STR0006,aCores) // "Histórico de Integração do Catálogo de Produtos" 

Return .T.

/*
Programa   : CP401IniBw
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_INIPAD do cadastro do campo.
*/
Function CP401IniBw(cCpo)
Local xRet
Local oModel,oModelEKD

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")

   Do Case
      Case cCpo == "EKD_VERSAO"
         xret := Replicate(" ",TamSx3("EKD_VERSAO")[1] )
      Case cCpo == "EKD_STATUS"
         xRet := "2"
   End Case
Return xRet

/*
Programa   : CP401Trigg
Objetivo   : Executa os gatilhos dos campos da EKD
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_REGRA do gatilho do campo.
*/
Function CP401Trigg(cCpo)
Local xRet  := ""
Local oModel,oModelEKD,oModelEKE,oModelEKF,oModelEKI
Local lPosicEK9      := .F.
local cCodI      := ""
local cSequencia := ""

   oModel    := FWModelActive()
   oModelEKD := oModel:GetModel("EKDMASTER")
   oModelEKE := oModel:GetModel("EKEDETAIL")
   oModelEKF := oModel:GetModel("EKFDETAIL")
   oModelEKI := oModel:GetModel("EKIDETAIL")

   EK9->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão Atual
   cCodI := oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I")

   If EK9->(dbSeek( xFilial("EK9") + cCodI )) 
      lPosicEK9 := .T.
   EndIf

   if lPosicEK9
      Do Case
         Case cCpo == "EKD_COD_I"

            EKD->(DbSetOrder(1))
            If EKD->(AvSeekLAst( xFilial("EKD") + cCodI ))
               cSequencia := EKD->EKD_VERSAO
               //Se status for nao integrado, deve manter a mesam versao, pois ao salvar a versao nao integrada sera excluida
               If EKD->EKD_STATUS == '2'
                  xRet := EKD->EKD_VERSAO
               else
                  xRet := Avkey(SomaIt(alltrim(EKD->EKD_VERSAO)),"EKD_VERSAO")
               EndIf
            Else
               xRet := AvKey('1',"EKD_VERSAO")
            EndIf

            setAltFab(.F.)

            LoadCpoMod( oModelEKD, cCodI, cSequencia )
            LoadModEKE( oModelEKE, cCodI, cSequencia )
            LoadModEKF( oModelEKF )
            LoadModEKI( oModelEKI, cCodI, cSequencia )

      End Case
   endif

Return xRet

/*
Programa   : CP401SX7Cd
Objetivo   : Determina se o gatilho de um campo da EKD será executado.
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X7_COND do gatilho do campo.
*/
Function CP401SX7Cd(cCpo)
Local lRet
Local oModel,oModelEKD

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")
Do Case
   Case cCpo == "EKD_COD_I"
      lRet := !Empty(oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I"))
EndCase

Return lRet

/*
Programa   : CP401Val
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       : Disparada do X3_VALID do cadastro do campo.
*/
Function CP401Val(cCpo)
Local lRet := .T.
Local oModel,oModelEKD,cCod_I

oModel    := FWModelActive()
oModelEKD := oModel:GetModel("EKDMASTER")

Do Case
   Case cCpo == "EKD_COD_I"
      cCod_I := oModelEKD:GetModel():GetValue("EKDMASTER","EKD_COD_I")
      lRet := ExistCpo( "EK9", cCod_I , 1 )
		If lRet .And. TemNaoInteg(cCod_I) //Verifica se ja existe registro nao integrado para o codigo informado
			If IsMemVar("lCP401Auto") .And. !lCP401Auto 
				MsgInfo(STR0023,STR0014)//"Foi identificado um registro com o Status 'Não integrado' para este mesmo código. O registro será excluído automaticamente ao confirmar a inclusão deste novo registro."###"Atenção"
			EndIf
		EndIf
End Case

Return lRet

/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("EKD")
Local aContextos := {"NAO_INTEGRADO", "INTEGRADO", "INTEGRADO_PENDENTE_FABRICANTE_PAIS","REGISTRADO_MANUALMENTE", "CANCELADO", "FALHA_INTEGRACAO"}
Local cFiltro
Local i

      If aScan(aColunas, "EKD_FILIAL") == 0
         aAdd(aColunas, "EKD_FILIAL")
      EndIf

      For i := 1 To Len(aContextos)
         cFiltro := RetFilter(aContextos[i])
         oDSView := FWDSView():New()
         oDSView:SetName(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .T.))
         oDSView:SetPublic(.T.)
         oDSView:SetCollumns(aColunas)
         oDSView:SetOrder(1)
         oDSView:AddFilter(AllTrim(Str(i)) + "-" + RetFilter(aContextos[i], .F.), cFiltro)
         oDSView:SetID(AllTrim(Str(i)))
         oDsView:SetLegend(.T.)
         aAdd(aVisions, oDSView)
      Next

Return aVisions

/*
Função     : RetFilter(cTipo)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
Local cRet		:= ""
Default lNome	:= .F.

      Do Case
         Case cTipo == "NAO_INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '2' "
         Case cTipo == "NAO_INTEGRADO" .And. lNome
            cRet := STR0008 //"Pendente de Integração"

         Case cTipo == "INTEGRADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '1' "
         Case cTipo == "INTEGRADO" .And. lNome
            cRet  := STR0009 //"Integrado"

         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. !lNome
            cRet := "EKD->EKD_STATUS = '5' "
         Case cTipo == "INTEGRADO_PENDENTE_FABRICANTE_PAIS" .and. lNome
            cRet := STR0027 //"Integrado (pendente: fabricante/país)" 
            
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. !lNome
            cRet := "EKD->EKD_STATUS = '6' "
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. lNome
            cRet := STR0028 //"Registrado Manualmente"

         Case cTipo == "CANCELADO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '3' "
         Case cTipo == "CANCELADO" .And. lNome
            cRet := STR0010 //"Obsoleto"

         Case cTipo == "FALHA_INTEGRACAO" .And. !lNome
            cRet := "EKD->EKD_STATUS = '4' "
         Case cTipo == "FALHA_INTEGRACAO" .And. lNome
            cRet := STR0025 //"Falha de Integração"

      EndCase

Return cRet

Static Function LoadCpoMod( oMdl , cCodI, cSequencia )
Local aArea			:= GetArea()
Local lRet
local aAreaEKD    := {}
local lAltCat     := .F.

default cCodI      := ""
default cSequencia := ""

If ValType(oMdl) == "O" .And. EK9->(!Eof())   
   oMdl:SetValue("EKD_IDPORT",EK9->EK9_IDPORT)   
   oMdl:SetValue("EKD_CNPJ"  ,AvKey(EK9->EK9_CNPJ, "EKD_CNPJ"))
   oMdl:SetValue("EKD_MODALI",EK9->EK9_MODALI)
   oMdl:SetValue("EKD_NCM"   ,EK9->EK9_NCM)
   oMdl:SetValue("EKD_UNIEST",EK9->EK9_UNIEST)
   oMdl:SetValue("EKD_OBSINT",EK9->EK9_OBSINT)
   If EK9->EK9_STATUS == "5" .And. IsMemVar("lCP401Auto") .And. lCP401Auto  //Registrado Manualmente - Integrado via Catálogo
      oMdl:SetValue("EKD_STATUS","6")
      If EKD->(ColumnPos("EKD_VATUAL")) > 0
         oMdl:SetValue("EKD_VATUAL",EK9->EK9_VATUAL)
      EndIf
   EndIf
   //oMdl:SetValue("EKD_USERIN",cUserNAme) //Sera gravado o usuario da integração

   if !empty(cSequencia) .and. !getAltInf()
      aAreaEKD := EKD->(getArea())
      EKD->(dbSetOrder(1)) // EKD_FILIAL+EKD_COD_I+EKD_VERSAO
      if EKD->(dbSeek(xFilial("EKD") + cCodI + cSequencia))
         lAltCat := !(EKD->EKD_CNPJ == EK9->EK9_CNPJ) .or. !(EKD->EKD_MODALI == EK9->EK9_MODALI)
         CP401AltInf(lAltCat)
      endif
      restArea(aAreaEKD)
   endif

   lRet := .T.
Else
   lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*
Função     : LoadModEKE(oModel)
Objetivo   : Carregar dados de relação de produtos do catalogo
Parâmetros : oModel - objeto do grid relaçao de prod
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Static Function LoadModEKE( oModelEKE, cCodI, cSequencia)
Local aArea  	:= getArea()
Local nContLn	:= 1
Local lRet 		:= .F.
local aAreaEKE := {}
local lAltProd := .F.
local cDesc    := ""

default cCodI      := ""
default cSequencia := ""

If Valtype(oModelEKE) == "O" .And. EK9->(!Eof())
	oModelEKE:SetNoDeleteLine(.F.)
	oModelEKE:SetNoInsertLine(.F.)
   If oModelEKE:Length() > 0
      CP400Clear(oModelEKE)
   EndIf
   DbSelectArea("EKA")
   EKA->(DbSetOrder(1)) //EKA_FILIAL+EKA_COD_I+EKA_PRDREF+EKA_ITEM
   If MsSeek(xFilial("EKA")+EK9->EK9_COD_I)

      if !empty(cSequencia)
         aAreaEKE := EKE->(getArea())
         EKE->(dbSetOrder(1)) // EKE_FILIAL+EKE_COD_I+EKE_VERSAO+EKE_ITEM
      endif

      While EKA->(!EOF()) .And. xFilial("EKA")+EKA->EKA_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I
         If nContLn <> 1
           oModelEKE:AddLine()
         EndIf
         oModelEKE:GoLine(nContLn)
         oModelEKE:SetValue("EKE_FILIAL" , EKA->EKA_FILIAL)
         oModelEKE:SetValue("EKE_ITEM"   , EKA->EKA_ITEM)
         oModelEKE:SetValue("EKE_PRDREF" , EKA->EKA_PRDREF)
         cDesc := Posicione("SB1",1, if( lMultiFil, EKA->EKA_FILORI, xFilial("SB1")) + AvKey(EKA->EKA_PRDREF,"B1_COD"),"B1_DESC")
         if( lMultiFil, oModelEKE:SetValue("EKE_FILORI" , EKA->EKA_FILORI), nil )
         oModelEKE:SetValue("EKE_DESC_I" , cDesc)
         
         if !getAltInf()
            lAltProd := empty(cSequencia) .or. !EKE->(dbSeek(xFilial("EKE") + cCodI + cSequencia + EKA->EKA_ITEM))
            CP401AltInf(lAltProd)
         endif

         lRet := .T.
         nContLn++
         EKA->(DbSkip())
      EndDo

      if !empty(cSequencia)
         restArea(aAreaEKE)
      endif
   else
      if !getAltInf() .and. !empty(cSequencia)
         lAltProd := EKE->(dbSeek(xFilial("EKE") + cCodI + cSequencia ))
         CP401AltInf(lAltProd)
      endif
   EndIf
   oModelEKE:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKE:SetNoDeleteLine(.T.)
oModelEKE:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Função     : LoadModEKF(oModel)
Objetivo   : Carregar dados de relação de fabricantes do catalogo
Parâmetros : oModel - objeto do grid relaçao de fabric.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Static Function LoadModEKF( oModelEKF )
Local aArea  	   := getArea()
Local nContLn	   := 1
Local lRet 		   := .F.
Local QryFb       := ""
Local cCatalogo   := ""
Local cChaveEKJ   := ""
Local cChaveSA2   := ""
Local cPais       := ""
local cSequencia  := ""
local nTamNome    := 0
local nTamDesc    := 0

If Valtype(oModelEKF) == "O" .And. EK9->(!Eof())

	oModelEKF:SetNoDeleteLine(.F.)
	oModelEKF:SetNoInsertLine(.F.)   
   If oModelEKF:Length() > 0
      CP400Clear(oModelEKF)
   EndIf 

   EKJ->(dbsetorder(1))
   EKF->(dbsetorder(1))

   cCatalogo := EK9->EK9_COD_I  
   cSequencia := CP401GetVs(cCatalogo)

   DbSelectArea("EKB")
   EKB->(DbSetOrder(1)) //EKB_FILIAL+EKB_COD_I+EKB_CODFAB+EKB_LOJA
   If EKB->(DbSeek(xFilial("EKB")+cCatalogo) )

      SA2->(dbsetorder(1))

      QryFb := " SELECT EKB_CODFAB, EKB_LOJA, D_E_L_E_T_ AS DELETED"  
      If lEkbPAis
         QryFb += ", EKB_PAIS "
      EndIf
      If lMultifil
         QryFb += ", EKB_FILORI "
      EndIf
      
      QryFb += " FROM " + RetSQLName("EKB")
      QryFb += " WHERE EKB_FILIAL = '" + xFilial("EKB") + "' "
      QryFb += "   AND EKB_COD_I  = '" + cCatalogo + "' "
      QryFb += "   AND D_E_L_E_T_ = ' ' " 
      QryFb:= ChangeQuery(QryFb)
      DBUseArea(.T., "TopConn", TCGenQry(,, QryFb), "WkQryFb", .T., .T.)

      WkQryFb->(DBGoTop())
      nTamNome := AvSX3("EKF_NOME", AV_TAMANHO)
      nTamDesc := AvSX3("EKF_PAISDS", AV_TAMANHO)
   
      While WkQryFb->(!EOF()) 
         // lDeletedFB := .F.   //Retirado as ocorrências da variável lDeleteFB, não tem sentido tratar registros deletados
         If nContLn <> 1
            oModelEKF:AddLine()
         EndIf

         cChaveSA2 := if(lMultiFil,WkQryFb->EKB_FILORI,XFILIAL("SA2")) + WkQryFb->EKB_CODFAB+WkQryFb->EKB_LOJA
         SA2->(dbSeek(cChaveSA2))

         oModelEKF:GoLine(nContLn)
         oModelEKF:SetValue("EKF_CODFAB", WkQryFb->EKB_CODFAB)
         oModelEKF:SetValue("EKF_LOJA", WkQryFb->EKB_LOJA)
         oModelEKF:SetValue("EKF_NOME", PadR(SA2->A2_NOME, nTamNome))
         If( lMultiFil, oModelEKF:SetValue("EKF_FILORI",WkQryFb->EKB_FILORI), nil )

         If lEkbPais
            oModelEKF:SetValue("EKF_PAIS", WkQryFb->EKB_PAIS)
            oModelEKF:LoadValue("EKF_PAISDS", PadR( POSICIONE("ELO",1,xFilial("ELO")+WkQryFb->EKB_PAIS,"ELO_DESC"),nTamDesc) ) // POSICIONE("SYA",1,xFilial("SYA")+WkQryFb->EKB_PAIS,"YA_DESCR"))
            cPais := WkQryFb->EKB_PAIS
         EndIf   

         cChaveEKJ := xFilial("EKJ")+EK9->EK9_CNPJ+SA2->A2_COD+SA2->A2_LOJA
         If EKJ->(msseek(cChaveEKJ)) 
            oModelEKF:LoadValue("EKF_OPERFB", EKJ->EKJ_TIN)
         EndIf
      
         If lEKFVincFB 
            oModelEKF:LoadValue("EKF_VINCFB", CP401Vinc( cCatalogo, cSequencia, WkQryFb->EKB_CODFAB, WkQryFb->EKB_LOJA, cPais)) //o default é False,lDeletedFB  
         EndIf

         lRet := .T.
         nContLn++
         WkQryFb->(DbSkip())
      EndDo  
      WkQryFb->(dbcloseArea())       
     
   EndIf

   If lEKFVincFB 
      EKFDesvinc(oModelEKF, cCatalogo, cSequencia)
   endif
   
   oModelEKF:GoLine(1)
Else
   lRet := .F.
Endif
oModelEKF:SetNoDeleteLine(.T.)
oModelEKF:SetNoInsertLine(.T.)
RestArea(aArea)
Return lRet

/*
Função     : CP401Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Parâmetros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :  
*/
Function CP401Gatil(cCampo)
Local aArea		   := GetArea()
Local oModel	   := FWModelActive()
Local oGridEKF    := oModel:GetModel("EKFDETAIL")
Local cRet        := ""

If cCampo == "EKF_PAISDS"   
   If !Empty(oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()))
      cRet := POSICIONE("ELO",1,xFilial("ELO") + oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()),"ELO_DESC")  // POSICIONE("SYA",1,xFilial("SYA")+oGridEKF:getvalue("EKF_PAIS",oGridEKF:getline()),"YA_DESCR")
   EndIf    
EndIf

RestArea(aArea)
Return cRet

/*
Função     : CP401GetVs()
Objetivo   : Retornar a ultima versao do historico de integracao
Parâmetros : 
Retorno    : lRet - ultima versao 
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function CP401GetVs(cCatalogo)
Local cVersao := ""
Local aArea := GetArea()

EKD->(DbSetOrder(1)) // EKD_FILIAL+EKD_COD_I+EKD_VERSAO 
If EKD->(AvSeekLAst( xFilial("EKD") + cCatalogo ))
   cVersao := EKD->EKD_VERSAO
EndIf

RestArea(aArea)
Return cVersao


/*
Função     : LoadModEKI(oModel)
Objetivo   : Carregar dados de relação de atributos do catalogo
Parâmetros : oModel - objeto do grid relaçao de atributos.
Retorno    : lRet - Retorno se foram carregados os dados na tela
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Static Function LoadModEKI( oModelEKI, cCodI, cSequencia)
Local aArea    := getArea()
Local aAreaEKC := EKC->(getArea())
Local aAreaEKG := EKG->(getArea())
Local nContLn	:= 1
Local lRet     := .F.
Local cNome    := ""
Local cChaveEKG:= ""
local lCondic    := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
local cCodAtrib  := ""
local cCodCondic := ""
local nPosOrdem  := 0
local nOrdem     := 0
local nOrdCond   := 0
local aOrderAtrb := {}
local cOrdem     := ""
local aAreaEKI   := {}
local lAltCat    := .F.

default cCodI      := ""
default cSequencia := ""

   If Valtype(oModelEKI) == "O" .And. EK9->(!Eof())
      oModelEKI:SetNoDeleteLine(.F.)
      oModelEKI:SetNoInsertLine(.F.)
      If oModelEKI:Length() > 0
         CP400Clear(oModelEKI)
      EndIf
      DbSelectArea("EKC")
      EKC->(DbSetOrder(1)) //EKC_FILIAL+EKC_COD_I+EKC_CODATR
      If MsSeek(xFilial("EKC")+EK9->EK9_COD_I)

         if !empty(cSequencia)
            aAreaEKI := EKI->(getArea())
            EKI->(dbSetOrder(1)) // EKI_FILIAL+EKI_COD_I+EKI_VERSAO+EKI_CODATR+EKI_CONDTE
         endif

         EKG->(dbsetorder(1))
         While EKC->(!EOF()) .And. xFilial("EKC")+EKC->EKC_COD_I == EK9->EK9_FILIAL+EK9->EK9_COD_I

            if lCondic
               cCodAtrib := EKC->EKC_CODATR
               cCodCondic := EKC->EKC_CONDTE
               if !empty(cCodCondic)
                  nPosOrdem := aScan( aOrderAtrb, { |X| X[1] == cCodCondic .and. empty(X[2]) })
                  if nPosOrdem > 0
                     nOrdem := aOrderAtrb[nPosOrdem][3]
                     nOrdCond := aOrderAtrb[nPosOrdem][4]
                  endif
                  nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) } )
                  if nPosOrdem > 0
                     while nPosOrdem > 0
                        nOrdCond := if( nOrdCond <= aOrderAtrb[nPosOrdem][4], aOrderAtrb[nPosOrdem][4], nOrdCond )
                        nPosOrdem := aScan( aOrderAtrb, { |X| X[2] == cCodCondic .and. !empty(X[1]) }, nPosOrdem+1 )
                     end
                  endif
                  nOrdCond += 1
               else
                  nOrdem += 1
                  if aScan( aOrderAtrb, { |X| X[1] == cCodAtrib }) == 0
                     nOrdCond := 0
                  endif
               endif
               cOrdem := StrZero(nOrdem,3) + "_" + StrZero(nOrdCond,3)
               aAdd( aOrderAtrb , { cCodAtrib, cCodCondic, nOrdem, nOrdCond} )
            endif

            //Se utilizar campos da EKG só usar após a linha de baixo onde posiciona o registro nesta tabela
            cChaveEKG := xFilial("EKG")+EK9->EK9_NCM+EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"")
            EKG->(msseek(cChaveEKG)) // POSICIONE("EKG",1,xFilial("EKC")+EK9->EK9_NCM+EKC->EKC_CODATR,"EKG_NIVIG")
            If nContLn <> 1
               oModelEKI:AddLine()
            EndIf
            cNome := (iif(EKG->EKG_OBRIGA == "1","* ","")) + AllTrim(EKG->EKG_NOME)
            oModelEKI:GoLine(nContLn)
            oModelEKI:SetValue("EKI_CODATR"  ,EKC->EKC_CODATR)
            oModelEKI:SetValue("EKI_STATUS"  ,CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG))
            oModelEKI:SetValue("EKI_NOME"    , cNome )
            oModelEKI:SetValue("EKI_VALOR"   ,EKC->EKC_VALOR/*CP401Valor(alltrim(EKG->EKG_FORMA),.F.)*/)
            oModelEKI:SetValue("EKI_VLEXIB"  ,CP401Valor(alltrim(EKG->EKG_FORMA),.T.))
            if lCondic
               oModelEKI:SetValue("EKI_CONDTE"  , EKC->EKC_CONDTE)
               if( empty(oModelEKI:GetValue("ATRIB_ORDEM")), oModelEKI:LoadValue("ATRIB_ORDEM", cOrdem ) , )
            endif

            if !getAltInf()
               lAltCat := empty(cSequencia) .or. ;
                        !EKI->(dbSeek(xFilial("EKI") + cCodI + cSequencia + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE, "") )) .or. ;
                        !(EKI->EKI_VALOR == EKC->EKC_VALOR)
               CP401AltInf(lAltCat)
            endif

            lRet := .T.
            nContLn++
            EKC->(DbSkip())
         EndDo
      EndIf

      if !empty(cSequencia)
         restArea(aAreaEKI)
      endif

      if lCondic
         OrdAtrib(oModelEKI)
      endif
      oModelEKI:GoLine(1)
      oModelEKI:SetNoDeleteLine(.T.)
      oModelEKI:SetNoInsertLine(.T.)
   Else
      lRet := .F.
   Endif

   RestArea(aArea)
   RestArea(aAreaEKC)
   RestArea(aAreaEKG)

Return lRet

/*
Função     : CP401Vinc()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Parâmetros : Cod do Catalogo, FAbri, Loja, Pais do Fabr.
Retorno    : Retorna a string com o status do vinculo
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function CP401Vinc(cCatalog, cVersaoEKF, cCodFab, cLojaFab, cPaisFb)
Local cVinculo    := "1" //vincular ao catálogo 
Local aArea       := GetArea()
 
If !Empty(cVersaoEKF) .and. EKF->(dbSeek(xFilial("EKF") + cCatalog + cVersaoEKF + cCodFab + cLojaFab + cPaisFb))
   // caso no histórico esteja com status 2 (Desvincular)  -> significa que no portal unico já está vinculado no catalogo, ou seja, gravo com status de vinculado 4
   // caso no histórico esteja com status 5 (Desvinculado) -> significa que no potal unico está desvinculado, assim tenho que vincular novamente, ou seja, gravo com status de vincular 1 
   // caso no histórico esteja com status 1 (Vincular)     -> significa que tenho que continuar com status vincular, pois ainda não houve o vinculado com o portal unico
   // caso no histórico esteja com status 4 (Vinculado)    -> significa que tenho que continuar com status vinculado, pois no portal unico já esta vinculado
   cVinculo := if( EKF->EKF_VINCFB == "1" .or. EKF->EKF_VINCFB == "4", EKF->EKF_VINCFB , if( EKF->EKF_VINCFB == "2", "4", cVinculo) )// 1=Vincular ao catálogo;2=Desvincular do catálogo;3=Sem alteração;4=Vinculado ao catálogo;5=Desvinculado do catálogo
EndIf

setAltFab(cVinculo == "1") 

RestArea(aArea)
Return cVinculo

/*
Função     : CP401Valor()
Objetivo   : Carregar o valor de acordo com a forma de preenchimento
Parâmetros : lTrunca, se true trunca o valor do tipo texo em 100 posições
Retorno    : Retorna a stringa com o valor
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP401Valor(cForma,lTrunca)
Local cRetorno:=""

DO CASE
   CASE cForma == "LISTA_ESTATICA"
      cRetorno := Substr(getAtrName(EKC->EKC_VALOR, EK9->EK9_NCM, EKC->EKC_CODATR),1,100)
      //cRetorno := alltrim(EKC->EKC_VALOR) + "-" + POSICIONE("EKH",1,xFilial("EKH")+EK9->EK9_NCM+EKC->EKC_CODATR+EKC->EKC_VALOR,"EKH_DESCRE")
   CASE cForma == "BOOLEANO"
        cRetorno := if(EKC->EKC_VALOR == "", "", if(EKC->EKC_VALOR =="1", "SIM", "NAO"))
   CASE cForma == "TEXTO"
        cRetorno := if(lTrunca,substr(EKC->EKC_VALOR,1,100),EKC->EKC_VALOR)
   otherwise // CASE cForma == "NUMERO_REAL"
        cRetorno := EKC->EKC_VALOR
EndCase
Return cRetorno


Static Function GetErrMessage(oModel)
Local cRet := ""
Local aErro

aErro   := oModel:GetErrorMessage(.T.)
// A estrutura do vetor com erro é:
//  [1] Id do formulário de origem
//  [2] Id do campo de origem
//  [3] Id do formulário de erro
//  [4] Id do campo de erro
//  [5] Id do erro
//  [6] mensagem do erro
//  [7] mensagem da solução
//  [8] Valor atribuido
//  [9] Valor anterior

If !Empty(aErro[4]) .AND. SX3->(dbSetOrder(2),dbSeek(aErro[4]))
   xInfo := if(ValType(aErro[8])=="U",aErro[9],aErro[8])
   cRet += "Erro ao preencher campo '"+PadR(AvSX3(aErro[4],AV_TITULO),Len(SX3->X3_TITULO))+"' com valor "+if(ValType(xInfo)=="C","'","")+AllTrim(AvConvert(ValType(xInfo),"C",,xInfo))+if(ValType(xInfo)=="C","'","")+": "+aErro[6]+" "
Else
   cRet += "Registro Inválido ("+AllTrim(aErro[3])+"): "+AllTrim(aErro[6])+IF(Len(aErro[7]) > 2," Solução: "+AllTrim(aErro[7]),"")
EndIf

Return cRet

/*
Função     : CP400Clear(oModel)
Objetivo   : Limpar dados do grid desejado
Parâmetros : oModel - objeto do grid 
Retorno    : lRet - Retorno se foi feito com sucesso a limpa dos dados
Autor      : Ramon Prado
Data       : Jan/2020
Revisão    :
*/
Static Function CP400Clear(oModel)
Local aArea   		  := GetArea()
Local lRet	    	  := .F.
Local nI := 0

For nI := 1 To oModel:Length()
   oModel:GoLine( nI )
   If !oModel:IsDeleted()
      oModel:DeleteLine()
   EndIf
Next

oModel:ClearData()

RestArea(aArea)
Return lRet

/*
Programa   : TemNaoInteg
Objetivo   : Verifica se para o codigo informado, existe registro nao integrado
Retorno    : .T. quando encontrar registro nao integrado; .F. não encontrar registro nao integrado
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function TemNaoInteg(cCod_I)
Local lRet := .F.
Local cQuery:= GetNextAlias()

BeginSQL Alias cQuery
   SELECT R_E_C_N_O_ RECNO 
   FROM %Table:EKD% EKD
      WHERE EKD_FILIAL = %xFilial:EKD%
        AND EKD_COD_I  = %Exp:cCod_I%
        AND EKD_STATUS = '2' 
        AND EKD.%NotDel%
EndSQL

If (cQuery)->(!Eof())
	lRet := .T.
   EKD->(dbGoTo((cQuery)->(RECNO)))
EndIf
(cQuery)->(dbCloseArea())
Return lRet

/*
Programa   : DelNaoInteg
Objetivo   : Delete o registro nao integrado ao incluir um novo registro.
Retorno    : .T. caso a exclusão tenha sido realizada; .F. caso não tenha sido efetivada a exclusão
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 02/01/2020
*/
Static Function DelNaoInteg(cCod_I,cVersaoEKD)
Local cRet  	:= ""
Local aCapaEKD := {}
Local oErro		:= AvObject():New()
aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")	, Nil})
aAdd(aCapaEKD,{"EKD_COD_I"	, cCod_I				, Nil})
aAdd(aCapaEKD,{"EKD_VERSAO", cVersaoEKD		, Nil})

EasyMVCAuto("EICCP401",5,{{"EKDMASTER", aCapaEKD}},oErro)
If oErro:HasErrors()
	cRet := oErro:GetStrErrors()
EndIf

Return cRet

/*
Programa   : CancelaTudo
Objetivo   : Alterar o status de todos os registros do codigo informado para 3-Cancelado
Retorno    : -
Autor      : THTS - Tiago Henrique Tudisco dos Santos
Data/Hora  : 30/12/2019
*/
Static Function CancelaTudo(oMdl, cCod_I)
Local aAreaEKD := EKD->(getArea())
Local aAreaEK9 := EK9->(getArea())
Local lTemEK9
local cVerAtual  := ""
local lVerAtual  := EKD->(ColumnPos("EKD_VATUAL")) > 0
local oModelEKD  := oMdl:GetModel("EKDMASTER")
local lIntStat   := .F. // Variavel para indicar o status integrado ou integrado (pendente: fabricante/país)
local nRecEKD    := 0   // Variavel para armazenar o ultimo recno da tabela EKD
local lAtualEK9  := .F.

EKD->(dbSetOrder(1)) //EKD_FILIAL, EKD_COD_I, EKD_VERSAO
If EKD->(dbSeek(xFilial("EKD") + cCod_I))
   lTemEK9     := EK9->(dbSeek( xFilial("EK9") + cCod_I ))
   lTemVersao  := lTemEK9 .And. !Empty(EK9->EK9_VATUAL)
	While EKD->(!EOF()) .And. EKD->EKD_FILIAL == xFilial("EKD") .And. EKD->EKD_COD_I == cCod_I
      if EKD->EKD_STATUS == '1' .or. ( EKD->EKD_STATUS == '5' .and. lTemVersao ) // 1=Integrado | 5 =Integrado (pendente: fabricante/país)
         lIntStat := .T.
         nRecEKD := EKD->(recno())
         if lVerAtual
            cVerAtual := EKD->EKD_VATUAL
         endif

      elseif EKD->EKD_STATUS $ '2|4|' .Or. (EKD->EKD_STATUS == "6" .And. lTemVersao) .or. ( EKD->EKD_STATUS == '5' .and. !lTemVersao ) // 2=Pendente Registro | 4=Falha de integração | 6=Registrado Manualmente
			RecLock("EKD",.F.)
			EKD->EKD_STATUS := '3' // Obsoleto
			EKD->(MsUnlock())
		EndIf
		EKD->(dbSkip())
	End

   // Caso não houve alteração no catalogo de produtos e a ultima versão do historico é integrado ou integrado (pendente: fabricante/país) com versão informada
   if !getAltInf() .and. lIntStat .and. nRecEKD > 0 .and. !empty(cVerAtual) .and. valtype(oModelEKD) == "O"
      EKD->(dbGoTo(nRecEKD))
      RecLock("EKD",.F.)
      EKD->EKD_STATUS := '3' // Obsoleto
      EKD->(MsUnlock())

      // caso houve somente alteração do fabricante/pais, atualizar a proxima sequencia com "Integrado (pendente: fabricante/país)"
      // manter a versão devido não ter uma retificação somente o relacionamento do fabricante/pais
      if getAltFab()
         oModelEKD:LoadValue("EKD_STATUS","5") // 5=Integrado (pendente: fabricante/país)
         // if lVerAtual
         //    oModelEKD:LoadValue("EKD_VATUAL",cVerAtual)
         // endif
      endif

      // Caso não houve alteração de fabricantes, mas alteração da relação de produtos de referencia, mantem a versão atual e seu status
      //if !getAltFab() .and. lVerAtual
      if lVerAtual
         oModelEKD:LoadValue("EKD_VATUAL",cVerAtual)
      endif

      // Caso não houve alteração de fabricantes e também não houve alteração da relação de produtos de referencia, significa que podemos voltar para status de integrado
      if !getAltFab() .and. lTemEK9 .and. !empty(EK9->EK9_IDPORT)
         oModelEKD:LoadValue("EKD_STATUS","1")
         lAtualEK9 := .T.
      endif

   endif

   EK9->(dbSetOrder(1))
   If IsMemVar("lCP401Auto") .And. !lCP401Auto .And. lTemEK9
      EK9->(RecLock("EK9",.F.))
      EK9->EK9_STATUS := "3" //Pendente Retificação
      EK9->EK9_VSMANU := " "
      EK9->EK9_VATUAL := " "
      EK9->(MsUnlock())
   elseif lAtualEK9
      EK9->(RecLock("EK9",.F.))
      EK9->EK9_STATUS := "1" // Registrado
      EK9->EK9_VATUAL := cVerAtual
      EK9->(MsUnlock())
   EndIf

EndIf

RestArea(aAreaEK9)
RestArea(aAreaEKD)
Return

/*
CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
MFR - Maurício Frison
 */
Class CP401EV FROM FWModelEvent
     
    Method New()
    Method Activate()
    Method DeActivate()

End Class

Method New() Class CP401EV
Return

Method Activate(oModel,lCopy) Class CP401EV
  CP401AtuAtrib(oModel)
Return

Method DeActivate() Class CP401EV
   CP401Fecha()
Return

Function CP401AtuATrib(oModel)
Local oModelEKI	:= oModel:GetModel("EKIDETAIL")
Local nI
Local nOperation := oModel:GetOperation()
Local aAreaEKG := EKG->(getArea())

If nOperation == 5 //Exclusão
    oModel:nOperation := 3
EndIf
If oModelEKI:Length() > 0
   EKG->(dbSetORder(1)) //EKG_FILIAL, EKG_NCM, EKG_COD_I, EKG_CONDTE
   oModelEKI:GoLine(1)
   For nI := 1 to oModelEKi:Length()
      oModelEKI:GoLine( nI )
      If EKG->(dbSeek(xFilial("EKG") + EKD->EKD_NCM + oModelEKI:getValue("EKI_CODATR") + If( Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS"), oModelEKI:getValue("EKI_CONDTE"),""))) 
         If Alltrim(EKG->EKG_FORMA) == ATT_LISTA_ESTATICA
            oModelEKI:LoadValue("EKI_VLEXIB",substr(getAtrName(oModelEKI:getValue("EKI_VALOR"), EKD->EKD_NCM, oModelEKI:getValue("EKI_CODATR")),1,100))
         ElseIf Alltrim(EKG->EKG_FORMA) == ATT_BOOLEANO
            oModelEKI:LoadValue("EKI_VLEXIB",if(oModelEKI:getValue("EKI_VALOR")=="1","SIM",if(oModelEKI:getValue("EKI_VALOR")=="2","NAO","")))
         Else
            oModelEKI:LoadValue("EKI_VLEXIB",substr(oModelEKI:getValue("EKI_VALOR"),1,100))
         EndIf
      Else
         oModelEKI:LoadValue("EKI_VLEXIB",substr(oModelEKI:getValue("EKI_VALOR"),1,100))
      EndIf
   Next
   oModelEKI:GoLine(1)
   RestArea(aAreaEKG)
EndIf
oModel:nOperation := nOperation
return .t.


/*/{Protheus.doc} CpoModel
   inclusão de campo no modelo 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param  oStruct, Objeto, Objeto da classe FWFormStruct
   @return 
/*/
static function CpoModel( oStruct )
   if Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
      oStruct:AddField( "Ordem"                        , ; // [01]  C   Titulo do campo
                        "Ordem"                        , ; // [02]  C   ToolTip do campo
                        "ATRIB_ORDEM"                  , ; // [03]  C   identificador (ID) do Field
                        "C"                            , ; // [04]  C   Tipo do campo
                        7                              , ; // [05]  N   Tamanho do campo
                        0                              , ; // [06]  N   Decimal do campo
                        {|| .T. }                      , ; // [07]  B   Code-block de validação do campo
                        {|| .F. }                      , ; // [08]  B   Code-block de validação When do campo
                        {}                             , ; // [09]  A   Lista de valores permitido do campo
                        .F.                            , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
                        nil                            , ; // [11]  B   Code-block de inicializacao do campo
                        .F.                            , ; // [12]  L   Indica se trata de um campo chave
                        .T.                            , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.                            )   // [14]  L   Indica se o campo é virtual
   endif

return

/*/{Protheus.doc} OrdAtrib
   Ordenar os atributos 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKI
   @return 
/*/
static function OrdAtrib(oModelEKI)
   local nPosOrdem  := 0
   local oStrGrd    := oModelEKI:getStruct()

   nPosOrdem  := oStrGrd:GetFieldPos("ATRIB_ORDEM")
   if nPosOrdem > 0
      aSort(oModelEKI:aDATAMODEL,,, {|x,y| x[1][1][nPosOrdem] < y[1][1][nPosOrdem] } )
   endif

return 

/*/{Protheus.doc} getAtrName
   Retornar o codigo da lista de atributos com descrição
   O campo cChave não deve conter os valores do dominio, pois estes vão estar no cValor

   @type  Static Function
   @author bruno akyo kubagawa

   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKI
   @return 
/*/
Static Function getAtrName(cValor, cNcm, cAtributo)
Local cRetorno := ""
Local aAreaEKH := EKH->(GetArea())
Local aValores
Local nI

EKH->(dbSetOrder(1))//EKH_FILIAL, EKH_NCM, EKH_COD_I, EKH_CODDOM
aValores := strTokArr( alltrim(cValor), ";" )
For nI := 1 To Len(aValores)
   If EKH->(dbSeek( xFilial("EKH") + padR("", len(EKH->EKH_NCM)) + cAtributo + aValores[nI])) .or. EKH->(dbSeek( xFilial("EKH") + cNcm + cAtributo + aValores[nI]))
      cRetorno += Alltrim(EKH->EKH_CODDOM) + " - " + Alltrim(EKH->EKH_DESCRE) + " ;"
   endif
next 
cRetorno := Substr( cRetorno, 1, Len(cRetorno)-1)
RestArea(aAreaEKH)
   
Return cRetorno

/*
Função     : CP401Valid()
Objetivo   : Validar dados digitados nos campos EKF
Parâmetros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Revisão    :
*/
function CP401Valid(cCampo)
   local lRet       := .T.
   local oModel     := nil
   local oModelEKF  := nil

   oModel    := FWModelActive()

   if oModel <> nil
      oModelEKF := oModel:GetModel("EKFDETAIL")
   endif

   do case
      case cCampo == "EKF_PAIS"
         if oModelEKF <> nil
            lRet := Vazio() .or. ExistCpo("ELO",oModelEKF:getvalue("EKF_PAIS"))
            if !lRet
               EasyHelp(STR0029, STR0014) // "Código do país conforme ISO-3166 invalido." ### "Atenção"
            endif
         endif
   endcase	
 

return lRet

/*/{Protheus.doc} EKFDesvinc
   Retorna os fabricantes/pais de origem que serão desvinculado do catalogo de produto da ultima sequencia

   @type  Static Function
   @author user
   @since 15/08/2023
   @version version
   @param oModelEKF, objeto, objeto de modelo de dados EKF
          cCatalogo, caractere, ID
          cSequencia, caracter, sequencia
   @return return_var, return_type, return_description
/*/
static function EKFDesvinc(oModelEKF, cCatalogo, cSequencia)
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local aSeek      := {}
   local cInformix := if(TcGetDB()=="INFORMIX", " AS ","")
   local cEKF := RetSqlName('EKF') + cInformix

   default cCatalogo  := ""
   default cSequencia := ""

   //EKF_VINCFB -> 1=Vincular ao catálogo;2=Desvincular do catálogo;3=Sem alteração;4=Vinculado ao catálogo;5=Desvinculado do catálogo
   cQuery := " SELECT "
   cQuery += "  EKF_CODFAB, EKF_LOJA, EKF_PAIS, EKF_FILORI, EKF_OPERFB, EKF_VINCFB "
   cQuery += " FROM " + cEKF + " EKF "
   cQuery += " WHERE EKF.D_E_L_E_T_ = ? "
   cQuery += " AND EKF.EKF_FILIAL = ? "
   cQuery += " AND EKF.EKF_COD_I = ? "
   cQuery += " AND EKF.EKF_VERSAO = ? "
   cQuery += " AND ( EKF.EKF_VINCFB = ? OR EKF.EKF_VINCFB = ? ) "
   
   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1,' ')
   oQuery:SetString(2,xFilial('EKF'))
   oQuery:SetString(3,cCatalogo)
   oQuery:SetString(4,cSequencia)
   oQuery:SetString(5,'2')
   oQuery:SetString(6,'4')
   cQuery := oQuery:GetFixQuery()

   cAliasQry := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      aSeek := {}
      aAdd( aSeek , { "EKF_CODFAB", (cAliasQry)->EKF_CODFAB})
      aAdd( aSeek , { "EKF_LOJA", (cAliasQry)->EKF_LOJA})
      aAdd( aSeek , { "EKF_PAIS", (cAliasQry)->EKF_PAIS})
      aAdd( aSeek , { "EKF_FILORI", (cAliasQry)->EKF_FILORI})
      if !oModelEKF:SeekLine(aSeek, .F., .F. )
         oModelEKF:AddLine()
         oModelEKF:LoadValue("EKF_CODFAB", (cAliasQry)->EKF_CODFAB)
         oModelEKF:LoadValue("EKF_LOJA", (cAliasQry)->EKF_LOJA)
         oModelEKF:LoadValue("EKF_FILORI", (cAliasQry)->EKF_FILORI)
         oModelEKF:LoadValue("EKF_PAIS", (cAliasQry)->EKF_PAIS)
         oModelEKF:LoadValue("EKF_OPERFB", (cAliasQry)->EKF_OPERFB)
         oModelEKF:LoadValue("EKF_VINCFB", "2") // 2=Desvincular do catálogo
         setAltFab(.T.)
      endif
      (cAliasQry)->(dbSkip())
   end      
   (cAliasQry)->(dbCloseArea())
   oQuery:Destroy()

   FwFreeObj(oQuery)

return

/*/{Protheus.doc} CP401Log
   Geração de log em pdf ou envio por email do histórico do catálogo de produto

   @type  Function
   @author user
   @since 16/08/2023
   @version version
   @param nenhum
   @return nulo
/*/
function CP401Log()
return EasyLogPrt("3")

/*
Função     : QryAttEKC
Objetivo   : Query para filtrar os atributos da EKC e montar os campos a ser enviados para o Angular.
Retorno    : cQuery - Retorna uma string com a query montada
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function QryAttEKC(cCatalogo)
Local cQuery := ""

cQuery += " SELECT	EKG.EKG_NCM,   EKG.EKG_COD_I, EKG_NOME,   EKG_CODOBJ,   EKG.EKG_FORMA,   EKG.EKG_MODALI,   EKG.EKG_OBRIGA,   EKG_MSBLQL, "
cQuery += "		EKG.EKG_INIVIG,   EKG.EKG_FIMVIG,   EKG.EKG_TAMAXI, EKG_DECATR,   EKG.EKG_CONDTE,   EKG.EKG_MULTVA,   EKG.R_E_C_N_O_ EKG_RECNO, "
cQuery += "		COALESCE(EKC.R_E_C_N_O_, 0) EKC_RECNO "
cQuery += " FROM  "
cQuery += "   " + RetSQLName("EKG") + " EKG  "
cQuery += "   LEFT JOIN " + RetSQLName("EKC") + " EKC ON ( "
cQuery += "     EKC.EKC_FILIAL      = ?  "
cQuery += "     AND EKC.EKC_COD_I   = ?  "
cQuery += "     AND EKC.EKC_CODATR  = EKG.EKG_COD_I  "
cQuery += "     AND EKC.EKC_CONDTE  = EKG.EKG_CONDTE "
cQuery += "     AND EKC.D_E_L_E_T_  = ' '  "
cQuery += "   )  "
cQuery += " WHERE  "
cQuery += "   EKG.EKG_FILIAL     = ?   "
cQuery += "   AND EKG.EKG_NCM    = ?   "
cQuery += "   AND EKG.EKG_MSBLQL<> '1' "
cQuery += "   AND (EKG_FIMVIG = ' ' OR EKG_FIMVIG    >= ? )  "
cQuery += "   AND ( EKG.EKG_MODALI = ' ' OR EKG.EKG_MODALI = '3' OR EKG.EKG_MODALI = ? ) " 
cQuery += "   AND EKG.EKG_CODOBJ like ? "
cQuery += "   AND EKG.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY  "
cQuery += "   EKG.EKG_CONDTE, "
cQuery += "   EKG.EKG_COD_I "

Return cQuery

Static Function QryAttEKH()
Local cQuery := ""

cQuery := " SELECT EKH.R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName("EKH") + " EKH "
cQuery += " WHERE EKH.EKH_FILIAL = ?  "
cQuery += "     AND (EKH.EKH_NCM = ?  "
cQuery += " 	  OR EKH.EKH_NCM  = ' ') "
cQuery += "     AND EKH.EKH_COD_I = ? "
cQuery += " 	AND EKH.EKH_MSBLQL <> '1' "
cQuery += "     AND EKH.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY "
cQuery += "   EKH.EKH_COD_I, "
cQuery += "   EKH.EKH_CODDOM "

Return cQuery

/*
Função     : loadAtPOUI
Objetivo   : Montar o objeto de campos a ser enviado para o Angular montar o cadastro dos Atributos
Retorno    : -
Parâmetros : -
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function LoadAtPOUI(cCatalogo, cNcmEKD, cModEKD,nOpc)
Local cQuery := QryAttEKC()
Local oDePara:= TETypePOUI() //De para com os tipos de campos
Local oQuery
Local cAliasAtt
Local cAliasDom
Local oCampo
Local oComposto := jsonObject():New()
Local oCondicao := jsonObject():New()
Local oDominio
Local oAttCP
Local lComposto
Local lTemCondicao
Local nOrder := 0
Local oCondFilho
Local lSeekEKC
Local cValueEKC
Local aNames
Local nY
Local nI
Local nPos
Local cPOUIJson
Local cDivider := ""
Local aArea := GetArea()

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1, xFilial('EKC'))
oQuery:SetString(2, cCatalogo)
oQuery:SetString(3, xFilial('EKG'))
oQuery:SetString(4, cNcmEKD)
oQuery:SetString(5, dToS(dDataBase))
oQuery:SetString(6, cModEKD)
oQuery:SetString(7, '%7%')

cQuery := oQuery:GetFixQuery()

cAliasAtt := getNextAlias()
MPSysOpenQuery(cQuery, cAliasAtt)
TcSetField(cAliasAtt, "EKG_INIVIG", "D", 8, 0)
TcSetField(cAliasAtt, "EKG_FIMVIG", "D", 8, 0)

oJsonAtt['listaAtributos'] := {}
oJsonAtt['listaCompostos'] := {}
oComposto['listaComposto'] := jSonObject():New()
oCondicao['listaCondicao'] := jSonObject():New()
EKH->(dbSetOrder(1))
EKC->(dbSetOrder(1))
While (cAliasAtt)->(!Eof())
   //If !("5" $ alltrim((cAliasAtt)->EKG_CODOBJ))
      oCampo := jsonObject():New()
      lComposto := .F.
      lTemCondicao := .F.
      nOrder++

      //Trata os dominios do atributo quando tiver
      If Alltrim((cAliasAtt)->(EKG_FORMA)) == "LISTA_ESTATICA" //Tem Dominio
         cQuery := QryAttEKH()
         oQuery := FWPreparedStatement():New(cQuery)
         oQuery:SetString(1, xFilial('EKH'))
         oQuery:SetString(2, cNcmEKD)
         oQuery:SetString(3, (cAliasAtt)->(EKG_COD_I))
         cQuery := oQuery:GetFixQuery()

         cAliasDom := getNextAlias()
         MPSysOpenQuery(cQuery, cAliasDom)

         oDominio  := jsonObject():New()
         oDominio['listaDominio'] := {}
         While (cAliasDom)->(!Eof())
            EKH->(dbGoTo((cAliasDom)->(RECNO)))
            aAdd(oDominio['listaDominio'], JsonObject():new())
            nPos := Len(oDominio['listaDominio'])
            oDominio['listaDominio'][nPos]['label' ] := Alltrim(EKH->EKH_DESCRE)
            oDominio['listaDominio'][nPos]['value' ] := Alltrim(EKH->EKH_CODDOM)

            (cAliasDom)->(dbSkip())
         End
         (cAliasDom)->(dbCloseArea())
         FreeObj(oQuery)
      EndIf

      If Alltrim((cAliasAtt)->(EKG_FORMA)) == "COMPOSTO"
         oAttCP := jsonObject():New()
         oAttCP['label'] := Alltrim((cAliasAtt)->(EKG_NOME))
         oAttCP['listaAtributosCompostos'] := {}

         oComposto['listaComposto'][Alltrim((cAliasAtt)->(EKG_COD_I))] := oAttCP

         FreeObj(oAttCP)
         lComposto := .T.
      EndIf

      If !Empty((cAliasAtt)->(EKG_CONDTE))
         EKG->(dbgoto((cAliasAtt)->(EKG_RECNO)))
         If !Empty(EKG->EKG_CONDIC)
            lTemCondicao := .T.
            oCondFilho := JsonObject():new()
            If !oCondicao['listaCondicao']:hasProperty(Alltrim(EKG->EKG_CONDTE))
               oCondicao['listaCondicao'][Alltrim(EKG->EKG_CONDTE)] := {}
            EndIf
            oCondFilho:FromJson(Alltrim(EKG->EKG_CONDIC))
            oCondFilho['campo'] := Alltrim(EKG->EKG_COD_I)
            aAdd(oCondicao['listaCondicao'][Alltrim(EKG->EKG_CONDTE)], oCondFilho)
            FreeObj(oCondFilho)
         EndIf
      EndIf
      
      If !lComposto
         //Chama função que vai monstar o objeto dos Campos
         cargaCpoPO(@oCampo, cAliasAtt, nOrder == 1, oDePara, nOrder, cDivider, oDominio, nOpc)

         // Valida se tem condição para deixar invisivel ao inicializar
         If lTemCondicao
            oCampo['visible'] := .F.
         EndIf

         //Valida atributos bloqueados quando for alteração
         lSeekEKC := .F.
         If !Empty(cValueEKC := getValorEKC(cCatalogo, (cAliasAtt)->(EKG_COD_I), @lSeekEKC))
            If Alltrim((cAliasAtt)->(EKG_MULTVA)) == "1"
               oCampo['value'] := strTokArr(getFormVal(Alltrim((cAliasAtt)->(EKG_FORMA)), cValueEKC, 'advpl'), ";")
            Else
               oCampo['value'] := getFormVal(Alltrim((cAliasAtt)->(EKG_FORMA)), cValueEKC, 'advpl')
            EndIf
         EndIf
         If lTemCondicao .And. lSeekEKC
            oCampo['visible'] := .T.
         EndIf
         If (oCampo['status'] != "EXPIRADO" .And. !oCampo['bloqueado']) .Or. (!Empty(oCampo['value']) .And. (oCampo['status'] == "EXPIRADO" .Or. (cAliasAtt)->(EKG_MSBLQL) == "1"))
            If inComposto(oComposto, Alltrim((cAliasAtt)->(EKG_CONDTE))) //Verifica se o Atributo pertence a um atributo Composto
               //Se é um filho de composto, armazera para montar depois
               oAttCP := oComposto['listaComposto']:GetJsonObject(Alltrim((cAliasAtt)->(EKG_CONDTE)))
               If ValType(oAttCP) <> "U"
                  aAdd(oAttCP['listaAtributosCompostos'], oCampo)
               EndIf         
            Else
               aAdd(oJsonAtt['listaAtributos'], oCampo)
            EndIf
         EndIf
      EndIf

      FreeObj(oDominio)
      FreeObj(oCampo)
   //EndIf

   (cAliasAtt)->(dbSkip())
End

//Trata os Atributos Compostos, para que fiquem por último
If Len(aNames := oComposto['listaComposto']:GetNames()) > 0
   For nI := 1 To Len(aNames)
      For nY := 1 To Len(oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'])
         If nY == 1 //Adicione o Divider
            oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY]['divider'] := oComposto['listaComposto'][aNames[nI]]['label']
         EndIf
         aAdd(oJsonAtt['listaCompostos'], oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY])
      Next
   Next
EndIf

If Len(aNames := oCondicao['listaCondicao']:GetNames()) > 0
   For nI := 1 To Len(aNames)
      If (nPos := aScan(oJsonAtt['listaAtributos'], {|X| X['property'] == aNames[nI]})) > 0
         oJsonAtt['listaAtributos'][nPos]['condicaoPreenchimento'] := .T.
      EndIf
   Next
EndIf

(cAliasAtt)->(dbCloseArea())

oJsonAtt['ncmInfoDesc'] := getNcmDesc(cNcmEKD)
oJsonAtt['ncmInfoCod']  := Transform(cNcmEKD, AvSX3("YD_TEC", AV_PICTURE))
oJsonAtt['listaCondicao'] := oCondicao['listaCondicao']

cPOUIJson := StrTran(oJsonAtt:toJson(), '".T."', 'true')
cPOUIJson := StrTran(cPOUIJson, '".F."', 'false')

oChannel:AdvPLToJS("listaAtributos", cPOUIJson)
restArea(aArea)
Return

/*
Função     : cargaCpoPO
Objetivo   : Montar objeto do campo a ser enviado para o Angular
Retorno    : -
Autor      : Tiago Tudisco
Data/Hora  : 06/03/2024
*/
Static Function cargaCpoPO(oCampo, cAliasAtt, lDivider, oDePara, nOrder, cDivider, oDominio, nOpc)
Local cTypeForm

oCampo['property'] := Alltrim((cAliasAtt)->(EKG_COD_I))
oCampo['label'   ] := Alltrim((cAliasAtt)->(EKG_NOME))
oCampo['visible'] := .T.

cTypeForm := Alltrim((cAliasAtt)->(EKG_FORMA))
If lDivider
   oCampo['divider'] := cDivider
EndIf

oCampo['type'] :=  TEgetTpPOUI(oDePara, cTypeForm)

If cTypeForm == 'LISTA_ESTATICA' .And. ValType(oDominio) != "U"
   oCampo['options'] := oDominio['listaDominio']
   oCampo['optionsMulti'] := (cAliasAtt)->(EKG_MULTVA) == "1"

ElseIf cTypeForm == "BOOLEANO"
   oCampo['booleanFalse'] := "Não"
   oCampo['booleanTrue']  := "Sim"
ElseIf cTypeForm == "TEXTO" .And. (cAliasAtt)->(EKG_MULTVA) == "1"
   oCampo['rows'] := 5
EndIf

oCampo['order']         :=  nOrder
oCampo['required']      :=  (cAliasAtt)->(EKG_OBRIGA) == "1"
oCampo['showRequired']  :=  oCampo['required']
oCampo['optional']      :=  (cAliasAtt)->(EKG_OBRIGA) != "1"
oCampo['maxLength']     :=  (cAliasAtt)->(EKG_TAMAXI)
If cTypeForm == 'VALOR_MONETARIO'
   oCampo['decimalsLength'] := (cAliasAtt)->(EKG_DECATR)
EndIf
oCampo['mask']          :=  ""
oCampo['gridColumns']   :=  6
oCampo['gridSmColumns'] :=  12
oCampo['condicaoPreenchimento'] := .F.

// Tratamentos condicionais que serão ajustados no próximo release - WorkItem 1073965
If cTypeForm == "IMPORTACAO_TERCEIROS"
   oCampo['options'] := {}
   Aadd(oCampo['options'], JsonObject():new())
   oCampo['options'][1]['label' ] := " 0 - Importação Direta"
   oCampo['options'][1]['value' ] := "0"
ElseIf cTypeForm == "FABRICANTE" .Or. cTypeForm == "OPERADOR_ESTRANGEIRO"
   oCampo['visible'] := .F.
EndIf

If cTypeForm == "DATA"
   oCampo["format"]     := "dd/mm/yyyy"
EndIf

oCampo['condicionante'] := (cAliasAtt)->(EKG_CONDTE)
oCampo['status']        := CP400Status((cAliasAtt)->(EKG_INIVIG), (cAliasAtt)->(EKG_FIMVIG))
oCampo['bloqueado']     := IIF((cAliasAtt)->(EKG_MSBLQL) == '1' .Or. oCampo['status'] == "EXPIRADO", .T., .F.)
oCampo['disabled']      := .F.
If oCampo['status'] == "FUTURO"
   oCampo['help'] := STR0038 + DToC((cAliasAtt)->(EKG_INIVIG)) + "." //"Este atributo tem vigência futura a partir de "
EndIf

oCampo["disabled"] := .T.

Return

Static Function inComposto(oComposto, cAtributo)
Return !Empty(oComposto['listaComposto']:HasProperty(cAtributo))

// Função pare retornar a descrição da NCM
Static Function getNcmDesc(cNCM, lAddCodigo)
Local cDescNCM := ""

Default lAddCodigo := .F.

// Define a ordem de busca na tabela SYD
SYD->(DbSetOrder(1)) //YD_FILIAL, YD_TEC, YD_EX_NCM, YD_EX_NBM, YD_DESTAQU
If SYD->(dbSeek(xFilial("SYD") + AvKey(cNCM,"EKM_NCM")))
   cDescNCM := IIF(lAddCodigo, Transform(cNCM, AvSX3("YD_TEC", AV_PICTURE)) + " - " + SYD->YD_DESC_P ,SYD->YD_DESC_P)
EndIf

cDescNCM := IIF(Empty(cDescNCM), cNCM, cDescNCM)

Return cDescNCM

Static Function getFormVal(cForma, cValor, cCode)
Local cRet := cValor

Default cCode := "POUI"

if !empty(cForma)
   cForma := Alltrim(cForma)
   cValor := Alltrim(strtran(cValor, chr(13)+chr(10), " "))
   Do Case
      Case cForma == ATT_BOOLEANO
         If cValor == '1'
            cRet := IIF(cCode == "POUI", "true", ".T.")
         Else
            cRet := IIF(cCode == "POUI", "false", ".F.")
         EndIf
      Otherwise
         cRet := cValor
   EndCase
endif

Return cRet

/*
Função     : getValorEKC
Objetivo   : Função stática para retornar o valor dos atributos gravados na tabela EKC
Parâmetros : cCatalogo - Codigo do Catálogo de Produtos
             cAtributo - Codigo do Atributo
             lSeek - Flag para indicar se o registro foi encontrado. Deve ser passado por referência
Autor      : Nicolas
Data/Hora  : 04/03/2024
*/
Static Function getValorEKC(cCatalogo, cAtributo, lSeek)
Local cChave
Local cRet := ""
   // Procura o atributo no banco para buscar seu valor
   DbSelectArea("EKC") // Retirar e colocar antes da chamada da função
   EKC->(dbSetOrder(1)) // Retirar e colocar antes da chamada da função

   cChave := xFilial("EKC") + cCatalogo + cAtributo

   // Preenche o valor do atributo no campo
   lSeek := .F.
   If EKC->(dbSeek(cChave))
      cRet := Alltrim(EKC->EKC_VALOR)
      lSeek := .T.
   EndIf

Return cRet

/*
Função     : CPCallApp
Objetivo   : Montar o objeto de campos a ser enviado para o Angular montar o cadastro dos Atributos
Retorno    : -
Parâmetros : oPanel  - Painel para a abertura da tela PO-UI
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function CPCallApp( oPanel )
	FWCallApp( "product-catalog", oPanel, , @oChannel, , "EICCP401")
Return .T.

/*
Função     : JsToAdvpl
Objetivo   : Função stática para comunicação entre o PO-UI e o Protheus
Parâmetros : oWebChannel - Objeto do WebChannel para enviar dados para o angular
             cType       - Identificação da chamada recebida do angular
             cContent    - Conteúdo recebido do angular
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function JsToAdvpl(oWebChannel,cType,cContent)
Local oPreLoad
Local oModel
Local oModelEKD

Do Case
   Case cType == 'preLoad'
      oPreLoad := JsonObject():New()

      oPreLoad['msgLoading']     := STR0039 //"Aguardando Catálogo de Produtos..."
      oPreLoad['isHideLoading']  := "false"
      oPreLoad['inclusao']       := IIF(Inclui, "true", "false")
      oPreLoad['noLabelNCM']     := STR0040 //"O Catálogo de Produtos informado não possui Atributos."
      oPreLoad['noValueNCM']     := STR0041 //"Acesse o cadastro 'Catálogo de Produtos' e preencha os dados dos Atributos."
      oWebChannel:AdvPLToJS('overLoad', oPreLoad:toJson())
      FreeObj(oPreLoad)
   
   Case cType == 'carregaAtributos'
      oModel      := FWModelActive()
      oModelEKD   := oModel:GetModel("EKDMASTER")
      // Chama a função para carregar os atributos
      LoadAtPOUI(oModelEKD:GetValue("EKD_COD_I"), oModelEKD:GetValue("EKD_NCM"), oModelEKD:GetValue("EKD_MODALI"), oModel:GetOperation()) //Carrega os atributos para apresentação do App PO-UI

   Case cType == 'retLoadAtributos'
      lPOUIOKLD := .T.

EndCase

Return .T.

/*
Função     : canUseApp
Objetivo   : Função para verificar se utilziada o cadastro de atributos antigo ou o novo em PO-UI
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function canUseApp()
Local lRet
If lCanUseApp == nil
   lRet := !IsBlind() .And. TEOpenApp(.F., .T.) .And. Len(GetApoInfo("product-catalog.app")) > 0
   lCanUseApp := lRet
Else
   lRet := lCanUseApp
EndIf

Return lRet

/*/{Protheus.doc} setAltFab
   Atualiza o conteudo da static _lAltFabr

   @type  Static Function
   @author user
   @since 28/08/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function setAltFab(lAltFabr)
   default lAltFabr := .F.
   _lAltFabr := _lAltFabr .or. lAltFabr
return 

/*/{Protheus.doc} getAltFab
   Retorna o conteudo da static _lAltFabr

   @type  Static Function
   @author user
   @since 28/08/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getAltFab()
return _lAltFabr

/*/{Protheus.doc} CP401AltInf
   Atualiza o conteudo da static _lAltInf

   @type  Function
   @author user
   @since 28/08/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
function CP401AltInf(lAltInf)
   default lAltInf := .F.
   _lAltInf := _lAltInf .or. lAltInf
return 

/*/{Protheus.doc} getAltInf
   Retorna o conteudo da static _lAltInf

   @type  Static Function
   @author user
   @since 28/08/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getAltInf()
return _lAltInf
