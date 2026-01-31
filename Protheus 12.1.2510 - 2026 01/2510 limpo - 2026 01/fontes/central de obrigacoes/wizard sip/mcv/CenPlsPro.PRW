#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPlsPro

Manutencao de Produtos de Saúde

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CenPlsPro(cTela)
    Local oBrowse	:= Nil
    Default cTela   := "1"
    Private lInfAns := cTela == "2"

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('BI3')

    If cTela == "1"
        cFiltro  := "BI3_FILIAL=B3D->B3D_FILIAL .And. BI3_CODINT='"+BuscaOper(B3D->B3D_CODOPE)+"' .And. BI3_GRUPO='001' .And. (BI3_CODSEG ='' .Or. BI3_TIPCON = '')"
        oBrowse:SetDescription("SIP - Os Produtos abaixo estão com um dos campos em Branco: Segmentacao (BI3_CODSEG), Tp.Contrato (BI3_TIPCON). Favor ajustar.")
    Else
        cFiltro  := "BI3_FILIAL=B3D->B3D_FILIAL .And. BI3_CODINT='"+BuscaOper(B3D->B3D_CODOPE)+"' .And. BI3_GRUPO='001' .And. BI3_INFANS <> '1' "
        oBrowse:SetDescription("SIP - Os Produtos abaixo estão com o campo Considera ANS diferente de Sim.")
    EndIf

    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetMenuDef( 'CenPlsPro' )
    oBrowse:Activate()

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Private aRotina	:= {}

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CenPlsPro'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CenPlsPro'   , 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BI3

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruBI3 	:= FWFormStruct( 1, 'BI3', , )
    Local oModel	:= Nil

    oModel:= MPFormModel():New( "SIP - Produtos de Saúde")
    oModel:AddFields( 'BI3MASTER', , oStruBI3 )
    oModel:GetModel( 'BI3MASTER' ):SetDescription( "SIP - Produtos de Saúde" )
    oModel:SetPrimaryKey( {"BI3_FILIAL","BI3_CODINT","BI3_CODIGO","BI3_VERSAO"} )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BI3
@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'CenPlsPro' )
    Local oStruBI3 := FWFormStruct( 2, 'BI3' )
    Local oView    := FWFormView():New()

    oStruBI3:RemoveField('BI3_ALLRED')
    oStruBI3:RemoveField('BI3_ALLCRE')
    oStruBI3:RemoveField('BI3_ALLUSR')
    oStruBI3:RemoveField('BI3_DESCAR')
    oStruBI3:RemoveField('BI3_TAXDIA')
    oStruBI3:RemoveField('BI3_COBJUR')
    oStruBI3:RemoveField('BI3_JURDIA')
    oStruBI3:RemoveField('BI3_NATURE')
    oStruBI3:RemoveField('BI3_TIPTIT')
    oStruBI3:RemoveField('BI3_COBRAT')
    oStruBI3:RemoveField('BI3_RATMAI')
    oStruBI3:RemoveField('BI3_TODOS')
    oStruBI3:RemoveField('BI3_RATSAI')
    oStruBI3:RemoveField('BI3_CPFM')
    oStruBI3:RemoveField('BI3_DTRGPR')
    oStruBI3:RemoveField('BI3_DTAPPR')
    oStruBI3:RemoveField('BI3_ALLOPE')
    oStruBI3:RemoveField('BI3_MUDFAI')
    oStruBI3:RemoveField('BI3_ANOMES')
    oStruBI3:RemoveField('BI3_INFCOB')
    oStruBI3:RemoveField('BI3_INFGCB')
    oStruBI3:RemoveField('BI3_INFCBU')
    oStruBI3:RemoveField('BI3_LIMTXA')
    oStruBI3:RemoveField('BI3_PADSAU')
    oStruBI3:RemoveField('BI3_DESSAU')
    oStruBI3:RemoveField('BI3_MODCON')
    oStruBI3:RemoveField('BI3_VL2BOL')
    oStruBI3:RemoveField('BI3_CODPTU')
    oStruBI3:RemoveField('BI3_CONTA')
    oStruBI3:RemoveField('BI3_CC')
    oStruBI3:RemoveField('BI3_NATJCO')
    oStruBI3:RemoveField('BI3_IDECAR')
    oStruBI3:RemoveField('BI3_HSPPLA')
    oStruBI3:RemoveField('BI3_FATMUL')
    oStruBI3:RemoveField('BI3_RISCO')
    oStruBI3:RemoveField('BI3_GRUCOM')
    oStruBI3:RemoveField('BI3_DESMEN')
    oStruBI3:RemoveField('BI3_COBCPF')
    oStruBI3:RemoveField('BI3_FORFAT')
    oStruBI3:RemoveField('BI3_REEMB')
    oStruBI3:RemoveField('BI3_CODSB1')
    oStruBI3:RemoveField('BI3_CODTES')
    oStruBI3:RemoveField('BI3_SCPA')
    oStruBI3:RemoveField('BI3_PORTAL')
    oStruBI3:RemoveField('BI3_QTDUS')
    oStruBI3:RemoveField('BI3_REDEDI')
    oStruBI3:RemoveField('BI3_QTDPUS')
    oStruBI3:RemoveField('BI3_UNIPUS')
    oStruBI3:RemoveField('BI3_CONRPC')
    oStruBI3:RemoveField('BI3_TPCONT')
    oStruBI3:RemoveField('BI3_TPBEN')
    oStruBI3:RemoveField('BI3_ABRCAR')
    oStruBI3:RemoveField('BI3_SITANS')
    oStruBI3:RemoveField('BI3_CLAPLS')
    oStruBI3:RemoveField('BI3_GUIMED')
    oStruBI3:RemoveField('BI3_REDREF')
    oStruBI3:RemoveField('BI3_TPFORN')
    oStruBI3:RemoveField('BI3_TPREDI')
    oStruBI3:RemoveField('BI3_MXDRMB')
    oStruBI3:RemoveField('BI3_VMIRMB')
    oStruBI3:RemoveField('BI3_TABCOP')
    oStruBI3:RemoveField('BI3_RRFDES')
    oStruBI3:RemoveField('BI3_LATEDI')
    oStruBI3:RemoveField('BI3_CLASSE')
    oStruBI3:RemoveField('BI3_MOTDOC')
    oStruBI3:RemoveField('BI3_DROGAR')
    oStruBI3:RemoveField('BI3_TIPRED')
    oStruBI3:RemoveField('BI3_EMPIND')
    oStruBI3:RemoveField('BI3_LCVIRT')
    oStruBI3:RemoveField('BI3_CARVIR')
    oStruBI3:RemoveField('BI3_SUSEP')
    oStruBI3:RemoveField('BI3_APOSRG')
    oStruBI3:RemoveField('BI3_CODACO')
    oStruBI3:RemoveField('BI3_MODPAG')
    oStruBI3:RemoveField('BI3_ABRANG')
    oStruBI3:RemoveField('BI3_DESACO')
    oStruBI3:RemoveField('BI3_DESABR')


    oStruBI3:SetProperty( 'BI3_DESCRI' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_NREDUZ' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_GRUPO'  ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_TIPPLA' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_CODANT' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_STATUS' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI3:SetProperty( 'BI3_TIPO'   ,MVC_VIEW_CANCHANGE,.f.)

    IF lInfAns
        oStruBI3:SetProperty( 'BI3_TIPCON'   ,MVC_VIEW_CANCHANGE,.f.)
        oStruBI3:SetProperty( 'BI3_DESCON'   ,MVC_VIEW_CANCHANGE,.f.)
        oStruBI3:SetProperty( 'BI3_CODSEG'   ,MVC_VIEW_CANCHANGE,.f.)
        oStruBI3:SetProperty( 'BI3_DESSEG'   ,MVC_VIEW_CANCHANGE,.f.)
    Else
        oStruBI3:SetProperty( 'BI3_INFANS'   ,MVC_VIEW_CANCHANGE,.f.)
    EndIf

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_BI3' , oStruBI3 , 'BI3MASTER' )
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )
    oView:SetOwnerView( 'VIEW_BI3', 'SUPERIOR' )
    oView:EnableTitleView( 'VIEW_BI3', 'SIP - Produtos de Saúde' )

Return oView

