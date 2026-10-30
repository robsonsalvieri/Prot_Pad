#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA650.ch"

/*/{Protheus.doc} LOJA650
    Cadastro de Veiculo
    @type    function
    @author  Bruno Almeida
    @since   14/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA650()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('ME6')
    oBrowse:SetDescription(STR0001) //"Veiculo"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Veiculo
    @type    function
    @author  Bruno Almeida
    @since   14/05/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Veiculo
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0005    Action "VIEWDEF.LOJA650"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0002    Action "VIEWDEF.LOJA650"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003    Action "VIEWDEF.LOJA650"  Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0004    Action "VIEWDEF.LOJA650"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006    Action "VIEWDEF.LOJA650"  Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Veiculo
    @type    function
    @author  Bruno Almeida
    @since   14/05/2026
    @version P12
    @return  Objeto de Model para o cadastro de Veiculo
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'ME6')
    Local oModel  := MPFormModel():New('LOJA650', /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Veiculo"
    oModel:AddFields('ME6MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'ME6_FILIAL', 'ME6_CODVEI'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Veiculo
    @type    function
    @author  Bruno Almeida
    @since   14/05/2026
    @version P12
    @return  Objeto de View para o cadastro de Veiculo
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'ME6')
    Local oModel  := FWLoadModel('LOJA650')

    oView:SetDescription(STR0001) //"Veiculo"
    oView:SetModel(oModel)
    oView:AddField('ME6', oStruct, 'ME6MASTER')
    oView:EnableTitleView('ME6', STR0001) //"Veiculo"

Return oView
