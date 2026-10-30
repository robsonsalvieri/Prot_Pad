#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D07.CH"

/*/{Protheus.doc} RU34D07()
    This function needed for maintaince counterparty groups records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34D07()
*/
Function RU34D07()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array
    aRotina := MenuDef()

    lRet := .T.
    aArea := GetArea()
    
    DbSeelectArea('F43')
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
    oBrowse:SetAlias("F43")
    oBrowse:SetDescription(STR0001) // Counterparties groups
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

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D07", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D07", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D07", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit
    aAdd( aRet, {STR0005, "VIEWDEF.RU34D07", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete
    aAdd( aRet, {STR0006, "RU34XFUN06('" + STR0006 + "','RU34D07')", 0, 9, 0, Nil} ) // Copy

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
    Local oStrF43 := FWFormStruct(1, 'F43')

    oModel := MPFormModel():New('RU34D07',{|| RU34XFUN08(STR0007, STR0009, 'RU34D07','F43')})
    oModel:AddFields('F43MASTER', Nil, oStrF43,{|oMdl| ChkDupl(oMdl)})
    oModel:SetPrimaryKey({'F43_FILIAL','F43_GRCNS'})

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
    Local oModel  := FwLoadModel("RU34D07")
    Local oStrF43 := FWFormStruct(2, "F43")

    oStrF43:RemoveField('F43_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F43_M", oStrF43, "F43MASTER")
Return(oView)

/*/{Protheus.doc} ChkDupl()
    This function check duplicates in F43 table

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2024/01/12
    @example ChkDupl(oModel)
*/
Static Function ChkDupl(oModel)
    Local lRet := .T.
    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        lRet := ExistChav("F43", oModel:GetValue("F43_GRCNS"))
    EndIf
Return(lRet)
                   
//Merge Russia R14 
                   
