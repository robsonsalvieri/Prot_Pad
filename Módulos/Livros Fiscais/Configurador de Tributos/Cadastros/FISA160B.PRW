#Include "FISA160B.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME FISA160B
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160B()

Esta rotina tem objetivo de realizar cadastro de regras para enquadramento 
pela NCM para calculo de IVA, Pauta, Majoração.

Esta rotina estará disponível somente na versão 12.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160B()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIS")
    oBrowse:SetDescription(STR0001) //"Cadastro Regras de Enquadramento por NCM"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0020,1,0) //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160B" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro de Unidade de Referência Fiscal

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel    := Nil

//Estrutura Pai do cabeçalho da rotina
Local oNcm      := FWFormStruct(1, "CIS" )

//Estrutura do grid
Local oTributo  := FWFormStruct(1, "CIT" )

Local lCIUCEST   := CIU->(FieldPos("CIU_CEST")) > 0
Local lCpAliTrb  := fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')
Local oStCfMVA   := Nil
Local oStCfPaut  := Nil
Local oStCfMajr  := Nil
Local oStCfAliq  := Nil
Local cCmpFolder := ''
Local bLinMva   := {||PosVldCIU("MVA", lCIUCEST)}//Validação da linha do grid
Local bLinPauta := {||PosVldCIU("PAUTA", lCIUCEST)}//Validação da linha do grid
Local bLinMaj   := {||PosVldCIU("MAJ", lCIUCEST)}//Validação da linha do grid
Local bLiAliq   := {||PosVldCIU("ALIQ", lCIUCEST)}//Validação da linha do grid

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160B',,{|oModel|VldPosModel(oModel)})

//Campos para a Aba de MVA:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MARGEM,CIU_MVAAUX,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMVA	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Pauta:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_UM,CIU_VIGINI,CIU_VIGFIM,CIU_VLPAUT,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfPaut	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Majoração:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MAJORA,CIU_MJAUX,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMajr	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Aliquota:
If lCpAliTrb
    cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_ALIQTR,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

    If lCIUCEST
        cCmpFolder += ',CIU_CEST'
    EndIf

    oStCfAliq	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )
EndIf

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160B",,oNcm)

//Adicionando o grid das variações do tributo
oModel:AddGrid( 'FISA160BTRIB'      , 'FISA160B'        , oTributo  )
oModel:AddGrid( 'FISA160BCFGMVA'	, 'FISA160BTRIB'	, oStCfMVA, , bLinMva)
oModel:AddGrid( 'FISA160BCFGPAUTA'	, 'FISA160BTRIB'    , oStCfPaut, , bLinPauta)
oModel:AddGrid( 'FISA160BCFGMAJOR'	, 'FISA160BTRIB'	, oStCfMajr, , bLinMaj)

If lCpAliTrb
    oModel:AddGrid( 'FISA160BCFGALIQ'	, 'FISA160BTRIB'	, oStCfAliq, , bLiAliq)
Endif

//Deixando as abas opcionais o preenchimento
oModel:GetModel( 'FISA160BTRIB'   ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGMVA'   ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGPAUTA' ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGMAJOR' ):SetOptional( .T. )

If lCpAliTrb
    oModel:GetModel( 'FISA160BCFGALIQ'  ):SetOptional( .T. )
EndIF

oTributo:SetProperty('CIT_TIPO'     ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("1")} )
oStCfMVA:SetProperty('CIU_TIPO'     ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("1")} )
oStCfPaut:SetProperty('CIU_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("2")} )
oStCfMajr:SetProperty('CIU_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("3")} )

If lCpAliTrb
    oStCfAliq:SetProperty('CIU_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("4")} )
Endif

//Não permite alterar a sigla do tributo
oNcm:SetProperty('CIS_CODNCM' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oNcm:SetProperty('CIS_CODNCM' , MODEL_FIELD_VALID,{||( VldCod(oModel) )})

//Define para não repetir os campos de ano e mês
oModel:GetModel( 'FISA160BTRIB' ):SetUniqueLine( { 'CIT_TRIB' } )

oTributo:SetProperty('CIT_IDNCM'    , MODEL_FIELD_OBRIGAT,  .F. )

oStCfMVA:SetProperty( 'CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
oStCfPaut:SetProperty('CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
oStCfMajr:SetProperty('CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 

oStCfMVA:SetProperty("CIU_ITEM"     , MODEL_FIELD_OBRIGAT,  .T. )
oStCfPaut:SetProperty("CIU_ITEM"	, MODEL_FIELD_OBRIGAT,  .T. )
oStCfMajr:SetProperty("CIU_ITEM"	, MODEL_FIELD_OBRIGAT,  .T. )

If lCpAliTrb
    oStCfAliq:SetProperty('CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. )
    oStCfAliq:SetProperty("CIU_ITEM"	, MODEL_FIELD_OBRIGAT,  .T. )
EndIf

oNcm:SetProperty('CIS_CODNCM'   , MODEL_FIELD_KEY,  .T. ) 

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //"Cadastro Regras de Enquadramento por NCM"

oModel:SetPrimaryKey({""})

oModel:SetRelation( 'FISA160BTRIB'      , { { 'CIT_FILIAL', 'xFilial( "CIT" )' }, { 'CIT_IDNCM', 'CIS_ID'}, { 'CIT_TIPO',"'1'" } }      , CIT->( IndexKey( 2 ) ) )
oModel:SetRelation( 'FISA160BCFGMVA'    , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'1'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )
oModel:SetRelation( 'FISA160BCFGPAUTA'  , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'2'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )
oModel:SetRelation( 'FISA160BCFGMAJOR'  , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'3'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )

If lCpAliTrb
    oModel:SetRelation( 'FISA160BCFGALIQ'   , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'4'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )
    oModel:GetModel('FISA160BCFGALIQ'):SetMaxLine(9999999)
EndIf

oModel:GetModel('FISA160BCFGMVA'):SetMaxLine(9999999)
oModel:GetModel('FISA160BCFGPAUTA'):SetMaxLine(9999999)
oModel:GetModel('FISA160BCFGMAJOR'):SetMaxLine(9999999)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160B" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oNcm      := FWFormStruct(2, "CIS")
Local oTributo  := FWFormStruct(2, "CIT")
Local oStCfMVA   := Nil
Local oStCfPaut  := Nil
Local oStCfMajr  := Nil
Local oStCfAliq  := Nil
Local oView      := Nil
Local cCmpFolder := ''
Local lCIUCEST   := CIU->(FieldPos("CIU_CEST")) > 0
Local lCpAliTrb  := fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')

oView := FWFormView():New()
oView:SetModel( oModel )

//Ajustando os campos que serão mostrados por abas
//Campos para a Aba de IVA:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MARGEM,CIU_MVAAUX,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMVA	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Pauta:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_UM,CIU_VIGINI,CIU_VIGFIM,CIU_VLPAUT,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfPaut	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Majoração:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MAJORA,CIU_MJAUX,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMajr	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Alíquotas:
If lCpAliTrb    
    cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_ALIQTR,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

    If lCIUCEST
        cCmpFolder += ',CIU_CEST'
    EndIf

    oStCfAliq	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )
EndIf

//Atribuindo formulários para interface
oView:AddField('VIEW_NCM'       , oNcm      , 'FISA160B'         )
oView:AddGrid( 'VIEW_TRIBUTO'   , oTributo  , 'FISA160BTRIB'     )
oView:AddGrid( 'VIEW_MVA'	    , oStCfMVA	, 'FISA160BCFGMVA'   )
oView:AddGrid( 'VIEW_PAUTA'	    , oStCfPaut	, 'FISA160BCFGPAUTA' )
oView:AddGrid( 'VIEW_MAJOR'	    , oStCfMajr	, 'FISA160BCFGMAJOR' )

If lCpAliTrb    
    oView:AddGrid( 'VIEW_ALIQTR'    , oStCfAliq	, 'FISA160BCFGALIQ'  )
Endif

//Retira os campos da View
oNcm:RemoveField('CIS_ID')
oTributo:RemoveField('CIT_ID')
oTributo:RemoveField('CIT_IDNCM')
oTributo:RemoveField('CIT_TIPO')
oTributo:RemoveField('CIT_NCM')
oTributo:RemoveField('CIT_ALIQ')
oTributo:RemoveField('CIT_CODISS')

oStCfMVA:RemoveField('CIU_ID')
oStCfMVA:RemoveField('CIU_IDNCM')
oStCfMVA:RemoveField('CIU_TIPO')
oStCfMVA:RemoveField('CIU_NCM')
oStCfMVA:RemoveField('CIU_TRIB')

oStCfPaut:RemoveField('CIU_ID')
oStCfPaut:RemoveField('CIU_IDNCM')
oStCfPaut:RemoveField('CIU_TIPO')
oStCfPaut:RemoveField('CIU_NCM')
oStCfPaut:RemoveField('CIU_TRIB')

oStCfMajr:RemoveField('CIU_ID')
oStCfMajr:RemoveField('CIU_IDNCM')
oStCfMajr:RemoveField('CIU_TIPO')
oStCfMajr:RemoveField('CIU_NCM')
oStCfMajr:RemoveField('CIU_TRIB')

If lCpAliTrb
    oStCfAliq:RemoveField('CIU_ID')
    oStCfAliq:RemoveField('CIU_IDNCM')
    oStCfAliq:RemoveField('CIU_TIPO')
    oStCfAliq:RemoveField('CIU_NCM')
    oStCfAliq:RemoveField('CIU_TRIB')
EndIf


//Cria três box
oView:CreateHorizontalBox( 'SUPERIOR'   , 18 )
oView:CreateHorizontalBox( 'MEIO'       , 37 )
oView:CreateHorizontalBox( 'INFERIOR'   , 45 )

//Cria o Folder Principal
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

//Cria as Abas Principais
oView:AddSheet( 'FOLDER'	, 'ABA_MVA'	        , STR0002 ) //"Margem de Valor Agregado"
oView:AddSheet( 'FOLDER'	, 'ABA_PAUTA'	    , STR0003 ) //"Pauta"
oView:AddSheet( 'FOLDER'	, 'ABA_MAJORACAO'	, STR0004 ) //"Majoração Alíquota"

If lCpAliTrb
    oView:AddSheet( 'FOLDER'	, 'ABA_ALIQTR'	    , STR0026 ) //"Alíquota do Tributo"
EndIf

//Cria box da aba de Principais
oView:CreateHorizontalBox( 'PAINEL_MVA'         , 100,,, 'FOLDER', 'ABA_MVA'        )
oView:CreateHorizontalBox( 'PAINEL_PAUTA'       , 100,,, 'FOLDER', 'ABA_PAUTA'      )
oView:CreateHorizontalBox( 'PAINEL_MAJORACAO'   , 100,,, 'FOLDER', 'ABA_MAJORACAO'  )

If lCpAliTrb
    oView:CreateHorizontalBox( 'PAINEL_ALIQTR'      , 100,,, 'FOLDER', 'ABA_ALIQTR'     )
EndIf

//Faz vínculo do box com a view
oView:SetOwnerView( 'VIEW_NCM'      , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_TRIBUTO'  , 'MEIO'        )

//Seta a View com seu respectivo Owner
oView:SetOwnerView( 'VIEW_NCM'      , 'SUPERIOR'        )
oView:SetOwnerView( 'VIEW_TRIBUTO'  , 'MEIO'            )
oView:SetOwnerView( 'VIEW_MVA'      , 'PAINEL_MVA'      )
oView:SetOwnerView( 'VIEW_PAUTA'    , 'PAINEL_PAUTA'    )
oView:SetOwnerView( 'VIEW_MAJOR'    , 'PAINEL_MAJORACAO')

If lCpAliTrb
    oView:SetOwnerView( 'VIEW_ALIQTR'   , 'PAINEL_ALIQTR')
EndIF

//Colocando título do formulário
oView:EnableTitleView('VIEW_NCM'    , STR0005 ) //'NCM'
oView:EnableTitleView('VIEW_TRIBUTO', STR0006 ) //'Tributos'
oView:EnableTitleView('VIEW_MVA'    , STR0007 ) //'Valores Auxiliares por Tributos( MVA )'
oView:EnableTitleView('VIEW_PAUTA'  , STR0008 ) //'Valores Auxiliares por Tributos( Pauta )'
oView:EnableTitleView('VIEW_MAJOR'  , STR0009 ) //'Valores Auxiliares por Tributos( Majoração de Alíquota )'

If lCpAliTrb
    oView:EnableTitleView('VIEW_ALIQTR' , STR0027 ) //"Valores Auxiliares por Tributos( Alíquota )"
EndIf

//Picture do campo Código NCM
oNcm:SetProperty('CIS_CODNCM' , MVC_VIEW_PICT, "@R 9999.99.99")

//Alterando a descrição de algns campos
oStCfMVA:SetProperty("CIU_ORIGEM"   , MVC_VIEW_TITULO, STR0010) //"Origem do Produto"
oStCfMVA:SetProperty("CIU_MVAAUX"   , MVC_VIEW_TITULO, STR0011) //"Índice Auxiliar do MVA"
oStCfPaut:SetProperty("CIU_VLPAUT"  , MVC_VIEW_TITULO, STR0012) //"Valor da Pauta"
oStCfPaut:SetProperty("CIU_UM"      , MVC_VIEW_TITULO, STR0013) //"Unidade de Medida do Produto"
oStCfMajr:SetProperty("CIU_MAJORA"  , MVC_VIEW_TITULO, STR0014) //"Percentual de Majoração"
oStCfMajr:SetProperty("CIU_MJAUX"   , MVC_VIEW_TITULO, STR0015) //"Índice Auxiliar de Majoração"
oStCfPaut:SetProperty("CIU_ORIGEM"  , MVC_VIEW_TITULO, STR0010) //"Origem do Produto"
oStCfMajr:SetProperty("CIU_ORIGEM"  , MVC_VIEW_TITULO, STR0010) //"Origem do Produto"


//Desabilita a edição do campo
oStCfMVA:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)
oStCfPaut:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)
oStCfMajr:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)

If lCpAliTrb
    oStCfAliq:SetProperty("CIU_ORIGEM"  , MVC_VIEW_TITULO, STR0010) //"Origem do Produto"
    oStCfAliq:SetProperty("CIU_ALIQTR"  , MVC_VIEW_TITULO, STR0028) //"Índice Auxiliar de Alíquota"
    oStCfAliq:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)
    oView:AddIncrementField( "VIEW_ALIQTR" , "CIU_ITEM" )
EndIf

//Definindo o campo como incremental
oView:AddIncrementField( "VIEW_MVA"    , "CIU_ITEM" )
oView:AddIncrementField( "VIEW_PAUTA"  , "CIU_ITEM" )
oView:AddIncrementField( "VIEW_MAJOR"  , "CIU_ITEM" )

//Ordem do grid de MVA
oStCfMVA:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfMVA:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfMVA:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfMVA:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfMVA:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
oStCfMVA:SetProperty("CIU_ORIGEM", MVC_VIEW_ORDEM, "06")

If lCIUCEST
    oStCfMVA:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "07")
    oStCfMVA:SetProperty("CIU_MARGEM", MVC_VIEW_ORDEM, "08")
    oStCfMVA:SetProperty("CIU_MVAAUX", MVC_VIEW_ORDEM, "09")
Else
    oStCfMVA:SetProperty("CIU_MARGEM", MVC_VIEW_ORDEM, "07")
    oStCfMVA:SetProperty("CIU_MVAAUX", MVC_VIEW_ORDEM, "08")
EndIf  

//Ordem do grid de Pauta
oStCfPaut:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfPaut:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfPaut:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfPaut:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfPaut:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
oStCfPaut:SetProperty("CIU_ORIGEM", MVC_VIEW_ORDEM, "06")
If lCIUCEST
    oStCfPaut:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "07")
    oStCfPaut:SetProperty("CIU_UM"    , MVC_VIEW_ORDEM, "08")
    oStCfPaut:SetProperty("CIU_VLPAUT", MVC_VIEW_ORDEM, "09")
Else
    oStCfPaut:SetProperty("CIU_UM"    , MVC_VIEW_ORDEM, "07")
    oStCfPaut:SetProperty("CIU_VLPAUT", MVC_VIEW_ORDEM, "08")
EndIf

//Ordem do grid de Majoração
oStCfMajr:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfMajr:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfMajr:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfMajr:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfMajr:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
oStCfMajr:SetProperty("CIU_ORIGEM", MVC_VIEW_ORDEM, "06")
If lCIUCEST
    oStCfMajr:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "07")
    oStCfMajr:SetProperty("CIU_MAJORA", MVC_VIEW_ORDEM, "08")
    oStCfMajr:SetProperty("CIU_MJAUX" , MVC_VIEW_ORDEM, "09")
Else
    oStCfMajr:SetProperty("CIU_MAJORA", MVC_VIEW_ORDEM, "07")
    oStCfMajr:SetProperty("CIU_MJAUX" , MVC_VIEW_ORDEM, "08")
EndIf

//Ordem do grid de Alíquota
If lCpAliTrb

    oStCfAliq:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
    oStCfAliq:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
    oStCfAliq:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
    oStCfAliq:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
    oStCfAliq:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
    oStCfAliq:SetProperty("CIU_ORIGEM", MVC_VIEW_ORDEM, "06")
    If lCIUCEST
        oStCfAliq:SetProperty("CIU_CEST"   , MVC_VIEW_ORDEM, "07")
        oStCfAliq:SetProperty("CIU_ALIQTR", MVC_VIEW_ORDEM, "08")
    Else
        oStCfAliq:SetProperty("CIU_ALIQTR", MVC_VIEW_ORDEM, "07")
    EndIf

EndIf

//Desabilitando opção de ordenação
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160TIPO
Função que retornar o código do tipo

@param		cOp       - String  -  Opção do Tipo do detalhamento da Atividade
@return     cOp       - String  -  Opção do Tipo do detalhamento da Atividade

@author Renato Rezende
@since 15/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function FSA160TIPO(cOp)
Return cOp

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldCIU
Função que realiza a validação de pós edição da linha do grid dos valores
@param		cOpcap  - String    - Opção com identificador de qual modelo a validação foi envocada
@Return     lRet    - Booleano  - REtorno com validação, .T. pode prosseguir, .F. não poderá prosseguir

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function PosVldCIU(cOpcao, lCIUCEST)
Local oModel		:= FWModelActive()
Local dDtIni        := ctod("  /  /    ")
Local dDtFim        := ctod("  /  /    ")
Local nTamGrid	    := 0
Local nX            := 0
Local nLnAtual      := 0
Local cUfOri        := ""
Local cUfDest       := ""
Local cMsgErro      := ""
Local cUndMedida    := ""
Local cOrigProd     := ""
Local cItemAtu      := ""
Local lChkVigIni    := .T.
Local lChkVigFim    := .T.
Local lErro         := .F.
Local oGrid         := nil
Local cCodCEST      := ""

Default lCIUCEST    := .F.

//Obtenho as informações para serem validadas
If cOpcao == "MVA" //Grid de MVA
    oGrid       := oModel:GetModel("FISA160BCFGMVA")
    cOrigProd   := oGrid:GetValue("CIU_ORIGEM")
    If lCIUCEST
        cCodCEST    := oGrid:GetValue("CIU_CEST")
    EndIf
ElseIf cOpcao == "PAUTA" //Grid De Paura
    oGrid       := oModel:GetModel("FISA160BCFGPAUTA")
    cOrigProd   := oGrid:GetValue("CIU_ORIGEM")
    cUndMedida  := oGrid:GetValue("CIU_UM")
    If lCIUCEST
        cCodCEST    := oGrid:GetValue("CIU_CEST")
    EndIf
ElseIf cOpcao == "MAJ" //grid de Majoração
    oGrid    := oModel:GetModel("FISA160BCFGMAJOR")
    cOrigProd   := oGrid:GetValue("CIU_ORIGEM")
    If lCIUCEST
        cCodCEST := oGrid:GetValue("CIU_CEST")
    EndIf
ElseIf cOpcao == "ALIQ" //grid de Aliquota
    oGrid    := oModel:GetModel("FISA160BCFGALIQ")
    cOrigProd   := oGrid:GetValue("CIU_ORIGEM")
    If lCIUCEST
        cCodCEST := oGrid:GetValue("CIU_CEST")
    EndIf
EndIF

//Obtenho os valores do grid
nTamGrid := oGrid:Length()
cUfOri   := oGrid:GetValue("CIU_UFORI")
cUfDest  := oGrid:GetValue("CIU_UFDEST")
dDtIni   := oGrid:GetValue("CIU_VIGINI")
dDtFim   := oGrid:GetValue("CIU_VIGFIM")
cItemAtu := oGrid:GetValue("CIU_ITEM") 
nLnAtual := oGrid:Getline()

//Itero as linhas para verificar as UFs de origem e destino
For nX := 1 to nTamGrid
    
    //Muda linha do grid
    oGrid:GoLine(nX)
    
    //Verifico se a linha está deletada. Se estiver irei para próxima linha válida
    //Verifico também se não estou validando a própria linha
    If nLnAtual <> nX .And. !oGrid:IsDeleted() 

        //Verifico se a origem e destino são iguais. Se não passar no check de origem e destino precisa fazer os demais checks
        If !ChkOriDest(cUfOri, cUfDest, oGrid)
            
            //Se possuem mesma origem e destino, então preciso verificar a vigência            
            //Primeiro faço Check da vigência inicial
            lChkVigIni := ChkVigIni(dDtIni, oGrid)
            
            //Depois faço Check da vigência final
            lChkVigFim := ChkVigFim(dDtFim, oGrid)

            If cOpcao == "MVA"
                //Validação do MVA
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkOriPrd(cOrigProd, oGrid) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            ELseIf cOpcao == "PAUTA"
                //VAlidação da Pauta
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkOriPrd(cOrigProd, oGrid, .T.) .And. !ChkUndMed(cUndMedida, oGrid) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            ELseIf cOpcao == "MAJ"
                //VAlidação da Majoração
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkOriPrd(cOrigProd, oGrid, .T.) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            ELseIf cOpcao == "ALIQ"
                //VAlidação da Aliquota
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkOriPrd(cOrigProd, oGrid, .T.) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            EndIF

            //Mensagem para identificar a linha que está divergente com a linha atual do grid
            If lErro
                cMsgErro := STR0023 + cItemAtu + STR0024  + oGrid:GetValue("CIU_ITEM") + " )" + CRLF //"Linha atual(Item: " -- ") está em conflito de vigência com linha já cadastrada(Item: "                
                //Restauro a linha inicial do grid antes de saír da função
                oGrid:GoLine(nLnAtual)
                HELP(' ',1, STR0021 ,, cMsgErro ,2,0,,,,,, {STR0022} ) //"Inconsistência de valores" -- "Verifique a vigência das informações"
                Return .F.
            EndIF

        EndIF

    EndIF

Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOriDest
Função que faz check de of origem e destino.

@param		cUfOri  - String    - UF origem da linha que está sendo validada
@param		cUfDest  - String    - UF Destino da linha que está sendo validada
@param		oGrid  - Objeto    - OBjeto com as informações do grid validado

@Return     lRet    - Booleano  - Rrtorno com validação, .T. possui origem e destino diferentes, .F. possuem mesmas origem e destino

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkOriDest(cUfOri, cUfDest, oGrid)

Local lRet  := .T.

//Verifica se origem e destino são iguais/correspondentes
//Os asteríscos significam todos os Estados.
If (cUfOri  == oGrid:GetValue("CIU_UFORI")  .OR. cUfOri  == "**" .Or. oGrid:GetValue("CIU_UFORI")  == "**") .AND.;
   (cUfDest == oGrid:GetValue("CIU_UFDEST") .OR. cUfDest == "**" .Or. oGrid:GetValue("CIU_UFDEST") == "**" )
    lRet  := .F. //Aqui significa que possuem mesma origem e destino
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkVigIni
Função que faz check da data inicial da vigência.

@param		dDtIni  - Date    - Data Inicial da linha que está sendo editada
@param		oGrid  - Objeto    - OBjeto com as informações do grid validado
@Return     lRet    - Booleano  - Rrtorno com validação, .T. data inicial não está contida em nenhum outro range

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkVigIni(dDtIni, oGrid)

Local lRet  := .T.

//Verifica se está compreendido em cadastro somente com data inicial preenchida
//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
If dDtIni >= oGrid:GetValue("CIU_VIGINI") .And. ;
    (Empty(oGrid:GetValue("CIU_VIGFIM")) .Or. dDtIni <= oGrid:GetValue("CIU_VIGFIM"))

    //Aqui a data inicial está contida em outro range, deve retornar mensagem de erro
    lRet    := .F.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkVigFim
Função que faz check da data final da vigência.

@param		dDtFim  - Date    - Data Final da linha que está sendo editada
@param		oGrid  - Objeto    - OBjeto com as informações do grid validado
@Return     lRet    - Booleano  - Rrtorno com validação, .T. data final não está contida em nenhum outro range

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkVigFim(dDtFim, oGrid)
Local lRet  := .T.

If Empty(dDtFim)
    //Se a data estiver vazia, então não poderia ter outra data vazia
    IF Empty(oGrid:GetValue("CIU_VIGFIM"))
        //Aqui significa que já existe uma linha com data de vigência vazia
        lRet := .F.
    EndIf

ElseIF dDtFim >= oGrid:GetValue("CIU_VIGINI") .And. ;
       (Empty(oGrid:GetValue("CIU_VIGFIM")) .OR. dDtFim <= oGrid:GetValue("CIU_VIGFIM"))
    //Aqui a data final está contida em algum range
    //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOriPrd
Função que faz check da origem do produto

@param		cOriPrd  - String    - Origem do produto da linha que está sendo editada
@param		oGrid  - Objeto    - Objeto com as informações do grid validado
@param		lPermitirVazio  - Booleano  - Indica se a origem do produto pode estar vazia

@Return     lRet    - Booleano  - Retorno com validação, .T. origem do produto é diferente

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------

Static Function ChkOriPrd(cOriPrd, oGrid, lPermitirVazio)
Local cGridOrigem      := oGrid:GetValue("CIU_ORIGEM")
Local lOrigemValida    := .T.
Default lPermitirVazio := .F.

// Verifica se a origem do produto é igual à origem do grid ou se ambas são asteriscos
If cOriPrd == cGridOrigem .Or. cOriPrd == "*" .Or. cGridOrigem == "*"
    Return .F.
EndIF

// Verificação se a origem do produto pode estar vazia
If lPermitirVazio .And. (Empty(cOriPrd) .Or. Empty(cGridOrigem))
    Return .F.
EndIF

Return lOrigemValida

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkUndMed
Função que faz check da unidade de medida

@param		cUndMed  - String    - Unidade de medida da linha que está sendo editada
@param		oGrid  - Objeto    - OBjeto com as informações do grid validado
@Return     lRet    - Booleano  - Rrtorno com validação, .T. unidade de medida é diferente

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkUndMed(cUndMed, oGrid)
Local lRet  := .T.

//Os asteríscos significam todas as unidade de medida
If cUndMed == oGrid:GetValue("CIU_UM") .Or. cUndMed == "**" .Or. oGrid:GetValue("CIU_UM") == "**"
    lRet    := .F.
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCEST
Função que faz check do Código CEST

@param cCodCEST - String    - Código CEST da linha que está sendo editada
@param oGrid    - Objeto    - Objeto com as informações do grid validado

@Return lRet     - Booleano  - Retorno com validação, .T. código CEST é diferente

@author pereira.weslley
@since 20/01/2023
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
Local lRet  := .T.

If lCIUCEST
    If cCodCEST == oGrid:GetValue("CIU_CEST")
        lRet    := .F.
    EndIF

    If nTamGrid > 1 .And. (Empty(oGrid:GetValue("CIU_CEST")) .And. !Empty(cCodCEST)) .Or. (!Empty(oGrid:GetValue("CIU_CEST")) .And. Empty(cCodCEST))
        lRet    := .F.
    EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPosModel
Função que realiza o pos processamento do modelo
Aqui basicamente atualizarei os Ids dos modelos, pois na cópia os Ids são copiados também, 
causando erro de chave duplicada. Poderia marcar os campos de IDs como chaves, e eles não seriam
copiados, porém nada seria copiado, já que o relacionamento é em função do Id.
Portanto estou atualizando manualmente os IDs dos modelos para possibilitar a funcionalidade da cópia

@param		oModel  - Objeto    - Objeto do modelo
@Return     lRet    - Booleano  - Retornar .T. para prosseguir com gravação do modelo

@author Erick Dias
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function VldPosModel(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cIdCIS        := ""
Local cIdCIT        := ""
Local nX            := 0
Local nTam          := 0
Local oNcm          := nil
Local oTrib         := nil
Local lCpAliTrb  := fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')

//Somente para operções de inclusão(cópia também)
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
    
    //-----------------------------
    //Atribui o ID para o cabeçalho
    //-----------------------------
    oNcm    := oModel:GetModel("FISA160B")
    cIdCIS  := FWUUID("CIS")
    
    If nOperation == MODEL_OPERATION_INSERT
        oNcm:SetValue('CIS_ID', cIdCIS) //Chave da CIS
    EndIF

    //-----------------------------------
    //Atribui o ID para o grid do tributo
    //-----------------------------------
    oTrib := oModel:GetModel("FISA160BTRIB")
    nTam  := oTrib:Length()

    //Laço no grid do tributo
    For nX := 1 to nTam
        oTrib:GoLine(nX)
        cIdCIT := FWUUID("CIT")
        
        If nOperation == MODEL_OPERATION_INSERT
            oTrib:SetValue('CIT_ID'   , cIdCIT) //Chave da CIT
            oTrib:SetValue('CIT_IDNCM', cIdCIS) //Chave estrangeira com CIS
        EndIf
        
        oTrib:SetValue('CIT_NCM', oNcm:GetValue('CIS_CODNCM')) //Grava o código do NCM

        //--------------------------------------
        //Atribui o ID para os grids dos valores
        //--------------------------------------        
        //Grid do MVA
        AtuIdCIU(oModel, "FISA160BCFGMVA"  , cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        //Grid da Pauta
        AtuIdCIU(oModel, "FISA160BCFGPAUTA", cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        //Grid da Majoração
        AtuIdCIU(oModel, "FISA160BCFGMAJOR", cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        //Grid da Alíquota
        If lCpAliTrb
            AtuIdCIU(oModel, "FISA160BCFGALIQ" , cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        EndIf
 
    Next nX

Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuIdCIU
Função que possui a atualização da tabela CIU, como é em comum para todos os 
grids de valores, então encapsulei em uma função só.

@param		oModel  - Objeto    - Objeto do modelo
@param		cModel  - String    - Nome do modelo
@param		cIdCIT  - String    - Id da tabela CIT(chave estrangeira)

@author Erick Dias
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function AtuIdCIU(oModel, cModel, cIdCIT, cNCM, nOperation)

Local nX        := 0
Local oCIU      := oModel:GetModel(cModel)
Local nTamFilho := oCIU:Length()
Local nItem     := 0

//Atualiza todos os itens da CIU
For nX := 1 to nTamFilho
    oCIU:GoLine(nX)
    
    If nOperation == MODEL_OPERATION_INSERT
        oCIU:SetValue('CIU_ID'   , FWUUID("CIU")) //Id da CIU
        oCIU:SetValue('CIU_IDNCM', cIdCIT       ) //Chave estrangeira com CIT
    EndIf
    
    
    If EMPTY( oCIU:getvalue('CIU_ITEM'))
        nItem := nTamFilho
        oCIU:SetValue('CIU_ITEM', strZero(nItem, 4) )
    Endif

    oCIU:SetValue('CIU_NCM', cNCM       ) //Código do NCM

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Função que valida se o código de regra por ncm já existe

@author Renato Rezende
@since 26/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160B',"CIS_CODNCM")
Local lRet      := .T.

dbSelectArea("SYD")
dbSetOrder(1) 
//Verifica se o código de NCM está devidamente cadastrado na SYD
If !SYD->( MsSeek ( xFilial('SYD') + cCodigo ) )
    Help( ,, 'Help',, STR0025, 1, 0 )  //"Código NCM inválido."
    return .F.    
EndIF

//Procura se já existe regra com o mesmo código
If CIS->( MsSeek ( xFilial('CIS') + cCodigo ) )
    Help( ,, 'Help',, STR0016, 1, 0 )  //"Código NCM já cadastrado."
    return .F.    
EndIF

Return lRet
