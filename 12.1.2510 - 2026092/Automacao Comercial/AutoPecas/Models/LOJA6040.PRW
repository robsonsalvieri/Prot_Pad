#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "LOJA6040.ch"

/*/{Protheus.doc} LOJA6040
    Cadastro de Conjunto de Sistema x Grupo de Produto
    @type    function
    @author  Alberto Deviciente
    @since   15/06/2026
    @version P12
    @return  Nil, Nil, Sem retorno
/*/
Function LOJA6040()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('MI4')
    oBrowse:SetDescription(STR0001) //"Conjunto de Sistema x Grupo de Produto"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Conjunto de Sistema x Grupo de Produto.
    @type    function
    @author  Alberto Deviciente
    @since   15/06/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet As Array
    aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6040" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6040" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6040" Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6040" Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Conjunto de Sistema x Grupo de Produto.
    @type    function
    @author  Alberto Deviciente
    @since   15/06/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Conjunto de Sistema x Grupo de Produto
/*/
Static Function ModelDef()
    Local oStruct As Object
    Local oModel  As Object

    oStruct := FWFormStruct(1, 'MI4')
    oModel  := MPFormModel():New('LOJA6040', /*bPre*/, /*bPost*/, /*bCommit*/ , /*bCancel*/)

    oModel:SetDescription(STR0001) //"Conjunto de Sistema x Grupo de Produto"
    oModel:AddFields('MI4MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MI4_FILIAL','MI4_CODCON','MI4_CODGRU'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Conjunto de Sistema x Grupo de Produto.
    @type    function
    @author  Alberto Deviciente
    @since   15/06/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Conjunto de Sistema x Grupo de Produto
/*/
Static Function ViewDef()
    Local oModel  As Object
    Local oView   As Object
    Local oStruct As Object
    Local cViewID As Character  //ID do formulario

    oModel  := FWLoadModel('LOJA6040')
    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MI4')
    cViewID := 'VIEW_MI4'

    oView:SetDescription(STR0001) //"Conjunto de Sistema x Grupo de Produto"
    oView:SetModel(oModel)
    oView:AddField(cViewID, oStruct, 'MI4MASTER')
    oView:EnableTitleView(cViewID, STR0001) //"Conjunto de Sistema x Grupo de Produto"

Return oView
