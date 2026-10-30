#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D07.CH"

/*/{Protheus.doc} RU01D07()
    This function needed for maintaince transport price types records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example RU01D07()
*/
Function RU01D07()
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
    oBrowse:SetAlias("F58")
    oBrowse:SetSeeAll(.T.)
    oBrowse:SetDescription(STR0001)
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRotina

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0003, "VIEWDEF.RU01D07", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0002, "VIEWDEF.RU01D07", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0005, "VIEWDEF.RU01D07", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete

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
    Local oStrF58 := FWFormStruct(1, "F58")

    oModel := MPFormModel():New("RU01D07",,{|oMdl| RU01XFUN06(oMdl, STR0006, STR0007, "RU01D07","F58")},,)
    oModel:AddFields("F58MASTER", Nil, oStrF58)
    oModel:SetPrimaryKey({'F58_FILIAL','F58_TRPRIC', 'F58_DESCRI'})

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
    Local oModel  := FwLoadModel("RU01D07")
    Local oStrF58 := FWFormStruct(2, "F58")

    oStrF58:RemoveField('F58_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F58_M", oStrF58, "F58MASTER")
Return(oView)
