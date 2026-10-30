#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D08.CH"

/*/{Protheus.doc} RU34D08()
    This function needed for maintaince Connection of number series to legal contract types

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/13
    @version 12.1.33
    @example RU34D08()
*/
Function RU34D08()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array
    aRotina := MenuDef()

    lRet := .T.
    aArea := GetArea()
    
    DbSeelectArea('F65')
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/11/13
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object
    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F65")
    oBrowse:SetDescription(STR0001) // Connection of number series to contract types
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/11/13
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D08", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D08", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D08", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit
    aAdd( aRet, {STR0005, "VIEWDEF.RU34D08", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete
    aAdd( aRet, {STR0006, "RU34XFUN06('" + STR0006 + "','RU34D08')", 0, 9, 0, Nil} ) // Copy

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/11/13
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF65 := FWFormStruct(1, 'F65')

    oModel := MPFormModel():New('RU34D08',{|| RU34XFUN08(STR0007, STR0009, 'RU34D08','F65')})
    oModel:AddFields('F65MASTER', Nil, oStrF65,{|oMdl| RU34D08001(oMdl)})
    oModel:SetPrimaryKey({'F65_FILIAL','F65_CTYPE','F65_TDOC'})

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/11/13
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oModel  := FwLoadModel("RU34D08")
    Local oStrF65 := FWFormStruct(2, "F65")

    oStrF65:RemoveField('F65_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F65_M", oStrF65, "F65MASTER")
Return(oView)

/*/{Protheus.doc} RU34D08001(oModel)
    This function needed search duplicates in F65 table, calls on MdlPosValidation

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/21
    @version 12.1.33
    @example RU34D08001(oModel)
*/
Function RU34D08001(oModel)
    Local lRet := .T.
    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        lRet := ExistChav('F65', oModel:GetValue('F65_CTYPE') + oModel:GetValue('F65_TDOC'))
    EndIf
Return(lRet)
                   
//Merge Russia R14 
                   
