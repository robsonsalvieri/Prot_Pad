#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU99D200.CH"

/*/{Protheus.doc} RU99D200()
    "Endpoints" routine main function
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version  1.0
    @return Logical, Success flag
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Function RU99D200()

    Local lRet as Logical
    Local oBrowse as Object
    Private aRotina as Array

    lRet := .T.
    SX2->(DbSetOrder(1))
    SX2->(DbSeek('F6E'))

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F6E")
    oBrowse:SetDescription(X2Nome()) 
    oBrowse:SetAttach(.T.)
    oBrowse:Activate()

Return(lRet)

/*/{Protheus.doc} MenuDef
    Menu for "Endpoints" routine
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version 1.0
    @return Array, Points of the menu
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function MenuDef()

    Local aRet as Array

    aRet := {{STR0001, "VIEWDEF.RU99D200", 0, MODEL_OPERATION_VIEW, 0, Nil},; // View
            {STR0002, "VIEWDEF.RU99D200", 0, MODEL_OPERATION_INSERT, 0, Nil},; // Add
            {STR0003, "VIEWDEF.RU99D200", 0, MODEL_OPERATION_UPDATE, 0, Nil},; // Update
            {STR0004, "VIEWDEF.RU99D200", 0, MODEL_OPERATION_DELETE, 0, Nil}} // Delete

Return(aRet)

/*/{Protheus.doc} ModelDef
    Creates Model for "Endpoints" routine
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version 1.0
    @return Object, Model of "Endpoints" routine
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function ModelDef()

    Local oModel as Object
    Local oStrF6E as Object

    oStrF6E := FWFormStruct(1, "F6E")
    oModel := MPFormModel():New("RU99D200", ,  , )

    oModel:AddFields("F6EMASTER", Nil, oStrF6E)
    oModel:SetPrimaryKey({"F6E_FILIAL", "F6E_CODE"})

Return(oModel)

/*/{Protheus.doc} ViewDef
    Creates View for "Endpoints" routine
    @type function
    @author Felipe Morais
    @since 13/01/2017
    @version 1.0
    @return Object, View of "Endpoints" routine
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5828
/*/
Static Function ViewDef()

    Local oView as Object
    Local oModel as Object
    Local oStrF6E as Object

    oModel := ModelDef()
    oStrF6E := FWFormStruct(2, "F6E")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F6E", oStrF6E, "F6EMASTER")

Return(oView)
                   
//Merge Russia R14 
                   
