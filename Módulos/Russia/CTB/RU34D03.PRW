#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D03.CH"

/*/{Protheus.doc} RU34D03()
    This function needs for maintaince analytic sync configuration

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example RU34D03()
*/
Function RU34D03()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array

    lRet := .T.
    aArea := GetArea()

    DbSelectArea("F5A")
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object
    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F5A")
    oBrowse:SetDescription(STR0001)
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D03", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D03", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D03", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit
    aAdd( aRet, {STR0005, "VIEWDEF.RU34D03", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF5A := FWFormStruct(1, 'F5A')

    oModel := MPFormModel():New('RU34D03', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields('F5AMASTER', Nil, oStrF5A)
    oModel:SetDescription(STR0001)
    oModel:SetPrimaryKey({'F5A_FILIAL','F5A_PRCODE', 'F5A_ANCODE', 'F5A_PRTABL'})

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/10/17
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oModel  := FwLoadModel("RU34D03")
    Local oStrF5A := FWFormStruct(2, "F5A")

    oStrF5A:RemoveField('F5A_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F5A_M", oStrF5A, "F5AMASTER")
Return(oView)
                   
//Merge Russia R14 
                   
