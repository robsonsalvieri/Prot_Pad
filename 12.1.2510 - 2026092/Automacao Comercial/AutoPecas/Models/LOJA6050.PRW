#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA6050.ch"

/*/{Protheus.doc} LOJA6050
    Cadastro de Caracteristicas de Produto
    @type    function
    @author  Bruno Almeida
    @since   16/06/2026
    @version P12
    @return  Nil
/*/
Function LOJA6050()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('D4X')
    oBrowse:SetDescription(STR0001) //"Cadastro de Caracteristicas de Produto"

    oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Caracteristicas de Produto
    @type    function
    @author  Bruno Almeida
    @since   16/06/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Caracteristicas de Produto
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6050"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6050"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6050"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6050"  Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Caracteristicas de Produto
    @type    function
    @author  Bruno Almeida
    @since   16/06/2026
    @version P12
    @return  Objeto de Model para o cadastro de Caracteristicas de Produto
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'D4X')
    Local oModel  := MPFormModel():New('LOJA6050', /*Pre-Validacao*/, {|oMdl| D4XValDup(oMdl)}, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Cadastro de Caracteristicas de Produto"
    oModel:AddFields('D4XMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'D4X_FILIAL', 'D4X_PROD', 'D4X_CARAC', 'D4X_VALOR', 'D4X_CATEGO'})

Return oModel

/*/{Protheus.doc} D4XValDup
    Valida se a chave informada ja existe na tabela D4X antes de concluir a inclusao.
    Executada somente em inclusao (operacao 3); em alteracao a chave e igual
    a do registro em edicao e nao ha risco de duplicidade.
    @type    function
    @author  Bruno Almeida
    @since   17/06/2026
    @version P12
    @return  .T. quando a chave nao existir; .F. quando houver duplicidade
/*/
Static Function D4XValDup(oModel)
    Local lRet    := .T.
    Local cProd   := ""
    Local cCarac  := ""
    Local cValor  := ""
    Local cCatego := ""

    // Valida somente na operacao de inclusao (3) ou alteracao (4)
    If oModel:GetOperation() == 3
        cProd   := oModel:GetValue("D4XMASTER", "D4X_PROD")
        cCarac  := oModel:GetValue("D4XMASTER", "D4X_CARAC")
        cValor  := oModel:GetValue("D4XMASTER", "D4X_VALOR")
        cCatego := oModel:GetValue("D4XMASTER", "D4X_CATEGO")

        If !Empty(Posicione("D4X", 1, xFilial("D4X") + cProd + cCarac + cValor + cCatego, "D4X_PROD")) 
            Help(, , "LOJA6050", , STR0006, 1, 0) //"Registro já existente na tabela. Verifique o produto, caracteristica e valor."
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Caracteristicas de Produto
    @type    function
    @author  Bruno Almeida
    @since   16/06/2026
    @version P12
    @return  Objeto de View para o cadastro de Caracteristicas de Produto
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'D4X')
    Local oModel  := FWLoadModel('LOJA6050')

    oView:SetDescription(STR0001) //"Cadastro de Caracteristicas de Produto"
    oView:SetModel(oModel)
    oView:AddField('D4X', oStruct, 'D4XMASTER')
    oView:EnableTitleView('D4X', STR0001) //"Cadastro de Caracteristicas de Produto"

Return oView
