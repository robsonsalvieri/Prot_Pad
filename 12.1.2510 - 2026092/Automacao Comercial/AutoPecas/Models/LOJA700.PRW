#include "totvs.ch"
#include "fwmvcdef.ch"
#include "loja700.ch"

/*/{Protheus.doc} LOJA700
    Cadastro de Classificacao Mercadologica (ACV)
    @type    function
    @author  fabio.favaretto
    @since   24/07/2026
    @version P12
    @return  Nil
/*/
Function LOJA700()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias("ACV")
    oBrowse:SetDescription(STR0001) //"Classificacao Mercadologica"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para Classificacao Mercadologica
    @type    function
    @author  fabio.favaretto
    @since   24/07/2026
    @version P12
    @return  Array
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA700" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA700" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA700" Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para Classificacao Mercadologica (ACV)
    @type    function
    @author  fabio.favaretto
    @since   24/07/2026
    @version P12
    @return  Object
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, "ACV")
    Local oModel  := MPFormModel():New("LOJA700", /*Pre-Validacao*/, /*Valid Model*/, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Classificacao Mercadologica"
    oModel:AddFields("ACVMASTER", /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({"ACV_FILIAL", "ACV_CATEGO", "ACV_REFGRD", "ACV_CODPRO", "ACV_GRUPO"})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para Classificacao Mercadologica
    @type    function
    @author  fabio.favaretto
    @since   24/07/2026
    @version P12
    @return  Object
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, "ACV")
    Local oModel  := FWLoadModel("LOJA700")

    oView:SetDescription(STR0001) //"Classificacao Mercadologica"
    oView:SetModel(oModel)
    oView:AddField("ACV", oStruct, "ACVMASTER")
    oView:EnableTitleView("ACV", STR0001) //"Classificacao Mercadologica"

Return oView
