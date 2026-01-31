#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICLP500.CH"
#INCLUDE "AVERAGE.CH"

#define DUIMP_INTEGRADA "1"
#define DUIMP_MANUAL    "2"

#define OBJETIVO_DUIMP              "5"
#define OBJETIVO_FUNDAMENTO_LEGAL   "9"//ALTERAR PARA O OBJETIVO CORRETO
#define OBJETIVO_CATALOGO           "7"
#define OBJETIVO_LPCO               "6"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"
#Define ATT_DATA           "DATA"

#Define ATT_ATO_SUSP       "ATT_11362"
#Define ATT_ATO_ISEN       "ATT_11380"
#Define ATT_ATO_ITEM       "ATT_11382"

#Define ATT_ATO_SUSP_VAL   "ATT_15165"
#Define ATT_ATO_ISEN_VAL   "ATT_15185"
#Define ATT_ATO_ITEM_VAL   "ATT_15186"

#Define ATT_CLASSTRIB      "ATT_15540"
#Define ATT_CLASSTRIB_VAL  "ATT_20130"


static __aLstFrmNCM    := {}
static __oLstQtdInf    := nil
static _nSeqDUIMP      := 0
static _lForceAtu      := .F.
static _DIC_22_4       := nil
static _EIJVERSAO      := nil
static _lEntPoint      := EasyEntryPoint("EICLP500")
static _cPergTrb       := "0"
static _oEasyTmp       := nil
static LP500_EKD       := "LP500_EKD"
static lAppLP500       := nil

/*
Programa   : EICLP500
Objetivo   : Rotina - Vinculação de LPCO/ Itens DUIMP
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Agosto /2021
Obs.       :
*/
Function EICLP500()
   local aArea         := GetArea()

   private aRotina      := {}
   private oChannel

   oBrowse := FWMBrowse():New() //Instanciando a Classe
   oBrowse:SetAlias("SW6") //Informando o Alias
   oBrowse:SetMenuDef("EICLP500") //Nome do fonte do MenuDef
   oBrowse:SetDescription(STR0001) //"Itens DUIMP"

   //Ativa o Browse
   oBrowse:Activate()

   RestArea(aArea)
   FreeObj(oChannel)
return

/*
Função     : LP500VINC
Objetivo   : Criada originalmente para vinculação de LPCO; convertida para tela de Itens da DUIMP
Retorno    :
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500VINC()
   local lRet     := .F.
   local cTitulo  := STR0001 //Itens DUIMP
   local nOpc     := 0

   private oJsonPOUI
   private oChannel
   private oJsonAtt
   private oInfoAtt
   private oValorAtt
   private oVlCodObj
   private oFundLegal
   private cActiveID
   private lPOUIRetOK

   private cTmpAtrib := ""
   private cFileAtrib
   private cIndCatPrd
   
   private cTmpLpco  := ""
   private cFileLpco
   private cIndLpco
   private cIndLpco2

   Begin Sequence

      LP500IniVar()

      If !(SW6->W6_TIPOREG == "2")
         EasyHelp(STR0005, STR0003, STR0006) // "A rotina 'Itens DUIMP' é indicada apenas para processos do tipo 'DUIMP'." # "Atenção" # "Verifique o conteúdo do campo Tipo de Registro."
         break
      EndIf

      if !AvFlags("REFORMA_TRIBUTARIA")
         EasyHelp(STR0195, STR0003, STR0196) // "Não é possível acessar a rotina de Itens da DUIMP." ### "Será necessário realizar a atualização do dicionário de dados utilizando a versão mais recente da expedição contínua disponibilizada."
         break
      endif

      if !VldWVID()
         break
      endif

      cTmpAtrib := GetNextAlias()
      cTmpLpco := GetNextAlias()

      LP500Atu(.F.)

      nOpc := getOption(.T., .T.)
      if SW6->W6_FORMREG == DUIMP_INTEGRADA .and. nOpc == MODEL_OPERATION_VIEW
         VerifPend(SW6->W6_HAWB)
      endif

      oJsonPOUI := JsonObject():new()
      oJsonAtt := JsonObject():new()
      oInfoAtt := JsonObject():new()
      oValorAtt := JsonObject():new()
      oVlCodObj := JsonObject():new()
      oFundLegal := JsonObject():new()

      oJsonAtt['listaAtributos'] := {}
      oJsonAtt['listaCondicao']  := JsonObject():new()
      oInfoAtt['listaAtributos'] := {}
      oInfoAtt['listaCondicao']  := JsonObject():new()
      oInfoAtt['listaCompostos'] := {}

      oJsonPOUI['listaItensSWV'] := JsonObject():new()
      oJsonPOUI['listaComplementares'] := {}
      oJsonPOUI['listaInformativos'] := {}
      oJsonPOUI['listaAdicionais'] := {}

      TabItemNCM(cTmpAtrib)
      TabItLPCO(cTmpLpco)
      
      cActiveID := ""
      FWExecView(cTitulo,'EICLP500', nOpc,, { || .T. } )
      lRet := .T.

   End Sequence

   FreeObj(oChannel)
   FreeObj(oJsonAtt)
   FreeObj(oInfoAtt)
   FreeObj(oJsonPOUI)
   FreeObj(oValorAtt)
   freeObj(oVlCodObj)
   freeObj(oFundLegal)

   if !empty(cTmpAtrib) .and. select(cTmpAtrib) > 0
      (cTmpAtrib)->(E_EraseArq(cFileAtrib, cIndCatPrd))
   endif

   if !empty(cTmpLpco) .and. select(cTmpLpco) > 0
      (cTmpLpco)->(E_EraseArq(cFileLpco, cIndLpco, cIndLpco2))
   endif

   cActiveID := ""

Return lRet

static function LP500IniVar()
lAppLP500 := nil
return

/*
Função     : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ModelDef()
   Local oStruSW6  := FWFormStruct( 1, "SW6", { |x| ALLTRIM(x) $ 'W6_FILIAL|W6_HAWB' })
   Local oMdlEvent := LP500EV():New()
   Local oModel    := nil
   Local bCommit   := {|oModel| LP500COMMIT(oModel)}
   Local bPosVld   := {|oModel| LP500PVldModel( oModel )}
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lRegtrib  := avFlags("REGIME_TRIBUTACAO_DUIMP")
   local lTribDUIMP:= avFlags("TRIBUTACAO_DUIMP")
   local bActivate := {|oModel| LP500Active(oModel)}
   local nMaxLines := 3000 //Limite maximo de linhas do grid SWV
   local lOpcView  := getOption(.F., .T.) == MODEL_OPERATION_VIEW

   if lRegtrib
      TRB100Clear()
   endif

   // Criação do Modelo
   oModel := MPFormModel():New( "EICLP500", /*bPreValidacao*/, bPosVld, bCommit, /*bCancel*/ )
   //Modelo para a tabela SW6 - Chave Principal de relacionamento das tabelas
   oModel:AddFields('SW6MASTER',/*cOwner*/,oStruSW6)
   oModel:SetPrimaryKey( { "W6_FILIAL","W6_HAWB"} )

   //Instala o gerenciador de eventos para validações
   oModel:InstallEvent("LP500EV", , oMdlEvent)

   //Carrega os modelos das tabealas filhas
   SetModSW9(oModel)
   SetModSWV(oModel, nMaxLines)
   SetModEKQ(oModel)
   SetModEIJ(oModel)
   SetModEIK(oModel)
   SetModEINA(oModel)
   SetModEIND(oModel)
   SetModEJ9(oModel)

   if !FwIsInCallStack("EICLP501") .and. !IsExecAuto(.F.)
      SetMSWVTrb(oModel, nMaxLines)
      if lRegtrib .and. !lOpcView
         SetMGrpTrb(oModel, nMaxLines)
      endif
      SetModII(oModel)
      SetModIPI(oModel)
      if lTribDUIMP
         SetModPIS(oModel)
         SetModCOF(oModel)
         SetModADU(oModel)
      else
         SetModPISCOFINS(oModel)
      endif
      SetModICMS(oModel)

      If AvFlags("REFORMA_TRIBUTARIA")      
         SetModIBS(oModel)
      EndIf

      if lDuimpInt .and. DUIMP2310()
         SetMObsTrb(oModel)
      endif
   endif

   If AvFlags("REFORMA_TRIBUTARIA")
      SetModCBS(oModel)
   EndIf

   If AvFlags("FUNDAMENTO_LEGAL_ITEM")
      SetModEKW(oModel, '"1"', "EKWGRID_II") //Imposto de Importação
      SetModEKW(oModel, '"2"', "EKWGRID_IPI") //Imposto sobre Produtos Industrializados
      SetModEKW(oModel, '"3"', "EKWGRID_PIS") //Programa de Integração Social
      SetModEKW(oModel, '"4"', "EKWGRID_COFINS") //Contribuição para o Financiamento da Seguridade Social
      SetModEKW(oModel, '"5"', "EKWGRID_ANTIDUMPING") //Medidas Antidumping
   endIf

   oModel:SetActivate(bActivate)
Return oModel

Static Function LP500Active(oModel)

cActiveID := oModel:getModel("SWVDETAIL"):getValue("WV_ID")

If !getForceAtu() .and. empty(oModel:getModel("SWVDETAIL"):getValue("WV_NCM"))
   //Tratamento criado devido a alteração dos campos WV_NCM e WV_EX_NCM de Virtual para Real, não podendo ficar em branco para processos ja criados
   //Quando já existir a NCM para o item, não será mais preciso executar este tratamento
   atuNcmSWV(oModel)
EndIf

lp500LPCO('SET')
ManLstFrm(,'_nSeqDUIMP'  ,'SET',,0)
setInfSWV(oModel)

SetTmpTable()

//carregar os dados para os apps
if !getForceAtu() .and. !FWIsInCallStack("LP501Estor") .and. canUseApp()
   loadOnActive(oModel)
endIf

Return Nil

Static Function atuNcmSWV(oModel)
Local oMdlSW9 := oModel:getModel("SW9DETAIL")
Local nI

For nI := 1 To oMdlSW9:length()
   oMdlSW9:goLine(nI)
   LP501WVNCM(oModel, .F., oMdlSW9:getValue("W9_HAWB"), oMdlSW9:getValue("W9_INVOICE"), .T.)
Next
Return

/*
Função     : SetModSW9
Objetivo   : Cria a instância do model para a tabela SW9 (Dados de capa da Invoice)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModSW9(oModel)
   Local oStruSW9  := FWFormStruct( 1, "SW9", {|x| CheckField(x, EasyStrSplit(LP500Model("SW9"), "|")) })
   Local cOrderBy:= "W9_FILIAL+W9_HAWB+W9_INVOICE+W9_FORN+W9_FORLOJ"

   oModel:AddGrid('SW9DETAIL', 'SW6MASTER', oStruSW9,,,,,)
   oModel:GetModel("SW9DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SW9DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("SW9DETAIL"):SetUniqueLine({"W9_FILIAL" ,"W9_HAWB" ,"W9_INVOICE","W9_FORN" ,"W9_FORLOJ"} )
   oModel:SetRelation('SW9DETAIL', {{ 'W9_FILIAL', 'xFilial("SW9")'},;
      { 'W9_HAWB'  , 'W6_HAWB'       }},;
      cOrderBy )

Return Nil


/*
Função     : SetModSWV
Objetivo   : Cria a instância do model para a tabela SWV (Dados de capa do Lote/LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModSWV(oModel, nMaxLine)
   Local oStruSWV      := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(LP500Model("SWV"), "|")) })
   Local bPreVLnSWV    := {|oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld| PreVldLSWV(oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld)}
   Local bPosVLnSWV    := {|oGridSWV, nLine| PosVldLSWV(oGridSWV, nLine)}   
   Local cOrderBy:= "WV_FILIAL+WV_HAWB+WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_SEQUENC"

   //STRUCT_FEATURE_VALID
   oStruSWV:SetProperty('WV_SEQDUIM', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c),lRet:=(LP500VALID(b,a,c,d,e)),FWCloseCpo(a,b,c,lRet),lRet  }) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   //STRUCT_FEATURE_INIPAD4
   //Monta Inicializador Padrão diferente do dicionário
   oStruSWV:SetProperty('WV_HAWB', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))

   if empty(getSx3Cache("WV_DESC_DI", "X3_RELACAO")) // https://tdn.totvs.com/pages/releaseview.action?pageId=927547415 - a atualização do campo saiu na 2510
      oStruSWV:SetProperty('WV_DESC_DI', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))
   endif

   oStruSWV:AddTrigger("WV_NCM", "WV_NCM",, {|oModel| LP500Gatil("WV_NCM")} )
   If AvFlags("DRAWBACK_DUIMP")
      oStruSWV:AddTrigger("WV_MODAL" , "WV_MODAL" ,, {|oModel| LP500Gatil("WV_MODAL" )})
      oStruSWV:AddTrigger("WV_AC"    , "WV_AC"    ,, {|oModel| LP500Gatil("WV_AC"    )})
      oStruSWV:AddTrigger("WV_SEQSIS", "WV_SEQSIS",, {|oModel| LP500Gatil("WV_SEQSIS")})
   EndIf
   SetCposSWV(@oStruSWV, .F.)
   
   oModel:AddGrid('SWVDETAIL', 'SW9DETAIL', oStruSWV, bPreVLnSWV,bPosVlnSWV) //aqui MFR

   oModel:GetModel("SWVDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetMaxLine(nMaxLine)
   oModel:GetModel("SWVDETAIL"):SetUniqueLine({"WV_FILIAL" ,"WV_HAWB" ,"WV_INVOICE","WV_FORN" ,"WV_FORLOJ","WV_PO_NUM" ,"WV_POSICAO","WV_SEQUENC"} )

   oModel:SetRelation('SWVDETAIL', {   { 'WV_FILIAL'   ,'xFilial("SWV")' },;
      { 'WV_HAWB'     ,'W9_HAWB'        },;
      { 'WV_INVOICE'  ,'W9_INVOICE'     },;
      { 'WV_FORN'     ,'W9_FORN'        },;
      { 'WV_FORLOJ'   ,'W9_FORLOJ'      }},;
      cOrderBy )

Return Nil


/*
Função     : SetModEKQ
Objetivo   : Cria a instância do model para a tabela EKQ (Necessidades de LPCO x N.c.m )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEKQ(oModel)
   Local bPreVLnEKQ    := {|oGridEKQ, nLine, cAction| PreVldLEKQ(oGridEKQ, nLine, cAction)}
   Local bPosVLnEKQ    := {|oGridEKQ, nLine, cAction| PosVldLEKQ(oGridEKQ, nLine, cAction)}
   Local oStruEKQ := FWFormStruct(1, "EKQ", {|x| CheckField(x, EasyStrSplit(LP500Model("EKQ"), "|")) })

   oModel:AddGrid('EKQDETAIL','SWVDETAIL'  ,oStruEKQ, bPreVLnEKQ, bPosVLnEKQ)
   oModel:SetOptional("EKQDETAIL", .T.)

   oModel:SetRelation('EKQDETAIL', {   { 'EKQ_FILIAL'   ,'xFilial("EKQ")'},;
      { 'EKQ_HAWB'     ,'WV_HAWB'       },;
      { 'EKQ_INVOIC'   ,'WV_INVOICE'    },;
      { 'EKQ_PO_NUM'   ,'WV_PO_NUM'     },;
      { 'EKQ_POSICA'   ,'WV_POSICAO'    },;
      { 'EKQ_SEQUEN'   ,'WV_SEQUENC'    }},;
      EKQ->(IndexKey(1)) ) // EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN+EKQ_ORGANU+EKQ_FRMLPC

   oModel:GetModel("EKQDETAIL"):SetUniqueLine({"EKQ_FILIAL","EKQ_HAWB","EKQ_INVOIC","EKQ_PO_NUM","EKQ_POSICA","EKQ_SEQUEN","EKQ_ORGANU","EKQ_FRMLPC"} )
   oModel:GetModel("EKQDETAIL"):SetDelAllLine(.T.) //Permite utilizar o método delAllLine para deletar todas as linhas, após deleção da linha do grid de cima(SWV)
   oModel:GetModel("EKQDETAIL"):CanDeleteLine(.T.)

Return Nil

/*
Função     : SetModEIJ
Objetivo   : Cria a instância do model para a tabela EIJ ( Dados de tributação do item )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIJ(oModel)
   Local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJ"), "|")) })
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")
   local aCpos   := StrTokArr2(LP500Model("EIJ"), "|")
   local nCpo    := 0

   for nCpo := 1 to Len(aCpos)
      if !aCpos[nCpo] $ "EIJ_FABR|EIJ_FABLOJ|EIJ_PAISOR|EIJ_TIPCOB|EIJ_MODALI|EIJ_MOEDA|EIJ_VL_FIN|EIJ_MOTIVO"
         oStruEIJ:SetProperty( aCpos[nCpo], MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("' + aCpos[nCpo] +'")'))
      endif
   next

   //MODEL_FIELD_OBRIGAT
   oStruEIJ:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
   //STRUCT_FEATURE_WHEN
   oStruEIJ:SetProperty('EIJ_FABR'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FABR")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_FABLOJ', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FABLOJ")'  )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_PAISOR', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_PAISOR")'  )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TIPCOB', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TIPCOB")'    ))
   oStruEIJ:SetProperty('EIJ_MODALI', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MODALI")'    ))
   oStruEIJ:SetProperty('EIJ_MOEDA' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MOEDA")'    ))
   oStruEIJ:SetProperty('EIJ_VL_FIN', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_VL_FIN")'    ))
   oStruEIJ:SetProperty('EIJ_MOTIVO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MOTIVO")'    ))
   
   //STRUCT_FEATURE_VALID
   oStruEIJ:SetProperty('EIJ_FABR'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_FABLOJ', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_PAISOR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_IDPTCP', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_VRSACP', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_VRSFOR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )   
   oStruEIJ:SetProperty('EIJ_VRSFAB', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )      
   oStruEIJ:SetProperty('EIJ_APLICM', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .OR. Pertence("12345")')) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   //STRUCT_FEATURE_INIPAD
   oStruEIJ:SetProperty('EIJ_FABRVM', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário

   //TRIGGER
   oStruEIJ:AddTrigger("EIJ_FABR"  , "EIJ_FABLOJ",, {|oModel| LP500Gatil("EIJ_FABR_LOJA"  )} )
   oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_PAISOR",, {|oModel| LP500Gatil("EIJ_FABLOJ_PAISOR")} )
   oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_TINFA" ,, {|oModel| LP500Gatil("EIJ_FABLOJ_TINFA" )} )
   // retirado o gatilho para evitar erro de mensagem: Valor não pode ser atribuido. (Nome Fabric.)
   // inserido no gatilho do campo EIJ_FABLOJ - EIJ_FABLOJ_PAISOR
   //oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_FABRVM",, {|oModel| LP500Gatil("EIJ_FABLOJ_FABRVM")} )

   oStruEIJ:SetProperty('EIJ_APLICM', MODEL_FIELD_VALUES , getCombo("EIJ_APLICM"))
   oStruEIJ:SetProperty('EIJ_MATUSA', MODEL_FIELD_VALUES , getCombo("EIJ_MATUSA"))

   if EIJVERSAO() .and. DUIMP2310()
      oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_FABLOJ_VRS")} )
      oStruEIJ:AddTrigger("EIJ_IDPTCP", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFAB"  )} )
      oStruEIJ:AddTrigger("EIJ_VRSACP", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFAB"  )} )
      oStruEIJ:AddTrigger("EIJ_TINFO" , "EIJ_VRSFOR",, {|oModel| LP500Gatil("EIJ_TINFO" )})
   endif

   if lTribDUIMP
      oStruEIJ:SetProperty("EIJ_STATUS", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))
      oStruEIJ:AddTrigger("EIJ_IDPTCP", "EIJ_STATUS",, {|oModel| LP500Gatil("EIJ_IDPTCP")} )
   endif

   SetCposEIJ(@oStruEIJ, "EIJMASTER_II", lTribDUIMP)
   SetCposEIJ(@oStruEIJ, "EIJMASTER_IPI", lTribDUIMP)
   if lTribDUIMP
      SetCposEIJ(@oStruEIJ, "EIJMASTER_PIS", lTribDUIMP)
      SetCposEIJ(@oStruEIJ, "EIJMASTER_COFINS", lTribDUIMP)
      SetCposEIJ(@oStruEIJ, "EIJMASTER_ANTIDUMPING", lTribDUIMP)
   else
      SetCposEIJ(@oStruEIJ, "EIJMASTER_PISCOFINS", lTribDUIMP)
   endif
   SetCposEIJ(@oStruEIJ, "EIJMASTER_ICMS", lTribDUIMP)

   oModel:AddFields('EIJMASTER',"SWVDETAIL",oStruEIJ)

   //Rules - a loja apenas será preenchida após o fabricante
   oModel:addRules('EIJMASTER', 'EIJ_FABLOJ', 'EIJMASTER', 'EIJ_FABR', 3)

   oModel:SetRelation('EIJMASTER', {;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; //Aviso: Falta tratar a adição (vinculo com o item)
      EIJ->(IndexKey(3)) )

Return Nil

/*
Função     : SetModEIK
Objetivo   : Cria a instância do model para a tabela EIK ( Documentos vinculados )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIK(oModel)
   Local oStruEIK := FWFormStruct( 1, "EIK", {|x| CheckField(x, EasyStrSplit(LP500Model("EIK"), "|")) })
   Local bPosValid:= {|oGridModel, nLine| PosValEIK(oGridModel, nLine)}
   Local cOrderBy:= "EIK_FILIAL+EIK_HAWB+EIK_IDWV+EIK_TIPVIN+EIK_DOCVIN"

   //MODEL_FIELD_OBRIGAT
   oStruEIK:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   //MODEL_FIELD_INIT
   oStruEIK:SetProperty('EIK_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIK:SetProperty('EIK_HAWB'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIK:SetProperty('EIK_IDWV'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário

   oModel:AddGrid('EIKDETAIL','SWVDETAIL'  ,oStruEIK,,bPosValid)
   oModel:SetOptional("EIKDETAIL", .T.)
   oModel:SetRelation('EIKDETAIL', {   { 'EIK_FILIAL'   ,'xFilial("EIK")'},;
      { 'EIK_HAWB'     ,'WV_HAWB'       },;
      { 'EIK_IDWV'     ,'WV_ID'         }},; //Aviso: Falta tratar a adição (vinculo com o item)
      cOrderBy )

   oModel:GetModel("EIKDETAIL"):SetDelAllLine(.T.)

Return Nil


/*
Função     : SetModEINA
Objetivo   : Cria a instância do model para a tabela EIN (Acréscimos)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEINA(oModel)
   Local oStruEIN := FWFormStruct( 1, "EIN",{|x| CheckField(x, EasyStrSplit(LP500Model("EINA"), "|")) } )
   Local bPosValid:= {|oGridModel, nLine| PosValEIN(oGridModel, nLine)}
   Local cOrderBy:= "EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO+EIN_CODIGO"

   oStruEIN:SetProperty('EIN_CODACR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_FOBMOE', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_VLMLE' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   oStruEIN:SetProperty('EIN_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_HAWB'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_IDWV'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_DESC'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário

   oStruEIN:AddTrigger("EIN_CODACR"  , "EIN_CODIGO",, {|oModel| LP500Gatil("EIN_CODACR_CODIGO"  )} )
   oStruEIN:AddTrigger("EIN_CODACR"  , "EIN_DESC"  ,, {|oModel| LP500Gatil("EIN_CODACR_DESC"  )} )
   oStruEIN:AddTrigger("EIN_VLMLE"   , "EIN_VLMMN" ,, {|oModel| LP500Gatil("EIN_VLMLE", , ,"1")} )

   oStruEIN:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EINADETAIL','SWVDETAIL'  ,oStruEIN,,bPosValid)
   oModel:SetOptional("EINADETAIL", .T.)
   oModel:SetRelation('EINADETAIL', {  { 'EIN_FILIAL'  ,'xFilial("EIN")'},;
      { 'EIN_HAWB'    ,'WV_HAWB'       },;
      { 'EIN_IDWV'    ,'WV_ID'         },;
      { 'EIN_TIPO'    , "'1'"          }},;
      cOrderBy )

   oModel:GetModel("EINADETAIL"):SetDelAllLine(.T.)

Return Nil

/*
Função     : SetModEIND
Objetivo   : Cria a instância do model para a tabela EIN (Acréscimos)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIND(oModel)
   Local oStruEIN := FWFormStruct( 1, "EIN",{|x| CheckField(x, EasyStrSplit(LP500Model("EIND"), "|")) } )
   Local bPosValid:= {|oGridModel, nLine, cAction| PosValEIN(oGridModel, nLine)}
   Local cOrderBy:= "EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO+EIN_CODIGO"

   oStruEIN:SetProperty('EIN_CODDED', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_FOBMOE', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_VLMLE' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   oStruEIN:SetProperty('EIN_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_HAWB'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_IDWV'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_DESC'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)')) //Monta Inicializador Padrão diferente do dicionário

   oStruEIN:AddTrigger("EIN_CODDED"  , "EIN_CODIGO",, {|oModel| LP500Gatil("EIN_CODDED_CODIGO"  )} )
   oStruEIN:AddTrigger("EIN_CODDED"  , "EIN_DESC"  ,, {|oModel| LP500Gatil("EIN_CODDED_DESC"  )} )
   oStruEIN:AddTrigger("EIN_VLMLE"   , "EIN_VLMMN" ,, {|oModel| LP500Gatil("EIN_VLMLE", , ,"2")} )

   oStruEIN:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EINDDETAIL','SWVDETAIL'  ,oStruEIN,,bPosValid)
   oModel:SetOptional("EINDDETAIL", .T.)
   oModel:SetRelation('EINDDETAIL', {  { 'EIN_FILIAL'  ,'xFilial("EIN")'},;
      { 'EIN_HAWB'    ,'WV_HAWB'       },;
      { 'EIN_IDWV'    ,'WV_ID'         },;
      { 'EIN_TIPO'    , "'2'"          }},;
      cOrderBy )

   oModel:GetModel("EINDDETAIL"):SetDelAllLine(.T.)

Return Nil

/*
Função     : SetModEJ9
Objetivo   : Cria a instância do model para a tabela ej9
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEJ9(oModel)
   Local oStruEJ9 := FWFormStruct( 1, "EJ9", {|x| CheckField(x, EasyStrSplit(LP500Model("EJ9"), "|")) })
   Local bPosVLnEJ9 := {|oGridEJ9, nLine| PosVldEJ9(oGridEJ9, nLine)}

   oStruEJ9:SetProperty('EJ9_IDCERT',MODEL_FIELD_OBRIGAT, .F. )
   oStruEJ9:SetProperty('EJ9_DEMERC',MODEL_FIELD_OBRIGAT, .F. )
   oStruEJ9:SetProperty('EJ9_QTDCER',MODEL_FIELD_OBRIGAT, .F. )

   oStruEJ9:SetProperty('EJ9_DEMERC'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEJ9:SetProperty("EJ9_FILIAL" , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))
   oStruEJ9:SetProperty("EJ9_HAWB"   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))
   oStruEJ9:SetProperty("EJ9_IDWV"   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))

   oModel:AddGrid('EJ9DETAIL','SWVDETAIL'  ,oStruEJ9,,bPosVLnEJ9)
   oModel:SetOptional("EJ9DETAIL", .T.)
   oModel:SetRelation('EJ9DETAIL', {   { 'EJ9_FILIAL'   ,'xFilial("EJ9")'},;
      { 'EJ9_HAWB'     ,'WV_HAWB'       },;
      { 'EJ9_IDWV'     ,'WV_ID'    }},;
      EJ9->(IndexKey(2)) )
   oModel:GetModel("EJ9DETAIL"):SetUniqueLine({"EJ9_FILIAL","EJ9_HAWB","EJ9_IDWV","EJ9_DEMERC"} )
   oModel:GetModel("EJ9DETAIL"):SetDelAllLine(.T.)
Return Nil

/*
Função     : SetMSWVTrb
Objetivo   : Cria a instância do model para a tabela SWV (Tributação)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetMSWVTrb(oModel, nMaxLine)
   local oStruSWV   := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(LP500Model("SWV"), "|")) })
   local cOrderBy   := "WV_FILIAL+WV_HAWB+WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_SEQUENC"
   local nCpo       := 0
   local aFields    := {}

   aFields := oStruSWV:GetFields()
   for nCpo := 1 to len(aFields)
      if !(aFields[nCpo][3] == "WV_CODREG")
         oStruSWV:SetProperty(aFields[nCpo][3] , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.' )) //Monta When diferente do dicionário
      endif
   next nCpo
   // Retira o inicilizador padrão do campo WV_ID devido criação de novas linhas nos grids de tributação
   oStruSWV:SetProperty("WV_ID"   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI("WV_ID_GRP",a,c)'))
   if empty(getSx3Cache("WV_DESC_DI", "X3_RELACAO")) // https://tdn.totvs.com/pages/releaseview.action?pageId=927547415 - a atualização do campo saiu na 2510
      oStruSWV:SetProperty('WV_DESC_DI', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'))
   endif

   SetCposSWV( @oStruSWV )

   oModel:AddGrid('SWVDETAIL_TRIBUTACAO',"SW6MASTER", oStruSWV)

   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetNoDeleteLine(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetOnlyQuery(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetMaxLine(nMaxLine)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetUniqueLine({"WV_FILIAL","WV_HAWB","WV_INVOICE","WV_FORN","WV_FORLOJ","WV_PO_NUM","WV_POSICAO","WV_SEQUENC"} )

   oModel:SetRelation('SWVDETAIL_TRIBUTACAO', { ;
      { 'WV_FILIAL'   ,'xFilial("SWV")' },;
      { 'WV_HAWB'     ,'W6_HAWB'        }},;
      cOrderBy )

return nil

/*
Função     : SetMGrpTrb
Objetivo   : Cria a instância do model para o Grupo de Tributação
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetMGrpTrb(oModel, nMaxLine)
   local oStGrpTrib := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(LP500Model("GRPDETAIL_TRIBUTACAO"), "|")) })
   local nCpo       := 0
   local aFields    := {}

   aFields := oStGrpTrib:GetFields()
   for nCpo := 1 to len(aFields)
      if !(aFields[nCpo][3] == "WV_CODREG")
         oStGrpTrib:SetProperty(aFields[nCpo][3] , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.' )) //Monta When diferente do dicionário
      endif
   next nCpo

   oStGrpTrib:AddTrigger("WV_CODREG", "WV_DSCREG",, {|oModel| LP500Gatil("WV_CODREG_GRP")} )

   oModel:AddGrid("GRPDETAIL_TRIBUTACAO", "SW6MASTER", oStGrpTrib)
   oModel:SetOptional("GRPDETAIL_TRIBUTACAO", .T.)
   oModel:GetModel("GRPDETAIL_TRIBUTACAO"):SetNoInsertLine(.T.)
   oModel:GetModel("GRPDETAIL_TRIBUTACAO"):SetNoDeleteLine(.T.)
   oModel:GetModel("GRPDETAIL_TRIBUTACAO"):SetOnlyQuery(.T.)
   oModel:GetModel("GRPDETAIL_TRIBUTACAO"):SetMaxLine(nMaxLine)

return nil

/*
Função     : SetModII
Objetivo   : Cria a instância do model para a tabela EIJ (Imposto de importação)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
Revisão    : Separação do modelo da EKW para fundamentos legais e tributação
*/
static function SetModII(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_II"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_II")

   oModel:AddFields('EIJMASTER_II', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_II"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_II', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModEKW
Objetivo   : Cria a instância do model para a tabela EKW, um para cada tributo
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
Revisão    : Separação da função SetModXX para o modelo da EKW, referente aos fundamentos legais e tributação
*/
static function SetModEKW(oModel, cTributo, cModelName)
   local bPreEKW  := {|oModel, nLine, cAction, cField| LP500EKWPRE(oModel, nLine, cAction, cField, cModelName) }
   local oStruEKW
   local cKeyEKW

   //GRID FUNDAMENTO LEGAL
   cKeyEKW:= EKW->(IndexKey(1))//"EKW_FILIAL+EKW_HAWB+EKW_IDWV+EKW_NCM+EKW_FDTLGL+EKW_TRIBUT"
   oStruEKW := FWFormStruct( 1, "EKW", {|x| CheckField(x, EasyStrSplit(LP500Model("EKW"), "|")) })
   oModel:AddGrid(cModelName, 'SWVDETAIL', oStruEKW, bPreEKW)
   oModel:GetModel(cModelName):SetOptional( .T. )
   oModel:GetModel(cModelName):SetUniqueLine({"EKW_FILIAL","EKW_HAWB","EKW_IDWV","EKW_NCM","EKW_FDTLGL","EKW_TRIBUT"} )
   
   oModel:SetRelation(cModelName, {;
      { 'EKW_FILIAL' , 'xFilial("EKW")' },;
      { 'EKW_HAWB'   , 'WV_HAWB'        },;
      { 'EKW_IDWV'   , 'WV_ID'          },;
      { 'EKW_TRIBUT' , cTributo         }},;
      cKeyEKW)
   oModel:GetModel(cModelName):SetDelAllLine(.T.) //Permite utilizar o método delAllLine para deletar todas as linhas, após deleção da linha do grid de cima(SWV)

return nil

/*
Função     : SetModIPI
Objetivo   : Cria a instância do model para a tabela EIJ (IPI)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
Revisão    : Separação do modelo da EKW para fundamentos legais e tributação
*/
static function SetModIPI(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_IPI"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_IPI")

   oModel:AddFields('EIJMASTER_IPI', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_IPI"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_IPI', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModPISCOFINS
Objetivo   : Cria a instância do model para a tabela EIJ (PIS/COFINS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModPISCOFINS(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_PISCOFINS"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_PISCOFINS")

   oModel:AddFields('EIJMASTER_PISCOFINS', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_PISCOFINS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_PISCOFINS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModICMS
Objetivo   : Cria a instância do model para a tabela EIJ (ICMS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModICMS(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_ICMS"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_ICMS")

   oModel:AddFields('EIJMASTER_ICMS', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_ICMS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_ICMS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil


/*
Função     : SetModCBS
Objetivo   : Cria a instância do model para a tabela EKX (CBS e IBS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModCBS(oModel)
   local oStruEKX := FWFormStruct( 1, "EKX", {|x| CheckField(x, EasyStrSplit(LP500Model("EKXMASTER"), "|")) })

   oModel:AddFields('EKXMASTER',"SWVDETAIL",oStruEKX)

   oModel:SetRelation('EKXMASTER', { ;
      { 'EKX_FILIAL'   ,'xFilial("EKX")'},;
      { 'EKX_HAWB'     ,'WV_HAWB'       },;
      { 'EKX_IDWV'     ,'WV_ID'         }},; 
      EKX->(IndexKey(1)) )

return nil
/*
Função     : SetModIBS
Objetivo   : Cria a instância do model para a tabela EKX (CBS e IBS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModIBS(oModel)
   local oStruEKX := FWFormStruct( 1, "EKX", {|x| CheckField(x, EasyStrSplit(LP500Model("EKXMASTER"), "|")) })

   oStruEKX:AddTrigger("EKX_ALADIB", "EKX_ALADIB",, {|oModel| LP500Gatil("EKX_ALADIB")} )
   oStruEKX:AddTrigger("EKX_ALRDIB", "EKX_ALRDIB",, {|oModel| LP500Gatil("EKX_ALRDIB")} )
   oStruEKX:AddTrigger("EKX_ALRBIB", "EKX_ALRBIB",, {|oModel| LP500Gatil("EKX_ALRBIB")} )

   oModel:AddFields('EKXIBS',"SWVDETAIL",oStruEKX)
   
   oModel:GetModel("EKXIBS"):SetOnlyQuery(.T.)
   
   oModel:SetRelation('EKXIBS', { ;
      { 'EKX_FILIAL'   ,'xFilial("EKX")'},;
      { 'EKX_HAWB'     ,'WV_HAWB'       },;
      { 'EKX_IDWV'     ,'WV_ID'         }},; 
      EKX->(IndexKey(1)) )

return nil
/*
Função     : SetMObsTrb
Objetivo   : Cria a instância do model para a tabela EIJ (Integração)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       :
*/
static function SetMObsTrb(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_OBSTRB"), "|")) })

   oModel:AddFields('EIJMASTER_OBSTRB', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_OBSTRB"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_OBSTRB', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ViewDef()
   Local oStruSW6  := FWFormStruct( 2, "SW6", { |x| ALLTRIM(x) $ 'W6_FILIAL|W6_HAWB' }, /*lViewUsado*/ )
   Local oModel    := FWLoadModel( "EICLP500" )
   Local oView     := nil
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local cIdViewIt := ""
   local lRegTrib  := avFlags("REGIME_TRIBUTACAO_DUIMP")
   local lTribDUIMP:= avFlags("TRIBUTACAO_DUIMP")
   local bActivate := {|oView| LP500VWAct(oView)}
   local nTamTrib  := 100
   local lOpcView  := getOption(.F., .T.) == MODEL_OPERATION_VIEW

   //Cria o objeto de View
   oView := FWFormView():New()

   IF !lDuimpInt
      oView:AddUserButton(STR0055, 'CLIPS', {|| GerSeqDuimp(.T.)}) //"Gerar Sequência Automaticamente"
      oView:AddUserButton(STR0054, 'CLIPS', {|| DelSeqDuimp(.T.)}) //"Apagar Sequências"
   EndIf

   // Adiciona no nosso View um controle do tipo formulário
   //Define qual o Modelo de dados será utilizado na View
   oView:SetModel( oModel )

   If canUseApp()
      oView:AddOtherObject("VIEW_ATRIB", {|oPanel| LPCallApp(oPanel)})
   EndIf

   //Cria grupo de folders principal (100% da tela)
   oView:CreateHorizontalBox("MAINB", 100)
   oView:CreateFolder("MAIN", "MAINB")

   //Cria abas do grupo de folders principal
   oView:addSheet("MAIN", "DUIMP", STR0079) //"Itens"
   oView:addSheet("MAIN", "TRIB" , STR0080) //"Tributação" //escopo migrado para o release 12.1.2210
   If CanUseApp()
      oView:addSheet("MAIN", "ATRIBUTOS" , "Atributos") //"Tributação" //escopo migrado para o release 12.1.2210
      oView:CreateHorizontalBox( 'BOX_ATRIBUTOS', 100,,,'MAIN', 'ATRIBUTOS')
      oView:SetOwnerView("VIEW_ATRIB", 'BOX_ATRIBUTOS')
      oView:SetAfterViewActivate(bActivate)
   EndIf

   //Cria Form oculto para o SW6 (Modelo Base), na aba DUIMP
   oView:CreateHorizontalBox( 'NAOEXIBIDO', 0,,,'MAIN', 'DUIMP')
   oView:AddField( 'VIEW_SW6', oStruSW6, 'SW6MASTER' )
   oView:SetOwnerView( 'VIEW_SW6', 'NAOEXIBIDO' )

   //Aba DUIMP
   //Cria Box superior da Aba DUIMP
   oView:CreateHorizontalBox( 'SUPERIOR', 40,,,'MAIN', 'DUIMP')
   //Cria Box a esquerda para dados das Invoices
   oView:CreateVerticalBox('SUP_ESQ', 30, "SUPERIOR",,'MAIN', 'DUIMP')
   //Cria Box a Direita para dados dos itens da DUIMP (SWV)
   oView:CreateVerticalBox('SUP_DIR', 70,"SUPERIOR",,'MAIN', 'DUIMP')

   //Cria Box inferior da Aba DUIMP
   oView:CreateHorizontalBox( 'INFERIOR', 60,,,'MAIN', 'DUIMP')

   //Cria Grupo de folders do Box inferior da Aba DUIMP
   oView:CreateFolder("INFERIORF", "INFERIOR")

   //Cria abas do grupo de folders para apresentar detalhes do item
   oView:addSheet("INFERIORF", "MERCADORIA", STR0056) //"Mercadoria"
   oView:addSheet("INFERIORF", "ACRESDED"  , STR0059) //"Acréscimos/Deduções"
   oView:addSheet("INFERIORF", "LPCO"      , STR0060) //"LPCO"
   oView:addSheet("INFERIORF", "DOCS"      , STR0061) //"Documentos Vinculados"
   oView:addSheet("INFERIORF", "CERTMERC"  , STR0062) //"Certificado Mercosul"

   //Carrega as Views para os Sub Modelos:
   SetViewInvoices(oView)
   SetViewItens(oView)
   SetViewMercadoria(oView)
   /* as duas views foram comentadas e os campos passaram a ser exibidos na view Mercadoria, até que ocorra a correção do refresh pela equipe de Framework - DFRM1-28263
   SetViewFabFor(oView) 
   SetViewCondVend(oView) */
   SetViewLPCO(oView)
   SetViewDocs(oView)
   SetViewAcr(oView)
   SetViewCMs(oView)

   //Aba Tributação
   //Cria Box superior da Aba DUIMP
   oView:CreateHorizontalBox( 'SUPERIORTRIB', 40,,,'MAIN', 'TRIB')
   oView:CreateHorizontalBox( 'INFERIORTRIB', 60,,,'MAIN', 'TRIB')

   cIdViewIt := "SUPERIORTRIB"
   if lRegTrib
      if !lOpcView 
         oView:CreateVerticalBox('SUP_ESQ_TRIB', 30, "SUPERIORTRIB",,'MAIN', 'TRIB')
         nTamTrib := 70
      endif
      oView:CreateVerticalBox('SUP_DIR_TRIB', nTamTrib,"SUPERIORTRIB",,'MAIN', 'TRIB')
      cIdViewIt := "SUP_DIR_TRIB"
   endif

   oView:CreateFolder("INFERIOR_TRIB", "INFERIORTRIB")
   oView:addSheet("INFERIOR_TRIB", "FOLDER_II"        , STR0099) // "Imposto de Importação"
   oView:CreateHorizontalBox( 'BOX_II', 50,,,'INFERIOR_TRIB', 'FOLDER_II')

   oView:addSheet("INFERIOR_TRIB", "FOLDER_IPI"       , "IPI") // "IPI"
   oView:CreateHorizontalBox( 'BOX_IPI', 50,,,'INFERIOR_TRIB', 'FOLDER_IPI')

   if lTribDUIMP
      oView:addSheet("INFERIOR_TRIB", "FOLDER_PIS" , "PIS") // "PIS"
      oView:CreateHorizontalBox( 'BOX_PIS', 50,,,'INFERIOR_TRIB', 'FOLDER_PIS')
      oView:addSheet("INFERIOR_TRIB", "FOLDER_COFINS" , "COFINS") // "COFINS"
      oView:CreateHorizontalBox( 'BOX_COF', 50,,,'INFERIOR_TRIB', 'FOLDER_COFINS')
      oView:addSheet("INFERIOR_TRIB", "FOLDER_ANTIDUMPING" , "ANTIDUMPING") // "ANTIDUMPING"
      oView:CreateHorizontalBox( 'BOX_ANTIDUMPING', 50,,,'INFERIOR_TRIB', 'FOLDER_ANTIDUMPING')
   else
      oView:addSheet("INFERIOR_TRIB", "FOLDER_PISCOFINS" , "PIS/COFINS") // "PIS/COFINS"
      oView:CreateHorizontalBox( 'BOX_PISCOFINS', 50,,,'INFERIOR_TRIB', 'FOLDER_PISCOFINS')
   endif

   oView:addSheet("INFERIOR_TRIB", "FOLDER_ICMS"      , "ICMS") // "ICMS"
   oView:CreateHorizontalBox( 'BOX_ICMS', 50,,,'INFERIOR_TRIB', 'FOLDER_ICMS')

   If AvFlags("REFORMA_TRIBUTARIA")
      oView:addSheet("INFERIOR_TRIB", "FOLDER_CBS" , "CBS") // "CBS"
      oView:CreateHorizontalBox( 'BOX_CBS', 50,,,'INFERIOR_TRIB', 'FOLDER_CBS')
      oView:addSheet("INFERIOR_TRIB", "FOLDER_IBS" , "IBS") // "IBS"
      oView:CreateHorizontalBox( 'BOX_IBS', 50,,,'INFERIOR_TRIB', 'FOLDER_IBS')
   EndIf

   if lDuimpInt .and. DUIMP2310()
      oView:addSheet("INFERIOR_TRIB", "FOLDER_OBSTRB" , STR0110 ) // "Integração"
      oView:CreateHorizontalBox( 'BOX_OBSTRB', 50,,,'INFERIOR_TRIB', 'FOLDER_OBSTRB')
   endif

   //Carrega as Views para os Sub Modelos:
   SetVSWVTrb(oView, cIdViewIt)
   if lRegTrib .and. !lOpcView
      SetVGrpTrb(oView)
   endif
   SetViewII(oView)
   SetViewIPI(oView)
   if lTribDUIMP
      SetPISView(oView)
      SetCOFView(oView)
      SetADUView(oView)
   else
      SetViewPISCOFINS(oView)
   endif
   SetViewICMS(oView)

   If AvFlags("REFORMA_TRIBUTARIA")
      SetViewCBS(oView)
      SetViewIBS(oView)      
   EndIf

   if lDuimpInt .and. DUIMP2310()
      SetVObsTrb(oView)
   endif

Return oView

Static Function LP500VWAct(oView)
local oModel    := nil
local oModelSW9 := nil
local oModelSWV := nil

//Monta objeto com os valores comuns para os atributos de Catálogo e LPCO
If canUseApp()
   getValCP("") //Pega os valores dos atributos do catalogo
   getvalLPCO() //Pega os valores dos atributos do LPCO
   oModel := FwModelActive()
   oModelSW9 := oModel:getModel("SW9DETAIL")
   oModelSW9:goline(1)
   oModelSWV := oModel:getModel("SWVDETAIL")
   oModelSWV:goline(1)
   cActiveID := oModelSWV:getValue("WV_ID")
   sendAttPOUI(oJsonPOUI)
   AttDisable(oView:getOperation() == MODEL_OPERATION_VIEW .Or. oView:getOperation() == MODEL_OPERATION_DELETE)
EndIf

Return Nil

/*
Função     : SetViewInvoices
Objetivo   : Cria a instância da View para a tabela SW9 (Dados de capa da Invoice)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewInvoices(oView)
   Local oStruSW9 := FWFormStruct( 2, "SW9", {|x| CheckField(x, EasyStrSplit(LP500View("SW9"), "|")) }   )

   oStruSW9:SetProperty('W9_INVOICE'	,MVC_VIEW_CANCHANGE ,.F.)
   oStruSW9:SetProperty('W9_FORN'   	,MVC_VIEW_CANCHANGE ,.F.)
   oStruSW9:SetProperty('W9_FORLOJ'	,MVC_VIEW_CANCHANGE ,.F.)

   oView:AddGrid("VIEW_SW9",oStruSW9 , "SW9DETAIL")
   oView:SetOwnerView( 'VIEW_SW9', 'SUP_ESQ' )

   oView:EnableTitleView( "VIEW_SW9", STR0081) //"Invoices"
   oView:SetViewProperty( "VIEW_SW9", "GRIDFILTER", {.T.} )
   oView:SetViewProperty( "VIEW_SW9", "GRIDSEEK"  , {.T.} )

Return Nil

/*
Função     : SetViewItens
Objetivo   : Cria a instância da View para a tabela SWV (Itens da DUIMP)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewItens(oView)
   Local oStruSWV := FWFormStruct( 2, "SWV", {|x| CheckField(x, EasyStrSplit(LP500View("SWV"), "|")) })
   local nProximo := 0

   //Altera a ordem de visualização dos campos na tela
   oStruSWV:SetProperty('WV_SEQDUIM' , MVC_VIEW_ORDEM ,'01')
   oStruSWV:SetProperty('WV_PO_NUM'  , MVC_VIEW_ORDEM ,'02')
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_ORDEM ,'03')
   oStruSWV:SetProperty('WV_SEQUENC' , MVC_VIEW_ORDEM ,'04')
   oStruSWV:SetProperty('WV_COD_I'   , MVC_VIEW_ORDEM ,'05')
   oStruSWV:SetProperty('WV_DESC_DI' , MVC_VIEW_ORDEM ,'06')
   oStruSWV:SetProperty('WV_NCM'     , MVC_VIEW_ORDEM ,'07')
   if avFlags("REGIME_TRIBUTACAO_DUIMP")
      oStruSWV:SetProperty('WV_EX_NCM'    , MVC_VIEW_ORDEM ,'08')
      nProximo := 1
   endif
   oStruSWV:SetProperty('WV_QTDE'    , MVC_VIEW_ORDEM , StrZero(08 + nProximo, 2))
   oStruSWV:SetProperty('WV_LOTE'	 , MVC_VIEW_ORDEM , StrZero(09 + nProximo, 2))
   oStruSWV:SetProperty('WV_DT_VALI' , MVC_VIEW_ORDEM , StrZero(10 + nProximo, 2))
   oStruSWV:SetProperty('WV_DFABRI'	 , MVC_VIEW_ORDEM , StrZero(11 + nProximo, 2))
   oStruSWV:SetProperty('WV_OBS'	    , MVC_VIEW_ORDEM , StrZero(12 + nProximo, 2))
   oStruSWV:SetProperty('WV_LPCOPND' , MVC_VIEW_ORDEM , StrZero(13 + nProximo, 2))

   //Define quais campos são editáveis
   IF SW6->W6_FORMREG == DUIMP_MANUAL
      oStruSWV:SetProperty('WV_SEQDUIM',MVC_VIEW_CANCHANGE ,.T.)
   EndIf

   oStruSWV:SetProperty('WV_PO_NUM'	 , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_COD_I'	 , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_LOTE'	 , MVC_VIEW_CANCHANGE ,.T.)

   oView:AddGrid("VIEW_SWV", oStruSWV , "SWVDETAIL")
   oView:SetOwnerView('VIEW_SWV', 'SUP_DIR' )

   oView:EnableTitleView( "VIEW_SWV", STR0079) //"Itens"
   oView:SetViewProperty( "VIEW_SWV", "GRIDFILTER", {.T.} ) // Habilita o Filtro no grid superior (Itens\Lotes)
   oView:SetViewProperty( "VIEW_SWV", "GRIDSEEK"  , {.T.} ) // HAbilita a pesquisa no grid superior (Itens\Lotes)
   oView:SetViewProperty( 'VIEW_SWV', "CHANGELINE", {{ |oView, cViewID| ChangeLnWV(oView, cViewID) }} ) //Seta Função a ser executada quando trocar de linha no grid superior (SWV)

Return Nil

/*
Função     : SetViewMercadoria
Objetivo   : Cria a instância da View para a tabela EIJ (Tributação dos itens da DUIMP)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewMercadoria(oView)
   Local aCampos := {}
   Local oStruct := nil
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

   aCampos := { {"EIJ_IDPTCP","01"}, {"EIJ_VRSACP","01"},;
      {"EIJ_IMPORT","02"}, {"EIJ_NOMIMP","02"}, {"EIJ_CNPJRZ","02"}, {"EIJ_VINCCO","02"}, {"EIJ_APLICM","02"}, {"EIJ_MATUSA","02"}, {"EIJ_DSCCIT","02"},;
      {"EIJ_UNIDCO","03"}, {"EIJ_QTDECO","03"}, {"EIJ_UNDEST","03"}, {"EIJ_QT_EST","03"}, {"EIJ_PESOL" ,"03"}, {"EIJ_MOEDA" ,"03"}, {"EIJ_VLMLE" ,"03"},;
      {"EIJ_FORN", "04"} , {"EIJ_FORLOJ", "04"} , {"EIJ_FORNVM", "04"} , {"EIJ_TINFO" , "04"} , {"EIJ_PAISPR" , "04"} ,;
      {"EIJ_FABR", "05"} , {"EIJ_FABLOJ", "05"} , {"EIJ_FABRVM", "05"} , {"EIJ_FABFOR", "05"} , {"EIJ_TINFA"  , "05"} , {"EIJ_PAISOR", "05"},;
      {"EIJ_METVAL", "06"} , {"EIJ_INCOTE", "06"} , {"EIJ_TIPCOB", "07"} , {"EIJ_MODALI", "07"} , {"EIJ_NRROF", "07"} , {"EIJ_INSTFI", "07"}, {"EIJ_MOEDA", "07"},{"EIJ_MOTIVO", "07"},{"EIJ_VL_FIN", "07"} }

   if EIJVERSAO()
      aAdd( aCampos, {"EIJ_VRSFOR", "04"} )
      aAdd( aCampos, {"EIJ_VRSFAB", "05"} )
   endif

   if lTribDUIMP
      aAdd( aCampos, {"EIJ_STATUS", "01"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0063, "01", 2) //"Catálogo de Produtos"
   oStruct:AddGroup("02", STR0064, "01", 2) //"Dados Gerais"
   oStruct:AddGroup("03", STR0065, "01", 2) //"Valores"
   oStruct:AddGroup("04", STR0066, "01", 2) //"Dados do Fornecedor"
   oStruct:AddGroup("05", STR0067, "01", 2) //"Dados do Fabricante"
   oStruct:AddGroup("06", STR0068 , "01", 2) //"Valoração"
   oStruct:AddGroup("07", STR0069 , "01", 2) //"Dados Cambiais"

   //Remove os Folders
   oStruct:aFolders := {}

   //Adiciona os Grupos
   aEval(aCampos, {|x| oStruct:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })

   oStruct:SetProperty('EIJ_APLICM', MVC_VIEW_COMBOBOX , getCombo("EIJ_APLICM") )
   oStruct:SetProperty('EIJ_MATUSA', MVC_VIEW_COMBOBOX , getCombo("EIJ_MATUSA") )
   oStruct:SetProperty('EIJ_MATUSA', MVC_VIEW_TITULO   , STR0133 ) // "Condição"

   oStruct:SetProperty('EIJ_TINFA', MVC_VIEW_TITULO , STR0152 ) // "Código Fabr."
   oStruct:SetProperty('EIJ_TINFO', MVC_VIEW_TITULO , STR0153 ) // "Código Forn."
   oStruct:SetProperty('EIJ_TINFA' , MVC_VIEW_DESCR , STR0154 ) // "Código Portal Único"
   oStruct:SetProperty('EIJ_TINFO' , MVC_VIEW_DESCR , STR0154 ) // "Código Portal Único"

   oView:CreateHorizontalBox('V_MERCADORIA',100,,,'INFERIORF', 'MERCADORIA')

   oView:AddField( 'MERCADORIA', oStruct, 'EIJMASTER' )
   oView:SetOwnerView( 'MERCADORIA', 'V_MERCADORIA' )

Return Nil

/*
Função     : SetViewLPCO
Objetivo   : Cria a instância da View para a tabela EKQ (Dados de LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewLPCO(oView)
   Local oStruEKQ := FWFormStruct(2, "EKQ", {|x| CheckField(x, EasyStrSplit(LP500View("EKQ"), "|")) })

   oView:CreateHorizontalBox( 'LPCOBOX', 100,,,'INFERIORF', 'LPCO')

   oStruEKQ:SetProperty('EKQ_ORGANU'	,MVC_VIEW_ORDEM ,'01')
   oStruEKQ:SetProperty('EKQ_FRMLPC'	,MVC_VIEW_ORDEM ,'02')
   oStruEKQ:SetProperty('EKQ_DSCFRM'	,MVC_VIEW_ORDEM ,'03')
   oStruEKQ:SetProperty('EKQ_OBRFRM'	,MVC_VIEW_ORDEM ,'04')
   oStruEKQ:SetProperty('EKQ_LPCO'	    ,MVC_VIEW_ORDEM ,'05')
   oStruEKQ:SetProperty('EKQ_VERSAO'   ,MVC_VIEW_ORDEM ,'06')

   oView:AddGrid("VIEW_EKQ", oStruEKQ, "EKQDETAIL")
   oView:SetOwnerView('VIEW_EKQ', 'LPCOBOX' )
   oView:EnableTitleView("VIEW_EKQ", "LPCO" )

Return Nil

/*
Função     : SetViewDocs
Objetivo   : Cria a instância da View para a tabela EIK (Documentos Vinculados)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewDocs(oView)
   Local oStruct := FWFormStruct( 2, "EIK", {|x| CheckField(x, EasyStrSplit(LP500View("EIK"), "|")) })

   oView:CreateHorizontalBox('V_DOCS',100,,,'INFERIORF', 'DOCS')
   oView:AddGrid( 'DOCS', oStruct, 'EIKDETAIL' )
   oView:SetOwnerView( 'DOCS', 'V_DOCS' )
   oView:EnableTitleView("DOCS", STR0061 ) //"Documentos Vinculados"

Return Nil

/*
Função     : SetViewAcr
Objetivo   : Cria a instância da View para a tabela EKQ (Dados de LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewAcr(oView)
   Local oStruEINAc := FWFormStruct(2, "EIN", {|x| CheckField(x, EasyStrSplit(LP500View("EINA"), "|")) })
   Local oStruEINDd := FWFormStruct(2, "EIN", {|x| CheckField(x, EasyStrSplit(LP500View("EIND"), "|")) })

   oView:CreateHorizontalBox( 'ACRESDEDBOX', 100,,,'INFERIORF', 'ACRESDED')

   //Cria Box a esquerda para dados dos acrescimos
   oView:CreateVerticalBox('BOXVACRES', 50, "ACRESDEDBOX",,"INFERIORF", "ACRESDED")
   //Cria Box a Direita para dados das deduções
   oView:CreateVerticalBox('BOXVDEDUC', 50, "ACRESDEDBOX",,"INFERIORF", "ACRESDED")

   oStruEINAc:SetProperty('EIN_CODACR'	,MVC_VIEW_ORDEM ,'01')
   oStruEINAc:SetProperty('EIN_DESC'	,MVC_VIEW_ORDEM ,'02')
   oStruEINAc:SetProperty('EIN_FOBMOE'	,MVC_VIEW_ORDEM ,'03')
   oStruEINAc:SetProperty('EIN_VLMLE'	,MVC_VIEW_ORDEM ,'04')
   oStruEINAc:SetProperty('EIN_VLMMN'	,MVC_VIEW_ORDEM ,'05')

   oView:AddGrid("VIEW_EINACR", oStruEINAc, "EINADETAIL")
   oView:SetOwnerView('VIEW_EINACR', 'BOXVACRES' )
   oView:EnableTitleView("VIEW_EINACR", STR0082) //"Acréscimos"

   oStruEINDd:SetProperty('EIN_CODDED'	,MVC_VIEW_ORDEM ,'01')
   oStruEINDd:SetProperty('EIN_DESC'	,MVC_VIEW_ORDEM ,'02')
   oStruEINDd:SetProperty('EIN_FOBMOE'	,MVC_VIEW_ORDEM ,'03')
   oStruEINDd:SetProperty('EIN_VLMLE'	,MVC_VIEW_ORDEM ,'04')
   oStruEINDd:SetProperty('EIN_VLMMN'	,MVC_VIEW_ORDEM ,'05')

   oView:AddGrid("VIEW_EINDED", oStruEINDd, "EINDDETAIL")
   oView:SetOwnerView('VIEW_EINDED', 'BOXVDEDUC' )
   oView:EnableTitleView("VIEW_EINDED", STR0083) //"Deduções"


Return Nil


/*
Função     : SetViewCMs
Objetivo   : Cria a instância da View para a tabela EJ9 (DE Mercosul)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewCMs(oView)
   Local oStruEJ9 := FWFormStruct(2, "EJ9", {|x| CheckField(x, EasyStrSplit(LP500View("EJ9"), "|")) })

   oView:CreateHorizontalBox( 'CERTMERCBOX', 100,,,'INFERIORF', 'CERTMERC')

   oView:AddGrid("VIEW_EJ9", oStruEJ9, "EJ9DETAIL")
   oView:SetOwnerView('VIEW_EJ9', 'CERTMERCBOX' )
   oView:EnableTitleView("VIEW_EJ9", STR0084) //"Certificados Mercosul"

   oStruEJ9:SetProperty('EJ9_IDCERT'	,MVC_VIEW_ORDEM ,'04')
   oStruEJ9:SetProperty('EJ9_DEMERC'	,MVC_VIEW_ORDEM ,'05')
   oStruEJ9:SetProperty('EJ9_QTDCER'	,MVC_VIEW_ORDEM ,'06')

Return Nil

/*
Função     : SetVSWVTrb
Objetivo   : Cria a instância da View para a tabela SWV (Itens da DUIMP) - aba Tributação
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
static function SetVSWVTrb(oView, cIdViewIt)
   local oStruSWV := FWFormStruct( 2, "SWV", {|x| CheckField(x, EasyStrSplit(LP500View("SWV",1), "|")) })
   local cOrdem as character

   default cIdViewIt  := "SUPERIORTRIB"

   cOrdem:= "01"
   oStruSWV:SetProperty('WV_SEQDUIM' , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_INVOICE' , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_PO_NUM'  , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_SEQUENC' , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_COD_I'   , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_DESC_DI' , MVC_VIEW_ORDEM , cOrdem)
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_NCM'     , MVC_VIEW_ORDEM , cOrdem)

   if avFlags("REGIME_TRIBUTACAO_DUIMP")
      cOrdem:= SomaIt(cOrdem)
      oStruSWV:SetProperty('WV_EX_NCM'    , MVC_VIEW_ORDEM , cOrdem)
      cOrdem:= SomaIt(cOrdem)
      oStruSWV:SetProperty('WV_CODREG'    , MVC_VIEW_ORDEM , cOrdem)
      cOrdem:= SomaIt(cOrdem)
      oStruSWV:SetProperty('WV_DSCREG'    , MVC_VIEW_ORDEM , cOrdem)
   endif
   cOrdem:= SomaIt(cOrdem)
   oStruSWV:SetProperty('WV_QTDE'    , MVC_VIEW_ORDEM ,  cOrdem)

   oView:AddGrid("VIEW_SWV_TRIB", oStruSWV , "SWVDETAIL_TRIBUTACAO")
   oView:SetOwnerView('VIEW_SWV_TRIB', cIdViewIt )

   oView:SetViewProperty( 'VIEW_SWV_TRIB', "CHANGELINE", {{ |oView, cViewID| ChangeLnWV(oView, cViewID) }} ) //Seta Função a ser executada quando trocar de linha no grid superior (SWV)

   oView:EnableTitleView( "VIEW_SWV_TRIB", STR0079) //"Itens"

Return Nil

/*
Função     : SetVGrpTrb
Objetivo   : Cria a instância da View para a tabela Grupo de Tributação
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
static function SetVGrpTrb(oView)
   Local oStGrpTrib :=  FWFormStruct( 2, "SWV", {|x| CheckField(x, EasyStrSplit(LP500View("GRPDETAIL_TRIBUTACAO"), "|")) })

   oView:AddGrid("VIEW_GRP_TRIB", oStGrpTrib , "GRPDETAIL_TRIBUTACAO")
   oView:SetOwnerView('VIEW_GRP_TRIB', "SUP_ESQ_TRIB" )

   oView:EnableTitleView( "VIEW_GRP_TRIB", STR0136 ) // "Grupo Tributário"

Return Nil

/*
Função     : SetViewII
Objetivo   : Cria a instância da View para a tabela EIJ (Imposto de importaçao)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewII(oView)
   local aCampos   := {}
   local oStruct   := nil
   local nCpo      := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")
   local oStrEKWII

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := { ;
               {"EIJ_REGTRI","01"},;
               {"EIJ_FUNREG","02"},;
               {"EIJ_TPAII" ,"03"},{"EIJ_ALI_II","03"};
              }

   if lTribDUIMP
      aCampos := {}
      if !avFlags('FUNDAMENTO_LEGAL_ITEM')          
         aAdd( aCampos,{"EIJ_FUNII","01"})
         aAdd( aCampos,{"EIJ_DSCFL1","01"})
      EndIF 
      aAdd( aCampos,{"EIJ_REGTRI","02"})
      aAdd( aCampos,{"EIJ_DSCRG1","02"})
      aAdd( aCampos,{"EIJ_TPAII" ,"03"})
      aAdd( aCampos,{"EIJ_ALI_II","03"})
      aAdd( aCampos,{ "EIJ_ALR_II","03"})
   endif

   if lCpos
      aAdd( aCampos, {"EIJ_VLCII" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDII" ,"04"} )
      aAdd( aCampos, {"EIJ_VLDII" ,"04"} )
      aAdd( aCampos, {"EIJ_VLSII" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCII" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   if !avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("01", STR0101, "01", 2) // "Fundamento Legal"
   EndIF   
   oStruct:AddGroup("02", STR0100, "01", 2) // "Regime Tributário"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("05", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   if lTribDUIMP
      oStruct:SetProperty( "EIJ_REGTRI" , MVC_VIEW_TITULO , STR0155) // "Regime"
      oStruct:SetProperty( "EIJ_TPAII"  , MVC_VIEW_TITULO , STR0156) // "Tipo Alíq."
      oStruct:SetProperty( "EIJ_ALI_II" , MVC_VIEW_TITULO , STR0157) // "Ad Valorem"
      oStruct:SetProperty( "EIJ_ALR_II" , MVC_VIEW_TITULO , STR0158) // "Alíq. Reduz."
      oStruct:SetProperty( "EIJ_TPAII"  , MVC_VIEW_COMBOBOX , {"1=" + STR0157, "2=" + STR0159, "3=" + STR0160, "" } ) // "Ad Valorem" #### "Específica" #### "Mista"
   endif

   if lCpos
      oStruct:SetProperty( "EIJ_VLCII" , MVC_VIEW_TITULO , STR0112 ) // "Calculado"
      oStruct:SetProperty( "EIJ_VRDII" , MVC_VIEW_TITULO , STR0113 ) // "a Reduzir"
      oStruct:SetProperty( "EIJ_VLDII" , MVC_VIEW_TITULO , STR0114 ) // "Devido"
      oStruct:SetProperty( "EIJ_VLSII" , MVC_VIEW_TITULO , STR0115 ) // "Suspenso"
      oStruct:SetProperty( "EIJ_VRCII" , MVC_VIEW_TITULO , STR0116 ) // "a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_II', oStruct, 'EIJMASTER_II' )
   oView:SetOwnerView( 'VIEW_EIJ_II', 'BOX_II' )

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStrEKWII:= FWFormStruct( 2, "EKW", {|x| CheckField(x, strtokarr2(LP500View("EKWGRID"), "|")) })
      oView:CreateHorizontalBox( 'BOX_II_EKW', 50,,,'INFERIOR_TRIB', "FOLDER_II")
      oView:AddGrid("VIEW_EKW_TR_II", oStrEKWII, "EKWGRID_II")
      oView:EnableTitleView('VIEW_EKW_TR_II',STR0101) // "Fundamento Legal"
      oView:SetOwnerView( 'VIEW_EKW_TR_II', 'BOX_II_EKW' )
   EndIf

return nil

/*
Função     : SetViewIPI
Objetivo   : Cria a instância da View para a tabela EIJ (IPI)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewIPI(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")
   local oStrEKWIPI

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := { ;
               {"EIJ_REGIPI","01"},;
               {"EIJ_ASSIPI","02"},;
               {"EIJ_TPAIPI","03"},{"EIJ_ALAIPI","03"};
              }
   if lTribDUIMP
      aCampos := {}
      if !avFlags('FUNDAMENTO_LEGAL_ITEM')          
         aAdd( aCampos, {"EIJ_FUNIPI","01"} )
         aAdd( aCampos, {"EIJ_DSCFL2","01"} )
      endIf   
      aAdd( aCampos, {"EIJ_REGIPI","02"} )
      aAdd( aCampos, {"EIJ_DSCRG2","02"} )
      aAdd( aCampos, {"EIJ_TPAIPI","03"} )
      aAdd( aCampos, {"EIJ_ALAIPI","03"} )
      aAdd( aCampos, { "EIJ_ALRIPI","03"}) 
      aAdd( aCampos, { "EIJ_ALUIPI","03"} )
      aAdd( aCampos, { "EIJ_QTUIPI","03"} )                 
   endif

   if lCpos
      aAdd( aCampos, {"EIJ_VLCIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VDIPI"  ,"04"} )
      aAdd( aCampos, {"EIJ_VLSIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCIPI" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   If !avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("01", STR0101, "01", 2) // "Fundamento Legal"
   EndIf   
   oStruct:AddGroup("02", STR0100, "01", 2) // "Regime Tributário"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
 
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("05", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   if lTribDUIMP
      oStruct:SetProperty( "EIJ_REGIPI" , MVC_VIEW_TITULO , STR0155) // "Regime"
      oStruct:SetProperty( "EIJ_TPAIPI" , MVC_VIEW_TITULO , STR0156) // "Tipo Alíq."
      oStruct:SetProperty( "EIJ_ALAIPI" , MVC_VIEW_TITULO , STR0157) // "Ad Valorem"
      oStruct:SetProperty( "EIJ_ALRIPI" , MVC_VIEW_TITULO , STR0158) // "Alíq. Reduz."
      oStruct:SetProperty( "EIJ_ALUIPI" , MVC_VIEW_TITULO , STR0161) // "Alíq. Espec."
      oStruct:SetProperty( "EIJ_QTUIPI" , MVC_VIEW_TITULO , STR0162) // "Qtde. Espec."
      oStruct:SetProperty( "EIJ_REGIPI" , MVC_VIEW_COMBOBOX , {} )
      oStruct:SetProperty( "EIJ_REGIPI" , MVC_VIEW_LOOKUP   , "SJP" )
      oStruct:SetProperty( "EIJ_TPAIPI" , MVC_VIEW_COMBOBOX , {"1=" + STR0157, "2=" + STR0159, "3=" + STR0160, "" } ) // "Ad Valorem" #### "Específica" #### "Mista"
   endif

   if lCpos
      oStruct:SetProperty( "EIJ_VLCIPI" , MVC_VIEW_TITULO , STR0112 ) // "Calculado"
      oStruct:SetProperty( "EIJ_VRDIPI" , MVC_VIEW_TITULO , STR0113 ) // "a Reduzir"
      oStruct:SetProperty( "EIJ_VDIPI"  , MVC_VIEW_TITULO , STR0114 ) // "Devido"
      oStruct:SetProperty( "EIJ_VLSIPI" , MVC_VIEW_TITULO , STR0115 ) // "Suspenso"
      oStruct:SetProperty( "EIJ_VRCIPI" , MVC_VIEW_TITULO , STR0116 ) // "a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_IPI', oStruct, 'EIJMASTER_IPI' )
   oView:SetOwnerView( 'VIEW_EIJ_IPI', 'BOX_IPI' )
   
   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStrEKWIPI:= FWFormStruct( 2, "EKW", {|x| CheckField(x, strtokarr2(LP500View("EKWGRID"), "|")) })
      oView:CreateHorizontalBox( 'BOX_IPI_EKW', 50,,,'INFERIOR_TRIB', "FOLDER_IPI")
      oView:AddGrid("VIEW_EKW_TR_IPI", oStrEKWIPI, "EKWGRID_IPI")
      oView:EnableTitleView('VIEW_EKW_TR_IPI',STR0101) // "Fundamento Legal"
      oView:SetOwnerView( 'VIEW_EKW_TR_IPI', 'BOX_IPI_EKW' )
   EndIf

return nil

/*
Função     : SetViewPISCOFINS
Objetivo   : Cria a instância da View para a tabela EIJ ( PIS COFINS )
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewPISCOFINS(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := { ;
               {"EIJ_REG_PC","01"},;
               {"EIJ_FUN_PC","02"},;
               {"EIJ_TPAPIS","03"},{"EIJ_ALAPIS","03"},;
               {"EIJ_TPACOF","04"},{"EIJ_ALACOF","04"};
              }

   if lCpos
      aAdd( aCampos, {"EIJ_VLCPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VRDPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VDEPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VLSPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VRCPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VLCCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VRDCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VDECOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VLSCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VRCCOF" ,"06"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0100, "01", 2) // "Regime de Tributação"
   oStruct:AddGroup("02", STR0101, "01", 2) // "Fundamento"
   oStruct:AddGroup("03", STR0102 + " - PIS"   , "01", 2) // "Alíquotas"
   oStruct:AddGroup("04", STR0102 + " - COFINS", "01", 2) // "Alíquotas"

   if lCpos
      oStruct:AddGroup("05", STR0111 + " - PIS", "01", 2) // "Tributos Registrados"
      oStruct:AddGroup("06", STR0111 + " - COFINS", "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   oStruct:SetProperty( "EIJ_TPAPIS" , MVC_VIEW_TITULO , STR0106 ) // "Tip. Aliq. PIS"
   oStruct:SetProperty( "EIJ_ALAPIS" , MVC_VIEW_TITULO , STR0105 ) // "% Ad Val PIS"
   oStruct:SetProperty( "EIJ_TPACOF" , MVC_VIEW_TITULO , STR0104 ) // "Tip. Aliq. COFINS"
   oStruct:SetProperty( "EIJ_ALACOF" , MVC_VIEW_TITULO , STR0103 ) // "% Ad Val COFINS"

   if lCpos
      oStruct:SetProperty( "EIJ_VLCPIS" , MVC_VIEW_TITULO , "PIS " + STR0112 ) // "PIS/COFINS Calculado"
      oStruct:SetProperty( "EIJ_VRDPIS" , MVC_VIEW_TITULO , "PIS " + STR0113 ) // "PIS/COFINS a Reduzir"
      oStruct:SetProperty( "EIJ_VDEPIS" , MVC_VIEW_TITULO , "PIS " + STR0114 ) // "PIS/COFINS Devido"
      oStruct:SetProperty( "EIJ_VLSPIS" , MVC_VIEW_TITULO , "PIS " + STR0115 ) // "PIS/COFINS Suspenso"
      oStruct:SetProperty( "EIJ_VRCPIS" , MVC_VIEW_TITULO , "PIS " + STR0116 ) // "PIS/COFINS a Recolher"
      oStruct:SetProperty( "EIJ_VLCCOF" , MVC_VIEW_TITULO , "COFINS " + STR0112 ) // "PIS/COFINS Calculado"
      oStruct:SetProperty( "EIJ_VRDCOF" , MVC_VIEW_TITULO , "COFINS " + STR0113 ) // "PIS/COFINS a Reduzir"
      oStruct:SetProperty( "EIJ_VDECOF" , MVC_VIEW_TITULO , "COFINS " + STR0114 ) // "PIS/COFINS Devido"
      oStruct:SetProperty( "EIJ_VLSCOF" , MVC_VIEW_TITULO , "COFINS " + STR0115 ) // "PIS/COFINS Suspenso"
      oStruct:SetProperty( "EIJ_VRCCOF" , MVC_VIEW_TITULO , "COFINS " + STR0116 ) // "PIS/COFINS a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_PISCOFINS', oStruct, 'EIJMASTER_PISCOFINS' )
   oView:SetOwnerView( 'VIEW_EIJ_PISCOFINS', 'BOX_PISCOFINS' )

return nil

/*
Função     : SetViewICMS
Objetivo   : Cria a instância da View para a tabela EIJ (ICMS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewICMS(oView)
   local oStruct  := nil

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500View("EIJMASTER_ICMS"), "|")) }   )

    //Remove os Folders
   oStruct:aFolders := {}

   oView:AddField( 'VIEW_EIJ_ICMS', oStruct, 'EIJMASTER_ICMS' )
   oView:SetOwnerView( 'VIEW_EIJ_ICMS', 'BOX_ICMS' )

return nil

/*
Função     : SetViewCBS
Objetivo   : Cria a instância da View para a tabela EKX (CBS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewCBS(oView)
   local oStruct  := nil
   local aCampos  := {}

   aAdd( aCampos, {"EKX_ALADCB" ,"01"} )
   aAdd( aCampos, {"EKX_ALRDCB" ,"01"} )
   aAdd( aCampos, {"EKX_ALRBCB" ,"01"} )

   oStruct := FWFormStruct( 2, "EKX", {|x| CheckField(x, aCampos) } )

   oView:AddField( 'VIEW_EKX_CBS', oStruct, 'EKXMASTER' )
   oView:SetOwnerView( 'VIEW_EKX_CBS', 'BOX_CBS' )

return nil

/*
Função     : SetViewIBS
Objetivo   : Cria a instância da View para a tabela EKX (IBS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewIBS(oView)
   local oStruct  := nil
   local aCampos  := {}

   aAdd( aCampos, {"EKX_ALADIB" ,"01"} )
   aAdd( aCampos, {"EKX_ALRDIB" ,"01"} )
   aAdd( aCampos, {"EKX_ALRBIB" ,"01"} )

   oStruct := FWFormStruct( 2, "EKX", {|x| CheckField(x, aCampos) } )

   oView:AddField( 'VIEW_EKX_IBS', oStruct, 'EKXIBS' )
   oView:SetOwnerView( 'VIEW_EKX_IBS', 'BOX_IBS' )

return nil

/*
Função     : SetVObsTrb
Objetivo   : Cria a instância da View para a tabela EIJ (Integração)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2021
Obs.       :
*/
static function SetVObsTrb(oView)
   local oStruct  := nil

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500View("EIJMASTER_OBSTRB"), "|")) }   )

   oStruct:SetProperty( "EIJ_OBSTRB" , MVC_VIEW_TITULO , STR0117 ) // "Obs. Tributos"

    //Remove os Folders
   oStruct:aFolders := {}

   oView:AddField( 'VIEW_EIJ_OBSTRB', oStruct, 'EIJMASTER_OBSTRB' )
   oView:SetOwnerView( 'VIEW_EIJ_OBSTRB', 'BOX_OBSTRB' )

return nil

Static Function CheckField(cField, aFields, lUser)
   Local lRet := .F.
   Default lUser := .T.

   If ValType(aFields) == "A" .And. Len(aFields) > 0
      lRet := (ValType(aFields[1]) == "A" .And. aScan(aFields, {|x| AllTrim(x[1]) == AllTrim(cField) }) > 0) .Or. (ValType(aFields[1]) == "C" .And.  aScan(aFields, AllTrim(cField)) > 0) .Or. (lUser .and. GetSx3Cache(cField, "X3_PROPRI") == "U")
   Else
      lRet := .T.
   EndIf

Return lRet

/*
Função     : Menudef
Objetivo   : Estrutura do MenuDef
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function MenuDef()
   Local aRotina := {}
   //ADD OPTION aRotina TITLE STR0024               ACTION "VIEWDEF.EICLP500" OPERATION 1 ACCESS 0 //"Pesquisar"
   ADD OPTION aRotina TITLE STR0025               ACTION "VIEWDEF.EICLP500" OPERATION 2 ACCESS 0 //"Visualizar"
   //ADD OPTION aRotina TITLE STR0026               ACTION "VIEWDEF.EICLP500" OPERATION 3 ACCESS 0 //"Incluir"
   ADD OPTION aRotina TITLE STR0008               ACTION "LP500VINC"        OPERATION 4 ACCESS 0 //Itens DUIMP
   //ADD OPTION aRotina TITLE STR0027               ACTION "VIEWDEF.EICLP500" OPERATION 5 ACCESS 0   //"Excluir"

Return aRotina

/*
Class      : LP500EV
Objetivo   : CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
Retorno    : Nil
Autor      :
Data       :
Revisão    :
*/
Class LP500EV FROM FWModelEvent

   Method New()
   Method VldActivate()
   Method DeActivate()
   Method ModelPosVld()
   method AfterTTS()
End Class

/*
Class      : Método New Class LP500EV
Objetivo   : Método para criação do objeto
Retorno    : Nil
Autor      :
Data       :
Revisão    :
*/
Method New() Class LP500EV
Return

/*
Class      : Método New Class CP400EV
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method VldActivate(oModel) Class LP500EV
   local lRet        := .T.
   local cHelpLP500  := ""
   local cSolLP500   := ""
   local nOperation  := oModel:GetOperation()

   LP500IniVar()

   if !(nOperation == MODEL_OPERATION_UPDATE) .and. !(nOperation == MODEL_OPERATION_VIEW)
      cHelpLP500 := STR0149 // "Opção não permitida para a rotina 'Itens Duimp'."
      lRet := .F.
   endif

   if !AvFlags("REFORMA_TRIBUTARIA")
      cHelpLP500 := STR0197 // "A rotina de Itens da DUIMP não está atualizada com a última expedição contínua."
      cSolLP500  := STR0196 // "Será necessário realizar a atualização do dicionário de dados utilizando a versão mais recente da expedição contínua disponibilizada."
      lRet := .F.
   endif

   If lRet .and. nOperation == 4

      If !(SW6->(ColumnPos("W6_TIPOREG")) > 0) .Or. SW6->W6_TIPOREG <> "2"
         cHelpLP500 := STR0005 //"A rotina 'Itens DUIMP' é indicada apenas para processos do tipo 'DUIMP'.'
         cSolLP500 := STR0006 //"Verifique o conteúdo do campo Tipo de Registro"
         lRet := .F.
      EndIf

      if !FWIsInCallStack("LP501Estor")
         If lRet .and. (SW6->(IsLocked()) .or. !SoftLock("SW6"))
            cHelpLP500 := STR0035 //"Registro em uso por outro usuário!" # "Atenção"
            lRet := .F.
         EndIf

         if lRet .and. !FwIsInCallStack("LP500VINC") .and. !FwIsInCallStack("DI154NFE")
            lRet := LP500VlPrc(.F., .F., .F., @cHelpLP500, @cSolLP500)
         endif

         if lRet
            SW8->(DBSETORDER(1)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_FORN + W8_FORLOJ
            If !SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB))
               cHelpLP500 := STR0002 //"Processo não possui Invoices para a geração dos itens da duimp"
               cSolLP500  := STR0004 //"Verifique o processo de embarque e se necessário cadastre Invoice(s)"
               lRet := .F.
            EndIf

            if lRet .and. !FWIsInCallStack("EICLP501") .and. existFunc("DU100VdSW6") .and. !DU100VdSW6( SW6->W6_HAWB, IsExecAuto(.F.))
               lRet := .F.
               cHelpLP500 := STR0107 // "Operação cancelada."
            endif
         endif

      endif

   endif

   If !lRet
      EasyHelp(cHelpLP500, STR0003/*Atenção*/, cSolLP500)
   EndIf

   If lRet
      ManLstFrm(oModel,'__aLstFrmNcm',"CLEAR")
      ManLstFrm(oModel,'__oLstQtdInf','CLEAR')
   EndIf

Return lRet

/*
Class      : Método DeActivate Class CP400EV
Objetivo   : Método para desativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method DeActivate(oModel) Class LP500EV
   // Realiza a atualização da integração DUIMP
   SW6->(MsUnlock())
   EraseTmpTable()
Return

/*
Class      : Método AfterTTS Class CP400EV
Objetivo   : Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
             Esse evento ocorre uma vez no contexto do modelo principal.
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method AfterTTS(oModel) Class LP500EV
   // Realiza a atualização da integração DUIMP
   if !FWIsInCallStack("EICLP501") .and. existFunc("DU100AtuDUIMP")
      DU100AtuDUIMP(SW6->W6_HAWB, .F.)
   endif
Return

Method ModelPosVld(oModel, cModelId) Class LP500EV
Local lRet := .T.
If CanUseApp() .And. isMemVar("oValorAtt")
   freeObj(oValorAtt)
   getValPOUI()
   lPOUIRetOK := .F.
   WaitPOUI({|| lPOUIRetOK })
   //Gravar os valores retornados pelo POUI para o campo EKW_ATRIBU de cada item
   If lPOUIRetOK
      lRet := GrvRetPOUI(oModel) //Grava no campo EKW_ATRIBUT os atributos preenchidos no POUI para os fundamentos legais de cada tributo
   EndIf
EndIf
Return lRet

/*
Função     : GrvRetPOUI
Objetivo   : Função para gravar no campo EKW_ATRIBU os atributos preenchidos no POUI para os fundamentos legais de cada tributo
Parâmetro  : oModel - Modelo de dados EICLP500
Retorno    : Lógico .T. se gravou com sucesso, .F. caso contrário
Autor      : THTS - Tiago Tudisco
Data/Hora  : Dezembro/2024
*/
Static Function GrvRetPOUI(oModel)
Local lRet        := .T.
Local cTributOld  := ""
Local oModelSWV   := nil
Local cHawb       := ""
Local aNames
Local oModelEKW
Local oAtributos
Local nI
Local nY
Local cIdWV
Local oComplemen
Local oInformati
Local oAdicional
local oModelSW9 := nil
local nInv      := 0

If oValorAtt:HasProperty('complementares')
   oComplemen := oValorAtt['complementares']
EndIf
If oValorAtt:HasProperty('informativos')
   oInformati := oValorAtt['informativos']
EndIf
If oValorAtt:HasProperty('adicionais')
   oAdicional := oValorAtt['adicionais']
EndIf

oModelSW9 := oModel:GetModel("SW9DETAIL")
for nInv := 1 to oModelSW9:length()
   oModelSW9:goLine(nInv)

   oModelSWV := oModel:GetModel("SWVDETAIL")
   cHawb := oModelSWV:getValue("WV_HAWB")
   For nI := 1 To oModelSWV:length()
      oModelSWV:goLine(nI)

      if !oModelSWV:isDeleted()
         cIdWV := oModelSWV:getValue("WV_ID")

         //Grava Atributos Complementares (Duimp)
         oModelSWV:LoadValue("WV_ATRIBUT", " ")
         If oComplemen:HasProperty(cIdWV) .And. oComplemen[cIdWV]:hasProperty('atributosDuimp') .And. Len(oComplemen[cIdWV]['atributosDuimp']) > 0
            oAtributos := JsonObject():new()
            oAtributos['atributosDuimp'] := oComplemen[cIdWV]['atributosDuimp']
            oModelSWV:LoadValue("WV_ATRIBUT", oAtributos:toJson())
            freeObj(oAtributos)
         EndIf

         //Grava Atributos Informativos (Fundamento Legal)
         If SWV->(ColumnPos("WV_ATT_FL")) > 0 
            oModelSWV:LoadValue("WV_ATT_FL", " ")
            If oInformati:HasProperty(cIdWV) .And. oInformati[cIdWV]:hasProperty('atributosFundamentoLegalDuimp') .And. Len(oInformati[cIdWV]['atributosFundamentoLegalDuimp']) > 0
               oAtributos := JsonObject():new()
               oAtributos['atributosFundamentoLegalDuimp'] := oInformati[cIdWV]['atributosFundamentoLegalDuimp']
               oModelSWV:LoadValue("WV_ATT_FL", oAtributos:toJson())
               freeObj(oAtributos)
            EndIf
         EndIf

         //Grava Atributos Adicionais (Regime Tributário)
         If oAdicional:HasProperty(cIdWV)
            aNames := oAdicional[cIdWV]:getNames()
            If Len(aNames) > 0
               For nY := 1 to Len(aNames)
               //Se mudar o tributo, pega o grid referente ao tributo atual a ser gravadao os atributos
                  If oAdicional[cIdWV][aNames[nY]]['tributo'] <> cTributOld
                     cTributOld := oAdicional[cIdWV][aNames[nY]]['tributo']
                     oModelEKW := oModel:GetModel(getGridEKW(cTributOld))
                  EndIf
                  //Com o grid SWV posicionado no item correto, carrega o model do tributo para setar o atributo para os campos
                  seekModel("EKW", oModelEKW, cHawb, oAdicional[cIdWV][aNames[nY]])
                  oAtributos := JsonObject():new()
                  oAtributos['atributos'] := oAdicional[cIdWV][aNames[nY]]['atributos']
                  oModelEKW:LoadValue("EKW_ATRIBU", oAtributos:toJson())
                  freeObj(oAtributos)
               Next
               aNames      := {}
               cTributOld  := ""
            EndIf
         EndIf
      endif
   Next
next

Return lRet

Static Function seekModel(cGrid, oModel, cHawb, oAtributo)
Local lRet := .T.
Local aSeek := {}

aSeek := {  {"EKW_FILIAL" , xFilial("EKW")         },;
            {"EKW_HAWB"   , cHawb                  },;
            {"EKW_IDWV"   , oAtributo['idwv']      },;
            {"EKW_NCM"    , oAtributo['ncm']       },;
            {"EKW_FDTLGL" , oAtributo['fundamento']},;
            {"EKW_TRIBUT" , oAtributo['tributo']   },;
            {"EKW_TIPO"   , oAtributo['tipo']      }}

lRet := oModel:SeekLine(aSeek, .F., .T.)

Return lRet
/*
Função     : LP500Model
Objetivo   : Função que retorna string de campos a serem utilizados pelo modeldef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500Model(cAlias, lEIJtodos)
   Local cRet       := ""
   local lCpos      := .F.
   local lTribDUIMP := .F.

   default lEIJtodos  := .T.

   Do CASE
      CASE cAlias == 'SW9'
         cRet := "W9_FILIAL|W9_HAWB|W9_INVOICE|W9_FORN|W9_FORLOJ|W9_NOM_FOR|W9_INCOTER|W9_COND_PA|W9_MOE_FOB"

      CASE cAlias == 'SWV'
         cRet := 'WV_FILIAL|WV_SEQDUIM|WV_PO_NUM|WV_POSICAO|WV_REG|WV_CC|WV_SI_NUM|WV_FORN|WV_FORLOJ|WV_INVOICE|WV_COD_I|WV_PGI_NUM|WV_HAWB|WV_SEQUENC|WV_DESC_DI'+;
                 '|WV_NCM|WV_QTDE|WV_DT_VALI|WV_LOTE|WV_DT_VALI|WV_OBS|WV_DFABRI|WV_LPCOPND|WV_NOMEFOR|WV_ID|'
         if AvFlags("REGIME_TRIBUTACAO_DUIMP")
            cRet += '|WV_EX_NCM|WV_CODREG|WV_DSCREG|'
         endif
         if AvFlags("FUNDAMENTO_LEGAL_ITEM")
            cRet += "WV_ATRIBUT|"
         EndIf
         if AvFlags("DRAWBACK_DUIMP")
            cRet += "WV_MODAL|WV_AC|WV_SEQSIS|"
         EndIf
         if SWV->(ColumnPos("WV_ATT_FL")) > 0
            cRet += "WV_ATT_FL"
         EndIf

      CASE cAlias == 'EKQ'
         cRet := 'EKQ_FILIAL|EKQ_HAWB|EKQ_INVOIC|EKQ_PO_NUM|EKQ_POSICA|EKQ_SEQUEN|EKQ_ORGANU|EKQ_FRMLPC|EKQ_DSCFRM|EKQ_LPCO|EKQ_OBRFRM|EKQ_VERSAO|EKQ_IDLPCO'

      CASE substr(cAlias, 1, 3) == 'EIJ'
         cRet := 'EIJ_FILIAL|EIJ_HAWB|EIJ_IDWV'
         lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

         if cAlias == "EIJ"
            cRet += '|EIJ_VINCCO|EIJ_APLICM|EIJ_MATUSA|EIJ_QT_EST|EIJ_PESOL|EIJ_MOEDA|EIJ_VLMLE|EIJ_FORN'+;
               '|EIJ_FABFOR|EIJ_PO_NUM|EIJ_EX_NCM|EIJ_EX_NBM|EIJ_NROLI|EIJ_ASSVIC|EIJ_ASSVIB|EIJ_ATOVIC|EIJ_ATOVIB'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_EX_VIB|EIJ_EX_VIC|EIJ_ORGVIC|EIJ_ORGVIB|EIJ_NROVIC|EIJ_NROVIB|EIJ_ANOVIC|EIJ_ANOVIB|EIJ_NALASH|EIJ_NALANC|EIJ_UM_EST|EIJ_REGICM|EIJ_VLMMN|EIJ_BENSEN|EIJ_INCOTE|EIJ_METVAL|EIJ_VSEGMN|EIJ_VFREMN|EIJ_LOCVEN|EIJ_ASSII|EIJ_BAS_II|EIJ_EX_II|EIJ_ATO_II|EIJ_ORG_II|EIJ_NRATII|EIJ_ANO_II|EIJ_CALCII|EIJ_ALU_II|EIJ_QTU_II|EIJ_VL_II|EIJ_VLR_II|EIJ_DEVII|EIJ_VLARII|EIJ_BASIPI|EIJ_EX_IPI|EIJ_ATOIPI|EIJ_ORGIPI|EIJ_NROIPI'+;  //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_VLDIPI|EIJ_VLAIPI|EIJ_EXDUMP|EIJ_ATODUM|EIJ_ORGDUM|EIJ_UNE_AD|EIJ_ASSDUM|EIJ_ANODUM|EIJ_NRODUM|EIJ_TIPCOB|EIJ_MODALI|EIJ_INSTFI|EIJ_MOTIVO|EIJ_TXB_JU|EIJ_NRROF|EIJ_TXA_JU|EIJ_TEMJUR|EIJ_TEMVAR|EIJ_VL_FIN|EIJ_QTPARC|EIJ_PERPAR|EIJ_PERIOD|EIJ_COMIAG|EIJ_COMIVL|EIJ_TPAGE|EIJ_AGENID|EIJ_AGENOM|EIJ_AGEEND|EIJ_AGEBCO|EIJ_AGEAGE|EIJ_VLM360|EIJ_TX_FRE|EIJ_COBDES|EIJ_VLFRET|EIJ_CONDPG|EIJ_MOEFRE|EIJ_DIASPG|EIJ_COMPLE|EIJ_VLICMS|EIJ_MOESEG|EIJ_FLGICM|EIJ_URFENT|EIJ_TX_SEG|EIJ_VSEGLE|EIJ_PAISPR|EIJ_TX_FOB|EIJ_RATACR|EIJ_TEC_CL'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_MERCOS|EIJ_TAXSIS|EIJ_NVE|EIJ_UNUPIS|EIJ_BASPIS|EIJ_BR_PIS|EIJ_VLDPIS|EIJ_VLRPIS|EIJ_UNUCOF|EIJ_BASCOF|EIJ_BR_COF|EIJ_VLDCOF|EIJ_VLRCOF|EIJ_DEMERC|EIJ_ARDPIS|EIJ_IDCERT|EIJ_ARDCOF|EIJ_VLICMD|EIJ_VLRIPI|EIJ_PAISOR|EIJ_CODMAT|EIJ_BASICM'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_MOTIVO|EIJ_FORLOJ|EIJ_FORNVM|EIJ_FABR|EIJ_FABLOJ|EIJ_FABRVM|EIJ_METVAL|EIJ_INCOTE|EIJ_MODALI|EIJ_NRROF|EIJ_INSTFI'+;
               '|EIJ_IDPTCP|EIJ_VRSACP|EIJ_IMPORT|EIJ_NOMIMP|EIJ_CNPJRZ|EIJ_DSCCIT|EIJ_UNIDCO|EIJ_QTDECO|EIJ_UNDEST|EIJ_TINFA|EIJ_TINFO'

            if EIJVERSAO()
               cRet += '|EIJ_VRSFOR|EIJ_VRSFAB'
            endif
            
            if AvFlags("REGIME_TRIBUTACAO_DUIMP")
               cRet += '|EIJ_CODREG'
            endif

            if lTribDUIMP
               cRet += '|EIJ_STATUS'
            endif

         endif

         if lEIJtodos

            lCpos := DUIMP2310()
            if cAlias == "EIJMASTER_II" .or. cAlias == "EIJ"
               cRet += '|EIJ_REGTRI|EIJ_TPAII|EIJ_ALI_II' + if(!lTribDUIMP, '|EIJ_FUNREG', '|EIJ_FUNII|EIJ_DSCFL1|EIJ_DSCRG1|EIJ_ALR_II')
               if lCpos
                  cRet += '|EIJ_VLCII|EIJ_VRDII|EIJ_VLDII|EIJ_VLSII|EIJ_VRCII'
               endif
            endif

            if cAlias == "EIJMASTER_IPI" .or. cAlias == "EIJ"
               cRet += '|EIJ_REGIPI|EIJ_TPAIPI|EIJ_ALAIPI' + if(!lTribDUIMP, '|EIJ_ASSIPI', '|EIJ_FUNIPI|EIJ_DSCFL2|EIJ_DSCRG2|EIJ_ALRIPI|EIJ_ALUIPI|EIJ_QTUIPI')
               if lCpos
                  cRet += '|EIJ_VLCIPI|EIJ_VRDIPI|EIJ_VDIPI|EIJ_VLSIPI|EIJ_VRCIPI'
               endif
            endif

            if (cAlias == "EIJMASTER_PISCOFINS" .or. cAlias == "EIJ" ) .and. !lTribDUIMP
               cRet += '|EIJ_REG_PC|EIJ_FUN_PC|EIJ_TPAPIS|EIJ_ALAPIS|EIJ_TPACOF|EIJ_ALACOF'
               if lCpos
                  cRet += '|EIJ_VLCPIS|EIJ_VRDPIS|EIJ_VDEPIS|EIJ_VLSPIS|EIJ_VRCPIS'
                  cRet += '|EIJ_VLCCOF|EIJ_VRDCOF|EIJ_VDECOF|EIJ_VLSCOF|EIJ_VRCCOF'
               endif
            endif

            if (cAlias == "EIJMASTER_PIS" .or. cAlias == "EIJ") .and. lTribDUIMP
               cRet += '|EIJ_FUNPIS|EIJ_REGPIS|EIJ_TPAPIS|EIJ_ALAPIS|EIJ_DSCFL3|EIJ_DSCRG3|EIJ_REDPIS|EIJ_ALUPIS|EIJ_QTUPIS|EIJ_ALPISM'
               if lCpos
                  cRet += '|EIJ_VLCPIS|EIJ_VRDPIS|EIJ_VDEPIS|EIJ_VLSPIS|EIJ_VRCPIS'
               endif
            endif

            if (cAlias == "EIJMASTER_COFINS" .or. cAlias == "EIJ") .and. lTribDUIMP
               cRet += '|EIJ_FUNCOF|EIJ_REGCOF|EIJ_TPACOF|EIJ_ALACOF|EIJ_DSCFL4|EIJ_DSCRG4|EIJ_REDCOF|EIJ_ALUCOF|EIJ_QTUCOF|EIJ_ALCOFM'
               if lCpos
                  cRet += '|EIJ_VLCCOF|EIJ_VRDCOF|EIJ_VDECOF|EIJ_VLSCOF|EIJ_VRCCOF'
               endif
            endif

            if (cAlias == "EIJMASTER_ANTIDUMPING" .or. cAlias == "EIJ") .and. lTribDUIMP
               cRet += '|EIJ_FUNADU|EIJ_DSCFL5|EIJ_TPADUM|EIJ_ALADDU|EIJ_BAE_AD|EIJ_ALEADU|EIJ_VLC_DU|EIJ_VLD_DU|EIJ_VLR_DU'
            endif

            if cAlias == "EIJMASTER_ICMS" .or. cAlias == "EIJ"
               cRet += '|EIJ_OPERAC'
            endif

            if ( cAlias == "EIJMASTER_OBSTRB" .or. cAlias == "EIJ") .and. lCpos
               cRet += '|EIJ_OBSTRB'
            endif

         endif

      CASE cAlias == 'EIK'
         cRet := 'EIK_FILIAL|EIK_HAWB|EIK_IDWV|EIK_TIPVIN|EIK_DOCVIN'

      CASE cAlias == 'EINA'
         cRet := 'EIN_FILIAL|EIN_HAWB|EIN_IDWV|EIN_TIPO|EIN_CODACR|EIN_CODIGO|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN'

      CASE cAlias == 'EIND'
         cRet := 'EIN_FILIAL|EIN_HAWB|EIN_IDWV|EIN_TIPO|EIN_CODDED|EIN_CODIGO|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN'

      CASE cAlias == 'EJ9'
         cRet := 'EJ9_FILIAL|EJ9_HAWB|EJ9_IDWV|EJ9_DEMERC|EJ9_IDCERT|EJ9_QTDCER'

      CASE cAlias == "GRPDETAIL_TRIBUTACAO"
         cRet := 'WV_NCM|WV_EX_NCM|WV_CODREG|WV_DSCREG'
      
      CASE cAlias == 'EKW'
         cRet := 'EKW_FILIAL|EKW_HAWB|EKW_IDWV|EKW_NCM|EKW_FDTLGL|EKW_FDTDES|EKW_TRIBUT|EKW_REGIME|EKW_REGDES|EKW_TIPO|EKW_ATRIBU'

      Case cAlias == "EKXMASTER"
         cRet := 'EKX_FILIAL|EKX_HAWB|EKX_IDWV|EKX_ALADCB|EKX_ALRDCB|EKX_ALADIB|EKX_ALRDIB|EKX_ALRBCB|EKX_ALRBIB'

   END CASE

Return  cRet

/*
Função     : LP500View
Objetivo   : Função que retorna string de campos a serem exibidos e utilizados pela rotina(tela)
Parâmetro  :
Retorno    : String
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500View(cAlias,nType)
   Local cRet := ""
   Default nType := 0
   Do CASE
      CASE cAlias == 'SW9'
         cRet := '|W9_FILIAL|W9_HAWB|W9_INVOICE|W9_FORN|W9_FORLOJ|W9_NOM_FOR|'

      CASE cAlias == 'SWV'
         If nType == 0 // Itens
            cRet := '|WV_SEQDUIM|WV_PO_NUM|WV_POSICAO|WV_SEQUENC|WV_COD_I|WV_DESC_DI|WV_NCM|WV_QTDE|WV_DT_VALI'+;
               '|WV_LOTE|WV_DT_VALI|WV_OBS|WV_DFABRI|WV_LPCOPND|'
            if AvFlags("REGIME_TRIBUTACAO_DUIMP")
               cRet += '|WV_EX_NCM|' 
            endif
            if AvFlags("DRAWBACK_DUIMP")
               cRet += "WV_MODAL|WV_AC|WV_SEQSIS|"
            EndIf
         ElseIf nType == 1 // Tributação
            cRet := '|WV_SEQDUIM|WV_INVOICE|WV_PO_NUM|WV_POSICAO|WV_SEQUENC|WV_COD_I|WV_DESC_DI|WV_NCM|WV_QTDE|'
            if AvFlags("REGIME_TRIBUTACAO_DUIMP")
               cRet += '|WV_EX_NCM|WV_CODREG|WV_DSCREG|' 
            endif
            if AvFlags("DRAWBACK_DUIMP")
               cRet += "WV_MODAL|WV_AC|WV_SEQSIS|"
            EndIf
         EndIf

      CASE cAlias == 'EKQ'
         cRet := '|EKQ_ORGANU|EKQ_FRMLPC|EKQ_DSCFRM|EKQ_LPCO|EKQ_OBRFRM|EKQ_VERSAO|'

/*    CASE cAlias == 'EIJ'
         cRet := '|EIJ_VINCCO|EIJ_APLICM|EIJ_MATUSA|EIJ_QT_EST|EIJ_PESOL|EIJ_MOEDA|EIJ_VLMLE'+;
            '|EIJ_IDPTCP|EIJ_VRSACP|EIJ_IMPORT|EIJ_NOMIMP|EIJ_CNPJRZ|EIJ_DSCCIT|EIJ_UNIDCO|EIJ_QTDECO|EIJ_UNDEST|EIJ_TIPCOB|EIJ_MODALI|'
*/
      CASE cAlias == 'EIK'
         cRet := '|EIK_TIPVIN|EIK_DOCVIN|'

      CASE cAlias == 'EINA'
         cRet := 'EIN_CODACR|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EIND'
         cRet := 'EIN_CODDED|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EJ9'
         cRet := '|EJ9_DEMERC|EJ9_IDCERT|EJ9_QTDCER|'

      Case cAlias == "EIJMASTER_ICMS"
         cRet := '|EIJ_OPERAC|'

      Case cAlias == "EIJMASTER_OBSTRB"
         cRet := '|EIJ_OBSTRB|'

      Case cAlias == "GRPDETAIL_TRIBUTACAO"
         cRet := '|WV_NCM|WV_EX_NCM|WV_CODREG|'
      
      CASE cAlias == 'EKWGRID'
         cRet := '|EKW_FDTLGL|EKW_FDTDES|EKW_REGIME|EKW_REGDES|EKW_TIPO|'

   END CASE

Return cRet

/*
Função     : LP500VALID
Objetivo   : Função de validação
Parâmetro  : 1. Id do campo alterado
             2. submodelo
             3. valor atribuído ao campo
             4. se for formgrid, o número da linha alterada; se for formfields, valor anterior do campo
             5. se for formgrid, valor anterior do campo
Retorno    : .T. ou .F. se validou
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500VALID(cCampo, oSubModel, xNewVl, xValue1, xValue2)
   Local aArea          := GetArea()
   Local oModel         := FWModelActive()
   Local oModelEKQ
   local oModelEIJ
   local oModelSWV
   Local cVersaoUlt     := ""
   Local lRet := .T.
   Local cPais
   Local cIdCatalogo:= ""
   Local cFabricante
   Local cProduto
   Local nLine
   Local xOldValue
   Local cVersao
   local lDUIMP23_3  := .F.
   local cTributo   := ""
   local cModelId   := ""
   local cCpoInfo   := ""
   local cNcm       := ""
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")
   local cCnpjRaiz  := ""
   local cCodFor    := ""
   local cVerOper   := ""

   If oSubModel <> Nil
      If oSubModel:ClassName() == "FWFORMGRID"
         nLine:= xValue1
         xOldValue:= xValue2
      Else //FWFORMFIELDS
         xOldValue:= xValue1
      EndIf
   EndIf

   If ValType(oModel) == 'O' .and. alltrim(upper(oModel:getId())) == "EICLP500"
      oModelEKQ := oModel:GetModel("EKQDETAIL")
      Do Case
         Case cCampo == 'EKQ_LPCO'
            if !Empty(oModelEKQ:GetValue("EKQ_LPCO"))
               lRet := .F.
               If !Empty(oModelEKQ:GetValue("EKQ_ORGANU"))
                  If !Empty(oModelEKQ:GetValue("EKQ_FRMLPC"))
                     lRet := SW6->W6_FORMREG == DUIMP_MANUAL .OR. ExistCpo("EKO", oModelEKQ:GetValue("EKQ_ORGANU")+oModelEKQ:GetValue("EKQ_FRMLPC")+oModelEKQ:GetValue("EKQ_LPCO"), 3)
                  Else
                     EasyHelp(STR0020, STR0003, STR0021) //"O campo Formulário do LPCO não foi preenchido", "Atenção", "Será necessário prencher o Formulário do LPCO antes de digitar LPCO")
                  EndIf
               Else
                  EasyHelp(STR0022, STR0003, STR0023) //"O campo Órgão anuente não foi preenchido", "Atenção", "Será necessário prencher o Órgão anuente antes de digitar LPCO"
               Endif
            endIf

         Case cCampo == 'EKQ_VERSAO'
            If !Vazio()
               If !Empty(oModelEKQ:GetValue("EKQ_LPCO"))
                  If !Empty(oModelEKQ:GetValue("EKQ_VERSAO")) .and. SW6->W6_FORMREG == DUIMP_INTEGRADA
                     lRet := ExistCpo("EKO", oModelEKQ:GetValue("EKQ_LPCO")+oModelEKQ:GetValue("EKQ_VERSAO"), 2)
                     If lRet
                        EKO->(DbSetOrder(2)) //Filial + LPCO + Versão
                        If EKO->(AvSeekLAst(xFilial("EKO") + oModelEKQ:GetValue("EKQ_LPCO")))
                           cVersaoUlt := EKO->EKO_VERSAO
                        EndIf
                        If !Empty(cVersaoUlt) .And. cVersaoUlt <> oModelEKQ:GetValue("EKQ_VERSAO")
                           If !IsExecAuto() .and. !MsgYesNo(STR0010)  //"Versão digitada/escolhida não é a última existente para o LPCO. Deseja prosseguir?"
                              lRet := .F.
                           EndIf
                        EndIf
                     Else
                        EasyHelp(STR0011, STR0003, STR0012) //"Versão digitada não encontrada na Base de dados para o LPCO" #Atenção # "Digite uma versão válida. "
                        lRet := .F.
                     EndIf
                  EndIf
               Else
                  EasyHelp(STR0013, STR0003, STR0014) //"O campo LPCO não foi preenchido." #Atenção # "Preencha um LPCO válido antes de preencher a Versão do LPCO"
                  lRet := .F.
               EndIf
            EndIf

         Case cCampo == 'EKQ_ORGANU'
            lRet := Vazio() .Or. ExistCpo( "SJJ", oModelEKQ:GetValue("EKQ_ORGANU" ))

         Case cCampo == 'EKQ_FRMLPC'
            if !Vazio()
               lRet := SW6->W6_FORMREG == DUIMP_MANUAL .or. ExistCpo( "EKL", oModelEKQ:GetValue("EKQ_ORGANU" )+oModelEKQ:GetValue("EKQ_FRMLPC" ))
               if lRet
                  lRet := VldEKQ( oModelEKQ )
               endif
            endif

         Case cCampo == 'WV_QTDE'
            if !getForceAtu()
               lRet := AltQtdLote(oModel)
            endIf

         Case cCampo == 'EIJ_IDPTCP'
            If !Vazio()
               oModelEIJ := oModel:GetModel("EIJMASTER")
               oModelSWV := oModel:GetModel("SWVDETAIL")
               lRet := VldCatProd(cCampo, getNCM(oModelSWV), xNewVl, oModelEIJ:GetValue("EIJ_VRSACP"))
            endif

         Case cCampo == 'EIJ_VRSACP'
            If !Vazio()
               oModelEIJ := oModel:GetModel("EIJMASTER")
               oModelSWV := oModel:GetModel("SWVDETAIL")
               lRet := VldCatProd(cCampo, getNCM(oModelSWV), oModelEIJ:GetValue("EIJ_IDPTCP"), xNewVl, xOldValue)
            EndIf

         Case cCampo == 'EIJ_FABR'
            oModelEIJ := oModel:GetModel("EIJMASTER")
            lRet := Vazio() .Or. ExistCpo( "SA2" , oModelEIJ:GetValue("EIJ_FABR") )

         Case cCampo == 'EIJ_FABLOJ'

            lRet := Vazio()
            If !lRet
               oModelEIJ := oModel:GetModel("EIJMASTER")
               oModelSWV := oModel:GetModel("SWVDETAIL")
               cFabricante := if( !empty(xFilial("SA2")) , xFilial("SA2") + "-", "" ) + AllTrim(oModelEIJ:GetValue("EIJ_FABR")) + " / " + oModelEIJ:GetValue("EIJ_FABLOJ")

               If (lRet := ExistCpo( "SA2" , oModelEIJ:GetValue("EIJ_FABR") + oModelEIJ:GetValue("EIJ_FABLOJ") ))
                  if !empty(oModelEIJ:GetValue("EIJ_IDPTCP")) .and. !empty(oModelEIJ:GetValue("EIJ_VRSACP"))
                     lRet := .F.
                     cProduto := oModelSWV:GetValue("WV_COD_I")
                     lDUIMP23_3 := AvFlags("DUIMP_12.1.2310-23.3")
                     PosHistCat(getNCM(oModelSWV), oModelEIJ:GetValue("EIJ_IDPTCP"), oModelEIJ:GetValue("EIJ_VRSACP"))

                     cIdCatalogo := AllTrim(EKD->EKD_IDPORT) + " / " + if( lDUIMP23_3, AllTrim(EKD->EKD_VATUAL), AllTrim(EKD->EKD_VERSAO))

                     //Verifica se o produto está nesta versão de catálogo, bem como o fabricante
                     if PosCatOper(EKD->EKD_COD_I, EKD->EKD_VERSAO, oModelEIJ:GetValue("EIJ_FABR"), oModelEIJ:GetValue("EIJ_FABLOJ")) .and. ;
                        PosCatProd(EKD->EKD_COD_I, EKD->EKD_VERSAO, cProduto)
                        lRet := .T.
                     else
                        EasyHelp(StrTran(StrTran(StrTran(STR0089, "###", cFabricante), "***", cIdCatalogo), "$$$", AllTrim(cProduto)), STR0003, STR0090) //"O Fabricante ### não está vinculado ao produto $$$ da versão *** do Catálogo de Produtos."/// 'Informe um Fabricante válido vinculado ao item!'
                     endif
                  endif
               else
                  EasyHelp(StrTran(STR0093, "###", cFabricante), STR0003, STR0094) //'O Fabricante ### não está cadastrado.' //"Verifique o cadastro de Fornecedores/ Fabricantes."
               EndIf
            EndIf

         Case cCampo == 'EIJ_PAISOR'
            lRet := Vazio() .Or. ExistCpo("SYA")

         case cCampo == 'EIJ_TINFO'
            lRet := SW6->W6_FORMREG == DUIMP_MANUAL .or. Vazio()
            if !lRet 
               cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
               oModelEIJ := oModel:GetModel("EIJMASTER")
               cCodFor := LP500OpEst("EKJ_TIN", cCnpjRaiz, oModelEIJ:getValue("EIJ_FORN"), oModelEIJ:getValue("EIJ_FORLOJ"), .F.)
               lRet := .T.
               if empty(cCodFor) .or. !(cCodFor == oModelEIJ:getValue("EIJ_TINFO"))
                  lRet := .F.
                  easyHelp(STR0202, STR0003, STR0203 ) // "O código do Operador Estrangeiro não tem vínculo com o fornecedor ou não possui versão registrada." ### "Revise o código do Operador Estrangeiro informado."
               endif

            endif

         case cCampo == 'EIJ_VRSFOR'
            lRet := SW6->W6_FORMREG == DUIMP_MANUAL .or. Vazio()
            if !lRet
               cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
               oModelEIJ := oModel:GetModel("EIJMASTER")
               cVerOper := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, oModelEIJ:getValue("EIJ_FORN"), oModelEIJ:getValue("EIJ_FORLOJ"))
               lRet := .T.
               if empty(cVerOper) .or. (!empty(oModelEIJ:getValue("EIJ_TINFO")) .and. !(cVerOper == oModelEIJ:getValue("EIJ_VRSFOR")))
                  lRet := .F.
                  easyHelp(STR0204, STR0003, STR0205 ) // "A versão informada para o Operador Estrangeiro não é válida ou não está registrada." ### "Revise a versão informada."
               endif
            endif

         Case cCampo == 'EIN_FOBMOE'
            lRet := Vazio() .OR. ExistCpo("SYF",xNewVl, 1)

         Case cCampo == 'EIN_VLMLE'
            lRet := Positivo(xNewVl)

         Case cCampo == 'EJ9_DEMERC'
            SYA->(dbSetOrder(1))
            cPais := oModel:GetModel():GetValue("EIJMASTER","EIJ_PAISPR")
            IF !EMPTY(xNewVl) .AND.  (Empty(cPais) .or. !(POSICIONE("SYA",1,xFilial("SYA") + cPais,"YA_MERCOSU") $ cSim) )
               EasyHelp(STR0078, STR0003) //Atenção  // A declaração só deve ser informada se o país de procedência for membro do Mercosul.
               lRet := .F.
            EndIf

         Case cCampo == 'EIN_CODACR'
            lRet:= Vazio() .Or. ExistCpo("SJN", xNewVl)

         Case cCampo == 'EIN_CODDED'
            lRet:= Vazio() .Or. ExistCpo("SJO", xNewVl)

         Case cCampo == 'EIK_TIPVIN'
            //Opções para a DUIMP
            lRet:= Vazio() .Or. Pertence("1234")
         Case cCampo == "WV_SEQDUIM"

            xNewVl := if (xNewVl == nil .Or. ValType("cVlNew") # "C" ,"",StrZero(Val(xNewVl), AVSX3("WV_SEQDUIM", AV_TAMANHO)))
            If  !Empty(xNewVl) .And. xNewVl # xOldValue
               lRet:= ValidaItemDuimp(oModel, oSubModel, cCampo, xNewVl, nLine )
               If !lRet
                  EasyHelp(STR0047,STR0048,STR0049) //"Sequência DUIMP repetida","AVISO","Informe uma sequência ainda não utilizada"
               EndIf
            EndIf

         Case cCampo == 'EIJ_VRSFAB'
            lRet := empty(xNewVl)
            if !lRet
               oModelEIJ := oModel:GetModel("EIJMASTER")
               cIdCatalogo := oModelEIJ:GetValue("EIJ_IDPTCP")
               cVersao     := oModelEIJ:GetValue("EIJ_VRSACP")
               if !empty(cIdCatalogo) .and. !empty(cVersao)
                  lRet := xNewVl == GetFabFor("VERSAO", cIdCatalogo , cVersao, oModel )
               else
                  cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
                  lRet := xNewVl == LP500OpEst("EKJ_VERSAO", cCnpjRaiz, oModelEIJ:GetValue("EIJ_FABR"), oModelEIJ:GetValue("EIJ_FABLOJ"))
               endif
            endif

            if !lRet 
               EasyHelp(STR0124,STR0003,STR0125) //"Versão não encontrada no cadastro do operador estrangeiro","ATENÇÃO","Informe uma versão válida"
            endif
         case cCampo == "EIJ_FUNII" .or. cCampo == "EIJ_FUNIPI" .or. cCampo == "EIJ_FUNPIS" .or. cCampo == "EIJ_FUNCOF" .or. cCampo == "EIJ_FUNADU"

            do case
               case cCampo == "EIJ_FUNII" // Fundamento legal para II
                  cTributo := TEGetOpcTr("II")
                  cModelId := "EIJMASTER_II"
               case cCampo == "EIJ_FUNIPI" // Fundamento legal para IPI
                  cTributo := TEGetOpcTr("IPI")
                  cModelId := "EIJMASTER_IPI"
               case cCampo == "EIJ_FUNPIS" // Fundamento legal para PIS
                  cTributo := TEGetOpcTr("PIS")
                  cModelId := "EIJMASTER_PIS"
               case cCampo == "EIJ_FUNCOF" // Fundamento legal para COFINS
                  cTributo := TEGetOpcTr("COFINS")
                  cModelId := "EIJMASTER_COFINS"
               case cCampo == "EIJ_FUNADU" // Fundamento legal para ANTIDUMPING
                  cTributo := TEGetOpcTr("ANTIDUMPING")
                  cModelId := "EIJMASTER_ANTIDUMPING"
            end case

            cNcm := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):getValue("WV_NCM")
            cCpoInfo := getModEIJ(oModel, cModelId):GetValue(cCampo)
            if !empty(cCpoInfo)
               lRet := ExistCpo("EKV", cNcm + cCpoInfo + cTributo, 1)
            endif

         case lTribDUIMP .and. (cCampo == "EIJ_REGTRI" .or. cCampo == "EIJ_REGIPI" .or. cCampo == "EIJ_REGPIS" .or. cCampo == "EIJ_REGCOF")

            do case
               case cCampo == "EIJ_REGTRI"
                  cModelId := "EIJMASTER_II"
               case cCampo == "EIJ_REGIPI"
                  cModelId := "EIJMASTER_IPI"
               case cCampo == "EIJ_REGPIS"
                  cModelId := "EIJMASTER_PIS"
               case cCampo == "EIJ_REGCOF"
                  cModelId := "EIJMASTER_COFINS"
            end case

            cCpoInfo := getModEIJ(oModel, cModelId):GetValue(cCampo)
            lRet := empty(cCpoInfo) .or. ExistCpo("SJP", cCpoInfo)

         case lTribDUIMP .and. (cCampo == "EIJ_TPAII" .or. cCampo == "EIJ_TPAIPI" .or. cCampo == "EIJ_TPADUM")
            do case
               case cCampo == "EIJ_TPAII"
                  cModelId := "EIJMASTER_II"
               case cCampo == "EIJ_TPAIPI"
                  cModelId := "EIJMASTER_IPI"
               case cCampo == "EIJ_TPADUM"
                  cModelId := "EIJMASTER_ANTIDUMPING"
            end case
            cCpoInfo := getModEIJ(oModel, cModelId):GetValue(cCampo)
            lRet := empty(cCpoInfo) .or. Pertence("123")

         case lTribDUIMP .and. (cCampo == "EIJ_TPAPIS" .or. cCampo == "EIJ_TPACOF")
            do case
               case cCampo == "EIJ_TPAPIS"
                  cModelId := "EIJMASTER_PIS"
               case cCampo == "EIJ_TPACOF"
                  cModelId := "EIJMASTER_COFINS"
            end case
            cCpoInfo := getModEIJ(oModel, cModelId):GetValue(cCampo)
            lRet := empty(cCpoInfo) .or. Pertence("12")

         case lTribDUIMP .and. cCampo == "EIJ_STATUS"
            lRet := vazio() .or. Pertence( TEListComb( CP400CBox(cCampo), ";" ) + " " )

      EndCase
   EndIf
   RestArea(aArea)

Return lRet

/*
Função     : LP500WHEN
Objetivo   : Função para saber se campo pode ou nao ser habilitado para edição na tela
Parâmetro  :
Retorno    : .T. ou .F.
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500WHEN(cCampo)
   Local aArea      := GetArea()
   Local oModel     := FWModelActive()
   Local lRet       := .T.
   local oModelSWV  := nil
   local oModelEIJ  := nil

   begin sequence

      //quando a chamada vier do EICLP501, para inicialização ou atualização dos itens da DUIMP, não avaliar o when dos campos
      if getForceAtu()
         break
      endIf

      if cCampo $ LP500Model("EIJ", .F.) + "|" + LP500Model("EINA") + "|" + LP500Model("EIND") + "|" + ;
                  LP500Model("EKQ") + "|" + LP500Model("EIK") + "|" + LP500Model("EJ9");
         .and. valtype(oModelSWV := oModel:GetModel("SWVDETAIL")) == "O" .and. oModelSWV:isDeleted()
         lRet := .F.
      endif

      if cCampo $ LP500Model("EIJMASTER_II") + "|" + LP500Model("EIJMASTER_IPI") + "|" + LP500Model("EIJMASTER_PISCOFINS") + "|" + ;
                  LP500Model("EIJMASTER_PIS") + "|" + LP500Model("EIJMASTER_COFINS") + "|" + LP500Model("EIJMASTER_ANTIDUMPING") + "|" + ;
                  LP500Model("EIJMASTER_ICMS") +  "|" + LP500Model("EIJMASTER_OBSTRB") + "|" + LP500Model("EKXMASTER") + "|" + LP500Model("EKW");
         .and. valtype(oModelSWV := oModel:GetModel("SWVDETAIL_TRIBUTACAO")) == "O" .and. oModelSWV:isDeleted()
         lRet := .F.
      endif

      If cCampo $ "EIJ_VLC_DU|EIJ_VRCCOF|EIJ_VLSCOF|EIJ_VDECOF|EIJ_VRDCOF|EIJ_VLCCOF|EIJ_VRCPIS|EIJ_VLSPIS|EIJ_VDEPIS|EIJ_VRDPIS|EIJ_VLCPIS|EIJ_OBSTRB|EIJ_VRCIPI|EIJ_VLSIPI|EIJ_VRDIPI|EIJ_VDIPI|EIJ_VLCIPI|EIJ_VRCII|EIJ_VLSII|EIJ_VRDII|EIJ_VLDII|EIJ_VLCII"
         lRet := .F.
      EndIf

      if !lRet
         break
      endif

      Do CASE
         Case cCampo == 'EIJ_TINFA'
            lRet := .F.
         Case cCampo == 'EIJ_TINFO' .or. cCampo == 'EIJ_VRSFOR'
            lRet := .T.
         Case cCampo == 'EIJ_FABR'
            lRet := .T.
         Case cCampo == 'EIJ_FABLOJ'
            lRet := .T.
         Case cCampo == 'EIJ_PAISOR'
            lRet := .T.
         Case cCampo == 'EIJ_MODALI'
            lRet := .F.
         Case cCampo == 'EIJ_TIPCOB'
            lRet := .F.
         Case cCampo == 'EIJ_MOEDA'
            lRet := .F.
         Case cCampo == 'EIJ_VL_FIN'
            lRet := .F.
         Case cCampo == 'EIJ_MOTIVO'
            lRet := .F.
         Case cCampo == 'WV_SEQDUIM'    
            lRet := SW6->W6_FORMREG == DUIMP_MANUAL
         // campo EIJ - II 
         CASE cCampo == 'EIJ_REGTRI'
            lRet := .T.
         CASE cCampo == 'EIJ_FUNREG'
            lRet := !alltrim(getModEIJ(oModel, 'EIJMASTER_II'):GetValue('EIJ_REGTRI')) == "1"
         CASE cCampo == 'EIJ_TPAII'
            lRet := .F.
         CASE cCampo == 'EIJ_ALI_II'
            lRet := UseAliq("II", "AD VALOREM", getModEIJ(oModel, 'EIJMASTER_II'):GetValue('EIJ_REGTRI'), getModEIJ(oModel, 'EIJMASTER_II'):GetValue('EIJ_TPAII'))
         CASE cCampo == 'EIJ_ALR_II'
            lRet := UseAliq("II", "REDUZIDA", getModEIJ(oModel, 'EIJMASTER_II'):GetValue('EIJ_REGTRI'), getModEIJ(oModel, 'EIJMASTER_II'):GetValue('EIJ_TPAII'))
         // campo EIJ - IPI
         CASE cCampo == 'EIJ_REGIPI'
            lRet := .T.
         CASE cCampo == 'EIJ_ASSIPI'
            lRet := !alltrim(getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_REGIPI')) == "4"
         CASE cCampo == 'EIJ_TPAIPI'
            lRet := avFlags("TRIBUTACAO_DUIMP")
         CASE cCampo == 'EIJ_ALAIPI'
            lRet := .T.
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("IPI", "AD VALOREM", getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_REGIPI'), getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_TPAIPI'))
            endif
         case cCampo == 'EIJ_ALRIPI'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("IPI", "REDUZIDA", getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_REGIPI'), getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_TPAIPI'))
            endif
         case cCampo == 'EIJ_ALUIPI' .or. cCampo == 'EIJ_QTUIPI'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("IPI", "ESPECIFICA", getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_REGIPI'), getModEIJ(oModel, 'EIJMASTER_IPI'):GetValue('EIJ_TPAIPI'))
            endif
         // campo EIJ - PIS COFINS
         CASE cCampo == 'EIJ_REG_PC'
            lRet := .T.
         CASE cCampo == 'EIJ_FUN_PC'
            lRet := !alltrim(getModEIJ(oModel,'EIJMASTER_PISCOFINS'):GetValue('EIJ_REG_PC')) == "1"
         CASE cCampo == 'EIJ_TPAPIS'
            lRet := avFlags("TRIBUTACAO_DUIMP")
         CASE cCampo == 'EIJ_ALAPIS'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("PIS", "AD VALOREM", getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_REGPIS'), getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_TPAPIS'))
            endif
         case cCampo == 'EIJ_REDPIS'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("PIS", "REDUZIDA", getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_REGPIS'), getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_TPAPIS'))
            endif
         case cCampo == 'EIJ_ALUPIS' .or. cCampo == 'EIJ_QTUPIS'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("PIS", "ESPECIFICA", getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_REGPIS'), getModEIJ(oModel, 'EIJMASTER_PIS'):GetValue('EIJ_TPAPIS'))
            endif
         case cCampo == 'EIJ_ALPISM'
            lRet := .T.
         CASE cCampo == 'EIJ_TPACOF'
            lRet := avFlags("TRIBUTACAO_DUIMP")
         CASE cCampo == 'EIJ_ALACOF'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("COFINS", "AD VALOREM", getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_REGCOF'), getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_TPACOF'))
            endif
         case cCampo == 'EIJ_REDCOF'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("COFINS", "REDUZIDA", getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_REGCOF'), getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_TPACOF'))
            endif
         case cCampo == 'EIJ_ALUCOF' .or. cCampo == 'EIJ_QTUCOF'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("COFINS", "ESPECIFICA", getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_REGCOF'), getModEIJ(oModel, 'EIJMASTER_COFINS'):GetValue('EIJ_TPACOF'))
            endif
         case cCampo == 'EIJ_ALCOFM'
            lRet := .T.
         // campo EIJ - ICMS 
         CASE cCampo == 'EIJ_OPERAC'
            lRet := .T.
         // campo EIJ - ANTIDUMPING
         case cCampo == 'EIJ_TPADUM'
            lRet := .T.
         case cCampo == 'EIJ_ALADDU'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("ANTIDUMPING", "AD VALOREM", , getModEIJ(oModel, 'EIJMASTER_ANTIDUMPING'):GetValue('EIJ_TPADUM'))
            endif
         case cCampo == 'EIJ_BAE_AD' .or. cCampo == 'EIJ_ALEADU'
            if avFlags("TRIBUTACAO_DUIMP")
               lRet := UseAliq("ANTIDUMPING", "ESPECIFICA", , getModEIJ(oModel, 'EIJMASTER_ANTIDUMPING'):GetValue('EIJ_TPADUM'))
            endif
         case cCampo =='EIJ_VRSFAB'
            oModelEIJ := oModel:GetModel("EIJMASTER")
            lRet := !Empty(oModelEIJ:GetValue('EIJ_IDPTCP')) .and. !Empty(oModelEIJ:GetValue('EIJ_VRSACP')) 
         
         Case cCampo == "WV_MODAL" .Or. cCampo == "WV_AC" .Or. cCampo == "WV_SEQSIS"
            lRet := !EasyGParam("MV_EIC_EDC",,".F.")

         Case cCampo == "EKW_REGIME" .Or. cCampo == "EKW_TIPO"
            lRet := .F.

      EndCase

   end sequence

   RestArea(aArea)

Return lRet

Static Function TabItemNCM(cTmpAtrib)
cFileAtrib := E_CriaTrab(,{{"WV_ID","C",AVSX3("WV_ID",AV_TAMANHO),0}, {"YD_TEC","C",AVSX3("YD_TEC",AV_TAMANHO),0}, {"EK9_IDPORT","C",AVSX3("EK9_IDPORT",AV_TAMANHO),0}, {"EK9_VATUAL","C",AVSX3("EK9_VATUAL",AV_TAMANHO),0}}, cTmpAtrib)
IndRegua(cTmpAtrib, cFileAtrib + TEOrdBagExt(),"WV_ID+YD_TEC")
cIndCatPrd := e_create()
IndRegua(cTmpAtrib, cIndCatPrd + TEOrdBagExt(),"WV_ID+EK9_IDPORT")
SET INDEX TO (cFileAtrib + TEOrdBagExt()),(cIndCatPrd + TEOrdBagExt())
Return

Static Function TabItLPCO(cTmpLpco)
Local aEstrutura:= {}

AAdd(aEstrutura, {"WV_HAWB"   , "C", AVSX3('WV_HAWB'   ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_INVOICE", "C", AVSX3('WV_INVOIC' ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_PO_NUM" , "C", AVSX3('WV_PO_NUM' ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_POSICAO", "C", AVSX3('WV_POSICAO',AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_SEQUENC", "C", AVSX3('WV_SEQUENC',AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_ID"     , "C", AVSX3('WV_ID'     ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"WV_NCM"    , "C", AVSX3('YD_TEC'    ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"EKQ_ORGANU", "C", AVSX3('EKQ_ORGANU',AV_TAMANHO), 0})
AAdd(aEstrutura, {"EKQ_FRMLPC", "C", AVSX3('EKQ_FRMLPC',AV_TAMANHO), 0})
AAdd(aEstrutura, {"EKQ_LPCO"  , "C", AVSX3('EKQ_LPCO'  ,AV_TAMANHO), 0})
AAdd(aEstrutura, {"EKQ_VERSAO", "C", AVSX3('EKQ_VERSAO',AV_TAMANHO), 0})
AAdd(aEstrutura, {"EKQ_IDLPCO", "C", AVSX3('EKQ_IDLPCO',AV_TAMANHO), 0})

cFileLpco := E_CriaTrab(,aEstrutura, cTmpLpco)
IndRegua(cTmpLpco, cFileLpco + TEOrdBagExt(),"WV_HAWB+WV_INVOICE+WV_PO_NUM+WV_POSICAO+WV_SEQUENC")
cIndLpco := e_create()
IndRegua(cTmpLpco, cIndLpco + TEOrdBagExt(),"WV_ID")
cIndLpco2 := e_create()
IndRegua(cTmpLpco, cIndLpco2 + TEOrdBagExt(),"WV_ID+EKQ_ORGANU+EKQ_FRMLPC+EKQ_IDLPCO")
SET INDEX TO (cFileLpco + TEOrdBagExt()), (cIndLpco + TEOrdBagExt()), (cIndLpco2 + TEOrdBagExt())
Return

/*
Objetivo   : Função para carregar dados na SWV - Grid da porção superior da tela
Retorno    : Nil
Autor      : Ramon Prado
Data       : Agosto/2021
Revisão    : 15/09/2025: os dados estão gravados na base; carga a partir do banco de dados.
*/
Static Function LP500SWVLoad(oModel, lFinal, lMontaTela)
   Local cCampo      := ""
   Local aDadosPoui  := {}
   Local oCamposPoui := nil
   local oObjetivo   := nil 

   default lFinal   := .F.
   default lMontaTela := .T.

   oCamposPoui := jsonObject():New()
   oObjetivo := jsonObject():New()

   cCampo:= "WV_SEQUENC"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   cCampo:= "WV_NCM"
   oCamposPoui[cCampo] := allTrim(transform(oModel:getValue(cCampo), AvSx3("YD_TEC", AV_PICTURE)))
   oObjetivo['ncm'] := oModel:getValue(cCampo)

   cCampo:= "WV_QTDE"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   cCampo:= "WV_DESC_DI"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   cCampo:= "WV_ID"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)
   oObjetivo['idwv'] := oCamposPoui[cCampo]
   oFundLegal[oCamposPoui[cCampo]] := JsonObject():new()

   cCampo:= "WV_INVOICE"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)
   
   cCampo:= "WV_PO_NUM"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   cCampo:= "WV_POSICAO"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   cCampo:= "WV_COD_I"
   oCamposPoui[cCampo] := oModel:getValue(cCampo)

   setNcmAtri(cTmpAtrib, "NCM", oObjetivo['idwv'], oObjetivo['ncm'])
   //setLpcoAtr(cTmpLpco, "SWV", SW6->W6_HAWB, oCamposPoui['WV_INVOICE'], oCamposPoui['WV_PO_NUM'], oCamposPoui['WV_POSICAO'], oCamposPoui['WV_SEQUENC'], oCamposPoui['WV_ID'])
   aAdd(aDadosPoui, oCamposPoui)

   oVlCodObj[oObjetivo['idwv']] := oObjetivo
   freeObj(oCamposPoui)
   freeObj(oObjetivo)

   if lMontaTela
      montaTabelaPoui(aDadosPoui)
   endif

   //Monta o objeto com os atributos da DUIMP - EKG tipo 3
   if lFinal
      LP500ATCOM(cTmpAtrib, OBJETIVO_DUIMP)//Atributos complementares (atributos DUIMP)
   endIf
   //Monta o objeto com os atributos do Fundamento Legal - Informativos
   //LP500ATCOM(cTmpAtrib, OBJETIVO_FUNDAMENTO_LEGAL)//Atributos Informativos (atributos Fundamento Legal)

Return

/*/{Protheus.doc} LP500NextSeqDUIMP
description
@type function
@version  
@author wilsimar
@since 8/29/2025
@return variant, retorna a próxima sequencia do DUIMP
/*/
Function LP500NextSeqDUIMP()
local nSeqDuim as numeric 

   nSeqDuim:= ManLstFrm(,'_nSeqDUIMP',"GET")
   nSeqDuim++
   ManLstFrm(,'_nSeqDUIMP',"SET",,nSeqDuim)

Return nSeqDuim

Static Function setNcmAtri(cAlias, cTipo, cWVID, cNcm, cCatalogo, cVersao)
Local lSeek
lSeek := (cAlias)->(dbSeek(cWVID))
If cTipo == "NCM"
   RecLock(cAlias, !lSeek)
   (cAlias)->(WV_ID)       := cWVID
   (cAlias)->(YD_TEC) := cNcm
   (cAlias)->(MsUnlock())
Else //Catalogo
   RecLock(cAlias, !lSeek)
   (cAlias)->(EK9_IDPORT)  := cCatalogo
   (cAlias)->(EK9_VATUAL)  := cVersao
   (cAlias)->(MsUnlock())
EndIf
Return

Static Function setLpcoAtr(cAlias, cTipo, cHawb, cInvoice, cPO, cPosicao, cSequencia, cIdWV, cNcm, cOrgao, cForm, cLpco, cVersao, cIdLpco)
Local lSeek

If cTipo == "SWV"
   (cAlias)->(dbSetOrder(2))//WV_ID
   lSeek := (cAlias)->(dbSeek(cIdWV))
   RecLock(cAlias, !lSeek)
   (cAlias)->(WV_HAWB)    := cHawb
   (cAlias)->(WV_INVOICE) := cInvoice
   (cAlias)->(WV_PO_NUM)  := cPO
   (cAlias)->(WV_POSICAO) := cPosicao
   (cAlias)->(WV_SEQUENC) := cSequencia
   (cAlias)->(WV_ID)      := cIdWV
   (cAlias)->(MsUnlock())
Else //LPCO
   (cAlias)->(dbSetOrder(3))//WV_ID+EKQ_ORGANU+EKQ_FRMLPC+EKQ_IDLPCO
   lSeek := (cAlias)->(dbSeek(cIdWV + cOrgao + cForm))
   RecLock(cAlias, !lSeek)
   (cAlias)->(WV_HAWB)    := cHawb
   (cAlias)->(WV_INVOICE) := cInvoice
   (cAlias)->(WV_PO_NUM)  := cPO
   (cAlias)->(WV_POSICAO) := cPosicao
   (cAlias)->(WV_SEQUENC) := cSequencia
   (cAlias)->(WV_ID)      := cIdWV
   (cAlias)->(WV_NCM)      := cNcm
   (cAlias)->(EKQ_ORGANU) := cOrgao
   (cAlias)->(EKQ_FRMLPC) := cForm
   (cAlias)->(EKQ_LPCO)   := cLpco
   (cAlias)->(EKQ_VERSAO) := cVersao
   (cAlias)->(EKQ_IDLPCO) := cIdLpco
   (cAlias)->(MsUnlock())
EndIf
Return

Function LP500ATCOM(cAlias, cObj, cCallType)
Local oQuery
Local cQuery      := QryAttEKG(cAlias, cCallType)
Local cAliasAtt   := getNextAlias()
Local nOrder      := 0
Local oDePara     := TETypePOUI() //De para com os tipos de campos
Local oComposto   := jsonObject():New()
Local oAttCompl   := jsonObject():New()
Local oCondicao   := jSonObject():New()
Local oCampo
Local oDominio
Local oCondFilho
Local oAttCP
//Local cAliasDom
Local nPos
Local lComposto
Local lTemCondicao
Local cDivider := ""
Local aNames
Local nI
Local nY
Local lDisabled
Local cValue
Local cObjetivo := "%"+cObj+"%"
Local cChaveEV2 := ""
local nTamNCM   := 0
local cNCMAtrib := ""
local aDominios := {}
local nPosDomin := 0
local aAuxDom   := {}
local lMultiVal

Default cCallType := ""

oQuery := FWPreparedStatement():New(cQuery)

oQuery:SetString(1,  ' ') //EKH_NCM
oQuery:SetString(2,  '1') //EKH_MSBLQL
oQuery:SetString(3,  ' ') //EKH.D_E_L_E_T_
oQuery:SetString(4,  xFilial("EKG")) //EKG_FILIAL
oQuery:SetString(5,  '1') //EKG_MSBLQL
oQuery:SetString(6,  ' ') //EKG_MODALI
oQuery:SetString(7,  '3') //EKG_MODALI
oQuery:SetString(8,  '1') //EKG_MODALI
oQuery:SetString(9,  cObjetivo) //EKG_CODOBJ
oQuery:SetString(10,  ' ') //EKG.D_E_L_E_T_ =

cQuery := oQuery:GetFixQuery()

cAliasAtt := getNextAlias()
MPSysOpenQuery(cQuery, cAliasAtt)
TcSetField(cAliasAtt, "EKG_INIVIG", "D", 8, 0)
TcSetField(cAliasAtt, "EKG_FIMVIG", "D", 8, 0)

oAttCompl['listaAtributos'] := {}
oAttCompl['listaCompostos'] := {}
oComposto['listaComposto'] := jSonObject():New()
oCondicao['listaCondicao'] := jSonObject():New()

EKH->(dbSetOrder(1)) // EKH_FILIAL+EKH_NCM+EKH_COD_I+EKH_CODDOM
nTamNCM := getSX3Cache("EKH_NCM", "X3_TAMANHO")
cNCMAtrib := Space(nTamNCM)

While (cAliasAtt)->(!Eof())
   oCampo := jsonObject():New()
   lComposto := .F.
   lTemCondicao := .F.
   nOrder++
   //Trata os dominios do atributo quando tiver
   If (cAliasAtt)->(TEM_DOMINIO) > 0

      // cQuery := QryAttEKH(cAlias)
      // oQuery := FWPreparedStatement():New(cQuery)
      // oQuery:SetString(1, xFilial("EKH")) //EKH_FILIAL
      // oQuery:SetString(2, ' ') //EKH_NCM
      // oQuery:SetString(3, (cAliasAtt)->(EKG_COD_I)) //EKH_COD_I
      // oQuery:SetString(4, '1') //EKH_MSBLQL
      // oQuery:SetString(5, ' ')//EKH.D_L_E_T_
      // cQuery := oQuery:GetFixQuery()

      // cAliasDom := getNextAlias()
      // MPSysOpenQuery(cQuery, cAliasDom)

      // oDominio  := jsonObject():New()
      // oDominio['listaDominio'] := {}
      // While (cAliasDom)->(!Eof())
      //    aAdd(oDominio['listaDominio'], JsonObject():new())
      //    nPos := Len(oDominio['listaDominio'])
      //    oDominio['listaDominio'][nPos]['label' ] := Alltrim((cAliasDom)->EKH_DESCRE)
      //    oDominio['listaDominio'][nPos]['value' ] := Alltrim((cAliasDom)->EKH_CODDOM)

      //    (cAliasDom)->(dbSkip())
      // End
      // (cAliasDom)->(dbCloseArea())
      // FreeObj(oQuery)

      nPosDomin := aScan( aDominios, { |x| x[1] == xFilial("EKH") + cNCMAtrib + (cAliasAtt)->(EKG_COD_I) } )
      if nPosDomin == 0 .and. EKH->(dbSeek(xFilial("EKH") + cNCMAtrib + (cAliasAtt)->(EKG_COD_I)))
         oDominio := jsonObject():New()
         oDominio['listaDominio'] := {}

         While EKH->(!Eof()) .and. EKH->EKH_FILIAL == xFilial("EKH") .and. EKH->EKH_NCM == cNCMAtrib .and. EKH->EKH_COD_I == (cAliasAtt)->(EKG_COD_I)
            if !(alltrim(EKH->EKH_MSBLQL) == "1")
               aAdd(oDominio['listaDominio'], JsonObject():new())
               nPos := Len(oDominio['listaDominio'])
               oDominio['listaDominio'][nPos]['label' ] := Alltrim(EKH->EKH_CODDOM) + " - " + Alltrim(EKH->EKH_DESCRE)
               oDominio['listaDominio'][nPos]['value' ] := Alltrim(EKH->EKH_CODDOM)
            endif
            EKH->(dbSkip())
         End
         aAuxDom := { xFilial("EKH") + cNCMAtrib + (cAliasAtt)->(EKG_COD_I), oDominio }
         aAdd( aDominios , aClone(aAuxDom) )
         nPosDomin := len(aDominios)
      endif

      if nPosDomin > 0
         aAuxDom := aClone(aDominios[nPosDomin])
         oDominio := aAuxDom[2]
      endif
   EndIf

   If Alltrim((cAliasAtt)->(EKG_FORMA)) == ATT_COMPOSTO
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
      cargaCpoPO(@oCampo, cAliasAtt, nOrder == 1, oDePara, nOrder, cDivider, oDominio, .F.)

      // Valida se tem condição para deixar invisivel ao inicializar
      If lTemCondicao
         oCampo['visible'] := .F.
      EndIf

      //Valida atributos bloqueados quando for alteração
      lSeekVal := .F. //Valida se os atributos são comuns para Catalogo e LPCO
      lDisabled := .F.
      If cCallType == "INT_DUIMP_EV2"
         cChaveEV2 := (cAliasAtt)->(EV2_LOTE) + (cAliasAtt)->(EV2_HAWB) + (cAliasAtt)->(EV2_SEQDUI)
      EndIf
      lMultiVal := Alltrim((cAliasAtt)->(EKG_MULTVA)) == "1" .And. Alltrim((cAliasAtt)->(EKG_FORMA)) == ATT_LISTA_ESTATICA
      If !Empty(cValue := getValoratt(SW6->W6_HAWB, (cAliasAtt)->(WV_ID), Alltrim((cAliasAtt)->(EKG_COD_I)), Alltrim((cAliasAtt)->(EKG_CODOBJ)), @lSeekVal, @lDisabled, cObj, , cChaveEV2, lMultiVal))
         If lMultiVal
            oCampo['value'] := IIF(Valtype(cValue) == "A", getFormVal(Alltrim((cAliasAtt)->(EKG_FORMA)), cValue, 'advpl'),strTokArr(getFormVal(Alltrim((cAliasAtt)->(EKG_FORMA)), cValue, 'advpl'), ";"))
         Else
            oCampo['value'] := IIF(Alltrim((cAliasAtt)->(EKG_FORMA)) == ATT_BOOLEANO, cValue, getFormVal(Alltrim((cAliasAtt)->(EKG_FORMA)), cValue, 'advpl'))
         EndIf
      EndIf
      
      oCampo['disabled'] := lDisabled

      If lTemCondicao .And. lSeekVal
         oCampo['visible'] := .T.
      EndIf
      If (cAliasAtt)->(EKG_MSBLQL) == "1" .And. !Empty(cValue)
         oCampo['disabled'] := .T.
         oCampo['help']     := STR0169//"Este atributo encontra-se bloqueado e será excluído."
      EndIf
      If oCampo['status'] == "EXPIRADO" .And. !Empty(cValue)
         oCampo['disabled'] := .T.
         oCampo['help']     := STR0170 + DToC((cAliasAtt)->(EKG_FIMVIG)) + STR0171 //"Este atributo expirou em "####" e será excluído."
      EndIf
   
      If (oCampo['status'] != "EXPIRADO" .And. !oCampo['bloqueado']) .Or. (!Empty(oCampo['value']) .And. (oCampo['status'] == "EXPIRADO" .Or. (cAliasAtt)->(EKG_MSBLQL) == "1"))
         If inComposto(oComposto, Alltrim((cAliasAtt)->(EKG_CONDTE))) //Verifica se o Atributo pertence a um atributo Composto
            //Se é um filho de composto, armazera para montar depois
            oAttCP := oComposto['listaComposto']:GetJsonObject(Alltrim((cAliasAtt)->(EKG_CONDTE)))
            If ValType(oAttCP) <> "U"
               aAdd(oAttCP['listaAtributosCompostos'], oCampo)
            EndIf         
         Else
            aAdd(oAttCompl['listaAtributos'], oCampo)
         EndIf
      EndIf
   EndIf

   FreeObj(oDominio)
   FreeObj(oCampo)

(cAliasAtt)->(dbSkip())
End

//Trata os Atributos Compostos, para que fiquem por último
If Len(aNames := oComposto['listaComposto']:GetNames()) > 0
   For nI := 1 To Len(aNames)
      For nY := 1 To Len(oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'])
         If nY == 1 //Adicione o Divider
            oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY]['divider'] := oComposto['listaComposto'][aNames[nI]]['label']
         EndIf
         aAdd(oAttCompl['listaCompostos'], oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY])
      Next
   Next
EndIf

If Len(aNames := oCondicao['listaCondicao']:GetNames()) > 0
   For nI := 1 To Len(aNames)
      If (nPos := aScan(oAttCompl['listaAtributos'], {|X| X['property'] == aNames[nI]})) > 0
         oAttCompl['listaAtributos'][nPos]['condicaoPreenchimento'] := .T.
      EndIf
   Next
EndIf

oAttCompl['listaCondicao'] := oCondicao['listaCondicao']
If cObj == OBJETIVO_DUIMP
   oJsonPOUI['listaComplementares'] := oAttCompl
EndIf
(cAliasAtt)->(dbCloseArea())

Return

Static Function QryAttEKG(cAlias, cCallType)
Local cQuery := ""
Default cCallType := ""

cQuery := " SELECT "
cQuery += "  TMP.WV_ID, EKG.EKG_NCM, EKG.EKG_COD_I, EKG_NOME, EKG_CODOBJ, EKG_ORGAO, EKG.EKG_FORMA, EKG.EKG_MODALI, EKG.EKG_OBRIGA, EKG_MSBLQL, "
If cCallType == "INT_DUIMP_EV2"
   cQuery += "  TMP.EV2_LOTE, TMP.EV2_HAWB, TMP.EV2_SEQDUI, "
EndIf
cQuery += "  EKG.EKG_INIVIG, EKG.EKG_FIMVIG, EKG.EKG_TAMAXI, EKG_DECATR, EKG.EKG_CONDTE, EKG.EKG_MULTVA, EKG.R_E_C_N_O_ RECNO, "
cQuery += "    COALESCE((SELECT COUNT(EKH.EKH_COD_I) EKH_COD_I  "
cQuery += "              FROM " + RetSqlName("EKH") + " EKH "
cQuery += "              WHERE EKG.EKG_FILIAL     = EKH.EKH_FILIAL "
cQuery += "                AND (EKG.EKG_NCM    = EKH.EKH_NCM "
cQuery += "  	              OR EKH.EKH_NCM  = ?) " //1
cQuery += "                AND EKG.EKG_COD_I  = EKH.EKH_COD_I "
cQuery += "  	            AND EKH.EKH_MSBLQL <> ? " //2
cQuery += "                AND EKH.D_E_L_E_T_ = ? " //3
cQuery += "              GROUP BY EKH_COD_I), 0) TEM_DOMINIO "
cQuery += " FROM "
cQuery += "  " + RetSQLName("EKG") + " EKG INNER JOIN " + TETempName(cAlias) + " TMP ON (EKG_NCM = YD_TEC) "
cQuery += " WHERE "
cQuery += "  EKG.EKG_FILIAL = ? " //4
cQuery += "  AND EKG.EKG_MSBLQL <> ? " //5
cQuery += "  AND ( EKG.EKG_MODALI = ? OR EKG.EKG_MODALI = ? OR EKG.EKG_MODALI = ? ) " //6 / 7 / 8
cQuery += "  AND EKG.EKG_CODOBJ LIKE ? "//9
cQuery += "  AND EKG.D_E_L_E_T_ = ? " //10
cQuery += " ORDER BY "
cQuery += "  TMP.WV_ID, "
cQuery += "  EKG.EKG_CONDTE, "
cQuery += "  EKG.EKG_COD_I "

Return cQuery

// Static Function QryAttEKH(cAlias)
// Local cQuery := ""

// cQuery := " SELECT EKH_CODDOM, EKH_DESCRE "
// cQuery += " FROM " + RetSqlName("EKH") + " EKH "
// cQuery += " WHERE EKH.EKH_FILIAL = ?  " //1
// cQuery += "   AND EKH.EKH_NCM = ?  " //2
// cQuery += "     AND EKH.EKH_COD_I = ? " //3
// cQuery += " 	AND EKH.EKH_MSBLQL <> ? " //4
// cQuery += "     AND EKH.D_E_L_E_T_ = ? " //5
// cQuery += " ORDER BY "
// cQuery += "   EKH.EKH_COD_I, "
// cQuery += "   EKH.EKH_CODDOM "

// Return cQuery

/*
Função     : cargaCpoPO
Objetivo   : Montar objeto do campo a ser enviado para o Angular
Retorno    : -
Autor      : Tiago Tudisco
Data/Hora  : 06/03/2024
*/
Static Function cargaCpoPO(oCampo, cAliasAtt, lDivider, oDePara, nOrder, cDivider, oDominio, lIntegra)
Local cTypeForm

If lIntegra //Objeto resumido apenas para uso na integração
   oCampo['property']   := Alltrim((cAliasAtt)->(WV_ID)) + "-" + Alltrim((cAliasAtt)->(EKG_NCM)) + "-" + Alltrim((cAliasAtt)->(EKG_COD_I))
   oCampo['label'   ] := Alltrim((cAliasAtt)->(EKG_NOME))   
Else
   oCampo['property']   := Alltrim((cAliasAtt)->(WV_ID)) + "-" + Alltrim((cAliasAtt)->(EKG_NCM)) + "-" + Alltrim((cAliasAtt)->(EKG_COD_I))
   oCampo['label'   ] := Alltrim((cAliasAtt)->(EKG_NOME))
   oCampo['visible'] := .T.
   oCampo['id_att']     := Alltrim((cAliasAtt)->(EKG_COD_I))
   oCampo['idwv']       := Alltrim((cAliasAtt)->(WV_ID))
   oCampo['lastStatus'] := .T.
   oCampo['objetivo']   := Alltrim((cAliasAtt)->(EKG_CODOBJ))
   oCampo['orgao']      := Alltrim((cAliasAtt)->(EKG_ORGAO))
   oCampo['additionalHelpTooltip'] := oCampo['id_att']

   cTypeForm := Alltrim((cAliasAtt)->(EKG_FORMA))
   If lDivider
      oCampo['divider'] := cDivider
   EndIf

   oCampo['type'] :=  TEgetTpPOUI(oDePara, cTypeForm)

   If cTypeForm == 'LISTA_ESTATICA' .And. ValType(oDominio) != "U"
      oCampo['options'] := oDominio['listaDominio']
      oCampo['optionsMulti'] := (cAliasAtt)->(EKG_MULTVA) == "1"

   ElseIf cTypeForm == ATT_BOOLEANO
      oCampo['booleanFalse'] := "Não"
      oCampo['booleanTrue']  := "Sim"
   ElseIf cTypeForm == ATT_TEXTO .And. (cAliasAtt)->(EKG_MULTVA) == "1"
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

   If cTypeForm == ATT_DATA
      oCampo["format"]     := getFormVal(cTypeForm)
   EndIf

   oCampo['condicionante'] := (cAliasAtt)->(EKG_CONDTE)
   oCampo['status']        := CP400Status((cAliasAtt)->(EKG_INIVIG), (cAliasAtt)->(EKG_FIMVIG))
   oCampo['bloqueado']     := IIF((cAliasAtt)->(EKG_MSBLQL) == '1' .Or. oCampo['status'] == "EXPIRADO", .T., .F.)
   oCampo['disabled']      := .F.
   If oCampo['status'] == "FUTURO"
      oCampo['help'] := STR0172 + DToC((cAliasAtt)->(EKG_INIVIG)) + "." //"Este atributo tem vigência futura a partir de "
   EndIf
EndIf
Return

Static Function inComposto(oComposto, cAtributo)
Return !Empty(oComposto['listaComposto']:HasProperty(cAtributo))

/*
Função     : cargaInfPO
Objetivo   : Montar objeto do campo a ser enviado para o Angular
Retorno    : -
Autor      : Tiago Tudisco
Data/Hora  : 06/03/2024
*/
Static Function cargaInfPO(oCampo, oInformati, lDivider, oDePara, nOrder, cDivider, oDominio, lIntegra, cIdEnt)
Local cTypeForm

oCampo['property']   := cIdEnt + Alltrim(oInformati['codigo'])
oCampo['label'   ]   := Alltrim(oInformati['nomeApresentacao'])
oCampo['visible']    := .T.
oCampo['id_att']     := Alltrim(oInformati['codigo'])
oCampo['idwv']       := Alltrim(cActiveID)
oCampo['additionalHelpTooltip'] := oCampo['id_att']

cTypeForm := Alltrim(oInformati['formaPreenchimento'])
If lDivider
   oCampo['divider'] := cDivider
EndIf

oCampo['type'] :=  TEgetTpPOUI(oDePara, cTypeForm)

If cTypeForm == 'LISTA_ESTATICA' .And. ValType(oDominio) != "U"
   oCampo['options']       := oDominio['listaDominio']
   oCampo['optionsMulti']  := oInformati['multivalorado']

ElseIf cTypeForm == ATT_BOOLEANO
   oCampo['booleanFalse'] := "Não"
   oCampo['booleanTrue']  := "Sim"
ElseIf cTypeForm == ATT_TEXTO .And. oInformati['multivalorado']
   oCampo['rows'] := 5
EndIf

oCampo['order']         :=  nOrder
oCampo['required']      :=  oInformati['obrigatorio']
oCampo['showRequired']  :=  oCampo['required']
oCampo['optional']      :=  !oInformati['obrigatorio']
oCampo['maxLength']     :=  if(oInformati:GetJsonText('tamanhoMaximo')=='null',0,Val(oInformati:GetJsonText('tamanhoMaximo')))
If cTypeForm == 'VALOR_MONETARIO'
   oCampo['decimalsLength'] := if(oInformati:GetJsonText('casasDecimais')=='null',0,Val(oInformati:GetJsonText('casasDecimais')))
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
   oCampo["format"]     := getFormVal(cTypeForm)
EndIf

oCampo['condicionante'] := oInformati['condicionante']
oCampo['status']        := CP400Status(SToD(StrTran(oInformati:GetJsonText('dataInicioVigencia'),'-','')), SToD(StrTran(oInformati:GetJsonText('dataFimVigencia'),'-','')))
oCampo['bloqueado']     := IIF(oCampo['status'] == "EXPIRADO", .T., .F.)
oCampo['disabled']      := .F.
oCampo['idwv']          := cActiveID
oCampo['deleted']       := .F.
oCampo['lastStatus']    := .T.
If oCampo['status'] == "FUTURO"
   oCampo['help'] := STR0172 + DToC(SToD(StrTran(oInformati:GetJsonText('dataInicioVigencia'),'-',''))) + "." //"Este atributo tem vigência futura a partir de "
EndIf

Return


/*
Função     : getValorAtt
Objetivo   : Função para retornar o valor dos atributos gravados no banco
Autor      : Nicolas
Data/Hora  : 04/03/2024
*/
Static Function getValorAtt(cHawb, cID, cAtributo, cObjetivo, lSeek, lDisabled, cTipo, cInfoValor, cChaveEV2, lMultiVal)
Local cChave
Local cRet := ""
Local nPos
Local oAtt
Local aObjetivo := StrTokArr2(cObjetivo, ";")
Local aArea := getArea()
Local aAreaEV2

Default cInfoValor:= ""
Default cChaveEV2 := ""
Default lMultiVal := .F.

If cTipo == OBJETIVO_DUIMP
   If !Empty(cChaveEV2)
      aAreaEV2 := EV2->(getArea())
      EV2->(dbSetOrder(3)) //EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
      If EV2->(dbSeek(xFilial("EV2") + cChaveEV2))
         cInfoValor := EV2->EV2_ATRIBU
      EndIf
      RestArea(aAreaEV2)
   EndIf

   // Preenche o valor do atributo no campo
   lSeek := .F.
   If !Empty(cInfoValor)
      oAtt := jsonObject():New()
      oAtt:FromJson(cInfoValor)
   Else
      SWV->(dbSetOrder(5)) //WV_FILIAL + WV_HAWB + WV_ID
      cChave := xFilial("SWV") + cHawb + cID

      If Empty(cChaveEV2) .And. SWV->(dbSeek(cChave))
         lSeek := .T.
         If lSeek .And. !Empty(SWV->WV_ATRIBUT) //Ja tem dados gravados para o item, buscar os valores
            oAtt := jsonObject():New()
            oAtt:FromJson(SWV->WV_ATRIBUT)
         EndIf
      EndIf

   EndIf

   If oAtt <> nil .And. oAtt:hasProperty('atributosDuimp')
      If lMultiVal
         cRet := getMultiVl(oAtt, cAtributo, 'atributosDuimp')
      Else
         nPos := aScan(oAtt['atributosDuimp'], {|x| x['codigo'] == cAtributo})
         If nPos > 0
            cRet := oAtt['atributosDuimp'][nPos]['valor']
         EndIf
      EndIf
   EndIf
   // Procura o atributo no banco para buscar seu valor
   lDisabled := Len(aObjetivo) > 1 .And. aScan(aObjetivo, {|x| x == OBJETIVO_CATALOGO}) > 0

ElseIf cTipo == OBJETIVO_FUNDAMENTO_LEGAL

   lSeek := .F.
   If !Empty(cInfoValor)
      oAtt := jsonObject():New()
      oAtt:FromJson(cInfoValor)
   Else
      SWV->(dbSetOrder(5)) //WV_FILIAL + WV_HAWB + WV_ID
      cChave := xFilial("SWV") + cHawb + cID

      If SWV->(dbSeek(cChave))
         lSeek := .T.
         If lSeek .And. !Empty(SWV->WV_ATT_FL) //Ja tem dados gravados para o item, buscar os valores
            oAtt := jsonObject():New()
            oAtt:FromJson(SWV->WV_ATT_FL)
         EndIf
      EndIf
   EndIf

   If oAtt <> nil .And. oAtt:hasProperty('atributosFundamentoLegalDuimp')
      If lMultiVal
         cRet := getMultiVl(oAtt, cAtributo, 'atributosFundamentoLegalDuimp')
      Else
         nPos := aScan(oAtt['atributosFundamentoLegalDuimp'], {|x| x['codigo'] == cAtributo})
         If nPos > 0
            cRet := oAtt['atributosFundamentoLegalDuimp'][nPos]['valor']
         EndIf
      EndIf
   EndIf
EndIf

restArea(aArea)
Return cRet


Static Function getMultiVl(oJson, cAtributo, cProperty)
Local aValores := {}
Local nI

// Verifica se tem a propriedade atributosDuimp
If oJson:HasProperty(cProperty) .And. ValType(oJson[cProperty]) == "A"
   For nI := 1 To Len(oJson[cProperty])
      // Verifica se o item tem as propriedades necessárias
      If oJson[cProperty][nI]:HasProperty("codigo") .And. oJson[cProperty][nI]:HasProperty("valor")
         If oJson[cProperty][nI]["codigo"] == cAtributo
            aAdd(aValores, oJson[cProperty][nI]["valor"])
         EndIf
      EndIf
   Next nI
EndIf

Return aValores 

Static Function getFormVal(cForma, cValor, cCode, lInteg)
Local cRet

Default cCode := "POUI"
default lInteg := .F.

if !empty(cForma)
   cForma := Alltrim(cForma)
   If ValType(cValor) == "C"
      cValor := Alltrim(strtran(cValor, chr(13)+chr(10), " "))
   EndIf
   Do Case
      Case cForma == ATT_BOOLEANO
         If cValor == '1'
            cRet := IIF(cCode == "POUI", "true", ".T.")
         Else
            cRet := IIF(cCode == "POUI", "false", ".F.")
         EndIf
      Case cForma == ATT_DATA
         cRet:= ExtractDt(cValor)//"dd/mm/yyyy"//'0000-00-00T00:00:00.00Z'
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


//-------------------------------------------------------------------
Static Function ExtractDt(cTimestamp)
Local cRet := ""
Default cTimestamp := ""

If Len(cTimestamp) >= 10
   cRet:=Left(cTimestamp, 10)
EndIf
Return cRet

/*
Objetivo   : Função para montar e formatar a tabela que será exibida no POUI
Retorno    : Nil
Autor      : Nícolas Brisque
Data       : Janeiro/2025
Revisão    :
*/
Static Function montaTabelaPoui(aDados)
Local aColunas := {}
Local aCampos := {'WV_ID', 'WV_INVOICE', 'WV_PO_NUM', 'WV_POSICAO', 'WV_SEQUENC', 'WV_COD_I', 'WV_DESC_DI', 'WV_NCM', "WV_QTDE"}
Local oColuna := jsonObject():New()
Local oJsonItens := jsonObject():New()
Local cDecimais  := cValToChar(AvSX3("WV_QTDE", AV_DECIMAL))
Local i

   oJsonItens['listaItensSWV'] := jsonObject():New()
   oJsonItens['listaItensSWV']['columns'] := {}
   oJsonItens['listaItensSWV']['items'] := {}

   If !oJsonPOUI['listaItensSWV']:hasProperty('listaItensSWV') .Or. !oJsonPOUI['listaItensSWV']['listaItensSWV']:hasProperty('columns')
      For i := 1 to Len(aCampos)
         oColuna := jsonObject():New()
         oColuna['property'] := aCampos[i]
         oColuna['label'] := Alltrim(FWX3Titulo(aCampos[i]))
            if aCampos[i] == "WV_QTDE"
               oColuna['type']   := "number"
               oColuna["format"] := "1." + cDecimais + "-" + cDecimais
            EndIf

         aAdd(aColunas, oColuna)
         FreeObj(oColuna)
      Next i
      oColuna := getSubTitle()//Monsta a coluna de Subtitulo Catalogo e LPCO
      aAdd(aColunas, oColuna)
      FreeObj(oColuna)
      oJsonItens['listaItensSWV']['columns'] := aColunas
      oJsonItens['listaItensSWV']['items'] := aDados
      oJsonPOUI['listaItensSWV'] := oJsonItens
   Else
      //aScan(aDados, {|x| aAdd(oJsonPOUI['listaItensSWV']['listaItensSWV']['items'], x)}) //confirmar essa linha; será que não é um aeval ao invés de um ascan?
      AEval(aDados, {|x| aAdd(oJsonPOUI['listaItensSWV']['listaItensSWV']['items'], x)} )
   EndIf

   freeObj(oJsonItens)
   freeObj(oColuna)
Return

Static Function getSubTitle()
Local oSubTitle := jsonObject():New()
Local cCatalogo

cCatalogo := '{'+;
				'"property": "status",'+;
				'"label": "' + STR0173 + '",'+; //"Catálogo"
				'"type": "subtitle",'+;
				'"width": "180px",'+;
				'"subtitles": ['+;
					'{'+;
						'"value": "OK",'+;
						'"color": "color-10",'+;
						'"label": "' + STR0174 + '",'+; //"Item possui Catálogo de Produtos e LPCO"
						'"content": "OK"'+;
					'},'+;
					'{'+;
						'"value": "CP",'+;
						'"color": "color-01",'+;
						'"label": "' + STR0175 + '",'+; //"Item possui Catálogo de Produtos"
						'"content": "CP"'+;
					'},'+;
					'{'+;
						'"value": "LI",'+;
						'"color": "color-05",'+;
						'"label": "' + STR0176 + '",'+; //"Item possui LPCO"
						'"content": "LI"'+;
					'},'+;
					'{'+;
						'"value": "NO",'+;
						'"color": "color-07",'+;
						'"label": "' + STR0177 + '",'+; //"Item não possui Catálogo de Produtos e LPCO"
						'"content": "NO"'+;
					'}'+;
				']'+;
			'}'

oSubTitle:fromJson(cCatalogo)
Return oSubTitle

/*
Objetivo      : Função para carregar dados na SWV - Grid da porção inferior da tela
Retorno    : Nil
Autor      : Ramon Prado
Data       : Agosto/2021
Revisão    :
*/
Static Function EKQLoad(oModel)
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") //teste da carga do model
   local jsonItem      := jsonObject():New()
   local oObjLPCO
   local lTemLpco
   local cHawb    := oModelSWV:GetValue("WV_HAWB")
   local cInvoice := oModelSWV:GetValue("WV_INVOICE")
   local cPONUM   := oModelSWV:GetValue("WV_PO_NUM")
   local cPosicao := oModelSWV:GetValue("WV_POSICAO")
   local cSequenc := oModelSWV:GetValue("WV_SEQUENC")
   local cIdWV    := oModelSWV:GetValue("WV_ID")
   local cNcm     := oModelSWV:GetValue("WV_NCM")
   local cLPCO    := ""
   local cLPCOVer := ""

   cLPCO := oModel:getValue("EKQ_LPCO")
   cLPCOVer := oModel:getValue("EKQ_VERSAO")
   oVlCodObj[cIdWV]['lpco'] := {}

   lTemLpco := !empty(cLPCO) .And. !empty(cLPCOVer)
   if lTemLpco
      oObjLPCO := jsonObject():New()
      oObjLPCO['orgao'] := oModel:getValue("EKQ_ORGANU")
      oObjLPCO['formLpco'] := oModel:getValue("EKQ_FRMLPC")
      oObjLPCO['lpco'] := cLPCO
      oObjLPCO['versao'] := cLPCOVer
      oObjLPCO['idLpco'] := oModel:getValue("EKQ_IDLPCO")
      aAdd(oVlCodObj[cIdWV]['lpco'], jSonObject():New())
      oVlCodObj[cIdWV]['lpco'][Len(oVlCodObj[cIdWV]['lpco'])] := oObjLPCO
      setLpcoAtr(cTmpLpco, "EKQ", cHawb, cInvoice, cPONUM, cPosicao, cSequenc, cIdWV, cNcm, oObjLPCO['orgao'], oObjLPCO['formLpco'], oObjLPCO['lpco'], oObjLPCO['versao'], oObjLPCO['idLpco'])
      freeObj(oObjLPCO)
   endif

   if lTemLpco
      jsonItem['id']    := cIdWV
      jsonItem['lpco']  := .T.
   else
      jsonItem['id']    := cIdWV
      jsonItem['lpco']  := .F.
   EndIf
   
   If oJsonPOUI['listaItensSWV']:hasProperty('listaItensLpco')
      oJsonPOUI['listaItensSWV']['listaItensLpco'][cIdWV] := jsonItem
   Else
      oJsonPOUI['listaItensSWV']['listaItensLpco'] := jSonObject():New()
      oJsonPOUI['listaItensSWV']['listaItensLpco'][cIdWV] := jsonItem
   EndIf

   freeObj(jsonItem)

Return

/*
Objetivo   : Função para carregar dados na tabela EIJ
Retorno    : Nil
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function EIJLoad(oModel)
   local jsonItem   := jsonObject():New()
   local lTemCP
   local cIdWV:= oModel:getValue("EIJ_IDWV")
   local cCatalogo:= oModel:getValue("EIJ_IDPTCP")
   local cVersao:= oModel:getValue("EIJ_VRSACP")

   lTemCP := !Empty(cCatalogo)

   setNcmAtri(cTmpAtrib, "CATALOGO", cIdWV, , cCatalogo, cVersao)
   oVlCodObj[cIdWV]['catalogo'] := jsonObject():New()
   oVlCodObj[cIdWV]['catalogo']['catalogo'] := cCatalogo
   oVlCodObj[cIdWV]['catalogo']['versao']   := cVersao

   jsonItem['id']       := cIdWV
   jsonItem['catalogo'] := lTemCP

   If oJsonPOUI['listaItensSWV']:hasProperty('listaItensCatalogo')
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'][cIdWV] := jsonItem
   Else
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'] := jSonObject():New()
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'][cIdWV] := jsonItem
   EndIf

   freeObj(jsonItem)

Return

/*
Função     : LP500INI
Objetivo   : Função que retorna String de campos que existem na SWV e nao existem na SW8
Parâmetro  :
Retorno    : String de campos que existem na SWV e nao existem na SW8
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500INI(cCampo,oMdl, c)
   Local oModelSWV  := nil
   local oModelEIJ  := nil
   Local cRet       := ""
   local aRet       := {}
   Local cOrgAnu    := ""
   local cForm      := ""
   local lVisual    := .F.
   local cCpoInfo   := ""
   local cNCM       := ""

   Default oMdl := FwModelActive()

   If AvFlags("DUIMP") .and. ValType(oMdl) == "O"

      if(!(oMdl:getId() == "EICLP500"), oMdl := oMdl:GetModel(), nil) //Carrega Model Master

      If oMdl:getId() == "EICLP500" .and. ( oMdl:GetOperation() == MODEL_OPERATION_UPDATE .or. (lVisual := oMdl:GetOperation() == MODEL_OPERATION_VIEW) )
         //Objeto oMdl quando é chamado pelo Load do grid não está ativo ainda

         // quando executa a rotina do financeiro, como liquidar parcela por exemplo, e depois entrar aqui o oMdl vinha com o objeto
         // do financeiro e dava erro no inicializador dos campos, por isso usamos o cid == "EICLP500"
         //Estará ativo quando for chamado pela inclusão de linha(manual ou automatica)

         oModelSWV := oMdl:GETMODEL("SWVDETAIL")

         Do Case
            //inicializacao de campos da chave - inclusao de linha nova
            Case cCampo == "EKQ_FILIAL"
               cRet := xFilial("EKQ")
            Case cCampo == "EKQ_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EKQ_INVOIC"
               cRet := oModelSWV:GETVALUE("WV_INVOICE")
            Case cCampo == "EKQ_PO_NUM"
               cRet := oModelSWV:GETVALUE("WV_PO_NUM")
            Case cCampo == "EKQ_POSICA"
               cRet := oModelSWV:GETVALUE("WV_POSICAO")
            Case cCampo == "EKQ_SEQUEN"
               cRet := oModelSWV:GETVALUE("WV_SEQUENC")
            Case cCampo == "EKQ_OBRFRM"
               If !oModelSWV:IsDeleted()
                  cRet := "2" //Não - inicialização do campo 'Obrigatorio?'
               else
                  cRet := ""
               EndIf
            Case cCampo == "EKQ_VERSAO"
               cRet := ""
            Case cCampo == "EKQ_IDLPCO"
               cRet := ""
            Case cCampo == "EKQ_DSCFRM"
               cRet := ""
               If !oModelSWV:IsDeleted() .And. !empty(cOrgAnu := EKQ->EKQ_ORGANU) .and. !empty(cForm := EKQ->EKQ_FRMLPC)
                  cRet := LP500GetInfo("EKL",1,xFilial("EKL") + cOrgAnu + cForm , "EKL_DESC"  )
               EndIf
            Case cCampo == "EIJ_IMPORT"
               cRet := SW6->W6_IMPORT
            Case cCampo == "EIJ_NOMIMP"
               cRet := LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_NOME")
            Case cCampo == "EIJ_CNPJRZ"
               cRet := LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" )
            Case cCampo == "EIJ_UNIDCO"
               cRet := ""
               if !empty(oModelSWV:GetValue("WV_HAWB")) .and. !empty(oModelSWV:GetValue("WV_INVOICE")) .and. !empty(oModelSWV:GetValue("WV_PO_NUM")) .and. !empty(oModelSWV:GetValue("WV_POSICAO")) .and. !empty(oModelSWV:GetValue("WV_PGI_NUM"))
                  aRet := GetInfW7W8(oModelSWV, {"W8_UNID"})
                  if len(aRet) > 0
                     cRet := aRet[1]
                  endIf
               endif
            Case cCampo == "EIJ_QTDECO"
               cRet := oModelSWV:GETVALUE("WV_QTDE")
            Case cCampo == "EIJ_UNDEST"
               // Para efeitos de unidade de medida estatística, a NCM_EX não é relevante
               cRet := if( !empty( cNCM := getNCM(oModelSWV)), LP500GetInfo("SYD", 1, xFilial("SYD") + cNCM, "YD_UNID",,, "EIJ_UNDEST"), "" )
            Case cCampo == "EIJ_FABRVM"
               oModelEIJ := oMdl:getModel("EIJMASTER")
               if !empty(oModelEIJ:GetValue("EIJ_FABR")) .and. !empty(oModelEIJ:GetValue("EIJ_FABLOJ"))
                  cRet := LP500GetInfo("SA2", 1, xFilial("SA2") + oModelEIJ:GetValue("EIJ_FABR") + oModelEIJ:GetValue("EIJ_FABLOJ"), "A2_NREDUZ" )
               endif
               cRet := AvKey(if(!Empty(cRet),cRet,""), "EIJ_FABRVM")
            Case cCampo == "EIN_DESC"
               cRet := ""
            Case cCampo == "EIN_FILIAL"
               cRet :=  xFilial("EIN")
            Case cCampo == "EIN_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EIN_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            Case cCampo == "EJ9_FILIAL"
               cRet :=  xFilial("EJ9")
            Case cCampo == "EJ9_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EJ9_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            Case cCampo == "EIK_FILIAL"
               cRet :=  xFilial("EIK")
            Case cCampo == "EIK_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EIK_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            case (cCampo == "EIJ_DSCFL1" .or. cCampo == "EIJ_DSCFL2" .or. cCampo == "EIJ_DSCFL3" .or. cCampo == "EIJ_DSCFL4" .or. cCampo == "EIJ_DSCFL5")
               do case
                  case cCampo == "EIJ_DSCFL1"
                     cCpoInfo := EIJ->EIJ_FUNII // Fundamento legal para II
                  case cCampo == "EIJ_DSCFL2"
                     cCpoInfo := EIJ->EIJ_FUNIPI // Fundamento legal para IPI
                  case cCampo == "EIJ_DSCFL3"
                     cCpoInfo := EIJ->EIJ_FUNPIS // Fundamento legal para PIS
                  case cCampo == "EIJ_DSCFL4"
                     cCpoInfo := EIJ->EIJ_FUNCOF // Fundamento legal para COFINS
                  case cCampo == "EIJ_DSCFL5"
                     cCpoInfo := EIJ->EIJ_FUNADU // Fundamento legal para ANTIDUMPING
               end case
               cRet := getDscFL(cCampo,cCpoInfo)
            case cCampo == "EIJ_DSCRG1" .or. cCampo == "EIJ_DSCRG2" .or. cCampo == "EIJ_DSCRG3" .or. cCampo == "EIJ_DSCRG4"
               do case
                  case cCampo == "EIJ_DSCRG1"
                     cCpoInfo := if( empty(EIJ->EIJ_REGTRI), "1", EIJ->EIJ_REGTRI ) // Regime tributário para II
                  case cCampo == "EIJ_DSCRG2"
                     cCpoInfo := if( empty(EIJ->EIJ_REGIPI), "1", EIJ->EIJ_REGIPI ) // Regime tributário para IPI
                  case cCampo == "EIJ_DSCRG3"
                     cCpoInfo := if( empty(EIJ->EIJ_REGPIS), "1", EIJ->EIJ_REGPIS ) // Regime tributário para PIS
                  case cCampo == "EIJ_DSCRG4"
                     cCpoInfo := if( empty(EIJ->EIJ_REGCOF), "1", EIJ->EIJ_REGCOF ) // Regime tributário para COFINS
               end case
               cRet := getDscRG(cCampo, cCpoInfo)
            case cCampo == "EIJ_REGCOF" .or. cCampo == "EIJ_REGPIS"
               cRet := "1" // Recolhimento Integral
            case cCampo == "EIJ_STATUS"
               cRet := GetStatCat(getNCM(oModelSWV), EIJ->EIJ_IDPTCP, EIJ->EIJ_VRSACP)
            case cCampo == "WV_DESC_DI"
               cRet := space( getSx3Cache("WV_DESC_DI", "X3_TAMANHO") )
               if !empty(SWV->WV_COD_I)
                  cRet := LP500GetInfo("SB1", 1, xFilial("SB1") + SWV->WV_COD_I, "B1_DESC" )
               endif
            case cCampo == "WV_NOMEFOR"
               cRet := space( getSx3Cache("WV_NOMEFOR", "X3_TAMANHO") )
               if !Empty(SWV->WV_FORN)
                  cRet := LP500GetInfo("SA2", 1, xFilial("SA2") + SWV->WV_FORN + SWV->WV_FORLOJ, "A2_NREDUZ")
               endif
            case cCampo == "WV_DSCREG"
               cRet := space( getSx3Cache("WV_DSCREG", "X3_TAMANHO") )
               if !empty(SWV->WV_CODREG)
                  cRet := retCpoTrb(SWV->WV_CODREG, "EKR_DESCRI")
               endif
            Case cCampo == "WV_ID"
               cRet:= getWVId()
            
            Case cCampo == "WV_HAWB"
               cRet:= SW6->W6_HAWB

            case cCampo == "WV_ID_GRP"
               cRet := space( getSx3Cache("WV_ID", "X3_TAMANHO") )

            Otherwise
               cRet := if( lVisual, loadEmpty(cCampo), CRIAVAR(cCampo) )
         EndCase
         //oMdl:DeActivate() Tentei desativar aqui, mas começou a dar errorlog
			//oMdl:Destroy() Tentei destruir aqui, mas começou a dar errorlog
      EndIf

   EndIf

Return cRet

/*/{Protheus.doc} getWVId
Função para pegar o ID a partir do License Server
O ID será montado a partir da chave composta pelo ID e número do processo de importação
@type function
@version  
@author wilsimar
@since 9/4/2025
@return variant, ID
/*/
Static Function getWVId()
   local cIdWV as character
   local cHawb as character
   local oUserParam as object

   cHawb:= SW6->W6_HAWB
   cIdWV := getIDEWQ( cHawb, @oUserParam )
   cIdWV:= Soma1(cIdWV)  
   LP500IDEWQ( cHawb, cIdWV, oUserParams )

Return cIdWV

static function getIDEWQ( cHawb, oUserParams )
   local cIdWV := ""
   oUserParam := EASYUSERCFG():New('LP500_IDWV',,FWCodFil()) //tabela EWQ
   cIdWV := oUserParams:LoadParam(cHawb, STRZERO(0, AVSX3("WV_ID",AV_TAMANHO)), "LP500_IDWV")
return cIdWV

function LP500IDEWQ( cHawb, cIdWV, oUserParams )
   default oUserParam := EASYUSERCFG():New('LP500_IDWV',,FWCodFil()) 
   oUserParams:SetParam(cHawb, cIdWV , "LP500_IDWV")
return 

/*
Programa   : LP500COMMIT
Objetivo   : Funcao de Commit -
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/

Static Function LP500COMMIT(oMdl)
   Local nOpc       := oMdl:GetOperation()
   Local lRet := .T.

   Private lGerPrDI := EasyGParam("MV_EASYFDI",,"S")  $ cSim
   Private cControle

   If nOpc == MODEL_OPERATION_UPDATE

      lRet := FWFormCommit(oMdl)

      IF lRet .and. EasyGParam("MV_EASYFIN",,"N") $ cSim .And. lGerPrDI .and. !FWIsInCallStack("LP501Estor")
         If SW6->W6_TIPOFEC <> "DIN"
            DeleImpDesp(SW6->W6_NUMDUP,"PRE","DI",.T.)
            cControle := "Inclusao"
            Processa({|| AVPOS_DI(SW6->W6_HAWB,lGerPrDI) })
         EndIf
      EndIf

   EndIf

Return lRet

/*
Função     : LP500SetVar
Objetivo   : Manipular o array estático de NcmxForms LPCO - o Array __aLstFrmNCM é carregado no LOAD do grid superior
Retorno    : Logico/array
Autor      : Nilson Cesar
Data/Hora  : Agosto/2021
Obs.       :
*/
function LP500SetVar(oMdl,cVar,cCmd,cKey,xValue)
return ManLstFrm(oMdl,cVar,cCmd,cKey,xValue)

/*
Função     : ManLstFrm
Objetivo   : Manipular o array estático de NcmxForms LPCO - o Array __aLstFrmNCM é carregado no LOAD do grid superior
Retorno    : Logico/array
Autor      : Nilson Cesar
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ManLstFrm(oMdl,cVar,cCmd,cKey,xValue)
   Local xRet := .T.

   If cVar == '__aLstFrmNcm'
      If cCmd == "SET"
         __aLstFrmNCM := GetNCMLPCO()
         xRet := .T.
      elseif cCmd == "GET"
         xRet := aClone(__aLstFrmNCM)
      elseif cCmd == "CLEAR"
         xRet := aSize(__aLstFrmNCM,0)
      EndIf
   ElseIf cVar == '__oLstQtdInf'
      If cCmd == 'SET'
         BkpQtdSWV(cKey,xValue)
      ElseIf cCmd == "GET"
         xRet := BkpQtdSWV(cKey)
      ElseIf cCmd == 'CLEAR'
         __oLstQtdInf := Nil
      EndIf
   elseif cVar == '_nSeqDUIMP'
      if cCmd == 'SET'
         _nSeqDUIMP := xValue
      elseif cCmd == "GET"
         xRet := _nSeqDUIMP
      endif
   EndIf

Return xRet

/*
Função     : GetNCMLPCO
Objetivo   : Carrega uma única vez as exigências de formulários das n.c.m's de todos os itens de
             invoice do processo.
Retorno    : Array
Autor      : Nilson Cesar
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GetNCMLPCO()
   Local cQryNCMPRD := ""
   Local aFrmNcmPrd := {}
   local oQuery     := nil

   cQryNCMPRD += " SELECT EKM1.EKM_NCM,EKM1.EKM_OBRIGA,EKM1.EKN_COD_I,EKM1.EKN_OBRIGA, EKM1.EKM_ORGANU, EKM1.EKM_FRMLPC "
   cQryNCMPRD += " FROM (SELECT EKM.EKM_ORGANU,EKM.EKM_FRMLPC,EKM.EKM_NCM,EKM.EKM_OBRIGA,EKN.EKN_COD_I,EKN.EKN_OBRIGA "
   cQryNCMPRD +=      " FROM " + RetSQLName("EKM") + " EKM LEFT JOIN " + RetSQLName("EKN") + " EKN "
   cQryNCMPRD +=         " ON EKM.D_E_L_E_T_ = ' ' "
   cQryNCMPRD +=         " AND EKN.D_E_L_E_T_ = ' ' "
   cQryNCMPRD +=         " AND EKM.EKM_FILIAL =  EKN.EKN_FILIAL "
   cQryNCMPRD +=         " AND EKM.EKM_ORGANU =  EKN.EKN_ORGANU "
   cQryNCMPRD +=         " AND EKM.EKM_FRMLPC =  EKN.EKN_FRMLPC ) EKM1 "
   cQryNCMPRD += " WHERE EKM1.EKM_NCM IN ( SELECT W8_TEC FROM " + RetSQLName("SW8") + " WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = ?  AND W8_HAWB = ? GROUP BY W8_TEC ) "
   cQryNCMPRD += " AND "+ IF(Upper(TCGetDb()) == "ORACLE","LPAD(EKM1.EKM_FRMLPC,1)","LEFT(EKM1.EKM_FRMLPC,1)") +" = ? "
   cQryNCMPRD += " ORDER BY EKM1.EKM_NCM "

   // cQryNCMPRD:= ChangeQuery(cQryNCMPRD)
   // EasyQry(cQryNCMPRD, "WKFRMEXIG")

   oQuery := FWPreparedStatement():New(cQryNCMPRD)
   oQuery:SetString( 1, xFilial("SW8") ) // W8_FILIAL
   oQuery:SetString( 2, SW6->W6_HAWB ) // W8_HAWB
   oQuery:SetString( 3, 'I' ) // EKM_FRMLPC

   cQryNCMPRD := oQuery:GetFixQuery()
   FwFreeObj(oQuery)

   MPSysOpenQuery(cQryNCMPRD, "WKFRMEXIG")

   WKFRMEXIG->(DbGoTop())

   Do While WKFRMEXIG->(!Eof())
      If ( nPosNcm := aScan(aFrmNcmPrd,{|x| x[1] == WKFRMEXIG->EKM_NCM }) ) == 0                                                                       // Adiciona tudo para a nova N.c.m
         aAdd( aFrmNcmPrd , { WKFRMEXIG->EKM_NCM , { { WKFRMEXIG->EKM_ORGANU, WKFRMEXIG->EKM_FRMLPC,WKFRMEXIG->EKM_OBRIGA, {} } }   }   )
         If !Empty(WKFRMEXIG->EKN_COD_I)
            aAdd( aFrmNcmPrd[Len(aFrmNcmPrd)][2][1][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
         EndIf
      else                                                                                                                                             // Adiciona o orgão/formulário para a n.c.m existente
         If ( nPosForm := aScan( aFrmNcmPrd[nPosNCM][2] , {|y| y[1] == WKFRMEXIG->EKM_ORGANU .And. y[2] == WKFRMEXIG->EKM_FRMLPC  }  ) ) == 0
            aAdd( aFrmNcmPrd[nPosNcm][2] , { WKFRMEXIG->EKM_ORGANU, WKFRMEXIG->EKM_FRMLPC,WKFRMEXIG->EKM_OBRIGA, {} }   )
            If !Empty(WKFRMEXIG->EKN_COD_I)                                                                                                          // Adiciona o item excessão para o novo formulário
               aAdd( aFrmNcmPrd[nPosNcm][2][Len(aFrmNcmPrd[nPosNcm][2])][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
            EndIf
         else                                                                                                                                         // Adiciona o item excessão para o formulário já existente
            If !Empty(WKFRMEXIG->EKN_COD_I)
               aAdd( aFrmNcmPrd[nPosNcm][2][nPosForm][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
            EndIf
         EndIf
      EndIf
      WKFRMEXIG->(DbSkip())
   EndDo

   WKFRMEXIG->(DbCloseArea())


Return aFrmNcmPrd

/*
Função     : LP500FilF3
Objetivo   : Funcao para Filtrar os registros da consulta padrão EKO
Retorno    : .T. OU .F.
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500FilF3()
   Local oMdl := FWModelActive()
   Local oModelEKQ := oMdl:GetModel("EKQDETAIL")
   Local lRet := .T.

   If ValType(oModelEKQ) == "O"
      lRet := !Empty(EKO->EKO_LPCO) .And. EKO->EKO_ORGANU == oModelEKQ:GetValue("EKQ_ORGANU") .And. EKO->EKO_FRMLPC == oModelEKQ:GetValue("EKQ_FRMLPC")
   EndIf

Return lRet


Function LP500PVldModel(oMdl)
   Local oModelSW9,oModelSWV
   Local lRet := .t.
   Local nSW9,nI
   Local cMsg := ""
   Local aSaveLines := FWSaveRows()
   Local nLenSW9
   Local aData, aSeq:={}, nData
   Local nField
   Local lIntegrado := SW6->W6_FORMREG == DUIMP_INTEGRADA
   Local lSeqValida :=.T.

   If ValType(oMdl) == 'O'
      oModelSW9     := oMdl:GetModel("SW9DETAIL")
      oModelSWV     := oMdl:GetModel("SWVDETAIL")

      //Valida se tem catálogo de produtos inválido em algum item
      LP500VldCP(oMdl, oModelSWV)

      nField := oModelSWV:getIdField("WV_SEQDUIM")
      nLenSW9 := oModelSW9:Length()     
      For nSW9:=1 to nLenSW9
         oModelSW9:goline(nSW9)
         if !oModelSW9:isDeleted()
            if oModelSWV:SeekLine({{"WV_SEQDUIM"," "}}, .F., .F. ) .OR. oModelSWV:SeekLine({{"WV_SEQDUIM",""}}, .F., .F. ) //se encontrar alguma linha com o campo seqduimp vazio não é para validar a sequência
               if !lIntegrado
                  Return .T. //Se tem sequência em branco e não é integrado não precisa verificar mais nada
               else
                  lSeqValida := .F.
                  exit
               EndIf
            EndIf
         
            aDataModel:= AClone(oModelSW9:aDataModel[nSW9][MODEL_GRID_CHILDREN])
            nPosSubModel := AScan(aDataModel, {|x| x[MODEL_GRID_CHILDREN_ID] == "SWVDETAIL"})
            If nPosSubModel > 0
               aData := AClone(aDataModel[nPosSubModel][MODEL_GRID_CHILDREN_DATA])
               For nData:= 1 to Len(aData)
                  if !aData[nData][MODEL_GRID_DELETE] // desconsidera as linhas deletadas
                     AADD(aSeq,aData[nData][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nField])                  
                  endif
               Next      
            EndIf
         endif
      Next
 
      If (lIntegrado .and. lSeqValida) .or. !lIntegrado
         For nI:=1 to len(aSeq)
            nPos := aScan(aSeq,Strzero(ni,AVSX3("WV_SEQDUIM",AV_TAMANHO)))
            If nPos == 0 
               cMsg:= cMsg + StrTran(STR0050,"####",Strzero(nI,AVSX3("WV_SEQDUIM",AV_TAMANHO))) + ENTER //Sequência #### não existe"
               If !lIntegrado
                  lRet:=.f.
               else
                  lSeqValida := .F.
                  exit
               EndIF
            EndIf   
         Next   
      EndIf   
      If lIntegrado .And. !lSeqValida .and. !getForceAtu()
         DelSeqDuimp(.F.)
         GerSeqDuimp(.F.)
      EndIf   
      if !Empty(cMsg) .And. !lIntegrado
         EasyHelp(cMsg,STR0048,STR0051) //"Deixe a sequência DUIMP sem intervalos ou valores repetidos, exemplo (0001,0002,0003...)
      EndIf
   EndIf   
   FWRestRows(aSaveLines)
return lRet       

/*
Função     : LP500CNGAT
Objetivo   : Retornar se o gatilho será executado.
Retorno    : Lógico - Define se o gatilho será disparado.
Autor      : Nilson César
Data/Hora  : Dezembro/2021
Obs.       :
*/
Function LP500CNGAT(cCampo)
   Local oMdl := FWModelActive()
   Local lRet := .F.

   default cCampo := ""

   Begin Sequence

      if !empty(cCampo) .and. (cCampo == 'EIJ_FILIAL' .or. cCampo == 'EIJ_ALADDU' .or. cCampo == 'EIJ_ALEADU' .or. cCampo == 'EIJ_BAE_AD' .or. cCampo == 'EIJ_TPADUM')
         lRet := !FWIsInCallStack("LP500VINC") .and. !FWIsInCallStack("EICLP501")
         // condição que estava no SX7 do campo EIJ_ALADDU
         if( lRet .and. cCampo == 'EIJ_ALADDU', lRet := !empty(M->EIJ_BAD_AD), nil )
         // condição que estava no SX7 do campo EIJ_ALEADU
         if( lRet .and. cCampo == 'EIJ_ALEADU', lRet := !empty(M->EIJ_BAE_AD), nil )
         // condição que estava no SX7 do campo EIJ_BAE_AD
         if( lRet .and. cCampo == 'EIJ_BAE_AD', lRet := !empty(M->EIJ_ALEADU), nil )
         break
      endif

      //Não executar para processos que não forem DUIMP
      If SW6->W6_TIPOREG <> "2" .or. ( isMemVar("M->W6_TIPOREG") .and. M->W6_TIPOREG <> "2" )
         Break
      EndIf

      Do Case
         Case cCampo == 'EIN_VLMLE'
            lRet :=  !Empty(oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_FOBMOE"))
      EndCase

   End Sequence

Return lRet

/*
Função     : LP500Gatil
Objetivo   : Funcao para utilização de gatilhos
Retorno    : conteúdo a ser gatilhado
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500Gatil(cCampo, lVeioDelec, cAction, cTipo, cContDom)
   Local oMdl          := FWModelActive()
   Local oView         := FWViewActive()
   Local cRet          := ""
   Local nQtdAntSWV    := nQtdInf := 0
   Local aLoadCpos     := {}
   Local nLineSWV      := 0
   Local nLine         := 0
   Local nQtdPai       := 0
   Local nQtdFilha     := 0
   Local i
   Local oStrGrdSWV, aCposSWV, aPosCposKey, cSeqAtu
   Local aPKeyWV
   Local aLinGDEKQ, aLinEIJ
   Local aSeek          := {}
   local nAtuSWV        := 0
   local lAtuTribut     := .F.
   local oModelSW9      := nil
   local aSaveLines     := {}
   local lLoadEKR       := .F.
   local lLoadNCM       := .F.
   local aDados         := {}
   local xDado          := nil
   local oModelTrb      := nil
   local oModelII       := nil
   local oModelIPI      := nil
   local oModelPC       := nil
   local oModelICMS     := nil
   local oModGrpTrb     := nil
   local lTribDUIMP     := avFlags("TRIBUTACAO_DUIMP")
   local oModelPIS      := nil
   local oModelCOF      := nil
   local oModelADU      := nil
   local cRegime        := ""
   local cTpAliq        := ""
   local nDado          := 0
   local nPosFl         := 0
   local oEKWRegTri     := jSonObject():New()
   local oModelSWVTrib  := nil
   local oDadosItem     := nil
   local oDrawback      := nil
   local nOldPesoL
   local nNewPesoL
   local nOldValue
   local nNewValue
   local oMdlEKXCBS     := nil
   local oMdlEKXIBS     := nil
   local nInvTot        := 0
   local nInv           := 0
   local nPosJson       := 0
   local lFundLegal     := AvFlags("FUNDAMENTO_LEGAL_ITEM")
   local lRefTrib       := AvFlags("REFORMA_TRIBUTARIA")
   local aLinEINA       := {}
   local aLinEIND       := {}
   local aLinEIK        := {}
   local aLinEJ9        := {}
   local aLinEKWII      := {}
   local aLinEKWIPI     := {}
   local aLinEKWPIS     := {}
   local aLinEKWCOF     := {}
   local aLinEKWANT     := {}
   local aLinEKXCBS     := {}
   local aLinEKXIBS     := {}
   local oModelSWV := nil
   local oModelEKQ := nil
   local oModelEIJ := nil
   local oModelEINA:= nil
   local oModelEIND:= nil
   local oModeloEIN:= nil
   local oModelEIK := nil
   local oModelEJ9 := nil
   local oModEKWII := nil
   local oModEKWIPI := nil
   local oModEKWPIS := nil
   local oModEKWCOF := nil
   local oModEKWANT := nil
   local oModEKXCBS := nil
   local oModEKXIBS := nil
   local cLPCO      := ""
   local cLPCOVer   := ""
   local nPosSeq    := 0
   local nPosLPCO   := 0
   local nPosLPCOVer:= 0
   local cIdCatProd := ""
   local cVerCatPrd := ""
   local nPosCatPrd := 0
   local nPosCatVer := 0
   local cCnpjRaiz  := ""
   Local lAplicaII  := .T.
   Local lAplicaIPI := .T.
   Local lAplicaPIS := .T.
   Local lAplicaCOF := .T.
   Local lAplicaADU := .T.
   Local lAplicaICM := .T.
   Local lAplicaCBS := .T.
   Local lAplicaIBS := .T.

   Default lVeioDelec  := .F.
   Default cAction     := ""
   default cTipo       := "1" // 1 - acrescimos ou 2 - decrescimos
   default cContDom    := ""

   Private lDelAllLine := .F.
   Private oQuebraLn      := nil
   // OSSME-6929 incluído este controle pois quando alterado a quantidade do lote pela L.I. dava erro de gatilho
   If oMdl != nil
      
      If ValType(oMdl:GetModel("EKQDETAIL")) == "O"

         oModelSW9 := oMdl:GetModel("SW9DETAIL")
         oModelSWV := oMdl:GetModel("SWVDETAIL")
         oModelEKQ := oMdl:GetModel("EKQDETAIL")
         oModelEIJ := oMdl:GetModel("EIJMASTER")
         oModelEINA:= oMdl:GetModel("EINADETAIL")
         oModelEIND:= oMdl:GetModel("EINDDETAIL")
         oModelEIK := oMdl:GetModel("EIKDETAIL")
         oModelEJ9 := oMdl:GetModel("EJ9DETAIL")
         oModelSWVTrib:= oMdl:GETMODEL("SWVDETAIL_TRIBUTACAO")
         oEKWRegTri['listaOpcional'] := jSonObject():New()
         oEKWRegTri['listaOpcional']['ii']         := jSonObject():New()
         oEKWRegTri['listaOpcional']['ipi']        := jSonObject():New()
         oEKWRegTri['listaOpcional']['pis']        := jSonObject():New()
         oEKWRegTri['listaOpcional']['cofins']     := jSonObject():New()
         oEKWRegTri['listaOpcional']['antidumping']:= jSonObject():New()

         If cCampo == "EKQ_VERSAO"
            cRet      := EKO->EKO_ID
            aSaveLines := FWSaveRows()
            oModelSWV:LoadValue("WV_LPCOPND",EvalPdLPCO(oMdl))
            FWRestRows(aSaveLines)

         ElseIf cCampo == "EKQ_LPCO"
            cRet := ""
            EKO->(dbSetOrder(3)) //EKO_FILIAL+EKO_ORGANU+EKO_FRMLPC+EKO_LPCO+EKO_VERSAO
            If !Empty(M->EKQ_LPCO) .And. EKO->(dbSeek(xFilial("EKO") + oModelEKQ:GetValue("EKQ_ORGANU") + oModelEKQ:GetValue("EKQ_FRMLPC") + M->EKQ_LPCO))
               cRet := EKO->EKO_VERSAO
               //oModelEKQ:LoadValue("EKQ_VERSAO", EKO->EKO_VERSAO)
               oModelEKQ:LoadValue("EKQ_IDLPCO", EKO->EKO_ID)
               atuStatPOUI("lpco", oModelSWV:GetValue("WV_ID"), .T., oModelEKQ, oModelSWV)
            EndIf

         ElseIf cCampo == "WV_QTDE" .and. !getForceAtu()
            oQuebraLn := JsonObject():New()
            nQtdInf   := oModelSWV:GetValue("WV_QTDE")
            nLineSWV  := oModelSWV:GetLine()
            oQuebraLn['id_atual']      := oModelSWV:getValue("WV_ID")
            oQuebraLn['id_atual_qtde'] := nQtdInf
            oQuebraLn['hawb'] := oModelSWV:getValue("WV_HAWB")
            oQuebraLn['invoice'] := oModelSWV:getValue("WV_INVOICE")
            oQuebraLn['po_num'] := oModelSWV:getValue("WV_PO_NUM")
            oQuebraLn['posicao'] := oModelSWV:getValue("WV_POSICAO")
            oQuebraLn['produto'] := oModelSWV:getValue("WV_COD_I")

            If !oModelSWV:IsDeleted() .And. !lVeioDelec

               hashItemWV :=  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
               nQtdAntSWV :=  ManLstFrm(oMdl,'__oLstQtdInf', "GET" , hashItemWV )
               cSeqAtu    :=  oModelSWV:GetValue("WV_SEQUENC")

               If nQtdInf > 0 .And. nQtdInf <> nQtdAntSWV
                  oDadosItem := jSonObject():New()
                  oStrGrdSWV  := oModelSWV:getStruct()
                  aCposSWV    := oStrGrdSWV:GetFields()
                  For i := 1 to Len(aCposSWV)
                     If aCposSWV [i][3] $ 'WV_FILIAL|WV_SEQUENC|WV_QTDE|WV_SEQDUIM|WV_ID|WV_NCM'
                        If aCposSWV [i][3] == 'WV_FILIAL'
                           aAdd( aLoadCpos , {"WV_FILIAL" ,xFilial("SWV")})
                        ElseIf aCposSWV [i][3] == 'WV_SEQUENC'
                           aAdd( aLoadCpos , {"WV_SEQUENC",GetNextSeq(oModelSWV)/*SomaIt(oModelSWV:GetValue("WV_SEQUENC"))*/ }) // Adiciona nova sequência
                           oQuebraLn['seq_novo'] := aLoadCpos[Len(aLoadCpos)][2]
                           oDadosItem[aCposSWV [i][3]] := oQuebraLn['seq_novo']
                        ElseIf aCposSWV [i][3] == 'WV_QTDE'
                           aAdd( aLoadCpos , {"WV_QTDE"   ,nQtdAntSWV - nQtdInf                    }) // Adiciona a quantidade atualizada
                           oQuebraLn['id_novo_qtde'] := aLoadCpos[Len(aLoadCpos)][2]
                           oDadosItem[aCposSWV [i][3]] := oQuebraLn['id_novo_qtde']
                        ElseIf aCposSWV [i][3] == 'WV_SEQDUIM'
                           aAdd( aLoadCpos , {"WV_SEQDUIM"   ,""})
                        ElseIf aCposSWV [i][3] == 'WV_NCM'
                           aAdd( aLoadCpos , {"WV_NCM"   ,oModelSWV:GetValue("WV_NCM")})
                           oQuebraLn['ncm'] := oModelSWV:GetValue("WV_NCM")
                           oDadosItem[aCposSWV [i][3]] := allTrim(transform(oQuebraLn['ncm'], AvSx3("YD_TEC", AV_PICTURE))) 
                        EndIf
                     Else
                        aAdd( aLoadCpos , {aCposSWV[i][3]   ,oModelSWV:GetValue(aCposSWV[i][3])           })
                     EndIf
                  Next i

                  if oJsonPOUI:hasProperty('listaItensSWV') .and. oJsonPOUI['listaItensSWV']:hasProperty('listaItensSWV') .and. oJsonPOUI['listaItensSWV']['listaItensSWV']:hasProperty('items')
                     nPosJson := aScan( oJsonPOUI['listaItensSWV']['listaItensSWV']['items'], {|x| x['WV_ID'] == oModelSWV:GetValue("WV_ID")} )
                     if nPosJson > 0
                        oJsonPOUI['listaItensSWV']['listaItensSWV']['items'][nPosJson]['WV_QTDE'] := nQtdInf
                     endif
                  endif

                  //BACKUP DA EKQ, EIJ, EKN, EJ9
                  aLinGDEKQ := BkpLinesGD(oModelEKQ)
                  oModelEIJ:loadValue("EIJ_QTDECO", nQtdInf)
                  oModelEIJ:loadValue( "EIJ_QT_EST", AVTransUnid(oModelEIJ:getValue("EIJ_UNIDCO"), oModelEIJ:getValue("EIJ_UNDEST"), oModelSWV:getValue("WV_COD_I"), nQtdInf) )
                  
                  nOldPesoL:= oModelEIJ:getValue("EIJ_PESOL")
                  nNewPesoL:= DI500Trans( (nOldPesoL/nQtdAntSWV) * nQtdInf, AvSX3("EIJ_PESOL", AV_DECIMAL) )
                  oModelEIJ:loadValue("EIJ_PESOL", nNewPesoL)

                  nOldValue:= oModelEIJ:getValue("EIJ_VL_FIN")
                  nNewValue := DI500Trans( (nOldValue/nQtdAntSWV) * nQtdInf)
                  oModelEIJ:loadValue("EIJ_VL_FIN", nNewValue)

                  aLinEIJ   := aClone(oModelEIJ:ADATAMODEL)[1] //pega os dados do registro posicionado da eij

                  aLinEINA  := BkpLinesGD(oModelEINA)
                  aLinEIND  := BkpLinesGD(oModelEIND)
                  aLinEIK   := BkpLinesGD(oModelEIK)
                  aLinEJ9   := BkpLinesGD(oModelEJ9)
                  if lFundLegal
                     oModEKWII := oMdl:getModel("EKWGRID_II")
                     oModEKWIPI := oMdl:getModel("EKWGRID_IPI")
                     oModEKWPIS := oMdl:getModel("EKWGRID_PIS")
                     oModEKWCOF := oMdl:getModel("EKWGRID_COFINS")
                     oModEKWANT := oMdl:getModel("EKWGRID_ANTIDUMPING")
                     aLinEKWII  := BkpLinesGD(oModEKWII)
                     aLinEKWIPI := BkpLinesGD(oModEKWIPI)
                     aLinEKWPIS := BkpLinesGD(oModEKWPIS)
                     aLinEKWCOF := BkpLinesGD(oModEKWCOF)
                     aLinEKWANT := BkpLinesGD(oModEKWANT)
                  endif

                  If lRefTrib
                     oModEKXCBS := oMdl:getModel("EKXMASTER")
                     oModEKXIBS := oMdl:getModel("EKXIBS")
                     aLinEKXCBS := aClone(oModEKXCBS:ADATAMODEL)[1]
                     aLinEKXIBS := aClone(oModEKXIBS:ADATAMODEL)[1]
                  EndIf

                  //Criar nova linha no SWV
                  nAtuSWV := 0
                  GridAddLn(oModelSWV,aLoadCpos,{"WV_LOTE", "WV_DT_VALI", "WV_DFABRI", "WV_OBS"},,@nAtuSWV, {"WV_ID"})

                  oQuebraLn['id_novo'] := oModelSWV:getValue('WV_ID')
                  oDadosItem['WV_ID'] := oQuebraLn['id_novo']
                  LP500SWVLoad(oModelSWV, .F., .F.)

                  //EKQ - LPCO's
                  cLPCO := ""
                  cLPCOVer := ""
                  nPosSeq := aScan(aLinGDEKQ[1],{|x|x[1] == "EKQ_SEQUEN" })
                  nPosLPCO := aScan(aLinGDEKQ[1],{|x|x[1] == "EKQ_LPCO" })
                  nPosLPCOVer:= aScan(aLinGDEKQ[1],{|x|x[1] == "EKQ_VERSAO" })

                  For i := 1 To Len(aLinGDEKQ)
                     cLPCO := aLinGDEKQ[i][nPosLPCO][2] 
                     cLPCOVer := aLinGDEKQ[i][nPosLPCOVer][2] 
                     aLinGDEKQ[i][nPosSeq][2] := oModelSWV:GetValue("WV_SEQUENC")
                     GridAddLn(oModelEKQ,aLinGDEKQ[i],{"EKQ_LPCO","EKQ_VERSAO"}, i <> 1)
                     //EKQLoad(oModelEKQ)
                     if !empty(cLPCO)
                        oModelEKQ:loadValue("EKQ_LPCO", "")
                        oModelEKQ:loadValue("EKQ_VERSAO", "")
                        oModelEKQ:loadValue("EKQ_VERSAO", cLPCOVer)
                        oModelEKQ:SetValue("EKQ_LPCO", cLPCO)
                     endif
                     
                  Next i
                  oModelEKQ:GoLine(1)

                  //Atualiza a linha em branco da EIJ
                  nPosCatPrd := aScan( aLinEIJ, {|x| x[1] == "EIJ_IDPTCP" } )
                  nPosCatVer := aScan( aLinEIJ, {|x| x[1] == "EIJ_VRSACP" } )
                  cIdCatProd := aLinEIJ[nPosCatPrd][2]
                  cVerCatPrd := aLinEIJ[nPosCatVer][2]

                  oModelEIJ:ADATAMODEL[1] := aClone(aLinEIJ)
                  oModelEIJ:loadValue("EIJ_IDWV",oModelSWV:GetValue("WV_ID"))
                  EIJLoad(oModelEIJ)

                  if !empty(cIdCatProd)
                     oModelEIJ:loadValue("EIJ_IDPTCP", "")
                     oModelEIJ:loadValue("EIJ_VRSACP", "")
                  endif

                  oModelEIJ:loadValue("EIJ_QTDECO", nQtdAntSWV - nQtdInf)
                  oModelEIJ:loadValue("EIJ_QT_EST", AVTransUnid(oModelEIJ:getValue("EIJ_UNIDCO"), oModelEIJ:getValue("EIJ_UNDEST"), oModelSWV:getValue("WV_COD_I"), nQtdAntSWV - nQtdInf) )
                  
                  nNewPesoL:= DI500Trans( (nOldPesoL/nQtdAntSWV) * (nQtdAntSWV - nQtdInf), AvSX3("EIJ_PESOL", AV_DECIMAL) )
                  oModelEIJ:loadValue("EIJ_PESOL", nNewPesoL)

                  nNewValue := DI500Trans( (nOldValue/nQtdAntSWV) * (nQtdAntSWV - nQtdInf))
                  oModelEIJ:loadValue("EIJ_VL_FIN", nNewValue)
                  
                  if !empty(cIdCatProd)
                     oModelEIJ:LoadValue("EIJ_VRSACP", cVerCatPrd)
                     oModelEIJ:SetValue("EIJ_IDPTCP", cIdCatProd)
                  endif

                  //Atualiza EINA (acréscimos)
                  For i := 1 To Len(aLinEINA)
                     aLinEINA[i][aScan(aLinEINA[i],{|x|x[1] == "EIN_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEINA,aLinEINA[i],{}, i <> 1)
                  Next i

                  //Atualiza EIND (deduções)
                  For i := 1 To Len(aLinEIND)
                     aLinEIND[i][aScan(aLinEIND[i],{|x|x[1] == "EIN_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEIND,aLinEIND[i],{}, i <> 1)
                  Next i

                  //Atualiza EIK (documentos vinculados)
                  For i := 1 To Len(aLinEIK)
                     aLinEIK[i][aScan(aLinEIK[i],{|x|x[1] == "EIK_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEIK,aLinEIK[i],{}, i <> 1)
                  Next i

                  //Atualiza EJ9 (documentos mercosul)
                  For i := 1 To Len(aLinEJ9)
                     aLinEJ9[i][aScan(aLinEJ9[i],{|x|x[1] == "EJ9_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEJ9,aLinEJ9[i],{}, i <> 1)
                  Next i

                  //Atualiza EKW (Fundamento legal)
                  if lFundLegal
                     for i := 1 to len(aLinEKWII)
                        aLinEKWII[i][aScan(aLinEKWII[i],{|x|x[1] == "EKW_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                        GridAddLn(oModEKWII,aLinEKWII[i],{}, i <> 1)
                     next

                     for i := 1 to len(aLinEKWIPI)
                        aLinEKWIPI[i][aScan(aLinEKWIPI[i],{|x|x[1] == "EKW_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                        GridAddLn(oModEKWIPI,aLinEKWIPI[i],{}, i <> 1)
                     next

                     for i := 1 to len(aLinEKWPIS)
                        aLinEKWPIS[i][aScan(aLinEKWPIS[i],{|x|x[1] == "EKW_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                        GridAddLn(oModEKWPIS,aLinEKWPIS[i],{}, i <> 1)
                     next

                     for i := 1 to len(aLinEKWCOF)
                        aLinEKWCOF[i][aScan(aLinEKWCOF[i],{|x|x[1] == "EKW_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                        GridAddLn(oModEKWCOF,aLinEKWCOF[i],{}, i <> 1)
                     next

                     for i := 1 to len(aLinEKWANT)
                        aLinEKWANT[i][aScan(aLinEKWANT[i],{|x|x[1] == "EKW_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                        GridAddLn(oModEKWANT,aLinEKWANT[i],{}, i <> 1)
                     next
                  endif

                  If lRefTrib
                     oModEKXCBS:ADATAMODEL[1] := aClone(aLinEKXCBS)
                     oModEKXIBS:ADATAMODEL[1] := aClone(aLinEKXIBS)
                     oModEKXCBS:loadValue("EKX_IDWV",oModelSWV:GetValue("WV_ID"))
                     oModEKXIBS:loadValue("EKX_IDWV",oModelSWV:GetValue("WV_ID"))
                  EndIf

                  aPosCposKey := { ascan(aLoadCpos,{|x|x[1]=="WV_HAWB"}) , ascan(aLoadCpos,{|x|x[1]=="WV_INVOICE"}) , ascan(aLoadCpos,{|x|x[1]=="WV_PO_NUM"}) , ascan(aLoadCpos,{|x|x[1]=="WV_POSICAO"}) , ascan(aLoadCpos,{|x|x[1]=="WV_SEQUENC"}) , ascan(aLoadCpos,{|x|x[1]=="WV_QTDE"}) }
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', aLoadCpos[aPosCposKey[1]][2] + aLoadCpos[aPosCposKey[2]][2] + aLoadCpos[aPosCposKey[3]][2] + aLoadCpos[aPosCposKey[4]][2] + cSeqAtu                      , nQtdInf                      ) //Grava na variável de backup o último valor digitado para a linha
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', aLoadCpos[aPosCposKey[1]][2] + aLoadCpos[aPosCposKey[2]][2] + aLoadCpos[aPosCposKey[3]][2] + aLoadCpos[aPosCposKey[4]][2] + aLoadCpos[aPosCposKey[5]][2] , aLoadCpos[aPosCposKey[6]][2] ) //Grava na variável de backup o valor gerado para a nova linha
                  aSize(aLoadCpos,0)
                  aLoadCpos := Nil
                  lAtuTribut := .T.
                  oDadosItem['WV_INVOICE'] := oModelSWV:GetValue("WV_INVOICE")
                  oDadosItem['WV_PO_NUM'] := oModelSWV:GetValue("WV_PO_NUM")
                  oDadosItem['WV_COD_I'] := oModelSWV:GetValue("WV_COD_I")
                  oDadosItem['WV_POSICAO'] := oModelSWV:GetValue("WV_POSICAO")
                  oDadosItem['WV_DESC_DI'] := oModelSWV:GetValue("WV_DESC_DI")
                  oQuebraLn['operacao'] := "INSERT"

                  if oJsonPOUI:hasProperty('listaItensSWV') .and. oJsonPOUI['listaItensSWV']:hasProperty('listaItensSWV') .and. oJsonPOUI['listaItensSWV']['listaItensSWV']:hasProperty('items')
                     aAdd(oJsonPOUI['listaItensSWV']['listaItensSWV']['items'], oDadosItem)
                  endif

                  If canUseApp()
                  	oChannel:AdvPLToJS("AlteraQuantidadeSWV", oQuebraLn:toJson())
                  endif
               EndIf

            Elseif cAction == "DELETE" .or. cAction == "UNDELETE"

               nQtdFilha := oModelSWV:GetValue("WV_QTDE")
               nLine     := DevolvePai(oModelSWV:GetValue("WV_SEQUENC"), oModelSWV)
               If nLine > 0 //encontrou e posicionou na linha do pai
                  nAtuSWV := nLine
                  oModelSWV:GoLine(nLine)
                  nQtdPai := oModelSWV:GetValue("WV_QTDE")
               EndIf

               If cAction == "DELETE"
                  oModelSWV:LoadValue("WV_QTDE", nQtdPai + nQtdFilha) //restaurar qtde do pai já que linha filha foi deletada

                  oModelEIJ:loadValue("EIJ_QTDECO", nQtdPai + nQtdFilha)
                  oModelEIJ:LoadValue( "EIJ_QT_EST", AVTransUnid(oModelEIJ:getValue("EIJ_UNIDCO"), oModelEIJ:getValue("EIJ_UNDEST"), oModelSWV:getValue("WV_COD_I"), nQtdPai + nQtdFilha) )
                  
                  nNewPesoL:= DI500Trans( (oModelEIJ:getValue("EIJ_PESOL")/nQtdPai) * (nQtdPai + nQtdFilha), AvSX3("EIJ_PESOL", AV_DECIMAL) )
                  oModelEIJ:LoadValue("EIJ_PESOL", nNewPesoL)

                  nNewValue := DI500Trans( (oModelEIJ:getValue("EIJ_VL_FIN")/nQtdPai) * (nQtdPai + nQtdFilha))
                  oModelEIJ:LoadValue("EIJ_VL_FIN", nNewValue)

                  oQuebraLn['id_novo']       := oModelSWV:GetValue("WV_ID")
                  //Atualiza o hashmap com a última quantidade informada (neste caso, restaurada para a linha)
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , oModelSWV:GetValue("WV_QTDE") )
                  oModelSWV:GoLine(nLineSWV) //reposiciona na linha que foi deletada
                  lDelAllLine := .T.
                  LP500DelEKQ(oMdl, cAction) //chama função para deleção da EKQ
                  If !IsExecAuto(.T.,oView)
                     oModelEKQ:SetNoInsertLine(.T.)
                  EndIf
                  ExecDelEKW(oMdl, cAction)
                  oQuebraLn['id_novo_qtde']  := nQtdPai + nQtdFilha
                  oQuebraLn['operacao']      := "DELETE"
                  If canUseApp()
                  	oChannel:AdvPLToJS("AlteraQuantidadeSWV", oQuebraLn:toJson())
                  EndIf
               ElseIf cAction == "UNDELETE"
                  oModelSWV:LoadValue("WV_QTDE", nQtdPai - nQtdFilha) //subtrair qtde do pai já que linha filha foi 'desdeletada'

                  oModelEIJ:loadValue("EIJ_QTDECO", nQtdPai - nQtdFilha)
                  oModelEIJ:LoadValue( "EIJ_QT_EST", AVTransUnid(oModelEIJ:getValue("EIJ_UNIDCO"), oModelEIJ:getValue("EIJ_UNDEST"), oModelSWV:getValue("WV_COD_I"), nQtdPai - nQtdFilha) )
                  
                  nNewPesoL:= DI500Trans( (oModelEIJ:getValue("EIJ_PESOL")/nQtdPai) * (nQtdPai - nQtdFilha), AvSX3("EIJ_PESOL", AV_DECIMAL) )
                  oModelEIJ:LoadValue("EIJ_PESOL", nNewPesoL)

                  nNewValue := DI500Trans( (oModelEIJ:getValue("EIJ_VL_FIN")/nQtdPai) * (nQtdPai - nQtdFilha))
                  oModelEIJ:LoadValue("EIJ_VL_FIN", nNewValue)

                  oQuebraLn['id_novo']       := oModelSWV:GetValue("WV_ID")
                  //Atualiza o hashmap com a última quantidade informada (neste caso, restaurada para a linha)
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , oModelSWV:GetValue("WV_QTDE") )
                  oModelSWV:GoLine(nLineSWV) //reposiciona na linha que foi DesDeletada
                  LP500DelEKQ(oMdl, cAction) //chama função para DesDeleção da EKQ
                  If !IsExecAuto(.T.,oView)
                     oModelEKQ:SetNoInsertLine(.F.)
                  EndIf
                  ExecDelEKW(oMdl, cAction)
                  oQuebraLn['id_novo_qtde']  := nQtdPai - nQtdFilha
                  oQuebraLn['operacao']      := "UNDELETE"
                  If canUseApp()
                  	oChannel:AdvPLToJS("AlteraQuantidadeSWV", oQuebraLn:toJson())
                  EndIf
               EndIf
               lAtuTribut := cAction == "DELETE" .or. cAction == "UNDELETE"
            EndIf

            oModelSWV:GoLine(nLineSWV)
            freeObj(oQuebraLn)

            if lAtuTribut
               if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O"
                  LP500LdTrb(oMdl:GetModel("SWVDETAIL_TRIBUTACAO"), "SWVDETAIL_TRIBUTACAO", .T., nAtuSWV, if( empty(cAction), "NEWLINE", cAction))
               endif

               cRet := oModelSWV:GetValue("WV_LOTE")

               //Reordenação do Modelo para nova linha ser gerada logo abaixo da linha original após o refresh da View.
               aPKeyWV := { aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_INVOICE" }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_PO_NUM"  }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_POSICAO" }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_SEQUENC" })  }

               aSort(oModelSWV:aDATAMODEL,,, {|x,y| x[1][1][aPKeyWV[1]] + x[1][1][aPKeyWV[2]] + x[1][1][aPKeyWV[3]] + x[1][1][aPKeyWV[4]]  <  ;
                  y[1][1][aPKeyWV[1]] + y[1][1][aPKeyWV[2]] + y[1][1][aPKeyWV[3]] + y[1][1][aPKeyWV[4]]  } )

               // If !IsExecAuto(.T.,oView)
               //    oView:Refresh("VIEW_SWV")
               //    oView:Refresh("VIEW_SWV_TRIB")
               // EndIf

            endif

            oModelSWV:GoLine(nLineSWV)
            aSeek := { {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"   ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
                       {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")},{"WV_SEQUENC" , oModelSWV:GetValue("WV_SEQUENC")}}
            oModelSWV:SeekLine(aSeek, .T., .T.)
            if !IsExecAuto(.T.,oView)
               oView:Refresh()
            endif

         ElseIf cCampo == "EKQ_ORGANU"
            cRet := "" //Space( TamSx3("EKQ_FRMLPC")[1] )

         ElseIf cCampo == "EKQ_FRMLPC"
            If Empty( oModelEKQ:GetValue("EKQ_FRMLPC") )
               cRet := Space( TamSx3("EKQ_DSCFRM")[1] )
            Else
               cRet := POSICIONE("EKL",1,xFilial("EKL") +  oModelEKQ:GetValue("EKQ_ORGANU") + oModelEKQ:GetValue("EKQ_FRMLPC")   ,"EKL_DESC")
            EndIf

         ElseIf cCampo == "EIJ_FABR_LOJA"
            //Loja
            //não gatilha se o preenchimento será pela consulta padrão
            If !FwIsInCallStack("GETLKRET")
               //apaga o valor anterior para forçar a validação
               oModelEIJ:loadValue("EIJ_FABLOJ", "")
               cRet := AvGatilho(oModelEIJ:GetValue("EIJ_FABR"), "SA2")
               oModelEIJ:loadValue("EIJ_FABLOJ", cRet)

               //Se apagar a informação do fornecedor, apaga a loja, o nome, o pais e o TIN
               If Empty(cRet)
                  oModelEIJ:LoadValue("EIJ_FABRVM", cRet)
                  oModelEIJ:LoadValue("EIJ_PAISOR", cRet)
                  oModelEIJ:LoadValue("EIJ_TINFA", cRet)
               EndIf
            Else
               oModelEIJ:loadValue("EIJ_FABLOJ", "")
               oModelEIJ:LoadValue("EIJ_FABRVM", "")
               oModelEIJ:LoadValue("EIJ_PAISOR", "")
               oModelEIJ:LoadValue("EIJ_TINFA", "")
            EndIf

            if empty(cRet)
               oModelEIJ:loadValue("EIJ_VRSFAB", "")
            endif

         ElseIf cCampo == "EIJ_FABLOJ_PAISOR"
            if !empty(oModelEIJ:GetValue("EIJ_FABR")) .and. !empty(oModelEIJ:GetValue("EIJ_FABLOJ"))
               // retirado o retorno EKF_PAIS, na integração DUIMP está realizado o de/para pela função getPais
               cRet := AvKey( LP500GetInfo("SA2", 1, xFilial("SA2") + oModelEIJ:GetValue("EIJ_FABR") + oModelEIJ:GetValue("EIJ_FABLOJ"), "A2_PAIS"), "EIJ_PAISOR") // EKF->EKF_PAIS
               oModelEIJ:LoadValue("EIJ_FABRVM", AvKey( LP500GetInfo("SA2", 1, xFilial("SA2") + oModelEIJ:GetValue("EIJ_FABR") + oModelEIJ:GetValue("EIJ_FABLOJ"), "A2_NREDUZ" ), "EIJ_FABRVM"))
            endif

         ElseIf cCampo == "EIJ_FABLOJ_TINFA"
            cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
            cRet := LP500OpEst("EKJ_TIN", cCnpjRaiz, oModelEIJ:GetValue("EIJ_FABR"), oModelEIJ:GetValue("EIJ_FABLOJ"))

         // retirado o gatilho para evitar erro de mensagem: Valor não pode ser atribuido. (Nome Fabric.)
         // ElseIf cCampo == "EIJ_FABLOJ_FABRVM"
         //    if !empty(oModelEIJ:GetValue("EIJ_FABR")) .and. !empty(oModelEIJ:GetValue("EIJ_FABLOJ"))
         //       cRet := POSICIONE("SA2", 1, xFilial("SA2") + oModelEIJ:GetValue("EIJ_FABR") + oModelEIJ:GetValue("EIJ_FABLOJ"), "A2_NREDUZ" )
         //       cRet := AvKey(cRet, "EIJ_FABRVM")
         //    endif

         ElseIf cCampo == "EIJ_TINFO"
            cRet := oModelEIJ:GetValue("EIJ_VRSFOR")
            if !empty(oModelEIJ:GetValue("EIJ_TINFO")) .and. (SW6->W6_FORMREG == DUIMP_INTEGRADA .or. empty(cRet))
               cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
               cRet := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, oModelEIJ:GetValue("EIJ_FORN"), oModelEIJ:GetValue("EIJ_FORLOJ"))
            endif
            if empty(oModelEIJ:GetValue("EIJ_TINFO")) .and. SW6->W6_FORMREG == DUIMP_INTEGRADA
               cRet := space( getSX3Cache("EIJ_VRSFOR", "X3_TAMANHO") )
            endif

         ElseIf cCampo == "EIN_VLMLE"
            oModeloEIN := if( cTipo == "1", oModelEINA, oModelEIND)
            cRet := oModeloEIN:GetValue("EIN_VLMMN")
            if !empty(oModeloEIN:GetValue("EIN_FOBMOE"))
               cRet := if( alltrim(oModeloEIN:GetValue("EIN_FOBMOE")) == "R$", oModeloEIN:GetValue("EIN_VLMLE"), oModeloEIN:GetValue("EIN_VLMLE") * BuscaTaxa(oModeloEIN:GetValue("EIN_FOBMOE"),dDataBase,.T.,.F.,.T.))
            endif

         ElseIf cCampo == "WV_SEQDUIM" .or. cCampo == "WV_NCM" // .or. cCampo == "WV_LOTE" .or. cCampo == "WV_DT_VALI" .or. cCampo == "WV_DFABRI" .or. cCampo == "WV_OBS" 
            cRet := oModelSWV:GetValue(cCampo)
            If cCampo == "WV_SEQDUIM" .and. !Empty(oModelSWV:GetValue("WV_SEQDUIM"))
               cRet := StrZero(Val(oModelSWV:GetValue("WV_SEQDUIM")), AVSX3("WV_SEQDUIM",AV_TAMANHO))
               oModelSWV:LoadValue("WV_SEQDUIM", cRet)
            EndIf

            if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O"
               LP500LdTrb(oMdl:GetModel("SWVDETAIL_TRIBUTACAO"), "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", cCampo)
            endif

         ElseIf cCampo == "EIN_CODACR_CODIGO"
            cRet:= oModelEINA:getValue("EIN_CODACR")
            oModelEINA:loadValue("EIN_CODIGO", cRet)
            oModelEINA:loadValue("EIN_TIPO", "1")

         ElseIf cCampo == "EIN_CODACR_DESC"
            SJN->(DBSetOrder(1)) //JN_FILIAL+JN_CODIGO
            SJN->(DBSeek(xFilial() + oModelEINA:getValue("EIN_CODACR")))
            cRet:= SJN->JN_DESC
            oModelEINA:loadValue("EIN_DESC", cRet)

         ElseIf cCampo == "EIN_CODDED_CODIGO"
            cRet:= oModelEIND:getValue("EIN_CODDED")
            oModelEIND:loadValue("EIN_CODIGO", cRet)
            oModelEIND:loadValue("EIN_TIPO", "2")

         ElseIf cCampo == "EIN_CODDED_DESC"
            SJO->(DBSetOrder(1)) //JO_FILIAL+JO_CODIGO
            SJO->(DBSeek(xFilial() + oModelEIND:getValue("EIN_CODDED")))
            cRet:= SJO->JO_DESC
            oModelEIND:loadValue("EIN_DESC", cRet)

         elseif (cCampo == "EIJ_REGTRI" .and. (!lTribDUIMP .or. cContDom == "EIJ_REGTRI")) .or. cCampo == "EIJ_FUNREG" .or. cCampo == "EIJ_ALI_II" .or. cCampo == "EIJ_TPAII" .or. cCampo == "EIJ_ALR_II"
            cRet := getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", cCampo)
            endif

         elseif cCampo == "EIJ_REGTRI" .and. (cContDom == "EIJ_DSCRG1" .or. cContDom == "EIJ_ALR_II") .and. lTribDUIMP 
            if cContDom == "EIJ_DSCRG1"
               cRet := getDscRG("EIJ_DSCRG1", getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo)) 
               if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCRG1", cRet}})
               endif
            elseif cContDom == "EIJ_ALR_II"
               cRet := getModEIJ(oMdl, 'EIJMASTER_II'):GetValue("EIJ_ALR_II")
               if !UseAliq("II", "REDUZIDA", getModEIJ(oMdl, 'EIJMASTER_II'):GetValue("EIJ_REGTRI"),  getModEIJ(oMdl, 'EIJMASTER_II'):GetValue("EIJ_TPAII"))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALR_II", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_FUNII"
            if cContDom == "EIJ_FUNII"
               cRet := getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", cCampo)
               endif
               if !empty(cRet)
                  LoadFundLg( oMdl, cCampo, cRet)
               endif
            elseif cContDom == "EIJ_DSCFL1"
               cRet := getDscFL("EIJ_DSCFL1", getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCFL1", cRet}})
               endif
            elseif cContDom == "EIJ_REGTRI"
               cRet := getModEIJ(oMdl, 'EIJMASTER_II'):GetValue("EIJ_REGTRI")
               if !empty(getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo))
                  cRet := PadR( LP500GetInfo("EKU", 1, xFilial("EKU") + getModEIJ(oMdl, 'EIJMASTER_II'):GetValue(cCampo), "EKU_REGIME", "EKU_FILIAL + EKU_FDTLGL"), getSx3Cache( "EIJ_REGTRI", "X3_TAMANHO") )
                  if valtype(oMdl:GetModel("EIJMASTER_II")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_REGTRI", cRet}})
                  endif
               endif               
            endif

         elseif cCampo == "EIJ_FUNIPI"
            if cContDom == "EIJ_FUNIPI"
               cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", cCampo)
               endif
               if !empty(cRet)
                  LoadFundLg( oMdl, cCampo, cRet)
               endif
            elseif cContDom == "EIJ_DSCFL2"
               cRet := getDscFL("EIJ_DSCFL2", getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCFL2", cRet}})
               endif
            elseif cContDom == "EIJ_REGIPI"
               cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_REGIPI")
               if !empty(getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo))
                  cRet := PadR( LP500GetInfo("EKU", 1, xFilial("EKU") + getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo), "EKU_REGIME", "EKU_FILIAL + EKU_FDTLGL"), getSx3Cache( "EIJ_REGIPI", "X3_TAMANHO") )
                  if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_REGIPI", cRet}})
                  endif
               endif
            endif

         elseif (cCampo == "EIJ_REGIPI" .and. (!lTribDUIMP .or. cContDom == "EIJ_REGIPI")) .or. cCampo == "EIJ_ASSIPI" .or. cCampo == "EIJ_ALAIPI" .or. ;
            (cCampo == "EIJ_TPAIPI" .and. cContDom == "EIJ_TPAIPI" .and. lTribDUIMP ) .or. cCampo == "EIJ_ALRIPI" .or. cCampo == "EIJ_ALUIPI" .or. cCampo == "EIJ_QTUIPI"
            cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", cCampo)
            endif

         elseif ( cCampo == "EIJ_TPAIPI" .or. cCampo == "EIJ_REGIPI") .and. (cContDom == "EIJ_ALRIPI" .or. cContDom == "EIJ_ALUIPI" .or. cContDom == "EIJ_QTUIPI" .or. cContDom == "EIJ_ALAIPI") .and. lTribDUIMP  
            if cContDom == "EIJ_ALRIPI" 
               cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_ALRIPI")
               if !UseAliq("IPI", "REDUZIDA", getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_REGIPI"), getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_TPAIPI" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALRIPI", cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALUIPI" .or. cContDom == "EIJ_QTUIPI"
               cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue( cContDom )
               if !UseAliq("IPI", "ESPECIFICA", getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_REGIPI"), getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_TPAIPI" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER", cContDom, cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALAIPI"
               cRet := getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_ALAIPI")
               if !UseAliq("IPI", "AD VALOREM", getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_REGIPI"), getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue("EIJ_TPAIPI" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALAIPI", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_REGIPI" .and. lTribDUIMP 
            if cContDom == "EIJ_DSCRG2"
               cRet := getDscRG("EIJ_DSCRG2", getModEIJ(oMdl, 'EIJMASTER_IPI'):GetValue(cCampo))               
               if valtype(oMdl:GetModel("EIJMASTER_IPI")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCRG2", cRet}})
               endif
            endif

         elseif (cCampo == "EIJ_REG_PC" .or. cCampo == "EIJ_FUN_PC" .or. cCampo == "EIJ_ALAPIS" .or. cCampo == "EIJ_ALACOF") .and. !lTribDUIMP
            cRet := getModEIJ(oMdl, 'EIJMASTER_PISCOFINS'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_PISCOFINS")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_PISCOFINS"), "EIJMASTER_PISCOFINS", .T.,, "GATILHO", cCampo)
            endif

         elseif ((cCampo == "EIJ_TPAPIS" .and. (!lTribDUIMP .or. cContDom == "EIJ_TPAPIS")) .or. cCampo == "EIJ_ALAPIS" .or. cCampo == "EIJ_REDPIS" .or. cCampo == "EIJ_ALUPIS" .or. cCampo == "EIJ_QTUPIS" .or. cCampo == "EIJ_ALPISM") .and. lTribDUIMP
            cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", cCampo)
            endif

         elseif (cCampo == "EIJ_TPAPIS" .or. cCampo == "EIJ_REGPIS") .and. (cContDom == "EIJ_REDPIS" .or. cContDom == "EIJ_ALUPIS" .or. cContDom == "EIJ_QTUPIS" .or. cContDom == "EIJ_ALAPIS") .and. lTribDUIMP  
            if cContDom == "EIJ_REDPIS" 
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_REDPIS")
               if !UseAliq("PIS", "REDUZIDA", getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_REGPIS"), getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_TPAPIS" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_REDPIS", cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALUPIS" .or. cContDom == "EIJ_QTUPIS"
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue( cContDom )
               if !UseAliq("PIS", "ESPECIFICA", getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_REGPIS"), getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_TPAPIS" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER", cContDom, cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALAPIS"
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_ALAPIS")
               if !UseAliq("PIS", "AD VALOREM", getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_REGPIS"), getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_TPAPIS" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALAPIS", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_FUNPIS"
            if cContDom == "EIJ_FUNPIS"
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", cCampo)
               endif
               if !empty(cRet)
                  LoadFundLg( oMdl, cCampo, cRet)
               endif
            elseif cContDom == "EIJ_DSCFL3"
               cRet := getDscFL("EIJ_DSCFL3", getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCFL3", cRet}})
               endif
            elseif cContDom == "EIJ_REGPIS"
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue("EIJ_REGPIS")
               if !empty(getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo))
                  cRet := PadR( LP500GetInfo("EKU", 1, xFilial("EKU") + getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo), "EKU_REGIME", "EKU_FILIAL + EKU_FDTLGL"), getSx3Cache( "EIJ_REGPIS", "X3_TAMANHO") )
                  if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_REGPIS", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_REGPIS"
            if cContDom == "EIJ_REGPIS"
               cRet := getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", cCampo)
               endif
            elseif cContDom == "EIJ_DSCRG3"
               cRet := getDscRG("EIJ_DSCRG3", getModEIJ(oMdl, 'EIJMASTER_PIS'):GetValue(cCampo)) 
               if valtype(oMdl:GetModel("EIJMASTER_PIS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_PIS"), "EIJMASTER_PIS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCRG3", cRet}})
               endif
            endif

         elseif ((cCampo == "EIJ_TPACOF" .and. (!lTribDUIMP .or. cContDom == "EIJ_TPACOF")) .or. cCampo == "EIJ_ALACOF" .or. cCampo == "EIJ_REDCOF" .or. cCampo == "EIJ_ALUCOF" .or. cCampo == "EIJ_QTUCOF" .or. cCampo == "EIJ_ALCOFM") .and. lTribDUIMP
            cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", cCampo)
            endif

         elseif (cCampo == "EIJ_TPACOF" .or. cCampo == "EIJ_REGCOF") .and. (cContDom == "EIJ_REDCOF" .or. cContDom == "EIJ_ALUCOF" .or. cContDom == "EIJ_QTUCOF" .or. cContDom == "EIJ_ALACOF") .and. lTribDUIMP  
            if cContDom == "EIJ_REDCOF" 
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_REDCOF")
               if !UseAliq("COFINS", "REDUZIDA", getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_REGCOF"), getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_TPACOF" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_REDCOF", cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALUCOF" .or. cContDom == "EIJ_QTUCOF"
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue( cContDom )
               if !UseAliq("COFINS", "ESPECIFICA", getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_REGCOF"), getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_TPACOF" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER", cContDom, cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALACOF"
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_ALACOF")
               if !UseAliq("COFINS", "AD VALOREM", getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_REGCOF"), getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_TPACOF" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALACOF", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_FUNCOF"
            if cContDom == "EIJ_FUNCOF"
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", cCampo)
               endif
               if !empty(cRet)
                  LoadFundLg( oMdl, cCampo, cRet)
               endif
            elseif cContDom == "EIJ_DSCFL4"
               cRet := getDscFL("EIJ_DSCFL4", getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCFL4", cRet}})
               endif
            elseif cContDom == "EIJ_REGCOF"
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue("EIJ_REGCOF")
               if !empty(getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo))
                  cRet := PadR( LP500GetInfo("EKU", 1, xFilial("EKU") + getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo), "EKU_REGIME", "EKU_FILIAL + EKU_FDTLGL"), getSx3Cache( "EIJ_REGCOF", "X3_TAMANHO") )
                  if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_REGCOF", cRet}})
                  endif
               endif
            endif

         elseif cCampo == "EIJ_REGCOF" .and. (cContDom == "EIJ_REGCOF" .or. cContDom == "EIJ_DSCRG4")
            if cContDom == "EIJ_REGCOF"
               cRet := getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", cCampo)
               endif
            elseif cContDom == "EIJ_DSCRG4"
               cRet := getDscRG("EIJ_DSCRG4", getModEIJ(oMdl, 'EIJMASTER_COFINS'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_COFINS")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_COFINS"), "EIJMASTER_COFINS", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCRG4", cRet}})
               endif
            endif

         elseif cCampo == "EIJ_FUNADU"
            if cContDom == "EIJ_FUNADU"
               cRet := getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", cCampo)
               endif
               if !empty(cRet)
                  LoadFundLg( oMdl, cCampo, cRet)
               endif
            elseif cContDom == "EIJ_DSCFL5"
               cRet := getDscFL("EIJ_DSCFL5", getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue(cCampo))
               if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", , {{"EIJMASTER","EIJ_DSCFL5", cRet}})
               endif               
            endif

         elseif cCampo == "EIJ_TPADUM" .and. lTribDUIMP  
            if cContDom == "EIJ_TPADUM"
               cRet := getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue(cCampo)
               if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
                  LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", cCampo)
               endif
            elseif cContDom == "EIJ_BAE_AD" .or. cContDom == "EIJ_ALEADU"
               cRet := getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue( cContDom )
               if !UseAliq("ANTIDUMPING", "ESPECIFICA", "", getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue("EIJ_TPADUM" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", , {{"EIJMASTER", cContDom, cRet}})
                  endif
               endif
            elseif cContDom == "EIJ_ALADDU"
               cRet := getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue("EIJ_ALADDU")
               if !UseAliq("ANTIDUMPING", "AD VALOREM", "", getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue("EIJ_TPADUM" ))
                  cRet := 0
                  if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
                     LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", , {{"EIJMASTER", "EIJ_ALADDU", cRet}})
                  endif
               endif
            endif

         elseif (cCampo == "EIJ_ALADDU" .or. cCampo == "EIJ_BAE_AD" .or. cCampo == "EIJ_ALEADU") .and. lTribDUIMP
            cRet := getModEIJ(oMdl, 'EIJMASTER_ANTIDUMPING'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_ANTIDUMPING")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_ANTIDUMPING"), "EIJMASTER_ANTIDUMPING", .T.,, "GATILHO", cCampo)
            endif

         elseif cCampo == "EIJ_OPERAC"
            cRet := getModEIJ(oMdl, 'EIJMASTER_ICMS'):GetValue(cCampo)
            if valtype(oMdl:GetModel("EIJMASTER_ICMS")) == "O"
               LP500LdTrb(oMdl:GetModel("EIJMASTER_ICMS"), "EIJMASTER_ICMS", .T.,, "GATILHO", cCampo)
            endif

         elseif cCampo == "EIJ_IDPTCP_VRSFAB" 
            cRet := GetFabFor("VERSAO", oModelEIJ:GetValue("EIJ_IDPTCP") , oModelEIJ:GetValue("EIJ_VRSACP"), oMdl )

         elseif cCampo == "EIJ_FABLOJ_VRS"
            cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
            cRet := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, oModelEIJ:GetValue("EIJ_FABR"), oModelEIJ:GetValue("EIJ_FABLOJ"))

         elseif cCampo == "EIJ_IDPTCP"
            cRet := GetStatCat( oModelSWV:GetValue("WV_NCM"), oModelEIJ:GetValue("EIJ_IDPTCP"), oModelEIJ:GetValue("EIJ_VRSACP"))
            atuStatPOUI("catalogo", oModelSWV:GetValue("WV_ID"), !Empty(oModelEIJ:GetValue("EIJ_IDPTCP")), oModelEIJ, oModelSWV)

         elseif cCampo == "WV_CODREG"

            if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O" 
               oModelTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
               cRet := oModelTrb:getValue(cCampo)
               xDado := retCpoTrb(cRet, "EKR_DESCRI",,,,.T. )
               oModelTrb:loadValue("WV_DSCREG", xDado )
               LP500Aplic(cRet, avFlags("REFORMA_CCLASSTRIB"), avFlags("REGIME_TRIBUTACAO_DUIMP"), oModelSWV, @lAplicaII, @lAplicaIPI, @lAplicaPIS, @lAplicaCOF, @lAplicaADU, @lAplicaICM, @lAplicaCBS, @lAplicaIBS)
               ClsTrbPOUI(cRet, avFlags("REFORMA_CCLASSTRIB"), avFlags("REGIME_TRIBUTACAO_DUIMP"), oModelSWV)//Envia o cClass Trib do Regime para o APP
               oModelSW9 := oMdl:GetModel("SW9DETAIL")
               nInvTot := oModelSW9:length()
               for nInv := 1 to nInvTot
                  oModelSW9:goline(nInv)
                  oModelSWV := oMdl:GetModel("SWVDETAIL")
                  aSeek := {{"WV_FILIAL" , xFilial("SWV")},;
                           {"WV_HAWB"   , oModelTrb:GetValue("WV_HAWB")},;
                           {"WV_INVOICE", oModelTrb:GetValue("WV_INVOICE")},;
                           {"WV_FORN"   , oModelTrb:GetValue("WV_FORN")},;
                           {"WV_FORLOJ" , oModelTrb:GetValue("WV_FORLOJ")},;
                           {"WV_PO_NUM" , oModelTrb:GetValue("WV_PO_NUM")},;
                           {"WV_POSICAO", oModelTrb:GetValue("WV_POSICAO")},;
                           {"WV_SEQUENC", oModelTrb:GetValue("WV_SEQUENC")}}
                  if oModelSWV:SeekLine(aSeek, .F., .T.)
                     exit
                  endif
               next nInv
            else
               oModelTrb := oMdl:GetModel("SWVDETAIL")
               cRet := oModelTrb:getValue(cCampo)
            endif

            aDados := {}
            aAdd( aDados, { "SWVDETAIL", "WV_CODREG", cRet})
            aAdd( aDados, { "EIJMASTER", "EIJ_CODREG", cRet})

            lLoadEKR := !empty(cRet)
            if empty(cRet)
               lLoadNCM := if( _lEntPoint , ExecBlock("EICLP500",.F.,.F.,"WV_CODREG_VAZIO") , IsExecAuto(.T.,oView) .or. if( getLoadTrb() == "0", MsgYesNo(STR0134 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0135, STR0003), getLoadTrb() == "1" ) ) //"Deseja atualizar as alíquotas utilizando os dados cadastrados na NCM, considerando o regime tributário e tipo de alíquota informados em tela?" ### "Caso cancele, será mantido as regras de tributação atuais."
               setLoadTrb(if(lLoadNCM,"1","2")) // 1 - carregar da NCM / 2 - mantem o que esta na tela
               If lLoadNCM
                  lAplicaII := lAplicaIPI := lAplicaPIS := lAplicaCOF := lAplicaADU := lAplicaICM := lAplicaCBS := lAplicaIBS := .F.
               EndIf 
            endif

            if lLoadEKR

               xDado := retCpoTrb( cRet, "EKR_TPAPLI",,,,.T. )
               if !empty(xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_APLICM", xDado})
               endif

               xDado := retCpoTrb( cRet, "EKR_MATUSA",,,,.T. )
               if !empty(xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_MATUSA", xDado})
               endif

               // Dados II
               If lAplicaII
                  oModelII := getModEIJ(oMdl, "EIJMASTER_II")

                  xDado := retCpoTrb( cRet, "EKR_REGTRI",,,,.T. )
                  cRegime := xDado
                  oModelII:loadValue("EIJ_REGTRI", cRegime)
                  aAdd( aDados, { "EIJMASTER", "EIJ_REGTRI", cRegime})

                  if lTribDUIMP 
                     xDado := ""
                     if !empty(cRegime)
                        xDado := getDscRG("EIJ_DSCRG1", cRegime)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCRG1", "X3_TAMANHO") )
                     oModelII:loadValue("EIJ_DSCRG1", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCRG1", xDado})

                     xDado := retCpoTrb( cRet, "EKR_FUNII",,,,.T. )
                     oModelII:loadValue("EIJ_FUNII", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNII", xDado})
                     nPosFL := Len(aDados)

                     if !empty( xDado )
                        xDado := getDscFL("EIJ_DSCFL1", xDado)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCFL1", "X3_TAMANHO") )
                     oModelII:loadValue("EIJ_DSCFL1", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCFL1", xDado})

                  else
                     xDado := retCpoTrb( cRet, "EKR_FUNREG",,,,.T. )
                     oModelII:loadValue("EIJ_FUNREG", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNREG", xDado})
                  endif

                  xDado := retCpoTrb( cRet, "EKR_TPAII",,,,.T. )
                  cTpAliq := xDado
                  oModelII:loadValue("EIJ_TPAII" , cTpAliq)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPAII", cTpAliq})

                  xDado := getAliquotas("II", cRet, cRegime, cTpAliq, oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .T., .T.)
                  if len(xDado) > 0
                     oModelII:loadValue("EIJ_ALI_II", xDado[1][2])
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALI_II", xDado[1][2]})
                  endif

                  if lTribDUIMP
                     xDado := retCpoTrb( cRet, "EKR_ALR_II",,,,.T. )
                     oModelII:loadValue("EIJ_ALR_II", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALR_II", xDado})
                  endif

                  //Adiciona os dados do fundamento legal do regime tributário vinculado ao produto no grid de tributação
                  If lFundLegal// II - Imposto de Importação
                     setAtriOpc(oEKWRegTri, 'ii', oModelSWVTrib:getValue("WV_HAWB"), oModelSWVTrib:getValue("WV_ID"), oModelSWVTrib:getValue("WV_NCM"), aDados[nPosFL][3])
                  EndIf
               EndIf

               // Dados IPI
               If lAplicaIPI
                  oModelIPI := getModEIJ(oMdl, "EIJMASTER_IPI")

                  xDado := retCpoTrb( cRet, "EKR_REGIPI",,,,.T. )
                  cRegime := xDado
                  oModelIPI:loadValue("EIJ_REGIPI", cRegime)
                  aAdd( aDados, { "EIJMASTER", "EIJ_REGIPI", cRegime})

                  if lTribDUIMP 
                     xDado := ""
                     if !empty(cRegime)
                        xDado := getDscRG("EIJ_DSCRG2", cRegime)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCRG2", "X3_TAMANHO") )
                     oModelIPI:loadValue("EIJ_DSCRG2", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCRG2", xDado})

                     xDado := retCpoTrb( cRet, "EKR_FUNIPI",,,,.T. )
                     oModelIPI:loadValue("EIJ_FUNIPI", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNIPI", xDado})
                     nPosFL := Len(aDados)

                     if !empty( xDado )
                        xDado := getDscFL("EIJ_DSCFL2", xDado)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCFL2", "X3_TAMANHO") )
                     oModelIPI:loadValue("EIJ_DSCFL2", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCFL2", xDado})

                  else
                     xDado := retCpoTrb( cRet, "EKR_ASSIPI",,,,.T. )
                     oModelIPI:loadValue("EIJ_ASSIPI", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ASSIPI", xDado})
                  endif

                  xDado := retCpoTrb( cRet, "EKR_TPAIPI",,,,.T. )
                  cTpAliq := xDado
                  oModelIPI:loadValue("EIJ_TPAIPI", cTpAliq)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPAIPI", cTpAliq})

                  xDado := getAliquotas("IPI", cRet, cRegime, cTpAliq, oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .T., .T.)
                  for nDado := 1 to len(xDado)
                     oModelIPI:loadValue(xDado[nDado][1], xDado[nDado][2])
                     aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                  next

                  if lTribDUIMP
                     xDado := retCpoTrb( cRet, "EKR_ALRIPI",,,,.T. )
                     oModelIPI:loadValue("EIJ_ALRIPI", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALRIPI", xDado})

                     xDado := retCpoTrb( cRet, "EKR_ALUIPI",,,,.T. )
                     oModelIPI:loadValue("EIJ_ALUIPI", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALUIPI", xDado})
                  endif
                  
                  //Adiciona os dados do fundamento legal do regime tributário vinculado ao produto no grid de tributação
                  If lFundLegal// IPI
                     setAtriOpc(oEKWRegTri, 'ipi', oModelSWVTrib:getValue("WV_HAWB"), oModelSWVTrib:getValue("WV_ID"), oModelSWVTrib:getValue("WV_NCM"), aDados[nPosFL][3])
                  EndIf
               EndIf

               if lTribDUIMP
                  // Dados PIS
                  If lAplicaPIS
                     oModelPIS := getModEIJ(oMdl, "EIJMASTER_PIS")

                     xDado := retCpoTrb( cRet, "EKR_REGPIS",,,,.T. )
                     cRegime := xDado
                     oModelPIS:loadValue("EIJ_REGPIS", cRegime)
                     aAdd( aDados, { "EIJMASTER", "EIJ_REGPIS", cRegime})

                     xDado := ""
                     if !empty(cRegime)
                        xDado := getDscRG("EIJ_DSCRG3", cRegime)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCRG3", "X3_TAMANHO") )
                     oModelPIS:loadValue("EIJ_DSCRG3", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCRG3", xDado})

                     xDado := retCpoTrb( cRet, "EKR_FUNPIS",,,,.T. )
                     oModelPIS:loadValue("EIJ_FUNPIS", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNPIS", xDado})
                     nPosFL := Len(aDados)

                     if !empty( xDado )
                        xDado := getDscFL("EIJ_DSCFL3", xDado)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCFL3", "X3_TAMANHO") )
                     oModelPIS:loadValue("EIJ_DSCFL3", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCFL3", xDado})

                     xDado := retCpoTrb( cRet, "EKR_TPAPIS",,,,.T. )
                     cTpAliq := xDado
                     oModelPIS:loadValue("EIJ_TPAPIS", cTpAliq)
                     aAdd( aDados, { "EIJMASTER", "EIJ_TPAPIS", cTpAliq})

                     xDado := getAliquotas("PIS", cRet, cRegime, cTpAliq, oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .T., .T.)
                     for nDado := 1 to len(xDado)
                        oModelPIS:loadValue(xDado[nDado][1], xDado[nDado][2])
                        aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                     next

                     //Adiciona os dados do fundamento legal do regime tributário vinculado ao produto no grid de tributação
                     If lFundLegal// PIS
                        setAtriOpc(oEKWRegTri, 'pis', oModelSWVTrib:getValue("WV_HAWB"), oModelSWVTrib:getValue("WV_ID"), oModelSWVTrib:getValue("WV_NCM"), aDados[nPosFL][3])
                     EndIf
                  EndIf

                  // Dados COFINS
                  If lAplicaCOF
                     oModelCOF := getModEIJ(oMdl, "EIJMASTER_COFINS")

                     xDado := retCpoTrb( cRet, "EKR_REGCOF",,,,.T. )
                     cRegime := xDado
                     oModelCOF:loadValue("EIJ_REGCOF", cRegime)
                     aAdd( aDados, { "EIJMASTER", "EIJ_REGCOF", cRegime})

                     xDado := ""
                     if !empty(cRegime)
                        xDado := getDscRG("EIJ_DSCRG4", cRegime)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCRG4", "X3_TAMANHO") )
                     oModelCOF:loadValue("EIJ_DSCRG4", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCRG4", xDado})

                     xDado := retCpoTrb( cRet, "EKR_FUNCOF",,,,.T. )
                     oModelCOF:loadValue("EIJ_FUNCOF", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNCOF", xDado})
                     nPosFL := Len(aDados)

                     if !empty( xDado )
                        xDado := getDscFL("EIJ_DSCFL4", xDado)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCFL4", "X3_TAMANHO") )
                     oModelCOF:loadValue("EIJ_DSCFL4", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCFL4", xDado})

                     xDado := retCpoTrb( cRet, "EKR_TPACOF",,,,.T. )
                     cTpAliq := xDado
                     oModelCOF:loadValue("EIJ_TPACOF", cTpAliq)
                     aAdd( aDados, { "EIJMASTER", "EIJ_TPACOF", cTpAliq})

                     xDado := getAliquotas("COFINS", cRet, cRegime, cTpAliq, oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .T., .T.)
                     for nDado := 1 to len(xDado)
                        oModelCOF:loadValue(xDado[nDado][1], xDado[nDado][2])
                        aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                     next

                     //Adiciona os dados do fundamento legal do regime tributário vinculado ao produto no grid de tributação
                     If lFundLegal// COFINS
                        setAtriOpc(oEKWRegTri, 'cofins', oModelSWVTrib:getValue("WV_HAWB"), oModelSWVTrib:getValue("WV_ID"), oModelSWVTrib:getValue("WV_NCM"), aDados[nPosFL][3])
                     EndIf
                  EndIf

                  // Dados ANTIDUMPING
                  If lAplicaADU
                     oModelADU := getModEIJ(oMdl, "EIJMASTER_ANTIDUMPING")

                     xDado := retCpoTrb( cRet, "EKR_FUNADU",,,,.T. )
                     oModelADU:loadValue("EIJ_FUNADU", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_FUNADU", xDado})
                     nPosFL := Len(aDados)

                     if !empty( xDado )
                        xDado := getDscFL("EIJ_DSCFL5", xDado)
                     endif
                     xDado := PadR( xDado, getSx3Cache( "EIJ_DSCFL5", "X3_TAMANHO") )
                     oModelADU:loadValue("EIJ_DSCFL5", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_DSCFL5", xDado})

                     xDado := retCpoTrb( cRet, "EKR_TPADUM",,,,.T. )
                     cTpAliq := xDado
                     oModelADU:loadValue("EIJ_TPADUM", cTpAliq)
                     aAdd( aDados, { "EIJMASTER", "EIJ_TPADUM", cTpAliq})

                     xDado := 0
                     if UseAliq("ANTIDUMPING", "AD VALOREM", "", cTpAliq)
                        xDado := retCpoTrb( cRet, "EKR_ALADDU",,,,.T. )
                     endif
                     oModelADU:loadValue("EIJ_ALADDU", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALADDU", xDado})

                     xDado := 0
                     if UseAliq("ANTIDUMPING", "ESPECIFICA", "", cTpAliq)
                        xDado := retCpoTrb( cRet, "EKR_ALEADU",,,,.T. )
                     endif
                     oModelADU:loadValue("EIJ_ALEADU", xDado)
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALEADU", xDado})

                     //Adiciona os dados do fundamento legal do regime tributário vinculado ao produto no grid de tributação
                     If lFundLegal// ANTIDUMPING
                        setAtriOpc(oEKWRegTri, 'antidumping', oModelSWVTrib:getValue("WV_HAWB"), oModelSWVTrib:getValue("WV_ID"), oModelSWVTrib:getValue("WV_NCM"), aDados[nPosFL][3])
                     EndIf
                  EndIf
               else
                  // Dados PIS/COFINS
                  oModelPC := getModEIJ(oMdl, "EIJMASTER_PISCOFINS")

                  xDado := retCpoTrb( cRet, "EKR_REG_PC",,,,.T. )
                  oModelPC:loadValue("EIJ_REG_PC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_REG_PC", xDado})

                  xDado := retCpoTrb( cRet, "EKR_FUN_PC",,,,.T. )
                  oModelPC:loadValue("EIJ_FUN_PC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_FUN_PC", xDado})

                  xDado := retCpoTrb( cRet, "EKR_TPAPIS",,,,.T. )
                  oModelPC:loadValue("EIJ_TPAPIS", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPAPIS", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALAPIS",,,,.T. )
                  oModelPC:loadValue("EIJ_ALAPIS", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_ALAPIS", xDado})

                  xDado := retCpoTrb( cRet, "EKR_TPACOF",,,,.T. )
                  oModelPC:loadValue("EIJ_TPACOF", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPACOF", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALACOF",,,,.T. )
                  oModelPC:loadValue("EIJ_ALACOF", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_ALACOF", xDado})
               endif

               // Dados ICMS
               If lAplicaICM
                  oModelICMS := getModEIJ(oMdl, "EIJMASTER_ICMS")

                  xDado := retCpoTrb( cRet, "EKR_OPERAC",,,,.T. )
                  oModelICMS:loadValue("EIJ_OPERAC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_OPERAC", xDado})
               EndIf

               // Dados CBS
               If lAplicaCBS
                  oModEKXCBS := oMdl:getModel("EKXMASTER")

                  xDado := retCpoTrb( cRet, "EKR_ALADCB",,,,.T. )
                  oModEKXCBS:loadValue("EKX_ALADCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALADCB", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALRDCB",,,,.T. )
                  oModEKXCBS:loadValue("EKX_ALRDCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALRDCB", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALRBCB",,,,.T. )
                  oModEKXCBS:loadValue("EKX_ALRBCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALRBCB", xDado})
               EndIf

               // Dados IBS
               If lAplicaIBS
                  oModEKXIBS := oMdl:getModel("EKXIBS")

                  xDado := retCpoTrb( cRet, "EKR_ALADIB",,,,.T. )
                  oModEKXIBS:loadValue("EKX_ALADIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALADIB", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALRDIB",,,,.T. )
                  oModEKXIBS:loadValue("EKX_ALRDIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALRDIB", xDado})

                  xDado := retCpoTrb( cRet, "EKR_ALRBIB",,,,.T. )
                  oModEKXIBS:loadValue("EKX_ALRBIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALRBIB", xDado})
               EndIf
            EndIf
            
            IF lLoadNCM .Or. lLoadEKR .And. (!lAplicaII .Or. !lAplicaIPI .Or. !lAplicaPIS .Or. !lAplicaCOF .Or. !lAplicaADU .Or. !lAplicaICM .Or. !lAplicaCBS .Or. !lAplicaIBS)

               // Dados II
               If !lAplicaII
                  oModelII := getModEIJ(oMdl, "EIJMASTER_II") 

                  xDado := getAliquotas("II", "", oModelII:getValue("EIJ_REGTRI"), oModelII:getValue("EIJ_TPAII"), oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .F., .T.)
                  if len(xDado) > 0
                     oModelII:loadValue("EIJ_ALI_II", xDado[1][2])
                     aAdd( aDados, { "EIJMASTER", "EIJ_ALI_II", xDado[1][2]})
                  endif
               EndIf

               // Dados IPI
               If !lAplicaIPI
                  oModelIPI := getModEIJ(oMdl, "EIJMASTER_IPI")

                  xDado := getAliquotas("IPI", "", oModelIPI:getValue("EIJ_REGIPI"), oModelIPI:getValue("EIJ_TPAIPI"), oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .F., .T.)
                  for nDado := 1 to len(xDado)
                     oModelIPI:loadValue(xDado[nDado][1], xDado[nDado][2])
                     aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                  next
               EndIf

               if lTribDUIMP
                  // Dados PIS
                  If !lAplicaPIS
                     oModelPIS := getModEIJ(oMdl, "EIJMASTER_PIS")
                     xDado := getAliquotas("PIS", "", oModelPIS:getValue("EIJ_REGPIS"), oModelPIS:GetValue("EIJ_TPAPIS"), oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .F., .T.)
                     for nDado := 1 to len(xDado)
                        oModelPIS:loadValue(xDado[nDado][1], xDado[nDado][2])
                        aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                     next
                  EndIf

                  // Dados COFINS
                  If !lAplicaCOF
                     oModelCOF := getModEIJ(oMdl, "EIJMASTER_COFINS")
                     xDado := getAliquotas("COFINS", "", oModelCOF:getValue("EIJ_REGCOF"), oModelCOF:GetValue("EIJ_TPACOF"), oModelTrb:getValue("WV_NCM") + oModelTrb:getValue("WV_EX_NCM"), .F., .T.)
                     for nDado := 1 to len(xDado)
                        oModelCOF:loadValue(xDado[nDado][1], xDado[nDado][2])
                        aAdd( aDados, { "EIJMASTER", xDado[nDado][1], xDado[nDado][2]})
                     next
                  EndIf
               else
                  // Dados PIS/COFINS
                  oModelPC := getModEIJ(oMdl, "EIJMASTER_PISCOFINS") 

                  xDado := criavar("EIJ_REG_PC")
                  oModelPC:loadValue("EIJ_REG_PC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_REG_PC", xDado})

                  xDado := criavar("EIJ_FUN_PC")
                  oModelPC:loadValue("EIJ_FUN_PC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_FUN_PC", xDado})

                  xDado := "1"
                  oModelPC:loadValue("EIJ_TPAPIS", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPAPIS", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_PER_PIS")
                  oModelPC:loadValue("EIJ_ALAPIS", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_ALAPIS", xDado})

                  xDado := "1"
                  oModelPC:loadValue("EIJ_TPACOF", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_TPACOF", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_PER_COF")
                  oModelPC:loadValue("EIJ_ALACOF", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_ALACOF", xDado})
               endif

               // Dados ICMS
               If !lAplicaICM
                  oModelICMS := getModEIJ(oMdl, "EIJMASTER_ICMS")

                  xDado := criavar("EIJ_OPERAC")
                  oModelICMS:loadValue("EIJ_OPERAC", xDado)
                  aAdd( aDados, { "EIJMASTER", "EIJ_OPERAC", xDado})
               EndIf

               // Dados CBS
               If !lAplicaCBS
                  oModEKXCBS := oMdl:getModel("EKXMASTER")

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALADCBS")
                  oModEKXCBS:loadValue("EKX_ALADCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALADCB", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALRDCBS")
                  oModEKXCBS:loadValue("EKX_ALRDCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALRDCB", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALRBCBS")
                  oModEKXCBS:loadValue("EKX_ALRBCB", xDado)
                  aAdd( aDados, { "EKXMASTER", "EKX_ALRBCB", xDado})
               EndIf

               // Dados IBS
               If !lAplicaIBS
                  oModEKXIBS := oMdl:getModel("EKXIBS")

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALADIBS")
                  oModEKXIBS:loadValue("EKX_ALADIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALADIB", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALRDIBS")
                  oModEKXIBS:loadValue("EKX_ALRDIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALRDIB", xDado})

                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM") + oModelSWV:getValue("WV_EX_NCM") , "YD_ALRBIBS")
                  oModEKXIBS:loadValue("EKX_ALRBIB", xDado)
                  aAdd( aDados, { "EKXIBS", "EKX_ALRBIB", xDado})
               EndIf

            endif

            LP500LdTrb(oModelTrb , "EIJMASTER", .T., , "GATILHO", , aDados)

            //Carrega os dados do Regime Tributário no grid de tributação
            If lFundLegal
               IncRegTrib(oMdl, oEKWRegTri)
               FreeObj(oEKWRegTri)
            EndIf

            oModGrpTrb := oMdl:GetModel("GRPDETAIL_TRIBUTACAO")
            if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O" .and. valtype( oModGrpTrb ) == "O"

               aDados := { "GRPDETAIL_TRIBUTACAO",;
                           { { "WV_NCM"    , oModelTrb:getValue("WV_NCM")   } ,;
                              { "WV_EX_NCM" , oModelTrb:getValue("WV_EX_NCM")} ,;
                              { "WV_CODREG" , cRet                            }};
                           }

               LP500LdTrb(oModGrpTrb , "GRPDETAIL_TRIBUTACAO", .T., , "GATILHO", , aDados)

            endif
            
            if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O" 
               oModelSW9:goline(nInv)
               oModelSWV:SeekLine(aSeek, .F., .T.)
            endif

         elseif cCampo == "WV_CODREG_GRP"

            oModelTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
            oModGrpTrb := oMdl:GetModel("GRPDETAIL_TRIBUTACAO")
            if valtype(oModelTrb) == "O" .and. valtype(oModGrpTrb) == "O"

               cRet := ""
               aDados := { "SWVDETAIL_TRIBUTACAO",;
                           { { "WV_NCM"    , oModGrpTrb:getValue("WV_NCM")    } ,;
                             { "WV_EX_NCM" , oModGrpTrb:getValue("WV_EX_NCM") } ,;
                             { "WV_CODREG" , oModGrpTrb:getValue("WV_CODREG") } };
                         } 

               LP500LdTrb(oModelTrb , "GRPDETAIL_TRIBUTACAO", .T., , "GATILHO", , aDados)

            endif
         elseif cCampo == "WV_MODAL" .Or. cCampo == "WV_AC" .Or. cCampo == "WV_SEQSIS"
            If oModelSWVTrib <> nil
               oModelSWVTrib:loadValue(cCampo, oModelSWV:getValue(cCampo))
            EndIf
            If canUseApp() .And. !Empty(oModelSWV:getValue("WV_MODAL"))
               oDrawback := JsonObject():New()
               oDrawback['id']         := oModelSWV:getValue("WV_ID")
               oDrawback['modalidade'] := oModelSWV:getValue("WV_MODAL")
               oDrawback['ato']        := oModelSWV:getValue("WV_AC")
               oDrawback['seq']        := oModelSWV:getValue("WV_SEQSIS")
               oDrawback['ambiente']   := EasyGParam("MV_EIC0074",.F.,"1") == "1"

               oChannel:AdvPLToJS("setDrawback", oDrawback:ToJson())
               freeObj(oDrawback)
            EndIf
         Elseif cCampo == "EKX_ALADIB" .Or. cCampo == "EKX_ALRDIB" .Or. cCampo == "EKX_ALRBIB"
            oMdlEKXCBS := oMdl:getModel("EKXMASTER")
            oMdlEKXIBS := oMdl:getModel("EKXIBS")
            if valtype(oMdlEKXCBS) == "O" .And. valtype(oMdlEKXIBS) == "O"
               cRet := oMdlEKXIBS:GetValue(cCampo)
               oMdlEKXCBS:loadValue(cCampo, cRet)
            endif
         ElseIf cCampo == "WV_FORLOJ"
            cRet := LP500GetInfo("SA2", 1, xFilial("SA2") + oModelSWV:getValue("WV_FORN") + oModelSWV:getValue("WV_FORLOJ"), "A2_NREDUZ")
         endif
      EndIf
   elseif cCampo='WV_QTDE' .AND.  FwIsInCallStack("EICGI210")
      cRet := M->WV_LOTE //retorno necessário, pois quando alterava a quantidade pela L.I. e retornava "", apagava o campo No. Lote.
   EndIf

Return cRet

/*
Função     : PreVldLEKQ
Objetivo   : Funcao para validar ação na Linha - não permissao de exclusao de registro com
"Obrigatorio" = Sim
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function PreVldLEKQ(oGridEKQ, nLine, cAction)
   Local lRet := .T.
   Local oModel

   If cAction == "DELETE" .And. oGridEKQ:GetValue("EKQ_OBRFRM") == "1" .And. (!IsMemVar("lDelAllLine") .Or. !lDelAllLine)
      EasyHelp(STR0017, STR0003, STR0018) //"Não é possível excluir linha cujo campo 'Obrigatorio?' está preenchido como 'Sim' " #Atenção# "Avalie a necessidade de exclusão da linha"
      lRet := .F.
   ElseIf cAction == "DELETE" //Se é possível excluir o lpco, verifica se existem atributos a serem apagados
      oModel := FWModelActive()
      setAtuLPCO(oModel:GetModel("SWVDETAIL"), oGridEKQ, cAction)
   EndIf

   If cAction == "UNDELETE" //Se restaurou o lpco, cerifica se ele possui atributos para carregar os valores
      oModel := FWModelActive()
      setAtuLPCO(oModel:GetModel("SWVDETAIL"), oGridEKQ, cAction)
   EndIf

Return lRet

/*
Programa   : PosVldLEKQ
Objetivo   : Funcao para validar se Linha está Ok
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function PosVldLEKQ(oGridEKQ, nLine, cAction)
   Local lRet := .T.

   If !Empty(oGridEKQ:GetValue("EKQ_LPCO")) .and. Empty(oGridEKQ:GetValue("EKQ_VERSAO"))
      EasyHelp(STR0015, STR0003, STR0016) //"Ao preencher o LPCO, sua versão também deverá ser preenchido." #Atenção# "Preencha também o campo Versão do LPCO"
      lRet := .F.
   EndIf


Return lRet

/*
Programa   : PosVldLEJ9
Objetivo   : Funcao para validar se Linha está Ok
Retorno    : Logico
Autor      : Maurício Frison
Data/Hora  : Dezembro/2021
Obs.       :
*/
Static Function PosVldEJ9(oGridModel, nLine)
   Local aExceptions := {"EJ9_IDCERT","EJ9_DEMERC","EJ9_QTDCER"}
Return ValidLine(oGridModel, nLine,aExceptions)

/*
Função     : ValidLine
Objetivo   : Validação da linha - verifica se todos os campos foram preenchidos quando à ao menos um foi atribuído valor
Parâmetros : oGridModel, nLine, aExceptions
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function ValidLine(oGridModel, nLine, aExceptions)
   Local oStruct:= oGridModel:getStruct()
   Local aFields:= oStruct:getFields()
   Local lRet:= .T.
   Local i
   Local nPos
   Local aEmpty:= {}
   Local aNoEmpty:= {}
   Local cField
   Local cEmptyFields:= ""
   Local cHelpP
   Local cHelpS


   For i := 1 to Len(aExceptions)

      cField:= aExceptions[i]

      If Empty(oGridModel:getValue(cField))
         AAdd(aEmpty, cField)

         If !Empty(cEmptyFields)
            cEmptyFields += "', '"
         EndIf

         nPos:= AScan(aFields, {|x| x[3] == cField})
         cEmptyFields += aFields[nPos][1]
      Else
         AAdd(aNoEmpty, cField)
      EndIf


   Next i

   If Len(aEmpty) > 0 .And. Len(aNoEmpty) > 0

      cHelpP:= STR0095 //"Existem campos não informados na linha ### da pasta ***."
      cHelpP:= StrTran(cHelpP, "###", AllTrim(str(nLine)))
      cHelpP:= StrTran(cHelpP, "***", getFolder(oGridModel:getId()))

      cHelpS:= STR0096 //"Revise o(s) campo(s) '###' da pasta $$$, linha ***."
      cHelpS:= StrTran(cHelpS, "###",  cEmptyFields)
      cHelpS:= StrTran(cHelpS, "$$$",  getFolder(oGridModel:getId()))
      cHelpS:= StrTran(cHelpS, "***", AllTrim(str(nLine)))

      EasyHelp(cHelpP, STR0003, cHelpS)

      lRet:= .F.
   EndIf

Return lRet

/*
Função     : getFolder
Objetivo   : Recuperar o nome da pasta onde o grid se encontra
Parâmetros : cIdModel
Retorno    : nome do folder
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function getFolder(cIdModel)
   Local oView:= FWViewActive()
   local cRet := cIdModel
   if Valtype(oView) == "O"
      cRet := oView:GetViewObj(cIdModel)[7]
   endif
Return  cRet

/*
Função     : AltQtdLote
Objetivo   : Valida e atualiza o modelo conforme alteração na quantidade do Lote.
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function AltQtdLote(oModel)

   Local oMdl
   Local oModelSWV
   Local lRet       := .T.
   Local nQtdAntSWV := nQtdInf := 0
   local oModelEIJ := nil
   
   If ValType(oModel) == 'O' .and. alltrim(upper(oModel:getId())) == "EICLP500"

      oMdl          := oModel:GetModel()
      oModelSWV     := oMdl:GetModel("SWVDETAIL")
      oModelEIJ     := oMdl:GetModel("EIJMASTER")

      if valtype(oModelSWV) == "O"
         nQtdInf       := oModelSWV:GetValue("WV_QTDE")

         if valtype(oModelEIJ) == "O" .and. !empty(oModelEIJ:getValue("EIJ_IDPTCP")) .and. !empty(oModelEIJ:getValue("EIJ_VRSACP")) .and. !oModelSWV:VldLineData()
            return .F.
         endif

         hashItemW8 :=  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
         nQtdAntSWV := ManLstFrm(oModel,'__oLstQtdInf' ,'GET',hashItemW8)

         If nQtdInf == 0
            EasyHelp( STR0036 + GetMsgErrIt(oModelSWV) , STR0003 , STR0037 ) // "Quantidade informada para o lote não pode ser zero !" # "Informe uma quantidade menor que a exibida para esta linha!"
            lRet := .F.
         EndIf

         If nQtdInf > nQtdAntSWV
            EasyHelp(STR0038  + GetMsgErrIt(oModelSWV), STR0003 , STR0037 ) // "Quantidade informada para o lote não pode ser maior que a quantidade original do item na invoice!" # Informe uma quantidade menor que a exibida para esta linha!"
            lRet := .F.
         EndIf
      endif

   EndIf

Return lRet

/*
Função     : GetMsgErrIt
Objetivo   : Formata e retorna mensagem indicando o item posicionado no grid SWV
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GetMsgErrIt(oModelSWV)

   Local cMsgRet

   cMsgRet := StrTran( STR0045 , 'W8_HAWB'    , oModelSWV:GetValue("WV_HAWB")    ) //"Processo: 'W8_HAWB' , Invoice: 'W8_INVOICE', P.O.: 'W8_PO_NUM' e Posição: 'W8_POSICAO' "
   cMsgRet := StrTran( cMsgRet , 'W8_INVOICE' , oModelSWV:GetValue("WV_INVOICE") )
   cMsgRet := StrTran( cMsgRet , 'W8_PO_NUM'  , oModelSWV:GetValue("WV_PO_NUM")  )
   cMsgRet := StrTran( cMsgRet , 'W8_POSICAO' , oModelSWV:GetValue("WV_POSICAO") )
   cMsgRet := ENTER + cMsgRet

Return cMsgRet


/*
Função     : GridAddLn
Objetivo   : Formata e retorna mensagem indicando o item posicionado no grid SWV
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GridAddLn(oMdlGrid, aLoadCpos, aNoLoadCpos, lAddLine, nLine, aIgnoreCpos)
   Local lRet := .T.

   Default aNoLoadCpos := {}
   Default lAddLine:= .T.
   default aIgnoreCpos := {}

   default nLine := 0

   If oMdlGrid:getId() == "SWVDETAIL"
      oMdlGrid:SetNoInsertLine(.F.)
   EndIf

   nLine := AddLine(oMdlGrid, aLoadCpos, aNoLoadCpos, lAddLine, , aIgnoreCpos)

   If oMdlGrid:getId() == "SWVDETAIL"
      oMdlGrid:SetNoInsertLine(.T.)
   EndIf

Return lRet

/*
Função     : BkpLinesGD
Objetivo   : Retornar um array com os campos e o dado dos campos para cada linha do grid indicado.
Retorno    : Array
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function BkpLinesGD(oMdlGrid)
   Local aRet := {}, aAux := {}
   Local i,j
   Local aSaveRows := FWSaveRows()

   For i := 1 To oMdlGrid:length()
      oMdlGrid:Goline(i)
      if !oMdlGrid:IsDeleted()
         For j := 1 to Len(oMdlGrid:OFORMMODELSTRUCT:AFIELDS)
            aAdd(aAux,{oMdlGrid:OFORMMODELSTRUCT:AFIELDS[j][3], oMdlGrid:GetValue(oMdlGrid:OFORMMODELSTRUCT:AFIELDS[j][3])})
         Next j
         aAdd(aRet,aClone(aAux))
         aSize(aAux,0)
      endif
   Next i

   FwRestRows(aSaveRows)

Return aRet


/*
Função     : PosVldLSWV
Objetivo   : Função para verificar se o id do portal está preenchido com a versão
Retorno    : .T. se o id do portal e a versão estiverem preenchidas ou as duas estiverem sem preenchimento
             .F. se uma infomraçõa estiver preenchida e outra sem preencher
Autor      : Maurício Frison
Data/Hora  : Setembro/2022
Obs.       :
*/
Static Function PosVldLSWV(oGridSWV, nLine )
Local lRet      :=.T.
Local oMdl      := FWModelActive()
local oModelEIJ := oMdl:GetModel("EIJMASTER")
Local cIdPortal := oModelEIJ:GetValue("EIJ_IDPTCP")
Local cVersao   := oModelEIJ:GetValue("EIJ_VRSACP")
Local cFab      := oModelEIJ:GetValue("EIJ_FABR")
Local cFabLoj   := oModelEIJ:GetValue("EIJ_FABLOJ")
Local cNcm      := getNCM(oMdl:GetModel("SWVDETAIL"))  
local cCodForPU := ""
local cVerForPU := ""
local cCnpjRaiz := ""
local cVerForn  := ""

Begin Sequence

   if ( !empty(cIdPortal) .and. empty(cVersao) ) .or. ( empty(cIdPortal) .and. !empty(cVersao) )
      EasyHelp(STR0137, STR0003, STR0138) // "É necessário que seja informado o ID e a versão do catalogo de produto." ### "Revise os dados do catalogo de produto antes de prosseguir."
      lRet := .F.
      break
   endif

   // não validar devido ao seekline
   if getForceAtu() .or. IsExecAuto(.F.)
      break
   endif

   // Validação com a versão do catalogo de produto
   if !empty(cNcm) .and. !Empty(cIdPortal) .and. !empty(cVersao) .and. !VldCatProd("EIJ_VRSACP", cNCM, cIdPortal, cVersao, cVersao)
      lRet := .F.
      break
   endif

   if !empty(cNcm) .and. !Empty(cIdPortal) .and. !Empty(cVersao)
      PosHistCat(cNcm, cIdPortal, cVersao)
      If !PosCatOper(EKD->EKD_COD_I, EKD->EKD_VERSAO, cFab, cFabLoj)
         EasyHelp(STR0122, STR0003, STR0123) // "O fabricante informado no item não possui vínculo com o Catálogo de produtos informado" ### "Revise os dados dos operadores estrangeiros antes de prosseguir."      
         lRet:= .F.
         break
      EndIF   
   EndIF

   cCodForPU := oModelEIJ:getValue("EIJ_TINFO")   
   cVerForPU := oModelEIJ:getValue("EIJ_VRSFOR")

   if ( !empty(cCodForPU) .and. empty(cVerForPU) ) .or. ( empty(cCodForPU) .and. !empty(cVerForPU) )
      easyHelp(STR0206, STR0003, STR0207) // "É necessário que seja informado o código do fornecedor e sua versão." ### "Revise os dados do Fornecedor."
      lRet := .F.
      break
   endif

   if !empty(cCodForPU) .and. !empty(cVerForPU) .and. SW6->W6_FORMREG == DUIMP_INTEGRADA
      cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
      cVerForn := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, oModelEIJ:getValue("EIJ_FORN") , oModelEIJ:getValue("EIJ_FORLOJ"))
      if empty(cVerForn) .or. !(cVerForPU == cVerForn) .or. !(cCodForPU == EKJ->EKJ_TIN)
         easyHelp(STR0208, STR0003, STR0209) // "O código do fornecedor e sua versão não são válidos ou não estão registrados." ### "Revise o código do fornecedor e sua versão informada."
         lRet := .F.
         break
      endif
   endif

End Sequence

Return lRet

/*
Função     : PreVldLSWV
Objetivo   : Função para saber se linha do grid de vinculação(SWV) pode ou não ser excluída
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function PreVldLSWV(oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld)
   Local oModel         := nil
   Local oModelEKQ      := nil
   Local lRet           := .T.
   Local lTemLPCO       := .F.
   Local lTemLote       := .F.
   Local cRetMsg        := ""
   Local cSeqLnPai      := ""
   Local nX

   Begin Sequence

      // não validar devido ao delete da SW9
      if cAction == "DELETE" .and. (getForceAtu() .or. IsExecAuto(.F.))
         break
      endif

      If cAction == "DELETE"
         if !FwIsInCallStack("LP501Estor")
            cSeqLnPai := STRZERO(1, AVSX3("WV_SEQUENC",3))
            //Procura se há linha pai - saber se linha a ser excluída é originada a partir de uma quebra
            If oGridSWV:GetValue("WV_SEQUENC") <> cSeqLnPai
               //cRetMsg := STR0028 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. "
               If !Empty(oGridSWV:GetValue("WV_LOTE"))
                  lTemLote := .T.
               EndIf
               oModel := FWModelActive()
               oModelEKQ := oModel:GetModel("EKQDETAIL")
               For nX := 1 To oModelEKQ:Length()
                  oModelEKQ:GoLine(nX)
                  if !oModelEKQ:isDeleted()
                     If !Empty(oModelEKQ:GetValue("EKQ_LPCO"))
                        lTemLPCO := .T.
                        exit
                     EndIf
                  endif
               Next nX
               If lTemLPCO
                  cRetMsg += STR0029 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. " # " Existe LPCO vinculado a este registro. "
               EndIf
               If lTemLote
                  cRetMsg += STR0030 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. " # " Existe Lote vinculado a este registro. "
               EndIf
            Else
               lRet := .F.
               EasyHelp(STR0031, STR0003, STR0032) //"Não é possível excluir esta linha. ", "Atenção", "Apenas será possível excluir linha originada a partir de uma quebra")
               Break
            EndIf
         endif
         If !IsExecAuto()
            If MsgYesNo(STR0028 + if( !empty(cRetMsg) , ENTER + cRetMsg, "") + STR0033) //STR0028 "Esta linha foi originada a partir de uma quebra de linha. "- STR0033 - Confirma a Exclusão?
               lRet := .T.
               LP500GATIL("WV_QTDE", .T., cAction)
            Else
               lRet := .F.
               EasyHelp(cRetMsg,STR0003, STR0046) // Serão informadas na mensagem as pendências ## "Operação cancelada pelo usuário"
               Break
            EndIf
         Else
            If Empty(cRetMsg)
               lRet := .T.
               LP500GATIL("WV_QTDE", .T., cAction)
            Else
               lRet := .F.
               EasyHelp(STR0039 + cRetMsg,STR0003,STR0040) // "Registro não pôde ser excluído!" # "Verifique as pendências que impedem que o registro seja excluído!"
               Break
            EndIf
         EndIf

      ElseIf cAction == "UNDELETE"
         LP500GATIL("WV_QTDE", .T., cAction)
      EndIf

   End Sequence

Return lRet

/*
Função     : BkpQtdSWV
Objetivo   : Função para armazenar/recuperar o último valor digitado no campo de
             quantidade do lote no grid.
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function BkpQtdSWV(hashItemWV,xValue)
   Local aAux
   Local nQtdSWV := 0

   Default hashItemWV := ''

   __oLstQtdInf:List(@aAux)
   If ValType(xValue) == "N"
      __oLstQtdInf:Set( hashItemWV , xValue  )
   else
      If !__oLstQtdInf:Get(hashItemWV, @nQtdSWV)
         EasyHelp(STR0041+hashItemWV ) //"Não foi possível obter a quantidade do item chave: "
      EndIf
   EndIf

Return nQtdSWV


/*
Função     : DevolvePai
Objetivo   : Função para recompor saldo da linha pai quando linha filha foi excluída
Retorno    : Array contendo na primeira posição a linha do pai, e quantidade atual do pai
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function DevolvePai(cSeqFilha, oModelSWV)
   Local aSeek := {}
   Local nSubTrai  := 1
   Local cSeqPai   := STRZERO(VAL(cSeqFilha) - nSubTrai, AVSX3("WV_SEQUENC",3)) //vai subtraindo a sequencia a procura do pai
   Local cSeqPrimPai := STRZERO(1, AVSX3("WV_SEQUENC",3))
   Local lAchou    := .F.
   Local nLineRet  := 0

   //ate achar o pai nao deletado
   While !lAchou .And. VAL(cSeqPai) >= VAL(cSeqPrimPai)
      aSeek := { {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"   ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
         {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")},{"WV_SEQUENC" , cSeqPai}}
      If oModelSWV:SeekLine(aSeek , .F. , .T. )
         nLineRet := oModelSWV:GetLine()
         lAchou  := .T.
      EndIf

      cSeqPai := STRZERO(VAL(cSeqFilha) - nSubTrai, AVSX3("WV_SEQUENC",3)) //vai subtraindo a sequencia a procura do pai
      nSubTrai++
   EndDo

Return nLineRet

/*
Função     : LP500DelEKQ
Objetivo   : Função para deleção de todas as linhas do grid EKQ
Retorno    : Array contendo na primeira posição a linha do pai, e quantidade atual do pai
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function LP500DelEKQ(oModel, cAction)
   Local oModelEKQ := oModel:GetModel("EKQDETAIL")
   Local nX        := 0

   If ValType(oModelEKQ) == "O"
      If cAction == "DELETE"
         oModelEKQ:DelAllline()
      Elseif cAction == "UNDELETE"
         For nX := 1 to oModelEKQ:Length()
            oModelEKQ:GoLIne(nX)
            If oModelEKQ:IsDeleted()
               oModelEKQ:UnDeleteLine()
            EndIf
         Next nX
      EndIf
   EndIf

Return

/*
Função     : LP500PdLPCO
Objetivo   : Avaliar as linhas de grid EKQ relacionadas à linha de grid SWV
             posicionada de forma a determinar o valor do campo WV_LPCOPND
Retorno    : Status para o campo WV_LPCOPND
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Function LP500PdLPCO(oModel)
return EvalPdLPCO(oModel)

/*
Função     : EvalPdLPCO
Objetivo   : Avaliar as linhas de grid EKQ relacionadas à linha de grid SWV
             posicionada de forma a determinar o valor do campo WV_LPCOPND
Retorno    : Status para o campo WV_LPCOPND
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function EvalPdLPCO(oModel)

   Local i, cSttRet:= ''
   Local oMdlEKQ     := oModel:GetModel("EKQDETAIL")
   Local aPendLPCO   := {}
   Local aLnOKLPCO   := {}

   For i:=1 To oMdlEKQ:length()
      oMdlEKQ:GoLine(i)
      If !oMdlEKQ:isDeleted() .and. oMdlEKQ:GetValue("EKQ_OBRFRM") == "1"
         If Empty(oMdlEKQ:GetValue("EKQ_LPCO")) .Or. Empty(oMdlEKQ:GetValue("EKQ_VERSAO"))
            aAdd( aPendLPCO, { oMdlEKQ:GetValue("EKQ_ORGANU"),oMdlEKQ:GetValue("EKQ_FRMLPC") } )
         Else
            aAdd( aLnOKLPCO, { oMdlEKQ:GetValue("EKQ_ORGANU"),oMdlEKQ:GetValue("EKQ_FRMLPC") } )
         EndIf
      EndIf
   Next i
   oMdlEKQ:GoLine(1)

   If Len(aPendLPCO) > 0
      For i := 1 To Len(aPendLPCO)
         cSttRet += Alltrim(aPendLPCO[i][1]) + '/' + Alltrim(aPendLPCO[i][2]) + If(i<Len(aPendLPCO),",","")
      Next i
      cSttRet := STR0042 + cSttRet //"Pendente informar LPCO Órgão Anuente/Form.:  "
   ElseIf Len(aLnOKLPCO) > 0
      cSttRet := STR0043 //"Sem pendências de LPCO"
   Else
      cSttRet := STR0044 //"Sem necessidade de LPCO"
   EndIf

Return cSttRet

/*
Função     : GetNextSeq
Objetivo   : Função para buscar a próxima sequencia disponível na inclusão de linha no grid SWV
Retorno    : código da próxima sequência disponível
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       : Considera as linhas deletadas na busca
*/
Static Function GetNextSeq(oModelSWV)
   Local lSeek     := .T.
   Local nLineAt   := oModelSWV:GetLine()
   Local cSeqIndex := oModelSWV:GetValue("WV_SEQUENC")
   Local aSeek     := { {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"    ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
      {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")} , {"WV_SEQUENC" , cSeqIndex}}
   While lSeek
      If ( lSeek := oModelSWV:SeekLine(aSeek , .T. , .T. ) )
         cSeqIndex  := SomaIt(cSeqIndex)
         aSeek[6,2] := cSeqIndex
      EndIf
   EndDo

   oModelSWV:GoLine(nLineAt)

Return cSeqIndex

/*
Função     : ChangeLnWV
Objetivo   : Executar uma ação a cada mudança de linha no grid SWV
Retorno    : Nenhum
Autor      : Nilson César
Data/Hora  : Outubro/2021
*/
Static Function ChangeLnWV(oView, cViewID)

   Local oMdl       := FWModelActive()
   Local oModSW9    := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV    := oMdl:GetModel("SWVDETAIL")
   Local oMdlSWVTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
   Local oMdlEKQ    := oMdl:GetModel("EKQDETAIL")
   Local aSeek      := {}
   Local cHawb
   Local cInvoice
   Local cFornecedor
   Local cLoja
   Local cIdWV
   Local cInvHawb
   Local cInvInvoice
   Local cInvFornecedor
   Local cInvLoja

   Do Case
      Case cViewID == "SWVDETAIL"
         oMdlEKQ:SetNoInsertLine(  oMdlSWV:IsDeleted()  )

         cHawb      := oMdlSWV:GetValue("WV_HAWB")
         cIdWV      := oMdlSWV:GetValue("WV_ID")

         aSeek := {  {"WV_FILIAL"  , xFilial("SWV") },;
                     {"WV_HAWB"    , cHawb },;
                     {"WV_ID"      , cIdWV }}

         oMdlSWVTrb:SeekLine(aSeek, .T., .T.)

         If canUseApp()
            cActiveID := cIdWV
         EndIf
         oView:Refresh("VIEW_SWV_TRIB")

      Case cViewID == "SWVDETAIL_TRIBUTACAO"
         cHawb      := oMdlSWVTrb:GetValue("WV_HAWB")
         cInvoice   := oMdlSWVTrb:GetValue("WV_INVOICE")
         cFornecedor:= oMdlSWVTrb:GetValue("WV_FORN")
         cLoja      := oMdlSWVTrb:GetValue("WV_FORLOJ")
         cIdWV      := oMdlSWVTrb:GetValue("WV_ID")

         cInvHawb      := oModSW9:GetValue("W9_HAWB")
         cInvInvoice   := oModSW9:GetValue("W9_INVOICE")
         cInvFornecedor:= oModSW9:GetValue("W9_FORN")
         cInvLoja      := oModSW9:GetValue("W9_FORLOJ")

         If canUseApp()
            cActiveID := cIdWV
         EndIf
         
         If cInvHawb <> cHawb .Or. cInvInvoice <> cInvoice .Or. cInvFornecedor <> cFornecedor .Or. cInvLoja <> cLoja
            
            aSeek := {  {"W9_FILIAL"  , xFilial("SW9") },;
                        {"W9_HAWB"    , cHawb },;
                        {"W9_INVOICE" , cInvoice },;
                        {"W9_FORN"    , cFornecedor },;
                        {"W9_FORLOJ"  , cLoja }}

            oModSW9:SeekLine(aSeek, .T., .T.)
            
            oView:Refresh("VIEW_SWV")
         EndIf

         aSeek := {  {"WV_FILIAL"  , xFilial("SWV") },;
                     {"WV_HAWB"    , cHawb },;
                     {"WV_ID"      , cIdWV }}
         
         oMdlSWV:SeekLine(aSeek, .T., .T.)
         
         oView:Refresh("VIEW_SWV")

   EndCase

Return

/*
Função     : GerSeqDuimp
Objetivo   : Gera sequência DUIMP automaticamente
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Outubro/2021
*/
Static Function GerSeqDuimp(lPergunta)

   Local oMdl       := FWModelActive()
   Local oModelSW9  := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV    := oMdl:GetModel("SWVDETAIL")
   Local i,nLines,nSeq:=0,nSW9
   Local lContinua  := .T.
   Local lExit      := .F.
   Local aSaveLines := FWSaveRows()
   local oMdlSWVTrb := nil
   local lModSWVTrb := .F.

   //Verifica se tem alguma linha com o campo sequência duimp preenchido
   if lPergunta
      For nSW9 := 1 To oModelSW9:length()
         oModelSW9:GoLine(nSW9)
         if !oModelSW9:isDeleted()
            for i:=1 to 10
               if oMdlSWV:SeekLine({{"WV_SEQDUIM",strzero(i-1,1)}}, .F., .F. ) //pesquisa se existe alguma linha começando com a sequenciad duimp entre 0 e 9, se não encontrar é pq não existe nenhum item preenchdio
                  lExit:=.T.
                  lContinua := if( IsExecAuto(), .F., MsgNoYes(STR0052,STR0048))//"Existe um ou mais registos com o campo sequência DUIMP preenchido, se continuar os valores serão sobrepostos, deseja continuar?","AVISO"
                  Exit
               EndIf
            next i
         endif
         if lExit
            EXIt
         EndIf
      Next nSW9
   EndIf   

   if lContinua
      oMdlSWVTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
      lModSWVTrb := valtype(oMdlSWVTrb) == "O"
      For nSW9 := 1 To oModelSW9:length()
         oModelSW9:GoLine(nSW9)
         if !oModelSW9:isDeleted()
            nLines :=  oMdlSWV:length()
            For i:=1 To nLines
               oMdlSWV:GoLine(i)
               If !oMdlSWV:IsDeleted()
                  nSeq += 1
                  oMdlSWV:LoadValue("WV_SEQDUIM",strZero(nSeq,AVSX3("WV_SEQDUIM",AV_TAMANHO)))
                  if lModSWVTrb
                     LP500LdTrb(oMdlSWVTrb, "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", "WV_SEQDUIM")
                  endif
               EndIf
            Next i
         endif
      Next SW9
   EndIf
   FWRestRows(aSaveLines)
Return

/*
Função     : DelSeqDuimp
Objetivo   : Apagar as sequências DUIMP
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Outubro/2021
*/
function LP500DelSeq()
return DelSeqDuimp(.F.)

/*
Função     : DelSeqDuimp
Objetivo   : Apagar as sequências DUIMP
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Outubro/2021
*/
Static Function DelSeqDuimp(lPergunta)
   Local oMdl       := FWModelActive()
   Local oModelSW9  := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV    := oMdl:GetModel("SWVDETAIL")
   Local i,nLines,nSW9
   Local aSaveLines := {}
   Local lContinua  := .T.
   local oMdlSWVTrb := nil
   local lModSWVTrb := .F.

   default lPergunta := .F.

   lContinua := if(lPergunta, if( IsExecAuto(), .F., MsgNoYes(STR0053,STR0048)),.T.) //"Deseja apagar todas as sequências da DUIMP?","AVISO"

   if lContinua
      aSaveLines := FWSaveRows()
      oMdlSWVTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
      lModSWVTrb := valtype(oMdlSWVTrb) == "O"
      For nSW9 := 1 To oModelSW9:Length()
         oModelSW9:GoLine(nSW9)
         if !oModelSW9:isDeleted()
            nLines:=oMdlSWV:Length()
            For i:=1 To nLines
               oMdlSWV:GoLine(i)
               oMdlSWV:LoadValue("WV_SEQDUIM","")
               if lModSWVTrb
                  LP500LdTrb(oMdlSWVTrb, "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", "WV_SEQDUIM")
               endif
            Next i
         endif
      Next nSW9
      FWRestRows(aSaveLines)
   EndIf
Return

function LP500GetW7W8(oModelSWV,xCpos)
return GetInfW7W8(oModelSWV,xCpos)
/*
Função     : GetInfW7W8
Objetivo   : Posicionar o registro da SW8 e retornar a informação dos campos passados
             por parâmetro na variável xCpos
Parâmetros : oModel -> Objeto - modelo de dados ativo
             xCpos  -> Caracter/Array - campo ou campos das tabelas SW7 ou SW8 para retornar o valor
Retorno    : aRet - Array com os dados de cada campo para o registo, na mesma ordem de
                    indicação dos campos.
Obs.       : A tabela é definida pelo nome do primeiro campo passado no parâmetro
             Não passar campos de tabelas diferentes no mesmo array!
Autor      : Nilson César
Data/Hora  : Outubro/2021
*/
Static Function GetInfW7W8(oModelSWV,xCpos)
   Local i
   Local aRet := {}
   Local cAlias, nOrdSeek, cKeySeek

   cAlias   := If( Left(xCpos[1],2) == "W7", "SW7","SW8"  )
   nOrdSeek := If(cAlias == "SW7",4,6)                     //W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM  #### //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   (cAlias)->(DbSetOrder( nOrdSeek ))

   If cAlias == "SW7"
      cKeySeek := xFilial("SW7") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_PGI_NUM")
   Else
      cKeySeek := xFilial("SW8") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_PGI_NUM")
   EndIf

   If cKeySeek <> (cAlias)->&(IndexKey())
      (cAlias)->(DbSeek( cKeySeek ))
   EndIf

   If (cAlias)->(!Eof())
      For i := 1 To Len(xCpos)
         aAdd( aRet, (cAlias)->&(xCpos[i])  )
      Next i
   EndIf

Return aRet


/*
Função     : PosValEIN
Objetivo   : Validação da linha EIN do grid de acréscimos e deduções
Parâmetros : oGridModel, nLine
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function PosValEIN(oGridModel, nLine)
   Local aExceptions:= {"EIN_CODIGO", "EIN_FOBMOE", "EIN_VLMLE", "EIN_VLMMN"}
Return ValidLine(oGridModel, nLine, aExceptions)

/*
Função     : PosValEIK
Objetivo   : Validação da linha EIK do grid de documentos vinculados
Parâmetros : oGridModel, nLine
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function PosValEIK(oGridModel, nLine)
   Local aExceptions:= {"EIK_TIPVIN", "EIK_DOCVIN"}
Return ValidLine(oGridModel, nLine, aExceptions)

/*
Função     : LP500CBOX
Objetivo   : Retorna a lista de opções conforme o tipo de processo
Parâmetros :
Retorno    : lista de opções
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Function LP500CBOX()
   Local cRet:= ""

   If (IIF (ISMEMVAR('M->W6_TIPOREG'),M->W6_TIPOREG # '2',SW6->W6_TIPOREG # '2'))
      cRet:= "2=Declaração de Importação;3=Registro de Importação"   
   Else
      cRet:= "1=DUIMP;2=DUE;3=DI;4=DE"
   EndIf

Return cRet

/*
Função     : ValidaItemDuimp
Objetivo   : Verifica se o item da duimp informado para o item existe em outro item do processo
Parâmetros :
Retorno    :
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function ValidaItemDuimp(oModel, oModelSWV, cField, cNewValue, nLineSwv)
   Local nPosSubModel
   Local lFind:= .F.
   Local nSW9, nLineSW9
   Local aDataModel
   Local aData
   Local nData
   Local nField

   Begin Sequence

      nField:= oModelSWV:getIdField(cField)
      nLineSW9 := oModel:getModel("SW9DETAIL"):getline()
      For nSW9 := 1 To oModel:getModel("SW9DETAIL"):Length()

         aDataModel:= AClone(oModel:getModel("SW9DETAIL"):aDataModel[nSW9][MODEL_GRID_CHILDREN])

         nPosSubModel := AScan(aDataModel, {|x| x[MODEL_GRID_CHILDREN_ID] == "SWVDETAIL"})
         If nPosSubModel > 0
            aData := AClone(aDataModel[nPosSubModel][MODEL_GRID_CHILDREN_DATA])

            For nData:= 1 to Len(aData)
               If!(nSw9 == nLineSW9 .And. nLineSwv == nData) .and. !aData[nData][MODEL_GRID_DELETE] //Não pesquisa para o próprio registro que está sendo editado
                  lFind:= aData[nData][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nField] == cNewValue

                  If lFind
                     Break
                  EndIf
               EndIf   
            Next nData

         EndIf

      Next nSW9
      oModel:getModel("SW9DETAIL"):goline(nLineSW9)
      oModelSWV:goline(nLineSwv)
   End Sequence

Return !lFind

/*
Função     : VerCampos
Objetivo   : Verifica se os campos exitem e estão configurados como usado
Parâmetros :
Retorno    :
Obs.       :
Autor      : bak
Data/Hora  : 03/2022
*/
static function VerCampos(cAlias, aCampos)
   local lRet       := .F.
   local nCpo       := 0
   local cAliasOld  := ""

   default cAlias    := ""
   default aCampos   := {}

   if !empty(cAlias) .and. valtype(aCampos) == "A" .and. len(aCampos) > 0
      cAliasOld := Alias()

      dbSelectArea(cAlias)
      begin sequence
      for nCpo := 1 to len(aCampos)
         if (cAlias)->(columnPos(aCampos[nCpo])) == 0 .or. !X3USO(GetSX3Cache(aCampos[nCpo], "X3_USADO"))
            break
         endif
      next

      lRet := .T.
      end sequence

      if ( !empty(cAliasOld), dbSelectArea(cAliasOld), nil)

   endif

return lRet

/*
Função     : VldEKQ
Objetivo   : Valida se o orgão anuente e o formulario já foram informados
Parâmetros :
Retorno    :
Obs.       :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 03/2022
*/
static function VldEKQ( oModelEKQ )
   local lRet       := .T.
   local aLinesEKQ  := {}
   local cOrgao     := ""
   local cFormul    := ""
   local nLinePos   := 0
   local nLine      := 0
   local nLenEKQ    := 0

   if !empty(oModelEKQ:GetValue("EKQ_ORGANU")) .and. !empty(oModelEKQ:GetValue("EKQ_FRMLPC"))

      aLinesEKQ := FWSaveRows()

      cOrgao := oModelEKQ:GetValue("EKQ_ORGANU")
      cFormul := oModelEKQ:GetValue("EKQ_FRMLPC")
      nLinePos := oModelEKQ:getLine()
      nLenEKQ := oModelEKQ:Length()

      for nLine := 1 to nLenEKQ
         if nLinePos <> nLine
            oModelEKQ:goline(nLine)
            if !oModelEKQ:IsDeleted() .and. oModelEKQ:GetValue("EKQ_ORGANU") == cOrgao .and. oModelEKQ:GetValue("EKQ_FRMLPC") == cFormul
               lRet := .F.
               EasyHelp(STR0097 , STR0003, STR0098 + " " + alltrim(str(nLine)) + ".") // "O orgão anuente e formulário já foram informados." ### "Atenção" ### "Verifique a linha"
               exit
            endif
         endif
      next

      FWRestRows(aLinesEKQ)
   endif

return lRet

/*
Função     : LP500LdTrb
Objetivo   : Carrega os itens na pasta Tributação
Parâmetros :
Retorno    :
Obs.       :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 03/2022
*/
static function LP500LdTrb(oModelo, cType, lEdit, nAtuSWV, cAction, cCampo, aInfos, lFirst)
   local aDados     := {}
   local lNoInsLine := .F.
   local lNoUpdLine := .F.
   local lNoDelLine := .F.
   local oModel     := nil
   local oStruct    := nil
   local aCposMod   := {}
   local oModSWV    := nil
   local aLines     := {}
   local oModSW9    := nil
   local nLenSWV    := 0
   local nItens     := 0
   local nCampos    := {}
   local aCposLoads := {}
   local nLineSWV   := 0
   local aSeek      := {}
   local aPKeyWV    := {}
   local oModSWVTrb := nil
   local oModEIJ    := nil
   local nInfo      := 0
   local aLinEIJ    := {}
   local oModelII   := nil
   local oModelIPI  := nil
   local oModelPC   := nil
   local oModelICMS := nil
   local cCpo       := ""
   local xDado      := nil
   local nLine      := 0
   local nLineGrp   := 0
   local oView      := nil
   local oModelGrp  := nil
   local cNCMTrb    := ""
   local cEXNCMTrb  := "" 
   local cGrpTrb    := "" 
   local nPosGrp    := 0
   local aGrpTrib   := {}
   local nLenGrpTrb := 0
   local lDeleted   := .F.
   local lTribDUIMP := .F.
   local oModelPIS  := nil
   local oModelCOF  := nil
   local oModelADU  := nil

   default cType    := ""
   default lEdit    := .F.
   default nAtuSWV  := 0
   default cAction  := ""
   default cCampo   := ""
   default aInfos   := {}
   default lFirst    := .F.

   if !(oModelo == nil)
      oModel := oModelo:getModel()
      oStruct := oModelo:getStruct()
      aCposMod := oStruct:GetFields()
      oModSWV := oModel:getModel("SWVDETAIL")
   endif

   do case

      case cType == "SWVDETAIL_TRIBUTACAO"

         if !oModelo:CanInsertLine()
            oModelo:SetNoInsertLine(.F.)
            lNoInsLine := .T.
         endif

         if !oModelo:CanUpdateLine()
            oModelo:SetNoUpdateLine(.F.)
            lNoUpdLine := .T.
         endif

         if !oModelo:CanDeleteLine()
            oModelo:SetNoDeleteLine(.F.)
            lNoDelLine := .T.
         endif

         if lEdit

            oModSWV := oModel:getModel("SWVDETAIL")
            aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                  },;
                        {"WV_HAWB"    , oModSWV:GetValue("WV_HAWB")     },;
                        {"WV_INVOICE" , oModSWV:GetValue("WV_INVOICE")  },;
                        {"WV_FORN"    , oModSWV:GetValue("WV_FORN")     },;
                        {"WV_FORLOJ"  , oModSWV:GetValue("WV_FORLOJ")   },;
                        {"WV_PO_NUM"  , oModSWV:GetValue("WV_PO_NUM")   },;
                        {"WV_POSICAO" , oModSWV:GetValue("WV_POSICAO")  },;
                        {"WV_SEQUENC" , oModSWV:GetValue("WV_SEQUENC")  }}

            // posiciona no array do modelo SWVDETAIL_TRIBUTACAO
            if oModelo:SeekLine(aSeek, cAction == "UNDELETE", .T.)
               if cAction == "NEWLINE"

                  aLinEIJ := aClone(oModel:getModel("EIJMASTER"):ADATAMODEL)[1] //pega os dados do registro posicionado da eij

                  // atualiza a quantidade
                  oModelo:loadValue("WV_QTDE", oModSWV:GetValue("WV_QTDE") )

                  nLineSWV := oModSWV:getLine()

                  // Adicionar a linha quebrada
                  oModSWV:goline(nAtuSWV)

                  aCposLoads := {}
                  for nCampos := 1 to len(aCposMod)
                     aAdd( aCposLoads,  { aCposMod[nCampos][3], oModSWV:getValue(aCposMod[nCampos][3]) } )
                  next
                  AddLine(oModelo, aCposLoads, , .T., aCposMod, {"WV_CODREG"})
                  oModelo:setValue("WV_CODREG", oModSWV:GetValue("WV_CODREG") )

                  lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")
                  oModelII := oModel:getModel("EIJMASTER_II")
                  oModelIPI := oModel:getModel("EIJMASTER_IPI")
                  if lTribDUIMP
                     oModelPIS := oModel:getModel("EIJMASTER_PIS")
                     oModelCOF := oModel:getModel("EIJMASTER_COFINS")
                     oModelADU := oModel:getModel("EIJMASTER_ANTIDUMPING")
                  else
                     oModelPC := oModel:getModel("EIJMASTER_PISCOFINS")
                  endif
                  oModelICMS := oModel:getModel("EIJMASTER_ICMS")
                  for nInfo := 1 to len(aLinEIJ)
                     cCpo := alltrim(aLinEIJ[nInfo][1])
                     xDado := aLinEIJ[nInfo][2]
                     if cCpo $ "EIJ_HAWB||EIJ_IDWV"
                        oModelII:loadValue(cCpo, xDado)
                        oModelIPI:loadValue(cCpo, xDado)
                        if lTribDUIMP
                           oModelPIS:loadValue(cCpo, xDado)
                           oModelCOF:loadValue(cCpo, xDado)
                           oModelADU:loadValue(cCpo, xDado)
                        else
                           oModelPC:loadValue(cCpo, xDado)
                        endif
                        oModelICMS:loadValue(cCpo, xDado)
                     elseif !lTribDUIMP .and. cCpo $ "EIJ_REGTRI||EIJ_FUNREG||EIJ_TPAII||EIJ_ALI_II"
                        oModelII:loadValue(cCpo, xDado)
                     elseif !lTribDUIMP .and. cCpo $ "EIJ_REGIPI||EIJ_ASSIPI||EIJ_TPAIPI||EIJ_ALAIPI"
                        oModelIPI:loadValue(cCpo, xDado)
                     elseif !lTribDUIMP .and. cCpo $ "EIJ_REG_PC||EIJ_FUN_PC||EIJ_TPAPIS||EIJ_ALAPIS||EIJ_TPACOF||EIJ_ALACOF"
                        oModelPC:loadValue(cCpo, xDado)
                     elseif lTribDUIMP .and. cCpo $ "EIJ_FUNII||EIJ_DSCFL1||EIJ_REGTRI||EIJ_DSCRG1||EIJ_TPAII||EIJ_ALI_II||EIJ_ALR_II"
                        oModelII:loadValue(cCpo, xDado)
                     elseif lTribDUIMP .and. cCpo $ "EIJ_FUNIPI||EIJ_DSCFL2||EIJ_REGIPI||EIJ_DSCRG2||EIJ_TPAIPI||EIJ_ALAIPI||EIJ_ALRIPI||EIJ_ALUIPI||EIJ_QTUIPI"
                        oModelIPI:loadValue(cCpo, xDado)
                     elseif lTribDUIMP .and. cCpo $ "EIJ_FUNPIS||EIJ_DSCFL3||EIJ_REGPIS||EIJ_DSCRG3||EIJ_TPAPIS||EIJ_ALAPIS||EIJ_REDPIS||EIJ_ALUPIS||EIJ_QTUPIS||EIJ_ALPISM"
                        oModelPIS:loadValue(cCpo, xDado)
                     elseif lTribDUIMP .and. cCpo $ "EIJ_FUNCOF||EIJ_DSCFL4||EIJ_REGCOF||EIJ_DSCRG4||EIJ_TPACOF||EIJ_ALACOF||EIJ_REDCOF||EIJ_ALUCOF||EIJ_QTUCOF||EIJ_ALCOFM"
                        oModelCOF:loadValue(cCpo, xDado)
                     elseif lTribDUIMP .and. cCpo $ "EIJ_FUNADU||EIJ_DSCFL5||EIJ_TPADUM||EIJ_ALADDU||EIJ_BAE_AD||EIJ_ALEADU"
                        oModelADU:loadValue(cCpo, xDado)
                     elseif cCpo $ "EIJ_OPERAC||"
                        oModelICMS:loadValue(cCpo, xDado)
                     endif
                  next

                  // Orderna os registros dos itens da tributação
                  aPKeyWV := { aScan(oModelo:AHEADER,{|x| x[2] == "WV_INVOICE" }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_PO_NUM"  }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_POSICAO" }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_SEQUENC" })  }

                  aSort(oModelo:aDATAMODEL,,, {|x,y| x[1][1][aPKeyWV[1]] + x[1][1][aPKeyWV[2]] + x[1][1][aPKeyWV[3]] + x[1][1][aPKeyWV[4]]  <  ;
                     y[1][1][aPKeyWV[1]] + y[1][1][aPKeyWV[2]] + y[1][1][aPKeyWV[3]] + y[1][1][aPKeyWV[4]]  } )

                  oView := FWViewActive()
                  if valtype(oView) == "O"
                     oView:Refresh("VIEW_SWV_TRIB")
                  endif

                  oModSWV:goline(nLineSWV)
                  oModelo:goline(nLineGrp)

               elseif cAction == "DELETE" .or. cAction == "UNDELETE"
                  if cAction == "DELETE"
                     oModelo:DeleteLine()
                  else
                     oModelo:UnDeleteLine()
                     oView := FWViewActive()
                     if valtype(oView) == "O"
                        oView:Refresh("VIEW_SWV_TRIB")
                     endif
                  endif

                  if nAtuSWV > 0 .and. valtype(oModel:getModel("SWVDETAIL_TRIBUTACAO")) == "O"
                     nLineSWV := oModSWV:getLine()
                     oModSWV:goline(nAtuSWV)
                     nLine := oModelo:getLine()
                     LP500LdTrb(oModelo, "SWVDETAIL_TRIBUTACAO", .T., nAtuSWV, "GATILHO" , "WV_QTDE")
                     oModSWV:goline(nLineSWV)

                     oModelGrp := oModel:getModel("GRPDETAIL_TRIBUTACAO")
                     if valtype( oModelGrp ) == "O"

                        aDados := { "GRPDETAIL_TRIBUTACAO",;
                                    { { "WV_NCM"    , oModSWV:getValue("WV_NCM")   } ,;
                                      { "WV_EX_NCM" , oModSWV:getValue("WV_EX_NCM")} ,;
                                      { "WV_CODREG" , oModSWV:getValue("WV_CODREG")}};
                                   }
                        oModelo:goline(nLine)
                        LP500LdTrb(oModelGrp , "GRPDETAIL_TRIBUTACAO", .T., , cAction, , aDados)

                     endif
                     oModSWV:goline(nLineSWV)

                  endif

               elseif cAction == "GATILHO" .and. !empty(cCampo)
                  oModelo:loadValue(cCampo, oModSWV:GetValue(cCampo) )

               endif

               oModelo:SeekLine(aSeek, cAction == "UNDELETE", .T.)

            endif

         endif

         oModelo:SetNoInsertLine(lNoInsLine)
         oModelo:SetNoUpdateLine(lNoUpdLine)
         oModelo:SetNoDeleteLine(lNoDelLine)

      case cType == "EIJMASTER_II" .or. cType == "EIJMASTER_IPI" .or. cType == "EIJMASTER_PISCOFINS" .or. cType == "EIJMASTER_ICMS" .or. cType == "EIJMASTER_OBSTRB" .or. cType == "EIJMASTER" .or. ;
         cType == "EIJMASTER_PIS" .or. cType == "EIJMASTER_COFINS" .or. cType == "EIJMASTER_ANTIDUMPING"
 
         oModSW9 := oModel:getModel("SW9DETAIL")

         oModSWVTrb := oModel:getModel("SWVDETAIL_TRIBUTACAO")
         if cType == "EIJMASTER" .and. oModSWVTrb == nil
            oModSWVTrb := oModel:getModel("SWVDETAIL")
         endif
         aLines := FWSaveRows()

         aSeek := {  {"W9_FILIAL"  , xFilial("SW9")                     },;
                     {"W9_HAWB"    , oModSWVTrb:GetValue("WV_HAWB")     },;
                     {"W9_INVOICE" , oModSWVTrb:GetValue("WV_INVOICE")  },;
                     {"W9_FORN"    , oModSWVTrb:GetValue("WV_FORN")     },;
                     {"W9_FORLOJ"  , oModSWVTrb:GetValue("WV_FORLOJ")   }}

         if oModSW9:SeekLine(aSeek, .F., .T.)

            aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                     },;
                        {"WV_HAWB"    , oModSWVTrb:GetValue("WV_HAWB")     },;
                        {"WV_INVOICE" , oModSWVTrb:GetValue("WV_INVOICE")  },;
                        {"WV_FORN"    , oModSWVTrb:GetValue("WV_FORN")     },;
                        {"WV_FORLOJ"  , oModSWVTrb:GetValue("WV_FORLOJ")   },;
                        {"WV_PO_NUM"  , oModSWVTrb:GetValue("WV_PO_NUM")   },;
                        {"WV_POSICAO" , oModSWVTrb:GetValue("WV_POSICAO")  },;
                        {"WV_SEQUENC" , oModSWVTrb:GetValue("WV_SEQUENC")  }}

            oModSWV := oModel:getModel("SWVDETAIL")
            if oModSWV:SeekLine(aSeek, .F., .T.)

               oModEIJ := oModel:getModel("EIJMASTER")

               if lEdit
                  if cAction == "GATILHO"
                     if !empty(cCampo)
                        oModEIJ:loadValue(cCampo, oModelo:GetValue(cCampo) )
                     elseif len( aInfos ) > 0
                        for nInfo := 1 to len(aInfos)
                           if aInfos[nInfo][1] == "SWVDETAIL"
                              oModSWV:loadValue(aInfos[nInfo][2], aInfos[nInfo][3] )
                           elseif aInfos[nInfo][1] == "EIJMASTER"
                              oModEIJ:loadValue(aInfos[nInfo][2], aInfos[nInfo][3] )
                           endif
                        next
                     endif

                  endif

               endif

            endif

         endif

         FWRestRows(aLines)

      case cType == "GRPDETAIL_TRIBUTACAO"

         if( !oModelo:CanInsertLine() , ( oModelo:SetNoInsertLine(.F.) , lNoInsLine := .T. ) , nil )
         if( !oModelo:CanUpdateLine() , ( oModelo:SetNoUpdateLine(.F.) , lNoUpdLine := .T. ) , nil )
         if( !oModelo:CanDeleteLine() , ( oModelo:SetNoDeleteLine(.F.) , lNoDelLine := .T. ) , nil )

         if lEdit

            if cAction == "GATILHO" .or. cAction == "DELETE" .or. cAction == "UNDELETE"

               if len( aInfos ) > 0 

                  if aInfos[1] == "GRPDETAIL_TRIBUTACAO"

                     oView := FWViewActive()
                     nLine := oModelo:getLine()
                     oModSWVTrb := oModel:getModel("SWVDETAIL_TRIBUTACAO")
                     nLineSWV := oModSWVTrb:getLine()

                     aSeek := { {"WV_NCM"    , aInfos[2][1][2] },;
                                {"WV_EX_NCM" , aInfos[2][2][2] },;
                                {"WV_CODREG" , aInfos[2][3][2] }}

                     // caso não encontre o grupo tributário, realiza a inclusão
                     if !oModelo:SeekLine(aSeek, .T., .T.)
 
                        aCposLoads := {}
                        for nCampos := 1 to len(aCposMod)
                           aAdd( aCposLoads,  { aCposMod[nCampos][3], oModSWVTrb:getValue(aCposMod[nCampos][3]) } )
                        next
                        AddLine(oModelo, aCposLoads, , .T., aCposMod)

                     // caso encontre o grupo deletado e é uma ação de undelete , restaura a linha
                     elseif oModelo:isDeleted() .and. ( cAction == "UNDELETE" .or. cAction == "GATILHO")
                        if !oModelo:SeekLine(aSeek, .F., .T.)
                           oModelo:UnDeleteLine()
                        endif
                     endif

                     nLenGrpTrb := oModelo:length()
                     for nItens := 1 to nLenGrpTrb
                        oModelo:goline(nItens)
                        if !oModelo:isDeleted()

                           aSeek := { {"WV_NCM"    , oModelo:GetValue("WV_NCM")  },;
                                      {"WV_EX_NCM" , oModelo:GetValue("WV_EX_NCM") },;
                                      {"WV_CODREG" , oModelo:GetValue("WV_CODREG") }}
                           // caso nao tenha nenhum item com a chave, deleta o grupo
                           if !oModSWVTrb:SeekLine(aSeek, .F., .T.)
                              oModelo:DeleteLine()
                           endif

                        endif
                     next nItens

                     oModelo:goline( nLine )
                     oModSWVTrb:goline( nLineSWV )
                     aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                     },;
                                 {"WV_HAWB"    , oModSWVTrb:GetValue("WV_HAWB")     },;
                                 {"WV_INVOICE" , oModSWVTrb:GetValue("WV_INVOICE")  },;
                                 {"WV_FORN"    , oModSWVTrb:GetValue("WV_FORN")     },;
                                 {"WV_FORLOJ"  , oModSWVTrb:GetValue("WV_FORLOJ")   },;
                                 {"WV_PO_NUM"  , oModSWVTrb:GetValue("WV_PO_NUM")   },;
                                 {"WV_POSICAO" , oModSWVTrb:GetValue("WV_POSICAO")  },;
                                 {"WV_SEQUENC" , oModSWVTrb:GetValue("WV_SEQUENC")  }}

                     if valtype(oView) == "O"
                        oView:Refresh("VIEW_GRP_TRIB")
                        oView:Refresh("VIEW_SWV_TRIB")
                     endif

                     oModSWVTrb:SeekLine(aSeek, .T., .T.)

                  elseif aInfos[1] == "SWVDETAIL_TRIBUTACAO"

                     oModelGrp := oModel:getModel("GRPDETAIL_TRIBUTACAO")
                     oModelGrp:SetNoDeleteLine(.F.)
                     setLoadTrb("0")
                     oView := FWViewActive()

                     nLine := oModelo:getLine()
                     nLineGrp := oModelGrp:getLine()

                     nLenGrpTrb := oModelGrp:length()
                     for nItens := 1 to nLenGrpTrb

                        if !(nLineGrp == nItens)
                           oModelGrp:goline(nItens)
                           if !oModelGrp:isDeleted()

                              cNCMTrb := oModelGrp:GetValue("WV_NCM")
                              cEXNCMTrb := oModelGrp:GetValue("WV_EX_NCM") 
                              cGrpTrb := oModelGrp:GetValue("WV_CODREG") 
                              nPosGrp := aScan( aGrpTrib, { |X| X[1] == cNCMTrb .and. X[2] == cEXNCMTrb .and. X[3] == cGrpTrb } )
                              if nPosGrp == 0
                                 aAdd( aGrpTrib , { cNCMTrb, cEXNCMTrb, cGrpTrb } )
                              endif

                              if cNCMTrb == aInfos[2][1][2] .and. cEXNCMTrb == aInfos[2][2][2] .and. cGrpTrb == aInfos[2][3][2] .and. !oModelGrp:IsDeleted()
                                 oModelGrp:DeleteLine()
                              endif
                           endif
                        endif

                     next nItens

                     nLenSWV := oModelo:length()
                     for nItens := 1 to nLenSWV

                        oModelo:goline(nItens)
                        cNCMTrb := oModelo:GetValue("WV_NCM")
                        cEXNCMTrb := oModelo:GetValue("WV_EX_NCM") 
                        cGrpTrb := oModelo:GetValue("WV_CODREG") 
                        nPosGrp := aScan( aGrpTrib, { |X| X[1] == cNCMTrb .and. X[2] == cEXNCMTrb .and. X[3] == cGrpTrb } )
                        lDeleted := oModelo:isDeleted()
                        if !lDeleted .and. nPosGrp == 0 .and. cNCMTrb == aInfos[2][1][2] .and. cEXNCMTrb == aInfos[2][2][2] .and. !(cGrpTrb == aInfos[2][3][2])
                           //if( lDeleted , oModelo:UnDeleteLine(), nil )
                           oModelo:SetValue("WV_CODREG", aInfos[2][3][2] )
                           nLine := oModelo:getLine()
                           //if( lDeleted , oModelo:DeleteLine(), nil )
                        endif

                     next nItens

                     setLoadTrb("0")
                     aSize(aGrpTrib , 0 )
                     aGrpTrib := {}

                     oModelGrp:SetNoDeleteLine(.T.)
                     oModelGrp:goline( nLineGrp )
                     oModelo:goline( nLine )
                     aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                  },;
                                 {"WV_HAWB"    , oModelo:GetValue("WV_HAWB")     },;
                                 {"WV_INVOICE" , oModelo:GetValue("WV_INVOICE")  },;
                                 {"WV_FORN"    , oModelo:GetValue("WV_FORN")     },;
                                 {"WV_FORLOJ"  , oModelo:GetValue("WV_FORLOJ")   },;
                                 {"WV_PO_NUM"  , oModelo:GetValue("WV_PO_NUM")   },;
                                 {"WV_POSICAO" , oModelo:GetValue("WV_POSICAO")  },;
                                 {"WV_SEQUENC" , oModelo:GetValue("WV_SEQUENC")  }}

                     if valtype(oView) == "O"
                        oView:Refresh("VIEW_GRP_TRIB")
                        oView:Refresh("VIEW_SWV_TRIB")
                     endif

                     oModelo:SeekLine(aSeek, .T., .T.)

                  endif 

               endif

            endif

         else

            cNCMTrb  := oModSWV:GetValue("WV_NCM")
            cEXNCMTrb:= oModSWV:GetValue("WV_EX_NCM")
            cGrpTrb  := oModSWV:GetValue("WV_CODREG")

            aSeek := { {"WV_NCM"    , cNCMTrb},;
                       {"WV_EX_NCM" , cEXNCMTrb},;
                       {"WV_CODREG" , cGrpTrb}}

            //quando não localizar a NCM, EX e código de tributação, insere no modelo
            if !oModelo:SeekLine(aSeek, .F., .T.)
               if !lFirst
                  oModelo:addLine()
               endIf
               oModelo:LoadValue("WV_NCM"   , cNCMTrb  )
               oModelo:LoadValue("WV_EX_NCM", cEXNCMTrb)
               oModelo:LoadValue("WV_CODREG", cGrpTrb  )
            endIf

         endif

         oModelo:SetNoInsertLine(lNoInsLine)
         oModelo:SetNoUpdateLine(lNoUpdLine)
         oModelo:SetNoDeleteLine(lNoDelLine)

   end case

return aDados

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aLoadCpos, aNoLoadCpos, lAddLine, aCposGrd, aIgnoreCpos)
   local nLine     := 0
   local nCpo      := 0
   local nPos      := 0
   local oStrGrd   := nil
   local lIsIgnore := .F.

   default aLoadCpos   := {}
   default aNoLoadCpos := {}
   default lAddLine    := .F.
   default aCposGrd    := {}
   default aIgnoreCpos := {}

   lIsIgnore := len(aIgnoreCpos) > 0
   nLine := oModelDet:GetLine()
   if lAddLine
      nLine := oModelDet:AddLine()
   endif

   if len(aCposGrd) == 0
      oStrGrd  := oModelDet:getStruct()
      aCposGrd := oStrGrd:GetFields()
   endif

   for nCpo := 1 to Len(aCposGrd)
      if lIsIgnore .and. aScan(aIgnoreCpos, aCposGrd[nCpo][3]) > 0
         loop
      endif

      if ( nPos := aScan(aLoadCpos,{|x|x[1] == aCposGrd[nCpo][3] }) ) > 0 .And. aScan(aNoLoadCpos,aCposGrd[nCpo][3]) == 0
         oModelDet:LoadValue( aLoadCpos[nPos][1], aLoadCpos[nPos][2] )
      else
         oModelDet:LoadValue( aCposGrd[nCpo][3] , CriaVar(aCposGrd[nCpo][3]) )
      endif
   next

return nLine

/*
Função     : getForceAtu
Objetivo   : Retorna a variavel de controle para atualização de dados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function getForceAtu()
return _lForceAtu

/*
Função     : LP500Atu
Objetivo   : Atribui a variavel de controle para atualização de dados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
function LP500Atu(lForce)
   default lForce := .F.
   _lForceAtu := lForce
return

/*
Função     : LP500GetInfo
Objetivo   : Função para retornar o valor de um determinado campo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       : Cuidado ao chamar essa função dentro de um dbseek, devido a alias ficar selecionada do parametro cAliasTb
*/
function LP500GetInfo(cAliasTb, nIndice, cKeySeek, cCampo, cIndexKey, lAlwaysSeek, cField)
   local xRet       := nil

   default cAliasTb  := ""
   default nIndice   := 0
   default cKeySeek  := ""
   default cCampo    := ""
   default cIndexKey := ""
   default lAlwaysSeek := .F.
   default cField    := ""

   if !empty(cAliasTb) .and. nIndice > 0 .and. !empty(cKeySeek) .and. !empty(cCampo)

      dbSelectArea(cAliasTb)
      cIndexKey := if( empty(cIndexKey), IndexKey(), cIndexKey) 
      if lAlwaysSeek .Or. !( cKeySeek == (cAliasTb)->&(cIndexKey) )
         if( (cAliasTb)->(IndexOrd()) == nIndice , nil , (cAliasTb)->(dbSetOrder( nIndice )) )
         (cAliasTb)->(dbSeek( cKeySeek ))
      endif

      if (cAliasTb)->(!eof())
         xRet := (cAliasTb)->&(cCampo)

         if !empty(cField)
            xRet:= AvKey(xRet, cField)
         endIf
      endif

   endif

return xRet

/*
Função     : DUIMP2310
Objetivo   : Função para validação do dicionario de dados para DUIMP release 12.1.2310
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DUIMP2310()
   local lRet := .F.

   if _DIC_22_4 == nil
      _DIC_22_4 := AvFlags("DUIMP_12.1.2310-22.4")
   endif

   lRet := _DIC_22_4

return lRet

static function EIJVERSAO()
   local lRet := .F.

   if _EIJVERSAO == nil
      _EIJVERSAO := VerCampos("EIJ", {"EIJ_VRSFOR", "EIJ_VRSFAB"} )
   endif

   lRet := _EIJVERSAO

return lRet

/*
Função     : GetFabFor
Objetivo   : Retorna dados do Fabricante/Fornecedor (EKJ) relacionado ao Catálogo de Produto
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function GetFabFor(cInfo, cIDPTCP, cVRSACP, oMdl, cCodCat)
   local cRet      := ""
   local cCnpjRaiz := ""
   local oModelEIJ := nil

   default cInfo   := ""
   default cIDPTCP := ""
   default cVRSACP := ""
   default cCodCat := ""

   do case
      case cInfo == "VERSAO"
         if !empty(cIDPTCP) .and. !empty(cVRSACP)

            if PosHistCat( getNCM(oMdl:GetModel("SWVDETAIL")), cIDPTCP, cVRSACP)
               cCodCat := EKD->EKD_COD_I

               oModelEIJ := oMdl:GetModel("EIJMASTER")
               cCnpjRaiz := Left( oModelEIJ:GetValue("EIJ_CNPJRZ" ), 8 )
               cCod := oModelEIJ:GetValue("EIJ_FABR") 
               cLoja := oModelEIJ:GetValue("EIJ_FABLOJ") 

               if PosCatOper(cCodCat, EKD->EKD_VERSAO, cCod, cLoja)
                  cRet := LP500OpEst("EKJ_VERSAO", cCnpjRaiz, cCod, cLoja)
               endif

            endif

         endif

   end case

return cRet

/*
Função     : LP500ClrSq
Objetivo   : Função para executar DelSeqDuimp
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Setembro/2022
Obs.       : 
*/
function LP500ClrSq( lPergunte )
return DelSeqDuimp( lPergunte )

/*
Função     : LP500SeqD
Objetivo   : Função para verificar se já existe sequencia da DUIMP informada
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Setembro/2021
*/
function LP500SeqD(oMdl, oModelSW9, oMdlSWV)
   local lRet       := .F.
   local aSaveLines := {}
   local nSW9       := 0
   local nSWV       := 0

   default oMdl       := FWModelActive()
   default oModelSW9  := oMdl:GetModel("SW9DETAIL")
   default oMdlSWV    := oMdl:GetModel("SWVDETAIL")

   aSaveLines := FWSaveRows()

   begin sequence

   for nSW9 := 1 To oModelSW9:length()
      oModelSW9:GoLine(nSW9)
      for nSWV := 1 To 10
         if oMdlSWV:SeekLine({{"WV_SEQDUIM",strzero(nSWV-1,1)}}, .F., .F. )
            lRet := .T.
            break
         endif
      next nSWV
   next nSW9

   end sequence

   FWRestRows(aSaveLines)

return lRet

/*
Função     : getCombo
Objetivo   : Função que retorna o array de combo de um campo
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Novembro/2022
*/
static function getCombo(cCampo)
   local aCombo     := {}

   default cCampo   := ""

   do case
      case cCampo == "EIJ_APLICM"
         aCombo := if( !empty(FWSX3Util():GetFieldStruct( "EKR_TPAPLI" )) , StrTokArr2(alltrim(getSX3Cache( "EKR_TPAPLI", "X3_CBOX")), ";") , {"1=" + STR0126, "2=" + STR0127, "3=" + STR0128, "4=" + STR0129, "5=" + STR0130}) // "Consumo" ### "Incorporação Ativo Fixo" ### "Industrialização" ### "Revenda" ### "Outra"
         aAdd( aCombo, "")
      case cCampo == "EIJ_MATUSA"
         aCombo := if( !empty(FWSX3Util():GetFieldStruct( "EKR_MATUSA" )) , StrTokArr2(alltrim(getSX3Cache( "EKR_MATUSA", "X3_CBOX")), ";") , {"1=" + STR0131, "2=" + STR0132})
         aAdd( aCombo, "")
   end case

return aCombo

function LP500retCp(cCodReg, cRetCpo, oModelSWV, cInfDef, cCpoEIJ, lRegTrib)
return retCpoTrb(cCodReg, cRetCpo, oModelSWV, cInfDef, cCpoEIJ, lRegTrib)
/*
Função     : retCpoTrb
Objetivo   : Função que retornar o campo do código de regime de tributação DUIMP
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Novembro/2022
*/
static function retCpoTrb(cCodReg, cRetCpo, oModelSWV, cInfDef, cCpoEIJ, lRegTrib)
   local cRetInf   := ""

   default cCodReg    := ""
   default cRetCpo    := ""
   default cInfDef    := ""
   default cCpoEIJ    := ""
   default lRegTrib   := avFlags("REGIME_TRIBUTACAO_DUIMP")

   if lRegTrib

      cCodReg := if( empty(cCodReg) .and. !(oModelSWV == nil) , oModelSWV:getValue("WV_CODREG"), cCodReg )
      cRetInf := if( getSX3Cache(cRetCpo, "X3_TIPO") == "C" .or. getSX3Cache(cRetCpo, "X3_TIPO") == "M", space(getSX3Cache(cRetCpo, "X3_TAMANHO")), if( getSX3Cache(cRetCpo, "X3_TIPO") == "D", ctod("") , 0 ) )

      if !empty(cCodReg)
         cRetInf := LP500GetInfo("EKR", 1, xFilial("EKR") + cCodReg, cRetCpo, "EKR_FILIAL + EKR_CODREG")
      endif

   endif

   cRetInf := if( empty(cRetInf) .and. !empty(cInfDef), cInfDef, if( empty(cRetInf) .and. !empty(cCpoEIJ), CriaVar(cCpoEIJ),  cRetInf )  ) 

return cRetInf

/*
Função     : setLoadTrb
Objetivo   : Função que armazenar a decisão ao realizar a atualização da grid de Grupo de Tributário
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
*/
static function setLoadTrb(cPergunta)
   default cPergunta := "0"
   _cPergTrb := cPergunta
return 

/*
Função     : getLoadTrb
Objetivo   : Função que retornar a decisão ao realizar a atualização da grid de Grupo de Tributário
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Fevereiro/2023
*/
static function getLoadTrb()
return _cPergTrb

/*/{Protheus.doc} SetTmpTable
   Fecha/Apaga os arquivos temporarios criados no banco de dados

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetTmpTable()
   local cAliasTmp := ""
   local aSemSX3   := {}
   local aIndex    := {}

   if existFunc("EasyTemporaryTable") .and. existFunc("EasySXB")

      _oEasyTmp := EasyTemporaryTable():new()

      cAliasTmp := LP500_EKD
      aSemSX3 := {}
      aAdd(aSemSX3, {"EKD_IDPORT", getSX3Cache("EKD_IDPORT", "X3_TIPO"), getSX3Cache("EKD_IDPORT", "X3_TAMANHO"), getSX3Cache("EKD_IDPORT", "X3_DECIMAL") })
      aAdd(aSemSX3, {"EKD_VATUAL", getSX3Cache("EKD_VATUAL", "X3_TIPO"), getSX3Cache("EKD_VATUAL", "X3_TAMANHO"), getSX3Cache("EKD_VATUAL", "X3_DECIMAL") })
      aAdd(aSemSX3, {"EKE_PRDREF", getSX3Cache("EKE_PRDREF", "X3_TIPO"), getSX3Cache("EKE_PRDREF", "X3_TAMANHO"), getSX3Cache("EKE_PRDREF", "X3_DECIMAL") })
      aAdd(aSemSX3, {"EKE_DESC_I", getSX3Cache("EKE_DESC_I", "X3_TIPO"), getSX3Cache("EKE_DESC_I", "X3_TAMANHO"), getSX3Cache("EKE_DESC_I", "X3_DECIMAL") })
      aIndex := {}
      aAdd(aIndex, "EKD_IDPORT+EKD_VATUAL+EKE_PRDREF" )
      _oEasyTmp:setData(nil, aSemSX3, cAliasTmp, aIndex)

   endif

return

/*/{Protheus.doc} EraseTmpTable
   Fecha/Apaga os arquivos temporarios criados no banco de dados

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function EraseTmpTable()
   if _oEasyTmp <> nil
      _oEasyTmp:destroy()
      FwFreeObj(_oEasyTmp)
   endif
return

/*/{Protheus.doc} LP500F3EKD
   Funcão para consulta específica do catalogo de produto

   @type  Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
function LP500F3EKD()
   local lRet       := .F.
   local cAliasTmp  := LP500_EKD
   local oF3Catal   := nil

   if _oEasyTmp <> nil

      loadCatalogo()

      oF3Catal := EasySXB():New()
      lRet := oF3Catal:ViewSXB(STR0139,cAliasTmp) // "Catalogo de Produto"
      //FwFreeObj(oF3Catal)

   endif

return lRet

/*/{Protheus.doc} LP500RetF3
   Funcão para o retorno consulta específica do catalogo de produto

   @type  Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
function LP500RetF3()
   local oModel     := nil
   local oModelEIJ  := nil
   local cCatalogo  := ""
   local cAliasTmp  := LP500_EKD

   if (cAliasTmp)->(!eof())
      cCatalogo := (cAliasTmp)->EKD_IDPORT
      oModel := FWModelActive()
      oModelEIJ := oModel:getModel("EIJMASTER")
      oModelEIJ:loadValue("EIJ_VRSACP", (cAliasTmp)->EKD_VATUAL)
   endif

return cCatalogo

/*/{Protheus.doc} loadCatalogo
   Funcão para carregar a tabela temporaria da consulta padrão

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadCatalogo()
   local cAliasTmp  := LP500_EKD
   local cAliasQry  := ""

   cAliasQry := getNextAlias()
   getCatalogo(cAliasQry)

   // Realiza a limpeza ou criação do arquivo temporario
   _oEasyTmp:ClearTmp(cAliasTmp)

   (cAliasQry)->(dbGoTop())
   while (cAliasQry)->(!eof())
      reclock(cAliasTmp, .T.)
      (cAliasTmp)->EKD_IDPORT := (cAliasQry)->EKD_IDPORT
      (cAliasTmp)->EKD_VATUAL := (cAliasQry)->EKD_VATUAL
      (cAliasTmp)->EKE_PRDREF := (cAliasQry)->EKE_PRDREF
      (cAliasTmp)->EKE_DESC_I := (cAliasQry)->EKE_DESC_I
      (cAliasTmp)->(msUnLock())
      (cAliasQry)->(dbSkip())
   end

   (cAliasQry)->(dbCloseArea())

return

/*/{Protheus.doc} getCatalogo
   Funcão para realizar a query dos catalogos de produtos

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function getCatalogo(cAliasQry)
   local oModel     := nil
   local oModelEIJ  := nil
   local oModelSWV  := nil
   local cCnpjRaiz  := ""
   local cNCM       := ""
   local cQuery     := ""
   local oQuery     := nil
   local aQryInfos  := {}
   local nInfo      := 0
   local lMultiFil  := CP400MultF()

   default cAliasQry := getNextAlias()

   oModel := FWModelActive()
   oModelEIJ := oModel:GetModel("EIJMASTER")
   oModelSWV := oModel:GetModel("SWVDETAIL")

   cCnpjRaiz := Left( oModelEIJ:GetValue("EIJ_CNPJRZ" ), 8 )
   cNCM := getNCM(oModelSWV)

   cQuery := " SELECT EKD.EKD_IDPORT, EKD.EKD_VATUAL, EKE.EKE_PRDREF, EKE.EKE_DESC_I "
   if lMultiFil
      cQuery += ", EKE.EKE_FILORI"
   endif
   cQuery += " FROM " + RetSqlName('EKD') + " EKD "
   cQuery += " INNER JOIN " + RetSqlName('EK9') + " EK9 ON EK9.D_E_L_E_T_ = ' ' AND EK9.EK9_FILIAL = ? AND EK9.EK9_COD_I = EKD.EKD_COD_I AND EK9.EK9_MSBLQL <> '1' "
   cQuery += " LEFT JOIN " + RetSqlName('EKE') + " EKE ON EKE.D_E_L_E_T_ = ' ' AND EKE.EKE_FILIAL = EKD.EKD_FILIAL AND EKE.EKE_COD_I = EKD.EKD_COD_I "
   if lMultiFil
      cQuery += " AND EKE.EKE_FILORI = ? "
   endif
   cQuery += " WHERE EKD.D_E_L_E_T_ = ' ' AND EKD.EKD_IDPORT <> ' ' AND EKD.EKD_VATUAL <> ' ' "
   cQuery += " AND (EKD.EKD_STATUS = '1' OR EKD.EKD_STATUS = '5' OR EKD.EKD_STATUS = '6') "

   aQryInfos := {} 

   aAdd( aQryInfos , xFilial('EK9'))
   if lMultiFil
      aAdd( aQryInfos , xFilial('SB1'))
   endif
   aAdd( aQryInfos , xFilial('EKD'))
   cQuery += " AND EKD.EKD_FILIAL = ? "

   aAdd( aQryInfos , "1")
   cQuery += " AND EKD.EKD_MODALI = ? "

   aAdd( aQryInfos , cCnpjRaiz)
   cQuery += " AND EKD.EKD_CNPJ = ? "

   aAdd( aQryInfos , cNCM)
   cQuery += " AND EKD.EKD_NCM = ? "

   cQuery += " GROUP BY EKD.EKD_IDPORT, EKD.EKD_VATUAL, EKE.EKE_PRDREF, EKE.EKE_DESC_I " 
   if lMultiFil
      cQuery += ", EKE.EKE_FILORI "
   endif

   cQuery += " ORDER BY EKD.EKD_IDPORT, EKD.EKD_VATUAL, EKE.EKE_PRDREF "
   if lMultiFil
      cQuery += ", EKE.EKE_FILORI "
   endif

   oQuery := FWPreparedStatement():New(cQuery)
   for nInfo := 1 to len(aQryInfos)
      oQuery:SetString( nInfo , aQryInfos[nInfo] )
   next
   cQuery := oQuery:GetFixQuery()

   MPSysOpenQuery(cQuery, cAliasQry)
 
   fwFreeObj(oQuery)

return

/*/{Protheus.doc} VldCatProd
   Funcão para validação de catalogo de produto

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return lRet, logico, .T. ok / .F. deu erro
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldCatProd(cCampo, cNCM, cIdPortal, cVersao, cOldVersao)
   local lRet       := .T.
   local lSeekEKD   := .F.
   local cDscStatus := ""

   default cNCM      := ""
   default cIdPortal := ""
   default cVersao   := ""
   default cOldVersao:= ""

   if !empty(cIdPortal)

      if cCampo == "EIJ_IDPTCP"

         lRet := ExistCpo("EK9", cNCM + cIdPortal, 2)
         if lRet

            EK9->(dbSetOrder(2))
            EK9->(dbSeek(xFilial("EK9") + cNCM + cIdPortal))
            // Valida a modalidade do catalogo:
            if !(EK9->EK9_MODALI == "1")
               EasyHelp(STR0140, STR0003, STR0141) // "A modalidade do catálogo de produto é inválida para o processo." #### "A modalidade do catálogo de produto deverá ser igual a 'Importação'."
               lRet := .F.
            endif

            // Valida a raiz do Importador com o catalogo:
            if lRet .and. !( EK9->EK9_CNPJ == Left( POSICIONE("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC") ,8 ) )
               EasyHelp( StrTran(STR0142, "XXXX", EK9->EK9_CNPJ) , STR0003, STR0143) // "A raiz do CNPJ do declarante (XXXX) do catalogo de produto é diferente da raiz do CNPJ do importador do processo." ### "Somente é possível utilizar catálogo de produto, onde possui a mesma raiz do CNPJ do importador."
               lRet := .F.
            endif

            if lRet .and. !empty(cVersao)
               lRet := VldCatProd("EIJ_VRSACP", cNCM, cIdPortal, cVersao, cOldVersao)
            endif

         endif 

      elseif cCampo == "EIJ_VRSACP"

         // Quando o sistema está atualizado, esta sendo posicionado na versão digitada EKD_VATUAL.
         lSeekEKD := !empty(cIdPortal) .and. PosHistCat(cNCM, cIdPortal, cVersao)
         if lSeekEKD
            // Valida se esta trocando a versão do catalogo para uma inválida
            if lRet .and. !(EKD->EKD_STATUS $ "1|5|6") .And. cVersao != cOldVersao
               cDscStatus := alltrim(CP400CBSta("EKD_STATUS", "1"))
               cDscStatus += ", " + alltrim(CP400CBSta("EKD_STATUS", "5"))
               cDscStatus += " " + STR0144 + " " + alltrim(CP400CBSta("EKD_STATUS", "6")) // "ou"
               EasyHelp( StrTran( STR0145, "XXXX", alltrim(CP400CBSta("EKD_STATUS", EKD->EKD_STATUS)) ), STR0003, StrTran(STR0146, "XXXX", cDscStatus) ) // "Status do catálogo de produto informado está como 'XXXX'." ### "Somente é possível utilizar catálogo de produto com status: XXXX."
               lRet := .F.
            endif

         else
            EasyHelp(StrTran( STR0147, "XXXX", alltrim(cNcm) ), STR0003, STR0148) // "Não foi encontrado o catálogo de produto para a NCM 'XXXX'." ### "Revise os dados do ID e a versão do Catalogo de Produtos informado."
            lRet := .F.

         endif 

      endif

   endif

return lRet

/*/{Protheus.doc} SetOrdEKD
   Funcão para ordenar a tabela EKD de acordo com a atualização

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param nenhum
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetOrdEKD(lDUIMP23_3)
   default lDUIMP23_3 :=  AvFlags("DUIMP_12.1.2310-23.3")

   if( lDUIMP23_3 , EKD->(DbSetOrder(4)) , EKD->(DbSetOrder(2)) )
   //EKD->(DbSetOrder(4)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VATUAL
   //EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO

return

/*/{Protheus.doc} PosHistCat
   Função para posicionar no historico do catalogo de produto

   @type  Static Function
   @author user
   @since 04/02/2025
   @version version
   @param cParNcm, caractere, ncm do produto - WV_NCM
          cParIdPort, caractere, id do portal - EIJ_IDPORT
          cParVersao, caractere, versão do catalogo - EIJ_VRSACP
   @
Return lRet, logico, .t. se encontrou a ultima sequencia da versão
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function PosHistCat(cParNcm, cParIdPort, cParVersao)
   local lRet       := .F.
   local lDUIMP23_3 :=  AvFlags("DUIMP_12.1.2310-23.3")

   SetOrdEKD(lDUIMP23_3)
   if EKD->(DbSeek( xFilial("EKD") + cParNcm + cParIdPort + cParVersao ))
      while EKD->(!Eof()) .and. EKD->EKD_NCM == cParNcm .and. EKD->EKD_IDPORT == cParIdPort .and. if( lDUIMP23_3, EKD->EKD_VATUAL == cParVersao, EKD->EKD_VERSAO == cParVersao) 
         if EKD->EKD_STATUS $ "1|5|6" // "Integrado" ou "Integrado (pendente: fabricante/país)" ou "Registrado Manualmente"
            lRet := .T.
            exit
         endif
         EKD->(DbSkip())
      end
   endif


Return lRet

/*/{Protheus.doc} IsExecAuto
   Funcão para indicar se está sendo via execauto ou não

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param oView, objeto, objeto da view
   @return nenhum
/*/
static function IsExecAuto(lView, oView)
   local lExecAuto := .F.

   default lView := .T.
   default oView := FWViewActive()

   lExecAuto := isBlind() .or. if( lView, oView == nil, .F.)

return lExecAuto

/*/{Protheus.doc} SetCposEIJ
   Atualiza as configurações dos campos para a tabela EIJ

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param oStruEIJ, objeto, modelo de dados
          cModelo, caractere, nome do modelo de dados
   @return nenhum
/*/
static function SetCposEIJ(oStruEIJ, cModelo, lTribDUIMP)
   default cModelo    := ""
   default lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

   do case 
      case cModelo == "EIJMASTER_II"
         oStruEIJ:SetProperty('EIJ_REGTRI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REGTRI")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_TPAII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAII" )'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_ALI_II'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALI_II")'    )) //Monta When diferente do dicionário

         if lTribDUIMP
            oStruEIJ:SetProperty('EIJ_REGTRI' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
            oStruEIJ:SetProperty('EIJ_ALR_II' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALR_II")'    )) //Monta When diferente do dicionário

            oStruEIJ:AddTrigger("EIJ_FUNII" , "EIJ_FUNII" ,, {|oModel| LP500Gatil("EIJ_FUNII" ,,,, "EIJ_FUNII")} )
            oStruEIJ:AddTrigger("EIJ_FUNII" , "EIJ_DSCFL1",, {|oModel| LP500Gatil("EIJ_FUNII" ,,,, "EIJ_DSCFL1")} )
            oStruEIJ:AddTrigger("EIJ_FUNII" , "EIJ_REGTRI",, {|oModel| LP500Gatil("EIJ_FUNII" ,,,, "EIJ_REGTRI")} )
            oStruEIJ:AddTrigger("EIJ_REGTRI", "EIJ_REGTRI",, {|oModel| LP500Gatil("EIJ_REGTRI",,,, "EIJ_REGTRI")} )
            oStruEIJ:AddTrigger("EIJ_REGTRI", "EIJ_DSCRG1",, {|oModel| LP500Gatil("EIJ_REGTRI",,,, "EIJ_DSCRG1")} )
            oStruEIJ:AddTrigger("EIJ_REGTRI", "EIJ_ALR_II",, {|oModel| LP500Gatil("EIJ_REGTRI",,,, "EIJ_ALR_II")} )
            oStruEIJ:AddTrigger("EIJ_TPAII" , "EIJ_TPAII" ,, {|oModel| LP500Gatil("EIJ_TPAII")} )
            oStruEIJ:AddTrigger("EIJ_ALR_II", "EIJ_ALR_II",, {|oModel| LP500Gatil("EIJ_ALR_II")} )
         else
            oStruEIJ:SetProperty('EIJ_FUNREG'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FUNREG")'    )) //Monta When diferente do dicionário
            oStruEIJ:AddTrigger("EIJ_FUNREG", "EIJ_FUNREG",, {|oModel| LP500Gatil("EIJ_FUNREG")} )
            oStruEIJ:AddTrigger("EIJ_REGTRI", "EIJ_REGTRI",, {|oModel| LP500Gatil("EIJ_REGTRI")} )
         endif
         oStruEIJ:SetProperty('EIJ_TPAII', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
         oStruEIJ:AddTrigger("EIJ_ALI_II", "EIJ_ALI_II",, {|oModel| LP500Gatil("EIJ_ALI_II")} )

      case cModelo == "EIJMASTER_IPI"
         oStruEIJ:SetProperty('EIJ_REGIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REGIPI")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_TPAIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAIPI")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_ALAIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALAIPI")'    )) //Monta When diferente do dicionário

         if lTribDUIMP
            oStruEIJ:SetProperty("EIJ_ALRIPI" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALRIPI")'    )) //Monta When diferente do dicionário
            oStruEIJ:SetProperty("EIJ_ALUIPI" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALUIPI")'    )) //Monta When diferente do dicionário
            oStruEIJ:SetProperty("EIJ_QTUIPI" , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_QTUIPI")'    )) //Monta When diferente do dicionário

            oStruEIJ:SetProperty("EIJ_REGIPI" , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)")) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
            oStruEIJ:SetProperty("EIJ_REGIPI", MODEL_FIELD_VALUES , {})
            oStruEIJ:AddTrigger("EIJ_FUNIPI", "EIJ_FUNIPI",, {|oModel| LP500Gatil("EIJ_FUNIPI" ,,,, "EIJ_FUNIPI")} )
            oStruEIJ:AddTrigger("EIJ_FUNIPI", "EIJ_DSCFL2",, {|oModel| LP500Gatil("EIJ_FUNIPI" ,,,, "EIJ_DSCFL2")} )
            oStruEIJ:AddTrigger("EIJ_FUNIPI", "EIJ_REGIPI",, {|oModel| LP500Gatil("EIJ_FUNIPI" ,,,, "EIJ_REGIPI")} )
            oStruEIJ:AddTrigger("EIJ_REGIPI", "EIJ_REGIPI",, {|oModel| LP500Gatil("EIJ_REGIPI" ,,,, "EIJ_REGIPI")} )
            oStruEIJ:AddTrigger("EIJ_REGIPI", "EIJ_DSCRG2",, {|oModel| LP500Gatil("EIJ_REGIPI" ,,,, "EIJ_DSCRG2")} )
            oStruEIJ:AddTrigger("EIJ_REGIPI", "EIJ_ALRIPI",, {|oModel| LP500Gatil("EIJ_REGIPI" ,,,, "EIJ_ALRIPI")} )
            oStruEIJ:AddTrigger("EIJ_TPAIPI", "EIJ_TPAIPI",, {|oModel| LP500Gatil("EIJ_TPAIPI" ,,,, "EIJ_TPAIPI")} )
            oStruEIJ:AddTrigger("EIJ_TPAIPI", "EIJ_ALRIPI",, {|oModel| LP500Gatil("EIJ_TPAIPI" ,,,, "EIJ_ALRIPI")} )
            oStruEIJ:AddTrigger("EIJ_TPAIPI", "EIJ_ALUIPI",, {|oModel| LP500Gatil("EIJ_TPAIPI" ,,,, "EIJ_ALUIPI")} )
            oStruEIJ:AddTrigger("EIJ_TPAIPI", "EIJ_QTUIPI",, {|oModel| LP500Gatil("EIJ_TPAIPI" ,,,, "EIJ_QTUIPI")} )
            oStruEIJ:AddTrigger("EIJ_TPAIPI", "EIJ_ALAIPI",, {|oModel| LP500Gatil("EIJ_TPAIPI" ,,,, "EIJ_ALAIPI")} )
            oStruEIJ:AddTrigger("EIJ_ALRIPI", "EIJ_ALRIPI",, {|oModel| LP500Gatil("EIJ_ALRIPI")} )
            oStruEIJ:AddTrigger("EIJ_ALUIPI", "EIJ_ALUIPI",, {|oModel| LP500Gatil("EIJ_ALUIPI")} )
            oStruEIJ:AddTrigger("EIJ_QTUIPI", "EIJ_QTUIPI",, {|oModel| LP500Gatil("EIJ_QTUIPI")} )
         else
            oStruEIJ:SetProperty('EIJ_ASSIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ASSIPI")'    )) //Monta When diferente do dicionário
            oStruEIJ:AddTrigger("EIJ_ASSIPI", "EIJ_ASSIPI",, {|oModel| LP500Gatil("EIJ_ASSIPI")} )
            oStruEIJ:AddTrigger("EIJ_REGIPI", "EIJ_REGIPI",, {|oModel| LP500Gatil("EIJ_REGIPI")} )
         endif
         oStruEIJ:SetProperty('EIJ_TPAIPI', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
         oStruEIJ:AddTrigger("EIJ_ALAIPI", "EIJ_ALAIPI",, {|oModel| LP500Gatil("EIJ_ALAIPI")} )

      case cModelo == "EIJMASTER_PISCOFINS"
         oStruEIJ:SetProperty('EIJ_REG_PC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REG_PC")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_FUN_PC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FUN_PC")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_TPAPIS'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAPIS")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_ALAPIS'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALAPIS")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_TPACOF'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPACOF")'    )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty('EIJ_ALACOF'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALACOF")'    )) //Monta When diferente do dicionário

         oStruEIJ:AddTrigger("EIJ_REG_PC", "EIJ_REG_PC",, {|oModel| LP500Gatil("EIJ_REG_PC")} )
         oStruEIJ:AddTrigger("EIJ_FUN_PC", "EIJ_FUN_PC",, {|oModel| LP500Gatil("EIJ_FUN_PC")} )
         oStruEIJ:AddTrigger("EIJ_ALAPIS", "EIJ_ALAPIS",, {|oModel| LP500Gatil("EIJ_ALAPIS")} )
         oStruEIJ:AddTrigger("EIJ_ALACOF", "EIJ_ALACOF",, {|oModel| LP500Gatil("EIJ_ALACOF")} )

         // Mesmo a função LP500VALID não está tratando esses campos, foi inserido para evitar erro na rotina automatica e esses campos via tela estão não editáveis.
         oStruEIJ:SetProperty('EIJ_TPACOF', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )   
         oStruEIJ:SetProperty('EIJ_TPAPIS', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )      

      case cModelo == "EIJMASTER_PIS"
         oStruEIJ:SetProperty("EIJ_TPAPIS", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAPIS")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALAPIS", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALAPIS")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_REDPIS", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REDPIS")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALUPIS", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALUPIS")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_QTUPIS", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_QTUPIS")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALPISM", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALPISM")' )) //Monta When diferente do dicionário

         oStruEIJ:SetProperty("EIJ_TPAPIS", MODEL_FIELD_VALUES , {"1=" + STR0157, "2=" + STR0159, "" } ) // "Ad Valorem" ### "Específica"

         oStruEIJ:AddTrigger("EIJ_FUNPIS", "EIJ_FUNPIS",, {|oModel| LP500Gatil("EIJ_FUNPIS",,,, "EIJ_FUNPIS")} )
         oStruEIJ:AddTrigger("EIJ_FUNPIS", "EIJ_DSCFL3",, {|oModel| LP500Gatil("EIJ_FUNPIS",,,, "EIJ_DSCFL3")} )
         oStruEIJ:AddTrigger("EIJ_FUNPIS", "EIJ_REGPIS",, {|oModel| LP500Gatil("EIJ_FUNPIS",,,, "EIJ_REGPIS")} )
         oStruEIJ:AddTrigger("EIJ_REGPIS", "EIJ_REGPIS",, {|oModel| LP500Gatil("EIJ_REGPIS",,,, "EIJ_REGPIS")} )
         oStruEIJ:AddTrigger("EIJ_REGPIS", "EIJ_DSCRG3",, {|oModel| LP500Gatil("EIJ_REGPIS",,,, "EIJ_DSCRG3")} )
         oStruEIJ:AddTrigger("EIJ_REGPIS", "EIJ_REDPIS",, {|oModel| LP500Gatil("EIJ_REGPIS",,,, "EIJ_REDPIS")} )
         oStruEIJ:AddTrigger("EIJ_TPAPIS", "EIJ_TPAPIS",, {|oModel| LP500Gatil("EIJ_TPAPIS",,,, "EIJ_TPAPIS")} )
         oStruEIJ:AddTrigger("EIJ_TPAPIS", "EIJ_REDPIS",, {|oModel| LP500Gatil("EIJ_TPAPIS",,,, "EIJ_REDPIS")} )
         oStruEIJ:AddTrigger("EIJ_TPAPIS", "EIJ_ALUPIS",, {|oModel| LP500Gatil("EIJ_TPAPIS",,,, "EIJ_ALUPIS")} )
         oStruEIJ:AddTrigger("EIJ_TPAPIS", "EIJ_QTUPIS",, {|oModel| LP500Gatil("EIJ_TPAPIS",,,, "EIJ_QTUPIS")} )
         oStruEIJ:AddTrigger("EIJ_TPAPIS", "EIJ_ALAPIS",, {|oModel| LP500Gatil("EIJ_TPAPIS",,,, "EIJ_ALAPIS")} )
         oStruEIJ:AddTrigger("EIJ_ALAPIS", "EIJ_ALAPIS",, {|oModel| LP500Gatil("EIJ_ALAPIS")} )
         oStruEIJ:AddTrigger("EIJ_REDPIS", "EIJ_REDPIS",, {|oModel| LP500Gatil("EIJ_REDPIS")} )
         oStruEIJ:AddTrigger("EIJ_ALUPIS", "EIJ_ALUPIS",, {|oModel| LP500Gatil("EIJ_ALUPIS")} )
         oStruEIJ:AddTrigger("EIJ_QTUPIS", "EIJ_QTUPIS",, {|oModel| LP500Gatil("EIJ_QTUPIS")} )
         oStruEIJ:AddTrigger("EIJ_ALPISM", "EIJ_ALPISM",, {|oModel| LP500Gatil("EIJ_ALPISM")} )

         oStruEIJ:SetProperty("EIJ_TPAPIS", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)" )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
         oStruEIJ:SetProperty("EIJ_REGPIS", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)" )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

      case cModelo == "EIJMASTER_COFINS"
         oStruEIJ:SetProperty("EIJ_TPACOF", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPACOF")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALACOF", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALACOF")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_REDCOF", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REDCOF")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALUCOF", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALUCOF")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_QTUCOF", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_QTUCOF")' )) //Monta When diferente do dicionário
         oStruEIJ:SetProperty("EIJ_ALCOFM", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALCOFM")' )) //Monta When diferente do dicionário

         oStruEIJ:SetProperty("EIJ_TPACOF", MODEL_FIELD_VALUES , {"1=" + STR0157, "2=" + STR0159, "" } ) // "Ad Valorem" ### "Específica"

         oStruEIJ:AddTrigger("EIJ_FUNCOF", "EIJ_FUNCOF",, {|oModel| LP500Gatil("EIJ_FUNCOF",,,, "EIJ_FUNCOF")} )
         oStruEIJ:AddTrigger("EIJ_FUNCOF", "EIJ_DSCFL4",, {|oModel| LP500Gatil("EIJ_FUNCOF",,,, "EIJ_DSCFL4")} )
         oStruEIJ:AddTrigger("EIJ_FUNCOF", "EIJ_REGCOF",, {|oModel| LP500Gatil("EIJ_FUNCOF",,,, "EIJ_REGCOF")} )
         oStruEIJ:AddTrigger("EIJ_REGCOF", "EIJ_REGCOF",, {|oModel| LP500Gatil("EIJ_REGCOF",,,, "EIJ_REGCOF")} )
         oStruEIJ:AddTrigger("EIJ_REGCOF", "EIJ_DSCRG4",, {|oModel| LP500Gatil("EIJ_REGCOF",,,, "EIJ_DSCRG4")} )
         oStruEIJ:AddTrigger("EIJ_REGCOF", "EIJ_REDCOF",, {|oModel| LP500Gatil("EIJ_REGCOF",,,, "EIJ_REDCOF")} )
         oStruEIJ:AddTrigger("EIJ_TPACOF", "EIJ_TPACOF",, {|oModel| LP500Gatil("EIJ_TPACOF",,,, "EIJ_TPACOF")} )
         oStruEIJ:AddTrigger("EIJ_TPACOF", "EIJ_REDCOF",, {|oModel| LP500Gatil("EIJ_TPACOF",,,, "EIJ_REDCOF")} )
         oStruEIJ:AddTrigger("EIJ_TPACOF", "EIJ_ALUCOF",, {|oModel| LP500Gatil("EIJ_TPACOF",,,, "EIJ_ALUCOF")} )
         oStruEIJ:AddTrigger("EIJ_TPACOF", "EIJ_QTUCOF",, {|oModel| LP500Gatil("EIJ_TPACOF",,,, "EIJ_QTUCOF")} )
         oStruEIJ:AddTrigger("EIJ_TPACOF", "EIJ_ALACOF",, {|oModel| LP500Gatil("EIJ_TPACOF",,,, "EIJ_ALACOF")} )
         oStruEIJ:AddTrigger("EIJ_ALACOF", "EIJ_ALACOF",, {|oModel| LP500Gatil("EIJ_ALACOF")} )
         oStruEIJ:AddTrigger("EIJ_REDCOF", "EIJ_REDCOF",, {|oModel| LP500Gatil("EIJ_REDCOF")} )
         oStruEIJ:AddTrigger("EIJ_ALUCOF", "EIJ_ALUCOF",, {|oModel| LP500Gatil("EIJ_ALUCOF")} )
         oStruEIJ:AddTrigger("EIJ_QTUCOF", "EIJ_QTUCOF",, {|oModel| LP500Gatil("EIJ_QTUCOF")} )
         oStruEIJ:AddTrigger("EIJ_ALCOFM", "EIJ_ALCOFM",, {|oModel| LP500Gatil("EIJ_ALCOFM")} )

         oStruEIJ:SetProperty("EIJ_TPACOF", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)" )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
         oStruEIJ:SetProperty("EIJ_REGCOF", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)" )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

      case cModelo == "EIJMASTER_ANTIDUMPING"
         oStruEIJ:SetProperty("EIJ_TPADUM", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPADUM")' ))
         oStruEIJ:SetProperty("EIJ_ALADDU", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALADDU")' ))
         oStruEIJ:SetProperty("EIJ_BAE_AD", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_BAE_AD")' ))
         oStruEIJ:SetProperty("EIJ_ALEADU", MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALEADU")' ))
         oStruEIJ:SetProperty("EIJ_TPADUM", MODEL_FIELD_VALUES , {"1=" + STR0157, "2=" + STR0159, "3=" + STR0160, "" } ) // "Ad Valorem" #### "Específica" #### "Mista"

         oStruEIJ:AddTrigger("EIJ_FUNADU", "EIJ_FUNADU",, {|oModel| LP500Gatil("EIJ_FUNADU",,,, "EIJ_FUNADU")} )
         oStruEIJ:AddTrigger("EIJ_FUNADU", "EIJ_DSCFL5",, {|oModel| LP500Gatil("EIJ_FUNADU",,,, "EIJ_DSCFL5")} )
         oStruEIJ:AddTrigger("EIJ_TPADUM", "EIJ_TPADUM",, {|oModel| LP500Gatil("EIJ_TPADUM",,,, "EIJ_TPADUM")} )
         oStruEIJ:AddTrigger("EIJ_TPADUM", "EIJ_BAE_AD",, {|oModel| LP500Gatil("EIJ_TPADUM",,,, "EIJ_BAE_AD")} )
         oStruEIJ:AddTrigger("EIJ_TPADUM", "EIJ_ALEADU",, {|oModel| LP500Gatil("EIJ_TPADUM",,,, "EIJ_ALEADU")} )
         oStruEIJ:AddTrigger("EIJ_TPADUM", "EIJ_ALADDU",, {|oModel| LP500Gatil("EIJ_TPADUM",,,, "EIJ_ALADDU")} )
         oStruEIJ:AddTrigger("EIJ_ALADDU", "EIJ_ALADDU",, {|oModel| LP500Gatil("EIJ_ALADDU")} )
         oStruEIJ:AddTrigger("EIJ_BAE_AD", "EIJ_BAE_AD",, {|oModel| LP500Gatil("EIJ_BAE_AD")} )
         oStruEIJ:AddTrigger("EIJ_ALEADU", "EIJ_ALEADU",, {|oModel| LP500Gatil("EIJ_ALEADU")} )

         oStruEIJ:SetProperty("EIJ_TPADUM", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "LP500VALID(b,a,c,d)" )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

      case cModelo == "EIJMASTER_ICMS"
         oStruEIJ:SetProperty('EIJ_OPERAC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_OPERAC")'    )) //Monta When diferente do dicionário

         oStruEIJ:AddTrigger("EIJ_OPERAC", "EIJ_OPERAC",, {|oModel| LP500Gatil("EIJ_OPERAC")} )

   end case

return

/*/{Protheus.doc} SetCposSWV
   Atualiza as configurações dos campos para a tabela SWV

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param oStruSWV, objeto, modelo de dados
          lForce, logico, se força a atualização ou não
   @return nenhum
/*/
static function SetCposSWV(oStruSWV, lForce)
   default lForce  := .T.

   // Atualizar essas configurações quando for rotina automática, pois o modelo de dados 'EIJMASTER_II' não é instanciado e o commit está tudo baseado no modelo de dados 'EIJMASTER
   // assim como o X3_VALID ou X3_WHEN possuem a validação DI_VAL_EIJ, passando como parametro uma variavel X, mas na rotina automatica essa variavel não esta sendo declarada
   if lForce .or. IsExecAuto(.F.)
      if avFlags("REGIME_TRIBUTACAO_DUIMP")
         oStruSWV:AddTrigger("WV_CODREG", "WV_CODREG",, {|oModel| LP500Gatil("WV_CODREG")} )
      endif
   endif

return

/*/{Protheus.doc} getModEIJ
   Retorna o modelo de dados, devido para rotina automaticas não existir os modelos 
      EIJMASTER_II
      EIJMASTER_IPI
      EIJMASTER_PISCOFINS
      EIJMASTER_ICMS
      EIJMASTER_PIS
      EIJMASTER_COFINS
      EIJMASTER_ANTIDUMPING
   Somente irá existir EIJMASTER, por questão de performance.

   @type  Static Function
   @author bruno kubagawa
   @since 25/04/2023
   @version 1.0
   @param oModelo, objeto, modelo de dados
          cModelo, caractere, nome do modelo de dados
   @return cRetMod, caractere, modelo de dado EIJMASTER ou o que recebeu de parametro
/*/
static function getModEIJ(oModel, cModelo)
   local oRetMod := nil

   default cModelo := ""

   oRetMod := oModel:getModel():GetModel(cModelo)
   if oRetMod == nil
      oRetMod := oModel:getModel():GetModel("EIJMASTER")
   endif

return oRetMod

/*/{Protheus.doc} loadEmpty
   Inicializa o campo de acordo com seu tipo

   @type  Static Function
   @author user
   @since 10/06/2024
   @version version
   @param cCampo, caractere, campo
   @return xRet, undefined, retorna o conteúdo
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadEmpty(cCampo)
   local xRet       := nil
   local cTipo      := ""

   cTipo := GetSx3Cache(cCampo, "X3_TIPO")
   xRet := if( cTipo == "N", 0, if( cTipo == "D", ctod(""), "" ))

return xRet

/*/{Protheus.doc} SetModPIS
   Cria a instância da Model para a tabela EIJ ( PIS )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   @review: Separação do modelo da EKW para fundamentos legais e tributação
/*/
static function SetModPIS(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_PIS"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_PIS")

   oModel:AddFields('EIJMASTER_PIS', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_PIS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_PIS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )
   

return nil

/*/{Protheus.doc} SetModCOF
   Cria a instância da Model para a tabela EIJ ( COFINS )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   @review: Separação do modelo da EKW para fundamentos legais e tributação
/*/
static function SetModCOF(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_COFINS"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_COFINS")

   oModel:AddFields('EIJMASTER_COFINS', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_COFINS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_COFINS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*/{Protheus.doc} SetModADU
   Cria a instância da Model para a tabela EIJ ( ANTIDUMPING )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   @review: Separação do modelo da EKW para fundamentos legais e tributação
/*/
static function SetModADU(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_ANTIDUMPING"), "|")) })

   SetCposEIJ(@oStruEIJ, "EIJMASTER_ANTIDUMPING")

   oModel:AddFields('EIJMASTER_ANTIDUMPING', "SWVDETAIL", oStruEIJ)

   oModel:GetModel("EIJMASTER_ANTIDUMPING"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_ANTIDUMPING', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*/{Protheus.doc} SetPISView
   Cria a instância da View para a tabela EIJ ( PIS )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetPISView(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.
   local oStrEKWPIS

   if lDuimpInt
      lCpos := DUIMP2310()
   endif
   
   aCampos := {}
   if !avFlags('FUNDAMENTO_LEGAL_ITEM')          
      aAdd( aCampos, {"EIJ_FUNPIS","01"} )
      aAdd( aCampos, {"EIJ_DSCFL3","01"} )
   endIf   
   aAdd( aCampos, {"EIJ_REGPIS","02"} )
   aAdd( aCampos, {"EIJ_DSCRG3","02"} )
   aAdd( aCampos, {"EIJ_TPAPIS","03"} )
   aAdd( aCampos, {"EIJ_ALAPIS","03"} )
   aAdd( aCampos, {"EIJ_REDPIS","03"} )
   aAdd( aCampos, {"EIJ_ALUPIS","03"} )
   aAdd( aCampos, {"EIJ_QTUPIS","03"} )
   aAdd( aCampos, {"EIJ_ALPISM","03"} )

   if lCpos
      aAdd( aCampos, {"EIJ_VLCPIS" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDPIS" ,"04"} )
      aAdd( aCampos, {"EIJ_VDEPIS" ,"04"} )
      aAdd( aCampos, {"EIJ_VLSPIS" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCPIS" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   if !avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("01", STR0101, "01", 2) // "Fundamento Legal"
   EndIf   
   oStruct:AddGroup("02", STR0100, "01", 2) // "Regime Tributário"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
 
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("05", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   oStruct:SetProperty( "EIJ_TPAPIS" , MVC_VIEW_TITULO , STR0156) // "Tipo Alíq."
   oStruct:SetProperty( "EIJ_ALAPIS" , MVC_VIEW_TITULO , STR0157) // "Ad Valorem"
   oStruct:SetProperty( "EIJ_REDPIS" , MVC_VIEW_TITULO , STR0158) // "Alíq. Reduz."
   oStruct:SetProperty( "EIJ_ALUPIS" , MVC_VIEW_TITULO , STR0161) // "Alíq. Espec."
   oStruct:SetProperty( "EIJ_QTUPIS" , MVC_VIEW_TITULO , STR0162) // "Qtde. Espec."
   oStruct:SetProperty( "EIJ_ALPISM" , MVC_VIEW_TITULO , "% " + STR0163 ) // "% Majoração"
   oStruct:SetProperty( "EIJ_TPAPIS" , MVC_VIEW_COMBOBOX , {"1=" + STR0157, "2=" + STR0159, "" } ) // "Ad Valorem" ### "Específica"

   if lCpos
      oStruct:SetProperty( "EIJ_VLCPIS" , MVC_VIEW_TITULO , STR0112 ) // "Calculado"
      oStruct:SetProperty( "EIJ_VRDPIS" , MVC_VIEW_TITULO , STR0113 ) // "a Reduzir"
      oStruct:SetProperty( "EIJ_VDEPIS" , MVC_VIEW_TITULO , STR0114 ) // "Devido"
      oStruct:SetProperty( "EIJ_VLSPIS" , MVC_VIEW_TITULO , STR0115 ) // "Suspenso"
      oStruct:SetProperty( "EIJ_VRCPIS" , MVC_VIEW_TITULO , STR0116 ) // "a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_PIS', oStruct, 'EIJMASTER_PIS' )
   oView:SetOwnerView( 'VIEW_EIJ_PIS', 'BOX_PIS' )

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStrEKWPIS:= FWFormStruct( 2, "EKW", {|x| CheckField(x, strtokarr2(LP500View("EKWGRID"), "|")) })
      oView:CreateHorizontalBox( 'BOX_PIS_EKW', 50,,,'INFERIOR_TRIB', "FOLDER_PIS")
      oView:AddGrid("VIEW_EKW_TR_PIS", oStrEKWPIS, "EKWGRID_PIS")
      oView:EnableTitleView('VIEW_EKW_TR_PIS',STR0101) // "Fundamento Legal"
      oView:SetOwnerView( 'VIEW_EKW_TR_PIS', 'BOX_PIS_EKW' )
   EndIf

return nil

/*/{Protheus.doc} SetCOFView
   Cria a instância da View para a tabela EIJ ( COFINS )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetCOFView(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.
   local oStrEKWCOF

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := {}
   if !avFlags('FUNDAMENTO_LEGAL_ITEM')          
      aAdd( aCampos, {"EIJ_FUNCOF","01"} )
      aAdd( aCampos, {"EIJ_DSCFL4","01"} )
   endIf   
   aAdd( aCampos, {"EIJ_REGCOF","02"} )
   aAdd( aCampos, {"EIJ_DSCRG4","02"} )
   aAdd( aCampos, {"EIJ_TPACOF","03"} )
   aAdd( aCampos, {"EIJ_ALACOF","03"} )
   aAdd( aCampos, {"EIJ_REDCOF","03"} )
   aAdd( aCampos, {"EIJ_ALUCOF","03"} )
   aAdd( aCampos, {"EIJ_QTUCOF","03"} )
   aAdd( aCampos, {"EIJ_ALCOFM","03"} )

   if lCpos
      aAdd( aCampos, {"EIJ_VLCCOF" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDCOF" ,"04"} )
      aAdd( aCampos, {"EIJ_VDECOF" ,"04"} )
      aAdd( aCampos, {"EIJ_VLSCOF" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCCOF" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   if !avFlags('FUNDAMENTO_LEGAL_ITEM')    
      oStruct:AddGroup("01", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   oStruct:AddGroup("02", STR0100, "01", 2) // "Regime Tributário"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
 
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("05", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   oStruct:SetProperty( "EIJ_TPACOF" , MVC_VIEW_TITULO , STR0156) // "Tipo Alíq."
   oStruct:SetProperty( "EIJ_ALACOF" , MVC_VIEW_TITULO , STR0157 ) // "Ad Valorem"
   oStruct:SetProperty( "EIJ_REDCOF" , MVC_VIEW_TITULO , STR0158 ) // "Alíq. Reduz."
   oStruct:SetProperty( "EIJ_ALUCOF" , MVC_VIEW_TITULO , STR0161 ) // "Alíq. Espec."
   oStruct:SetProperty( "EIJ_QTUCOF" , MVC_VIEW_TITULO , STR0162) // "Qtde. Espec."
   oStruct:SetProperty( "EIJ_ALCOFM" , MVC_VIEW_TITULO , "% " + STR0163 ) // "% Majoração"
   oStruct:SetProperty( "EIJ_TPACOF" , MVC_VIEW_COMBOBOX , {"1=" + STR0157, "2=" + STR0159, "" } ) // "Ad Valorem" ### "Específica"

   if lCpos
      oStruct:SetProperty( "EIJ_VLCCOF" , MVC_VIEW_TITULO , STR0112 ) // "Calculado"
      oStruct:SetProperty( "EIJ_VRDCOF" , MVC_VIEW_TITULO , STR0113 ) // "a Reduzir"
      oStruct:SetProperty( "EIJ_VDECOF" , MVC_VIEW_TITULO , STR0114 ) // "Devido"
      oStruct:SetProperty( "EIJ_VLSCOF" , MVC_VIEW_TITULO , STR0115 ) // "Suspenso"
      oStruct:SetProperty( "EIJ_VRCCOF" , MVC_VIEW_TITULO , STR0116 ) // "a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_COF', oStruct, 'EIJMASTER_COFINS' )
   oView:SetOwnerView( 'VIEW_EIJ_COF', 'BOX_COF' )

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStrEKWCOF:= FWFormStruct( 2, "EKW", {|x| CheckField(x, strtokarr2(LP500View("EKWGRID"), "|")) })
      oView:CreateHorizontalBox( 'BOX_COFINS_EKW', 50,,,'INFERIOR_TRIB', "FOLDER_COFINS")
      oView:AddGrid("VIEW_EKW_TR_COFINS", oStrEKWCOF, "EKWGRID_COFINS")
      oView:EnableTitleView('VIEW_EKW_TR_COFINS',STR0101) // "Fundamento Legal"
      oView:SetOwnerView( 'VIEW_EKW_TR_COFINS', 'BOX_COFINS_EKW' )
   EndIf

return nil

/*/{Protheus.doc} SetADUView
   Cria a instância da View para a tabela EIJ ( ANTIDUMPING )

   @type  Static Function
   @author user
   @since 11/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function SetADUView(oView)
   local aCampos   := {}
   local oStruct   := nil
   local nCpo      := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local oStrEKWADU

   aCampos := {}
   if !avFlags('FUNDAMENTO_LEGAL_ITEM')          
      aAdd( aCampos, {"EIJ_FUNADU","01"} )
      aAdd( aCampos, {"EIJ_DSCFL5","01"} )
   endIf   
   aAdd( aCampos, {"EIJ_TPADUM","02"} )
   aAdd( aCampos, {"EIJ_ALADDU","02"} )
   aAdd( aCampos, {"EIJ_BAE_AD","02"} )
   aAdd( aCampos ,{"EIJ_ALEADU","02"} )

   if lDuimpInt
      aAdd( aCampos, {"EIJ_VLC_DU" ,"03"} )
      aAdd( aCampos, {"EIJ_VLD_DU" ,"03"} )
      aAdd( aCampos, {"EIJ_VLR_DU" ,"03"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   if !avFlags('FUNDAMENTO_LEGAL_ITEM')             
      oStruct:AddGroup("01", STR0101, "01", 2) // "Fundamento Legal"
   EndIf
   oStruct:AddGroup("02", STR0102, "01", 2) // "Alíquotas"
   if lDuimpInt
      oStruct:AddGroup("03", STR0111, "01", 2) // "Tributos Registrados"
   endif

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStruct:AddGroup("04", STR0101, "01", 2) // "Fundamento Legal"
   EndIf

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   oStruct:SetProperty( "EIJ_TPADUM" , MVC_VIEW_TITULO , STR0156) // "Tipo Alíq."
   oStruct:SetProperty( "EIJ_ALADDU" , MVC_VIEW_TITULO , STR0157) // "Ad Valorem"
   oStruct:SetProperty( "EIJ_BAE_AD" , MVC_VIEW_TITULO , STR0164) // "Base Espec."
   oStruct:SetProperty( "EIJ_ALEADU" , MVC_VIEW_TITULO , STR0161) // "Alíq. Espec."
   oStruct:SetProperty( "EIJ_TPADUM" , MVC_VIEW_COMBOBOX , {"1=" + STR0157, "2=" + STR0159, "3=" + STR0160, "" } ) // "Ad Valorem" #### "Específica" #### "Mista"

   if lDuimpInt
      oStruct:SetProperty( "EIJ_VLC_DU" , MVC_VIEW_TITULO , STR0112 ) // "Calculado"
      oStruct:SetProperty( "EIJ_VLD_DU" , MVC_VIEW_TITULO , STR0114 ) // "Devido"
      oStruct:SetProperty( "EIJ_VLR_DU" , MVC_VIEW_TITULO , STR0116 ) // "a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_ANTIDUMPING', oStruct, 'EIJMASTER_ANTIDUMPING' )
   oView:SetOwnerView( 'VIEW_EIJ_ANTIDUMPING', 'BOX_ANTIDUMPING' )

   If avFlags('FUNDAMENTO_LEGAL_ITEM') 
      oStrEKWADU:= FWFormStruct( 2, "EKW", {|x| CheckField(x, strtokarr2(LP500View("EKWGRID"), "|")) })
      oView:CreateHorizontalBox( 'BOX_ANTIDUMPING_EKW', 50,,,'INFERIOR_TRIB', "FOLDER_ANTIDUMPING")
      oView:AddGrid("VIEW_EKW_TR_ANTIDUMPING", oStrEKWADU, "EKWGRID_ANTIDUMPING")
      oView:EnableTitleView('VIEW_EKW_TR_ANTIDUMPING',STR0101) // "Fundamento Legal"
      oView:SetOwnerView( 'VIEW_EKW_TR_ANTIDUMPING', 'BOX_ANTIDUMPING_EKW' )
   EndIf

return nil

/*/{Protheus.doc} getDscFL
   Função para retornar a descrição do fundamento legal

   @type  Static Function
   @author user
   @since 17/07/2024
   @version version
   @param cCampo, caracter, campo de descrição (EIJ_DSCFL1, EIJ_DSCFL2, EIJ_DSCFL3, EIJ_DSCFL4, EIJ_DSCFL5)
          cCpoInfo, caracter, campo de informação (EIJ_FUNII, EIJ_FUNIPI, EIJ_FUNPIS, EIJ_FUNCOF, EIJ_FUNADU)
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getDscFL(cCampo, cCpoInfo)
   local nTam       := 0
   local cRet       := ""

   default cCampo     := ""
   default cCpoInfo   := ""

   nTam := getSx3Cache( cCampo, "X3_TAMANHO")
   cRet := space( nTam )

   if !empty( cCpoInfo )
      cRet := PadR( LP500GetInfo("EKU", 1, xFilial("EKU") + cCpoInfo, "EKU_FDTDES", "EKU_FILIAL + EKU_FDTLGL"), nTam )
   endif

return cRet

/*/{Protheus.doc} getDscRG
   Função para retornar a descrição a descrição do regime de tributação

   @type  Static Function
   @author user
   @since 17/07/2024
   @version version
   @param cCampo, caracter, campo de descrição (EIJ_DSCRG1, EIJ_DSCRG2, EIJ_DSCRG3, EIJ_DSCRG4)
          cCpoInfo, caracter, dado para posicionamento (EIJ_REGTRI, EIJ_REGIPI, EIJ_REGPIS, EIJ_REGCOF)
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getDscRG(cCampo, cCpoInfo)
   local nTam       := 0
   local cRet       := ""

   default cCampo     := ""
   default cCpoInfo   := ""

   nTam := getSx3Cache( cCampo, "X3_TAMANHO")
   cRet := space( nTam )

   if !empty( cCpoInfo )
      cRet := PadR( LP500GetInfo("SJP", 1, xFilial("SJP") + cCpoInfo , "JP_DESC", "JP_FILIAL + JP_CODIGO" ), nTam )
   endif

return cRet

function LP500GetAl(cTributo, cCodReg, cRegime, cTpAliq, cChaveSYD, lLoadEKR, lRegTrib, cCpoAliq)
return getAliquotas(cTributo, cCodReg, cRegime, cTpAliq, cChaveSYD, lLoadEKR, lRegTrib, cCpoAliq)

/*/{Protheus.doc} getAliquotas
   Função para retornar as alíquotas, II, IPI, PIS e COFINS a partir do cadastro de regime de tributação ou do cadastro da NCM
   @type  Static Function
   @author user
   @since 18/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getAliquotas(cTributo, cCodReg, cRegime, cTpAliq, cChaveSYD, lLoadEKR, lRegTrib, cCpoAliq)
   local aRet       := {}
   local xDado      := nil

   default cTributo   := ""
   default cCodReg    := ""
   default cRegime    := ""
   default cTpAliq    := ""
   default cChaveSYD  := ""
   default lLoadEKR   := .T.
   default lRegTrib   := avFlags("REGIME_TRIBUTACAO_DUIMP")
   default cCpoAliq   := ""

   do case

      case cTributo == "II"

         aAdd( aRet, { "EIJ_ALI_II", 0})
         if UseAliq(cTributo, "AD VALOREM", cRegime, cTpAliq)
            if lLoadEKR
               xDado := retCpoTrb( cCodReg, "EKR_ALI_II",,,, lRegTrib )
            else
               xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_PER_II" )
            endif
            aRet[1][2] := xDado
         endif

      case cTributo == "IPI"

         aAdd( aRet, { "EIJ_ALAIPI", 0 })
         if UseAliq(cTributo, "AD VALOREM", cRegime, cTpAliq)
            if lLoadEKR
               xDado := retCpoTrb( cCodReg, "EKR_ALAIPI",,,, lRegTrib )
            else
               xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_PER_IPI")
            endif
            aRet[len(aRet)][2] := xDado
         endif
      
         aAdd( aRet, { "EIJ_ALRIPI", 0 })
         if UseAliq(cTributo, "REDUZIDA", cRegime, cTpAliq)
            if lLoadEKR
               aRet[len(aRet)][2] := retCpoTrb( cCodReg, "EKR_ALRIPI",,,, lRegTrib )
            endif
         endif

         aAdd( aRet, { "EIJ_ALUIPI", 0 })
         if UseAliq(cTributo, "ESPECIFICA", cRegime, cTpAliq)
            if lLoadEKR
               aRet[len(aRet)][2] := retCpoTrb( cCodReg, "EKR_ALUIPI",,,, lRegTrib )
            endif
         endif

      case cTributo == "PIS"

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALAPIS")
            aAdd( aRet, { "EIJ_ALAPIS", 0 })
            if UseAliq(cTributo, "AD VALOREM", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_ALAPIS",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_PER_PIS")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALUPIS")
            aAdd( aRet, { "EIJ_ALUPIS", 0 })
            if UseAliq(cTributo, "ESPECIFICA", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_ALUPIS",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_VLU_PIS")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_REDPIS")
            aAdd( aRet, { "EIJ_REDPIS", 0 })
            if UseAliq(cTributo, "REDUZIDA", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_REDPIS",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_RED_PIS")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALPISM")
            if lLoadEKR
               xDado := retCpoTrb( cCodReg, "EKR_ALPISM",,,, lRegTrib )
            else
               xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_MAJ_PIS")
            endif
            aAdd( aRet, { "EIJ_ALPISM", xDado})
         endif

      case cTributo == "COFINS"

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALACOF")
            aAdd( aRet, { "EIJ_ALACOF", 0 })
            if UseAliq(cTributo, "AD VALOREM", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_ALACOF",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_PER_COF")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALUCOF")
            aAdd( aRet, { "EIJ_ALUCOF", 0 })
            if UseAliq(cTributo, "ESPECIFICA", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_ALUCOF",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_VLU_COF")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if (empty(cCpoAliq) .or. cCpoAliq == "EIJ_REDCOF")
            aAdd( aRet, { "EIJ_REDCOF", 0 })
            if UseAliq(cTributo, "REDUZIDA", cRegime, cTpAliq)
               if lLoadEKR
                  xDado := retCpoTrb( cCodReg, "EKR_REDCOF",,,, lRegTrib )
               else
                  xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_RED_COF")
               endif
               aRet[len(aRet)][2] := xDado
            endif
         endif

         if empty(cCpoAliq) .or. cCpoAliq == "EIJ_ALCOFM"
            if lLoadEKR
               xDado := retCpoTrb( cCodReg, "EKR_ALCOFM",,,, lRegTrib )
            else
               xDado := LP500GetInfo("SYD", 1, xFilial("SYD") + cChaveSYD, "YD_MAJ_COF")
            endif
            aAdd( aRet, { "EIJ_ALCOFM", xDado})
         endif

   end case
   
return aRet

/*/{Protheus.doc} LoadFundLg
   Ao informar um fundamento legal para um dos tributos, irá avaliar se o mesmo fundamento é aplicável à outros tributos, 
   preenchendo automaticamente nos demais folders caso o campo esteja vazio

   @type  Static Function
   @author user
   @since 18/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function LoadFundLg( oModel, cCpoOrig, cFundLg)
   local oMdlSWV    := ""
   local cNcm       := ""
   local aTributos  := {}
   local nTrib      := 0
   local cTributo   := ""
   local cFundLgDes := ""

   default cCpoOrig   := ""
   default cFundLg    := ""

   if valtype(oMdlSWV := oModel:GetModel("SWVDETAIL_TRIBUTACAO")) == "O" .and. !empty(cFundLg)

      cNcm := oMdlSWV:getValue("WV_NCM")
      aTributos := {}
      do case
         case cCpoOrig == "EIJ_FUNII" // Fundamento legal para II
            aAdd( aTributos, {"IPI", "EIJMASTER_IPI", "EIJ_FUNIPI"} )
            aAdd( aTributos, {"PIS", "EIJMASTER_PIS", "EIJ_FUNPIS"} )
            aAdd( aTributos, {"COFINS", "EIJMASTER_COFINS", "EIJ_FUNCOF"} )
            aAdd( aTributos, {"ANTIDUMPING", "EIJMASTER_ANTIDUMPING", "EIJ_FUNADU"} )

         case cCpoOrig == "EIJ_FUNIPI" // Fundamento legal para IPI
            aAdd( aTributos, {"II", "EIJMASTER_II", "EIJ_FUNII"} )
            aAdd( aTributos, {"PIS", "EIJMASTER_PIS", "EIJ_FUNPIS"} )
            aAdd( aTributos, {"COFINS", "EIJMASTER_COFINS", "EIJ_FUNCOF"} )
            aAdd( aTributos, {"ANTIDUMPING", "EIJMASTER_ANTIDUMPING", "EIJ_FUNADU"} )

         case cCpoOrig == "EIJ_FUNPIS" // Fundamento legal para PIS
            aAdd( aTributos, {"II", "EIJMASTER_II", "EIJ_FUNII"} )
            aAdd( aTributos, {"IPI", "EIJMASTER_IPI", "EIJ_FUNIPI"} )
            aAdd( aTributos, {"COFINS", "EIJMASTER_COFINS", "EIJ_FUNCOF"} )
            aAdd( aTributos, {"ANTIDUMPING", "EIJMASTER_ANTIDUMPING", "EIJ_FUNADU"} )

         case cCpoOrig == "EIJ_FUNCOF" // Fundamento legal para COFINS
            aAdd( aTributos, {"II", "EIJMASTER_II", "EIJ_FUNII"} )
            aAdd( aTributos, {"IPI", "EIJMASTER_IPI", "EIJ_FUNIPI"} )
            aAdd( aTributos, {"PIS", "EIJMASTER_PIS", "EIJ_FUNPIS"} )
            aAdd( aTributos, {"ANTIDUMPING", "EIJMASTER_ANTIDUMPING", "EIJ_FUNADU"} )

         case cCpoOrig == "EIJ_FUNADU" // Fundamento legal para ANTIDUMPING
            aAdd( aTributos, {"II", "EIJMASTER_II", "EIJ_FUNII"} )
            aAdd( aTributos, {"IPI", "EIJMASTER_IPI", "EIJ_FUNIPI"} )
            aAdd( aTributos, {"PIS", "EIJMASTER_PIS", "EIJ_FUNPIS"} )
            aAdd( aTributos, {"COFINS", "EIJMASTER_COFINS", "EIJ_FUNCOF"} )
      end case

      for nTrib := 1 to len(aTributos)
         cFundLgDes := getModEIJ(oModel, aTributos[nTrib][2]):getValue(aTributos[nTrib][3])
         if empty(cFundLgDes)
            cTributo := TEGetOpcTr(aTributos[nTrib][1])
            if !empty(LP500GetInfo("EKV", 1, xFilial("EKV") + cNcm + cFundLg + cTributo, "EKV_FDTLGL", "EKV_FILIAL + EKV_NCM + EKV_FDTLGL + EKV_TRIBUT")) 
               getModEIJ(oModel, aTributos[nTrib][2]):setValue(aTributos[nTrib][3], cFundLg)
            endif
         endif
      next
   endif

return  

/*/{Protheus.doc} GetStatCat
   Retorna o status do catalogo de produto e sua versão informada

   @type  Static Function
   @author user
   @since 19/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function GetStatCat(cNcm, cIdPortal, cVersao)
   local cRet       := " "

   default cNcm       := ""
   default cIdPortal  := EIJ->EIJ_IDPTCP 
   default cVersao    := EIJ->EIJ_VRSACP

   if !empty(cNcm) .and. !empty(cIdPortal)
      cRet := LP500GetInfo("EK9", 2, xFilial("EK9") + cNcm + cIdPortal, "EK9_STATUS", "EK9_FILIAL + EK9_NCM + EK9_IDPORT", .T.)
      cRet := if(empty(cRet), " ", cRet) // devido ao valid
      If EK9->EK9_IDPORT == cIdPortal .And. !Empty(cVersao) .And. EK9->EK9_VATUAL != cVersao .And. cRet $ "1|5"
         cRet := "7" //7=Existe versão posterior com o status Registrado
      EndIf
   endif

return cRet

/*/{Protheus.doc} VerifPend
   Na inicialização da rotina que verifica se para os catálogos/ versões informadas nos itens existe algum com o status pendente de retificação

   @type  Static Function
   @author user
   @since 19/07/2024
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function VerifPend(cHawb)
   local cQuery     := ""
   local oQuery     := nil
   local cAliasQry  := getNextAlias()

   default cHawb      := SW6->W6_HAWB

   cQuery := " SELECT EK9_STATUS FROM " + RetSQLName("EIJ") + " EIJ "
   cQuery +=   " INNER JOIN " + RetSQLName("EK9") + " EK9 ON EK9.D_E_L_E_T_ = ' ' "
   cQuery +=      " AND EK9_FILIAL = ? "
   cQuery +=      " AND EK9_IDPORT = EIJ_IDPTCP "
   cQuery +=      " AND EK9_STATUS = '3' " // Pendente Retificação
   cQuery +=      " AND EK9_MSBLQL <> '1' " 
   cQuery += " WHERE EIJ.D_E_L_E_T_ = ' ' "
   cQuery +=   " AND EIJ_FILIAL = ? "
   cQuery +=   " AND EIJ_HAWB = ? AND EIJ_IDPTCP <> ' ' "

   oQuery := FWPreparedStatement():New(cQuery)
   oQuery:SetString( 1, xFilial("EK9") ) // EK9_FILIAL
   oQuery:SetString( 2, xFilial("EIJ") ) // EIK_FILIAL
   oQuery:SetString( 3, cHawb ) // EIJ_HAWB

   cQuery := oQuery:GetFixQuery()
   FwFreeObj(oQuery)

   MPSysOpenQuery(cQuery, cAliasQry)

   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof())
      EasyHelp(STR0165, STR0003, STR0166) // "Existem itens com a versão do catálogo de produtos pendente de retificação." | "Atenção" | "Verifique se haverá a necessidade de reintegração do Catálogo de Produtos antes de prosseguir com a integração da DUIMP"
   endif

   (cAliasQry)->(dbCloseArea())

return nil 

function LP500UseAl(cTributo, cAliquota, cRegime, cTpAliq)
return UseAliq(cTributo, cAliquota, cRegime, cTpAliq)

/*/{Protheus.doc} UseAliq
   Verifica se alíquota poderá ser utilizada de acordo com o regime ou tipo de alíquota

   @type  Static Function
   @author user
   @since 26/07/2024
   @version version
   @param cTributo, caractere, tributo a ser verificado
          cAliquota, caractere, campo da alíquota a ser verificado
          cRegime, caractere, regime a ser verificado (II - EIJ_REGTRI, IPI - EIJ_REGIPI, PIS - EIJ_REGPIS, COFINS - EIJ_REGCOF)
          cTpAliq, caractere, tipo de alíquota a ser verificada (II - EIJ_TPALII, IPI - EIJ_TPAIPI, PIS - EIJ_TPAPIS, COFINS - EIJ_TPACOF, ANTIDUMPING - EIJ_TPADUM)
   @return lUse, logico, verdadeiro se a alíquota poderá ser utilizada
   @example
   (examples)
   @see (links_or_references)
   /*/
static function UseAliq(cTributo, cAliquota, cRegime, cTpAliq)
   local lUse       := .F.

   default cTributo   := "" // Imposto de Importação, IPI, PIS, COFINS e ANTIDUMPING
   default cAliquota  := "AD VALOREM" // Ad Valorem, Reduzida ou Específica
   default cRegime    := "1" // 1-RECOLHIMENTO INTEGRAL, 2-IMUNIDADE, 3-ISENCAO, 4-REDUCAO, 5-SUSPENSAO, 6-NAO INCIDENCIA
   default cTpAliq    := "1" // 1-Ad Valorem, 2-Específica e 3-Mista

   do case

      case cTributo == "II"

         if cAliquota == "AD VALOREM" // EIJ_ALI_II
            lUse := .T.
         elseif cAliquota == "REDUZIDA" // EIJ_ALR_II
            lUse := cRegime == "4" .and. (cTpAliq == "1" .or. cTpAliq == "3")
         endif

      case cTributo == "IPI"

         if cAliquota == "AD VALOREM" // EIJ_ALAIPI
            lUse := (cTpAliq == "1" .or. cTpAliq == "3")
         elseif cAliquota == "REDUZIDA" // EIJ_ALRIPI
            lUse := cRegime == "4" .and. (cTpAliq == "1" .or. cTpAliq == "3")
         elseif cAliquota == "ESPECIFICA" // EIJ_ALUIPI e EIJ_QTUIPI
            lUse := cTpAliq $ "2|3"
         endif

      case cTributo == "PIS" .or. cTributo == "COFINS"

         if cAliquota == "AD VALOREM" // EIJ_ALAPIS ou EIJ_ALACOF
            lUse := cTpAliq == "1"
         elseif cAliquota == "REDUZIDA" // EIJ_REDPIS ou EIJ_REDCOF
            lUse := cRegime == "4" .and. cTpAliq == "1"
         elseif cAliquota == "ESPECIFICA" // EIJ_ALUPIS e EIJ_QTUPIS ou EIJ_ALUCOF e EIJ_QTUCOF
            lUse := cTpAliq == "2"
         endif

      case cTributo == "ANTIDUMPING"

         if cAliquota == "AD VALOREM" // EIJ_ALADDU
            lUse := cTpAliq == "1" .or. cTpAliq == "3"
         elseif cAliquota == "ESPECIFICA" // EIJ_ALEADU
            lUse := cTpAliq == "2" .or. cTpAliq == "3"
         endif

   end case

return lUse

Static Function LP500VldCP(oMdl, oModelSWV)
local jItens
Local cHawb    := oModelSWV:GetValue("WV_HAWB")
Local lTemPend := .F.

If !FWIsInCallStack("EICLP501")
   jItens := DU100NewVs(cHawb)
   lTemPend := LP500ChkVs(oMdl, oModelSWV, jItens) //Checa se os registros com versão defasada da base foram atualizados manualmente via tela.
   If lTemPend .And.  MsgYesNo(STR0167 + ENTER+ENTER + STR0168, STR0048)//""###"Aviso"###"Existem catálogos de produtos registrados com versões mais recentes disponíveis."###"Deseja realizar uma atualização automática antes de continuar com a integração?"
      LP500AtuCP(oMdl, oModelSWV, jItens)
   EndIf
EndIf

Return

Function LP500ChkVs(oModel, oModelSWV, jItens)
Local lRet := .F.
Local nI

If Len(jItens['Itens']) > 0
   For nI := 1 To Len(jItens['Itens'])
      aSeek :={{"WV_FILIAL", xFilial("SWV")             },;
               {"WV_HAWB"  , jItens['Itens'][nI]['HAWB']},;
               {"WV_ID"    , jItens['Itens'][nI]['IDWV']}}
      if oModelSWV:SeekLine(aSeek, .F. , .T.) .And. oModel:getModel("EIJMASTER"):GetValue("EIJ_VRSACP") != LP500VATUAL(jItens['Itens'][nI]['EK9_VATUAL'], jItens['Itens'][nI]['EKD_VATUAL'])
         lRet := .T.
         Exit
      EndIf
   Next
EndIf

Return lRet

/*/{Protheus.doc} DU100NewVs (Verifica Catalogos)
   Verifica os status do catálogo nos itens da DUIMP
   @type  Static Function
   @param cHawb, caracter, variavel do Hawb da EV1
   @return lRet, lógico, retorno da execução
/*/
Function DU100NewVs(cHawb, lSWVSW9)
Local cQuery    := ""
Local cAliasQry := getNextAlias()
Local oQuery
Local jItens := JsonObject():New()
Local oItem

Default lSWVSW9 := .F.

cQuery += " SELECT  "
cQuery += "   EIJ_HAWB, "
cQuery += "   EIJ_IDWV, "
cQuery += "   EIJ_IDPTCP, "
cQuery += "   EIJ_VRSACP, "
cQuery += "   EK9_IDPORT, "
cQuery += "   EK9_VATUAL, "
cQuery += "   COALESCE(EKD_VATUAL, ' ') EKD_VATUAL "
If lSWVSW9
   cQuery += "  ,WV_FILIAL, "
   cQuery += "   WV_HAWB, "
   cQuery += "   WV_INVOICE, "
   cQuery += "   WV_FORN, "
   cQuery += "   WV_FORLOJ, "
   cQuery += "   WV_PO_NUM, "
   cQuery += "   WV_POSICAO, "
   cQuery += "   WV_SEQUENC, "
   cQuery += "   W9_FILIAL, "
   cQuery += "   W9_HAWB, "
   cQuery += "   W9_INVOICE, "
   cQuery += "   W9_FORN, "
   cQuery += "   W9_FORLOJ "
EndIf
cQuery += " FROM  "
cQuery += "   " + RetSqlName('EIJ') + " EIJ  "
cQuery += "   INNER JOIN " + RetSqlName('EK9') + " EK9 ON ( "
cQuery += "     EK9_FILIAL          = ?  "
cQuery += "     AND EK9_IDPORT      = EIJ_IDPTCP  "
cQuery += "     AND EK9.D_E_L_E_T_  = ' ' "
cQuery += "   )  "
If lSWVSW9
   cQuery += " INNER JOIN " + RetSQLName("SWV") +" WV ON ( "
   cQuery += "   WV_FILIAL          = ? "
   cQuery += "   AND WV_HAWB        = EIJ_HAWB "
   cQuery += "   AND WV_ID          = EIJ_IDWV "
   cQuery += "   AND WV.D_E_L_E_T_  = ' ' "
   cQuery += " ) "
   cQuery += " INNER JOIN " + RetSQLName("SW9") + " W9 ON ( "
   cQuery += "   W9_FILIAL          = ? "
   cQuery += "   AND W9_INVOICE     = WV_INVOICE "
   cQuery += "   AND W9_FORN        = WV_FORN "
   cQuery += "   AND W9_FORLOJ      = WV_FORLOJ "
   cQuery += "   AND W9_HAWB        = EIJ_HAWB "
   cQuery += "   AND W9.D_E_L_E_T_  = ' ' "
   cQuery += ") "
EndIf
cQuery += " LEFT JOIN " + RetSqlName('EKD') + " EKD ON ( "
cQuery += "   EKD_FILIAL          = ? "
cQuery += "   AND EKD_COD_I       = EK9_COD_I  "
cQuery += "   AND EKD_VATUAL      <>EK9_VATUAL "
cQuery += "   AND ( EKD_STATUS = '1' "
cQuery += "         OR EKD_STATUS = '5' "
cQuery += "         OR EKD_STATUS = '6' "
cQuery += "       ) "
cQuery += "   AND EKD.D_E_L_E_T_  = ' ' "
cQuery += " ) "
cQuery += " WHERE  "
cQuery += "   EIJ_FILIAL      = ?  "
cQuery += "   AND EIJ_HAWB    = ?  "
cQuery += "   AND EIJ_IDPTCP != ' '  "
cQuery += "  AND ( "
cQuery += "    ( "
cQuery += "      EK9_VATUAL <> ' '  "
cQuery += "      AND EIJ_VRSACP != EK9_VATUAL "
cQuery += "    )  "
cQuery += "    OR ( "
cQuery += "      EK9_VATUAL = ' '  "
cQuery += "      AND EKD_VATUAL <> ' '  "
cQuery += "      AND EIJ_VRSACP != EKD_VATUAL "
cQuery += "    ) "
cQuery += "  )  "
cQuery += "     AND (EK9_STATUS = '1' OR "
cQuery += "   	      EK9_STATUS = '5' OR "
cQuery += "          (EK9_VATUAL= ' ' AND EKD_VATUAL <> ' ')"
cQuery += "         ) "
cQuery += "   AND EIJ.D_E_L_E_T_ = ' ' "

oQuery := FWPreparedStatement():New(cQuery)

If lSWVSW9
   oQuery:SetString(1,xFilial('EK9'))
   oQuery:SetString(2,xFilial('SWV'))
   oQuery:SetString(3,xFilial('SW9'))
   oQuery:SetString(4,xFilial('EKD'))
   oQuery:SetString(5,xFilial('EIJ'))
   oQuery:SetString(6,cHawb)
Else
   oQuery:SetString(1,xFilial('EK9'))
   oQuery:SetString(2,xFilial('EKD'))
   oQuery:SetString(3,xFilial('EIJ'))
   oQuery:SetString(4,cHawb)
EndIf

cQuery := oQuery:GetFixQuery()

fwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasQry)

jItens['Itens'] := {}
If (cAliasQry)->(!EOF())

   While (cAliasQry)->(!EOF())
      oItem := jsonObject():New()
      oItem['HAWB'  ] := (cAliasQry)->(EIJ_HAWB)
      oItem['IDWV'  ] := (cAliasQry)->(EIJ_IDWV)
      oItem['EK9_VATUAL'] := (cAliasQry)->(EK9_VATUAL)
      oItem['IDPORT'] := (cAliasQry)->(EK9_IDPORT)
      oItem['EKD_VATUAL'] := (cAliasQry)->(EKD_VATUAL)
      If lSWVSW9
         oItem['INVOICE'] := (cAliasQry)->(WV_INVOICE)
         oItem['FORN'   ] := (cAliasQry)->(WV_FORN)
         oItem['FORLOJ' ] := (cAliasQry)->(WV_FORLOJ)
         oItem['PO_NUM' ] := (cAliasQry)->(WV_PO_NUM)
         oItem['POSICAO'] := (cAliasQry)->(WV_POSICAO)
         oItem['SEQUENC'] := (cAliasQry)->(WV_SEQUENC)
      EndIf
      aAdd(jItens['Itens'], oItem)

      FreeObj(oItem)
      (cAliasQry)->(dbSkip())
   End

EndIf

(cAliasQry)->(DbCloseArea())

Return jItens

/*
Função     : LP500AtuCP
Objetivo   : Atualiza o Catálogo de Produtos nos itens da DUIMP.
Parâmetro  : jItens - Objeto com os dados a serem atualizados
Retorno    : lógico - .T. se atualizou com sucesso, .F. se ocorreu erro.
Autor      : THTS - Tiago Tudisco
Data/Hora  : Agosto/2024
*/
Function LP500AtuCP(oModel, oModelSWV, jItens)
Local lRet     := .T.
Local aSeek
Local nI

default oModel   := FwModelActive()
default oModelSWV:= oModel:GetModel("SWVDETAIL")

For nI := 1 To Len(jItens['Itens'])
   aSeek :={{"WV_FILIAL", xFilial("SWV")             },;
            {"WV_HAWB"  , jItens['Itens'][nI]['HAWB']},;
            {"WV_ID"    , jItens['Itens'][nI]['IDWV']}}
   if oModelSWV:SeekLine(aSeek, .F. , .T.)
      oModel:getModel("EIJMASTER"):SetValue("EIJ_IDPTCP", jItens['Itens'][nI]['IDPORT'])
      oModel:getModel("EIJMASTER"):SetValue("EIJ_VRSACP", LP500VATUAL(jItens['Itens'][nI]['EK9_VATUAL'], jItens['Itens'][nI]['EKD_VATUAL']))
   EndIf
Next

Return lRet

Function LP500VATUAL(cEK9Versao, cEKDVersao)
Local cRet
If !Empty(cEK9Versao)
   cRet := cEK9Versao
Else
   cRet := cEKDVersao
EndIf
Return cRet

Static Function getPaisOri()
Local cRet := ""

   /*
   SYR->(dbSetOrder(1)) //YR_FILIAL+YR_VIA+YR_ORIGEM+YR_DESTINO+YR_TIPTRAN
   If SYR->(dbSeek(xFilial("SYR") + SW6->W6_VIA_TRA + SW6->W6_ORIGEM + SW6->W6_DEST))
      cRet := SYR->YR_PAIS_OR
   EndIf*/

   cRet:= SW6->W6_PAISPRO

Return cRet

/*/{Protheus.doc} LP500GetPais
Retornar o país de origem do processo para a consulta padrão EKV
@type function
@version  1.0.0
@author wilsimar
@since 12/23/2024
@return variant, país de orgem informado no processo de importação
/*/
Function LP500GetPais()
Return getPaisOri()

/*
Função     : LP500LDEKW
Objetivo   : Função de load chamada do addGrid para carregar os grids de Fundamento Legal
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
Revisão    : 16/09/2025: adaptado para carregar os dados dos atributos do fundamento legal
*/
Static Function LP500LDEKW(oModel, oModelEKW, cType)
Local cPais       := getPaisOri()
Local cNcm        := oModel:GetModel():GetValue("SWVDETAIL", "WV_NCM")

   Do Case
      Case cType == "EKWGRID_II"
         
         setGridEKW(cPais, cNcm, "1", oModelEKW, oModel)

      Case cType == "EKWGRID_IPI"
         
         setGridEKW(cPais, cNcm, "2", oModelEKW, oModel)

      Case cType == "EKWGRID_PIS"
         
         setGridEKW(cPais, cNcm, "3", oModelEKW, oModel)
         
      Case cType == "EKWGRID_COFINS"
         
         setGridEKW(cPais, cNcm, "4", oModelEKW, oModel)
         
      Case cType == "EKWGRID_ANTIDUMPING"
         
         setGridEKW(cPais, cNcm, "5", oModelEKW, oModel)
         
   EndCase

Return 

/*
Função     : setGridEKW
Objetivo   : Função para Carregar os dados selecionados de fundamento legal no grid da tabela EKW
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
Revisão    : 16/09/2025: adaptado para carregar os dados dos atributos do fundamento legal
*/
Static Function setGridEKW(cPais, cNcm, cTributo, oModelEKW, oModel)
Local oModSWV    := nil
Local cFundLegal := ""
Local cMercadoria:= ""
Local cMercValor := ""
Local cIdent     := ""
Local cIdentInfo := ""
Local cDivider   := ""
Local cRegime    := ""
Local cDesFund   := ""
Local cDesRegi   := ""
Local nOrder
local nFund

begin sequence 

   if oModelEKW:length(.T.) == 0 .Or. empty(oModelEKW:getValue("EKW_IDWV"))
      break
   endIf

   cActiveID:= oModelEKW:getValue("EKW_IDWV")

   oModSWV:= oModel:GetModel("SWVDETAIL")

   for nFund := 1 to oModelEKW:length()

      oModelEKW:goline(nFund)
      cMercValor := oModelEKW:getValue("EKW_ATRIBU")
      
      cFundLegal := oModelEKW:GetValue("EKW_FDTLGL")
      cDesRegi:= oModelEKW:GetValue("EKW_FDTDES")
      
      //EKV_FILIAL+EKV_NCM+EKV_FDTLGL+EKV_TRIBUT+EKV_PAIS //dbsetorder(1)
      EKV->(DBSeek(xFilial("EKV") + cNcm + cFundLegal + cTributo + cPais))
      cMercadoria:= EKV->EKV_ATRIBU

      cRegime := oModelEKW:GetValue("EKW_REGIME")
      cDesFund:= oModelEKW:GetValue("EKW_REGDES") 

      // Identificador da mercadoria
      If CanUseApp()
         If EKU->(ColumnPos("EKU_ATT_FL")) > 0
            If !oFundLegal[cActiveID]:hasProperty(cFundLegal)
               cIdentInfo := cActiveID + "-" + cFundLegal + "_"
               nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
               LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + cFundLegal, "EKU_ATT_FL"), cIdentInfo, oModSWV:GetValue("WV_ATT_FL"), oModSWV:GetValue("WV_AC"), oModSWV:GetValue("WV_SEQSIS"), nOrder)
               oFundLegal[cActiveID][cFundLegal] := 1
            Else
               oFundLegal[cActiveID][cFundLegal]++
            EndIf
         EndIf
         cIdent   := cActiveID + "-" + Alltrim(cNcm) + "-" + cFundLegal + "-" + cTributo + "-" + oModelEKW:GetValue("EKW_TIPO") + "-" + cPais + "_"
         cDivider := getTribName(cTributo) + " | " + cRegime + " - " + cDesRegi + " | " + cFundLegal + " - " + cDesFund
         LP500ATMER(oJsonAtt, cMercadoria, cIdent, cDivider, cMercValor)
      EndIf

   next

end sequence

Return

/*
Função     : QryOpcTrib
Objetivo   : Função para buscar os dados da tabela EKV e verificar se o mesmo Fundamento Legal possui outros tributos para carregar os grids de Fundamento Legal automaticamnete
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function QryOpcTrib(cFundLegal, cNcm, cTributo, cPais, cTipo, cListaTrib)
Local cQuery   := ""
Local cAliasEKV:= getNextAlias()
Local oRet     := jsonObject():New()
Local nI       := 0
Local oQuery

cQuery += " SELECT  "
cQuery += "   EKV_NCM,  "
cQuery += "   EKV_FDTLGL,  "
cQuery += "   EKV_TRIBUT,  "
cQuery += "   EKV_TIPO,  "
cQuery += "   EKV_PAIS,  "
cQuery += "   EKV.R_E_C_N_O_ RECNOEKV, "
cQuery += "   EKU_REGIME  "
cQuery += " FROM  "
cQuery +=     RetSqlName("EKV") + " EKV  "
cQuery += "   INNER JOIN " + RetSqlName("EKU") + " EKU ON ( "
cQuery += "     EKU_FILIAL          = ?  "
cQuery += "     AND EKU_FDTLGL      = EKV_FDTLGL  "
cQuery += "     AND EKU.D_E_L_E_T_  = ? "
cQuery += "   )  "
cQuery += " WHERE  "
cQuery += "   EKV_FILIAL         = ?  "
cQuery += "   AND EKV_NCM        = ?  "
cQuery += "   AND EKV_FDTLGL     = ?  "
cQuery += "   AND EKV_TRIBUT     <>?  "
cQuery += "   AND EKV_PAIS       = ?  "
//cQuery += "   AND EKV_TIPO       = ? "
cQuery += "   AND EKV.D_E_L_E_T_ = ? "
cQuery += " ORDER BY EKV.EKV_FDTLGL "

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString( 1, xFilial("EKU") )  // EKU_FILIAL
oQuery:SetString( 2, ' '            )  // EKU.D_E_L_E_T_
oQuery:SetString( 3, xFilial("EKV") )  // EKV_FILIAL
oQuery:SetString( 4, cNcm           )  // EKV_NCM
oQuery:SetString( 5, cFundLegal     )  // EKV_FDTLGL
oQuery:SetString( 6, cTributo       )  // EKV_TRIBUT
oQuery:SetString( 7, cPais          )  // EKV_PAIS
//oQuery:SetString( 8, cTipo          )  // EKV_TIPO
//oQuery:SetString( 9, ' '            )  // EKV.D_E_L_E_T_
oQuery:SetString( 8, ' '            )  // EKV.D_E_L_E_T_

cQuery := oQuery:GetFixQuery()
FwFreeObj(oQuery)

MPSysOpenQuery(cQuery, cALiasEKV)

oRet["listaOpcional"] := {}
While (cAliasEKV)->(!EOF())
   nI++
   IIF(!Empty(cListaTrib), cListaTrib += ", ", "")
   cListaTrib += getTribName((cAliasEKV)->(EKV_TRIBUT))
   aAdd(oRet["listaOpcional"], JsonObject():new())
   oRet["listaOpcional"][nI]["EKW_NCM"]   := (cAliasEKV)->(EKV_NCM)
   oRet["listaOpcional"][nI]["EKW_FDTLGL"]:= (cAliasEKV)->(EKV_FDTLGL)
   oRet["listaOpcional"][nI]["EKW_FDTDES"]:= LP500GetInfo("EKU", 1, xFilial("EKU") + (cAliasEKV)->(EKV_FDTLGL), "EKU_FDTDES")
   oRet["listaOpcional"][nI]["EKW_TRIBUT"]:= (cAliasEKV)->(EKV_TRIBUT)
   oRet["listaOpcional"][nI]["EKW_TIPO"]  := (cAliasEKV)->(EKV_TIPO)
   oRet["listaOpcional"][nI]["EKW_PAIS"]  := (cAliasEKV)->(EKV_PAIS)
   oRet["listaOpcional"][nI]["RECNOEKV"]  := (cAliasEKV)->(RECNOEKV)
   oRet["listaOpcional"][nI]["EKW_REGIME"]:= (cAliasEKV)->(EKU_REGIME)
   oRet["listaOpcional"][nI]["EKW_REGDES"]:= IIF(!Empty((cAliasEKV)->(EKU_REGIME)), LP500GetInfo("SJP", 1, xFilial("SJP") + LP500GetInfo("EKU", 1, xFilial("EKU") + (cAliasEKV)->(EKV_FDTLGL), "EKU_REGIME"), "JP_DESC"), "")

   (cAliasEKV)->(dbSkip())
End

(cAliasEKV)->(dbCloseArea())
Return oRet

/*
Função     : LPVALIDEKW
Objetivo   : Função Utilizada nos Valids SX3 da tabela EKW
Parâmetro  : cCampo - Campo a ser validado
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Function LPVALIDEKW(cCampo)
Local lRet        := .T.
Local aFolder     := {}
Local cTributo    := ""
Local cListaTrib  := ""
Local oModel
Local oView
Local cNcm        := ""
Local cPais       := ""
Local cHawb       := "" 
Local cIDWV       := ""
Local oFundOpc

Do Case

   Case cCampo == "EKW_FDTLGL"
      oModel := FWModelActive()
      oView := FwViewActive()
      if oView <> nil
         aFolder := oView:GetFolderActive("INFERIOR_TRIB",2)
         If Len(aFolder) > 0
            cTributo := Alltrim(Str(aFolder[1]))
         EndIf
         cNcm  := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):getValue("WV_NCM")
         cHawb := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):getValue("WV_HAWB")
         cIDWV := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):getValue("WV_ID")
         cActiveID:= cIDWV
      endif
      // Avaliar uma forma quando for execauto atribuir cTributo
      if( empty(cNcm) , cNcm := getNCM(oModel:GetModel("SWVDETAIL")), nil)

      cPais := getPaisOri()
      lRet  := Vazio() .Or. ExistCPO("EKV", M->EKW_FDTLGL + cNcm + cTributo + cPais , 2) //EKV_FILIAL+EKV_FDTLGL+EKV_NCM+EKV_TRIBUT+EKV_PAIS+EKV_TIPO

      If lRet .And. !Empty(M->EKW_FDTLGL) //Valida se ja existe o registro no grid para não duplicar
         If !VldLineEKW(oModel, cHawb, cIDWV, M->EKW_FDTLGL, cNcm, cTributo, cPais, "3")
            EasyHelp(STR0178, STR0003, STR0179) //"Este Fundamento Legal já foi adicionado para este tributo."###"Atenção"###"Adicione um Fundamento Legal que ainda não esteja adicionado ao tributo."
            lRet := .F.
         EndIf
      EndIf

      If lRet .And. !Empty(M->EKW_FDTLGL) .And. Empty(LP500GetInfo("EKU", 1, xFilial("EKU") + M->EKW_FDTLGL, "EKU_REGIME")) //Valida se fundamento possui Regime informado
         EasyHelp(STR0193, STR0003, STR0194) //"Este Fundamento Legal não possui Regime Tributário."###"Atenção"###"Informe um Regime Tributário para o Fundamento Legal no Cadastro 'Fundamento Legal Duimp'."
         lRet := .F.
      EndIf

      If lRet .and. canUseApp() .And. !Empty(M->EKW_FDTLGL) //Verifica se o Fundamento Legal Opcional possui outros tributos e se tiver, adiciona no grid automaticamente
         oFundOpc := jsonObject():New()
         oFundOpc := QryOpcTrib(M->EKW_FDTLGL, cNcm, cTributo, cPais, "3", @cListaTrib)
         If Len(oFundOpc["listaOpcional"]) > 0
            MsgInfo(STR0180 + cListaTrib + STR0181, STR0003) //"Este Fundamento Legal aplica-se também ao(s) tributo(s) "### " e será adicionado automaticamente na pasta destes tributos."###"Atenção"
            FWMsgRun(, {|oSay| FLOpcTrib(oModel, oFundOpc) }, STR0182, STR0183) //"Carregando Fundamentos Opcionais"###"Aguarde..."
            oView:Refresh()
         EndIf
         FreeObj(oFundOpc)
      EndIf

EndCase

Return lRet

/*
Função     : VldLineEKW
Objetivo   : Função Utilizada para validar se ja existe uma linha com os mesmos dados no grid da tabela EKW
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function VldLineEKW(oModel, cHawb, cIDWV, cFundLegal, cNcm, cTributo, cPais, cTipo)
Local lRet  := .T.
Local aSeek := {}
Local nLine
Local oGridEKW

aAdd(aSeek, {"EKW_FILIAL"  , xFilial("EKW")  })
aAdd(aSeek, {"EKW_HAWB"    , cHawb           })
aAdd(aSeek, {"EKW_IDWV"    , cIDWV           })
aAdd(aSeek, {"EKW_NCM"     , cNcm            })
aAdd(aSeek, {"EKW_FDTLGL"  , cFundLegal      })
aAdd(aSeek, {"EKW_TRIBUT"  , cTributo        })
//aAdd(aSeek, {"EKW_TIPO"    , cTipo           })

oGridEKW := oModel:GetModel(getGridEKW(cTributo))
nLine := oGridEKW:GetLine()
If oGridEKW:SeekLine(aSeek, .T., .T.)
   lRet := oGridEKW:GetLine() == nLine
EndIf

oGridEKW:GoLine(nLine)
Return lRet

/*
Função     : LPINIBREKW
Objetivo   : Função Utilizada no Inicializador Padrão SX3 da tabela EKW
Parâmetro  : cCampo - Campo a ser inicializado
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Function LPINIBREKW(cCampo, oGridEKW, c)
Local xRet  := ""

   Do Case
      Case cCampo == "EKW_FDTDES"
         xRet  := Space(getSX3Cache("EKU_FDTDES", "X3_TAMANHO"))
         if !empty(EKW->EKW_FDTLGL)
            xRet := LP500GetInfo("EKU", 1, xFilial("EKU") + EKW->EKW_FDTLGL, "EKU_FDTDES")
         endif
      Case cCampo == "EKW_REGDES"
         xRet  := Space(getSX3Cache("EKW_REGDES", "X3_TAMANHO"))
         if !empty(EKW->EKW_FDTLGL)
            xRet := LP500GetInfo("SJP", 1, xFilial("SJP") + LP500GetInfo("EKU", 1, xFilial("EKU") + EKW->EKW_FDTLGL, "EKU_REGIME"), "JP_DESC")
         endif
   EndCase

Return xRet

Static Function getGridEKW(cTributo)
Local cRet := ""

Do Case
   Case cTributo == "1"
      cRet := "EKWGRID_II"
   Case cTributo == "2"
      cRet := "EKWGRID_IPI"
   Case cTributo == "3"
      cRet := "EKWGRID_PIS"
   Case cTributo == "4"
      cRet := "EKWGRID_COFINS"
   Case cTributo == "5"
      cRet := "EKWGRID_ANTIDUMPING"
EndCase

Return cRet

Static Function getTribName(cTributo)
Local cRet:= ""

Do Case
   Case cTributo == "1"
      cRet := "II"
   Case cTributo == "2"
      cRet := "IPI"
   Case cTributo == "3"
      cRet := "PIS"
   Case cTributo == "4"
      cRet := "COFINS"
   Case cTributo == "5"
      cRet := "ANTIDUMPING"
EndCase

return cRet

Static Function getTribCode(cTributo)
Local cRet:= ""

Do Case
   Case cTributo == "II"
      cRet := "1"
   Case cTributo == "IPI"
      cRet := "2"
   Case cTributo == "PIS"
      cRet := "3"
   Case cTributo == "COFINS"
      cRet := "4"
   Case cTributo == "ANTIDUMPING"
      cRet := "5"
EndCase

return cRet

/*
Função     : LPGATILEKW
Objetivo   : Função Utilizada para Regra de Gatilho SX7 da tabela EKW
Parâmetro  : cCampo - Campo a ser gatilhado
             cSeq   - Sequência do Gatilho
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Function LPGATILEKW(cCampo, cSeq)
Local xRet   := ""
Local cHawb
Local cIDWV
Local cNcm
Local cTributo
Local cPais
Local cIdent
Local cIdentInfo
Local cDivider
Local oModel
Local oView
Local oGridEKW
Local nOrder

Do Case
   Case cCampo == "EKW_FDTLGL"
      If !Empty(M->EKW_FDTLGL)
         If     cSeq == "001" //EKW_FDTDES
            xRet := LP500GetInfo("EKU", 1, xFilial("EKU") + M->EKW_FDTLGL, "EKU_FDTDES")
         ElseIf cSeq == "002" //EKW_REGIME
            xRet := LP500GetInfo("EKU", 1, xFilial("EKU") + M->EKW_FDTLGL, "EKU_REGIME")
         ElseIf cSeq == "003" //EKW_REGDES
            xRet := LP500GetInfo("SJP", 1, xFilial("SJP") + LP500GetInfo("EKU", 1, xFilial("EKU") + M->EKW_FDTLGL, "EKU_REGIME"), "JP_DESC")
         ElseIf cSeq == "004" //EKW_TIPO
            oModel := FWModelActive()
            oView  := FwViewActive()
            If ValType(oModel) == 'O' .And. ValType(oView) == 'O'
               cHawb    := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):GetValue("WV_HAWB")
               cIDWV    := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):GetValue("WV_ID")
               cNcm     := oModel:GetModel("SWVDETAIL_TRIBUTACAO"):GetValue("WV_NCM")
               cTributo := Alltrim(Str(oView:GetFolderActive("INFERIOR_TRIB",2)[1]))
               cPais    := getPaisOri()
               oGridEKW := oModel:GetModel(getGridEKW(cTributo))
               oGridEKW:LoadValue("EKW_FILIAL"  , xFilial("EKW"))
               oGridEKW:LoadValue("EKW_HAWB"    , cHawb     )
               oGridEKW:LoadValue("EKW_IDWV"    , cIDWV     )
               oGridEKW:LoadValue("EKW_NCM"     , cNcm      )
               oGridEKW:LoadValue("EKW_TRIBUT" , cTributo  )
               xRet := LP500GetInfo("EKV", 1, xFilial("EKV") + cNcm + M->EKW_FDTLGL + cTributo + cPais, "EKV_TIPO")

               // Identificador da mercadoria
               If canUseApp()
                  If EKU->(ColumnPos("EKU_ATT_FL")) > 0 
                     If !oFundLegal[cActiveID]:hasProperty(M->EKW_FDTLGL)
                        cIdentInfo := cActiveID + "-" + M->EKW_FDTLGL + "_"
                        nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
                        LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + M->EKW_FDTLGL, "EKU_ATT_FL"), cIdentInfo, ,oModel:GetModel("SWVDETAIL"):GetValue("WV_AC"), oModel:GetModel("SWVDETAIL"):GetValue("WV_SEQSIS"), nOrder)
                        oFundLegal[cActiveID][M->EKW_FDTLGL] := 1
                        oJsonPOUI['listaInformativos'] := oInfoAtt
                     Else
                        oFundLegal[cActiveID][M->EKW_FDTLGL]++
                     EndIf
                  EndIf
                  cIdent   := cActiveID + "-" + Alltrim(cNcm) + "-" + M->EKW_FDTLGL + "-" + cTributo + "-" + xRet + "-" + cPais + "_"
                  cDivider := getTribName(cTributo) + " | " +  oGridEKW:GetValue("EKW_REGIME") + " - " + oGridEKW:GetValue("EKW_REGDES") + " | " +  M->EKW_FDTLGL + " - " +  oGridEKW:GetValue("EKW_FDTDES")
                  LP500ATMER(oJsonAtt, LP500GetInfo("EKV", 1, xFilial("EKV") + cNcm + M->EKW_FDTLGL + cTributo + cPais, "EKV_ATRIBU"), cIdent, cDivider)
                  oJsonPOUI['listaAdicionais'] := oJsonAtt
                  sendAttPOUI(oJsonPOUI)
               EndIf
            EndIf
         EndIf
      Else
         xRet := ""
      EndIf
   Case cCampo == "EKW_REGIME"
      If cSeq == "001" //EKW_REGDES

      EndIf
EndCase

Return xRet

Static Function LP500EKWPRE(oModel, nLine, cAction, cField, cGridEKW)
Local lRet := .T.
Local oMdl

Do Case

   Case cAction == "CANSETVALUE"
      If cField == "EKW_FDTLGL" .And. oModel:getModel("SWVDETAIL_TRIBUTACAO"):getModel(cGridEKW):GetValue("EKW_TIPO") $ "1|2" //Se for Normal ou Teto não permite edição
         EasyHelp(STR0184, STR0185, STR0003) //"Não é permitido alterar o Fundamento Legal para os tipos Normal e Teto."###Atenção!###"",""###"Somente FUndamento Legal do tipo Opcional pode ser editado."
         lRet := .F.
      EndIf
   Case cAction == "DELETE" 
      If oModel:getModel("SWVDETAIL_TRIBUTACAO"):getModel(cGridEKW):GetValue("EKW_TIPO") $ "1|2" //Se for Normal ou Teto não permite edição
         EasyHelp(STR0186, STR0003, STR0187) //"Não é permitido excluir o Fundamento Legal para os tipos Normal e Teto."###Atenção!###"",""###"Somente FUndamento Legal do tipo 'Opcional' pode ser excluído."
         lRet := .F.
      EndIf

      If lRet .And. canUseApp() .and. !empty(oModel:getModel("SWVDETAIL_TRIBUTACAO"):getModel(cGridEKW):GetValue("EKW_IDWV"))
         oMdl := oModel:getModel("SWVDETAIL_TRIBUTACAO"):getModel(cGridEKW)
         //EasyHelp('deletou a linha', STR0003, 'deletou a linha')
         setInvisible(cActiveID + "-" + Alltrim(oMdl:GetValue("EKW_NCM")) + "-" + oMdl:GetValue("EKW_FDTLGL") + "-" + oMdl:GetValue("EKW_TRIBUT") + "-" + oMdl:GetValue("EKW_TIPO") + "-" + getPaisOri())
         If EKU->(ColumnPos("EKU_ATT_FL")) > 0
            oFundLegal[cActiveID][oMdl:GetValue("EKW_FDTLGL")]--
            If oFundLegal[cActiveID][oMdl:GetValue("EKW_FDTLGL")] <= 0
               setInvisible(cActiveID + "-" + oMdl:GetValue("EKW_FDTLGL"))
            EndIf
         EndIf
      EndIf
   
   Case cAction == "UNDELETE"  .And. canUseApp()
      oMdl := oModel:getModel("SWVDETAIL_TRIBUTACAO"):getModel(cGridEKW)
      //EasyHelp('reativou a linha', STR0003, 'Reativou a linha') //"reativou a linha"###"Atenção"###"Reativou a linha"
      setVisible(cActiveID + "-" + Alltrim(oMdl:GetValue("EKW_NCM")) + "-" + oMdl:GetValue("EKW_FDTLGL") + "-" + oMdl:GetValue("EKW_TRIBUT") + "-" + oMdl:GetValue("EKW_TIPO") + "-" + getPaisOri())
      If EKU->(ColumnPos("EKU_ATT_FL")) > 0
         If oFundLegal[cActiveID][oMdl:GetValue("EKW_FDTLGL")] <= 0
            setVisible(cActiveID + "-" + oMdl:GetValue("EKW_FDTLGL"))
         EndIf
         oFundLegal[cActiveID][oMdl:GetValue("EKW_FDTLGL")]++
      EndIf
EndCase

Return lRet

/*
Função     : setInvisible / setVisble
Objetivo   : Envia a chave do atributo que foi deletado ou recuperada a linha do grid de fundamntos legais, para tornar o atributo visível ou invisível
Autor      : THTS - Tiago Tudisco
Data       : Dez/2024
*/
Static Function setInvisible(cIdAtt)
oChannel:AdvPLToJS("setInvisible", cIdAtt)
Return

Static Function setVisible(cIdAtt)
oChannel:AdvPLToJS("setVisible", cIdAtt)
Return

/*
Função     : IncRegTrib
Objetivo   : Carregar os fundamento legais aos grids dos tributos, quando estiver vinculado a um Regime Tributário
Autor      : THTS - Tiago Tudisco
Data       : NOV/2024
*/
Function IncRegTrib(oModel, oEKWRegTri, cModelSWV)
Local nI
Local nJ := 0
Local aNames := oEKWRegTri['listaOpcional']:getNames()
Local oFundOpc := jsonObject():New()

oFundOpc['listaOpcional'] := {}
For nI := 1 To Len(aNames)
   If oEKWRegTri['listaOpcional'][aNames[nI]]:hasProperty('EKW_NCM')
      nJ++
      aAdd(oFundOpc['listaOpcional'], jSonObject():new())
      oFundOpc['listaOpcional'][nJ]['EKW_NCM']    := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_NCM']
      oFundOpc['listaOpcional'][nJ]['EKW_FDTLGL'] := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_FDTLGL']
      oFundOpc['listaOpcional'][nJ]['EKW_FDTDES'] := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_FDTDES']
      oFundOpc['listaOpcional'][nJ]['EKW_TRIBUT'] := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_TRIBUT']
      oFundOpc['listaOpcional'][nJ]['EKW_TIPO']   := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_TIPO']
      oFundOpc['listaOpcional'][nJ]['RECNOEKV']   := oEKWRegTri['listaOpcional'][aNames[nI]]['RECNOEKV']
      oFundOpc['listaOpcional'][nJ]['EKW_REGIME'] := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_REGIME']
      oFundOpc['listaOpcional'][nJ]['EKW_REGDES'] := oEKWRegTri['listaOpcional'][aNames[nI]]['EKW_REGDES']
   EndIf

Next

FLOpcTrib(oModel, oFundOpc, cModelSWV)
FreeObj(oFundOpc)
Return

/*
Função     : FLOpcTrib
Objetivo   : Carregar os fundamento legais aos grids dos tributos, quando o mesmo fundamento tiver mais de um tributo
Autor      : THTS - Tiago Tudisco
Data       : NOV/2024
*/
Static Function FLOpcTrib(oModel, oFundOpc, cModelSWV)
Local nI
Local oGridEKW
Local oModSWV
Local aSeek := {}
Local cHawb
Local cIDWV
Local cIdent
Local cIdentInfo
Local cDivider
Local cNcm
Local cFundLegal
Local cTributo
Local cTipo
Local cPais
Local nOrder 

default cModelSWV := "SWVDETAIL_TRIBUTACAO"

For nI := 1 To Len(oFundOpc['listaOpcional'])
   oGridEKW := oModel:GetModel(getGridEKW(oFundOpc['listaOpcional'][nI]['EKW_TRIBUT']))
   cHawb := oModel:GetModel(cModelSWV):getValue("WV_HAWB")
   cIDWV := oModel:GetModel(cModelSWV):getValue("WV_ID")
   cActiveID := cIDWV
   aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                                                  },;
               {"WV_HAWB"    , oModel:GetModel(cModelSWV):GetValue("WV_HAWB")     },;
               {"WV_INVOICE" , oModel:GetModel(cModelSWV):GetValue("WV_INVOICE")  },;
               {"WV_FORN"    , oModel:GetModel(cModelSWV):GetValue("WV_FORN")     },;
               {"WV_FORLOJ"  , oModel:GetModel(cModelSWV):GetValue("WV_FORLOJ")   },;
               {"WV_PO_NUM"  , oModel:GetModel(cModelSWV):GetValue("WV_PO_NUM")   },;
               {"WV_POSICAO" , oModel:GetModel(cModelSWV):GetValue("WV_POSICAO")  },;
               {"WV_SEQUENC" , oModel:GetModel(cModelSWV):GetValue("WV_SEQUENC")  }}
   oModSWV := oModel:getModel("SWVDETAIL")
   oModSWV:SeekLine(aSeek, .F., .T.)
   //EKW_FILIAL+EKW_HAWB+EKW_IDWV+EKW_NCM+EKW_FDTLGL+EKW_TRIBUT
   aSeek := {}
   aAdd(aSeek, {"EKW_FILIAL", xFilial("EKW")})
   aAdd(aSeek, {"EKW_HAWB"  , cHawb})
   aAdd(aSeek, {"EKW_IDWV"  , cIDWV})
   aAdd(aSeek, {"EKW_NCM"   , oFundOpc['listaOpcional'][nI]['EKW_NCM']})
   aAdd(aSeek, {"EKW_FDTLGL", oFundOpc['listaOpcional'][nI]['EKW_FDTLGL']})
   aAdd(aSeek, {"EKW_TRIBUT", oFundOpc['listaOpcional'][nI]['EKW_TRIBUT']})

   If !oGridEKW:SeekLine(aSeek, .F., .F.)
      If !(oGridEKW:Length() == 1 .And. Empty(oGridEKW:getValue("EKW_FDTLGL")))
         oGridEKW:AddLine()
      EndIf
      cNcm        := oFundOpc['listaOpcional'][nI]['EKW_NCM']
      cFundLegal  := oFundOpc['listaOpcional'][nI]['EKW_FDTLGL']
      cTributo    := oFundOpc['listaOpcional'][nI]['EKW_TRIBUT']
      cTipo       := oFundOpc['listaOpcional'][nI]['EKW_TIPO']
      cPais       := getPaisOri()
      oGridEKW:LoadValue("EKW_FILIAL", xFilial("EKW"))
      oGridEKW:LoadValue("EKW_HAWB"  , cHawb)
      oGridEKW:LoadValue("EKW_IDWV"  , cIDWV)
      oGridEKW:LoadValue("EKW_NCM"   , cNcm)
      oGridEKW:LoadValue("EKW_FDTLGL", cFundLegal)
      oGridEKW:LoadValue("EKW_FDTDES", oFundOpc['listaOpcional'][nI]['EKW_FDTDES'])
      oGridEKW:LoadValue("EKW_TRIBUT", cTributo)
      oGridEKW:LoadValue("EKW_REGIME", oFundOpc['listaOpcional'][nI]['EKW_REGIME'])
      oGridEKW:LoadValue("EKW_REGDES", oFundOpc['listaOpcional'][nI]['EKW_REGDES'])
      oGridEKW:LoadValue("EKW_TIPO"  , cTipo)

      EKV->(dbGoTo(oFundOpc['listaOpcional'][nI]['RECNOEKV']))
      oGridEKW:LoadValue("EKW_ATRIBU", EKV->EKV_ATRIBU)

      // Identificador da mercadoria
      If canUseApp()
         If EKU->(ColumnPos("EKU_ATT_FL")) > 0
            If !oFundLegal[cActiveID]:hasProperty(cFundLegal)
               cIdentInfo := cActiveID + "-" + cFundLegal + "_"
               nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
               LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + cFundLegal, "EKU_ATT_FL"), cIdentInfo, , oModSWV:GetValue("WV_AC"), oModSWV:GetValue("WV_SEQSIS"), nOrder)
               oFundLegal[cActiveID][cFundLegal] := 1
               oJsonPOUI['listaInformativos'] := oInfoAtt
            Else
               oFundLegal[cActiveID][cFundLegal]++
            EndIf
         EndIf
         cIdent   := cActiveID + "-" + Alltrim(cNcm) + "-" + cFundLegal + "-" + cTributo + "-" + cTipo + "-" + cPais + "_"
         cDivider := getTribName(cTributo) + " | " +  oFundOpc['listaOpcional'][nI]['EKW_REGIME'] + " - " + oFundOpc['listaOpcional'][nI]['EKW_REGDES'] + " | " +  cFundLegal + " - " +  oFundOpc['listaOpcional'][nI]['EKW_FDTDES']
         LP500ATMER(oJsonAtt, LP500GetInfo("EKV", 1, xFilial("EKV") + cNcm + cFundLegal + cTributo + cPais, "EKV_ATRIBU"), cIdent, cDivider)
         oJsonPOUI['listaAdicionais'] := oJsonAtt
         sendAttPOUI(oJsonPOUI)
      EndIf
   EndIf
Next

Return

/*
Função     : canUseApp
Objetivo   : Função para verificar se da pra abrir o App de Atributos
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function canUseApp()
Local lRet
If lAppLP500 == nil
   lRet := !IsBlind() .And. !FwIsInCallStack("LP501Estor") .and. !FwIsInCallStack("EICLP501") .And. TEOpenApp(.F., .T.) .And. Len(GetApoInfo("duimp-items.app")) > 0 .And. AvFlags("FUNDAMENTO_LEGAL_ITEM")
   lAppLP500 := lRet
Else
   lRet := lAppLP500
EndIf

Return lRet

/*
Função     : LPCallApp
Objetivo   : Montar o objeto de campos a ser enviado para o Angular montar a Lista de Atributos do Fundamento Legal
Retorno    : -
Parâmetros : oPanel  - Painel para a abertura da tela PO-UI
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function LPCallApp( oPanel )
	FWCallApp( "duimp-items", oPanel, , @oChannel, , "EICLP500")
Return .T.

/*
Função     : LP500ATMER
Objetivo   : Função que trata o arquivo json de mercadorias, montando o objeto POUI com os atributos a serem exibidos em tela
Parâmetros : oJsonAtt    - Objeto com os atributos a serem exibidos
             cMercadoria - String com o json de mercadorias do funamento legal a ser processado e montado o objeto POUI
             cIdent - String para identificar os atributos
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Dez/2024
*/
Function LP500ATMER(oJsonAtt, cMercadoria, cIdent, cDivider, cMercValor)
Local oJson       := JsonObject():new()
Local oMerc       := jsonObject():new()
Local oCond       := jsonObject():new()
Local oMercValor  := jsonObject():new()
Local nI
Local nY
Local oDominio
Local oCampo
Local oCondicao
Local cAtributo
Local nOrder := 0
Local cCondVal := ""
Local cCondAtt := ""
Local lDisabled := .F.

If !Empty(cMercadoria)
   oMerc:fromJson(cMercadoria)
   If !Empty(cMercValor)
      oMercValor:fromJson(cMercValor)
   EndIf
   If oMerc:hasProperty("mercadorias")
      oDominio := jsonObject():New()
      oDominio['listaDominio'] := {}
      For nI := 1 To Len(oMerc['mercadorias'])
         If oMerc["mercadorias"][nI]:hasProperty('atributos') .And. Len(oMerc["mercadorias"][nI]['atributos']) > 0
               For nY := 1 To Len(oMerc['mercadorias'][nI]['atributos'])
                  lDisabled := .F.
                  If oJson:hasProperty(oMerc['mercadorias'][nI]['atributos'][nY]['codigo'])
                     cAtributo := oMerc['mercadorias'][nI]['atributos'][nY]['codigo']
                     If oJson[cAtributo]:hasProperty('valoresLista') .And. !oJson[cAtributo]['valoresLista']:hasProperty(oMerc['mercadorias'][nI]['atributos'][nY]['valor'])
                           Aadd(oJson[cAtributo]['options'], JsonObject():new())
                           oJson[cAtributo]['options'][Len(oJson[cAtributo]['options'])]['label' ] := oMerc['mercadorias'][nI]['atributos'][nY]['valor'] + " - " + oMerc['mercadorias'][nI]['atributos'][nY]['descricaoValor']
                           oJson[cAtributo]['options'][Len(oJson[cAtributo]['options'])]['value' ] := oMerc['mercadorias'][nI]['atributos'][nY]['valor']
                           oJson[cAtributo]['valoresLista'][oMerc['mercadorias'][nI]['atributos'][nY]['valor']] := ""
                     EndIf
                  Else
                     nOrder := Len(oJsonAtt['listaAtributos']) + 1
                     If nY == 1 .And. Len(oMerc['mercadorias'][nI]['atributos']) > 1
                        cCondVal := oMerc['mercadorias'][nI]['atributos'][nY]['valor']
                        cCondAtt := cIdent + oMerc['mercadorias'][nI]['atributos'][nY]['codigo']
                        cCondCam := cIdent + oMerc['mercadorias'][nI]['atributos'][nY + 1]['codigo']

                        oCondicao := JsonObject():new()
                        oCondicao["operador"] :=  "=="
                        oCondicao["valor"]    := cCondVal
                        oCondicao["campo"]    := cCondCam
                        //lVisible := .F.

                        // Linhas comentadas pois não passavam no ADVPR e não foram deletadas para caso volte a ser útil
                        // If oCond:hasProperty(cCondAtt)
                        //    If aScan(oCond[cCondAtt], {|x| x['valor'] == cCondVal .And. x['campo'] == cCondCam}) == 0
                        //       aAdd(oCond[cCondAtt], oCondicao)
                        //    EndIf
                        // Else
                        oCond[cCondAtt] := {}
                        aAdd(oCond[cCondAtt], oCondicao)
                        // EndIf

                        FreeObj(oCondicao)

                     EndIf
                     oJson[oMerc['mercadorias'][nI]['atributos'][nY]['codigo']] := jsonObject():new()
                     oCampo := jSonObject():new()
                     oCampo['property']  := cIdent + oMerc['mercadorias'][nI]['atributos'][nY]['codigo']
                     oCampo['value']     := getPOUIValue(oMerc['mercadorias'][nI]['atributos'][nY]['codigo'], oMercValor)
                     oCampo['id_att']    := oMerc['mercadorias'][nI]['atributos'][nY]['codigo']
                     oCampo['label'   ]  := oMerc['mercadorias'][nI]['atributos'][nY]['descricaoCodigo']
                     oCampo['additionalHelpTooltip'] := oCampo['id_att']
                     
                     If nY == 1
                           oCampo['divider']   := cDivider
                     EndIf
                     oCampo['order']     :=  nOrder
                     oCampo['required']  := .T. //Tratar se o tipo for normal ou teto
                     oCampo['optional']  := .F. //Tratar se o tipo for Opcional
                     oCampo['gridColumns']   :=  6
                     oCampo['gridSmColumns'] :=  12
                     oCampo['condicaoPreenchimento'] := IIF(Empty(cCondAtt), .F., .T.)
                     oCampo['idwv'] := cActiveID
                     If !Empty(cCondAtt) .And. nY > 1
                           oCampo['condicionante'] := cCondAtt
                           lDisabled := Empty(oCampo['value'])
                     EndIf
                     oCampo['disabled']   := lDisabled
                     oCampo['deleted']   := .F.
                     oCampo['lastStatus'] := lDisabled
                     If FWNoAccent(UPPER(oMerc['mercadorias'][nI]['atributos'][nY]['tipoCodigo'])) == "DOMINIO DINAMICO"
                           oCampo['type'] := "options"
                           oCampo['options'] := {}
                           Aadd(oCampo['options'], JsonObject():new())
                           oCampo['options'][1]['label' ] := oMerc['mercadorias'][nI]['atributos'][nY]['valor'] + " - " + oMerc['mercadorias'][nI]['atributos'][nY]['descricaoValor']
                           oCampo['options'][1]['value' ] := oMerc['mercadorias'][nI]['atributos'][nY]['valor']
                           oCampo['valoresLista'] := jSonObject():new()
                           oCampo['valoresLista'][oMerc['mercadorias'][nI]['atributos'][nY]['valor']] := ""
                           oCampo['forceOptionsComponentType'] := 'select'
                     Else
                           oCampo['type'] := "number"
                     EndIf
                     oJson[oMerc['mercadorias'][nI]['atributos'][nY]['codigo']] := oCampo
                     aAdd(oJsonAtt['listaAtributos'],oCampo)
                     FreeObj(oCampo)
                  EndIf
               Next
               cCondicao := ""
         EndIf
      Next
   EndIf
   If Len(oCond:getnames()) > 0
      oJsonAtt['listaCondicao'][cCondAtt] := oCond[cCondAtt]
   EndIf
   FreeObj(oCond)
   FreeObj(oMerc)
EndIf
return

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
Função     : getPOUIValue
Objetivo   : Função que verifica se ja existe valores gravados para o atributo e carrega estes valores
Parâmetros : cCodAtt - Código do Atributo
             oMercValor - Objeto com os valores do atributo
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Dez/2024
*/
Static Function getPOUIValue(cCodAtt, oMercValor)
Local xRet := ""
Local nI

If oMercValor:hasProperty('atributos')
   For nI := 1 To Len(oMercValor['atributos'])
      If oMercValor['atributos'][nI]['codigo'] == cCodAtt
         xRet := oMercValor['atributos'][nI]['valor']
         Exit
      EndIf
   Next
EndIf
Return xRet

Static Function getValPOUI()
oChannel:AdvPLToJS("getValPOUI")
Return .T.

/*
Função     : getValCP / getvalLPCO
Objetivo   : Funções para pegar os valores de atributos digitados no catalogo e lpco e trazer para a duimp
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Jan/2025
*/
Static Function getValCP(cItemWV)
Local oQuery
Local cQuery
Local cAliasTmp := GetNextAlias()
Local oAtribItem

Default cItemWV := ""

cQuery := " SELECT "
cQuery += "   TMP.WV_ID, "
cQuery += "   TMP.YD_TEC, "
cQuery += "   TMP.EK9_IDPORT, "
cQuery += "   TMP.EK9_VATUAL, "
cQuery += "   EKG_CODOBJ, "
cQuery += "   EKG_FORMA, "
cQuery += "   EKC.R_E_C_N_O_ "
cQuery += " FROM "
cQuery +=     TETempName(cTmpAtrib) + " TMP INNER JOIN " + RetSQLName('EK9') + " EK9 ON (EK9_FILIAL = ? AND EK9.EK9_IDPORT = TMP.EK9_IDPORT AND EK9.EK9_VATUAL = TMP.EK9_VATUAL AND EK9.EK9_NCM = TMP.YD_TEC) " // 1
cQuery += "   INNER JOIN " + RetSQLName('EKC') + " EKC ON ( "
cQuery += "     EKC_FILIAL = ? " //2
cQuery += "     AND EKC_COD_I = EK9.EK9_COD_I "
cQuery += "   ) "
cQuery += "   INNER JOIN " + RetSQLName('EKG') +" EKG ON ( "
cQuery += "     EKG_FILIAL = ? " //3
cQuery += "     AND EKG_NCM = TMP.YD_TEC "
cQuery += "     AND EKG_COD_I = EKC.EKC_CODATR "
cQuery += "   ) "
cQuery += " WHERE "
cQuery += "   TMP.EK9_IDPORT <> ? " //4
cQuery += "   AND ( "
cQuery += "     EKG_CODOBJ LIKE ? " //5
cQuery += "     AND EKG_CODOBJ LIKE ? " //6
cQuery += "   ) "
cQuery += "   AND TMP.D_E_L_E_T_ = ? " //7
cQuery += "   AND EK9.D_E_L_E_T_ = ? " //8
cQuery += "   AND EKC.D_E_L_E_T_ = ? " //9
cQuery += "   AND EKG.D_E_L_E_T_ = ? " //10
If !Empty(cItemWV)
   cQuery += "   AND TMP.WV_ID = ? " //11
EndIf
cQuery += " ORDER BY TMP.WV_ID "

oQuery := FWPreparedStatement():New(cQuery)

oQuery:SetString(1,  xFilial('EK9')) //EK9_FILIAL
oQuery:SetString(2,  xFilial('EKC')) //EKC_FILIAL
oQuery:SetString(3,  xFilial('EKG')) //EKG_FILIAL
oQuery:SetString(4,  ' ') //EK9_IDPORT
oQuery:SetString(5,  '%5%') //EKG_CODOBJ
oQuery:SetString(6,  '%7%') //EKG_CODOBJ
oQuery:SetString(7,  ' ') //TMP.D_E_L_E_T_
oQuery:SetString(8,  ' ') //EK9.D_E_L_E_T_
oQuery:SetString(9,  ' ') //EKC.D_E_L_E_T_
oQuery:SetString(10, ' ') //EKG.D_E_L_E_T_
If !Empty(cItemWV)
   oQuery:SetString(11, cItemWV) //WV_ID
EndIf

cQuery := oQuery:GetFixQuery()
MPSysOpenQuery(cQuery, cAliasTmp)

While (cAliasTmp)->(!EOF())
   EKC->(dbGoTo((cAliasTmp)->(R_E_C_N_O_)))
   oAtribItem := JsonObject():New()
   oAtribItem['atributo']  := Alltrim(EKC->EKC_CODATR)
   oAtribItem['valor']     := getFormVal(Alltrim((cAliasTmp)->(EKG_FORMA)), Alltrim(EKC->EKC_VALOR), 'advpl')
   
   If oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']:hasProperty('atributos')
      aAdd(oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'], JsonObject():new())
      oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'][Len(oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'])] := oAtribItem
   Else
      oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'] := {}
      aAdd(oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'], JsonObject():new())
      oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'][Len(oVlCodObj[(cAliasTmp)->(WV_ID)]['catalogo']['atributos'])] := oAtribItem
   EndIf
   freeObj(oAtribItem)
   (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(dbCloseArea())
freeObj(oQuery)
Return

Static Function getvalLPCO(cIdWV, cOrgao, cFormul, cIdLpco)
Local oQuery
Local cQuery
Local cAliasTmp := GetNextAlias()
Local oAtribItem
Local nPos := 0

Default cIdWV := ""
Default cOrgao := ""
Default cFormul := ""
Default cIdLpco := ""

cQuery := " SELECT "
cQuery += "   TMP.WV_HAWB, "
cQuery += "   TMP.WV_INVOICE, "
cQuery += "   TMP.WV_PO_NUM, "
cQuery += "   TMP.WV_POSICAO, "
cQuery += "   TMP.WV_SEQUENC, "
cQuery += "   TMP.WV_ID, "
cQuery += "   TMP.WV_NCM, "
cQuery += "   TMP.EKQ_ORGANU, "
cQuery += "   TMP.EKQ_FRMLPC, "
cQuery += "   TMP.EKQ_LPCO, "
cQuery += "   TMP.EKQ_VERSAO, "
cQuery += "   TMP.EKQ_IDLPCO, "
cQuery += "   EKG.EKG_FORMA, "
cQuery += "   EKP_SQCPOF,  "
cQuery += "   EKP_CDCPOF,  "
cQuery += "   EKP.R_E_C_N_O_  "
cQuery += " FROM  "
cQuery +=     TETempName(cTmpLpco) + " TMP "
cQuery += "   INNER JOIN " + RetSQLName("EKO") + " EKO ON ( "
cQuery += " 	EKO_FILIAL = ? " //1
cQuery += " 	AND EKO_ORGANU = TMP.EKQ_ORGANU "
cQuery += " 	AND EKO_FRMLPC = TMP.EKQ_FRMLPC "
cQuery += " 	AND EKO_ID     = TMP.EKQ_IDLPCO "
cQuery += " 	AND EKO_LPCO   = TMP.EKQ_LPCO "
cQuery += " 	AND EKO_VERSAO = TMP.EKQ_VERSAO) "
cQuery += "   INNER JOIN " + RetSQLName("EKP") + " EKP ON ( "
cQuery += "     EKP_FILIAL = ? " //2
cQuery += "     AND EKP_ID = EKO_ID "
cQuery += "     AND EKP_VERSAO = EKO_VERSAO "
cQuery += "     AND EKP_IDCPOF = ? " //3
cQuery += "   ) "
cQuery += "   INNER JOIN " + RetSQLName("EKG") + " EKG ON ( "
cQuery += "     EKG_FILIAL = ? " //4
cQuery += "     AND EKG_NCM = TMP.WV_NCM "
cQuery += "     AND EKG_COD_I = EKP.EKP_CDCPOF "
cQuery += "   ) "
cQuery += " WHERE "
cQuery += " 	   TMP.EKQ_LPCO <> ? " //5
cQuery += "   AND TMP.EKQ_VERSAO <> ? "//6
cQuery += "   AND ( "
cQuery += "     EKG_CODOBJ LIKE ? " //7
cQuery += "     AND EKG_CODOBJ LIKE ? " //8
cQuery += "   ) "
cQuery += "   AND TMP.D_E_L_E_T_ = ? " //9
cQuery += "   AND EKO.D_E_L_E_T_ = ? " //10
cQuery += "   AND EKP.D_E_L_E_T_ = ? " //11
cQuery += "   AND EKG.D_E_L_E_T_ = ? " //12
If !Empty(cIdWV)
   cQuery += "   AND TMP.WV_ID = ? " //13
EndIf
If !Empty(cOrgao)
   cQuery += "   AND TMP.EKQ_ORGANU = ? " //14
EndIf
If !Empty(cFormul)
   cQuery += "   AND TMP.EKQ_FRMLPC = ? " //15
EndIf
If !Empty(cIdLpco)
   cQuery += "   AND TMP.EKQ_IDLPCO = ? " //16
EndIf
cQuery += " ORDER BY "
cQuery += "   TMP.WV_ID, "
cQuery += "   TMP.EKQ_ORGANU, "
cQuery += "   TMP.EKQ_FRMLPC, "
cQuery += "   EKP.EKP_SQCPOF "

oQuery := FWPreparedStatement():New(cQuery)

oQuery:SetString(1,  xFilial('EKO')) //EKO_FILIAL
oQuery:SetString(2,  xFilial('EKP')) //EKP_FILIAL
oQuery:SetString(3,  'listaCamposNcm') //EKP_IDCPOF
oQuery:SetString(4,  xFilial('EKG')) //EKG_FILIAL
oQuery:SetString(5,  ' ') //TMP.EKQ_LPCO
oQuery:SetString(6,  ' ') //TMP.EKQ_VERSAO
oQuery:SetString(7,  '%5%') //EKG_CODOBJ
oQuery:SetString(8,  '%6%') //EKG_CODOBJ
oQuery:SetString(9,  ' ') //TMP.D_E_L_E_T_
oQuery:SetString(10, ' ') //EKO.D_E_L_E_T_
oQuery:SetString(11, ' ') //EKP.D_E_L_E_T_
oQuery:SetString(12, ' ') //EKG.D_E_L_E_T_
If !Empty(cIdWV)
   oQuery:SetString(13, cIdWV) //WV_ID
EndIf
If !Empty(cOrgao)
   oQuery:SetString(14, cOrgao) //EKQ_ORGANU
EndIf
If !Empty(cFormul)
   oQuery:SetString(15, cFormul) //EKQ_FRMLPC
EndIf
If !Empty(cIdLpco)
   oQuery:SetString(16, cIdLpco) //EKQ_IDLPCO
EndIf

cQuery := oQuery:GetFixQuery()
MPSysOpenQuery(cQuery, cAliasTmp)

While (cAliasTmp)->(!EOF())
   nPos := aScan( oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'], {|x| x['orgao'] == (cAliasTmp)->(EKQ_ORGANU) .And. x['formLpco'] == (cAliasTmp)->(EKQ_FRMLPC)})
   If nPos > 0
      EKP->(dbGoTo((cAliasTmp)->(R_E_C_N_O_)))
      oAtribItem := JsonObject():New()
      oAtribItem['atributo']  := Alltrim(EKP->EKP_CDCPOF)
      oAtribItem['valor']     := getFormVal(Alltrim((cAliasTmp)->(EKG_FORMA)), Alltrim(EKP->EKP_VLCPOF), 'advpl')

      If oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]:hasProperty('atributos')
         aAdd(oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'], JsonObject():new())
         oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'][Len(oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'])] := oAtribItem
      Else
         oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'] := {}
         aAdd(oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'], JsonObject():new())
         oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'][Len(oVlCodObj[(cAliasTmp)->(WV_ID)]['lpco'][nPos]['atributos'])] := oAtribItem
      EndIf
      freeObj(oAtribItem)
      nPos := 0
   EndIf
   (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(dbCloseArea())
freeObj(oQuery)
Return

/*
Função     : sendAttPOUI
Objetivo   : Função que faz o envio dos dados do objeto de atributos para o POUI exibir em tela
Parâmetros : oJsonAtt    - Objeto com os atributos a serem exibidos
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Dez/2024
*/
Static Function sendAttPOUI(oJsonPOUI)
Local cPOUIJson := ""
Local cListaAdic := ""
Local cListaInfo := ""
Local cListaComp := ""

setMsgPOUI(STR0188, "false")//"Atualizando informações dos atributos"

oJsonAtt['listaCompostos'] := {}
//oInfoAtt['listaCompostos'] := {}

oJsonPOUI['ncmInfoDesc'] := ""
oJsonPOUI['ncmInfoCod']  := ""
oJsonPOUI['activeID']    := cActiveID

oJsonPOUI['listaValores'] := oVlCodObj

cListaComp := StrTran(oJsonPOUI['listaComplementares']:toJson(), '".T."', 'true')
cListaComp := StrTran(cListaComp, '".F."', 'false')
// Removendo para evitar processamento duplicado
oJsonPOUI['listaComplementares'] := JsonObject():New()

cListaAdic := StrTran(oJsonAtt:toJson(), '".T."', 'true')
cListaAdic := StrTran(cListaAdic, '".F."', 'false')

cListaInfo := StrTran(oInfoAtt:toJson(), '".T."', 'true')
cListaInfo := StrTran(cListaInfo, '".F."', 'false')

cPOUIJson := StrTran(oJsonPOUI:toJson(), '".T."', 'true')
cPOUIJson := StrTran(cPOUIJson, '".F."', 'false')

oChannel:AdvPLToJS("loadComplementares", cListaComp )
oChannel:AdvPLToJS("loadAdicionais",     cListaAdic )
oChannel:AdvPLToJS("loadInformativos",   cListaInfo )
oChannel:AdvPLToJS("listaAtributos",     cPOUIJson )

oChannel:AdvPLToJS("sendAlertEsconde", "")
Return

/*
Função     : setMsgPOUI
Objetivo   : Função que faz o envio dos dados do objeto de atributos para o POUI exibir em tela
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Dez/2024
*/
Static Function setMsgPOUI(cMsg, isLock)
Local oMsgPOUI

oMsgPOUI := JsonObject():New()
oMsgPOUI['msg']     := cMsg
oMsgPOUI['isLock']  := isLock

oChannel:AdvPLToJS("sendAlertExibe",oMsgPOUI:toJson())
FreeObj(oMsgPOUI)
Return

Static Function setAtuLPCO(oModelSWV, oModelEKQ, cAction)
Local lTemDados := .F.

If cAction == "UNDELETE" .And. !Empty(oModelEKQ:getValue('EKQ_LPCO')) .And. !Empty(oModelEKQ:getValue('EKQ_VERSAO'))
   lTemDados := .T.
   atuStatPOUI("lpco", oModelSWV:GetValue("WV_ID"), lTemDados, oModelEKQ, oModelSWV)
EndIf

If cAction == "DELETE" .And. !Empty(oModelEKQ:getValue('EKQ_LPCO')) .And. !Empty(oModelEKQ:getValue('EKQ_VERSAO'))
   lTemDados := .F.
   atuStatPOUI("lpco", oModelSWV:GetValue("WV_ID"), lTemDados, oModelEKQ, oModelSWV)
EndIf

Return

Static Function atuStatPOUI(cTipo, cID, lTemDado, oModel, oModelSWV)
Local oContent := JsonObject():New()
Local cJson
Local nPos
If canUseApp()
   oContent['tipo']     := cTipo
   oContent['id']       := cID
   oContent['temDado']  := lTemDado
   oContent['ncm']      := oModelSWV:GetValue("WV_NCM")

   If cTipo == 'catalogo' //oModel == oModelEIJ
      oVlCodObj[cId]['catalogo']['catalogo'] := oModel:getValue("EIJ_IDPTCP")
      oVlCodObj[cId]['catalogo']['versao']   := oModel:getValue("EIJ_VRSACP")
      setNcmAtri(cTmpAtrib, "CATALOGO", cID, "", oVlCodObj[cId]['catalogo']['catalogo'], oVlCodObj[cId]['catalogo']['versao'])
      If lTemDado //Atualiza os atributos do catalogo
         oVlCodObj[cId]['catalogo']['atributos'] := {}
         getValCP(cID)
         oContent['listaValores'] := aClone(oVlCodObj[cId]['catalogo']['atributos'])
      Else
         If oVlCodObj[cId]['catalogo']:hasProperty('atributos')
            oContent['listaValores'] := aClone(oVlCodObj[cId]['catalogo']['atributos'])
            oVlCodObj[cId]['catalogo']['atributos'] := {}
         EndIf
      EndIf
   ElseIf cTipo == 'lpco' //oModel == oModelEKQ
      nPos := aScan(oVlCodObj[cId]['lpco'], {|x| x['orgao'] == oModel:getValue("EKQ_ORGANU") .And. x['formLpco'] == oModel:getValue("EKQ_FRMLPC")})
      If nPos > 0
         oVlCodObj[cId]['lpco'][nPos]['orgao']     := oModel:getValue("EKQ_ORGANU")
         oVlCodObj[cId]['lpco'][nPos]['formLpco']  := oModel:getValue("EKQ_FRMLPC")
         oVlCodObj[cId]['lpco'][nPos]['lpco']      := oModel:getValue("EKQ_LPCO")
         oVlCodObj[cId]['lpco'][nPos]['versao']    := oModel:getValue("EKQ_VERSAO")
         setLpcoAtr(cTmpLpco, "EKQ", oModelSWV:GetValue("WV_HAWB"), oModelSWV:GetValue("WV_INVOICE"), oModelSWV:GetValue("WV_PO_NUM"), oModelSWV:GetValue("WV_POSICAO"), oModelSWV:GetValue("WV_SEQUENC"), cID, oModelSWV:GetValue("WV_NCM"), oVlCodObj[cId]['lpco'][nPos]['orgao'], oVlCodObj[cId]['lpco'][nPos]['formLpco'], oVlCodObj[cId]['lpco'][nPos]['lpco'], oVlCodObj[cId]['lpco'][nPos]['versao'], oModel:getValue("EKQ_IDLPCO"))
         If lTemDado //Atualiza os atributos do lpco
            oVlCodObj[cId]['lpco'][nPos]['atributos'] := {}
            getValLPCO(cID, oModel:getValue("EKQ_ORGANU"), oModel:getValue("EKQ_FRMLPC"), oModel:getValue("EKQ_IDLPCO"))
            oContent['listaValores'] := aClone(oVlCodObj[cId]['lpco'][nPos]['atributos'])
         Else
            If oVlCodObj[cId]['lpco'][nPos]:hasProperty('atributos')
               oContent['listaValores'] := aClone(oVlCodObj[cId]['lpco'][nPos]['atributos'])
               oVlCodObj[cId]['lpco'][nPos]['atributos'] := {}
            EndIf
         EndIf
      Else
         If Empty(oVlCodObj[cId]['lpco'])
            oVlCodObj[cId]['lpco'] := {}
         EndIf
         aAdd(oVlCodObj[cId]['lpco'], jSonObject():new())
         nPos := Len(oVlCodObj[cId]['lpco'])
         // oVlCodObj[cId]['lpco'][nPos] := {}
         oVlCodObj[cId]['lpco'][nPos]['orgao']     := oModel:getValue("EKQ_ORGANU")
         oVlCodObj[cId]['lpco'][nPos]['formLpco']  := oModel:getValue("EKQ_FRMLPC")
         oVlCodObj[cId]['lpco'][nPos]['lpco']      := oModel:getValue("EKQ_LPCO")
         oVlCodObj[cId]['lpco'][nPos]['versao']    := oModel:getValue("EKQ_VERSAO")
         setLpcoAtr(cTmpLpco, "EKQ", oModelSWV:GetValue("WV_HAWB"), oModelSWV:GetValue("WV_INVOICE"), oModelSWV:GetValue("WV_PO_NUM"), oModelSWV:GetValue("WV_POSICAO"), oModelSWV:GetValue("WV_SEQUENC"), cID, oModelSWV:GetValue("WV_NCM"), oModel:getValue("EKQ_ORGANU"), oModel:getValue("EKQ_FRMLPC"), oModel:getValue("EKQ_LPCO"), oModel:getValue("EKQ_VERSAO"), oModel:getValue("EKQ_IDLPCO"))
         If lTemDado //Atualiza os atributos do lpco
            getValLPCO(cID, oModel:getValue("EKQ_ORGANU"), oModel:getValue("EKQ_FRMLPC"), oModel:getValue("EKQ_IDLPCO"))
            oContent['listaValores'] := aClone(oVlCodObj[cId]['lpco'][nPos]['atributos'])
         EndIf
      EndIf
   EndIf

   cJson := StrTran(oContent:toJson(), '".T."', 'true')
   cJson := StrTran(cJson, '".F."', 'false')

   oChannel:AdvPLToJS("atualizaStatus", cJson)
EndIf
freeObj(oContent)
Return

/*
Função     : LP500ATINF
Objetivo   : Monta objeto com os atributos informativos do Fundamento Legal
Autor      : Tiago Tudisco
Data/Hora  : Junho/2025
*/
Function LP500ATINF(oAttCompl, cJsonInfo, cIdent, cInfoValor, cAto, cSeqSis, nOrder)
Local oDePara     := TETypePOUI() //De para com os tipos de campos
Local oInformati  := jsonObject():New()
Local oInfoValor  := jsonObject():new()
Local oComposto   := jsonObject():New()
Local oCondicao   := jSonObject():New()
Local oCampo
Local oDominio
Local oCondFilho
Local oAttCP
Local oAttCond
Local nPos
Local lComposto
Local lTemCondicao
Local dVigencia
Local cDivider := ""
Local aNames
Local nI
Local nY
Local nComp
Local lDisabled
Local cValue
Local xCondicion
Local cCondicao := ""
Local cAttCond
Local cCodObj
Local xObjetivos
Local lPUProd := EasyGParam("MV_EIC0074",.F.,"1") == "1"
Local aVisible := {} //Deixar com visible falso
Local cAttSeq := ""
Local lMultiVal

Default nOrder := 0

If !Empty(cJsonInfo)
   If lPUProd
      aVisible := {ATT_ATO_SUSP, ATT_ATO_ISEN, ATT_ATO_ITEM}
   Else
      aVisible := {ATT_ATO_SUSP_VAL, ATT_ATO_ISEN_VAL, ATT_ATO_ITEM_VAL}
   EndIf
   oInformati:fromJson(cJsonInfo)
   If !Empty(cInfoValor)
      oInfoValor:fromJson(cInfoValor)
   EndIf
   If oInformati:hasProperty("listaAtributos") .And. Len(oInformati['listaAtributos']) > 0

      //oAttCompl['listaAtributos'] := {}
      //oAttCompl['listaCompostos'] := {}
      oComposto['listaComposto'] := jSonObject():New()
      oCondicao['listaCondicao'] := oInfoAtt['listaCondicao']
      nI := 1
      While nI <= Len(oInformati['listaAtributos'])
         oCampo := jsonObject():New()
         lComposto := .F.
         lTemCondicao := .F.
         nOrder++
         //Trata os dominios do atributo quando tiver
         If oInformati['listaAtributos'][nI]:hasProperty('dominio') .And. Len(oInformati['listaAtributos'][nI]['dominio']) > 0
            oDominio  := jsonObject():New()
            oDominio['listaDominio'] := {}
            For nY := 1 To Len(oInformati['listaAtributos'][nI]['dominio'])
               aAdd(oDominio['listaDominio'], JsonObject():new())
               nPos := Len(oDominio['listaDominio'])
               oDominio['listaDominio'][nPos]['label' ] := Alltrim(oInformati['listaAtributos'][nI]['dominio'][nY]['descricao'])
               oDominio['listaDominio'][nPos]['value' ] := Alltrim(oInformati['listaAtributos'][nI]['dominio'][nY]['codigo'])
            Next
         EndIf

         If Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']) == ATT_COMPOSTO
            oAttCP := jsonObject():New()
            oAttCP['label'] := Alltrim(oInformati['listaAtributos'][nI]['nomeApresentacao'])
            oAttCP['listaAtributosCompostos'] := {}
            oComposto['listaComposto'][cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo'])] := oAttCP

            FreeObj(oAttCP)
            lComposto := .T.
            If oInformati['listaAtributos'][nI]:hasProperty('listaSubatributos') .And. valtype(oInformati['listaAtributos'][nI]['listaSubatributos']) == "A" .And. Len(oInformati['listaAtributos'][nI]['listaSubatributos']) > 0
               For nY := 1 To Len(oInformati['listaAtributos'][nI]['listaSubatributos'])
                  aAdd(oInformati['listaAtributos'], JsonObject():new())
                  nPos := Len(oInformati['listaAtributos'])
                  oInformati['listaAtributos'][nI]['listaSubatributos'][nY]['condicionante'] := cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo'])
                  oInformati['listaAtributos'][nPos] := oInformati['listaAtributos'][nI]['listaSubatributos'][nY]
               Next
            EndIf
         EndIf

         //oInformati['listaAtributos'][nI]['condicionante'] := ""
         If oInformati['listaAtributos'][nI]:hasProperty('atributoCondicionante') .And. oInformati['listaAtributos'][nI]['atributoCondicionante'] .And. Len(oInformati['listaAtributos'][nI]['condicionados']) > 0
            //Pegar o atributo do array condicionados e adicionar ao final do array oInformati['listaAtributos'].
            //Gravar os dados necessários dele como condicionado do principal e deixar seguir o fluxo normal
            cCondicao := ""
            cAttCond  := ""
            xCondicion := oInformati['listaAtributos'][nI]['condicionados']
            if xCondicion != nil .and. valtype(xCondicion) == "A"
               for nComp := 1 to len(xCondicion)
                  oAttCond := xCondicion[nComp]
                  cCondicao := oAttCond:GetJsonText('condicao')
                  cAttCond  := cIdEnt + Alltrim(oAttCond['atributo']['codigo'])
                  aAdd(oInformati['listaAtributos'], JsonObject():new())
                  nPos := Len(oInformati['listaAtributos'])
                  oAttCond['atributo']['condicionante'] := cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo'])
                  oAttCond['atributo']['esconde'] := .T.
                  oInformati['listaAtributos'][nPos] := oAttCond['atributo']
                  FwFreeObj(oAttCond)

                  If !Empty(cCondicao)
                     lTemCondicao := .T.
                     oCondFilho := JsonObject():new()
                     If !oCondicao['listaCondicao']:hasProperty(cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo']))
                        oCondicao['listaCondicao'][cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo'])] := {}
                     EndIf
                     oCondFilho:FromJson(Alltrim(cCondicao))
                     oCondFilho['campo'] := Alltrim(cAttCond)
                     aAdd(oCondicao['listaCondicao'][cIdEnt + Alltrim(oInformati['listaAtributos'][nI]['codigo'])], oCondFilho)
                     FreeObj(oCondFilho)
                  EndIf
               next
               FwFreeArray(xCondicion)
            EndIf
         EndIf

         If !lComposto
            //Chama função que vai monstar o objeto dos Campos
            cargaInfPO(@oCampo, oInformati['listaAtributos'][nI], nOrder == 1, oDePara, nOrder, cDivider, oDominio, .F., cIdent)

            //Objetivos
            cCodObj := ''
            xObjetivos	:= oInformati['listaAtributos'][nI]:getJsonObject('objetivos')
            if xObjetivos != nil
               For nComp := 1 To Len(xObjetivos)
                  cCodObj += GetJsonCpo(xObjetivos[nComp],'codigo')//xObjetivos[nObj]:GetJsonText('codigo')
                  If nComp < Len(xObjetivos)
                     cCodObj += ';'
                  EndIf
               Next
               FwFreeArray(xObjetivos)
            EndIf

            //Valida atributos bloqueados quando for alteração
            lSeekVal := .F. //Valida se os atributos são comuns para Catalogo e LPCO
            lDisabled := .F.
            lMultiVal := oInformati['listaAtributos'][nI]['multivalorado'] .And. Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']) == ATT_LISTA_ESTATICA
            If !Empty(cValue := getValoratt(SW6->W6_HAWB, cActiveID, Alltrim(oInformati['listaAtributos'][nI]['codigo']), Alltrim(cCodObj), @lSeekVal, @lDisabled, "9", cInfoValor, , lMultiVal))
               If lMultiVal
                  oCampo['value'] := IIF(Valtype(cValue) == "A",getFormVal(Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']), cValue, 'advpl'),strTokArr(getFormVal(Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']), cValue, 'advpl'), ";"))
               Else
                  oCampo['value'] := IIF(Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']) == ATT_BOOLEANO, cValue, getFormVal(Alltrim(oInformati['listaAtributos'][nI]['formaPreenchimento']), cValue, 'advpl'))
               EndIf
            EndIf

            oCampo['disabled'] := lDisabled
            // Valida se tem condição para deixar invisivel ao inicializar
            If oInformati['listaAtributos'][nI]:hasProperty('esconde') .And. oInformati['listaAtributos'][nI]['esconde'] .And. (!oCampo:hasProperty('value') .Or. Empty(oCampo['value']))
               oCampo['disabled']   := .T.
               oCampo['lastStatus'] := .T.
            EndIf

            If aScan(aVisible, {|x| x == Alltrim(oInformati['listaAtributos'][nI]['codigo'])}) > 0
               //VALIDACAO
               //ATT_15165 - "Número Ato Concessório (AC) Suspensão
               //ATT_15185 - "Número Ato Concessório (AC) Isensão"
               //ATT_15186 - "Número Item Ato Concessório (AC)"
               //PRODUCAO
               //ATT_11362 - "Número Ato Concessório (AC) Suspensão
               //ATT_11380 - "Número Ato Concessório (AC) Isensão"
               //ATT_11382 - "Número Item Ato Concessório (AC)"
               IIF(lPUProd, cAttSeq := ATT_ATO_ITEM, cAttSeq := ATT_ATO_ITEM_VAL)
               oCampo['disabled']    := .T.
               If Empty(oCampo['value']) .Or. Alltrim(oCampo['value']) != IIF(Alltrim(oInformati['listaAtributos'][nI]['codigo']) == cAttSeq, cSeqSis, cAto)
                  oCampo['value'] := AllTrim(IIF(Alltrim(oInformati['listaAtributos'][nI]['codigo']) == cAttSeq, cSeqSis, cAto))
               EndIf
            EndIf

            If oCampo['status'] == "EXPIRADO"
               dVigencia := if( !empty(oInformati['listaAtributos'][nI]:GetJsonText('dataFimVigencia')), SToD(StrTran(oInformati['listaAtributos'][nI]:GetJsonText('dataFimVigencia'),'-','')), CToD("  /  /    "))
               oCampo['disabled'] := .T.
               oCampo['help']     := STR0170 + DToC(dVigencia) + STR0171 //"Este atributo expirou em "####" e será excluído."
            EndIf
         EndIf
         If inComposto(oComposto, Alltrim(oInformati['listaAtributos'][nI]['condicionante'])) //Verifica se o Atributo pertence a um atributo Composto
            //Se é um filho de composto, armazera para montar depois
            oAttCP := oComposto['listaComposto']:GetJsonObject(Alltrim(oInformati['listaAtributos'][nI]['condicionante']))
            If ValType(oAttCP) <> "U"
               aAdd(oAttCP['listaAtributosCompostos'], oCampo)
            EndIf         
         ElseIf !lComposto
            aAdd(oAttCompl['listaAtributos'], oCampo)
         EndIf
         FreeObj(oDominio)
         FreeObj(oCampo)
         nI++
      End

      //Trata os Atributos Compostos, para que fiquem por último
      If Len(aNames := oComposto['listaComposto']:GetNames()) > 0
         For nI := 1 To Len(aNames)
            For nY := 1 To Len(oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'])
               If nY == 1 //Adicione o Divider
                  oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY]['divider'] := oComposto['listaComposto'][aNames[nI]]['label']
               EndIf
               aAdd(oAttCompl['listaCompostos'], oComposto['listaComposto'][aNames[nI]]['listaAtributosCompostos'][nY])
            Next
         Next
      EndIf

      If Len(aNames := oCondicao['listaCondicao']:GetNames()) > 0
         For nI := 1 To Len(aNames)
            If (nPos := aScan(oAttCompl['listaAtributos'], {|X| X['property'] == aNames[nI]})) > 0
               oAttCompl['listaAtributos'][nPos]['condicaoPreenchimento'] := .T.
            EndIf
         Next
      EndIf
      oAttCompl['listaCondicao'] := oCondicao['listaCondicao']
   EndIf
EndIf

Return

Static Function GetJsonCpo(oObj,cTag)
Local cRet
Local cInfo
local cInfDecode

cInfo := oObj:GetJsonText(cTag)
If Alltrim(cInfo) == 'null' .Or. Empty(cInfo)
	cRet := " "
Else
	cInfDecode := DecodeUTF8(cInfo)
	cRet := if( cInfDecode == nil, cInfo, cInfDecode)
EndIf
Return cRet

Static Function AttDisable(lNoEdit)
Local cNoEdit := IIF(lNoEdit, "false", "true")
lCpPOUIOK := .F.
oChannel:AdvPLToJS("alteraAtributos", cNoEdit)
Return

/*
Função     : JsToAdvpl
Objetivo   : Função stática para comunicação entre o PO-UI e o Protheus
Parâmetros : oWebChannel - Objeto do WebChannel para enviar dados para o angular
             cType       - Identificação da chamada recebida do angular
             cContent    - Conteúdo recebido do angular
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function JsToAdvpl(oWebChannel,cType,cContent)
Local oPreLoad
// Local oModel
// Local oModelEIJ
Local oTrataRet
// Local lAlteraAt

Do Case
   Case cType == 'preLoad'
      oPreLoad := JsonObject():New()
      oPreLoad['msgLoading']        := STR0189//"Carregando informações..."
      oPreLoad['isHideLoading']     := "false"
      oPreLoad['inclusao']          := "true"//IIF(Inclui, "true", "false")
      oPreLoad['noLabelComplementares']  := STR0190//"Sem atributos complementares."
      oPreLoad['noLabelInformativos']    := STR0191//"Sem atributos informativos."
      oPreLoad['noLabelAdicionais']      := STR0192//"Sem atributos adicionais."
      oPreLoad['noValue']  := ""
      oWebChannel:AdvPLToJS('overLoad', oPreLoad:toJson())
      FreeObj(oPreLoad)

   Case cType == 'retLoadAtributos'
      lPOUIOKLD := .T.

   Case cType == 'retInvisible'
      lPOUIRetOK := .T.

   Case cType == 'retVisible'
      lPOUIRetOK := .T.
   
   Case cType == 'retValPOUI'
      oTrataRet := JsonObject():New()
      oTrataRet:FromJson(cContent)
      oValorAtt := oTrataRet
      lPOUIRetOK := .T.
      FreeObj(oTrataRet)

EndCase

Return .T.


/*/{Protheus.doc} loadOnActive
Função para carregar os atributos ao ativar o item
@type function
@version  1.0.0
@author wilsimar
@since 15/09/2025
@param oModel, object, modelo de dados com todos os submodelos
/*/
Static Function loadOnActive(oModel)
local nInvoice as numeric
local nItem as numeric
local nTotalInvoice as numeric
local nTotalItems as numeric
local oModSW9 as object
local oModSWV as object
local oModLdTrb as object
local aModels as array
local cModel as character
local nModel as numeric
local nOperation as numeric

   nOperation := oModel:getOperation()

   //recupera os submodelos que devem ser gravados
   aModels:= getModelsUpdate(oModel, "SWVDETAIL")
   
   oModSW9:= oModel:getModel("SW9DETAIL")
   nTotalInvoice:= oModSW9:Length(.T.)

   //para cada invoice, marcar os dados dos itens quando alterados
   for nInvoice:= 1 to nTotalInvoice
      oModSW9:goLine(nInvoice)

      //para cada item, checar e marcar os submodelos como alterados
      oModSWV:= oModel:getModel("SWVDETAIL")
      nTotalItems:= oModSWV:Length(.T.)

      if nOperation == MODEL_OPERATION_UPDATE
         oModLdTrb:= oModel:getModel("GRPDETAIL_TRIBUTACAO")
      endif

      for nItem:= 1 to nTotalItems

         oModSWV:goLine(nItem)

         //tratamentos de load de dados dos atributos para os apps DUIMP

         //atributos dos itens da duimp (informativos)
         LP500SWVLoad(oModSWV, nItem == nTotalItems)

         if nOperation == MODEL_OPERATION_UPDATE
            //replicar dados para o modelo de grupo de tributação
            LP500LdTrb(oModLdTrb, "GRPDETAIL_TRIBUTACAO", , , , , , nItem == 1)
         endif

         for nModel:= 1 to len(aModels)

            cModel:= aModels[nModel]
            loadLine(cModel, oModel:getModel(cModel), oModel)

         next

      next
   
   next

   oModSW9:goLine(1)
   oModSWV:goLine(1)
Return .T.

/*/{Protheus.doc} getModelsUpdate
recupera os submodelos que devem ser gravados pelo commit
@type function
@version  1.0.0
@author wilsimar
@since 12/23/2024
@param oModel, object, modelo de dados
@return variant, array com os submodelos que devem ser gravados
/*/
static function getModelsUpdate(oModel, cModel)
local aDependecyModels as array
local aModels as array

   //recupera os submodelos que são dependências dos itens
   aDependecyModels:= oModel:getDependency(cModel)

   aModels:= {}
   AEval(aDependecyModels, {|aModel| AAdd(aModels, aModel[MODEL_STRUCT_ID])} )

return aClone(aModels)

/*/{Protheus.doc} loadLine
Carrega os dados de atributos dos submodelos do tipo FWFORMFIELDS e FWFORMGRID
@type function
@version  1.0.0
@author wilsimar
@since 15/09/2025
@param cModel, character, nome do submodelo
@param oSubModel, objetct, submodelo de dados
@return variant, nil
/*/
Static Function loadLine(cModel, oSubModel, oModel)
local nLine as numeric
local nLength as numeric

   do Case
      case cModel == "EKQDETAIL"

         nLength := oSubModel:length(.T.)
         for nLine:= 1 to nLength
            oSubModel:goLine(nLine)
            EKQLoad(oSubModel)
         next

      case cModel == "EIJMASTER"

         EIJLoad(oSubModel)

      case "EKWGRID" $ cModel

         LP500LDEKW(oModel, oSubModel, cModel)

   endCase

Return

/*/{Protheus.doc} lp500LPCO
Recuperar os formulários LPCO's para as NCMs dos itens do processo
@type function
@version  
@author wilsimar
@since 9/8/2025
@param cEvent, character, define se a ação será para gerar o array com as informações dos formulários ou se será para recuperar a listagem gerada
@return variant, retorna os formulários LPCO's para as NCMs dos itens do processo
/*/
function lp500LPCO(cEvent)
local aLPCOs as array

   do Case

      case cEvent == "SET"
         ManLstFrm(,'__aLstFrmNcm',"SET",'')

      case cEvent == "GET"
         aLPCOs:= ManLstFrm(,'__aLstFrmNcm',"GET",'')

   endCase
   
return aClone(aLPCOs)

/*/{Protheus.doc} setInfSWV
   Realiza a carga das informações do modelo da SWV

   @type  Static Function
   @author user
   @since 29/09/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function setInfSWV(oModel)
   local oModelSW9  := oModel:GetModel("SW9DETAIL")
   local oModelSWV  := oModel:GetModel("SWVDETAIL")
   local nAtLnSW9   := oModelSW9:GetLine()
   local nAtLnSWV   := oModelSWV:GetLine()
   local nInv       := 0
   local nItemInv   := 0
   local cHashLinWV := ""
   local aSeqSWV    := {}
   local cSequencia := ""
   local nTamSeq    := AVSX3("WV_SEQUENC",3)
   local nPosSeq    := 0
   local cStatusSWV := ""
   local oUserParam := nil 
   local cIdWV      := ""

   __oLstQtdInf := tHashMap():New()

   cIdEWQ := getIDEWQ( SW6->W6_HAWB, @oUserParam )

   for nInv := 1 to oModelSW9:length()
      oModelSW9:GoLine(nInv)
      
      oModelSWV  := oModel:GetModel("SWVDETAIL")
      for nItemInv := 1 to oModelSWV:length()
         
         oModelSWV:GoLine(nItemInv)

         cHashLinWV := oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO")
         
         // Gerar a sequencia do item, devido a quebra de lote do processo DI que foi alterado para DUIMP
         // reaproveitamento os lotes informados no processo de DI
         if empty(oModelSWV:GetValue("WV_SEQUENC")) .and. !empty(oModelSWV:GetValue("WV_LOTE"))
            nPosSeq := aScan(aSeqSWV, {|x| x[1] == cHashLinWV})		
		      if nPosSeq == 0
               cSequencia := strZero(1, nTamSeq)
               aAdd( aSeqSWV, {cHashLinWV, cSequencia} )
            else
               cSequencia := SomaIt(aSeqSWV[nPosSeq][2])
               aSeqSWV[nPosSeq][2] := cSequencia
            endif
            oModelSWV:LoadValue("WV_SEQUENC", cSequencia)
         endif

         cHashLinWV += oModelSWV:GetValue("WV_SEQUENC")
         __oLstQtdInf:Set( cHashLinWV , oModelSWV:GetValue("WV_QTDE")  )

         cStatusSWV := EvalPdLPCO(oModel)
         oModelSWV:LoadValue("WV_LPCOPND", cStatusSWV)

         if empty(cIdWV) .or. val(cIdWV) < val(oModelSWV:GetValue("WV_ID"))
            cIdWV := oModelSWV:GetValue("WV_ID")
         endif

      next nItemInv
   next nInv

   // Atualiza a sequencia na EWQ
   if cIdEWQ == STRZERO(0, AVSX3("WV_ID",AV_TAMANHO)) .and. !empty(cIdWV) .and. val(cIdWV) > val(cIdEWQ) 
      LP500IDEWQ( SW6->W6_HAWB, cIdWV, oUserParam )
   endif

   oModelSW9:GoLine(nAtLnSW9)
   oModelSWV:GoLine(nAtLnSWV)

return nil

/*/{Protheus.doc} getOption 
   Retorna a opção definida para acessar a rotina do itens da duimp

   @type  Static Function
   @author user
   @since 03/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getOption(lHelp, lVldView, cMsgHelp, cMsgSoluc)
   local nOpc       := MODEL_OPERATION_UPDATE
   local lAltera    := .F.

   default lHelp      := .T.
   default lVldView   := .T.
   default cMsgHelp   := ""
   default cMsgSoluc  := ""

   if !FwIsInCallStack("DI154NFE")
      lAltera := LP500VlPrc(lHelp, lVldView, .F., @cMsgHelp, @cMsgSoluc)
      nOpc := MODEL_OPERATION_VIEW
      if lAltera
         nOpc := MODEL_OPERATION_UPDATE
      endif
   endif

return nOpc

/*/{Protheus.doc} LP500VlPrc
   Valida se pode acessar o itens da duimp, caso já tenha sido gerado a nota fiscal para duimp manual ou tenha sido informado os dados da duimp integrada

   @type  Function
   @author user
   @since 15/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return lRet, logico, Verdadeiro se pode alterar, falso apenas visualização
   @example
   (examples)
   @see (links_or_references)
/*/
function LP500VlPrc(lHelp, lVldView, lVldID, cMsgHelp, cMsgSoluc)
   local lRet       := .T.

   default lHelp      := .T.
   default lVldView   := .T.
   default lVldID     := .F.
   default cMsgHelp   := ""
   default cMsgSoluc  := ""

   if SW6->W6_FORMREG == DUIMP_INTEGRADA
      if !empty(SW6->W6_DI_NUM ) .and. !empty(SW6->W6_VERSAO ) .and. !empty(SW6->W6_DTREG_D)
         lRet := .F.
         cMsgHelp := if( lVldView, STR0108, STR0198 ) // "A rotina será aberta em modo de visualização." ### "Não é possível atualizar os itens DUIMP."
         cMsgSoluc := STR0109 // "Caso seja necessário realizar alguma atualização nos Itens DUIMP, será necessário remover as informações dos campos do número da DUIMP, sua data de registro e sua versão."
         if lHelp
            EasyHelp(cMsgHelp, STR0003, cMsgSoluc)
         endif
      endif
   else
      SF1->(DBSETORDER(5)) // F1_FILIAL+F1_HAWB+F1_TIPO_NF+F1_DOC+F1_SERIE
      if (SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+'1')) .Or.;
                  SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+'3')) .Or.;
                  SF1->(dbSeek(xFilial("SF1")+SW6->W6_HAWB+'5')))
         lRet := .F.
         cMsgHelp := if( lVldView, STR0108, STR0198 ) // "A rotina será aberta em modo de visualização." ### "Não é possível atualizar os itens DUIMP."
         cMsgSoluc := STR0199 //  "Já foi gerado a nota fiscal para o processo. Caso seja necessário realizar alguma atualização nos itens da duimp, será necessário estornar a nota gerada."
         if lHelp
            EasyHelp(cMsgHelp, STR0003, cMsgSoluc)
         endif
      endif
   endif

   if lRet .and. lVldID
      lRet := VldWVID(lHelp, @cMsgHelp, @cMsgSoluc)
   endif

return lRet

/*/{Protheus.doc} VldWVID
   Realiza a validação do vampo WV_ID

   @type  Static Function
   @author user
   @since 17/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function VldWVID(lHelp, cMsgHelp, cMsgSoluc)
   local lRet       := .T.
   local aAreaSWV := {}

   default lHelp      := .T.
   default cMsgHelp   := ""
   default cMsgSoluc  := ""

   aAreaSWV := SWV->(getArea())

   SWV->(dbSetOrder(5)) //WV_FILIAL+WV_HAWB+WV_ID 
   if !SWV->(DbSeek(xFilial("SWV") + SW6->W6_HAWB)) .or. empty(SWV->WV_ID)
      lRet := .F.
      cMsgHelp := STR0200 // "Processo não possui itens da duimp gerado."
      cMsgSoluc := STR0201 // "Será necessário realizar a gravação do desembaraço para prosseguir."
      if lHelp
         EasyHelp(cMsgHelp, STR0003, cMsgSoluc)
      endif
   endif

   restArea( aAreaSWV )

return lRet

/*/{Protheus.doc} setAtriOpc
   (long_description)
   @type  Static Function
   @author user
   @since 07/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
function setAtriOpc(oEKWRegTri, cTributo, cHawb, cIdWV, cNCM, cFundLegal)
   local cTriUpper := ""

   if !empty(cFundLegal) 
      cTriUpper := upper(Alltrim(cTributo))
      if EKU->(dbSeek(xFilial("EKU") + cFundLegal)) .and. ;
         EKV->(dbSeek(xFilial("EKV") + cNCM + cFundLegal + getTribCode(cTriUpper) + getPaisOri()))
         oEKWRegTri['listaOpcional'][cTributo]["EKW_FILIAL"] := xFilial("EKW")
         oEKWRegTri['listaOpcional'][cTributo]["EKW_HAWB"  ] := cHawb
         oEKWRegTri['listaOpcional'][cTributo]["EKW_IDWV"  ] := cIdWV
         oEKWRegTri['listaOpcional'][cTributo]["EKW_NCM"   ] := cNCM
         oEKWRegTri['listaOpcional'][cTributo]["EKW_FDTLGL"] := EKU->EKU_FDTLGL
         oEKWRegTri['listaOpcional'][cTributo]["EKW_FDTDES"] := LP500GetInfo("EKU", 1, xFilial("EKU") + EKU->EKU_FDTLGL, "EKU_FDTDES")
         oEKWRegTri['listaOpcional'][cTributo]["EKW_TRIBUT"] := getTribCode(cTriUpper)
         oEKWRegTri['listaOpcional'][cTributo]["EKW_REGIME"] := EKU->EKU_REGIME
         oEKWRegTri['listaOpcional'][cTributo]["EKW_REGDES"] := IIF(!Empty(EKU->EKU_REGIME),LP500GetInfo("SJP", 1, xFilial("SJP") + EKU->EKU_REGIME, "JP_DESC"), "")
         oEKWRegTri['listaOpcional'][cTributo]["EKW_TIPO"  ] := EKV->EKV_TIPO
         oEKWRegTri['listaOpcional'][cTributo]["EKW_ATRIBU"] := EKV->EKV_ATRIBU
         oEKWRegTri['listaOpcional'][cTributo]["RECNOEKV"  ] := EKV->(Recno())
      endif
   endif

return nil

/*/{Protheus.doc} ExecDelEKW
   Realiza a exclusão ou a restauração das linhas do modelo EKW

   @type  Static Function
   @author user
   @since 07/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function ExecDelEKW(oModel, cAction)

   If AvFlags("FUNDAMENTO_LEGAL_ITEM") .and. (cAction == "DELETE" .Or. cAction == "UNDELETE")
      DelGridEKW(oModel, cAction, "EKWGRID_II") //Imposto de Importação
      DelGridEKW(oModel, cAction, "EKWGRID_IPI") //Imposto sobre Produtos Industrializados
      DelGridEKW(oModel, cAction, "EKWGRID_PIS") //Programa de Integração Social
      DelGridEKW(oModel, cAction, "EKWGRID_COFINS") //Contribuição para o Financiamento da Seguridade Social
      DelGridEKW(oModel, cAction, "EKWGRID_ANTIDUMPING") //Medidas Antidumping
   endIf

Return

/*/{Protheus.doc} DelGridEKW
   Realiza a exclusão ou a restauração das linhas do modelo EKW

   @type  Static Function
   @author user
   @since 07/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
Static Function DelGridEKW(oModel, cAction, cModelGrid)
   local oModelEKW  := oModel:GetModel(cModelGrid)
   local nLine      := 0

   if ValType(oModelEKW) == "O"
      if cAction == "DELETE"
         oModelEKW:DelAllline()
      elseif cAction == "UNDELETE"
         for nLine := 1 to oModelEKW:Length()
            oModelEKW:GoLIne(nLine)
            if oModelEKW:IsDeleted()
               oModelEKW:UnDeleteLine()
            endif
         next nLine
      endif
   endif
return

/*/{Protheus.doc} getNCM
   Retornar a NCM caso ainda o campo WV_NCM não esteja salvo 

   @type  Static Function
   @author user
   @since 07/10/2025
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
/*/
static function getNCM(oModelSWV)
   local cRet := oModelSWV:GetValue("WV_NCM")
   local aRet := {}

   if empty(cRet) .and. len(aRet := GetInfW7W8(oModelSWV, {"W8_TEC"}) ) > 0 
      cRet := aRet[1]
   endif

return cRet

/*/{Protheus.doc} LP500OpEst
	Retorna a informação do operador estrangeiro

	@type  Static Function
	@author user
	@since 10/11/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
function LP500OpEst(cCampo, cCnpjRaiz, cCodFabFor, cLojFabFor, lStatusInt)
	local cRet := ""

   default cCnpjRaiz  := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ), 8)
	default lStatusInt := .T.
	
	EKJ->(DbSetOrder(1))
	if !empty(cCodFabFor) .and. !empty(cLojFabFor) .and. EKJ->(DbSeek( xFilial("EKJ") + cCnpjRaiz + cCodFabFor + cLojFabFor )) .and. (!lStatusInt .or. EKJ->EKJ_STATUS == '1') // 1=Registrado;2=Pendente Registro;3=Pendente Retificação;4=Falha de integração;5=Desativado
		if cCampo == "EKJ_TIN"
         cRet := EKJ->EKJ_TIN
      elseif cCampo == "EKJ_VERSAO"
         cRet := EKJ->EKJ_VERSAO
      endif
	endif

return cRet

/*/{Protheus.doc} PosCatOper
	Posiciona na tabela EKF

	@type  Static Function
	@author user
	@since 10/11/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function PosCatOper(cIdCat, cSeqCat, cCodFabFor, cLojFabFor)
   local lRet       := .F.
   local lMultiFil  := CP400MultF()

   default cIdCat     := EKD->EKD_COD_I
   default cSeqCat    := EKD->EKD_VERSAO
   default cCodFabFor := ""
   default cLojFabFor := ""

   if !empty(cIdCat) .and. !empty(cSeqCat) .and. !empty(cCodFabFor) .and. !empty(cLojFabFor)

      if lMultiFil .and. FWSIXUtil():ExistIndex("EKF","3")
         EKF->(dbSetOrder(3)) // EKF_FILIAL+EKF_FILORI+EKF_COD_I+EKF_VERSAO+EKF_CODFAB+EKF_LOJA
         lRet := EKF->(dbSeek(xFilial("EKF") + xFilial("SA2") + cIdCat + cSeqCat + cCodFabFor + cLojFabFor ))
      else
         EKF->(dbSetOrder(1)) // EKF_FILIAL+EKF_COD_I+EKF_VERSAO+EKF_CODFAB+EKF_LOJA+EKF_PAIS+EKF_FILORI
         lRet := EKF->(dbSeek(xFilial("EKF") + cIdCat + cSeqCat + cCodFabFor + cLojFabFor))
      endif

   endif

return lRet

/*/{Protheus.doc} PosCatProd
	Posiciona na tabela EKE

	@type  Static Function
	@author user
	@since 10/11/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
static function PosCatProd(cIdCat, cSeqCat, cProduto)
   local lRet       := .F.
   local lMultiFil  := CP400MultF()

   default cIdCat     := EKD->EKD_COD_I
   default cSeqCat    := EKD->EKD_VERSAO
   default cProduto   := ""

   if !empty(cIdCat) .and. !empty(cSeqCat) .and. !empty(cProduto) 
      EKE->(dbSetOrder(2)) // EKE_FILIAL+EKE_COD_I+EKE_VERSAO+EKE_PRDREF+EKE_FILORI
      lRet := EKE->(dbSeek(xFilial("EKE") + cIdCat + cSeqCat + cProduto))
      if lRet .and. lMultiFil
         lRet := EKE->(dbSeek(xFilial("EKE") + cIdCat + cSeqCat + cProduto + xFilial("SB1")))
      endif
   endif

return lRet

Function LP500Aplic(cCodReg, lClassTrib, lRegTrib, oModelSWV, lAplicaII, lAplicaIPI, lAplicaPIS, lAplicaCOF, lAplicaADU, lAplicaICM, lAplicaCBS, lAplicaIBS)
Default cCodReg := oModelSWV:getValue("WV_CODREG")
If lClassTrib .And. !Empty(cCodReg)
	//Quando os campos de Aplica for igual a 2, não deve aplicar as aliquotas do Regime e sim da NCM
	lAplicaII  := LP500retCp(cCodReg ,"EKR_APLII" , oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaIPI := LP500retCp(cCodReg ,"EKR_APLIPI", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaPIS := LP500retCp(cCodReg ,"EKR_APLPIS", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaCOF := LP500retCp(cCodReg ,"EKR_APLCOF", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaADU := LP500retCp(cCodReg ,"EKR_APLADU", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaICM := LP500retCp(cCodReg ,"EKR_APLICM", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaCBS := LP500retCp(cCodReg ,"EKR_APLCBS", oModelSWV, "1", "", lRegTrib ) <> "2"
	lAplicaIBS := LP500retCp(cCodReg ,"EKR_APLIBS", oModelSWV, "1", "", lRegTrib ) <> "2"
EndIf
Return

Static Function ClsTrbPOUI(cCodRegime, lClassTrib, lRegTrib, oModelSWV)
Local cAtributo := IIF(EasyGParam("MV_EIC0074",.F.,"1") == "1", ATT_CLASSTRIB, ATT_CLASSTRIB_VAL)
Local cClassTrib := ""
Local oJson

If lClassTrib .And. lRegTrib .And. !Empty(cCodRegime)
   cClassTrib := LP500retCp(cCodRegime ,"EKR_CSTCCT", , "", "", lRegTrib )
   If !Empty(cClassTrib)

      oJson := jsonObject():New()
      oJson['id']     := oModelSWV:getValue("WV_ID")
      oJson['codigo'] := cAtributo
      oJson['valor']  := cClassTrib

      oChannel:AdvPLToJS("setClassificacaoFiscal", oJson:toJson())
      FreeObj(oJson)
   EndIf
EndIf
Return
