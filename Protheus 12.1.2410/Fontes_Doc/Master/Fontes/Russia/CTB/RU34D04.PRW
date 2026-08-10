#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D04.CH"

/*/{Protheus.doc} RU34D04()
    This function needed for maintaince type of contracts records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34D04()
*/
Function RU34D04()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array

    aRotina := MenuDef()

    lRet := .T.
    aArea := GetArea()
    
    DbSeelectArea('F4K')
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F4K")
    oBrowse:SetDescription(STR0001) //Contract types
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D04", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D04", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D04", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit
    aAdd( aRet, {STR0005, "VIEWDEF.RU34D04", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete
    aAdd( aRet, {STR0006, "RU34XFUN06('" + STR0006 + "','RU34D04')", 0, 9, 0, Nil} ) // Copy

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF4K := FWFormStruct(1, 'F4K')

    oModel := MPFormModel():New('RU34D04',{|| RU34XFUN08(STR0007, STR0009, 'RU34D04','F4K')})
    oModel:AddFields('F4KMASTER', Nil, oStrF4K)
    oModel:SetPrimaryKey({'F4K_FILIAL','F4K_CTYPE','F4K_CLISUP'})

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oModel  := FwLoadModel("RU34D04")
    Local oStrF4K := FWFormStruct(2, "F4K")

    oStrF4K:RemoveField('F4K_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F4K_M", oStrF4K, "F4KMASTER")
Return(oView)
                   
//Merge Russia R14 
                   
