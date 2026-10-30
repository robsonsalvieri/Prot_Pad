#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6080.ch'

/*/{Protheus.doc} LOJA6080
    Cadastro de Eixo do Catálogo de Auto Peças
    @type    Function
    @author  Alberto Deviciente
    @since   24/06/2026
    @version P12
    @return  Nil, Nulo
/*/
Function LOJA6080()
    Local oBrowse := FWMBrowse():New() as Object

    oBrowse:SetAlias('MEB')
    oBrowse:SetDescription(STR0001) //"Cadastro de Eixo"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   24/06/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Eixo
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MEB')
    Local oModel  := MPFormModel():New('LOJA6080', /*Pre-Validacao*/,/* Valid Model */,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Cadastro de Eixo"
    oModel:AddFields('MEBMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MEB_FILIAL', 'MEB_CODEIX'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   24/06/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Eixo
/*/
Static Function ViewDef()
    Local oView   as Object
    Local oStruct as Object
    Local oModel  as Object

    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MEB')
    oModel  := ModelDef()
 
    // Remove campos da estrutura que nao serao apresentados na tela
    oStruct:RemoveField('MEB_FILFAB')
    oStruct:RemoveField('MEB_FILMOD')

    oView:SetDescription(STR0001) //"Cadastro de Eixo"
    oView:SetModel(oModel)
    oView:AddField('MEB', oStruct, 'MEBMASTER')

Return oView

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   24/06/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA6080"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA6080"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA6080"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA6080"  Operation 5 Access 0 //"Excluir"

Return aRet
