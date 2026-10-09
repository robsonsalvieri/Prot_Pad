#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA610.ch'

/*/{Protheus.doc} LOJA610
    Cadastro de Modelo de Transmissão do Catálogo de Auto Pecas
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Function LOJA610()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('MEW')
    oBrowse:SetDescription(STR0001) //"Modelo de Transmissão"
    aRotina := MenuDef()
    
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Modelo de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MEW')
    Local oModel  := MPFormModel():New('LOJA610', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Modelo de Transmissão"
    oModel:AddFields('MEWMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MEW_FILIAL', 'MEW_CODMOD'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Modelo de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MEW')
    Local oModel  := ModelDef()
 

    oView:SetDescription(STR0001) //"Modelo de Transmissão"
    oView:SetModel(oModel)
    oView:AddField('MEW', oStruct, 'MEWMASTER')
    oView:EnableTitleView('MEW', STR0001) //"Modelo de Transmissão"

Return oView

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Modelo de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA610"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA610"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA610"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA610"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0006  Action "VIEWDEF.LOJA610"  Operation 9 Access 0 //"Copiar"
Return aRet
