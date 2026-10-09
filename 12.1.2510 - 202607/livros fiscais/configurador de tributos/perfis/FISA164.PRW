#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA164.ch" 

//Constantes de status dos participantes

// F20_STATUS e F22_STATUS
#Define MANUAL "1"
#Define AUTOMATIZADO "2"
#Define MANUAL_EM_CONFORMIDADE "3"
#Define MANUAL_FORA_CONFORMIDADE "4"

Static lF22Tipo := cPaisLoc == "BRA" .and. AliasInDic("F22") .and. F22->(Fieldpos("F22_TIPOPF")) > 0
Static lAutomato := IsBlind()
Static lFilters := AliasInDic("CKJ") .and. AliasInDic("CKK")
Static jPrepared := Nil

// Cache: oCachePar[cFilial]["COD+LOJA+TIPO"] = "RAZAO_SOCIAL"
Static oCachePar := Nil
Static cFilAtu := ""
// Índice: oIdxPerf[cFilial][cCodPerf] = .T. (perfil carregado)
Static oIdxPerf := Nil

Static lProfStatus := F20->(FieldPos("F20_STATUS")) > 0 .And. F22->(FieldPos("F22_STATUS")) > 0 .and. FindClass('totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizerMVC')
Static oProfileOptimizerMVC := nil
Static nLimPart := 270000 // Limite de participantes na opcao alterar acima desse valor o campo razao social nao será exibido por conta de performance do framework MVC

PUBLISH MODEL REST NAME FISA164
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA164()

Cadastro de perfil tributário de participantes.
Esta rotina fará cadastro de perfis de participantes, que serão utilizadas no
motor de cálculo tributário fiscal.


@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA164()

Local   oBrowse := Nil
Private cTpPart := ""

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F20") .AND. AliasIndic("F22")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0001) // Cadastro de Perfil Tributário de Produto
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '02'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'A164OPEN(1)'     OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA164' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA164' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'A164OPEN(4)'     OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'A164OPEN(5)'     OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador - Clientes'      ACTION 'FSA171WIZ("1","02","CLI")' OPERATION 4 ACCESS 0 //'Facilitador'
    ADD OPTION aRotina TITLE 'Facilitador - Fornecedores'  ACTION 'FSA171WIZ("1","02","FOR")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

If FindFunction("FSA164DESC")
    ADD OPTION aRotina TITLE 'Altera Descricao do Perfil'  ACTION 'FSA164DESC()' OPERATION 4 ACCESS 0 //'Altera Descricao do Perfil'
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela de perfil F20
Local oCabecalho := FWFormStruct(1, "F20" )

//Estrutura do produto considerando a tabela F24
Local oParticipante  := FWFormStruct(1, "F22" )
Local oProfileFilter := Nil
Local oFilterItem    := Nil
Local nTamRazSoc     := 0

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA164',,/*{|oModel| updAllStatus(oModel)}*/)

If ( lProfStatus )
    addCmpLegend(oModel, oParticipante, .T.)
EndIf

if lFilters
    oProfileFilter := FWFormStruct(1, "CKJ")
    oFilterItem := FWFormStruct(1, "CKK")
endif

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA164",,oCabecalho)

//Adicionando o grid de participante
oModel:AddGrid( 'FISA164PARTICIPANTE', 'FISA164', oParticipante,,{|oParticipante| VldF22Grid(oParticipante)},,{|oParticipante| ValidDel(oParticipante)})
//oModel:GetModel( 'FISA164PARTICIPANTE' ):SetUseOldGrid()

//Inicializa o campo F20_TIPO com ´conteúdo "04" que significa tipo de perfil de produto
oCabecalho:SetProperty('F20_TIPO' , MODEL_FIELD_INIT ,{||"02"} )

IF lF22Tipo
    oParticipante:SetProperty('F22_TIPOPF' , MODEL_FIELD_INIT ,{||"02"} )
Endif

//Retira obrigatoriedade dos campos F24_CODIGO e F25_CODIGO
oParticipante:SetProperty('F22_CODIGO' , MODEL_FIELD_OBRIGAT,  .F. )

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oCabecalho:SetProperty('F20_DESC' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA164', '02') )})
oParticipante:SetProperty('F22_LOJA', MODEL_FIELD_VALID, {|| Vazio(oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA")) .Or. VldCliFor(oModel:GetValue('FISA164PARTICIPANTE',"F22_TPPART"),oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA"))})

nTamRazSoc := Max(FisTamSX3("SA1", "A1_NOME")[1], FisTamSX3("SA2", "A2_NOME")[1])
oParticipante:SetProperty('F22_RAZSOC', MODEL_FIELD_TAMANHO, nTamRazSoc)
oParticipante:AddTrigger('F22_TPPART','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_TPPART")})
oParticipante:AddTrigger('F22_CLIFOR','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC")})
oParticipante:AddTrigger('F22_LOJA'  ,'F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC")})

// Gatilho do campo Loja do cliente/fornecedor
oParticipante:AddTrigger('F22_CLIFOR','F22_LOJA' ,{|| .T. },{||A164TRG(oModel,"F22_CLIFOR")})
oParticipante:AddTrigger('F22_TPPART','F22_CLIFOR',{|| .T. },{||A164TRG(oModel,"F22_TPPART")})
oParticipante:AddTrigger('F22_TPPART','F22_LOJA'  ,{|| .T. },{||A164TRG(oModel,"F22_TPPART")}) 

//Relacionamento entre as tabelas F20 Perfil com F22 Participantes
oModel:SetRelation( 'FISA164PARTICIPANTE', { { 'F22_FILIAL', 'xFilial("F22")' }, { 'F22_CODIGO', 'F20_CODIGO' }, {'02','F20_TIPO'} }, F22->( IndexKey( 1 ) ) )

If lFilters
    oModel:AddGrid("FISA164FILTERS","FISA164",oProfileFilter)
    oModel:AddGrid("FISA164ITEMS","FISA164FILTERS",oFilterItem)

    // esse modelo só será usado em PO-UI. Por isso o mesmo se tornou opcional
    oModel:getModel("FISA164FILTERS"):setOptional(.T.)
    oModel:getModel("FISA164ITEMS"):setOptional(.T.)

    oModel:SetRelation( 'FISA164FILTERS', { { 'CKJ_FILIAL', 'xFilial("CKJ")' }, { 'CKJ_CODIGO', 'F20_CODIGO' }, {'CKJ_TIPOPF','F20_TIPO'} }, CKJ->( IndexKey( 2 ) ) )

    oModel:SetRelation( 'FISA164ITEMS', { { 'CKK_FILIAL', 'xFilial("CKK")' }, { 'CKK_IDFILT', 'CKJ_ID' }}, CKK->( IndexKey( 2 ) ) )
EndIf

//Define para não repetir o código de produto
oModel:GetModel( 'FISA164PARTICIPANTE' ):SetUniqueLine( { 'F22_TPPART','F22_CLIFOR','F22_LOJA'} )

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA164PARTICIPANTE'):SetMaxLine(9999999)

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tributário de Participantes

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA164" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20", {|cCampo| !(alltrim(cCampo) $ 'F20_STATUS') })
Local oParticipante	:= FWFormStruct(2, "F22")
// Local oProfileFilter := Nil
// Local oFilterItem := Nil


Local oView := Nil
Local cVersao 	:= GetVersao(.F.)

If ( lProfStatus )
    addCmpLegend(oModel, oParticipante, .F.)
EndIf

// if lFilters
//     oProfileFilter := FWFormStruct(2, "CKJ")
//     oFilterItem := FWFormStruct(2, "CKK")
// endif

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA164'         )
oView:AddGrid(  'VIEW_PARTICIPANTE'   , oParticipante    , 'FISA164PARTICIPANTE'  )

// if lFilters
//     oView:AddGrid('VIEW_CABECFILTER', oProfileFilter, "FISA164FILTERS")
//     oView:AddGrid('VIEW_ITEMFILTER', oFilterItem, 'FISA164ITEMS')
// endif

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_PARTICIPANTE', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_PARTICIPANTE', "GRIDSEEK", {.T.})


//Retira os campos da View
oCabecalho:RemoveField( 'F20_TIPO' )
oParticipante:RemoveField( 'F22_CODIGO' )

If ( lProfStatus )
    oParticipante:RemoveField( 'F22_STATUS' )
EndIf

IF lF22Tipo
    oParticipante:RemoveField('F22_TIPOPF')
Endif

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_PARTICIPANTE'     , 'INFERIOR'    )

// if lFilters
//     oView:SetOwnerView('VIEW_CABECFILTER', 'RODAPE1')
//     oView:SetOwnerView('VIEW_ITEMFILTER', 'RODAPE2')
// endif

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO' , STR0001 )
oView:EnableTitleView('VIEW_PARTICIPANTE' , STR0003 ) 

// if lFilters
//     oView:EnableTitleView('VIEW_CABECFILTER' , "Dados do filtro" )
//     oView:EnableTitleView('VIEW_ITEMFILTER' , "Itens do filtro" )
// endif

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

oParticipante:SetProperty("F22_CLIFOR", MVC_VIEW_INIBROW, {|| A164TRG(oModel,"F22_RAZSOC")})
oParticipante:SetProperty("F22_CLIFOR",MVC_VIEW_LOOKUP,{ || A164ChgF3("F22_TPPART",oModel) })

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ")
    oView:AddUserButton( 'Facilitador - Clientes'    ,'', {|oVw| FISA164RunWiz("CLI")} )
    oView:AddUserButton( 'Facilitador - Fornecedores','', {|oVw| FISA164RunWiz("FOR")} )
EndIF

//Adiciona o botão de Legenda
If ( lProfStatus )
    oView:AddUserButton( 'Legenda', 'CLIPS', {|oModel| f164leg(oModel)} )
EndIf

Return oView

/*/{Protheus.doc} FISA164RunWiz(cTpPart)
    Função estática responsável por orquestrar a abertura do wizard a partir do formulário MVC e fechar o formulário automaticamente após a conclusão:
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510
/*/
Static Function FISA164RunWiz(cTpPart)
    
    Local oFVw := FwViewActive()
    Local oMdl := FWModelActive()
    Local lRet := .T.
    Private lWizOK := .F.
    
    FSA171WIZ("2","02",cTpPart)
    
    If lWizOK
        oMdl:DeActivate()
        oMdl:SetOperation(MODEL_OPERATION_VIEW)
        oFVw:ButtonCancelAction()
        lRet := .F.
    EndIf

Return LRET

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function A164ChgF3(cCmpF3,oModel)

Local cTpPart	:= oModel:GetValue ('FISA164PARTICIPANTE',cCmpF3)
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.

If cTpPart == '1'
    cRet    := "SA2"
ElseIf cTpPart == '2'
    cRet    := "SA1"   
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function A164TRG(oModel,cCmpTrigger)

Local cTpPart := oModel:GetValue('FISA164PARTICIPANTE',"F22_TPPART")
Local cRet    := ""

If cTpPart == '1'
    If cCmpTrigger == "F22_CLIFOR"
        cRet := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR"),"A2_LOJA")
    ElseIf cCmpTrigger == "F22_RAZSOC"
        If AllTrim(oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")) + AllTrim(oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet := STR0005
        Else
            cRet := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA"),"A2_NOME")
        EndIf
    ElseIf cCmpTrigger == "F22_TPPART"
        cRet := " "
    EndIf

ElseIf cTpPart == '2'
    If cCmpTrigger == "F22_CLIFOR"
        cRet := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR"),"A1_LOJA")
    ElseIf cCmpTrigger == "F22_RAZSOC"
        If AllTrim(oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")) + AllTrim(oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet := STR0004
        Else
            cRet := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA"),"A1_NOME")
        EndIf
    ElseIf cCmpTrigger == "F22_TPPART"
        cRet := " "
    EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A164ChgF3
Função que Troca a Consulta do campo  

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCliFor(cTipo,cCliFor)

Local lRet := .F.

//Verifico o Tipo do Participante para Setar a consulta de Campo.
If AllTrim(cCliFor) == PADR("TODOS", TamSx3("F22_CLIFOR")[1]) + Replicate("Z",TamSx3("F22_LOJA")[1])
    lRet    := .T.
ElseIf cTipo == '1'
    DbSelectArea("SA2")
    DbSetOrder(1)
    If SA2->(DbSeek(xFilial("SA2")+cCliFor))
        lRet    := .T.
    EndIf 
ElseIf cTipo == '2' 
    DbSelectArea("SA1")
    DbSetOrder(1)
    If SA1->(DbSeek(xFilial("SA1")+cCliFor))
        lRet    := .T.
    EndIf 
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPerfil
    Recupera o código do perfil de participante a partir do modelo ativo (FISA164).
    Utilizado para identificar o contexto de perfil quando não passado explicitamente.

    @type  Static Function
    @author Julia Mota
    @since 14/01/2026
    @version 12.1.2510
    @return cCodPerf, Character, Código do perfil (F20_CODIGO) ou vazio se modelo não ativo.
    @example
    Local cCodPerf := GetPerfil()
    @see FWModelActive
/*/
//-------------------------------------------------------------------
Static Function GetPerfil()
    Local oModel := FwModelActive()
    
    If ValType(oModel) != "O"
        Return ""
    EndIf

Return AllTrim(oModel:GetValue("FISA164", "F20_CODIGO"))

//-------------------------------------------------------------------
/*/{Protheus.doc} A164RAZSOC
Retorna razão social do participante com cache hierárquico.

@author Erich M. Buttner
@since 19/06/2018
@version 12.1.2510
@param cTpPart, Character, Tipo: "1"=Fornecedor, "2"=Cliente
@param cCliFor, Character, Código
@param cLoja, Character, Loja
@return cRet, Character, Razão social
/*/
//-------------------------------------------------------------------
Function A164RAZSOC(cTpPart, cCliFor, cLoja, cCodPerf)
    Local cRet := ""    
    Local cFilAtual := cFilAnt
    Local cChave := ""
    Local cTipo := Iif(cTpPart == "1", "F", "C")

    // Obtém código do perfil
    Default cCodPerf := GetPerfil()

    If Empty(cCodPerf)
        Return cRet
    EndIf

    If Empty(cTpPart) .Or. Empty(cCliFor) .Or. Empty(cLoja)
        Return cRet
    EndIf
    
    cCliFor := AllTrim(cCliFor)
    
    // Valida "TODOS"
    If Upper(cCliFor + AllTrim(cLoja)) == "TODOS" + Replicate("Z", Len(cLoja))
        Return Iif(cTpPart == "1", STR0005, STR0004)
    EndIf
    
    // Sincroniza filial e limpa índice se mudou
    If cFilAtual != cFilAtu
        cFilAtu := cFilAtual
        If ValType(oIdxPerf) == "J"
            FreeObj(oIdxPerf)
            oIdxPerf := Nil
        EndIf
        If ValType(oCachePar) == "J"
            FreeObj(oCachePar)
            oCachePar := Nil
        Endif
    EndIf
    
    // Inicializa cache
    IniCache()

    If F164ExcedeLim(cCodPerf)
        Return cRet
    EndIf
    
    // Carga total se perfil não foi carregado
    If !PerfLoad(cCodPerf)
        LoadPerf(cCodPerf)
    EndIf
    
    // Busca no cache
    cChave := Alltrim(cCliFor + cLoja + cTipo)
    cRet := GetCache(cFilAtu, cChave)
    
    // Carga sob demanda se não encontrou
    If Empty(cRet)
        LoadPart(cCodPerf, cFilAtu, cTpPart, cCliFor, cLoja)
        cRet := GetCache(cFilAtu, cChave)
    EndIf
    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IniCache
    Inicializa estruturas de cache (JsonObject) para a filial corrente se não existirem.
    Garante que oCachePar e oIdxPerf estejam instanciados e prontos para uso.

    @type  Static Function
    @author Julia Mota
    @since 14/01/2026
    @version 12.1.2510
    @return Nil, N/A, Sem retorno
    @example
    IniCache()
    @see JsonObject
/*/
//-------------------------------------------------------------------
Static Function IniCache()
    If ValType(oCachePar) != "J"
        oCachePar := JsonObject():New()
    EndIf
    If ValType(oIdxPerf) != "J"
        oIdxPerf := JsonObject():New()
    EndIf
    If !oCachePar:HasProperty(cFilAtu)
        oCachePar[cFilAtu] := JsonObject():New()
    EndIf
    If !oIdxPerf:HasProperty(cFilAtu)
        oIdxPerf[cFilAtu] := JsonObject():New()
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PerfLoad
    Verifica no índice de controle se os participantes de um perfil já foram carregados em cache.
    Evita queries desnecessárias ao banco de dados.

    @type  Static Function
    @author Julia Mota
    @since 14/01/2026
    @version 12.1.2510
    @param cCodPerf, Character, Código do perfil a verificar
    @return lLoaded, Logical, .T. se já carregado, .F. caso contrário
    @example
    If !PerfLoad("000001")
        LoadPerf("000001")
    EndIf
    @see LoadPerf
/*/
//-------------------------------------------------------------------
Static Function PerfLoad(cCodPerf)
Return  oIdxPerf[cFilAtu]:HasProperty(cCodPerf)

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadPerf
    Realiza a carga massiva de todos os participantes vinculados a um perfil para o cache.
    Executa a query (via CliForJs) e marca o perfil como carregado no índice.

    @type  Static Function
    @author Julia Mota
    @since 14/01/2026
    @version 12.1.2510
    @param cCodPerf, Character, Código do perfil a carregar
    @return Nil, N/A, Sem retorno
    @example
    LoadPerf("000001")
    @see CliForJs
/*/
//-------------------------------------------------------------------
Static Function LoadPerf(cCodPerf)
    CliForJs(.T., cCodPerf, cFilAtu, "", "", "")
    oIdxPerf[cFilAtu][cCodPerf] := .T.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadPart
    Carrega um participante específico para o cache sob demanda (lazy loading).
    Utilizado quando o participante não foi encontrado na carga inicial do perfil.

    @type  Static Function
    @author Julia Mota
    @since 14/01/2026
    @version 12.1.2510
    @param cCodPerf, Character, Código do perfil
    @param cFil, Character, Filial do sistema
    @param cTpPart, Character, Tipo do participante ("1"=Forn, "2"=Cli)
    @param cCliFor, Character, Código do cliente/fornecedor
    @param cLoja, Character, Loja do cliente/fornecedor
    @return Nil, N/A, Sem retorno
    @example
    LoadPart("000001", "01", "2", "C001", "01")
    @see CliForJs
/*/
//-------------------------------------------------------------------
Static Function LoadPart(cCodPerf, cFil, cTpPart, cCliFor, cLoja)
    CliForJs(.F., cCodPerf, cFil, cTpPart, cCliFor, cLoja)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA164GF22

Função para gravação/exclusão da F22 chamada de "fora" da rotina
de cadastro

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA164GF22(cCodPerfil, cOper, cTpPart, cCliFor, cLoja, aPerfAtu, aPerfNAtu)

    Local aAreaF20    := F20->(GetArea()) as array
    Local aAreaF22    := F22->(GetArea()) as array
    Local cF22Sql     := RetSqlName("F22") as character
    Local cFilF22     := xFilial("F22") as character
    Local lRet        := .F. as logical
    Local oStmt       := Nil as object
    Local nRecno      := 0 as numeric
    Local cSql        := "" as character
    Local cLojaTodos  := Replicate("Z", TamSx3("F22_LOJA")[1]) as character

    If isF22LineEmpty(cTpPart, cCliFor, cLoja)
        RestArea(aAreaF22)
        RestArea(aAreaF20)
        Return .T.
    EndIf

    DbSelectArea("F20")
    F20->(DbSetOrder(1))

    If F20->(DbSeek(xFilial("F20") + cCodPerfil + "02"))

        If cOper == "INCLUI"

            // Valida se o participante ja existe no perfil
            cSql := " SELECT F22_CLIFOR FROM " + cF22Sql
            cSql += " WHERE F22_FILIAL = ? AND F22_CODIGO = ? AND F22_TPPART = ? AND F22_CLIFOR = ? AND F22_LOJA = ? AND D_E_L_E_T_ = ' '"

            oStmt := FwExecStatement():New(ChangeQuery(cSql))
            oStmt:SetString(1, cFilF22)
            oStmt:SetString(2, cCodPerfil)
            oStmt:SetString(3, cTpPart)
            oStmt:SetString(4, cCliFor)
            oStmt:SetString(5, cLoja)

            If !Empty(oStmt:ExecScalar("F22_CLIFOR"))
                oStmt:Destroy()
                lRet := .T.
            Else
                oStmt:Destroy()

                // Valida se o perfil possui TODOS configurado para o mesmo tipo de participante
                cSql := " SELECT F22_CLIFOR FROM " + cF22Sql
                cSql += " WHERE F22_FILIAL = ? AND F22_CODIGO = ? AND F22_TPPART = ? AND F22_CLIFOR = 'TODOS' AND F22_LOJA = ? AND D_E_L_E_T_ = ' '"
                oStmt := FwExecStatement():New(ChangeQuery(cSql))
                oStmt:SetString(1, cFilF22)
                oStmt:SetString(2, cCodPerfil)
                oStmt:SetString(3, cTpPart)
                oStmt:SetString(4, cLojaTodos)

                If !Empty(oStmt:ExecScalar("F22_CLIFOR"))
                    oStmt:Destroy()
                    If ValType(aPerfNAtu) == "A"
                        AAdd(aPerfNAtu, cCodPerfil)
                    EndIf
                    lRet := .T.
                Else
                    oStmt:Destroy()

                    DbSelectArea("F22")
                    RecLock("F22", .T.)
                    F22->F22_FILIAL := cFilF22
                    F22->F22_CODIGO := cCodPerfil
                    F22->F22_TPPART := cTpPart
                    F22->F22_CLIFOR := cCliFor
                    F22->F22_LOJA   := cLoja
                    IF lF22Tipo
                        F22->F22_TIPOPF := "02"
                    Endif
                    MsUnlock()
                    If ValType(aPerfAtu) == "A"
                        AAdd(aPerfAtu, cCodPerfil)
                    EndIf
                    lRet := .T.
                EndIf
            EndIf

        ElseIf cOper == "EXCLUI"

            // Busca o RECNO do registro a excluir
            cSql := " SELECT R_E_C_N_O_ FROM " + cF22Sql
            cSql += " WHERE F22_FILIAL = ? AND F22_CODIGO = ? AND F22_TPPART = ? AND F22_CLIFOR = ? AND F22_LOJA = ? AND D_E_L_E_T_ = ' '"

            oStmt := FwExecStatement():New(ChangeQuery(cSql))
            oStmt:SetString(1, cFilF22)
            oStmt:SetString(2, cCodPerfil)
            oStmt:SetString(3, cTpPart)
            oStmt:SetString(4, cCliFor)
            oStmt:SetString(5, cLoja)
            nRecno := oStmt:ExecScalar("R_E_C_N_O_")
            oStmt:Destroy()

            If ValType(nRecno) == "N" .And. nRecno > 0
                DbSelectArea("F22")
                F22->(DbGoTo(nRecno))
                RecLock("F22", .F.)
                DbDelete()
                MsUnlock()
            EndIf

            lRet := .T.

        EndIf

    EndIf

    RestArea(aAreaF22)
    RestArea(aAreaF20)

Return lRet

/*/{Protheus.doc} AtuTpPF02
    (Atualiza novo campo F22_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF02()

IF lF22Tipo
    cQuery := "UPDATE " +  RetSqlName('F22') + " SET F22_TIPOPF = '02' WHERE F22_FILIAL = " + ValToSql(xFilial('F22')) + " AND F22_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif


Return

/*/{Protheus.doc} F164EhTodos
    Indica se a linha do grid representa o participante generico TODOS.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 09/06/2026
    @version 12.1.2510
/*/
Static Function F164EhTodos(cCliFor, cLoja)
Return Upper(AllTrim(cCliFor) + AllTrim(cLoja)) == "TODOS" + Replicate("Z", TamSx3("F22_LOJA")[1])

/*/{Protheus.doc} VldTodos
    Valida a inclusão do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oParticipante)

    Local lRet          := .T.
    Local cTpPart       := ""
    Local cPart         := ""
    Local cLoja         := ""
    Local nY            := 0
    Local lTemTodos1    := .F.
    Local lTemEspec1    := .F.
    Local lTemTodos2    := .F.
    Local lTemEspec2    := .F.
    Local lConflito1    := .F.
    Local lConflito2    := .F.

    oModelPad := FwModelActive()

    For nY := 1 To oParticipante:Length()
        If !oParticipante:IsDeleted(nY)
            cTpPart := AllTrim(oParticipante:GetValue("F22_TPPART", nY))
            cPart   := AllTrim(oParticipante:GetValue("F22_CLIFOR", nY))
            cLoja   := AllTrim(oParticipante:GetValue("F22_LOJA",   nY))
            If F164EhTodos(cPart, cLoja)
                If cTpPart == "1"
                    lTemTodos1 := .T.
                ElseIf cTpPart == "2"
                    lTemTodos2 := .T.
                EndIf
            Else
                If cTpPart == "1"
                    lTemEspec1 := .T.
                ElseIf cTpPart == "2"
                    lTemEspec2 := .T.
                EndIf
            EndIf
        EndIf
    Next nY

    lConflito1 := lTemTodos1 .And. lTemEspec1
    lConflito2 := lTemTodos2 .And. lTemEspec2

    If !lConflito1 .And. !lConflito2
        Return lRet
    EndIf

    If lAutomato .Or. MsgYesNo(STR0006 + Chr(13) + Chr(10) + ;
                STR0007 + Chr(13) + Chr(10) + ;
                STR0008, STR0001)
        For nY := 1 To oParticipante:Length()
            If !oParticipante:IsDeleted(nY)
                cTpPart := AllTrim(oParticipante:GetValue("F22_TPPART", nY))
                cPart   := AllTrim(oParticipante:GetValue("F22_CLIFOR", nY))
                cLoja   := AllTrim(oParticipante:GetValue("F22_LOJA",   nY))
                If !F164EhTodos(cPart, cLoja)
                    If lConflito2 .And. cTpPart == "2"
                        oParticipante:GoLine(nY)
                        oParticipante:DeleteLine()
                    EndIf
                    If lConflito1 .And. cTpPart == "1"
                        oParticipante:GoLine(nY)
                        oParticipante:DeleteLine()
                    EndIf
                EndIf
            EndIf
        Next nY
    Else
        lRet := .F.
        oModelPad:SetErrorMessage(,,,,,STR0009,STR0010)
    EndIf
    
Return lRet

/*/{Protheus.doc} F164CntSql
    funcao auxiliar para manipulacao de queryes
    retorna a quantidade de registros passado pela query
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 22/05/2026
    @version 12.1.2510
    @param cQry, charcter, query a ser processada
    @param aParams, array, parametros da query para bind
    @return nret, numerico, retorna a quantidade de registros
/*/
Static Function F164CntSql(cQry, aParams)
    Local oStmt := FwExecStatement():New(ChangeQuery(cQry))
    Local cAls  := ""
    Local nRet  := 0
    Local nI    := 0

    For nI := 1 To Len(aParams)
        oStmt:SetString(nI, aParams[nI])
    Next nI

    cAls := oStmt:OpenAlias()
    If !(cAls)->(Eof())
        nRet := (cAls)->QTD
    EndIf
    (cAls)->(DbCloseArea())
    oStmt:Destroy()

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CliForJs
Popula cache de participantes.

@param lCarga, Logical, .T.=Total, .F.=Sob demanda
@param cCodPerf, Character, Código perfil
@param cFil, Character, Filial
@param cTpPart, Character, Tipo: "1"=Fornec, "2"=Cliente
@param cCliFor, Character, Código
@param cLoja, Character, Loja
@return lRet, Logical, Sucesso
/*/
//-------------------------------------------------------------------
Function CliForJs(lCarga, cCodPerf, cFil, cTpPart, cCliFor, cLoja)
    Local cAlias := GetNextAlias()
    Local cQuery := ""
    Local cChave := ""
    Local aBinds := {}
    Local cFilF22 := xFilial("F22")
    Local cFilSA1 := xFilial("SA1")
    Local cFilSA2 := xFilial("SA2")
    
    Default cTpPart := ""
    Default cCliFor := ""
    Default cLoja := ""
    
    // Monta query
    If lCarga
        cQuery := QryCarga()
        aBinds := {cFilF22, cCodPerf, cFilSA1, cFilF22, cCodPerf, cFilSA2}
    Else
        cQuery := QryPart(cTpPart)
        aBinds := {Iif(cTpPart == "1", cFilSA2, cFilSA1), cCliFor, cLoja}
    EndIf
    
    // Executa e popula cache direto na filial
    cAlias := ExecQry(cQuery, aBinds)
    
    While (cAlias)->(!Eof())
        cChave := Alltrim((cAlias)->CODIGO + (cAlias)->LOJA + (cAlias)->TIPO)        
        
        SetCache(cFil, cChave, (cAlias)->NOME)        
        
        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->(DbCloseArea())
    
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCache
Busca participante no cache.
/*/
//-------------------------------------------------------------------
Static Function GetCache(cFil, cChave)
    Local cRet := ""
    
    If oCachePar[cFil]:HasProperty(cChave)
        cRet := oCachePar[cFil][cChave]
    EndIf
    
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCache
Armazena participante no cache.
/*/
//-------------------------------------------------------------------
Static Function SetCache(cFil, cChave, cValor)
    oCachePar[cFil][cChave] := cValor
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} QryCarga
Monta query para carga completa de clientes e fornecedores
@type Static Function
@return Character, Query SQL
@author Julia Mota
@since 11/11/2025
/*/
//-------------------------------------------------------------------
Static Function QryCarga()
    Local cQuery := ""
    
    cQuery := " SELECT SA1.A1_FILIAL FILIAL, SA1.A1_COD CODIGO, SA1.A1_LOJA LOJA, "
    cQuery += "        SA1.A1_NOME NOME, 'C' TIPO "
    cQuery += " FROM " + RetSQLName("SA1") + " SA1 "
    cQuery += " INNER JOIN " + RetSQLName("F22") + " F22 "
    cQuery += "    ON F22.F22_TIPOPF = '02' "
    cQuery += "   AND F22.F22_FILIAL = ? "
    cQuery += "   AND F22.F22_CODIGO = ? "
    cQuery += "   AND F22.F22_CLIFOR = SA1.A1_COD "
    cQuery += "   AND F22.F22_LOJA = SA1.A1_LOJA "
    cQuery += "   AND F22.F22_TPPART = '2' "
    cQuery += "   AND F22.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SA1.A1_FILIAL = ? "
    cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += " UNION ALL "
    cQuery += " SELECT SA2.A2_FILIAL FILIAL, SA2.A2_COD CODIGO, SA2.A2_LOJA LOJA, "
    cQuery += "        SA2.A2_NOME NOME, 'F' TIPO "
    cQuery += " FROM " + RetSQLName("SA2") + " SA2 "
    cQuery += " INNER JOIN " + RetSQLName("F22") + " F22 "
    cQuery += "    ON F22.F22_TIPOPF = '02' "
    cQuery += "   AND F22.F22_FILIAL = ? "
    cQuery += "   AND F22.F22_CODIGO = ? "
    cQuery += "   AND F22.F22_CLIFOR = SA2.A2_COD "
    cQuery += "   AND F22.F22_LOJA = SA2.A2_LOJA "
    cQuery += "   AND F22.F22_TPPART = '1' "
    cQuery += "   AND F22.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SA2.A2_FILIAL = ? "
    cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} QryPart
Query para participante específico.
/*/
//-------------------------------------------------------------------
Static Function QryPart(cTpPart)
    Local cQuery := ""
    
    If cTpPart == "1" // Fornecedores
        cQuery := " SELECT SA2.A2_FILIAL FILIAL, SA2.A2_COD CODIGO, SA2.A2_LOJA LOJA, "
        cQuery += "        SA2.A2_NOME NOME, 'F' TIPO "
        cQuery += " FROM " + RetSQLName("SA2") + " SA2 "
        cQuery += " WHERE SA2.A2_FILIAL = ? "
        cQuery += "   AND SA2.A2_COD = ? "
        cQuery += "   AND SA2.A2_LOJA = ? "
        cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "
        
    ElseIf cTpPart == "2" // Clientes
        cQuery := " SELECT SA1.A1_FILIAL FILIAL, SA1.A1_COD CODIGO, SA1.A1_LOJA LOJA, "
        cQuery += "        SA1.A1_NOME NOME, 'C' TIPO "
        cQuery += " FROM " + RetSQLName("SA1") + " SA1 "
        cQuery += " WHERE SA1.A1_FILIAL = ? "
        cQuery += "   AND SA1.A1_COD = ? "
        cQuery += "   AND SA1.A1_LOJA = ? "
        cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
    EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecQry
Executa a query com prepared statement
@type Static Function
@param cQuery, Character, Query SQL
@param aBindParams, Array, Parâmetros para bind
@param cAlias, Character, Alias de retorno (por referência)
@return cAlias, Character, Alias da tabela temporária criada
@author Julia Mota
@since 11/11/2025
/*/
//-------------------------------------------------------------------
Static Function ExecQry(cQuery, aBindParams)	
	Local nI        := 0
    Local cMD5      := MD5(cQuery)
    Local cAliasQry := ""

    //Verifica se a query já foi preparada, se não foi prepara a query e adiciona na lista de querys preparadas.
	If Valtype(jPrepared) <> 'J'
		jPrepared := JsonObject():new()
	EndIf

	If Valtype(jPrepared[cMD5]) <> 'O'
		jPrepared[cMD5] := FwExecStatement():New(ChangeQuery(cQuery))
	EndIf

	// BIND DOS PARÂMETROS
	For nI := 1 To Len(aBindParams)
		jPrepared[cMD5]:setString(nI, aBindParams[nI])
	Next nI

	// EXECUÇÃO
	cAliasQry := jPrepared[cMD5]:OpenAlias()

Return cAliasQry

/*/{Protheus.doc} getParStCode
Função que retorna o código do status do Perfil de Participante a partir da descrição.
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 24/09/2025
@param cStatusDesc, character, Descrição do status
@return character, Retorna o código do status do Perfil de Participante
/*/
Function getParStCode(cStatusDesc)

    Do Case
        Case ( cStatusDesc == 'MANUAL' )
            Return MANUAL
        Case ( cStatusDesc == 'AUTOMATIZADO' )
            Return AUTOMATIZADO
        Case ( cStatusDesc == 'MANUAL_EM_CONFORMIDADE' )
            Return MANUAL_EM_CONFORMIDADE
        Case ( cStatusDesc == 'MANUAL_FORA_CONFORMIDADE' )
            Return MANUAL_FORA_CONFORMIDADE
    EndCase

Return ''

/*/{Protheus.doc} f164ProfOp
Função que executa o Otimizador de Perfis para o Perfil de Participante.
A chamada dessa função é realizada nos fontes MATA020EVBRA.prw e CRM980EventBRAFIS.prw na função AfterTTS().
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 29/09/2025
@param cType, character, Tipo do Perfil ('CUSTOMER' ou 'SUPPLIER')
@param nOperation, numeric, Tipo de operação (inserção ou atualização)
/*/
Function f164ProfOp(cType,nOperation)

    Local oProfileOptimizer := Nil
    Local lProfOptim := FindClass('totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer')

    If cPaisLoc == "BRA"
        If ( lProfStatus .And. lProfOptim .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
            oProfileOptimizer := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer():new()
            oProfileOptimizer:setTypes('PARTICIPANT',cType)
            oProfileOptimizer:process()
            oProfileOptimizer:destroy()
            fwFreeObj(oProfileOptimizer)
        EndIf
    EndIf

Return

/*/{Protheus.doc} objProfileOptimizerMVC
Funcao que instancia o objeto do ProfileOptimizerMVC
@type static function
@version 12.1.2510
@author Matheus Bispo
@since 07/10/2025
@param oModel, object, Modelo que contém os dados
@return nil, nil
/*/
Static Function objProfileOptimizerMVC(oModel)
    if oProfileOptimizerMVC == nil
        oProfileOptimizerMVC := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizerMVC():new(oModel, "FISA164", "FISA164PARTICIPANTE", "FISA164FILTERS", "FISA164ITEMS", "F22_STATUS", "F22_LEGEND", "02")
    endIf
Return

/*/{Protheus.doc} updAllStatus
Funcao que atualiza o status do perfil e de cada linha do grid.
@type static function
@version 12.1.2510
@author Matheus Bispo
@since 07/10/2025
@param oModel, object, Modelo que contém os dados
@param logical, logical, retorna .T.
@return nil, nil
/*/
Static Function updAllStatus(oModel)
    if lProfStatus
        objProfileOptimizerMVC(oModel)
        oProfileOptimizerMVC:setDefaultModel(oModel)
        oProfileOptimizerMVC:updAllStatus()
    endIf
Return .T.

/*/{Protheus.doc} addCmpLegend
Funcao que cria um campo de legenda
@type static function
@version 12.1.2510
@author Matheus Bispo
@since 07/10/2025
@param oModel, object, Modelo que contém os dados
@param oParticipante, object, SubModelo de Participante
@param lModel, logical, indica se e ModelDef ou ViewDef
@return nil, nil
/*/
Static Function addCmpLegend(oModel, oParticipante, lModel)
    objProfileOptimizerMVC(oModel)
    oProfileOptimizerMVC:addCmpLegend(oParticipante, lModel)
Return

/*/{Protheus.doc} f164leg
Funcao que cria a legenda
@type static function
@version 12.1.2510
@author Matheus Bispo
@since 07/10/2025
@param oModel, object, Modelo que contém os dados
@return nil, nil
/*/
Static Function f164leg(oModel)
    objProfileOptimizerMVC(oModel)
    oProfileOptimizerMVC:showLegend()
Return

/*/{Protheus.doc} getParStDesc
Função que retorna a descrição do status do Perfil de Participante a partir do código.
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 06/10/2025
@param cStatusCode, character, Código do status
@return character, Retorna a descrição do status do Perfil de Participante
/*/
Function getParStDesc(cStatusCode)

    Do Case
        Case ( cStatusCode == MANUAL )
            Return 'MANUAL'
        Case ( cStatusCode == AUTOMATIZADO )
            Return 'AUTOMATIZADO'
        Case ( cStatusCode == MANUAL_EM_CONFORMIDADE )
            Return 'MANUAL_EM_CONFORMIDADE'
        Case ( cStatusCode == MANUAL_FORA_CONFORMIDADE )
            Return 'MANUAL_FORA_CONFORMIDADE'
    EndCase

Return ''

/*/{Protheus.doc} getDesTpFil
Função que retorna a descrição do Tipo do Filtro a partir do código.
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 08/10/2025
@param cFilTypeCode, character, Código do tipo do filtro
@return character, Retorna a descrição do tipo do filtro
/*/
Function getDesTpFil(cFilTypeCode)

    Local aCombo := {}
    Local nPos :=  0
    Local cFilTypeDesc := ''

    aCombo := retSX3Box(getSx3Cache('CKJ_TIPO','X3_CBOX'),,,1)
    /*Ele retorna um array multidimensional onde cada elemento tem 3 posições, sendo :

    [1] Opção completa (ex. F=Fisica)
    [2] Código da opção (ex. F)
    [3] Descrição da opção (ex. Fisica)
    */

    If (nPos := AScan(aCombo,{|aX| aX[2] == cFilTypeCode},/*nStart*/,/*nCount*/)) > 0
        cFilTypeDesc := aCombo[nPos,3]
    EndIf

Return allTrim(cFilTypeDesc)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldF22Grid
Função de validação no commit do grid de participantes F22.
Garante que os campos F22_TPPART, F22_CLIFOR e F22_LOJA não estejam vazios, e se estiverem, a linha é deletada. 
Essa validação é necessária para evitar registros incompletos no banco, já que o modelo é editável e permite inclusão de linhas em branco vindo fora do cadastro.

@author Douglas Dourado
@since 15/04/2026
@version 12.1.17
@param oGridModel, object, Modelo do grid FISA164PARTICIPANTE
@return logical, .T. se válido, .F. se inválido
/*/
//-------------------------------------------------------------------
Function VldF22Grid(oGridModel)

    Local nLine  := 0
    Local nLines := oGridModel:GetQtdLine()
    Local cTpPart := ""
    Local cCliFor := ""
    Local cLoja   := ""

    For nLine := 1 To nLines

        // Apenas linhas inseridas nesta sessão precisam de validação.
        // Registros vindos do banco já foram gravados válidos anteriormente.
        If oGridModel:IsInserted(nLine)

            cTpPart := AllTrim(oGridModel:GetValue("F22_TPPART", nLine))
            cCliFor := AllTrim(oGridModel:GetValue("F22_CLIFOR", nLine))
            cLoja   := AllTrim(oGridModel:GetValue("F22_LOJA",   nLine))

            If !oGridModel:IsDeleted(nLine) .And. isF22LineEmpty(cTpPart, cCliFor, cLoja)
                oGridModel:DeleteLine()
            EndIf

        EndIf

    Next nLine

Return .T.

/*/{Protheus.doc} isF22LineEmpty
Função que verifica se os campos essenciais da linha do grid de participantes (F22_TPPART, F22_CLIFOR e F22_LOJA) estão vazios.
@type Function
@param cTpPart, Character, Tipo do participante
@param cCliFor, Character, Código do cliente/fornecedor
@param cLoja, Character, Loja do cliente/fornecedor
@return Logical, Retorna .T. se algum dos campos estiver vazio, .F. caso contrário
@author Douglas Dourado
@since 16/04/2026
@version 12.1.2510
*/
Function isF22LineEmpty(cTpPart, cCliFor, cLoja)
Return (Empty(cTpPart) .OR. Empty(cCliFor) .OR. Empty(cLoja))

/*/{Protheus.doc} FSA164DELF22
Função que recebe um alias com recnos da F22 que contem registros inconsistentes (com campos vazios) da tabela F22 e precisam ser deletados.
O saneamento é intencionalmennte multi-filial: remove registros inconsistentes de todas as filiais.
@type Function
@param cAlias, Character, Alias da tabela F22 com os recnos a serem deletados
@author Douglas Dourado
@since 16/04/2026
@version 12.1.2510
*/
Function FSA164DELF22(cAlias)

    DbSelectArea("F22")
    While ( !(cAlias)->(EoF()) ) // Percorre o alias para deletar os registros que foram identificados como inconsistentes (com campos vazios) na carga do FISA170.

        If ( (cAlias)->RECNO > 0 ) 
            F22->( DbGoto((cAlias)->RECNO) )
            
            If RecLock("F22", .F.)
                F22->(dbDelete())
                MsUnLock()
            EndIf
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    F22->(FkCommit())
Return

/*/{Protheus.doc} SanitizaF22
Função que sanitiza a tabela F22 - Perfil de Participante, removendo registros órfãos e corrigindo inconsistências. 
@type Static Function
@author Douglas Dourado
@since 16/04/2026
@version 12.1.2510
/*/
Function SanitizaF22()
	Local cQuery := ""
	Local cAlias := ""
	Local oStatement := Nil
	Local aArea := GetArea()

	// Verifica se existem registros com campos vazios
	cQuery := " SELECT F22.R_E_C_N_O_  as RECNO "
	cQuery += " FROM " + RetSqlName("F22") + " F22 "
	cQuery += " WHERE F22.D_E_L_E_T_ = ? "
	cQuery += " AND ( F22.F22_TPPART = ? OR F22.F22_CLIFOR = ? OR F22.F22_LOJA = ? "
	cQuery += " OR NOT EXISTS (SELECT 1 FROM " + RetSqlName("F20") + " F20E "
	cQuery += " WHERE F20E.F20_FILIAL = F22.F22_FILIAL "
	cQuery += " AND F20E.F20_CODIGO = F22.F22_CODIGO "
	cQuery += " AND F20E.F20_TIPO   = '02' "
	cQuery += " AND F20E.D_E_L_E_T_ = ' ') ) "

	oStatement := FwExecStatement():New( ChangeQuery(cQuery) )
	oStatement:SetString(1, " ") // D_E_L_E_T_
	oStatement:SetString(2, "") // F22_TPPART
	oStatement:SetString(3, "") // F22_CLIFOR
	oStatement:SetString(4, "") // F22_LOJA

	cAlias := oStatement:OpenAlias()

	If !(cAlias)->(Eof())
		FSA164DELF22(cAlias) // Chama funcao que deleta os registros inconsistentes da tabela de Perfil de Participante (F22)
	EndIf

	(cAlias)->(DbCloseArea())

	oStatement:Destroy()
	oStatement := Nil

	RestArea(aArea)

Return

/*/{Protheus.doc} A164OPEN
    Funcao que monta um browser FWbrowser usado para substituir
    as chamadas em MVC de Vizualizacao e Cópia
    @type  Function
    @author Ricardo Henrique de Mello Lima
    @since 25/05/2026
    @version 12.1.2510
    @param nOption, numeric, Define qual a operacao está acontecendo
    Sendo 1 para Vizualizacao e 5 para Copia
    @return implicita, logica, true
    /*/
Function A164OPEN(nOption as numeric)
    
    Local oDlgPart   := nil as object
    Local oBrwPart   := nil as object
    Local oSize      := nil as object
    Local oPanelTop  := nil as object
    Local oPanelBot  := nil as object
    Local oGetCod    := nil as object
    Local oGetNome   := nil as object
    Local oColumn    := nil as object
    Local aSeek      := {} as array
    Local aFields    := {} as array
    Local cQry       := "" as character
    Local cNome      := F20->F20_DESC as character
    Local cCod       := F20->F20_CODIGO as character
    Local cFilF22    := xFilial("F22") as character
    Local cFilSA1    := xFilial("SA1") as character
    Local cFilSA2    := xFilial("SA2") as character
    Local cAlsTemp   := GetNextAlias() as character
    Local oTempPart  := FWTemporaryTable():New(cAlsTemp) as object
    Local aTempFlds  := {} as array
    Local lAction    := .F. as logical
    Local lOk        := .T. as logical
    Local cTempSql   := "" as character
    Local cTitulo    := "" as character
    Local cAcao      := "" as character
    
    Default nOption := 1
   
    if nOption == 1
        cAcao := "VIZUALIZAR"
    elseif nOption == 5
        cAcao := "COPIAR"
    elseif nOption == 4
        cAcao := "EXCLUIR"
    endif       

    cTitulo   := "Perfil Tributário de Participantes - " + cAcao
    
    AAdd(aSeek,{ GETSX3CACHE("F22_CLIFOR","X3_TITULO"),;
                {{ "F22_CLIFOR",;
                GETSX3CACHE("F22_CLIFOR","X3_TIPO"),;
                GETSX3CACHE("F22_CLIFOR","X3_TAMANHO"),;
                GETSX3CACHE("F22_CLIFOR","X3_DECIMAL"),;
                GETSX3CACHE("F22_CLIFOR","X3_TITULO"),;
                GETSX3CACHE("F22_CLIFOR","X3_PICTURE"),;
                }},;
                1})
    
    AAdd(aSeek,{ GETSX3CACHE("F22_RAZSOC","X3_TITULO"),;
                {{ "F22_RAZSOC",;
                GETSX3CACHE("F22_RAZSOC","X3_TIPO"),;
                GETSX3CACHE("F22_RAZSOC","X3_TAMANHO"),;
                GETSX3CACHE("F22_RAZSOC","X3_DECIMAL"),;
                GETSX3CACHE("F22_RAZSOC","X3_TITULO"),;
                GETSX3CACHE("F22_RAZSOC","X3_PICTURE"),;
                }},;
                1})
    
    aAdd(aFields, "F22_TPPART")
    aAdd(aFields, "F22_CLIFOR")
    aAdd(aFields, "F22_LOJA"  )
    aAdd(aFields, "F22_NOME"  )
    
    cQry := " SELECT"
    cQry += "     F22.F22_TPPART,"
    cQry += "     F22.F22_CLIFOR,"
    cQry += "     F22.F22_LOJA,"
    cQry += "     COALESCE(SA1.A1_NOME, F22.F22_CLIFOR) AS NOME,"
    cQry += "     F22.R_E_C_N_O_ AS F22_RECNO"
    cQry += " FROM " + RetSqlName("F22") + " F22"
    cQry += " LEFT JOIN " + RetSqlName("SA1") + " SA1"
    cQry += "     ON  SA1.A1_FILIAL = " + ValToSQL(cFilSA1)
    cQry += "     AND SA1.A1_COD    = F22.F22_CLIFOR"
    cQry += "     AND SA1.A1_LOJA   = F22.F22_LOJA"
    cQry += "     AND SA1.D_E_L_E_T_ = ' '"
    cQry += " WHERE F22.F22_FILIAL = " + ValToSQL(cFilF22)
    cQry += "   AND F22.F22_CODIGO = " + ValToSQL(cCod)
    cQry += "   AND F22.F22_TPPART = '2'"
    cQry += "   AND F22.D_E_L_E_T_ = ' '"
    cQry += " UNION ALL"
    cQry += " SELECT"
    cQry += "     F22.F22_TPPART,"
    cQry += "     F22.F22_CLIFOR,"
    cQry += "     F22.F22_LOJA,"
    cQry += "     COALESCE(SA2.A2_NOME, F22.F22_CLIFOR) AS NOME,"
    cQry += "     F22.R_E_C_N_O_ AS F22_RECNO"
    cQry += " FROM " + RetSqlName("F22") + " F22"
    cQry += " LEFT JOIN " + RetSqlName("SA2") + " SA2"
    cQry += "     ON  SA2.A2_FILIAL = " + ValToSQL(cFilSA2)
    cQry += "     AND SA2.A2_COD    = F22.F22_CLIFOR"
    cQry += "     AND SA2.A2_LOJA   = F22.F22_LOJA"
    cQry += "     AND SA2.D_E_L_E_T_ = ' '"
    cQry += " WHERE F22.F22_FILIAL = " + ValToSQL(cFilF22)
    cQry += "   AND F22.F22_CODIGO = " + ValToSQL(cCod)
    cQry += "   AND F22.F22_TPPART = '1'"
    cQry += "   AND F22.D_E_L_E_T_ = ' '"
    
    AAdd(aTempFlds, {"F22_TPPART", "C", TamSX3("F22_TPPART")[1], 0})
    AAdd(aTempFlds, {"F22_CLIFOR", "C", TamSX3("F22_CLIFOR")[1], 0})
    AAdd(aTempFlds, {"F22_LOJA",   "C", TamSX3("F22_LOJA")[1],   0})
    AAdd(aTempFlds, {"F22_NOME",   "C", 255, 0})
    AAdd(aTempFlds, {"F22_RECNO",  "N", 15,  0})
    
     FWMsgRun(, {|oSay|;
        oSay:SetText("Preparando estrutura..."),;
        oTempPart:SetFields(aTempFlds),;
        oTempPart:AddIndex(cValToChar(StrZero(1,2)),{"F22_CLIFOR"}),;
        oTempPart:AddIndex(cValToChar(StrZero(2,2)),{"F22_NOME"}),;
        oTempPart:Create(),;
        cTempSql := oTempPart:GetRealName(),;
        FkCommit();
    }, "Aguarde", "Preparando...")

    If cValToChar(nOption) $ "4/5"
        FWMsgRun(, {|oSay|;
            oSay:SetText("Carregando prévia de participantes (primeiros 1000)..."),;
            TCSqlExec("INSERT INTO " + cTempSql + " (F22_TPPART, F22_CLIFOR, F22_LOJA, F22_NOME, F22_RECNO)" + ;
                " SELECT T2.F22_TPPART, T2.F22_CLIFOR, T2.F22_LOJA, T2.NOME, T2.F22_RECNO" + ;
                " FROM (SELECT T.*, ROW_NUMBER() OVER (ORDER BY T.F22_TPPART, T.F22_CLIFOR) AS RNPREV" + ;
                "       FROM (" + cQry + ") T) T2" + ;
                " WHERE T2.RNPREV <= 1000"),;            
            FkCommit();
        }, "Aguarde", "Carregando participantes... Esta operação pode levar alguns minutos dependendo da quantidade de registros.")
    Elseif nOption == 1
        FWMsgRun(, {|oSay|;
            oSay:SetText("Carregando participantes... Esta operação pode levar alguns minutos dependendo da quantidade de registros."),;
            TCSqlExec("INSERT INTO " + cTempSql + " (F22_TPPART, F22_CLIFOR, F22_LOJA, F22_NOME, F22_RECNO)" + cQry),;         
            FkCommit();
        }, "Aguarde", "Carregando participantes... Esta operação pode levar alguns minutos dependendo da quantidade de registros.")
    EndIf

    oSize := FwDefSize():New(.T.,.F.,,)
    oSize:lProp    := .T.
    oSize:aMargins := { 0, 0, 0, 0 }
    oSize:Process()
    
    If nOption == 5
        cCod  := Space(GETSX3CACHE("F20_CODIGO","X3_TAMANHO"))
        cNome := Space(GETSX3CACHE("F20_DESC","X3_TAMANHO"))
    EndIf
    
    DEFINE MSDIALOG oDlgPart TITLE cTitulo From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
    
    If nOption == 5
        EnchoiceBar(oDlgPart,;
            {|| lAction := .T.,;
                FWMsgRun(, {|| lOk := A164Copia(cCod, cNome) },;
                "Aguarde",;
                "Copiando perfil de participantes... Esta operação pode levar alguns minutos dependendo da quantidade de registros."),;
                If(lOk, oDlgPart:End(), Nil) },;
            {|| lAction := .F., oDlgPart:End()},,)
    Elseif nOption == 4
        EnchoiceBar(oDlgPart,;
            {|| lAction := .T.,;
                FWMsgRun(, {|| lOk := A164Excluir(cCod) },;
                "Aguarde",;
                "Excluindo perfil de participantes... Esta operação pode levar alguns minutos dependendo da quantidade de registros."),;
                If(lOk, oDlgPart:End(), Nil) },;
            {|| lAction := .F., oDlgPart:End()},,)
    Elseif nOption == 1
        EnchoiceBar(oDlgPart,;
            {|| lAction := .T., oDlgPart:End()},;
            {|| lAction := .F., oDlgPart:End()},,)
    EndIf
    
    oPanelTop := TPanel():New(0,0,'',oDlgPart,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelTop:Align   := CONTROL_ALIGN_TOP
    oPanelTop:nHeight := 100
    oPanelBot := TPanel():New(0,0,'',oDlgPart,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT
    oGetCod  := TGet():New(15, 10,{ |u| If(PCount() == 0,cCod,cCod:=u) }, oPanelTop,100,10,"@!",{|| },0,,,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,cCod,,,,,,,"Codigo",1 )
    oGetCod:lReadOnly := !nOption == 5
    oGetNome := TGet():New(15,200,{ |u| If(PCount() == 0,cNome,cNome:=u) }, oPanelTop,300,10,"@!",{|| },0,,,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,cNome,,,,,,,"Nome",1)
    oGetNome:lReadOnly := !nOption == 5
    
    oBrwPart := FWBrowse():New()
    oBrwPart:SetDescription("Participantes")
    oBrwPart:SetDataTable()
    oBrwPart:SetAlias(cAlsTemp)
    oBrwPart:SetSeek(, aSeek)
    oBrwPart:SetOwner(oPanelBot)
    oBrwPart:DisableReport()
    oBrwPart:DisableFilter()
    oBrwPart:DisableConfig()
    oBrwPart:DisableSaveConfig()
    oBrwPart:AddLegend("F22_TPPART == '2'", "GREEN",  "Cliente"    )
    oBrwPart:AddLegend("F22_TPPART == '1'", "YELLOW", "Fornecedor" )
    
    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFields[2] + " }"))
    oColumn:SetSize(GETSX3CACHE("F22_CLIFOR", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F22_CLIFOR", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F22_CLIFOR", "X3_TITULO"))
    oBrwPart:SetColumns({oColumn})
    
    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFields[3] + " }"))
    oColumn:SetSize(GETSX3CACHE("F22_LOJA", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F22_LOJA", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F22_LOJA", "X3_TITULO"))
    oBrwPart:SetColumns({oColumn})
    
    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFields[4] + " }"))
    oColumn:SetSize(GETSX3CACHE("F22_RAZSOC", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F22_RAZSOC", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F22_RAZSOC", "X3_TITULO"))
    oBrwPart:SetColumns({oColumn})
    
    oBrwPart:Activate()
    
    ACTIVATE MSDIALOG oDlgPart CENTERED

    oBrwPart:Deactivate()
    oTempPart:Delete()
    FreeObj(oTempPart)
    FreeObj(oBrwPart)
    FreeObj(oDlgPart)
Return

/*/{Protheus.doc} A164Copia
    Função responsavel por fazer a cópia do prefil de participante Usado
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 25/05/2026
    @version 12.1.2510
    @param cCods, Character, o Novo Código Do perfil
    @param cNome, Character, O Novo Nome do Perfil
    @return lOk, logico, Retorno True se copio de forma correta e Falso se deu erro na copia
/*/
Static Function A164Copia(cCod as character ,cNome as character )
    
    Local aAreaF20  := F20->(GetArea()) as array
    Local cF22Sql   := RetSqlName("F22") as character
    Local cQry      := "" as character
    Local lOk       := .T. as logical
    Local aF20Copia := {} as array
    Local oModel    := nil as object
    Local cMsgErro  := "" as character

    Default cCod  := ""
    Default cNome := ""

    aAdd(aF20Copia, F20->F20_FILIAL)
    aAdd(aF20Copia, F20->F20_CODIGO)
    aAdd(aF20Copia, F20->F20_DESC)
    aAdd(aF20Copia, F20->F20_TIPO)
    aAdd(aF20Copia, F20->F20_NATOPE)
    aAdd(aF20Copia, F20->F20_STATUS)

    oModel := FWLoadModel("FISA164")
    oModel:GetModel("FISA164PARTICIPANTE"):SetOptional(.T.)
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("FISA164", "F20_FILIAL", aF20Copia[1])
    oModel:SetValue("FISA164", "F20_CODIGO", cCod)
    oModel:SetValue("FISA164", "F20_DESC",   cNome)
    oModel:SetValue("FISA164", "F20_TIPO",   aF20Copia[4])

    If oModel:VldData()
        lOk := oModel:CommitData()
    Else
        lOk      := .F.
        cMsgErro := "Erro ao gravar F20: " + AllTrim(oModel:GetErrorMessage()[6])
    EndIf
    oModel:DeActivate()
    FreeObj(oModel)

    If lOk
        cQry := " INSERT INTO " + cF22Sql + " ("
        cQry +=     " R_E_C_N_O_, F22_FILIAL, F22_CODIGO, F22_TPPART,"
        cQry +=     " F22_CLIFOR, F22_LOJA, F22_TIPOPF, F22_STATUS,"
        cQry +=     " D_E_L_E_T_, R_E_C_D_E_L_"
        cQry += " ) SELECT"
        cQry +=     " COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF22Sql + "), 0)"
        cQry +=     " + ROW_NUMBER() OVER (ORDER BY SRC.F22_TPPART, SRC.F22_CLIFOR, SRC.F22_LOJA),"
        cQry +=     " SRC.F22_FILIAL,"
        cQry +=     " " + ValToSQL(cCod) + ","
        cQry +=     " SRC.F22_TPPART, SRC.F22_CLIFOR, SRC.F22_LOJA,"
        cQry +=     " SRC.F22_TIPOPF, SRC.F22_STATUS,"
        cQry +=     " ' ', 0"
        cQry += " FROM " + cF22Sql + " SRC"
        cQry += " WHERE SRC.F22_FILIAL = " + ValToSQL(xFilial("F22"))
        cQry += "   AND SRC.F22_CODIGO = " + ValToSQL(aF20Copia[2])
        cQry += "   AND SRC.D_E_L_E_T_ = ' '"
        TcSqlExec(cQry)
    EndIf

    If !Empty(cMsgErro)
        Help(,, "HELP",, cMsgErro, 1, 0)
    EndIf

    If lOk
        TcRefresh(cF22Sql)
    EndIf

    RestArea(aAreaF20)

Return lOk


/*/{Protheus.doc} A164Excluir
    (long_description)
    @type  Funcao responsavel por excluir o Perfil 
    @author Ricardo Henrique de Mello Lima
    @since 26/05/2026
    @version 12.1.2510
    @param cCods, Character, o Novo Código Do perfil
    @return lOk, logico, Retorno True se Excluiu de forma correta e Falso se deu erro na exclusao
/*/
Static Function A164Excluir(cCod as character)
 
    Local aAreaF20  := F20->(GetArea()) as array
    Local cF20Sql   := RetSqlName("F20") as character
    Local cF22Sql   := RetSqlName("F22") as character
    Local oStmt     := Nil as object
    Local cAliasChk := "" as character

    Default cCod  := ""

    // Pre-validacao: replica o check de integridade referencial do SX7
    // que o modelo faria - F2B referencia F20 via F2B_PERFPA
    oStmt := FwExecStatement():New(ChangeQuery(;
        " SELECT F2B_PERFPA FROM " + RetSqlName("F2B") + ;
        " WHERE F2B_FILIAL = ? AND F2B_PERFPA = ? AND D_E_L_E_T_ = ' '"))
    oStmt:SetString(1, xFilial("F2B"))
    oStmt:SetString(2, cCod)
    cAliasChk := oStmt:OpenAlias()

    If !(cAliasChk)->(Eof())
        (cAliasChk)->(DbCloseArea())
        oStmt:Destroy()
        RestArea(aAreaF20)
        Help(,, "HELP",, "Violacao de Integridade. Foi encontrada referencia de " + ;
            "Cod. Perfil (F20_CODIGO) + Tipo Perfil (F20_TIPO) na tabela F2B - " + ;
            "Regra Tributaria. Formulario FISA164", 1, 0)
        Return .F.
    EndIf

    (cAliasChk)->(DbCloseArea())
    oStmt:Destroy()

    // Exclui todos os participantes em uma unica operacao SQL
    TcSqlExec("UPDATE " + cF22Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
              " WHERE F22_FILIAL = " + ValToSQL(xFilial("F22")) + ;
              "   AND F22_CODIGO = " + ValToSQL(cCod) + ;
              "   AND F22_TIPOPF = '02'" + ;
              "   AND D_E_L_E_T_ = ' '")

    If lFilters
        TcSqlExec("UPDATE " + RetSqlName("CKK") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
                  " WHERE CKK_FILIAL = " + ValToSQL(xFilial("CKK")) + ;
                  "   AND CKK_IDFILT IN (" + ;
                  "       SELECT CKJ_ID FROM " + RetSqlName("CKJ") + ;
                  "       WHERE CKJ_FILIAL = " + ValToSQL(xFilial("CKJ")) + ;
                  "       AND CKJ_CODIGO = " + ValToSQL(cCod) + ;
                  "       AND CKJ_TIPOPF = '02'" + ;
                  "       AND D_E_L_E_T_ = ' ')" + ;
                  "   AND D_E_L_E_T_ = ' '")

        TcSqlExec("UPDATE " + RetSqlName("CKJ") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
                  " WHERE CKJ_FILIAL = " + ValToSQL(xFilial("CKJ")) + ;
                  "   AND CKJ_CODIGO = " + ValToSQL(cCod) + ;
                  "   AND CKJ_TIPOPF = '02'" + ;
                  "   AND D_E_L_E_T_ = ' '")
    EndIf

    TcSqlExec("UPDATE " + cF20Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
              " WHERE F20_FILIAL = " + ValToSQL(xFilial("F20")) + ;
              "   AND F20_CODIGO = " + ValToSQL(cCod) + ;
              "   AND F20_TIPO   = '02'" + ;
              "   AND D_E_L_E_T_ = ' '")

    TcRefresh(cF22Sql)
    TcRefresh(cF20Sql)

    RestArea(aAreaF20)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} F164ExcedeLim
    Verifica se o total de participantes de um perfil ultrapassa o limite
    definido em nLimPart. O resultado é armazenado em cache (oIdxPerf)
    para evitar consultas repetidas ao banco durante o LOADLINEGRID.

    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 26/05/2026
    @version 12.1.2510
    @param cCodPerf, Character, Código do perfil a verificar
    @return lExcede, Logical, .T. se o perfil ultrapassa nLimPart participantes
/*/
//-------------------------------------------------------------------
Static Function F164ExcedeLim(cCodPerf)
    Local cChave  := "LIM_" + AllTrim(cCodPerf) as character
    Local lExcede := .F. as logical
    IniCache()
    If oIdxPerf[cFilAtu]:HasProperty(cChave)
        lExcede := oIdxPerf[cFilAtu][cChave]
    Else
        lExcede := F164CntSql(;
            "SELECT COUNT(*) QTD FROM " + RetSQLName("F22") + ;
            " WHERE F22_FILIAL = ? AND F22_CODIGO = ? AND D_E_L_E_T_ = ' '",;
            {xFilial("F22"), AllTrim(cCodPerf)}) > nLimPart
        oIdxPerf[cFilAtu][cChave] := lExcede
    EndIf
Return lExcede

/*/{Protheus.doc} FSA166DESA
    Altera a Descrição do Perfil de Participantes
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 10/04/2026
    @version 12.1.2510  
    @param cDesc, Character, Descricao do Perfil a verificar
/*/
Static Function FSA164DESA(cDesc as character)
    if !Empty(cDesc)
        F20->(RecLock("F20",.F.))
        F20->(F20_DESC) := cDesc
        F20->(MsUnlock())
    endif    
Return


/*/{Protheus.doc} FSA166DESC
    Altera a Descrição do Perfil
    @type  Function
    @author Ricardo Herique de Mello Lima
    @since 10/04/2026
    @version 12.1.2510
    @Observacao Foi detectado que quando se altera a Descrição do 
    Perfil com um Grid com Milhoes de Registro o Modelo sofre udegradacao de performance
    degradando a experiencia do usuário, por esse motivo para alterar a Descrição do modelo\
    se faz necessário uma rotina externa que não carregue todo modelo em memoria 
    /*/
Function FSA164DESC()
    
	Local cTitulo := "Descrição do Perfil" as character
	Local aButtons := {} as array
	Local cDesc := Space(FWSX3Util():GetFieldStruct("F20_DESC")[3]) as character
	Local lHasButton as logical
	Local oModalDesc := nil as object
	Local oContainer := nil as object
	Local oGetDesc as object
		
	aAdd(aButtons,{,"Alterar",{|| FSA164DESA(cDesc),oModalDesc:DeActivate()},,1,.T.,.T.})

	oModalDesc := FWDialogModal():New()
	oModalDesc:SetEscClose(.T.)
	oModalDesc:setTitle(cTitulo)
	oModalDesc:setSize(80, 250)
	oModalDesc:createDialog()
	oModalDesc:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModalDesc:getPanelMain() )
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oGetDesc := TGet():New( 05, 05,{ | u | If( PCount() == 0, cDesc, cDesc := u ) },;
		oContainer,240, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cDesc",,,,lHasButton,,,,1)

	oModalDesc:addButtons(aButtons)
	oModalDesc:Activate()
 
Return 
