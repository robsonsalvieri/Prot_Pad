#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA640.CH'

/*/{Protheus.doc} LOJA640
    Cadastro de Marca
    @type    Function
    @author  Bruno Almeida
    @since   18/04/2026
    @version P12
/*/
Function LOJA640()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('MG0')
    oBrowse:SetDescription(STR0001) //"Marca"
    aRotina := MenuDef()
    
    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Marca
    @type    Function
    @author  Bruno Almeida
    @since   18/04/2026
    @version P12
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002    Action "VIEWDEF.LOJA640"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003    Action "VIEWDEF.LOJA640"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004    Action "VIEWDEF.LOJA640"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0005    Action "VIEWDEF.LOJA640"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0006    Action "VIEWDEF.LOJA640"  Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Marca
    @type    Function
    @author  Bruno Almeida
    @since   18/04/2026
    @version P12
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MG0')
    Local oModel  := MPFormModel():New('LOJA640', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001)
    oModel:AddFields('MG0MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MG0_FILIAL', 'MG0_CODMAR'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Marca
    @type    Function
    @author  Bruno Almeida
    @since   18/04/2026
    @version P12
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MG0')
    Local oModel := ModelDef()

    oView:SetDescription(STR0001) //"Marca"
    oView:SetModel(oModel)
    oView:AddField('MG0', oStruct, 'MG0MASTER')
    oView:EnableTitleView('MG0', STR0001) //"Marca"
Return oView
