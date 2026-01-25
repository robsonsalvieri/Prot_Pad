#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICDU100.CH"
#INCLUDE "AVERAGE.CH"

#define MYCSS "QTableView { selection-background-color: #1C9DBD; }"
#define DUIMP "2"
#define DUIMP_INTEGRADA "1"

// define EV1_STATUS
#define PENDENTE_INTEGRACAO        "1"
#define PROCESSO_PENDENTE_REVISAO  "2"
#define PENDENTE_REGISTRO          "3"
#define DUIMP_REGISTRADA           "4"
#define OBSOLETO                   "5"
#define EM_PROCESSAMENTO           "6"

static _nRecEV1   := 0
static _DIC_22_4  := nil
static _cNumLote  := ""
static lAppDU100

#define OBJETIVO_DUIMP              "5"
#define OBJETIVO_FUNDAMENTO_LEGAL   "9"//ALTERAR PARA O OBJETIVO CORRETO
#define OBJETIVO_CATALOGO           "7"
#define OBJETIVO_LPCO               "6"

#Define ATT_COMPOSTO       "COMPOSTO"
#Define ATT_LISTA_ESTATICA "LISTA_ESTATICA"
#Define ATT_TEXTO          "TEXTO"
#Define ATT_BOOLEANO       "BOOLEANO"

/*
Programa        : EICDU100.PRW
Objetivo        : Manutenção do cadastro de Integração DUIMP
Autor           : Maurício Frison
Data/Hora       : 26/01/2022
Obs. 
*/
Function EICDU100()
Local aArea         := GetArea()
local lLibAccess  := .F.
local lExecFunc   := .F. // existFunc("FwBlkUserFunction")

Private lInclui :=.F.
Private oBufSeqEV1 := tHashMap():New()
private oChannel
private oJsonPOUI
private oJsonAtt
private oInfoAtt
private oValorAtt
private oVlCodObj
private oFundLegal
private cActiveID
private cTmpAtrib     := GetNextAlias()
private cFileAtrib
private cIndCatPrd

if lExecFunc
   FwBlkUserFunction(.T.)
endif

lLibAccess := AmIin(17)

if lExecFunc
   FwBlkUserFunction(.F.)
endif

if lLibAccess
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
   cActiveID := ""
   
   TabItemNCM(cTmpAtrib)
	
   oBrowse := FWMBrowse():New() //Instanciando a Classe
	oBrowse:SetAlias("EV1") //Informando o Alias
	oBrowse:SetMenuDef("EICDU100") //Nome do fonte do MenuDef
	oBrowse:SetDescription(STR0001) //"Integração DUIMP"
	
	oBrowse:SetUseFilter()
	oBrowse:DisableDetails( )
	oBrowse:AddFilter("Filtrar" , "EV1->EV1_TIPREG == '2'", .T., .T.)
	
	oBrowse:AddLegend( "EV1_STATUS == '" + PENDENTE_INTEGRACAO + "' .or. empty(EV1_STATUS)", "BR_AZUL"      , STR0055) // "Pendente de Integração"
	oBrowse:AddLegend( "EV1_STATUS == '" + PROCESSO_PENDENTE_REVISAO + "'"                 , "BR_AMARELO"   , STR0056) // "Processo Pendente de Revisão"
	oBrowse:AddLegend( "EV1_STATUS == '" + PENDENTE_REGISTRO + "'"                         , "BR_VERMELHO"  , STR0057) // "Pendente de Registro"
	oBrowse:AddLegend( "EV1_STATUS == '" + EM_PROCESSAMENTO + "'"                          , "BR_LARANJA"   , STR0105) // "Registro em Processamento"
	oBrowse:AddLegend( "EV1_STATUS == '" + DUIMP_REGISTRADA + "'"                          , "BR_VERDE"     , STR0058) // "Duimp Registrada"
	oBrowse:AddLegend( "EV1_STATUS == '" + OBSOLETO + "'"                                  , "BR_CINZA"     , STR0059) // "Obsoleto"

   //Habilita a exibição de visões e gráficos
   oBrowse:SetAttach( .T. )
   //Configura as visões padrão
   oBrowse:SetViewsDefault(GetVisions())
   oBrowse:SetIDViewDefault('1') //Define a visão padrão
   
	oBrowse:SetOnlyFields( { 'EV1_STATUS', 'EV1_LOTE', 'EV1_SEQUEN', 'EV1_HAWB', 'EV1_USRGER','EV1_DATGER', 'EV1_HORGER' } ) 
	
	oBrowse:Activate()
endif

RestArea(aArea)
cActiveID := ""
freeObj(oChannel)
freeObj(oJsonPOUI)
freeObj(oFundLegal)
FreeObj(oJsonAtt)
FreeObj(oInfoAtt)
FreeObj(oValorAtt)
freeObj(oVlCodObj)
(cTmpAtrib)->(E_EraseArq(cFileAtrib, cIndCatPrd))
Return

/*
Funcao      : MenuDef
Parametros  : Nenhum
Retorno     : 
Objetivos   : Efetuar manutenção no cadastro 
Autor       : Maurício Frison
Data/Hora   : 26/01/2022
Revisão     : 
Obs         : 
*/
Static Function MenuDef()
Local aRotina := {}
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICDU100" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICDU100" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0062 ACTION "DU101PrcInt"      OPERATION 4 ACCESS 0 // "Integrar"
ADD OPTION aRotina TITLE STR0005 ACTION "DU100Manut"       OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0090 ACTION "DU101PrcInt"      OPERATION 6 ACCESS 0 // "Solicitar Registro"
ADD OPTION aRotina TITLE STR0106 ACTION "DU101PrcInt"      OPERATION 7 ACCESS 0 // "Consultar Status"
ADD OPTION aRotina TITLE STR0061 ACTION "EICDULegen"       OPERATION 8 ACCESS 0 // "Legenda"
ADD OPTION aRotina TITLE STR0101 ACTION "DU100Log"         OPERATION 2 ACCESS 0 // "Log de Integração"

Return aRotina  

/*
Função     : DU100Manut
Objetivo   : Função para manutenção do modelo EICDU100
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
function DU100Manut(cAlias, nRecno, nOpc)
   local cTitulo := ""

   default cAlias     := "EV1"
   default nRecno     := 0
   default nOpc       := 0

   if nOpc == MODEL_OPERATION_DELETE .and. EV1->(!eof()) .and. EV1->(!bof())
      cTitulo := STR0001 + " - " + STR0005 // "Integração DUIMP" ### "Excluir"
      if EV1->EV1_STATUS == DUIMP_REGISTRADA .or. EV1->EV1_STATUS == OBSOLETO .or. EV1->EV1_STATUS == EM_PROCESSAMENTO 
         EasyHelp(  StrTran( STR0088, "####", if( EV1->EV1_STATUS == DUIMP_REGISTRADA, STR0058 , if(EV1->EV1_STATUS == OBSOLETO, STR0059, STR0105 ) ) )  , STR0014 , "") // "O status deste processo é de '####'. Não é possível prosseguir com a ação de exclusão do registro." ### "Atenção" ### "Duimp Registrada" #### "Obsoleto" ### "Registro em Processamento"
      elseif !FwIsInCallStack("DU100ExAuto")
         if MsgYesNo(STR0089 , STR0014 ) // "Caso o registro tenha histórico de integração com o Portal Único, esta operação o tornará Obsoleto. Deseja prosseguir com esta operação?" ### "Atenção"
            FWExecView(cTitulo,'EICDU100', MODEL_OPERATION_DELETE,, { || .T. }  )
         endif
      endif

   endif

return .T.

Static Function TabItemNCM(cTmpAtrib)
cFileAtrib := E_CriaTrab(,{{"WV_ID","C",AVSX3("WV_ID",AV_TAMANHO),0}, {"YD_TEC","C",AVSX3("YD_TEC",AV_TAMANHO),0}, {"EV2_LOTE","C",AVSX3("EV2_LOTE",AV_TAMANHO),0}, {"EV2_HAWB","C",AVSX3("EV2_HAWB",AV_TAMANHO),0}, {"EV2_SEQDUI","C",AVSX3("EV2_SEQDUI",AV_TAMANHO),0}}, cTmpAtrib)
IndRegua(cTmpAtrib, cFileAtrib + TEOrdBagExt(),"WV_ID+YD_TEC")
cIndCatPrd := e_create()
IndRegua(cTmpAtrib, cIndCatPrd + TEOrdBagExt(),"EV2_LOTE+EV2_SEQDUI")
SET INDEX TO (cFileAtrib + TEOrdBagExt()),(cIndCatPrd + TEOrdBagExt())
Return

/*
Função     : EICDULegen
Objetivo   : Opção de Legenda
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function EICDULegen()
   local aCores := {}
 
   aCores := { { "BR_AZUL"      , STR0055},; // "Pendente de Integração"
               { "BR_AMARELO"   , STR0056},; // "Processo Pendente de Revisão"
               { "BR_VERMELHO"  , STR0057},; // "Pendente de Registro"
               { "BR_LARANJA"   , STR0105},; // "Registro em Processamento"
               { "BR_VERDE"     , STR0058},; // "Duimp Registrada"
               { "BR_CINZA"     , STR0059}}  // "Obsoleto"

   BrwLegenda(STR0001,STR0061,aCores)

return .T.

Static Function ModelDef()
   local oModel     := nil
   local bCancel    := { |oModel| DU100VdCan(oModel)}
   local bPostVld   := { |oModel| DU100PVldModel(oModel) }
   local bCommit    := { |oModel| DU100Commit(oModel) }
   local bActivate  := { |oModel| DU100Active(oModel)}

   // Define o modelo principal da rotina
   oModel := MPFormModel():New( 'EICDU100', /*bPreValidacao*/, bPostVld, bCommit, bCancel )
   oModel:SetDescription(STR0001)//"Integração DUIMP"

   // Capa da rotina
   setMdlEV1(oModel)
   setMdlEV9(oModel)
   setMdlEVB(oModel)

   // Itens da rotina
   setMdlSWV(oModel)
   setMdlEV2MC(oModel)
   setMdlEV2FF(oModel)
   setMdlEV2CV(oModel)
   if DUIMP2310()
      setMdlEV2TR(oModel)
   endif
   setMdlEV3(oModel)
   setMdlEV4(oModel)
   setMdlEVE(oModel)
   setMdlEVI(oModel)
   setMdlEV6(oModel)
   
   oModel:SetActivate(bActivate)
Return oModel

/*
   Executado apos ativar o modelo
*/
Static Function DU100Active(oModel)
Local oModelSWV   := oModel:GetModel("SWVDETAIL")
Local cTela
If oModel:getOperation() == MODEL_OPERATION_DELETE
   cTela := STR0005 // "Excluir"
Else
   cTela := STR0003 // "Visualizar"
EndIf
FWMsgRun(, {|oSay| DU100LdAtt(oModel, oModelSWV) }, cTela, STR0133) //"Visualizar/Excluir"###"Carregando atributos..."
cActiveID := oModelSWV:getValue("WV_ID")
Return

Static Function DU100LdAtt(oModel, oModelSWV)
Local oCamposPoui := jsonObject():New()
Local aDadosPoui := {}
Local aDadosLPCO := {}
Local aDadosCP   := {}
Local oModelLPCO
Local oObjetivo
Local oModelEVG
Local jsonCP
Local jsonLPCO
Local lTemLpco
Local cIdentInfo
Local cIdent
Local cDivider
Local nI
Local nY

If canUseApp() .And. oModel:getOperation() <> MODEL_OPERATION_INSERT
   clearField()
   //Trata itens a serem apresentados no APP
   cActiveID := oModelSWV:getValue("WV_ID")
   SW6->(dbSeek(xFilial("SW6") + oModelSWV:GetValue("WV_HAWB")))
   For nI := 1 To oModelSWV:getQtdLine()
      oModelSWV:goLine(nI)
      oObjetivo := jSonObject():New()  
      oObjetivo['ncm']  := oModelSWV:GetValue("WV_NCM") 
      oObjetivo['idwv'] := oModelSWV:GetValue("WV_ID") 
      oVlCodObj[oObjetivo['idwv']] := oObjetivo
      oVlCodObj[oObjetivo['idwv']]['lpco']      := {}
      oVlCodObj[oObjetivo['idwv']]['catalogo']  := jsonObject():New()
      setNcmAtri(cTmpAtrib, "NCM", oModelSWV:GetValue("WV_ID"), oModelSWV:GetValue("WV_NCM"), oModel:GetModel("EV2MSTR_MC"):getValue("EV2_LOTE"), oModelSWV:GetValue("WV_HAWB"), oModel:GetModel("EV2MSTR_MC"):getValue("EV2_SEQDUI"))
      oCamposPoui := jsonObject():New()
      oCamposPoui['WV_SEQUENC']  := oModelSWV:GetValue("WV_SEQUENC")
      oCamposPoui['WV_NCM']      := oModelSWV:GetValue("WV_NCM")
      oCamposPoui['WV_QTDE']     := oModelSWV:GetValue("WV_QTDE")
      oCamposPoui['WV_DESC_DI']  := oModelSWV:GetValue("WV_DESC_DI")
      oCamposPoui['WV_ID']       := oModelSWV:GetValue("WV_ID")
      oCamposPoui['WV_INVOICE']  := oModelSWV:GetValue("WV_INVOICE")
      oCamposPoui['WV_PO_NUM']   := oModelSWV:GetValue("WV_PO_NUM")
      oCamposPoui['WV_POSICAO']  := oModelSWV:GetValue("WV_POSICAO")
      oCamposPoui['WV_COD_I']    := oModelSWV:GetValue("WV_COD_I")

      oFundLegal[oModelSWV:GetValue("WV_ID")] := JsonObject():new()

      //CATALOGO
      oVlCodObj[oModelSWV:GetValue("WV_ID")]['catalogo']['catalogo'] := oModel:GetModel("EV2MSTR_MC"):getValue("EV2_IDPTCP")
      oVlCodObj[oModelSWV:GetValue("WV_ID")]['catalogo']['versao']   := oModel:GetModel("EV2MSTR_MC"):getValue("EV2_VRSACP")
      jsonCP := jsonObject():New()
      jsonCP['id']      := oModelSWV:GetValue("WV_ID")
      jsonCP['catalogo']:= !Empty(oModel:GetModel("EV2MSTR_MC"):getValue("EV2_IDPTCP"))
      aAdd(aDadosCP, jsonCP)
      freeObj(jsonCP)

      //LPCO
      oModelLPCO  := oModel:GetModel("EVEDETAIL")
      lTemLpco    := .F.
      For nY := 1 To oModelLPCO:getQtdLine()
         oModelLPCO:goLine(nY)
         oObjLPCO := jsonObject():New()
         oObjLPCO['orgao']    := ''//EKQ->EKQ_ORGANU
         oObjLPCO['formLpco'] := ''//EKQ->EKQ_FRMLPC
         oObjLPCO['lpco']     := oModelLPCO:getValue("EVE_LPCO")
         oObjLPCO['versao']   := ''//EKQ->EKQ_VERSAO
         aAdd(oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'], jSonObject():New())
         oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'][Len(oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'])] := oObjLPCO
         If !Empty(oModelLPCO:getValue("EVE_LPCO"))
            lTemLpco := .T.
         EndIf
         freeObj(oObjLPCO)
      Next
      jsonLPCO := jsonObject():New()
      jsonLPCO['id']   := oModelSWV:GetValue("WV_ID")
      jsonLPCO['lpco'] := lTemLpco
      aAdd(aDadosLPCO, jsonLPCO)
      aAdd(aDadosPoui, oCamposPoui)
      freeObj(oCamposPoui)
      freeObj(oObjetivo)
      freeObj(jsonLPCO)

      //II
      oModelEVG := oModel:GetModel("EVGGRID_II")
      For nY := 1 To oModelEVG:getQtdLine()
         oModelEVG:goLine(nY)
         //Atributos Informativos
         If !Empty(oModelEVG:getValue("EVG_FUNDLE")) .And. !oFundLegal[oModelSWV:GetValue("WV_ID")]:hasProperty(oModelEVG:getValue("EVG_FUNDLE"))
            cIdentInfo := oModelSWV:GetValue("WV_ID") + "-" + oModelEVG:getValue("EVG_FUNDLE") + "_"
            nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
            cActiveID := oModelSWV:GetValue("WV_ID")
            LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"), "EKU_ATT_FL"), cIdentInfo, oModelSWV:GetValue("WV_ATT_FL"), oModelSWV:GetValue("WV_AC"), oModelSWV:GetValue("WV_SEQSIS"), nOrder)
            oFundLegal[oModelSWV:GetValue("WV_ID")][oModelEVG:getValue("EVG_FUNDLE")] := 1
         EndIf

         //Atributos Adicionais
         xRetEKV := LP500GetInfo("EKV", 1, xFilial("EKV") + oModelSWV:GetValue("WV_NCM") + oModelEVG:getValue("EVG_FUNDLE") + oModelEVG:getValue("EVG_IDIMP") + getPaisOri(oModelSWV:GetValue("WV_HAWB")), "EKV_ATRIBU")
         If !Empty(xRetEKV)
            cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(oModelSWV:GetValue("WV_NCM")) + "-" + oModelEVG:getValue("EVG_FUNDLE") + "-" + oModelEVG:getValue("EVG_IDIMP") + "-" + oModelEVG:getValue("EVG_TIPOFL") + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
            cDivider := getTribName(oModelEVG:getValue("EVG_IDIMP")) + " | " +  oModelEVG:getValue("EVG_REGIME") + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + oModelEVG:getValue("EVG_REGIME"),"JP_DESC")) + " | " +  oModelEVG:getValue("EVG_FUNDLE") + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"),"EKU_FDTDES")
            LP500ATMER(oJsonAtt, xRetEKV, cIdent, cDivider, oModelEVG:getValue("EVG_ATRIBU"))
            oJsonPOUI['listaAdicionais'] := oJsonAtt
         EndIf
      Next
      //freeObj(oModelEVG)
      
      //IPI
      oModelEVG := oModel:GetModel("EVGGRID_IPI")
      For nY := 1 To oModelEVG:getQtdLine()
         oModelEVG:goLine(nY)
         //Atributos Informativos
         If !Empty(oModelEVG:getValue("EVG_FUNDLE")) .And. !oFundLegal[oModelSWV:GetValue("WV_ID")]:hasProperty(oModelEVG:getValue("EVG_FUNDLE"))
            cIdentInfo := oModelSWV:GetValue("WV_ID") + "-" + oModelEVG:getValue("EVG_FUNDLE") + "_"
            nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
            cActiveID := oModelSWV:GetValue("WV_ID")
            LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"), "EKU_ATT_FL"), cIdentInfo, oModelSWV:GetValue("WV_ATT_FL"), oModelSWV:GetValue("WV_AC"), oModelSWV:GetValue("WV_SEQSIS"), nOrder)
            oFundLegal[oModelSWV:GetValue("WV_ID")][oModelEVG:getValue("EVG_FUNDLE")] := 1
         EndIf

         //Atributos Adicionais
         xRetEKV := LP500GetInfo("EKV", 1, xFilial("EKV") + oModelSWV:GetValue("WV_NCM") + oModelEVG:getValue("EVG_FUNDLE") + oModelEVG:getValue("EVG_IDIMP") + getPaisOri(oModelSWV:GetValue("WV_HAWB")), "EKV_ATRIBU")
         If !Empty(xRetEKV)
            cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(oModelSWV:GetValue("WV_NCM")) + "-" + oModelEVG:getValue("EVG_FUNDLE") + "-" + oModelEVG:getValue("EVG_IDIMP") + "-" + oModelEVG:getValue("EVG_TIPOFL") + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
            cDivider := getTribName(oModelEVG:getValue("EVG_IDIMP")) + " | " +  oModelEVG:getValue("EVG_REGIME") + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + oModelEVG:getValue("EVG_REGIME"),"JP_DESC")) + " | " +  oModelEVG:getValue("EVG_FUNDLE") + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"),"EKU_FDTDES")
            LP500ATMER(oJsonAtt, xRetEKV, cIdent, cDivider, oModelEVG:getValue("EVG_ATRIBU"))
            oJsonPOUI['listaAdicionais'] := oJsonAtt
         EndIf
      Next
      //freeObj(oModelEVG)

      //PIS
      oModelEVG := oModel:GetModel("EVGGRID_PIS")
      For nY := 1 To oModelEVG:getQtdLine()
         oModelEVG:goLine(nY)
         //Atributos Informativos
         If !Empty(oModelEVG:getValue("EVG_FUNDLE")) .And. !oFundLegal[oModelSWV:GetValue("WV_ID")]:hasProperty(oModelEVG:getValue("EVG_FUNDLE"))
            cIdentInfo := oModelSWV:GetValue("WV_ID") + "-" + oModelEVG:getValue("EVG_FUNDLE") + "_"
            nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
            cActiveID := oModelSWV:GetValue("WV_ID")
            LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"), "EKU_ATT_FL"), cIdentInfo, oModelSWV:GetValue("WV_ATT_FL"), oModelSWV:GetValue("WV_AC"), oModelSWV:GetValue("WV_SEQSIS"), nOrder)
            oFundLegal[oModelSWV:GetValue("WV_ID")][oModelEVG:getValue("EVG_FUNDLE")] := 1
         EndIf

         //Atributos Adicionais
         xRetEKV := LP500GetInfo("EKV", 1, xFilial("EKV") + oModelSWV:GetValue("WV_NCM") + oModelEVG:getValue("EVG_FUNDLE") + oModelEVG:getValue("EVG_IDIMP") + getPaisOri(oModelSWV:GetValue("WV_HAWB")), "EKV_ATRIBU")
         If !Empty(xRetEKV)
            cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(oModelSWV:GetValue("WV_NCM")) + "-" + oModelEVG:getValue("EVG_FUNDLE") + "-" + oModelEVG:getValue("EVG_IDIMP") + "-" + oModelEVG:getValue("EVG_TIPOFL") + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
            cDivider := getTribName(oModelEVG:getValue("EVG_IDIMP")) + " | " +  oModelEVG:getValue("EVG_REGIME") + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + oModelEVG:getValue("EVG_REGIME"),"JP_DESC")) + " | " +  oModelEVG:getValue("EVG_FUNDLE") + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"),"EKU_FDTDES")
            LP500ATMER(oJsonAtt, xRetEKV, cIdent, cDivider, oModelEVG:getValue("EVG_ATRIBU"))
            oJsonPOUI['listaAdicionais'] := oJsonAtt
         EndIf
      Next
      //freeObj(oModelEVG)

      //COFINS
      oModelEVG := oModel:GetModel("EVGGRID_COFINS")
      For nY := 1 To oModelEVG:getQtdLine()
         oModelEVG:goLine(nY)
         //Atributos Informativos
         If !Empty(oModelEVG:getValue("EVG_FUNDLE")) .And. !oFundLegal[oModelSWV:GetValue("WV_ID")]:hasProperty(oModelEVG:getValue("EVG_FUNDLE"))
            cIdentInfo := oModelSWV:GetValue("WV_ID") + "-" + oModelEVG:getValue("EVG_FUNDLE") + "_"
            nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
            cActiveID := oModelSWV:GetValue("WV_ID")
            LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"), "EKU_ATT_FL"), cIdentInfo, oModelSWV:GetValue("WV_ATT_FL"), oModelSWV:GetValue("WV_AC"), oModelSWV:GetValue("WV_SEQSIS"), nOrder)
            oFundLegal[oModelSWV:GetValue("WV_ID")][oModelEVG:getValue("EVG_FUNDLE")] := 1
         EndIf

         //Atributos Adicionais
         xRetEKV := LP500GetInfo("EKV", 1, xFilial("EKV") + oModelSWV:GetValue("WV_NCM") + oModelEVG:getValue("EVG_FUNDLE") + oModelEVG:getValue("EVG_IDIMP") + getPaisOri(oModelSWV:GetValue("WV_HAWB")), "EKV_ATRIBU")
         If !Empty(xRetEKV)
            cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(oModelSWV:GetValue("WV_NCM")) + "-" + oModelEVG:getValue("EVG_FUNDLE") + "-" + oModelEVG:getValue("EVG_IDIMP") + "-" + oModelEVG:getValue("EVG_TIPOFL") + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
            cDivider := getTribName(oModelEVG:getValue("EVG_IDIMP")) + " | " +  oModelEVG:getValue("EVG_REGIME") + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + oModelEVG:getValue("EVG_REGIME"),"JP_DESC")) + " | " +  oModelEVG:getValue("EVG_FUNDLE") + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"),"EKU_FDTDES")
            LP500ATMER(oJsonAtt, xRetEKV, cIdent, cDivider, oModelEVG:getValue("EVG_ATRIBU"))
            oJsonPOUI['listaAdicionais'] := oJsonAtt
         EndIf
      Next
      //freeObj(oModelEVG)

      //ANTIDUMPING
      oModelEVG := oModel:GetModel("EVGGRID_ANTIDUMPING")
      For nY := 1 To oModelEVG:getQtdLine()
         oModelEVG:goLine(nY)
         //Atributos Informativos
         If !Empty(oModelEVG:getValue("EVG_FUNDLE")) .And. !oFundLegal[oModelSWV:GetValue("WV_ID")]:hasProperty(oModelEVG:getValue("EVG_FUNDLE"))
            cIdentInfo := oModelSWV:GetValue("WV_ID") + "-" + oModelEVG:getValue("EVG_FUNDLE") + "_"
            nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
            cActiveID := oModelSWV:GetValue("WV_ID")
            LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"), "EKU_ATT_FL"), cIdentInfo, oModelSWV:GetValue("WV_ATT_FL"), oModelSWV:GetValue("WV_AC"), oModelSWV:GetValue("WV_SEQSIS"), nOrder)
            oFundLegal[oModelSWV:GetValue("WV_ID")][oModelEVG:getValue("EVG_FUNDLE")] := 1
         EndIf

         //Atributos Adicionais
         xRetEKV := LP500GetInfo("EKV", 1, xFilial("EKV") + oModelSWV:GetValue("WV_NCM") + oModelEVG:getValue("EVG_FUNDLE") + oModelEVG:getValue("EVG_IDIMP") + getPaisOri(oModelSWV:GetValue("WV_HAWB")), "EKV_ATRIBU")
         If !Empty(xRetEKV)
            cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(oModelSWV:GetValue("WV_NCM")) + "-" + oModelEVG:getValue("EVG_FUNDLE") + "-" + oModelEVG:getValue("EVG_IDIMP") + "-" + oModelEVG:getValue("EVG_TIPOFL") + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
            cDivider := getTribName(oModelEVG:getValue("EVG_IDIMP")) + " | " +  oModelEVG:getValue("EVG_REGIME") + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + oModelEVG:getValue("EVG_REGIME"),"JP_DESC")) + " | " +  oModelEVG:getValue("EVG_FUNDLE") + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + oModelEVG:getValue("EVG_FUNDLE"),"EKU_FDTDES")
            LP500ATMER(oJsonAtt, xRetEKV, cIdent, cDivider, oModelEVG:getValue("EVG_ATRIBU"))
            oJsonPOUI['listaAdicionais'] := oJsonAtt
         EndIf
      Next
      //freeObj(oModelEVG)

   Next
   setItPOUI(aDadosPoui)
   setStPOUI(aDadosCP, aDadosLPCO)
   //Monta o objeto com os atributos da DUIMP - EKG tipo 3
   LP500ATCOM(cTmpAtrib, OBJETIVO_DUIMP, "INT_DUIMP_EV2")//Atributos complementares (atributos DUIMP)
   oModelSWV:goLine(1)
   oModelLPCO:goLine(1)
EndIf
Return Nil

/*
Função     : setMdlEV1
Objetivo   : Define o modelo para Cadastrais (EV1)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV1(oModel)
   local oStruEV1   := nil
   local aTrigger   := {}
   local nTrigger   := 0

   oStruEV1 := FWFormStruct( 1, "EV1", {|x| CheckField(x, strtokarr2(DU100Model("EV1"), "|")) })

   oStruEV1:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
   oStruEV1:SetProperty('EV1_LOTE',MODEL_FIELD_OBRIGAT, .T. )
   oStruEV1:SetProperty('EV1_HAWB',MODEL_FIELD_OBRIGAT, .T. )
   oStruEV1:SetProperty('EV1_SEQUEN',MODEL_FIELD_OBRIGAT, .T. )

   //STRUCT_FEATURE_WHEN
   oStruEV1:SetProperty('*'         , MODEL_FIELD_WHEN , {|| .F. }) //Monta When diferente do dicionário   
   oStruEV1:SetProperty('EV1_HAWB'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'DU100WHEN("EV1_HAWB")'    )) //Monta When diferente do dicionário
  
   //STRUCT_FEATURE_VALID
   oStruEV1:SetProperty('EV1_HAWB'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'DU100VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV1:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   //                    N A O    A L T E R A R    A    O R D E M   D O S    G A T I L H O S
   //
   //Alguns gatilhos utilizam o registro já posicionado no gatilho anterior
   //
   //TRIGGER
   aTrigger := loadTrigger()
   for nTrigger := 1 to Len(aTrigger)
      oStruEV1:AddTrigger(aTrigger[nTrigger][1], aTrigger[nTrigger][2], aTrigger[nTrigger][3], aTrigger[nTrigger][4])
   next

   //STRUCT_FEATURE_INIPAD 
   oStruEV1:SetProperty('EV1_LOTE'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'DU100EV1LO(b,a,c)'         ))  //Monta Inicializador Padrão diferente do dicionário   

   oModel:AddFields( 'EV1MASTER',/*nOwner*/, oStruEV1, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
   oModel:SetPrimaryKey({'EV1_FILIAL','EV1_HAWB','EV1_LOTE'})

return nil

/*
Função     : setMdlEV9
Objetivo   : Define o modelo para Documentos de Instrução (EV9)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV9(oModel)
   local oStruEV9   := nil

   oStruEV9 := FWFormStruct( 1, "EV9", {|x| CheckField(x, strtokarr2(DU100Model("EV9"), "|")) })

   oStruEV9:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EV9DETAIL', 'EV1MASTER', oStruEV9)

   oModel:GetModel("EV9DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetOptional( .T. )

   oModel:GetModel("EV9DETAIL"):SetUniqueLine({"EV9_FILIAL" ,"EV9_HAWB" ,"EV9_LOTE","EV9_CODIN", "EV9_SEQUEN"} )

   oModel:SetRelation('EV9DETAIL', {{ 'EV9_FILIAL', 'xFilial("EV9")'},;
      { 'EV9_HAWB'  , 'EV1_HAWB'       },;
      { 'EV9_LOTE'  , 'EV1_LOTE'       }},;
       EV9->(IndexKey(1)) )

return

/*
Função     : setMdlEVB
Objetivo   : Define o modelo para Processos Vinculados (EVB)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVB(oModel)
   local oStruEVB   := nil

   oStruEVB := FWFormStruct( 1, "EVB", {|x| CheckField(x, strtokarr2(DU100Model("EVB"), "|")) })

   oStruEVB:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EVBDETAIL', 'EV1MASTER', oStruEVB)
   oModel:GetModel("EVBDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetOptional( .T. )

   oModel:GetModel("EVBDETAIL"):SetUniqueLine({"EVB_FILIAL" ,"EVB_HAWB" ,"EVB_LOTE","EVB_CODPV"} )

   oModel:SetRelation('EVBDETAIL', {   { 'EVB_FILIAL'   ,'xFilial("EVB")'},;
      { 'EVB_HAWB'     ,'EV1_HAWB'       },;
      { 'EVB_LOTE'     ,'EV1_LOTE'         }},; 
      EVB->(IndexKey(1)) )

return nil

/*
Função     : setMdlSWV
Objetivo   : Define o modelo para Dados do item da duimp (SWV)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlSWV(oModel)
   local oStruSWV := FWFormStruct( 1, "SWV", {|x| CheckField(x, strtokarr2(DU100Model("SWV"), "|")) })

   oStruSWV:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
   oStruSWV:SetProperty("WV_NOMEFOR" , MODEL_FIELD_INIT, {|| DU100Relac("WV_NOMEFOR")})
   oStruSWV:SetProperty("WV_NCM"     , MODEL_FIELD_INIT, {|| DU100Relac("WV_NCM")})
   oStruSWV:SetProperty("WV_DESC_DI" , MODEL_FIELD_INIT, {|| DU100Relac("WV_DESC_DI")})

   oModel:AddGrid('SWVDETAIL', 'EV1MASTER', oStruSWV)
   oModel:GetModel("SWVDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetOnlyQuery(.T.) //Retira o modelo do commit
   //oModel:GetModel("EVBDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetOptional( .F. )

   oModel:SetRelation('SWVDETAIL', {   { 'WV_FILIAL'   ,'xFilial("SWV")'},;
                                       { 'WV_HAWB'     ,'EV1_HAWB'      }},;
   SWV->(IndexKey(5)) ) // WV_FILIAL+WV_HAWB+WV_ID

return nil

/*
Função     : setMdlEV2MC
Objetivo   : Define o modelo para Mercadorias (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2MC(oModel)
   local oStruEV2   := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_MERCADORIA"), "|")) })   
   local bLoadEV2MC := {|oModel| DU100EV2Load( oModel) }
   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)   
    
   oModel:AddFields( 'EV2MSTR_MC', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2MC)
   
   oModel:SetRelation('EV2MSTR_MC', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2FF
Objetivo   : Define o modelo para Fabricante / Fornecedor (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2FF(oModel)
   local oStruEV2   := nil
   local bLoadEV2FF := {|oModel| DU100EV2Load( oModel) }
   oStruEV2 := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_FABR_FORN"), "|")) })

   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_FF', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2FF)
   oModel:GetModel("EV2MSTR_FF"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_FF', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2CV
Objetivo   : Define o modelo para Condição de Venda / Cambiais (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2CV(oModel)
   local oStruEV2   := nil
   local bLoadEV2CV := {|oModel| DU100EV2Load( oModel) }
   oStruEV2 := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_COND_VENDA"), "|")) })

   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_CV', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_CV"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_CV', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2TR
Objetivo   : Define o modelo para Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2TR(oModel)
   local oStrII     := nil
   local oStrIPI    := nil
   local oStrPISCOF := nil
   local oStrPIS    := nil
   local oStrCOF    := nil
   local oStrANTDUM := nil
   local oStrInteg  := nil
   local oStrEVGII  := nil
   local oStrEVGIPI := nil
   local oStrEVGPIS := nil
   local oStrEVGCOF := nil
   local oStrEVGDUM := nil
   local aCamposEVG := EasyStrSplit(FwX2Unico("EVG"), "+")
   local bLoadEV2CV := {|oModel| DU100EV2Load( oModel ) }
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

   //====================II====================
   oStrII   := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_II"), "|")) })
   oStrII:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrII:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrII:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_II', 'SWVDETAIL', oStrII, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_II"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_II', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

   If lTribDUIMP
      oStrEVGII:= FWFormStruct( 1, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVG"), "|")) })
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP+EVG_IDIMP+EVG_SEQDUI+EVG_FUNDLE
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
      oModel:AddGrid('EVGGRID_II','EV2MSTR_TRIB_II'  ,oStrEVGII,,/*bPosValid*/,,, /*bLoadEIN*/)
      oModel:GetModel("EVGGRID_II"):SetNoInsertLine(.T.)
      oModel:GetModel("EVGGRID_II"):SetNoDeleteLine(.T.)
      oModel:GetModel("EVGGRID_II"):SetNoUpdateLine(.T.)
      oModel:GetModel("EVGGRID_II"):SetOptional( .T. )
      oModel:GetModel("EVGGRID_II"):SetUniqueLine(aCamposEVG)
      
      oModel:SetRelation('EVGGRID_II', {;
         { 'EVG_FILIAL'  ,'xFilial("EVG")'},;
         { 'EVG_HAWB'    ,'EV2_HAWB'      },;
         { 'EVG_LOTE'    ,'EV2_LOTE'      },;
         { 'EVG_SEQDUI'  ,'EV2_SEQDUI'    },;
         { 'EVG_IDIMP'   , "'1'"          }},;
         EVG->(dbSetOrder(2)) ) //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP
   EndIf
   //====================IPI====================
   oStrIPI := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_IPI"), "|")) })
   oStrIPI:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrIPI:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrIPI:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_IPI', 'SWVDETAIL', oStrIPI, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_IPI"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_IPI', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
   
   If lTribDUIMP
      oStrEVGIPI:= FWFormStruct( 1, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVG"), "|")) })
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP+EVG_IDIMP+EVG_SEQDUI+EVG_FUNDLE
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
      oModel:AddGrid('EVGGRID_IPI','EV2MSTR_TRIB_IPI'  ,oStrEVGIPI,,/*bPosValid*/,,, /*bLoadEIN*/)
      oModel:GetModel("EVGGRID_IPI"):SetNoInsertLine(.T.)
      oModel:GetModel("EVGGRID_IPI"):SetNoDeleteLine(.T.)
      oModel:GetModel("EVGGRID_IPI"):SetNoUpdateLine(.T.)
      oModel:GetModel("EVGGRID_IPI"):SetOptional( .T. )
      oModel:GetModel("EVGGRID_IPI"):SetUniqueLine(aCamposEVG)

      oModel:SetRelation('EVGGRID_IPI', {;
         { 'EVG_FILIAL'  ,'xFilial("EVG")'},;
         { 'EVG_HAWB'    ,'EV2_HAWB'      },;
         { 'EVG_LOTE'    ,'EV2_LOTE'      },;
         { 'EVG_SEQDUI'  ,'EV2_SEQDUI'    },;
         { 'EVG_IDIMP'   , "'2'"          }},;
         EVG->(dbSetOrder(2)) ) //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP
   EndIf
   
   If lTribDUIMP
   //====================PIS====================
      oStrPIS := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_PIS"), "|")) })
      oStrPIS:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
      oStrPIS:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
      oStrPIS:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
   
      oModel:AddFields( 'EV2MSTR_TRIB_PIS', 'SWVDETAIL', oStrPIS, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
      oModel:GetModel("EV2MSTR_TRIB_PIS"):SetOnlyQuery(.T.) //Retira o modelo do commit
      oModel:SetRelation('EV2MSTR_TRIB_PIS', { ;
         { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
         { 'EV2_LOTE'     ,'EV1_LOTE'      },;
         { 'EV2_HAWB'     ,'WV_HAWB'       },;
         { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
         },; 
         EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

      oStrEVGPIS:= FWFormStruct( 1, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVG"), "|")) })
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP+EVG_IDIMP+EVG_SEQDUI+EVG_FUNDLE
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
      oModel:AddGrid('EVGGRID_PIS','EV2MSTR_TRIB_PIS'  ,oStrEVGPIS,,/*bPosValid*/,,, /*bLoadEIN*/)
      oModel:GetModel("EVGGRID_PIS"):SetNoInsertLine(.T.)
      oModel:GetModel("EVGGRID_PIS"):SetNoDeleteLine(.T.)
      oModel:GetModel("EVGGRID_PIS"):SetNoUpdateLine(.T.)
      oModel:GetModel("EVGGRID_PIS"):SetOptional( .T. )
      oModel:GetModel("EVGGRID_PIS"):SetUniqueLine(aCamposEVG)
      
      oModel:SetRelation('EVGGRID_PIS', {;
         { 'EVG_FILIAL'  ,'xFilial("EVG")'},;
         { 'EVG_HAWB'    ,'EV2_HAWB'      },;
         { 'EVG_LOTE'    ,'EV2_LOTE'      },;
         { 'EVG_SEQDUI'  ,'EV2_SEQDUI'    },;
         { 'EVG_IDIMP'   , "'3'"          }},;
         EVG->(dbSetOrder(2)) ) //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP

   //====================COFINS====================
      oStrCOF := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_COFINS"), "|")) })
      oStrCOF:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
      oStrCOF:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
      oStrCOF:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
   
      oModel:AddFields( 'EV2MSTR_TRIB_COFINS', 'SWVDETAIL', oStrCOF, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
      oModel:GetModel("EV2MSTR_TRIB_COFINS"):SetOnlyQuery(.T.) //Retira o modelo do commit
      oModel:SetRelation('EV2MSTR_TRIB_COFINS', { ;
         { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
         { 'EV2_LOTE'     ,'EV1_LOTE'      },;
         { 'EV2_HAWB'     ,'WV_HAWB'       },;
         { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
         },; 
         EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
      
      oStrEVGCOF:= FWFormStruct( 1, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVG"), "|")) })
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP+EVG_IDIMP+EVG_SEQDUI+EVG_FUNDLE
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
      oModel:AddGrid('EVGGRID_COFINS','EV2MSTR_TRIB_COFINS'  ,oStrEVGCOF,,/*bPosValid*/,,, /*bLoadEIN*/)
      oModel:GetModel("EVGGRID_COFINS"):SetNoInsertLine(.T.)
      oModel:GetModel("EVGGRID_COFINS"):SetNoDeleteLine(.T.)
      oModel:GetModel("EVGGRID_COFINS"):SetNoUpdateLine(.T.)
      oModel:GetModel("EVGGRID_COFINS"):SetOptional( .T. )
      oModel:GetModel("EVGGRID_COFINS"):SetUniqueLine(aCamposEVG)
      
      oModel:SetRelation('EVGGRID_COFINS', {;
         { 'EVG_FILIAL'  ,'xFilial("EVG")'},;
         { 'EVG_HAWB'    ,'EV2_HAWB'      },;
         { 'EVG_LOTE'    ,'EV2_LOTE'      },;
         { 'EVG_SEQDUI'  ,'EV2_SEQDUI'    },;
         { 'EVG_IDIMP'   , "'4'"          }},;
         EVG->(dbSetOrder(2)) ) //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP
   Else
   //====================PIS/COFINS====================
      oStrPISCOF := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_PISCOFINS"), "|")) })
      oStrPISCOF:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
      oStrPISCOF:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
      oStrPISCOF:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
   
      oModel:AddFields( 'EV2MSTR_TRIB_PISCOFINS', 'SWVDETAIL', oStrPISCOF, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
      oModel:GetModel("EV2MSTR_TRIB_PISCOFINS"):SetOnlyQuery(.T.) //Retira o modelo do commit
      oModel:SetRelation('EV2MSTR_TRIB_PISCOFINS', { ;
         { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
         { 'EV2_LOTE'     ,'EV1_LOTE'      },;
         { 'EV2_HAWB'     ,'WV_HAWB'       },;
         { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
         },; 
         EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
   EndIf
   //====================ANTIDUMPING====================
   If lTribDUIMP
      oStrANTDUM := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTOS_ANTIDUMPING"), "|")) })
      oStrANTDUM:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
      oStrANTDUM:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
      oStrANTDUM:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
   
      oModel:AddFields( 'EV2MSTR_TRIB_ANTIDUMPING', 'SWVDETAIL', oStrANTDUM, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
      oModel:GetModel("EV2MSTR_TRIB_ANTIDUMPING"):SetOnlyQuery(.T.) //Retira o modelo do commit
      oModel:SetRelation('EV2MSTR_TRIB_ANTIDUMPING', { ;
         { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
         { 'EV2_LOTE'     ,'EV1_LOTE'      },;
         { 'EV2_HAWB'     ,'WV_HAWB'       },;
         { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
         },; 
         EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

      oStrEVGDUM:= FWFormStruct( 1, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVG"), "|")) })
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP+EVG_IDIMP+EVG_SEQDUI+EVG_FUNDLE
      //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
      oModel:AddGrid('EVGGRID_ANTIDUMPING','EV2MSTR_TRIB_ANTIDUMPING'  ,oStrEVGDUM,,/*bPosValid*/,,, /*bLoadEIN*/)
      oModel:GetModel("EVGGRID_ANTIDUMPING"):SetNoInsertLine(.T.)
      oModel:GetModel("EVGGRID_ANTIDUMPING"):SetNoDeleteLine(.T.)
      oModel:GetModel("EVGGRID_ANTIDUMPING"):SetNoUpdateLine(.T.)
      oModel:GetModel("EVGGRID_ANTIDUMPING"):SetOptional( .T. )
      oModel:GetModel("EVGGRID_ANTIDUMPING"):SetUniqueLine(aCamposEVG)
      
      oModel:SetRelation('EVGGRID_ANTIDUMPING', {;
         { 'EVG_FILIAL'  ,'xFilial("EVG")'},;
         { 'EVG_HAWB'    ,'EV2_HAWB'      },;
         { 'EVG_LOTE'    ,'EV2_LOTE'      },;
         { 'EVG_SEQDUI'  ,'EV2_SEQDUI'    },;
         { 'EVG_IDIMP'   , "'5'"          }},;
         EVG->(dbSetOrder(2)) ) //EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP
   EndIf
//====================INTEGRACAO====================
   oStrInteg := FWFormStruct( 1, "EV2", {|x| CheckField(x, strtokarr2(DU100Model("EV2_TRIBUTACAO"), "|")) })
   oStrInteg:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrInteg:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrInteg:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_OBS', 'SWVDETAIL', oStrInteg, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_OBS"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_OBS', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV3
Objetivo   : Define o modelo para Acréscimos (EV3)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV3(oModel)
   local oStruEV3   := nil

   oStruEV3 := FWFormStruct( 1, "EV3", {|x| CheckField(x, strtokarr2(DU100Model("EV3"), "|")) })

   oStruEV3:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV3:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV3:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddGrid('EV3DETAIL', 'EV2MSTR_MC', oStruEV3)

   oModel:GetModel("EV3DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV3DETAIL"):SetUniqueLine({"EV3_FILIAL","EV3_LOTE","EV3_HAWB","EV3_SEQDUI","EV3_ACRES"} )

   oModel:SetRelation('EV3DETAIL', {;
      { 'EV3_FILIAL'   ,'xFilial("EV3")'},;
      { 'EV3_LOTE'     ,'EV2_LOTE'      },;
      { 'EV3_HAWB'     ,'EV2_HAWB'      },;
      { 'EV3_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV3->(dbSetOrder(3)) ) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI

return nil

/*
Função     : setMdlEV4
Objetivo   : Define o modelo para Deduções (EV4)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV4(oModel)
   local oStruEV4   := nil

   oStruEV4 := FWFormStruct( 1, "EV4", {|x| CheckField(x, strtokarr2(DU100Model("EV4"), "|")) })

   oStruEV4:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV4:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV4:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   oModel:AddGrid('EV4DETAIL', 'EV2MSTR_MC', oStruEV4)

   oModel:GetModel("EV4DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV4DETAIL"):SetUniqueLine({"EV4_FILIAL","EV4_LOTE","EV4_HAWB","EV4_SEQDUI","EV4_DEDU"} )

   oModel:SetRelation('EV4DETAIL', {;
      { 'EV4_FILIAL'   ,'xFilial("EV4")'},;
      { 'EV4_LOTE'     ,'EV2_LOTE'      },;
      { 'EV4_HAWB'     ,'EV2_HAWB'      },;
      { 'EV4_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV4->(dbSetOrder(3)) ) // EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI

return nil

/*
Função     : setMdlEVE
Objetivo   : Define o modelo para LPCO's (EVE)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVE(oModel)
   local oStruEVE   := nil

   oStruEVE := FWFormStruct( 1, "EVE", {|x| CheckField(x, strtokarr2(DU100Model("EVE"), "|")) })

   oStruEVE:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEVE:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEVE:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddGrid('EVEDETAIL', 'EV2MSTR_MC', oStruEVE)

   oModel:GetModel("EVEDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetOptional( .T. )

   oModel:GetModel("EVEDETAIL"):SetUniqueLine({"EVE_FILIAL","EVE_LOTE","EVE_SEQDUI","EVE_LPCO"} )

   oModel:SetRelation('EVEDETAIL', {;
      { 'EVE_FILIAL'   ,'xFilial("EVE")'},;
      { 'EVE_LOTE'     ,'EV2_LOTE'      },;
      { 'EVE_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EVE->(dbSetOrder(2)) ) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI

return nil

/*
Função     : setMdlEVI
Objetivo   : Define o modelo para Certificado Mercosul (EVI)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVI(oModel)
   local oStruEVI   := nil

   oStruEVI := FWFormStruct( 1, "EVI", {|x| CheckField(x, strtokarr2(DU100Model("EVI"), "|")) })

   oStruEVI:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEVI:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEVI:SetProperty('*', MODEL_FIELD_NOUPD, .F.)

   oModel:AddGrid('EVIDETAIL', 'EV2MSTR_MC', oStruEVI)

   oModel:GetModel("EVIDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetOptional( .T. )
   oModel:GetModel("EVIDETAIL"):SetUniqueLine({"EVI_FILIAL","EVI_LOTE","EVI_HAWB","EVI_SEQDUI","EVI_NUM"} )

   oModel:SetRelation('EVIDETAIL', {;
      { 'EVI_FILIAL'   ,'xFilial("EVI")'},;
      { 'EVI_LOTE'     ,'EV2_LOTE'      },;
      { 'EVI_HAWB'     ,'EV2_HAWB'      },;
      { 'EVI_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EVI->(dbSetOrder(2)) ) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI

return nil

/*
Função     : setMdlEV6
Objetivo   : Define o modelo para Documentos Vinculados (EV6)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV6(oModel)
   local oStruEV6   := nil

   oStruEV6 := FWFormStruct( 1, "EV6", {|x| CheckField(x, strtokarr2(DU100Model("EV6"), "|")) })

   oStruEV6:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV6:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV6:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   oModel:AddGrid('EV6DETAIL', 'EV2MSTR_MC', oStruEV6)

   oModel:GetModel("EV6DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV6DETAIL"):SetUniqueLine({'EV6_FILIAL','EV6_LOTE','EV6_HAWB','EV6_SEQDUI','EV6_TIPVIN','EV6_DOCVIN'})

   oModel:SetRelation('EV6DETAIL', {;
      { 'EV6_FILIAL'   ,'xFilial("EV6")'},;
      { 'EV6_LOTE'     ,'EV2_LOTE'      },;
      { 'EV6_HAWB'     ,'EV2_HAWB'      },;
      { 'EV6_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV6->(dbSetOrder(3)) ) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI

return nil

Static Function ViewDef()
   local oModel     := nil
   local oView      := nil
   local bInteg     := { |oView| if( oView:GetbuttonWasPressed() == 0, DU101PrcInt(,,oView:GetOperation()), nil) }

   oView := FWFormView():New() // Cria o objeto de View
   oModel := FWLoadModel("EICDU100") // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
   oView:SetModel( oModel ) // Define qual o Modelo de dados a ser utilizado
   oView:SetDescription(STR0001) // "Integração DUIMP" 
   
   SetViewStuc(oView)

   // Capa da rotina
   SetViewEV1(oView)
   SetViewEV9(oView)
   SetViewEVB(oView)
   SetViewCmp(oView)

   // Itens da rotina
   SetViewSWV(oView)
   setViewMC(oView)
   setViewFF(oView)
   setViewCV(oView)
   if DUIMP2310()
      setViewTR(oView)
   endif
   setViewAcDe(oView)
   setViewEVE(oView)
   setViewEVI(oView)
   setViewEV6(oView)

   oView:SetAfterOkButton(bInteg)

Return oView 
/*
Função     : SetViewStuc
Objetivo   : Define o layout da tela
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Static Function SetViewStuc(oView)
   local bActivate  := { |oView| DU100VWAct(oView)}

   If CanUseApp()
      oView:CreateHorizontalBox('GERAL',100)
      oView:CreateFolder('PASTAS','GERAL')
      oView:AddSheet('PASTAS','PASTA1', STR0134 ) //"Duimp"
      oView:AddSheet('PASTAS','PASTA2', STR0135 ) //"Atributos"

      oView:CreateHorizontalBox("CAPA", 40,,,'PASTAS', 'PASTA1' )
      oView:CreateFolder("FOLDER_CAPA", "CAPA")
      oView:addSheet("FOLDER_CAPA", "CADASTRAIS", STR0006 ) //"Cadastrais"
      oView:addSheet("FOLDER_CAPA", "DOCINSTR"  , STR0007 ) //"Documentos de Instrução"
      oView:addSheet("FOLDER_CAPA", "PROCVINC"  , STR0008 ) //"Processos Vinculados"
      oView:addSheet("FOLDER_CAPA", "DADOS_COMP", STR0063 ) //"Dados Complementares"
      
      //oView:addSheet("FOLDER_CAPA", "ATRIBUTOS", "Atributos" ) //"Atributos"
      oView:CreateHorizontalBox( 'BOX_ATRIBUTOS', 100,,,'PASTAS', 'PASTA2')
      oView:AddOtherObject("VIEW_ATRIB", {|oPanel| DUCallApp(oPanel)})
      oView:SetOwnerView("VIEW_ATRIB", 'BOX_ATRIBUTOS')
      oView:SetAfterViewActivate(bActivate)

      oView:CreateHorizontalBox("ITEM", 60,,,'PASTAS', 'PASTA1' )
      oView:CreateVerticalBox('INF_ESQ', 30,"ITEM",,'PASTAS','PASTA1')    //Cria Box a esquerda para dados da SWV
      oView:CreateVerticalBox('INF_DIR', 70,"ITEM",,'PASTAS','PASTA1')     ////Cria Box a Direita para Pastas do item

      oView:CreateFolder("FOLDER_ITEM", "INF_DIR")
      oView:addSheet("FOLDER_ITEM", "MERCADORIA", STR0030 ) // "Mercadoria"
      oView:addSheet("FOLDER_ITEM", "FABR_FORN" , STR0031 ) // "Fabricante / Fornecedor"
      oView:addSheet("FOLDER_ITEM", "COND_VENDA", STR0032 ) // "Condição de Venda / Cambiais"
      oView:addSheet("FOLDER_ITEM", "ACRES_DEDU", STR0033 ) // "Acréscimos e Deduções"
      oView:addSheet("FOLDER_ITEM", "LPCO"      , "LPCO's" )
      oView:addSheet("FOLDER_ITEM", "CERT_MERC" , STR0034 ) // "Certificado Mercosul"
      oView:addSheet("FOLDER_ITEM", "DOC_VINCUL", STR0035 ) // "Documentos Vinculados"
      if DUIMP2310()
         oView:addSheet("FOLDER_ITEM", "TRIBUTOS"  , STR0091 ) // "Tributos"
      endif
   Else
      oView:CreateHorizontalBox("CAPA", 40)
      oView:CreateFolder("FOLDER_CAPA", "CAPA")
      oView:addSheet("FOLDER_CAPA", "CADASTRAIS", STR0006 ) //"Cadastrais"
      oView:addSheet("FOLDER_CAPA", "DOCINSTR"  , STR0007 ) //"Documentos de Instrução"
      oView:addSheet("FOLDER_CAPA", "PROCVINC"  , STR0008 ) //"Processos Vinculados"
      oView:addSheet("FOLDER_CAPA", "DADOS_COMP", STR0063 ) //"Dados Complementares"

      oView:CreateHorizontalBox("ITEM", 60)
      oView:CreateVerticalBox('INF_ESQ', 30,"ITEM",,,)    //Cria Box a esquerda para dados da SWV
      oView:CreateVerticalBox('INF_DIR', 70,"ITEM",,,)     ////Cria Box a Direita para Pastas do item

      oView:CreateFolder("FOLDER_ITEM", "INF_DIR")
      oView:addSheet("FOLDER_ITEM", "MERCADORIA", STR0030 ) // "Mercadoria"
      oView:addSheet("FOLDER_ITEM", "FABR_FORN" , STR0031 ) // "Fabricante / Fornecedor"
      oView:addSheet("FOLDER_ITEM", "COND_VENDA", STR0032 ) // "Condição de Venda / Cambiais"
      oView:addSheet("FOLDER_ITEM", "ACRES_DEDU", STR0033 ) // "Acréscimos e Deduções"
      oView:addSheet("FOLDER_ITEM", "LPCO"      , "LPCO's" )
      oView:addSheet("FOLDER_ITEM", "CERT_MERC" , STR0034 ) // "Certificado Mercosul"
      oView:addSheet("FOLDER_ITEM", "DOC_VINCUL", STR0035 ) // "Documentos Vinculados"
      if DUIMP2310()
         oView:addSheet("FOLDER_ITEM", "TRIBUTOS"  , STR0091 ) // "Tributos"
      endif
   EndIf
Return nil

/*
Função     : SetViewEV1
Objetivo   : Cria a instância da View para a tabela EV1 (Cadastrais)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Static Function SetViewEV1(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV1   := nil

   aCampos := {{"EV1_LOTE","01"},{"EV1_HAWB","01"},{"EV1_SEQUEN","01"},{"EV1_DI_NUM","01"}, {"EV1_VERSAO","01"},{"EV1_USRGER","01"},{"EV1_DATGER","01"},{"EV1_HORGER","01"},; 
      {"EV1_IMPNOM"  ,"02"}, {"EV1_IMPNRO","02"}, {"EV1_INFCOM","02"},;
      {"EV1_COIDM","03"},{"EV1_URFDES","03"},{"EV1_PAISPR","03"},;
      {"EV1_SEGMOE","04"}, {"EV1_SETOMO","04"}}

   oStruEV1 := FWFormStruct( 2, "EV1", {|x| CheckField(x, aCampos) } )
   oStruEV1:AddGroup("01", STR0009 , "01", 2) //"Dados Gerais"
   oStruEV1:AddGroup("02", STR0010 , "01", 2) //"Identificação"
   oStruEV1:AddGroup("03", STR0011 , "01", 2) //"Carga"
   oStruEV1:AddGroup("04", STR0012 , "01", 2) //"Seguro"

   //Remove os Folders
   oStruEV1:aFolders := {}

   //Títulos
   oStruEV1:SetProperty('EV1_HAWB'    , MVC_VIEW_TITULO, STR0024) // Embarque
   oStruEV1:SetProperty('EV1_IMPNOM'  , MVC_VIEW_TITULO, STR0025) // Importador
   oStruEV1:SetProperty('EV1_IMPNRO'  , MVC_VIEW_TITULO, STR0026) // CNPJ Importador  
   oStruEV1:SetProperty('EV1_COIDM'   , MVC_VIEW_TITULO, STR0027) // Ident. Carga  
 
   oStruEV1:SetProperty('EV1_DI_NUM'  , MVC_VIEW_TITULO, STR0114) // "Número da DUIMP"

   for nCpo := 1 to len(aCampos)
      oStruEV1:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV1:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM , strZero(nCpo,2))
   next

   // Consulta Padrão SW6
   oStruEV1:SetProperty("EV1_HAWB"  , MVC_VIEW_LOOKUP , "SW6DUI" )

   oView:CreateHorizontalBox( 'VIEW_CADASTRAIS', 100,,,'FOLDER_CAPA', "CADASTRAIS")
   oView:AddField( 'VIEW_EV1', oStruEV1, 'EV1MASTER' )
   oView:SetOwnerView( 'VIEW_EV1', 'VIEW_CADASTRAIS' )

Return Nil

/*
Função     : SetViewEV9
Objetivo   : Cria a instância da View para a tabela EV9 (Documentos de Instrução)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewEV9(oView)
   local oStruEV9   := nil

   oStruEV9 := FWFormStruct( 2, "EV9", {|x| CheckField(x, strtokarr2(DU100View("EV9"), "|")) }   )

   oStruEV9:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV9:SetProperty('EV9_CODIN'   , MVC_VIEW_TITULO, STR0044) // "Código"
   oStruEV9:SetProperty('EV9_DOCTO'   , MVC_VIEW_TITULO, STR0045) // "Número do Documento"

   oView:CreateHorizontalBox( 'VIEW_DOCINSTR', 100,,,'FOLDER_CAPA', "DOCINSTR")
   oView:AddGrid( 'VIEW_EV9', oStruEV9, 'EV9DETAIL' )
   oView:SetOwnerView( 'VIEW_EV9', 'VIEW_DOCINSTR' )

return nil

/*
Função     : SetViewEVB
Objetivo   : Cria a instância da View para a tabela EVB (Processo Vinculados)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewEVB(oView)
   local oStruEVB   := nil

   oStruEVB := FWFormStruct( 2, "EVB", {|x| CheckField(x, strtokarr2(DU100View("EVB"), "|")) }   )

   oStruEVB:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEVB:SetProperty('EVB_CODPV', MVC_VIEW_TITULO, STR0023) // Tipo
   oStruEVB:SetProperty('EVB_DESPV', MVC_VIEW_TITULO, STR0022) // Identificação  

   oView:CreateHorizontalBox( 'VIEW_PROCVINC', 100,,,'FOLDER_CAPA', "PROCVINC")
   oView:AddGrid( 'VIEW_EVB', oStruEVB, 'EVBDETAIL' )
   oView:SetOwnerView( 'VIEW_EVB', 'VIEW_PROCVINC' )

Return Nil

/*
Função     : SetViewCmp
Objetivo   : Cria a instância da View para a tabela EV1 (Dados Complementares)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
Static Function SetViewCmp(oView)
   local oStruEV1   := nil

   oStruEV1 := FWFormStruct( 2, "EV1", {|x| CheckField(x, strtokarr2(DU100View("EV1"), "|")) } )

   //Remove os Folders
   oStruEV1:aFolders := {}

   //Títulos
   oStruEV1:SetProperty('EV1_LOGINT'  , MVC_VIEW_TITULO, STR0060) // Log Geral da Integração 

   oView:CreateHorizontalBox( 'VIEW_DADOS_COMP', 100,,,'FOLDER_CAPA', "DADOS_COMP")
   oView:AddField( 'VIEW_EV1_DADOS_COMP', oStruEV1, 'EV1MASTER' )
   oView:SetOwnerView( 'VIEW_EV1_DADOS_COMP', 'VIEW_DADOS_COMP' )

Return Nil

/*
Função     : SetViewSWV
Objetivo   : Cria a instância da View para a tabela SWV (Dados itens duimp)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewSWV(oView)
   local oStruSWV   := nil

   oStruSWV := FWFormStruct( 2, "SWV", {|x| alltrim(x) $ DU100View("SWV") } )

   oStruSWV:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   //ordem dos campos
   oStruSWV:SetProperty('WV_SEQDUIM', MVC_VIEW_ORDEM, '01') 
   oStruSWV:SetProperty('WV_INVOICE', MVC_VIEW_ORDEM, '02') 
   oStruSWV:SetProperty('WV_FORN'   , MVC_VIEW_ORDEM, '03') 
   oStruSWV:SetProperty('WV_FORLOJ' , MVC_VIEW_ORDEM, '04') 
   oStruSWV:SetProperty('WV_NOMEFOR', MVC_VIEW_ORDEM, '05') 
   oStruSWV:SetProperty('WV_PO_NUM' , MVC_VIEW_ORDEM, '06') 
   oStruSWV:SetProperty('WV_POSICAO', MVC_VIEW_ORDEM, '07') 
   oStruSWV:SetProperty('WV_SEQUENC', MVC_VIEW_ORDEM, '08') 
   oStruSWV:SetProperty('WV_COD_I'  , MVC_VIEW_ORDEM, '09') 
   oStruSWV:SetProperty('WV_DESC_DI', MVC_VIEW_ORDEM, '10') 
   oStruSWV:SetProperty('WV_NCM'    , MVC_VIEW_ORDEM, '11') 
   oStruSWV:SetProperty('WV_QTDE'   , MVC_VIEW_ORDEM, '12') 
   oStruSWV:SetProperty('WV_LOTE'   , MVC_VIEW_ORDEM, '13') 
   oStruSWV:SetProperty('WV_DT_VALI', MVC_VIEW_ORDEM, '14') 
   oStruSWV:SetProperty('WV_DFABRI' , MVC_VIEW_ORDEM, '15') 
   oStruSWV:SetProperty('WV_OBS'    , MVC_VIEW_ORDEM, '16') 


   oView:AddGrid( 'VIEW_SWV', oStruSWV, 'SWVDETAIL' )
   oView:SetOwnerView( 'VIEW_SWV', 'INF_ESQ' )

Return Nil

/*
Função     : setViewMC
Objetivo   : Define o view para Mercadorias (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewMC(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_IDPTCP","01"},{"EV2_VRSACP","01"},{"EV2_CNPJRZ","01"},;
      {"EV2_VINCCO","02"},{"EV2_APLME" ,"02"},{"EV2_MATUSA","02"},{"EV2_DSCCIT","02"},;
      {"EV2_IMPCO" ,"03"},{"EV2_CNPJAD","03"},;
      {"EV2_NMCOM" ,"04"},{"EV2_QTCOM" ,"04"},{"EV2_QT_EST","04"},{"EV2_PESOL" ,"04"},{"EV2_MOE1","04"},{"EV2_VLMLE","04"}}
      
   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:AddGroup("01", STR0036 , "01", 2) // "Catálogo de Produtos"
   oStruEV2:AddGroup("02", STR0037 , "01", 2) // "Dados Gerais"
   oStruEV2:AddGroup("03", STR0038 , "01", 2) // "Caracterização da Importação"
   oStruEV2:AddGroup("04", STR0039 , "01", 2) // "Valores"

   //Remove os Folders
   oStruEV2:aFolders := {}

   //Títulos
   oStruEV2:SetProperty('EV2_VINCCO'  , MVC_VIEW_TITULO, STR0046) // Código
   oStruEV2:SetProperty('EV2_MATUSA'  , MVC_VIEW_TITULO, STR0047) // Condição
   oStruEV2:SetProperty('EV2_NMCOM'   , MVC_VIEW_TITULO, STR0048) // Unidade Comercial

   oStruEV2:SetProperty('EV2_APLME'   , MVC_VIEW_COMBOBOX, {" ",STR0064, STR0065 } ) // "1=Consumo","2=Revenda"
   oStruEV2:SetProperty('EV2_MATUSA'  , MVC_VIEW_COMBOBOX, {" ",STR0066, STR0067 } ) // "1=Usado","2=Nao Usado"
   oStruEV2:SetProperty('EV2_VINCCO'  , MVC_VIEW_COMBOBOX, {" ",STR0068, STR0069, STR0070 } ) // "1=Sem Vinculação","2=Com vinculação, sem influência no preço","3=Com vinculação, com influência no preço"
   oStruEV2:SetProperty('EV2_IMPCO'   , MVC_VIEW_COMBOBOX, {" ",STR0071, STR0072 } ) // "1=Sim","2=Não"

   oStruEV2:SetProperty("EV2_MOE1"   , MVC_VIEW_LOOKUP , "SYF" )

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_MERCADORIAS', 100,,,'FOLDER_ITEM', "MERCADORIA")
   oView:AddField( 'VIEW_EV2_MC', oStruEV2, 'EV2MSTR_MC' )
   oView:SetOwnerView( 'VIEW_EV2_MC', 'VIEW_MERCADORIAS' )

return nil

/*
Função     : setViewFF
Objetivo   : Define o view para Fabricante / Fornecedor (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewFF(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_FABFOR","01"},{"EV2_TINFA" ,"01"},{"EV2_VRSFAB","01"},{"EV2_PAIOME","01"},;
      {"EV2_TINFO" ,"02"},{"EV2_VRSFOR","02"},{"EV2_PAISPR","02"}}
      
   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:SetProperty('EV2_TINFA', MVC_VIEW_TITULO , STR0102 ) // "Código Fabr." 
   oStruEV2:SetProperty('EV2_TINFO', MVC_VIEW_TITULO , STR0103 ) // "Código Forn."
   oStruEV2:SetProperty('EV2_TINFA' , MVC_VIEW_DESCR , STR0104 ) // "Código Portal Único"
   oStruEV2:SetProperty('EV2_TINFO' , MVC_VIEW_DESCR , STR0104 ) // "Código Portal Único"

   oStruEV2:AddGroup("01", STR0040 , "01", 2) // "Dados do Fabricante"
   oStruEV2:AddGroup("02", STR0041 , "01", 2) // "Fornecedor"

   //Remove os Folders
   oStruEV2:aFolders := {}

   //Títulos
   oStruEV2:SetProperty('EV2_FABFOR'  , MVC_VIEW_TITULO, STR0049) // Indicador Fabricante
   oStruEV2:SetProperty('EV2_PAIOME'  , MVC_VIEW_TITULO, STR0050) // País de Origem

   oStruEV2:SetProperty('EV2_FABFOR'  , MVC_VIEW_COMBOBOX, {" ", STR0073, STR0074, STR0075 } ) // "1=Fabricante / Produtor é o Exportador" , "2=Fabricante / Produtor não é o Exportador" , "3=O Fabricante / Produtor é Desconhecido"

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_FAB_FORN', 100,,,'FOLDER_ITEM', "FABR_FORN")
   oView:AddField( 'VIEW_EV2_FF', oStruEV2, 'EV2MSTR_FF' )
   oView:SetOwnerView( 'VIEW_EV2_FF', 'VIEW_FAB_FORN' )

return nil

/*
Função     : setViewCV
Objetivo   : Define o view para Condição de Venda / Cambiais (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewCV(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_METVAL","01"},{"EV2_INCOTE","01"},;
      {"EV2_TIPCOB","02"},{"EV2_NRROF" ,"02"},{"EV2_INSTFI","02"},{"EV2_VL_FIN","02"},{"EV2_MOTIVO","02"}}

   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:AddGroup("01", STR0042 , "01", 2) // "Valoração"
   oStruEV2:AddGroup("02", STR0043 , "01", 2) // "Dados Cambiais"

   //Remove os Folders
   oStruEV2:aFolders := {}

   oStruEV2:SetProperty('EV2_TIPCOB'  , MVC_VIEW_COMBOBOX, {" ", STR0076, STR0077, STR0078, STR0079 } ) // "1=180 DD" ,"2=De 181 a 360 DD" ,"3=Acima de 360 DD" ,"4=Sem Cobertura"

   oStruEV2:SetProperty("EV2_METVAL"  , MVC_VIEW_LOOKUP , "SJM" )
   oStruEV2:SetProperty("EV2_INCOTE"  , MVC_VIEW_LOOKUP , "SYJ" )
   oStruEV2:SetProperty("EV2_INSTFI"  , MVC_VIEW_LOOKUP , "SJ7" )
   oStruEV2:SetProperty("EV2_MOTIVO"  , MVC_VIEW_LOOKUP , "SJ8" )

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_COND_VENDA', 100,,,'FOLDER_ITEM', "COND_VENDA")
   oView:AddField( 'VIEW_EV2_CC', oStruEV2, 'EV2MSTR_CV' )
   oView:SetOwnerView( 'VIEW_EV2_CC', 'VIEW_COND_VENDA' )

return nil

/*
Função     : setViewTR
Objetivo   : Define o view para Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewTR(oView)
   local aCampos    := {}
   local oStrII     := nil
   local oStrIPI    := nil
   local oStrPISCOF := nil
   local oStrPIS    := nil
   local oStrCOF    := nil
   local oStrDUMP   := nil
   local oStrInteg  := nil
   local oStrEVGII  := nil
   local oStrEVGIPI := nil
   local oStrEVGPIS := nil
   local oStrEVGCOF := nil
   local oStrEVGDUM := nil
   local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

   aCampos := { {"EV2_VLRCII","01", "II " + STR0092},{"EV2_VRDII","01", "II " + STR0093},{"EV2_VLDII","01", "II " + STR0094},{"EV2_VLSII","01", "II " + STR0095},{"EV2_VRCII","01", "II " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
   oStrII := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLRCII||EV2_VRDII||EV2_VLDII||EV2_VLSII||EV2_VRCII" } )
   setStruEV2(@oStrII, aCampos)

   aCampos := { {"EV2_VLCIPI","01", "IPI " + STR0092},{"EV2_VRDIPI","01", "IPI " + STR0093},{"EV2_VDIPI","01", "IPI " + STR0094},{"EV2_VLSIPI","01", "IPI " + STR0095},{"EV2_VRCIPI","01", "IPI " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
   oStrIPI := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCIPI||EV2_VRDIPI||EV2_VDIPI||EV2_VLSIPI||EV2_VRCIPI" } )
   setStruEV2(@oStrIPI, aCampos)

   If lTribDUIMP
      //PIS
      aCampos := {{"EV2_VLCPIS","01", "PIS " + STR0092},{"EV2_VRDPIS","01", "PIS " + STR0093},{"EV2_VDEPIS","01", "PIS " + STR0094},{"EV2_VLSPIS","01", "PIS " + STR0095},{"EV2_VRCPIS","01", "PIS " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
      oStrPIS := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCPIS||EV2_VRDPIS||EV2_VDEPIS||EV2_VLSPIS||EV2_VRCPIS" } )
      setStruEV2(@oStrPIS, aCampos)
      //COFINS
      aCampos := {{"EV2_VLCCOF","01", "COFINS " + STR0092},{"EV2_VRDCOF","01", "COFINS " + STR0093},{"EV2_VDECOF","01", "COFINS " + STR0094},{"EV2_VLSCOF","01", "COFINS " + STR0095},{"EV2_VRCCOF","01", "COFINS " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
      oStrCOF := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCCOF||EV2_VRDCOF||EV2_VDECOF||EV2_VLSCOF||EV2_VRCCOF" } )
      setStruEV2(@oStrCOF, aCampos)
      //Anti-Dumping
      aCampos := {{"EV2_VLC_DU","01", "Antidumping " + STR0092},{"EV2_VLD_DU","01", "Antidumping " + STR0094},{"EV2_VLR_DU","01", "Antidumping " + STR0096}} // "Calculado" ### "Devido" ### "a Recolher"
      oStrDUMP := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLC_DU||EV2_VLD_DU||EV2_VLR_DU" } )
      setStruEV2(@oStrDUMP, aCampos)
      //EVG II
      oStrEVGII:= FWFormStruct( 2, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVGGRID"), "|")) })
      //EVG IPI
      oStrEVGIPI:= FWFormStruct( 2, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVGGRID"), "|")) })
      //EVG PIS
      oStrEVGPIS:= FWFormStruct( 2, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVGGRID"), "|")) })
      //EVG COFINS
      oStrEVGCOF:= FWFormStruct( 2, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVGGRID"), "|")) })
      //EVG ANTIDUMPING
      oStrEVGDUM:= FWFormStruct( 2, "EVG", {|x| CheckField(x, strtokarr2(DU100Model("EVGGRID"), "|")) })
   Else
      aCampos := {{"EV2_VLCPIS","01", "PIS " + STR0092},{"EV2_VRDPIS","01", "PIS " + STR0093},{"EV2_VDEPIS","01", "PIS " + STR0094},{"EV2_VLSPIS","01", "PIS " + STR0095},{"EV2_VRCPIS","01", "PIS " + STR0096},; // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
                  {"EV2_VLCCOF","02", "COFINS " + STR0092},{"EV2_VRDCOF","02", "COFINS " + STR0093},{"EV2_VDECOF","02", "COFINS " + STR0094},{"EV2_VLSCOF","02", "COFINS " + STR0095},{"EV2_VRCCOF","02", "COFINS " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
      oStrPISCOF := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCPIS||EV2_VRDPIS||EV2_VDEPIS||EV2_VLSPIS||EV2_VRCPIS||EV2_VLCCOF||EV2_VRDCOF||EV2_VDECOF||EV2_VLSCOF||EV2_VRCCOF" } )
      setStruEV2(@oStrPISCOF, aCampos, "PISCOFINS")
   EndIf

   oStrInteg := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_OBSTRB" } )
   oStrInteg:SetProperty( "EV2_OBSTRB", MVC_VIEW_TITULO, STR0097) // "Obs. Tributos"

   oView:CreateHorizontalBox( 'VIEW_TRIBUTOS', 100,,,'FOLDER_ITEM', "TRIBUTOS") 
   oView:CreateFolder("FOLDER_TRIBUTOS", "VIEW_TRIBUTOS")
   oView:addSheet("FOLDER_TRIBUTOS", "II"          , STR0098 ) //"Imposto de Importação"
   oView:addSheet("FOLDER_TRIBUTOS", "IPI"         , "IPI" ) //"IPI"
   If lTribDUIMP
      oView:addSheet("FOLDER_TRIBUTOS", "PIS"  , "PIS" ) //"PIS"
      oView:addSheet("FOLDER_TRIBUTOS", "COFINS"  , "COFINS" ) //"COFINS"
      oView:addSheet("FOLDER_TRIBUTOS", "ANTIDUMPING"  , "ANTIDUMPING" ) //"AntiDumping"
   Else
      oView:addSheet("FOLDER_TRIBUTOS", "PIS_COFINS"  , "PIS/COFINS" ) //"PIS/COFINS"
   EndIf
   oView:addSheet("FOLDER_TRIBUTOS", "INTEGRACAO"  , STR0099 ) //"Integração"
   //II
   If lTribDUIMP
      oView:CreateHorizontalBox( 'BOX_II', 35,,,'FOLDER_TRIBUTOS', "II")
      oView:AddField( 'VIEW_EV2_TR_II', oStrII, 'EV2MSTR_TRIB_II' )
      oView:SetOwnerView( 'VIEW_EV2_TR_II', 'BOX_II' )
      
      oView:CreateHorizontalBox( 'BOX_II_EVG', 65,,,'FOLDER_TRIBUTOS', "II")
      oView:AddGrid("VIEW_EVG_TR_II", oStrEVGII, "EVGGRID_II")
      oView:SetOwnerView( 'VIEW_EVG_TR_II', 'BOX_II_EVG' )
   Else
      oView:CreateHorizontalBox( 'BOX_II', 100,,,'FOLDER_TRIBUTOS', "II")
      oView:AddField( 'VIEW_EV2_TR_II', oStrII, 'EV2MSTR_TRIB_II' )
      oView:SetOwnerView( 'VIEW_EV2_TR_II', 'BOX_II' )
   EndIf
   
   //IPI
   If lTribDUIMP
      oView:CreateHorizontalBox( 'BOX_IPI', 35,,,'FOLDER_TRIBUTOS', "IPI")
      oView:AddField( 'VIEW_EV2_TR_IPI', oStrIPI, 'EV2MSTR_TRIB_IPI' )
      oView:SetOwnerView( 'VIEW_EV2_TR_IPI', 'BOX_IPI' )

      oView:CreateHorizontalBox( 'BOX_IPI_EVG', 65,,,'FOLDER_TRIBUTOS', "IPI")
      oView:AddGrid("VIEW_EVG_TR_IPI", oStrEVGIPI, "EVGGRID_IPI")
      oView:SetOwnerView( 'VIEW_EVG_TR_IPI', 'BOX_IPI_EVG' )
   Else
      oView:CreateHorizontalBox( 'BOX_IPI', 100,,,'FOLDER_TRIBUTOS', "IPI")
      oView:AddField( 'VIEW_EV2_TR_IPI', oStrIPI, 'EV2MSTR_TRIB_IPI' )
      oView:SetOwnerView( 'VIEW_EV2_TR_IPI', 'BOX_IPI' )
   EndIf

   If lTribDUIMP
      //PIS
      oView:CreateHorizontalBox( 'BOX_PIS', 35,,,'FOLDER_TRIBUTOS', "PIS")
      oView:AddField( 'VIEW_EV2_TR_PIS', oStrPIS, 'EV2MSTR_TRIB_PIS' )
      oView:SetOwnerView( 'VIEW_EV2_TR_PIS', 'BOX_PIS' )

      oView:CreateHorizontalBox( 'BOX_PIS_EVG', 65,,,'FOLDER_TRIBUTOS', "PIS")
      oView:AddGrid("VIEW_EVG_TR_PIS", oStrEVGPIS, "EVGGRID_PIS")
      oView:SetOwnerView( 'VIEW_EVG_TR_PIS', 'BOX_PIS_EVG' )
      
      //COFINS
      oView:CreateHorizontalBox( 'BOX_COFINS', 35,,,'FOLDER_TRIBUTOS', "COFINS")
      oView:AddField( 'VIEW_EV2_TR_COFINS', oStrCOF, 'EV2MSTR_TRIB_COFINS' )
      oView:SetOwnerView( 'VIEW_EV2_TR_COFINS', 'BOX_COFINS' )
      
      oView:CreateHorizontalBox( 'BOX_COFINS_EVG', 65,,,'FOLDER_TRIBUTOS', "COFINS")
      oView:AddGrid("VIEW_EVG_TR_COFINS", oStrEVGCOF, "EVGGRID_COFINS")
      oView:SetOwnerView( 'VIEW_EVG_TR_COFINS', 'BOX_COFINS_EVG' )

      //ANTIDUMPING
      oView:CreateHorizontalBox( 'BOX_ANTIDUMPING', 35,,,'FOLDER_TRIBUTOS', "ANTIDUMPING")
      oView:AddField( 'VIEW_EV2_TR_ANTIDUMPING', oStrDUMP, 'EV2MSTR_TRIB_ANTIDUMPING' )
      oView:SetOwnerView( 'VIEW_EV2_TR_ANTIDUMPING', 'BOX_ANTIDUMPING' )

      oView:CreateHorizontalBox( 'BOX_ANTIDUMPING_EVG', 65,,,'FOLDER_TRIBUTOS', "ANTIDUMPING")
      oView:AddGrid("VIEW_EVG_TR_ANTIDUMPING", oStrEVGDUM, "EVGGRID_ANTIDUMPING")
      oView:SetOwnerView( 'VIEW_EVG_TR_ANTIDUMPING', 'BOX_ANTIDUMPING_EVG' )
   Else
      oView:CreateHorizontalBox( 'BOX_PISCOFINS', 100,,,'FOLDER_TRIBUTOS', "PIS_COFINS")
      oView:AddField( 'VIEW_EV2_TR_PISCOFINS', oStrPISCOF, 'EV2MSTR_TRIB_PISCOFINS' )
      oView:SetOwnerView( 'VIEW_EV2_TR_PISCOFINS', 'BOX_PISCOFINS' )
   EndIf

   oView:CreateHorizontalBox( 'BOX_INTEGRACAO', 100,,,'FOLDER_TRIBUTOS', "INTEGRACAO")
   oView:AddField( 'VIEW_EV2_TR_INTEGRACAO', oStrInteg, 'EV2MSTR_TRIB_OBS' )
   oView:SetOwnerView( 'VIEW_EV2_TR_INTEGRACAO', 'BOX_INTEGRACAO' )

return nil

/*
Função     : setStruEV2
Objetivo   : Define as propriedades para a view dos Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setStruEV2(oStruct, aCampos, cTipo)
   local nCpo       := 0

   default oStruct := FWFormStruct( 2, "EV2" )
   default aCampos := {}
   default cTipo   := ""

   oStruct:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   if empty(cTipo)
      oStruct:AddGroup("01", STR0100 , "01", 2) // "Tributos Registrados"
   else
      oStruct:AddGroup("01", STR0100 + " - PIS" , "01", 2) // "Tributos Registrados"
      oStruct:AddGroup("02", STR0100 + " - COFINS", "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
      if len(aCampos[nCpo]) > 2 .and. !empty(aCampos[nCpo][3])
         oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_TITULO, aCampos[nCpo][3])
      endif
   next

return

/*
Função     : setViewAcDe
Objetivo   : Define o view para Acréscimos (EV3) e Deduções (EV4)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewAcDe(oView)
   local oStruEV3   := nil
   local oStruEV4   := nil

   oView:CreateHorizontalBox( 'VIEW_ACRES_DED', 100,,,'FOLDER_ITEM', "ACRES_DEDU")
   oView:CreateVerticalBox('VIEW_ACRES', 50,"VIEW_ACRES_DED",,'FOLDER_ITEM', "ACRES_DEDU")
   oView:CreateVerticalBox('VIEW_DEDU' , 50,"VIEW_ACRES_DED",,'FOLDER_ITEM', "ACRES_DEDU")

   oStruEV3 := FWFormStruct( 2, "EV3", {|x| CheckField(x, strtokarr2(DU100View("EV3"), "|")) }   )
   oStruEV3:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV3:SetProperty("EV3_MOE"  , MVC_VIEW_LOOKUP , "SYF" )

   oView:AddGrid( 'VIEW_EV3', oStruEV3, 'EV3DETAIL' )
   oView:SetOwnerView( 'VIEW_EV3', 'VIEW_ACRES' )

   oStruEV4 := FWFormStruct( 2, "EV4", {|x| CheckField(x, strtokarr2(DU100View("EV4"), "|")) }   )
   oStruEV4:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV4:SetProperty("EV4_MOE"  , MVC_VIEW_LOOKUP , "SYF" )

   oView:AddGrid( 'VIEW_EV4', oStruEV4, 'EV4DETAIL' )
   oView:SetOwnerView( 'VIEW_EV4', 'VIEW_DEDU' )

return nil

/*
Função     : setViewEVE
Objetivo   : Define o view para LPCO's (EVE)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEVE(oView)
   local oStruEVE   := nil

   oStruEVE := FWFormStruct( 2, "EVE", {|x| CheckField(x, strtokarr2(DU100View("EVE"), "|")) }   )
   oStruEVE:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oView:CreateHorizontalBox( 'VIEW_LPCO', 100,,,'FOLDER_ITEM', "LPCO")
   oView:AddGrid( 'VIEW_EVE', oStruEVE, 'EVEDETAIL' )
   oView:SetOwnerView( 'VIEW_EVE', 'VIEW_LPCO' )

return nil

/*
Função     : setViewEVI
Objetivo   : Define o view para Certificado Mercosul (EVI)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEVI(oView)
   local oStruEVI   := nil

   oStruEVI := FWFormStruct( 2, "EVI", {|x| CheckField(x, strtokarr2(DU100View("EVI"), "|")) }   )
   oStruEVI:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEVI:SetProperty( "EVI_IDCERT", MVC_VIEW_ORDEM, "01")
   oStruEVI:SetProperty( "EVI_DEMERC", MVC_VIEW_ORDEM, "02")
   oStruEVI:SetProperty( "EVI_QTDCER", MVC_VIEW_ORDEM, "03")

   oView:CreateHorizontalBox( 'VIEW_CERT_MERC', 100,,,'FOLDER_ITEM', "CERT_MERC")
   oView:AddGrid( 'VIEW_EVI', oStruEVI, 'EVIDETAIL' )
   oView:SetOwnerView( 'VIEW_EVI', 'VIEW_CERT_MERC' )

return nil

/*
Função     : setViewEV6
Objetivo   : Define o view para Documentos Vinculados (EV6)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEV6(oView)
   local oStruEV6   := nil

   oStruEV6 := FWFormStruct( 2, "EV6", {|x| CheckField(x, strtokarr2(DU100View("EV6"), "|")) }   )
   oStruEV6:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oView:CreateHorizontalBox( 'VIEW_DOC_VINC', 100,,,'FOLDER_ITEM', "DOC_VINCUL")
   oView:AddGrid( 'VIEW_EV6', oStruEV6, 'EV6DETAIL' )
   oView:SetOwnerView( 'VIEW_EV6', 'VIEW_DOC_VINC' )

return nil

/*
Função     : DU100Model
Objetivo   : Função que retorna string de campos a serem utilizados pelo modeldef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function DU100Model(cAlias, lCpoImpos)
   Local cRet := ""

   default lCpoImpos := .T.

   Do CASE
      CASE cAlias == 'EV1'
         cRet := "|EV1_FILIAL|EV1_HAWB|EV1_LOTE|EV1_SEQUEN|EV1_DATGER|EV1_HORGER|EV1_USRGER|EV1_IMPNOM|EV1_IMPNRO|EV1_COIDM|EV1_URFDES|EV1_SEGMOE|EV1_SETOMO|EV1_TIPREG|EV1_INFCOM|EV1_LOGINT|EV1_STATUS|EV1_DI_NUM|EV1_VERSAO|EV1_PAISPR"
      CASE cAlias == 'EVB'         
         cRet := "|EVB_FILIAL|EVB_HAWB|EVB_LOTE|EVB_CODPV|EVB_DESPV|"
      CASE cAlias == 'EV9'
         cRet := "|EV9_FILIAL|EV9_HAWB|EV9_LOTE|EV9_CODIN|EV9_SEQUEN|EV9_DOCTO|"
      CASE cAlias == 'SWV'   
         cRet := "|WV_HAWB|WV_SEQDUIM|WV_ID|WV_INVOICE|WV_FORN|WV_NOMEFOR|WV_FORLOJ|WV_PO_NUM|WV_POSICAO|WV_COD_I|WV_DESC_DI|WV_NCM|WV_SEQUENC|WV_QTDE|WV_LOTE|WV_DT_VALI|WV_DFABRI|WV_OBS|WV_PGI_NUM|"
         If AvFlags("FUNDAMENTO_LEGAL_ITEM")
            cRet += "WV_ATRIBUT|"
         EndIf
         if AvFlags("DRAWBACK_DUIMP")
            cRet += "WV_MODAL|WV_AC|WV_SEQSIS|"
         EndIf
         If SWV->(columnPos("WV_ATT_FL")) > 0
            cRet += "WV_ATT_FL|"
         EndIf
      CASE cAlias == 'EV2_MERCADORIA'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_IDPTCP|EV2_VRSACP|EV2_CNPJRZ|EV2_VINCCO|EV2_APLME|EV2_MATUSA|EV2_DSCCIT|EV2_IMPCO|EV2_NMCOM|EV2_QTCOM|EV2_QT_EST|EV2_PESOL|EV2_MOE1|EV2_VLMLE|EV2_FABFOR|EV2_TINFA|EV2_VRSFAB|EV2_PAIOME|EV2_TINFO|EV2_VRSFOR|EV2_PAISPR|EV2_METVAL|EV2_INCOTE|EV2_TIPCOB|EV2_NRROF|EV2_INSTFI|EV2_MOTIVO|EV2_VL_FIN|EV2_CNPJAD|"
         if DUIMP2310() .and. lCpoImpos
            cRet += "EV2_VLRCII|EV2_VLDII|EV2_VRDII|EV2_VLSII|EV2_VRCII|EV2_VLCIPI|EV2_VDIPI|EV2_VRDIPI|EV2_VLSIPI|EV2_VRCIPI|EV2_VLCPIS|EV2_VRDPIS|EV2_VDEPIS|EV2_VLSPIS|EV2_VRCPIS|EV2_VLCCOF|EV2_VRDCOF|EV2_VDECOF|EV2_VLSCOF|EV2_VRCCOF|EV2_OBSTRB|"
         endif
         If AvFlags("TRIBUTACAO_DUIMP") .and. lCpoImpos
            cRet += "EV2_VLC_DU|EV2_VLD_DU|EV2_VLR_DU|"
         EndIf
         If AvFlags("FUNDAMENTO_LEGAL_ITEM")
            cRet += "EV2_ATRIBU|"
         EndIf
         If EV2->(columnPos("EV2_ATT_FL")) > 0
            cRet += "EV2_ATT_FL|"
         EndIf
      CASE cAlias == 'EV2_FABR_FORN'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_FABFOR|EV2_TINFA|EV2_VRSFAB|EV2_PAIOME|EV2_TINFO|EV2_VRSFOR|EV2_PAISPR|"
      CASE cAlias == 'EV2_COND_VENDA'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_METVAL|EV2_INCOTE|EV2_TIPCOB|EV2_NRROF|EV2_INSTFI|EV2_MOTIVO|EV2_VL_FIN|"
      CASE cAlias == 'EV2_TRIBUTOS_II'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLRCII|EV2_VLDII|EV2_VRDII|EV2_VLSII|EV2_VRCII|"
      CASE cAlias == 'EV2_TRIBUTOS_IPI'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCIPI|EV2_VDIPI|EV2_VRDIPI|EV2_VLSIPI|EV2_VRCIPI|"
      CASE cAlias == 'EV2_TRIBUTOS_PISCOFINS'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCPIS|EV2_VRDPIS|EV2_VDEPIS|EV2_VLSPIS|EV2_VRCPIS|EV2_VLCCOF|EV2_VRDCOF|EV2_VDECOF|EV2_VLSCOF|EV2_VRCCOF|"
      CASE cAlias == 'EV2_TRIBUTOS_PIS'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCPIS|EV2_VRDPIS|EV2_VDEPIS|EV2_VLSPIS|EV2_VRCPIS|"
      CASE cAlias == 'EV2_TRIBUTOS_COFINS'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCCOF|EV2_VRDCOF|EV2_VDECOF|EV2_VLSCOF|EV2_VRCCOF|"
      CASE cAlias == "EV2_TRIBUTOS_ANTIDUMPING"
         cRet += "EV2_VLC_DU|EV2_VLD_DU|EV2_VLR_DU|"
      CASE cAlias == 'EV2_TRIBUTACAO'
         cRet := "|EV2_OBSTRB|"
      CASE cAlias == 'EV3'
         cRet := "|EV3_FILIAL|EV3_HAWB|EV3_LOTE|EV3_SEQDUI|EV3_MOE|EV3_VLMLE|EV3_ACRES|"
      CASE cAlias == 'EV4'
         cRet := "|EV4_FILIAL|EV4_HAWB|EV4_LOTE|EV4_SEQDUI|EV4_MOE|EV4_VLMLE|EV4_DEDU|"
      CASE cAlias == 'EVE'
         cRet := "|EVE_FILIAL|EVE_LOTE|EVE_SEQDUI|EVE_LPCO|"
      CASE cAlias == 'EVI'
         cRet := "|EVI_FILIAL|EVI_HAWB|EVI_LOTE|EVI_SEQDUI|EVI_NUM|EVI_IDCERT|EVI_DEMERC|EVI_QTDCER|"
      CASE cAlias == 'EV6'
         cRet := "|EV6_FILIAL|EV6_HAWB|EV6_LOTE|EV6_SEQDUI|EV6_TIPVIN|EV6_DOCVIN|"
      CASE cAlias == 'EVG'
         cRet := "|EVG_FILIAL|EVG_HAWB|EVG_LOTE|EVG_SEQDUI|EVG_IDIMP|EVG_FUNDLE|EVG_DESCFL|EVG_REGIME|EVG_DESCRE|EVG_ADICAO|EVG_TPIMP|"
         If AvFlags("FUNDAMENTO_LEGAL_ITEM")
            cRet += "EVG_TIPOFL|EVG_ATRIBU|"
         EndIf
      CASE cAlias == 'EVGGRID'
         cRet := "|EVG_FUNDLE|EVG_DESCFL|EVG_REGIME|EVG_DESCRE|"
         If AvFlags("FUNDAMENTO_LEGAL_ITEM")
            cRet += "EVG_TIPOFL|"
         EndIf
   END CASE

Return  cRet

/*
Função     : DU100View
Objetivo   : Função que retorna string de campos a serem utilizados pelo viewdef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function DU100View(cAlias)
   Local cRet := ""
   Do CASE
      CASE cAlias == 'EV1'
         cRet := "|EV1_LOGINT|"
      CASE cAlias == 'EVB'         
         cRet := "|EVB_DESPV|EVB_CODPV|"
      CASE cAlias == 'EV9'
         cRet := "|EV9_CODIN|EV9_DOCTO|"
      CASE cAlias == 'SWV'   
         cRet := "|WV_SEQDUIM|WV_INVOICE|WV_FORN|WV_NOMEFOR|WV_FORLOJ|WV_PO_NUM|WV_POSICAO|WV_COD_I|WV_DESC_DI|WV_NCM|WV_SEQUENC|WV_QTDE|WV_LOTE|WV_DT_VALI|WV_DFABRI|WV_OBS|"
         if AvFlags("DRAWBACK_DUIMP")
            cRet += "WV_MODAL|WV_AC|WV_SEQSIS|"
         EndIf
      CASE cAlias == 'EV3'
         cRet := "|EV3_MOE|EV3_VLMLE|EV3_ACRES"
      CASE cAlias == 'EV4'
         cRet := "|EV4_MOE|EV4_VLMLE|EV4_DEDU"
      CASE cAlias == 'EVE'
         cRet := "|EVE_LPCO|"
      CASE cAlias == 'EVI'
         cRet := "|EVI_IDCERT|EVI_DEMERC|EVI_QTDCER|"
      CASE cAlias == 'EV6'
         cRet := "|EV6_TIPVIN|EV6_DOCVIN|"
   END CASE

Return  cRet

/*
Função     : CheckField
Objetivo   : Função para avaliar os campos para serem apresentados
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function CheckField(cField, aFields, lUser)
   Local lRet := .F.
   Default lUser := .T.
   lRet := (ValType(aFields[1]) == "A" .And. aScan(aFields, {|x| AllTrim(x[1]) == AllTrim(cField) }) > 0) .Or. (ValType(aFields[1]) == "C" .And.  aScan(aFields, AllTrim(cField)) > 0) .Or. (lUser .and. GetSx3Cache(cField, "X3_PROPRI") == "U")
Return lRet

Function DU100EV1LO(cCampo) 
   Local xValue

   Do Case
      Case cCampo == 'EV1_LOTE' 
         if empty(_cNumLote)
            xValue := NextSeq(cCampo) //Função em desenvolvimento
         else
            xValue := _cNumLote
         endif
         _cNumLote := ""
   EndCase

Return xValue

/*---------------------------------------------------------------------*
 | Func:  NextSeq                                                    |
 | Autor: Maurício Frison                                              |
 | Data:  08/03/2022                                                   |
 | Desc:  Buscar próxima sequência dos campos sequenciais do modelo    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function NextSeq(cCampo) 
Local cLastSeq 
Local oMdl     := FWModelActive()
Local oMdlEV1Master := oMdl:GetModel():GetModel("EV1MASTER")

Do CASE 
   Case cCampo='EV1_LOTE'
      cLastSeq := EasyGetMVSeq('CTRL_EV0')
   Case cCAmpo='EV1_SEQUEN'     
      cLastSeq := GetSql( oMdlEV1Master:GetValue("EV1_HAWB") )     
      cLastSeq := Soma1(cLastSeq)   
   EndCase
Return cLastSeq

/*---------------------------------------------------------------------*
 | Func:  GetSql                                                       |
 | Autor: Maurício Frison                                              |
 | Data:  10/03/2022                                                   |
 | Desc:  Executar o sql para buscar a próxima sequência               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetSql(cHawb)
Local cQryTab   := ""
Local cLastSeq  := '000'
Local nOldArea, cAliasQry
Local cAlias    := "EV1"
local cQryMax   := ""
local cQryWhere := ""

default cHawb := ""

   cQryMax   := "% MAX(EV1_SEQUEN) LASTSEQ %"
   cQryWhere := "% EV1_FILIAL = '"+xFilial("EV1")+"' AND EV1_HAWB = '" + cHawb + "' %"
   cQryTab := "% "+RetSQLName(cAlias)+" %"
   nOldArea = Select()
   cAliasQry := GetNextAlias()
   BeginSQL Alias cAliasQry
      SELECT %Exp:cQryMax% 
      FROM %Exp:cQryTab%
      WHERE %Exp:cQryWhere% 
      AND %notDel%
   EndSql
   If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
      cLastSeq := (cAliasQry)->LASTSEQ
   EndIf
   (cAliasQry)->(DBCloseArea())
   If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 

Return cLastSeq

/*
Função     : DU100Gatil
Objetivo   : Funcao para utilização de gatilhos
Retorno    : conteúdo a ser gatilhado
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100Gatil(cCampo, cProcesso, aRetorno)
   Local oMdl      := nil
   Local cRet      := "" 
   local oModelEV1 := nil

   default cProcesso := ""
   default aRetorno  := {}

   if empty(cProcesso)
      oMdl = FWModelActive()
   endif

   if !empty(cProcesso) .or. ValType(oModelEV1 := oMdl:GetModel("EV1MASTER")) == "O"

      Do Case
         Case cCampo == "EV1_TIPREG"
              cRet  := LP500GetInfo("SW6",1,xFilial("SW6") + if(!empty(cProcesso), cProcesso, oModelEV1:GetValue("EV1_HAWB")),"W6_TIPOREG")
         Case cCampo == "EV1_SEQUEN"
              cRet := NextSeq(cCampo)
         Case cCampo == "EV1_IMPNOM"  
              cRet := LP500GetInfo("SYT",1,xFilial("SYT")+SW6->W6_IMPORT,"YT_NOME")
         Case cCampo == "EV1_IMPNRO"    
              cRet := SYT->YT_CGC //Entendo qeu já etá posicionado pela execução do gatilho acima
         Case cCampo == "EV1_INFCOM"   
              cRet := MSMM(SW6->W6_COMPLEM,AVSX3("W6_VM_COMP",03))
         Case cCampo == "EV1_COIDM"  
              cRet := SW6->W6_PRCARGA
         Case cCampo == "EV1_URFDES"   
              cRet := SW6->W6_URF_DES
         Case cCampo == "EV1_SEGMOE"
              cRet := getMoeda(SW6->W6_SEGMOED) // Posicione("SYF",1,xFilial("SYF")+SW6->W6_SEGMOED,"YF_COD_GI")    
         Case cCampo == "EV1_SETOMO"
              cRet := transform(SW6->W6_VL_USSE,GetSX3Cache("W6_VL_USSE","X3_PICTURE")) 
         Case cCampo == "EVB_DETAIL"   
              cRet := if(!empty(cProcesso), cProcesso, oModelEV1:GetValue("EV1_HAWB"))
              Processa({|| aRetorno := GetInfDet(oMdl, "EVBDETAIL", "VIEW_EVB", cRet) }, STR0081 + "...") // "Carregando Processos Vinculados"
         Case cCampo == "EV9_DETAIL"
              cRet := if(!empty(cProcesso), cProcesso, oModelEV1:GetValue("EV1_HAWB"))
              Processa({|| aRetorno := GetInfDet(oMdl, "EV9DETAIL", "VIEW_EV9", cRet) }, STR0082 + "...") // "Carregando Documentos de Instrução"
         Case cCampo == "SWV_DETAIL"
              clearField()
              cRet := if(!empty(cProcesso), cProcesso, oModelEV1:GetValue("EV1_HAWB"))
              Processa({|| aRetorno := GetInfDet(oMdl, "SWVDETAIL", "VIEW_SWV", cRet) }, STR0083 + "...") // "Carregando Informações dos Itens da DUIMP"
              if canUseApp()
                  cActiveID := oMdl:GetModel("SWVDETAIL"):GetValue("WV_ID")
                  sendAttPOUI(oJsonPOUI)
              endif
         Case cCampo == "EVG_REGIME" //Busca a descrição do regime na tabela SJP
               //JP_FILIAL+JP_CODIGO
               cRet := Posicione("SJP", 1, xFilial("SJP") + M->EVG_REGIME, "JP_DESC")
         Case cCampo == "EVG_FUNDLE" //Busca a descrição do fundamento legal na tabela EKU
               //EKU_FILIAL+EKU_FDTLGL                                                                                                                                           
               cRet := Posicione("EKU", 1, xFilial("EKU") + M->EVG_FUNDLE, "EKU_FDTDES")
         Case cCampo == "EV1_PAISPR"
              cRet:= LP500GetInfo("SW6",1,xFilial("SW6") + if(!empty(cProcesso), cProcesso, oModelEV1:GetValue("EV1_HAWB")),"W6_PAISPRO")
              cRet:= Posicione("SYA", 1, xFilial("SYA") + cRet, "YA_PAISDUE")
      EndCase

   EndIf

Return cRet

/*
Função     : DU100WHEN
Objetivo   : Função para saber se campo pode ou nao ser habilitado para edição na tela
Parâmetro  :
Retorno    : .T. ou .F.
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100WHEN(cCampo)
   Local aArea          := GetArea()
   Local oModel         := FWModelActive()
   Local lRet := .T.

   Do CASE
      Case cCampo == 'EV1_HAWB'
         lRet := oModel:getOperation() == 3
      EndCase
   RestArea(aArea)
Return lRet

 /*
Função     : DU100VALID
Objetivo   : Função de validação
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100VALID(cCampo,oMdl,xNewVl,xOldVl)
   Local aArea     := GetArea()
   Local oModel    := FWModelActive()
   Local lRet      := .T.
   Local cHawb     := ""
   Local oModelEV1 := nil
   Local lVerSeq   := .T.
   Local jItens    := nil

   If ValType(oModel) == 'O'
      oModelEV1 := oModel:GetModel("EV1MASTER")
      Do Case
         Case cCampo == 'EV1_HAWB'
            if !empty( cHawb := oModelEV1:GetValue("EV1_HAWB"))

               aAreaSW6 := SW6->(getArea())
               SW6->(dbSetOrder(1))

               lRet := SW6->(dbSeek( xFilial("SW6") + cHawb ))
               if !lRet 
                  lRet := .F.
                  EasyHelp(STR0020, STR0014, STR0021) // "Embarque não encontrado." ### "Atenção" ### "Informe um Embarque correto."
               elseif SW6->W6_TIPOREG != DUIMP .OR. SW6->W6_FORMREG != DUIMP_INTEGRADA
                  lRet := .F.
                  EasyHelp(STR0013, STR0014, STR0015) // "Embarque inválido." ### "Atenção" ### "Somente será permitido Embarque do tipo 'DUIMP' e com a forma de registro 'Integrado'."
               endif

               if lRet
                  lRet := DU100VdPrc( oModel, oModelEV1, cHawb )
               endif

               If lRet //aqui
                  Do while lVerSeq
                     If DI154SeqVazia()
                        If MsgYesNo(STR0052,STR0051) //A sequência de registro da DUIMP não foi informada para todos os itens do processo. Deseja revisar a sequência dos itens?
                           Processa( { || LP500VINC() } , STR0084 + "...") // "Carregando itens DUIMP"
                        Else
                           EasyHelp(STR0054,STR0051,STR0053)  // ""Sequência do itens da DUIMP inválido" É necessário informar o campo sequência DUIMP de todos os itens para gerar o registro para a integração"                                                                                                                                                                                                                                                                                                                                                                                                                          
                           lVerSeq :=.F.
                           lRet := .F.
                        EndIf   
                     else
                        lVerSeq:=.F.   
                     EndIf   
                  EndDo   
               EndIf   

               //Verifica os Catalos de Produtos amarrado aos itens da DUIMP
               If lRet
                  jItens := DU100NewVs(cHawb, .T.)
                  If Len(jItens['Itens']) > 0 .And.  MsgYesNo(STR0115 + ENTER+ENTER + STR0116, STR0028)//""###"Atenção"###"Existem catálogos de produtos registrados com versões mais recentes disponíveis." + ### "Deseja realizar uma atualização automática antes de continuar com a integração?"
                     If !DU100UpdCat(cHawb, jItens, .T.)
                        EasyHelp(STR0117, STR0028, STR0118)//"Não foi possível atualizar a versão do Catálogo de Produtos."###"Atenção"###"Verifique o catálogo de produtos informado no itens da DUIMP."
                        lRet := .F.
                     EndIf
                  EndIf
               EndIf               
				
				// Verificação nos itens da DUIMP para caso haja algum catálogo com status de bloqueado
               If lRet
                  If !DU100VdBloq(cHawb)
                     EasyHelp(STR0119, STR0028, STR0120)//'Não é possível prosseguir, pois existem catálogos de produtos bloqueados vinculados aos itens da DUIMP.'###"Atenção"###"Revise os catálogos e versões vinculados aos itens da DUIMP."
                     lRet := .F.
                  EndIf
               EndIf

               If lRet
                  If !DU100VdRet(cHawb)
                     If !MsgYesNo(STR0123 + CRLF + CRLF + STR0124, STR0003) //"Foram encontrados catálogos de produtos com status 3 - Pendente de Retificação."###"Deseja prosseguir com os dados atuais?"
                        lRet := .F.
                     EndIf
                  EndIf
               EndIf

               If lRet
                  If !SoftLock("SW6")
                     EasyHelp(STR0029,STR0028) //"Registro em uso por outro usuário!" # "Atenção"
                     lRet:=.f.
                  EndIf
               EndIF

               restArea(aAreaSW6)
            endif
      EndCase
   EndIf

   RestArea(aArea)

Return lRet

/*
Função     : DU100VdPrc
Objetivo   : Função para validação do processo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function DU100VdPrc( oModelo, oModelEV1, cHawb )
   local lRet       := .T.
   local nOperation := 0
   local aAreaEV1   := {}

   default oModelo   := FWModelActive()
   default oModelEV1 := oModelo:GetModel("EV1MASTER")
   default cHawb     := ""

   nOperation := oModelo:GetOperation()
   if nOperation == MODEL_OPERATION_INSERT .and. !empty(cHawb)

      dbSelectArea("EV1")
      aAreaEV1 := EV1->(getArea())
      EV1->(dbSetOrder(1)) // EV1_FILIAL+EV1_HAWB+EV1_LOTE
      if EV1->(AvSeekLast( xFilial("EV1") + cHawb ))
         if EV1->EV1_STATUS == DUIMP_REGISTRADA
            lRet := .F.
            EasyHelp(STR0085, STR0014, STR0109) // "O status deste processo é 'Duimp Registrada'." ### "Atenção" ### "Não é possível prosseguir com a ação de inclusão do registro. Favor informar um processo válido."
         elseif EV1->EV1_STATUS == EM_PROCESSAMENTO
            lRet := MsgYesNo(STR0125 + ENTER + ; //"O status deste processo é 'Registro em Processamento'. "
            STR0126 +ENTER + ENTER +; //"Ao prosseguir com a inclusão de um novo registro, a versão atual será excluída e uma nova versão da Duimp será gerada no portal único."
            STR0127, STR0014) //"Deseja prosseguir?"####"Atenção"
            //EasyHelp(STR0107, STR0014, STR0108) // "O status deste processo é 'Registro em Processamento'. Não é possível prosseguir com a ação de inclusão do registro." ### "Atenção" ### "Será necessário realizar a ação 'Consultar Status' ou informar um outro processo válido."
            If lRet //Se clicou em prosseguir, deve ser excluida a versao atual do portal unico
               lRet := DU101PrcInt("EV1", EV1->(recno()), 99, EV1->EV1_HAWB, EV1->EV1_LOTE)
               If !lRet
                  EasyHelp(STR0131 + CRLF + STR0132, STR0014, "") // "Não foi possível realizar a exclusão da Duimp no Portal Único." #### "Para mais informações, consulte o log de integração" ### "Atenção"
               EndIf
            EndIf
         else
            lRet := EV1->EV1_STATUS == OBSOLETO .or. FwIsInCallStack("DU100ExAuto") .or. MsgYesNo(STR0086, STR0014 ) // "Ao incluir um novo registro para integração, a sequência atual ficará obsoleta. Deseja prosseguir com a operação?" ### "Atenção"
            if lRet
               if !(EV1->EV1_STATUS == OBSOLETO)
                  _nRecEV1 := EV1->(recno())
               endif
               oModelEV1:loadValue("EV1_DI_NUM", EV1->EV1_DI_NUM )
               oModelEV1:loadValue("EV1_VERSAO", EV1->EV1_VERSAO )
            else
               EasyHelp(STR0087, STR0014, "") // "Operação cancelada." ### "Atenção"
            endif
         endif

      endif

      restArea(aAreaEV1)

   endif

return lRet

/*
Função     : DU100VdCan
Objetivo   : Função para tratar o cancelamento da inclusão ou alteração
Parâmetro  :
Retorno    : sem retorno
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function DU100VdCan(oModel)
   FWFormCancel(oModel)
   RollbackSx8()
Return .T.

/*
Função     : DU100Commit
Objetivo   : Função para gravação do modelo
Parâmetro  :
Retorno    : sem retorno
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function DU100Commit(oModel)
   local nOperation := oModel:GetOperation()
   local cTabela    := ""

   if nOperation == MODEL_OPERATION_INSERT
      FWFormCommit(oModel)
      DU100AtuEV( _nRecEV1 , OBSOLETO )
   endif

   if nOperation == MODEL_OPERATION_DELETE

      if empty(EV1->EV1_DI_NUM) .and. empty(EV1->EV1_VERSAO)

         begin transaction

            EV9->(IndexKey(1)) // EV9_FILIAL+EV9_HAWB+EV9_LOTE+EV9_CODIN
            if EV9->(dbSeek( xFilial("EV9") + EV1->EV1_HAWB + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EV9")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV9_FILIAL = '" + xFilial("EV9") + "' AND EV9_HAWB = '" + EV1->EV1_HAWB + "' AND EV9_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVB->(IndexKey(1)) // EVB_FILIAL+EVB_HAWB+EVB_LOTE
            if EVB->(dbSeek( xFilial("EVB") + EV1->EV1_HAWB + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EVB")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVB_FILIAL = '" + xFilial("EVB") + "' AND EVB_HAWB = '" + EV1->EV1_HAWB + "' AND EVB_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV2->(dbSetOrder(3)) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
            if EV2->(dbSeek( xFilial("EV2") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV2")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV2_FILIAL = '" + xFilial("EV2") + "' AND EV2_HAWB = '" + EV1->EV1_HAWB + "' AND EV2_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV3->(dbSetOrder(3)) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI
            if EV3->(dbSeek( xFilial("EV3") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV3")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV3_FILIAL = '" + xFilial("EV3") + "' AND EV3_HAWB = '" + EV1->EV1_HAWB + "' AND EV3_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV4->(dbSetOrder(3)) // EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI
            if EV4->(dbSeek( xFilial("EV4") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV4")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV4_FILIAL = '" + xFilial("EV4") + "' AND EV4_HAWB = '" + EV1->EV1_HAWB + "' AND EV4_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVE->(dbSetOrder(2)) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI
            if EVE->(dbSeek( xFilial("EVE") + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EVE")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVE_FILIAL = '" + xFilial("EVE") + "' AND EVE_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVI->(dbSetOrder(2)) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI
            if EVI->(dbSeek( xFilial("EVI") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EVI")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVI_FILIAL = '" + xFilial("EVI") + "' AND EVI_HAWB = '" + EV1->EV1_HAWB + "' AND EVI_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV6->(dbSetOrder(3)) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI
            if EV6->(dbSeek( xFilial("EV6") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV6")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV6_FILIAL = '" + xFilial("EV6") + "' AND EV6_HAWB = '" + EV1->EV1_HAWB + "' AND EV6_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVG->(dbSetOrder(1)) // EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_ADICAO+EVG_TPIMP
            if EVG->(dbSeek( xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE))
               cTabela := RetSQLName("EVG")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVG_FILIAL = '" + xFilial("EVG") + "' AND EVG_HAWB = '" + EV1->EV1_HAWB + "' AND EVG_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            cTabela := RetSQLName("EV1")
            ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV1_FILIAL = '" + xFilial("EV1") + "' AND EV1_HAWB = '" + EV1->EV1_HAWB + "' AND EV1_LOTE = '" + EV1->EV1_LOTE + "'")
            
         end transaction

      endif

   endif
   _nRecEV1 := 0

return .T.

/*
Função     : ExecSql
Objetivo   : Função para realizar um comando direto no banco de dados
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function ExecSql(cTabela, cSqlExec)
   local nExec := 0

   default cTabela   := ""
   default cSqlExec  := ""

   if !empty(cTabela) .and. !empty(cSqlExec)
      nExec := TCSqlExec(cSqlExec)
      TCRefresh( cTabela )
   endif

return nExec

/*
Função     : DU100PVldModel
Objetivo   : Função para validação do commit do modelo (TUDOOK)
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function DU100PVldModel(oModelo)
   local aArea      := getArea()
   local lRet       := .F.
   local nOpc       := 0
   local oModelEV1  := nil
   local cSequencia := ""
   local cLastSeq   := ""
   local cMsg       := ""

   begin sequence

      nOpc := oModelo:GetOperation()
      if nOpc == MODEL_OPERATION_DELETE // avaliar se tambem será validado na opção de alteração (reenviar)

         oModelEV1 := oModelo:GetModel("EV1MASTER")
         cSequencia := oModelEV1:getValue("EV1_SEQUEN")
         cLastSeq := GetSql(oModelEV1:getValue("EV1_HAWB"))
         if !cSequencia == cLastSeq
            cMsg := if( nOpc == MODEL_OPERATION_DELETE , StrTran( STR0017, "###", STR0019 )  , StrTran( STR0017, "###", STR0018 ) ) // "Só será permitido ### da última sequência do Embarque." ### "alteração" ### "exclusão"
            EasyHelp(STR0016, STR0014, cMsg ) // "Registro inválido." ### "Atenção" ### 
            break
         endif

      endif

      lRet := .T.

   end sequence

   restArea(aArea)

return lRet

/*
Função     : GetInfDet
Objetivo   : Busca informação de tabela para preenchimento de grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function GetInfDet(oModelo, cIdModel, cIdView, cHawb, oModelSWV, oModelEV3, oModelEV4, oModelEVE, oModelEVI, oModelEV6, oModEVGII, oModEVGIPI, oModEVGPIS, oModEVGCOF, oModEVGDUM)
   local aArea      := {}
   local oModelDet  := nil
   local aConfig    := {}
   local aAreaSW6   := {}
   local aAreaSWV   := {}   
   local aProformas := {}
   local nTamSeq    := 0
   local nTamCodIn  := 0
   local nTamDocTo  := 0
   local aCposLoad  := {}
   local cAliasQry  := ""
   local lAddLine   := .F.
   local aAreaEIG   := {}
   local aCfgEV3    := {}
   local aCfgEV4    := {}
   local aCfgEVE    := {}
   local aCfgEVI    := {}
   local aCfgEV6    := {}
   local oModelEV2MC:= nil
   local oGrdEV2MC  := nil
   local aCpoEV2MC  := {}
   local oModelEV2FF:= nil
   local oGrdEV2FF  := nil
   local aCpoEV2FF  := {}
   local oModelEV2CV:= nil
   local oGrdEV2CV  := nil
   local aCpoEV2CV  := {}   
   local oModelEV1  := nil
   local oMdlEV2II  := nil 
   local oGrdEV2II  := nil
   local aCpoEV2II  := {}
   local oMdlEV2IPI := nil
   local oGrdEV2IPI := nil
   local aCpoEV2IPI := {}
   local oMdlEV2PCO := nil
   local oGrdEV2PCO := nil
   local aCpoEV2PCO := {}
   local oMdlEV2PIS := nil
   local oGrdEV2PIS := nil
   local aCpoEV2PIS := {}
   local oMdlEV2COF := nil
   local oGrdEV2COF := nil
   local aCpoEV2COF := {}
   local oMdlEV2DUM := nil
   local oGrdEV2DUM := nil
   local aCpoEV2DUM := {}
   local oMdlEV2TRB := nil
   local oGrdEV2TRB := nil
   local aCpoEV2TRB := {}
   local oMdlEVGII  := nil
   //local oGrdEVGII  := nil
   //local aCpoEVGII  := {}
   local oMdlEVGIPI := nil
   //local oGrdEVGIPI := nil
   //local aCpoEVGIPI := {}
   local oMdlEVGPIS := nil
   //local oGrdEVGPIS := nil
   //local aCpoEVGPIS := {}
   local oMdlEVGCOF := nil
   //local oGrdEVGCOF := nil
   //local aCpoEVGCOF := {}
   local oMdlEVGDUM := nil
   //local oGrdEVGDUM := nil
   //local aCpoEVGDUM := {}
   local aCfgEVGII  := {}
   local aCfgEVGIPI := {}
   local aCfgEVGPIS := {}
   local aCfgEVGCOF := {}
   local aCfgEVGDUM := {}
   local lModel     := .F.
   local aRet       := {}
   local aRetorno   := {}
   local cQuery     := ""
   local oQuery     := nil
   local lPaisMerc  := .F.
   local cPaisOrg   := ""
   Local aDadosPoui := {}
   Local aDadosLPCO := {}
   Local aDadosCP   := {}
   Local oCamposPoui:= jsonObject():New()
   Local jsonCP
   Local jsonLPCO
   Local lTemLpco := .F.
   Local lTemCP   := .F.
   local oObjetivo

   default cIdModel   := ""
   default cIdView    := ""
   default cHawb      := ""
   
   lModel := !valtype(oModelo) == "U"

   if !lModel .or. !empty(cIdModel)

      if lModel
         oModelDet := oModelo:GetModel(cIdModel)

         if cIdModel == "EVBDETAIL" .or. cIdModel == "EV9DETAIL" .or. cIdModel == "SWVDETAIL"
            aArea := getArea()
            aConfig := gUpdDelIns(oModelDet)
         endif
      endif

      if !empty(cHawb)

         if lModel .and. oModelo:getOperation() == MODEL_OPERATION_INSERT
            oModelDet:DelAllline()
            oModelDet:ClearData(.F., .T.)
         endif

         do case
            case cIdModel == "EVBDETAIL"

               aAreaEIG := EIG->(getArea())
               EIG->(dbSetOrder(1))
               aRet := {}
               if EIG->(dbSeek( xFilial("EIG") + cHawb))
                  lAddLine := .F.
                  Do While EIG->(!Eof()) .and. EIG->EIG_FILIAL == xFilial("EIG") .and. EIG->EIG_HAWB == cHawb
                     aCposLoad := {}
                     aAdd( aCposLoad, {"EVB_CODPV", EIG->EIG_CODIGO } )
                     aAdd( aCposLoad, {"EVB_DESPV", EIG->EIG_NUMERO } )
                     if lModel
                        AddLine(oModelDet, aCposLoad, lAddLine)
                        lAddLine := .T.
                     else
                        aAdd( aRet, aClone(aCposLoad) )
                     endif
                     EIG->(DbSkip())
                  EndDo
               endif

               if !lModel
                  aRetorno := {cIdModel, aRet}
               endif
               restArea(aAreaEIG)

            case cIdModel == "EV9DETAIL"

               aAreaSW6 := SW6->(getArea())
               SW6->(dbSeek( xFilial("SW6") + cHawb))

               aRet := {}
               nTamSeq := getSX3Cache("EV9_SEQUEN", "X3_TAMANHO")
               nTamCodIn := getSX3Cache("EV9_CODIN", "X3_TAMANHO")
               nTamDocTo := getSX3Cache("EV9_DOCTO", "X3_TAMANHO")

               /// ***********************************************
               // Carregando 30 - Conhecimento de Embarque
               if !empty(SW6->W6_HOUSE)
                  aCposLoad := {}
                  lAddLine := .F.
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(1, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("30", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR(SW6->W6_HOUSE, nTamDocTo)} )
                  if lModel
                     AddLine(oModelDet, aCposLoad, lAddLine)
                  else
                     aAdd( aRet, aClone(aCposLoad) )
                  endif
               endif
               /// ***********************************************

               /// ***********************************************
               // Carregando 49 - Fatura Comercial
               cAliasQry := getNextAlias()
               cQuery := " SELECT SW9.W9_INVOICE INVOICE "
               cQuery += " FROM " + RetSqlName("SW9") + " SW9 "
               cQuery += " WHERE SW9.D_E_L_E_T_ = ' ' "
               cQuery += " AND SW9.W9_FILIAL = ? "
               cQuery += " AND SW9.W9_HAWB = ? "
               cQuery += " GROUP BY SW9.W9_INVOICE "

               oQuery := FWPreparedStatement():New(cQuery)
               oQuery:SetString( 1 , xFilial("SW9") )
               oQuery:SetString( 2 , cHawb )
               cQuery := oQuery:GetFixQuery()

               MPSysOpenQuery(cQuery, cAliasQry)
            
               fwFreeObj(oQuery)

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE)
               nSeq := 1
               while (cAliasQry)->(!eof())
                  aCposLoad := {}
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("49", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR((cAliasQry)->INVOICE, nTamDocTo)} )
                  if lModel
                     AddLine(oModelDet, aCposLoad, lAddLine )
                  else
                     aAdd( aRet, aClone(aCposLoad) )
                  endif
                  lAddLine := .T.
                  nSeq += 1
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())
               /// ***********************************************

               /// ***********************************************
               // Carregando 50 - Fatura Proforma
               aProformas := {}
               nSeq := 1
               cAliasQry := getNextAlias()
               cQuery := " SELECT EW0.EW0_NR_PRO "
               cQuery += " FROM " + RetSqlName("SW7") + " SW7 "
               cQuery += " INNER JOIN " + RetSqlName("EW0") + " EW0 ON EW0.D_E_L_E_T_ = ' ' "
               cQuery += " AND EW0.EW0_FILIAL = '" + xFilial("EW0") + "' "
               cQuery += " AND EW0.EW0_PO_NUM = SW7.W7_PO_NUM "
               cQuery += " AND EW0.EW0_POSICA = SW7.W7_POSICAO "
               cQuery += " WHERE SW7.D_E_L_E_T_ = ' ' "
               cQuery += " AND SW7.W7_FILIAL = ? "
               cQuery += " AND SW7.W7_HAWB = ? "
               cQuery += " GROUP BY EW0.EW0_NR_PRO "

               oQuery := FWPreparedStatement():New(cQuery)
               oQuery:SetString( 1 , xFilial("SW7") )
               oQuery:SetString( 2 , cHawb )
               cQuery := oQuery:GetFixQuery()

               MPSysOpenQuery(cQuery, cAliasQry)
            
               fwFreeObj(oQuery)

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE) .or. lAddLine
               while (cAliasQry)->(!eof())
                  aAdd( aProformas, (cAliasQry)->EW0_NR_PRO )
                  aCposLoad := {}
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("50", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR((cAliasQry)->EW0_NR_PRO, nTamDocTo)} )
                  if lModel
                     AddLine(oModelDet, aCposLoad, lAddLine)
                  else
                     aAdd( aRet, aClone(aCposLoad) )
                  endif
                  lAddLine := .T.
                  nSeq += 1
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())

               cAliasQry := getNextAlias()
               cQuery := " SELECT SW2.W2_NR_PRO "
               cQuery += " FROM " + RetSqlName("SW7") + " SW7 "
               cQuery += " INNER JOIN " + RetSqlName("SW3") + " SW3 ON SW3.D_E_L_E_T_ = ' ' "
               cQuery += " AND SW3.W3_FILIAL = '" + xFilial("SW3") + "' "
               cQuery += " AND SW3.W3_PO_NUM = SW7.W7_PO_NUM "
               cQuery += " AND SW3.W3_POSICAO = SW7.W7_POSICAO "
               cQuery += " INNER JOIN " + RetSqlName("SW2") + " SW2 ON SW2.D_E_L_E_T_ = ' ' "
               cQuery += " AND SW2.W2_FILIAL = '" + xFilial("SW2") + "' "
               cQuery += " AND SW2.W2_PO_NUM = SW3.W3_PO_NUM "
               cQuery += " WHERE SW7.D_E_L_E_T_ = ' ' "
               cQuery += " AND SW7.W7_FILIAL = ? "
               cQuery += " AND SW7.W7_HAWB = ? "
               cQuery += " GROUP BY SW2.W2_NR_PRO "

               oQuery := FWPreparedStatement():New(cQuery)
               oQuery:SetString( 1 , xFilial("SW7") )
               oQuery:SetString( 2 , cHawb )
               cQuery := oQuery:GetFixQuery()

               MPSysOpenQuery(cQuery, cAliasQry)
            
               fwFreeObj(oQuery)

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE) .or. lAddLine
               while (cAliasQry)->(!eof())
                  if !empty((cAliasQry)->W2_NR_PRO) .and. aScan( aProformas, { |X| alltrim(X) == alltrim((cAliasQry)->W2_NR_PRO)} ) == 0
                     aCposLoad := {}
                     aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                     aAdd( aCposLoad, {"EV9_CODIN", PadR("50", nTamCodIn) } )
                     aAdd( aCposLoad, {"EV9_DOCTO", PadR( (cAliasQry)->W2_NR_PRO , nTamDocTo)} )
                     if lModel
                        AddLine(oModelDet, aCposLoad, lAddLine)
                     else
                        aAdd( aRet, aClone(aCposLoad) )
                     endif
                     lAddLine := .T.
                     nSeq += 1
                  endif
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())
               /// ***********************************************

               /// ***********************************************
               // Carregando 41 - Declaração de Exportação
               lPaisMerc := (!empty(SW6->W6_PAISPRO) .and. Posicione("SYA",1,xFilial("SYA") + SW6->W6_PAISPRO,"YA_MERCOSU") $ cSim ) .or. ;
                           (!empty(cPaisOrg := Posicione("SYR",1,xFilial("SYR")+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST,"YR_PAIS_OR")) .and. Posicione("SYA",1,xFilial("SYA") + cPaisOrg,"YA_MERCOSU") $ cSim ) 
               if lPaisMerc 
                  cAliasQry := getNextAlias()
                  cQuery := " SELECT EIF.EIF_DOCTO DOCTO "
                  cQuery += " FROM " + RetSqlName("EIF") + " EIF "
                  cQuery += " WHERE "
                  cQuery += " EIF.EIF_FILIAL = ? "
                  cQuery += " AND EIF.EIF_HAWB = ? "
                  cQuery += " AND EIF.EIF_CODIGO = ? "
                  cQuery += " AND EIF.D_E_L_E_T_ = ? "
                  cQuery += " GROUP BY EIF.EIF_DOCTO "

                  oQuery := FWPreparedStatement():New(cQuery)
                  oQuery:SetString( 1 , xFilial("EIF") )
                  oQuery:SetString( 2 , cHawb )
                  oQuery:SetString( 3 , "41" )
                  oQuery:SetString( 4 , ' ' )
                  cQuery := oQuery:GetFixQuery()

                  MPSysOpenQuery(cQuery, cAliasQry)
               
                  fwFreeObj(oQuery)

                  (cAliasQry)->(dbGoTop())
                  lAddLine := !empty(SW6->W6_HOUSE) .or. lAddLine
                  nSeq := 1
                  while (cAliasQry)->(!eof())
                     aCposLoad := {}
                     aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                     aAdd( aCposLoad, {"EV9_CODIN", PadR("41", nTamCodIn) } )
                     aAdd( aCposLoad, {"EV9_DOCTO", PadR((cAliasQry)->DOCTO, nTamDocTo)} )
                     if( lModel, AddLine(oModelDet, aCposLoad, lAddLine ), aAdd( aRet, aClone(aCposLoad) ))
                     lAddLine := .T.
                     nSeq += 1
                     (cAliasQry)->(dbSkip())
                  end
                  (cAliasQry)->(DBCloseArea())
               endif
               /// ***********************************************
               
               // Carregando Documentos da EIF (Documentos de instrução de depacho do desembaraço)
               setDocs(cHawb,lModel,@oModelDet,@lAddLine,@aRet,nTamSeq,nTamCodIn,nTamDocTo,'19') //Certificado de Origem
               setDocs(cHawb,lModel,@oModelDet,@lAddLine,@aRet,nTamSeq,nTamCodIn,nTamDocTo,'60') //Manifesto de Carga
               setDocs(cHawb,lModel,@oModelDet,@lAddLine,@aRet,nTamSeq,nTamCodIn,nTamDocTo,'73') //Packing List      
                              
               if !lModel
                  aRetorno := {cIdModel, aRet}
               endif

               restArea(aAreaSW6)

            case cIdModel == "SWVDETAIL"
               aAreaSWV := SWV->(getArea())
               aRet := {}

               SWV->(dbSetOrder(1))
               if SWV->(dbSeek( xFilial("SWV") + cHawb))

                  if lModel
                     oModelEV3 := oModelo:GetModel("EV3DETAIL")
                     aCfgEV3 := gUpdDelIns(oModelEV3)

                     oModelEV4 := oModelo:GetModel("EV4DETAIL")
                     aCfgEV4 := gUpdDelIns(oModelEV4)

                     oModelEVE := oModelo:GetModel("EVEDETAIL")
                     aCfgEVE := gUpdDelIns(oModelEVE)

                     oModelEVI := oModelo:GetModel("EVIDETAIL")
                     aCfgEVI := gUpdDelIns(oModelEVI)

                     oModelEV6 := oModelo:GetModel("EV6DETAIL")
                     aCfgEV6 := gUpdDelIns(oModelEV6)

                     If avFlags("TRIBUTACAO_DUIMP")
                        oMdlEVGII := oModelo:GetModel("EVGGRID_II")
                        aCfgEVGII := gUpdDelIns(oMdlEVGII)
                        
                        oMdlEVGIPI := oModelo:GetModel("EVGGRID_IPI")
                        aCfgEVGIPI := gUpdDelIns(oMdlEVGIPI)

                        oMdlEVGPIS := oModelo:GetModel("EVGGRID_PIS")
                        aCfgEVGPIS := gUpdDelIns(oMdlEVGPIS)

                        oMdlEVGCOF := oModelo:GetModel("EVGGRID_COFINS")
                        aCfgEVGCOF := gUpdDelIns(oMdlEVGCOF)

                        oMdlEVGDUM := oModelo:GetModel("EVGGRID_ANTIDUMPING")
                        aCfgEVGDUM := gUpdDelIns(oMdlEVGDUM)
                     EndIf

                     oModelEV2MC := oModelo:GetModel("EV2MSTR_MC") 
                     oGrdEV2MC := oModelEV2MC:getStruct()
                     aCpoEV2MC := oGrdEV2MC:GetFields()

                     oModelEV2FF := oModelo:GetModel("EV2MSTR_FF") 
                     oGrdEV2FF := oModelEV2FF:getStruct()
                     aCpoEV2FF := oGrdEV2FF:GetFields()

                     oModelEV2CV := oModelo:GetModel("EV2MSTR_CV") 
                     oGrdEV2CV := oModelEV2CV:getStruct()
                     aCpoEV2CV := oGrdEV2CV:GetFields()

                     if DUIMP2310()
                        oMdlEV2II := oModelo:GetModel("EV2MSTR_TRIB_II") 
                        oGrdEV2II := oMdlEV2II:getStruct()
                        aCpoEV2II := oGrdEV2II:GetFields()

                        oMdlEV2IPI := oModelo:GetModel("EV2MSTR_TRIB_IPI") 
                        oGrdEV2IPI := oMdlEV2IPI:getStruct()
                        aCpoEV2IPI := oGrdEV2IPI:GetFields()

                        If avFlags("TRIBUTACAO_DUIMP")
                           //II - EVG
                           //oMdlEVGII := oModelo:GetModel("EVGGRID_II")
                           //oGrdEVGII := oMdlEVGII:getStruct()
                           //aCpoEVGII := oGrdEVGII:GetFields()
                           //IPI - EVG
                           //oMdlEVGIPI := oModelo:GetModel("EVGGRID_IPI")
                           //oGrdEVGIPI := oMdlEVGIPI:getStruct()
                           //aCpoEVGIPI := oGrdEVGIPI:GetFields()
                           //PIS
                           oMdlEV2PIS := oModelo:GetModel("EV2MSTR_TRIB_PIS") 
                           oGrdEV2PIS := oMdlEV2PIS:getStruct()
                           aCpoEV2PIS := oGrdEV2PIS:GetFields()
                           //oMdlEVGPIS := oModelo:GetModel("EVGGRID_PIS")
                           //oGrdEVGPIS := oMdlEVGPIS:getStruct()
                           //aCpoEVGPIS := oGrdEVGPIS:GetFields()

                           //COFINS
                           oMdlEV2COF := oModelo:GetModel("EV2MSTR_TRIB_COFINS") 
                           oGrdEV2COF := oMdlEV2COF:getStruct()
                           aCpoEV2COF := oGrdEV2COF:GetFields()
                           //oMdlEVGCOF := oModelo:GetModel("EVGGRID_COFINS")
                           //oGrdEVGCOF := oMdlEVGCOF:getStruct()
                           //aCpoEVGCOF := oGrdEVGCOF:GetFields()
                           //ANTIDUMPING
                           oMdlEV2DUM := oModelo:GetModel("EV2MSTR_TRIB_ANTIDUMPING") 
                           oGrdEV2DUM := oMdlEV2DUM:getStruct()
                           aCpoEV2DUM := oGrdEV2DUM:GetFields()
                           //oMdlEVGDUM := oModelo:GetModel("EVGGRID_ANTIDUMPING")
                           //oGrdEVGDUM := oMdlEVGDUM:getStruct()
                           //aCpoEVGDUM := oGrdEVGDUM:GetFields()
                        Else
                           oMdlEV2PCO := oModelo:GetModel("EV2MSTR_TRIB_PISCOFINS") 
                           oGrdEV2PCO := oMdlEV2PCO:getStruct()
                           aCpoEV2PCO := oGrdEV2PCO:GetFields()
                        EndIf

                        oMdlEV2TRB := oModelo:GetModel("EV2MSTR_TRIB_OBS") 
                        oGrdEV2TRB := oMdlEV2TRB:getStruct()
                        aCpoEV2TRB := oGrdEV2TRB:GetFields()
                     endif

                     oModelSWV := oModelo:GetModel("SWVDETAIL") 
                     oModelEV1 := oModelo:GetModel("EV1MASTER")

                     oModelDet:SetMaxLine(10000) // avaliar se tem necessidade de verificar a quantidade de item no processo do embarque
                  endif

                  lAddLine := .F.
                  aRet := {}
                  aAreaSW6 := SW6->(getArea())
                  SW6->(dbSetOrder(1)) // SW6_FILIAL+SW6_HAWB
                  SW6->(dbSeek( xFilial("SW6") + cHawb))
                  Do While SWV->(!Eof()) .and. SWV->WV_FILIAL == xFilial("SWV") .and. SWV->WV_HAWB == cHawb
                     lTemLpco := .F.
                     lTemCP   := .F.
                     aCposLoad := {}
                     oObjetivo := jSonObject():New()
                     aAdd( aRet, {} ) // { {} /*SWV*/, {} /*EIJ*/ , {} /*EV3 e EV4*/ , {} /*EVE*/, {} /*EVI*/, {} /*EV6*/ }

                     LP500GetInfo("EIJ",3,xFilial("EIJ") + SWV->WV_HAWB + SWV->WV_ID,"EIJ_IDWV")
                     aAdd( aCposLoad, {"WV_HAWB"   , SWV->WV_HAWB} )
                     aAdd( aCposLoad, {"WV_SEQDUIM", SWV->WV_SEQDUIM} )
                     aAdd( aCposLoad, {"WV_ID"     , SWV->WV_ID} )                     
                     aAdd( aCposLoad, {"WV_INVOICE", SWV->WV_INVOICE} )
                     aAdd( aCposLoad, {"WV_FORN"   , SWV->WV_FORN} )
                     aAdd( aCposLoad, {"WV_NOMEFOR", DU100Relac('WV_NOMEFOR')})
                     aAdd( aCposLoad, {"WV_FORLOJ" , SWV->WV_FORLOJ} )
                     aAdd( aCposLoad, {"WV_PO_NUM" , SWV->WV_PO_NUM} )
                     aAdd( aCposLoad, {"WV_POSICAO", SWV->WV_POSICAO} )
                     aAdd( aCposLoad, {"WV_COD_I"  , SWV->WV_COD_I} )
                     aAdd( aCposLoad, {"WV_DESC_DI", DU100Relac('WV_DESC_DI')} )
                     aAdd( aCposLoad, {"WV_NCM"    , DU100Relac('WV_NCM')} )
                     aAdd( aCposLoad, {"WV_SEQUENC", SWV->WV_SEQUENC} )
                     aAdd( aCposLoad, {"WV_QTDE"   , SWV->WV_QTDE} )
                     aAdd( aCposLoad, {"WV_LOTE"   , SWV->WV_LOTE} )
                     aAdd( aCposLoad, {"WV_DT_VALI", SWV->WV_DT_VALI} )
                     aAdd( aCposLoad, {"WV_DFABRI" , SWV->WV_DFABRI} )
                     aAdd( aCposLoad, {"WV_OBS"    , SWV->WV_OBS} )
                     aAdd( aCposLoad, {"WV_PGI_NUM", SWV->WV_PGI_NUM})
                     If AvFlags("FUNDAMENTO_LEGAL_ITEM")
                        aAdd( aCposLoad, {"WV_ATRIBUT", SWV->WV_ATRIBUT})
                     EndIf
                     If AvFlags("DRAWBACK_DUIMP")
                        aAdd( aCposLoad, {"WV_MODAL"  , SWV->WV_MODAL })
                        aAdd( aCposLoad, {"WV_AC"     , SWV->WV_AC    })
                        aAdd( aCposLoad, {"WV_SEQSIS" , SWV->WV_SEQSIS})
                     EndIf
                     If SWV->(columnPos("WV_ATT_FL")) > 0
                        aAdd( aCposLoad, {"WV_ATT_FL" , SWV->WV_ATT_FL})
                     EndIf
                     If lModel .And. canUseApp()
                        oObjetivo['ncm']  := DU100Relac('WV_NCM')
                        oObjetivo['idwv'] := SWV->WV_ID
                        oVlCodObj[oObjetivo['idwv']] := oObjetivo

                        setNcmAtri(cTmpAtrib, "NCM", SWV->WV_ID, DU100Relac('WV_NCM'))
                        oCamposPoui := jsonObject():New()
                        oCamposPoui['WV_SEQUENC']  := SWV->WV_SEQUENC
                        oCamposPoui['WV_NCM']      := DU100Relac('WV_NCM')
                        oCamposPoui['WV_QTDE']     := SWV->WV_QTDE
                        oCamposPoui['WV_DESC_DI']  := DU100Relac('WV_DESC_DI')
                        oCamposPoui['WV_ID']       := SWV->WV_ID
                        oCamposPoui['WV_INVOICE']  := SWV->WV_INVOICE
                        oCamposPoui['WV_PO_NUM']   := SWV->WV_PO_NUM
                        oCamposPoui['WV_POSICAO']  := SWV->WV_POSICAO
                        oCamposPoui['WV_COD_I']    := SWV->WV_COD_I
                        
                        oFundLegal[SWV->WV_ID] := JsonObject():new()
                        aAdd(aDadosPoui, oCamposPoui)
                        freeObj(oCamposPoui)
                     EndIf
                     
                     if lModel
                        AddLine(oModelDet, aCposLoad, lAddLine)
                     else
                        aAdd( aRet[len(aRet)], { "SWVDETAIL", aClone(aCposLoad) })
                     endif

                     lAddLine := .T.
                     if SWV->WV_ID == EIJ->EIJ_IDWV
                        if lModel
                           DU100EV2Inc(oModelEV2MC, aCpoEV2MC, oModelEV2FF, aCpoEV2FF, oModelEV2CV, aCpoEV2CV, oModelSWV, oModelEV1, oMdlEV2II, aCpoEV2II, oMdlEV2IPI, aCpoEV2IPI, oMdlEV2PCO, aCpoEV2PCO, oMdlEV2TRB, aCpoEV2TRB,  oMdlEV2PIS, aCpoEV2PIS, oMdlEV2COF, aCpoEV2COF, oMdlEV2DUM, aCpoEV2DUM)
                        else
                           aCposLoad := getInfEIJ()
                           aAdd( aRet[len(aRet)], { "EV2DETAIL", aClone(aCposLoad) } )
                        endif
                     endif
                     If lModel .And. canUseApp()
                        If !Empty(oModelEV2MC:getvalue("EV2_IDPTCP"))
                           lTemCP := .T.
                        EndIf
                        oVlCodObj[SWV->WV_ID]['catalogo'] := jsonObject():New()
                        oVlCodObj[SWV->WV_ID]['catalogo']['catalogo'] := oModelEV2MC:getvalue("EV2_IDPTCP")
                        oVlCodObj[SWV->WV_ID]['catalogo']['versao']   := oModelEV2MC:getvalue("EV2_VRSACP")
                        jsonCP := jsonObject():New()
                        jsonCP['id']      := SWV->WV_ID
                        jsonCP['catalogo']:= lTemCP
                        aAdd(aDadosCP, jsonCP)
                        freeObj(jsonCP)
                     EndIf

                     aCposLoad := GetInfDet(oModelo,"EV3DETAIL",,cHawb, oModelDet, oModelEV3, oModelEV4) // Acréscimos e deduções
                     if !lModel
                        aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                     endif

                     aCposLoad := GetInfDet(oModelo,"EVEDETAIL",,cHawb, oModelDet, , , oModelEVE) // LPCO's
                     if !lModel
                        aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                     endif
                     If lModel .And. canUseApp()
                        If !Empty(oModelEVE:getValue("EVE_LPCO")) // Verifica se tem LPCO's
                           lTemLpco := .T.
                        EndIf
                        jsonLPCO := jsonObject():New()
                        jsonLPCO['id']   := SWV->WV_ID
                        jsonLPCO['lpco'] := lTemLpco
                        aAdd(aDadosLPCO, jsonLPCO)
                        freeObj(jsonLPCO)
                     EndIf
                     aCposLoad := GetInfDet(oModelo,"EVIDETAIL",,cHawb, oModelDet, , , , oModelEVI) // Certificado Mercosul
                     if !lModel
                        aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                     endif

                     aCposLoad := GetInfDet(oModelo,"EV6DETAIL",,cHawb, oModelDet, , , , , oModelEV6) // Documentos Vinculados
                     if !lModel
                        aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                     endif

                     If avFlags("TRIBUTACAO_DUIMP")
                        aCposLoad := GetInfDet(oModelo,"EVGGRID_II",,cHawb, oModelDet, , , , , ,oMdlEVGII) // II - EVG
                        if !lModel
                           aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                        endif

                        aCposLoad := GetInfDet(oModelo,"EVGGRID_IPI",,cHawb, oModelDet, , , , , , ,oMdlEVGIPI) // IPI - EVG
                        if !lModel
                           aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                        endif

                        aCposLoad := GetInfDet(oModelo,"EVGGRID_PIS",,cHawb, oModelDet, , , , , , , ,oMdlEVGPIS) // PIS - EVG
                        if !lModel
                           aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                        endif

                        aCposLoad := GetInfDet(oModelo,"EVGGRID_COFINS",,cHawb, oModelDet, , , , , , , , ,oMdlEVGCOF) // COFINS - EVG
                        if !lModel
                           aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                        endif

                        aCposLoad := GetInfDet(oModelo,"EVGGRID_ANTIDUMPING",,cHawb, oModelDet, , , , , , , , , ,oMdlEVGDUM) // COFINS - EVG
                        if !lModel
                           aAdd( aRet[len(aRet)], aClone(aCposLoad) )
                        endif
                     EndIf
                     freeObj(oObjetivo)
                     SWV->(DbSkip())
                  EndDo
                  If lModel .And. canUseApp()
                     setItPOUI(aDadosPoui)
                     setStPOUI(aDadosCP, aDadosLPCO)
                     //Monta o objeto com os atributos da DUIMP - EKG tipo 3
                     LP500ATCOM(cTmpAtrib, OBJETIVO_DUIMP)//Atributos complementares (atributos DUIMP)
                  EndIf
                  
                  if lModel .and. len(oModelDet:aDataModel) == 1
                     oModelDet:aDataModel[1][9] := .T.
                  endif
               endif

               if lModel
                  sUpdDelIns(oModelEV3, aCfgEV3)
                  sUpdDelIns(oModelEV4, aCfgEV4)
                  sUpdDelIns(oModelEVE, aCfgEVE)
                  sUpdDelIns(oModelEVI, aCfgEVI)
                  sUpdDelIns(oModelEV6, aCfgEV6)
                  If avFlags("TRIBUTACAO_DUIMP")
                     sUpdDelIns(oMdlEVGII , aCfgEVGII)
                     sUpdDelIns(oMdlEVGIPI, aCfgEVGIPI)
                     sUpdDelIns(oMdlEVGPIS, aCfgEVGPIS)
                     sUpdDelIns(oMdlEVGCOF, aCfgEVGCOF)
                     sUpdDelIns(oMdlEVGDUM, aCfgEVGDUM)
                  EndIf
               else
                  aRetorno := {cIdModel, aRet}
               endif

               restArea(aAreaSWV)
               restArea(aAreaSW6)

            case cIdModel == "EV3DETAIL"

               if lModel .and. oModelo:getOperation() == MODEL_OPERATION_INSERT
                  oModelEV4 := oModelo:GetModel("EV4DETAIL")
                  oModelEV4:DelAllline()
                  oModelEV4:ClearData(.F., .T.)
               endif

               aRet := LoadEV3EV4(oModelSWV, oModelEV3, oModelEV4)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVEDETAIL"

               aRet := LoadEVE(oModelSWV, oModelEVE)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVIDETAIL"

               aRet := LoadEVI(oModelSWV, oModelEVI)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EV6DETAIL"

               aRet := LoadEV6(oModelSWV, oModelEV6)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVGGRID_II"
               aRet := LoadEVG(oModelSWV, oModEVGII, 1)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVGGRID_IPI"
               aRet := LoadEVG(oModelSWV, oModEVGIPI, 2)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVGGRID_PIS"
               aRet := LoadEVG(oModelSWV, oModEVGPIS, 3)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVGGRID_COFINS"
               aRet := LoadEVG(oModelSWV, oModEVGCOF, 4)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

            case cIdModel == "EVGGRID_ANTIDUMPING"
               aRet := LoadEVG(oModelSWV, oModEVGDUM, 5)
               if !lModel
                  aRetorno := {cIdModel, aClone(aRet)}
               endif

         end case

      endif

      if lModel
         oModelDet:GoLine(1)
         if cIdModel == "EVBDETAIL" .or. cIdModel == "EV9DETAIL" .or. cIdModel == "SWVDETAIL"
            sUpdDelIns(oModelDet, aConfig)
            restArea(aArea)
         endif
      endif

   endif

return aRetorno

/*
Função     : sUpdDelIns
Objetivo   : Verifica a permissão de inclusão, alteração ou exclusão da grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function gUpdDelIns(oModelDet)
   local aRet       := {}
   local lNoInsLine := .F.
   local lNoUpdLine := .F.
   local lNoDelLine := .F.

   if !oModelDet:CanInsertLine()
      oModelDet:SetNoInsertLine(.F.)
      lNoInsLine := .T.
   endif

   if !oModelDet:CanUpdateLine()
      oModelDet:SetNoUpdateLine(.F.)
      lNoUpdLine := .T.
   endif

   if !oModelDet:CanDeleteLine()
      oModelDet:SetNoDeleteLine(.F.)
      lNoDelLine := .T.
   endif
   aRet := {lNoInsLine,lNoUpdLine,lNoDelLine}

return aRet


Static Function setNcmAtri(cAlias, cTipo, cWVID, cNcm, cLote, cHawb, cSeqDuim)
Local lSeek
Default cLote := ""
Default cHawb := ""
Default cSeqDuim := ""

lSeek := (cAlias)->(dbSeek(cWVID))
If cTipo == "NCM"
   RecLock(cAlias, !lSeek)
   (cAlias)->(WV_ID)       := cWVID
   (cAlias)->(YD_TEC)      := cNcm
   (cAlias)->(EV2_LOTE)    := cLote
   (cAlias)->(EV2_HAWB)    := cHawb
   (cAlias)->(EV2_SEQDUI)  := cSeqDuim
   (cAlias)->(MsUnlock())
EndIf
Return

/*
Função     : sUpdDelIns
Objetivo   : Atualiza a permissão de inclusão, alteração ou exclusão da grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function sUpdDelIns(oModelDet, aConfig)

   default aConfig   := {.F.,.F.,.F.}

   oModelDet:SetNoInsertLine(aConfig[1])
   oModelDet:SetNoUpdateLine(aConfig[2])
   oModelDet:SetNoDeleteLine(aConfig[3])

return

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aCposLoad, lAddLine, lSetValue)
   local nCpo      := 0

   default lAddLine := .F.
   default lSetValue:= .F.

   if lAddLine
      oModelDet:AddLine()
   endif

   for nCpo := 1 to Len(aCposLoad)
      If lSetValue
         oModelDet:SetValue( aCposLoad[nCpo][1], aCposLoad[nCpo][2] )
      Else
         oModelDet:LoadValue( aCposLoad[nCpo][1], aCposLoad[nCpo][2] )
      EndIf
   next

return

/*
Objetivo   : Função para carregar dados na tabela EV2
Retorno    : Nil
Autor      : Maurício Frison
Data       : Março/2022
Revisão    :
*/
Static Function DU100EV2Load(oModel)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oGrdEV2MC    :=  oModel:getStruct() 
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") 
   Local oModelEV1     := oMdl:GetModel("EV1MASTER")  
   Local oModelEV2MC   := oMdl:GetModel("EV2MSTR_MC")           
   Local aCpoEV2       := {}
   Local nContCpo      := 0
   Local cCampo        := ""
   aCpoEV2 := oGrdEV2MC:GetFields()

   cChaveEV2 := xFilial("EV2") + oModelEV1:GetValue("EV1_LOTE")  + oModelSWV:GetValue("WV_HAWB") + "" + oModelSWV:GetValue("WV_SEQDUIM") 
   EV2->(DbSetOrder(3))
   If EV2->(DbSeek( cChaveEV2  ))
      For nContCpo := 1 to Len(aCpoEV2)
          //trata campos virtual quando houver na tabela
          //aAdd( aFilCpos ,  If( GetSx3Cache( aCpoEV2[nContCpo][3], "X3_CONTEXT") <> "V"  ,  EV2->&(aCpoEV2[nContCpo][3]) ,  LoadCpoVir(aCpoEV2[nContCpo][3],"EV2")   )     )
         cCampo := aCpoEV2[nContCpo][3]          
         aAdd( aFilCpos , iif(oModel:cid $ "EV2MSTR_FF|EV2MSTR_CV|EV2MSTR_TRIB_II|EV2MSTR_TRIB_IPI|EV2MSTR_TRIB_PISCOFINS|EV2MSTR_TRIB_PIS|EV2MSTR_TRIB_COFINS|EV2MSTR_TRIB_ANTIDUMPING|EV2MSTR_TRIB_OBS", oModelEV2MC:getValue(cCampo), EV2->&(aCpoEV2[nContCpo][3])))
      Next nContCpo
   EndIf
Return aFilCpos

/*
Objetivo   : Função para carregar dados na tabela EV2MC
Retorno    : Nil
Autor      : Maurício Frison
Data       : Março/2022
Revisão    :
*/
Static Function DU100EV2Inc(oModelEV2MC, aCpoEV2MC, oModelEV2FF, aCpoEV2FF, oModelEV2CV, aCpoEV2CV, oModelSWV, oModelEV1, oMdlEV2II, aCpoEV2II, oMdlEV2IPI, aCpoEV2IPI, oMdlEV2PCO, aCpoEV2PCO, oMdlEV2TRB, aCpoEV2TRB, oMdlEV2PIS, aCpoEV2PIS, oMdlEV2COF, aCpoEV2COF, oMdlEV2DUM, aCpoEV2DUM )
   Local nContCpo      := 0
   Local cCampo        := ""   

   For nContCpo := 1 to Len(aCpoEV2MC)
      cCampo := aCpoEV2MC[nContCpo][3]
      oModelEV2MC:loadValue(cCampo,GetValor(cCampo,oModelSWV,oModelEV1))
   Next nContCpo

   For nContCpo := 1 to Len(aCpoEV2FF)
      cCampo := aCpoEV2FF[nContCpo][3]
      oModelEV2FF:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
   Next nContCpo

   For nContCpo := 1 to Len(aCpoEV2CV)
      cCampo := aCpoEV2CV[nContCpo][3]
      oModelEV2CV:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
   Next nContCpo

   if DUIMP2310()
      For nContCpo := 1 to Len(aCpoEV2II)
         cCampo := aCpoEV2II[nContCpo][3]
         oMdlEV2II:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
      For nContCpo := 1 to Len(aCpoEV2IPI)
         cCampo := aCpoEV2IPI[nContCpo][3]
         oMdlEV2IPI:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
      If avFlags("TRIBUTACAO_DUIMP")
         For nContCpo := 1 to Len(aCpoEV2PIS)
            cCampo := aCpoEV2PIS[nContCpo][3]
            oMdlEV2PIS:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
         Next nContCpo
         For nContCpo := 1 to Len(aCpoEV2COF)
            cCampo := aCpoEV2COF[nContCpo][3]
            oMdlEV2COF:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
         Next nContCpo
         For nContCpo := 1 to Len(aCpoEV2DUM)
            cCampo := aCpoEV2DUM[nContCpo][3]
            oMdlEV2DUM:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
         Next nContCpo
      Else
         For nContCpo := 1 to Len(aCpoEV2PCO)
            cCampo := aCpoEV2PCO[nContCpo][3]
            oMdlEV2PCO:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
         Next nContCpo
      EndIf
      For nContCpo := 1 to Len(aCpoEV2TRB)
         cCampo := aCpoEV2TRB[nContCpo][3]
         oMdlEV2TRB:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
   endif

Return 

/*
Função     : GetValor
Objetivo   : Pegar o valor conforme o campo
Retorno    : Retorna o valor
Autor      : Maurício Frison
Data/Hora  : Março/2022
*/
Static Function getValor(cCampo,oModelSWV,oModelEV1)
Local cUnid        := ""
Local cCnpjad      := ""
Local xRet

Do Case
         Case cCampo == "EV2_FILIAL"
            xRet:= xFilial("EV2")
         Case cCampo == "EV2_HAWB"
            xRet:= if( valtype(oModelSWV) == "O", oModelSWV:GetValue("WV_HAWB"), SWV->WV_HAWB)
         Case cCampo == "EV2_IDPTCP"   
            xRet:= EIJ->EIJ_IDPTCP
         Case cCampo == "EV2_VRSACP"
            xRet:= EIJ->EIJ_VRSACP
         Case cCampo == "EV2_CNPJRZ"
            xRet:= GetCNPJ( if( valtype(oModelSWV) == "O", oModelSWV:GetValue("WV_NCM"), DU100Relac("WV_NCM")), EIJ->EIJ_IDPTCP, EIJ->EIJ_VRSACP) 
         Case cCampo == "EV2_VINCCO"
            xRet:= EIJ->EIJ_VINCCO
         Case cCampo == "EV2_APLME"
            xRet:= EIJ->EIJ_APLICM
         Case cCampo = "EV2_MATUSA"
            xRet:= EIJ->EIJ_MATUSA
         Case cCampo == "EV2_DSCCIT"
            xRet:= EIJ->EIJ_DSCCIT
         Case cCampo == "EV2_IMPCO"
            xRet:= SW6->W6_IMPCO
         Case cCampo == "EV2_CNPJAD" 
              If SW6->W6_IMPCO=="1"
                 LP500GetInfo("SW2",1,xFilial("SW2") + SWV->WV_PO_NUM,"W2_CLIENTE")
                 cCnpjad  := LP500GetInfo("SA1",1,xFilial("SA1") + SW2->W2_CLIENTE + SW2->W2_CLILOJ,"A1_CGC")
              EndIf   
              xRet:= cCnpjad
         Case cCampo == "EV2_NMCOM"
            cUnid := LP500GetInfo("SW8",6,xFilial("SW8") + if( valtype(oModelSWV) == "O", oModelSWV:GETVALUE("WV_HAWB") + oModelSWV:GETVALUE("WV_INVOICE") + oModelSWV:GETVALUE("WV_PO_NUM") + oModelSWV:GETVALUE("WV_POSICAO") + oModelSWV:GETVALUE("WV_PGI_NUM"),;
            SWV->WV_HAWB + SWV->WV_INVOICE + SWV->WV_PO_NUM + SWV->WV_POSICAO + SWV->WV_PGI_NUM),"W8_UNID")
            xRet:= LP500GetInfo("SAH",1,xFilial("SAH") + cUnid,"AH_DESCPO")
         Case cCampo == "EV2_QTCOM"
            xRet:= transform(SWV->WV_QTDE,GetSX3Cache("WV_QTDE","X3_PICTURE")) 
         Case cCampo == "EV2_ATRIBU"
            xRet := IF(ValType(oModelSWV) == "O", oModelSWV:GetValue("WV_ATRIBUT"), SWV->WV_ATRIBUT)
         Case cCampo == "EV2_ATT_FL"
            xRet := IF(ValType(oModelSWV) == "O", oModelSWV:GetValue("WV_ATT_FL"), SWV->WV_ATT_FL)
         Case cCampo == "EV2_QT_EST"
            xRet:= transform(EIJ->EIJ_QT_EST,GetSX3Cache("EIJ_QT_EST","X3_PICTURE"))
         Case cCampo == "EV2_PESOL"
            xRet:= transform(EIJ->EIJ_PESOL,GetSX3Cache("EIJ_PESOL","X3_PICTURE")) 
         Case cCampo == "EV2_MOE1"
            xRet:= getMoeda(EIJ->EIJ_MOEDA) // POSICIONE("SYF",1,xFilial("SYF") + EIJ->EIJ_MOEDA,"YF_COD_GI")
         Case cCampo == "EV2_VLMLE"
            xRet:= transform(EIJ->EIJ_VLMLE,GetSX3Cache("EIJ_VLMLE","X3_PICTURE")) 
         Case cCampo == "EV2_LOTE"
            xRet:= if( valtype(oModelEV1) == "O", oModelEV1:GetValue("EV1_LOTE"), EV1->EV1_LOTE)
         Case cCampo == "EV2_SEQDUI"
            xRet:= if( valtype(oModelSWV) == "O", oModelSWV:GetValue("WV_SEQDUIM"), SWV->WV_SEQDUIM)
         Case cCampo == "EV2_FABFOR"
            xRet:= EIJ->EIJ_FABFOR
         Case cCampo == "EV2_TINFA"
            xRet:= EIJ->EIJ_TINFA            
         Case cCampo == "EV2_VRSFAB"         
            xRet:= EIJ->EIJ_VRSFAB
         Case cCampo == "EV2_PAIOME"         
            xRet:= GetPais(EIJ->EIJ_PAISOR)
         Case cCampo == "EV2_TINFO"  
            xRet:= EIJ->EIJ_TINFO
         Case cCampo == "EV2_VRSFOR"           
            xRet:= EIJ->EIJ_VRSFOR
         Case cCampo == "EV2_PAISPR"                    
            xRet:= GetPais(EIJ->EIJ_PAISPR)
         Case cCampo == "EV2_METVAL" 
            xRet:= EIJ->EIJ_METVAL
         Case cCampo == "EV2_INCOTE" 
            xRet:= EIJ->EIJ_INCOTE
         Case cCampo == "EV2_TIPCOB" 
            xRet:= EIJ->EIJ_TIPCOB
         Case cCampo == "EV2_NRROF" 
            xRet:= EIJ->EIJ_NRROF
         Case cCampo == "EV2_INSTFI" 
            xRet:= EIJ->EIJ_INSTFI
         Case cCampo == "EV2_MOTIVO"
            xRet:= EIJ->EIJ_MOTIVO
         Case cCampo == "EV2_VL_FIN"
            xRet:= transform(EIJ->EIJ_VL_FIN,AvSX3("EIJ_VLMLE",AV_PICTURE)) 
         otherwise
            xRet := criavar(cCampo)

ENDCASE
return xRet

/*
Função     : LoadEV3EV4
Objetivo   : Carrega a grid da EV3 e EV4 - Acréscimos e Deduções
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEV3EV4(oModelSWV, oModelEV3, oModelEV4)
   local aAreaEIN   := {}
   local cChaveEIN  := ""
   local aCposLoad  := {}
   local cPicture   := ""
   local cValor     := ""
   local cTipo      := ""
   local lAddLinEV3 := .F.
   local lAddLinEV4 := .F.
   local lModel     := .F.
   local aRet       := {}

   dbSelectArea("EIN")
   aAreaEIN := EIN->(getArea())
   lModel := valtype( oModelEV3 ) == "O" .and. valtype( oModelEV4 ) == "O"

   cChaveEIN := xFilial("EIN") + if( lModel , oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID"), SWV->WV_HAWB + SWV->WV_ID )

   EIN->(dbSetOrder(2)) // EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO
   if EIN->(dbSeek( cChaveEIN ))

      cPicture := GetSX3Cache("EIN_VLMLE","X3_PICTURE")
      while EIN->(!eof()) .and. (EIN->(EIN_FILIAL+EIN_HAWB+EIN_IDWV)) == cChaveEIN

         cValor := transform(EIN->EIN_VLMLE,cPicture) 
         cTipo := alltrim(EIN->EIN_TIPO)
         aCposLoad := {}

         if cTipo == "1" // Acréscimos

            aAdd( aCposLoad, {"EV3_MOE"   , EIN->EIN_FOBMOE} )
            aAdd( aCposLoad, {"EV3_VLMLE" , cValor} )
            aAdd( aCposLoad, {"EV3_ACRES" , EIN->EIN_CODIGO} )

            if lModel
               AddLine(oModelEV3, aCposLoad, lAddLinEV3)
            else
               aAdd( aRet , { cTipo, aClone(aCposLoad) } )
            endif
            lAddLinEV3 := .T.

         elseif cTipo == "2" // Deduções

            aAdd( aCposLoad, {"EV4_MOE"   , EIN->EIN_FOBMOE} )
            aAdd( aCposLoad, {"EV4_VLMLE" , cValor} )
            aAdd( aCposLoad, {"EV4_DEDU"  , EIN->EIN_CODIGO} )

            if lModel
               AddLine(oModelEV4, aCposLoad, lAddLinEV4)
            else
               aAdd( aRet , { cTipo, aClone(aCposLoad) } )
            endif
            lAddLinEV4 := .T.

         endif

         EIN->(dbSkip())
      end

   endif

   restArea(aAreaEIN)

return aRet

/*
Função     : LoadEVE
Objetivo   : Carrega a grid da EVE - LPCO's
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEVE(oModelSWV, oModelEVE)
   local aAreaEKQ   := {}
   local cChaveEKQ  := ""
   local aCposLoad  := {}
   local lAddLinEVE := .F.
   local aDados     := {}
   local lModel     := .F.
   local aRet       := {}
   local oObjLPCO

   dbSelectArea("EKQ")
   aAreaEKQ := EKQ->(getArea())

   EKQ->(dbSetOrder(1)) // EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN+EKQ_ORGANU+EKQ_FRMLPC
   lModel := valtype( oModelEVE ) == "O" 
   cChaveEKQ := xFilial("EKQ") + if( lModel, oModelSWV:GetValue("WV_HAWB")  + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC"),;
   SWV->WV_HAWB + SWV->WV_INVOICE + SWV->WV_PO_NUM + SWV->WV_POSICAO + SWV->WV_SEQUENC)

   if EKQ->(dbSeek( cChaveEKQ ))
      If canUseApp()
         oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'] := {}
      EndIf
      while EKQ->(!eof()) .and. (EKQ->(EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN)) == cChaveEKQ
         oObjLPCO := jsonObject():New()
         if !empty(EKQ->EKQ_LPCO) .and. aScan( aDados, { |X| X == EKQ->EKQ_LPCO } ) == 0
            aCposLoad := {}
            aAdd( aCposLoad, {"EVE_LPCO"   , EKQ->EKQ_LPCO} )
            if lModel
               AddLine(oModelEVE, aCposLoad, lAddLinEVE)
            else
               aAdd( aRet , aClone(aCposLoad))
            endif
            lAddLinEVE := .T.
            If canUseApp()
               oObjLPCO['orgao']    := EKQ->EKQ_ORGANU
               oObjLPCO['formLpco'] := EKQ->EKQ_FRMLPC
               oObjLPCO['lpco']     := EKQ->EKQ_LPCO
               oObjLPCO['versao']   := EKQ->EKQ_VERSAO
               aAdd(oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'], jSonObject():New())
               oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'][Len(oVlCodObj[oModelSWV:GetValue("WV_ID")]['lpco'])] := oObjLPCO
            EndIf
            aAdd( aDados , EKQ->EKQ_LPCO)
         endif
         freeObj(oObjLPCO)
         EKQ->(dbSkip())
      end

   endif

   restArea(aAreaEKQ)

return aRet

/*
Função     : LoadEVI
Objetivo   : Carrega a grid da EVI- Certificado Mercosul
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEVI(oModelSWV, oModelEVI)
   local aAreaEJ9   := {}
   local cChaveEJ9  := ""
   local cPicture   := ""
   local aCposLoad  := {}
   local lAddLinEVI := .F.
   local lModel     := .F.
   local aRet       := {}

   dbSelectArea("EJ9")
   aAreaEJ9 := EJ9->(getArea())

   EJ9->(dbSetOrder(2)) // EJ9_FILIAL+EJ9_HAWB+EJ9_IDWV+EJ9_IDCERT+EJ9_DEMERC
   lModel := valtype( oModelEVI ) == "O"
   cChaveEJ9 := xFilial("EJ9") + if( lModel, oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID"), SWV->WV_HAWB + SWV->WV_ID)

   if EJ9->(dbSeek( cChaveEJ9 ))

      cPicture := GetSX3Cache("EJ9_QTDCER","X3_PICTURE") 
      while EJ9->(!eof()) .and. (EJ9->(EJ9_FILIAL+EJ9_HAWB+EJ9_IDWV)) == cChaveEJ9

         aCposLoad := {}
         aAdd( aCposLoad, {"EVI_NUM"    , EJ9->EJ9_DEMERC} )
         aAdd( aCposLoad, {"EVI_IDCERT" , EJ9->EJ9_IDCERT} )
         aAdd( aCposLoad, {"EVI_DEMERC" , EJ9->EJ9_DEMERC} )
         aAdd( aCposLoad, {"EVI_QTDCER" , transform(EJ9->EJ9_QTDCER,cPicture) } )
      
         if lModel
            AddLine(oModelEVI, aCposLoad, lAddLinEVI)
         else
            aAdd( aRet, aClone(aCposLoad) )
         endif
         lAddLinEVI := .T.

         EJ9->(dbSkip())
      end

   endif

   restArea(aAreaEJ9)

return aRet

/*
Função     : LoadEV6
Objetivo   : Carrega a grid da EV6 - Documentos Vinculados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEV6(oModelSWV, oModelEV6)
   local aAreaEIK   := {}
   local cChaveEIK  := ""
   local aCposLoad  := {}
   local lAddLinEV6 := .F.
   local lModel     := .F.
   local aRet       := {}

   dbSelectArea("EIK")
   aAreaEIK := EIK->(getArea())

   EIK->(dbSetOrder(2)) // EIK_FILIAL+EIK_HAWB+EIK_IDWV
   lModel := valtype( oModelEV6 ) == "O"
   cChaveEIK := xFilial("EIK") + if( lModel, oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID"), SWV->WV_HAWB + SWV->WV_ID)

   if EIK->(dbSeek( cChaveEIK ))

      while EIK->(!eof()) .and. (EIK->(EIK_FILIAL+EIK_HAWB+EIK_IDWV)) == cChaveEIK

         aCposLoad := {}
         aAdd( aCposLoad, {"EV6_TIPVIN" , EIK->EIK_TIPVIN} )
         aAdd( aCposLoad, {"EV6_DOCVIN" , EIK->EIK_DOCVIN } )
         if lModel
            AddLine(oModelEV6, aCposLoad, lAddLinEV6)
         else
            aAdd( aRet, aClone(aCposLoad) )
         endif
         lAddLinEV6 := .T.

         EIK->(dbSkip())
      end

   endif

   restArea(aAreaEIK)

return aRet

/*
Função     : LoadEVG
Objetivo   : Carrega a grid da EVG - Tributos
Autor      : THTS - Tiago Tudisco
Parâmetros : oModelSWV, oModelEVG, cTributo - Codigo do Tributo a ser carregado (1-II, 2-IPI, 3-PIS, 4-COFINS e 5-ANTIDUMPING)
Data/Hora  : Julho/2024
*/
static function LoadEVG(oModelSWV, oModelEVG, nTributo)
   local aArea      := {}
   local cChave     := ""
   local aCposLoad  := {}
   local lAddLinEVG := .F.
   local lModel     := .F.
   local aRet       := {}
   local aFundLegal := {'EIJ_FUNII','EIJ_FUNIPI','EIJ_FUNPIS','EIJ_FUNCOF','EIJ_FUNADU'}
   local aRegime    := {'EIJ_REGTRI','EIJ_REGIPI','EIJ_REGPIS','EIJ_REGCOF'}
   local cIdent     := ""
   local cDivider   := ""
   local cIdentInfo := ""
   local nOrder     := 0

   lModel := valtype( oModelEVG ) == "O"
   If AvFlags("FUNDAMENTO_LEGAL_ITEM")
      aArea := EKW->(getArea())
      EKW->(dbSetOrder(2))//EKW_FILIAL+EKW_IDWV+EKW_HAWB+EKW_TRIBUT+EKW_FDTLGL
      cChave := xFilial("EKW") + if( lModel, oModelSWV:GetValue("WV_ID") + oModelSWV:GetValue("WV_HAWB") + cValToChar(nTributo), SWV->WV_ID + SWV->WV_HAWB + cValToChar(nTributo))
      If EKW->(dbSeek( cChave ))
         While EKW->(!eof()) .and. (EKW->(EKW_FILIAL+EKW_IDWV+EKW_HAWB+EKW_TRIBUT)) == cChave
            aCposLoad   := {}
            cMercValor  := ""
            cMercadoria := ""
            aAdd( aCposLoad, {"EVG_FUNDLE"   , EKW->EKW_FDTLGL})
            aAdd( aCposLoad, {"EVG_IDIMP"    , EKW->EKW_TRIBUT})  
            aAdd( aCposLoad, {"EVG_REGIME"   , EKW->EKW_REGIME})
            aAdd( aCposLoad, {"EVG_TIPOFL"   , EKW->EKW_TIPO})
            aAdd( aCposLoad, {"EVG_ATRIBU"   , EKW->EKW_ATRIBU})
            aAdd( aCposLoad, {"EVG_SEQDUI"   , IIF(lModel, oModelSWV:GetValue("WV_SEQDUIM"), SWV->WV_SEQDUIM)})
            if lModel
               AddLine(oModelEVG, aCposLoad, lAddLinEVG, .T.)
            else
               aAdd( aRet, aClone(aCposLoad) )
            endif
            //Tratamento para Atributos POUI
            If canUseApp() .And. EKV->(dbSeek(xFilial("EKV") + EKW->EKW_NCM + EKW->EKW_FDTLGL + EKW->EKW_TRIBUT + getPaisOri(oModelSWV:GetValue("WV_HAWB")))) //EKV_FILIAL+EKV_NCM+EKV_FDTLGL+EKV_TRIBUT+EKV_PAIS
               //Atributos Informativos
               If EV2->(ColumnPos("EV2_ATT_FL")) > 0
                  If !oFundLegal[SWV->WV_ID]:hasProperty(EKW->EKW_FDTLGL)
                     cIdentInfo := SWV->WV_ID + "-" + EKW->EKW_FDTLGL + "_"
                     nOrder := IIF(oInfoAtt:hasProperty('listaAtributos'),Len(oInfoAtt['listaAtributos']),nil)
                     cActiveID := SWV->WV_ID
                     SW6->(dbSeek(xFilial("SW6") + SWV->WV_HAWB))
                     LP500ATINF(oInfoAtt, LP500GetInfo("EKU", 1, xFilial("EKU") + EKW->EKW_FDTLGL, "EKU_ATT_FL"), cIdentInfo, SWV->WV_ATT_FL, SWV->WV_AC, SWV->WV_SEQSIS, nOrder)
                     oFundLegal[SWV->WV_ID][EKW->EKW_FDTLGL] := 1
                  Else
                     oFundLegal[SWV->WV_ID][EKW->EKW_FDTLGL]++
                  EndIf
               EndIf
               //Atributos Adicionais
               If !Empty(EKV->EKV_ATRIBU)
                  cIdent   := oModelSWV:GetValue("WV_ID") + "-" + Alltrim(EKW->EKW_NCM) + "-" + EKW->EKW_FDTLGL + "-" + EKW->EKW_TRIBUT + "-" + EKW->EKW_TIPO + "-" + getPaisOri(oModelSWV:GetValue("WV_HAWB")) + "_"
                  cDivider := getTribName(EKW->EKW_TRIBUT) + " | " +  EKW->EKW_REGIME + " - " + Alltrim(LP500GetInfo("SJP",1,xFilial("SJP") + EKW->EKW_REGIME,"JP_DESC")) + " | " +  EKW->EKW_FDTLGL + " - " +  LP500GetInfo("EKU",1,xFilial("EKU") + EKW->EKW_FDTLGL,"EKU_FDTDES")
                  LP500ATMER(oJsonAtt, EKV->EKV_ATRIBU, cIdent, cDivider, EKW->EKW_ATRIBU)
                  oJsonPOUI['listaAdicionais'] := oJsonAtt
               EndIf
            EndIf
            lAddLinEVG := .T.
            EKW->(dbSkip())
         End
      EndIf
      restArea(aArea)
   Else
      dbSelectArea("EIJ")
      aArea := EIJ->(getArea())
 
      EIJ->(dbSetOrder(3)) // EIJ_FILIAL+EIJ_HAWB+EIJ_IDWV
      cChave := xFilial("EIJ") + if( lModel, oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID"), SWV->WV_HAWB + SWV->WV_ID)
 
      if EIJ->(dbSeek( cChave ))
 
         while EIJ->(!eof()) .and. (EIJ->(EIJ_FILIAL + EIJ_HAWB + EIJ_IDWV)) == cChave
 
            aCposLoad := {}
            aAdd( aCposLoad, {"EVG_FUNDLE"   , &("EIJ->"+aFundLegal[nTributo]) } )
            If nTributo <> 5 //Antidumping não tem regime
               aAdd( aCposLoad, {"EVG_REGIME", &("EIJ->"+aRegime[nTributo]) } )
            EndIf
            aAdd( aCposLoad, {"EVG_IDIMP"    , Str(nTributo,1) } )
            if lModel
               AddLine(oModelEVG, aCposLoad, lAddLinEVG, .T.)
            else
               aAdd( aRet, aClone(aCposLoad) )
            endif
            lAddLinEVG := .T.
 
            EIJ->(dbSkip())
         end
 
      endif
 
      restArea(aArea)
   EndIf
return aRet

/*
Função     : GetMoeda
Objetivo   : Função para retornar o campo YF_ISO, caso esteja preenchido
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetMoeda(cMoeda)
   local cRet       := ""
   local cKeySeek   := ""

   default cMoeda := ""

   dbSelectArea("SYF") // YF_FILIAL+YF_MOEDA

   cKeySeek := xFilial("SYF") + cMoeda

   if cKeySeek <> SYF->&(IndexKey())
      SYF->(dbSetOrder(1))
      SYF->(DbSeek( cKeySeek ))
   endif

   cRet := cMoeda
   if SYF->(!eof())
      cRet := if(!empty(SYF->YF_ISO),SYF->YF_ISO,SYF->YF_MOEDA)
   endif

return cRet

/*
Função     : GetPais
Objetivo   : Função para retornar o campo YA_PAISDUE
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetPais(cPais)
   local cRet       := ""
   local cKeySeek   := ""

   default cPais := ""

   dbSelectArea("SYA") // YA_FILIAL+YA_CODGI

   cKeySeek := xFilial("SYA") + cPais

   if cKeySeek <> SYA->&(IndexKey())
      SYA->(dbSetOrder(1))
      SYA->(DbSeek( cKeySeek ))
   endif

   if SYA->(!eof())
      cRet := SYA->YA_PAISDUE
   endif

return cRet

/*
Função     : GetCNPJ
Objetivo   : Função para retornar o campo EKD_CNPJ (Raiz do CNPJ declarante)
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetCNPJ(cNCM, cIdPortal, cVersao)
   local cRet       := ""
   local cKeySeek   := ""
   local lDUIMP23_3 := AvFlags("DUIMP_12.1.2310-23.3")

   default cNCM       := ""
   default cIdPortal  := ""
   default cVersao    := ""

   dbSelectArea("EKD") 

   cKeySeek := xFilial("EKD") + cNCM + cIdPortal + cVersao

   if cKeySeek <> EKD->&(IndexKey())
      if( lDUIMP23_3 , EKD->(DbSetOrder(4)) , EKD->(DbSetOrder(2)) )
      //EKD->(DbSetOrder(4)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VATUAL
      //EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
      EKD->(DbSeek( cKeySeek ))
   endif

   if EKD->(!eof())
      cRet := EKD->EKD_CNPJ
   endif

return cRet

/*
Função     : DU100VdSW6
Objetivo   : Função para validar se irá prosseguir com a manutenção do Embarque ou Desembaraço, dependendo do status das tabelas EV's
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU100VdSW6(cHawb, lExecAuto)
   local cAliasSel := alias()
   local lRet      := .T.
   local aAreaEV1  := {}

   default cHawb     := SW6->W6_HAWB
   default lExecAuto := .F.

   dbSelectArea("EV1")
   if EV1->(columnPos("EV1_STATUS")) > 0

      aAreaEV1 := EV1->(getArea())
      EV1->(dbSetOrder(1)) // EV1_FILIAL+EV1_HAWB+EV1_LOTE
      if EV1->(AvSeekLast( xFilial("EV1") + cHawb ))
         if EV1->EV1_STATUS == EM_PROCESSAMENTO
            lRet := lExecAuto .or. MsgYesNo(STR0128 + ENTER + ; //"A declaração deste processo encontra-se com o status 'Registro em Processamento'. "
            STR0129 +ENTER + ENTER +; //"A alteração de dados sensíveis para a DUIMP implicarão na geração de uma nova versão para transmissão, que deverá ser realizada pela rotina de Integração DUIMP (EICDU100)."
            STR0127, STR0014) //"Deseja prosseguir?"####"Atenção"
         elseif EV1->EV1_STATUS == PENDENTE_REGISTRO
            lRet := lExecAuto .or. MsgYesNo( STR0080, STR0014) 
            // "A declaração deste processo encontra-se com o status 'Pendente de registro'. Ao atualizar os dados, o status será atualizado para 'Pendente de integração' e o registro atual será atualizado para 'Obsoleto'. Deseja prosseguir?" ### "Atenção"
         endif
      endif
      restArea(aAreaEV1)

   endif

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return lRet

/*
Função     : DU100AtuEV
Objetivo   : Função para atualizar a tabela EV1
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU100AtuEV( nRecEV1 , cStatus)
   local cAliasSel := alias()
   local aAreaEV1  := {}

   default nRecEV1   := 0
   default cStatus   := OBSOLETO

   if nRecEV1 > 0 .and. EV1->(columnPos("EV1_STATUS")) > 0

      aAreaEV1 := EV1->(getArea())

      EV1->(dbGoTo(nRecEV1))
      if (EV1->(recno()) == nRecEV1 .and. RecLock("EV1", .F.))
         EV1->EV1_STATUS := cStatus
         EV1->(MsUnLock())
      endif

      restArea(aAreaEV1)

   endif

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return

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

/*/{Protheus.doc} DU100Relac
   Realiza o inicializador padrão de um determinado campo

   @type  Static Function
   @author user
   @since 15/08/2023
   @version version
   @param cCampo, caractere, nome do campo
   @return cRet, caractere, informação para o campo
/*/
static function DU100Relac(cCampo)
   local cRet       := ""

   do case
      case cCampo == "WV_NOMEFOR"
         cRet := LP500GetInfo("SA2",1,xFilial("SA2") + SWV->WV_FORN + SWV->WV_FORLOJ,"A2_NREDUZ")
      case cCampo == "WV_DESC_DI"
         LP500GetInfo("EIJ",3,xFilial("EIJ") + SWV->WV_HAWB + SWV->WV_ID,"EIJ_IDWV")
         if SWV->WV_ID == EIJ->EIJ_IDWV
            cRet := Left( EIJ->EIJ_DSCCIT ,AvSx3("WV_DESC_DI", AV_TAMANHO))
         endif
      case cCampo == "WV_NCM"
         cRet := LP500GetInfo("SW8",6,xFilial("SW8") + SWV->WV_HAWB + SWV->WV_INVOICE + SWV->WV_PO_NUM + SWV->WV_POSICAO + SWV->WV_PGI_NUM,"W8_TEC")
   end case

return cRet

/*/{Protheus.doc} DU100Log
   Geração de log em pdf ou envio por email do Integração DUIMP

   @type  Function
   @author user
   @since 16/08/2023
   @version version
   @param nenhum
   @return nulo
/*/
function DU100Log()
return EasyLogPrt("4")

/*/{Protheus.doc} DU100Status
   Opções do campo EV1_STATUS

   @type  Function
   @author user
   @since 16/08/2023
   @version version
   @param nenhum
   @return cComboBox, caractere, combo box do campo EV1_STATUS
/*/
function DU100Status()
   local cComboBox := ""

   cComboBox := "1=" + STR0055 + ";" // "Pendente de Integração" 
   cComboBox += "2=" + STR0056 + ";" // "Processo Pendente de Revisão"
   cComboBox += "3=" + STR0057 + ";" // "Pendente de Registro"
   cComboBox += "4=" + STR0058 + ";" // "Duimp Registrada"
   cComboBox += "5=" + STR0059 + ";" // "Obsoleto"
   cComboBox += "6=" + STR0105       // "Registro em Processamento"

return cComboBox

/*/{Protheus.doc} loadTrigger
   Array com os gatilhos da integração DUIMP

   @type  Static Function
   @author user
   @since 03/01/2024
   @version version
   @param nenhum
   @return aTrigger, vetor, informações dos gatilhos
   @example
   (examples)
   @see (links_or_references)
/*/
static function loadTrigger()
   local aTrigger   := {}
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_TIPREG" , nil , {|oModel| DU100GATIL("EV1_TIPREG")} , "EV1_TIPREG" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_SEQUEN" , nil , {|oModel| DU100GATIL("EV1_SEQUEN")} , "EV1_SEQUEN" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_IMPNOM" , nil , {|oModel| DU100GATIL("EV1_IMPNOM")} , "EV1_IMPNOM" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_IMPNRO" , nil , {|oModel| DU100GATIL("EV1_IMPNRO")} , "EV1_IMPNRO" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_INFCOM" , nil , {|oModel| DU100GATIL("EV1_INFCOM")} , "EV1_INFCOM" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_COIDM"  , nil , {|oModel| DU100GATIL("EV1_COIDM") } , "EV1_COIDM"  })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_URFDES" , nil , {|oModel| DU100GATIL("EV1_URFDES")} , "EV1_URFDES" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_SEGMOE" , nil , {|oModel| DU100GATIL("EV1_SEGMOE")} , "EV1_SEGMOE" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_SETOMO" , nil , {|oModel| DU100GATIL("EV1_SETOMO")} , "EV1_SETOMO" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_HAWB"   , nil , {|oModel| DU100GATIL("EVB_DETAIL")} , "EVB_DETAIL" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_HAWB"   , nil , {|oModel| DU100GATIL("EV9_DETAIL")} , "EV9_DETAIL" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_HAWB"   , nil , {|oModel| DU100GATIL("SWV_DETAIL")} , "SWV_DETAIL" })
   aAdd( aTrigger, {"EV1_HAWB" , "EV1_PAISPR" , nil , {|oModel| DU100GATIL("EV1_PAISPR")} , "EV1_PAISPR" })

return aTrigger

/*/{Protheus.doc} getInfEIJ
   Função para retornar os valores dos campos da EIJ

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param nenhum
   @return aCposLoad, vetor, vetor com os dados da EIJ para os campos da EV2
   @example
   (examples)
   @see (links_or_references)
/*/
static function getInfEIJ()
   local aCposLoad  := {}
   local aCposEV2   := strtokarr2(DU100Model("EV2_MERCADORIA",.F.), "|")
   local nCpo       := 0

   for nCpo := 1 to len(aCposEV2)
      aAdd( aCposLoad, {aCposEV2[nCpo], getValor(aCposEV2[nCpo])} )
   next

return aCposLoad

/*/{Protheus.doc} DU100AtuDUIMP
   A partir do processo de embarque/ desembaraço ou os itens da DUIMP, o sistema irá avaliar se existe alguma DUIMP para este processo com o status "Processo pendente de revisão" ou "Pendente de integração".
   O sistema irá levar em consideração os campos mapeados na função DU100Gatil() e os demais modelos de dados invocadas por ela
   Caso esteja com status "Processo pendente de Revisão", o sistema irá criar uma nova sequência, deixando a atual com status obsoleto. 
   Caso esteja com status "Pendente Integração", o sistema deverá atualizar os dados da sequência corrente.

   @type  Function
   @author user
   @since 03/01/2024
   @version version
   @param cHawb, caracter, Código do Procsso
          lValidTudo, logico, VERDADEIRO para validar tudo, ou seja, a partir do embarque/ desembaraço; FALSO somente a partir do itens da DUIMP
          lAltItens, logico, VERDADEIRO se alterou os itens do processo do embarque/ desembaraço; FALSO caso não houve alteração dos itens do processo do embarque/ desembaraço (lGravaSoCap)
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
   /*/
function DU100AtuDUIMP(cHawb, lValidTudo, lAltItens)
   local cAliasSel := alias()
   local lRet      := .T.
   local aAreaEV1  := {}
   local nRecEV1   := 0
   local cStatus   := ""
   local aLoadInfo := {}
   local nLoad     := 0
   local cInfoLoad := ""
   local cIgnoreCp := ""
   local cInfo     := ""
   local aInfo     := {}
   local lDif      := .F.

   default cHawb      := SW6->W6_HAWB
   default lValidTudo := .T.
   default lAltItens  := .F.

   dbSelectArea("EV1")
   if EV1->(columnPos("EV1_STATUS")) > 0

      aAreaEV1 := EV1->(getArea())
      EV1->(dbSetOrder(1)) // EV1_FILIAL+EV1_HAWB+EV1_LOTE
      if EV1->(AvSeekLast( xFilial("EV1") + cHawb )) .and. ( EV1->EV1_STATUS == PENDENTE_INTEGRACAO .or. EV1->EV1_STATUS == PROCESSO_PENDENTE_REVISAO .or. EV1->EV1_STATUS == PENDENTE_REGISTRO )
         nRecEV1 := EV1->(recno())
         cStatus := EV1->EV1_STATUS

         aLoadInfo := loadTrigger()

         aRetorno := {}
         cIgnoreCp := "EV1_TIPREG||EV1_SEQUEN||"
         lDif := .F.

         for nLoad := 1 to len( aLoadInfo )
            cInfoLoad := aLoadInfo[nLoad][5]
            aInfo := {}

            if cInfoLoad $ cIgnoreCp
               loop
            endif

            if lDif
               exit
            endif

            if lValidTudo

               // Comparação da EV1
               if "EV1_" $ cInfoLoad
                  cInfo := DU100Gatil(cInfoLoad, cHawb, @aInfo)
                  if( !EV1->(recno()) == nRecEV1, EV1->(dbGoTo(nRecEV1)), nil)
                  lDif := dif(cInfoLoad, EV1->&(cInfoLoad), cInfo, {"EV1_SETOMO"})

               else
                  if !(cInfoLoad == "SWV_DETAIL") // Comparação da EVB e EV9 
                     cInfo := DU100Gatil(cInfoLoad, cHawb, @aInfo)
                     if( !EV1->(recno()) == nRecEV1, EV1->(dbGoTo(nRecEV1)), nil)
                     lDif := ValidDif(cInfoLoad, aInfo)
                  endif
               endif

            endif

            if !lDif .and. (!lValidTudo .or. lAltItens)

               // Comparação da EV2, EV3, EV4, EVE, EVI e EV6
               if cInfoLoad == "SWV_DETAIL"
                  cInfo := DU100Gatil(cInfoLoad, cHawb, @aInfo)
                  if( !EV1->(recno()) == nRecEV1, EV1->(dbGoTo(nRecEV1)), nil)
                  lDif := ValidDif(cInfoLoad, aInfo)
               endif

            endif

            FwFreeArray(aInfo)

         next

         if lDif
            EV1->(dbGoTo(nRecEV1))
            if EV1->(Recno()) == nRecEV1

               DU100AtuEV( nRecEV1 , OBSOLETO)
               if cStatus == PENDENTE_INTEGRACAO .and. empty(EV1->EV1_DI_NUM) .and. empty(EV1->EV1_VERSAO)
                  _cNumLote := EV1->EV1_LOTE
                  lRet := DU100ExAuto(5)
               endif

               if (cStatus == PENDENTE_INTEGRACAO .and. lRet) .or. cStatus == PROCESSO_PENDENTE_REVISAO .or. cStatus == PENDENTE_REGISTRO
                  lRet := DU100ExAuto(3, cHawb)
               endif

            endif
         endif

      endif
      restArea(aAreaEV1)

   endif

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return lRet

/*/{Protheus.doc} ValidDif
   Função para retornar os valores dos campos da EIJ

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param nenhum
   @return aCposLoad, vetor, vetor com os dados da EIJ para os campos da EV2
   @example
   (examples)
   @see (links_or_references)
/*/
static function ValidDif(cInfoLoad, aInfo)
   local lDif       := .F.
   local aItens     := {}
   local nItens     := 0
   local aDados     := {}
   local nPosSWV    := 0
   local aDadosMod  := {}
   local cIdSWV     := ""
   local nPosIDItem := 0
   local cSeqDUIMP  := ""
   local nDados     := 0
   local cModelo    := ""
   local cTabela    := ""
   local nIndice    := 0
   local cIndice    := ""
   local cSeekTab   := ""
   local aCampos    := {}
   local lDetail    := .T.
   local aCpoIgnore := {}
   local aCposEsp   := {}
   local aInfAcrDec := {}

   default cInfoLoad  := ""
   default aInfo      := {}

   do case
      case cInfoLoad == "EVB_DETAIL"

         if len(aInfo) > 0 .and. aInfo[1] == "EVBDETAIL"
            lDif := VerifDif("EVB", 1, "EVB_FILIAL+EVB_HAWB+EVB_LOTE", (xFilial("EVB") + EV1->EV1_HAWB + EV1->EV1_LOTE), {"EVB_CODPV"}, aInfo[2])
         endif

      case cInfoLoad == "EV9_DETAIL"

         if len(aInfo) > 0 .and. aInfo[1] == "EV9DETAIL"
            lDif := VerifDif("EV9", 1, "EV9_FILIAL+EV9_HAWB+EV9_LOTE", (xFilial("EVB") + EV1->EV1_HAWB + EV1->EV1_LOTE), {"EV9_CODIN", "EV9_SEQUEN"}, aInfo[2])
         endif

      case cInfoLoad == "SWV_DETAIL"

         if len(aInfo) > 0 .and. aInfo[1] == "SWVDETAIL"
            aItens := aInfo[2]

            for nItens := 1 to len(aItens)
               aDados := aItens[nItens]
               cIdSWV := ""

               // Procura modelo SWVDETAIL
               nPosSWV := aScan( aDados, { |X| X[1] == "SWVDETAIL" } )
               if nPosSWV > 0 
                  aDadosMod := aDados[nPosSWV][2]
                  nPosIDItem := aScan( aDadosMod, {|X| X[1] == "WV_ID"} )
                  if nPosIDItem > 0
                     cIdSWV := aDadosMod[nPosIDItem][2]
                  endif
               endif

               aCpoIgnore := {"WV_NOMEFOR", "WV_NCM", "WV_DESC_DI"}
               lDif := empty(cIdSWV) .or. VerifDif("SWV", 5, "WV_FILIAL+WV_HAWB+WV_ID", (xFilial("SWV") + EV1->EV1_HAWB + cIdSWV), {"WV_HAWB", "WV_ID"}, aDadosMod, .F., aCpoIgnore)

               if !lDif .and. cIdSWV == SWV->WV_ID

                  cSeqDUIMP := SWV->WV_SEQDUIM

                  // Valida os demais modelo EV2DETAIL, EV3DETAIL, EV4DETAIL, EVEDETAIL, EVIDETAIL, EV6DETAIL
                  for nDados := 1 to len(aDados)

                     cModelo := aDados[nDados][1]
                     if cModelo == "SWVDETAIL"
                        loop
                     endif

                     aDadosMod := aDados[nDados][2]
                     cTabela := ""
                     nIndice := 0
                     cIndice := ""
                     cSeekTab := ""
                     aCampos := {}
                     lDetail := .T.
                     aCpoIgnore := {}
                     aCposEsp := {}

                     do case

                        case cModelo == "EV2DETAIL" // Mercadoria
                           cTabela := "EV2"
                           nIndice := 3
                           cIndice := "EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI"
                           cSeekTab := xFilial("EV2") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSeqDUIMP
                           aCampos := {}
                           lDetail := .F.
                           aCposEsp := {"EV2_QTCOM","EV2_QT_EST","EV2_PESOL","EV2_MOE1","EV2_VLMLE","EV2_VL_FIN"}

                        case cModelo == "EV3DETAIL" // Acréscimos e deduções
                           cTabela := "EV3"
                           nIndice := 3
                           cIndice := "EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI"
                           cSeekTab := xFilial("EV3") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSeqDUIMP
                           aCampos := {"EV3_ACRES"}
                           aCposEsp := {"EV3_VLMLE"}

                           aInfAcrDec := {}
                           aEval(aDadosMod,{|x| if( x[1] == "1", aAdd(aInfAcrDec,x[2]), )})
                           lDif := VerifDif(cTabela, nIndice, cIndice, cSeekTab, aCampos, aInfAcrDec, lDetail, aCpoIgnore, aCposEsp)

                           if !lDif
                              cTabela := "EV4"
                              nIndice := 3
                              cIndice := "EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI"
                              cSeekTab := xFilial("EV4") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSeqDUIMP
                              aCampos := {"EV4_DEDU"}
                              aCposEsp := {"EV4_VLMLE"}

                              aInfAcrDec := {}
                              aEval(aDadosMod,{|x| if( x[1] == "2", aAdd(aInfAcrDec,x[2]), )})
                              aDadosMod := aInfAcrDec
                           endif

                        case cModelo == "EVEDETAIL" // LPCO's
                           cTabela := "EVE"
                           nIndice := 2
                           cIndice := "EVE_FILIAL+EVE_LOTE+EVE_SEQDUI"
                           cSeekTab := xFilial("EVE") + EV1->EV1_LOTE + cSeqDUIMP
                           aCampos := {"EVE_LPCO"}

                        case cModelo == "EVIDETAIL" // Certificado Mercosul
                           cTabela := "EVI"
                           nIndice := 2
                           cIndice := "EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI"
                           cSeekTab := xFilial("EVI") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSeqDUIMP
                           aCampos := {"EVI_NUM"}
                           aCposEsp := {"EVI_QTDCER"}
 
                        case cModelo == "EV6DETAIL" // Documentos Vinculados
                           cTabela := "EV6"
                           nIndice := 3
                           cIndice := "EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI"
                           cSeekTab := xFilial("EV6") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSeqDUIMP
                           aCampos := {"EV6_TIPVIN"}
                        
                        case cModelo == "EVGGRID_II" // Tributos - Tabela EVG / Grid Tibuto II
                           cTabela := "EVG"
                           nIndice := 2
                           cIndice := "EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP"
                           cSeekTab := xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE + cSeqDUIMP + "1"
                           aCampos := {"EVG_FUNDLE","EVG_REGIME"}

                        case cModelo == "EVGGRID_IPI" // Tributos - Tabela EVG / Grid Tibuto IPI
                           cTabela := "EVG"
                           nIndice := 2
                           cIndice := "EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP"
                           cSeekTab := xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE + cSeqDUIMP + "2"
                           aCampos := {"EVG_FUNDLE","EVG_REGIME"}

                        case cModelo == "EVGGRID_PIS" // Tributos - Tabela EVG / Grid Tibuto PIS
                           cTabela := "EVG"
                           nIndice := 2
                           cIndice := "EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP"
                           cSeekTab := xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE + cSeqDUIMP + "3"
                           aCampos := {"EVG_FUNDLE","EVG_REGIME"}

                        case cModelo == "EVGGRID_COFINS" // Tributos - Tabela EVG / Grid Tibuto COFINS
                           cTabela := "EVG"
                           nIndice := 2
                           cIndice := "EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP"
                           cSeekTab := xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE + cSeqDUIMP + "4"
                           aCampos := {"EVG_FUNDLE","EVG_REGIME"}

                        case cModelo == "EVGGRID_ANTIDUMPING" // Tributos - Tabela EVG / Grid Tibuto ANTIDUMPING
                           cTabela := "EVG"
                           nIndice := 2
                           cIndice := "EVG_FILIAL+EVG_HAWB+EVG_LOTE+EVG_SEQDUI+EVG_IDIMP"
                           cSeekTab := xFilial("EVG") + EV1->EV1_HAWB + EV1->EV1_LOTE + cSeqDUIMP + "5"
                           aCampos := {"EVG_FUNDLE"}

                     end case

                     if !lDif .and. !empty(cTabela)
                        lDif := VerifDif(cTabela, nIndice, cIndice, cSeekTab, aCampos, aDadosMod, lDetail, aCpoIgnore, aCposEsp)
                     endif

                     FwFreeArray(aDadosMod)
                     aDadosMod := {}

                     if lDif
                        exit
                     endif
                  next

               endif

               if lDif
                  exit
               endif

            next

         endif

   end case

return lDif

/*/{Protheus.doc} VerifDif
   Função para verificar a diferença de informações

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param cTabela, caracte, tabela EV's
          nIndice, numerico, ordem da tabela
          cIndice, caracte, campos do indice
          cSeekTab, caracte, valores do seek
          aCampos, vetor, campos de chave
          aDados, vetor, array com os dados de origem
          lDetail, logico, Verdadeiro para tabelas em detalhes ou Falso para capa de processo
          aCposIgnore, vetor, vetor com campos para ignorar (virtuais)
          aCposEsp, vetor, vetor com os campos específicos (numéricos mas caracteres)
   @return lRet, lógico, verdadeiro possui diferença ou falso não possui
   @example
   (examples)
   @see (links_or_references)
/*/
static function VerifDif(cTabela, nIndice, cIndice, cSeekTab, aCampos, aDados, lDetail, aCposIgnore, aCposEsp)
   local lDif       := .F.
   local lSeek      := .F.
   local lCompara   := .F.
   local nDados     := 0
   local aCpos      := {}
   local nCpo       := 0

   default cTabela    := ""
   default nIndice    := 0
   default cIndice    := ""
   default cSeekTab   := ""
   default aCampos    := {}
   default aDados     := {}
   default lDetail    := .T.
   default aCposIgnore:= {}
   default aCposEsp   := {}

   begin sequence

   if !empty(cTabela)
      (cTabela)->(dbSetOrder(nIndice)) 
      lSeek := (cTabela)->(dbSeek( cSeekTab ))
   endif

   // Verifica se tem dados gravados na Origem mas não encontrou registro (EV's)
   lDif := len(aDados) > 0 .and. !lSeek

   if lSeek .and. !lDif

      // Verifica se não tem dados gravados na Origem mas encontrou registro (EV's)
      lDif := len(aDados) == 0

      if !lDetail

         for nCpo := 1 to len( aDados )
            if (len(aCposIgnore) == 0 .or. aScan( aCposIgnore, { |X| X == aDados[nCpo][1]} ) == 0)
               // Verificar se o campo gravado na Origem é diferente da (EV's)
               lDif := dif(aDados[nCpo][1], (cTabela)->&(aDados[nCpo][1]), aDados[nCpo][2], aCposEsp)
               if lDif
                  break
               endif
            endif
         next nCpo

      else

         while !lDif .and. (cTabela)->(!eof()) .and. (cTabela)->&(cIndice) == cSeekTab

            lCompara := .F.
            for nDados := 1 to len(aDados)

               aCpos := aDados[nDados]

               lCompara := isReg(cTabela, aCampos, aCpos)

               if lCompara

                  for nCpo := 1 to len( aCpos )
                     if aScan( aCampos, { |X| X == aCpos[nCpo][1] } ) == 0 .and. (len(aCposIgnore) == 0 .or. aScan( aCposIgnore, { |X| X == aCpos[nCpo][1]} ) == 0)
                        // Verificar se o campo gravado na Origem é diferente da (EV's)
                        lDif := dif(aCpos[nCpo][1], (cTabela)->&(aCpos[nCpo][1]), aCpos[nCpo][2], aCposEsp)
                        if lDif
                           break
                        endif
                     endif
                  next nCpo

                  exit

               endif

            next nDados

            if lCompara .and. nDados > 0 .and. nDados <= len(aDados)
               aDel( aDados, nDados)
               aSize( aDados, Len(aDados)-1 )
            endif

            (cTabela)->(dbSkip())
         end

         // Verifica se sobrou registrados gravados na Origem mas não encontrou registro (EV's)
         lDif := lDif .or. len(aDados) > 0
      endif

   endif

   end sequence

return lDif

/*/{Protheus.doc} dif
   Função para compara informação

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param cCampo, caracter, nome do campo
          cOrigem, caracter, informacao de origem
          cDestino, caracter, informacao de destino
          aCposEsp, vetor, campos com as informações específicos (numéricos mas caracteres)
   @return lRet, lógico, verdadeiro diferente ou falso não
   @example
   (examples)
   @see (links_or_references)
/*/
static function dif(cCampo, cOrigem, cDestino, aCposEsp)
   local lDif       := .F.

   default cCampo     := ""
   default cOrigem    := ""
   default cDestino   := ""
   default aCposEsp   := {}

   if valtype(cOrigem) == "C"
      // campos da EVs que são caracteres mas salvos com valores númericos
      if len(aCposEsp) > 0 .and. aScan( aCposEsp, { |X| X == cCampo }) > 0
         cDestino := val(strTran(cDestino, ",", "."))
         cOrigem := val(strTran(cOrigem, ",", "."))
      else
         cDestino := alltrim(cDestino)
         cOrigem := alltrim(cOrigem)
      endif
   endif
   lDif := !(cDestino == cOrigem)

return lDif

/*/{Protheus.doc} isReg
   Função para verifica se é o registro correto do array

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param cTabela, caractere, tabela
          aCampos, vetor, campos chave
          aCpos, vetor, campos com as informações
   @return lIsReg, lógico, verdadeiro diferente ou falso não
   @example
   (examples)
   @see (links_or_references)
/*/
static function isReg(cTabela, aCampos, aCpos)
   local lIsReg     := .T.
   local nCpo       := 0

   default aCampos    := {}
   default aCpos      := {}

   for nCpo := 1 to len( aCampos )
      if lIsReg
         nPosCpo := aScan( aCpos, { |X| X[1] == aCampos[nCpo] } ) 
         lIsReg := nPosCpo > 0
         if lIsReg
            lIsReg := (alltrim(aCpos[nPosCpo][2]) == alltrim((cTabela)->&(aCampos[nCpo])))
         endif
      endif
   next

return lIsReg

/*/{Protheus.doc} DU100ExAuto
   Função para atualizar a integração DUIMP a inclusão ou exclusão/inclusão

   @type  Static Function
   @author user
   @since 04/01/2024
   @version version
   @param nOpc, numérico, opção de manutenção
   @return lRet, lógico, verdadeiro (sucesso) ou falso (falha)
   @example
   (examples)
   @see (links_or_references)
/*/
static function DU100ExAuto(nOpc, cHawb)
   local lRet       := .T.
   local oModelo    := nil
   local oModelEV1  := nil
   local xError     := nil

   default nOpc       := 3
   default cHawb      := ""

   oModelo := FwLoadModel("EICDU100")
   oModelo:SetOperation(nOpc)
   oModelo:Activate()

   if lRet
      if nOpc == 3
         oModelEV1 := oModelo:GetModel("EV1MASTER")
         oModelEV1:SetValue("EV1_HAWB", cHawb)
      endif

      if( oModelo:VldData(), oModelo:CommitData(), ( lRet := .F. ,;
      EasyHelp(StrTran(STR0110,"####",if(nOpc==3, STR0111, STR0019)) + CRLF + if( valtype(xError := oModelo:GetErrorMessage()) == "C", ; // "Não foi possível realizar a #### da Integração DUIMP." ### "inclusão" ### "exclusão"
      alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 , CHR(10) + CHR(10) + STR0112 + ": " + allToChar( xError[6]) + CHR(10) + STR0113 + ": " + allToChar( xError[7] ) , "") ) ,STR0014,"") ) ) // "Mensagem do erro" ### "Mensagem do solução" ### "Atenção"
   endif

   oModelo:DeActivate()
   oModelo:Destroy()
   FwFreeObj(oModelo)

return lRet

/*/{Protheus.doc} DU100INI
   Função para retornar o inicializador padrão do campo. Chamada pelo dicionário SX3.
   @author THTS - Tiago Tudisco
   @since 18/07/2024
   @param cCampo - Nome do campo que esta chamando a função do Inicializador Padrão SX3.
   @return cRet - Conteudo para o inicializador padrao do campo
/*/
Function DU100INI(cCampo)
Local cRet := ""
Local oMdl := FwModelActive()

If ValType(oMdl) == "O" .And. oMdl:GetOperation() <> MODEL_OPERATION_INSERT
   Do Case
      Case cCampo == "EVG_DESCFL" //EKU - Fundamento Legal
         cRet := LP500GetInfo("EKU",1,xFilial("EKU") + EVG->EVG_FUNDLE,"EKU_FDTDES")
      Case cCampo == "EVG_DESCRE" //SJP - Regime
         cRet := LP500GetInfo("SJP",1,xFilial("SJP") + EVG->EVG_REGIME,"JP_DESC")
   EndCase
EndIf
Return cRet

/*/{Protheus.doc} DU100VdBloq
   Função para verificar se há catálogos de produtos (EK9) bloqueados. 
   @author Nícolas Castellani Brisque
   @since 20/08/2024
   @param cHawb - Hawb que será passado como parâmetro para a verificação
   @return lRet - Lógico com valor .T. caso não seja encontrado registro bloqueado e .F. caso contrário
/*/
Function DU100VdBloq(cHawb)
Local cQuery    := ""
Local cAliasQry := getNextAlias()
Local lRet

cQuery += " SELECT  "
cQuery += "   EIJ_HAWB "
cQuery += " FROM  "
cQuery += "   " + RetSqlName('EIJ') + " EIJ  "
cQuery += "   INNER JOIN " + RetSqlName('EK9') + " EK9 ON ( "
cQuery += "     EK9_FILIAL = ?  "
cQuery += "     AND EK9_IDPORT = EIJ_IDPTCP  "
cQuery += "     AND EK9.D_E_L_E_T_ = ' ' "
cQuery += "   )  "
cQuery += " WHERE  "
cQuery += "   EIJ_FILIAL      = ?  "
cQuery += "   AND EIJ_HAWB    = ?  "
cQuery += "   AND EIJ_IDPTCP != ' '  "
cQuery += "   AND EIJ.D_E_L_E_T_ = ' ' "
cQuery += "   AND ( EK9_STATUS = '4' OR "
cQuery += "         EK9_MSBLQL = '1' ) "

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1,xFilial('EK9'))
oQuery:SetString(2,xFilial('EIJ'))
oQuery:SetString(3,cHawb)
cQuery := oQuery:GetFixQuery()

fwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasQry)

lRet := IIF((cAliasQry)->(EOF()) .and. (cAliasQry)->(BOF()), .T., .F.) // Retorna .T. se não encontrou registro bloqueado

(cAliasQry)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} DU100VdRet
   Função para verificar se há catálogos de produtos (EK9) pendente de retificação. 
   @author Nícolas Castellani Brisque
   @since 20/08/2024
   @param cHawb - Hawb que será passado como parâmetro para a verificação
   @return lRet - Lógico com valor .T. caso não seja encontrado registro pendente de retificação e .F. caso contrário
/*/
Function DU100VdRet(cHawb)
Local cQuery    := ""
Local cAliasQry := getNextAlias()
Local lRet

cQuery += " SELECT  "
cQuery += "   EIJ_HAWB "
cQuery += " FROM  "
cQuery += "   " + RetSqlName('EIJ') + " EIJ  "
cQuery += "   INNER JOIN " + RetSqlName('EK9') + " EK9 ON ( "
cQuery += "     EK9_FILIAL = ?  "
cQuery += "     AND EK9_IDPORT = EIJ_IDPTCP  "
cQuery += "     AND EK9.D_E_L_E_T_ = ' ' "
cQuery += "   )  "
cQuery += " WHERE  "
cQuery += "   EIJ_FILIAL      = ?  "
cQuery += "   AND EIJ_HAWB    = ?  "
cQuery += "   AND EIJ_IDPTCP != ' '  "
cQuery += "   AND EIJ.D_E_L_E_T_ = ' ' "
cQuery += "   AND EK9_STATUS = '3' "

oQuery := FWPreparedStatement():New(cQuery)
oQuery:SetString(1,xFilial('EK9'))
oQuery:SetString(2,xFilial('EIJ'))
oQuery:SetString(3,cHawb)
cQuery := oQuery:GetFixQuery()

fwFreeObj(oQuery)
MPSysOpenQuery(cQuery, cAliasQry)

lRet := IIF((cAliasQry)->(EOF()) .and. (cAliasQry)->(BOF()), .T., .F.) // Retorna .T. se não encontrou registro bloqueado

(cAliasQry)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} DU100UpdCat
   Atualiza o catalogo de produtos para os itens que possuem catalogo desatualizados
   @author THTS - Tiago Tudisco
   @since 19/08/2024
/*/
Function DU100UpdCat(cHawb, jItens, lModel)
Local lRet := .T.
Local cChaveSW9
Local cChaveSWV
Local nI
Local aSeek
Local aDados
Local jModelo
Local jMdlSW9Rel
Local jMdlSWVRel
Local aModelSW9 := {}
Local aBkpModel

default lModel := .F.

For nI := 1 To Len(jItens['Itens'])
   // adicionando o modelo da invoice (SW9DETAIL)
   cChaveSW9 := cHawb + ;
            jItens['Itens'][nI]["INVOICE"] + ;
            jItens['Itens'][nI]["FORN"] + ;
            jItens['Itens'][nI]["FORLOJ"]
   aSeek := {}
   aAdd( aSeek , { "W9_FILIAL" ,  xFilial("SW9")                  })
   aAdd( aSeek , { "W9_HAWB"   ,  cHawb                           })
   aAdd( aSeek , { "W9_INVOICE",  jItens['Itens'][nI]["INVOICE"]  })
   aAdd( aSeek , { "W9_FORN"   ,  jItens['Itens'][nI]["FORN"]     })
   aAdd( aSeek , { "W9_FORLOJ" ,  jItens['Itens'][nI]["FORLOJ"]  })
   aDados := {}
   jMdlSW9Rel := aAddModel(@aModelSW9, "SW9DETAIL", cChaveSW9, aSeek, aDados)

   // adicionando o modelo dos itens de cada invoice (SWVDETAIL)
   cChaveSWV := cChaveSW9 + ;
            jItens['Itens'][nI]["PO_NUM"] + ;
            jItens['Itens'][nI]["POSICAO"] + ; 
            jItens['Itens'][nI]["SEQUENC"]
   aSeek := {}
   aAdd( aSeek , { "WV_FILIAL" ,  xFilial("SWV")                  })
   aAdd( aSeek , { "WV_HAWB"   ,  cHawb                           })
   aAdd( aSeek , { "WV_INVOICE",  jItens['Itens'][nI]["INVOICE"]  })
   aAdd( aSeek , { "WV_FORN"   ,  jItens['Itens'][nI]["FORN"]     })
   aAdd( aSeek , { "WV_FORLOJ" ,  jItens['Itens'][nI]["FORLOJ"]  })
   aAdd( aSeek , { "WV_PO_NUM" ,  jItens['Itens'][nI]["PO_NUM"]    })
   aAdd( aSeek , { "WV_POSICAO",  jItens['Itens'][nI]["POSICAO"]  })
   aAdd( aSeek , { "WV_SEQUENC",  jItens['Itens'][nI]["SEQUENC"]  })
   aDados := {}
   jMdlSWVRel := aAddModel(@jMdlSW9Rel, "SWVDETAIL", cChaveSWV, aSeek, aDados)

   // adicionando o modelo de dados de cada item (EIJMASTER)
   aSeek := {}
   aDados := {}
   aAdd( aDados , { "EIJ_IDPTCP",  jItens['Itens'][nI]["IDPORT"] })
   aAdd( aDados , { "EIJ_VRSACP",  LP500VATUAL(jItens['Itens'][nI]['EK9_VATUAL'], jItens['Itens'][nI]['EKD_VATUAL']) })
   aAddModel(@jMdlSWVRel, "EIJMASTER", cChaveSWV, aSeek, aDados)
Next

jModelo := JsonObject():New()
jModelo:set(aModelSW9[1])
fwfreeobj(aModelSW9)
fwfreeobj(jMdlSW9Rel)

SW6->(dbSetOrder(1))
SW6->(dbSeek(xFilial("SW6") + cHawb))
If lModel
   aBkpModel := FWModelActive()
EndIf
if !EICLP501(cHawb, jModelo, .F.)
   EasyHelp(STR0121 ,STR0014, STR0122)// "Não foi possível atualizar o Catálogo de Produtos."###"Atenção"###"Revise os Itens Duimp e faça a atualização do Catálogo de Produtos."
   lRet := .F.
endif
If lModel
   aBkpModel:Activate()
EndIf

Return lRet

/*
Funcao      : aAddModel()
Parâmetros  :
Retorno     : 
Objetivos   : Adiciona modelo de dados (EICLP500)
Autor       : Maurício Frison
Data 	      : Setembro 2022
*/ 
static function aAddModel(aModelos, cModelo, cChave, aSeek, aDados)
   local nPosChave  := 0
   local cChaveRet  := ""
   local jModel     := nil
   local jMdlChave  := nil

   default aModelos   := {}
   default cModelo    := ""
   default cChave     := ""
   default aSeek      := {}
   default aDados     := {}

   if !empty(cModelo)
      nPosModelo := aScan( aModelos, { |X| !X:GetJsonValue(cModelo, @cChaveRet) .or. !empty(cChaveRet)} )
      if nPosModelo == 0
         jModel := JsonObject():New()
         jModel[cModelo] := {}
         aAdd( aModelos, jModel )
      else
         jModel := aModelos[nPosModelo]
      endif
   endif

   if !empty(cChave)
      cChaveRet := ""
      nPosChave := aScan( jModel[cModelo], { |X| X:GetJsonValue("CHAVE", @cChaveRet) .and. cChaveRet == cChave} )
      if nPosChave == 0
         jMdlChave := JsonObject():New()
         jMdlChave["CHAVE"] := cChave
         jMdlChave["SEEK"] := aClone(aSeek)
         jMdlChave["DADOS"] := aClone(aDados)
         jMdlChave["RELACIONAMENTOS"] := {}
         aAdd( jModel[cModelo] , jMdlChave)
      else
         jMdlChave := jModel[cModelo][nPosChave]
      endif
      jMdlChave["DADOS"] := aClone(aDados)
   endif

   aSize(aDados,0)
   aSize(aSeek,0)

return jMdlChave["RELACIONAMENTOS"]


/*
Função     : GetVisions()
Objetivo   : Retorna as visões definidas para o Browse
*/
Static Function GetVisions()
   Local aVisions    := {}
   Local aColunas    := AvGetCpBrw("EV1")
   Local aContextos  := {"REGISTROS_ATIVOS", "PENDENTE_INTEGRACAO", "PENDENTE_REVISAO", "PENDENTE_REGISTRO", "DUIMP_REGISTRADA", "OBSOLETO", "EM_PROCESSAMENTO"}
   Local cFiltro     := ""
   Local oDSView
   Local i

   If aScan(aColunas, "EV1_FILIAL") == 0
      aAdd(aColunas, "EV1_FILIAL")
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
         Case cTipo == "REGISTROS_ATIVOS" .And. !lNome
            cRet := "EV1->EV1_STATUS <> '5' " //todos menos os obsoletos
         Case cTipo == "REGISTROS_ATIVOS" .And. lNome
            cRet := STR0150 //"Registros Ativos"

         Case cTipo == "PENDENTE_INTEGRACAO" .And. !lNome
            cRet := "EV1->EV1_STATUS = '1' "
         Case cTipo == "PENDENTE_INTEGRACAO" .And. lNome
            cRet := STR0136 // "Pendente de Integração" 

         Case cTipo == "PENDENTE_REVISAO" .And. !lNome
            cRet := "EV1->EV1_STATUS = '2' "
         Case cTipo == "PENDENTE_REVISAO" .And. lNome
            cRet := STR0137 // "Processo Pendente de Revisão"

         Case cTipo == "PENDENTE_REGISTRO" .And. !lNome
            cRet := "EV1->EV1_STATUS = '3' "
         Case cTipo == "PENDENTE_REGISTRO" .And. lNome
            cRet := STR0138 // "Pendente de Registro"

         Case cTipo == "DUIMP_REGISTRADA" .And. !lNome
            cRet := "EV1->EV1_STATUS = '4' "
         Case cTipo == "DUIMP_REGISTRADA" .And. lNome
            cRet := STR0139 // "Duimp Registrada"

         Case cTipo == "OBSOLETO" .And. !lNome
            cRet := "EV1->EV1_STATUS = '5' "
         Case cTipo == "OBSOLETO" .And. lNome
            cRet := STR0140 // "Obsoleto"

         Case cTipo == "EM_PROCESSAMENTO" .And. !lNome
            cRet := "EV1->EV1_STATUS = '6' "
         Case cTipo == "EM_PROCESSAMENTO" .And. lNome
            cRet :=  STR0105// "Registro em Processamento"

      EndCase

Return cRet

Static Function getGridEWK(cTributo)
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

Static Function getPaisOri(cHawb)
Local cRet := ""

SW6->(dbSetOrder(1)) //W6_FILIAL+W6_HAWB
SYR->(dbSetOrder(1)) //YR_FILIAL+YR_VIA+YR_ORIGEM+YR_DESTINO+YR_TIPTRAN
If SW6->(dbSeek(xFilial("SW6") + cHawb)) .And. SYR->(dbSeek(xFilial("SYR") + SW6->W6_VIA_TRA + SW6->W6_ORIGEM + SW6->W6_DEST))
   cRet := SYR->YR_PAIS_OR
EndIf
Return cRet

Static Function clearField()
If canUseApp() .and. oJsonPOUI:hasProperty("listaItensSWV") .And. oJsonPOUI['listaItensSWV']:hasProperty("listaItensSWV") .And. oJsonPOUI['listaItensSWV']['listaItensSWV']:hasProperty("items") .And. Len(oJsonPOUI['listaItensSWV']['listaItensSWV']['items']) > 0
   oChannel:AdvPLToJS("clearFieldsPOUI", "")
   
   cActiveID := ""
   freeObj(oJsonPOUI)
   freeObj(oFundLegal)
   FreeObj(oJsonAtt)
   FreeObj(oInfoAtt)
   FreeObj(oValorAtt)
   freeObj(oVlCodObj)
   AvZap(cTmpAtrib)

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
   cActiveID := ""
   
   TabItemNCM(cTmpAtrib)

EndIf
Return

/*
Função     : canUseApp
Objetivo   : Função para verificar se da pra abrir o App de Atributos
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function canUseApp()
Local lRet
If lAppDU100 == nil
   lRet := !IsBlind() .And. TEOpenApp(.F., .T.) .And. Len(GetApoInfo("duimp-items.app")) > 0 .And. AvFlags("FUNDAMENTO_LEGAL_ITEM") .And. EKU->(ColumnPos("EKU_ATT_FL")) > 0 .And. !IsInCallStack("DU100AtuDUIMP")
   lAppDU100 := lRet
Else
   lRet := lAppDU100
EndIf

Return lRet

/*
Objetivo   : Função para montar e formatar a tabela que será exibida no POUI
Retorno    : Nil
Autor      : Nícolas Brisque
Data       : Janeiro/2025
Revisão    :
*/
Static Function setItPOUI(aDados)
Local aColunas    := {}
Local aCampos     := {'WV_ID', 'WV_INVOICE', 'WV_PO_NUM', 'WV_POSICAO', 'WV_SEQUENC', 'WV_COD_I', 'WV_DESC_DI', 'WV_NCM', "WV_QTDE"}
Local oColuna     := jsonObject():New()
Local oJsonItens  := jsonObject():New()
Local cDecimais   := cValToChar(AvSX3("WV_QTDE", AV_DECIMAL))
Local i

   oJsonItens['listaItensSWV']            := jsonObject():New()
   oJsonItens['listaItensSWV']['columns'] := {}
   oJsonItens['listaItensSWV']['items']   := {}

   If !oJsonPOUI['listaItensSWV']:hasProperty('listaItensSWV') .Or. !oJsonPOUI['listaItensSWV']['listaItensSWV']:hasProperty('columns')
   For i := 1 to Len(aCampos)
      oColuna := jsonObject():New()
      oColuna['property']  := aCampos[i]
      oColuna['label']     := Alltrim(FWX3Titulo(aCampos[i]))
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
      oJsonItens['listaItensSWV']['items']   := aDados
      oJsonPOUI['listaItensSWV']             := oJsonItens
   Else
      aScan(aDados, {|x| aAdd(oJsonPOUI['listaItensSWV']['listaItensSWV']['items'], x)})
   EndIf

   freeObj(oJsonItens)
   freeObj(oColuna)
Return

Static Function setStPOUI(aDadosCP, aDadosLPCO)
Local nI

Default aDadosCP  := {}
Default aDadosLPCO := {}

For nI := 1 To Len(aDadosCP)
   If oJsonPOUI['listaItensSWV']:hasProperty('listaItensCatalogo')
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'][aDadosCP[nI]['id']] := aDadosCP[nI]
   Else
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'] := jSonObject():New()
      oJsonPOUI['listaItensSWV']['listaItensCatalogo'][aDadosCP[nI]['id']] := aDadosCP[nI]
   EndIf
Next

For nI := 1 To Len(aDadosLPCO)
   If oJsonPOUI['listaItensSWV']:hasProperty('listaItensLpco')
      oJsonPOUI['listaItensSWV']['listaItensLpco'][aDadosLPCO[nI]['id']] := aDadosLPCO[nI]
   Else
      oJsonPOUI['listaItensSWV']['listaItensLpco'] := jSonObject():New()
      oJsonPOUI['listaItensSWV']['listaItensLpco'][aDadosLPCO[nI]['id']] := aDadosLPCO[nI]
   EndIf
Next

Return

Static Function getSubTitle()
Local oSubTitle := jsonObject():New()
Local cCatalogo

cCatalogo := '{'+;
				'"property": "status",'+;
				'"label": "' + STR0141 + '",'+; //"Catálogo/LPCO"
				'"type": "subtitle",'+;
				'"width": "180px",'+;
				'"subtitles": ['+;
					'{'+;
						'"value": "OK",'+;
						'"color": "color-10",'+;
						'"label": "' + STR0142 + '",'+; //"Item possui Catálogo de Produtos e LPCO"
						'"content": "OK"'+;
					'},'+;
					'{'+;
						'"value": "CP",'+;
						'"color": "color-01",'+;
						'"label": "' + STR0143 + '",'+; //"Item possui Catálogo de Produtos"
						'"content": "CP"'+;
					'},'+;
					'{'+;
						'"value": "LI",'+;
						'"color": "color-05",'+;
						'"label": "' + STR0144 + '",'+; //"Item possui LPCO"
						'"content": "LI"'+;
					'},'+;
					'{'+;
						'"value": "NO",'+;
						'"color": "color-07",'+;
						'"label": "' + STR0145 + '",'+; //"Item não possui Catálogo de Produtos e LPCO"
						'"content": "NO"'+;
					'}'+;
				']'+;
			'}'

oSubTitle:fromJson(cCatalogo)
Return oSubTitle

/*
Função     : sendAttPOUI
Objetivo   : Função que faz o envio dos dados do objeto de atributos para o POUI exibir em tela
Parâmetros : oJsonAtt    - Objeto com os atributos a serem exibidos
Autor      : Tiago Tudisco/ Nicolas
Data/Hora  : Dez/2024
*/
Static Function sendAttPOUI(oJsonPOUI)
Local cPOUIJson := ""

setMsgPOUI("Atualizando informações dos atributos", "false")//"Atualizando informações dos atributos"

oJsonAtt['listaCompostos'] := {}
oInfoAtt['listaCompostos'] := {}
oJsonPOUI['listaAdicionais'] := oJsonAtt
oJsonPOUI['listaInformativos'] := oInfoAtt

oJsonPOUI['ncmInfoDesc'] := ""
oJsonPOUI['ncmInfoCod']  := ""
oJsonPOUI['activeID']    := cActiveID

oJsonPOUI['listaValores'] := oVlCodObj

cPOUIJson := StrTran(oJsonPOUI:toJson(), '".T."', 'true')
cPOUIJson := StrTran(cPOUIJson, '".F."', 'false')

oChannel:AdvPLToJS("listaAtributos", cPOUIJson)
AttDisable(.T.)
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

Static Function AttDisable(lNoEdit)
Local cNoEdit := IIF(lNoEdit, "false", "true")
lCpPOUIOK := .F.
oChannel:AdvPLToJS("alteraAtributos", cNoEdit)
Return

Static Function DU100VWAct(oView)
//Monta objeto com os valores comuns para os atributos de Catálogo e LPCO
If canUseApp() .And. oView:getOperation() <> MODEL_OPERATION_INSERT
   sendAttPOUI(oJsonPOUI)
EndIf
AttDisable(.T.)
Return Nil

/*
Função     : DUCallApp
Objetivo   : Montar o objeto de campos a ser enviado para o Angular montar a Lista de Atributos do Fundamento Legal
Retorno    : -
Parâmetros : oPanel  - Painel para a abertura da tela PO-UI
Autor      : Tiago Tudisco
Data/Hora  : 21/11/2024
*/
Static Function DUCallApp( oPanel )
	FWCallApp( "duimp-items", oPanel, , @oChannel, , "EICDU100")
Return .T.

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
      oPreLoad['msgLoading']        := STR0146 //"Aguardando embarque..."
      oPreLoad['isHideLoading']     := "false"
      oPreLoad['inclusao']          := "true"//IIF(Inclui, "true", "false")
      oPreLoad['noLabelComplementares']  := STR0147 //"Sem atributos complementares."
      oPreLoad['noLabelInformativos']    := STR0148 //"Sem atributos informativos."
      oPreLoad['noLabelAdicionais']      := STR0149 //"Sem atributos adicionais."
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


/*
Função     : setDocs
Objetivo   : Função para gerar os documentos de instrução de despacho que serão enviados na integração DUIMP
Parâmetros : cHawb     - Hawb do registro que será enviado
             lModel    - Indica se o modelo é do Angular 
             oModelDet - Modelo de detalhes do Angular
             lAddLine - Indica se deve adicionar a linha no modelo de detalhes
             aRet      - Array de retorno para os dados  
               nTamSeq   - Tamanho do campo de sequência
               nTamCodIn - Tamanho do campo de código do documento
               nTamDocTo - Tamanho do campo de documento
             cDoc      - Código do documento a ser adicionado
Retorno    : Nil Sem retorno, já atuliza o modelo de detalhes ou o array de retorno             
Autor      : Maurício Frison
Data/Hora  : 22/08/2025
*/
Static Function setDocs(cHawb, lModel, oModelDet,lAddLine, aRet,nTamSeq,nTamCodIn,nTamDocTo,cDoc)
Local nSeq := 0
Local aCposLoad := {}
Local cCodAvkey := avkey(cDoc,'EIF_CODIGO')
   EIF->(dbSeek( xFilial("EIF") + cHawb + cCodAvkey))
   Do while EIF->(!Eof()) .and. EIF->EIF_FILIAL == xFilial("EIF") .and. EIF->EIF_HAWB == cHawb .and. EIF->EIF_CODIGO == cCodAvkey
      if AvFlags('TIPOREG_DOCS_IMP') .And. EIF->EIF_TIPORE == DUIMP
         nSeq += 1
         aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
         aAdd( aCposLoad, {"EV9_CODIN", PadR(cDoc, nTamCodIn) } )
         aAdd( aCposLoad, {"EV9_DOCTO", PadR(EIF->EIF_DOCTO, nTamDocTo)} )
         if lModel
            AddLine(oModelDet, aCposLoad, lAddLine)
            lAddLine := .T.
         else
            aAdd( aRet, aClone(aCposLoad) )
         endif
      EndIf   
      EIF->(DbSkip())
   EndDo   
Return nil
