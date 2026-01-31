#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA166.ch" 

Static lF24Tipo := F24->(Fieldpos("F24_TIPOPF")) > 0
Static lF25Tipo  := F25->(Fieldpos("F25_TIPOPF")) > 0
Static lAutomato := IsBlind()
Static oJSPROD 
Static cFilAtu := " "
Static lProfStatus := F20->(FieldPos("F20_STATUS")) > 0 .And. F24->(FieldPos("F24_STATUS")) > 0 .And. FindClass('totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizerMVC')
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

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA166' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA166' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA166' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA166' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA166' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","04")' OPERATION 4 ACCESS 0 //'Facilitador'
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
oModel	:=	MPFormModel():New('FISA166',{|oModel| CARGAORIGEM(oModel)},{|oModel| updAllStatus(oModel)})

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
    oView:AddUserButton( 'Facilitador','', {|oView| FSA171WIZ("2","04")} )
EndIF

If lProfStatus 
    oView:AddUserButton( 'Legenda', 'CLIPS', {|oModel| f166leg(oModel)} )
endIf

Return oView

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
Function FSA166GF24(cCodPerfil, cOper, cCodProd)

Local oModel := NIL
Local oProd := NIL
Local lRet := .F.

oModel := FWLoadModel("FISA166")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "04"))

    oModel:Activate()

    oProd := oModel:GetModel("FISA166PRODUTO")

    If cOper == "INCLUI"

        oProd:AddLine()
        oProd:SetValue("F24_CDPROD",cCodProd)
        IF lF24Tipo
            oProd:LoadValue("F24_TIPOPF" ,'04')
        Endif

    ElseIf cOper == "EXCLUI"

         If oProd:SeekLine( { {"F24_CDPROD", cCodProd } } )
            oProd:DeleteLine()
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

Local cDescr    := ""
Local cCodPro   := AllTrim(Upper(F24->F24_CDPROD))
Local lJson     := .F.
Local oModel := FWModelActive()

If Empty(cCodPro) .OR. oModel:GetOperation() == MODEL_OPERATION_INSERT
    Return cDescr
Elseif cCodPro == "TODOS"
    cDescr  := "TODOS OS PRODUTOS"    
Else
    
    lJson    := VALTYPE( oJSPROD ) == "J"
    
    if !lJson .or. cFilAtu <> cFilAnt
        lJson := ProduJs() 
        cFilAtu := cFilAnt
    EndIf

    If lJson .AND. Empty(cDescr)
        cRFilial := RTrim(oJSPROD:GetNames()[1]) //RTrim(cFil)
        If oJSPROD:hasproperty(cRFilial)
            cDescr  := oJSPROD[cRFilial][cCodPro]
        EndIf
    EndIf

    If Empty(cDescr)
        cDescr  := POSICIONE("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
    EndIf
Endif

Return cDescr

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
//-------------------------------------------------------------------
/*/{Protheus.doc} ProduJs

Cria um JSON com todos produtos dos perfis para melhorar a performance ao visualizar, 
alterar e excluir no perfil de produtos

@author Julia Mota
@since 05/09/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ProduJs()
Local cAlias  := ""
Local cQuery  := ""
Local lRet    := .F.
Local cFil    := " "
Local oQryTmp

	cQuery := " SELECT  SB1.B1_FILIAL FILIAL,SB1.B1_COD CODIGO,SB1.B1_DESC DESCR
	cQuery += " FROM ? SB1"
    cQuery += " WHERE SB1.B1_FILIAL = ? AND SB1.D_E_L_E_T_ = ' ' ORDER BY B1_FILIAL, B1_COD"

	oQryTmp := FwExecStatement():New(cQuery)
    oQryTmp:SetUnsafe(1, RetSQLName("SB1"))
    oQryTmp:setString(2, xFilial("SB1"))

    cAlias	:= oQryTmp:OpenAlias(GetNextAlias())
    
    oJSDetalhe := JsonObject():New()    
	
 	While (cAlias)->(!Eof())
        cFil := (cAlias)->FILIAL
        oJSDetalhe[Alltrim((cAlias)->CODIGO)] := Alltrim((cAlias)->DESCR)

		(cAlias)->(DbSkip())					
	EndDo	

    IF VALTYPE( oJSPROD ) == "J"    
        FREEOBJ(oJSPROD)
    Endif 

    oJSPROD    := JsonObject():New()

    If Len(oJSDetalhe:GetNames( )) > 0
        oJSPROD[RTrim(cFil)] := oJSDetalhe
        lRet := .T.
    EndIf
    
    (cAlias)->(dbCloseArea())
     FREEOBJ(oJSDetalhe)

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

	If ( lProfStatus .And. lProfOptim .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE ) )
        oProfileOptimizer := totvs.protheus.backoffice.fiscal.configurador.profiles.profileoptimizer.ProfileOptimizer():new()
        oProfileOptimizer:setProduct(cCodProd)
        oProfileOptimizer:setTypes('','PRODUCT')
        oProfileOptimizer:process()
        oProfileOptimizer:destroy()
        fwFreeObj(oProfileOptimizer)
    EndIf

Return
