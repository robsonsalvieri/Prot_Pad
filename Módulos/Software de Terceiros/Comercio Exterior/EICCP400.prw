#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#include 'eiccp400.ch'
#Include "TOPCONN.CH"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"
#Define ATT_NUMERO_REAL    "NUMERO_REAL"
#Define ATT_VALOR_MONETARIO "VALOR_MONETARIO"
#define ALIAS_TEMP          1
#define ARQ_TAB             2
#define INDEX1              3
#define INDEX2              4

#define REGISTRADO                   "1"
#define PENDENTE_REGISTRO            "2"
#define PENDENTE_RETIFICACAO         "3"
#define BLOQUEADO                    "4"
#define REGISTRADO_MANUALMENTE       "5"
#define REGISTRADO_PENDENTE_FAB_PAIS "6"

static _aAtributos:= {}
static _aTabsTmp  := {}
static CP400_PROD := "CP400_SB1"
static lAppCP400

/*
Programa   : EICCP400   
Objetivo   : Rotina - Catalogo de Produtos
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Dez /2019
Obs.       :
*/
function EICCP400()
   Local aArea       := GetArea()
   Local aCores      := {}
   Local nX          := 1
   Local cModoAcEK9  := FWModeAccess("EK9",3)
   Local cModoAcEKA  := FWModeAccess("EKA",3)
   Local cModoAcEKB  := FWModeAccess("EKB",3)
   Local cModoAcEKD  := FWModeAccess("EKD",3)
   Local cModoAcEKE  := FWModeAccess("EKE",3)
   Local cModoAcEKF  := FWModeAccess("EKF",3)
   Local oBrowse
   local lLibAccess  := .F.
   local lExecFunc   := .F. // existFunc("FwBlkUserFunction")
   local aCoresNum   := {REGISTRADO,REGISTRADO_MANUALMENTE,REGISTRADO_PENDENTE_FAB_PAIS,PENDENTE_REGISTRO,PENDENTE_RETIFICACAO,BLOQUEADO}
                         
   Private aRotina      := {}
   Private cValor       := ""
   Private cNcmEK9      := ""
   Private cModalEK9    := ""
   Private cPrdRefEK9   := ""
   Private cFilRefEK9   := ""
   Private lRetAux      :=.T.
   Private lMultiFil    := nil // mantido devido ao dicionário de dados, está no X3_WHEN do campo EKA_FILORI
   Private oJsonAtt     := jsonObject():New()
   Private oChannel
   Private lCanWrite := .T.
   Private oCpObrig  := jSonObject():New()
   Private oCondicao := jsonObject():New()
   Private lCpPOUIOK := .F.
   Private lPOUIOKCM := .F.
   Private lPOUIOKLD := .F.
   Private lAltPOUI  := .F.
   private cFilSB1F3 := ""
   private cFilSA2F3 := ""

   if lExecFunc
      FwBlkUserFunction(.T.)
   endif

   lLibAccess := AmIin(17)

   if lExecFunc
      FwBlkUserFunction(.F.)
   endif

   if lLibAccess

      lMultiFil := isMultFil()

      If !(cModoAcEK9 == cModoAcEKD .And. cModoAcEK9==cModoAcEKA .and. cModoAcEK9 == cModoAcEKE .And. cModoAcEK9==cModoAcEKB .And. cModoAcEK9 == cModoAcEKF)
         EasyHelp(STR0025,STR0002) // "Modo de compatilhamento esta diferente entre as tabelas. Verifique o modo das tabelas EK9, EKA, EKB,EKD, EKE e EKF "#Atenção
      Else

         aCores := CP400Cores(aCoresNum)

         AtuStatus()
         oBrowse := FWMBrowse():New() //Instanciando a Classe
         oBrowse:SetAlias("EK9") //Informando o Alias 
         oBrowse:SetMenuDef("EICCP400") //Nome do fonte do MenuDef
         oBrowse:SetDescription(STR0001) // "Catalogo de Produtos" //Descrição a ser apresentada no Browse   
      
         //Adiciona a legenda
         For nX := 1 To Len( aCores )   	    
            oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
         Next nX
         
         //Habilita a exibição de visões e gráficos
         oBrowse:SetAttach( .T. )
         //Configura as visões padrão
         oBrowse:SetViewsDefault(GetVisions())

         oBrowse:AddFilter(STR0117,"@EK9_MODALI = '1'", .F., .T.) // "Modalidade de Catálogo de Produtos"

         //Força a exibição do botão fechar o browse para fechar a tela
         oBrowse:ForceQuitButton()
         
         //Ativa o Browse
         oBrowse:Activate()
         
         FreeObj(oChannel)
      EndIf
   endif

   FreeObj(oJsonAtt)
   FreeObj(oCpObrig)
   FreeObj(oCondicao)
   RestArea(aArea)

Return Nil

/*
Programa   : Menudef
Objetivo   : Estrutura do MenuDef - Funcionalidades: Pesquisar, Visualizar, Incluir, Alterar e Excluir
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function MenuDef()
   Local aRotina := {}

   aAdd( aRotina, { STR0008 , "AxPesqui"         , 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0009 , 'VIEWDEF.EICCP400' , 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0010 , 'VIEWDEF.EICCP400' , 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0011 , 'VIEWDEF.EICCP400' , 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0012 , 'VIEWDEF.EICCP400' , 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0013 , 'CP400Legen'       , 0, 6, 0, NIL } )	//'Legenda'
   aAdd( aRotina, { STR0050 , 'CP400CadOE()'     , 0, 6, 0, NIL } )	//'"Cadastra Operador Estrangeiro" '
   aAdd( aRotina, { STR0045 , 'CP400IntCat()'    , 0, 6, 0, NIL } )	//'Integrar'
   aAdd( aRotina, { STR0140 , 'CP400GerCat()'    , 0, 3, 0, NIL } ) // "Geração em lote de catalogo de produtos"
   aAdd( aRotina, { STR0197 , 'CP400Log()'       , 0, 2, 0, NIL } ) // "Log de Integração"
   aAdd( aRotina, { STR0253 , 'CP403ExpXls'      , 0, 2, 0, NIL } ) // "Exportar para planilha"
   aAdd( aRotina, { STR0254 , 'CP403ImpXls'      , 0, 2, 0, NIL } ) // "Importar da planilha"
   aAdd( aRotina, { STR0255 , 'CP404ImpArq'      , 0, 2, 0, NIL } ) // "Importar Arquivo do Portal Único"
   

Return aRotina

/*
Programa   : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ModelDef()
   Local oStruEK9       := FWFormStruct( 1, "EK9", , /*lViewUsado*/ )
   Local oStruEKA       := FWFormStruct( 1, "EKA", , /*lViewUsado*/ )
   Local oStruEKB       := FWFormStruct( 1, "EKB", , /*lViewUsado*/ )
   Local oStruEKC       := FWFormStruct( 1, "EKC", , /*lViewUsado*/ )
   Local bCommit        := {|oModel| CP400COMMIT(oModel)}
   Local bPosValidacao  := {|oModel| CP400POSVL(oModel)}
   Local bCancel        := {|oModel| CP400CANC(oModel)}
   Local oMdlEvent      := CP400EV():New()
   Local bPreVldEKC     := {|oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue| EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)}
   Local bPreVldEKA     := {|oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue| EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)}   
   Local bPosVldEKA     := {|oGridEKA| EKALineValid(oGridEKA)}
   Local bLnPosEKB      := {|oGridEKB| EKBLnVlPos(oGridEKB)}
   Local oModel         // Modelo de dados que será construído	
   Local lMultifil      := isMultFil()

      // Criação do Modelo
      oModel := MPFormModel():New( "EICCP400", /*bPreValidacao*/, bPosValidacao, bCommit, bCancel )

      if(!lMultiFil, oStruEK9:RemoveField("EK9_FILORI"), oStruEK9:SetProperty('EK9_FILORI' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_FILORI")'    )))
      oStruEK9:RemoveField("EK9_NALADI")
      oStruEK9:RemoveField("EK9_GPCBRK")
      oStruEK9:RemoveField("EK9_GPCCOD")
      oStruEK9:RemoveField("EK9_UNSPSC")
      oStruEK9:SetProperty('EK9_MSBLQL'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_MSBLQL")'    )) //Monta When diferente do dicionário
      oStruEK9:SetProperty('EK9_COD_I'   , MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, 'CP400VALID("EK9_COD_I")'    ))
      oStruEK9:SetProperty("EK9_COD_I"   , MODEL_FIELD_INIT   , FwBuildFeature(STRUCT_FEATURE_INIPAD,'CP400Init("EK9_COD_I")'     ))
      oStruEK9:SetProperty('EK9_NCM'     , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_NCM")'       ))
      oStruEK9:SetProperty('EK9_UNIEST'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_UNIEST")'    ))
      oStruEK9:SetProperty('EK9_RETINT'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_RETINT")'    ))
      oStruEK9:SetProperty('EK9_IDPORT'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_IDPORT")'    ))
      oStruEK9:SetProperty('EK9_VATUAL'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_VATUAL")'    ))
      oStruEK9:SetProperty('EK9_STATUS'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_STATUS")'    ))
      oStruEK9:SetProperty("EK9_CNPJ"    , MODEL_FIELD_TAMANHO , AVSX3("EKJ_CNPJ_R", 3))
      oStruEK9:SetProperty("EK9_MODALI"  , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'CP400Init("EK9_MODALI")' ))
      oStruEK9:SetProperty('EK9_MODALI'  , MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, 'Pertence("12")'    ))   
      oStruEK9:SetProperty('EK9_IMPORT' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_IMPORT")'    ))      
      oStruEK9:SetProperty('EK9_CNPJ'   , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_CNPJ")'    ))
      oStruEK9:SetProperty('EK9_MODALI' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_MODALI")'    ))
      oStruEK9:SetProperty('EK9_PRDREF' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_PRDREF")'    ))
      oStruEK9:SetProperty('EK9_DESC_I' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_DESC_I")'    ))
      oStruEK9:SetProperty('EK9_DSCCOM' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_DSCCOM")'    ))
      oStruEK9:SetProperty('EK9_OBSINT' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_OBSINT")'    ))
      oStruEK9:SetProperty('EK9_IDMANU' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_IDMANU")'    ))
      oStruEK9:SetProperty('EK9_VSMANU' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EK9_VSMANU")'    )) 

      If canUseApp() .and. oStruEK9:HasField("EK9_PERATR")
         oStruEK9:SetProperty('EK9_PERATR', MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, 'CP400VALID("EK9_PERATR")'))
      EndIf
 
      if(!lMultiFil, oStruEKB:RemoveField("EKB_FILORI"), oStruEKB:SetProperty('EKB_FILORI' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EKB_FILORI")'    )))
      oStruEKB:RemoveField("EKB_FILIAL")
      oStruEKB:RemoveField("EKB_COD_I")
      oStruEKB:SetProperty('EKB_OESTAT', MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, 'PERTENCE("1|2|3|4|5")' ))
      oStruEKB:SetProperty('EKB_CODFAB' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EKB_CODFAB")'    ))
      oStruEKB:SetProperty('EKB_LOJA'   , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EKB_LOJA")'    ))

      if(!lMultiFil, oStruEKA:RemoveField("EKA_FILORI"), oStruEKA:SetProperty('EKA_FILORI' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EKA_FILORI")'    )))
      oStruEKA:RemoveField("EKA_FILIAL")
      oStruEKA:RemoveField("EKA_COD_I")
      oStruEKA:SetProperty('EKA_PRDREF' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN , 'CP400WHEN("EKA_PRDREF")'    ))
   
      oStruEKC:RemoveField("EKC_FILIAL")
      oStruEKC:RemoveField("EKC_COD_I")
      oStruEKC:RemoveField("EKC_VERSAO")

      // Adiciona ao modelo uma estrutura de formulário de edição por campo
      oModel:AddFields("EK9MASTER", /*cOwner*/ , oStruEK9, /*bPre*/, /*bPost*/, /*bLoad*/)
      oModel:SetPrimaryKey( { "EK9_FILIAL", "EK9_COD_I"} )	

      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Relação de Produtos
      oModel:AddGrid("EKADETAIL","EK9MASTER", oStruEKA, bPreVldEKA , bPosVldEKA, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKADETAIL"):SetOptional( .T. ) //Pode deixar o grid sem preencher nenhum Produto - OSSME-5771 - Critério 7
      oModel:SetRelation('EKADETAIL', {{ 'EKA_FILIAL' , 'xFilial("EKA")' },;
                                       { 'EKA_COD_I'  , 'EK9_COD_I'     }},;
                                       EKA->(IndexKey(1)) )

      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Fabricantes
      oModel:AddGrid("EKBDETAIL","EK9MASTER", oStruEKB, /*bLinePre*/ ,bLnPosEKB, /*bPreVal*/ , /* bPosValEKB */, /*BLoad*/ )   
      oModel:GetModel("EKBDETAIL"):SetOptional( .T. ) //apesar de ser opcional, será validado no PosValid e obrigado a informar ao menos um fabricante ou país
      oModel:SetRelation('EKBDETAIL', {{ 'EKB_FILIAL' , 'xFilial("EKB")' },;
                                       { 'EKB_COD_I'  , 'EK9_COD_I'     }},;
                                       EKB->(IndexKey(1)) )

      CpoModel(oStruEKC)
      // Adiciona ao modelo uma estrutura de formulário de edição por grid - Atributos
      oModel:AddGrid("EKCDETAIL","EK9MASTER", oStruEKC, bPreVldEKC ,/*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:GetModel("EKCDETAIL"):SetOptional( .T. ) 
      if !IsRest()
         oModel:GetModel("EKCDETAIL"):SetNoInsertLine(.T.) 
      endif
      oModel:GetModel("EKCDETAIL"):SetNoDeleteLine(.F.)
      oModel:GetModel("EKCDETAIL"):SetOnlyQuery(.T.)
      oModel:SetRelation('EKCDETAIL', {{ 'EKC_FILIAL'	, 'xFilial("EKC")' },;
                                       { 'EKC_COD_I'  , 'EK9_COD_I'     }},;
                                       "EKC_FILIAL+EKC_COD_I+EKC_CODATR" + if(Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS"),"+EKC_CONDTE",""))
                                    
      If lMultiFil
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF","EKA_FILORI"} )
      Else
         oModel:GetModel("EKADETAIL"):SetUniqueLine({"EKA_PRDREF"} )
      EndIf	
      
      If oStruEKB:hasField("EKB_PAIS")
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_PAIS","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA", "EKB_PAIS"} )
         EndIf	
      Else
         If lMultiFil
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA","EKB_FILORI"} )
         Else
            oModel:GetModel("EKBDETAIL"):SetUniqueLine({"EKB_CODFAB","EKB_LOJA"} )
         EndIf	
      EndIf   

      //Adiciona a descrição do Componente do Modelo de Dados
      oModel:GetModel("EK9MASTER"):SetDescription(STR0001) //"Catalogo de Produtos"
      oModel:SetDescription(STR0001) // "Catalogo de Produtos"
      oModel:GetModel("EKADETAIL"):SetDescription(STR0014) //'Relação do Catálogo de Produtos'
      oModel:GetModel("EKBDETAIL"):SetDescription(STR0024) //"Relação de Países de Origem e Fabricantes "
      oModel:GetModel("EKCDETAIL"):SetDescription(STR0040) //"Relação de Atributos"

      oModel:InstallEvent("CP400EV", , oMdlEvent)

Return oModel

/*
Programa   : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : 26/11/2019
Obs.       :
*/
Static Function ViewDef()
   Local oStruEK9 := FWFormStruct(2, "EK9")
   Local oStruEKA := FWFormStruct(2, "EKA")
   Local oStruEKB := FWFormStruct(2, "EKB")
   Local oStruEKC := FWFormStruct(2, "EKC")
   Local oModel   := FWLoadModel("EICCP400")
   Local oView
   Local aCampos  := {}
   local lMultifil := isMultFil()
   local lCatProdEx  := FwIsInCallStack("EECCP400")

   // Cria o objeto de View
   oView := FWFormView():New()

   // Define qual o Modelo de dados será utilizado na View
   oView:SetModel(oModel)
   
   If canUseApp()
      oView:AddOtherObject("VIEW_EKC", {|oPanel| CPCallApp(oPanel)})
   EndIf
   
   // Remoção dos campos não utilizados
   oStruEK9:RemoveField("EK9_NALADI")
   oStruEK9:RemoveField("EK9_GPCBRK")
   oStruEK9:RemoveField("EK9_GPCCOD")
   oStruEK9:RemoveField("EK9_UNSPSC")
   
   if lCatProdEx .and. oStruEK9:HasField("EK9_STATUS")
      oStruEK9:RemoveField("EK9_STATUS")
      oStruEK9:RemoveField("EK9_RETINT")
      oStruEK9:RemoveField("EK9_IMPORT")
   endif

   oStruEKA:RemoveField("EKA_COD_I")
   oStruEKB:RemoveField("EKB_COD_I")
   oStruEKC:RemoveField("EKC_COD_I")
   oStruEKC:RemoveField("EKC_VERSAO")
   oStruEKC:RemoveField("EKC_VALOR")
   if oStruEKC:hasField("EKC_CONDTE")
      oStruEKC:RemoveField("EKC_CONDTE")
   endif

   If !lMultiFil
      oStruEK9:RemoveField("EK9_FILORI")
      oStruEKA:RemoveField("EKA_FILORI")
      oStruEKB:RemoveField("EKB_FILORI")
   EndIf

   // Devido as atualizações do portal unico, foi retirado a obrigatoriedade do campo TIN e criado um novo campo Codigo
   // Assim será alterado o titulo do campo EKJ_TIN para Código e será o primeiro campo da tela, sendo não editável
   // Observação: no portal unico foi migrado a informação cadastrado no campo TIN para o campo Código
   oStruEKB:SetProperty('EKB_OPERFB' , MVC_VIEW_TITULO , STR0202) // "Código"
   oStruEKB:SetProperty('EKB_OPERFB' , MVC_VIEW_DESCR  , STR0203) // "Código Portal Único"

   // Cria o grupo de folders principal (100% da tela)
   oView:CreateHorizontalBox('TELA', 100)
   oView:CreateFolder("MAIN", "TELA") 

   // Cria os folders
   oView:addSheet("MAIN", "F_CATALOGO_PRODUTOS", STR0001) // Catalogo de Produtos
   oView:addSheet("MAIN", "F_ATRIBUTOS", STR0040) // Relação de Atributos
   oView:addSheet("MAIN", "F_RELACAO_PROD", STR0108) // Relação de Produtos x Origens/Fabricantes

   // Cria as divisões nas telas
   oView:CreateHorizontalBox( 'CAT_PROD', 100,,,'MAIN', 'F_CATALOGO_PRODUTOS')
   oView:CreateHorizontalBox( 'REL_ATRI', 100,,,'MAIN', 'F_ATRIBUTOS')
   oView:CreateHorizontalBox( 'REL_PROD_SUP', 50,,,'MAIN', 'F_RELACAO_PROD')
   oView:CreateHorizontalBox( 'REL_PROD_INF', 50,,,'MAIN', 'F_RELACAO_PROD')

   // EK9 - Catálogo de Produtos (capa)
   if lCatProdEx
      // Cria os agrupadores
      oStruEK9:AddGroup("01", STR0109, "01", 2) // Cadastrais
      oStruEK9:AddGroup("02", STR0111, "01", 2) // Dados Complementares

      // Remove os Folders
      oStruEK9:aFolders := {}

      // Lista de campos e seus respectivos grupos
      aCampos := {{"EK9_COD_I", "01"}, {"EK9_IDPORT","01"}, {"EK9_VATUAL","01"}, {"EK9_CNPJ","01"},;
                  {"EK9_MODALI","01"}, {"EK9_PRDREF","01"}, {"EK9_DESC_I","01"}, {"EK9_NCM", "01"},;
                  {"EK9_DSCNCM","01"}, {"EK9_UNIEST","01"}, {"EK9_IDMANU","01"}, {"EK9_VSMANU","01"},;
                  {"EK9_DSCCOM","02"}, {"EK9_OBSINT","02"}, {"EK9_MSBLQL","02"}, {"EK9_ULTALT","02"}}

      if( lMultiFil, aAdd( aCampos, {"EK9_FILORI", "01"}), nil)

      // Adiciona os campos nos grupos
      aEval(aCampos, {|x| oStruEK9:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })
   else
      // Cria os agrupadores
      oStruEK9:AddGroup("01", STR0109, "01", 2) // Cadastrais
      oStruEK9:AddGroup("02", STR0110, "01", 2) // Integração
      oStruEK9:AddGroup("03", STR0111, "01", 2) // Dados Complementares

      // Remove os Folders
      oStruEK9:aFolders := {}

      // Lista de campos e seus respectivos grupos
      aCampos := {{"EK9_COD_I", "01"}, {"EK9_IDPORT","01"}, {"EK9_VATUAL","01"}, {"EK9_IMPORT","01"}, {"EK9_CNPJ","01"},;
                  {"EK9_MODALI","01"}, {"EK9_PRDREF","01"}, {"EK9_DESC_I","01"}, {"EK9_STATUS","01"}, {"EK9_NCM", "01"},;
                  {"EK9_DSCNCM","01"}, {"EK9_UNIEST","01"}, {"EK9_RETINT","02"}, {"EK9_IDMANU","02"}, {"EK9_VSMANU","02"},;
                  {"EK9_DSCCOM","03"}, {"EK9_OBSINT","03"}, {"EK9_MSBLQL","03"}, {"EK9_ULTALT","03"}}

      if( lMultiFil, aAdd( aCampos, {"EK9_FILORI", "01"}), nil)

      // Adiciona os campos nos grupos
      aEval(aCampos, {|x| oStruEK9:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })
   endif

   // Demais propriedades
   oView:AddField('CATALOGO_PRODUTOS', oStruEK9, 'EK9MASTER')
   oView:SetOwnerView('CATALOGO_PRODUTOS', 'CAT_PROD')
   oStruEK9:SetProperty("EK9_CNPJ", MVC_VIEW_PICT, AVSX3("EKJ_CNPJ_R", 6))

   // EKC - Atributos
   If !canUseApp()
      CpoView(oStruEKC)
      oView:AddGrid("VIEW_EKC", oStruEKC ,"EKCDETAIL")
      oView:SetViewProperty("EKCDETAIL", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})  
   EndIf
   oView:SetOwnerView("VIEW_EKC", 'REL_ATRI')

   if( lMultiFil, (oStruEKB:SetProperty('EKB_FILORI' , MVC_VIEW_ORDEM ,'04'), oStruEKB:SetProperty('EKB_NOME'   , MVC_VIEW_ORDEM ,'05')), nil)

   // EKA - Catálogo de Produtos (detalhes) e EKB - Cadastro de Fabricantes
   oView:AddGrid("VIEW_EKA", oStruEKA, "EKADETAIL")
   oView:AddGrid("VIEW_EKB", oStruEKB, "EKBDETAIL")
   oView:SetOwnerView( "VIEW_EKA", 'REL_PROD_SUP')
   oView:SetOwnerView( "VIEW_EKB", 'REL_PROD_INF')
   oView:EnableTitleView('VIEW_EKA', STR0014 ) //'Relação de Produtos'
   oView:EnableTitleView('VIEW_EKB', STR0024) //"Relação de Países de Origem e Fabricantes"
   oView:AddIncrementField('VIEW_EKA', 'EKA_ITEM')

Return oView

/*
Programa   : CP400CANC
Objetivo   : Ação ao clicar no botao cancelar
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400CANC(oMdl)

   RollbackSx8()

Return .T.

Static Function CP400Fecha(oPanel)
If canUseApp() .And. isMemVar("oChannel")
   oChannel:AdvPLToJS("closeAppProductCatalog",'') //Força fechar o App
   FreeObj(oChannel)
   FreeObj(oPanel)
   FreeObj(oJsonAtt)
   FreeObj(oCpObrig)
   FreeObj(oCondicao)
EndIf
Return .T.
/*
Programa   : CP400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Dez/2019
Obs.       :
*/
Static Function CP400POSVL(oMdl)
   Local aArea			:= GetArea()
   Local lRet			:= .T.
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   // Local oModelEKB	:= oMdl:GetModel("EKBDETAIL")
   Local oModelEKC	:= oMdl:GetModel("EKCDETAIL")
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local lPosicEKD   := .F.
   Local lEasyhelp   := .F. 
   // Local lEmpPais    := .T. 
   local aAtributos  := {}
   local lAutoExec   := isExecAuto()
   local oModelEKA	:= nil
   local nProds      := 0
   local aOrdemEKA   := {}

      EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
      If EKD->(AvSeekLAst( xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I") ))
         lPosicEKD := .T.
      EndIf
   
      Begin Sequence
         If oMdl:GetOperation() == 5 //Exclusão
            if Alltrim(oModelEK9:GetValue("EK9_STATUS")) <> PENDENTE_REGISTRO
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0003,STR0002) //"Apenas é possível excluir Catalogo de produto com Status 'Registro Pendente' "##"Atenção"
               break               
            EndIf
            
            If lPosicEKD .And. EKD->EKD_STATUS == '1' .Or. EKD->EKD_STATUS == '3' //Integrado ou Cancelado
               lRet := .F.
               lEasyhelp := .T.
               EasyHelp(STR0048,STR0002) //"Não é possível excluir Catalogo de Produtos que possua integração com status Integrado ou Cancelado" //"Apenas é possível excluir Catalogo de produto com Status 'Registro Pendente' "##"Atenção"
               break               
            EndiF   

            If lRet .And. lPosicEKD
               If !TemIntegEKD(oModelEK9:GetVAlue("EK9_COD_I")) .And. EKD->EKD_STATUS == '2' //nao achou registros Integrados ou Cancelados e a Ultima versao é "Nao Integrado"            
                  cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro Não Integrado     
               Else
                  lRet := .F.	
                  lEasyhelp := .T.
                  EasyHelp(STR0044,STR0002) // "Não é possível excluir Catalogo de Produtos que possua integração com status Integrado ou Cancelado""##"Atenção"
                  break                  
               EndIf
            EndIf

         ElseIf oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusão ou Alteração	

            //grid elação de Países de Origem e Fabricantes Em branco - a linha 1 fica vazia - Lenght igual a 1 - quando há deleção de linhas volta a ficar 0 o Lenght
            // If oModelEKB:hasField("EKB_PAIS")
            //    lEmpPais := Empty(oModelEKB:GetValue("EKB_PAIS"))
            // EndIf

            // If oModelEKB:Length(.T.) == 0 .Or. ;
            //          oModelEKB:Length(.T.) == 1 .And. ;
            //          Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. Empty(oModelEKB:GetValue("EKB_LOJA")) .And. ;
            //          lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS"))
            //    EasyHelp(STR0083,STR0002,STR0084)  //Problema: "Não foram informados fabricantes ou países de origem" Solução: "Informe ao menos um país de origem ou fabricante para prosseguir"
            
            //    lRet := .F.	
            //    lEasyhelp := .T.
            //    break
            // EndIf

            if isRest()
               oModelEKA := oMdl:GetModel("EKADETAIL")
               if valtype(oModelEKA) == "O"
                  for nProds := 1 to oModelEKA:Length(.T.)
                     oModelEKA:goline(nProds)
                     if empty(oModelEKA:getvalue( "EKA_ITEM" ))
                        lRet := .F.
                        EasyHelp( StrTran( STR0204, "XXX", AVSX3("EKA_ITEM", AV_TITULO)), STR0002, StrTran( STR0205 , "YYYY", cValtoChar(nProds))) // "O campo XXX é obrigatório do formulário EKADETAIL." ### "Atenção" ### "Deve ser informado um sequencial para a linha YYYY."
                        break
                     else
                        if aScan( aOrdemEKA, { |X| X == oModelEKA:getvalue( "EKA_ITEM" ) }) > 0
                           lRet := .F.
                           EasyHelp( STR0206, STR0002,  StrTran( STR0207 , "XXX", AVSX3("EKA_ITEM", AV_TITULO))) // "A ordem dos produtos foi informado mais de uma vez." ### "Atenção" ### "Verifique a ordem informada no campo XXX do formulário EKADETAIL."
                           break
                        endif
                        aAdd( aOrdemEKA, oModelEKA:getvalue( "EKA_ITEM" ) )
                     endif
                  next
               endif
            endif

            cIdManu  := oModelEK9:GetValue("EK9_IDMANU") 
            cVsManu  := oModelEK9:GetValue("EK9_VSMANU") 
            If Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. !Empty(cIdManu) .And. Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0037,STR0002) // "Ao preencher o campo ID Manual também será necessário preencher o campo Versão Manual"##"Atenção"
               break               
            EndIf

            If Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. Empty(cIdManu) .And. !Empty(cVsManu)
               lRet := .F.	
               lEasyhelp := .T.
               EasyHelp(STR0041,STR0002) // "Ao preencher o campo ID Manual também será necessário preencher o campo Versão Manual"##"Atenção"
               break               
            EndIf

            If !empty(cIdManu) .and. !empty(cVsManu)
               cErro := ""
               lRet := ValIdVers( cIdManu , cVsManu , oMdl:GetOperation(), @cErro)
               if lRet .and. oModelEK9:GetValue("EK9_MODALI") == "2" .and. oMdl:GetOperation() == MODEL_OPERATION_UPDATE
                  lRet := ValProcExp( cIdManu , cVsManu, @cErro)
               endif
               If !lRet
                  break
               EndIf
            EndIf

            if lRet .and. ( !lAutoExec ) .and. ( !oModelEK9:HasField("EK9_PERATR") .or. !(oModelEK9:getValue("EK9_PERATR") == "2" ))
               If !canUseApp() //Valida atributos do POUI
                  aAtributos := getAtrVazio( oModelEKC,,, oModelEK9:getValue("EK9_MODALI") )
                  if len(aAtributos) > 0
                     MsgInfo(STR0120 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0121, STR0002)  // "Existem atributos obrigatórios e vigentes que não foram preenchidos." ### "Revise as informações do catalogo de produtos." ### "Atenção"
                  endif
               EndIf
            endif

         EndIf
      End Sequence   

      If !Empty(cErro)
         lRet := .F.
         lEasyhelp := .T.
         EasyHelp(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Atenção
      EndIf

      RestArea(aArea)

Return lRet
/*
Programa   : CP400COMMIT
Objetivo   : Funcao de Commit - utilizado para campos cujo formulario do mvc nao grava  
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Mar/2020
Obs.       :
*/
Static Function CP400COMMIT(oMdl)
   Local oModelEK9	:= oMdl:GetModel("EK9MASTER")
   Local oGridEKB    := oMdl:GetModel("EKBDETAIL")
   Local cIdManu     := ""
   Local cVsManu     := ""
   Local cErro       := ""
   Local cStatusEK9  := "" 
   Local lRet        := .T.
   Local lPosicEKD   := .F.
   Local lRetDif     := .F.
   Local aOEs        := {}
   Local lPendRetif  := .F.
   local lCatProdEx  := FwIsInCallStack("EECCP400")
   local lAutoExec   := isExecAuto()
   local lAltFabPais := .F.
   local lAltCatProd := .F.
   local cVAtual     := ""

      if !lCatProdEx
         EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
         If EKD->(AvSeekLast(xFilial("EKD") + oModelEK9:GetVAlue("EK9_COD_I")))
            lPosicEKD := .T.
         EndIf

         If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao
            // Caso tenha operador estrangeiro relacionado ao produto não cadastrado cadastra via rotina automática
            if CP400OEValid(oGridEKB,oModelEK9,@aOEs)
               CP400ExecEKJ(aOEs,oModelEK9)
               oMdl:activate()
            endif
         endif
      endif
      If canUseApp() .And. !lAutoExec
         setMsgPOUI(STR0217, "false") //"Validando atributos..."
         lPOUIOKCM := .F.
         oChannel:AdvPLToJS("getObrigatorio",'')
         If WaitPOUI({|| lPOUIOKCM })
            lRet:= CP400BTNOK("VIEW", oMdl)
         Else
            lRet := .F.
         EndIf
      EndIf
      If lRet
         Begin Transaction
            
            If oMdl:GetOperation() == 3 .Or. oMdl:GetOperation() == 4 //Inclusao ou Alteracao

               cIdManu  := oModelEK9:GetValue("EK9_IDMANU")
               cVsManu  := oModelEK9:GetValue("EK9_VSMANU")

               If !lCatProdEx .and. oMdl:GetOperation() <> 3 
                  lRetDif := VerificDif(oMdl, @lAltFabPais, @lAltCatProd) .Or. lAltPOUI
                  If lRetDif .And. !Empty(cVsManu) .And. cVsManu == EK9->EK9_VATUAL
                     //se foi encontrada diferença e se não for execauto exibe a pergunta. Senão segue como Sim(Existe Diferença)             
                     If lRetDif .And. !lAutoExec .And. !MsgNoYes(STR0043,STR0002) //"O catalogo alterado foi registrado manualmente no portal único, 
                                                      //deseja gerar uma nova versão para integração automática pelo sistema com os dados informados?" ## "Atenção"
                        lRetDif := .F. 
                     EndIf
                  EndIf         
               EndIf

               If lRetDif .And. oMdl:GetOperation() == 4 .And. ((!Empty(cVsManu) .And. EK9->EK9_VSMANU == oModelEK9:GetValue("EK9_VSMANU")) .Or. oModelEK9:GetValue("EK9_STATUS") $ REGISTRADO + "|" + REGISTRADO_PENDENTE_FAB_PAIS )//Se teve alteração e tem versão manual, limpa a informação para que seja possível integrar
                  cVAtual := oModelEK9:GetValue("EK9_VATUAL")
                  oModelEK9:LoadValue("EK9_VSMANU", " ")
                  oModelEK9:LoadValue("EK9_VATUAL", " ")
                  cIdManu  := " "
                  cVsManu  := " "
                  lPendRetif := .T.
               EndIf
               If !Empty(cVsManu) 
                  oModelEK9:SetValue("EK9_ULTALT",cUserName)
                  oModelEK9:LoadValue("EK9_VATUAL", oModelEK9:GetValue("EK9_VSMANU") )
                  If !Empty(cIdManu)
                     oModelEK9:LoadValue("EK9_IDPORT", oModelEK9:GetValue("EK9_IDMANU") )
                  EndIf
               EndIf

               if !lCatProdEx .and. (lRetDif .or. oMdl:GetOperation() == 3)
                  // "EK9_STATUS" -> "1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Bloqueado;5=Registrado Manualmente;6=Registrado Pendente Fabricante/País"
                  if oMdl:GetOperation() == 3 .And. Empty(cVsManu)
                     cStatusEK9 := "2"
                  elseif !Empty(oModelEK9:GetValue("EK9_IDPORT")) .And. !Empty(oModelEK9:GetValue("EK9_VATUAL")) .And. Empty(cVsManu)
                     cStatusEK9 := "1"
                  elseif oModelEK9:GetValue("EK9_MSBLQL") == "1" 
                     cStatusEK9 := "4"
                  elseif lPendRetif .or. (EK9->EK9_STATUS == PENDENTE_RETIFICACAO .And. Empty(cVsManu))
                     if lAltFabPais .and. !lAltCatProd
                        cStatusEK9 := "6"
                        oModelEK9:LoadValue("EK9_VATUAL", cVAtual)
                     else
                        cStatusEK9 := "3"
                        oModelEK9:LoadValue("EK9_RETINT", "")
                     endif
                  elseif !Empty(cVsManu)
                     cStatusEK9 := "5" //Registrado Manualmente
                  else
                     cStatusEK9 := "2"
                  endif
                  oModelEK9:LoadValue("EK9_STATUS", cStatusEK9)
               EndIf

               If Empty(cErro)
                  CommitEKC(oMdl)
                  FWFormCommit(oMdl)
                  //havendo diferenças, versao manual igual a versao atual - resposta Sim para a pergunta de gerar Inclusao de Integracao Cat Prod.
                  If !lCatProdEx .and. (oMdl:GetOperation() == 3 .Or. (lRetDif .and. oModelEK9:GetValue("EK9_MSBLQL") <> "1"))
                     cErro := IncluInteg(oModelEK9)
                  EndIf

               Else
                  DisarmTransaction()
               EndIf
            EndIf 

            If oMdl:GetOperation() == 5
               CommitEKC(oMdl)
               FWFormCommit(oMdl)
               If lPosicEKD
                  cErro := ExcIntegr(EKD->EKD_COD_I, EKD->EKD_VERSAO ) //Exclusao de registro Não Integrado     
               EndIf
            EndIf

         End Transaction
      EndIf

      //primeiro commita o catalogo com a alteração do campo para depois incluir a integração e se houver erro a transação de inclusao
      //sera desarmada pela rotina EICCP401
      If !Empty(cErro)
         EECVIEW(cErro,STR0002) //apresenta a mensagem de Erro da Rotima Automatica ExecAuto ## Atenção 
         lRet := .F.
      EndIf

Return lRet

/*
Programa   : IncluInteg
Objetivo   : Funcao utilizada para Incluir integração do catálogo de produtos 
Retorno    : Caractere - Erro da Execução Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function IncluInteg( oModelEK9)
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

      aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")                    , Nil})
      aAdd(aCapaEKD,{"EKD_COD_I"	, oModelEK9:GetValue("EK9_COD_I")   , Nil})

      MSExecAuto({|a,b| EICCP401(a,b)}, aCapaEKD, 3)

      If lMsErroAuto
         aErros := GetAutoGRLog()
         For nJ:= 1 To Len(aErros)
            cLogErro += aErros[nJ]+ENTER
         Next nJ
      EndIf

Return cLogErro

/*
Programa   : VerificDif(oMdl)
Objetivo   : Funcao utilizada para Incluir integração do catálogo de produtos 
Retorno    : Caractere - Erro da Execução Automatica
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function VerificDif(oMdl, lAltFabPais, lAltCatProd)
   local lRet        := .F.
   Local oModelEK9   := oMdl:GetModel("EK9MASTER")
   Local oModelEKA   := oMdl:GetModel("EKADETAIL")
   Local oModelEKB   := oMdl:GetModel("EKBDETAIL")
   Local oModelEKC   := oMdl:GetModel("EKCDETAIL")
   Local nI          := 0
   Local lAchouDif   := .F.
   Local cChaveEKC   := ""
   Local cVersaoEKD
   local lCondic     := .F.
   local lMultiFil   := isMultFil()
   local lEKBPAIS    := .F.

   default lAltFabPais := .F.
   default lAltCatProd := .F.
   
      begin sequence
         CP401AltInf(.F.)

         //Verifica se foi excluido o registro da EKD. Se sim, gera um novo
         cVersaoEKD := CPGetVersion(xFilial("EKD"), oModelEK9:GetValue("EK9_COD_I"))
         If !EKD->(dbsetorder(1),DbSeek(xFilial("EKD") + oModelEK9:GetValue("EK9_COD_I") + cVersaoEKD))
            lAchouDif := .T.
            break
         EndIf

         if (getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V" .And. !(EK9->EK9_DESC_I == oModelEK9:GetValue("EK9_DESC_I")))
            lAchouDif := .T.
            CP401AltInf(lAchouDif)
            break            
         endif

         If EK9->EK9_IDPORT <> oModelEK9:GetValue("EK9_IDPORT") .Or. EK9->EK9_VATUAL <> oModelEK9:GetValue("EK9_VATUAL") .Or. ;
            EK9->EK9_IMPORT <> oModelEK9:GetValue("EK9_IMPORT") .Or. AvKey(EK9->EK9_CNPJ, "EKJ_CNPJ_R") <> AvKey(oModelEK9:GetValue("EK9_CNPJ"), "EKJ_CNPJ_R")   .Or. ;
            EK9->EK9_MODALI <> oModelEK9:GetValue("EK9_MODALI") .Or. EK9->EK9_NCM    <> oModelEK9:GetValue("EK9_NCM")    .Or. ;
            EK9->EK9_UNIEST <> oModelEK9:GetValue("EK9_UNIEST") .Or. EK9->EK9_STATUS <> oModelEK9:GetValue("EK9_STATUS") .Or. ;
            !(EK9->EK9_DSCCOM == oModelEK9:GetValue("EK9_DSCCOM")) .Or. !(EK9->EK9_RETINT == oModelEK9:GetValue("EK9_RETINT")) .Or. ;
            EK9->EK9_IDMANU <> oModelEK9:GetValue("EK9_IDMANU") .Or. EK9->EK9_VSMANU <> oModelEK9:GetValue("EK9_VSMANU") .Or. ;
            EK9->EK9_MSBLQL <> oModelEK9:GetValue("EK9_MSBLQL") .Or. ;
            (lMultiFil .AND. EK9->EK9_FILORI <> oModelEK9:GetValue("EK9_FILORI")) 
               lAchouDif := .T.
               break
         EndIf

         For nI := 1 To oModelEKA:Length()
            oModelEKA:GoLine( nI )
            if ((oModelEKA:isInserted() .or. oModelEKA:isDeleted() .or. oModelEKA:isUpdated() ) .and. !empty(oModelEKA:GetValue("EKA_PRDREF")))
               lAchouDif := .T.
               break   
            endif
         Next nI

         lEKBPAIS := oModelEKB:hasField("EKB_PAIS")
         For nI := 1 To oModelEKB:Length()
            oModelEKB:GoLine( nI )
            if ((oModelEKB:isInserted() .or. oModelEKB:isDeleted() .or. oModelEKB:isUpdated() ) .and. ((!empty(oModelEKB:GetValue("EKB_CODFAB") + oModelEKB:GetValue("EKB_LOJA"))) .or. ;
                                                                                                      if( lEKBPAIS, !empty(oModelEKB:GetValue("EKB_PAIS")), .F.)))
               lAltFabPais := .T.
               exit
            endif
         Next nI

         if canUseApp() .and. isMemVar("lAltPOUI") .and. lAltPOUI
            lAchouDif := .T.
            break
         endif

         EKC->(dbsetorder(1))
         lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
         For nI := 1 To oModelEKC:Length()
            oModelEKC:GoLine( nI )

            if (alltrim(upper(oModelEKC:GetValue("EKC_STATUS"))) == "EXPIRADO" .OR. alltrim(upper(oModelEKC:GetValue("EKC_STATUS"))) == alltrim(upper(STR0007))) .and. oModelEKC:isdeleted()
               lAchouDif := .T.
               break
            endif

            if !oModelEKC:isdeleted()
               cChaveEKC := xFilial("EKC") + PADR(oModelEK9:GetValue("EK9_COD_I"),AVSX3("EKC_COD_I",3)) + oModelEKC:GetValue("EKC_CODATR") + if( lCondic, oModelEKC:getValue("EKC_CONDTE"), "") 
               If EKC->(dbSeek( cChaveEKC ))
                  If !(EKC->EKC_VALOR == oModelEKC:GetValue("EKC_VALOR"))
                     lAchouDif := .T.
                     break
                  EndIf
               elseIf !Empty(oModelEKC:GetValue("EKC_VALOR"))
                  lAchouDif := .T.
                  break
               EndIf
            endif
         Next nI

      end sequence

lAltCatProd := lAchouDif
lRet := lAltCatProd .or. lAltFabPais
Return lRet

/*{Protheus.doc} CPGetVersion
   Busca a última versão do integrador do catálogo de produtos
   @author Miguel Prado Gontijo
   @since 20/06/2020
   @version 1
   @param cXFil e cXCodI - Filial e código do item a ser buscado a última versão
   @return Nil
*/
function CPGetVersion( cXFil , cXCodI )
   Local cRet := ""

   if select("EKDVERSAO") > 0
      EKDVERSAO->(dbclosearea())
   endif

   BeginSql Alias "EKDVERSAO"
      select MAX(EKD_VERSAO) VERSAO 
      from %table:EKD% EKD 
      where EKD_FILIAL  = %Exp:cXFil%
         and EKD_COD_I  = %Exp:cXCodI%
         and EKD.%NotDel%
   EndSql

   if EKDVERSAO->(! eof())
      cRet := EKDVERSAO->VERSAO
   endif
   EKDVERSAO->(dbclosearea())

Return AvKey(cRet,"EKD_VERSAO")
/*
Programa   : CP400CadOE
Objetivo   : Inserir registros no cadastro de operador estrangeiro
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : 10/06/2020
Obs.       :
*/
Function CP400CadOE()
   Local oModel      := FWLoadModel("EICCP400")
   Local oModelEKB   := oModel:GetModel("EKBDETAIL")
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local aOEs        := {}
   Local lRet := .t.

   oModel:Activate()
   if CP400OEValid(oModelEKB,oModelEK9,@aOEs)
      lRet := CP400ExecEKJ(aOEs,oModelEK9)
      oModel:activate()
   Else 
         EasyHelp( StrTran(STR0069,"######",EK9->EK9_COD_I),STR0021) //Aviso Nenhum registro para processar. Todos os fabricantes do catálogo ###### já se encontram no cadastro de operador estrangeiro
   endif

Return
/*
Programa   : CP400OEValid
Objetivo   : Funcao que valida se deve gerar o cadastro de operador estrangeiro a partir do cadastro de fabricante relacionado ao produto do catálogo
Retorno    : Lógico
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
static function CP400OEValid(oModelEKB,oModelEK9,aOEs)
   Local lRet        := .F.
   Local nLinEKB     := 1
   Local cChaveEKJ2  := ""
   Local aAux        := {}
   Local aAreaEKJ    := EKJ->(getarea())
   local aRegOper    := {}

   EKJ->(dbsetorder(1))

   for nLinEKB := 1 to oModelEKB:length()
      if ! oModelEKB:isdeleted(nLinEKB)
         if ! empty( oModelEKB:getvalue("EKB_CODFAB", nLinEKB) ) .and. ! empty( oModelEKB:getvalue("EKB_LOJA", nLinEKB) )
            cChaveEKJ2 := xFilial("EKJ") + AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R") + oModelEKB:getvalue("EKB_CODFAB", nLinEKB)  + oModelEKB:getvalue("EKB_LOJA", nLinEKB)
            if !EKJ->(msseek(cChaveEKJ2)) .and. aScan( aRegOper, { |x| x == cChaveEKJ2 } ) == 0
               aAdd( aRegOper, cChaveEKJ2 )
               aAux := {}
               Aadd( aAux, { "EKJ_FILIAL"  , xFilial("EKJ")                            , Nil })
               Aadd( aAux, { "EKJ_IMPORT"  , oModelEK9:GetValue("EK9_IMPORT")          , Nil })
               Aadd( aAux, { "EKJ_CNPJ_R"  , AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R"), Nil })
               Aadd( aAux, { "EKJ_FORN"    , oModelEKB:getvalue("EKB_CODFAB" , nLinEKB) , Nil })
               Aadd( aAux, { "EKJ_FOLOJA"  , oModelEKB:getvalue("EKB_LOJA"   , nLinEKB) , Nil })
               aadd( aOEs, aclone(aAux))
            endif
         endif
      endif
   next

   lRet := len(aOEs) > 0

   restarea(aAreaEKJ)
return lRet


/*
Programa   : CP400ExecEKJ(aOEs)
Objetivo   : ExecAuto de Operador Estrangeiro - Grava o fabricante na tabela de operador estrangeiro
Parâmetro  : aOEs - array que contém uma lista de operadores a serem incluídos via rotina automática
Retorno    : Nil
Autor      : Miguel Gontijo
Data/Hora  : 06/2020
Obs.       :
*/
function CP400ExecEKJ(aOEs,oModelEK9)
   Local aArea       := getarea()
   Local aLog        := {}
   Local i           := 0
   Local nx          := 0
   Local nPosForn    := ""
   Local nPosFoLoja  := ""
   Local cMsg        := ""
   Local lRet        := .T.
   local lAutoExec   := isExecAuto()

   Private lMsErroAuto     := .F.
   Private lAutoErrNoFile  := .T.
   Private lMsHelpAuto     := .F. 

   For i := 1 to len(aOEs)
      lMsErroAuto := .F.
      MsExecAuto({|x,y| EICOE400(x,y) },aOEs[i], 3)
      if lMsErroAuto
         lRet := .F.
         aLog        := GetAutoGrLog()
         nPosForn    := ascan(aOEs[i], {|x| x[1] == "EKJ_FORN" })
         nPosFoLoja  := ascan(aOEs[i], {|x| x[1] == "EKJ_FOLOJA" })
         cMsg        += STR0074 + alltrim(oModelEK9:getvalue('EK9_COD_I')) + ENTER //"Erro na inclusão do registro de operador estrangeiro para o catálogo "
         cMsg        += STR0077 + Alltrim(aOEs[i][nPosForn][2]) + " Loja: " + Alltrim(aOEs[i][nPosFoLoja][2]) + ENTER //"Fornecedor: "
         cMsg        += STR0078 + ENTER //"Esse erro não intefere na gravação do catálogo de produtos(Veja mensagem abaixo)"
         for nx := 1 to len(aLog)
            cMsg += Alltrim(aLog[nx]) + ENTER
         Next
      EndIf
   Next

   if !empty(cMsg) .and. !lAutoExec
      EECVIEW(cMsg, STR0002,,,,, .T.)
   endif

   restarea(aArea)

return lRet
/*
Programa   : ExcIntegr
Objetivo   : Funcao utilizada para excluir integração do catálogo de produtos Não Integrada
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function ExcIntegr( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 5)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CancInteg
Objetivo   : Funcao utilizada para Cancelar integração do catálogo de produtos
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Maio/2020
Obs.       :
*/
Static Function CancInteg( cCat, cVersao )
   Local aCapaEKD := {}
   Local aErros   := {}
   Local nJ       := 1
   Local cLogErro := ""

   Private lMsHelpAuto     := .T. 
   Private lAutoErrNoFile  := .T.
   Private lMsErroAuto     := .F.

   aAdd(aCapaEKD,{"EKD_FILIAL", xFilial("EKD")  , Nil})
   aAdd(aCapaEKD,{"EKD_COD_I"	, cCat            , Nil})
   aAdd(aCapaEKD,{"EKD_VERSAO", cVersao         , Nil})

   MSExecAuto({|a,b| EICCP401 (a,b)}, aCapaEKD, 4)

   If lMsErroAuto
      aErros := GetAutoGRLog()
      For nJ:= 1 To Len(aErros)
         cLogErro += aErros[nJ]+ENTER
      Next nJ
   EndIf

Return cLogErro
/*
Programa   : CP400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Ramon Prado
Data/Hora  : 27/11/2019
Obs.       :
*/
Function CP400Legen()
   Local aCores := {}

   aCores := { {"ENABLE"       , STR0004 },; // "Registrado"
               {"BR_AZUL_CLARO", STR0156 },; // "Registrado Manualmente"
               {"BR_AZUL"      , STR0250 },; //"Registrado (pendente: fabricante/país)"
               {"BR_CINZA"     , STR0005 },; // "Pendente Registro"
               {"BR_AMARELO"   , STR0006 },; // "Pendente Retificação"
               {"DISABLE"      , STR0007 }}  // "Bloqueado"

   BrwLegenda(STR0001,STR0013,aCores)

Return .T.
/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
   Local aVisions    := {}
   Local aColunas    := AvGetCpBrw("EK9")
   Local aContextos  := {"REGISTRADO", "REGISTRADO_MANUALMENTE", "REGISTRADO_PENDENTE_FAB_PAIS", "PENDENTE_REGISTRO", "PENDENTE_RETIFICACAO", "BLOQUEADO"} // {STR0004,STR0005,STR0006,STR0007}
   Local cFiltro     := ""
   Local oDSView
   Local i

   If aScan(aColunas, "EK9_FILIAL") == 0
      aAdd(aColunas, "EK9_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := RetFilter(aContextos[i])            
      oDSView    := FWDSView():New()
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
Função     : RetFilter(cTipo,lNome)
Objetivo   : Retorna a chave ou nome do filtro da tabela EK9 de acordo com o contexto desejado
Parâmetros : cTipo - Código do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome)
   Local cRet     := ""
   Default lNome  := .F.

      Do Case
         Case cTipo == "REGISTRADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '1' "
         Case cTipo == "REGISTRADO" .And. lNome
            cRet := STR0004 //"Registrado" "

         Case cTipo == "REGISTRADO_MANUALMENTE" .And. !lNome
            cRet := "EK9->EK9_STATUS = '5' "
         Case cTipo == "REGISTRADO_MANUALMENTE" .And. lNome
            cRet := STR0156 //"Registrado Manualmente"

         Case cTipo == "PENDENTE_REGISTRO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '2' "
         Case cTipo == "PENDENTE_REGISTRO" .And. lNome
            cRet := STR0005 //"Pendente Registro" "

         Case cTipo == "PENDENTE_RETIFICACAO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '3' "
         Case cTipo == "PENDENTE_RETIFICACAO" .And. lNome
            cRet := STR0006 //"Pendente Retificação" "

         Case cTipo == "BLOQUEADO" .And. !lNome
            cRet := "EK9->EK9_STATUS = '4' .OR. EK9->EK9_MSBLQL = '1' "
         Case cTipo == "BLOQUEADO" .And. lNome
            cRet := STR0007 //"Bloqueado"

         Case cTipo == "REGISTRADO_PENDENTE_FAB_PAIS" .And. !lNome
            cRet := "EK9->EK9_STATUS = '6' "
         Case cTipo == "REGISTRADO_PENDENTE_FAB_PAIS" .And. lNome
            cRet := STR0250 //"Registrado (pendente: fabricante/país)"

      EndCase

Return cRet

/*
Função     : CP400SB1F3()
Objetivo   : Monta a consulta padrão da filial de origem do produto para seleção 
             
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Ramon Prado (adaptada da função NF400SD2F3, fonte: EICCP400)
Data       : Dez/2019
Revisão    :
*/
Function CP400SB1F3()
   Local aSeek    := {}
   Local bOk      := {|| ( if( cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF", (cFilSB1F3 := SB1->B1_FILIAL) , (cFilSA2F3 := SA2->A2_FILIAL) ) ), lRet:= .T., oDlgF3:End()}
   Local bCancel  := {|| lRet:= .F.,  oDlgF3:End()}
   Local cCpo     := AllTrim(Upper(ReadVar()))
   Local aColunas	:= IF(cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF", AvGetCpBrw("SB1",,.T. /*desconsidera virtual*/), AvGetCpBrw("SA2",,.T. /*desconsidera virtual*/))
   Local lRet     := .F.
   Local nX       := 1
   Local oDlgF3
   Local oBrowseF3
   local lMultiFil := isMultFil()
   local cFiltFil  := ""

   Private cTitulo   := ""
   Private aCampos   := {}
   Private aFilter   := {} 

   Begin Sequence

      cFilSB1F3 := ""
      cFilSA2F3 := ""
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aAdd(aColunas,"B1_IMPORT")
      Elseif cCpo == "M->EKB_CODFAB" .And. aScan(aColunas, "A2_FILIAL") == 0      
         aAdd(aColunas,Nil)
         AIns(aColunas,1)
         aColunas[1] := "A2_FILIAL"    
      EndIf   
      
      /* Campos usados na pesquisa */
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         aSeek := AVIndSeek("SB1",3)
      Else
         aSeek := AVIndSeek("SA2",3)
      EndIf

      For nX := 1 to Len(aColunas)
         /* Campos usados no filtro */
         AAdd(aFilter, {aColunas[nX]  , AvSx3(aColunas[nX]    , AV_TITULO) , AvSx3(aColunas[nX]    , AV_TIPO) , AvSx3(aColunas[nX]    , AV_TAMANHO) , AvSx3(aColunas[nX]    , AV_DECIMAL), AvSx3(aColunas[nX]    , AV_PICTURE)})
      Next nX
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF"    
         AllCpoIndex("SB1",aColunas)
         cTitulo := STR0016
      Else
         AllCpoIndex("SA2",aColunas)
         cTitulo := STR0035
      EndIf
      
      Define MsDialog oDlgF3 Title STR0001 + " - " + cTitulo From DLG_LIN_INI, DLG_COL_INI To DLG_LIN_FIM * 0.9, DLG_COL_FIM * 0.9 Of oMainWnd Pixel

      oBrowseF3 := FWBrowse():New(oDlgF3)
      
      If cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         oBrowseF3:SetDataTable("SB1")
         oBrowseF3:SetAlias("SB1")
         //cTitulo := STR0016
         oBrowseF3:SetColumns(AddColumns(aColunas, "SB1"))
      Else
         oBrowseF3:SetDataTable("SA2")
         oBrowseF3:SetAlias("SA2")
         //cTitulo := STR0035
         oBrowseF3:SetColumns(AddColumns(aColunas, "SA2"))
      EndIf

      oBrowseF3:SetDoubleClick( bOk )
      /* Pesquisa */
      oBrowseF3:SetSeek(, aSeek)
      
      /* Filtro */	
      oBrowseF3:SetUseFilter()
      oBrowseF3:SetFieldFilter(aFilter)

      if cCpo == "M->EK9_PRDREF" .Or. cCpo == "M->EKA_PRDREF" 
         cFiltFil  := xFilial("SB1")
         cFiltFil := "B1_FILIAL " + if( lMultiFil, "IN ( " + getFilUser() + " ) ", "= '" + cFiltFil + "' ")
         oBrowseF3:AddFilter('Default',"@" + cFiltFil + " AND B1_IMPORT = 'S' AND B1_MSBLQL <> '1' ",.F.,.T.)
      else
         cFiltFil := xFilial("SA2")
         cFiltFil := "A2_FILIAL " + if( lMultiFil, "IN ( " + getFilUser() + " ) ", "= '" + cFiltFil + "' ")
         oBrowseF3:AddFilter('Default',"@" + cFiltFil + " AND A2_MSBLQL <> '1' ",.F.,.T.)
      endif

      If cCpo == "M->EKA_PRDREF" .And. !Empty(M->EK9_NCM)
         oBrowseF3:AddFilter('Ncm',"@B1_POSIPI = '" + M->EK9_NCM + "' ",.F.,.T.)
      EndIF

      oBrowseF3:Activate()
      
      Activate MsDialog oDlgF3 On Init (EnchoiceBar(oDlgF3, bOk, bCancel,,,,,,,.F.))	

   End Sequence

Return lRet

/*
Função     : CP400Relac(cCampo)
Objetivo   : Inicializar dados dos campos do grid(Relacao de Produtos - Catalogo de prds)
Parâmetros : cCampo - campo a ser inicializado
Retorno    : cRet - Conteudo a ser inicializado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400Relac(cCampo)
   Local aArea       := getArea()
   Local cRet        := "" 
   Local oModel      := FWModelActive()
   Local cChaveEKJ   := ""
   Local cChaveSA2   := ""
   local lCondic     := .F.
   local lMultiFil   := isMultFil()

   If oModel:GetOperation() <> 3

      Do Case
         Case cCampo == "EKA_DESC_I"
            cRet := POSICIONE("SB1",1,if( lMultiFil , EKA->EKA_FILORI, XFILIAL("SB1")) + EKA->EKA_PRDREF ,"B1_DESC")
         Case cCampo == "EK9_DESC_I"
            cRet := POSICIONE("SB1",1,if( lMultiFil , EK9->EK9_FILORI, XFILIAL("SB1")) + EK9->EK9_PRDREF ,"B1_DESC")
         Case cCampo == "EKB_NOME"
            If lMultiFil
               cRet := POSICIONE("SA2",1,EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            Else
               cRet := POSICIONE("SA2",1,xFilial("SA2")+EKB->EKB_CODFAB+EKB->EKB_LOJA,"A2_NOME")
            EndIf
         Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"
            If lMultiFil
               cChaveSA2 := EKB->EKB_FILORI+EKB->EKB_CODFAB+EKB->EKB_LOJA
            Else
               cChaveSA2 := xFilial("SA2")+EKB->EKB_CODFAB+EKB->EKB_LOJA
            EndIf
            SA2->(dbsetorder(1))
            if SA2->(dbseek(cChaveSA2))
               cChaveEKJ := xFilial("EKJ") + EK9->EK9_CNPJ + SA2->A2_COD + SA2->A2_LOJA
               EKJ->(dbsetorder(1))
               if EKJ->(dbSeek(cChaveEKJ))
                  if cCampo == "EKB_OENOME"
                     cRet := EKJ->EKJ_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := EKJ->EKJ_STATUS
                  elseif ccampo == "EKB_OPERFB"
                     cRet := EKJ->EKJ_TIN
                  endif
               else
                  if cCampo == "EKB_OENOME"
                     cRet := SA2->A2_NOME
                  elseif cCampo == "EKB_OEEND"
                     cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
                  elseif cCampo == "EKB_OESTAT"
                     cRet := "2"
                  endif
               endif
            endif
         Case cCampo == "EKB_PAISDS"
            cRet := POSICIONE("ELO",1,xFilial("ELO")+EKB->EKB_PAIS,"ELO_DESC") //POSICIONE("SYA",1,xFilial("SYA")+EKB->EKB_PAIS,"YA_DESCR")
         Case cCampo == "EKC_STATUS"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG)
            EndIf
         Case cCampo == "EKC_NOME"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := AllTrim(EKG->EKG_NOME)
            EndIf
         Case cCampo == "ATRIB_OBRIG"
            EKG->(dbSetOrder(1))
            lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
            If EKG->(DBSEEK(xFilial("EKG") + EK9->EK9_NCM + EKC->EKC_CODATR + if( lCondic, EKC->EKC_CONDTE,"") ))
               cRet := if(empty(EKG->EKG_OBRIGA),"2", EKG->EKG_OBRIGA)
            EndIf

         Case cCampo == "EKC_VLEXIB"
            //cRet := IIF(!Empty(EKC->EKC_VALOR),SubSTR(EKC->EKC_VALOR,1,100),"")
                     
      EndCase	
   EndIf

   RestArea(aArea)

Return cRet

/*
Função     : CP400When(cCampo)
Objetivo   : Define se campo será habilitado para ediçao/alteração ou não na tela
Parâmetros : cCampo - campo a verificado o when(será habilitado pra edição/alteração ou nao na tela)
Retorno    : lWhen - lógico sim ou nao
Autor      : Ramon Prado
Data       : maio/2021
Revisão    :
*/
Function CP400When(cCampo)
   Local aArea       := getArea()
   Local lWhen       := .T.
   Local lCatProdEx  := FwIsInCallStack("EECCP400")

   Do Case
      Case cCampo == 'EKB_PAIS'
         If (SemPerm() .or. !Empty(Fwfldget("EKB_CODFAB")) .and. !EMPTY(Fwfldget("EKB_LOJA"))) .AND. !FwIsInCallStack('CP404ImpArq')
            lWhen := .F.
         EndIf
      Case cCampo == 'EK9_MSBLQL'   //MFR 14/02/2022 OSSME-6604        
            if Inclui .or. SemPerm()
               lWhen := .F.         
            endif
      Case cCampo == 'EK9_VSMANU'
            if SemPerm()
               lWhen := .F.
            elseif Inclui .or. lCatProdEx .or. isRest() .Or. Empty(EK9->EK9_VATUAL)
               lWhen := .T.
            endif
      Case cCampo == 'EK9_IDMANU'
            if SemPerm()
               lWhen := .F.
            elseif Inclui .or. isRest() .or. (Empty(EK9->EK9_IDPORT) .And. Empty(EK9->EK9_VATUAL))
               lWhen := .T.
            endif   
      Case cCampo == 'EK9_NCM' .Or. cCampo == 'EK9_UNIEST' 
            lWhen := Inclui
      Case cCampo == "EK9_RETINT" .or. cCampo == "EK9_IDPORT" .or. cCampo == "EK9_VATUAL" .or. cCampo == "EK9_STATUS"
            lWhen := .F.
      Case cCampo == "EK9_PERALT" .or. cCampo == "EK9_PERATR"
            lWhen := FwIsAdmin()
      otherwise
         if SemPerm()
            lWhen := .F.
         endif
   EndCase

   RestArea(aArea)
Return lWhen

static function SemPerm()
return !Inclui .and. !IsRest() .and. AvFlags("PERMISSAO_CATALOGO_OPERADOR") .and. EK9->EK9_PERALT == "2"

/* 
Função     : CP400AtLn1()
Objetivo   : Gatilho para preencher produto de referência na linha 1 do detalhe(Relacao de produtos)
Parâmetros : 
Retorno    : cRet - Conteudo a ser gatilhado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400AtLn1()	
   local aArea       := getArea()	 
   local oModel      := FWModelActive()
   local oModelEK9   := oModel:GetModel("EK9MASTER")
   local oModelEKA   := oModel:GetModel("EKADETAIL")
   local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   local nI	         := 1
   local nPos        := 0
   local lExistPrd   := .F.
   local lMultiFil   := isMultFil()

   if oModelEKA:Length() > 0 .And. !Empty(oModelEK9:GetValue("EK9_PRDREF"))

      for nI := 1 to oModelEKA:Length()
         oModelEKA:GoLine( nI )
         if oModelEKA:GetValue("EKA_PRDREF") == oModelEK9:GetValue("EK9_PRDREF")	.and. ;
            if( lMultiFil, oModelEKA:GetValue("EKA_FILORI") == oModelEK9:GetValue("EK9_FILORI") , .T.)
            lExistPrd := .T.
            exit
         endif
         if( empty(oModelEKA:GetValue("EKA_PRDREF")), nPos := nI, nil )
      next nI
      
      if !lExistPrd
         if nPos > 0
            oModelEKA:GoLine( nPos )
            oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
         else
            if oModelEKA:Length() < oModelEKA:AddLine()
               oModelEKA:SetValue("EKA_PRDREF", oModelEK9:GetValue("EK9_PRDREF"))
               ClearPrEKA(oModelEK9,oModelEKA)
            endif   
         endif		
      elseif oModelEKA:IsDeleted()
         oModelEKA:UnDeleteLine()		
      endif
      oModelEKA:GoLine(1)	//posiciona na linha 1

   endif

   RestArea(aArea)

Return cRet

/*
Função     : ClearPrEKA(model)
Objetivo   : Excluir as linhas que tenham o produto com ncm diferente do ncm da capa(EK9)
Parâmetros : 
Retorno    : Retorno .t.
Autor      : Maurício Frison
Data       : Abr/2020
Revisão    :
*/
static function ClearPrEKA(oModelEK9,oModelEKA)
   local oView       := nil
   local nI          := 0
   local aArrayProd	:= {}
   local lMultiFil   := .F.
   local cProdRef    := ""
   local cFilRef     := ""

   if oModelEKA:GetOperation() == MODEL_OPERATION_INSERT
      oView := FWViewActive()
      lMultiFil := isMultFil()
      aArrayProd := LoadPrdEKA(oModelEKA)
      if len(aArrayProd) > 0
         oModelEKA:ClearData(.T.,.F.)
         cProdRef := oModelEK9:GetValue("EK9_PRDREF")
         cFilRef := if( lMultiFil, oModelEK9:GetValue("EK9_FILORI"), xFilial("SB1"))
         for nI := 1 to len(aArrayProd)
            if (!empty(cProdRef) .and. cProdRef == aArrayProd[ni][1] .and. cFilRef == aArrayProd[ni][2] ) .or. ;
               (VldReg(aArrayProd[ni][1], aArrayProd[ni][2], "SB1", .F.) .and. alltrim(oModelEK9:GetValue("EK9_NCM")) == alltrim(SB1->B1_POSIPI))
               oModelEKA:AddLine()
               oModelEKA:LoadValue("EKA_PRDREF", aArrayProd[ni][1])
               if( lMultiFil, oModelEKA:LoadValue("EKA_FILORI", aArrayProd[ni][2]), nil )
               oModelEKA:LoadValue("EKA_DESC_I", POSICIONE("SB1",1, aArrayProd[ni][2] + aArrayProd[ni][1],"B1_DESC"))
            endif
         next
         if( oModelEKA:Length() == 0, oModelEKA:AddLine(), nil )
         oModelEKA:GoLine(1)
         if( !isExecAuto(oView), oView:Refresh("EKADETAIL"), nil )
      endif
   endif

return .T.


/*
Função     : CP400Valid()
Objetivo   : Validar dados digitados nos campos EK9 e EKA
Parâmetros : cCampo - campo a ser validado
Retorno    : lRet - Retorno se foi validado ou nao
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400Valid(cCampo,lUndelete)
   Local oModel      := FWModelActive()
   Local oModelEK9   := oModel:GetModel("EK9MASTER")
   Local oModelEKA   := oModel:GetModel("EKADETAIL")
   Local oModelEKB   := oModel:GetModel("EKBDETAIL")
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   Local lRet        := .T.
   Local cCodFab     := ""
   local lAutoExec   := isExecAuto()
   local lMultiFil   := isMultFil()
   local cFil        := ""
   local mDesc       := ""
   local cFilOrig    := ""

   Default lUndelete    := .F.

   Do Case
      Case cCampo == "EK9_PRDREF" .OR. cCampo == "EK9_FILORI" .or. ;
           cCampo == "EKA_PRDREF" .OR. cCampo == "EKA_FILORI"

         if cCampo == "EK9_PRDREF" .And. Empty(oModelEK9:GetValue("EK9_CNPJ"))
            lRet:=.F.
            EasyHelp(STR0104,STR0002,STR0103) // "Campo CNPJ Raiz não informado" ### "Atenção" ### "Informe primeiro o campo CNPJ Raiz"
         endif

         if lRet .and. ((cCampo == "EK9_FILORI" .and. !empty(cFilOrig := oModelEK9:GetValue("EK9_FILORI"))) .or. ;
                        (cCampo == "EKA_FILORI" .and. !empty(cFilOrig := oModelEKA:GetValue("EKA_FILORI"))))
            lRet := ExistCpo("SM0", FWCodEmp() + cFilOrig)
         endif
         
         if lRet
            if cCampo == "EK9_PRDREF" .or. cCampo == "EK9_FILORI"
               cProd := oModelEK9:GetValue("EK9_PRDREF")
               cFil := if( lMultiFil, nil, xFilial("SB1")) 
               if cCampo == "EK9_FILORI"
                  cFil := oModelEK9:GetValue("EK9_FILORI")
               endif
            elseif cCampo == "EKA_PRDREF" .or. cCampo == "EKA_FILORI"
               cProd := oModelEKA:GetValue("EKA_PRDREF")
               cFil := if( lMultiFil, if(!empty(oModelEKA:GetValue("EKA_FILORI")), oModelEKA:GetValue("EKA_FILORI"), if(!empty(oModelEK9:GetValue("EK9_FILORI")), oModelEK9:GetValue("EK9_FILORI"), nil)) , xFilial("SB1")) 
               if cCampo == "EKA_FILORI"
                  cFil := oModelEKA:GetValue("EKA_FILORI")
               endif
            endif
            lRet := VldReg(cProd, cFil, "SB1")
         endif

         if lRet .and. ( cCampo == "EKA_PRDREF" .or. cCampo == "EK9_PRDREF" ) .and. !empty(oModelEK9:GetValue("EK9_NCM")) .and. ;
            !(alltrim(oModelEK9:GetValue("EK9_NCM")) == alltrim(SB1->B1_POSIPI))

            if ( oModel:GetOperation() == MODEL_OPERATION_UPDATE .or. (oModel:GetOperation() == MODEL_OPERATION_INSERT .and. oModelEKA:Length(!lUndelete) > 1) )
               lRet := .F.
               easyhelp(STR0242 , STR0002,; // "O produto informado não pode ser utilizado para esse catalogo de produto." ### "Atenção"
                        STR0243 + " (" + alltrim(oModelEK9:GetValue("EK9_NCM")) + ").") // "Informe um produto onde sua NCM seja igual à NCM já informado no catalogo"
            else

               if cCampo == "EK9_PRDREF" .And. !lAutoExec
                  lRet := MsgNoYes(STR0240 + ENTER + ENTER + ; // "A NCM do produto informado é diferente da NCM do catalogo de produto. Deseja prosseguir?"
                                   STR0241,; // "Caso prossiga, as informações dos atributos serão perdidas e também será retirado o produto de Relação de Produtos. Os países de origem e fabricantes serão mantidos para serem avaliados se farão parte do catalogo de produto."
                                   STR0002) // "Atenção"
               endif

               if lRet
                  oModelEK9:LoadValue("EK9_NCM", SB1->B1_POSIPI)
                  CP400ATRIB(.F.)
               else
                  EasyHelp(STR0244,STR0002)// "Foi cancelado a atualização dos dados para o novo produto de referência informado." ### "Atenção"                          
               endif

            endif

         endif

         if lRet
            if cCampo == "EK9_PRDREF" .and. !empty(oModelEK9:GetValue("EK9_PRDREF"))
               mDesc := MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3))
               if !empty(mDesc)
                  oModelEK9:LoadValue("EK9_DSCCOM",mDesc)
               endif
            endif
         endif

      Case cCampo == "EKB_LOJA" .or. cCampo == "EKB_FILORI" .or. cCampo == "EKB_CODFAB"

         if cCampo == "EKB_CODFAB"
            if !empty(oModelEKB:GetValue("EKB_CODFAB")) .and. empty(oModelEK9:GetValue("EK9_CNPJ"))
               lRet := .F.
               EasyHelp(STR0104,STR0002,STR0103) //Campo CNPJ não informado. Informe primeiro o campo CNPJ Raiz
            endif
         elseif cCampo == "EKB_LOJA" .or. cCampo == "EKB_FILORI"
            if empty(oModelEKB:GetValue("EKB_CODFAB")) .and. !empty(oModelEKB:GetValue(cCampo))
               Help("",1,"CP400LOJA") //Problema: Código do Fabricante não está preenchido. Solução: Preencha o Cód. do Fabricante
               lRet := .F.
            endif
         endif

         if lRet .and. !empty(oModelEKB:GetValue("EKB_CODFAB"))
            cCodFab := oModelEKB:GetValue("EKB_CODFAB") + if( !empty(oModelEKB:GetValue("EKB_LOJA")), oModelEKB:GetValue("EKB_LOJA"), "")
            lRet := VldReg(cCodFab, if( !lMultiFil,;
                                       xFilial("SA2"),;
                                       nil), "SA2")

            if lRet
               if empty(SA2->A2_PAIS)
                  EasyHelp(STR0087, STR0002, STR0088) //Problema: "O código do País de origem não foi preenchido no Cadastro de Fabricantes/Forn." Solução: "Acesse o Cadastro do Fabricantes/Forn. e preencha o código do País de origem do Fabricante na aba 'Cadastrais' "
                  lRet := .F.
               else
                  if empty(Posicione("SYA", 1, xFilial("SYA") + SA2->A2_PAIS, "YA_PAISDUE"))
                     EasyHelp( StrTran( STR0174, "XXX", alltrim(AvSX3("YA_PAISDUE",AV_TITULO))), STR0002, ;
                              StrTran( STR0175, "XXXX", alltrim(SA2->A2_PAIS)))  // "O campo 'XXX' não está preenchido no cadastro de paises." #### "Verifique o cadastro do código do pais 'XXXX' em Atualizações -> Tabelas -> Paises"
                     lRet := .F.
                  endif
               endif
            endif

            if lRet
               if EKJ->(dbsetorder(1), msseek(xFilial("EKJ") + oModelEK9:getvalue("EK9_CNPJ") + SA2->A2_COD + SA2->A2_LOJA )) .and. EKJ->EKJ_MSBLQL == '1'
                  Help(" ",1,"CP400OPBLQ") //"Registro do operador estrangeiro encontra-se bloqueado. Para utilizá-lo efetue o desbloqueio do registro no Cadastro do Op. Estrangeiro"##"Atenção"
                  lRet := .F.
               endif
            endif
         endif

      Case cCampo == "EK9_UNIEST" 
         lRet := Vazio() .OR. ExistCpo("SAH",oModelEK9:GetValue("EK9_UNIEST"))
         If !lRet
            EasyHelp(StrTran(STR0022, "#####", oModelEK9:GetValue("EK9_UNIEST")),STR0002,STR0105) //"Unidade de Medida: ##### da NCM não encontrada no cadastro de unidade de medida"##"Atenção" Solução: "Revise o cadastro da NCM ou cadastre a unidade de medida"
         Endif

      Case cCampo == "EK9_NCM"

         lRet := Vazio() .or. ExistCpo("SYD",oModelEK9:GetValue("EK9_NCM")) 
         cNcmEK9 := if(isMemVar("cNcmEK9"), cNcmEK9, "")

         if lRet .and. !empty(oModelEK9:GetValue("EK9_NCM")) .and. !(alltrim(oModelEK9:GetValue("EK9_NCM")) == alltrim(cNcmEK9)) .and. ;
            ( (oModelEKC:Length() > 0  .and. !empty(oModelEKC:GetValue("EKC_CODATR"))) .or. ( isMemVar("oJsonAtt") .and. oJsonAtt:hasProperty("listaAtributos") .and. len(oJsonAtt['listaAtributos']) > 0) ) 
            if lAutoExec .or. (lRet := MsgNoYes(STR0247 + ENTER + ENTER + ; // "Deseja alterar a NCM?"
                                                STR0248,; // "Caso prossiga, as informações dos atributos serão perdidas."
                                                STR0002)) // "Atenção"
               ClearPrEKA(oModelEK9,oModelEKA)
            endif

            if !lRet
               EasyHelp(STR0246, STR0002) // "Foi cancelado a atualização dos dados para a nova NCM informado." ### "Atenção"
            endif

         endif

      Case cCampo == "EK9_IDMANU"

         If !FwIsInCallStack("EECCP400") .and. !Empty(oModelEK9:getvalue("EK9_IDPORT"))
            //EasyHelp(STR0079,STR0002) //"Não é possível digitar ID Manual já que o ID Portal já está preenchido"
            Help(" ",1,"CP400IDMAN")   //"Não é possível digitar ID Manual já que o ID Portal já está preenchido"         
            lRet := .F.
         EndIf

         If lRet .and. !Empty(oModelEK9:getvalue("EK9_VSMANU")) .And. AvExisteInd({{"EKD","3"}}) .And. ExistCpo("EKD",oModelEK9:getvalue("EK9_COD_I") + oModelEK9:getvalue("EK9_IDPORT") + oModelEK9:getvalue("EK9_VSMANU"),3,,.F.)
            EasyHelp(STR0157,STR0002,STR0158) // "Versão informada já existe no Histórico de Integração do Catálogo de Produtos." "###"Atenção"###"Informe uma versão que ainda não possua cadastro no Histórico de Integração."
            lRet := .F.
         EndIf 

      Case cCampo == "EK9_VSMANU"
         If !Empty(oModelEK9:getvalue("EK9_VSMANU")) .And. AvExisteInd({{"EKD","3"}}) .And. ExistCpo("EKD",oModelEK9:getvalue("EK9_COD_I") + oModelEK9:getvalue("EK9_IDPORT") + oModelEK9:getvalue("EK9_VSMANU"),3,,.F.)
            EasyHelp(STR0157,STR0002,STR0158) // "Versão informada já existe no Histórico de Integração do Catálogo de Produtos." "###"Atenção"###"Informe uma versão que ainda não possua cadastro no Histórico de Integração."
            lRet := .F.
         EndIf 

      Case cCampo == "EK9_DSCCOM"
         If len(oModelEK9:getvalue("EK9_DSCCOM")) > 3700
            EasyHelp(STR0096,STR0002) //"O campo de descrição complementar não pode ter mais de 3700 caracteres!"  "###"Atenção"
            lRet := .F.
         EndIf

      Case cCampo == "EKB_PAIS"  
         lRet := Vazio() .or. ExistCpo("ELO",oModelEKB:getvalue("EKB_PAIS"))
         If !lRet
            EasyHelp(STR0173, STR0002) // "Código do país conforme ISO-3166 invalido." ### "Atenção"
         EndIf

      Case cCampo == "EK9_STATUS"
         lRet := Pertence("123456") //"1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Bloqueado;5=Registrado Manualmente;6=Registrado (Pendente: Fabricante/País)"
      
      Case cCampo == "EKD_STATUS"
         lRet := Pertence("123456") //"1=Registrado;2=Pendente Registro;3=Obsoleto;4=Falha de integração;5=Registrado(pendente: fabricante/ país);6=Registrado Manualmente"

      case cCampo == "EK9_COD_I" .or. cCampo == 'EK9_FILIAL'
         lRet := ExistChav("EK9")
      
      Case cCampo == "EK9_PERATR"
         lRet := pertence("12")
         If lRet .And. canUseApp() .And. !lAutoExec
            setAtEdit(PermAlt(oModelEK9, .T.))//Deixa os atributos editáveis ou não editáveis, conforme o campo EK9_PERATR
         EndIf

   EndCase	
   lRetAux := lRet

Return lRet

/*
Função     : VldReg()
Objetivo   : Pesquisa filial para o produto digitado - quando nao via F3(consulta padrão/especifica)
Parâmetros : cCampo - Produto a ser pesquisado
             cTable - Tabela EKA - uso escpecifico para posicionar no produto SB1 para a filial encontrada
Retorno    : lRet - retorna se achou filial para o produto digitado
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
static function VldReg(cPesq, cFil, cTable, lHelpMsg)
   local aFilReg    := {}
   local lRet       := .F.
   local cFilF3     := ""
   local cFilOrig   := ""

   default lHelpMsg   := .T.

   if cFil == nil .or. (empty(cFil) .and. isMultFil())
      if cTable == "SB1"
         cFilF3 := xFilial("SB1")
         if isMemVar("cFilSB1F3") .and. !empty(cFilSB1F3)
            cFilF3 := cFilSB1F3
            cFilSB1F3 := ""
         endif
      else
         cFilF3 := xFilial("SA2")
         if isMemVar("cFilSA2F3")
            if !empty(cFilSA2F3)
               cFilF3 := cFilSA2F3
               cFilSA2F3 := ""
            elseif isMultFil() // pega a filial do produto, pois senão carrega a filial logada, caso o produto foi selecionado de outra filial, carrega os fabricantes da mesma filial do produto
               cFilOrig := getFilOrig()
               cFilF3 := if( !empty(cFilOrig), cFilOrig, cFilF3)
            endif
         endif
      endif
      aAdd(aFilReg, cFilF3 )
      getFilUser(@aFilReg)
   else
      aAdd(aFilReg, cFil )
   endif

   If cTable == "SB1"
      if( SB1->(indexOrd()) <> 1, SB1->(DbSetOrder(1)), nil ) //Filial + Produto
      lRet := aScan(aFilReg,{|X| SB1->(dbSeek(X+cPesq)) }) > 0
   Else
      if( SA2->(indexOrd()) <> 1, SA2->(DbSetOrder(1)), nil ) //Filial + Cod + Loja
      lRet := aScan(aFilReg,{|X| SA2->(dbSeek(X+cPesq)) }) > 0
   EndIf

   if lRet
      lRet := RegistroOk(cTable, lHelpMsg)
   else
      if lHelpMsg
         Help(" ",1,"REGNOIS")
      endif
   endif

Return lRet

/*/{Protheus.doc} getFilOrig
   Retorna o campo da filial de origem do produto

   @type  Static Function
   @author user
   @since 10/10/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFilOrig()
   local oMdlActive := nil
   local oModelEK9  := nil
   local cFilOrig   := ""

   oMdlActive := FwModelActivate()
   oModelEK9 := oMdlActive:GetModel("EK9MASTER")
   cFilOrig := oModelEK9:GetValue("EK9_FILORI")

return cFilOrig

/*
Função     : CP400IniBrw()
Objetivo   : Inicializa Browse - conteudo exibido no browse para campo passado por parametro
Parâmetros : cCampo - Campo a a ser inicializado no browse
Retorno    : cRet - Conteudo a ser inicializado no browse
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
Function CP400IniBrw(cCampo)
   Local cRet	:= ""
   Local aArea	:= GetArea()

   If  cCampo == "EK9_DESC_I"
      If isMultFil()
         cRet := POSICIONE("SB1",1,EK9->EK9_FILORI+EK9->EK9_PRDREF,"B1_DESC")
      Else
         cRet := POSICIONE("SB1",1,xFILIAL("SB1")+EK9->EK9_PRDREF,"B1_DESC")
      EndIf
   EndIf

   RestArea(aArea)

Return cRet

/*
Função     : CP400Gatil(cCampo)
Objetivo   : Regras de gatilho para diversos campos
Parâmetros : cCampo - campo cujo conteudo deve ser gatilhado
Retorno    : .T.
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :  
*/
Function CP400Gatil(cCampo)
   local aArea		   := GetArea()
   local oModel	   := FWModelActive()
   local oGridEKB    := oModel:GetModel("EKBDETAIL")
   local oModelEK9   := oModel:GetModel("EK9MASTER")
   local cRet        := ""
   local lMultiFil   := isMultFil()
   local cChaveSA2   := ""
   local cChaveEKJ   := ""

   Do Case
      Case cCampo == "EKB_NOME"
         cChaveSA2 := if( lMultiFil, oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline()), xFilial("SA2")) + oGridEKB:getvalue("EKB_CODFAB",oGridEKB:getline())+oGridEKB:getvalue("EKB_LOJA",oGridEKB:getline())
         SA2->(dbsetorder(1))
         if SA2->(msSeek(cChaveSA2))
            cRet := SA2->A2_NOME
         endif

      Case cCampo $ "EKB_OENOME|EKB_OEEND|EKB_OESTAT|EKB_OPERFB"

         cChaveSA2 := if( lMultiFil, oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline()), xFilial("SA2")) + oGridEKB:getvalue("EKB_CODFAB", oGridEKB:getline()) + oGridEKB:getvalue("EKB_LOJA", oGridEKB:getline())
         SA2->(dbsetorder(1))
         if SA2->(msSeek(cChaveSA2))
            cChaveEKJ := xFilial("EKJ") + oModelEK9:getvalue("EK9_CNPJ") + SA2->A2_COD + SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            if EKJ->(msSeek(cChaveEKJ)) .or. ;
               EKJ->(msSeek(xFilial("EKJ") + AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R") + SA2->A2_COD + SA2->A2_LOJA))
               if cCampo == "EKB_OENOME"
                  cRet := EKJ->EKJ_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(EKJ->EKJ_LOGR) + "-" + alltrim(EKJ->EKJ_CIDA) + "-" + alltrim(EKJ->EKJ_SUBP) + "-" + alltrim(EKJ->EKJ_PAIS) + "-" + alltrim(EKJ->EKJ_POSTAL)
               elseif cCampo == "EKB_OESTAT"
                  cRet := EKJ->EKJ_STATUS
               elseif cCampo == "EKB_OPERFB"
                  cRet := EKJ->EKJ_TIN 
               endif
            elseif SA2->(msSeek(cChaveSA2)) //ta desposicionando na SA2 ao fazer o Seek da EKJ
               if cCampo == "EKB_OENOME"
                  cRet := SA2->A2_NOME
               elseif cCampo == "EKB_OEEND"
                  cRet := alltrim(SA2->A2_END) + "-" + alltrim(SA2->A2_MUN) + "-" + alltrim(SA2->A2_PAISSUB) + "-" + alltrim(SA2->A2_PAIS) + "-" + alltrim(SA2->A2_POSEX)
               elseif cCampo == "EKB_OESTAT"
                  cRet := "2"
               endif
            endif
         endif

      Case cCampo $ "EKB_LOJA"
         if IsInCallStack("F3GET") .Or. VldReg(oGridEKB:GetValue("EKB_CODFAB"), if( lMultiFil, if(!empty(oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline())),oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline()),nil), xFilial("SA2")), "SA2", .F.)
            cRet := SA2->A2_LOJA
         endif
         
      Case cCampo == "EKB_PAIS"   
         cChaveSA2 := if( lMultiFil, oGridEKB:getvalue("EKB_FILORI",oGridEKB:getline()), xFilial("SA2")) + oGridEKB:getvalue("EKB_CODFAB", oGridEKB:getline()) + oGridEKB:getvalue("EKB_LOJA", oGridEKB:getline())
         SA2->(dbsetorder(1))
         if SA2->(msSeek(cChaveSA2))
            if !empty(SA2->A2_PAIS)
               cRet := POSICIONE("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_PAISDUE")
            endif 

            cChaveEKJ := xFilial("EKJ") + oModelEK9:getvalue("EK9_CNPJ") + SA2->A2_COD + SA2->A2_LOJA
            EKJ->(dbsetorder(1))
            if EKJ->(msSeek(cChaveEKJ)) .or. ;
               EKJ->(msSeek(xFilial("EKJ") + AvKey(oModelEK9:getvalue("EK9_CNPJ"), "EKJ_CNPJ_R") + SA2->A2_COD + SA2->A2_LOJA))
               cRet := EKJ->EKJ_PAIS
            endif

         endif

      Case cCampo == "EKB_PAISDS"   
         if !empty(oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()))
            cRet := POSICIONE("ELO",1,xFilial("ELO")+oGridEKB:getvalue("EKB_PAIS",oGridEKB:getline()),"ELO_DESC")
         endif
       
   EndCase

   RestArea(aArea)

Return cRet

/*
Função     : CP400Condc(cCampo)
Objetivo   : Regras de condicao para gatilho ser executo para diversos campos
Parâmetros : cCampo - campo cujo condicao de execução do gatilho deve ser verificada
Retorno    : lRet
Autor      : Ramon Prado
Data       : Jan/2020
Revisão    :
*/
Function CP400Condc(cCampo)
   Local lRet := .F.

   Do Case
      Case cCampo == "EKA_PRDREF" .or. cCampo == "EK9_PRDREF"
         lRet := isMultFil() .And. !EMPTY(FWFLDGET(cCampo))
      Case cCampo == "EKB_LOJA"
         lRet := isMultFil() .And. !EMPTY(FWFLDGET("EKB_LOJA"))
   EndCase

Return lRet

/*
Função     : LoadPrdEKA()
Objetivo   : Carrega Array de Produtos digitados no grid Relação de Produtos
Parâmetros : Nil
Retorno    : Array de Produtos
Autor      : Ramon Prado
Data       : dez/2019
Revisão    :
*/
static function LoadPrdEKA(oModelPrd)
   local aArea       := GetArea()
   local aArrayProd  := {}
   local nI          := 1
   local nTotPrd     := oModelPrd:Length()
   local cFilSB1     := xFilial("SB1")

   for nI := 1 to nTotPrd
      oModelPrd:GoLine(nI)
      if !Empty(oModelPrd:GetValue("EKA_PRDREF"))
         aAdd(aArrayProd, {oModelPrd:GetValue("EKA_PRDREF"), if(isMultFil(), oModelPrd:GetValue("EKA_FILORI"), cFilSB1)})
      endif
   next nI

   RestArea(aArea)

Return aArrayProd

/*
Função     : CP400CarFb()
Objetivo   : Pesquisa Amarracao Produto XFornecedor Ou Produto X Fabricante e carrega a lista no grid de fabricantes conforme produto digitado
Parâmetros : Nil
Retorno    : Nil
Autor      : Ramon Prado
Data       : Abr/2021
Revisão    :
*/
Function CP400CarFb()
   Local aArea := getArea()
   Local oModel      := FWModelActive()
   Local oModelEK9	:= oModel:GetModel("EK9MASTER")
   Local oModelEKB	:= oModel:GetModel("EKBDETAIL")
   Local cFilSA5     := ""
   Local lMsgYesNo   := .T.
   Local cRet        := oModelEK9:GetValue("EK9_PRDREF")
   Local cPais,cBlq
   local lAutoExec   := .F.
   local aAreaSA2    := {}
   local aAreaEKJ    := {}
   local lMultiSA2   := FWModeAccess("EK9",3) == "C" .and. FWModeAccess("SA2",3) == "E"
   local aSeek       := {}

   cPrdRefEK9 := if( isMemVar("cPrdRefEK9"), cPrdRefEK9, "")
   cFilRefEK9 := if( isMemVar("cFilRefEK9"), cFilRefEK9, "")
   If !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. (!(cPrdRefEK9 == oModelEK9:GetValue("EK9_PRDREF")) .or. if(isMultFil(), !(cFilRefEK9 == oModelEK9:GetValue("EK9_FILORI")) , .F.) ) .And. oModel:GetOperation() != EXCLUIR 
      
      cPrdRefEK9 := oModelEK9:GetValue("EK9_PRDREF")
      if(isMultFil(), cFilRefEK9 := oModelEK9:GetValue("EK9_FILORI"), nil )

      /* //MFR 14/02/2022 OSSME-6592 Retirado para não apagar os fabricantes já existentes
      If oModel:GetOperation() == INCLUIR
         oModelEKB:DelAllline()     
         oModelEKB:ClearData(.T.,.T.)     
      EndIf 
      */
      
      cFilSA5 := xFilial("SA5")
      SA5->(DbSetOrder(2)) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
   
      //Cadastro de Produto x Fornecedor/Fabricante
      If SA5->(MsSeek(PADR(cFilSA5, AVSX3("A5_FILIAL",3)) + PADR(oModelEK9:GetValue("EK9_PRDREF"), AVSX3("A5_PRODUTO",3))))
         lAutoExec   := isExecAuto()
         If !lAutoExec //exibe a pergunta apenas para rotinas não automaticas, rotina automatica a variavel lMsgYesNo é "Sim"   
            lMsgYesNo := MsgYesNo(STR0238 + ENTER + ENTER + ; // "Deseja carregar a lista de Fabricantes/Fornecedores associados ao produto?" 
                                  STR0239,; // "Serão considerados apenas os cadastros que possuírem o país informado e no cadastro dos países esteja informado seu código no padrão ISO (3166-1 alfa-2)."
                                  STR0021) // "Aviso" 
         EndIf
         If lMsgYesno .and. !IsRest()

            aAreaSA2 := SA2->(getArea())
            SA2->(dbSetOrder(1))
            aAreaEKJ := EKJ->(getArea())
            EKJ->(dbSetOrder(1))

            While SA5->(!EOF()) .And. SA5->(A5_FILIAL+A5_PRODUTO) == cFilSA5+oModelEK9:GetValue("EK9_PRDREF")            

               // Carrega o fornecedor associado ao produto
               if !empty(SA5->A5_FORNECE)
                  aSeek := {{"EKB_CODFAB", SA5->A5_FORNECE},{"EKB_LOJA", SA5->A5_LOJA}}
                  lSeekSA2 := VldReg( SA5->A5_FORNECE+SA5->A5_LOJA , if( lMultiSA2, nil, xFilial("SA2")) , "SA2", .F.)
                  if( lMultiSA2, aAdd( aSeek, {"EKB_FILORI", SA2->A2_FILIAL} ), nil )

                  If lSeekSA2 .and. !empty(SA2->A2_PAIS) .and. !oModelEKB:SeekLine(aSeek)
                     cPais := POSICIONE("SYA",1,xFilial("SYA") + SA2->A2_PAIS, "YA_PAISDUE")
                     cBlq := if( EKJ->( dbSeek( xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA ) ), EKJ->EKJ_MSBLQL, " " ) 
                     If !Empty(cPais) .And. !(cBlq == "1")
                        if !(oModelEKB:length()==1 .AND. Empty(oModelEKB:GetValue("EKB_CODFAB"))) 
                           ForceAddLine(oModelEKB, .F./*Não permite bloquear grid para nova inserção de linhas*/) 
                        EndIf 
                        oModelEKB:SetValue("EKB_CODFAB", SA5->A5_FORNECE)
                        oModelEKB:SetValue("EKB_LOJA", SA5->A5_LOJA)
                     EndIf
                  Endif
               endif

               // Carrega o fabricante associado ao produto
               If !empty(SA5->A5_FABR)

                  aSeek := {{"EKB_CODFAB", SA5->A5_FABR},{"EKB_LOJA", SA5->A5_FALOJA}}
                  lSeekSA2 := VldReg( SA5->A5_FABR + SA5->A5_FALOJA , if( lMultiSA2, nil, xFilial("SA2")) , "SA2", .F.)
                  if( lMultiSA2, aAdd( aSeek, {"EKB_FILORI", SA2->A2_FILIAL} ), nil )

                  If lSeekSA2 .and. !oModelEKB:SeekLine(aSeek)
                     cPais := POSICIONE("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_PAISDUE")
                     cBlq := if( EKJ->( dbSeek( xFilial("EKJ")+oModelEK9:getvalue("EK9_CNPJ")+SA2->A2_COD+SA2->A2_LOJA ) ), EKJ->EKJ_MSBLQL, " " ) 
                     If !Empty(cPais) .And. !(cBlq == "1")
                        if !(oModelEKB:length()==1 .AND. Empty(oModelEKB:GetValue("EKB_CODFAB"))) 
                           ForceAddLine(oModelEKB, .F./*Não permite bloquear grid para nova inserção de linhas*/) 
                        EndIf 
                        oModelEKB:SetValue("EKB_CODFAB", SA5->A5_FABR)
                        oModelEKB:SetValue("EKB_LOJA", SA5->A5_FALOJA) 
                     EndIf
                  Endif
               endif
               SA5->(DbSkip())
            EndDo  

            restArea(aAreaSA2)
            restArea(aAreaEKJ)

            oModelEKB:GoLine(1) //posiciona na linha 1
         EndIf   
      EndIf

   Endif

   RestArea(aArea)
Return cRet

/*
Função     : CP400ATRIB() Gatilho EK9_NCM
Objetivo   : Monta o grid com os atributos de acordo como ncm(gatilho no ncm da EK9)
             
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400ATRIB(lEvento)
   local oModel      := FWModelActive()
   Local oView       := FWViewActive()
   local oModelEK9   := oModel:GetModel("EK9MASTER")
   local oModelEKC   := oModel:GetModel("EKCDETAIL")
   local nOperation  := oModel:GetOperation()
   local lIsRest     := .F.
   local lPermissao  := .F.
   local nTamCpoVlr  := 0
   local aCposGrd    := {}
   local nCpo        := 0
   local cCampos     := ""
   local cQuery      := ""
   local oQuery      := nil
   local cAliasQry   := ""
   local lCondic     := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local cCodCatalog := ""
   local cModalid    := ""
   local nAtrib      := 0
   local cCodAtrib   := ""
   local cForm       := ""
   local cNcmEKG     := ""
   local nRecEKG     := 0
   local cAtrPrinc   := ""
   local cMultVal    := ""
   local cOrdem      := ""
   local aAttCompos  := {} //Array para armazenar os atributos que possuirem a forma de preenchimento COMPOSTO
   local cValor      := ""
   local aValores    := {}
   local nValores    := 0
   local nRegEKC     := 0
   local lAtbPrcBlq  := .F.
   local nPosComp    := 0
   Local oMdlDtCP
   Local lAutoExec := isExecAuto()
   Default lEvento := .F.

   If canUseApp() .And. !lAutoExec
      If nOperation == MODEL_OPERATION_INSERT .And. !Empty(oModelEK9:GetValue("EK9_NCM"))
         oMdlDtCP := oView:GetModel():GetModel("EKCDETAIL")
         oView:GetModel():lModify := .T.
         oMdlDtCP:lUpdateLine := .T.
         loadAtPOUI(oModelEK9:GetValue("EK9_NCM"), oModelEK9:GetValue("EK9_MODALI"), nOperation)
         setAtEdit(PermAlt(oModelEK9, .T.))//Deixa os atributos editáveis ou não editáveis, conforme o campo EK9_PERATR
      ElseIf nOperation == MODEL_OPERATION_UPDATE
         oMdlDtCP := oView:GetModel():GetModel("EKCDETAIL")
         oView:GetModel():lModify := .T.
         oMdlDtCP:lUpdateLine := .T.
      EndIf

      If( nOperation == MODEL_OPERATION_UPDATE .And. !FwIsInCallStack("incCatProd") .And. !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. Empty(oModelEK9:GetValue("EK9_DESC_I")) .And. getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V",; //Como o campo EK9_DESC_I inicialmente era virtual, verifica se esta em branco e preenche
         oModelEK9:SetValue("EK9_DESC_I", Posicione("SB1", 1, if(isMultFil(),oModelEK9:GetValue("EK9_FILORI"),xFilial("SB1")) + oModelEK9:GetValue("EK9_PRDREF"), "B1_DESC")), nil)
      if !FwIsInCallStack("incCatProd") .and. nOperation != MODEL_OPERATION_DELETE
         cNcmEK9 := if(isMemVar("cNcmEK9"), cNcmEK9, "")
         cModalEK9 := if(isMemVar("cModalEK9"), cModalEK9, "")
         if PermAlt(oModelEK9, .T.) .and.!empty(oModelEK9:GetValue("EK9_NCM")) .and. ( !(alltrim(cNcmEK9) == alltrim(oModelEK9:GetValue("EK9_NCM"))) .or. cModalEK9 <> oModelEK9:GetValue("EK9_MODALI"))
            cNcmEK9 := oModelEK9:GetValue("EK9_NCM") 
            cModalEK9 := oModelEK9:GetValue("EK9_MODALI")
         endif
      endif
   Else
      If( nOperation == MODEL_OPERATION_UPDATE .And. !FwIsInCallStack("incCatProd") .And. !Empty(oModelEK9:GetValue("EK9_PRDREF")) .And. Empty(oModelEK9:GetValue("EK9_DESC_I")) .And. getSX3Cache("EK9_DESC_I","X3_CONTEXT") <> "V",; //Como o campo EK9_DESC_I inicialmente era virtual, verifica se esta em branco e preenche
         oModelEK9:SetValue("EK9_DESC_I", Posicione("SB1", 1, if(isMultFil(),oModelEK9:GetValue("EK9_FILORI"),xFilial("SB1")) + oModelEK9:GetValue("EK9_PRDREF"), "B1_DESC")), nil)

      cNcmEK9 := if(isMemVar("cNcmEK9"), cNcmEK9, "")
      cModalEK9 := if(isMemVar("cModalEK9"), cModalEK9, "")
      lIsRest := IsRest()
      lPermissao := PermAlt(oModelEK9, .T.)

      if !lIsRest .and. lPermissao .and. !FwIsInCallStack("incCatProd") .and. nOperation != MODEL_OPERATION_DELETE .and. !empty(oModelEK9:GetValue("EK9_NCM")) .and. ( !(alltrim(cNcmEK9) == alltrim(oModelEK9:GetValue("EK9_NCM"))) .or. cModalEK9 <> oModelEK9:GetValue("EK9_MODALI"))

         cNcmEK9 := oModelEK9:GetValue("EK9_NCM") 
         cModalEK9 := oModelEK9:GetValue("EK9_MODALI")
         nTamCpoVlr := getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")
         
         if nOperation != MODEL_OPERATION_VIEW
            oModelEKC:SetNoInsertLine(.F.)
         endif

         if nOperation == MODEL_OPERATION_INSERT
            oModelEKC:DelAllline()
            oModelEKC:ClearData(.T.,.T.)
         endif

         DbSelectArea("EKG")
         if EKG->(dbSeek( xFilial("EKG") + cNcmEK9 ))
      

            aCposGrd := FWSX3Util():GetAllFields("EKG", .F.)
            for nCpo := 1 to len(aCposGrd)
               cCampos += " " + aCposGrd[nCpo] + " ,"
            next
            cCampos := substr(cCampos , 1, len(cCampos)-1)

            cQuery := " SELECT "
            cQuery += " R_E_C_N_O_ REC_EKG, "
            cQuery += cCampos 
            cQuery += " FROM " + RetSqlName('EKG') + " EKG "
            cQuery += " WHERE EKG.D_E_L_E_T_ = ' ' "
            cQuery += " AND EKG.EKG_FILIAL = ? "
            cQuery += " AND EKG.EKG_NCM = ? "
            if nOperation == MODEL_OPERATION_INSERT
               cQuery += " AND EKG.EKG_MSBLQL <> '1' "
            endif
            cQuery += " ORDER BY " + if( lCondic , "EKG_CONDTE, EKG_COD_I", "EKG_COD_I" )

            oQuery := FWPreparedStatement():New(cQuery)
            oQuery:SetString(1,xFilial('EKG'))
            oQuery:SetString(2,cNcmEK9)
            cQuery := oQuery:GetFixQuery()

            cAliasQry := getNextAlias()
            MPSysOpenQuery(cQuery, cAliasQry)
            TcSetField(cAliasQry, "EKG_INIVIG", "D", 8, 0)
            TcSetField(cAliasQry, "EKG_FIMVIG", "D", 8, 0)

            _aAtributos := {} // variavel static

            cCodCatalog := oModelEK9:GetValue("EK9_COD_I")
            cModalid := oModelEK9:GetValue("EK9_MODALI")

            EKC->(dbSetOrder(1))

            (cAliasQry)->(dbGoTop())
            nAtrib := if(nOperation == MODEL_OPERATION_INSERT .or. ( oModelEKC:length() == 1 .and. empty(oModelEKC:getValue("EKC_CODATR"))), 0, oModelEKC:length())
            while (cAliasQry)->(!eof())
            
               // caso seja DUIMP, não carrega os atributos diferente de alteração
               if cModalid == "1" .and. !(nOperation == MODEL_OPERATION_UPDATE) .and. !("7" $ alltrim((cAliasQry)->EKG_CODOBJ))
                  (cAliasQry)->(dbSkip())
                  loop
               endif
               //Se a modalidade estiver preenchida e não for a mesma da modalidade do catalogo, nao exibe
               if !( empty((cAliasQry)->EKG_MODALI) .or. (cAliasQry)->EKG_MODALI == "3" .or. cModalid == (cAliasQry)->EKG_MODALI )
                  (cAliasQry)->(dbSkip())
                  loop
               endif

               nAtrib += 1
               cCodAtrib := (cAliasQry)->EKG_COD_I
               cForm := alltrim((cAliasQry)->EKG_FORMA)
               cNcmEKG := (cAliasQry)->EKG_NCM
               nRecEKG := (cAliasQry)->REC_EKG
               cAtrPrinc := ""
               cMultVal := ""
               cOrdem := ""
               lAtbPrcBlq := .F.
               nPosComp := 0

               if lCondic
                  cAtrPrinc := (cAliasQry)->EKG_CONDTE
                  cMultVal := (cAliasQry)->EKG_MULTVA
               endif

               if cForm == ATT_COMPOSTO //Forma de Preenchimento do tipo COMPOSTO
                  if aScan(aAttCompos,{|X| X[1] == cNcmEKG .And. X[2] == cCodAtrib}) == 0
                     aAdd(aAttCompos,{cNcmEKG, cCodAtrib, (cAliasQry)->EKG_MSBLQL == "1" })
                  endif
                  (cAliasQry)->(dbSkip())
                  loop
               endif
               // para atributos que não possuem condicionantes e que possuem atributos compostos
               if empty(cAtrPrinc) .or. (nPosComp := aScan(aAttCompos,{|X| X[1] == cNcmEKG .And. X[2] == cAtrPrinc})) > 0
                  lAtbPrcBlq := if( nPosComp > 0 , aAttCompos[nPosComp][3] , .F.)
                  cOrdem := cCodAtrib
               endif

               aAdd(_aAtributos, { cCodAtrib, cAtrPrinc, nRecEKG, cOrdem, (cAliasQry)->EKG_MSBLQL == "1"} )

               if !oModelEKC:SeekLine( if( lCondic, {{"EKC_COD_I", cCodCatalog} , {"EKC_CODATR", cCodAtrib } , {"EKC_CONDTE", cAtrPrinc }} , {{"EKC_COD_I" , cCodCatalog} , {"EKC_CODATR", cCodAtrib }} ), .T. )

                  // adiciona somente atributos que não possuem condicionates e que são subatributos dos atributos compostos
                  if (!lCondic .or. !empty(cOrdem)) .and. (cAliasQry)->EKG_MSBLQL <> '1' .and. ( (cModalid == "1" .and. "7" $ alltrim((cAliasQry)->EKG_CODOBJ)) .or. !(cModalid == "1") ) .and. CP400Status((cAliasQry)->EKG_INIVIG,(cAliasQry)->EKG_FIMVIG) != "EXPIRADO" .and. ( empty((cAliasQry)->EKG_MODALI) .or. (cAliasQry)->EKG_MODALI == "3" .or. cModalid == (cAliasQry)->EKG_MODALI ) 
                     if nOperation != MODEL_OPERATION_VIEW
                        AddLine(oModelEKC, , !(nAtrib == 1))
                     else
                        ForceAddLine(oModelEKC)
                     endif
                     loadInfAtr(oModelEKC, cAliasQry, lCondic, cCodCatalog, cOrdem )
                  endif

               else

                  if lCondic .and. !empty(cOrdem)
                     oModelEKC:LoadValue("ATRIB_ORDEM", cOrdem )
                  endif

                  // caso seja diferente de catalogo, deleta os atributos que já estão gravados
                  if (cModalid == "1" .and. !("7" $ alltrim((cAliasQry)->EKG_CODOBJ))) .or. (cAliasQry)->EKG_MSBLQL == "1" .or. lAtbPrcBlq
                     if (cAliasQry)->EKG_MSBLQL == "1" .or. lAtbPrcBlq
                        oModelEKC:LoadValue("EKC_STATUS" , STR0007) // "Bloqueado"
                     endif
                     if nOperation != MODEL_OPERATION_VIEW
                        oModelEKC:deleteLine()
                     endif
                  endif

               endif

               (cAliasQry)->(dbSkip())
            end
            (cAliasQry)->(dbCloseArea())
            oQuery:Destroy()

            if lCondic .and. !( nOperation == MODEL_OPERATION_INSERT )
               for nRegEKC := 1 to len(_aAtributos)
                  cCodAtrib := _aAtributos[nRegEKC][1]
                  cAtrPrinc := _aAtributos[nRegEKC][2]
                  lAtbPrcBlq := getAtrBlq(cAtrPrinc, nRegEKC)
                  loadCond(oModelEKC, nOperation, cNcmEKG, cCodCatalog, cModalid, cCodAtrib, cAtrPrinc, lAtbPrcBlq)
               next nRegEKC
            endif

            // Carrega os atributos que não estão na EKG, registro que vieram de integração
            for nRegEKC := 1 to oModelEKC:length()
               oModelEKC:goLine(nRegEKC)
               if empty(oModelEKC:GetValue("EKC_VLEXIB"))
                  if EKC->(dbSeek( xFilial("EKC") + cCodCatalog + oModelEKC:getValue("EKC_CODATR") + if( lCondic, oModelEKC:getValue("EKC_CONDTE"), "") )) .and. !empty(EKC->EKC_VALOR)   
                     oModelEKC:LoadValue("EKC_VLEXIB",SubSTR(EKC->EKC_VALOR,1,nTamCpoVlr))
                  endif
               endif
            next nRegEKC

            if lCondic .and. !( nOperation == MODEL_OPERATION_INSERT ) 
               OrdAtrib(oModelEKC)
            endif

            oModelEKC:GoLine(1) 

         endif

         if nOperation != MODEL_OPERATION_VIEW
            oModelEKC:SetNoInsertLine(.T.)
         endif

      elseif !lIsRest .and. !lPermissao .and. nOperation != MODEL_OPERATION_DELETE
         oModelEKC:GoLine(1)
         EKC->(dbSetOrder(1))
         nTamCpoVlr := getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")
      
         for nRegEKC := 1 to oModelEKC:length()
            oModelEKC:goLine(nRegEKC)
            if EKC->(dbSeek( xFilial("EKC") + oModelEK9:GetValue("EK9_COD_I") + oModelEKC:getValue("EKC_CODATR") + if( lCondic, oModelEKC:getValue("EKC_CONDTE"), "") ))
   
               aValores := if( lCondic, { EKC->EKC_VALOR }, strTokArr( alltrim( EKC->EKC_VALOR ), ";" ))

               cValor := ""
               for nValores := 1 to len(aValores)
                  if EKH->(dbSeek( xFilial("EKH") + PadR("", len( EKH->EKH_NCM) ) + EKC->EKC_CODATR + aValores[nValores])) .or. EKH->(dbSeek( xFilial("EKH") + oModelEK9:GetValue("EK9_NCM") + EKC->EKC_CODATR + aValores[nValores]))
                     cValor += alltrim(EKH->EKH_CODDOM) + " - " + alltrim(EKH->EKH_DESCRE) + " ;"
                  endif
               next nValores
               cValor := if( empty(cValor), EKC->EKC_VALOR, substr( cValor, 1, len(cValor)-1) )
               oModelEKC:LoadValue("EKC_VLEXIB",SubSTR(cValor,1,nTamCpoVlr))

            endif
         next nRegEKC
         oModelEKC:GoLine(1) 
      endif
   EndIf
return .T.

/*
Função     : ForceAddLine()
Objetivo   : Força adição de linha na tela de grid
Parâmetros : oModelGrid
Retorno    : .T.
Autor      : Maurício Frison
Data       : Mar/2020
*/
Static Function ForceAddLine(oModelGrid, lControlLn)
   Local oModel   := FWModelActive()
   Local lDel     := .F.

   Default lControlLn := .T.

      nOperation := oModel:GetOperation()
      If lControlLn
         oModelGrid:SetNoInsertLine(.F.)
      EndIf
      if nOperation == 1
         oModel:nOperation := 3
      EndIf

      If oModelGrid:Length() >= oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If !oModelGrid:IsDeleted()
            oModelGrid:DeleteLine()
            lDel := .T.
         EndIf
         oModelGrid:AddLine()
         oModelGrid:GoLine(1)
         If lDel
            oModelGrid:UnDeleteLine()
         EndIf
         oModelGrid:GoLine(oModelGrid:Length())
      EndIf

      If lControlLn
         oModelGrid:SetNoInsertLine(.T.)
         //oModelGrid:SetNoDeleteLine(.T.)
      EndIf   
      oModel:nOperation := nOperation

Return .T.

/*
Função     : CP400Status()
Objetivo   : Gera o status conforme data da vigência e data base            
Parâmetros : dDataVigencia
Retorno    : Status
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400Status(dIniVig,dFimVig)
   Local cReturn := ""

   If !Empty(dIniVig) .And. dIniVig > dDataBase
      cReturn := "FUTURO"
   ElseIf !Empty(dFimVig) .And. dFimVig < dDataBase 
      cReturn := "EXPIRADO"
   Else
      cReturn := "VIGENTE"
   Endif

Return cReturn
/*
Função     : CP400TELA() Gatilho campo EKC_CODATR
Objetivo   : Abrir uma tela diferente para cada tipo de dado de acordo com as tabelas EKG e EKH
Parâmetros : cCodAtr código do atributo
Retorno    : cTela - Retorna a informação selecionada pelo usuário
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400TELA()
   Local oModel    := FWModelActive()
   Local oModelEKC := nil
   Local oView     := nil
   Local lRetorno  := .F.
   local lCondic   := .F.
   local cCondte   := ""

   Private cTela := ""

   if valtype(oModel) == "O" .and. PermAlt(oModel:GetModel("EK9MASTER"), .T.)
      oModelEKC := oModel:GetModel("EKCDETAIL")
      if valtype(oModelEKC) == "O" .and. !(oModelEKC:getOperation() == 1)
         cAtr := oModelEKC:GetValue("EKC_CODATR")
         lCondic := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
         if lCondic
            cCondte := oModelEKC:GetValue("EKC_CONDTE")
         endif
         CP400CapaAtr(oModel:getModel("EK9MASTER"):getValue("EK9_NCM"),cAtr)

         oView := FWViewActive()
         if !isExecAuto(oView)
            oview:Refresh("EKCDETAIL")
         endif
         lRetorno := .T.
      EndIf
   endif

Return lREtorno

/*
Função     : getArrAtrb()
Objetivo   : Pegar a forma de preenchimento do atributo
Parâmetros : cAtributo o código do atributo, nCampo posição qeu define qual campo será retornado
Retorno    : valor - Retorna o campo de preenchimento do atributo
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
static function getArrAtrb(cAtributo, cCondte, lCondic)
   local nPos       := 0
   local nRecno     := 0

   default cCondte := ""
   default lCondic := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")

   nPos := if( !lCondic , aScan(_aAtributos, {|x| alltrim(x[1]) == alltrim(cAtributo)}), ascan(_aAtributos, {|x| alltrim(x[1]) == alltrim(cAtributo) .and. alltrim(x[2]) == alltrim(cCondte)  }))

   if nPos > 0
      nRecno := _aAtributos[nPos][3]
   EndIf

Return nRecno

/*
Função     : CP400CapaAtr()
Objetivo   : Exibir a tela de capa do atributo
Parâmetros : cForma - é a forma de preenchimento que veio da tabela ekg
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400CapaAtr(cNCM, cAtr)
   Local oModel      := FWModelActive()
   Local oModelEKC   := oModel:GetModel("EKCDETAIL")
   Local cPict       := ""
   Local cObrig      := ""
   Local cValor      := ""
   Local cTela       := ""
   Local nTam        := 0
   Local nDec        := 0
   Local nValor      := 0
   Local aLista      := {}
   //Local npos        := 1
   Local bOk		   := {|| lRet:= .T., CP400GravaAtr(oModelEKC,cTela,cValor,lCondic) , oDlg:End()}
   Local bCancel     := {|| lRet:= .F., CP400ViewAtr()  , oDlg:End()}
   Local aItems      := {'1-SIM','2-NAO'}
   Local lHtml       := .T.
   Local oPanelEnch
   Local oPanelAtr
   Local cTituloAtributos := STR0168 //"Edição de Atributos"
   Local cTextHtml   := ""
   Local cNotCampos  := ""
   local nCpo        := 0
   local aCposGrd    := {}
   Local aCposExib   := {}
   Local aSeek       := {}
   Local cCampo
   local lCondic     := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local cCondte     := ""
   local cConfigCSS  := ""
   local cTipoSmart  := ""
   local nTipo       := 0
   local lViaHtml    := .F. // .F. - Via SmartCliente .T. - Via Html
   local nPosAtrb    := 0
   local aValores    := {}
   local cForma      := ""

   Private oBrowse
   Private aRotina  := menudef()
   Private cLabelGrid := ""
   Private cTelaView  := "" 

   nTipo := GetRemoteType(@cTipoSmart)
   lViaHtml := if( (valtype(nTipo) == "N" .and. nTipo == 5) .or. 'HTML' $ alltrim(upper(cTipoSmart)), .T. , .F.)
  
   nLinIni := DLG_LIN_INI+100
   nColIni := DLG_COL_INI+100
   nLinFim := DLG_LIN_FIM
   nColFim := DLG_COL_FIM

   begin sequence

   If !Empty(cAtr)
      if lCondic
         cCondte := oModelEKC:getValue("EKC_CONDTE")
      endif

      nRecEKG := getArrAtrb(cAtr, cCondte, lCondic)
      if nRecEKG == 0
         EasyHelp(STR0212 + " - " + cAtr, STR0067, STR0213 ) // "Atributo não encontrado" #### "Atenção" #### "Verifique o cadastro de atributos"
         break
      endif

      EKG->(dbGoTo(nRecEKG))
      cForma := alltrim(EKG->EKG_FORMA)
      If EKG->EKG_MSBLQL == "1" //Registro Bloqueado
         Help(" ",1,"REGBLOQ",,"EKG - " + Alltrim(FWX2Nome("EKG")),2,5)
      Else
         RegToMemory("EKG", .F.)
         
         cNotCampos += "EKG_CODOBJ/EKG_FORMA/EKG_TAMAXI/EKG_DECATR/EKG_BRIDAT" //Campos que não serão exibidos na tela da edição de atributos - OSSME-5342 - RNLP
         
         //Adicionando os campos a serem apresentados na Enchoice 
         aCposGrd := FWSX3Util():GetAllFields("EKG", .T.)
         for nCpo := 1 to len(aCposGrd)
            If !(alltrim(aCposGrd[nCpo]) $ cNotCampos) .And. X3Uso(SX3->X3_USADO)
               aAdd(aCposExib,aCposGrd[nCpo])
            endif
         next

         DEFINE MSDIALOG oDlg TITLE cTituloAtributos FROM nLinIni,nColIni TO nLinFim,nColFim OF oMainWnd PIXEL

            // Panel para a enchoice
            nWidth            := PosDlg(oDlg)[4]
            nHeight           := round(PosDlg(oDlg)[3] * 0.6,0)
            oPanelEnch        := TPanel():New(0,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight)
            oPanelEnch:Align  := CONTROL_ALIGN_TOP

            // enchoice
            oEnCh             := MsMGet():New("EKG", ,2, , , , aCposExib,PosDlg(oPanelEnch),{},,,,,oPanelEnch,.T.)
            oEnch:oBox:Align  := CONTROL_ALIGN_TOP //CONTROL_ALIGN_ALLCLIENT
            cObrig            := EKG->EKG_OBRIGA
            cTela             := oModelEKC:GetValue("EKC_VALOR")
            cValor            := oModelEKC:GetValue("EKC_VALOR")
            cTelaView         := oModelEKC:GetValue("EKC_VLEXIB")

            // Panel para a Say
            nLinIni           := round(PosDlg(oDlg)[3] * 0.6,0) - noround(PosDlg(oDlg)[3] * 0.05,0)
            nHeight           := round(PosDlg(oDlg)[3] * 0.06,0)
            oPanelSay         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,/* CLR_BLUE */,nWidth,nHeight)
            // oPanelSay:Align   := CONTROL_ALIGN_ALLCLIENT

            // TSay permitindo texto no formato HMTL
            nCol              := 5
            oSay              := TSay():New(01,nCol,{|| '' },oPanelSay,,,,,,.T.,CLR_BLACK,/* CLR_YELLOW */,nWidth,nHeight,,,,,,lHtml)
            oSay:Align        := CONTROL_ALIGN_ALLCLIENT
            oSay:SetTextAlign( 2, 2 )

            // Panel para o atributo
            nLinIni           += nHeight + 1
            nHeight           := PosDlg(oDlg)[3] * 0.4
            oPanelAtr         := TPanel():New(nLinIni,0,'',oDlg,,.F.,.T.,,,nWidth,nHeight,.T.,.T.)
            oPanelAtr:Align   := CONTROL_ALIGN_BOTTOM
            nRow              := 30

            // Atributo a ser incluído
            DO CASE

               CASE cForma == "LISTA_ESTATICA"

                  cTextHtml := STR0169//'Selecione na lista o valor do atributo'
                  bOk := {|| If(Len(aLista) > 0, getPosAtrib(oBrowse, aLista, @cTela, @cValor), ), CP400GravaAtr(oModelEKC,cTela,cValor, lCondic) , oDlg:End() }
                  aLista := getDominios( cNcm, cAtr )
                  //nPos := AScan(aLista, {|x| x[2] == cTela})
                  bDuploClick := {|oBrowse| duploClickAtributo(oBrowse, lCondic) }

                  if len(aLista) > 0 .and. !empty(cValor)
                     aValores := StrTokArr2(cValor,';')
                     for nValor := 1 to len(aValores)
                        nPosAtrb := aScan( aLista, { |X| alltrim(X[2]) == alltrim(aValores[nValor]) })
                        if nPosAtrb > 0
                           aLista[nPosAtrb][4] := "LBOK"
                        endif
                     next
                  endif

                  // Define o Browse
                  cCampo := alltrim(EKG->EKG_NOME)
                  AAdd(aSeek, {cCampo, {{"", "C", LEN(aLista[1][2]), 0, cCampo,,cCampo}},1,.T.})

                  oBrowse := FWBrowse():New(oPanelAtr)
                  oBrowse:SetProfileID("CP400FwBrw")
                  oBrowse:SetClrAlterRow(15000804)
                  oBrowse:setDataArray()
                  oBrowse:setArray( aLista )
                  oBrowse:SetSeek(,aSeek)
                  //oBrowse:disableConfig() //se deixar esta linha não funciona a automação e teve que incluir o SetSeek também para funcionar
                  oBrowse:disableReport()

                  oBrowse:AddMarkColumns({|oBrowse| iif( marcaAtributo(oBrowse) ,'LBOK','LBNO') },;
                                                   bDuploClick,;
                                                   {|oBrowse| headerClickAtributo(oBrowse) })

                  // Adiciona as colunas do Browse 
                  oColumn := FWBrwColumn():New()
                  oColumn:SetData(&('{ || aLista[oBrowse:At()][2] }'))
                  oColumn:ReadVar('aLista[oBrowse:At()][2]')
                  oColumn:SetTitle(AvSX3('EKH_COD_I')[5])
                  oColumn:SetSize(AvSX3('EKH_COD_I')[3])
                  oColumn:SetDoubleClick(bDuploClick)

                  oBrowse:SetColumns({oColumn})

                  oColumn := FWBrwColumn():New()
                  oColumn:SetData(&('{ || aLista[oBrowse:At()][3] }'))
                  oColumn:ReadVar('aLista[oBrowse:At()][3]')
                  oColumn:SetTitle( alltrim(EKG->EKG_NOME) )
                  oColumn:SetSize(100)
                  oColumn:SetDoubleClick(bDuploClick)

                  oBrowse:SetColumns({oColumn})

                  oBrowse:Activate()

               CASE cForma == "TEXTO"
                  cValor      := StrTran(cValor, ENTER, "<br>")
                  cTela       := StrTran(cTela, ENTER, "<br>")
                  cLabelGrid  := alltrim(EKG->EKG_NOME)
                  cLabelGrid  := substr(cLabelGrid, 1 , 1 ) + substr( lower(cLabelGrid), 2  ) 
                  cTextHtml   := cLabelGrid
                  nTam        := EKG->EKG_TAMAXI
                  bValid      := { || .T. } // {|u| CP400VlTexto(u,@cValor,nTam,@cTela)  }
                  bOk         := {|| if( CP400VlTexto(oMulti,@cValor,nTam,@cTela, lViaHtml), (CP400GravaAtr(oModelEKC, cTela, cValor, lCondic, lViaHtml , oMulti, nTam) , oDlg:End()), nil )}
                  cLabelAux   := STR0170 + " (" + AllTrim(str(nTam)) + ")" //'Caracteres'
                  nRow        := 5
                  nWidth      := PosDlg(oPanelAtr)[4] - 6
                  nHeight     := PosDlg(oPanelAtr)[3]
                  bSetGet     := {|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}
                  
                  oMulti      := TSimpleEditor():New(nRow,nCol,oPanelAtr,nWidth,nHeight,,.F.,bSetGet,,.T.,,bValid,cLabelAux,1)
                  oMulti:bGetKey  := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam, lViaHtml) }
                  oMulti:bChanged := {|self,oDlg| CP400Changed(self,@cTela,oPanelAtr,nTam) }
                  oMulti:load( if( lViaHtml, substr(cTela, 1, nTam), cTela))
                  oMulti:SetMaxTextLength( nTam )
                  oMulti:SetFocus()
                  // oMulti := TMultiget():New(nRow,nCol,{|u| iif(Pcount()>0, (cTela:=u, cValor:=cTela) ,cTela)}, ;
                  // oPanelAtr,nWidth,nHeight,,,,,,.T.,,,bValid,,,,bValid,,,.F.,.T. ,cLabelAux,1 )
                  // oMulti:bGetKey := {|self,cText,nkey,oDlg| CP400GetKey(self,cText,nkey,oPanelAtr,nTam) }
                  
               CASE cForma $ "NUMERO_REAL|NUMERO_INTEIRO"

                  //tela com número com picture correspondente
                  cTitle  := alltrim(EKG->EKG_NOME)
                  cTitle  := substr(cTitle, 1 , 1 ) + substr( lower(cTitle), 2  ) 
                  cTextHtml   := cTitle
                  nTam        := EKG->EKG_TAMAXI
                  nDec        := EKG->EKG_DECATR
                  cPict       := CP400GeraPic(nTam,nDec)
                  nValor      := getCtela(cTela,.f.)
                  nWidth      := 80
                  nHeight     := 20

                  oGetNum := TGet():New(nRow,nCol, { | u | If( PCount() == 0, nValor, (nValor := u, cTela := alltrim(Transform(nValor,cPict)),cValor:=cTela) ) },oPanelAtr, ;
                  nWidth,nHeight, cPict ,, 0, ,,.F.,,.T., ,.F., ,.F.,.F., ,.F.,.F. ,,"nValor",,,,.T.,.F., ,"",1 )
                  oGetNum:SetFocus()
               CASE cForma == "BOOLEANO"
                  
                  // Tela combox sim ou nao
                  cTitle  := alltrim(EKG->EKG_NOME)
                  cTitle  := substr(cTitle, 1 , 1 ) + substr( lower(cTitle), 2  ) 
                  cTextHtml   := cTitle
                  cCombo1     := if(cValor == "", aItems[2], if(cValor =="1", aItems[1], aItems[2]))
                  cTela       := right(cCombo1,3)
                  cValor      := left(cCombo1,1)
                  nWidth      := 80
                  nHeight     := 20

                  oCombo1  := TComboBox():New(nRow,nCol,{ |u| if(PCount()>0, cCombo1:=u , cCombo1) },;
                  aItems,nWidth,nHeight,oPanelAtr, , { || cTela:=right(cCombo1,3), cValor:=left(cCombo1,1) } ;
                  , , , ,.T., , , , , , , , , "cCombo1" , "",1)
                  oCombo1:SetFocus()
            EndCase
            oSay:SetText( alltrim(cTextHtml) )
            cConfigCSS := FWGetCSS( "TPANEL", 68) // "QLabel {color:white; border: 1px solid #CECECE; font-size:15px; background-color:#155c94}"
            oSay:setCSS(cConfigCSS)

         Activate MsDialog oDlg On Init (EnchoiceBar(oDlg, bOk, bCancel,,,,,,,.F.))	CENTERED
      EndIf
   EndIf

   end sequence

Return 

/*/{Protheus.doc} getPosAtrib
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
static function getPosAtrib(oBrowse, aLista, cTela, cValor)
   Local oData     := oBrowse:Data()
   Local aMarcados := {}
   Local nC        := 0

   default aLista := {}
   default cTela  := ""
   default cValor := ""

   cTela := ""
   cValor := ""
   aEval(oData:aArray, {|x| nC++, if( !empty(x[4]) .and. x[4] == 'LBOK' , ( aAdd( aMarcados, nC ), cValor += alltrim(aLista[nC][2]) + ";", cTela += allTrim(aLista[nC][2])+"-"+aLista[nC][3]+" ;" ), ) })

   if !empty(cValor)
      cValor := substr(cValor, 1, len(cValor)-1)
      cTela := substr(cTela, 1, len(cTela)-1)
   endif

Return aMarcados

/*/{Protheus.doc} marcaAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function marcaAtributo(oBrowse)
   Local lRet     := .F.
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   
   if len(oData:aArray) > 0
      if ! empty(oData:aArray[nPos][4]) .and. oData:aArray[nPos][4] == 'LBOK'
         lRet := .T.
      endif
   endif

Return lRet
/*/{Protheus.doc} duploClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function duploClickAtributo(oBrowse, lCondic)
   Local oData    := oBrowse:Data()
   Local nPos     := oBrowse:At()
   Local nCount   := 0

   default lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")

   if( lCondic .and. M->EKG_MULTVA == "1", oData:aArray[nPos][4] := if(oData:aArray[nPos][4] == 'LBOK', 'LBNO', 'LBOK'), aEval(oData:aArray, {|x| nCount++, x[4] := iif( nCount == nPos, if( X[4] == 'LBOK', 'LBNO', 'LBOK' ), 'LBNO' ) }) )
   oBrowse:Refresh(.T.)

Return
/*/{Protheus.doc} headerClickAtributo
   (long_description)
   @type  Static Function
   @author user
   @since date
   @version version
   @param param, param_type, param_descr
   @return return, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
Static Function headerClickAtributo(oBrowse)
   Local oData    := oBrowse:Data()

   aEval(oData:aArray, {|x| x[4] := 'LBNO' })
   oBrowse:Refresh(.T.)

Return

/*
Função   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o número de caracters disponíveis
Parâmetros : cValor: o valor digitado, nTam: o tamanho máximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho máximo e .F. se passar deste tamanho
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400Changed(objeto,cText,oDlg,nTam)
   
   if cText # nil
      objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len(cText))) + ")"
   endif

Return .T. 

/*
Função   : CP400GetKey(cValor,nTam)
Objetivo   : Exibir o número de caracters disponíveis
Parâmetros : cValor: o valor digitado, nTam: o tamanho máximo
Retorno    : .T. se o tamanho do campo digitado estiver dentro do tamanho máximo e .F. se passar deste tamanho
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400GetKey(objeto,cText,nKey,oDlg,nTam, lViaHtml)
   default lViaHtml    := .F.
   objeto:cTitle := cLabelGrid + " (" + allTrim(str(nTam-len( if( lViaHtml, TrataInf(objeto) ,cText )))) + ")"
Return .T. 

/*
Função   : CP400VlTexto(oObjeto,nTam)
Objetivo   : trata o tamanho do campo e pergunta se quer truncar
Parâmetros : objeto a trucar o texto, nTam: o tamanho máximo
Retorno    : lRet se truncou ou não o tamanho do objeto
Autor      : Maurício Frison
Data       : abr/2020
Revisão    :
*/
Function CP400VlTexto(oObjeto,cValor,nTam,cTela, lViaHtml)
   Local lRet := .T.

   default lViaHtml    := .F.
   
   cValor   := StrTran(cValor, "<br>", ENTER)
   cTela    := StrTran(cTela, "<br>", ENTER)
   
   if len( if( lViaHtml , TrataInf(oObjeto) , cValor) ) > nTam 
      lRet := MsgNoYes(STR0036) //Tamanho do campo excedido, as informações serão truncadas. Deseja prosseguir?
      if lRet
         cValor:=substring(cValor,1,nTam)
         cTela:=cValor
         oObjeto:load( cValor )
      EndIf
   EndIf

Return lRet 

/*
Função     : CP400GravaAtr()
Objetivo   : Grava a informação no banco
Parâmetros : cTela campo gerado na tela
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400GravaAtr(oModelEKC, cTela, cValor, lCondic,  lViaHtml , oMulti, nTam)
   local aValores   := {}
   local nTamCpoVlr := 0

   default lCondic     := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   default lViaHtml    := .F.
   default nTam        := 0

   cValor := if( lViaHtml .and. valtype(oMulti) == "O", TrataInf(oMulti, nTam) , cValor )
   cTela := if( lViaHtml .and. valtype(oMulti) == "O", cValor, cTela )

   oModelEKC:SetValue("EKC_VALOR",cValor)
   nTamCpoVlr := getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")
   cTela := subString(cTela,1,nTamCpoVlr)
   oModelEKC:LoadValue("EKC_VLEXIB",cTela)

   if lCondic .and. len(_aAtributos) > 0
      aValores := if( M->EKG_MULTVA == "1", StrTokArr2(cValor,';', .T.), {cValor} )
      LoadAtrCond(oModelEKC,alltrim(M->EKG_FORMA), aValores)
   endif

return .T.

static function TrataInf(oMulti, nTam)
   local cRet   := ""

   default nTam  := 0

   cRet := strTran( if( oMulti == nil, "" , oMulti:retText()) , "<!--?-->" + CHR(10), "")
   cRet := strTran( cRet ,  "<!--?-->", "")
   cRet := strTran( cRet , CHR(10) + CHR(9) , "")
   cRet := strTran( cRet , CHR(9) , "")
   cRet := if( at( "<!--?lit$",cRet) > 0 .and. at( "$-->",cRet) > 0 , strTran( cRet , substr( cRet, at( "<!--?lit$",cRet), at( "$-->",cRet)+len("$-->")-1), "" ), cRet)

   cRet := if( nTam > 0, substr( cRet, 1, nTam), cRet)

return cRet

/*
Função     : CP400ViewAtr()
Objetivo   : Retorna a informação pra tela principal quando sai da tela do F3 sem Confirmar 
Parâmetros : 
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400ViewAtr()
   cTela := cTelaView
return .T.

/*
Função     : CP400GeraPic()
Objetivo   : Gera a picture de acordo com os parÂmeros
Parâmetros : nTam tamanho total do campo inclusive com ponto decimal
             nDec número de casas decimais
Retorno    : 
Autor      : Maurício Frison
Data       : Mar/2020
Revisão    :
*/
Function CP400GeraPic(nTam,nDec)
   Local cPict := ""
   Local nI

   //define decimal
   For nI := 1 to nDec
      cPict := cPict+"9"
   Next
   if nDec <> 0
      cPict :=  "."+cPict
      nTam := nTAm - ndec -1 //-1 referente ao ponto decimal
   EndIf
   //defini parte inteira
   For nI := nTam to 1 step -1
      if Mod(nTam-nI,3) == 0 .And. (nTam-nI) > 0
            cPict := "9," + cpict
      Else 
            cPict := "9" + cpict 
      EndIf     
   Next
   cPict :=  "@E " + cPict

Return cPict

/*
Função     : EKCLineValid()
Objetivo   : Funcao de Pre validacao do grid da EKC
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Static Function EKCLineValid(oGridEKC, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.
 
   Do Case
      Case cAction == "DELETE" .And. !IsInCallStack("ForceAddLine") .And. !IsInCallStack("CP400POSVL") .And. !IsInCallStack("CP400ATRIB") .and. !IsInCallStack("CP400GravaAtr")
         If Alltrim(oGridEKC:GetValue("EKC_STATUS")) != "EXPIRADO"
            Help( ,, 'HELP',, STR0034, 1, 0) //"Não é possível excluir atributos com o status Vigente ou Futuro." 
            lRet := .F.
         EndIf
      Case cAction == "UNDELETE" .And. !IsInCallStack("ForceAddLine") .And. !IsInCallStack("CP400POSVL") .And. !IsInCallStack("CP400ATRIB") .and. !IsInCallStack("CP400GravaAtr")
         If (alltrim(upper(oGridEKC:GetValue("EKC_STATUS"))) == alltrim(upper(STR0007)))
            EasyHelp(STR0215,STR0002,STR0216) // "Não é possível recuperar um atributo com o status 'Bloqueado'." ### "Atenção" ### "O atributo ou seu atributo principal encontra-se bloqueado."
            lRet := .F.
         EndIf

   EndCase

Return lRet


/*
Função     : EKAPreValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : Maurício Frison
Data       : Junho/2022
Revisão    :
*/
Static Function EKAPreValid(oGridEKA, nLine, cAction, cIDField, xValue, xCurrentValue)
   Local lRet := .T.

   Do Case
      Case cAction == "UNDELETE" 
         lRet := CP400Valid('EKA_PRDREF',.T.)
   EndCase

Return lRet

/*
Função     : EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
Objetivo   : Funcao para quando efetuado um duplo clik no item abrir em tela
Retorno    : Retorno lógico
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Static Function EKCDblClick(oFormulario,cFieldName,nLineGrid,nLineModel)
   Local lRet := .F.

   lRet := CP400TELA()

Return lRet

/*
Class      : CP400EV
Objetivo   : CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Class CP400EV FROM FWModelEvent
     
   Method New()
   Method Activate()
   Method DeActivate()

End Class
/*
Class      : Método New Class CP400EV 
Objetivo   : Método para criação do objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method New() Class CP400EV
Return

/*
Class      : Método New Class CP400EV 
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method Activate(oModel,lCopy) Class CP400EV
   cNcmEK9  := ""
   cModalEK9 := ""
   cPrdRefEK9 := ""
   cFilRefEK9 := ""
   oJsonAtt := jsonObject():New()
   oCpObrig := jSonObject():New()
   oCondicao := jsonObject():New()
   CP400ATRIB(.T.)
Return 

/*
Class      : Método New Class CP400EV 
Objetivo   : Limpar objeto e fechar o APP
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Abril/2024
Revisão    :
*/
Method DeActivate() Class CP400EV
   CP400Fecha()
Return

Function CP400BTNOK(cVar,oModel,cModelId)

Local lRet := .T.
Local oView := FWViewActive()
Local oMdl_EK9 := oView:GetModel("EK9MASTER")
Local oMdl_EKA := oView:GetModel("EKADETAIL")
Local oMdl_EKB := oView:GetModel("EKBDETAIL")

If oView:GetModel():GetOperation() != MODEL_OPERATION_DELETE .And. oView:GetModel():GetOperation() != MODEL_OPERATION_VIEW
   Begin Sequence 

   setMsgPOUI(STR0217, "false")//"Validando atributos..."
   If cVar == "VIEW"
      If isMemVar("oCpObrig") .And. lAltPOUI
         If !canWriteAtt()
               oView:SetInsertMessage(STR0225, STR0120 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0121) //'Registro incluído com sucesso!'###"Existem atributos obrigatórios e vigentes que não foram preenchidos."###"Revise as informações do catalogo de produtos."
               oView:SetUpdateMessage(STR0226, STR0120 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0121) //'Registro alterado com sucesso!'###"Existem atributos obrigatórios e vigentes que não foram preenchidos."###"Revise as informações do catalogo de produtos."
            //lRet := .F.
            Break
         Else
            oView:SetInsertMessage('', STR0225) //'Registro incluído com sucesso!'
            oView:SetUpdateMessage('', STR0226) //'Registro alterado com sucesso!'
         EndIf
      Else
         If oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE .And. !oMdl_EK9:IsModified() .And. !oMdl_EKA:IsModified() .And. !oMdl_EKB:IsModified()
            oModel:SetErrorMessage("","","","","SEMALTERACAO", STR0218)//"Não foi detectada nenhuma alteração nos dados do Catálogo de Produtos"
            lRet := .F.
            Break
         EndIf
      EndIf
   EndIf

   End Sequence

   oChannel:AdvPLToJS("sendAlertEsconde", "")

   If oView <> Nil
      oView:lModify 		   := .T.
      oView:oModel:lModify	:= .T.
   EndIf
EndIf
Return lRet
/*
Função     : EKALineValid()
Objetivo   : Funcao de Pre validacao do grid da EKA
Retorno    : T se quiser continuar e F se não quiser continuar
Autor      : Maurício Frison
Data       : Abr/2020
Revisão    :
*/
Static Function EKALineValid(oModelEKA)
   Local lRet := .T.

   if IsInCallStack("CP400AtLn1") 
      lRet := lRetAux
   EndIf

Return lRet

/*
Função     : EKBLnVlPos()
Objetivo   : Funcao de Pos validacao da linha do grid da EKB - Relação de Países de Origem e Fabricantes
Retorno    : T se validar  e F se não validar
Autor      : Ramon Prado
Data       : Maio/2021
Revisão    :
*/
Static Function EKBLnVlPos(oModelEKB)
   Local lRet := .T.
   // Local lEmpPais := .T.
   // if oModelEKB:HasField("EKB_PAIS")
   //    lEmpPais :=  Empty(oModelEKB:GetValue("EKB_PAIS"))
   // EndIf
   // If Empty(oModelEKB:GetValue("EKB_CODFAB")) .And. lEmpPais //Empty(oModelEKB:GetValue("EKB_PAIS")) //informou o fabricante e o país está vazio
   //    Help(" ",1,"CP400FABRP") //"Veja que na linha: " ## "Problema: Não foram informados fabricantes ou países de origem. Solução: Informe ao menos um país de origem ou fabricante para prosseguir" 
   //    lRet := .F.
   // EndIf

Return lRet


/*
Programa   : TemIntegEKD
Objetivo   : Verifica se para o Catalogo informado, existe registro Integrado ou Cancelado
Retorno    : .T. quando encontrar registro Integrado ou Cancelado; .F. não encontrar registro Integrado ou Cancelado
Autor      : Ramon Prado
Data/Hora  : Maio/2020
*/
Static Function TemIntegEKD(cCod_I)
   Local lRet := .F.
   Local cQuery

   cQuery := "SELECT EKD_COD_I FROM " + RetSQLName("EKD")
   cQuery += " WHERE EKD_FILIAL = '" + xFilial("EKD") + "' "
   cQuery += "   AND EKD_COD_I  = '" + cCod_I + "' "
   cQuery += "   AND (EKD_STATUS = '1' OR EKD_STATUS = '3') " //Registrado ou Cancelado
   cQuery += "   AND D_E_L_E_T_ = ' ' "

   If EasyQryCount(cQuery) != 0
      lRet := .T.
   EndIf

Return lRet



/*/{Protheus.doc} CP400StEKD
   Função que retorna o Status da ultima integração/Historico do Catálogo
   @author Ramon Prado
   @since 18/05/2021
   @version 1
/*/
Function CP400StEKD(cCatEK9)
   Local cStatusEKD  := ""
   Local aArea       := GetArea()

   EKD->(DbSetOrder(1)) //Filial + Cod.Item Cat + Versão
   If EKD->(AvSeekLAst( xFilial("EKD") + cCatEK9 ))
      cStatusEKD := EKD->EKD_STATUS
   EndIf

   RestArea(aArea)
Return cStatusEKD

Static Function AddColumns(aColumns, cAlias)
Local nInc
Local aStruct := (cAlias)->(DbStruct())
Local aBrowse := {}
Local cColumn, bBlock, cType, nSize, nDec, cTitle, cPicture, nAlign

	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
   For nInc := 1 To Len(aColumns)

      cColumn := Alltrim(aColumns[nInc])
      bBlock := &("{ ||" + cColumn + " }")
      cType := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][2]
      nSize := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][3]
      nDec := aStruct[aScan(aStruct, {|x| x[1] == cColumn })][4]

      cTitle   := AvSX3(cColumn, AV_TITULO)
      cPicture := AvSX3(cColumn, AV_PICTURE)
      nAlign := If(cType<>"N", 1, 2)
      aAdd(aBrowse, {cTitle,bBlock,cType,cPicture,nAlign,nSize,nDec,.F.,{||.T.},.F.,, cColumn, {||.T.},.F.,.F.})
   Next

Return aBrowse


Static Function AllCpoIndex(cAlias,aColunas)
Local aInd
Local aAux
Local oAliasStru := FWFormStruct(1,cAlias)
Local nI
Local nY
local cCampo := ""

Default aColunas := {}

aInd := oAliasStru:GetIndex()

For nI := 1 To Len(aInd)
   aAux := StrTokArr(aInd[nI][3],'+')
   For nY := 1 To Len(aAux)
      cCampo := CpoIndex(if( cAlias == "SB1", "B1", "A2"), Alltrim(aAux[nY]))
      If aScan(aColunas,{|X| Alltrim(X) == cCampo}) == 0
         aAdd(aColunas,cCampo)
      EndIf
   Next
Next

Return aColunas

/*/{Protheus.doc} CpoIndex
   Trata as funções que estão nos campos de indice para campos numericos ou datas

   @type  Static Function
   @author user
   @since 29/08/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
static function CpoIndex(cPrefixo, cCampo)
   local cRet       := cCampo
   local nPos       := 0

   nPos := At(cPrefixo + "_", cCampo)
   if nPos > 0 .and. "(" $ cCampo .and. ")" $ cCampo
      cRet := SubStr(cCampo, nPos, len(cCampo))
      nPos := At(",",cRet)
      if nPos > 0
         cRet := SubStr(cRet, 1, nPos-1)
      else
         nPos := At(")",cRet)
         if nPos > 0
            cRet := SubStr(cRet, 1, nPos-1)
         endif
      endif 
   endif

return cRet

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
   oStruct:AddField( STR0208                        , ; // [01]  C   Titulo do campo ### "Obrigatório"
                     STR0208                        , ; // [02]  C   ToolTip do campo ### "Obrigatório"
                     "ATRIB_OBRIG"                  , ; // [03]  C   identificador (ID) do Field
                     "C"                            , ; // [04]  C   Tipo do campo
                     1                              , ; // [05]  N   Tamanho do campo
                     0                              , ; // [06]  N   Decimal do campo
                     {|| .T. }                      , ; // [07]  B   Code-block de validação do campo
                     {|| .F. }                      , ; // [08]  B   Code-block de validação When do campo
                     {"1=" + STR0210, "2=" + STR0211}  , ; // [09]  A   Lista de valores permitido do campo #### "Sim" #### "Não"            
                     .F.                            , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
                     {|| CP400Relac("ATRIB_OBRIG") }, ; // [11]  B   Code-block de inicializacao do campo
                     .F.                            , ; // [12]  L   Indica se trata de um campo chave
                     .T.                            , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                     .T.                            )   // [14]  L   Indica se o campo é virtual

   if Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
      oStruct:AddField( STR0209                        , ; // [01]  C   Titulo do campo ### "Ordem"
                        STR0209                        , ; // [02]  C   ToolTip do campo ### "Ordem"
                        "ATRIB_ORDEM"                  , ; // [03]  C   identificador (ID) do Field
                        "C"                            , ; // [04]  C   Tipo do campo
                        254                            , ; // [05]  N   Tamanho do campo
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

/*/{Protheus.doc} CpoView
   inclusão de campo no view 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param  oStruct, Objeto, Objeto da classe FWFormStruct
   @return 
/*/
static function CpoView( oStruct )
   local nOrdem := val(getSX3Cache("EKC_CODATR", "X3_ORDEM"))+1

   oStruct:AddField(	"ATRIB_OBRIG"      , ;  // [01]  C   Nome do Campo
                     StrZero(nOrdem,2)  , ;  // [02]  C   Ordem
                     STR0208            , ;  // [03]  C   Titulo do campo ### "Obrigatório"
                     STR0208            , ;  // [04]  C   Descrição do campo ### "Obrigatório"
                     nil                , ;  // [05]  A   Array com Help
                     "C"                , ;  // [06]  C   Tipo do campo
                     ""                 , ;  // [07]  C   Picture
                     nil                , ;  // [08]  B   Bloco de Picture Var
                     ''                 , ;  // [09]  C   Consulta F3
                     .F.                , ;  // [10]  L   Indica se o campo é editável
                     ""                 , ;  // [11]  C   Pasta do campo
                     ""                 , ;  // [12]  C   Agrupamento do campo
                     {"1=" + STR0210, "2=" + STR0211} , ;  // [13]  A   Lista de valores permitido do campo (Combo) #### "Sim" #### "Não"
                     nil                , ;  // [14]  N   Tamanho Maximo da maior opção do combo
                     nil                , ;  // [15]  C   Inicializador de Browse
                     .T.                , ;  // [16]  L   Indica se o campo é virtual
                     nil                )    // [17]  C   Picture Variável

return

/*/{Protheus.doc} LoadAtrCond
   Carrega no modelo EKC os atributos condicionados

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, Objeto, Modelo EKC
          cValor, caracter, valor do atributo
   @return 
/*/
static function LoadAtrCond(oModelEKC, cFormaPai, aValores)
   local cCodAtrib  := ""
   local cAtrPrinc  := ""
   local nPosCond   := 0
   local oModel     := nil
   local oModelEK9  := nil
   local cCodCat    := ""
   local cAtribCond := ""
   local cError     := ""
   local lError     := .F.
   local cOrdem     := ""
   local aIncAtrib  := {}
   local aExcAtrib  := {}
   local aBackLines := {}
   local nPosCpoAtb := 0
   local nPosCpoCnd := 0
   local nPosOrdem  := 0
   local nAtrib     := 0
   local cMsgError  := STR0112 // "Verifique como está cadastrado a condição do atributo."
   local nValor     := 0
   local cValor     := ""
   local cModalid   := ""
   local lExc       := .F.

   default cFormaPai := ""
   default aValores  := {}

   cCodAtrib := oModelEKC:GetValue("EKC_CODATR")
   cAtrPrinc := oModelEKC:GetValue("EKC_CONDTE")
   nPosCond := aScan( _aAtributos , { |X| X[2] == cCodAtrib })

   if nPosCond > 0

      oModel := oModelEKC:getModel()
      oModelEK9 := oModel:getModel("EK9MASTER")
      oModelEKC:SetNoInsertLine(.F.)
      cCodCat := oModelEK9:GetValue("EK9_COD_I")
      cModalid := oModelEK9:GetValue("EK9_MODALI")

      for nValor := 1 to len(aValores)

         cValor := aValores[nValor]
         nPosCond := aScan( _aAtributos , { |X| X[2] == cCodAtrib })
         while nPosCond > 0

            EKG->(dbGoTo(_aAtributos[nPosCond][3]))
            if EKG->(recno()) == _aAtributos[nPosCond][3]

               cAtribCond := alltrim(EKG->EKG_COD_I) + " - " + alltrim(EKG->EKG_NOME)
               cError := ""
               lError := .F.
               cOrdem := retOrdemAtrb(EKG->EKG_COD_I, cCodAtrib)

               if !empty(cValor) .and. !empty(EKG->EKG_CONDIC) .and. VldAtrCond(alltrim(EKG->EKG_CONDIC), cFormaPai, alltrim(cValor), @cError, @lError) // Realiza a inclusão dos condicionados

                  if !oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", EKG->EKG_COD_I },{"EKC_CONDTE", cCodAtrib }}, .T.)
                     if CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG) != "EXPIRADO" .and.  ( (cModalid == "1" .and. "7" $ alltrim(EKG->EKG_CODOBJ)) .or. !(cModalid == "1") ) .and. ( empty(EKG->EKG_MODALI) .or. EKG->EKG_MODALI == "3" .or. cModalid == EKG->EKG_MODALI )
                        aAdd( aIncAtrib, {cCodAtrib, EKG->EKG_COD_I, cOrdem, _aAtributos[nPosCond][3]} )
                     endif
                  endif

               elseif !lError // Realiza a exclusão dos condicionados

                  lExc := oModelEKC:SeekLine({{"ATRIB_ORDEM", cOrdem}}, .T.) 
                  if lExc
                     if aScan( aExcAtrib, { |X| X[1] == oModelEKC:getValue("EKC_CONDTE") .and. X[2] == oModelEKC:getValue("EKC_CODATR") } ) == 0
                        aAdd( aExcAtrib, {oModelEKC:getValue("EKC_CONDTE"), oModelEKC:getValue("EKC_CODATR"), cOrdem} )
                        delCond(oModelEKC, oModelEKC:getValue("EKC_CODATR"), @aExcAtrib)
                     endif
                  endif

               endif

            endif

            nPosCond := if( !lError , aScan( _aAtributos , { |X| X[2] == cCodAtrib }, nPosCond+1), 0)
         end
      next

      if( lError, EasyHelp(STR0113 + " [" + cAtribCond + "]" + CHR(10) + CHR(10) + STR0114 + ": " + cError, STR0067, cMsgError), nil) // "Não foi possível carregar os atributos condicionados" ### "Erro"

      if !lError .and. (len(aIncAtrib) > 0 .or. len(aExcAtrib) > 0)

         aBackLines := GetLines(oModelEKC, aExcAtrib)

         aSize(oModelEKC:aDataModel, 0)
         oModelEKC:aDataModel := {}
         oModelEKC:InitLine()

         if len(aBackLines) > 0
            nPosCpoAtb := aScan(aBackLines[1], { |X| X[1] == "EKC_CODATR" } )
            nPosCpoCnd := aScan(aBackLines[1], { |X| X[1] == "EKC_CONDTE" } )
            nPosOrdem := aScan(aBackLines[1], { |X| X[1] == "ATRIB_ORDEM" } )
         endif

         for nAtrib := 1 to len(aBackLines)
            //if !oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", aBackLines[nAtrib][nPosCpoAtb][2] },{"EKC_CONDTE", aBackLines[nAtrib][nPosCpoCnd][2] }}, .T.)
            if !oModelEKC:SeekLine({{"ATRIB_ORDEM", aBackLines[nAtrib][nPosOrdem][2]}}, .T.)
               AddLine(oModelEKC, aBackLines[nAtrib], !(nAtrib == 1))
               if len(aIncAtrib) > 0 .and. cCodAtrib == aBackLines[nAtrib][nPosCpoAtb][2] .and.;
                  ( empty(aBackLines[nAtrib][nPosCpoCnd][2]) .Or. aScan(aIncAtrib, { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] .and. !empty(X[2])}) > 0)
                  nPosCond := aScan( aIncAtrib , { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] })
                  while nPosCond > 0
                     AddLine(oModelEKC)
                     getInfCond(oModelEKC, aIncAtrib[nPosCond][4] , cCodCat, aIncAtrib[nPosCond][3])
                     nPosCond := aScan( aIncAtrib , { |X| X[1] == aBackLines[nAtrib][nPosCpoAtb][2] }, nPosCond+1)
                  end
               endif
            endif
         next

      endif

      OrdAtrib(oModelEKC)

      oModelEKC:SetNoInsertLine(.T.)
      oModelEKC:SeekLine({{"EKC_COD_I", cCodCat} ,{"EKC_CODATR", cCodAtrib }})

   endif

return

/*/{Protheus.doc} VldAtrCond
   Valida todas as condições dos atributos condicionados com o valor do condicionante

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param cCondicao, caracter, condição para o condicionado
          cInfo, caracter, valor do atributo condicionante
          cError, caracter, mensagem de erro
          lError, logico, houve erro da verificação da condição
   @return 
/*/
static function VldAtrCond(cCondicao, cFormaPai, cInfo, cError, lError)
   local lRet       := .F.
   local oJson      := nil
   local aNames     := {}
   local cComposic  := ""

   default cCondicao  := ""
   default cFormaPai  := ""
   default cInfo      := ""
   default cError     := ""
   default lError     := .F.

   if !empty(cCondicao)
      oJson := JsonObject():New()
      if oJson:FromJson(cCondicao) == nil
         while !( lRet := JsonCond( oJson, cFormaPai, cInfo, @cError, @lError )) .and. !lError
            aNames := oJson:GetNames()
            if aScan( aNames , { |X| X == "composicao" }) > 0 .and. aScan( aNames , { |X| X == "condicao" }) > 0 .and. valtype(oJson["condicao"]) == "J"

               cComposic := ""
               if valtype(oJson["composicao"]) == "C"
                  cComposic := alltrim(oJson["composicao"])
               endif

               if !lRet .and. cComposic == '&&'
                  exit
               endif

               oJson := oJson["condicao"]
            else
               exit
            endif
         end
      endif
      fwFreeObj(oJson)
   endif

return lRet

/*/{Protheus.doc} JsonCond
   Valida a condição dos atributos condicionados com o valor do condicionante

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param cCondicao, caracter, condição para o condicionado
          cInfo, caracter, valor do atributo condicionante
          cError, caracter, mensagem de erro
          lError, logico, houve erro da verificação da condição
   @return 
/*/
static function JsonCond( oJsonCond, cFormaPai, cInfo, cError, lError )
   local lRet       := .F.
   local aNames     := {}
   local cOperador  := ""
   local cValor     := ""
   local oErr       := nil
   local bLastError := {||}

   default cError := ""
   default lError := .F.

   aNames := oJsonCond:GetNames()

   if aScan( aNames , { |X| X == "operador" }) > 0
      cOperador := alltrim(oJsonCond["operador"])
   endif

   if aScan( aNames , { |X| X == "valor" }) > 0
      cValor := alltrim(oJsonCond["valor"])
      if lower( cValor ) == "true" .or. lower(cValor) == "false" .or. cFormaPai == "BOOLEANO"
         cValor := if(cValor == "true", "1", if(cValor == "false", "2", "true / false"))
      elseif !isnumeric(cInfo) .and. !isnumeric(cValor)
         cValor := "'" + lower(cValor) + "'"
         cInfo := "'" + lower(cInfo) + "'"
      endif
   endif

   bLastError := ErrorBlock( { |e| oErr := e, lError := .T., lRet := .F.})
   if !empty(cOperador) .and. !empty(cValor)
      lRet := &(cInfo + cOperador + cValor)
   endif
   ErrorBlock(bLastError)

   //if( valType(oErr) != "U", cError := oErr:ERRORSTACK, nil)
   if( valType(oErr) != "U", cError := STR0115 + ": " + cInfo + " " + cOperador + " " + cValor, nil) // "Falha ao verificar a condição"

return lRet

/*/{Protheus.doc} loadInfAtr
   Carrega o modelo EKC de acordo com os parametros  

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKC
          aInf, vetor, informações do atributo em vetor
          lCondic, logico, ambiente atualizado com o campo EKC_CONDTE
          cCodCat, caracter, código do catalogo de produto
   @return 
/*/
static function loadInfAtr(oModelEKC, cAliasTb, lCondic, cCodCat, cOrdem)

   default cAliasTb := "EKG"
   default lCondic  := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   default cCodCat  := ""
   default cOrdem   := ""

   oModelEKC:LoadValue("EKC_CODATR" , (cAliasTb)->EKG_COD_I)
   oModelEKC:LoadValue("EKC_STATUS" , CP400Status((cAliasTb)->EKG_INIVIG,(cAliasTb)->EKG_FIMVIG))
   oModelEKC:LoadValue("EKC_NOME"   , AllTrim((cAliasTb)->EKG_NOME))
   oModelEKC:LoadValue("ATRIB_OBRIG", if(empty((cAliasTb)->EKG_OBRIGA),"2", (cAliasTb)->EKG_OBRIGA))
   oModelEKC:LoadValue("EKC_VALOR"  , "" )
   if lCondic 
      oModelEKC:LoadValue("EKC_CONDTE" , (cAliasTb)->EKG_CONDTE)
      oModelEKC:LoadValue("ATRIB_ORDEM", cOrdem )
   endif

return

/*/{Protheus.doc} OrdAtrib
   Ordenar os atributos 

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oModelEKC, objeto, modelo EKC
   @return 
/*/
static function OrdAtrib(oModelEKC)
   local nPosOrdem  := 0
   local oStrGrd    := oModelEKC:getStruct()

   nPosOrdem  := oStrGrd:GetFieldPos("ATRIB_ORDEM")
   if nPosOrdem > 0
      aSort(oModelEKC:aDATAMODEL,,, {|x,y| x[1][1][nPosOrdem] < y[1][1][nPosOrdem] } )
   endif

return 

/*/{Protheus.doc} GetLines
   Realiza o backup dos dados do grid

   @type  Static Function
   @author bruno akyo kubagawa
   @since 23/12/2022
   @version 1.0
   @param oMdlGrid, objeto, modelo da grid
   @return 
/*/
static function GetLines(oMdlGrid, aNoCopy)
   local oStrGrd    := nil
   local aCposGrd   := {}
   local aRet       := {}
   local nReg       := 0
   local aReg       := {}
   local nCpo       := 0

   default aNoCopy := {}

   oStrGrd  := oMdlGrid:getStruct()
   aCposGrd := oStrGrd:GetFields()

   for nReg := 1 To oMdlGrid:GetQtdLine()
      oMdlGrid:Goline(nReg)
      if len(aNoCopy) > 0 .and. aScan( aNoCopy , { |X| X[2] == oMdlGrid:getValue("EKC_CODATR") .and. X[1] == oMdlGrid:getValue("EKC_CONDTE") }) > 0  
         loop
      endif
      aReg := {}
      for nCpo := 1 to Len(aCposGrd)
         aAdd(aReg,{aCposGrd[nCpo][3], oMdlGrid:GetValue(aCposGrd[nCpo][3])})
      next nCpo
      aAdd(aRet,aClone(aReg))
      aSize(aReg,0)
   next nReg

return aRet

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aLoadCpos, lAddLine)
   local nLine     := 0
   local nCpo      := 0

   default aLoadCpos   := {}
   default lAddLine    := .T.

   nLine := oModelDet:GetLine()
   if lAddLine
      nLine := oModelDet:AddLine()
   endif

   for nCpo := 1 to Len(aLoadCpos)
      oModelDet:LoadValue( aLoadCpos[nCpo][1], aLoadCpos[nCpo][2] )
   next

return nLine

/*
Função     : getInfCond
Objetivo   : Realiza a atualização do modelo de dados EKC a partir da EKG
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function getInfCond(oModelEKC, nRecEKG, cCodCat, cOrdem)
   EKG->(dbGoTo(nRecEKG))
   loadInfAtr(oModelEKC, , .T., cCodCat, cOrdem)
return

/*
Função     : CommitEKC
Objetivo   : Commit do modelo de dados da EKC
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function CommitEKC( oModelo )
   local lCondic   := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
   local oModelEKC := nil
   local cQuery    := ""
   local oQuery    := nil
   local cAliasQry := ""
   local oStrGrd   := nil
   local aCposGrd  := {}
   local nRegEKC   := 0
   local lSeek     := .F.
   local nCpo      := 0
   local aCpos     := {}
   local nOperat   := oModelo:getOperation()
   Local lAutoExec := isExecAuto()

   if !nOperat == MODEL_OPERATION_VIEW

      oModelEKC := oModelo:getModel("EKCDETAIL")
      oModelEK9 := oModelo:getModel("EK9MASTER")

      cQuery := " SELECT "
      cQuery += " R_E_C_N_O_ REC_EKC, EKC_FILIAL, EKC_COD_I, EKC_CODATR " 
      if lCondic
         cQuery += " , EKC_CONDTE "
      endif
      cQuery += " FROM " + RetSqlName('EKC') + " EKC "
      cQuery += " WHERE EKC.D_E_L_E_T_ = ' ' "
      cQuery += " AND EKC.EKC_FILIAL = ? "
      cQuery += " AND EKC.EKC_COD_I = ? "
      cQuery += " ORDER BY EKC_FILIAL, EKC_COD_I, EKC_CODATR "
      if lCondic
         cQuery += " , EKC_CONDTE "
      endif

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EKC'))
      oQuery:SetString(2,oModelEK9:GetValue("EK9_COD_I"))
      cQuery := oQuery:GetFixQuery()

      cAliasQry := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())

      If canUseApp() .And. !lAutoExec //Se utilzia o APP da Relação de Atributos
         setMsgPOUI(STR0219, "false")//"Gravando atributos..."
         POUIGrvEKC(cAliasQry, oModelEK9, nOperat)
         (cAliasQry)->(dbCloseArea())
         oQuery:Destroy()
         oChannel:AdvPLToJS("sendAlertEsconde", "")
      Else//Nao esta usando o APP POUI para a Relação de Atributos, segue como era feito antes
         while (cAliasQry)->(!eof())
            if !oModelEKC:SeekLine( if( lCondic, {{"EKC_COD_I", (cAliasQry)->EKC_COD_I} , {"EKC_CODATR", (cAliasQry)->EKC_CODATR } , {"EKC_CONDTE", (cAliasQry)->EKC_CONDTE }} , {{"EKC_COD_I" , (cAliasQry)->EKC_COD_I} , {"EKC_CODATR", (cAliasQry)->EKC_CODATR }} ), .T. )
               EKC->(dbGoTo((cAliasQry)->REC_EKC))
               if (cAliasQry)->REC_EKC == EKC->(recno())
                  EKC->(reclock("EKC", .F.))
                  EKC->(dbDelete())
                  EKC->(MsUnlock())
               endif
            endif
            (cAliasQry)->(dbSkip())
         end
         (cAliasQry)->(dbCloseArea())
         oQuery:Destroy()

         EKC->(dbSetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR
         oStrGrd  := oModelEKC:getStruct()
         aCposGrd := oStrGrd:GetFields()
         for nCpo := 1 to len(aCposGrd)
            if EKC->(ColumnPos(aCposGrd[nCpo][3])) > 0
               aAdd( aCpos, aCposGrd[nCpo][3])
            endif
         next

         for nRegEKC := 1 to oModelEKC:length()
            oModelEKC:goLine(nRegEKC)
            lSeek := EKC->(dbSeek( xFilial("EKC") + oModelEK9:GetValue("EK9_COD_I") + oModelEKC:getValue("EKC_CODATR") + if( lCondic, oModelEKC:getValue("EKC_CONDTE"), "") ))

            if nOperat == MODEL_OPERATION_DELETE .or. oModelEKC:isDeleted()
               if lSeek
                  EKC->(reclock("EKC", .F.))
                  EKC->(dbDelete())
                  EKC->(MsUnlock())
               endif
            elseif !empty( oModelEKC:getValue("EKC_CODATR") )
               EKC->(reclock("EKC", !lSeek))
               for nCpo := 1 to len(aCpos)
                     EKC->&(aCpos[nCpo]) := oModelEKC:GetValue( aCpos[nCpo] )
               next
               if !lSeek
                  EKC->EKC_FILIAL := xFilial("EKC")
                  EKC->EKC_COD_I  := oModelEK9:GetValue("EK9_COD_I")
                  EKC->EKC_CODATR := oModelEKC:getValue("EKC_CODATR")
               endif
               EKC->(MsUnlock())
            endif
         next nRegEKC
      EndIf
   endif

return

/*
Função     : POUIGrvEKC
Objetivo   : Função para fazer o commit dos dados da EKC quando utilizado o APP POUI para a relação dos atributos
Autor      : Tiago Tudisco
Data/Hora  : 14/03/2024
*/
Static Function POUIGrvEKC(cAliasQry, oModelEK9, nOperat)
//Excluir oq tiver na EKC e não foi preenchido no App
//Alterar oq tiver na EKC e foi preenchido no App
//Incluir oq não tiver na EKC e foi preenchido no App
local lCondic   := AvFlags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")
Local aNames := oCpObrig:GetNames()
Local lSeek
Local nI

EKC->(dbSetOrder(1)) // EKC_FILIAL+EKC_COD_I+EKC_CODATR

While (cAliasQry)->(!Eof())
   If !oCpObrig:HasProperty(Alltrim((cAliasQry)->EKC_CODATR))
      EKC->(dbGoTo((cAliasQry)->REC_EKC))
      If (cAliasQry)->REC_EKC == EKC->(recno())
         EKC->(reclock("EKC", .F.))
         EKC->(dbDelete())
         EKC->(MsUnlock())
      EndIf
   EndIf
   (cAliasQry)->(dbSkip())
End

For nI := 1 To Len(aNames)
   lSeek := EKC->(dbSeek( xFilial("EKC") + oModelEK9:GetValue("EK9_COD_I") + AvKey(aNames[nI],"EKC_CODATR") + if( lCondic, oCpObrig[aNames[nI]]['condicionante'], "") ))
   If oCpObrig[aNames[nI]]['visible'] .And. !oCpObrig[aNames[nI]]['bloqueado'] //Grava na EKC
      
      if nOperat == MODEL_OPERATION_DELETE
      	if lSeek
            EKC->(reclock("EKC", .F.))
            EKC->(dbDelete())
            EKC->(MsUnlock())
	      endif
      Else
         EKC->(reclock("EKC", !lSeek))
         EKC->EKC_VALOR := getValPOUI(oCpObrig[aNames[nI]]['value'])
         if !lSeek
            EKC->EKC_FILIAL := xFilial("EKC")
            EKC->EKC_COD_I  := oModelEK9:GetValue("EK9_COD_I")
            EKC->EKC_CODATR := aNames[nI]
            EKC->EKC_CONDTE := oCpObrig[aNames[nI]]['condicionante']
         endif

         EKC->(MsUnlock())

      EndIf
   Else //Apaga se existir na EKC
      If lSeek
         EKC->(reclock("EKC", .F.))
         EKC->(dbDelete())
         EKC->(MsUnlock())
      EndIf
      
   EndIf
Next

Return

Static Function getValPOUI(xVal)
Local cRet := ""
Local nI

If ValType(xVal) == "A"
   For nI := 1 To Len(xVal)
      cRet += cValToChar(xVal[nI]) + ";"
   Next
   //Verifique se o ultimo caracter da string cRet é um ; e se for, retire esse ; do final de cRet
   If SubStr(cRet,Len(cRet),1) == ";"
      cRet := SubStr(cRet,1,Len(cRet)-1)
   EndIf
Else
   cRet := cValToChar(xVal)
EndIf
IIF(FwNoAccent(Alltrim(cRet)) == FwNoAccent("Valor Inválido"), cRet := "",)
Return cRet

/*
Função     : CP400Init
Objetivo   : Inicializador padrão para os campos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       :
*/
function CP400Init(cCampo) 
   local xValue

   do case
      case cCampo == 'EK9_MODALI'
         xValue := "1"
         if FwIsInCallStack("EECCP400")
            xValue := "2"
         endif
      case cCampo == "EK9_COD_I"
         xValue := ""
         if !isRest()
            xValue := GetSxeNum("EK9","EK9_COD_I","EK9_COD_I" + FWCodEmp() + if( !empty(xFilial("EK9")), "_" + alltrim(xFilial("EK9")), "") )
         endif
   end case

return xValue

/*
Função     : ValIdVers
Objetivo   : Valida se o catalogo de produto e a versão já existe.
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       : 
*/
static function ValIdVers(cIdMan, cVerMan, nOpc, cMsgError)
   local lRet       := .T.
   local aArea      := getArea()
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""

   default cIdMan    := ""
   default cVerMan   := ""
   default nOpc      := 0
   default cMsgError := ""

   if !empty(cIdMan) .and. !empty(cVerMan)
      cAliasQry := getNextAlias()

      cQuery := " SELECT EK9.EK9_COD_I, EK9.EK9_IDPORT, EK9.EK9_VATUAL "
      cQuery += " FROM " + RetSqlName('EK9') + " EK9 "
      cQuery += " WHERE EK9.D_E_L_E_T_ = ' ' "
      cQuery += " AND EK9.EK9_FILIAL = ? "
      cQuery += " AND EK9.EK9_IDPORT = ? "
      cQuery += " AND EK9.EK9_VATUAL = ? "
      if nOpc == MODEL_OPERATION_UPDATE
         cQuery += " AND EK9.R_E_C_N_O_ <> " + alltrim(str(EK9->(Recno()))) + " "
      endif

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EK9'))
      oQuery:SetString(2,cIdMan)
      oQuery:SetString(3,cVerMan)

      cQuery := oQuery:GetFixQuery()

      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         lRet := .F.
         cMsgError := STR0118 // "O catálogo de produto e a versão já está registrado no sistema."
      endif

      (cAliasQry)->(dbCloseArea())

      fwFreeObj(oQuery)

   endif

   restArea(aArea)

return lRet


/*
Função     : ValProcExp
Objetivo   : Valida se o catalogo de produto e a versão está sendo usada no item do processo de embarque
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
Obs.       : Como os campos de EK9_IDPORT e EK9_VATUAL são atualizados somente na confirmação, ou seja, não engatilhamos, podemos usar os campos para validação
*/
static function ValProcExp(cIdMan, cVerMan, cMsgError)
   local lRet       := .T.
   local aArea      := getArea()
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""
   local cIdPort    := ""
   local cVersao    := ""

   default cIdMan    := ""
   default cVerMan   := ""
   default cMsgError := ""

   cIdPort := EK9->EK9_IDPORT
   cVersao := EK9->EK9_VATUAL

   if !empty(cIdPort) .and. !empty(cVersao) .and. (!(cIdPort == cIdMan) .or. !(cVersao == cVerMan))

      cAliasQry := getNextAlias()

      cQuery := " SELECT DISTINCT EE9.EE9_PREEMB "
      cQuery += " FROM " + RetSqlName('EE9') + " EE9 "
      cQuery += " WHERE EE9.D_E_L_E_T_ = ' ' "
      cQuery += " AND EE9.EE9_FILIAL = ? "
      cQuery += " AND EE9.EE9_IDPORT = ? "
      cQuery += " AND EE9.EE9_VATUAL = ? "
   
      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,xFilial('EE9'))
      oQuery:SetString(2,cIdPort)
      oQuery:SetString(3,cVersao)

      cQuery := oQuery:GetFixQuery()

      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         lRet := .F.
         cMsgError := STR0119 // "Não é permitido a alteração dos campos ID Portal e Versão do catálogo de produto, pois está sendo utilizado no processo de Embarque."
      endif

      (cAliasQry)->(dbCloseArea())

      fwFreeObj(oQuery)

   endif

   restArea(aArea)

return lRet


Function CP400gtFrm(cForma, cValor, cCode, lInteg)
Local cRet

Default cCode := "POUI"
default lInteg := .F.

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
else
   cRet := cValor
endif

if lInteg .and. cForma == ATT_TEXTO
   cRet := comex.generics.SetStringJson(cRet)
endif

Return cRet

/*
Função     : ValidAtr
Objetivo   : Valida os atributos vinculados a tabela de integração do catalogo de produto
Parâmetro  : cCodCatPrd- Código do catalogo de produto (EK9_COD_I)
             cVersao - Ultima versão do catalogo de produto (EKD_VERSAO)
Retorno    : Retorna .T. os atributos estão corretos, .F. os atributos obrigatórios estão vazio
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
Function CP400AtrValid(cCodCatPrd, cVersao,cMsg) 
   local lRet       := .T.
   local aAreaEK9   := {}
   local oModelo    := nil
   local oModEKC    := nil
   local cAtributos := ""
   local aAtributos := {}
   local lBckAltera := ALTERA
   local cNcm       := ""
   local cModalid   := ""

   default cCodCatPrd := EKD->EKD_COD_I
   default cVersao    := EKD->EKD_VERSAO
   default cMsg      := ""

   dbSelectArea("EK9")
   aAreaEK9 := EK9->(getArea())

   if PermAlt(, .T.)
      EK9->(DbSeek(xFilial("EK9")+cCodCatPrd))
      oModelo := FwLoadModel("EICCP400")
      oModelo:SetOperation(MODEL_OPERATION_UPDATE)
      lRet := oModelo:Activate()

      if lRet         
         oModEKC := oModelo:getModel("EKCDETAIL")
         oModEK9 := oModelo:getModel("EK9MASTER")         
         cNcm := oModEK9:getValue("EK9_NCM")
         cModalid := oModEK9:getValue("EK9_MODALI")
         aAtributos := getAtrVazio( oModEKC, @cAtributos, cNcm, cModalid )

         if len(aAtributos) > 0
            lRet := .F.
            If canUseApp()
               cMsg := STR0124 + STR0229 // "Existem atributos que não foram preenchidos." ### "Atenção" #### "Para prosseguir com a integração, todos os atributos obrigatórios devem ser preenchidos."
            Else
               cMsg := STR0124 + STR0125 + ": " + cAtributos // "Existem atributos que não foram preenchidos." ### "Favor preencher os atributos" ### "Atenção"
            EndIf
         endif
      endif

      ALTERA := lBckAltera
      oModelo:DeActivate()
   endif

   restArea(aAreaEK9)

return lRet

/*
Função     : getAtrVazio
Objetivo   : Retorna os atributos que estão vazio no modelo de dados, que são obrigatórios e vigentes
Parâmetro  : oModelEKC - Modelo de dados EKCDETAIL
             cAtributos - String com todos os atributos
Retorno    : aAtributos - Array com os atributos
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function getAtrVazio( oModelEKC, cAtributos, cNcm, cModalid) 
   local aAtributos := {}
   local nAtributos := 0
   local lCondic    := .F.

   default cAtributos := ""
   default cNcm       := ""
   default cModalid   := "1"

   EKG->(dbSetOrder(1))
   lCondic := Avflags("ATRIBUTOS_CONDICIONANTES_CONDICIONADOS")

   for nAtributos := 1 to oModelEKC:Length()
      oModelEKC:GoLine( nAtributos )
      if !oModelEKC:IsDeleted() .and. oModelEKC:GetValue("ATRIB_OBRIG") == "1" .and. empty(oModelEKC:GetValue("EKC_VALOR")) .and. alltrim(oModelEKC:GetValue("EKC_STATUS")) == "VIGENTE"
         if empty(cNcm) .or. ( EKG->(dbSeek(xFilial("EKG") + cNcm + oModelEKC:GetValue("EKC_CODATR") + if( lCondic, oModelEKC:GetValue("EKC_CONDTE"),""))) .and. ;
                               ( (cModalid == "1" .and. "7" $ alltrim(EKG->EKG_CODOBJ)) .or. !(cModalid == "1") ) )
            aAdd( aAtributos , alltrim(oModelEKC:GetValue("EKC_CODATR")) )
         endif
      endif
   next

   if len(aAtributos) > 0
      aEval( aAtributos, { |X| cAtributos += X + ', '})
      cAtributos := substr( cAtributos, 1, len(cAtributos)-2)
   endif

return aAtributos

/*
Função     : CP400IntCat
Objetivo   : Função chamada no menu para Integrar o catalogo de produto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function CP400IntCat()
return EICCP402()

/*
Função     : CP400GerCat
Objetivo   : Função chamada no menu para o facilitador de inclusão automaticamente de catálogo de produtos para os itens importados
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function CP400GerCat()
   local aArea      := {}
   local oFwSX1Util := nil
   local aPergunte  := {}
   local lProc      := .F.

   aArea := getArea()

   oFwSX1Util := FwSX1Util():New()
   oFwSX1Util:AddGroup("EICCP400")
   oFwSX1Util:SearchGroup()
   aPergunte := oFwSX1Util:GetGroup("EICCP400")

   lProc := if( len(aPergunte) > 0 .and. len(aPergunte[2]) > 0, .T., (EasyHelp(STR0127, STR0002, STR0128 ),.F.)) // "Funcionalidade não disponível para esta versão do sistema." #### "Atenção" #### "A funcionalidade estará disponível a partir do próximo release ou através do pacote de Expedição Contínua. Acompanhe a página de publicações em Documentos de Referência - Comércio Exterior (TDN)."

   if lProc
      ViewWizard()
   endif

   RestArea(aArea)

   FwFreeArray(aPergunte)
   FwFreeObj(oFwSX1Util)
   aPergunte := nil

return

/*
Função     : ViewWizard
Objetivo   : Função do wizard para inclusão automática do catalogo de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewWizard()
   local aCoords    := {}
   local oStepWiz   := nil
   local oStep1     := nil
   local oStep2     := nil
   local oStep3     := nil
   local aPergCP400 := {}
   local cAliasSB1  := CP400_PROD
   local cFieldMark := "REG_MARCA"
   local cMarcaSB1  := "X"

   private __oDlg // devido ao erro na validação do pergunte

   aCoords := FWGetDialogSize()
   oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
   oStepWiz:ActiveUISteps()

   oStep1 := oStepWiz:AddStep("1", { |oPanel| ViewIntrod( oPanel )  })
   oStep1:SetStepDescription(STR0129) // "Introdução"
   oStep1:SetNextTitle(STR0130) // "Avançar"
   oStep1:SetNextAction( { || .T. } )
   oStep1:SetCancelAction({|| MsgYesNo(STR0131, STR0132) }) // "Deseja cancelar a geração de catálogo de produto?" ### "Geração de Catálogo de Produto"

   oStep2 := oStepWiz:AddStep("2", {|oPanel| getFiltro( oPanel, @aPergCP400 )})
   oStep2:SetStepDescription(STR0133) // "Opções de filtro"
   oStep2:SetPrevTitle(STR0134) // "Voltar"
   oStep2:SetNextTitle(STR0130) // "Avançar"
   oStep2:SetNextAction({|| VldNext(cAliasSB1, cFieldMark, cMarcaSB1, @aPergCP400) })
   oStep2:SetCancelAction({|| MsgYesNo(STR0131, STR0132) }) // "Deseja cancelar a geração de catálogo de produto?" ### "Geração de Catálogo de Produto"

   oStep3 := oStepWiz:AddStep("3", {|oPanel| ViewResul( oPanel, cAliasSB1, cFieldMark)})
   oStep3:SetStepDescription(STR0135) // "Resultado"
   oStep3:SetNextTitle(STR0136) // "Fechar"
   oStep3:SetNextAction({|| .T. })
   oStep3:SetPrevTitle(STR0233) // "Exportar"
   oStep3:SetPrevAction({|| geraExcel(cAliasSB1) })
   oStep3:SetCancelWhen({|| .F. })
   oStepWiz:Activate()
   oStepWiz:Destroy()

   // deleta os arquivos temporarios, tem que ser após devido para evitar errorlog ao destruir os objetos
   eraseTmp()

   FwFreeObj( oStepWiz )

return

/*
Função     : ViewIntrod
Objetivo   : Função apresentar a introdução do wizard
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewIntrod(oPanel)
   local aCoords    := {}
   local cIntrod    := "" 
   local oSay       := nil
   local oFont      := nil

   aCoords := FWGetDialogSize(oPanel)
   cIntrod := STR0137 // "Esta rotina tem como objetivo verificar os itens importados que não possuem Catálogo de Produtos e sugerir a sua criação."
   oFont := TFont():New('Courier new',,-16,.T.)
   oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
   oSay:CtrlRefresh()
   oSay:SetTextAlign( 0, 0 )

return

/*
Função     : getFiltro
Objetivo   : Função para apresentar o pergunte que é utilizado para o filtro de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getFiltro(oPanel, aPergCP400)
   default aPergCP400 := {}
   Pergunte('EICCP400',.T.,,,oPanel,,@aPergCP400)
return

/*
Função     : VldNext
Objetivo   : Função para validar os proximos passos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function VldNext(cAliasSB1, cFieldMark, cMarcaSB1, aPergCP400)
   local lRet       := .F.
   local cPOIni     := ""
   local cPOFim     := ""
   local dDtPOIni   := ctod("")
   local dDtPOFim   := ctod("")
   local cProdIni   := ""
   local cProdFim   := ""
   local cNCMIni    := ""
   local cNCMFim    := ""
   local cEXNCMIni  := ""
   local cEXNCMFim  := ""
   local cProdSemPed:= ""
   local cCodImport := ""
   local cCnpj      := ""

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default aPergCP400 := {}

   cPOIni     := MV_PAR01
   cPOFim     := MV_PAR02
   dDtPOIni   := MV_PAR03
   dDtPOFim   := MV_PAR04
   cProdIni   := MV_PAR05
   cProdFim   := MV_PAR06
   cNCMIni    := MV_PAR07
   cNCMFim    := MV_PAR08
   cEXNCMIni  := MV_PAR09
   cEXNCMFim  := MV_PAR10
   if AvFlags("TRIBUTACAO_DUIMP")
      cProdSemPed := alltrim(Str(MV_PAR11))
      cCodImport := MV_PAR12
      cCnpj := MV_PAR13
   endif
   __SaveParam('EICCP400', aPergCP400)

   begin sequence

   if empty(MV_PAR06)
      MsgInfo(STR0138, STR0002 ) // "Informe o intervalo de produtos para realizar o filtro." #### "Atenção"
      break
   endif

   lRet := getProds(cAliasSB1, cFieldMark, cMarcaSB1, cPOIni, cPOFim, dDtPOIni, dDtPOFim, cProdIni, cProdFim, cNCMIni, cNCMFim, cEXNCMIni, cEXNCMFim, cProdSemPed, cCodImport, cCnpj)
   if !lRet
      MsgInfo(STR0139, STR0002 ) // "Não foi encontrado nenhum produto." #### "Atenção"
   else
      lRet := ViewProds(cAliasSB1, cFieldMark, cMarcaSB1)
   endif

   end sequence

return lRet

/*
Função     : getProds
Objetivo   : Função para realizar a query, de acordo com os parametros (Pergunte - EICCP400)
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getProds(cAliasSB1, cFieldMark, cMarcaSB1, cPOIni, cPOFim, dDtPOIni, dDtPOFim, cProdIni, cProdFim, cNCMIni, cNCMFim, cEXNCMIni, cEXNCMFim, cProdSemPed, cCodImport, cCnpj)
   local lRet       := .F.
   local cAliasQry  := ""
   local cQuery     := ""
   local oQuery     := nil
   local aFilInfos  := {}
   local nFil       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default cPOIni     := ""
   default cPOFim     := ""
   default dDtPOIni   := ctod("")
   default dDtPOFim   := ctod("")
   default cProdIni   := ""
   default cProdFim   := ""
   default cNCMIni    := ""
   default cNCMFim    := ""
   default cEXNCMIni  := ""
   default cEXNCMFim  := ""
   default cProdSemPed:= ""
   default cCodImport := " "
   default cCnpj      := " "

   cAliasQry := getNextAlias()

   aFilInfos := {}
   If cProdSemPed == "1"
      cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_ RECSB1, '" + cCodImport + "' W2_IMPORT , '" + cCnpj + "' YT_CGC "
      cQuery += " FROM " + RetSqlName('SB1') + " SB1 "
      cQuery += " LEFT JOIN " + RetSqlName('EKA') + " EKA ON EKA.D_E_L_E_T_ = ' ' AND EKA.EKA_FILIAL = '" + xFilial("EKA") + "' AND EKA_PRDREF = SB1.B1_COD "
      cQuery += if( isMultFil(), " AND EKA.EKA_FILORI = '" + xFilial("SB1") + "' ", "")
      cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND SB1.B1_MSBLQL <> '1' "
      cQuery += " AND SB1.B1_IMPORT = 'S' AND EKA.EKA_COD_I IS NULL "

      aAdd( aFilInfos , xFilial("SB1"))
      cQuery += " AND SB1.B1_FILIAL = ? "

      If cProdIni == cProdFim
         aAdd( aFilInfos , cProdIni)
         cQuery += " AND SB1.B1_COD = ? "
      Else
         aAdd( aFilInfos , cProdIni)
         aAdd( aFilInfos , cProdFim)
         cQuery += " AND SB1.B1_COD >= ? "
         cQuery += " AND SB1.B1_COD <= ? "
      EndIf

      if !empty(cNCMIni) .or. !empty(cNCMFim)
         if cNCMIni == cNCMFim
            aAdd( aFilInfos , cNCMIni)
            cQuery += " AND SB1.B1_POSIPI = ? "
         else
            aAdd( aFilInfos , cNCMIni)
            aAdd( aFilInfos , cNCMFim)
            cQuery += " AND SB1.B1_POSIPI >= ? "
            cQuery += " AND SB1.B1_POSIPI <= ? "
         endif
      endif

      if !empty(cEXNCMIni) .or. !empty(cEXNCMFim)
         if cEXNCMIni == cEXNCMFim
            aAdd( aFilInfos , cEXNCMIni)
            cQuery += " AND SB1.B1_EX_NCM = ? "
         else
            aAdd( aFilInfos , cEXNCMIni)
            aAdd( aFilInfos , cEXNCMFim)
            cQuery += " AND SB1.B1_EX_NCM >= ? "
            cQuery += " AND SB1.B1_EX_NCM <= ? "
         endif
      endif

      cQuery += " ORDER BY SB1.B1_COD "

   Else
      // ao confirmar a parametrização, o sistema deverá verificar em todos os Purchases Orders emitidos no período (data do PO) os produtos que não possuem catálogo de produtos (relação de produtos) e que se enquadram na parametrização informada; 
      // os produtos que estão bloqueados no cadastro (SB1) devem ser desconsiderados;
      cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_ RECSB1, SW2.W2_IMPORT, SYT.YT_CGC "
      cQuery += " FROM " + RetSqlName('SW3') + " SW3 "
      cQuery += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SW3.W3_COD_I AND SB1.B1_MSBLQL <> '1' "
      cQuery += " INNER JOIN " + RetSqlName('SW2') + " SW2 ON SW2.D_E_L_E_T_ = ' ' AND SW2.W2_FILIAL = '" + xFilial("SW2") + "' AND SW2.W2_PO_NUM = SW3.W3_PO_NUM "
      cQuery += " LEFT JOIN " + RetSqlName('SYT') + " SYT ON SYT.D_E_L_E_T_ = ' ' AND SYT.YT_FILIAL = '" + xFilial("SYT") + "' AND SYT.YT_COD_IMP = SW2.W2_IMPORT "
      cQuery += " LEFT JOIN " + RetSqlName('EKA') + " EKA ON EKA.D_E_L_E_T_ = ' ' AND EKA.EKA_FILIAL = '" + xFilial("EKA") + "' AND EKA_PRDREF = SW3.W3_COD_I "
      cQuery += if( isMultFil(), " AND EKA.EKA_FILORI = '" + xFilial("SB1") + "' ", "")
      cQuery += " WHERE SW3.D_E_L_E_T_ = ' ' AND EKA.EKA_COD_I IS NULL "

      aAdd( aFilInfos , xFilial('SW3'))
      cQuery += " AND SW3.W3_FILIAL = ? "

      if cProdIni == cProdFim
         aAdd( aFilInfos , cProdIni)
         cQuery += " AND SW3.W3_COD_I = ? "
      else
         aAdd( aFilInfos , cProdIni)
         aAdd( aFilInfos , cProdFim)
         cQuery += " AND SW3.W3_COD_I >= ? "
         cQuery += " AND SW3.W3_COD_I <= ? "
      endif

      if !empty(cPOIni) .or. !empty(cPOFim)
         if cPOIni == cPOFim
            aAdd( aFilInfos , cPOIni)
            cQuery += " AND SW3.W3_PO_NUM = ? "
         else
            aAdd( aFilInfos , cPOIni)
            aAdd( aFilInfos , cPOFim)
            cQuery += " AND SW3.W3_PO_NUM >= ? "
            cQuery += " AND SW3.W3_PO_NUM <= ? "
         endif
      endif

      if !empty(dDtPOIni) .or. !empty(dDtPOFim)
         if dDtPOIni == dDtPOFim
            aAdd( aFilInfos , dDtPOIni)
            cQuery += " AND SW2.W2_PO_DT   = ? "
         else
            aAdd( aFilInfos , dDtPOIni)
            aAdd( aFilInfos , dDtPOFim)
            cQuery += " AND SW2.W2_PO_DT >= ? "
            cQuery += " AND SW2.W2_PO_DT <= ? "
         endif
      endif

      if !empty(cNCMIni) .or. !empty(cNCMFim)
         if cNCMIni == cNCMFim
            aAdd( aFilInfos , cNCMIni)
            cQuery += " AND SW3.W3_TEC = ? "
         else
            aAdd( aFilInfos , cNCMIni)
            aAdd( aFilInfos , cNCMFim)
            cQuery += " AND SW3.W3_TEC >= ? "
            cQuery += " AND SW3.W3_TEC <= ? "
         endif
      endif

      if !empty(cEXNCMIni) .or. !empty(cEXNCMFim)
         if cEXNCMIni == cEXNCMFim
            aAdd( aFilInfos , cEXNCMIni)
            cQuery += " AND SW3.W3_EX_NCM = ? "
         else
            aAdd( aFilInfos , cEXNCMIni)
            aAdd( aFilInfos , cEXNCMFim)
            cQuery += " AND SW3.W3_EX_NCM >= ? "
            cQuery += " AND SW3.W3_EX_NCM <= ? "
         endif
      endif

      cQuery += " GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_, SW2.W2_IMPORT, SYT.YT_CGC "
      cQuery += " ORDER BY SB1.B1_COD "
   EndIf

   oQuery := FWPreparedStatement():New(cQuery)
   for nFil := 1 to len(aFilInfos)
      if valtype(aFilInfos[nFil]) == "D"
         oQuery:SetDate( nFil , aFilInfos[nFil] )
      else
         oQuery:SetString( nFil , aFilInfos[nFil] )
      endif
   next
   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasQry)
 
   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof())
      lRet := .T.
      LoadProd(cAliasQry, cAliasSB1, cFieldMark, cMarcaSB1)
   endif

   if !empty(cAliasQry) .and. select(cAliasQry) > 0
      (cAliasQry)->(dbCloseArea())
   endif

   fwFreeObj(oQuery)

return lRet

/*
Função     : LoadProd
Objetivo   : Função para carregar os produtos do resultado da query no arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function LoadProd(cAliasQry, cAliasSB1, cFieldMark, cMarcaSB1)
   local aStruct    := {}
   local nCpo       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   clearTmp(cAliasSB1)
   aStruct := (cAliasSB1)->(dbStruct())

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())

      reclock(cAliasSB1, .T.)
      for nCpo := 1 To Len(aStruct)
         if aStruct[nCpo][1] == cFieldMark
            (cAliasSB1)->&(cFieldMark) := cMarcaSB1
         elseif aStruct[nCpo][1] == "RESULTADO"
            (cAliasSB1)->&(aStruct[nCpo][1]) := "0"
         elseif !(aStruct[nCpo][1] $ "RECNO||RETORNO")
            (cAliasSB1)->&(aStruct[nCpo][1]) := (cAliasQry)->&(aStruct[nCpo][1])
         endif
      next nCpo
      (cAliasSB1)->(MsUnlock())

      (cAliasQry)->(dbSkip())
   end

   (cAliasSB1)->(dbGoTop())

return

/*
Função     : createTmp
Objetivo   : Função para criação do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function createTmp()
   local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
   local cAliasTmp  := ""
   local cFieldMark := ""
   local aSemSX3    := {}
   local cArqTab    := ""
   local cIndExt    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   // ---- Criação da tabela temporaria para a funcionalidade Gerar Catalogo de Produtos
   cAliasTmp := CP400_PROD
   if Select(cAliasTmp) == 0
      cFieldMark := "REG_MARCA"
      aCampos := {}
      aSemSX3 := {}

      aAdd(aSemSX3, {"B1_COD"    , getSX3Cache( "B1_COD"   , "X3_TIPO"), getSX3Cache( "B1_COD"   , "X3_TAMANHO"), getSX3Cache( "B1_COD"   , "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_DESC"   , getSX3Cache( "B1_DESC"  , "X3_TIPO"), getSX3Cache( "B1_DESC"  , "X3_TAMANHO"), getSX3Cache( "B1_DESC"  , "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_POSIPI" , getSX3Cache( "B1_POSIPI", "X3_TIPO"), getSX3Cache( "B1_POSIPI", "X3_TAMANHO"), getSX3Cache( "B1_POSIPI", "X3_DECIMAL") })
      aAdd(aSemSX3, {"B1_EX_NCM" , getSX3Cache( "B1_EX_NCM", "X3_TIPO"), getSX3Cache( "B1_EX_NCM", "X3_TAMANHO"), getSX3Cache( "B1_EX_NCM", "X3_DECIMAL") })
      aAdd(aSemSX3, {"W2_IMPORT" , getSX3Cache( "W2_IMPORT", "X3_TIPO"), getSX3Cache( "W2_IMPORT", "X3_TAMANHO"), getSX3Cache( "W2_IMPORT", "X3_DECIMAL") })
      aAdd(aSemSX3, {"YT_CGC"    , getSX3Cache( "YT_CGC"   , "X3_TIPO"), getSX3Cache( "YT_CGC", "X3_TAMANHO")   , getSX3Cache( "YT_CGC"   , "X3_DECIMAL") })
      aAdd(aSemSX3, {"RESULTADO" , "C"                                 , 01                                     , 0                                       })
      aAdd(aSemSX3, {"RETORNO"   , "M"                                 , 250                                    , 0                                       })
      aAdd(aSemSX3, {"RECNO"     , "N"                                 , 10                                     , 0                                       })
      aAdd(aSemSX3, {"RECSB1"    , "N"                                 , 10                                     , 0                                       })
      aAdd(aSemSX3, {cFieldMark  , "C"                                 , 01                                     , 0                                       })

      cArqTab := e_criatrab(, aSemSX3, cAliasTmp )

      cIndExt := TEOrdBagExt()
      E_IndRegua( cAliasTmp , cArqTab+cIndExt, "B1_COD")

      cIndex1 := e_create()
      E_IndRegua( cAliasTmp , cIndex1+cIndExt, cFieldMark)

      SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt)

      aAdd( _aTabsTmp, {cAliasTmp, cArqTab, cIndex1, cIndex2 })
   endif
   // ------------------------------------------------------------------------

   if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return

/*
Função     : eraseTmp
Objetivo   : Função para exclusão do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function eraseTmp()
   local nTab       := 0
   local cAliasTmp  := ""
   local cTabArq    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   for nTab := 1 to len(_aTabsTmp)
      cAliasTmp := _aTabsTmp[nTab][ALIAS_TEMP]
      cTabArq := _aTabsTmp[nTab][ARQ_TAB]
      cIndex1 := if(empty(_aTabsTmp[nTab][INDEX1]),nil,_aTabsTmp[nTab][INDEX1])
      cIndex2 := if(empty(_aTabsTmp[nTab][INDEX2]),nil,_aTabsTmp[nTab][INDEX2])
      if select(cAliasTmp) > 0
         (cAliasTmp)->(E_EraseArq(cTabArq, cIndex1, cIndex2))
      endif
   next

   aSize(_aTabsTmp, 0)
   _aTabsTmp := {}

return

/*
Função     : clearTmp
Objetivo   : Função limpeza do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function clearTmp(cAliasTmp)
   default cAliasTmp := ""

   if( !empty(cAliasTmp), if( select(cAliasTmp)  > 0, AvZap(cAliasTmp), createTmp()), nil)

return

/*
Função     : ViewProds
Objetivo   : Função para apresentar o FwMarkBrowse com os produtos para geração do catálogo de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewProds(cAliasSB1, cFieldMark, cMarcaSB1)
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}
   local bMarcar    := { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1 ), oMrkBrSB1:oBrowse:Refresh() }
   local oMrkBrSB1  := nil
   local oDlgProd   := nil
   local nOpc       := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   aRotina := {} 

   aStruct := (cAliasSB1)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||RECSB1||RESULTADO||RETORNO"))
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
         aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
      endif
   next nCpo 

   fwFreeObj(oDlgProd)
   oDlgProd := FWDialogModal():New()
   oDlgProd:setEscClose(.F.)
   oDlgProd:enableAllClient()
   oDlgProd:setTitle( OemTOAnsi(STR0140) ) // "Geração em lote de catalogo de produtos"
   oDlgProd:enableFormBar(.F.)
   oDlgProd:SetCloseButton( .F. )
   oDlgProd:createDialog()

   fwFreeObj(oMrkBrSB1)
   oMrkBrSB1 := FWMarkBrowse():New()
   oMrkBrSB1:SetFieldMark( cFieldMark )
   oMrkBrSB1:SetOwner( oDlgProd:getPanelMain() )
   oMrkBrSB1:SetAlias( cAliasSB1 )
   oMrkBrSB1:SetAllMark( bMarcar )
   oMrkBrSB1:SetMark( cMarcaSB1, cAliasSB1, cFieldMark )
   oMrkBrSB1:SetColumns( aColumns )
   oMrkBrSB1:SetMenuDef("")
   oMrkBrSB1:SetTemporary(.T.)
   oMrkBrSB1:DisableFilter()
   oMrkBrSB1:DisableConfig()
   oMrkBrSB1:DisableReport()
   oMrkBrSB1:DisableDetails()
   oMrkBrSB1:AddButton( OemTOAnsi(STR0141), { || if( validPrds(cAliasSB1, cFieldMark, cMarcaSB1) , (nOpc := 1 , oDlgProd:DeActivate()), )},, 2 ) // "Confirmar"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0142), { || if( MsgYesNo(STR0145,STR0132), oDlgProd:DeActivate(),)},, 2 ) // "Cancelar" #### "Deseja cancelar a operação?" ### "Geração de Catálogo de Produto"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0143), { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1, "M" ), oMrkBrSB1:oBrowse:Refresh()},, 2 ) // "Marcar todos"
   oMrkBrSB1:AddButton( OemTOAnsi(STR0144), { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1, "D" ), oMrkBrSB1:oBrowse:Refresh()},, 2 ) // "Desmarcar todos"
   oMrkBrSB1:Activate()

   oDlgProd:Activate()

   lRet := nOpc == 1

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return lRet

/*
Função     : MarcarProd
Objetivo   : Função para marcar os produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function MarcarProd(cAliasSB1, cFieldMark, cMarcaSB1, cOpc )
   local cMarca     := ""
   local lMarcados  := .T.
   local nPosSB1    := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"
   default cOpc       := ""

   nPosSB1 := (cAliasSB1)->(recno())

   if empty(cOpc)
      (cAliasSB1)->(dbGoTop())
      while (cAliasSB1)->(!eof())
         lMarcados := !empty((cAliasSB1)->&(cFieldMark))
         if !lMarcados
            exit
         endif
         (cAliasSB1)->(dbSkip())
      end
   endif

   cMarca := if( empty(cOpc), if( lMarcados, " ", cMarcaSB1), if(cOpc=="M", cMarcaSB1, " "))

   (cAliasSB1)->(dbGoTop())
   while (cAliasSB1)->(!eof())
      reclock(cAliasSB1,.F.)
      (cAliasSB1)->&(cFieldMark) := cMarca
      (cAliasSB1)->(msUnLock())
      (cAliasSB1)->(dbSkip())
   end

   (cAliasSB1)->(dbGoTo(nPosSB1))

return .T.

/*
Função     : validPrds
Objetivo   : Função para validar ao confirmar a tela de marcação de produtos
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function validPrds(cAliasSB1, cFieldMark, cMarcaSB1)
   local lRet       := .F.
   local aArea      := {}

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"
   default cMarcaSB1  := "X"

   aArea := (cAliasSB1)->(getArea())
      (cAliasSB1)->(dbSetOrder(2))
      lRet := (cAliasSB1)->(dbSeek(cMarcaSB1))
   RestArea(aArea)

   if !lRet
      MsgInfo(STR0146, STR0002 ) // "Marque ao menos um produto para criação do catálogo de produto." #### "Atenção"
   else
      lRet := MsgYesNo(STR0147, STR0132) // "Deseja processar a inclusão dos catálogos de produtos?" #### "Geração de Catálogo de Produto"
   endif

return lRet

/*
Função     : ViewResul
Objetivo   : Função para o resultado final do processamento
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function ViewResul(oPanel, cAliasSB1, cFieldMark)
   local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   local oResult    := nil
   local oProc      := nil
   local nCpo       := 0
   local aStruct    := {}
   local aColumns   := {}

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"

   (cAliasSB1)->(dbGoTop())

   aRotina := {}
   aStruct := (cAliasSB1)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||RECSB1||RESULTADO"))
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
         if aStruct[nCpo][1] == "RETORNO"
            aColumns[Len(aColumns)]:SetTitle("Mensagem")
         else            
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
         endif
      endif
   next nCpo 

   fwFreeObj(oResult)
   aRotina := {}
   oResult := FWmBrowse():New()
   oResult:SetProfileID( 'RESULTADO' )
   oResult:SetDataTable()
   oResult:SetOwner( oPanel )
   oResult:SetAlias( cAliasSB1 )
   oResult:AddLegend("RESULTADO == '0' ","BR_AMARELO",STR0148) // "Pendente de processamento"
   oResult:AddLegend("RESULTADO == '1' ","ENABLE",STR0149) // "Inclusão realizada com sucesso"
   oResult:AddLegend("RESULTADO == '2' ","DISABLE",STR0150) // "Falha na inclusão"
   oResult:SetColumns( aColumns )
   oResult:SetMenuDef( "" )
   oResult:SetFilterDefault(" " + cFieldMark + " <> ' ' ")
   oResult:DisableFilter()
   oResult:DisableConfig()
   oResult:DisableReport()
   oResult:DisableDetails()
   oResult:Activate()

   oProc := EasyProgress():New(.F.)
   oProc:SetProcess({|| PrcCatProd( cAliasSB1, cFieldMark, @oResult, @oProc)}, STR0151) // "Incluindo catálogo de produtos... "
   oProc:Init()  

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return

/*
Função     : PrcCatProd
Objetivo   : Função para realizar a chamada da função do execauto EICCP400
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function PrcCatProd(cAliasSB1, cFieldMark, oBrowse, oProc)
   local cCodChave  := ""
   local cMsgError  := ""
   local nQtdInt    := 0
   local nRecno     := 0

   default cAliasSB1  := CP400_PROD
   default cFieldMark := "REG_MARCA"

   nQtdInt := EasyQryCount("SELECT B1_COD FROM " + TETempName(cAliasSB1) + " WHERE D_E_L_E_T_= ' ' AND " + cFieldMark + " <> ' ' " )

   (cAliasSB1)->(dbGoTop())
   oProc:SetRegua(nQtdInt)
   while (cAliasSB1)->(!eof())
      nRecno := (cAliasSB1)->(recno())

      if !empty((cAliasSB1)->&(cFieldMark))
         cMsgError := ""

         cCodChave := incCatProd(@cMsgError, (cAliasSB1)->B1_COD, (cAliasSB1)->W2_IMPORT, (cAliasSB1)->YT_CGC, (cAliasSB1)->RECSB1 )
         reclock(cAliasSB1,.F.)
         if !empty(cCodChave)
            (cAliasSB1)->RESULTADO := "1"
            (cAliasSB1)->RETORNO := cCodChave
         else
            (cAliasSB1)->RESULTADO := "2"
            (cAliasSB1)->RETORNO := cMsgError
         endif
         (cAliasSB1)->(msUnLock())
         oProc:IncRegua()
         oBrowse:Refresh()
      endif

      (cAliasSB1)->(dbgoto(nRecno))
      (cAliasSB1)->(dbSkip())
   end

   oProc:Refresh()
   oBrowse:Refresh(.T.)
   (cAliasSB1)->(dbGoTop())

return .T.

/*
Função     : incCatProd
Objetivo   : Função que realiza a inclusão do catalogo de produto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function incCatProd(cMsgError, cProduto, cImport, cCnpj, nRecSB1)
   local cCodCat    := ""
   local oModelo    := nil
   local oModEK9    := nil
   local lOk        := .F.
   local xError     := nil
   local oStruEK9   := nil
   local oStruEKB   := nil

   default cMsgError := ""
   default cProduto  := ""
   default cImport   := ""
   default cCnpj     := ""

   cMsgError := STR0155 // "Falha ao carregar o modelo"
   oModelo := FwLoadModel("EICCP400")
   oModelo:SetOperation(MODEL_OPERATION_INSERT)
   if oModelo:Activate()

      cMsgError := ""
      oModEK9 := oModelo:getModel("EK9MASTER")
      if empty(cImport)
         oStruEK9 := oModEK9:getStruct()
         oStruEK9:SetProperty('EK9_CNPJ'     , MODEL_FIELD_OBRIGAT, .F. )
         oStruEK9:SetProperty('EK9_PRDREF'   , MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ))

         oModEKB := oModelo:getModel("EKBDETAIL")
         oStruEKB := oModEKB:getStruct()
         oStruEKB:SetProperty('EKB_CODFAB'   , MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, '.T.' ))
      endif

      SB1->(DbGoTo(nRecSB1))
      lOk := if( !empty(cImport), oModEK9:setValue( "EK9_IMPORT", cImport), (if( !empty(cCnpj), oModEK9:setValue( "EK9_CNPJ", substr(cCnpj, 1, getSX3Cache("EK9_CNPJ", "X3_TAMANHO")) ), .T.)) )
      lOk := lOk .and. oModEK9:setValue( "EK9_PRDREF", cProduto)
      lOk := lOk .and. oModelo:VldData()
      lOk := lOk .and. oModelo:CommitData()
      cMsgError := if( !lOk ,;
         ( RollbackSx8(),;
            xError := oModelo:GetErrorMessage(), ;
            if( valtype(xError) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 ,;
            STR0153 + ": " + alltrim(allToChar( xError[6])) + " - " + if( !empty(xError[7]) , STR0154 + ": " + alltrim(allToChar( xError[7] )), "") , "") );
         ),;
         "") // "Problema" ### "Solução"
      if lOk
         cCodCat := STR0152 + ": " + alltrim(oModEK9:getValue("EK9_COD_I")) // "Código chave gerado
      endif
      oModelo:deactivate()
   endif

   fwFreeObj(oModEK9)
   fwFreeObj(oModelo)

return cCodCat

/*
Função     : isExecAuto
Objetivo   : Função que indica se é execauto
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function isExecAuto(oView)
   local lRet := .F.
   default oView := FwViewActive()
   lRet := FwIsInCallStack("incCatProd") .or. FwIsInCallStack("VldAtr") .or. FwIsInCallStack("CP403ImpXls") .or. FwIsInCallStack("CP404ImpArq") .or. oView == nil
return lRet

/*
Função     : CP400CBox
Objetivo   : Função chamada no X3_CBOX dos campos EK9_STATUS/ EKD_STATUS
Retorno    : Retorna a lista de Status.
Autor      : Tiago Tudisco
Data/Hora  : Março/2023
Obs.       :
*/
Function CP400CBox(cCampo)
Local cRet  := ""

Default cCampo:= Alltrim(ReadVar())
Do Case
   Case cCampo == "EK9_STATUS"
      cRet := STR0160//"1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Bloqueado;5=Registrado Manualmente;6=Registrado (pendente: fabricante/ país)"
   Case cCampo == "EKD_STATUS"
      cRet := STR0161//"1=Integrado;2=Pendente de Integração;3=Obsoleto;4=Falha de integração;5=Integrado(pendente: fabricante/ país);6=Registrado Manualmente"
   Case cCampo == "EIJ_STATUS"
      cRet := STR0237 // "1=Registrado;2=Pendente Registro;3=Existe uma versão posterior pendente de retificação;4=Bloqueado;5=Registrado Manualmente;5=Existe versão posterior com o status Registrado;6=Existe versão posterior com o status Registrado"
EndCase

Return cRet

/*/{Protheus.doc} CP400CBSta
   @type  Function
   @author Tiago Tudisco
   @since 19/04/2023
   @version v001
   @param cCampo - Campo a ser verificado; cStatus - Número do Status no combobox
   @return Retorna a descrição contida no combobox
   /*/
Function CP400CBSta(cCampo, cStatus)
Local cRet := ""
Local aStatus
Local nPos
Local cTexto

aStatus := StrTokarr(CP400CBox(cCampo),";")
If (nPos := aScan(aStatus,{|x| Substr(x, 1, at("=", x)-1) == cStatus})) > 0
   cTexto := aStatus[nPos]
   cRet := Substr(cTexto, at("=", cTexto) + 1)
EndIf

Return Alltrim(cRet)

/*/{Protheus.doc} getLog
   Geração de log do catalogo de produto
   
   @type  Static Function
   @author user
   @since 16/08/2023
   @version version
   @param cMsg, caractere, Mensagem de log
          oLogView, objeto, objeto do MEMO do EECVIEW
   @return nulo
/*/
static function getLog(cMsg, oLogView, cLogInteg)
   default cMsg      := ""
   default cLogInteg := ""

   oLogView:appendText( cMsg )
   cLogInteg += cMsg
   oLogView:Refresh()
   oLogView:goEnd()
return

/*/{Protheus.doc} CP400Log
   Geração de log em pdf ou envio por email do catalogo de produto
   
   @type  Function
   @author user
   @since 16/08/2023
   @version version
   @param nenhum
   @return nulo
/*/
function CP400Log()
return EasyLogPrt("2")

/*/{Protheus.doc} isMultFil
   Função para retornar se a tabela EK9 é compartilhada, porem as tabelas SB1 e SA2 são exclusivas 

   @type  Static Function
   @author user
   @since 25/09/2023
   @version version
   @param nenhum
   @return lMultiFil, logico, verdadeiro se a tabela EK9 é compartilhada, porem as tabelas SB1 e SA2 são exclusivas 
   @example
   (examples)
   @see (links_or_references)
/*/
static function isMultFil()
   local cModoAcEK9 := ""
   local cModoAcSB1 := ""
   local cModoAcSA2 := ""

   if !isMemVar("lMultiFil") .or. lMultiFil == nil
      cModoAcEK9 := FWModeAccess("EK9",3)
      cModoAcSB1 := FWModeAccess("SB1",3)
      cModoAcSA2 := FWModeAccess("SA2",3)
      lMultiFil := cModoAcEK9 == "C" .and. ( cModoAcSB1 == "E" .and. cModoAcSA2 == "E" )
   endif

return lMultiFil

/*/{Protheus.doc} isRest
   Função para verificar se é via APIrest

   @type  Static Function
   @author user
   @since 25/09/2023
   @version version
   @param nenhum
   @return lIsRest, logico, verdadeiro se for via api REST
   @example
   (examples)
   @see (links_or_references)
/*/
static function IsRest()
   local lIsRest := .F.
   lIsRest := if(ExistFunc("EasyIsRest"), EasyIsRest(), .F.)
return lIsRest

/*/{Protheus.doc} PermAlt
   Função para verificar se é permitido a alteração de atributos ou demais informações

   @type  Static Function
   @author user
   @since 25/09/2023
   @version version
   @param oModelEK9, objeto, modelo da tabela EK9
          lAtributo, logico, verdadeiro verificar se é permitido a alteração dos atributos 
          lOutras, logico,  verdadeiro verificar se é permitido a alteração outras informações
   @return lOk, logico, verdadeiro se for é permitido a alteração dos atributos ou outras informações
   @example
   (examples)
   @see (links_or_references)
/*/
Static function PermAlt(oModelEK9, lAtributo, lOutras) 
   local lOk        := .T.
   local cPermite   := ""

   default lAtributo := .F.
   default lOutras   := .F.

   if AvFlags("PERMISSAO_CATALOGO_OPERADOR") .and. (lAtributo .or. lOutras)
      cPermite := if(valtype(oModelEK9) == "O", (if( lAtributo, oModelEK9:getValue("EK9_PERATR"), oModelEK9:getValue("EK9_PERALT"))), (if( lAtributo, EK9->EK9_PERATR, EK9->EK9_PERALT)))
      lOk := !(cPermite == "2")
   endif

return lOk

/*/{Protheus.doc} getDominios
   Função para retornar os dominios de um determinado atributo

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cNcm, caracter, código da NCM
          cAtributo, caracter, código do atributo
   @return aDominio, array, vetor com os dominios do atributo
   @example
   (examples)
   @see (links_or_references)
/*/
static function getDominios( cNcm, cAtributo )
   local aDominio   := {}

   default cNcm       := ""
   default cAtributo  := ""

   if !empty(cAtributo) .and. (EKH->(dbSeek(xFilial("EKH") + PadR("", len(EKH->EKH_NCM)) + cAtributo)) .or. EKH->(dbSeek(xFilial("EKH") + cNcm + cAtributo)))
      while EKH->(!eof()) .and. EKH->EKH_FILIAL == xFilial("EKH") .and. (empty(EKH->EKH_NCM) .or. EKH->EKH_NCM == cNcm) .AND. EKH->EKH_COD_I == cAtributo
         aAdd(aDominio,{EKH->EKH_COD_I,EKH->EKH_CODDOM,EKH->EKH_DESCRE,""})
         EKH->(dbSkip())
      enddo
   endif

return aDominio

/*/{Protheus.doc} GetAtribPr
   Função para retornar o atributo principal de um atributo condicionado

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cAtributo, caracter, código do atributo
          aNivel, array, vetor com todos os niveis em relação ao principal
   @return cAtrib, caracter, código do atributo principal
   @example
   (examples)
   @see (links_or_references)
/*/
static function GetAtribPr(cAtributo, cAtribSup, aNivel)
   local cAtrib := cAtributo
   local nAtrib := 0
   local lFind  := .F.

   default aNivel := {}

   aAdd( aNivel, cAtrib )
   lFind := empty(cAtribSup)
   while !lFind
      nAtrib := aScan( _aAtributos, { |X| X[1] == cAtrib .and. !empty(X[2])} ) 
      if nAtrib > 0
         aAdd( aNivel, _aAtributos[nAtrib][2] )
         cAtrib := _aAtributos[nAtrib][2]
      elseif aScan( _aAtributos, { |X| X[1] == cAtrib .and. empty(X[2])} ) > 0
         lFind := .T.
      endif
   end

return cAtrib

/*/{Protheus.doc} retOrdemAtrb
   Função para retornar a hierarquia de atributos

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cAtributo, caracter, código do atributo
   @return cOrdem, caracter, ordem do atributo
   @example
   (examples)
   @see (links_or_references)
/*/
static function retOrdemAtrb(cAtributo, cAtribSub)
   local cOrdem     := ""
   local nNivel     := 0
   local aNiveis    := {}

   GetAtribPr(cAtributo, cAtribSub, @aNiveis)
   cOrdem := ""
   for nNivel := len(aNiveis) to 1 step -1
      cOrdem += aNiveis[nNivel] + " -> "
   next
   cOrdem := substr(cOrdem,1, len(cOrdem)-4)

return cOrdem

/*/{Protheus.doc} loadCond
   Função para carregar os atributos condicionados

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cNcmEKG, caracter, código da NCM
          cCodCatalog, caracter, código do catalogo
          cCodAtrib, caracter, código do atributo
          cAtrPrinc, caracter, código do atributo principal
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadCond(oModelEKC, nOperation, cNcmEKG, cCodCatalog, cModalid, cCodAtrib, cAtrPrinc, lAtbPrcBlq)
   local cValorAtrb  := ""
   local nPosAtrib   := 0
   local cForma      := ""
   local cMultVal    := ""
   local aValores    := {}
   local cValor      := ""
   local nValores    := 0
   local aDominio    := {}
   local nPosDom     := 0

   // Pega o valor do atributo principal 
   if EKC->(dbSeek( xFilial("EKC") + cCodCatalog + cCodAtrib + cAtrPrinc )) .and. !empty(EKC->EKC_VALOR)
      cValorAtrb := alltrim(EKC->EKC_VALOR)

      nPosAtrib := aScan( _aAtributos , { |X| X[1] == cCodAtrib .and. X[2] == cAtrPrinc })
      if nPosAtrib > 0
         EKG->(dbGoTo(_aAtributos[nPosAtrib][3]))
         cForma := alltrim(EKG->EKG_FORMA)
         cMultVal := EKG->EKG_MULTVA
         aValores := if( cMultVal == "1", strTokArr( cValorAtrb, ";" ) , {cValorAtrb})

         if cForma == "BOOLEANO"
            cValor := if(aValores[1]=="1","SIM",if(aValores[1]=="2","NAO",""))

         elseif cForma == "LISTA_ESTATICA"
            cValor := ""
            aDominio := getDominios(cNcmEKG, cCodAtrib)
            for nValores := 1 to len(aValores)
               nPosDom := aScan( aDominio, {|X| alltrim(X[2]) == aValores[nValores] } )
               if nPosDom > 0
                  cValor += alltrim( aDominio[nPosDom][2] ) + " - " + alltrim(aDominio[nPosDom][3]) + " ;"
               endif
            next nValores
            cValor := substr( cValor, 1, len(cValor)-1)
            aSize(aDominio, 0)
            aDominio := {}
         endif

         if oModelEKC:SeekLine({{"EKC_COD_I", cCodCatalog} ,{"EKC_CODATR", cCodAtrib },{"EKC_CONDTE", cAtrPrinc}}, .T.)
            oModelEKC:LoadValue("EKC_VLEXIB",SubSTR(cValor,1,getSx3Cache("EKC_VLEXIB", "X3_TAMANHO")))
            if lAtbPrcBlq
               oModelEKC:LoadValue("EKC_STATUS" , STR0007) // "Bloqueado"
               if nOperation != MODEL_OPERATION_VIEW
                  oModelEKC:deleteLine()
               endif
            endif
         endif

         if nOperation != MODEL_OPERATION_VIEW
            nPosAtrib := aScan( _aAtributos , { |X| X[2] == cCodAtrib })
            while nPosAtrib > 0
               EKG->(dbGoTo(_aAtributos[nPosAtrib][3]))
               if EKG->(recno()) == _aAtributos[nPosAtrib][3]
                  if cForma == "BOOLEANO"
                     InfCond(oModelEKC, cNcmEKG, cCodCatalog, cCodAtrib, aValores[1], cForma, cModalid, lAtbPrcBlq)

                  elseif cForma == "LISTA_ESTATICA"
                     for nValores := 1 to len(aValores)
                        InfCond(oModelEKC, cNcmEKG, cCodCatalog, cCodAtrib, alltrim( aValores[nValores] ), cForma, cModalid, lAtbPrcBlq)
                     next nValores

                  endif

               endif
               nPosAtrib := aScan( _aAtributos , { |X| X[2] == cCodAtrib }, nPosAtrib+1 )
            end
         endif
      endif

   endif

return

/*/{Protheus.doc} InfCond
   Função para carregar para incluir ou atualizar os atributos condicionados

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cNcmEKG, caracter, código da NCM
          cCodCatalog, caracter, código do catalogo
          cCodAtrib, caracter, código do atributo
          cValor, caracter, valor do atributo
          cForma, caracter, forma do atributo
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function InfCond(oModelEKC, cNcmEKG, cCodCatalog, cCodAtrib, cValor, cForma, cModalid, lAtbPrcBlq)
   local cOrdem := ""
   default lAtbPrcBlq := .F.

   if !empty(cValor) .and. !empty(EKG->EKG_CONDIC) .and. VldAtrCond(alltrim(EKG->EKG_CONDIC), cForma, alltrim(cValor))
      cOrdem := retOrdemAtrb(EKG->EKG_COD_I, cCodAtrib)
      if !oModelEKC:SeekLine({{"EKC_COD_I", cCodCatalog} ,{"EKC_CODATR", EKG->EKG_COD_I },{"EKC_CONDTE", cCodAtrib }}, .T.)
         if CP400Status(EKG->EKG_INIVIG,EKG->EKG_FIMVIG) != "EXPIRADO" .and. ( (cModalid == "1" .and. "7" $ alltrim(EKG->EKG_CODOBJ)) .or. !(cModalid == "1") )  .and. ( empty(EKG->EKG_MODALI) .or. EKG->EKG_MODALI == "3" .or. cModalid == EKG->EKG_MODALI )
            AddLine(oModelEKC,  , .T.)
            loadInfAtr(oModelEKC, "EKG", .T., cCodCatalog, cOrdem )  
         endif
      else
         oModelEKC:LoadValue("ATRIB_ORDEM", cOrdem)
      endif

      if lAtbPrcBlq
         oModelEKC:LoadValue("EKC_STATUS" , STR0007) // "Bloqueado"
         oModelEKC:deleteLine()
      endif

   endif
return

/*/{Protheus.doc} delCond
   Função para deletar os subs atributos

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cAtributo, caracter, código do atributo
          aExcAtrib, vetor, array com os atributos deletados
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function delCond(oModelEKC, cAtributo, aExcAtrib)
   local cOrdem   := ""
   local nPosCond := 0
   local lExc     := .F.

   nPosCond := aScan( _aAtributos , { |X| X[2] == cAtributo })
   while nPosCond > 0
      cOrdem   := retOrdemAtrb(_aAtributos[nPosCond][1], cAtributo)
      lExc := oModelEKC:SeekLine({{"ATRIB_ORDEM", cOrdem}}, .T.) 
      if lExc .and. aScan( aExcAtrib, { |X| X[1] == oModelEKC:getValue("EKC_CONDTE") .and. X[2] == oModelEKC:getValue("EKC_CODATR") } ) == 0
         aAdd( aExcAtrib, {oModelEKC:getValue("EKC_CONDTE"), oModelEKC:getValue("EKC_CODATR"), cOrdem} )
         delCond(oModelEKC, oModelEKC:getValue("EKC_CODATR"), @aExcAtrib)
      endif
      nPosCond := aScan( _aAtributos , { |X| X[2] == cAtributo }, nPosCond+1)
   end

return 

/*/{Protheus.doc} getAtrBlq
   Função para verificar o atributo principal se está bloqueado

   @type  Static Function
   @author user
   @since 27/12/2023
   @version version
   @param cAtribSup, caracter, código do atributo superior
          nPosAtrib, numerico, posição do atributo
   @return nil
   @example
   (examples)
   @see (links_or_references)
/*/
static function getAtrBlq(cAtribSup, nPosAtrib)
   local lBloq      := .F.
   local cAtribPrc  := ""
   local nPos       := 0

   if nPosAtrib > 0 
      lBloq := _aAtributos[nPosAtrib][5]
      if !lBloq .and. !empty(cAtribSup)
         nPos := aScan( _aAtributos, { |X| X[1] == cAtribSup .and. !empty(X[2])} ) 
         while nPos > 0 .and. !lBloq
            cAtribPrc := _aAtributos[nPos][2]
            lBloq := _aAtributos[nPos][5]
            nPos := aScan( _aAtributos, { |X| X[1] == cAtribPrc .and. !empty(X[2])} ) 
         end
         if !lBloq .and. nPos == 0
            nPos := aScan( _aAtributos, { |X| X[1] == cAtribPrc .and. empty(X[2])} ) 
            if nPos > 0 
               lBloq := _aAtributos[nPos][5]
            endif
         endif
      endif
   endif

return lBloq

/*
Função     : QryAttEKG
Objetivo   : Query para filtrar os atributos do EKG/EKH e montar os campos a ser enviados para o Angular.
Retorno    : cQuery - Retorna uma string com a query montada
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function QryAttEKG(lInclusao, cModEK9)
Local cQuery := ""

default cModEK9 := "1"

cQuery := " SELECT "
cQuery += "  EKG.EKG_NCM, EKG.EKG_COD_I, EKG_NOME, EKG_CODOBJ, EKG.EKG_FORMA, EKG.EKG_MODALI, EKG.EKG_OBRIGA, EKG_MSBLQL, "
cQuery += "  EKG.EKG_INIVIG, EKG.EKG_FIMVIG, EKG.EKG_TAMAXI, EKG_DECATR, EKG.EKG_CONDTE, EKG.EKG_MULTVA, R_E_C_N_O_ RECNO, "
cQuery += "    COALESCE((SELECT COUNT(EKH.EKH_COD_I) EKH_COD_I  "
cQuery += "              FROM " + RetSqlName("EKH") + " EKH "
cQuery += "              WHERE EKG.EKG_FILIAL     = EKH.EKH_FILIAL "
cQuery += "                AND (EKG.EKG_NCM    = EKH.EKH_NCM "
cQuery += "  	              OR EKH.EKH_NCM  = ' ') "
cQuery += "                AND EKG.EKG_COD_I  = EKH.EKH_COD_I "
cQuery += "  	            AND EKH.EKH_MSBLQL <> '1' "
cQuery += "                AND EKH.D_E_L_E_T_ = ' ' "
cQuery += "              GROUP BY EKH_COD_I), 0) TEM_DOMINIO "
cQuery += " FROM "
cQuery += "  " + RetSQLName("EKG") + " EKG "
cQuery += " WHERE "
cQuery += "  EKG.EKG_FILIAL = ? "
cQuery += "  AND EKG.EKG_NCM = ? "
if lInclusao
   cQuery += "  AND EKG.EKG_MSBLQL <> '1' "
EndIf
cQuery += "  AND ( EKG.EKG_MODALI = ' ' OR EKG.EKG_MODALI = '3' OR EKG.EKG_MODALI = ? ) " 
if (cModEK9 == "1") // somente para importação
   cQuery += "  AND EKG.EKG_CODOBJ like ? "
endif
cQuery += "  AND EKG.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY "
cQuery += "  EKG.EKG_CONDTE, "
cQuery += "  EKG.EKG_COD_I "

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
Parâmetros : cCodNcmEK9 - Código da NCM
             nOpc    - Operação a ser realizada (Inclusão, ALteração, Exclusão e Visualização)
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function loadAtPOUI(cCodNcmEK9, cModEK9, nOpc, lAlteraAt, lIntegra)
Local cQuery := QryAttEKG(nOpc == MODEL_OPERATION_INSERT, cModEK9)
Local oDePara:= TETypePOUI() //De para com os tipos de campos
Local nOrder := 0
Local oQuery
Local cAliasAtt
Local cAliasDom
Local oCampo
Local oDominio
Local oComposto := jsonObject():New()
Local oCondFilho
Local oAttCP
Local nPos
Local lComposto
Local lTemCondicao
Local cPOUIJson
Local cDivider := ""
Local aNames
Local cValueEKC
Local nI
Local nY
Local lSeekEKC

Default lAlteraAt := .T.
Default lIntegra  := .F.

If !Empty(cCodNcmEK9)
   //cDivider := getNcmDesc(cCodNcmEK9)

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1, xFilial('EKG'))
   oQuery:SetString(2, cCodNcmEK9)
   oQuery:SetString(3, cModEK9)
   if cModEK9 == "1" // somente para importação
      oQuery:SetString(4, '%7%')
   endif

   cQuery := oQuery:GetFixQuery()

   cAliasAtt := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasAtt)
   TcSetField(cAliasAtt, "EKG_INIVIG", "D", 8, 0)
   TcSetField(cAliasAtt, "EKG_FIMVIG", "D", 8, 0)

   oJsonAtt['listaAtributos'] := {}
   oJsonAtt['listaCompostos'] := {}
   oComposto['listaComposto'] := jSonObject():New()
   oCondicao['listaCondicao'] := jSonObject():New()

   While (cAliasAtt)->(!Eof())
      //If !("5" $ alltrim((cAliasAtt)->EKG_CODOBJ))
         oCampo := jsonObject():New()
         lComposto := .F.
         lTemCondicao := .F.
         nOrder++
         
         //Trata os dominios do atributo quando tiver
         If (cAliasAtt)->(TEM_DOMINIO) > 0 .and. !lIntegra
            cQuery := QryAttEKH()
            oQuery := FWPreparedStatement():New(cQuery)
            oQuery:SetString(1, xFilial('EKH'))
            oQuery:SetString(2, cCodNcmEK9)
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
            //aAdd(oComposto['listaComposto'], JsonObject():new())
            //nPos := Len(oComposto['listaComposto'])

            oAttCP := jsonObject():New()
            oAttCP['label']          := Alltrim((cAliasAtt)->(EKG_NOME))
            oAttCP['listaAtributosCompostos'] := {}

            oComposto['listaComposto'][Alltrim((cAliasAtt)->(EKG_COD_I))] := oAttCP

            FreeObj(oAttCP)
            lComposto := .T.
         EndIf

         If !Empty((cAliasAtt)->(EKG_CONDTE))
            EKG->(dbgoto((cAliasAtt)->(RECNO)))
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
            cargaCpoPO(@oCampo, cAliasAtt, nOrder == 1, oDePara, nOrder, cDivider, oDominio, nOpc, lIntegra)

            // Valida se tem condição para deixar invisivel ao inicializar
            If lTemCondicao
               oCampo['visible'] := .F.
            EndIf

            //Valida atributos bloqueados quando for alteração
            If nOpc != MODEL_OPERATION_INSERT
               lSeekEKC := .F.
               If !Empty(cValueEKC := getValorEKC(EK9->EK9_COD_I, Alltrim((cAliasAtt)->(EKG_COD_I)), @lSeekEKC))
                  If Alltrim((cAliasAtt)->(EKG_MULTVA)) == "1"
                     oCampo['value'] := strTokArr(CP400gtFrm(Alltrim((cAliasAtt)->(EKG_FORMA)), cValueEKC, 'advpl'), ";")
                  Else
                     oCampo['value'] := CP400gtFrm(Alltrim((cAliasAtt)->(EKG_FORMA)), cValueEKC, 'advpl')
                  EndIf
               EndIf
               If lTemCondicao .And. lSeekEKC
                  oCampo['visible'] := .T.
               EndIf
               If (cAliasAtt)->(EKG_MSBLQL) == "1" .And. !Empty(cValueEKC)
                  oCampo['disabled'] := .T.
                  oCampo['help']     := STR0220 //"Este atributo encontra-se bloqueado e será excluído."
               EndIf
               If oCampo['status'] == "EXPIRADO" .And. !Empty(cValueEKC)
                  oCampo['disabled'] := .T.
                  oCampo['help']     := STR0221 + DToC((cAliasAtt)->(EKG_FIMVIG)) + STR0222 //"Este atributo expirou em "####" e será excluído."
               EndIf
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
   
   oJsonAtt['ncmInfoDesc'] := getNcmDesc(cCodNcmEK9)
   oJsonAtt['ncmInfoCod']  := Transform(cCodNcmEK9, AvSX3("YD_TEC", AV_PICTURE))
   oJsonAtt['listaCondicao'] := oCondicao['listaCondicao']

   cPOUIJson := StrTran(oJsonAtt:toJson(), '".T."', 'true')
   cPOUIJson := StrTran(cPOUIJson, '".F."', 'false')

   If !lIntegra
      lPOUIOKLD := .F.
      oChannel:AdvPLToJS("listaAtributos", cPOUIJson)
      //WaitPOUI({|| lPOUIOKLD })
   EndIf
EndIf
Return

Static Function inComposto(oComposto, cAtributo)
Return !Empty(oComposto['listaComposto']:HasProperty(cAtributo))

/*
Função     : cargaCpoPO
Objetivo   : Montar objeto do campo a ser enviado para o Angular
Retorno    : -
Autor      : Tiago Tudisco
Data/Hora  : 06/03/2024
*/
Static Function cargaCpoPO(oCampo, cAliasAtt, lDivider, oDePara, nOrder, cDivider, oDominio, nOpc, lIntegra)
Local cTypeForm

If lIntegra //Objeto resumido apenas para uso na integração
   oCampo['property'] := Alltrim((cAliasAtt)->(EKG_COD_I))
   oCampo['label'   ] := Alltrim((cAliasAtt)->(EKG_NOME))   
Else
   oCampo['property'] := Alltrim((cAliasAtt)->(EKG_COD_I))
   oCampo['label'   ] := Alltrim((cAliasAtt)->(EKG_NOME))
   oCampo['visible'] := .T.
   oCampo['additionalHelpTooltip'] := oCampo['property']
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
   oCampo['mask']          :=  ""
   If cTypeForm == 'VALOR_MONETARIO' 
      oCampo['decimalsLength'] := (cAliasAtt)->(EKG_DECATR) //quando monetário já vem com a máscara de separação de milhar e decimal
   ElseIf cTypeForm == 'NUMERO_REAL' .or. cTypeForm == 'NUMERO_INTEIRO' 
      oCampo['decimalsLength'] := (cAliasAtt)->(EKG_DECATR)
      oCampo['thousandMaxlength'] := (cAliasAtt)->(EKG_TAMAXI)
      oCampo['maxLength'] := (cAliasAtt)->(EKG_TAMAXI) + (cAliasAtt)->(EKG_DECATR) + Int(((cAliasAtt)->(EKG_TAMAXI) - 1) / 3) + 1
      oCampo['locale'] := "pt"
   EndIf      
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
      oCampo['help'] := STR0223 + DToC((cAliasAtt)->(EKG_INIVIG)) + "." //"Este atributo tem vigência futura a partir de "
   EndIf

   If nOpc == MODEL_OPERATION_DELETE .Or. nOpc == MODEL_OPERATION_VIEW
      oCampo["disabled"] := .T.
   EndIf
EndIf
Return

Function cp400getNomeAtt(cErro,cNcm,cModal)
Local aAtributos := {}
Local nI
Default cNcm := EK9->EK9_NCM
Default cModal := EK9->EK9_MODALI

If canUseApp()
   If valType(oJsonAtt['listaAtributos']) == "U"
      loadAtPOUI(cNcm, cModal, MODEL_OPERATION_UPDATE, .F., .T.)
   EndIf
   aAtributos := Array(Len(oJsonAtt['listaAtributos']) + Len(oJsonAtt['listaCompostos']))

   If Len(oJsonAtt['listaAtributos']) > 0
      aCopy(oJsonAtt['listaAtributos'], aAtributos,,,1)
   EndIf
   If Len(oJsonAtt['listaCompostos']) > 0
      aCopy(oJsonAtt['listaCompostos'], aAtributos,,,Len(oJsonAtt['listaAtributos'])+1)
   EndIf
   
   For nI := 1 To Len(aAtributos)
      If aAtributos[nI]['property'] $ cErro
         cErro := StrTran(cErro , aAtributos[nI]['property'], "'"+aAtributos[nI]['label'] + "(" + aAtributos[nI]['property'] + ")'")
         Exit
      EndIf
   Next
EndIf

Return cErro

/*
Função     : CPCallApp
Objetivo   : Montar o objeto de campos a ser enviado para o Angular montar o cadastro dos Atributos
Retorno    : -
Parâmetros : oPanel  - Painel para a abertura da tela PO-UI
Autor      : Tiago Tudisco
Data/Hora  : 04/03/2024
*/
Static Function CPCallApp( oPanel )
	FWCallApp( "product-catalog", oPanel, , @oChannel, , "EICCP400")
Return .T.

// Função pare retornar a descrição da NCM
Static Function getNcmDesc(cNCM, lAddCodigo)
Local cDescNCM

Default lAddCodigo := .F.

// Define a ordem de busca na tabela SYD
SYD->(DbSetOrder(1)) //YD_FILIAL, YD_TEC, YD_EX_NCM, YD_EX_NBM, YD_DESTAQU
If SYD->(dbSeek(xFilial("SYD") + AvKey(cNCM,"EKM_NCM")))
   cDescNCM := IIF(lAddCodigo, Transform(cNCM, AvSX3("YD_TEC", AV_PICTURE)) + " - " + SYD->YD_DESC_P ,SYD->YD_DESC_P)
Else // Num caso em que não exista a NCM, retorna a própria NCM para não ter erros
   cDescNCM := cNCM
EndIf

Return cDescNCM

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


Static Function canWriteAtt()
Local lRet := .T.
Local aNames
Local nI

//Verifica se algum campo do objeto oCpObrig está em branco
If Len(aNames := oCpObrig:GetNames()) > 0
   For nI := 1 To Len(aNames)
      If oCpObrig[aNames[nI]]['visible'] .And. oCpObrig[aNames[nI]]['required'] .And. Empty(oCpObrig[aNames[nI]]['value'])
         lRet := .F.
         Exit
      EndIf
   Next
EndIf

Return lRet

Static Function setMsgPOUI(cMsg, isLock)
Local oMsgPOUI

oMsgPOUI := JsonObject():New()
oMsgPOUI['msg']     := cMsg
oMsgPOUI['isLock']  := isLock

oChannel:AdvPLToJS("sendAlertExibe",oMsgPOUI:toJson())

FreeObj(oMsgPOUI)
Return

Static Function setAtEdit(lEditavel)
Local cEditavel := IIF(lEditavel, "true", "false")

lCpPOUIOK := .F.
oChannel:AdvPLToJS("alteraAtributos", cEditavel)
//WaitPOUI({|| lCpPOUIOK })

Return

Static Function WaitPOUI(bCond,nTimeOut)
Local oTmpDlg, oTmpTimer
Local nFimTimeout := 0
Local lRet
Local bFim
Default nTimeOut := 30

If nTimeOut > 0
    nFimTimeout := Seconds2()+nTimeOut
EndIf

bFim := {|| If((lRet := Eval(bCond)) .OR. nFimTimeout > 0 .AND. Seconds2() > nFimTimeout .OR. KillApp(),(oTmpTimer:deactivate(),oTmpDlg:End()),) }

If !(lRet := Eval(bCond))
    DEFINE MSDIALOG oTmpDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL
        oTmpDlg:bInit := bFim
        oTmpTimer := TTimer():New(1, bFim, oTmpDlg )
        oTmpTimer:lLiveAny := .T.
        oTmpTimer:Activate()
        //oTmpDlg:lVisible := .F.//.F.
    ACTIVATE MSDIALOG oTmpDlg
EndIf

Return lRet
Static Function Seconds2(dData,cHora)
Default dData := date()
Default cHora := time()
Return (dData-stod('20000101'))*86400 + (val(substr(cHora,1,2))*3600) + (val(substr(cHora,4,2))*60) + val(substr(cHora,7,2))
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
Local oModelEK9
Local lAlteraAt

Do Case
   Case cType == 'preLoad'
      oPreLoad := JsonObject():New()
      //If Inclui
         oPreLoad['msgLoading']     := STR0224 //"Aguardando NCM..."
         oPreLoad['isHideLoading']  := "false"
         oPreLoad['inclusao']       := IIF(Inclui, "true", "false")
         oPreLoad['noLabelNCM']     := STR0227 //"A NCM informada não possui Atributos."
         oPreLoad['noValueNCM']     := STR0228 //"Acesse o cadastro 'Atributos Portal Único' e faça a integração dos Atributos da NCM."
         oWebChannel:AdvPLToJS('overLoad', oPreLoad:toJson())
         FreeObj(oPreLoad)
      //EndIf
   
   Case cType == 'carregaAtributos'
      oModel      := FWModelActive()
      oModelEK9   := oModel:GetModel("EK9MASTER")
      lAlteraAt   := PermAlt(oModelEK9, .T.)
      // Chama a função para carregar os atributos
      loadAtPOUI(oModelEK9:GetValue("EK9_NCM"), oModelEK9:GetValue("EK9_MODALI"), oModel:GetOperation(), lAlteraAt)
      setAtEdit(lAlteraAt)//Deixa os atributos editáveis ou não editáveis, conforme o campo EK9_PERATR

   Case cType == 'validaObrigatorio'
      oPreLoad := JsonObject():New()
      oPreLoad:FromJson(cContent)
      oCpObrig := oPreLoad['listaAtributos']
      lAltPOUI := oPreLoad['alterouPOUI']
      lPOUIOKCM := .T.
      FreeObj(oPreLoad)

   Case cType == 'retLoadAtributos'
      lPOUIOKLD := .T.

   Case cType == 'retEnableDisableAt'
      lCpPOUIOK := .T.

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
If lAppCP400 == nil
   lRet := !IsBlind() .And. TEOpenApp(.F., .T.) .And. Len(GetApoInfo("product-catalog.app")) > 0
   lAppCP400 := lRet
Else
   lRet := lAppCP400
EndIf

If FwIsInCallStack("CP403ImpXls") .Or. FwIsInCallStack("CP404ImpArq")
   lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} vincOperCat
   Executa a vinculação do operador com o catalogo de produto

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param oEasyJS, objeto, EasyJS
          cErros, caracter, variavel de erro
          cUrl, caracter, URL do portal unico da API
          cJson, caracter, JSON de envio
   @return cRet, caracter, retorno da execução
/*/
static function vincOperCat(oEasyJS, cErros, cUrl, cJson)
   local cRet    := ""
   local cScript := ""

   begincontent var cScript

      vincOperCat('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)

   endcontent

   oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )

return cRet

/*
Função     : geraExcel
Objetivo   : Função para gerar arquivo excel da geração em lote do catálogo de produtos
Retorno    : 
Autor      : Nícolas Brisque
Data/Hora  : Julho/2024
Obs.       :
*/
Static Function geraExcel(cAliasSB1)
Local oExcel      := FwMsExcelXlsx():New()
Local cWorksheet  := STR0230 // "Log de geração"
Local cTable      := STR0231 // "Log da geração do catálogo de produtos em lote"
Local cArquivo    := CriaTrab(Nil, .F.) + ".xlsx"
Local cTitulo     := ""
Local aStruct     := {}
Local oFwSX1Util  := nil
Local aPergunte   := {}
Local i           := 0
Default cAliasSB1 := CP400_PROD

// Cria a planilha e a tabela que será utilizada
oExcel:AddworkSheet(cWorksheet)
oExcel:AddTable(cWorksheet, cTable)

// Adiciona as colunas na tabela
(cAliasSB1)->(dbGoTop())
aStruct := (cAliasSB1)->(dbStruct())
For i := 1 To Len(aStruct)
   If !(aStruct[i][1] $ "REG_MARCA||RECNO||RECSB1")
         cTitulo  := IIF(aStruct[i][1] == "RETORNO", "Mensagem", IIF(aStruct[i][1] == "RESULTADO", "Resultado", RetTitle(aStruct[i][1])))
         oExcel:AddColumn(cWorksheet, cTable, cTitulo)
   EndIf
Next i

// Adiciona as linhas na tabela
While (cAliasSB1)->(!EoF())
   cResultado := IIF((cAliasSB1)->RESULTADO == "0", STR0148, IIF((cAliasSB1)->RESULTADO == "1", STR0149, STR0150)) // "Pendente de processamento" // "Inclusão realizada com sucesso" // "Falha na inclusão"
   oExcel:Addrow(cWorksheet, cTable, { ;
      (cAliasSB1)->B1_COD, ;
      (cAliasSB1)->B1_DESC, ;
      Transform((cAliasSB1)->B1_POSIPI, GetSx3Cache("B1_POSIPI", "X3_PICTURE")), ;
      (cAliasSB1)->B1_EX_NCM, ;
      (cAliasSB1)->W2_IMPORT, ;
      Transform((cAliasSB1)->YT_CGC, GetSx3Cache("YT_CGC", "X3_PICTURE")), ;
      cResultado, ;
      (cAliasSB1)->RETORNO ;
   })
   (cAliasSB1)->(dbSkip())
EndDo

// Adquire as informações do pergunte
oFwSX1Util := FwSX1Util():New()
oFwSX1Util:AddGroup("EICCP400")
oFwSX1Util:SearchGroup()
aPergunte := oFwSX1Util:GetGroup("EICCP400")

// Adiciona o filtro na tabela
oExcel:Addrow(cWorksheet, cTable, {}) // Adiciona uma linha em branco só para dar um espaço entre a tabela e o filtro utilizado
oExcel:Addrow(cWorksheet, cTable, {STR0236}) // "Filtros utilizados:"

For i := 1 to Len(aPergunte[2])
   oExcel:Addrow(cWorksheet, cTable, {AllTrim(aPergunte[2][i]["CX1_PERGUNT"]), &("MV_PAR" + IIF(i < 10, "0" + AllTrim(Str(i)), AllTrim(Str(i))))})
Next i

// Salva o arquivo
oExcel:Activate()
oExcel:GetXMLFile(cArquivo)
oExcel:DeActivate()
FwFreeObj(oExcel)

MsAguarde( {|| comex.generics.TEOpenExcel(cArquivo)}, STR0232) // "Gerando o arquivo excel."

Return .F. // Retorna falso para não realizar mudanças na página


/*/{Protheus.doc} CP400VldX1()
   Realiza as validações do pergunte EICCP400

   @type  Function
   @author user
   @since 16/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
function CP400VldX1(cOrdem)
   local lRet       := .T.

   default cOrdem     := ""

   if cOrdem == "MV_PAR12"
      
      if MV_PAR11 == 1 .and. !empty(MV_PAR12)
         lRet := ExistCpo("SYT", MV_PAR12, 1) // YT_FILIAL+YT_COD_IMP
         if lRet
            MV_PAR13 := subStr(SYT->YT_CGC, 1, len(MV_PAR13))
         endif
      endif

   elseif cOrdem == "MV_PAR13"

      if MV_PAR11 == 1 
         if !empty(MV_PAR12) .and. !empty(MV_PAR13) .and. !(substr(Posicione("SYT", 1, xFilial("SYT") + MV_PAR12, "YT_CGC"), 1, len(MV_PAR13)) == MV_PAR13)
            lRet := .F.
            MsgInfo(STR0234, STR0002) // "Para informar o CNPJ raiz é necessário que o código do importador não seja informado." ### "Atenção"
         elseif !empty(MV_PAR13) .and. len(alltrim(MV_PAR13)) < len(MV_PAR13)
            lRet := .F.
            MsgInfo(STR0235, STR0002) // "CNPJ raiz inválido. É necessário informar os 8 primeiros dígitos." ### "Atenção"
         endif

      endif

   endif

return lRet

/*/{Protheus.doc} getFilUser
   Retorna as filiais que o usuario tem permissão

   @type  Static Function
   @author user
   @since 07/10/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getFilUser(aRetFils)
   local cFiltFil  := ""
   local aFilUser  := {}
   local nLenFil   := 0
   local nFil      := 0

   default aRetFils   := {}

   nLenFil := len(aRetFils)
   aFilUser := FwLoadSM0(,.T.)
   for nFil := 1 to len(aFilUser)
      if len(aFilUser[nFil]) >= 11 .and. aFilUser[nFil][11]
         if nLenFil == 0 .or. aScan(aRetFils, { |Y| Y == aFilUser[nFil][2]} ) == 0
            aAdd(aRetFils , aFilUser[nFil][2])
         endif
         cFiltFil += "'" + aFilUser[nFil][2] + "', "
      endif
   next
   cFiltFil := subStr(cFiltFil, 1, len(cFiltFil) - 2)

return cFiltFil

/*/{Protheus.doc} AtuStatus
   Verificar se há a necessidade de executar a atualização dos catalogos de produtos com status de "Registrado" para "Registrado (pendente: fabricante/ país)"

   @type  Static Function
   @author user
   @since 14/01/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function AtuStatus()
   local cRelease   := getRPORelease()
   local oParams    := nil
   local lAtualiza  := .F.

   if cRelease <= "12.1.2410"
      oParams:= EASYUSERCFG():New("EICCP400", "")
      lAtualiza := oParams:LoadParam("ATU_STATUS", .T., , .T.)
      if lAtualiza
         AtuEK9Stat()
         oParams:SetParam("ATU_STATUS", .F.)
      endif
      FwFreeObj(oParams)
   endif

return nil

/*/{Protheus.doc} AtuEK9Stat
   Realiza a atualização dos catalogos de produtos com status de "Registrado" para "Registrado (pendente: fabricante/ país)"

   @type  Static Function
   @author user
   @since 14/01/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function AtuEK9Stat()
   local aArea      := {}
   local aAreaEK9   := {}
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := ""

   aArea := getArea()
   aAreaEK9 := EK9->(getArea())

   cQuery := " SELECT EK9.R_E_C_N_O_ RECEK9 FROM " + RetSqlName("EKD") + " EKD "
   cQuery +=   " INNER JOIN " + RetSqlName("EK9") + " EK9 ON EK9.EK9_FILIAL = ? AND EK9.EK9_COD_I = EKD.EKD_COD_I AND EK9.EK9_STATUS <> ? AND EK9.D_E_L_E_T_ = ? "
   cQuery += " WHERE EKD.EKD_FILIAL = ? AND EKD_STATUS = ? AND EKD.D_E_L_E_T_ = ? "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString(1,xFilial('EK9')) // EK9_FILIAL
   oQuery:SetString(2,'6') // EK9_STATUS
   oQuery:SetString(3,' ') // D_E_L_E_T_
   oQuery:SetString(4,xFilial('EKD')) // EKD_FILIAL
   oQuery:SetString(5,'5') // EKD_STATUS
   oQuery:SetString(6,' ') // D_E_L_E_T_

   cQuery := oQuery:GetFixQuery()
   fwFreeObj(oQuery)

   cAliasQry := getNextAlias()
   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      EK9->(DbGoTo((cAliasQry)->RECEK9))
      if (cAliasQry)->RECEK9 == EK9->(Recno())
         RecLock("EK9",.F.)
         EK9->EK9_STATUS := REGISTRADO_PENDENTE_FAB_PAIS
         EK9->(MsUnLock())
      endif
      (cAliasQry)->(dbSkip())
   end

   (cAliasQry)->(dbCloseArea())
   RestArea(aArea)
   RestArea(aAreaEK9)

return nil

/*/{Protheus.doc} AtuEK9Stat
   Retorna array com as cores dos staus da EKk9 (Catálgoo de produtos)
   @type  Static Function
   @author user
   @since 27/02/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Function CP400Cores(aCoresNum)
Local aCores := {}
Local nCor := 0
for nCor := 1 to len(aCoresNum)
    Do case 
       case aCoresNum[nCor] == REGISTRADO
            aadd(aCores,{ "EK9_STATUS == '1' "                       ,"ENABLE"       ,STR0004	})  //"Registrado"
       case aCoresNum[nCor] ==  PENDENTE_REGISTRO    
            aadd(aCores,{"EK9_STATUS == '2' "                       ,"BR_CINZA"	   ,STR0005	})  //"Pendente Registro"
        case aCoresNum[nCor] == PENDENTE_RETIFICACAO
            aadd(aCores,{"EK9_STATUS == '3' "                       ,"BR_AMARELO"	,STR0006	})  //"Pendente Retificação"
        case aCoresNum[nCor] == BLOQUEADO            
            aadd(aCores,{"EK9_STATUS == '4' .or. EK9_MSBLQL == '1' ","DISABLE"      ,STR0007	})  //"Bloqueado"
        case aCoresNum[nCor] == REGISTRADO_MANUALMENTE
            aadd(aCores,{"EK9_STATUS == '5' "                       ,"BR_AZUL_CLARO",STR0156 }) //"Registrado Manualmente"
        case aCoresNum[nCor] == REGISTRADO_PENDENTE_FAB_PAIS            
            aadd(aCores,{"EK9_STATUS == '6' "                       ,"BR_AZUL"      ,STR0250 }) //"Registrado (pendente: fabricante/país)"
     EndCase       
next
Return aCores                     

/*/{Protheus.doc} CP400MultF
   Chama a função isMultfil e retorna seu resultado
   @type  Static Function
   @author user
   @since 18/03/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Function CP400MultF()
Return isMultFil()

/*/{Protheus.doc} getCtela
   função que trata os campos numéricos que vem da tela com formatação de separador de milhar e vírgula como ponto decimal e retorna o valor sem formatação
   @type  Static Function
   @author user
   @since 20/03/2025
   @version version
   @param cValor, caracter com valor numérico a ser tratado
          lString, indica se deve retornar o valor na variável do tipo numérica ou caracter
   @return nTela, retorna o valor numérico sem formatação e variável do tipo numérica
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getCtela(cValor,lString)
Local cTela := ''
      cTela := StrTran(cValor,".","")
      cTela := StrTran(cTela,",",".")
Return if(lString,cTela,val(cTela))


/*/{Protheus.doc} getMascara
   função que monta a máscara dos campos numéricos
   @type  Static Function
   @author user
   @since 21/03/2025
   @version version
   @param nTam, tamanho total do campo
          nDec, tamanho das decimais do campo
   @return cMascara, retorna a máscara formatada
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getMascara(nTam,nDec)
local nInteiro := nTam-nDec
local cMascara := ''
cMilhar := '.'
cDecimal := ',' 
cMascara := replicate("9",nInteiro)
cMascara := strTran(cMascara,'999',cMilhar + '999')
cMascara := getAjuste(cMascara,cMilhar)
cMascara := cMascara + IIF(nDec > 0, cDecimal + replicate("9",nDec), "")
Return cMascara 

/*/{Protheus.doc} getAjust
   função ajusta a mácara iniciada na funcao getMacara, ajustando o final e o início qunado necessário
   @type  Static Function
   @author user
   @since 21/03/2025
   @version version
   @param cMascara, mascara a ser tratada
          cMilhar, separador de milhar com a qual a mascara original foi criada
   @return cMascara, retorna a máscara formatada
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getAjuste(cMascara,cMilhar)
local i:=0
for i:= length(cMascara) to 1 step -1
   if substring(cMascara,i,1) == cMilhar
      cFinTot := right(cMascara,length(cMascara)-i)
      if length(cFinTot) > 3
         cFinOK := substring(cFinTot,1,3)
         cMascara := substring(cMascara,1,i) + cFinOK
         cRestFin := right(cFinTot,length(cFinTot)-3)
         cMascara :=  cRestFin + cMascara
      Endif   
      exit
   endif
next  
cMascara := if(substring(cMascara,1,1) == cMilhar,right(cMascara,length(cMascara)-1),cMascara)
Return cMascara
