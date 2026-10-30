#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6070.ch'

/*/{Protheus.doc} LOJA6070
    Cadastro de Modelo de Eixo do Catálogo de Auto Peças
    @type    Function
    @author  Alberto Deviciente
    @since   21/06/2026
    @version P12
    @return  Nil, Nulo
/*/
Function LOJA6070()
    Local oBrowse := FWMBrowse():New() as Object

    oBrowse:SetAlias('MG2')
    oBrowse:SetDescription(STR0001) //"Modelo de Eixo"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Modelo de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   21/06/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Modelo de Eixo
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MG2')
    Local oModel  := MPFormModel():New('LOJA6070', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Modelo de Eixo"
    oModel:AddFields('MG2MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MG2_FILIAL', 'MG2_CODMOD'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Modelo de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   21/06/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Modelo de Eixo
/*/
Static Function ViewDef()
    Local oModel  As Object
    Local oView   As Object
    Local oStruct As Object

    oModel  := FWLoadModel('LOJA6070')
    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MG2')

    oView:SetDescription(STR0001) //"Modelo de Eixo"
    oView:SetModel(oModel)
    oView:AddField('VIEW_MG2', oStruct, 'MG2MASTER')

Return oView

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Modelo de Eixo
    @type    Function
    @author  Alberto Deviciente
    @since   21/06/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA6070"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA6070"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA6070"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA6070"  Operation 5 Access 0 //"Excluir"

Return aRet
