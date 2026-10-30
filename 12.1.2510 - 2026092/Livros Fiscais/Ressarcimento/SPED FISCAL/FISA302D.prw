#INCLUDE "FISA302D.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Fonte responsavel pela tela de Apuração - FISA193
*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA302D
  
Rotina de Visualização da Apuração do ICMS Recolhido Anteriormente.
Para o Estado de Rio Grande do SUL, o método de apuração é determinado pelo Decreto 54.308.

@author Rafael.soliveira 
@since 28/01/2018 
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA302D()

    Local oBrowse

    Private lAutomato := Iif(IsBlind(),.T.,.F.)

    If AliasIndic("CIG") .and. AliasIndic("CIH") .and. AliasIndic("CII") .and. AliasIndic("CIJ") .and. AliasIndic("CIK") .and. AliasIndic("CIL") .and. AliasIndic("CIF") .and. AliasIndic("CIM") 
            DbSelectArea ("CIG") //Apuração ressarcimento Total
            DbSelectArea ("CIH") //Apuração ressarcimento ICMS SPED - Totais por Enquadramento
            DbSelectArea ("CII") //Apuração ressarcimento ICMS SPED - Detalhe por item
            DbSelectArea ("CIJ") //Apuração ressarcimento ICMS SPED - Enquadramento Cabeçalho
            DbSelectArea ("CIK") //Apuração ressarcimento ICMS SPED - Enquadramento por Item
            DbSelectArea ("CIL") //Apuração ressarcimento ICMS SPED - Saldo

            oBrowse:= FWMBrowse():New()
            oBrowse:SetAlias("CIG")
            oBrowse:SetDescription(STR0001) //STR0001 //"Apuração do Ressarcimento / Complemento"
            If !lAutomato
                oBrowse:Activate()
            Else
                FISA302D()
            EndIF
    Else
            If !lAutomato
                MsgStop(STR0002) //STR0002 //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
            EndIF
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA302D' OPERATION 2 ACCESS 0 //STR0003 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'FISA302CEXC'      OPERATION 5 ACCESS 0 //STR0004 //"Excluir"
    ADD OPTION aRotina TITLE STR0005 ACTION 'FISA302C'         OPERATION 3 ACCESS 0 //STR0005 //"Apuração"

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructCIG := FWFormStruct(1,"CIG")
    Local oStructCIH := FWFormStruct(1,"CIH")
    Local oStructCII := FWFormStruct(1,"CII")

    oModel := MPFormModel():New("FISA302D",,)
    oModel:AddFields("CIGMASTER",,oStructCIG)
    oModel:AddGrid("CIHDETAIL","CIGMASTER",oStructCIH)
    oModel:AddGrid("CIIDETAIL","CIHDETAIL",oStructCII)
    oModel:SetRelation("CIHDETAIL",{{'CIH_FILIAL','xFilial("CIH")'},{'CIH_PERIOD','CIG_PERIOD'}},CIH->(IndexKey(1)))
    oModel:SetRelation("CIIDETAIL",{{'CII_FILIAL','xFilial("CII")'},{'CII_PERIOD','CIH_PERIOD'},{'CII_ENQLEG','CIH_ENQLEG'},{'CII_REGRA','CIH_REGRA'} } ,CII->(IndexKey(1)))
    oModel:GetModel("CIGMASTER"):SetOnlyView ( .T. )
    oModel:GetModel("CIHDETAIL"):SetOnlyView ( .T. )
    oModel:GetModel("CIIDETAIL"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0001)                       //STR0001 //"Apuração do Ressarcimento / Complemento"
    oModel:GetModel("CIGMASTER"):SetDescription(STR0006) //STR0006 //"Apuração do Ressarcimento / Complemento"
    oModel:GetModel("CIHDETAIL"):SetDescription(STR0007) //STR0007 //"Apuração do Ressarcimento / Complemento - Por Regra / Equadramento"
    oModel:GetModel("CIIDETAIL"):SetDescription(STR0008) //STR0008 //"Apuração do Ressarcimento / Complemento - Detalhada"
    oModel:SetOnDemand()
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel     := FWLoadModel("FISA302D")
    Local oStructCIG := FWFormStruct(2,"CIG")
    Local oStructCIH := FWFormStruct(2,"CIH")
    Local oStructCII := FWFormStruct(2,"CII")
    Local oView

    //---Remove campos que não serão exibidos---//
    oStructCIG:RemoveField('CIG_IDAPUR') 
    oStructCIH:RemoveField('CIH_IDAPUR') 
    oStructCIH:RemoveField('CIH_PERIOD')
    oStructCII:RemoveField('CII_IDAPUR')
    oStructCII:RemoveField('CII_PERIOD')
    oStructCII:RemoveField('CII_ORDEM')
    oStructCII:RemoveField('CII_ICMEFE')
    oStructCII:RemoveField('CII_BURET')
    oStructCII:RemoveField('CII_VURET')
    oStructCII:RemoveField('CII_VURFCP')
    oStructCII:RemoveField('CII_VUREST') 
    oStructCII:RemoveField('CII_VURTFC') 
    oStructCII:RemoveField('CII_VUCST')
    oStructCII:RemoveField('CII_VUCFC')
    oStructCII:RemoveField('CII_TPREG')
    oStructCII:RemoveField('CII_UNID')
    oStructCII:RemoveField('CII_PDV')
    oStructCII:RemoveField('CII_LIVRO')
    oStructCII:RemoveField('CII_CODDA')
    oStructCII:RemoveField('CII_NUMDA')
    oStructCII:RemoveField('CII_CODRES')
    oStructCII:RemoveField('CII_REGRA')
    oStructCII:RemoveField('CII_ENQLEG')

    //---Totais da Apuração---//
    oStructCIG:SetProperty( 'CIG_VCREDI' , MVC_VIEW_TITULO,STR0009) //"Val. Crédito ICMS OP"
    oStructCIG:SetProperty( 'CIG_VRESSA' , MVC_VIEW_TITULO,STR0010) //"Val. Ressarcimento"
    oStructCIG:SetProperty( 'CIG_REFECP' , MVC_VIEW_TITULO,STR0011) //"Val. Ressarc. FECP"
    oStructCIG:SetProperty( 'CIG_VCMPL'  , MVC_VIEW_TITULO,STR0012) //"Val. Complemento"
    oStructCIG:SetProperty( 'CIG_VCMFCP' , MVC_VIEW_TITULO,STR0013) //"Val. Complem. FECP"

    //---Totais da Apuração - Por Regra / Equadramento---//
    oStructCIH:SetProperty( 'CIH_ENQLEG' , MVC_VIEW_TITULO,STR0014) //"Enquadramento Legal"
    oStructCIH:SetProperty( 'CIH_VCREDI' , MVC_VIEW_TITULO,STR0009) //"Val. Crédito ICMS OP"
    oStructCIH:SetProperty( 'CIH_VRESSA' , MVC_VIEW_TITULO,STR0010) //"Val. Ressarcimento"
    oStructCIH:SetProperty( 'CIH_REFECP' , MVC_VIEW_TITULO,STR0011) //"Val. Ressarc. FECP"
    oStructCIH:SetProperty( 'CIH_VCOMPL' , MVC_VIEW_TITULO,STR0012) //"Val. Complemento"
    oStructCIH:SetProperty( 'CIH_VCMFCP' , MVC_VIEW_TITULO,STR0013) //"Val. Complem. FECP"
    oStructCIH:SetProperty( 'CIH_REGRA'  , MVC_VIEW_TITULO,STR0017) //"Regra de Cálculo"
    oStructCIH:SetProperty( 'CIH_REGRA'  , MVC_VIEW_ORDEM,"01") //"Regra de Cálculo"
    oStructCIH:SetProperty( 'CIH_ENQLEG' , MVC_VIEW_ORDEM,"02") //"Enquadramento Legal"
    oStructCIH:SetProperty( 'CIH_VCREDI' , MVC_VIEW_ORDEM,"03") //"Val. Crédito ICMS OP"
    oStructCIH:SetProperty( 'CIH_VRESSA' , MVC_VIEW_ORDEM,"04") //"Val. Ressarcimento"    
    oStructCIH:SetProperty( 'CIH_REFECP' , MVC_VIEW_ORDEM,"05") //"Val. Ressarc. FECP"
    oStructCIH:SetProperty( 'CIH_VCOMPL' , MVC_VIEW_ORDEM,"06") //"Val. Complemento"
    oStructCIH:SetProperty( 'CIH_VCMFCP' , MVC_VIEW_ORDEM,"07") //"Val. Complem. FECP"

    //---Totais da Apuração - Por Regra / Equadramento - Detalhada---//
    oStructCII:SetProperty( 'CII_ICMEFS' , MVC_VIEW_TITULO,STR0019) //"ICMS OP - Saída (Efetivo)"
    oStructCII:SetProperty( 'CII_VUCRED' , MVC_VIEW_TITULO,STR0020) //"ICMS OP - Entrada"
    oStructCII:SetProperty( 'CII_VCREDI' , MVC_VIEW_TITULO,STR0021) //"Crédito ICMS OP"
    oStructCII:SetProperty( 'CII_VRESSA' , MVC_VIEW_TITULO,STR0022) //"Ressarcimento"
    oStructCII:SetProperty( 'CII_VREFCP' , MVC_VIEW_TITULO,STR0023) //"Ressarc. FECP"
    oStructCII:SetProperty( 'CII_VCMPL'  , MVC_VIEW_TITULO,STR0024) //"Complemento"
    oStructCII:SetProperty( 'CII_VCMFCP' , MVC_VIEW_TITULO,STR0025) //"Complem. FECP"
    oStructCII:SetProperty( 'CII_QTDSLD' , MVC_VIEW_TITULO,STR0026) //"Estoque - Saldo"
    oStructCII:SetProperty( 'CII_MUCRED' , MVC_VIEW_TITULO,STR0027) //"Estoque - Média ICMS OP"
    oStructCII:SetProperty( 'CII_MUBST'  , MVC_VIEW_TITULO,STR0028) //"Estoque - Média BC ST FECP"
    oStructCII:SetProperty( 'CII_MUVSTF' , MVC_VIEW_TITULO,STR0029) //"Estoque - Média ICMS ST FECP"
    oStructCII:SetProperty( 'CII_MUVSF'  , MVC_VIEW_TITULO,STR0030) //"Estoque - Média FECP"
    oStructCII:SetProperty( 'CII_PRODUT' , MVC_VIEW_ORDEM,"01") 
    oStructCII:SetProperty( 'CII_DTMOV'  , MVC_VIEW_ORDEM,"02") 
    oStructCII:SetProperty( 'CII_TPMOV'  , MVC_VIEW_ORDEM,"03") 
    oStructCII:SetProperty( 'CII_TIPO'   , MVC_VIEW_ORDEM,"04")     
    oStructCII:SetProperty( 'CII_NFISCA' , MVC_VIEW_ORDEM,"05") 
    oStructCII:SetProperty( 'CII_SERIE'  , MVC_VIEW_ORDEM,"06") 
    oStructCII:SetProperty( 'CII_ITEM'   , MVC_VIEW_ORDEM,"07") 
    oStructCII:SetProperty( 'CII_CFOP'   , MVC_VIEW_ORDEM,"08") 
    oStructCII:SetProperty( 'CII_CST'    , MVC_VIEW_ORDEM,"09")     
    oStructCII:SetProperty( 'CII_PARTIC' , MVC_VIEW_ORDEM,"10") 
    oStructCII:SetProperty( 'CII_LOJA'   , MVC_VIEW_ORDEM,"11") 
    oStructCII:SetProperty( 'CII_ESPECI' , MVC_VIEW_ORDEM,"12") 
    oStructCII:SetProperty( 'CII_QTDMOV' , MVC_VIEW_ORDEM,"13") 
    oStructCII:SetProperty( 'CII_VUNIT'  , MVC_VIEW_ORDEM,"14")     
    oStructCII:SetProperty( 'CII_ICMEFS' , MVC_VIEW_ORDEM,"15") 
    oStructCII:SetProperty( 'CII_VUCRED' , MVC_VIEW_ORDEM,"16") 
    oStructCII:SetProperty( 'CII_VCREDI' , MVC_VIEW_ORDEM,"17") 
    oStructCII:SetProperty( 'CII_VRESSA' , MVC_VIEW_ORDEM,"18") 
    oStructCII:SetProperty( 'CII_VREFCP' , MVC_VIEW_ORDEM,"19") 
    oStructCII:SetProperty( 'CII_VCMPL'  , MVC_VIEW_ORDEM,"20")     
    oStructCII:SetProperty( 'CII_VCMFCP' , MVC_VIEW_ORDEM,"21") 
    oStructCII:SetProperty( 'CII_QTDSLD' , MVC_VIEW_ORDEM,"22") 
    oStructCII:SetProperty( 'CII_MUCRED' , MVC_VIEW_ORDEM,"23") 
    oStructCII:SetProperty( 'CII_MUBST'  , MVC_VIEW_ORDEM,"24") 
    oStructCII:SetProperty( 'CII_MUVSTF' , MVC_VIEW_ORDEM,"25")     
    oStructCII:SetProperty( 'CII_MUVSF'  , MVC_VIEW_ORDEM,"26") 
    oStructCII:SetProperty( 'CII_SPED'   , MVC_VIEW_ORDEM,"27") 

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CIG",oStructCIG,"CIGMASTER")
    oView:AddGrid("VIEW_CIH",oStructCIH,"CIHDETAIL")
    oView:AddGrid("VIEW_CII",oStructCII,"CIIDETAIL")
    oView:CreateHorizontalBox("TOPO",20)
    oView:CreateHorizontalBox("MEDIO",25)
    oView:CreateHorizontalBox("BAIXO",55)
    oView:EnableTitleView('VIEW_CIG',STR0015) //"Totais da Apuração"
    oView:EnableTitleView('VIEW_CIH',STR0016) //"Totais da Apuração - Por Regra / Equadramento"
    oView:EnableTitleView('VIEW_CII',STR0018) //"Totais da Apuração - Por Regra / Equadramento - Detalhada"
    oView:SetOwnerView("VIEW_CIG","TOPO")
    oView:SetOwnerView("VIEW_CIH","MEDIO") 
    oView:SetOwnerView("VIEW_CII","BAIXO") 
    oView:SetViewProperty("VIEW_CII", "ENABLENEWGRID")
    oView:SetViewProperty("VIEW_CII", "GRIDSEEK", {.T.})

Return oView



