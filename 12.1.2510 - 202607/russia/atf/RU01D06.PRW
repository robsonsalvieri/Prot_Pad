#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D06.CH"

/*/{Protheus.doc} RU01D06()
    This function needed for maintaince transport types records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example RU01D06()
*/
Function RU01D06()
    Local lRet as Logical
    Local oBrowse as Object
    Private aRotina as Array

    lRet := .T.

    oBrowse := BrowseDef()
    oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object
    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F57")
    oBrowse:SetSeeAll(.T.)
    oBrowse:SetDescription(STR0001)
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0003, "VIEWDEF.RU01D06", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0002, "VIEWDEF.RU01D06", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0005, "VIEWDEF.RU01D06", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF57 := FWFormStruct(1, "F57")

    oModel := MPFormModel():New("RU01D06",,{|oMdl| RU01XFUN06(oMdl, STR0006, STR0007, "RU01D06","F57")},,)
    oModel:AddFields("F57MASTER", Nil, oStrF57)
    oModel:SetPrimaryKey({'F57_FILIAL','F57_TRANTY', 'F57_DESCRI'})

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView as Object
    Local oModel  := FwLoadModel("RU01D06")
    Local oStrF57 := FWFormStruct(2, "F57")

    oStrF57:RemoveField('F57_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F57_M", oStrF57, "F57MASTER")
Return(oView)
