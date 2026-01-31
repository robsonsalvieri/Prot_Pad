#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D05.CH"

/*/{Protheus.doc} RU34D05()
    This function needed for maintaince relations between relationship codes and contract types records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34D05()
*/
Function RU34D05()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array

    aRotina := MenuDef()

    lRet := .T.
    aArea := GetArea()
    
    DbSeelectArea('F4Y')
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
    oBrowse:SetAlias("F4Y")
    oBrowse:SetDescription(STR0001) //Connection of Relation codes to Contract types
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

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D05", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D05", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D05", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete

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
    Local oStrF4Y := FWFormStruct(1, 'F4Y')
    
    oModel := MPFormModel():New('RU34D05')
    oModel:AddFields('F4YMASTER', Nil, oStrF4Y)
    oModel:SetPrimaryKey({'F4Y_FILIAL','F4Y_TYPE'})

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
    Local oModel  := FwLoadModel("RU34D05")
    Local oStrF4Y := FWFormStruct(2, "F4Y")

    oStrF4Y:RemoveField('F4Y_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F4Y_M", oStrF4Y, "F4YMASTER")
Return(oView)
                   
//Merge Russia R14 
                   
