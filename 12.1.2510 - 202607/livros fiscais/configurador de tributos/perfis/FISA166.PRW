#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA166.ch" 

Static lF24Tipo := (cPaisLoc == "BRA" .and. AliasInDic("F24") .and. F24->(Fieldpos("F24_TIPOPF")) > 0 )
Static lF25Tipo  := (cPaisLoc == "BRA" .and. AliasInDic("F25") .and. F25->(Fieldpos("F25_TIPOPF")) > 0 )
Static lAutomato := IsBlind()
Static oJSPROD    := Nil  // Cache: oJSPROD[cFilial][xFilial("SB1")+cCodPro] = cDescr
Static oIdxProd   := Nil  // Indice: oIdxProd[cFilial][cCodPerf] = .T. (perfil carregado)
Static jPrep166   := Nil  // Prepared statements reutilizaveis
Static cFilAtu    := " "
Static lProfStatus := cPaisLoc == "BRA" .and. AliasInDic("F20") .and. AliasInDic("F24") .And. F20->(FieldPos("F20_STATUS")) > 0 .And. F24->(FieldPos("F24_STATUS")) > 0 .And. FindClass('totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizerMVC')
Static oProfileOptimizerMVC := nil
Static lFilters := AliasInDic("CKJ") .and. AliasInDic("CKK")

PUBLISH MODEL REST NAME FISA166

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA166()

Cadastro de perfil tributário de produto.
Esta rotina fará cadastro de perfis de produto, que serão utilizadas no
motor de cálculo tributário fiscal.

Teremos neste perfil o relacionamento dos códigos de produtos bem como
as origens que compoem este perfil

Esta rotina estará disponível somente na versão 12.

@author Erick G. Dias
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA166()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F20") .AND. AliasIndic("F24") .AND. AliasIndic("F25")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0002) // Cadastro de Perfil Tributário de Produto
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '04'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0001,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'A166OPEN(1)'     OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA166' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA166' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'A166OPEN(4)'     OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'A166OPEN(5)'     OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","04")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

If FindFunction("FSA166DESC")
    ADD OPTION aRotina TITLE 'Altera Descricao do Perfil'  ACTION 'FSA166DESC()' OPERATION 4 ACCESS 0 //'Altera Descricao do Perfil'
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela de perfil F20
Local oCabecalho := FWFormStruct(1, "F20")

//Estrutura do produto considerando a tabela F24
Local oProduto := FWFormStruct(1, "F24" )

//Estrutura da origem considerando a tabela F25
Local oOrigem := FWFormStruct(1, "F25" )

Local oProfileFilter := Nil
Local oFilterItem := Nil

if lFilters
    oProfileFilter := FWFormStruct(1, "CKJ")
    oFilterItem := FWFormStruct(1, "CKK")
endif

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA166',{|oModel| CARGAORIGEM(oModel)}/*,{|oModel| updAllStatus(oModel)}*/)

If lProfStatus 
    addCmpLegend(oModel, oProduto, .T.)
EndIf

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA166",,oCabecalho)

//Adicionando o grid de produto
oModel:AddGrid( 'FISA166PRODUTO', 'FISA166', oProduto,,,,{|oProduto| ValidDel(oProduto)})
//oModel:GetModel( 'FISA166PRODUTO' ):SetUseOldGrid()

//Adicionando o grid das origens de produto
oModel:AddGrid('FISA166ORIGEM','FISA166',oOrigem) 
//oModel:GetModel('FISA166ORIGEM'):SetUseOldGrid()

//Inicializa o campo F20_TIPO com ´conteúdo "04" que significa tipo de perfil de produto
oCabecalho:SetProperty('F20_TIPO' , MODEL_FIELD_INIT ,{||"04"} )
//Inicializa o campo F25_TIPO com ´conteúdo "04" que significa tipo de perfil de produto
IF lF25Tipo
    oOrigem:SetProperty('F25_TIPOPF' , MODEL_FIELD_INIT ,{||"04"} )
Endif
IF lF24Tipo
    oProduto:SetProperty('F24_TIPOPF' , MODEL_FIELD_INIT ,{||"04"} )
Endif

//Retira obrigatoriedade dos campos F24_CODIGO e F25_CODIGO
oProduto:SetProperty('F24_CODIGO' , MODEL_FIELD_OBRIGAT,  .F. )
oOrigem:SetProperty('F25_CODIGO'  , MODEL_FIELD_OBRIGAT,  .F. )

oProduto:AddTrigger('F24_CDPROD','F24_CDPROD',{|| .T. },{|| updLineStatus(oModel, oModel:getModel('FISA166PRODUTO'))})

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oCabecalho:SetProperty('F20_DESC' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA166', '04') )})

//Define para não repetir o código de produto
oModel:GetModel( 'FISA166PRODUTO' ):SetUniqueLine( { 'F24_CDPROD' } )

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA166PRODUTO'):SetMaxLine(9999999)

//Não permite repetir a origem
oModel:GetModel('FISA166ORIGEM'):SetUniqueLine({'F25_ORIGEM'})

//Relacionamento entre as tabelas F20 Perfil com F24 Produto
oModel:SetRelation( 'FISA166PRODUTO', { { 'F24_FILIAL', 'xFilial("F24")' }, { 'F24_CODIGO', 'F20_CODIGO' }, {'04','F20_TIPO'} }, F24->( IndexKey( 1 ) ) )

//Relacionamento entre as tabelas F20 Perfil com F25 origens
oModel:SetRelation( 'FISA166ORIGEM', { { 'F25_FILIAL', 'xFilial("F25")' }, { 'F25_CODIGO', 'F20_CODIGO' }, {'04','F20_TIPO'} }, F25->( IndexKey( 1 ) ) )

if lFilters
    oModel:AddGrid("FISA166FILTERS", "FISA166", oProfileFilter)
    oModel:AddGrid("FISA166ITEMS", "FISA166FILTERS", oFilterItem)

    // esse modelo só será usado em PO-UI. Por isso o mesmo se tornou opcional
    oModel:getModel("FISA166FILTERS"):setOptional(.T.)
    oModel:getModel("FISA166ITEMS"):setOptional(.T.)

    oModel:SetRelation( 'FISA166FILTERS', { { 'CKJ_FILIAL', 'xFilial("CKJ")' }, { 'CKJ_CODIGO', 'F20_CODIGO' }, {'CKJ_TIPOPF','F20_TIPO'} }, CKJ->( IndexKey( 2 ) ) )

    oModel:SetRelation( 'FISA166ITEMS', { { 'CKK_FILIAL', 'xFilial("CKK")' }, { 'CKK_IDFILT', 'CKJ_ID' }}, CKK->( IndexKey( 2 ) ) )
endIf

//Adicionando descrição ao modelo
oModel:SetDescription(STR0002) // Cadastro de Perfil Tributário de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA166" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20", {|cCampo| !(alltrim(cCampo) $ 'F20_STATUS') })
Local oProduto	:= FWFormStruct(2, "F24")
Local oOrigem	:= FWFormStruct(2, "F25")

Local oView := Nil
Local cVersao 	:= GetVersao(.F.)

if lProfStatus
    addCmpLegend(oModel, oProduto, .F.)
EndIf


oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA166'         )
oView:AddGrid(  'VIEW_PRODUTO'   , oProduto    , 'FISA166PRODUTO'  )
oView:AddGrid(  'VIEW_ORIGEM'    , oOrigem     , 'FISA166ORIGEM'   )

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_PRODUTO', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_PRODUTO', "GRIDSEEK", {.T.})
oView:SetViewProperty('VIEW_ORIGEM', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_ORIGEM', "GRIDSEEK", {.T.})

//Retira os campos da View
oCabecalho:RemoveField( 'F20_TIPO' )
oProduto:RemoveField( 'F24_CODIGO' )
oProduto:RemoveField( 'F24_CODNCM' )
oOrigem:RemoveField( 'F25_CODIGO'  )

IF lF25Tipo
    oOrigem:RemoveField( 'F25_TIPOPF')
Endif
IF lF24Tipo
    oProduto:RemoveField( 'F24_TIPOPF')
Endif

If lProfStatus 
    oProduto:RemoveField( 'F24_STATUS' )
endIf

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'MEDIO'     , 40 )
oView:CreateHorizontalBox( 'INFERIOR'  , 40 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_PRODUTO'     , 'MEDIO'    )
oView:SetOwnerView( 'VIEW_ORIGEM'      , 'INFERIOR' )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO' , STR0002 )
oView:EnableTitleView('VIEW_PRODUTO' , STR0003 ) 
oView:EnableTitleView('VIEW_ORIGEM' , STR0004 ) 

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ") 
    oView:AddUserButton( 'Facilitador','', {|oVw| FISA166RunWiz()} )
EndIF

If lProfStatus 
    oView:AddUserButton( 'Legenda', 'CLIPS', {|oModel| f166leg(oModel)} )
endIf

Return oView

/*/{Protheus.doc} FISA166RunWiz()
    Funcao estatica responsavel por orquestrar a abertura do wizard a partir do
    formulario MVC e fechar o formulario automaticamente apos a conclusao.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
/*/
Static Function FISA166RunWiz()

    Local oVwAtv := FwViewActive()
    Local oMdAtv := FWModelActive()
    Local lRetWz := .T.
    Private lWizOK := .F.

    FSA171WIZ("2","04")

    If lWizOK
        oMdAtv:DeActivate()
        oMdAtv:SetOperation(MODEL_OPERATION_VIEW)
        oVwAtv:ButtonCancelAction()
        lRetWz := .F.
    EndIf

Return lRetWz

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Função que valida se o código de perfil cadastrado já existe

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function VldPerfil(oModel, cModelName, cTpPerfil)

Local cPerfil 	:= oModel:GetValue (cModelName,"F20_CODIGO")
Local lRet      := .T.

//Verifico se o perfil já existe.
If F20->( MsSeek ( xFilial('F20') + cPerfil + cTpPerfil ) )
    lRet    := .F.    
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaOrigem
Função que faz a carga automática das origens de produto no grid.
O objetivo é facilitar o cadastro do usuário, sugerindo todas as origens,
cabendo ele somente excluir as origens que não pertinentes ao perfil.

@author Erick G Dias
@since 05/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CargaOrigem(oModel)

Local oOrigen		:= oModel:GetModel("FISA166ORIGEM")
Local lFirst        := .T.
Local aDadosSX5     := FWGetSX5( "S0" )
Local nX            := 0

//A carga será realizada somente no momento da inclusão do perfil
If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. oOrigen:Length() == 1
    //Posiciono na tabela SX5 para buscar as informações da origem do produto
    For nX := 1 to Len(aDadosSX5)
        //Adiciono uma linha para cada ocorrência de origem na SX5
        IF !lFirst
            //Não devo criar AddLine() na primeira linha, se fizer teremos a primeira linha vazia.
            oOrigen:AddLine()            
        EndIF
        oOrigen:LoadValue("F25_ORIGEM" , Alltrim(aDadosSX5[nX][3]))
        oOrigen:LoadValue("F25_DSORIG" , Alltrim(aDadosSX5[nX][4]))
        IF lF25Tipo
            oOrigen:LoadValue("F25_TIPOPF" ,'04')
        Endif
        lFirst  := .F.        
    Next       
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166GF24

Função para gravação/exclusão da F24 chamada de "fora" da rotina
de cadastro

@author joao.pellegrini
@since 13/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166GF24(cCodPerfil, cOper, cCodProd, aPerfAtu, aPerfNAtu)

    Local aAreaF20 := F20->(GetArea()) as array
    Local aAreaF24 := F24->(GetArea()) as array
    Local cF24Sql  := RetSqlName("F24") as character
    Local cFilF24  := xFilial("F24") as character
    Local lRet     := .F. as logical
    Local oStmt    := Nil as object
    Local nRecno   := 0 as numeric
    Local cSql     := "" as character

    DbSelectArea("F20")
    F20->(DbSetOrder(1))

    If F20->(DbSeek(xFilial("F20") + cCodPerfil + "04"))

        If cOper == "INCLUI"

            // Valida se o produto ja existe no perfil

            cSql := " SELECT F24_CDPROD FROM " + cF24Sql
            cSql += " WHERE F24_FILIAL = ? AND F24_CODIGO = ? AND F24_CDPROD = ? AND D_E_L_E_T_ = ' '"

            oStmt := FwExecStatement():New(ChangeQuery(cSql))
            oStmt:SetString(1, cFilF24)
            oStmt:SetString(2, cCodPerfil)
            oStmt:SetString(3, cCodProd)

            If !Empty(oStmt:ExecScalar("F24_CDPROD"))
                oStmt:Destroy()
                lRet := .T.
            Else
                oStmt:Destroy()

                // Valida se o perfil possui TODOS configurado
                cSql := " SELECT F24_CDPROD FROM " + cF24Sql
                cSql += " WHERE F24_FILIAL = ? AND F24_CODIGO = ? AND F24_CDPROD = 'TODOS' AND D_E_L_E_T_ = ' '"
                oStmt := FwExecStatement():New(ChangeQuery(cSql))
                oStmt:SetString(1, cFilF24)
                oStmt:SetString(2, cCodPerfil)

                If !Empty(oStmt:ExecScalar("F24_CDPROD"))
                    oStmt:Destroy()
                    If ValType(aPerfNAtu) == "A"
                        AAdd(aPerfNAtu, cCodPerfil)
                    EndIf
                    lRet := .T.
                Else
                    oStmt:Destroy()

                    DbSelectArea("F24")
                    RecLock("F24", .T.)
                    F24->F24_FILIAL := cFilF24
                    F24->F24_CODIGO := cCodPerfil
                    F24->F24_CDPROD := cCodProd
                    F24->F24_TIPOPF := "04"
                    F24->F24_STATUS := " "
                    MsUnlock()
                    If ValType(aPerfAtu) == "A"
                        AAdd(aPerfAtu, cCodPerfil)
                    EndIf
                    lRet := .T.
                EndIf
            EndIf

        ElseIf cOper == "EXCLUI"

            // Busca o RECNO do registro a excluir

            cSql := " SELECT R_E_C_N_O_ FROM " + cF24Sql
            cSql += " WHERE F24_FILIAL = ? AND F24_CODIGO = ? AND F24_CDPROD = ? AND D_E_L_E_T_ = ' '"

            oStmt := FwExecStatement():New(ChangeQuery(cSql))
            oStmt:SetString(1, cFilF24)
            oStmt:SetString(2, cCodPerfil)
            oStmt:SetString(3, cCodProd)
            nRecno := oStmt:ExecScalar("R_E_C_N_O_")
            oStmt:Destroy()

            If ValType(nRecno) == "N" .And. nRecno > 0
                DbSelectArea("F24")
                F24->(DbGoTo(nRecno))
                RecLock("F24", .F.)
                DbDelete()
                MsUnlock()
            EndIf

            lRet := .T.

        EndIf

    EndIf

    RestArea(aAreaF24)
    RestArea(aAreaF20)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166DPRD
Função auxiliar para tratar o inicializador padrão da descrição do 
do Produto, pois o campo X3_RELACAO é limitado e não cabia 
toda a instrução necessária.

@author Erich Buttner
@since 01/02/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166DPRD()

Local cDescr   := ""
Local cCodPro  := AllTrim(Upper(F24->F24_CDPROD))
Local cCodPerf := ""
Local cChave   := ""
Local oModel   := FWModelActive()

If Empty(cCodPro) .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT
    Return cDescr
Elseif cCodPro == "TODOS"
    cDescr := "TODOS OS PRODUTOS"
Else
    cCodPerf := AllTrim(oModel:GetValue("FISA166", "F20_CODIGO"))

    If Empty(cCodPerf)
        Return POSICIONE("SB1", 1, xFilial("SB1") + cCodPro, "B1_DESC")
    EndIf

    // Inicializa e sincroniza cache (invalida se mudou de filial)
    IniProdCache()

    // Carga em massa: uma unica query carrega todas as descricoes do perfil
    If !ProdPerfLoad(cCodPerf)
        LoadProdPerf(cCodPerf)
    EndIf

    // Busca no cache
    cChave := xFilial("SB1") + cCodPro
    cDescr := GetProdCache(cChave)

    // Fallback para produto incluido na sessao (nao estava na carga inicial)
    If Empty(cDescr)
        cDescr := POSICIONE("SB1", 1, cChave, "B1_DESC")
        oJSPROD[cFilAtu][cChave] := cDescr
    EndIf
EndIf

Return cDescr

/*/{Protheus.doc} IniProdCache
    Inicializa/sincroniza estruturas de cache para descricoes de produto.
    Invalida o cache quando a filial muda.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 06/04/2026
    @version 12.1.2510
/*/
Static Function IniProdCache()
    Local cFilAtual := cFilAnt

    If cFilAtual != cFilAtu
        cFilAtu := cFilAtual
        If ValType(oJSPROD) == "J"
            FreeObj(oJSPROD)
            oJSPROD := Nil
        EndIf
        If ValType(oIdxProd) == "J"
            FreeObj(oIdxProd)
            oIdxProd := Nil
        EndIf
    EndIf

    If ValType(oJSPROD) != "J"
        oJSPROD := JsonObject():New()
    EndIf
    If ValType(oIdxProd) != "J"
        oIdxProd := JsonObject():New()
    EndIf
    If !oJSPROD:HasProperty(cFilAtu)
        oJSPROD[cFilAtu] := JsonObject():New()
    EndIf
    If !oIdxProd:HasProperty(cFilAtu)
        oIdxProd[cFilAtu] := JsonObject():New()
    EndIf
Return

/*/{Protheus.doc} ProdPerfLoad
    Verifica se os produtos de um perfil ja foram carregados em cache.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 06/04/2026
    @version 12.1.2510
/*/
Static Function ProdPerfLoad(cCodPerf)
Return oIdxProd[cFilAtu]:HasProperty(xFilial("F24") + cCodPerf)


/*/{Protheus.doc} LoadProdPerf
    Carrega em massa as descricoes de todos os produtos do perfil.
    Uma unica query substitui N chamadas POSICIONE.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 06/04/2026
    @version 12.1.2510
/*/
Static Function LoadProdPerf(cCodPerf)
    Local cQuery  := ""
    Local cAlias  := ""
    Local cFilSB1 := xFilial("SB1")
    Local cFilF24 := xFilial("F24")

    cQuery := " SELECT SB1.B1_COD CODIGO, SB1.B1_DESC NOME "
    cQuery += " FROM " + RetSQLName("SB1") + " SB1 "
    cQuery += " INNER JOIN " + RetSQLName("F24") + " F24 "
    cQuery += "    ON F24.F24_CDPROD = SB1.B1_COD "
    cQuery += "   AND F24.F24_FILIAL = ? "
    cQuery += "   AND F24.F24_CODIGO = ? "
    cQuery += "   AND F24.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB1.B1_FILIAL = ? "
    cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "

    cAlias := ExecProdQry(cQuery, {cFilF24, cCodPerf, cFilSB1})

    While (cAlias)->(!Eof())
        oJSPROD[cFilAtu][cFilSB1 + AllTrim((cAlias)->CODIGO)] := AllTrim((cAlias)->NOME)
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oIdxProd[cFilAtu][cFilF24 + cCodPerf] := .T.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProdCache
Busca descricao de produto no cache.
/*/
//-------------------------------------------------------------------
Static Function GetProdCache(cChave)
    Local cRet := ""
    If oJSPROD[cFilAtu]:HasProperty(cChave)
        cRet := oJSPROD[cFilAtu][cChave]
    EndIf
Return cRet


/*/{Protheus.doc} ExecProdQry
    Executa query com prepared statement reutilizavel (mesmo padrao do FISA164).
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 06/04/2026
    @version 12.1.2510
/*/
Static Function ExecProdQry(cQuery, aBindParams)
    Local nI        := 0
    Local cMD5      := MD5(cQuery)
    Local cAliasQry := ""

    If ValType(jPrep166) != "J"
        jPrep166 := JsonObject():New()
    EndIf

    If ValType(jPrep166[cMD5]) != "O"
        jPrep166[cMD5] := FwExecStatement():New(ChangeQuery(cQuery))
    EndIf

    For nI := 1 To Len(aBindParams)
        jPrep166[cMD5]:setString(nI, aBindParams[nI])
    Next nI

    cAliasQry := jPrep166[cMD5]:OpenAlias()
Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166X3

Função para ajustar o valid do campo de codigo de produto

@author erich buttner
@since 01/02/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166X3()

Local aDados := {}

aAdd( aDados, { { 'F24_CDPROD' 	}, { { 'X3_VALID'	, 'Vazio() .Or. ExistCpo("SB1") .Or. Upper(Alltrim(FwFldGet("F24_CDPROD"))) == "TODOS"' } } } )
aAdd( aDados, { { 'F24_DSPROD' 	}, { { 'X3_RELACAO'	, 'Iif(FindFunction("FSA166DPRD"), FSA166DPRD(),"")' } } } )

Return


/*/{Protheus.doc} AtuTpPF04
    (Atualiza novos campos F25_TIPOPF e F24_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF04()

IF lF24Tipo
    cQuery := "UPDATE " +  RetSqlName('F24') + " SET F24_TIPOPF = '04' WHERE F24_FILIAL = " + ValToSql(xFilial('F24')) + " AND F24_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lF25Tipo
    cQuery := "UPDATE " +  RetSqlName('F25') + " SET F25_TIPOPF = '04' WHERE F25_FILIAL = " + ValToSql(xFilial('F25')) + " AND F25_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif

Return

/*/{Protheus.doc} VldTodos
    Valida a inclusão do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oObjeto)

Local lRet      := .T.
Local lProdTd    := .F.
Local lProdAv    := .F.
Local nY
Local oModelGrid := oObjeto

/*
nOpcao == 1 -> Tipo de Operação
nOpcao == 2 -> Código de Serviço
*/
oModelPad   := FwModelActive()

For nY := 1 to oModelGrid:Length()

    oModelGrid:GoLine(nY)

    iF !oModelGrid:IsDeleted()

        cCdProd := AllTrim(oModelGrid:GetValue ("F24_CDPROD"))

        lProdTd := iif(lProdTd==.F.,iif(AllTrim(cCdProd)=="TODOS",.t.,.f.),.T.)
        lProdAv := iif(lProdAv==.F.,iif(AllTrim(cCdProd)<>"TODOS",.t.,.f.),.T.)

        If lProdTd .and. lProdAv
            exit
        ENDIF

    EndIf

Next nY

nY := 0

If lProdTd .and. lProdAv

    If lAutomato .or. MsgYesNo( STR0005 + chr(13)+chr(10) +;    //"Existem Produtos configurados como 'TODOS' no Grid."
                                STR0006 + chr(13)+chr(10) +;    //"Os tipos de Produto diferente de TODOS serão excluídos"
                                STR0007, STR0002)               //"Deseja continuar?"

        For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

            iF !oModelGrid:IsDeleted()

                cCdProd := AllTrim(oModelGrid:GetValue ("F24_CDPROD"))

                if(!("TODOS" $ cCdProd) .and. lProdTd)
                    oModelGrid:DeleteLine()
                EndIf
            EndIF

        Next nY
    else

        lRet := .F.
        oModelPad:SetErrorMessage(,,,,,STR0008,STR0009)

    EndIf

EndIF

Return lRet

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
        oProfileOptimizerMVC := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizerMVC():new(oModel, "FISA166", "FISA166PRODUTO", "FISA166FILTERS", "FISA166ITEMS", "F24_STATUS", "F24_LEGEND", "04")
    endIf
Return

/*/{Protheus.doc} updAllStatus
Função que atualiza o status do perfil e de cada linha do grid.
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 24/09/2025
@param oModel, object, Modelo que contém os dados
@return logical, true
/*/
Static Function updAllStatus(oModel)
    if lProfStatus
        objProfileOptimizerMVC(oModel)
        oProfileOptimizerMVC:setDefaultModel(oModel)
        oProfileOptimizerMVC:updAllStatus()
    endIf
Return .T.

/*/{Protheus.doc} updLineStatus
Função que atualiza o status da linha do grid.
@type function
@version 12.1.2510
@author Juliano Fernandes
@since 24/09/2025
@param oModel, object, Modelo que contém os dados
@param oSubModel, object, SubModelo que contém os dados
@return logical, true
/*/
Static Function updLineStatus(oModel, oSubModel)
    if lProfStatus
        objProfileOptimizerMVC(oModel)
        oProfileOptimizerMVC:setDefaultModel(oModel)
        oProfileOptimizerMVC:updLineStatus(oSubModel)
    endIf
Return

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

/*/{Protheus.doc} f166leg
Funcao que cria a legenda
@type static function
@version 12.1.2510
@author Matheus Bispo
@since 07/10/2025
@param oModel, object, Modelo que contém os dados
@return nil, nil
/*/
Static Function f166leg(oModel)
    objProfileOptimizerMVC(oModel)
    oProfileOptimizerMVC:showLegend()
Return

/*/{Protheus.doc} f166ProfOp
Função que executa o Otimizador de Perfis para o Perfil de Produto
A chamada dessa função é realizada nos fontes MATA010EVBRA na function AfterTTS().
@type function
@version 12.1.2510
@author Matheus Bispo
@since 13/10/2025
@param nOperation, numeric, Tipo de operação (inserção ou atualização)
@param cCodProd, character, Codigo do Produto processado
@retun nil, nil, nil
/*/
Function f166ProfOp(nOperation, cCodProd)

    Local oProfileOptimizer := Nil
    Local lProfOptim := FindClass('totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer')

    If cPaisLoc == "BRA"
        If ( lProfStatus .And. lProfOptim .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
            oProfileOptimizer := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer():new()
            oProfileOptimizer:setProduct(cCodProd)
            oProfileOptimizer:setTypes('','PRODUCT')
            oProfileOptimizer:process()
            oProfileOptimizer:destroy()
            fwFreeObj(oProfileOptimizer)
        EndIf
    EndIf

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
Function FSA166DESC()
    
	Local cTitulo := "Descrição do Perfil" as character
	Local aButtons := {} as array
	Local cDesc := Space(FWSX3Util():GetFieldStruct("F20_DESC")[3]) as character
	Local lHasButton as logical
	Local oModalDesc := nil as object
	Local oContainer := nil as object
	Local oGetDesc as object
		
	aAdd(aButtons,{,"Alterar",{|| FSA166DESA(cDesc),oModalDesc:DeActivate()},,1,.T.,.T.})

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

/*/{Protheus.doc} FSA166DESA
    Altera a Descrição doo Perfil de Produto
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 10/04/2026
    @version 12.1.2510  
/*/
Static Function FSA166DESA(cDesc as character)
    if !Empty(cDesc)
        F20->(RecLock("F20",.F.))
        F20->(F20_DESC) := cDesc
        F20->(MsUnlock())
    endif    
Return

/*/{Protheus.doc} A166OPEN
    Funcao que monta um browser FWBrowse para substituir as chamadas
    MVC de Visualizacao, Exclusao e Copia no perfil de produto.
    @type  Function
    @author Ricardo Henrique de Mello Lima
    @since 14/06/2026
    @version 12.1.2510
    @param nOption, numeric, 1=Visualizar, 4=Excluir, 5=Copiar
    @return implicita, logica, true
/*/
Function A166OPEN(nOption as numeric)

    Local oDlgProd   := nil as object
    Local oBrwProd   := nil as object
    Local oBrwOrig   := nil as object
    Local oSize      := nil as object
    Local oPanelTop  := nil as object
    Local oPanelBot  := nil as object
    Local oPanelMid  := nil as object
    Local oPanelInf  := nil as object
    Local oGetCod    := nil as object
    Local oGetNome   := nil as object
    Local oColumn    := nil as object
    Local aSeek      := {} as array
    Local aSeekOr    := {} as array
    Local aFields    := {} as array
    Local aFieldsO   := {} as array
    Local cQry       := "" as character
    Local cQryOrig   := "" as character
    Local cNome      := F20->F20_DESC as character
    Local cCod       := F20->F20_CODIGO as character
    Local cFilF24    := xFilial("F24") as character
    Local cFilF25    := xFilial("F25") as character
    Local cFilSB1    := xFilial("SB1") as character
    Local cAlsTemp   := GetNextAlias() as character
    Local cAlsOrig   := GetNextAlias() as character
    Local oTempProd  := FWTemporaryTable():New(cAlsTemp) as object
    Local oTempOrig  := FWTemporaryTable():New(cAlsOrig) as object
    Local aTempFlds  := {} as array
    Local aTempFlds2 := {} as array
    Local lAction    := .F. as logical
    Local lOk        := .T. as logical
    Local cTempSql   := "" as character
    Local cTempSqlO  := "" as character
    Local cTitulo    := "" as character
    Local cAcao      := "" as character

    Default nOption := 1

    If nOption == 1
        cAcao := "VIZUALIZAR"
    ElseIf nOption == 5
        cAcao := "COPIAR"
    ElseIf nOption == 4
        cAcao := "EXCLUIR"
    EndIf

    cTitulo := "Perfil Tributario de Produto - " + cAcao

    AAdd(aSeek, { GETSX3CACHE("F24_CDPROD","X3_TITULO"),;
                  {{ "F24_CDPROD",;
                     GETSX3CACHE("F24_CDPROD","X3_TIPO"),;
                     GETSX3CACHE("F24_CDPROD","X3_TAMANHO"),;
                     GETSX3CACHE("F24_CDPROD","X3_DECIMAL"),;
                     GETSX3CACHE("F24_CDPROD","X3_TITULO"),;
                     GETSX3CACHE("F24_CDPROD","X3_PICTURE") }},;
                  1 })

    AAdd(aSeek, { GETSX3CACHE("F24_DSPROD","X3_TITULO"),;
                  {{ "F24_DSPROD",;
                     GETSX3CACHE("F24_DSPROD","X3_TIPO"),;
                     GETSX3CACHE("F24_DSPROD","X3_TAMANHO"),;
                     GETSX3CACHE("F24_DSPROD","X3_DECIMAL"),;
                     GETSX3CACHE("F24_DSPROD","X3_TITULO"),;
                     GETSX3CACHE("F24_DSPROD","X3_PICTURE") }},;
                  2 })

    AAdd(aSeekOr,{ GETSX3CACHE("F25_ORIGEM","X3_TITULO"),;
                  {{ "F25_ORIGEM",;
                     GETSX3CACHE("F25_ORIGEM","X3_TIPO"),;
                     GETSX3CACHE("F25_ORIGEM","X3_TAMANHO"),;
                     GETSX3CACHE("F25_ORIGEM","X3_DECIMAL"),;
                     GETSX3CACHE("F25_ORIGEM","X3_TITULO"),;
                     GETSX3CACHE("F25_ORIGEM","X3_PICTURE") }},;
                  1 })   

    aAdd(aFields, "F24_CDPROD")
    aAdd(aFields, "F24_NOME"  )

    aAdd(aFieldsO,"F25_ORIGEM")
    aAdd(aFieldsO,"F25_DSORIG")

    cQry := " SELECT"
    cQry += "     F24.F24_CDPROD,"
    cQry += "     COALESCE(SB1.B1_DESC, F24.F24_CDPROD) AS NOME,"
    cQry += "     F24.R_E_C_N_O_ AS F24_RECNO"
    cQry += " FROM " + RetSqlName("F24") + " F24"
    cQry += " LEFT JOIN " + RetSqlName("SB1") + " SB1"
    cQry += "     ON  SB1.B1_FILIAL = " + ValToSQL(cFilSB1)
    cQry += "     AND SB1.B1_COD    = F24.F24_CDPROD"
    cQry += "     AND SB1.D_E_L_E_T_ = ' '"
    cQry += " WHERE F24.F24_FILIAL = " + ValToSQL(cFilF24)
    cQry += "   AND F24.F24_CODIGO = " + ValToSQL(cCod)
    cQry += "   AND F24.D_E_L_E_T_ = ' '"

    AAdd(aTempFlds, {"F24_CDPROD", "C", TamSX3("F24_CDPROD")[1], 0})
    AAdd(aTempFlds, {"F24_NOME",   "C", 255, 0})
    AAdd(aTempFlds, {"F24_RECNO",  "N", 15,  0})

    FWMsgRun(, {|oSay|;
        oSay:SetText("Preparando estrutura de produtos..."),;
        oTempProd:SetFields(aTempFlds),;
        oTempProd:AddIndex(cValToChar(StrZero(1,2)), {"F24_CDPROD"}),;
        oTempProd:AddIndex(cValToChar(StrZero(2,2)), {"F24_NOME"}),;
        oTempProd:Create(),;
        cTempSql := oTempProd:GetRealName(),;
        FkCommit();
    }, "Aguarde", "Preparando...")

    If cValToChar(nOption) $ "4/5"
        FWMsgRun(, {|oSay|;
            oSay:SetText("Carregando previa de produtos (primeiros 1000)..."),;
            TCSqlExec("INSERT INTO " + cTempSql + " (F24_CDPROD, F24_NOME, F24_RECNO)" + ;
                " SELECT T2.F24_CDPROD, T2.NOME, T2.F24_RECNO" + ;
                " FROM (SELECT T.*, ROW_NUMBER() OVER (ORDER BY T.F24_CDPROD) AS RNPREV" + ;
                "       FROM (" + cQry + ") T) T2" + ;
                " WHERE T2.RNPREV <= 1000"),;
            FkCommit();
        }, "Aguarde", "Carregando produtos... Esta operacao pode levar alguns minutos dependendo da quantidade de registros.")
    ElseIf nOption == 1
        FWMsgRun(, {|oSay|;
            oSay:SetText("Carregando produtos..."),;
            TCSqlExec("INSERT INTO " + cTempSql + " (F24_CDPROD, F24_NOME, F24_RECNO)" + cQry),;
            FkCommit();
        }, "Aguarde", "Carregando produtos... Esta operacao pode levar alguns minutos dependendo da quantidade de registros.")
    EndIf

    cQryOrig := " SELECT"
    cQryOrig += "     F25.F25_ORIGEM,"
    cQryOrig += "     COALESCE(SX5.X5_DESCRI, F25.F25_ORIGEM) AS F25_DSORIG,"
    cQryOrig += "     F25.R_E_C_N_O_ AS F25_RECNO"
    cQryOrig += " FROM " + RetSqlName("F25") + " F25"
    cQryOrig += " LEFT JOIN " + RetSqlName("SX5") + " SX5"
    cQryOrig += "     ON  SX5.X5_FILIAL = '  '"
    cQryOrig += "     AND SX5.X5_TABELA = 'S0'"
    cQryOrig += "     AND SX5.X5_CHAVE  = F25.F25_ORIGEM"
    cQryOrig += "     AND SX5.D_E_L_E_T_ = ' '"
    cQryOrig += " WHERE F25.F25_FILIAL = " + ValToSQL(cFilF25)
    cQryOrig += "   AND F25.F25_CODIGO = " + ValToSQL(cCod)
    cQryOrig += "   AND F25.D_E_L_E_T_ = ' '"

    AAdd(aTempFlds2, {"F25_ORIGEM", "C", TamSX3("F25_ORIGEM")[1], 0})
    AAdd(aTempFlds2, {"F25_DSORIG", "C", 60, 0})
    AAdd(aTempFlds2, {"F25_RECNO",  "N", 15, 0})

    FWMsgRun(, {|oSay|;
        oSay:SetText("Preparando estrutura de origens..."),;
        oTempOrig:SetFields(aTempFlds2),;
        oTempOrig:AddIndex(cValToChar(StrZero(1,2)), {"F25_ORIGEM"}),;
        oTempOrig:AddIndex(cValToChar(StrZero(2,2)), {"F25_DSORIG"}),;
        oTempOrig:Create(),;
        cTempSqlO := oTempOrig:GetRealName(),;
        FkCommit();
    }, "Aguarde", "Preparando...")

    FWMsgRun(, {|oSay|;
        oSay:SetText("Carregando origens..."),;
        TCSqlExec("INSERT INTO " + cTempSqlO + " (F25_ORIGEM, F25_DSORIG, F25_RECNO)" + cQryOrig),;
        FkCommit();
    }, "Aguarde", "Carregando origens...")

    oSize := FwDefSize():New(.T.,.F.,,)
    oSize:lProp    := .T.
    oSize:aMargins := { 0, 0, 0, 0 }
    oSize:Process()

    If nOption == 5
        cCod  := Space(GETSX3CACHE("F20_CODIGO","X3_TAMANHO"))
        cNome := Space(GETSX3CACHE("F20_DESC","X3_TAMANHO"))
    EndIf

    DEFINE MSDIALOG oDlgProd TITLE cTitulo From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

    If nOption == 5
        EnchoiceBar(oDlgProd,;
            {|| lAction := .T.,;
                FWMsgRun(, {|| lOk := A166Copia(cCod, cNome) },;
                "Aguarde",;
                "Copiando perfil de produto... Esta operacao pode levar alguns minutos dependendo da quantidade de registros."),;
                If(lOk, oDlgProd:End(), Nil) },;
            {|| lAction := .F., oDlgProd:End()},,)
    ElseIf nOption == 4
        EnchoiceBar(oDlgProd,;
            {|| lAction := .T.,;
                FWMsgRun(, {|| lOk := A166Excluir(cCod) },;
                "Aguarde",;
                "Excluindo perfil de produto... Esta operacao pode levar alguns minutos dependendo da quantidade de registros."),;
                If(lOk, oDlgProd:End(), Nil) },;
            {|| lAction := .F., oDlgProd:End()},,)
    ElseIf nOption == 1
        EnchoiceBar(oDlgProd,;
            {|| lAction := .T., oDlgProd:End()},;
            {|| lAction := .F., oDlgProd:End()},,)
    EndIf

    oPanelTop := TPanel():New(0,0,'',oDlgProd,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelTop:Align   := CONTROL_ALIGN_TOP
    oPanelTop:nHeight := 100

    oPanelBot := TPanel():New(0,0,'',oDlgProd,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelBot:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelMid := TPanel():New(0,0,'',oPanelBot,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelMid:Align   := CONTROL_ALIGN_TOP
    oPanelMid:nHeight := Int((oSize:aWindSize[3] - oSize:aWindSize[1] - 100) / 2)

    oPanelInf := TPanel():New(0,0,'',oPanelBot,,.T.,.T.,,,30,30,.T.,.T.)
    oPanelInf:Align := CONTROL_ALIGN_ALLCLIENT

    oGetCod  := TGet():New(15, 10,{ |u| If(PCount()==0,cCod,cCod:=u) }  , oPanelTop,100,10,"@!",{||},0,,,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,cCod ,,,,,,,"Codigo",1)
    oGetCod:lReadOnly  := !nOption == 5
    oGetNome := TGet():New(15,200,{ |u| If(PCount()==0,cNome,cNome:=u) }, oPanelTop,300,10,"@!",{||},0,,,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,cNome,,,,,,,"Nome",1)
    oGetNome:lReadOnly := !nOption == 5

    oBrwProd := FWBrowse():New()
    oBrwProd:SetDescription("Produtos")
    oBrwProd:SetDataTable()
    oBrwProd:SetAlias(cAlsTemp)
    oBrwProd:SetSeek(, aSeek)
    oBrwProd:SetOwner(oPanelMid)
    oBrwProd:DisableReport()
    oBrwProd:DisableFilter()
    oBrwProd:DisableConfig()
    oBrwProd:DisableSaveConfig()

    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFields[1] + " }"))
    oColumn:SetSize(GETSX3CACHE("F24_CDPROD", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F24_CDPROD", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F24_CDPROD", "X3_TITULO"))
    oBrwProd:SetColumns({oColumn})

    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFields[2] + " }"))
    oColumn:SetSize(GETSX3CACHE("F24_DSPROD", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F24_DSPROD", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F24_DSPROD", "X3_TITULO"))
    oBrwProd:SetColumns({oColumn})

    oBrwProd:Activate()

    oBrwOrig := FWBrowse():New()
    oBrwOrig:SetDescription("Origens")
    oBrwOrig:SetDataTable()
    oBrwOrig:SetAlias(cAlsOrig)
    oBrwOrig:SetSeek(, aSeekOr)
    oBrwOrig:SetOwner(oPanelInf)
    oBrwOrig:DisableReport()
    oBrwOrig:DisableFilter()
    oBrwOrig:DisableConfig()
    oBrwOrig:DisableSaveConfig()

    oColumn := FWBrwColumn():New()
    oColumn:SetData(&("{ || " + aFieldsO[1] + " }"))
    oColumn:SetSize(GETSX3CACHE("F25_ORIGEM", "X3_TAMANHO"))
    oColumn:SetDecimal(GETSX3CACHE("F25_ORIGEM", "X3_DECIMAL"))
    oColumn:SetTitle(GETSX3CACHE("F25_ORIGEM", "X3_TITULO"))
    oBrwOrig:SetColumns({oColumn})

    oColumn := FWBrwColumn():New()
     oColumn:SetData(&("{ || " + aFieldsO[2] + " }"))
    oColumn:SetSize(120)
    oColumn:SetDecimal(0)
    oColumn:SetTitle("Descricao")
    oBrwOrig:SetColumns({oColumn})

    oBrwOrig:Activate()

    ACTIVATE MSDIALOG oDlgProd CENTERED

    oBrwProd:Deactivate()
    oBrwOrig:Deactivate()
    oTempProd:Delete()
    oTempOrig:Delete()
    FreeObj(oTempProd)
    FreeObj(oTempOrig)
    FreeObj(oBrwProd)
    FreeObj(oBrwOrig)
    FreeObj(oDlgProd)

Return

/*/{Protheus.doc} A166Copia
    Funcao responsavel por copiar o perfil de produto (F20 + F24 + F25).
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 14/06/2026
    @version 12.1.2510
    @param cCod, Character, Novo codigo do perfil
    @param cNome, Character, Novo nome do perfil
    @return lOk, Logical, .T. se copiou com sucesso
/*/
Static Function A166Copia(cCod as character, cNome as character)

    Local aAreaF20  := F20->(GetArea()) as array
    Local cF24Sql   := RetSqlName("F24") as character
    Local cF25Sql   := RetSqlName("F25") as character
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

    oModel := FWLoadModel("FISA166")
    oModel:GetModel("FISA166PRODUTO"):SetOptional(.T.)
    oModel:GetModel("FISA166ORIGEM"):SetOptional(.T.)
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("FISA166", "F20_FILIAL", aF20Copia[1])
    oModel:SetValue("FISA166", "F20_CODIGO", cCod)
    oModel:SetValue("FISA166", "F20_DESC",   cNome)
    oModel:SetValue("FISA166", "F20_TIPO",   aF20Copia[4])

    If oModel:VldData()
        lOk := oModel:CommitData()
    Else
        lOk      := .F.
        cMsgErro := "Erro ao gravar F20: " + AllTrim(oModel:GetErrorMessage()[6])
    EndIf
    oModel:DeActivate()
    FreeObj(oModel)

    If lOk
        // Remove origens inseridas automaticamente pelo CARGAORIGEM durante o CommitData
        TcSqlExec("UPDATE " + cF25Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
                  " WHERE F25_FILIAL = " + ValToSQL(xFilial("F25")) + ;
                  "   AND F25_CODIGO = " + ValToSQL(cCod) + ;
                  "   AND D_E_L_E_T_ = ' '")

        // Copia produtos (F24)
        cQry := " INSERT INTO " + cF24Sql + " ("
        cQry +=     " R_E_C_N_O_, F24_FILIAL, F24_CODIGO, F24_CDPROD,"
        cQry +=     " F24_TIPOPF, F24_STATUS,"
        cQry +=     " D_E_L_E_T_, R_E_C_D_E_L_"
        cQry += " ) SELECT"
        cQry +=     " COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF24Sql + "), 0)"
        cQry +=     " + ROW_NUMBER() OVER (ORDER BY SRC.F24_CDPROD),"
        cQry +=     " SRC.F24_FILIAL,"
        cQry +=     " " + ValToSQL(cCod) + ","
        cQry +=     " SRC.F24_CDPROD,"
        cQry +=     " SRC.F24_TIPOPF, SRC.F24_STATUS,"
        cQry +=     " ' ', 0"
        cQry += " FROM " + cF24Sql + " SRC"
        cQry += " WHERE SRC.F24_FILIAL = " + ValToSQL(xFilial("F24"))
        cQry += "   AND SRC.F24_CODIGO = " + ValToSQL(aF20Copia[2])
        cQry += "   AND SRC.D_E_L_E_T_ = ' '"
        TcSqlExec(cQry)

        // Copia origens (F25)
        cQry := " INSERT INTO " + cF25Sql + " ("
        cQry +=     " R_E_C_N_O_, F25_FILIAL, F25_CODIGO, F25_ORIGEM,"
        cQry +=     " F25_TIPOPF,"
        cQry +=     " D_E_L_E_T_, R_E_C_D_E_L_"
        cQry += " ) SELECT"
        cQry +=     " COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF25Sql + "), 0)"
        cQry +=     " + ROW_NUMBER() OVER (ORDER BY SRC.F25_ORIGEM),"
        cQry +=     " SRC.F25_FILIAL,"
        cQry +=     " " + ValToSQL(cCod) + ","
        cQry +=     " SRC.F25_ORIGEM,"
        cQry +=     " SRC.F25_TIPOPF,"
        cQry +=     " ' ', 0"
        cQry += " FROM " + cF25Sql + " SRC"
        cQry += " WHERE SRC.F25_FILIAL = " + ValToSQL(xFilial("F25"))
        cQry += "   AND SRC.F25_CODIGO = " + ValToSQL(aF20Copia[2])
        cQry += "   AND SRC.D_E_L_E_T_ = ' '"
        TcSqlExec(cQry)
    EndIf

    If !Empty(cMsgErro)
        Help(,, "HELP",, cMsgErro, 1, 0)
    EndIf

    If lOk
        TcRefresh(cF24Sql)
        TcRefresh(cF25Sql)
    EndIf

    RestArea(aAreaF20)

Return lOk

/*/{Protheus.doc} A166Excluir
    Funcao responsavel por excluir o perfil de produto (F24 + F25 + CKJ/CKK + F20).
    Verifica integridade referencial via F2B_PERFPR antes de excluir.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 14/06/2026
    @version 12.1.2510
    @param cCod, Character, Codigo do perfil a excluir
    @return lOk, Logical, .T. se excluiu com sucesso
/*/
Static Function A166Excluir(cCod as character)

    Local aAreaF20  := F20->(GetArea()) as array
    Local cF20Sql   := RetSqlName("F20") as character
    Local cF24Sql   := RetSqlName("F24") as character
    Local cF25Sql   := RetSqlName("F25") as character
    Local oStmt     := Nil as object
    Local cAliasChk := "" as character

    Default cCod := ""

    // Pre-validacao: verifica integridade referencial — F2B_PERFPR referencia F20 tipo '04'
    oStmt := FwExecStatement():New(ChangeQuery(;
        " SELECT F2B_PERFPR FROM " + RetSqlName("F2B") + ;
        " WHERE F2B_FILIAL = ? AND F2B_PERFPR = ? AND D_E_L_E_T_ = ' '"))
    oStmt:SetString(1, xFilial("F2B"))
    oStmt:SetString(2, cCod)
    cAliasChk := oStmt:OpenAlias()

    If !(cAliasChk)->(Eof())
        (cAliasChk)->(DbCloseArea())
        oStmt:Destroy()
        RestArea(aAreaF20)
        Help(,, "HELP",, "Violacao de Integridade. Foi encontrada referencia de " + ;
            "Cod. Perfil (F20_CODIGO) + Tipo Perfil (F20_TIPO) na tabela F2B - " + ;
            "Regra Tributaria. Formulario FISA166", 1, 0)
        Return .F.
    EndIf
    (cAliasChk)->(DbCloseArea())
    oStmt:Destroy()

    // Exclui produtos (F24)
    TcSqlExec("UPDATE " + cF24Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
              " WHERE F24_FILIAL = " + ValToSQL(xFilial("F24")) + ;
              "   AND F24_CODIGO = " + ValToSQL(cCod) + ;
              "   AND F24_TIPOPF = '04'" + ;
              "   AND D_E_L_E_T_ = ' '")

    // Exclui origens (F25)
    TcSqlExec("UPDATE " + cF25Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
              " WHERE F25_FILIAL = " + ValToSQL(xFilial("F25")) + ;
              "   AND F25_CODIGO = " + ValToSQL(cCod) + ;
              "   AND F25_TIPOPF = '04'" + ;
              "   AND D_E_L_E_T_ = ' '")

    If lFilters
        TcSqlExec("UPDATE " + RetSqlName("CKK") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
                  " WHERE CKK_FILIAL = " + ValToSQL(xFilial("CKK")) + ;
                  "   AND CKK_IDFILT IN (" + ;
                  "       SELECT CKJ_ID FROM " + RetSqlName("CKJ") + ;
                  "       WHERE CKJ_FILIAL = " + ValToSQL(xFilial("CKJ")) + ;
                  "       AND CKJ_CODIGO = " + ValToSQL(cCod) + ;
                  "       AND CKJ_TIPOPF = '04'" + ;
                  "       AND D_E_L_E_T_ = ' ')" + ;
                  "   AND D_E_L_E_T_ = ' '")

        TcSqlExec("UPDATE " + RetSqlName("CKJ") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
                  " WHERE CKJ_FILIAL = " + ValToSQL(xFilial("CKJ")) + ;
                  "   AND CKJ_CODIGO = " + ValToSQL(cCod) + ;
                  "   AND CKJ_TIPOPF = '04'" + ;
                  "   AND D_E_L_E_T_ = ' '")
    EndIf

    TcSqlExec("UPDATE " + cF20Sql + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_" + ;
              " WHERE F20_FILIAL = " + ValToSQL(xFilial("F20")) + ;
              "   AND F20_CODIGO = " + ValToSQL(cCod) + ;
              "   AND F20_TIPO   = '04'" + ;
              "   AND D_E_L_E_T_ = ' '")

    TcRefresh(cF24Sql)
    TcRefresh(cF25Sql)
    TcRefresh(cF20Sql)

    RestArea(aAreaF20)

Return .T.
