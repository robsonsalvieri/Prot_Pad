#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU06D01.CH'

/*/{Protheus.doc} RU06D01RUS()
    This function needed for maintaince signers records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/10
    @example RU06D01RUS()
*/
Function RU06D01RUS()
    Local lRet := .T.
    RU06D01()
Return(lRet)

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2024/01/10
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aRet := FWLoadMenuDef("RU06D01")

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2024/01/10
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel As Object
    Local oEAIEVENT := np.framework.eai.MVCEvent():New('RU06D01')
    
    oModel := FWLoadModel('RU06D01')
    oModel:InstallEvent("NPEAI"	,,oEAIEVENT)

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2024/01/10
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    
    oView := FWLoadView('RU06D01')

Return(oView)
                   
//Merge Russia R14 
                   
