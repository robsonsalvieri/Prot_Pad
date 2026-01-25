#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICOE400.CH"
#INCLUDE "AVERAGE.CH"

#define ALIAS_TEMP          1
#define ARQ_TAB             2
#define INDEX1              3
#define INDEX2              4
#define limiteInt           100

static _aTabsTmp  := {}
static OE400_F3 := "OE400_F3"

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

   aCores :={{"EKJ_STATUS == '1' "                       ,"ENABLE"      ,STR0027 },; // "Registrado"
            { "EKJ_STATUS == '2' .OR. EMPTY(EKJ_STATUS)" ,"BR_AMARELO"  ,STR0028 },; // "Pendente Registro"
            { "EKJ_STATUS == '3' "                       ,"BR_VERMELHO" ,STR0029 },; // "Pendente Retificação"
            { "EKJ_STATUS == '4' "                       ,"BR_PRETO"    ,STR0030 },; // "Falha de Integração"
            { "EKJ_STATUS == '5' "                       ,"BR_LARANJA"  ,STR0083 }}  // "Desativados"

   if  !lOE400Auto

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
   aAdd( aRotina, { STR0026 , 'OE400Integrar()'  , 0, 6, 0, NIL } )	//'Integrar'
   aAdd( aRotina, { STR0038 , 'OE400RecVers()'   , 0, 7, 0, NIL } )	//'Recuperar Versão'
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
Local lRet := .T.
Local oModel      := FWModelActive()
Local oModelEKJ   := oModel:GetModel("EICOE400_EKJ")

   Do Case 
      Case cCampo == "EKJ_IMPORT"
         if !empty(oModelEKJ:GetValue("EKJ_IMPORT"))
            If Empty(Posicione("SYT",1,xFilial("SYT")+oModelEKJ:GetValue("EKJ_IMPORT"),"YT_COD_IMP"))
               lRet := .F.
               easyHelp(STR0008) //Código do importador não encontrado
            ElseIf SYT->YT_IMP_CON <> "1"
               lRet := .F.
               easyHelp(STR0009) //"Código informado não é de importador"
            EndIf
         endif
      Case cCampo == "EKJ_TIN"
         //If !Empty(Posicione("EKJ",2,xFilial("EKJ")+oModelEKJ:GetValue("EKJ_TIN"),"EKJ_TIN"))
         //   lRet := .F.
           // easyHelp(STRTRAN(STR0007,####,":"+M->EKJ_TIN)) // Campo TIN:#### já existente
         //  easyHelp(STR0007) // Campo TIN já existente
         //EndIf
      Case (cCampo == "EKJ_FORN" .OR. cCampo == "EKJ_FOLOJA") .And. !empty(oModelEKJ:GetValue("EKJ_FORN")) .And. !empty(oModelEKJ:GetValue("EKJ_FOLOJA"))
         If empty(Posicione("SA2",1,xFilial("SA2")+oModelEKJ:GetValue("EKJ_FORN")+oModelEKJ:GetValue("EKJ_FOLOJA"),"A2_COD"))
            lRet := .F.
            easyHelp(STR0010) //Fornecedor e Loja não encontrados
         EndIf
         If !empty(Posicione("EKJ",1,xFilial("EKJ") + oModelEKJ:GetValue("EKJ_CNPJ_R") + oModelEKJ:GetValue("EKJ_FORN") + oModelEKJ:GetValue("EKJ_FOLOJA"),"EKJ_CNPJ_R"))
            lRet := .F.
            easyHelp(STR0035) //Importador, Fornecedor e Loja já existentes
         EndIf
      Case cCampo == "EKJ_VERMAN"
         If !Empty(oModelEKJ:GetValue("EKJ_VERMAN")) .and. !Empty(oModelEKJ:GetValue("EKJ_VERSAO"))
            lRet := (oModelEKJ:GetValue("EKJ_VERMAN") == oModelEKJ:GetValue("EKJ_VERSAO")) .Or. MsgYesNo(STR0043) // Deseja substituir a versão atual pela informação digitada?
            If !lRet
               easyHelp(STR0042) // Limpe o campo para prosseguir.
            EndIf
         EndIf
      Case cCampo == "EKJ_PAIS"
         if !empty(oModelEKJ:GetValue("EKJ_PAIS")) .and. !ExistCpo("ELO",oModelEKJ:GetValue("EKJ_PAIS"))
            lRet := .F.
            EasyHelp(STR0059, STR0017) // "Código do país conforme ISO-3166 invalido." ### "Atenção"
         EndIf
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

   default cMsgError  := ""
   default cMsgSoluc  := ""

   lOE400Auto := if( isMemVar("lOE400Auto"), lOE400Auto, .F.)
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
   if lAltBase 
      if EKJ->EKJ_MSBLQL == "1" .and. oModelEKJ:getvalue("EKJ_MSBLQL") == '1'
         if lOE400Auto .or. ( lRet := MsgYesNo(STR0084) ) // "Devido a alteração dos campos que são integrados com o Portal Único, o registro será desbloqueado. Deseja realmente desbloquear?"
            oModelEKJ:loadvalue("EKJ_MSBLQL", "2")
         endif
         if( !lRet, (cMsgError := STR0085 ) , nil ) // "Operação cancelada." ### "Atenção"
      endif
   endif
 
   if oModelEKJ:getvalue("EKJ_STATUS") == "3" 
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
   elseif lAltBase .or. !(EKJ->EKJ_MSBLQL == oModelEKJ:getvalue("EKJ_MSBLQL"))
      oModelEKJ:loadvalue("EKJ_STATUS", "3")
   endif

return lRet

/*
Programa   : OE400RecVers
Objetivo   : Função para recuperar a versão do Operador Estrangeiro diretamente do Portal Único
Retorno    : 
Autor      : Nícolas Castellani Brisque
Data/Hora  : Ago/2022
Obs.       :
*/
Function OE400RecVers()
   Local cUrlInteg   := ""
   Local cURLAuth    := ""
   Local cUrlGetVers := ""
   Local oEasyJS     := nil
   Local cErros      := ''
   Local cRet        := ""
   Local aResult     := {}
   Local lRet        := .T.
   Local lIntegrou   := .F.

   Private cIntCpfCnpj

   lRet := AvFlags("DUIMP_12.1.2310-22.4")
   If( !lRet, EasyHelp(STR0045, STR0033, STR0046) , nil )// Esta ação está indisponível para o release atual. #### "A ação estará disponível a partir do release 12.1.2310. #### Aviso

   if lRet

      cUrlInteg := AVgetUrl()
      if !empty(cUrlInteg)

         cIntCpfCnpj := alltrim(EKJ->EKJ_CNPJ_R)
         If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICOE400_RECUPERAR_VERSAO"),)

         cURLAuth    := cUrlInteg + "/portal/api/autenticar"
         cUrlGetVers := cUrlInteg + "/catp/api/ext/operador-estrangeiro?cpfCnpjRaiz=" + cIntCpfCnpj + "&codigo=" + alltrim(EKJ->EKJ_TIN)

         oEasyJS := EasyJS():New()
         oEasyJS:cUrl := cURLAuth
         oEasyJS:setTimeOut(30)
         oEasyJS:AddLib( EasyAppFetch(cUrlAuth) )
         oEasyJS:AddLib( OE400Script() )
         lRet := oEasyJS:Activate(.T.) //Ativa a tela que solicita o certificado

         If lRet
            oEasyJS:runJSSync( "getVersao('" + cUrlGetVers + "', retAdvplError, retAdvpl)", {|x| cRet := x }, {|x| cErros := x })
            aResult := getRetorno(cRet, @cErros)
            if empty(cErros) .and. len( aResult ) > 0
               lIntegrou := .T.
               recLock("EKJ",.F.)
               EKJ->EKJ_TIN := aResult[1]
               EKJ->EKJ_VERSAO := aResult[2]
               EKJ->(msUnlock())
               MsgInfo(STR0041, STR0033) // "Recuperado a versão com sucesso!" / "Aviso"
            else
               EasyHelp(STR0044 + CHR(10) + CHR(10) + cErros, STR0017) // "Houve uma falha na recuperação da versão do operador estrangeiro do Portal Único." / "Atenção"
            endif
         else
            EasyHelp(STR0090, STR0017) // "Não foi possível acessar o site do Portal Único." ### "Atenção"
         endif

         if oEasyJS <> nil
            oEasyJS:Destroy()
         endif

      endif
   endif

return lIntegrou

/*
Função:    getRetorno
Objetivo:  tratar o json retornado pelo portal e obter o código do Operador Estrangeiro e a Versão
Retorno:   aResult contendo o código do Operador Estrangeiro na primeira posição e a versão na segunda posição
Autor:     Maurício Frison
Data:      Maio/2022
*/
Static Function getRetorno(cMsg, cErros)
   Local cRet     := ""
   Local oJson    := nil
   local cRetJson := ""
   Local aJson    := {}
   Local aResult  := {}
   local cCodigo  := ""
   local cVersao  := ""
   local nError   := 0

   default cMsg    := ""
   default cErros  := ""

   if !empty(cMsg)

      cRet     := '{"items":'+cMsg+'}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)

      cErros := if( !valtype(cRetJson) == "U", STR0077 + ENTER + ENTER + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
      if empty(cErros)

         //cErros := if( valtype(oJson:GetJsonObject("items")) == "A", "", STR0018 + ENTER ) // "Arquivo de retorno sem itens!"  
         if valtype(oJson:GetJsonObject("items")) == "A"

            aJson := oJson:GetJsonObject("items")
            if len(aJson) > 0
               cCodigo := aJson[1]:GetJsonText("codigo")
               cCodigo := if(alltrim(cCodigo) == 'null', "", cCodigo)
               aAdd( aResult, cCodigo)
               cVersao := aJson[1]:GetJsonText("versao")
               cVersao := if(alltrim(cVersao) == 'null', "", cVersao)
               aAdd( aResult, cVersao)
               aJsonErros := if( valtype(aJson[1]:GetJsonObject("erros")) == "A", aJson[1]:GetJsonObject("erros"), if( valtype(aJson[1]:GetJsonObject("error")) == "C" , aJson[1]:GetJsonObject("error_description"), {}))
               if len(aJsonErros) > 0
                  cErros := if( valtype(aJson[1]:GetJsonObject("error")) == "C", aJson[1]:GetJsonObject("error") + ENTER, "")
                  for nError := 1 to len(aJsonErros)
                     cErros += alltrim(aJsonErros[nError]) + " " + ENTER
                  next
                  cErros += if(empty(cErros), STR0019 + ENTER,"") // "Arquivo de retorno inválido!"
               endif
            endif
         else
            cErros := STR0018 + ENTER // "Arquivo de retorno sem itens!"
            if oJson:HasProperty("items") .and. oJson:GetJsonObject("items"):HasProperty("message")
               cErros := oJson:GetJsonObject("items"):GetJsonObject("message")
            endif
         endif

      endif
      FwFreeObj(oJson)

   else
      cErros := if( match(cErros,"*Failed to fetch*"), STR0079 , if (empty(cErros), STR0020, cErros)) + ENTER // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto." ###  "Integração sem nenhum retorno!"

   endif

Return aResult

/*/{Protheus.doc} OE400Integrar
   Função para realizar a integração do operador estrangeiro com o siscomex
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   @param aOperadores - array com o recno do operador a ser integrado, se vazio registra o posicionado no browse
   @return Nil
   /*/
Function OE400Integrar(aOperadores, lIntegAuto, oLogView, oEasyJS, cLogInteg,oProc,aErros,lLote)
Local cErros      := ""
Local cPathInt    := ""
Local lRet        := .F.
Local oProcess     
local cURLIAOE    := ""
local cURLAuth    := ""
local cPathAuth   := ""
local cPathIAOE   := ""
local lProc       := .T.
local lCancelou   := .F.

Default aOperadores := {}
Default lIntegAuto  := .F.
default cLogInteg   := ""
Default aErros := {}
Default lLote := .f.
if oProc <> nil
   oProcess := oProc
EndIf   
lOE400Auto := if( isMemVar("lOE400Auto"), lOE400Auto, .F.)

If !lIntegAuto .And. EKJ->EKJ_STATUS == "1"
   easyhelp(STR0049,STR0033,STR0050) //"Integração não realizada, operador estrangeiro já estava integrado","AVISO","Posicione em um operador estrangeiro com o status diferente de integrado pra executar a integração"
Else
   begin sequence

      // Caso não receba parâmetro faz a inclusão do registro posicionado 
      if len(aOperadores) == 0
         if EKJ->EKJ_STATUS == "5" .or. (( EKJ->EKJ_STATUS == "2" .or. empty(EKJ->EKJ_STATUS)) .and. EKJ->EKJ_MSBLQL == '1' )
            lRet := .F.
            lProc := .F.
            EasyHelp( if( EKJ->EKJ_STATUS == "5" , STR0086, STR0089), "Atenção")  // "Operador Estrangeiro está desativado" ### "Operador Estrangeiro está bloqueado."
         else
            aadd(aOperadores, EKJ->(recno()) )
         endif
      endif

      if lProc

         cPathInt := AVgetUrl( , lOE400Auto .Or. lIntegAuto, @lCancelou, "EIC")
         cURLIAOE := "/catp/api/ext/operador-estrangeiro"
         cURLAuth := "/portal/api/autenticar"
      
         If lCancelou
            lRet := .F.
            break
         EndIf

         cPathAuth := cPathInt+cURLAuth
         cPathIAOE := cPathInt+cURLIAOE

         if !lIntegAuto .and. !lOE400Auto
            oProcess := MsNewProcess():New({|| lRet := OE400Sicomex(aOperadores, cPathAuth, cPathIAOE, oProcess, @cErros, @oLogView, @oEasyJS, @cLogInteg, @aErros) }, STR0024, STR0025, .F.) // "Integrar Operado Estrangeiro" , "Processando integração"
            oProcess:Activate()
         else
            lRet := OE400Sicomex(aOperadores, cPathAuth, cPathIAOE, oProcess, @cErros, oLogView, @oEasyJS, @cLogInteg, @aErros,lLote)
         endif

         if oEasyJS <> nil .and. !lIntegAuto
            oEasyJS:Destroy()
         endif

         if !lIntegAuto .or. lOE400Auto
            if !lRet
               EasyHelp(cErros,STR0017) // ATENÇÃO
            Elseif !lOE400Auto
               MsgInfo(STR0032,STR0033) //"Registrado com sucesso" //"Aviso" "
            endif
         endif

      endif

   end sequence

EndIf

Return lRet

/*/{Protheus.doc} OE400Sicomex
   Função que realiza a integração com o siscomex para cada item do array aOperadores
   @author Miguel Prado Gontijo
   @since 16/06/2020
   @version 1
   /*/
Function OE400Sicomex(aOperadores, cPathAuth, cPathIAOE, oProcess, cErros, oLogView, oEasyJS, cLogRetInt, aErros,lLote)
Local nQtdInt     := len(aOperadores)
Local cRet        := ""
Local aJsonEnvio  := {}
local aJsonGeral  := {}
Local lRet        := .F.
Local nSeq
local lAtualTIN   := avFlags("CATALOGO_PRODUTO")
local aAreaEKT    := {}
local cLogInicio  := ""
local cLogInteg   := ""
local cLogOperad  := "" 
local lTypeProc   := .F.
local lLogView    := valtype(oLogView) == "O"
local nForF       := nil
local nFor        := nil
local ni          := nil
Default aErros := {}
Default lLote := .f.

Private cIntCpfCnpj

default cLogRetInt := ""

   if lAtualTIN
      aAreaEKT := EKT->(getArea())
      EKT->(dbSetOrder(1))
   endif

   lTypeProc := valtype(oProcess) == "O"
   if lTypeProc
      oProcess:SetRegua1(nQtdInt)
   endif

   if nQtdInt > 0 .and. valtype(oEasyJS) == "U"
      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cPathAuth
      oEasyJS:setTimeOut(30)
      oEasyJS:AddLib( EasyAppFetch(cPathAuth) )
      oEasyJS:AddLib( OE400Script() )
      if !oEasyJS:Activate(.T.)
         cErros := STR0090 // "Não foi possível acessar o site do Portal Único."
         nQtdInt := 0
      endif
   endif

   cLogInicio := STR0060 + ":" + ENTER + ENTER // "Detalhes da integração"
   cLogInicio += dToc(Date()) +  " - " + Time() + " - " + STR0061 + ": " + UsrFullName(retCodUsr()) + ENTER // "Usuário do sistema"
   cLogInicio += Time() + " - " + STR0062+ENTER // "Acessando certificado digital"

   lRet := empty(cErros)
   nForF := int(nQtdInt / limiteInt) + if( nQtdInt % limiteInt > 0, 1, 0)     
      
   //processa no limite de 100 registros por vez
   for nFor := 1 to nForF   
      if lTypeProc      
         oProcess:IncRegua1(if(lLote,CP402getEt("3"),'') +  STR0063 + if(lLote,STR0094,'') ) // "Integrando operador estrangeiro:" "Etapa
      endif
      nSeq := 0
      aJsonEnvio:={}
      cRet := ''
      for ni:= 1+((nFor-1)*limiteInt) to if(limiteInt * nFor > nQtdInt, nQtdInt, limiteInt * nFor)       
         EKJ->(dbgoto(aOperadores[ni]))
         
         cLogOperad := Time() + " - " + STR0063 + " - " + STR0055 + ": " + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA + ENTER // "Integrando Operador Estrangeiro" ### "Código"
         if EKJ->EKJ_STATUS == "5" .or. (( EKJ->EKJ_STATUS == "2" .or. empty(EKJ->EKJ_STATUS)) .and. EKJ->EKJ_MSBLQL == '1' ) // Desativado ou pendente de registro bloqueado
            lRet := .F.
            cErros := if( EKJ->EKJ_STATUS == "5" , STR0086, STR0089) + ENTER  // "Operador Estrangeiro está desativado" ### "Operador Estrangeiro está bloqueado."
            if lLogView
               setLogInt(oLogView, cLogOperad, lRet, cErros, @cLogRetInt)
            endif

         elseif EKJ->EKJ_STATUS <> "1" // se for diferente de registrado   
            nSeq += 1            
            getJsonOE(nSeq,@aJsonEnvio)            
            aadd(aJsonGeral,aJsonEnvio[nSeq])               
         EndIf   
      next ni      
      if cErros <> "Failed to fetch" .and. cErros <> STR0090//se retorna este erro é pq. não conectou no portal, então não precisa tentar enviar novamente, mas precisa registrar o erro no array
         cRet := getEnvOE(aJsonEnvio,@cErros,cPathIAOE,oEasyJS)
      EndIf   
      setAerros(cRet,@aErros,aOperadores,nFor,nSeq,@cErros)
   next nFor  
   IF nQtdInt > 0
      lRet := setEKJLog(aErros,oLogView,@cLogInteg,@cLogRetInt,aOperadores,lLogView,lTypeProc,cLogInicio,aJsonGeral)
   EndIf   
         
   if !empty(cErros)
      cErros := STR0072 + ". " + STR0073 + CHR(10) + CHR(10) + cErros// "Houve falha na integração do operador estrangeiro" #### "Para mais informações consulte o campo 'Log de integração'"
   endif

   if len(aAreaEKT) > 0
      restArea(aAreaEKT)
   endif
   if lTypeProc
      oProcess:IncRegua2(STR0092) // "Intgração do operador estrangeiro finalizada
   endif   

Return lRet

/*/{Protheus.doc} setLogInt
   Trata a gravação do logview

   @type  Static Function
   @author user
   @since 30/08/2023
   @version version
   @param oLogView, objeto, objeto Memo do EECVIEW
          cLogOperad, caractere, mensagem do operador
          lFalha, logico, se ocorreu falha (.F.)
          cErros, caractere, mensagem de erro
          cLogRetInt, caractere, mensagem acumulativa
   @return nenhum
/*/
static function setLogInt(oLogView, cLogOperad, lFalha, cErros, cLogRetInt)
   oLogView:appendText( cLogOperad )
   cLogRetInt += cLogOperad
   if !lFalha
      oLogView:appendText( space(08) + " - " + STR0078 + ": " + cErros + ENTER ) // "Falha ao integrar o Operador Estrangeiro"
      cLogRetInt += space(08) + " - " + STR0078 + ": " + cErros + ENTER
   endif
   oLogView:appendText( ENTER )
   cLogRetInt += ENTER
   oLogView:Refresh()
   oLogView:goEnd()
return

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

      function getVersao(cUrl, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'GET')
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

      function intOperador(cUrl, sBody, retAdvplError, retAdvpl) {
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => res.text() )
         .then( (res) => { retAdvpl(res) } )
         .catch((e) => { retAdvplError(e) });
      }

   endcontent

Return cScript

/*/{Protheus.doc} intOperador
   Executa a integração do Operador Estrangeiro

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
static function intOperador(oEasyJS, cErros, cUrl, cJson)
   local cRet    := ""
   local cScript := ""

   begincontent var cScript

      intOperador('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvpl)

   endcontent

   oEasyJS:runJSSync( cScript ,{|x| cRet := x } , {|x| cErros := x } )

return cRet

/*/{Protheus.doc} getJsonOE
   Função carregar o array aJsonEnvio com os dados do operadores estrangeiros a serem integrados no portal único
   @type  Static Function
   @author user
   @since 24/01/2025
   @version version
   @param nSeq, sequência a ser enviado na integração
          aJsonEnvio, array com os jsons dos operadores a serem integados no portal único
   @return 
   @example
   (examples)
   @see (links_or_references)
/*/
Static function getJsonOE(nSeq,aJsonEnvio)
local cIdenAdic  := ""
local lAtualTIN  := avFlags("CATALOGO_PRODUTO")   
local lCpoCodTin := EKJ->(ColumnPos("EKJ_CODTIN")) > 0
local lCpoEmail  := EKJ->(ColumnPos("EKJ_EMAIL")) > 0
local aIdenAdic  := {}

   if lAtualTIN
      cIdenAdic := getIdenAdc(EKJ->(recno()), @aIdenAdic)
   endif
   
   cIntCpfCnpj := alltrim(EKJ->EKJ_CNPJ_R)
   If(EasyEntryPoint("EICCFGPU"),Execblock("EICCFGPU",.F.,.F.,"EICOE400_INTEGRAR"),)

   // Monta o texto do json para a integração
   Aadd(aJsonEnvio,JsonObject():new())
   aJsonEnvio[nSeq]["seq"] := nSeq
   aJsonEnvio[nSeq]["cpfCnpjRaiz"] := cIntCpfCnpj 
   aJsonEnvio[nSeq]["codigo"] := alltrim(EKJ->EKJ_TIN)
   aJsonEnvio[nSeq]["nome"] := alltrim(EKJ->EKJ_NOME)
   aJsonEnvio[nSeq]["logradouro"] := alltrim(EKJ->EKJ_LOGR)
   aJsonEnvio[nSeq]["nomeCidade"] := alltrim(EKJ->EKJ_CIDA)
   if( !empty(EKJ->EKJ_SUBP), aJsonEnvio[nSeq]["codigoSubdivisaoPais"] := alltrim(EKJ->EKJ_SUBP), "")
   aJsonEnvio[nSeq]["codigoPais"] := alltrim(EKJ->EKJ_PAIS)
   if( !empty(EKJ->EKJ_POSTAL), aJsonEnvio[nSeq]["cep"] := alltrim(EKJ->EKJ_POSTAL), "")
   if( lCpoCodTin .and. !empty(EKJ->EKJ_CODTIN), aJsonEnvio[nSeq]["tin"] := alltrim(EKJ->EKJ_CODTIN), "")
   if( lCpoEmail .and. !empty(EKJ->EKJ_EMAIL), aJsonEnvio[nSeq]["email"] := alltrim(EKJ->EKJ_EMAIL), "")
   aJsonEnvio[nSeq]["situacao"] := if( EKJ->EKJ_MSBLQL == "1", "DESATIVADO", "ATIVADO")
   aJsonEnvio[nSeq]["codigoInterno"] := if(!empty(xFilial("EKJ")), alltrim(xFilial("EKJ")) + "-","") + alltrim(EKJ->EKJ_FORN) + if( alltrim(EKJ->EKJ_FOLOJA) == ".", "", "/" + alltrim(EKJ->EKJ_FOLOJA))
   if( lAtualTIN .and. !empty(cIdenAdic), aJsonEnvio[nSeq]["identificacoesAdicionais"] := aClone(aIdenAdic), "")

   FwFreeArray(aIdenAdic)

Return        

/*/{Protheus.doc} getEnvOE
   Função que executa a chamada da integração do operador estrangiero no portal único
   @type  Static Function
   @author user
   @since 10/02/2025
   @version version
   @param aJsonEnvio, json a com as informações do operador estrangeiro a ser enviado ao potal único
          cErros, variável que conterá o erro da integração com o portal único se houver
          cPathIAOE, caminho da integração
   @return cRet retorna o resultado da integração com o portal único
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function getEnvOE(aJsonEnvio,cErros,cPathIAOE,oEasyJS)
local cRet := ''
local oJson
local cTxtJson := nil
   oJson := JsonObject():new()
   oJson:set(aJsonEnvio) 
   cTxtJson := oJson:ToJson()
   FwFreeObj(oJson)
   cRet := intOperador(oEasyJS, @cErros, cPathIAOE, cTxtJson)
Return cRet      


/*/{Protheus.doc} setaEerros
   Função que executa a chamada da integração do operador estrangiero no portal único
   @type  Static Function
   @author user
   @since 10/02/2025
   @version version
   @param aJsonEnvio, json a com as informações do operador estrangeiro a ser enviado ao potal único
          cErros, variável que conterá o erro da integração com o portal único se houver
          cPathIAOE, caminho da integração
   @return cRet retorna o resultado da integração com o portal único
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function setAerros(cRet,aErros,aOperadores,nFor,nSeq,cErros)
local lAtuErr := .f.
local nje := 0
local nj := 0
local cSucesso := ''
local cCodigo := ''
local cVersao := ''
local cStrJson := ''
local oJson
local cRetJson := ''
local aJson := {}
local aJsonErros := {}
local cMsgRetErr := ""

      // Pega o retorno e converte para json para extrair as informações
   if !empty(cRet)
      cRet     := '{"items":'+cRet+'}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      cErros := if( !valtype(cRetJson) == "U", STR0077 + ENTER + ENTER + " " + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
      if empty(cErros)
         cErros := if( valtype(oJson:GetJsonObject("items")) == "A", "", STR0018 + ENTER ) // "Arquivo de retorno sem itens!"  
         if empty(cErros)
            aJson    := oJson:GetJsonObject("items") //aqui retorna um array de json cada um com sua mensagem de erro
            if len(aJson) > 0
               for nje := 1 to len(aJson)
                  cSucesso := aJson[nje]:GetJsonText("sucesso")
                  cCodigo  := aJson[nje]:GetJsonText("codigo")
                  cVersao  := aJson[nje]:GetJsonText("versao")
                  cStrJson :=  Time() + " - " + STR0065 + ": " + aJson[nje]:ToJson() + ENTER// "Mensagem de retorno"
                  aJsonErros := if( valtype(aJson[1]:GetJsonObject("erros")) == "A", aJson[1]:GetJsonObject("erros"), if( valtype(aJson[1]:GetJsonObject("error")) == "C" , aJson[1]:GetJsonObject("error_description"), {}))
                  if len(aJsonErros) > 0
                     cErros := if( valtype(aJson[nje]:GetJsonObject("error")) == "C", aJson[1]:GetJsonObject("error") + ENTER, "")
                     for nj := 1 to len(aJsonErros)
                        cMsgRetErr := alltrim(aJsonErros[nj])
                        if !cMsgRetErr $ cErros
                           cErros += cMsgRetErr + " " + ENTER
                        endif
                     next
                     cErros += if(empty(cErros), STR0019 + ENTER,"") // "Arquivo de retorno inválido!"
                  endif
                  lAtuErr := .t.
                  aadd(aErros,{cSucesso, cCodigo, cVersao,cErros,substr(cStrJson,10,len(cStrJson)),aOperadores[limiteInt * (nFor - 1) +nje]})
               next nje   
            endif
         endif
      endif
      FwFreeObj(oJson)
   elseif !empty(cErros)
      cErros := if( match(cErros,"*Failed to fetch*"), STR0079 , cErros) + ENTER // "Não foi possível estabelecer conexão com o portal único. Verifique se está conectado na internet ou se o certificado está correto."
      cStrJson := Time() + " - " + STR0065 + ": " + if(empty(cRet),STR0076,cRet) + ENTER // "Mensagem de retorno"
   elseif empty(cErros)
      cErros := STR0020 + ENTER // "Integração sem nenhum retorno!"
      cStrJson := Time() + " - " + STR0065 + ": " + if(empty(cRet),STR0076,cRet) + ENTER // "Mensagem de retorno"
   endif

   if !lAtuErr
      for nje := 1 to nSeq
            aadd(aErros,{"false", "", "", cErros,substr(cStrJson,10,len(cStrJson)),aOperadores[limiteInt * (nFor - 1) +nje]}) 
            //adiciona a mesma mensagem de erro com conexão ao portal único para cada operador
      next nje
   EndIF   

   CP402aRtCt(@aErros,nSeq,nFor,aOperadores,.T.)   
Return      
   
/*/{Protheus.doc} setEKJLog
   Função que executa a gravaçaõ dos resultados da integração do operador estrangiero no portal único na tabela EKJ
   @type  Static Function
   @author user
   @since 10/02/2025
   @version version
   @param aJsonEnvio, json a com as informações do operador estrangeiro a ser enviado ao potal único
          cErros, variável que conterá o erro da integração com o portal único se houver
          cPathIAOE, caminho da integração
   @return cRet retorna o resultado da integração com o portal único
   @example
   (examples)
   @see (links_or_references)
/*/
//trata os erros com todos os registros processados, independente do limite
Static Function setEKJLog(aErros,oLogView,cLogInteg,cLogRetInt,aOperadores,lLogView,lTypeProc,cLogInicio,aJsonGeral)
local nje := 0
local cLogOperad := ''
local cLogPorOp := ''
local nQtdInt := len(aOperadores)
local cAmbiente   := IIF(EasyGParam("MV_EIC0074")=="1",STR0074,STR0075) // "Produção" #### "Treinamento"
local lRet := nil
local lRetFinal := .t.
local cErros := ''

   for nje := 1 to nQtdInt
      EKJ->(dbgoto(aOperadores[nje]))

      // caso dê tudo certo grava as informações e finaliza o registro
      oJson := JsonObject():new()
      oJson:set(aJsonGeral[nje])  
      cLogOperad := Time() + " - " + STR0063 + " - " + STR0055 + ": " + EKJ->EKJ_FORN + "/" + EKJ->EKJ_FOLOJA + ENTER // "Integrando Operador Estrangeiro" ### "Código"          
      cLogPorOp := cLogOperad + Time() + " - " + STR0064 + ": " + oJson:ToJson() + ENTER // "Mensagem de envio"
      cLogPorOp += aErros[nje,5] // "Mensagem de retorno"
      FwFreeObj(oJson)

      lRet := !empty(aErros[nje,1]) .and. upper(aErros[nje,1]) == "TRUE"
      if !lRet 
         lRetFinal := lRet
      endIf   
      cLogInteg := STR0066 + " " + cAmbiente + ENTER + ; // "Integração realizada no ambiente de"
                  STR0067 + ": " + if( lRet, STR0068, STR0069 ) + ENTER + ENTER + ; // "Resultado da integração" ### "Sucesso" ### Erro
                  if( lRet, "", STR0071 + ": " + aErros[nje,4] + ENTER ) + ; // "Mensagem de erro" 
                  cLogInicio + cLogPorOp + ;
                  dToc(Date()) +  " - " + Time() + " - " + STR0070 + ENTER // "Fim do processamento"                        
      cErros :=  aErros[nje,4]
      if lLogView
         setLogInt(oLogView, cLogInteg, lRet, cErros, @cLogRetInt)
      endif

      reclock("EKJ",.F.)
      EKJ->EKJ_DATA := dDatabase
      EKJ->EKJ_HORA := strtran(time(),":","")
      EKJ->EKJ_USER := __cUserID
      EKJ->EKJ_LOG  := cLogInteg
      if lRet
         EKJ->EKJ_STATUS := if( EKJ->EKJ_MSBLQL == "1", "5", "1" )
         EKJ->EKJ_TIN    := aErros[nje,2]
         if !empty(aErros[nje,3])
            EKJ->EKJ_VERSAO := aErros[nje,3]
         endif
      else
         EKJ->EKJ_STATUS := "4"
      endif

      EKJ->(msunlock())
   next      
Return lRetFinal  
