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

Static lF22Tipo := F22->(Fieldpos("F22_TIPOPF")) > 0
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

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA164' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA164' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA164' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA164' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA164' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador - Clientes'      ACTION 'FSA171WIZ("1","02","CLI")' OPERATION 4 ACCESS 0 //'Facilitador'
    ADD OPTION aRotina TITLE 'Facilitador - Fornecedores'  ACTION 'FSA171WIZ("1","02","FOR")' OPERATION 4 ACCESS 0 //'Facilitador'
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
Local oParticipante := FWFormStruct(1, "F22" )
Local oProfileFilter := Nil
Local oFilterItem := Nil

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA164',,{|oModel| updAllStatus(oModel)})

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
oModel:AddGrid( 'FISA164PARTICIPANTE', 'FISA164', oParticipante,,,,{|oParticipante| ValidDel(oParticipante)})
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

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA164', '02') )})
oParticipante:SetProperty('F22_LOJA', MODEL_FIELD_VALID, {|| Vazio(oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA")) .Or. VldCliFor(oModel:GetValue('FISA164PARTICIPANTE',"F22_TPPART"),oModel:GetValue('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue('FISA164PARTICIPANTE',"F22_LOJA"))})

// Gatilho do campo Loja do cliente/fornecedor
oParticipante:AddTrigger('F22_CLIFOR','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_CLIFOR")})
oParticipante:AddTrigger('F22_CLIFOR','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_CLIFOR")})
oParticipante:AddTrigger('F22_TPPART','F22_CLIFOR',{|| .T. },{||A164TRG(oModel,"F22_TPPART")})
oParticipante:AddTrigger('F22_TPPART','F22_LOJA',{|| .T. },{||A164TRG(oModel,"F22_TPPART")})
oParticipante:AddTrigger('F22_TPPART','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_TPPART")})
oParticipante:AddTrigger('F22_CLIFOR','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC")})
oParticipante:AddTrigger('F22_LOJA','F22_RAZSOC',{|| .T. },{||A164TRG(oModel,"F22_RAZSOC")})

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

// if !lFilters
//     //Criando um container com nome tela com 100%
//     oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
//     oView:CreateHorizontalBox( 'INFERIOR'  , 80 )
// else
//     oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
//     oView:CreateHorizontalBox( 'INFERIOR'  , 40 )
//     oView:CreateHorizontalBox( 'RODAPE1'   , 20 )
//     oView:CreateHorizontalBox( 'RODAPE2'   , 20 )
// endif

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

oParticipante:SetProperty("F22_CLIFOR",MVC_VIEW_LOOKUP,{ || A164ChgF3("F22_TPPART",oModel) })
oParticipante:SetProperty("F22_CLIFOR",MVC_VIEW_INIBROW,{ || A164TRG(oModel,"F22_RAZSOC") })

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ") 
    oView:AddUserButton( 'Facilitador - Clientes'    ,'', {|oView| FSA171WIZ("2","02","CLI")} )
    oView:AddUserButton( 'Facilitador - Fornecedores','', {|oView| FSA171WIZ("2","02","FOR")} )
EndIF

//Adiciona o botão de Legenda
If ( lProfStatus )
    oView:AddUserButton( 'Legenda', 'CLIPS', {|oModel| f164leg(oModel)} )
EndIf

Return oView

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

Local cTpPart	:= oModel:GetValue ('FISA164PARTICIPANTE',"F22_TPPART")
Local cRet      := ""

//Verifico o Tipo do Participante para Setar a consulta de Campo.

If cTpPart == '1'
    If cCmpTrigger == "F22_CLIFOR"

        cRet    := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"),"A2_LOJA")

        updAllStatus(oModel)

    ElseIf cCmpTrigger == "F22_RAZSOC"  

        If AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"))+AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet    := STR0005 //"TODOS OS FORNECEDORES"
        Else
            cRet    := POSICIONE("SA2",1,xFilial("SA2")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA"),"A2_NOME")
        EndIf 
    ElseIf cCmpTrigger == "F22_TPPART"
    
        cRet := " "
    
    EndIf 

ElseIf cTpPart == '2'

    If cCmpTrigger == "F22_CLIFOR"

        cRet    := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"),"A1_LOJA")

        updAllStatus(oModel)

    ElseIf cCmpTrigger == "F22_RAZSOC"  

        If AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR"))+AllTrim(oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA")) == "TODOS" + Replicate("Z",TamSx3("F22_LOJA")[1])
            cRet    := STR0004//"TODOS OS CLIENTES"
        Else
            cRet    := POSICIONE("SA1",1,xFilial("SA1")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_CLIFOR")+oModel:GetValue ('FISA164PARTICIPANTE',"F22_LOJA"),"A1_NOME")
        EndIf

    ElseIf cCmpTrigger == "F22_TPPART"
    
        cRet := " "
    
    EndIf 

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
Function FSA164GF22(cCodPerfil, cOper, cTpPart, cCliFor, cLoja)

Local oModel := NIL
Local oPartic := NIL
Local lRet := .F.

oModel := FWLoadModel("FISA164")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "02"))

    oModel:Activate()

    oPartic := oModel:GetModel("FISA164PARTICIPANTE")

    If cOper == "INCLUI"

        oPartic:AddLine()
        oPartic:LoadValue("F22_TPPART" , cTpPart)
        oPartic:SetValue("F22_CLIFOR" , cCliFor)
        oPartic:SetValue("F22_LOJA"   , cLoja)
        IF lF22Tipo
            oPartic:SetValue("F22_TIPOPF"   , '02')
        Endif

    ElseIf cOper == "EXCLUI"

        If oPartic:SeekLine( { {"F22_TPPART", cTpPart }, {"F22_CLIFOR", cCliFor}, {"F22_LOJA", cLoja } } )
            oPartic:DeleteLine()
        EndIf

    EndIf

    If oModel:VldData()
        lRet := oModel:CommitData()        
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

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

/*/{Protheus.doc} VldTodos
    Valida a inclusão do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oParticipante)

Local lRet      := .T.
Local lForTd    := .F.
Local lCliTd    := .F.
Local lForAv    := .F.
Local lCliAv    := .F.
Local cTpPart   := ""
Local nY
Local cPart

oModelPad   := FwModelActive()

For nY := 1 to oParticipante:Length()

    oParticipante:GoLine(nY)

    iF !oParticipante:IsDeleted()

        cTpPart := AllTrim(oParticipante:GetValue ("F22_TPPART"))
        cPart   := AllTrim(oParticipante:GetValue ("F22_CLIFOR"))

        lForTd := iif(lForTd==.F.,iif(cTpPart=="1" .and. AllTrim(cPart)=="TODOS",.t.,.f.),.T.)
        lCliTd := iif(lCliTd==.F.,iif(cTpPart=="2" .and. AllTrim(cPart)=="TODOS",.t.,.f.),.T.)

        lForAv := iif(lForAv==.F.,iif(cTpPart=="1" .and. !("TODOS" $ cPart),.t.,.f.),.T.)
        lCliAv := iif(lCliAv==.F.,iif(cTpPart=="2" .and. !("TODOS" $ cPart),.t.,.f.),.T.)

        If (lForTd .and. lForAv) .and. (lCliTd .and. lCliAv)
            exit
        ENDIF

    EndIf

Next nY

nY := 0

If (lForTd .and. lForAv) .or. (lCliTd .and. lCliAv)

    If lAutomato .or. MsgYesNo(STR0006 + chr(13)+chr(10) +;    //"Existem participantes configurados como 'TODOS' no Grid."
                STR0007 + chr(13)+chr(10) +;    //"Os participantes diferente de TODOS serão excluídos"
                STR0008, STR0001)               //"Deseja continuar?" "Perfil Tributário de Participante"

        For nY := 1 to oParticipante:Length()

        oParticipante:GoLine(nY)

            cTpPart := AllTrim(oParticipante:GetValue ("F22_TPPART"))
            cPart   := AllTrim(oParticipante:GetValue ("F22_CLIFOR"))

            iF !oParticipante:IsDeleted()

                if(!("TODOS" $ cPart) .and. (lCliTd .and. lCliAv) .and. cTpPart == "2")
                    oParticipante:DeleteLine()
                EndIf

                if(!("TODOS" $ cPart) .and. (lForTd .and. lForAv) .and. cTpPart == "1")
                    oParticipante:DeleteLine()
                EndIf
            EndIf

        Next nY
    else
        lRet := .F.
        oModelPad:SetErrorMessage(,,,,,STR0009,STR0010)
    EndIf
EndIF

Return lRet

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

	If ( lProfStatus .And. lProfOptim .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
        oProfileOptimizer := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer():new()
        oProfileOptimizer:setTypes('PARTICIPANT',cType)
        oProfileOptimizer:process()
        oProfileOptimizer:destroy()
        fwFreeObj(oProfileOptimizer)
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
