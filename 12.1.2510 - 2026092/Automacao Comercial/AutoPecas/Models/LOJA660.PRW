#include "totvs.ch"
#include "fwmvcdef.ch"
#include "loja660.ch"

/*/{Protheus.doc} LOJA660
    Cadastro de Conjunto Sistema
    @type    function
    @author  Bruno Almeida
    @since   22/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA660()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias("MI2")
    oBrowse:SetDescription(STR0001) //"Conjunto Sistema"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Conjunto Sistema
    @type    function
    @author  Bruno Almeida
    @since   22/05/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Conjunto Sistema
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA660" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA660" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA660" Operation 4 Access 0 //"Editar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA660" Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Conjunto Sistema
    @type    function
    @author  Bruno Almeida
    @since   22/05/2026
    @version P12
    @return  Objeto de Model para o cadastro de Conjunto Sistema
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, "MI2")
    Local oModel  := MPFormModel():New("LOJA660", /*Pre-Validacao*/,/*Valid Model*/,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Conjunto Sistema"
    oModel:AddFields("MI2MASTER", /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({"MI2_FILIAL", "MI2_CODCON"})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Conjunto Sistema
    @type    function
    @author  Bruno Almeida
    @since   22/05/2026
    @version P12
    @return  Objeto de View para o cadastro de Conjunto Sistema
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, "MI2")
    Local oModel  := FWLoadModel("LOJA660")

    oView:SetDescription(STR0001) //"Conjunto Sistema"
    oView:SetModel(oModel)
    oView:AddField("MI2", oStruct, "MI2MASTER")
    oView:EnableTitleView("MI2", STR0001) //"Conjunto Sistema"

Return oView
