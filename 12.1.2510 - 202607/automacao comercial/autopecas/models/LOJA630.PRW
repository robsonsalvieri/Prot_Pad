#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA630.CH'

/*/{Protheus.doc} LOJA630
    Cadastro de Montadora
    @type    Function
    @author  Bruno Almeida
    @since   10/04/2026
    @version P12
/*/
Function LOJA630()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('ME0')
    oBrowse:SetDescription(STR0001) //"Montadora"
    aRotina := MenuDef()
    
    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Montadora
    @type    Function
    @author  Bruno Almeida
    @since   10/04/2026
    @version P12
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002    Action "VIEWDEF.LOJA630"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003    Action "VIEWDEF.LOJA630"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004    Action "VIEWDEF.LOJA630"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0005    Action "VIEWDEF.LOJA630"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0006    Action "VIEWDEF.LOJA630"  Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Montadora
    @type    Function
    @author  Bruno Almeida
    @since   10/04/2026
    @version P12
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'ME0')
    Local oModel  := MPFormModel():New('LOJA630', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription('Montadora')
    oModel:AddFields('ME0MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'ME0_FILIAL', 'ME0_CODMOD'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Montadora
    @type    Function
    @author  Bruno Almeida
    @since   10/04/2026
    @version P12
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'ME0')
    Local oModel := ModelDef()

    oView:SetDescription(STR0001) //"Montadora"
    oView:SetModel(oModel)
    oView:AddField('ME0', oStruct, 'ME0MASTER')
    oView:EnableTitleView('ME0', STR0001) //"Montadora"
Return oView
