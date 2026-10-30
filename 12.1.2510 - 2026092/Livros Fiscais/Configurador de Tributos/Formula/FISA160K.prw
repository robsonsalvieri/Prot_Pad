#Include "FISA160K.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160K()

Esta rotina tem objetivo de disponibilizar a opção de ajustes fiscais
para os tributos genéricos.

@author Renato Rezende
@since 20/08/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160K()
Local   oBrowse as object
Local   cFiltro as char

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ3")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SF3")
    oBrowse:SetDescription(STR0001) //"Acertos Fiscais Tributo Genérico"

     cFiltro := " R_E_C_N_O_ IN ( SELECT SF3.R_E_C_N_O_  FROM " + RetSQLName("SF3") + " SF3 "
     
     cFiltro += " INNER JOIN " + RetSQLName("SFT") + " SFT ON SFT.FT_FILIAL = " + ValToSql(xFilial("SFT")) + " AND SF3.F3_SERIE = SFT.FT_SERIE AND " 
     cFiltro += " SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 AND "
     cFiltro += " SF3.F3_ENTRADA = SFT.FT_ENTRADA AND SFT.FT_IDTRIB <> ' ' AND SFT.FT_DTCANC = ' ' AND SFT.D_E_L_E_T_ = ' ' "
     
     cFiltro += " WHERE SF3.F3_FILIAL = " + ValToSql(xFilial("SF3")) +  " AND SF3.F3_DTCANC = ' ' AND SF3.D_E_L_E_T_ = ' ' )"

    oBrowse:SetFilterDefault("@" + cFiltro)
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do configurador de tributos"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Renato Rezende
@since 20/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA160K' OPERATION 2 ACCESS 0 ///"Visualizar"
//ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.FISA160J' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA160K' OPERATION 4 ACCESS 0 //"Alterar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da regra de escrituração

@author Renato Rezende
@since 20/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local cCmpSFT as char
Local cCmpSF3 as char

//Criação do objeto do modelo de dados
Local oModel as object

//Estrutura Pai do cabeçalho da rotina
Local oSF3  as object
Local oSFT  as object

//Estrutura do grid
Local oTrbGen       := FWFormStruct(1, "CJ3" )

//Instanciando o modelo
oModel := MPFormModel():New('FISA160K')

//Campos para o cabeçalho:
cCmpSF3	:=	'F3_ENTRADA|F3_EMISSAO|F3_NFISCAL|F3_ESPECIE|F3_SERIE|F3_CLIEFOR|F3_LOJA|F3_ESTADO|F3_CFOP|F3_CODISS|F3_VALCONT|F3_CHVNFE|F3_IDENTFT|'
oSF3	:=	FwFormStruct( 1, 'SF3', {|x| AllTrim( x ) + "|" $ cCmpSF3 } )

//Campos para o cabeçalho:
cCmpSFT	:=	'FT_ITEM|FT_ENTRADA|FT_PRODUTO|FT_EMISSAO|FT_NFISCAL|FT_ESPECIE|FT_SERIE|FT_CLIEFOR|FT_LOJA|FT_ESTADO|FT_CFOP|FT_CODISS|FT_VALCONT|FT_CHVNFE|FT_IDENTF3|FT_TIPOMOV|FT_IDTRIB|'
oSFT	:=	FwFormStruct( 1, 'SFT', {|x| AllTrim( x ) + "|" $ cCmpSFT } )

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160K",,oSF3)

oSF3:SetProperty( '*'   , MODEL_FIELD_OBRIGAT,  .F. ) 
oSFT:SetProperty( '*'   , MODEL_FIELD_OBRIGAT,  .F. ) 

//Adicionando o grid dos itens da nota no livro
oModel:AddGrid( 'FISA160KSFT', 'FISA160K', oSFT )
oModel:GetModel('FISA160KSFT'):SetNoInsertLine(.T.)
oModel:GetModel('FISA160KSFT'):SetNoDeleteLine(.T.)
oModel:GetModel('FISA160KSFT'):SetNoUpdateLine(.T.)

//Adicionando o grid dos tributos genéricos
oModel:AddGrid( 'FISA160KTRIB', 'FISA160KSFT', oTrbGen, { |oModelGrid, nLine, cAction, cField| FSA160KPV(oModelGrid, nLine, cAction, cField)} )
oModel:GetModel('FISA160KTRIB'):SetNoInsertLine(.T.)
oModel:GetModel('FISA160KTRIB'):SetNoDeleteLine(.T.)

//Deixando o grid do tributos genéricos opcional
oModel:GetModel( 'FISA160KTRIB'   ):SetOptional( .T. )

//Não permite alterar o código da regra
oTrbGen:SetProperty('CJ3_TRIB' , MODEL_FIELD_KEY,  .T. )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //"Acertos Fiscais Tributo Genérico"

oModel:SetPrimaryKey({""})

//Order 3 - F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL + F3_IDENTFT
oModel:SetRelation( 'FISA160KSFT'       , { { 'FT_FILIAL', 'xFilial( "SFT" )' }, { 'FT_TIPOMOV', 'IIF(F3_CFO < "5","E","S")'} ,{ 'FT_CLIEFOR', 'F3_CLIEFOR'},{ 'FT_LOJA', 'F3_LOJA'},;
                                            { 'FT_SERIE', 'F3_SERIE'},{ 'FT_NFISCAL', 'F3_NFISCAL'},{ 'FT_IDENTF3', 'F3_IDENTFT'} }      , SFT->( IndexKey( 3 ) ) )

oModel:SetRelation( 'FISA160KTRIB'      , { { 'CJ3_FILIAL', 'xFilial( "CJ3" )' }, { 'CJ3_IDTGEN', 'FT_IDTRIB'} }      , CJ3->( IndexKey( 2 ) ) )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Renato Rezende
@since 20/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local cCmpSFT as char

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel        := FWLoadModel( "FISA160K" )

//Estrutura Pai do cabeçalho da rotina
Local oSFT as object

//Estrutura do grid
Local oTrbGen       := FWFormStruct(2, "CJ3" )
Local oView as object

oView:= FWFormView():New()
oView:SetModel( oModel )

//Campos para o cabeçalho:
cCmpSFT	:=	'FT_ITEM|FT_PRODUTO|FT_CFOP|FT_CODISS|FT_VALCONT||FT_IDENTF3|FT_IDTRIB|'
oSFT	:=	FwFormStruct( 2, 'SFT', {|x| AllTrim( x ) + "|" $ cCmpSFT } )

cCmpSF3	:=	'F3_ENTRADA|F3_EMISSAO|F3_NFISCAL|F3_ESPECIE|F3_SERIE|F3_CLIEFOR|F3_LOJA||F3_VALCONT|F3_CHVNFE|'
oSF3	:=	FwFormStruct( 2, 'SF3', {|x| AllTrim( x ) + "|" $ cCmpSF3 } )

//Atribuindo formulários para interface
oView:AddField('VIEW_CAB', oSF3, 'FISA160K')
oView:AddGrid('VIEW_ACERTOSTG', oSFT, 'FISA160KSFT')
oView:AddGrid( 'VIEW_TRIBUTO', oTrbGen, 'FISA160KTRIB')

//Não deixa editar nenhum campo do cabeçalho
oSFT:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
oSF3:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)

//Retira os campos da View
oSFT:RemoveField('FT_IDENTF3')
oSFT:RemoveField('FT_IDTRIB')
oTrbGen:RemoveField('CJ3_IDESCR')
oTrbGen:RemoveField('CJ3_IDRESC')
oTrbGen:RemoveField('CJ3_IDTGEN')
oTrbGen:RemoveField('CJ3_IDF2D')
oTrbGen:RemoveField('CJ3_DTEXCL')

//Cria três box
oView:CreateHorizontalBox( 'CAB'        , 30 )
oView:CreateHorizontalBox( 'SUPERIOR'   , 35 )
oView:CreateHorizontalBox( 'INFERIOR'   , 35 )

//Faz vínculo do box com a view
oView:SetOwnerView( 'VIEW_CAB'          , 'CAB' )
oView:SetOwnerView( 'VIEW_ACERTOSTG'    , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_TRIBUTO'      , 'INFERIOR' )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CAB'        , STR0005 ) //"Cabeçalho Livro Fiscal"
oView:EnableTitleView('VIEW_ACERTOSTG'  , STR0006 ) //"Itens do Livro Fiscal"
oView:EnableTitleView('VIEW_TRIBUTO'    , STR0007 ) //"Tributos"

//Ordem dos campos
oTrbGen:SetProperty("CJ3_TRIB"   , MVC_VIEW_ORDEM, "01")
oTrbGen:SetProperty("CJ3_CSTCAB" , MVC_VIEW_ORDEM, "02")
oTrbGen:SetProperty("CJ3_CST"    , MVC_VIEW_ORDEM, "03")


oSF3:SetProperty("F3_NFISCAL" , MVC_VIEW_ORDEM, "01")
oSF3:SetProperty("F3_SERIE" , MVC_VIEW_ORDEM,   "02")
oSF3:SetProperty("F3_ENTRADA" , MVC_VIEW_ORDEM, "03")
oSF3:SetProperty("F3_EMISSAO" , MVC_VIEW_ORDEM, "04")
oSF3:SetProperty("F3_ESPECIE" , MVC_VIEW_ORDEM, "05")
oSF3:SetProperty("F3_CLIEFOR" , MVC_VIEW_ORDEM, "06")
oSF3:SetProperty("F3_LOJA" , MVC_VIEW_ORDEM,    "07")
oSF3:SetProperty("F3_VALCONT" , MVC_VIEW_ORDEM, "08")
oSF3:SetProperty("F3_CHVNFE" , MVC_VIEW_ORDEM,  "09")

oSFT:SetProperty("FT_ITEM" , MVC_VIEW_ORDEM, "01")
oSFT:SetProperty("FT_PRODUTO"   , MVC_VIEW_ORDEM, "02")
oSFT:SetProperty("FT_CFOP" , MVC_VIEW_ORDEM, "03")
oSFT:SetProperty("FT_CODISS" , MVC_VIEW_ORDEM, "04")
oSFT:SetProperty("FT_CODISS" , MVC_VIEW_ORDEM, "05")


//Desabilitando opção de ordenação
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160KPV
Função de pre validação da linha do tribuot genérico
Aqui somente será permitido edição de linhas que possuir ao menos 1 tributo calculado

@author Erick Dias
@since 26/08/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160KPV(oModelGrid, nLine, cAction, cField)

Local oModel		:=	FWModelActive()
Local oModelCJ3	    := oModel:GetModel( 'FISA160KTRIB' )

oModelCJ3:GoLine( nLine)

Return !Empty(oModelCJ3:GetValue( 'CJ3_TRIB' ))
