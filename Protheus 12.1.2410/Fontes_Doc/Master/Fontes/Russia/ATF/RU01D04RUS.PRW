#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D04.CH"

/*/{Protheus.doc} RU01D04RUS()
    This function needed for maintaince OKTMO records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/12/19
    @version 12.1.33
    @example RU01D04()
*/
Function RU01D04RUS()
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
    @since 2023/12/19
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object
    
    aRotina := MenuDef()
    oBrowse := FWLoadBrw("RU01D04")

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/12/19
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aRet := FWLoadMenuDef("RU01D04")

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/12/19
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    
    oModel := FWLoadModel('RU01D04')

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/12/19
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object

    oView := FWLoadView('RU01D04')

Return(oView)
