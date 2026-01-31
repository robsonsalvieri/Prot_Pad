#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICOE400.CH"
#INCLUDE "AVERAGE.CH"

#define ALIAS_TEMP          1
#define ARQ_TAB             2
#define INDEX1              3
#define INDEX2              4

static _aTabsTmp  := {}
static OE400_F3   := "OE400_F3"

/*
Programa   : EICOE400
Objetivo   : Criar o cadastro de operadaor estrangeiro 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Function EICOE400(aCapAuto,nOpcAuto)
Local oBrowse
Local aCores 	:= {}
Local nX		:= 1
local lAtualTIN  := .F.
local lLibAccess  := .F.
local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

Private INCLUI     := .F. //Variável INCLUI utilizada no dicionário de dados da EKJ para nao permitir alteração de alguns campos  
Private lOE400Auto := ValType(aCapAuto) <> "U" .And. ValType(nOpcAuto) <> "U"
Private lAutoErrNoFile := .T.

if lExecFunc
   FwBlkUserFunction(.T.)
endif

lLibAccess := AmIin(17)

if lExecFunc
   FwBlkUserFunction(.F.)
endif

if lLibAccess

   aCores := {{"EKJ_STATUS == '1' "                       ,"ENABLE"      ,STR0027 },; // "Registrado"
              { "EKJ_STATUS == '2' .OR. EMPTY(EKJ_STATUS)" ,"BR_AMARELO"  ,STR0028 },; // "Pendente Registro"
              { "EKJ_STATUS == '3' "                       ,"BR_VERMELHO" ,STR0029 },; // "Pendente Retificação"
              { "EKJ_STATUS == '4' "                       ,"BR_PRETO"    ,STR0030 },; // "Falha de Integração"
              { "EKJ_STATUS == '5' "                       ,"BR_LARANJA"  ,STR0083 }}  // "Desativados"

   if !lOE400Auto

      lAtualTIN  := avFlags("CATALOGO_PRODUTO")
      if lAtualTIN
         loadAgeEmi()
      endif

      oBrowse := FWMBrowse():New() //Instanciando a Classe
      For nX := 1 To Len( aCores )                                 //Adiciona a legenda 	    
			oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
		Next nX
      oBrowse:SetAlias("EKJ") //Informando o Alias
      oBrowse:SetMenuDef("EICOE400") //Nome do fonte do MenuDef
      oBrowse:SetDescription(STR0006)//Operador Estrangeiro
      oBrowse:Activate()

      eraseTmp()

   Else
      FWMVCRotAuto(ModelDef(), "EKJ", nOpcAuto,{{"EICOE400_EKJ",aCapAuto}})

   EndIf

endif

Return 

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Maurício Frison 
Data/Hora  : 29/05/2020 11:28:07 
*/ 
Static Function MenuDef()
Local aRotina := {}

   aAdd( aRotina, { STR0001 , "AxPesqui"         , 0, 1, 0, NIL } )	//'Pesquisar'
   aAdd( aRotina, { STR0002 , 'VIEWDEF.EICOE400' , 0, 2, 0, NIL } )	//'Visualizar'
   aAdd( aRotina, { STR0003 , 'VIEWDEF.EICOE400' , 0, 3, 0, NIL } )	//'Incluir'
   aAdd( aRotina, { STR0004 , 'VIEWDEF.EICOE400' , 0, 4, 0, NIL } )	//'Alterar'
   aAdd( aRotina, { STR0005 , 'VIEWDEF.EICOE400' , 0, 5, 0, NIL } )	//'Excluir'
   aAdd( aRotina, { STR0026 , 'OE400Integrar()'  , 0, 6, 0, NIL } )	//'Integrar' // deixar os parenteses devido por padrão retornar -> alias, recno e opção
   aAdd( aRotina, { STR0103 , 'OE400NewVrs'      , 0, 6, 0, NIL } )	//'Gerar Nova Versão'
   aAdd( aRotina, { STR0031 , 'COE400Legen'      , 0, 1, 0, NIL } )	//'Legenda'
   aAdd( aRotina, { STR0080 , 'OE400Log'         , 0, 2, 0, NIL } )	//'Log de Integração'

Return aRotina

/*
Programa   : modelef()
Objetivo   : model da rotina de cadastro de operador estrangeiro
Retorno    : objeto model
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ModelDef()
Local oStruEKJ       := FWFormStruct( 1, "EKJ") //Monta a estrutura da tabela EKJ
Local bPosValidacao  := {|oModel| OE400POSVL(oModel)}
Local oModel
local lAtualTIN  := avFlags("CATALOGO_PRODUTO")
local oStruEKT   := nil
local oMdlEvent  := OE400EV():New()

   oStruEKJ:SetProperty('EKJ_TIN'   , MODEL_FIELD_WHEN   , {|| .F. })
   oStruEKJ:SetProperty('EKJ_TIN'   , MODEL_FIELD_OBRIGAT, .F. )
   oStruEKJ:SetProperty('EKJ_POSTAL', MODEL_FIELD_OBRIGAT, .F. )
   oStruEKJ:SetProperty('EKJ_SUBP'  , MODEL_FIELD_OBRIGAT, .F. )
   oStruEKJ:SetProperty('EKJ_STATUS', MODEL_FIELD_VALID  , FwBuildFeature(STRUCT_FEATURE_VALID, 'PERTENCE("1|2|3|4|5")' ))

   /*Criação do Modelo com o cID = "EXPP016", este nome deve conter como as tres letras inicial de acordo com o
   módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
   oModel := MPFormModel():New( 'EICOE400', /*bPreValidacao*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

   //Modelo para criação da antiga Enchoice com a estrutura da tabela SJO
   oModel:AddFields( 'EICOE400_EKJ',/*nOwner*/,oStruEKJ, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)    

   //Adiciona a descrição do Modelo de Dados
   oModel:SetDescription(STR0006)//Operador Estrangeiro

   //Utiliza a chave primaria
   oModel:SetPrimaryKey( { "EKJ_FILIAL","EKJ_CNPJ_R", "EKJ_FORN", "EKJ_FOLOJA"} )  

   if lAtualTIN
      oStruEKT := FWFormStruct( 1, "EKT")
      oModel:AddGrid("EICOE400_EKT","EICOE400_EKJ", oStruEKT, /*bPreValidacao*/ , /*bPosValidacao*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )
      oModel:SetRelation('EICOE400_EKT', {{ 'EKT_FILIAL' , 'xFilial("EKT")' },;
                                          { 'EKT_CNPJ_R' , 'EKJ_CNPJ_R'     },;
                                          { 'EKT_FORN'   , 'EKJ_FORN'       },;
                                          { 'EKT_FOLOJA' , 'EKJ_FOLOJA'     }},;
                                           EKT->(IndexKey(1)) )
      oModel:GetModel("EICOE400_EKT"):SetDescription(STR0051) // "Identificações Adicionais"
      oModel:GetModel("EICOE400_EKT"):SetOptional(.T.)
   endif

   oModel:InstallEvent("OE400EV", , oMdlEvent)

Return oModel

/*
Programa   : Viewdef()
Objetivo   : View da rotina de cadastro de operador estrangeiro
Retorno    : objeto view
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function ViewDef()
Local oModel     := FWLoadModel("EICOE400")
Local oStruEKJ   := FWFormStruct(2,"EKJ")
Local oView      := nil
local lAtualTIN  := avFlags("CATALOGO_PRODUTO")
local oStruEKT   := nil

   // Cria o objeto de View
   oView := FWFormView():New()
                                                                        
   // Define qual o Modelo de dados a ser utilizado
   oView:SetModel( oModel ) 

   // Devido as atualizações do portal unico, foi retirado a obrigatoriedade do campo TIN e criado um novo campo Codigo
   // Assim será alterado o titulo do campo EKJ_TIN para Código e será o primeiro campo da tela, sendo não editável
   // Observação: no portal unico foi migrado a informação cadastrado no campo TIN para o campo Código
   oStruEKJ:SetProperty('EKJ_TIN' , MVC_VIEW_TITULO , STR0081 ) // "Código"
   oStruEKJ:SetProperty('EKJ_TIN' , MVC_VIEW_DESCR  , STR0082 ) // "Código Portal Único"
   oStruEKJ:SetProperty('EKJ_TIN' , MVC_VIEW_ORDEM  ,'01')
   if( oStruEKJ:HasField("EKJ_VERMAN"), oStruEKJ:RemoveField("EKJ_VERMAN"), nil )

   //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
   oView:AddField('VIEW_EKJ', oStruEKJ, 'EICOE400_EKJ')

   //Relaciona a quebra com os objetos
   if lAtualTIN
      oStruEKT := FWFormStruct(2,"EKT")
      if( oStruEKT:HasField("EKT_CNPJ_R"), oStruEKT:RemoveField("EKT_CNPJ_R"), nil )
      if( oStruEKT:HasField("EKT_FORN"), oStruEKT:RemoveField("EKT_FORN"), nil )
      if( oStruEKT:HasField("EKT_FOLOJA"), oStruEKT:RemoveField("EKT_FOLOJA"), nil )

      if oStruEKT:hasField("EKT_DESCRI")
         oStruEKT:SetProperty("EKT_DESCRI", MVC_VIEW_ORDEM, "06")
         oStruEKT:SetProperty("EKT_NUMIDE", MVC_VIEW_ORDEM, "07")
      endif

      oView:AddGrid("VIEW_EKT",oStruEKT , "EICOE400_EKT")
      oView:CreateHorizontalBox( 'SUPERIOR' , 60 )
      oView:CreateHorizontalBox( 'INFERIOR' , 40 )
      oView:SetOwnerView( 'VIEW_EKJ' , 'SUPERIOR' )
      oView:SetOwnerView( 'VIEW_EKT' , 'INFERIOR' )
      oView:EnableTitleView("EICOE400_EKT",STR0051) // "Identificações Adicionais"
   endif

   //Habilita ButtonsBar
   oView:EnableControlBar(.T.)

Return oView 

/*
Programa   : OE400Val(cCampo)
Objetivo   : Funcao de validação dos campos
Retorno    : Lógico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Val(cCampo)
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")

   Do Case 

      Case cCampo == "EKJ_IMPORT"
         if !empty(oModelEKJ:GetValue("EKJ_IMPORT"))
            lRet := ExistCpo("SYT", oModelEKJ:GetValue("EKJ_IMPORT"))
            if lRet .and. !(alltrim(Posicione( "SYT", 1, xFilial("SYT") + oModelEKJ:GetValue("EKJ_IMPORT") , "YT_IMP_CON")) == "1")
               lRet := .F.
               easyHelp(STR0009, STR0017, STR0096 + " " + AVSX3("YT_IMP_CON", AV_TITULO) + " " + STR0097) // "Código informado não é de importador" ### "Verifique o campo" + "(YT_IMP_CON) do cadastro do importadores. Para utilizá-lo, é necessário que esteja com contéudo igual a 1=Importador."
            endif
         endif
      Case cCampo == "EKJ_TIN"
         //If !Empty(Posicione("EKJ",2,xFilial("EKJ")+oModelEKJ:GetValue("EKJ_TIN"),"EKJ_TIN"))
         //   lRet := .F.
           // easyHelp(STRTRAN(STR0007,####,":"+M->EKJ_TIN)) // Campo TIN:#### já existente
         //  easyHelp(STR0007) // Campo TIN já existente
         //EndIf
      Case (cCampo == "EKJ_FORN" .OR. cCampo == "EKJ_FOLOJA") .And. !empty(oModelEKJ:GetValue("EKJ_FORN")) .And. !empty(oModelEKJ:GetValue("EKJ_FOLOJA"))
         lRet := ExistCpo("SA2", oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"))
         If lRet .and. !empty(Posicione("EKJ",1,xFilial("EKJ") + oModelEKJ:GetValue("EKJ_CNPJ_R") + oModelEKJ:GetValue("EKJ_FORN") + oModelEKJ:GetValue("EKJ_FOLOJA"),"EKJ_CNPJ_R"))
            lRet := .F.
            easyHelp(STR0098, STR0017, STR0099) // "Já existe um cadastro de Operador Estrangeiro para este Fornecedor/Loja e CNPJ raiz do importador." #### "Verifique o cadastro existente ou utilize outro Fornecedor/Loja."
         EndIf
      Case cCampo == "EKJ_VERMAN"
         If !Empty(oModelEKJ:GetValue("EKJ_VERMAN")) .and. !Empty(oModelEKJ:GetValue("EKJ_VERSAO"))
            lRet := (oModelEKJ:GetValue("EKJ_VERMAN") == oModelEKJ:GetValue("EKJ_VERSAO")) .Or. MsgYesNo(STR0043, STR0017) // Deseja substituir a versão atual pela informação digitada?
            If !lRet
               easyHelp(STR0100, STR0017, STR0042) // "Operação cancelada." ### "Limpe o campo para prosseguir."
            EndIf
         EndIf
      Case cCampo == "EKJ_PAIS"
         if !empty(oModelEKJ:GetValue("EKJ_PAIS"))
            lRet := ExistCpo("ELO",oModelEKJ:GetValue("EKJ_PAIS"))
         EndIf
      Case cCampo == "EKJ_MSBLQL"
         if oModel:GetOperation() == MODEL_OPERATION_UPDATE
            if !(oModelEKJ:GetValue("EKJ_MSBLQL") == "1") .and. EKJ->EKJ_MSBLQL == "1" .and. !empty(EKJ->EKJ_TIN) .and. EKJ->EKJ_STATUS == "5" //  "Desativados"
               lRet := .F.
               easyHelp(STR0110, STR0017, STR0111) // "Não é permitido desbloquear um operador estrangeiro que está desativado." #### "Utilize a funcionalidade de 'Gerar Nova Versão', para que seja possível realizar a sua reativação no Portal Único e desbloqueado no sistema."
            endif
         endif

   EndCase

Return lRet

/*
Programa   : OE400Gatil(cCampo)
Objetivo   : Funcao de gatilho dos campos
Retorno    : cReturn
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
FUNCTION OE400Gatil(cCampo)
Local cReturn := ''
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")
//Local cTin  := ""
local cPais := ""

   Do Case
      Case cCampo=="EKJ_IMPORT" 
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_NOME_RE")
      Case cCampo=="EKJ_CNPJ_R"
           cReturn := Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_CGC")
           cReturn := Substr(cReturn,1,8)
      Case cCampo=="EKJ_NOME" 
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_NOME")
      Case cCampo=="EKJ_CODTIN"
           cReturn := SubStr(Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_NIFEX"), 1 , getSX3Cache("EKJ_CODTIN", "X3_TAMANHO"))
      Case (cCampo=="EKJ_CIDA")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_MUN")
           cReturn := SubStr(cReturn,1,35)
      Case (cCampo=="EKJ_LOGR")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_END")
      Case (cCampo=="EKJ_POSTAL")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_POSEX")
           cReturn := SubStr(cReturn,1,9)
      Case (cCampo=="EKJ_PAIS")
           cPais := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAIS")
           if !empty(cPais)
               cReturn := Posicione( "SYA", 1, xFilial("SYA") + cPais , "YA_PAISDUE")
           endif
      Case (cCampo=="EKJ_SUBP")
           cReturn := Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_PAISSUB")
      Case (cCampo=="EKJ_VERSAO")
           cReturn := oModelEKJ:GetValue("EKJ_VERSAO")
           If !Empty(oModelEKJ:GetValue("EKJ_VERMAN"))
               cReturn := oModelEKJ:GetValue("EKJ_VERMAN")
           EndIf
      Case (cCampo=="EKJ_EMAIL")
           cReturn := PADR(Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_EMAIL"), AVSX3("EKJ_EMAIL",AV_TAMANHO))
   EndCase

return cReturn

/*
Programa   : OE400POSVL
Objetivo   : Funcao de Pos Validacao
Retorno    : Logico
Autor      : Maurício Frison
Data/Hora  : Jun/2020
Obs.       :
*/
Static Function OE400POSVL(oMdl)
Local oModelEKJ   := oMdl:GetModel("EICOE400_EKJ")
Local lRet        := .T.
local lAtualTIN   := avFlags("CATALOGO_PRODUTO")
local oModelEKT   := nil
local nAgencia    := 0
local nTotaAgen   := 0
local cMsgError   := ""
local cMsgSoluc   := ""

   //Inclusão
   If oMdl:GetOperation() == 3
      If EKJ->( dbsetorder(1),dbseek(xFilial("EKJ")+oModelEKJ:GetValue("EKJ_CNPJ_R")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA")))
         lRet := .F.
         easyHelp(STR0012) // Inclusão não permitida, chave do registro duplicada
      EndIf
   EndIf

   //Alteração
   if oMdl:GetOperation() == 4
      // registrado / pendente de retificação / falha de integração / desativado  
      If ( oModelEKJ:getvalue("EKJ_STATUS") == "1" .or. oModelEKJ:getvalue("EKJ_STATUS") == "3" .or. oModelEKJ:getvalue("EKJ_STATUS") == "4" .or. oModelEKJ:getvalue("EKJ_STATUS") == "5"  )
         lRet := VerifJson(oMdl, oModelEKJ, @cMsgError, @cMsgSoluc)
         if !lRet
            EasyHelp(cMsgError, STR0017, cMsgSoluc) // "Atenção"
         endif
      endif
   endif

   if lAtualTIN .and. lRet .and. (oMdl:GetOperation() == 3 .or. oMdl:GetOperation() == 4)
      oModelEKT := oMdl:GetModel("EICOE400_EKT")
      nTotaAgen := oModelEKT:length(.T.) 
      for nAgencia := 1 to nTotaAgen
         oModelEKT:goLine(nAgencia)
         if !oModelEKT:IsDeleted(nAgencia) .and. ( (empty(oModelEKT:getValue("EKT_AGEEMI")) .and. !empty(oModelEKT:getValue("EKT_NUMIDE"))) .or. (!empty(oModelEKT:getValue("EKT_AGEEMI")) .and. empty(oModelEKT:getValue("EKT_NUMIDE"))) )
            lRet := .F.
            EasyHelp(STR0052, STR0017, STR0053) // "Existe número de identificação do operador estrangeiro sem agência emissora informada ou agência emissora sem número de identificação." ### "Atenção" ### "Revise as informações das Identificações Adicionais antes de prosseguir."
            exit
         endif
      next
   endif

   //Exclusão
   If oMdl:GetOperation() == 5
      IF !Empty(oModelEKJ:GetValue("EKJ_DATA")) 
         lRet := .F.
         easyHelp(STR0011) // Registro com data de integração não pode ser excluído
      EndIf
   EndIf

Return lRet

/*
Programa   : VerifAlt
Objetivo   : Função para verificar se houve alteração nos campos e consequentemente alterar o status de retificação
Retorno    : Logico (.T. caso houve alteração e caso contrário, .F.)
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Static Function VerifAlt(oModelEKT, aCampos)
   Local lRet    := .F.
   Local i

   Begin Sequence
      For i := 1 to Len(aCampos)
         If !( aCampos[i][1] == "EKT") .and. !aCampos[i][3] == EKJ->&(aCampos[i][1])
            lRet := .T.
            Break
         EndIf
      Next

      if !(oModelEKT == nil)
         lRet := oModelEKT:isModified()
      endif

   End Sequence

Return lRet

/*/{Protheus.doc} VerifJson
   Função para validar os dados do modelo com o JSON enviado para o portal unico

   @type  Static Function
   @author user
   @since 01/09/2023
   @version version
   @param oMdl, objeto, modelo de dados
          oModelEKJ, objeto, modelo de dados EKJ
          cMsgError, caractere, mensagem de validação
          cMsgSoluc, caractere, mensagem de solução
   @return lRet, logico, caso .T. está ok e .F. validação
/*/
static function VerifJson(oMdl, oModelEKJ, cMsgError, cMsgSoluc)
   local lRet       := .T.
   local cLogInteg  := ""
   local cIdenAdic  := ""
   local lCpoCodTin := .F.
   local lCpoEmail  := .F.
   local oModelEKT  := nil
   local aCampos    := {}
   local lAltBase   := .F.
   local lAltJson   := .F.
   local cMsgEnvio  := ""
   local cMsgRet    := ""
   local nPosMsgRet := 0
   local nPosMsgEnv := 0
   local oJson      := nil
   local cRetJson   := ""
   local aJson      := {}
   local aAtribJson := {}
   local lSucesso   := .F.
   local nCampos    := 0
   local nPosJson   := 0
   local lAtivado   := .T.
   local oViewOE400 := nil
   local aModels    := {}

   default cMsgError  := ""
   default cMsgSoluc  := ""

   lOE400Auto := if( isMemVar("lOE400Auto"), lOE400Auto, valtype(oViewOE400 := FWViewActive()) == "O" .and. len(aModels := oViewOE400:GetModelsIDS()) > 0 .and. aScan(aModels, { |X| X == "EICOE400_EKJ" } ) > 0 )

   cIdenAdic := ""
   lCpoCodTin := EKJ->(ColumnPos("EKJ_CODTIN")) > 0
   lCpoEmail := EKJ->(ColumnPos("EKJ_EMAIL")) > 0
   if avFlags("CATALOGO_PRODUTO")
      cIdenAdic := getIdenAdc(EKJ->(recno()))
      oModelEKT := oMdl:GetModel("EICOE400_EKT")
   endif

   aAdd( aCampos, {"EKJ_NOME"      , "nome"                , oModelEKJ:getvalue("EKJ_NOME")   , AVSX3( "EKJ_NOME", AV_TIPO) } )
   aAdd( aCampos, {"EKJ_LOGR"      , "logradouro"          , oModelEKJ:getvalue("EKJ_LOGR")   , AVSX3( "EKJ_LOGR", AV_TIPO) } )
   aAdd( aCampos, {"EKJ_CIDA"      , "nomeCidade"          , oModelEKJ:getvalue("EKJ_CIDA")   , AVSX3( "EKJ_CIDA", AV_TIPO) } )
   aAdd( aCampos, {"EKJ_SUBP"      , "codigoSubdivisaoPais", oModelEKJ:getvalue("EKJ_SUBP")   , AVSX3( "EKJ_SUBP", AV_TIPO) } )
   aAdd( aCampos, {"EKJ_PAIS"      , "codigoPais"          , oModelEKJ:getvalue("EKJ_PAIS")   , AVSX3( "EKJ_PAIS", AV_TIPO) } )
   aAdd( aCampos, {"EKJ_POSTAL"    , "cep"                 , oModelEKJ:getvalue("EKJ_POSTAL") , AVSX3( "EKJ_POSTAL", AV_TIPO) } )

   if lCpoCodTin
      aAdd( aCampos, {"EKJ_CODTIN" , "tin"              , oModelEKJ:getvalue("EKJ_CODTIN") , AVSX3( "EKJ_CODTIN", AV_TIPO) } )
   endif

   if lCpoEmail
      aAdd( aCampos, {"EKJ_EMAIL"  , "email"            , oModelEKJ:getvalue("EKJ_EMAIL")  , AVSX3( "EKJ_EMAIL", AV_TIPO) } )
   endif

   if !empty(cIdenAdic)
      aAdd( aCampos, {"EKT"        , "identificacoesAdicionais", cIdenAdic, "C" } )
   endif

   lAltBase := VerifAlt(oModelEKT, aCampos)

   // Teve alteração e está bloqueado
   if lAltBase .and. !(oModelEKJ:getvalue("EKJ_STATUS") == "5")  // "Desativados" 
      if EKJ->EKJ_MSBLQL == "1" .and. oModelEKJ:getvalue("EKJ_MSBLQL") == '1'
         if lOE400Auto .or. ( lRet := MsgYesNo(STR0084) ) // "Devido a alteração dos campos que são integrados com o Portal Único, o registro será desbloqueado. Deseja realmente desbloquear?"
            oModelEKJ:loadvalue("EKJ_MSBLQL", "2")
         endif
         if( !lRet, (cMsgError := STR0085 ) , nil ) // "Operação cancelada." ### "Atenção"
      endif
   endif
 
   if oModelEKJ:getvalue("EKJ_STATUS") == "3" // "Pendente Retificação"
      cLogInteg := EKJ->EKJ_LOG
      if !empty(cLogInteg) .and. (nPosMsgRet := at( STR0065 , cLogInteg)) > 0 .and. (nPosMsgEnv := at( STR0064 , cLogInteg)) > 0 // "Mensagem de retorno" ### Mensagem de envio" 
         cMsgRet := substr( cLogInteg, nPosMsgRet + len( STR0065 + ":") ) // "Mensagem de retorno"
         cMsgRet := substr( cMsgRet, 1 , at( ENTER , cMsgRet))
         cMsgRet := '{"items":'+cMsgRet+'}'
         oJson    := JsonObject():New()
         cRetJson := oJson:FromJson(cMsgRet)
         if valtype(cRetJson) == "U" .and. valtype(aJson := oJson:GetJsonObject("items")) == "A"
            if len(aJson) > 0
               aAtribJson := aJson[1]:getNames()
               if aScan( aAtribJson , { |X| X == "sucesso"}) > 0
                  lSucesso := aJson[1]["sucesso"]
               endif
            endif
         endif
         FwFreeObj(oJson)

         if lSucesso

            cMsgEnvio := substr( cLogInteg, nPosMsgEnv + len( STR0064 + ":")) // "Mensagem de envio" 
            cMsgEnvio := substr( cMsgEnvio, 1 , at( ENTER , cMsgEnvio))
            cMsgEnvio := '{"items":'+cMsgEnvio+'}'
            oJson := JsonObject():New()
            cRetJson := oJson:FromJson(cMsgEnvio)
            if valtype(cRetJson) == "U" .and. valtype(aJson := oJson:GetJsonObject("items")) == "A"
               if len(aJson) > 0
                  aAtribJson := aJson[1]:getNames()
                  for nCampos := 1 to len(aCampos)
                     // Caso encontre no json e tenha sido alterado OU não encontre no json mas está com conteudo no campo
                     nPosJson := aScan( aAtribJson, { |X| X == aCampos[nCampos][2] } ) 
                     if ( nPosJson > 0 .and. (aCampos[nCampos][4] == "C" .and. !(alltrim(aJson[1][aCampos[nCampos][2]]) == alltrim( aCampos[nCampos][3]) )) .or. (!(aCampos[nCampos][4] == "C") .and. !aJson[1][aCampos[nCampos][2]] == aCampos[nCampos][3] ) ) ;
                        .or. ;
                        ( nPosJson == 0 .and. !empty(aCampos[nCampos][3]))
                        lAltJson := .T.
                        exit    
                     endif
                  next
                  if aScan( aAtribJson, { |X| X == "situacao" } ) > 0
                     lAtivado := alltrim(upper(aJson[1]["situacao"])) == "ATIVADO"
                  endif
               endif
            endif
            
            FwFreeObj(oJson)

         endif

      endif

      if lAltJson .and. EKJ->EKJ_MSBLQL == "2" .and. oModelEKJ:getvalue("EKJ_MSBLQL") == "1" .and. !lAtivado
         cMsgError := STR0087 // "Não é possível bloquear o Operador Estrangeiro."
         cMsgSoluc := STR0088 // "O operador estrangeiro está desativado no Portal Único e está com status Pendente de Retificação devido a alteração salva. Deverá ser realizado a integração para a atualização de seus dados no Portal Único e sua ativação ou altere os dados para serem iguais ao do Portal Único."
         lRet := .F.
      endif

      if !lAltJson .and. lSucesso
         oModelEKJ:loadvalue("EKJ_STATUS", if( lAtivado, "1", "5"))
      endif
   elseif (lAltBase .or. !(EKJ->EKJ_MSBLQL == oModelEKJ:getvalue("EKJ_MSBLQL"))) .and. !(oModelEKJ:getvalue("EKJ_STATUS") == "5")  // "Desativados" 
      if empty(EKJ->EKJ_TIN)
         oModelEKJ:loadvalue("EKJ_STATUS", "2") // "Pendente Registro"
      else
         oModelEKJ:loadvalue("EKJ_STATUS", "3") // "Pendente Retificação"         
      endif
   endif

return lRet

/*
Programa   : COE400Legen
Objetivo   : Demonstra a legenda das cores da mbrowse
Retorno    : .T.
Autor      : Nilson Cesar
Data/Hora  : 27/11/2019
Obs.       :
*/
Function COE400Legen()
Local aCores := {}

   aCores := { {"ENABLE"      ,STR0027 },;   // "Registrado"
               {"BR_AMARELO"  ,STR0028 },;   // "Pendente Registro"
               {"BR_VERMELHO" ,STR0029 },;   // "Pendente de Retificação
               {"BR_PRETO"    ,STR0030 },;   // "Falha de Integração"
               {"BR_LARANJA"  ,STR0083 }}    // "Desativados"

   BrwLegenda(STR0006,STR0031,aCores)

Return .T.

/*
Programa   : COE400AgEm
Objetivo   : Utilizado na consulta padrão da Agencia Emissora do número da identificação (EKT_AGEEMI)
             https://service.unece.org/trade/untdid/d20b/tred/tred3055.htm
Retorno    : .T.
Autor      : Bruno Kubagawa
Data/Hora  : 20/03/2023
Obs.       :
*/
function COE400AgEm()
   local lRet       := .F.
   local cAliasTmp  := OE400_F3
   local aBckRot    := {}
   local aBckCampo  := {}
   local cAliasSel  := alias()
   local oDlgAgen   := nil
   local oBrAgen    := nil
   local aStruct    := {}
   local nCpo       := 0
   local aColumns   := {}
   local nOpc       := 0
 
   aBckRot := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
   aRotina := {}
   aBckCampo := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
   aCampos := {}

   aStruct := (cAliasTmp)->(dbStruct())
   for nCpo := 1 To Len(aStruct)
      if !(aStruct[nCpo][1] $ "RECNO||SEQUENCIA")
         aAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nCpo][1]+"}") )
         if aStruct[nCpo][1] == "CODIGO"
            aColumns[Len(aColumns)]:SetTitle( STR0055 ) // "Código"
         elseif aStruct[nCpo][1] == "DESCRICAO"
            aColumns[Len(aColumns)]:SetTitle( STR0056 ) // "Descrição"
         endif
         aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
         aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
         aColumns[Len(aColumns)]:SetPicture( "" )
      endif	
   next nCpo 

   oDlgAgen := FWDialogModal():New()
   oDlgAgen:setEscClose(.F.)
   oDlgAgen:setTitle( OemTOAnsi( STR0054 )) // "Agências Emissoras" 
   oDlgAgen:setSize(250, 340)
   oDlgAgen:enableFormBar(.F.)
   oDlgAgen:createDialog()

   oBrAgen := FWMBrowse():New()
   oBrAgen:SetOwner( oDlgAgen:getPanelMain() )
   oBrAgen:SetAlias( cAliasTmp )
   oBrAgen:AddButton( OemTOAnsi(STR0057) , { || nOpc := 1 , oDlgAgen:DeActivate() },, 2 ) // "Confirmar"
   oBrAgen:AddButton( OemTOAnsi(STR0058)  , { || oDlgAgen:DeActivate() },, 2 ) // "Cancelar"
   oBrAgen:SetColumns( aColumns )
   oBrAgen:SetMenuDef("")
   oBrAgen:SetTemporary(.T.)
   oBrAgen:DisableDetails()
   oBrAgen:DisableFilter()
   oBrAgen:DisableConfig()
   oBrAgen:DisableReport()
   oBrAgen:SetDoubleClick({ || nOpc := 1 , oDlgAgen:DeActivate() })
   oBrAgen:Activate()

   oDlgAgen:Activate()

   if nOpc == 1 .and. (cAliasTmp)->(!eof()) .and. (cAliasTmp)->(!bof())
      lRet := .T.
   endif

   fwFreeObj(oDlgAgen)

   if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)
   if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)
   if(!empty(cAliasSel),dbSelectArea(cAliasSel),nil)

return lRet

/*
Função     : COE400RAgEm
Objetivo   : Função de retorno
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function COE400RAgEm()
   local cAgencia   := ""
   local cAliasTmp  := OE400_F3

   if (cAliasTmp)->(!eof())
      cAgencia := (cAliasTmp)->CODIGO
   endif

return cAgencia

/*
Função     : loadAgeEmi
Objetivo   : Função para carregar as agencias identificadoras na tabela temporaria
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function loadAgeEmi()
   local cAliasTmp  := ""
   local aListAgenc := {}
   local nAgencia   := 0
   local nTam       := 0

   cAliasTmp := OE400_F3
   clearTmp(cAliasTmp)

   nTam := len((cAliasTmp)->SEQUENCIA)
   aListAgenc := getAgeEmis()
   for nAgencia := 1 to len( aListAgenc )
      reclock(cAliasTmp, .T.)
      (cAliasTmp)->SEQUENCIA := strZero( nAgencia, nTam)
      (cAliasTmp)->CODIGO := aListAgenc[nAgencia][1]
      (cAliasTmp)->DESCRICAO := aListAgenc[nAgencia][2]
      (cAliasTmp)->(msUnLock())
   next nAgencia

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
   local aSemSX3    := {}
   local cArqTab    := ""
   local cIndExt    := ""
   local cIndex1    := ""
   local cIndex2    := ""

   // ---- Criação da tabela temporaria para a consulta padrão das agencias emissoras da identificação
   cAliasTmp := OE400_F3
   if Select(cAliasTmp) == 0
 
      aCampos := {}
      aSemSX3 := {}
      aAdd(aSemSX3, {"SEQUENCIA" , "C" , 003 , 0 })
      aAdd(aSemSX3, {"CODIGO"    , "C" , 003 , 0 })
      aAdd(aSemSX3, {"DESCRICAO" , "C" , 150 , 0 })
      aAdd(aSemSX3, {"RECNO"     , "N" , 010 , 0 })
  
      cArqTab := e_criatrab(, aSemSX3, cAliasTmp )

      cIndExt := TEOrdBagExt()
      E_IndRegua( cAliasTmp , cArqTab+cIndExt, "SEQUENCIA")

      cIndex1 := e_create()
      E_IndRegua( cAliasTmp , cIndex1+cIndExt, "CODIGO")

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
         (cAliasTmp)->(E_EraseArq(cTabArq,cIndex1,cIndex2))
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
Função     : getAgeEmis
Objetivo   : Função retorna as agencias emissoras de identificação
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getAgeEmis()
   local aAgencias := {}

   aAdd( aAgencias , { "1"   , "CCC (Customs Co-operation Council)" } )
   aAdd( aAgencias , { "2"   , "CEC (Commission of the European Communities)" } )
   aAdd( aAgencias , { "3"   , "IATA (International Air Transport Association)" } )
   aAdd( aAgencias , { "4"   , "ICC (International Chamber of Commerce)" } )
   aAdd( aAgencias , { "5"   , "ISO (International Organization for Standardization)" } )
   aAdd( aAgencias , { "6"   , "UN/ECE (United Nations - Economic Commission for Europe)" } )
   aAdd( aAgencias , { "7"   , "CEFIC (Conseil Europeen des Federations de l'Industrie Chimique)" } )
   aAdd( aAgencias , { "8"   , "EDIFICE" } )
   aAdd( aAgencias , { "9"   , "GS1" } )
   aAdd( aAgencias , { "10"  , "ODETTE" } )
   aAdd( aAgencias , { "11"  , "Lloyd's register of shipping" } )
   aAdd( aAgencias , { "12"  , "UIC (International union of railways)" } )
   aAdd( aAgencias , { "13"  , "ICAO (International Civil Aviation Organization)" } )
   aAdd( aAgencias , { "14"  , "ICS (International Chamber of Shipping)" } )
   aAdd( aAgencias , { "15"  , "RINET (Reinsurance and Insurance Network)" } )
   aAdd( aAgencias , { "16"  , "US, D&B (Dun & Bradstreet Corporation)" } )
   aAdd( aAgencias , { "17"  , "S.W.I.F.T." } )
   aAdd( aAgencias , { "18"  , "Conventions on SAD and transit (EC and EFTA)" } )
   aAdd( aAgencias , { "19"  , "FRRC (Federal Reserve Routing Code)" } )
   aAdd( aAgencias , { "20"  , "BIC (Bureau International des Containeurs)" } )
   aAdd( aAgencias , { "21"  , "Assigned by transport company" } )
   aAdd( aAgencias , { "22"  , "US, ISA (Information Systems Agreement)" } )
   aAdd( aAgencias , { "23"  , "FR, EDITRANSPORT" } )
   aAdd( aAgencias , { "24"  , "AU, ROA (Railways of Australia)" } )
   aAdd( aAgencias , { "25"  , "EDITEX (Europe)" } )
   aAdd( aAgencias , { "26"  , "NL, Foundation Uniform Transport Code" } )
   aAdd( aAgencias , { "27"  , "US, FDA (Food and Drug Administration)" } )
   aAdd( aAgencias , { "28"  , "EDITEUR (European book sector electronic data interchange group)" } )
   aAdd( aAgencias , { "29"  , "GB, FLEETNET" } )
   aAdd( aAgencias , { "30"  , "GB, ABTA (Association of British Travel Agencies)" } )
   aAdd( aAgencias , { "31"  , "FI, Finish State Railway" } )
   aAdd( aAgencias , { "32"  , "PL, Polish State Railway" } )
   aAdd( aAgencias , { "33"  , "BG, Bulgaria State Railway" } )
   aAdd( aAgencias , { "34"  , "RO, Rumanian State Railway" } )
   aAdd( aAgencias , { "35"  , "CZ, Tchechian State Railway" } )
   aAdd( aAgencias , { "36"  , "HU, Hungarian State Railway" } )
   aAdd( aAgencias , { "37"  , "GB, British Railways" } )
   aAdd( aAgencias , { "38"  , "ES, Spanish National Railway" } )
   aAdd( aAgencias , { "39"  , "SE, Swedish State Railway" } )
   aAdd( aAgencias , { "40"  , "NO, Norwegian State Railway" } )
   aAdd( aAgencias , { "41"  , "DE, German Railway" } )
   aAdd( aAgencias , { "42"  , "AT, Austrian Federal Railways" } )
   aAdd( aAgencias , { "43"  , "LU, Luxembourg National Railway Company" } )
   aAdd( aAgencias , { "44"  , "IT, Italian State Railways" } )
   aAdd( aAgencias , { "45"  , "NL, Netherlands Railways" } )
   aAdd( aAgencias , { "46"  , "CH, Swiss Federal Railways" } )
   aAdd( aAgencias , { "47"  , "DK, Danish State Railways" } )
   aAdd( aAgencias , { "48"  , "FR, French National Railway Company" } )
   aAdd( aAgencias , { "49"  , "BE, Belgian National Railway Company" } )
   aAdd( aAgencias , { "50"  , "PT, Portuguese Railways" } )
   aAdd( aAgencias , { "51"  , "SK, Slovakian State Railways" } )
   aAdd( aAgencias , { "52"  , "IE, Irish Transport Company" } )
   aAdd( aAgencias , { "53"  , "FIATA (International Federation of Freight Forwarders Associations)" } )
   aAdd( aAgencias , { "54"  , "IMO (International Maritime Organisation)" } )
   aAdd( aAgencias , { "55"  , "US, DOT (United States Department of Transportation)" } )
   aAdd( aAgencias , { "56"  , "TW, Trade-van" } )
   aAdd( aAgencias , { "57"  , "TW, Chinese Taipei Customs" } )
   aAdd( aAgencias , { "58"  , "EUROFER" } )
   aAdd( aAgencias , { "59"  , "DE, EDIBAU" } )
   aAdd( aAgencias , { "60"  , "Assigned by national trade agency" } )
   aAdd( aAgencias , { "61"  , "Association Europeenne des Constructeurs de Materiel Aerospatial (AECMA)" } )
   aAdd( aAgencias , { "62"  , "US, DIstilled Spirits Council of the United States (DISCUS)" } )
   aAdd( aAgencias , { "63"  , "North Atlantic Treaty Organization (NATO)" } )
   aAdd( aAgencias , { "64"  , "FR, CLEEP" } )
   aAdd( aAgencias , { "65"  , "GS1 France" } )
   aAdd( aAgencias , { "66"  , "MY, Malaysian Customs and Excise" } )
   aAdd( aAgencias , { "67"  , "MY, Malaysia Central Bank" } )
   aAdd( aAgencias , { "68"  , "GS1 Italy" } )
   aAdd( aAgencias , { "69"  , "US, National Alcohol Beverage Control Association (NABCA)" } )
   aAdd( aAgencias , { "70"  , "MY, Dagang.Net" } )
   aAdd( aAgencias , { "71"  , "US, FCC (Federal Communications Commission)" } )
   aAdd( aAgencias , { "72"  , "US, MARAD (Maritime Administration)" } )
   aAdd( aAgencias , { "73"  , "US, DSAA (Defense Security Assistance Agency)" } )
   aAdd( aAgencias , { "74"  , "US, NRC (Nuclear Regulatory Commission)" } )
   aAdd( aAgencias , { "75"  , "US, ODTC (Office of Defense Trade Controls)" } )
   aAdd( aAgencias , { "76"  , "US, ATF (Bureau of Alcohol, Tobacco and Firearms)" } )
   aAdd( aAgencias , { "77"  , "US, BXA (Bureau of Export Administration)" } )
   aAdd( aAgencias , { "78"  , "US, FWS (Fish and Wildlife Service)" } )
   aAdd( aAgencias , { "79"  , "US, OFAC (Office of Foreign Assets Control)" } )
   aAdd( aAgencias , { "80"  , "BRMA/RAA - LIMNET - RINET Joint Venture" } )
   aAdd( aAgencias , { "81"  , "RU, (SFT) Society for Financial Telecommunications" } )
   aAdd( aAgencias , { "82"  , "NO, Enhetsregisteret ved Bronnoysundregisterne" } )
   aAdd( aAgencias , { "83"  , "US, National Retail Federation" } )
   aAdd( aAgencias , { "84"  , "DE, BRD (Gesetzgeber der Bundesrepublik Deutschland)" } )
   aAdd( aAgencias , { "85"  , "North America, Telecommunications Industry Forum" } )
   aAdd( aAgencias , { "86"  , "Assigned by party originating the message" } )
   aAdd( aAgencias , { "87"  , "Assigned by carrier" } )
   aAdd( aAgencias , { "88"  , "Assigned by owner of operation" } )
   aAdd( aAgencias , { "89"  , "Assigned by distributor" } )
   aAdd( aAgencias , { "90"  , "Assigned by manufacturer" } )
   aAdd( aAgencias , { "91"  , "Assigned by seller or seller's agent" } )
   aAdd( aAgencias , { "92"  , "Assigned by buyer or buyer's agent" } )
   aAdd( aAgencias , { "93"  , "AT, Austrian Customs" } )
   aAdd( aAgencias , { "94"  , "AT, Austrian PTT" } )
   aAdd( aAgencias , { "95"  , "AU, Australian Customs Service" } )
   aAdd( aAgencias , { "96"  , "CA, Revenue Canada, Customs and Excise" } )
   aAdd( aAgencias , { "97"  , "CH, Administration federale des contributions" } )
   aAdd( aAgencias , { "98"  , "CH, Direction generale des douanes" } )
   aAdd( aAgencias , { "99"  , "CH, Division des importations et exportations, OFAEE" } )
   aAdd( aAgencias , { "100" , "CH, Entreprise des PTT" } )
   aAdd( aAgencias , { "101" , "CH, Carbura" } )
   aAdd( aAgencias , { "102" , "CH, Centrale suisse pour l'importation du charbon" } )
   aAdd( aAgencias , { "103" , "CH, Office fiduciaire des importateurs de denrees alimentaires" } )
   aAdd( aAgencias , { "104" , "CH, Association suisse code des articles" } )
   aAdd( aAgencias , { "105" , "DK, Ministry of taxation, Central Customs and Tax Administration" } )
   aAdd( aAgencias , { "106" , "FR, Direction generale des douanes et droits indirects" } )
   aAdd( aAgencias , { "107" , "FR, INSEE" } )
   aAdd( aAgencias , { "108" , "FR, Banque de France" } )
   aAdd( aAgencias , { "109" , "GB, H.M. Customs & Excise" } )
   aAdd( aAgencias , { "110" , "IE, Revenue Commissioners, Customs AEP project" } )
   aAdd( aAgencias , { "111" , "US, U.S. Customs Service" } )
   aAdd( aAgencias , { "112" , "US, U.S. Census Bureau" } )
   aAdd( aAgencias , { "113" , "GS1 US" } )
   aAdd( aAgencias , { "114" , "US, ABA (American Bankers Association)" } )
   aAdd( aAgencias , { "116" , "US, ANSI ASC X12" } )
   aAdd( aAgencias , { "117" , "AT, Geldausgabeautomaten-Service Gesellschaft m.b.H." } )
   aAdd( aAgencias , { "118" , "SE, Svenska Bankfoereningen" } )
   aAdd( aAgencias , { "119" , "IT, Associazione Bancaria Italiana" } )
   aAdd( aAgencias , { "120" , "IT, Socieata' Interbancaria per l'Automazione" } )
   aAdd( aAgencias , { "121" , "CH, Telekurs AG" } )
   aAdd( aAgencias , { "122" , "CH, Swiss Securities Clearing Corporation" } )
   aAdd( aAgencias , { "123" , "NO, Norwegian Interbank Research Organization" } )
   aAdd( aAgencias , { "124" , "NO, Norwegian Bankers' Association" } )
   aAdd( aAgencias , { "125" , "FI, The Finnish Bankers' Association" } )
   aAdd( aAgencias , { "126" , "US, NCCMA (Account Analysis Codes)" } )
   aAdd( aAgencias , { "127" , "DE, ARE (AbRechnungs Einheit)" } )
   aAdd( aAgencias , { "128" , "BE, Belgian Bankers' Association" } )
   aAdd( aAgencias , { "129" , "BE, Belgian Ministry of Finance" } )
   aAdd( aAgencias , { "130" , "DK, Danish Bankers Association" } )
   aAdd( aAgencias , { "131" , "DE, German Bankers Association" } )
   aAdd( aAgencias , { "132" , "GB, BACS Limited" } )
   aAdd( aAgencias , { "133" , "GB, Association for Payment Clearing Services" } )
   aAdd( aAgencias , { "134" , "GB, APACS (Association of payment clearing services)" } )
   aAdd( aAgencias , { "135" , "GB, The Clearing House" } )
   aAdd( aAgencias , { "136" , "GS1 UK" } )
   aAdd( aAgencias , { "137" , "AT, Verband oesterreichischer Banken und Bankiers" } )
   aAdd( aAgencias , { "138" , "FR, CFONB (Comite francais d'organ. et de normalisation bancaires)" } )
   aAdd( aAgencias , { "139" , "Universal Postal Union (UPU)" } )
   aAdd( aAgencias , { "140" , "CEC (Commission of the European Communities), DG/XXI-01" } )
   aAdd( aAgencias , { "141" , "CEC (Commission of the European Communities), DG/XXI-B-1" } )
   aAdd( aAgencias , { "142" , "CEC (Commission of the European Communities), DG/XXXIV" } )
   aAdd( aAgencias , { "143" , "NZ, New Zealand Customs" } )
   aAdd( aAgencias , { "144" , "NL, Netherlands Customs" } )
   aAdd( aAgencias , { "145" , "SE, Swedish Customs" } )
   aAdd( aAgencias , { "146" , "DE, German Customs" } )
   aAdd( aAgencias , { "147" , "BE, Belgian Customs" } )
   aAdd( aAgencias , { "148" , "ES, Spanish Customs" } )
   aAdd( aAgencias , { "149" , "IL, Israel Customs" } )
   aAdd( aAgencias , { "150" , "HK, Hong Kong Customs" } )
   aAdd( aAgencias , { "151" , "JP, Japan Customs" } )
   aAdd( aAgencias , { "152" , "SA, Saudi Arabia Customs" } )
   aAdd( aAgencias , { "153" , "IT, Italian Customs" } )
   aAdd( aAgencias , { "154" , "GR, Greek Customs" } )
   aAdd( aAgencias , { "155" , "PT, Portuguese Customs" } )
   aAdd( aAgencias , { "156" , "LU, Luxembourg Customs" } )
   aAdd( aAgencias , { "157" , "NO, Norwegian Customs" } )
   aAdd( aAgencias , { "158" , "FI, Finnish Customs" } )
   aAdd( aAgencias , { "159" , "IS, Iceland Customs" } )
   aAdd( aAgencias , { "160" , "LI, Liechtenstein authority" } )
   aAdd( aAgencias , { "161" , "UNCTAD (United Nations - Conference on Trade And Development)" } )
   aAdd( aAgencias , { "162" , "CEC (Commission of the European Communities), DG/XIII-D-5" } )
   aAdd( aAgencias , { "163" , "US, FMC (Federal Maritime Commission)" } )
   aAdd( aAgencias , { "164" , "US, DEA (Drug Enforcement Agency)" } )
   aAdd( aAgencias , { "165" , "US, DCI (Distribution Codes, INC.)" } )
   aAdd( aAgencias , { "166" , "US, National Motor Freight Classification Association" } )
   aAdd( aAgencias , { "167" , "US, AIAG (Automotive Industry Action Group)" } )
   aAdd( aAgencias , { "168" , "US, FIPS (Federal Information Publishing Standard)" } )
   aAdd( aAgencias , { "169" , "CA, SCC (Standards Council of Canada)" } )
   aAdd( aAgencias , { "170" , "CA, CPA (Canadian Payment Association)" } )
   aAdd( aAgencias , { "171" , "NL, Interpay Girale Services" } )
   aAdd( aAgencias , { "172" , "NL, Interpay Debit Card Services" } )
   aAdd( aAgencias , { "173" , "NO, NORPRO" } )
   aAdd( aAgencias , { "174" , "DE, DIN (Deutsches Institut fuer Normung)" } )
   aAdd( aAgencias , { "175" , "FCI (Factors Chain International)" } )
   aAdd( aAgencias , { "176" , "BR, Banco Central do Brazil" } )
   aAdd( aAgencias , { "177" , "AU, LIFA (Life Insurance Federation of Australia)" } )
   aAdd( aAgencias , { "178" , "AU, SAA (Standards Association of Australia)" } )
   aAdd( aAgencias , { "179" , "US, Air transport association of America" } )
   aAdd( aAgencias , { "180" , "DE, BIA (Berufsgenossenschaftliches Institut fuer Arbeitssicherheit)" } )
   aAdd( aAgencias , { "181" , "Edibuild" } )
   aAdd( aAgencias , { "182" , "US, Standard Carrier Alpha Code (Motor)" } )
   aAdd( aAgencias , { "183" , "US, American Petroleum Institute" } )
   aAdd( aAgencias , { "184" , "AU, ACOS (Australian Chamber of Shipping)" } )
   aAdd( aAgencias , { "185" , "DE, BDI (Bundesverband der Deutschen Industrie e.V.)" } )
   aAdd( aAgencias , { "186" , "US, GSA (General Services Administration)" } )
   aAdd( aAgencias , { "187" , "US, DLMSO (Defense Logistics Management Standards Office)" } )
   aAdd( aAgencias , { "188" , "US, NIST (National Institute of Standards and Technology)" } )
   aAdd( aAgencias , { "189" , "US, DoD (Department of Defense)" } )
   aAdd( aAgencias , { "190" , "US, VA (Department of Veterans Affairs)" } )
   aAdd( aAgencias , { "191" , "IAPSO (United Nations Inter-Agency Procurement Services Office)" } )
   aAdd( aAgencias , { "192" , "Shipper's association" } )
   aAdd( aAgencias , { "193" , "EU, European Telecommunications Informatics Services (ETIS)" } )
   aAdd( aAgencias , { "194" , "AU, AQIS (Australian Quarantine and Inspection Service)" } )
   aAdd( aAgencias , { "195" , "CO, DIAN (Direccion de Impuestos y Aduanas Nacionales)" } )
   aAdd( aAgencias , { "196" , "US, COPAS (Council of Petroleum Accounting Society)" } )
   aAdd( aAgencias , { "197" , "US, DISA (Data Interchange Standards Association)" } )
   aAdd( aAgencias , { "198" , "CO, Superintendencia Bancaria De Colombia" } )
   aAdd( aAgencias , { "199" , "FR, Direction de la Comptabilite Publique" } )
   aAdd( aAgencias , { "200" , "GS1 Netherlands" } )
   aAdd( aAgencias , { "201" , "US, WSSA(Wine and Spirits Shippers Association)" } )
   aAdd( aAgencias , { "202" , "PT, Banco de Portugal" } )
   aAdd( aAgencias , { "203" , "FR, GALIA (Groupement pour l'Amelioration des Liaisons dans l'Industrie Automobile)" } )
   aAdd( aAgencias , { "204" , "DE, VDA (Verband der Automobilindustrie E.V.)" } )
   aAdd( aAgencias , { "205" , "IT, ODETTE Italy" } )
   aAdd( aAgencias , { "206" , "NL, ODETTE Netherlands" } )
   aAdd( aAgencias , { "207" , "ES, ODETTE Spain" } )
   aAdd( aAgencias , { "208" , "SE, ODETTE Sweden" } )
   aAdd( aAgencias , { "209" , "GB, ODETTE United Kingdom" } )
   aAdd( aAgencias , { "210" , "EU, EDI for financial, informational, cost, accounting, auditing and social areas (EDIFICAS) - Europe" } )
   aAdd( aAgencias , { "211" , "FR, EDI for financial, informational, cost, accounting, auditing and social areas (EDIFICAS) - France" } )
   aAdd( aAgencias , { "212" , "DE, Deutsch Telekom AG" } )
   aAdd( aAgencias , { "213" , "JP, NACCS Center (Nippon Automated Cargo Clearance System Operations Organization)" } )
   aAdd( aAgencias , { "214" , "US, AISI (American Iron and Steel Institute)" } )
   aAdd( aAgencias , { "215" , "AU, APCA (Australian Payments Clearing Association)" } )
   aAdd( aAgencias , { "216" , "US, Department of Labor" } )
   aAdd( aAgencias , { "217" , "US, N.A.I.C. (National Association of Insurance Commissioners)" } )
   aAdd( aAgencias , { "218" , "GB, The Association of British Insurers" } )
   aAdd( aAgencias , { "219" , "FR, d'ArvA" } )
   aAdd( aAgencias , { "220" , "FI, Finnish tax board" } )
   aAdd( aAgencias , { "221" , "FR, CNAMTS (Caisse Nationale de l'Assurance Maladie des Travailleurs Salaries)" } )
   aAdd( aAgencias , { "222" , "DK, Danish National Board of Health" } )
   aAdd( aAgencias , { "223" , "DK, Danish Ministry of Home Affairs" } )
   aAdd( aAgencias , { "224" , "US, Aluminum Association" } )
   aAdd( aAgencias , { "225" , "US, CIDX (Chemical Industry Data Exchange)" } )
   aAdd( aAgencias , { "226" , "US, Carbide Manufacturers" } )
   aAdd( aAgencias , { "227" , "US, NWDA (National Wholesale Druggist Association)" } )
   aAdd( aAgencias , { "228" , "US, EIA (Electronic Industry Association)" } )
   aAdd( aAgencias , { "229" , "US, American Paper Institute" } )
   aAdd( aAgencias , { "230" , "US, VICS (Voluntary Inter-Industry Commerce Standards)" } )
   aAdd( aAgencias , { "231" , "Copper and Brass Fabricators Council" } )
   aAdd( aAgencias , { "232" , "GB, Inland Revenue" } )
   aAdd( aAgencias , { "233" , "US, OMB (Office of Management and Budget)" } )
   aAdd( aAgencias , { "234" , "DE, Siemens AG" } )
   aAdd( aAgencias , { "235" , "AU, Tradegate (Electronic Commerce Australia)" } )
   aAdd( aAgencias , { "236" , "US, United States Postal Service (USPS)" } )
   aAdd( aAgencias , { "237" , "US, United States health industry" } )
   aAdd( aAgencias , { "238" , "US, TDCC (Transportation Data Coordinating Committee)" } )
   aAdd( aAgencias , { "239" , "US, HL7 (Health Level 7)" } )
   aAdd( aAgencias , { "240" , "US, CHIPS (Clearing House Interbank Payment Systems)" } )
   aAdd( aAgencias , { "241" , "PT, SIBS (Sociedade Interbancaria de Servicos)" } )
   aAdd( aAgencias , { "244" , "US, Department of Health and Human Services" } )
   aAdd( aAgencias , { "245" , "GS1 Denmark" } )
   aAdd( aAgencias , { "246" , "GS1 Germany" } )
   aAdd( aAgencias , { "247" , "US, HBICC (Health Industry Business Communication Council)" } )
   aAdd( aAgencias , { "248" , "US, ASTM (American Society of Testing and Materials)" } )
   aAdd( aAgencias , { "249" , "IP (Institute of Petroleum)" } )
   aAdd( aAgencias , { "250" , "US, UOP (Universal Oil Products)" } )
   aAdd( aAgencias , { "251" , "AU, HIC (Health Insurance Commission)" } )
   aAdd( aAgencias , { "252" , "AU, AIHW (Australian Institute of Health and Welfare)" } )
   aAdd( aAgencias , { "253" , "AU, NCCH (National Centre for Classification in Health)" } )
   aAdd( aAgencias , { "254" , "AU, DOH (Australian Department of Health)" } )
   aAdd( aAgencias , { "255" , "AU, ADA (Australian Dental Association)" } )
   aAdd( aAgencias , { "256" , "US, AAR (Association of American Railroads)" } )
   aAdd( aAgencias , { "257" , "ECCMA (Electronic Commerce Code Management Association)" } )
   aAdd( aAgencias , { "258" , "JP, Japanese Ministry of Transport" } )
   aAdd( aAgencias , { "259" , "JP, Japanese Maritime Safety Agency" } )
   aAdd( aAgencias , { "260" , "ebIX (European forum for energy Business Information eXchange)" } )
   aAdd( aAgencias , { "261" , "EEG7, European Expert Group 7 (Insurance)" } )
   aAdd( aAgencias , { "262" , "DE, GDV (Gesamtverband der Deutschen Versicherungswirtschaft e.V.)" } )
   aAdd( aAgencias , { "263" , "CA, CSIO (Centre for Study of Insurance Operations)" } )
   aAdd( aAgencias , { "264" , "FR, AGF (Assurances Generales de France)" } )
   aAdd( aAgencias , { "265" , "SE, Central bank" } )
   aAdd( aAgencias , { "266" , "US, DoA (Department of Agriculture)" } )
   aAdd( aAgencias , { "267" , "RU, Central Bank of Russia" } )
   aAdd( aAgencias , { "268" , "FR, DGI (Direction Generale des Impots)" } )
   aAdd( aAgencias , { "269" , "GRE (Reference Group of Experts)" } )
   aAdd( aAgencias , { "270" , "Concord EDI group" } )
   aAdd( aAgencias , { "271" , "InterContainer InterFrigo" } )
   aAdd( aAgencias , { "272" , "Joint Automotive Industry agency" } )
   aAdd( aAgencias , { "273" , "CH, SCC (Swiss Chambers of Commerce)" } )
   aAdd( aAgencias , { "274" , "ITIGG (International Transport Implementation Guidelines Group)" } )
   aAdd( aAgencias , { "275" , "ES, Banco de Espana" } )
   aAdd( aAgencias , { "276" , "Assigned by Port Community" } )
   aAdd( aAgencias , { "277" , "BIGNet (Business Information Group Network)" } )
   aAdd( aAgencias , { "278" , "Eurogate" } )
   aAdd( aAgencias , { "279" , "NL, Graydon" } )
   aAdd( aAgencias , { "280" , "FR, Euler" } )
   aAdd( aAgencias , { "281" , "GS1 Belgium and Luxembourg" } )
   aAdd( aAgencias , { "282" , "DE, Creditreform International e.V." } )
   aAdd( aAgencias , { "283" , "DE, Hermes Kreditversicherungs AG" } )
   aAdd( aAgencias , { "284" , "TW, Taiwanese Bankers' Association" } )
   aAdd( aAgencias , { "285" , "ES, Asociacion Espanola de Banca" } )
   aAdd( aAgencias , { "286" , "SE, TCO (Tjanstemannes Central Organisation)" } )
   aAdd( aAgencias , { "287" , "DE, FORTRAS (Forschungs- und Entwicklungsgesellschaft fur Transportwesen GMBH)" } )
   aAdd( aAgencias , { "288" , "OSJD (Organizacija Sotrudnichestva Zeleznih Dorog)" } )
   aAdd( aAgencias , { "289" , "JP.JIPDEC" } )
   aAdd( aAgencias , { "290" , "JP, JAMA" } )
   aAdd( aAgencias , { "291" , "JP, JAPIA" } )
   aAdd( aAgencias , { "292" , "FI, TIEKE The Information Technology Development Centre of Finland" } )
   aAdd( aAgencias , { "293" , "DE, BDEW (Bundesverband der Energie- und Wasserwirtschaft e.V.)" } )
   aAdd( aAgencias , { "294" , "GS1 Austria" } )
   aAdd( aAgencias , { "295" , "AU, Australian Therapeutic Goods Administration" } )
   aAdd( aAgencias , { "296" , "ITU (International Telecommunication Union)" } )
   aAdd( aAgencias , { "297" , "IT, Ufficio IVA" } )
   aAdd( aAgencias , { "298" , "GS1 Spain" } )
   aAdd( aAgencias , { "299" , "BE, Seagha" } )
   aAdd( aAgencias , { "300" , "SE, Swedish International Freight Association" } )
   aAdd( aAgencias , { "301" , "DE, BauDatenbank GmbH" } )
   aAdd( aAgencias , { "302" , "DE, Bundesverband des Deutschen Textileinzelhandels e.V." } )
   aAdd( aAgencias , { "303" , "GB, Trade Service Information Ltd (TSI)" } )
   aAdd( aAgencias , { "304" , "DE, Bundesverband Deutscher Heimwerker-, Bau- und Gartenfachmaerkte e.V." } )
   aAdd( aAgencias , { "305" , "ETSO (European Transmission System Operator)" } )
   aAdd( aAgencias , { "306" , "SMDG (Ship-planning Message Design Group)" } )
   aAdd( aAgencias , { "307" , "JP, Ministry of Justice" } )
   aAdd( aAgencias , { "309" , "JP, JASTPRO (Japan Association for Simplification of International Trade Procedures)" } )
   aAdd( aAgencias , { "310" , "DE, SAP AG (Systeme, Anwendungen und Produkte)" } )
   aAdd( aAgencias , { "311" , "JP, TDB (Teikoku Databank, Ltd.)" } )
   aAdd( aAgencias , { "312" , "FR, AGRO EDI EUROPE" } )
   aAdd( aAgencias , { "313" , "FR, Groupement National Interprofessionnel des Semences et Plants" } )
   aAdd( aAgencias , { "314" , "OAGi (Open Applications Group, Incorporated)" } )
   aAdd( aAgencias , { "315" , "US, STAR (Standards for Technology in Automotive Retail)" } )
   aAdd( aAgencias , { "316" , "GS1 Finland" } )
   aAdd( aAgencias , { "317" , "GS1 Brazil" } )
   aAdd( aAgencias , { "318" , "IETF (Internet Engineering Task Force)" } )
   aAdd( aAgencias , { "319" , "FR, GTF" } )
   aAdd( aAgencias , { "320" , "DK, Danish National IT and Telcom Agency (ITA)" } )
   aAdd( aAgencias , { "321" , "EASEE-Gas (European Association for the Streamlining of Energy Exchange for gas)" } )
   aAdd( aAgencias , { "322" , "IS, ICEPRO" } )
   aAdd( aAgencias , { "323" , "PROTECT" } )
   aAdd( aAgencias , { "324" , "GS1 Ireland" } )
   aAdd( aAgencias , { "325" , "GS1 Russia" } )
   aAdd( aAgencias , { "326" , "GS1 Poland" } )
   aAdd( aAgencias , { "327" , "GS1 Estonia" } )
   aAdd( aAgencias , { "328" , "Assigned by ultimate recipient of the message" } )
   aAdd( aAgencias , { "329" , "Assigned by loading dock operator" } )
   aAdd( aAgencias , { "330" , "Nordic Ediel Group" } )
   aAdd( aAgencias , { "331" , "US, Agricultural Marketing Service (AMS)" } )
   aAdd( aAgencias , { "332" , "DE, DVGW Service & Consult GmbH" } )
   aAdd( aAgencias , { "333" , "US, Animal and Plant Health Inspection Service (APHIS)" } )
   aAdd( aAgencias , { "334" , "US, Bureau of Labor Statistics (BLS)" } )
   aAdd( aAgencias , { "335" , "US, Bureau of Transportation Statistics (BTS)" } )
   aAdd( aAgencias , { "336" , "US, Customs and Border Protection (CBP)" } )
   aAdd( aAgencias , { "337" , "US, Center for Disease Control (CDC)" } )
   aAdd( aAgencias , { "338" , "US, Consumer Product Safety Commission (CPSC)" } )
   aAdd( aAgencias , { "339" , "US, Directorate of Defense Trade Controls (DDTC)" } )
   aAdd( aAgencias , { "340" , "US, Environmental Protection Agency (EPA)" } )
   aAdd( aAgencias , { "341" , "US, Federal Aviation Administration (FAA)" } )
   aAdd( aAgencias , { "342" , "US, Foreign Agriculture Service (FAS)" } )
   aAdd( aAgencias , { "343" , "US, Federal Motor Carrier Safety Administration (FMCSA)" } )
   aAdd( aAgencias , { "344" , "US, Food Safety Inspection Service (FSIS)" } )
   aAdd( aAgencias , { "345" , "US, Foreign Trade Zones Board (FTZB)" } )
   aAdd( aAgencias , { "346" , "US, The Grain Inspection, Packers and Stockyards Administration (GIPSA)" } )
   aAdd( aAgencias , { "347" , "US, Import Administration (IA)" } )
   aAdd( aAgencias , { "348" , "US, Internal Revenue Service (IRS)" } )
   aAdd( aAgencias , { "349" , "US, International Trade Commission (ITC)" } )
   aAdd( aAgencias , { "350" , "US, National Highway Traffic Safety Administration (NHTSA)" } )
   aAdd( aAgencias , { "351" , "US, National Marine Fisheries Service (NMFS)" } )
   aAdd( aAgencias , { "352" , "US, Office of Fossil Energy (OFE)" } )
   aAdd( aAgencias , { "353" , "US, Office of Foreign Missions (OFM)" } )
   aAdd( aAgencias , { "354" , "US, Bureau of Oceans and International Environmental and Scientific Affairs (OES)" } )
   aAdd( aAgencias , { "355" , "US, Office of Naval Intelligence (ONI)" } )
   aAdd( aAgencias , { "356" , "US, Pipeline and Hazardous Materials Safety Administration (PHMSA)" } )
   aAdd( aAgencias , { "357" , "US, Alcohol and Tobacco Tax and Trade Bureau (TTB)" } )
   aAdd( aAgencias , { "358" , "US, Army Corp of Engineers (USACE)" } )
   aAdd( aAgencias , { "359" , "US, Agency for International Development (USAID)" } )
   aAdd( aAgencias , { "360" , "US, Coast Guard (USCG)" } )
   aAdd( aAgencias , { "361" , "US, Office of the United States Trade Representative (USTR)" } )
   aAdd( aAgencias , { "362" , "International Commission for the Conservation of Atlantic Tunas (ICCAT)" } )
   aAdd( aAgencias , { "363" , "Inter-American Tropical Tuna Commission (IATTC)" } )
   aAdd( aAgencias , { "364" , "Commission for the Conservation of Southern Bluefin Tuna (CCSBT)" } )
   aAdd( aAgencias , { "365" , "Indian Ocean Tuna Commission (IOTC)" } )
   aAdd( aAgencias , { "366" , "International Botanical Congress" } )
   aAdd( aAgencias , { "367" , "International Commission on Zoological Nomenclature" } )
   aAdd( aAgencias , { "368" , "International Society for Horticulture Science" } )
   aAdd( aAgencias , { "369" , "Chemical Abstract Service (CAS)" } )
   aAdd( aAgencias , { "370" , "Social Security Administration (SSA)" } )
   aAdd( aAgencias , { "371" , "INMARSAT" } )
   aAdd( aAgencias , { "372" , "Agent of ship at the intended port of arrival" } )
   aAdd( aAgencias , { "373" , "US Air Force" } )
   aAdd( aAgencias , { "374" , "US, Bureau of Explosives" } )
   aAdd( aAgencias , { "375" , "Basel Convention Secretariat" } )
   aAdd( aAgencias , { "376" , "PANTONE" } )
   aAdd( aAgencias , { "377" , "IS, National Registry of Iceland" } )
   aAdd( aAgencias , { "378" , "IS, Internal Revenue Directorate of Iceland" } )
   aAdd( aAgencias , { "379" , "IANA (Internet Assigned Numbers Authority)" } )
   aAdd( aAgencias , { "380" , "Korea Customs Service" } )
   aAdd( aAgencias , { "381" , "Israel Tax Authority" } )
   aAdd( aAgencias , { "382" , "Israeli Ministry of Interior" } )
   aAdd( aAgencias , { "383" , "FR, LUMD (Logistique Urbaine Mutualisee Durable)" } )
   aAdd( aAgencias , { "384" , "DE, BiPRO (Brancheninitiative Prozessoptimierung)" } )
   aAdd( aAgencias , { "385" , "JO, Jordan Ministry of Agriculture" } )
   aAdd( aAgencias , { "386" , "JO, Jordan Customs" } )
   aAdd( aAgencias , { "387" , "JO, Jordan Food & Drug Administration" } )
   aAdd( aAgencias , { "388" , "JO, Jordan Institution for Standards and Metrology" } )
   aAdd( aAgencias , { "389" , "JO, Jordan Telecommunication Regulatory Commission" } )
   aAdd( aAgencias , { "390" , "JO, Jordan Nuclear Regulatory Commission" } )
   aAdd( aAgencias , { "391" , "JO, Jordan Ministry of Environment" } )
   aAdd( aAgencias , { "392" , "Hazardous waste collector" } )
   aAdd( aAgencias , { "393" , "Hazardous waste generator" } )
   aAdd( aAgencias , { "394" , "Marketing agent" } )
   aAdd( aAgencias , { "395" , "BE, TELEBIB Centre" } )
   aAdd( aAgencias , { "396" , "BE, BNB" } )
   aAdd( aAgencias , { "397" , "BE, FSMA" } )
   aAdd( aAgencias , { "398" , "FR, PHAST" } )
   aAdd( aAgencias , { "399" , "EXIS (Exis Technologies Ltd.)" } )
   aAdd( aAgencias , { "400" , "FAO (Food and Agriculture Organisation)" } )
   aAdd( aAgencias , { "401" , "CH, Spedlogswiss" } )
   aAdd( aAgencias , { "402" , "JP, National Tax Agency" } )
   aAdd( aAgencias , { "403" , "Comite Europeen de Normalisation" } )
   aAdd( aAgencias , { "404" , "Assigned by logistics service provider" } )
   aAdd( aAgencias , { "405" , "Assigned by transport ministry" } )
   aAdd( aAgencias , { "406" , "AR, Customs Administration of Argentina" } )
   aAdd( aAgencias , { "407" , "BO, Customs Administration of Bolivia" } )
   aAdd( aAgencias , { "408" , "BR, Customs Administration of Brazil" } )
   aAdd( aAgencias , { "409" , "PY, Customs Administration of Paraguay" } )
   aAdd( aAgencias , { "410" , "UY, Customs Administration of Uruguay" } )
   aAdd( aAgencias , { "411" , "VE, Customs Administration of Venezuela" } )
   aAdd( aAgencias , { "412" , "IN, Customs Administration of India" } )
   aAdd( aAgencias , { "413" , "JP, JEC (UN/CEFACT Japan Committee)" } )
   aAdd( aAgencias , { "ZZZ" , "Mutually defined" } )

return aAgencias

/*
Função     : getIdenAdc
Objetivo   : Função retorna as identificações adicionais para integração do operador estrangeiro
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function getIdenAdc(nRecEKJ, aJsonIden)
   local cRet       := ""
   local cIdenAdic  := ""
   local cFilEKT    := xFilial("EKT")
   local lAddJson   := .F.

   default nRecEKJ := EKJ->(recno())

   lAddJson := aJsonIden <> nil

   // EKT_FILIAL+EKT_CNPJ_R+EKT_FORN+EKT_FOLOJA+EKT_AGEEMI+EKT_NUMIDE
   if EKT->(dbSeek(cFilEKT + EKJ->EKJ_CNPJ_R + EKJ->EKJ_FORN + EKJ->EKJ_FOLOJA))
      cRet := '['
      while EKT->(!eof()) .and. ;
         EKT->EKT_FILIAL == cFilEKT .and. EKT->EKT_CNPJ_R == EKJ->EKJ_CNPJ_R .and. EKT->EKT_FORN == EKJ->EKJ_FORN .and. EKT->EKT_FOLOJA == EKJ->EKJ_FOLOJA

         cIdenAdic := '{ "codigo": "' + alltrim(EKT->EKT_AGEEMI) + '", '
         cIdenAdic += '"numero": "' + alltrim(EKT->EKT_NUMIDE) + '" }'
         cRet += cIdenAdic + ', '

         if lAddJson
            aAdd(aJsonIden, JsonObject():new())
            aJsonIden[len(aJsonIden)]["codigo"] := alltrim(EKT->EKT_AGEEMI)
            aJsonIden[len(aJsonIden)]["numero"] := alltrim(EKT->EKT_NUMIDE) 
         endif

         EKT->(dbSkip())
      end
      cRet := substr( cRet, 1 , len(cRet)-2)
      cRet += ']'
   endif
 
return cRet

/*
Função     : OE400AgDsc
Objetivo   : Função retorna o nome da agencia emissora de identificação
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
function OE400AgDsc(cCodAgen)
   local cRet       := ""
   local cAliasTmp  := OE400_F3
   local aAreaTmp   := {}
   local oModel     := FWModelActive()
   local oModelEKT  := nil

   default cCodAgen := ""

   if oModel <> nil .and. !FWIsInCallStack("ADDLINE")
      if !(oModel:getOperation() == MODEL_OPERATION_INSERT)
         cCodAgen := EKT->EKT_AGEEMI
      endif
      oModelEKT := oModel:getModel("EICOE400_EKT")
      if oModelEKT <> nil .and. oModelEKT:getLine() > 0 
         cCodAgen := oModelEKT:getValue("EKT_AGEEMI")
      endif
   endif

   if !empty(cCodAgen) .and. select(cAliasTmp) > 0 
      aAreaTmp := (cAliasTmp)->(getArea())
      (cAliasTmp)->(dbSetOrder(2)) // "CODIGO"
      if (cAliasTmp)->(dbSeek( cCodAgen ))
         cRet := (cAliasTmp)->DESCRICAO
      endif
      restArea(aAreaTmp)
   endif

return cRet

/*/{Protheus.doc} OE400Log
   Geração de log em pdf ou envio por email do operador estrangeiro

   @type  Function
   @author user
   @since 16/08/2023
   @version version
   @param nenhum
   @return nulo
/*/
function OE400Log()
return EasyLogPrt("1")

/*
Class      : OE400EV
Objetivo   : CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
class OE400EV FROM FWModelEvent
     
   Method New()
   Method VldActivate()

end class

/*
Class      : Método New Class LP500EV
Objetivo   : Método para criação do objeto
Retorno    : Nil
Autor      :
Data       :
Revisão    :
*/
Method New() Class OE400EV
Return

/*
Class      : Método New Class CP400EV
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method VldActivate(oModel) Class OE400EV
   local lRet       := .T.
   local cModoSA2   := FWModeAccess("SA2",3)
   local cModoEKJ   := FWModeAccess("EKJ",3)
   local cModoEKT   := FWModeAccess("EKT",3)

   if !cModoEKJ == cModoEKT .or. !cModoEKJ == cModoSA2
      easyHelp(STR0101, STR0017, STR0102) // "O compartilhamento está diferente entre as tabelas EKJ, EKT e SA2." ### "Atenção" ### "Verifique o compartilhamento através do Configurador."
      lRet := .F.
   endif

return lRet

/*/{Protheus.doc} OE400Integrar
   Função para realizar a integração do operador estrangeiro com o Portal Único

   @type  Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
function OE400Integrar(aOperInt, aExecIntOE, oProcess, oEasyJS, cPathInt, lIntgProd, lNewVers)
   local aAreaEKJ   := {}
   local lRet       := .T.
   local lRotOper   := .F.
   local lCancelou  := .F.
   local cError     := ""
   local cMsgError  := ""
   local cMsgSoluc  := ""

   default aOperInt   := {}
   default aExecIntOE := {}
   default oProcess   := nil
   default cPathInt   := ""
   default lIntgProd  := EasyGParam("MV_EIC0074", .F., "1") == "1"
   default lNewVers   := .F.

   aAreaEKJ := EKJ->(getArea())

   if len(aOperInt) == 0 .and. !FWIsInCallStack("EICCP402")
      if !lNewVers
         lRotOper := .T. // indica que a integração é pela rotina do operador estrangeiro - OE400Integrar
      endif

      if (lRet := (lNewVers .or. VldOper( @cMsgError, @cMsgSoluc)))
         aAdd(aOperInt, EKJ->(recno()) )
         cPathInt := AVGetUrl(,,@lCancelou,"EIC")
      endif
   endif

   if len(aOperInt) > 0 .and. lRet .and. !lCancelou .and. !empty(cPathInt)

      cMsgSoluc := ""
      if lRotOper .or. lNewVers
         oProcess := MsNewProcess():New( { || lRet := IntOperador(aOperInt, @aExecIntOE, cPathInt, oProcess, @oEasyJS, lIntgProd, @cError, @cMsgSoluc, lRotOper, lNewVers) }, STR0024, STR0025, .F.) // "Integrar Operador Estrangeiro" , "Processando integração"
         oProcess:Activate()
         if !empty(cError)
            cMsgError := cError
            cMsgSoluc := STR0072 + ". " + STR0073 + CHR(10) + CHR(10) // "Houve falha na integração do operador estrangeiro" #### "Para mais informações consulte o campo 'Log de integração'"
         endif

      else
         // Pela rotina de integração do catalogo de produtos - EICCP402
         lRet := IntOperador(aOperInt, @aExecIntOE, cPathInt, oProcess, @oEasyJS, lIntgProd, @cError, @cMsgSoluc, .F., .F.)
      endif

   endif

   if (lRotOper .or. lNewVers) .and. !lCancelou 
      if !lRet
         EasyHelp(cMsgError, STR0017, cMsgSoluc) // "Atenção"
      else
         MsgInfo(STR0032, STR0033) // "Registrado com sucesso" ### "Aviso"
      endif
   endif

   restArea(aAreaEKJ)

return lRet

/*/{Protheus.doc} VldOper
   Realiza a validação do operador estrangeiro antes de iniciar a integração

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function VldOper(cMsgError, cMsgSoluc)
   local lRet       := .T.

   default cMsgError  := ""
   default cMsgSoluc  := ""

   if EKJ->EKJ_STATUS == "1" // "Registrado"
      cMsgError := STR0049 // "Integração não realizada, operador estrangeiro já estava integrado"
      cMsgSoluc := STR0050 // "Posicione em um operador estrangeiro com o status diferente de integrado pra executar a integração"
      lRet := .F.

   elseif EKJ->EKJ_STATUS == "5" .or. ; // "Desativados"
      (( EKJ->EKJ_STATUS == "2" .or. empty(EKJ->EKJ_STATUS)) .and. EKJ->EKJ_MSBLQL == '1') // "Pendente Registro"
      cMsgError := if( EKJ->EKJ_STATUS == "5" , STR0086, STR0089) // "Operador Estrangeiro está desativado" ### "Operador Estrangeiro está bloqueado."
      cMsgSoluc := STR0104 // "Posicione em um operador estrangeiro que não esteja bloqueado ou desativado."
      lRet := .F.

   endif

return lRet

/*/{Protheus.doc} IntOperador
   Função que realiza o processamento de integração com o portal único para os operadores estrangeiros passado como parametro

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static Function IntOperador(aRegsEKJ, aExecIntOE, cPathInt, oProcess, oEasyJS, lIntgProd, cMsgError, cMsgSoluc, lRotOper, lNewVers)
   local lRet       := .T.
   local lAtualTIN  := .F.
   local lCpoCodTin := .F.
   local lCpoEmail  := .F.
   local aAreaEKT   := {}
   local cUserProc  := ""
   local cEndPoint  := ""
   local cLogInicio := ""
   local nQtdInt    := 0
   local cPathAuth  := ""
   local nOper      := 0
   local cReturnPU  := ""
   local cLogProc   := ""
   local cMsgProc   := ""
   local lDesativa  := .F.
   local cJsonOper  := ""
   local cCodPrtUni := ""
   local cVerPrtUni := ""

   default aRegsEKJ   := {}
   default aExecIntOE := {}
   default cPathInt   := AVGetUrl(,,,"EIC")
   default lIntgProd  := EasyGParam("MV_EIC0074", .F., "1") == "1"
   default cMsgError  := ""
   default cMsgSoluc  := ""
   default lRotOper   := .T.
   default lNewVers   := .F.

   CP400GtFil()

   lAtualTIN := avFlags("CATALOGO_PRODUTO")
   lCpoCodTin := EKJ->(ColumnPos("EKJ_CODTIN")) > 0
   lCpoEmail := EKJ->(ColumnPos("EKJ_EMAIL")) > 0

   if lAtualTIN
      aAreaEKT := EKT->(getArea())
      EKT->(dbSetOrder(1))
   endif

   cUserProc := UsrFullName(retCodUsr())
   cEndPoint := if( lIntgProd, EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br"), EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") )

   cLogInicio := STR0066 + " " + if( lIntgProd, STR0074, STR0075) + " - " + alltrim(cEndPoint) + ENTER // "Integração realizada no ambiente de" ### "Produção" ### "Treinamento"
   cLogInicio += dToc(Date()) +  " - " + Time() + " - " + STR0061 + ": " + cUserProc + ENTER + ENTER // "Usuário do sistema"

   nQtdInt := len(aRegsEKJ)
   if lRotOper .or. lNewVers

      oProcess:SetRegua1(3)
      cPathAuth := avGetAuth()
      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cPathAuth
      oEasyJS:setTimeOut(120)
      oEasyJS:AddLib( EasyAppFetch(cPathAuth) )
      oEasyJS:AddLib( OE400Script() )
      cMsgError := STR0090 // "Não foi possível acessar o site do Portal Único."
      cMsgSoluc := STR0105 // "Por favor, acesse novamente o sistema e tente realizar a integração."
      lRet := oEasyJS:Activate(.T.)
      if lRet
         oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplError);", {|x| lRet := comex.generics.EasyRetAut(x, @cMsgError, @cMsgSoluc) }, { |x| lRet := comex.generics.EasyRetAut(x, @cMsgError, @cMsgSoluc) } )
      endif

   else
      oProcess:SetRegua2(nQtdInt)
   endif

   if lRet

      for nOper := 1 to nQtdInt

         EKJ->(dbgoto(aRegsEKJ[nOper]))
         if EKJ->(recno()) == aRegsEKJ[nOper] .and. (lRet := (lNewVers .or. VldOper(@cMsgError)))

            CP400StFil(EKJ->EKJ_FILIAL)

            cMsgError := ""
            cReturnPU := ""

            cLogProc := STR0060 + ": " + ENTER + ENTER // "Detalhes da Integração"

            cMsgProc := STR0063 + ": " + if( !empty(EKJ->EKJ_FILIAL), EKJ->EKJ_FILIAL + "-", "" )  + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA // "Integrando operador estrangeiro"
            cLogProc += Time() + " - " + cMsgProc + ENTER + ENTER 

            if lRotOper .or. lNewVers
               oProcess:IncRegua1( cMsgProc )
            else
               oProcess:IncRegua2( cMsgProc )
            endif

            lDesativa := !empty(EKJ->EKJ_TIN) .and. EKJ->EKJ_MSBLQL == '1'
            cJsonOper := ""
         
            if !lDesativa .or. (!empty(EKJ->EKJ_TIN) .and. EKJ->EKJ_STATUS == "5" .and. lNewVers)// "Desativados"

               cJsonOper := getJsonOE(lAtualTIN, lCpoCodTin, lCpoEmail)
               if !empty(cJsonOper)
                  cLogProc += Time() + " - " + STR0064 + ": " + cJsonOper + ENTER + ENTER // "Mensagem de envio"
               endif

            endif

            if lRet .and. (!empty(cJsonOper) .or. lDesativa)

               if lRotOper .or. lNewVers
                  oProcess:IncRegua1( STR0106 + "..." ) // "Obtendo resposta do portal único"
               endif

               cReturnPU := EnvOper(cPathInt, lDesativa, cJsonOper, oEasyJS, @cMsgError, lNewVers)

               cLogProc += Time() + " - " + STR0065 + ": " // "Mensagem de retorno"
               cCodPrtUni := ""
               cVerPrtUni := ""
               lRet := procReturn(cReturnPU, @cMsgError, @cLogProc, @cCodPrtUni, @cVerPrtUni)

               cLogInicio += STR0067 + ": " + if( lRet, STR0068, STR0069 ) + ENTER // "Resultado da integração" ### "Sucesso" ### Erro
               cLogInicio += if( lRet, ENTER, STR0071 + ": " + cMsgError + ENTER + ENTER )   // "Mensagem de erro" 

               setEKJ(aRegsEKJ[nOper], (cLogInicio + cLogProc), cCodPrtUni, cVerPrtUni)

               // Integrado pela integração do catalogo de produtos
               if !lRotOper .and. !lNewVers
                  aAdd( aExecIntOE, { aRegsEKJ[nOper], lRet, cMsgError } )
               endif

            endif

         endif

      next nOper

   endif

   if lRotOper .or. lNewVers
      oEasyJS:Destroy()
   endif

   if lAtualTIN
      restArea(aAreaEKT)
   endif

   CP400StFil()

   if lRotOper .or. lNewVers
      oProcess:IncRegua1( STR0107 + " " + if( lRet, STR0068, STR0069) + "." ) // "Operação realizada com" ### "Sucesso" ### "Erro"
   endif

return lRet

/*/{Protheus.doc} getJsonOE
   Função gerar o json do operador estrangeiro para ser integrado no portal único

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getJsonOE(lAtualTIN, lCpoCodTin, lCpoEmail)
   local cJsonOper  := ""
   local cIdenAdic  := ""
   local aIdenAdic  := {}

   default lAtualTIN  := avFlags("CATALOGO_PRODUTO")
   default lCpoCodTin := EKJ->(ColumnPos("EKJ_CODTIN")) > 0
   default lCpoEmail  := EKJ->(ColumnPos("EKJ_EMAIL")) > 0

   if lAtualTIN
      cIdenAdic := getIdenAdc(EKJ->(recno()), @aIdenAdic)
   endif  

   /*-------------------------------------------------------------------------------
   {
      "tin": "123",
      "nome": "Fornecedor 123",
      "logradouro": "Rua teste, 155, Bairro teste",
      "nomeCidade": "Buenos Aires",
      "codigoSubdivisaoPais": "AR-B",
      "cep": "12345",
      "codigoInterno": "12345",
      "email": "email@email.com",
      "identificacoesAdicionais": [
         {
         "numero": "1232121212122",
         "codigo": "123"
         }
      ]
   }
   -------------------------------------------------------------------------------*/

   oJsonOpe := JsonObject():new()
   if( lCpoCodTin .and. !empty(EKJ->EKJ_CODTIN), oJsonOpe["tin"] := alltrim(EKJ->EKJ_CODTIN), nil)
   oJsonOpe["nome"] := alltrim(EKJ->EKJ_NOME)
   oJsonOpe["logradouro"] := alltrim(EKJ->EKJ_LOGR)
   oJsonOpe["nomeCidade"] := alltrim(EKJ->EKJ_CIDA)
   if( !empty(EKJ->EKJ_SUBP), oJsonOpe["codigoSubdivisaoPais"] := alltrim(EKJ->EKJ_SUBP), nil)
   if( !empty(EKJ->EKJ_POSTAL), oJsonOpe["cep"] := alltrim(EKJ->EKJ_POSTAL), nil)
   oJsonOpe["codigoInterno"] := if(!empty(xFilial("EKJ")), alltrim(xFilial("EKJ")) + "-","") + alltrim(EKJ->EKJ_FORN) + if( alltrim(EKJ->EKJ_FOLOJA) == ".", "", "/" + alltrim(EKJ->EKJ_FOLOJA))
   if( lCpoEmail .and. !empty(EKJ->EKJ_EMAIL), oJsonOpe["email"] := alltrim(EKJ->EKJ_EMAIL), "")  
   if( lAtualTIN .and. !empty(cIdenAdic), oJsonOpe["identificacoesAdicionais"] := aClone(aIdenAdic), "")

   cJsonOper := oJsonOpe:ToJson()

   FwFreeArray(aIdenAdic)
   FwFreeObj(oJsonOpe)

return cJsonOper

/*/{Protheus.doc} EnvOper
   Função que realiza o envio do operador estrangeiro para o portal único

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function EnvOper(cUrlPU, lDesativa, cJsonOper, oEasyJS, cError, lNewVers)
   local cRet       := ""
   local cScript    := ""
   local cPais      := ""
   local cCodPrtUni := ""
   local cVerPrtUni := ""
   local cMethodPU  := ""
   local cEndPoint  := ""

   default cUrlPU     := ""
   default lDesativa  := .F.
   default cJsonOper  := ""
   default cError     := ""
   default lNewVers   := .F.
 
   private cIntCpfCnpj := ""

   cIntCpfCnpj := alltrim(EKJ->EKJ_CNPJ_R)
   If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICOE400_INTEGRAR"),)

   cPais := alltrim(EKJ->EKJ_PAIS)
   cCodPrtUni := alltrim(EKJ->EKJ_TIN)
   cVerPrtUni := alltrim(EKJ->EKJ_VERSAO)

   cMethodPU := "POST"
   cEndPoint += "/catp/api/ext/operador-estrangeiro/"
   // caso seja desativação 
   if lDesativa .and. !lNewVers
      cEndPoint += "desativar/"
   endif
   cEndPoint += cIntCpfCnpj + "/" + cPais

   // caso seja uma retificação ou nova versão
   if !empty(cCodPrtUni)
      cMethodPU := "PUT"
      cEndPoint += "/" + cCodPrtUni + if( !lNewVers, "/" + cVerPrtUni, "")
   endif
   cUrlPU += cEndPoint

   do case
      // Inclusão do operador estrangeiro - pela ação Integrar
      case cMethodPU == "POST"
         begincontent var cScript
            insertOperador('%Exp:cUrlPU%', %Exp:cJsonOper%, retAdvplError, retAdvpl)
         endcontent

      // Retificação do operador estrangeiro - pela ação Integrar
      case cMethodPU == "PUT" .and. !lNewVers .and. !lDesativa
         begincontent var cScript
            updateOperador('%Exp:cUrlPU%', %Exp:cJsonOper%, retAdvplError, retAdvpl)
         endcontent

      // Desativação do operador estrangeiro - pela ação Integrar
      case cMethodPU == "PUT" .and. !lNewVers .and. lDesativa 
         begincontent var cScript
            disableOperador('%Exp:cUrlPU%', retAdvplError, retAdvpl)
         endcontent

      // Geração de nova versão ou ativação do operador estrangeiro - pela ação Gerar Nova Versão
      case cMethodPU == "PUT" .and. lNewVers
         begincontent var cScript
            newVersionOperador('%Exp:cUrlPU%', %Exp:cJsonOper%, retAdvplError, retAdvpl)
         endcontent

   end case

   oEasyJS:runJSSync( cScript, {|x| cRet := x } , {|x| cError := x } )

return cRet

/*/{Protheus.doc} procReturn
   Função que trata o retorno da integração do operador estrangeiro com o portal único

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function procReturn(cReturnPU, cMsgError, cLogReturn, cCodPrtUni, cVerPrtUni)
   local lRet       := .F.
   local oJson      := nil
   local cRetJson   := ""

   default cReturnPU  := ""
   default cMsgError  := ""
   default cLogReturn := ""
   default cCodPrtUni := ""
   default cVerPrtUni := ""

   if !empty(cReturnPU)

      oJson := JsonObject():New()
      cRetJson := oJson:FromJson(cReturnPU)
      cLogReturn += cReturnPU + ENTER

      cMsgError := if( !valtype(cRetJson) == "U", STR0077 + ENTER + ENTER + " " + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
      if empty(cMsgError)
         if oJson:hasProperty("message")
            cMsgError := oJson:GetJsonText("message")
            cMsgError += getError(oJson)
         endif
         if oJson:hasProperty("codigo") .and. valtype(oJson:GetJsonText("codigo")) == "C"
            cCodPrtUni  := oJson:GetJsonText("codigo")
         endif
         if oJson:hasProperty("versao") .and. valtype(oJson:GetJsonText("versao")) == "C"
            cVerPrtUni  := oJson:GetJsonText("versao")
         endif
         lRet := !empty(cCodPrtUni) .and. !empty(cVerPrtUni)
      endif
      FwFreeObj(oJson)

   else 
      cMsgError := if( empty(cMsgError), STR0020 , cMsgError) + ENTER // "Integração sem nenhum retorno!"
      cLogReturn += cMsgError + ENTER

   endif

return lRet

/*/{Protheus.doc} getError()
   Retorna os erros de integração do portal unico

   @type  Static Function
   @author user
   @since 05/12/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getError(oJsonResp)
   local cErrors    := ""
   local aError     := {}
   local nError     := 0

   if oJsonResp:hasProperty("detail")
      aError := if( valtype(oJsonResp:GetJsonObject("detail")) == "C", {oJsonResp:GetJsonObject("detail")}, oJsonResp:GetJsonObject("detail"))
      for nError := 1 to len(aError)
         if aError[nError]:hasProperty("error")
            if aError[nError]['error']:hasProperty("message") .and. !(aError[nError]['error']:GetJsonText("message") $ cErrors)
               cErrors += aError[nError]['error']:GetJsonText("message") + ENTER
            endif
         endif
      next
      cErrors := subStr(cErrors, 1, len(cErrors)-len(ENTER)) // Remove o ultimo ENTER adicionado
   endif   

return cErrors

/*/{Protheus.doc} setEKJ
   Função para gravação do retorno da integração na tabela EKJ

   @type  Static Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function setEKJ(nRecEKJ, cLogProc, cCodPrtUni, cVerPrtUni)

   default nRecEKJ    := 0
   default cLogProc   := ""
   default cCodPrtUni := ""
   default cVerPrtUni := ""

   EKJ->(dbgoto(nRecEKJ))
   if nRecEKJ == EKJ->(recno())

      reclock("EKJ",.F.)
      EKJ->EKJ_DATA := dDatabase
      EKJ->EKJ_HORA := strtran(time(),":","")
      EKJ->EKJ_USER := __cUserID
      EKJ->EKJ_LOG  := cLogProc
      if !empty(cCodPrtUni) .and. !empty(cVerPrtUni)
         if EKJ->EKJ_STATUS == "5" // "Desativados"
            EKJ->EKJ_MSBLQL := "2"
         endif
         EKJ->EKJ_STATUS := if( EKJ->EKJ_MSBLQL == "1", "5", "1" )
         EKJ->EKJ_TIN    := cCodPrtUni
         EKJ->EKJ_VERSAO := cVerPrtUni
      elseif !(EKJ->EKJ_STATUS == "5") // "Desativados"
         EKJ->EKJ_STATUS := "4"
      endif

      EKJ->(msunlock())

   endif

return nil

/*/{Protheus.doc} OE400Script
   Gera o script para consumir o serviço do portal unico através do easyjs

   @type  Static Function
   @author user
   @since 24/11/2023
   @version version
   @param cUrl, caracter, URL do portal unico da API
   @return cScript, caracter, script javascript
/*/
function OE400Script()
   local cScript := ''

   begincontent var cScript

      function insertOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

      function updateOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'PUT', sBody)
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

      function disableOperador(cUrl, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'PUT')
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

      function newVersionOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'PUT', sBody)
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

   endcontent

Return cScript

/*/{Protheus.doc} OE400NewVrs
   Função para realizar a integração do operador estrangeiro com o Portal Único

   @type  Function
   @author user
   @since 29/11/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
function OE400NewVrs()
   local lRet       := .F.
   local aAreaEKJ   := {}

   aAreaEKJ := EKJ->(getArea())
   if EKJ->(!eof())

      if !empty(EKJ->EKJ_TIN) .and. (!(EKJ->EKJ_MSBLQL == "1") .and. (EKJ->EKJ_STATUS == '3' .or. EKJ->EKJ_STATUS == '4') .or. ; // "Pendente Retificação" ### "Falha de Integração"
                                    ( EKJ->EKJ_MSBLQL == "1" .and. EKJ->EKJ_STATUS == '5' )) // "Desativados"
         // OE400Integrar(aOperInt, aExecIntOE, oProcess, oEasyJS, cPathInt, lIntgProd, lNewVers)
         lRet := OE400Integrar(,,,,,, .T.)
      else
         easyHelp(STR0108, STR0017, STR0109) // "Não é possível prosseguir com a integração do Operador Estrangeiro." ### "Atenção" ### "Esta ação só é possível para cadastros que encontram-se com a situação de pendência para retificação, assim como bloqueados e desativados."
         lRet := .F.
      endif

   endif
   restArea(aAreaEKJ)

return lRet
