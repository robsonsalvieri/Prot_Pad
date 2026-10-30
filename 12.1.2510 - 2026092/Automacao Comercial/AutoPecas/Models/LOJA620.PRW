#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA620.ch'

/*/{Protheus.doc} LOJA620
    Cadastro de Transmissão do Catálogo de Auto Pecas
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Function LOJA620()
    Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('ME9')
    oBrowse:SetDescription(STR0001) //"Cadastro de Transmissão"
    aRotina := MenuDef()
    
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'ME9')
    Local oModel  := MPFormModel():New('LOJA620', /*Pre-Validacao*/,/* Valid Model */,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Cadastro de Transmissão"
    oModel:AddFields('ME9MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'ME9_FILIAL', 'ME9_CODTRA'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'ME9')
    Local oModel := ModelDef()
 
    // Remove campo da estrutura que não será apresentado na tela
    oStruct:RemoveField('ME9_FILFAB')            

    oView:SetDescription(STR0001) //"Cadastro de Transmissão"
    oView:SetModel(oModel)
    oView:AddField('ME9', oStruct, 'ME9MASTER')
    oView:EnableTitleView('ME9', STR0001) //"Cadastro de Transmissão"

Return oView

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Transmissão
    @type  Function
    @author eduardo.Flima
    @since 10/04/2026
    @version P12
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA620"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA620"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA620"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA620"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0006  Action "VIEWDEF.LOJA620"  Operation 9 Access 0 //"Copiar"
Return aRet
