#include "protheus.ch"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"
#include "FISA163.ch"

Static lF21Tipo := F21->(Fieldpos("F21_TIPOPF")) > 0

PUBLISH MODEL REST NAME FISA163
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA163()

Motor de cálculo tributário fiscal. 
Esta rotina faz o Cadastro dos perfis de Origem e Destino.
Permite a definição de grupos de origem e destino, condiderando as Unidades
Federativas.

Estes grupos são utilizados no cálculo de tributos genéricos.

@author Vogas Júnior
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA163()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F20") .AND. AliasIndic("F21") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0002) // Cadastro dos Perfis de Origem e Destino
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '01'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0001,1,0) // Dicionário desatualizado, verifique as atualizações do motor  fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar menu

@author Vogas Júnior
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA163' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA163' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA163' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA163' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA163' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","01")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F21

@author Vogas Júnior
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela de perfil F20
Local oCabecalho := FWFormStruct(1, "F20" )

//Estrutura das origens de destino considerando a tabela F21
Local oOrigemDestino := FWFormStruct(1, "F21" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA163')

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA163",,oCabecalho)

//Adicionando o grid das origens e destino
oModel:AddGrid( 'FISA163ORIGEMDESTINO', 'FISA163', oOrigemDestino)
//oModel:GetModel( 'FISA163ORIGEMDESTINO' ):SetUseOldGrid()

//Inicializa o campo F20_TIPO com ´conteúdo "01" que significa tipo de perfil de origem e destino
oCabecalho:SetProperty('F20_TIPO' , MODEL_FIELD_INIT ,{||"01"} )

IF lF21Tipo
    oOrigemDestino:SetProperty('F21_TIPOPF' , MODEL_FIELD_INIT ,{||"01"} )
Endif

//Retira obrigatoriedade do campo F21_CODIGO
oOrigemDestino:SetProperty('F21_CODIGO' , MODEL_FIELD_OBRIGAT,  .F. )

//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA163', '01') )})

//Não permite repetir origem e destino dentro de um mesmo perfil
oModel:GetModel('FISA163ORIGEMDESTINO'):SetUniqueLine({  'F21_UFORI', 'F21_UFDEST'})

//Relacionamento entre as tabelas F20 Perfil com F21 origens
oModel:SetRelation( 'FISA163ORIGEMDESTINO', { { 'F21_FILIAL', 'xFilial("F21")' }, { 'F21_CODIGO', 'F20_CODIGO' }, {'01', 'F20_TIPO'} }, F21->( IndexKey( 1 ) ) )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0002) // Cadastro dos Perfis de Origem e Destino

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Vogas Júnior
@since 20/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA163" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho    := FWFormStruct(2, "F20")
Local oOrigemDestino:= FWFormStruct(2, "F21")
Local oView         := Nil
Local cVersao       := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO'    , oCabecalho  , 'FISA163'         )
oView:AddGrid(  'VIEW_ORIGEMDESTINO', oOrigemDestino    , 'FISA163ORIGEMDESTINO'  )

//Habilitando opções de filtros 
oView:SetViewProperty('VIEW_ORIGEMDESTINO', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_ORIGEMDESTINO', "GRIDSEEK", {.T.})

//Retira os campos da View
oCabecalho:RemoveField( 'F20_TIPO' )
oOrigemDestino:RemoveField( 'F21_CODIGO'  )

IF lF21Tipo
    oOrigemDestino:RemoveField('F21_TIPOPF')
Endif

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ORIGEMDESTINO'     , 'INFERIOR'    )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO'      , STR0002 )
oView:EnableTitleView('VIEW_ORIGEMDESTINO'  , STR0003 ) 

//Picture do campo código
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

//Adiciona botão do Facilitador
If FindFunction("FSA171WIZ")
    oView:AddUserButton( 'Facilitador','', {|oView| FSA171WIZ("2","01")} )
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteCarga
Função que fará verificação se já existe carga de UFs criada nas tabelas F20 e F21.
Se houver então retornará verdadeiro, caso contrário retornará falso.

@Return     lRet    - Boolean  - Retorna .T. caso exista ao menos 1 anexo cadastrado.

@author Vogas Júnior
@since 20/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ExisteCarga()

Local lRet      := .F.
Local aAreaF20  := F20->(GetArea())

dbSelectArea('F20')
dbSetOrder(2)

//Se houver ao menos uma linha criada na tabela F20 com o perfil origem e destino, a rotina não fará a carga inicial.
If	F20->( MsSeek ( xFilial('F20') + '01' ) )
    lRet:= .T.
EndIF

RestArea(aAreaF20)
Return lRet
/*-------------------------------------------------------------------
//{Protheus.doc} FSA163CARG
Função que fará chamdas da criação das cargas iniciais

@author Vogas Júnior
@since 20/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA163CARG()

Local nX         := 0
Local aUFs       := {}
Local aContentX5 := {}

//Se não houver nenhuma relação origem/destino cadastrada, fará a carga das informações iniciais.
If !ExisteCarga()
    aContentX5 := FWGetSX5( "12" )

    For nX := 1 To Len( aContentX5 )        
        
        aAdd( aUFs, Alltrim(aContentX5[nX][3]))
        
    Next

    //Popula Operações Internas(1), Todas as UFs(2), Saídas Interestaduais(3), Entradas Interestaduais(4).
	Begin Transaction
        For nx := 1 To 4
            CriaUF_OD(nX, aUFs)
        Next nX
    End Transaction
EndIF

Return

/*/-------------------------------------------------------------------
//{Protheus.doc} CriaUF_OD
Popula combinações de UF Origem e Destino das tabelas F20, F21

@param	nOp - Integer   - 1=Op. Internas, 2=Todas UFs, 3=Saídas Interestaduais, 4=Entradas Interestaduais
@param	aUfs- Array     - Unidades Federativas cadastradas no SX5

@author Vogas Júnior
@since 20/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriaUF_OD(nOp, aUFs)

Local cUF       := AllTrim(SuperGetMV("MV_ESTADO"))

Do Case 
    Case nOp = 1 //Grava Operações Internas
        GrvCombUF( nOp, '000001',STR0004, cUF, aUFs) //'Operações Internas'
    Case nOp = 2 //Grava Todas as UFs
        GrvCombUF( nOp, '000002',STR0005, cUF, aUFs) //'Todas as UFs'
    Case nOp = 3 //Grava Saídas Interestaduais
        GrvCombUF( nOp, '000003',STR0006, cUF, aUFs) //Saídas Interestaduais'
    Case nOp = 4 //Grava Entradas Interestaduais
        GrvCombUF( nOp, '000004',STR0007, cUF, aUFs) //Entradas Interestaduais'
EndCase

Return 

/*/-------------------------------------------------------------------
//{Protheus.doc} GrvCombUF

Função responsável por realizar a carga inicial das combinações de UF
@param		nOp     - Integer       -  1=Op. Internas, 2=Todas UFs, 3=Saídas Interestaduais, 4=Entradas Interestaduais
@param		cCodOp  - String        -  Código da Operação
@param		cDescOp	- String        -  Descrição do perfil Origem Destino
@param		UFori   - String/array  -  UF(s) de Origem
@param		UfDest  - String/Array  -  UF(s) de Destino

@author Vogas Júnior
@since 20/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function GrvCombUF( nOp, cCodOp, cDescOp, cUF,aUFs )

Local nX        := 0
Local nV        := 0

RecLock('F20',.T.)
F20->F20_FILIAL := xFilial("F20")
F20->F20_CODIGO := cCodOp
F20->F20_TIPO   := '01'
F20->F20_DESC   := cDescOp
F20->(msUnlock())

Do Case 
    Case nOp = 1 //Operações Internas

        FSA163GF21(cCodOp, cUF, cUF)            

    Case nOp = 2 //Todas UFs 

        For nX = 1 to Len( aUFs )             
            For nV = 1 To Len( aUFs )
                FSA163GF21(cCodOp, aUFs[nX], aUFs[nV])
            Next nV
        Next nX
        
    Case nOp = 3 .Or. nOp = 4 //Entradas e Saídas Interestaduais

        For nX = 1 to Len( aUFs )
            If aUFs[nX] <> cUF    
                If nOp = 3
                    FSA163GF21(cCodOp, cUF, aUFs[nX])
                Else
                    FSA163GF21(cCodOp, aUFs[nX], cUF)
                EndIf
            EndIf
        Next nX

EndCase

Return  
/*/-------------------------------------------------------------------
//{Protheus.doc} FSA163GF21

Função de persistência de dados da tabela F21
@param		cCodOp  - String        -  Código da Operação
@param		UFori   - String/array  -  UF(s) de Origem
@param		UfDest  - String/Array  -  UF(s) de Destino

@author Vogas Júnior
@since 22/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA163GF21(cCodOp, cUfOri, cUfDest)

RecLock('F21',.T.)
F21->F21_FILIAL := xFilial("F21")
F21->F21_CODIGO := cCodOp
F21->F21_UFORI  := cUfOri
F21->F21_UFDEST := cUfDest
IF lF21Tipo
    F21->F21_TIPOPF := '01'
Endif
F21->(msUnlock())    

Return


/*/{Protheus.doc} AtuTpPF01
    (Atualiza novo campo F21_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF01()

IF lF21Tipo
    cQuery := "UPDATE " +  RetSqlName('F21') + " SET F21_TIPOPF = '01' WHERE F21_FILIAL = " + ValToSql(xFilial('F21')) + " AND F21_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif

Return
